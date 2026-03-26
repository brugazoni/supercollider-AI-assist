from agent_graph_incremental import extract_new_block_node
from sclang_validator import SclangValidator
import os

code = """// ============ BLOCK 1: INIT ============
(
// --- BLOCK 1: INIT ---
Ndef(\\metalKick).clear;
Ndef(\\metalKick, {
	|freq=80, amp=0.7, t_trig=1, decay=0.4, numPartials=8, rq=0.05, pan=0|
	var env, freqs, amps, decays, sig;

	env = EnvGen.ar(Env.perc(0.001, decay * 0.8), t_trig); // Percussive envelope

	sig = DynKlank.ar(`[freqs, amps, decays], env, 0, 1, 0, 0); // Trigger DynKlank with the envelope

	// Apply a resonant filter to shape the body of the sound
	sig = BPF.ar(sig, freq * 2, rq);

	Pan2.ar(sig * amp, pan); // Stereo imaging
}).play;
)

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
Ndef(\\metalKick)[1] = \\set -> Pbindef(\\metalKickSeq); // Route sequence to Ndef parameters
)"""

state = {"current_code_block": code}
new_state = extract_new_block_node(state)
processed_code = new_state["current_code_block"]
print("\\n--- PROCESSED CODE ---")
print(processed_code)

print("\\n--- VALIDATING ---")
v = SclangValidator()
if v.start():
    valid, err = v.validate(processed_code)
    print(f"Valid: {valid}\\nError: {err}")
    v.stop()
