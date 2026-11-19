#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Qualitative & Artistic Evaluation Suite for Multi-Provider X-Append Benchmarks.

Performs a two-stage blind LLM-as-a-Judge critique + deterministic DSP telemetry
audit on every generated SuperCollider piece in a `benchmark_report.json` run:
  1. Variety (UGen palette, synthesis paradigms, avoiding boilerplate)
  2. Technical Depth (SuperCollider architecture, routing, modulation, DSP craft)
  3. Compositional Audacity (sonic/structural risk-taking, unconventional tunings/textures)
  4. Coherence with Prompt (translation of Brazilian Portuguese imagery & narrative)
  5. Compositional Arcs (temporal pacing, tension/release, macro-evolution)
  6. Creativity (originality of sonic metaphors and expressive DSP mappings)
"""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import glob
import json
import os
import re
import sys
import time
from typing import Any

from openai import OpenAI

TESTS_DIR = os.path.dirname(os.path.abspath(__file__))
SC_GEN_RAG_DIR = os.path.abspath(os.path.join(TESTS_DIR, ".."))
if SC_GEN_RAG_DIR not in sys.path:
    sys.path.insert(0, SC_GEN_RAG_DIR)

import config

DIMENSIONS = [
    "variety",
    "technical_depth",
    "compositional_audacity",
    "coherence_with_prompt",
    "compositional_arcs",
    "creativity",
]

DIM_LABELS = {
    "variety": "Variety",
    "technical_depth": "Technical Depth",
    "compositional_audacity": "Compositional Audacity",
    "coherence_with_prompt": "Prompt Coherence",
    "compositional_arcs": "Compositional Arcs",
    "creativity": "Creativity",
}

NON_UGEN_CLASSES = {
    "EnvGen", "Env", "Impulse", "Control", "NamedControl", "Out", "In",
    "ReplaceOut", "XOut", "Select", "Mix", "Splay", "Pan2", "Balance2",
    "LeakDC", "Limiter", "Clip", "CheckBadValues", "Done", "FreeSelf",
    "Line", "XLine", "Lag", "Lag2", "Lag3", "VarLag", "Ramp", "A2K", "K2A",
    "DC", "Silent", "BufRd", "PlayBuf", "RecordBuf", "LocalIn", "LocalOut",
    "DelayN", "DelayL", "DelayC", "CombN", "CombL", "CombC", "AllpassN",
    "AllpassL", "AllpassC", "FreeVerb", "FreeVerb2", "GVerb", "Amplitude",
    "PeakFollower", "RunningSum", "Slope", "HPZ1", "LPZ1", "Integrator",
}

ARCH_PATTERNS = {
    "SynthDef": r"\bSynthDef\s*\(",
    "Ndef": r"\bNdef\s*\(",
    "Pbindef": r"\bPbindef\s*\(",
    "Pbind": r"\bPbind\s*\(",
    "Tdef": r"\bTdef\s*\(",
    "Routine": r"\bRoutine\s*\(",
    "MIDIdef": r"\bMIDIdef\.",
    "GUI": r"\b(?:Window|Slider|Knob|Button|StaticText|CompositeView|NumberBox)\b",
    "Bus": r"\bBus\.(?:audio|control)\b",
}

JUDGE_SYSTEM_PROMPT = """You are an expert electroacoustic composer, live-coder, and senior SuperCollider DSP architect.
You are conducting a BLIND qualitative evaluation of a SuperCollider code block generated for a specific Brazilian Portuguese artistic prompt and X-Append mode.

Score each of the 6 dimensions strictly on an integer/half-step scale from 1.0 to 10.0 (1=broken/trivial boilerplate, 5=competent/functional, 8=strong/inventive, 9.5-10=exceptional mastery):

1. `variety`: Diversity of synthesis techniques (FM, modal/DynKlank, physical modeling, granular, wavetable, feedback, subtractive, stochastic) and UGen palette inside this piece, avoiding generic `SinOsc + FreeVerb2` clichés.
2. `technical_depth`: SuperCollider architectural rigor — clean `Ndef`/`SynthDef` design, slot routing (`\\filter ->`, `\\set ->`), bus allocation, gain staging, `LeakDC`, stereo handling, frequency bracketing, `MIDIdef`/GUI architecture (especially in `design` mode), and absence of fragile/buggy patterns.
3. `compositional_audacity`: Willingness to take sonic and structural risks — bold timbral sculpting, unconventional scales/microtonality, intricate modulation networks, polyrhythms, spatialization, or dramatic dynamic contrasts rather than safe ambient pads.
4. `coherence_with_prompt`: How faithfully and evocatively the synthesis, rhythm, timbre, and structure translate the specific Brazilian Portuguese prompt's imagery, mood, cultural instruments (e.g., berimbau, congada, Buchla, Ouro Preto clocks), and narrative.
5. `compositional_arcs`: Temporal pacing and form — presence of introduction, development, climax, tension/release, `Tdef`/envelope/macro-parameter evolution rather than a static unchanging loop.
6. `creativity`: Originality of sonic metaphors and expressive mapping between literary/visual cues and DSP parameters.

Return ONLY valid JSON with this exact schema:
{
  "variety": <float 1..10>,
  "technical_depth": <float 1..10>,
  "compositional_audacity": <float 1..10>,
  "coherence_with_prompt": <float 1..10>,
  "compositional_arcs": <float 1..10>,
  "creativity": <float 1..10>,
  "standout_technique": "<concise 5-12 word phrase>",
  "weakness": "<concise 5-12 word phrase>",
  "rationale": "<2-3 crisp sentences evaluating DSP craft, musicality, and prompt alignment>"
}"""

PORTFOLIO_SYSTEM_PROMPT = """You are an expert electroacoustic composer and SuperCollider architect.
You will receive the 8-round qualitative evaluation summaries and static DSP telemetry for ONE anonymous AI model across 4 modes (append, compose, design, generate).
Assess its cross-round stylistic breadth, synthesis variety, architectural strengths, and recurring blind spots.

Return ONLY valid JSON with this exact schema:
{
  "portfolio_variety": <float 1..10>,
  "artistic_signature": "<1-2 sentences describing this model's musical & DSP personality>",
  "key_strengths": ["<bullet 1>", "<bullet 2>", "<bullet 3>"],
  "blind_spots": ["<bullet 1>", "<bullet 2>"]
}"""


def find_latest_report() -> str:
    base = os.path.join(TESTS_DIR, "multi_provider_benchmark_output", "run_*", "benchmark_report.json")
    matches = sorted(glob.glob(base))
    if not matches:
        raise FileNotFoundError(f"No benchmark_report.json found under {base}")
    return matches[-1]


def extract_dsp_telemetry(code: str) -> dict[str, Any]:
    ugen_calls = re.findall(r"\b([A-Z][A-Za-z0-9_]*)\.(?:ar|kr)\b", code or "")
    unique_ugens = sorted(set(u for u in ugen_calls if u not in NON_UGEN_CLASSES))
    arch_hits = [name for name, pat in ARCH_PATTERNS.items() if re.search(pat, code or "")]
    lines = [ln for ln in (code or "").splitlines() if ln.strip()]
    comment_lines = [ln for ln in lines if ln.strip().startswith("//")]
    return {
        "loc": len(lines),
        "comment_lines": len(comment_lines),
        "unique_ugens": unique_ugens,
        "unique_ugen_count": len(unique_ugens),
        "arch_constructs": arch_hits,
    }


def parse_json_response(raw_text: str) -> dict[str, Any]:
    cleaned = (raw_text or "").strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)
    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start != -1 and end != -1 and end > start:
        cleaned = cleaned[start : end + 1]
    return json.loads(cleaned)


def call_judge_json(
    client: OpenAI,
    judge_model: str,
    system_prompt: str,
    user_prompt: str,
) -> tuple[dict[str, Any], int, int]:
    last_err = None
    for attempt in range(2):
        try:
            resp = client.chat.completions.create(
                model=judge_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                temperature=0.2,
                extra_body={"reasoning": {"effort": "low"}},
                timeout=120.0,
            )
            content = resp.choices[0].message.content or "{}"
            in_tok = int(getattr(resp.usage, "prompt_tokens", 0) or 0)
            out_tok = int(getattr(resp.usage, "completion_tokens", 0) or 0)
            return parse_json_response(content), in_tok, out_tok
        except Exception as exc:
            last_err = exc
    return {
        "variety": 5.0,
        "technical_depth": 5.0,
        "compositional_audacity": 5.0,
        "coherence_with_prompt": 5.0,
        "compositional_arcs": 5.0,
        "creativity": 5.0,
        "standout_technique": "Judge parse fallback",
        "weakness": f"Judge error: {str(last_err)[:80]}",
        "rationale": f"Fallback neutral score after judge error: {last_err}",
    }, 0, 0


def evaluate_report(report_path: str, judge_model: str) -> dict[str, Any]:
    if not config.OPENROUTER_API_KEY:
        raise ValueError("OPENROUTER_API_KEY is required in config.py / environment.")

    with open(report_path, "r", encoding="utf-8") as f:
        report = json.load(f)

    client = OpenAI(
        api_key=config.OPENROUTER_API_KEY,
        base_url="https://openrouter.ai/api/v1",
        timeout=120.0,
        max_retries=1,
        default_headers={
            "HTTP-Referer": "https://github.com/brugazoni/supercollider-AI-assist",
            "X-Title": "SuperCollider AI Assist Qualitative Eval",
        },
    )

    total_in_tokens = 0
    total_out_tokens = 0
    model_results: list[dict[str, Any]] = []

    models = report.get("models", [])
    print(f"Evaluating {len(models)} models from: {report_path}")
    print(f"Judge model: {judge_model}\n")

    for m_idx, m in enumerate(models, 1):
        model_name = m["model_name"]
        model_id = m["model_id"]
        gen_codes = m.get("generated_codes", [])
        print(f"[{m_idx}/{len(models)}] Evaluating {model_name} ({len(gen_codes)} rounds)...", flush=True)

        round_evals: list[dict[str, Any]] = []
        ugen_counter: Counter[str] = Counter()
        arch_counter: Counter[str] = Counter()

        for g in gen_codes:
            r_idx = g["round_index"]
            mode = g["mode"]
            prompt = g["prompt"]
            final_code = g.get("final_code") or g.get("initial_code") or ""
            initial_valid = bool(g.get("initial_valid", False))
            final_valid = bool(g.get("final_valid", False))

            telemetry = extract_dsp_telemetry(final_code)
            ugen_counter.update(telemetry["unique_ugens"])
            arch_counter.update(telemetry["arch_constructs"])

            is_timeout_stub = final_code.strip().startswith("// API Timeout:") or not final_code.strip()
            if is_timeout_stub:
                print(f"  Round {r_idx:02d} [{mode.upper()}]: API timeout stub -> scored 0.0", flush=True)
                scores = {d: 0.0 for d in DIMENSIONS}
                round_evals.append({
                    "round_index": r_idx,
                    "mode": mode,
                    "timed_out": True,
                    "initial_valid": initial_valid,
                    "final_valid": final_valid,
                    "telemetry": telemetry,
                    "scores": scores,
                    "overall_score": 0.0,
                    "standout_technique": "N/A (API Timeout >120s)",
                    "weakness": "Generation timed out before producing code",
                    "rationale": "Round exceeded the 120s API timeout and produced no evaluable SuperCollider code.",
                })
                continue

            # Truncate ultra-long code only if extreme (>28k chars) to keep judge crisp
            code_for_judge = final_code if len(final_code) <= 28000 else (final_code[:28000] + "\n// ... [truncated]")
            user_prompt = (
                f"Mode: {mode.upper()}\n"
                f"Initial sclang compilation valid: {initial_valid}\n"
                f"Final sclang compilation valid: {final_valid}\n"
                f"Brazilian Portuguese Prompt:\n{prompt}\n\n"
                f"Generated SuperCollider Code:\n```supercollider\n{code_for_judge}\n```"
            )

            t0 = time.perf_counter()
            parsed, in_t, out_t = call_judge_json(client, judge_model, JUDGE_SYSTEM_PROMPT, user_prompt)
            dt = time.perf_counter() - t0
            total_in_tokens += in_t
            total_out_tokens += out_t

            scores = {d: round(float(parsed.get(d, 5.0)), 2) for d in DIMENSIONS}
            overall = round(sum(scores.values()) / len(DIMENSIONS), 2)
            print(
                f"  Round {r_idx:02d} [{mode.upper():8s}]: overall={overall:.2f} | "
                f"var={scores['variety']:.1f} tech={scores['technical_depth']:.1f} "
                f"aud={scores['compositional_audacity']:.1f} coh={scores['coherence_with_prompt']:.1f} "
                f"arc={scores['compositional_arcs']:.1f} cre={scores['creativity']:.1f} ({dt:.1f}s)",
                flush=True,
            )

            round_evals.append({
                "round_index": r_idx,
                "mode": mode,
                "timed_out": False,
                "initial_valid": initial_valid,
                "final_valid": final_valid,
                "telemetry": telemetry,
                "scores": scores,
                "overall_score": overall,
                "standout_technique": parsed.get("standout_technique", ""),
                "weakness": parsed.get("weakness", ""),
                "rationale": parsed.get("rationale", ""),
            })

        # Stage 2: Portfolio audit across all 8 rounds
        portfolio_input = {
            "total_unique_ugens_across_8_rounds": len(ugen_counter),
            "top_ugens": ugen_counter.most_common(18),
            "arch_constructs_frequency": dict(arch_counter),
            "rounds": [
                {
                    "round": r["round_index"],
                    "mode": r["mode"],
                    "timed_out": r["timed_out"],
                    "overall": r["overall_score"],
                    "ugens": r["telemetry"]["unique_ugens"],
                    "standout": r["standout_technique"],
                    "weakness": r["weakness"],
                }
                for r in round_evals
            ],
        }
        port_parsed, p_in, p_out = call_judge_json(
            client,
            judge_model,
            PORTFOLIO_SYSTEM_PROMPT,
            f"Evaluate this model's 8-round SuperCollider portfolio:\n{json.dumps(portfolio_input, ensure_ascii=False, indent=2)}",
        )
        total_in_tokens += p_in
        total_out_tokens += p_out

        # Compute averages (both all-rounds including timeouts as 0, and completed-only)
        n_all = max(len(round_evals), 1)
        completed = [r for r in round_evals if not r["timed_out"]]
        n_comp = max(len(completed), 1)

        mean_scores_all = {
            d: round(sum(r["scores"][d] for r in round_evals) / n_all, 2) for d in DIMENSIONS
        }
        mean_scores_completed = {
            d: round(sum(r["scores"][d] for r in completed) / n_comp, 2) for d in DIMENSIONS
        }
        overall_mean_all = round(sum(mean_scores_all.values()) / len(DIMENSIONS), 2)
        overall_mean_completed = round(sum(mean_scores_completed.values()) / len(DIMENSIONS), 2)

        by_mode: dict[str, dict[str, float]] = {}
        for mode_name in ["append", "compose", "design", "generate"]:
            m_rounds = [r for r in round_evals if r["mode"] == mode_name]
            if m_rounds:
                by_mode[mode_name] = {
                    d: round(sum(r["scores"][d] for r in m_rounds) / len(m_rounds), 2) for d in DIMENSIONS
                }
                by_mode[mode_name]["overall"] = round(
                    sum(r["overall_score"] for r in m_rounds) / len(m_rounds), 2
                )

        model_results.append({
            "model_name": model_name,
            "model_id": model_id,
            "initial_pass_rate": m.get("initial_pass_rate", 0.0),
            "mean_scores_all_rounds": mean_scores_all,
            "mean_scores_completed_only": mean_scores_completed,
            "overall_mean_all": overall_mean_all,
            "overall_mean_completed": overall_mean_completed,
            "portfolio_variety_score": round(float(port_parsed.get("portfolio_variety", 5.0)), 2),
            "artistic_signature": port_parsed.get("artistic_signature", ""),
            "key_strengths": port_parsed.get("key_strengths", []),
            "blind_spots": port_parsed.get("blind_spots", []),
            "unique_ugens_total": len(ugen_counter),
            "top_ugens": ugen_counter.most_common(12),
            "arch_constructs": dict(arch_counter),
            "mean_loc": round(sum(r["telemetry"]["loc"] for r in round_evals) / n_all, 1),
            "by_mode": by_mode,
            "rounds": round_evals,
        })

    # Sort leaderboard by overall_mean_all descending
    model_results.sort(key=lambda x: x["overall_mean_all"], reverse=True)

    # Estimate judge cost from config pricing
    j_price = config.PRICING_PER_1M_TOKENS.get(judge_model, {"in": 2.0, "out": 10.0})
    est_judge_cost = (total_in_tokens * j_price["in"] + total_out_tokens * j_price["out"]) / 1_000_000.0

    output = {
        "evaluated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC"),
        "source_benchmark_report": report_path,
        "judge_model": judge_model,
        "judge_tokens": {"in": total_in_tokens, "out": total_out_tokens, "est_cost_usd": round(est_judge_cost, 5)},
        "models": model_results,
    }
    return output


def write_markdown_report(eval_data: dict[str, Any], out_md_path: str) -> None:
    lines: list[str] = []
    lines.append("# Qualitative & Artistic SuperCollider Evaluation Report")
    lines.append(f"**Evaluated**: {eval_data['evaluated_at_utc']}")
    lines.append(f"**Blind Judge**: `{eval_data['judge_model']}` (2-stage: per-round blind scoring + cross-round portfolio variety audit)")
    lines.append(f"**Judge Cost**: {eval_data['judge_tokens']['in']:,} in / {eval_data['judge_tokens']['out']:,} out tokens (~${eval_data['judge_tokens']['est_cost_usd']:.4f})")
    lines.append("")
    lines.append("> **Note on Timeouts**: Rounds that timed out (>120s API guard) receive `0.0` in all-rounds averages; completed-only averages are also shown in parentheses where applicable.")
    lines.append("")

    lines.append("## 1. Qualitative Leaderboard (Mean Scores / 10)")
    lines.append("")
    lines.append("| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |")
    lines.append("|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|")
    for idx, m in enumerate(eval_data["models"], 1):
        s = m["mean_scores_all_rounds"]
        sc = m["mean_scores_completed_only"]
        overall_str = f"**{m['overall_mean_all']:.2f}**"
        if m["overall_mean_completed"] != m["overall_mean_all"]:
            overall_str += f" ({m['overall_mean_completed']:.2f})"
        lines.append(
            f"| #{idx} | **{m['model_name']}** | {overall_str} | {m['portfolio_variety_score']:.1f} | "
            f"{s['variety']:.2f} | {s['technical_depth']:.2f} | {s['compositional_audacity']:.2f} | "
            f"{s['coherence_with_prompt']:.2f} | {s['compositional_arcs']:.2f} | {s['creativity']:.2f} | "
            f"{m['unique_ugens_total']} | {m['mean_loc']} |"
        )
    lines.append("")

    lines.append("## 2. Qualitative Overall Score by Mode")
    lines.append("")
    lines.append("| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |")
    lines.append("|:---|:---:|:---:|:---:|:---:|")
    for m in eval_data["models"]:
        bm = m["by_mode"]
        lines.append(
            f"| **{m['model_name']}** | "
            f"{bm.get('append', {}).get('overall', 0):.2f} | "
            f"{bm.get('compose', {}).get('overall', 0):.2f} | "
            f"{bm.get('design', {}).get('overall', 0):.2f} | "
            f"{bm.get('generate', {}).get('overall', 0):.2f} |"
        )
    lines.append("")

    lines.append("## 3. Artistic Profiles, DSP Signatures & Blind Spots")
    lines.append("")
    for m in eval_data["models"]:
        lines.append(f"### {m['model_name']} (`{m['model_id']}`)")
        lines.append(f"- **Artistic Signature**: {m['artistic_signature']}")
        lines.append(f"- **Unique UGens Used ({m['unique_ugens_total']})**: {', '.join(f'`{u}` ({c})' for u, c in m['top_ugens'])}")
        lines.append(f"- **Architectural Constructs**: {', '.join(f'`{k}`×{v}' for k, v in sorted(m['arch_constructs'].items()))}")
        lines.append("- **Key Strengths**:")
        for b in m["key_strengths"]:
            lines.append(f"  - {b}")
        lines.append("- **Blind Spots**:")
        for b in m["blind_spots"]:
            lines.append(f"  - {b}")
        lines.append("")

    lines.append("## 4. Round-by-Round Blind Critique")
    lines.append("")
    for m in eval_data["models"]:
        lines.append(f"### {m['model_name']}")
        lines.append("| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |")
        lines.append("|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|")
        for r in m["rounds"]:
            s = r["scores"]
            lines.append(
                f"| {r['round_index']:02d} | `{r['mode'].upper()}` | **{r['overall_score']:.2f}** | "
                f"{s['variety']:.1f} | {s['technical_depth']:.1f} | {s['compositional_audacity']:.1f} | "
                f"{s['coherence_with_prompt']:.1f} | {s['compositional_arcs']:.1f} | {s['creativity']:.1f} | "
                f"{r['standout_technique']} | {r['weakness']} |"
            )
        lines.append("")
        for r in m["rounds"]:
            lines.append(f"- **Round {r['round_index']:02d} (`{r['mode'].upper()}`)**: {r['rationale']}")
        lines.append("")

    with open(out_md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def main() -> None:
    parser = argparse.ArgumentParser(description="Run blind LLM qualitative evaluation on X-Append benchmark results.")
    parser.add_argument("--report", type=str, default="", help="Path to benchmark_report.json (defaults to latest).")
    parser.add_argument("--judge-model", type=str, default="anthropic/claude-sonnet-5.5", help="OpenRouter judge model ID.")
    args = parser.parse_args()

    report_path = args.report or find_latest_report()
    out_dir = os.path.dirname(os.path.abspath(report_path))
    out_json = os.path.join(out_dir, "qualitative_eval_report.json")
    out_md = os.path.join(out_dir, "qualitative_eval_report.md")

    eval_data = evaluate_report(report_path, args.judge_model)
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(eval_data, f, ensure_ascii=False, indent=2)
    write_markdown_report(eval_data, out_md)

    print("\n" + "=" * 78)
    print("QUALITATIVE EVALUATION COMPLETE")
    print(f"Markdown Report : {out_md}")
    print(f"JSON Report     : {out_json}")
    print("=" * 78)


if __name__ == "__main__":
    main()
