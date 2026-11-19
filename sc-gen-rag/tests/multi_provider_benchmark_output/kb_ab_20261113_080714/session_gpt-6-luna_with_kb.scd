// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-13T11:24:19.651108+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\mapFold, { |freq=1800, amp=0.12, pan=0, t_trig=0, crackle=0.4|
    var env, paper, crease, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.32, 1, -7), t_trig);
    paper = BPF.ar(WhiteNoise.ar, freq.clip(500, 9000), 0.22) * 5;
    crease = SinOsc.ar(freq * 0.73, 0, 0.25) + (WhiteNoise.ar * crackle);
    sig = (paper + crease) * env;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([0.18, 0.18, 0.36, 0.72, 0.18, 0.54], inf),
    \t_trig, 1,
    \freq, Pseq([3200, 1400, 5100, 900, 2600, 1800], inf),
    \crackle, Pwhite(0.15, 0.65, inf),
    \amp, Pseq([0.08, 0.13, 0.09, 0.16, 0.07, 0.11], inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

Ndef(\mapFold)[10] = \filter -> { |in|
    CombC.ar(in, 0.35, [0.19, 0.27], 1.8);
};
Ndef(\mapFold).set(\wet10, 0);

Ndef(\stormSilence, { |freq=46, amp=0.16, pan=0, t_trig=0, pressure=0.4|
    var swell, sub, wind, sig;
    swell = EnvGen.ar(Env.perc(0.04, 5.5, 1, -3), t_trig);
    sub = SinOsc.ar(freq) * 0.35 + SinOsc.ar(freq * 2) * 0.18;
    wind = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.08).range(180, 950), 0.35) * pressure;
    sig = (sub + wind) * (0.35 + (swell * 0.65));
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\stormSilenceSeq,
    \dur, Pseq([3.5, 5, 4, 6], inf),
    \t_trig, 1,
    \freq, Pseq([46, 43, 41, 38], inf),
    \pressure, Pseq([0.25, 0.4, 0.55, 0.7], inf),
    \amp, 0.16,
    \pan, Pseq([-0.15, 0.15], inf)
);
Ndef(\stormSilence)[1] = \set -> Pbindef(\stormSilenceSeq);

Ndef(\stormSilence)[11] = \filter -> { |in|
    FreeVerb.ar(in, 0.85, 0.94, 0.25);
};
Ndef(\stormSilence).set(\wet11, 0);

// A tensão cresce até ao limite: a tempestade antártica suspende a conversa.
Pbindef(\mapFoldSeq, \dur, Pseq([0.12, 0.12, 0.24, 0.48], inf));
// Pbindef(\mapFoldSeq, \dur, Pseq([0.18, 0.18, 0.36, 0.72, 0.18, 0.54], inf)); // Revert sequence
Ndef(\stormSilence).xset(\pressure, 0.7);
// Ndef(\stormSilence).xset(\pressure, 0.4); // Revert tweak

// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument
// Pbindef(\stormSilenceSeq).stop; Ndef(\stormSilence).fadeTime = 2; Ndef(\stormSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\chainElegy, { |freq=320, amp=0.08, pan=0, t_trig=0, strike=0.5|
    var hit, metal, breath, sig;
    hit = Decay2.ar(K2A.ar(t_trig), 0.001, 0.18) * (WhiteNoise.ar * strike + Impulse.ar(0));
    metal = Ringz.ar(hit, [freq, freq * 1.47, freq * 2.13], [1.8, 1.2, 0.7]).sum;
    breath = BPF.ar(PinkNoise.ar, freq * 3, 0.4) * Decay2.ar(K2A.ar(t_trig), 0.003, 0.32);
    sig = metal + (breath * 0.16);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\chainElegySeq,
    \dur, Pseq([0.24, 0.24, 0.48, 0.96, 0.24, 0.72], inf),
    \t_trig, 1,
    \freq, Pseq([196, 233, 175, 147, 220, 164], inf),
    \strike, Pseq([0.35, 0.65, 0.45, 0.8, 0.4, 0.7], inf),
    \amp, Pseq([0.07, 0.11, 0.08, 0.13, 0.07, 0.1], inf),
    \pan, Pwhite(-0.65, 0.65, inf)
);
Ndef(\chainElegy)[1] = \set -> Pbindef(\chainElegySeq);

Ndef(\chainElegy)[12] = \filter -> { |in|
    FreeVerb.ar(in, 0.75, 0.88, 0.3);
};
Ndef(\chainElegy).set(\wet12, 0);

// A corrente aperta num limite de densidade crescente: o tinir insiste até tocar o silêncio.
Pbindef(\chainElegySeq, \dur, Pseq([0.24, 0.18, 0.12, 0.08], inf));
// Pbindef(\chainElegySeq, \dur, Pseq([0.24, 0.24, 0.48, 0.96, 0.24, 0.72], inf)); // Revert sequence

// Pbindef(\chainElegySeq).stop; Ndef(\chainElegy).fadeTime = 2; Ndef(\chainElegy).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var tickDef, chimeDef, breathDef;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    tickDef = SynthDef(\atelierTick, { |out=0, freq=1800, amp=0.08, pan=0, decay=0.045, tone=0.3|
        var env, click, ring, sig;
        env = EnvGen.ar(Env.perc(0.001, decay, 1, -8), doneAction: 2);
        click = BPF.ar(WhiteNoise.ar, freq.clip(500, 9000), 0.16) * 6;
        ring = SinOsc.ar(freq * [1, 1.47]).sum * tone;
        sig = (click + ring) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    chimeDef = SynthDef(\atelierChime, { |out=0, freq=440, amp=0.06, pan=0, decay=2|
        var env, exc, modes, sig;
        env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        exc = Decay2.ar(Impulse.ar(0), 0.001, 0.035);
        modes = Ringz.ar(exc, freq * [1, 2.71, 3.92, 5.43], [decay, decay * 0.7, decay * 0.45, decay * 0.3], [1, 0.45, 0.25, 0.15]).sum;
        sig = modes * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    breathDef = SynthDef(\atelierBreath, { |out=0, freq=110, amp=0.06, pan=0, dur=5|
        var env, air, pulse, sig;
        env = EnvGen.ar(Env.perc(0.08, dur, 1, -4), doneAction: 2);
        air = BPF.ar(PinkNoise.ar, SinOsc.kr(0.17).range(240, 760), 0.5) * 2;
        pulse = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
        sig = (air * 0.24 + pulse * 0.2) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    Ndef(\clockPhase, { |rate=1, width=0.12, amp=0|
        var trig, body, tick, sig;
        trig = Impulse.ar(rate + SinOsc.kr(0.071).range(-0.025, 0.025));
        body = Decay2.ar(trig, 0.001, width);
        tick = BPF.ar(WhiteNoise.ar, LFNoise1.kr(0.6).range(1100, 3400), 0.22) * 3;
        sig = Pan2.ar(tick * body * amp, LFNoise1.kr(0.23).range(-0.8, 0.8));
    });
    Ndef(\brassBreath, { |freq=55, shimmer=0.2, amp=0|
        var low, upper, air, sig;
        low = SinOsc.ar(freq) * 0.25 + SinOsc.ar(freq * 2) * 0.15;
        upper = Mix([SinOsc.ar(freq * 3.01), SinOsc.ar(freq * 4.97), SinOsc.ar(freq * 7.03)]) * shimmer * 0.06;
        air = BPF.ar(PinkNoise.ar, SinOsc.kr(0.09).range(180, 520), 0.4) * 0.04;
        sig = Splay.ar([low + upper + air, low * 0.8 + upper * 1.1 + air]);
        sig * amp;
    });
    Ndef(\clockPhase).fadeTime = 3;
    Ndef(\brassBreath).fadeTime = 5;

    Ndef(\atelierMix, {
        var events, textures;
        events = In.ar(~synthBus, 2);
        textures = Ndef.ar(\clockPhase, 2) + Ndef.ar(\brassBreath, 2);
        events + textures;
    });
    Ndef(\atelierMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.28);
    };
    Ndef(\atelierMix)[11] = \filter -> { |in|
        var delayed;
        delayed = CombC.ar(in, 0.3, [0.19, 0.263], 1.2);
        delayed;
    };
    Ndef(\atelierMix).set(\wet10, 0, \wet11, 0);
    Ndef(\atelierMix).play;
    s.sync;

    Pbindef(\atelierTicks,
        \instrument, \atelierTick,
        \out, ~synthBus,
        \dur, Pseq([0.5, 0.5, 0.75, 0.25, 0.5, 1.0], inf),
        \freq, Pseq([1900, 1420, 2300, 1700, 2050, 1280], inf),
        \decay, Pwhite(0.025, 0.07, inf),
        \tone, Pwhite(0.15, 0.4, inf),
        \amp, Pwhite(0.035, 0.07, inf),
        \pan, Pwhite(-0.85, 0.85, inf)
    );
    Pbindef(\atelierChimes,
        \instrument, \atelierChime,
        \out, ~synthBus,
        \dur, Pseq([3, 4, 2, 5, 3], inf),
        \freq, Pseq([523.25, 659.25, 783.99, 587.33, 440], inf),
        \decay, Pwhite(1.3, 2.8, inf),
        \amp, Pwhite(0.025, 0.055, inf),
        \pan, Pwhite(-0.7, 0.7, inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - [A oficina: engrenagens desencontradas]".postln;
        Ndef(\clockPhase).xset(\amp, 0.42, \rate, 1.9);
        Ndef(\atelierMix).set(\wet10, 0.12);
        Pbindef(\atelierTicks).play;

        5.do { |i|
            Ndef(\clockPhase).xset(\rate, 1.6 + (i * 0.22), \width, 0.08 + (i * 0.018));
            3.wait;
        };

        "0:15 - [Carrilhões: pequenas distâncias entre os metais]".postln;
        Pbindef(\atelierChimes).play;
        Ndef(\atelierMix).set(\wet10, 0.3, \wet11, 0.18);
        4.do { |i|
            Ndef(\clockPhase).xset(\rate, 2.8 + (i * 0.5));
            2.wait;
        };

        "0:23 - [O enxame acelera até ao limite]".postln;
        Pbindef(\atelierTicks, \dur, Pseq([0.25, 0.125, 0.25, 0.125, 0.5], inf));
        Ndef(\clockPhase).xset(\amp, 0.55);
        4.do { |i|
            Ndef(\atelierMix).set(\wet10, 0.22 + (i * 0.08));
            2.wait;
        };

        "0:31 - [O relojoeiro fecha os olhos]".postln;
        Pbindef(\atelierTicks).stop;
        Pbindef(\atelierChimes).stop;
        Ndef(\clockPhase).fadeTime = 2;
        Ndef(\clockPhase).xset(\amp, 0.08, \rate, 0.72);
        Ndef(\brassBreath).fadeTime = 3;
        Ndef(\brassBreath).xset(\amp, 0.42, \freq, 55, \shimmer, 0.28);
        3.wait;
        Synth(\atelierBreath, [\out, ~synthBus, \freq, 55, \amp, 0.08, \dur, 5, \pan, 0]);

        4.do { |i|
            Ndef(\brassBreath).xset(\shimmer, 0.28 - (i * 0.05));
            2.wait;
        };

        "0:42 - [O tempo respira; retorno ao primeiro tique]".postln;
        Ndef(\brassBreath).fadeTime = 4;
        Ndef(\brassBreath).xset(\amp, 0);
        Ndef(\clockPhase).fadeTime = 4;
        Ndef(\clockPhase).xset(\amp, 0.38, \rate, 1.9);
        Ndef(\atelierMix).set(\wet10, 0.1, \wet11, 0);
        Pbindef(\atelierTicks,
            \dur, Pseq([0.5, 0.5, 0.75, 0.25, 0.5, 1.0], inf),
            \amp, Pwhite(0.025, 0.05, inf)
        ).play;
        4.do { |i|
            Ndef(\clockPhase).xset(\rate, 1.9 + (i * 0.04));
            2.wait;
        };

        "0:50 - [Corte: a oficina suspende o seu mecanismo]".postln;
        Pbindef(\atelierTicks).stop;
        Pbindef(\atelierTicks).clear;
        Pbindef(\atelierChimes).stop;
        Pbindef(\atelierChimes).clear;
        Ndef(\clockPhase).clear(3);
        Ndef(\brassBreath).clear(3);
        Ndef(\atelierMix).clear(3);
        3.wait;
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
    var i;

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

    SynthDef(\calciteDrop, { |out=0, freq=700, decay=1.2, amp=0.06, pan=0|
        var env = EnvGen.ar(Env.perc(0.002, decay), doneAction: 2);
        var strike = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.025));
        var sig = Ringz.ar(strike, freq * [1, 1.51, 2.37], decay * [0.7, 1, 0.55]).sum;
        sig = sig + (SinOsc.ar(freq * 0.5) * env * 0.12);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\limestoneKnock, { |out=0, freq=95, amp=0.08, pan=0, decay=0.22|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var noise = BPF.ar(WhiteNoise.ar, freq * 5, 0.7) * 2;
        var body = SinOsc.ar(freq * [1, 2.03, 3.8], 0, [0.55, 0.22, 0.09]).sum;
        Out.ar(out, Pan2.ar((body + noise * 0.28) * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\caveDraught, { |amp=0, cutoff=520, rate=0.11|
        var wind = BrownNoise.ar(0.32) + PinkNoise.ar(0.12);
        var sway = SinOsc.kr(rate).range(0.55, 1);
        var sig = RLPF.ar(wind, cutoff.clip(80, 5000), 0.32) * sway;
        Pan2.ar(sig * amp, SinOsc.kr(rate * 0.7).range(-0.55, 0.55));
    });
    Ndef(\vaultResonance, { |amp=0, root=54, drift=0.15|
        var mod = LFNoise2.kr(0.08).range(0.985, 1.015);
        var tone = SinOsc.ar(root * [1, 1.5, 2.01, 3.02] * mod, 0, [0.42, 0.24, 0.16, 0.07]).sum;
        var shimmer = SinOsc.ar(root * 6.1 * (1 + (SinOsc.kr(0.07) * drift)), 0, 0.025);
        Pan2.ar((tone + shimmer) * amp, SinOsc.kr(0.035).range(-0.35, 0.35));
    });
    Ndef(\caveDraught).fadeTime = 4;
    Ndef(\vaultResonance).fadeTime = 5;

    Ndef(\maquineMix, {
        var events = In.ar(~synthBus, 2);
        var textures = Ndef.ar(\caveDraught, 2) + Ndef.ar(\vaultResonance, 2);
        events + textures;
    });
    Ndef(\maquineMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.86, 0.24);
    };
    Ndef(\maquineMix)[11] = \filter -> { |in|
        [CombC.ar(in[0], 0.4, 0.23, 1.5), CombC.ar(in[1], 0.4, 0.31, 1.5)];
    };
    Ndef(\maquineMix).set(\wet10, 0, \wet11, 0);
    Ndef(\maquineMix).play;
    s.sync;

    Pbindef(\calciteDrops,
        \instrument, \calciteDrop, \out, ~synthBus,
        \dur, Pseq([2.5, 3.5, 1.75, 4, 2.25], inf),
        \freq, Pseq([698, 523, 784, 587, 440, 659], inf),
        \decay, Pwhite(0.7, 1.8, inf),
        \amp, Pwhite(0.035, 0.065, inf),
        \pan, Pwhite(-0.8, 0.8, inf)
    );
    Pbindef(\stonePulse,
        \instrument, \limestoneKnock, \out, ~synthBus,
        \dur, Pseq([1.5, 1, 2, 0.75, 1.25, 2.5], inf),
        \freq, Pseq([72, 86, 64, 95, 78], inf),
        \decay, Pwhite(0.12, 0.28, inf),
        \amp, Pwhite(0.035, 0.07, inf),
        \pan, Pwhite(-0.65, 0.65, inf)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [A entrada: ar frio sob a rocha]".postln;
        Ndef(\caveDraught).xset(\amp, 0.22, \cutoff, 380, \rate, 0.09);
        Ndef(\maquineMix).set(\wet10, 0.22);
        Pbindef(\calciteDrops).play;
        4.do { |i|
            Ndef(\caveDraught).xset(\cutoff, 300 + (i * 115));
            3.wait;
        };

        "0:12 - [Salões amplos: a pedra começa a responder]".postln;
        Ndef(\vaultResonance).xset(\amp, 0.12, \root, 54);
        Ndef(\maquineMix).set(\wet10, 0.48, \wet11, 0.12);
        5.do { |i|
            Ndef(\vaultResonance).xset(\root, 50 + (i * 2), \drift, 0.12 + (i * 0.035));
            2.wait;
        };

        "0:22 - [Gotejamento nas cortinas minerais]".postln;
        Pbindef(\stonePulse).play;
        Pbindef(\calciteDrops, \dur, Pseq([1.25, 1.75, 0.75, 2.5], inf));
        5.do { |i|
            Ndef(\caveDraught).xset(\cutoff, 900 + (i * 520));
            Ndef(\maquineMix).set(\wet10, 0.45 + (i * 0.07));
            2.wait;
        };

        "0:32 - [Limite: o gotejamento se estreita até o brilho]".postln;
        Pbindef(\stonePulse, \dur, Pseq([0.5, 0.25, 0.75, 0.25, 1], inf));
        Ndef(\caveDraught).xset(\cutoff, 4800, \rate, 0.42);
        4.do { |i|
            Ndef(\vaultResonance).xset(\drift, 0.3 + (i * 0.15));
            1.5.wait;
        };

        "0:38 - [Assentamento: a água desaparece na escuridão]".postln;
        Pbindef(\stonePulse).stop;
        Ndef(\caveDraught).fadeTime = 2;
        Ndef(\caveDraught).xset(\amp, 0.035, \cutoff, 240);
        Ndef(\vaultResonance).xset(\amp, 0.18, \root, 54, \drift, 0.04);
        Ndef(\maquineMix).set(\wet10, 0.68, \wet11, 0.24);
        4.do { |i|
            if (i == 2) {
                Synth(\calciteDrop, [\out, ~synthBus, \freq, 698, \decay, 2.2, \amp, 0.045, \pan, 0]);
            };
            2.wait;
        };

        "0:48 - [Retorno: uma gota encontra a nota inicial]".postln;
        Pbindef(\calciteDrops,
            \dur, Pseq([2.5, 3.5, 1.75, 4, 2.25], inf),
            \freq, Pseq([698, 523, 784, 587, 440, 659], inf),
            \amp, Pwhite(0.025, 0.045, inf)
        );
        Pbindef(\calciteDrops).play;
        Ndef(\vaultResonance).fadeTime = 4;
        Ndef(\vaultResonance).xset(\root, 54, \drift, 0.02);
        3.do { |i|
            Ndef(\maquineMix).set(\wet10, 0.62 - (i * 0.12));
            2.wait;
        };

        "0:54 - [Corte final: sete salões guardam o eco]".postln;
        Pbindef(\calciteDrops).stop;
        Pbindef(\calciteDrops).clear;
        Pbindef(\stonePulse).stop;
        Pbindef(\stonePulse).clear;
        Ndef(\caveDraught).clear(3);
        Ndef(\vaultResonance).clear(4);
        Ndef(\maquineMix).clear(4);
        4.wait;
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

