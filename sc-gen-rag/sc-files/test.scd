// Set a base fadeTime for Ndefs for smoother transitions, and initialize globals
// Initialize globals (Ndef class does not accept a global fadeTime)
(
t = TempoClock.default; // Initialize 't' so t.tempo operations work
Pdef.defaultQuant = 1;  // Initialize to prevent nil errors in Pfunc calculations
)

// --- I. INTRODUCCIÓN: EL LATIDO INSTRUMENTS ---
(
// Ndef(\golpe): Low-frequency, short-duration impulse (knuckle tap)
Ndef(\golpe).clear;
Ndef(\golpe, {
	|freq=180, rq=0.08, amp=0.4, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.005, 0.05), t_trig);
	// Use WhiteNoise with BPF for a more organic, woody tap sound
	sig = BPF.ar(WhiteNoise.ar(1), freq, rq);
	Pan2.ar(sig * env * amp, 0);
}).play;

// Ndef(\cajonKick): Deeper, slightly longer impulse (cajón bass)
Ndef(\cajonKick).clear;
Ndef(\cajonKick, {
	|freq=80, decayscale=1.0, amp=0.6, t_trig=1|
	var env, exciter, sig;
	env = EnvGen.ar(Env.perc(0.01, 0.15), t_trig);
	exciter = PinkNoise.ar * env;
	// DynKlank for a resonant body sound
	sig = DynKlank.ar(
		`[ // Changed from #[ to `[
			[1, 1.5, 2.1, 2.8] * freq, // Frequencies
			[1, 0.7, 0.4, 0.2],        // Amplitudes
			[0.15, 0.1, 0.08, 0.05]    // Ring times
		],
		exciter,
		decayscale: decayscale // Controls overall decay
	);
	sig = LPF.ar(sig, freq * 3); // Warm the kick
	Pan2.ar(sig * amp, Rand(-0.1, 0.1));
}).play;
)

// --- I. INTRODUCCIÓN: EL LATIDO EFFECTS ---
(
// Ndef(\golpe) reverb
Ndef(\golpe)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.2, 0.2) };
Ndef(\golpe).set(\wet10, 0); // Initialize dry
)

// --- I. INTRODUCCIÓN: EL LATIDO SEQUENCES ---
(
Pbindef(\golpeSeq,
	\dur, 1/4,
	\amp, Pseq([0.6, 0.4, 0.6, 0.4], inf), // Accented pulse
	\t_trig, 1
);

Pbindef(\cajonKickSeq,
	\dur, 1/4,
	\legato, 0.7,
	\amp, Pseq([0.8, 0, 0.5, 0], inf), // Syncopated low-end
	\t_trig, 1
);

Ndef(\golpe).quant = 1;
Ndef(\cajonKick).quant = 1;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeq);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeq);
)

// --- II. EXPLORACIÓN BINARIA Y TERNARIA INSTRUMENTS ---
(
// Ndef(\cajonSnare): Sharper, mid-frequency click/thwack
Ndef(\cajonSnare).clear;
Ndef(\cajonSnare, {
	|freq=3000, rq=0.05, amp=0.3, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.08), t_trig);
	// BandPassFilter WhiteNoise for a sharp snare-like sound
	sig = BPF.ar(WhiteNoise.ar(1), freq, rq, 4);
	Pan2.ar(sig * env * amp, Rand(-0.3, 0.3));
}).play;

// Ndef(\palmas): Short, sharp, high-frequency claps
Ndef(\palmas).clear;
Ndef(\palmas, {
	|freq=8000, rq=0.01, amp=0.25, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.03), t_trig);
	// High-passed Crackle for a crisp clap texture
	sig = HPF.ar(Crackle.ar(1.9, 0.5), freq);
	Splay.ar(sig * env * amp); // Use Splay for wide stereo
}).play;

// Ndef(\rasgueado): Short, rich, percussive broadband sound for guitar strumming
Ndef(\rasgueado).clear;
Ndef(\rasgueado, {
	|freq=150, rq=0.1, amp=0.5, atk=0.01, rel=0.2, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	// Blip for rich harmonics, filtered for percussive strum
	sig = Blip.ar(freq, 20); // 20 harmonics
	sig = BPF.ar(sig, freq * 4, rq); // Shape it with a BPF
	Pan2.ar(sig * env * amp, Rand(-0.4, 0.4));
}).play;

// Ndef(\bass): Clean sine wave for a walking bassline
Ndef(\bass).clear;
Ndef(\bass, {
	|freq=60, amp=0.5, rel=0.7, filterFreq=200, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.01, rel), t_trig);
	sig = SinOsc.ar(freq);
	sig = LPF.ar(sig, filterFreq); // Keep it warm
	Pan2.ar(sig * env * amp, 0);
}).play;
)

// --- II. EXPLORACIÓN BINARIA Y TERNARIA EFFECTS ---
(
// Ndef(\palmas) delay
Ndef(\palmas)[11] = \filter -> { |in| CombL.ar(in.sum, 0.2, 0.08, 0.3) }; // Short slapback
Ndef(\palmas).set(\wet11, 0);

// Ndef(\rasgueado) reverb
Ndef(\rasgueado)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.4, 0.3) };
Ndef(\rasgueado).set(\wet10, 0);
)

// --- II. EXPLORACIÓN BINARIA Y TERNARIA SEQUENCES ---
(
// Binary (4/4) rhythm
Pbindef(\cajonSnareSeq,
	\dur, 1/4,
	\amp, Pseq([0, 0.4, 0, 0.3], inf),
	\t_trig, 1
);

Pbindef(\palmasSeq,
	\dur, 1/4,
	\amp, Pseq([0.5, 0.7, 0.5, 0.7], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeq,
	\dur, 1/2,
	\amp, Pseq([0.6, 0.0, 0.4, 0.0], inf),
	\freq, Pseq([120, 150, 100, 130], inf),
	\t_trig, 1
);

Pbindef(\bassSeq,
	\dur, 1,
	\degree, Pseq([0, 2, 4, 5], inf) + 36, // Root, M2, M3, P4
	\amp, 0.4,
	\rel, 0.8,
	\t_trig, 1
);

Ndef(\cajonSnare).quant = 1;
Ndef(\palmas).quant = 1;
Ndef(\rasgueado).quant = 1;
Ndef(\bass).quant = 1;

Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeq);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeq);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeq);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeq);
)

// --- III. LA RUEDA DE DOCE INSTRUMENTS ---
(
// Ndef(\melodiaPluck): Karplus-Strong string model
Ndef(\melodiaPluck).clear;
Ndef(\melodiaPluck, {
	|freq=220, amp=0.7, bright=0.5, atk=0.005, rel=0.7, t_trig=1|
	var env, exciter, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	// Short noise burst for excitation
	exciter = WhiteNoise.ar(0.2) * EnvGen.ar(Env.perc(0.001, 0.005), t_trig);
	// Pluck UGen for string sound
	sig = Pluck.ar(exciter, t_trig, 0.5, 1/freq, 3, bright); // 0.5 is maxdelaytime, bright is coef
	Pan2.ar(sig * env * amp, Rand(-0.2, 0.2));
}).play;
)

// --- III. LA RUEDA DE DOCE EFFECTS ---
(
// Ndef(\melodiaPluck) reverb and delay
Ndef(\melodiaPluck)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.4) };
Ndef(\melodiaPluck).set(\wet10, 0);

Ndef(\melodiaPluck)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 1.2) }; // Subtle, longer delay
Ndef(\melodiaPluck).set(\wet11, 0);
)

// --- III. LA RUEDA DE DOCE SEQUENCES ---
(
// 12-beat cycle for Soleá / Peteneras (accents on 12)
// ~soleaCycleDur will be dynamically set based on defaultQuant (1 beat = 1/4 dur in a 4/4 measure)
// So, if defaultQuant = 1, a 1/4 note gets 1 second. A 12-beat cycle should then be 12*1 second = 12 seconds.
// But compás is typically much faster. Let's make ~soleaCycleDur control the entire cycle duration.
// Let's assume t.tempo = 60/80 (0.75 beat duration) so a 12-beat cycle is 12 * 0.75 = 9 seconds
~soleaCycleDur = Pfunc { Pdef.defaultQuant.value * 12 * (60 / t.tempo) / 4 }; // 12 beats, scaled by actual tempo and then by 4/4 assumption. Simplified.

// Let's explicitly define a *base beat duration* for 12-beat cycles and use that as the fundamental `\dur` unit
~base12BeatUnit = Pfunc { Pdef.defaultQuant.value * (60 / t.tempo) * (1/4) }; // If t.tempo = 60 (1s/beat), this is 0.25s per 'unit'

Pbindef(\golpeSeqSolea,
	\dur, ~base12BeatUnit, // Each dur is 1/12th of the cycle duration
	\amp, Pseq([0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.7], inf), // Accent on 12
	\t_trig, 1
);

Pbindef(\cajonKickSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0.5, 0, 0, 0.4, 0, 0, 0.3, 0, 0, 0.5, 0, 0.8], inf),
	\t_trig, 1
);

Pbindef(\cajonSnareSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0, 0.2, 0, 0.2, 0, 0.3, 0, 0.2, 0.3, 0, 0, 0.4], inf),
	\t_trig, 1
);

Pbindef(\palmasSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0.4, 0.6, 0.4, 0.6, 0.4, 0.7, 0.4, 0.6, 0.4, 0.6, 0.4, 0.8], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeqSolea,
	\dur, ~base12BeatUnit * Pseq(([2, 1, 2, 1, 2, 1, 2, 1].normalizeSum * 12), inf), // Longer strokes over the 12 beats
	\amp, Pseq([0.6, 0, 0.5, 0, 0.7, 0, 0.6, 0.0], inf),
	\freq, Pseq([130, 0, 100, 0, 150, 0, 120, 0], inf),
	\t_trig, Pseq([1, 0], inf) // Only trigger on downbeats for the longer strokes
);

Pbindef(\melodiaPluckSeq,
	\dur, ~base12BeatUnit * Pseq(([3, 1, 2, 2, 4].normalizeSum * 12), inf), // Slow, melancholic melody
	\degree, Pseq([0, -2, -4, -5, -7], inf) + 48, // C major scale in MIDI
	\amp, Pseq([0.7, 0.6, 0.7, 0.5, 0.8], inf),
	\rel, Pkey(\dur) * 0.8,
	\t_trig, 1
);
)

// --- IV. BULERÍAS: EL FUEGO SEQUENCES ---
(
// 12-beat Bulerías cycle (accents on 3rd, 6th, 8th, 10th, 12th beats)
~baseBuleriasBeatUnit = Pfunc { Pdef.defaultQuant.value * (60 / t.tempo) * (1/4) }; // Faster overall unit

Pbindef(\golpeSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0.2, 0.2, 0.7, 0.2, 0.2, 0.7, 0.2, 0.7, 0.2, 0.7, 0.2, 0.8], inf),
	\t_trig, 1
);

Pbindef(\cajonKickSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0.5, 0, 0.8, 0, 0, 0.7, 0, 0.8, 0, 0.7, 0, 0.9], inf),
	\t_trig, 1
);

Pbindef(\cajonSnareSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0, 0.3, 0.5, 0.2, 0.4, 0.6, 0.2, 0.5, 0.7, 0.3, 0.5, 0.8], inf),
	\t_trig, 1
);

Pbindef(\palmasSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq([2, 2, 2, 2, 2, 2], inf), // Palmas in groups of 6 beats (2 units each)
	\amp, Pseq([0.8, 0.7, 0.9, 0.7, 0.8, 1.0], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 0.5].normalizeSum * 12), inf), // Fast, intricate strumming
	\amp, Pseq([0.8, 0.6, 0.7, 0.9, 0.7, 0.8, 1.0, 0.8, 0.9], inf),
	\freq, Pseq([180, 200, 160, 220, 170, 190, 240, 180, 210], inf),
	\t_trig, 1
);

Pbindef(\melodiaPluckSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5].normalizeSum * 12), inf), // Faster, percussive melody
	\degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12], inf) + 60, // Higher and faster
	\amp, Pseq([0.8, 0.7, 0.6, 0.7, 0.9, 0.8, 0.7, 0.9], inf),
	\rel, Pkey(\dur) * 0.7,
	\t_trig, 1
);
)

// --- V. AIRE LIBRE INSTRUMENTS ---
(
// Ndef(\pads): Evolving, sustained chords with detuned sine waves
Ndef(\pads).clear;
Ndef(\pads, {
	|freq=110, amp=0.2, sus=5.0, detune=0.005, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [0.5, sus, 1.0], \sine), t_trig);
	// Mix of detuned sine waves for a lush pad
	sig = Mix.fill(4, { |i|
		var f = freq * (1 + (detune * (i-1.5)));
		// Replaced LFO with SinOsc.kr for the subtle pitch modulation
		SinOsc.ar(f + SinOsc.kr(0.1 + (i*0.02), 0, 2));
	});
	Splay.ar(sig * env * amp);
}).play;

// Ndef(\melodiaFree): Sustained, glissando-capable melodic voice (FM synthesis)
Ndef(\melodiaFree).clear;
Ndef(\melodiaFree, {
	|freq=220, amp=0.4, sus=4.0, modIndex=1.5, modFreq=200, sweepRate=0.05, t_trig=1|
	var env, mod, car, sweepLFO;
	env = EnvGen.ar(Env([0, 1, 1, 0], [1.0, sus, 2.0]), t_trig);
	sweepLFO = LFTri.ar(sweepRate).range(0.98, 1.02); // Slow pitch sweep
	mod = SinOsc.ar(modFreq * sweepLFO) * modIndex;
	car = SinOsc.ar(freq * sweepLFO + mod);
	Pan2.ar(car * env * amp, 0);
}).play;
)

// --- V. AIRE LIBRE EFFECTS ---
(
// Ndef(\pads) reverb and delay
Ndef(\pads)[10] = \filter -> { |in| GVerb.ar(in.sum, 100, 8, 0.7, 0.8, 15, 0.5) }; // Lush GVerb
Ndef(\pads).set(\wet10, 0);

Ndef(\pads)[11] = \filter -> { |in| CombL.ar(in.sum, 1.5, 0.8, 5.0) }; // Long feedback delay
Ndef(\pads).set(\wet11, 0);

// Ndef(\melodiaFree) reverb and delay
Ndef(\melodiaFree)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.5) };
Ndef(\melodiaFree).set(\wet10, 0);

Ndef(\melodiaFree)[11] = \filter -> { |in| AllpassC.ar(in, 2.0, 1.0, 6.0) }; // Diffused long delay
Ndef(\melodiaFree).set(\wet11, 0);
)

// --- V. AIRE LIBRE SEQUENCES ---
(
// For ambient section, Pbindefs will be triggered manually or with very slow patterns.
Pbindef(\melodiaFreeSeq,
	\dur, 8, // Very long notes
	\freq, Pseq([110, 146.83, 98, 130.81], inf), // A2, D3, G2, C3
	\legato, 4, // Glissando between notes
	\amp, 0.6,
	\sus, Pkey(\dur) * 0.9,
	\t_trig, 1
);

Pbindef(\padsSeq,
	\dur, 16,
	\freq, Pseq([65.4, 82.4, 98, 130.8], inf), // C2, E2, G2, C3
	\amp, 0.3,
	\sus, 15,
	\t_trig, 1
);
)

// --- MASTER MIXING & GLOBAL EFFECTS ---
(
// Define a master Ndef to apply global effects (e.g., low-pass filter).
// This Ndef will receive all audio from the main output bus (0 and 1) and process it.
Ndef(\masterMix).clear;
Ndef(\masterMix, {
	var in = In.ar(0, 2); // Receive audio from the main output bus
	var lpfCutoff = \lpfCutoff.kr(20000); // Global LPF cutoff frequency
	var lpfRes = \lpfRes.kr(0.1);
	var masterAmp = \amp.kr(1.0);
	in = RLPF.ar(in, lpfCutoff, lpfRes); // Apply global low-pass filter
	Out.ar(0, in * masterAmp); // Send processed audio back to the main output
}).play;
)


// --- COMPOSITION CONTROL (Initial State and Performance Arc) ---

// Initial setup with minimal sounds (Phase I)
(
// Ensure all Ndefs are initially stopped and dry before setting up the first phase
Ndef(\golpe).stop; Ndef(\cajonKick).stop; Ndef(\cajonSnare).stop;
Ndef(\palmas).stop; Ndef(\rasgueado).stop; Ndef(\bass).stop;
Ndef(\melodiaPluck).stop; Ndef(\pads).stop; Ndef(\melodiaFree).stop;

// Clear patterns from any previous runs
Pbindef(\golpeSeq).stop; Pbindef(\cajonKickSeq).stop; Pbindef(\cajonSnareSeq).stop;
Pbindef(\palmasSeq).stop; Pbindef(\rasgueadoSeq).stop; Pbindef(\bassSeq).stop;
Pbindef(\golpeSeqSolea).stop; Pbindef(\cajonKickSeqSolea).stop; Pbindef(\cajonSnareSeqSolea).stop;
Pbindef(\palmasSeqSolea).stop; Pbindef(\rasgueadoSeqSolea).stop; Pbindef(\bassSeqSolea).stop;
Pbindef(\melodiaPluckSeq).stop; Pbindef(\golpeSeqBulerias).stop; Pbindef(\cajonKickSeqBulerias).stop;
Pbindef(\cajonSnareSeqBulerias).stop; Pbindef(\palmasSeqBulerias).stop; Pbindef(\rasgueadoSeqBulerias).stop;
Pbindef(\melodiaPluckSeqBulerias).stop; Pbindef(\bassSeqBulerias).stop; Pbindef(\padsSeq).stop;
Pbindef(\melodiaFreeSeq).stop; Pbindef(\golpeOutro).stop;

// Reset all wet levels to 0
Ndef(\golpe).set(\wet10, 0);
Ndef(\palmas).set(\wet11, 0); Ndef(\palmas).set(\wet10, 0); // Also adding reverb slot for later
Ndef(\rasgueado).set(\wet10, 0);
Ndef(\melodiaPluck).set(\wet10, 0, \wet11, 0);
Ndef(\pads).set(\wet10, 0, \wet11, 0);
Ndef(\melodiaFree).set(\wet10, 0, \wet11, 0);

// Bring in Phase I instruments and sequences
Ndef(\golpe).play;
Ndef(\cajonKick).play;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeq);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeq);

// Initial effect settings for Phase I
Ndef(\golpe).xset(\wet10, 0.2); // short, dry reverb
// Ndef(\golpe).xset(\wet10, 0); // Revert

// Set initial tempo
t.tempo = 60/80; // 80 BPM
// t.tempo = 60/60; // Revert
)

// --- LIVE CODING TWEAKS (Simulated Performance Progression) ---

// --- Phase II. Exploración Binaria y Ternaria ---
// Introduce cajonSnare, palmas, rasgueado, bass with 4/4 rhythm
(
Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3); // Bring in cajon snare
// Ndef(\cajonSnare).xset(\amp, 0); // Revert
Ndef(\palmas).play; Ndef(\palmas).xset(\amp, 0.25); // Bring in palmas
// Ndef(\palmas).xset(\amp, 0); // Revert
Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.5); // Bring in rasgueado
// Ndef(\rasgueado).xset(\amp, 0); // Revert
Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.4); // Bring in bassline
// Ndef(\bass).xset(\amp, 0); // Revert

Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeq);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeq);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeq);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeq);

// Apply effects for Phase II
Ndef(\palmas).xset(\wet11, 0.1); // Add short delay to palmas
// Ndef(\palmas).xset(\wet11, 0); // Revert
Ndef(\rasgueado).xset(\wet10, 0.3); // Add short reverb to rasgueado
// Ndef(\rasgueado).xset(\wet10, 0); // Revert
)

// --- Phase III. La Rueda de Doce ---
// Transition to 12-beat cycle (Soleá/Peteneras accentuation - on 12)
(
// Stop current 4/4 patterns and switch to 12-beat soleá cycle patterns
Pbindef(\golpeSeq).stop; Pbindef(\cajonKickSeq).stop;
Pbindef(\cajonSnareSeq).stop; Pbindef(\palmasSeq).stop;
Pbindef(\rasgueadoSeq).stop; Pbindef(\bassSeq).stop;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqSolea);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqSolea);
Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqSolea);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqSolea);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqSolea);
// Define bassSeqSolea here for a richer bassline in 12-beat context
Pbindef(\bassSeqSolea,
	\dur, ~base12BeatUnit * Pseq(([3, 1, 2, 2, 4].normalizeSum * 12), inf),
	\degree, Pseq([0, -2, -4, -5, -7], inf) + 36,
	\amp, 0.45,
	\rel, Pkey(\dur) * 0.9,
	\t_trig, 1
);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeqSolea);

// Introduce melodic pluck
Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.7);
// Ndef(\melodiaPluck).xset(\amp, 0); // Revert
Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeq);

// Apply effects for Phase III
Ndef(\melodiaPluck).xset(\wet10, 0.5, \wet11, 0.3); // Medium decay reverb and subtle long delay
// Ndef(\melodiaPluck).xset(\wet10, 0, \wet11, 0); // Revert

// Slightly increase tempo
t.tempo = 60/70; // 70 BPM
// t.tempo = 60/80; // Revert
)

// --- Phase IV. Bulerías: El Fuego ---
// Climax with intense 12-beat Bulerías cycle (accents 3, 6, 8, 10, 12)
(
// Stop Soleá patterns and switch to Bulerías patterns
Pbindef(\golpeSeqSolea).stop; Pbindef(\cajonKickSeqSolea).stop;
Pbindef(\cajonSnareSeqSolea).stop; Pbindef(\palmasSeqSolea).stop;
Pbindef(\rasgueadoSeqSolea).stop; Pbindef(\bassSeqSolea).stop;
Pbindef(\melodiaPluckSeq).stop;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqBulerias);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias);
Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqBulerias);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias);
Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias);

// Ndef(\bass) adapted for Bulerías
Pbindef(\bassSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 0.5].normalizeSum * 12), inf),
	\degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12], inf) + 36, // Adapted to faster rhythm
	\amp, 0.5,
	\rel, Pkey(\dur) * 0.7,
	\t_trig, 1
);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias);

// Increase rasgueado prominence and complexity
Ndef(\rasgueado).xset(\amp, 0.7);
// Ndef(\rasgueado).xset(\amp, 0.5); // Revert

// Apply effects for Phase IV
Ndef(\rasgueado).xset(\freq, 250, \rq, 0.08); // Sharper rasgueado, simulating hpFreq (no explicit hpFreq arg)
// Ndef(\rasgueado).xset(\freq, 150, \rq, 0.1); // Revert
Ndef(\palmas).xset(\wet11, 0.05); // Shorten delay time for tightness
// Ndef(\palmas).xset(\wet11, 0.1); // Revert

// Reduce reverb on most elements for a drier, more immediate sound
Ndef(\golpe).xset(\wet10, 0.1); // Less reverb
// Ndef(\golpe).xset(\wet10, 0.2); // Revert
Ndef(\rasgueado).xset(\wet10, 0.2); // Less reverb
// Ndef(\rasgueado).xset(\wet10, 0.3); // Revert
Ndef(\melodiaPluck).xset(\wet10, 0.3, \wet11, 0.1); // Less reverb and delay
// Ndef(\melodiaPluck).xset(\wet10, 0.5, \wet11, 0.3); // Revert

// Fastest tempo
t.tempo = 60/50; // 50 BPM (fastest)
// t.tempo = 60/70; // Revert
)

// --- Phase V. Aire Libre ---
// Radical contrast: Free-form, sustained sonic exploration
(
// Stop all rhythmic Pbindefs and fade out rhythmic Ndefs
Pbindef(\golpeSeqBulerias).stop; Pbindef(\cajonKickSeqBulerias).stop;
Pbindef(\cajonSnareSeqBulerias).stop; Pbindef(\palmasSeqBulerias).stop;
Pbindef(\rasgueadoSeqBulerias).stop; Pbindef(\bassSeqBulerias).stop;
Pbindef(\melodiaPluckSeqBulerias).stop;

// Clear Ndefs with fade time
Ndef(\golpe).clear(2); Ndef(\cajonKick).clear(2);
Ndef(\cajonSnare).clear(2); Ndef(\palmas).clear(2);
Ndef(\rasgueado).clear(2); Ndef(\bass).clear(2);
Ndef(\melodiaPluck).clear(2);

// Bring in pads and free melody
Ndef(\pads).play; Ndef(\pads).xset(\amp, 0.2); // Fade in pads
// Ndef(\pads).xset(\amp, 0); // Revert
Ndef(\melodiaFree).play; Ndef(\melodiaFree).xset(\amp, 0.4); // Fade in free melody
// Ndef(\melodiaFree).xset(\amp, 0); // Revert

Ndef(\pads)[1] = \set -> Pbindef(\padsSeq);
Ndef(\melodiaFree)[1] = \set -> Pbindef(\melodiaFreeSeq);

// Apply effects for Phase V
Ndef(\pads).xset(\wet10, 0.9, \wet11, 0.5); // Lush reverb and long delay for pads
// Ndef(\pads).xset(\wet10, 0, \wet11, 0); // Revert
Ndef(\melodiaFree).xset(\wet10, 0.8, \wet11, 0.6); // Long reverb and diffused delay for melody
// Ndef(\melodiaFree).xset(\wet10, 0, \wet11, 0); // Revert

// (No explicit tempo setting as it's free-form)
)

// --- Phase VI. Retorno del Compás ---
// Re-establish driving 12-beat rhythm (Bulerías variations)
(
// Fade out ambient elements
Pbindef(\padsSeq).stop; Ndef(\pads).clear(2);
Pbindef(\melodiaFreeSeq).stop; Ndef(\melodiaFree).clear(2);

// Re-introduce rhythmic Ndefs, starting with kick and golpe
Ndef(\cajonKick).play; Ndef(\cajonKick).xset(\amp, 0.6); // Fade in
// Ndef(\cajonKick).xset(\amp, 0); // Revert
Ndef(\golpe).play; Ndef(\golpe).xset(\amp, 0.4); // Fade in
// Ndef(\golpe).xset(\amp, 0); // Revert

Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias); // Re-use Bulerías pattern
Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqBulerias);

// Gradually layer in palmas and snare
{
	Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3);
	Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias);
	Ndef(\palmas).play; Ndef(\palmas).xset(\amp, 0.25);
	Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqBulerias);
}.defer(4); // After 4 beats

// Rejoin rasgueado and melodic pluck
{
	Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.6);
	Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias);
	Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.75); // Slightly more prominent
	Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias);
	Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.5);
	Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias);
}.defer(8); // After 8 beats

// Tempo is brisk but controlled
t.tempo = 60/60; // 60 BPM (moderate brisk tempo)
// t.tempo = 60/50; // Revert to previous faster tempo

// Effects: Initially more reverb, then reduce
Ndef(\golpe).xset(\wet10, 0.3); // More reverb for softer re-entry
// Ndef(\golpe).xset(\wet10, 0.1); // Revert
Ndef(\rasgueado).xset(\wet10, 0.4); // More reverb
// Ndef(\rasgueado).xset(\wet10, 0.2); // Revert
Ndef(\melodiaPluck).xset(\wet10, 0.6, \wet11, 0.4); // More reverb/delay
// Ndef(\melodiaPluck).xset(\wet10, 0.3, \wet11, 0.1); // Revert
)

// --- Phase VII. Fin del Baile (Outro) ---
(
// Decelerate the rhythm
t.tempo = 60/80; // Slow down to 80 BPM
// t.tempo = 60/60; // Revert

// Sequentially stop Pbindefs and fade Ndefs
// Fade rasgueado first
Pbindef(\rasgueadoSeqBulerias).stop; Ndef(\rasgueado).clear(2);
// Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.6); Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias); // Revert

// Then bass and cajon snare
{ Pbindef(\bassSeqBulerias).stop; Ndef(\bass).clear(2); }.defer(4);
// { Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.5); Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias); }.defer(4); // Revert
{ Pbindef(\cajonSnareSeqBulerias).stop; Ndef(\cajonSnare).clear(2); }.defer(4);
// { Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3); Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias); }.defer(4); // Revert

// Melodic pluck fades
{ Pbindef(\melodiaPluckSeqBulerias).stop; Ndef(\melodiaPluck).clear(3); }.defer(8);
// { Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.75); Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias); }.defer(8); // Revert

// Increase global reverb for sense of vastness
Ndef(\golpe).xset(\wet10, 0.8);
// Ndef(\golpe).xset(\wet10, 0.3); // Revert
Ndef(\palmas).set(\wet10, 0); // Assign a reverb filter to palmas if not already
Ndef(\palmas)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.3) };
Ndef(\palmas).xset(\wet10, 0.7, \wet11, 0.3); // Introduce reverb + delay
// Ndef(\palmas).xset(\wet10, 0, \wet11, 0.05); // Revert

// End with sparse palmas and golpe, then a final accent from golpe.
// Gradually thin out palmas and kick
{ Pbindef(\cajonKickSeqBulerias).stop; Ndef(\cajonKick).clear(2); }.defer(12);
// { Ndef(\cajonKick).play; Ndef(\cajonKick).xset(\amp, 0.6); Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias); }.defer(12); // Revert

{
	Pbindef(\palmasSeqBulerias).stop; Ndef(\palmas).clear(2);
	Pbindef(\golpeSeqBulerias).stop; // Stop main patterns

	// A final sparse golpe pattern
	Pbindef(\golpeOutro, \dur, 1, \amp, Pseq([0.5, 0, 0.8, 0, 0.5, 0], inf), \t_trig, 1);
	Ndef(\golpe)[1] = \set -> Pbindef(\golpeOutro);
	Ndef(\golpe).xset(\freq, 100); // Deeper final taps
	// Ndef(\golpe).xset(\freq, 180); // Revert
}.defer(16);

// Final fade out for golpe and clear all
{
	Pbindef(\golpeOutro).stop;
	Ndef(\golpe).clear(5); // Long fade for the final taps
	Ndef(\masterMix).clear(5); // Fade out the global LPF
	Ndef.clear(6); // Clear all remaining Ndefs after masterMix fades
	t.tempo = 60/60; // Reset tempo to default
}.defer(24);
)