import subprocess
import time
import json
import sys
import os

def test_daemon():
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    
    print("Starting daemon...")
    p = subprocess.Popen(
        [sys.executable, "gui_backend.py", "serve"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env
    )
    
    print("Waiting for daemon ready...")
    while True:
        line = p.stdout.readline()
        if not line:
            print("Daemon EOF unexpectedly!")
            break
        print(f"DAEMON: {line.strip()}")
        if "ready" in line:
            break
            
    print("Sending start_dictation...")
    p.stdin.write(json.dumps({"command": "start_dictation", "model": "tiny"}) + "\n")
    p.stdin.flush()
    
    print("Waiting for dictation started...")
    while True:
        line = p.stdout.readline()
        if not line:
            print("Daemon EOF during dictation!")
            break
        print(f"DAEMON: {line.strip()}")
        
    p.wait()
    print(f"Daemon exited with {p.returncode}")

if __name__ == '__main__':
    test_daemon()
