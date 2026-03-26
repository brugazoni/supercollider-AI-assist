/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: NOISE SYNTHESIS
   Target: Live Coding, JITLib, & Sound Design
   Concepts: Subtractive Filtering, Particles (Dust), Chaos (Crackle), & Tuned Noise
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Noise Environment...".postln;

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
// 1. SUBTRACTIVE NOISE (The "Colored" Canvas)
// Best for: Basic shaping. White=All Freqs, Pink=Balanced, Brown=Low Rumble.
// =============================================================================

(
Ndef(\noiseColor, {
	var color = \color.kr(0); // 0=White, 1=Pink, 2=Brown
	var cutoff = \cutoff.kr(1000);
	var rq = \rq.kr(0.5); // Resonance (0.1 = whistling, 1.0 = flat)

	// 1. Source Selection
	// SelectX allows smooth crossfading between noise types
	// Note: We duplicate the source { ... } ! 2 to get STEREO decorrelated noise (wide)
	var noise = {
		SelectX.ar(color, [WhiteNoise.ar, PinkNoise.ar, BrownNoise.ar])
	} ! 2;

	// 2. Filter
	// RLPF adds character at the cutoff point
	var sig = RLPF.ar(noise, cutoff, rq);

	sig * \amp.kr(0.3);
}).play;
)
Ndef(\master) <<> Ndef(\noiseColor);

// LIVE TWEAKS:
Ndef(\noiseColor).xset(\color, 2, \cutoff, 200); // Deep Rumble (Brown)
Ndef(\noiseColor).xset(\color, 0, \cutoff, 8000, \rq, 0.9); // Air/Hiss (White)


// =============================================================================
// 2. ENVIRONMENTAL TEXTURES (Wind & Ocean)
// Best for: Background ambience, evolving drones.
// Concept: Modulating filter cutoff with slow random LFOs.
// =============================================================================

(
Ndef(\windGust, {
	var baseCutoff = \cutoff.kr(400);
	var intensity = \force.kr(0.5); // 0=Breeze, 1=Storm

	// 1. Source: Pink Noise is best for nature sounds
	var src = { PinkNoise.ar } ! 2;

	// 2. Modulation: LFNoise1 (Random Ramp)
	// We create separate modulators for L and R for stereo movement
	var mod = { LFNoise1.kr(0.2).exprange(0.5, 2.0) } ! 2;

	// 3. Filter: Low Pass that moves randomly
	// As intensity increases, the filter opens wider
	var sig = LPF.ar(src, baseCutoff * mod * (1 + (intensity * 4)));

	// 4. Amplitude Modulation (Volume swells)
	sig = sig * { LFNoise1.kr(0.1).range(0.2, 1.0) } ! 2;

	sig * 0.5;
}).play;
)
Ndef(\master) <<> Ndef(\windGust);

// LIVE TWEAKS:
Ndef(\windGust).xset(\force, 0.1); // Gentle Breeze
Ndef(\windGust).xset(\force, 1.0, \cutoff, 800); // Blizzard


// =============================================================================
// 3. PARTICLE NOISE (Dust & Crackle)
// Best for: Geiger counters, vinyl crackle, sparks, "glitch" textures.
// =============================================================================

(
Ndef(\particles, {
	var density = \dens.kr(10); // Impacts per second
	var chaos = \chaos.kr(1.5); // For Crackle: 1.0=Quiet, 2.0=Loud/Chaotic

	// A. Dust: Random impulses (Sparks/Geiger)
	var dust = Dust.ar(density ! 2);

	// B. Crackle: Chaotic fractal noise (Vinyl/Fire)
	var crackle = Crackle.ar(chaos ! 2);

	// Crossfade between them
	var mix = SelectX.ar(\mix.kr(0), [dust, crackle]);

	mix * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\particles);

// LIVE TWEAKS:
Ndef(\particles).xset(\mix, 0, \dens, 50); // Heavy Geiger Counter
Ndef(\particles).xset(\mix, 1, \chaos, 1.9); // Broken Cable / Fire


// =============================================================================
// 4. TUNED NOISE (The "Ghostly" Resonator)
// Best for: Sci-fi scanners, ethereal chords, wind turning into flute.
// Concept: Using a filter with extremely high resonance (low RQ) creates a pitch.
// =============================================================================

(
Ndef(\tunedNoise, {
	var freq = \freq.kr(200);
	var width = \width.kr(0.005); // Extremely narrow band = Pure tone

	var noise = WhiteNoise.ar(0.5 ! 2);

	// Resonz is a highly efficient resonant filter
	// Arguments: input, freq, bwr (bandwidth ratio)
	var sig = Resonz.ar(noise, freq, width);

	// Resonz loses volume as it gets narrower, so we boost it massive amounts
	(sig * 50).tanh * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\tunedNoise);

// LIVE CHORD (Using a Pattern to "play" the noise filter):
(
Ndef(\ghostChord, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\tunedNoise).nodeID }),
	\args, #[\freq],
	\dur, 2,
	// Random Pentatonic Chord
	\freq, Pxrand([200, 300, 400, 500, 600, 800], inf),
	\width, 0.002 // Make it whistle
)).play;
)


// =============================================================================
// 5. SAMPLE & HOLD NOISE (Computer Data)
// Best for: R2D2 effects, retro computer processing sounds.
// Concept: LFNoise0 holds a random value for a set time (Steps).
// =============================================================================

(
Ndef(\dataStream, {
	var rate = \rate.kr(12); // Speed of data calculation

	// LFNoise0 = Step Noise (jumps to new value instantly)
	// We map it to frequency
	var freq = LFNoise0.kr(rate).exprange(200, 2000);

	// We use the noise to drive a simple Sine wave
	var sig = SinOsc.ar(freq);

	// Add bitcrushing for extra digital feel
	sig = Decimator.ar(sig, 44100, 4);

	sig * 0.2 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\dataStream);

// LIVE TWEAKS:
Ndef(\dataStream).xset(\rate, 80); // Fast data transfer
Ndef(\dataStream).xset(\rate, 4); // Slow calculation


// =============================================================================
// 6. PERCUSSIVE NOISE (Snares & Hats)
// Best for: Drum synthesis.
// =============================================================================

(
Ndef(\noiseSnare).fadeTime = 0;
Ndef(\noiseSnare, {
	var t_trig = \t_trig.tr(1);

	// 1. Envelope: Fast Attack, Short Decay
	var env = EnvGen.kr(Env.perc(0.001, 0.2), t_trig);

	// 2. Source: White Noise
	var noise = WhiteNoise.ar();

	// 3. Filter: Band Pass for the "body" of the snare (approx 2000Hz)
	var sig = BPF.ar(noise, 2000, 0.5);

	// 4. Mix dry noise back in for "wires" (high frequency)
	sig = sig + (HPF.ar(noise, 5000) * 0.5);

	sig * env * 0.5 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\noiseSnare);

// LIVE STRIKE:
Ndef(\noiseSnare).set(\t_trig, 1);