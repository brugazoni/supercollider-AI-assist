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
