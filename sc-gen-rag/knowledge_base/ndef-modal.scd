/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: MODAL SYNTHESIS
   Target: Live Coding, JITLib, & Physical Modeling
   Concepts: Ringz, Klank, DynKlank, Exciter-Resonator Separation
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Modal Environment...".postln;

	// --- FIX: Force ProxySpace Initialization ---
	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	// Defaults
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


// =============================================================================
// 1. THE ATOM: SINGLE MODE RESONANCE (Ringz)
// Best for: Tuned percussion, simple pings, creating a "pitched" reverb.
// Physics: Energy Impulse -> Damped Spring
// =============================================================================

// --- A. The Basic Ping (Integrated Exciter) ---
(
Ndef(\modalAtom).fadeTime = 0; // Percussive = Instant
Ndef(\modalAtom, {
	var t_trig = \t_trig.tr(1);
	var freq = \freq.kr(800);
	var decay = \decay.kr(1.0); // Time to drop by 60dB

	// 1. THE EXCITER (The Hammer)
	// We mix a click (Impulse) with a burst of noise (Softness)
	var click = Impulse.ar(0); // 0 freq means "play once when triggered"
	var noise = PinkNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.01), t_trig);
	var exc = click + (noise * 0.5);

	// 2. THE RESONATOR (The Object)
	// Ringz is a resonant filter.
	// Arguments: Input, Frequency, DecayTime
	var sig = Ringz.ar(exc, freq, decay);

	sig * 0.1 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\modalAtom);

// LIVE STRIKE:
// Ndef(\modalAtom).set(\t_trig, 1, \freq, exprand(400, 1200));


// --- B. EXPANSION: Modular Resonator (External Exciter) ---
// This is pure Physical Modeling: separating the "Hammer" from the "String".
(
// 1. The Resonator (Always Listening)
Ndef(\resonator, {
	var input = \in.ar(0 ! 2); // Expects stereo input
	var freq = \freq.kr(440);
	var decay = \decay.kr(2.0);

	// Route input into Ringz
	Ringz.ar(input, freq, decay) * 0.05;
}).play;

// 2. The Exciter (A Rhythmic Pattern)
Ndef(\exciterSeq, Pbind(
	\instrument, \default, // Placeholder, usually a "click" SynthDef
	\dur, 0.25,
	\amp, Pseq([1, 0, 1, 0.5], inf), // The Rhythm
	\freq, 1000 // High freq click
));
)

// ROUTING: Connect Exciter -> Resonator -> Master
// Now the RHYTHM comes from 'exciterSeq', but the TONE comes from 'resonator'
Ndef(\resonator) <<> Ndef(\exciterSeq);
Ndef(\master) <<> Ndef(\resonator);


// =============================================================================
// 2. FIXED MODAL BANK (Klank)
// Best for: Bells, Vibraphones, Marimbas, Static Metallic Objects.
// Concept: Objects vibrate at multiple fixed frequencies ("Modes").
// =============================================================================

(
Ndef(\modalBell).fadeTime = 0;
Ndef(\modalBell, {
	var t_trig = \t_trig.tr(1);
	var amp = \amp.kr(0.3);

	// 1. Exciter (Filtered Noise Burst)
	var exc = PinkNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), t_trig);

	// 2. Spectral Definition (The DNA of the sound)
	// Format: `[ [freqs], [amps], [decays] ]
	// Standard "Chime" Ratios
	var specs = `[
		[1, 2.7, 5.4, 8.9],    // Frequencies (Ratios)
		[1, 0.5, 0.3, 0.1],    // Amplitudes
		[1, 0.8, 0.6, 0.2]     // Decay Times
	];

	// 3. Klank (Efficient Fixed Bank)
	// Input, FreqScale, FreqOffset, DecayScale
	var sig = Klank.ar(specs, exc, \freq.kr(440), 0, \decay.kr(2.0));

	sig * amp ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\modalBell);

// LIVE STRIKE:
// Ndef(\modalBell).set(\t_trig, 1, \freq, 200, \decay, 4);


// =============================================================================
// 3. DYNAMIC MODAL BANK (DynKlank)
// Best for: Bending metal, water bowls, morphing materials.
// Concept: Unlike Klank, we can modulate the modes LIVE.
// =============================================================================

(
Ndef(\bendingMetal, {
	var freq = \freq.kr(150);
	var bend = \bend.kr(0); // Detune amount (0 to 1)

	// Continuous Exciter: Random metallic scrapes
	var exc = Dust.ar(10) * 0.5; // Dust = random clicks

	// Dynamic Mode Generation
	// We use Array math to bend the partials apart
	var freqs = [1, 2.4, 4.6, 8.1] * freq;
	var bentFreqs = freqs * [1, 1+bend, 1+(bend*2), 1+(bend*3)];

	var amps = [1, 0.4, 0.2, 0.1];
	var decays = [1, 0.8, 0.6, 0.5] * \decay.kr(1.5);

	// DynKlank allows Audio Rate modulation of the specs
	var sig = DynKlank.ar(
		`[bentFreqs, amps, decays],
		exc
	);

	// Compressor to tame the resonances
	sig = Compander.ar(sig, sig, 0.5, 1, 0.3) * 0.1 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\bendingMetal);

// LIVE MODULATION:
// Create an LFO to bend the metal
(
Ndef(\lfoBend, { SinOsc.kr(0.2).range(0.0, 0.2) });
)
Ndef(\bendingMetal).map(\bend, Ndef(\lfoBend));


// =============================================================================
// 4. ADVANCED: THE "SCRAPE" (Continuous Excitation)
// Best for: Bowed glass, singing bowls, friction sounds.
// Concept: Using Band-Limited Noise to excite the modes continuously.
// =============================================================================

(
Ndef(\singingBowl, {
	var freq = \freq.kr(200);
	var pressure = \press.kr(0.5); // How hard we press (0 to 1)

	// 1. The Bow/Scrape Exciter
	// A noisy signal focused around the resonant frequency
	var noise = WhiteNoise.ar();
	var exc = BPF.ar(noise, freq, 0.5) * pressure;

	// 2. The Bowl (Resonator)
	// Very long decays create the "singing" loop effect
	var sig = DynKlank.ar(
		`[
			[1, 2.3, 4.1, 6.5] * freq,
			[1, 0.1, 0.2, 0.05],
			[4, 3, 2, 1] // Long decays
		],
		exc
	);

	// Soft saturation to simulate physical limits
	sig = sig.tanh * 0.3 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\singingBowl);

// LIVE PERFORMANCE:
Ndef(\singingBowl).xset(\press, 0.8, \freq, 250); // Start singing
// Ndef(\singingBowl).xset(\press, 0.0); // Lift the bow (ring out)


// =============================================================================
// 5. THE "UBER-MATERIAL" SYNTH (Parameterized)
// Best for: Generating Wood, Glass, and Metal from one algorithm.
// =============================================================================

(
Ndef(\modalMaterial).fadeTime = 0;
Ndef(\modalMaterial, {
	var t_trig = \t_trig.tr(1);
	var freq = \freq.kr(440);

	// Material Params
	var stiffness = \stiff.kr(1.0); // 1.0 = Harmonic, >1.0 = Stretched/Glass
	var decayMain = \decay.kr(1.0);
	var hardness  = \hard.kr(0.5);  // Exciter hardness

	// 1. Dual Exciter (Click + Noise)
	var click = Impulse.ar(0) * hardness;
	var brush = PinkNoise.ar() * EnvGen.ar(Env.perc(0.005, 0.05), t_trig) * (1-hardness);
	var exc = click + brush;

	// 2. Algorithmic Modes
	// We generate mode ratios based on stiffness
	var ratios = [1, 2.7, 5.4, 8.9, 12.8];
	var stretchedRatios = ratios.pow(stiffness);

	var modes = stretchedRatios * freq;
	var amps = [1, 0.6, 0.4, 0.3, 0.2];
	var decays = [1, 0.7, 0.5, 0.4, 0.3] * decayMain;

	var sig = DynKlank.ar(`[modes, amps, decays], exc);

	sig * 0.1 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\modalMaterial);

// PRESETS:

// 1. Vibraphone (Low Stiffness, Long Decay, Soft Mallet)
Ndef(\modalMaterial).set(\t_trig, 1, \stiff, 1.0, \decay, 3.0, \hard, 0.1, \freq, 300);

// 2. Marimba (Medium Stiffness, Short Decay, Hard Mallet)
Ndef(\modalMaterial).set(\t_trig, 1, \stiff, 1.4, \decay, 0.4, \hard, 0.8, \freq, 200);

// 3. Crystal (High Stiffness, Medium Decay, Hard Mallet)
Ndef(\modalMaterial).set(\t_trig, 1, \stiff, 2.2, \decay, 1.5, \hard, 1.0, \freq, 800);