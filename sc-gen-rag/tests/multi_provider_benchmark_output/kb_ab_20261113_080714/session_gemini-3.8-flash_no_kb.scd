// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-13T11:07:18.715925+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// --- ADD_INSTRUMENT: Cold antarctic silence & suspended tension ---
// Form: Intrinsic Limit (b) - Dense sub-zero stillness meeting brittle paper folding friction

Ndef(\antarcticDrone, { |freq=48, amp=0.28, subMix=0.6, rumble=0.4, freeze=0.2|
    var wind, subs, tension, sig;
    wind = BPF.ar(WhiteNoise.ar, freq * [1.5, 2.1, 4.2], 0.08).sum * 8.0;
    subs = SinOsc.ar(freq * [1, 1.005]) + (SinOsc.ar(freq * 0.5) * subMix);
    subs = (subs * 1.5).tanh;
    tension = Ringz.ar(Dust.ar(freeze * 12 + 0.5), freq * [8, 12.3], 0.4).sum * 0.15;
    sig = (subs * (1 - rumble)) + (wind * rumble) + tension;
    LeakDC.ar(sig) * amp;
}).play;

Ndef(\mapFriction, { |freq=2400, amp=0.22, pan=0, t_trig=0, crackle=0.7, ringTime=0.15|
    var tr = K2A.ar(t_trig);
    var exciter = Decay2.ar(tr, 0.001, 0.04) * WhiteNoise.ar;
    var paperFold = BPF.ar(exciter * 4.0, freq * [0.8, 1.1, 1.6], 0.12).sum;
    var glassWait = Ringz.ar(exciter * 0.4, freq * 2.1, ringTime) * 0.3;
    var sig = (paperFold * crackle) + (glassWait * (1 - crackle));
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFrictionSeq,
    \dur, Pseq([0.75, 1.5, 0.25, 0.5, 2.0, 0.5, 3.0], inf),
    \t_trig, 1,
    \freq, Pseq([1800, 2600, 3200, 1400, 4200], inf),
    \crackle, Pseq([0.9, 0.8, 0.4, 0.95, 0.3], inf),
    \ringTime, Pseq([0.08, 0.12, 0.4, 0.05, 0.6], inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \amp, Pwhite(0.12, 0.24, inf)
);

Ndef(\mapFriction)[1] = \set -> Pbindef(\mapFrictionSeq);

// Reversion / Rollback
// Pbindef(\mapFrictionSeq).stop; Ndef(\mapFriction).fadeTime = 2; Ndef(\mapFriction).clear(2);
// Ndef(\antarcticDrone).fadeTime = 3; Ndef(\antarcticDrone).clear(3);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// --- ADD_INSTRUMENT & ADD_EFFECTS: O Navio Negreiro (Castro Alves) ---
// Form: Intrinsic Limit (b) driven towards tragic resolution.
// Rhythmic whip-cracks (açoite), resonant clanking chains (tinir de ferros), and blood-red harmonic distortion.

Ndef(\chainIron, { |freq=587, amp=0.28, pan=0, t_trig=0, strikeDecay=0.6, metalBright=3200|
    var tr = K2A.ar(t_trig);
    var whip = WhiteNoise.ar * Decay2.ar(tr, 0.0005, 0.025) * 4.5;
    var metalImp = (Impulse.ar(0) * tr) + (PinkNoise.ar * Decay.ar(tr, 0.005));
    var chainModes = DynKlank.ar(`[
        freq * [1, 2.34, 3.89, 5.72, 7.31],
        [0.8, 0.6, 0.45, 0.3, 0.15],
        [strikeDecay, strikeDecay * 0.8, strikeDecay * 0.5, strikeDecay * 0.3, strikeDecay * 0.2]
    ], metalImp);
    var snap = HPF.ar((whip * 3.0).fold2(0.6), 1800);
    var body = BPF.ar(chainModes, metalBright, 0.3) * 6.0;
    var sig = (snap * 0.7) + (body * 0.9);
    Pan2.ar(LeakDC.ar(sig) * amp, pan);
}).play;

Pbindef(\chainIronSeq,
    \dur, Pseq([0.375, 0.125, 0.25, 0.75, 0.5, 0.25, 0.25, 1.0], inf),
    \t_trig, 1,
    \freq, Pseq([320, 290, 480, 240, 560, 210, 680, 180], inf),
    \metalBright, Pseq([2400, 4800, 3100, 1900, 5600], inf),
    \strikeDecay, Pseq([0.4, 0.15, 0.9, 0.3, 1.4, 0.2], inf),
    \pan, Pseq([-0.6, 0.4, -0.2, 0.7, -0.5, 0.1], inf),
    \amp, Pseq([0.28, 0.35, 0.22, 0.4, 0.3, 0.32], inf)
);

Ndef(\chainIron)[1] = \set -> Pbindef(\chainIronSeq);

// Distort previous antarctic drone into ocean brine and bloody resonance
Ndef(\antarcticDrone)[10] = \filter -> { |in|
    var drive = 3.5;
    var blood = LeakDC.ar(((in * drive) + 0.15).tanh);
    var swell = blood * SinOsc.kr(0.12).range(0.6, 1.2);
    swell;
};
Ndef(\antarcticDrone).xset(\wet10, 0.85);

// Reversion / Rollback:
// Pbindef(\chainIronSeq).stop; Ndef(\chainIron).fadeTime = 2; Ndef(\chainIron).clear(2); // Rollback: remove this instrument
// Ndef(\antarcticDrone).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockRatios;

    // --- Safety Limiter ---
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // --- Discrete Instruments: Brass Ticks, Escapements & French Chimes ---
    SynthDef(\brassTick, { |out=0, freq=3400, amp=0.15, pan=0, hardness=0.8, decayTime=0.035|
        var click = Impulse.ar(0) * 1.5;
        var noise = WhiteNoise.ar * Decay.ar(Impulse.ar(0), 0.002) * hardness;
        var exciter = click + noise;
        var body = DynKlank.ar(`[
            freq * [1, 2.76, 5.41, 8.92],
            [1.0, 0.6, 0.3, 0.15],
            [decayTime, decayTime * 0.7, decayTime * 0.4, decayTime * 0.2]
        ], exciter);
        var bite = HPF.ar(exciter * 4.0, 4000);
        var sig = (body * 0.8) + (bite * 0.4);
        var env = EnvGen.ar(Env.perc(0.0005, decayTime * 1.5), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\frenchChime, { |out=0, freq=660, amp=0.18, pan=0, strike=0.8, ring=2.8|
        var tr = Impulse.ar(0);
        var hammer = Decay2.ar(tr, 0.001, 0.012) * PinkNoise.ar * strike;
        var res = DynKlank.ar(`[
            freq * [1, 2.012, 3.004, 4.21, 5.88],
            [0.7, 0.5, 0.35, 0.2, 0.1],
            [ring, ring * 0.85, ring * 0.6, ring * 0.4, ring * 0.25]
        ], hammer);
        var warmth = BPF.ar(res, freq * 1.5, 0.5) * 1.8;
        var env = EnvGen.ar(Env.perc(0.002, ring), doneAction: 2);
        var sig = (warmth + (res * 0.5)) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\pocketWatch, { |out=0, freq=4800, amp=0.1, pan=0, grit=0.5|
        var click = Dust2.ar(30) * Decay.ar(Impulse.ar(0), 0.008);
        var gear = Ringz.ar(click, freq * [1, 1.48, 2.12], 0.015).sum;
        var env = EnvGen.ar(Env.perc(0.0002, 0.02), doneAction: 2);
        var sig = (gear * (1 + (grit * 2.0))).fold2(0.5) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // --- Continuous Textures: The 200 Pendulums & The Collective Breathing of Time ---
    Ndef(\pendulumSwarm, { |amp=0, baseFreq=0.85, phaseSpread=1.0, friction=0.4|
        var lfos, pendulumClicks, metalDrones, sig;
        lfos = Array.fill(8, { |i|
            var rate = (baseFreq * (1 + (i * 0.03125))).clip(0.1, 8.0);
            LFPulse.ar(rate, width: 0.015)
        });
        pendulumClicks = lfos.collect({ |trig, i|
            var f = 1200 + (i * 260);
            Ringz.ar(trig, f, 0.02) * 0.3
        }).sum;
        metalDrones = lfos.collect({ |trig, i|
            var f = 82 * (i + 1);
            CombC.ar(trig, 0.05, f.reciprocal.clip(0.0005, 0.04), 0.6) * 0.15
        }).sum;
        sig = (pendulumClicks * 0.7) + (metalDrones * friction);
        Splay.ar(sig * amp, 0.75);
    });

    Ndef(\timeRespiration, { |amp=0, lungRate=0.11, brassTone=180, flutter=0.3|
        var breathLFO = SinOsc.kr(lungRate).range(0.2, 1.0);
        var gearBed = PinkNoise.ar(0.3) + BPF.ar(BrownNoise.ar, brassTone * [1, 2, 3], 0.08).sum * 8.0;
        var brassDrone = SinOsc.ar(brassTone * [1, 1.006]) * 0.3;
        var fluttering = SinOsc.ar(SinOsc.kr(4.5).range(12, 28)) * flutter;
        var sig = (gearBed + brassDrone) * breathLFO * (1 + fluttering);
        var panPos = SinOsc.kr(0.07).range(-0.5, 0.5);
        sig = LeakDC.ar(sig);
        if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], panPos, amp) } { Pan2.ar(sig, panPos, amp) };
    });

    // --- Master Bus & Subtle Reverberation of the Narrow Workshop ---
    Ndef(\masterMix, {
        var discrete = In.ar(~synthBus, 2);
        var swarm = Ndef(\pendulumSwarm).ar;
        var lung = Ndef(\timeRespiration).ar;
        discrete + swarm + lung;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 0.75, 0.65, 0.15);
    };
    Ndef(\masterMix).set(\wet10, 0.22);
    Ndef(\masterMix).play;

    s.sync;

    // --- Pattern Sequences (Micro-Phase Polyrhythms) ---
    clockRatios = [0.125, 0.128, 0.122, 0.130, 0.124];

    Pbindef(\frenchChimesSeq,
        \instrument, \frenchChime,
        \out, ~synthBus,
        \dur, Pseq([3.5, 2.75, 4.0, 1.25, 3.0, 2.5], inf),
        \freq, Pseq([523.25, 659.25, 783.99, 587.33, 440.0], inf),
        \strike, Pwhite(0.5, 0.9, inf),
        \ring, Pwhite(2.2, 4.0, inf),
        \pan, Pwhite(-0.6, 0.6, inf),
        \amp, 0.18
    );

    Pbindef(\brassClockTicks,
        \instrument, \brassTick,
        \out, ~synthBus,
        \dur, Pseq([0.125, 0.126, 0.124, 0.125, 0.127, 0.123, 0.25], inf),
        \freq, Pseq([2800, 3200, 3600, 4100, 2900, 3800], inf),
        \hardness, Pwhite(0.6, 0.95, inf),
        \decayTime, Pseq([0.02, 0.04, 0.025, 0.06], inf),
        \pan, Pseq([-0.7, 0.7, -0.4, 0.4, -0.1, 0.1], inf),
        \amp, 0.14
    );

    Pbindef(\pocketWatchesSeq,
        \instrument, \pocketWatch,
        \out, ~synthBus,
        \dur, Pseq([0.0625, 0.063, 0.062, 0.064], inf),
        \freq, Pseq([4400, 5200, 4800, 5600, 6000], inf),
        \grit, Pwhite(0.3, 0.8, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \amp, 0.08
    );

    // --- Master Chronological Score ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [A Oficina de Santa Efigênia: Primeiros Tique-Taques Solitários]".postln;
        Ndef(\masterMix).set(\wet10, 0.18);
        Pbindef(\brassClockTicks).play;
        1.5.wait;

        "0:04 - [Entram os Cronômetros de Bolso e Desfasagens Finas]".postln;
        Pbindef(\pocketWatchesSeq).play;
        Ndef(\pendulumSwarm).fadeTime = 3;
        Ndef(\pendulumSwarm).set(\amp, 0.22, \baseFreq, 1.0, \friction, 0.25);

        3.do { |idx|
            var nudge = (idx + 1) * 0.002;
            Pbindef(\brassClockTicks, \dur, Pseq([0.125 + nudge, 0.124 - nudge, 0.126], inf));
            2.5.wait;
        };

        "0:12 - [Carrilhões Franceses Soam ao Fundo da Sala Estreita]".postln;
        Pbindef(\frenchChimesSeq).play;
        Ndef(\timeRespiration).fadeTime = 5;
        Ndef(\timeRespiration).set(\amp, 0.25, \lungRate, 0.12, \brassTone, 146.8);

        4.do { |idx|
            var sweep = 146.8 + (idx * 22);
            Ndef(\timeRespiration).xset(\brassTone, sweep, \flutter, 0.2 + (idx * 0.08));
            3.0.wait;
        };

        "0:24 - [Enxame Total: 200 Pêndulos em Polirritmia Desencontrada]".postln;
        Ndef(\pendulumSwarm).xset(\amp, 0.42, \baseFreq, 1.4, \friction, 0.65);
        Pbindef(\brassClockTicks, \amp, 0.20, \decayTime, Pwhite(0.015, 0.08, inf));
        Pbindef(\pocketWatchesSeq, \amp, 0.14);
        Ndef(\masterMix).set(\wet10, 0.32);

        3.do { |idx|
            Pbindef(\pocketWatchesSeq, \dur, Pseq([0.06 - (idx * 0.005), 0.065 + (idx * 0.004)], inf));
            Pbindef(\frenchChimesSeq, \strike, 0.95, \ring, 3.8);
            3.5.wait;
        };

        "0:35 - [O Relojoeiro Fecha os Olhos: O Respirar do Latão]".postln;
        // Intrinsic Limit & Settling: Damping the clicks, magnifying the macroscopic lung
        Pbindef(\brassClockTicks, \amp, 0.05);
        Pbindef(\pocketWatchesSeq, \amp, 0.03);
        Ndef(\pendulumSwarm).xset(\amp, 0.15, \friction, 0.1);
        Ndef(\timeRespiration).fadeTime = 4;
        Ndef(\timeRespiration).xset(\amp, 0.48, \lungRate, 0.08, \brassTone, 110.0, \flutter, 0.5);
        Ndef(\masterMix).set(\wet10, 0.45);

        4.do { |idx|
            Ndef(\timeRespiration).xset(\lungRate, 0.07 - (idx * 0.01));
            2.5.wait;
        };

        "0:45 - [Desvanecimento Final nas Engrenagens]".postln;
        Pbindef(\pocketWatchesSeq).stop;
        Pbindef(\pocketWatchesSeq).clear;
        Pbindef(\frenchChimesSeq).stop;
        Pbindef(\frenchChimesSeq).clear;
        Pbindef(\brassClockTicks, \amp, 0.02);

        Ndef(\pendulumSwarm).fadeTime = 4;
        Ndef(\pendulumSwarm).set(\amp, 0);
        Ndef(\timeRespiration).fadeTime = 5;
        Ndef(\timeRespiration).set(\amp, 0);

        4.0.wait;
        Pbindef(\brassClockTicks).stop;
        Pbindef(\brassClockTicks).clear;

        Ndef(\pendulumSwarm).clear(1);
        Ndef(\timeRespiration).clear(1);
        Ndef(\masterMix).clear(1);

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
    // --- Architecture & Setup ---
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

    // --- Sound Synthesis: Acoustic & Mineral Physics of Maquiné ---
    // Water drop hitting calcareous rock pools: liquid impact + pitch bend
    SynthDef(\caveDrop, {
        |out=0, freq=1600, endFreq=450, dripDecay=0.22, pan=0.0, amp=0.25|
        var pitchenv = EnvGen.ar(Env([freq, endFreq * 1.3, endFreq], [0.008, dripDecay], \exp));
        var ampenv = EnvGen.ar(Env.perc(0.002, dripDecay, amp, -4), doneAction: 2);
        var bubble = SinOsc.ar(pitchenv) * ampenv;
        var click = HPF.ar(PinkNoise.ar, 2500) * EnvGen.ar(Env.perc(0.0005, 0.005));
        var sig = Pan2.ar(bubble + (click * 0.4), pan);
        Out.ar(out, sig);
    }).add;

    // Resonant stalactite strike: modal synthesis via DynKlank
    SynthDef(\stalactiteRing, {
        |out=0, freq=440, decay=2.8, pan=0.0, amp=0.2, brightness=1.0|
        var trigger = Impulse.ar(0);
        var exciter = (Decay.ar(trigger, 0.004) * WhiteNoise.ar * brightness)
                    + (Decay.ar(trigger, 0.015) * SinOsc.ar(freq * 0.5));
        var freqs = [freq, freq * 1.98, freq * 3.44, freq * 5.12];
        var amps = [1.0, 0.5, 0.28, 0.12];
        var rings = [decay, decay * 0.8, decay * 0.5, decay * 0.3];
        var modal = DynKlank.ar(Ref([freqs, amps, rings]), exciter, freqscale: 1.0, decayscale: 1.0);
        var ampenv = EnvGen.ar(Env.linen(0.001, decay.max(0.1), 0.1, 1.0), doneAction: 2);
        var sig = Pan2.ar(modal * ampenv * 0.18 * amp, pan);
        Out.ar(out, sig);
    }).add;

    // Calcified air gust / underground pressure pulse
    SynthDef(\abyssalGust, {
        |out=0, dur=4.5, freq=75, pan=0.0, amp=0.25|
        var env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);
        var noise = PinkNoise.ar;
        var filtered = MoogFF.ar(noise, freq + (env * 60), 3.2) * 4.0;
        var sub = SinOsc.ar(freq * 0.5) * 0.5;
        var sig = Pan2.ar((filtered.tanh + sub) * env, pan);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // --- Continuous Textures (Ndefs) ---
    // Deep vault air circulation through limestone halls
    Ndef(\vaultResonance, {
        |amp=0.0, filterFreq=180, resQ=0.04|
        var noise = BPF.ar(BrownNoise.ar, [filterFreq, filterFreq * 1.48], resQ) * 14.0;
        var slowAir = SinOsc.kr(0.08).range(0.4, 1.0);
        var subAir = SinOsc.ar([46.25, 46.5]) * 0.35;
        (noise * slowAir + subAir) * amp;
    });

    // Mineral seepage: subtle granular percolation on damp limestone walls
    Ndef(\mineralSeepage, {
        |amp=0.0, density=6, tone=2200|
        var trig = Dust.ar([density, density * 1.15]);
        var gran = Ringz.ar(trig * 0.2, tone + TRand.ar(-300, 400, trig), 0.08);
        var filtered = HPF.ar(gran, 600) * amp;
        filtered.tanh;
    });

    // Master JITLib Mixer & Reverb (Seven Subterranean Chambers of Maquiné)
    Ndef(\masterMix, {
        var synthSig = In.ar(~synthBus, 2);
        var vault = Ndef(\vaultResonance).ar;
        var seep = Ndef(\mineralSeepage).ar;
        synthSig + vault + seep;
    });

    // 100% wet long cave reverberation slot
    Ndef(\masterMix)[10] = \filter -> {
        |in|
        var rev = GVerb.ar(in.sum, 240, 6.5, 0.45, 0.7, 15, -9.dbamp, -11.dbamp, -16.dbamp);
        rev;
    };

    Ndef(\masterMix).set(\wet10, 0.48);
    Ndef(\masterMix).play;

    s.sync;

    // --- Algorithmic Score Patterns ---
    // Rhythmic, irregular water droplets falling from high mineral vaults
    Pbindef(\waterDrops,
        \instrument, \caveDrop,
        \out, ~synthBus,
        \dur, Pseq([0.35, 0.7, 1.1, 0.25, 0.45, 0.9, 1.4, 0.3], inf),
        \freq, Pexprand(1200, 2800, inf),
        \endFreq, Pexprand(350, 650, inf),
        \dripDecay, Pwhite(0.12, 0.32, inf),
        \pan, Pwhite(-0.75, 0.75, inf),
        \amp, 0.28
    );

    // Stiff resonant stalactite bell pitches (limestone lithophone)
    Pbindef(\stalactites,
        \instrument, \stalactiteRing,
        \out, ~synthBus,
        \dur, Pseq([2.2, 1.6, 2.8, 3.4, 1.2, 2.5], inf),
        \freq, Pseq([174.61, 220.0, 261.63, 329.63, 392.0, 523.25, 659.25], inf),
        \decay, Pwhite(2.5, 4.2, inf),
        \pan, Pwhite(-0.6, 0.6, inf),
        \amp, 0.22,
        \brightness, Pwhite(0.6, 1.2, inf)
    );

    // Sudden acoustic gusts passing between chamber thresholds
    Pbindef(\chamberWind,
        \instrument, \abyssalGust,
        \out, ~synthBus,
        \dur, Pseq([7.0, 9.5, 8.2], inf),
        \freq, Pseq([55, 68, 82, 48], inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \amp, 0.35
    );

    // --- Master Chronological Score (Total Duration: ~105s) ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Salão I: Descida à Gruta do Maquiné - O gotejamento solitário]".postln;
        Ndef(\masterMix).set(\wet10, 0.52);
        Pbindef(\waterDrops).play;

        // Active micro-modulations of drop intervals
        4.do { |idx|
            Ndef(\vaultResonance).fadeTime = 3;
            Ndef(\vaultResonance).set(\amp, 0.08 * (idx + 1), \filterFreq, 120 + (idx * 30));
            2.5.wait;
        };

        "0:10 - [Salão II & III: O Respiro das Abóbadas e Secreção Mineral]".postln;
        Ndef(\mineralSeepage).fadeTime = 4;
        Ndef(\mineralSeepage).set(\amp, 0.22, \density, 7, \tone, 2400);
        Pbindef(\chamberWind).play;

        3.do { |idx|
            Pbindef(\waterDrops, \amp, 0.32 + (idx * 0.04));
            3.0.wait;
        };

        "0:19 - [Salão IV: O Litofone Natural - Lund escuta o mineral vibrar]".postln;
        Pbindef(\stalactites).play;
        Ndef(\masterMix).set(\wet10, 0.62);

        4.do { |idx|
            Ndef(\vaultResonance).xset(\filterFreq, 160 + (idx * 45), \resQ, 0.035);
            Ndef(\mineralSeepage).xset(\density, 10 + (idx * 3));
            3.2.wait;
        };

        "0:32 - [Salão V: Salão do Elefante - Cortinas de Calcário em Plena Ressonância]".postln;
        // Intrinsic Limit (b): High density and cavernous ring saturation
        Ndef(\vaultResonance).fadeTime = 3;
        Ndef(\vaultResonance).xset(\amp, 0.42, \filterFreq, 310);
        Pbindef(\waterDrops, \dur, Pseq([0.15, 0.25, 0.18, 0.32, 0.12], inf), \amp, 0.38);
        Pbindef(\stalactites, \dur, Pseq([0.8, 1.2, 0.6, 1.4, 0.9], inf), \amp, 0.28);
        Ndef(\masterMix).set(\wet10, 0.72);

        4.do { |idx|
            Ndef(\mineralSeepage).xset(\tone, 1800 + (idx * 300));
            3.5.wait;
        };

        "0:46 - [Salão VI: O Salão do Trono - O Vento Subterrâneo Transversal]".postln;
        Pbindef(\chamberWind, \dur, Pseq([4.0, 5.2, 4.8], inf), \amp, 0.45);
        3.do { |idx|
            Pbindef(\stalactites, \freq, Pseq([130.81, 196.0, 261.63, 392.0] * (1 + (idx * 0.1)), inf));
            3.2.wait;
        };

        "0:56 - [Settling (c): O Silêncio Mineral e a Luz das Tochas de Lund]".postln;
        // Settling: drop wind and rapid drops; leave only deep resonance and isolated stalactite pings
        Pbindef(\chamberWind).stop;
        Pbindef(\waterDrops, \dur, Pseq([1.8, 2.4, 3.1, 1.6], inf), \amp, 0.24);
        Pbindef(\stalactites, \dur, Pseq([3.8, 4.5, 5.0], inf), \amp, 0.2);
        Ndef(\mineralSeepage).fadeTime = 5;
        Ndef(\mineralSeepage).set(\amp, 0.08, \density, 4);
        Ndef(\vaultResonance).fadeTime = 6;
        Ndef(\vaultResonance).xset(\amp, 0.25, \filterFreq, 140);
        Ndef(\masterMix).set(\wet10, 0.55);

        4.do { |idx|
            Pbindef(\waterDrops, \freq, Pexprand(900, 1800, inf));
            3.5.wait;
        };

        "1:10 - [Salão VII: O Fim da Galeria Escavada - Resolução Final]".postln;
        // Resolution (a): Return to foundational low droplet rhythm in immense darkness
        Pbindef(\stalactites).stop;
        Pbindef(\stalactites).clear;
        Ndef(\mineralSeepage).fadeTime = 4;
        Ndef(\mineralSeepage).set(\amp, 0.0);

        3.do { |idx|
            Ndef(\vaultResonance).xset(\amp, 0.20 - (idx * 0.06));
            Pbindef(\waterDrops, \amp, 0.22 - (idx * 0.05));
            3.0.wait;
        };

        "1:19 - [Extrinsic Limit (d): O Abismo Retorna ao Silêncio Absoluto]".postln;
        Pbindef(\waterDrops).stop;
        Pbindef(\waterDrops).clear;
        Pbindef(\chamberWind).clear;

        Ndef(\vaultResonance).fadeTime = 5;
        Ndef(\vaultResonance).set(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.2);

        5.0.wait;

        // Scoped cleanup of exact named objects
        Ndef(\vaultResonance).clear(1);
        Ndef(\mineralSeepage).clear(1);
        Ndef(\masterMix).clear(1);

        "Score Complete: A Gruta do Maquiné repousa na escuridão.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

