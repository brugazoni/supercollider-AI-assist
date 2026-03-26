import subprocess
import time
import os

p = subprocess.Popen(["sclang"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def read_until(target, timeout=5.0):
    start = time.time()
    collected = []
    while time.time() - start < timeout:
        line = p.stdout.readline()
        if not line: break
        l = line.decode('utf-8', errors='replace').rstrip()
        collected.append(l)
        if target in l:
            break
    return '\n'.join(collected)

out = read_until("Welcome to SuperCollider")

sc_path = os.path.abspath("tests/full-test.scd").replace('\\', '/')
cmd = f'"{sc_path}".load;\n\x0c'
p.stdin.write(cmd.encode('utf-8'))
p.stdin.flush()

out2 = read_until("***DONE***", timeout=6.0)
print("OUT2:\n", out2)

cmd2 = '"***DONE***".postln;\n\x0c'
p.stdin.write(cmd2.encode('utf-8'))
p.stdin.flush()

out3 = read_until("***DONE***", timeout=3.0)
print("OUT3:\n", out3)

p.stdin.write(b"0.exit;\n\x0c")
p.stdin.flush()
p.wait(timeout=2)
