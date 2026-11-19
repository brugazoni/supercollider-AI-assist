// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Carbon
// Model ID: openrouter:google/gemini-4-carbon
// Date: 2026-11-13T13:22:06.756995+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// =====================================================================
// 1. O MAPA RODOVIÁRIO (The Road Map - Pedantic, dry paper creases)
// =====================================================================
Ndef(\mapaRodoviario, { |freq=1200, amp=0.18, pan=0, fold=2.2, rq=0.04, rel=0.06, t_trig=0|
    var env, noise, sig;
    env = EnvGen.ar(Env.perc(0.002, rel, 1, -6), t_trig);
    noise = WhiteNoise.ar + (PinkNoise.ar * 0.5);
    // West Coast wavefolding to emulate crisp, dry paper friction
    sig = Fold.ar(noise * fold, -0.7, 0.7);
    // Narrow bandpass with aggressive makeup gain for thin, brittle acoustics
    sig = BPF.ar(sig, freq.clip(200, 14000), rq) * 12.0;
    sig = HPF.ar(sig, 500);
    Pan2.ar(sig * env * amp, pan);
}).play;

// Spatial reflection of a quiet restaurant table (initialized dry)
Ndef(\mapaRodoviario)[10] = \filter -> { |in|
    CombL.ar(in, 0.2, [0.043, 0.057], 0.35);
};
Ndef(\mapaRodoviario).set(\wet10, 0);

// Methodical, asymmetric rhythmic pattern mimicking step-by-step folding instructions
Pbindef(\mapaSeq,
    \dur, Pseq([0.35, 0.15, 0.35, 0.8, 0.2, 0.2, 1.4], inf),
    \freq, Pseq([1800, 2400, 1500, 3200, 1100, 2900, 950], inf),
    \fold, Pseq([1.8, 2.5, 2.0, 3.4, 1.5, 2.8, 4.0], inf),
    \rel, Pseq([0.04, 0.025, 0.05, 0.11, 0.03, 0.03, 0.16], inf),
    \rq, Pwhite(0.025, 0.06, inf),
    \pan, Pseq([-0.35, -0.2, -0.4, -0.15, -0.3, -0.25, 0.0], inf),
    \amp, Pseq([0.18, 0.12, 0.16, 0.24, 0.14, 0.15, 0.22], inf),
    \t_trig, 1
);
Ndef(\mapaRodoviario)[1] = \set -> Pbindef(\mapaSeq);


// =====================================================================
// 2. GARRAFA SUSPENSA (The Suspended Wine Bottle - Frozen glassy tension)
// =====================================================================
Ndef(\garrafaSuspensa, { |freq=987.77, amp=0.11, pan=0.35, atk=2.5, rel=5.0, vibRate=0.25, t_trig=0|
    var env, exciter, freqs, amps, rings, sig;
    env = EnvGen.ar(Env.perc(atk, rel, 1, -2), t_trig);
    // Continuous breathy excitation like air trapped in the neck of a wine bottle
    exciter = BPF.ar(PinkNoise.ar(0.25), freq, 0.02) * 10.0;
    exciter = exciter + SinOsc.ar(freq * [1, 1.0015], 0, 0.04).sum;
    freqs = [1, 2.003, 2.756, 4.11] * freq * SinOsc.kr(vibRate).range(0.998, 1.002);
    amps = [1.0, 0.45, 0.25, 0.1];
    rings = [4.0, 2.5, 1.8, 0.9];
    sig = DynKlank.ar(Ref([freqs, amps, rings]), exciter * 0.12, 1.0, 0.0, 1.0);
    Pan2.ar(sig * env * amp, pan);
}).play;

// Frozen temporal shimmer for the motionless waiter (initialized at 0.35)
Ndef(\garrafaSuspensa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.94, 0.15);
};
Ndef(\garrafaSuspensa).set(\wet10, 0.35);

// Sparse, high-register harmonic suspension (27 years crystallized in a second)
Pbindef(\garrafaSeq,
    \dur, Pseq([7.0, 9.0, 8.0], inf),
    \midinote, Pseq([83, 84, 81], inf), // B5, C6, A5 - tight semitone/minor friction
    \atk, 3.0,
    \rel, 6.0,
    \pan, Pwhite(0.25, 0.45, inf),
    \amp, 0.1,
    \t_trig, 1
);
Ndef(\garrafaSuspensa)[1] = \set -> Pbindef(\garrafaSeq);


// =====================================================================
// 3. TEMPESTADE ANTÁRTICA (Antarctic Storm - Crushing sub-bass silence)
// =====================================================================
Ndef(\tempestadeAntartica, { |freq=36.71, amp=0.38, cutoff=130, res=3.3, windAmt=0.22, atk=3.5, rel=5.5, t_trig=0|
    var env, sub, detuned, wind, sig;
    env = EnvGen.ar(Env.perc(atk, rel, 1, 2), t_trig);
    // Fundamental + 1st octave harmonic so deep sub-bass translates physically
    sub = SinOsc.ar(freq, 0, 0.75) + SinOsc.ar(freq * 2, 0, 0.35);
    // 27-year pressure: dense detuned low cluster
    detuned = Splay.ar(Saw.ar(freq * [0.985, 0.994, 1.0, 1.007, 1.502])) * 0.45;
    // Sub-zero katabatic wind howling beneath the silence
    wind = RLPF.ar(PinkNoise.ar(windAmt), LFNoise2.kr(0.18).range(90, 380), 0.25);
    sig = (sub + detuned + wind);
    // Heavy Moog low-pass pressure with makeup gain into soft saturation
    sig = (MoogFF.ar(sig, cutoff + (env * 70), res) * 4.5).tanh;
    sig = LeakDC.ar(sig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * (0.35 + (env * 0.65))) } { Pan2.ar(sig, 0, amp * (0.35 + (env * 0.65))) };
}).play;

// Cavernous sub-zero atmospheric blur (initialized dry)
Ndef(\tempestadeAntartica)[10] = \filter -> { |in|
    GVerb.ar(in.sum * 0.5, 140, 8.0, 0.7, 0.5, 15, 0.0, 0.4, 0.3);
};
Ndef(\tempestadeAntartica).set(\wet10, 0);

// Slow, tectonic barometer drops about to collapse
Pbindef(\tempestadeSeq,
    \dur, Pseq([8.0, 8.0, 11.0], inf), // 8 + 8 + 11 = 27 beats of accumulated marriage weight
    \midinote, Pseq([26, 25, 24], inf), // D1 -> Db1 -> C1
    \cutoff, Pseq([120, 155, 190], inf),
    \windAmt, Pseq([0.15, 0.28, 0.42], inf),
    \atk, 4.0,
    \rel, 6.5,
    \amp, Pseq([0.34, 0.38, 0.44], inf),
    \t_trig, 1
);
Ndef(\tempestadeAntartica)[1] = \set -> Pbindef(\tempestadeSeq);

// Pbindef(\mapaSeq).stop; Ndef(\mapaRodoviario).fadeTime = 2; Ndef(\mapaRodoviario).clear(2); // Rollback: remove mapaRodoviario
// Pbindef(\garrafaSeq).stop; Ndef(\garrafaSuspensa).fadeTime = 2; Ndef(\garrafaSuspensa).clear(2); // Rollback: remove garrafaSuspensa
// Pbindef(\tempestadeSeq).stop; Ndef(\tempestadeAntartica).fadeTime = 2; Ndef(\tempestadeAntartica).clear(2); // Rollback: remove tempestadeAntartica
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

    // 0. Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 1. Discrete Horological SynthDefs (Brass Escapements, French Chimes, Pocket Watches)
    SynthDef(\escapamentoLatao, { |out=0, freq=2400, woodFreq=380, amp=0.12, pan=0, rel=0.045|
        var env, click, brass, wood, sig;
        env = EnvGen.ar(Env.perc(0.0008, rel, 1, -7), doneAction: 2);
        click = HPF.ar(WhiteNoise.ar(0.8), 3200) * EnvGen.ar(Env.perc(0.0003, 0.008));
        brass = DynKlank.ar(Ref([[1.0, 2.73, 4.18], [1.0, 0.45, 0.2], [0.025, 0.015, 0.008]]), click, freq / 1000, 0, 1.0);
        wood = Ringz.ar(LPF.ar(Impulse.ar(0), 1200), woodFreq, 0.035) * 0.25;
        sig = (brass * 0.35 + wood) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\cronometroBolso, { |out=0, freq=5600, amp=0.06, pan=0|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.0005, 0.018, 1, -8), doneAction: 2);
        mod = SinOsc.ar(freq * 1.414) * freq * 1.8 * env;
        sig = HPF.ar(SinOsc.ar(freq + mod), 2500) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\carrilhaoFrances, { |out=0, freq=523.25, amp=0.14, pan=0, dur=3.5, strike=1.2|
        var env, idxEnv, mod1, mod2, car, body, sig;
        env = EnvGen.ar(Env.perc(0.003, dur.max(0.2), 1, -4), doneAction: 2);
        idxEnv = EnvGen.ar(Env.perc(0.001, 0.18, strike, -6));
        mod1 = SinOsc.ar(freq * 2.756) * (freq * idxEnv * 1.4);
        mod2 = SinOsc.ar(freq * 5.404) * (freq * idxEnv * 0.7);
        car = SinOsc.ar(freq + mod1 + mod2) * 0.65;
        body = DynKlank.ar(Ref([[1.0, 2.002, 3.01], [0.5, 0.25, 0.12], [1.0, 0.7, 0.4]]), Impulse.ar(0) * 0.25, freq, 0, dur * 0.5);
        sig = LeakDC.ar((car + body) * env);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\cordaMola, { |out=0, rate=28, freq=1800, dur=0.7, amp=0.1, pan=0|
        var env, trig, sig;
        env = EnvGen.ar(Env.linen(0.02, (dur - 0.12).max(0.05), 0.1, 1, -3), doneAction: 2);
        trig = Impulse.ar(XLine.kr(rate, rate * 0.45, dur));
        sig = Ringz.ar(trig * 0.25, freq * [1, 1.62], 0.015).sum;
        sig = BPF.ar(sig, freq * 1.2, 0.4) * 3.0 * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // 2. Continuous Ndef Textures (200-Clock Swarm & The Breath of Time)
    Ndef(\enxameDuzentos, { |dens=18, baseFreq=3100, spread=0.85, combDecay=0.12, amp=0|
        var trigs, grainMove, clicks, microGear, sig;
        trigs = Dust.ar([dens, dens * 1.03]);
        clicks = Decay2.ar(trigs, 0.0006, 0.012) * BPF.ar(WhiteNoise.ar(1.0), TExpRand.ar(baseFreq * 0.6, baseFreq * 2.1, trigs), 0.15) * 5.0;
        microGear = CombL.ar(clicks, 0.1, LFNoise1.kr([0.3, 0.33]).range(0.018, 0.065), combDecay);
        grainMove = Splay.ar([clicks[0] + (microGear[0] * 0.45), clicks[1] + (microGear[1] * 0.45)], spread);
        sig = HPF.ar(grainMove, 700);
        if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp) } { Pan2.ar(sig, 0, amp) };
    });

    Ndef(\respirarDoTempo, { |freq=130.81, breathRate=0.14, phaseShift=0.6, cutoff=900, amp=0|
        var breathLFO, air, harmonics, sig;
        breathLFO = SinOsc.kr(breathRate, [0, phaseShift]).range(0.18, 1.0);
        air = BPF.ar(PinkNoise.ar(0.35), [freq * 2, freq * 3.01] * breathLFO.range(0.85, 1.35), 0.06) * 8.0;
        harmonics = Mix.fill(6, { |i|
            var det = SinOsc.kr(0.05 + (i * 0.017)).range(0.996, 1.004);
            var hFreq = freq * (i + 1) * det;
            SinOsc.ar([hFreq, hFreq * 1.0025]) * (1 / ((i + 1) ** 1.35)) * SinOsc.kr(breathRate * (1 + (i * 0.08))).range(0.2, 1.0);
        });
        sig = RLPF.ar((harmonics * 0.25) + (air * 0.35), cutoff * breathLFO.sum.linlin(0.36, 2.0, 0.5, 1.6), 0.45);
        sig = (sig * 1.3).tanh;
        if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp) } { Pan2.ar(sig, 0, amp) };
    });

    // 3. Master Mixer & Workshop Acoustics (Narrow Shop on Ladeira de Santa Efigenia)
    Ndef(\oficinaMaster, {
        var discrete = In.ar(~synthBus, 2);
        var swarm = Ndef.ar(\enxameDuzentos, 2);
        var breath = Ndef.ar(\respirarDoTempo, 2);
        discrete + swarm + breath;
    });

    Ndef(\oficinaMaster)[10] = \filter -> { |in|
        var early = AllpassC.ar(in, 0.08, [0.029, 0.041], 0.35);
        FreeVerb2.ar(early[0], early[1], 1.0, \roomSize.kr(0.55), \damp.kr(0.45));
    };
    Ndef(\oficinaMaster).set(\wet10, 0.18);
    Ndef(\oficinaMaster).play;
    s.sync;

    // 4. Master Timeline Score (~1:45 narrative arc)
    Tdef(\masterScore, {
        0.5.wait;

        // Smoothly crossfade out prior scene elements if running on shared server
        Pbindef(\mapaSeq).stop;
        Pbindef(\garrafaSeq).stop;
        Pbindef(\tempestadeSeq).stop;
        Ndef(\mapaRodoviario).fadeTime = 4; Ndef(\mapaRodoviario).xset(\amp, 0);
        Ndef(\garrafaSuspensa).fadeTime = 4; Ndef(\garrafaSuspensa).xset(\amp, 0);
        Ndef(\tempestadeAntartica).fadeTime = 4; Ndef(\tempestadeAntartica).xset(\amp, 0);

        // CUE 1: A Oficina Estreita (0:00 - 0:20) — Phase-shifting pendulums & winding springs
        "0:00 - [Cue 1: A Oficina Estreita da Ladeira de Santa Efigênia]".postln;
        Synth(\cordaMola, [\out, ~synthBus, \rate, 34, \freq, 2100, \dur, 1.1, \pan, -0.4, \amp, 0.12]);

        Pbindef(\penduloA,
            \instrument, \escapamentoLatao,
            \out, ~synthBus,
            \dur, 0.5,
            \freq, Pseq([2200, 1850], inf),
            \woodFreq, Pseq([340, 310], inf),
            \pan, -0.55,
            \rel, 0.045,
            \amp, Pseq([0.13, 0.09], inf)
        ).play;

        2.0.wait;

        // Slightly out-of-sync second & third pendulums (Steve Reich style horological drift)
        Pbindef(\penduloB,
            \instrument, \escapamentoLatao,
            \out, ~synthBus,
            \dur, 0.487,
            \freq, Pseq([2650, 2120], inf),
            \woodFreq, Pseq([420, 390], inf),
            \pan, 0.55,
            \rel, 0.04,
            \amp, Pseq([0.12, 0.08], inf)
        ).play;

        Pbindef(\penduloC,
            \instrument, \escapamentoLatao,
            \out, ~synthBus,
            \dur, 0.519,
            \freq, Pseq([1950, 1620], inf),
            \woodFreq, Pseq([290, 265], inf),
            \pan, 0.05,
            \rel, 0.055,
            \amp, Pseq([0.11, 0.08], inf)
        ).play;

        Ndef(\enxameDuzentos).fadeTime = 8;
        Ndef(\enxameDuzentos).xset(\amp, 0.16, \dens, 14, \baseFreq, 2900);

        3.do { |i|
            if (i == 1) { Synth(\cordaMola, [\out, ~synthBus, \rate, 26, \freq, 1650, \dur, 0.85, \pan, 0.45, \amp, 0.1]); };
            Ndef(\enxameDuzentos).xset(\dens, 18 + (i * 8));
            5.5.wait;
        };

        // CUE 2: Carrilhões Franceses e Cronômetros de Bolso (0:19 - 0:46)
        "0:19 - [Cue 2: Carrilhões Franceses e Cronômetros em Desencontro]".postln;
        Pbindef(\bolsoRapido,
            \instrument, \cronometroBolso,
            \out, ~synthBus,
            \dur, Pseq([0.197, 0.197, 0.197, 0.203, 0.191], inf),
            \freq, Pwhite(4800, 7400, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, Pseq([0.065, 0.035, 0.05, 0.03, 0.06], inf)
        ).play;

        // Westminster-inspired asymmetric French carillon chimes drifting apart
        Pbindef(\carrilhaoSeq,
            \instrument, \carrilhaoFrances,
            \out, ~synthBus,
            \dur, Pseq([1.75, 1.65, 1.85, 3.4, 1.7, 1.8, 1.6, 3.6], inf),
            \midinote, Pseq([76, 72, 74, 67, 67, 74, 76, 72] + Prand([0, 0, 0.12, -0.1], inf), inf),
            \dur, Pseq([1.6, 1.55, 1.7, 3.1], inf),
            \strike, Pwhite(0.9, 1.6, inf),
            \pan, Pwhite(-0.65, 0.65, inf),
            \amp, Pwhite(0.09, 0.14, inf)
        ).play;

        Ndef(\oficinaMaster).set(\wet10, 0.28, \roomSize, 0.65);

        // Intrinsic Limit (b): Drive swarm density & micro-gear resonance toward saturation
        5.do { |i|
            var dTarget = 32 + (i * 22);
            Ndef(\enxameDuzentos).fadeTime = 4;
            Ndef(\enxameDuzentos).xset(\dens, dTarget, \amp, 0.18 + (i * 0.035), \combDecay, 0.14 + (i * 0.07));
            if (i == 3) {
                Synth(\carrilhaoFrances, [\out, ~synthBus, \freq, 261.63, \dur, 5.5, \strike, 2.0, \amp, 0.16, \pan, 0]);
            };
            5.2.wait;
        };

        // CUE 3: O Velho Relojoeiro Fecha os Olhos (0:45 - 1:17) — Settling Archetype (c)
        // Abrupt subjective shift: mechanical clatter recedes into microscopic phase-beating breath
        "0:45 - [Cue 3: Olhos Fechados — Nas Defasagens Microscópicas, o Respirar do Tempo]".postln;
        Pbindef(\penduloB).stop;
        Pbindef(\penduloC).stop;
        Pbindef(\carrilhaoSeq).stop;

        // Soften remaining pendulum & pocket watch into delicate heartbeat pulse
        Pbindef(\penduloA, \amp, Pseq([0.055, 0.03], inf), \freq, Pseq([1400, 1180], inf), \rel, 0.03);
        Pbindef(\bolsoRapido, \dur, Pseq([0.201, 0.199, 0.6], inf), \amp, 0.028);

        Ndef(\enxameDuzentos).fadeTime = 6;
        Ndef(\enxameDuzentos).xset(\dens, 9, \amp, 0.07, \baseFreq, 4200, \combDecay, 0.45);

        Ndef(\oficinaMaster).set(\wet10, 0.52, \roomSize, 0.86, \damp, 0.25);

        // The Breath of Time blooms out of the microscopic phase differences
        Ndef(\respirarDoTempo).fadeTime = 7;
        Ndef(\respirarDoTempo).xset(\amp, 0.34, \freq, 130.81, \breathRate, 0.13, \cutoff, 1150);

        6.do { |i|
            var roots = [130.81, 146.83, 130.81, 164.81, 146.83, 130.81];
            Ndef(\respirarDoTempo).fadeTime = 4.5;
            Ndef(\respirarDoTempo).xset(
                \freq, roots[i],
                \breathRate, 0.12 + (i * 0.015),
                \cutoff, [1100, 1450, 950, 1650, 1250, 900][i]
            );
            // Occasional solitary crystalline chime floating inside the breath
            if (i.even) {
                Synth(\carrilhaoFrances, [
                    \out, ~synthBus,
                    \freq, (roots[i] * 4),
                    \dur, 5.0,
                    \strike, 0.65,
                    \pan, rrand(-0.4, 0.4),
                    \amp, 0.075
                ]);
            };
            5.2.wait;
        };

        // CUE 4: Resolução e Expiração Final (1:16 - 1:42) — Resolution (a) & Extrinsic Limit (d)
        "1:16 - [Cue 4: Resolução — O Tempo Inspira e Suspende]".postln;
        // Brief flashback return of the second pendulum matching the breath cycle
        Pbindef(\penduloB, \dur, 0.503, \amp, Pseq([0.05, 0.025], inf), \freq, Pseq([1650, 1380], inf)).play;
        Synth(\cordaMola, [\out, ~synthBus, \rate, 18, \freq, 1450, \dur, 1.3, \pan, 0.1, \amp, 0.07]);

        3.do { |i|
            Ndef(\respirarDoTempo).fadeTime = 4;
            Ndef(\respirarDoTempo).xset(\cutoff, 850 - (i * 200), \amp, 0.28 - (i * 0.07));
            Ndef(\enxameDuzentos).xset(\amp, 0.05 - (i * 0.015));
            4.5.wait;
        };

        // Final 6 PM solitary chime and delicate escapement stop
        Pbindef(\bolsoRapido).stop;
        Pbindef(\penduloB).stop;
        Synth(\carrilhaoFrances, [\out, ~synthBus, \freq, 261.63, \dur, 6.5, \strike, 0.85, \amp, 0.11, \pan, 0]);

        Ndef(\respirarDoTempo).fadeTime = 6;
        Ndef(\respirarDoTempo).xset(\amp, 0);
        Ndef(\enxameDuzentos).fadeTime = 5;
        Ndef(\enxameDuzentos).xset(\amp, 0);

        4.5.wait;
        Pbindef(\penduloA).stop;
        Synth(\escapamentoLatao, [\out, ~synthBus, \freq, 1500, \woodFreq, 280, \rel, 0.08, \amp, 0.08, \pan, 0]);
        3.5.wait;

        // Scoped Termination (cleanup ONLY objects managed here)
        Pbindef(\penduloA).clear;
        Pbindef(\penduloB).clear;
        Pbindef(\penduloC).clear;
        Pbindef(\bolsoRapido).clear;
        Pbindef(\carrilhaoSeq).clear;

        Ndef(\enxameDuzentos).clear(2);
        Ndef(\respirarDoTempo).clear(2);
        Ndef(\oficinaMaster).clear(2);

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
// Clear safe fallback if running
Ndef(\safe).clear(2);

// Layer 1: Caixa de Congo & Passo Cadenciado (Earth-shaking procession drum & sub)
Ndef(\caixaCongo).fadeTime = 2;
Ndef(\caixaCongo, { |freq=55, snap=0.45, decay=0.35, drive=2.2, pan=0, amp=0.26, t_trig=1|
    var trig, bodyEnv, pitchEnv, body, subHarm, snareEnv, snare, sig;
    trig = K2A.ar(t_trig);
    bodyEnv = EnvGen.ar(Env.perc(0.004, decay, 1, -5), t_trig);
    pitchEnv = EnvGen.ar(Env([2.6, 1.2, 1.0], [0.018, 0.09], -4), t_trig);
    body = SinOsc.ar(freq * pitchEnv);
    subHarm = SinOsc.ar(freq * 2 * pitchEnv, 0, 0.45);
    snareEnv = Decay2.ar(trig, 0.002, decay * 0.55);
    snare = BPF.ar(WhiteNoise.ar, [1150, 2450], 0.35).sum * 3.5 * snareEnv * snap;
    sig = ((body + subHarm) * bodyEnv) + snare;
    sig = (sig * drive).tanh * 0.7;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\caixaCongo)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.42, 0.65);
};
Ndef(\caixaCongo).set(\wet10, 0.18);

Pbindef(\seqCaixaCongo,
    \t_trig, 1,
    \dur, Pseq([
        0.5, 0.25, 0.25, 0.5, 0.5,
        0.375, 0.375, 0.25, 0.5, 0.5
    ], inf),
    \freq, Pseq([52, 68, 65, 52, 58, 52, 65, 73, 52, 55], inf),
    \snap, Pseq([0.2, 0.65, 0.55, 0.85, 0.3, 0.25, 0.7, 0.6, 0.9, 0.35], inf),
    \decay, Pseq([0.42, 0.18, 0.2, 0.35, 0.28], inf),
    \pan, Pwhite(-0.15, 0.15, inf),
    \amp, Pseq([0.27, 0.18, 0.19, 0.25, 0.21], inf)
);
Ndef(\caixaCongo).quant = 1;
Ndef(\caixaCongo)[1] = \set -> Pbindef(\seqCaixaCongo);

// Layer 2: Gungas de Lata (Tin-can ankle rattles with lead pellets & metallic modes)
Ndef(\gungasLata).fadeTime = 2;
Ndef(\gungasLata, { |tinFreq=1650, rattleDens=42, decay=0.16, spread=0.65, pan=0, amp=0.18, t_trig=1|
    var stepEnv, grains, exciter, modes, lata, highShake, sig;
    stepEnv = EnvGen.ar(Env([0, 1, 0.6, 0], [0.012, 0.05, decay], -3), t_trig);
    grains = Dust.ar(rattleDens + LFNoise1.kr(3).range(0, 18)) * stepEnv;
    exciter = (K2A.ar(t_trig) * 0.5) + (Decay2.ar(grains, 0.001, 0.018) * WhiteNoise.ar);
    modes = [1.0, 1.47, 2.13, 2.89, 3.64] * TRand.kr(0.96, 1.05, t_trig);
    lata = DynKlank.ar(
        Ref([modes * tinFreq, [0.45, 0.35, 0.28, 0.2, 0.14], [0.07, 0.05, 0.04, 0.03, 0.02]]),
        exciter,
        1.0,
        0,
        decay * 4
    ) * 0.18;
    highShake = BPF.ar(WhiteNoise.ar * stepEnv, [4800, 7200], 0.18).sum * 5.0;
    sig = Splay.ar([lata, highShake * 0.65], spread);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    CombL.ar(in, 0.25, [0.062, 0.089], 0.32);
};
Ndef(\gungasLata).set(\wet10, 0.24);

Pbindef(\seqGungasLata,
    \t_trig, 1,
    \dur, Pwrand([
        Pseq([0.25, 0.25, 0.25, 0.25], 1),
        Pseq([0.25, 0.125, 0.125, 0.25, 0.25], 1),
        Pseq([0.375, 0.125, 0.25, 0.25], 1)
    ], [0.55, 0.3, 0.15], inf),
    \tinFreq, Pseq([1480, 1820, 1560, 1950, 1420, 1760], inf) * Pwhite(0.97, 1.03, inf),
    \rattleDens, Pseq([55, 32, 48, 36], inf),
    \decay, Pseq([0.19, 0.11, 0.15, 0.12], inf),
    \pan, Pseq([-0.55, 0.55, -0.4, 0.45], inf),
    \amp, Pseq([0.20, 0.12, 0.17, 0.13], inf)
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\seqGungasLata);

// Layer 3: Canto do Rosário & Sanfona de Louvor (Syncretic Mixolydian vocal/reed devotion)
Ndef(\cantoRosario).fadeTime = 4;
Ndef(\cantoRosario, { |freq=220, dur=2.0, vowel=0.35, vibDepth=0.008, brightness=1900, pan=0, amp=0.17, t_trig=1|
    var lagFreq, vib, env, reeds, body, vA, vO, vE, formF, choir, bellMod, bell, sig;
    lagFreq = Lag.kr(freq, 0.12);
    vib = SinOsc.kr(LFNoise1.kr(0.4).range(4.6, 5.8)).range(1 - vibDepth, 1 + vibDepth);
    env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.35, (dur - 0.85).max(0.1), 0.5], \sin), t_trig);
    reeds = Saw.ar(lagFreq * vib * [0.5, 0.997, 1.0, 1.004, 1.498]);
    reeds = RLPF.ar(reeds, brightness * LFNoise1.kr(0.25).range(0.75, 1.25), 0.45);
    body = reeds.sum * 0.25;
    vA = [730, 1090, 2440];
    vO = [450, 800, 2600];
    vE = [530, 1840, 2480];
    formF = SelectX.kr((vowel + LFNoise1.kr(0.2).range(-0.15, 0.15)).clip(0, 2), [vA, vO, vE]);
    choir = BPF.ar(body, formF, 0.11).sum * 12.0;
    bellMod = SinOsc.ar(lagFreq * 4.02) * lagFreq * 1.2 * EnvGen.ar(Env.perc(0.005, 0.35), t_trig);
    bell = SinOsc.ar((lagFreq * 2) + bellMod) * EnvGen.ar(Env.perc(0.01, 0.9), t_trig) * 0.18;
    sig = Splay.ar(reeds * 0.45, 0.55) + Pan2.ar((choir * 0.65) + bell, pan * 0.5);
    sig = HPF.ar(sig, 130) * env;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    GVerb.ar(in.sum * 0.45, 65, 3.8, 0.45, 0.5, 15, 0.0, 0.45, 0.35);
};
Ndef(\cantoRosario).set(\wet10, 0.36);

Pbindef(\seqCantoRosario,
    \t_trig, 1,
    \scale, Scale.mixolydian,
    \root, 7,
    \octave, Pseq([4, 4, 4, 5, 4, 4, 4, 4], inf),
    \degree, Pseq([
        0, 2, 4, 0,
        5, 4, 2, 0,
        4, 6, 4, 2,
        1, 2, 0, -3
    ], inf),
    \dur, Pseq([
        1.5, 0.5, 1.0, 1.0,
        1.0, 1.0, 0.75, 1.25,
        1.5, 0.5, 1.0, 1.0,
        0.75, 0.75, 1.5, 1.0
    ], inf),
    \vowel, Pseq([0.1, 0.8, 1.5, 0.4, 1.1, 1.8], inf),
    \brightness, Pwhite(1500, 2600, inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \amp, Pseq([0.18, 0.15, 0.19, 0.16], inf)
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\seqCantoRosario);
)

// Live-coding performance tweaks & rollbacks:
// Ndef(\gungasLata).xset(\spread, 0.95, \wet10, 0.42); // Widen ankle-rattle procession | Revert: Ndef(\gungasLata).xset(\spread, 0.65, \wet10, 0.24);
// Ndef(\cantoRosario).xset(\brightness, 3200, \wet10, 0.55); // Open devotion choir & cathedral space | Revert: Ndef(\cantoRosario).xset(\brightness, 1900, \wet10, 0.36);
// Pbindef(\seqGungasLata, \dur, Pn(Pgeom(0.25, 0.88, 6), inf)); // Accelerating Moçambique step | Revert: Pbindef(\seqGungasLata, \dur, Pseq([0.25, 0.25, 0.25, 0.25], inf));
// Pbindef(\seqCaixaCongo).stop; Ndef(\caixaCongo).clear(4); // Rollback Layer 1
// Pbindef(\seqGungasLata).stop; Ndef(\gungasLata).clear(4); // Rollback Layer 2
// Pbindef(\seqCantoRosario).stop; Ndef(\cantoRosario).clear(4); // Rollback Layer 3

