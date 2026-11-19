import pytest
from sc_state_parser import update_composition_state

def test_parse_empty_state_adds_new_ndef():
    prev = "(Empty)"
    code = """
    (
    Ndef(\\bass, { |freq=50| SinOsc.ar(freq) }).play;
    Pbindef(\\bassSeq, \\dur, 0.5, \\degree, Pseq([1,2,3], inf));
    Ndef(\\bass)[1] = \\set -> Pbindef(\\bassSeq);
    )
    """
    new_state = update_composition_state(prev, code)
    assert "Active Ndefs:" in new_state
    assert "- \\bass" in new_state
    assert "Active Pbindefs:" in new_state
    assert "- \\bassSeq" in new_state

def test_parse_existing_state_adds_effects():
    prev = """
Active Ndefs:
- \\pad
Active Pbindefs:
- \\padSeq
    """
    code = """
    (
    Ndef(\\pad)[10] = \\filter -> { |in| GVerb.ar(in, 10, 3) };
    Ndef(\\pad).xset(\\wet10, 0.5);
    )
    """
    new_state = update_composition_state(prev, code)
    assert "- \\pad" in new_state
    assert "- Slot 10: GVerb.ar(in, 10, 3)" in new_state
    assert "- \\wet10: 0.5" in new_state

def test_parse_clear_and_stop():
    prev = """
Active Ndefs:
- \\pad
- \\bass
Active Pbindefs:
- \\padSeq
- \\bassSeq
    """
    code = """
    (
    Pbindef(\\padSeq).stop;
    Ndef(\\pad).clear(4);
    )
    """
    new_state = update_composition_state(prev, code)
    assert "\\pad" not in new_state
    assert "\\padSeq" not in new_state
    assert "\\bass" in new_state
    assert "\\bassSeq" in new_state

def test_all_cleared_returns_empty():
    prev = """
Active Ndefs:
- \\pad
    """
    code = """
    Ndef(\\pad).clear;
    """
    new_state = update_composition_state(prev, code)
    assert new_state == "(Empty)"


def test_tracks_all_xappend_modes_and_patch_json():
    from sc_state_parser import get_patch_state_json

    # 1. Append Ndef + Pbindef + args + binding
    s1 = update_composition_state("(Empty)", """
    (
    Ndef(\\oceanPad, { |freq=110, cutoff=1200, amp=0.2, t_trig=1|
        Pan2.ar(RLPF.ar(Saw.ar(freq), cutoff, 0.3) * amp, 0);
    }).play;
    Pbindef(\\oceanSeq, \\dur, 0.5, \\freq, 110, \\t_trig, 1);
    Ndef(\\oceanPad)[1] = \\set -> Pbindef(\\oceanSeq);
    )
    """)
    j1 = get_patch_state_json(s1)
    assert "oceanPad" in j1["ndefs"]
    assert "freq=110" in j1["ndefs"]["oceanPad"]["args"]
    assert j1["ndefs"]["oceanPad"]["bound_pbindef"] == "oceanSeq"
    assert "oceanSeq" in j1["pbindefs"]

    # 2. Compose SynthDef + Tdef + ~synthBus (skips safetyLimiter/diskRecorder)
    s2 = update_composition_state(s1, """
    (
    if(~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };
    SynthDef(\\safetyLimiter, { ReplaceOut.ar(0, In.ar(0, 2)) }).add;
    SynthDef(\\metalBell, { |out=0, freq=440, decay=1.2, amp=0.2|
        Out.ar(out, Pan2.ar(SinOsc.ar(freq) * amp, 0));
    }).add;
    Tdef(\\masterScore, {
        Pbindef(\\bellSeq, \\instrument, \\metalBell, \\out, ~synthBus, \\dur, 0.25).play;
        2.wait;
        Tdef(\\masterScore).stop;
    });
    )
    """)
    j2 = get_patch_state_json(s2)
    assert "metalBell" in j2["synthdefs"]
    assert "safetyLimiter" not in j2["synthdefs"]
    assert "masterScore" in j2["tdefs"]
    assert "~synthBus" in j2["buses"]
    assert j2["pbindefs"]["bellSeq"]["out_bus"] == "~synthBus"
    assert "oceanPad" in j2["ndefs"]  # preserved from prior step

    # 3. Design SynthDef + MIDIdef + Groups + Windows + ~ccVals
    s3 = update_composition_state(s2, """
    (
    s.waitForBoot({
        ~ccVals = (vol1: 0.3, lpf1: 4000, fxSol: 0.0);
        ~synthGroup = Group.new(s);
        ~fxGroup = Group.after(~synthGroup);
        SynthDef(\\z1_Lead, { |out=0, freq=440, vol=0.3| Out.ar(out, SinOsc.ar(freq) * vol) }).add;
        MIDIdef.noteOn(\\leadOn, { |v, n| }, srcID: ~myUid);
        defer { ~mainWin = Window("Lead", Rect(0, 0, 300, 200)).front; };
    });
    )
    """)
    j3 = get_patch_state_json(s3)
    assert j3["design"]["active"] is True
    assert "leadOn" in j3["design"]["mididefs"]
    assert "~synthGroup" in j3["design"]["groups"]
    assert "~mainWin" in j3["design"]["gui_vars"]
    assert "vol1" in j3["design"]["cc_keys"]
    assert "z1_Lead" in j3["synthdefs"]
    assert "Patch JSON:" in s3
