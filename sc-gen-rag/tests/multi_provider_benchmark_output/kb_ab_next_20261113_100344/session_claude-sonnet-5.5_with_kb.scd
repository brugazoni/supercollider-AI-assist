// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Sonnet 5.5
// Model ID: openrouter:anthropic/claude-sonnet-5.5
// Date: 2026-11-13T13:29:36.512030+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Piece: "O Mapa Dobrado" - a restaurant table, 27 years of silence, an Antarctic storm gathering

// 1. Restaurant ambience: warm, polite room hum (the 27 years of civility)
Ndef(\mesaHum, { |amp=0.12, cutoff=900, t_trig=0|
    var sig, room;
    room = BPF.ar(PinkNoise.ar(0.5), [300, 520, 780], 0.8).sum * 2;
    sig = LPF.ar(room, cutoff);
    sig = sig + (SinOsc.ar([110, 165.3]) * 0.1);
    Splay.ar(sig) * amp;
}).play;

// 2. Husband's pedantic folding: crisp, precise paper-like plucks
Ndef(\mapaDobra, { |freq=440, amp=0.2, pan=0, t_trig=0, decay=0.4, cutoff=3500|
    var env, mod, sig;
    env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), t_trig);
    mod = SinOsc.ar(freq * 2.01) * freq * 0.8 * env;
    sig = SinOsc.ar(freq + mod) * env;
    sig = sig + (BPF.ar(WhiteNoise.ar(0.3), 6000, 0.3) * EnvGen.ar(Env.perc(0.001, 0.03), t_trig));
    sig = LPF.ar(sig, cutoff);
    Pan2.ar(sig * amp, pan);
}).play;

// 3. Antarctic storm: suspended, heavy, building tension (starts nearly silent)
Ndef(\tempestadeAntartica, { |freq=55, amp=0.0, wind=800, tension=0.3|
    var noise, drone, sig;
    noise = BPF.ar(PinkNoise.ar, wind * LFNoise1.kr(0.2).range(0.6, 1.4), 0.2) * 6;
    drone = Splay.ar(Saw.ar(freq * [1, 1.003, 1.5, 2.01]) * 0.3);
    drone = RLPF.ar(drone, 200 + (tension * 1500), 0.4);
    sig = (noise * tension) + drone + (SinOsc.ar(freq * 2) * 0.2);
    sig = LeakDC.ar(sig).tanh;
    sig * amp;
}).play;

// 4. Waiter frozen with the wine bottle: a single glassy suspended tone
Ndef(\garcomVinho, { |freq=880, amp=0.0, t_trig=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(1.5, 6, 1, -3), t_trig);
    sig = DynKlank.ar(Ref([[freq, freq * 2.76, freq * 5.4], [1, 0.5, 0.3], [4, 3, 2]]), PinkNoise.ar(0.01) * env, 1, 0, 1);
    sig = sig * 20;
    Pan2.ar(sig * amp, 0.3);
}).play;

// Effects
Ndef(\mapaDobra)[10] = \filter -> { |in| CombC.ar(in, 0.4, [0.21, 0.27], 1.5) };
Ndef(\mapaDobra).set(\wet10, 0);

Ndef(\tempestadeAntartica)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.95, 0.3) };
Ndef(\tempestadeAntartica).set(\wet10, 0.3);

Ndef(\garcomVinho)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.5) };
Ndef(\garcomVinho).set(\wet10, 0.5);

// Sequences
Pbindef(\seqMapa,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 1], inf),
    \degree, Pseq([0, 2, 4, 2, 0, 4, 7, 4], inf),
    \octave, 5,
    \t_trig, 1,
    \decay, Pwhite(0.2, 0.5, inf),
    \cutoff, Pseq([2500, 3500, 4500], inf),
    \amp, Pseq([0.15, 0.1, 0.12, 0.1], inf),
    \pan, Pwhite(-0.4, 0.4, inf)
);
Ndef(\mapaDobra)[1] = \set -> Pbindef(\seqMapa);

Pbindef(\seqGarcom,
    \dur, Pseq([12, 16], inf),
    \freq, Pseq([880, 932], inf),
    \t_trig, 1,
    \amp, 0.12
);
Ndef(\garcomVinho)[1] = \set -> Pbindef(\seqGarcom);

Pbindef(\seqTempestade,
    \dur, 8,
    \freq, Pseq([55, 55, 58.27, 61.74], inf),
    \tension, Pseq([0.3, 0.45, 0.6, 0.8], inf),
    \wind, Pseq([700, 900, 1200, 1800], inf),
    \amp, Pseq([0.05, 0.08, 0.12, 0.18], inf)
);
Ndef(\tempestadeAntartica)[1] = \set -> Pbindef(\seqTempestade);

// Rollbacks
// Pbindef(\seqMapa).stop; Ndef(\mapaDobra).fadeTime = 2; Ndef(\mapaDobra).clear(2); // Rollback: remove this instrument
// Pbindef(\seqGarcom).stop; Ndef(\garcomVinho).fadeTime = 2; Ndef(\garcomVinho).clear(2); // Rollback: remove this instrument
// Pbindef(\seqTempestade).stop; Ndef(\tempestadeAntartica).fadeTime = 2; Ndef(\tempestadeAntartica).clear(2); // Rollback: remove this instrument
// Pbindef(\mesaHum).stop; Ndef(\mesaHum).fadeTime = 2; Ndef(\mesaHum).clear(2); // Rollback: remove this instrument
// Ndef(\mapaDobra).set(\wet10, 0); Ndef(\tempestadeAntartica).set(\wet10, 0); Ndef(\garcomVinho).set(\wet10, 0); // Rollback: disable these effects
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var mkTick;
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Brass escapement tick
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.2, pan=0, dec=0.05|
        var env, sig, ex;
        env = EnvGen.ar(Env.perc(0.0005, dec, 1, -6), doneAction: 2);
        ex = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0003, 0.008))) + (Impulse.ar(0) * 0.5);
        sig = DynKlank.ar(Ref([[freq, freq * 2.76, freq * 5.4, freq * 8.9], [1, 0.6, 0.35, 0.2], [0.15, 0.1, 0.08, 0.05]]), ex, 1, 0, 1);
        sig = sig * env * 0.8;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // French carillon chime
    SynthDef(\carillon, { |out=0, freq=660, amp=0.15, pan=0, dur=4|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.003, dur.max(0.5), 1, -5), doneAction: 2);
        mod = SinOsc.ar(freq * 3.51) * freq * 1.2 * EnvGen.ar(Env.perc(0.001, 0.3));
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 2.01) * 0.3);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    // Pendulum bob: low wooden thunk
    SynthDef(\pendulumThunk, { |out=0, freq=90, amp=0.2, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.002, 0.25, 1, -8), doneAction: 2);
        sig = SinOsc.ar(freq * (1 + (env * 0.5))) + (LPF.ar(PinkNoise.ar, 400) * 0.3);
        Out.ar(out, Pan2.ar((sig * env).tanh, pan, amp));
    }).add;
    s.sync;

    Ndef(\timeBreath, { |amp=0, cutoff=900, rate=0.2|
        var sig, mod;
        mod = SinOsc.kr(rate).range(0.3, 1);
        sig = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.3).range(0.7, 1.3), 0.3) * 4 * mod;
        sig = sig + (SinOsc.ar([55, 55.4]) * 0.15);
        sig = LeakDC.ar(sig);
        sig * amp;
    });

    Ndef(\gearSwarm, { |amp=0, dens=20, lo=1500|
        var trg, sig;
        trg = Dust.ar([dens, dens * 1.07]);
        sig = Ringz.ar(trg, TExpRand.ar(lo, lo * 3, trg), 0.03) * 0.3;
        sig * amp;
    });

    Ndef(\masterMix, {
        In.ar(~synthBus, 2) + Ndef.ar(\timeBreath, 2) + Ndef.ar(\gearSwarm, 2);
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
    Ndef(\masterMix).set(\wet10, 0.2);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: one lone clock]".postln;
        Pbindef(\clockA, \instrument, \brassTick, \out, ~synthBus, \dur, 0.5, \freq, 2400, \amp, 0.2, \pan, (-0.3)).play;
        8.do { 1.wait; };

        "0:08 - [Cue 2: second clock, slight drift]".postln;
        Pbindef(\clockB, \instrument, \brassTick, \out, ~synthBus, \dur, 0.503, \freq, 3100, \amp, 0.15, \pan, 0.4).play;
        Pbindef(\pend, \instrument, \pendulumThunk, \out, ~synthBus, \dur, 1.0, \freq, 85, \amp, 0.2, \pan, 0).play;
        8.do { 1.wait; };

        "0:16 - [Cue 3: swarm of misaligned clocks]".postln;
        Pbindef(\clockC, \instrument, \brassTick, \out, ~synthBus, \dur, 0.497, \freq, Pwhite(1800, 4200, inf), \amp, 0.1, \pan, Pwhite(-0.8, 0.8, inf)).play;
        Pbindef(\clockD, \instrument, \brassTick, \out, ~synthBus, \dur, 0.331, \freq, Pwhite(2000, 5000, inf), \amp, 0.08, \pan, Pwhite(-0.8, 0.8, inf), \dec, 0.03).play;
        Ndef(\gearSwarm).fadeTime = 6;
        Ndef(\gearSwarm).xset(\amp, 0.5, \dens, 30);
        6.do { |i|
            Pbindef(\clockC, \dur, 0.497 - (i * 0.012));
            Pbindef(\clockD, \dur, 0.331 + (i * 0.007));
            2.wait;
        };

        "0:28 - [Cue 4: carillon chimes the hour]".postln;
        Pbindef(\chime, \instrument, \carillon, \out, ~synthBus, \dur, Pseq([2, 2, 2, 4], inf), \freq, Pseq([523.25, 659.25, 783.99, 392], inf), \pan, Pwhite(-0.5, 0.5, inf), \amp, 0.14).play;
        Ndef(\gearSwarm).xset(\dens, 90, \lo, 2500);
        8.do { |i|
            Pbindef(\clockC, \dur, Pn(Pgeom(0.4, 0.93, 12), inf));
            Ndef(\masterMix).set(\wet10, 0.2 + (i * 0.04));
            1.5.wait;
        };

        "0:40 - [Cue 5: eyes closed, the breath of time]".postln;
        Pbindef(\clockB).stop; Pbindef(\clockC).stop; Pbindef(\clockD).stop; Pbindef(\pend).stop;
        Ndef(\gearSwarm).xset(\amp, 0.1, \dens, 4);
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.35, \rate, 0.18);
        Ndef(\masterMix).set(\wet10, 0.5);
        4.do { |i|
            Ndef(\timeBreath).xset(\cutoff, exprand(500, 1800));
            3.wait;
        };

        "0:52 - [Cue 6: return of single tick]".postln;
        Pbindef(\clockA).stop; Pbindef(\chime).stop;
        Pbindef(\clockA, \dur, 1.0, \freq, 2400, \amp, 0.2).play;
        Ndef(\timeBreath).fadeTime = 6;
        Ndef(\timeBreath).xset(\amp, 0);
        Ndef(\gearSwarm).xset(\amp, 0);
        6.wait;

        Pbindef(\clockA).stop; Pbindef(\clockA).clear;
        Pbindef(\clockB).clear; Pbindef(\clockC).clear; Pbindef(\clockD).clear;
        Pbindef(\pend).clear; Pbindef(\chime).clear;
        2.wait;
        Ndef(\timeBreath).clear(2);
        Ndef(\gearSwarm).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
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
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: Brazilian procession for Nossa Senhora do Rosário and São Benedito
// Layer 1: caixa/bumbo drum bed (sub + skin)
Ndef(\congadaBumbo, { |freq=62, amp=0.22, t_trig=1, pan=0, decay=0.6|
    var env, pitchEnv, sig, sub;
    env = Env.perc(0.004, decay, 1, -6).kr(0, t_trig);
    pitchEnv = Env.perc(0.001, 0.08, 1, -4).kr(0, t_trig);
    sub = SinOsc.ar(freq * (1 + (pitchEnv * 1.5))) * env;
    sig = sub + (SinOsc.ar(freq * 2.01) * env * 0.3);
    sig = sig + (BPF.ar(PinkNoise.ar, 220, 0.5) * env * 0.4);
    sig = LeakDC.ar((sig * 1.8).tanh);
    Pan2.ar(sig, pan, amp);
}).fadeTime = 2;
Ndef(\congadaBumbo).play;

// Layer 2: gungas de lata - metallic ankle shakers
Ndef(\congadaGunga, { |amp=0.16, t_trig=1, pan=0, freq=5200, decay=0.14|
    var trg, env, noise, sig, ring;
    trg = K2A.ar(t_trig);
    env = Decay2.ar(trg, 0.002, decay);
    noise = WhiteNoise.ar * env;
    ring = Ringz.ar(noise, [freq, freq * 1.47, freq * 2.09], 0.12).sum * 0.08;
    sig = HPF.ar(noise, 4500) * 0.5 + ring;
    sig = BPF.ar(sig, freq, 0.6) * 6;
    Pan2.ar(sig, pan, amp);
}).fadeTime = 2;
Ndef(\congadaGunga).play;

// Layer 3: chanted vocal formant voices (ternos de congo)
Ndef(\congadaCanto, { |freq=220, amp=0.14, t_trig=1, vowel=0, pan=0|
    var env, body, fA, fO, fU, formF, sig, vib;
    env = Env([0, 1, 1, 0], [0.08, 0.6, 0.9]).kr(0, t_trig);
    vib = SinOsc.kr(5.2).range(0.995, 1.005);
    body = (Saw.ar(freq * vib * [0.995, 1, 1.005]).sum * 0.3);
    fA = [800, 1150, 2800];
    fO = [450, 800, 2830];
    fU = [325, 700, 2530];
    formF = SelectX.kr(vowel, [fA, fO, fU]);
    sig = BPF.ar(body, formF, 0.12).sum * 12 * env;
    sig = LeakDC.ar(sig);
    Pan2.ar(sig, pan, amp);
}).fadeTime = 3;
Ndef(\congadaCanto).play;

// Layer 4: festive air / distant crowd hiss
Ndef(\congadaAr, { |amp=0.06|
    var sig;
    sig = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.2).range(900, 2200), 0.4) * 5;
    sig = sig * LFNoise1.kr(0.3).range(0.3, 1);
    Splay.ar([sig, DelayC.ar(sig, 0.05, 0.03), BPF.ar(PinkNoise.ar, 3000, 0.5) * 2]) * amp;
}).fadeTime = 4;
Ndef(\congadaAr).play;

// Effects
Ndef(\congadaBumbo)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.4, 0.5) };
Ndef(\congadaBumbo).set(\wet10, 0.12);
Ndef(\congadaGunga)[10] = \filter -> { |in| CombL.ar(in, 0.4, [0.18, 0.24], 1.2) };
Ndef(\congadaGunga).set(\wet10, 0.25);
Ndef(\congadaCanto)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.4) };
Ndef(\congadaCanto).set(\wet10, 0.4);

// Sequences
Pbindef(\seqCongBumbo,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25], inf),
    \freq, Pseq([62, 62, 70, 62, 55, 62, 78], inf),
    \decay, Pwhite(0.4, 0.8, inf),
    \amp, Pseq([0.26, 0.16, 0.14, 0.2, 0.24, 0.15, 0.18], inf),
    \pan, Pwhite(-0.15, 0.15, inf),
    \t_trig, 1
);
Ndef(\congadaBumbo).quant = 1;
Ndef(\congadaBumbo)[1] = \set -> Pbindef(\seqCongBumbo);

Pbindef(\seqCongGunga,
    \dur, Pwrand([0.125, 0.25, 0.375], [0.6, 0.3, 0.1], inf),
    \freq, Pwhite(4300, 6500, inf),
    \decay, Pwhite(0.08, 0.2, inf),
    \amp, Pwhite(0.08, 0.2, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \t_trig, 1
);
Ndef(\congadaGunga).quant = 1;
Ndef(\congadaGunga)[1] = \set -> Pbindef(\seqCongGunga);

Pbindef(\seqCongCanto,
    \dur, Pseq([2, 2, 1.5, 2.5], inf),
    \freq, Pseq([220, 261.63, 196, 246.94, 220, 293.66, 196, 164.81], inf),
    \vowel, Pwhite(0.0, 2.0, inf),
    \amp, Pwhite(0.1, 0.17, inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \t_trig, 1
);
Ndef(\congadaCanto).quant = 1;
Ndef(\congadaCanto)[1] = \set -> Pbindef(\seqCongCanto);
)

// Ndef(\congadaGunga).xset(\freq, 7000); // Brighter | Revert: Ndef(\congadaGunga).xset(\freq, 5200);
// Pbindef(\seqCongBumbo, \dur, 0.25); // Double-time | Revert: Pbindef(\seqCongBumbo, \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25], inf));
// Ndef(\congadaCanto).set(\wet10, 0.7); // More reverb | Revert: Ndef(\congadaCanto).set(\wet10, 0.4);
// Pbindef(\seqCongBumbo).stop; Ndef(\congadaBumbo).clear(4); // Rollback bumbo
// Pbindef(\seqCongGunga).stop; Ndef(\congadaGunga).clear(4); // Rollback gunga
// Pbindef(\seqCongCanto).stop; Ndef(\congadaCanto).clear(4); Ndef(\congadaAr).clear(4); // Rollback canto + air

