/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: WAVETABLE SYNTHESIS
   Target: Live Coding, JITLib, & Morphing Timbres
   Concepts: Osc, VOsc (Morphing), Shaper (Distortion), & Rhythmic Scanning
   =============================================================================
*/
// =============================================================================
// 0. SETUP & BUFFER GENERATION (Run this block first!)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Generatings Wavetables...".postln;

	// --- 1. Environment Setup ---
	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };
	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;
	NdefMixer(s);

	// --- 2. Buffer Allocation ---

	// A. Single Cycle Buffer (Complex Sine)
	// We use 'wavetable' format (special SC format for interpolating oscillators)
	~wt_single = Buffer.alloc(s, 2048, 1);
	~wt_single.loadCollection(
		Signal.sineFill(1024, [1, 0.5, 0.2, 0.1, 0.5, 0.2]).asWavetable
	);

	// B. Morphing Bank (4 Consecutive Buffers)
	// We allocate 4 buffers with IDs side-by-side for VOsc to sweep through
	~wt_morph = Buffer.allocConsecutive(4, s, 4096, 1);

	// Define 4 distinct shapes
	~shapes = [
		Signal.sineFill(2048, [1]), // Sine
		Signal.sineFill(2048, 1 / (1, 3..50)), // Triangle-ish
		Signal.sineFill(2048, 1 / (1..50)), // Saw-ish
		Signal.sineFill(2048, Array.exprand(20, 0.01, 1)) // Random Metal
	];

	// Load them into the consecutive buffers
	~wt_morph.do({ |buf, i| buf.loadCollection(~shapes[i].asWavetable) });

	// C. Waveshaping Transfer Function (S-Curve Distortion)
	~wt_shape = Buffer.alloc(s, 2048, 1);
	~sig_shape = Env([-1, 0, 1], [1, 1], [4, -4]).asSignal(1024);
	~wt_shape.loadCollection(~sig_shape.asWavetable); // Wavetable format for Shaper

	// --- 3. Master FX ---
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in| Limiter.ar(LeakDC.ar(in), 0.95) });

	"Wavetables Ready.".postln;
});
)


// =============================================================================
// 1. SINGLE CYCLE PLAYBACK (Osc)
// Best for: Efficient, specific timbres (Gameboy, Chiptune, Organ).
// Note: Osc is much more CPU efficient than playing a sample file.
// =============================================================================

(
Ndef(\wtStatic, {
	var freq = \freq.kr(110);
	var buf  = \buf.kr(~wt_single); // Reference the buffer we created

	// Osc reads the wavetable format
	var sig = Osc.ar(buf, freq);

	// Simple lowpass to tame aliases
	sig = LPF.ar(sig, 8000);

	sig * 0.4 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\wtStatic);

// LIVE SWAP:
Ndef(\wtStatic).xset(\freq, 55);
Ndef(\wtStatic).xset(\buf, ~wt_morph[3]); // Swap to the "Random Metal" buffer


// =============================================================================
// 2. VECTOR MORPHING (VOsc)
// Best for: Evolving pads, dubstep "wobble" basses, PPG sweeps.
// Concept: Interpolating between multiple buffers in real-time.
// =============================================================================

(
Ndef(\wtMorph, {
	var freq = \freq.kr(55);
	var bufBase = \bufBase.kr(~wt_morph[0].bufnum); // Start at first buffer
	var numBufs = 4; // We have 4 buffers in the bank

	// Position Control (0.0 to 3.0)
	// We map an LFO to sweep through the buffers
	var lfo = SinOsc.kr(\rate.kr(0.5)).range(0, numBufs - 1.01);

	// VOsc(bufferIndex, freq)
	// bufferIndex can be a float (e.g., 1.5 mixes buffer 1 and buffer 2)
	var sig = VOsc.ar(bufBase + lfo, freq);

	// Add some stereo width by detuning a second voice
	var sig2 = VOsc.ar(bufBase + lfo, freq * 1.01);

	[sig, sig2] * 0.3;
}).play;
)
Ndef(\master) <<> Ndef(\wtMorph);

// LIVE TWEAK:
Ndef(\wtMorph).xset(\rate, 8); // Fast wobble
Ndef(\wtMorph).xset(\rate, 0.1, \freq, 220); // Slow evolving pad


// =============================================================================
// 3. WAVESHAPING (Distortion / Saturator)
// Best for: Adding complex harmonics to simple sounds (Sine -> Complex).
// Math: Output = TransferFunction(Input)
// =============================================================================

(
Ndef(\shaper, {
	var freq = \freq.kr(110);
	var drive = \drive.kr(0.5); // 0..1 = Clean, >1 = Distorted
	var buf = \buf.kr(~wt_shape);

	// 1. Pure Sine Input
	var input = SinOsc.ar(freq);

	// 2. Shaper
	// The 'drive' pushes the sine wave into the nonlinear part of the curve
	var sig = Shaper.ar(buf, input * drive);

	// 3. Gain Compensation
	// As we drive harder, we lower volume to keep it sane
	sig = sig * (1 / drive.max(1).sqrt);

	sig * 0.4 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\shaper);

// LIVE TWEAK:
Ndef(\shaper).xset(\drive, 0.2); // Clean Sine
Ndef(\shaper).xset(\drive, 5.0); // Hard Square-like Distortion


// =============================================================================
// 4. EXPANSION: RHYTHMIC TABLE JUMPING
// Best for: Glitchy sequences, robotic arpeggios.
// Concept: Using a Step Sequencer (Demand) to jump buffer indices instantly.
// =============================================================================

(
Ndef(\wtGlitch, {
	var freq = \freq.kr(110);
	var bufBase = \bufBase.kr(~wt_morph[0].bufnum);
	var trig = Impulse.kr(8); // 8Hz Clock

	// Demand Sequencer
	// Randomly picks a buffer index (0, 1, 2, or 3) on every trigger
	var bufIndex = Demand.kr(trig, 0, Dseq([0, 2, 1, 3], inf));
	// Or use Drand for chaos:
	// var bufIndex = Demand.kr(trig, 0, Drand([0, 1, 2, 3], inf));

	// We use VOsc, but the index jumps cleanly instead of morphing
	var sig = VOsc.ar(bufBase + bufIndex, freq);

	// Add a rhythmic envelope
	var env = Decay.kr(trig, 0.2);

	sig * env * 0.3 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\wtGlitch);


// =============================================================================
// 5. EXPANSION: FM-WAVETABLE HYBRID
// Best for: Extremely rich, metallic, or aggressive textures.
// Concept: Using a Wavetable Oscillator as the Modulator for FM.
// =============================================================================

(
Ndef(\wtFM, {
	var freq = \freq.kr(80);
	var modIdx = \modIdx.kr(200);
	var bufBase = \bufBase.kr(~wt_morph[0].bufnum);

	// 1. Modulator: A Morphing Wavetable
	// Sweeps through the tables slowly
	var modPos = SinOsc.kr(0.1).range(0, 3);
	var mod = VOsc.ar(bufBase + modPos, freq * 2); // Ratio 2:1

	// 2. Carrier: Simple Sine (or another VOsc!)
	var car = SinOsc.ar(freq + (mod * modIdx));

	car * 0.4 ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\wtFM);

// LIVE TWEAK:
Ndef(\wtFM).xset(\modIdx, 1000); // Heavy distortion
Ndef(\wtFM).xset(\freq, 40); // Deep Growl


// =============================================================================
// 6. CLEANUP
// =============================================================================

Ndef(\master).fadeTime = 5;
Ndef(\master, { 0 });
Ndef.clear(5);
// To free buffers:
~wt_single.free; ~wt_morph.do(_.free); ~wt_shape.free;