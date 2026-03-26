/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: DISTORTION & SATURATION
   Target: Live Coding, JITLib, & Timbral Destruction
   Concepts: Hard Math, Soft Clipping, Bitcrushing, Crossover, Multiband, & FX Chains
   =============================================================================
*/

// =============================================================================
// 0. SETUP & SAFETY (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Distortion Environment...".postln;

	// Force ProxySpace Initialization
	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	// Defaults
	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;

	NdefMixer(s);

	// MASTER FX & LIMITER (Crucial for Distortion!)
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = LeakDC.ar(in);
		// Hard limiter to protect your ears when driving signals heavily
		Limiter.ar(sig, 0.95, 0.01);
	});

	"Distortion Environment Ready.".postln;
});
)


// =============================================================================
// 1. HARD MATH SHAPING (Clip, Fold, Wrap)
// Best for: Industrial sounds, "West Coast" synthesis, chaotic textures.
// =============================================================================

(
Ndef(\hardMath).fadeTime = 0.5;
Ndef(\hardMath, {
	var freq = \freq.kr(110);
	var drive = \drive.kr(1.0); // Pushes signal into the walls
	var mode = \mode.kr(0);     // 0=Clip, 1=Fold, 2=Wrap
	var sig;

	// Basic source (Sine is best to hear added harmonics clearly)
	sig = SinOsc.ar(freq);

	// 1. GAIN STAGE (Pre-Amp)
	sig = sig * drive;

	// 2. SHAPING
	sig = Select.ar(mode, [
		sig.clip2(1.0), // CLIP: Squares the wave. Odd harmonics.
		sig.fold2(1.0), // FOLD: Mirrors wave back in. Buchla-style chevrons.
		sig.wrap2(1.0)  // WRAP: Teleports from +1 to -1. Harsh digital aliasing.
	]);

	// 3. GAIN COMPENSATION (Post-Amp)
	sig = sig * (1 / drive.max(1).sqrt);

	sig * \amp.kr(0.3) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\hardMath);

// LIVE TWEAKS:
Ndef(\hardMath).xset(\drive, 5, \mode, 0); // Standard Overdrive (Clip)
Ndef(\hardMath).xset(\drive, 8, \mode, 1, \freq, 60); // West Coast Scream (Fold)
Ndef(\hardMath).xset(\drive, 4, \mode, 2); // Digital Glitch (Wrap)


// =============================================================================
// 2. ANALOG SATURATION & ASYMMETRY (Soft Clipping)
// Best for: Warmth, tube amp emulation, gluing mixes.
// Math: Uses hyperbolic tangent to round off peaks smoothly.
// =============================================================================

(
Ndef(\analogSat, {
	var freq = \freq.kr(200);
	var drive = \drive.kr(1.0);
	var bias = \bias.kr(0.0); // DC Offset for Asymmetry
	var sig;

	sig = SinOsc.ar(freq);

	// 1. ASYMMETRY
	// Adding a DC offset before distortion makes positive and negative
	// cycles clip differently. This produces EVEN harmonics (Tube warmth).
	sig = sig + bias;

	// 2. SATURATION (The "Tube")
	sig = (sig * drive).tanh;

	// 3. DC BLOCKER
	// Mandatory if we used 'bias', otherwise speakers push out and stay there
	sig = LeakDC.ar(sig);

	// 4. GAIN COMPENSATION
	sig = sig * (1 / drive.max(1).sqrt);

	sig * \amp.kr(0.4) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\analogSat);

// LIVE TWEAKS:
Ndef(\analogSat).xset(\drive, 10, \bias, 0); // Saturated Symmetrical
Ndef(\analogSat).xset(\drive, 5, \bias, 0.6); // Broken Tube (Asymmetrical)


// =============================================================================
// 3. DIGITAL DEGRADATION (Bitcrushing & Downsampling)
// Best for: Chiptune, lo-fi hip hop, artifacts, robotic sounds.
// =============================================================================

(
Ndef(\bitCrush, {
	var freq = \freq.kr(150);
	var bitDepth = \bits.kr(16); // Amplitude resolution
	var sRate = \sRate.kr(44100); // Time resolution
	var sig, bitRes;

	// A slightly richer source to crush
	sig = Saw.ar(freq);

	// 1. SAMPLE RATE REDUCTION (Time / Horizontal)
	sig = Latch.ar(sig, Impulse.ar(sRate));

	// 2. BIT DEPTH REDUCTION (Amplitude / Vertical)
	bitRes = 2.pow(bitDepth);
	sig = sig.round(1 / bitRes);

	// Note: SC also has a built-in UGen for this: Decimator.ar(sig, sRate, bits)

	sig * \amp.kr(0.2) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\bitCrush);

// LIVE TWEAKS:
Ndef(\bitCrush).xset(\bits, 8, \sRate, 8000); // Atari/NES vibe
Ndef(\bitCrush).xset(\bits, 3, \sRate, 1500); // Complete destruction


// =============================================================================
// 4. FUNCTION SHAPING & CROSSOVER
// Best for: Dynamic timbre morphing, "broken amp" sputtering, needle pulses.
// =============================================================================

(
Ndef(\shapeShifter, {
	var freq = \freq.kr(80);
	var curve = \curve.kr(0); // 0=Linear, >0=Square-ish, <0=Needle-ish
	var crossover = \crossover.kr(0); // Deadzone at amplitude 0
	var sig;

	sig = SinOsc.ar(freq);

	// 1. CROSSOVER DISTORTION
	// Zeros out the signal if it's close to the center line.
	sig = sig * (sig.abs > crossover);

	// 2. LINCURVE MAPPING
	// Remaps the sine wave shape dynamically using exponential curves
	sig = sig.lincurve(-1, 1, -1, 1, curve);

	sig = LeakDC.ar(sig);
	sig * \amp.kr(0.3) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\shapeShifter);

// LIVE TWEAKS:
Ndef(\shapeShifter).xset(\curve, 10); // Square-ish (Pushing sides out)
Ndef(\shapeShifter).xset(\curve, -10); // Needle-ish (Pulling sides in)
Ndef(\shapeShifter).xset(\crossover, 0.2, \curve, 0); // Broken Amp fizz


// =============================================================================
// 5. MULTIBAND DISTORTION (The "Modern Bass" trick)
// Best for: Drum loops, basslines.
// Concept: Splitting frequencies, distorting the highs, keeping the subs clean.
// =============================================================================

(
Ndef(\multiband, {
	var freq = \freq.kr(55);
	var drive = \drive.kr(5);
	var xoverFreq = \xover.kr(300); // Crossover frequency
	var sig, subBand, midHighBand;

	// Rich source
	sig = Pulse.ar(freq, 0.4);

	// 1. SPLIT THE SIGNAL
	subBand = LPF.ar(sig, xoverFreq); // Clean low end
	midHighBand = HPF.ar(sig, xoverFreq); // High end to be destroyed

	// 2. DISTORT THE HIGHS
	midHighBand = (midHighBand * drive).fold2(1.0); // Wavefold the highs
	midHighBand = midHighBand * (1 / drive.max(1).sqrt); // Compensate

	// 3. RECOMBINE
	sig = subBand + midHighBand;

	sig * \amp.kr(0.4) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\multiband);


// =============================================================================
// 6. FEEDBACK WAVEFOLDING (Phase Modulation)
// Best for: Pure, screaming Buchla-style tones without using .fold2
// Concept: Using a sine wave to phase-modulate itself via LocalIn/Out.
// =============================================================================

(
Ndef(\fbFolder, {
	var freq = \freq.kr(110);
	var fb = \fb.kr(0); // Feedback amount
	var sig;

	// The sine wave's phase is modulated by a delayed copy of itself.
	sig = SinOsc.ar(freq + (LocalIn.ar(1) * fb));

	// Send the signal back into the local loop
	LocalOut.ar(sig);

	sig * \amp.kr(0.3) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\fbFolder);

// LIVE TWEAKS:
Ndef(\fbFolder).xset(\fb, 500); // Moderate folding
Ndef(\fbFolder).xset(\fb, 2000); // Screaming overtones


// =============================================================================
// 7. PRACTICAL FX CHAIN: VIRTUAL GUITAR PEDAL EMULATOR
// Best for: Turning dry plucks/synths into electric guitar tones.
// Signal Flow: Source -> Drive/Asymmetry -> Mid-Boost EQ -> Cab Sim
// =============================================================================



(
// The Sound Source (A simple Pluck string)
Ndef(\guitarSource).fadeTime = 0;
Ndef(\guitarSource, {
	var t_trig = \t_trig.tr(1);
	var freq = \freq.kr(220);
	// Pluck simulates a physical string
	var sig = Pluck.ar(WhiteNoise.ar(0.1), t_trig, 0.2, freq.reciprocal, 3, 0.5);
	sig ! 2;
});

// The Pedalboard (Insert FX Chain)
Ndef(\guitarPedal, {
	var sig = Ndef(\guitarSource).ar; // Read the source
	var drive = \drive.kr(8.0);
	var tone = \tone.kr(2500); // Tone knob (LPF)

	// 1. TUBE SCREAMER STAGE (Asymmetric Soft Clip + Mid Boost)
	sig = sig + 0.1; // Bias for asymmetry
	sig = (sig * drive).tanh;
	sig = LeakDC.ar(sig);
	sig = BPeakEQ.ar(sig, 800, 1.0, 6.0); // Boost 800Hz by 6dB (The "Tube Screamer" mid hump)

	// 2. TONE KNOB
	sig = LPF.ar(sig, tone);

	// 3. CAB SIMULATOR (A steep filter to remove digital fizz)
	// Guitars don't have much output above 6kHz or below 80Hz
	sig = LPF.ar(sig, 6000);
	sig = HPF.ar(sig, 80);

	// Gain compensation
	sig = sig * (1 / drive.max(1).sqrt);

	sig * \amp.kr(0.5);
}).play;
)
Ndef(\master) <<> Ndef(\guitarPedal);

// LIVE PERFORMANCE:
Ndef(\guitarSource).set(\t_trig, 1, \freq, [110, 164.8, 220].choose); // Play random power chords
Ndef(\guitarPedal).xset(\drive, 20.0, \tone, 4000); // Turn up the distortion


// =============================================================================
// 8. PRACTICAL FX CHAIN: LO-FI BITCRUSHER DELAY
// Best for: Vintage sampler vibes, dub techno stabs, eerie vocals.
// Signal Flow: Source -> Decimator -> BPF (Telephone EQ) -> Slapback Delay
// =============================================================================

(
// The Sound Source (A simple synth stab)
Ndef(\lofiSource).fadeTime = 0;
Ndef(\lofiSource, {
	var t_trig = \t_trig.tr(1);
	var env = EnvGen.kr(Env.perc(0.01, 0.5), t_trig);
	var sig = Pulse.ar(\freq.kr(440), 0.3) * env;
	sig ! 2;
});

// The Lo-Fi Chain
Ndef(\lofiChain, {
	var sig = Ndef(\lofiSource).ar;
	var sRate = \sRate.kr(8000);
	var bits = \bits.kr(6);
	var delayTime = \delayTime.kr(0.3);
	var feedback = \feedback.kr(0.4);

	// 1. MPC/SP-404 STYLE BITCRUSHING
	sig = Decimator.ar(sig, sRate, bits);

	// 2. TELEPHONE EQ (Bandpass filtering out lows and highs)
	sig = BPF.ar(sig, 1200, 0.8);

	// 3. DIRTY SLAPBACK DELAY
	// CombC allows for feedback delays
	sig = sig + CombC.ar(sig, 2.0, delayTime, delayTime * 4 * feedback);

	sig * \amp.kr(0.6);
}).play;
)
Ndef(\master) <<> Ndef(\lofiChain);

// LIVE PERFORMANCE:
Ndef(\lofiSource).set(\t_trig, 1, \freq, 600); // Play the synth
Ndef(\lofiChain).xset(\sRate, 4000, \bits, 4, \delayTime, 0.15); // Make it dirtier and faster


// =============================================================================
// 9. CLEANUP
// =============================================================================

// Ndef(\master).fadeTime = 5;
// Ndef(\master, { 0 });
// Ndef.clear(5);