// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Carbon
// Model ID: openrouter:google/gemini-4-carbon
// Date: 2026-11-13T13:03:49.043830+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// 1. A tempestade antártica no silêncio (Heavy, glacial sub-bass & frozen atmospheric tension)
Ndef(\antarcticSilence).fadeTime = 4;
Ndef(\antarcticSilence, { |freq=43.65, amp=0.35, windCutoff=320, tension=0.25, pan=0|
    var sub, cluster, wind, sig;
    // Sub-bass com oitava para garantir peso físico na sala
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    // Dissonância contida de 27 anos (batimentos microtonais lentos)
    cluster = Splay.ar(
        SinOscFB.ar(
            freq * [2.0, 2.012, 2.995, 4.03, 5.98],
            LFNoise2.kr(0.08 ! 5).range(0.1, tension + 0.3)
        )
    ) * 0.25;
    // Vento polar suspenso (BPF estreito com compensação de ganho)
    wind = Splay.ar(
        BPF.ar(
            PinkNoise.ar(1 ! 2),
            LFNoise2.kr([0.05, 0.07]).exprange(windCutoff * 0.6, windCutoff * 1.8),
            0.03
        ) * 12.0
    ) * 0.25;
    sig = (sub ! 2 * 0.5) + cluster + wind;
    sig = LeakDC.ar((sig * (1.0 + tension)).tanh);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\antarcticSeq,
    \dur, Pseq([8, 12, 7], inf), // Ciclo assimétrico de 27 tempos
    \freq, Pseq([43.65, 41.20, 38.89], inf), // Descida tectônica: F1 -> E1 -> Eb1
    \tension, Pseq([0.2, 0.45, 0.75], inf),
    \windCutoff, Pseq([280, 420, 680], inf),
    \amp, 0.35
);
Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSeq);

// 2. A garrafa de vinho suspensa no ar (Frozen crystal resonance of the immobilized waiter)
Ndef(\suspendedGlass).fadeTime = 5;
Ndef(\suspendedGlass, { |freq=1046.5, amp=0.14, shimmer=0.3, pan=0.25|
    var exciter, modes, sig;
    // Excitação contínua e quase imperceptível no vidro imóvel
    exciter = BPF.ar(WhiteNoise.ar(0.06), freq, 0.02) * 10.0;
    modes = DynKlank.ar(
        `[
            [1, 2.003, 2.98, 4.05, 5.42],
            [0.5, 0.3, 0.15, 0.1, 0.05],
            [4.5, 3.8, 2.5, 2.0, 1.2]
        ],
        exciter,
        freqscale: freq * LFNoise2.kr(0.12).range(0.998, 1.002),
        decayscale: shimmer.linlin(0, 1, 0.8, 2.5)
    );
    sig = Splay.ar([modes, DelayC.ar(modes, 0.05, SinOsc.kr(0.15).range(0.008, 0.022))]);
    sig = HPF.ar(sig, 400);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\glassSeq,
    \dur, Pseq([6.5, 9.5, 11.0], inf),
    \midinote, Pseq([84, 83, 86, 80], inf), // C6, B5, D6, Ab5 - harmonia suspensa no ar
    \shimmer, Pwhite(0.4, 0.85, inf),
    \pan, Pseq([0.25, 0.35, 0.15], inf),
    \amp, 0.13
);
Ndef(\suspendedGlass)[1] = \set -> Pbindef(\glassSeq);

// 3. A explicação metódica do mapa rodoviário (Dry, crisp paper-folding & pedantic geometric clicks)
Ndef(\mapFolding).fadeTime = 2;
Ndef(\mapFolding, { |freq=620, amp=0.22, foldness=1.8, crisp=2800, rel=0.09, pan=(-0.3), t_trig=0|
    var trigA, clickEnv, foldEnv, paper, crease, sig;
    trigA = K2A.ar(t_trig);
    clickEnv = Decay2.ar(trigA, 0.001, 0.018);
    foldEnv = EnvGen.ar(Env.perc(0.003, rel, 1, -6), t_trig);
    // Fricção seca do papel sendo vincado com precisão irritante
    paper = BPF.ar(WhiteNoise.ar(1), crisp, 0.25) * 4.5 * foldEnv;
    // Geometria pedante da explicação (Buchla-style wavefolding)
    crease = Fold.ar(SinOsc.ar(freq + (clickEnv * freq * 1.5)) * foldness, -0.7, 0.7) * clickEnv;
    sig = HPF.ar(paper + (crease * 0.65), 220);
    Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\mapSeq,
    // Ritmo meticuloso pontuado por pausas tensas sobre a mesa
    \dur, Pseq([0.35, 0.35, 0.7, 2.6, 0.25, 0.25, 0.25, 0.5, 3.75], inf),
    \t_trig, 1,
    \freq, Pseq([580, 640, 720, 520, 810, 810, 640, 490, 550], inf),
    \crisp, Pseq([2400, 3100, 1900, 3800, 2700], inf),
    \foldness, Pseq([1.4, 2.1, 2.8, 1.6, 3.2], inf),
    \rel, Pseq([0.06, 0.08, 0.16, 0.05, 0.04, 0.04, 0.09, 0.22, 0.1], inf),
    \pan, Pseq([-0.35, -0.2, -0.4, -0.25, -0.15], inf),
    \amp, Pseq([0.2, 0.18, 0.25, 0.12, 0.22, 0.22, 0.24, 0.26, 0.1], inf)
);
Ndef(\mapFolding)[1] = \set -> Pbindef(\mapSeq);

// Efeito de espaço gélido no restaurante silencioso (inicializado sutilmente para a tensão)
Ndef(\mapFolding)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.25);
};
Ndef(\mapFolding).set(\wet10, 0.22);

// Pbindef(\antarcticSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove antarcticSilence
// Pbindef(\glassSeq).stop; Ndef(\suspendedGlass).fadeTime = 2; Ndef(\suspendedGlass).clear(2); // Rollback: remove suspendedGlass
// Pbindef(\mapSeq).stop; Ndef(\mapFolding).fadeTime = 2; Ndef(\mapFolding).clear(2); // Rollback: remove mapFolding
// Ndef(\mapFolding).set(\wet10, 0); // Rollback: disable mapFolding reverb
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 1. Discrete Brass Escapement (Pocket watches & crisp anchor ticks)
    SynthDef(\brassEscapement, { |out=0, freq=2800, spring=5400, amp=0.14, pan=0, rel=0.035|
        var env, tick, escapement, hairspring, sig;
        env = EnvGen.ar(Env.perc(0.0005, rel.clip(0.01, 0.35), 1, -7), doneAction: 2);
        tick = HPF.ar(WhiteNoise.ar(0.8), 1800) * EnvGen.ar(Env.perc(0.0002, 0.006));
        escapement = Ringz.ar(tick, [freq, freq * 1.47, spring], [0.015, 0.011, 0.024]).sum * 0.22;
        hairspring = SinOsc.ar(freq * 0.5 + (SinOsc.ar(freq * 2.31) * freq * 1.6 * env)) * env * 0.35;
        sig = HPF.ar((escapement + hairspring) * env, 450);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // 2. French Carillon Bell (Inharmonic bronze partials)
    SynthDef(\carillonChime, { |out=0, freq=523.25, amp=0.18, pan=0, decay=3.2, strike=0.5|
        var env, mallet, bell, sig;
        env = EnvGen.ar(Env.perc(0.002, decay.max(0.2), 1, -4), doneAction: 2);
        mallet = Impulse.ar(0) + (BPF.ar(PinkNoise.ar(strike), freq * 3.2, 0.25) * 4.0 * EnvGen.ar(Env.perc(0.0008, 0.014)));
        bell = DynKlank.ar(
            Ref([
                [1.0, 2.002, 2.41, 2.996, 4.13, 5.47],
                [0.45, 0.32, 0.24, 0.16, 0.1, 0.06],
                [1.0, 0.85, 0.65, 0.55, 0.35, 0.2]
            ]),
            mallet,
            freqscale: freq,
            decayscale: decay
        ) * 0.18;
        sig = LeakDC.ar(bell * env);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // 3. Heavy Wooden Wall Pendulum (Low cabinet thud + metal latch)
    SynthDef(\woodenPendulum, { |out=0, freq=92, wood=340, amp=0.22, pan=0, dur=0.22|
        var env, body, click, sig;
        env = EnvGen.ar(Env.perc(0.002, dur.max(0.06), 1, -5), doneAction: 2);
        click = BPF.ar(WhiteNoise.ar(1), wood * 3.1, 0.18) * 5.0 * EnvGen.ar(Env.perc(0.0005, 0.012));
        body = Ringz.ar(Impulse.ar(0) + (click * 0.25), [freq, freq * 2.0, wood, wood * 1.58], [0.14, 0.09, 0.06, 0.035]).sum * 0.16;
        sig = LPF.ar((body + (click * 0.4)).tanh, 3600) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // Continuous 1: 200 Out-of-Phase Clocks Swarm (Micro-drifting escapements)
    Ndef(\clockSwarm).fadeTime = 3.0;
    Ndef(\clockSwarm, { |amp=0.0, density=8.0, spread=0.85, brassCut=3600, drift=0.12|
        var voices;
        voices = 12.collect({ |i|
            var rate, trig, fBase, ping;
            rate = (density * (0.72 + (i * 0.051))) + LFNoise2.kr(0.18 + (i * 0.02), drift * 2.5);
            trig = Impulse.ar(rate.clip(0.5, 48.0), (i * 0.137) % 1.0);
            fBase = 1500 + (i * 290) + LFNoise1.kr(0.25, 65);
            ping = Ringz.ar(trig, [fBase, fBase * 1.62], [0.009, 0.005]).sum * 0.12;
            BPF.ar(ping, brassCut.clip(600, 9500), 0.45) * 2.2;
        });
        Splay.ar(voices, spread, amp);
    });

    // Continuous 2: The Breathing of Time (Acoustic beating & bellows sigh between gears)
    Ndef(\timeBreath).fadeTime = 4.0;
    Ndef(\timeBreath, { |amp=0.0, root=130.81, beatRate=0.22, air=0.35, warmth=1100|
        var lfo, gears, breathNoise, sig;
        lfo = SinOsc.kr(beatRate, [0, 0.6]).range(0.18, 1.0);
        gears = Splay.ar(
            [1.0, 1.004, 1.498, 1.503, 2.006, 2.994].collect({ |ratio, i|
                var f = root * ratio;
                SinOsc.ar(f + (SinOsc.ar(f * 2.0) * f * 0.25 * lfo[i % 2])) * (0.28 / (i + 1))
            }),
            0.75
        );
        breathNoise = [0.99, 1.01].collect({ |m, ch|
            BPF.ar(PinkNoise.ar(air), (warmth * m * lfo[ch]).clip(180, 4800), 0.08) * 7.5
        });
        sig = LPF.ar((gears + (breathNoise * 0.35)) * lfo, warmth.clip(250, 5200));
        if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp) } { Pan2.ar(sig, 0, amp) };
    });

    // Master Bus & Workshop Acoustics (Narrow Santa Efigênia shop with wooden shelves)
    Ndef(\masterMix).fadeTime = 1.0;
    Ndef(\masterMix, {
        var discrete = In.ar(~synthBus, 2);
        var swarm = Ndef.ar(\clockSwarm, 2);
        var breath = Ndef.ar(\timeBreath, 2);
        discrete + swarm + breath;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        var pre = CombL.ar(in, 0.08, [0.029, 0.043], 0.28);
        FreeVerb2.ar(pre[0], pre[1], 1.0, 0.68, 0.42);
    };
    Ndef(\masterMix).set(\wet10, 0.18);
    Ndef(\masterMix).play;
    s.sync;

    // Chronological Score (~1m48s)
    Tdef(\masterScore, {
        0.5.wait;

        // Smoothly crossfade out previous scene elements to spotlight the clock shop
        Pbindef(\antarcticSeq).stop;
        Pbindef(\glassSeq).stop;
        Pbindef(\mapSeq).stop;
        Ndef(\antarcticSilence).fadeTime = 4.0; Ndef(\antarcticSilence).clear(4.0);
        Ndef(\suspendedGlass).fadeTime = 4.0; Ndef(\suspendedGlass).clear(4.0);
        Ndef(\mapFolding).fadeTime = 3.0; Ndef(\mapFolding).clear(3.0);

        "0:00 - [Cue 1: A Oficina Estreita — Solitary Pendulums & Pocket Chronometers]".postln;
        Pbindef(\pendulumPulse,
            \instrument, \woodenPendulum,
            \out, ~synthBus,
            \dur, Pseq([1.0, 1.02, 0.98, 1.01], inf),
            \freq, Pseq([87.31, 92.5, 87.31, 98.0], inf),
            \wood, Pseq([310, 395, 325, 420], inf),
            \pan, Pseq([-0.55, 0.55, -0.45, 0.45], inf),
            \amp, 0.20
        ).play;
        3.0.wait;

        // Staggered pocket chronometer enters at irrational phase ratio
        Pbindef(\pocketWatchA,
            \instrument, \brassEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.213, 0.217, 0.211, 0.215], inf),
            \freq, Pseq([3100, 3480, 3050, 3520], inf),
            \spring, Pexprand(4800, 6800, inf),
            \rel, 0.028,
            \pan, Pwhite(-0.75, -0.25, inf),
            \amp, 0.12
        ).play;
        4.0.wait;

        Pbindef(\pocketWatchB,
            \instrument, \brassEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.168, 0.172, 0.169], inf),
            \freq, Pseq([4120, 3890, 4260], inf),
            \spring, Pexprand(5600, 7900, inf),
            \rel, 0.022,
            \pan, Pwhite(0.25, 0.8, inf),
            \amp, 0.11
        ).play;
        5.0.wait;

        "0:12 - [Cue 2: Enxame de Duzentos Relógios — Phase Multiplication]".postln;
        Ndef(\clockSwarm).xset(\amp, 0.16, \density, 5.5, \brassCut, 3200, \drift, 0.18);
        4.do { |i|
            Ndef(\clockSwarm).xset(
                \density, 6.5 + (i * 2.8),
                \brassCut, 3400 + (i * 650),
                \amp, 0.18 + (i * 0.03)
            );
            4.5.wait;
        };

        "0:30 - [Cue 3: Carrilhões Franceses Desencontrados — Staggered Hour Chimes]".postln;
        Ndef(\masterMix).set(\wet10, 0.28);
        // Westminster-inspired French quarter-chime fragments drifting out of alignment
        Pbindef(\frenchCarillon,
            \instrument, \carillonChime,
            \out, ~synthBus,
            \dur, Pseq([0.62, 0.64, 0.61, 1.35, 0.58, 0.63, 0.60, 1.85], inf),
            \midinote, Pseq([76, 74, 72, 67, 72, 74, 76, 72, 79, 74, 76, 69], inf),
            \decay, Pwhite(2.4, 3.8, inf),
            \strike, Pwhite(0.35, 0.75, inf),
            \pan, Pwhite(-0.65, 0.65, inf),
            \amp, 0.15
        ).play;

        4.do { |i|
            Ndef(\clockSwarm).xset(\drift, 0.25 + (i * 0.15), \spread, 0.95);
            4.5.wait;
        };

        "0:48 - [Cue 4: Limite Intrínseco — Hyper-Dense Brass Swarm Saturation]".postln;
        // Intrinsic Limit (Archetype B): Drive tick density & escapement rates to extreme threshold
        Pbindef(\frenchCarillon).stop;
        Pbindef(\pocketWatchA, \dur, Pseq([0.092, 0.095, 0.089], inf), \amp, 0.14);
        Pbindef(\pocketWatchB, \dur, Pseq([0.078, 0.083, 0.081], inf), \amp, 0.13);
        5.do { |i|
            Ndef(\clockSwarm).xset(
                \density, 18.0 + (i * 5.2),
                \brassCut, 5200 + (i * 850),
                \drift, 0.8 + (i * 0.35),
                \amp, 0.26
            );
            2.4.wait;
        };

        "1:00 - [Cue 5: O Velho Relojoeiro Fecha os Olhos — Settling into the Breath of Time]".postln;
        // Settling / Subtractive Spotlight (Archetype C): Hard perceptual shift inward
        Pbindef(\pocketWatchA).stop;
        Pbindef(\pocketWatchB).stop;
        Pbindef(\pendulumPulse, \dur, Pseq([1.98, 2.03], inf), \amp, 0.11, \wood, 240);
        Ndef(\clockSwarm).fadeTime = 2.5;
        Ndef(\clockSwarm).xset(\amp, 0.045, \density, 3.8, \brassCut, 1650, \drift, 0.08);
        Ndef(\masterMix).set(\wet10, 0.46);

        // Acoustic beating between gears blooms as calm respiratory cycles
        Ndef(\timeBreath).fadeTime = 4.5;
        Ndef(\timeBreath).xset(\amp, 0.28, \root, 130.81, \beatRate, 0.18, \warmth, 1350, \air, 0.42);

        5.do { |i|
            var roots = [130.81, 146.83, 123.47, 130.81, 98.0];
            Ndef(\timeBreath).xset(
                \root, roots[i],
                \beatRate, [0.18, 0.24, 0.15, 0.21, 0.14][i],
                \warmth, [1450, 1850, 1200, 1650, 1100][i]
            );
            // Delicate ghostly chime overtones inside the watchmaker's closed-eye reverie
            Synth(\carillonChime, [
                \out, ~synthBus,
                \freq, roots[i] * [4, 5, 6].choose,
                \decay, 4.8,
                \strike, 0.15,
                \pan, rrand(-0.5, 0.5),
                \amp, 0.08
            ]);
            4.8.wait;
        };

        "1:24 - [Cue 6: Defasagens Microscópicas — Micro-Tick Flashback & Resolution]".postln;
        // Resolution (Archetype A) & Extrinsic Finale (Archetype D)
        Ndef(\timeBreath).xset(\root, 130.81, \amp, 0.22, \beatRate, 0.12, \warmth, 920);
        Pbindef(\pocketWatchA,
            \dur, Pseq([0.48, 0.52, 0.49, 1.45], inf),
            \freq, Pseq([2616, 2936, 3296, 2616], inf),
            \rel, 0.04,
            \amp, 0.09
        ).play;

        3.do { |i|
            Ndef(\clockSwarm).xset(\amp, (0.04 - (i * 0.012)).max(0.005), \density, 2.5 - (i * 0.5));
            4.0.wait;
        };

        "1:36 - [Cue 7: Último Suspiro das Engrenagens — Final Chime & Stillness]".postln;
        Pbindef(\pocketWatchA).stop;
        Pbindef(\pendulumPulse).stop;
        Ndef(\clockSwarm).fadeTime = 5.0;
        Ndef(\clockSwarm).xset(\amp, 0.0);
        Ndef(\timeBreath).fadeTime = 7.0;
        Ndef(\timeBreath).xset(\amp, 0.0, \warmth, 420);

        // One final resonant bronze strike settling into wooden silence
        Synth(\woodenPendulum, [\out, ~synthBus, \freq, 65.41, \wood, 260, \dur, 0.45, \amp, 0.22, \pan, -0.15]);
        0.35.wait;
        Synth(\carillonChime, [\out, ~synthBus, \freq, 523.25, \decay, 6.5, \strike, 0.25, \amp, 0.16, \pan, 0.15]);
        7.5.wait;

        // Scoped Cleanup (preserving ~synthBus and shared server state)
        Pbindef(\pendulumPulse).stop; Pbindef(\pendulumPulse).clear;
        Pbindef(\pocketWatchA).stop; Pbindef(\pocketWatchA).clear;
        Pbindef(\pocketWatchB).stop; Pbindef(\pocketWatchB).clear;
        Pbindef(\frenchCarillon).stop; Pbindef(\frenchCarillon).clear;
        Ndef(\clockSwarm).clear(2.0);
        Ndef(\timeBreath).clear(2.0);
        Ndef(\masterMix).clear(2.0);
        2.2.wait;
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
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\subtractiveDesign).fadeTime = 1.5;
Ndef(\subtractiveDesign, {
    |freq=130.81, detune=0.018, sawMix=0.44, pulseMix=0.56,
     pw=0.34, pwmRate=1.7, pwmDepth=0.1,
     subAmp=0.15, noiseAmp=0.036,
     cutoff=1437.4, rq=0.54, hpf=152.2,
     filtEnvAmt=2348.1, lfoRate=1.45, lfoDepth=194.9,
     atk=0.053, dec=0.58, sus=0.51, rls=0.43,
     pan=(0.21), amp=0.29, t_trig=1|
    var env, filtEnv, freqs, pwm, sawSig, pulseSig, subSig, noiseSig, sig, dynCutoff;

    env = EnvGen.ar(Env([0, 1, sus, 0], [atk, dec, rls], \sin), t_trig);
    filtEnv = EnvGen.ar(Env.perc(atk.max(0.005), (dec + rls).clip(0.1, 2.5)), t_trig);

    freqs = freq * [1 - detune, 1, 1 + detune];
    pwm = (pw + (SinOsc.kr(pwmRate) * pwmDepth)).clip(0.08, 0.92);

    sawSig = Splay.ar(Saw.ar(freqs));
    pulseSig = Splay.ar(Pulse.ar(freqs, pwm));
    subSig = SinOsc.ar(freq * 0.5) * subAmp;
    noiseSig = PinkNoise.ar * noiseAmp;

    sig = (sawSig * sawMix) + (pulseSig * pulseMix) + subSig + noiseSig;

    dynCutoff = (cutoff + (filtEnv * filtEnvAmt) + (SinOsc.kr(lfoRate) * lfoDepth)).clip(60, 18000);
    sig = RLPF.ar(sig, dynCutoff, rq.clip(0.08, 0.95));
    sig = HPF.ar(sig, hpf.clip(20, 2000));
    sig = (sig * 1.4).tanh;

    sig = Balance2.ar(sig[0], sig[1], pan) * env * amp;
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\subtractiveDesign)[10] = \filter -> { |in|
    CombL.ar(in, 0.5, 0.1875, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.22);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.57, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.34);

Pbindef(\subtractiveDesignSeq,
    \dur, Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf),
    \freq, (130.81 * (2 ** (Prand([0, 1, 4, 5, 7, 8, 10], inf) / 12))),
    \t_trig, 1
);
Ndef(\subtractiveDesign)[1] = \set -> Pbindef(\subtractiveDesignSeq);

// Live MIDI control (loopMIDI -> BeatStep Pro -> any external hardware MIDI)
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
    MIDIClient.sources.first
};
if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ~myUid = ~myInDevice.uid;
    ("Design Fallback MIDI connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
} {
    ~myUid = nil;
};
MIDIdef.noteOn(\subtractiveDesignMidiOn, { |vel, noteNum|
    Pbindef(\subtractiveDesignSeq).stop;
    Ndef(\subtractiveDesign).set(\freq, noteNum.midicps, \amp, vel.linlin(1, 127, 0.12, 0.42), \t_trig, 1);
}, srcID: ~myUid);
MIDIdef.cc(\subtractiveDesignMidiCC, { |val, num|
    if((num == 1) or: { num == 74 }) {
        Ndef(\subtractiveDesign).set(\cutoff, val.linexp(0, 127, 120, 14000));
    };
}, srcID: ~myUid);
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Layer 1: Caixas do Rosário & Surdo de Moçambique (Cadenced Processional Drum Pulse)
Ndef(\caixaMocambique).fadeTime = 2.0;
Ndef(\caixaMocambique, {
    |freq=65, snap=0.45, toneDecay=0.38, snareDecay=0.18, drive=1.8, pan=0.0, amp=0.25, t_trig=1|
    var trigA, pEnv, aEnv, sEnv, body, snare, woodClick, sig;
    trigA = K2A.ar(t_trig);
    pEnv = EnvGen.ar(Env.perc(0.001, 0.06, 1, -6), t_trig);
    aEnv = EnvGen.ar(Env.perc(0.003, toneDecay, 1, -4), t_trig);
    sEnv = EnvGen.ar(Env.perc(0.002, snareDecay, 1, -5), t_trig);

    body = SinOsc.ar(freq * (1 + (pEnv * 2.2))) + (SinOsc.ar(freq * 2.0) * 0.45);
    body = (body * drive).tanh * aEnv;

    snare = WhiteNoise.ar + (PinkNoise.ar * 0.6);
    snare = (BPF.ar(snare, 2100, 0.45) * 3.5) + (HPF.ar(snare, 4200) * 0.6);
    snare = snare * sEnv * snap;

    woodClick = Ringz.ar(Decay2.ar(trigA, 0.001, 0.015) * PinkNoise.ar, [420, 790], 0.04).sum * 0.25;

    sig = LeakDC.ar(body + snare + woodClick);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\caixaMocambique)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.42, 0.6);
};
Ndef(\caixaMocambique).set(\wet10, 0.16);

Pbindef(\caixaSeq,
    \dur, Pn(Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.375, 0.375, 0.25, 0.5, 0.25, 0.25], 1), inf),
    \freq, Pn(Pseq([58, 92, 86, 62, 95, 88, 55, 65, 98, 58, 90, 96], 1), inf),
    \snap, Pn(Pseq([0.15, 0.65, 0.5, 0.22, 0.72, 0.45, 0.18, 0.35, 0.8, 0.2, 0.6, 0.75], 1), inf),
    \toneDecay, Pwrand([0.42, 0.26, 0.18], [0.45, 0.35, 0.2], inf),
    \snareDecay, Pwhite(0.11, 0.24, inf),
    \pan, Pwhite(-0.2, 0.2, inf),
    \amp, Pn(Pseq([0.26, 0.16, 0.14, 0.24, 0.18, 0.14, 0.25, 0.22, 0.19, 0.25, 0.15, 0.18], 1), inf),
    \t_trig, 1
);
Ndef(\caixaMocambique).quant = 1;
Ndef(\caixaMocambique)[1] = \set -> Pbindef(\caixaSeq);

// Layer 2: Gungas de Lata nos Tornozelos (Tin-Can Ankle Rattles & Metallic Step Shakers)
Ndef(\gungasLata).fadeTime = 2.0;
Ndef(\gungasLata, {
    |baseFreq=1450, spread=0.35, decay=0.09, grit=0.6, pan=0.3, amp=0.16, t_trig=1|
    var trigA, grains, exciter, tinModes, rattle, lfo, sig;
    trigA = K2A.ar(t_trig);
    lfo = SinOsc.kr(0.23).range(0.92, 1.08);
    grains = Dust.ar(TRand.kr(45, 110, t_trig)) * Decay2.ar(trigA, 0.012, decay * 1.4);
    exciter = (Decay2.ar(trigA, 0.002, 0.035) + (grains * grit)) * WhiteNoise.ar(0.45);

    tinModes = DynKlank.ar(
        Ref([
            [1.0, 1.49, 2.13, 2.87, 3.74, 4.61] * baseFreq * lfo,
            [0.35, 0.28, 0.22, 0.18, 0.12, 0.09],
            [0.08, 0.06, 0.05, 0.04, 0.03, 0.02]
        ]),
        exciter,
        1.0,
        0.0,
        decay.clip(0.03, 0.35) * 6.0
    );

    rattle = BPF.ar(exciter, baseFreq * 2.4, 0.18) * 9.0;
    sig = HPF.ar((tinModes * 0.35) + rattle, 750).tanh;
    sig = Splay.ar([sig, DelayN.ar(sig, 0.03, TRand.kr(0.004, 0.019, t_trig))], spread);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    CombL.ar(in, 0.25, 0.125, 0.55);
};
Ndef(\gungasLata).set(\wet10, 0.22);

Pbindef(\gungasSeq,
    \dur, Pn(Pseq([0.25, 0.25, 0.125, 0.125, 0.25, 0.25, 0.25, 0.25, 0.125, 0.125], 1), inf),
    \baseFreq, Pwrand([1280, 1490, 1680, 1920], [0.35, 0.35, 0.2, 0.1], inf),
    \decay, Pn(Pseq([0.14, 0.07, 0.05, 0.06, 0.13, 0.08, 0.15, 0.07, 0.05, 0.08], 1), inf),
    \grit, Pwhite(0.45, 0.85, inf),
    \pan, Pn(Pseq([-0.55, 0.55, -0.4, -0.35, 0.5, -0.5, 0.55, -0.45, 0.35, 0.4], 1), inf),
    \amp, Pn(Pseq([0.18, 0.11, 0.09, 0.11, 0.17, 0.11, 0.18, 0.12, 0.09, 0.12], 1), inf),
    \t_trig, 1
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\gungasSeq);

// Layer 3: Canto do Rosário & Sanfona Devocional (Syncretic Vocal Formant Choir + Reed Harmonics)
Ndef(\cantoRosario).fadeTime = 3.5;
Ndef(\cantoRosario, {
    |freq=220, dur=2.0, vowel=0.35, reedMix=0.35, vibrato=0.007, pan=0.0, amp=0.18, t_trig=1|
    var env, vib, chords, body, vA, vO, vU, formF, formants, reed, sig;
    env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.35, (dur - 0.95).max(0.1), 0.6], \sin), t_trig);
    vib = SinOsc.kr(5.1 + LFNoise1.kr(0.4).range(-0.5, 0.5)) * vibrato;
    chords = freq * (1 + vib) * [0.5, 1.0, 1.498, 2.0];

    body = Saw.ar(chords).sum * 0.25;
    vA = [730, 1090, 2440];
    vO = [450, 800, 2600];
    vU = [320, 700, 2500];
    formF = SelectX.kr((vowel + LFNoise1.kr(0.25).range(-0.18, 0.18)).clip(0, 2), [vA, vO, vU]);
    formants = BPF.ar(body, formF, 0.11).sum * 11.0;

    reed = Splay.ar(Pulse.ar(chords * [1.0, 1.003], 0.38)) * reedMix;
    reed = RLPF.ar(reed, (freq * 5.5).clip(300, 4800), 0.45);

    sig = (Pan2.ar(formants, pan * 0.5) * 0.72) + reed;
    sig = HPF.ar(sig, 110) * env;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 65, 3.8, 0.48, 0.5, 15, 0.0, 0.55, 0.35);
};
Ndef(\cantoRosario).set(\wet10, 0.36);

Pbindef(\cantoSeq,
    \dur, Pn(Pseq([2.0, 1.5, 0.5, 2.0, 1.0, 1.0, 2.5, 1.5], 1), inf),
    \freq, (196.0 * (2 ** (Pn(Pseq([0, 4, 7, 9, 7, 4, 2, 0, 5, 4, 2, -3, 0, 4, 2, 0], 1), inf) / 12))),
    \vowel, Pn(Pseq([0.1, 0.8, 1.2, 0.3, 1.6, 0.9, 0.2, 1.4], 1), inf),
    \reedMix, Pwhite(0.25, 0.45, inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \amp, Pwhite(0.15, 0.21, inf),
    \t_trig, 1
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\cantoSeq);
)

// Ndef(\gungasLata).xset(\wet10, 0.45); // Expand metallic street echo | Revert: Ndef(\gungasLata).xset(\wet10, 0.22);
// Pbindef(\caixaSeq, \dur, 0.25); // Steady march cadence | Revert: Pbindef(\caixaSeq, \dur, Pn(Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25], 1), inf));
// Pbindef(\cantoSeq, \vowel, 0.0); // Open /a/ coronation chant | Revert: Pbindef(\cantoSeq, \vowel, Pn(Pseq([0.1, 0.8, 1.2, 0.3], 1), inf));
// Pbindef(\caixaSeq).stop; Ndef(\caixaMocambique).fadeTime = 4; Ndef(\caixaMocambique).clear(4); // Rollback Layer 1
// Pbindef(\gungasSeq).stop; Ndef(\gungasLata).fadeTime = 4; Ndef(\gungasLata).clear(4); // Rollback Layer 2
// Pbindef(\cantoSeq).stop; Ndef(\cantoRosario).fadeTime = 4; Ndef(\cantoRosario).clear(4); // Rollback Layer 3

