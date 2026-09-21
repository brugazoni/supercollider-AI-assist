"""
Integration tests for the RAG Failsafe auto-append flow.

Why these tests exist:
  The original test suite missed the multi-block extraction bug because:
  1. SAMPLE_RAG_FILE used single monolithic (...) blocks — never tested the 
     instrument/sequence/effects split pattern used by ndef-animals.scd.
  2. TestFailsafeFlow tests injected hardcoded rag_block strings, bypassing
     the actual _rag_failsafe_lookup function entirely.
  3. No test validated that the returned fallback is *self-contained and playable*
     (i.e. has an Ndef, a Pbindef, slot routing, and .play).
  4. No test used the real knowledge base files as ground truth.

These integration tests close those gaps by:
  - Testing against the REAL ndef-animals.scd knowledge base
  - Validating that fallback code is structurally playable
  - Running the full failsafe flow (lookup → error → reset → state recovery)
    with realistic multi-block RAG data
  - Testing every animal section in the real KB
  - Validating SC structural soundness of the extracted code
"""
import os
import re
import sys
import types
import textwrap
import threading

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import gui_backend
import sc_state_parser
import config as config_module


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

REAL_KB_DIR = os.path.join(os.path.dirname(__file__), '..', 'knowledge_base')

# SC structural checks: what makes a block "self-contained and playable"
def _has_ndef_play(code):
    """Code defines at least one Ndef and calls .play on it."""
    return bool(re.search(r'Ndef\(\\', code)) and '.play' in code

def _has_pbindef_or_pbind(code):
    """Code has a Pbindef or Pbind driving the sequencer."""
    return bool(re.search(r'Pbindef\(\\|Pbind\(', code))

def _has_slot_routing(code):
    """Code routes a pattern into an Ndef slot via [1] = \\set ->"""
    return bool(re.search(r'\[\d+\]\s*=\s*\\set\s*->', code))

def _has_balanced_parens(code):
    """All top-level () are balanced."""
    stack = []
    for c in code:
        if c == '(':
            stack.append(c)
        elif c == ')':
            if not stack:
                return False
            stack.pop()
    return len(stack) == 0

def _count_top_level_blocks(text):
    count = 0
    stack = []
    for i, c in enumerate(text):
        if c == '(':
            if not stack:
                if i == 0 or text[i-1] == '\n':
                    stack.append(c)
            else:
                stack.append(c)
        elif c == ')':
            if stack:
                stack.pop()
                if not stack:
                    count += 1
    return count

def _extract_ndef_names(code):
    """Extract all Ndef names from the code."""
    return set(re.findall(r'Ndef\((\\[\w]+)', code))

def _has_teardown_keywords(code):
    """Check if code contains teardown operations like .clear, .stop, fadeTime."""
    lower = code.lower()
    # Only count these as teardown if they appear as standalone actions,
    # not as part of the setup (like Ndef(\x).clear; at the top of a block)
    lines = code.strip().split('\n')
    for line in lines:
        stripped = line.strip()
        # Skip the common pattern: Ndef(\x).clear; at the start of an instrument block
        # (this is a pre-clear before redefining)
        if re.match(r'Ndef\(\\[\w]+\)\.clear\s*;', stripped):
            continue
        if '.fadeTime' in stripped:
            return True
        if re.search(r'\.clear\(\d+\)', stripped):
            return True
        if re.search(r'Pbindef\(\\[\w]+\)\.stop', stripped):
            return True
    return False


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

# A realistic multi-block KB file modeled directly on ndef-animals.scd structure.
# This is NOT a copy of ndef-animals.scd — it's a minimal structural twin
# that exercises all the same patterns: instrument/sequence/effects as separate
# blocks, LIVE CODING TWEAKS section (individual lines, not in parens),
# fade-out block, and section delimiters.
REALISTIC_MULTI_BLOCK_KB = textwrap.dedent("""\
////////////////////
// --- WOLF INSTRUMENT ---
(
Ndef(\\wolf).clear;
Ndef(\\wolf, {
    |freq=80, amp=0.3, trig=1, growl=8, rq=0.2|
    var env, mod, car, out;
    env = EnvGen.kr(Env.perc(0.1, 1.5), trig);
    mod = SinOsc.ar(freq * 0.5) * (freq * growl);
    car = SinOsc.ar(freq + mod);
    out = RLPF.ar(car, freq * 4, rq);
    Pan2.ar(out * env * amp, 0);
}).play;
)

// --- WOLF SEQUENCES ---
(
Pbindef(\\wolfSeq, \\dur, 3, \\freq, 80, \\growl, 10, \\trig, 1);
Ndef(\\wolf).quant = 1;
Ndef(\\wolf)[1] = \\set -> Pbindef(\\wolfSeq);
)

// --- WOLF EFFECTS ---
(
Ndef(\\wolf)[10] = \\filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.2) };
Ndef(\\wolf).set(\\wet10, 0);
Ndef(\\wolf)[11] = \\filter -> { |in| CombL.ar(in, 1, 0.4, 3) };
Ndef(\\wolf).set(\\wet11, 0);
)

// --- WOLF LIVE CODING TWEAKS ---
//instrument tweaks
Ndef(\\wolf).set(\\growl, 20);
Ndef(\\wolf).set(\\freq, 50, \\growl, 15);

//sequence tweaks
Pbindef(\\wolfSeq, \\dur, 0.5, \\freq, 100);
Pbindef(\\wolfSeq, \\dur, Pwhite(1.0, 4.0));

//effect tweaks
Ndef(\\wolf).set(\\wet10, 0.6);

//wolf fade out and ending
(
Pbindef(\\wolfSeq).stop;
Ndef(\\wolf).fadeTime = 5;
Ndef(\\wolf).clear(5);
)

////////////////////
// --- OWL INSTRUMENT ---
(
Ndef(\\owl).clear;
Ndef(\\owl, {
    |freq=400, amp=0.2, trig=1|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.02, 0.8), trig);
    sig = SinOsc.ar(freq) * env;
    Pan2.ar(sig * amp, 0);
}).play;
)

// --- OWL SEQUENCES ---
(
Pbindef(\\owlSeq, \\dur, 2, \\freq, Pseq([400, 350], inf), \\trig, 1);
Ndef(\\owl).quant = 1;
Ndef(\\owl)[1] = \\set -> Pbindef(\\owlSeq);
)

// --- OWL EFFECTS ---
(
Ndef(\\owl)[10] = \\filter -> { |in| FreeVerb.ar(in, 1, 0.95, 0.1) };
Ndef(\\owl).set(\\wet10, 0.3);
)

// --- OWL LIVE CODING TWEAKS ---
Ndef(\\owl).set(\\freq, 300);

//owl fade out and ending
(
Pbindef(\\owlSeq).stop;
Ndef(\\owl).fadeTime = 4;
Ndef(\\owl).clear(4);
)
""")


@pytest.fixture
def realistic_kb_dir(tmp_path):
    """Create a KB directory with the realistic multi-block file."""
    kb_dir = tmp_path / "knowledge_base"
    kb_dir.mkdir()
    rag_file = kb_dir / "ndef-animals.scd"
    rag_file.write_text(REALISTIC_MULTI_BLOCK_KB, encoding="utf-8")
    return tmp_path


@pytest.fixture
def real_kb_dir():
    """Points to the real knowledge_base directory for ground-truth tests."""
    kb_path = os.path.abspath(REAL_KB_DIR)
    if not os.path.isdir(kb_path):
        pytest.skip("Real knowledge_base directory not found")
    return kb_path


@pytest.fixture
def mock_retriever_for_chunk():
    """Build a mock retriever that returns a single chunk with metadata."""
    from langchain_core.documents import Document

    def factory(chunk_text, filename):
        docs = [Document(page_content=chunk_text, metadata={"source": "knowledge-base", "filename": filename})]
        def mock_retriever(query):
            return docs
        return mock_retriever

    return factory


@pytest.fixture(autouse=True)
def reset_state():
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()
    yield
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()


# ===========================================================================
# 1. Structural Soundness — fallback code must be self-contained & playable
# ===========================================================================

class TestFallbackStructuralSoundness:
    """Validate that the extracted fallback code is structurally sound SC code
    that would actually produce sound when evaluated."""

    def test_wolf_fallback_is_playable(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """The wolf fallback should have Ndef.play, Pbindef, and slot routing."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf howl")

        assert result, "Fallback should not be empty"
        assert _has_ndef_play(result), "Fallback must define an Ndef with .play"
        assert _has_pbindef_or_pbind(result), "Fallback must have a Pbindef/Pbind to drive triggers"
        assert _has_slot_routing(result), "Fallback must route the pattern into an Ndef slot"
        assert _has_balanced_parens(result), "Fallback must have balanced parentheses"

    def test_owl_fallback_is_playable(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """Same structural check for a different animal."""
        chunk = "Ndef(\\owl, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("owl hooting")

        assert result, "Fallback should not be empty"
        assert _has_ndef_play(result), "Fallback must define an Ndef with .play"
        assert _has_pbindef_or_pbind(result), "Fallback must have a Pbindef/Pbind"
        assert _has_slot_routing(result), "Fallback must route pattern into Ndef slot"

    def test_fallback_has_multiple_blocks(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """The wolf section should return 3 blocks: instrument, sequence, effects."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf")

        block_count = _count_top_level_blocks(result)
        assert block_count == 3, f"Expected 3 blocks (instrument+sequence+effects), got {block_count}"

    def test_fallback_does_not_contain_teardown(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """Extracted fallback must not contain .stop, .clear(N), or .fadeTime."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf")

        assert not _has_teardown_keywords(result), \
            f"Fallback should not contain teardown code. Got:\n{result}"

    def test_fallback_only_references_one_instrument(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """The wolf fallback should only reference \\wolf, not \\owl or others."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf")

        ndef_names = _extract_ndef_names(result)
        assert "\\wolf" in ndef_names, f"Expected \\wolf in Ndef names, got {ndef_names}"
        assert "\\owl" not in ndef_names, f"\\owl should not appear in wolf fallback"

    def test_fallback_does_not_contain_live_coding_tweaks(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """Individual .set() lines from the LIVE CODING TWEAKS section should not
        appear since they are outside (…) blocks."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf")

        # These are individual tweak lines that sit between the effects block
        # and the fade-out block — they should never be in the fallback
        assert "\\growl, 20" not in result, "Live coding tweaks should not be in fallback"
        assert "\\growl, 15" not in result, "Live coding tweaks should not be in fallback"


# ===========================================================================
# 2. Real Knowledge Base — ground truth validation against ndef-animals.scd
# ===========================================================================

class TestRealKnowledgeBase:
    """Test _rag_failsafe_lookup against the REAL ndef-animals.scd file.
    
    These tests are the critical integration layer that would have caught
    the original bug. They use the actual knowledge base content as ground
    truth and verify structural properties of the extracted code.
    """

    # All animals in ndef-animals.scd that have the instrument/sequence/effects pattern
    ANIMALS = [
        ("scorpion", "Ndef(\\scorpionScrape, {"),
        ("jaguar", "Ndef(\\jaguar, {"),
        ("guariba", "Ndef(\\guariba, {"),
        ("arara", "Ndef(\\arara, {"),
        ("toad", "Ndef(\\toad, {"),
    ]

    @pytest.fixture
    def setup_real_kb(self, real_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """Fixture that wires up the real KB directory for testing."""
        import rag_engine
        self._mock_retriever_for_chunk = mock_retriever_for_chunk
        self._monkeypatch = monkeypatch
        self._real_kb_dir = real_kb_dir
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", real_kb_dir)
        yield

    @pytest.mark.parametrize("animal_name, chunk_text", ANIMALS)
    def test_animal_fallback_has_ndef_play(self, animal_name, chunk_text, setup_real_kb):
        """Every animal in the KB should produce a fallback with Ndef.play."""
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(chunk_text, "ndef-animals.scd")
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup(animal_name)

        assert result, f"Fallback for '{animal_name}' should not be empty"
        assert _has_ndef_play(result), \
            f"Fallback for '{animal_name}' must have Ndef.play. Got:\n{result[:200]}"

    @pytest.mark.parametrize("animal_name, chunk_text", ANIMALS)
    def test_animal_fallback_has_sequence(self, animal_name, chunk_text, setup_real_kb):
        """Every animal should have a Pbindef or sequence driving triggers."""
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(chunk_text, "ndef-animals.scd")
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup(animal_name)

        assert _has_pbindef_or_pbind(result), \
            f"Fallback for '{animal_name}' must have a sequencer (Pbindef/Pbind). Got:\n{result[:300]}"

    @pytest.mark.parametrize("animal_name, chunk_text", ANIMALS)
    def test_animal_fallback_no_teardown(self, animal_name, chunk_text, setup_real_kb):
        """No animal fallback should include fade-out/stop/clear-with-fade code."""
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(chunk_text, "ndef-animals.scd")
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup(animal_name)

        assert not _has_teardown_keywords(result), \
            f"Fallback for '{animal_name}' should not contain teardown code. Got:\n{result}"

    @pytest.mark.parametrize("animal_name, chunk_text", ANIMALS)
    def test_animal_fallback_balanced_parens(self, animal_name, chunk_text, setup_real_kb):
        """Every fallback must have balanced parentheses."""
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(chunk_text, "ndef-animals.scd")
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup(animal_name)

        assert _has_balanced_parens(result), \
            f"Fallback for '{animal_name}' has unbalanced parens"

    @pytest.mark.parametrize("animal_name, chunk_text", ANIMALS)
    def test_animal_fallback_has_at_least_two_blocks(self, animal_name, chunk_text, setup_real_kb):
        """Every animal should produce at least 2 blocks (instrument + sequence),
        most should have 3 (instrument + sequence + effects)."""
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(chunk_text, "ndef-animals.scd")
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup(animal_name)

        block_count = _count_top_level_blocks(result)
        assert block_count >= 2, \
            f"Expected ≥2 blocks for '{animal_name}', got {block_count}. Got:\n{result[:300]}"

    def test_guariba_fallback_exact_content(self, setup_real_kb):
        """The specific guariba case from the original bug report.
        
        The guariba section in ndef-animals.scd has:
        - Instrument block with Ndef(\\guariba)
        - Sequence block with Pbindef(\\guaribaSeq) and slot routing
        - Effects block with filter slots 10, 11, 12
        
        All three must be present; the fade-out block must NOT be present.
        """
        import rag_engine
        mock_ret = self._mock_retriever_for_chunk(
            "Ndef(\\guariba, {", "ndef-animals.scd"
        )
        self._monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup("guariba howler monkey")

        # Instrument
        assert "Ndef(\\guariba, {" in result, "Missing instrument definition"
        assert ".play;" in result, "Missing .play"

        # Sequence
        assert "Pbindef(\\guaribaSeq" in result, "Missing Pbindef sequence"
        assert "Ndef(\\guariba)[1] = \\set ->" in result, "Missing slot routing"

        # Effects  
        assert "Ndef(\\guariba)[10]" in result, "Missing effects slot 10"

        # Must NOT have teardown
        assert "Ndef(\\guariba).clear(6)" not in result, "Teardown clear should be excluded"
        assert "Pbindef(\\guaribaSeq).stop" not in result, "Teardown stop should be excluded"
        assert ".fadeTime" not in result, "Teardown fadeTime should be excluded"


# ===========================================================================
# 3. Full failsafe flow — lookup → error → reset → state recovery
# ===========================================================================

class TestFullFailsafeFlowIntegration:
    """Simulate the complete failsafe flow with realistic multi-block data.
    
    This tests the full chain:
    1. cmd_append returns rag_fallback from multi-block KB
    2. Error is detected (simulated)
    3. applyRagFallback clears Ndefs and executes the fallback code
    4. cmd_reset_composition_state rebuilds state from the multi-block fallback
    5. The next cmd_append sees the correct state
    """

    def test_full_flow_with_multi_block_fallback(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """End-to-end: multi-block RAG → error → reset → state correctly reflects
        the full instrument (not just the Ndef definition)."""
        # Step 1: Get the RAG fallback for wolf
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")
        
        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))
        
        rag_fallback = gui_backend._rag_failsafe_lookup("wolf howl")
        assert rag_fallback, "RAG fallback should not be empty"

        # Step 2: Simulate a broken code block was appended
        broken_code = textwrap.dedent("""\
        (
        Ndef(\\brokenWolf, { |freq=80|
            var sig = SinOsc.ar(freq);
            var env = EnvGen.ar(Env.perc(0.1, 1), \\trig.tr);
            sig = sig * env;
            Pan2.ar(sig, 0);
        }).play;
        )""")
        gui_backend._composition_states["test.scd"] = \
            sc_state_parser.update_composition_state("", broken_code)

        assert "\\brokenWolf" in gui_backend._composition_states["test.scd"]

        # Step 3: Error detected → reset composition state with RAG fallback
        gui_backend.cmd_reset_composition_state({
            "code": rag_fallback,
            "active_file": "test.scd"
        })

        # Step 4: Verify state now reflects the full wolf instrument
        state = gui_backend._composition_states["test.scd"]
        assert "\\brokenWolf" not in state, "Broken Ndef should be gone"
        assert "\\wolf" in state, "Wolf Ndef should be in state"
        assert "\\wolfSeq" in state, "Wolf Pbindef should be in state"

    def test_state_after_reset_has_effects(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """After failsafe reset, composition state should include effect slots."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")
        
        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))
        
        rag_fallback = gui_backend._rag_failsafe_lookup("wolf")

        gui_backend.cmd_reset_composition_state({
            "code": rag_fallback,
            "active_file": "test.scd"
        })

        state = gui_backend._composition_states["test.scd"]
        
        # In sc_state_parser, effects and wetness are parsed if they exist in the text.
        # But wait, looking at sc_state_parser, it says: `slot 10: FreeVerb.ar`
        # Let's ensure they appear in the parsed string state.
        assert "FreeVerb" in state or "slot 10" in state, \
            f"State should reference effects. Got:\n{state}"

    def test_cmd_append_returns_multi_block_fallback(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """cmd_append should return a rag_fallback that contains multiple blocks."""
        chunk = "Ndef(\\wolf, {"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")
        
        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        # Mock cmd_append dependencies
        class MockLLMClient:
            def __init__(self, *a, **kw): pass
            def generate(self, prompt, sys_prompt, *a, **kw):
                # Return intentionally broken code
                return "(Ndef(\\broken, { INVALID_UGEN.ar }).play;)", {"tokens_in": 50, "tokens_out": 30}

        monkeypatch.setattr(gui_backend, '_resolve_model', lambda x: ("mock", "mock-model"))
        monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
        fake_config = type('obj', (object,), {'AVAILABLE_MODELS': {}})
        monkeypatch.setattr(gui_backend, 'config', fake_config)
        monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *a, **kw: None}))

        fake_llm = types.ModuleType("llm_engine")
        fake_llm.LLMClient = MockLLMClient
        sys.modules["llm_engine"] = fake_llm
        
        try:
            result = gui_backend.cmd_append({
                "prompt": "wolf howl",
                "active_file": "test.scd",
                "use_kb": False
            })

            fallback = result.get("rag_fallback", "")
            assert fallback, "rag_fallback should not be empty"

            # The critical check: fallback must be playable
            assert _has_ndef_play(fallback), "Fallback from cmd_append must have Ndef.play"
            assert _has_pbindef_or_pbind(fallback), "Fallback from cmd_append must have sequencer"
            assert _count_top_level_blocks(fallback) >= 2, \
                f"Fallback should have ≥2 blocks, got {_count_top_level_blocks(fallback)}"
        finally:
            if "llm_engine" in sys.modules:
                del sys.modules["llm_engine"]


# ===========================================================================
# 4. Edge cases for multi-block extraction
# ===========================================================================

class TestMultiBlockEdgeCases:
    """Edge cases specific to multi-block section extraction."""

    def test_chunk_matches_sequence_block_not_instrument(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """When the RAG chunk matches the SEQUENCE block (not the instrument),
        it should still return the full section."""
        chunk = "Pbindef(\\wolfSeq, \\dur, 3"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf sequence")

        assert _has_ndef_play(result), "Should include instrument block even when chunk matches sequence"
        assert _has_pbindef_or_pbind(result), "Should include the sequence block"

    def test_chunk_matches_effects_block(self, realistic_kb_dir, mock_retriever_for_chunk, monkeypatch):
        """When the RAG chunk matches the EFFECTS block, it should still return
        the full section (instrument + sequence + effects)."""
        chunk = "Ndef(\\wolf)[10] = \\filter"
        mock_ret = mock_retriever_for_chunk(chunk, "ndef-animals.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(realistic_kb_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("wolf effects")

        assert _has_ndef_play(result), "Should include instrument block when chunk matches effects"
        assert _has_pbindef_or_pbind(result), "Should include sequence"
        assert "\\filter" in result, "Should include effects"

    def test_last_section_without_trailing_delimiter(self, tmp_path, mock_retriever_for_chunk, monkeypatch):
        """A section at the end of the file (no trailing ////) should still work."""
        kb_content = textwrap.dedent("""\
        ////////////////////
        // --- FIRST INSTRUMENT ---
        (
        Ndef(\\first, { SinOsc.ar(440) }).play;
        )

        ////////////////////
        // --- LAST INSTRUMENT ---
        (
        Ndef(\\last, { Saw.ar(100) }).play;
        )

        (
        Pbindef(\\lastSeq, \\dur, 1, \\t_trig, 1);
        Ndef(\\last)[1] = \\set -> Pbindef(\\lastSeq);
        )
        """)

        kb_dir = tmp_path / "knowledge_base"
        kb_dir.mkdir()
        (kb_dir / "test.scd").write_text(kb_content, encoding="utf-8")

        chunk = "Ndef(\\last, { Saw.ar(100) }).play;"
        mock_ret = mock_retriever_for_chunk(chunk, "test.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(kb_dir))

        result = gui_backend._rag_failsafe_lookup("last instrument")

        assert "Ndef(\\last" in result, "Should find the last instrument"
        assert "Pbindef(\\lastSeq" in result, "Should find the sequence in the last section"
        assert "Ndef(\\first" not in result, "Should not cross into previous section"

    def test_file_without_section_delimiters_returns_single_block(self, tmp_path, mock_retriever_for_chunk, monkeypatch):
        """Files with no //// or // === delimiters should fall back to returning
        all blocks in the file (since section_start=0 and section_end=len(file))."""
        kb_content = textwrap.dedent("""\
        (
        Ndef(\\solo, { SinOsc.ar(220) }).play;
        )

        (
        Pbindef(\\soloSeq, \\dur, 0.5);
        Ndef(\\solo)[1] = \\set -> Pbindef(\\soloSeq);
        )
        """)

        kb_dir = tmp_path / "knowledge_base"
        kb_dir.mkdir()
        (kb_dir / "plain.scd").write_text(kb_content, encoding="utf-8")

        chunk = "Ndef(\\solo, { SinOsc.ar(220) }).play;"
        mock_ret = mock_retriever_for_chunk(chunk, "plain.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(kb_dir))

        result = gui_backend._rag_failsafe_lookup("solo")

        assert "Ndef(\\solo" in result
        assert "Pbindef(\\soloSeq" in result
        assert _count_top_level_blocks(result) == 2

    def test_monolithic_block_still_works(self, tmp_path, mock_retriever_for_chunk, monkeypatch):
        """Files that use the monolithic single-block style (like auto-append-rag.scd)
        should still work correctly after the multi-block changes."""
        kb_content = textwrap.dedent("""\
        // Source: append-mono.scd
        (
        Ndef(\\mono, { |freq=55, amp=0.8|
            var sig = SinOsc.ar(freq) * amp;
            Pan2.ar(sig, 0);
        }).play;

        Ndef(\\mono)[1] = \\set -> Pbind(
            \\dur, Pwhite(1.0, 3.0, inf),
            \\freq, Pwhite(40.0, 70.0, inf)
        );
        )

        // Source: append-other.scd
        (
        Ndef(\\other, { Saw.ar(100) }).play;
        )
        """)

        kb_dir = tmp_path / "knowledge_base"
        kb_dir.mkdir()
        (kb_dir / "auto-append-rag.scd").write_text(kb_content, encoding="utf-8")

        chunk = "Ndef(\\mono, { |freq=55, amp=0.8|"
        mock_ret = mock_retriever_for_chunk(chunk, "auto-append-rag.scd")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(kb_dir))

        result = gui_backend._rag_failsafe_lookup("bass rumble")

        # Should return just the mono block, not the other one
        assert "Ndef(\\mono" in result
        assert "Ndef(\\other" not in result
        # The mono block contains both Ndef and slot routing in one block
        assert "\\set -> Pbind" in result
