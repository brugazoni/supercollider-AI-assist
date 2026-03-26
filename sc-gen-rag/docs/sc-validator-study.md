# SuperCollider Validation Server — Complete Study

> Full research documentation, architecture analysis, and implementation strategy for adding automatic syntax validation and code execution to the SC-Gen-RAG incremental composition pipeline.

---

## Table of Contents

1. [Project Context](#project-context)
2. [Codebase Architecture](#codebase-architecture)
3. [SC Internals: sclang vs scsynth](#sc-internals-sclang-vs-scsynth)
4. [Feature 1: Auto-Execute Toggle](#feature-1-auto-execute-toggle)
5. [Feature 2: Two-Tier Syntax Validation](#feature-2-two-tier-syntax-validation)
6. [Feature 3: SC IDE Auto-Evaluate on Reload](#feature-3-sc-ide-auto-evaluate-on-reload)
7. [Validation Server: Feasibility Analysis](#validation-server-feasibility-analysis)
8. [Strategy Comparison Matrix](#strategy-comparison-matrix)
9. [Recommended Architecture](#recommended-architecture)
10. [Implementation Status](#implementation-status)
11. [Verification Plan](#verification-plan)

---

## Project Context

The system consists of two projects:

1. **SC-Gen-RAG** (`sc-gen-rag/`): A Python application that generates SuperCollider code via LLM prompting with RAG. Supports one-shot and incremental (block-by-block) composition modes.
2. **SuperCollider-AI-Assist** (`supercollider-AI-assist/`): A modified SuperCollider IDE that auto-reloads files when changed externally, bypassing user confirmation dialogs.

### Current Workflow (Before Changes)

```
User prompt → Python LLM generates SC code → writes to test.scd
→ SC IDE detects file change → auto-reloads document
→ User MANUALLY selects and evaluates code block (Ctrl+Enter)
```

### Goal

Close the gap: when a new block is written, the system should **automatically parse, validate, and execute** only the newest block — controlled by a user toggle.

---

## Codebase Architecture

### Python Generator — Key Files

| File | Role |
|---|---|
| `main.py` | Entry point; mode selection (one-shot vs incremental) |
| `agent_graph_incremental.py` | LangGraph state machine for incremental generation |
| `agent_graph.py` | LangGraph state machine for one-shot generation |
| `config.py` | All configuration: paths, models, API keys |
| `llm_engine.py` | LLM abstraction (Gemini / Ollama) |
| `rag_engine.py` | RAG pipeline with ChromaDB vector stores |
| `utils.py` | File I/O, Google Drive, user input helpers |
| `system-instruction.md` | Base system prompt for SC code generation |
| `system-instruction-incremental.md` | Addendum for incremental mode |

### SC IDE — Key Files

| File | Role |
|---|---|
| `core/doc_manager.cpp` | Document management; `onFileChanged()` auto-reload |
| `core/doc_manager.hpp` | Header for DocumentManager class |
| `core/sc_process.cpp` | sclang process wrapper (`QProcess`); code evaluation |
| `core/sc_process.hpp` | Header for ScProcess class |
| `core/sc_server.cpp` | scsynth server wrapper; OSC/UDP communication |
| `core/main.cpp` | IDE initialization; creates ScProcess + ScServer |
| `widgets/code_editor/sc_editor.cpp` | Code evaluation functions (`evaluateLine`, `evaluateRegion`) |

### Incremental Graph Flow (Pre-Modification)

```
load_resources → classify_block → generate_block → write_block → verify_block
    ↓ (if correct)                                        ↓ (if incorrect)
update_composition → END                          correction_auto/manual/external
                                                         ↓
                                                    apply_patch → verify_block
```

---

## SC Internals: sclang vs scsynth

### Critical Discovery

SuperCollider has a strict **two-process architecture**:

| Process | Role | Communication | Error Handling |
|---|---|---|---|
| **sclang** | Language interpreter — parses, compiles, evaluates SC code | Receives code via stdin + control characters | Outputs `ERROR:` prefixed messages to stdout |
| **scsynth** | Audio DSP engine — synthesizes sound from SynthDefs | Receives OSC messages via UDP | Status replies via OSC |

**Syntax errors are caught entirely by sclang**, before anything reaches scsynth. This is the foundational insight for the validation architecture.

### sclang stdin Protocol

From `sc_process.cpp` — how the IDE sends code to sclang:

```cpp
void ScProcess::evaluateCode(QString const& commandString, bool silent) {
    QByteArray bytesToWrite = commandString.toUtf8();
    write(bytesToWrite);
    // 0x1b = interpret silently, 0x0c = interpret and print result
    char commandChar = silent ? '\x1b' : '\x0c';
    write(&commandChar, 1);
}
```

### sclang Error Output

From `SC_TerminalClient.cpp` — how sclang reports errors:

```cpp
void SC_TerminalClient::postError(const char* str, size_t len) {
    fprintf(gPostDest, "ERROR: ");
    fwrite(str, sizeof(char), len, gPostDest);
}
```

Error patterns include:
- `ERROR: Parse error` — syntax errors (missing brackets, bad tokens)
- `ERROR: syntax error, unexpected ...` — specific parse failures
- `ERROR: Variable '...' not defined` — undefined symbols

### sclang Standalone Operation

From `SC_TerminalClient.cpp` — sclang can run headless:

```cpp
int SC_TerminalClient::run(int argc, char** argv) {
    initRuntime(opt);               // Initialize runtime
    compileLibrary(opt.mStandalone); // Compile class library (~5-10s)
    if (!compiledOK) { return EXIT_FAILURE; }
    if (opt.mDaemon) {
        daemonLoop();               // Headless mode available
    } else {
        commandLoop();              // Interactive mode
    }
}
```

### SC Server Class — Multi-Server Support

From `Server.sc` — SC natively supports multiple server instances:

```supercollider
// Built-in servers
Server.local    // localhost:57110
Server.internal // in-process

// Custom servers are trivial to create
~myServer = Server(\custom, NetAddr("127.0.0.1", 57111));
~myServer.options.numOutputBusChannels = 0;
~myServer.options.numInputBusChannels = 0;
```

However, multiple `Server` instances share the **same sclang process** — parse errors in one affect all.

---

## Feature 1: Auto-Execute Toggle

### Design

- **Config**: `AUTO_EXECUTE_ENABLED = False` (default off)
- **Session prompt** in `main.py`: `"Enable Auto-Execute? (y/n)"` before starting incremental mode
- **Passed through** to `run_incremental_session(auto_execute=True/False)` and into the graph state

### Modified Graph (Auto-Execute ON)

```
generate → extract_new_block → syntax_validate → [valid?]
    ↓ yes                                          ↓ no (retries left)
write_block → update_composition → END       syntax_correction → syntax_validate
                                                   ↓ no (max retries)
                                             write_block → verify_block (manual fallback)
```

### Modified Graph (Auto-Execute OFF)

Unchanged from original flow.

---

## Feature 2: Two-Tier Syntax Validation

### Tier 1: Local Structural Checks (No LLM, No sclang)

Fast, free, runs in Python:

1. **Bracket matching**: `( ) { } [ ]` balance check, respecting strings and comments
2. **Empty block detection**: Rejects blocks that are only comments/whitespace
3. **String/comment awareness**: Properly tracks `" "`, `// ...`, `/* ... */` to avoid false positives

### Tier 2: sclang Subprocess Validation (Replaces LLM)

Originally designed as an LLM-based semantic check. **Now replaced** by a headless sclang subprocess:

```
Python sends code → sclang stdin (+ 0x0c control char)
sclang parses → stdout output
Python reads stdout → checks for "ERROR:" pattern
    → VALID or INVALID + error message
```

This is **more accurate, faster, and free** compared to the LLM approach.

### Auto-Correction Loop

When validation fails:
1. Error message is sent to the LLM with the failing code
2. LLM generates a corrected version
3. Corrected code goes back through Tier 1 + Tier 2
4. Max 3 attempts before falling back to manual verification

---

## Feature 3: SC IDE Auto-Evaluate on Reload

### Changes to `doc_manager.cpp`

After the existing `reload(doc)` succeeds in `onFileChanged()`:

```cpp
if (mAutoEvaluateEnabled) {
    autoEvaluateLastRegion(doc);
}
```

### `autoEvaluateLastRegion` Algorithm

1. Get the document's full plain text
2. Scan backwards from end to find the last top-level `(...)` region (opening `(` at column 0)
3. Extract that region's text
4. Call `Main::evaluateCode(regionText)` to execute in sclang

### Safety Considerations

- `mAutoEvaluateEnabled` flag (initialized `true`) provides an IDE-side kill switch
- The Python-side validation acts as the safety net — the IDE trusts validated code
- If validation misses something, auto-evaluation could produce noise or hang the server

---

## Validation Server: Feasibility Analysis

### Approach A: SC IDE Internal Validation Server

Create a second `Server` instance within the same sclang session.

```supercollider
~validationServer = Server(\validation, NetAddr("127.0.0.1", 57111));
~validationServer.options.numOutputBusChannels = 0;
```

**Verdict: ❌ Not viable.**

Parse errors are caught at the **parser** level before evaluation. A second Server instance shares the same sclang parser — parse errors can't be sandboxed within a single sclang process. SC's `.try` only catches runtime exceptions, not syntax errors.

---

### Approach B: Python-Managed sclang Subprocess ⭐

Run a dedicated sclang process from Python. Feed code via stdin, capture stdout/stderr, check for errors.

**Architecture:**

```
Python Generator                         Validation sclang (subprocess)
┌──────────────────┐                     ┌──────────────────────────┐
│ generate_block   │                     │ sclang process           │
│      ↓           │                     │                          │
│ extract_block    │                     │ - Class library compiled │
│      ↓           │   code + 0x0c      │ - No server booted       │
│ Tier 1 check     │ ──────────────────→ │ - Receives code via stdin│
│      ↓           │                     │ - Parses & evaluates     │
│ Tier 2: sclang   │ ←────────────────── │ - Returns result/errors  │
│ (read stdout)    │   stdout output     │   via stdout             │
│      ↓           │                     │                          │
│ write_block      │   mirror accepted   │ - Mirrors accepted blocks│
│                  │ ──────────────────→ │   to maintain state      │
└──────────────────┘                     └──────────────────────────┘
```

**Verdict: ✅ Recommended.**

Advantages:
- True parse-level validation via sclang's actual parser
- No IDE modifications needed (purely Python-side)
- Isolated process — errors can't affect the main IDE
- No audio device needed — sclang without a booted server still parses correctly
- Replaces LLM Tier 2 — saves API cost, faster, deterministic
- ~1s response time vs LLM API round-trip

Challenges:
- Startup time (~5-10s for class library compilation; done once at session start)
- Output parsing requires robust `ERROR:` detection vs normal output
- State mirroring: validation sclang must know about previously defined names

**State mirroring solution:** After each block is validated and accepted, also evaluate it in the validation sclang. This keeps both processes in sync with minimal overhead.

---

### Approach C: SC IDE Dual-sclang Architecture

Modify the IDE's C++ code to launch two `ScProcess` instances.

```cpp
// Would require:
mScProcess(new ScProcess(mSettings, this)),           // Main
mValidationProcess(new ScProcess(mSettings, this)),   // Validation-only
```

**Verdict: ❌ Too complex.**

`ScProcess` is tightly coupled to IDE signals, IPC server names (`SCIde_<pid>`), and the document manager. Running two in the same IDE requires significant refactoring of C++ internals, with no benefit over Approach B.

---

## Strategy Comparison Matrix

| Criteria | A: IDE Internal | B: Python sclang ⭐ | C: IDE Dual-sclang | LLM Tier 2 (original) |
|---|---|---|---|---|
| True syntax validation | ❌ Can't sandbox | ✅ Full parser | ✅ Full parser | ⚠️ Approximate |
| No IDE changes needed | ✅ | ✅ | ❌ Heavy refactor | ✅ |
| No audio device needed | ❌ Shares server | ✅ No server | ✅ Possible | ✅ |
| Isolation from main | ❌ Same process | ✅ Separate | ✅ Separate | ✅ |
| Implementation complexity | Low (incorrect) | **Medium** | Very high | Low |
| Startup cost | None | ~5-10s (once) | ~5-10s (once) | None |
| Per-validation cost | N/A | <1s, free | <1s, free | ~2-5s, API tokens |
| Deterministic results | N/A | ✅ | ✅ | ❌ |
| Catches all parse errors | ❌ | ✅ | ✅ | ⚠️ Most |

---

## Recommended Architecture

### Final Pipeline

```
User prompt
    ↓
generate_block_node (LLM generates SC code)
    ↓
extract_new_block_node (ensure ( ) wrapping)
    ↓
syntax_validate_node:
    ├─ Tier 1: Python structural check (bracket matching, empty block)
    │   → Fails fast, no external process needed
    └─ Tier 2: sclang subprocess validation
        → Sends code to headless sclang via stdin
        → Reads stdout for ERROR: patterns
        → Returns VALID or INVALID + error message
    ↓ (if invalid, up to 3 retries)
syntax_correction_node (LLM auto-fix)
    ↓ (re-validate)
    ↓ (if valid)
write_block_node → file updated
    ↓
SC IDE: onFileChanged() → reload() → autoEvaluateLastRegion()
    ↓
Sound plays automatically
```

### Key Design Decisions

1. **sclang subprocess replaces LLM Tier 2** — more accurate, faster, free
2. **State mirroring**: accepted blocks are echoed to the validation sclang to maintain context
3. **Validator starts once** at session begin, stays alive throughout
4. **Max 3 auto-correction attempts** before falling back to manual verification
5. **IDE auto-evaluate** is gated by `mAutoEvaluateEnabled` flag (independent kill switch)

---

## Implementation Status

### Phase 1: Auto-Execute + Validation Nodes ✅

| File | Change | Status |
|---|---|---|
| `config.py` | Added `AUTO_EXECUTE_ENABLED`, `MAX_SYNTAX_RETRIES`, `SCLANG_PATH`, `SCLANG_BOOT_TIMEOUT` | ✅ |
| `main.py` | Added auto-execute toggle prompt in incremental mode | ✅ |
| `agent_graph_incremental.py` | Added state fields, `extract_new_block_node`, `_tier1_structural_check`, `syntax_validate_node`, `syntax_correction_node`, conditional graph wiring, updated session runner | ✅ |
| `doc_manager.hpp` | Added `autoEvaluateLastRegion` declaration, `mAutoEvaluateEnabled` flag | ✅ |
| `doc_manager.cpp` | Added `autoEvaluateLastRegion` method, call from `onFileChanged`, init flag in constructor | ✅ |

### Phase 2: sclang Validator Subprocess 🔄

| File | Change | Status |
|---|---|---|
| `config.py` | Added `SCLANG_PATH`, `SCLANG_BOOT_TIMEOUT` | ✅ |
| `sclang_validator.py` | New module — subprocess lifecycle management | 🔄 In progress |
| `agent_graph_incremental.py` | Replace Tier 2 LLM check with `SclangValidator.validate()` | Pending |
| `run_incremental_session` | Start/stop validator, mirror accepted blocks | Pending |

---

## Verification Plan

### Automated Checks

- Python AST parse verification on all modified `.py` files
- All three files (`config.py`, `main.py`, `agent_graph_incremental.py`) confirmed clean via `ast.parse`

### Manual Testing Protocol

| Test | Steps | Expected |
|---|---|---|
| Toggle Prompt | Run `python main.py`, select mode 2 | "Enable Auto-Execute? (y/n)" prompt appears |
| Toggle OFF | Type "n" | Standard manual flow, no validation nodes |
| Toggle ON | Type "y" | Auto-execute enabled, validation nodes active |
| Tier 1 Pass | Request simple block (sine wave pad) | Structural check passes silently |
| Tier 1 Fail | Intentionally malformed brackets | "Tier 1 FAILED" in console, auto-correction triggered |
| Tier 2 Pass | Valid block through sclang | "Syntax validation PASSED" |
| Tier 2 Fail | Block with undefined UGen | Error from sclang, auto-correction triggered |
| Max Retries | 3 failed corrections | Falls back to manual `verify_block_node` |
| SC IDE Reload | With modified IDE running | File reloads + last region auto-evaluates |
| State Mirror | Multi-block session | Validation sclang knows about prior Ndefs |

### Prerequisites

- **Python changes**: work immediately with any Python 3.9+ environment
- **SC IDE changes**: require rebuilding the `supercollider-AI-assist` project
- **sclang validator**: requires `sclang` binary accessible on PATH or via `SCLANG_PATH` env var
