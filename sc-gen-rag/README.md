# SC-Gen-RAG

A research tool for studying **LLM-driven music generation** through **SuperCollider** code synthesis. Built on [LangGraph](https://github.com/langchain-ai/langgraph), it uses a **dense Vector Retrieval-Augmented Generation (RAG)** pipeline to ground prompts in real SuperCollider documentation and user-curated examples, then drives an interactive human-in-the-loop correction cycle so every generated patch can be evaluated, fixed, and logged for analysis.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
  - [Agent Graph (LangGraph)](#agent-graph-langgraph)
  - [RAG Pipeline](#rag-pipeline)
  - [LLM Backend](#llm-backend)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Starting the Tool](#starting-the-tool)
  - [Generation & Verification Loop](#generation--verification-loop)
  - [Correction Methods](#correction-methods)
  - [Session Logging](#session-logging)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Overview

SC-Gen-RAG converts natural-language musical descriptions into executable SuperCollider code. A typical session looks like this:

1. **You describe a sound** — e.g. *"a shimmering granular pad with slow pitch drift"*.
2. The system **refines your query** into SuperCollider-oriented keywords, then runs a **vector search** (semantic dense retrieval) over the SuperCollider help files and any custom `.scd` examples you provide.
3. An LLM generates a SuperCollider code block, grounded in the retrieved documentation.
4. You **listen to the result** in SuperCollider and tell the system whether it's correct.
5. If not, you choose a **correction path** — automatic re-generation, manual edit, or paste from an external LLM — and the loop repeats.
6. Once satisfied, you add comments and the full session is **logged to a Google Doc** for later research analysis.

---

## Architecture

### Agent Graph (LangGraph)

The core workflow is a compiled **LangGraph `StateGraph`** with the following nodes:

```
START
  │
  ▼
load_resources ──► generate_initial ──► verify_output ─┐
                                           ▲           │
                                           │           ├─ (correct) ──► summarize_improvements* ──► add_comments ──► log_to_drive ──► END
                                           │           ├─ (abort)   ──► add_comments ──► log_to_drive ──► END
                                           │           │
                                           │           ├─ (auto fix)     ──► correction_auto ──► apply_patch ──┐
                                           │           ├─ (manual fix)   ──► correction_manual ─────────────────┤
                                           │           └─ (external fix) ──► correction_external ──────────────┤
                                           │                                                                   │
                                           └───────────────────────────────────────────────────────────────────┘
```

\* `summarize_improvements` only runs when an **auto-fix** resolved a **programmatic** error, generating a "lesson learned" entry.

#### Key State Fields

| Field | Purpose |
|---|---|
| `user_query` | Original natural-language prompt |
| `code_context` | RAG-retrieved SuperCollider documentation |
| `current_code_block` | Latest generated / corrected code |
| `is_correct` | Whether the user accepted the code |
| `fix_mode` | `auto` · `manual` · `external` |
| `error_type` | `programmatic` · `aesthetic` |
| `aesthetic_scope` | `regenerate` (full rewrite) · `tweak` (partial edit) |
| `interaction_log` | Accumulated session transcript (appended per node) |
| `token_usage_log` | Token counts per LLM call |

### RAG Pipeline

The retrieval engine (`rag_engine.py`) uses a vector-based semantic search strategy matching natural language against indexed documents:

- **Semantic** (vector): ChromaDB + `all-MiniLM-L6-v2` | Conceptual similarity — maps "warm pad" to relevant synthesis examples

#### Indexing Pipeline

1. **Document loading** — reads `.scd` files from `knowledge_base/` and `.schelp` files from the local SuperCollider help tree.
2. **Chunking** — `RecursiveCharacterTextSplitter` with SuperCollider-aware separators (`{`, `(`, `;`).
3. **Embedding & persistence** — chunks are embedded with `all-MiniLM-L6-v2` and stored in a ChromaDB collection at `sc_vector_store/`.

#### Query Pipeline

1. The user's musical prompt is fed to the ensemble retriever, which returns the top-*k* (default 5) results.
2. Retrieved chunks are formatted and injected into the generation prompt as a `=== Knowledge Base ===` section.

### LLM Backend

`llm_engine.py` provides a unified `LLMClient` that wraps:

| Provider | Model (default) | Notes |
|---|---|---|
| **Gemini** | `gemini-2.5-flash` | Cloud API; requires `GEMINI_API_KEY` |
| **Ollama** | `qwen3:4b` | Local inference; requires Ollama running |

Switch between them by changing `CURRENT_LLM_PROVIDER` in `config.py`.

---

## Project Structure

```
sc-gen-rag/
├── main.py                 # Entry point — CLI loop
├── build_vectordb.py       # Standalone script to build/rebuild the vector DB
├── config.py               # All configuration constants
├── agent_graph.py          # LangGraph state machine (nodes + edges)
├── rag_engine.py           # Engine for RAG: indexing, retrieval
├── llm_engine.py           # Unified LLM client (Gemini / Ollama)
├── utils.py                # Google Docs integration, file I/O, input helpers
├── pyproject.toml          # Project metadata & dependencies (PDM)
├── pdm.lock                # Pinned dependency lockfile
├── .gitignore
├── .env                    # API keys (not committed)
│
├── knowledge_base/         # Place your .scd example files here for RAG indexing
├── sc_vector_store/        # ChromaDB persisted index (auto-generated)
├── sc-files/
│   └── test.scd            # Output file — generated code is appended here
│
├── system-instruction.md   # (optional) Custom system prompt for the LLM
├── system-improvements.md  # (auto-generated) Accumulated "lessons learned"
├── credentials.json        # Google OAuth2 credentials (not committed)
└── token.json              # Google OAuth2 token cache (not committed)
```

---

## Prerequisites

- **Python 3.10+**
- **[PDM](https://pdm-project.org/)** — Python dependency manager (`pip install pdm`)
- **SuperCollider 3.13+** installed (the help files at `SC_HELP_PATH` are used for RAG indexing)
- **Gemini API key** *or* **Ollama** installed and running locally
- *(Optional)* Google Cloud project with the **Google Docs API** enabled and OAuth2 credentials, for session logging

---

## Installation

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd sc-gen-rag
   ```

2. **Install dependencies** (creates a `.venv` automatically)

   ```bash
   pdm install
   ```

3. **Configure environment variables**

   Create a `.env` file in the project root:

   ```env
   GEMINI_API_KEY=your-api-key-here
   ```

4. *(Optional)* **Set up Google Docs logging**

   - Create a Google Cloud project and enable the **Google Docs API**.
   - Download your OAuth2 credentials and save them as `credentials.json` in the project root.
   - Update `DOCUMENT_ID` in `config.py` with the ID of the Google Doc you want to log to.
   - On first run, a browser window will open for OAuth consent; the resulting token is cached in `token.json`.

---

## Configuration

All settings live in `config.py`:

| Constant | Default | Description |
|---|---|---|
| `CURRENT_LLM_PROVIDER` | `"gemini"` | `"gemini"` or `"ollama"` |
| `GEMINI_MODEL` | `"gemini-2.5-flash"` | Gemini model name |
| `OLLAMA_MODEL` | `"qwen3:4b"` | Ollama model name |
| `SC_HELP_PATH` | `C:\Program Files\SuperCollider-3.13.0\HelpSource` | Path to SuperCollider help files |
| `CONTEXT_FOLDER` | `"knowledge_base"` | Folder for user-curated `.scd` examples |
| `VECTOR_DB_PATH` | `"sc_vector_store"` | ChromaDB persistence directory |
| `EMBEDDING_MODEL` | `"BAAI/bge-small-en-v1.5"` | Sentence-transformer model for embeddings |
| `RAG_K` | `5` | Number of documents returned per retrieval |
| `USER_LIB_BOOST` | `1.5` | Source weighting for retrieval ranking — values **>1** boost your own knowledge base (User-Lib) chunks, **<1** favor SC Help documentation, **1.0** is neutral |
| `OUTPUT_FILE` | `"sc-files/test.scd"` | File where generated code is written |
| `SYSTEM_TEXT_FILE` | `"system-text.md"` | Custom system prompt (optional) |
| `IMPROVEMENTS_FILE` | `"system-improvements.md"` | Auto-accumulated lessons learned |
| `DOCUMENT_ID` | *(Google Doc ID)* | Target Google Doc for session logging |

---

## Usage

### Starting the Tool

```bash
pdm run start
```

On first launch the vector index is built automatically from the SuperCollider help files and any `.scd` files in `knowledge_base/`. This can take several minutes depending on the number of files.

You'll see a prompt:

```
==========================================
  SC-Graph | Provider: gemini
  Vector DB: sc_vector_store
==========================================

SC-Graph>
```

### Built-In Commands

| Command | Action |
|---|---|
| Any text | Treated as a musical generation prompt |
| `rebuild` | Rebuilds the RAG vector index from scratch |
| `exit` / `quit` | Exits the application |

### Generation & Verification Loop

1. **Enter a musical description** — e.g. `a drone using Klank resonators with randomized frequencies`.
2. The system retrieves relevant context, generates a SuperCollider code block, and appends it to `sc-files/test.scd`.
3. **Open and evaluate** the code in SuperCollider's IDE.
4. At the verification prompt, choose:

   | Key | Action |
   |---|---|
   | `y` | Accept — code is correct |
   | `n` | Reject — enter correction flow |
   | `s` | Stop & save — abort session but still log |

### Correction Methods

When you reject the output, you first classify the issue:

- **Programmatic** — syntax errors, crashes, runtime exceptions
- **Aesthetic** — the code runs but the sound is wrong

Then select a correction method:

| Method | Description |
|---|---|
| **Auto-Fix (1)** | The internal LLM re-generates corrected code. For programmatic issues, you paste the bad block and the error message. For aesthetic issues, you describe the desired change. |
| **Manual Fix (2)** | You edit `sc-files/test.scd` yourself. The system picks up the changes. |
| **External LLM (3)** | You paste code from an external platform (ChatGPT, Claude, etc.). The system logs which model was used and what prompt you gave it. |

After correction, the loop returns to verification — you can iterate until the code is satisfactory.

### Session Logging

Once you accept the code (or abort), the tool:

1. Asks for **optional session comments**.
2. If an auto-fix resolved a programmatic bug, generates a **lesson-learned summary** and appends it to `system-improvements.md`. Future sessions load these lessons into the system prompt, so the LLM progressively avoids past mistakes.
3. Uploads the full session transcript — including all prompts, corrections, token usage, and the final code — to the configured **Google Doc**.

---

## Customization

### Adding Custom Examples to the Knowledge Base

Place `.scd` files in the `knowledge_base/` folder. These can be:

- Your own SuperCollider patches
- Examples from tutorials or libraries
- Curated code snippets demonstrating specific techniques

Then run `rebuild` inside the tool, or from the terminal:

```bash
pdm run build-db --force
```

### Custom System Prompt

Create a `system-text.md` file in the project root to override the default system prompt. This file is loaded at the start of every session and sets the base personality and instructions for the LLM.

### Using Ollama (Local Models)

1. Install and start [Ollama](https://ollama.ai/).
2. Pull a model: `ollama pull qwen3:4b`
3. In `config.py`, set:
   ```python
   CURRENT_LLM_PROVIDER = "ollama"
   OLLAMA_MODEL = "qwen3:4b"  # or any other model
   ```

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `Vector Database not found` on every start | The index build may be failing silently. Check that `SC_HELP_PATH` points to a valid SuperCollider installation and that `knowledge_base/` contains `.scd` files. |
| `Gemini API key missing` | Ensure `.env` contains `GEMINI_API_KEY=your-key` and that `python-dotenv` is installed. |
| `Ollama Error: connection refused` | Make sure Ollama is running (`ollama serve`) before starting the tool. |
| Google Docs upload fails | Verify `credentials.json` exists, `DOCUMENT_ID` is correct, and the Google Docs API is enabled in your Cloud project. Delete `token.json` and re-authenticate if the token expired. |


---

## License

This project is a research prototype. Please refer to the project owner for licensing terms.
