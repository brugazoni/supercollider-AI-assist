/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: ADDITIVE SYNTHESIS
   Adapted for: Live Coding & JITLib (Ndef)
   Target: Stability, Modularity, and "Hot-Swapping"
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run this block first, once)
// =============================================================================
(
// --- Server Options for Heavy Synthesis ---
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;
s.options.maxNodes = 1024 * 32;

s.waitForBoot({
	"Server Booted. Initializing Environment...".postln;
	// --- Visual Mixer ---
	NdefMixer(s);

	// --- Master FX Chain (Safety) ---
	// All sound is routed through here to prevent volume spikes
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = Limiter.ar(in, 0.95, 0.01);
		LeakDC.ar(sig);
	});
});
)


// =============================================================================
// 1. HARMONIC ADDITIVE SYNTHESIS
// concept: Stacking sine waves at integer multiples of a fundamental freq.
// =============================================================================

// --- A. The Manual Stack (Drone) ---
(
Ndef(\addHarmonic, {
	var fund = \fund.kr(110); // Fundamental freq
	var amp  = \amp.kr(0.3);

	// Define Partial Ratios (1=fund, 2=octave, 3=fifth, etc.)
	// LIVE TIP: Change these numbers and re-run to morph the timbre
	var ratios = [1, 2, 3, 4, 5];

	// Define Amplitudes for each partial
	var amps   = [0.5, 0.3, 0.2, 0.1, 0.05];

	// Sum the oscillators
	var sig = SinOsc.ar(fund * ratios, 0, amps).sum;

	// Splay spreads the partials for a wide stereo image
	Splay.ar(sig) * amp;
}).play(out: 0); // Play to hardware output 0
)

// Connect to Master Safety Chain (Recommended)
Ndef(\master) <<> Ndef(\addHarmonic);

// Live Modulation
Ndef(\addHarmonic).set(\fund, 150);
Ndef(\addHarmonic).xset(\fund, 80); // xset = crossfade to new value


// --- B. The Pattern Sequencer (Bell/Pluck) ---
// Note: We define a SynthDef for granular control, then sequence it with Ndef
(
SynthDef(\sinAddDef, { |out=0, freq=200, amp=0.1, pan=0, gate=1, rel=1|
	var sig, env;
	// 'r' argument allows us to sequence the TIMBRE per note
	var r = \r.kr([1, 2, 3, 4]);
	var a = \a.kr([0.2, 0.2, 0.2, 0.2]);

	env = EnvGen.kr(Env.perc(0.01, rel), gate, doneAction: 2);
	sig = SinOsc.ar(freq * r, 0, a).sum;
	OffsetOut.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

(
Ndef(\addPattern).fadeTime = 0; // Percussive sounds need instant transition
Ndef(\addPattern, Pbind(
	\instrument, \sinAddDef,
	\dur, Pseq([0.25, 0.25, 0.5], inf),
	\freq, Pseq([200, 300, 450, 150], inf),

	// Sequence the Harmonic Structure:
	// 1. Harmonic (Organ-like) -> 2. Inharmonic (Bell-like)
	\r, Pseq([
		[[1, 2, 3, 4]],
		[[1, 2.7, 5.1, 7.3]]
	], inf),

	\rel, 2.5,
	\amp, 0.3
)).play;
)
Ndef(\master) <<> Ndef(\addPattern);


// =============================================================================
// 2. ITERATIVE ADDITIVE SYNTHESIS
// concept: Algorithmic generation of partials (e.g. "spectral tilt").
// =============================================================================

(
Ndef(\addIterative, {
	var n = 16; // Number of partials (Fixed at definition)
	var fund = \fund.kr(100);
	var ratio = \ratio.kr(1.5); // 1.0 = Harmonic, 1.5 = Inharmonic
	var dec = \decay.kr(1.3);   // How fast high freqs fade out

	// Iteratively build the synthesis graph
	var sig = Mix.fill(n, { |i|
		var freq = fund * (1 + (i * ratio));
		// Amplitude follows an exponential decay curve
		var amp = 1.0 / (dec.pow(i));
		SinOsc.ar(freq) * amp;
	});

	// Spread and add subtle saturation
	Splay.ar(sig).tanh * \amp.kr(0.4);
}).play;
)
Ndef(\master) <<> Ndef(\addIterative);

// LIVE TIP: Create a separate LFO Ndef and map it to 'ratio'
// This makes the spectrum "breathe" or "stretch"
(
Ndef(\lfoBreath, { LFNoise1.kr(0.2).range(1.0, 2.1) });
)
Ndef(\addIterative).map(\ratio, Ndef(\lfoBreath));


// =============================================================================
// 3. BAND-LIMITED IMPULSE (BLIP)
// concept: Buzzing, retro sounds. Efficient way to stack many harmonics.
// =============================================================================

(
Ndef(\addBlip, {
	var fund = \fund.kr(60);
	var numHarm = \harm.kr(20); // Number of harmonics

	// Stereo Blip with slight detune [1, 1.01]
	var sig = Blip.ar(fund * [1, 1.01], numHarm);

	// Low Pass Filter that tracks the highest harmonic to remove aliasing/fizz
	sig = LPF.ar(sig, (fund * numHarm).clip(100, 18000));

	sig * \amp.kr(0.4);
}).play;
)
Ndef(\master) <<> Ndef(\addBlip);

// Modular LFO for Harmonic Sweep
(
Ndef(\lfoSweep, {
	// Sweep from 1 to 40 harmonics over time
	LFTri.kr(0.1).exprange(1, 40)
});
)
// Map the LFO to the Blip's harmonic count
Ndef(\addBlip).map(\harm, Ndef(\lfoSweep));


// =============================================================================
// 4. KLANG (Fixed & Dynamic Banks)
// concept: Resonant metals, frozen chords, or shifting glass textures.
// =============================================================================

// --- A. Klang (Static / Baked Randomness) ---
(
Ndef(\addKlang, {
	// Re-running this block generates a NEW random timbre
	var freqs = Array.exprand(12, 200, 4000).sort;
	var amps = Array.exprand(12, 0.01, 0.1).sort.reverse;
	var phases = Array.rand(12, 0, 2pi);

	// `[] syntax creates a Ref, required by Klang
	var sig = Klang.ar(`[freqs, amps, phases], 1, 0);

	Splay.ar(sig) * 0.5;
}).play;
)
Ndef(\master) <<> Ndef(\addKlang);


// --- B. DynKlang (Dynamic / Modulatable) ---
(
Ndef(\addDynKlang, {
	var n = 8;
	var fund = \fund.kr(150);

	// Arrays of Modulators (one LFO per partial)
	var freqMods = { LFNoise1.kr(0.5).exprange(0.98, 1.02) } ! n;

	// Fibonacci Series for base frequencies (Golden Ratio-ish)
	var baseFreqs = Array.fib(n, fund, fund);

	var sig = DynKlang.ar(`[
		baseFreqs * freqMods, // Modulate freq live
		nil, // Default amps
		nil  // Default phases
	]);

	Splay.ar(sig) * 0.2;
}).play;
)
Ndef(\master) <<> Ndef(\addDynKlang);

// Add an Insert FX (Reverb) to the DynKlang
// Slot 10 is arbitrary (processed after source [0])
Ndef(\addDynKlang)[10] = \filter -> { |in| FreeVerb.ar(in, 0.5, 0.9, 0.2) };


// =============================================================================
// 5. CLEANUP / PANIC
// =============================================================================

// Fade everything out over 5 seconds
Ndef(\master).fadeTime = 5;
Ndef(\master, { 0 });

// Clear all Ndefs (Stops sound and frees memory)
Ndef.clear(5);