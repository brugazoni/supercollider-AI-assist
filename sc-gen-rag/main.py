import os
import config
# from agent_graph import build_graph # Ensure this imports your full graph
import rag_engine
import utils

def main():
    import sys
    if sys.stdout.encoding.lower() != 'utf-8':
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except AttributeError:
            pass
    if not os.path.exists(config.CONTEXT_FOLDER):
        os.makedirs(config.CONTEXT_FOLDER)
    
    print("==========================================")
    print(f"  SC-Graph | Provider: {config.CURRENT_LLM_PROVIDER}")
    print(f"  Knowledge DB: {config.KNOWLEDGE_DB_PATH}")
    print("==========================================")

    if not os.path.exists(config.KNOWLEDGE_DB_PATH):
        print("Vector Database not found. Building initial index...")
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

    # --- Correction Cycle Configuration ---
    print("\n  Validation & Correction:")
    use_correction = input(">> Use correction cycle? (y/n) [default: y]: ").strip().lower()
    validation_prefs = {
        "enabled": use_correction not in ("n", "no"),
        "mode": "2-tier",
        "llm_provider": config.CURRENT_LLM_PROVIDER,
        "scope": "programmatic"
    }

    if validation_prefs["enabled"]:
        print("\n  Correction Mode:")
        print("  (1) 2-Tier Structural System (Fast, strict syntax checking)")
        print("  (2) LLM Review (AI-powered analysis before testing)")
        val_mode = input(">> Mode (1/2) [default: 1]: ").strip()
        
        if val_mode == "2":
            validation_prefs["mode"] = "llm"
            print("\n  Select LLM API for review:")
            print("  [gemini, anthropic, openai]")
            provider = input(f">> Provider [default: {config.CURRENT_LLM_PROVIDER}]: ").strip().lower()
            if provider in ["gemini", "anthropic", "openai"]:
                validation_prefs["llm_provider"] = provider
            
            print("\n  Review Scope:")
            print("  (1) Programmatic only (Fix syntax and logic)")
            print("  (2) Programmatic + Aesthetic (Fix syntax, logic, and improve musicality)")
            scope = input(">> Scope (1/2) [default: 1]: ").strip()
            if scope == "2":
                validation_prefs["scope"] = "aesthetic"

    if mode == "2":
        from agent_graph_incremental import run_incremental_session

        # --- Auto-Execute Toggle ---
        print("\n  Auto-Execute will automatically validate and run each new block")
        print("  in the SC IDE without manual evaluation.")
        ae_input = input(">> Enable Auto-Execute? (y/n) [default: n]: ").strip().lower()
        auto_execute = ae_input in ("y", "yes")
        if auto_execute:
            print("  ✓ Auto-Execute ENABLED — blocks will be validated and run automatically.")
        else:
            print("  ○ Auto-Execute disabled — manual verification after each block.")

        run_incremental_session(auto_execute=auto_execute, validation_prefs=validation_prefs)
        return

    # --- One-Shot Mode ---
    from agent_graph import build_graph

    app = build_graph(validation_prefs=validation_prefs)

    while True:
        try:
            user_input = utils.get_multiline_input("Enter your composition request (One-Shot):").strip()
            if user_input.lower() in ["exit", "quit"]: break
            if not user_input: continue

            if user_input.lower() == "rebuild":
                rag_engine.build_all()
                continue
            
            invoke_state = {
                "user_query": user_input,
                "validation_prefs": validation_prefs
            }
            
            app.invoke(invoke_state)
            print("\nSession Complete.")
            
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except Exception as e:
            print(f"Runtime Error: {e}")

if __name__ == "__main__":
    main()
