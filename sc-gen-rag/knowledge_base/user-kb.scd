

// --- User Knowledge Entry [2026-03-26 20:29] ---
// test block file
(
Pbindef(\padSeq,
    \instrument, \pad,
    \degree, Pseq([0, 2, 4, 7, 5, 2, 0, 7], inf), // Simple harmonic changes
    \scale, Scale.minor,
    \dur, 1, // Faster note duration
    \legato, 0.7, // Shorter legato for more distinct notes
    \amp, 0.4,
    \atk, 0.5, // Shorter attack for faster notes
    \rel, 1.0, // Shorter release for faster notes
    \t_trig, 1
);
Ndef(\pad).quant = 1;
Ndef(\pad)[1] = \set -> Pbindef(\padSeq);
)


// --- User Knowledge Entry [2026-04-01 12:00] ---
// Instruments setup to emulate the Parker Solar Probe's mission.
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
