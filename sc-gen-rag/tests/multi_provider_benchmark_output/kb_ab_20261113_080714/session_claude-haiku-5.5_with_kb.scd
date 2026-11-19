// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-13T11:19:11.090110+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Ndef(\antarcticDrone) - The Antarctic silence before the storm
Ndef(\antarcticDrone).fadeTime = 4;
Ndef(\antarcticDrone, {
    |freq=40, amp=0.25, cutoff=180, swell=0.02|
    var sub, wind, lfo, sig;
    sub = SinOsc.ar(freq, 0, 0.6) + SinOsc.ar(freq * 2, 0, 0.2);
    lfo = SinOsc.kr(swell).range(0.4, 1.0);
    wind = LPF.ar(PinkNoise.ar(0.5), cutoff * lfo);
    sig = (sub + wind) * amp;
    Pan2.ar(sig, SinOsc.kr(0.03) * 0.2);
}).play;

// ADD_EFFECTS: Slot [10] on the drone - cavernous reverb that makes the silence feel vast
Ndef(\antarcticDrone)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 0.9, 0.9, 0.2);
};
Ndef(\antarcticDrone).set(\wet10, 0);
// Ndef(\antarcticDrone).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Ndef(\mapFold) - Dry paper crinkle of the road map being folded
Ndef(\mapFold).fadeTime = 0.5;
Ndef(\mapFold, {
    |amp=0.3, pan=0, t_trig=0|
    var env, crackle, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, 0.08);
    crackle = HPF.ar(WhiteNoise.ar, 3000) * env;
    sig = crackle * amp;
    Pan2.ar(sig, pan);
}).play;

// TWEAK_SEQUENCE: Pbindef(\mapFoldSeq) - Uneven, hesitant creases, as if the folding is being explained step by step
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1.0, 0.75, 0.5, 1.5], inf),
    \t_trig, 1,
    \amp, Pwhite(0.15, 0.35, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

// Pbindef(\mapFoldSeq).stop; Ndef(\antarcticDrone).fadeTime = 2; Ndef(\antarcticDrone).clear(2); // Rollback: remove drone instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: Ndef(\chainIron) - "Tinir de ferros": iron chains ringing in the dark hold
Ndef(\chainIron).fadeTime = 1;
Ndef(\chainIron, {
    |amp=0.2, pan=0, t_trig=0, ring=1.5|
    var env, exciter, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.0005, 0.05);
    exciter = HPF.ar(WhiteNoise.ar, 2000) * env;
    sig = Ringz.ar(exciter, [1870, 2650, 3930], ring * [0.3, 0.2, 0.1]).sum * 0.5;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\chainSeq,
    \dur, Pseq([0.5, 0.5, 0.25, 0.25, 1.0, 0.75], inf),
    \t_trig, 1,
    \amp, Pwhite(0.2, 0.5, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \ring, Pwhite(0.8, 2.0, inf)
);
Ndef(\chainIron)[1] = \set -> Pbindef(\chainSeq);
// Pbindef(\chainSeq).stop; Ndef(\chainIron).fadeTime = 2; Ndef(\chainIron).clear(2); // Rollback: remove chain instrument

// ADD_INSTRUMENT: Ndef(\whipCrack) - "Estalar de açoite": sharp lash cracks across the deck
Ndef(\whipCrack).fadeTime = 0.5;
Ndef(\whipCrack, {
    |amp=0.3, pan=0, t_trig=0|
    var env, crack, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, 0.12);
    crack = BPF.ar(WhiteNoise.ar, 3500, 0.2) * env * 6;
    sig = crack.tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\whipSeq,
    \dur, Pseq([1.0, 0.5, 0.5, 2.0, 0.25, 0.25], inf),
    \t_trig, 1,
    \amp, Pwhite(0.3, 0.6, inf),
    \pan, Pwhite(-0.8, 0.8, inf)
);
Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2); // Rollback: remove whip instrument

// ADD_EFFECTS: Slot [10] on the whip - fold distortion to evoke the blood-lit deck, initialized dry
Ndef(\whipCrack)[10] = \filter -> { |in|
    Fold.ar(in * 3, -0.6, 0.6) * 0.8
};
Ndef(\whipCrack).set(\wet10, 0);
// Ndef(\whipCrack).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var dummy;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig; sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Escapement tick: brass tooth striking a tuned comb of resonators
    SynthDef(\clockTick, { |out=0, amp=0.2, pan=0, freq=3200|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0005, 0.04, 1, -8), doneAction: 2);
        sig = Ringz.ar(WhiteNoise.ar * env, [freq, freq * 2.37, freq * 3.9], [0.02, 0.012, 0.008]).sum;
        sig = HPF.ar(sig, 1200);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    // Carillon bell: inharmonic FM strike with fast clang
    SynthDef(\carillonBell, { |out=0, freq=660, amp=0.1, pan=0|
        var env, modEnv, mod, sig;
        env = EnvGen.ar(Env.perc(0.002, 3.5, 1, -5), doneAction: 2);
        modEnv = EnvGen.ar(Env.perc(0.001, 0.6));
        mod = SinOsc.ar(freq * 3.51) * freq * 0.8 * modEnv;
        sig = SinOsc.ar(freq + mod) * env;
        sig = sig + (SinOsc.ar(freq * 2.01) * env * 0.3);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // Continuous breath of the workshop: filtered pink air swelling with the pendulums
    Ndef(\gearBreath).fadeTime = 4;
    Ndef(\gearBreath, { |amp=0, rate=0.07, cutoff=900|
        var lfo, drift, air, hum;
        lfo = SinOsc.kr(rate).range(0.3, 1.0);
        drift = LFNoise2.kr(0.4).range(0.98, 1.02);
        air = BPF.ar(PinkNoise.ar(0.6), cutoff * lfo * drift, 0.3) * 4;
        hum = SinOsc.ar(110 * drift, 0, 0.08 * lfo);
        Pan2.ar((air + hum) * amp, SinOsc.kr(0.05) * 0.4);
    }).play;

    // Continuous time-breath: detuned sawtooth cluster filtered like a sighing spring
    Ndef(\timeBreath).fadeTime = 6;
    Ndef(\timeBreath, { |amp=0, cutoff=1400|
        var drift, sig;
        drift = LFNoise2.kr(0.1).range(0.998, 1.002);
        sig = Mix(Saw.ar([55, 55.23, 82.8] * drift, 0.15));
        sig = LPF.ar(sig, cutoff);
        Pan2.ar(sig * amp, 0);
    }).play;

    // Master mixer with a wet-only room on slot 10
    Ndef(\masterMix, {
        var synths, cont;
        synths = In.ar(~synthBus, 2);
        cont = Ndef.ar(\gearBreath, 2) + Ndef.ar(\timeBreath, 2);
        synths + cont;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.4);
    };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;
    s.sync;

    // Clock patterns: three escapements with microscopic period differences
    Pbindef(\clockA,
        \instrument, \clockTick,
        \out, ~synthBus,
        \dur, 0.5,
        \freq, Pwhite(2800, 3400, inf),
        \amp, Pwhite(0.08, 0.14, inf),
        \pan, Pwhite(-0.7, 0.7, inf)
    );
    Pbindef(\clockB,
        \instrument, \clockTick,
        \out, ~synthBus,
        \dur, 0.5 * 1.0031,
        \freq, Pwhite(3000, 3800, inf),
        \amp, 0,
        \pan, Pwhite(-0.6, 0.6, inf)
    );
    Pbindef(\clockC,
        \instrument, \clockTick,
        \out, ~synthBus,
        \dur, 0.5 * 0.9969,
        \freq, Pwhite(4200, 5200, inf),
        \amp, 0,
        \pan, Pwhite(-0.8, 0.8, inf)
    );
    Pbindef(\carillon,
        \instrument, \carillonBell,
        \out, ~synthBus,
        \dur, Pseq([2.0, 1.5, 3.0, 2.5], inf),
        \freq, Pseq([660, 785, 880, 587], inf),
        \amp, 0,
        \pan, Pwhite(-0.5, 0.5, inf)
    );

    Tdef(\masterScore, {
        "0:00 - [Cue 1: A Oficina Estreita]".postln;
        Pbindef(\clockA, \amp, Pwhite(0.08, 0.14, inf));
        Pbindef(\clockA).play;
        Ndef(\gearBreath).xset(\amp, 0.5);
        8.wait;

        "0:08 - [Cue 2: Duzentos Relógios]".postln;
        Pbindef(\clockB, \amp, Pwhite(0.05, 0.1, inf)).play;
        Pbindef(\clockC, \amp, Pwhite(0.03, 0.07, inf)).play;
        4.do { |i|
            Ndef(\gearBreath).xset(\cutoff, 600 + (i * 250));
            4.wait;
        };

        "0:32 - [Cue 3: Carrilhões]".postln;
        Pbindef(\carillon, \amp, 0.12).play;
        Ndef(\timeBreath).xset(\amp, 0.25, \cutoff, 900);
        4.do { |i|
            Ndef(\timeBreath).xset(\cutoff, exprand(500, 2200));
            3.wait;
        };

        "0:56 - [Cue 4: Intrinsic Limit - Defasagem Máxima]".postln;
        6.do { |i|
            Pbindef(\clockB, \dur, 0.5 * (1 + (i * 0.012)));
            Pbindef(\clockC, \dur, 0.5 * (1 - (i * 0.012)));
            3.wait;
        };

        "1:14 - [Cue 5: Settling - Respiração Frágil]".postln;
        Pbindef(\clockB).stop;
        Pbindef(\clockC).stop;
        Pbindef(\carillon).stop;
        Pbindef(\clockA, \dur, 1.0);
        Ndef(\timeBreath).xset(\amp, 0.05);
        Ndef(\gearBreath).xset(\cutoff, 300);
        8.wait;

        "1:22 - [Cue 6: Resolution - Uníssono Reencontrado]".postln;
        Pbindef(\clockA, \dur, 0.5);
        Pbindef(\clockB, \dur, 0.5 * 1.0031).play;
        Pbindef(\clockC, \dur, 0.5 * 0.9969).play;
        Pbindef(\carillon).play;
        Ndef(\timeBreath).xset(\amp, 0.2, \cutoff, 1400);
        Ndef(\masterMix).set(\wet10, 0.3);
        10.wait;

        "1:35 - [Cue 7: Extrinsic Limit - Silêncio do Relógio]".postln;
        Ndef(\masterMix).fadeTime = 6;
        Ndef(\masterMix).xset(\wet10, 0);
        Ndef(\gearBreath).xset(\amp, 0);
        Ndef(\timeBreath).xset(\amp, 0);
        Pbindef(\clockA).stop;
        Pbindef(\clockB).stop;
        Pbindef(\clockC).stop;
        Pbindef(\carillon).stop;
        7.wait;

        Pbindef(\clockA).clear;
        Pbindef(\clockB).clear;
        Pbindef(\clockC).clear;
        Pbindef(\carillon).clear;
        Ndef(\gearBreath).clear(3);
        Ndef(\timeBreath).clear(3);
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
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

    // Safety limiter
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete sources
    SynthDef(\gotaDrip, { |freq=1200, amp=0.2, pan=0, decay=0.6|
        var env, pitch, sig;
        env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), doneAction: 2);
        pitch = XLine.kr(freq * 1.8, freq * 0.6, 0.08);
        sig = SinOsc.ar(pitch) * env;
        sig = sig + (HPF.ar(WhiteNoise.ar, 4000) * env * 0.04);
        Out.ar(~synthBus, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\caveBoom, { |freq=55, amp=0.4, pan=0, ring=4|
        var env, exciter, sig;
        env = EnvGen.ar(Env.perc(0.01, ring, 1, -3), doneAction: 2);
        exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        sig = DynKlank.ar(Ref([ [freq, freq * 2.76, freq * 5.4, freq * 8.93], [1, 0.5, 0.25, 0.1], [ring, ring * 0.7, ring * 0.5, ring * 0.3] ]), exciter);
        sig = LeakDC.ar(sig) * env * 0.3;
        Out.ar(~synthBus, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\stalBell, { |freq=880, amp=0.15, pan=0|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.003, 2.5, 1, -5), doneAction: 2);
        mod = SinOsc.ar(freq * 3.51) * freq * 1.2 * EnvGen.ar(Env.perc(0.001, 0.6));
        sig = SinOsc.ar(freq + mod) * env;
        Out.ar(~synthBus, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\cavernWind, { |amp=0, cutoff=400|
        var sig, mod;
        sig = BrownNoise.ar(0.4);
        mod = LFNoise2.kr(0.07).range(0.3, 1);
        sig = BPF.ar(sig, cutoff * LFNoise2.kr(0.05).range(0.8, 1.25), 0.2) * 6;
        Pan2.ar(sig * mod * amp, LFNoise2.kr(0.03));
    });
    Ndef(\aquiferDrone, { |amp=0, cutoff=900|
        var drift, sig;
        drift = LFNoise2.kr(0.08).range(0.997, 1.003);
        sig = Mix(SinOsc.ar([55, 55.4, 82.4, 110.2] * drift, 0, 0.12));
        sig = LPF.ar(sig, cutoff);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\cavernWind).play;
    Ndef(\aquiferDrone).play;

    // Master mixer with wet-only cavern room
    Ndef(\masterMix, {
        var synths, cont;
        synths = In.ar(~synthBus, 2);
        cont = Ndef.ar(\cavernWind, 2) + Ndef.ar(\aquiferDrone, 2);
        synths + cont;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.2);
    };
    Ndef(\masterMix).set(\wet10, 0.35);
    Ndef(\masterMix).play;
    s.sync;

    // Event patterns
    Pbindef(\drips,
        \instrument, \gotaDrip,
        \out, ~synthBus,
        \dur, Pwhite(0.4, 1.6, inf),
        \freq, Pwhite(900, 2400, inf),
        \decay, Pwhite(0.3, 0.9, inf),
        \amp, 0.2,
        \pan, Pwhite(-0.8, 0.8, inf)
    );
    Pbindef(\halls,
        \instrument, \caveBoom,
        \out, ~synthBus,
        \dur, Pseq([3.0, 5.0, 4.0], inf),
        \freq, Pseq([55, 41.2, 36.7, 48.9], inf),
        \ring, Pwhite(3.0, 6.0, inf),
        \amp, 0.5,
        \pan, Pwhite(-0.4, 0.4, inf)
    );
    Pbindef(\stalBells,
        \instrument, \stalBell,
        \out, ~synthBus,
        \dur, Pseq([1.5, 0.75, 2.25, 0.75], inf),
        \freq, Pseq([523.25, 659.25, 784.0, 587.33], inf),
        \amp, 0.1,
        \pan, Pwhite(-0.6, 0.6, inf)
    );

    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: Gota no Escuro]".postln;
        Ndef(\cavernWind).fadeTime = 6;
        Ndef(\cavernWind).xset(\amp, 0.4, \cutoff, 300);
        Pbindef(\drips, \amp, Pexprand(0.1, 0.3, inf)).play;
        8.wait;

        "0:08 - [Cue 2: Primeiro Salão - Abóbada Úmida]".postln;
        Ndef(\aquiferDrone).fadeTime = 5;
        Ndef(\aquiferDrone).xset(\amp, 0.25, \cutoff, 500);
        Pbindef(\halls, \amp, 0.5).play;
        4.do { |i|
            Ndef(\cavernWind).xset(\cutoff, 300 + (i * 150));
            4.wait;
        };

        "0:24 - [Cue 3: Cortinas Minerais - Estalactites]".postln;
        Pbindef(\stalBells, \amp, Pexprand(0.05, 0.15, inf)).play;
        6.do { |i|
            Pbindef(\drips, \dur, Pwhite(0.08, 0.6 - (i * 0.09), inf));
            Ndef(\aquiferDrone).xset(\cutoff, 500 + (i * 120));
            4.wait;
        };

        "0:48 - [Cue 4: Intrinsic Limit - Salão Profundo]".postln;
        Pbindef(\halls, \dur, Pseq([2.0, 2.5, 1.5], inf));
        Ndef(\masterMix).xset(\wet10, 0.55);
        6.do { |i|
            Ndef(\cavernWind).xset(\cutoff, exprand(150, 900));
            Pbindef(\halls, \freq, Pseq([55, 41.2, 36.7, 48.9] * (1 - (i * 0.06)), inf));
            4.wait;
        };

        "1:12 - [Cue 5: Settling - Gota Solitária]".postln;
        Pbindef(\halls).stop;
        Pbindef(\stalBells).stop;
        Pbindef(\drips, \dur, Pwhite(2.0, 3.0, inf), \amp, 0.25);
        Ndef(\cavernWind).xset(\amp, 0.1, \cutoff, 200);
        Ndef(\aquiferDrone).xset(\amp, 0.1);
        8.wait;

        "1:20 - [Cue 6: Resolução - Eco de Peter Lund]".postln;
        Pbindef(\halls, \freq, Pseq([55, 41.2, 36.7, 48.9], inf), \dur, Pseq([3.0, 5.0, 4.0], inf)).play;
        Pbindef(\stalBells, \amp, 0.1).play;
        Ndef(\cavernWind).xset(\amp, 0.35, \cutoff, 700);
        Ndef(\aquiferDrone).xset(\amp, 0.25, \cutoff, 900);
        Ndef(\masterMix).xset(\wet10, 0.5);
        8.wait;

        "1:32 - [Cue 7: Extrinsic Limit - Silêncio da Gruta]".postln;
        Ndef(\masterMix).fadeTime = 6;
        Ndef(\masterMix).xset(\wet10, 0);
        Ndef(\cavernWind).xset(\amp, 0);
        Ndef(\aquiferDrone).xset(\amp, 0);
        Pbindef(\drips).stop;
        Pbindef(\halls).stop;
        Pbindef(\stalBells).stop;
        7.wait;

        Pbindef(\drips).clear;
        Pbindef(\halls).clear;
        Pbindef(\stalBells).clear;
        Ndef(\cavernWind).clear(3);
        Ndef(\aquiferDrone).clear(3);
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

