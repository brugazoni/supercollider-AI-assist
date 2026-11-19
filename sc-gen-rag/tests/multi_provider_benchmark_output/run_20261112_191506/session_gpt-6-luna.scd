// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-12T22:41:47.883343+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\wineSuspended, { |freq=1760, amp=0.12, pan=0.2, t_trig=0|
    var env = EnvGen.kr(Env.perc(0.003, 2.8, 1, -5), t_trig);
    var tone = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.71) * 0.22);
    Pan2.ar(tone * env * amp, pan);
}).play;

Pbindef(\wineSuspendedSeq,
    \dur, Pseq([5, 7, 6, 9], inf),
    \freq, Pseq([1760, 1320, 2093, 1568], inf),
    \t_trig, 1,
    \amp, Pseq([0.10, 0.07, 0.09, 0.05], inf),
    \pan, Pseq([0.2, 0.15, 0.25, 0.1], inf)
);
Ndef(\wineSuspended)[1] = \set -> Pbindef(\wineSuspendedSeq);
Pbindef(\wineSuspendedSeq).play;
// Pbindef(\wineSuspendedSeq).stop; Ndef(\wineSuspended).fadeTime = 2; Ndef(\wineSuspended).clear(2); // Rollback: remove this instrument

Ndef(\mapFolds, { |freq=180, amp=0.16, pan=(-0.3), t_trig=0|
    var env = EnvGen.kr(Env.perc(0.001, 0.11, 1, -7), t_trig);
    var click = WhiteNoise.ar(0.7) + (SinOsc.ar(freq) * 0.3);
    var shaped = BPF.ar(click, freq * 4, 0.45);
    Pan2.ar(shaped * env * amp, pan);
}).play;

Pbindef(\mapFoldsSeq,
    \dur, Pseq([0.75, 1.25, 0.5, 2, 1.5, 3], inf),
    \freq, Pseq([180, 240, 145, 310, 190, 115], inf),
    \t_trig, 1,
    \amp, Pseq([0.14, 0.08, 0.12, 0.06, 0.1, 0.04], inf),
    \pan, Pseq([-0.3, 0.25, -0.15, 0.35, -0.25, 0.1], inf)
);
Ndef(\mapFolds)[1] = \set -> Pbindef(\mapFoldsSeq);
Pbindef(\mapFoldsSeq).play;
// Pbindef(\mapFoldsSeq).stop; Ndef(\mapFolds).fadeTime = 2; Ndef(\mapFolds).clear(2); // Rollback: remove this instrument

Ndef(\antarcticSilence, { |freq=38, amp=0.12, pan=0, t_trig=0|
    var slow = SinOsc.kr(0.035).range(0.985, 1.015);
    var sub = SinOsc.ar(freq * slow);
    var overtone = SinOsc.ar(freq * 2 * slow) * 0.32;
    var pressure = BPF.ar(PinkNoise.ar(0.2), 120, 0.25);
    var sig = (sub + overtone + pressure) * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\antarcticSilenceSeq,
    \dur, Pseq([12, 12, 16, 20], inf),
    \freq, Pseq([38, 38, 41, 38], inf),
    \t_trig, 1,
    \amp, Pseq([0.09, 0.12, 0.14, 0.08], inf),
    \pan, 0
);
Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);
Pbindef(\antarcticSilenceSeq).play;
// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\ironChain, { |freq=740, amp=0.1, pan=0, t_trig=0, decay=1.2|
    var strike = Decay2.ar(K2A.ar(t_trig), 0.001, 0.045) * WhiteNoise.ar(0.8);
    var metal = Ringz.ar(strike, [freq, freq * 1.414, freq * 2.17], decay, [0.45, 0.25, 0.16]).sum;
    var env = EnvGen.kr(Env.perc(0.001, decay, 1, -5), t_trig);
    Pan2.ar(metal * env * amp, pan);
}).play;

Pbindef(\ironChainSeq,
    \dur, Pseq([3, 1.5, 0.75, 0.5, 0.25, 0.25, 4], inf),
    \freq, Pseq([740, 622, 830, 554, 932, 494, 740], inf),
    \t_trig, 1,
    \decay, Pseq([1.8, 1.4, 1.1, 0.8, 0.55, 0.35, 2.4], inf),
    \amp, Pseq([0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.045], inf),
    \pan, Pseq([-0.65, 0.55, -0.35, 0.7, -0.6, 0.4, 0], inf)
);
Ndef(\ironChain)[1] = \set -> Pbindef(\ironChainSeq);
Pbindef(\ironChainSeq).play;
// Pbindef(\ironChainSeq).stop; Ndef(\ironChain).fadeTime = 2; Ndef(\ironChain).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
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

    SynthDef(\clockTick, { |out=0, freq=1800, amp=0.08, pan=0, decay=0.045|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -8), doneAction: 2);
        var click = WhiteNoise.ar(0.7) + SinOsc.ar(freq * 0.73, 0, 0.3);
        var sig = BPF.ar(click, freq, 0.32) * env * amp * 5;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\clockChime, { |out=0, freq=880, amp=0.045, pan=0, decay=2|
        var env = EnvGen.ar(Env.perc(0.002, decay, 1, -4), doneAction: 2);
        var strike = Decay2.ar(Impulse.ar(0), 0.002, 0.035) * WhiteNoise.ar(0.4);
        var modes = Ringz.ar(strike, [freq, freq * 1.503, freq * 2.71], decay, [0.6, 0.24, 0.12]).sum;
        var tone = SinOsc.ar(freq * 0.5) * 0.12;
        Out.ar(out, Pan2.ar((modes + tone) * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\clockBreath, { |amp=0, rate=0.08, cutoff=1400|
        var swell = SinOsc.kr(rate).range(0.15, 1);
        var air = BPF.ar(PinkNoise.ar(0.18), cutoff, 0.35);
        var low = SinOsc.ar(54 * SinOsc.kr(0.023).range(0.99, 1.01), 0, 0.18);
        Pan2.ar((air + low) * swell * amp, SinOsc.kr(0.11).range(-0.35, 0.35));
    }).play;
    Ndef(\clockBreath).fadeTime = 4;
    Ndef(\clockBreath).xset(\amp, 0);

    Ndef(\masterMix, {
        var ticks = In.ar(~synthBus, 2);
        var breath = Ndef(\clockBreath).ar(2);
        ticks + breath;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.24);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        LeakDC.ar(in);
    };
    Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\clockTicks,
        \instrument, \clockTick,
        \out, ~synthBus,
        \dur, Pseq([0.49, 0.51, 0.48, 0.52, 0.5, 0.5, 0.47, 0.53], inf),
        \freq, Pseq([1720, 1880, 1640, 2030, 1790, 1560, 1940, 1680], inf),
        \amp, Pseq([0.045, 0.035, 0.052, 0.032, 0.048, 0.04, 0.055, 0.034], inf),
        \decay, Pseq([0.035, 0.055, 0.04, 0.07], inf),
        \pan, Pwhite(-0.82, 0.82, inf)
    );
    Pbindef(\clockChimes,
        \instrument, \clockChime,
        \out, ~synthBus,
        \dur, Pseq([4.5, 6, 3.5, 7], inf),
        \freq, Pseq([880, 1174, 784, 1047, 932, 698], inf),
        \amp, Pseq([0.032, 0.026, 0.038, 0.024], inf),
        \decay, Pseq([2.1, 1.5, 2.7, 1.8], inf),
        \pan, Pseq([-0.5, 0.45, 0.15, -0.3], inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - A oficina desperta: latão em desencontro microscópico.".postln;
        Ndef(\clockBreath).fadeTime = 5;
        Ndef(\clockBreath).xset(\amp, 0.24, \cutoff, 900, \rate, 0.07);
        Pbindef(\clockTicks).play;
        4.wait;

        "0:05 - Duzentos balanços imaginários; cada tique recusa o uníssono.".postln;
        5.do { |i|
            Ndef(\clockBreath).xset(\cutoff, [680, 1250, 920, 1740, 760][i], \rate, [0.06, 0.11, 0.08, 0.14, 0.07][i]);
            Ndef(\masterMix).set(\wet10, [0.18, 0.32, 0.22, 0.38, 0.2][i]);
            3.wait;
        };

        "0:20 - Carrilhões franceses abrem pequenas fendas no mecanismo.".postln;
        Pbindef(\clockChimes).play;
        4.do { |i|
            Pbindef(\clockTicks, \dur, Pseq([[0.38, 0.62, 0.31, 0.69], [0.25, 0.75, 0.5, 0.5], [0.42, 0.58, 0.34, 0.66], [0.2, 0.8, 0.4, 0.6]][i], inf));
            Ndef(\clockBreath).xset(\cutoff, [1800, 2300, 1350, 2800][i]);
            3.wait;
        };

        "0:32 - O mecanismo toca seu limite: acelera, range, quase perde o pulso.".postln;
        Pbindef(\clockTicks, \dur, Pseq([0.18, 0.22, 0.16, 0.24, 0.2, 0.17], inf), \amp, Pseq([0.035, 0.05, 0.03, 0.055], inf));
        Ndef(\clockBreath).xset(\rate, 0.23, \cutoff, 3200, \amp, 0.16);
        Ndef(\masterMix).set(\wet10, 0.42);
        6.wait;

        "0:38 - Repentino recolhimento: resta o respirar entre duas engrenagens.".postln;
        Pbindef(\clockTicks).stop;
        Ndef(\clockBreath).fadeTime = 2;
        Ndef(\clockBreath).xset(\amp, 0.12, \cutoff, 520, \rate, 0.035);
        4.wait;

        "0:42 - Flashback: o tique inicial retorna, agora espaçado e mais frágil.".postln;
        Pbindef(\clockTicks,
            \dur, Pseq([0.49, 0.51, 0.48, 0.52, 0.5, 0.5, 0.47, 0.53], inf),
            \amp, Pseq([0.025, 0.018, 0.03, 0.02], inf)
        ).play;
        Pbindef(\clockChimes, \amp, Pseq([0.018, 0.014, 0.022, 0.015], inf));
        5.do { |i|
            Ndef(\clockBreath).xset(\cutoff, [700, 1100, 830, 620, 480][i]);
            2.wait;
        };

        "0:52 - O relojoeiro abre os olhos; o tempo fecha em seu centro.".postln;
        Pbindef(\clockTicks).stop;
        Pbindef(\clockChimes).stop;
        Ndef(\clockBreath).fadeTime = 5;
        Ndef(\clockBreath).xset(\amp, 0);
        5.wait;

        Pbindef(\clockTicks).clear;
        Pbindef(\clockChimes).clear;
        Ndef(\clockBreath).clear(2);
        Ndef(\masterMix).clear(2);
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
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\grutaGota, { |out=0, freq=680, amp=0.04, decay=1.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        var strike = Decay2.ar(Impulse.ar(0), 0.002, 0.035) * WhiteNoise.ar(0.5);
        var modes = Ringz.ar(strike, [freq, freq * 1.47, freq * 2.13], [decay, decay * 0.72, decay * 0.43], [1, 0.45, 0.22]).sum;
        Out.ar(out, Pan2.ar(modes * env * amp, pan));
    }).add;

    SynthDef(\grutaCortina, { |out=0, freq=210, amp=0.035, decay=3, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay, 1, -3), doneAction: 2);
        var exc = BPF.ar(WhiteNoise.ar(0.7), freq * 2.2, 0.22);
        var modes = Ringz.ar(exc, [freq, freq * 1.31, freq * 1.82, freq * 2.6], [decay, decay * 0.8, decay * 0.65, decay * 0.4], [0.9, 0.6, 0.35, 0.2]).sum;
        Out.ar(out, Pan2.ar(modes * env * amp * 4, pan));
    }).add;

    SynthDef(\grutaEstalo, { |out=0, freq=95, amp=0.045, decay=0.42, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -7), doneAction: 2);
        var body = (SinOsc.ar(freq, 0, 0.7) + SinOsc.ar(freq * 2.03, 0, 0.22)) * env;
        var grit = BPF.ar(WhiteNoise.ar, freq * 5, 0.5) * env * 0.18;
        Out.ar(out, Pan2.ar((body + grit) * amp, pan));
    }).add;
    s.sync;

    Ndef(\grutaArUmido, {
        var breath = BrownNoise.ar(0.16) + PinkNoise.ar(0.06);
        var drift = LFNoise1.kr(0.08).range(380, 1450);
        var filtered = LPF.ar(HPF.ar(breath, 90), drift);
        var low = SinOsc.ar(38 + SinOsc.kr(0.035).range(0, 3), 0, 0.12);
        Pan2.ar((filtered + low + SinOsc.ar(76, 0, 0.035)) * \amp.kr(0), SinOsc.kr(0.045).range(-0.3, 0.3));
    }).play;
    Ndef(\grutaArUmido).fadeTime = 6;
    Ndef(\grutaArUmido).xset(\amp, 0);

    Ndef(\grutaAguaDistante, {
        var drops = Dust.ar(\density.kr(0.8));
        var resonant = Ringz.ar(drops, [310, 467, 702], [1.8, 2.6, 1.2], [0.45, 0.3, 0.2]).sum;
        var smear = AllpassC.ar(resonant, 0.22, [0.13, 0.19], 2.4).sum;
        Pan2.ar((resonant + smear) * \amp.kr(0), SinOsc.kr(0.07).range(-0.65, 0.65));
    }).play;
    Ndef(\grutaAguaDistante).fadeTime = 4;
    Ndef(\grutaAguaDistante).xset(\amp, 0);

    Ndef(\masterMix, {
        var dry = In.ar(~synthBus, 2);
        var air = Ndef(\grutaArUmido).ar(2);
        var water = Ndef(\grutaAguaDistante).ar(2);
        dry + air + water;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.22);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        LeakDC.ar(in);
    };
    Ndef(\masterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\grutaGotejo,
        \instrument, \grutaGota, \out, ~synthBus,
        \dur, Pseq([1.1, 1.7, 0.8, 2.2, 1.4, 2.8], inf),
        \freq, Pseq([680, 523, 784, 587, 440, 698, 392], inf),
        \decay, Pseq([1.3, 2.1, 1.1, 2.8], inf),
        \amp, Pseq([0.04, 0.03, 0.046, 0.032], inf),
        \pan, Pwhite(-0.8, 0.8, inf)
    );
    Pbindef(\grutaMineral,
        \instrument, \grutaCortina, \out, ~synthBus,
        \dur, Pseq([4.5, 6.5, 3.8, 7], inf),
        \freq, Pseq([146, 174, 130, 196, 164, 220], inf),
        \decay, Pseq([3.2, 4.1, 2.7, 3.6], inf),
        \amp, Pseq([0.034, 0.027, 0.038, 0.03], inf),
        \pan, Pseq([-0.55, 0.42, 0.18, -0.28], inf)
    );
    Pbindef(\grutaFratura,
        \instrument, \grutaEstalo, \out, ~synthBus,
        \dur, Pseq([0.42, 0.58, 0.34, 0.66, 0.5], inf),
        \freq, Pseq([82, 97, 73, 110, 91, 65], inf),
        \decay, Pseq([0.26, 0.38, 0.22], inf),
        \amp, Pseq([0.042, 0.03, 0.05, 0.027], inf),
        \pan, Pwhite(-0.75, 0.75, inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - A água respira sob a pedra; o primeiro salão se abre.".postln;
        Ndef(\grutaArUmido).fadeTime = 5;
        Ndef(\grutaArUmido).xset(\amp, 0.24);
        Ndef(\grutaAguaDistante).xset(\amp, 0.12, \density, 0.45);
        Pbindef(\grutaGotejo).play;
        5.wait;

        "0:06 - Gotejos isolados desenham as abóbadas calcárias.".postln;
        5.do { |i|
            Ndef(\grutaAguaDistante).xset(\density, [0.35, 0.8, 0.5, 1.1, 0.6][i]);
            Ndef(\masterMix).set(\wet10, [0.18, 0.28, 0.22, 0.34, 0.24][i]);
            3.wait;
        };

        "0:21 - Cortinas minerais: ressonâncias atravessam os salões.".postln;
        Pbindef(\grutaMineral).play;
        4.do { |i|
            Ndef(\grutaArUmido).xset(\amp, [0.22, 0.16, 0.26, 0.19][i]);
            Ndef(\grutaAguaDistante).xset(\density, [0.75, 1.3, 0.55, 1.05][i]);
            3.wait;
        };

        "0:33 - A rocha cede em estalos breves; a água chega ao limite.".postln;
        Pbindef(\grutaFratura).play;
        Ndef(\grutaAguaDistante).xset(\density, 2.8, \amp, 0.16);
        Ndef(\masterMix).set(\wet10, 0.42);
        5.wait;
        Pbindef(\grutaFratura).stop;
        Ndef(\grutaAguaDistante).xset(\density, 0.7, \amp, 0.09);

        "0:38 - Recolhimento súbito: resta o eco úmido de um salão vazio.".postln;
        Pbindef(\grutaGotejo).stop;
        Ndef(\grutaArUmido).fadeTime = 2;
        Ndef(\grutaArUmido).xset(\amp, 0.1);
        Ndef(\masterMix).set(\wet10, 0.5);
        5.wait;

        "0:43 - Flashback: uma gota retorna ao centro tonal, mais frágil.".postln;
        Pbindef(\grutaGotejo,
            \dur, Pseq([1.1, 1.7, 0.8, 2.2, 1.4, 2.8], inf),
            \freq, Pseq([680, 523, 784, 587, 440, 698, 392], inf),
            \amp, Pseq([0.021, 0.016, 0.025, 0.018], inf)
        ).play;
        Pbindef(\grutaMineral, \amp, Pseq([0.018, 0.014, 0.022, 0.016], inf));
        5.do { |i|
            Ndef(\grutaArUmido).xset(\amp, [0.12, 0.09, 0.11, 0.07, 0.04][i]);
            2.wait;
        };

        "0:53 - Os sete salões se apagam; permanece a última ressonância.".postln;
        Pbindef(\grutaGotejo).stop;
        Pbindef(\grutaMineral).stop;
        Ndef(\grutaArUmido).fadeTime = 5;
        Ndef(\grutaArUmido).xset(\amp, 0);
        Ndef(\grutaAguaDistante).fadeTime = 5;
        Ndef(\grutaAguaDistante).xset(\amp, 0);
        5.wait;

        Pbindef(\grutaGotejo).clear;
        Pbindef(\grutaMineral).clear;
        Pbindef(\grutaFratura).stop;
        Pbindef(\grutaFratura).clear;
        Ndef(\grutaArUmido).clear(2);
        Ndef(\grutaAguaDistante).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: PASS
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxPatch: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxOrbit: 52,
    delMix: 60, verbMix: 61, panic: 123
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label;
    label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not and: { label.contains("bome").not } and: { label.contains("midiin2").not }
        and: { label.contains("midiin 2").not } and: { label.contains("microsoft gs").not }
        and: { label.contains("wavetable").not } and: { label.contains("midi through").not }
        and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    var keys, defaults;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 68, hpf1: 25, lpf1: 180, rq1: 0.7, atk1: 0.01, dec1: 0.35, sus1: 0.65, rls1: 0.8, fxPatch: 0.0,
        vol2: 0.18, pan2: 0.25, mute2: 0.0, min2: 42, max2: 127, hpf2: 350, lpf2: 6500, rq2: 0.5, atk2: 0.008, dec2: 0.7, sus2: 0.0, rls2: 1.2, fxOrbit: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });
    ~zoneMeta = [
        (title: "01 — Prata / Núcleo", fxKey: \fxPatch, fxLabel: "Patch Fold"),
        (title: "02 — Fósforo / Órbita", fxKey: \fxOrbit, fxLabel: "Lissajous Drift")
    ];

    SynthDef(\modularCore, { |out=0, freq=110, gate=1, amp=0.2, pan=0, hpf=25, lpf=180, rq=0.7, atk=0.01, dec=0.35, sus=0.65, rls=0.8, fx=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 2.71, 0, freq * (1 + (fx * 8)));
        sig = (SinOsc.ar(freq + mod) * 0.7) + (SinOscFB.ar(freq * 0.5, fx * 0.85) * 0.3);
        sig = Fold.ar(sig * (1 + (fx * 4)), -0.85, 0.85);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000), rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\modularOrbit, { |out=0, freq=440, gate=1, amp=0.18, pan=0.25, hpf=350, lpf=6500, rq=0.5, atk=0.008, dec=0.7, sus=0, rls=1.2, fx=0|
        var env, phase, sig, exc, ring;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        phase = SinOsc.kr(0.07 + (fx * 0.4)).range(0.2, 0.8);
        sig = (Saw.ar(freq * [0.997, 1.003]) * 0.35).sum;
        sig = sig + (SinOsc.ar(freq * 2.71, SinOsc.kr(0.13).range(0, 2pi)) * 0.3);
        exc = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.04), gate);
        ring = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.4);
        sig = sig + (ring * (0.15 + (fx * 0.5)));
        sig = (sig * (1 + (fx * 2))).tanh;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000) * phase.linlin(0.2, 0.8, 0.8, 1.2), rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\modDelay, { |in=0, out=0, mix=0|
        var sig, dry, wet;
        sig = In.ar(in, 2);
        dry = sig;
        wet = CombC.ar(sig, 1.2, 0.37, 2.8);
        Out.ar(out, XFade2.ar(dry, wet, mix.clip(0, 1).linlin(0, 1, -1, 1)));
    }).add;
    SynthDef(\modVerb, { |in=0, out=0, mix=0|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 0.65, 0.82, 0.45);
        Out.ar(out, XFade2.ar(sig, wet, mix.clip(0, 1).linlin(0, 1, -1, 1)));
    }).add;
    SynthDef(\modMaster, { |in=0|
        var sig;
        sig = LeakDC.ar(In.ar(in, 2));
        ReplaceOut.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    Synth.tail(~fxGroup, \modDelay, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.delMix.asMap]);
    Synth.tail(~fxGroup, \modVerb, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.verbMix.asMap]);
    Synth.tail(~masterGroup, \modMaster, [\in, ~audioBus]);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("vol") } { norm * 0.4 }
                    { ks.contains("Mix") } { norm }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
                if(key == \panic and: { val > 0 }) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\modNoteOn, { |vel, noteNum|
        var freq, amp;
        freq = noteNum.midicps;
        amp = vel / 127;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[noteNum].add(Synth(\modularCore, [\out, ~audioBus, \freq, freq, \amp, ~ccVals[\vol1] * amp, \pan, ~ccVals[\pan1], \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap, \fx, ~buses.fxPatch.asMap, \gate, 1], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[noteNum].add(Synth(\modularOrbit, [\out, ~audioBus, \freq, freq, \amp, ~ccVals[\vol2] * amp, \pan, ~ccVals[\pan2], \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap, \fx, ~buses.fxOrbit.asMap, \gate, 1], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\modNoteOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |syn| syn.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);
    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, winH, winW, pages, pageButtons, bottom, pageLabel;
        ~mainWin = Window("PHOSPHOR PATCH — Modular Lissajous", Window.availableBounds, resizable: false);
        bounds = Window.availableBounds;
        winW = 660;
        winH = min(740, bounds.height - 60);
        ~mainWin.bounds = Rect(bounds.center.x - (winW/2), bounds.center.y - (winH/2), winW, winH);
        ~mainWin.view.background = Color.fromHexString("#171b1d");
        pages = Array.newClear(~zoneMeta.size);
        ~ui = ();
        pageButtons = CompositeView(~mainWin, Rect(12, 12, 636, 40));
        pageLabel = StaticText(pageButtons, Rect(0, 0, 636, 30));
        pageLabel.stringColor = Color.green;
        ~zoneMeta.do { |zm, idx|
            var page, title, controls, names, x, y, w;
            page = CompositeView(~mainWin, Rect(12, 58, 636, winH - 140));
            page.background = Color.fromHexString("#22282a");
            pages[idx] = page;
            title = StaticText(page, Rect(16, 10, 600, 28));
            title.string = zm[\title] ++ "   •   " ++ zm[\fxLabel];
            title.stringColor = Color.fromHexString("#9aff8b");
            names = if(idx == 0, { [\vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxPatch] }, { [\vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxOrbit] });
            controls = names;
            controls.do { |key, j|
                var col, row, label, slider;
                col = j % 3;
                row = (j / 3).floor;
                x = 12 + (col * 205);
                y = 52 + (row * 78);
                label = key.asString ++ "  CC " ++ ~cc[key].asString;
                slider = EZSlider(page, Rect(x, y, 195, 62), label, ControlSpec(
                    if(key.asString.contains("pan"), -1, 0),
                    if(key.asString.contains("pan"), 1, if(key.asString.matchRegexp("hpf|lpf"), 18000, if(key.asString.matchRegexp("min|max"), 127, 5))),
                    \lin, 0, ~ccVals[key]
                ), { |ez| ~ccVals[key] = ez.value; if(~buses[key].notNil) { ~buses[key].set(ez.value) } }, ~ccVals[key]);
                slider.labelView.stringColor = Color.white;
                ~ui[key] = slider;
            };
        };
        ~zoneMeta.do { |zm, idx|
            var button;
            button = Button(pageButtons, Rect(idx * 150, 0, 145, 32));
            button.states = [[zm[\title], Color.white, Color.fromHexString("#344448")]];
            button.action = { pages.do { |p, j| p.visible = (j == idx) }; pageLabel.string = zm[\fxLabel] };
            if(idx == 0) { button.value = 1; pages[idx].visible = true } { pages[idx].visible = false };
        };
        bottom = CompositeView(~mainWin, Rect(12, winH - 72, 636, 55));
        EZSlider(bottom, Rect(0, 0, 195, 48), "Delay mix CC 60", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\delMix] = ez.value; ~buses.delMix.set(ez.value) }, 0);
        EZSlider(bottom, Rect(205, 0, 195, 48), "Reverb mix CC 61", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\verbMix] = ez.value; ~buses.verbMix.set(ez.value) }, 0);
        Button(bottom, Rect(430, 4, 190, 38)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({ ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } });
        ~mainWin.front;
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
)


// ============================================================
// ROUND 06 | MODE: DESIGN | FRAG #86
// STATUS: PASS
// PROMPT: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente e...
// ============================================================
(
// [Pre-Design Cleanup: freeing previous Design synthesizer resources]
{
    if(~guiRoutine.notNil) { try { ~guiRoutine.stop } {}; ~guiRoutine = nil };
    [~mainWin, ~surWin, ~win, ~guiWin, ~synthWin].do { |w|
        if(w.notNil) { try { w.close } {} };
    };
    ~mainWin = nil; ~surWin = nil; ~win = nil; ~guiWin = nil; ~synthWin = nil;
    try { Window.closeAll } {};
    try { MIDIdef.freeAll } {};
    if(~notes.notNil) {
        try {
            ~notes.do { |item|
                if(item.notNil) {
                    if(item.isKindOf(Collection)) {
                        item.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                    } {
                        try { item.free } {};
                    };
                };
            };
        } {};
        ~notes = nil;
    };
    if(~zoneNotes.notNil) {
        try {
            ~zoneNotes.do { |zone|
                if(zone.notNil) {
                    zone.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                };
            };
        } {};
        ~zoneNotes = nil;
    };
    ~activeCount = 0;
    [
        ~subSynth, ~monoSynth, ~leadSynth, ~droneSynth, ~synth,
        ~fxSynth, ~masterFx, ~celestialFx, ~ancientFx, ~reverbSynth, ~delaySynth,
        ~synthGroup, ~fxGroup, ~masterGroup, ~sourceGroup
    ].do { |node|
        if(node.notNil) { try { node.free } {} };
    };
    ~subSynth = nil; ~monoSynth = nil; ~leadSynth = nil; ~droneSynth = nil; ~synth = nil;
    ~fxSynth = nil; ~masterFx = nil; ~celestialFx = nil; ~ancientFx = nil; ~reverbSynth = nil; ~delaySynth = nil;
    ~synthGroup = nil; ~fxGroup = nil; ~masterGroup = nil; ~sourceGroup = nil;
    if(~buses.notNil) {
        try { ~buses.do { |b| if(b.notNil) { try { b.free } {} } } } {};
        ~buses = nil;
    };
    [~fxBus, ~celestialBus, ~ancientBus, ~reverbBus, ~delayBus].do { |b|
        if(b.notNil) { try { b.free } {} };
    };
    ~fxBus = nil; ~celestialBus = nil; ~ancientBus = nil; ~reverbBus = nil; ~delayBus = nil;
    try {
        if(Pbindef.all.notNil and: { Pbindef.all[\subtractiveDesignSeq].notNil }) {
            Pbindef(\subtractiveDesignSeq).stop;
            Pbindef(\subtractiveDesignSeq).clear;
        };
    } {};
    try {
        if(Ndef.dictFor(s).notNil and: { Ndef.dictFor(s)[\subtractiveDesign].notNil }) {
            Ndef(\subtractiveDesign).clear(0.1);
        };
    } {};
}.value;
{
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxGourd: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxCaxixi: 52,
    delMix: 60, verbMix: 61, panic: 123
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label;
    label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not and: { label.contains("bome").not }
            and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not } and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not } and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    var keys, vals;
    keys = [
        \vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxGourd,
        \vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxCaxixi,
        \delMix,\verbMix
    ];
    vals = [
        0.22,0,0,0,72,25,1800,0.5,0.005,0.35,0.5,0.25,0,
        0.17,0.25,0,38,110,350,6500,0.55,0.001,0.15,0,0.18,0,
        0,0
    ];
    ~ccVals = ();
    keys.do { |k, i| ~ccVals[k] = vals[i] };
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });

    SynthDef(\berimbauBody, {
        |out=0, freq=220, amp=0.22, pan=0, gate=1, mute=0, hpf=25, lpf=1800,
        rq=0.5, atk=0.005, dec=0.35, sus=0.5, rls=0.25, fx=0|
        var env, bow, wire, body, tone, sig, thump;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        bow = WhiteNoise.ar(0.18) * EnvGen.kr(Env.perc(0.001, 0.035));
        wire = SinOsc.ar(freq, 0, 0.25) + SinOsc.ar(freq * (1.002 + (fx * 0.012)), 0, 0.16)
            + SinOsc.ar(freq * 2, 0, 0.08);
        body = CombL.ar(bow, 0.08, (freq.reciprocal * 0.5).clip(0.001, 0.08), 0.4 + (fx * 2));
        thump = SinOsc.ar(freq * 0.5, 0, EnvGen.kr(Env.perc(0.001, 0.12)) * 0.18);
        tone = (wire + body + thump) * (1 + (fx * 2));
        sig = RLPF.ar(HPF.ar(tone, hpf), lpf, rq.clip(0.05, 1));
        sig = Pan2.ar(sig * env * amp * (1 - mute), pan);
        Out.ar(out, sig);
    }).add;

    SynthDef(\berimbauRattle, {
        |out=0, freq=220, amp=0.17, pan=0.25, gate=1, mute=0, hpf=350, lpf=6500,
        rq=0.55, atk=0.001, dec=0.15, sus=0, rls=0.12, fx=0|
        var env, hit, cax, metal, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        hit = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.018));
        cax = CombL.ar(hit, 0.04, (freq.reciprocal * 0.23).clip(0.001, 0.04), 0.08 + (fx * 0.65));
        metal = SinOsc.ar(freq * 2.71, 0, 0.07) + SinOsc.ar(freq * 3.51, 0, 0.045);
        sig = RLPF.ar(HPF.ar(cax + (metal * EnvGen.kr(Env.perc(0.001, 0.06))), hpf), lpf, rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env * amp * (1 - mute), pan));
    }).add;

    SynthDef(\berimbauMaster, {
        |inBus=0, out=0, delMix=0, verbMix=0|
        var dry, delayed, reverbed, sig;
        dry = In.ar(inBus, 2);
        delayed = CombC.ar(dry, 1.2, 0.31, 2.4);
        reverbed = FreeVerb2.ar(dry[0], dry[1], 0.7, 0.72, 0.25);
        sig = dry + (delayed * delMix) + ((reverbed - dry) * verbMix);
        sig = Limiter.ar(LeakDC.ar(sig), 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;
    Synth.tail(~masterGroup, \berimbauMaster, [
        \inBus, ~audioBus.index, \delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap
    ]);

    ~zoneMeta = [
        (title: "CABAÇA / ARAME", fxKey: \fxGourd, fxLabel: "Gourd resonance"),
        (title: "CAXIXI / DOBRÃO", fxKey: \fxCaxixi, fxLabel: "Rattle & metal")
    ];

    MIDIdef.noteOn(\berimbauOn, { |vel, noteNum|
        var freq, syn;
        freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            syn = Synth(\berimbauBody, [
                \out, ~audioBus.index, \freq, freq, \amp, vel / 127,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap,
                \rls, ~buses.rls1.asMap, \fx, ~buses.fxGourd.asMap
            ], ~synthGroup);
            ~zoneNotes[noteNum].add(syn);
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            syn = Synth(\berimbauRattle, [
                \out, ~audioBus.index, \freq, freq, \amp, (vel / 127) * 0.7,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap,
                \rls, ~buses.rls2.asMap, \fx, ~buses.fxCaxixi.asMap
            ], ~synthGroup);
            ~zoneNotes[noteNum].add(syn);
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\berimbauOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |syn| syn.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            var ks, v;
            if(num == ccNum) {
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linlin(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { norm };
                if(key != \panic) {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, winW, winH, pages, pageButtons, bottom, pageLabel, screen;
        bounds = Window.availableBounds;
        screen = bounds.height;
        winW = 660;
        winH = min(780, screen - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("BERIMBAU — CABAÇA / ARAME", bounds, resizable: false, scroll: true);
        ~mainWin.bounds = Rect(bounds.center.x - (winW / 2), bounds.center.y - (winH / 2), winW, winH);
        ~mainWin.view.background = Color.fromHexString("#171b1d");
        pages = Array.newClear(~zoneMeta.size);
        ~ui = ();
        pageButtons = CompositeView(~mainWin, Rect(12, 10, 636, 38));
        pageLabel = StaticText(pageButtons, Rect(310, 4, 310, 28));
        pageLabel.stringColor = Color.green;
        ~zoneMeta.do { |zm, idx|
            var page, title, names;
            page = CompositeView(~mainWin, Rect(12, 55, 636, winH - 132));
            page.background = Color.fromHexString("#22282a");
            pages[idx] = page;
            title = StaticText(page, Rect(16, 8, 600, 28));
            title.string = zm[\title] ++ " — " ++ zm[\fxLabel];
            title.stringColor = Color.fromHexString("#9aff8b");
            names = if(idx == 0,
                { [\vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxGourd] },
                { [\vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxCaxixi] });
            names.do { |key, j|
                var col, row, isPan, isFreq, high, label, slider;
                col = j % 3;
                row = (j / 3).floor;
                isPan = key.asString.contains("pan");
                isFreq = key.asString.matchRegexp("hpf|lpf");
                high = if(isPan, 1, if(isFreq, 18000, if(key.asString.matchRegexp("min|max"), 127, 5)));
                label = key.asString ++ "  CC " ++ ~cc[key].asString;
                slider = EZSlider(page, Rect(12 + (col * 205), 45 + (row * 76), 195, 62), label,
                    ControlSpec(if(isPan, -1, 0), high, \lin, 0, ~ccVals[key]),
                    { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) }, ~ccVals[key]);
                slider.labelView.stringColor = Color.white;
                ~ui[key] = slider;
            };
        };
        ~zoneMeta.do { |zm, idx|
            var button;
            button = Button(pageButtons, Rect(idx * 150, 2, 145, 30));
            button.states = [[zm[\title], Color.white, Color.fromHexString("#344448")]];
            button.action = { pages.do { |pg, j| pg.visible = (j == idx) }; pageLabel.string = zm[\fxLabel] };
            if(idx == 0) { button.value = 1; pages[idx].visible = true } { pages[idx].visible = false };
        };
        bottom = CompositeView(~mainWin, Rect(12, winH - 68, 636, 54));
        EZSlider(bottom, Rect(0, 0, 195, 48), "Delay mix CC 60", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\delMix] = ez.value; ~buses.delMix.set(ez.value) }, 0);
        EZSlider(bottom, Rect(205, 0, 195, 48), "Reverb mix CC 61", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\verbMix] = ez.value; ~buses.verbMix.set(ez.value) }, 0);
        Button(bottom, Rect(430, 4, 190, 38)).states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({ ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } });
        ~mainWin.front;
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
}.value;
)


// ============================================================
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: chão cadenciado, gungas metálicas e canto de coroação
 Ndef(\congoChao, {
     |t_trig=0, freq=55, amp=0.16, pan=0|
     var env, slow, sig;
     env = EnvGen.kr(Env.perc(0.08, 1.8, 1, -4), t_trig);
     slow = SinOsc.kr(0.09).range(0.94, 1.06);
     sig = (Pulse.ar(freq * slow, 0.46) * 0.22) + SinOsc.ar(freq * 2 * slow, 0, 0.18);
     sig = LPF.ar(sig, 260);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(3).play;

 Ndef(\congoGungas, {
     |t_trig=0, freq=620, amp=0.13, pan=0, tone=3200|
     var env, hit, metal;
     env = EnvGen.kr(Env.perc(0.002, 0.24, 1, -7), t_trig);
     hit = Decay2.ar(K2A.ar(t_trig), 0.001, 0.035) * WhiteNoise.ar(0.35);
     metal = SinOsc.ar(freq, 0, 0.55)
         + SinOsc.ar(freq * 2.71, 0, 0.30)
         + SinOsc.ar(freq * 3.51, 0, 0.18);
     metal = metal + BPF.ar(hit, freq * 2.4, 0.22) * 4;
     metal = LPF.ar(metal, tone);
     Pan2.ar(metal * env, pan, amp);
 }).fadeTime_(0.15).play;

 Ndef(\congoCoroa, {
     |t_trig=0, freq=392, amp=0.11, pan=0|
     var env, index, mod, sig;
     env = EnvGen.kr(Env.perc(0.01, 1.1, 1, -5), t_trig);
     index = Decay2.kr(t_trig, 0.01, 0.32).range(0.2, 2.8);
     mod = SinOsc.ar(freq * 2.71) * (freq * index);
     sig = SinOsc.ar((freq * 1.003) + mod)
         + (SinOsc.ar(freq * 3.51 + mod * 0.37) * 0.28);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(1.5).play;

 // Ambiência comum: reverberação integral, misturada pelo slot do proxy
 Ndef(\congoChao)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.42)
 };
 Ndef(\congoChao).set(\wet10, 0.22);

 Ndef(\congoGungas)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.48, 0.28)
 };
 Ndef(\congoGungas).set(\wet10, 0.18);

 Ndef(\congoCoroa)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.52)
 };
 Ndef(\congoCoroa).set(\wet10, 0.30);

 // Passos cadenciados: pulsação grave com variações de andamento e acento
 Pbindef(\congoChaoSeq,
     \dur, Pwrand([0.5, 0.75, 1], [0.58, 0.3, 0.12], inf),
     \freq, Pseq([55, 55, 65.41, 55, 73.42, 65.41, 55, 49], inf),
     \amp, Pwhite(0.11, 0.17, inf),
     \pan, Pwhite(-0.18, 0.18, inf),
     \t_trig, 1
 );
 Ndef(\congoChao).quant = 1;
 Ndef(\congoChao)[1] = \set -> Pbindef(\congoChaoSeq);

 // Gungas: balanço metálico irregular sobre os ternos em marcha
 Pbindef(\congoGungasSeq,
     \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.38, 0.14], inf),
     \freq, Pseq([620, 740, 620, 880, 740, 620, 990, 740], inf),
     \amp, Pwhite(0.07, 0.13, inf),
     \pan, Pwhite(-0.72, 0.72, inf),
     \tone, Pwhite(2400, 4200, inf),
     \t_trig, 1
 );
 Ndef(\congoGungas).quant = 1;
 Ndef(\congoGungas)[1] = \set -> Pbindef(\congoGungasSeq);

 // Coroação: frase modal em respostas espaçadas, com brilho de sino
 Pbindef(\congoCoroaSeq,
     \dur, Pwrand([0.75, 1, 1.5, 2], [0.28, 0.38, 0.24, 0.1], inf),
     \freq, Pseq([392, 440, 493.88, 587.33, 523.25, 440, 392, 329.63], inf),
     \amp, Pwhite(0.065, 0.11, inf),
     \pan, Pwhite(-0.5, 0.5, inf),
     \t_trig, 1
 );
 Ndef(\congoCoroa).quant = 1;
 Ndef(\congoCoroa)[1] = \set -> Pbindef(\congoCoroaSeq);

 // Ndef(\congoGungas).xset(\tone, 2100); // Escurecer metais | Revert: Ndef(\congoGungas).xset(\tone, 3200);
 // Pbindef(\congoGungasSeq, \dur, 0.25); // Acelerar gungas | Revert: Pbindef(\congoGungasSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.38, 0.14], inf));
 // Pbindef(\congoChaoSeq).stop; Ndef(\congoChao).fadeTime = 4; Ndef(\congoChao).clear(4); // Rollback chão
 // Pbindef(\congoGungasSeq).stop; Ndef(\congoGungas).fadeTime = 4; Ndef(\congoGungas).clear(4); // Rollback gungas
 // Pbindef(\congoCoroaSeq).stop; Ndef(\congoCoroa).fadeTime = 4; Ndef(\congoCoroa).clear(4); // Rollback coroação
)


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: PASS
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// Pantanal ao crepúsculo: corixo, piúva silenciosa e voo das araras-azuis
 Ndef(\pantanalCorixo, {
     |t_trig=0, freq=55, amp=0.15, pan=0, cutoff=260|
     var env, tide, low, shimmer, sig;
     env = EnvGen.kr(Env.perc(0.8, 5.5, 1, -4), t_trig);
     tide = SinOsc.kr(0.035).range(0.94, 1.06);
     low = SinOsc.ar(freq * tide, 0, 0.24)
         + SinOsc.ar(freq * 2 * tide, 0, 0.12);
     shimmer = BPF.ar(PinkNoise.ar(0.12), 430 + SinOsc.kr(0.07).range(0, 90), 0.35);
     sig = LPF.ar(low + shimmer, cutoff);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(5).play;

 Ndef(\pantanalTuiuiu, {
     |t_trig=0, freq=740, amp=0.11, pan=0, tone=2500|
     var env, tick, modes, sig;
     env = EnvGen.kr(Env.perc(0.004, 0.72, 1, -6), t_trig);
     tick = Decay2.ar(K2A.ar(t_trig), 0.002, 0.06) * WhiteNoise.ar(0.22);
     modes = SinOsc.ar(freq, 0, 0.55)
         + SinOsc.ar(freq * 2.71, 0, 0.24)
         + SinOsc.ar(freq * 3.51, 0, 0.12);
     sig = modes + (BPF.ar(tick, freq * 2.2, 0.24) * 3);
     sig = LPF.ar(sig, tone);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(0.4).play;

 Ndef(\pantanalAraras, {
     |t_trig=0, freq=880, amp=0.10, pan=0, brightness=3200|
     var env, index, mod, call, rasp, sig;
     env = EnvGen.kr(Env.perc(0.008, 0.42, 1, -5), t_trig);
     index = Decay2.kr(t_trig, 0.006, 0.22).range(0.3, 3.4);
     mod = SinOsc.ar(freq * 1.47) * (freq * index);
     call = SinOsc.ar((freq * 1.006) + mod)
         + (SinOsc.ar(freq * 2.03 + (mod * 0.31), 0, 0.3));
     rasp = BPF.ar(WhiteNoise.ar(0.16), freq * 2.8, 0.3);
     sig = LPF.ar(call + rasp, brightness);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(0.18).play;

 Ndef(\pantanalCorixo)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.86, 0.48)
 };
 Ndef(\pantanalCorixo).set(\wet10, 0.27);

 Ndef(\pantanalTuiuiu)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.7, 0.35)
 };
 Ndef(\pantanalTuiuiu).set(\wet10, 0.24);

 Ndef(\pantanalAraras)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.3)
 };
 Ndef(\pantanalAraras).set(\wet10, 0.18);

 // Corixo: brilho alaranjado e movimento lento sobre o grave refletido
 Pbindef(\pantanalCorixoSeq,
     \dur, Pwrand([2, 3, 4, 6], [0.28, 0.36, 0.24, 0.12], inf),
     \freq, Pseq([55, 55, 65.41, 55, 49, 55, 73.42, 65.41], inf),
     \cutoff, Pwhite(220, 430, inf),
     \amp, Pwhite(0.10, 0.15, inf),
     \pan, Pwhite(-0.16, 0.16, inf),
     \t_trig, 1
 );
 Ndef(\pantanalCorixo).quant = 1;
 Ndef(\pantanalCorixo)[1] = \set -> Pbindef(\pantanalCorixoSeq);

 // Tuiuiús imóveis nos galhos: poucas ressonâncias, espaçadas e graves
 Pbindef(\pantanalTuiuiuSeq,
     \dur, Pwrand([1.5, 2, 3, 4], [0.2, 0.38, 0.3, 0.12], inf),
     \freq, Pseq([740, 659.25, 587.33, 659.25, 523.25, 587.33, 740, 659.25], inf),
     \tone, Pwhite(1900, 2900, inf),
     \amp, Pwhite(0.055, 0.10, inf),
     \pan, Pwhite(-0.7, 0.7, inf),
     \t_trig, 1
 );
 Ndef(\pantanalTuiuiu).quant = 1;
 Ndef(\pantanalTuiuiu)[1] = \set -> Pbindef(\pantanalTuiuiuSeq);

 // Araras-azuis: frases agudas e vivas, em bandos atravessando o céu
 Pbindef(\pantanalArarasSeq,
     \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.28, 0.28, 0.12], inf),
     \freq, Pseq([880, 987.77, 1174.66, 1046.5, 1318.51, 1174.66, 987.77, 783.99], inf),
     \brightness, Pwhite(2400, 3900, inf),
     \amp, Pwhite(0.055, 0.10, inf),
     \pan, Pwhite(-0.9, 0.9, inf),
     \t_trig, 1
 );
 Ndef(\pantanalAraras).quant = 1;
 Ndef(\pantanalAraras)[1] = \set -> Pbindef(\pantanalArarasSeq);

 // Ndef(\pantanalCorixo).xset(\cutoff, 520); // Abrir o reflexo | Revert: Ndef(\pantanalCorixo).xset(\cutoff, 260);
 // Pbindef(\pantanalArarasSeq, \dur, 0.25); // Acelerar o bando | Revert: Pbindef(\pantanalArarasSeq, \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.28, 0.28, 0.12], inf));
 // Pbindef(\pantanalCorixoSeq).stop; Ndef(\pantanalCorixo).fadeTime = 4; Ndef(\pantanalCorixo).clear(4); // Rollback corixo
 // Pbindef(\pantanalTuiuiuSeq).stop; Ndef(\pantanalTuiuiu).fadeTime = 4; Ndef(\pantanalTuiuiu).clear(4); // Rollback tuiuiús
 // Pbindef(\pantanalArarasSeq).stop; Ndef(\pantanalAraras).fadeTime = 4; Ndef(\pantanalAraras).clear(4); // Rollback araras
)

