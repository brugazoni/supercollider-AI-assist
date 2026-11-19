// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-13T11:15:06.425726+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\anniversaryDrone, { |freq=110, amp=0.08, pan=0, t_trig=0|
    var env = EnvGen.kr(Env.perc(0.8, 5.5), t_trig);
    var tone = SinOsc.ar(freq) + (SinOsc.ar(freq * 1.003) * 0.35);
    Pan2.ar(tone * env * amp, pan);
}).play;

Pbindef(\anniversarySeq,
    \dur, Pseq([3, 3, 4, 2], inf),
    \freq, Pseq([110, 110, 103.83, 110], inf),
    \t_trig, 1,
    \amp, Pseq([0.07, 0.065, 0.055, 0.045], inf),
    \pan, Pseq([-0.12, 0.08, 0.12, -0.08], inf)
);
Ndef(\anniversaryDrone)[1] = \set -> Pbindef(\anniversarySeq);

// The map lesson: small, precise folds interrupt the otherwise composed dinner.
Ndef(\mapFolds, { |freq=1200, amp=0.06, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.001, 0.045), K2A.ar(t_trig));
    var click = BPF.ar(WhiteNoise.ar, freq, 0.22) * 5;
    Pan2.ar(click * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([1.5, 0.75, 0.75, 1, 0.5, 0.5], inf),
    \freq, Pseq([900, 1500, 1100, 1900, 1300, 2200], inf),
    \t_trig, 1,
    \amp, Pseq([0.035, 0.04, 0.035, 0.045, 0.04, 0.055], inf),
    \pan, Pseq([-0.35, 0.25, -0.2, 0.35, -0.1, 0.2], inf)
);
Ndef(\mapFolds)[1] = \set -> Pbindef(\mapFoldSeq);

// The suspended waiter and gathering Antarctic hush: an increasingly dense, low wind.
Ndef(\antarcticHush, { |cutoff=420, amp=0.035, pan=0, t_trig=0|
    var swell = LFNoise1.kr(0.12).range(0.35, 1);
    var wind = LPF.ar(PinkNoise.ar, cutoff) * 4;
    var undertone = SinOsc.ar(48) * 0.35;
    Pan2.ar((wind + undertone) * swell * amp, pan);
}).play;

Pbindef(\antarcticSeq,
    \dur, Pseq([4, 3, 2, 1.5, 1, 0.75], inf),
    \cutoff, Pseq([420, 550, 760, 1050, 1450, 1900], inf),
    \t_trig, 1,
    \amp, Pseq([0.025, 0.028, 0.032, 0.036, 0.04, 0.045], inf),
    \pan, 0
);
Ndef(\antarcticHush)[1] = \set -> Pbindef(\antarcticSeq);

// Rollback: remove the anniversary drone.
// Pbindef(\anniversarySeq).stop; Ndef(\anniversaryDrone).fadeTime = 2; Ndef(\anniversaryDrone).clear(2);

// Rollback: remove the map-fold clicks.
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFolds).fadeTime = 2; Ndef(\mapFolds).clear(2);

// Rollback: remove the Antarctic hush.
// Pbindef(\antarcticSeq).stop; Ndef(\antarcticHush).fadeTime = 2; Ndef(\antarcticHush).clear(2);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\correnteLamento, { |freq=180, amp=0.045, pan=0, t_trig=0, ring=2.8|
    var hit = Decay2.ar(K2A.ar(t_trig), 0.002, 0.12);
    var exciter = (Impulse.ar(0) + (WhiteNoise.ar * hit * 0.18)) * hit;
    var metal = Ringz.ar(exciter, [freq, freq * 1.41, freq * 2.37], ring).sum;
    var lament = SinOsc.ar(freq * 0.503) * Decay2.ar(K2A.ar(t_trig), 0.04, 1.8) * 0.25;
    Pan2.ar((metal + lament) * amp, pan);
}).play;

Pbindef(\correnteLamentoSeq,
    \dur, Pseq([3, 2, 1.5, 1, 0.75, 0.5], inf),
    \freq, Pseq([180, 161, 143, 127, 110, 98], inf),
    \ring, Pseq([3.2, 2.8, 2.4, 2, 1.6, 1.2], inf),
    \t_trig, 1,
    \amp, Pseq([0.025, 0.03, 0.035, 0.04, 0.045, 0.05], inf),
    \pan, Pseq([-0.3, 0.2, -0.15, 0.3, -0.25, 0.1], inf)
);
Ndef(\correnteLamento)[1] = \set -> Pbindef(\correnteLamentoSeq);

// O tinir se adensa e desce até o limite; a queda abre caminho ao silêncio.
Pbindef(\correnteLamentoSeq).play;

// Pbindef(\correnteLamentoSeq).stop; Ndef(\correnteLamento).fadeTime = 2; Ndef(\correnteLamento).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockSynth, tickPattern, texture, mix;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\santaEfigeniaTick, { |out=0, freq=1200, amp=0.04, pan=0, decay=0.045|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var strike = (BPF.ar(WhiteNoise.ar, freq, 0.18) * 4)
            + (SinOsc.ar(freq * 0.73) * 0.35);
        Out.ar(out, Pan2.ar(strike * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\santaEfigeniaBreath, { |cutoff=1700, drift=0.08, amp=0|
        var pulse = SinOsc.kr(drift).range(0.25, 1);
        var air = BPF.ar(PinkNoise.ar, cutoff, 0.55) * 2.2;
        var low = SinOsc.ar(55) * 0.12;
        var stereo = [air + low, DelayC.ar(air, 0.04, 0.013) + low];
        stereo * pulse * amp;
    });
    Ndef(\santaEfigeniaBreath).fadeTime = 3;
    Ndef(\santaEfigeniaBreath).xset(\amp, 0);

    Ndef(\santaEfigeniaMix, {
        var sig = In.ar(~synthBus, 2) + Ndef(\santaEfigeniaBreath).ar(2);
        sig;
    });
    Ndef(\santaEfigeniaMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.22);
    };
    Ndef(\santaEfigeniaMix)[11] = \filter -> { |in|
        LPF.ar(in, 10500);
    };
    Ndef(\santaEfigeniaMix).set(\wet10, 0.22, \wet11, 0.18);
    Ndef(\santaEfigeniaMix).play;
    s.sync;

    Pbindef(\santaEfigeniaClock,
        \instrument, \santaEfigeniaTick,
        \out, ~synthBus,
        \dur, Pseq([0.47, 0.53, 0.49, 0.51, 0.72, 0.28], inf),
        \freq, Pseq([1320, 790, 1680, 1030, 2210, 910, 1450, 680], inf),
        \decay, Pseq([0.035, 0.055, 0.025, 0.07, 0.03, 0.045], inf),
        \amp, Pseq([0.045, 0.038, 0.05, 0.034, 0.042, 0.048], inf),
        \pan, Pseq([-0.82, 0.66, -0.38, 0.9, -0.65, 0.28, 0.72, -0.12], inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - Oficina estreita: engrenagens começam a divergir.".postln;
        Pbindef(\santaEfigeniaClock).play;
        Ndef(\santaEfigeniaBreath).xset(\amp, 0.018, \cutoff, 900);
        6.wait;

        "0:06 - Enxame de latão: pequenas defasagens cruzam a sala.".postln;
        Pbindef(\santaEfigeniaClock,
            \dur, Pseq([0.31, 0.68, 0.43, 0.56, 0.25, 0.77, 0.39, 0.61], inf),
            \pan, Pseq([-0.9, 0.75, -0.2, 0.42, 0.93, -0.62, 0.12, -0.78], inf)
        );
        Ndef(\santaEfigeniaBreath).xset(\amp, 0.026, \cutoff, 1500);
        4.do({ |j|
            Ndef(\santaEfigeniaBreath).xset(\cutoff, [1100, 2100, 1450, 2600].at(j));
            3.wait;
        });

        "0:18 - Carrilhões franceses abrem um brilho irregular.".postln;
        Pbindef(\santaEfigeniaClock,
            \dur, Pseq([0.22, 0.28, 0.5, 0.24, 0.72, 0.36], inf),
            \freq, Pseq([1760, 2630, 1180, 2340, 880, 1980, 1470, 3100], inf),
            \amp, Pseq([0.04, 0.045, 0.052, 0.038, 0.043, 0.05], inf)
        );
        4.wait;

        "0:22 - Limite: o mecanismo acelera até quase perder o pulso.".postln;
        Pbindef(\santaEfigeniaClock,
            \dur, Pseq([0.18, 0.16, 0.14, 0.21, 0.12, 0.25], inf),
            \freq, Pseq([920, 1380, 2080, 1110, 2460, 1640], inf)
        );
        Ndef(\santaEfigeniaBreath).xset(\amp, 0.012, \cutoff, 3400);
        5.wait;

        "0:27 - Flashback: quase silêncio, um cronômetro solitário.".postln;
        Pbindef(\santaEfigeniaClock,
            \dur, Pseq([1.1, 0.9, 1.3, 0.7], inf),
            \freq, Pseq([1320, 790, 1320, 1030], inf),
            \amp, Pseq([0.025, 0.019, 0.022, 0.016], inf),
            \pan, Pseq([-0.08, 0.1, -0.04, 0.06], inf)
        );
        Ndef(\santaEfigeniaBreath).xset(\amp, 0.01, \cutoff, 650);
        6.wait;

        "0:33 - O relojoeiro escuta o próprio respirar do tempo.".postln;
        Pbindef(\santaEfigeniaClock,
            \dur, Pseq([0.47, 0.53, 0.49, 0.51], inf),
            \freq, Pseq([1320, 790, 1320, 1030], inf),
            \amp, Pseq([0.03, 0.024, 0.028, 0.022], inf)
        );
        Ndef(\santaEfigeniaBreath).xset(\amp, 0.022, \cutoff, 1050);
        5.wait;

        "0:38 - Resolução: o primeiro tique regressa, depois a oficina se apaga.".postln;
        Pbindef(\santaEfigeniaClock).stop;
        Ndef(\santaEfigeniaBreath).xset(\amp, 0);
        2.wait;
        Pbindef(\santaEfigeniaClock).clear;
        Ndef(\santaEfigeniaBreath).clear(2);
        Ndef(\santaEfigeniaMix).clear(2);
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

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\maqDrip, { |out=0, freq=900, amp=0.04, decay=1, pan=0|
        var env, ping, body, sig;
        env = EnvGen.ar(Env.perc(0.002, decay.max(0.05)), doneAction: 2);
        ping = SinOsc.ar(freq * 1.73 + (SinOsc.ar(freq * 2.71) * freq * 0.18));
        body = DynKlank.ar(Ref([[freq * 0.5, freq, freq * 1.49, freq * 2.32], [0.4, 1, 0.32, 0.16], [decay, decay * 0.8, decay * 0.55, decay * 0.38]]), Impulse.ar(0));
        sig = (ping * 0.28 + body * 0.72) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\maqStone, { |out=0, freq=110, amp=0.035, decay=2, pan=0|
        var env, exc, modes, sig;
        env = EnvGen.ar(Env.perc(0.003, decay.max(0.05)), doneAction: 2);
        exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.035));
        modes = DynKlank.ar(Ref([[freq, freq * 1.414, freq * 2.09, freq * 2.76], [1, 0.48, 0.24, 0.12], [decay, decay * 0.8, decay * 0.62, decay * 0.45]]), exc);
        sig = (modes + SinOsc.ar(freq * 0.5) * 0.22) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    Ndef(\maqWater, { |cutoff=1200, drift=0.07, amp=0|
        var pulse, droplets, air, stereo;
        pulse = SinOsc.kr(drift).range(0.28, 1);
        droplets = BPF.ar(WhiteNoise.ar, LFNoise1.kr(0.23).range(350, 2400), 0.045) * 5;
        air = BPF.ar(PinkNoise.ar, cutoff, 0.42) * 1.5;
        stereo = [air + droplets * 0.35, DelayC.ar(air + droplets * 0.35, 0.05, 0.021)];
        stereo * pulse * amp;
    });
    Ndef(\maqWater).fadeTime = 4;
    Ndef(\maqWater).xset(\amp, 0);

    Ndef(\maqResonance, { |freq=46, amp=0|
        var breath, harmonic, stereo;
        breath = SinOsc.kr(0.035).range(0.35, 1);
        harmonic = SinOsc.ar(freq) * 0.18 + SinOsc.ar(freq * 2.01) * 0.12;
        stereo = [harmonic, DelayC.ar(harmonic, 0.08, 0.037)];
        stereo * breath * amp;
    });
    Ndef(\maqResonance).fadeTime = 5;
    Ndef(\maqResonance).xset(\amp, 0);

    Ndef(\maqMix, {
        var sig;
        sig = In.ar(~synthBus, 2) + Ndef(\maqWater).ar(2) + Ndef(\maqResonance).ar(2);
        sig;
    });
    Ndef(\maqMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.24);
    };
    Ndef(\maqMix)[11] = \filter -> { |in|
        LPF.ar(in, 11500);
    };
    Ndef(\maqMix).set(\wet10, 0.28, \wet11, 0.12);
    Ndef(\maqMix).play;
    s.sync;

    Pbindef(\maqDrips,
        \instrument, \maqDrip,
        \out, ~synthBus,
        \dur, Pseq([1.2, 0.63, 0.91, 1.47, 0.54, 1.08], inf),
        \freq, Pseq([740, 1120, 560, 930, 1480, 680, 1030], inf),
        \decay, Pseq([1.1, 0.75, 1.4, 0.8, 1.2], inf),
        \amp, Pseq([0.035, 0.027, 0.04, 0.03, 0.036], inf),
        \pan, Pseq([-0.8, 0.52, -0.35, 0.9, -0.62, 0.18], inf)
    );

    Pbindef(\maqStonefalls,
        \instrument, \maqStone,
        \out, ~synthBus,
        \dur, Pseq([4.5, 5.5, 3.8, 6.2], inf),
        \freq, Pseq([73, 82, 65, 92, 73], inf),
        \decay, Pseq([3.8, 4.6, 3.2, 4.1], inf),
        \amp, Pseq([0.032, 0.026, 0.038, 0.03], inf),
        \pan, Pseq([-0.3, 0.22, 0.4, -0.18], inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - Primeiro salão: o gotejo encontra a abóbada calcária.".postln;
        Pbindef(\maqDrips).play;
        Ndef(\maqWater).xset(\amp, 0.012, \cutoff, 900);
        Ndef(\maqResonance).xset(\amp, 0.012, \freq, 46);
        6.wait;

        "0:06 - Cortinas minerais: gotas irregulares desenham o espaço.".postln;
        Pbindef(\maqDrips,
            \dur, Pseq([0.42, 0.86, 0.57, 1.1, 0.34, 0.73], inf),
            \pan, Pseq([-0.92, 0.71, -0.22, 0.48, 0.87, -0.58], inf)
        );
        Ndef(\maqWater).xset(\amp, 0.018, \cutoff, 1500);
        4.do({ |j|
            Ndef(\maqWater).xset(\cutoff, [740, 1800, 1100, 2300].at(j));
            3.wait;
        });

        "0:18 - Salão amplo: estalagmites respondem em modos profundos.".postln;
        Pbindef(\maqStonefalls).play;
        Ndef(\maqResonance).xset(\amp, 0.024, \freq, 52);
        Pbindef(\maqDrips,
            \dur, Pseq([0.31, 0.48, 0.72, 0.38, 0.59], inf),
            \freq, Pseq([1480, 620, 1840, 820, 1230, 560], inf)
        );
        6.wait;

        "0:24 - Limite: o gotejamento acelera até a pedra vibrar.".postln;
        Pbindef(\maqDrips,
            \dur, Pseq([0.19, 0.24, 0.16, 0.29, 0.14, 0.22], inf),
            \freq, Pseq([2140, 1760, 2680, 1320, 2380, 1920], inf),
            \amp, Pseq([0.027, 0.032, 0.025, 0.035], inf)
        );
        Ndef(\maqWater).xset(\amp, 0.022, \cutoff, 3200);
        Ndef(\maqResonance).xset(\amp, 0.03, \freq, 39);
        5.wait;

        "0:29 - Flashback: um único salão, frágil e quase imóvel.".postln;
        Pbindef(\maqDrips,
            \dur, Pseq([1.7, 2.1, 1.4, 2.5], inf),
            \freq, Pseq([740, 560, 740, 930], inf),
            \amp, Pseq([0.018, 0.015, 0.019, 0.014], inf),
            \pan, Pseq([-0.06, 0.08, -0.03, 0.04], inf)
        );
        Pbindef(\maqStonefalls).stop;
        Ndef(\maqWater).xset(\amp, 0.006, \cutoff, 600);
        Ndef(\maqResonance).xset(\amp, 0.016, \freq, 46);
        6.wait;

        "0:35 - Sete salões: a água retorna ao seu centro grave.".postln;
        Pbindef(\maqDrips,
            \dur, Pseq([1.2, 0.63, 0.91, 1.47], inf),
            \freq, Pseq([740, 1120, 560, 930, 740], inf),
            \amp, Pseq([0.025, 0.021, 0.027, 0.023], inf)
        );
        Ndef(\maqWater).xset(\amp, 0.012, \cutoff, 1000);
        Ndef(\maqResonance).xset(\amp, 0.018, \freq, 46);
        5.wait;

        "0:40 - Resolução: o último gotejo se dissolve na rocha.".postln;
        Pbindef(\maqDrips).stop;
        Pbindef(\maqStonefalls).stop;
        Ndef(\maqWater).xset(\amp, 0);
        Ndef(\maqResonance).xset(\amp, 0);
        3.wait;
        Pbindef(\maqDrips).clear;
        Pbindef(\maqStonefalls).clear;
        Ndef(\maqWater).clear(2);
        Ndef(\maqResonance).clear(2);
        Ndef(\maqMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

