import subprocess
import time

def test():
    # start sclang
    p = subprocess.Popen(
        ['sclang'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=0,
    )
    time.sleep(2)
    import threading
    def read_out():
        while True:
            line = p.stdout.readline()
            if not line: break
            print("SC:", line.decode('utf-8').strip())
            
    threading.Thread(target=read_out, daemon=True).start()
    
    code = """(
Ndef(\\test, { SinOsc.ar(440) * 0.1 }).play
)
"""
    with open("temp_test.scd", "w", encoding='utf-8') as f:
        f.write(code)
    
    # We load the file
    print("Loading file...")
    cmd = 'try { "temp_test.scd".load; "__SCLANG_VALID__".postln; } { |err| ("__SCLANG_ERROR__: " ++ err.errorString).postln };\n'
    p.stdin.write(cmd.encode('utf-8') + b'\x0c')
    p.stdin.flush()
    time.sleep(2)
    
    # Test syntax error
    code2 = """(
Ndef(\\test, { SinOsc.ar(440) * 0.1 ).play
)
"""
    with open("temp_test2.scd", "w", encoding='utf-8') as f:
        f.write(code2)
        
    print("Loading file 2 (syntax error)...")
    cmd2 = 'try { "temp_test2.scd".load; "__SCLANG_VALID__".postln; } { |err| ("__SCLANG_ERROR__: " ++ err.errorString).postln };\n'
    p.stdin.write(cmd2.encode('utf-8') + b'\x0c')
    p.stdin.flush()
    time.sleep(2)
    
    p.terminate()

test()
