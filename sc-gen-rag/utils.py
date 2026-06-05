import os
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import config

def get_docs_service():
    creds = None
    if os.path.exists(config.TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(config.TOKEN_FILE, config.DOCS_SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            try:
                creds.refresh(Request())
            except Exception as e:
                print(f"Token refresh failed ({e}). Triggering re-authentication...")
                if os.path.exists(config.TOKEN_FILE):
                    os.remove(config.TOKEN_FILE)
                creds = None

        if not creds or not creds.valid:
            if not os.path.exists(config.CREDENTIALS_FILE):
                print(f"Error: {config.CREDENTIALS_FILE} not found.")
                return None
            flow = InstalledAppFlow.from_client_secrets_file(config.CREDENTIALS_FILE, config.DOCS_SCOPES)
            creds = flow.run_local_server(port=0)

        with open(config.TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())

    return build('docs', 'v1', credentials=creds)

def append_to_google_doc(text_content):
    service = get_docs_service()
    if not service: return False
    try:
        requests = [{'insertText': {'text': text_content, 'endOfSegmentLocation': {'segmentId': ''}}}]
        service.documents().batchUpdate(documentId=config.DOCUMENT_ID, body={'requests': requests}).execute()
        return True
    except Exception as e:
        print(f"Error writing to Google Doc: {e}")
        return False

def append_to_local_file(filename, text_content):
    try:
        prefix = "\n\n" if os.path.exists(filename) and os.path.getsize(filename) > 0 else ""
        with open(filename, 'a', encoding='utf-8') as f:
            f.write(prefix + text_content)
        return True
    except Exception as e:
        print(f"Error writing to local file {filename}: {e}")
        return False

def get_multiline_input(prompt_text):
    print(f"\n{prompt_text}\n" + "-"*40 + "\n(Press Enter twice to finish)\n" + "-"*40)
    lines = []
    empty_count = 0
    while True:
        try:
            line = input()
            if line.strip() == '':
                empty_count += 1
                if empty_count >= 2:
                    break
                lines.append(line)
            else:
                empty_count = 0
                lines.append(line)
        except EOFError: break
    # Strip trailing empty lines
    while lines and lines[-1].strip() == '':
        lines.pop()
    return "\n".join(lines)

def load_system_instruction():
    if os.path.exists(config.SYSTEM_TEXT_FILE):
        with open(config.SYSTEM_TEXT_FILE, 'r', encoding='utf-8') as f:
            sys_instr = f.read().strip()
    else:
        sys_instr = "You are an expert SuperCollider programmer."

    if os.path.exists(config.IMPROVEMENTS_FILE):
        try:
            with open(config.IMPROVEMENTS_FILE, 'r', encoding='utf-8') as f:
                improvements = f.read().strip()
                if improvements:
                    sys_instr += f"\n\n=== SYSTEM IMPROVEMENTS ===\n{improvements}"
                    print(f" > Loaded system improvements.")
        except Exception: pass
    return sys_instr

LOGS_DIR = "use-logs"
SESSION_MAP_FILE = ".session_map.json"
ACTIVE_SESSION_POINTER = ".active_session.txt"
# Prefix for file-specific stats: .stats_<log_filename_no_ext>.json
STATS_PREFIX = ".stats_"

def init_session_log(active_file=None):
    """Bootstraps a session log for a specific file or as a default.
    Returns the log filename.
    """
    import datetime
    import os
    import json
    
    os.makedirs(LOGS_DIR, exist_ok=True)
    now = datetime.datetime.now()
    
    # Generate unique log name
    base_name = now.strftime("%Y-%m-%d_%H-%M")
    final_name = base_name + ".md"
    counter = 1
    while os.path.exists(os.path.join(LOGS_DIR, final_name)):
        final_name = f"{base_name}_{counter}.md"
        counter += 1
    
    final_path = os.path.join(LOGS_DIR, final_name)
    
    # If active_file is provided, map it
    if active_file:
        _update_session_map(active_file, final_name)
    
    # Update the global "current" pointer for backward compatibility/legacy calls
    pointer_path = os.path.join(LOGS_DIR, ACTIVE_SESSION_POINTER)
    with open(pointer_path, 'w', encoding='utf-8') as f:
        f.write(final_name)
        
    # Append a boot header
    header = f"# SuperCollider AI Session Log\n"
    if active_file:
        header += f"*Target File: {active_file}*\n"
    header += f"*Session started: {now.strftime('%Y-%m-%d %H:%M:%S')}*\n---\n"
    append_to_local_file(final_path, header)
    
    return final_name


def _update_session_map(scd_path, log_name):
    import json
    map_path = os.path.join(LOGS_DIR, SESSION_MAP_FILE)
    session_map = {}
    if os.path.exists(map_path):
        try:
            with open(map_path, 'r', encoding='utf-8') as f:
                session_map = json.load(f)
        except Exception: pass
    
    session_map[scd_path] = log_name
    with open(map_path, 'w', encoding='utf-8') as f:
        json.dump(session_map, f, indent=2)


def _get_active_session_log_path(active_file=None):
    """Resolves the session log path for the given file or the global active one."""
    import os
    import json
    
    if active_file:
        map_path = os.path.join(LOGS_DIR, SESSION_MAP_FILE)
        if os.path.exists(map_path):
            try:
                with open(map_path, 'r', encoding='utf-8') as f:
                    session_map = json.load(f)
                    if active_file in session_map:
                        return os.path.join(LOGS_DIR, session_map[active_file])
            except Exception: pass
        
        # Not mapped. Check if we have a dangling active session to claim for this newly saved file
        pointer_path = os.path.join(LOGS_DIR, ACTIVE_SESSION_POINTER)
        if os.path.exists(pointer_path):
            with open(pointer_path, 'r', encoding='utf-8') as f:
                name = f.read().strip()
                if name:
                    # Claim this session for the new file
                    _update_session_map(active_file, name)
                    return os.path.join(LOGS_DIR, name)
        
        # If not mapped and no active pointer, initialize it
        return os.path.join(LOGS_DIR, init_session_log(active_file))

    # Legacy: use the global pointer
    pointer_path = os.path.join(LOGS_DIR, ACTIVE_SESSION_POINTER)
    if os.path.exists(pointer_path):
        with open(pointer_path, 'r', encoding='utf-8') as f:
            name = f.read().strip()
            if name:
                return os.path.join(LOGS_DIR, name)
                
    # Ultimate fallback
    return os.path.join(LOGS_DIR, init_session_log())


def _sync_completed_logs_to_google_docs():
    """Sync any finalized session log files to Google Docs."""
    import os
    synced_tracker = os.path.join(LOGS_DIR, ".synced_logs")
    synced_set = set()
    if os.path.exists(synced_tracker):
        with open(synced_tracker, 'r', encoding='utf-8') as f:
            synced_set = set(line.strip() for line in f if line.strip())

    # Protect the currently active session log file pointer from being prematurely synced
    active_filename = None
    pointer_path = os.path.join(LOGS_DIR, ACTIVE_SESSION_POINTER)
    if os.path.exists(pointer_path):
        with open(pointer_path, 'r', encoding='utf-8') as f:
            active_filename = f.read().strip()

    all_logs = sorted([f for f in os.listdir(LOGS_DIR)
                       if f.endswith(".md") and not f.startswith(".")])
    for log_file in all_logs:
        # Don't sync the currently open live session log
        if log_file == active_filename:
            continue
            
        if log_file not in synced_set:
            log_path = os.path.join(LOGS_DIR, log_file)
            try:
                with open(log_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "USE CASE:" not in content:
                    print(f"Skipping empty session log ({log_file}).", flush=True)
                    synced_set.add(log_file)
                    with open(synced_tracker, 'a', encoding='utf-8') as f:
                        f.write(log_file + "\n")
                    continue

                header = (
                    f"\n\n{'=' * 50}\n"
                    f"SESSION LOG: {log_file.replace('.md', '')}\n"
                    f"{'=' * 50}\n\n"
                )
                print(f"Syncing session log ({log_file}) to Google Docs...", flush=True)
                if append_to_google_doc(header + content):
                    synced_set.add(log_file)
                    with open(synced_tracker, 'a', encoding='utf-8') as f:
                        f.write(log_file + "\n")
            except Exception as e:
                print(f"Failed to sync {log_file}: {e}", flush=True)


def append_to_session_log(command, system_prompt, user_prompt, response, stats_dict, model="", active_file=None):
    """Append contextually to a file-bound session log."""
    import datetime
    import os
    import json
    
    log_path = _get_active_session_log_path(active_file)
    log_filename = os.path.basename(log_path)
    
    now = datetime.datetime.now()
    timestamp = now.strftime("%Y-%m-%d %H:%M:%S")

    # Update session stats (file-bound)
    stats_name = STATS_PREFIX + log_filename.replace(".md", ".json")
    stats_path = os.path.join(LOGS_DIR, stats_name)
    
    session_stats = {"total_cost": 0.0, "total_time": 0.0, "total_energy": 0.0, "total_gwp": 0.0, "total_adpe": 0.0, "total_pe": 0.0, "total_wcf": 0.0, "providers": {}}
    if os.path.exists(stats_path):
        try:
            with open(stats_path, 'r', encoding='utf-8') as f:
                session_stats = json.load(f)
        except Exception: pass
            
    in_tok = stats_dict.get('in_tokens', 0)
    out_tok = stats_dict.get('out_tokens', 0)
    time_s = stats_dict.get('time_s', 0.0)
    cost = stats_dict.get('cost', 0.0)
    
    # EcoLogits and Context metrics
    energy = stats_dict.get('energy_kwh', 0.0)
    ctx_limit = stats_dict.get('context_limit', 0)
    
    # Fallback flags
    cost_fb = stats_dict.get('cost_fb', False)
    ctx_fb = stats_dict.get('context_fb', False)
    eco_fb = stats_dict.get('eco_fb', False)

    session_stats["total_cost"] = session_stats.get("total_cost", 0.0) + cost
    session_stats["total_time"] = session_stats.get("total_time", 0.0) + time_s
    session_stats["total_energy"] = session_stats.get("total_energy", 0.0) + energy
    session_stats["total_gwp"] = session_stats.get("total_gwp", 0.0) + stats_dict.get('gwp_kg', 0.0)
    session_stats["total_adpe"] = session_stats.get("total_adpe", 0.0) + stats_dict.get('adpe_kg', 0.0)
    session_stats["total_pe"] = session_stats.get("total_pe", 0.0) + stats_dict.get('pe_mj', 0.0)
    session_stats["total_wcf"] = session_stats.get("total_wcf", 0.0) + stats_dict.get('wcf_m3', 0.0)
    
    # Track if ANY call in the session used a fallback
    session_stats["any_cost_fb"] = session_stats.get("any_cost_fb", False) or cost_fb
    session_stats["any_ctx_fb"] = session_stats.get("any_ctx_fb", False) or ctx_fb
    session_stats["any_eco_fb"] = session_stats.get("any_eco_fb", False) or eco_fb
    
    provider_key = model if model else "unknown"
    if "providers" not in session_stats:
        session_stats["providers"] = {}

    if provider_key not in session_stats["providers"]:
        session_stats["providers"][provider_key] = {
            "calls": 0, "cost": 0.0, "time": 0.0, "in_tokens": 0, "out_tokens": 0, 
            "energy_kwh": 0.0, "gwp_kg": 0.0, "adpe_kg": 0.0, "pe_mj": 0.0, "wcf_m3": 0.0,
            "context_limit": ctx_limit,
            "cost_fb": False, "context_fb": False, "eco_fb": False
        }
        
    p_stats = session_stats["providers"][provider_key]
    p_stats["calls"] = p_stats.get("calls", 0) + 1
    p_stats["cost"] = p_stats.get("cost", 0.0) + cost
    p_stats["time"] = p_stats.get("time", 0.0) + time_s
    p_stats["in_tokens"] = p_stats.get("in_tokens", 0) + in_tok
    p_stats["out_tokens"] = p_stats.get("out_tokens", 0) + out_tok
    p_stats["energy_kwh"] = p_stats.get("energy_kwh", 0.0) + energy
    p_stats["gwp_kg"] = p_stats.get("gwp_kg", 0.0) + stats_dict.get('gwp_kg', 0.0)
    p_stats["adpe_kg"] = p_stats.get("adpe_kg", 0.0) + stats_dict.get('adpe_kg', 0.0)
    p_stats["pe_mj"] = p_stats.get("pe_mj", 0.0) + stats_dict.get('pe_mj', 0.0)
    p_stats["wcf_m3"] = p_stats.get("wcf_m3", 0.0) + stats_dict.get('wcf_m3', 0.0)
    p_stats["context_limit"] = ctx_limit
    
    # Group-level fallback tracking
    p_stats["cost_fb"] = p_stats.get("cost_fb", False) or cost_fb
    p_stats["context_fb"] = p_stats.get("context_fb", False) or ctx_fb
    p_stats["eco_fb"] = p_stats.get("eco_fb", False) or eco_fb

    try:
        with open(stats_path, 'w', encoding='utf-8') as f:
            json.dump(session_stats, f, indent=2)
    except Exception as e:
        print(f"Failed to write session stats: {e}")

    # Log format with EcoLogits
    impact_info = ""
    if 'energy_kwh' in stats_dict:
        impact_info = (
            f"**Environmental Impact:**\n"
            f"- Energy: {stats_dict['energy_kwh']:.6f} kWh\n"
            f"- GWP: {stats_dict.get('gwp_kg', 0):.6f} kgCO2eq\n"
            f"- ADPE: {stats_dict.get('adpe_kg', 0):.6e} kgSbeq\n"
            f"- PE: {stats_dict.get('pe_mj', 0):.4f} MJ\n"
            f"- WCF: {stats_dict.get('wcf_m3', 0):.6f} m3\n"
            f"*(Note: {stats_dict.get('environmental_estimated_flag', 'Measured')})*\n\n"
        )

    ctx_usage = stats_dict.get('context_usage_pct', 0.0)
    ctx_info = f"\n**Context Window:** {in_tok + out_tok} / {ctx_limit} ({ctx_usage:.2f}%)\n"

    temp = stats_dict.get('temperature', 0.7)
    token_info = f"In {in_tok} / Out {out_tok}"
    cost_info = f"${cost:.5f} | {time_s}s | Temp: {temp}"

    kb_section = ""
    clean_sys = system_prompt
    if "=== Knowledge Base ===" in system_prompt:
        parts = system_prompt.split("=== Knowledge Base ===")
        clean_sys = parts[0].strip()
        kb_section = f"**Knowledge Base RAG Used:**\n```text\n{parts[1].strip()}\n```\n\n"

    entry = (
        f"\n## [{timestamp}] USE CASE: {command.upper()} | MODEL: {model}\n"
        f"**Cost & Token Usage:** {token_info} | {cost_info}"
        f"{ctx_info}\n"
        f"{impact_info}"
        f"**System Guidance:**\n```text\n{clean_sys}\n```\n\n"
        f"{kb_section}"
        f"**User Prompt & Subtext:**\n```text\n{user_prompt}\n```\n\n"
        f"**Final Answer/Output:**\n```supercollider\n{response}\n```\n\n---\n"
    )
    append_to_local_file(log_path, entry)
    return True


def get_session_stats_summary(active_file=None):
    """Reads file-specific stats and returns the stats dict."""
    import os
    import json
    
    log_path = _get_active_session_log_path(active_file)
    log_filename = os.path.basename(log_path)
    stats_name = STATS_PREFIX + log_filename.replace(".md", ".json")
    stats_path = os.path.join(LOGS_DIR, stats_name)
    
    if not os.path.exists(stats_path):
        return {"total_cost": 0.0, "total_time": 0.0, "total_energy": 0.0, "total_gwp": 0.0, "total_adpe": 0.0, "total_pe": 0.0, "total_wcf": 0.0, "providers": {}}
    
    try:
        with open(stats_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception:
        return {"total_cost": 0.0, "total_time": 0.0, "total_energy": 0.0, "total_gwp": 0.0, "total_adpe": 0.0, "total_pe": 0.0, "total_wcf": 0.0, "providers": {}}


def finalize_session_log(process_fixes):
    """Teardown phase explicitly called when closing SC IDE.
    Syncs completed logs to Google Drive.
    """
    import os
    
    active_filename = None
    pointer_path = os.path.join(LOGS_DIR, ACTIVE_SESSION_POINTER)
    if os.path.exists(pointer_path):
        with open(pointer_path, 'r', encoding='utf-8') as f:
            active_filename = f.read().strip()
        # The session has ended, destroy the pointer
        os.remove(pointer_path)
        
    print(f"Closed session log {active_filename}", flush=True)

    # Sync any completed (non-current) logs to Google Docs
    _sync_completed_logs_to_google_doc_service = get_docs_service()
    if _sync_completed_logs_to_google_doc_service:
        _sync_completed_logs_to_google_docs()
    
    return active_filename


def get_session_history_entries(active_file=None):
    """Parse the file-bound session log and return UI-friendly log entries."""
    import re
    import os
    log_path = _get_active_session_log_path(active_file)
    if not os.path.exists(log_path):
        return []

    entries = []
    try:
        with open(log_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Split by entry headers — more robust than '---' since responses can contain '---'
        raw_blocks = re.split(r'(?=\n## \[)', content)
        for block in raw_blocks:
            if not block.strip():
                continue

            # We are parsing:
            # ## [YYYY-MM-DD HH:MM:SS] USE CASE: COMMAND | MODEL: model_name
            header_match = re.search(r"## \[(.*?)\] USE CASE: (.*?) \| MODEL: (.*)", block)
            if not header_match:
                continue

            timestamp = header_match.group(1).strip()
            command = header_match.group(2).strip()
            model = header_match.group(3).strip()

            # Parse user prompt
            user_prompt = ""
            user_match = re.search(r"\*\*User Prompt & Subtext:\*\*\n```text\n(.*?)\n```", block, re.DOTALL)
            if user_match:
                user_prompt = user_match.group(1).strip()

            # Parse response — accept any code fence language (plan text is not supercollider)
            response = ""
            resp_match = re.search(r"\*\*Final Answer/Output:\*\*\n```\w*\n(.*?)\n```", block, re.DOTALL)
            if resp_match:
                response = resp_match.group(1).strip()

            if user_prompt or response:
                entries.append({
                    "timestamp": timestamp,
                    "command": command,
                    "model": model,
                    "user_prompt": user_prompt,
                    "response": response
                })
    except Exception as e:
        print(f"Error parsing session history: {e}")

    return entries