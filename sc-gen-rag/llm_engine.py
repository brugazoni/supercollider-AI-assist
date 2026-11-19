import config
import sys

# Attempt lazy-loading of providers so the application doesn't crash 
# if the user hasn't pip-installed the new external dependencies yet.
try:
    from google import genai
    from google.genai import types as genai_types
except ImportError:
    genai = None
    genai_types = None

try:
    from openai import OpenAI
except ImportError:
    OpenAI = None

try:
    import anthropic
except ImportError:
    anthropic = None

try:
    from langsmith import traceable
except ImportError:
    def traceable(*args, **kwargs):
        def decorator(func):
            return func
        return decorator

try:
    import logfire
except ImportError:
    logfire = None

try:
    from ecologits import EcoLogits
except ImportError:
    EcoLogits = None

# Module-level flag to avoid re-initializing EcoLogits on every LLMClient instantiation
_ecologits_initialized = False
_logfire_configured = False
_cached_service_version = None


def _get_service_version() -> str:
    """Resolve the repository's git HEAD commit hash purely via filesystem reads
    (never spawning `git rev-parse HEAD` via subprocess).

    CRITICAL on Windows: When running inside the persistent daemon (`gui_backend.py serve`),
    stdin/stdout/stderr are inherited pipes (fd 0/1/2 marked inheritable for torch.multiprocessing).
    Calling `logfire.configure()` without an explicit `service_version` causes Logfire to invoke
    `subprocess.check_output(['git', 'rev-parse', 'HEAD'])`, which on Windows inherits stdin or
    deadlocks on git pack/index locks and hangs the first LLM request indefinitely.
    """
    global _cached_service_version
    if _cached_service_version is not None:
        return _cached_service_version

    import os
    from pathlib import Path

    try:
        cur = Path(__file__).resolve().parent
        for parent in (cur, *cur.parents):
            git_dir = parent / ".git"
            if git_dir.is_file():
                raw = git_dir.read_text(encoding="utf-8", errors="ignore").strip()
                if raw.startswith("gitdir:"):
                    rel = raw.split(":", 1)[1].strip()
                    git_dir = (parent / rel).resolve()
            head_file = git_dir / "HEAD"
            if head_file.is_file():
                head = head_file.read_text(encoding="utf-8", errors="ignore").strip()
                if head.startswith("ref:"):
                    ref_rel = head.split(":", 1)[1].strip()
                    ref_file = git_dir / ref_rel
                    if ref_file.is_file():
                        _cached_service_version = ref_file.read_text(encoding="utf-8", errors="ignore").strip()
                        return _cached_service_version
                    packed = git_dir / "packed-refs"
                    if packed.is_file():
                        for line in packed.read_text(encoding="utf-8", errors="ignore").splitlines():
                            if not line or line.startswith("#") or line.startswith("^"):
                                continue
                            parts = line.split()
                            if len(parts) >= 2 and parts[1] == ref_rel:
                                _cached_service_version = parts[0]
                                return _cached_service_version
                elif len(head) >= 7:
                    _cached_service_version = head
                    return _cached_service_version
    except Exception:
        pass

    _cached_service_version = os.environ.get("LOGFIRE_SERVICE_VERSION", "dev")
    return _cached_service_version


# Ensure LANGCHAIN_REVISION_ID is pre-populated in os.environ and patch langsmith's
# git subprocess helper so `@traceable` NEVER spawns `git describe --tags --always --dirty`
# via `subprocess.check_output` (which deadlocks on Windows inside the persistent daemon
# because fd 0/1/2 are marked inheritable for torch.multiprocessing).
try:
    import os as _os
    _rev = _get_service_version()
    _os.environ.setdefault("LANGCHAIN_REVISION_ID", _rev)
    import langsmith.env._git as _ls_git
    _ls_git.exec_git = lambda command: _rev
except Exception:
    pass


def _extract_impact_value(impact_field):
    """Extract a scalar float from an EcoLogits impact field.
    
    EcoLogits v0.10+ returns RangeValue(min, max) objects for some providers
    instead of plain floats. This helper extracts a usable scalar by
    averaging min/max when a range is returned.
    """
    if impact_field is None:
        return 0.0
    # If it's a structured impact object (Energy, GWP, etc.), get its .value
    val = getattr(impact_field, 'value', impact_field)
    # If it's a RangeValue, average min and max
    if hasattr(val, 'min') and hasattr(val, 'max'):
        min_v = val.min or 0.0
        max_v = val.max or 0.0
        return (min_v + max_v) / 2.0
    # Plain float
    try:
        return float(val)
    except (TypeError, ValueError):
        return 0.0


def strip_code_fences(raw_text):
    """Remove markdown code fences from LLM output.
    
    Handles ```supercollider, ```sc, ```sclang, and bare ``` fences.
    Logs a warning if stripping produces empty output from non-empty input.
    """
    import re
    # Remove opening fences with optional language tag
    text = re.sub(r'```(?:supercollider|sclang|sc)?\s*\n?', '', raw_text)
    text = text.strip()
    if not text and raw_text.strip():
        print(f"WARNING: code fence stripping produced empty output from {len(raw_text)}-char input", flush=True)
        print(f"  Raw input (first 200 chars): {raw_text[:200]}", flush=True)
        # Fallback: return the raw text commented out so it's not totally lost
        fallback = "\n".join(f"// {line}" for line in raw_text.splitlines())
        return f"// WARNING: No code block found in LLM response.\n{fallback}"
    return text


class RequestCancelledError(Exception):
    """Raised when an active LLM request is cancelled by the user."""


class LLMClient:
    def __init__(self, provider=None, model_name=None, cancel_event=None):
        global _ecologits_initialized, _logfire_configured

        self.provider = provider or config.CURRENT_LLM_PROVIDER
        self.model_name = model_name or config.CURRENT_MODEL_NAME
        self.cancel_event = cancel_event

        # Initialize Logfire (once) — pass explicit service_version so Logfire never spawns
        # a blocking `git rev-parse HEAD` subprocess inside the persistent daemon.
        if logfire and not _logfire_configured:
            try:
                logfire.configure(
                    service_name="sc-ai-assist",
                    service_version=_get_service_version(),
                    send_to_logfire="if-token-present",
                )
            except Exception as e:
                print(f"  ⚠ Logfire init skipped ({e}).", flush=True)
            _logfire_configured = True
        
        # Initialize EcoLogits with explicit provider list (once)
        if EcoLogits and not _ecologits_initialized:
            try:
                EcoLogits.init(providers=["google_genai", "anthropic"])
            except Exception as e:
                print(f"  ⚠ EcoLogits init failed ({e}), environmental metrics will use fallback estimates.")
            _ecologits_initialized = True

        if self.provider == "gemini":
            if not config.GEMINI_API_KEY:
                raise ValueError("Gemini API key missing. Configure it via the API Keys button.")
            if not genai:
                raise ValueError("The 'google-genai' python package is required. pip install google-genai")
            self.gemini_client = genai.Client(api_key=config.GEMINI_API_KEY)

        elif self.provider == "openai":
            if not config.OPENAI_API_KEY:
                raise ValueError("OpenAI API key missing. Configure it via the API Keys button.")
            if not OpenAI:
                raise ValueError("The 'openai' python package is required. pip install openai")
            self.openai_client = OpenAI(api_key=config.OPENAI_API_KEY)

        elif self.provider == "openrouter":
            if not config.OPENROUTER_API_KEY:
                raise ValueError("OpenRouter API key missing. Configure it via the API Keys button.")
            if not OpenAI:
                raise ValueError("The 'openai' python package is required. pip install openai")
            self.openai_client = OpenAI(
                api_key=config.OPENROUTER_API_KEY,
                base_url="https://openrouter.ai/api/v1",
                timeout=120.0,
                max_retries=0,
                default_headers={
                    "HTTP-Referer": "https://github.com/brugazoni/supercollider-AI-assist",
                    "X-Title": "SuperCollider AI Assist",
                }
            )

        elif self.provider == "anthropic":
            if not config.ANTHROPIC_API_KEY:
                raise ValueError("Anthropic API key missing. Configure it via the API Keys button.")
            if not anthropic:
                raise ValueError("The 'anthropic' python package is required. pip install anthropic")
            self.anthropic_client = anthropic.Anthropic(api_key=config.ANTHROPIC_API_KEY)

    def cancel(self):
        """Abort any in-flight HTTP request for this client."""
        if self.cancel_event is not None:
            self.cancel_event.set()
        for attr in ("openai_client", "gemini_client", "anthropic_client"):
            sdk_client = getattr(self, attr, None)
            if sdk_client is not None and hasattr(sdk_client, "close"):
                try:
                    sdk_client.close()
                except Exception:
                    pass

    @traceable(name="LLM_Generate", run_type="llm")
    def generate(self, prompt, system_instruction=None, temperature=0.7, thinking_budget=0, cancel_event=None):
        import time
        active_cancel = cancel_event if cancel_event is not None else self.cancel_event
        if active_cancel is not None and active_cancel.is_set():
            raise RequestCancelledError("Request cancelled")

        start_time = time.time()
        
        # Logfire span for deep tracing
        span_context = logfire.span(f"LLM Generate: {self.provider}/{self.model_name}") if logfire else None
        
        # Placeholder for EcoLogits impact data
        impact_data = {}
        environmental_flag = "Measured"

        try:
            if span_context:
                with span_context:
                    text, in_tok, out_tok, response_obj = self._generate_with_provider(prompt, system_instruction, temperature, thinking_budget)
            else:
                text, in_tok, out_tok, response_obj = self._generate_with_provider(prompt, system_instruction, temperature, thinking_budget)

            if active_cancel is not None and active_cancel.is_set():
                raise RequestCancelledError("Request cancelled")
            
            # Extract EcoLogits impact if available
            impacts = getattr(response_obj, 'impacts', None)
            if impacts is not None:
                impact_data = {
                    "energy_kwh": _extract_impact_value(getattr(impacts, 'energy', None)),
                    "gwp_kg": _extract_impact_value(getattr(impacts, 'gwp', None)),
                    "adpe_kg": _extract_impact_value(getattr(impacts, 'adpe', None)),
                    "pe_mj": _extract_impact_value(getattr(impacts, 'pe', None)),
                    "wcf_m3": _extract_impact_value(getattr(impacts, 'wcf', None)),
                }
                # Check if we actually got non-zero values
                if all(v == 0.0 for v in impact_data.values()):
                    environmental_flag = "Estimated (EcoLogits returned zero for this model)"
                    total_t = in_tok + out_tok
                    impact_data = {
                        "energy_kwh": (total_t / 1000.0) * 0.001,
                        "gwp_kg": (total_t / 1000.0) * 0.0005,
                        "adpe_kg": 0.0,
                        "pe_mj": 0.0,
                        "wcf_m3": 0.0
                    }
            else:
                # Fallback estimation for missing impact
                environmental_flag = "Estimated (Model output lacked native impact metadata)"
                total_t = in_tok + out_tok
                impact_data = {
                    "energy_kwh": (total_t / 1000.0) * 0.001,
                    "gwp_kg": (total_t / 1000.0) * 0.0005,
                    "adpe_kg": 0.0,
                    "pe_mj": 0.0,
                    "wcf_m3": 0.0
                }

        except RequestCancelledError:
            raise
        except Exception as e:
            if active_cancel is not None and active_cancel.is_set():
                raise RequestCancelledError("Request cancelled") from e
            text = f"// API error: {str(e)}"
            in_tok = 0
            out_tok = 0
            response_obj = None

        latency = time.time() - start_time
        
        # Cost calculation - Fallback to local config pricing (supporting vendor/model or bare model keys)
        bare_model = self.model_name.split("/")[-1] if "/" in self.model_name else self.model_name
        pricing = (
            config.PRICING_PER_1M_TOKENS.get(self.model_name)
            or config.PRICING_PER_1M_TOKENS.get(bare_model)
            or {"in": 0.0, "out": 0.0}
        )
        cost = (in_tok / 1_000_000.0) * max(0.0, pricing["in"]) + (out_tok / 1_000_000.0) * max(0.0, pricing["out"])
        if cost == 0.0 and response_obj is not None:
            usage_obj = getattr(response_obj, "usage", None)
            native_cost = getattr(usage_obj, "cost", None) if usage_obj is not None else None
            if native_cost is not None:
                try:
                    cost = float(native_cost)
                except (TypeError, ValueError):
                    pass

        # Context Window metrics - Pull from config.py (supporting vendor/model or bare model keys)
        ctx_limit = (
            config.CONTEXT_WINDOW_SIZES.get(self.model_name)
            or config.CONTEXT_WINDOW_SIZES.get(bare_model)
            or 32000
        )
        ctx_usage_pct = ((in_tok + out_tok) / ctx_limit) * 100.0 if ctx_limit > 0 else 0

        stats_dict = {
            "in_tokens": in_tok,
            "out_tokens": out_tok,
            "time_s": round(latency, 2),
            "cost": round(cost, 5),
            "cost_fb": True,
            "context_limit": ctx_limit,
            "context_fb": True,
            "context_usage_pct": round(ctx_usage_pct, 2),
            "environmental_estimated_flag": environmental_flag,
            "eco_fb": (environmental_flag != "Measured"),
            "temperature": temperature,
            **impact_data
        }
        
        # Inject metadata into the active LangSmith trace if enabled
        try:
            from langsmith import run_helpers
            rt = run_helpers.get_current_run_tree()
            if rt:
                rt.add_metadata({
                    "provider": self.provider,
                    "model_name": self.model_name,
                    "cost_usd": stats_dict["cost"],
                    "energy_kwh": stats_dict.get("energy_kwh", 0),
                    "ctx_usage_pct": stats_dict["context_usage_pct"]
                })
        except Exception: pass
            
        return text, stats_dict

    def _generate_with_provider(self, prompt, system_instruction, temperature=0.7, thinking_budget=0):
        """Internal router that also returns the raw response object for impact metadata extraction."""
        if self.provider == "gemini":
            return self._generate_gemini(prompt, system_instruction, temperature, thinking_budget)
        elif self.provider == "openai":
            return self._generate_openai(prompt, system_instruction, temperature, thinking_budget)
        elif self.provider == "anthropic":
            return self._generate_anthropic(prompt, system_instruction, temperature, thinking_budget)
        elif self.provider == "openrouter":
            return self._generate_openai(prompt, system_instruction, temperature, thinking_budget)
        else:
            raise ValueError(f"unknown provider: {self.provider}")

    def _generate_gemini(self, prompt, system_instruction, temperature=0.7, thinking_budget=0):
        config_obj = genai_types.GenerateContentConfig(
            temperature=temperature,
        )
        if system_instruction:
            config_obj.system_instruction = system_instruction
        if hasattr(genai_types, "ThinkingConfig"):
            try:
                config_obj.thinking_config = genai_types.ThinkingConfig(
                    thinking_budget=max(0, int(thinking_budget))
                )
            except Exception:
                pass

        response = self.gemini_client.models.generate_content(
            model=self.model_name,
            contents=prompt,
            config=config_obj
        )
        usage = response.usage_metadata
        
        raw_text = ""
        try:
            raw_text = response.text
        except ValueError:
            # Handle cases where response.text throws an exception (e.g. safety blocks)
            pass
            
        if not raw_text and hasattr(response, 'candidates') and response.candidates:
            cand = response.candidates[0]
            finish_reason = getattr(cand, 'finish_reason', None)
            if finish_reason and finish_reason.name != "STOP":
                raw_text = f"// API Error: Generation blocked by Google (Reason: {finish_reason.name})"
                
        if not raw_text:
            raw_text = "// API Error: Model returned an empty response (possible silent safety block)."

        text = strip_code_fences(raw_text)
        return text, usage.prompt_token_count, usage.candidates_token_count, response

    def _generate_openai(self, prompt, system_instruction, temperature=0.7, thinking_budget=0):
        messages = []
        if system_instruction:
            messages.append({'role': 'system', 'content': system_instruction})
        messages.append({'role': 'user', 'content': prompt})

        kwargs = {
            "model": self.model_name,
            "messages": messages,
            "temperature": temperature,
            "timeout": 120.0,
        }
        if self.provider == "openrouter":
            if thinking_budget and int(thinking_budget) > 0:
                kwargs["extra_body"] = {"reasoning": {"max_tokens": int(thinking_budget)}}
            else:
                kwargs["extra_body"] = {"reasoning": {"effort": "low"}}

        try:
            response = self.openai_client.chat.completions.create(**kwargs)
        except Exception as exc:
            status_code = getattr(exc, "status_code", None)
            if "extra_body" in kwargs and status_code == 400:
                kwargs.pop("extra_body", None)
                response = self.openai_client.chat.completions.create(**kwargs)
            else:
                raise
        text = strip_code_fences(response.choices[0].message.content)
        return text, response.usage.prompt_tokens, response.usage.completion_tokens, response

    def _generate_anthropic(self, prompt, system_instruction, temperature=0.7, thinking_budget=0):
        kwargs = {
            "model": self.model_name,
            "max_tokens": 4096,
            "messages": [{"role": "user", "content": prompt}]
        }
        
        if thinking_budget > 0:
            kwargs["thinking"] = { "type": "enabled", "budget_tokens": thinking_budget }
            kwargs["temperature"] = 1.0 # Anthropic requires temperature=1.0 when thinking is enabled
            # max_tokens must safely exceed thinking budget block
            kwargs["max_tokens"] = max(kwargs["max_tokens"], thinking_budget + 1024)
        else:
            kwargs["temperature"] = temperature
            
        if system_instruction:
            kwargs["system"] = [
                {
                    "type": "text",
                    "text": system_instruction,
                    "cache_control": {"type": "ephemeral"}
                }
            ]
        response = self.anthropic_client.messages.create(**kwargs)
        
        # In Anthropic with thinking enabled, content block is a list: first text is 'thinking', second text is final text
        final_text = ""
        for block in response.content:
            if block.type == "text":
                final_text = block.text
                
        text = strip_code_fences(final_text)
        return text, response.usage.input_tokens, response.usage.output_tokens, response
