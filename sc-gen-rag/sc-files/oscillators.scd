

(
// Ensure ProxySpace and Ndef system are initialized
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Oscillator Study Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;

	NdefMixer(s); // Optional, but good practice for a master mix
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = LeakDC.ar(in);
		Limiter.ar(sig, 0.95, 0.01);
	});
	"System Ready.".postln;
});
)


// --- INSTRUMENTS ---
(
Ndef(\fmSynth).clear;
Ndef(\fmSynth, {
	|freq=60, modRatio=1.5, modIndex=0.5, amp=0.4, atk=0.1, rel=1.5, t_trig=1|
	var env, mod, car, sig;
	env = EnvGen.ar(Env([0, 1, 0], [atk, rel], \sin), t_trig); // Smooth sine attack/release
	mod = SinOsc.ar(freq * modRatio) * (freq * modIndex); // Modulator frequency and depth
	car = SinOsc.ar(freq + mod); // Carrier
	sig = Pan2.ar(car * env * amp, Rand(-0.5, 0.5));
}).play;

Ndef(\kick).clear;
Ndef(\kick, {
	|freq=40, clickFreq=120, amp=0.8, atk=0.005, rel=0.2, t_trig=1|
	var env, pitchEnv, sub, click, sig;
	env = EnvGen.ar(Env.perc(atk, rel, curve: -4), t_trig);
	pitchEnv = EnvGen.ar(Env([freq * 2, freq * 0.5, freq * 0.1], [atk, rel * 0.5, rel * 0.5], \exp), t_trig); // Descending pitch
	sub = SinOsc.ar(pitchEnv);
	click = WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(atk, atk * 2), t_trig);
	sig = LPF.ar(sub + click, freq * 3); // Low-pass to clean up click
	Pan2.ar(sig * env * amp, 0); // Mono, sub-bass
}).play;

Ndef(\sawLead).clear;
Ndef(\sawLead, {
	|freq=120, amp=0.0, atk=0.2, sus=0.5, rel=1.0, lpfFreq=500, lpfRq=0.5, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel], [-4, 0, -4]), t_trig); // ADSR-like
	sig = Saw.ar([freq, freq * 1.005]); // Slightly detuned for richness
	sig = RLPF.ar(sig, lpfFreq, lpfRq);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\pulseRhythm).clear;
Ndef(\pulseRhythm, {
	|freq=400, width=0.5, amp=0.0, atk=0.01, rel=0.1, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Pulse.ar(freq, width);
	Pan2.ar(sig * env * amp, pan);
}).play;
)

// --- EFFECTS ---
(
// --- fmSynth Effects ---
Ndef(\fmSynth)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.5) }; // Reverb (100% wet)
Ndef(\fmSynth).set(\wet10, 0);
Ndef(\fmSynth)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.15, 0.7) }; // Delay (100% wet)
Ndef(\fmSynth).set(\wet11, 0);
Ndef(\fmSynth)[12] = \filter -> { |in| (in * 2).tanh / 2 }; // Subtle Distortion
Ndef(\fmSynth).set(\wet12, 0);

// --- kick Effects ---
Ndef(\kick)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.3) }; // Reverb
Ndef(\kick).set(\wet10, 0);
Ndef(\kick)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.2, 1.2) }; // Longer Delay
Ndef(\kick).set(\wet11, 0);

// --- sawLead Effects ---
Ndef(\sawLead)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.4) }; // Reverb
Ndef(\sawLead).set(\wet10, 0);
Ndef(\sawLead)[11] = \filter -> { |in| CombL.ar(in, 0.3, 0.1, 1.0) }; // Delay
Ndef(\sawLead).set(\wet11, 0);
Ndef(\sawLead)[12] = \filter -> { |in| (in * 3).clip2(0.8) }; // Light Clipping
Ndef(\sawLead).set(\wet12, 0);

// --- pulseRhythm Effects ---
Ndef(\pulseRhythm)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.5, 0.2) }; // Reverb
Ndef(\pulseRhythm).set(\wet10, 0);
Ndef(\pulseRhythm)[12] = \filter -> { |in| (in * 5).fold2(0.5) }; // Distortion
Ndef(\pulseRhythm).set(\wet12, 0);
)

// --- SEQUENCES ---
(
// --- fmSynth Sequence ---
Pbindef(\fmSeq,
    \instrument, \fmSynth,
    \degree, Pseq([0, 2, 4, 7, 5, 2, 0, (-3)], inf),
    \scale, Scale.minor,
    \dur, 2,
    \amp, 0.4,
    \t_trig, 1
);
Ndef(\fmSynth).quant = 1;
Ndef(\fmSynth)[1] = \set -> Pbindef(\fmSeq);

// --- kick Sequence ---
Pbindef(\kickSeq,
    \instrument, \kick,
    \freq, 30,
    \dur, 4, // Very slow pulse
    \amp, 0.05, // Very low volume
    \t_trig, 1
);
Ndef(\kick).quant = 1;
Ndef(\kick)[1] = \set -> Pbindef(\kickSeq);

// --- sawLead Sequence (initially inactive) ---
Pbindef(\sawSeq,
    \instrument, \sawLead,
    \degree, Pseq([7, 5, 4, 2], inf),
    \scale, Scale.major,
    \dur, 4,
    \legato, 3.5,
    \amp, 0.0, // Start silent
    \t_trig, 1
);
Ndef(\sawLead).quant = 1;
Ndef(\sawLead)[1] = \set -> Pbindef(\sawSeq);

// --- pulseRhythm Sequence (initially inactive) ---
Pbindef(\pulseSeq,
    \instrument, \pulseRhythm,
    \freq, Pseq([400, 800, 600, 1000], inf),
    \width, 0.3,
    \dur, 0.25,
    \amp, 0.0, // Start silent
    \t_trig, 1
);
Ndef(\pulseRhythm).quant = 1;
Ndef(\pulseRhythm)[1] = \set -> Pbindef(\pulseSeq);
)


// --- 1. Introduction: Ethereal FM Pulse (Duration: ~30-45 seconds) ---
(
Ndef(\fmSynth).fadeTime = 2;
Ndef(\kick).fadeTime = 2;
Pbindef(\fmSeq).play;
Pbindef(\kickSeq).play;

// fmSynth: low freq, gentle FM, long decay, sparse arpeggio
Ndef(\fmSynth).xset(\modIndex, 0.8, \atk, 0.5, \rel, 3.0); // Gentle FM, longer envelope
// Ndef(\fmSynth).xset(\modIndex, 0.5, \atk, 0.1, \rel, 1.5); // Revert

// kick: sub-bass, very slow
Pbindef(\kickSeq, \freq, 35, \dur, 4, \amp, 0.08); // Steady, very subtle
// Pbindef(\kickSeq, \freq, 30, \dur, 4, \amp, 0.05); // Revert

// fmSynth effects: subtle, long reverb and rhythmic delay
Ndef(\fmSynth).xset(\wet10, 0.5, \wet11, 0.3);
// Ndef(\fmSynth).xset(\wet10, 0, \wet11, 0); // Revert
)

// --- 2. Section A: FM Development & Expansion (Duration: ~60 seconds) ---
(
// fmSynth: modIndex increases, brighter timbre
Ndef(\fmSynth).xset(\modIndex, 2.0); // Brighter, more complex harmonics
// Ndef(\fmSynth).xset(\modIndex, 0.8); // Revert

// fmSynth: freq range expands, rhythmic density increases, decay shortens
Pbindef(\fmSeq,
    \degree, Pseq([0, 4, 7, 12, 11, 7, 4, 0], inf), // Wider range
    \dur, 1.5, // Slightly faster
    \rel, 2.0 // Shorter release for more definition
);
// Pbindef(\fmSeq, \degree, Pseq([0, 2, 4, 7, 5, 2, 0, (-3)], inf), \dur, 2, \rel, 3.0); // Revert

// kick: rhythm subtly increases complexity
Pbindef(\kickSeq, \dur, Pseq([4, 2, 4, 2], inf), \amp, 0.1); // Occasional off-beat hit
// Pbindef(\kickSeq, \dur, 4, \amp, 0.08); // Revert

// fmSynth effects: subtle increase in reverb and delay
Ndef(\fmSynth).xset(\wet10, 0.6, \wet11, 0.4);
// Ndef(\fmSynth).xset(\wet10, 0.5, \wet11, 0.3); // Revert
)

// --- 3. Section B: Sawtooth Lead Introduction (Duration: ~90 seconds) ---
(
Ndef(\sawLead).fadeTime = 3;
Pbindef(\sawSeq).play;

// sawLead: introduce, sustained, filtered, low in mix
Pbindef(\sawSeq, \amp, 0.3, \dur, 3.0, \legato, 2.8); // Bring in saw lead, sustained
// Pbindef(\sawSeq, \amp, 0.0); // Revert

// sawLead filter: slowly opens (lpfFreq sweeps upwards)
Ndef(\sawLead).xset(\lpfFreq, 3000, \lpfRq, 0.3, \pan, (-0.4)); // Filter opening, some pan
// Ndef(\sawLead).xset(\lpfFreq, 500, \lpfRq, 0.5, \pan, 0); // Revert

// sawLead effects: short, bright reverb added
Ndef(\sawLead).xset(\wet10, 0.4);
// Ndef(\sawLead).xset(\wet10, 0); // Revert

// fmSynth: pattern simplifies/syncopates, recedes slightly
Pbindef(\fmSeq,
    \degree, Pseq([0, 7, 0, 4], inf),
    \dur, 2, // Slower, more spacious
    \amp, 0.3 // Recede slightly
);
// Pbindef(\fmSeq, \degree, Pseq([0, 4, 7, 12, 11, 7, 4, 0], inf), \dur, 1.5, \amp, 0.4); // Revert

// kick: more driving, consistent beat
Pbindef(\kickSeq, \dur, 1, \amp, 0.15); // Four-on-the-floor
// Pbindef(\kickSeq, \dur, Pseq([4, 2, 4, 2], inf), \amp, 0.1); // Revert
)

// --- 4. Section C: Pulse Rhythm & Harmonic Density (Duration: ~75 seconds) ---
(
Ndef(\pulseRhythm).fadeTime = 1;
Pbindef(\pulseSeq).play;

// pulseRhythm: introduce, fast, percussive
Pbindef(\pulseSeq, \amp, 0.2, \dur, 0.125, \pan, Pseq([0.5, (-0.5)], inf)); // Fast, aggressive pulse
// Pbindef(\pulseSeq, \amp, 0.0); // Revert

// pulseRhythm effects: subtle distortion
Ndef(\pulseRhythm).xset(\wet12, 0.5);
// Ndef(\pulseRhythm).xset(\wet12, 0); // Revert

// sawLead: filter opens fully, amp peaks
Ndef(\sawLead).xset(\lpfFreq, 8000, \amp, 0.6, \pan, 0.4); // Brightest timbre, peak amplitude
// Ndef(\sawLead).xset(\lpfFreq, 3000, \amp, 0.3, \pan, (-0.4)); // Revert

// fmSynth: modIndex increases again, shimmering quality
Ndef(\fmSynth).xset(\modIndex, 4.0, \rel, 1.0); // Bell-like sparkle
// Ndef(\fmSynth).xset(\modIndex, 2.0, \rel, 2.0); // Revert

// All Ndef's reverb swells slightly (applied to individual Ndefs for control)
Ndef(\fmSynth).xset(\wet10, 0.7);
Ndef(\sawLead).xset(\wet10, 0.6);
Ndef(\kick).xset(\wet10, 0.3);
Ndef(\pulseRhythm).xset(\wet10, 0.3);
// Ndef(\fmSynth).xset(\wet10, 0.6); Ndef(\sawLead).xset(\wet10, 0.4); Ndef(\kick).xset(\wet10, 0); Ndef(\pulseRhythm).xset(\wet10, 0); // Revert
)

// --- 5. Outro: Dissolution and Fade (Duration: ~60 seconds) ---
(
// --- pulseRhythm stops and fades ---
Pbindef(\pulseSeq).stop;
Ndef(\pulseRhythm).fadeTime = 2;
Ndef(\pulseRhythm).clear(2); // Clear after 2 seconds
// Pbindef(\pulseSeq).play; Ndef(\pulseRhythm).clear; // Revert

// --- kick stops and fades ---
0.5.wait; // Short pause
Pbindef(\kickSeq).stop;
Ndef(\kick).fadeTime = 3;
Ndef(\kick).clear(3); // Clear after 3 seconds
// Pbindef(\kickSeq).play; Ndef(\kick).clear; // Revert

// --- sawLead filter closes, amplitude decreases, pattern simplifies, then stops ---
2.0.wait; // Pause before fading sawLead
Ndef(\sawLead).xset(\lpfFreq, 200, \amp, 0.1, \pan, 0); // Filter closes, amplitude drops
Pbindef(\sawSeq, \degree, Pseq([0, 0, 0, 0], inf), \dur, 8, \legato, 7.5); // Very simple drone
// Ndef(\sawLead).xset(\lpfFreq, 8000, \amp, 0.6, \pan, 0.4); Pbindef(\sawSeq, \degree, Pseq([7, 5, 4, 2], inf), \dur, 3.0, \legato, 2.8); // Revert

3.0.wait; // Pause
Pbindef(\sawSeq).stop;
Ndef(\sawLead).fadeTime = 4;
Ndef(\sawLead).clear(4); // Clear after 4 seconds
// Pbindef(\sawSeq).play; Ndef(\sawLead).clear; // Revert

// --- fmSynth reverts, reverb/delay increase, then fades ---
5.0.wait; // Pause
Ndef(\fmSynth).xset(\modIndex, 0.1, \freq, 40, \rel, 5.0, \atk, 2.0); // Pure tone, very long release
Pbindef(\fmSeq, \degree, Pseq([0, (-7)], inf), \dur, 8); // Very sparse, low pattern
Ndef(\fmSynth).xset(\wet10, 0.9, \wet11, 0.7); // Max out reverb and delay
// Ndef(\fmSynth).xset(\modIndex, 4.0, \freq, 60, \rel, 1.0, \atk, 0.1); Pbindef(\fmSeq, \degree, Pseq([0, 7, 0, 4], inf), \dur, 2); Ndef(\fmSynth).xset(\wet10, 0.7, \wet11, 0.4); // Revert

10.0.wait; // Long pause to let it echo
Pbindef(\fmSeq).stop;
Ndef(\fmSynth).fadeTime = 8; // Very long fade out
Ndef(\fmSynth).clear(8); // Clear after 8 seconds
// Pbindef(\fmSeq).play; Ndef(\fmSynth).clear; // Revert

"Composition Ended.".postln;
)