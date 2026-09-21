import sys
import os
import time
import threading
import multiprocessing as mp

def worker():
    print(f"Child worker {os.getpid()} starting...", file=sys.stderr, flush=True)
    time.sleep(5)
    print(f"Child worker {os.getpid()} exiting.", file=sys.stderr, flush=True)

def _run_dictation():
    print(f"BG thread starting child process...", file=sys.stderr, flush=True)
    
    # Save original fd 0
    fd0 = os.dup(0)
    devnull = open(os.devnull, 'r')
    os.dup2(devnull.fileno(), 0)
    
    p = mp.Process(target=worker)
    p.start()
    
    # Restore original fd 0
    os.dup2(fd0, 0)
    os.close(fd0)
    devnull.close()
    
    p.join()
    print(f"BG thread child process finished.", file=sys.stderr, flush=True)

def serve():
    print(f"Parent {os.getpid()} starting dictation thread...", file=sys.stderr, flush=True)
    t = threading.Thread(target=_run_dictation, daemon=True)
    t.start()
    
    print(f"Parent {os.getpid()} entering sys.stdin loop...", file=sys.stderr, flush=True)
    try:
        for line in sys.stdin:
            line = line.strip()
            print(f"Parent read: {line}", file=sys.stderr, flush=True)
            if not line:
                continue
    except Exception as e:
        print(f"Parent {os.getpid()} stdin error: {e}", file=sys.stderr, flush=True)
        return
    
    print(f"Parent {os.getpid()} hit EOF on stdin. Exiting...", file=sys.stderr, flush=True)

if __name__ == '__main__':
    mp.freeze_support()
    serve()
