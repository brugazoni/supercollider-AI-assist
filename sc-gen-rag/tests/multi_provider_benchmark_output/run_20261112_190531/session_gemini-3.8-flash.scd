// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T22:05:33.180927+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Suspended stillness and dry, tense friction (the road map fold & Antarctic storm brewing)
Ndef(\frozenTension, { |freq=54, amp=0.28, tension=1.2, foldAmt=0.8, pan=0, t_trig=0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.02, 1.8, 1, -4), trig);
    var sub = SinOsc.ar([freq, freq * 1.005]);
    var subHarm = SinOsc.ar(freq * 2) * 0.25;
    var paperCrease = BPF.ar(WhiteNoise.ar, freq * 18 * tension, 0.08) * Decay2.ar(trig, 0.002, 0.06) * 6.0;
    var antarcticWind = HPF.ar(PinkNoise.ar(0.15), 180) * SinOsc.kr(0.08).range(0.2, 0.8);
    var sig = (sub + subHarm + paperCrease + antarcticWind);
    sig = Fold.ar(sig * (1 + (foldAmt * env * 2)), -0.85, 0.85);
    sig = LeakDC.ar(sig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp * 0.7) } { Pan2.ar(sig, pan, amp * 0.7) } + (env * amp * 0.3);
}).play;

Pbindef(\seqFrozen,
    \dur, Pseq([3.5, 2.5, 4.0, 1.5, 5.0], inf),
    \midinote, Pseq([30, 30, 31, 30, 29], inf),
    \tension, Pseq([1.0, 1.2, 2.5, 1.1, 3.2], inf),
    \foldAmt, Pwhite(0.4, 0.9, inf),
    \amp, Pwhite(0.22, 0.32, inf),
    \pan, Pseq([0, -0.15, 0.15, -0.05, 0.05], inf),
    \t_trig, 1
);

Ndef(\frozenTension)[1] = \set -> Pbindef(\seqFrozen);

// ADD_EFFECTS: Resonant cold space (wine bottle suspended in air)
Ndef(\frozenTension)[10] = \filter -> { |in|
    var wet = CombC.ar(in, 0.5, [0.24, 0.29], 3.2);
    LPF.ar(wet, 1600);
};
Ndef(\frozenTension).set(\wet10, 0.35);

// Pbindef(\seqFrozen).stop; Ndef(\frozenTension).fadeTime = 2; Ndef(\frozenTension).clear(2); // Rollback: remove this instrument
// Ndef(\frozenTension).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: FIXED
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: "Navio Negreiro" — Clanging iron chains, whip cracks, and cavernous lamentation
Ndef(\slaveShipChains, { |freq=48, amp=0.35, whipDrive=3.0, chainRes=1200, pan=0, t_trig=0|
    var trig = K2A.ar(t_trig);
    var metalEnv = EnvGen.ar(Env.perc(0.001, 1.2, 1, -6), trig);
    var whipEnv = EnvGen.ar(Env.perc(0.0005, 0.08, 1, -8), trig);
    var whip, chainModes, groanMod, hullGroan, sig;
    // Whip crack: aggressive high-passed noise burst through saturation
    whip = HPF.ar(WhiteNoise.ar, 1800) * whipEnv * whipDrive;
    whip = (whip * 4.0).clip2(0.9);
    // Tinir de ferros: inharmonic resonant modes of metal links & shackles
    chainModes = DynKlank.ar(
        `[
            [840, 1190, 1680, 2340, 3120] * (chainRes / 1000),
            [0.6, 0.4, 0.5, 0.3, 0.2],
            [0.6, 0.9, 0.4, 0.7, 0.3]
        ],
        Impulse.ar(0) + (whip * 0.4) + (PinkNoise.ar(0.08) * metalEnv),
        decayscale: 1.4
    );
    // Groaning ship hull and desperate cry (dark deep FM drone)
    groanMod = SinOsc.ar(freq * 0.75) * freq * 1.8;
    hullGroan = SinOsc.ar(freq + groanMod) * Decay2.ar(trig, 0.1, 2.8) * 0.4;
    sig = whip + chainModes + hullGroan;
    sig = LeakDC.ar(sig.tanh);
    Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\seqChains,
    \dur, Pseq([0.75, 0.25, 0.5, 1.5, 0.5, 1.0], inf),
    \chainRes, Pseq([1100, 1450, 980, 1800, 1320, 850], inf),
    \freq, Pseq([42, 38, 45, 36, 40, 35], inf),
    \whipDrive, Pseq([2.5, 4.5, 1.8, 5.0, 2.0, 3.8], inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pexprand(0.28, 0.45, inf),
    \t_trig, 1
);

Ndef(\slaveShipChains)[1] = \set -> Pbindef(\seqChains);

// ADD_EFFECTS: Vast, abyssal ocean hold (cavernous cavern reverb soaked in blood and salt)
Ndef(\slaveShipChains)[10] = \filter -> { |in|
    var rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.35);
    rev + DelayC.ar(rev, 0.4, [0.27, 0.33] * SinOsc.kr(0.05).range(0.98, 1.02));
};
Ndef(\slaveShipChains).set(\wet10, 0.45);

// Pbindef(\seqChains).stop; Ndef(\slaveShipChains).fadeTime = 2; Ndef(\slaveShipChains).clear(2); // Rollback: remove this instrument
// Ndef(\slaveShipChains).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockRatios;

    // Safety Bus & Limiter Configuration
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

    // SynthDef 1: Escapement Mechanism (Brass Gear Clicks & Pinion Strikes)
    SynthDef(\escapementTick, { |out=0, freq=3200, res=0.2, clickLen=0.015, bodyLen=0.04, amp=0.25, pan=0, springLoss=0.1|
        var impulse = Impulse.ar(0);
        var click = HPF.ar(WhiteNoise.ar, 2400) * EnvGen.ar(Env.perc(0.0002, clickLen, 1, -8));
        var gear = Ringz.ar(impulse + (click * 0.4), [freq, freq * 1.62, freq * 2.41], [bodyLen, bodyLen * 0.6, bodyLen * 0.3], [0.6, 0.3, 0.15]).sum;
        var brassCase = BPF.ar(PinkNoise.ar, freq * 0.5, 0.25) * EnvGen.ar(Env.perc(0.001, bodyLen * 1.8));
        var sig = (click * 1.5) + (gear * 0.8) + (brassCase * 0.4);
        sig = sig * EnvGen.ar(Env.perc(0.0005, bodyLen * 2.2, 1, -6), doneAction: 2);
        sig = (sig * (1 + (springLoss * 2))).tanh;
        OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // SynthDef 2: French Pendulum Chime (Inharmonic Bell Rods)
    SynthDef(\carrilhaoRod, { |out=0, freq=440, decay=2.2, strike=1.0, amp=0.2, pan=0|
        var hammer = Decay.ar(Impulse.ar(0), 0.002) * (HPF.ar(WhiteNoise.ar, 1800) * strike);
        var modes = DynKlank.ar(
            Ref([
                freq * [1.0, 2.76, 5.4, 8.9],
                [1.0, 0.45, 0.25, 0.12],
                decay * [1.0, 0.65, 0.4, 0.2]
            ]),
            hammer + (Impulse.ar(0) * 0.8),
            decayscale: decay
        );
        var subHarm = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.01, decay * 0.8)) * 0.15;
        var sig = (modes * 0.6) + subHarm;
        sig = sig * EnvGen.ar(Env.perc(0.002, (decay * 1.2).max(0.1), 1, -5), doneAction: 2);
        OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // SynthDef 3: Pocket Chronometer Palette Jewels (Glassy High-Frequency Escapement)
    SynthDef(\rubyPalette, { |out=0, freq=6800, amp=0.18, pan=0, dur=0.035|
        var excit = HPF.ar(Dust2.ar(4000), 4500) * EnvGen.ar(Env.perc(0.0001, 0.004));
        var jewel = Ringz.ar(excit + (Impulse.ar(0) * 0.3), [freq, freq * 1.48], [dur, dur * 0.5], [0.7, 0.3]).sum;
        var sig = jewel * EnvGen.ar(Env.perc(0.0002, dur, 1, -7), doneAction: 2);
        OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    s.sync;

    // Continuous Ndef: The Collective Brass Swarm (200 Unsynchronized Pulleys and Cogs)
    Ndef(\brassSwarm, { |amp=0, speed=1.0, breathRate=0.08, spread=0.8, filtCut=2200|
        var pulseGen = Array.fill(8, { |i|
            var detuneRate = (0.75 + (i * 0.093)) * speed;
            var t = LFPulse.ar(detuneRate, 0, 0.02);
            var gearNoise = BPF.ar(WhiteNoise.ar, (1200 + (i * 380)), 0.12) * Decay.ar(t, 0.018);
            var rodChirp = SinOsc.ar(1800 + (i * 420)) * Decay2.ar(t, 0.001, 0.008) * 0.25;
            Pan2.ar(gearNoise + rodChirp, (i / 3.5 - 1.0) * spread)
        }).sum;
        var grandBreath = SinOsc.kr(breathRate).range(0.25, 1.0);
        var subSway = SinOsc.ar([48, 48.4]) * (0.15 * grandBreath);
        var filtered = LPF.ar(pulseGen, filtCut * grandBreath.range(0.6, 1.4));
        var sig = (filtered * 0.45) + subSway;
        LeakDC.ar(sig) * amp;
    });

    // Master Mixer and Spatial Reverb
    Ndef(\masterMix, {
        var discrete = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\brassSwarm, 2);
        discrete + continuous;
    });

    // Workshop Acoustics (Ladeira de Santa Efigênia Narrow Stone & Wood Shop)
    Ndef(\masterMix)[10] = \filter -> { |in|
        var early = AllpassC.ar(in, 0.04, [0.014, 0.021], 0.25);
        var rev = FreeVerb2.ar(early[0], early[1], 1.0, 0.72, 0.45);
        rev;
    };
    Ndef(\masterMix).set(\wet10, 0.22);
    Ndef(\masterMix).play;

    s.sync;

    // Chronological Score: 100 seconds narrative arc
    Tdef(\masterScore, {
        0.5.wait;

        // Cue 1: 0:00 - The Pocket Watches Awake (Staccato Polyrhythms)
        "0:00 - [Cue 1: Ladeira de Santa Efigenia - Descompasso dos cronometros]".postln;
        Ndef(\brassSwarm).fadeTime = 6;
        Ndef(\brassSwarm).xset(\amp, 0.12, \speed, 1.0, \breathRate, 0.06, \filtCut, 1600);

        Pbindef(\pockWatchA,
            \instrument, \rubyPalette,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.124, 0.126, 0.123], inf),
            \freq, Pseq([6400, 6800, 7200, 6100], inf),
            \amp, Pwhite(0.12, 0.2, inf),
            \pan, Pwhite(-0.7, -0.2, inf)
        ).play;

        Pbindef(\pockWatchB,
            \instrument, \rubyPalette,
            \out, ~synthBus,
            \dur, Pseq([0.165, 0.168, 0.162], inf),
            \freq, Pseq([5800, 6200, 5600], inf),
            \amp, Pwhite(0.1, 0.18, inf),
            \pan, Pwhite(0.2, 0.8, inf)
        ).play;

        // Active Micro-Evolutions: Defasagem Progressiva
        4.do { |idx|
            Ndef(\brassSwarm).xset(\filtCut, 1600 + (idx * 250));
            2.5.wait;
        };

        // Cue 2: 0:10 - Escapement Swarm (French Carrilhões & Grandfather Clocks Enter)
        "0:10 - [Cue 2: Duzentos relogios - Enxame de engrenagens de latao]".postln;
        Pbindef(\pendulums,
            \instrument, \escapementTick,
            \out, ~synthBus,
            \dur, Pseq([0.495, 0.508, 0.498, 0.502], inf),
            \freq, Pseq([2800, 3400, 2200, 3100], inf),
            \bodyLen, Pseq([0.03, 0.05, 0.04, 0.06], inf),
            \springLoss, Pwhite(0.05, 0.25, inf),
            \amp, Pwhite(0.18, 0.28, inf),
            \pan, Pseq([-0.4, 0.4, -0.2, 0.2], inf)
        ).play;

        Ndef(\brassSwarm).xset(\amp, 0.24, \speed, 1.15, \breathRate, 0.08);

        6.do { |idx|
            Pbindef(\pendulums, \freq, Pseq([2600 + (idx * 120), 3200 - (idx * 80), 2400 + (idx * 90)], inf));
            2.0.wait;
        };

        // Cue 3: 0:22 - Carrilhões Franceses (Chimes in Distant Harmonic Micro-Phasing)
        "0:22 - [Cue 3: Carrilhoes Franceses - O som metalico das horas desfasadas]".postln;
        Ndef(\masterMix).set(\wet10, 0.38);

        Pbindef(\chimes,
            \instrument, \carrilhaoRod,
            \out, ~synthBus,
            \dur, Pseq([1.8, 1.2, 2.4, 1.6, 0.9], inf),
            \freq, Pseq([392, 440, 523.25, 329.63, 587.33], inf),
            \decay, Pwhite(1.6, 3.2, inf),
            \strike, Pwhite(0.8, 1.6, inf),
            \amp, Pwhite(0.18, 0.26, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        // Subtle accelerating tension: gears warming up
        5.do { |i|
            Ndef(\brassSwarm).xset(\speed, 1.15 + (i * 0.08), \breathRate, 0.09 + (i * 0.015));
            3.0.wait;
        };

        // Cue 4: 0:37 - The Dense Temporal Swarm (Intrinsic Limit of Desynchronization)
        "0:37 - [Cue 4: Limite Intrinseco - Caos microscopico dos duzentos eixos]".postln;
        Ndef(\brassSwarm).xset(\amp, 0.35, \filtCut, 3800, \speed, 1.6);
        Pbindef(\pockWatchA, \dur, Pseq([0.085, 0.082, 0.088], inf), \amp, 0.22);
        Pbindef(\pockWatchB, \dur, Pseq([0.11, 0.114, 0.108], inf), \amp, 0.2);
        Pbindef(\pendulums, \dur, Pseq([0.252, 0.248, 0.255], inf), \amp, 0.3);

        5.do { |idx|
            Ndef(\masterMix).set(\wet10, 0.38 + (idx * 0.04));
            2.0.wait;
        };

        // Cue 5: 0:47 - Sudden Fracture / Flashback: O Relojoeiro Fecha os Olhos (Settling Archetype)
        "0:47 - [Cue 5: Assentamento - O velho relojoeiro fecha os olhos]".postln;
        Pbindef(\pockWatchA).stop;
        Pbindef(\pockWatchB).stop;
        Pbindef(\pendulums).stop;
        Ndef(\brassSwarm).fadeTime = 4;
        Ndef(\brassSwarm).xset(\amp, 0.08, \filtCut, 800, \speed, 0.6, \breathRate, 0.04);
        Ndef(\masterMix).set(\wet10, 0.55);

        // Solitary, fragile chime in silence
        Pbindef(\chimes,
            \dur, Pseq([3.8, 4.2, 5.0], inf),
            \freq, Pseq([329.63, 440, 261.63], inf),
            \decay, 4.0,
            \amp, 0.18,
            \pan, 0
        );

        4.do { 2.5.wait; };

        // Cue 6: 0:57 - O Próprio Respirar do Tempo (Subtle Micro-Phase Phantasm)
        "0:57 - [Cue 6: Nas defasagens microscopicas, o proprio respirar do tempo]".postln;
        Ndef(\brassSwarm).fadeTime = 8;
        Ndef(\brassSwarm).xset(\amp, 0.18, \filtCut, 1400, \speed, 0.9, \breathRate, 0.05);

        // A single pocket watch ticks in extreme close-up, orbiting around center
        Pbindef(\pockWatchA,
            \dur, Pseq([0.25, 0.249, 0.251], inf),
            \freq, Pseq([7200, 6800], inf),
            \amp, Pseq([0.22, 0.14], inf),
            \pan, Pseq([-0.15, 0.15], inf)
        ).play;

        Pbindef(\pendulums,
            \dur, Pseq([1.002, 0.998], inf),
            \freq, Pseq([1800, 1820], inf),
            \bodyLen, 0.08,
            \amp, 0.24,
            \pan, 0
        ).play;

        6.do { |step|
            Ndef(\brassSwarm).xset(\breathRate, 0.05 + (step * 0.008));
            3.0.wait;
        };

        // Cue 7: 1:15 - Clockwork Recoil & Harmonic Unison Resolution (Resolution Archetype)
        "1:15 - [Cue 7: Resolucao - As engrenagens alinham-se por um instante fugaz]".postln;
        Pbindef(\pockWatchA, \dur, 0.25, \pan, 0);
        Pbindef(\pendulums, \dur, 0.5, \pan, 0);
        Pbindef(\chimes,
            \dur, Pseq([2.0, 2.0, 4.0], inf),
            \freq, Pseq([440, 550, 220], inf),
            \decay, 3.5,
            \amp, 0.22
        );

        Ndef(\masterMix).set(\wet10, 0.3);

        3.do { |k|
            Ndef(\brassSwarm).xset(\amp, 0.14 - (k * 0.03));
            3.0.wait;
        };

        // Cue 8: 1:24 - Extrinsic Limit: The Last Unwound Escapement
        "1:24 - [Cue 8: Limite Extrinseco - Desaceleracao final e paragem dos eixos]".postln;
        Pbindef(\pockWatchA).stop;
        Pbindef(\chimes).stop;

        // Pendulum slows down gradually to a halt
        Pbindef(\pendulums,
            \dur, Pseq([0.6, 0.75, 0.95, 1.3, 1.8, 2.5], 1),
            \freq, Pseq([1600, 1500, 1400, 1300, 1200, 1100], 1),
            \amp, Pseq([0.22, 0.18, 0.14, 0.10, 0.06, 0.02], 1)
        );

        Ndef(\brassSwarm).fadeTime = 6;
        Ndef(\brassSwarm).xset(\amp, 0);

        8.0.wait;

        // Scoped Termination (Shared Server Safe)
        Pbindef(\pockWatchA).stop; Pbindef(\pockWatchA).clear;
        Pbindef(\pockWatchB).stop; Pbindef(\pockWatchB).clear;
        Pbindef(\pendulums).stop; Pbindef(\pendulums).clear;
        Pbindef(\chimes).stop; Pbindef(\chimes).clear;

        Ndef(\brassSwarm).clear(3);
        Ndef(\masterMix).clear(3);

        "Score Complete: Os relogios da Santa Efigenia silenciam.".postln;
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
    var setup;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // 1. Safety Limiter Setup
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete Acoustic SynthDefs: Mineral Drops, Stalactite Resonances, and Calcite Shards
    SynthDef(\mineralDrip, {
        |out, freq=1200, dropSweep=1800, decTime=1.8, amp=0.2, pan=0|
        var env, pitchEnv, click, sig;
        env = EnvGen.ar(Env.perc(0.001, decTime, 1, -6), doneAction: 2);
        pitchEnv = XLine.ar(dropSweep, freq, 0.012);
        click = BPF.ar(LPF.ar(WhiteNoise.ar, 7000), pitchEnv, 0.1) * EnvGen.ar(Env.perc(0.0005, 0.008));
        sig = SinOsc.ar(pitchEnv) * EnvGen.ar(Env.perc(0.002, 0.04));
        sig = sig + (Ringz.ar(click, freq, decTime * 0.8) * 0.4);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\stalactiteModal, {
        |out, freq=280, amp=0.15, dec=3.2, hitBright=2400, pan=0|
        var strike, env, freqs, amps, rings, modes, sig;
        env = EnvGen.ar(Env.perc(0.002, dec, 1, -4), doneAction: 2);
        strike = HPF.ar(PinkNoise.ar, 800) * EnvGen.ar(Env.perc(0.0008, 0.015));
        freqs = [freq, freq * 2.32, freq * 4.18, freq * 5.86, freq * 8.42];
        amps = [1.0, 0.45, 0.22, 0.12, 0.06];
        rings = [dec, dec * 0.75, dec * 0.5, dec * 0.35, dec * 0.2];
        modes = DynKlank.ar(Ref([freqs, amps, rings]), strike, decayscale: 1.0);
        sig = (modes * 0.35) + (LPF.ar(strike, hitBright) * 0.15);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\limestoneCrackle, {
        |out, freq=3200, dur=0.12, amp=0.1, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0005, dur.max(0.01), 1, -8), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar * 2.5, freq, 0.15);
        sig = (sig * 3.0).fold2(0.8);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // 3. Continuous Acoustic Environments: Subterranean Vaults & Deep Siphon Flow
    Ndef(\vaultDrone, {
        |amp=0, rumbleFreq=48, airCut=650, waterFlow=0.2|
        var air, sub, siphon, sig;
        air = BPF.ar(PinkNoise.ar(0.8), [rumbleFreq * 3.5, rumbleFreq * 4.8], 0.2).sum;
        sub = SinOsc.ar([rumbleFreq, rumbleFreq * 1.008]) * 0.4;
        sub = sub + (SinOsc.ar(rumbleFreq * 2) * 0.18);
        siphon = LPF.ar(BrownNoise.ar, airCut) * LFNoise2.kr(0.12).range(0.3, 1.0);
        sig = Splay.ar([air * 0.3, sub[0], sub[1], siphon * waterFlow]);
        sig = LeakDC.ar(sig) * amp;
    });

    Ndef(\wetVapor, {
        |amp=0, motion=0.1, resFreq=440|
        var exciter, bank, sig;
        exciter = Dust2.ar(LFNoise1.kr(0.2).range(4, 28)) * 0.2;
        bank = DynKlank.ar(
            Ref([
                [resFreq, resFreq * 1.48, resFreq * 1.95, resFreq * 2.72],
                [0.4, 0.25, 0.18, 0.08],
                [2.8, 2.2, 1.6, 1.1]
            ]),
            exciter
        );
        sig = (bank * 0.4) + CombL.ar(exciter, 0.2, SinOsc.kr(motion, 0).range(0.03, 0.08), 2.5);
        sig = Pan2.ar(sig, SinOsc.kr(motion * 0.5));
        LeakDC.ar(sig) * amp;
    });

    // 4. Master Cave Bus Mixer with 7-Chamber Monumental Reverberation
    Ndef(\masterMix, {
        var busSig = In.ar(~synthBus, 2);
        var droneSig = Ndef.ar(\vaultDrone, 2);
        var vaporSig = Ndef.ar(\wetVapor, 2);
        busSig + droneSig + vaporSig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.96, damp: 0.2);
    };

    Ndef(\masterMix)[11] = \filter -> { |in|
        GVerb.ar(in.sum, 240, 7.5, 0.45, 0.6, 15, -6.dbamp, -12.dbamp, -18.dbamp);
    };

    Ndef(\masterMix).play;
    Ndef(\masterMix).set(\wet10, 0.35, \wet11, 0.2);

    s.sync;

    // 5. Fixed Timeline Master Score: A Gruta do Maquiné (~2 min)
    Tdef(\masterScore, {
        0.5.wait;

        // Salão I: O Vestíbulo de Cordisburgo e a Penumbra
        "0:00 - [Salão I: O Vestíbulo de Cordisburgo - Peter Lund acende as tochas]".postln;
        Ndef(\vaultDrone).fadeTime = 6;
        Ndef(\vaultDrone).xset(\amp, 0.28, \rumbleFreq, 44, \airCut, 520, \waterFlow, 0.15);

        Pbindef(\caveDrips,
            \instrument, \mineralDrip,
            \out, ~synthBus,
            \dur, Pseq([1.4, 2.1, 0.9, 3.2, 1.8], inf),
            \freq, Pseq([1650, 1420, 2100, 1280, 1850], inf),
            \dropSweep, Pkey(\freq) * 1.5,
            \decTime, 1.8,
            \amp, Pseq([0.18, 0.12, 0.22, 0.14, 0.19], inf),
            \pan, Pseq([-0.6, 0.4, -0.2, 0.7, -0.4], inf)
        ).play;

        3.do { |i|
            Ndef(\vaultDrone).xset(\rumbleFreq, 44 + (i * 2));
            3.0.wait;
        };

        // Salão II: O Lustre do Alabastro (Iniciação Modal)
        "0:09 - [Salão II: O Lustre do Alabastro - Primeiras cortinas calcárias ressoam]".postln;
        Ndef(\wetVapor).fadeTime = 5;
        Ndef(\wetVapor).xset(\amp, 0.18, \resFreq, 330, \motion, 0.08);

        Pbindef(\stalactites,
            \instrument, \stalactiteModal,
            \out, ~synthBus,
            \dur, Pseq([3.5, 4.2, 2.8, 5.0], inf),
            \freq, Pseq([220, 277.18, 164.81, 329.63], inf),
            \amp, 0.16,
            \dec, 3.8,
            \pan, Pseq([-0.3, 0.3, -0.5, 0.5], inf)
        ).play;

        Pbindef(\caveDrips, \dur, Pseq([0.8, 1.2, 0.6, 1.7, 0.4, 2.0], inf));

        4.do { |k|
            Ndef(\masterMix).set(\wet10, 0.38 + (k * 0.03));
            2.5.wait;
        };

        // Salão III: O Templo dos Esqueletos Fósseis (Sub-graves Profundos)
        "0:19 - [Salão III: O Templo dos Fósseis - Sedimentos pleistocênicos sob a terra]".postln;
        Ndef(\vaultDrone).fadeTime = 4;
        Ndef(\vaultDrone).xset(\amp, 0.36, \rumbleFreq, 38, \airCut, 880, \waterFlow, 0.35);

        Pbindef(\stalactites,
            \dur, Pseq([1.8, 2.4, 1.2, 3.1], inf),
            \freq, Pseq([110, 146.83, 164.81, 123.47], inf),
            \amp, 0.22,
            \dec, 4.5
        );

        Pbindef(\calciteCrack,
            \instrument, \limestoneCrackle,
            \out, ~synthBus,
            \dur, Pseq([0.35, 0.7, 0.45, 1.2, 0.25], inf),
            \freq, Pexprand(2400, 6800, inf),
            \amp, Pseq([0.08, 0.14, 0.06, 0.11], inf),
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        3.do { |idx|
            Ndef(\wetVapor).xset(\resFreq, 220 + (idx * 55));
            3.2.wait;
        };

        // Salão IV: A Cascata Petrificada (Aceleração Hidrológica)
        "0:29 - [Salão IV: A Cascata Petrificada - Véus de calcita gotejam aceleradamente]".postln;
        Pbindef(\caveDrips,
            \dur, Pseq([0.22, 0.18, 0.35, 0.14, 0.28, 0.12], inf),
            \freq, Pseq([2400, 2150, 2800, 1920, 3100, 1680], inf),
            \amp, 0.22
        );

        Pbindef(\stalactites,
            \dur, Pseq([0.9, 1.1, 0.7, 1.4], inf),
            \freq, Pseq([330, 440, 293.66, 392], inf),
            \amp, 0.18
        );

        Ndef(\masterMix).set(\wet11, 0.38);

        4.do { |step|
            Ndef(\vaultDrone).xset(\waterFlow, 0.4 + (step * 0.1));
            2.5.wait;
        };

        // Salão V: O Salão do Trono (Ressonância Máxima - Limite Intrínseco)
        "0:39 - [Salão V: O Salão do Trono - Acústica monumental das cúpulas de pedra]".postln;
        Ndef(\vaultDrone).xset(\amp, 0.42, \rumbleFreq, 32, \airCut, 1200);
        Ndef(\wetVapor).xset(\amp, 0.28, \resFreq, 165, \motion, 0.18);
        Ndef(\masterMix).set(\wet10, 0.55, \wet11, 0.45);

        Pbindef(\stalactites,
            \dur, Pseq([0.5, 0.5, 0.75, 0.25, 1.0], inf),
            \freq, Pseq([164.81, 220, 329.63, 440, 110], inf),
            \amp, 0.24,
            \dec, 5.0
        );

        5.do { |m|
            Ndef(\wetVapor).xset(\resFreq, 165 * (1 + (m * 0.15)));
            2.0.wait;
        };

        // Salão VI: O Silêncio das Catacumbas (Assentamento / Flashback)
        "0:49 - [Salão VI: O Silêncio das Catacumbas - As tochas tremulam no ar rarefeito]".postln;
        Pbindef(\calciteCrack).stop;
        Pbindef(\stalactites).stop;
        Ndef(\wetVapor).fadeTime = 6;
        Ndef(\wetVapor).xset(\amp, 0.05);
        Ndef(\vaultDrone).fadeTime = 5;
        Ndef(\vaultDrone).xset(\amp, 0.15, \airCut, 380, \waterFlow, 0.08);

        // Retorno ao gotejamento solitário, amplíssimo no espaço reverberante
        Pbindef(\caveDrips,
            \dur, Pseq([2.8, 3.4, 2.1, 4.2], inf),
            \freq, Pseq([1200, 1480, 1100, 1620], inf),
            \amp, 0.16,
            \decTime, 2.4,
            \pan, Pseq([0, -0.4, 0.5, -0.2], inf)
        );

        Ndef(\masterMix).set(\wet10, 0.65, \wet11, 0.3);

        4.do { 2.5.wait; };

        // Salão VII: O Fim das Galerias e Resolução Acústica (Retorno e Parada)
        "0:59 - [Salão VII: As Galerias Terminais - A pedra consome o eco milenar]".postln;
        Pbindef(\stalactites,
            \dur, Pseq([4.0, 5.0], inf),
            \freq, Pseq([55, 110], inf),
            \amp, 0.14,
            \dec, 6.0,
            \pan, 0
        ).play;

        4.do { |k|
            Ndef(\vaultDrone).xset(\amp, 0.12 - (k * 0.025));
            Ndef(\masterMix).set(\wet10, 0.65 - (k * 0.08));
            2.5.wait;
        };

        // Limite Extrínseco: A escuridão total se assenta
        "1:09 - [Limite Extrínseco: O último pingo calcário petrifica o silêncio]".postln;
        Pbindef(\stalactites).stop;
        Pbindef(\caveDrips,
            \dur, Pseq([1.8, 2.5, 3.8], 1),
            \freq, Pseq([1800, 1400, 950], 1),
            \amp, Pseq([0.14, 0.08, 0.03], 1)
        );

        Ndef(\wetVapor).fadeTime = 4;
        Ndef(\wetVapor).xset(\amp, 0);
        Ndef(\vaultDrone).fadeTime = 5;
        Ndef(\vaultDrone).xset(\amp, 0);

        7.0.wait;

        // Scoped Termination (Shared Server Safe)
        Pbindef(\caveDrips).stop; Pbindef(\caveDrips).clear;
        Pbindef(\stalactites).stop; Pbindef(\stalactites).clear;
        Pbindef(\calciteCrack).stop; Pbindef(\calciteCrack).clear;

        Ndef(\vaultDrone).clear(2);
        Ndef(\wetVapor).clear(2);
        Ndef(\masterMix).clear(2);

        "Score Complete: A Gruta do Maquiné repousa na escuridão.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

