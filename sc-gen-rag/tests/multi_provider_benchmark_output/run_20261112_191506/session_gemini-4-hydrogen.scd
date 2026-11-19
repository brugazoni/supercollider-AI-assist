// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Hydrogen
// Model ID: openrouter:google/gemini-4-hydrogen
// Date: 2026-11-12T22:22:13.391429+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\antarcticSilence, { |freq=55, amp=0.18, pan=0, atk=1.5, rel=4.0, cutoff=1200, rq=0.05, windAmp=0.12, t_trig=0|
    var env = EnvGen.ar(Env.perc(atk, rel, 1, -2), t_trig);
    var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var wind = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.15).range(0.8, 1.3), rq) * 10.0 * windAmp;
    var shimmer = Mix.fill(4, { |i|
        SinOsc.ar(freq * (i + 3) * LFNoise1.kr(0.08).range(0.995, 1.005)) * (0.15 / (i + 1))
    });
    var sig = (sub * 0.5) + (shimmer * env) + wind;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\silenceSeq,
    \dur, Pseq([4, 6, 5, 8], inf),
    \freq, Pseq([55, 51.91, 49, 55], inf),
    \cutoff, Pseq([900, 1400, 750, 1800], inf),
    \t_trig, 1,
    \amp, Pwhite(0.15, 0.22, inf),
    \pan, Pwhite(-0.2, 0.2, inf)
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\silenceSeq);
// Pbindef(\silenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\ironChains, { |freq=180, amp=0.25, pan=0, rel=0.8, whipAmp=0.6, ironAmp=0.7, t_trig=0|
    var whipEnv = EnvGen.ar(Env.perc(0.001, 0.05, 1, -8), t_trig);
    var ironEnv = EnvGen.ar(Env.perc(0.002, rel, 1, -4), t_trig);
    var trigAudio = K2A.ar(t_trig);
    var noise = WhiteNoise.ar * whipEnv * whipAmp;
    var whip = HPF.ar(noise, 1800) + BPF.ar(noise, 3400, 0.35);
    var iron = Ringz.ar(
        (trigAudio * 0.5) + (PinkNoise.ar * whipEnv * 0.2),
        freq * [1, 1.47, 2.13, 3.31],
        [0.45, 0.32, 0.55, 0.28]
    ).sum * 0.25 * ironAmp * ironEnv;
    var sig = ((whip + iron) * 1.6).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\chainsSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75, 0.5, 0.25, 0.25], inf),
    \freq, Pseq([180, 210, 145, 260, 130, 195, 240, 160], inf),
    \rel, Pwhite(0.4, 1.1, inf),
    \t_trig, 1,
    \amp, Pwhite(0.18, 0.32, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\ironChains)[1] = \set -> Pbindef(\chainsSeq);
// Pbindef(\chainsSeq).stop; Ndef(\ironChains).fadeTime = 2; Ndef(\ironChains).clear(2); // Rollback: remove this instrument
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

    // 2. Discrete SynthDefs
    SynthDef(\brassTick, { |out=0, freq=1400, amp=0.25, pan=0, dur=0.12, metal=0.6|
        var env = EnvGen.ar(Env.perc(0.001, dur.max(0.03), 1, -8), doneAction: 2);
        var click = (Impulse.ar(0) * 0.8) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.008)));
        var body = Ringz.ar(click, freq * [1, 1.62, 2.71], [0.04, 0.025, 0.015]).sum * 0.35;
        var sig = (click * (1 - metal)) + (body * metal);
        sig = HPF.ar(sig, 350) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pocketChrono, { |out=0, freq=3800, amp=0.15, pan=0|
        var env = EnvGen.ar(Env.perc(0.0005, 0.035, 1, -10), doneAction: 2);
        var trig = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003)));
        var sig = BPF.ar(trig, freq, 0.15) * 6.0;
        sig = sig * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\frenchChime, { |out=0, freq=440, amp=0.22, pan=0, dur=3.5, modIdx=1.8|
        var env = EnvGen.ar(Env.perc(0.005, (dur - 0.005).max(0.2), 1, -4), doneAction: 2);
        var modEnv = EnvGen.ar(Env.perc(0.002, 0.4, 1, -6));
        var mod1 = SinOsc.ar(freq * 2.756) * (freq * modIdx * modEnv);
        var mod2 = SinOsc.ar(freq * 5.404) * (freq * (modIdx * 0.4) * modEnv);
        var car = SinOsc.ar(freq + mod1 + mod2) * 0.5;
        var res = DynKlank.ar(
            Ref([ [freq, freq * 2.01, freq * 3.02, freq * 4.18], [0.5, 0.3, 0.15, 0.08], [2.5, 1.8, 1.1, 0.6] ]),
            Impulse.ar(0) * 0.25,
            1, 0, 0.8
        );
        var sig = (car + (res * 0.45)) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // 3. Continuous Ndefs
    Ndef(\timeBreath, { |amp=0, freq=73.42, cutoff=420, breathRate=0.14|
        var breath = SinOsc.kr(breathRate).range(0.4, 1.0) * LFNoise1.kr(0.08).range(0.75, 1.15);
        var air = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.11).range(0.85, 1.25), 0.12) * 5.5;
        var sub = (SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4)) * 0.35;
        var sig = (air + sub) * breath;
        Splay.ar([sig, DelayC.ar(sig, 0.05, 0.017)], 0.6) * amp;
    });

    Ndef(\clockSwarm, { |amp=0, density=14, baseFreq=1800|
        var trigs = Array.fill(4, { |i| Dust.ar(density * (0.85 + (i * 0.12))) });
        var voices = trigs.collect({ |tr, i|
            var f = baseFreq * (0.7 + (i * 0.35)) * LFNoise0.kr(2 + i).range(0.92, 1.08);
            Ringz.ar(tr * 0.3, f, 0.025)
        });
        Splay.ar(voices, 0.85) * amp;
    });

    // 4. Master Mixer
    Ndef(\masterMix, {
        var bus = In.ar(~synthBus, 2);
        var breath = Ndef.ar(\timeBreath, 2);
        var swarm = Ndef.ar(\clockSwarm, 2);
        bus + breath + swarm;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.18);
    Ndef(\masterMix).play;
    s.sync;

    // 5. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: O Pêndulo e o Cronômetro]".postln;
        Pbindef(\tickSeq,
            \instrument, \brassTick,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf),
            \freq, Pseq([1200, 980, 1220, 960], inf),
            \metal, 0.7,
            \amp, Pwhite(0.18, 0.24, inf),
            \pan, Pseq([-0.3, 0.3], inf)
        ).play;

        Pbindef(\chronoSeq,
            \instrument, \pocketChrono,
            \out, ~synthBus,
            \dur, Pseq([0.166, 0.166, 0.168], inf),
            \freq, Pwhite(3600, 4400, inf),
            \amp, Pwhite(0.08, 0.13, inf),
            \pan, 0.45
        ).play;
        8.wait;

        "0:08 - [Cue 2: O Enxame de Engrenagens]".postln;
        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, 0.16, \density, 12);
        Pbindef(\tickSeq, \dur, Pseq([0.48, 0.52, 0.49, 0.51], inf), \pan, Pwhite(-0.7, 0.7, inf));
        2.do { |i|
            Ndef(\clockSwarm).xset(\density, 14 + (i * 8), \baseFreq, 1700 + (i * 300));
            5.wait;
        };

        "0:18 - [Cue 3: Carrilhões Franceses e o Respirar do Tempo]".postln;
        Ndef(\timeBreath).fadeTime = 6;
        Ndef(\timeBreath).xset(\amp, 0.22, \cutoff, 480);
        Ndef(\masterMix).set(\wet10, 0.32);

        Pbindef(\chimeSeq,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([3.5, 2.5, 4.0, 3.0], inf),
            \midinote, Pseq([62, 69, 65, 72, 60, 67], inf),
            \dur, Pseq([3.5, 2.5, 4.0, 3.0], inf),
            \modIdx, Pwhite(1.2, 2.2, inf),
            \amp, Pwhite(0.14, 0.20, inf),
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.do { |i|
            Ndef(\timeBreath).xset(\cutoff, 420 + (i * 180));
            6.wait;
        };

        "0:36 - [Cue 4: Defasagem Máxima (Limite Intrínseco)]".postln;
        Pbindef(\chronoSeq, \dur, Pseq([0.11, 0.12, 0.11, 0.13], inf), \amp, Pwhite(0.12, 0.18, inf));
        3.do { |i|
            Ndef(\clockSwarm).xset(\density, 28 + (i * 14), \amp, 0.24);
            4.wait;
        };

        "0:48 - [Cue 5: O Velho Relojoeiro Fecha os Olhos (Flashback)]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\chimeSeq).stop;
        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, 0.0);
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.28, \cutoff, 320, \breathRate, 0.1);
        Pbindef(\chronoSeq, \dur, 0.25, \amp, Pwhite(0.06, 0.10, inf), \pan, 0);
        8.wait;

        "0:56 - [Cue 6: Resolução e Silêncio]".postln;
        Pbindef(\chronoSeq).stop;
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.0);
        5.wait;

        // Scoped Termination
        Pbindef(\tickSeq).stop; Pbindef(\tickSeq).clear;
        Pbindef(\chronoSeq).stop; Pbindef(\chronoSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Ndef(\timeBreath).clear(2);
        Ndef(\clockSwarm).clear(2);
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
    // 1. Configuration & Safety Limiter
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

    // 2. Discrete SynthDefs
    SynthDef(\waterDrop, { |out=0, freq=900, amp=0.2, pan=0, decay=0.25|
        var pEnv = EnvGen.kr(Env.perc(0.002, 0.06, 1, -4));
        var aEnv = EnvGen.ar(Env.perc(0.002, decay.max(0.05), 1, -6), doneAction: 2);
        var drop = SinOsc.ar(freq * (1 + (pEnv * 0.45))) * aEnv;
        var cav = Ringz.ar(drop * 0.3, freq * 1.5, decay * 0.8);
        var sig = (drop * 0.7) + (cav * 0.3);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\stalactiteStrike, { |out=0, freq=440, amp=0.18, pan=0, dur=2.5|
        var exc = (Impulse.ar(0) * 0.8) + (BPF.ar(PinkNoise.ar, freq * 2, 0.3) * EnvGen.ar(Env.perc(0.001, 0.02)));
        var env = EnvGen.ar(Env.perc(0.005, dur.max(0.1), 1, -4), doneAction: 2);
        var freqs = [freq, freq * 2.13, freq * 3.47, freq * 5.12];
        var amps = [0.6, 0.35, 0.2, 0.1];
        var rings = [dur, dur * 0.7, dur * 0.45, dur * 0.25];
        var res = DynKlank.ar(Ref([freqs, amps, rings]), exc);
        Out.ar(out, Pan2.ar(res * env * 0.25, pan, amp));
    }).add;

    SynthDef(\subterraneanRes, { |out=0, freq=65, amp=0.25, pan=0, dur=4.0|
        var env = EnvGen.ar(Env.linen(0.8, (dur - 1.6).max(0.1), 1.2, 1, -3), doneAction: 2);
        var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
        var air = BPF.ar(PinkNoise.ar, freq * 3, 0.08) * 6.0;
        var sig = LPF.ar((sub * 0.7) + (air * 0.3), 420) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // 3. Continuous Ndefs
    Ndef(\cavernAir, { |amp=0, cutoff=320, panRate=0.07|
        var noise = PinkNoise.ar([0.8, 0.85]);
        var sweep = SinOsc.kr(0.05).range(0.7, 1.4);
        var sig = BPF.ar(noise, cutoff * sweep, 0.35) * 2.2;
        var ref = CombL.ar(sig, 0.2, [0.087, 0.113], 1.8);
        Balance2.ar(sig[0] + (ref[0] * 0.4), sig[1] + (ref[1] * 0.4), SinOsc.kr(panRate) * 0.3, amp);
    });

    Ndef(\mineralDripCloud, { |amp=0, density=6, baseFreq=1400|
        var trigs = Array.fill(4, { |i| Dust.ar(density * (0.7 + (i * 0.2))) });
        var voices = trigs.collect({ |tr, i|
            var f = baseFreq * (0.65 + (i * 0.28)) * LFNoise0.kr(1.5 + i).range(0.85, 1.15);
            Ringz.ar(tr * 0.25, f, 0.04)
        });
        Splay.ar(voices, 0.9) * amp;
    });

    // 4. Master Mixer
    Ndef(\masterMix, {
        var bus = In.ar(~synthBus, 2);
        var air = Ndef.ar(\cavernAir, 2);
        var cloud = Ndef.ar(\mineralDripCloud, 2);
        bus + air + cloud;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.35);
    Ndef(\masterMix).play;
    s.sync;

    // 5. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Escuridao Calcaria]".postln;
        Ndef(\cavernAir).fadeTime = 5;
        Ndef(\cavernAir).xset(\amp, 0.14, \cutoff, 280);

        Pbindef(\dropSeq,
            \instrument, \waterDrop,
            \out, ~synthBus,
            \dur, Pwhite(0.9, 2.2, inf),
            \freq, Pexprand(650, 1800, inf),
            \decay, Pwhite(0.18, 0.38, inf),
            \amp, Pwhite(0.14, 0.22, inf),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;
        2.do { |i|
            Ndef(\cavernAir).xset(\cutoff, 280 + (i * 60));
            6.wait;
        };

        "0:12 - [Cue 2: Os Sete Saloes]".postln;
        Ndef(\masterMix).set(\wet10, 0.48);
        Pbindef(\stalactiteSeq,
            \instrument, \stalactiteStrike,
            \out, ~synthBus,
            \dur, Pseq([2.5, 3.0, 2.0, 3.5], inf),
            \midinote, Pseq([64, 71, 67, 74, 62, 69], inf),
            \amp, Pwhite(0.14, 0.20, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;
        2.do { |i|
            Ndef(\cavernAir).xset(\cutoff, 360 + (i * 80));
            7.wait;
        };

        "0:26 - [Cue 3: Ressonancias Profundas]".postln;
        Ndef(\mineralDripCloud).fadeTime = 6;
        Ndef(\mineralDripCloud).xset(\amp, 0.12, \density, 7, \baseFreq, 1300);

        Pbindef(\vaultSeq,
            \instrument, \subterraneanRes,
            \out, ~synthBus,
            \dur, Pseq([4.0, 4.0], inf),
            \midinote, Pseq([36, 38, 33, 36], inf),
            \amp, 0.26,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;
        2.do { |i|
            Ndef(\mineralDripCloud).xset(\density, 9 + (i * 4));
            8.wait;
        };

        "0:42 - [Cue 4: Gotejamento Intenso (Limite Intrinseco)]".postln;
        Ndef(\masterMix).set(\wet10, 0.58);
        Pbindef(\dropSeq, \dur, Pwhite(0.25, 0.65, inf), \amp, Pwhite(0.16, 0.24, inf));
        Pbindef(\stalactiteSeq, \dur, Pseq([1.5, 1.25, 1.75, 1.0], inf));
        3.do { |i|
            Ndef(\mineralDripCloud).xset(\density, 16 + (i * 6), \amp, 0.18);
            4.wait;
        };

        "0:54 - [Cue 5: Cortinas Minerais (Settling)]".postln;
        Pbindef(\vaultSeq).stop;
        Ndef(\mineralDripCloud).fadeTime = 3;
        Ndef(\mineralDripCloud).xset(\amp, 0.0);
        Ndef(\cavernAir).fadeTime = 4;
        Ndef(\cavernAir).xset(\amp, 0.10, \cutoff, 240);
        Pbindef(\dropSeq, \dur, Pwhite(1.4, 2.8, inf), \amp, Pwhite(0.10, 0.16, inf));
        Pbindef(\stalactiteSeq, \dur, Pseq([3.0, 4.0], inf), \amp, 0.14);
        2.do { 6.wait; };

        "1:06 - [Cue 6: Silencio na Gruta (Resolucao)]".postln;
        Pbindef(\dropSeq).stop;
        Pbindef(\stalactiteSeq).stop;
        Ndef(\cavernAir).fadeTime = 5;
        Ndef(\cavernAir).xset(\amp, 0.0);
        6.wait;

        // Scoped Termination
        Pbindef(\dropSeq).stop; Pbindef(\dropSeq).clear;
        Pbindef(\stalactiteSeq).stop; Pbindef(\stalactiteSeq).clear;
        Pbindef(\vaultSeq).stop; Pbindef(\vaultSeq).clear;
        Ndef(\cavernAir).clear(2);
        Ndef(\mineralDripCloud).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Step 0: CC Mapping Dictionary
~cc = (
    vol1: 10, pan1: 11, mute1: 12, min1: 13, max1: 14, hpf1: 15, lpf1: 16, rq1: 17, atk1: 18, dec1: 19, sus1: 20, rls1: 21, fxFold: 22,
    vol2: 30, pan2: 31, mute2: 32, min2: 33, max2: 34, hpf2: 35, lpf2: 36, rq2: 37, atk2: 38, dec2: 39, sus2: 40, rls2: 41, fxPhase: 42,
    vol3: 50, pan3: 51, mute3: 52, min3: 53, max3: 54, hpf3: 55, lpf3: 56, rq3: 57, atk3: 58, dec3: 59, sus3: 60, rls3: 61, fxDrift: 62,
    delMix: 70, delTime: 71, delFb: 72, verbMix: 73, revTime: 74,
    panic: 120
);

// Step 1 & 2: MIDI Discovery & Hardware Fallback
MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

// Step 3: Server Boot, Buses, SynthDefs, FX, MIDIdefs, & GUI
s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 64, hpf1: 28, lpf1: 220, rq1: 0.45, atk1: 0.01, dec1: 0.25, sus1: 0.75, rls1: 0.35, fxFold: 0.0,
        vol2: 0.24, pan2: -0.35, mute2: 0.0, min2: 36, max2: 108, hpf2: 240, lpf2: 6500, rq2: 0.35, atk2: 0.008, dec2: 0.45, sus2: 0.40, rls2: 0.65, fxPhase: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 180, lpf3: 3800, rq3: 0.50, atk3: 0.35, dec3: 0.80, sus3: 0.70, rls3: 1.40, fxDrift: 0.0,
        delMix: 0.0, delTime: 0.32, delFb: 0.35, verbMix: 0.0, revTime: 2.8
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // Zone 1: Pin Matrix Sub (Wavefolding Buchla-style Sub)
    SynthDef(\pinMatrixSub, { |out=0, freq=55, amp=0.5, gate=1,
        vol=0.28, pan=0.0, mute=0.0, hpf=28, lpf=220, rq=0.45,
        atk=0.01, dec=0.25, sus=0.75, rls=0.35, fxFold=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var core = SinOsc.ar(freq) + (Pulse.ar(freq * 0.5, 0.42) * 0.35);
        var folded = Fold.ar(core * (1.0 + (fxFold * 5.0)), -0.8, 0.8);
        var sig = HPF.ar(folded, hpf.clip(20, 18000));
        sig = (MoogFF.ar(sig, lpf.clip(20, 18000), (1.0 - rq.clip(0.05, 1.0)) * 3.5) * 1.6).tanh;
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1.0 - mute), pan));
    }).add;

    // Zone 2: Lissajous FM (2-Op Harmonic Ratio FM)
    SynthDef(\lissajousFM, { |out=0, freq=220, amp=0.5, gate=1,
        vol=0.24, pan=(-0.35), mute=0.0, hpf=240, lpf=6500, rq=0.35,
        atk=0.008, dec=0.45, sus=0.40, rls=0.65, fxPhase=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var modEnv = EnvGen.kr(Env.perc(0.005, dec + 0.2), gate);
        var modIdx = (0.4 + (fxPhase * 6.5)) * modEnv;
        var mod = SinOsc.ar(freq * 2.0) * (freq * modIdx);
        var car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.5 + (mod * 0.5)) * 0.35);
        var sig = RLPF.ar(HPF.ar(car, hpf.clip(20, 18000)), lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1.0 - mute), pan));
    }).add;

    // Zone 3: Phosphor Trace (Detuned SuperSaw & Pulse Pad)
    SynthDef(\phosphorTrace, { |out=0, freq=220, amp=0.5, gate=1,
        vol=0.20, pan=0.35, mute=0.0, hpf=180, lpf=3800, rq=0.50,
        atk=0.35, dec=0.80, sus=0.70, rls=1.40, fxDrift=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var detune = 0.004 + (fxDrift * 0.018);
        var saws = Splay.ar(Saw.ar(freq * [1.0 - detune, 1.0 - (detune * 0.5), 1.0, 1.0 + (detune * 0.5), 1.0 + detune]));
        var sig = RLPF.ar(HPF.ar(saws, hpf.clip(20, 18000)), lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, env * amp * vol * (1.0 - mute)) } { Pan2.ar(sig, pan, env * amp * vol * (1.0 - mute)) });
    }).add;

    // Group FX: Stereo Delay & Phosphor Reverb
    SynthDef(\modularFX, { |inBus=0, outBus=0, delMix=0.0, delTime=0.32, delFb=0.35, verbMix=0.0, revTime=2.8|
        var dry = In.ar(inBus, 2);
        var del = CombL.ar(dry, 1.2, Lag.kr(delTime.clip(0.02, 1.0), 0.1), (delFb.clip(0.0, 0.9) * 4.0) + 0.1);
        var sig = (dry * (1.0 - (delMix * 0.5))) + (del * delMix);
        var verb = FreeVerb2.ar(sig[0], sig[1], 1.0, revTime.linlin(0.2, 8.0, 0.3, 0.96), 0.35);
        sig = (sig * (1.0 - verbMix)) + (verb * verbMix);
        Out.ar(outBus, sig);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, { |inBus=0|
        var sig = LeakDC.ar(In.ar(inBus, 2));
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \modularFX, [
        \inBus, ~fxBus, \outBus, ~masterBus,
        \delMix, ~buses.delMix.asMap, \delTime, ~buses.delTime.asMap, \delFb, ~buses.delFb.asMap,
        \verbMix, ~buses.verbMix.asMap, \revTime, ~buses.revTime.asMap
    ]);
    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\inBus, ~masterBus]);

    // MIDI NoteOn
    MIDIdef.noteOn(\modNoteOn, { |vel, noteNum|
        var amp = (vel / 127.0).linlin(0, 1, 0.15, 1.0);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(
                Synth(\pinMatrixSub, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxFold, ~buses.fxFold.asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth(\lissajousFM, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                    \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                    \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                    \fxPhase, ~buses.fxPhase.asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth(\phosphorTrace, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                    \fxDrift, ~buses.fxDrift.asMap
                ], ~synthGroup)
            );
        };
    }, srcID: ~myUid);

    // MIDI NoteOff
    MIDIdef.noteOff(\modNoteOff, { |vel, noteNum|
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            if(arr[noteNum].notNil) {
                arr[noteNum].do { |syn| syn.set(\gate, 0) };
                arr[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    // Loop-Driven MIDIdef.cc
    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // Panic CC
    MIDIdef.cc(\panicCC, { |val|
        if(val > 0) {
            [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                arr.do { |list, idx|
                    if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                };
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Paginated GUI
    defer {
        var screen = Window.availableBounds;
        var winW = 760;
        var winH = min(720, screen.height - 60);
        var zoneMeta = [
            (title: "Z1: Pin Matrix Sub", fxKey: \fxFold, fxLabel: "Pin Fold"),
            (title: "Z2: Lissajous FM", fxKey: \fxPhase, fxLabel: "Phase Mod"),
            (title: "Z3: Phosphor Trace", fxKey: \fxDrift, fxLabel: "Trace Drift")
        ];
        var pages = List.new;
        var tabBtns = List.new;
        var bgCol = Color(0.08, 0.11, 0.09);
        var panelCol = Color(0.12, 0.16, 0.13);
        var phosCol = Color(0.25, 0.95, 0.45);
        var textCol = Color(0.85, 0.95, 0.88);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~ui = ();
        ~mainWin = Window("Modular Pin Matrix & Lissajous Oscilloscope",
            Rect((screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH),
            scroll: true
        ).background_(bgCol).front;

        StaticText(~mainWin, Rect(15, 10, 500, 26))
            .string_("MODULAR PIN MATRIX // LISSAJOUS SYNTH")
            .font_(Font("Helvetica", 15, true))
            .stringColor_(phosCol);

        // Tab Buttons & Zone Pages
        zoneMeta.do { |zm, idx|
            var btn, page, zNum, kVol, kPan, kMute, kMin, kMax, kHpf, kLpf, kRq, kAtk, kDec, kSus, kRls, kFx;
            zNum = idx + 1;
            kVol = ("vol" ++ zNum).asSymbol; kPan = ("pan" ++ zNum).asSymbol; kMute = ("mute" ++ zNum).asSymbol;
            kMin = ("min" ++ zNum).asSymbol; kMax = ("max" ++ zNum).asSymbol;
            kHpf = ("hpf" ++ zNum).asSymbol; kLpf = ("lpf" ++ zNum).asSymbol; kRq = ("rq" ++ zNum).asSymbol;
            kAtk = ("atk" ++ zNum).asSymbol; kDec = ("dec" ++ zNum).asSymbol; kSus = ("sus" ++ zNum).asSymbol; kRls = ("rls" ++ zNum).asSymbol;
            kFx = zm[\fxKey];

            btn = Button(~mainWin, Rect(15 + (idx * 175), 42, 168, 28))
                .states_([[zm[\title], textCol, panelCol], [zm[\title], bgCol, phosCol]])
                .value_(if(idx == 0, 1, 0))
                .action_({
                    pages.do { |p, pIdx| p.visible = (pIdx == idx) };
                    tabBtns.do { |b, bIdx| b.value = if(bIdx == idx, 1, 0) };
                });
            tabBtns.add(btn);

            page = CompositeView(~mainWin, Rect(15, 78, winW - 30, 440))
                .background_(panelCol)
                .visible_(idx == 0);
            pages.add(page);

            ~ui[kMute] = Button(page, Rect(15, 14, 90, 26))
                .states_([["ACTIVE", bgCol, phosCol], ["MUTED", Color.white, Color(0.7, 0.2, 0.2)]])
                .value_(~ccVals[kMute])
                .action_({ |b| ~ccVals[kMute] = b.value; ~buses[kMute].set(b.value) });

            ~ui[kVol] = EZSlider(page, Rect(120, 14, 280, 24), "Vol (CC" ++ ~cc[kVol] ++ ")", ControlSpec(0, 1, \lin),
                { |ez| ~ccVals[kVol] = ez.value; ~buses[kVol].set(ez.value) }, ~ccVals[kVol], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kPan] = EZSlider(page, Rect(415, 14, 290, 24), "Pan (CC" ++ ~cc[kPan] ++ ")", ControlSpec(-1, 1, \lin),
                { |ez| ~ccVals[kPan] = ez.value; ~buses[kPan].set(ez.value) }, ~ccVals[kPan], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            EZRanger(page, Rect(15, 52, 690, 24), "Key Range", ControlSpec(0, 127, \lin, 1),
                { |ez|
                    ~ccVals[kMin] = ez.lo; ~buses[kMin].set(ez.lo);
                    ~ccVals[kMax] = ez.hi; ~buses[kMax].set(ez.hi);
                }, [~ccVals[kMin], ~ccVals[kMax]], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            // Filter & Unique FX Knobs
            [
                [kHpf, "HPF (CC" ++ ~cc[kHpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kLpf, "LPF (CC" ++ ~cc[kLpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kRq, "Res (CC" ++ ~cc[kRq] ++ ")", ControlSpec(1.0, 0.05, \exp)],
                [kFx, zm[\fxLabel] ++ " (CC" ++ ~cc[kFx] ++ ")", ControlSpec(0, 1, \lin)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 96, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };

            // ADSR Knobs
            [
                [kAtk, "Atk (CC" ++ ~cc[kAtk] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kDec, "Dec (CC" ++ ~cc[kDec] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kSus, "Sus (CC" ++ ~cc[kSus] ++ ")", ControlSpec(0, 1, \lin)],
                [kRls, "Rls (CC" ++ ~cc[kRls] ++ ")", ControlSpec(0.005, 5.0, \exp)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 235, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };
        };

        // Static Bottom Bar: Group FX & Panic
        CompositeView(~mainWin, Rect(15, 530, winW - 30, 135)).background_(panelCol);
        ~ui[\delMix] = EZSlider(~mainWin, Rect(30, 542, 330, 22), "Delay Mix (CC70)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delTime] = EZSlider(~mainWin, Rect(380, 542, 330, 22), "Delay Time (CC71)", ControlSpec(0.02, 1.0, \exp),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) }, ~ccVals[\delTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delFb] = EZSlider(~mainWin, Rect(30, 572, 330, 22), "Delay Fb (CC72)", ControlSpec(0, 0.9, \lin),
            { |ez| ~ccVals[\delFb] = ez.value; ~buses[\delFb].set(ez.value) }, ~ccVals[\delFb], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\verbMix] = EZSlider(~mainWin, Rect(380, 572, 330, 22), "Verb Mix (CC73)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\revTime] = EZSlider(~mainWin, Rect(30, 602, 330, 22), "Verb Time (CC74)", ControlSpec(0.2, 8.0, \exp),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) }, ~ccVals[\revTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

        Button(~mainWin, Rect(380, 604, 330, 32))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({
                [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                    arr.do { |list, idx|
                        if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                    };
                };
            });

        // 20fps AppClock Poller
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
// Step 0: MIDI CC Map
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 33, pan2: 34, mute2: 35, min2: 36, max2: 37, hpf2: 38, lpf2: 39, rq2: 40, atk2: 41, dec2: 42, sus2: 43, rls2: 44, fx2: 45,
    vol3: 46, pan3: 47, mute3: 48, min3: 49, max3: 50, hpf3: 51, lpf3: 52, rq3: 53, atk3: 54, dec3: 55, sus3: 56, rls3: 57, fx3: 58,
    delMix: 70, delTime: 71, delFb: 72, verbMix: 73, revTime: 74, panic: 120
);

// Step 1 & 2: MIDI Auto-Detection with Hardware Fallback
MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

// Step 3: Server Boot, Buses, SynthDefs, Routing, MIDI & GUI
s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 72, hpf1: 80, lpf1: 5200, rq1: 0.45, atk1: 0.005, dec1: 0.45, sus1: 0.15, rls1: 0.35, fx1: 0.0,
        vol2: 0.26, pan2: -0.35, mute2: 0.0, min2: 36, max2: 96, hpf2: 110, lpf2: 3200, rq2: 0.35, atk2: 0.015, dec2: 0.65, sus2: 0.35, rls2: 0.55, fx2: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 48, max3: 127, hpf3: 900, lpf3: 14000, rq3: 0.40, atk3: 0.005, dec3: 0.18, sus3: 0.05, rls3: 0.12, fx3: 0.0,
        delMix: 0.0, delTime: 0.28, delFb: 0.25, verbMix: 0.0, revTime: 1.8
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // Zone 1: Arame & Verga (Steel Wire & Biriba Bow)
    SynthDef(\berimbauWire, {
        |out=0, freq=146.83, amp=0.5, gate=1,
         vol=0.28, pan=0.0, mute=0.0, hpf=80, lpf=5200, rq=0.45,
         atk=0.005, dec=0.45, sus=0.15, rls=0.35, fx=0.0|
        var env, strike, string, dobrao, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        strike = BPF.ar(WhiteNoise.ar, (freq * 3.5).clip(200, 9000), 0.35)
            * EnvGen.ar(Env.perc(0.001, 0.018));
        string = CombL.ar(strike, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.6 + (sus * 2.0));
        string = string + (SinOsc.ar(freq) * 0.22 * EnvGen.ar(Env.perc(0.002, 0.35)));
        dobrao = AllpassC.ar(string, 0.02, (fx * 0.006) + 0.0004, 0.06);
        dobrao = dobrao * (1.0 + (SinOsc.ar(freq * 2.71) * fx * 0.65));
        sig = (string * (1.0 - fx)) + (dobrao * fx);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Cabaca Ressonadora (Gourd Resonator)
    SynthDef(\berimbauCabaca, {
        |out=0, freq=220, amp=0.5, gate=1,
         vol=0.26, pan=(-0.35), mute=0.0, hpf=110, lpf=3200, rq=0.35,
         atk=0.015, dec=0.65, sus=0.35, rls=0.55, fx=0.0|
        var env, exc, gourd, shift, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = (Saw.ar(freq * [0.997, 1.003]).sum * 0.35) + (SinOsc.ar(freq * 0.5) * 0.25);
        shift = 1.0 + (fx * 0.85);
        gourd = BPF.ar(exc, (freq * 1.5 * shift).clip(60, 8000), 0.22, 2.2)
            + BPF.ar(exc, (freq * 2.8 * shift).clip(80, 10000), 0.18, 1.5);
        sig = (exc * 0.35 * (1.0 - (fx * 0.5))) + (gourd * 0.85);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 3: Caxixi & Baqueta (Wicker Rattle & Stick)
    SynthDef(\berimbauCaxixi, {
        |out=0, freq=880, amp=0.5, gate=1,
         vol=0.20, pan=0.35, mute=0.0, hpf=900, lpf=14000, rq=0.40,
         atk=0.005, dec=0.18, sus=0.05, rls=0.12, fx=0.0|
        var env, seeds, stick, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        seeds = PinkNoise.ar * (0.6 + (Dust2.ar(35 + (fx * 180)) * 0.6));
        seeds = BPF.ar(seeds, (freq * 2.5).clip(600, 12000), 0.25, 2.4);
        stick = BPF.ar(WhiteNoise.ar, (freq * 1.8).clip(400, 9000), 0.15, 1.5)
            * EnvGen.ar(Env.perc(0.001, 0.025));
        sig = seeds + stick;
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Group FX: Stereo Delay & Reverb
    SynthDef(\groupFX, {
        |in=0, out=0, delMix=0.0, delTime=0.28, delFb=0.25, verbMix=0.0, revTime=1.8|
        var dry, del, verb, sig;
        dry = In.ar(in, 2);
        del = CombL.ar(dry, 1.2, delTime.clip(0.02, 1.0), (delFb.clip(0.0, 0.9) * 4.0) + 0.05);
        sig = (dry * (1.0 - (delMix * 0.5))) + (del * delMix);
        verb = FreeVerb2.ar(sig[0], sig[1], 1.0, revTime.linlin(0.2, 8.0, 0.2, 0.95), 0.4);
        sig = (sig * (1.0 - (verbMix * 0.5))) + (verb * verbMix);
        Out.ar(out, sig);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, {
        |in=0, out=0|
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \groupFX, [
        \in, ~fxBus, \out, ~masterBus,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap,
        \delFb, ~buses[\delFb].asMap, \verbMix, ~buses[\verbMix].asMap,
        \revTime, ~buses[\revTime].asMap
    ]);

    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\in, ~masterBus, \out, 0]);

    // MIDI NoteOn
    MIDIdef.noteOn(\berimbauOn, { |vel, noteNum|
        var amp = (vel / 127.0).linexp(0.01, 1.0, 0.12, 1.0);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(
                Synth(\berimbauWire, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap,
                    \rls, ~buses[\rls1].asMap, \fx, ~buses[\fx1].asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth(\berimbauCabaca, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap,
                    \rls, ~buses[\rls2].asMap, \fx, ~buses[\fx2].asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth(\berimbauCaxixi, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap,
                    \rls, ~buses[\rls3].asMap, \fx, ~buses[\fx3].asMap
                ], ~synthGroup)
            );
        };
    }, srcID: ~myUid);

    // MIDI NoteOff
    MIDIdef.noteOff(\berimbauOff, { |vel, noteNum|
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            if(arr[noteNum].notNil) {
                arr[noteNum].do(_.set(\gate, 0));
                arr[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    // Loop-Driven MIDI CC
    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // MIDI Panic CC
    MIDIdef.cc(\panicCC, {
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            arr.do { |list, idx|
                if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Paginated GUI
    defer {
        var screen = Window.availableBounds;
        var winW = 760;
        var winH = min(680, screen.height - 60);
        var bgCol = Color(0.11, 0.09, 0.07);
        var panelCol = Color(0.18, 0.14, 0.10);
        var textCol = Color(0.95, 0.88, 0.72);
        var phosCol = Color(0.95, 0.65, 0.22);
        var tabBtns = Array.newClear(3);
        var pages = Array.newClear(3);
        var zoneMeta = [
            (title: "1. Arame & Verga", fxLabel: "Dobrao Buzz"),
            (title: "2. Cabaca", fxLabel: "Abertura Barriga"),
            (title: "3. Caxixi & Baqueta", fxLabel: "Grao Seco")
        ];

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~ui = ();
        ~mainWin = Window("Berimbau de Barriga - Afro-Brazilian Capoeira Synth",
            Rect((screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH),
            scroll: true).background_(bgCol).front;

        StaticText(~mainWin, Rect(15, 10, winW - 30, 26))
            .string_("BERIMBAU DE BARRIGA // BIRIBA, ARAME, CABACA & CAXIXI")
            .stringColor_(phosCol).font_(Font("Helvetica", 15, true));

        // Tab Buttons
        zoneMeta.do { |zm, idx|
            tabBtns[idx] = Button(~mainWin, Rect(15 + (idx * 245), 42, 235, 30))
                .states_([
                    [zm[\title], textCol, panelCol],
                    [zm[\title], bgCol, phosCol]
                ])
                .value_(if(idx == 0, 1, 0))
                .action_({
                    pages.do { |pg, pIdx|
                        pg.visible_(pIdx == idx);
                        tabBtns[pIdx].value_(if(pIdx == idx, 1, 0));
                    };
                });
        };

        // Zone Pages
        zoneMeta.do { |zm, idx|
            var z = (idx + 1).asString;
            var kVol = ("vol" ++ z).asSymbol, kPan = ("pan" ++ z).asSymbol, kMute = ("mute" ++ z).asSymbol;
            var kMin = ("min" ++ z).asSymbol, kMax = ("max" ++ z).asSymbol;
            var kHpf = ("hpf" ++ z).asSymbol, kLpf = ("lpf" ++ z).asSymbol, kRq = ("rq" ++ z).asSymbol;
            var kAtk = ("atk" ++ z).asSymbol, kDec = ("dec" ++ z).asSymbol, kSus = ("sus" ++ z).asSymbol, kRls = ("rls" ++ z).asSymbol;
            var kFx = ("fx" ++ z).asSymbol;
            var page = CompositeView(~mainWin, Rect(15, 80, winW - 30, 440))
                .background_(panelCol).visible_(idx == 0);
            pages[idx] = page;

            ~ui[kVol] = EZSlider(page, Rect(15, 12, 280, 22), "Vol (CC" ++ ~cc[kVol] ++ ")", ControlSpec(0, 1, \lin),
                { |ez| ~ccVals[kVol] = ez.value; ~buses[kVol].set(ez.value) }, ~ccVals[kVol], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kPan] = EZSlider(page, Rect(310, 12, 280, 22), "Pan (CC" ++ ~cc[kPan] ++ ")", ControlSpec(-1, 1, \lin),
                { |ez| ~ccVals[kPan] = ez.value; ~buses[kPan].set(ez.value) }, ~ccVals[kPan], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kMute] = Button(page, Rect(605, 12, 110, 24))
                .states_([["ACTIVE", textCol, Color(0.2, 0.45, 0.2)], ["MUTED", Color.white, Color(0.7, 0.15, 0.15)]])
                .value_(~ccVals[kMute])
                .action_({ |b| ~ccVals[kMute] = b.value; ~buses[kMute].set(b.value) });

            ~ui[kMin] = EZSlider(page, Rect(15, 44, 340, 22), "Min Note (CC" ++ ~cc[kMin] ++ ")", ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMin] = ez.value; ~buses[kMin].set(ez.value) }, ~ccVals[kMin], labelWidth: 115)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kMax] = EZSlider(page, Rect(375, 44, 340, 22), "Max Note (CC" ++ ~cc[kMax] ++ ")", ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMax] = ez.value; ~buses[kMax].set(ez.value) }, ~ccVals[kMax], labelWidth: 115)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            // Filter & Character FX Knobs
            [
                [kHpf, "HPF (CC" ++ ~cc[kHpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kLpf, "LPF (CC" ++ ~cc[kLpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kRq, "Res (CC" ++ ~cc[kRq] ++ ")", ControlSpec(1.0, 0.05, \exp)],
                [kFx, zm[\fxLabel] ++ " (CC" ++ ~cc[kFx] ++ ")", ControlSpec(0, 1, \lin)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 96, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };

            // ADSR Knobs
            [
                [kAtk, "Atk (CC" ++ ~cc[kAtk] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kDec, "Dec (CC" ++ ~cc[kDec] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kSus, "Sus (CC" ++ ~cc[kSus] ++ ")", ControlSpec(0, 1, \lin)],
                [kRls, "Rls (CC" ++ ~cc[kRls] ++ ")", ControlSpec(0.005, 5.0, \exp)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 235, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };
        };

        // Static Bottom Bar: Group FX & Panic
        CompositeView(~mainWin, Rect(15, 530, winW - 30, 135)).background_(panelCol);
        ~ui[\delMix] = EZSlider(~mainWin, Rect(30, 542, 330, 22), "Delay Mix (CC70)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delTime] = EZSlider(~mainWin, Rect(380, 542, 330, 22), "Delay Time (CC71)", ControlSpec(0.02, 1.0, \exp),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) }, ~ccVals[\delTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delFb] = EZSlider(~mainWin, Rect(30, 572, 330, 22), "Delay Fb (CC72)", ControlSpec(0, 0.9, \lin),
            { |ez| ~ccVals[\delFb] = ez.value; ~buses[\delFb].set(ez.value) }, ~ccVals[\delFb], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\verbMix] = EZSlider(~mainWin, Rect(380, 572, 330, 22), "Verb Mix (CC73)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\revTime] = EZSlider(~mainWin, Rect(30, 602, 330, 22), "Verb Time (CC74)", ControlSpec(0.2, 8.0, \exp),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) }, ~ccVals[\revTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

        Button(~mainWin, Rect(380, 604, 330, 32))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({
                [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                    arr.do { |list, idx|
                        if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                    };
                };
            });

        // 20fps AppClock Poller
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
// 1. Caixa & Zabumba (Cadenced Processional Drum)
Ndef(\congadaCaixa).fadeTime = 2;
Ndef(\congadaCaixa, {
    |freq=110, tone=380, snare=0.45, amp=0.26, pan=(-0.15), t_trig=1|
    var env, body, rattle, sig, trigA;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.002, 0.22, 1, -6), t_trig);
    body = SinOsc.ar(freq * (1 + (2.5 * EnvGen.ar(Env.perc(0.001, 0.035, 1, -8), t_trig)))) * env;
    rattle = BPF.ar(WhiteNoise.ar, tone * 4.5, 0.35) * Decay2.ar(trigA, 0.002, 0.14) * snare * 2.5;
    sig = (body + rattle).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaCaixa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.45, 0.5);
};
Ndef(\congadaCaixa).set(\wet10, 0.22);

Pbindef(\caixaSeq,
    \dur, Pwrand([0.25, 0.5, 0.125], [0.65, 0.25, 0.1], inf),
    \freq, Pseq([95, 115, 95, 130, 95, 110, 140, 95], inf),
    \tone, Pwhite(320, 480, inf),
    \snare, Pseq([0.2, 0.55, 0.25, 0.65, 0.2, 0.5, 0.7, 0.3], inf),
    \amp, Pseq([0.26, 0.16, 0.22, 0.25, 0.24, 0.15, 0.28, 0.18], inf),
    \t_trig, 1
);
Ndef(\congadaCaixa).quant = 1;
Ndef(\congadaCaixa)[1] = \set -> Pbindef(\caixaSeq);

// 2. Gungas de Lata (Metallic Ankle Shakers & Bell-Tin Percussions)
Ndef(\gungasLata).fadeTime = 2;
Ndef(\gungasLata, {
    |freq=1450, decay=0.14, grit=0.6, amp=0.18, pan=0.25, t_trig=1|
    var trigA, exc, modes, sig, rattle;
    trigA = K2A.ar(t_trig);
    exc = (Impulse.ar(0) + (WhiteNoise.ar * Decay2.ar(trigA, 0.001, 0.03))) * 0.6;
    modes = DynKlank.ar(
        Ref([
            [1.0, 1.53, 2.17, 2.94, 3.81] * freq,
            [0.35, 0.28, 0.22, 0.15, 0.1],
            [0.8, 0.6, 0.5, 0.35, 0.25]
        ]),
        exc,
        decayscale: decay
    );
    rattle = HPF.ar(WhiteNoise.ar, 4200) * Decay2.ar(trigA, 0.002, decay * 0.7) * grit * 0.4;
    sig = (modes + rattle).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    var dly;
    dly = CombL.ar(in, 0.5, [0.18, 0.24], 1.4);
    FreeVerb2.ar(dly[0], dly[1], 1.0, 0.55, 0.35);
};
Ndef(\gungasLata).set(\wet10, 0.28);

Pbindef(\gungasSeq,
    \dur, Pwrand([0.125, 0.25, Rest(0.125)], [0.55, 0.3, 0.15], inf),
    \freq, Pexprand(1180, 1850, inf),
    \decay, Pwhite(0.08, 0.19, inf),
    \grit, Pwhite(0.4, 0.85, inf),
    \pan, Pwhite(-0.45, 0.55, inf),
    \amp, Pwhite(0.12, 0.2, inf),
    \t_trig, 1
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\gungasSeq);

// 3. Canto do Rosário (Syncretic Vocal Formant & Harmonium Drone)
Ndef(\cantoRosario).fadeTime = 4;
Ndef(\cantoRosario, {
    |freq=196, vowel=0.5, cutoff=1400, amp=0.14, pan=(-0.05), t_trig=1|
    var env, osc, formF, vA, vO, vU, body, sig;
    env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.18, 0.6, 0.9]), t_trig);
    osc = Splay.ar(Saw.ar(freq * [0.995, 1.0, 1.005, 2.0])).sum * 0.35;
    vA = [730, 1090, 2440];
    vO = [570, 840, 2410];
    vU = [300, 870, 2240];
    formF = SelectX.kr(vowel.clip(0, 2), [vA, vO, vU]);
    body = BPF.ar(osc, formF, 0.14).sum * 5.0;
    sig = LPF.ar(body + (osc * 0.25), cutoff) * env;
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 65, 3.8, 0.45, 0.5, 15, 0.0, 0.6, 0.5);
};
Ndef(\cantoRosario).set(\wet10, 0.38);

Pbindef(\cantoSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 2.0], inf),
    \freq, Pseq([196, 220, 246.94, 196, 174.61, 196], inf),
    \vowel, Pwhite(0.0, 2.0, inf),
    \cutoff, Pexprand(1100, 2200, inf),
    \amp, 0.14,
    \t_trig, 1
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\cantoSeq);
)

// Ndef(\gungasLata).xset(\freq, 2200); // Brighten ankle tins | Revert: Ndef(\gungasLata).xset(\freq, 1450);
// Pbindef(\caixaSeq, \dur, 0.125); // Double-time march | Revert: Pbindef(\caixaSeq, \dur, Pwrand([0.25, 0.5, 0.125], [0.65, 0.25, 0.1], inf));
// Pbindef(\cantoSeq, \freq, Pseq([293.66, 329.63, 392.0, 293.66], inf)); // Lift chant octave | Revert: Pbindef(\cantoSeq, \freq, Pseq([196, 220, 246.94, 196, 174.61, 196], inf));
// Pbindef(\caixaSeq).stop; Ndef(\congadaCaixa).fadeTime = 4; Ndef(\congadaCaixa).clear(4); // Rollback Caixa
// Pbindef(\gungasSeq).stop; Ndef(\gungasLata).fadeTime = 4; Ndef(\gungasLata).clear(4); // Rollback Gungas
// Pbindef(\cantoSeq).stop; Ndef(\cantoRosario).fadeTime = 4; Ndef(\cantoRosario).clear(4); // Rollback Canto


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: PASS
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// 1. Corixo Espelho (Calm Twilight Water Reflection & Sub-Harmonic Glow)
Ndef(\corixoEspelho).fadeTime = 4;
Ndef(\corixoEspelho, {
    |freq=73.42, cutoff=420, shimmer=0.35, amp=0.18, pan=0.0, t_trig=1|
    var env, sub, pad, water, lfo, sig;
    env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.8, 2.2, 2.5]), t_trig);
    lfo = SinOsc.kr(0.14).range(0.75, 1.35);
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.0) * 0.45);
    pad = Splay.ar(Saw.ar(freq * [1.0, 1.498, 2.003, 2.995])).sum * 0.22;
    pad = MoogFF.ar(pad, (cutoff * lfo).clip(120, 4500), 1.8) * 2.2;
    water = BPF.ar(PinkNoise.ar, SinOsc.kr(0.23).range(340, 920), 0.12) * 12.0 * shimmer;
    sig = (sub * 0.45) + pad + water;
    Pan2.ar((sig * env).tanh, pan, amp);
}).play;

Ndef(\corixoEspelho)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 75, 4.8, 0.4, 0.5, 15, 0.0, 0.55, 0.45);
};
Ndef(\corixoEspelho).set(\wet10, 0.42);

Pbindef(\corixoSeq,
    \dur, Pseq([4.0, 4.0, 6.0], inf),
    \freq, Pseq([73.42, 82.41, 65.41, 73.42], inf),
    \cutoff, Pexprand(360, 780, inf),
    \shimmer, Pwhite(0.25, 0.48, inf),
    \amp, 0.18,
    \t_trig, 1
);
Ndef(\corixoEspelho).quant = 1;
Ndef(\corixoEspelho)[1] = \set -> Pbindef(\corixoSeq);

// 2. Araras-Azuis & Bater de Asas (Wingbeats & Twilight Flock Calls)
Ndef(\ararasAsas).fadeTime = 2;
Ndef(\ararasAsas, {
    |freq=680, modRatio=1.62, wingRate=7.5, amp=0.14, pan=0.0, t_trig=1|
    var trigA, wingEnv, callEnv, wing, mod, call, sig;
    trigA = K2A.ar(t_trig);
    wingEnv = Decay2.ar(trigA, 0.015, 0.22);
    callEnv = EnvGen.ar(Env.perc(0.01, 0.26, 1, -5), t_trig);
    wing = BPF.ar(WhiteNoise.ar, TRand.kr(420, 980, t_trig), 0.28) * 10.0;
    wing = wing * SinOsc.ar(wingRate).range(0.2, 1.0) * wingEnv;
    mod = SinOsc.ar(freq * modRatio) * (freq * 2.4 * callEnv);
    call = BPF.ar(Saw.ar(freq + mod), [1150, 2100, 3200], 0.16).sum * 3.5 * callEnv;
    sig = (wing * 0.55) + (call * 0.45);
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Ndef(\ararasAsas)[10] = \filter -> { |in|
    var dly;
    dly = CombL.ar(in, 0.6, [0.22, 0.31], 1.6);
    FreeVerb2.ar(dly[0], dly[1], 1.0, 0.65, 0.4);
};
Ndef(\ararasAsas).set(\wet10, 0.34);

Pbindef(\ararasSeq,
    \dur, Pwrand([0.125, 0.25, 0.375, Rest(0.5)], [0.45, 0.3, 0.1, 0.15], inf),
    \freq, Pexprand(520, 940, inf),
    \modRatio, Pwhite(1.45, 1.85, inf),
    \wingRate, Pwhite(6.0, 9.5, inf),
    \pan, Pn(Pgeom(0.15, 1.18, 8), inf) * Pseq([-1, 1], inf),
    \amp, Pwhite(0.09, 0.16, inf),
    \t_trig, 1
);
Ndef(\ararasAsas).quant = 1;
Ndef(\ararasAsas)[1] = \set -> Pbindef(\ararasSeq);

// 3. Piúva & Tuiuiús (Dry Branches & Silent Twilight Watchers)
Ndef(\piuvaTuiuiu).fadeTime = 3;
Ndef(\piuvaTuiuiu, {
    |freq=320, decay=0.45, amp=0.14, pan=(-0.25), t_trig=1|
    var trigA, exc, modes, sig;
    trigA = K2A.ar(t_trig);
    exc = (Impulse.ar(0) + (PinkNoise.ar * Decay2.ar(trigA, 0.002, 0.025))) * 0.5;
    modes = DynKlank.ar(
        Ref([
            [1.0, 2.38, 3.91, 5.42] * freq,
            [0.45, 0.3, 0.18, 0.1],
            [1.2, 0.85, 0.5, 0.3]
        ]),
        exc,
        decayscale: decay
    );
    sig = LPF.ar(modes, 3200).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\piuvaTuiuiu)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.45);
};
Ndef(\piuvaTuiuiu).set(\wet10, 0.32);

Pbindef(\piuvaSeq,
    \dur, Pwrand([0.75, 1.5, 2.25, Rest(1.5)], [0.35, 0.3, 0.15, 0.2], inf),
    \freq, Pseq([293.66, 329.63, 440.0, 392.0, 261.63], inf),
    \decay, Pwhite(0.35, 0.65, inf),
    \pan, Pwhite(-0.65, 0.45, inf),
    \amp, Pwhite(0.1, 0.16, inf),
    \t_trig, 1
);
Ndef(\piuvaTuiuiu).quant = 1;
Ndef(\piuvaTuiuiu)[1] = \set -> Pbindef(\piuvaSeq);
)

// Ndef(\corixoEspelho).xset(\cutoff, 950); // Brighten orange water glow | Revert: Ndef(\corixoEspelho).xset(\cutoff, 420);
// Pbindef(\ararasSeq, \dur, 0.125); // Dense flock flight | Revert: Pbindef(\ararasSeq, \dur, Pwrand([0.125, 0.25, 0.375, Rest(0.5)], [0.45, 0.3, 0.1, 0.15], inf));
// Pbindef(\corixoSeq).stop; Ndef(\corixoEspelho).fadeTime = 4; Ndef(\corixoEspelho).clear(4); // Rollback Corixo
// Pbindef(\ararasSeq).stop; Ndef(\ararasAsas).fadeTime = 4; Ndef(\ararasAsas).clear(4); // Rollback Araras
// Pbindef(\piuvaSeq).stop; Ndef(\piuvaTuiuiu).fadeTime = 4; Ndef(\piuvaTuiuiu).clear(4); // Rollback Piúva

