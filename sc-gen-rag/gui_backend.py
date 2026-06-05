#!/usr/bin/env python3
"""
gui_backend.py — Unified CLI entry point for the SuperCollider AI Assist UI.

Called by the C++ IDE via QProcess:
    python gui_backend.py <command> <json_input_file>

Returns JSON on stdout. Logs all interactions to session_log.md.
"""

import sys
import os
import json
import datetime

# Ensure we're running from the sc-gen-rag directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(SCRIPT_DIR)

import config
import utils

# Lazy imports for heavy dependencies (rag_engine, llm_engine)
# These are imported inside the functions that need them
# to avoid blocking simple commands like list_models


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

    print(f"Writing to {target_display}...", flush=True)
    # Write to target file
    _write_scd("\n\n" + code, filepath=active_file, mode='a')

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

    print(f"Writing to {target_display}...", flush=True)
    _write_scd("\n\n" + code, filepath=active_file, mode='a')

    utils.append_to_session_log("custom_generate", full_sys if full_sys else "N/A", user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "last_stats": stats_dict}


def cmd_append(data):
    """Append a new block to the composition (incremental mode)."""
    prompt = data.get("prompt", "")
    composition_state = data.get("composition_state", "")
    model_key = data.get("model", "")

    print("Loading AI models...", flush=True)
    provider, model_name = _resolve_model(model_key)
    from llm_engine import LLMClient
    client = LLMClient(provider=provider, model_name=model_name)

    # Build system prompt from explicit sys_msgs sent by the UI
    full_sys = _build_system_prompt(data)

    # RAG context
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

    # Include file content based on toggle
    active_file = data.get("active_file")
    use_code_context = data.get("use_code_context", False)
    if use_code_context:
        prev_content = _read_scd(active_file)
    else:
        prev_content = _read_scd(active_file)[-2000:]
        
    prev_section = f"\n\n=== PREVIOUS CODE ===\n{prev_content}" if prev_content else ""

    user_prompt = (
        f"User Request: {prompt}\n"
        f"{comp_section}"
        f"{prev_section}\n\n"
        f"Generate ONLY the SuperCollider code for this single block. "
        f"Do NOT repeat any existing instruments or sequences."
    )

    print("Generating next block...", flush=True)
    temperature = data.get("temperature", config.AVAILABLE_MODELS.get(model_key, {}).get("default_temp", 0.7))
    thinking_budget = data.get("thinking", 0)
    code, stats_dict = client.generate(user_prompt, full_sys, temperature=temperature, thinking_budget=thinking_budget)

    target_display = active_file if active_file else config.OUTPUT_FILE
    print(f"Writing to {target_display}...", flush=True)
    # Append to target file
    _write_scd("\n\n" + code, filepath=active_file, mode='a')

    print("Updating composition state...", flush=True)
    # Update composition state via LLM (lean prompt — no RAG, no improvements)
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
    # State tracking doesn't need high temperature, override to 0.0 for predictability
    new_state, state_stats = client.generate(state_prompt, state_sys, temperature=0.0)

    # Merge state-tracking token usage into the main stats so session analytics are accurate
    stats_dict["in_tokens"] = stats_dict.get("in_tokens", 0) + state_stats.get("in_tokens", 0)
    stats_dict["out_tokens"] = stats_dict.get("out_tokens", 0) + state_stats.get("out_tokens", 0)
    stats_dict["time_s"] = round(stats_dict.get("time_s", 0) + state_stats.get("time_s", 0), 2)
    stats_dict["cost"] = round(stats_dict.get("cost", 0) + state_stats.get("cost", 0), 5)

    utils.append_to_session_log("append", full_sys, user_prompt, code, stats_dict, f"{provider}/{model_name}", active_file=active_file)
    return {"code": code, "new_composition_state": new_state.strip(), "last_stats": stats_dict}


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
    target_display = active_file if active_file else config.OUTPUT_FILE
    print(f"Applying fix to {target_display}...", flush=True)
    # Substitute block in target file
    file_content = _read_scd(active_file)
    if block.strip() in file_content:
        new_content = file_content.replace(block.strip(), code.strip(), 1)
        _write_scd(new_content, filepath=active_file, mode='w')

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
    target_display = active_file if active_file else config.OUTPUT_FILE
    print(f"Writing to {target_display}...", flush=True)
    # Substitute block in target file
    file_content = _read_scd(active_file)
    if block.strip() in file_content:
        new_content = file_content.replace(block.strip(), code.strip(), 1)
        _write_scd(new_content, filepath=active_file, mode='w')

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
        print(json.dumps(result, ensure_ascii=False), file=original_stdout)
    except Exception as e:
        import traceback
        print(json.dumps({
            "error": str(e),
            "traceback": traceback.format_exc()
        }), file=original_stdout)
        sys.exit(1)


if __name__ == "__main__":
    main()
