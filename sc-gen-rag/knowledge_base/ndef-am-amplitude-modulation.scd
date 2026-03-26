/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: AMPLITUDE MODULATION (AM)
   Target: Live Coding, JITLib, & Textural Sound Design
   Concepts: Tremolo, Ring Mod, Sidebands, Gating, & Spectral Wobble
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing AM Environment...".postln;

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


// =============================================================================
// 1. TREMOLO (Sub-Audio Rate AM)
// Best for: Pulsing pads, vintage electric pianos, warm movement.
// Math: Carrier * Unipolar LFO (0 to 1)
// =============================================================================

// --- A. The Basic Tremolo ---
(
Ndef(\tremolo, {
	var freq = \freq.kr(220);
	var modFreq = \modFreq.kr(6);   // < 20Hz = Rhythm/Tremolo
	var depth = \depth.kr(0.6);     // 0 = Dry, 1 = Full Silence gaps

	// 1. The Source (Carrier)
	// SelectX allows morphing waveshapes: 0=Sine, 1=Tri, 2=Saw
	var source = SelectX.ar(\shape.kr(0.5), [SinOsc.ar(freq), LFTri.ar(freq), Saw.ar(freq)]);

	// 2. The Modulator (Unipolar)
	// LinLin converts bipolar (-1 to 1) to unipolar range ((1-depth) to 1)
	var mod = SinOsc.kr(modFreq).linlin(-1, 1, 1 - depth, 1);

	source * mod * \amp.kr(0.5) ! 2; // ! 2 for stereo
}).play;
)
Ndef(\master) <<> Ndef(\tremolo);

// LIVE TWEAKS:
// Ndef(\tremolo).xset(\modFreq, 12, \depth, 1.0); // Hard "Helicopter" chop
// Ndef(\tremolo).xset(\modFreq, 3, \depth, 0.3, \shape, 0); // Gentle Sine swell


// --- B. EXPANSION: Stereo Auto-Pan (Offset Phase) ---
(
Ndef(\autoPan, {
	var freq = 150;
	var modFreq = 2;

	// Use an array for phase: [0, pi] creates varying amplitude per ear
	var mod = SinOsc.kr(modFreq, [0, pi]).range(0, 1);

	// A wide Sawtooth pad
	var sig = Saw.ar([freq, freq * 1.01]);

	sig * mod * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\autoPan);


// =============================================================================
// 2. STANDARD AM (Audio Rate)
// Best for: Robotic voices, grit, and preserving the fundamental pitch.
// Math: Carrier * (1 + Modulator) -> Carrier + Sidebands
// =============================================================================

// --- A. The AM Drone ---
(
Ndef(\amStandard, {
	var carFreq = \carFreq.kr(200);
	var modFreq = \modFreq.kr(150); // > 20Hz = Timbre/Sidebands
	var index   = \index.kr(0.5);   // Sideband Intensity

	// Modulator (Audio Rate)
	var mod = SinOsc.ar(modFreq) * index;

	// Carrier * (1 + Mod) preserves the Carrier fundamental
	var sig = SinOsc.ar(carFreq) * (1 + mod);

	Pan2.ar(sig, 0) * \amp.kr(0.4);
}).play;
)
Ndef(\master) <<> Ndef(\amStandard);

// LIVE TWEAKS:
// Ndef(\amStandard).xset(\modFreq, 550, \index, 0.9); // Radio Interference
// Ndef(\amStandard).xset(\modFreq, 205, \carFreq, 200); // Beating Cluster (5Hz diff)


// --- B. EXPANSION: Modular AM (Patching Ndefs) ---
// This allows you to use ANY sound source as a carrier or modulator
(
// 1. Define the Carrier (Source)
Ndef(\mySource, { Saw.ar([60, 61]) * LPF.ar(WhiteNoise.ar(0.1), 1000) });

// 2. Define the Modulator (LFO/Oscillator)
Ndef(\myMod, { LFPulse.ar(10) * SinOsc.ar(50) });

// 3. Define the AM Processor
Ndef(\amProcessor, {
	var car = Ndef(\mySource).ar;
	var mod = Ndef(\myMod).ar;
	car * (1 + mod);
}).play;
)
Ndef(\master) <<> Ndef(\amProcessor);


// =============================================================================
// 3. RING MODULATION (RM)
// Best for: Sci-Fi "Daleks", bells, gongs, inharmonic metallic textures.
// Math: Carrier * Modulator (Pure multiplication, Bipolar) -> Sum & Diff only
// =============================================================================

// --- A. The Sci-Fi Sweep ---
(
Ndef(\ringMod, {
	var carFreq = \carFreq.kr(750);

	// XLine creates a "Power Down" or "Power Up" sweep
	// We use 'impulse' to re-trigger the envelope when we run .set(\t_trig, 1)
	var sweep = XLine.kr(\start.kr(800), \end.kr(20), \dur.kr(2));

	var car = SinOsc.ar(carFreq);
	var mod = SinOsc.ar(sweep);

	(car * mod) ! 2 * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\ringMod);

// Trigger the sweep
// Ndef(\ringMod).stop; Ndef(\ringMod).play; // Quick restart to hear XLine


// --- B. EXPANSION: The Metallic Bell (Static RM) ---
(
Ndef(\bellRM, {
	var fund = 400;
	// RM creates sum (C+M) and difference (C-M) frequencies.
	// Non-integer ratios create bell-like inharmonic spectra.
	var car = SinOsc.ar(fund);
	var mod = SinOsc.ar(fund * 2.414); // Inharmonic Ratio

	var env = EnvGen.kr(Env.perc(0.01, 3.0), doneAction: 0); // Long tail

	(car * mod) * env ! 2 * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\bellRM);


// =============================================================================
// 4. DYNAMIC FLUX (Percussive / Envelope AM)
// Best for: FM-like electric pianos, synthetic plucks.
// Concept: Modulating the *intensity* of AM over time.
// =============================================================================

(
// The Synthesis Graph
Ndef(\amFlux, {
	var freq = \freq.kr(200);
	var gate = \trig.tr; // Trigger input

	// Envelope for Amplitude
	var ampEnv = EnvGen.kr(Env.perc(0.01, 1.0), gate);

	// Envelope for Modulation Index (Timbre)
	// Starts bright (index 2) and fades to pure sine (index 0)
	var modEnv = EnvGen.kr(Env.perc(0.01, 0.2), gate).linlin(0, 1, 0, 2.5);

	var car = SinOsc.ar(freq);
	var mod = SinOsc.ar(freq * 2.0); // Octave up modulator

	// AM Formula + Saturation
	var sig = car * (1 + (mod * modEnv));
	sig = sig.tanh; // Soft clip to glue it together

	sig * ampEnv * 0.4 ! 2;
}).play;

// The Sequencer (Pbind)
Ndef(\amFlux_seq, Pbind(
	\type, \set, // This pattern sets parameters of the Ndef
	\id, Pfunc({ Ndef(\amFlux).nodeID }),
	\args, #[\freq, \trig],

	\dur, 0.25,
	\freq, Pseq([200, 300, 150, 400], inf),
	\trig, 1
)).play;
)
Ndef(\master) <<> Ndef(\amFlux);


// =============================================================================
// 5. RESONANT WOBBLE (Spectral AM)
// Best for: Dubstep basses, acid lines, "talking" textures.
// Concept: Using AM logic (LFO) to drive Filter Cutoff.
// =============================================================================

(
Ndef(\wobble, {
	var freq = \freq.kr(65);
	var width = \width.kr(0.5); // 0.5=Square, 0.1=Pulse

	var modRate = \rate.kr(4);
	var modDepth = \depth.kr(1000);
	var baseCutoff = \cutoff.kr(150);

	// The Wobble LFO
	var lfo = SinOsc.kr(modRate).range(0, modDepth);

	// Source: Pulse wave
	var sig = Pulse.ar(freq, width);

	// Filter: RLPF (Resonant Low Pass)
	sig = RLPF.ar(sig, baseCutoff + lfo, \rq.kr(0.2));

	// Makeup gain for high resonance
	sig = sig * 2.0;

	sig ! 2 * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\wobble);

// LIVE TWEAKS:
// Ndef(\wobble).xset(\rate, 8, \depth, 2500, \rq, 0.1); // Aggressive Acid
// Ndef(\wobble).xset(\rate, 1, \depth, 500, \width, 0.1); // Hollow Pulse


// =============================================================================
// 6. EXPANSION: LOGIC GATING (The Trance Gate)
// Best for: Rhythmic chords, converting pads into beats.
// Concept: Using a Pulse LFO as a hard on/off switch.
// =============================================================================

(
Ndef(\tranceGate, {
	var chord = Saw.ar([60, 64, 67, 71].midicps).sum; // Major 7th Chord

	// LFPulse creates a square wave (0 or 1)
	// width: 0.5 = normal square, 0.1 = short stabs
	var gate = LFPulse.kr(\rate.kr(8), 0, \width.kr(0.3));

	// Lag smooths the sharp edges of the square wave to prevent clicking
	var env = gate.lag(0.02);

	chord * env * 0.2 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\tranceGate);

// Polyrhythmic Gating
// Use separate gates for Left and Right channels
(
Ndef(\polyGate, {
	var sound = Blip.ar(100, 20);
	var gateL = LFPulse.kr(6, 0, 0.2); // 6 Hz
	var gateR = LFPulse.kr(4, 0, 0.2); // 4 Hz (Polyrhythm)

	[sound * gateL, sound * gateR] * 0.2;
}).play;
)
Ndef(\master) <<> Ndef(\polyGate);