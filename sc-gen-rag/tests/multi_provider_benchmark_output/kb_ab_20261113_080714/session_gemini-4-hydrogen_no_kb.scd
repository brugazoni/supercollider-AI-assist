// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Hydrogen
// Model ID: openrouter:google/gemini-4-hydrogen
// Date: 2026-11-13T11:09:08.843603+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\antarcticSilence, { |freq=55, amp=0.25, pan=0, atk=2.5, rel=6.0, cutoff=800, t_trig=0|
    var env = EnvGen.ar(Env.perc(atk, rel, 1, -2), t_trig);
    var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var wind = BPF.ar(PinkNoise.ar, freq * [3.0, 4.5, 6.2], 0.025) * 10.0;
    var drone = LPF.ar(Splay.ar(wind) + sub, cutoff);
    var sig = drone * (0.25 + (env * 0.75));
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\antarcticSilenceSeq,
    \dur, Pseq([8, 10, 6], inf),
    \midinote, Pseq([33, 34, 31, 33], inf),
    \t_trig, 1,
    \cutoff, Pwhite(400, 1200, inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \amp, 0.25
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);
// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\ironChains, { |freq=220, amp=0.22, pan=0, ring=0.6, whip=0.5, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.001, 0.04, 1, -6), t_trig);
    var whipNoise = HPF.ar(WhiteNoise.ar, 2400) * env * whip;
    var strike = Impulse.ar(0) + (HPF.ar(PinkNoise.ar, 1200) * EnvGen.ar(Env.perc(0.0005, 0.015), t_trig));
    var modes = [1.0, 2.73, 4.18, 5.89, 7.42];
    var chains = Splay.ar(Ringz.ar(strike, freq * modes, ring * [1.0, 0.8, 0.6, 0.4, 0.3]) * 0.15);
    var sig = chains + Pan2.ar(whipNoise, pan);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\ironChainsSeq,
    \dur, Pwrand([0.25, 0.5, 0.75, 1.5], [0.4, 0.3, 0.2, 0.1], inf),
    \midinote, Pseq([45, 46, 52, 45, 50, 48], inf),
    \t_trig, 1,
    \ring, Pwhite(0.2, 0.9, inf),
    \whip, Pwrand([0.1, 0.8], [0.7, 0.3], inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pwhite(0.15, 0.28, inf)
);

Ndef(\ironChains)[1] = \set -> Pbindef(\ironChainsSeq);
// Pbindef(\ironChainsSeq).stop; Ndef(\ironChains).fadeTime = 2; Ndef(\ironChains).clear(2); // Rollback: remove this instrument
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

    // 1. Discrete SynthDefs
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.25, pan=0, decay=0.04, click=0.7|
        var env = EnvGen.ar(Env.perc(0.0005, decay, 1, -6), doneAction: 2);
        var exc = Impulse.ar(0) + (HPF.ar(WhiteNoise.ar, 3200) * EnvGen.ar(Env.perc(0.0002, 0.008)) * click);
        var modes = [1.0, 1.87, 2.93, 4.12];
        var res = Mix.fill(4, { |i| Ringz.ar(exc, (freq * modes[i]).clip(80, 16000), decay * (1.0 - (i * 0.18))) }) * 0.18;
        var sig = (res + (exc * 0.25)) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\frenchChime, { |out=0, freq=880, amp=0.18, pan=0, dur=2.2, modIdx=1.8|
        var rel = (dur - 0.01).max(0.2);
        var env = EnvGen.ar(Env.perc(0.004, rel, 1, -4), doneAction: 2);
        var modEnv = EnvGen.ar(Env.perc(0.002, rel * 0.35, 1, -5));
        var mod = SinOsc.ar(freq * 2.71) * (freq * modIdx * modEnv);
        var car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 2.003) * 0.25);
        var sig = LPF.ar(car, 7500) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\pendulumWood, { |out=0, freq=98, amp=0.35, pan=0, decay=0.65|
        var env = EnvGen.ar(Env.perc(0.005, decay, 1, -3), doneAction: 2);
        var thud = LPF.ar(PinkNoise.ar, 420) * EnvGen.ar(Env.perc(0.002, 0.035));
        var freqs = [freq, freq * 1.52, freq * 2.38, freq * 3.15];
        var amps = [1.0, 0.6, 0.35, 0.2];
        var rings = [0.6, 0.45, 0.3, 0.2];
        var body = DynKlank.ar(Ref([freqs, amps, rings]), thud, 1.0, 0.0, decay);
        var sig = LPF.ar(body + (SinOsc.ar(freq) * 0.35), 1800) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // 2. Continuous Ndefs
    Ndef(\gearSwarm, { |amp=0.0, density=28, centerFreq=2600, spread=0.8|
        var trigs = Array.fill(4, { |i| Dust.ar(density * (0.85 + (i * 0.11))) });
        var ticks = trigs.collect({ |tr, i|
            var f = centerFreq * (0.75 + (i * 0.22));
            BPF.ar(WhiteNoise.ar * Decay.ar(tr, 0.012), f, 0.12) * 4.5
        });
        var sig = Splay.ar(ticks, spread);
        sig = AllpassC.ar(sig, 0.05, [0.013, 0.021], 0.18);
        sig * amp;
    });

    Ndef(\timeBreath, { |amp=0.0, baseFreq=110, breathRate=0.22, cutoff=1100|
        var lfo = SinOsc.kr(breathRate).range(0.25, 1.0);
        var beat1 = SinOsc.ar([baseFreq, baseFreq + 0.35]);
        var beat2 = SinOsc.ar([baseFreq * 1.5, (baseFreq * 1.5) - 0.28]) * 0.5;
        var air = BPF.ar(PinkNoise.ar, baseFreq * [3.0, 4.5], 0.08) * 3.2;
        var sig = LPF.ar((beat1 + beat2 + air) * lfo, cutoff);
        sig * amp;
    });

    // 3. Master Mix & FX
    Ndef(\masterMix, {
        var dry = In.ar(~synthBus, 2);
        var swarm = Ndef.ar(\gearSwarm, 2);
        var breath = Ndef.ar(\timeBreath, 2);
        dry + swarm + breath;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.3);
    };
    Ndef(\masterMix).set(\wet10, 0.15);
    Ndef(\masterMix).play;
    s.sync;

    // 4. Patterns
    Pbindef(\pendulumSeq,
        \instrument, \pendulumWood,
        \out, ~synthBus,
        \dur, Pseq([1.0, 1.0, 1.0, 1.02], inf),
        \freq, Pseq([98, 96, 98, 95], inf),
        \decay, 0.6,
        \pan, Pwhite(-0.2, 0.2, inf),
        \amp, 0.32
    );

    Pbindef(\brassTickSeq,
        \instrument, \brassTick,
        \out, ~synthBus,
        \dur, Pwrand([0.125, 0.25, 0.18, 0.33], [0.4, 0.3, 0.2, 0.1], inf),
        \freq, Pexprand(1800, 4800, inf),
        \decay, Pwhite(0.02, 0.055, inf),
        \click, Pwhite(0.4, 0.9, inf),
        \pan, Pwhite(-0.85, 0.85, inf),
        \amp, Pwhite(0.12, 0.26, inf)
    );

    Pbindef(\chimeSeq,
        \instrument, \frenchChime,
        \out, ~synthBus,
        \dur, Pwrand([0.75, 1.5, 2.25, Rest(1.0)], [0.35, 0.3, 0.2, 0.15], inf),
        \midinote, Pseq([72, 76, 79, 83, 84, 79, 74, 71], inf),
        \modIdx, Pwhite(1.2, 2.4, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \amp, Pwhite(0.1, 0.18, inf)
    );

    // 5. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Estreita]".postln;
        Pbindef(\pendulumSeq).play;
        4.wait;
        Pbindef(\brassTickSeq).play;
        6.wait;

        "0:10 - [Cue 2: Duzentos Relogios]".postln;
        Ndef(\gearSwarm).fadeTime = 4;
        Ndef(\gearSwarm).xset(\amp, 0.18, \density, 24, \centerFreq, 2400);
        4.wait;
        Pbindef(\chimeSeq).play;
        8.wait;

        "0:22 - [Cue 3: O Enxame de Latao]".postln;
        Ndef(\masterMix).set(\wet10, 0.32);
        4.do { |i|
            Ndef(\gearSwarm).xset(\density, 32 + (i * 18), \centerFreq, 2600 + (i * 450), \amp, 0.24);
            4.wait;
        };

        "0:38 - [Cue 4: O Respirar do Tempo]".postln;
        Pbindef(\brassTickSeq).stop;
        Pbindef(\pendulumSeq).stop;
        Ndef(\gearSwarm).fadeTime = 2.5;
        Ndef(\gearSwarm).xset(\amp, 0.0);
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.32, \baseFreq, 110, \breathRate, 0.2);
        Ndef(\masterMix).set(\wet10, 0.45);
        Pbindef(\chimeSeq, \dur, Pseq([2.5, 3.0, Rest(1.5)], inf), \amp, 0.14);
        3.do { |i|
            Ndef(\timeBreath).xset(\cutoff, 800 + (i * 350));
            5.wait;
        };

        "0:53 - [Cue 5: Ultimo Pendulo]".postln;
        Pbindef(\chimeSeq).stop;
        Pbindef(\pendulumSeq, \dur, Pseq([1.5, 1.5], inf), \amp, 0.26).play;
        5.wait;
        Pbindef(\pendulumSeq).stop;
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.0);
        5.wait;

        Pbindef(\pendulumSeq).clear;
        Pbindef(\brassTickSeq).clear;
        Pbindef(\chimeSeq).clear;
        Ndef(\gearSwarm).clear(2);
        Ndef(\timeBreath).clear(2);
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

    // 1. Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete SynthDefs (Limestone & Water)
    SynthDef(\cavernDrop, { |out=0, freq=1200, decay=0.35, pan=0, amp=0.3|
        var env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), doneAction: 2);
        var pitchEnv = EnvGen.kr(Env.perc(0.001, 0.045, 1, -4));
        var bubble = SinOsc.ar(freq * (1.0 + (pitchEnv * 0.65)));
        var stone = Ringz.ar(Impulse.ar(0), freq * 0.5, decay * 0.8) * 0.25;
        var sig = (bubble + stone) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\stalactiteStrike, { |out=0, freq=440, decay=2.8, pan=0, amp=0.25|
        var env = EnvGen.ar(Env.perc(0.004, decay, 1, -5), doneAction: 2);
        var exc = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.012))) + Impulse.ar(0);
        var modes = DynKlank.ar(
            Ref([
                [1.0, 2.32, 3.87, 5.41] * freq,
                [1.0, 0.55, 0.28, 0.14],
                [1.0, 0.75, 0.5, 0.3]
            ]),
            exc,
            decayscale: decay
        );
        var sig = LPF.ar(modes, 5200) * env * amp * 0.35;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // 3. Continuous Cavern Textures
    Ndef(\cavernAir, { |amp=0.0, baseFreq=55, cutoff=320|
        var sub = SinOsc.ar([baseFreq, baseFreq + 0.22]) + (SinOsc.ar(baseFreq * 2) * 0.35);
        var air = LPF.ar(PinkNoise.ar([0.4, 0.4]), cutoff);
        var swell = SinOsc.kr(0.11).range(0.5, 1.0);
        var sig = (sub * 0.45 + air) * swell;
        sig * amp;
    });

    Ndef(\mineralStream, { |amp=0.0, density=14, centerFreq=1800, spread=0.8|
        var drops = Array.fill(4, { |i|
            var tr = Dust.ar(density * (0.7 + (i * 0.15)));
            var f = centerFreq * (0.8 + (i * 0.25));
            BPF.ar(WhiteNoise.ar * Decay.ar(tr, 0.018), f, 0.09) * 6.0;
        });
        var sig = Splay.ar(drops, spread);
        sig = AllpassC.ar(sig, 0.08, [0.029, 0.043], 0.35);
        sig * amp;
    });

    // 4. Master Mix & Subterranean Reverb
    Ndef(\masterMix, {
        var dry = In.ar(~synthBus, 2);
        var air = Ndef.ar(\cavernAir, 2);
        var stream = Ndef.ar(\mineralStream, 2);
        dry + air + stream;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.42);
    Ndef(\masterMix).play;
    s.sync;

    // 5. Patterns
    Pbindef(\dropSeq,
        \instrument, \cavernDrop,
        \out, ~synthBus,
        \dur, Pwrand([1.2, 2.1, 0.85, Rest(1.5)], [0.35, 0.3, 0.2, 0.15], inf),
        \freq, Pexprand(750, 2600, inf),
        \decay, Pwhite(0.22, 0.55, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \amp, Pwhite(0.18, 0.32, inf)
    );

    Pbindef(\stalactiteSeq,
        \instrument, \stalactiteStrike,
        \out, ~synthBus,
        \dur, Pwrand([1.75, 2.5, 3.25, Rest(2.0)], [0.35, 0.3, 0.2, 0.15], inf),
        \midinote, Pseq([48, 55, 60, 62, 67, 63, 55, 50], inf),
        \decay, Pwhite(2.2, 4.0, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \amp, Pwhite(0.16, 0.28, inf)
    );

    // 6. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: O Primeiro Salao]".postln;
        Ndef(\cavernAir).fadeTime = 4;
        Ndef(\cavernAir).xset(\amp, 0.28, \baseFreq, 55, \cutoff, 280);
        4.wait;
        Pbindef(\dropSeq).play;
        6.wait;
        6.wait;

        "0:16 - [Cue 2: Cortinas Minerais]".postln;
        Ndef(\masterMix).set(\wet10, 0.55);
        Pbindef(\stalactiteSeq).play;
        4.do { |i|
            Ndef(\cavernAir).xset(\cutoff, 280 + (i * 85));
            5.wait;
        };

        "0:36 - [Cue 3: Gotejamento Acelerado]".postln;
        Ndef(\mineralStream).fadeTime = 4;
        Ndef(\mineralStream).xset(\amp, 0.22, \density, 18, \centerFreq, 1900);
        Pbindef(\dropSeq, \dur, Pwrand([0.22, 0.35, 0.5, 0.15], [0.35, 0.3, 0.2, 0.15], inf));
        4.do { |i|
            Ndef(\mineralStream).xset(\density, 20 + (i * 12), \centerFreq, 1900 + (i * 350));
            5.wait;
        };

        "0:56 - [Cue 4: Silencio da Pedra]".postln;
        Ndef(\mineralStream).fadeTime = 3;
        Ndef(\mineralStream).xset(\amp, 0.0);
        Pbindef(\dropSeq, \dur, Pseq([2.4, 3.2, Rest(2.0)], inf), \amp, 0.2);
        Pbindef(\stalactiteSeq, \dur, Pseq([3.5, 4.5, Rest(2.0)], inf), \amp, 0.22);
        Ndef(\cavernAir).xset(\cutoff, 220, \amp, 0.22);
        6.wait;
        6.wait;
        6.wait;

        "1:14 - [Cue 5: Escuridao Subterranea]".postln;
        Pbindef(\stalactiteSeq).stop;
        6.wait;
        Pbindef(\dropSeq).stop;
        Ndef(\cavernAir).fadeTime = 5;
        Ndef(\cavernAir).xset(\amp, 0.0);
        6.wait;

        Pbindef(\dropSeq).clear;
        Pbindef(\stalactiteSeq).clear;
        Ndef(\cavernAir).clear(2);
        Ndef(\mineralStream).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

