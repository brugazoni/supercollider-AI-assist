import subprocess
import sys
import os
import threading
import json
import time

def main():
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    p = subprocess.Popen(
        [sys.executable, "gui_backend.py", "serve"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        text=False
    )
    print("Launched gui_backend.py", flush=True)
    
    ready_event = threading.Event()

    def read_stdout():
        try:
            while True:
                line = p.stdout.readline()
                if not line: break
                print(f"[STDOUT] {line!r}", flush=True)
                if b'"status": "ready"' in line:
                    ready_event.set()
        except Exception as e:
            print(f"[STDOUT ERROR] {e}", flush=True)

    def read_stderr():
        try:
            while True:
                line = p.stderr.readline()
                if not line: break
                print(f"[STDERR] {line!r}", flush=True)
        except Exception as e:
            print(f"[STDERR ERROR] {e}", flush=True)

    t1 = threading.Thread(target=read_stdout, daemon=True)
    t2 = threading.Thread(target=read_stderr, daemon=True)
    t1.start()
    t2.start()

    try:
        if not ready_event.wait(timeout=60):
            print("Timeout waiting for ready!", flush=True)
            p.kill()
            return
            
        print("Sending start_dictation...", flush=True)
        p.stdin.write(b'{"command": "start_dictation", "model": "tiny", "language": "en"}\n')
        p.stdin.flush()
        
        time.sleep(20) # wait for model load
        
        print("Sending stop_dictation...", flush=True)
        p.stdin.write(b'{"command": "stop_dictation"}\n')
        p.stdin.flush()
        
        time.sleep(5)
        
        p.stdin.close()
        p.wait(timeout=30)
        print(f"Process exited with code {p.returncode}", flush=True)
    except subprocess.TimeoutExpired:
        print("Timeout! Process is still running.", flush=True)

if __name__ == "__main__":
    main()
