/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: SUBTRACTIVE SYNTHESIS
   Target: Live Coding, JITLib, & Timbral Sculpting
   Concepts: Filters (LPF/HPF/BPF), Resonance, Envelope Modulation, Acid
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Subtractive Environment...".postln;

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
// 1. THE BASICS: FILTER SWEEP (LFO)
// Best for: Pads, slow-evolving textures, "breathing" sounds.
// =============================================================================

(
Ndef(\filterSweep, {
	var freq = \freq.kr(110);
	var rate = \rate.kr(0.2); // LFO Speed

	// 1. The Source (Rich Harmonics needed for Subtractive)
	// Sawtooth waves are ideal because they contain ALL harmonics.
	var sig = Saw.ar([freq, freq * 1.01]);

	// 2. The Modulator (LFO)
	// We map the LFO to a frequency range (e.g. 500Hz to 5000Hz)
	var cutoff = SinOsc.kr(rate).exprange(500, 5000);

	// 3. The Filter (LPF - Low Pass Filter)
	// Removes high frequencies based on the cutoff
	sig = LPF.ar(sig, cutoff);

	sig * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\filterSweep);

// LIVE TWEAK:
Ndef(\filterSweep).xset(\rate, 4, \freq, 60); // Fast wobble bass


// =============================================================================
// 2. RESONANT ACID (Envelope Modulation)
// Best for: TB-303 style leads, squelchy basses, techno zaps.
// Concept: Using a fast envelope to "whip" the filter cutoff down.
// =============================================================================

(
Ndef(\acidBass).fadeTime = 0;
Ndef(\acidBass, {
	var t_trig = \t_trig.tr(1);
	var freq = \freq.kr(55);
	var res = \res.kr(0.2); // Resonance (Lower is more resonant in RLPF usually 0.1-0.5)

	// 1. Filter Envelope (The "Whip")
	// Moves from 0 to 1 very quickly, then decays
	var env = EnvGen.kr(Env.perc(0.001, 0.3), t_trig);

	// 2. Map Envelope to Frequency
	// Base Cutoff (100Hz) + (Envelope * Amount (4000Hz))
	var cutoff = 100 + (env * 4000);

	// 3. Source: Pulse Wave (Square)
	// Pulse width 0.5 is standard square, varies for timbre
	var sig = Pulse.ar(freq, 0.5);

	// Amp Envelope
	var ampEnv = EnvGen.kr(Env.perc(0.01, 0.4), t_trig);

	// 4. Filter: RLPF (Resonant Low Pass)
	// Note: In RLPF, 'rq' is bandwidth. Lower rq = Higher Resonance.
	sig = RLPF.ar(sig, cutoff, res);

	// Makeup gain for high resonance
	sig = (sig * 2).tanh;

	sig * ampEnv * 0.5 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\acidBass);

// LIVE SEQUENCER (Acid Line):
(
Ndef(\acidSeq, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\acidBass).nodeID }),
	\args, #[\freq, \t_trig],
	\dur, 0.25,
	\freq, Pseq([55, 55, 110, 55, 55, 220, 110, 55], inf),
	\t_trig, 1,
	\res, Pseq([0.2, 0.1, 0.05], inf) // Varying resonance
)).play;
)


// =============================================================================
// 3. THE "SUPER-SAW" (Detuned Stacks)
// Best for: Trance leads, huge pads, thick walls of sound.
// Concept: Stacking multiple detuned saw waves to create "chorus" effect.
// =============================================================================

(
Ndef(\superSaw, {
	var freq = \freq.kr(110);
	var detune = \detune.kr(0.02); // 2% detune

	// 1. Create an array of 5 frequencies centered around 'freq'
	var freqs = freq * [1-detune, 1-(detune/2), 1, 1+(detune/2), 1+detune];

	// 2. Source: 5 Saw waves summed together
	var sig = Splay.ar(Saw.ar(freqs));

	// 3. Filter: Low Pass to tame the buzz
	sig = LPF.ar(sig, 6000);

	sig * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\superSaw);

// LIVE TWEAK:
Ndef(\superSaw).xset(\detune, 0.1); // Huge, messy detune


// =============================================================================
// 4. BANDPASS SWEEP (Formants/Vowels)
// Best for: "Talking" basses, vocal-like textures.
// Concept: Sweeping a narrow band of frequencies (BPF).
// =============================================================================

(
Ndef(\vowelBass, {
	var freq = \freq.kr(80);
	var rate = \rate.kr(0.5);

	// 1. Source: Rich Pulse wave
	var sig = Pulse.ar([freq, freq * 1.01], 0.2);

	// 2. Modulator: Slow Triangle LFO
	var sweep = LFTri.kr(rate).exprange(200, 2000);

	// 3. Filter: BPF (Band Pass Filter)
	// rq = 0.2 (Narrow band -> Vocal quality)
	sig = BPF.ar(sig, sweep, 0.2);

	// High gain needed after narrow BPF
	sig = (sig * 5).tanh;

	sig * 0.4;
}).play;
)
Ndef(\master) <<> Ndef(\vowelBass);


// =============================================================================
// 5. NOISE SCULPTING (Subtractive Percussion)
// Best for: Hi-hats, snares, wind, ocean sounds.
// Concept: Filtering White/Pink Noise.
// =============================================================================

(
Ndef(\noisePerc).fadeTime = 0;
Ndef(\noisePerc, {
	var t_trig = \t_trig.tr(1);

	// FIX 1: Renamed 'type' to 'filtType' to avoid conflict
	var mode = \filtType.kr(0);

	var env = EnvGen.kr(Env.perc(0.001, 0.2), t_trig);
	var sig = WhiteNoise.ar();

	// Select filter type
	sig = Select.ar(mode, [
		HPF.ar(sig, 8000),       // 0: Hat
		BPF.ar(sig, 2000, 0.5),  // 1: Snare
		LPF.ar(sig, 300)         // 2: Kick
	]);

	sig * env * 0.5 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\noisePerc);

// LIVE SEQUENCE:
(
Ndef(\percSeq, Pbind(
	// FIX 2: This command must remain \set
	\type, \set,

	// Target the noisePerc Ndef
	\id, Pfunc({ Ndef(\noisePerc).nodeID }),

	// FIX 3: Control the NEW argument name
	\filtType, Pseq([2, 0, 1, 0], inf),

	\t_trig, 1,
	\dur, 0.25,
	\args, #[\t_trig, \filtType] // Ensure arguments are sent
)).play;
)


// =============================================================================
// 6. GATED PADS (Rhythmic Subtractive)
// Best for: Trance gates, rhythmic chord pulses.
// Concept: Modulating the Amplitude (VCA) with a Pulse LFO.
// =============================================================================

(
Ndef(\gatedPad, {
	var freq = \freq.kr(110);
	var gateRate = \rate.kr(4); // 16th notes at 120bpm = 8Hz

	// 1. Source: Lush Chord (SuperSaw)
	var chord = Splay.ar(Saw.ar(freq * [1, 1.2, 1.5])); // Major Triad

	// 2. The Gate (Square LFO)
	// width: 0.5 (normal) to 0.1 (staccato)
	var gate = LFPulse.kr(gateRate, 0, 0.4);

	// 3. Filter: Soft Low Pass
	chord = LPF.ar(chord, 2000);

	chord * gate * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\gatedPad);

// LIVE TWEAK:
Ndef(\gatedPad).xset(\rate, 8, \freq, 220); // Double time, octave up