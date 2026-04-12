

// --- PARKER SOLAR PROBE INSTRUMENTS ---
(
Ndef(\voidPad).clear;
Ndef(\voidPad, {
	|freq=40, amp=0.3, t_trig=1, hpfFreq=20|
	var env, sig, sub;
	env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 3]), t_trig);
	sig = Saw.ar([freq, freq * 1.01]);
	sub = SinOsc.ar([freq * 0.5, freq * 0.505]);
	sig = RLPF.ar(sig + sub, freq * 3, 0.4);
	sig = HPF.ar(sig, hpfFreq);
	sig * env * amp;
}).play;

Ndef(\probePulse).clear;
Ndef(\probePulse, {
	|freq=2000, modFreq=500, modIndex=1, amp=0.35, t_trig=1|
	var env, mod, sig;
	env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
	mod = SinOsc.ar(modFreq) * modIndex * freq;
	sig = SinOsc.ar(freq + mod);
	Pan2.ar(sig * env * amp, 0);
}).play;

Ndef(\venusGravity).clear;
Ndef(\venusGravity, {
	|freq=80, sweepDur=4, amp=0.5, t_trig=1, pan=0|
	var env, sweep, sig;
	env = EnvGen.ar(Env.perc(0.1, sweepDur), t_trig);
	sweep = EnvGen.ar(Env([freq * 6, freq, freq * 0.2], [0.1, sweepDur * 0.9], \exp), t_trig);
	sig = Pulse.ar(sweep, 0.3) + Saw.ar(sweep * 1.01);
	sig = RLPF.ar(sig, sweep * 1.5, 0.2);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\solarWind).clear;
Ndef(\solarWind, {
	|amp=0.25, t_trig=1, bpfFreq=2000, rq=0.1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
	sig = Array.fill(4, { PinkNoise.ar() + (WhiteNoise.ar() * 0.5) });
	sig = BPF.ar(sig, bpfFreq, rq);
	Splay.ar(sig) * env * amp;
}).play;
)

// --- PARKER SOLAR PROBE EFFECTS ---
(
// Reverb (Index 10)
Ndef(\voidPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\voidPad).set(\wet10, 0);

// Delay (Index 11)
Ndef(\probePulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \decayTime.kr(0.5)) };
Ndef(\probePulse).set(\wet11, 0);

// Distortion (Index 12)
Ndef(\solarWind)[12] = \filter -> { |in| (in * \drive.kr(5)).tanh }; // Changed to tanh for warmer, smoother saturation
Ndef(\solarWind).set(\wet12, 0);
)

// --- PARKER SOLAR PROBE SEQUENCES ---
(
Pbindef(\voidSeq, \dur, 8, \freq, Pseq([40, 42, 38, 45], inf), \t_trig, 1);
Pbindef(\probeSeq, \dur, 2, \freq, 2000, \modFreq, 500, \modIndex, 1, \t_trig, 1);
Pbindef(\venusSeq, \dur, 8, \freq, 80, \sweepDur, 4, \pan, Pseq([-0.8, 0.8], inf), \t_trig, 1);
Pbindef(\solarSeq, \dur, Pwhite(0.05, 0.15), \bpfFreq, Pwhite(1000, 5000), \rq, 0.1, \t_trig, 1);

// Quantization for synchronization
Ndef(\voidPad).quant = 1;
Ndef(\probePulse).quant = 1;
Ndef(\venusGravity).quant = 1;
Ndef(\solarWind).quant = 1;

// Set fade times for smooth transitions
Ndef(\voidPad).fadeTime = 3;
Ndef(\probePulse).fadeTime = 1;
Ndef(\venusGravity).fadeTime = 2;
Ndef(\solarWind).fadeTime = 2;
)


// --- PARKER SOLAR PROBE LIVE CODING TWEAKS ---

// =============================================================================
// Movement I: Launch & Vacuum (Intro / Static Loop)
// =============================================================================

Ndef(\voidPad)[1] = \set -> Pbindef(\voidSeq);
Ndef(\probePulse)[1] = \set -> Pbindef(\probeSeq);

Ndef(\voidPad).xset(\wet10, 1.0); // 100% wet massive reverb establishing deep space
// Ndef(\voidPad).xset(\wet10, 0); // Revert reverb

Ndef(\probePulse).xset(\wet11, 0); // Dry isolated ping representing the lonely probe
// Ndef(\probePulse).xset(\wet11, 0.5); // Revert delay


// =============================================================================
// Movement II: Venus Gravity Assists (Development)
// =============================================================================

Ndef(\venusGravity)[1] = \set -> Pbindef(\venusSeq); // Introduce the huge orbital whips
// Pbindef(\venusSeq).stop; // Revert Venus flybys

Pbindef(\probeSeq, \dur, 1); // Velocity increases
// Pbindef(\probeSeq, \dur, 2); // Revert velocity

Pbindef(\probeSeq, \dur, 0.5); // Velocity increases further
// Pbindef(\probeSeq, \dur, 1); // Revert velocity

Ndef(\probePulse).xset(\wet11, 0.4); // Add sonic trails for kinetic movement
// Ndef(\probePulse).xset(\wet11, 0); // Revert delay

Pbindef(\probeSeq, \modIndex, 4); // Tone becomes metallic and stressed from G-forces
// Pbindef(\probeSeq, \modIndex, 1); // Revert tone


// =============================================================================
// Movement III: Piercing the Corona (Radical Contrast)
// =============================================================================

Pbindef(\venusSeq).stop; // Leave planetary bodies behind
// Ndef(\venusGravity)[1] = \set -> Pbindef(\venusSeq); // Revert Venus

Ndef(\voidPad).xset(\hpfFreq, 400); // Radically thin the low end to make space for the sun
// Ndef(\voidPad).xset(\hpfFreq, 20); // Revert low end

Ndef(\solarWind)[1] = \set -> Pbindef(\solarSeq); // Plunge into the blistering solar wind
// Pbindef(\solarSeq).stop; // Revert solar wind

Ndef(\solarWind).xset(\wet12, 1.0, \drive, 10); // Overwhelming scorched wall of harsh noise
// Ndef(\solarWind).xset(\wet12, 0, \drive, 1); // Revert distortion

Pbindef(\probeSeq, \freq, Pn(Pgeom(1500, 1.15, 12), inf)); // Erratic, ascending pitch sweeps
// Pbindef(\probeSeq, \freq, 2000); // Revert pitch


// =============================================================================
// Movement IV: 0.064% The Speed of Light (Climax)
// =============================================================================

Pbindef(\probeSeq, \dur, 0.0625); // Push to incredible, audio-rate speeds
// Pbindef(\probeSeq, \dur, 0.5); // Revert sequence duration

Ndef(\probePulse).xset(\decayTime, 8, \wet11, 0.85); // Near-infinite blinding streaks
// Ndef(\probePulse).xset(\decayTime, 0.5, \wet11, 0.4); // Revert delay feedback

Ndef(\solarWind).xset(\rq, 1.0); // Open noise bandpass entirely for maximum stereo chaos
// Ndef(\solarWind).xset(\rq, 0.1); // Revert noise filter


// =============================================================================
// Movement V: Telemetry & Void (Outro)
// =============================================================================

Pbindef(\solarSeq).stop; // Emerge from the corona
// Ndef(\solarWind)[1] = \set -> Pbindef(\solarSeq); // Revert to solar wind

Ndef(\solarWind).xset(\wet12, 0, \drive, 1); // Immediately kill the intense heat
// Ndef(\solarWind).xset(\wet12, 1.0, \drive, 10); // Revert to heat

Pbindef(\probeSeq, \dur, 2, \freq, 400); // Slow down significantly, Doppler pitch drop
// Pbindef(\probeSeq, \dur, 0.0625, \freq, Pn(Pgeom(1500, 1.15, 12), inf)); // Revert Doppler


// =============================================================================
// FADE OUT & ENDING
// =============================================================================
(
Pbindef(\voidSeq).stop;
Pbindef(\probeSeq).stop;
Pbindef(\venusSeq).stop;
Pbindef(\solarSeq).stop;

Ndef(\voidPad).fadeTime = 8;
Ndef(\probePulse).fadeTime = 8;
Ndef(\venusGravity).fadeTime = 8;
Ndef(\solarWind).fadeTime = 8;

Ndef(\voidPad).clear(8);
Ndef(\probePulse).clear(8);
Ndef(\venusGravity).clear(8);
Ndef(\solarWind).clear(8);
)

// --- BLOCK 1: TWEAK_SEQUENCE ---
(
Pbindef(\probeSeq, \freq, Pn(Pwhite(1800, 2500, 8), inf)); // Introduce high-pitched, erratic blips for navigation
// Pbindef(\probeSeq, \freq, 2000); // Revert to fixed frequency
)

// --- GLOBAL SETUP (already assumed to be run, but for completeness) ---
(
s.options.numBuffers = 1024 * 256; // Increase for longer samples or complex reverb
s.options.memSize = 8192 * 16;     // Increase server memory
s.options.maxNodes = 2048;         // More nodes for complex patterns/synths
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.boot;
)

s.sync;

(
t = TempoClock.default;
t.tempo = 60/60; // 60 BPM
Pdef.defaultQuant = 1; // Quantize patterns to 1 beat by default
)

// Clear any existing Ndefs or Pbindefs to ensure a clean start
(
Ndef.clear;
Pbindef.clear;
)


// --- Section 1: Gentle Unveiling (Intro) INSTRUMENTS ---
(
Ndef(\baseTone).clear;
Ndef(\baseTone, {
	|freq=100, amp=0.4, modFreq=0.2, modIndex=0.01, pan=0|
	var mod, sig;
	// Low-frequency amplitude modulation to give a "breathing" quality
	mod = SinOsc.ar(modFreq) * modIndex;
	sig = SinOsc.ar(freq * (1 + mod)); // Carrier modulated by LFO
	Pan2.ar(sig * amp, pan);
}).play;
)

// --- Section 1: Gentle Unveiling (Intro) EFFECTS ---
(
// Reverb for baseTone (Index 10)
Ndef(\baseTone)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\baseTone).set(\wet10, 0); // Initially dry

// Delay for baseTone (Index 11) - defined but kept dry for now
Ndef(\baseTone)[11] = \filter -> { |in, delayTime=0.4, delFeedback=0.3| CombL.ar(in, delayTime, delayTime, delFeedback) };
Ndef(\baseTone).set(\wet11, 0);
)

// --- Section 1: Gentle Unveiling (Intro) LIVE CODING TWEAKS ---
(
Ndef(\baseTone).fadeTime = 8; // Set fade time for smooth crossfades
Ndef(\baseTone).xset(\amp, 0.3); // Slowly fade in the base tone
// Ndef(\baseTone).xset(\amp, 0); // Revert amp
Ndef(\baseTone).xset(\wet10, 0.4); // Gently introduce spacious reverb
// Ndef(\baseTone).xset(\wet10, 0); // Revert reverb
)


// --- Section 2: Drifting Harmonies (Development) INSTRUMENTS ---
(
Ndef(\harmony).clear;
Ndef(\harmony, {
	|freq=150, amp=0.2, pan=(-0.6)|
	var sig;
	sig = SinOsc.ar(freq);
	Pan2.ar(sig * amp, pan);
}).play;
)

// --- Section 2: Drifting Harmonies (Development) EFFECTS ---
(
// Reverb for harmony (Index 10)
Ndef(\harmony)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\harmony).set(\wet10, 0); // Initially dry
)

// --- Section 2: Drifting Harmonies (Development) SEQUENCES ---
(
// Pbindef for baseTone - gentle arpeggiation
Pbindef(\baseSeq,
	\dur, 2, // Slow, sustained notes
	\degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf), // Arpeggiated pattern
	\scale, Scale.majorPentatonic, // Simple, consonant scale
	\root, 40, // Base MIDI note
	\legato, 1.0 // Fully sustained
);
// Assign a scale-based frequency to baseTone. The Ndef's `freq` arg will be overwritten by this.
Pbindef(\baseSeq, \freq, Pkey(\degree).midicps);
Ndef(\baseTone).quant = 1;
Ndef(\baseTone)[1] = \set -> Pbindef(\baseSeq);

// Pbindef for harmony - slow panning and consonant intervals
Pbindef(\harmonySeq,
	\dur, 4, // Even slower notes for harmony
	\degree, Pseq([4, 7, 0, 2, 0, 7, 4, 7], inf), // Consonant to base tone, but shifting
	\scale, Scale.majorPentatonic,
	\root, 47, // Offset for harmony
	\legato, 1.0,
	\pan, Pseq([-0.6, 0.6, -0.4, 0.4, -0.2, 0.2, 0, 0], inf).wrap(-0.8, 0.8) // Slow, drifting pan
);
Pbindef(\harmonySeq, \freq, Pkey(\degree).midicps);
Ndef(\harmony).quant = 1;
Ndef(\harmony)[1] = \set -> Pbindef(\harmonySeq);
)

// --- Section 2: Drifting Harmonies (Development) LIVE CODING TWEAKS ---
(
Ndef(\baseTone).xset(\wet11, 0.3); // Introduce subtle, long delay on baseTone
// Ndef(\baseTone).xset(\wet11, 0); // Revert delay

Ndef(\harmony).fadeTime = 6; // Set fade time for harmony
Ndef(\harmony).xset(\amp, 0.15); // Gently fade in the harmony tone
// Ndef(\harmony).xset(\amp, 0); // Revert amp
Ndef(\harmony).xset(\wet10, 0.3); // Gently introduce reverb on harmony
// Ndef(\harmony).xset(\wet10, 0); // Revert reverb
)


// --- Section 3: Phase Shift (Radical Contrast) LIVE CODING TWEAKS ---

// baseTone pattern shifts to slightly higher/new harmonic color
(
Pbindef(\baseSeq,
	\root, 52, // Shift base tone octave up
	// \root, 40, // Revert root
	\degree, Pseq([0, 3, 5, 8, 10, 8, 5, 3], inf) // New, slightly more dissonant arpeggio
	// \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf) // Revert degree
);
Ndef(\baseTone).xset(\modIndex, 0.03); // Amplitude modulation slightly more pronounced
// Ndef(\baseTone).xset(\modIndex, 0.01); // Revert modIndex
)

// harmony frequency morphs to a different consonant interval or subtle beat frequency
(
Pbindef(\harmonySeq,
	\root, 58, // Shift harmony root to create new intervals with baseTone
	// \root, 47, // Revert root
	\degree, Pseq([5, 8, 1, 3, 1, 8, 5, 8], inf), // New harmonic intervals
	// \degree, Pseq([4, 7, 0, 2, 0, 7, 4, 7], inf), // Revert degree
	\pan, Pseq([-0.8, 0.8, -0.6, 0.6, -0.4, 0.4, -0.2, 0.2], inf).wrap(-0.9, 0.9) // Wider, slightly faster pan
	// \pan, Pseq([-0.6, 0.6, -0.4, 0.4, -0.2, 0.2, 0, 0], inf).wrap(-0.8, 0.8) // Revert pan
);
)

// Delay feedback slightly increased for baseTone
Ndef(\baseTone).xset(\delFeedback, 0.5);
// Ndef(\baseTone).xset(\delFeedback, 0.3); // Revert delFeedback

// Reverb decay time slightly lengthened for baseTone
Ndef(\baseTone).xset(\revDecay, 1.2);
// Ndef(\baseTone).xset(\revDecay, 0.8); // Revert revDecay

// Reverb decay time slightly lengthened for harmony
Ndef(\harmony).xset(\revDecay, 1.2);
// Ndef(\harmony).xset(\revDecay, 0.8); // Revert revDecay


// --- Section 4: Dissolution (Outro) ---
(
Pbindef(\baseSeq).stop; // Stop baseTone arpeggio, current note sustains
Pbindef(\harmonySeq).stop; // Stop harmony arpeggio, current note sustains

Ndef(\harmony).fadeTime = 10; // Long fade out for harmony
Ndef(\harmony).xset(\amp, 0); // Fade out harmony
// Ndef(\harmony).xset(\amp, 0.15); // Revert amp

Ndef(\baseTone).fadeTime = 12; // Even longer fade out for baseTone
Ndef(\baseTone).xset(\amp, 0); // Fade out baseTone
// Ndef(\baseTone).xset(\amp, 0.3); // Revert amp

// Momentarily increase wetness to emphasize decaying tails
Ndef(\baseTone).xset(\wet10, 0.9, \wet11, 0.8); // Max out reverb and delay on baseTone
// Ndef(\baseTone).xset(\wet10, 0.4, \wet11, 0.3); // Revert wetness for baseTone
Ndef(\harmony).xset(\wet10, 0.9); // Max out reverb on harmony
// Ndef(\harmony).xset(\wet10, 0.3); // Revert wetness for harmony

// Schedule the eventual full fade out of effects and clearing of Ndefs
(
var fadeTimeFinal = 20; // Total time for tails to fully decay

// Gradually reduce effect wetness
~cleanupTimer = TempoClock.default.sched(thisThread.beats + 5, {
	Ndef(\baseTone).fadeTime = 10;
	Ndef(\baseTone).xset(\wet10, 0, \wet11, 0); // Fade out baseTone effects
	Ndef(\harmony).fadeTime = 10;
	Ndef(\harmony).xset(\wet10, 0); // Fade out harmony effects
});

// Clear Ndefs after everything has faded out
~cleanupTimer = TempoClock.default.sched(thisThread.beats + fadeTimeFinal, {
	Ndef(\baseTone).clear(5); // Clear with a final fade buffer
	Ndef(\harmony).clear(5);
	"Composition ended.".postln;
});
)

// --- Instrument Definitions ---
(
// Ndef(\rainNoise): Continuous, evolving atmospheric texture
Ndef(\rainNoise).clear;
Ndef(\rainNoise, {
	|amp=0.1, filterFreq=200, rq=0.1, t_trig=1, pan=0|
	var sig;
	sig = PinkNoise.ar();
	sig = RLPF.ar(sig, filterFreq, rq);
	Pan2.ar(sig * amp, pan); // Stereo spread
}).play;
Ndef(\rainNoise).fadeTime = 2;

// Ndef(\drops): Sparse, percussive "raindrop" sounds
Ndef(\drops).clear;
Ndef(\drops, {
	|amp=0.25, freq=1000, rq=0.5, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.05), t_trig); // Very short percussive envelope
	sig = WhiteNoise.ar();
	sig = BPF.ar(sig, freq, rq); // Bandpass filter for a distinct "plink"
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\drops).fadeTime = 0.1;

// Ndef(\chimes): Gentle, bell-like or metallic tones (FM Synthesis)
Ndef(\chimes).clear;
Ndef(\chimes, {
	|freq=440, amp=0.05, t_trig=1, modRatio1=2, modRatio2=3.5, modIndexScale=1, pan=0|
	var indexEnv, ampEnv, mod1, mod2, car;
	// Percussive envelope for modulation intensity and amplitude
	indexEnv = EnvGen.kr(Env.perc(0.001, 0.2), t_trig); // Quick decay for metallic strike
	ampEnv = EnvGen.kr(Env.perc(0.001, 0.5), t_trig); // Longer decay for bell sustain

	// Parallel FM synthesis (Bell algorithm from KB)
	mod1 = SinOsc.ar(freq * modRatio1) * (freq * modRatio1 * indexEnv * modIndexScale);
	mod2 = SinOsc.ar(freq * modRatio2) * (freq * 0.5 * indexEnv * modIndexScale);
	car = SinOsc.ar(freq + mod1 + mod2);
	Pan2.ar(car * ampEnv * amp, pan);
}).play;
Ndef(\chimes).fadeTime = 2;

// Ndef(\bells): Richer, more resonant and sustained bell sounds (DynKlank)
Ndef(\bells).clear;
Ndef(\bells, {
	|fund=110, amp=0.3, t_trig=1, decayscale=1, pan=0|
	var env, freqs, amps, ringtimes, sig;

	// Generate harmonics for a bell-like sound using DynKlank
	freqs = #[1, 2.01, 3.03, 4.16, 5.25, 6.33, 7.61, 8.85, 9.99] * fund;
	amps = #[1.0, 0.7, 0.5, 0.4, 0.3, 0.2, 0.15, 0.1, 0.05];
	ringtimes = #[4, 2, 1.5, 1, 0.8, 0.6, 0.5, 0.4, 0.3] * decayscale;

	env = EnvGen.ar(Env.perc(0.01, 4), t_trig, levelScale: amp); // Long decay for sustained bell
	sig = DynKlank.ar(`[freqs, amps, ringtimes], Impulse.ar(0, 0, env));
	Pan2.ar(sig, pan);
}).play;
Ndef(\bells).fadeTime = 4;

// Ndef(\bassPad): Low-frequency, sustained harmonic foundation
Ndef(\bassPad).clear;
Ndef(\bassPad, {
	|freq=40, amp=0.1, t_trig=1, atk=4, sus=4, rel=8, filterFreq=200, rq=0.2, pan=0|
	var env, sig, sub;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel]), t_trig); // Long ADSR-like envelope
	sig = Saw.ar([freq, freq * 1.005]); // Slightly detuned saw for warmth
	sub = SinOsc.ar([freq * 0.5, freq * 0.501]); // Sub-octave sine for depth
	sig = RLPF.ar(sig + sub, filterFreq, rq);
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\bassPad).fadeTime = 4;
)

// --- Effect Definitions ---

(
// Ndef(\rainNoise) effects (Index 10: Reverb)
Ndef(\rainNoise)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8, 0.5) }; // Reverb: room size 0.8, damping 0.5
Ndef(\rainNoise).set(\wet10, 0); // Initially dry

// Ndef(\drops) effects (Index 11: Delay)
Ndef(\drops)[11] = \filter -> { |in| CombL.ar(in, 0.1, 0.05, 0.8) }; // Delay: max delay 0.1s, delay time 0.05s, decay 0.8s
Ndef(\drops).set(\wet11, 0); // Initially dry

// Ndef(\chimes) effects (Index 10: Reverb, Index 11: Delay)
Ndef(\chimes)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.2) }; // Reverb: room size 0.7, damping 0.2
Ndef(\chimes).set(\wet10, 0); // Initially dry
Ndef(\chimes)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.3, 1.0) }; // Delay: max delay 0.5s, delay time 0.3s, decay 1.0s
Ndef(\chimes).set(\wet11, 0); // Initially dry

// Ndef(\bells) effects (Index 10: Reverb, Index 11: Delay)
Ndef(\bells)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.7) }; // Reverb: room size 0.9, damping 0.7 (cathedral-like)
Ndef(\bells).set(\wet10, 0); // Initially dry
Ndef(\bells)[11] = \filter -> { |in| CombL.ar(in, 1.0, 0.8, 4.0) }; // Delay: max delay 1.0s, delay time 0.8s, decay 4.0s (lush)
Ndef(\bells).set(\wet11, 0); // Initially dry

// Ndef(\bassPad) effects (Index 10: Reverb)
Ndef(\bassPad)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.8) }; // Reverb: room size 0.6, damping 0.8
Ndef(\bassPad).set(\wet10, 0); // Initially dry
)

// --- Sequence Definitions ---

(
// Pbindef(\rainNoiseSeq): Controls Ndef(\rainNoise) filter cutoff
Pbindef(\rainNoiseSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\rainNoise).nodeID }),
	\args, #[\filterFreq],
	\filterFreq, Pn(Pseg(200, 1000, 60, \lin), inf) // Slowly raise cutoff from 200 to 1000 over 60s
);

// Pbindef(\dropSeq): Controls Ndef(\drops) timing, pitch, and panning
Pbindef(\dropSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\drops).nodeID }),
	\args, #[\t_trig, \freq, \pan],
	\t_trig, 1,
	\dur, Pn(Pwrand([2, 1, 0.5], [0.5, 0.3, 0.2], inf), inf), // Irregular timing
	\freq, Pn(Pwhite(500, 2000, inf), inf), // Random high frequencies
	\pan, Pn(Pwhite((-0.8), 0.8, inf), inf) // Random panning
);

// Pbindef(\chimeSeq): Sequences Ndef(\chimes) melodic phrases
Pbindef(\chimeSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\chimes).nodeID }),
	\args, #[\t_trig, \freq, \amp, \pan],
	\t_trig, 1,
	\dur, Pn(Pwrand([1, 0.75, 0.5], [0.6, 0.3, 0.1], inf), inf), // Slow, varied rhythm
	\freq, Pn(Pseq([60, 64, 67, 72].midicps, inf), inf), // Simple, hopeful major arpeggio
	\amp, Pn(Pseq([0.1, 0.15, 0.2, 0.18], inf), inf), // Dynamic amplitudes
	\pan, Pn(Pseq([(-0.4), 0.4, (-0.2), 0.2], inf), inf)
);

// Pbindef(\bellSeq): Sequences Ndef(\bells) harmonic progressions (root notes)
Pbindef(\bellSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\bells).nodeID }),
	\args, #[\t_trig, \fund, \pan],
	\t_trig, 1,
	\dur, Pn(Pwrand([4, 2, 1], [0.6, 0.3, 0.1], inf), inf), // Slower, more sustained phrases
	\fund, Pn(Pseq([
		60, // C Major root
		58, // Bb Major root
		62  // D Major root
	].midicps, inf), inf),
	\pan, Pn(Pseq([(-0.6), 0.6, 0.0], inf), inf) // Panning for chord elements
);

// Pbindef(\bassPadSeq): Sequences Ndef(\bassPad) sustained notes
Pbindef(\bassPadSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\bassPad).nodeID }),
	\args, #[\t_trig, \freq, \atk, \sus, \rel, \pan],
	\t_trig, 1,
	\dur, 8, // Long, sustained notes
	\freq, Pn(Pseq([36, 34, 38].midicps, inf), inf), // Root notes for chords
	\atk, 4, \sus, 4, \rel, 8, // Long envelopes
	\pan, 0 // Centered
);
)

// --- Section 1: Rainy Intro ---

(
// Initial setup for rainNoise and drops
Ndef(\rainNoise).xset(\amp, 0.1, \filterFreq, 200, \rq, 0.1, \pan, 0); // Initial low cutoff, centered
// Ndef(\rainNoise).xset(\amp, 0.1, \filterFreq, 200, \rq, 0.1, \pan, 0); // Revert
Ndef(\rainNoise).set(\wet10, 0.8); // Very wet reverb for atmosphere
// Ndef(\rainNoise).set(\wet10, 0); // Revert

Ndef(\drops).xset(\amp, 0.25); // Slightly higher amplitude for drops
// Ndef(\drops).xset(\amp, 0.25); // Revert
Ndef(\drops).set(\wet11, 0.4); // Subtle splash/drip echo
// Ndef(\drops).set(\wet11, 0); // Revert

Ndef(\rainNoise).quant = 1;
Ndef(\rainNoise)[1] = \set -> Pbindef(\rainNoiseSeq); // Start rainNoise cutoff evolution

Ndef(\drops).quant = 1;
Ndef(\drops)[1] = \set -> Pbindef(\dropSeq); // Start raindrop sequence
)

// --- Section 2: Emerging Light (Transition after ~1.5 - 2 minutes) ---
// Execute these lines to transition to Section 2
(
// Rain transformation: filter cutoff continues to rise, amplitude slightly decreases
Pbindef(\rainNoiseSeq, \filterFreq, Pn(Pseg(1000, 3000, 90, \lin), inf)); // Continue raising cutoff over 90s
// Pbindef(\rainNoiseSeq, \filterFreq, Pn(Pseg(200, 1000, 60, \lin), inf)); // Revert
Ndef(\rainNoise).xset(\amp, 0.08); // Slight amplitude reduction
// Ndef(\rainNoise).xset(\amp, 0.1); // Revert

// Drops evolution: more regular timing, softer character, lower amplitude
Pbindef(\dropSeq, \dur, Pn(Pwrand([1.5, 1, 0.75], [0.4, 0.4, 0.2], inf), inf)); // More regular rhythm
// Pbindef(\dropSeq, \dur, Pn(Pwrand([2, 1, 0.5], [0.5, 0.3, 0.2], inf), inf)); // Revert
Ndef(\drops).xset(\amp, 0.15); // Lower amplitude
// Ndef(\drops).xset(\amp, 0.25); // Revert

// Introduction of Chimes: soft melodic line
Ndef(\chimes).xset(\amp, 0.05); // Start very quietly
// Ndef(\chimes).xset(\amp, 0); // Revert (to silence)
Ndef(\chimes).set(\wet10, 0.6); // Sparkling reverb
// Ndef(\chimes).set(\wet10, 0); // Revert
Ndef(\chimes).set(\wet11, 0.5); // Shimmering echoes
// Ndef(\chimes).set(\wet11, 0); // Revert

Ndef(\chimes).quant = 1;
Ndef(\chimes)[1] = \set -> Pbindef(\chimeSeq); // Start chime melody
)

// --- Section 3: Easter Bells & Rain (Open-Ended Loop) (Transition after ~1.5 minutes) ---
// Execute these lines to transition to Section 3
(
// Fade out Chimes and introduce Bells and BassPad
Pbindef(\chimeSeq).stop; // Stop chime melody
Ndef(\chimes).clear(4); // Fade out chimes gracefully over 4 seconds

Ndef(\bells).xset(\amp, 0.3); // Overall amplitude for main bells
// Ndef(\bells).xset(\amp, 0); // Revert (to silence)
Ndef(\bells).set(\wet10, 0.8); // Cathedral-like reverb
// Ndef(\bells).set(\wet10, 0); // Revert
Ndef(\bells).set(\wet11, 0.6); // Lush, evolving echoes
// Ndef(\bells).set(\wet11, 0); // Revert
Ndef(\bells).quant = 1;
Ndef(\bells)[1] = \set -> Pbindef(\bellSeq); // Start bell chord progressions

Ndef(\bassPad).xset(\amp, 0.1); // Subtle background bass
// Ndef(\bassPad).xset(\amp, 0); // Revert (to silence)
Ndef(\bassPad).set(\wet10, 0.5); // Depth reverb for bass
// Ndef(\bassPad).set(\wet10, 0); // Revert
Ndef(\bassPad).quant = 1;
Ndef(\bassPad)[1] = \set -> Pbindef(\bassPadSeq); // Start bass pad foundation

// Rain persistence: shimmering drone, recedes further
Pbindef(\rainNoiseSeq).stop; // Stop filterFreq pattern for static value
Ndef(\rainNoise).xset(\filterFreq, 4000); // Sustained brighter filter cutoff
// Ndef(\rainNoise).xset(\filterFreq, 3000); // Revert (if rainNoiseSeq had finished at 3000)
Ndef(\rainNoise).xset(\amp, 0.05); // Recedes further, acts as a drone
// Ndef(\rainNoise).xset(\amp, 0.08); // Revert

// Rhythmic drops: more defined, subtle movement
Pbindef(\dropSeq, \dur, Pn(Pwrand([1, 0.75, 0.5], [0.3, 0.4, 0.3], inf), inf)); // Slightly more rhythmic
// Pbindef(\dropSeq, \dur, Pn(Pwrand([1.5, 1, 0.75], [0.4, 0.4, 0.2], inf), inf)); // Revert
Ndef(\drops).xset(\amp, 0.1); // Maintain subtle presence
// Ndef(\drops).xset(\amp, 0.15); // Revert
)

(
// --- RAINING EASTER INSTRUMENTS ---
// Rain Noise (Atmosphere)
Ndef(\rainNoise).clear;
Ndef(\rainNoise, {
	|freq=200, rq=0.1, amp=0.1, pan=0|
	var sig;
	sig = PinkNoise.ar();
	sig = RLPF.ar(sig, freq, rq);
	Pan2.ar(sig * amp, pan);
}).play;

// Rain Drops (Percussive elements)
Ndef(\drops).clear;
Ndef(\drops, {
	|freq=1000, amp=0.25, pan=0, t_trig=1, sustain=0.05, rq=0.1, atk=0.001|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, sustain), t_trig);
	sig = WhiteNoise.ar();
	sig = RLPF.ar(sig, freq, rq);
	Pan2.ar(sig * env * amp, pan);
}).play;

// Chimes (Delicate Bell-like Tones - FM based)
Ndef(\chimes).clear;
Ndef(\chimes, {
	|freq=440, amp=0.0, t_trig=1, modRatio=2.0, modIndex=1.0, atk=0.001, rel=0.5|
	var env, mod, car, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	mod = SinOsc.ar(freq * modRatio);
	car = SinOsc.ar(freq + (mod * freq * modIndex));
	Pan2.ar(car * env * amp, 0);
}).play;

// Bells (Rich, Resonant Bell Sounds - Layered SinOsc)
Ndef(\bells).clear;
Ndef(\bells, {
	|freq=440, amp=0.0, t_trig=1, atk=0.1, rel=3.0, detune=0.005, lfoRate=0.1|
	var env, sig, partials, ratios, amps;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);

	// Bell partials and amplitudes (can be fine-tuned)
	ratios = #[1.0, 1.5, 2.0, 2.7, 3.0, 3.5, 4.0];
	amps = #[1.0, 0.7, 0.5, 0.4, 0.3, 0.2, 0.1];

	// Create multiple detuned sinoscs
	partials = ratios.collect { |ratio, i|
		var f_offset = LFTri.kr(lfoRate + (i * 0.01)).range(1, 1 + detune); // subtle LFO on detune
		SinOsc.ar(freq * ratio * f_offset) * amps.at(i);
	};

	sig = Splay.ar(partials);
	sig = (sig * env * amp); // Overall amp with envelope
	Pan2.ar(sig, 0); // pan is always 0, splay handles spread
}).play;

// Bass Pad (Low-Frequency Harmonic Foundation)
Ndef(\bassPad).clear;
Ndef(\bassPad, {
	|freq=40, amp=0.0, t_trig=1, atk=2.0, sus=3.0, rel=5.0, lpfFreq=500, lpfRQ=0.5|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 0.8, 0], [atk, sus, rel]), t_trig);
	sig = Saw.ar([freq, freq * 1.005]); // Slightly detuned saws
	sig = RLPF.ar(sig, lpfFreq, lpfRQ);
	sig = sig * env * amp;
	sig ! 2; // Stereo output
}).play;
)

// --- RAINING EASTER EFFECTS ---
(
// Rain Noise effects (Index 10: Reverb)
Ndef(\rainNoise)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.2) }; // wetness 1 for internal mix
Ndef(\rainNoise).set(\wet10, 0);

// Rain Drops effects (Index 11: Delay)
Ndef(\drops)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.05, 1.0) }; // Delay time 0.05s, feedback 1.0s
Ndef(\drops).set(\wet11, 0);

// Chimes effects (Index 10: Reverb, Index 11: Delay)
Ndef(\chimes)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) };
Ndef(\chimes).set(\wet10, 0);
Ndef(\chimes)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.3, 3.0) }; // Delay time 0.3s, feedback 3.0s
Ndef(\chimes).set(\wet11, 0);

// Bells effects (Index 10: Reverb, Index 11: Delay)
Ndef(\bells)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.9, 0.8) };
Ndef(\bells).set(\wet10, 0);
Ndef(\bells)[11] = \filter -> { |in| CombL.ar(in, 1.0, 0.8, 5.0) }; // Delay time 0.8s, feedback 5.0s
Ndef(\bells).set(\wet11, 0);

// Bass Pad effects (Index 10: Reverb)
Ndef(\bassPad)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.3) };
Ndef(\bassPad).set(\wet10, 0);
)

// --- RAINING EASTER SEQUENCES ---
(
// Pbindef for Rain Noise filter sweep
Pbindef(\rainNoiseSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\rainNoise).nodeID }),
	\freq, Pn(Pseg([200, 1000], [60], \lin), inf), // Initial sweep for Section 1
	\rq, 0.1,
	\args, #[\freq, \rq]
);
Ndef(\rainNoise).quant = 1;

// Pbindef for Rain Drops
Pbindef(\dropSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\drops).nodeID }),
	\dur, Pn(Pwrand([2, 1, 0.5], [0.5, 0.3, 0.2], 8), inf), // Section 1 timing
	\freq, Pn(Pwhite(500, 2000, 16), inf),
	\pan, Pn(Pwhite(-0.8, 0.8, 16), inf),
	\t_trig, 1,
	\amp, 0.25, // Initial amplitude for drops
	\args, #[\dur, \freq, \pan, \t_trig, \amp]
);
Ndef(\drops).quant = 1;

// Pbindef for Chimes
Pbindef(\chimeSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\chimes).nodeID }),
	\dur, Pn(Pwrand([1, 0.75, 0.5], [0.6, 0.3, 0.1], 8), inf), // Section 2 timing
	\freq, Pn(Pseq([60, 64, 67, 72].midicps, inf), inf),
	\amp, 0.2, // Chimes overall amp, sequence will set this
	\t_trig, 1,
	\modRatio, 2.0,
	\modIndex, 1.0,
	\args, #[\dur, \freq, \amp, \t_trig, \modRatio, \modIndex]
);
Ndef(\chimes).quant = 1;

// Pbindef for Bells
Pbindef(\bellSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\bells).nodeID }),
	\dur, Pn(Pwrand([4, 2, 1], [0.6, 0.3, 0.1], 8), inf), // Section 3 timing
	\freq, Pn(Pseq([Ptuple([60, 67, 72]), Ptuple([58, 65, 70]), Ptuple([62, 69, 74])].midicps, inf), inf),
	\amp, 0.3, // Bells overall amplitude
	\t_trig, 1,
	\detune, 0.005,
	\lfoRate, 0.1,
	\args, #[\dur, \freq, \amp, \t_trig, \detune, \lfoRate]
);
Ndef(\bells).quant = 1;

// Pbindef for Bass Pad
Pbindef(\bassPadSeq,
	\type, \set,
	\id, Pfunc({ Ndef(\bassPad).nodeID }),
	\dur, 8, // Section 3 timing
	\freq, Pn(Pseq([36, 34, 38].midicps, inf), inf),
	\amp, 0.1, // Bass Pad overall amplitude
	\t_trig, 1,
	\atk, 2.0,
	\sus, 3.0,
	\rel, 5.0,
	\lpfFreq, 500,
	\lpfRQ, 0.5,
	\args, #[\dur, \freq, \amp, \t_trig, \atk, \sus, \rel, \lpfFreq, \lpfRQ]
);
Ndef(\bassPad).quant = 1;
)

// --- RAINING EASTER LIVE CODING SECTIONS ---

// Set Ndef fade times for smooth transitions
(
Ndef(\rainNoise).fadeTime = 2;
Ndef(\drops).fadeTime = 1;
Ndef(\chimes).fadeTime = 2;
Ndef(\bells).fadeTime = 3;
Ndef(\bassPad).fadeTime = 4;
)

// --- SECTION 1: Rainy Intro (Initial setup & gradual introduction) ---
(
"--- Section 1: Rainy Intro ---".postln;

// Rain Noise: Starts quietly, heavily reverbed
Ndef(\rainNoise).xset(\amp, 0.1, \freq, 200, \rq, 0.1);
Ndef(\rainNoise).xset(\wet10, 0.8); // Very wet reverb
Ndef(\rainNoise)[1] = \set -> Pbindef(\rainNoiseSeq); // Start filter sweep for rain
// Ndef(\rainNoise).xset(\amp, 0.1, \freq, 200, \rq, 0.1); // Revert to previous state
// Ndef(\rainNoise).xset(\wet10, 0); // Revert to previous state

// Rain Drops: Sparse, irregular clicks with subtle delay
Ndef(\drops).xset(\amp, 0.25);
Ndef(\drops).xset(\wet11, 0.4); // Subtle splash delay
Ndef(\drops)[1] = \set -> Pbindef(\dropSeq);
// Ndef(\drops).xset(\amp, 0); // Revert to previous state
// Ndef(\drops).xset(\wet11, 0); // Revert to previous state
)

// --- SECTION 2: Emerging Light (Chimes introduced, rain evolves) ---
// This block would typically be evaluated ~1.5 - 2 minutes into the piece.
(
"--- Section 2: Emerging Light ---".postln;

// Rain Noise: Continue filter sweep, subtle amplitude reduction
Pbindef(\rainNoiseSeq).set(\freq, Pn(Pseg([1000, 3000], [90], \lin), inf)); // Continue raising cutoff over 90 seconds
// Pbindef(\rainNoiseSeq).set(\freq, Pn(Pseg([200, 1000], [60], \lin), inf)); // Revert to initial part of sweep.
Ndef(\rainNoise).xset(\amp, 0.08); // Slight amplitude reduction
// Ndef(\rainNoise).xset(\amp, 0.1); // Revert amplitude

// Rain Drops: More regular, slightly softer amplitude
Pbindef(\dropSeq).set(\dur, Pn(Pwrand([1.5, 1, 0.75], [0.4, 0.4, 0.2], 8), inf), \amp, 0.15); // More regular, less amplitude
// Pbindef(\dropSeq).set(\dur, Pn(Pwrand([2, 1, 0.5], [0.5, 0.3, 0.2], 8), inf), \amp, 0.25); // Revert timing and amplitude

// Chimes: Introduced softly with sparkling reverb and shimmering delay
Ndef(\chimes).xset(\amp, 0.05); // Start very quietly
Ndef(\chimes).xset(\wet10, 0.6, \wet11, 0.5); // Reverb and delay
Ndef(\chimes)[1] = \set -> Pbindef(\chimeSeq);
// Ndef(\chimes).xset(\amp, 0); // Revert to previous state
// Ndef(\chimes).xset(\wet10, 0, \wet11, 0); // Revert to previous state
)

// --- SECTION 3: Easter Bells & Rain (Main loop, open-ended) ---
// This block would typically be evaluated ~3 - 3.5 minutes into the piece.
(
"--- Section 3: Easter Bells & Rain ---".postln;

// Chimes: Fade out
Ndef(\chimes).xset(\amp, 0.0); // Chimes fade out
// Ndef(\chimes).xset(\amp, 0.05); // Revert chimes amplitude

// Bells: Introduced as dominant, resonant element with cathedral-like reverb
Ndef(\bells).xset(\amp, 0.3); // Set overall amplitude for bells
Ndef(\bells).xset(\wet10, 0.8, \wet11, 0.6); // Long reverb, lush delay
Ndef(\bells)[1] = \set -> Pbindef(\bellSeq);
// Ndef(\bells).xset(\amp, 0); // Revert to previous state
// Ndef(\bells).xset(\wet10, 0, \wet11, 0); // Revert to previous state

// Bass Pad: Deep, warm harmonic foundation
Ndef(\bassPad).xset(\amp, 0.1); // Subtle background bass
Ndef(\bassPad).xset(\wet10, 0.5); // Depth from reverb
Ndef(\bassPad)[1] = \set -> Pbindef(\bassPadSeq);
// Ndef(\bassPad).xset(\amp, 0); // Revert to previous state
// Ndef(\bassPad).xset(\wet10, 0); // Revert to previous state

// Rain Noise: Becomes an ethereal, high-frequency drone. Stop sweep and set fixed values.
Pbindef(\rainNoiseSeq).stop; // Stop the filter sweep
// Pbindef(\rainNoiseSeq).play; // Revert by restarting the sweep (will continue from its last state)
Ndef(\rainNoise).xset(\freq, 4000, \amp, 0.05, \rq, 0.2); // Set sustained brighter filter cutoff, lower amp, slight resonance
// Ndef(\rainNoise).xset(\freq, 3000, \amp, 0.08, \rq, 0.1); // Revert to section 2 rainNoise state

// Rain Drops: More rhythmic, subtle texture
Pbindef(\dropSeq).set(\dur, Pn(Pwrand([1, 0.75, 0.5], [0.3, 0.4, 0.3], 8), inf), \amp, 0.1); // More rhythmic, lower amp
// Pbindef(\dropSeq).set(\dur, Pn(Pwrand([1.5, 1, 0.75], [0.4, 0.4, 0.2], 8), inf), \amp, 0.15); // Revert drops timing and amplitude
)

// --- THE WHIM AND THE WALTZ INSTRUMENTS ---
(
Ndef(\whimPluck).clear;
Ndef(\whimPluck, {
	|freq=400, amp=0.2, t_trig=1, modIndex=2, modRatio=2.5, pan=0|
	var env, mod, sig;
	// Delicate, short percussive envelope
	env = EnvGen.ar(Env.perc(0.005, 0.15), t_trig);
	// Bright FM synthesis for spontaneous high-frequency energy
	mod = SinOsc.ar(freq * modRatio) * modIndex * freq;
	sig = SinOsc.ar(freq + mod);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\grandPad).clear;
Ndef(\grandPad, {
	|freq=#[200, 200, 200], amp=0.0, t_trig=1, cutoff=800|
	var env, sig;
	// Lush, long envelope triggered strictly by the sequence
	env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 4, 2]), t_trig);
	// Thick, detuned sawtooth bed (array multiplication creates 9 oscillators total for chords)
	sig = Saw.ar(freq) + Saw.ar(freq * 1.005) + Saw.ar(freq * 0.995);
	// Carve out highs so the pluck can slice through
	sig = RLPF.ar(sig, cutoff, 0.4);
	Splay.ar(sig) * env * amp;
}).play;
)

// --- THE WHIM AND THE WALTZ EFFECTS ---
(
// whimPluck Reverb (Index 10)
Ndef(\whimPluck)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.2) };
Ndef(\whimPluck).set(\wet10, 0.2); // Subtle base space

// whimPluck Delay (Index 11)
Ndef(\whimPluck)[11] = \filter -> { |in| CombC.ar(in, 1, \delayTime.kr(0.2), 2.5) };
Ndef(\whimPluck).set(\wet11, 0);

// grandPad Reverb (Index 10)
Ndef(\grandPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8) }; // Mono-summed to avoid phasing
Ndef(\grandPad).set(\wet10, 0);

// grandPad Chorus/Modulation (Index 11)
Ndef(\grandPad)[11] = \filter -> { |in| 
	var chorus = DelayC.ar(in, 0.05, SinOsc.kr([0.3, 0.4]).range(0.005, 0.015));
	in * 0.7 + (chorus * 0.5);
};
Ndef(\grandPad).set(\wet11, 1); // Permanent widening
)

// --- THE WHIM AND THE WALTZ SEQUENCES ---
(
Pbindef(\whimSeq,
	\dur, Pwhite(0.1, 0.6, inf), // Erratic, spontaneous durations
	\freq, Pexprand(600, 2000, inf), // Scattered high pitches
	\t_trig, 1
);
Ndef(\whimPluck).quant = 1;
Ndef(\whimPluck)[1] = \set -> Pbindef(\whimSeq);

Pbindef(\padSeq,
	\dur, 8,
	\scale, Scale.harmonicMinor,
	// Sweeping minor-to-majorish chord progressions
	\degree, Pseq([[0, 2, 4], [3, 5, 7], [-1, 1, 3], [2, 4, 6]], inf),
	\t_trig, 1
);
Ndef(\grandPad).quant = 1;
Ndef(\grandPad)[1] = \set -> Pbindef(\padSeq);
)

// --- THE WHIM AND THE WALTZ LIVE CODING TWEAKS ---

// 1. THE SPONTANEOUS APPLICATION (Development)
Ndef(\whimPluck).xset(\wet11, 0.4); // Delay gradually begins to overlap the chaotic random plucks
// Ndef(\whimPluck).xset(\wet11, 0); // Revert delay to dry

// 2. THE ACCEPTANCE LETTER (Radical Contrast)
// Execute these simultaneously: the pad violently fades in while the pluck is forced into discipline
(
Ndef(\grandPad).fadeTime = 2;
Ndef(\grandPad).xset(\amp, 0.3); // Grand pad floods the empty low-end
Pbindef(\whimSeq, \dur, 0.25, \freq, Pseq([800, 1200, 1000, 1500, 900, 1800], inf)); // Clamped to strict 16th-note arpeggios
)
// Ndef(\grandPad).xset(\amp, 0); // Revert pad volume
// Pbindef(\whimSeq, \dur, Pwhite(0.1, 0.6, inf), \freq, Pexprand(600, 2000, inf)); // Revert to scattered whim

// 3. THE CHOREOGRAPHER'S WALTZ (Static Loop)
(
Pbindef(\whimSeq, \dur, 1/3); // Whim pluck rhythm shifted to a waltz-like triplet
Ndef(\grandPad).xset(\wet10, 0.8); // GVerb pushes the pad into a continuous cinematic blur
Ndef(\whimPluck).xset(\delayTime, 0.375, \wet11, 0.65); // Delay locks into a dancing dotted rhythm
)
// Pbindef(\whimSeq, \dur, 0.25); // Revert whim to 16th notes
// Ndef(\grandPad).xset(\wet10, 0); // Revert pad reverb to dry
// Ndef(\whimPluck).xset(\delayTime, 0.2, \wet11, 0.4); // Revert pluck delay timing


// --- OPEN-ENDED CONCLUSION ---
// The piece intentionally remains in this driving, hypnotic loop (The Choreographer's Waltz)
// for continuous live-coding expansion. 
// However, if an explicit fade-out is required, uncomment and execute the block below:

/*
(
Pbindef(\whimSeq).stop;
Pbindef(\padSeq).stop;
Ndef(\whimPluck).fadeTime = 6;
Ndef(\grandPad).fadeTime = 6;
Ndef(\whimPluck).clear(6);
Ndef(\grandPad).clear(6);
)
*/