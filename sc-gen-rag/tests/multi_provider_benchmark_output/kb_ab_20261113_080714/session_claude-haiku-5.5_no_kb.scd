// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-13T11:10:15.677435+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: "antarctica" — pressão silenciosa e tempestade contida
Ndef(\antarctica, {
    var drone, sub, rumble, crack, env, sig;
    drone = LPF.ar(PinkNoise.ar(0.25), LFNoise1.kr(0.05).range(120, 700), 0.6);
    sub = SinOsc.ar(36, 0, 0.18) * LFNoise1.kr(0.2).range(0.5, 1.0);
    rumble = LPF.ar(BrownNoise.ar(0.3), LFNoise1.kr(0.1).range(80, 260));
    env = EnvGen.ar(Env.perc(0.004, 1.6, 1, -6), K2A.ar(\t_trig.kr(0)));
    crack = HPF.ar(WhiteNoise.ar(0.5), 2500) * env;
    sig = (drone + sub + rumble + crack) * \amp.kr(0.0);
    sig = (sig * 1.2).tanh;
    Pan2.ar(sig, LFNoise1.kr(0.03).range(-0.3, 0.3));
}).play;

// Pulso de tensão: silêncio que se acumula até o estalo
Pbindef(\antarcticaSeq,
    \dur, Pseq([6, 6, 4, 2, 1, 0.5, 0.25, 0.25], inf),
    \t_trig, Pseq([0, 0, 0, 1, 0, 1, 1, 1], inf),
    \amp, Pseq([0.0, 0.2, 0.35, 0.5, 0.6, 0.8, 1.0, 0.4], inf)
);

Ndef(\antarctica)[1] = \set -> Pbindef(\antarcticaSeq);
Ndef(\antarctica).fadeTime = 3;
// Pbindef(\antarcticaSeq).play; // Iniciar a sequência
// Pbindef(\antarcticaSeq).stop; Ndef(\antarctica).fadeTime = 2; Ndef(\antarctica).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: "navioNegreiro" - pesadelo dantesco: ferros tinindo, açoites e um raio final
Ndef(\navioNegreiro, { |amp=0.0, cutoff=400, t_whip=0, t_chain=0, t_raio=0|
    var whipEnv, whip, chainEnv, chain, drone, raioEnv, raio, sig;
    drone = LPF.ar(Saw.ar(LFNoise1.kr(0.07).range(38, 46) * [1, 1.007]).sum * 0.12, cutoff.lag(0.3));
    whipEnv = EnvGen.ar(Env.perc(0.001, 0.25, 1, -8), K2A.ar(t_whip));
    whip = HPF.ar(WhiteNoise.ar(0.6), 1800) * whipEnv;
    chainEnv = EnvGen.ar(Env.perc(0.001, 0.8, 1, -4), K2A.ar(t_chain));
    chain = Klank.ar(`[[1180, 1543, 2317, 3390], [0.4, 0.3, 0.2, 0.1], [0.4, 0.3, 0.25, 0.2]], HPF.ar(WhiteNoise.ar(0.03), 3000) * chainEnv);
    raioEnv = EnvGen.ar(Env.perc(0.3, 2.5, 1, -3), K2A.ar(t_raio));
    raio = LPF.ar(BrownNoise.ar(1.5), 900) * raioEnv;
    sig = (drone * 0.6 + whip * 0.7 + chain * 0.5 + raio) * amp;
    sig = (sig * 1.3).tanh;
    Pan2.ar(sig, LFNoise1.kr(0.2).range(-0.6, 0.6));
}).play;

// Sequência: dread lento, açoites e correntes, raio final de libertação
Pbindef(\navioSeq,
    \dur, Pseq([3, 1.5, 0.5, 0.5, 2, 0.75, 0.25, 0.25, 4], inf),
    \t_whip, Pseq([0, 0, 1, 0, 0, 1, 1, 0, 0], inf),
    \t_chain, Pseq([0, 1, 0, 0, 1, 0, 0, 1, 0], inf),
    \t_raio, Pseq([0, 0, 0, 0, 0, 0, 0, 0, 1], inf),
    \amp, Pseq([0.25, 0.35, 0.6, 0.5, 0.45, 0.8, 0.9, 0.7, 0.5], inf),
    \cutoff, Pseq([300, 500, 900, 400, 250, 1400, 2000, 700, 200], inf)
);

Ndef(\navioNegreiro)[1] = \set -> Pbindef(\navioSeq);
Ndef(\navioNegreiro).fadeTime = 3;
// Pbindef(\navioSeq).play; // Iniciar a sequência
// Pbindef(\navioSeq).stop; Ndef(\navioNegreiro).fadeTime = 2; Ndef(\navioNegreiro).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
// Configuração e limitador de segurança
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Tique de pêndulo: clique metálico curto
    SynthDef(\pendTick, { |out=0, freq=3200, amp=0.3, pan=0|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.0005, 0.012, 1, -8), doneAction: 2);
        exc = HPF.ar(WhiteNoise.ar(1), 1500) * env;
        sig = Ringz.ar(exc, freq, 0.025) + (exc * 0.4);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    // Carrilhão: placas inarmônicas com ressonância longa
    SynthDef(\carillon, { |out=0, freq=440, amp=0.2, pan=0|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.002, 4.5, 1, -5), doneAction: 2);
        exc = PinkNoise.ar(0.6) * EnvGen.ar(Env.perc(0.001, 0.03));
        sig = Klank.ar(`[[1, 2.756, 5.404, 8.933], [1, 0.6, 0.35, 0.2], [1.6, 1.0, 0.6, 0.4]], exc, freq);
        sig = sig * env * amp * 8;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // Respiração do tempo: sub lento e ar filtrado
    Ndef(\clockBreath, { |amp=0|
        var sub, air, lfo;
        lfo = LFPar.kr(0.09).range(0.15, 1.0);
        sub = (SinOsc.ar(41.2, 0, 0.25) + SinOsc.ar(82.4, 0, 0.06)) * lfo;
        air = LPF.ar(PinkNoise.ar(0.2), LFPar.kr(0.09).range(180, 900)) * lfo.squared;
        Pan2.ar(((sub + air) * amp).tanh, SinOsc.kr(0.05) * 0.3);
    });

    // Enxame de duzentos relógios: quarenta impulsos com defasagens microscópicas
    Ndef(\swarm, { |amp=0, dens=3, spread=0.0013|
        var voices, sig;
        voices = Array.fill(40, { |i|
            var rate = dens * (1 + (i * spread));
            Ringz.ar(Impulse.ar(rate, i * 0.137), 2600 * (1 + (i * 0.0021)), 0.03) * 0.12
        });
        sig = Splay.ar(voices);
        (HPF.ar(sig, 900) * amp * 4).tanh;
    });

    Ndef(\masterMix, { In.ar(~synthBus, 2) + Ndef.ar(\clockBreath, 2) + Ndef.ar(\swarm, 2) });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25) };
    Ndef(\clockBreath).fadeTime = 4;
    Ndef(\swarm).fadeTime = 3;
    Ndef(\masterMix).fadeTime = 2;
    Ndef(\masterMix).set(\wet10, 0.3);
    Ndef(\masterMix).play;
    s.sync;

    // Sequências: pêndulos levemente desencontrados
    Pbindef(\cronoSeq,
        \instrument, \pendTick,
        \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf),
        \freq, Pwhite(2800, 3600, inf),
        \amp, 0.12,
        \pan, Pwhite(-0.8, 0.8, inf),
        \out, ~synthBus
    );

    // Carrilhão francês: frases em tempos irregulares
    Pbindef(\carillonSeq,
        \instrument, \carillon,
        \dur, Pseq([1.5, 1.5, 0.75, 0.75, 3, 0.5, 0.5, 2], inf),
        \freq, Pseq([392, 440, 523.25, 392, 329.63, 440, 293.66, 392], inf),
        \amp, 0.18,
        \pan, Pwhite(-0.7, 0.7, inf),
        \out, ~synthBus
    );

    // Cronômetros de bolso: rajadas agudas e rápidas
    Pbindef(\pocketSeq,
        \instrument, \pendTick,
        \dur, Pn(Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.5]), inf),
        \freq, Pwhite(5000, 6200, inf),
        \amp, 0.07,
        \pan, Pwhite(-1.0, 1.0, inf),
        \out, ~synthBus
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Oficina silenciosa, respiração do tempo]".postln;
        Ndef(\clockBreath).xset(\amp, 1.0);
        8.wait;

        "0:08 - [Cue 2: Entra o enxame de tique-taques]".postln;
        Ndef(\swarm).xset(\amp, 0.6, \dens, 3);
        Pbindef(\cronoSeq).play;
        4.do { |i| Ndef(\swarm).xset(\spread, exprand(0.0005, 0.004)); 5.5.wait; };

        "0:30 - [Cue 3: Carrilhões desencontrados]".postln;
        Pbindef(\carillonSeq).play;
        Ndef(\swarm).xset(\dens, 5);
        4.do { |i| Ndef(\swarm).xset(\spread, exprand(0.001, 0.006)); 5.wait; };

        "1:00 - [Cue 4: Limite intrínseco, densidade extrema]".postln;
        Pbindef(\pocketSeq).play;
        6.do { |i|
            Ndef(\swarm).xset(\dens, 5 + (i * 1.6), \spread, 0.001 + (i * 0.0006));
            Pbindef(\cronoSeq, \dur, Pseq([0.5, 0.5 + (i * 0.0012), 0.5 - (i * 0.0010), 0.5 + (i * 0.0004)], inf));
            3.wait;
        };

        "1:20 - [Cue 5: Assentamento, fragilidade]".postln;
        Pbindef(\pocketSeq).stop;
        Pbindef(\carillonSeq).stop;
        Pbindef(\cronoSeq, \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf));
        Ndef(\swarm).xset(\dens, 1.5, \spread, 0.0013);
        8.wait;

        "1:36 - [Cue 6: Resolução, a nota inicial retorna]".postln;
        Pbindef(\carillonSeq, \dur, Pseq([2, 4], inf), \freq, Pseq([392, 392], inf));
        Pbindef(\carillonSeq).play;
        8.wait;
        Pbindef(\carillonSeq).stop;

        "1:50 - [Coda: dissolução do tempo]".postln;
        Ndef(\clockBreath).xset(\amp, 0.0);
        Ndef(\swarm).xset(\amp, 0.0);
        6.wait;

        Pbindef(\cronoSeq).stop; Pbindef(\cronoSeq).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
        Pbindef(\pocketSeq).stop; Pbindef(\pocketSeq).clear;
        Ndef(\swarm).clear(2);
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
~enableRecording = false;
s.waitForBoot({
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Gotas de calcário: impulsos de ressonância úmida
    SynthDef(\gotaCalcaria, { |out=0, freq=660, amp=0.3, pan=0|
        var env, sig, strike;
        env = EnvGen.ar(Env.perc(0.002, 2.4, 1, -7), doneAction: 2);
        strike = K2A.ar(Impulse.kr(0)) + Impulse.ar(0);
        sig = Ringz.ar(strike, [freq, freq * 2.76, freq * 5.4], [1.8, 0.9, 0.4]).sum;
        sig = LPF.ar(sig, 4200);
        Pan2.ar(sig * env * amp, pan);
    }).add;

    // Cortina mineral: sino grave de estalactite
    SynthDef(\estalactiteBell, { |out=0, freq=110, amp=0.4, pan=0|
        var env, sig, exc;
        env = EnvGen.ar(Env.perc(0.005, (2.5 - 1.6).max(0.05) + 1.6, 1, -4), doneAction: 2);
        exc = PinkNoise.ar(0.3) * EnvGen.ar(Env.perc(0.001, 0.03));
        sig = DynKlank.ar(Ref([[freq, freq * 2.32, freq * 4.25], [1, 0.5, 0.2], [3.0, 2.0, 1.2]]), exc);
        sig = sig + SinOsc.ar(freq * 2, 0, 0.05);
        Pan2.ar((sig * env * amp).tanh, pan);
    }).add;
    s.sync;

    // Ruído de caverna: sopro frio e lento
    Ndef(\cavernAir, { |amp=0, cut=400|
        var sig = LPF.ar(PinkNoise.ar(0.15), LFPar.kr(0.05).range(cut * 0.6, cut * 1.8));
        var lfo = SinOsc.kr(0.07).range(0.4, 1.0);
        Pan2.ar((sig * lfo * amp).tanh, SinOsc.kr(0.03) * 0.4);
    });

    // Lençol de ressonâncias: modos de rocha úmida
    Ndef(\limestoneDrone, { |amp=0, detune=0.004|
        var base = 55, sig;
        sig = Array.fill(4, { |i| SinOsc.ar(base * (1 + (i * detune)) * [1, 2, 3].choose, 0, 0.08) }).sum;
        sig = LPF.ar(sig + Saw.ar(base * 0.5, 0.02), 320);
        Splay.ar((sig * amp * 3).tanh);
    });

    Ndef(\masterMix, { In.ar(~synthBus, 2) + Ndef.ar(\cavernAir, 2) + Ndef.ar(\limestoneDrone, 2) });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.3) };
    Ndef(\cavernAir).fadeTime = 4;
    Ndef(\limestoneDrone).fadeTime = 6;
    Ndef(\masterMix).fadeTime = 2;
    Ndef(\masterMix).set(\wet10, 0.35);
    Ndef(\masterMix).play;
    s.sync;

    // Gotejamento lento das estalactites
    Pbindef(\gotaSeq,
        \instrument, \gotaCalcaria,
        \dur, Pseq([1.8, 1.8, 0.9, 2.7], inf),
        \freq, Pseq([660, 587.33, 740, 523.25], inf),
        \amp, 0.22,
        \pan, Pwhite(-0.7, 0.7, inf),
        \out, ~synthBus
    );

    // Sinos de estalactite: frases graves em tempos irregulares
    Pbindef(\bellSeq,
        \instrument, \estalactiteBell,
        \dur, Pseq([3, 1.5, 0.75, 0.75, 4.5, 2], inf),
        \freq, Pseq([55, 65.41, 49, 55, 73.42, 65.41], inf),
        \amp, 0.35,
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    // Rajada de gotas rápidas em salão estreito
    Pbindef(\dripBurstSeq,
        \instrument, \gotaCalcaria,
        \dur, Pn(Pseq([0.125, 0.125, 0.25, 0.5]), inf),
        \freq, Pwhite(2400, 3800, inf),
        \amp, 0.1,
        \pan, Pwhite(-1.0, 1.0, inf),
        \out, ~synthBus
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Entrada na Gruta, ar frio e silêncio]".postln;
        Ndef(\cavernAir).xset(\amp, 0.8);
        Ndef(\limestoneDrone).xset(\amp, 0.7);
        8.wait;

        "0:08 - [Cue 2: Gotejamento das estalactites]".postln;
        Pbindef(\gotaSeq).play;
        4.do { |i| Ndef(\cavernAir).xset(\cut, exprand(250, 900)); 5.5.wait; };

        "0:30 - [Cue 3: Sinos graves dos salões]".postln;
        Pbindef(\bellSeq).play;
        Pbindef(\gotaSeq, \dur, Pseq([0.9, 0.9, 1.8, 0.45], inf));
        4.do { |i| Ndef(\limestoneDrone).xset(\detune, exprand(0.002, 0.012)); 5.wait; };

        "1:00 - [Cue 4: Limite intrínseco, rajada extrema]".postln;
        Pbindef(\dripBurstSeq).play;
        6.do { |i|
            Pbindef(\gotaSeq, \dur, Pseq([0.25, 0.25, 0.5, 0.125 + (i * 0.02)], inf));
            Ndef(\cavernAir).xset(\cut, 900 + (i * 250));
            3.wait;
        };

        "1:20 - [Cue 5: Assentamento, fragilidade]".postln;
        Pbindef(\dripBurstSeq).stop;
        Pbindef(\bellSeq).stop;
        Pbindef(\gotaSeq, \dur, Pseq([1.8, 1.8, 0.9, 2.7], inf));
        Ndef(\cavernAir).xset(\cut, 300);
        8.wait;

        "1:36 - [Cue 6: Resolução, a nota grave retorna]".postln;
        Pbindef(\bellSeq, \dur, Pseq([4, 4], inf), \freq, Pseq([55, 55], inf));
        Pbindef(\bellSeq).play;
        8.wait;
        Pbindef(\bellSeq).stop;

        "1:50 - [Coda: dissolução nas águas]".postln;
        Ndef(\cavernAir).xset(\amp, 0.0);
        Ndef(\limestoneDrone).xset(\amp, 0.0);
        6.wait;

        Pbindef(\gotaSeq).stop; Pbindef(\gotaSeq).clear;
        Pbindef(\bellSeq).stop; Pbindef(\bellSeq).clear;
        Pbindef(\dripBurstSeq).stop; Pbindef(\dripBurstSeq).clear;
        Ndef(\cavernAir).clear(2);
        Ndef(\limestoneDrone).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

