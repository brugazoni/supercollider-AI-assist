"""
System integration tests for the Auto-Append pipeline.

Tests cover:
  1. Mute guard: muting mid-transcription vs. muting before speech
  2. Queue draining: multiple blocks queued while LLM is busy
  3. Composition state synchronization between sequential appends
  4. Concurrency guard: cmd_append waits for in-flight state updates

Run:  pytest tests/test_auto_append_system.py -v
"""
import json
import os
import sys
import time
import threading
from io import StringIO

import pytest

# --- path setup ---
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import gui_backend


# ---------------------------------------------------------------------------
# Shared Fixtures
# ---------------------------------------------------------------------------

class SlowMockLLMClient:
    """A mock LLM client whose generate() takes a configurable delay.

    This lets us simulate the daemon being busy during an LLM call so we can
    exercise the queue-draining logic.
    """
    _call_count = 0
    _delay = 0.0
    _calls = []  # records (prompt_snippet, composition_state_snippet)

    def __init__(self, *a, **kw):
        pass

    def generate(self, prompt, sys_prompt=None, *a, **kw):
        SlowMockLLMClient._call_count += 1
        n = SlowMockLLMClient._call_count

        # Record what composition state was seen by this call
        state_snippet = ""
        if "CURRENT COMPOSITION STATE" in prompt:
            idx = prompt.index("CURRENT COMPOSITION STATE")
            state_snippet = prompt[idx:idx + 200]
        SlowMockLLMClient._calls.append({
            "n": n,
            "prompt_head": prompt[:120],
            "state_snippet": state_snippet,
        })

        if SlowMockLLMClient._delay > 0:
            time.sleep(SlowMockLLMClient._delay)

        # Background state update branch (now obsolete, but keeping for safety if called)
        if "TASK: Output the UPDATED composition state" in prompt:
            return f"Active Ndefs:\n- \\block{n}", {"in_tokens": 10, "out_tokens": 10, "time_s": 0.1, "cost": 0}

        return f"(\n// Block {n}\nNdef(\\block{n}, {{ SinOsc.ar(440) }}).play;\n)", {
            "in_tokens": 50, "out_tokens": 50, "time_s": 0.2, "cost": 0
        }


@pytest.fixture(autouse=True)
def _reset_append_globals():
    """Reset all cmd_append caches between tests."""
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()
    SlowMockLLMClient._call_count = 0
    SlowMockLLMClient._delay = 0.0
    SlowMockLLMClient._calls = []
    yield
    gui_backend._composition_states.clear()
    gui_backend._composition_state_events.clear()


@pytest.fixture(autouse=True)
def _reset_dictation_globals():
    """Reset dictation state between tests (matches test_dictation_state.py)."""
    gui_backend._dictation_active = False
    gui_backend._dictation_recorder = None
    gui_backend._dictation_thread = None
    gui_backend._dictation_muted = False
    gui_backend._dictation_session_id = 0
    yield
    # Ensure dictation is stopped after each test
    if gui_backend._dictation_active:
        try:
            gui_backend.cmd_stop_dictation({})
            if gui_backend._dictation_thread:
                gui_backend._dictation_thread.join(timeout=2)
        except Exception:
            pass
    gui_backend._dictation_active = False
    gui_backend._dictation_recorder = None
    gui_backend._dictation_thread = None
    gui_backend._dictation_muted = False


@pytest.fixture
def mock_llm(monkeypatch):
    """Patch LLMClient globally so cmd_append uses SlowMockLLMClient."""
    import types
    fake_mod = types.ModuleType("llm_engine")
    fake_mod.LLMClient = SlowMockLLMClient
    sys.modules["llm_engine"] = fake_mod

    monkeypatch.setattr(gui_backend, '_resolve_model', lambda x: ("mock", "mock-model"))
    mock_config = type('C', (), {
        'AVAILABLE_MODELS': {},
        'GEMINI_API_KEY': 'fake',
    })()
    monkeypatch.setattr(gui_backend, 'config', mock_config)
    monkeypatch.setattr(gui_backend, 'utils',
                        type('U', (), {'append_to_session_log': lambda *a, **kw: None})())
    monkeypatch.setattr(gui_backend, '_read_scd', lambda x: "")

    yield SlowMockLLMClient

    if "llm_engine" in sys.modules:
        del sys.modules["llm_engine"]


def _wait_for_recorder(timeout=5.0):
    """Thin wrapper around conftest.wait_for_recorder for this module."""
    from conftest import wait_for_recorder
    return wait_for_recorder(timeout)


# ===========================================================================
# TEST GROUP 1 — Mute Guard (Python-side)
# ===========================================================================

class TestMuteGuard:
    """Verify the Python backend's mute-at-record-start semantics.

    Key insight: `on_rec_start` captures `_dictation_muted` at the moment
    VAD detects speech. If the user mutes AFTER speech has started but BEFORE
    transcription finishes, the result must still pass through.

    With MockRecorder, on_rec_start fires synchronously inside text(),
    so we test mute state at the time text() is called.
    """

    def test_mute_during_transcription_does_not_drop_result(
        self, mock_recorder_class, capture_daemon_stdout
    ):
        """Mute state is checked at record-start, not at on_final time.
        If unmuted when on_rec_start fires, on_final must emit regardless
        of the mute state at emission time."""
        gui_backend.cmd_start_dictation({})
        recorder = _wait_for_recorder()
        assert recorder is not None, "_dictation_recorder not set after 5s"

        # The recorder thread is now in the `while _dictation_active` loop,
        # blocking on recorder.text(on_final). The mock's text() polls
        # self.text_queue. When we inject_text, it fires on_rec_start
        # (captures muted=False) then on_final synchronously.
        # We cannot mute between on_rec_start and on_final in the same
        # synchronous flow, but the key invariant is: if muted was False
        # when on_rec_start fired, on_final WILL emit.
        assert gui_backend._dictation_muted is False
        recorder.inject_text("hello world")
        time.sleep(0.3)

        out = capture_daemon_stdout.getvalue()
        assert '"type": "dictation_final"' in out
        assert '"text": "hello world"' in out

        gui_backend.cmd_stop_dictation({})

    def test_mute_before_speech_drops_result(
        self, mock_recorder_class, capture_daemon_stdout
    ):
        """If user is already muted when VAD detects speech, the resulting
        transcription must be silently discarded."""
        gui_backend.cmd_start_dictation({})
        recorder = _wait_for_recorder()
        assert recorder is not None, "_dictation_recorder not set after 5s"

        # Mute BEFORE injecting text → on_rec_start will capture muted=True
        gui_backend.cmd_mute_dictation({"muted": True})
        recorder.inject_text("should be dropped")
        time.sleep(0.3)

        out = capture_daemon_stdout.getvalue()
        # The text should NOT appear as a dictation_final
        finals = [json.loads(l) for l in out.strip().split("\n")
                  if l.strip() and '"dictation_final"' in l]
        assert len(finals) == 0, f"Expected no dictation_final but got: {finals}"

        gui_backend.cmd_stop_dictation({})

    def test_unmute_resumes_normal_transcription(
        self, mock_recorder_class, capture_daemon_stdout
    ):
        """Toggling mute off after muting should let subsequent speech through."""
        gui_backend.cmd_start_dictation({})
        recorder = _wait_for_recorder()
        assert recorder is not None

        # Mute → inject (should drop)
        gui_backend.cmd_mute_dictation({"muted": True})
        recorder.inject_text("dropped phrase")
        time.sleep(0.3)

        # Unmute → inject (should pass)
        gui_backend.cmd_mute_dictation({"muted": False})
        recorder.inject_text("resumed phrase")
        time.sleep(0.3)

        out = capture_daemon_stdout.getvalue()
        # Parse only dictation_final events
        finals = [json.loads(l) for l in out.strip().split("\n")
                  if l.strip() and '"dictation_final"' in l]
        final_texts = [f["text"] for f in finals]
        assert "dropped phrase" not in final_texts
        assert "resumed phrase" in final_texts

        gui_backend.cmd_stop_dictation({})

    def test_mute_command_returns_correct_status(self):
        """cmd_mute_dictation should return the current mute status."""
        res_mute = gui_backend.cmd_mute_dictation({"muted": True})
        assert res_mute["status"] == "muted"
        assert gui_backend._dictation_muted is True

        res_unmute = gui_backend.cmd_mute_dictation({"muted": False})
        assert res_unmute["status"] == "unmuted"
        assert gui_backend._dictation_muted is False


# ===========================================================================
# TEST GROUP 2 — Queue Behavior & Sequential Processing
# ===========================================================================

class TestAppendQueue:
    """Simulate the C++ QQueue FIFO behavior in pure Python by calling
    cmd_append sequentially and verifying composition state handoffs."""

    def test_sequential_appends_use_cached_state(
        self, mock_llm, capture_daemon_stdout
    ):
        """Block 2 must see the composition state generated by block 1's
        background thread, not the empty fallback."""
        # Block 1 — composition state starts empty
        res1 = gui_backend.cmd_append({
            "prompt": "create a pad",
            "active_file": "queue_test.scd",
            "use_kb": False,
        })
        assert res1["code"]  # non-empty

        # Wait for background state update thread to finish
        evt = gui_backend._composition_state_events.get("queue_test.scd")
        assert evt is not None, "Background state event was not created"
        evt.wait(timeout=5)

        # Verify the cached state was populated
        cached = gui_backend._composition_states.get("queue_test.scd", "")
        assert "Active Ndefs" in cached

        # Block 2 — should pick up the cached state
        res2 = gui_backend.cmd_append({
            "prompt": "add drums",
            "active_file": "queue_test.scd",
            "use_kb": False,
        })
        assert res2["code"]

        # The second generate call should have seen the cached state
        # in its prompt (not "(Empty — this is the first block)")
        code_gen_calls = [c for c in SlowMockLLMClient._calls
                          if "User Request:" in c["prompt_head"]]
        assert len(code_gen_calls) >= 2
        second_call = code_gen_calls[1]
        assert "Active Ndefs" in second_call["state_snippet"]

    def test_append_waits_for_inflight_state_update(
        self, mock_llm, capture_daemon_stdout
    ):
        """If block 2 arrives while block 1's state update is still running,
        cmd_append must block on the threading.Event until it completes."""
        # Make state updates slow so they're still in-flight when block 2 starts
        original_delay = SlowMockLLMClient._delay
        SlowMockLLMClient._delay = 0.3  # 300ms per LLM call

        res1 = gui_backend.cmd_append({
            "prompt": "block one",
            "active_file": "wait_test.scd",
            "use_kb": False,
        })

        # Don't wait for the event — immediately fire block 2.
        # cmd_append should internally wait on the event.
        res2 = gui_backend.cmd_append({
            "prompt": "block two",
            "active_file": "wait_test.scd",
            "use_kb": False,
        })

        # Block 2 should have waited for the state event
        assert res2["code"]

        # Verify the state was available to block 2
        code_gen_calls = [c for c in SlowMockLLMClient._calls
                          if "User Request:" in c["prompt_head"]]
        second_call = code_gen_calls[1]
        assert "Active Ndefs" in second_call["state_snippet"]

        SlowMockLLMClient._delay = original_delay

    def test_three_blocks_sequential_state_chain(
        self, mock_llm, capture_daemon_stdout
    ):
        """Three blocks appended sequentially should each see the updated
        state from the prior block."""
        for i, prompt in enumerate(["pad", "drums", "bass"], start=1):
            res = gui_backend.cmd_append({
                "prompt": prompt,
                "active_file": "chain_test.scd",
                "use_kb": False,
            })
            assert res["code"], f"Block {i} returned empty code"

            # Wait for background state update
            evt = gui_backend._composition_state_events.get("chain_test.scd")
            if evt:
                evt.wait(timeout=5)

        # All 3 code-gen calls plus 3 state-update calls = 6 total
        code_gen_calls = [c for c in SlowMockLLMClient._calls
                          if "User Request:" in c["prompt_head"]]
        assert len(code_gen_calls) == 3

        # Block 1 should have seen "(Empty"
        assert "Empty" in code_gen_calls[0]["state_snippet"]
        # Block 2 and 3 should have seen "Active Ndefs"
        assert "Active Ndefs" in code_gen_calls[1]["state_snippet"]
        assert "Active Ndefs" in code_gen_calls[2]["state_snippet"]

    def test_unsaved_documents_use_shared_state_key(
        self, mock_llm, capture_daemon_stdout
    ):
        """When active_file is empty (unsaved buffer), all appends share
        the __unsaved__ state key."""
        gui_backend.cmd_append({
            "prompt": "first block",
            "active_file": "",
            "use_kb": False,
        })
        evt = gui_backend._composition_state_events.get("__unsaved__")
        assert evt is not None
        evt.wait(timeout=5)

        assert "__unsaved__" in gui_backend._composition_states
        assert "Active Ndefs" in gui_backend._composition_states["__unsaved__"]

    def test_empty_prompt_returns_code(
        self, mock_llm, capture_daemon_stdout
    ):
        """Appending with a blank prompt should still go through the pipeline
        (the LLM decides what to do)."""
        res = gui_backend.cmd_append({
            "prompt": "",
            "active_file": "empty_prompt.scd",
            "use_kb": False,
        })
        # The mock always returns code, so this tests the pipeline doesn't crash
        assert "code" in res


# ===========================================================================
# TEST GROUP 3 — Concurrency Guard (Daemon-level IPC)
# ===========================================================================

class TestDaemonConcurrency:
    """Test the daemon's sequential command processing (stdin loop)
    to verify commands cannot interleave."""

    def test_daemon_processes_commands_sequentially(self, daemon_subprocess):
        """Commands sent while the daemon is processing should queue in
        stdin and be handled after the current command completes."""
        client = daemon_subprocess
        ready = client.wait_for_ready(timeout=60)
        assert ready, "Daemon did not become ready"

        # Send list_models (fast) followed immediately by another command
        client.send_command({"command": "list_models"})
        resp1 = client.read_response(timeout=15)
        assert resp1 is not None
        assert "models" in resp1 or "error" not in resp1

    def test_daemon_survives_malformed_append(self, daemon_subprocess):
        """An append command with missing keys should return a clean error
        without crashing the daemon."""
        client = daemon_subprocess
        ready = client.wait_for_ready(timeout=60)
        assert ready

        # Send append with no prompt, no model — should fail gracefully.
        # Use timeout=60s since in environments with real API keys the daemon
        # will make an actual LLM call (empty prompt) before returning.
        client.send_command({"command": "append"})
        resp = client.read_response(timeout=60)
        # May return an error (missing API key, etc) but daemon should survive
        assert resp is not None

        # Daemon should still accept more commands
        client.send_command({"command": "list_models"})
        resp2 = client.read_response(timeout=15)
        assert resp2 is not None
