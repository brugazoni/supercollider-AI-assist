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
