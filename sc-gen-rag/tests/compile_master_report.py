import json
import os
from datetime import datetime, timezone

base_dir = r"C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output"

d_10 = json.load(open(os.path.join(base_dir, "run_20261111_214444", "benchmark_report.json"), encoding="utf-8"))
d_8 = json.load(open(os.path.join(base_dir, "run_20261112_191506", "benchmark_report.json"), encoding="utf-8"))
d_8_qual = json.load(open(os.path.join(base_dir, "run_20261112_191506", "qualitative_eval_report.json"), encoding="utf-8"))
d_fast_ab = json.load(open(os.path.join(base_dir, "kb_ab_20261113_082808", "unified_ab_report.json"), encoding="utf-8"))
d_next_ab = json.load(open(os.path.join(base_dir, "kb_ab_next_20261113_100344", "unified_ab_report.json"), encoding="utf-8"))

lines = []
def p(text=""):
    lines.append(text)

p("# Master Benchmark Compendium: Multi-Provider X-Append SuperCollider Evaluation")
p()
p(f"**Generated**: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
p("**Author/Evaluator**: SuperCollider AI Assist (DeepMind Antigravity)")
p("**Corpus**: 200-fragment Brazilian Portuguese Literary & Technical Corpus (`ptbr_xappend_corpus_200.json`)")
p("**Compiler Environment**: SuperCollider `3.14.1` (via `SclangParallelValidator`) on Windows")
p("**Providers & Gateway**: OpenRouter API (`openrouter.ai/api/v1`)")
p()
p("---")
p()
p("## Executive Table of Contents")
p("1. [Overview & Evaluation Architecture](#1-overview--evaluation-architecture)")
p("2. [Grand Comparison: Fast Tier vs. Next Tier Across All Batteries](#2-grand-comparison-fast-tier-vs-next-tier-across-all-batteries)")
p("3. [Battery 1: Initial 10-Round Multi-Provider Stress Test (4 Models)](#3-battery-1-initial-10-round-multi-provider-stress-test-4-models)")
p("4. [Battery 2: 8-Round Specialization & 120s Timeout Guard (5 Models)](#4-battery-2-8-round-specialization--120s-timeout-guard-5-models)")
p("5. [Battery 3: Comprehensive Qualitative & Artistic Evaluation (Blind LLM Judge)](#5-battery-3-comprehensive-qualitative--artistic-evaluation-blind-llm-judge)")
p("6. [Battery 4: Fast-Tier Unified Knowledge Base (KB) A/B Test (5 Models)](#6-battery-4-fast-tier-unified-knowledge-base-kb-ab-test-5-models)")
p("7. [Battery 5: Next-Tier Unified Knowledge Base (KB) A/B Test (4 Models)](#7-battery-5-next-tier-unified-knowledge-base-kb-ab-test-4-models)")
p("8. [Comprehensive Mode-by-Mode Specialization Breakdown](#8-comprehensive-mode-by-mode-specialization-breakdown)")
p("9. [Artistic Signatures, DSP Idioms & Systemic Blind Spots](#9-artistic-signatures-dsp-idioms--systemic-blind-spots)")
p("10. [Artifact Index & Verifiable File Links](#10-artifact-index--verifiable-file-links)")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 1
# -------------------------------------------------------------
p("## 1. Overview & Evaluation Architecture")
p()
p("This compendium unifies every automated empirical benchmark executed across the SuperCollider AI Assist lean prompt engine, testing both quantitative execution metrics and qualitative artistic/DSP quality across multiple leading LLM families.")
p()
p("### Evaluated Models by Tier")
p()
p("| Provider | Fast / Budget Tier | Next / Flagship Tier |")
p("|:---|:---|:---|")
p("| **Google** | `google/gemini-3.8-flash`<br>`google/gemini-4-hydrogen` | `google/gemini-4-carbon` |")
p("| **Anthropic** | `anthropic/claude-haiku-5.5` | `anthropic/claude-sonnet-5.5` |")
p("| **DeepSeek** | `deepseek/deepseek-v4.1-flash` | `deepseek/deepseek-v4-pro` |")
p("| **OpenAI** | `openai/gpt-6-luna` | `openai/gpt-6.1-sol` |")
p()
p("### Evaluated X-Append Modes")
p("- **`APPEND`**: Incremental live-coding layer addition and parameter evolution onto a running `Ndef`/`Pbindef` session without sound interruption.")
p("- **`COMPOSE`**: Long-form multi-layer algorithmic timeline scores via `Tdef` and `Pbindef`, including macro-structure and cleanup concluding.")
p("- **`DESIGN`**: Hardware MIDI-mapped playable synthesizers with multi-zone keyboard splits, hardware fallback, and paginated GUI control panels.")
p("- **`GENERATE`**: Continuously evolving autonomous multi-layer generative soundscapes with frequency bracketing, stochastic textures, and ambient layers.")
p()
p("### Evaluation Pipeline & Guards")
p("- **120-Second Strict Timeout**: Implemented via concurrent `ThreadPoolExecutor` and OpenAI client timeouts to prevent unhandled API hangs.")
p("- **Automatic Normalization**: Deterministic code normalizer handling `Balance2` collection guards, reserved `pi` identifiers, and third-party UGen sanitization (`DPW4Saw` -> `Saw`).")
p("- **Parallel Compilation Validator**: Real-time `sclang.exe` compilation validation over isolated localhost UDP ports.")
p("- **Blind LLM-as-a-Judge**: Multi-stage evaluation (`anthropic/claude-sonnet-5.5` for fast tier; `anthropic/claude-opus-5.5` for next tier) measuring 6 dimensions (1.0 to 10.0 scale): Variety, Technical Depth, Compositional Audacity, Prompt Coherence, Compositional Arcs, and Creativity.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 2: Grand Comparison
# -------------------------------------------------------------
p("## 2. Grand Comparison: Fast Tier vs. Next Tier Across All Batteries")
p()
p("A high-level synthesis of all evaluated models across their primary benchmark configurations:")
p()
p("| Tier | Model | Best 1st-Pass Rate | Auto-Fix Reliance | Mean LLM Time | Qual Score (No KB) | Qual Score (With KB) | Primary Specialization |")
p("|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|")
p("| **Fast** | **OpenAI GP6 Luna** | **100.0%** | **0 fixes** | **19.40s** | 4.33 | 4.27 | Ultra-reliable, lightning fast, best for fast prototyping |")
p("| **Fast** | **Gemini 4 Hydrogen** | 87.5% | Low (1 fix) | 26.54s | 4.65 | 4.69 | Solid all-rounder; strong in `COMPOSE` & `GENERATE` |")
p("| **Fast** | **Claude Haiku Latest** | 75.0% | Low (1 fix) | 26.52s | 4.48 | 3.54 | Budget `COMPOSE` & `APPEND`; struggles with heavy `DESIGN` |")
p("| **Fast** | **DeepSeek Flash Latest** | 75.0% | Medium (1-3 fixes) | 30.52s | 3.98 | 4.40 | Greatly elevated by KB; strong generative textures |")
p("| **Fast** | **Gemini 3.8 Flash** | 50.0% - 70.0% | High (2-5 fixes) | 24.57s | 4.40 | **5.19** | Peak artistic ambition and UGen variety; higher syntax fragility |")
p("|:---|:---|:---:|:---:|:---:|:---:|:---:|:---|")
p("| **Next** | **OpenAI GPT-6.1 Sol** | **100.0%** | **0 fixes (No-KB)** | **30.04s** | **6.12** | **6.39** | **Overall Champion**: Flawless compilation + #1 in Technical Depth & Composition |")
p("| **Next** | **Gemini 4 Carbon** | 75.0% | Low-Med (1-2 fixes)| 54.02s | 5.71 | 5.37 | Elite electroacoustic composer in `APPEND`, `COMPOSE` & `GENERATE` |")
p("| **Next** | **Claude Sonnet 5.5** | **100.0% (No-KB)** | **0 fixes** | **18.69s** | 5.15 | 4.67 | Fastest Next-Tier model; pristine syntax; excels in `COMPOSE` with KB |")
p("| **Next** | **DeepSeek V4 Pro** | 50.0% | High (1-3 fixes) | 66.80s | 4.11 | 3.00 | Heavy reasoning overhead; prone to 120s timeout in `DESIGN`/`GENERATE` |")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 3: Battery 1
# -------------------------------------------------------------
p("## 3. Battery 1: Initial 10-Round Multi-Provider Stress Test (4 Models)")
p()
p(f"**Execution Timestamp**: `{d_10.get('timestamp')}`")
p(f"**Schedule**: 10 sequential rounds per model across randomized Brazilian Portuguese fragments (Rounds: {d_10.get('rounds_per_model')})")
p("**Knowledge Base**: Disabled (`use_kb=False`)")
p()
p("| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Calls | Mean LLM Time | Total Wall Time | Total In Tokens | Total Out Tokens | Total Cost (USD) |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
for m in d_10["models"]:
    p(f"| **{m['model_name']}** | {m['initial_pass_rate']:.1f}% ({m['initial_pass_count']}/{m['total_rounds']}) | {m['final_pass_rate']:.1f}% ({m['final_pass_count']}/{m['total_rounds']}) | {m['total_fix_calls']} | {m['mean_llm_time_s']:.2f}s | {m['model_total_wall_s']:.1f}s | {m['total_in_tokens']:,} | {m['total_out_tokens']:,} | ${m['total_cost_usd']:.5f} |")
p()
p("> **Key Findings (Battery 1)**:")
p("> - **OpenAI GP6 Luna** established immediate technical dominance with a 90% 1st-pass rate, only 2 fixes, and the lowest cost (\$0.02356).")
p("> - **DeepSeek Flash Latest** recovered 100% final compilation across 10 rounds after 2 auto-fix calls.")
p("> - **Gemini 3.8 Flash** generated the longest, most intricate patches, but required 4 auto-fixes to resolve undeclared variables and JITLib slot conflicts.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 4: Battery 2
# -------------------------------------------------------------
p("## 4. Battery 2: 8-Round Specialization & 120s Timeout Guard (5 Models)")
p()
p(f"**Execution Timestamp**: `{d_8.get('timestamp')}`")
p("**Enhancements**: Integrated **Gemini 4 Hydrogen**, enforced strict **120-second timeout guard**, balanced 2 rounds per mode (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`).")
p("**Knowledge Base**: Disabled (`use_kb=False`)")
p()
p("### Executive Leaderboard")
p()
p("| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Used | Mean LLM Time | Mean Round Wall | Total Cost (USD) | Total Tokens | Mean Chars |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
for m in d_8["models"]:
    p(f"| **{m['model_name']}** | {m['initial_pass_rate']:.1f}% ({m['initial_pass_count']}/{m['total_rounds']}) | {m['final_pass_rate']:.1f}% ({m['final_pass_count']}/{m['total_rounds']}) | {m['total_fix_calls']} | {m['mean_llm_time_s']:.2f}s | {m['mean_wall_time_s']:.2f}s | ${m['total_cost_usd']:.5f} | {m['total_tokens']:,} | {m['mean_code_chars']} |")
p()
p("### By-Mode 1st-Pass Compilation Rates & Mean Latency")
p()
p("| Model | `APPEND` (Pass / Latency) | `COMPOSE` (Pass / Latency) | `DESIGN` (Pass / Latency) | `GENERATE` (Pass / Latency) |")
p("|:---|:---:|:---:|:---:|:---:|")
for m in d_8["models"]:
    ms = m["mode_stats"]
    p(f"| **{m['model_name']}** | {ms['append']['init_pass_rate']:.0f}% ({ms['append']['mean_llm_time_s']:.1f}s) | {ms['compose']['init_pass_rate']:.0f}% ({ms['compose']['mean_llm_time_s']:.1f}s) | {ms['design']['init_pass_rate']:.0f}% ({ms['design']['mean_llm_time_s']:.1f}s) | {ms['generate']['init_pass_rate']:.0f}% ({ms['generate']['mean_llm_time_s']:.1f}s) |")
p()
p("> **Key Findings (Battery 2)**:")
p("> - **OpenAI GP6 Luna** went a perfect **8/8 (100.0%) on the 1st-pass** with **0 auto-fixes**, clocking 19.50s average LLM response time.")
p("> - **Gemini 4 Hydrogen** demonstrated a massive jump over Gemini 3.8 Flash: 1st-pass compile jumped from 50.0% to 87.5%, and fixes dropped from 5 to 1.")
p("> - **Claude Haiku Latest** encountered a 120s timeout in Round 05 (`DESIGN`), demonstrating the necessity of the timeout failsafe.")
p("> - **`DESIGN` mode** proved to be the universal crucible for all models, with 3 of 5 models failing 1st-pass syntax due to complex MIDI/GUI interactions.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 5: Battery 3
# -------------------------------------------------------------
p("## 5. Battery 3: Comprehensive Qualitative & Artistic Evaluation (Blind LLM Judge)")
p()
p(f"**Evaluated At**: `{d_8_qual.get('evaluated_at_utc')}`")
p(f"**Blind Judge**: `{d_8_qual.get('judge_model')}`")
p(f"**Judge Consumption**: {d_8_qual['judge_tokens']['in']:,} in / {d_8_qual['judge_tokens']['out']:,} out tokens (~${d_8_qual['judge_tokens']['est_cost_usd']:.4f})")
p()
p("### Qualitative Leaderboard (Scores / 10.0)")
p()
p("| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |")
p("|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
for idx, m in enumerate(d_8_qual["models"], 1):
    s = m["mean_scores_all_rounds"]
    ov_str = f"**{m['overall_mean_all']:.2f}**"
    if m['overall_mean_completed'] != m['overall_mean_all']:
        ov_str += f" ({m['overall_mean_completed']:.2f})"
    p(f"| #{idx} | **{m['model_name']}** | {ov_str} | {m['portfolio_variety_score']:.1f} | {s['variety']:.2f} | {s['technical_depth']:.2f} | {s['compositional_audacity']:.2f} | {s['coherence_with_prompt']:.2f} | {s['compositional_arcs']:.2f} | {s['creativity']:.2f} | {m['unique_ugens_total']} | {m['mean_loc']:.1f} |")
p()
p("### Qualitative Score by Mode (Overall / 10.0)")
p()
p("| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |")
p("|:---|:---:|:---:|:---:|:---:|")
for m in d_8_qual["models"]:
    bm = m["by_mode"]
    p(f"| **{m['model_name']}** | {bm.get('append',{}).get('overall',0):.2f} | {bm.get('compose',{}).get('overall',0):.2f} | {bm.get('design',{}).get('overall',0):.2f} | {bm.get('generate',{}).get('overall',0):.2f} |")
p()
p("> **Key Findings (Battery 3)**:")
p("> - **The Safety vs. Audacity Dichotomy**: While **OpenAI GP6 Luna** swept quantitative metrics, it placed **#4 qualitatively (4.40)** due to conservative, literal sound-object loops and a narrow UGen palette (17 unique UGens).")
p("> - **Gemini 3.8 Flash took #1 Qualitatively (5.30)**: It dominated UGen palette richness (27 unique UGens) and took daring programmatic risks (e.g. mapping a 27-second `Pseg` tension ramp to a 27-year marriage, and writing a 7-chamber `Tdef` cavern narrative scoring 6.33).")
p("> - **Gemini 4 Hydrogen represented the ideal balance (4.76)**: Highest technical depth (4.94) and highest `GENERATE` quality (5.12) with minimal compilation fragility.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 6: Battery 4
# -------------------------------------------------------------
p("## 6. Battery 4: Fast-Tier Unified Knowledge Base (KB) A/B Test (5 Models)")
p()
p(f"**Execution Timestamp**: `{d_fast_ab.get('generated_at_utc')}`")
p("**Setup**: 4 paired rounds (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`) per arm across all 5 models (40 rounds total) comparing **Without KB** (`use_kb=False`) against **With KB** (`use_kb=True`).")
p(f"**Blind Judge**: `{d_fast_ab['qual_no_kb']['judge_model']}`")
p()
p("### Unified Executive Summary: Fast-Tier KB Impact")
p()
p("| Model | 1st-Pass (No→KB) | Auto-Fixes (No→KB) | Mean LLM (No→KB) | Total Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
qn_fast = {m["model_name"]: m for m in d_fast_ab["quant_no_kb"]["models"]}
qw_fast = {m["model_name"]: m for m in d_fast_ab["quant_with_kb"]["models"]}
ln_fast = {m["model_name"]: m for m in d_fast_ab["qual_no_kb"]["models"]}
lw_fast = {m["model_name"]: m for m in d_fast_ab["qual_with_kb"]["models"]}

for name in [m["model_name"] for m in d_fast_ab["quant_no_kb"]["models"]]:
    qn, qw = qn_fast[name], qw_fast[name]
    ln, lw = ln_fast[name], lw_fast[name]
    d_q = lw["overall_mean_all"] - ln["overall_mean_all"]
    p(f"| **{name}** | {qn['initial_pass_rate']:.0f}% → {qw['initial_pass_rate']:.0f}% | {qn['total_fix_calls']} → {qw['total_fix_calls']} | {qn['mean_llm_time_s']:.1f}s → {qw['mean_llm_time_s']:.1f}s | ${qn['total_cost_usd']:.4f} → ${qw['total_cost_usd']:.4f} | **{ln['overall_mean_all']:.2f} → {lw['overall_mean_all']:.2f}** ({d_q:+.2f}) | {ln['portfolio_variety_score']:.1f} → {lw['portfolio_variety_score']:.1f} | {ln['unique_ugens_total']} → {lw['unique_ugens_total']} |")
p()
p("### Fast-Tier 6-Dimension Qualitative Shifts")
p()
p("| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|")
for name in [m["model_name"] for m in d_fast_ab["quant_no_kb"]["models"]]:
    ln, lw = ln_fast[name], lw_fast[name]
    sn, sw = ln["mean_scores_all_rounds"], lw["mean_scores_all_rounds"]
    cells = [f"{sn[d]:.2f}→{sw[d]:.2f} ({(sw[d]-sn[d]):+.2f})" for d in ["variety", "technical_depth", "compositional_audacity", "coherence_with_prompt", "compositional_arcs", "creativity"]]
    p(f"| **{name}** | " + " | ".join(cells) + " |")
p()
p("> **Key Findings (Battery 4 - Fast Tier KB)**:")
p("> - **KB is a massive boon for Gemini 3.8 Flash (+0.79)** and **DeepSeek Flash (+0.42)**: RAG injection supplied concrete UGen idioms, boosting variety (+1.00 for 3.8 Flash) and resolving cryptic syntax errors.")
p("> - **KB reduces costs and fixes for Gemini 4 Hydrogen**: 1st-pass compile rose from 50% to 75%, fixes dropped from 3 to 1, and total cost fell from \$0.3509 to \$0.2772.")
p("> - **KB harms Claude Haiku under a 120s timeout cap (-0.94)**: The additional token context in `DESIGN` mode caused Haiku to exceed the 120s execution cap, triggering a fallback stub.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 7: Battery 5
# -------------------------------------------------------------
p("## 7. Battery 5: Next-Tier Unified Knowledge Base (KB) A/B Test (4 Models)")
p()
p(f"**Execution Timestamp**: `{d_next_ab.get('generated_at_utc')}`")
p("**Setup**: Paired 4-mode schedule across next-tier models: `Gemini 4 Carbon`, `Claude Sonnet 5.5`, `DeepSeek V4 Pro`, `OpenAI GPT-6.1 Sol`.")
p(f"**Blind Judge**: `{d_next_ab['qual_no_kb']['judge_model']}` (Evaluated using Claude Opus 5.5)")
p()
p("### Unified Executive Summary: Next-Tier KB Impact")
p()
p("| Model | 1st-Pass (No→KB) | Auto-Fixes (No→KB) | Mean LLM (No→KB) | Total Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
qn_next = {m["model_name"]: m for m in d_next_ab["quant_no_kb"]["models"]}
qw_next = {m["model_name"]: m for m in d_next_ab["quant_with_kb"]["models"]}
ln_next = {m["model_name"]: m for m in d_next_ab["qual_no_kb"]["models"]}
lw_next = {m["model_name"]: m for m in d_next_ab["qual_with_kb"]["models"]}

for name in [m["model_name"] for m in d_next_ab["quant_no_kb"]["models"]]:
    qn, qw = qn_next[name], qw_next[name]
    ln, lw = ln_next[name], lw_next[name]
    d_q = lw["overall_mean_all"] - ln["overall_mean_all"]
    p(f"| **{name}** | {qn['initial_pass_rate']:.0f}% → {qw['initial_pass_rate']:.0f}% | {qn['total_fix_calls']} → {qw['total_fix_calls']} | {qn['mean_llm_time_s']:.1f}s → {qw['mean_llm_time_s']:.1f}s | ${qn['total_cost_usd']:.4f} → ${qw['total_cost_usd']:.4f} | **{ln['overall_mean_all']:.2f} → {lw['overall_mean_all']:.2f}** ({d_q:+.2f}) | {ln['portfolio_variety_score']:.1f} → {lw['portfolio_variety_score']:.1f} | {ln['unique_ugens_total']} → {lw['unique_ugens_total']} |")
p()
p("### Next-Tier 6-Dimension Qualitative Shifts")
p()
p("| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity |")
p("|:---|:---:|:---:|:---:|:---:|:---:|:---:|")
for name in [m["model_name"] for m in d_next_ab["quant_no_kb"]["models"]]:
    ln, lw = ln_next[name], lw_next[name]
    sn, sw = ln["mean_scores_all_rounds"], lw["mean_scores_all_rounds"]
    cells = [f"{sn[d]:.2f}→{sw[d]:.2f} ({(sw[d]-sn[d]):+.2f})" for d in ["variety", "technical_depth", "compositional_audacity", "coherence_with_prompt", "compositional_arcs", "creativity"]]
    p(f"| **{name}** | " + " | ".join(cells) + " |")
p()
p("> **Key Findings (Battery 5 - Next Tier KB)**:")
p("> - **OpenAI GPT-6.1 Sol is the Undisputed Benchmark Champion**: It achieved the highest qualitative score across the entire test campaign (**6.39 with KB**), dominating Technical Depth (7.00), Prompt Coherence (7.50), and Creativity (6.75).")
p("> - **Gemini 4 Carbon is an Elite Sound Designer in `APPEND`, `COMPOSE` & `GENERATE` (6.42–7.42)**, scoring high marks on physical modeling and inharmonic resonator banks.")
p("> - **The Next-Tier `DESIGN` + KB Bottleneck**: When KB was enabled during `DESIGN` mode, prompt context length caused 3 out of 4 next-tier models (`Gemini 4 Carbon`, `Claude Sonnet 5.5`, `DeepSeek V4 Pro`) to exceed the 120s limit. Only **GPT-6.1 Sol** successfully synthesized the multitimbral GUI/MIDI architecture within 33.7s.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 8: Mode-by-Mode Specialization Breakdown
# -------------------------------------------------------------
p("## 8. Comprehensive Mode-by-Mode Specialization Breakdown")
p()
p("Cross-battery analysis of which provider and model tier excels at each specific SuperCollider musical discipline:")
p()
p("### 1. `APPEND` Mode (Live Session Layering & Mutation)")
p("- **Leader**: **OpenAI GPT-6.1 Sol** (`6.83` Qual With KB) & **Gemini 4 Carbon** (`6.75` Qual No KB).")
p("- **Fast-Tier Best**: **Claude Haiku Latest** (100% 1st-pass, 9.98s LLM) & **OpenAI GP6 Luna** (100% 1st-pass, 9.77s LLM).")
p("- **Key Challenge**: Models often redeclare existing variables or fail to handle `\filter ->` slot wet levels properly. Both OpenAI models and Gemini Carbon handled live session scoping cleanly.")
p()
p("### 2. `COMPOSE` Mode (Algorithmic Timeline Scores & Pbindef/Tdef Architecture)")
p("- **Leader**: **OpenAI GPT-6.1 Sol** (`7.58` Qual No KB) & **Gemini 4 Carbon** (`7.42` Qual With KB).")
p("- **Fast-Tier Best**: **Gemini 3.8 Flash** (`6.33` Qual With KB) & **Gemini 4 Hydrogen** (`6.08` Qual With KB).")
p("- **Key Challenge**: Constructing multi-section narrative arcs rather than static loops. Top models successfully phased detuned clock escapements (`Pbindef` drift) and used `Tdef` sequences to schedule dynamic climaxes.")
p()
p("### 3. `DESIGN` Mode (Hardware MIDI-Mapped Synthesizers + Paginated GUI)")
p("- **Leader**: **OpenAI GPT-6.1 Sol** (`5.42` Qual, 100% No-KB compile, completed in 33.7s).")
p("- **Fast-Tier Best**: **OpenAI GP6 Luna** (`100%` 1st-pass across all runs, 29.15s LLM).")
p("- **Key Challenge**: Huge syntactic complexity. 7 of 9 evaluated models failed compilation or timed out in this mode due to `_ConnectMIDIIn` primitive crashes, missing GUI control arrays, or 120s generation timeouts. OpenAI's architecture is uniquely hardened against GUI/MIDI pitfalls.")
p()
p("### 4. `GENERATE` Mode (Autonomous Ambient & Textural Soundscapes)")
p("- **Leader**: **Gemini 4 Carbon** (`6.42` Qual With KB) & **OpenAI GPT-6.1 Sol** (`6.08` Qual With KB).")
p("- **Fast-Tier Best**: **DeepSeek Flash Latest** (`5.33` Qual With KB) & **Gemini 4 Hydrogen** (`5.17` Qual No KB).")
p("- **Key Challenge**: Avoiding static repeating loops. Top models implemented frequency bracketing (sub, body, shimmer) and stochastic modulation networks (`LFNoise2`, `Dust`, `DynKlank`).")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 9: Signatures & Blind Spots
# -------------------------------------------------------------
p("## 9. Artistic Signatures, DSP Idioms & Systemic Blind Spots")
p()
p("### Model Artistic Signatures")
p("- **OpenAI (GP6 Luna / GPT-6.1 Sol)**: Conceptual, gesture-driven, and structurally impeccable. Excels at converting narrative cues into precise physical metaphors (ringing bells, paper ticks, clock escapements). Sol brings massive technical depth, while Luna is lightweight and concise.")
p("- **Google Gemini (3.8 Flash / 4 Hydrogen / 4 Carbon)**: Deeply textural, organic, and timbrally ambitious. Leans heavily on inharmonic modal synthesis (`DynKlank`, `Ringz`), pitch-enveloped noise exciters, and comb filtering. Carbon writes lush, concert-grade electroacoustic studies.")
p("- **Anthropic Claude (Haiku 5.5 / Sonnet 5.5)**: Clean, modular, and foley-oriented. Uses clean subtractive filtering and microtiming phasing. Highly effective in `COMPOSE`, but prompt-heavy KB context causes generation stalls on complex GUI code.")
p("- **DeepSeek (V4.1 Flash / V4 Pro)**: Highly responsive to Knowledge Base retrieval. Flash gains significant UGen richness from KB examples, though Pro suffers from severe reasoning latency and socket timeouts.")
p()
p("### Systemic SuperCollider Runtime Bugs Discovered")
p("The blind evaluation uncovered 3 recurring subtle runtime bugs that compiled cleanly on `sclang` but failed dynamically:")
p("1. **Build-Time `Collection` Guards**: Models frequently wrote `if(sig.isKindOf(Collection))` inside SynthDefs. This evaluates once at UGen graph creation time rather than runtime, causing broken stereo branches.")
p("2. **Stuck Trigger Inputs**: Using `Ndef(...)[1] = \\set -> Pbindef(..., \\t_trig, 1)` fails to retrigger envelopes because the control never transitions from 0 to 1.")
p("3. **Filter Slot Misconfigurations**: Assigning `\\wet10` before establishing the `\\filter ->` slot or using `FreeVerb2` with hardcoded 1.0 wet levels.")
p()
p("---")
p()

# -------------------------------------------------------------
# Section 10: Artifact Index
# -------------------------------------------------------------
p("## 10. Artifact Index & Verifiable File Links")
p()
p("All benchmark runs, logs, JSON datasets, and generated `.scd` code files are preserved on disk:")
p()
p("### Consolidated Reports")
p("- [unified_ab_report.md (Fast Tier)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/unified_ab_report.md)")
p("- [unified_ab_report.md (Next Tier)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/unified_ab_report.md)")
p("- [qualitative_eval_report.md (8-Round Blind Eval)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261112_191506/qualitative_eval_report.md)")
p("- [benchmark_report.md (8-Round Specialization)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261112_191506/benchmark_report.md)")
p("- [benchmark_report.md (Initial 10-Round Stress)](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/run_20261111_214444/benchmark_report.md)")
p()
p("### Test Scripts & Harnesses")
p("- [test_xappend_kb_ab_unified.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/test_xappend_kb_ab_unified.py)")
p("- [evaluate_qualitative_benchmark.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/evaluate_qualitative_benchmark.py)")
p("- [test_xappend_multi_provider_benchmark.py](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/test_xappend_multi_provider_benchmark.py)")
p("- [ptbr_xappend_corpus_200.json](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/test-prompts/ptbr_xappend_corpus_200.json)")
p()
p("### Executable SuperCollider Session Code (.scd)")
p("- **Next Tier**: [session_gpt-6.1-sol_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_gpt-6.1-sol_with_kb.scd) | [session_gemini-4-carbon_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_gemini-4-carbon_with_kb.scd) | [session_claude-sonnet-5.5_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_next_20261113_100344/session_claude-sonnet-5.5_with_kb.scd)")
p("- **Fast Tier**: [session_gpt-6-luna_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gpt-6-luna_with_kb.scd) | [session_gemini-4-hydrogen_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gemini-4-hydrogen_with_kb.scd) | [session_gemini-3.8-flash_with_kb.scd](file:///C:/Users/Bruno%20Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/tests/multi_provider_benchmark_output/kb_ab_20261113_082808/session_gemini-3.8-flash_with_kb.scd)")

out_path = r"C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\MASTER_BENCHMARK_REPORT.md"
with open(out_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("Successfully written MASTER_BENCHMARK_REPORT.md!")
print(f"File size: {os.path.getsize(out_path):,} bytes")
