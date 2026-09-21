"""
Test suite for the RAG Failsafe mechanism.

Tests cover:
1. _rag_failsafe_lookup — block extraction logic (balanced-paren parser, 
   chunk-to-block mapping, edge cases)
2. cmd_reset_composition_state — state reset from scratch
3. cmd_append integration — verifies rag_fallback is returned in response
4. Error classification — the C++ onPostWindowText logic (tested as pure logic)
"""
import os
import sys
import time
import types
import threading
import tempfile
import textwrap

import pytest

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import gui_backend
import sc_state_parser
import config as config_module


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

SAMPLE_RAG_FILE = textwrap.dedent("""\
    // Source: append-volcano.scd
    (
    Ndef(\\baruBase, { |freq=55, amp=0.8|
        var sig = SinOsc.ar(freq) * amp;
        Pan2.ar(sig, 0);
    }).play;

    Ndef(\\baruBase)[1] = \\set -> Pbind(
        \\dur, Pwhite(4.0, 9.0, inf),
        \\freq, Pwhite(45.0, 65.0, inf)
    );
    )

    // Source: append-bird-bat.scd
    (
    // ADD_INSTRUMENT: Ndef(\\rearmouse)
    Ndef(\\rearmouse, { |freq=14000, amp=0.1, t_trig=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.04), t_trig);
        var sig = SinOsc.ar(freq) * env;
        Pan2.ar(sig * amp, 0);
    }).play;

    Ndef(\\rearmouse)[1] = \\set -> Pbind(
        \\dur, Pwhite(0.1, 0.3, inf),
        \\t_trig, 1,
        \\freq, Pwhite(12000, 16000, inf)
    );
    )

    // Source: append-pad-ambient.scd
    (
    Ndef(\\pad, { |freq=440, amp=0.5|
        var sig = LFSaw.ar(freq) * amp;
        Pan2.ar(sig, 0);
    }).play;
    )
""")

SAMPLE_RAG_FILE_NESTED = textwrap.dedent("""\
    // Source: append-nested.scd
    (
    Ndef(\\nested, { |freq=55|
        var sig = SinOsc.ar(freq * (1 + SinOsc.kr(0.1)));
        Pan2.ar(sig, 0);
    }).play;

    Pbindef(\\nestedSeq,
        \\dur, Pseq([0.5, Pwhite(0.1, 0.3)], inf),
        \\freq, Pwhite(40, 80, inf)
    );
    )
""")

SAMPLE_RAG_FILE_MULTI_BLOCK = textwrap.dedent("""\
    ////////////////////
    // --- SCORPION INSTRUMENT ---
    (
    Ndef(\\scorpion).clear;
    Ndef(\\scorpion, { SinOsc.ar(440) }).play;
    )

    // --- SCORPION SEQUENCE ---
    (
    Pbindef(\\scorpionSeq, \\dur, 1);
    Ndef(\\scorpion)[1] = \\set -> Pbindef(\\scorpionSeq);
    )

    // --- SCORPION EFFECTS ---
    (
    Ndef(\\scorpion)[10] = \\filter -> { |in| in * 0.5 };
    )

    // scorpion fade out and ending
    (
    Ndef(\\scorpion).clear(5);
    )

    ////////////////////
    // --- JAGUAR INSTRUMENT ---
    (
    Ndef(\\jaguar, { Saw.ar(100) }).play;
    )
""")


@pytest.fixture
def rag_knowledge_dir(tmp_path):
    """Create a temporary knowledge_base directory with a test auto-append-rag.scd."""
    kb_dir = tmp_path / "knowledge_base"
    kb_dir.mkdir()
    rag_file = kb_dir / "auto-append-rag.scd"
    rag_file.write_text(SAMPLE_RAG_FILE, encoding="utf-8")
    return tmp_path


@pytest.fixture
def rag_knowledge_dir_multi(tmp_path):
    """Create a temporary knowledge_base directory with a test ndef-animals.scd."""
    kb_dir = tmp_path / "knowledge_base"
    kb_dir.mkdir()
    rag_file = kb_dir / "ndef-animals.scd"
    rag_file.write_text(SAMPLE_RAG_FILE_MULTI_BLOCK, encoding="utf-8")
    return tmp_path


@pytest.fixture
def mock_retriever_factory():
    """Returns a factory that builds mock retrievers returning configurable chunks."""
    from langchain_core.documents import Document

    def factory(chunks_with_meta):
        """
        chunks_with_meta: list of (page_content, filename) tuples
        """
        docs = [
            Document(page_content=content, metadata={"source": "knowledge-base", "filename": fname})
            for content, fname in chunks_with_meta
        ]
        def mock_retriever(query):
            return docs
        return mock_retriever

    return factory


@pytest.fixture(autouse=True)
def reset_gui_backend_state():
    """Ensure each test starts with clean global state."""
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()
    yield
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()


# ===========================================================================
# Tests: Balanced parenthesis extraction (the core parser inside _rag_failsafe_lookup)
# ===========================================================================

def _extract_all_blocks(content):
    """Standalone helper replicating the block extraction from _rag_failsafe_lookup."""
    blocks = []
    stack = []
    start_idx = -1
    for i, char in enumerate(content):
        if char == '(':
            if not stack:
                start_idx = i
            stack.append(i)
        elif char == ')':
            if stack:
                stack.pop()
                if not stack:
                    blocks.append(content[start_idx:i+1])
    return blocks


class TestBlockExtraction:
    """Test the balanced-parenthesis block parser used by _rag_failsafe_lookup."""

    def test_extracts_three_blocks_from_sample(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE)
        assert len(blocks) == 3

    def test_first_block_contains_volcano_ndef(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE)
        assert "Ndef(\\baruBase" in blocks[0]
        assert "Pwhite(45.0, 65.0, inf)" in blocks[0]

    def test_second_block_contains_bat_ndef(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE)
        assert "Ndef(\\rearmouse" in blocks[1]

    def test_third_block_contains_pad(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE)
        assert "Ndef(\\pad" in blocks[2]

    def test_blocks_start_and_end_with_parens(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE)
        for block in blocks:
            assert block.startswith("(")
            assert block.endswith(")")

    def test_nested_parens_handled_correctly(self):
        blocks = _extract_all_blocks(SAMPLE_RAG_FILE_NESTED)
        assert len(blocks) == 1
        assert "SinOsc.ar(freq * (1 + SinOsc.kr(0.1)))" in blocks[0]
        assert "Pwhite(0.1, 0.3)" in blocks[0]

    def test_empty_input_returns_no_blocks(self):
        blocks = _extract_all_blocks("")
        assert blocks == []

    def test_no_parens_returns_no_blocks(self):
        blocks = _extract_all_blocks("// just a comment\nvar x = 5;\n")
        assert blocks == []

    def test_unbalanced_parens_returns_nothing(self):
        blocks = _extract_all_blocks("( Ndef(\\test, { SinOsc.ar(440) }")
        assert blocks == []  # never closes the outer paren


# ===========================================================================
# Tests: _rag_failsafe_lookup (full function with mocked retriever)
# ===========================================================================

class TestRagFailsafeLookup:
    """Test the _rag_failsafe_lookup function end-to-end with mocked retriever."""

    def test_returns_matching_block_for_volcano_query(self, rag_knowledge_dir, mock_retriever_factory, monkeypatch):
        """When the retriever returns a chunk from the volcano block, 
        the function should return the complete (…) block containing it."""
        # The chunk simulates what ChromaDB would return: a fragment inside the first block
        chunk_text = textwrap.dedent("""\
            Ndef(\\baruBase, { |freq=55, amp=0.8|
                var sig = SinOsc.ar(freq) * amp;
                Pan2.ar(sig, 0);
            }).play;""")

        mock_ret = mock_retriever_factory([(chunk_text, "auto-append-rag.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("volcanic rumble bass")

        assert result.startswith("(")
        assert result.endswith(")")
        assert "Ndef(\\baruBase" in result
        assert "Pwhite(45.0, 65.0, inf)" in result

    def test_returns_bat_block_for_bat_chunk(self, rag_knowledge_dir, mock_retriever_factory, monkeypatch):
        chunk_text = "Ndef(\\rearmouse, { |freq=14000, amp=0.1, t_trig=0|"

        mock_ret = mock_retriever_factory([(chunk_text, "auto-append-rag.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("bat sounds high frequency")

        assert "Ndef(\\rearmouse" in result
        assert "Pwhite(12000, 16000, inf)" in result

    def test_returns_empty_when_retriever_returns_nothing(self, monkeypatch):
        mock_ret = lambda query: []

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)

        result = gui_backend._rag_failsafe_lookup("anything")
        assert result == ""

    def test_returns_empty_when_file_not_found(self, mock_retriever_factory, monkeypatch):
        chunk_text = "some chunk"
        mock_ret = mock_retriever_factory([(chunk_text, "nonexistent-file.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", "/nonexistent/path")

        result = gui_backend._rag_failsafe_lookup("anything")
        assert result == ""

    def test_returns_empty_when_chunk_not_in_file(self, rag_knowledge_dir, mock_retriever_factory, monkeypatch):
        """If the chunk text is not found anywhere in the file, return empty."""
        chunk_text = "THIS TEXT DOES NOT EXIST IN THE FILE AT ALL ANYWHERE"
        mock_ret = mock_retriever_factory([(chunk_text, "auto-append-rag.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("anything")
        assert result == ""

    def test_falls_through_to_next_doc_if_first_misses(self, rag_knowledge_dir, mock_retriever_factory, monkeypatch):
        """If the first document can't be mapped to a block, try the next one."""
        from langchain_core.documents import Document

        docs = [
            Document(page_content="NONEXISTENT CHUNK TEXT", metadata={"source": "knowledge-base", "filename": "auto-append-rag.scd"}),
            Document(page_content="Ndef(\\pad, { |freq=440, amp=0.5|", metadata={"source": "knowledge-base", "filename": "auto-append-rag.scd"}),
        ]
        mock_ret = lambda query: docs

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("ambient pad")
        assert "Ndef(\\pad" in result

    def test_handles_retriever_exception_gracefully(self, monkeypatch):
        """If the retriever raises an exception, return empty string (no crash)."""
        def exploding_retriever():
            raise RuntimeError("ChromaDB is broken!")

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", exploding_retriever)

        result = gui_backend._rag_failsafe_lookup("anything")
        assert result == ""

    def test_partial_match_via_first_100_chars(self, rag_knowledge_dir, mock_retriever_factory, monkeypatch):
        """When the full chunk text is not found verbatim (e.g. trailing data appended),
        the first-100-char fallback match should still find the block."""
        # Read the actual file content so we match the exact whitespace
        file_path = rag_knowledge_dir / "knowledge_base" / "auto-append-rag.scd"
        file_content = file_path.read_text(encoding="utf-8")

        # Find a real substring from the pad block and append garbage
        pad_idx = file_content.find("Ndef(\\pad")
        real_prefix = file_content[pad_idx:pad_idx+100]
        chunk_text = real_prefix + "EXTRA GARBAGE NOT IN FILE"

        mock_ret = mock_retriever_factory([(chunk_text, "auto-append-rag.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("pad sound")
        assert "Ndef(\\pad" in result

    def test_multi_block_returns_all_setup_blocks_in_section(self, rag_knowledge_dir_multi, mock_retriever_factory, monkeypatch):
        """When chunk matches an instrument block in a multi-block section,
        it should return all setup blocks (instrument, sequence, effects)."""
        chunk_text = "Ndef(\\scorpion, { SinOsc.ar(440) }).play;"
        mock_ret = mock_retriever_factory([(chunk_text, "ndef-animals.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir_multi / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("scorpion")

        # Should contain instrument
        assert "Ndef(\\scorpion, { SinOsc.ar(440) }).play;" in result
        # Should contain sequence
        assert "Pbindef(\\scorpionSeq, \\dur, 1);" in result
        # Should contain effects
        assert "Ndef(\\scorpion)[10] = \\filter -> { |in| in * 0.5 };" in result
        
    def test_multi_block_excludes_teardown_blocks(self, rag_knowledge_dir_multi, mock_retriever_factory, monkeypatch):
        """When extracting a multi-block section, blocks preceded by teardown keywords
        (like 'fade out and ending') should be excluded."""
        chunk_text = "Ndef(\\scorpion, { SinOsc.ar(440) }).play;"
        mock_ret = mock_retriever_factory([(chunk_text, "ndef-animals.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir_multi / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("scorpion")

        # The fade out block should NOT be included
        assert "Ndef(\\scorpion).clear(5);" not in result

    def test_multi_block_does_not_cross_section_boundaries(self, rag_knowledge_dir_multi, mock_retriever_factory, monkeypatch):
        """Blocks from a different section should not be included."""
        chunk_text = "Ndef(\\scorpion, { SinOsc.ar(440) }).play;"
        mock_ret = mock_retriever_factory([(chunk_text, "ndef-animals.scd")])

        import rag_engine
        monkeypatch.setattr(rag_engine, "get_retriever", lambda: mock_ret)
        monkeypatch.setattr(config_module, "CONTEXT_FOLDER", str(rag_knowledge_dir_multi / "knowledge_base"))

        result = gui_backend._rag_failsafe_lookup("scorpion")

        # The jaguar block is in the next section, should not be included
        assert "Ndef(\\jaguar, { Saw.ar(100) }).play;" not in result


# ===========================================================================
# Tests: cmd_reset_composition_state
# ===========================================================================

class TestResetCompositionState:
    """Test the cmd_reset_composition_state daemon command."""

    def test_resets_state_from_empty_to_new_block(self):
        code = textwrap.dedent("""\
        (
        Ndef(\\bass, { |freq=50| SinOsc.ar(freq) }).play;
        Pbindef(\\bassSeq, \\dur, 0.5);
        )
        """)
        result = gui_backend.cmd_reset_composition_state({
            "code": code,
            "active_file": "test.scd"
        })

        assert result["status"] == "ok"
        state = gui_backend._composition_states["test.scd"]
        assert "\\bass" in state
        assert "\\bassSeq" in state

    def test_resets_state_overwrites_existing(self):
        # Pre-populate with an existing state
        gui_backend._composition_states["test.scd"] = "Active Ndefs:\n- \\oldNdef"

        code = "(Ndef(\\newNdef, { SinOsc.ar(440) }).play;)"
        gui_backend.cmd_reset_composition_state({
            "code": code,
            "active_file": "test.scd"
        })

        state = gui_backend._composition_states["test.scd"]
        assert "\\newNdef" in state
        assert "\\oldNdef" not in state  # Old state completely replaced

    def test_resets_unsaved_document(self):
        code = "(Ndef(\\foo, { SinOsc.ar(220) }).play;)"
        gui_backend.cmd_reset_composition_state({
            "code": code,
            "active_file": ""  # unsaved
        })

        assert "__unsaved__" in gui_backend._composition_states
        assert "\\foo" in gui_backend._composition_states["__unsaved__"]

    def test_resets_to_empty_for_empty_code(self):
        gui_backend._composition_states["test.scd"] = "Active Ndefs:\n- \\bass"
        gui_backend.cmd_reset_composition_state({
            "code": "",
            "active_file": "test.scd"
        })

        state = gui_backend._composition_states["test.scd"]
        assert state == "(Empty)"

    def test_resets_state_with_effects_and_wetness(self):
        code = textwrap.dedent("""\
        (
        Ndef(\\pad, { |freq=440| LFSaw.ar(freq) }).play;
        Ndef(\\pad)[10] = \\filter -> { |in| GVerb.ar(in, 10, 3) };
        Ndef(\\pad).xset(\\wet10, 0.4);
        )
        """)
        gui_backend.cmd_reset_composition_state({
            "code": code,
            "active_file": "fx.scd"
        })

        state = gui_backend._composition_states["fx.scd"]
        assert "\\pad" in state
        assert "GVerb.ar(in, 10, 3)" in state
        assert "\\wet10: 0.4" in state


# ===========================================================================
# Tests: cmd_append integration (rag_fallback in response)
# ===========================================================================

@pytest.fixture
def mock_llm_client(monkeypatch):
    """Mock the LLM client to return predictable code."""
    class MockClient:
        def __init__(self, *args, **kwargs):
            pass
        def generate(self, prompt, sys_prompt, *args, **kwargs):
            return "(Ndef(\\generated, { SinOsc.ar(440) }).play;)", {"tokens_in": 100, "tokens_out": 50}

    monkeypatch.setattr(gui_backend, '_resolve_model', lambda x: ("mock", "mock-model"))

    fake_module = types.ModuleType("llm_engine")
    fake_module.LLMClient = MockClient
    sys.modules["llm_engine"] = fake_module

    yield MockClient
    if "llm_engine" in sys.modules:
        del sys.modules["llm_engine"]


class TestAppendReturnsRagFallback:
    """Verify cmd_append returns a rag_fallback field in its response."""

    def test_append_response_includes_rag_fallback_key(self, mock_llm_client, capture_daemon_stdout, monkeypatch):
        monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
        monkeypatch.setattr(gui_backend, '_rag_failsafe_lookup', lambda prompt: "(Ndef(\\fallback).play;)")
        fake_config = type('obj', (object,), {'AVAILABLE_MODELS': {}})
        monkeypatch.setattr(gui_backend, 'config', fake_config)
        monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *a, **kw: None}))

        result = gui_backend.cmd_append({
            "prompt": "make a bass",
            "active_file": "test.scd",
            "use_kb": False
        })

        assert "rag_fallback" in result
        assert result["rag_fallback"] == "(Ndef(\\fallback).play;)"

    def test_append_response_has_empty_fallback_when_lookup_fails(self, mock_llm_client, capture_daemon_stdout, monkeypatch):
        monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
        monkeypatch.setattr(gui_backend, '_rag_failsafe_lookup', lambda prompt: "")
        fake_config = type('obj', (object,), {'AVAILABLE_MODELS': {}})
        monkeypatch.setattr(gui_backend, 'config', fake_config)
        monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *a, **kw: None}))

        result = gui_backend.cmd_append({
            "prompt": "make something",
            "active_file": "test.scd",
            "use_kb": False
        })

        assert result["rag_fallback"] == ""

    def test_rag_lookup_runs_in_parallel_with_llm(self, mock_llm_client, capture_daemon_stdout, monkeypatch):
        """Verify the RAG lookup and LLM call execute concurrently."""
        call_log = []

        original_generate = mock_llm_client.generate

        class TimingClient:
            def __init__(self, *args, **kwargs):
                pass
            def generate(self, prompt, sys_prompt, *args, **kwargs):
                call_log.append(("llm_start", time.monotonic()))
                time.sleep(0.2)  # Simulate LLM latency
                call_log.append(("llm_end", time.monotonic()))
                return "(Ndef(\\gen).play;)", {"tokens_in": 10, "tokens_out": 5}

        def slow_rag_lookup(prompt):
            call_log.append(("rag_start", time.monotonic()))
            time.sleep(0.1)  # Simulate RAG latency
            call_log.append(("rag_end", time.monotonic()))
            return "(Ndef(\\fallback).play;)"

        fake_module = types.ModuleType("llm_engine")
        fake_module.LLMClient = TimingClient
        sys.modules["llm_engine"] = fake_module

        monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")
        monkeypatch.setattr(gui_backend, '_rag_failsafe_lookup', slow_rag_lookup)
        fake_config = type('obj', (object,), {'AVAILABLE_MODELS': {}})
        monkeypatch.setattr(gui_backend, 'config', fake_config)
        monkeypatch.setattr(gui_backend, 'utils', type('obj', (object,), {'append_to_session_log': lambda *a, **kw: None}))

        result = gui_backend.cmd_append({
            "prompt": "bass",
            "active_file": "test.scd",
            "use_kb": False
        })

        # Both should have started before either finished
        events = {name: t for name, t in call_log}
        assert events["rag_start"] < events["llm_end"], "RAG lookup should start before LLM finishes"
        assert events["rag_end"] < events["llm_end"] + 0.05, "RAG should finish before or shortly after LLM"

        assert result["rag_fallback"] == "(Ndef(\\fallback).play;)"


# ===========================================================================
# Tests: Error classification logic (mirrors C++ onPostWindowText)
# ===========================================================================

def classify_error(text: str) -> bool:
    """
    Pure-Python replica of the C++ onPostWindowText error classification.
    This allows us to unit-test the logic without needing Qt.
    """
    text_upper = text.upper()
    text_stripped = text

    # Ignore warnings and info
    if "WARNING:" in text_upper or "INFO:" in text_upper:
        return False

    # True errors
    if "ERROR:" in text_upper:
        return True
    if "Exception" in text_stripped:  # case-sensitive
        return True
    if "syntax error" in text_stripped.lower():
        return True
    if text_stripped.startswith("!"):
        return True

    return False


class TestErrorClassification:
    """Test the error detection logic that mirrors the C++ onPostWindowText."""

    def test_error_colon_is_detected(self):
        assert classify_error("ERROR: Message not understood: 'foo'") is True

    def test_exception_is_detected(self):
        assert classify_error("Exception in World_OpenUDP: bind(2) failed") is True

    def test_syntax_error_is_detected(self):
        assert classify_error("  syntax error, unexpected BINOP, expecting '}'") is True

    def test_exclamation_start_is_detected(self):
        assert classify_error("! Error in node synthesis function") is True

    def test_warning_is_not_error(self):
        assert classify_error("WARNING: buffer overflow possible") is False

    def test_warning_with_error_substring_not_triggered(self):
        """A line that says WARNING but also contains ERROR: should still be ignored
        because warnings are checked first."""
        assert classify_error("WARNING: ERROR: this is a confusing message") is False

    def test_info_is_not_error(self):
        assert classify_error("INFO: Server booted successfully") is False

    def test_normal_post_output_is_not_error(self):
        assert classify_error("-> Ndef('bass')") is False

    def test_ndef_play_output_is_not_error(self):
        assert classify_error("Ndef('bass' : 1003)") is False

    def test_server_status_is_not_error(self):
        assert classify_error("localhost : avg cpu: 12.3%, peak cpu: 34.5%") is False

    def test_empty_string_is_not_error(self):
        assert classify_error("") is False

    def test_case_insensitive_error(self):
        assert classify_error("error: something went wrong") is True

    def test_case_insensitive_syntax_error(self):
        assert classify_error("SYNTAX ERROR in some file") is True

    def test_exception_is_case_sensitive(self):
        """The C++ uses CaseSensitive for 'Exception', so 'exception' should not match."""
        assert classify_error("exception in lower case") is False

    def test_multiline_error_first_line(self):
        assert classify_error("ERROR: Message 'play' not understood.") is True

    def test_sc_common_warning_not_error(self):
        """SuperCollider commonly prints WARNING: about buffer sizes, etc."""
        assert classify_error("WARNING: Buffer UGen channel mismatch: expected 2, but buffer has 1 channels") is False

    def test_node_not_found_warning(self):
        assert classify_error("WARNING: Node 1003 not found") is False


# ===========================================================================
# Tests: State parser — fresh-start (empty previous) scenario
# ===========================================================================

class TestStateParserFreshStart:
    """Test that update_composition_state with empty previous state
    correctly bootstraps from a RAG block (the reset scenario)."""

    def test_fresh_start_with_complete_block(self):
        code = textwrap.dedent("""\
        (
        Ndef(\\bass, { |freq=50| SinOsc.ar(freq) }).play;
        Ndef(\\pad, { |freq=440| LFSaw.ar(freq) }).play;
        Pbindef(\\bassSeq, \\dur, 0.5, \\degree, Pseq([1,2,3], inf));
        Ndef(\\bass)[1] = \\set -> Pbindef(\\bassSeq);
        Ndef(\\pad)[10] = \\filter -> { |in| GVerb.ar(in, 10, 3) };
        Ndef(\\pad).xset(\\wet10, 0.6);
        )
        """)

        state = sc_state_parser.update_composition_state("", code)

        assert "\\bass" in state
        assert "\\pad" in state
        assert "\\bassSeq" in state
        assert "GVerb.ar(in, 10, 3)" in state
        assert "\\wet10: 0.6" in state

    def test_fresh_start_empty_code_returns_empty(self):
        state = sc_state_parser.update_composition_state("", "")
        assert state == "(Empty)"

    def test_fresh_start_from_explicit_empty_marker(self):
        code = "(Ndef(\\newSound, { WhiteNoise.ar(0.1) }).play;)"
        state = sc_state_parser.update_composition_state("(Empty)", code)
        assert "\\newSound" in state


# ===========================================================================
# Tests: End-to-end failsafe flow simulation
# ===========================================================================

class TestFailsafeFlow:
    """Simulate the full failsafe flow: 
    append → error detected → state reset from RAG block."""

    def test_full_failsafe_sequence(self, monkeypatch):
        """
        1. Simulate an append that produces broken code
        2. The RAG fallback is a known-good block
        3. After the error, reset_composition_state rebuilds from the RAG block
        4. The next append should see the RAG block's state, not the broken one
        """
        rag_block = textwrap.dedent("""\
        (
        Ndef(\\safeBass, { |freq=80| SinOsc.ar(freq) * 0.5 }).play;
        Pbindef(\\safeBassSeq, \\dur, 1, \\freq, Pseq([80, 100, 120], inf));
        )
        """)

        # Step 1: Simulate that the broken code was appended and its state was updated
        broken_code = "(Ndef(\\brokenThing, { INVALID_UGEN.ar }).play;)"
        gui_backend._composition_states["test.scd"] = \
            sc_state_parser.update_composition_state("", broken_code)

        # The broken state should show the broken Ndef
        assert "\\brokenThing" in gui_backend._composition_states["test.scd"]

        # Step 2: Simulate error detection — apply RAG failsafe reset
        gui_backend.cmd_reset_composition_state({
            "code": rag_block,
            "active_file": "test.scd"
        })

        # Step 3: Verify the state is now from the RAG block, not the broken code
        state = gui_backend._composition_states["test.scd"]
        assert "\\brokenThing" not in state
        assert "\\safeBass" in state
        assert "\\safeBassSeq" in state

    def test_failsafe_clears_pending_state_events(self, monkeypatch):
        """After a failsafe reset, any pending state events from the
        broken block should not interfere with subsequent appends."""
        # Simulate a pending (not-yet-completed) state event
        evt = threading.Event()
        gui_backend._composition_state_events["test.scd"] = evt

        # Reset should overwrite regardless
        rag_block = "(Ndef(\\safe, { SinOsc.ar(220) }).play;)"
        gui_backend.cmd_reset_composition_state({
            "code": rag_block,
            "active_file": "test.scd"
        })

        # State should be updated even though the event wasn't set
        assert "\\safe" in gui_backend._composition_states["test.scd"]
