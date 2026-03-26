/*
   SUPERCOLLIDER KNOWLEDGE BASE: LIVE INPUT & ARCHITECTURE
   -------------------------------------------------------
   Topics:
   1. System Architecture (Busses & Groups)
   2. Input Routing (Mic to Busses)
   3. Live Time-Based Effects (Delays, Resonators)
   4. Real-Time Granular Synthesis (Live Texture Freezing)
*/

// =====================================================================
// 1. SERVER CONFIGURATION & BOOT
// =====================================================================
(
// Increase memory for delay lines and buffers
s.options.memSize = 2.pow(20); // Approx 1GB real-time memory
s.options.numInputBusChannels = 2; // Ensure inputs are active
s.options.numOutputBusChannels = 2;

s.waitForBoot({
	// --- A) ALLOCATE GLOBAL RESOURCES ---

	// 1. Reset Allocators (Good practice before creating new busses)
	s.newBusAllocators;

	// 2. Audio Busses (Invisible cables between synths)
	~bus_dry    = Bus.audio(s, 2); // Main clean signal
	~bus_delay  = Bus.audio(s, 2); // Send to Dub Delay
	~bus_reverb = Bus.audio(s, 2); // Send to Resonator/Reverb

	// 3. Buffers (For Granular Synthesis)
	// Allocate 3 seconds of buffer memory for live recording
	if(~b_live.notNil, { ~b_live.free });
	~b_live = Buffer.alloc(s, s.sampleRate * 3);

	"Server Booted and Resources Allocated.".postln;
});
)


// =====================================================================
// 2. SYNTH DEFINITIONS (Run these blocks individually to update)
// =====================================================================

// 6.2 LIVE INPUT ROUTER
// Best for: Getting a clean mic signal and sending it to effects.
(
SynthDef(\micInputLive, {
	arg
		inChan = 0,      // Hardware Input Index
		outBus = 0,      // Output destination (Internal Bus)
		sendDelay = 0,   // Aux Send Level to Delay
		sendReverb = 0,  // Aux Send Level to Reverb
		amp = 1.0,
		gate = 1;

	var sig, env;

	// Smooth mute/unmute
	env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction: 2);

	// SoundIn adapts to hardware input offset automatically
	sig = SoundIn.ar(inChan) ! 2; // Force Mono In -> Stereo Out

	sig = sig * env * amp;

	// ROUTING
	// 1. Direct Out (Dry signal to main bus)
	Out.ar(outBus, sig);

	// 2. Aux Sends (Post-Fader sends to FX busses)
	Out.ar(~bus_delay, sig * sendDelay);
	Out.ar(~bus_reverb, sig * sendReverb);
}).add;
)

// 6.3 LIVE EFFECTS: Dub Delay & Resonator
(
// DUB DELAY (Variable Time + Pitch Shift)
SynthDef(\dubDelayLive, {
	arg in, out,
		maxDelay = 2.0,
		time = 0.5,
		feedback = 0.7,
		amp = 1.0;

	var sig, local;

	sig = In.ar(in, 2);
	local = LocalIn.ar(2) + sig; // Read feedback loop

	// DelayL allows smooth time modulation (Pitch warping)
	local = DelayL.ar(local, maxDelay, time);

	// Filter the repeats (Tape echo style)
	local = LPF.ar(local, 2000);

	// LeakDC prevents DC bias buildup in loops
	LocalOut.ar(local * feedback);

	Out.ar(out, local * amp);
}).add;
)

// RESONATOR (Comb Filter)
(
SynthDef(\resonatorLive, {
	arg in, out,
		freq = 40,       // Resonant pitch (Hz)
		decay = 2.0,     // Ring time
		amp = 0.5;

	var sig;
	sig = In.ar(in, 2);

	// Convert Freq to Delay Time (T = 1/f)
	sig = CombN.ar(sig, 0.2, 1/freq, decay);

	Out.ar(out, sig * amp);
}).add;
)

// MAIN MIXER (Final Output)
// Reads from internal busses and sums them to speakers
(
SynthDef(\mainOutLive, {
	arg inDry, inDelay, inReverb, out=0, masterVol=1;
	var dry, wet1, wet2, sum;

	dry  = In.ar(inDry, 2);
	wet1 = In.ar(inDelay, 2);
	wet2 = In.ar(inReverb, 2);

	sum = dry + wet1 + wet2;
	sum = Limiter.ar(sum); // Safety
	Out.ar(out, sum * masterVol);
}).add;
)

// 6.4 LIVE GRANULAR SYNTHESIS
// Best for: Real-time texture freezing, stutter effects.
(
SynthDef(\liveGranLive, {
	arg
		inChan = 0,
		buf = 0,
		out = 0,
		amp = 0.5,

		// Granular Controls
		rate = 1,          // Pitch playback rate
		density = 16,      // Grains per second
		dur = 0.05,        // Grain duration
		delayTime = 0.2,   // How far behind "now" to read (latency)
		posJitter = 0.01,  // Randomness in read position

		gate = 1;

	var input, writePtr, readPtr, grainTrig, sig, env;

	env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction: 2);

	// A) INPUT & RECORDING
	input = SoundIn.ar(inChan);

	// Phasor: A precise audio-rate ramp from 0 to BufFrames
	// This acts as our "Record Head"
	writePtr = Phasor.ar(0, BufRateScale.kr(buf), 0, BufFrames.kr(buf));
	BufWr.ar(input, buf, writePtr);

	// B) GRAIN CALCULATIONS
	grainTrig = Dust.kr(density); // Random triggers

	// Calculate Read Pointer:
	// Start at Write Pointer -> Subtract delay time (convert seconds to samples)
	readPtr = writePtr - (delayTime * SampleRate.ir);

	// Normalize pointer (0.0 to 1.0) for GrainBuf
	readPtr = readPtr / BufFrames.kr(buf);

	// Add Jitter (Texture)
	// TRand generates a new random number every grain trigger
	readPtr = readPtr + TRand.kr(posJitter.neg, posJitter, grainTrig);

	// Wrap values between 0 and 1 so we don't read off the edge
	readPtr = readPtr.wrap(0, 1);

	// C) SAFETY LIMITER (Anti-Click)
	// If playing backwards or fast forward, grain might catch up to record head.
	// We limit duration based on the delay gap.
	dur = dur.min(delayTime / rate.abs.max(0.1));

	// D) GENERATION
	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: grainTrig,
		dur: dur,
		sndbuf: buf,
		rate: rate,
		pos: readPtr,
		interp: 2, // Linear interpolation
		pan: 0
	);

	Out.ar(out, sig * env * amp);
}).add;
)


// =====================================================================
// 3. EXECUTION & ROUTING
// =====================================================================
(
// Define Order of Execution using Groups
// Audio flows: Input Group -> FX Group -> Output Group
~grp_in  = Group.new;
~grp_fx  = Group.after(~grp_in);
~grp_out = Group.after(~grp_fx);

// Instantiate Synths
// 1. The Output Mixer (Must be last in chain)
~master = Synth(\mainOutLive, [
	\inDry, ~bus_dry,
	\inDelay, ~bus_delay,
	\inReverb, ~bus_reverb,
	\out, 0
], ~grp_out);

// 2. The Effects (Middle of chain)
~fx_del = Synth(\dubDelayLive, [\in, ~bus_delay, \out, ~bus_dry], ~grp_fx);
~fx_res = Synth(\resonatorLive, [\in, ~bus_reverb, \out, ~bus_dry], ~grp_fx);

// 3. The Sources (Start of chain)
// Mic Input
~mic = Synth(\micInputLive, [
	\outBus, ~bus_dry,
	\sendDelay, 0.0,
	\sendReverb, 0.0
], ~grp_in);

// Live Granulator (Also an input source)
~gran = Synth(\liveGranLive, [
	\buf, ~b_live,
	\out, ~bus_dry, // Send grains to dry bus
	\amp, 0.0       // Start silent
], ~grp_in);
)


// =====================================================================
// 4. LIVE CONTROL EXAMPLES (Run line by line)
// =====================================================================

// --- MIC & FX CONTROL ---

// Send Mic to Delay
~mic.set(\sendDelay, 0.5);
~fx_del.set(\time, 0.25, \feedback, 0.6);

// Dub Echo Throw (High feedback moment)
~fx_del.set(\feedback, 0.95);
~fx_del.set(\feedback, 0.6); // Return to normal

// Send Mic to Resonator (Metallic Drone)
~mic.set(\sendReverb, 0.5);
~fx_res.set(\freq, 50, \decay, 4);
~fx_res.set(\freq, 80); // Change pitch

// Stop Mic Input (Mute)
~mic.set(\amp, 0);


// --- GRANULAR CONTROL ---

// Bring in Granular Cloud
~gran.set(\amp, 0.6);

// 1. Angelic Freeze (Pitch up 1 octave, smooth)
~gran.set(\rate, 2, \density, 30, \dur, 0.1, \delayTime, 0.5);

// 2. Reverse Stutter (Pitch down, reverse, choppy)
~gran.set(\rate, -0.5, \density, 8, \dur, 0.15, \delayTime, 0.2);

// 3. Static Texture (Freeze the buffer in place)
~gran.set(\rate, 1.0, \density, 50, \dur, 0.2, \posJitter, 0.05);


// =====================================================================
// 5. CLEANUP
// =====================================================================
(
~grp_in.freeAll;
~grp_fx.freeAll;
~grp_out.freeAll;
~b_live.free;
)