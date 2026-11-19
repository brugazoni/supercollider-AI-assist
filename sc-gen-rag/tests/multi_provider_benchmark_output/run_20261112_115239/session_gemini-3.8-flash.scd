// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T14:52:45.492194+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Archetype: Intrinsic Limit (b) - Dense frozen tension and sharp paper-folding creases
// An icy antarctic drone with suspended high-frequency metallic resonance and crisp, brittle folds

// 1. Frozen wine bottle & glacial tension drone
Ndef(\antarcticStorm, { |freq=48, amp=0.25, pan=0, brightness=400, spread=0.8|
    var sub, rumble, wind, noise, sig;
    sub = SinOsc.ar([freq, freq * 1.5]) * 0.4;
    sub = sub + (SinOsc.ar(freq * 2) * 0.2);
    rumble = BrownNoise.ar() * 0.25;
    rumble = LPF.ar(rumble, brightness);
    wind = BPF.ar(WhiteNoise.ar(), [120, 240, 480], 0.15).sum * 0.3;
    sig = sub + rumble + wind;
    sig = sig + (CombC.ar(sig, 0.2, SinOsc.kr(0.05).range(0.08, 0.12), 3) * 0.25);
    sig = LeakDC.ar(sig);
    Splay.ar(sig, spread, amp, pan);
}).play;

// 2. Road map folding: brittle, sharp creases and geometric friction
Ndef(\mapFolds, { |freq=3200, amp=0.28, pan=0, t_trig=0, foldAmt=1.2, decay=0.08, rq=0.04|
    var env = Decay2.ar(K2A.ar(t_trig), 0.001, decay);
    var click = Dust2.ar(800) * env * 3;
    var burst = BPF.ar(WhiteNoise.ar(), freq, rq) * 12.0 * env;
    var fold = (burst + click * foldAmt).fold2(0.8);
    var sig = HPF.ar(fold, 800);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFoldsSeq,
    \dur, Pseq([0.15, 0.35, 0.1, 0.2, 0.8, 0.08, 0.12, 1.2], inf),
    \t_trig, 1,
    \freq, Pseq([2400, 4200, 3100, 5600, 1800, 6800, 3600], inf),
    \decay, Pexprand(0.02, 0.14, inf),
    \foldAmt, Pwhite(1.1, 3.5, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pwhite(0.18, 0.32, inf)
);

Ndef(\mapFolds)[1] = \set -> Pbindef(\mapFoldsSeq);

// 3. The suspended bottle: frozen glass tone hanging in the room
Ndef(\suspendedGlass, { |freq=840, amp=0.18, pan=0, t_trig=0, shimmer=0.02|
    var trig = K2A.ar(t_trig);
    var exc = Impulse.ar(0) + (PinkNoise.ar() * Decay.ar(trig, 0.01) * 0.1);
    var modes = [1, 2.76, 5.4, 8.9];
    var ringTimes = [2.5, 1.8, 1.2, 0.6];
    var sig = DynKlank.ar(
        `[modes * freq, [0.4, 0.25, 0.15, 0.05], ringTimes],
        exc
    );
    sig = sig + SinOsc.ar(freq * (1 + (SinOsc.kr(4) * shimmer)), 0, 0.08);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\glassSeq,
    \dur, Pseq([3.0, 4.5, 2.5, 6.0], inf),
    \t_trig, 1,
    \freq, Pseq([784, 880, 1046.5, 659.25], inf), // G5, A5, C6, E5
    \amp, Pwhite(0.12, 0.2, inf),
    \pan, Pseq([0.3, -0.3, 0.1, -0.1], inf)
);

Ndef(\suspendedGlass)[1] = \set -> Pbindef(\glassSeq);

// Rollback for entire opening set:
// Pbindef(\mapFoldsSeq).stop; Ndef(\mapFolds).fadeTime = 2; Ndef(\mapFolds).clear(2);
// Pbindef(\glassSeq).stop; Ndef(\suspendedGlass).fadeTime = 2; Ndef(\suspendedGlass).clear(2);
// Ndef(\antarcticStorm).fadeTime = 3; Ndef(\antarcticStorm).clear(3);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// Archetype: Intrinsic Limit (b) transitioning into tragic upheaval
// "O Navio Negreiro" (Castro Alves): Dantean nightmare, clanking irons, crack of the whip, groans, feverish blood-red dance

// 1. Clanking irons & rusted chains ("Tinir de ferros... elos da corrente maldita")
Ndef(\chainedIrons, { |freq=1800, amp=0.28, pan=0, t_trig=0, strike=0.8, decay=0.35|
    var trig = K2A.ar(t_trig);
    var exc = (Impulse.ar(0) * strike) + (Dust2.ar(1200) * Decay2.ar(trig, 0.001, 0.04));
    var freqs = [1, 1.48, 2.14, 3.22, 4.67, 6.1] * freq;
    var amps = [0.4, 0.35, 0.25, 0.18, 0.1, 0.05];
    var rings = [1.2, 0.9, 0.7, 0.4, 0.25, 0.15] * decay;
    var metal = DynKlank.ar(`[freqs, amps, rings], exc);
    var scrap = (HPF.ar(BrownNoise.ar(), 1200) * Decay2.ar(trig, 0.01, decay * 0.8) * 1.5).fold2(0.6);
    var sig = metal + scrap;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\chainedIronsSeq,
    \dur, Pseq([0.25, 0.5, 0.25, 0.25, 0.75, 0.125, 0.125, 0.375], inf),
    \t_trig, 1,
    \freq, Pseq([1240, 1680, 1420, 2150, 980, 1890], inf),
    \decay, Pexprand(0.2, 0.6, inf),
    \strike, Pwhite(0.6, 1.2, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pwhite(0.22, 0.34, inf)
);

Ndef(\chainedIrons)[1] = \set -> Pbindef(\chainedIronsSeq);

// 2. Crack of the whip / slash ("Estalar de açoite...")
Ndef(\whipCrack, { |amp=0.32, pan=0, t_trig=0, drive=4.0|
    var trig = K2A.ar(t_trig);
    var snapEnv = Decay2.ar(trig, 0.0005, 0.025);
    var tailEnv = Decay2.ar(trig, 0.01, 0.18);
    var noise = WhiteNoise.ar();
    var snap = BPF.ar(noise, 4200, 0.25) * snapEnv * 18.0;
    var body = HPF.ar(noise, 800) * tailEnv * 3.0;
    var whip = (snap + body * drive).tanh;
    whip = CombL.ar(whip, 0.05, 0.018, 0.12);
    Pan2.ar(whip * amp, pan);
}).play;

Pbindef(\whipSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 1.0, 3.0], inf),
    \t_trig, 1,
    \drive, Pwhite(3.0, 6.5, inf),
    \pan, Pseq([0.4, -0.5, 0.2, -0.3], inf),
    \amp, Pwhite(0.25, 0.38, inf)
);

Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);

// 3. Groaning breath & salt wind under red lanterns ("homens gemendo sob a aragem salgada")
Ndef(\slaveGroans, { |fund=82, amp=0.22, pan=0, t_trig=0, formant=420, modRate=4.5|
    var trig = K2A.ar(t_trig);
    var env = Decay2.ar(trig, 0.3, 2.2);
    var vibrato = SinOsc.kr(modRate).range(0.96, 1.04);
    var osc = Saw.ar(fund * vibrato) + Pulse.ar((fund * 0.5) * vibrato, 0.35, 0.6);
    var vowel = BPF.ar(osc, [formant, formant * 1.8, formant * 2.7], 0.08).sum * 8.0;
    var breath = PinkNoise.ar() * Decay.ar(trig, 0.8) * 0.15;
    var groan = (vowel + breath).tanh * env;
    Pan2.ar(groan * amp, pan);
}).play;

Pbindef(\groanSeq,
    \dur, Pseq([3.5, 2.5, 4.0, 3.0], inf),
    \t_trig, 1,
    \fund, Pseq([65.41, 73.42, 61.74, 82.41], inf), // C2, D2, B1, E2
    \formant, Pseq([320, 480, 260, 540], inf),
    \modRate, Pwhite(3.5, 6.0, inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \amp, Pwhite(0.18, 0.28, inf)
);

Ndef(\slaveGroans)[1] = \set -> Pbindef(\groanSeq);

// 4. Stain existing antarctic storm with blood-red saturation & heavy churn
Ndef(\antarcticStorm)[10] = \filter -> { |in|
    var redDrive = (in * 2.8).tanh;
    var swell = RLPF.ar(redDrive, SinOsc.kr(0.15).range(180, 950), 0.3);
    LeakDC.ar(swell);
};
Ndef(\antarcticStorm).xset(\wet10, 0.7);
// Ndef(\antarcticStorm).xset(\wet10, 0); // Revert tweak

// Rollbacks:
// Pbindef(\chainedIronsSeq).stop; Ndef(\chainedIrons).fadeTime = 2; Ndef(\chainedIrons).clear(2); // Rollback: remove chained irons
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2); // Rollback: remove whip
// Pbindef(\groanSeq).stop; Ndef(\slaveGroans).fadeTime = 2; Ndef(\slaveGroans).clear(2); // Rollback: remove groans
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockScore;

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
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete SynthDefs for Horological Instruments
    // Small pocket watch escapement: high, dry, brass click
    SynthDef(\pocketEscapement, { |out=0, freq=3800, amp=0.15, pan=0, hardness=1.2|
        var env = EnvGen.ar(Env.perc(0.0004, 0.028, 1, -8), doneAction: 2);
        var click = (Impulse.ar(0) * hardness) + (WhiteNoise.ar() * Decay.ar(Impulse.ar(0), 0.003));
        var freqs = [1, 2.13, 3.87, 5.2] * freq;
        var amps = [0.5, 0.25, 0.15, 0.08];
        var rings = [0.015, 0.01, 0.008, 0.004];
        var res = DynKlank.ar(`[freqs, amps, rings], click);
        var body = BPF.ar(click, freq * 0.8, 0.1) * 3.0;
        var sig = (res + body) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Heavy pendulum escapement: deep clack with resonant wooden casing
    SynthDef(\pendulumThump, { |out=0, freq=180, amp=0.25, pan=0, drop=0.4|
        var env = EnvGen.ar(Env.perc(0.002, 0.14, 1, -5), doneAction: 2);
        var pEnv = XLine.ar(freq * 1.8, freq, 0.02);
        var tooth = WhiteNoise.ar() * Decay2.ar(Impulse.ar(0), 0.0005, 0.012) * 2.0;
        var wood = SinOsc.ar(pEnv) * 1.5 + (BPF.ar(BrownNoise.ar(), freq * 2.2, 0.15) * 2.5);
        var sig = ((tooth + wood).tanh * env * amp);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // French Ormolu Chimes: silvery, complex harmonic bells
    SynthDef(\frenchChime, { |out=0, freq=880, amp=0.2, pan=0, dur=2.5, strike=1.0|
        var env = EnvGen.ar(Env.perc(0.001, (dur - 0.05).max(0.1), 1, -4), doneAction: 2);
        var exc = Impulse.ar(0) * strike + (PinkNoise.ar() * Decay.ar(Impulse.ar(0), 0.004));
        var freqs = [1, 2.76, 5.4, 8.93, 11.2] * freq;
        var amps = [0.45, 0.28, 0.18, 0.08, 0.04];
        var rings = [dur, dur * 0.75, dur * 0.5, dur * 0.3, dur * 0.15];
        var metal = DynKlank.ar(`[freqs, amps, rings], exc);
        var shimmer = SinOsc.ar(freq * 3.01) * Decay.ar(Impulse.ar(0), 0.3) * 0.2;
        var sig = (metal + shimmer) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // 3. Continuous Acoustic Environments (Ndefs)
    // 200 clocks asynchronous phase drift / brass friction
    Ndef(\clockSwarm, { |amp=0.0, speed=1.0, filterFreq=2800, scatter=0.25|
        var t1 = Dust2.ar(14 * speed);
        var t2 = Dust2.ar(22 * speed);
        var t3 = Dust2.ar(31 * speed);
        var gear1 = Ringz.ar(t1, LFNoise1.kr(0.2).exprange(1200, 2400), 0.012) * 0.4;
        var gear2 = Ringz.ar(t2, LFNoise1.kr(0.3).exprange(2600, 4800), 0.008) * 0.35;
        var gear3 = Ringz.ar(t3, LFNoise1.kr(0.15).exprange(600, 1500), 0.02) * 0.5;
        var brassFriction = BPF.ar(PinkNoise.ar(), LFNoise2.kr(0.1).exprange(800, 3200), 0.2) * 0.12;
        var sig = Splay.ar([gear1, gear2, gear3, brassFriction], scatter);
        sig = LPF.ar(sig, filterFreq);
        sig * amp;
    });

    // The Old Watchmaker's deep perception: "o próprio respirar do tempo"
    Ndef(\timeBreathing, { |amp=0.0, rate=0.12, subFund=43.65, resonance=480|
        var breathLfo = SinOsc.kr(rate);
        var breathVol = breathLfo.range(0.2, 1.0);
        var sub = SinOsc.ar(subFund) + (SinOsc.ar(subFund * 2) * 0.35);
        var air = BPF.ar(BrownNoise.ar(), breathLfo.exprange(180, resonance), 0.22) * 2.5;
        var combined = (sub * 0.8) + (air * 1.2);
        var stereo = [combined * breathLfo.range(0.7, 1.0), combined * (1.0 - breathLfo.range(0.0, 0.3))];
        LeakDC.ar(stereo) * breathVol * amp;
    });

    // Master Mixer & Shared Bus Reader
    Ndef(\masterMix, {
        var busSig = In.ar(~synthBus, 2);
        var swarm = Ndef.ar(\clockSwarm, 2);
        var breath = Ndef.ar(\timeBreathing, 2);
        busSig + swarm + breath;
    });

    // Reverberant shop acoustic: narrow masonry and tall mahogany cases
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.45);
    };
    Ndef(\masterMix).set(\wet10, 0.18);
    Ndef(\masterMix).play;

    s.sync;

    // 4. Fixed Timeline Choreography
    Tdef(\masterScore, {
        "0:00 - [Ladeira de Santa Efigênia: Oficina de Relógios Despertando]".postln;
        Ndef(\clockSwarm).fadeTime = 3.0;
        Ndef(\clockSwarm).xset(\amp, 0.22, \speed, 0.8, \filterFreq, 2200);
        Ndef(\timeBreathing).fadeTime = 6.0;
        Ndef(\timeBreathing).xset(\amp, 0.18, \rate, 0.1);

        // Pattern 1: Large wooden wall clocks & grandfather pendulums (irregular, out-of-sync seconds)
        Pbindef(\pendulumSeq,
            \instrument, \pendulumThump,
            \out, ~synthBus,
            \dur, Pseq([0.98, 1.03, 0.95, 1.08, 0.99, 1.04, 0.92, 1.01], inf),
            \freq, Pseq([120, 142, 110, 160, 134, 150], inf),
            \pan, Pseq([-0.65, 0.55, -0.4, 0.7, -0.2, 0.3], inf),
            \amp, Pwhite(0.24, 0.36, inf)
        ).play;

        0.8.wait;

        // Pattern 2: Swarm of pocket watches ticking in polyrhythmic phase-displacement
        Pbindef(\pocketSeqA,
            \instrument, \pocketEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.248, 0.252, 0.246, 0.254, 0.250], inf),
            \freq, Pseq([3400, 4200, 3800, 4600], inf),
            \pan, Pwhite(-0.85, -0.15, inf),
            \amp, Pwhite(0.08, 0.15, inf)
        ).play;

        Pbindef(\pocketSeqB,
            \instrument, \pocketEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.165, 0.171, 0.162, 0.168], inf),
            \freq, Pseq([4800, 5200, 4400, 5600], inf),
            \pan, Pwhite(0.15, 0.85, inf),
            \amp, Pwhite(0.06, 0.12, inf)
        ).play;

        "0:12 - [Defasagens Microscópicas: Textural Expansion]".postln;
        // Active loop: modulate the microscopic phase density
        4.do { |i|
            Ndef(\clockSwarm).xset(\speed, 1.0 + (i * 0.25), \scatter, 0.2 + (i * 0.15));
            Ndef(\timeBreathing).xset(\resonance, 320 + (i * 80), \rate, 0.12 + (i * 0.02));
            3.0.wait;
        };

        "0:24 - [Carrilhões Franceses: Antique Chimes Sounding Out of Step]".postln;
        Ndef(\masterMix).set(\wet10, 0.32);

        // Pattern 3: Ornate French chiming clocks striking discordant quarters
        Pbindef(\chimeSeq,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([1.8, 0.6, 1.2, 0.9, 2.4, 0.4, 1.5], inf),
            \freq, Pseq([587.33, 659.25, 783.99, 880.0, 523.25, 698.46, 1046.5], inf), // D5, E5, G5, A5, C5, F5, C6
            \dur_metal, Pwhite(1.8, 3.2, inf),
            \strike, Pwhite(0.7, 1.2, inf),
            \pan, Pseq([0.35, -0.45, 0.6, -0.2, -0.6, 0.1], inf),
            \amp, Pwhite(0.14, 0.24, inf)
        ).play;

        // Sub-loop: Accelerating gear friction as time approaches sync threshold
        5.do { |idx|
            Pbindef(\pocketSeqA, \dur, Pseq([0.248 - (idx * 0.012), 0.252 + (idx * 0.008)], inf));
            Pbindef(\pendulumSeq, \freq, Pseq([120 + (idx * 15), 142 - (idx * 8), 110 + (idx * 20)], inf));
            2.5.wait;
        };

        "0:36 - [Intrinsic Limit: O Respirar do Tempo Revelado]".postln;
        // Pendulums and chimes converge into a heavy, suspended breathing texture
        Pbindef(\chimeSeq).stop;
        Pbindef(\pocketSeqB).stop;

        Ndef(\timeBreathing).fadeTime = 4.0;
        Ndef(\timeBreathing).xset(\amp, 0.42, \rate, 0.08, \resonance, 680);
        Ndef(\clockSwarm).fadeTime = 3.0;
        Ndef(\clockSwarm).xset(\filterFreq, 950, \amp, 0.15);

        // Sparse single pendulum ticking like a slowing heartbeat
        Pbindef(\pendulumSeq,
            \dur, Pseq([1.4, 1.45, 1.5, 1.6, 1.7], inf),
            \freq, Pseq([98, 92, 88, 82], inf),
            \amp, Pseq([0.32, 0.28, 0.24, 0.20, 0.16], inf)
        );

        3.do { |step|
            Ndef(\masterMix).set(\wet10, 0.35 + (step * 0.08));
            4.0.wait;
        };

        "0:48 - [Settling & Final Decay: O Silêncio da Ladeira]".postln;
        Pbindef(\pocketSeqA).stop;
        Pbindef(\pendulumSeq).stop;

        // One last isolated high-register pocket-watch click and distant chime decay
        Synth(\pocketEscapement, [\out, ~synthBus, \freq, 5120, \amp, 0.18, \pan, 0.2]);
        0.4.wait;
        Synth(\frenchChime, [\out, ~synthBus, \freq, 880, \amp, 0.15, \pan, -0.3, \dur, 4.0]);

        Ndef(\clockSwarm).fadeTime = 5.0;
        Ndef(\clockSwarm).xset(\amp, 0.0);
        Ndef(\timeBreathing).fadeTime = 6.0;
        Ndef(\timeBreathing).xset(\amp, 0.0);

        6.0.wait;

        // Scoped Termination: Clean ONLY the elements created in this block
        Pbindef(\pendulumSeq).stop; Pbindef(\pendulumSeq).clear;
        Pbindef(\pocketSeqA).stop; Pbindef(\pocketSeqA).clear;
        Pbindef(\pocketSeqB).stop; Pbindef(\pocketSeqB).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;

        Ndef(\clockSwarm).clear(1);
        Ndef(\timeBreathing).clear(1);
        Ndef(\masterMix).clear(1);

        "Score Complete: Na oficina da Ladeira de Santa Efigênia, o tempo silencia.".postln;
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
    // --- Master Bus & Safety Limiter Setup ---
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

    // --- Discrete SynthDefs: Stalactite Drops, Calcite Resonances, Air Fractures ---
    // Water drop with initial hydrodynamic sine-chirp into modal calcite vibration
    SynthDef(\maquineDrop, {
        |out=0, freq=1200, resFreq=440, dec=1.8, pan=0.0, amp=0.2|
        var pitchenv = EnvGen.ar(Env([freq * 1.5, freq, freq * 0.8], [0.003, 0.04], \exp));
        var click = SinOsc.ar(pitchenv) * EnvGen.ar(Env.perc(0.001, 0.03));
        var impact = HPF.ar(LPF.ar(WhiteNoise.ar, 6000), 1200) * EnvGen.ar(Env.perc(0.0005, 0.008));
        var body = Ringz.ar(click + (impact * 0.4), [resFreq, resFreq * 1.48, resFreq * 2.15], [dec, dec * 0.7, dec * 0.4], [0.5, 0.3, 0.15]).sum;
        var sig = (click * 0.6) + (body * 0.8);
        var env = EnvGen.ar(Env.perc(0.002, dec.max(0.1)), doneAction: 2);
        OffsetOut.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    // Mineral curtain chime: struck limestone stalagmite modal cluster
    SynthDef(\calciteCurtain, {
        |out=0, freq=320, strike=0.8, pan=0.0, amp=0.15, dur=3.5|
        var exc = PinkNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.02 * strike));
        var freqs = freq * [1.0, 1.73, 2.61, 3.84, 5.12];
        var amps = [0.8, 0.45, 0.25, 0.12, 0.05];
        var decays = [dur, dur * 0.8, dur * 0.6, dur * 0.4, dur * 0.2];
        var modal = DynKlank.ar(Ref([freqs, amps, decays]), exc);
        var env = EnvGen.ar(Env.perc(0.002, dur.max(0.1)), doneAction: 2);
        var sig = (modal * 0.35) * env;
        OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // Subterranean tectonic stress: low frequency limestone compaction
    SynthDef(\karstRumble, {
        |out=0, freq=48, pan=0.0, amp=0.25, dur=4.0|
        var env = EnvGen.ar(Env.sine(dur.max(0.1)), doneAction: 2);
        var sub = SinOsc.ar([freq, freq * 1.5, freq * 2.02]).sum * 0.4;
        var friction = BPF.ar(BrownNoise.ar, freq * 2, 0.4) * 1.5;
        var sig = (sub + friction).tanh * env;
        OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    s.sync;

    // --- Continuous Textures: Cave Atmosphere & Moisture Film ---
    // Seven subterranean vaults breathing with wind and continuous distant condensation
    Ndef(\maquineAbyss, {
        |amp=0.0, vaultTone=55, breathRate=0.08, airLoss=800|
        var air = PinkNoise.ar([0.2, 0.2]);
        var flow = SinOsc.kr(breathRate, [0, 0.5pi]).range(0.3, 1.0);
        var resonant = BPF.ar(air, vaultTone * [1, 1.33, 1.5, 2.2], 0.03).sum * 8.0;
        var vault = LPF.ar(resonant * flow, airLoss);
        vault * amp;
    });

    // Slow condensation seepage: micro-textures of mineral water crawling down calcified walls
    Ndef(\calciteSeep, {
        |amp=0.0, density=6, dripFilter=2400|
        var grainTrig = Dust.ar([density, density * 1.1]);
        var clicks = Decay.ar(grainTrig, 0.004) * WhiteNoise.ar;
        var dampStream = Resonz.ar(clicks, SinOsc.kr(0.05).range(1200, dripFilter), 0.15) * 6.0;
        dampStream * amp;
    });

    // Master bus mixer and cave acoustics (massive reverberant limestone halls)
    Ndef(\masterMix, {
        var busSig = In.ar(~synthBus, 2);
        var c1 = Ndef(\maquineAbyss).ar;
        var c2 = Ndef(\calciteSeep).ar;
        busSig + c1 + c2;
    });

    // Slot 10: Cavernous acoustics (Salão das Fadas / Salão do Trono)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.96, damp: 0.35);
    };

    // Slot 11: Long multi-tap karst reflections
    Ndef(\masterMix)[11] = \filter -> { |in|
        var delayed = CombL.ar(in, 0.3, [0.187, 0.231], 4.5) * 0.35;
        delayed;
    };

    Ndef(\masterMix).set(\wet10, 0.25, \wet11, 0.15);
    Ndef(\masterMix).play;

    s.sync;

    // --- Master Timeline: Exploration of the Seven Chambers (Peter Lund, 1835) ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Câmara I: Vestíbulo - Entrada na Escuridão de Peter Lund]".postln;
        Ndef(\maquineAbyss).fadeTime = 6.0;
        Ndef(\maquineAbyss).xset(\amp, 0.28, \vaultTone, 58, \breathRate, 0.07, \airLoss, 750);
        Ndef(\calciteSeep).fadeTime = 4.0;
        Ndef(\calciteSeep).xset(\amp, 0.12, \density, 4);

        // Slow, lonely drops falling from high limestone vault
        Pbindef(\dropSeq,
            \instrument, \maquineDrop,
            \out, ~synthBus,
            \dur, Pseq([2.2, 3.1, 1.8, 2.7, 4.0], inf),
            \freq, Pseq([1450, 1680, 1320, 1850, 1200], inf),
            \resFreq, Pseq([380, 440, 310, 520, 290], inf),
            \dec, Pwhite(1.6, 2.5, inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, Pwhite(0.25, 0.42, inf)
        ).play;

        4.do { |i|
            Ndef(\maquineAbyss).xset(\airLoss, 700 + (i * 60));
            3.0.wait;
        };

        "0:12 - [Câmara II & III: O Anfiteatro e o Sino dos Espíritos - Ressonância Mineral]".postln;
        Ndef(\masterMix).set(\wet10, 0.45, \wet11, 0.25);
        Ndef(\calciteSeep).xset(\amp, 0.22, \density, 12, \dripFilter, 3400);

        // Struck calcite curtain: natural stone organ tones
        Pbindef(\curtainSeq,
            \instrument, \calciteCurtain,
            \out, ~synthBus,
            \dur, Pseq([2.4, 1.8, 3.2, 0.9, 1.5, 2.1], inf),
            \freq, Pseq([220, 277.18, 329.63, 440, 493.88, 369.99], inf), // Natural A-minor modal resonance
            \strike, Pwhite(0.6, 1.3, inf),
            \dur, Pwhite(2.5, 4.2, inf),
            \pan, Pseq([-0.6, 0.5, -0.2, 0.7, -0.4, 0.1], inf),
            \amp, Pwhite(0.12, 0.22, inf)
        ).play;

        // Active water infiltration accelerating
        Pbindef(\dropSeq,
            \dur, Pseq([0.9, 1.4, 0.6, 1.1, 0.8, 1.7], inf),
            \freq, Pseq([1700, 2100, 1550, 2400, 1920], inf),
            \resFreq, Pseq([420, 560, 380, 680, 490], inf)
        );

        5.do { |i|
            Ndef(\maquineAbyss).xset(\vaultTone, 55 + (i * 4), \breathRate, 0.08 + (i * 0.015));
            2.5.wait;
        };

        "0:25 - [Câmara IV & V: Salão do Trono - O Gotejamento Polirrítmico Escava a Rocha]".postln;
        // Deep subterranean geological groan as weight of mountain settles
        Pbindef(\rumbleSeq,
            \instrument, \karstRumble,
            \out, ~synthBus,
            \dur, Pseq([4.5, 5.2, 3.8], inf),
            \freq, Pseq([42, 36, 48], inf),
            \pan, Pwhite(-0.4, 0.4, inf),
            \amp, Pwhite(0.35, 0.5, inf),
            \dur, 5.0
        ).play;

        // Rapid cascade of mineralized drops pooling into underground river
        Pbindef(\dropSeq,
            \dur, Pseq([0.28, 0.35, 0.22, 0.44, 0.18, 0.52], inf),
            \freq, Pwhite(1300, 2800, inf),
            \resFreq, Pseq([520, 650, 440, 780, 590, 880], inf),
            \amp, Pwhite(0.18, 0.36, inf)
        );

        4.do { |idx|
            Ndef(\masterMix).set(\wet10, 0.48 + (idx * 0.04));
            3.0.wait;
        };

        "0:37 - [Câmara VI & VII: Salão das Fadas - Transfiguração em Luz e Cristal]".postln;
        // Intrinsic limit: high-density drip cascade with shimmering stalactite harmonic clusters
        Pbindef(\rumbleSeq).stop;
        Ndef(\calciteSeep).fadeTime = 3.0;
        Ndef(\calciteSeep).xset(\amp, 0.32, \density, 24);

        Pbindef(\curtainSeq,
            \dur, Pseq([1.2, 0.8, 0.6, 1.4, 0.9], inf),
            \freq, Pseq([659.25, 880, 987.77, 1174.66, 1318.51], inf), // Pure crystalline upper harmonics
            \strike, 1.4,
            \dur, Pwhite(3.0, 5.0, inf),
            \amp, Pwhite(0.15, 0.26, inf)
        );

        4.do { |step|
            Ndef(\maquineAbyss).xset(\airLoss, 1200 - (step * 150));
            3.0.wait;
        };

        "0:49 - [Settling & Extrinsic Limit: A Escuridão Perpétua Reassume a Caverna]".postln;
        // Gradual stopping of active layers, leaving solitary drops echoing into absolute stillness
        Pbindef(\curtainSeq).stop;
        Ndef(\calciteSeep).fadeTime = 4.0;
        Ndef(\calciteSeep).xset(\amp, 0.0);

        // Returns to slow singular drops echoing in the 7th chamber
        Pbindef(\dropSeq,
            \dur, Pseq([2.5, 3.2, 4.0], inf),
            \freq, Pseq([1580, 1260, 1420], inf),
            \resFreq, Pseq([340, 280, 310], inf),
            \dec, 3.2,
            \amp, Pseq([0.28, 0.20, 0.14], inf)
        );

        Ndef(\maquineAbyss).fadeTime = 6.0;
        Ndef(\maquineAbyss).xset(\amp, 0.08, \vaultTone, 46);

        6.0.wait;

        // Final drop echoing into the vast dark
        Pbindef(\dropSeq).stop;
        Synth(\maquineDrop, [\out, ~synthBus, \freq, 1380, \resFreq, 285, \dec, 4.5, \pan, 0.0, \amp, 0.28]);

        Ndef(\maquineAbyss).fadeTime = 5.0;
        Ndef(\maquineAbyss).xset(\amp, 0.0);

        5.5.wait;

        // Scoped Termination: Clean strictly the objects declared in this piece
        Pbindef(\dropSeq).stop; Pbindef(\dropSeq).clear;
        Pbindef(\curtainSeq).stop; Pbindef(\curtainSeq).clear;
        Pbindef(\rumbleSeq).stop; Pbindef(\rumbleSeq).clear;

        Ndef(\maquineAbyss).clear(1);
        Ndef(\calciteSeep).clear(1);
        Ndef(\masterMix).clear(1);

        "Score Complete: Gruta do Maquiné - As águas e o silêncio de Lund preservados.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

