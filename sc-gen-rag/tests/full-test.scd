

// ============ BLOCK 1: INIT ============
// --- BLOCK 1: INIT ---
(
Ndef(\ballRoll).clear;
Ndef(\ballRoll, {
	|freq=300, rq=0.1, amp=0.8, atk=0.01, rel=0.5, pan=0, t_trig=1,
	rollFreqEnd=150, rollRqEnd=0.02, hpfFreq=200|
	var env, freqEnv, rqEnv, sig;

	// Main amplitude envelope for the percussive hit and decay
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);

	// Frequency envelope for the rolling sound, decaying from start to end frequency
	freqEnv = EnvGen.ar(Env([freq, rollFreqEnd], [rel]), t_trig);

	// Resonance quality (Q) envelope, making the resonance wider/duller over time
	rqEnv = EnvGen.ar(Env([rq, rollRqEnd], [rel]), t_trig);

	// Source: White noise for a granular, rattling texture
	sig = WhiteNoise.ar();

	// Bandpass filter to create the resonant body sound
	sig = BPF.ar(sig, freqEnv, rqEnv);

	// Highpass filter to remove muddy low-end and add crispness to the 'roll'
	sig = HPF.ar(sig, hpfFreq);

	Pan2.ar(sig * env * amp, pan);
}).play;
);

// --- ballRoll EFFECTS ---
(
// reverb (Index 10)
Ndef(\ballRoll)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8, 0.5) };
Ndef(\ballRoll).set(\wet10, 0);

// delay (Index 11)
Ndef(\ballRoll)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 2) };
Ndef(\ballRoll).set(\wet11, 0);

// distortion/filter (Index 12) - subtle crunch
Ndef(\ballRoll)[12] = \filter -> { |in| (in * 2).tanh };
Ndef(\ballRoll).set(\wet12, 0);
);

// --- ballRoll SEQUENCES ---
(
Pbindef(\ballRollSeq,
	\dur, Pn(Pseq([1.25, 0.5, 0.25, 1], 1), inf), // Uneven rhythm for a natural roll
	\freq, Pn(Pseq([3000, 3200, 2800, 2500], 1), inf), // Varied resonance pitches
	\rq, Pn(Pseq([0.1, 0.08, 0.12, 0.09], 1), inf), // Slight variations in resonance quality
	\amp, Pwhite(2.6, 2.9), // Subtle amplitude variations for realism
	\pan, Pseq([-0.5, 0.5, 0, 0], inf), // Movement left to right
	\rollFreqEnd, Pwhite(100, 180), // End frequency for the roll decay
	\t_trig, 1
);
Ndef(\ballRoll).quant = 1;
Ndef(\ballRoll)[1] = \set -> Pbindef(\ballRollSeq);
)

Ndef(\ballRoll).set(\wet12, 30); //with reverb becomes cool snares
Ndef(\ballRoll).set(\wet10, 0.5);
Ndef(\ballRoll).set(\wet11, 1);

Pbindef(\ballRollSeq).set(\freq, Pn(Pseq([3000, 10000], 1), inf));
Pbindef(\ballRollSeq).set(\dur, Pn(Pseq([0.1, 0.2, 0.3], 1), inf));