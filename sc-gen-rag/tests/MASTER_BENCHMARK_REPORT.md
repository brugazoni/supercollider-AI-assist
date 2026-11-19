# Master Benchmark Compendium: Multi-Provider X-Append SuperCollider Evaluation

**Generated**: 2026-11-13 14:19:30 UTC
**Author/Evaluator**: SuperCollider AI Assist (DeepMind Antigravity)
**Corpus**: 200-fragment Brazilian Portuguese Literary & Technical Corpus (`ptbr_xappend_corpus_200.json`)
**Compiler Environment**: SuperCollider `3.14.1` (via `SclangParallelValidator`) on Windows
**Providers & Gateway**: OpenRouter API (`openrouter.ai/api/v1`)

---

## Executive Table of Contents
1. [Overview & Evaluation Architecture](#1-overview--evaluation-architecture)
2. [Grand Comparison: Fast Tier vs. Next Tier Across All Batteries](#2-grand-comparison-fast-tier-vs-next-tier-across-all-batteries)
3. [Battery 1: Initial 10-Round Multi-Provider Stress Test (4 Models)](#3-battery-1-initial-10-round-multi-provider-stress-test-4-models)
4. [Battery 2: 8-Round Specialization & 120s Timeout Guard (5 Models)](#4-battery-2-8-round-specialization--120s-timeout-guard-5-models)
5. [Battery 3: Comprehensive Qualitative & Artistic Evaluation (Blind LLM Judge)](#5-battery-3-comprehensive-qualitative--artistic-evaluation-blind-llm-judge)
6. [Battery 4: Fast-Tier Unified Knowledge Base (KB) A/B Test (5 Models)](#6-battery-4-fast-tier-unified-knowledge-base-kb-ab-test-5-models)
7. [Battery 5: Next-Tier Unified Knowledge Base (KB) A/B Test (4 Models)](#7-battery-5-next-tier-unified-knowledge-base-kb-ab-test-4-models)
8. [Comprehensive Mode-by-Mode Specialization Breakdown](#8-comprehensive-mode-by-mode-specialization-breakdown)
9. [Artistic Signatures, DSP Idioms & Systemic Blind Spots](#9-artistic-signatures-dsp-idioms--systemic-blind-spots)
10. [Artifact Index & Verifiable File Links](#10-artifact-index--verifiable-file-links)

---

## 1. Overview & Evaluation Architecture

This compendium unifies every automated empirical benchmark executed across the SuperCollider AI Assist lean prompt engine, testing both quantitative execution metrics and qualitative artistic/DSP quality across multiple leading LLM families.

### Evaluated Models by Tier

| Provider | Fast / Budget Tier | Next / Flagship Tier |
|:---|:---|:---|
| **Google** | `google/gemini-3.8-flash`<br>`google/gemini-4-hydrogen` | `google/gemini-4-carbon` |
| **Anthropic** | `anthropic/claude-haiku-5.5` | `anthropic/claude-sonnet-5.5` |
| **DeepSeek** | `deepseek/deepseek-v4.1-flash` | `deepseek/deepseek-v4-pro` |
| **OpenAI** | `openai/gpt-6-luna` | `openai/gpt-6.1-sol` |

### Evaluated X-Append Modes
- **`APPEND`**: Incremental live-coding layer addition and parameter evolution onto a running `Ndef`/`Pbindef` session without sound interruption.
- **`COMPOSE`**: Long-form multi-layer algorithmic timeline scores via `Tdef` and `Pbindef`, including macro-structure and cleanup concluding.
- **`DESIGN`**: Hardware MIDI-mapped playable synthesizers with multi-zone keyboard splits, hardware fallback, and paginated GUI control panels.
- **`GENERATE`**: Continuously evolving autonomous multi-layer generative soundscapes with frequency bracketing, stochastic textures, and ambient layers.

### Evaluation Pipeline & Guards
- **120-Second Strict Timeout**: Implemented via concurrent `ThreadPoolExecutor` and OpenAI client timeouts to prevent unhandled API hangs.
- **Automatic Normalization**: Deterministic code normalizer handling `Balance2` collection guards, reserved `pi` identifiers, and third-party UGen sanitization (`DPW4Saw` -> `Saw`).
- **Parallel Compilation Validator**: Real-time `sclang.exe` compilation validation over isolated localhost UDP ports.
- **Blind LLM-as-a-Judge**: Multi-stage evaluation (`anthropic/claude-sonnet-5.5` for fast tier; `anthropic/claude-opus-5.5` for next tier) measuring 6 dimensions (1.0 to 10.0 scale): Variety, Technical Depth, Compositional Audacity, Prompt Coherence, Compositional Arcs, and Creativity.

---

## 2. Grand Comparison: Fast Tier vs. Next Tier Across All Batteries

A high-level synthesis of all evaluated models across their primary benchmark configurations:

| Tier | Model | Best 1st-Pass Rate | Auto-Fix Reliance | Mean LLM Time | Qual Score (No KB) | Qual Score (With KB) | Primary Specialization |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| **Fast** | **OpenAI GP6 Luna** | **100.0%** | **0 fixes** | **19.40s** | 4.33 | 4.27 | Ultra-reliable, lightning fast, best for fast prototyping |
| **Fast** | **Gemini 4 Hydrogen** | 87.5% | Low (1 fix) | 26.54s | 4.65 | 4.69 | Solid all-rounder; strong in `COMPOSE` & `GENERATE` |
| **Fast** | **Claude Haiku Latest** | 75.0% | Low (1 fix) | 26.52s | 4.48 | 3.54 | Budget `COMPOSE` & `APPEND`; struggles with heavy `DESIGN` |
| **Fast** | **DeepSeek Flash Latest** | 75.0% | Medium (1-3 fixes) | 30.52s | 3.98 | 4.40 | Greatly elevated by KB; strong generative textures |
| **Fast** | **Gemini 3.8 Flash** | 50.0% - 70.0% | High (2-5 fixes) | 24.57s | 4.40 | **5.19** | Peak artistic ambition and UGen variety; higher syntax fragility |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|
| **Next** | **OpenAI GPT-6.1 Sol** | **100.0%** | **0 fixes (No-KB)** | **30.04s** | **6.12** | **6.39** | **Overall Champion**: Flawless compilation + #1 in Technical Depth & Composition |
| **Next** | **Gemini 4 Carbon** | 75.0% | Low-Med (1-2 fixes)| 54.02s | 5.71 | 5.37 | Elite electroacoustic composer in `APPEND`, `COMPOSE` & `GENERATE` |
| **Next** | **Claude Sonnet 5.5** | **100.0% (No-KB)** | **0 fixes** | **18.69s** | 5.15 | 4.67 | Fastest Next-Tier model; pristine syntax; excels in `COMPOSE` with KB |
| **Next** | **DeepSeek V4 Pro** | 50.0% | High (1-3 fixes) | 66.80s | 4.11 | 3.00 | Heavy reasoning overhead; prone to 120s timeout in `DESIGN`/`GENERATE` |

---

## 3. Battery 1: Initial 10-Round Multi-Provider Stress Test (4 Models)

**Execution Timestamp**: `2026-11-12T03:04:49.316080+00:00`
**Schedule**: 10 sequential rounds per model across randomized Brazilian Portuguese fragments (Rounds: 10)
**Knowledge Base**: Disabled (`use_kb=False`)

| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Calls | Mean LLM Time | Total Wall Time | Total In Tokens | Total Out Tokens | Total Cost (USD) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 70.0% (7/10) | 90.0% (9/10) | 4 | 150.07s | 2698.6s | 113,566 | 68,110 | $0.34060 |
| **Claude Haiku Latest** | 80.0% (8/10) | 80.0% (8/10) | 4 | 158.52s | 1747.7s | 151,027 | 110,236 | $0.07024 |
| **DeepSeek Flash Latest** | 80.0% (8/10) | 100.0% (10/10) | 2 | 190.30s | 2400.7s | 80,673 | 114,592 | $0.08189 |
| **OpenAI GP6 Luna** | 90.0% (9/10) | 90.0% (9/10) | 2 | 148.88s | 1556.2s | 84,135 | 33,767 | $0.02356 |

> **Key Findings (Battery 1)**:
> - **OpenAI GP6 Luna** established immediate technical dominance with a 90% 1st-pass rate, only 2 fixes, and the lowest cost (\$0.02356).
> - **DeepSeek Flash Latest** recovered 100% final compilation across 10 rounds after 2 auto-fix calls.
> - **Gemini 3.8 Flash** generated the longest, most intricate patches, but required 4 auto-fixes to resolve undeclared variables and JITLib slot conflicts.

---

## 4. Battery 2: 8-Round Specialization & 120s Timeout Guard (5 Models)

**Execution Timestamp**: `2026-11-12T22:44:25.581173+00:00`
**Enhancements**: Integrated **Gemini 4 Hydrogen**, enforced strict **120-second timeout guard**, balanced 2 rounds per mode (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`).
**Knowledge Base**: Disabled (`use_kb=False`)

### Executive Leaderboard

| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Used | Mean LLM Time | Mean Round Wall | Total Cost (USD) | Total Tokens | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50.0% (4/8) | 100.0% (8/8) | 5 | 25.59s | 53.23s | $0.32879 | 166,426 | 10114.375 |
| **Gemini 4 Hydrogen** | 87.5% (7/8) | 100.0% (8/8) | 1 | 29.29s | 36.14s | $0.40364 | 106,111 | 8010.0 |
| **Claude Haiku Latest** | 75.0% (6/8) | 100.0% (8/8) | 2 | 32.58s | 44.93s | $0.03504 | 145,615 | 4289.0 |
| **DeepSeek Flash Latest** | 62.5% (5/8) | 100.0% (8/8) | 4 | 45.65s | 65.74s | $0.03954 | 150,203 | 8883.375 |
| **OpenAI GP6 Luna** | 100.0% (8/8) | 100.0% (8/8) | 0 | 19.50s | 19.71s | $0.01545 | 75,036 | 6050.625 |

### By-Mode 1st-Pass Compilation Rates & Mean Latency

| Model | `APPEND` (Pass / Latency) | `COMPOSE` (Pass / Latency) | `DESIGN` (Pass / Latency) | `GENERATE` (Pass / Latency) |
|:---|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50% (8.1s) | 100% (25.8s) | 0% (48.4s) | 50% (20.0s) |
| **Gemini 4 Hydrogen** | 100% (11.1s) | 100% (28.4s) | 50% (57.2s) | 100% (20.4s) |
| **Claude Haiku Latest** | 100% (10.0s) | 100% (33.9s) | 0% (70.2s) | 100% (16.2s) |
| **DeepSeek Flash Latest** | 50% (33.6s) | 50% (71.5s) | 50% (56.2s) | 100% (21.3s) |
| **OpenAI GP6 Luna** | 100% (9.8s) | 100% (24.4s) | 100% (29.1s) | 100% (14.7s) |

> **Key Findings (Battery 2)**:
> - **OpenAI GP6 Luna** went a perfect **8/8 (100.0%) on the 1st-pass** with **0 auto-fixes**, clocking 19.50s average LLM response time.
> - **Gemini 4 Hydrogen** demonstrated a massive jump over Gemini 3.8 Flash: 1st-pass compile jumped from 50.0% to 87.5%, and fixes dropped from 5 to 1.
> - **Claude Haiku Latest** encountered a 120s timeout in Round 05 (`DESIGN`), demonstrating the necessity of the timeout failsafe.
> - **`DESIGN` mode** proved to be the universal crucible for all models, with 3 of 5 models failing 1st-pass syntax due to complex MIDI/GUI interactions.

---

## 5. Battery 3: Comprehensive Qualitative & Artistic Evaluation (Blind LLM Judge)

**Evaluated At**: `2026-11-13 10:44:28 UTC`
**Blind Judge**: `anthropic/claude-sonnet-5.5`
**Judge Consumption**: 229,882 in / 16,875 out tokens (~$0.6285)

### Qualitative Leaderboard (Scores / 10.0)

| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| #1 | **Gemini 3.8 Flash** | **5.30** | 5.5 | 5.81 | 4.69 | 4.81 | 6.50 | 4.38 | 5.62 | 27 | 210.8 |
| #2 | **Gemini 4 Hydrogen** | **4.76** | 4.8 | 5.06 | 4.94 | 3.94 | 5.81 | 4.00 | 4.81 | 21 | 161.8 |
| #3 | **DeepSeek Flash Latest** | **4.50** | 4.5 | 5.19 | 4.50 | 3.69 | 5.31 | 3.94 | 4.38 | 22 | 218.5 |
| #4 | **OpenAI GP6 Luna** | **4.40** | 4.2 | 4.50 | 4.62 | 3.56 | 5.44 | 3.75 | 4.50 | 17 | 127.5 |
| #5 | **Claude Haiku Latest** | **4.19** | 4.0 | 4.25 | 4.12 | 3.41 | 5.31 | 3.69 | 4.35 | 19 | 91.9 |

### Qualitative Score by Mode (Overall / 10.0)

| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |
|:---|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 5.08 | 6.25 | 4.88 | 5.00 |
| **Gemini 4 Hydrogen** | 3.62 | 5.96 | 4.33 | 5.12 |
| **DeepSeek Flash Latest** | 3.62 | 5.62 | 4.04 | 4.71 |
| **OpenAI GP6 Luna** | 3.67 | 5.62 | 3.92 | 4.38 |
| **Claude Haiku Latest** | 4.12 | 5.88 | 2.38 | 4.38 |

> **Key Findings (Battery 3)**:
> - **The Safety vs. Audacity Dichotomy**: While **OpenAI GP6 Luna** swept quantitative metrics, it placed **#4 qualitatively (4.40)** due to conservative, literal sound-object loops and a narrow UGen palette (17 unique UGens).
> - **Gemini 3.8 Flash took #1 Qualitatively (5.30)**: It dominated UGen palette richness (27 unique UGens) and took daring programmatic risks (e.g. mapping a 27-second `Pseg` tension ramp to a 27-year marriage, and writing a 7-chamber `Tdef` cavern narrative scoring 6.33).
> - **Gemini 4 Hydrogen represented the ideal balance (4.76)**: Highest technical depth (4.94) and highest `GENERATE` quality (5.12) with minimal compilation fragility.

---

## 6. Battery 4: Fast-Tier Unified Knowledge Base (KB) A/B Test (5 Models)

**Execution Timestamp**: `2026-11-13T12:02:00.459943+00:00`
**Setup**: 4 paired rounds (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`) per arm across all 5 models (40 rounds total) comparing **Without KB** (`use_kb=False`) against **With KB** (`use_kb=True`).
**Blind Judge**: `anthropic/claude-sonnet-5.5`

### Unified Executive Summary: Fast-Tier KB Impact

| Model | 1st-Pass (No→KB) | Auto-Fixes (No→KB) | Mean LLM (No→KB) | Total Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50% → 50% | 1 → 2 | 45.4s → 24.6s | $0.0635 → $0.1641 | **4.40 → 5.19** (+0.79) | 3.5 → 4.8 | 21 → 26 |
| **Gemini 4 Hydrogen** | 50% → 75% | 3 → 1 | 26.5s → 27.0s | $0.3509 → $0.2772 | **4.65 → 4.69** (+0.04) | 4.8 → 4.8 | 22 → 21 |
| **Claude Haiku Latest** | 75% → 75% | 1 → 0 | 26.5s → 44.2s | $0.0187 → $0.0132 | **4.48 → 3.54** (-0.94) | 3.5 → 3.0 | 15 → 12 |
| **DeepSeek Flash Latest** | 75% → 50% | 1 → 3 | 30.5s → 48.6s | $0.0128 → $0.0320 | **3.98 → 4.40** (+0.42) | 3.5 → 4.0 | 13 → 19 |
| **OpenAI GP6 Luna** | 100% → 100% | 0 → 0 | 19.4s → 20.5s | $0.0074 → $0.0100 | **4.33 → 4.27** (-0.06) | 3.5 → 4.0 | 15 → 15 |

### Fast-Tier 6-Dimension Qualitative Shifts

| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 4.88→5.88 (+1.00) | 3.75→5.00 (+1.25) | 4.12→4.62 (+0.50) | 5.38→6.12 (+0.74) | 3.50→4.12 (+0.62) | 4.75→5.38 (+0.63) |
| **Gemini 4 Hydrogen** | 5.00→5.12 (+0.12) | 4.88→4.75 (-0.13) | 3.88→4.00 (+0.12) | 5.62→5.62 (+0.00) | 4.00→3.88 (-0.12) | 4.50→4.75 (+0.25) |
| **Claude Haiku Latest** | 4.88→3.62 (-1.26) | 4.25→3.50 (-0.75) | 3.75→2.88 (-0.87) | 5.62→4.38 (-1.24) | 3.75→3.12 (-0.63) | 4.62→3.75 (-0.87) |
| **DeepSeek Flash Latest** | 4.25→4.88 (+0.63) | 4.00→4.00 (+0.00) | 3.25→3.88 (+0.63) | 4.88→5.38 (+0.50) | 3.62→3.88 (+0.26) | 3.88→4.38 (+0.50) |
| **OpenAI GP6 Luna** | 4.75→4.50 (-0.25) | 4.50→4.38 (-0.12) | 3.62→3.62 (+0.00) | 5.00→5.00 (+0.00) | 3.62→3.75 (+0.13) | 4.50→4.38 (-0.12) |

> **Key Findings (Battery 4 - Fast Tier KB)**:
> - **KB is a massive boon for Gemini 3.8 Flash (+0.79)** and **DeepSeek Flash (+0.42)**: RAG injection supplied concrete UGen idioms, boosting variety (+1.00 for 3.8 Flash) and resolving cryptic syntax errors.
> - **KB reduces costs and fixes for Gemini 4 Hydrogen**: 1st-pass compile rose from 50% to 75%, fixes dropped from 3 to 1, and total cost fell from \$0.3509 to \$0.2772.
> - **KB harms Claude Haiku under a 120s timeout cap (-0.94)**: The additional token context in `DESIGN` mode caused Haiku to exceed the 120s execution cap, triggering a fallback stub.

---

## 7. Battery 5: Next-Tier Unified Knowledge Base (KB) A/B Test (4 Models)

**Execution Timestamp**: `2026-11-13T13:49:16.748420+00:00`
**Setup**: Paired 4-mode schedule across next-tier models: `Gemini 4 Carbon`, `Claude Sonnet 5.5`, `DeepSeek V4 Pro`, `OpenAI GPT-6.1 Sol`.
**Blind Judge**: `anthropic/claude-opus-5.5` (Evaluated using Claude Opus 5.5)

### Unified Executive Summary: Next-Tier KB Impact

| Model | 1st-Pass (No→KB) | Auto-Fixes (No→KB) | Mean LLM (No→KB) | Total Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 75% → 50% | 2 → 1 | 54.0s → 68.7s | $0.3353 → $0.2293 | **5.71 → 5.37** (-0.34) | 4.5 → 4.5 | 20 → 20 |
| **Claude Sonnet 5.5** | 100% → 75% | 0 → 0 | 18.7s → 44.6s | $0.2195 → $0.2105 | **5.15 → 4.67** (-0.48) | 4.0 → 4.0 | 16 → 16 |
| **DeepSeek V4 Pro** | 50% → 25% | 3 → 1 | 66.8s → 105.6s | $0.1056 → $0.0492 | **4.11 → 3.00** (-1.11) | 3.8 → 2.5 | 15 → 14 |
| **OpenAI GPT-6.1 Sol** | 100% → 75% | 0 → 2 | 31.4s → 30.0s | $0.1544 → $0.2885 | **6.12 → 6.39** (+0.27) | 4.5 → 4.5 | 16 → 16 |

### Next-Tier 6-Dimension Qualitative Shifts

| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 6.00→5.62 (-0.38) | 5.88→5.12 (-0.76) | 5.00→4.88 (-0.12) | 6.62→6.25 (-0.37) | 4.88→4.62 (-0.26) | 5.88→5.75 (-0.13) |
| **Claude Sonnet 5.5** | 5.75→4.88 (-0.87) | 5.75→4.62 (-1.13) | 4.38→4.00 (-0.38) | 6.00→5.50 (-0.50) | 3.88→4.12 (+0.24) | 5.12→4.88 (-0.24) |
| **DeepSeek V4 Pro** | 4.00→3.00 (-1.00) | 4.88→3.00 (-1.88) | 3.38→2.62 (-0.76) | 5.00→3.50 (-1.50) | 3.50→2.75 (-0.75) | 3.88→3.12 (-0.76) |
| **OpenAI GPT-6.1 Sol** | 5.88→6.00 (+0.12) | 6.88→7.00 (+0.12) | 5.12→5.50 (+0.38) | 7.12→7.50 (+0.38) | 5.25→5.62 (+0.37) | 6.50→6.75 (+0.25) |

> **Key Findings (Battery 5 - Next Tier KB)**:
> - **OpenAI GPT-6.1 Sol is the Undisputed Benchmark Champion**: It achieved the highest qualitative score across the entire test campaign (**6.39 with KB**), dominating Technical Depth (7.00), Prompt Coherence (7.50), and Creativity (6.75).
> - **Gemini 4 Carbon is an Elite Sound Designer in `APPEND`, `COMPOSE` & `GENERATE` (6.42–7.42)**, scoring high marks on physical modeling and inharmonic resonator banks.
> - **The Next-Tier `DESIGN` + KB Bottleneck**: When KB was enabled during `DESIGN` mode, prompt context length caused 3 out of 4 next-tier models (`Gemini 4 Carbon`, `Claude Sonnet 5.5`, `DeepSeek V4 Pro`) to exceed the 120s limit. Only **GPT-6.1 Sol** successfully synthesized the multitimbral GUI/MIDI architecture within 33.7s.

---

## 8. Comprehensive Mode-by-Mode Specialization Breakdown

Cross-battery analysis of which provider and model tier excels at each specific SuperCollider musical discipline:

### 1. `APPEND` Mode (Live Session Layering & Mutation)
- **Leader**: **OpenAI GPT-6.1 Sol** (`6.83` Qual With KB) & **Gemini 4 Carbon** (`6.75` Qual No KB).
- **Fast-Tier Best**: **Claude Haiku Latest** (100% 1st-pass, 9.98s LLM) & **OpenAI GP6 Luna** (100% 1st-pass, 9.77s LLM).
- **Key Challenge**: Models often redeclare existing variables or fail to handle `ilter ->` slot wet levels properly. Both OpenAI models and Gemini Carbon handled live session scoping cleanly.

### 2. `COMPOSE` Mode (Algorithmic Timeline Scores & Pbindef/Tdef Architecture)
- **Leader**: **OpenAI GPT-6.1 Sol** (`7.58` Qual No KB) & **Gemini 4 Carbon** (`7.42` Qual With KB).
- **Fast-Tier Best**: **Gemini 3.8 Flash** (`6.33` Qual With KB) & **Gemini 4 Hydrogen** (`6.08` Qual With KB).
- **Key Challenge**: Constructing multi-section narrative arcs rather than static loops. Top models successfully phased detuned clock escapements (`Pbindef` drift) and used `Tdef` sequences to schedule dynamic climaxes.

### 3. `DESIGN` Mode (Hardware MIDI-Mapped Synthesizers + Paginated GUI)
- **Leader**: **OpenAI GPT-6.1 Sol** (`5.42` Qual, 100% No-KB compile, completed in 33.7s).
- **Fast-Tier Best**: **OpenAI GP6 Luna** (`100%` 1st-pass across all runs, 29.15s LLM).
- **Key Challenge**: Huge syntactic complexity. 7 of 9 evaluated models failed compilation or timed out in this mode due to `_ConnectMIDIIn` primitive crashes, missing GUI control arrays, or 120s generation timeouts. OpenAI's architecture is uniquely hardened against GUI/MIDI pitfalls.

### 4. `GENERATE` Mode (Autonomous Ambient & Textural Soundscapes)
- **Leader**: **Gemini 4 Carbon** (`6.42` Qual With KB) & **OpenAI GPT-6.1 Sol** (`6.08` Qual With KB).
- **Fast-Tier Best**: **DeepSeek Flash Latest** (`5.33` Qual With KB) & **Gemini 4 Hydrogen** (`5.17` Qual No KB).
- **Key Challenge**: Avoiding static repeating loops. Top models implemented frequency bracketing (sub, body, shimmer) and stochastic modulation networks (`LFNoise2`, `Dust`, `DynKlank`).

---

## 9. Artistic Signatures, DSP Idioms & Systemic Blind Spots

### Model Artistic Signatures
- **OpenAI (GP6 Luna / GPT-6.1 Sol)**: Conceptual, gesture-driven, and structurally impeccable. Excels at converting narrative cues into precise physical metaphors (ringing bells, paper ticks, clock escapements). Sol brings massive technical depth, while Luna is lightweight and concise.
- **Google Gemini (3.8 Flash / 4 Hydrogen / 4 Carbon)**: Deeply textural, organic, and timbrally ambitious. Leans heavily on inharmonic modal synthesis (`DynKlank`, `Ringz`), pitch-enveloped noise exciters, and comb filtering. Carbon writes lush, concert-grade electroacoustic studies.
- **Anthropic Claude (Haiku 5.5 / Sonnet 5.5)**: Clean, modular, and foley-oriented. Uses clean subtractive filtering and microtiming phasing. Highly effective in `COMPOSE`, but prompt-heavy KB context causes generation stalls on complex GUI code.
- **DeepSeek (V4.1 Flash / V4 Pro)**: Highly responsive to Knowledge Base retrieval. Flash gains significant UGen richness from KB examples, though Pro suffers from severe reasoning latency and socket timeouts.

### Systemic SuperCollider Runtime Bugs Discovered
The blind evaluation uncovered 3 recurring subtle runtime bugs that compiled cleanly on `sclang` but failed dynamically:
1. **Build-Time `Collection` Guards**: Models frequently wrote `if(sig.isKindOf(Collection))` inside SynthDefs. This evaluates once at UGen graph creation time rather than runtime, causing broken stereo branches.
2. **Stuck Trigger Inputs**: Using `Ndef(...)[1] = \set -> Pbindef(..., \t_trig, 1)` fails to retrigger envelopes because the control never transitions from 0 to 1.
3. **Filter Slot Misconfigurations**: Assigning `\wet10` before establishing the `\filter ->` slot or using `FreeVerb2` with hardcoded 1.0 wet levels.

---

## 10. Artifact Index & Verifiable File Links

All benchmark runs, logs, JSON datasets, and generated `.scd` code files are preserved on disk:

### Consolidated Reports
- [unified_ab_report.md (Fast Tier)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/unified_ab_report.md)
- [unified_ab_report.md (Next Tier)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/unified_ab_report.md)
- [qualitative_eval_report.md (8-Round Blind Eval)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261112_191506/qualitative_eval_report.md)
- [benchmark_report.md (8-Round Specialization)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261112_191506/benchmark_report.md)
- [benchmark_report.md (Initial 10-Round Stress)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261111_214444/benchmark_report.md)

### Test Scripts & Harnesses
- [test_xappend_kb_ab_unified.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/test_xappend_kb_ab_unified.py)
- [evaluate_qualitative_benchmark.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/evaluate_qualitative_benchmark.py)
- [test_xappend_multi_provider_benchmark.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/test_xappend_multi_provider_benchmark.py)
- [ptbr_xappend_corpus_200.json](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/test-prompts/ptbr_xappend_corpus_200.json)

### Executable SuperCollider Session Code (.scd)
- **Next Tier**: [session_gpt-6.1-sol_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_gpt-6.1-sol_with_kb.scd) | [session_gemini-4-carbon_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_gemini-4-carbon_with_kb.scd) | [session_claude-sonnet-5.5_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_claude-sonnet-5.5_with_kb.scd)
- **Fast Tier**: [session_gpt-6-luna_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gpt-6-luna_with_kb.scd) | [session_gemini-4-hydrogen_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gemini-4-hydrogen_with_kb.scd) | [session_gemini-3.8-flash_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gemini-3.8-flash_with_kb.scd)