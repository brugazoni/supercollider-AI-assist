// 1. Boot and Setup
p = ProxySpace.push(s.boot);
p.fadeTime = 2; // Smooth crossfades
TempoClock.default.tempo = 120/60;

// --- SYNTH DEFS ---
// FIX: I renamed 'dur' to 'rel' (release) to avoid conflict with Pbind's timing system.
(
SynthDef(\kick, { |out=0, freq=50, amp=0.8, rel=0.2, gate=1|
    var env = EnvGen.kr(Env.perc(0.001, rel, 1, (-4)), gate, doneAction: 2);
    var sig = SinOsc.ar(freq * (1 + (env * 0.5))) * env * amp;
    sig = LPF.ar(sig, 2000 * env.linlin(0, 1, 0.5, 1));
    Out.ar(out, Pan2.ar(sig));
}).add;

SynthDef(\click, { |out=0, freq=3000, amp=0.5, rel=0.05, gate=1, pan=0|
    var env = EnvGen.kr(Env.perc(0.001, rel, 1, (-8)), gate, doneAction: 2);
    var sig = WhiteNoise.ar(amp * env);
    sig = BPF.ar(sig, freq, 0.5);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\resoHit, { |out=0, freq=800, amp=0.3, decay=1.0, gate=1, pan=0|
    var env = EnvGen.kr(Env.perc(0.001, decay, 1, (-4)), gate, doneAction: 2);
    var exciter = WhiteNoise.ar(env) * EnvGen.ar(Env.perc(0.001, 0.01));
    var sig = Ringz.ar(exciter, freq, decay);
    sig = HPF.ar(sig, 200) * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --- MOVEMENT 1 ---
(
// 1. Define the source
~kick_m1 = Pdef(\kick_m1, Pbind(
    \instrument, \kick,
    \midinote, Pseq([36], inf),
    \dur, 1,
    \rel, 0.2, // Maps to the new SynthDef argument
    \amp, 0.5,
    \legato, 0.1
));
// 2. Play the proxy (Monitor audio)
~kick_m1.play;

~click_m1 = Pdef(\click_m1, Pbind(
    \instrument, \click,
    \dur, 0.5,
    \amp, Pseq([0.1, 0.0, 0.15, 0.0], inf),
    \pan, Pseq([-0.5, 0.0, 0.5, 0.0], inf),
    \rel, 0.05,
    \freq, 4000
));
~click_m1.play;
)

// --- MOVEMENT 2 ---
// Transition: Clear previous, start new
(
~kick_m1.clear(2);
~click_m1.clear(2);

~kick_m2 = Pdef(\kick_m2, Pbind(
    \instrument, \kick,
    \midinote, Pseq([36, 40, 36, 38], inf),
    \dur, Pseq([0.5, 0.5, 1, 0.5], inf),
    \rel, 0.3,
    \amp, 0.6
));
~kick_m2.play;

~reso_m2 = Pdef(\reso_m2, Pbind(
    \instrument, \resoHit,
    \midinote, Pxrand([60, 64, 67, 72], inf),
    \dur, Pseq([0.25, 0.25, 0.5, 0.25], inf),
    \decay, Pseq([0.8, 0.6, 1.2, 0.7], inf),
    \amp, Pseq([0.2, 0.1, 0.3, 0.1], inf),
    \pan, Pwhite(-0.8, 0.8),
    \legato, 0.01
));
~reso_m2.play;

~click_accent_m2 = Pdef(\click_accent_m2, Pbind(
    \instrument, \click,
    \dur, Pseq([1, 0.5, 0.5, 1, 0.5, 0.5], inf),
    \amp, Pseq([0.2, 0, 0.1, 0.2, 0, 0.1], inf),
    \freq, Pxrand([5000, 6000, 7000], inf),
    \rel, 0.05,
    \pan, Pseq([0.7, 0, -0.7, 0, 0.7, 0], inf)
));
~click_accent_m2.play;
)

// --- MOVEMENT 3 (Auto-Ending) ---
(
~kick_m2.clear(2);
~reso_m2.clear(2);
~click_accent_m2.clear(2);
TempoClock.default.tempo = 40/60;

~kick_m3 = Pdef(\kick_m3, Pbind(
    \instrument, \kick,
    \midinote, Pseq([36, 36, 38, 36, 36, 40, 36, 38], 4), // Stops after 4 cycles
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], inf),
    \amp, 0.7,
    \rel, 0.2,
    \legato, 0.05
));
~kick_m3.play;

~reso_m3_a = Pdef(\reso_m3_a, Pbind(
    \instrument, \resoHit,
    \midinote, Pseq([72, 75, 79, 75, 72, 70, 67, 70], inf),
    \dur, 0.125,
    \decay, 0.3,
    \amp, 0.2,
    \pan, Pseq([-0.8, 0.8], inf)
));
~reso_m3_a.play;

~click_m3_amp = Pdefn(\click_m3_amp, Pseq([
    Pseries(0.1, 0.05, 12),
    Pseries(0.7, -0.05, 10),
    Pseq([0.2, 0.8], 5),
    Pseq([0.0], 1)
], 1));

~click_m3 = Pdef(\click_m3, Pbind(
    \instrument, \click,
    \dur, Pseq([0.25, 0.5, 0.25, 0.5], inf),
    \amp, ~click_m3_amp,
    \freq, Pseq([6000, 7000, 8000, 7000], inf),
    \rel, 0.05,
    \pan, Pseq([0.5, -0.5], inf)
));
~click_m3.play;

// Define Final Hit (Do not play yet)
~finalHit = Pdef(\finalHit, Pbind(
    \instrument, \resoHit,
    \midinote, Pseq([[60, 64, 67]], 1),
    \dur, 4,
    \decay, 4,
    \amp, 0.8,
    \legato, 0.1
));

// CALLBACK LOGIC
Pdef(\kick_m3).onEnd = {
    "Movement 3 (Kick) Ended. Triggering Final Hit.".postln;
    ~reso_m3_a.clear(1);
    ~click_m3.clear(1);
    ~finalHit.play; // Play the final hit here
};

Pdef(\finalHit).onEnd = {
    "Final Hit Ended. Cleaning up.".postln;
    p.clear;
    TempoClock.default.tempo = 120/60;
};
)