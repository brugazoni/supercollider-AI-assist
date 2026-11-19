#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unified Quantitative + Qualitative KB A/B Benchmark Battery.

Runs a paired 4-mode schedule (1 APPEND, 1 COMPOSE, 1 DESIGN, 1 GENERATE)
across all 5 OpenRouter models TWICE:
  - Arm A: Without Knowledge Base (`use_kb=False`)
  - Arm B: With Knowledge Base (`use_kb=True`)

Then executes the 2-stage blind LLM-as-a-Judge qualitative evaluation
(variety, technical_depth, compositional_audacity, coherence_with_prompt,
compositional_arcs, creativity + portfolio variety + UGen telemetry)
on BOTH arms, and synthesizes a unified Quantitative + Qualitative KB
impact report (`unified_ab_report.md` and `unified_ab_report.json`).
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
import sys
from typing import Any

TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
SC_GEN_RAG_DIR = os.path.abspath(os.path.join(TESTS_DIR, ".."))
if SC_GEN_RAG_DIR not in sys.path:
    sys.path.insert(0, SC_GEN_RAG_DIR)
if TESTS_DIR not in sys.path:
    sys.path.insert(0, TESTS_DIR)

from test_xappend_lean_stress import SclangParallelValidator, load_ptbr_corpus
from test_xappend_multi_provider_benchmark import (
    BENCHMARK_MODELS,
    DEFAULT_CORPUS,
    build_specialization_benchmark_schedule,
    format_comparative_markdown,
    run_benchmark_for_model,
)
from evaluate_qualitative_benchmark import (
    DIMENSIONS,
    DIM_LABELS,
    evaluate_report,
    write_markdown_report,
)


NEXT_TIER_MODELS = [
    {
        "id": "openrouter:google/gemini-4-carbon",
        "name": "Gemini 4 Carbon",
        "slug": "gemini-4-carbon",
        "openrouter_model": "google/gemini-4-carbon",
    },
    {
        "id": "openrouter:anthropic/claude-sonnet-5.5",
        "name": "Claude Sonnet 5.5",
        "slug": "claude-sonnet-5.5",
        "openrouter_model": "anthropic/claude-sonnet-5.5",
    },
    {
        "id": "openrouter:deepseek/deepseek-v4-pro",
        "name": "DeepSeek V4 Pro",
        "slug": "deepseek-v4-pro",
        "openrouter_model": "deepseek/deepseek-v4-pro",
    },
    {
        "id": "openrouter:openai/gpt-6.1-sol",
        "name": "OpenAI GPT-6.1 Sol",
        "slug": "gpt-6.1-sol",
        "openrouter_model": "openai/gpt-6.1-sol",
    },
]


def _index_by_name(items: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {item["model_name"]: item for item in items}


def _fmt_delta(val: float, fmt: str = "+.2f", unit: str = "") -> str:
    return f"{val:{fmt}}{unit}"


def build_unified_ab_markdown(
    quant_no_kb: dict[str, Any],
    quant_with_kb: dict[str, Any],
    qual_no_kb: dict[str, Any],
    qual_with_kb: dict[str, Any],
    schedule: list[dict[str, Any]],
    models_list: list[dict[str, str]] | None = None,
) -> str:
    models_list = models_list or BENCHMARK_MODELS
    qn_map = _index_by_name(quant_no_kb["models"])
    qw_map = _index_by_name(quant_with_kb["models"])
    ln_map = _index_by_name(qual_no_kb["models"])
    lw_map = _index_by_name(qual_with_kb["models"])

    lines: list[str] = []
    lines.append("# Unified Quantitative & Qualitative KB A/B Benchmark Report")
    lines.append(f"**Generated**: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")
    lines.append(f"**Schedule**: {len(schedule)} rounds per arm (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`) × 2 arms (`No KB` vs `With KB`) × {len(models_list)} models = {len(schedule) * 2 * len(models_list)} rounds")
    lines.append(f"**Blind Qualitative Judge**: `{qual_no_kb['judge_model']}`")
    lines.append("")

    # Section 1: Unified Executive Summary (Quant + Qual side by side)
    lines.append("## 1. Unified Executive Leaderboard: Without KB vs. With KB")
    lines.append("")
    lines.append("| Model | 1st-Pass (No→KB) | Fixes (No→KB) | Mean LLM (No→KB) | Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |")
    lines.append("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")

    ordered_names = [m["name"] for m in models_list]
    for name in ordered_names:
        qn, qw = qn_map[name], qw_map[name]
        ln, lw = ln_map[name], lw_map[name]
        d_qual = lw["overall_mean_all"] - ln["overall_mean_all"]
        lines.append(
            f"| **{name}** | "
            f"{qn['initial_pass_rate']:.0f}% → {qw['initial_pass_rate']:.0f}% | "
            f"{qn['total_fix_calls']} → {qw['total_fix_calls']} | "
            f"{qn['mean_llm_time_s']:.1f}s → {qw['mean_llm_time_s']:.1f}s | "
            f"${qn['total_cost_usd']:.4f} → ${qw['total_cost_usd']:.4f} | "
            f"**{ln['overall_mean_all']:.2f} → {lw['overall_mean_all']:.2f}** ({_fmt_delta(d_qual)}) | "
            f"{ln['portfolio_variety_score']:.1f} → {lw['portfolio_variety_score']:.1f} | "
            f"{ln['unique_ugens_total']} → {lw['unique_ugens_total']} |"
        )
    lines.append("")

    # Section 2: Detailed 6-Dimension Qualitative Impact
    lines.append("## 2. Qualitative Dimensions Breakdown (No KB → With KB / Δ)")
    lines.append("")
    header = "| Model | " + " | ".join(DIM_LABELS[d] for d in DIMENSIONS) + " | Mean LOC |"
    sep = "|:---|" + ":---:|" * (len(DIMENSIONS) + 1)
    lines.append(header)
    lines.append(sep)
    for name in ordered_names:
        ln, lw = ln_map[name], lw_map[name]
        sn, sw = ln["mean_scores_all_rounds"], lw["mean_scores_all_rounds"]
        cells = []
        for d in DIMENSIONS:
            delta = sw[d] - sn[d]
            cells.append(f"{sn[d]:.2f}→{sw[d]:.2f} ({_fmt_delta(delta)})")
        lines.append(f"| **{name}** | " + " | ".join(cells) + f" | {ln['mean_loc']:.0f}→{lw['mean_loc']:.0f} |")
    lines.append("")

    # Section 3: Detailed Quantitative Telemetry Impact
    lines.append("## 3. Quantitative Efficiency & Token Impact (No KB → With KB)")
    lines.append("")
    lines.append("| Model | Arm | 1st-Pass | Final Pass | Fix Calls | Mean LLM | Total Wall | In Tokens | Out Tokens | Total Cost |")
    lines.append("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
    for name in ordered_names:
        for arm_label, q in [("No KB", qn_map[name]), ("With KB", qw_map[name])]:
            lines.append(
                f"| **{name}** | {arm_label} | "
                f"{q['initial_pass_rate']:.1f}% ({q['initial_pass_count']}/{q['total_rounds']}) | "
                f"{q['final_pass_rate']:.1f}% ({q['final_pass_count']}/{q['total_rounds']}) | "
                f"{q['total_fix_calls']} | {q['mean_llm_time_s']:.2f}s | {q['model_total_wall_s']:.1f}s | "
                f"{q['total_in_tokens']:,} | {q['total_out_tokens']:,} | ${q['total_cost_usd']:.5f} |"
            )
    lines.append("")

    # Section 4: By-Mode Comparison
    lines.append("## 4. By-Mode Impact (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`)")
    lines.append("")
    for mode_name in ["append", "compose", "design", "generate"]:
        lines.append(f"### Mode: `{mode_name.upper()}`")
        lines.append("| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |")
        lines.append("|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
        for name in ordered_names:
            qn_m = qn_map[name]["mode_stats"].get(mode_name, {})
            qw_m = qw_map[name]["mode_stats"].get(mode_name, {})
            ln_m = ln_map[name]["by_mode"].get(mode_name, {})
            lw_m = lw_map[name]["by_mode"].get(mode_name, {})
            d_o = lw_m.get("overall", 0) - ln_m.get("overall", 0)
            lines.append(
                f"| **{name}** | "
                f"{qn_m.get('init_pass_rate',0):.0f}%→{qw_m.get('init_pass_rate',0):.0f}% | "
                f"{qn_m.get('mean_llm_time_s',0):.1f}s→{qw_m.get('mean_llm_time_s',0):.1f}s | "
                f"**{ln_m.get('overall',0):.2f}→{lw_m.get('overall',0):.2f}** ({_fmt_delta(d_o)}) | "
                f"{ln_m.get('variety',0):.1f}→{lw_m.get('variety',0):.1f} | "
                f"{ln_m.get('technical_depth',0):.1f}→{lw_m.get('technical_depth',0):.1f} | "
                f"{ln_m.get('compositional_audacity',0):.1f}→{lw_m.get('compositional_audacity',0):.1f} | "
                f"{ln_m.get('coherence_with_prompt',0):.1f}→{lw_m.get('coherence_with_prompt',0):.1f} | "
                f"{ln_m.get('compositional_arcs',0):.1f}→{lw_m.get('compositional_arcs',0):.1f} | "
                f"{ln_m.get('creativity',0):.1f}→{lw_m.get('creativity',0):.1f} |"
            )
        lines.append("")

    # Section 5: Per-Model Artistic Signatures
    lines.append("## 5. Per-Model Artistic Signatures (No KB vs. With KB)")
    lines.append("")
    for name in ordered_names:
        ln, lw = ln_map[name], lw_map[name]
        lines.append(f"### {name}")
        lines.append(f"- **Without KB**: {ln['artistic_signature']}")
        lines.append(f"- **With KB**: {lw['artistic_signature']}")
        lines.append("")

    return "\n".join(lines)


def run_unified_kb_ab(
    rounds_per_arm: int = 4,
    max_fix_attempts: int = 2,
    judge_model: str = "",
    outdir: str = "",
    tier: str = "fast",
) -> dict[str, Any]:
    models_list = NEXT_TIER_MODELS if tier == "next" else BENCHMARK_MODELS
    if not judge_model:
        judge_model = "anthropic/claude-opus-5.5" if tier == "next" else "anthropic/claude-sonnet-5.5"
    if not outdir:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        outdir = os.path.join(TESTS_DIR, "multi_provider_benchmark_output", f"kb_ab_{tier}_{ts}")
    os.makedirs(outdir, exist_ok=True)

    print(f"Loading corpus from: {DEFAULT_CORPUS}...", flush=True)
    corpus_data = load_ptbr_corpus(DEFAULT_CORPUS)
    fragments = corpus_data["fragments"]
    if rounds_per_arm == 4:
        full_8 = build_specialization_benchmark_schedule(fragments, total_rounds=8)
        # Pick 1 round per mode: APPEND (#1), COMPOSE (#3), DESIGN (#5), GENERATE (#7)
        schedule = []
        seen_modes = set()
        for item in full_8:
            if item["mode"] not in seen_modes:
                seen_modes.add(item["mode"])
                new_item = dict(item)
                new_item["round_index"] = len(schedule) + 1
                new_item["mode_occurrence"] = 1
                new_item["requires_design_cleanup"] = False
                schedule.append(new_item)
    else:
        schedule = build_specialization_benchmark_schedule(fragments, total_rounds=rounds_per_arm)

    print(f"\nConstructed paired A/B schedule ({len(schedule)} rounds per arm):")
    for s in schedule:
        print(f"  Round {s['round_index']:02d}: {s['mode'].upper():<8} [id={s['fragment_id']:03d}, {s['fragment_category']:<16}] {s['fragment_source']}")

    validator = SclangParallelValidator()
    if not validator.start():
        print("WARNING: SclangParallelValidator failed to boot. Structural checks will be used as fallback.")

    arm_outputs: dict[str, dict[str, Any]] = {}

    try:
        for arm_key, use_kb_flag, suffix in [
            ("no_kb", False, "_no_kb"),
            ("with_kb", True, "_with_kb"),
        ]:
            print(f"\n{'#'*78}\nRUNNING ARM: {arm_key.upper()} (use_kb={use_kb_flag})\n{'#'*78}", flush=True)
            summaries = []
            for m_info in models_list:
                m_sum = run_benchmark_for_model(
                    model_info=m_info,
                    schedule=schedule,
                    validator=validator,
                    max_fix_attempts=max_fix_attempts,
                    outdir=outdir,
                    verbose=True,
                    use_kb=use_kb_flag,
                    session_suffix=suffix,
                )
                summaries.append(m_sum)

            md_text = format_comparative_markdown(summaries, schedule)
            md_path = os.path.join(outdir, f"benchmark_{arm_key}.md")
            with open(md_path, "w", encoding="utf-8") as f:
                f.write(md_text)

            json_payload = {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "arm": arm_key,
                "use_kb": use_kb_flag,
                "rounds_per_model": rounds_per_arm,
                "max_fix_attempts": max_fix_attempts,
                "models": summaries,
                "schedule": schedule,
            }
            json_path = os.path.join(outdir, f"benchmark_{arm_key}.json")
            with open(json_path, "w", encoding="utf-8") as f:
                json.dump(json_payload, f, ensure_ascii=False, indent=2)

            arm_outputs[arm_key] = {"json_path": json_path, "md_path": md_path, "data": json_payload}
    finally:
        validator.stop()

    # Qualitative blind evaluation on both arms
    print(f"\n{'#'*78}\nRUNNING BLIND QUALITATIVE EVALUATION ON BOTH ARMS\n{'#'*78}", flush=True)
    qual_no_kb = evaluate_report(arm_outputs["no_kb"]["json_path"], judge_model)
    with open(os.path.join(outdir, "qualitative_no_kb.json"), "w", encoding="utf-8") as f:
        json.dump(qual_no_kb, f, ensure_ascii=False, indent=2)
    write_markdown_report(qual_no_kb, os.path.join(outdir, "qualitative_no_kb.md"))

    qual_with_kb = evaluate_report(arm_outputs["with_kb"]["json_path"], judge_model)
    with open(os.path.join(outdir, "qualitative_with_kb.json"), "w", encoding="utf-8") as f:
        json.dump(qual_with_kb, f, ensure_ascii=False, indent=2)
    write_markdown_report(qual_with_kb, os.path.join(outdir, "qualitative_with_kb.md"))

    unified_md = build_unified_ab_markdown(
        quant_no_kb=arm_outputs["no_kb"]["data"],
        quant_with_kb=arm_outputs["with_kb"]["data"],
        qual_no_kb=qual_no_kb,
        qual_with_kb=qual_with_kb,
        schedule=schedule,
        models_list=models_list,
    )
    unified_md_path = os.path.join(outdir, "unified_ab_report.md")
    with open(unified_md_path, "w", encoding="utf-8") as f:
        f.write(unified_md)

    unified_json_path = os.path.join(outdir, "unified_ab_report.json")
    with open(unified_json_path, "w", encoding="utf-8") as f:
        json.dump({
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "schedule": schedule,
            "quant_no_kb": arm_outputs["no_kb"]["data"],
            "quant_with_kb": arm_outputs["with_kb"]["data"],
            "qual_no_kb": qual_no_kb,
            "qual_with_kb": qual_with_kb,
        }, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 78)
    print("UNIFIED KB A/B BATTERY COMPLETE")
    print(f"Unified Report : {unified_md_path}")
    print(f"Unified JSON   : {unified_json_path}")
    print("=" * 78)

    return {"outdir": outdir, "unified_md": unified_md_path, "unified_json": unified_json_path}


def main() -> int:
    parser = argparse.ArgumentParser(description="Unified Quantitative + Qualitative KB A/B Benchmark")
    parser.add_argument("--rounds-per-arm", type=int, default=4, help="Rounds per arm (default: 4 = 1 per mode)")
    parser.add_argument("--max-fix", type=int, default=2, help="Max auto-fix attempts (default: 2)")
    parser.add_argument("--judge-model", type=str, default="", help="Blind LLM judge model")
    parser.add_argument("--tier", type=str, choices=["fast", "next"], default="fast", help="Model tier: fast or next")
    parser.add_argument("--outdir", type=str, default="", help="Output directory")
    args = parser.parse_args()

    run_unified_kb_ab(
        rounds_per_arm=args.rounds_per_arm,
        max_fix_attempts=args.max_fix,
        judge_model=args.judge_model,
        outdir=args.outdir,
        tier=args.tier,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
