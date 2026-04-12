import os
import datetime
from typing import TypedDict, List, Optional, Annotated
from operator import add
from langgraph.graph import StateGraph, START, END
from langchain_core.runnables import RunnableConfig

import config
import utils
import rag_engine
import re
from llm_engine import LLMClient


class IncrementalState(TypedDict):
    user_query: str
    system_instruction: str
    code_context: str
    current_code_block: str
    block_number: int
    block_type: str  # "init" | "add_instrument" | "add_effects" | "tweak" | "fade_out"
    composition_history: str  # Running summary of active Ndefs/Pbindefs/effects
    previous_blocks: Annotated[List[str], add]  # Code of all prior blocks
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
    interaction_log: Annotated[List[str], add]
    token_usage_log: Annotated[List[str], add]
    # Auto-execute fields
    auto_execute: bool
    syntax_valid: Optional[bool]
    syntax_errors: Optional[str]
    syntax_check_attempts: int
    validation_prefs: dict


# ---------------------------------------------------------------------------
# Nodes
# ---------------------------------------------------------------------------

def load_resources_node(state: IncrementalState):
    """Load system instruction (base + incremental addendum) and RAG context."""
    print("[node] loading resources for incremental block")

    # Load base system instruction + improvements
    sys_instr = utils.load_system_instruction()

    # Append incremental addendum
    incr_path = config.SYSTEM_TEXT_FILE_INCREMENTAL
    if os.path.exists(incr_path):
        with open(incr_path, 'r', encoding='utf-8') as f:
            sys_instr += "\n\n" + f.read().strip()

    # RAG retrieval
    code_context = rag_engine.query_index(state['user_query'], sources=["knowledge-base"])

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
            f"BLOCK {state['block_number']} QUERY: {state['user_query']}\n"
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
    }


def classify_block_node(state: IncrementalState):
    """Use the LLM to classify the user prompt into a block type."""
    print("-- [node] classifying block type")

    # If block_type was pre-set (e.g., ending blocks forced to fade_out), skip classification
    if state.get('block_type'):
        block_type = state['block_type']
        print(f"  > Block type (pre-set): {block_type}")
        return {
            "block_type": block_type,
            "token_usage_log": [],
            "interaction_log": [f"BLOCK TYPE (pre-set): {block_type}"],
        }

    client = LLMClient()

    prompt = (
        f"You are classifying a SuperCollider live coding user request into one block type.\n\n"
        f"BLOCK NUMBER: {state['block_number']}\n"
        f"USER REQUEST: {state['user_query']}\n"
        f"CURRENT COMPOSITION STATE:\n{state.get('composition_history', '(empty — first block)')}\n\n"
        f"BLOCK TYPES:\n"
        f"- init: First block — create initial instruments and sequences\n"
        f"- add_instrument: Add a new Ndef+Pbindef to the composition\n"
        f"- add_effects: Attach or modify effect chains on existing Ndefs\n"
        f"- tweak: Change parameters of existing instruments, sequences, or effects\n"
        f"- fade_out: Stop/clear one or more instruments\n\n"
        f"Rules:\n"
        f"- If block_number is 1, the type MUST be 'init'\n"
        f"- If the user wants to add a NEW sound source, use 'add_instrument'\n"
        f"- If the user wants to change how something sounds (params, rhythm, wetness), use 'tweak'\n"
        f"- If the user wants to add/change reverb/delay/distortion slots, use 'add_effects'\n"
        f"- If the user wants to stop/remove/fade something, use 'fade_out'\n\n"
        f"Output ONLY the block type name, nothing else."
    )

    block_type, token_stats = client.generate(prompt)
    block_type = block_type.strip().lower().replace("'", "").replace('"', '')

    # Validate
    valid_types = {"init", "add_instrument", "add_effects", "tweak", "fade_out"}
    if block_type not in valid_types:
        print(f"  ⚠ Unknown block type '{block_type}', defaulting to 'tweak'")
        block_type = "tweak"

    if state['block_number'] == 1:
        block_type = "init"

    print(f"  > Block type: {block_type}")

    return {
        "block_type": block_type,
        "token_usage_log": [f"classify: {token_stats}"],
        "interaction_log": [f"BLOCK TYPE: {block_type}"],
    }


def generate_block_node(state: IncrementalState):
    """Generate code for a single composition block."""
    print(f"-- [node] generating block {state['block_number']} ({state['block_type']})")
    client = LLMClient()

    # Build the full system prompt
    full_system_prompt = f"{state['system_instruction']}\n\n=== Knowledge Base ===\n{state['code_context']}"

    # Build the user prompt with composition context
    composition_ctx = state.get('composition_history', '')
    if composition_ctx:
        composition_section = f"\n\n=== CURRENT COMPOSITION STATE ===\n{composition_ctx}"
    else:
        composition_section = "\n\n=== CURRENT COMPOSITION STATE ===\n(Empty — this is the first block)"

    # Include recent previous blocks for direct code context
    prev_blocks = state.get('previous_blocks', [])
    recent = prev_blocks[-config.MAX_HISTORY_BLOCKS:] if prev_blocks else []
    if recent:
        prev_code_section = "\n\n=== PREVIOUS BLOCKS (most recent) ===\n" + "\n\n".join(recent)
    else:
        prev_code_section = ""

    user_prompt = (
        f"Block {state['block_number']} — Type: {state['block_type']}\n"
        f"User Request: {state['user_query']}\n"
        f"{composition_section}"
        f"{prev_code_section}\n\n"
        f"Generate ONLY the SuperCollider code for this single block. "
        f"Do NOT repeat any existing instruments or sequences."
    )

    code, token_stats = client.generate(user_prompt, full_system_prompt)

    return {
        "current_code_block": code,
        "token_usage_log": [f"generate block {state['block_number']}: {token_stats}"],
        "interaction_log": [f"\n--- Generated Block {state['block_number']} ---\n{code}", f"[Stats] {token_stats}"],
    }


def extract_new_block_node(state: IncrementalState):
    """Ensure the generated block is properly wrapped in parentheses for SC region evaluation."""
    print("-- [node] extracting and wrapping new block")
    code = state['current_code_block'].strip()

    # Strip markdown fences if the LLM included them
    if code.startswith('```'):
        lines = code.split('\n')
        # Remove first line (```supercollider or similar)
        lines = lines[1:]
        # Remove last line if it's closing fence
        if lines and lines[-1].strip() == '```':
            lines = lines[:-1]
        code = '\n'.join(lines).strip()

    # Check if the block already contains evaluation regions `( ... )`.
    # If the LLM provided regions natively, we do not want to force-wrap the entire file into one giant region.
    has_region = bool(re.search(r'(?m)^\s*\(', code))
    if not has_region:
        code = '(\n' + code + '\n)'

    # When the LLM generates multiple disconnected regions:
    #   ( ... ) \n\n ( ... )
    # This evaluates perfectly in the IDE iteratively, but Sclang's `.load` compiler 
    # strictly requires semicolons between top-level expressions.
    # We automatically inject missing semicolons between adjacent blocks.
    code = re.sub(r'(?m)^(\s*\))(\s*\n\s*//.*\n|\s*\n)*(\s*\()', r'\1;\2\3', code)

    return {
        "current_code_block": code,
        "syntax_check_attempts": 0,
        "interaction_log": [f"  > Block extracted and wrapped ({len(code)} chars)"],
    }


def _tier1_structural_check(code: str) -> tuple[bool, str]:
    """Fast local structural validation — no LLM, no subprocess.
    Returns (is_valid, error_message).
    """
    errors = []

    # 1. Strip comments and strings for bracket analysis
    in_string = False
    in_line_comment = False
    in_block_comment = False
    cleaned = []
    i = 0
    while i < len(code):
        ch = code[i]
        if in_line_comment:
            if ch == '\n':
                in_line_comment = False
                cleaned.append(ch)
        elif in_block_comment:
            if ch == '*' and i + 1 < len(code) and code[i + 1] == '/':
                in_block_comment = False
                i += 1  # skip the '/'
        elif in_string:
            if ch == '\\' and i + 1 < len(code):
                i += 1  # skip escaped char
            elif ch == '"':
                in_string = False
        else:
            if ch == '"':
                in_string = True
            elif ch == '/' and i + 1 < len(code):
                if code[i + 1] == '/':
                    in_line_comment = True
                    i += 1
                elif code[i + 1] == '*':
                    in_block_comment = True
                    i += 1
                else:
                    cleaned.append(ch)
            else:
                cleaned.append(ch)
        i += 1

    cleaned_code = ''.join(cleaned)

    # 2. Bracket balancing
    bracket_pairs = {'(': ')', '[': ']', '{': '}'}
    stack = []
    for ch in cleaned_code:
        if ch in bracket_pairs:
            stack.append(bracket_pairs[ch])
        elif ch in bracket_pairs.values():
            if not stack:
                errors.append(f"Unmatched closing bracket '{ch}'")
            elif stack[-1] != ch:
                errors.append(f"Bracket mismatch: expected '{stack[-1]}', found '{ch}'")
                stack.pop()
            else:
                stack.pop()
    if stack:
        errors.append(f"Unclosed brackets: {len(stack)} remaining ({', '.join(stack)})")

    # 3. Empty block detection
    content = cleaned_code.strip()
    if content in ('()', '(\n)'):
        errors.append("Block is empty (only parentheses)")
    elif not content:
        errors.append("Block is entirely empty")

    if errors:
        return False, '; '.join(errors)
    return True, ''


def syntax_validate_node(state: IncrementalState, config: RunnableConfig):
    """Validate the current code block using structural checks (Tier 1)."""
    print("-- [node] syntax validation")
    code = state['current_code_block']
    attempts = state.get('syntax_check_attempts', 0)

    # --- Tier 1: Fast local structural checks ---
    is_valid, error_msg = _tier1_structural_check(code)

    if not is_valid:
        print(f"  ✗ Tier 1 structural check: FAILED — {error_msg}")
        return {
            "syntax_valid": False,
            "syntax_errors": error_msg,
            "syntax_check_attempts": attempts + 1,
            "interaction_log": [f"  > Syntax validation FAILED (Tier 1): {error_msg}"],
        }
    print("  ✓ Tier 1 structural check: PASSED")

    return {
        "syntax_valid": True,
        "syntax_errors": None,
        "interaction_log": ["  > Syntax validation PASSED (Tier 1)"],
    }


def syntax_correction_node(state: IncrementalState):
    """Auto-correct syntax errors using the LLM."""
    attempts = state.get('syntax_check_attempts', 0)
    print(f"-- [node] syntax auto-correction (attempt {attempts}/{config.MAX_SYNTAX_RETRIES})")
    client = LLMClient()

    prompt = (
        f"You are fixing a SuperCollider syntax error.\n\n"
        f"CODE WITH ERROR:\n{state['current_code_block']}\n\n"
        f"SYNTAX ERROR:\n{state.get('syntax_errors', 'Unknown')}\n\n"
        f"RULES:\n"
        f"- Fix ONLY the syntax issue described above\n"
        f"- Keep the musical/audio intent identical\n"
        f"- The block MUST be wrapped in top-level parentheses ( )\n"
        f"- Return ONLY the corrected code, no explanations\n"
    )

    corrected, token_stats = client.generate(prompt, state.get('system_instruction', ''))
    corrected = corrected.strip()

    # Strip markdown fences if present
    if corrected.startswith('```'):
        lines = corrected.split('\n')
        lines = lines[1:]
        if lines and lines[-1].strip() == '```':
            lines = lines[:-1]
        corrected = '\n'.join(lines).strip()

    return {
        "current_code_block": corrected,
        "token_usage_log": [f"syntax correction (attempt {attempts}): {token_stats}"],
        "interaction_log": [f"  > Syntax auto-correction applied (attempt {attempts})"],
    }


def write_block_node(state: IncrementalState):
    """Append the generated block to the output file with a separator."""
    print(f"--- [node] writing block {state['block_number']} to output file ---")
    code = state['current_code_block']
    block_num = state['block_number']
    block_type = state['block_type']

    separator = f"\n\n// ============ BLOCK {block_num}: {block_type.upper()} ============\n"

    with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
        f.write(separator + code)

    print(f"  > Block {block_num} written to {config.OUTPUT_FILE}")
    return {"interaction_log": [f"  > Block {block_num} written to {config.OUTPUT_FILE}"]}


def llm_review_node(state: IncrementalState):
    """Review and correct the generated code block using a dedicated LLM before evaluation."""
    print("--- [node] LLM Code Review ---")
    prefs = state.get("validation_prefs", {})
    provider = prefs.get("llm_provider", config.CURRENT_LLM_PROVIDER)
    scope = prefs.get("scope", "programmatic")
    
    # Load system instruction
    with open("system-instruction-review.md", "r", encoding="utf-8") as f:
        sys_instr = f.read().strip()
    
    prompt = (
        f"USER GOAL: {state['user_query']}\n"
        f"REVIEW SCOPE: {scope.upper()}\n"
        f"GENERATED CODE:\n{state['current_code_block']}\n"
    )
    
    # Temporarily override LLMClient config
    original_provider = config.CURRENT_LLM_PROVIDER
    config.CURRENT_LLM_PROVIDER = provider
    if provider == "gemini": config.CURRENT_MODEL_NAME = config.GEMINI_MODEL
    elif provider == "anthropic": config.CURRENT_MODEL_NAME = config.ANTHROPIC_MODEL
    elif provider == "openai": config.CURRENT_MODEL_NAME = config.OPENAI_MODEL
    
    client = LLMClient()
    result, token_info = client.generate(prompt, sys_instr)
    
    # Restore defaults
    config.CURRENT_LLM_PROVIDER = original_provider
    if original_provider == "gemini": config.CURRENT_MODEL_NAME = config.GEMINI_MODEL
    elif original_provider == "anthropic": config.CURRENT_MODEL_NAME = config.ANTHROPIC_MODEL
    elif original_provider == "openai": config.CURRENT_MODEL_NAME = config.OPENAI_MODEL
    
    # Use re to strip wrap if LLM responded with it, so extract_new_block structure passes natively or force it.
    # LLM instruction mandates returning strict `( ... )` enclosed blocks.
    
    return {
        "current_code_block": result,
        "syntax_valid": True, # Assume LLM fixed it to pass directly to output
        "interaction_log": [f"  > LLM Review ({provider}):\n{result}"],
        "token_usage_log": [f"LLM Review: {token_info}"]
    }


def update_composition_node(state: IncrementalState):
    """Use LLM to extract/update the running composition state from the generated block."""
    print("--- [node] updating composition state ---")
    client = LLMClient()

    current_history = state.get('composition_history', '')

    prompt = (
        f"You are tracking the state of a SuperCollider live coding composition.\n\n"
        f"PREVIOUS STATE:\n{current_history if current_history else '(empty)'}\n\n"
        f"NEW CODE BLOCK (Block {state['block_number']}, type: {state['block_type']}):\n"
        f"{state['current_code_block']}\n\n"
        f"TASK: Output the UPDATED composition state. List ALL currently active elements:\n"
        f"- Active Ndefs (name + key arguments)\n"
        f"- Active Pbindefs (name + key parameters)\n"
        f"- Effect slots assigned (which Ndef, which slot index, what effect)\n"
        f"- Current wetness levels if set\n\n"
        f"If a fade_out block cleared an instrument, REMOVE it from the state.\n"
        f"Be concise. Use a structured list format."
    )

    updated_history, token_stats = client.generate(prompt)

    return {
        "composition_history": updated_history.strip(),
        "previous_blocks": [f"// Block {state['block_number']} ({state['block_type']})\n{state['current_code_block']}"],
        "token_usage_log": [f"update state: {token_stats}"],
    }


def verify_block_node(state: IncrementalState):
    """Interactive verification — identical to one-shot verification_node."""
    print("\n" + "=" * 40)
    print(f"      BLOCK {state['block_number']} VERIFICATION")
    print("=" * 40)

    while True:
        choice = input(">> Is this block correct? (y)es / (n)o / (s)top & save: ").strip().lower()

        if choice == 'y':
            return {
                "is_correct": True,
                "user_abort": False,
                "interaction_log": [f"\n--- BLOCK {state['block_number']}: VALIDATED BY USER ---"],
            }

        elif choice == 's':
            print(" >> Stopping session.")
            return {
                "is_correct": False,
                "user_abort": True,
                "interaction_log": [f"\n--- BLOCK {state['block_number']}: SESSION ABORTED BY USER ---"],
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

                if method == '1':  # Auto
                    bad_block = utils.get_multiline_input("Paste WRONG code block:")
                    error_msg = utils.get_multiline_input("Paste ERROR message:")
                    return {
                        "is_correct": False, "fix_mode": "auto", "error_type": "programmatic",
                        "bad_block": bad_block, "error_msg": error_msg,
                        "interaction_log": [f"\n--- ISSUE: PROGRAMMATIC (AUTO) ---\nERROR: {error_msg}"]
                    }
                elif method == '2':  # Manual
                    return {"is_correct": False, "fix_mode": "manual", "error_type": "programmatic"}
                elif method == '3':  # External
                    return {"is_correct": False, "fix_mode": "external", "error_type": "programmatic"}

            else:  # Aesthetic
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

                if method == '1':  # Auto
                    if scope == "regenerate":
                        instr = utils.get_multiline_input("Describe the desired sound/result:")
                        return {
                            "is_correct": False, "fix_mode": "auto", "error_type": "aesthetic",
                            "aesthetic_scope": "regenerate", "correction_instruction": instr,
                            "bad_block": None,
                            "interaction_log": [f"\n--- ISSUE: AESTHETIC REGEN (AUTO) ---\nGOAL: {instr}"]
                        }
                    else:  # Tweak
                        bad_block = utils.get_multiline_input("Paste the Code Block to Change:")
                        instr = utils.get_multiline_input("How should this change?:")
                        return {
                            "is_correct": False, "fix_mode": "auto", "error_type": "aesthetic",
                            "aesthetic_scope": "tweak", "bad_block": bad_block, "correction_instruction": instr,
                            "interaction_log": [f"\n--- ISSUE: AESTHETIC TWEAK (AUTO) ---\nGOAL: {instr}"]
                        }

                elif method == '2':  # External
                    return {
                        "is_correct": False, "fix_mode": "external", "error_type": "aesthetic",
                        "aesthetic_scope": scope
                    }
                elif method == '3':  # Manual
                    return {
                        "is_correct": False, "fix_mode": "manual", "error_type": "aesthetic",
                        "aesthetic_scope": scope
                    }
        else:
            print("Invalid input.")


def correction_auto_node(state: IncrementalState):
    """Auto-correct a block — handles both programmatic and aesthetic errors."""
    print(f"--- [node] auto-correcting block {state['block_number']} ---")
    client = LLMClient()

    if state['error_type'] == 'programmatic':
        prompt = (
            f"You are fixing a SuperCollider bug.\n"
            f"BAD BLOCK:\n{state['bad_block']}\n"
            f"ERROR:\n{state['error_msg']}\n"
            f"COMPOSITION STATE:\n{state.get('composition_history', 'N/A')}\n\n"
            f"INSTRUCTION: Return ONLY the corrected code block."
        )
        label = "PROGRAMMATIC FIX"

    elif state['error_type'] == 'aesthetic' and state['aesthetic_scope'] == 'tweak':
        prompt = (
            f"You are tweaking SuperCollider code for aesthetics.\n"
            f"TARGET BLOCK:\n{state['bad_block']}\n"
            f"USER GOAL:\n{state['correction_instruction']}\n"
            f"COMPOSITION STATE:\n{state.get('composition_history', 'N/A')}\n\n"
            f"INSTRUCTION: Return ONLY the updated code block implementing this change."
        )
        label = "AESTHETIC TWEAK"

    elif state['error_type'] == 'aesthetic' and state['aesthetic_scope'] == 'regenerate':
        prompt = (
            f"You are rewriting a SuperCollider block.\n"
            f"ORIGINAL REQUEST:\n{state['user_query']}\n"
            f"NEW AESTHETIC GOAL:\n{state['correction_instruction']}\n"
            f"COMPOSITION STATE:\n{state.get('composition_history', 'N/A')}\n\n"
            f"INSTRUCTION: Output the COMPLETE valid SuperCollider code for the new block."
        )
        label = "AESTHETIC REGEN"
    else:
        prompt = (
            f"You are fixing a SuperCollider code block.\n"
            f"BLOCK TYPE: {state['block_type']}\n"
            f"BAD BLOCK:\n{state.get('bad_block', state['current_code_block'])}\n"
            f"ISSUE:\n{state.get('error_msg', 'Unknown')}\n"
            f"INSTRUCTION: Return ONLY the corrected code block."
        )
        label = "GENERAL FIX"

    code, token_stats = client.generate(prompt, state['system_instruction'])

    return {
        "current_code_block": code,
        "token_usage_log": [f"Fix ({label}): {token_stats}"],
        "interaction_log": [
            f"\n--- AUTO GENERATION ({label}) ---\n{code}",
            f"[Stats] {token_stats}"
        ],
    }


def correction_manual_node(state: IncrementalState):
    """Handle manual fix — user edits the file directly."""
    print(f"--- [node] manual fix for block {state['block_number']} ---")
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
        ],
    }


def correction_external_node(state: IncrementalState):
    """Handle external LLM fix."""
    print(f"--- [node] external LLM fix for block {state['block_number']} ---")

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
        ],
    }


def apply_patch_node(state: IncrementalState):
    """Overwrite the last block in the output file with the corrected version."""
    print("--- [node] patching output file ---")

    if not os.path.exists(config.OUTPUT_FILE):
        return {}

    # Aesthetic regenerate: append as a new section
    if state.get('aesthetic_scope') == 'regenerate':
        with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
            f.write("\n\n// --- REGENERATED BLOCK ---\n" + state['current_code_block'])
        print(" > Success: Regenerated block appended.")
        return {}

    with open(config.OUTPUT_FILE, 'r', encoding='utf-8') as f:
        file_content = f.read()

    # Find the last block separator and replace everything after it
    separator_prefix = f"// ============ BLOCK {state['block_number']}:"
    idx = file_content.rfind(separator_prefix)
    if idx >= 0:
        separator = f"\n\n// ============ BLOCK {state['block_number']}: {state['block_type'].upper()} ============\n"
        new_content = file_content[:idx].rstrip() + separator + state['current_code_block']
        with open(config.OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(" > Block patched in file.")
    else:
        # Fallback: try to find and replace the bad block directly
        target = (state.get('bad_block') or '').strip()
        replacement = state['current_code_block'].strip()
        if target and target in file_content:
            new_content = file_content.replace(target, replacement)
            with open(config.OUTPUT_FILE, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(" > Success: Code block updated via direct match.")
        else:
            with open(config.OUTPUT_FILE, 'a', encoding='utf-8') as f:
                f.write("\n\n// --- CORRECTED BLOCK ---\n" + state['current_code_block'])
            print(" > WARNING: Could not find block separator. Appended correction.")

    return {}


def summarize_improvements_node(state: IncrementalState):
    """Summarize what was learned from this correction — identical to one-shot."""
    print("--- [node] summarizing improvements ---")
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
    entry = f"### Entry [{timestamp}] ({label} — Incremental Block {state['block_number']})\n{summary}"
    utils.append_to_local_file(config.IMPROVEMENTS_FILE, entry)

    return {
        "learning_summary": summary,
        "token_usage_log": [f"Summary: {token_stats}"]
    }


def add_comments_node(state: IncrementalState):
    """Prompt user for session-end comments — identical to one-shot."""
    print("\n" + "=" * 40)
    print("      SESSION COMMENTS")
    print("=" * 40)
    comments = utils.get_multiline_input("Final notes (press Enter twice to skip):")
    return {"user_comments": comments if comments.strip() else "No comments."}


def summarize_comments_node(state: IncrementalState):
    """Extract lessons from user comments — identical to one-shot."""
    comments = state.get('user_comments', '')
    if not comments or comments.strip() == 'No comments.':
        return {}

    print("--- [node] summarizing user comments ---")
    client = LLMClient()
    prompt = (
        f"A user just finished a SuperCollider incremental live coding session and left these comments:\n"
        f"SESSION QUERY: {state.get('user_query', 'N/A')}\n"
        f"COMMENTS:\n{comments}\n\n"
        f"TASK: Extract any actionable lessons for improving future SuperCollider code generation. "
        f"Write a concise takeaway (LESSON). If the comments contain no actionable feedback, "
        f"respond with exactly 'NO_LESSON'."
    )
    summary, token_stats = client.generate(prompt)

    if 'NO_LESSON' not in summary:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
        entry = f"### Entry [{timestamp}] (User Feedback — Incremental Session)\n{summary}"
        utils.append_to_local_file(config.IMPROVEMENTS_FILE, entry)
        print(f"  > User feedback lesson saved.")
    else:
        print(f"  > No actionable lesson in comments.")

    return {"token_usage_log": [f"Comment Summary: {token_stats}"]}


def log_to_drive_node(state: IncrementalState):
    """Log the full session to Google Drive — identical to one-shot."""
    print("--- [node] logging to Google Drive ---")

    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    status = "FAILED / ABORTED" if state['user_abort'] else "SUCCESS"

    full_log_text = (
        f"\n\n========================================\n"
        f"SESSION LOG (INCREMENTAL): {timestamp}\n"
        f"STATUS: {status}\n"
        f"MODEL: {config.CURRENT_LLM_PROVIDER} / {config.CURRENT_MODEL_NAME}\n"
        f"TOTAL BLOCKS: {state['block_number']}\n"
        f"========================================\n"
    )

    for entry in state['interaction_log']:
        full_log_text += f"{entry}\n"

    if state.get('learning_summary'):
        full_log_text += f"\n--- SYSTEM IMPROVEMENT NOTE ---\n{state['learning_summary']}\n"
    if state.get('user_comments'):
        full_log_text += f"\n--- USER COMMENTS ---\n{state['user_comments']}\n"

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


# ---------------------------------------------------------------------------
# Graph Construction
# ---------------------------------------------------------------------------

def build_incremental_graph(auto_execute=False, validation_prefs=None):
    """Build the incremental block-by-block composition graph.
    
    Pipeline: load_resources → classify_block → generate_block
              → extract_new_block → write_block → update_composition → END
    
    All validation and correction loops have been removed.
    Code review is handled exclusively by the Fix tab in the IDE.
    """
    workflow = StateGraph(IncrementalState)

    # Nodes
    workflow.add_node("load_resources", load_resources_node)
    workflow.add_node("classify_block", classify_block_node)
    workflow.add_node("generate_block", generate_block_node)
    workflow.add_node("extract_new_block", extract_new_block_node)
    workflow.add_node("write_block", write_block_node)
    workflow.add_node("update_composition", update_composition_node)
    workflow.add_node("add_comments", add_comments_node)
    workflow.add_node("summarize_comments", summarize_comments_node)
    workflow.add_node("log_to_drive", log_to_drive_node)

    # Linear edges — no validation or correction loops
    workflow.add_edge(START, "load_resources")
    workflow.add_edge("load_resources", "classify_block")
    workflow.add_edge("classify_block", "generate_block")
    workflow.add_edge("generate_block", "extract_new_block")
    workflow.add_edge("extract_new_block", "write_block")
    workflow.add_edge("write_block", "update_composition")

    # Normal completion → done with this block
    workflow.add_edge("update_composition", END)

    # Session-end path (abort or fallthrough)
    workflow.add_edge("add_comments", "summarize_comments")
    workflow.add_edge("summarize_comments", "log_to_drive")
    workflow.add_edge("log_to_drive", END)

    return workflow.compile()


# ---------------------------------------------------------------------------
# Session Runner (called from main.py)
# ---------------------------------------------------------------------------

def run_incremental_session(auto_execute=False, validation_prefs=None):
    """Run the incremental block-by-block composition session.
    
    Validation and correction loops have been removed.
    Code review is handled exclusively by the Fix tab in the IDE.
    """

    # Ensure vector DB exists
    if not os.path.exists(config.KNOWLEDGE_DB_PATH):
        print("Vector Database not found. Building initial index...")
        rag_engine.build_all()

    graph = build_incremental_graph(auto_execute=auto_execute, validation_prefs=validation_prefs)
    composition_history = ""
    previous_blocks = []
    block_number = 0
    all_interaction_logs = []
    all_token_logs = []

    print("\n" + "=" * 50)
    print(f"  INCREMENTAL COMPOSITION MODE")
    print("  Type your request for each block.")
    print("  Type 'end' to compose a final ending block.")
    print("  Type 'quit' to exit without ending.")
    print("=" * 50)

    ending_completed = False

    try:
        while True:
            try:
                user_input = input(f"\nSC-Graph [Block {block_number + 1}]> ").strip()

                if user_input.lower() in ["quit", "exit"]:
                    print("\n  Session exited without ending block.")
                    break
                if not user_input:
                    continue

                # --- End Piece Flow ---
                is_ending = user_input.lower() in ["end", "finish", "done"]
                if is_ending:
                    print("\n" + "=" * 40)
                    print("      ENDING THE PIECE")
                    print("=" * 40)
                    if composition_history:
                        print(f"\n  Current composition state:")
                        print(f"  {composition_history[:200]}..." if len(composition_history) > 200 else f"  {composition_history}")
                    ending_prompt = utils.get_multiline_input(
                        "Describe how the piece should end (fade out, abrupt stop, dissolve, etc.):"
                    )
                    if not ending_prompt.strip():
                        ending_prompt = "Fade out all instruments gracefully."
                    user_input = ending_prompt

                block_number += 1

                invoke_state = {
                    "user_query": user_input,
                    "block_number": block_number,
                    "composition_history": composition_history,
                    "previous_blocks": previous_blocks,
                    "auto_execute": auto_execute,
                    "syntax_valid": None,
                    "syntax_errors": None,
                    "syntax_check_attempts": 0,
                    "validation_prefs": validation_prefs or {}
                }

                # Force block_type to fade_out for ending blocks
                if is_ending:
                    invoke_state["block_type"] = "fade_out"

                result = graph.invoke(invoke_state)

                # Accumulate logs across blocks
                if result.get("interaction_log"):
                    all_interaction_logs.extend(result["interaction_log"])
                if result.get("token_usage_log"):
                    all_token_logs.extend(result["token_usage_log"])

                # Carry state forward to the next block
                if result.get("composition_history"):
                    composition_history = result["composition_history"]
                if result.get("previous_blocks"):
                    previous_blocks = result["previous_blocks"]

                print(f"\n  Block {block_number} complete.")

                # If this was the ending block, exit to session logging
                if is_ending:
                    print("\n  Ending block written. Proceeding to session wrap-up...")
                    ending_completed = True
                    break

            except KeyboardInterrupt:
                print("\n  Session interrupted.")
                break
            except Exception as e:
                print(f"  Runtime Error: {e}")
                import traceback
                traceback.print_exc()

        # --- Session-End Logging ---
        if block_number > 0:
            print("\n" + "=" * 40)
            print("      SESSION COMPLETE — LOGGING")
            print("=" * 40)

            # Comments
            comments_result = add_comments_node({
                "user_query": "", "block_number": block_number,
                "interaction_log": [], "token_usage_log": [],
            })
            user_comments = comments_result.get("user_comments", "No comments.")
            all_interaction_logs.append(f"\n--- USER COMMENTS ---\n{user_comments}")

            # Summarize comments
            summarize_result = summarize_comments_node({
                "user_query": "(incremental session)",
                "user_comments": user_comments,
                "interaction_log": [], "token_usage_log": [],
            })
            if summarize_result.get("token_usage_log"):
                all_token_logs.extend(summarize_result["token_usage_log"])

            # Log to Drive
            log_to_drive_node({
                "user_abort": False,
                "block_number": block_number,
                "current_code_block": "",
                "interaction_log": all_interaction_logs,
                "token_usage_log": all_token_logs,
                "learning_summary": None,
                "user_comments": user_comments,
            })

            print("\n  Session logged. Goodbye!")
    finally:
        pass  # No validator to clean up

