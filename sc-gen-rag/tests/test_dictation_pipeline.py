import sys
import os
import json
import time
import subprocess
import pytest

# Ensure we can find the gui_backend module
SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GUI_BACKEND_PY = os.path.join(SCRIPT_DIR, "gui_backend.py")

@pytest.fixture
def daemon_process():
    """Fixture to launch the daemon via the self-launcher and manage its lifecycle."""
    env = os.environ.copy()
    # Use unbuffered output to ensure we don't hang waiting for chunks
    env["PYTHONUNBUFFERED"] = "1"
    
    # We run 'serve' just like the IDE does. The self-launcher should intercept
    # this and shield us from QProcess-style EOF bugs.
    p = subprocess.Popen(
        [sys.executable, GUI_BACKEND_PY, "serve"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        text=False  # use binary to avoid encoding mismatch hangs on windows
    )
    
    yield p
    
    # Cleanup
    if p.poll() is None:
        try:
            p.stdin.close()
        except:
            pass
        p.terminate()
        p.wait(timeout=5)


def read_next_json(p, timeout=40.0):
    """Read the next JSON line from the daemon's stdout."""
    start_time = time.time()
    print(f"\n[TEST] Waiting for JSON output (timeout={timeout}s)...")
    while time.time() - start_time < timeout:
        # We read raw bytes since RealtimeSTT can sometimes emit weird chars
        print(f"[TEST] Calling p.stdout.readline()...")
        line = p.stdout.readline()
        print(f"[TEST] Received bytes from readline: {line!r}")
        if not line:
            # EOF reached
            if p.poll() is not None:
                raise EOFError(f"Daemon exited with code {p.returncode}")
            time.sleep(0.1)
            continue
            
        decoded = line.decode('utf-8', errors='replace').strip()
        if not decoded:
            print(f"[TEST] Empty decoded string, continuing...")
            continue
            
        print(f"[TEST] Decoding JSON: {decoded!r}")
        try:
            return json.loads(decoded)
        except json.JSONDecodeError:
            print(f"[TEST] Skipping non-JSON output from stdout: {decoded}", file=sys.stderr)
            continue
            
    raise TimeoutError("Timed out waiting for JSON response from daemon.")


def write_json(p, obj):
    """Write a JSON command to the daemon's stdin."""
    line = json.dumps(obj) + "\n"
    print(f"[TEST] Writing JSON to daemon: {line!r}")
    p.stdin.write(line.encode('utf-8'))
    p.stdin.flush()


def test_daemon_survives_dictation_start(daemon_process):
    """
    Verify that sending start_dictation to the launcher does not trigger
    the Windows EOF pipe inheritance bug. The daemon should stay alive.
    """
    p = daemon_process
    
    # 1. Wait for daemon ready (loads RAG which can take ~35s on first run)
    msg = read_next_json(p, timeout=300.0)
    assert msg.get("status") == "ready"
    
    # 2. Send start_dictation
    write_json(p, {"command": "start_dictation", "model": "tiny", "language": "en"})
    
    # 3. Read response
    msg = read_next_json(p)
    assert msg.get("status") == "dictation_starting"
    
    # 4. Wait for the dictation thread to confirm it started
    # (This involves multiprocessing.Process spawning, which is where it usually crashes)
    msg = read_next_json(p, timeout=20.0)
    assert msg.get("type") == "dictation_started"
    
    # 5. Verify the daemon is STILL ALIVE and hasn't hit EOF
    assert p.poll() is None, "Daemon crashed after starting dictation!"
    
    # 6. Verify stdin is still functional by sending another command
    write_json(p, {"command": "list_models"})
    msg = read_next_json(p)
    assert "models" in msg
    
    # 7. Cleanly stop dictation
    write_json(p, {"command": "stop_dictation"})
    
    # We should get BOTH a synchronous 'dictation_stopped' response from the command...
    # AND an asynchronous 'dictation_stopped' event from the dictation thread exiting.
    # The order might vary slightly.
    stops_received = 0
    for _ in range(2):
        msg = read_next_json(p, timeout=10.0)
        if msg.get("status") == "dictation_stopped" or msg.get("type") == "dictation_stopped":
            stops_received += 1
            
    assert stops_received == 2, "Did not receive all stop confirmation events"
    assert p.poll() is None, "Daemon crashed after stopping dictation!"


def test_cleanup_on_stdin_eof(daemon_process):
    """
    Verify that if the IDE closes the write channel (stdin hits EOF),
    the daemon shuts down gracefully with code 0.
    """
    p = daemon_process
    
    # 1. Wait for ready
    msg = read_next_json(p, timeout=300.0)
    assert msg.get("status") == "ready"
    
    # 2. Close stdin
    p.stdin.close()
    
    # 3. Wait for process to exit
    exit_code = p.wait(timeout=10.0)
    assert exit_code == 0, f"Daemon exited with unexpected code {exit_code} on EOF"

