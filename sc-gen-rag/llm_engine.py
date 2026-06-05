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


class LLMClient:
    def __init__(self, provider=None, model_name=None):
        global _ecologits_initialized, _logfire_configured

        self.provider = provider or config.CURRENT_LLM_PROVIDER
        self.model_name = model_name or config.CURRENT_MODEL_NAME

        # Initialize Logfire (once)
        if logfire and not _logfire_configured:
            logfire.configure(project_name="sc-ai-assist")
            _logfire_configured = True
        
        # Initialize EcoLogits with explicit provider list (once)
        if EcoLogits and not _ecologits_initialized:
            try:
                EcoLogits.init(providers=["google_genai", "openai", "anthropic"])
            except Exception as e:
                print(f"  ⚠ EcoLogits init failed ({e}), environmental metrics will use fallback estimates.")
            _ecologits_initialized = True

        if self.provider == "gemini":
            if not config.GEMINI_API_KEY:
                print("Gemini API key missing")
                sys.exit(1)
            if not genai:
                print("The 'google-genai' python package is required. pip install google-genai")
                sys.exit(1)
            self.gemini_client = genai.Client(api_key=config.GEMINI_API_KEY)

        elif self.provider == "openai":
            if not config.OPENAI_API_KEY:
                print("OpenAI API key missing")
                sys.exit(1)
            if not OpenAI:
                print("The 'openai' python package is required. pip install openai")
                sys.exit(1)
            self.openai_client = OpenAI(api_key=config.OPENAI_API_KEY)

        elif self.provider == "anthropic":
            if not config.ANTHROPIC_API_KEY:
                print("Anthropic API key missing")
                sys.exit(1)
            if not anthropic:
                print("The 'anthropic' python package is required. pip install anthropic")
                sys.exit(1)
            self.anthropic_client = anthropic.Anthropic(api_key=config.ANTHROPIC_API_KEY)

    @traceable(name="LLM_Generate", run_type="llm")
    def generate(self, prompt, system_instruction=None, temperature=0.7, thinking_budget=0):
        import time
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

        except Exception as e:
            text = f"// API error: {str(e)}"
            in_tok = 0
            out_tok = 0
            response_obj = None

        latency = time.time() - start_time
        
        # Cost calculation - Always FB (Fallback) as we use local config pricing
        pricing = config.PRICING_PER_1M_TOKENS.get(self.model_name, {"in": 0.0, "out": 0.0})
        cost = (in_tok / 1_000_000.0) * pricing["in"] + (out_tok / 1_000_000.0) * pricing["out"]

        # Context Window metrics - Always FB as we pull from config.py
        ctx_limit = config.CONTEXT_WINDOW_SIZES.get(self.model_name, 32000)
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
            return self._generate_gemini(prompt, system_instruction, temperature)
        elif self.provider == "openai":
            return self._generate_openai(prompt, system_instruction, temperature)
        elif self.provider == "anthropic":
            return self._generate_anthropic(prompt, system_instruction, temperature, thinking_budget)
        else:
            raise ValueError(f"unknown provider: {self.provider}")

    def _generate_gemini(self, prompt, system_instruction, temperature=0.7):
        config_obj = genai_types.GenerateContentConfig(
            temperature=temperature,
        )
        if system_instruction:
            config_obj.system_instruction = system_instruction

        response = self.gemini_client.models.generate_content(
            model=self.model_name,
            contents=prompt,
            config=config_obj
        )
        usage = response.usage_metadata
        text = response.text.replace("```supercollider", "").replace("```", "").strip()
        return text, usage.prompt_token_count, usage.candidates_token_count, response

    def _generate_openai(self, prompt, system_instruction, temperature=0.7):
        messages = []
        if system_instruction:
            messages.append({'role': 'system', 'content': system_instruction})
        messages.append({'role': 'user', 'content': prompt})

        response = self.openai_client.chat.completions.create(
            model=self.model_name,
            messages=messages,
            temperature=temperature
        )
        text = response.choices[0].message.content.replace("```supercollider", "").replace("```", "").strip()
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
            kwargs["system"] = system_instruction
            
        response = self.anthropic_client.messages.create(**kwargs)
        
        # In Anthropic with thinking enabled, content block is a list: first text is 'thinking', second text is final text
        final_text = ""
        for block in response.content:
            if block.type == "text":
                final_text = block.text
                
        text = final_text.replace("```supercollider", "").replace("```", "").strip()
        return text, response.usage.input_tokens, response.usage.output_tokens, response
