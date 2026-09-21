"""
Test whether RealtimeSTT's multiprocessing child process
kills the parent's stdin pipe on Windows.

Run via:
  echo '{"command":"test"}' | python test_stdin_mp.py
"""
import sys
import json
import threading
import time
import os

def bg_load():
    print("BG thread: Starting RealtimeSTT load...", file=sys.stderr, flush=True)
    try:
        devnull = open(os.devnull, 'w')
        old_stdout = sys.stdout
        sys.stdout = devnull
        
        from RealtimeSTT import AudioToTextRecorder
        print("BG thread: Imported AudioToTextRecorder", file=sys.stderr, flush=True)
        
        recorder = AudioToTextRecorder(
            model="tiny",
            language="en",
            compute_type="int8",
            beam_size=1,
        )
        print("BG thread: Recorder created successfully!", file=sys.stderr, flush=True)
        
        # Let it run for 10 seconds then shutdown
        time.sleep(10)
        recorder.stop()
        recorder.shutdown()
        print("BG thread: Recorder shut down.", file=sys.stderr, flush=True)
        devnull.close()
    except Exception as e:
        print(f"BG thread ERROR: {e}", file=sys.stderr, flush=True)
        import traceback
        traceback.print_exc(file=sys.stderr)

if __name__ == "__main__":
    original_stdout = sys.stdout
    sys.stdout = sys.stderr
    
    print(f"Main thread: PID = {os.getpid()}", flush=True)
    print(f"Main thread: sys.stdin fileno = {sys.stdin.fileno()}", flush=True)
    
    # Start background load
    t = threading.Thread(target=bg_load, daemon=True)
    t.start()
    
    # Simulate the serve() stdin loop
    print("Main thread: entering stdin loop...", flush=True)
    
    # Keep stdin open by reading in a loop
    while True:
        line = sys.stdin.readline()
        if not line:
            print("Main thread: GOT EOF ON STDIN!", flush=True)
            break
        line = line.strip()
        if not line:
            continue
        print(f"Main thread: GOT LINE: {line}", flush=True)
    
    print(f"Main thread: BG thread alive = {t.is_alive()}", flush=True)
    print("Main thread: EXITING", flush=True)
