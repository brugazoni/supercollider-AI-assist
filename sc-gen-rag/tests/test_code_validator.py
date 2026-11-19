import pytest
from code_validator import validate_and_fix


def test_strip_artifact_header():
    code = "//=========\n(\nNdef(\\test).play;\n)"
    fixed, fixes = validate_and_fix(code)
    assert "//=========" not in fixed
    assert "stripped //========= header" in fixes

def test_fix_literal_array():
    code = "var x = DynKlank.ar(..., Ref(#[freqs, amps, decays]));"
    fixed, fixes = validate_and_fix(code)
    assert "Ref([freqs, amps, decays])" in fixed
    assert "fixed Ref(#[...]) array bug" in fixes

def test_fix_done_action_2():
    code = "Ndef(\\test, { EnvGen.ar(Env.perc, t_trig, doneAction: 2) });"
    fixed, fixes = validate_and_fix(code)
    assert "doneAction: 2" not in fixed
    assert "stripped doneAction: 2 from Ndef" in fixes

def test_fix_decay_t_trig():
    code = "Decay2.ar(t_trig, 0.01, 0.1);"
    fixed, fixes = validate_and_fix(code)
    assert "Decay2.ar(K2A.ar(t_trig), 0.01, 0.1);" in fixed
    assert "fixed Decay.ar(t_trig) rate mismatch" in fixes

def test_fix_ndef_preinit():
    code = "Ndef(\\test).ar(2);\nNdef(\\test, { SinOsc.ar });"
    fixed, fixes = validate_and_fix(code)
    assert "Ndef(\\test).ar(2);" not in fixed
    assert "stripped Ndef.ar() pre-initialization" in fixes

def test_balanced_brackets():
    code = "(\nNdef(\\test, { [1, 2, 3] });\n)"
    fixed, fixes = validate_and_fix(code)
    assert "WARNING: brackets are unbalanced" not in fixes

def test_unbalanced_brackets():
    code = "(\nNdef(\\test, { [1, 2, 3 );\n)"
    fixed, fixes = validate_and_fix(code)
    assert "WARNING: brackets are unbalanced" in fixes


def test_normalize_for_xappend_design_6_blocks():
    from code_validator import normalize_for_xappend
    design_code = """// ============================================================
// STEP 0 — BOOT & SYNTHDEFS
// ============================================================
(
s.waitForBoot({
    SynthDef(\\myPad, { |out=0, freq=220|
        Out.ar(out, Pan2.ar(SinOsc.ar(freq) * 0.1));
    }).add;
    s.sync;
});
)

// ============================================================
// STEP 1 — LAUNCH GUI & SYNTH
// ============================================================
(
var w;
if(~surWin.notNil) { ~surWin.close };
w = Window("Test", Rect(100, 100, 400, 300));
~synth = Synth(\\myPad);
)

// ============================================================
// STEP 5 — CLEANUP
// ============================================================
(
~surWin.close;
MIDIdef.freeAll;
~synthGroup.free;
)
"""
    normalized, notes = normalize_for_xappend(design_code, mode="design")
    assert normalized.startswith("(")
    assert normalized.endswith(")")
    # Cleanup block must be commented out
    assert "// ~surWin.close;" in normalized
    assert "// MIDIdef.freeAll;" in normalized
    # Active GUI step (even if it calls .close on an old window before Window(...)) must remain active inside waitForBoot
    assert 'Window("Test"' in normalized
    assert '// w = Window("Test"' not in normalized
    _, fixes = validate_and_fix(normalized)
    assert "WARNING: brackets are unbalanced" not in fixes


def test_normalize_for_xappend_compose_disables_recording_and_gui():
    from code_validator import normalize_for_xappend
    compose_code = """(
~enableRecording = true;
s.waitForBoot({
    s.makeGui;
    Ndef(\\compLayer, { SinOsc.ar(220) * 0.1 }).play;
});
)"""
    normalized, notes = normalize_for_xappend(compose_code, mode="compose")
    assert normalized.startswith("(")
    assert normalized.endswith(")")
    assert "~enableRecording = false;" in normalized
    assert "~enableRecording = true;" not in normalized
    assert "// s.makeGui" in normalized


def test_normalize_for_xappend_generate_multi_block_and_teardown():
    from code_validator import normalize_for_xappend
    gen_code = """// --- DRONE INSTRUMENT ---
(
var baseFreq = 110;
Ndef(\\drone).clear;
Ndef(\\drone, { SinOsc.ar(baseFreq) * 0.2 }).play;
)

// --- DRONE SEQUENCE ---
(
var baseFreq = 220;
Pbindef(\\droneSeq, \\dur, 1, \\freq, baseFreq);
Ndef(\\drone)[1] = \\set -> Pbindef(\\droneSeq);
)

// Live Tweaks
// Ndef(\\drone).xset(\\freq, 330);

// drone fade out and ending
(
Ndef(\\drone).clear(10);
Pbindef(\\droneSeq).stop;
)
"""
    normalized, notes = normalize_for_xappend(gen_code, mode="generate")
    assert normalized.startswith("(")
    assert normalized.endswith(")")
    # Both active blocks have `var baseFreq` - they must be wrapped in `{ ... }.value;` so var declarations don't collide
    assert normalized.count("{") >= 2
    assert "}.value;" in normalized
    # Teardown fade-out block must be commented out
    assert "// Ndef(\\drone).clear(10);" in normalized
    _, fixes = validate_and_fix(normalized)
    assert "WARNING: brackets are unbalanced" not in fixes


def test_fix_negative_default_in_pipe_args():
    code = "Ndef(\\sub, { |freq=110, pan=-0.25, amp=0.3| Pan2.ar(SinOsc.ar(freq), pan, amp) });"
    fixed, fixes = validate_and_fix(code)
    assert "pan=(-0.25)" in fixed
    assert "parenthesized negative default in |...| args" in fixes


def test_fix_nested_paren_var_blocks_in_design():
    from code_validator import normalize_for_xappend
    code = """(
s.boot;
s.waitForBoot({
    ~ccVals = (min1: 0, max1: 127);
});
defer {
    var pages = Array.newClear(2);
    (
        var p1 = CompositeView();
        var kSize = 75@90;
        pages[0] = p1;
    );
};
)"""
    normalized, notes = normalize_for_xappend(code, mode="design")
    assert "converted 1 nested ( var ... ) block(s) to { var ... }.value" in notes
    assert "commented out redundant s.boot before s.waitForBoot" in notes
    assert "moved post-waitForBoot GUI code inside s.waitForBoot" in notes
    assert "}.value;" in normalized
    # defer { ... } should now be inside s.waitForBoot({ ... })
    assert normalized.index("defer {") < normalized.rindex("});")


def test_inject_midi_fallback_replaces_loopmidi_and_midiin2_trap():
    from code_validator import normalize_for_xappend, validate_and_fix

    # Real pattern from session log where nested `or: { src.device.containsi("Midi") }` matched dead MIDIIN2 port
    raw_design = """(
MIDIClient.init;
~myInDevice = MIDIClient.sources.detect { |src| src.device.containsi("loopMIDI") or: { src.device.containsi("Midi") } };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " + ~myInDevice.device).postln;
    ~myUid = ~myInDevice.uid;
} {
    "Target MIDI device not found! Listening across available inputs...".warn;
    ~myUid = nil;
};
s.waitForBoot({
    MIDIdef.noteOn(\\testOn, { |vel, num| [vel, num].postln }, srcID: ~myUid);
});
)"""
    normalized, notes = normalize_for_xappend(raw_design, mode="design")
    assert any("injected hardware MIDI fallback" in n for n in notes)
    assert 'label.contains("loopmidi")' in normalized
    assert 'label.contains("beatstep")' in normalized
    assert 'label.contains("midiin2").not' in normalized
    assert 'label.contains("bmt").not' in normalized
    assert "MIDIIn.connect(0, ~myInDevice);" in normalized
    assert "~myUid = ~myInDevice.uid;" in normalized
    _, fixes = validate_and_fix(normalized)
    assert "WARNING: brackets are unbalanced" not in fixes

    # Idempotency check on second pass
    normalized_2, notes_2 = normalize_for_xappend(normalized, mode="design")
    assert not any("injected hardware MIDI fallback" in n for n in notes_2)
    assert normalized_2 == normalized


def test_lean_prompt_files_and_non_interference():
    import json
    import os
    import gui_backend

    defaults_path = os.path.join(gui_backend.SCRIPT_DIR, "sys_msgs_defaults.json")
    with open(defaults_path, "r", encoding="utf-8") as f:
        defaults = json.load(f)

    # Original tabs' defaults must remain completely untouched
    assert "compose_plan" in defaults and "compose_code" in defaults
    assert "design_plan" in defaults and "design_code" in defaults
    assert "gen_plan" in defaults and "gen_code" in defaults
    for mode, rel_list in gui_backend.LEAN_XAPPEND_SYS_MSGS.items():
        sys_text = gui_backend._build_system_prompt({"sys_msgs": rel_list})
        assert len(sys_text) > 500, f"Lean prompt for {mode} did not load properly"
        assert "CRITICAL RUNTIME INVARIANTS" in sys_text


def test_cmd_cross_append_lean_single_step_vs_standard_two_step(monkeypatch):
    import gui_backend

    calls = []

    class DummyLLM:
        def __init__(self, provider, model_name):
            self.provider = provider
            self.model_name = model_name

        def generate(self, user_prompt, sys_prompt="", temperature=0.7, thinking_budget=0):
            calls.append((user_prompt, sys_prompt))
            if "Task: Generate a composition plan" in user_prompt:
                return ("# Mock Plan\n- Cue 1", {"time_s": 1.0, "cost": 0.001})
            return (
                "(\nMIDIClient.init;\n~myInDevice = MIDIClient.sources.detect { |src| src.device == \"loopMIDI Port\" };\n"
                "if(~myInDevice.notNil) { MIDIIn.connect(0, ~myInDevice); ~myUid = ~myInDevice.uid; } { ~myUid = nil; };\n"
                "s.waitForBoot({ Ndef(\\leanTest, { Pan2.ar(SinOsc.ar(220) * 0.1, 0) }).play; });\n)",
                {"time_s": 2.0, "cost": 0.002},
            )

    import llm_engine
    monkeypatch.setattr(llm_engine, "LLMClient", DummyLLM)
    monkeypatch.setattr(gui_backend, "_resolve_model", lambda k: ("google", "gemini-3.8-flash"))
    monkeypatch.setattr(gui_backend, "_rag_failsafe_lookup", lambda p: "(\nNdef(\\fb, { Silent.ar(2) }).play;\n)")
    monkeypatch.setattr(gui_backend.utils, "append_to_session_log", lambda *a, **kw: None)

    # 1. Lean Prompt = True -> SINGLE LLM call, empty plan, MIDI fallback injected for design
    calls.clear()
    res_lean = gui_backend.cmd_cross_append({
        "mode": "design",
        "lean_prompt": True,
        "use_kb": False,
        "prompt": "Warm analog poly synth",
        "plan_sys_msgs": ["design/system-instruction-oneshot-plan-design-v2.md"],
        "code_sys_msgs": ["design/system-instruction-oneshot-gen-design-v2.md"],
    })
    assert len(calls) == 1, "Lean prompt mode must execute in a SINGLE LLM step"
    assert res_lean["plan"] == ""
    assert 'label.contains("beatstep")' in res_lean["code"]
    assert res_lean["last_stats"]["time_s"] == 2.0

    # 2. Lean Prompt = False (default) -> TWO LLM calls (plan -> code)
    calls.clear()
    res_std = gui_backend.cmd_cross_append({
        "mode": "compose",
        "lean_prompt": False,
        "use_kb": False,
        "prompt": "Short kinetic study",
        "plan_sys_msgs": ["compose/plan-v5.md"],
        "code_sys_msgs": ["compose/implement-v3.md"],
    })
    assert len(calls) == 2, "Standard mode must preserve two-step plan->code pipeline"
    assert "Mock Plan" in res_std["plan"]
    assert res_std["last_stats"]["time_s"] == 3.0


def test_compose_xappend_scopes_global_server_termination():
    """
    Regression test for Compose in X-Append:
    Ensure fixed-length Tdef(\\masterScore) compositions NEVER wipe the entire shared
    SuperCollider server at the end of execution (`Pbindef.all.do(_.stop)`, `Pbindef.removeAll`,
    `Ndef.clear(0.0)`, `Tdef.removeAll`, `ServerTree.removeAll`, `s.freeAll`, `s.quit`).
    Instead, only the block's own local Ndefs, Pbindefs, and Tdefs are stopped/cleared.
    """
    from code_validator import normalize_for_xappend

    raw_compose = """(
s.waitForBoot({
    ~enableRecording = false;
    ~synthBus = Bus.audio(s, 2);
    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \\safetyLimiter) });

    Ndef(\\oceanBed, { |amp=0| Pan2.ar(PinkNoise.ar(amp), 0) });
    Ndef(\\coastalWind, { |amp=0| Pan2.ar(WhiteNoise.ar(amp), 0) });
    Ndef(\\masterMix, { In.ar(~synthBus, 2) + Ndef.ar(\\oceanBed, 2) + Ndef.ar(\\coastalWind, 2) }).play;

    Tdef(\\masterScore, {
        0.5.wait;
        Pbindef(\\gullFlock, \\instrument, \\default, \\out, ~synthBus, \\dur, 0.25).play;
        Pbindef(\\chitter, \\instrument, \\default, \\out, ~synthBus, \\dur, 0.125).play;
        2.0.wait;

        // Cue 20: Form Operation D
        Pbindef.all.do(_.stop);
        Tdef.all.do(_.stop);

        // Cue 22: Terminal cleanup
        Pbindef.removeAll;
        Ndef.clear(0.0);
        Tdef.removeAll;
        s.freeAll;
        s.quit;
    });
    Tdef(\\masterScore).play;
});
)"""

    norm, fixes = normalize_for_xappend(raw_compose, mode="compose")

    # Global destructive calls must NOT remain active
    active_lines = [
        line.strip()
        for line in norm.splitlines()
        if line.strip() and not line.strip().startswith("//")
    ]
    active_code = "\n".join(active_lines)

    assert "ServerTree.removeAll" not in active_code
    assert "Pbindef.all" not in active_code
    assert "Pbindef.removeAll" not in active_code
    assert "Ndef.clear" not in active_code
    assert "Tdef.removeAll" not in active_code
    assert "Tdef.all" not in active_code
    assert "s.freeAll" not in active_code
    assert "s.quit" not in active_code

    # Scoped local proxy/pattern cleanup MUST be present
    assert "Pbindef(\\gullFlock).stop;" in active_code
    assert "Pbindef(\\chitter).stop;" in active_code
    assert "Pbindef(\\gullFlock).clear;" in active_code
    assert "Pbindef(\\chitter).clear;" in active_code
    assert "Ndef(\\oceanBed).clear(0.0);" in active_code
    assert "Ndef(\\coastalWind).clear(0.0);" in active_code
    assert "Ndef(\\masterMix).clear(0.0);" in active_code
    assert "Tdef(\\masterScore).stop;" in active_code


def test_fix_stray_wait_outside_routines():
    raw_code = """(
s.waitForBoot({
    var srv = s;
    Tdef(\\masterScore, {
        0.5.wait;
        "playing inside routine".postln;
    });

    0.5.wait;
    Tdef(\\masterScore).play;
});
)"""
    fixed, fixes = validate_and_fix(raw_code)
    assert "commented out stray .wait outside Routine" in fixes

    # Wait inside Tdef must be preserved
    assert "0.5.wait;\n        \"playing inside routine\"" in fixed

    # Wait outside Tdef before .play must be commented out
    assert "// 0.5.wait; // removed: .wait outside Routine" in fixed
    assert "Tdef(\\masterScore).play;" in fixed


def test_scope_teardowns_blocks_synthbus_free():
    from code_validator import normalize_for_xappend
    raw_compose = """(
s.waitForBoot({
    ~synthBus = Bus.audio(s, 2);
    Tdef(\\masterScore, {
        1.wait;
        ~synthBus.free;
    });
    Tdef(\\masterScore).play;
});
)"""
    norm, fixes = normalize_for_xappend(raw_compose, mode="compose")
    assert "blocked ~synthBus.free to preserve shared routing bus" in fixes
    assert "// ~synthBus.free; // preserved for shared X-Append session" in norm


def test_fix_reserved_pi_identifiers():
    code = """(
~pages = [1, 2, 3];
~pages.do { |page, pi|
    var x = pi * 10;
    ("Page " ++ page ++ " at " ++ pi).postln;
};

// Outside constant pi must remain unchanged
(2 * pi).postln;
)"""
    fixed, fixes = validate_and_fix(code)
    assert any("renamed reserved token 'pi' to 'pIdx'" in f for f in fixes)
    assert "|page, pIdx|" in fixed
    assert "pIdx * 10" in fixed
    assert "2 * pi" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes


def test_fix_unary_minus_on_identifiers():
    code = """(
var sig = SinOsc.ar(440);
var pan = 0.5, spread = 0.5, a = 1, b = 2;
~spread = 0.5;
Pan2.ar(sig, -pan);
Balance2.ar(sig, sig, -spread);
[-spread, spread];
a - b;
10 - 5;
pan = -pan;
foo.value(pos: -~spread);
-(a + b);
)"""
    fixed, fixes = validate_and_fix(code)
    assert "converted unary '-' prefix on identifier/expression to .neg" in fixes
    assert "Pan2.ar(sig, pan.neg);" in fixed
    assert "spread.neg" in fixed
    assert "[spread.neg, spread];" in fixed
    assert "pan = pan.neg;" in fixed
    assert "~spread.neg" in fixed
    assert "(a + b).neg;" in fixed
    # Binary minus must NOT be touched
    assert "a - b;" in fixed
    assert "10 - 5;" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes


def test_fix_jitlib_set_instrument():
    code = """(
Ndef(\\lead, { |freq=440| SinOsc.ar(freq) * 0.1 });
Ndef(\\lead)[1] = \\set -> Pbindef(\\lead_ctl, \\instrument, \\lead, \\dur, 0.5, \\freq, 440);
Ndef(\\pad)[2] = \\set -> Pbind(\\dur, 1, \\instrument, \\pad);
Pbindef(\\realSynth, \\instrument, \\mySynth, \\dur, 0.5);
)"""
    fixed, fixes = validate_and_fix(code)
    assert "stripped redundant \\instrument from JITLib \\set pattern" in fixes
    assert "\\set -> Pbindef(\\lead_ctl, \\dur, 0.5, \\freq, 440);" in fixed
    assert "\\set -> Pbind(\\dur, 1);" in fixed
    # Standalone Pbindef playing a SynthDef must preserve \instrument
    assert "Pbindef(\\realSynth, \\instrument, \\mySynth, \\dur, 0.5);" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes


def test_fix_balance2_on_mono_ugen():
    code = """(
var sig = SinOsc.ar(440);
var pan = 0.2;
sig = Balance2.ar(sig[0], sig[1], pan, 0.8);
)"""
    fixed, fixes = validate_and_fix(code)
    assert any("wrapped Balance2.ar" in f for f in fixes)
    assert "if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, 0.8) } { Pan2.ar(sig, pan, 0.8) }" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes

    # Pre-guarded code must NOT be double-wrapped
    guarded_code = """(
var sig = SinOsc.ar(440);
sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0) } { Pan2.ar(sig, 0) };
)"""
    fixed_guarded, fixes_guarded = validate_and_fix(guarded_code)
    assert not any("wrapped Balance2.ar" in f for f in fixes_guarded)
    assert "WARNING: brackets are unbalanced" not in fixes_guarded


def test_fix_non_vanilla_classes():
    code = """(
var osc = DPW4Saw.ar(440);
var crushed = Decimator.ar(osc, 12000, 10);
var tabs = TabbedView(~mainWin, Rect(0, 0, 400, 300));
var pages = PageLayout(~mainWin, 400 @ 300);
)"""
    fixed, fixes = validate_and_fix(code)
    assert any("normalized non-vanilla DPW4Saw" in f for f in fixes)
    assert any("normalized non-vanilla Decimator.ar" in f for f in fixes)
    assert any("normalized third-party GUI class" in f for f in fixes)
    assert "Saw.ar(440)" in fixed
    assert "Latch.ar(osc, Impulse.ar(12000))" in fixed
    assert "CompositeView(~mainWin, Rect(0, 0, 400, 300))" in fixed
    assert "CompositeView(~mainWin, 400 @ 300)" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes


def test_fix_array_new_inplace_add():
    code = """(
var pages, pageButtons;
~ruvVoices = Array.new;
pages = Array.new;
pageButtons = [];
~zoneMeta.do { |zm, idx|
    var page = CompositeView(~mainWin, Rect(10, 42, 700, 500));
    pages.add(page);
    pageButtons.add(Button(~mainWin, Rect(10, 8, 160, 28)));
};
~ruvVoices.add((note: 60));
)"""
    fixed, fixes = validate_and_fix(code)
    assert any("converted Array.new/[] to List.new" in f for f in fixes)
    assert "~ruvVoices = List.new;" in fixed
    assert "pages = List.new;" in fixed
    assert "pageButtons = List.new;" in fixed
    assert "WARNING: brackets are unbalanced" not in fixes








