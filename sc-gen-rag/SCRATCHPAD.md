# SC-Gen-RAG Project Scratchpad
## Comprehensive Context Document for AI-Assisted Development Sessions

> **Last Updated**: 2026-08-21
> **Purpose**: This document captures ALL key facts, architecture, design decisions, and implementation details of the SC-Gen-RAG project. Load this document at the start of any new AI session to restore full project context.

---

# TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Repository Structure](#2-repository-structure)
3. [Git History & Commit Structure](#3-git-history--commit-structure)
4. [Architecture Overview](#4-architecture-overview)
5. [Python Backend — Core Files](#5-python-backend--core-files)
6. [C++ / Qt IDE Integration](#6-c--qt-ide-integration)
7. [System Messages & Prompt Architecture](#7-system-messages--prompt-architecture)
8. [Use Cases & Pipelines](#8-use-cases--pipelines)
9. [RAG System](#9-rag-system)
10. [Validation Pipeline](#10-validation-pipeline)
11. [Docker Infrastructure](#11-docker-infrastructure)
12. [Knowledge Base](#12-knowledge-base)
13. [Session Management & Logging](#13-session-management--logging)
14. [Observability & Sustainability Tracking](#14-observability--sustainability-tracking)
15. [Configuration Reference](#15-configuration-reference)
16. [Build & Deployment](#16-build--deployment)
17. [Key Design Decisions & Rationale](#17-key-design-decisions--rationale)
18. [Known Issues & Gotchas](#18-known-issues--gotchas)
19. [File-by-File Quick Reference](#19-file-by-file-quick-reference)

---

# 1. PROJECT OVERVIEW

## What This Is
A fork of SuperCollider (v3.14+/develop branch) altered to integrate LLM-powered code generation for music creation. This is the experimental product/artifact of the academic research: **"Approaches for Using LLM Code Generation to Generate Music with GenAI"**.

## Core Thesis
The project explores interfacing with AI purely through text and code generation to create music based on LLM output code, using SuperCollider as the target language/platform. Multiple use cases have been developed and refined through iterative experimentation.

## Two-Component System
1. **SC-Gen-RAG** (`sc-gen-rag/`): Python-based LangGraph agent with RAG pipeline, multi-provider LLM support, session logging, and sustainability tracking
2. **SuperCollider-AI-Assist** (modified C++ IDE): Custom SC IDE with embedded AI panel, auto-reload, auto-evaluate, and per-document session persistence

## Author
Bruno Gazoni (brugazoni@gmail.com)

---

# 2. REPOSITORY STRUCTURE

```
supercollider-AI-assist/                    # Root = SC fork (develop branch)
├── sc-gen-rag/                             # ★ Python backend (the AI brain)
│   ├── main.py                             # CLI entry point (standalone mode)
│   ├── gui_backend.py                      # ★ IDE backend (QProcess command protocol)
│   ├── agent_graph.py                      # One-shot LangGraph pipeline
│   ├── agent_graph_incremental.py          # Incremental LangGraph pipeline
│   ├── llm_engine.py                       # Multi-provider LLM client
│   ├── rag_engine.py                       # ChromaDB + HuggingFace RAG
│   ├── config.py                           # Central configuration
│   ├── utils.py                            # Google Docs, session logging, stats
│   ├── build_knowledge_db.py               # Vector DB builder CLI
│   ├── validate_knowledge_db.py            # Vector DB validation (6 checks)
│   ├── inspect_vectordb.py                 # Vector DB inspection CLI
│   ├── sys_msgs_defaults.json              # ★ Use case → prompt file mapping
│   ├── system-instruction-review.md        # Code review agent prompt
│   ├── system_messages/                    # ★ 10 subdirs, 19 prompt files
│   │   ├── base/                           # Foundation SC coding rules
│   │   ├── generate/                       # One-shot plan + code
│   │   ├── design/                         # MIDI/OSC synthesizer design
│   │   ├── compose/                        # Timeline-based composition
│   │   ├── append/                         # Incremental live coding
│   │   ├── fix/                            # Error correction
│   │   ├── remake/                         # Aesthetic rework
│   │   ├── learn/                          # Teaching/Q&A
│   │   ├── custom/                         # Free-form & lexical transcoding
│   │   └── improvements/                   # ★ Self-improving lessons learned
│   ├── knowledge_base/                     # 16 curated .scd RAG examples
│   ├── sc-files/                           # AI-generated output files + session JSONs
│   ├── use-logs/                           # Session logs (markdown + stats JSON)
│   ├── vectordb_knowledge_base/            # ChromaDB vector store
│   ├── tests/                              # RAG and sclang validation tests
│   ├── docs/                               # Internal documentation
│   ├── .env                                # API keys (Gemini, LangChain, Logfire)
│   ├── pyproject.toml                      # PDM project config
│   └── requirements.txt                    # Pip dependencies
├── sc-gen-rag-docs/                        # ★ Thesis/research documentation
│   ├── sc-gen-rag_thesis_documentation.md  # Main architecture doc
│   ├── auto-execute-walkthrough.md         # Full diff walkthrough (194KB)
│   ├── sc-validator-study.md               # Validation feasibility study
│   ├── sc-validator-indepth.md             # Validator architecture
│   ├── supercollider-changes-indepth.md    # C++ changes documentation
│   ├── sc-ide-rebuild-guide.md             # Build instructions
│   └── code-17-04-26.md                    # Code snapshot (1.2MB)
├── editors/sc-ide/                         # ★ Modified SC IDE source
│   ├── widgets/ai_assist_widget.hpp/.cpp   # ★ THE AI panel (2598 lines total)
│   ├── widgets/main_window.hpp/.cpp        # Modified for AI signals
│   ├── widgets/post_window.hpp/.cpp        # Modified to host AI widget
│   └── core/doc_manager.hpp/.cpp           # Auto-reload + auto-evaluate
├── docker/                                 # Docker syntax validation pipeline
│   ├── Dockerfile / Dockerfile.gui         # Headless + GUI containers
│   ├── check_syntax.py / .scd             # SC code validators
│   ├── preprocess_sc.py                    # Top-level paren remover
│   └── code_input/                         # Test SC files
└── implementation_plan.md                  # Docker environment plan
```

---

# 3. GIT HISTORY & COMMIT STRUCTURE

## Custom Commits (chronological, on `develop` branch)

| # | Hash | Date | Message | Key Changes |
|---|------|------|---------|-------------|
| 1 | `b4b829896` | 2026-03-11 | `feat: pre-auto execution implementation` | Docker setup, initial C++ mods (auto-reload, document dialog changes), implementation plan, build artifacts |
| 2 | `82d94b5ec` | 2026-03-26 | `feat: pre-ui refactoring` | ★ Entire `sc-gen-rag/` Python codebase, all documentation, knowledge base, tests, initial system messages. The big bang commit. |
| 3 | `2133045f5` | date N/A | `feat: use cases up to design` | GUI backend, LLM engine expansion, system message reorganization, use-logs, session management, design pipeline prompts, sc-files with session JSONs |
| 4 | `aec5d3447` | 2026-06-05 | `feat: first version for experiments` | ★ `ai_assist_widget.cpp/hpp` (the full IDE panel), compose/custom/design v2 prompts, MIDI/OSC variants, sys_msgs_defaults.json, famous-synths KB, experiment outputs cleanup |

## Base Branch
Forked from SC `develop` branch at commit `835641a1b` (after SC 3.14.1 release cycle).

## Duplicate Refs
`refs/original/refs/heads/develop` contains duplicate commits (060b69654, 7ce66d869, 2d2f83615, a4a17963d) — likely from a `git filter-branch` operation to clean history.

---

# 4. ARCHITECTURE OVERVIEW

## Data Flow (IDE Mode — Primary)

```
User types prompt in AI panel tab
        │
        ▼
AiAssistWidget (C++ Qt)
        │  spawns QProcess
        ▼
python gui_backend.py <command> <json_file>
        │
        ├── Reads sys_msgs from system_messages/ directory
        ├── Queries ChromaDB for RAG context (if use_kb=true)
        ├── Calls LLM via llm_engine.py (Gemini/Anthropic/OpenAI)
        ├── Tracks stats (cost, time, eco metrics)
        ├── Logs to session log (use-logs/)
        │
        ▼
JSON response on stdout
        │
        ▼
AiAssistWidget parses response
        │  inserts code into active document
        ▼
DocumentManager detects file change
        │  auto-reloads (silent, no dialog)
        ▼
(Optional) Auto-evaluate last (...) region
        │
        ▼
Sound plays through scsynth
```

## Data Flow (CLI Mode — Legacy/Testing)

```
Terminal → main.py → mode selection → LangGraph StateGraph → LLM → validation → file output → Google Docs logging
```
**CRITICAL DISTINCTION**: `agent_graph.py` and `agent_graph_incremental.py` are **ONLY** used when running `main.py` from the terminal. The IDE integration (`gui_backend.py`) completely bypasses these LangGraph pipelines, skipping the iterative syntax validation loops in favor of fast, direct LLM generation using `LLMClient.generate()`. Any modifications made to the agent graphs will not affect the IDE tabs.


## Communication Protocol (IDE ↔ Python)

- **Transport**: QProcess subprocess (NOT HTTP/WebSocket)
- **Invocation**: `python gui_backend.py <command> <temp_json_file>`
- **Input**: JSON payload written to temp file (auto-cleaned)
- **Output**: JSON on stdout; progress/status on stderr
- **Concurrency**: Single process at a time (guarded by `mCurrentProcess != nullptr`)
- **Sync commands**: `list_models`, `init_session`, `get_session_stats`, `get_prompt_history`, `save_session_log` (use `waitForFinished()`)
- **Async commands**: All tab action commands (use signal-based `onProcessFinished`)

## Available Backend Commands
`list_models`, `init_session`, `generate_plan`, `generate_code`, `custom_generate`, `append`, `fix`, `remake`, `learn`, `add_kb`, `consume_kb`, `get_session_stats`, `get_prompt_history`, `get_raw_session_log`, `import_raw_session_log`, `save_session_log`, `start_dictation`, `stop_dictation`

---

# 5. PYTHON BACKEND — CORE FILES

## 5.1 `gui_backend.py` (689 lines) — IDE Interface

The primary entry point when called from the C++ IDE. Command-based JSON-in/JSON-out protocol.

**Architecture**: `python gui_backend.py <command> <json_input_file>` — reads JSON from file or inline, dispatches to command handler, returns JSON on stdout. stderr is used for progress messages (stdout is redirected to stderr for print statements, original stdout preserved for JSON output).

**Key helper functions**:
- `_resolve_model(model_key)`: Resolves `provider/model` → `(provider, model_name)` tuple
- `_build_system_prompt(data)`: Builds composite system prompt from explicit list of `sys_msgs` paths — reads files from `system_messages/` directory, joins with separator markers
- `_read_scd(filepath)` / `_write_scd(content, filepath, mode)`: File I/O

**Command implementations**:
- `cmd_generate_plan`: Generates composition plan. Supports mode-specific ending instructions (design/compose/generate)
- `cmd_generate_code`: Generates code from approved plan. Optional RAG context (`use_kb` toggle). Writes to active file
- `cmd_custom_generate`: Free-form generation driven by dynamically selected system messages
- `cmd_append`: Incremental block append — does TWO LLM calls: code generation + composition state update (at temp 0.0)
- `cmd_fix`: Bug fix from error/stack trace. Substitutes bad block in file. Queues fix to `.pending_fixes.json` for offline learning
- `cmd_remake`: Aesthetic rework of code block
- `cmd_learn`: Q&A with conversation history support
- `cmd_add_kb`: Adds code block + description to `user-kb.scd`
- `cmd_consume_kb`: Re-indexes knowledge base via `rag_engine.build_knowledge_base_index()`
- `cmd_save_session_log`: Finalizes session, processes offline learnings from `.pending_fixes.json`

## 5.2 `llm_engine.py` (284 lines) — Multi-Provider LLM Client

**Class `LLMClient`**:
- Providers: Gemini (`google.genai`), OpenAI, Anthropic
- `generate(prompt, system_instruction, temperature, thinking_budget)` → `(text, stats_dict)`
- Anthropic extended thinking: when `thinking_budget` is set, forces `temperature=1.0`, increases `max_tokens`, extracts final text block from multi-block response
- **Observability**: LangSmith `@traceable` decorator, Logfire auto-instrumentation, EcoLogits environmental impact tracking
- **Stats tracked**: `in_tokens`, `out_tokens`, `time_s`, `cost`, `cost_fb` (fallback estimation flag), `context_usage_pct`, `energy_kwh`, `gwp_kg`, `adpe_kg`, `pe_mj`, `wcf_m3`
- Cost calculation from `config.PRICING_PER_1M_TOKENS`

## 5.3 `agent_graph.py` (689 lines) — One-Shot Pipeline

**`AgentState` TypedDict**: 20+ fields including `user_query`, `system_instruction`, `code_context`, `composition_plan`, `plan_approved`, `current_code_block`, `is_correct`, `fix_mode`, `error_type`, `aesthetic_scope`, `validation_prefs`, etc.

**Graph flow** (current simplified version):
```
load_resources → generate_plan → review_plan → generate_initial → write_output → add_comments → summarize_comments → log_to_drive → END
```
Plan review has conditional routing (approve → generate, reject → regenerate plan, abort → comments).

**Key functions**:
- `_tier1_structural_check(code)`: Bracket-balancing validator that strips comments/strings, checks bracket pairs, detects empty blocks
- `load_resources_node`: RAG retrieval via `rag_engine.query_index()`
- `correction_auto_node` / `correction_manual_node` / `correction_external_node`: Three fix strategies
- `summarize_improvements_node`: Generates learning summary from corrections, appends to improvements file
- `log_to_drive_node`: Logs full session to Google Docs

## 5.4 `agent_graph_incremental.py` (1029 lines) — Incremental Pipeline

**`IncrementalState` TypedDict**: Extends AgentState with `block_number`, `block_type`, `composition_history`, `previous_blocks`, `auto_execute`.

**Block types**: `init`, `add_instrument`, `add_effects`, `tweak`, `fade_out`

**Graph flow**:
```
load_resources → classify_block → generate_block → extract_new_block → write_block → update_composition → END
```

**`run_incremental_session()`**: Session runner that loops accepting per-block prompts, carries `composition_history` and `previous_blocks` across iterations, supports "end"/"finish"/"done" for fade_out ending.

**Key**: `update_composition_node` — LLM extracts/updates running composition state (active Ndefs, Pbindefs, effect slots, wetness levels) for context in next block.

## 5.5 `rag_engine.py` (140 lines)

- Uses ChromaDB + HuggingFace `BAAI/bge-small-en-v1.5` embeddings
- `RecursiveCharacterTextSplitter` (chunk_size=4000, overlap=400, separators: `\n\n`, `\n`, `{`, `(`, `;`)
- `query_index(query_text, sources)`: Auto-builds if DB missing, returns formatted numbered blocks
- `build_knowledge_base_index()`: Wipes and rebuilds from `knowledge_base/*.scd`

## 5.6 `utils.py` (468 lines)

**Google Docs Integration**: OAuth2 authentication, auto-refresh on `invalid_grant`, append to configured Google Doc.

**Session Logging System**:
- `LOGS_DIR = "use-logs/"` with timestamped markdown files
- `init_session_log(active_file)`: Creates timestamped log, maps to active .scd file
- `append_to_session_log(...)`: Updates per-session JSON stats file with cost, time, energy, GWP, ADPE, PE, WCF per provider
- `finalize_session_log(process_fixes)`: Teardown on IDE close, syncs to Google Docs
- `get_session_history_entries(active_file)`: Parses markdown log into structured entries

**Self-improvement**: `load_system_instruction()` loads base system instruction + improvements file.

## 5.7 `config.py` (85 lines)

See [Configuration Reference](#15-configuration-reference) section below.

---

# 6. C++ / QT IDE INTEGRATION

## 6.1 Widget Hierarchy

```
MainWindow
  └─ PostDocklet (Docklet)
       └─ AiAssistWidget (QWidget) ← docklet's main widget
            ├─ Row 1: Model combo, Temp slider (0-20 → 0.0-2.0), Thinking budget combo
            ├─ Row 2: History, Import, Audio Boot, API Keys, Status buttons
            ├─ Row 3: Session cost btn, Sustainability btn, Eco label, Context bar, Wait label
            └─ QTabWidget (10 tabs)
                 ├─ Tab 0: Post (original PostWindow)
                 ├─ Tab 1: Generate (plan → code with KB toggle, include-ending toggle)
                 ├─ Tab 2: Compose (absolute-time composition with cue sheet plan)
                 ├─ Tab 3: Design (MIDI/OSC synthesizer design)
                 ├─ Tab 4: Custom (free-form with custom system messages)
                 ├─ Tab 5: Append (incremental with auto-execute toggle)
                 ├─ Tab 6: Fix (error correction with auto-populated stack trace)
                 ├─ Tab 7: Remake (aesthetic modification)
                 ├─ Tab 8: Ask/Learn (chat-style Q&A)
                 └─ Tab 9: Add to KB (knowledge base management)
```

## 6.2 `ai_assist_widget.hpp/cpp` (279 + 2319 = 2598 lines)

This is the largest custom file. Key aspects:

**Backend Communication** (`runBackendCommand`, L1082-1158):
1. Guards against concurrent processes
2. Merges `basePayload()` (active_file, model, temperature, thinking)
3. Writes JSON to QTemporaryFile
4. Creates QProcess, sets working directory to sc-gen-rag/
5. Connects stderr → status button updates, stdout → accumulator
6. Starts: `python gui_backend.py <command> <tempfile_path>`

**Python path resolution** (`pythonPath`, L1019-1033): Searches `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python`, falls back to `"python"`.

**Backend script resolution** (`backendScriptPath`, L1035-1046): Walks up 6 directory levels looking for `sc-gen-rag/gui_backend.py`.

**Session Persistence** (fixed 2026-06-10 — 8-bug overhaul):
- Each document gets `.ai-session.json` sidecar file
- Contains ALL UI state: prompts, plans, model, temperature, system message selections, stats labels, raw session log
- Auto-saved on document save/switch/close
- Auto-restored on document open/switch
- `mLastActiveDocument` uses `QPointer<Document>` for safe pointer tracking (auto-nullifies on destroy)
- `connectDocumentSignals()` includes catch-up logic — calls `onDocumentShown` for any document already open before signals were connected (solves startup race)
- `init_session` call deferred from constructor to `connectDocumentSignals()` so the real active file is known
- `restoreSessionFor()` calls `tryUpdateSessionStats()` after restore to refresh live data from Python backend
- `onDocumentClosed()` checks `hasSessionContent()` *before* `clearSessionFields()` so the "Session Lost" warning fires correctly
- Variable shadowing of `doc` in `saveSessionFor` fixed (renamed to `jsonDoc`)

**Error Detection** (`onPostWindowText`, L995-1007): Monitors post window output for "ERROR:", "Exception", "syntax error", lines starting with "!" — accumulates into `mLastStackTrace` (capped 4000 chars).

**System Message Editor** (L1648-1811): Rich dialog with drag-reorderable checkable QListWidget, file content editor, new message creation, live concatenation preview.

**Stats & Sustainability Dialogs**: Per-model breakdown, environmental impact with 5 metrics (energy, GWP, ADPE, PE, WCF).

**API Keys Dialog**: Modal with QFormLayout for GEMINI, ANTHROPIC, OPENAI, LANGCHAIN keys — reads/writes `.env` file.

**Shutdown handler** (`handleIdeShutdown`): Auto-saves session, processes pending fixes from `.pending_fixes.json`, runs `save_session_log` with timeout.

## 6.3 Signal/Slot Connections

| Signal | Slot | Purpose |
|--------|------|---------|
| `ScProcess::scPost` | `AiAssistWidget::onPostWindowText` | Error detection from post window |
| `ScProcess::codeEvaluated` | lambda → `setLastEvaluatedCode` | Capture last-evaluated code |
| `DocumentManager::saved` | `onDocumentSaved` | Session auto-save |
| `DocumentManager::showRequest` | `onDocumentShown` | Session switch |
| `DocumentManager::opened` | `onDocumentShown` | Session restore |
| `DocumentManager::closed` | `onDocumentClosed` | Session cleanup |
| `MainWindow::quit()` | `handleIdeShutdown()` | Shutdown hook |

## 6.4 `doc_manager.cpp` Modifications

**Auto-reload** (`onFileChanged`): When file changes on disk, compares `mSaveTime < info.lastModified()`, directly invokes `reload(doc)` without user confirmation dialog (bypasses QMessageBox). Shows non-intrusive status message.

**Cursor/scroll preservation on reload**: Saves cursor position and scroll bar value before reload, restores after. Clamps cursor to document length.

**Auto-evaluate** (`autoEvaluateLastRegion`): Scans backwards from end of document, finds last top-level `(...)` region (opening `(` at column 0), extracts and evaluates via `Main::evaluateCode()`.

**`mAutoEvaluateEnabled`**: Boolean member, default `false`. Toggle via `setAutoEvaluateEnabled(bool)` slot.

**`documents_dialog.cpp`**: Commented out "Overwrite", "Ignore", and "Close" buttons for external file changes — only "Reload" remains.

---

# 7. SYSTEM MESSAGES & PROMPT ARCHITECTURE

## Compositional Prompt System

Prompts are **composited** (concatenated in order) from multiple files. The mapping is defined in `sys_msgs_defaults.json`:

| Use Case Key | Files (stacked) |
|---|---|
| `gen_plan` | base + oneshot-plan |
| `gen_code` | base + improvements + oneshot-gen |
| `design_plan` | plan-design-v2 |
| `design_code` | gen-design-v2 + fix |
| `compose_plan` | plan-v2 |
| `compose_code` | implement-v2 + improvements |
| `append` | base + improvements + incremental |
| `fix` | fix |
| `remake` | base + improvements + remake |
| `learn` | base + learn |
| `custom` | (empty — fully custom) |

**Key insight**: The `design` pipeline does NOT inherit the `base` prompt — it uses SynthDef architecture (not Ndef/JITLib), so it's self-contained.

## Two Fundamentally Different SC Architectures

### Architecture A: JITLib (base, generate, compose, append, remake, learn)
- **Ndef + Pbindef** exclusively
- Slot-based routing: [0]=source, [1]=pattern control, [10-12]=effects
- `t_trig` envelope triggering
- No SynthDef/Synth, no `doneAction: 2`
- Effects initialize at `wet=0`
- NEVER use `<<<>` operator

### Architecture B: SynthDef (design pipeline)
- Pre-compiled SynthDef + Synth instantiation
- Group-based execution order: `synthGroup → fxGroup → masterGroup`
- ADSR envelopes with `doneAction: 2`
- MIDI/OSC driven (no pattern sequencing)
- Audio bus routing between groups
- Paginated GUI with CC/ID labels

## Base Prompt Anti-Patterns (6 Critical Traps)
1. **Lethal Finite Pattern Trap**: Wrap finite generators in `Pn(..., inf)`
2. **Envelope/Trigger Trap**: NEVER `Env.asr`/`Env.adsr` with `t_trig`; use `Env.perc` or fixed-duration
3. **Sine Wave Filter Trap**: Never filter pure SinOsc with subtractive filters
4. **GVerb Phasing Trap**: GVerb expects mono input, must `.sum` stereo
5. **Wet/Dry Reverb Trap**: FreeVerb mix must be 1 in filter slot
6. **Dead Delay Trap**: Use CombL/CombC instead of DelayN/DelayC

## System Improvements File (Self-Learning Memory)
`system_messages/improvements/system-improvements.md` acts as a **rudimentary reinforcement learning memory buffer** — past corrections, user feedback, and auto-fixes are summarized into lessons and appended. This file is loaded into future prompts. Contains 20+ dated entries from 2026-03-16 to 2026-05-29.

---

# 8. USE CASES & PIPELINES

## 8.1 Generate (One-Shot)
**Plan → Code** two-step pipeline. User provides creative prompt → LLM generates composition plan (markdown) → user reviews/approves → LLM generates full SC code.

## 8.2 Design (MIDI/OSC Synthesizer)
**Plan → Code** for multi-zone MIDI/OSC synthesizers. Uses SynthDef architecture with overlapping key ranges (up to 8 zones), paginated GUI, CC/OSC control. Three variants: MIDI v2, OSC, MIDI v1.

## 8.3 Compose (Timeline Composition)
**Plan → Code** for fixed-timeline narrative/cinematic compositions. Uses absolute time (minutes:seconds), Tdef with `.wait` periods, active wait states (no static waits >8s), safety limiter on RootNode.

## 8.4 Custom (Free-Form)
Fully custom system messages. Includes "Apophenia-Driven Lexical-to-DSP Transcoder" mode — converts arbitrary text (e.g., Wikipedia articles) into SC compositions by treating text as meaningful signal rather than metaphor.

## 8.5 Append (Incremental Live Coding)
Block-by-block composition with running state tracking. Each block classified (init/add_instrument/add_effects/tweak/fade_out). Composition state updated after each block. Optional auto-execute. **Voice dictation**: 🎤 toggle button uses RealtimeSTT (faster-whisper + Silero VAD) to transcribe speech into the prompt field in real-time. Uses block-based mode: each 1-second silence boundary creates a visually separated block (— — — — —). **Auto-Append**: when enabled, each dictation block is automatically queued and sent through the Append→LLM→insert→evaluate pipeline using a FIFO `QQueue`, enabling fully hands-free live coding.

## 8.6 Fix (Error Correction)
Receives code block + error/stack trace, outputs fixed code. Auto-populates from captured post window errors. Queues fixes to `.pending_fixes.json` for offline learning.

## 8.7 Remake (Aesthetic Rework)
Takes existing code block + aesthetic direction prompt, rewrites for new sound design intent while preserving structure/names.

## 8.8 Learn (Q&A/Tutoring)
Chat-style interaction with conversation history. Uses current file as context. Pedagogical tone, short examples, no full code generation unless asked.

## 8.9 Add to KB (Knowledge Base Management)
Add code block + description to `user-kb.scd`, then re-index the vector database.

---

# 9. RAG SYSTEM

## Vector Store
- **Engine**: ChromaDB with LangChain integration
- **Embeddings**: `BAAI/bge-small-en-v1.5` (HuggingFace)
- **Chunk size**: 4000 chars, 400 overlap
- **Separators**: `\n\n`, `\n`, `{`, `(`, `;` (SC-aware)
- **Top-K**: 5 (configurable via `RAG_K`)
- **USER_LIB_BOOST**: 1.5 — artificially favors user knowledge base over SC help docs

## Sources
- `vectordb_knowledge_base/` — from 16 curated `.scd` files in `knowledge_base/`
- (Previously also had `vectordb_sc_help/` from SC HelpSource, removed in later commits)

## Retrieval Format
Results formatted as numbered blocks: `--- RETRIEVED N (type: filename) ---`

---

# 10. VALIDATION PIPELINE

## Three-Tier Architecture

### Tier 1: Structural (Python)
`_tier1_structural_check(code)` — Python-side bracket-balancing validator:
- Strips comments and strings
- Checks bracket pairs: `()`, `{}`, `[]`
- Detects empty blocks
- Fast-fail filter (no subprocess needed)

### Tier 2: Headless sclang (Subprocess)
Persistent `subprocess.Popen` connection to sclang CLI:
- **File execution workaround** (Windows): Write code to temp file, send single-line wrapper:
  ```
  try { "C:/path/temp.scd".load ; "__SCLANG_VALID__".postln } { |err| ("__SCLANG_ERROR__: " ++ err.errorString).postln }
  ```
- **stdin protocol**: UTF-8 encoded, terminated with `\n` + `\x0c` (Form Feed execution character)
- **State mirroring**: After validation passes, `mirror_block()` silently evaluates code to keep environment synchronized
- **Critical finding**: SC's `.try` catches runtime exceptions but NOT syntax/parse errors — the wrapper distinguishes these

### Tier 3: LLM Auto-Correction
- Routes to `syntax_correction_node` via LangGraph
- Feeds exact error output back to LLM
- Bounded by `MAX_SYNTAX_RETRIES = 3`
- Falls back to human-in-the-loop on max retries

## Auto-Execute Flow
```
generate → extract → validate → [valid?] → write → update_composition → END
                               [invalid & retries left?] → correct → validate (loop)
                               [max retries?] → write → verify_block (manual)
```

---

# 11. DOCKER INFRASTRUCTURE

## Purpose
Two roles: (1) headless code validation backend, (2) full GUI dev environment.

## Headless Container (`sc-syntax-checker`)
- Multi-stage build: ubuntu:22.04 → cmake build with `-DSC_QT=ON -DSC_IDE=OFF`
- Runtime: `xvfb` (virtual framebuffer for Qt class library) + `jackd2` (dummy audio)
- Entrypoint: starts JACK dummy → wraps execution in `xvfb-run`

## GUI Container (`supercollider-gui`)
- Builds from LOCAL source (includes C++ modifications)
- Full IDE with X11 forwarding
- Adds `libyaml-cpp` for YAML support

## Preprocessing Pipeline
SC IDE uses `()` blocks as "execute region" markers which cause parse errors when compiling whole files. Both `preprocess_sc.py` and `check_syntax.py` have `remove_top_level_parens()` functions that strip these while preserving functional parentheses.

---

# 12. KNOWLEDGE BASE

## 16 Curated Files (knowledge_base/)

| File | Topic |
|------|-------|
| ndef-addictive.scd | Additive synthesis |
| ndef-am-amplitude-modulation.scd | AM synthesis |
| ndef-animals.scd | Animal sound design (5 creatures) |
| ndef-distortion.scd | Distortion effects |
| ndef-famous-synths.scd | Classic synth emulations (Oberheim, Moog, ARP, etc.) |
| ndef-fm-frequency-modulation.scd | FM synthesis |
| ndef-granular.scd | Sample-based granular |
| ndef-live-audio-granular.scd | Live audio granular |
| ndef-modal.scd | Modal synthesis (Ringz, Klank) |
| ndef-noise.scd | Noise synthesis |
| ndef-subtractive.scd | Subtractive synthesis |
| ndef-wavetable.scd | Wavetable synthesis |
| live-audio-granular.scd | Live input routing |
| live-coding.scd | Basic live coding patterns |
| pbindef-pbind.scd | Sequencing patterns |
| user-kb.scd | User-contributed entries |

## Canonical Pattern (consistent across KB files)
```supercollider
// Setup
s.waitForBoot({
    Ndef(\master).play;
    Ndef(\master).filter(100, { |in| Limiter.ar(LeakDC.ar(in), 0.95, 0.01) });
});

// Instrument [Slot 0]
Ndef(\name, { |freq=440, amp=0.3, t_trig=1| ... }).play;

// Effects [Slots 10-12]
Ndef(\name)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8) };
Ndef(\name).set(\wet10, 0);  // start dry

// Sequences [Slot 1]
Ndef(\name)[1] = \set -> Pbindef(\seq, \dur, 0.5, \freq, Pseq([440, 550], inf), \t_trig, 1);

// Tweaks
Ndef(\name).xset(\wet10, 0.3);  // smooth crossfade

// Cleanup
Pbindef(\seq).stop;
Ndef(\name).fadeTime = 8;
Ndef(\name).clear(8);
```

---

# 13. SESSION MANAGEMENT & LOGGING

## Per-Document Session Files (`.ai-session.json`)
Each document gets a sidecar JSON file containing:
- All tab prompts and plans (gen, design, compose, custom, append, fix, remake, learn, KB)
- Model selection and temperature
- System message selections per tab (11 QStringList members)
- Stats labels (cost, context, eco, wait time)
- Raw session log
- Composition state

## Session Lifecycle (C++ side)

**Startup flow** (fixed 2026-06-10):
1. `AiAssistWidget` constructor builds UI, fetches models — does NOT init session or connect document signals
2. `PostDocklet` constructor creates the widget, then uses `QTimer::singleShot(0, ...)` to call `connectDocumentSignals` after the event loop starts
3. `connectDocumentSignals()` connects to `DocumentManager` signals, then immediately checks for an already-active document and restores its session (catch-up logic)
4. `init_session` backend call happens here with the real `active_file`, not in the constructor
5. Initial `tryUpdateSessionStats()` fetches live stats from Python backend

**Document switch** (`onDocumentShown`):
1. If switching away from a different document, save outgoing session via `saveSessionFor(mLastActiveDocument)`
2. Clear all UI fields via `clearSessionFields()`
3. Check if `.ai-session.json` sidecar exists for the new document
4. If exists, restore via `restoreSessionFor(jsonPath)` → also refreshes live stats
5. Update `mLastActiveDocument` tracker

**Document save** (`onDocumentSaved`): Writes full session state to `.ai-session.json` sidecar, including fetching `raw_log` from Python backend.

**Document close** (`onDocumentClosed`): Checks `hasSessionContent()` *before* clearing fields. If the document is unsaved and had content, shows a warning.

**IDE shutdown** (`handleIdeShutdown`): Saves session for active document, optionally processes pending fix learnings, runs `save_session_log`.

**Pointer safety**: `mLastActiveDocument` is a `QPointer<Document>` — auto-nullifies when the Document object is destroyed, preventing dangling pointer access.

## Session Logs (`use-logs/`)
Timestamped markdown files + JSON stats aggregating:
- Per-provider cost, time, token counts
- Environmental metrics (energy, GWP, ADPE, PE, WCF)
- Fallback estimation flags

## Session Log Resolution (Python side — `utils.py`)

`_get_active_session_log_path(active_file)` resolves which log file to use:
1. If `active_file` is in the session map (`.session_map.json`) → use mapped log
2. If session map is **empty** and an active session pointer exists → claim the bootstrap log (first file only)
3. Otherwise → create a new session log for this file (fixed 2026-06-10: no longer greedily steals the pointer from other files)
4. If no `active_file` → fall back to the global active session pointer

## Google Docs Integration
OAuth2 with auto-refresh, batch sync of finalized logs to a configured Google Doc.

## Offline Learning (`pending_fixes.json`)
Fix tab corrections are queued and processed at IDE shutdown — lessons extracted and appended to `system-improvements.md`.

---

# 14. OBSERVABILITY & SUSTAINABILITY TRACKING

## LangSmith
- `@traceable` decorator on `LLMClient.generate()`
- Auto-configured via `LANGCHAIN_API_KEY` env var
- Project: "SuperCollider-AI-Assist"

## Logfire (Pydantic)
- Auto-instrumentation of LLM providers
- `LOGFIRE_TOKEN` env var

## EcoLogits
- Environmental impact tracking: energy (kWh), GWP (kgCO2eq), ADPE (kgSbeq), PE (MJ), WCF (m³ water)
- Fallback estimation when native tracking unavailable
- Displayed in IDE sustainability dialog (5-metric table + glossary)

## Context Window Tracking
- Progress bar in IDE with color coding: blue → yellow → red
- Per-model context limits from `CONTEXT_WINDOW_SIZES`

---

# 15. CONFIGURATION REFERENCE

```python
# API Keys (from .env)
GEMINI_API_KEY, ANTHROPIC_API_KEY, OPENAI_API_KEY, LANGCHAIN_API_KEY, LOGFIRE_TOKEN

# Models
GEMINI_MODEL = "gemini-2.5-flash"           # Free tier
GEMINI_PRO_MODEL = "gemini-3.1-pro-preview" # Paid
ANTHROPIC_MODEL = "claude-3-7-sonnet-20250219"
OPENAI_MODEL = "gpt-4o"
CURRENT_LLM_PROVIDER = "gemini"             # Default provider

# RAG
KNOWLEDGE_DB_PATH = "vectordb_knowledge_base"
EMBEDDING_MODEL = "BAAI/bge-small-en-v1.5"
RAG_K = 5
USER_LIB_BOOST = 1.5

# Auto-Execute
AUTO_EXECUTE_ENABLED = False
MAX_SYNTAX_RETRIES = 3
MAX_HISTORY_BLOCKS = 10

# Google Docs
DOCUMENT_ID = '1YaAr1jlZ3w5N1t3GeIf_-o8j1za0jvTaTEpcL1JIBdo'

# Context Windows
gemini-2.5-flash: 1,048,576 tokens
gemini-3.1-pro-preview: 2,097,152 tokens
claude-3-7-sonnet: 200,000 tokens
gpt-4o: 128,000 tokens

# Pricing (USD per 1M tokens)
gemini-2.5-flash: in=$0.00, out=$0.00
gemini-3.1-pro-preview: in=$3.50, out=$15.00
claude-3-7-sonnet: in=$3.00, out=$15.00
gpt-4o: in=$2.50, out=$10.00

# Temperature Ranges (AVAILABLE_MODELS)
gemini models: 0.0 - 2.0, default 0.7
anthropic: 0.0 - 1.0, default 0.5
openai: 0.0 - 2.0, default 0.7
```

---

# 16. BUILD & DEPLOYMENT

## SC IDE Build (Windows)
```bash
# Prerequisites: Git, CMake 3.5+, VS C++ Build Tools 2019/2022, Qt 5.15, Python 3
cd supercollider-AI-assist
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:\Qt\5.15.2\msvc2019_64" ..
cmake --build . --config Release --target SuperCollider
# Output: build\editors\sc-ide\Release\scide.exe
```

## Python Environment
```bash
cd sc-gen-rag
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
# OR: pdm install
```

## Running
```bash
# CLI mode (standalone):
python main.py

# IDE mode: Launch custom scide.exe, AI panel is in Post window dock
```

---

# 17. KEY DESIGN DECISIONS & RATIONALE

1. **QProcess over HTTP/WebSocket**: Simpler, no server management, natural request-response pattern, temp file for large payloads
2. **sclang subprocess for Tier 2 validation**: More accurate than LLM review, faster, free, deterministic. LLM can't reliably catch SC-specific parse errors
3. **File-based workaround for Windows sclang**: Windows stdin line buffering truncates multi-line blocks — solved by writing to temp file and using `.load`
4. **State mirroring in validator**: After validation passes, code is silently evaluated in validation sclang to keep runtime state synchronized for next block
5. **USER_LIB_BOOST = 1.5**: RAG biased toward user's curated examples over generic SC docs — curated examples are more relevant to the JITLib/Ndef patterns used
6. **Compositional prompts**: System messages stacked from multiple files enables mix-and-match customization per use case, and the user can edit/reorder them via the IDE dialog
7. **Self-improving memory**: `system-improvements.md` accumulates lessons across sessions — rudimentary RL that prevents repeating the same mistakes
8. **Per-document sessions**: Each .scd file gets its own AI session context, enabling multiple compositions in parallel without state confusion
9. **Design pipeline uses SynthDef (not Ndef)**: MIDI synthesizers need pre-compiled SynthDefs with `doneAction: 2` for proper voice management; Ndef pattern doesn't support polyphonic MIDI well
10. **Auto-reload without dialog**: The IDE silently reloads files changed on disk (by the Python backend) without prompting the user — essential for the generate → file write → IDE update loop

---

# 18. KNOWN ISSUES & GOTCHAS

1. **sclang Windows stdin truncation**: Multi-line code on Windows causes "unexpected end of file" — solved by temp file + `.load`
2. **DLL Hell with Qt versions**: Multiple Qt versions can conflict — use `windeployqt.exe` on both `scide.exe` and `sclang.exe`
3. **SC class library requires GUI mock in Docker**: Even headless mode needs Xvfb because class library depends on Qt
4. **Parse errors can't be sandboxed in single sclang**: `.try` only catches runtime errors, not parse errors — need separate process
5. **Embedding model inconsistency**: README mentions `all-MiniLM-L6-v2` but config uses `BAAI/bge-small-en-v1.5` — config is authoritative
6. **`t_trig` with continuous Ndefs**: Causes immediate dropouts — custom/implement-v2.md explicitly documents this fix (multiply by `amp` instead, let JITLib handle crossfading)
7. **High temperature experiments**: Temperature values 5-7 (mapped from slider 0-20) produce garbled plan text (visible in session JSONs) — intended for creative exploration, not production
8. **Concurrent process guard**: Only one backend command runs at a time; attempting a second shows a warning
9. **`.pending_fixes.json` processing**: Fix learnings accumulate and are only processed on IDE shutdown — if IDE crashes, learnings may be lost
10. **Google Docs token refresh**: `invalid_grant` errors handled by re-authenticating via local server flow

### Fixed Session Bugs (2026-06-10)
The following 8 bugs were identified and fixed in a single pass:

| # | Bug | Files Changed |
|---|-----|---------------|
| 1 | `mLastActiveDocument` uninitialized (garbage pointer on first document switch) | `ai_assist_widget.cpp` |
| 2 | First document at startup missed signal connection (session never restored) | `ai_assist_widget.cpp` |
| 3 | `clearSessionFields` called before `hasSessionContent` (warning never shown) | `ai_assist_widget.cpp` |
| 4 | Variable name shadowing `doc` in `saveSessionFor` | `ai_assist_widget.cpp` |
| 5 | No `tryUpdateSessionStats` after session restore (stale values on screen) | `ai_assist_widget.cpp` |
| 6 | `init_session` called in constructor with wrong/empty `active_file` | `ai_assist_widget.cpp` |
| 7 | Raw `Document*` pointer susceptible to dangling after `deleteLater` | `ai_assist_widget.hpp` |
| 8 | Python `_get_active_session_log_path` greedily stole session pointers | `utils.py` |

### Recent Enhancements & Fixes (2026-07)
| Feature / Bug | Files Changed | Description |
|---|---|---|
| Append Tab Context Transparency | `gui_backend.py`, `ai_assist_widget.cpp/hpp`, `test_append_pipeline.py` | Removed the "Use code as context" checkbox entirely. The append tab now silently falls back to the last 2000 chars of the active file for context. This length is documented in the logging to ensure transparency. |
| Dictation Mute Guard Fix | `ai_assist_widget.cpp` | Removed redundant `mDictationMuted` C++ check on `dictation_final` message arrival. The Python backend already captures mute state when speech *starts* (`muted_at_rec_start`). The C++ guard caused valid transcriptions to drop if the user muted while the transcription was still processing. |
| Dictation UTF-8 Encoding Fix | `gui_backend.py` | Injected `PYTHONUTF8=1` into the background Python daemon proxy environment. This prevents Windows' legacy `cp1252` encoding from corrupting special characters (like Portuguese accents "três") originating from the faster-whisper C++ backend before they reach the Qt IDE's JSON parser. |
| Dictation Model Default | `gui_backend.py` | Set default language to Brazilian Portuguese (`pt`) and default model to `large-v3-turbo` for faster-whisper. |
| Append Tab Auto-Execute | `ai_assist_widget.cpp` | Previous fix relied on `autoEvaluateLastRegion`, which only worked if the LLM output contained top-level `(...)` parentheses. Fixed by directly evaluating the generated `code` block using `Main::evaluateCode(code)`, perfectly mimicking a manual Ctrl+Enter selection. |
| Append Tab KB Toggle | `ai_assist_widget.cpp/hpp`, `gui_backend.py` | Added "Use KB" toggle to the Append tab, sending a `use_kb` flag to the python backend to selectively disable RAG. |
| Gemini 3.5 Flash | `config.py` | Added `gemini-3.5-flash` model option with context window (1M tokens) and updated pricing. |
| Dual-Write File Race Condition | `gui_backend.py` | Fixed a duplicate-code bug where the Python backend wrote the code to the file on disk before returning the response, causing duplicate code insertion (and unreliable auto-execution in the Append tab). Removed `_write_scd` from `cmd_generate_code`, `cmd_custom_generate`, `cmd_append`, `cmd_fix`, and `cmd_remake` since the C++ side handles inserting the code into the document buffer. |
| Model Dropdown Fallback & Timeout | `ai_assist_widget.cpp` | Increased `list_models` timeout from 3s to 15s to handle Python cold start import times. Added `gemini-3.5-flash` to the hardcoded fallback list in case the backend request still fails. |
| Persistent AI Daemon & Async State | `gui_backend.py`, `ai_assist_widget.cpp/hpp` | Eliminated the 30-50s latency bottleneck caused by per-command Python startup (`import` costs). Transformed the C++ `QProcess` usage to a single, persistent daemon running `python gui_backend.py serve`. C++ now sends commands to the daemon via JSON on stdin. Composition state updates in `cmd_append` were moved to a background thread to return code instantly. `saveSessionFor` and `tryUpdateSessionStats` now use asynchronous `QProcess` without blocking the main thread. |
| Lazy-Loaded API Imports | `utils.py` | Moved Google Docs API imports (`google.auth`, `googleapiclient`, etc.) from the module top-level into `get_docs_service()` to avoid paying a ~6s import penalty on every backend script execution. |
| Voice Dictation (Speech-to-Text) | `gui_backend.py`, `ai_assist_widget.cpp/hpp`, `requirements.txt` | Added 🎤 microphone dictation button to the Append tab. Uses RealtimeSTT (faster-whisper `medium` model + Silero VAD) for free, offline, real-time speech-to-text. Python daemon runs the recorder in a background thread, streaming final transcription results as unsolicited JSON messages (`dictation_final`) back to the C++ side. New daemon commands: `start_dictation`, `stop_dictation`. |
| Dictation Toggle Race Condition Fix | `gui_backend.py` | Fixed inverted start/stop behavior caused by a race condition during Whisper model loading. The old code checked `_dictation_recorder is None` to decide if dictation was running, but the recorder object was only assigned *after* the slow model load (~3-5s). If stop was called during loading, it returned "not_running" and did nothing, then recording started after the model finished. Fixed by adding a `_dictation_active` flag that is set `True` immediately on start and checked at two points after model loading before entering the recording loop. |
| Block-Based Dictation + Auto-Append | `gui_backend.py`, `ai_assist_widget.cpp/hpp` | Reworked dictation from cumulative retranscription to block-based: each 1s silence creates a new block separated by — — — — — in the prompt field. Removed `on_realtime_transcription_update` (which caused full retranscription) and increased `post_speech_silence_duration` to 1.0s. Added "Auto-Append" checkbox that enqueues each dictation block into a `QQueue<QString>` and processes them FIFO via `processAppendQueue()`. The queue drains one block at a time—each `submitAppendForBlock` callback calls `processAppendQueue()` to dequeue the next. Manual "Append" click still works (sends full prompt text directly). Prompt field is never auto-cleared. |
| SuperCollider Memory Spikes Fix | `CMakeLists.txt` | Resolved an issue where running long compositions caused massive memory spikes (unlike the official SC release). The custom build had `SC_MEMORY_DEBUGGING=ON` enabled in CMake, which adds `-DDISABLE_MEMORY_POOLS`. This forced every real-time audio allocation (synths, UGens, buffers) to bypass SC's efficient pre-allocated memory pool and use raw `malloc`/`free`, causing heap fragmentation and massive overhead. Fixed by configuring CMake with `-DSC_MEMORY_DEBUGGING=OFF`. |
| Windows Multiprocessing Spawn Deadlock | `RealtimeSTT/core/runtime.py` | Fixed an infinite hang ("Waiting for main transcription model to start") caused by `torch.multiprocessing` deadlocking during `NtQueryInformationFile` in C-level `Py_InitializeFromConfig` when spawned from a daemon process with redirected standard I/O (no console). Bypassed completely by patching `RealtimeSTT` to unconditionally use `threading.Thread` instead of `multiprocessing.Process` on Windows. Performance remains identical because underlying libraries (`faster_whisper`, `pyaudio`) release the GIL. |
| Dictation I/O Operation on Closed File Crash | `gui_backend.py` | Fixed a crash when stopping dictation. `RealtimeSTT` imports implicitly initialized `colorama`, which wrapped the globally redirected `sys.stdout` (temporarily set to `os.devnull` to suppress PyAudio warnings). When the dictation thread closed `devnull` without restoring `sys.stdout`, the colorama wrapper retained the closed file reference. Stopping dictation attempted to `print()`, traversing the wrapper and crashing the daemon. Fixed by using a safe `DummyStdout` class that ignores `close()` calls, and properly saving/restoring `original_stdout` in the `finally` block. |
| Dictation Mute Feature & Latency Fix | `ai_assist_widget.cpp/hpp`, `gui_backend.py` | Added a mute button next to the mic to pause processing without terminating the dictation session. Handled immediately in the C++ layer: when `dictation_final` messages arrive while muted, they are dropped instantly, bypassing the Python queue latency so no undesired text slips in while waiting for background LLM processes to clear. |
| Multi-Block Auto-Execution | `ai_assist_widget.cpp` | LLM outputs generating multiple `()` blocks concurrently would fail SC's interpreter because `Main::evaluateCode` treats it as a single expression (triggering "unexpected '('" syntax errors). Fixed by adding a depth-tracking parser to split the returned string into individual top-level `()` blocks (handling comments/strings properly) and evaluating each separately. |
| Dictation Race Condition & Stale Enqueueing | `gui_backend.py` | Fixed a bug where restarting dictation produced ghost text (a late `dictation_final` message arriving from the old instance). Added `_dictation_session_id` to strictly separate transcription results; any asynchronous callbacks returning an old session ID are ignored. Also improved thread cleanup to ensure the mic releases cleanly. |
| Code Fence Stripping & "Empty Code" | `llm_engine.py`, `gui_backend.py` | Enhanced code extraction from LLM outputs. Replaced naive string replacements (`.replace("```supercollider", "")`) with robust regex in `strip_code_fences()` catching alternative SC markers (` ```sc `, ` ```sclang `). Added diagnostic logs for "empty code" responses from LLM when non-coding context queries are asked. |
| API Key Missing Exception Handling | `llm_engine.py` | Prevented hard daemon crashes on missing API keys. Handled via `ValueError` catch inside the python serving loop returning standard JSON error responses. |
### Concurrency Model
- **C++ UI guard**: `runBackendCommand` checks `mDaemonBusy || mCurrentProcess` and shows a "Busy" warning, preventing concurrent tab commands.
- **Python daemon**: `serve()` processes commands sequentially in a `for line in sys.stdin` loop — blocks on each command, reads the next only after writing the response.
- **Intentional overlap**: `cmd_append` fires composition state update in a background `threading.Thread` (second LLM call), which is safe since LLM APIs are stateless REST endpoints.
- **Dictation bypass**: Dictation commands are written directly to daemon stdin (not via `runBackendCommand`), so they don't set `mDaemonBusy`. If the daemon is busy with an LLM command, dictation start/stop will queue in stdin until the current command completes.
- **Append queue**: Auto-append dictation blocks are queued in `mAppendQueue` (`QQueue<QString>`) and drained FIFO — each `submitAppendForBlock` callback calls `processAppendQueue()` to send the next block. No concurrent LLM requests.

---

# 19. FILE-BY-FILE QUICK REFERENCE

| File | Lines | Purpose |
|------|-------|---------|
| `gui_backend.py` | 689 | ★ IDE backend (JSON command protocol) |
| `agent_graph.py` | 689 | One-shot LangGraph pipeline |
| `agent_graph_incremental.py` | 1029 | Incremental LangGraph pipeline |
| `llm_engine.py` | 284 | Multi-provider LLM client with observability |
| `rag_engine.py` | 140 | ChromaDB + HuggingFace RAG |
| `utils.py` | 468 | Google Docs, session logging, stats |
| `config.py` | 85 | Central configuration |
| `main.py` | 115 | CLI entry point |
| `build_knowledge_db.py` | 69 | Vector DB builder |
| `validate_knowledge_db.py` | 235 | Vector DB validation |
| `inspect_vectordb.py` | 198 | Vector DB inspection |
| `ai_assist_widget.hpp` | 280 | AI panel header (uses QPointer for safe document tracking) |
| `ai_assist_widget.cpp` | 2336 | ★ AI panel implementation (tabs, backend comm, sessions) |
| `doc_manager.cpp` | ~1285 | Auto-reload + auto-evaluate |
| `sys_msgs_defaults.json` | 45 | Use case → prompt mapping |
| System messages (19 files) | ~2500 | LLM behavior definitions |
| Knowledge base (16 files) | ~3500 | RAG examples |

---

# END OF SCRATCHPAD

> **How to use this document**: Load this file at the start of any new AI session working on this project. It contains all the context needed to understand the architecture, make informed changes, and avoid known pitfalls. For deeper dives into specific components, refer to the files in `sc-gen-rag-docs/` and the source code itself.
