import os
import re
from sclang_validator import SclangValidator

def test_sequential(code):
    print("\\n--- Testing Sequential Splitting ---")
    v = SclangValidator()
    if not v.start(): return
    
    # Simple heuristic to split top-level blocks
    # A top level block is usually preceded by an empty line and starts with (
    # We can split by empty lines, or more robustly, split by `^\\s*\\)\\s*$`
    # Actually, a regex that finds `( ... )` at the top level is tricky.
    # What if we just regex replace `^(\\s*\\))(\\s*\\n\\s*\\()` with `\\1;\\2`?
    
    # If adding semicolons between `)` and `(` works when compiling the whole file:
    # Let's test that first!
    
    modified_code = re.sub(r'(?m)^(\s*\))(\s*\n\s*//.*\n|\s*\n)*(\s*\()', r'\1;\2\3', code)
    
    print("Modified Code (Adding Semicolons between blocks):")
    print(modified_code)

    tmp_path = f"C:/Users/BRUNOG~1/AppData/Local/Temp/tmpsplit.scd"
    with open(tmp_path, 'w', encoding='utf-8') as f:
        f.write(modified_code)
    
    sc_path = tmp_path.replace('\\\\', '/')
    wrapped = 'try {{ "{0}".load; "***SCLANG_VALID***".postln; }} {{ |err| ("***SCLANG_ERROR***: " ++ err.errorString).postln; }}'.format(sc_path)
    
    v._send_code(wrapped + "\n")
    import time
    time.sleep(1)
    
    for l in v._flush_buffer():
        print(repr(l))
    
    v.stop()
    if os.path.exists(tmp_path):
        os.remove(tmp_path)


code = """// ============ BLOCK 1: INIT ============
(
// --- BLOCK 1: INIT ---
Ndef(\\metalKick).clear;
Ndef(\\metalKick, {
	|freq=80, amp=0.7, t_trig=1, decay=0.4, numPartials=8, rq=0.05, pan=0|
	var env, freqs, amps, decays, sig;

	env = EnvGen.ar(Env.perc(0.001, decay * 0.8), t_trig); // Percussive envelope
	sig = BPF.ar(sig, freq * 2, rq);

	Pan2.ar(sig * amp, pan); // Stereo imaging
}).play;
)

// --- percDrum EFFECTS ---

(
// reverb (Index 10) - Adds metallic space
Ndef(\\metalKick)[10] = \\filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.2) };
Ndef(\\metalKick).set(\\wet10, 0);
)

(
Pbindef(\\metalKickSeq,
	\\dur, Pseq([0.25, 0.25, 0.5, 0.25], inf), // Rhythmic pattern
	\\t_trig, 1 // Essential trigger for the envelope
);
Ndef(\\metalKick).quant = 1; // Quantize Ndef updates to the beat
)"""

test_sequential(code)
