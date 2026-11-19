import json
import os
import sys
from pathlib import Path

import pytest

# Ensure sc-gen-rag is importable
SC_GEN_RAG_DIR = str(Path(__file__).resolve().parent.parent)
if SC_GEN_RAG_DIR not in sys.path:
    sys.path.insert(0, SC_GEN_RAG_DIR)

import code_validator
import config
import gui_backend
import rag_engine
import utils


SAMPLE_APPEND = """
(
// ADD_INSTRUMENT: Ndef(\\oceanPad)
Ndef(\\oceanPad, { |freq=110, amp=0.2, pan=0, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.05, 1.2), t_trig);
    var sig = Saw.ar(freq) * env * amp;
    Pan2.ar(LPF.ar(sig, 1200), pan);
}).play;

Ndef(\\oceanPad)[1] = \\set -> Pbindef(\\oceanPadSeq,
    \\dur, 1.0,
    \\freq, Pseq([110, 130.81], inf),
    \\t_trig, 1
);
)
// Pbindef(\\oceanPadSeq).stop; Ndef(\\oceanPad).fadeTime = 2; Ndef(\\oceanPad).clear(2); // Rollback: remove this instrument
"""

SAMPLE_GENERATE = """
// --- OCEAN INSTRUMENTS ---
(
Ndef(\\subSwell, { |freq=55, amp=0.25, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.2, 2.0), t_trig);
    Pan2.ar(SinOsc.ar(freq) * env * amp, 0);
}).play;
)

(
Ndef(\\foamSpray, { |freq=2400, amp=0.12, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.02, 0.4), t_trig);
    var sig = BPF.ar(WhiteNoise.ar, freq, 0.1) * 4.0;
    Pan2.ar(sig * env * amp, 0.2);
}).play;
)

// --- OCEAN EFFECTS ---
(
Ndef(\\subSwell)[10] = \\filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.8, 0.3) };
Ndef(\\subSwell).set(\\wet10, 0.35);
)

// --- OCEAN SEQUENCES ---
(
Pbindef(\\subSeq, \\dur, 2.0, \\freq, 55, \\t_trig, 1);
Ndef(\\subSwell)[1] = \\set -> Pbindef(\\subSeq);
Pbindef(\\foamSeq, \\dur, 0.5, \\freq, Pwhite(1800, 3200, inf), \\t_trig, 1);
Ndef(\\foamSpray)[1] = \\set -> Pbindef(\\foamSeq);
)

// Ending fade out
(
Pbindef(\\subSeq).stop;
Pbindef(\\foamSeq).stop;
Ndef(\\subSwell).clear(4);
Ndef(\\foamSpray).clear(4);
)
"""

SAMPLE_COMPOSE = """
(
s.waitForBoot({
    ~enableRecording = false;
    if(~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\\safetyLimiter, {
        var sig = In.ar(0, 2);
        ReplaceOut.ar(0, Limiter.ar(LeakDC.ar(sig), 0.85, 0.01));
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \\safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \\safetyLimiter) };

    SynthDef(\\pulsePing, { |out=0, freq=440, amp=0.2|
        var env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction: 2);
        Out.ar(out, Pan2.ar(SinOsc.ar(freq) * env * amp, 0));
    }).add;
    s.sync;

    Ndef(\\masterMix, { In.ar(~synthBus, 2) }).play;
    s.sync;

    Tdef(\\masterScore, {
        0.5.wait;
        Pbindef(\\pingSeq, \\instrument, \\pulsePing, \\out, ~synthBus, \\dur, 0.25, \\freq, 440).play;
        2.wait;
        Pbindef(\\pingSeq).stop; Pbindef(\\pingSeq).clear;
        Ndef(\\masterMix).clear(1);
        Tdef(\\masterScore).stop;
    });
    Tdef(\\masterScore).play;
});
)
"""

SAMPLE_DESIGN = """
(
~cc = (vol1: 0, lpf1: 1, panic: 120);
)
(
if(MIDIClient.initialized.not) { MIDIClient.init };
~myUid = nil;
)
(
s.waitForBoot({
    ~ccVals = (vol1: 0.3, lpf1: 4000, min1: 0, max1: 127);
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    SynthDef(\\z1_Lead, { |out=0, freq=440, gate=1, vol=0.3, lpf=4000|
        var env = EnvGen.kr(Env.adsr(0.01, 0.2, 0.7, 0.3), gate, doneAction: 2);
        var sig = RLPF.ar(Saw.ar(freq), lpf, 0.3);
        Out.ar(out, Pan2.ar(sig * env * vol, 0));
    }).add;
    s.sync;

    ~notes = Array.newClear(128);
    MIDIdef.noteOn(\\leadOn, { |vel, noteNum|
        if((noteNum >= ~ccVals[\\min1]) and: { noteNum <= ~ccVals[\\max1] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\\z1_Lead, [\\freq, noteNum.midicps, \\vol, ~buses.vol1.asMap, \\lpf, ~buses.lpf1.asMap], ~synthGroup));
        };
    }, srcID: ~myUid);

    defer {
        ~mainWin = Window("Test Synth", Rect(100, 100, 300, 200));
        ~ui = ();
        ~ui[\\vol1] = EZSlider(~mainWin, 280@30, "Vol (CC 0)", \\amp, { |sl| ~buses.vol1.set(sl.value) }, 0.3);
        ~mainWin.front;
    };
});
)
// STEP 5: CLEANUP
(
if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
MIDIdef.freeAll;
~synthGroup.free;
)
"""


def test_classify_sc_block_modes():
    assert code_validator.classify_sc_block(SAMPLE_APPEND)["mode"] == "append"
    assert code_validator.classify_sc_block(SAMPLE_GENERATE)["mode"] == "generate"
    assert code_validator.classify_sc_block(SAMPLE_COMPOSE)["mode"] == "compose"
    assert code_validator.classify_sc_block(SAMPLE_DESIGN)["mode"] == "design"


def test_classify_rejects_teardown_and_failsafe():
    teardown = "(\nPbindef(\\foo).stop;\nNdef(\\foo).clear(2);\n)"
    res_td = code_validator.classify_sc_block(teardown, hint_mode="append")
    assert res_td["is_rag_eligible"] is False

    fb = "// [FAILSAFE APPLIED]\n(\nNdef(\\x, { Pan2.ar(SinOsc.ar(220), 0) }).play;\n)"
    res_fb = code_validator.classify_sc_block(fb, hint_mode="append")
    assert res_fb["is_rag_eligible"] is False


def test_extract_executable_rag_blocks_strips_teardown_and_keeps_parens():
    gen_blocks = code_validator.extract_executable_rag_blocks(SAMPLE_GENERATE, mode="generate")
    assert len(gen_blocks) == 4
    for blk in gen_blocks:
        assert blk.startswith("(") and blk.endswith(")")
        assert "Ndef(\\subSwell).clear" not in blk

    design_blocks = code_validator.extract_executable_rag_blocks(SAMPLE_DESIGN, mode="design")
    assert len(design_blocks) == 3
    for blk in design_blocks:
        assert "STEP 5: CLEANUP" not in blk
        assert "MIDIdef.freeAll" not in blk


def test_extract_unpacks_consolidated_closures():
    consolidated = (
        "(\n"
        "{\nNdef(\\a, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play;\n}.value;\n\n"
        "{\nNdef(\\b, { Pan2.ar(Saw.ar(110) * 0.1, 0) }).play;\n}.value;\n"
        ")"
    )
    blocks = code_validator.extract_executable_rag_blocks(consolidated, mode="generate")
    assert len(blocks) == 2
    assert "Ndef(\\a" in blocks[0]
    assert "Ndef(\\b" in blocks[1]


def test_verify_blocks_with_sclang_scval():
    sclang_exe = code_validator._find_sclang_executable()
    if not sclang_exe:
        pytest.skip("sclang.exe not found on this machine")

    valid_entry = {
        "detected_mode": "append",
        "val_server_verified": False,
        "executable_blocks": [
            "(\nNdef(\\testValid, { Pan2.ar(SinOsc.ar(220) * 0.05, 0) }).play;\n)"
        ],
    }
    broken_entry = {
        "detected_mode": "append",
        "val_server_verified": False,
        "executable_blocks": [
            "(\nvar x = 1;\nx = x + 1;\nvar y = 2;\n)"  # var after statement -> syntax error
        ],
    }
    verified = code_validator.verify_blocks_with_sclang_scval([valid_entry, broken_entry], sclang_path=sclang_exe)
    assert len(verified) == 1
    assert verified[0]["val_server_verified"] is True


def test_prepare_queue_and_shutdown_rag_ingestion(tmp_path, monkeypatch):
    kb_dir = tmp_path / "knowledge_base"
    logs_dir = tmp_path / "use-logs"
    db_dir = tmp_path / "vectordb"
    kb_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)

    monkeypatch.setattr(config, "CONTEXT_FOLDER", str(kb_dir))
    monkeypatch.setattr(config, "KNOWLEDGE_DB_PATH", str(db_dir))
    monkeypatch.setattr(utils, "LOGS_DIR", str(logs_dir))

    # Avoid actually running Google Docs sync during test shutdown
    monkeypatch.setattr(utils, "finalize_session_log", lambda process_fixes: "test_session.md")

    prep = gui_backend.cmd_prepare_rag_block({"code": SAMPLE_COMPOSE, "mode": "compose"})
    assert prep["is_rag_eligible"] is True
    assert prep["detected_mode"] == "compose"
    assert len(prep["executable_blocks"]) == 1

    q_res = gui_backend.cmd_queue_rag_block({
        "code": SAMPLE_COMPOSE,
        "prompt": "Minimalist pulse score",
        "origin_mode": "compose",
        "detected_mode": prep["detected_mode"],
        "executable_blocks": prep["executable_blocks"],
        "val_server_verified": True,
        "active_file": "test.scd",
    })
    assert q_res["status"] == "queued"
    assert q_res["num_chunks"] >= 1

    # Duplicate check
    q_dup = gui_backend.cmd_queue_rag_block({
        "code": SAMPLE_COMPOSE,
        "prompt": "Minimalist pulse score",
        "origin_mode": "compose",
        "detected_mode": prep["detected_mode"],
        "executable_blocks": prep["executable_blocks"],
        "val_server_verified": True,
    })
    assert q_dup["status"] == "duplicate"

    # Trigger shutdown ingestion
    save_res = gui_backend.cmd_save_session_log({
        "process_fixes": False,
        "process_rag_blocks": True,
    })
    assert save_res["rag_summary"]["processed"] == 1
    assert save_res["rag_summary"]["chunks_added"] >= 1
    assert (kb_dir / "failsafe-compose.scd").exists()
    assert not (logs_dir / ".pending_rag_blocks.json").exists()

    # Verify mode-specific lookup finds the newly ingested compose block
    rag_engine._cached_db = None
    found = gui_backend._rag_failsafe_lookup("Minimalist pulse score", mode="compose")
    assert "pulsePing" in found


def test_session_end_automatic_job_all_four_modes_and_correct_failsafes(tmp_path, monkeypatch):
    """Verify the automatic session-end job feeds all 4 failsafe-<mode>.scd files
    and that cmd_rag_lookup / _design_failsafe_lookup apply the right failsafe per use case."""
    kb_dir = tmp_path / "knowledge_base"
    logs_dir = tmp_path / "use-logs"
    db_dir = tmp_path / "vectordb"
    kb_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)

    monkeypatch.setattr(config, "CONTEXT_FOLDER", str(kb_dir))
    monkeypatch.setattr(config, "KNOWLEDGE_DB_PATH", str(db_dir))
    monkeypatch.setattr(utils, "LOGS_DIR", str(logs_dir))
    monkeypatch.setattr(utils, "finalize_session_log", lambda process_fixes: "test_session_all.md")

    # 1. Design fallback when failsafe-design.scd does not exist yet -> subtractive synth
    sub_fb = gui_backend.cmd_rag_lookup({"prompt": "acid lead", "mode": "design"})
    assert "Ndef(\\subtractiveDesign" in sub_fb["code"]

    # 2. Queue one verified block for each of the 4 use cases
    cases = [
        ("append", "Ocean pad texture", SAMPLE_APPEND, "oceanPad"),
        ("generate", "Ocean waves and foam spray", SAMPLE_GENERATE, "subSwell"),
        ("compose", "Minimalist pulse score", SAMPLE_COMPOSE, "pulsePing"),
        ("design", "Multitimbral MIDI lead synth", SAMPLE_DESIGN, "z1_Lead"),
    ]
    for hint_mode, prompt, code, _ in cases:
        prep = gui_backend.cmd_prepare_rag_block({"code": code, "mode": hint_mode})
        assert prep["is_rag_eligible"] is True
        assert prep["detected_mode"] == hint_mode
        q_res = gui_backend.cmd_queue_rag_block({
            "code": code,
            "prompt": prompt,
            "origin_mode": hint_mode,
            "detected_mode": prep["detected_mode"],
            "executable_blocks": prep["executable_blocks"],
            "val_server_verified": True,
            "active_file": f"{hint_mode}_session.scd",
        })
        assert q_res["status"] == "queued"

    # 3. Run the automatic shutdown job with process_rag_blocks=True
    rag_engine._cached_db = None
    save_res = gui_backend.cmd_save_session_log({
        "process_fixes": False,
        "process_rag_blocks": True,
    })
    assert save_res["rag_summary"]["processed"] == 4
    assert save_res["rag_summary"]["chunks_added"] >= 4
    assert not (logs_dir / ".pending_rag_blocks.json").exists()

    for mode, _, _, expected_symbol in cases:
        rag_file = kb_dir / f"failsafe-{mode}.scd"
        assert rag_file.exists(), f"Expected {rag_file} to be created"
        text = rag_file.read_text(encoding="utf-8")
        assert f"// MODE: {mode}" in text
        assert expected_symbol in text

    # 4. Verify cmd_rag_lookup retrieves the mode-specific failsafe for each use case
    rag_engine._cached_db = None
    for mode, prompt, _, expected_symbol in cases:
        res = gui_backend.cmd_rag_lookup({"prompt": prompt, "mode": mode})
        assert expected_symbol in res["code"], f"Expected {expected_symbol} for mode={mode}, got: {res['code'][:120]}"


def test_session_end_decline_cleans_up_queue(tmp_path, monkeypatch):
    kb_dir = tmp_path / "knowledge_base"
    logs_dir = tmp_path / "use-logs"
    db_dir = tmp_path / "vectordb"
    kb_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)

    monkeypatch.setattr(config, "CONTEXT_FOLDER", str(kb_dir))
    monkeypatch.setattr(config, "KNOWLEDGE_DB_PATH", str(db_dir))
    monkeypatch.setattr(utils, "LOGS_DIR", str(logs_dir))
    monkeypatch.setattr(utils, "finalize_session_log", lambda process_fixes: "test_decline.md")

    gui_backend.cmd_queue_rag_block({
        "code": SAMPLE_APPEND,
        "prompt": "Ocean pad",
        "origin_mode": "append",
        "val_server_verified": True,
    })
    assert (logs_dir / ".pending_rag_blocks.json").exists()

    save_res = gui_backend.cmd_save_session_log({
        "process_fixes": False,
        "process_rag_blocks": False,
    })
    assert save_res["rag_summary"]["processed"] == 0
    assert not (logs_dir / ".pending_rag_blocks.json").exists()
    assert not (kb_dir / "failsafe-append.scd").exists()


def test_xappend_state_tracking_lean_and_standard_and_failsafe_reset(monkeypatch):
    """Verify:
    1. Standard two-stage and lean X-Append both receive === CURRENT COMPOSITION STATE === + Patch JSON.
    2. cmd_cross_append updates and returns composition_state + patch_state_json across modes.
    3. When failsafe triggers and cmd_reset_composition_state runs, prior state and design tracker
       are wiped and replaced solely by the failsafe block ('starts from scratch').
    """
    import llm_engine
    captured_prompts = []

    class DummyLLM:
        def __init__(self, provider, model_name):
            self.provider = provider
            self.model_name = model_name

        def generate(self, user_prompt, sys_prompt="", temperature=0.7, thinking_budget=0):
            captured_prompts.append((user_prompt, sys_prompt))
            if "Task: Generate a composition plan" in user_prompt:
                return ("1. Add shimmering bell layer", {"time_s": 0.5, "cost": 0.0001})
            return (
                "(\nNdef(\\shimmerBell, { |freq=660, amp=0.15, t_trig=1| "
                "Pan2.ar(SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.01, 0.5), t_trig) * amp, 0) }).play;\n)",
                {"time_s": 0.8, "cost": 0.0002},
            )

    monkeypatch.setattr(llm_engine, "LLMClient", DummyLLM)
    monkeypatch.setattr(gui_backend, "_resolve_model", lambda k: ("google", "gemini-3.8-flash"))
    monkeypatch.setattr(gui_backend, "_rag_failsafe_lookup", lambda p, *a, **kw: "(\nNdef(\\safeStart, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play;\n)")
    monkeypatch.setattr(gui_backend.utils, "append_to_session_log", lambda *a, **kw: None)

    file_key = "xappend_multi_test.scd"
    gui_backend._composition_states.pop(file_key, None)
    gui_backend._design_ran_in_session.pop(file_key, None)

    # Seed initial state via cmd_reset_composition_state with a Design block
    gui_backend.cmd_reset_composition_state({
        "code": SAMPLE_DESIGN,
        "active_file": file_key,
        "mode": "design",
    })
    assert gui_backend._design_ran_in_session[file_key] is True
    assert "z1_Lead" in gui_backend._composition_states[file_key]

    # 1. Lean prompt cross_append (compose) should see Design + SynthDef + Patch JSON
    captured_prompts.clear()
    res_lean = gui_backend.cmd_cross_append({
        "mode": "compose",
        "lean_prompt": True,
        "use_kb": False,
        "prompt": "Layer a subtle clock pulse",
        "active_file": file_key,
    })
    assert len(captured_prompts) == 1
    assert "=== CURRENT COMPOSITION STATE ===" in captured_prompts[0][0]
    assert "Patch JSON:" in captured_prompts[0][0]
    assert "z1_Lead" in captured_prompts[0][0]
    assert "=== CURRENT COMPOSITION STATE ===" in captured_prompts[0][1]
    assert "shimmerBell" in res_lean["composition_state"]
    assert "shimmerBell" in res_lean["patch_state_json"]["ndefs"]

    # 2. Standard two-stage cross_append (generate) should ALSO pass CURRENT COMPOSITION STATE to plan AND code
    captured_prompts.clear()
    res_std = gui_backend.cmd_cross_append({
        "mode": "generate",
        "lean_prompt": False,
        "use_kb": False,
        "prompt": "Add wind canopy",
        "active_file": file_key,
    })
    assert len(captured_prompts) == 2
    assert "=== CURRENT COMPOSITION STATE ===" in captured_prompts[0][0]
    assert "shimmerBell" in captured_prompts[0][0]
    assert "=== CURRENT COMPOSITION STATE ===" in captured_prompts[1][0]
    assert "Patch JSON:" in captured_prompts[1][0]

    # 3. Failsafe reset ("start from scratch"): replaces entire state with failsafe block & resets design tracker
    gui_backend.cmd_reset_composition_state({
        "code": "(\nNdef(\\safeStart, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play;\n)",
        "active_file": file_key,
        "mode": "generate",
        "reset_design_tracker": True,
    })
    reset_state = gui_backend._composition_states[file_key]
    assert "safeStart" in reset_state
    assert "shimmerBell" not in reset_state
    assert "z1_Lead" not in reset_state
    assert gui_backend._design_ran_in_session[file_key] is False


def test_real_kb_dedicated_failsafes_per_use_case():
    """Verify against the real knowledge_base/ & vectordb_knowledge_base/ built in session 3a6dbab1
    that each of the 4 X-Append modes resolves to a valid failsafe block from its dedicated file."""
    kb_dir = Path(SC_GEN_RAG_DIR) / "knowledge_base"
    db_dir = Path(SC_GEN_RAG_DIR) / "vectordb_knowledge_base"
    if not (kb_dir / "failsafe-generate.scd").exists() or not db_dir.exists():
        pytest.skip("Real failsafe KB / vectordb not present")

    rag_engine._cached_db = None
    for mode, prompt in [
        ("append", "volcanic rumble and canopy wind"),
        ("generate", "stereo detune fm pad and pluck"),
        ("compose", "kinetic rhythmic score with safety limiter"),
        ("design", "multitimbral midi synthesizer with gui"),
    ]:
        res = gui_backend.cmd_rag_lookup({"prompt": prompt, "mode": mode})
        code = res.get("code", "")
        assert code.strip(), f"Empty failsafe returned for mode={mode}"
        assert code.strip().startswith("(") and code.strip().endswith(")"), f"Expected single (...) block for mode={mode}"
        _, fixes = code_validator.validate_and_fix(code)
        assert "WARNING: brackets are unbalanced" not in fixes


def test_logfire_service_version_never_spawns_subprocess(monkeypatch):
    """Regression test: LLMClient initialization AND @traceable generate() inside the persistent daemon
    must never spawn `git rev-parse HEAD` or `git describe` via subprocess (which hangs indefinitely
    on Windows when fd 0/1/2 are marked inheritable)."""
    import subprocess
    import llm_engine

    def forbid_subprocess(*args, **kwargs):
        raise AssertionError(f"Forbidden subprocess call during LLMClient init/generate: {args}")

    monkeypatch.setattr(subprocess, "check_output", forbid_subprocess)
    monkeypatch.setattr(subprocess, "Popen", forbid_subprocess)
    monkeypatch.setattr(llm_engine, "_logfire_configured", False)
    monkeypatch.setattr(llm_engine, "_cached_service_version", None)

    ver = llm_engine._get_service_version()
    assert isinstance(ver, str) and len(ver) >= 3
    assert os.environ.get("LANGCHAIN_REVISION_ID")

    monkeypatch.setattr(config, "GEMINI_API_KEY", "dummy-key")
    client = llm_engine.LLMClient(provider="gemini", model_name="gemini-3.8-flash")
    assert client.model_name == "gemini-3.8-flash"

    # Also invoke the @traceable-decorated generate() with a stubbed _generate_with_provider
    monkeypatch.setattr(client, "_generate_with_provider", lambda *a, **kw: ("(Ndef(\\x, { Silent.ar(2) }).play;)", 10, 5, None))
    text, stats = client.generate("test prompt", "test sys")
    assert "Ndef(\\x" in text


def test_shutdown_drains_extra_rag_candidates_and_processes_before_sync(tmp_path, monkeypatch):
    """Verify that unverified in-memory candidates handed over by handleIdeShutdown via
    `extra_rag_candidates` are queued, verified, and ingested into failsafe-<mode>.scd
    BEFORE Google Docs network sync runs."""
    kb_dir = tmp_path / "knowledge_base"
    logs_dir = tmp_path / "use-logs"
    db_dir = tmp_path / "vectordb"
    kb_dir.mkdir(parents=True, exist_ok=True)
    logs_dir.mkdir(parents=True, exist_ok=True)

    monkeypatch.setattr(config, "CONTEXT_FOLDER", str(kb_dir))
    monkeypatch.setattr(config, "KNOWLEDGE_DB_PATH", str(db_dir))
    monkeypatch.setattr(utils, "LOGS_DIR", str(logs_dir))

    call_order = []

    def fake_finalize(process_fixes):
        # At the time finalize_session_log runs, failsafe-append.scd must ALREADY exist on disk
        assert (kb_dir / "failsafe-append.scd").exists()
        call_order.append("finalize")
        return "session_done.md"

    monkeypatch.setattr(utils, "finalize_session_log", fake_finalize)
    rag_engine._cached_db = None

    res = gui_backend.cmd_save_session_log({
        "process_fixes": False,
        "process_rag_blocks": True,
        "extra_rag_candidates": [
            {
                "code": SAMPLE_APPEND,
                "prompt": "Late ocean pad before close",
                "hint_mode": "append",
                "val_server_verified": True,
                "active_file": "late.scd",
            }
        ],
    })
    assert call_order == ["finalize"]
    assert res["rag_summary"]["processed"] == 1
    assert res["rag_summary"]["chunks_added"] >= 1
    assert "oceanPad" in (kb_dir / "failsafe-append.scd").read_text(encoding="utf-8")


