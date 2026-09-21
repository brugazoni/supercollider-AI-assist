import os
import sys
import json
import time
import subprocess
import threading
from io import StringIO
from typing import Dict, Any, Optional

import pytest

# Adjust sys.path so we can import gui_backend
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import gui_backend

class MockRecorder:
    def __init__(self, *args, **kwargs):
        self.is_running = True
        self.stop_called = False
        self.shutdown_called = False
        
        # Capture VAD lifecycle callbacks (used by _run_dictation mute guard)
        self._on_rec_start = kwargs.get("on_recording_start")
        self._on_rec_stop = kwargs.get("on_recording_stop")
        
        # Simulate model load delay if requested by tests
        load_delay = kwargs.get("mock_load_delay", 0.0)
        if load_delay > 0:
            time.sleep(load_delay)
            
        # Optional mock exception on init
        if kwargs.get("mock_init_error"):
            raise Exception("Mock init error")
            
        self.text_queue = []

    def stop(self):
        self.is_running = False
        self.stop_called = True

    def shutdown(self):
        self.shutdown_called = True

    def text(self, on_final):
        # Simulate blocking until text is available
        while self.is_running and not self.text_queue:
            time.sleep(0.01)
            
        if not self.is_running:
            return ""
            
        text = self.text_queue.pop(0)
        # Simulate VAD lifecycle: speech detected → transcribe → final
        if self._on_rec_start:
            self._on_rec_start()
        if on_final:
            on_final(text)
        if self._on_rec_stop:
            self._on_rec_stop()
        return text
        
    def inject_text(self, text):
        self.text_queue.append(text)


@pytest.fixture
def mock_recorder_class(monkeypatch):
    """Mocks RealtimeSTT.AudioToTextRecorder to avoid hardware dependencies."""
    class RecorderFactory:
        def __init__(self):
            self.instances = []
            self.mock_kwargs = {}
            
        def __call__(self, *args, **kwargs):
            kwargs.update(self.mock_kwargs)
            instance = MockRecorder(*args, **kwargs)
            self.instances.append(instance)
            return instance

    factory = RecorderFactory()
    
    # We must mock the import in gui_backend's namespace since it lazy imports
    # However, it imports inside _run_dictation. 
    # To reliably mock it, we add it to sys.modules
    import sys
    import types
    
    # Create fake RealtimeSTT module
    fake_module = types.ModuleType("RealtimeSTT")
    fake_module.AudioToTextRecorder = factory
    sys.modules["RealtimeSTT"] = fake_module
    
    # _run_dictation also does `import torch.multiprocessing as tmp` before
    # importing RealtimeSTT. In pytest's threaded context, this import can
    # be very slow or deadlock if torch needs to initialize for the first time.
    # Pre-import torch here (main thread) so the background thread's import
    # is a no-op cache hit.
    try:
        import torch.multiprocessing  # noqa: F401
    except ImportError:
        pass  # torch not installed — dictation tests will be skipped
    
    yield factory
    
    # Cleanup
    if "RealtimeSTT" in sys.modules:
        del sys.modules["RealtimeSTT"]


def wait_for_recorder(timeout: float = 5.0):
    """Poll until gui_backend._dictation_recorder is set by the dictation thread.

    The recorder is assigned inside the _run_dictation background thread
    *after* torch.multiprocessing and RealtimeSTT are imported (which can
    take several hundred ms). Use this instead of a bare time.sleep().
    """
    import time
    import gui_backend
    deadline = time.time() + timeout
    while time.time() < deadline:
        if gui_backend._dictation_recorder is not None:
            return gui_backend._dictation_recorder
        time.sleep(0.05)
    return None


class DaemonTestClient:
    def __init__(self):
        env = os.environ.copy()
        script_path = os.path.join(os.path.dirname(__file__), '..', 'gui_backend.py')
        self.process = subprocess.Popen(
            [sys.executable, script_path, "serve"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1, # Line buffered
            env=env
        )
        self.stdout_lock = threading.Lock()

    def wait_for_ready(self, timeout=30.0):
        start = time.time()
        while time.time() - start < timeout:
            line = self.read_line_nonblocking(timeout=0.1)
            if line:
                try:
                    data = json.loads(line)
                    if data.get("status") == "ready":
                        return True
                except json.JSONDecodeError:
                    pass
        return False

    def send_command(self, cmd_dict: Dict[str, Any]):
        self.process.stdin.write(json.dumps(cmd_dict) + "\n")
        self.process.stdin.flush()

    def read_line_nonblocking(self, timeout=2.0) -> Optional[str]:
        if sys.platform == 'win32':
            if not hasattr(self, '_read_queue'):
                import queue
                self._read_queue = queue.Queue()
                def _reader():
                    for line in iter(self.process.stdout.readline, ''):
                        self._read_queue.put(line)
                t = threading.Thread(target=_reader, daemon=True)
                t.start()
            
            import queue
            try:
                return self._read_queue.get(timeout=timeout)
            except queue.Empty:
                return None
        else:
            import select
            r, _, _ = select.select([self.process.stdout], [], [], timeout)
            if r:
                return self.process.stdout.readline()
            return None

    def read_response(self, timeout=2.0) -> Optional[Dict]:
        line = self.read_line_nonblocking(timeout)
        if line:
            return json.loads(line)
        return None
        
    def close_stdin(self):
        self.process.stdin.close()

    def terminate(self):
        self.process.terminate()
        try:
            self.process.wait(timeout=2.0)
        except subprocess.TimeoutExpired:
            self.process.kill()


@pytest.fixture
def daemon_subprocess():
    client = DaemonTestClient()
    yield client
    client.terminate()


@pytest.fixture
def capture_daemon_stdout(monkeypatch):
    string_io = StringIO()
    monkeypatch.setattr(gui_backend, '_daemon_stdout', string_io)
    yield string_io
