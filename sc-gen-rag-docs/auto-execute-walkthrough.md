# Walkthrough: Auto-Execute Incremental Blocks with Syntax Validation

## Summary

Implemented a complete auto-execute pipeline that allows the incremental SuperCollider composition mode to automatically validate and execute each newly generated code block — eliminating the need for manual code selection and evaluation in the IDE.

## Changes Made

### Python Generator (5 files)

#### [config.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/config.py)

```diff:config.py
import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
CONTEXT_FOLDER = "knowledge_base"
SC_HELP_PATH = r"C:\Program Files\SuperCollider-3.13.0\HelpSource"

SYSTEM_TEXT_FILE = "system-instruction.md"
SYSTEM_TEXT_FILE_INCREMENTAL = "system-instruction-incremental.md"
OUTPUT_FILE = "sc-files/test.scd"
MAX_HISTORY_BLOCKS = 10  # Max previous blocks to include in LLM context
IMPROVEMENTS_FILE = "system-improvements.md"

KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
SCHELP_DB_PATH    = "vectordb_sc_help"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5  # >1 favors knowledge-base, <1 favors sc-help, 1.0 = neutral

DOCS_SCOPES = ['https://www.googleapis.com/auth/documents']
DOCUMENT_ID = '1YaAr1jlZ3w5N1t3GeIf_-o8j1za0jvTaTEpcL1JIBdo'
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'

CURRENT_LLM_PROVIDER = "gemini"

GEMINI_MODEL = "gemini-2.5-flash"
OLLAMA_MODEL = "qwen3:4b"

CURRENT_MODEL_NAME = GEMINI_MODEL if CURRENT_LLM_PROVIDER == "gemini" else OLLAMA_MODEL
===
import os
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
CONTEXT_FOLDER = "knowledge_base"
SC_HELP_PATH = r"C:\Program Files\SuperCollider-3.13.0\HelpSource"

SYSTEM_TEXT_FILE = "system-instruction.md"
SYSTEM_TEXT_FILE_INCREMENTAL = "system-instruction-incremental.md"
OUTPUT_FILE = "sc-files/test.scd"
MAX_HISTORY_BLOCKS = 10  # Max previous blocks to include in LLM context
AUTO_EXECUTE_ENABLED = False  # Default off; toggled at session start
MAX_SYNTAX_RETRIES = 3  # Max auto-correction attempts before falling back to manual
IMPROVEMENTS_FILE = "system-improvements.md"

KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
SCHELP_DB_PATH    = "vectordb_sc_help"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5  # >1 favors knowledge-base, <1 favors sc-help, 1.0 = neutral

DOCS_SCOPES = ['https://www.googleapis.com/auth/documents']
DOCUMENT_ID = '1YaAr1jlZ3w5N1t3GeIf_-o8j1za0jvTaTEpcL1JIBdo'
CREDENTIALS_FILE = 'credentials.json'
TOKEN_FILE = 'token.json'

CURRENT_LLM_PROVIDER = "gemini"

GEMINI_MODEL = "gemini-2.5-flash"
OLLAMA_MODEL = "qwen3:4b"

CURRENT_MODEL_NAME = GEMINI_MODEL if CURRENT_LLM_PROVIDER == "gemini" else OLLAMA_MODEL
```

Added `AUTO_EXECUTE_ENABLED` (default `False`) and `MAX_SYNTAX_RETRIES = 3`.

---

#### [main.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/main.py)

```diff:main.py
import os
import config
# from agent_graph import build_graph # Ensure this imports your full graph
import rag_engine

def main():
    if not os.path.exists(config.CONTEXT_FOLDER):
        os.makedirs(config.CONTEXT_FOLDER)
    
    print("==========================================")
    print(f"  SC-Graph | Provider: {config.CURRENT_LLM_PROVIDER}")
    print(f"  Knowledge DB: {config.KNOWLEDGE_DB_PATH}")
    print(f"  SC Help DB:   {config.SCHELP_DB_PATH}")
    print("==========================================")

    kb_exists = os.path.exists(config.KNOWLEDGE_DB_PATH)
    sc_exists = os.path.exists(config.SCHELP_DB_PATH)
    if not kb_exists or not sc_exists:
        print("Vector Database(s) not found. Building initial indexes...")
        rag_engine.build_all()

    # --- Mode Selection ---
    print("\n  Select generation mode:")
    print("  (1) One-Shot Generation    — Full code block in one pass")
    print("  (2) Incremental Building   — Block by block, step by step")
    
    while True:
        mode = input("\n>> Mode (1/2): ").strip()
        if mode in ("1", "2"):
            break
        print("Invalid input. Please enter 1 or 2.")

    if mode == "2":
        from agent_graph_incremental import run_incremental_session
        run_incremental_session()
        return

    # --- One-Shot Mode (existing flow, unchanged) ---
    from agent_graph import build_graph
    app = build_graph()

    while True:
        try:
            user_input = input("\nSC-Graph> ").strip()
            if user_input.lower() in ["exit", "quit"]: break
            if not user_input: continue

            if user_input.lower() == "rebuild":
                rag_engine.build_all()
                continue

            app.invoke({"user_query": user_input})
            print("\nSession Complete.")
            
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except Exception as e:
            print(f"Runtime Error: {e}")

if __name__ == "__main__":
    main()
===
import os
import config
# from agent_graph import build_graph # Ensure this imports your full graph
import rag_engine

def main():
    if not os.path.exists(config.CONTEXT_FOLDER):
        os.makedirs(config.CONTEXT_FOLDER)
    
    print("==========================================")
    print(f"  SC-Graph | Provider: {config.CURRENT_LLM_PROVIDER}")
    print(f"  Knowledge DB: {config.KNOWLEDGE_DB_PATH}")
    print(f"  SC Help DB:   {config.SCHELP_DB_PATH}")
    print("==========================================")

    kb_exists = os.path.exists(config.KNOWLEDGE_DB_PATH)
    sc_exists = os.path.exists(config.SCHELP_DB_PATH)
    if not kb_exists or not sc_exists:
        print("Vector Database(s) not found. Building initial indexes...")
        rag_engine.build_all()

    # --- Mode Selection ---
    print("\n  Select generation mode:")
    print("  (1) One-Shot Generation    — Full code block in one pass")
    print("  (2) Incremental Building   — Block by block, step by step")
    
    while True:
        mode = input("\n>> Mode (1/2): ").strip()
        if mode in ("1", "2"):
            break
        print("Invalid input. Please enter 1 or 2.")

    if mode == "2":
        from agent_graph_incremental import run_incremental_session

        # --- Auto-Execute Toggle ---
        print("\n  Auto-Execute will automatically run each generated block")
        print("  in SuperCollider after syntax validation (requires modified SC IDE).")
        while True:
            ae = input("\n>> Enable Auto-Execute? (y/n): ").strip().lower()
            if ae in ("y", "yes"):
                auto_execute = True
                print("  ✓ Auto-Execute ENABLED")
                break
            elif ae in ("n", "no"):
                auto_execute = False
                print("  ✗ Auto-Execute disabled (manual flow)")
                break
            print("Invalid input. Please enter y or n.")

        run_incremental_session(auto_execute=auto_execute)
        return

    # --- One-Shot Mode (existing flow, unchanged) ---
    from agent_graph import build_graph
    app = build_graph()

    while True:
        try:
            user_input = input("\nSC-Graph> ").strip()
            if user_input.lower() in ["exit", "quit"]: break
            if not user_input: continue

            if user_input.lower() == "rebuild":
                rag_engine.build_all()
                continue

            app.invoke({"user_query": user_input})
            print("\nSession Complete.")
            
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except Exception as e:
            print(f"Runtime Error: {e}")

if __name__ == "__main__":
    main()
```

Added interactive toggle prompt when user selects incremental mode: `"Enable Auto-Execute? (y/n)"`. Result is passed to [run_incremental_session(auto_execute=...)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#916-1068).

---

#### [agent_graph_incremental.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py) (core changes)

```diff:agent_graph_incremental.py
import os
import datetime
from typing import TypedDict, List, Optional, Annotated
from operator import add
from langgraph.graph import StateGraph, START, END

import config
import utils
import rag_engine
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
        "interaction_log": [f"BLOCK {state['block_number']} QUERY: {state['user_query']}"],
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

def build_incremental_graph():
    workflow = StateGraph(IncrementalState)

    # Nodes
    workflow.add_node("load_resources", load_resources_node)
    workflow.add_node("classify_block", classify_block_node)
    workflow.add_node("generate_block", generate_block_node)
    workflow.add_node("write_block", write_block_node)
    workflow.add_node("verify_block", verify_block_node)
    workflow.add_node("update_composition", update_composition_node)
    workflow.add_node("correction_auto", correction_auto_node)
    workflow.add_node("correction_manual", correction_manual_node)
    workflow.add_node("correction_external", correction_external_node)
    workflow.add_node("apply_patch", apply_patch_node)
    workflow.add_node("summarize_improvements", summarize_improvements_node)
    workflow.add_node("add_comments", add_comments_node)
    workflow.add_node("summarize_comments", summarize_comments_node)
    workflow.add_node("log_to_drive", log_to_drive_node)

    # Edges: linear flow
    workflow.add_edge(START, "load_resources")
    workflow.add_edge("load_resources", "classify_block")
    workflow.add_edge("classify_block", "generate_block")
    workflow.add_edge("generate_block", "write_block")
    workflow.add_edge("write_block", "verify_block")

    # The Verification Router (identical logic to one-shot)
    def verify_router(state: IncrementalState):
        if state["user_abort"]:
            return "add_comments"

        if state["is_correct"]:
            if state.get("fix_mode"):  # If a fix mode was active, summarize improvements
                return "summarize_improvements"
            else:  # Correct from the start
                return "update_composition"

        else:
            mode = state.get("fix_mode")
            if mode == "auto": return "correction_auto"
            if mode == "manual": return "correction_manual"
            if mode == "external": return "correction_external"
            return "add_comments"

    workflow.add_conditional_edges("verify_block", verify_router, {
        "update_composition": "update_composition",
        "correction_auto": "correction_auto",
        "correction_manual": "correction_manual",
        "correction_external": "correction_external",
        "summarize_improvements": "summarize_improvements",
        "add_comments": "add_comments",
    })

    # Correction paths all loop back through patch → verify
    workflow.add_edge("correction_auto", "apply_patch")
    workflow.add_edge("apply_patch", "verify_block")
    workflow.add_edge("correction_manual", "verify_block")
    workflow.add_edge("correction_external", "verify_block")

    # After improvements, update composition state then done with this block
    workflow.add_edge("summarize_improvements", "update_composition")

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

def run_incremental_session():
    """Run the incremental block-by-block composition session."""

    # Ensure vector DBs exist
    if not os.path.exists(config.KNOWLEDGE_DB_PATH) or not os.path.exists(config.SCHELP_DB_PATH):
        print("Vector Database(s) not found. Building initial indexes...")
        rag_engine.build_all()

    graph = build_incremental_graph()
    composition_history = ""
    previous_blocks = []
    block_number = 0
    all_interaction_logs = []
    all_token_logs = []

    print("\n" + "=" * 50)
    print("  INCREMENTAL COMPOSITION MODE")
    print("  Type your request for each block.")
    print("  Type 'end' to compose a final ending block.")
    print("  Type 'quit' to exit without ending.")
    print("=" * 50)

    session_aborted = False
    ending_completed = False

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

            # If user aborted during verification, the graph already handled
            # comments + drive logging via the abort path
            if result.get("user_abort"):
                print("\n  Session aborted.")
                session_aborted = True
                break

            print(f"\n  Block {block_number} complete.")

            # If this was the ending block and it was validated, exit to session logging
            if is_ending:
                print("\n  Ending block validated. Proceeding to session wrap-up...")
                ending_completed = True
                break

        except KeyboardInterrupt:
            print("\n  Session interrupted.")
            break
        except Exception as e:
            print(f"  Runtime Error: {e}")
            import traceback
            traceback.print_exc()

    # --- Session-End Logging (for normal exits or completed endings) ---
    if not session_aborted and block_number > 0:
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
===
import os
import datetime
from typing import TypedDict, List, Optional, Annotated
from operator import add
from langgraph.graph import StateGraph, START, END

import config
import utils
import rag_engine
from llm_engine import LLMClient


import re as _re


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
    syntax_valid: bool
    syntax_errors: Optional[str]
    syntax_check_attempts: int


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
        "interaction_log": [f"BLOCK {state['block_number']} QUERY: {state['user_query']}"],
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
    """Ensure the generated block is properly wrapped in parentheses for evaluation."""
    print("-- [node] extracting and preparing new block for validation")
    code = state['current_code_block'].strip()

    # Ensure block is wrapped in ( ) for SC IDE region evaluation
    if not code.startswith('('):
        code = '(' + '\n' + code
    if not code.endswith(')'):
        code = code + '\n' + ')'

    return {
        "current_code_block": code,
        "syntax_check_attempts": 0,
        "syntax_valid": False,
        "syntax_errors": None,
        "interaction_log": [f"\n--- Prepared block for syntax validation ---"],
    }


def _tier1_structural_check(code: str) -> Optional[str]:
    """Tier 1: Local structural checks — bracket matching and basic syntax.
    Returns None if valid, or an error description string if invalid."""
    # --- Bracket matching ---
    bracket_pairs = {'(': ')', '[': ']', '{': '}'}
    closing_to_opening = {')': '(', ']': '[', '}': '{'}
    stack = []
    in_string = False
    in_line_comment = False
    in_block_comment = False
    prev_char = ''

    for i, ch in enumerate(code):
        # Track string state (skip bracket checks inside strings)
        if ch == '"' and not in_line_comment and not in_block_comment:
            in_string = not in_string
        if in_string:
            prev_char = ch
            continue

        # Track comment state
        if ch == '/' and i + 1 < len(code):
            next_ch = code[i + 1]
            if next_ch == '/' and not in_block_comment:
                in_line_comment = True
            elif next_ch == '*' and not in_line_comment:
                in_block_comment = True
        if ch == '\n':
            in_line_comment = False
        if ch == '/' and prev_char == '*' and in_block_comment:
            in_block_comment = False
            prev_char = ch
            continue

        if in_line_comment or in_block_comment:
            prev_char = ch
            continue

        # Track brackets
        if ch in bracket_pairs:
            stack.append((ch, i))
        elif ch in closing_to_opening:
            expected_opener = closing_to_opening[ch]
            if not stack:
                return f"Unmatched closing '{ch}' at position {i}"
            opener, opener_pos = stack.pop()
            if opener != expected_opener:
                return f"Mismatched brackets: '{opener}' at pos {opener_pos} closed by '{ch}' at pos {i}"

        prev_char = ch

    if stack:
        opener, pos = stack[-1]
        return f"Unmatched opening '{opener}' at position {pos}"

    # --- Empty block detection ---
    stripped = _re.sub(r'//[^\n]*', '', code)  # strip line comments
    stripped = _re.sub(r'/\*.*?\*/', '', stripped, flags=_re.DOTALL)  # strip block comments
    stripped = _re.sub(r'[()\s]', '', stripped)  # strip parens and whitespace
    if not stripped:
        return "Block is empty (contains only comments/whitespace)"

    return None  # Valid


def syntax_validate_node(state: IncrementalState):
    """Two-tier syntax validation of the generated code block."""
    attempt = state.get('syntax_check_attempts', 0) + 1
    print(f"-- [node] syntax validation (attempt {attempt}/{config.MAX_SYNTAX_RETRIES})")

    code = state['current_code_block']

    # --- Tier 1: Structural checks ---
    tier1_error = _tier1_structural_check(code)
    if tier1_error:
        print(f"  ✗ Tier 1 FAILED: {tier1_error}")
        return {
            "syntax_valid": False,
            "syntax_errors": f"Structural: {tier1_error}",
            "syntax_check_attempts": attempt,
            "interaction_log": [f"\n--- SYNTAX CHECK (attempt {attempt}): FAILED (Tier 1) ---\n{tier1_error}"],
            "token_usage_log": [],
        }

    # --- Tier 2: LLM-based semantic validation ---
    client = LLMClient()
    prompt = (
        f"You are a SuperCollider syntax checker. Analyze this code block for SYNTAX ERRORS ONLY "
        f"(not style, not aesthetics, not best practices — only things that would cause sclang to fail).\n\n"
        f"Check:\n"
        f"- Balanced brackets and parentheses\n"
        f"- Correct method signatures and argument syntax\n"
        f"- Valid UGen names and argument order\n"
        f"- Proper semicolons between statements\n"
        f"- Correct use of pipe characters for arguments\n\n"
        f"CODE:\n{code}\n\n"
        f"If the code is syntactically valid, respond with EXACTLY: VALID\n"
        f"If errors are found, respond with: INVALID: followed by a brief description of each error."
    )

    result, token_stats = client.generate(prompt)
    result_clean = result.strip()

    if result_clean.upper().startswith("VALID"):
        print(f"  ✓ Syntax validation PASSED (Tier 1 + Tier 2)")
        return {
            "syntax_valid": True,
            "syntax_errors": None,
            "syntax_check_attempts": attempt,
            "token_usage_log": [f"syntax_check (attempt {attempt}): {token_stats}"],
            "interaction_log": [f"\n--- SYNTAX CHECK (attempt {attempt}): PASSED ---"],
        }
    else:
        error_desc = result_clean
        print(f"  ✗ Tier 2 FAILED: {error_desc[:150]}")
        return {
            "syntax_valid": False,
            "syntax_errors": error_desc,
            "syntax_check_attempts": attempt,
            "token_usage_log": [f"syntax_check (attempt {attempt}): {token_stats}"],
            "interaction_log": [f"\n--- SYNTAX CHECK (attempt {attempt}): FAILED (Tier 2) ---\n{error_desc}"],
        }


def syntax_correction_node(state: IncrementalState):
    """Auto-correct a block that failed syntax validation."""
    print(f"--- [node] auto-correcting syntax errors (attempt {state.get('syntax_check_attempts', 0)}) ---")
    client = LLMClient()

    prompt = (
        f"You are fixing SuperCollider syntax errors.\n"
        f"CODE WITH ERRORS:\n{state['current_code_block']}\n\n"
        f"ERRORS FOUND:\n{state.get('syntax_errors', 'Unknown syntax error')}\n\n"
        f"COMPOSITION STATE:\n{state.get('composition_history', 'N/A')}\n\n"
        f"INSTRUCTION: Return ONLY the corrected code block. Fix the syntax errors "
        f"while preserving the musical intent. The block must be wrapped in ( )."
    )

    code, token_stats = client.generate(prompt, state.get('system_instruction'))

    return {
        "current_code_block": code,
        "token_usage_log": [f"syntax_correction: {token_stats}"],
        "interaction_log": [
            f"\n--- SYNTAX AUTO-CORRECTION ---\n{code}",
            f"[Stats] {token_stats}"
        ],
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

def build_incremental_graph(auto_execute=False):
    workflow = StateGraph(IncrementalState)

    # Nodes
    workflow.add_node("load_resources", load_resources_node)
    workflow.add_node("classify_block", classify_block_node)
    workflow.add_node("generate_block", generate_block_node)
    workflow.add_node("extract_new_block", extract_new_block_node)
    workflow.add_node("syntax_validate", syntax_validate_node)
    workflow.add_node("syntax_correction", syntax_correction_node)
    workflow.add_node("write_block", write_block_node)
    workflow.add_node("verify_block", verify_block_node)
    workflow.add_node("update_composition", update_composition_node)
    workflow.add_node("correction_auto", correction_auto_node)
    workflow.add_node("correction_manual", correction_manual_node)
    workflow.add_node("correction_external", correction_external_node)
    workflow.add_node("apply_patch", apply_patch_node)
    workflow.add_node("summarize_improvements", summarize_improvements_node)
    workflow.add_node("add_comments", add_comments_node)
    workflow.add_node("summarize_comments", summarize_comments_node)
    workflow.add_node("log_to_drive", log_to_drive_node)

    # Edges: linear flow up to generation
    workflow.add_edge(START, "load_resources")
    workflow.add_edge("load_resources", "classify_block")
    workflow.add_edge("classify_block", "generate_block")

    if auto_execute:
        # --- Auto-Execute Path ---
        # generate → extract → validate → [router]
        workflow.add_edge("generate_block", "extract_new_block")
        workflow.add_edge("extract_new_block", "syntax_validate")

        # Syntax validation router
        def syntax_router(state: IncrementalState):
            if state.get("syntax_valid"):
                return "write_block"
            elif state.get("syntax_check_attempts", 0) >= config.MAX_SYNTAX_RETRIES:
                # Max retries exceeded — fall back to manual verification
                return "write_block_manual"
            else:
                return "syntax_correction"

        workflow.add_conditional_edges("syntax_validate", syntax_router, {
            "write_block": "write_block",
            "write_block_manual": "write_block",
            "syntax_correction": "syntax_correction",
        })

        # Correction loops back to validation
        workflow.add_edge("syntax_correction", "syntax_validate")

        # After writing: route based on whether validation passed or we hit max retries
        def post_write_router(state: IncrementalState):
            if state.get("syntax_valid"):
                # Validated — skip manual verification, go directly to update
                return "update_composition"
            else:
                # Max retries hit — fall through to manual verification
                return "verify_block"

        workflow.add_conditional_edges("write_block", post_write_router, {
            "update_composition": "update_composition",
            "verify_block": "verify_block",
        })
    else:
        # --- Standard Path (unchanged) ---
        workflow.add_edge("generate_block", "write_block")
        workflow.add_edge("write_block", "verify_block")

    # The Verification Router (identical logic to one-shot)
    def verify_router(state: IncrementalState):
        if state["user_abort"]:
            return "add_comments"

        if state["is_correct"]:
            if state.get("fix_mode"):  # If a fix mode was active, summarize improvements
                return "summarize_improvements"
            else:  # Correct from the start
                return "update_composition"

        else:
            mode = state.get("fix_mode")
            if mode == "auto": return "correction_auto"
            if mode == "manual": return "correction_manual"
            if mode == "external": return "correction_external"
            return "add_comments"

    workflow.add_conditional_edges("verify_block", verify_router, {
        "update_composition": "update_composition",
        "correction_auto": "correction_auto",
        "correction_manual": "correction_manual",
        "correction_external": "correction_external",
        "summarize_improvements": "summarize_improvements",
        "add_comments": "add_comments",
    })

    # Correction paths all loop back through patch → verify
    workflow.add_edge("correction_auto", "apply_patch")
    workflow.add_edge("apply_patch", "verify_block")
    workflow.add_edge("correction_manual", "verify_block")
    workflow.add_edge("correction_external", "verify_block")

    # After improvements, update composition state then done with this block
    workflow.add_edge("summarize_improvements", "update_composition")

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

def run_incremental_session(auto_execute=False):
    """Run the incremental block-by-block composition session."""

    # Ensure vector DBs exist
    if not os.path.exists(config.KNOWLEDGE_DB_PATH) or not os.path.exists(config.SCHELP_DB_PATH):
        print("Vector Database(s) not found. Building initial indexes...")
        rag_engine.build_all()

    graph = build_incremental_graph(auto_execute=auto_execute)
    composition_history = ""
    previous_blocks = []
    block_number = 0
    all_interaction_logs = []
    all_token_logs = []

    print("\n" + "=" * 50)
    print("  INCREMENTAL COMPOSITION MODE")
    if auto_execute:
        print("  [AUTO-EXECUTE ENABLED] Blocks will be validated and run automatically.")
    print("  Type your request for each block.")
    print("  Type 'end' to compose a final ending block.")
    print("  Type 'quit' to exit without ending.")
    print("=" * 50)

    session_aborted = False
    ending_completed = False

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
                "syntax_valid": False,
                "syntax_errors": None,
                "syntax_check_attempts": 0,
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

            # If user aborted during verification, the graph already handled
            # comments + drive logging via the abort path
            if result.get("user_abort"):
                print("\n  Session aborted.")
                session_aborted = True
                break

            # Auto-execute status message
            if auto_execute and result.get("syntax_valid"):
                attempts = result.get("syntax_check_attempts", 1)
                if attempts > 1:
                    print(f"\n  ✓ Block {block_number} auto-validated (after {attempts - 1} correction(s)) and executing...")
                else:
                    print(f"\n  ✓ Block {block_number} auto-validated and executing...")
            elif auto_execute and not result.get("syntax_valid"):
                print(f"\n  ⚠ Block {block_number} required manual verification (auto-validation failed).")
            else:
                print(f"\n  Block {block_number} complete.")

            # If this was the ending block and it was validated, exit to session logging
            if is_ending:
                print("\n  Ending block validated. Proceeding to session wrap-up...")
                ending_completed = True
                break

        except KeyboardInterrupt:
            print("\n  Session interrupted.")
            break
        except Exception as e:
            print(f"  Runtime Error: {e}")
            import traceback
            traceback.print_exc()

    # --- Session-End Logging (for normal exits or completed endings) ---
    if not session_aborted and block_number > 0:
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

```

Key additions:

| Component | Purpose |
|---|---|
| [IncrementalState](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#16-42) new fields | `auto_execute`, [syntax_valid](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#274-331), `syntax_errors`, `syntax_check_attempts` |
| [extract_new_block_node](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#189-207) | Ensures block is wrapped in [( )](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/test_queries.py#71-91) for SC IDE region evaluation |
| [_tier1_structural_check()](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#209-272) | Local bracket matching, empty block detection — no LLM cost |
| [syntax_validate_node](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#274-331) | Two-tier validation: Tier 1 (structural) + Tier 2 (LLM semantic check) |
| [syntax_correction_node](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#333-357) | Auto-fixes syntax errors when validation fails |
| [build_incremental_graph(auto_execute)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#795-910) | Conditional graph wiring: auto path vs standard path |
| [run_incremental_session(auto_execute)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py#916-1068) | Passes auto-execute state, prints status messages |

**Auto-execute graph flow:**
```
generate → extract → validate → [valid?] → write → update_composition → END
                                [invalid & retries left?] → correct → validate (loop)
                                [max retries?] → write → verify_block (manual fallback)
```

---

### SuperCollider IDE (2 files)

#### [doc_manager.hpp](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.hpp)

```diff:doc_manager.hpp
/*
    SuperCollider Qt IDE
    Copyright (c) 2012 Jakob Leben & Tim Blechmann
    http://www.audiosynth.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
*/

#pragma once

#include "../widgets/code_editor/editor.hpp"
#include <QDateTime>
#include <QFileSystemWatcher>
#include <QHash>
#include <QList>
#include <QMetaType>
#include <QObject>
#include <QStringList>
#include <QTextDocument>
#include <QPlainTextDocumentLayout>
#include <QUuid>
#include <QTimer>
#include <QStandardItemModel>
#include <QApplication>
#include <QStyle>

#define RESTORE_COAL 100
#define RESTORE_COAL_MSECS 60000

namespace ScIDE {

namespace Settings {
class Manager;
}
class SyntaxHighlighter;

class Main;
class DocumentManager;

class Document : public QObject {
    Q_OBJECT

    friend class DocumentManager;

public:
    Document(bool isPlainText, const QByteArray& id = QByteArray(), const QString& title = QString(),
             const QString& text = QString());

    QTextDocument* textDocument() { return mDoc; }
    const QByteArray& id() { return mId; }
    const QString& filePath() { return mFilePath; }
    const QString& title() { return mTitle; }
    void setTitle(QString& newTitle) {
        mTitle = newTitle;
        mModelItem->setText(mTitle);
    }

    QFont defaultFont() const { return mDoc->defaultFont(); }
    void setDefaultFont(const QFont& font);

    int indentWidth() const { return mIndentWidth; }
    void setIndentWidth(int numSpaces);

    void deleteTrailingSpaces();

    bool isPlainText() const { return mHighlighter == NULL; }
    bool isModified() const { return mDoc->isModified(); }

    QStandardItem* modelItem() { return mModelItem; }

    QString textAsSCArrayOfCharCodes(int start, int range);
    QString titleAsSCArrayOfCharCodes();
    QString pathAsSCArrayOfCharCodes();
    QString bytesToSCArrayOfCharCodes(QByteArray stringBytes);

    void setTextInRange(const QString text, int start, int range);

    bool keyDownActionEnabled() { return mKeyDownActionEnabled; }
    bool keyUpActionEnabled() { return mKeyUpActionEnabled; }
    bool mouseDownActionEnabled() { return mMouseDownActionEnabled; }
    bool mouseUpActionEnabled() { return mMouseUpActionEnabled; }
    bool textChangedActionEnabled() { return mTextChangedActionEnabled; }
    GenericCodeEditor* lastActiveEditor() { return mLastActiveEditor; }
    int initialSelectionStart() { return mInitialSelectionStart; }
    int initialSelectionRange() { return mInitialSelectionRange; }
    bool editable() { return mEditable; }
    bool promptsToSave() { return mPromptsToSave; }

    void setKeyDownActionEnabled(bool enabled) { mKeyDownActionEnabled = enabled; }
    void setKeyUpActionEnabled(bool enabled) { mKeyUpActionEnabled = enabled; }
    void setMouseDownActionEnabled(bool enabled) { mMouseDownActionEnabled = enabled; }
    void setMouseUpActionEnabled(bool enabled) { mMouseUpActionEnabled = enabled; }
    void setTextChangedActionEnabled(bool enabled) { mTextChangedActionEnabled = enabled; }
    void setLastActiveEditor(GenericCodeEditor* lastActive) { mLastActiveEditor = lastActive; }
    void setInitialSelection(int start, int range) {
        mInitialSelectionStart = start;
        mInitialSelectionRange = range;
    }
    void setEditable(bool editable) { mEditable = editable; }
    void setPromptsToSave(bool prompts) { mPromptsToSave = prompts; }

    void removeTmpFile();

public slots:
    void applySettings(Settings::Manager*);
    void resetDefaultFont();
    void storeTmpFile();
    void onTmpCoalUsecs();

    void onModificationChanged(bool changed) {
        if (changed) {
            mModelItem->setIcon(QApplication::style()->standardIcon(QStyle::SP_DialogSaveButton));
        } else {
            mModelItem->setIcon(QIcon());
        }
    }

signals:
    void defaultFontChanged();

private:
    void setPlainText(bool flag);

    QByteArray mId;
    QTextDocument* mDoc;
    QString mFilePath;
    QString mTitle;
    QString mTmpFilePath;
    int mTmpCoalCount;
    QTimer mTmpCoalTimer;
    QDateTime mSaveTime;
    int mIndentWidth;
    SyntaxHighlighter* mHighlighter;
    bool mKeyDownActionEnabled;
    bool mKeyUpActionEnabled;
    bool mMouseDownActionEnabled;
    bool mMouseUpActionEnabled;
    bool mTextChangedActionEnabled;
    GenericCodeEditor* mLastActiveEditor;
    int mInitialSelectionStart, mInitialSelectionRange;
    bool mEditable;
    bool mPromptsToSave;
    QStandardItem* mModelItem;
};

class DocumentManager : public QObject {
    Q_OBJECT

public:
    typedef QList<Document*> DocumentList;

    DocumentManager(Main*, Settings::Manager*);
    QList<Document*> documents() { return mDocHash.values(); }
    QList<QByteArray> documentIDs() { return mDocHash.keys(); }

    void create();
    void close(Document*);
    bool save(Document*);
    bool saveAs(Document*, const QString& path);
    bool reload(Document*);
    bool needRestore();
    void restore();
    void deleteRestore();
    const QStringList& recents() const { return mRecent; }
    Document* documentForId(const QByteArray id);
    bool textMirrorEnabled() { return mTextMirrorEnabled; }
    void setActiveDocument(class Document*);
    void sendActiveDocument();
    Document* activeDocument() { return mCurrentDocument; }
    bool globalKeyDownActionEnabled() { return mGlobalKeyDownEnabled; }
    bool globalKeyUpActionEnabled() { return mGlobalKeyUpEnabled; }
    QStandardItemModel* docModel() { return mDocumentModel; }

public slots:
    // initialCursorPosition -1 means "don't change position if already open"
    Document* open(const QString& path, int initialCursorPosition = -1, int selectionLength = 0,
                   bool addToRecent = true, const QByteArray& id = QByteArray(), bool syncLang = true);
    void clearRecents();
    void storeSettings(Settings::Manager*);
    void handleScLangMessage(const QString& selector, const QString& data);

Q_SIGNALS:
    void opened(Document*, int cursorPosition, int selectionLength);
    void closed(Document*);
    void saved(Document*);
    void showRequest(Document*, int pos = -1, int selectionLength = 0);
    void changedExternally(Document*);
    void recentsChanged();
    void titleChanged(Document*);

private slots:
    void onFileChanged(const QString& path);
    void updateCurrentDocContents(int position, int charsRemoved, int charsAdded);

private:
    Document* createDocument(bool isPlainText = false, const QByteArray& id = QByteArray(),
                             const QString& title = QString(), const QString& text = QString());
    bool doSaveAs(Document*, const QString& path);
    void addToRecent(Document*);
    void loadRecentDocuments(Settings::Manager*);
    QStringList tmpFiles();
    void closeSingleUntitledIfUnmodified();
    QString decodeDocument(QByteArray const&);
    void handleDocListScRequest();
    void handleNewDocScRequest(const QString& data);
    void handleOpenFileScRequest(const QString& data);
    void handleGetDocTextScRequest(const QString& data);
    void handleSetDocTextScRequest(const QString& data);
    void handleSetDocSelectionScRequest(const QString& data);
    void handleSetDocEditableScRequest(const QString& data);
    void handleSetDocPromptsToSaveScRequest(const QString& data);
    void handleSetCurrentDocScRequest(const QString& data);
    void handleRemoveDocUndoScRequest(const QString& data);
    void handleCloseDocScRequest(const QString& data);
    void handleSaveDocScRequest(const QString& data);
    void handleSetDocTitleScRequest(const QString& data);

    bool parseActionEnabledRequest(const QString& data, std::string* idString, bool* en);
    void handleEnableKeyDownScRequest(const QString& data);
    void handleEnableKeyUpScRequest(const QString& data);
    void handleEnableGlobalKeyDownScRequest(const QString& data);
    void handleEnableGlobalKeyUpScRequest(const QString& data);
    void handleEnableMouseDownScRequest(const QString& data);
    void handleEnableMouseUpScRequest(const QString& data);
    void handleEnableTextChangedScRequest(const QString& data);
    void handleEnableTextMirrorScRequest(const QString& data);
    void syncLangDocument(Document*);

    typedef QHash<QByteArray, Document*>::iterator DocIterator;

    QHash<QByteArray, Document*> mDocHash;
    QFileSystemWatcher mFsWatcher;

    QStringList mRecent;
    static const int mMaxRecent = 10;

    bool mTextMirrorEnabled;
    QString mCurrentDocumentPath;
    class Document* mCurrentDocument;
    bool mGlobalKeyDownEnabled, mGlobalKeyUpEnabled;
    QStandardItemModel* mDocumentModel;
};

} // namespace ScIDE

Q_DECLARE_METATYPE(ScIDE::Document*)
===
/*
    SuperCollider Qt IDE
    Copyright (c) 2012 Jakob Leben & Tim Blechmann
    http://www.audiosynth.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
*/

#pragma once

#include "../widgets/code_editor/editor.hpp"
#include <QDateTime>
#include <QFileSystemWatcher>
#include <QHash>
#include <QList>
#include <QMetaType>
#include <QObject>
#include <QStringList>
#include <QTextDocument>
#include <QPlainTextDocumentLayout>
#include <QUuid>
#include <QTimer>
#include <QStandardItemModel>
#include <QApplication>
#include <QStyle>

#define RESTORE_COAL 100
#define RESTORE_COAL_MSECS 60000

namespace ScIDE {

namespace Settings {
class Manager;
}
class SyntaxHighlighter;

class Main;
class DocumentManager;

class Document : public QObject {
    Q_OBJECT

    friend class DocumentManager;

public:
    Document(bool isPlainText, const QByteArray& id = QByteArray(), const QString& title = QString(),
             const QString& text = QString());

    QTextDocument* textDocument() { return mDoc; }
    const QByteArray& id() { return mId; }
    const QString& filePath() { return mFilePath; }
    const QString& title() { return mTitle; }
    void setTitle(QString& newTitle) {
        mTitle = newTitle;
        mModelItem->setText(mTitle);
    }

    QFont defaultFont() const { return mDoc->defaultFont(); }
    void setDefaultFont(const QFont& font);

    int indentWidth() const { return mIndentWidth; }
    void setIndentWidth(int numSpaces);

    void deleteTrailingSpaces();

    bool isPlainText() const { return mHighlighter == NULL; }
    bool isModified() const { return mDoc->isModified(); }

    QStandardItem* modelItem() { return mModelItem; }

    QString textAsSCArrayOfCharCodes(int start, int range);
    QString titleAsSCArrayOfCharCodes();
    QString pathAsSCArrayOfCharCodes();
    QString bytesToSCArrayOfCharCodes(QByteArray stringBytes);

    void setTextInRange(const QString text, int start, int range);

    bool keyDownActionEnabled() { return mKeyDownActionEnabled; }
    bool keyUpActionEnabled() { return mKeyUpActionEnabled; }
    bool mouseDownActionEnabled() { return mMouseDownActionEnabled; }
    bool mouseUpActionEnabled() { return mMouseUpActionEnabled; }
    bool textChangedActionEnabled() { return mTextChangedActionEnabled; }
    GenericCodeEditor* lastActiveEditor() { return mLastActiveEditor; }
    int initialSelectionStart() { return mInitialSelectionStart; }
    int initialSelectionRange() { return mInitialSelectionRange; }
    bool editable() { return mEditable; }
    bool promptsToSave() { return mPromptsToSave; }

    void setKeyDownActionEnabled(bool enabled) { mKeyDownActionEnabled = enabled; }
    void setKeyUpActionEnabled(bool enabled) { mKeyUpActionEnabled = enabled; }
    void setMouseDownActionEnabled(bool enabled) { mMouseDownActionEnabled = enabled; }
    void setMouseUpActionEnabled(bool enabled) { mMouseUpActionEnabled = enabled; }
    void setTextChangedActionEnabled(bool enabled) { mTextChangedActionEnabled = enabled; }
    void setLastActiveEditor(GenericCodeEditor* lastActive) { mLastActiveEditor = lastActive; }
    void setInitialSelection(int start, int range) {
        mInitialSelectionStart = start;
        mInitialSelectionRange = range;
    }
    void setEditable(bool editable) { mEditable = editable; }
    void setPromptsToSave(bool prompts) { mPromptsToSave = prompts; }

    void removeTmpFile();

public slots:
    void applySettings(Settings::Manager*);
    void resetDefaultFont();
    void storeTmpFile();
    void onTmpCoalUsecs();

    void onModificationChanged(bool changed) {
        if (changed) {
            mModelItem->setIcon(QApplication::style()->standardIcon(QStyle::SP_DialogSaveButton));
        } else {
            mModelItem->setIcon(QIcon());
        }
    }

signals:
    void defaultFontChanged();

private:
    void setPlainText(bool flag);

    QByteArray mId;
    QTextDocument* mDoc;
    QString mFilePath;
    QString mTitle;
    QString mTmpFilePath;
    int mTmpCoalCount;
    QTimer mTmpCoalTimer;
    QDateTime mSaveTime;
    int mIndentWidth;
    SyntaxHighlighter* mHighlighter;
    bool mKeyDownActionEnabled;
    bool mKeyUpActionEnabled;
    bool mMouseDownActionEnabled;
    bool mMouseUpActionEnabled;
    bool mTextChangedActionEnabled;
    GenericCodeEditor* mLastActiveEditor;
    int mInitialSelectionStart, mInitialSelectionRange;
    bool mEditable;
    bool mPromptsToSave;
    QStandardItem* mModelItem;
};

class DocumentManager : public QObject {
    Q_OBJECT

public:
    typedef QList<Document*> DocumentList;

    DocumentManager(Main*, Settings::Manager*);
    QList<Document*> documents() { return mDocHash.values(); }
    QList<QByteArray> documentIDs() { return mDocHash.keys(); }

    void create();
    void close(Document*);
    bool save(Document*);
    bool saveAs(Document*, const QString& path);
    bool reload(Document*);
    bool needRestore();
    void restore();
    void deleteRestore();
    const QStringList& recents() const { return mRecent; }
    Document* documentForId(const QByteArray id);
    bool textMirrorEnabled() { return mTextMirrorEnabled; }
    void setActiveDocument(class Document*);
    void sendActiveDocument();
    Document* activeDocument() { return mCurrentDocument; }
    bool globalKeyDownActionEnabled() { return mGlobalKeyDownEnabled; }
    bool globalKeyUpActionEnabled() { return mGlobalKeyUpEnabled; }
    QStandardItemModel* docModel() { return mDocumentModel; }

public slots:
    // initialCursorPosition -1 means "don't change position if already open"
    Document* open(const QString& path, int initialCursorPosition = -1, int selectionLength = 0,
                   bool addToRecent = true, const QByteArray& id = QByteArray(), bool syncLang = true);
    void clearRecents();
    void storeSettings(Settings::Manager*);
    void handleScLangMessage(const QString& selector, const QString& data);

Q_SIGNALS:
    void opened(Document*, int cursorPosition, int selectionLength);
    void closed(Document*);
    void saved(Document*);
    void showRequest(Document*, int pos = -1, int selectionLength = 0);
    void changedExternally(Document*);
    void recentsChanged();
    void titleChanged(Document*);

private slots:
    void onFileChanged(const QString& path);
    void updateCurrentDocContents(int position, int charsRemoved, int charsAdded);

private:
    Document* createDocument(bool isPlainText = false, const QByteArray& id = QByteArray(),
                             const QString& title = QString(), const QString& text = QString());
    bool doSaveAs(Document*, const QString& path);
    void addToRecent(Document*);
    void loadRecentDocuments(Settings::Manager*);
    QStringList tmpFiles();
    void closeSingleUntitledIfUnmodified();
    QString decodeDocument(QByteArray const&);
    void handleDocListScRequest();
    void handleNewDocScRequest(const QString& data);
    void handleOpenFileScRequest(const QString& data);
    void handleGetDocTextScRequest(const QString& data);
    void handleSetDocTextScRequest(const QString& data);
    void handleSetDocSelectionScRequest(const QString& data);
    void handleSetDocEditableScRequest(const QString& data);
    void handleSetDocPromptsToSaveScRequest(const QString& data);
    void handleSetCurrentDocScRequest(const QString& data);
    void handleRemoveDocUndoScRequest(const QString& data);
    void handleCloseDocScRequest(const QString& data);
    void handleSaveDocScRequest(const QString& data);
    void handleSetDocTitleScRequest(const QString& data);

    bool parseActionEnabledRequest(const QString& data, std::string* idString, bool* en);
    void handleEnableKeyDownScRequest(const QString& data);
    void handleEnableKeyUpScRequest(const QString& data);
    void handleEnableGlobalKeyDownScRequest(const QString& data);
    void handleEnableGlobalKeyUpScRequest(const QString& data);
    void handleEnableMouseDownScRequest(const QString& data);
    void handleEnableMouseUpScRequest(const QString& data);
    void handleEnableTextChangedScRequest(const QString& data);
    void handleEnableTextMirrorScRequest(const QString& data);
    void syncLangDocument(Document*);
    void autoEvaluateLastRegion(Document*);

    typedef QHash<QByteArray, Document*>::iterator DocIterator;

    QHash<QByteArray, Document*> mDocHash;
    QFileSystemWatcher mFsWatcher;

    QStringList mRecent;
    static const int mMaxRecent = 10;

    bool mTextMirrorEnabled;
    bool mAutoEvaluateEnabled;  // Toggle for auto-evaluating new code on reload
    QString mCurrentDocumentPath;
    class Document* mCurrentDocument;
    bool mGlobalKeyDownEnabled, mGlobalKeyUpEnabled;
    QStandardItemModel* mDocumentModel;
};

} // namespace ScIDE

Q_DECLARE_METATYPE(ScIDE::Document*)
```

Added [autoEvaluateLastRegion(Document*)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.cpp#563-605) declaration and `mAutoEvaluateEnabled` flag.

---

#### [doc_manager.cpp](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.cpp)

```diff:doc_manager.cpp
/*
    SuperCollider Qt IDE
    Copyright (c) 2012 Jakob Leben & Tim Blechmann
    http://www.audiosynth.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
*/

#include "doc_manager.hpp"
#include "main.hpp"
#include "main_window.hpp"
#include "settings/manager.hpp"
#include "../widgets/code_editor/highlighter.hpp"
#include "../../common/SC_TextUtils.hpp"
#include "util/standard_dirs.hpp"

#include <QPlainTextDocumentLayout>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QMessageBox>
#include <QTextBlock>
#include <QApplication>

#include <yaml-cpp/yaml.h>

using namespace ScIDE;

Document::Document(bool isPlainText, const QByteArray& id, const QString& title, const QString& text):
    mId(id),
    mDoc(new QTextDocument(text, this)),
    mTitle(title),
    mIndentWidth(4),
    mHighlighter(0),
    mKeyDownActionEnabled(false),
    mKeyUpActionEnabled(false),
    mMouseDownActionEnabled(false),
    mMouseUpActionEnabled(false),
    mTextChangedActionEnabled(false),
    mLastActiveEditor(0),
    mInitialSelectionStart(0),
    mInitialSelectionRange(0),
    mEditable(true),
    mPromptsToSave(true) {
    mTmpCoalCount = 0;
    mTmpCoalTimer.setInterval(RESTORE_COAL_MSECS);
    mTmpCoalTimer.setSingleShot(true);
    connect(&mTmpCoalTimer, SIGNAL(timeout()), this, SLOT(onTmpCoalUsecs()));

    if (mId.isEmpty())
        mId = QUuid::createUuid().toString().toLatin1();
    if (mTitle.isEmpty())
        mTitle = tr("Untitled");

    mDoc->setDocumentLayout(new QPlainTextDocumentLayout(mDoc));

    if (!isPlainText)
        mHighlighter = new SyntaxHighlighter(mDoc);

    connect(Main::instance(), SIGNAL(applySettingsRequest(Settings::Manager*)), this,
            SLOT(applySettings(Settings::Manager*)));

    applySettings(Main::settings());
}

void Document::setPlainText(bool set_plain_text) {
    if (isPlainText() == set_plain_text)
        return;

    delete mHighlighter;
    mHighlighter = 0;

    if (!set_plain_text)
        mHighlighter = new SyntaxHighlighter(mDoc);
}

void Document::applySettings(Settings::Manager* settings) {
    QFont font = settings->codeFont();
    int indentWidth = settings->value("IDE/editor/indentWidth").toInt();

    setDefaultFont(font);
    setIndentWidth(indentWidth);
}

void Document::deleteTrailingSpaces() {
    QTextCursor cursor(textDocument());
    cursor.beginEditBlock();
    cursor.movePosition(QTextCursor::EndOfBlock);
    QTextDocument* doc = textDocument();

    while (!cursor.atEnd()) {
        while ((cursor.block().length() > 1) && doc->characterAt(cursor.position() - 1).isSpace())
            cursor.deletePreviousChar();

        cursor.movePosition(QTextCursor::NextBlock);
        cursor.movePosition(QTextCursor::EndOfBlock);
    }
    cursor.endEditBlock();
}

void Document::setDefaultFont(const QFont& font) {
    mDoc->setDefaultFont(font);
    // update tab stop, since it depends on font:
    setIndentWidth(mIndentWidth);
    emit defaultFontChanged();
}

void Document::resetDefaultFont() {
    Settings::Manager* settings = Main::settings();
    setDefaultFont(settings->codeFont());
}

void Document::setIndentWidth(int numSpaces) {
    mIndentWidth = numSpaces;

    QFontMetricsF fontMetrics(mDoc->defaultFont());
    qreal tabStop = fontMetrics.horizontalAdvance(' ') * numSpaces;

    QTextOption options = mDoc->defaultTextOption();

    options.setTabStopDistance(tabStop);

    mDoc->setDefaultTextOption(options);
}

QString Document::textAsSCArrayOfCharCodes(int start = 0, int range = -1) {
    QTextCursor cursor = QTextCursor(mDoc);
    cursor.setPosition(start, QTextCursor::MoveAnchor);
    if (range == -1) {
        cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);
    } else {
        cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, range);
    }

    QByteArray stringBytes = cursor.selectedText().replace(QChar(0x2029), QChar('\n')).toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
}

QString Document::titleAsSCArrayOfCharCodes() {
    QByteArray stringBytes = mTitle.toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
}

QString Document::pathAsSCArrayOfCharCodes() {
    QString path;
    if (mFilePath.isEmpty()) {
        return QStringLiteral("nil");
    } else {
        path = mFilePath;
    }
    QByteArray stringBytes = path.toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
    ;
}

QString Document::bytesToSCArrayOfCharCodes(QByteArray stringBytes) {
    QString returnString = QStringLiteral("[");
    for (int i = 0; i < stringBytes.size(); ++i) {
        returnString = returnString.append(QString::number(static_cast<int>(stringBytes.at(i)))).append(',');
    }
    returnString = returnString.append(QStringLiteral("]"));
    return returnString;
}

void Document::setTextInRange(const QString text, int start, int range) {
    QTextCursor cursor = QTextCursor(mDoc);
    int size = mDoc->characterCount();
    if (start > (size - 1)) {
        start = size - 1;
        range = 0;
    }
    cursor.setPosition(start, QTextCursor::MoveAnchor);
    if (range == -1) {
        cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);
    } else {
        cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, range);
    }
    cursor.insertText(text);
}

void Document::onTmpCoalUsecs() {
    mTmpCoalCount = RESTORE_COAL;
    storeTmpFile();
}

void Document::storeTmpFile() {
    QString path, name;
    QDir tmpFilesDir = standardDirectory(ScConfigUserDir);
    int i = 0;

    if (!textDocument()->isModified())
        return;

    if (++mTmpCoalCount < RESTORE_COAL) {
        mTmpCoalTimer.start();
        return;
    }

    mTmpCoalCount = 0;

    if (!mTmpFilePath.isEmpty()) {
        path = mTmpFilePath;
        goto store;
    }

    if (mFilePath.isEmpty())
        name = QStringLiteral("Untitled");
    else
        name = QFileInfo(mFilePath).baseName();

    if (!tmpFilesDir.exists("tmp"))
        tmpFilesDir.mkdir("tmp");
    tmpFilesDir.cd("tmp");

    path = QStringLiteral("%1/%2.bak").arg(tmpFilesDir.absolutePath()).arg(name);
    while (QFile(path).exists())
        path = QStringLiteral("%1/%2-%3.bak").arg(tmpFilesDir.absolutePath()).arg(name).arg(++i);
    mTmpFilePath = path;

store:
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "DocumentManager: the file" << path << "could not be opened for writing.";
        return;
    }

    QString str = textDocument()->toPlainText();
    file.write(str.toUtf8());
    file.close();
}

void Document::removeTmpFile() {
    if (mTmpFilePath.isEmpty())
        return;

    if (!QFile(mTmpFilePath).remove())
        qWarning() << "DocumentManager: the file" << mTmpFilePath << "could not be removed.'";
    mTmpFilePath = "";
}

DocumentManager::DocumentManager(Main* main, Settings::Manager* settings):
    QObject(main),
    mTextMirrorEnabled(true),
    mCurrentDocument(NULL),
    mGlobalKeyDownEnabled(false),
    mGlobalKeyUpEnabled(false) {
    mDocumentModel = new QStandardItemModel(this);
    connect(&mFsWatcher, SIGNAL(fileChanged(QString)), this, SLOT(onFileChanged(QString)));

    connect(main, SIGNAL(storeSettingsRequest(Settings::Manager*)), this, SLOT(storeSettings(Settings::Manager*)));

    loadRecentDocuments(settings);
}

Document* DocumentManager::createDocument(bool isPlainText, const QByteArray& id, const QString& title,
                                          const QString& text) {
    Document* doc = new Document(isPlainText, id, title, text);
    mDocHash.insert(doc->id(), doc);

    QStandardItem* item = new QStandardItem(doc->title());
    doc->mModelItem = item;
    item->setData(QVariant::fromValue(doc));
    mDocumentModel->appendRow(item);
    QTextDocument* tdoc = doc->textDocument();
    connect(tdoc, SIGNAL(modificationChanged(bool)), doc, SLOT(onModificationChanged(bool)));
    return doc;
}

void DocumentManager::create() {
    Document* doc = createDocument();

    connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));
    syncLangDocument(doc);
    Q_EMIT(opened(doc, 0, 0));
}

Document* DocumentManager::open(const QString& path, int initialCursorPosition, int selectionLength, bool toRecent,
                                const QByteArray& id, bool syncLang) {
    QFileInfo info(path);
    QString cpath = info.canonicalFilePath();
    info.setFile(cpath);

    if (cpath.isEmpty()) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file: %1 (file does not exist)").arg(path));
        return 0;
    }

    // Check if file already opened
    for (DocIterator it = mDocHash.begin(); it != mDocHash.end(); ++it) {
        Document* doc = it.value();
        if (doc->mFilePath == cpath) {
            Q_EMIT(showRequest(doc, initialCursorPosition, selectionLength));
            if (toRecent)
                addToRecent(doc);
            return doc;
        }
    }

    // Open the file
    QFile file(cpath);
    if (!file.open(QIODevice::ReadOnly)) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(cpath));
        return 0;
    }
    QByteArray bytes(file.readAll());
    file.close();

    // strip .rtf
    bool isRTF = false;
    QString filePath = cpath;
    if (info.suffix() == QStringLiteral("rtf")) {
        isRTF = true;

        filePath += QStringLiteral(".scd");
        int result = rtf2txt(bytes.data());
        bytes = bytes.left(result);
        QMessageBox::warning(NULL, QString(tr("Opening RTF File")),
                             QString(tr("Warning: RTF file will be converted to plain-text scd file.")));
    }

    closeSingleUntitledIfUnmodified();

    const bool fileIsPlainText = !(info.suffix() == QStringLiteral("sc") || (info.suffix() == QStringLiteral("scd"))
                                   || (info.suffix() == QStringLiteral("schelp")));

    Document* doc = createDocument(fileIsPlainText, id);
    doc->mDoc->setPlainText(decodeDocument(bytes));
    doc->mDoc->setModified(false);
    doc->mFilePath = filePath;
    QString fileTitle = info.fileName();
    doc->setTitle(fileTitle);
    doc->mSaveTime = info.lastModified();
    doc->setInitialSelection(initialCursorPosition, selectionLength);
    connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));

    if (!isRTF)
        mFsWatcher.addPath(cpath);

    // if this was opened from the lang we don't need to sync
    if (syncLang) {
        syncLangDocument(doc);
    }
    Q_EMIT(opened(doc, initialCursorPosition, selectionLength));

    if (toRecent)
        this->addToRecent(doc);

    return doc;
}

bool DocumentManager::reload(Document* doc) {
    Q_ASSERT(doc);

    if (doc->mFilePath.isEmpty())
        return false;

    QFile file(doc->mFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(doc->mFilePath));
        return false;
    }

    QByteArray bytes(file.readAll());
    file.close();

    doc->mDoc->setPlainText(decodeDocument(bytes));
    doc->mDoc->setModified(false);

    QFileInfo info(doc->mFilePath);
    doc->mSaveTime = info.lastModified();

    if (!mFsWatcher.files().contains(doc->mFilePath))
        mFsWatcher.addPath(doc->mFilePath);

    return true;
}

QStringList DocumentManager::tmpFiles() {
    QDir tmpFilesDir = standardDirectory(ScConfigUserDir) + "/tmp";
    QStringList files = tmpFilesDir.entryList(QStringList("*.bak"), QDir::Files);
    int i;

    for (i = 0; i < files.size(); i++)
        files.replace(i, tmpFilesDir.absolutePath() + "/" + files[i]);

    return files;
}

bool DocumentManager::needRestore() { return (!tmpFiles().isEmpty()); }

void DocumentManager::restore() {
    foreach (QString path, tmpFiles()) {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly))
            MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(path));
        QByteArray bytes(file.readAll());
        file.close();
        Document* doc = createDocument(false, QByteArray(), QFileInfo(path).baseName(), decodeDocument(bytes));
        doc->mTmpFilePath = path;
        syncLangDocument(doc);
        Q_EMIT(opened(doc, 0, 0));
        connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));
    }
}

void DocumentManager::deleteRestore() {
    foreach (QString file, tmpFiles())
        QFile(file).remove();
}

Document* DocumentManager::documentForId(const QByteArray docID) {
    Document* doc = mDocHash.value(docID);
    if (!doc)
        MainWindow::instance()->showStatusMessage(
            QStringLiteral("Lookup failed for Document %1").arg(docID.constData()));
    return doc;
}

QString DocumentManager::decodeDocument(const QByteArray& bytes) {
    QTextStream stream(bytes);
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
    stream.setCodec("UTF-8");
#else
    stream.setEncoding(QStringConverter::Utf8);
#endif
    stream.setAutoDetectUnicode(true);
    return stream.readAll();
}

void DocumentManager::close(Document* doc) {
    Q_ASSERT(doc);

    doc->removeTmpFile();

    if (mDocHash.remove(doc->id()) == 0) {
        qWarning("DocumentManager: trying to close an unmanaged document.");
        return;
    }

    mDocumentModel->removeRow(mDocumentModel->indexFromItem(doc->mModelItem).row());

    if (!doc->mFilePath.isEmpty())
        mFsWatcher.removePath(doc->mFilePath);

    Q_EMIT(closed(doc));

    QString command = QStringLiteral("Document.findByQUuid(\'%1\').closed").arg(doc->id().constData());
    Main::evaluateCodeIfCompiled(command, true);

    doc->deleteLater();
}

bool DocumentManager::save(Document* doc) {
    Q_ASSERT(doc);

    return doSaveAs(doc, doc->mFilePath);
}

bool DocumentManager::saveAs(Document* doc, const QString& path) {
    Q_ASSERT(doc);

    if (path.isEmpty()) {
        qWarning() << "DocumentManager: the saving path is empty.";
        return false;
    }

    bool ok = doSaveAs(doc, path);
    if (ok)
        addToRecent(doc);
    return ok;
}

bool DocumentManager::doSaveAs(Document* doc, const QString& path) {
    Q_ASSERT(doc);

    doc->deleteTrailingSpaces();


    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "DocumentManager: the file" << path << "could not be opened for writing.";
        return false;
    }

    QFileInfo info(path);
    QString cpath = info.canonicalFilePath();

    const bool pathChanged = (!(doc->filePath().isEmpty()) && (cpath != doc->filePath()));
    if (pathChanged)
        mFsWatcher.removePath(doc->filePath());

    QString str = doc->textDocument()->toPlainText();
    file.write(str.toUtf8());
    file.flush();
    file.close();

    info.refresh();

    const bool fileIsPlainText = !(info.suffix() == QStringLiteral("sc") || (info.suffix() == QStringLiteral("scd"))
                                   || (info.suffix() == QStringLiteral("schelp")));

    // It's possible the mod time has not been updated - if it looks like that is the case,
    // just set it one second in the future, so we don't trip the external modification alarm.
    if (doc->mSaveTime == info.lastModified()) {
        doc->mSaveTime = QDateTime::currentDateTime().addMSecs(1000);
    } else {
        doc->mSaveTime = info.lastModified();
    }

    doc->mFilePath = cpath;
    QString fileTitle = info.fileName();
    doc->setTitle(fileTitle);
    doc->mDoc->setModified(false);
    doc->setPlainText(fileIsPlainText);
    doc->removeTmpFile();

    // Always try to start watching, because the file could have been removed:
    if (!mFsWatcher.files().contains(cpath))
        mFsWatcher.addPath(cpath);

    Q_EMIT(saved(doc));
    syncLangDocument(doc);

    return true;
}

void DocumentManager::onFileChanged(const QString& path) {
    DocIterator it;
    for (it = mDocHash.begin(); it != mDocHash.end(); ++it) {
        Document* doc = it.value();
        if (doc->mFilePath == path) {
            QFileInfo info(doc->mFilePath);

            // 1. Check if the file on disk is newer than the last time we saved it.
            if (doc->mSaveTime < info.lastModified()) {
                // Force auto-reload regardless of modified state
                if (reload(doc)) {
                    MainWindow::instance()->showStatusMessage(tr("Automatically reloaded: %1").arg(doc->mFilePath));
                }
            }
        }
    }
}

void DocumentManager::addToRecent(Document* doc) {
    const QString& path = doc->mFilePath;
    int i = mRecent.indexOf(path);
    if (i != -1)
        mRecent.move(i, 0);
    else {
        mRecent.prepend(path);
        if (mRecent.count() > mMaxRecent)
            mRecent.removeLast();
    }

    emit recentsChanged();
}

void DocumentManager::clearRecents() {
    mRecent.clear();
    emit recentsChanged();
}

void DocumentManager::loadRecentDocuments(Settings::Manager* settings) {
    QVariantList list = settings->value("IDE/recentDocuments").value<QVariantList>();
    mRecent.clear();
    foreach (const QVariant& var, list) {
        QString filePath = var.toString();
        if (QFile::exists(filePath))
            mRecent << filePath;
    }
}

void DocumentManager::storeSettings(Settings::Manager* settings) {
    QVariantList list;
    foreach (const QString& path, mRecent)
        list << QVariant(path);

    settings->setValue("IDE/recentDocuments", QVariant::fromValue<QVariantList>(list));
}

void DocumentManager::closeSingleUntitledIfUnmodified() {
    QList<Document*> openDocuments = documents();

    if (openDocuments.size() == 1) {
        Document* document = openDocuments.front();
        if (document->filePath().isEmpty() && !document->isModified())
            close(document);
    }
}

void DocumentManager::handleScLangMessage(const QString& selector, const QString& data) {
    static QString requestDocListSelector("requestDocumentList");
    static QString newDocSelector("newDocument");
    static QString openFileSelector("openFile");
    static QString getDocTextSelector("getDocumentText");
    static QString setDocTextSelector("setDocumentText");
    static QString setDocSelectionSelector("setDocumentSelection");
    static QString setDocEditableSelector("setDocumentEditable");
    static QString setDocPromptsToSaveSelector("setDocumentPromptsToSave");
    static QString setCurrentDocSelector("setCurrentDocument");
    static QString removeDocUndoSelector("removeDocUndo");
    static QString closeDocSelector("closeDocument");
    static QString saveDocSelector("saveDocument");
    static QString setDocTitleSelector("setDocumentTitle");
    static QString enableGlobalKeyDownSelector("enableDocumentGlobalKeyDownAction");
    static QString enableGlobalKeyUpSelector("enableDocumentGlobalKeyUpAction");
    static QString enableKeyDownSelector("enableDocumentKeyDownAction");
    static QString enableKeyUpSelector("enableDocumentKeyUpAction");
    static QString enableMouseDownSelector("enableDocumentMouseDownAction");
    static QString enableMouseUpSelector("enableDocumentMouseUpAction");
    static QString enableTextChangedSelector("enableDocumentTextChangedAction");
    static QString enableTextMirrorSelector("enableDocumentTextMirror");

    if (selector == requestDocListSelector)
        handleDocListScRequest();

    if (selector == newDocSelector)
        handleNewDocScRequest(data);

    if (selector == openFileSelector)
        handleOpenFileScRequest(data);

    if (selector == getDocTextSelector)
        handleGetDocTextScRequest(data);

    if (selector == setDocTextSelector)
        handleSetDocTextScRequest(data);

    if (selector == setDocSelectionSelector)
        handleSetDocSelectionScRequest(data);

    if (selector == setDocEditableSelector)
        handleSetDocEditableScRequest(data);

    if (selector == setDocPromptsToSaveSelector)
        handleSetDocPromptsToSaveScRequest(data);

    if (selector == setCurrentDocSelector)
        handleSetCurrentDocScRequest(data);

    if (selector == removeDocUndoSelector)
        handleRemoveDocUndoScRequest(data);

    if (selector == closeDocSelector)
        handleCloseDocScRequest(data);

    if (selector == saveDocSelector)
        handleSaveDocScRequest(data);

    if (selector == setDocTitleSelector)
        handleSetDocTitleScRequest(data);

    if (selector == enableKeyDownSelector)
        handleEnableKeyDownScRequest(data);

    if (selector == enableKeyUpSelector)
        handleEnableKeyUpScRequest(data);

    if (selector == enableGlobalKeyDownSelector)
        handleEnableGlobalKeyDownScRequest(data);

    if (selector == enableGlobalKeyUpSelector)
        handleEnableGlobalKeyUpScRequest(data);

    if (selector == enableMouseDownSelector)
        handleEnableMouseDownScRequest(data);

    if (selector == enableMouseUpSelector)
        handleEnableMouseUpScRequest(data);

    if (selector == enableTextChangedSelector)
        handleEnableTextChangedScRequest(data);

    if (selector == enableTextMirrorSelector)
        handleEnableTextMirrorScRequest(data);
}

void DocumentManager::handleDocListScRequest() {
    QList<Document*> docs = documents();
    QList<Document*>::Iterator it;
    QString command = QStringLiteral("Document.syncDocs([");
    for (it = docs.begin(); it != docs.end(); ++it) {
        Document* doc = *it;
        int start, range;
        if (doc->lastActiveEditor()) { // we might have changed selection before sync happened
            QTextCursor cursor = doc->lastActiveEditor()->textCursor();
            start = cursor.selectionStart();
            range = cursor.selectionEnd() - start;
        } else {
            start = doc->initialSelectionStart();
            range = doc->initialSelectionRange();
        }
        QString docData = QStringLiteral("[\'%1\', %2, %3, %4, %5, %6, %7],")
                              .arg(doc->id().constData())
                              .arg(doc->titleAsSCArrayOfCharCodes())
                              .arg(doc->textAsSCArrayOfCharCodes(0, -1))
                              .arg(doc->isModified())
                              .arg(doc->pathAsSCArrayOfCharCodes())
                              .arg(start)
                              .arg(range);
        command = command.append(docData);
    }
    command = command.append("]);");
    command = command.append(QStringLiteral("ScIDE.prSignalHandshakeCond;"));
    Main::evaluateCode(command, true);
}

void DocumentManager::handleNewDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string title = doc[0].as<std::string>();
            std::string text = doc[1].as<std::string>();
            std::string id = doc[2].as<std::string>();

            Document* document =
                createDocument(false, id.c_str(), QString::fromUtf8(title.c_str()), QString::fromUtf8(text.c_str()));
            syncLangDocument(document);
            Q_EMIT(opened(document, 0, 0));
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleOpenFileScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string path = doc[0].as<std::string>();
            int position = doc[1].as<int>();
            int selectionLength = doc[2].as<int>();
            std::string id = doc[3].as<std::string>();

            // we don't need to sync with lang in this case
            open(QString(path.c_str()), position, selectionLength, true, id.c_str(), false);
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what() << "\n";
        return;
    }
}

void DocumentManager::handleGetDocTextScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string funcID = doc[1].as<std::string>();
            int start = doc[2].as<int>();
            int range = doc[3].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                QString docText = document->textAsSCArrayOfCharCodes(start, range);

                QString command = QStringLiteral("Document.executeAsyncResponse(\'%1\', %2.collect({|x| "
                                                 "{x.asInteger.asAscii}.try ? \"\" }).join)")
                                      .arg(funcID.c_str(), docText);
                Main::evaluateCode(command, true);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what() << "\n";
        return;
    }
}

void DocumentManager::handleSetDocTextScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            // Parse funcID (doc[1]) later, if it was not null.
            std::string id = doc[0].as<std::string>();
            std::string text = doc[2].as<std::string>();
            int start = doc[3].as<int>();
            int range = doc[4].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                // avoid a loop
                if (document == mCurrentDocument) {
                    disconnect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                               SLOT(updateCurrentDocContents(int, int, int)));
                }

                document->setTextInRange(QString::fromUtf8(text.c_str()), start, range);

                if (document == mCurrentDocument) {
                    connect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                            SLOT(updateCurrentDocContents(int, int, int)));
                }

                // Only execute a call if a function name was passed.
                if (!doc[1].IsNull()) {
                    std::string funcID = doc[1].as<std::string>("");
                    QString command = QStringLiteral("Document.executeAsyncResponse(\'%1\')").arg(funcID.c_str());
                    Main::evaluateCode(command, true);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocSelectionScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            int start = doc[1].as<int>();
            int range = doc[2].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                if (document->lastActiveEditor()) {
                    document->lastActiveEditor()->showPosition(start, range);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocEditableScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            bool editable = doc[1].as<bool>();

            Document* document = documentForId(id.c_str());
            if (document) {
                document->setEditable(editable);
                if (document->lastActiveEditor()) {
                    document->lastActiveEditor()->setReadOnly(!editable);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocPromptsToSaveScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            bool promptsToSave = doc[1].as<bool>();

            Document* document = documentForId(id.c_str());
            if (document) {
                document->setPromptsToSave(promptsToSave);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetCurrentDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();

            Document* document = documentForId(id.c_str());
            if (document)
                Q_EMIT(showRequest(document));
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleRemoveDocUndoScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();

            Document* document = documentForId(id.c_str());
            if (document) {
                QTextDocument* textDoc = document->textDocument();
                textDoc->clearUndoRedoStacks();
                textDoc->setModified(false);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleCloseDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                close(document);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSaveDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string path = doc[1].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                saveAs(document, QString::fromUtf8(path.c_str()));
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocTitleScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string title = doc[1].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                document->mTitle = QString::fromUtf8(title.c_str());
                Q_EMIT(titleChanged(document));
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

bool DocumentManager::parseActionEnabledRequest(const QString& data, std::string* idString, bool* en) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return false;

            std::string id = doc[0].as<std::string>();
            bool enabled = doc[1].as<bool>();

            *idString = id;
            *en = enabled;

            return true;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
    return false;
}

void DocumentManager::handleEnableKeyDownScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setKeyDownActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableKeyUpScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setKeyUpActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableGlobalKeyDownScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>(enabled);
            mGlobalKeyDownEnabled = enabled;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::handleEnableGlobalKeyUpScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>();

            mGlobalKeyUpEnabled = enabled;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::handleEnableMouseDownScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setMouseDownActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableMouseUpScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setMouseUpActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableTextChangedScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setTextChangedActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableTextMirrorScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>();

            mTextMirrorEnabled = enabled;

            QList<Document*> docs = documents();
            QList<Document*>::Iterator it;
            if (enabled) {
                for (it = docs.begin(); it != docs.end(); ++it) {
                    Document* doc = *it;
                    Main::scProcess()->updateTextMirrorForDocument(doc, 0, -1, doc->textDocument()->characterCount());
                    doc->lastActiveEditor()->updateDocLastSelection();
                }
            } else {
                // this sets the mirror to empty strings
                for (it = docs.begin(); it != docs.end(); ++it) {
                    Document* doc = *it;
                    Main::scProcess()->updateTextMirrorForDocument(doc, 0, -1, 0);
                }
                QString warning = QStringLiteral("Document Text Mirror Disabled\n");
                Main::scProcess()->post(warning);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::syncLangDocument(Document* doc) {
    int start, range;
    if (doc->lastActiveEditor()) { // we might have changed selection before sync happened
        QTextCursor cursor = doc->lastActiveEditor()->textCursor();
        start = cursor.selectionStart();
        range = cursor.selectionEnd() - start;
    } else {
        start = doc->initialSelectionStart();
        range = doc->initialSelectionRange();
    }
    QString command = QStringLiteral("Document.syncFromIDE(\'%1\', %2, %3, %4, %5, %6, %7)")
                          .arg(doc->id().constData())
                          .arg(doc->titleAsSCArrayOfCharCodes())
                          .arg(doc->textAsSCArrayOfCharCodes(0, -1))
                          .arg(doc->isModified())
                          .arg(doc->pathAsSCArrayOfCharCodes())
                          .arg(start)
                          .arg(range);
    Main::evaluateCodeIfCompiled(command, true);
}

void DocumentManager::setActiveDocument(Document* document) {
    if (mCurrentDocument)
        disconnect(mCurrentDocument->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                   SLOT(updateCurrentDocContents(int, int, int)));
    if (document) {
        mCurrentDocumentPath = document->filePath();
        connect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                SLOT(updateCurrentDocContents(int, int, int)));
        mCurrentDocument = document;
    } else {
        mCurrentDocumentPath.clear();
        mCurrentDocument = NULL;
    }

    sendActiveDocument();
}

void DocumentManager::sendActiveDocument() {
    if (Main::scProcess()->state() != QProcess::Running)
        return;
    if (mCurrentDocument) {
        QString command =
            QStringLiteral("Document.setActiveDocByQUuid(\'%1\');").arg(mCurrentDocument->id().constData());
        if (mCurrentDocumentPath.isEmpty()) {
            command = command.append(QStringLiteral("ScIDE.currentPath_(nil);"));
        } else {
            command = command.append(QStringLiteral("ScIDE.currentPath_(\"%1\");").arg(mCurrentDocumentPath));
        }
        command = command.append(QStringLiteral("ScIDE.prSignalHandshakeCond;"));
        Main::evaluateCodeIfCompiled(command, true);
    } else
        Main::evaluateCodeIfCompiled(
            QStringLiteral("ScIDE.currentPath_(nil); Document.current = nil; ScIDE.prSignalHandshakeCond;"), true);
}

void DocumentManager::updateCurrentDocContents(int position, int charsRemoved, int charsAdded) {
    if (mTextMirrorEnabled) {
        Main::scProcess()->updateTextMirrorForDocument(mCurrentDocument, position, charsRemoved, charsAdded);
    }

    if (mCurrentDocument->textChangedActionEnabled()) {
        QString addedChars = mCurrentDocument->textAsSCArrayOfCharCodes(position, charsAdded);
        Main::evaluateCode(QStringLiteral("Document.findByQUuid(\'%1\').textChanged(%2, %3, %4);")
                               .arg(mCurrentDocument->id().constData())
                               .arg(position)
                               .arg(charsRemoved)
                               .arg(addedChars),
                           true);
    }
}
===
/*
    SuperCollider Qt IDE
    Copyright (c) 2012 Jakob Leben & Tim Blechmann
    http://www.audiosynth.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
*/

#include "doc_manager.hpp"
#include "main.hpp"
#include "main_window.hpp"
#include "settings/manager.hpp"
#include "../widgets/code_editor/highlighter.hpp"
#include "../../common/SC_TextUtils.hpp"
#include "util/standard_dirs.hpp"

#include <QPlainTextDocumentLayout>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QMessageBox>
#include <QTextBlock>
#include <QApplication>

#include <yaml-cpp/yaml.h>

using namespace ScIDE;

Document::Document(bool isPlainText, const QByteArray& id, const QString& title, const QString& text):
    mId(id),
    mDoc(new QTextDocument(text, this)),
    mTitle(title),
    mIndentWidth(4),
    mHighlighter(0),
    mKeyDownActionEnabled(false),
    mKeyUpActionEnabled(false),
    mMouseDownActionEnabled(false),
    mMouseUpActionEnabled(false),
    mTextChangedActionEnabled(false),
    mLastActiveEditor(0),
    mInitialSelectionStart(0),
    mInitialSelectionRange(0),
    mEditable(true),
    mPromptsToSave(true) {
    mTmpCoalCount = 0;
    mTmpCoalTimer.setInterval(RESTORE_COAL_MSECS);
    mTmpCoalTimer.setSingleShot(true);
    connect(&mTmpCoalTimer, SIGNAL(timeout()), this, SLOT(onTmpCoalUsecs()));

    if (mId.isEmpty())
        mId = QUuid::createUuid().toString().toLatin1();
    if (mTitle.isEmpty())
        mTitle = tr("Untitled");

    mDoc->setDocumentLayout(new QPlainTextDocumentLayout(mDoc));

    if (!isPlainText)
        mHighlighter = new SyntaxHighlighter(mDoc);

    connect(Main::instance(), SIGNAL(applySettingsRequest(Settings::Manager*)), this,
            SLOT(applySettings(Settings::Manager*)));

    applySettings(Main::settings());
}

void Document::setPlainText(bool set_plain_text) {
    if (isPlainText() == set_plain_text)
        return;

    delete mHighlighter;
    mHighlighter = 0;

    if (!set_plain_text)
        mHighlighter = new SyntaxHighlighter(mDoc);
}

void Document::applySettings(Settings::Manager* settings) {
    QFont font = settings->codeFont();
    int indentWidth = settings->value("IDE/editor/indentWidth").toInt();

    setDefaultFont(font);
    setIndentWidth(indentWidth);
}

void Document::deleteTrailingSpaces() {
    QTextCursor cursor(textDocument());
    cursor.beginEditBlock();
    cursor.movePosition(QTextCursor::EndOfBlock);
    QTextDocument* doc = textDocument();

    while (!cursor.atEnd()) {
        while ((cursor.block().length() > 1) && doc->characterAt(cursor.position() - 1).isSpace())
            cursor.deletePreviousChar();

        cursor.movePosition(QTextCursor::NextBlock);
        cursor.movePosition(QTextCursor::EndOfBlock);
    }
    cursor.endEditBlock();
}

void Document::setDefaultFont(const QFont& font) {
    mDoc->setDefaultFont(font);
    // update tab stop, since it depends on font:
    setIndentWidth(mIndentWidth);
    emit defaultFontChanged();
}

void Document::resetDefaultFont() {
    Settings::Manager* settings = Main::settings();
    setDefaultFont(settings->codeFont());
}

void Document::setIndentWidth(int numSpaces) {
    mIndentWidth = numSpaces;

    QFontMetricsF fontMetrics(mDoc->defaultFont());
    qreal tabStop = fontMetrics.horizontalAdvance(' ') * numSpaces;

    QTextOption options = mDoc->defaultTextOption();

    options.setTabStopDistance(tabStop);

    mDoc->setDefaultTextOption(options);
}

QString Document::textAsSCArrayOfCharCodes(int start = 0, int range = -1) {
    QTextCursor cursor = QTextCursor(mDoc);
    cursor.setPosition(start, QTextCursor::MoveAnchor);
    if (range == -1) {
        cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);
    } else {
        cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, range);
    }

    QByteArray stringBytes = cursor.selectedText().replace(QChar(0x2029), QChar('\n')).toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
}

QString Document::titleAsSCArrayOfCharCodes() {
    QByteArray stringBytes = mTitle.toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
}

QString Document::pathAsSCArrayOfCharCodes() {
    QString path;
    if (mFilePath.isEmpty()) {
        return QStringLiteral("nil");
    } else {
        path = mFilePath;
    }
    QByteArray stringBytes = path.toUtf8();
    return bytesToSCArrayOfCharCodes(stringBytes);
    ;
}

QString Document::bytesToSCArrayOfCharCodes(QByteArray stringBytes) {
    QString returnString = QStringLiteral("[");
    for (int i = 0; i < stringBytes.size(); ++i) {
        returnString = returnString.append(QString::number(static_cast<int>(stringBytes.at(i)))).append(',');
    }
    returnString = returnString.append(QStringLiteral("]"));
    return returnString;
}

void Document::setTextInRange(const QString text, int start, int range) {
    QTextCursor cursor = QTextCursor(mDoc);
    int size = mDoc->characterCount();
    if (start > (size - 1)) {
        start = size - 1;
        range = 0;
    }
    cursor.setPosition(start, QTextCursor::MoveAnchor);
    if (range == -1) {
        cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor, 1);
    } else {
        cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, range);
    }
    cursor.insertText(text);
}

void Document::onTmpCoalUsecs() {
    mTmpCoalCount = RESTORE_COAL;
    storeTmpFile();
}

void Document::storeTmpFile() {
    QString path, name;
    QDir tmpFilesDir = standardDirectory(ScConfigUserDir);
    int i = 0;

    if (!textDocument()->isModified())
        return;

    if (++mTmpCoalCount < RESTORE_COAL) {
        mTmpCoalTimer.start();
        return;
    }

    mTmpCoalCount = 0;

    if (!mTmpFilePath.isEmpty()) {
        path = mTmpFilePath;
        goto store;
    }

    if (mFilePath.isEmpty())
        name = QStringLiteral("Untitled");
    else
        name = QFileInfo(mFilePath).baseName();

    if (!tmpFilesDir.exists("tmp"))
        tmpFilesDir.mkdir("tmp");
    tmpFilesDir.cd("tmp");

    path = QStringLiteral("%1/%2.bak").arg(tmpFilesDir.absolutePath()).arg(name);
    while (QFile(path).exists())
        path = QStringLiteral("%1/%2-%3.bak").arg(tmpFilesDir.absolutePath()).arg(name).arg(++i);
    mTmpFilePath = path;

store:
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "DocumentManager: the file" << path << "could not be opened for writing.";
        return;
    }

    QString str = textDocument()->toPlainText();
    file.write(str.toUtf8());
    file.close();
}

void Document::removeTmpFile() {
    if (mTmpFilePath.isEmpty())
        return;

    if (!QFile(mTmpFilePath).remove())
        qWarning() << "DocumentManager: the file" << mTmpFilePath << "could not be removed.'";
    mTmpFilePath = "";
}

DocumentManager::DocumentManager(Main* main, Settings::Manager* settings):
    QObject(main),
    mTextMirrorEnabled(true),
    mAutoEvaluateEnabled(true),
    mCurrentDocument(NULL),
    mGlobalKeyDownEnabled(false),
    mGlobalKeyUpEnabled(false) {
    mDocumentModel = new QStandardItemModel(this);
    connect(&mFsWatcher, SIGNAL(fileChanged(QString)), this, SLOT(onFileChanged(QString)));

    connect(main, SIGNAL(storeSettingsRequest(Settings::Manager*)), this, SLOT(storeSettings(Settings::Manager*)));

    loadRecentDocuments(settings);
}

Document* DocumentManager::createDocument(bool isPlainText, const QByteArray& id, const QString& title,
                                          const QString& text) {
    Document* doc = new Document(isPlainText, id, title, text);
    mDocHash.insert(doc->id(), doc);

    QStandardItem* item = new QStandardItem(doc->title());
    doc->mModelItem = item;
    item->setData(QVariant::fromValue(doc));
    mDocumentModel->appendRow(item);
    QTextDocument* tdoc = doc->textDocument();
    connect(tdoc, SIGNAL(modificationChanged(bool)), doc, SLOT(onModificationChanged(bool)));
    return doc;
}

void DocumentManager::create() {
    Document* doc = createDocument();

    connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));
    syncLangDocument(doc);
    Q_EMIT(opened(doc, 0, 0));
}

Document* DocumentManager::open(const QString& path, int initialCursorPosition, int selectionLength, bool toRecent,
                                const QByteArray& id, bool syncLang) {
    QFileInfo info(path);
    QString cpath = info.canonicalFilePath();
    info.setFile(cpath);

    if (cpath.isEmpty()) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file: %1 (file does not exist)").arg(path));
        return 0;
    }

    // Check if file already opened
    for (DocIterator it = mDocHash.begin(); it != mDocHash.end(); ++it) {
        Document* doc = it.value();
        if (doc->mFilePath == cpath) {
            Q_EMIT(showRequest(doc, initialCursorPosition, selectionLength));
            if (toRecent)
                addToRecent(doc);
            return doc;
        }
    }

    // Open the file
    QFile file(cpath);
    if (!file.open(QIODevice::ReadOnly)) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(cpath));
        return 0;
    }
    QByteArray bytes(file.readAll());
    file.close();

    // strip .rtf
    bool isRTF = false;
    QString filePath = cpath;
    if (info.suffix() == QStringLiteral("rtf")) {
        isRTF = true;

        filePath += QStringLiteral(".scd");
        int result = rtf2txt(bytes.data());
        bytes = bytes.left(result);
        QMessageBox::warning(NULL, QString(tr("Opening RTF File")),
                             QString(tr("Warning: RTF file will be converted to plain-text scd file.")));
    }

    closeSingleUntitledIfUnmodified();

    const bool fileIsPlainText = !(info.suffix() == QStringLiteral("sc") || (info.suffix() == QStringLiteral("scd"))
                                   || (info.suffix() == QStringLiteral("schelp")));

    Document* doc = createDocument(fileIsPlainText, id);
    doc->mDoc->setPlainText(decodeDocument(bytes));
    doc->mDoc->setModified(false);
    doc->mFilePath = filePath;
    QString fileTitle = info.fileName();
    doc->setTitle(fileTitle);
    doc->mSaveTime = info.lastModified();
    doc->setInitialSelection(initialCursorPosition, selectionLength);
    connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));

    if (!isRTF)
        mFsWatcher.addPath(cpath);

    // if this was opened from the lang we don't need to sync
    if (syncLang) {
        syncLangDocument(doc);
    }
    Q_EMIT(opened(doc, initialCursorPosition, selectionLength));

    if (toRecent)
        this->addToRecent(doc);

    return doc;
}

bool DocumentManager::reload(Document* doc) {
    Q_ASSERT(doc);

    if (doc->mFilePath.isEmpty())
        return false;

    QFile file(doc->mFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(doc->mFilePath));
        return false;
    }

    QByteArray bytes(file.readAll());
    file.close();

    doc->mDoc->setPlainText(decodeDocument(bytes));
    doc->mDoc->setModified(false);

    QFileInfo info(doc->mFilePath);
    doc->mSaveTime = info.lastModified();

    if (!mFsWatcher.files().contains(doc->mFilePath))
        mFsWatcher.addPath(doc->mFilePath);

    return true;
}

QStringList DocumentManager::tmpFiles() {
    QDir tmpFilesDir = standardDirectory(ScConfigUserDir) + "/tmp";
    QStringList files = tmpFilesDir.entryList(QStringList("*.bak"), QDir::Files);
    int i;

    for (i = 0; i < files.size(); i++)
        files.replace(i, tmpFilesDir.absolutePath() + "/" + files[i]);

    return files;
}

bool DocumentManager::needRestore() { return (!tmpFiles().isEmpty()); }

void DocumentManager::restore() {
    foreach (QString path, tmpFiles()) {
        QFile file(path);
        if (!file.open(QIODevice::ReadOnly))
            MainWindow::instance()->showStatusMessage(tr("Cannot open file for reading: %1").arg(path));
        QByteArray bytes(file.readAll());
        file.close();
        Document* doc = createDocument(false, QByteArray(), QFileInfo(path).baseName(), decodeDocument(bytes));
        doc->mTmpFilePath = path;
        syncLangDocument(doc);
        Q_EMIT(opened(doc, 0, 0));
        connect(doc->textDocument(), SIGNAL(contentsChanged()), doc, SLOT(storeTmpFile()));
    }
}

void DocumentManager::deleteRestore() {
    foreach (QString file, tmpFiles())
        QFile(file).remove();
}

Document* DocumentManager::documentForId(const QByteArray docID) {
    Document* doc = mDocHash.value(docID);
    if (!doc)
        MainWindow::instance()->showStatusMessage(
            QStringLiteral("Lookup failed for Document %1").arg(docID.constData()));
    return doc;
}

QString DocumentManager::decodeDocument(const QByteArray& bytes) {
    QTextStream stream(bytes);
#if (QT_VERSION < QT_VERSION_CHECK(6, 0, 0))
    stream.setCodec("UTF-8");
#else
    stream.setEncoding(QStringConverter::Utf8);
#endif
    stream.setAutoDetectUnicode(true);
    return stream.readAll();
}

void DocumentManager::close(Document* doc) {
    Q_ASSERT(doc);

    doc->removeTmpFile();

    if (mDocHash.remove(doc->id()) == 0) {
        qWarning("DocumentManager: trying to close an unmanaged document.");
        return;
    }

    mDocumentModel->removeRow(mDocumentModel->indexFromItem(doc->mModelItem).row());

    if (!doc->mFilePath.isEmpty())
        mFsWatcher.removePath(doc->mFilePath);

    Q_EMIT(closed(doc));

    QString command = QStringLiteral("Document.findByQUuid(\'%1\').closed").arg(doc->id().constData());
    Main::evaluateCodeIfCompiled(command, true);

    doc->deleteLater();
}

bool DocumentManager::save(Document* doc) {
    Q_ASSERT(doc);

    return doSaveAs(doc, doc->mFilePath);
}

bool DocumentManager::saveAs(Document* doc, const QString& path) {
    Q_ASSERT(doc);

    if (path.isEmpty()) {
        qWarning() << "DocumentManager: the saving path is empty.";
        return false;
    }

    bool ok = doSaveAs(doc, path);
    if (ok)
        addToRecent(doc);
    return ok;
}

bool DocumentManager::doSaveAs(Document* doc, const QString& path) {
    Q_ASSERT(doc);

    doc->deleteTrailingSpaces();


    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "DocumentManager: the file" << path << "could not be opened for writing.";
        return false;
    }

    QFileInfo info(path);
    QString cpath = info.canonicalFilePath();

    const bool pathChanged = (!(doc->filePath().isEmpty()) && (cpath != doc->filePath()));
    if (pathChanged)
        mFsWatcher.removePath(doc->filePath());

    QString str = doc->textDocument()->toPlainText();
    file.write(str.toUtf8());
    file.flush();
    file.close();

    info.refresh();

    const bool fileIsPlainText = !(info.suffix() == QStringLiteral("sc") || (info.suffix() == QStringLiteral("scd"))
                                   || (info.suffix() == QStringLiteral("schelp")));

    // It's possible the mod time has not been updated - if it looks like that is the case,
    // just set it one second in the future, so we don't trip the external modification alarm.
    if (doc->mSaveTime == info.lastModified()) {
        doc->mSaveTime = QDateTime::currentDateTime().addMSecs(1000);
    } else {
        doc->mSaveTime = info.lastModified();
    }

    doc->mFilePath = cpath;
    QString fileTitle = info.fileName();
    doc->setTitle(fileTitle);
    doc->mDoc->setModified(false);
    doc->setPlainText(fileIsPlainText);
    doc->removeTmpFile();

    // Always try to start watching, because the file could have been removed:
    if (!mFsWatcher.files().contains(cpath))
        mFsWatcher.addPath(cpath);

    Q_EMIT(saved(doc));
    syncLangDocument(doc);

    return true;
}

void DocumentManager::onFileChanged(const QString& path) {
    DocIterator it;
    for (it = mDocHash.begin(); it != mDocHash.end(); ++it) {
        Document* doc = it.value();
        if (doc->mFilePath == path) {
            QFileInfo info(doc->mFilePath);

            // 1. Check if the file on disk is newer than the last time we saved it.
            if (doc->mSaveTime < info.lastModified()) {
                // Force auto-reload regardless of modified state
                if (reload(doc)) {
                    MainWindow::instance()->showStatusMessage(tr("Automatically reloaded: %1").arg(doc->mFilePath));

                    // Auto-evaluate the last region if enabled
                    if (mAutoEvaluateEnabled) {
                        autoEvaluateLastRegion(doc);
                    }
                }
            }
        }
    }
}

void DocumentManager::autoEvaluateLastRegion(Document* doc) {
    if (!doc || !doc->textDocument())
        return;

    QString text = doc->textDocument()->toPlainText();
    if (text.isEmpty())
        return;

    // Scan backwards to find the last top-level parenthesized region.
    // In SC, a top-level region is a '(' at the start of a line matched
    // with its closing ')'.
    int depth = 0;
    int regionEnd = -1;
    int regionStart = -1;

    for (int i = text.length() - 1; i >= 0; --i) {
        QChar ch = text[i];
        if (ch == ')') {
            if (depth == 0)
                regionEnd = i;
            depth++;
        } else if (ch == '(') {
            depth--;
            if (depth == 0 && regionEnd >= 0) {
                // Check if '(' is at the start of a line (column 0)
                bool atLineStart = (i == 0 || text[i - 1] == '\n');
                if (atLineStart) {
                    regionStart = i;
                    break;
                }
            }
        }
    }

    if (regionStart >= 0 && regionEnd >= 0 && regionEnd > regionStart) {
        QString regionText = text.mid(regionStart, regionEnd - regionStart + 1);
        regionText.replace(QChar(0x2029), QChar('\n'));
        Main::evaluateCode(regionText);
        MainWindow::instance()->showStatusMessage(
            tr("Auto-evaluated last region (%1 chars)").arg(regionText.length()));
    }
}

void DocumentManager::addToRecent(Document* doc) {
    const QString& path = doc->mFilePath;
    int i = mRecent.indexOf(path);
    if (i != -1)
        mRecent.move(i, 0);
    else {
        mRecent.prepend(path);
        if (mRecent.count() > mMaxRecent)
            mRecent.removeLast();
    }

    emit recentsChanged();
}

void DocumentManager::clearRecents() {
    mRecent.clear();
    emit recentsChanged();
}

void DocumentManager::loadRecentDocuments(Settings::Manager* settings) {
    QVariantList list = settings->value("IDE/recentDocuments").value<QVariantList>();
    mRecent.clear();
    foreach (const QVariant& var, list) {
        QString filePath = var.toString();
        if (QFile::exists(filePath))
            mRecent << filePath;
    }
}

void DocumentManager::storeSettings(Settings::Manager* settings) {
    QVariantList list;
    foreach (const QString& path, mRecent)
        list << QVariant(path);

    settings->setValue("IDE/recentDocuments", QVariant::fromValue<QVariantList>(list));
}

void DocumentManager::closeSingleUntitledIfUnmodified() {
    QList<Document*> openDocuments = documents();

    if (openDocuments.size() == 1) {
        Document* document = openDocuments.front();
        if (document->filePath().isEmpty() && !document->isModified())
            close(document);
    }
}

void DocumentManager::handleScLangMessage(const QString& selector, const QString& data) {
    static QString requestDocListSelector("requestDocumentList");
    static QString newDocSelector("newDocument");
    static QString openFileSelector("openFile");
    static QString getDocTextSelector("getDocumentText");
    static QString setDocTextSelector("setDocumentText");
    static QString setDocSelectionSelector("setDocumentSelection");
    static QString setDocEditableSelector("setDocumentEditable");
    static QString setDocPromptsToSaveSelector("setDocumentPromptsToSave");
    static QString setCurrentDocSelector("setCurrentDocument");
    static QString removeDocUndoSelector("removeDocUndo");
    static QString closeDocSelector("closeDocument");
    static QString saveDocSelector("saveDocument");
    static QString setDocTitleSelector("setDocumentTitle");
    static QString enableGlobalKeyDownSelector("enableDocumentGlobalKeyDownAction");
    static QString enableGlobalKeyUpSelector("enableDocumentGlobalKeyUpAction");
    static QString enableKeyDownSelector("enableDocumentKeyDownAction");
    static QString enableKeyUpSelector("enableDocumentKeyUpAction");
    static QString enableMouseDownSelector("enableDocumentMouseDownAction");
    static QString enableMouseUpSelector("enableDocumentMouseUpAction");
    static QString enableTextChangedSelector("enableDocumentTextChangedAction");
    static QString enableTextMirrorSelector("enableDocumentTextMirror");

    if (selector == requestDocListSelector)
        handleDocListScRequest();

    if (selector == newDocSelector)
        handleNewDocScRequest(data);

    if (selector == openFileSelector)
        handleOpenFileScRequest(data);

    if (selector == getDocTextSelector)
        handleGetDocTextScRequest(data);

    if (selector == setDocTextSelector)
        handleSetDocTextScRequest(data);

    if (selector == setDocSelectionSelector)
        handleSetDocSelectionScRequest(data);

    if (selector == setDocEditableSelector)
        handleSetDocEditableScRequest(data);

    if (selector == setDocPromptsToSaveSelector)
        handleSetDocPromptsToSaveScRequest(data);

    if (selector == setCurrentDocSelector)
        handleSetCurrentDocScRequest(data);

    if (selector == removeDocUndoSelector)
        handleRemoveDocUndoScRequest(data);

    if (selector == closeDocSelector)
        handleCloseDocScRequest(data);

    if (selector == saveDocSelector)
        handleSaveDocScRequest(data);

    if (selector == setDocTitleSelector)
        handleSetDocTitleScRequest(data);

    if (selector == enableKeyDownSelector)
        handleEnableKeyDownScRequest(data);

    if (selector == enableKeyUpSelector)
        handleEnableKeyUpScRequest(data);

    if (selector == enableGlobalKeyDownSelector)
        handleEnableGlobalKeyDownScRequest(data);

    if (selector == enableGlobalKeyUpSelector)
        handleEnableGlobalKeyUpScRequest(data);

    if (selector == enableMouseDownSelector)
        handleEnableMouseDownScRequest(data);

    if (selector == enableMouseUpSelector)
        handleEnableMouseUpScRequest(data);

    if (selector == enableTextChangedSelector)
        handleEnableTextChangedScRequest(data);

    if (selector == enableTextMirrorSelector)
        handleEnableTextMirrorScRequest(data);
}

void DocumentManager::handleDocListScRequest() {
    QList<Document*> docs = documents();
    QList<Document*>::Iterator it;
    QString command = QStringLiteral("Document.syncDocs([");
    for (it = docs.begin(); it != docs.end(); ++it) {
        Document* doc = *it;
        int start, range;
        if (doc->lastActiveEditor()) { // we might have changed selection before sync happened
            QTextCursor cursor = doc->lastActiveEditor()->textCursor();
            start = cursor.selectionStart();
            range = cursor.selectionEnd() - start;
        } else {
            start = doc->initialSelectionStart();
            range = doc->initialSelectionRange();
        }
        QString docData = QStringLiteral("[\'%1\', %2, %3, %4, %5, %6, %7],")
                              .arg(doc->id().constData())
                              .arg(doc->titleAsSCArrayOfCharCodes())
                              .arg(doc->textAsSCArrayOfCharCodes(0, -1))
                              .arg(doc->isModified())
                              .arg(doc->pathAsSCArrayOfCharCodes())
                              .arg(start)
                              .arg(range);
        command = command.append(docData);
    }
    command = command.append("]);");
    command = command.append(QStringLiteral("ScIDE.prSignalHandshakeCond;"));
    Main::evaluateCode(command, true);
}

void DocumentManager::handleNewDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string title = doc[0].as<std::string>();
            std::string text = doc[1].as<std::string>();
            std::string id = doc[2].as<std::string>();

            Document* document =
                createDocument(false, id.c_str(), QString::fromUtf8(title.c_str()), QString::fromUtf8(text.c_str()));
            syncLangDocument(document);
            Q_EMIT(opened(document, 0, 0));
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleOpenFileScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string path = doc[0].as<std::string>();
            int position = doc[1].as<int>();
            int selectionLength = doc[2].as<int>();
            std::string id = doc[3].as<std::string>();

            // we don't need to sync with lang in this case
            open(QString(path.c_str()), position, selectionLength, true, id.c_str(), false);
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what() << "\n";
        return;
    }
}

void DocumentManager::handleGetDocTextScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string funcID = doc[1].as<std::string>();
            int start = doc[2].as<int>();
            int range = doc[3].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                QString docText = document->textAsSCArrayOfCharCodes(start, range);

                QString command = QStringLiteral("Document.executeAsyncResponse(\'%1\', %2.collect({|x| "
                                                 "{x.asInteger.asAscii}.try ? \"\" }).join)")
                                      .arg(funcID.c_str(), docText);
                Main::evaluateCode(command, true);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what() << "\n";
        return;
    }
}

void DocumentManager::handleSetDocTextScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            // Parse funcID (doc[1]) later, if it was not null.
            std::string id = doc[0].as<std::string>();
            std::string text = doc[2].as<std::string>();
            int start = doc[3].as<int>();
            int range = doc[4].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                // avoid a loop
                if (document == mCurrentDocument) {
                    disconnect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                               SLOT(updateCurrentDocContents(int, int, int)));
                }

                document->setTextInRange(QString::fromUtf8(text.c_str()), start, range);

                if (document == mCurrentDocument) {
                    connect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                            SLOT(updateCurrentDocContents(int, int, int)));
                }

                // Only execute a call if a function name was passed.
                if (!doc[1].IsNull()) {
                    std::string funcID = doc[1].as<std::string>("");
                    QString command = QStringLiteral("Document.executeAsyncResponse(\'%1\')").arg(funcID.c_str());
                    Main::evaluateCode(command, true);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocSelectionScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            int start = doc[1].as<int>();
            int range = doc[2].as<int>();

            Document* document = documentForId(id.c_str());
            if (document) {
                if (document->lastActiveEditor()) {
                    document->lastActiveEditor()->showPosition(start, range);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocEditableScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            bool editable = doc[1].as<bool>();

            Document* document = documentForId(id.c_str());
            if (document) {
                document->setEditable(editable);
                if (document->lastActiveEditor()) {
                    document->lastActiveEditor()->setReadOnly(!editable);
                }
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocPromptsToSaveScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            bool promptsToSave = doc[1].as<bool>();

            Document* document = documentForId(id.c_str());
            if (document) {
                document->setPromptsToSave(promptsToSave);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetCurrentDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();

            Document* document = documentForId(id.c_str());
            if (document)
                Q_EMIT(showRequest(document));
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleRemoveDocUndoScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();

            Document* document = documentForId(id.c_str());
            if (document) {
                QTextDocument* textDoc = document->textDocument();
                textDoc->clearUndoRedoStacks();
                textDoc->setModified(false);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleCloseDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                close(document);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSaveDocScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string path = doc[1].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                saveAs(document, QString::fromUtf8(path.c_str()));
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

void DocumentManager::handleSetDocTitleScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            std::string id = doc[0].as<std::string>();
            std::string title = doc[1].as<std::string>();
            Document* document = documentForId(id.c_str());
            if (document) {
                document->mTitle = QString::fromUtf8(title.c_str());
                Q_EMIT(titleChanged(document));
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
        return;
    }
}

bool DocumentManager::parseActionEnabledRequest(const QString& data, std::string* idString, bool* en) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return false;

            std::string id = doc[0].as<std::string>();
            bool enabled = doc[1].as<bool>();

            *idString = id;
            *en = enabled;

            return true;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
    return false;
}

void DocumentManager::handleEnableKeyDownScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setKeyDownActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableKeyUpScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setKeyUpActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableGlobalKeyDownScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>(enabled);
            mGlobalKeyDownEnabled = enabled;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::handleEnableGlobalKeyUpScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>();

            mGlobalKeyUpEnabled = enabled;
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::handleEnableMouseDownScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setMouseDownActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableMouseUpScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setMouseUpActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableTextChangedScRequest(const QString& data) {
    std::string id;
    bool enabled;
    if (parseActionEnabledRequest(data, &id, &enabled)) {
        Document* document = documentForId(id.c_str());
        if (document) {
            document->setTextChangedActionEnabled(enabled);
        }
    }
}

void DocumentManager::handleEnableTextMirrorScRequest(const QString& data) {
    try {
        YAML::Node doc = YAML::Load(data.toStdString());
        if (doc) {
            if (!doc.IsSequence())
                return;

            bool enabled = doc[0].as<bool>();

            mTextMirrorEnabled = enabled;

            QList<Document*> docs = documents();
            QList<Document*>::Iterator it;
            if (enabled) {
                for (it = docs.begin(); it != docs.end(); ++it) {
                    Document* doc = *it;
                    Main::scProcess()->updateTextMirrorForDocument(doc, 0, -1, doc->textDocument()->characterCount());
                    doc->lastActiveEditor()->updateDocLastSelection();
                }
            } else {
                // this sets the mirror to empty strings
                for (it = docs.begin(); it != docs.end(); ++it) {
                    Document* doc = *it;
                    Main::scProcess()->updateTextMirrorForDocument(doc, 0, -1, 0);
                }
                QString warning = QStringLiteral("Document Text Mirror Disabled\n");
                Main::scProcess()->post(warning);
            }
        }
    } catch (std::exception const& e) {
        qWarning() << "DocumentManager::" << __FUNCTION__ << ": could not handle request:" << e.what();
    }
}

void DocumentManager::syncLangDocument(Document* doc) {
    int start, range;
    if (doc->lastActiveEditor()) { // we might have changed selection before sync happened
        QTextCursor cursor = doc->lastActiveEditor()->textCursor();
        start = cursor.selectionStart();
        range = cursor.selectionEnd() - start;
    } else {
        start = doc->initialSelectionStart();
        range = doc->initialSelectionRange();
    }
    QString command = QStringLiteral("Document.syncFromIDE(\'%1\', %2, %3, %4, %5, %6, %7)")
                          .arg(doc->id().constData())
                          .arg(doc->titleAsSCArrayOfCharCodes())
                          .arg(doc->textAsSCArrayOfCharCodes(0, -1))
                          .arg(doc->isModified())
                          .arg(doc->pathAsSCArrayOfCharCodes())
                          .arg(start)
                          .arg(range);
    Main::evaluateCodeIfCompiled(command, true);
}

void DocumentManager::setActiveDocument(Document* document) {
    if (mCurrentDocument)
        disconnect(mCurrentDocument->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                   SLOT(updateCurrentDocContents(int, int, int)));
    if (document) {
        mCurrentDocumentPath = document->filePath();
        connect(document->textDocument(), SIGNAL(contentsChange(int, int, int)), this,
                SLOT(updateCurrentDocContents(int, int, int)));
        mCurrentDocument = document;
    } else {
        mCurrentDocumentPath.clear();
        mCurrentDocument = NULL;
    }

    sendActiveDocument();
}

void DocumentManager::sendActiveDocument() {
    if (Main::scProcess()->state() != QProcess::Running)
        return;
    if (mCurrentDocument) {
        QString command =
            QStringLiteral("Document.setActiveDocByQUuid(\'%1\');").arg(mCurrentDocument->id().constData());
        if (mCurrentDocumentPath.isEmpty()) {
            command = command.append(QStringLiteral("ScIDE.currentPath_(nil);"));
        } else {
            command = command.append(QStringLiteral("ScIDE.currentPath_(\"%1\");").arg(mCurrentDocumentPath));
        }
        command = command.append(QStringLiteral("ScIDE.prSignalHandshakeCond;"));
        Main::evaluateCodeIfCompiled(command, true);
    } else
        Main::evaluateCodeIfCompiled(
            QStringLiteral("ScIDE.currentPath_(nil); Document.current = nil; ScIDE.prSignalHandshakeCond;"), true);
}

void DocumentManager::updateCurrentDocContents(int position, int charsRemoved, int charsAdded) {
    if (mTextMirrorEnabled) {
        Main::scProcess()->updateTextMirrorForDocument(mCurrentDocument, position, charsRemoved, charsAdded);
    }

    if (mCurrentDocument->textChangedActionEnabled()) {
        QString addedChars = mCurrentDocument->textAsSCArrayOfCharCodes(position, charsAdded);
        Main::evaluateCode(QStringLiteral("Document.findByQUuid(\'%1\').textChanged(%2, %3, %4);")
                               .arg(mCurrentDocument->id().constData())
                               .arg(position)
                               .arg(charsRemoved)
                               .arg(addedChars),
                           true);
    }
}
```

Three changes:
1. Constructor initializes `mAutoEvaluateEnabled = true`
2. [onFileChanged](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.cpp#540-562) calls [autoEvaluateLastRegion(doc)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.cpp#563-605) after successful reload
3. New [autoEvaluateLastRegion](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/editors/sc-ide/core/doc_manager.cpp#563-605) method: scans backwards for the last top-level [(...)](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/test_queries.py#71-91) region and evaluates it via `Main::evaluateCode`

## Validation

| Check | Result |
|---|---|
| [config.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/config.py) Python parse | ✓ Clean |
| [main.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/main.py) Python parse | ✓ Clean |
| [agent_graph_incremental.py](file:///c:/Users/Bruno%20Gazoni/Desktop/supercollider-project/sc-gen-rag/agent_graph_incremental.py) Python parse | ✓ Clean |

> [!IMPORTANT]
> **C++ changes require rebuilding the SC IDE** to take effect. The Python changes work independently — they will validate and write blocks, but auto-execution in the IDE requires the rebuilt binary.
