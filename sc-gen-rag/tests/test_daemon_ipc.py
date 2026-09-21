import pytest
import json
import time

def test_daemon_starts_and_signals_ready(daemon_subprocess):
    assert daemon_subprocess.wait_for_ready(timeout=30.0)

def test_daemon_echoes_unknown_command_error(daemon_subprocess):
    daemon_subprocess.wait_for_ready()
    daemon_subprocess.send_command({"command": "nonexistent"})
    response = daemon_subprocess.read_response()
    assert response is not None
    assert "error" in response
    assert "Unknown command" in response["error"]

def test_daemon_handles_malformed_json(daemon_subprocess):
    daemon_subprocess.wait_for_ready()
    daemon_subprocess.process.stdin.write("not json at all\n")
    daemon_subprocess.process.stdin.flush()
    response = daemon_subprocess.read_response()
    assert response is not None
    assert "error" in response
    assert "Invalid JSON" in response["error"]

def test_daemon_handles_empty_lines(daemon_subprocess):
    daemon_subprocess.wait_for_ready()
    daemon_subprocess.process.stdin.write("\n\n\n")
    daemon_subprocess.send_command({"command": "list_models"})
    response = daemon_subprocess.read_response()
    assert response is not None
    assert "models" in response
    
def test_daemon_sequential_commands(daemon_subprocess):
    daemon_subprocess.wait_for_ready()
    
    daemon_subprocess.send_command({"command": "list_models"})
    response1 = daemon_subprocess.read_response()
    assert response1 is not None
    assert "models" in response1
    
    daemon_subprocess.send_command({"command": "get_session_stats"})
    response2 = daemon_subprocess.read_response()
    assert response2 is not None
    assert "session_stats" in response2

def test_daemon_stdin_eof_graceful_exit(daemon_subprocess):
    daemon_subprocess.wait_for_ready()
    daemon_subprocess.close_stdin()
    
    try:
        daemon_subprocess.process.wait(timeout=5.0)
    except subprocess.TimeoutExpired:
        pytest.fail("Daemon did not exit after EOF")
        
    assert daemon_subprocess.process.returncode == 0
