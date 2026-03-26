# SC-Gen-RAG: Architecture & Implementation Documentation

This document serves as a comprehensive technical breakdown of the SC-Gen-RAG (SuperCollider Generative Retrieval-Augmented Generation) ecosystem. It details the underlying architectural choices, the validation pipelines, LLM agent integration via LangGraph, dual-database RAG strategies, and the modifications required in the SuperCollider IDE C++ source code to natively support an interactive, "hot-reloading" generative programming workflow.

---

## 1. Project Overview & Use Case Scenarios

The core objective of SC-Gen-RAG is to provide a seamless, AI-assisted live-coding and composition environment for SuperCollider. Instead of copy-pasting code from a web browser into the IDE, SC-Gen-RAG acts as a headless agent that composes, strictly validates, and actively pushes functioning code directly into the active SuperCollider environment.

### 1.1 Generation Modes

The system operates under two primary user-selected modes evaluated in `main.py`:

- **One-Shot Generation:**  
  The user provides a single, overarching prompt (e.g., "Create a granular synthesizer with a reverb effect and a 4-on-the-floor kick drum pattern"). The LLM generates the entire composition as a monolithic block, evaluates its validity, and outputs the final `.scd` file. This mode is useful for rapid prototyping and generating self-contained generative instruments.

- **Incremental Building:**  
  Designed for active live-coding and continuous composition, this mode guides the user through a sequential block-by-block loop (`agent_graph_incremental.py`). The LLM generates elements chronologically (e.g., Block 1: `init` Synths, Block 2: `effects`, Block 3: sequencing contexts). The ongoing state of the script is tracked, appending to an existing output file and compiling context for subsequent LLM reasoning. Crucially, the user is offered a graceful "end flow" by typing `end`, allowing them to dictate an outro (like a fade-out curve) before the session wraps up.

### 1.2 "Auto-Execute" Operation

In both modes, users can toggle `AUTO_EXECUTE_ENABLED`. 
- **Disabled (Manual):** Evaluated blocks are written to the target `.scd` output file. The user must manually switch windows to the SC IDE and hit `Ctrl+Enter` to verify it musically.
- **Enabled (Automatic Hot-Reloading):** Evaluated blocks are proven syntactically valid in the background and pushed instantly to the target output file. Because the SC IDE was modified to *listen* for these specific file changes, it will autonomously route the new string to the SC language interpreter (`sclang`), evaluating it instantly without the user lifting a finger.

---

## 2. Agent Framework & LangGraph Workflow

The interactive logic of SC-Gen-RAG is driven by **LangGraph**, a highly capable state-machine library built on top of LangChain. LangGraph structures the AI's execution into deterministic, acyclic, and cyclic nodes.

### 2.1 The Incremental State Graph
The incremental loop (`agent_graph_incremental.py`) uses a `TypedDict` to track iterative session history across turns, carrying variables like `block_number`, `session_history`, `current_code_block`, and `interaction_log`.

1. **`prepare_context_node`**: Formulates the prompt and extracts context.
2. **`classify_block_node`**: Categorizes the LLM's goal (e.g., `init`, `sequence`, `fx`, `routing`) to tune system instructions.
3. **`generate_block_node`**: Calls the core LLM API (passing the context, conversation history, and classification).
4. **`extract_new_block_node`**: Strips markdown, formats the raw text into structurally safe `( ... )` evaluation regions, and injects runtime-required semicolons.
5. **`syntax_validate_node`**: Evaluates the code against the dual-tier pipeline (structural & execution).
6. **Conditional Router**: 
   - If `syntax_valid == True`, routing moves to output compilation.
   - If `syntax_valid == False`, routing loops back into `syntax_correction_node`, recursively feeding the exact compilation traceback back to the LLM to write a targeted patch. If the failure counter surpasses `MAX_SYNTAX_RETRIES` (default: 3), the agent gives up and gracefully falls back to a "Human-in-the-loop" node for manual intervention.
7. **`human_review_node` & File Writing**: Output is written to `sc-files/test.scd`.
8. **Ending & Teardown**: Upon hitting the session end, `add_comments_node` extracts a meta-summary from the user and hands the session transcript over to Google Drive.

---

## 3. Code Validation & Review Pipeline

SuperCollider lacks a formal static analysis or "Linting" framework. Therefore, the SC-Gen-RAG pipeline utilizes a highly customizable validation mechanism to prove code stability *before* injecting it into the live SC IDE. This validation pipeline is fully standardized across both generation modes (`One-Shot` and `Incremental`). 

At the start of every session, the user is presented a dynamic configuration menu exposing three primary evaluation branches:

### 3.1 Validation Bypass
The user can explicitly opt out of all validation logic. This routes the LangGraph state machine directly from code extraction to file writing, vastly accelerating token speeds when pure LLM trust is desired.

### 3.2 2-Tier Sclang System (Syntax Priority)
If selected, the code runs through a rigorous dual-layered gate:
1. **Tier 1 (Structural):** Implemented locally in Python (`_tier1_structural_check`), this tier rapidly scans the newly generated block text to count `( )`, `{ }`, and `[ ]` bracketing while completely ignoring string literals, inline `//`, and block `/* */` comments. This ensures an obvious syntax mistake doesn't lock up the background parser.
2. **Tier 2 (Headless `sclang` Subprocess execution):** A persistent, invisible `subprocess.Popen` connection is established targeting the SuperCollider CLI (`sclang`). The validator wraps the code block in a protective try/catch closure (`try { ... } { |err| ... }`), intercepts the `stdout` via signature strings (`***SCLANG_VALID***`), and silently syncs the environment state (`.mirror_block`).

### 3.3 LLM-Powered Code Review (Aesthetic & Programmatic Priority)
Alternatively, users can mandate a dedicated, secondary LLM strictly for peer-reviewing the initial generator's code before testing.
- **Provider Agnosticism:** The user dynamically selects the LLM API specifically for the review (defaulting to the primary `gemini` engine, but switchable on the fly to `openai`, `anthropic`, `deepseek`, or `ollama`). 
- **Variable Scope Assessment:** Users choose whether this secondary LLM should focus strictly on **Programmatic** soundness (fixing crashes/logic) or include **Aesthetic** adjustments—evaluating parameter mapping, envelope curves, and evaluating the underlying sonic intention against the generated code snippet to ensure heightened musicality.

---

## 4. Context Management & The RAG System

To generate idiomatically correct syntax and utilize complex third-party tools (like `SuperDirt` or `JITLib` structures), SC-Gen-RAG employs a robust Hybrid RAG database.

### 4.1 Vector Database Construction
Using `langchain-chroma` and the highly capable `BAAI/bge-small-en-v1.5` dense embedding model, the architecture creates two parallel persistent vector stores:
- **`vectordb_knowledge_base`**: A curated library of user-crafted, idiomatically perfect `.scd` scripts, configurations, and reference implementations outlining highly specialized code logic (like `Ndef` chaining arrays or customized routing workflows).
- **`vectordb_sc_help`**: A comprehensively chunked and indexed copy of the massive `SuperCollider-3.13.0/HelpSource` native documentation reference, extracted via markdown parsing. 

### 4.2 Dynamic Search & Hybrid Injection
When the user submits a request, `rag_engine.py` performs a semantic similarity search (`similarity_search_with_score`) against both databases.
The implementation uses a `USER_LIB_BOOST` prioritization modifier. Distance scores from the native HelpSource database are artificially multiplied (yielding "worse" relevance distances), strongly skewing the retriever's selection bias towards surfacing highly curated, custom user knowledge rather than generic library defaults, ensuring the agent aligns with the user's specific performance environment templates.

### 4.3 Prompt Orchestration and System Messages
The retrieved chunks, conversation history summaries, and user inputs are synthesized into a stringent `SystemMessage`. Specifically, the system utilizes prompt templates mapped in `system-instruction.md` and `system-instruction-incremental.md`, aggressively enforcing:
- Refusal to generate extraneous explanations (Markdown formatting only).
- Enforcing structural rules (explicit top-level `( ... )` regions).
- Mandating iterative proxy assignments instead of sweeping global overwrites.

### 4.4 System Improvements (RL-Style History)
`system-improvements.md` acts as a rudimentary reinforcement learning memory buffer. By passing previous interaction criticisms back into the system prompt context, the agent "remembers" structural habits or idiosyncrasies unique to SuperCollider or the user's workflow, minimizing the recurrence of specific syntactic hallucinations between sessions.

---

## 5. SuperCollider C++ Modifications (Auto-Execution)

Live coding demands instantaneous acoustic feedback. Standard SC development involves typing code, highlighting regions, and evaluating them via UI actions. To facilitate "hot-reloading", fundamental alterations were heavily injected directly into the SuperCollider IDE C++ Source (`supercollider/editors/sc-ide/core`).

### 5.1 DocumentManager Extensions (`doc_manager.cpp`)
A `QFileSystemWatcher` was instantiated inside the `DocumentManager`. 
When SC-Gen-RAG pushes a new output file update (`test.scd`), the core operating system fires a metadata update. The `QFileSystemWatcher` explicitly intercepts the trigger signal, validating that the file has indeed changed externally on disk.

### 5.2 Bypassing UI Modals
Normally, modifying a loaded string outside of the IDE forces the UI to pause the application and present a blocking `QMessageBox`: *"File modified outside editor. Reload?"*, halting the agentic flow.
A dedicated method, `DocumentManager::setAutoEvaluateEnabled(bool enabled)` dynamically bypasses this modal. If the toggle is active, the `Document` drops the confirmation dialog, reloads the text from the disk automatically, and issues a command sequence straight to the language interpreter (`ScIDE::Session::evaluate`). The string is parsed natively by Sclang synchronously, delivering live, gapless playback in milliseconds.

### 5.3 Interface & Persistence Additions
The auto-eval toggle is heavily embedded inside the IDE presentation layer.
- Added a `QAction` parameter representing `"Auto-Evaluate Externally Modified Files"` injected natively into the SC `Language` dropdown menu (`main_window.cpp` & `main_window_menu.cpp`).
- Wired signal bridging ensures altering the GUI physically writes parameters into `Settings::Manager`, enforcing state persistence across SuperCollider shutdowns and reboots. 

---

## 6. Modularity & Platform Integrity

### 6.1 LLM Provider Architecture
The `llm_engine.py` wrapper abstracts all outbound LLM interactions cleanly.
Controlled by `CURRENT_LLM_PROVIDER` in `config.py` and actively mutable during runtime verification menus, the system is intrinsically multi-modal and seamlessly routes state outputs across differing corporate APIs using try/catch error enclosures enforcing strictly necessary pip dependencies:
- **`gemini`**: Connects via `google.generativeai` utilizing high-context models like `gemini-2.5-flash` for high-throughput generic generation.
- **`openai` & `deepseek`**: Bound through the unified `openai` python library connecting models like `gpt-4o` and `deepseek-chat` respectively. DeepSeek uses a patched `base_url`.
- **`anthropic`**: Native interface hook resolving calls to models like `claude-3-7-sonnet`.
- **`ollama`**: Seamlessly injects Local, open-source inferencing via `ollama` (leveraging localized checkpoints like `qwen2.5-coder`), guaranteeing execution privacy or operation in internet-denied environments without impacting agent capability or graph architecture.

### 6.2 Session Persistence and Archival
Once a session gracefully completes, the application utilizes the `google-api-python-client` (`utils.py`). The script securely parses `credentials.json` utilizing OAuth 2 flow servers. It then logs the entirety of the interaction (including user prompt sequences, generated evaluation regions, syntax failures, and concluding annotations) synchronously up to a central Google Docs file via the `googleapiclient.discovery` builder. 
If an access token (`token.json`) is flagged by the Google Authentication backend with `invalid_grant` or explicitly expires, a protected `try/catch` mechanism instantly eradicates the corrupted local token and auto-prompts a localized browser window, guaranteeing uninterruptible session persistence.
