/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: SAMPLE-BASED GRANULAR SYNTHESIS
   Target: Live Coding, JITLib, & RAG System Retrieval
   Concepts: TGrains vs GrainBuf, Warp1 Time-Stretching, Clouds, & Glitch
   =============================================================================
*/

// =============================================================================
// 0. SETUP & BUFFER LOADING (Run once)
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 64; // Granular synthesis requires ample real-time memory

s.waitForBoot({
	"Server Booted. Initializing Granular Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };
	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;
	NdefMixer(s);

	// LOAD AUDIO BUFFER
	// Using SuperCollider's built-in default sound file for universal compatibility.
	// Replace this path with any breakbeat, vocal, or synth chord on your hard drive.
	~b_samp = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

	// CUSTOM GRAIN ENVELOPE (Optional but powerful)
	// A Gaussian curve creates the smoothest, most "watery" grains.
	~b_env = Buffer.sendCollection(s, Env([0, 1, 0], [0.5, 0.5], \sine).discretize, 1);

	// MASTER FX & LIMITER
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in| Limiter.ar(LeakDC.ar(in), 0.95) });

	"Sample Buffers Loaded.".postln;
});
)


// =============================================================================
// 1. ASYNCHRONOUS CLOUDS (GrainBuf)
// Best for: Ambient drones, blurring vocals, creating wide spatial textures.
// Concept: Randomized triggers (Dust), position (0.0 to 1.0), and pitch.
// CRITICAL RULE: GrainBuf uses normalized position (0.0 to 1.0).
// =============================================================================

(
Ndef(\granCloud, {
	var buf = \buf.kr(~b_samp);
	var envBuf = \envBuf.kr(~b_env);

	// Cloud Parameters
	var dens = \dens.kr(40);        // Grains per second
	var dur = \dur.kr(0.15);        // Grain length
	var pitch = \pitch.kr(1.0);     // Base playback rate (1=normal, -1=reverse)
	var pos = \pos.kr(0.5);         // Center read position (0.0 to 1.0)

	// Randomization (Jitter)
	var pitchJitter = \pitchJit.kr(0.05);
	var posJitter = \posJit.kr(0.1);
	var panSpread = \spread.kr(0.8);      // 0=Mono, 1=Hard Panned

	var trig, calcPos, calcPitch, sig;

	// 1. Asynchronous Triggers (Dust creates random, non-rhythmic firing)
	trig = Dust.kr(dens);

	// 2. Apply Jitter per grain
	// TRand picks a new random number every time 'trig' fires
	calcPos = pos + TRand.kr(posJitter.neg, posJitter, trig);
	calcPitch = pitch + TRand.kr(pitchJitter.neg, pitchJitter, trig);

	// Wrap position safely between 0 and 1
	calcPos = calcPos.wrap(0, 1);

	// 3. Generation via GrainBuf
	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: trig,
		dur: dur,
		sndbuf: buf,
		rate: calcPitch,
		pos: calcPos,
		interp: 2,               // Linear interpolation
		pan: TRand.kr(panSpread.neg, panSpread, trig), // Random pan
		envbufnum: envBuf        // Custom smoothing envelope
	);

	sig * \amp.kr(0.5);
}).play;
)
Ndef(\master) <<> Ndef(\granCloud);

// LIVE TWEAKS:
// Ndef(\granCloud).xset(\pos, 0.2, \posJit, 0.01); // Focus on a specific phoneme/hit
// Ndef(\granCloud).xset(\pitch, 0.5, \dur, 0.4, \dens, 80); // Deep, smeared ambient pad
// Ndef(\granCloud).xset(\pitch, 2.0, \pitchJit, 0.5); // Shimmering, chaotic high frequencies


// =============================================================================
// 2. SYNCHRONOUS SCANNING (TGrains)
// Best for: Precise time-stretching, rhythmic slicing, metallic timbres.
// Concept: Steady triggers (Impulse), scanning linearly through the file.
// CRITICAL RULE: TGrains uses position in SECONDS.
// =============================================================================

(
Ndef(\granScan, {
	var buf = \buf.kr(~b_samp);
	var dens = \dens.kr(32);        // Steady grains per second
	var dur = \dur.kr(0.1);         // Grain length
	var pitch = \pitch.kr(1.0);
	var scanRate = \scanRate.kr(1); // How fast we move through the file

	var trig, posSec, sig;

	// 1. Linear Playhead (Phasor)
	// Phasor moves from 0 to total frames. We multiply by scanRate to change speed.
	var frames = BufFrames.kr(buf);
	var playhead = Phasor.kr(0, BufRateScale.kr(buf) * scanRate * ControlRate.ir.reciprocal, 0, frames);

	// 2. Synchronous Triggers (Impulse creates a steady metronome)
	trig = Impulse.kr(dens);

	// Convert frames to seconds for TGrains
	posSec = playhead / BufSampleRate.kr(buf);

	// 3. Generation via TGrains
	sig = TGrains.ar(
		numChannels: 2,
		trigger: trig,
		bufnum: buf,
		rate: pitch,
		centerPos: posSec,
		dur: dur,
		pan: 0,
		amp: 1,
		interp: 4 // High-quality interpolation
	);

	sig * \amp.kr(0.5);
}).play;
)
Ndef(\master) <<> Ndef(\granScan);

// LIVE TWEAKS:
Ndef(\granScan).xset(\scanRate, 0.1, \pitch, 1.0); // Clean time-stretch (10% speed)
Ndef(\granScan).xset(\scanRate, -1.0, \pitch, 1.0); // Reverse audio, forward pitch
Ndef(\granScan).xset(\dens, 100, \dur, 0.01); // Robotic/Metallic vocoder effect


// =============================================================================
// 3. THE MAGIC UGEN: WARP1
// Best for: Effortless, high-quality time-stretching and pitch-shifting.
// Concept: Warp1 abstracts the triggers and overlapping for you.
// =============================================================================

(
Ndef(\granWarp, {
	var buf = \buf.kr(~b_samp);
	var pitch = \pitch.kr(1.0);
	var posScale = \posScale.kr(0.1); // Playback speed (0.1 = 10% speed)
	var grainSize = \grainSize.kr(0.1);

	var pointer, sig;

	// 1. Pointer (0.0 to 1.0)
	// LFSaw sweeps from 0 to 1 over a calculated duration.
	var duration = BufDur.kr(buf) / posScale.max(0.001);
	pointer = LFSaw.kr(1 / duration).range(0, 1);

	// 2. Warp1 Generation
	// arguments: numChans, bufnum, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio
	sig = Warp1.ar(
		numChannels: 1,
		bufnum: buf,
		pointer: pointer,
		freqScale: pitch,
		windowSize: grainSize,
		envbufnum: -1, // Use default Hanning window
		overlaps: 8,   // Density of overlapping grains
		windowRandRatio: 0.1, // Slight time jitter
		interp: 4
	);

	sig * \amp.kr(0.5) ! 2;
}).play;
)
Ndef(\master) <<> Ndef(\granWarp);

// LIVE TWEAKS:
Ndef(\granWarp).xset(\posScale, 0.01, \pitch, 0.5); // "Paulstretch" extreme slow-down


// =============================================================================
// 4. RHYTHMIC STUTTER & GLITCH (Demand Rate)
// Best for: IDM, Breakcore, turning speech into rhythmic percussion.
// Concept: Using Demand UGens to sequence granular parameters per-grain.
// =============================================================================

(
Ndef(\granGlitch, {
	var buf = \buf.kr(~b_samp);
	var clock = \clock.kr(16); // 16th notes

	var trig, seqPos, seqPitch, seqDur, sig;

	trig = Impulse.kr(clock);

	// 1. Demand Sequencers
	// Dseq advances one step every time 'trig' fires.
	// We sequence the read position (0.0 to 1.0)
	seqPos = Demand.kr(trig, 0, Dseq([0.1, 0.2, 0.1, 0.8, 0.4, 0.4, 0.4, 0.9], inf));

	// Sequence the pitch (Octaves and reversing)
	seqPitch = Demand.kr(trig, 0, Dseq([1, 1, 2, -1, 1, 0.5, 1, 4], inf));

	// Sequence the grain duration (Staccato vs Legato)
	seqDur = Demand.kr(trig, 0, Dseq([0.1, 0.1, 0.05, 0.2], inf));

	// 2. GrainBuf Generation
	sig = GrainBuf.ar(
		numChannels: 2,
		trigger: trig,
		dur: seqDur,
		sndbuf: buf,
		rate: seqPitch,
		pos: seqPos,
		interp: 2,
		pan: 0
	);

	sig * \amp.kr(0.5);
}).play;
)
Ndef(\master) <<> Ndef(\granGlitch);

// LIVE TWEAKS:
Ndef(\granGlitch).xset(\clock, 32); // Double speed drill effect


// =============================================================================
// 5. SEQUENCING MACRO PARAMETERS (Pbind + Ndef)
// Best for: Evolving textures, playing the granulator like an instrument.
// Concept: The Ndef is an asynchronous cloud, but Pbind changes its parameters rhythmically.
// =============================================================================

// Make sure granCloud is running first!
(
Ndef(\granCloud_Seq, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\granCloud).nodeID }),
	\args, #[\pitch, \pos, \dens, \dur],

	\dur, Pseq([1.0, 0.5, 0.5, 2.0], inf),

	// Sequence chords/pitches
	\pitch, Pseq([1, 1.5, 1.25, 0.5], inf),

	// Jump around the audio file rhythmically
	\pos, Pwhite(0.2, 0.8, inf),

	// Alternate between sparse drops and dense clouds
	\dens, Pseq([10, 80, 80, 100], inf),

	// Alternate between tight plucks and smeared drones
	\dur, Pseq([0.05, 0.1, 0.1, 0.5], inf)
)).play;
)


// =============================================================================
// 6. CLEANUP
// =============================================================================

Ndef(\master).fadeTime = 5;
Ndef(\master, { 0 });
Ndef.clear(5);
~b_samp.free; ~b_env.free;