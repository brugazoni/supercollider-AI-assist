#!/usr/bin/env python
"""
Automated Stress Test Suite for X-Append Lean Prompts (pt-BR 80-Fragment Corpus)
=================================================================================

Tests the 4 X-Append modes (`append`, `compose`, `design`, `generate`) using
single-step Lean Prompts (`lean_prompt=True`) over an 80-fragment corpus of
paragraph-length Brazilian Portuguese (`pt-BR`) texts (Wikipedia articles,
poems, stories/chronicles, and image descriptions).

Battery specification:
  - 20 rounds total in X-Append: each of the 4 modes (`append`, `compose`,
    `design`, `generate`) is tested 5 times, randomly choosing 20 distinct
    fragments from the 80-fragment `pt-BR` corpus.
  - Up to 2 rounds of Auto-Fix (`max_fix_attempts = 2`) via `cmd_fix` when
    parallel `sclang` validation detects a syntax or runtime error.
  - Pre-Design Synthesizer Cleanup: when a `design` use case runs after another
    `design` has already run before in the battery, cleans up the previously
    generated synthesizer (`~guiRoutine`, GUI windows, `MIDIdef`s, `~notes`,
    `~zoneNotes`, mono/FX synths, `~synthGroup`/`~fxGroup`/`~masterGroup`,
    `~buses`, design audio buses, and `subtractiveDesign` fallback) while
    preserving `Ndef`/`Pbindef` layers from `append`/`compose`/`generate`.
  - Records and reports:
    * Lean prompt execution time (wall-clock & LLM `time_s`, per-round and
      per-mode mean, median, min, max, total)
    * Auto-fix amount (rounds triggered, Attempt 1 vs Attempt 2 recoveries,
      failsafe fallbacks, auto-fix durations)
    * Overall behavior (1st-try pass rate, post-autofix pass rate, validator
      normalizations applied, design synthesizer cleanups, composition state
      evolution)

Usage (Live 20-Round Battery):
  python tests/test_xappend_lean_stress.py --model "openrouter:google/gemini-3.8-flash"
  python tests/test_xappend_lean_stress.py --model "openrouter:google/gemini-3.8-flash" --seed 42

Usage (Pytest Automated Suite):
  pytest tests/test_xappend_lean_stress.py -v
"""
from __future__ import annotations

import argparse
import json
import os
import queue
import random
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
import threading
import time
from dataclasses import dataclass, field, asdict
from typing import Any, Callable, Optional

# Ensure `sc-gen-rag` root is importable
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SC_GEN_RAG_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
if SC_GEN_RAG_DIR not in sys.path:
    sys.path.insert(0, SC_GEN_RAG_DIR)

import config
import gui_backend
import sc_state_parser
from code_validator import (
    DESIGN_PRE_CLEANUP_MARKER,
    get_design_cleanup_sc,
    normalize_for_xappend,
    prepend_design_cleanup,
    validate_and_fix,
)

CORPUS_PATH_200 = os.path.join(SC_GEN_RAG_DIR, "test-prompts", "ptbr_xappend_corpus_200.json")
CORPUS_PATH_80 = os.path.join(SC_GEN_RAG_DIR, "test-prompts", "ptbr_xappend_corpus_80.json")
CORPUS_PATH = CORPUS_PATH_200 if os.path.isfile(CORPUS_PATH_200) else CORPUS_PATH_80
XAPPEND_MODES = ("append", "compose", "design", "generate")
DEFAULT_ROUNDS_PER_MODE = 5
DEFAULT_MAX_FIX_ATTEMPTS = 2


# ============================================================================
# 1. Corpus Loading & 20-Round Battery Scheduling
# ============================================================================

def load_ptbr_corpus(corpus_path: str = CORPUS_PATH) -> dict[str, Any]:
    """Load and validate the Brazilian Portuguese corpus (supporting 80 or 200 fragments)."""
    with open(corpus_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    fragments = data.get("fragments", [])
    if len(fragments) < 80:
        raise ValueError(f"Expected at least 80 fragments in corpus, found {len(fragments)}")
    return data


def build_20_round_battery_schedule(
    fragments: list[dict[str, Any]],
    rounds_per_mode: int = DEFAULT_ROUNDS_PER_MODE,
    seed: Optional[int] = None,
    shuffle_modes: bool = True,
) -> list[dict[str, Any]]:
    """
    Build a 20-round X-Append test schedule:
      - 4 modes (`append`, `compose`, `design`, `generate`) x `rounds_per_mode` (5) = 20 rounds.
      - Randomly samples `4 * rounds_per_mode` distinct fragments from the 80-fragment corpus.
      - Shuffles the mode sequence (unless `shuffle_modes=False`) so cross-mode transitions
        and repeated `design` cleanups happen in realistic interleaved order.
    """
    total_rounds = len(XAPPEND_MODES) * rounds_per_mode
    if total_rounds > len(fragments):
        raise ValueError(
            f"Cannot sample {total_rounds} unique fragments from corpus of size {len(fragments)}"
        )

    rng = random.Random(seed)
    chosen_fragments = rng.sample(fragments, total_rounds)

    mode_list: list[str] = []
    for m in XAPPEND_MODES:
        mode_list.extend([m] * rounds_per_mode)
    if shuffle_modes:
        rng.shuffle(mode_list)

    schedule: list[dict[str, Any]] = []
    mode_counters = {m: 0 for m in XAPPEND_MODES}
    for idx, (mode, frag) in enumerate(zip(mode_list, chosen_fragments), start=1):
        mode_counters[mode] += 1
        schedule.append({
            "round_index": idx,
            "mode": mode,
            "mode_occurrence": mode_counters[mode],
            "requires_design_cleanup": (mode == "design" and mode_counters["design"] > 1),
            "fragment_id": frag["id"],
            "fragment_category": frag["category"],
            "fragment_source": frag["source"],
            "prompt": frag["text"],
        })
    return schedule


# ============================================================================
# 2. Parallel SuperCollider (`sclang`) Validator & Runtime Executor
# ============================================================================

def find_sclang_executable() -> Optional[str]:
    """Locate `sclang.exe` / `sclang` on Windows, macOS, or Linux."""
    env_path = os.environ.get("SCLANG_PATH")
    if env_path and os.path.isfile(env_path):
        return env_path

    which_path = shutil.which("sclang")
    if which_path:
        return which_path

    candidates = [
        r"C:\Program Files\SuperCollider-3.14.1\sclang.exe",
        r"C:\Program Files\SuperCollider-3.14.0\sclang.exe",
        r"C:\Program Files\SuperCollider-3.13.0\sclang.exe",
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None


class SclangParallelValidator:
    """
    Persistent `sclang -i scval` validation interpreter + virtual Server on port 57111.
    Mirrors `AiAssistWidget::validateCodeOnParallelServer` in `ai_assist_widget.cpp`.
    """

    def __init__(self, sclang_path: Optional[str] = None, udp_port: int = 57131):
        self.sclang_path = sclang_path or find_sclang_executable()
        self.udp_port = udp_port
        self.proc: Optional[subprocess.Popen] = None
        self._out_queue: queue.Queue[str] = queue.Queue()
        self._reader_thread: Optional[threading.Thread] = None
        self.ready = False

    def start(self, timeout: float = 20.0) -> bool:
        if not self.sclang_path or not os.path.isfile(self.sclang_path):
            return False
        if self.proc and self.proc.poll() is None and self.ready:
            return True

        self.proc = subprocess.Popen(
            [self.sclang_path, "-i", "scval", "-u", str(self.udp_port)],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=0,
        )

        def _reader():
            assert self.proc and self.proc.stdout
            while True:
                raw = self.proc.stdout.readline()
                if not raw:
                    break
                text = raw.decode("utf-8", errors="replace")
                self._out_queue.put(text)

        self._reader_thread = threading.Thread(target=_reader, daemon=True)
        self._reader_thread.start()

        # Wait for class library compilation
        deadline = time.perf_counter() + timeout
        compile_buf = ""
        while time.perf_counter() < deadline:
            try:
                line = self._out_queue.get(timeout=0.25)
                compile_buf += line
                if "Welcome to SuperCollider" in compile_buf or "compile done" in compile_buf:
                    break
            except queue.Empty:
                if self.proc.poll() is not None:
                    return False

        init_script = (
            "(\n"
            "~valServer = Server(\\valServer, NetAddr(\"127.0.0.1\", 57111));\n"
            "~valServer.options.numOutputBusChannels = 2;\n"
            "~valServer.options.numInputBusChannels = 0;\n"
            "~valServer.options.memSize = 131072;\n"
            "Server.default = s = ~valServer;\n"
            "s.boot;\n"
            "\"__VAL_SERVER_BOOTED__\".postln;\n"
            "\"__VAL_INTERPRETER_READY__\".postln;\n"
            ")\n\x0c"
        )
        self._send(init_script)

        ready_deadline = time.perf_counter() + 8.0
        while time.perf_counter() < ready_deadline:
            try:
                line = self._out_queue.get(timeout=0.25)
                if "__VAL_INTERPRETER_READY__" in line:
                    self.ready = True
                    return True
            except queue.Empty:
                if self.proc.poll() is not None:
                    return False
        return False

    def _send(self, code_with_formfeed: str) -> None:
        if not self.proc or not self.proc.stdin:
            raise RuntimeError("sclang process is not running")
        self.proc.stdin.write(code_with_formfeed.encode("utf-8"))
        self.proc.stdin.flush()

    def _drain_queue(self) -> None:
        while not self._out_queue.empty():
            try:
                self._out_queue.get_nowait()
            except queue.Empty:
                break

    def run_design_cleanup(self, timeout: float = 4.0) -> tuple[bool, float]:
        """Explicitly run the Design synthesizer cleanup block on the sclang interpreter."""
        if not self.ready:
            return True, 0.0
        t0 = time.perf_counter()
        cleanup_sc = get_design_cleanup_sc(as_block=False)
        self._drain_queue()
        cmd = (
            "try {\n"
            f"    {cleanup_sc}\n"
            "    \"__DESIGN_CLEANUP_OK__\".postln;\n"
            "} { |err|\n"
            "    (\"__DESIGN_CLEANUP_ERR__: \" ++ err.errorString).postln;\n"
            "};\n\x0c"
        )
        self._send(cmd)
        deadline = time.perf_counter() + timeout
        while time.perf_counter() < deadline:
            try:
                line = self._out_queue.get(timeout=0.1)
                if "__DESIGN_CLEANUP_OK__" in line:
                    return True, time.perf_counter() - t0
                if "__DESIGN_CLEANUP_ERR__:" in line:
                    return False, time.perf_counter() - t0
            except queue.Empty:
                pass
        return True, time.perf_counter() - t0

    def validate_code(
        self,
        code: str,
        mode: str = "append",
        timeout: float = 6.0,
    ) -> tuple[bool, str, float]:
        """
        Validate a candidate SuperCollider block on the parallel sclang server.
        Returns `(is_valid, error_message, validation_time_s)`.
        """
        t0 = time.perf_counter()
        if not code or not code.strip():
            return False, "Empty SuperCollider code block", time.perf_counter() - t0

        # Structural check if sclang is not running
        if not self.ready or not self.proc or self.proc.poll() is None is False:
            _, fixes = validate_and_fix(code)
            if "WARNING: brackets are unbalanced" in fixes:
                return False, "ERROR: Unbalanced brackets in generated code", time.perf_counter() - t0
            return True, "", time.perf_counter() - t0

        self._drain_queue()

        # Mirror AiAssistWidget::validateCodeOnParallelServer:
        # Convert `.waitForBoot(` -> `.do(` and `s.sync;` -> `nil;` so setup inside
        # waitForBoot executes synchronously inside `try { fn.value; }`.
        val_code = re.sub(r'\.\s*waitForBoot\s*\(', '.do(', code)
        val_code = re.sub(r'\b(?:s|Server\.default)\s*\.\s*sync\s*;', 'nil;', val_code)

        fd, temp_path = tempfile.mkstemp(prefix="sc_val_candidate_", suffix=".scd")
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as f:
                f.write(val_code)

            escaped_path = temp_path.replace("\\", "/")
            # Stop Tdefs and close GUI windows after synchronous validation while keeping
            # environment state (~synthGroup, ~buses, Ndefs, Pbindefs) alive across rounds.
            post_step_cmd = "try { Tdef.all.do(_.stop); Window.closeAll; } { };"

            wrapper = (
                "try {\n"
                f"    var fn = thisProcess.interpreter.compileFile(\"{escaped_path}\");\n"
                "    if(fn.isNil) {\n"
                "        \"__VAL_ERROR__: Syntax / compile error in generated code\".postln;\n"
                "    } {\n"
                "        fn.value;\n"
                f"        {post_step_cmd}\n"
                "        \"__VAL_VALID__\".postln;\n"
                "    };\n"
                "} { |err|\n"
                f"    {post_step_cmd}\n"
                "    (\"__VAL_ERROR__: \" ++ err.errorString).postln;\n"
                "};\n\x0c"
            )
            self._send(wrapper)

            output_lines: list[str] = []
            has_valid = False
            has_error = False
            deadline = time.perf_counter() + timeout

            while time.perf_counter() < deadline:
                try:
                    line = self._out_queue.get(timeout=0.1)
                    output_lines.append(line)
                    if "__VAL_VALID__" in line:
                        has_valid = True
                        break
                    if "__VAL_ERROR__:" in line:
                        has_error = True
                        break
                except queue.Empty:
                    if self.proc.poll() is not None:
                        break

            # Drain any trailing error lines posted within 50ms
            drain_until = time.perf_counter() + 0.05
            while time.perf_counter() < drain_until:
                try:
                    output_lines.append(self._out_queue.get_nowait())
                except queue.Empty:
                    break

            full_output = "".join(output_lines)
            err_details: list[str] = []
            full_trace: list[str] = []
            capturing_trace = False

            for raw_line in full_output.splitlines():
                trimmed = raw_line.strip()
                if not trimmed:
                    continue
                if trimmed.upper().startswith("WARNING:") or trimmed.upper().startswith("INFO:"):
                    continue
                if "__VAL_VALID__" in trimmed:
                    continue
                is_err_trigger = (
                    "__VAL_ERROR__:" in trimmed
                    or trimmed.upper().startswith("ERROR:")
                    or trimmed.lower().startswith("lexing error")
                    or trimmed.lower().startswith("parse error")
                    or "syntax error" in trimmed.lower()
                    or trimmed.startswith("!")
                )
                if is_err_trigger:
                    err_details.append(trimmed)
                    capturing_trace = True
                if capturing_trace:
                    full_trace.append(raw_line)

            is_valid = has_valid and (not has_error) and (len(err_details) == 0)
            error_text = ""
            if not is_valid:
                if err_details:
                    error_text = "\n".join(err_details)
                    if full_trace:
                        error_text += "\n" + "\n".join(full_trace)
                else:
                    error_text = full_output[-600:].strip() or "Validation timed out on sclang"

            return is_valid, error_text.strip(), time.perf_counter() - t0
        finally:
            try:
                os.remove(temp_path)
            except OSError:
                pass

    def stop(self) -> None:
        if self.proc and self.proc.poll() is None:
            try:
                self._send("if(s.notNil) { s.quit }; 0.exit\n\x0c")
                self.proc.wait(timeout=2.0)
            except Exception:
                try:
                    self.proc.kill()
                except Exception:
                    pass
        self.proc = None
        self.ready = False


# ============================================================================
# 3. Data Structures for Round & Battery Telemetry
# ============================================================================

@dataclass
class FixAttemptRecord:
    attempt_number: int
    wall_time_s: float
    llm_time_s: float
    val_time_s: float
    in_tokens: int
    out_tokens: int
    cost_usd: float
    valid_after_fix: bool
    error_before_fix: str
    error_after_fix: str
    validator_fixes: list[str] = field(default_factory=list)


@dataclass
class RoundRecord:
    round_index: int
    mode: str
    mode_occurrence: int
    fragment_id: int
    fragment_category: str
    fragment_source: str
    prompt: str
    lean_wall_time_s: float
    lean_llm_time_s: float
    initial_val_time_s: float
    in_tokens: int
    out_tokens: int
    cost_usd: float
    code_chars: int
    initial_valid: bool
    initial_error: str
    design_cleanup_required: bool
    design_cleanup_applied: bool
    design_cleanup_time_s: float
    auto_fix_triggered: bool
    auto_fix_attempts_used: int
    auto_fix_succeeded: bool
    resolved_on_attempt: int  # 0 = passed initially, 1 = fix #1, 2 = fix #2, -1 = fallback
    fallback_triggered: bool
    final_valid: bool
    total_round_wall_time_s: float
    validator_fixes: list[str] = field(default_factory=list)
    fix_attempts: list[FixAttemptRecord] = field(default_factory=list)
    composition_state_after: str = ""


# ============================================================================
# 4. 20-Round X-Append Lean Prompt + 2-Round Auto-Fix Battery Runner
# ============================================================================

def run_xappend_lean_battery(
    model_key: str,
    seed: Optional[int] = 42,
    rounds_per_mode: int = DEFAULT_ROUNDS_PER_MODE,
    max_fix_attempts: int = DEFAULT_MAX_FIX_ATTEMPTS,
    use_kb: bool = False,
    temperature: Optional[float] = None,
    validator: Optional[Any] = None,
    corpus_path: str = CORPUS_PATH,
    outdir: Optional[str] = None,
    verbose: bool = True,
) -> dict[str, Any]:
    """
    Execute a full 20-round X-Append Lean Prompt stress test battery with up to
    `max_fix_attempts` (default 2) Auto-Fix rounds per failed block.
    """
    corpus_data = load_ptbr_corpus(corpus_path)
    fragments = corpus_data["fragments"]
    schedule = build_20_round_battery_schedule(
        fragments,
        rounds_per_mode=rounds_per_mode,
        seed=seed,
        shuffle_modes=True,
    )

    own_validator = False
    if validator is None:
        validator = SclangParallelValidator()
        own_validator = True
        started = validator.start()
        if verbose:
            print(f"[VAL-SERVER] sclang parallel validator ready={started} ({validator.sclang_path})")

    # Create an isolated temporary .scd session file so composition state and
    # previous code context accumulate realistically across all 20 rounds.
    if outdir:
        os.makedirs(outdir, exist_ok=True)
        session_scd_path = os.path.join(outdir, "xappend_lean_battery_session.scd")
    else:
        fd, session_scd_path = tempfile.mkstemp(prefix="xappend_lean_battery_", suffix=".scd")
        os.close(fd)

    with open(session_scd_path, "w", encoding="utf-8") as f:
        f.write("// X-Append Lean Prompt 20-Round Stress Test Session\n\n")

    # Reset backend state for this session key
    gui_backend._composition_states.pop(session_scd_path, None)
    gui_backend._composition_state_events.pop(session_scd_path, None)
    gui_backend._design_ran_in_session.pop(session_scd_path, None)

    round_records: list[RoundRecord] = []
    design_runs_completed = 0
    battery_t0 = time.perf_counter()

    try:
        for item in schedule:
            r_idx = item["round_index"]
            mode = item["mode"]
            mode_occ = item["mode_occurrence"]
            prompt = item["prompt"]
            frag_id = item["fragment_id"]
            frag_cat = item["fragment_category"]
            frag_src = item["fragment_source"]

            round_t0 = time.perf_counter()
            needs_design_cleanup = (mode == "design" and design_runs_completed >= 1)
            design_cleanup_time_s = 0.0

            if verbose:
                print(
                    f"\n--- [Round {r_idx:02d}/{len(schedule):02d}] MODE={mode.upper()} (#{mode_occ}) "
                    f"| Frag #{frag_id} ({frag_cat}: {frag_src}) ---",
                    flush=True,
                )
                if needs_design_cleanup:
                    print(
                        "  [DESIGN CLEANUP] Previous design synth detected -> cleaning up before new design...",
                        flush=True,
                    )

            # If a previous design synthesizer ran before, execute cleanup on the live sclang session
            if needs_design_cleanup and hasattr(validator, "run_design_cleanup"):
                _, design_cleanup_time_s = validator.run_design_cleanup()

            payload: dict[str, Any] = {
                "mode": mode,
                "lean_prompt": True,
                "use_kb": use_kb,
                "prompt": prompt,
                "model": model_key,
                "active_file": session_scd_path,
                "cleanup_previous_design": needs_design_cleanup,
            }
            if temperature is not None:
                payload["temperature"] = temperature

            # --- Step 1: Execute Lean Prompt X-Append Generation ---
            lean_t0 = time.perf_counter()
            res = gui_backend.cmd_cross_append(payload)
            lean_wall_s = time.perf_counter() - lean_t0

            # Wait for background composition state thread to finish before inspecting
            evt = gui_backend._composition_state_events.get(session_scd_path)
            if evt and not evt.is_set():
                evt.wait(timeout=10.0)

            code = res.get("code", "")
            stats = res.get("last_stats", {}) or {}
            rag_fallback = res.get("rag_fallback", "")
            validator_fixes = list(res.get("validator_fixes", []))
            design_cleanup_applied = bool(
                res.get("design_cleanup_applied", False)
                or (needs_design_cleanup and DESIGN_PRE_CLEANUP_MARKER in code)
            )

            # Ensure pre-design cleanup is present in code if a previous design ran
            if needs_design_cleanup and code and DESIGN_PRE_CLEANUP_MARKER not in code:
                code, prepended = prepend_design_cleanup(code)
                if prepended:
                    design_cleanup_applied = True
                    validator_fixes.append(
                        "prepended pre-design synthesizer cleanup for previous design instance"
                    )

            lean_llm_s = float(stats.get("time_s", 0.0) or lean_wall_s)
            in_tokens = int(stats.get("in_tokens", 0) or 0)
            out_tokens = int(stats.get("out_tokens", 0) or 0)
            cost_usd = float(stats.get("cost", 0.0) or 0.0)

            # --- Step 2: Validate on Parallel sclang Server ---
            initial_valid, initial_error, initial_val_s = validator.validate_code(code, mode=mode)

            if verbose:
                status_tag = "PASS" if initial_valid else "FAIL"
                print(
                    f"  [LEAN {mode.upper()}] wall={lean_wall_s:.2f}s (llm={lean_llm_s:.2f}s) "
                    f"| chars={len(code)} | val={status_tag} ({initial_val_s:.2f}s)",
                    flush=True,
                )
                if not initial_valid:
                    first_err_line = (initial_error.splitlines() or ["Unknown error"])[0]
                    print(f"  [VAL ERROR] {first_err_line}", flush=True)

            # --- Step 3: Up to `max_fix_attempts` (2) Rounds of Auto-Fix ---
            fix_records: list[FixAttemptRecord] = []
            current_code = code
            current_valid = initial_valid
            current_error = initial_error
            resolved_on_attempt = 0 if initial_valid else -1
            fallback_triggered = False

            if not current_valid and max_fix_attempts > 0:
                for attempt in range(1, max_fix_attempts + 1):
                    if verbose:
                        print(
                            f"  [AUTO-FIX {attempt}/{max_fix_attempts}] Sending broken {mode.upper()} block + trace to cmd_fix...",
                            flush=True,
                        )
                    fix_payload: dict[str, Any] = {
                        "block": current_code,
                        "error": current_error,
                        "mode": mode,
                        "is_cross_append": True,
                        "cleanup_previous_design": needs_design_cleanup,
                        "model": model_key,
                        "active_file": session_scd_path,
                    }
                    if temperature is not None:
                        fix_payload["temperature"] = temperature

                    fix_t0 = time.perf_counter()
                    fix_res = gui_backend.cmd_fix(fix_payload)
                    fix_wall_s = time.perf_counter() - fix_t0

                    fixed_code = fix_res.get("code", "")
                    fix_stats = fix_res.get("last_stats", {}) or {}
                    fix_val_fixes = list(fix_res.get("validator_fixes", []))

                    if needs_design_cleanup and fixed_code and DESIGN_PRE_CLEANUP_MARKER not in fixed_code:
                        fixed_code, prepended = prepend_design_cleanup(fixed_code)
                        if prepended:
                            fix_val_fixes.append(
                                "prepended pre-design synthesizer cleanup for previous design instance"
                            )

                    valid_after, err_after, val_s = validator.validate_code(fixed_code, mode=mode)
                    fix_llm_s = float(fix_stats.get("time_s", 0.0) or fix_wall_s)

                    fix_records.append(
                        FixAttemptRecord(
                            attempt_number=attempt,
                            wall_time_s=fix_wall_s,
                            llm_time_s=fix_llm_s,
                            val_time_s=val_s,
                            in_tokens=int(fix_stats.get("in_tokens", 0) or 0),
                            out_tokens=int(fix_stats.get("out_tokens", 0) or 0),
                            cost_usd=float(fix_stats.get("cost", 0.0) or 0.0),
                            valid_after_fix=valid_after,
                            error_before_fix=current_error,
                            error_after_fix=err_after,
                            validator_fixes=fix_val_fixes,
                        )
                    )

                    current_code = fixed_code
                    current_valid = valid_after
                    current_error = err_after

                    if verbose:
                        fix_status = "RECOVERED" if valid_after else "STILL FAILING"
                        print(
                            f"  [AUTO-FIX {attempt}/{max_fix_attempts}] {fix_status} in {fix_wall_s:.2f}s (val={val_s:.2f}s)",
                            flush=True,
                        )

                    if valid_after:
                        resolved_on_attempt = attempt
                        # Update composition state with the repaired code
                        prev_state = gui_backend._composition_states.get(session_scd_path, "")
                        gui_backend._composition_states[session_scd_path] = (
                            sc_state_parser.update_composition_state(prev_state, current_code).strip()
                        )
                        break

            # --- Step 4: Failsafe Fallback if Auto-Fix Exhausted ---
            if not current_valid:
                fallback_triggered = True
                resolved_on_attempt = -1
                if not rag_fallback:
                    fb_res = gui_backend.cmd_rag_lookup({"prompt": prompt, "mode": mode})
                    rag_fallback = fb_res.get("code", "")
                if needs_design_cleanup and rag_fallback and DESIGN_PRE_CLEANUP_MARKER not in rag_fallback:
                    rag_fallback, _ = prepend_design_cleanup(rag_fallback)
                current_code = rag_fallback
                current_valid, _, _ = validator.validate_code(current_code, mode=mode)
                gui_backend.cmd_reset_composition_state({
                    "code": current_code,
                    "active_file": session_scd_path,
                })
                if verbose:
                    print(
                        f"  [FAILSAFE - {mode.upper()}] Exhausted {max_fix_attempts} auto-fix attempts -> applied fallback block.",
                        flush=True,
                    )

            if mode == "design":
                design_runs_completed += 1

            # Append committed block to the session .scd file (matching IDE behavior)
            with open(session_scd_path, "a", encoding="utf-8") as f:
                f.write(
                    f"\n// === Round {r_idx:02d} [{mode.upper()}] Frag #{frag_id} ({frag_cat}) ===\n"
                    f"{current_code}\n"
                )

            comp_state_after = gui_backend._composition_states.get(session_scd_path, "")
            total_round_s = time.perf_counter() - round_t0

            round_records.append(
                RoundRecord(
                    round_index=r_idx,
                    mode=mode,
                    mode_occurrence=mode_occ,
                    fragment_id=frag_id,
                    fragment_category=frag_cat,
                    fragment_source=frag_src,
                    prompt=prompt,
                    lean_wall_time_s=round(lean_wall_s, 4),
                    lean_llm_time_s=round(lean_llm_s, 4),
                    initial_val_time_s=round(initial_val_s, 4),
                    in_tokens=in_tokens,
                    out_tokens=out_tokens,
                    cost_usd=round(cost_usd, 6),
                    code_chars=len(current_code or ""),
                    initial_valid=initial_valid,
                    initial_error=initial_error,
                    design_cleanup_required=needs_design_cleanup,
                    design_cleanup_applied=design_cleanup_applied,
                    design_cleanup_time_s=round(design_cleanup_time_s, 4),
                    auto_fix_triggered=(not initial_valid and max_fix_attempts > 0),
                    auto_fix_attempts_used=len(fix_records),
                    auto_fix_succeeded=(not initial_valid and resolved_on_attempt in (1, 2)),
                    resolved_on_attempt=resolved_on_attempt,
                    fallback_triggered=fallback_triggered,
                    final_valid=current_valid,
                    total_round_wall_time_s=round(total_round_s, 4),
                    validator_fixes=validator_fixes,
                    fix_attempts=fix_records,
                    composition_state_after=comp_state_after,
                )
            )
    finally:
        if own_validator and validator is not None:
            validator.stop()
        if not outdir and os.path.exists(session_scd_path):
            try:
                os.remove(session_scd_path)
            except OSError:
                pass

    total_battery_wall_s = time.perf_counter() - battery_t0
    summary = summarize_battery_results(
        round_records=round_records,
        model_key=model_key,
        seed=seed,
        max_fix_attempts=max_fix_attempts,
        total_battery_wall_s=total_battery_wall_s,
    )

    if outdir:
        report_json_path = os.path.join(outdir, "xappend_lean_battery_report.json")
        with open(report_json_path, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2, ensure_ascii=False)
        report_md_path = os.path.join(outdir, "xappend_lean_battery_report.md")
        with open(report_md_path, "w", encoding="utf-8") as f:
            f.write(format_battery_markdown_report(summary))

    return summary


# ============================================================================
# 5. Summary & Markdown Report Generation
# ============================================================================

def _numeric_stats(values: list[float]) -> dict[str, float]:
    if not values:
        return {"count": 0, "mean": 0.0, "median": 0.0, "min": 0.0, "max": 0.0, "total": 0.0}
    return {
        "count": len(values),
        "mean": round(statistics.mean(values), 3),
        "median": round(statistics.median(values), 3),
        "min": round(min(values), 3),
        "max": round(max(values), 3),
        "total": round(sum(values), 3),
    }


def summarize_battery_results(
    round_records: list[RoundRecord],
    model_key: str,
    seed: Optional[int],
    max_fix_attempts: int,
    total_battery_wall_s: float,
) -> dict[str, Any]:
    total_rounds = len(round_records)
    lean_wall_times = [r.lean_wall_time_s for r in round_records]
    lean_llm_times = [r.lean_llm_time_s for r in round_records]
    round_wall_times = [r.total_round_wall_time_s for r in round_records]

    initial_pass_count = sum(1 for r in round_records if r.initial_valid)
    autofix_triggered_count = sum(1 for r in round_records if r.auto_fix_triggered)
    total_autofix_calls = sum(r.auto_fix_attempts_used for r in round_records)
    recovered_attempt_1 = sum(1 for r in round_records if r.resolved_on_attempt == 1)
    recovered_attempt_2 = sum(1 for r in round_records if r.resolved_on_attempt == 2)
    fallback_count = sum(1 for r in round_records if r.fallback_triggered)
    final_valid_count = sum(1 for r in round_records if r.final_valid)

    all_fix_wall_times = [
        fa.wall_time_s for r in round_records for fa in r.fix_attempts
    ]

    design_rounds = [r for r in round_records if r.mode == "design"]
    design_cleanups_required = sum(1 for r in design_rounds if r.design_cleanup_required)
    design_cleanups_applied = sum(1 for r in design_rounds if r.design_cleanup_applied)

    per_mode: dict[str, Any] = {}
    for m in XAPPEND_MODES:
        m_rounds = [r for r in round_records if r.mode == m]
        per_mode[m] = {
            "rounds": len(m_rounds),
            "lean_wall_time_s": _numeric_stats([r.lean_wall_time_s for r in m_rounds]),
            "lean_llm_time_s": _numeric_stats([r.lean_llm_time_s for r in m_rounds]),
            "total_round_wall_time_s": _numeric_stats([r.total_round_wall_time_s for r in m_rounds]),
            "initial_pass_count": sum(1 for r in m_rounds if r.initial_valid),
            "initial_pass_rate": round(
                sum(1 for r in m_rounds if r.initial_valid) / len(m_rounds), 3
            ) if m_rounds else 0.0,
            "auto_fix_triggered_rounds": sum(1 for r in m_rounds if r.auto_fix_triggered),
            "auto_fix_total_calls": sum(r.auto_fix_attempts_used for r in m_rounds),
            "recovered_on_attempt_1": sum(1 for r in m_rounds if r.resolved_on_attempt == 1),
            "recovered_on_attempt_2": sum(1 for r in m_rounds if r.resolved_on_attempt == 2),
            "fallback_count": sum(1 for r in m_rounds if r.fallback_triggered),
            "final_valid_count": sum(1 for r in m_rounds if r.final_valid),
            "mean_code_chars": round(
                statistics.mean([r.code_chars for r in m_rounds]), 1
            ) if m_rounds else 0.0,
            "design_cleanups_applied": sum(1 for r in m_rounds if r.design_cleanup_applied),
        }

    return {
        "model": model_key,
        "seed": seed,
        "total_rounds": total_rounds,
        "max_fix_attempts_per_round": max_fix_attempts,
        "total_battery_wall_time_s": round(total_battery_wall_s, 3),
        "lean_prompt_wall_time_s": _numeric_stats(lean_wall_times),
        "lean_prompt_llm_time_s": _numeric_stats(lean_llm_times),
        "round_total_wall_time_s": _numeric_stats(round_wall_times),
        "auto_fix_summary": {
            "rounds_triggered": autofix_triggered_count,
            "total_fix_calls": total_autofix_calls,
            "recovered_on_attempt_1": recovered_attempt_1,
            "recovered_on_attempt_2": recovered_attempt_2,
            "exhausted_to_fallback": fallback_count,
            "fix_call_wall_time_s": _numeric_stats(all_fix_wall_times),
        },
        "validation_summary": {
            "initial_pass_count": initial_pass_count,
            "initial_pass_rate": round(initial_pass_count / total_rounds, 3) if total_rounds else 0.0,
            "post_autofix_pass_count": initial_pass_count + recovered_attempt_1 + recovered_attempt_2,
            "post_autofix_pass_rate": round(
                (initial_pass_count + recovered_attempt_1 + recovered_attempt_2) / total_rounds, 3
            ) if total_rounds else 0.0,
            "final_valid_count": final_valid_count,
            "final_valid_rate": round(final_valid_count / total_rounds, 3) if total_rounds else 0.0,
        },
        "design_cleanup_summary": {
            "design_rounds": len(design_rounds),
            "cleanups_required": design_cleanups_required,
            "cleanups_applied": design_cleanups_applied,
        },
        "per_mode": per_mode,
        "rounds": [asdict(r) for r in round_records],
    }


def format_battery_markdown_report(summary: dict[str, Any]) -> str:
    """Format the 20-round battery summary as a Markdown report."""
    lines = [
        "# X-Append Lean Prompt Stress Test Report (20 Rounds + 2-Round Auto-Fix)",
        "",
        f"- **Model**: `{summary['model']}`",
        f"- **Seed**: `{summary['seed']}`",
        f"- **Total Rounds**: `{summary['total_rounds']}` (4 modes × 5 rounds)",
        f"- **Max Auto-Fix Attempts / Round**: `{summary['max_fix_attempts_per_round']}`",
        f"- **Total Battery Wall Time**: `{summary['total_battery_wall_time_s']:.2f}s`",
        f"- **Initial 1st-Try Pass Rate**: `{summary['validation_summary']['initial_pass_count']}/{summary['total_rounds']}` (`{summary['validation_summary']['initial_pass_rate'] * 100:.1f}%`)",
        f"- **Post-Auto-Fix Pass Rate**: `{summary['validation_summary']['post_autofix_pass_count']}/{summary['total_rounds']}` (`{summary['validation_summary']['post_autofix_pass_rate'] * 100:.1f}%`)",
        f"- **Auto-Fix Calls**: `{summary['auto_fix_summary']['total_fix_calls']}` across `{summary['auto_fix_summary']['rounds_triggered']}` round(s) (Attempt 1 recoveries: `{summary['auto_fix_summary']['recovered_on_attempt_1']}`, Attempt 2 recoveries: `{summary['auto_fix_summary']['recovered_on_attempt_2']}`, Fallbacks: `{summary['auto_fix_summary']['exhausted_to_fallback']}`)",
        f"- **Design Synthesizer Cleanups Applied**: `{summary['design_cleanup_summary']['cleanups_applied']}/{summary['design_cleanup_summary']['cleanups_required']}` subsequent design round(s)",
        "",
        "## Per-Mode Timing & Behavior",
        "",
        "| Mode | Rounds | Mean Lean Time (s) | Median (s) | Min (s) | Max (s) | 1st-Try Pass | Auto-Fix Triggered | Fix #1 OK | Fix #2 OK | Fallback | Design Cleanups |",
        "| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |",
    ]
    for m in XAPPEND_MODES:
        pm = summary["per_mode"][m]
        lt = pm["lean_wall_time_s"]
        lines.append(
            f"| `{m}` | {pm['rounds']} | {lt['mean']:.2f}s | {lt['median']:.2f}s | "
            f"{lt['min']:.2f}s | {lt['max']:.2f}s | {pm['initial_pass_count']}/{pm['rounds']} | "
            f"{pm['auto_fix_triggered_rounds']} ({pm['auto_fix_total_calls']} calls) | "
            f"{pm['recovered_on_attempt_1']} | {pm['recovered_on_attempt_2']} | "
            f"{pm['fallback_count']} | {pm['design_cleanups_applied']} |"
        )

    lines.extend([
        "",
        "## Round-by-Round Execution Log",
        "",
        "| Round | Mode | Frag # | Category | Lean (s) | 1st Val | Auto-Fix Used | Resolution | Design Cleanup | Chars |",
        "| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |",
    ])
    for r in summary["rounds"]:
        res_label = (
            "1st Try OK"
            if r["resolved_on_attempt"] == 0
            else (
                f"Auto-Fix #{r['resolved_on_attempt']}"
                if r["resolved_on_attempt"] > 0
                else "Failsafe Fallback"
            )
        )
        lines.append(
            f"| {r['round_index']:02d} | `{r['mode']}` (#{r['mode_occurrence']}) | "
            f"#{r['fragment_id']} | `{r['fragment_category']}` | {r['lean_wall_time_s']:.2f}s | "
            f"{'PASS' if r['initial_valid'] else 'FAIL'} | {r['auto_fix_attempts_used']} | "
            f"{res_label} | {'Yes' if r['design_cleanup_applied'] else 'No'} | {r['code_chars']} |"
        )
    lines.append("")
    return "\n".join(lines)


# ============================================================================
# 6. Pytest Automated Unit & Integration Tests
# ============================================================================

def test_ptbr_corpus_has_80_paragraph_fragments():
    """Verify the 80-fragment Brazilian Portuguese corpus structure and content."""
    corpus = load_ptbr_corpus()
    fragments = corpus["fragments"]
    assert len(fragments) == 80

    ids = [f["id"] for f in fragments]
    assert ids == list(range(1, 81)), "Fragment IDs must be 1..80"

    categories = {}
    for frag in fragments:
        cat = frag["category"]
        categories[cat] = categories.get(cat, 0) + 1
        text = frag["text"].strip()
        # Paragraph-length check (substantial multi-sentence pt-BR paragraph)
        assert len(text) >= 180, f"Fragment #{frag['id']} is too short ({len(text)} chars)"
        assert len(text.split()) >= 25, f"Fragment #{frag['id']} has too few words"
        assert frag.get("source"), f"Fragment #{frag['id']} missing source"

    assert categories == {
        "wikipedia": 20,
        "poema": 20,
        "conto_cronica": 20,
        "descricao_imagem": 20,
    }


def test_20_round_battery_schedule_sampling_and_design_cleanup_flags():
    """Verify 4 modes x 5 rounds = 20 distinct fragments and design cleanup marking."""
    corpus = load_ptbr_corpus()
    schedule = build_20_round_battery_schedule(corpus["fragments"], rounds_per_mode=5, seed=123)

    assert len(schedule) == 20
    frag_ids = [item["fragment_id"] for item in schedule]
    assert len(set(frag_ids)) == 20, "All 20 rounds must use distinct fragments from the 80-corpus"

    for m in XAPPEND_MODES:
        m_items = [item for item in schedule if item["mode"] == m]
        assert len(m_items) == 5, f"Mode {m} must appear exactly 5 times in a 20-round battery"

    design_items = [item for item in schedule if item["mode"] == "design"]
    assert design_items[0]["requires_design_cleanup"] is False, (
        "First design round must NOT require cleaning up a previous design synth"
    )
    for subsequent in design_items[1:]:
        assert subsequent["requires_design_cleanup"] is True, (
            "Subsequent design rounds (2..5) MUST require cleaning up the previous design synth"
        )


def test_design_synthesizer_cleanup_injection_and_session_tracking(monkeypatch):
    """
    Verify that when a `design` use case runs after another `design` has already run:
      1. The 1st `design` call does NOT inject pre-design cleanup.
      2. The 2nd `design` call automatically injects `DESIGN_PRE_CLEANUP_MARKER` at the
         top of the single `(...)` block while keeping top-level `var` declarations valid.
    """
    class MockDesignLLM:
        def __init__(self, provider, model_name):
            pass

        def generate(self, user_prompt, sys_prompt="", temperature=0.7, thinking_budget=0):
            return (
                "(\n"
                "var customVar = 440;\n"
                "MIDIClient.init;\n"
                "~myInDevice = MIDIClient.sources.detect { |src| src.device == \"loopMIDI Port\" };\n"
                "if(~myInDevice.notNil) { MIDIIn.connect(0, ~myInDevice); ~myUid = ~myInDevice.uid; } { ~myUid = nil; };\n"
                "s.waitForBoot({\n"
                "    ~synthGroup = Group.new(s);\n"
                "    ~fxGroup = Group.after(~synthGroup);\n"
                "    ~buses = IdentityDictionary.new;\n"
                "    ~notes = Array.newClear(128);\n"
                "});\n"
                ")",
                {"time_s": 1.25, "in_tokens": 500, "out_tokens": 200, "cost": 0.001},
            )

    import llm_engine
    monkeypatch.setattr(llm_engine, "LLMClient", MockDesignLLM)
    monkeypatch.setattr(gui_backend, "_resolve_model", lambda k: ("openrouter", "google/gemini-3.8-flash"))
    monkeypatch.setattr(gui_backend.utils, "append_to_session_log", lambda *a, **kw: None)

    state_file = "__test_design_session__.scd"
    gui_backend._design_ran_in_session.pop(state_file, None)

    # 1st Design run: no previous design has run yet
    res1 = gui_backend.cmd_cross_append({
        "mode": "design",
        "lean_prompt": True,
        "use_kb": False,
        "prompt": "Primeiro sintetizador",
        "active_file": state_file,
    })
    assert res1["design_cleanup_applied"] is False
    assert DESIGN_PRE_CLEANUP_MARKER not in res1["code"]

    # 2nd Design run: previous design HAS run -> must inject pre-design cleanup
    res2 = gui_backend.cmd_cross_append({
        "mode": "design",
        "lean_prompt": True,
        "use_kb": False,
        "prompt": "Segundo sintetizador",
        "active_file": state_file,
    })
    assert res2["design_cleanup_applied"] is True
    assert DESIGN_PRE_CLEANUP_MARKER in res2["code"]
    assert "MIDIdef.freeAll" in res2["code"]
    assert "~synthGroup = nil" in res2["code"]
    assert "~buses = nil" in res2["code"]
    _, fixes = validate_and_fix(res2["code"])
    assert "WARNING: brackets are unbalanced" not in fixes


def test_20_round_battery_with_2_round_autofix_and_design_cleanup(monkeypatch):
    """
    Simulate a complete 20-round X-Append Lean Prompt battery (4 modes x 5 rounds)
    with 2 rounds of Auto-Fix, exercising:
      - Immediate 1st-try pass rounds
      - Round failing initially and recovering on Auto-Fix Attempt 1
      - Round failing initially + Attempt 1 and recovering on Auto-Fix Attempt 2
      - Round exhausting both Auto-Fix attempts (1 and 2) and triggering RAG/Design fallback
      - Pre-Design cleanup across the 5 `design` rounds (rounds 2..5 cleaned up)
    """
    call_state = {"round_counter": 0}

    class SimulatedBatteryLLM:
        def __init__(self, provider, model_name):
            self.provider = provider
            self.model_name = model_name

        def generate(self, user_prompt, sys_prompt="", temperature=0.7, thinking_budget=0):
            # Is this a cmd_fix call?
            if user_prompt.startswith("CODE BLOCK:\n"):
                if "BROKEN_NEEDS_1_FIX" in user_prompt:
                    return (
                        "(\nNdef(\\fixedOnOne, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play;\n)",
                        {"time_s": 0.45, "in_tokens": 400, "out_tokens": 80, "cost": 0.0004},
                    )
                if "BROKEN_NEEDS_2_FIXES_STAGE1" in user_prompt:
                    # Still broken after Fix Attempt 1
                    return (
                        "(\n// BROKEN_NEEDS_2_FIXES_STAGE2\nNdef(\\stillBroken, { UndefinedUGenXYZ.ar(220) }).play;\n)",
                        {"time_s": 0.50, "in_tokens": 420, "out_tokens": 90, "cost": 0.0005},
                    )
                if "BROKEN_NEEDS_2_FIXES_STAGE2" in user_prompt:
                    # Repaired on Fix Attempt 2!
                    return (
                        "(\nNdef(\\fixedOnTwo, { Pan2.ar(SinOsc.ar(330) * 0.1, 0) }).play;\n)",
                        {"time_s": 0.55, "in_tokens": 430, "out_tokens": 95, "cost": 0.0005},
                    )
                if "BROKEN_UNFIXABLE" in user_prompt:
                    return (
                        "(\n// BROKEN_UNFIXABLE\nNdef(\\unfixable, { UndefinedUGenXYZ.ar(110) }).play;\n)",
                        {"time_s": 0.60, "in_tokens": 450, "out_tokens": 90, "cost": 0.0005},
                    )

            call_state["round_counter"] += 1
            idx = call_state["round_counter"]

            # Inject controlled failures on specific rounds to test 1-fix, 2-fix, and fallback
            if idx == 3:
                return (
                    "(\n// BROKEN_NEEDS_1_FIX\nNdef(\\bad1, { UndefinedUGenXYZ.ar(220) }).play;\n)",
                    {"time_s": 0.80, "in_tokens": 900, "out_tokens": 150, "cost": 0.001},
                )
            if idx == 7:
                return (
                    "(\n// BROKEN_NEEDS_2_FIXES_STAGE1\nNdef(\\bad2, { UndefinedUGenXYZ.ar(220) }).play;\n)",
                    {"time_s": 0.85, "in_tokens": 920, "out_tokens": 160, "cost": 0.001},
                )
            if idx == 12:
                return (
                    "(\n// BROKEN_UNFIXABLE\nNdef(\\bad3, { UndefinedUGenXYZ.ar(220) }).play;\n)",
                    {"time_s": 0.90, "in_tokens": 950, "out_tokens": 170, "cost": 0.001},
                )

            return (
                f"(\nNdef(\\layer_{idx}, {{ Pan2.ar(SinOsc.ar({110 + idx * 15}) * 0.1, 0) }}).play;\n"
                f"Pbindef(\\seq_{idx}, \\dur, 0.5, \\t_trig, 1);\n"
                f"Ndef(\\layer_{idx})[1] = \\set -> Pbindef(\\seq_{idx});\n)",
                {"time_s": 0.75, "in_tokens": 850, "out_tokens": 180, "cost": 0.001},
            )

    class MockValidator:
        def __init__(self):
            self.cleanup_calls = 0

        def run_design_cleanup(self):
            self.cleanup_calls += 1
            return True, 0.01

        def validate_code(self, code: str, mode: str = "append"):
            if "UndefinedUGenXYZ" in code:
                return False, "ERROR: Class not defined: UndefinedUGenXYZ", 0.02
            return True, "", 0.02

    import llm_engine
    monkeypatch.setattr(llm_engine, "LLMClient", SimulatedBatteryLLM)
    monkeypatch.setattr(gui_backend, "_resolve_model", lambda k: ("openrouter", "google/gemini-3.8-flash"))
    monkeypatch.setattr(
        gui_backend,
        "_rag_failsafe_lookup",
        lambda p: "(\nNdef(\\ragFallback, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play;\n)",
    )
    monkeypatch.setattr(gui_backend.utils, "append_to_session_log", lambda *a, **kw: None)

    mock_val = MockValidator()
    summary = run_xappend_lean_battery(
        model_key="Gemini 3.8 Flash (OpenRouter)",
        seed=77,
        rounds_per_mode=5,
        max_fix_attempts=2,
        use_kb=False,
        validator=mock_val,
        verbose=False,
    )

    assert summary["total_rounds"] == 20
    for m in XAPPEND_MODES:
        assert summary["per_mode"][m]["rounds"] == 5

    # Check Auto-Fix accounting:
    # - Round 3: failed initially -> 1 auto-fix call -> recovered on attempt 1
    # - Round 7: failed initially -> 2 auto-fix calls -> recovered on attempt 2
    # - Round 12: failed initially -> 2 auto-fix calls -> exhausted -> fallback
    af = summary["auto_fix_summary"]
    assert af["rounds_triggered"] == 3
    assert af["total_fix_calls"] == 5  # 1 + 2 + 2
    assert af["recovered_on_attempt_1"] == 1
    assert af["recovered_on_attempt_2"] == 1
    assert af["exhausted_to_fallback"] == 1

    vs = summary["validation_summary"]
    assert vs["initial_pass_count"] == 17
    assert vs["post_autofix_pass_count"] == 19
    assert vs["final_valid_count"] == 20

    # Check Design synthesizer cleanup: 5 design rounds -> 1st needs no cleanup, 4 subsequent rounds cleaned up
    dc = summary["design_cleanup_summary"]
    assert dc["design_rounds"] == 5
    assert dc["cleanups_required"] == 4
    assert dc["cleanups_applied"] == 4
    assert mock_val.cleanup_calls == 4


def test_sclang_parallel_validator_and_design_cleanup_live():
    """
    If `sclang` is installed on this machine, verify live compilation & execution
    of consecutive `design` synthesizers with pre-design cleanup in between while
    preserving an existing `append` Ndef layer.
    """
    sclang_bin = find_sclang_executable()
    if not sclang_bin:
        import pytest
        pytest.skip("sclang executable not found on this machine")

    val = SclangParallelValidator(sclang_path=sclang_bin, udp_port=57139)
    try:
        assert val.start(), "Failed to start sclang parallel validation interpreter"

        # 1. Run an append layer
        append_code = "(\nNdef(\\bgDrone, { Pan2.ar(SinOsc.ar(110) * 0.05, 0) }).play;\n)"
        ok, err, _ = val.validate_code(append_code, mode="append")
        assert ok, f"Append validation failed: {err}"

        # 2. Run 1st design synth
        design_1 = (
            "(\n"
            "s.waitForBoot({\n"
            "    ~synthGroup = Group.new(s);\n"
            "    ~fxGroup = Group.after(~synthGroup);\n"
            "    ~buses = IdentityDictionary[\n"
            "        \\cutoff -> Bus.control(s, 1).set(1200)\n"
            "    ];\n"
            "    ~notes = Array.newClear(128);\n"
            "    MIDIdef.noteOn(\\d1On, { |vel, num| [vel, num].postln });\n"
            "});\n"
            ")"
        )
        ok1, err1, _ = val.validate_code(design_1, mode="design")
        assert ok1, f"1st Design validation failed: {err1}"

        # 3. Run 2nd design synth with pre-design cleanup prepended
        design_2_raw = (
            "(\n"
            "var baseCutoff = 800;\n"
            "s.waitForBoot({\n"
            "    ~synthGroup = Group.new(s);\n"
            "    ~fxGroup = Group.after(~synthGroup);\n"
            "    ~buses = IdentityDictionary[\n"
            "        \\cutoff -> Bus.control(s, 1).set(baseCutoff)\n"
            "    ];\n"
            "    ~zoneNotes = Array.fill(4, { Array.newClear(128) });\n"
            "    MIDIdef.noteOn(\\d2On, { |vel, num| [vel, num].postln });\n"
            "});\n"
            ")"
        )
        design_2_clean, _ = normalize_for_xappend(
            design_2_raw, mode="design", cleanup_previous_design=True
        )
        assert DESIGN_PRE_CLEANUP_MARKER in design_2_clean
        ok2, err2, _ = val.validate_code(design_2_clean, mode="design")
        assert ok2, f"2nd Design with pre-cleanup validation failed: {err2}"
    finally:
        val.stop()


# ============================================================================
# 7. CLI Entry Point
# ============================================================================

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run the 20-round X-Append Lean Prompt + 2-round Auto-Fix stress test battery."
    )
    parser.add_argument(
        "--model",
        default="openrouter:google/gemini-3.8-flash",
        help="Model key from config.AVAILABLE_MODELS or openrouter:google/gemini-3.8-flash (default: 'openrouter:google/gemini-3.8-flash')",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Random seed for sampling 20 fragments from the 80-fragment pt-BR corpus (default: 42)",
    )
    parser.add_argument(
        "--rounds-per-mode",
        type=int,
        default=DEFAULT_ROUNDS_PER_MODE,
        help="Number of rounds per X-Append mode (default: 5 -> 20 rounds total)",
    )
    parser.add_argument(
        "--max-fix-attempts",
        type=int,
        default=DEFAULT_MAX_FIX_ATTEMPTS,
        help="Maximum Auto-Fix attempts per failed round (default: 2)",
    )
    parser.add_argument(
        "--use-kb",
        action="store_true",
        default=False,
        help="Enable RAG knowledge base lookup during lean prompt generation",
    )
    parser.add_argument(
        "--temp",
        type=float,
        default=None,
        help="Optional LLM temperature override",
    )
    parser.add_argument(
        "--outdir",
        default=os.path.join(SCRIPT_DIR, "xappend_lean_stress_output"),
        help="Directory to write session .scd, JSON report, and Markdown report",
    )
    args = parser.parse_args()

    summary = run_xappend_lean_battery(
        model_key=args.model,
        seed=args.seed,
        rounds_per_mode=args.rounds_per_mode,
        max_fix_attempts=args.max_fix_attempts,
        use_kb=args.use_kb,
        temperature=args.temp,
        outdir=args.outdir,
        verbose=True,
    )

    print("\n" + "=" * 78)
    print(format_battery_markdown_report(summary))
    print("=" * 78)
    print(f"Reports saved to: {args.outdir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
