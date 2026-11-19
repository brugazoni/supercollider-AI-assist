// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek V4 Pro
// Model ID: openrouter:deepseek/deepseek-v4-pro
// Date: 2026-11-13T13:33:40.205222+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Ndef(\antarcticSilence) - The weight of the Antarctic storm, heavy silence
Ndef(\antarcticSilence, { |freq=60, amp=0.2, noiseAmp=0.05, lpfFreq=200, pan=0|
    var sig, wind, sub;
    sub = SinOsc.ar(freq * [1, 1.005]) * 0.3;
    wind = PinkNoise.ar(noiseAmp) * LFTri.kr(0.2).range(0.5, 1);
    sig = sub + wind;
    sig = RLPF.ar(sig, lpfFreq, 0.3);
    Pan2.ar(sig * amp, pan);
}).play;
// Pbindef(\silenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument

// ADD_EFFECTS: Slot [10] on \antarcticSilence - vast reverb to simulate the restaurant space
Ndef(\antarcticSilence)[10] = \filter -> { |in| GVerb.ar(in.sum, 100, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\antarcticSilence).set(\wet10, 0);
// Ndef(\antarcticSilence).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Ndef(\suspendedBottle) - The frozen wine bottle, suspended in air
Ndef(\suspendedBottle, { |freq=2200, amp=0.1, decay=5, t_trig=0, pan=0|
    var env, exciter, sig;
    env = EnvGen.ar(Env.perc(0.001, decay), t_trig);
    exciter = WhiteNoise.ar(0.1) * EnvGen.ar(Env.perc(0.001, 0.005), t_trig);
    sig = Ringz.ar(exciter, freq, decay);
    Pan2.ar(sig * env * amp, pan);
}).play;
// Pbindef(\bottleSeq).stop; Ndef(\suspendedBottle).fadeTime = 2; Ndef(\suspendedBottle).clear(2); // Rollback: remove this instrument

// ADD_EFFECTS: Slot [10] on \suspendedBottle - comb delay for frozen echo
Ndef(\suspendedBottle)[10] = \filter -> { |in| CombC.ar(in, 1.0, 0.8, 5) };
Ndef(\suspendedBottle).set(\wet10, 0);
// Ndef(\suspendedBottle).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Ndef(\mapFold) - The meticulous explanation of map folding
Ndef(\mapFold, { |freq=440, amp=0.15, bright=0.4, atk=0.001, rel=0.3, t_trig=0, pan=0|
    var env, exciter, sig;
    env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    exciter = WhiteNoise.ar(0.1) * EnvGen.ar(Env.perc(0.001, 0.005), t_trig);
    sig = Pluck.ar(exciter, t_trig, 0.2, 1/freq, 2, bright);
    Pan2.ar(sig * env * amp, pan);
}).play;
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

// ADD_EFFECTS: Slot [10] on \mapFold - slight saturation to make it mechanical
Ndef(\mapFold)[10] = \filter -> { |in| (in * 1.5).tanh };
Ndef(\mapFold).set(\wet10, 0);
// Ndef(\mapFold).set(\wet10, 0); // Rollback: disable this effect

// SEQUENCE: Pbindef(\bottleSeq) - occasional trigger of the suspended bottle, like a frozen moment
Pbindef(\bottleSeq,
    \dur, Pseq([4, 7, 5], inf),
    \t_trig, 1,
    \freq, Pwhite(1800, 2500, inf),
    \amp, Pwhite(0.05, 0.12, inf),
    \decay, Pwhite(4.0, 6.0, inf),
    \pan, Pwhite(-0.3, 0.3, inf)
);
Ndef(\suspendedBottle)[1] = \set -> Pbindef(\bottleSeq);

// SEQUENCE: Pbindef(\mapFoldSeq) - the unfolding explanation, slow and deliberate
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.75, 0.75, 1.5, 0.5, 0.25, 0.25, 1.0], inf),
    \t_trig, 1,
    \freq, Pseq(([0, 2, 4, 5, 7, 9, 11] + 60).midicps, inf),
    \amp, Pseq([0.1, 0.08, 0.12, 0.07, 0.05, 0.06, 0.09], inf),
    \bright, Pwhite(0.3, 0.6, inf),
    \rel, Pkey(\dur) * 0.8,
    \pan, Pwhite(-0.5, 0.5, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// TWEAK_EFFECTS: Set initial wetness for reverb on silence to create space from the start
Ndef(\antarcticSilence).xset(\wet10, 0.3); // subtle space
// Ndef(\antarcticSilence).xset(\wet10, 0); // Revert tweak
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var synths, cont;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2) };
    s.sync;

    // Safety limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // Discrete instruments
    SynthDef(\tick, { |out=0, freq=800, amp=0.1, pan=0, t_trig=1, ring=0.05|
        var env = EnvGen.ar(Env.perc(0.001, ring), t_trig, doneAction:2);
        var sig = SinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\carillon, { |out=0, freq=440, amp=0.1, pan=0, t_trig=1, decay=2|
        var env = EnvGen.ar(Env.perc(0.005, decay), t_trig, doneAction:2);
        var exciter = Impulse.ar(0) * EnvGen.ar(Env.perc(0.001, 0.01), t_trig);
        var sig = DynKlank.ar(Ref([
            [1, 2.76, 5.4, 8.9] * freq,
            [1, 0.8, 0.5, 0.3],
            [0.5, 0.3, 0.2, 0.1] * decay
        ]), exciter);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\chrono, { |out=0, freq=4000, amp=0.1, pan=0, t_trig=1, decay=0.02|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction:2);
        var sig = WhiteNoise.ar * env;
        sig = BPF.ar(sig, freq, 0.1);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\tickSwarm, { |amp=0, rateBase=2.0, spread=0.02, filt=2000|
        var sig = Mix.fill(30, { |i|
            var rate = rateBase + (i * spread) + LFNoise2.kr(0.2).range(-0.01, 0.01);
            var trig = LFPulse.ar(rate, 0, 0.005); // changed .kr to .ar to provide audio-rate trigger for Decay2
            var env = Decay2.ar(trig, 0.001, 0.03);
            var tick = SinOsc.ar(800 + (i*10), 0, env);
            Pan2.ar(tick, i.linlin(0, 29, -1, 1))
        }).sum * 0.5;
        sig = LPF.ar(sig, filt);
        sig * amp;
    });

    Ndef(\breathOfTime, { |amp=0, freq=55, breathRate=0.1|
        var mod = LFTri.kr(breathRate).range(0.5, 1);
        var sig = SinOsc.ar(freq * [1, 1.01]) * mod;
        sig = sig.sum * amp;
        Pan2.ar(sig, 0);
    });

    Ndef(\masterMix, {
        synths = In.ar(~synthBus, 2);
        cont = Ndef.ar(\tickSwarm, 2) + Ndef.ar(\breathOfTime, 2);
        synths + cont;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.6, damp: 0.4);
    };
    Ndef(\masterMix).set(\wet10, 0.1);
    Ndef(\masterMix).play;
    s.sync;

    // Score
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: The Workshop Awakens]".postln;
        Ndef(\tickSwarm).fadeTime = 12;
        Ndef(\tickSwarm).xset(\amp, 0.25, \rateBase, 1.5, \spread, 0.005, \filt, 1200);
        12.wait;

        "0:12 - [Cue 2: Pendulum Swarm Densifies]".postln;
        fork {
            6.do { |i|
                Ndef(\tickSwarm).xset(\rateBase, 1.5 + (i*0.1), \spread, 0.005 + (i*0.003));
                3.wait;
            };
        };
        Pbindef(\carillonSeq,
            \instrument, \carillon,
            \out, ~synthBus,
            \dur, Pseq([2, 3, 1.5, 2.5], inf),
            \freq, Pseq([440, 554, 660, 880], inf),
            \amp, 0.12,
            \decay, Pwhite(1.5, 3.0),
            \pan, Pwhite(-0.5, 0.5)
        ).play;
        18.wait;

        "0:30 - [Cue 3: Carillons and Chronometers]".postln;
        Pbindef(\chronoSeq,
            \instrument, \chrono,
            \out, ~synthBus,
            \dur, Pwhite(0.05, 0.15),
            \freq, Pwhite(3000, 6000),
            \amp, 0.05,
            \pan, Pwhite(-0.8, 0.8)
        ).play;
        Ndef(\masterMix).set(\wet10, 0.3);
        30.wait;

        "1:00 - [Cue 4: The Breath of Time]".postln;
        Ndef(\breathOfTime).fadeTime = 10;
        Ndef(\breathOfTime).xset(\amp, 0.2, \breathRate, 0.08);
        Ndef(\tickSwarm).xset(\rateBase, 2.5, \spread, 0.05, \filt, 3000);
        15.wait;

        "1:15 - [Cue 5: Phase Differences Peak]".postln;
        8.do { |i|
            Synth(\tick, [\out, ~synthBus, \freq, rrand(600, 1200), \amp, 0.08, \pan, rrand(-1,1), \ring, 0.1]);
            1.wait;
        };
        Ndef(\tickSwarm).xset(\spread, 0.08);
        15.wait;

        "1:30 - [Cue 6: Settling Down]".postln;
        Pbindef(\chronoSeq).stop;
        Pbindef(\carillonSeq).stop;
        Ndef(\tickSwarm).fadeTime = 15;
        Ndef(\tickSwarm).xset(\amp, 0.05, \spread, 0.01, \rateBase, 1.2);
        Ndef(\breathOfTime).fadeTime = 15;
        Ndef(\breathOfTime).xset(\amp, 0,);
        Ndef(\masterMix).set(\wet10, 0.05);
        15.wait;

        "1:45 - [Terminating]".postln;
        Ndef(\tickSwarm).clear(5);
        Ndef(\breathOfTime).clear(5);
        Ndef(\masterMix).clear(5);
        Pbindef(\carillonSeq).clear;
        Pbindef(\chronoSeq).clear;
        Tdef(\masterScore).stop;
        "Score Complete.".postln;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: FALLBACK
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: FALLBACK
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)

