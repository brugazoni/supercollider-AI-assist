import os
import datetime
from typing import TypedDict, List, Optional, Annotated
from operator import add
from langgraph.graph import StateGraph, START, END
from langchain_core.runnables import RunnableConfig

import config
import utils
import rag_engine
from llm_engine import LLMClient

class AgentState(TypedDict):
    user_query: str
    system_instruction: str
    code_context: str
    composition_plan: Optional[str]
    plan_approved: Optional[bool]
    plan_feedback: Optional[str]
    current_code_block: str
    is_correct: bool
    user_abort: bool
    fix_mode: Optional[str]
    error_type: Optional[str]
    aesthetic_scope: Optional[str]
    bad_block: Optional[str]
    error_msg: Optional[str]
    correction_instruction: Optional[str]
    learning_summary: Optional[str]
    user_comments: Optional[str]
    wants_validation: Optional[bool]
    validation_report: Optional[str]
    interaction_log: Annotated[List[str], add]
    token_usage_log: Annotated[List[str], add]
    syntax_valid: Optional[bool]
    syntax_errors: Optional[str]
    syntax_check_attempts: int
    validation_prefs: dict

def load_resources_node(state: AgentState):
    print("[node] loading Vector RAG context")
    query = state["user_query"]
    
    #vector search
    code_context = rag_engine.query_index(state['user_query'], sources=["knowledge-base"])
    sys_instr = utils.load_system_instruction()

    # --- RAG Context Display ---
    import re
    chunks = re.findall(
        r"--- RETRIEVED (\d+) \(([^:]+): ([^)]+)\) ---\n(.*?)(?=\n--- RETRIEVED|\Z)",
        code_context, re.DOTALL
    )
    if chunks:
        print(f"\n  --- RAG Context ({len(chunks)} chunks) ---")
        for num, src_type, filename, content in chunks:
            print(f"    {num}. [{src_type:9s}] {filename:35s}  ({len(content.strip()):,} chars)")
        print()

    return {
        "system_instruction": sys_instr,
        "code_context": code_context,
        "interaction_log": [
            f"QUERY: {state['user_query']}\n"
            f"\n--- SYSTEM INSTRUCTION ---\n{sys_instr}\n"
            f"\n--- RAG CONTEXT ---\n{code_context}\n"
        ],
        "token_usage_log": [],
        "is_correct": False,
        "user_abort": False,
        "fix_mode": None,
        "error_type": None,
        "bad_block": None,
        "learning_summary": None,
        "user_comments": None,
        "syntax_valid": None,
        "syntax_errors": None,
        "syntax_check_attempts": 0,
        "validation_prefs": state.get('validation_prefs', {})
    }

def generate_plan_node(state: AgentState):
    print("-- [node] generate composition plan")
    client = LLMClient()
    
    plan_prompt_file = config.SYSTEM_TEXT_FILE_ONESHOT_PLAN
    if os.path.exists(plan_prompt_file):
        with open(plan_prompt_file, 'r', encoding='utf-8') as f:
            plan_sys = f.read().strip() + "\n\n=== BASE INSTRUCTIONS & SYSTEM IMPROVEMENTS ===\n" + state['system_instruction']
    else:
        plan_sys = state['system_instruction']

    prompt = f"User Request: {state['user_query']}\n\nTask: Generate a composition plan proportional to the request's length."
    if state.get('plan_feedback'):
        prompt += f"\n\nRefinement needed based on user feedback: {state['plan_feedback']}"

    plan, token_stats = client.generate(prompt, plan_sys)
    return {
        "composition_plan": plan,
        "token_usage_log": [f"plan: {token_stats}"],
        "interaction_log": [f"\n--- Generated Plan ---\n{plan}"]
    }

def review_plan_node(state: AgentState):
    print("\n" + "="*40)
    print("      COMPOSITION PLAN REVIEW")
    print("="*40)
    print(state.get('composition_plan', ''))
    print("="*40)
    
    while True:
        choice = input(">> Approve plan? (y)es / (n)o (provide feedback) / (s)top: ").strip().lower()
        if choice == 'y':
            return {"plan_approved": True, "plan_feedback": None, "interaction_log": ["\n--- PLAN APPROVED BY USER ---"]}
        elif choice == 's':
            print(" >> Stopping session.")
            return {"user_abort": True, "plan_approved": False, "interaction_log": ["\n--- SESSION ABORTED DURING PLAN REVIEW ---"]}
        elif choice == 'n':
            feedback = utils.get_multiline_input("Enter your feedback to adjust the plan:")
            return {"plan_approved": False, "plan_feedback": feedback, "interaction_log": [f"\n--- USER PLAN FEEDBACK ---\n{feedback}"]}
        else:
            print("Invalid input.")

def initial_generation_node(state: AgentState):
    print("-- [node] initial generation")
    client = LLMClient()

    prev_content = ""
    if os.path.exists(config.OUTPUT_FILE):
        with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
            prev_content = f.read()[-800:]
    
    gen_sys_file = config.SYSTEM_TEXT_FILE_ONESHOT_GEN
    if os.path.exists(gen_sys_file):
        with open(gen_sys_file, 'r', encoding='utf-8') as f:
            base_sys = f.read().strip() + "\n\n=== BASE INSTRUCTIONS & SYSTEM IMPROVEMENTS ===\n" + state['system_instruction']
    else:
        base_sys = state['system_instruction']
        
    full_system_prompt = f"{base_sys}\n\n=== Knowledge Base ===\n{state['code_context']}"
    
    plan_text = state.get('composition_plan', '')
    plan_section = f"\n\n=== APPROVED COMPOSITION PLAN ===\n{plan_text}" if plan_text else ""
    
    user_prompt = (
        f"Context: Working in '{config.OUTPUT_FILE}'. Previous code:\n{prev_content}{plan_section}\n\n"
        f"Request: {state['user_query']}\n"
        f"Output ONLY the valid SuperCollider code block executing the plan."
    )

    code, token_stats = client.generate(user_prompt, full_system_prompt)

    return {
        "current_code_block": code,
        "token_usage_log": [f"init: {token_stats}"],
        "interaction_log": [f"\\n--- Generated Code ---\\n{code}", f"[Stats] {token_stats}"]
    }

def _tier1_structural_check(code: str) -> tuple[bool, str]:
    errors = []
    in_string = False
    in_line_comment = False
    in_block_comment = False
    cleaned = []
    i = 0
    while i < len(code):
        ch = code[i]
        if in_line_comment:
            if ch == '\n': in_line_comment = False; cleaned.append(ch)
        elif in_block_comment:
            if ch == '*' and i + 1 < len(code) and code[i + 1] == '/': in_block_comment = False; i += 1
        elif in_string:
            if ch == '\\' and i + 1 < len(code): i += 1
            elif ch == '"': in_string = False
        else:
            if ch == '"': in_string = True
            elif ch == '/' and i + 1 < len(code):
                if code[i + 1] == '/': in_line_comment = True; i += 1
                elif code[i + 1] == '*': in_block_comment = True; i += 1
                else: cleaned.append(ch)
            else: cleaned.append(ch)
        i += 1

    cleaned_code = ''.join(cleaned)
    bracket_pairs = {'(': ')', '[': ']', '{': '}'}
    stack = []
    for ch in cleaned_code:
        if ch in bracket_pairs: stack.append(bracket_pairs[ch])
        elif ch in bracket_pairs.values():
            if not stack: errors.append(f"Unmatched closing bracket '{ch}'")
            elif stack[-1] != ch:
                errors.append(f"Bracket mismatch: expected '{stack[-1]}', found '{ch}'")
                stack.pop()
            else: stack.pop()
    if stack: errors.append(f"Unclosed brackets: {len(stack)} remaining ({', '.join(stack)})")

    content = cleaned_code.strip()
    if content in ('()', '(\n)'): errors.append("Block is empty (only parentheses)")
    elif not content: errors.append("Block is entirely empty")

    if errors: return False, '; '.join(errors)
    return True, ''

def syntax_validate_node(state: AgentState, config: RunnableConfig):
    print("-- [node] syntax validation")
    code = state['current_code_block']
    attempts = state.get('syntax_check_attempts', 0)

    is_valid, error_msg = _tier1_structural_check(code)
    if not is_valid:
        print(f"  ✗ Tier 1 structural check: FAILED — {error_msg}")
        return {
            "syntax_valid": False,
            "syntax_errors": error_msg,
            "syntax_check_attempts": attempts + 1,
            "interaction_log": [f"  > Syntax validation FAILED (Tier 1): {error_msg}"]
        }
    print("  ✓ Tier 1 structural check: PASSED")

    return {
        "syntax_valid": True,
        "syntax_errors": None,
        "interaction_log": ["  > Syntax validation PASSED (Tier 1)"]
    }

def syntax_correction_node(state: AgentState):
    attempts = state.get('syntax_check_attempts', 0)
    import config as cfg
    print(f"-- [node] syntax auto-correction (attempt {attempts}/{cfg.MAX_SYNTAX_RETRIES})")
    client = LLMClient()
    prompt = (
        f"You are fixing a SuperCollider syntax error.\\n\\n"
        f"CODE WITH ERROR:\\n{state['current_code_block']}\\n\\n"
        f"SYNTAX ERROR:\\n{state.get('syntax_errors', 'Unknown')}\\n\\n"
        f"RULES:\\n"
        f"- Fix ONLY the syntax issue described above\\n"
        f"- Keep the musical/audio intent identical\\n"
        f"- The block MUST be wrapped in top-level parentheses ( )\\n"
        f"- Return ONLY the corrected code, no explanations\\n"
    )
    corrected, token_stats = client.generate(prompt, state.get('system_instruction', ''))
    corrected = corrected.strip()
    if corrected.startswith('```'):
        lines = corrected.split('\\n')[1:]
        if lines and lines[-1].strip() == '```': lines = lines[:-1]
        corrected = '\\n'.join(lines).strip()
    return {
        "current_code_block": corrected,
        "token_usage_log": [f"syntax correction (attempt {attempts}): {token_stats}"],
        "interaction_log": [f"  > Syntax auto-correction applied (attempt {attempts})"]
    }

def llm_review_node(state: AgentState):
    print("--- [node] LLM Code Review ---")
    prefs = state.get("validation_prefs", {})
    import config as cfg
    provider = prefs.get("llm_provider", cfg.CURRENT_LLM_PROVIDER)
    scope = prefs.get("scope", "programmatic")
    with open("system-instruction-review.md", "r", encoding="utf-8") as f:
        sys_instr = f.read().strip()
    prompt = (
        f"USER GOAL: {state['user_query']}\\n"
        f"REVIEW SCOPE: {scope.upper()}\\n"
        f"GENERATED CODE:\\n{state['current_code_block']}\\n"
    )
    original_provider = cfg.CURRENT_LLM_PROVIDER
    cfg.CURRENT_LLM_PROVIDER = provider
    if provider == "gemini": cfg.CURRENT_MODEL_NAME = cfg.GEMINI_MODEL
    elif provider == "anthropic": cfg.CURRENT_MODEL_NAME = cfg.ANTHROPIC_MODEL
    elif provider == "openai": cfg.CURRENT_MODEL_NAME = cfg.OPENAI_MODEL
    
    client = LLMClient()
    result, token_info = client.generate(prompt, sys_instr)
    
    cfg.CURRENT_LLM_PROVIDER = original_provider
    if original_provider == "gemini": cfg.CURRENT_MODEL_NAME = cfg.GEMINI_MODEL
    elif original_provider == "anthropic": cfg.CURRENT_MODEL_NAME = cfg.ANTHROPIC_MODEL
    elif original_provider == "openai": cfg.CURRENT_MODEL_NAME = cfg.OPENAI_MODEL
    
    return {
        "current_code_block": result,
        "syntax_valid": True,
        "interaction_log": [f"  > LLM Review ({provider}):\\n{result}"],
        "token_usage_log": [f"LLM Review: {token_info}"]
    }

def write_output_node(state: AgentState):
    print("--- [node] writing code to output file ---")
    code = state['current_code_block']

    with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
        f.write("\n\n" + code)

    print(f"  > Written to {config.OUTPUT_FILE}")
    return {"interaction_log": [f"  > Code written to {config.OUTPUT_FILE}"]}

def verification_node(state: AgentState):
    print("\n" + "="*40)
    print("      VERIFICATION REQUIRED")
    print("="*40)
    
    while True:
        choice = input(">> Is code correct? (y)es / (n)o / (s)top & save: ").strip().lower()
        
        if choice == 'y':
            return {
                "is_correct": True,
                "user_abort": False,
                "interaction_log": ["\n--- STATUS: VALIDATED BY USER ---"]
            }
        
        elif choice == 's':
            print(" >> Stopping session.")
            return {
                "is_correct": False,
                "user_abort": True,
                "interaction_log": ["\n--- STATUS: SESSION ABORTED BY USER ---"]
            }
            
        elif choice == 'n':
            print("\n--- ISSUE TYPE ---")
            print("(P)rogrammatic: Errors, Crashes, Syntax issues.")
            print("(A)esthetic:    Sound is wrong, Style is off, but code runs.")
            e_type = input("Select Type (P/A): ").strip().upper()
            
            error_type = "programmatic" if e_type == 'P' else "aesthetic"
            
            if error_type == "programmatic":
                print("\n--- PROGRAMMATIC FIX METHOD ---")
                print("1. Auto-Fix (Internal Generator)")
                print("2. Manual Fix (You edit file)")
                print("3. External LLM (Paste from ChatGPT/Claude)")
                method = input("Select Method (1/2/3): ").strip()
                
                if method == '1': # Auto
                    bad_block = utils.get_multiline_input("Paste WRONG code block:")
                    error_msg = utils.get_multiline_input("Paste ERROR message:")
                    return {
                        "is_correct": False, "fix_mode": "auto", "error_type": "programmatic",
                        "bad_block": bad_block, "error_msg": error_msg,
                        "interaction_log": [f"\n--- ISSUE: PROGRAMMATIC (AUTO) ---\nERROR: {error_msg}"]
                    }
                elif method == '2': # Manual
                    return {"is_correct": False, "fix_mode": "manual", "error_type": "programmatic"}
                elif method == '3': # External
                    return {"is_correct": False, "fix_mode": "external", "error_type": "programmatic"}

            else: # Aesthetic
                print("\n--- AESTHETIC SCOPE ---")
                print("1. Regenerate Whole Patch (Start over/Rewrite)")
                print("2. Tweak Specific Part (Modify a parameter/block)")
                scope_in = input("Select Scope (1/2): ").strip()
                scope = "regenerate" if scope_in == '1' else "tweak"
                
                print(f"\n--- AESTHETIC FIX METHOD ({scope.upper()}) ---")
                print("1. Use Generator (Internal LLM)")
                print("2. External LLM Platform")
                print("3. Manual Tweak")
                method = input("Select Method (1/2/3): ").strip()
                
                if method == '1': # Auto
                    if scope == "regenerate":
                        instr = utils.get_multiline_input("Describe the desired sound/result:")
                        return {
                            "is_correct": False, "fix_mode": "auto", "error_type": "aesthetic", 
                            "aesthetic_scope": "regenerate", "correction_instruction": instr,
                            "bad_block": None, 
                            "interaction_log": [f"\n--- ISSUE: AESTHETIC REGEN (AUTO) ---\nGOAL: {instr}"]
                        }
                    else: # Tweak
                        bad_block = utils.get_multiline_input("Paste the Code Block to Change:")
                        instr = utils.get_multiline_input("How should this change?:")
                        return {
                            "is_correct": False, "fix_mode": "auto", "error_type": "aesthetic",
                            "aesthetic_scope": "tweak", "bad_block": bad_block, "correction_instruction": instr,
                            "interaction_log": [f"\n--- ISSUE: AESTHETIC TWEAK (AUTO) ---\nGOAL: {instr}"]
                        }
                        
                elif method == '2': # External
                    return {
                        "is_correct": False, "fix_mode": "external", "error_type": "aesthetic",
                        "aesthetic_scope": scope
                    }
                elif method == '3': # Manual
                    return {
                        "is_correct": False, "fix_mode": "manual", "error_type": "aesthetic",
                        "aesthetic_scope": scope
                    }
        else:
            print("Invalid input.")

def correction_auto_node(state: AgentState):
    print("--- [Node] Generating Auto-Correction ---")
    client = LLMClient()
    
    if state['error_type'] == 'programmatic':
        prompt = (
            f"You are fixing a SuperCollider bug.\n"
            f"BAD BLOCK:\n{state['bad_block']}\n"
            f"ERROR:\n{state['error_msg']}\n"
            f"INSTRUCTION: Return ONLY the corrected code block."
        )
        label = "PROGRAMMATIC FIX"

    elif state['error_type'] == 'aesthetic' and state['aesthetic_scope'] == 'tweak':
        prompt = (
            f"You are tweaking SuperCollider code for aesthetics.\n"
            f"TARGET BLOCK:\n{state['bad_block']}\n"
            f"USER GOAL:\n{state['correction_instruction']}\n"
            f"INSTRUCTION: Return ONLY the updated code block implementing this change."
        )
        label = "AESTHETIC TWEAK"

    elif state['error_type'] == 'aesthetic' and state['aesthetic_scope'] == 'regenerate':
        prompt = (
            f"You are rewriting a SuperCollider patch.\n"
            f"ORIGINAL REQUEST:\n{state['user_query']}\n"
            f"NEW AESTHETIC GOAL:\n{state['correction_instruction']}\n"
            f"INSTRUCTION: Output the COMPLETE valid SuperCollider code for the new patch."
        )
        label = "AESTHETIC REGEN"
        
    code, token_stats = client.generate(prompt, state['system_instruction'])
    
    return {
        "current_code_block": code,
        "token_usage_log": [f"Fix ({label}): {token_stats}"],
        "interaction_log": [
            f"\n--- AUTO GENERATION ({label}) ---\n{code}",
            f"[Stats] {token_stats}"
        ]
    }

def correction_manual_node(state: AgentState):
    print("--- [Node] Processing Manual Fix ---")
    print(f">> Please edit '{config.OUTPUT_FILE}' directly.")
    
    summary = utils.get_multiline_input("Describe your manual changes:")
    
    if os.path.exists(config.OUTPUT_FILE):
        with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
            latest_snippet = f.read()[-500:]
    else:
        latest_snippet = "(File not found)"

    return {
        "current_code_block": latest_snippet,
        "correction_instruction": summary,
        "interaction_log": [
            f"\n--- MANUAL FIX SUMMARY ({state['error_type']}) ---\nUser Note: {summary}",
            f"\n--- CODE STATE ---\n...{latest_snippet}"
        ]
    }

def correction_external_node(state: AgentState):
    print("--- [Node] Processing External LLM Fix ---")
    
    llm_name = input(">> Which External LLM are you using? (e.g., ChatGPT o1, Claude 3.5): ").strip()
    user_prompt = utils.get_multiline_input("Paste YOUR PROMPT (what you asked the external LLM):")
    llm_response = utils.get_multiline_input("Paste the RESPONSE (the code/solution):")
    
    print(f">> Ensure you have applied this fix to '{config.OUTPUT_FILE}'.")
    input("Press Enter to continue...")
    
    if os.path.exists(config.OUTPUT_FILE):
        with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
            latest_snippet = f.read()[-500:]
    else:
        latest_snippet = "(File not found)"

    ext_summary = f"[{llm_name}] Prompt: {user_prompt}\nResponse: {llm_response}"

    return {
        "current_code_block": latest_snippet,
        "correction_instruction": ext_summary,
        "interaction_log": [
            f"\n--- EXTERNAL LLM FIX ({state['error_type']}) ---",
            f"MODEL: {llm_name}",
            f"USER PROMPT:\n{user_prompt}",
            f"RESPONSE:\n{llm_response}",
            f"\n--- CODE STATE ---\n...{latest_snippet}"
        ]
    }

def apply_patch_node(state: AgentState):
    print("--- [Node] Patching Local File ---")
    
    if not os.path.exists(config.OUTPUT_FILE):
        return {} 

    if state.get('aesthetic_scope') == 'regenerate':
        with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
            f.write("\n\n// --- REGENERATED PATCH ---\n" + state['current_code_block'])
        print(" > Success: Regenerated patch appended.")
        return {}

    with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
        file_content = f.read()
    
    target = state['bad_block'].strip()
    replacement = state['current_code_block'].strip()
    
    if target in file_content:
        new_content = file_content.replace(target, replacement)
        with open(config.OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(" > Success: Code block updated.")
    else:
        print(" > WARNING: Exact match not found. Appending fix.")
        with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
            f.write("\n\n// --- CORRECTED BLOCK ---\n" + replacement)
            
    return {}

def summarize_improvements_node(state: AgentState):
    print("--- [Node] Summarizing Improvements ---")
    client = LLMClient()
    fix_mode = state.get('fix_mode', 'auto')

    if fix_mode == 'manual':
        prompt = (
            f"A user manually fixed a SuperCollider {state.get('error_type', 'unknown')} issue.\n"
            f"USER DESCRIPTION OF FIX:\n{state.get('correction_instruction', 'N/A')}\n"
            f"RESULTING CODE:\n{state['current_code_block']}\n\n"
            f"TASK: Write a concise technical takeaway (LESSON) on how to avoid this issue in the future."
        )
        label = "Manual Fix"
    elif fix_mode == 'external':
        prompt = (
            f"A user used an external LLM to fix a SuperCollider {state.get('error_type', 'unknown')} issue.\n"
            f"EXTERNAL LLM EXCHANGE:\n{state.get('correction_instruction', 'N/A')}\n"
            f"RESULTING CODE:\n{state['current_code_block']}\n\n"
            f"TASK: Write a concise technical takeaway (LESSON) on how to avoid this issue in the future."
        )
        label = "External Fix"
    elif state.get('error_type') == 'programmatic':
        prompt = (
            f"Analyze this SuperCollider bug fix.\n"
            f"MISTAKE:\n{state.get('bad_block', 'N/A')}\n"
            f"ERROR:\n{state.get('error_msg', 'N/A')}\n"
            f"FIX:\n{state['current_code_block']}\n\n"
            f"TASK: Write a concise technical takeaway (LESSON) on how to avoid this error."
        )
        label = "Auto Fix"
    else:
        prompt = (
            f"Analyze this SuperCollider aesthetic correction.\n"
            f"ORIGINAL CODE:\n{state.get('bad_block', 'N/A')}\n"
            f"USER GOAL:\n{state.get('correction_instruction', 'N/A')}\n"
            f"RESULT:\n{state['current_code_block']}\n\n"
            f"TASK: Write a concise aesthetic takeaway (LESSON) on what makes this sound better."
        )
        label = "Aesthetic Fix"
    
    summary, token_stats = client.generate(prompt)
    
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    entry = f"### Entry [{timestamp}] ({label})\n{summary}"
    utils.append_to_local_file(config.IMPROVEMENTS_FILE, entry)
    
    return {
        "learning_summary": summary,
        "token_usage_log": [f"Summary: {token_stats}"]
    }

def add_comments_node(state: AgentState):
    print("\n" + "="*40)
    print("      SESSION COMMENTS")
    print("="*40)
    comments = utils.get_multiline_input("Final notes (press Enter twice to skip):")
    return {"user_comments": comments if comments.strip() else "No comments."}

def summarize_comments_node(state: AgentState):
    comments = state.get('user_comments', '')
    if not comments or comments.strip() == 'No comments.':
        return {}
    
    print("--- [Node] Summarizing User Comments ---")
    client = LLMClient()
    prompt = (
        f"A user just finished a SuperCollider live coding session and left these comments:\n"
        f"SESSION QUERY: {state.get('user_query', 'N/A')}\n"
        f"COMMENTS:\n{comments}\n\n"
        f"TASK: Extract any actionable lessons for improving future SuperCollider code generation. "
        f"Write a concise takeaway (LESSON). If the comments contain no actionable feedback, "
        f"respond with exactly 'NO_LESSON'."
    )
    summary, token_stats = client.generate(prompt)
    
    if 'NO_LESSON' not in summary:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
        entry = f"### Entry [{timestamp}] (User Feedback)\n{summary}"
        utils.append_to_local_file(config.IMPROVEMENTS_FILE, entry)
        print(f"  > User feedback lesson saved.")
    else:
        print(f"  > No actionable lesson in comments.")
    
    return {"token_usage_log": [f"Comment Summary: {token_stats}"]}

def log_to_drive_node(state: AgentState):
    print("--- [Node] Logging to Google Drive ---")
    
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    status = "FAILED / ABORTED" if state['user_abort'] else "SUCCESS"

    full_log_text = (
        f"\n\n========================================\n"
        f"SESSION LOG: {timestamp}\n"
        f"STATUS: {status}\n"
        f"MODEL: {config.CURRENT_LLM_PROVIDER} / {config.CURRENT_MODEL_NAME}\n"
        f"========================================\n"
    )
    
    for entry in state['interaction_log']:
        full_log_text += f"{entry}\n"

    if state.get('learning_summary'):
        full_log_text += f"\n--- SYSTEM IMPROVEMENT NOTE ---\n{state['learning_summary']}\n"
    if state.get('user_comments'):
         full_log_text += f"\n--- USER COMMENTS ---\n{state['user_comments']}\n"

    # We keep the summary token table as well
    full_log_text += "\n--- TOKEN USAGE SUMMARY ---\n"
    for stat in state['token_usage_log']:
        full_log_text += f"- {stat}\n"
        
    final_code_content = "(Error reading file)"
    if os.path.exists(config.OUTPUT_FILE):
        try:
            with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
                final_code_content = f.read()
        except Exception:
            final_code_content = state['current_code_block'] 

    full_log_text += f"\n--- FINAL CODE STATE (Full File) ---\n{final_code_content}\n"
    full_log_text += f"========================================\n"

    success = utils.append_to_google_doc(full_log_text)
    print(" > Drive Upload Successful." if success else " > Drive Upload Failed.")
    return {}

# --- Graph Construction ---
def build_graph(validation_prefs=None):
    """Build the one-shot generation graph.
    
    Pipeline: load_resources → generate_plan → review_plan → generate_initial
              → write_output → add_comments → summarize_comments → log_to_drive → END
    
    All validation and correction loops have been removed.
    Code review is handled exclusively by the Fix tab in the IDE.
    """
    workflow = StateGraph(AgentState)

    # Nodes
    workflow.add_node("load_resources", load_resources_node)
    workflow.add_node("generate_plan", generate_plan_node)
    workflow.add_node("review_plan", review_plan_node)
    workflow.add_node("generate_initial", initial_generation_node)
    workflow.add_node("write_output", write_output_node)
    workflow.add_node("add_comments", add_comments_node)
    workflow.add_node("summarize_comments", summarize_comments_node)
    workflow.add_node("log_to_drive", log_to_drive_node)

    # Linear edges
    workflow.add_edge(START, "load_resources")
    workflow.add_edge("load_resources", "generate_plan")
    workflow.add_edge("generate_plan", "review_plan")

    def plan_router(state: AgentState):
        if state.get("user_abort"):
            return "add_comments"
        if state.get("plan_approved"):
            return "generate_initial"
        return "generate_plan"

    workflow.add_conditional_edges("review_plan", plan_router, {
        "generate_initial": "generate_initial",
        "generate_plan": "generate_plan",
        "add_comments": "add_comments"
    })

    # After generation, write directly — no validation loops
    workflow.add_edge("generate_initial", "write_output")
    workflow.add_edge("write_output", "add_comments")
    workflow.add_edge("add_comments", "summarize_comments")
    workflow.add_edge("summarize_comments", "log_to_drive")
    workflow.add_edge("log_to_drive", END)

    return workflow.compile()