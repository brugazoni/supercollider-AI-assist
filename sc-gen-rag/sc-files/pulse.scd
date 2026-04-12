

(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Composition Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;

	NdefMixer(s);

	// MASTER FX & LIMITER
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = LeakDC.ar(in);
		Limiter.ar(sig, 0.95, 0.01);
	});
});
)

// --- PULSE & SINE WEAVE INSTRUMENTS ---

// Ndef(\sinePad): Sustained sine waves for atmospheric pads
(
Ndef(\sinePad).clear;
Ndef(\sinePad, {
	|freq=180, amp=0.1, t_trig=1, atk=4, rel=8, sus=4, lfoFreq=0.1, lfoDepth=0.005, detune=0.002, pan=0|
	var env, lfo, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel]), t_trig, doneAction: 0);
	lfo = SinOsc.kr(lfoFreq) * lfoDepth * freq; // Subtle vibrato
	sig = SinOsc.ar(freq + lfo) + SinOsc.ar((freq * (1 + detune)) + lfo); // Two detuned sines
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\sinePad).fadeTime = 4; // Long fade time for pad
)

// Ndef(\pulseBase): Low-frequency pulse wave for rhythmic and textural foundation
(
Ndef(\pulseBase).clear;
Ndef(\pulseBase, {
	|freq=60, amp=0.15, t_trig=1, atk=0.5, rel=3, width=0.8, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = Pulse.ar([freq, freq * 1.005], width); // Slightly detuned for richness
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\pulseBase).fadeTime = 2; // Moderate fade time
)

// Ndef(\sineLead): Percussive or melodic sine waves for lead lines and arpeggios
(
Ndef(\sineLead).clear;
Ndef(\sineLead, {
	|freq=500, amp=0.2, t_trig=1, atk=0.01, rel=0.3, detune=0.003, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = SinOsc.ar(freq) + SinOsc.ar(freq * (1 + detune)); // Detuned for bell-like quality
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\sineLead).fadeTime = 1; // Shorter fade time for percussive element
)

// --- PULSE & SINE WEAVE EFFECTS ---

// Reverb (slot 10) - Global atmospheric glue
(
Ndef(\sinePad)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) }; // in.sum for mono input
Ndef(\sinePad).set(\wet10, 0);

Ndef(\pulseBase)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.3) };
Ndef(\pulseBase).set(\wet10, 0);

Ndef(\sineLead)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.2) };
Ndef(\sineLead).set(\wet10, 0);
)

// Delay (slot 11) - Primarily on \sineLead and \sinePad
(
Ndef(\sinePad)[11] = \filter -> { |in| CombL.ar(in, 0.4, 0.3, 3) }; // Long evolving delay
Ndef(\sinePad).set(\wet11, 0);

Ndef(\sineLead)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.15, 1.2) }; // Shorter, shimmering delay
Ndef(\sineLead).set(\wet11, 0);
)

// Distortion/Saturation (slot 12) - Subtle on \pulseBase
(
Ndef(\pulseBase)[12] = \filter -> { |in| (in * 2.0).fold2(0.8) }; // Gentle saturation
Ndef(\pulseBase).set(\wet12, 0);
)

// --- PULSE & SINE WEAVE SEQUENCES (Will be introduced in stages) ---
// Initialize Pbindefs, but don't connect them to Ndefs yet.
(
Pbindef(\sinePadSeq,
	\degree, Pseq([0, 2, 4, 7, 5, 2, 0, -2], inf),
	\scale, Scale.minor,
	\dur, 8, // Very slow changes
	\amp, 0.1,
	\atk, 4, \rel, 8, \sus, 4, // Long envelope
	\lfoFreq, Pwhite(0.08, 0.12, inf),
	\lfoDepth, Pwhite(0.003, 0.007, inf),
	\detune, Pwhite(0.001, 0.003, inf),
	\t_trig, 1
);

Pbindef(\pulseSeq,
	\dur, Pseq([1.5, 1, 0.5, 2], inf), // Syncopated, slow rhythm
	\degree, Pseq([-12, -12.01, -12.02, -12], inf), // Very low pitch
	\scale, Scale.chromatic, // Chromatic scale doesn't matter for specific degree, just direct frequency
	\amp, 0.15,
	\atk, 0.5, \rel, 3,
	\width, Pwhite(0.7, 0.9, inf), // Fluctuate width slightly
	\pan, Pwhite((-0.5), 0.5, inf),
	\t_trig, 1
);

Pbindef(\sineLeadSeq,
	\dur, Pseq([0.25, 0.5, 0.25, 0.25], inf), // Arpeggiated rhythm
	\degree, Pseq([0, 2, 4, 5, 7, 5, 4, 2], inf), // Simple ascending/descending
	\scale, Scale.major,
	\amp, 0.2,
	\atk, 0.01, \rel, 0.3,
	\detune, 0.003,
	\pan, Pwhite((-0.7), 0.7, inf),
	\t_trig, 1
);
)

// --- PULSE & SINE WEAVE LIVE COMPOSITION ---

// --- 1. Introduction: Ethereal Pulse ---
// Ndef(\sinePad) fades in slowly, static sound
(
Ndef(\sinePad).set(\amp, 0.001); // Start almost silent for slow fade in
Ndef(\sinePad).xset(\amp, 0.1, \freq, 180, \lfoFreq, 0.1, \lfoDepth, 0.005, \detune, 0.002, \pan, 0); // Ethereal pad
Ndef(\sinePad).xset(\wet10, 0.7); // High reverb for vast soundscape
)

// Ndef(\pulseBase) enters after \sinePad has established itself
(
fork {
	20.wait; // Wait 20 seconds for sinePad to establish
	Ndef(\pulseBase).set(\amp, 0.001); // Start almost silent
	Ndef(\pulseBase).xset(\amp, 0.15, \freq, 60, \width, 0.85, \atk, 0.5, \rel, 3, \pan, 0); // Deep, soft pulse
	Ndef(\pulseBase).xset(\wet10, 0.6); // Moderate reverb for depth
};
)

// --- 2. Rhythmic Incursion: Pulsing Groove ---
(
fork {
	60.wait; // Wait for initial atmosphere to develop
	// \pulseBase gets Pbindef
	Pbindef(\pulseSeq).resume; // Ensure it's not accidentally stopped
	Ndef(\pulseBase).quant = 1;
	Ndef(\pulseBase)[1] = \set -> Pbindef(\pulseSeq);
	Pbindef(\pulseSeq, \amp, 0.2); // Increase amplitude slightly
	Ndef(\pulseBase).xset(\wet12, 0.3); // Add subtle saturation

	// \sineLead enters
	Ndef(\sineLead).set(\amp, 0.001); // Start silent for fade in
	Ndef(\sineLead).xset(\amp, 0.2); // Bring in sine lead
	Ndef(\sineLead).quant = 1;
	Ndef(\sineLead)[1] = \set -> Pbindef(\sineLeadSeq);
	Ndef(\sineLead).xset(\wet11, 0.4); // Add short delay

	// \sinePad adapts
	Ndef(\sinePad).xset(\lfoFreq, 0.15); // Slightly faster vibrato
};
)

// --- 3. Harmonic Ascent: Shimmering Density ---
(
fork {
	120.wait; // Wait for rhythmic incursion to develop
	// \sineLead becomes faster and richer
	Pbindef(\sineLeadSeq,
		\dur, Pseq([0.125, 0.25, 0.125, 0.125], inf), // Faster rhythm
		\degree, Pseq([7, 9, 11, 12, 14, 12, 11, 9], inf), // Higher arpeggio
		\detune, 0.005 // More noticeable detune
	);
	Ndef(\sineLead).xset(\amp, 0.3); // Increase volume
	Ndef(\sineLead).xset(\wet10, 0.8, \wet11, 0.6); // More reverb and delay

	// \sinePad introduces evolving chords
	Pbindef(\sinePadSeq).resume; // Ensure it's not accidentally stopped
	Ndef(\sinePad).quant = 1;
	Ndef(\sinePad)[1] = \set -> Pbindef(\sinePadSeq);
	Pbindef(\sinePadSeq, \dur, 6); // Slightly faster chord changes
	Ndef(\sinePad).xset(\detune, 0.004); // Increase detune for more beating
	Ndef(\sinePad).xset(\wet10, 0.9, \wet11, 0.5); // Maximize reverb, add delay

	// \pulseBase drops out and returns
	Pbindef(\pulseSeq).stop; // Pause the rhythmic pulse
	Ndef(\pulseBase).xset(\amp, 0.05, \freq, 40, \width, 0.95); // Sustain low drone
	20.wait; // Hold drone for a bit
	Pbindef(\pulseSeq,
		\dur, Pseq([4, 2, 8], inf), // Very sparse, slow pulse
		\amp, 0.1,
		\degree, Pseq([-12, -12, -13], inf) // Slightly different low notes
	).resume;
	Ndef(\pulseBase).quant = 1; // Re-engage Pbindef, but slowly
	Ndef(\pulseBase).xset(\wet12, 0.2); // Less saturation as it's sparser
};
)

// --- 4. Outro: Dissipation into Silence ---
(
fork {
	200.wait; // Wait for the peak to develop and sustain
	// \sineLead dissipates
	Pbindef(\sineLeadSeq,
		\dur, Pseq([1, 2, 4, 8], inf), // Slow down
		\degree, Pseq([5, 4, 2, 0], inf) // Descend
	);
	Ndef(\sineLead).xset(\amp, 0.1); // Reduce amplitude
	Ndef(\sineLead).xset(\wet10, 0.9, \wet11, 0.8); // Maximize effects
	15.wait;
	Pbindef(\sineLeadSeq).stop; // Stop sequence
	Ndef(\sineLead).xset(\amp, 0.0); // Ensure silence
	Ndef(\sineLead).clear(4); // Clear Ndef

	// \pulseBase dissipates
	Pbindef(\pulseSeq,
		\dur, Pseq([8, 16], inf), // Even slower
		\amp, 0.05 // Very quiet
	);
	Ndef(\pulseBase).xset(\wet10, 0.9); // Maximize reverb
	10.wait;
	Pbindef(\pulseSeq).stop; // Stop sequence
	Ndef(\pulseBase).xset(\amp, 0.0); // Ensure silence
	Ndef(\pulseBase).clear(6); // Clear Ndef

	// \sinePad is the last to fade
	Pbindef(\sinePadSeq, \dur, 12, \degree, Pseq([0, -2], inf)); // Slowest chord changes, settling
	Ndef(\sinePad).xset(\lfoFreq, 0.05, \detune, 0.001); // Slower LFO, less detune
	Ndef(\sinePad).xset(\wet10, 1.0, \wet11, 0.7); // Maximize effects
	20.wait;
	Pbindef(\sinePadSeq).stop; // Stop sequence
	Ndef(\sinePad).xset(\amp, 0.0); // Ensure silence
	Ndef(\sinePad).clear(10); // Clear Ndef with a very long fade
};
)