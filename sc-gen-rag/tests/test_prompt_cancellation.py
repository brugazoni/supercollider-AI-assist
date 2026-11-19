import json
import socket
import threading
import time
import pytest

import gui_backend
from llm_engine import LLMClient, RequestCancelledError


def test_llm_client_cancel_aborts_stalled_openai_socket(monkeypatch):
    """Calling client.cancel() from another thread must abort a hung OpenAI/OpenRouter socket immediately."""
    srv = socket.socket()
    srv.bind(("127.0.0.1", 0))
    srv.listen(1)
    port = srv.getsockname()[1]

    accepted = []

    def accept_and_hang():
        try:
            conn, _ = srv.accept()
            accepted.append(conn)
        except OSError:
            pass
        # Keep socket open without sending any HTTP response

    threading.Thread(target=accept_and_hang, daemon=True).start()

    monkeypatch.setattr(gui_backend.config, "OPENROUTER_API_KEY", "test-key")
    import llm_engine
    monkeypatch.setattr(llm_engine.config, "OPENROUTER_API_KEY", "test-key")

    cancel_event = threading.Event()
    client = LLMClient(provider="openrouter", model_name="openai/gpt-6-luna", cancel_event=cancel_event)
    # Point at the stalled local socket
    client.openai_client.base_url = f"http://127.0.0.1:{port}/v1/"

    t0 = time.monotonic()

    def trigger_cancel():
        time.sleep(0.2)
        client.cancel()

    threading.Thread(target=trigger_cancel, daemon=True).start()

    try:
        with pytest.raises(RequestCancelledError):
            client.generate("compose a dark ambient piece", "system")
    finally:
        for c in accepted:
            try:
                c.close()
            except Exception:
                pass
        srv.close()

    elapsed = time.monotonic() - t0
    assert elapsed < 3.0, f"Expected immediate abort on cancel(), took {elapsed:.2f}s"


def test_llm_client_pre_cancelled_event_raises_immediately(monkeypatch):
    import llm_engine
    monkeypatch.setattr(llm_engine.config, "OPENROUTER_API_KEY", "test-key")
    cancel_event = threading.Event()
    cancel_event.set()
    client = LLMClient(provider="openrouter", model_name="openai/gpt-6-luna", cancel_event=cancel_event)
    with pytest.raises(RequestCancelledError):
        client.generate("hello", "sys")


def test_cross_append_cancellation_skips_stage2_and_logging(monkeypatch):
    """Cancelling during Stage 1 of cmd_cross_append must abort before Stage 2 and skip session logging."""
    calls = []
    logs = []
    started = threading.Event()

    class BlockingFakeClient:
        def __init__(self, provider=None, model_name=None, cancel_event=None):
            self.cancel_event = cancel_event
            calls.append((provider, model_name))

        def cancel(self):
            if self.cancel_event:
                self.cancel_event.set()

        def generate(self, prompt, system_instruction=None, temperature=0.7, thinking_budget=0):
            started.set()
            # Block until cancelled
            assert self.cancel_event.wait(timeout=5.0)
            raise RequestCancelledError("Request cancelled")

    import llm_engine
    monkeypatch.setattr(llm_engine, "LLMClient", BlockingFakeClient)
    monkeypatch.setattr(
        gui_backend.utils,
        "append_to_session_log",
        lambda *args, **kwargs: logs.append(args),
    )

    ctx = gui_backend._CancellationContext(job_id=999, request_id=42)
    with gui_backend._active_requests_lock:
        gui_backend._active_requests[ctx.job_id] = ctx

    outcome = {}

    def worker():
        gui_backend._tls.cancel_ctx = ctx
        try:
            gui_backend.cmd_cross_append({
                "prompt": "hang test",
                "mode": "generate",
                "model": "openrouter:openai/gpt-6-luna",
                "use_kb": False,
                "lean_prompt": False,
            })
        except RequestCancelledError as exc:
            outcome["cancelled"] = str(exc)
        finally:
            gui_backend._tls.cancel_ctx = None
            with gui_backend._active_requests_lock:
                gui_backend._active_requests.pop(ctx.job_id, None)

    t = threading.Thread(target=worker, daemon=True)
    t.start()
    assert started.wait(timeout=2.0)

    assert gui_backend._cancel_active_requests(42) is True
    t.join(timeout=3.0)
    assert not t.is_alive()
    assert "cancelled" in outcome
    assert len(calls) == 1, "Stage 2 must not be invoked after Stage 1 cancellation"
    assert logs == [], "Cancelled request must not write to session log"


def test_daemon_cancel_command_and_request_id_echo(daemon_subprocess):
    """Daemon serve() echoes request_id on normal commands and handles cancel immediately."""
    assert daemon_subprocess.wait_for_ready(timeout=90.0)

    daemon_subprocess.send_command({"command": "list_models", "request_id": 7})
    res = daemon_subprocess.read_response(timeout=5.0)
    assert res is not None
    assert res.get("request_id") == 7
    assert "models" in res

    daemon_subprocess.send_command({"command": "cancel", "request_id": 99})
    cancel_res = daemon_subprocess.read_response(timeout=5.0)
    assert cancel_res is not None
    assert cancel_res.get("type") == "command_cancelled"
    assert cancel_res.get("request_id") == 99

    # Daemon stays alive and processes subsequent commands cleanly
    daemon_subprocess.send_command({"command": "list_models", "request_id": 8})
    res2 = daemon_subprocess.read_response(timeout=5.0)
    assert res2 is not None
    assert res2.get("request_id") == 8
    assert "models" in res2
