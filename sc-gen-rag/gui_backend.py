#!/usr/bin/env python3
"""
gui_backend.py — Unified CLI entry point for the SuperCollider AI Assist UI.

Called by the C++ IDE via QProcess:
    python gui_backend.py <command> <json_input_file>

Returns JSON on stdout. Logs all interactions to session_log.md.
"""

import sys
import os
import traceback

# Suppress HuggingFace Hub symlink warnings on Windows without Developer Mode.
# This ensures the cache system falls back to copies instead of crashing with
# OSError [WinError 1314] when symlink privileges are not available.
os.environ.setdefault("HF_HUB_DISABLE_SYMLINKS_WARNING", "1")

def log_crash(type, value, tb):
    with open("c:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/child_crash.log", "a") as f:
        f.write(f"CRASH IN PID {os.getpid()}:\n")
        traceback.print_exception(type, value, tb, file=f)
sys.excepthook = log_crash

# CRITICAL FIX for torch.multiprocessing on Windows:
# When torch.multiprocessing spawns a child process using the system python.exe,
# it must be able to import the venv's site-packages BEFORE unpickling the target function.
# Inserting the venv site-packages at the absolute top of the main module ensures that
# when spawn_main calls runpy.run_path, sys.path is immediately patched in the child process.
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SCRIPT_DIR = _SCRIPT_DIR
import multiprocessing
# Removed overriding sys.executable to avoid breaking multiprocessing venv detection

_venv_site_packages = os.path.join(_SCRIPT_DIR, ".venv", "Lib", "site-packages")
with open("c:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/gui_backend_env.log", "w") as f:
    for k, v in os.environ.items(): f.write(f"{k}={v}\n")
if _venv_site_packages not in sys.path:
    sys.path.insert(0, _venv_site_packages)

with open("mp_child_debug_startup.log", "a", encoding="utf-8") as f: f.write(f"PID {os.getpid()} BEFORE IMPORTS\n")

import io
import json
import traceback
import threading
import queue
import datetime

with open("mp_child_debug_startup.log", "a", encoding="utf-8") as f: f.write(f"PID {os.getpid()} AFTER STANDARD IMPORTS\n")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(SCRIPT_DIR)

import multiprocessing.spawn

# CRITICAL FIX for multiprocessing on Windows with scripts running as __main__:
# When Python runs a script directly, sys.modules['__main__'].__spec__ is set.
# This causes multiprocessing to use init_main_from_name='__main__' instead of init_main_from_path.
# This breaks child processes because they will import '-c' as __main__ and skip this script entirely!
if hasattr(sys.modules.get('__main__'), '__spec__'):
    sys.modules['__main__'].__spec__ = None

with open("mp_child_debug_startup.log", "a", encoding="utf-8") as f: f.write(f"PID {os.getpid()} BEFORE MODULE LOG\n")

# DEBUG: Write unconditionally on every import of this module
try:
    with open("module_import_debug.log", "a", encoding="utf-8") as _f:
        _mp_name = multiprocessing.current_process().name
        _inheriting = getattr(multiprocessing.process.current_process(), '_inheriting', False)
        _f.write(f"PID: {os.getpid()}, Name: {_mp_name}, __name__: {__name__}, _inheriting: {_inheriting}, argv: {sys.argv}\n")
except Exception:
    pass

if getattr(multiprocessing.process.current_process(), '_inheriting', False) or __name__ == "__mp_main__":
    with open("mp_child_debug_startup.log", "a", encoding="utf-8") as f:
        f.write("Child process successfully started run_path!\n")
    log_file = open("mp_child_debug.log", "a", encoding="utf-8", buffering=1)
    sys.stdout = log_file
    sys.stderr = log_file

import config
import utils

# Lazy imports for heavy dependencies (rag_engine, llm_engine)
# These are imported inside the functions that need them
# to avoid blocking simple commands like list_models

# Daemon-mode composition state cache (thread-safe via GIL for simple dict ops)
_composition_states = {}  # active_file -> latest composition state
_composition_state_events = {}  # active_file -> threading.Event (signals when bg state update is done)
_design_ran_in_session = {}  # active_file -> bool (tracks whether a design block has already run)

# Daemon-mode stdout reference — set by serve(), used by dictation thread
# to stream unsolicited JSON lines (partials/finals) back to the C++ side.
_daemon_stdout = None
_daemon_stdout_lock = threading.Lock()

# Daemon-mode per-request cancellation tracking
_tls = threading.local()
_active_requests = {}  # job_id -> _CancellationContext
_active_requests_lock = threading.Lock()
_active_job_seq = 0


class _CancellationContext:
    """Tracks cancellation state and active HTTP/LLM clients for one daemon request."""

    def __init__(self, job_id, request_id=None):
        self.job_id = job_id
        self.request_id = request_id
        self.cancel_event = threading.Event()
        self._lock = threading.Lock()
        self._clients = []

    def register_client(self, client):
        with self._lock:
            if self.cancel_event.is_set():
                self._abort_client(client)
                from llm_engine import RequestCancelledError
                raise RequestCancelledError("Request cancelled")
            self._clients.append(client)

    @staticmethod
    def _abort_client(client):
        if hasattr(client, "cancel"):
            try:
                client.cancel()
            except Exception:
                pass
        else:
            for attr in ("openai_client", "gemini_client", "anthropic_client"):
                sdk = getattr(client, attr, None)
                if sdk is not None and hasattr(sdk, "close"):
                    try:
                        sdk.close()
                    except Exception:
                        pass

    def cancel(self):
        self.cancel_event.set()
        with self._lock:
            clients = list(self._clients)
        for client in clients:
            self._abort_client(client)


def _get_current_cancel_ctx():
    return getattr(_tls, "cancel_ctx", None)


def _check_cancelled():
    ctx = _get_current_cancel_ctx()
    if ctx is not None and ctx.cancel_event.is_set():
        from llm_engine import RequestCancelledError
        raise RequestCancelledError("Request cancelled")


def _wait_event_cancellable(evt, timeout=30.0):
    """Wait on a threading.Event while waking up promptly if the current request is cancelled."""
    import time
    ctx = _get_current_cancel_ctx()
    if ctx is None:
        evt.wait(timeout=timeout)
        return
    deadline = time.monotonic() + timeout
    while not evt.is_set():
        _check_cancelled()
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            break
        evt.wait(timeout=min(0.1, remaining))
    _check_cancelled()


def _make_llm_client(provider, model_name):
    """Instantiate LLMClient and bind it to the current request's CancellationContext."""
    from llm_engine import LLMClient
    _check_cancelled()
    ctx = _get_current_cancel_ctx()
    cancel_event = ctx.cancel_event if ctx is not None else None
    try:
        client = LLMClient(provider=provider, model_name=model_name, cancel_event=cancel_event)
    except TypeError:
        client = LLMClient(provider=provider, model_name=model_name)
    if ctx is not None:
        ctx.register_client(client)
    return client


def _cancel_active_requests(request_id=None):
    """Cancel matching active daemon request(s). Returns True if at least one matched."""
    with _active_requests_lock:
        targets = [
            ctx for ctx in _active_requests.values()
            if request_id is None or ctx.request_id == request_id
        ]
    for ctx in targets:
        ctx.cancel()
    return len(targets) > 0


def _run_with_parallel_fallback(fallback_fn, fallback_args, work_fn):
    """Run work_fn() concurrently with fallback_fn(*fallback_args) without blocking on fallback if cancelled."""
    import concurrent.futures
    executor = concurrent.futures.ThreadPoolExecutor(max_workers=1)
    fallback_future = executor.submit(fallback_fn, *fallback_args)
    try:
        work_result = work_fn()
        _check_cancelled()
        fallback_result = fallback_future.result()
        return work_result, fallback_result
    finally:
        executor.shutdown(wait=False, cancel_futures=True)

# Dictation state
_dictation_recorder = None
_dictation_thread = None
_dictation_active = False  # guards against race between start/stop during model load
_dictation_muted = False   # skips transcription final output when muted
_dictation_session_id = 0  # incremented on each start; prevents stale callbacks

# Pre-loaded dictation recorder (created at startup, reused across sessions)
_preloaded_recorder = None
_preloaded_recorder_model = None
_preloaded_recorder_lang = None


def _resolve_model(model_key):
    """Resolve a model key like 'gemini/gemini-3.8-flash' to (provider, model_name)."""
    print(f"[DEBUG _resolve_model] model_key={model_key!r}", flush=True)
    if not model_key:
        return config.CURRENT_LLM_PROVIDER, config.CURRENT_MODEL_NAME
    entry = config.AVAILABLE_MODELS.get(model_key)
    if entry:
        return entry["provider"], entry["model"]
        
    # OpenRouter models: key prefixed with openrouter: or openrouter/
    if model_key.startswith("openrouter:"):
        return "openrouter", model_key[11:]
    if model_key.startswith("openrouter/"):
        return "openrouter", model_key[11:]

    # Fallback: try to split on /
    parts = model_key.split("/", 1)
    if len(parts) == 2:
        return parts[0], parts[1]
    return config.CURRENT_LLM_PROVIDER, config.CURRENT_MODEL_NAME


def _load_system_instruction_file(filepath):
    """Load a system instruction file, returning its contents or empty string."""
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read().strip()
    return ""


DEFAULT_SYS_MSGS_BY_KEY = {
    "append": ["append/system-instruction-incremental-v3.md"],
    "compose_plan": ["compose/plan-v5.md"],
    "compose_code": ["compose/implement-v3.md", "improvements/sys-improvements-v2.md"],
    "design_plan": ["design/system-instruction-oneshot-plan-design-v2.md"],
    "design_code": ["design/system-instruction-oneshot-gen-design-v2.md", "fix/system-instruction-fix.md"],
    "gen_plan": ["base/system-instruction.md", "generate/system-instruction-oneshot-plan.md"],
    "gen_code": ["base/system-instruction.md", "improvements/system-improvements.md", "generate/system-instruction-oneshot-gen.md"],
    "fix": ["fix/system-instruction-fix.md"],
    "remake": ["base/system-instruction.md", "improvements/system-improvements.md", "remake/system-instruction-remake.md"],
    "learn": ["base/system-instruction.md", "learn/system-instruction-learn.md"],
}


def _get_default_sys_msgs(key):
    """Return configured default system message relative paths for a given key
    (reading sys_msgs_defaults.json if present, otherwise DEFAULT_SYS_MSGS_BY_KEY)."""
    defaults_path = os.path.join(SCRIPT_DIR, "sys_msgs_defaults.json")
    if os.path.exists(defaults_path):
        try:
            with open(defaults_path, "r", encoding="utf-8") as f:
                cfg = json.load(f)
            msgs = cfg.get(key)
            if isinstance(msgs, list) and msgs:
                return list(msgs)
        except Exception:
            pass
    return list(DEFAULT_SYS_MSGS_BY_KEY.get(key, []))


def _build_system_prompt(data, default_key=None):
    """Build a system prompt from an explicit list of system message file paths.
    
    Reads the 'sys_msgs' key from data (a list of relative paths under system_messages/),
    falling back to _get_default_sys_msgs(default_key) if 'sys_msgs' is missing or empty,
    loads each file, and concatenates them with separator markers.
    This replaces the old _get_base_system_instruction() and hidden improvements injection.
    """
    venv_python = os.path.join(SCRIPT_DIR, ".venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        sys.executable = venv_python
        sys._base_executable = venv_python
        multiprocessing.set_executable(venv_python)
    sys_msgs = data.get("sys_msgs") or ([] if not default_key else _get_default_sys_msgs(default_key))
    base_dir = os.path.join(SCRIPT_DIR, "system_messages")
    
    blocks = []
    for relative_path in sys_msgs:
        abs_path = os.path.join(base_dir, relative_path)
        if os.path.exists(abs_path):
            try:
                with open(abs_path, 'r', encoding='utf-8') as f:
                    content = f.read().strip()
                    if content:
                        blocks.append(content)
            except Exception as e:
                print(f"Error reading {abs_path}: {e}", flush=True)
    
    return "\n\n=== ADDITIONAL INSTRUCTION ===\n\n".join(blocks)


def _read_scd(filepath):
    """Read current contents of the targeted .scd file.
    If no filepath is given (unsaved doc), returns empty string.
    """
    target = filepath if filepath else None
    if target and os.path.exists(target):
        with open(target, 'r', encoding='utf-8') as f:
            return f.read()
    return ""


def _write_scd(content, filepath, mode='w'):
    """Write or append to the targeted .scd file.
    If filepath is empty (unsaved doc), skip — the C++ IDE handles buffer insertion.
    """
    target = filepath if filepath else None
    if not target: return
    os.makedirs(os.path.dirname(os.path.abspath(target)), exist_ok=True)
    with open(target, mode, encoding='utf-8') as f:
        f.write(content)


def cmd_list_models(data):
    """Return all available models."""
    models = list(config.AVAILABLE_MODELS.keys())
    return {"models": models, "models_info": config.AVAILABLE_MODELS}


def cmd_list_openrouter_models(data):
    """Fetch available models from OpenRouter's API."""
    import urllib.request
    import json as json_mod
    
    if not config.OPENROUTER_API_KEY:
        return {"error": "OPENROUTER_API_KEY not configured", "models": []}
    
    try:
        _check_cancelled()
        req = urllib.request.Request(
            "https://openrouter.ai/api/v1/models",
            headers={"Authorization": f"Bearer {config.OPENROUTER_API_KEY}"}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            raw = json_mod.loads(resp.read().decode())
        _check_cancelled()
    except Exception as e:
        from llm_engine import RequestCancelledError
        if isinstance(e, RequestCancelledError):
            raise
        return {"error": str(e), "models": []}
    
    models = []
    for m in raw.get("data", []):
        output_modalities = m.get("architecture", {}).get("output_modalities", [])
        if output_modalities and "text" not in output_modalities:
            continue
        if ":batch" in m.get("id", ""):
            continue
            
        pricing = m.get("pricing", {})
        prompt_raw = float(pricing.get("prompt", 0))
        completion_raw = float(pricing.get("completion", 0))
        prompt_price = -1.0 if prompt_raw < 0 else prompt_raw * 1_000_000
        completion_price = -1.0 if completion_raw < 0 else completion_raw * 1_000_000
        
        model_id = m["id"]
        config.PRICING_PER_1M_TOKENS[model_id] = {"in": prompt_price, "out": completion_price}
        config.CONTEXT_WINDOW_SIZES[model_id] = m.get("context_length", 0)
        
        models.append({
            "id": model_id,
            "name": m.get("name", model_id),
            "context_length": m.get("context_length", 0),
            "price_in": round(prompt_price, 3),
            "price_out": round(completion_price, 3),
            "default_temp": 0.7,
            "max_temp": 2.0,
        })
    
    return {"models": models}


def _build_plan_user_prompt(prompt, mode="generate", include_ending=True, is_cross_append=False, composition_state=""):
    """Construct the complete user prompt + subtext for plan generation."""
    if mode == "design":
        ending_instruction = "The design plan should configure an external synthesize patch."
    elif mode == "compose":
        if is_cross_append:
            ending_instruction = (
                "The composition runs in a shared X-Append session alongside other active instruments on the server. "
                "At the end of the fixed-length timeline, ONLY fade out and stop/clear the specific Pbindefs, Ndefs, and Tdef created within this piece itself. "
                "CRITICAL: NEVER plan global server-wide termination or wipe commands (`Ndef.clear`, `Pbindef.removeAll`, `Pbindef.all`, `Tdef.removeAll`, `Tdef.all`, `ServerTree.removeAll`, `s.freeAll`, `s.quit`), and do NOT silence the rest of the server. Use absolute timestamps throughout."
            )
        else:
            ending_instruction = "The composition MUST include an explicit ending where all Tdefs conclude, all Ndefs are cleared with a long fade, and the server is left silent. Use absolute timestamps throughout."
    else:
        if include_ending:
            ending_instruction = "The composition plan MUST include an explicit ending or 'Outro' where all active instruments and sequences are cleanly faded out and stopped."
        else:
            ending_instruction = "The composition plan MUST NOT include an ending or Outro. The final section must remain actively looping and open-ended so it can be built upon later. Do NOT stop or clear the instruments at the end."

    comp_section = ""
    if is_cross_append or (composition_state and composition_state.strip() and composition_state.strip() != "(Empty)"):
        state_body = composition_state.strip() if (composition_state and composition_state.strip()) else "(Empty — this is the first block)"
        comp_section = (
            f"\n\n=== CURRENT COMPOSITION STATE ===\n{state_body}\n"
            f"(Avoid name collisions with existing Ndefs, Pbindefs, SynthDefs, Tdefs, and MIDIdefs; "
            f"reference existing active sources/buses programmatically if the request builds on them.)"
        )

    return f"User Request: {prompt}\n\nTask: Generate a composition plan proportional to the request's length. {ending_instruction}{comp_section}"


def _build_code_user_prompt(prompt, plan, mode="generate", active_file=None, include_ending=True, is_cross_append=False, composition_state=""):
    """Construct the complete user prompt + subtext for code generation from a plan."""
    prev_len = 4000 if is_cross_append else 800
    prev_content = _read_scd(active_file)[-prev_len:] if active_file and os.path.exists(active_file) else ""

    if mode == "design":
        if is_cross_append:
            ending_instruction = (
                "\nCRITICAL FOR AUTOMATED EXECUTION: Wrap the ENTIRE executable synthesizer setup "
                "(global config, MIDI setup, s.waitForBoot with SynthDefs, routing, MIDIdefs, and defer GUI creation) "
                "inside a SINGLE outer parenthesis block `( ... )` so it runs atomically in one evaluation. "
                "Do NOT emit an active Step 5 Cleanup block that closes the GUI or frees synths (if you include cleanup code, keep it completely commented out with `//`)."
            )
        else:
            ending_instruction = "\nEnsure the final block is a valid, runnable sequence defining the synthesizer logic properly."
    elif mode == "compose":
        if is_cross_append:
            ending_instruction = (
                "\nCRITICAL FOR X-APPEND SHARED SERVER: This composition runs alongside other active Ndefs, Pbindefs, and Synths on the server. "
                "When the Tdef timeline concludes, ONLY stop/clear the specific named Pbindefs (e.g. `Pbindef(\\mySeq).stop; Pbindef(\\mySeq).clear;`), "
                "specific named Ndefs (e.g. `Ndef(\\myTex).clear(2); Ndef(\\masterMix).clear(2);`), and specific Tdef (`Tdef(\\masterScore).stop;`) created in THIS script. "
                "NEVER call global server-wiping commands (`Ndef.clear`, `Pbindef.removeAll`, `Pbindef.all.do(_.stop)`, `Tdef.removeAll`, `Tdef.all.do(_.stop)`, `ServerTree.removeAll`, `s.freeAll`, or `s.quit`). "
                "Keep `~enableRecording = false;` and wrap the entire script in a SINGLE outer `( ... )` block."
            )
        else:
            ending_instruction = "\nThe Tdef script MUST conclude by stopping all Pbindefs, clearing all Ndefs with a long fade, and leaving the server silent. Include s.makeGui; at the end."
    else:
        if include_ending:
            ending_instruction = "\nEnsure the final block cleanly ends the piece according to the plan."
        else:
            ending_instruction = (
                "\nCRITICAL: Do not clear or free the Ndefs at the end. The generated code MUST remain running indefinitely. "
                + ("Wrap all active Ndef, effect, and Pbindef definitions into a SINGLE outer `( ... )` block." if is_cross_append else "")
            )

    comp_section = ""
    if is_cross_append or (composition_state and composition_state.strip() and composition_state.strip() != "(Empty)"):
        state_body = composition_state.strip() if (composition_state and composition_state.strip()) else "(Empty — this is the first block)"
        comp_section = f"\n\n=== CURRENT COMPOSITION STATE ===\n{state_body}"

    plan_section = f"\n\n=== APPROVED COMPOSITION PLAN ===\n{plan}" if plan else ""
    target_display = active_file if active_file else config.OUTPUT_FILE
    return (
        f"Context: Working in '{target_display}'.{comp_section}\n\nPrevious code:\n{prev_content}{plan_section}\n\n"
        f"Request: {prompt}\n"
        f"Output ONLY the valid SuperCollider code block executing the plan. {ending_instruction}"
    )


def cmd_generate_plan(data):
    """Generate a composition plan from a user prompt.
    
    Uses lean system prompt (no RAG, no improvements) since this is a
    planning/structural stage, not code generation.
    """
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    mode = data.get("mode", "generate")
    default_plan_key = f"{mode}_plan" if mode in ("compose", "design") else "gen_plan"
    # Build system prompt from explicit sys_msgs sent by the UI (falling back to mode defaults)
    full_sys = _build_system_prompt(data, default_key=default_plan_key)

    include_ending = data.get("include_ending", True)
    is_cross_append = data.get("is_cross_append", False)
    composition_state = data.get("composition_state", "")
    user_prompt = _build_plan_user_prompt(
        prompt,
        mode=mode,
        include_ending=include_ending,
        is_cross_append=is_cross_append,
        composition_state=composition_state,
    )

    print("Generating composition plan...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    plan, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)
    
    active_file = data.get("active_file")
    if not is_cross_append:
        utils.append_to_session_log("generate_plan", full_sys, user_prompt, plan, stats_dict, f"{provider}/{model_name}", active_file=active_file)

    return {
        "plan": plan,
        "last_stats": stats_dict,
        "system_prompt": full_sys,
        "user_prompt": user_prompt,
    }


def cmd_generate_code(data):
    """Generate code from an approved plan."""
    plan = data.get("plan", "")
    prompt = data.get("prompt", "")
    use_kb = data.get("use_kb", False)
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    mode = data.get("mode", "generate")
    default_code_key = f"{mode}_code" if mode in ("compose", "design") else "gen_code"
    # Build system prompt from explicit sys_msgs sent by the UI (falling back to mode defaults)
    full_sys = _build_system_prompt(data, default_key=default_code_key)

    # Optionally add RAG context
    if use_kb:
        try:
            print("Searching knowledge base...", flush=True)
            import rag_engine
            code_context = rag_engine.query_index(prompt, sources=["knowledge-base"])
            full_sys += f"\n\n=== Knowledge Base ===\n{code_context}"
        except Exception:
            pass
    _check_cancelled()

    active_file = data.get("active_file")
    include_ending = data.get("include_ending", True)
    is_cross_append = data.get("is_cross_append", False)
    composition_state = data.get("composition_state", "")
    user_prompt = _build_code_user_prompt(
        prompt,
        plan,
        mode=mode,
        active_file=active_file,
        include_ending=include_ending,
        is_cross_append=is_cross_append,
        composition_state=composition_state,
    )

    print("Generating SuperCollider code...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # inserts the code into the document via QTextCursor and handles saving.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher.

    if not is_cross_append:
        utils.append_to_session_log("generate_code", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {
        "code": code,
        "last_stats": stats_dict,
        "system_prompt": full_sys,
        "user_prompt": user_prompt,
    }


def cmd_custom_generate(data):
    """Generate code dynamically driven by explicitly selected system messages."""
    prompt = data.get("prompt", "")
    use_kb = data.get("use_kb", False)
    model_key = data.get("model", "")
    sys_msgs = data.get("sys_msgs", [])

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

    # Optionally add RAG context
    if use_kb:
        try:
            print("Searching knowledge base...", flush=True)
            import rag_engine
            code_context = rag_engine.query_index(prompt, sources=["knowledge-base"])
            if full_sys:
                full_sys += f"\n\n=== Knowledge Base ===\n{code_context}"
            else:
                full_sys = f"=== Knowledge Base ===\n{code_context}"
        except Exception:
            pass

    # Previous file content for context
    active_file = data.get("active_file")
    prev_content = _read_scd(active_file)[-800:] if active_file and os.path.exists(active_file) else ""

    target_display = active_file if active_file else config.OUTPUT_FILE
    user_prompt = (
        f"Context: Working in '{target_display}'. Previous code:\n{prev_content}\n\n"
        f"Request: {prompt}\n"
        f"Output ONLY the valid SuperCollider code block executing the prompt."
    )

    print("Generating SuperCollider code...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # inserts the code into the document via QTextCursor and handles saving.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher.

    utils.append_to_session_log("custom_generate", full_sys if full_sys else "N/A", user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "last_stats": stats_dict}



def _rag_failsafe_lookup(prompt, *args, **kwargs):
    """Perform a parallel lookup to find the best semantic RAG block for the given mode."""
    mode = args[0] if args else kwargs.get("mode", "append")
    try:
        import rag_engine
        import config
        import random
        docs = []
        mode_file = None
        if mode in ("append", "generate", "compose", "design"):
            candidate_file = os.path.join(config.CONTEXT_FOLDER, f"failsafe-{mode}.scd")
            if os.path.exists(candidate_file):
                mode_file = candidate_file
                try:
                    mode_retriever = rag_engine.get_retriever(mode_filter=mode)
                    docs = mode_retriever(prompt) or []
                except Exception:
                    docs = []

        if not docs:
            if mode == "design" and not mode_file:
                # Design falls back to _generate_design_subtractive_fallback when no design RAG exists
                return ""
            retriever = rag_engine.get_retriever()
            docs = retriever(prompt)
        if not docs:
            return ""

        def _extract_sections_from_scd(file_content: str) -> list[list[str]]:
            """Parse all delimiter-bounded sections and return each section's active () blocks."""
            blocks = []
            stack = []
            start_idx = -1
            for i, char in enumerate(file_content):
                if char == '(':
                    if not stack:
                        if i == 0 or file_content[i - 1] == '\n':
                            start_idx = i
                            stack.append(i)
                    else:
                        stack.append(i)
                elif char == ')':
                    if stack:
                        stack.pop()
                        if not stack:
                            blocks.append((start_idx, i))

            if not blocks:
                return []

            import re
            delimiter_pattern = re.compile(r'^(/{5,}|// ={3,}|// Source:)', re.MULTILINE)
            delimiters = sorted(set([0] + [m.start() for m in delimiter_pattern.finditer(file_content)] + [len(file_content)]))
            sections = []
            for d_idx in range(len(delimiters) - 1):
                sec_start = delimiters[d_idx]
                sec_end = delimiters[d_idx + 1]
                sec_blocks = []
                for b_start, b_end in blocks:
                    if b_start >= sec_start and b_end <= sec_end:
                        prev_end = sec_start
                        for prev_b_start, prev_b_end in blocks:
                            if prev_b_end < b_start and prev_b_end > prev_end:
                                prev_end = prev_b_end
                        preceding_text = file_content[prev_end:b_start].lower()
                        if not any(kw in preceding_text for kw in ["fade", "ending", "stop", "clear"]):
                            sec_blocks.append(file_content[b_start:b_end + 1])
                if sec_blocks:
                    sections.append(sec_blocks)
            return sections

        def _consolidate_section_blocks(collected_code: list[str]) -> str:
            inner_parts = []
            for block in collected_code:
                stripped = block.strip()
                if stripped.startswith('(') and stripped.endswith(')'):
                    inner_parts.append(stripped[1:-1].strip())
                else:
                    inner_parts.append(stripped)
            consolidated = "(\n" + "\n\n".join(inner_parts) + "\n)"
            try:
                from code_validator import normalize_for_xappend
                consolidated, _ = normalize_for_xappend(consolidated, mode=mode if mode else "compose")
            except Exception:
                pass
            return consolidated

        chunk_matched_in_file = False
        for doc in (docs or []):
            top_chunk = doc.page_content
            filename = doc.metadata.get("filename", "")
            if not filename:
                continue

            file_path = os.path.join(config.CONTEXT_FOLDER, filename)
            if not os.path.exists(file_path):
                continue

            with open(file_path, "r", encoding="utf-8") as f:
                file_content = f.read()

            idx = file_content.find(top_chunk.strip())
            if idx == -1:
                idx = file_content.find(top_chunk.strip()[:100])
                if idx == -1:
                    continue
            chunk_matched_in_file = True

            # 1. Pre-parse all top-level blocks
            blocks = []
            stack = []
            start_idx = -1
            for i, char in enumerate(file_content):
                if char == '(':
                    if not stack:
                        # Only start a top-level block if '(' is at the beginning of a line
                        if i == 0 or file_content[i-1] == '\n':
                            start_idx = i
                            stack.append(i)
                    else:
                        stack.append(i)
                elif char == ')':
                    if stack:
                        stack.pop()
                        if not stack:
                            blocks.append((start_idx, i))

            # Find the block that overlaps with the chunk
            chunk_end = idx + len(top_chunk)
            matched_block_idx = -1
            for i, (b_start, b_end) in enumerate(blocks):
                if b_start <= chunk_end and b_end >= idx:
                    matched_block_idx = i
                    break

            if matched_block_idx == -1:
                continue

            # 2. Find section boundaries
            import re
            delimiter_pattern = re.compile(r'^(/{5,}|// ={3,}|// Source:)', re.MULTILINE)
            delimiters = [m.start() for m in delimiter_pattern.finditer(file_content)]

            section_start = 0
            for pos in reversed(delimiters):
                if pos <= blocks[matched_block_idx][0]:
                    section_start = pos
                    break

            section_end = len(file_content)
            for pos in delimiters:
                if pos > blocks[matched_block_idx][1]:
                    section_end = pos
                    break

            # 3. Collect all blocks in this section, filtering teardowns
            collected_code = []
            for b_start, b_end in blocks:
                if b_start >= section_start and b_end <= section_end:
                    # Check the preceding comment for teardown keywords
                    prev_end = section_start
                    for prev_b_start, prev_b_end in blocks:
                        if prev_b_end < b_start and prev_b_end > prev_end:
                            prev_end = prev_b_end

                    preceding_text = file_content[prev_end:b_start].lower()

                    if not any(kw in preceding_text for kw in ["fade", "ending", "stop", "clear"]):
                        collected_code.append(file_content[b_start:b_end+1])

            if collected_code:
                return _consolidate_section_blocks(collected_code)

        # Direct file-based fallback: if a retrieved chunk matched inside failsafe-<mode>.scd
        # (e.g. a pure comment header chunk before a block) but did not overlap a top-level `(...)`
        # block, pick a verified section directly from failsafe-<mode>.scd.
        if chunk_matched_in_file and mode_file and os.path.exists(mode_file):
            try:
                with open(mode_file, "r", encoding="utf-8") as mf:
                    mode_content = mf.read()
                sections = _extract_sections_from_scd(mode_content)
                if sections:
                    chosen = random.choice(sections)
                    return _consolidate_section_blocks(chosen)
            except Exception:
                pass

        return ""
    except Exception as e:
        print(f"RAG failsafe lookup error: {e}", flush=True)
        return ""


def _call_rag_failsafe_lookup(prompt, mode="append"):
    """Wrapper around _rag_failsafe_lookup that stays compatible with 1-arg test mocks."""
    try:
        return _rag_failsafe_lookup(prompt, mode=mode)
    except TypeError:
        return _rag_failsafe_lookup(prompt)


def _design_failsafe_lookup(prompt=""):
    """Try design-specific failsafe RAG first, falling back to randomized subtractive synth."""
    import config
    design_rag = os.path.join(config.CONTEXT_FOLDER, "failsafe-design.scd")
    if os.path.exists(design_rag):
        effective_prompt = prompt.strip() if (prompt and prompt.strip()) else "multitimbral midi synthesizer"
        try:
            rag_code = _rag_failsafe_lookup(effective_prompt, mode="design")
        except TypeError:
            rag_code = _rag_failsafe_lookup(effective_prompt)
        if rag_code and rag_code.strip():
            return rag_code
    return _generate_design_subtractive_fallback(prompt)


def _generate_design_subtractive_fallback(prompt=""):
    """Instantiate a single-block runnable subtractive synthesizer with randomized parameters.

    Used as the fallback for the 'design' mode in X-Append when LLM-generated code
    fails validation or execution, and when testing via the 'RAG Design' button.
    """
    import random

    base_freq = round(random.choice([55.0, 65.41, 73.42, 82.41, 98.0, 110.0, 130.81, 146.83]), 2)
    detune = round(random.uniform(0.004, 0.035), 4)
    saw_mix = round(random.uniform(0.35, 0.75), 2)
    pulse_mix = round(1.0 - saw_mix, 2)
    pulse_width = round(random.uniform(0.18, 0.82), 2)
    pwm_rate = round(random.uniform(0.15, 2.8), 2)
    pwm_depth = round(random.uniform(0.05, 0.25), 2)
    sub_amp = round(random.uniform(0.12, 0.38), 2)
    noise_amp = round(random.uniform(0.01, 0.06), 3)

    cutoff = round(random.uniform(420.0, 3600.0), 1)
    rq = round(random.uniform(0.14, 0.58), 2)
    hpf_freq = round(random.uniform(40.0, 180.0), 1)
    filt_env_amt = round(random.uniform(900.0, 4800.0), 1)
    lfo_rate = round(random.uniform(0.12, 3.2), 2)
    lfo_depth = round(random.uniform(120.0, 1100.0), 1)

    atk = round(random.uniform(0.008, 0.22), 3)
    dec = round(random.uniform(0.15, 0.65), 2)
    sus = round(random.uniform(0.35, 0.8), 2)
    rls = round(random.uniform(0.25, 1.4), 2)

    pan_pos = round(random.uniform(-0.35, 0.35), 2)
    amp = round(random.uniform(0.22, 0.38), 2)
    delay_wet = round(random.uniform(0.1, 0.35), 2)
    delay_time = round(random.choice([0.125, 0.1875, 0.25, 0.375]), 4)
    verb_wet = round(random.uniform(0.15, 0.45), 2)
    verb_room = round(random.uniform(0.45, 0.85), 2)

    scale_choices = [
        "[0, 2, 3, 5, 7, 8, 10]",   # natural minor
        "[0, 2, 4, 7, 9]",          # major pentatonic
        "[0, 3, 5, 7, 10]",         # minor pentatonic
        "[0, 2, 3, 7, 8]",          # hirajoshi
        "[0, 1, 4, 5, 7, 8, 10]",   # phrygian dominant
    ]
    chosen_scale = random.choice(scale_choices)
    chosen_durs = random.choice([
        "Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf)",
        "Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf)",
        "Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf)",
    ])

    code = f"""(
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\\subtractiveDesign).fadeTime = 1.5;
Ndef(\\subtractiveDesign, {{
    |freq={base_freq}, detune={detune}, sawMix={saw_mix}, pulseMix={pulse_mix},
     pw={pulse_width}, pwmRate={pwm_rate}, pwmDepth={pwm_depth},
     subAmp={sub_amp}, noiseAmp={noise_amp},
     cutoff={cutoff}, rq={rq}, hpf={hpf_freq},
     filtEnvAmt={filt_env_amt}, lfoRate={lfo_rate}, lfoDepth={lfo_depth},
     atk={atk}, dec={dec}, sus={sus}, rls={rls},
     pan=({pan_pos}), amp={amp}, t_trig=1|
    var env, filtEnv, freqs, pwm, sawSig, pulseSig, subSig, noiseSig, sig, dynCutoff;

    env = EnvGen.ar(Env([0, 1, sus, 0], [atk, dec, rls], \\sin), t_trig);
    filtEnv = EnvGen.ar(Env.perc(atk.max(0.005), (dec + rls).clip(0.1, 2.5)), t_trig);

    freqs = freq * [1 - detune, 1, 1 + detune];
    pwm = (pw + (SinOsc.kr(pwmRate) * pwmDepth)).clip(0.08, 0.92);

    sawSig = Splay.ar(Saw.ar(freqs));
    pulseSig = Splay.ar(Pulse.ar(freqs, pwm));
    subSig = SinOsc.ar(freq * 0.5) * subAmp;
    noiseSig = PinkNoise.ar * noiseAmp;

    sig = (sawSig * sawMix) + (pulseSig * pulseMix) + subSig + noiseSig;

    dynCutoff = (cutoff + (filtEnv * filtEnvAmt) + (SinOsc.kr(lfoRate) * lfoDepth)).clip(60, 18000);
    sig = RLPF.ar(sig, dynCutoff, rq.clip(0.08, 0.95));
    sig = HPF.ar(sig, hpf.clip(20, 2000));
    sig = (sig * 1.4).tanh;

    sig = Balance2.ar(sig[0], sig[1], pan) * env * amp;
    Limiter.ar(LeakDC.ar(sig), 0.85);
}}).play;

Ndef(\\subtractiveDesign)[10] = \\filter -> {{ |in|
    CombL.ar(in, 0.5, {delay_time}, 1.6);
}};
Ndef(\\subtractiveDesign).set(\\wet10, {delay_wet});

Ndef(\\subtractiveDesign)[11] = \\filter -> {{ |in|
    FreeVerb2.ar(in[0], in[1], 1.0, {verb_room}, 0.35);
}};
Ndef(\\subtractiveDesign).set(\\wet11, {verb_wet});

Pbindef(\\subtractiveDesignSeq,
    \\dur, {chosen_durs},
    \\freq, ({base_freq} * (2 ** (Prand({chosen_scale}, inf) / 12))),
    \\t_trig, 1
);
Ndef(\\subtractiveDesign)[1] = \\set -> Pbindef(\\subtractiveDesignSeq);

// Live MIDI control (loopMIDI -> BeatStep Pro -> any external hardware MIDI)
if(MIDIClient.initialized.not) {{ MIDIClient.init }};
~myInDevice = MIDIClient.sources.detect {{ |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
}} ?? {{
    MIDIClient.sources.detect {{ |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: {{ label.contains("midiin2").not }} and: {{ label.contains("midiin 2").not }}
    }}
}} ?? {{
    MIDIClient.sources.detect {{ |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: {{ label.contains("bome").not }}
            and: {{ label.contains("midiin2").not }}
            and: {{ label.contains("midiin 2").not }}
            and: {{ label.contains("microsoft gs").not }}
            and: {{ label.contains("wavetable").not }}
            and: {{ label.contains("midi through").not }}
            and: {{ label.contains("iac ").not }}
    }}
}} ?? {{
    MIDIClient.sources.first
}};
if(~myInDevice.notNil) {{
    MIDIIn.connect(0, ~myInDevice);
    ~myUid = ~myInDevice.uid;
    ("Design Fallback MIDI connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
}} {{
    ~myUid = nil;
}};
MIDIdef.noteOn(\\subtractiveDesignMidiOn, {{ |vel, noteNum|
    Pbindef(\\subtractiveDesignSeq).stop;
    Ndef(\\subtractiveDesign).set(\\freq, noteNum.midicps, \\amp, vel.linlin(1, 127, 0.12, 0.42), \\t_trig, 1);
}}, srcID: ~myUid);
MIDIdef.cc(\\subtractiveDesignMidiCC, {{ |val, num|
    if((num == 1) or: {{ num == 74 }}) {{
        Ndef(\\subtractiveDesign).set(\\cutoff, val.linexp(0, 127, 120, 14000));
    }};
}}, srcID: ~myUid);
)"""
    return code


def _lookup_design_fallback(prompt=""):
    """Lookup semantic RAG design synthesizer, falling back to randomized subtractive synth."""
    code = _rag_failsafe_lookup(prompt, mode="design")
    if not code:
        code = _generate_design_subtractive_fallback(prompt)
    return code


def _merge_stats(stats1, stats2):
    """Merge two stats_dict objects by summing numeric fields.
    Used by cross_append to combine plan + code generation stats."""
    if not stats1:
        return stats2 or {}
    if not stats2:
        return stats1 or {}
    merged = {}
    for key in set(list(stats1.keys()) + list(stats2.keys())):
        v1 = stats1.get(key, 0)
        v2 = stats2.get(key, 0)
        if isinstance(v1, (int, float)) and isinstance(v2, (int, float)):
            merged[key] = v1 + v2
        else:
            # For non-numeric (strings, bools), take from stats2 (the later stage)
            merged[key] = v2 if key in stats2 else v1
    return merged

def cmd_append(data):
    """Append a new block to the composition (incremental mode)."""
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")
    active_file = data.get("active_file", "")

    # Use a stable cache key even for unsaved documents (empty active_file).
    # Without this, the empty string is falsy and all state lookups/waits are skipped.
    state_key = active_file if active_file else "__unsaved__"

    # Wait for any in-flight background state update from a previous block
    # to complete before reading the composition state. This prevents the race
    # condition where block N+1 starts before block N's state update finishes.
    if state_key in _composition_state_events:
        evt = _composition_state_events[state_key]
        if not evt.is_set():
            print("Waiting for previous composition state update...", flush=True)
            _wait_event_cancellable(evt, timeout=30)

    # Use daemon's cached composition state if available, otherwise fall back to C++ state
    if state_key in _composition_states:
        composition_state = _composition_states[state_key]
    else:
        composition_state = data.get("composition_state", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    # Build system prompt from explicit sys_msgs sent by the UI (falling back to append default)
    full_sys = _build_system_prompt(data, default_key="append")

    # RAG context (only if KB toggle is enabled)
    use_kb = data.get("use_kb", True)
    if use_kb:
        try:
            print("Searching knowledge base...", flush=True)
            import rag_engine
            code_context = rag_engine.query_index(prompt, sources=["knowledge-base"])
            full_sys += f"\n\n=== Knowledge Base ===\n{code_context}"
        except Exception:
            pass
    _check_cancelled()

    # Build user prompt with composition context
    comp_section = f"\n\n=== CURRENT COMPOSITION STATE ===\n{composition_state}" if composition_state else \
        "\n\n=== CURRENT COMPOSITION STATE ===\n(Empty — this is the first block)"

    # Always include up to 6000 characters of the active file as fallback context.
    # 2000 was too small — by block 4 of a typical session (~6000 chars total),
    # only the last block was visible, causing the LLM to lose track of earlier instruments.
    prev_content = _read_scd(active_file)[-6000:] if active_file else ""
    prev_section = f"\n\n=== PREVIOUS CODE ===\n{prev_content}" if prev_content else ""

    user_prompt = (
        f"User Request: {prompt}\n"
        f"{comp_section}"
        f"{prev_section}\n\n"
        f"Generate ONLY the SuperCollider code for this single block. "
        f"Do NOT repeat any existing instruments or sequences."
    )

    print(f"Generating next block... (including {len(prev_content)} chars of previous code context)", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)

    (code, stats_dict), rag_fallback = _run_with_parallel_fallback(
        _rag_failsafe_lookup,
        (prompt,),
        lambda: client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget),
    )

    validator_fixes = []
    if code and code.strip():
        # Validate and auto-fix common runtime-breaking bugs
        try:
            from code_validator import validate_and_fix
            code, fix_log = validate_and_fix(code)
            validator_fixes = list(fix_log)
            if fix_log:
                print(f"Code validator applied fixes: {fix_log}", flush=True)
        except Exception as e:
            print(f"Code validator failed: {e}", flush=True)

    if not code or not code.strip():
        print(f"WARNING: LLM returned empty code for prompt: '{prompt[:100]}'", flush=True)
        print(f"  model={model_key}", flush=True)
        print(f"  user_prompt length={len(user_prompt)}, sys_prompt length={len(full_sys)}", flush=True)

    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # inserts the code into the document via QTextCursor and handles saving.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher that breaks the auto-execute flow.

    updated_state = composition_state
    patch_state_json = {}
    if code and code.strip():
        try:
            import sc_state_parser
            updated_state = sc_state_parser.update_composition_state(composition_state, code).strip()
            _composition_states[state_key] = updated_state
            patch_state_json = sc_state_parser.get_patch_state_json(updated_state)
        except Exception as e:
            print(f"Composition state update failed: {e}", flush=True)

    utils.append_to_session_log("append", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {
        "code": code,
        "last_stats": stats_dict,
        "rag_fallback": rag_fallback,
        "design_cleanup_applied": False,
        "validator_fixes": validator_fixes,
        "composition_state": updated_state,
        "patch_state_json": patch_state_json,
    }


LEAN_XAPPEND_SYS_MSGS = {
    "compose": ["xappend_lean/compose-lean-v1.md"],
    "design": ["xappend_lean/design-lean-v1.md"],
    "generate": ["xappend_lean/generate-lean-v1.md"],
}


def cmd_cross_append(data):
    """Cross-Append: route voice transcription or prompt through the selected mode's pipeline.
    
    Supports two workflows for compose/design/generate:
      - Standard (default, lean_prompt=False): two-stage plan→code pipeline using original tab prompts.
      - Lean Prompt (optional, lean_prompt=True): single-step leaned-out prompt (like append mode),
        completely independent of the original two-step prompts and other tabs.
    All modes update the shared composition state for cross-mode awareness.
    """
    mode = data.get("mode", "append")
    active_file = data.get("active_file", "")
    state_key = active_file if active_file else "__unsaved__"
    
    if mode == "append":
        # Delegate directly — cmd_append already handles state tracking
        result = cmd_append(data)
        return result

    lean_prompt = bool(data.get("lean_prompt", False))
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")
    provider, model_name = _resolve_model(model_key)

    # Read shared composition state upfront for BOTH lean and standard two-stage X-Append
    if state_key in _composition_state_events:
        evt = _composition_state_events[state_key]
        if not evt.is_set():
            print("Waiting for previous composition state update...", flush=True)
            _wait_event_cancellable(evt, timeout=30)

    if state_key in _composition_states:
        composition_state = _composition_states[state_key]
    else:
        composition_state = data.get("composition_state", "")

    import concurrent.futures

    if lean_prompt and mode in LEAN_XAPPEND_SYS_MSGS:
        # --- Single-Step Lean Prompt Pipeline (modeled on cmd_append) ---

        print(f"Loading AI models for lean {mode}...", flush=True)
        client = _make_llm_client(provider, model_name)

        lean_msgs = data.get("lean_sys_msgs") or LEAN_XAPPEND_SYS_MSGS[mode]
        full_sys = _build_system_prompt({"sys_msgs": lean_msgs})

        use_kb = data.get("use_kb", True)
        if use_kb:
            try:
                print("Searching knowledge base...", flush=True)
                import rag_engine
                code_context = rag_engine.query_index(prompt, sources=["knowledge-base"])
                full_sys += f"\n\n=== Knowledge Base ===\n{code_context}"
            except Exception:
                pass
        _check_cancelled()

        comp_section = (
            f"\n\n=== CURRENT COMPOSITION STATE ===\n{composition_state}"
            if composition_state
            else "\n\n=== CURRENT COMPOSITION STATE ===\n(Empty — this is the first block)"
        )
        prev_content = _read_scd(active_file)[-4000:] if active_file else ""
        prev_section = f"\n\n=== PREVIOUS CODE ===\n{prev_content}" if prev_content else ""

        if mode == "compose":
            mode_directive = (
                "Generate ONLY the single-block (...) fixed-timeline SuperCollider piece "
                "(with \\safetyLimiter and Tdef(\\masterScore) concluding by stopping/clearing ONLY the specific named Pbindefs, Ndefs, and Tdef defined in this block; "
                "NEVER call Ndef.clear, Pbindef.removeAll, Pbindef.all, Tdef.removeAll, Tdef.all, ServerTree.removeAll, s.freeAll, or s.quit)."
            )
        elif mode == "design":
            mode_directive = (
                "Generate ONLY the single-block (...) playable multitimbral MIDI + Paginated-GUI "
                "SuperCollider synthesizer (with hardware MIDI fallback and no active cleanup block)."
            )
        else:
            mode_directive = (
                "Generate ONLY the single-block (...) continuously running JITLib Ndef + Pbindef "
                "SuperCollider soundscape (do NOT stop or clear active instruments at the end)."
            )

        user_prompt = (
            f"User Request: {prompt}"
            f"{comp_section}"
            f"{prev_section}\n\n"
            f"{mode_directive}"
        )

        temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
        thinking_budget = data.get("thinking", 0)

        print(f"Generating single-step lean {mode} block...", flush=True)
        fallback_fn = _design_failsafe_lookup if mode == "design" else _call_rag_failsafe_lookup
        fallback_args = (prompt,) if mode == "design" else (prompt, mode)

        def _run_lean_generate():
            try:
                return client.generate(
                    user_prompt,
                    full_sys,
                    temperature=temperature,
                    thinking_budget=thinking_budget,
                )
            except Exception as e:
                from llm_engine import RequestCancelledError
                if isinstance(e, RequestCancelledError):
                    raise
                print(f"Error in lean {mode} generate: {e}", flush=True)
                err_code = f"// Error in lean {mode} generation: {e}\n"
                err_stats = {"error": str(e), "cost": 0.0, "time_s": 0.0, "in_tokens": 0, "out_tokens": 0}
                return err_code, err_stats

        (code, code_stats), rag_fallback = _run_with_parallel_fallback(
            fallback_fn, fallback_args, _run_lean_generate
        )

        plan = ""
        plan_stats = {}
        log_tag = f"cross_append_{mode}_lean"
        log_sys = full_sys
        log_user = user_prompt
    else:
        # --- Standard Two-Stage Plan→Code Pipeline ---
        default_plan_key = f"{mode}_plan" if mode in ("compose", "design") else "gen_plan"
        default_code_key = f"{mode}_code" if mode in ("compose", "design") else "gen_code"
        plan_sys_msgs = data.get("plan_sys_msgs") or _get_default_sys_msgs(default_plan_key)
        code_sys_msgs = data.get("code_sys_msgs") or _get_default_sys_msgs(default_code_key)

        fallback_fn = _design_failsafe_lookup if mode == "design" else _call_rag_failsafe_lookup
        fallback_args = (prompt,) if mode == "design" else (prompt, mode)

        def _run_two_stage():
            # --- Stage 1: Generate Plan ---
            plan_data = dict(data)
            plan_data["sys_msgs"] = plan_sys_msgs
            plan_data["mode"] = mode
            plan_data["is_cross_append"] = True
            plan_data["composition_state"] = composition_state
            if mode == "generate":
                plan_data["include_ending"] = False

            plan_result = cmd_generate_plan(plan_data)
            stg_plan = plan_result.get("plan", "")
            stg_plan_stats = plan_result.get("last_stats", {})
            plan_sys = plan_result.get("system_prompt") or _build_system_prompt(
                {"sys_msgs": plan_sys_msgs}, default_key=default_plan_key
            )
            plan_user = plan_result.get("user_prompt") or _build_plan_user_prompt(
                prompt,
                mode=mode,
                include_ending=plan_data.get("include_ending", True),
                is_cross_append=True,
                composition_state=composition_state,
            )

            # Log the plan separately for observability
            utils.append_to_session_log(
                f"cross_append_{mode}_plan",
                plan_sys,
                plan_user,
                stg_plan,
                stg_plan_stats,
                f"{provider}/{model_name}",
                active_file=active_file
            )

            # --- Stage 2: Generate Code from Plan ---
            _check_cancelled()
            code_data = dict(data)
            code_data["sys_msgs"] = code_sys_msgs
            code_data["plan"] = stg_plan
            code_data["prompt"] = prompt
            code_data["mode"] = mode
            code_data["is_cross_append"] = True
            code_data["composition_state"] = composition_state
            if mode == "generate":
                code_data["include_ending"] = False

            stg_code_result = cmd_generate_code(code_data)
            return stg_plan, stg_plan_stats, stg_code_result, code_data

        (plan, plan_stats, code_result, code_data), rag_fallback = _run_with_parallel_fallback(
            fallback_fn, fallback_args, _run_two_stage
        )
        code = code_result.get("code", "")
        code_stats = code_result.get("last_stats", {})

        log_tag = f"cross_append_{mode}"
        log_sys = code_result.get("system_prompt") or _build_system_prompt(
            {"sys_msgs": code_sys_msgs}, default_key=default_code_key
        )
        log_user = code_result.get("user_prompt") or _build_code_user_prompt(
            prompt,
            plan,
            mode=mode,
            active_file=active_file,
            include_ending=code_data.get("include_ending", True),
            is_cross_append=True,
            composition_state=composition_state,
        )

    # Validate, fix, and normalize into a single outer (...) block for automated evaluation
    had_previous_design = bool(
        data.get("cleanup_previous_design", _design_ran_in_session.get(state_key, False))
    ) if mode == "design" else False
    design_cleanup_applied = False
    validator_fixes = []

    if code and code.strip():
        try:
            from code_validator import normalize_for_xappend, prepend_design_cleanup
            code, fix_log = normalize_for_xappend(
                code,
                mode=mode,
                cleanup_previous_design=had_previous_design,
            )
            validator_fixes = list(fix_log)
            if mode == "design":
                design_cleanup_applied = had_previous_design
                if had_previous_design and rag_fallback:
                    rag_fallback, _ = prepend_design_cleanup(rag_fallback)
                _design_ran_in_session[state_key] = True
            if fix_log:
                print(f"Cross-append validator/normalizer ({mode}) applied: {fix_log}", flush=True)
        except Exception as e:
            print(f"Cross-append validator/normalizer ({mode}) failed: {e}", flush=True)

    # Log the code generation
    utils.append_to_session_log(
        log_tag,
        log_sys,
        log_user,
        code,
        code_stats,
        f"{provider}/{model_name}",
        active_file=active_file
    )
    
    # Update composition state synchronously (<5ms deterministic parse)
    updated_state = composition_state
    patch_state_json = {}
    if code and code.strip():
        try:
            import sc_state_parser
            updated_state = sc_state_parser.update_composition_state(composition_state, code).strip()
            _composition_states[state_key] = updated_state
            patch_state_json = sc_state_parser.get_patch_state_json(updated_state)
            print(f"Cross-append state update complete for {state_key} (mode={mode})", flush=True)
        except Exception as e:
            print(f"Cross-append state update failed: {e}", flush=True)
    
    # Merge stats from both stages
    merged_stats = _merge_stats(plan_stats, code_stats)
    
    return {
        "code": code,
        "plan": plan,
        "last_stats": merged_stats,
        "rag_fallback": rag_fallback,
        "design_cleanup_applied": design_cleanup_applied,
        "validator_fixes": validator_fixes,
        "composition_state": updated_state,
        "patch_state_json": patch_state_json,
    }


def cmd_rag_lookup(data):
    """Fallback-only lookup (no LLM call) used by the X-Append validation "RAG" buttons.

    - For append / compose / generate: runs semantic RAG lookup (_rag_failsafe_lookup).
    - For design: tries design RAG first, then instantiates the randomized subtractive synth fallback.
    """
    prompt = data.get("prompt", "")
    mode = data.get("mode", "append")
    active_file = data.get("active_file", "")
    state_key = active_file if active_file else "__unsaved__"

    if mode == "design":
        print(f"Design fallback lookup (RAG or randomized subtractive synth): {prompt[:100]}", flush=True)
        code = _design_failsafe_lookup(prompt)
        had_previous_design = bool(
            data.get("cleanup_previous_design", _design_ran_in_session.get(state_key, False))
        )
        if code and code.strip() and had_previous_design:
            try:
                from code_validator import prepend_design_cleanup
                code, _ = prepend_design_cleanup(code)
            except Exception:
                pass
        if code and code.strip():
            _design_ran_in_session[state_key] = True
        return {"code": code, "mode": mode}
    if not prompt.strip():
        return {"code": "", "mode": mode}
    print(f"RAG validation lookup (mode={mode}): {prompt[:100]}", flush=True)
    code = _rag_failsafe_lookup(prompt, mode=mode)
    return {"code": code, "mode": mode}


def cmd_reset_composition_state(data):
    """Reset composition state from scratch using a specific block (failsafe fallback)."""
    code = data.get("code", "")
    active_file = data.get("active_file", "")
    mode = data.get("mode", "")
    state_key = active_file if active_file else "__unsaved__"

    new_state = "(Empty)"
    patch_state_json = {}
    try:
        import sc_state_parser
        new_state = sc_state_parser.update_composition_state("", code).strip()
        _composition_states[state_key] = new_state
        patch_state_json = sc_state_parser.get_patch_state_json(new_state)
        if data.get("reset_design_tracker", False):
            _design_ran_in_session[state_key] = False
        else:
            _design_ran_in_session[state_key] = bool(
                mode == "design" or patch_state_json.get("design", {}).get("active", False)
            )
        print(f"Composition state reset for {state_key} (design_active={_design_ran_in_session[state_key]})", flush=True)
    except Exception as e:
        print(f"Composition state reset failed: {e}", flush=True)

    return {
        "status": "ok",
        "composition_state": new_state,
        "patch_state_json": patch_state_json,
    }
def cmd_fix(data):
    """Fix a code block using its stack trace."""
    block = data.get("block", "")
    error = data.get("error", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    # Build system prompt from explicit sys_msgs sent by the UI (falling back to fix default)
    full_sys = _build_system_prompt(data, default_key="fix")

    user_prompt = (
        f"CODE BLOCK:\n{block}\n\n"
        f"ERROR / STACK TRACE:\n{error}\n\n"
        f"Fix the code. Return ONLY the corrected code block."
    )

    print("Analyzing trace and generating fix...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    is_cross_append = bool(data.get("is_cross_append", False))
    fix_mode = data.get("mode", "append")
    validator_fixes = []
    if code and code.strip():
        try:
            if is_cross_append:
                from code_validator import normalize_for_xappend, DESIGN_PRE_CLEANUP_MARKER
                had_prev_design = (
                    bool(data.get("cleanup_previous_design", False))
                    or (fix_mode == "design" and DESIGN_PRE_CLEANUP_MARKER in block)
                )
                code, fix_log = normalize_for_xappend(
                    code,
                    mode=fix_mode,
                    cleanup_previous_design=had_prev_design,
                )
                validator_fixes = list(fix_log)
                if fix_log:
                    print(f"Auto-fix validator/normalizer ({fix_mode}) applied: {fix_log}", flush=True)
            else:
                from code_validator import validate_and_fix
                code, fix_log = validate_and_fix(code)
                validator_fixes = list(fix_log)
                if fix_log:
                    print(f"Fix validator applied: {fix_log}", flush=True)
        except Exception as e:
            print(f"Fix validator failed: {e}", flush=True)

    active_file = data.get("active_file")
    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # handles substituting the block in the document and saving it.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher.

    print("Queueing learnings for system improvements...", flush=True)
    # Queue the mistake/error/fix for background processing on IDE shutdown
    pending_fixes_path = os.path.join(utils.LOGS_DIR, ".pending_fixes.json")
    pending_list = []
    if os.path.exists(pending_fixes_path):
        try:
            with open(pending_fixes_path, 'r', encoding='utf-8') as f:
                pending_list = json.load(f)
        except Exception:
            pass
            
    pending_list.append({
        "block": block,
        "error": error,
        "code": code,
        "model_key": model_key
    })
    
    with open(pending_fixes_path, 'w', encoding='utf-8') as f:
        json.dump(pending_list, f, indent=2)

    utils.append_to_session_log("fix", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "last_stats": stats_dict, "validator_fixes": validator_fixes}


def cmd_remake(data):
    """Rework a code block based on aesthetic direction."""
    block = data.get("block", "")
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    # Build system prompt from explicit sys_msgs sent by the UI (falling back to remake default)
    full_sys = _build_system_prompt(data, default_key="remake")

    user_prompt = (
        f"CODE BLOCK:\n{block}\n\n"
        f"USER PROMPT:\n{prompt}\n\n"
        f"Rework this code block. Return ONLY the reworked code block."
    )

    print("Applying aesthetic changes...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    active_file = data.get("active_file")
    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # handles substituting the block in the document and saving it.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher.

    utils.append_to_session_log("remake", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "last_stats": stats_dict}


def cmd_learn(data):
    """Answer a free-form question using test.scd as context.
    
    Uses lean system prompt (no improvements) — this is Q&A, not code generation.
    """
    prompt = data.get("prompt", "")
    history = data.get("history", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    client = _make_llm_client(provider, model_name)

    # Build system prompt from explicit sys_msgs sent by the UI (falling back to learn default)
    full_sys = _build_system_prompt(data, default_key="learn")

    # Add target file as context
    active_file = data.get("active_file")
    target_content = _read_scd(active_file)
    if target_content:
        target_display = active_file if active_file else config.OUTPUT_FILE
        full_sys += f"\n\n=== CURRENT SESSION CODE ({target_display}) ===\n{target_content}"

    # Build prompt with chat history
    user_prompt = prompt
    if history:
        user_prompt = f"CONVERSATION HISTORY:\n{history}\n\nNEW QUESTION: {prompt}"

    print("Thinking...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    response, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    utils.append_to_session_log("learn", full_sys, user_prompt, response, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"response": response, "last_stats": stats_dict}


def cmd_add_kb(data):
    """Add a code block + description to user-kb.scd."""
    block = data.get("block", "")
    description = data.get("description", "")

    kb_file = os.path.join(config.CONTEXT_FOLDER, "user-kb.scd")

    # Format: SC comment with description, then the code block
    entry = f"\n\n// --- User Knowledge Entry [{datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}] ---\n"
    if description:
        # Add description as SC comments
        for line in description.strip().split("\n"):
            entry += f"// {line}\n"
    entry += block + "\n"

    print("Writing entry to user-kb.scd...", flush=True)
    os.makedirs(config.CONTEXT_FOLDER, exist_ok=True)
    with open(kb_file, 'a', encoding='utf-8') as f:
        f.write(entry)

    active_file = data.get("active_file")
    utils.append_to_session_log("add_kb", "N/A", f"Desc: {description}\n\nBlock:\n{block}", f"Block added ({len(block)} chars)", {}, "", active_file=active_file)
    return {"status": "ok", "file": kb_file}


def cmd_consume_kb(data):
    """Re-ingest the knowledge base."""
    try:
        print("Accessing files and preparing index...", flush=True)
        import rag_engine
        print("Embedding contents...", flush=True)
        rag_engine.build_knowledge_base_index()
        _check_cancelled()
        active_file = data.get("active_file")
        utils.append_to_session_log("consume_kb", "N/A", "Re-ingesting knowledge base", "Knowledge base rebuilt successfully", {}, "", active_file=active_file)
        return {"status": "ok"}
    except Exception as e:
        from llm_engine import RequestCancelledError
        if isinstance(e, RequestCancelledError):
            raise
        error_msg = str(e)
        active_file = data.get("active_file")
        utils.append_to_session_log("consume_kb", "N/A", "Re-ingesting knowledge base", f"ERROR: {error_msg}", {}, "", active_file=active_file)
        return {"status": "error", "error": error_msg}


def cmd_init_session(data):
    """Bootstraps a precise timestamped log to trace a new session dynamically."""
    active_file = data.get("active_file")
    final_name = utils.init_session_log(active_file=active_file)
    return {"status": "ok", "filename": final_name}


def _pending_rag_path():
    return os.path.join(utils.LOGS_DIR, ".pending_rag_blocks.json")


def _rag_content_hash(blocks: list[str]) -> str:
    import hashlib
    normalized = "\n\n".join(b.strip() for b in blocks if b and b.strip())
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:16]


def cmd_prepare_rag_block(data):
    """Programmatically classify a generated block and break it into () executable blocks
    (plus a consolidated failsafe preview) for Gate 2 Validation Server execution.
    Zero LLM calls.
    """
    code = data.get("code", "")
    hint_mode = data.get("mode", "")
    from code_validator import classify_sc_block, extract_executable_rag_blocks, normalize_for_xappend

    cls = classify_sc_block(code, hint_mode=hint_mode)
    if not cls.get("is_rag_eligible", False):
        return {
            "is_rag_eligible": False,
            "detected_mode": cls.get("mode", hint_mode or "append"),
            "reason": cls.get("reason", "ineligible"),
            "executable_blocks": [],
            "consolidated_block": "",
        }

    detected_mode = cls["mode"]
    exec_blocks = extract_executable_rag_blocks(code, mode=detected_mode)
    if not exec_blocks:
        return {
            "is_rag_eligible": False,
            "detected_mode": detected_mode,
            "reason": "no_executable_blocks_extracted",
            "executable_blocks": [],
            "consolidated_block": "",
        }

    inner_parts = []
    for blk in exec_blocks:
        s = blk.strip()
        if s.startswith("(") and s.endswith(")"):
            inner_parts.append(s[1:-1].strip())
        else:
            inner_parts.append(s)
    consolidated = "(\n" + "\n\n".join(inner_parts) + "\n)"
    try:
        consolidated, _ = normalize_for_xappend(consolidated, mode=detected_mode)
    except Exception:
        pass

    return {
        "is_rag_eligible": True,
        "detected_mode": detected_mode,
        "reason": cls.get("reason", ""),
        "signals": cls.get("signals", []),
        "executable_blocks": exec_blocks,
        "consolidated_block": consolidated,
    }


def cmd_queue_rag_block(data):
    """Queue a validation-verified block into use-logs/.pending_rag_blocks.json
    with programmatic chunk/byte/time metrics (zero LLM calls).
    """
    code = data.get("code", "")
    prompt = (data.get("prompt", "") or "").strip()
    origin_mode = (data.get("origin_mode") or data.get("mode") or "append").strip()
    detected_mode = (data.get("detected_mode") or "").strip()
    exec_blocks = data.get("executable_blocks")
    val_verified = bool(data.get("val_server_verified", False))
    active_file = data.get("active_file", "") or ""

    if not detected_mode or not exec_blocks:
        prep = cmd_prepare_rag_block({"code": code, "mode": origin_mode})
        if not prep.get("is_rag_eligible"):
            return {"status": "skipped", "reason": prep.get("reason", "ineligible")}
        detected_mode = prep["detected_mode"]
        exec_blocks = prep["executable_blocks"]

    if detected_mode not in ("append", "generate", "compose", "design"):
        detected_mode = "append"

    content_hash = _rag_content_hash(exec_blocks)
    os.makedirs(utils.LOGS_DIR, exist_ok=True)
    pending_path = _pending_rag_path()

    pending_list = []
    if os.path.exists(pending_path):
        try:
            with open(pending_path, "r", encoding="utf-8") as f:
                pending_list = json.load(f)
        except Exception:
            pending_list = []

    # Deduplicate against already queued entries
    if any(item.get("content_hash") == content_hash for item in pending_list):
        return {
            "status": "duplicate",
            "detected_mode": detected_mode,
            "num_exec_blocks": len(exec_blocks),
            "val_server_verified": val_verified,
        }

    # Deduplicate against target failsafe-<mode>.scd on disk
    target_rag_file = os.path.join(config.CONTEXT_FOLDER, f"failsafe-{detected_mode}.scd")
    if os.path.exists(target_rag_file):
        try:
            with open(target_rag_file, "r", encoding="utf-8") as f:
                existing_text = f.read()
            if exec_blocks[0].strip() in existing_text:
                return {
                    "status": "duplicate_on_disk",
                    "detected_mode": detected_mode,
                    "num_exec_blocks": len(exec_blocks),
                    "val_server_verified": val_verified,
                }
        except Exception:
            pass

    formatted_section = _format_rag_section(
        prompt=prompt,
        detected_mode=detected_mode,
        exec_blocks=exec_blocks,
        source_file=os.path.basename(active_file) if active_file else "session",
        timestamp=datetime.datetime.now().strftime("%Y-%m-%d_%H-%M"),
    )

    try:
        import rag_engine
        num_chunks = rag_engine.count_chunks_for_text(formatted_section)
    except Exception:
        num_chunks = max(1, (len(formatted_section) + 3599) // 3600)

    entry = {
        "prompt": prompt[:500],
        "detected_mode": detected_mode,
        "origin_mode": origin_mode,
        "executable_blocks": exec_blocks,
        "num_exec_blocks": len(exec_blocks),
        "num_chunks": num_chunks,
        "char_count": len(formatted_section),
        "content_hash": content_hash,
        "val_server_verified": val_verified,
        "source_file": os.path.basename(active_file) if active_file else "session",
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    pending_list.append(entry)
    with open(pending_path, "w", encoding="utf-8") as f:
        json.dump(pending_list, f, indent=2)

    return {
        "status": "queued",
        "detected_mode": detected_mode,
        "num_exec_blocks": len(exec_blocks),
        "num_chunks": num_chunks,
        "val_server_verified": val_verified,
    }


def _format_rag_section(prompt: str, detected_mode: str, exec_blocks: list[str], source_file: str, timestamp: str) -> str:
    clean_prompt = " ".join((prompt or "session block").splitlines()).strip()
    if len(clean_prompt) > 160:
        clean_prompt = clean_prompt[:157] + "..."
    header = (
        f"// Source: {source_file}_{timestamp}\n"
        f"// MODE: {detected_mode}\n"
        f"// THEME: {clean_prompt}"
    )
    return header + "\n" + "\n\n".join(b.strip() for b in exec_blocks if b and b.strip()) + "\n"


def _incorporate_pending_rag_blocks():
    """Verify (if needed), write () executable blocks to per-use-case failsafe RAG files,
    and incrementally index new chunks into ChromaDB. Zero LLM calls.
    """
    pending_path = _pending_rag_path()
    if not os.path.exists(pending_path):
        return {"processed": 0, "chunks_added": 0}

    with open(pending_path, "r", encoding="utf-8") as f:
        pending_list = json.load(f)

    if not pending_list:
        return {"processed": 0, "chunks_added": 0}

    from code_validator import verify_blocks_with_sclang_scval
    verified_list = verify_blocks_with_sclang_scval(pending_list)

    if not verified_list:
        print("No pending RAG blocks passed validation.", flush=True)
        return {"processed": 0, "chunks_added": 0}

    os.makedirs(config.CONTEXT_FOLDER, exist_ok=True)
    from langchain_core.documents import Document
    import rag_engine

    new_docs = []
    processed_count = 0

    for item in verified_list:
        mode = item.get("detected_mode", "append")
        if mode not in ("append", "generate", "compose", "design"):
            mode = "append"
        exec_blocks = item.get("executable_blocks") or []
        if not exec_blocks:
            continue

        target_filename = f"failsafe-{mode}.scd"
        target_path = os.path.join(config.CONTEXT_FOLDER, target_filename)

        section_text = _format_rag_section(
            prompt=item.get("prompt", ""),
            detected_mode=mode,
            exec_blocks=exec_blocks,
            source_file=item.get("source_file", "session"),
            timestamp=item.get("timestamp", datetime.datetime.now().strftime("%Y-%m-%d_%H-%M")).replace(":", "-").replace(" ", "_"),
        )

        prefix = "\n\n" if os.path.exists(target_path) and os.path.getsize(target_path) > 0 else ""
        with open(target_path, "a", encoding="utf-8") as rf:
            rf.write(prefix + section_text)

        new_docs.append(
            Document(
                page_content=section_text,
                metadata={
                    "source": "knowledge-base",
                    "filename": target_filename,
                    "use_case": mode,
                },
            )
        )
        processed_count += 1

    chunks_added = 0
    if new_docs:
        print(f"Incrementally indexing {len(new_docs)} verified RAG section(s)...", flush=True)
        chunks_added = rag_engine.ingest_documents_incrementally(new_docs)
        print(f"Failsafe RAG update complete: {processed_count} entries, {chunks_added} chunks added.", flush=True)

    return {"processed": processed_count, "chunks_added": chunks_added}


def cmd_save_session_log(data):
    """Finalize the current session log on IDE shutdown and conditionally process offline learnings & failsafe RAGs."""
    process_fixes = data.get("process_fixes", False)
    process_rag_blocks = data.get("process_rag_blocks", False)

    # Drain any unverified candidates handed over by the IDE during shutdown so they are verified & ingested
    extra_candidates = data.get("extra_rag_candidates") or []
    for cand in extra_candidates:
        if not isinstance(cand, dict):
            continue
        c_code = cand.get("code", "")
        if not c_code or not c_code.strip():
            continue
        try:
            cmd_queue_rag_block({
                "code": c_code,
                "prompt": cand.get("prompt", ""),
                "origin_mode": cand.get("hint_mode", "append"),
                "val_server_verified": bool(cand.get("val_server_verified", False)),
                "active_file": cand.get("active_file") or data.get("active_file", ""),
            })
        except Exception as cand_err:
            print(f"Failed to queue extra shutdown RAG candidate: {cand_err}", flush=True)

    # IMPORTANT: Process failsafe RAG blocks FIRST before Google Docs network sync so
    # local KB ingestion completes immediately and cannot be delayed by slow network I/O.
    pending_rag_path = _pending_rag_path()
    rag_summary = {"processed": 0, "chunks_added": 0}
    if os.path.exists(pending_rag_path):
        if process_rag_blocks:
            try:
                rag_summary = _incorporate_pending_rag_blocks()
            except Exception as rag_err:
                print(f"Failed to process pending RAG blocks: {rag_err}", flush=True)
        try:
            os.remove(pending_rag_path)
        except OSError:
            pass

    pending_fixes_path = os.path.join(utils.LOGS_DIR, ".pending_fixes.json")
    if os.path.exists(pending_fixes_path):
        if process_fixes:
            try:
                with open(pending_fixes_path, 'r', encoding='utf-8') as f:
                    pending_list = json.load(f)

                if pending_list:
                    print(f"Processing {len(pending_list)} offline background learnings...", flush=True)
                    from llm_engine import LLMClient

                    for item in pending_list:
                        block = item.get("block", "")
                        error = item.get("error", "")
                        code = item.get("code", "")
                        model_key = item.get("model_key", "")

                        provider, model_name = _resolve_model(model_key)
                        client = LLMClient(provider=provider, model_name=model_name)

                        summary_prompt = (
                            f"Analyze this SuperCollider bug fix.\n"
                            f"MISTAKE:\n{block}\n"
                            f"ERROR:\n{error}\n"
                            f"FIX:\n{code}\n\n"
                            f"TASK: Write a concise technical takeaway (LESSON) on how to avoid this error."
                        )

                        try:
                            summary, _ = client.generate(summary_prompt)
                            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
                            entry = f"### Entry [{timestamp}] (Fix Tab - Offline)\n{summary}"
                            utils.append_to_local_file(config.IMPROVEMENTS_FILE, entry)
                        except Exception as lesson_err:
                            print(f"Error generating offline lesson: {lesson_err}", flush=True)
            except Exception as e:
                print(f"Failed to process offline learning tasks: {e}", flush=True)

        # Always delete the queue file at the end whether we processed it or aborted it
        try:
            os.remove(pending_fixes_path)
        except OSError:
            pass

    sync_to_docs = bool(data.get("sync_to_docs", True))
    try:
        result = utils.finalize_session_log(process_fixes, sync_to_docs=sync_to_docs)
    except TypeError:
        result = utils.finalize_session_log(process_fixes)
    if result:
        return {"status": "ok", "filename": result, "rag_summary": rag_summary}
    return {"status": "ok", "filename": None, "rag_summary": rag_summary, "message": "No session data to save."}


def cmd_get_prompt_history(data):
    """Return UI-friendly prompt history for the current session."""
    active_file = data.get("active_file")
    entries = utils.get_session_history_entries(active_file=active_file)
    return {"entries": entries}


def cmd_get_session_stats(data):
    """Return the session environmental and cost statistics."""
    active_file = data.get("active_file")
    stats = utils.get_session_stats_summary(active_file=active_file)
    return {"session_stats": stats}


def cmd_get_raw_session_log(data):
    """Return the entire markdown session log content."""
    active_file = data.get("active_file")
    log_path = utils._get_active_session_log_path(active_file)
    if os.path.exists(log_path):
        with open(log_path, 'r', encoding='utf-8') as f:
            return {"raw_log": f.read()}
    return {"raw_log": ""}


def cmd_import_raw_session_log(data):
    """Overwrite the session log with provided raw content."""
    active_file = data.get("active_file")
    content = data.get("raw_log", "")
    log_path = utils._get_active_session_log_path(active_file)
    os.makedirs(os.path.dirname(os.path.abspath(log_path)), exist_ok=True)
    with open(log_path, 'w', encoding='utf-8') as f:
        f.write(content)
    return {"status": "ok"}


def cmd_sync_to_drive(data):
    """Manually sync pending session logs to Google Docs.
    Allows interactive OAuth re-authentication if needed.
    """
    print("Syncing pending logs to Google Docs...", flush=True)
    result = utils.sync_pending_logs_to_google_docs(allow_interactive=True)
    if result:
        return {"status": "ok", "message": "Sync complete."}
    return {"status": "skipped", "message": "Could not authenticate with Google Docs."}


# --- Voice Dictation Commands ---

def _daemon_write_json(obj):
    """Thread-safe write of a JSON line to the daemon stdout."""
    global _daemon_stdout
    if _daemon_stdout is None:
        return
    with _daemon_stdout_lock:
        try:
            # CRITICAL FIX: ensure_ascii=True MUST be used on Windows.
            # If False, Python's stdout pipe encoding (often cp1252) will corrupt
            # non-ASCII characters (like pt-BR accents) into invalid bytes or ,
            # causing the C++ IDE's QJsonDocument parser to fail silently.
            _daemon_stdout.write(json.dumps(obj, ensure_ascii=True) + "\n")
            _daemon_stdout.flush()
        except Exception as e:
            with open("c:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/child_crash.log", "a") as f:
                f.write(f"WRITE_JSON ERROR: {e}\n{traceback.format_exc()}\n")


def _select_best_microphone_device_index(preferred_index=None):
    """Select a real hardware microphone device index for PyAudio / RealtimeSTT.

    When ASIO Link Pro (`ASIOVADPRO Driver`) or VB-Audio Virtual Cable is installed on Windows,
    Windows often sets `Mix 01 (ASIOVADPRO Driver)` or `CABLE Output` as the default recording
    device. Because those virtual loopback buses carry no microphone signal, RealtimeSTT's VAD
    never triggers and dictation hangs on 'Listening...'.
    """
    if preferred_index is not None:
        try:
            return int(preferred_index), f"explicit index {preferred_index}"
        except (TypeError, ValueError):
            pass

    virtual_keywords = (
        "asiovadpro",
        "asio link",
        "cable output",
        "vb-audio",
        "voicemeeter",
        "stereo mix",
        "mix 0",
        "mix 1",
        "virtual",
        "what u hear",
        "loopback",
        "sound mapper",
    )

    def _is_virtual(name: str) -> bool:
        low = (name or "").lower()
        return any(kw in low for kw in virtual_keywords)

    try:
        import pyaudio
        pa = pyaudio.PyAudio()
        try:
            # 1. Check OS default input device first
            try:
                default_info = pa.get_default_input_device_info()
                def_idx = int(default_info.get("index", -1))
                def_name = str(default_info.get("name", ""))
                if def_idx >= 0 and not _is_virtual(def_name) and (
                    "mic" in def_name.lower() or "microfone" in def_name.lower()
                ):
                    return def_idx, def_name
            except Exception:
                default_info = None

            # 2. Scan MME (hostApi == 0) input devices for real microphones
            candidates = []
            for i in range(pa.get_device_count()):
                try:
                    info = pa.get_device_info_by_index(i)
                except Exception:
                    continue
                if info.get("maxInputChannels", 0) <= 0:
                    continue
                if info.get("hostApi", 0) != 0:
                    continue
                name = str(info.get("name", ""))
                if _is_virtual(name):
                    continue
                low = name.lower()
                # Score: prefer explicit "microphone"/"microfone" over generic "headset" hands-free AG
                score = 0
                if "microphone" in low or "microfone" in low:
                    score += 20
                elif "mic" in low:
                    score += 15
                if "realtek" in low or "usb" in low or "array" in low:
                    score += 5
                if "hands-free" in low or "headset" in low:
                    score -= 5
                candidates.append((score, i, name))

            if candidates:
                candidates.sort(key=lambda x: (-x[0], x[1]))
                best_score, best_idx, best_name = candidates[0]
                return best_idx, best_name

            if default_info is not None:
                return int(default_info["index"]), str(default_info.get("name", "default"))
        finally:
            pa.terminate()
    except Exception as e:
        return None, f"auto-detect fallback ({e})"

    return None, "system default"


def cmd_start_dictation(data):
    """Start microphone capture and speech-to-text transcription.

    Runs RealtimeSTT in a background thread.  Streams unsolicited JSON
    messages on stdout:
      {"type": "dictation_partial", "text": "..."}
      {"type": "dictation_final",   "text": "..."}
    """
    global _dictation_recorder, _dictation_thread, _dictation_active, _dictation_session_id

    if _dictation_active:
        return {"status": "already_running"}

    # Wait for old thread to finish (ensure microphone is released)
    if _dictation_thread and _dictation_thread.is_alive():
        _dictation_thread.join(timeout=5.0)

    _dictation_session_id += 1
    my_session = _dictation_session_id
    _dictation_active = True
    model_size = data.get("model", "base")
    language = data.get("language", "en")

    print(f"Starting dictation session #{my_session} (model={model_size}, lang={language})...", flush=True)

    def _run_dictation():
        global _dictation_recorder, _dictation_active
        # Suppress RealtimeSTT's internal print output ("speak now", model loading
        # messages, etc.) by redirecting this thread's sys.stdout to a dummy object.
        # Our own status messages use _daemon_write_json (writes to _daemon_stdout).
        class DummyStdout:
            def write(self, s): pass
            def flush(self): pass
            def close(self): pass
        
        original_stdout = sys.stdout
        sys.stdout = DummyStdout()
        try:
            import logging

            # Set up a dedicated file logger for dictation diagnostics.
            # logging.basicConfig is a no-op after the first call in a process,
            # so we configure the realtimestt logger's handler directly.
            dict_log_path = os.path.join(SCRIPT_DIR, 'dictation_debug.log')
            stt_logger = logging.getLogger("realtimestt")
            # Remove any existing handlers to avoid duplicates on restart
            stt_logger.handlers.clear()
            fh = logging.FileHandler(dict_log_path, mode='w', encoding='utf-8')
            fh.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
            stt_logger.addHandler(fh)
            stt_logger.setLevel(logging.DEBUG)  # file gets full detail
            stt_logger.propagate = False         # don't leak to stderr

            import torch.multiprocessing as tmp
            venv_site_packages = os.path.join(SCRIPT_DIR, ".venv", "Lib", "site-packages")
            if os.path.exists(venv_site_packages):
                current_pythonpath = os.environ.get("PYTHONPATH", "")
                if venv_site_packages not in current_pythonpath:
                    os.environ["PYTHONPATH"] = venv_site_packages + (os.pathsep + current_pythonpath if current_pythonpath else "")
            
            from RealtimeSTT import AudioToTextRecorder
            _daemon_write_json({"type": "debug", "msg": "RealtimeSTT imported"})

            # Track whether the user was muted when speech started.
            # This prevents dropping transcriptions captured while unmuted
            # just because the user clicked mute during the post-speech
            # silence / transcription delay.
            _muted_at_rec_start = [False]  # mutable container for closure

            def on_final(text):
                """Called by recorder.text() ONCE per utterance after
                speech→silence→transcription completes."""
                # File-based diagnostic logging (survives stdout redirection and thread issues)
                diag_path = os.path.join(SCRIPT_DIR, 'dictation_on_final.log')
                try:
                    with open(diag_path, 'a', encoding='utf-8') as diag:
                        import datetime
                        ts = datetime.datetime.now().isoformat()
                        diag.write(f"[{ts}] on_final called, text={repr(text)}, "
                                   f"session={my_session}, current_session={_dictation_session_id}, "
                                   f"active={_dictation_active}, muted_at_start={_muted_at_rec_start[0]}\n")
                except Exception:
                    pass
                # Guard: ignore results from a stale session (user stopped
                # and restarted dictation while transcription was in progress)
                if _dictation_session_id != my_session:
                    _daemon_write_json({"type": "debug", "msg": f"on_final DROPPED (stale session {my_session} vs current {_dictation_session_id})"})
                    return
                if not _dictation_active:
                    _daemon_write_json({"type": "debug", "msg": "on_final DROPPED (dictation inactive)"})
                    return
                _daemon_write_json({"type": "debug", "msg": f"on_final called: '{text[:80] if text else ''}', muted_at_start={_muted_at_rec_start[0]}"})
                if _muted_at_rec_start[0]:
                    return
                if text and text.strip():
                    _daemon_write_json({"type": "dictation_final", "text": text})

            def on_realtime_update(text):
                if _dictation_session_id != my_session:
                    return
                if _muted_at_rec_start[0]:
                    return
                if text and text.strip():
                    _daemon_write_json({"type": "dictation_partial", "text": text})

            def on_transcription_start(*args, **kwargs):
                """Fires when silence is detected and the main model starts processing."""
                if not _dictation_muted:
                    _daemon_write_json({"type": "dictation_transcribing"})

            def on_rec_start():
                _muted_at_rec_start[0] = _dictation_muted
                _daemon_write_json({"type": "debug", "msg": f"Recording started (VAD detected speech), muted={_muted_at_rec_start[0]}"})

            def on_rec_stop():
                _daemon_write_json({"type": "debug", "msg": "Recording stopped (silence detected)"})

            # Check if stop was called during model loading
            if not _dictation_active:
                _daemon_write_json({"type": "dictation_stopped"})
                return

            mic_idx, mic_name = _select_best_microphone_device_index(data.get("input_device_index"))
            _daemon_write_json({
                "type": "debug",
                "msg": f"Creating AudioToTextRecorder (model={model_size}, lang={language}, input_device_index={mic_idx} [{mic_name}])..."
            })
            recorder_kwargs = dict(
                model=model_size,
                language=language,
                device="cuda",
                compute_type="int8",
                spinner=False,
                level=logging.WARNING,  # WARNING — suppress noisy DEBUG on stderr
                enable_realtime_transcription=True,
                realtime_model_type="tiny",
                realtime_processing_pause=0.3,
                on_realtime_transcription_update=on_realtime_update,
                beam_size_realtime=1,
                post_speech_silence_duration=1.0,
                early_transcription_on_silence=0.3,
                beam_size=1,
                batch_size=4,
                initial_prompt="SuperCollider, Ndef, Pbindef, synth, filter, reverb, delay, frequency, amplitude",
                on_transcription_start=on_transcription_start,
                on_recording_start=on_rec_start,
                on_recording_stop=on_rec_stop,
                no_log_file=True,
            )
            if mic_idx is not None:
                recorder_kwargs["input_device_index"] = mic_idx
            recorder = AudioToTextRecorder(**recorder_kwargs)
            _daemon_write_json({"type": "debug", "msg": f"AudioToTextRecorder created (mic={mic_name}, index={mic_idx})"})

            # Check again after model loading (may take several seconds)
            if not _dictation_active:
                try:
                    recorder.stop()
                    recorder.shutdown()
                except Exception:
                    pass
                _daemon_write_json({"type": "dictation_stopped"})
                return

            _dictation_recorder = recorder
            _daemon_write_json({"type": "dictation_started"})

            # Blocking loop using the ORIGINAL working approach:
            # recorder.text(callback) blocks in wait_audio(), then calls
            # recorder.transcribe() in the current thread, passes the result
            # to on_final in a new thread, and returns None so the loop
            # re-arms for the next utterance immediately.
            while _dictation_active and _dictation_session_id == my_session:
                _daemon_write_json({"type": "dictation_listening"})
                recorder.text(on_final)
                if not _dictation_active:
                    break

        except Exception as e:
            import traceback
            _daemon_write_json({"type": "dictation_error", "error": str(e), "traceback": traceback.format_exc()})
        finally:
            sys.stdout = original_stdout
            _dictation_recorder = None
            # Only mark inactive if we are still the current session.
            # If a new session was started, _dictation_session_id will
            # have been incremented and _dictation_active re-set to True
            # — we must NOT clobber that.
            if _dictation_session_id == my_session:
                _dictation_active = False

    _dictation_thread = threading.Thread(target=_run_dictation, daemon=True)
    _dictation_thread.start()
    return {"status": "dictation_starting"}


def cmd_mute_dictation(data):
    global _dictation_muted
    _dictation_muted = data.get("muted", True)
    return {"status": "muted" if _dictation_muted else "unmuted"}

def cmd_stop_dictation(data):
    """Stop the active dictation session."""
    global _dictation_recorder, _dictation_thread, _dictation_active

    if not _dictation_active:
        return {"status": "not_running"}

    print("Stopping dictation...", flush=True)
    _dictation_active = False  # signal the thread to exit (works even during model load)

    recorder = _dictation_recorder
    _dictation_recorder = None

    if recorder is not None:
        try:
            recorder.stop()
            recorder.shutdown()
        except Exception as e:
            print(f"Dictation cleanup error: {e}", flush=True)

    _dictation_thread = None
    _daemon_write_json({"type": "dictation_stopped"})
    print("Dictation stopped.", flush=True)
    return {"status": "dictation_stopped"}


# Command dispatcher
COMMANDS = {
    "list_models": cmd_list_models,
    "list_openrouter_models": cmd_list_openrouter_models,
    "init_session": cmd_init_session,
    "generate_plan": cmd_generate_plan,
    "generate_code": cmd_generate_code,
    "custom_generate": cmd_custom_generate,
    "append": cmd_append,
    "cross_append": cmd_cross_append,
    "reset_composition_state": cmd_reset_composition_state,
    "rag_lookup": cmd_rag_lookup,
    "fix": cmd_fix,
    "remake": cmd_remake,
    "learn": cmd_learn,
    "add_kb": cmd_add_kb,
    "consume_kb": cmd_consume_kb,
    "prepare_rag_block": cmd_prepare_rag_block,
    "queue_rag_block": cmd_queue_rag_block,
    "save_session_log": cmd_save_session_log,
    "get_prompt_history": cmd_get_prompt_history,
    "get_session_stats": cmd_get_session_stats,
    "get_raw_session_log": cmd_get_raw_session_log,
    "import_raw_session_log": cmd_import_raw_session_log,
    "sync_to_drive": cmd_sync_to_drive,
    "start_dictation": cmd_start_dictation,
    "stop_dictation": cmd_stop_dictation,
    "mute_dictation": cmd_mute_dictation,
}


def main():
    if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except AttributeError:
            pass

    # Save original stdout for pure JSON output and redirect noisy prints to stderr
    original_stdout = sys.stdout
    sys.stdout = sys.stderr

    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: gui_backend.py <command> [json_input_file]"}), file=original_stdout)
        sys.exit(1)

    command = sys.argv[1].lower()

    if command not in COMMANDS:
        print(json.dumps({"error": f"Unknown command: {command}. Available: {list(COMMANDS.keys())}"}), file=original_stdout)
        sys.exit(1)

    # Load input data from JSON file or inline string
    data = {}
    if len(sys.argv) >= 3:
        input_arg = sys.argv[2]
        if input_arg.strip() == "{}" or (input_arg.strip().startswith("{") and input_arg.strip().endswith("}")):
            try:
                data = json.loads(input_arg)
            except Exception as e:
                print(json.dumps({"error": f"Failed to parse inline JSON: {e}"}), file=original_stdout)
                sys.exit(1)
        else:
            try:
                with open(input_arg, 'r', encoding='utf-8') as f:
                    data = json.load(f)
            except Exception as e:
                print(json.dumps({"error": f"Failed to read input file: {e}"}), file=original_stdout)
                sys.exit(1)

    try:
        result = COMMANDS[command](data)
        # Output JSON result to original stdout (the only channel the C++ UI reads)
        print(json.dumps(result, ensure_ascii=True), file=original_stdout)
    except Exception as e:
        import traceback
        print(json.dumps({
            "error": str(e),
            "traceback": traceback.format_exc()
        }), file=original_stdout)
        sys.exit(1)


def serve():
    """Run as a persistent daemon, reading JSON commands from stdin.

    The IDE starts this once via QProcess; it stays alive for the entire session.
    Protocol: newline-delimited JSON on stdin/stdout, progress on stderr.
    """
    global _daemon_stdout

    # CRITICAL: On Windows, when running under a proxy launcher (subprocess pipes),
    # we must explicitly mark standard handles as inheritable so that any grandchild
    # processes (like those spawned by torch.multiprocessing) can inherit them.
    # Otherwise, they get WinError 6 (invalid handle) and crash silently on print.
    import sys
    if sys.platform == "win32":
        try:
            import msvcrt, os
            for fd in (0, 1, 2):
                os.set_handle_inheritable(msvcrt.get_osfhandle(fd), True)
        except Exception as e:
            print(f"Warning: failed to make handles inheritable: {e}", file=sys.stderr)

    # Redirect prints to stderr, preserve stdout for JSON responses
    original_stdout = sys.stdout
    sys.stdout = sys.stderr
    _daemon_stdout = original_stdout  # expose for dictation thread

    if original_stdout.encoding and original_stdout.encoding.lower() != 'utf-8':
        try:
            original_stdout.reconfigure(encoding='utf-8')
        except AttributeError:
            pass

    print("Daemon starting: pre-loading dependencies...", flush=True)

    # Pre-import heavy dependencies (pay the cost once)
    print("Loading LLM engine...", flush=True)
    try:
        import llm_engine  # noqa: F401 — pre-import
        print("LLM engine loaded.", flush=True)
    except Exception as e:
        print(f"LLM engine pre-load failed: {e}", flush=True)

    print("Loading RAG engine...", flush=True)
    try:
        import rag_engine
        # Pre-warm the embedding model into RAM (this is the big cost: ~35s)
        rag_engine.get_embedding_function()
        print("RAG embeddings loaded.", flush=True)
    except Exception as e:
        print(f"RAG pre-warm skipped: {e}", flush=True)

    # Pre-load the dictation model into GPU memory
    print("Pre-loading dictation model (large-v3-turbo)...", flush=True)
    try:
        import io
        _real_stdout = sys.stdout
        sys.stdout = io.StringIO()
        try:
            import logging as _logging
            _stt_logger = _logging.getLogger("realtimestt")
            _stt_logger.setLevel(_logging.CRITICAL)
            _stt_logger.propagate = False

            from RealtimeSTT import AudioToTextRecorder
            # Warm up the dictation model and CUDA kernels
            _preload_mic_idx, _ = _select_best_microphone_device_index()
            _preload_kwargs = dict(
                model="large-v3-turbo",
                language="pt",
                device="cuda",
                compute_type="int8",
                use_microphone=True,  # Must be True to properly warm up audio workers
                spinner=False,
                level=_logging.CRITICAL,
                enable_realtime_transcription=True,
                realtime_model_type="tiny",
                realtime_processing_pause=0.3,
                beam_size_realtime=1,
                post_speech_silence_duration=1.0,
                early_transcription_on_silence=0.3,
                beam_size=1,
                batch_size=4,
                initial_prompt="SuperCollider, Ndef, Pbindef, synth, filter, reverb, delay, frequency, amplitude",
                no_log_file=True,
            )
            if _preload_mic_idx is not None:
                _preload_kwargs["input_device_index"] = _preload_mic_idx
            _preloaded = AudioToTextRecorder(**_preload_kwargs)
            # Immediately shut it down so the OS microphone indicator turns off
            try:
                _preloaded.shutdown()
            except Exception:
                pass
            _preloaded = None
            import gc; gc.collect()
        finally:
            sys.stdout = _real_stdout
        print("Dictation model pre-loaded and ready.", flush=True)
    except Exception as e:
        print(f"Dictation pre-load skipped: {e}", flush=True)
        import traceback; traceback.print_exc()

    # Signal readiness to the C++ side
    print("Daemon ready.", flush=True)
    original_stdout.write(json.dumps({"status": "ready"}) + "\n")
    original_stdout.flush()

    # Command loop — read one JSON line per command.
    # Control commands (cancel, dictation controls) execute immediately on the stdin thread
    # so they can interrupt or coexist with blocked LLM calls. All other commands execute
    # on a worker thread so stdin stays responsive.
    global _active_job_seq
    control_commands = {"start_dictation", "stop_dictation", "mute_dictation"}

    def _emit_daemon_json(payload):
        with _daemon_stdout_lock:
            try:
                original_stdout.write(json.dumps(payload, ensure_ascii=True) + "\n")
                original_stdout.flush()
                return True
            except (BrokenPipeError, OSError):
                return False

    def _run_daemon_job(cmd_name, req_data, ctx):
        _tls.cancel_ctx = ctx
        try:
            from llm_engine import RequestCancelledError
            try:
                res = COMMANDS[cmd_name](req_data)
            except RequestCancelledError:
                print(f"Command '{cmd_name}' cancelled (request_id={ctx.request_id}).", flush=True)
                return
            except Exception as exc:
                if ctx.cancel_event.is_set():
                    print(f"Command '{cmd_name}' aborted after cancel (request_id={ctx.request_id}): {exc}", flush=True)
                    return
                res = {"error": str(exc), "traceback": traceback.format_exc()}

            if ctx.cancel_event.is_set():
                print(f"Discarding result of cancelled command '{cmd_name}' (request_id={ctx.request_id}).", flush=True)
                return

            if ctx.request_id is not None and isinstance(res, dict):
                res["request_id"] = ctx.request_id
            _emit_daemon_json(res)
        finally:
            _tls.cancel_ctx = None
            with _active_requests_lock:
                _active_requests.pop(ctx.job_id, None)

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
        except json.JSONDecodeError as e:
            if not _emit_daemon_json({"error": f"Invalid JSON: {e}"}):
                break
            continue

        command = request.pop("command", "")
        request_id = request.pop("request_id", None)

        if command == "cancel":
            was_active = _cancel_active_requests(request_id)
            print(f"Cancel requested (request_id={request_id}, was_active={was_active}).", flush=True)
            if not _emit_daemon_json({
                "type": "command_cancelled",
                "request_id": request_id,
                "was_active": was_active,
            }):
                break
            continue

        if command in control_commands:
            try:
                result = COMMANDS[command](request)
            except Exception as e:
                result = {"error": str(e), "traceback": traceback.format_exc()}
            if request_id is not None and isinstance(result, dict):
                result["request_id"] = request_id
            if not _emit_daemon_json(result):
                break
            continue

        if command not in COMMANDS:
            err_res = {"error": f"Unknown command: {command}. Available: {list(COMMANDS.keys())}"}
            if request_id is not None:
                err_res["request_id"] = request_id
            if not _emit_daemon_json(err_res):
                break
            continue

        with _active_requests_lock:
            _active_job_seq += 1
            ctx = _CancellationContext(_active_job_seq, request_id=request_id)
            _active_requests[ctx.job_id] = ctx

        t = threading.Thread(
            target=_run_daemon_job,
            args=(command, request, ctx),
            daemon=True,
        )
        t.start()

    # Stdin closed (EOF / shutdown): abort any in-flight requests cleanly
    _cancel_active_requests(None)


def _bind_child_to_kill_on_close_job(proc):
    """On Windows, bind child `proc` to a Job Object with JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    so that if this launcher process is killed via QProcess::kill() (TerminateProcess),
    the OS kernel automatically terminates `__impl_serve__` and its descendants."""
    if sys.platform != "win32":
        return None
    try:
        import ctypes
        from ctypes import wintypes

        kernel32 = ctypes.windll.kernel32

        class JOBOBJECT_BASIC_LIMIT_INFORMATION(ctypes.Structure):
            _fields_ = [
                ("PerProcessUserTimeLimit", ctypes.c_int64),
                ("PerJobUserTimeLimit", ctypes.c_int64),
                ("LimitFlags", wintypes.DWORD),
                ("MinimumWorkingSetSize", ctypes.c_size_t),
                ("MaximumWorkingSetSize", ctypes.c_size_t),
                ("ActiveProcessLimit", wintypes.DWORD),
                ("Affinity", ctypes.c_size_t),
                ("PriorityClass", wintypes.DWORD),
                ("SchedulingClass", wintypes.DWORD),
            ]

        class IO_COUNTERS(ctypes.Structure):
            _fields_ = [
                ("ReadOperationCount", ctypes.c_uint64),
                ("WriteOperationCount", ctypes.c_uint64),
                ("OtherOperationCount", ctypes.c_uint64),
                ("ReadTransferCount", ctypes.c_uint64),
                ("WriteTransferCount", ctypes.c_uint64),
                ("OtherTransferCount", ctypes.c_uint64),
            ]

        class JOBOBJECT_EXTENDED_LIMIT_INFORMATION(ctypes.Structure):
            _fields_ = [
                ("BasicLimitInformation", JOBOBJECT_BASIC_LIMIT_INFORMATION),
                ("IoInfo", IO_COUNTERS),
                ("ProcessMemoryLimit", ctypes.c_size_t),
                ("JobMemoryLimit", ctypes.c_size_t),
                ("PeakProcessMemoryUsed", ctypes.c_size_t),
                ("PeakJobMemoryUsed", ctypes.c_size_t),
            ]

        JobObjectExtendedLimitInformation = 9
        JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000

        kernel32.CreateJobObjectW.restype = wintypes.HANDLE
        job = kernel32.CreateJobObjectW(None, None)
        if not job:
            return None

        info = JOBOBJECT_EXTENDED_LIMIT_INFORMATION()
        info.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
        res = kernel32.SetInformationJobObject(
            job,
            JobObjectExtendedLimitInformation,
            ctypes.byref(info),
            ctypes.sizeof(info),
        )
        if not res:
            kernel32.CloseHandle(job)
            return None

        kernel32.AssignProcessToJobObject(job, wintypes.HANDLE(int(proc._handle)))
        return job
    except Exception:
        return None


if __name__ == "__main__":
    import multiprocessing
    import multiprocessing.process
    if getattr(multiprocessing.process.current_process(), '_inheriting', False):
        pass
    else:
        # CRITICAL: torch.multiprocessing (used by RealtimeSTT) spawns child
        # processes via 'spawn' on Windows. Those children re-import __main__,
        # and without freeze_support() they would re-enter serve()/main().
        import torch.multiprocessing as _mp
        _mp.freeze_support()

        if len(sys.argv) >= 2 and sys.argv[1].lower() == "serve":
            # LAUNCHER MODE: Isolate the QProcess stdin pipe from Windows multiprocessing bugs.
            # Spawning multiprocessing workers directly from a QProcess pipe receiver
            # breaks the stdin handle (EOF) on Windows. We act as a thin proxy here.
            import subprocess
            import threading
            import os
            
            SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
            cmd = [sys.executable, __file__, "__impl_serve__"]
            env = os.environ.copy()
            env["PYTHONUNBUFFERED"] = "1"
            env["PYTHONUTF8"] = "1"  # Fix C++ faster-whisper UTF-8 -> cp1252 corruption
            
            p = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=env
            )
            _job_handle = _bind_child_to_kill_on_close_job(p)
            
            def forward_stdin():
                try:
                    while True:
                        line = sys.stdin.buffer.readline()
                        if not line: break
                        p.stdin.write(line)
                        p.stdin.flush()
                except Exception: pass
                finally:
                    try: p.stdin.close()
                    except Exception: pass
                    # When the parent IDE closes its stdin pipe (shutdown/exit),
                    # give the child daemon up to 2s to exit gracefully, then terminate it
                    # so it never lingers as an orphan in the background.
                    try:
                        p.wait(timeout=2.0)
                    except Exception:
                        try: p.kill()
                        except Exception: pass

            def forward_stdout():
                diag = open(os.path.join(SCRIPT_DIR, 'proxy_stdout.log'), 'wb')
                try:
                    while True:
                        chunk = p.stdout.read1(4096)
                        if not chunk: break
                        diag.write(b'CHUNK: ' + chunk + b'\n---\n')
                        diag.flush()
                        sys.stdout.buffer.write(chunk)
                        sys.stdout.buffer.flush()
                except Exception as e:
                    try:
                        diag.write(f'ERROR: {e}\n'.encode())
                        diag.flush()
                    except Exception:
                        pass
                    try: p.kill()
                    except Exception: pass
                finally:
                    diag.close()

            def forward_stderr():
                try:
                    while True:
                        chunk = p.stderr.read1(4096)
                        if not chunk: break
                        sys.stderr.buffer.write(chunk)
                        sys.stderr.buffer.flush()
                except Exception: pass

            t_in = threading.Thread(target=forward_stdin, daemon=True)
            t_out = threading.Thread(target=forward_stdout, daemon=True)
            t_err = threading.Thread(target=forward_stderr, daemon=True)
            
            t_in.start()
            t_out.start()
            t_err.start()
            
            p.wait()
            sys.exit(p.returncode)

        elif len(sys.argv) >= 2 and sys.argv[1] == "__impl_serve__":
            # ACTUAL DAEMON MODE
            serve()
        else:
            main()

