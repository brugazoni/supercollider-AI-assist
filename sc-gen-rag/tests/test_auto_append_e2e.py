#!/usr/bin/env python
"""
End-to-End Auto-Append Test Runner
===================================

Sends real multi-step voice-dictation scenarios through the full
cmd_append → LLM → code pipeline and validates that the generated
SuperCollider code is structurally sound.

Usage:
  python tests/test_auto_append_e2e.py --model gemini/gemini-3.5-flash
  python tests/test_auto_append_e2e.py --model anthropic/claude-3-7-sonnet --scenario B
  python tests/test_auto_append_e2e.py --model gemini/gemini-2.5-flash --all

Arguments:
  --model    Required. The LLM model key (e.g. gemini/gemini-3.5-flash).
  --scenario Run a single scenario: A, B, or C.  (default: all)
  --all      Run all three scenarios.
  --temp     Temperature override (default: model default).
  --outdir   Directory to write generated .scd files (default: tests/e2e_output/).
"""
import argparse
import json
import os
import re
import sys
import time
import textwrap

# --- path setup ---
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


# ============================================================================
# Scenario Definitions (derived from real session logs)
# ============================================================================

SCENARIOS = {
    "A": {
        "name": "The Red Cyclone — Creation & Cross-Cutting Directive",
        "description": (
            "Tests instrument creation, multiple instantiations, global effect "
            "routing, and targeted silencing."
        ),
        "steps": [
            {
                "prompt": "Chega o ciclone rubro à sua cabeça.",
                "expect_type": "ADD_INSTRUMENT",
                "validate": [
                    "ndef_created",      # At least one Ndef defined
                    "pbindef_created",   # At least one Pbindef defined
                    "has_play",          # .play is called
                    "wrapped_in_parens", # Top-level () block
                ],
            },
            {
                "prompt": (
                    "Implora a enxames brancos de seus sonhos vagos, "
                    "mãos de unhas cor de prata."
                ),
                "expect_type": "ADD_INSTRUMENT",
                "validate": [
                    "ndef_created",
                    "pbindef_created",
                    "no_ndef_name_collision",  # Must not redefine block 1's Ndefs
                ],
            },
            {
                "prompt": "Coloque todos os sons dentro de uma caverna espaçosa.",
                "expect_type": "CROSS-CUTTING / ADD_EFFECTS",
                "validate": [
                    "has_effect_slot",    # Uses \\filter -> in slot [10], [11] or [12]
                    "has_wet_control",    # Sets \\wet10 etc.
                ],
            },
            {
                "prompt": "Silencie as camadas de ciclone.",
                "expect_type": "FADE_OUT (Partial)",
                "validate": [
                    "has_fade_or_clear",  # Ndef.clear or fadeTime
                    "has_stop",           # Pbindef.stop
                ],
            },
        ],
    },
    "B": {
        "name": "The Nightingale — Melodic Live-Coding & Tempo",
        "description": (
            "Tests ambient pad creation, fast melodic arpeggios, and global "
            "tempo/rhythm manipulation."
        ),
        "steps": [
            {
                "prompt": (
                    "Lá no bosque de tilhas há uma cama de grama e flores "
                    "esmagadas, embora não haja fadas nem famílias."
                ),
                "expect_type": "ADD_INSTRUMENT",
                "validate": ["ndef_created", "pbindef_created", "wrapped_in_parens"],
            },
            {
                "prompt": (
                    "Fora um rouxinol que canta encantado ao sol, "
                    "eu fui pelo caminho na campina."
                ),
                "expect_type": "ADD_INSTRUMENT",
                "validate": [
                    "ndef_created",
                    "pbindef_created",
                    "no_ndef_name_collision",
                ],
            },
            {
                "prompt": "Filtre todas as camadas e reduza o ritmo de tudo.",
                "expect_type": "CROSS-CUTTING DIRECTIVE",
                "validate": [
                    "touches_multiple_ndefs",  # Modifies >=2 Ndefs or Pbindefs
                ],
            },
        ],
    },
    "C": {
        "name": "The Tower Sentinel — Rhythm & Fade-Out",
        "description": (
            "Tests percussive/rhythmic sequencing, sharp transients, and "
            "complete piece conclusion with full fade-out."
        ),
        "steps": [
            {
                "prompt": (
                    "Na velha torre cinza, uma guarita e a sentinela de "
                    "escarlate a marchar de um lado ao outro, como quem se atua."
                ),
                "expect_type": "ADD_INSTRUMENT",
                "validate": ["ndef_created", "wrapped_in_parens"],
            },
            {
                "prompt": (
                    "Maneja o fuzil como a fim de que faísque ao sol vermelho. "
                    "Ombro arma, apresentar arma."
                ),
                "expect_type": "ADD_INSTRUMENT",
                "validate": [
                    "ndef_created",
                    "no_ndef_name_collision",
                ],
            },
            {
                "prompt": "Finalize todas as camadas e conclua a peça.",
                "expect_type": "FADE_OUT (Full)",
                "validate": [
                    "has_fade_or_clear",
                    "has_stop",
                ],
            },
        ],
    },
}


# ============================================================================
# Validation Checks
# ============================================================================

def _extract_ndef_names(code: str) -> list[str]:
    """Extract all Ndef names (\\symbolName) from definitions like Ndef(\\name, {..."""
    return re.findall(r'Ndef\(\s*\\(\w+)\s*,\s*\{', code)


def _extract_pbindef_names(code: str) -> list[str]:
    """Extract Pbindef definition names."""
    return re.findall(r'Pbindef\(\s*\\(\w+)\s*,', code)


def _check_balanced_brackets(code: str) -> bool:
    """Verify bracket balance, stripping comments and strings."""
    clean = re.sub(r'//.*$', '', code, flags=re.MULTILINE)
    clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL)
    clean = re.sub(r'"[^"]*"', '', clean)
    clean = re.sub(r"'[^']*'", '', clean)
    depth = {'(': 0, '[': 0, '{': 0}
    pairs = {'(': ')', '[': ']', '{': '}'}
    for ch in clean:
        if ch in depth:
            depth[ch] += 1
        elif ch in pairs.values():
            opener = [k for k, v in pairs.items() if v == ch][0]
            depth[opener] -= 1
            if depth[opener] < 0:
                return False
    return all(v == 0 for v in depth.values())


class ValidationResult:
    def __init__(self, name: str, passed: bool, detail: str = ""):
        self.name = name
        self.passed = passed
        self.detail = detail

    def __repr__(self):
        status = "[PASS]" if self.passed else "[FAIL]"
        return f"  {status}  {self.name}" + (f"  ({self.detail})" if self.detail else "")


def run_validations(
    code: str,
    checks: list[str],
    all_previous_ndef_names: list[str],
) -> list[ValidationResult]:
    """Run a list of named validation checks against generated code."""
    results = []
    ndef_names = _extract_ndef_names(code)
    pbindef_names = _extract_pbindef_names(code)

    for check in checks:
        if check == "ndef_created":
            results.append(ValidationResult(
                check, len(ndef_names) > 0,
                f"found: {ndef_names}" if ndef_names else "no Ndef(..., {{...}}) found"
            ))
        elif check == "pbindef_created":
            results.append(ValidationResult(
                check, len(pbindef_names) > 0,
                f"found: {pbindef_names}" if pbindef_names else "no Pbindef found"
            ))
        elif check == "has_play":
            results.append(ValidationResult(
                check, ".play" in code,
            ))
        elif check == "wrapped_in_parens":
            # The LLM often prepends comment headers before the opening paren.
            # We accept any output that contains at least one top-level ( ... ) block.
            has_paren_block = bool(re.search(r'^\s*\(', code, re.MULTILINE))
            results.append(ValidationResult(
                check,
                has_paren_block,
                "found ( block" if has_paren_block else "no top-level ( block found"
            ))
        elif check == "no_ndef_name_collision":
            collisions = set(ndef_names) & set(all_previous_ndef_names)
            results.append(ValidationResult(
                check, len(collisions) == 0,
                f"collisions: {collisions}" if collisions else "unique"
            ))
        elif check == "has_effect_slot":
            has_slot = bool(re.search(r'Ndef\(\s*\\\w+\s*\)\s*\[\s*1[0-2]\s*\]', code))
            results.append(ValidationResult(
                check, has_slot,
                "found filter slot assignment" if has_slot else "no [10]/[11]/[12] slot found"
            ))
        elif check == "has_wet_control":
            has_wet = bool(re.search(r'\\wet1[0-2]', code))
            results.append(ValidationResult(
                check, has_wet,
                "found wet control" if has_wet else "no \\wet10/11/12 found"
            ))
        elif check == "has_fade_or_clear":
            has = ".clear" in code or "fadeTime" in code
            results.append(ValidationResult(
                check, has,
                "found clear/fadeTime" if has else "no .clear or fadeTime"
            ))
        elif check == "has_stop":
            has = ".stop" in code
            results.append(ValidationResult(check, has))
        elif check == "touches_multiple_ndefs":
            # Count unique Ndef references (not definitions, just mentions)
            all_refs = re.findall(r'Ndef\(\s*\\(\w+)', code)
            unique = set(all_refs)
            results.append(ValidationResult(
                check, len(unique) >= 2,
                f"Ndefs referenced: {unique}"
            ))
        elif check == "brackets_balanced":
            bal = _check_balanced_brackets(code)
            results.append(ValidationResult(check, bal))
        else:
            results.append(ValidationResult(check, False, "unknown check"))

    # Always check bracket balance
    bal = _check_balanced_brackets(code)
    results.append(ValidationResult("brackets_balanced", bal))

    return results


# ============================================================================
# Scenario Runner
# ============================================================================

def load_sys_msgs_for_append() -> list[str]:
    """Load the default sys_msgs paths for the append use case."""
    defaults_path = os.path.join(os.path.dirname(__file__), '..', 'sys_msgs_defaults.json')
    with open(defaults_path, 'r', encoding='utf-8') as f:
        defaults = json.load(f)
    return defaults.get("append", [])


def run_scenario(
    scenario_key: str,
    model: str,
    temperature: float | None = None,
    outdir: str = "tests/e2e_output",
) -> dict:
    """Execute a single scenario end-to-end, returning a results dict."""
    import gui_backend

    scenario = SCENARIOS[scenario_key]
    sys_msgs = load_sys_msgs_for_append()
    active_file = ""  # unsaved buffer -- uses __unsaved__ state key

    print(f"\n{'='*72}")
    print(f"  SCENARIO {scenario_key}: {scenario['name']}")
    print(f"  Model: {model}")
    print(f"{'='*72}")
    print(f"  {scenario['description']}\n")

    # Clear state for this run
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()

    all_ndef_names: list[str] = []
    all_code_blocks: list[str] = []
    step_results = []

    for i, step in enumerate(scenario["steps"], start=1):
        prompt = step["prompt"]
        print(f"\n  -- Step {i}/{len(scenario['steps'])} --")
        print(f"  Prompt: {prompt[:100]}...")
        print(f"  Expected: {step['expect_type']}")

        t0 = time.time()
        try:
            data = {
                "prompt": prompt,
                "active_file": active_file,
                "use_kb": False,
                "model": model,
                "sys_msgs": sys_msgs,
            }
            if temperature is not None:
                data["temperature"] = temperature

            result = gui_backend.cmd_append(data)
            code = result.get("code", "")
            stats = result.get("last_stats", {})
            elapsed = time.time() - t0
        except Exception as e:
            elapsed = time.time() - t0
            print(f"  [FAIL] EXCEPTION after {elapsed:.1f}s: {e}")
            step_results.append({
                "step": i, "prompt": prompt, "passed": False,
                "error": str(e), "elapsed": elapsed,
            })
            continue

        print(f"  LLM response: {len(code)} chars in {elapsed:.1f}s")
        if stats:
            print(f"  Tokens: in={stats.get('in_tokens',0)} out={stats.get('out_tokens',0)} "
                  f"cost=${stats.get('cost',0):.4f}")

        # Run validations
        validations = run_validations(code, step["validate"], all_ndef_names)
        passed = all(v.passed for v in validations)

        for v in validations:
            print(repr(v))

        # Track Ndef names across steps for collision detection
        new_ndefs = _extract_ndef_names(code)
        all_ndef_names.extend(new_ndefs)
        all_code_blocks.append(code)

        step_results.append({
            "step": i,
            "prompt": prompt,
            "expect_type": step["expect_type"],
            "passed": passed,
            "code_length": len(code),
            "elapsed": elapsed,
            "validations": [{"name": v.name, "passed": v.passed, "detail": v.detail} for v in validations],
            "ndef_names": new_ndefs,
        })

        # Wait for background state update before next step
        state_key = active_file if active_file else "__unsaved__"
        evt = gui_backend._composition_state_events.get(state_key)
        if evt:
            print(f"  Waiting for composition state update...", end="", flush=True)
            evt.wait(timeout=60)
            print(" done.")

    # -- Summary --
    total_passed = sum(1 for r in step_results if r.get("passed"))
    total_steps = len(step_results)
    scenario_passed = total_passed == total_steps

    print(f"\n  {'-'*50}")
    status_str = "[PASS]" if scenario_passed else "[FAIL]"
    print(f"  {status_str} Scenario {scenario_key}: {total_passed}/{total_steps} steps passed")

    # Write outputs
    os.makedirs(outdir, exist_ok=True)
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    model_slug = model.replace("/", "_")

    # Write combined .scd file
    scd_path = os.path.join(outdir, f"e2e_{scenario_key}_{model_slug}_{timestamp}.scd")
    with open(scd_path, "w", encoding="utf-8") as f:
        f.write(f"// E2E Scenario {scenario_key}: {scenario['name']}\n")
        f.write(f"// Model: {model}\n")
        f.write(f"// Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        for idx, block in enumerate(all_code_blocks, start=1):
            f.write(f"// ========= Step {idx} =========\n")
            f.write(block + "\n\n")
    print(f"  Output: {scd_path}")

    # Write JSON results
    json_path = os.path.join(outdir, f"e2e_{scenario_key}_{model_slug}_{timestamp}.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump({
            "scenario": scenario_key,
            "name": scenario["name"],
            "model": model,
            "timestamp": timestamp,
            "passed": scenario_passed,
            "steps": step_results,
        }, f, indent=2, ensure_ascii=False)
    print(f"  Results: {json_path}")

    return {
        "scenario": scenario_key,
        "passed": scenario_passed,
        "steps": step_results,
        "scd_path": scd_path,
        "json_path": json_path,
    }


# ============================================================================
# Main
# ============================================================================

def main():
    # Force UTF-8 output so accented Portuguese prompts print on Windows consoles.
    import io
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
    else:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

    parser = argparse.ArgumentParser(
        description="Run Auto-Append E2E test scenarios against a live LLM API.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              python tests/test_auto_append_e2e.py --model gemini/gemini-3.5-flash
              python tests/test_auto_append_e2e.py --model anthropic/claude-3-7-sonnet --scenario A
              python tests/test_auto_append_e2e.py --model gemini/gemini-2.5-flash --all --temp 0.5
        """)
    )
    parser.add_argument("--model", required=True,
                        help="LLM model key (e.g. gemini/gemini-3.5-flash)")
    parser.add_argument("--scenario", choices=["A", "B", "C"],
                        help="Run a single scenario (default: all)")
    parser.add_argument("--all", action="store_true",
                        help="Run all scenarios (default if --scenario not specified)")
    parser.add_argument("--temp", type=float, default=None,
                        help="Temperature override")
    parser.add_argument("--outdir", default=os.path.join(os.path.dirname(__file__), "e2e_output"),
                        help="Output directory (default: tests/e2e_output/)")

    args = parser.parse_args()

    # Determine which scenarios to run
    if args.scenario:
        scenarios_to_run = [args.scenario]
    else:
        scenarios_to_run = ["A", "B", "C"]

    print(f"\n{'#'*72}")
    print(f"  AUTO-APPEND E2E TEST RUNNER")
    print(f"  Model: {args.model}")
    print(f"  Scenarios: {', '.join(scenarios_to_run)}")
    print(f"  Output: {args.outdir}")
    print(f"{'#'*72}")

    all_results = []
    for key in scenarios_to_run:
        result = run_scenario(key, args.model, temperature=args.temp, outdir=args.outdir)
        all_results.append(result)

    # -- Final Summary --
    print(f"\n\n{'='*72}")
    print(f"  FINAL SUMMARY")
    print(f"{'='*72}")
    total_scenarios = len(all_results)
    passed_scenarios = sum(1 for r in all_results if r["passed"])

    for r in all_results:
        icon = "[PASS]" if r["passed"] else "[FAIL]"
        step_pass = sum(1 for s in r["steps"] if s.get("passed"))
        step_total = len(r["steps"])
        print(f"  {icon}  Scenario {r['scenario']}: {step_pass}/{step_total} steps")
        for s in r["steps"]:
            s_icon = "[PASS]" if s.get("passed") else "[FAIL]"
            fails = [v["name"] for v in s.get("validations", []) if not v["passed"]]
            fail_str = f"  FAILED: {', '.join(fails)}" if fails else ""
            print(f"      Step {s['step']}: {s_icon} {s.get('expect_type', '')} ({s.get('elapsed', 0):.1f}s){fail_str}")

    print(f"\n  Overall: {passed_scenarios}/{total_scenarios} scenarios passed")
    print(f"{'='*72}\n")

    # Exit code for CI
    sys.exit(0 if passed_scenarios == total_scenarios else 1)


if __name__ == "__main__":
    main()
