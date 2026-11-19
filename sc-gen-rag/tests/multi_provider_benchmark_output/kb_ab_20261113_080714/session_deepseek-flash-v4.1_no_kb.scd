// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-13T11:11:37.535514+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Antarctic storm drone - continuous low rumble
Ndef(\antarcticDrone, {
    var sig, wind, lfo;
    lfo = SinOsc.kr(0.05).range(0.2, 0.8);
    sig = SinOsc.ar(40) * 0.5 + SinOsc.ar(80) * 0.3 + SinOsc.ar(120) * 0.1;
    wind = LPF.ar(PinkNoise.ar(0.1), 200 + (lfo * 300));
    sig = sig + wind;
    sig = LeakDC.ar(sig);
    sig = sig * 0.3;
    Pan2.ar(sig, 0);
}).play;

// Map folding - triggered percussive noise bursts
Ndef(\mapFold, { |t_trig=0, freq=800, rq=0.1, amp=0.5, pan=0|
    var env, sig, click;
    env = EnvGen.ar(Env.perc(0.001, 0.15), t_trig);
    click = Decay2.ar(K2A.ar(t_trig), 0.0001, 0.01) * WhiteNoise.ar;
    sig = BPF.ar(WhiteNoise.ar, freq, rq) * env;
    sig = sig + (click * 0.5);
    sig = sig * amp;
    Pan2.ar(sig, pan);
}).play;

// Waiter frozen - glassy suspended tone
Ndef(\waiterGlass, {
    var sig, lfo1, lfo2;
    lfo1 = SinOsc.kr(0.03).range(0.1, 0.4);
    lfo2 = SinOsc.kr(0.07).range(0.99, 1.01);
    sig = SinOsc.ar(2000 * [1, 2.01, 3.03]) * [0.5, 0.3, 0.2];
    sig = Splay.ar(sig);
    sig = sig * lfo1;
    sig = DelayC.ar(sig, 0.1, SinOsc.kr(0.1).range(0.001, 0.01));
    sig * 0.2;
}).play;

// Weight of silence - very low rumble
Ndef(\silenceWeight, {
    var sig, lfo;
    lfo = SinOsc.kr(0.02).range(0.0, 0.3);
    sig = BrownNoise.ar(0.1);
    sig = LPF.ar(sig, 80);
    sig = sig * lfo;
    Pan2.ar(sig, 0);
}).play;

// Sequence for map folding
Pbindef(\mapFoldSeq,
    \dur, Pseq([1.5, 0.8, 2.0, 1.2, 0.5, 3.0], inf),
    \t_trig, 1,
    \freq, Pseq([800, 1200, 600, 1500, 900, 400], inf),
    \rq, Pseq([0.05, 0.1, 0.2, 0.08], inf),
    \amp, Pwhite(0.2, 0.6, inf),
    \pan, Pseq([-0.7, 0.7, -0.3, 0.3], inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// Add reverb to waiterGlass for ethereal suspension
Ndef(\waiterGlass)[10] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.9, 0.5) };
Ndef(\waiterGlass).set(\wet10, 0.4);

// Rollback: remove all instruments and effects
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Ndef(\antarcticDrone).fadeTime = 2; Ndef(\antarcticDrone).clear(2);
// Ndef(\waiterGlass).fadeTime = 2; Ndef(\waiterGlass).clear(2);
// Ndef(\silenceWeight).fadeTime = 2; Ndef(\silenceWeight).clear(2);
// Ndef(\waiterGlass).set(\wet10, 0); // Rollback: disable reverb
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ============================================================
// "O Navio Negreiro" — Castro Alves
// Dark, horrific imagery: chains, whips, groans, prayers
// ============================================================

// Metallic chains rattling — Klank resonators struck by noise
Ndef(\chainRattle, { |t_trig=0, freq=1200, amp=0.4, pan=0|
    var env, exc, sig;
    env = EnvGen.ar(Env.perc(0.001, 0.4, 1, -4), t_trig);
    exc = WhiteNoise.ar * env;
    sig = Klank.ar(`[[freq, freq*1.5, freq*2.3, freq*3.1], [1, 0.6, 0.4, 0.2], [0.3, 0.2, 0.15, 0.1]], exc);
    Pan2.ar(sig * amp, pan);
}).play;

// Whip crack — sharp violent transient
Ndef(\whipCrack, { |t_trig=0, amp=0.6, pan=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.0001, 0.08, 1, -10), t_trig);
    sig = WhiteNoise.ar * env;
    sig = BPF.ar(sig, 3000, 0.5) * 3;
    sig = sig + (HPF.ar(WhiteNoise.ar * env, 6000) * 0.5);
    Pan2.ar(sig * amp, pan);
}).play;

// Groans of the damned — low vocal-formant drone, praying
Ndef(\groanChoir, { |freq=75, amp=0.3, pan=0|
    var sig, formants, lfo;
    lfo = SinOsc.kr(0.27).range(0.85, 1.15);
    sig = Saw.ar(freq * [1, 1.005, 0.995]).sum * 0.3;
    formants = BPF.ar(sig, [500, 1000, 2000], [0.1, 0.15, 0.2]) * [1, 0.7, 0.3];
    sig = formants.sum * amp * lfo;
    Pan2.ar(sig, pan);
}).play;

// Prayers rising — cavernous reverb on the groaning choir
Ndef(\groanChoir)[10] = \filter -> { |in| FreeVerb.ar(in, 0.9, 0.95, 0.6) };
Ndef(\groanChoir).set(\wet10, 0.5);

// Sequence for chains — irregular clanking
Pbindef(\chainSeq,
    \dur, Pseq([0.3, 0.15, 0.5, 0.2, 0.4, 0.25], inf),
    \t_trig, 1,
    \freq, Pseq([1200, 900, 1500, 800, 1800, 1100], inf),
    \amp, Pwhite(0.2, 0.5, inf),
    \pan, Pseq([-0.6, 0.6, -0.3, 0.3], inf)
);
Ndef(\chainRattle)[1] = \set -> Pbindef(\chainSeq);

// Whip sequence — sparse, brutal
Pbindef(\whipSeq,
    \dur, Pseq([2.0, 0.3, 1.5, 0.2, 3.0, 0.5], inf),
    \t_trig, 1,
    \amp, Pwhite(0.4, 0.8, inf),
    \pan, Pseq([-0.8, 0.8, 0.0], inf)
);
Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);

// Rollback: remove new instruments
// Pbindef(\chainSeq).stop; Ndef(\chainRattle).fadeTime = 2; Ndef(\chainRattle).clear(2); // Rollback
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2); // Rollback
// Ndef(\groanChoir).fadeTime = 2; Ndef(\groanChoir).clear(2); // Rollback
// Ndef(\groanChoir).set(\wet10, 0); // Rollback: disable reverb
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
~enableRecording = false;

if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    sig = LeakDC.ar(sig);
    sig = Limiter.ar(sig, 0.85, 0.01);
    ReplaceOut.ar(0, sig);
}).add;

s.sync;

ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

// --- Discrete SynthDefs: brass clockwork ---

// Pendulum clock tick: brass click through resonant filter
SynthDef(\pendulumTick, {
    |out=0, freq=1800, rq=0.08, amp=0.3, pan=0, decay=0.08|
    var env, exc, sig;
    env = EnvGen.ar(Env.perc(0.0005, decay, 1, -6), doneAction: 2);
    exc = WhiteNoise.ar * env;
    sig = BPF.ar(exc, freq, rq) * 8;
    sig = sig + (HPF.ar(exc, 5000) * 0.3);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// French carillon bell — FM inharmonic bell
SynthDef(\carillonBell, {
    |out=0, freq=440, amp=0.3, pan=0, decay=4|
    var env, mod, car, sig;
    env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
    mod = SinOsc.ar(freq * 2.76, 0, freq * 3 * env);
    car = SinOsc.ar(freq + mod, 0, env);
    car = car + (SinOsc.ar(freq * 3.51, 0, env * 0.3));
    car = car + (SinOsc.ar(freq * 5.4, 0, env * 0.15));
    sig = LPF.ar(car * amp, 6500);
    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Pocket chronometer: tiny fast tick
SynthDef(\pocketTick, {
    |out=0, freq=4500, amp=0.2, pan=0|
    var env, exc, sig;
    env = EnvGen.ar(Env.perc(0.0001, 0.02, 1, -12), doneAction: 2);
    exc = WhiteNoise.ar * env;
    sig = BPF.ar(exc, freq, 0.15) * 7;
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

s.sync;

// --- Continuous Ndefs ---

// Brass haze: resonance of the workshop
Ndef(\brassHaze, { |amp=0|
    var sig, lfo, bp, sweep;
    lfo = LFNoise1.kr(0.15).range(0.3, 0.9);
    sweep = SinOsc.kr(0.05).range(1200, 2800);
    sig = PinkNoise.ar(0.15);
    bp = BPF.ar(sig, [sweep, sweep*1.4, sweep*1.9], [0.3, 0.4, 0.5]) * [1, 0.7, 0.5];
    sig = bp.sum * lfo;
    sig = sig + (SinOsc.ar([180, 240, 320], 0, 0.015).sum);
    Pan2.ar(sig * amp, 0);
});
Ndef(\brassHaze).fadeTime = 3;
Ndef(\brassHaze).xset(\amp, 0);

// Breath of time: slow emergent drone from detuned sines
Ndef(\breathOfTime, { |amp=0|
    var sig, lfo, detune;
    detune = LFNoise1.kr(0.08).range(0.99, 1.01);
    sig = SinOsc.ar(55 * [1, 1.5, 2, 3] * detune, 0, [0.4, 0.25, 0.15, 0.08]).sum;
    sig = sig + (SinOsc.ar(110 * detune, 0, 0.1));
    lfo = SinOsc.kr(0.07).range(0.4, 1.0);
    sig = LPF.ar(sig * lfo, 800);
    Pan2.ar(sig * amp * 0.3, 0);
});
Ndef(\breathOfTime).fadeTime = 4;
Ndef(\breathOfTime).xset(\amp, 0);

// --- Master mixer ---
Ndef(\masterMix, {
    var mix;
    mix = In.ar(~synthBus, 2);
    mix = mix + Ndef.ar(\brassHaze, 2);
    mix = mix + Ndef.ar(\breathOfTime, 2);
    mix;
});
Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
Ndef(\masterMix).set(\wet10, 0);
Ndef(\masterMix).play;
s.sync;

// --- Sequences ---

Pbindef(\pendulumSeq,
    \instrument, \pendulumTick, \out, ~synthBus,
    \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf),
    \freq, Pseq([1600, 1800, 1400, 2000, 1700, 1500], inf),
    \rq, Pseq([0.06, 0.08, 0.1, 0.07], inf),
    \decay, Pseq([0.06, 0.08, 0.05], inf),
    \amp, Pwhite(0.15, 0.35, inf),
    \pan, Pseq([-0.5, 0.5, -0.2, 0.2, -0.7, 0.7], inf)
);

Pbindef(\pendulumSeq2,
    \instrument, \pendulumTick, \out, ~synthBus,
    \dur, Pseq([0.47, 0.53, 0.49, 0.51], inf),
    \freq, Pseq([2200, 1900, 2400, 1700], inf),
    \rq, Pseq([0.05, 0.09, 0.07], inf),
    \decay, Pseq([0.04, 0.06], inf),
    \amp, Pwhite(0.1, 0.25, inf),
    \pan, Pseq([0.6, -0.6, 0.3, -0.3], inf)
);

Pbindef(\pocketSeq,
    \instrument, \pocketTick, \out, ~synthBus,
    \dur, Pseq([0.25, 0.25, 0.25, 0.25], inf),
    \freq, Pseq([4200, 4800, 5000, 4500], inf),
    \amp, Pwhite(0.05, 0.15, inf),
    \pan, Pseq([-0.4, 0.4], inf)
);

Pbindef(\carillonSeq,
    \instrument, \carillonBell, \out, ~synthBus,
    \dur, Pseq([4.5, 3.2, 6.0, 5.1], inf),
    \freq, Pseq([523, 622, 698, 784, 880], inf),
    \decay, Pseq([3.5, 4.5, 5.5], inf),
    \amp, Pwhite(0.15, 0.3, inf),
    \pan, Pseq([-0.4, 0.4, 0.0], inf)
);

// --- Score ---
Tdef(\masterScore, {
    "0:00 - [Cue 1: The workshop awakens, first ticks]".postln;
    Ndef(\brassHaze).xset(\amp, 0.3);
    Pbindef(\pendulumSeq).play;
    Pbindef(\pendulumSeq2).play;
    Pbindef(\pocketSeq).play;
    6.do { Ndef(\brassHaze).xset(\amp, rrand(0.25, 0.45)); (0.8 + 0.2.rand).wait; };

    "0:08 - [Cue 2: Carillon bells enter]".postln;
    Pbindef(\carillonSeq).play;
    Ndef(\masterMix).set(\wet10, 0.35);
    8.do { Ndef(\brassHaze).xset(\amp, rrand(0.2, 0.5));
            Ndef(\breathOfTime).xset(\amp, rrand(0.0, 0.15)); 1.wait; };

    "0:18 - [Cue 3: Swarm of clocks, density rises]".postln;
    Ndef(\breathOfTime).xset(\amp, 0.25);
    Pbindef(\pendulumSeq).stop;
    Pbindef(\pendulumSeq, \dur, Pseq([0.25, 0.25, 0.25, 0.25], inf),
                          \amp, Pwhite(0.2, 0.4, inf));
    Pbindef(\pendulumSeq).play;
    10.do { Ndef(\brassHaze).xset(\amp, rrand(0.3, 0.55));
            Ndef(\breathOfTime).xset(\amp, rrand(0.15, 0.35));
            (0.7 + 0.4.rand).wait; };

    "0:30 - [Cue 4: Clockmaker closes his eyes - microscopic offsets]".postln;
    Pbindef(\pocketSeq).stop;
    Pbindef(\pendulumSeq2).stop;
    Pbindef(\carillonSeq, \dur, Pseq([8.0, 6.5, 9.0], inf),
                          \decay, Pseq([6.0, 7.0, 8.0], inf),
                          \amp, Pwhite(0.2, 0.35, inf));
    Ndef(\masterMix).set(\wet10, 0.55);
    Ndef(\breathOfTime).xset(\amp, 0.4);
    12.do { Ndef(\breathOfTime).xset(\amp, rrand(0.3, 0.5));
            Ndef(\brassHaze).xset(\amp, rrand(0.15, 0.3)); 1.wait; };

    "0:44 - [Cue 5: Breathing of time - phase offsets become audible]".postln;
    Pbindef(\pendulumSeq).stop;
    Pbindef(\pendulumSeq, \dur, Pseq([0.5, 0.48, 0.52, 0.49, 0.51], inf),
                          \freq, Pseq([800, 1200, 600, 1000], inf),
                          \amp, Pwhite(0.15, 0.3, inf));
    Pbindef(\pendulumSeq).play;
    Ndef(\breathOfTime).xset(\amp, 0.55);
    Ndef(\brassHaze).xset(\amp, 0.2);
    10.do { Ndef(\breathOfTime).xset(\amp, rrand(0.4, 0.6));
            (0.9 + 0.3.rand).wait; };

    "0:56 - [Cue 6: Pocket watches rejoin, faster]".postln;
    Pbindef(\pocketSeq, \dur, Pseq([0.2, 0.2, 0.2, 0.2], inf),
                        \amp, Pwhite(0.08, 0.18, inf));
    Pbindef(\pocketSeq).play;
    8.do { Ndef(\breathOfTime).xset(\amp, rrand(0.35, 0.55));
           Ndef(\brassHaze).xset(\amp, rrand(0.2, 0.4)); 1.wait; };

    "1:06 - [Cue 7: Settling - one clock remains]".postln;
    Pbindef(\pendulumSeq2).play;
    Pbindef(\carillonSeq).stop;
    Pbindef(\pocketSeq).stop;
    Pbindef(\pendulumSeq, \dur, Pseq([1.0, 1.0, 1.0, 1.0], inf),
                          \amp, Pwhite(0.15, 0.25, inf));
    Ndef(\breathOfTime).xset(\amp, 0.35);
    Ndef(\masterMix).set(\wet10, 0.4);
    10.do { Ndef(\breathOfTime).xset(\amp, rrand(0.2, 0.4)); 1.wait; };

    "1:18 - [Cue 8: Final carillon, resolution]".postln;
    Pbindef(\carillonSeq).play;
    Pbindef(\pendulumSeq).stop;
    Pbindef(\pendulumSeq2).stop;
    Ndef(\masterMix).set(\wet10, 0.6);
    8.do { Ndef(\breathOfTime).xset(\amp, rrand(0.15, 0.3));
           Ndef(\brassHaze).xset(\amp, rrand(0.1, 0.25)); 1.wait; };

    "1:26 - [Cue 9: Fade to silence]".postln;
    Pbindef(\carillonSeq).stop;
    Ndef(\breathOfTime).xset(\amp, 0);
    Ndef(\brassHaze).xset(\amp, 0);
    6.do { |k| Ndef(\masterMix).set(\wet10, (0.6 - (k * 0.1)).max(0)); 1.wait; };

    "Score Complete.".postln;

    Pbindef(\pendulumSeq).stop; Pbindef(\pendulumSeq).clear;
    Pbindef(\pendulumSeq2).stop; Pbindef(\pendulumSeq2).clear;
    Pbindef(\pocketSeq).stop; Pbindef(\pocketSeq).clear;
    Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
    Ndef(\brassHaze).clear(2);
    Ndef(\breathOfTime).clear(2);
    Ndef(\masterMix).clear(2);
    Tdef(\masterScore).stop;
});
Tdef(\masterScore).play;
)


// ============================================================
// ROUND 04 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // --- Discrete SynthDefs ---
    // Resonant drip on limestone
    SynthDef(\dropRes, {
        |out=0, freq=800, amp=0.3, decay=3.5, pan=0|
        var exc, res, env, sig;
        exc = Impulse.ar(0) + (PinkNoise.ar(0.35) * EnvGen.ar(Env.perc(0.0005, 0.003)));
        res = DynKlank.ar(Ref([
            [freq, freq*2.31, freq*3.87, freq*5.12, freq*7.03],
            [1, 0.6, 0.4, 0.25, 0.15],
            [decay, decay*0.7, decay*0.5, decay*0.35, decay*0.25]
        ]), exc, 0.5, 0.0, 1.0);
        env = EnvGen.ar(Env.perc(0.001, decay*0.9), doneAction: 2);
        sig = res * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Deep struck stone
    SynthDef(\stonePulse, {
        |out=0, freq=90, amp=0.4, decay=5.0, pan=0|
        var exc, res, env, sig, sub;
        exc = Impulse.ar(0) + (WhiteNoise.ar(0.5) * EnvGen.ar(Env.perc(0.001, 0.01)));
        res = DynKlank.ar(Ref([
            [freq, freq*1.41, freq*2.13, freq*3.27, freq*4.85],
            [1, 0.7, 0.5, 0.3, 0.2],
            [decay, decay*0.8, decay*0.6, decay*0.4, decay*0.3]
        ]), exc, 0.6, 0.0, 1.0);
        sub = SinOsc.ar(freq*0.5) * EnvGen.ar(Env.perc(0.005, decay*0.5)) * 0.3;
        env = EnvGen.ar(Env.perc(0.002, decay*0.9), doneAction: 2);
        sig = (res + sub) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Mineral curtain shimmer
    SynthDef(\mineralShimmer, {
        |out=0, freq=1200, amp=0.2, decay=4.0, pan=0|
        var exc, res, env, sig;
        exc = (Dust.ar(90) * 0.5) + (SinOsc.ar(freq*0.5) * 0.02);
        res = DynKlank.ar(Ref([
            [freq, freq*1.5, freq*2.7, freq*4.1, freq*6.3, freq*8.9],
            [0.8, 0.6, 0.5, 0.35, 0.25, 0.15],
            [decay, decay, decay*0.8, decay*0.6, decay*0.45, decay*0.3]
        ]), exc, 0.4, 0.0, 1.0);
        env = EnvGen.ar(Env.perc(0.02, decay*0.8), doneAction: 2);
        sig = res * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // --- Continuous Textures ---
    Ndef(\caveDrone, {
        var sig, amp;
        amp = \amp.kr(0).lag(1.5);
        sig = SinOsc.ar(38 * LFNoise1.kr(0.07).range(0.98, 1.02)) * 0.5;
        sig = sig + (SinOsc.ar(38.5 * LFNoise1.kr(0.11).range(0.99, 1.01)) * 0.4);
        sig = sig + (SinOsc.ar(76) * 0.25);
        sig = sig + (SinOsc.ar(57) * 0.2);
        sig = LPF.ar(sig, 400);
        sig = sig * amp * 0.5;
        [sig, sig * 0.95];
    });
    Ndef(\caveDrone).fadeTime = 3;

    Ndef(\waterFlow, {
        var sig, amp;
        amp = \amp.kr(0).lag(1.5);
        sig = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.5).range(400, 1800), 0.3) * 2;
        sig = sig + (BPF.ar(PinkNoise.ar, LFNoise1.kr(0.7).range(2000, 5000), 0.4) * 1.5);
        sig = sig * amp * 0.4;
        [sig, sig];
    });
    Ndef(\waterFlow).fadeTime = 3;

    Ndef(\mineralAir, {
        var sig, amp, voices;
        amp = \amp.kr(0).lag(2);
        voices = [2400, 3200, 4100, 5300].collect { |f|
            SinOsc.ar(f * LFNoise1.kr(0.3).range(0.99, 1.01)) * LFNoise1.kr(0.5).range(0.2, 1);
        };
        sig = Splay.ar(voices) * amp * 0.15;
        sig;
    });
    Ndef(\mineralAir).fadeTime = 3;

    // --- Master Mixer ---
    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2);
        sig = sig + Ndef.ar(\caveDrone, 2);
        sig = sig + Ndef.ar(\waterFlow, 2);
        sig = sig + Ndef.ar(\mineralAir, 2);
        sig;
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.95, 0.5) };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;
    s.sync;

    // --- Patterns ---
    Pbindef(\dripSeq,
        \instrument, \dropRes,
        \out, ~synthBus,
        \freq, Pexprand(400, 1600, inf),
        \decay, Pexprand(1.5, 4.0, inf),
        \amp, Pwhite(0.15, 0.35, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \dur, Pexprand(0.4, 2.0, inf)
    );

    Pbindef(\stoneSeq,
        \instrument, \stonePulse,
        \out, ~synthBus,
        \freq, Pexprand(70, 140, inf),
        \decay, Pexprand(3.0, 6.0, inf),
        \amp, Pwhite(0.2, 0.4, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \dur, Pexprand(3.0, 8.0, inf)
    );

    Pbindef(\shimmerSeq,
        \instrument, \mineralShimmer,
        \out, ~synthBus,
        \freq, Pexprand(800, 2200, inf),
        \decay, Pexprand(2.0, 5.0, inf),
        \amp, Pwhite(0.08, 0.2, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \dur, Pexprand(1.5, 5.0, inf)
    );

    // --- Score ---
    Tdef(\masterScore, {
        "0:00 - [Cue 1: Darkness - first drips in the void]".postln;
        Ndef(\caveDrone).xset(\amp, 0.15);
        Ndef(\masterMix).set(\wet10, 0.3);
        Pbindef(\dripSeq).play;
        8.do {
            Ndef(\caveDrone).xset(\amp, rrand(0.1, 0.25));
            Ndef(\masterMix).set(\wet10, rrand(0.25, 0.45));
            (0.8 + 0.4.rand).wait;
        };

        "0:08 - [Cue 2: Water finds the limestone]".postln;
        Ndef(\waterFlow).xset(\amp, 0.3);
        Pbindef(\stoneSeq).play;
        8.do {
            Ndef(\waterFlow).xset(\amp, rrand(0.2, 0.45));
            Ndef(\caveDrone).xset(\amp, rrand(0.15, 0.3));
            (0.9 + 0.4.rand).wait;
        };

        "0:20 - [Cue 3: Seven chambers resonate, drops quicken]".postln;
        Pbindef(\dripSeq, \dur, Pexprand(0.15, 0.8, inf),
                           \amp, Pwhite(0.2, 0.4, inf)).play;
        Ndef(\masterMix).set(\wet10, 0.5);
        10.do {
            Ndef(\waterFlow).xset(\amp, rrand(0.3, 0.5));
            Ndef(\caveDrone).xset(\amp, rrand(0.2, 0.35));
            Ndef(\masterMix).set(\wet10, rrand(0.45, 0.6));
            (0.8 + 0.3.rand).wait;
        };

        "0:32 - [Cue 4: Mineral curtains shimmer]".postln;
        Pbindef(\shimmerSeq).play;
        Ndef(\mineralAir).xset(\amp, 0.25);
        10.do {
            Ndef(\mineralAir).xset(\amp, rrand(0.15, 0.35));
            Ndef(\masterMix).set(\wet10, rrand(0.5, 0.7));
            (0.9 + 0.4.rand).wait;
        };

        "0:46 - [Cue 5: Peter Lund's deep resonance of time]".postln;
        Ndef(\caveDrone).xset(\amp, 0.4);
        Ndef(\waterFlow).xset(\amp, 0.35);
        Pbindef(\dripSeq, \dur, Pexprand(0.5, 2.5, inf),
                           \decay, Pexprand(3.0, 6.0, inf)).play;
        Pbindef(\stoneSeq, \dur, Pexprand(2.0, 5.0, inf)).play;
        12.do {
            Ndef(\caveDrone).xset(\amp, rrand(0.3, 0.5));
            Ndef(\mineralAir).xset(\amp, rrand(0.1, 0.25));
            (0.9 + 0.3.rand).wait;
        };

        "1:04 - [Cue 6: Settling - one drip remains]".postln;
        Pbindef(\shimmerSeq).stop;
        Pbindef(\stoneSeq).stop;
        Ndef(\mineralAir).xset(\amp, 0);
        Ndef(\waterFlow).xset(\amp, 0.15);
        Pbindef(\dripSeq, \dur, Pexprand(1.5, 4.0, inf),
                           \amp, Pwhite(0.12, 0.25, inf)).play;
        Ndef(\masterMix).set(\wet10, 0.55);
        10.do {
            Ndef(\caveDrone).xset(\amp, rrand(0.15, 0.3));
            Ndef(\waterFlow).xset(\amp, rrand(0.08, 0.18));
            (0.9 + 0.3.rand).wait;
        };

        "1:20 - [Cue 7: Resolution - return to the void]".postln;
        Pbindef(\dripSeq).stop;
        Ndef(\waterFlow).xset(\amp, 0);
        Ndef(\caveDrone).xset(\amp, 0.1);
        8.do { |k|
            Ndef(\masterMix).set(\wet10, (0.55 - (k * 0.07)).max(0.1));
            Ndef(\caveDrone).xset(\amp, rrand(0.05, 0.15));
            1.0.wait;
        };

        "Score Complete.".postln;

        Pbindef(\dripSeq).stop; Pbindef(\dripSeq).clear;
        Pbindef(\stoneSeq).stop; Pbindef(\stoneSeq).clear;
        Pbindef(\shimmerSeq).stop; Pbindef(\shimmerSeq).clear;
        Ndef(\caveDrone).clear(2);
        Ndef(\waterFlow).clear(2);
        Ndef(\mineralAir).clear(2);
        Ndef(\masterMix).clear(2);
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

