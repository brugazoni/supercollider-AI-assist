import pytest
import json
import threading
from io import StringIO
import sys

from gui_backend import _daemon_write_json

@pytest.fixture(autouse=True)
def setup_teardown_stdout():
    import gui_backend
    original = gui_backend._daemon_stdout
    yield
    gui_backend._daemon_stdout = original


def test_write_json_basic(capture_daemon_stdout):
    _daemon_write_json({"type": "test", "value": 42})
    out = capture_daemon_stdout.getvalue()
    assert out.endswith("\n")
    parsed = json.loads(out)
    assert parsed["type"] == "test"
    assert parsed["value"] == 42


def test_write_json_with_unicode(capture_daemon_stdout):
    _daemon_write_json({"text": "café résumé 🎶"})
    out = capture_daemon_stdout.getvalue()
    # ensure_ascii=False should keep literal characters
    assert "café résumé 🎶" in out
    

def test_write_json_when_stdout_is_none():
    import gui_backend
    gui_backend._daemon_stdout = None
    # Should not raise exception
    _daemon_write_json({"type": "test"})


def test_write_json_thread_safety(capture_daemon_stdout):
    def worker(thread_id):
        for i in range(100):
            _daemon_write_json({"thread": thread_id, "msg": i})

    threads = [threading.Thread(target=worker, args=(i,)) for i in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()

    out = capture_daemon_stdout.getvalue()
    lines = out.strip().split("\n")
    assert len(lines) == 1000
    
    # Each line should be valid JSON
    for line in lines:
        try:
            parsed = json.loads(line)
            assert "thread" in parsed
            assert "msg" in parsed
        except json.JSONDecodeError:
            pytest.fail(f"Interleaved or invalid JSON produced: {line}")


def test_write_json_broken_pipe():
    class BrokenPipeMock:
        def write(self, data):
            raise BrokenPipeError("Pipe closed")
        def flush(self):
            pass

    import gui_backend
    gui_backend._daemon_stdout = BrokenPipeMock()
    
    # Currently this raises, which is fine to document in tests, but it will fail the test
    # if we don't catch it. If the intent is that it SHOULD crash the app on broken IPC,
    # then we test that it raises.
    with pytest.raises(BrokenPipeError):
        _daemon_write_json({"test": "broken"})
