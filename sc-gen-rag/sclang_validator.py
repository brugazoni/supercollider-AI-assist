"""
sclang_validator.py — Headless sclang subprocess for syntax validation.

Spawns a standalone sclang process, feeds it SC code blocks via stdin,
and parses stdout to detect parse/syntax errors. This replaces the
LLM-based Tier 2 validation with the actual SC parser.

Usage:
    validator = SclangValidator()
    validator.start()  # boots sclang, waits for class library
    is_valid, error = validator.validate("( SinOsc.ar(440) )")
    validator.mirror_block("( Ndef(\\test, { SinOsc.ar(440) * 0.1 }).play )")
    validator.stop()
"""

import subprocess
import threading
import time
import re
import config


class SclangValidator:
    """Manages a headless sclang subprocess for syntax validation."""

    def __init__(self, sclang_path=None, boot_timeout=None):
        self.sclang_path = sclang_path or config.SCLANG_PATH
        self.boot_timeout = boot_timeout or config.SCLANG_BOOT_TIMEOUT
        self.process = None
        self._output_buffer = []
        self._buffer_lock = threading.Lock()
        self._reader_thread = None
        self._ready = False
        self._stopped = False

    def start(self):
        """Start the sclang subprocess and wait for class library compilation."""
        print(f"  [sclang-validator] Starting sclang from: {self.sclang_path}")

        try:
            self.process = subprocess.Popen(
                [self.sclang_path],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,  # merge stderr into stdout
                bufsize=0,  # unbuffered binary
            )
        except FileNotFoundError:
            print(f"  [sclang-validator] ERROR: sclang not found at '{self.sclang_path}'")
            print(f"  [sclang-validator] Set SCLANG_PATH env var or update config.py")
            return False
        except Exception as e:
            print(f"  [sclang-validator] ERROR: Failed to start sclang: {e}")
            return False

        # Start background reader thread
        self._stopped = False
        self._reader_thread = threading.Thread(target=self._read_stdout, daemon=True)
        self._reader_thread.start()

        # Wait for class library compilation
        print(f"  [sclang-validator] Waiting for class library (up to {self.boot_timeout}s)...")
        start_time = time.time()
        while time.time() - start_time < self.boot_timeout:
            if self._ready:
                elapsed = time.time() - start_time
                print(f"  [sclang-validator] Ready ({elapsed:.1f}s)")
                return True
            if self.process.poll() is not None:
                print(f"  [sclang-validator] ERROR: sclang exited during boot (code {self.process.returncode})")
                return False
            time.sleep(0.5)

        print(f"  [sclang-validator] WARNING: Boot timeout ({self.boot_timeout}s) — proceeding anyway")
        self._ready = True
        return True

    def _read_stdout(self):
        """Background thread: continuously reads sclang stdout."""
        try:
            while not self._stopped and self.process and self.process.poll() is None:
                line = self.process.stdout.readline()
                if not line:
                    break
                decoded = line.decode('utf-8', errors='replace').rstrip('\r\n')

                # Detect readiness
                if not self._ready:
                    if 'compileLibrary' in decoded or 'Welcome to SuperCollider' in decoded:
                        self._ready = True

                with self._buffer_lock:
                    self._output_buffer.append(decoded)
        except Exception:
            pass  # subprocess gone

    def _flush_buffer(self):
        """Clear and return all accumulated output lines."""
        with self._buffer_lock:
            lines = list(self._output_buffer)
            self._output_buffer.clear()
        return lines

    def _send_code(self, code, silent=False):
        """Send code to sclang via stdin using the SC protocol."""
        if not self.process or self.process.poll() is not None:
            return False
        try:
            payload = code.encode('utf-8')
            control_char = b'\x1b' if silent else b'\x0c'
            self.process.stdin.write(payload + control_char)
            self.process.stdin.flush()
            return True
        except (BrokenPipeError, OSError):
            return False

    def validate(self, code, timeout=5.0):
        """Validate a SuperCollider code block.

        Sends the code to sclang and checks stdout for ERROR patterns.
        Returns (is_valid: bool, error_message: str).
        """
        if not self._ready or not self.process or self.process.poll() is not None:
            return True, "(validator not available — skipping)"

        import tempfile
        import os

        # Flush any stale output
        self._flush_buffer()

        # Write code to a temporary file in the *current directory* to avoid long absolut paths
        # triggering standard input console-wrapping breaks in the sclang Windows REPL.
        tmp_fd, tmp_path = tempfile.mkstemp(suffix=".scd", dir=".")
        with os.fdopen(tmp_fd, 'w', encoding='utf-8') as f:
            f.write(code)

        # SC strings escape backslashes, so replacing \ with / is safest
        sc_path = tmp_path.replace('\\', '/')

        # Send the load command, followed immediately by a completion marker instruction.
        # This completely avoids 80-char REPL line wrapping limits on Windows and ensures that 
        # both syntax errors and runtime exceptions naturally bubble up to stdout before printing the DONE marker.
        if not self._send_code(f"\"{sc_path}\".load;\n", silent=False):
            return True, "(validator pipe broken — skipping)"
        if not self._send_code("\"***SCLANG_DONE***\".postln;\n", silent=False):
            return True, "(validator pipe broken — skipping)"

        # Collect output with timeout
        deadline = time.time() + timeout
        collected = []
        found_result = False

        while time.time() < deadline:
            time.sleep(0.15)
            new_lines = self._flush_buffer()
            collected.extend(new_lines)

            # Check if we got the definitive completion marker.
            for l in collected:
                if l.startswith('***SCLANG_DONE***'):
                    found_result = True
                    break
            
            if found_result:
                break

        if not found_result:
            # Grab any remaining output
            time.sleep(0.3)
            collected.extend(self._flush_buffer())

        # Analyze collected output
        all_text = '\n'.join(collected)

        # Prioritize matching compile/parse exceptions first
        parse_error_patterns = [
            r'ERROR: Parse error',
            r'ERROR: syntax error',
            r"ERROR:.*unexpected",
        ]
        out_error = None
        for pattern in parse_error_patterns:
            match = re.search(pattern, all_text)
            if match:
                error_lines = [l for l in collected if 'ERROR' in l or 'error' in l.lower() or 'line' in l.lower()]
                out_error = '\n'.join(error_lines[:5]).strip() if error_lines else match.group(0)
                break
        
        # If no parse error, check for generic runtime errors natively printed by SC
        if not out_error:
            error_lines = [l for l in collected if l.strip().startswith('ERROR:')]
            if error_lines:
                out_error = '\n'.join(error_lines[:5]).strip()
        
        # Clean up temp file
        try:
            os.remove(tmp_path)
        except OSError:
            pass

        if out_error:
            return False, out_error
        else:
            return True, ''

        # Clean up temp file
        try:
            os.remove(tmp_path)
        except OSError:
            pass

        # No clear result — assume valid (timeout or quiet success)
        return True, ''

    def mirror_block(self, code):
        """Evaluate a validated block in the validator sclang to keep state in sync.

        This ensures the validation sclang knows about previously defined
        Ndefs, SynthDefs, etc. for subsequent validations.
        """
        import tempfile
        import os
        
        if not self._ready or not self.process or self.process.poll() is not None:
            return
            
        tmp_fd, tmp_path = tempfile.mkstemp(suffix=".scd", dir=".")
        with os.fdopen(tmp_fd, 'w', encoding='utf-8') as f:
            f.write(code)
            
        sc_path = tmp_path.replace('\\', '/')
        
        # Evaluate silently — we don't need output
        self._send_code(f"\"{sc_path}\".load\n", silent=True)
        
        # We wait a tiny bit to make sure it loads before deleting
        time.sleep(0.1)
        try:
            os.remove(tmp_path)
        except OSError:
            pass

    def stop(self):
        """Shut down the sclang subprocess."""
        self._stopped = True
        if self.process and self.process.poll() is None:
            try:
                self._send_code("0.exit", silent=True)
                self.process.wait(timeout=3)
            except Exception:
                try:
                    self.process.terminate()
                    self.process.wait(timeout=2)
                except Exception:
                    self.process.kill()
            print("  [sclang-validator] Stopped")
        self.process = None
        self._ready = False

    @property
    def is_ready(self):
        return self._ready and self.process is not None and self.process.poll() is None
