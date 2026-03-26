/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: FREQUENCY MODULATION (FM)
   Target: Live Coding, JITLib, & Timbral Design
   Concepts: Exponential Sweeps, Operator Stacks, Feedback, & Chaos
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing FM Environment...".postln;

	// --- FIX: Force ProxySpace Initialization ---
	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	// Defaults for smooth morphing
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
// 1. SIMPLE FM & EXPONENTIAL SWEEPS
// Best for: "Laser" zaps, kicks, and sci-fi sirens.
// Math: Carrier + (Modulator * Index)
// =============================================================================

// --- A. The "Zap" (Percussive One-Shot) ---
(
Ndef(\fmZap).fadeTime = 0; // Immediate attack
Ndef(\fmZap, {
	var freq = \freq.kr(60);
	var modIdx = \modIdx.kr(500); // How "hard" the zap is
	var dur = \dur.kr(0.3);
	var t_trig = \t_trig.tr(1);   // Trigger input

	// Frequency Envelope (Sweep)
	// XLine isn't retriggerable easily in Ndef, so we use EnvGen
	var modHz = EnvGen.kr(Env([400, 10], [dur], \exp), t_trig);
	var ampEnv = EnvGen.kr(Env.perc(0.001, dur), t_trig);

	// The FM Math
	var mod = SinOsc.ar(modHz) * modIdx;
	var car = SinOsc.ar(freq + mod);

	car * ampEnv * 0.5 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\fmZap);

// LIVE RE-TRIGGERING:
// Run this line repeatedly to fire the sound
Ndef(\fmZap).set(\t_trig, 1, \modIdx, 800, \dur, 0.2);


// --- B. The "Siren" (Continuous LFO FM) ---
(
Ndef(\fmSiren, {
	var centerFreq = 600;
	var modRate = 4; // 4 Hz wobble

	// Modulator is an LFO
	var mod = SinOsc.ar(modRate) * 200; // Swings +/- 200Hz

	var car = SinOsc.ar(centerFreq + mod);

	// Add a rhythmic panner
	Pan2.ar(car, SinOsc.kr(0.5)) * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\fmSiren);


// =============================================================================
// 2. SERIES FM (The Stack)
// Best for: Growls, distorted basses, and complex evolving textures.
// Algorithm: Modulator 2 -> Modulator 1 -> Carrier
// =============================================================================

(
Ndef(\fmStack, {
	var freq = \freq.kr(110);

	// Ratio = Multiplier of the fundamental frequency
	// Index = Brightness/Distortion amount
	var m2Ratio = \m2Ratio.kr(4.0);
	var m2Idx   = \m2Idx.kr(3.0);

	var m1Ratio = \m1Ratio.kr(1.0);
	var m1Idx   = \m1Idx.kr(5.0); // High index = Growl

	// --- STAGE 3: Modulator 2 (Top of stack) ---
	// We multiply index by freq to keep timbre consistent across keys
	var mod2 = SinOsc.ar(freq * m2Ratio) * (freq * m2Idx);

	// --- STAGE 2: Modulator 1 (Modulated by M2) ---
	var mod1 = SinOsc.ar((freq * m1Ratio) + mod2) * (freq * m1Idx);

	// --- STAGE 1: Carrier (Modulated by M1) ---
	var car = SinOsc.ar(freq + mod1);

	car * \amp.kr(0.4) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\fmStack);

// LIVE TWEAKS:
Ndef(\fmStack).xset(\m1Idx, 10, \m2Ratio, 0.5); // Deep Dubstep Growl
// Ndef(\fmStack).xset(\freq, 800, \m1Idx, 1, \m2Idx, 20); // Broken Radio


// =============================================================================
// 3. PARALLEL FM (The Bell)
// Best for: Organs, Bells, Metallic textures with distinct partials.
// Algorithm: (Mod1 + Mod2) -> Carrier
// =============================================================================

(
Ndef(\fmBell).fadeTime = 0; // Percussive sounds need 0 fade
Ndef(\fmBell, {
	var freq = \freq.kr(440);
	var amp = \amp.kr(0.5);
	var t_trig = \t_trig.tr(1); // Trigger for re-striking

	// 1. INTENSITY ENVELOPE (How loud the metal "clangs")
	// This controls the Modulation Index.
	// It decays FAST (0.2s), leaving only the pure sine wave fundamental behind.
	var indexEnv = EnvGen.kr(Env.perc(0.001, 0.2), t_trig);

	// 2. AMPLITUDE ENVELOPE (How long it rings)
	// This decays for 0.5s.
	var ampEnv = EnvGen.kr(Env.perc(0.001, 0.5), t_trig);

	// 3. THE RATIOS (The Metallic Recipe)
	// Ratio 1:2 = Octave (Body)
	// Ratio 1:3.5 = Non-integer (The "Metal" sound)
	var mod1 = SinOsc.ar(freq * 2) * (freq * 2 * indexEnv); // Dynamic brightness!
	var mod2 = SinOsc.ar(freq * 3.5) * (freq * 0.5 * indexEnv);

	// Carrier
	var car = SinOsc.ar(freq + mod1 + mod2);

	// Stereo Spreading (Pan based on pitch for realism)
	Pan2.ar(car, LinLin.kr(freq, 200, 800, -0.5, 0.5)) * ampEnv * amp;
}).play;
)
Ndef(\master) <<> Ndef(\fmBell);

// Expansion: Add a wrapper pattern to play it as a sequence
(
Ndef(\bellSeq, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\fmBell).nodeID }),

	// FIX 1: Add \t_trig to the list of arguments we are sending
	\args, #[\freq, \t_trig],

	\dur, Pseq([0.25, 0.25, 0.5], inf),
	\freq, Pseq([200, 300, 400, 250], inf) * 2,

	// FIX 2: Send the trigger value (1) on every event
	\t_trig, 1
)).play;
)


// =============================================================================
// 4. FEEDBACK FM
// Best for: White noise bursts, guitar feedback, abrasive textures.
// Technique: Using SinOscFB (Sine with internal feedback)
// =============================================================================

(
Ndef(\fmFeedback, {
	var freq = \freq.kr(110);
	var fb = \fb.kr(1.5); // 0 = Sine, 1 = Saw-ish, >2 = Noise

	// LFO to modulate the feedback amount
	var fbMod = SinOsc.kr(0.2).range(0.5, fb);

	// SinOscFB is the most stable way to do feedback in SC
	var sig = SinOscFB.ar(freq, fbMod);

	sig * 0.3 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\fmFeedback);

// LIVE TWEAK: Push it into noise
Ndef(\fmFeedback).xset(\fb, 10);


// =============================================================================
// 5. PULSE WIDTH MODULATION (PWM)
// Best for: Retro strings, "Commodore 64" leads.
// =============================================================================

// --- Stereo Detuned PWM Pad ---
(
Ndef(\pwmPad, {
	var freq = \freq.kr(110);
	var rate = \rate.kr(0.5); // Slow sweep

	// Create two different LFOs for Left and Right ear
	var widthL = SinOsc.kr(rate).range(0.1, 0.5);
	var widthR = SinOsc.kr(rate * 1.1).range(0.5, 0.9);

	// VarSaw(freq, phase, width)
	var oscL = VarSaw.ar(freq, 0, widthL);
	var oscR = VarSaw.ar(freq * 1.01, 0, widthR); // Slight detune

	[oscL, oscR] * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\pwmPad);


// =============================================================================
// 6. CHAOTIC / RANDOM FM
// Best for: Glitch, computer data, R2D2 effects.
// Technique: Using LFNoise or Chaos generators as Modulators.
// =============================================================================

(
Ndef(\glitchFM, {
	var carrierFreq = \freq.kr(400);

	// Sample & Hold Modulator (Stepped random)
	var rate = \rate.kr(12); // Steps per second
	var randFreq = LFNoise0.kr(rate).exprange(100, 2000);

	// Modulator
	var mod = SinOsc.ar(randFreq) * 500;

	var car = SinOsc.ar(carrierFreq + mod);

	car * 0.3 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\glitchFM);

// LIVE TWEAK: Go into audio rate chaos
// Ndef(\glitchFM).xset(\rate, 500);