import sys
import subprocess
import threading

def forward(src, dst):
    while True:
        data = src.read(4096)
        if not data:
            break
        try:
            dst.write(data)
            dst.flush()
        except:
            break

def main():
    # Launcher script to isolate gui_backend.py from QProcess pipe inheritance bugs
    cmd = [sys.executable, "test_mp_stdin.py"]
    
    p = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=sys.stdout,
        stderr=sys.stderr,
        bufsize=0
    )
    
    # Forward stdin from QProcess to gui_backend
    def stdin_forwarder():
        while True:
            try:
                line = sys.stdin.buffer.readline()
                if not line:
                    break
                p.stdin.write(line)
                p.stdin.flush()
            except Exception:
                break
        p.stdin.close()
        
    t = threading.Thread(target=stdin_forwarder, daemon=True)
    t.start()
    
    p.wait()
    sys.exit(p.returncode)

if __name__ == '__main__':
    main()
