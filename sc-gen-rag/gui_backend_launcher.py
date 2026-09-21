import sys
import subprocess
import threading
import os

def main():
    # If this script is run as a worker by multiprocessing, delegate directly to impl.
    # multiprocessing on Windows sets __name__ = "__mp_main__" and uses -c.
    # However, this script should not even be imported by multiprocessing if freeze_support is not called,
    # because the impl script will be the one spawning workers.

    # We only act as a launcher if "serve" is requested.
    if len(sys.argv) < 2 or sys.argv[1].lower() != "serve":
        # Just run the impl directly for other commands
        cmd = [sys.executable, "gui_backend_impl.py"] + sys.argv[1:]
        p = subprocess.Popen(cmd)
        p.wait()
        sys.exit(p.returncode)

    # Launcher mode: isolate the QProcess stdin pipe from multiprocessing inheritance bugs.
    cmd = [sys.executable, "gui_backend_impl.py", "serve"]
    
    # We must set PYTHONUNBUFFERED to ensure stdout/stderr flow immediately
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    
    p = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env
    )
    
    def forward_stdin():
        try:
            while True:
                # Read raw bytes from stdin buffer
                data = sys.stdin.buffer.read1(4096)
                if not data:
                    break
                p.stdin.write(data)
                p.stdin.flush()
        except Exception:
            pass
        finally:
            try:
                p.stdin.close()
            except:
                pass
                
    def forward_stdout():
        try:
            while True:
                data = p.stdout.read1(4096)
                if not data:
                    break
                sys.stdout.buffer.write(data)
                sys.stdout.buffer.flush()
        except Exception:
            pass

    def forward_stderr():
        try:
            while True:
                data = p.stderr.read1(4096)
                if not data:
                    break
                sys.stderr.buffer.write(data)
                sys.stderr.buffer.flush()
        except Exception:
            pass

    t_in = threading.Thread(target=forward_stdin, daemon=True)
    t_out = threading.Thread(target=forward_stdout, daemon=True)
    t_err = threading.Thread(target=forward_stderr, daemon=True)
    
    t_in.start()
    t_out.start()
    t_err.start()
    
    p.wait()
    sys.exit(p.returncode)

if __name__ == '__main__':
    main()
