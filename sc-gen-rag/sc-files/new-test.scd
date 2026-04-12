

// --- OSCILLATOR TEST PATCH INSTRUMENTS ---
(
// Ndef(\osc1): Saw wave, foundational tone with an envelope
Ndef(\osc1).clear;
Ndef(\osc1, {
	|freq=220, amp=0.3, pan=0, atk=0.01, rel=0.2, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Saw.ar(freq);
	Pan2.ar(sig * env * amp, pan);
}).play;

// Ndef(\osc2): Pulse wave, contrasting timbre with an envelope
Ndef(\osc2).clear;
Ndef(\osc2, {
	|freq=110, amp=0.001, pan=0.4, width=0.3, atk=0.05, rel=0.5, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Pulse.ar(freq, width);
	Pan2.ar(sig * env * amp, pan);
}).play;
)

// --- OSCILLATOR TEST PATCH EFFECTS ---
(
// Reverb for Ndef(\osc1) on slot [10]
Ndef(\osc1)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) };
Ndef(\osc1).set(\wet10, 0); // Initialize reverb wetness to 0
)

// --- OSCILLATOR TEST PATCH SEQUENCES ---
(
// Sequence for Ndef(\osc1): Simple C major arpeggio
Pbindef(\osc1Seq,
	\instrument, \osc1,
	\degree, Pseq([0, 2, 4, 7], inf), // C major arpeggio
	\scale, Scale.major,
	\dur, 1,
	\amp, 1, // Full amplitude for pattern, controlled by Ndef's top-level amp
	\t_trig, 1
);
Ndef(\osc1).quant = 1; // Quantize sequence changes to the beat
Ndef(\osc1)[1] = \set -> Pbindef(\osc1Seq);

// Sequence for Ndef(\osc2): Sparse, low C minor notes for a drone-like quality
Pbindef(\osc2Seq,
	\instrument, \osc2,
	\degree, Pseq([-12, -5, -17], inf), // C minor notes an octave or two down
	\scale, Scale.minor,
	\dur, 4, // Long durations for a sustained, drone-like character
	\amp, 1, // Full amplitude for pattern, controlled by Ndef's top-level amp
	\t_trig, 1
);
Ndef(\osc2).quant = 1; // Quantize sequence changes to the beat
Ndef(\osc2)[1] = \set -> Pbindef(\osc2Seq);
)

// --- OSCILLATOR TEST PATCH LIVE CODING TWEAKS ---

// Set fade times for smooth crossfades on Ndefs
Ndef(\osc1).fadeTime = 2;
Ndef(\osc2).fadeTime = 2;

// --- Section 1: Introduction - "Humble Foundations" ---
// Ndef(\osc1) is playing with its initial parameters.
// Ndef(\osc2) is silent (amp=0.001 effectively silent).
// Reverb on Ndef(\osc1) is off (wet10=0).
// Let this section play for ~10-15 seconds before proceeding.

// --- Section 2: Development - "Harmonic Bloom" ---
// Gently introduce Ndef(\osc2) and fade in reverb on Ndef(\osc1).
(
// Fade in Ndef(\osc2) amplitude over its fadeTime (2 seconds)
Ndef(\osc2).xset(\amp, 0.2); // Introduce the contrasting pulse wave
// Ndef(\osc2).xset(\amp, 0.001); // Revert Ndef(\osc2) to initial silent state

// Fade in reverb on Ndef(\osc1) over its fadeTime (2 seconds)
Ndef(\osc1).xset(\wet10, 0.4); // Add subtle depth to the foundational saw wave
// Ndef(\osc1).xset(\wet10, 0); // Revert Ndef(\osc1) reverb mix to 0
)
// Let this section play for ~20-30 seconds to allow the layered sound to develop.

// --- Section 3: Outro - "Gentle Dissipation" ---
// Begin a slow, simultaneous fade-out for all elements.
(
// Set a longer fadeTime for the outro
Ndef(\osc1).fadeTime = 10;
Ndef(\osc2).fadeTime = 10;

// Fade out Ndef(\osc1) amplitude and reverb over 10 seconds
Ndef(\osc1).xset(\amp, 0.0, \wet10, 0.0); // Ndef(\osc1) fades out and its reverb disappears
// Ndef(\osc1).xset(\amp, 0.3, \wet10, 0.4); // Revert Ndef(\osc1) to previous state

// Fade out Ndef(\osc2) amplitude over 10 seconds
Ndef(\osc2).xset(\amp, 0.0); // Ndef(\osc2) fades out
// Ndef(\osc2).xset(\amp, 0.2); // Revert Ndef(\osc2) to previous state
)

// [OSCILLATOR TEST PATCH] fade out and ending
(
// Wait for the fades to complete, then stop patterns and clear Ndefs
fork {
	10.wait; // Wait for the 10-second fadeTime applied above
	Pbindef(\osc1Seq).stop; // Stop Ndef(\osc1)'s pattern
	Pbindef(\osc2Seq).stop; // Stop Ndef(\osc2)'s pattern
	Ndef(\osc1).clear(2); // Clear Ndef(\osc1) after a short additional fade
	Ndef(\osc2).clear(2); // Clear Ndef(\osc2) after a short additional fade
	"Composition: Oscillator Test Patch ended cleanly.".postln;
};
)