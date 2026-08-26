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

# Daemon-mode stdout reference — set by serve(), used by dictation thread
# to stream unsolicited JSON lines (partials/finals) back to the C++ side.
_daemon_stdout = None
_daemon_stdout_lock = threading.Lock()

# Dictation state
_dictation_recorder = None
_dictation_thread = None
_dictation_active = False  # guards against race between start/stop during model load
_dictation_muted = False   # skips transcription final output when muted
_dictation_session_id = 0  # incremented on each start; prevents stale callbacks


def _resolve_model(model_key):
    """Resolve a model key like 'gemini/gemini-2.5-flash' to (provider, model_name)."""
    if not model_key:
        return config.CURRENT_LLM_PROVIDER, config.CURRENT_MODEL_NAME
    entry = config.AVAILABLE_MODELS.get(model_key)
    if entry:
        return entry["provider"], entry["model"]
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


def _build_system_prompt(data):
    """Build a system prompt from an explicit list of system message file paths.
    
    Reads the 'sys_msgs' key from data (a list of relative paths under system_messages/),
    loads each file, and concatenates them with separator markers.
    This replaces the old _get_base_system_instruction() and hidden improvements injection.
    """
    venv_python = os.path.join(SCRIPT_DIR, ".venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        sys.executable = venv_python
        sys._base_executable = venv_python
        multiprocessing.set_executable(venv_python)
    sys_msgs = data.get("sys_msgs", [])
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


def cmd_generate_plan(data):
    """Generate a composition plan from a user prompt.
    
    Uses lean system prompt (no RAG, no improvements) since this is a
    planning/structural stage, not code generation.
    """
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)
    mode = data.get("mode", "generate")

    include_ending = data.get("include_ending", True)
    if mode == "design":
        ending_instruction = "The design plan should configure an external synthesize patch."
    elif mode == "compose":
        ending_instruction = "The composition MUST include an explicit ending where all Tdefs conclude, all Ndefs are cleared with a long fade, and the server is left silent. Use absolute timestamps throughout."
    else:
        if include_ending:
            ending_instruction = "The composition plan MUST include an explicit ending or 'Outro' where all active instruments and sequences are cleanly faded out and stopped."
        else:
            ending_instruction = "The composition plan MUST NOT include an ending or Outro. The final section must remain actively looping and open-ended so it can be built upon later. Do NOT stop or clear the instruments at the end."

    user_prompt = f"User Request: {prompt}\n\nTask: Generate a composition plan proportional to the request's length. {ending_instruction}"

    print("Generating composition plan...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    plan, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)
    
    active_file = data.get("active_file")
    utils.append_to_session_log("generate_plan", full_sys, user_prompt, plan, stats_dict, f"{provider}/{model_name}", active_file=active_file)

    return {"plan": plan, "last_stats": stats_dict}


def cmd_generate_code(data):
    """Generate code from an approved plan."""
    plan = data.get("plan", "")
    prompt = data.get("prompt", "")
    use_kb = data.get("use_kb", False)
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)
    mode = data.get("mode", "generate")

    # Optionally add RAG context
    if use_kb:
        try:
            print("Searching knowledge base...", flush=True)
            import rag_engine
            code_context = rag_engine.query_index(prompt, sources=["knowledge-base"])
            full_sys += f"\n\n=== Knowledge Base ===\n{code_context}"
        except Exception:
            pass

    # Previous file content for context
    active_file = data.get("active_file")
    prev_content = _read_scd(active_file)[-800:] if active_file and os.path.exists(active_file) else ""

    include_ending = data.get("include_ending", True)
    if mode == "design":
        ending_instruction = "\nEnsure the final block is a valid, runnable sequence defining the synthesizer logic properly."
    elif mode == "compose":
        ending_instruction = "\nThe Tdef script MUST conclude by stopping all Pbindefs, clearing all Ndefs with a long fade, and leaving the server silent. Include s.makeGui; at the end."
    else:
        if include_ending:
            ending_instruction = "\nEnsure the final block cleanly ends the piece according to the plan."
        else:
            ending_instruction = "\nCRITICAL: Do not clear or free the Ndefs at the end. The generated code MUST remain running indefinitely."

    plan_section = f"\n\n=== APPROVED COMPOSITION PLAN ===\n{plan}" if plan else ""
    target_display = active_file if active_file else config.OUTPUT_FILE
    user_prompt = (
        f"Context: Working in '{target_display}'. Previous code:\n{prev_content}{plan_section}\n\n"
        f"Request: {prompt}\n"
        f"Output ONLY the valid SuperCollider code block executing the plan. {ending_instruction}"
    )

    print("Generating SuperCollider code...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # inserts the code into the document via QTextCursor and handles saving.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher.

    utils.append_to_session_log("generate_code", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "last_stats": stats_dict}


def cmd_custom_generate(data):
    """Generate code dynamically driven by explicitly selected system messages."""
    prompt = data.get("prompt", "")
    use_kb = data.get("use_kb", False)
    model_key = data.get("model", "")
    sys_msgs = data.get("sys_msgs", [])

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

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


def cmd_append(data):
    """Append a new block to the composition (incremental mode)."""
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")
    active_file = data.get("active_file", "")

    # Use daemon's cached composition state if available, otherwise fall back to C++ state
    if active_file and active_file in _composition_states:
        composition_state = _composition_states[active_file]
    else:
        composition_state = data.get("composition_state", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

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

    # Build user prompt with composition context
    comp_section = f"\n\n=== CURRENT COMPOSITION STATE ===\n{composition_state}" if composition_state else \
        "\n\n=== CURRENT COMPOSITION STATE ===\n(Empty — this is the first block)"

    # Always include up to 2000 characters of the active file as fallback context
    prev_content = _read_scd(active_file)[-2000:] if active_file else ""
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
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    if not code or not code.strip():
        print(f"WARNING: LLM returned empty code for prompt: '{prompt[:100]}'", flush=True)
        print(f"  model={model_key}", flush=True)
        print(f"  user_prompt length={len(user_prompt)}, sys_prompt length={len(full_sys)}", flush=True)

    # NOTE: We do NOT write to the file here. The C++ side (AiAssistWidget)
    # inserts the code into the document via QTextCursor and handles saving.
    # Writing here would cause duplicate code and a race condition with
    # QFileSystemWatcher that breaks the auto-execute flow.

    # Fire composition state update in a background thread so the code
    # is returned to the IDE immediately without waiting for the 2nd LLM call.
    def _bg_update_state():
        try:
            state_prompt = (
                f"You are tracking the state of a SuperCollider live coding composition.\n\n"
                f"PREVIOUS STATE:\n{composition_state if composition_state else '(empty)'}\n\n"
                f"NEW CODE BLOCK:\n{code}\n\n"
                f"TASK: Output the UPDATED composition state. List ALL currently active elements:\n"
                f"- Active Ndefs (name + key arguments)\n"
                f"- Active Pbindefs (name + key parameters)\n"
                f"- Effect slots assigned (which Ndef, which slot index, what effect)\n"
                f"- Current wetness levels if set\n\n"
                f"If a fade_out block cleared an instrument, REMOVE it from the state.\n"
                f"Be concise. Use a structured list format."
            )
            state_sys = "You are a concise SuperCollider composition state tracker. Output only structured state lists."
            new_state, state_stats = client.generate(state_prompt, state_sys, temperature=0.0)
            _composition_states[active_file] = new_state.strip()
            print(f"Background state update complete for {active_file}", flush=True)
        except Exception as e:
            print(f"Background state update failed: {e}", flush=True)

    if code and code.strip():
        threading.Thread(target=_bg_update_state, daemon=True).start()

    utils.append_to_session_log("append", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "new_composition_state": composition_state, "last_stats": stats_dict}


def cmd_fix(data):
    """Fix a code block using its stack trace."""
    block = data.get("block", "")
    error = data.get("error", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

    user_prompt = (
        f"CODE BLOCK:\n{block}\n\n"
        f"ERROR / STACK TRACE:\n{error}\n\n"
        f"Fix the code. Return ONLY the corrected code block."
    )

    print("Analyzing trace and generating fix...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

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
    return {"code": code, "last_stats": stats_dict}


def cmd_remake(data):
    """Rework a code block based on aesthetic direction."""
    block = data.get("block", "")
    prompt = data.get("prompt", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

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
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

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
        active_file = data.get("active_file")
        utils.append_to_session_log("consume_kb", "N/A", "Re-ingesting knowledge base", "Knowledge base rebuilt successfully", {}, "", active_file=active_file)
        return {"status": "ok"}
    except Exception as e:
        error_msg = str(e)
        active_file = data.get("active_file")
        utils.append_to_session_log("consume_kb", "N/A", "Re-ingesting knowledge base", f"ERROR: {error_msg}", {}, "", active_file=active_file)
        return {"status": "error", "error": error_msg}


def cmd_init_session(data):
    """Bootstraps a precise timestamped log to trace a new session dynamically."""
    active_file = data.get("active_file")
    final_name = utils.init_session_log(active_file=active_file)
    return {"status": "ok", "filename": final_name}


def cmd_save_session_log(data):
    """Finalize the current session log on IDE shutdown and conditionally process offline learnings."""
    process_fixes = data.get("process_fixes", False)
    result = utils.finalize_session_log(process_fixes)
    
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

    if result:
        return {"status": "ok", "filename": result}
    return {"status": "ok", "filename": None, "message": "No session data to save."}


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
                """Fires continuously during speech with partial results.
                Only used for status feedback — NOT for enqueuing blocks."""
                if _dictation_muted:
                    return  # suppress even status feedback while muted
                if text and text.strip():
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

            _daemon_write_json({"type": "debug", "msg": f"Creating AudioToTextRecorder (model={model_size}, lang={language})..."})
            recorder = AudioToTextRecorder(
                model=model_size,
                language=language,
                compute_type="int8",   # int8 quantization — runs efficiently on CPU without GPU
                spinner=False,
                level=logging.WARNING,  # WARNING — suppress noisy DEBUG on stderr
                enable_realtime_transcription=True,
                post_speech_silence_duration=1.5,
                on_realtime_transcription_update=on_realtime_update,
                on_recording_start=on_rec_start,
                on_recording_stop=on_rec_stop,
            )
            _daemon_write_json({"type": "debug", "msg": "AudioToTextRecorder created"})

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
    "init_session": cmd_init_session,
    "generate_plan": cmd_generate_plan,
    "generate_code": cmd_generate_code,
    "custom_generate": cmd_custom_generate,
    "append": cmd_append,
    "fix": cmd_fix,
    "remake": cmd_remake,
    "learn": cmd_learn,
    "add_kb": cmd_add_kb,
    "consume_kb": cmd_consume_kb,
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

    # Signal readiness to the C++ side
    print("Daemon ready.", flush=True)
    original_stdout.write(json.dumps({"status": "ready"}) + "\n")
    original_stdout.flush()

    # Command loop — read one JSON line per command, write one JSON line per response
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
        except json.JSONDecodeError as e:
            original_stdout.write(json.dumps({"error": f"Invalid JSON: {e}"}) + "\n")
            original_stdout.flush()
            continue

        command = request.pop("command", "")

        if command not in COMMANDS:
            result = {"error": f"Unknown command: {command}. Available: {list(COMMANDS.keys())}"}
        else:
            try:
                result = COMMANDS[command](request)
            except Exception as e:
                import traceback
                result = {"error": str(e), "traceback": traceback.format_exc()}

        # CRITICAL: ensure_ascii=True MUST be used on Windows.
        # If False, Python's stdout pipe encoding (often cp1252) will corrupt
        # non-ASCII characters (like pt-BR accents in LLM-generated comments)
        # into invalid bytes, causing QJsonDocument::fromJson on the C++ side
        # to silently fail — resulting in empty code being delivered to the IDE.
        #
        # CRITICAL: Must acquire _daemon_stdout_lock because the dictation
        # background thread also writes to original_stdout (via _daemon_write_json).
        # Without the lock, the large JSON response from a command and a small
        # dictation_transcribing message can interleave at the byte level,
        # producing garbled JSON that the C++ side silently drops.
        with _daemon_stdout_lock:
            original_stdout.write(json.dumps(result, ensure_ascii=True) + "\n")
            original_stdout.flush()


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
                    except: pass

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
                    diag.write(f'ERROR: {e}\n'.encode())
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
