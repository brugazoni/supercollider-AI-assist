// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-12T22:27:02.533659+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: "antarctic" - tempestade contida, vento grave e sub-drone que se acumula sob o silêncio da mesa
Ndef(\antarctic, { |amp=0.15, cutoff=300, rq=0.5|
    var wind, drone, lfo, sig;
    lfo = LFNoise2.kr(0.05).range(0.3, 1);
    wind = BPF.ar(BrownNoise.ar, cutoff * lfo, rq);
    drone = SinOsc.ar(55) * 0.3 * LFNoise1.kr(0.1).range(0.2, 1);
    sig = (wind * 4) + drone;
    Pan2.ar(LeakDC.ar(sig.tanh) * amp, LFNoise1.kr(0.03));
}).play;

// ADD_INSTRUMENT: "crease" - dobras de mapa rodoviário, cada vez mais rápidas e secas
Ndef(\crease, { |t_trig=0, amp=0.4, pan=0, rel=0.08|
    var env, crackle, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.002, rel);
    crackle = HPF.ar(WhiteNoise.ar, 3000) * env;
    sig = (BPF.ar(crackle, 5000, 0.5) * 6) + (crackle * 0.5);
    Pan2.ar(sig * amp, pan);
}).play;

// Sequência: dobras aceleram em direção à ruptura (Extrinsic Limit / Intrinsic Limit)
Pbindef(\creaseSeq,
    \dur, Pseq([1.2, 0.8, 0.6, 0.4, 0.25, 0.15, 0.1, 0.07, 0.07, 0.07], inf),
    \t_trig, 1,
    \amp, Pwhite(0.1, 0.4, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \rel, Pexprand(0.05, 0.2, inf)
);

Ndef(\crease)[1] = \set -> Pbindef(\creaseSeq);

// Rollback: remove this instrument
// Pbindef(\creaseSeq).stop; Ndef(\crease).fadeTime = 2; Ndef(\crease).clear(2);
// Pbindef(\creaseSeq).stop; Ndef(\antarctic).fadeTime = 2; Ndef(\antarctic).clear(2);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: "chains" - tinir de ferros e estalar de açoite, sob o brilho avermelhado do tombadilho
Ndef(\chains, { |t_trig=0, amp=0.3, pan=0, freq=1800, rel=0.25|
    var env, clank, whip, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, rel);
    clank = Ringz.ar(WhiteNoise.ar * env, [freq, freq * 1.47, freq * 2.13], [0.4, 0.25, 0.15]).sum;
    whip = HPF.ar(WhiteNoise.ar, 2500) * Decay.ar(K2A.ar(t_trig), 0.003) * 3;
    sig = (clank * 0.4) + whip;
    Pan2.ar(sig.tanh * amp, pan);
}).play;

// Sequência: golpes irregulares de corrente e açoite, espalhados pelo convés
Pbindef(\chainSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1.0, 0.125, 0.125, 0.5, 0.75], inf),
    \t_trig, 1,
    \amp, Pwhite(0.2, 0.5, inf),
    \pan, Pwhite(-0.9, 0.9, inf),
    \freq, Pexprand(900, 2600, inf),
    \rel, Pexprand(0.1, 0.4, inf)
);

Ndef(\chains)[1] = \set -> Pbindef(\chainSeq);

// Rollback: remove this instrument
// Pbindef(\chainSeq).stop; Ndef(\chains).fadeTime = 2; Ndef(\chains).clear(2);
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

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Brass escapement tick
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.3, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, 0.12, 1, -6), doneAction: 2);
        sig = Ringz.ar(WhiteNoise.ar * env, [freq, freq * 2.76, freq * 5.4], [0.12, 0.06, 0.03]).sum;
        sig = sig + (HPF.ar(WhiteNoise.ar, 6000) * env * 0.3);
        Out.ar(out, Pan2.ar(sig.tanh * amp, pan));
    }).add;

    // Pendulum escape click
    SynthDef(\escapeClick, { |out=0, freq=900, amp=0.25, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0005, 0.04, 1, -8), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.2) * env * 8;
        Out.ar(out, Pan2.ar(sig.tanh * amp, pan));
    }).add;

    // Carillon bell with inharmonic FM
    SynthDef(\chimeBell, { |out=0, freq=660, amp=0.2, pan=0|
        var env, sig, mod;
        env = EnvGen.ar(Env.perc(0.005, 2.5, 1, -3), doneAction: 2);
        mod = SinOsc.ar(freq * 3.51, 0, freq * 1.2 * EnvGen.ar(Env.perc(0.001, 0.3)));
        sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // Continuous air around the pendulums
    Ndef(\pendulumAir, { |amp=0, cut=1200|
        var breath, sig;
        breath = LFNoise2.kr(0.07).range(0.2, 1);
        sig = BPF.ar(PinkNoise.ar([1, 1]), cut * breath, 0.3) * 6;
        sig = sig + (SinOsc.ar([110, 111.3]) * 0.04 * breath);
        (sig * amp).tanh;
    }).play;

    // Beating drift between detuned escapements
    Ndef(\beatDrift, { |amp=0, spread=0.4|
        var sig, pan;
        sig = Ringz.ar(Impulse.ar([2.0, 2.0 * 1.0031, 2.0 * 0.9972]), 1800, 0.02).sum * 0.5;
        pan = LFNoise1.kr(0.05).range(spread.neg, spread);
        Pan2.ar(sig.tanh * amp, pan);
    }).play;

    Ndef(\pendulumAir).fadeTime = 4;
    Ndef(\beatDrift).fadeTime = 3;
    Ndef(\pendulumAir).set(\amp, 0);
    Ndef(\beatDrift).set(\amp, 0);

    // Three clocks at slightly different tempi
    Pbindef(\clockA, \instrument, \brassTick, \dur, 0.5, \freq, 2400, \amp, 0.22, \pan, -0.6, \out, ~synthBus);
    Pbindef(\clockB, \instrument, \brassTick, \dur, 0.50185, \freq, 2430, \amp, 0.2, \pan, 0.0, \out, ~synthBus);
    Pbindef(\clockC, \instrument, \brassTick, \dur, 0.49815, \freq, 2370, \amp, 0.2, \pan, 0.6, \out, ~synthBus);

    // Escapement acceleration toward rupture
    Pbindef(\escapeSeq,
        \instrument, \escapeClick,
        \dur, Pn(Pseq([0.4, 0.3, 0.2, 0.14, 0.1, 0.07, 0.05, 0.04], 1), inf),
        \freq, Pexprand(700, 1800, inf),
        \amp, Pwhite(0.12, 0.3, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \out, ~synthBus
    );

    // Sparse carillon fragments
    Pbindef(\chimeSeq,
        \instrument, \chimeBell,
        \dur, Pexprand(1.5, 4.0, inf),
        \freq, Pseq([660, 880, 587, 740], inf),
        \amp, Pwhite(0.12, 0.22, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    // Mixer with optional room
    Ndef(\masterMix, {
        var mix = In.ar(~synthBus, 2) + Ndef.ar(\pendulumAir, 2) + Ndef.ar(\beatDrift, 2);
        mix;
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25) };
    Ndef(\masterMix).set(\wet10, 0.25);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: One pendulum breathes alone]".postln;
        Pbindef(\clockA).play;
        Ndef(\pendulumAir).xset(\amp, 0.35);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(700, 2200)); 2.wait; };

        "0:08 - [Cue 2: A second clock drifts in]".postln;
        Pbindef(\clockB).play;
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(500, 2800)); 2.wait; };

        "0:16 - [Cue 3: Third clock, beating appears]".postln;
        Pbindef(\clockC).play;
        Ndef(\beatDrift).xset(\amp, 0.18);
        4.do { |i| Ndef(\beatDrift).xset(\spread, rrand(0.2, 0.9)); 2.wait; };

        "0:24 - [Cue 4: Intrinsic limit, escapement accelerates]".postln;
        Pbindef(\escapeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.3);
        6.wait;
        Pbindef(\clockA).stop;
        4.wait;

        "0:34 - [Cue 5: Settling, only clockB and carillon]".postln;
        Pbindef(\escapeSeq).stop;
        Pbindef(\chimeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.1);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(400, 1200)); 2.wait; };

        "0:46 - [Cue 6: Flashback to the opening clock]".postln;
        Pbindef(\clockA).play;
        Ndef(\beatDrift).xset(\amp, 0.22);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(800, 2000)); 2.wait; };

        "0:54 - [Cue 7: Resolution, all clocks in phase drift]".postln;
        Pbindef(\escapeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.25);
        Ndef(\masterMix).set(\wet10, 0.4);
        4.do { |i| Ndef(\beatDrift).xset(\spread, rrand(0.3, 0.8)); 2.wait; };

        "1:02 - [Cue 8: Extrinsic cut]".postln;
        Ndef(\pendulumAir).xset(\amp, 0);
        Ndef(\beatDrift).xset(\amp, 0);
        3.wait;

        Pbindef(\clockA).stop; Pbindef(\clockA).clear;
        Pbindef(\clockB).stop; Pbindef(\clockB).clear;
        Pbindef(\clockC).stop; Pbindef(\clockC).clear;
        Pbindef(\escapeSeq).stop; Pbindef(\escapeSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Ndef(\pendulumAir).clear(3);
        Ndef(\beatDrift).clear(3);
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

    // Safety limiter
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete sources
    SynthDef(\mqDrip, { |out=0, freq=1200, amp=0.2, pan=0|
        var env, sig, click;
        env = EnvGen.ar(Env.perc(0.001, 0.7, 1, -6), doneAction: 2);
        sig = SinOsc.ar(freq * XLine.kr(1.5, 1, 0.04)) * env;
        click = BPF.ar(WhiteNoise.ar, freq * 2.5, 0.2) * EnvGen.ar(Env.perc(0.001, 0.008)) * 0.6;
        Out.ar(out, Pan2.ar((sig + click).tanh * amp, pan));
    }).add;

    SynthDef(\mqStalac, { |out=0, freqscale=1, amp=0.2, pan=0, ring=1|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, (3.0 * ring).max(0.05), 1, -4), doneAction: 2);
        exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        sig = DynKlank.ar(Ref([[312, 785, 1243, 1871, 2650], [1, 0.6, 0.35, 0.2, 0.1], [1.0, 0.8, 0.6, 0.4, 0.3]]), exc, freqscale, 0, ring);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\mqCave, { |amp=0, cut=600|
        var base, sig, swell;
        swell = LFNoise1.kr(0.2).range(0.6, 1.0);
        base = BrownNoise.ar(0.05) + SinOsc.ar(48, 0, 0.04);
        sig = LPF.ar([base, base * 0.98 + PinkNoise.ar(0.01)], cut);
        sig = CombC.ar(sig, 0.5, [0.173, 0.211], 3.5) * 0.4 + sig;
        (sig * swell * amp).tanh;
    });

    Ndef(\mqWater, { |amp=0|
        var sig;
        sig = BPF.ar(PinkNoise.ar(0.3), LFNoise1.kr(0.12).range(250, 800), 0.08) * 6;
        [sig, DelayC.ar(sig, 0.03, 0.013)] * amp;
    });

    // Master mixer
    Ndef(\mqMix, {
        var mix = In.ar(~synthBus, 2) + Ndef.ar(\mqCave, 2) + Ndef.ar(\mqWater, 2);
        mix * 0.8;
    });
    Ndef(\mqMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
    Ndef(\mqMix).set(\wet10, 0.25);
    Ndef(\mqCave).fadeTime = 4;
    Ndef(\mqWater).fadeTime = 3;
    Ndef(\mqMix).play;
    Ndef(\mqCave).play;
    Ndef(\mqWater).play;
    s.sync;

    // Patterns
    Pbindef(\mqDripSeq,
        \instrument, \mqDrip,
        \dur, Pexprand(0.9, 2.2, inf),
        \freq, Pexprand(900, 2600, inf),
        \amp, Pwhite(0.1, 0.25, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \out, ~synthBus
    );

    Pbindef(\mqBellSeq,
        \instrument, \mqStalac,
        \dur, Pexprand(1.2, 3.5, inf),
        \freqscale, Pseq([0.8, 1.2, 1.0, 0.6], inf),
        \ring, Pwhite(0.6, 1.2, inf),
        \amp, Pwhite(0.15, 0.28, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    Tdef(\mqScore, {
        0.5.wait;

        "0:00 - [Cue 1: A single drip in the dark]".postln;
        Ndef(\mqCave).xset(\amp, 0.5);
        Pbindef(\mqDripSeq).play;
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(300, 900)); 2.wait; };

        "0:16 - [Cue 2: Stalactite bells answer the drip]".postln;
        Pbindef(\mqBellSeq).play;
        Ndef(\mqWater).xset(\amp, 0.3);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(400, 1400)); 2.wait; };

        "0:32 - [Cue 3: Accelerating drips, water rises]".postln;
        Pbindef(\mqDripSeq, \dur, Pn(Pseq([0.5, 0.4, 0.3, 0.22, 0.16, 0.12, 0.1, 0.08], 1), inf));
        8.do { |i| Ndef(\mqWater).xset(\amp, rrand(0.2, 0.5)); 2.wait; };

        "0:48 - [Cue 4: Intrinsic limit, drip density collapses into roar]".postln;
        Pbindef(\mqDripSeq, \dur, Pexprand(0.03, 0.06, inf));
        Pbindef(\mqBellSeq, \ring, Pwhite(1.2, 2.0, inf));
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(2000, 5000)); 2.wait; };

        "1:04 - [Cue 5: Settling, one bell in vast stone]".postln;
        Pbindef(\mqDripSeq).stop;
        Pbindef(\mqDripSeq, \dur, Pexprand(2.5, 4.5, inf));
        Pbindef(\mqBellSeq, \dur, Pexprand(4.0, 6.0, inf), \ring, Pwhite(0.6, 1.0, inf));
        Pbindef(\mqDripSeq).play;
        Ndef(\mqCave).xset(\cut, 250);
        8.do { |i| Ndef(\mqWater).xset(\amp, rrand(0.1, 0.25)); 2.wait; };

        "1:20 - [Cue 6: Flashback to the opening drip motif]".postln;
        Pbindef(\mqDripSeq, \dur, Pn(Pseq([0.9, 1.4, 0.9, 2.2], 1), inf));
        Ndef(\mqWater).xset(\amp, 0.3);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(300, 1000)); 2.wait; };

        "1:36 - [Cue 7: Resolution, bells and drips in echo]".postln;
        Pbindef(\mqBellSeq, \dur, Pexprand(1.2, 3.5, inf), \ring, Pwhite(0.6, 1.2, inf));
        Pbindef(\mqBellSeq).play;
        Ndef(\mqMix).set(\wet10, 0.45);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(500, 1600)); Ndef(\mqWater).xset(\amp, rrand(0.2, 0.4)); 2.wait; };

        "1:52 - [Cue 8: Extrinsic cut]".postln;
        Ndef(\mqCave).xset(\amp, 0);
        Ndef(\mqWater).xset(\amp, 0);
        3.wait;

        Pbindef(\mqDripSeq).stop; Pbindef(\mqDripSeq).clear;
        Pbindef(\mqBellSeq).stop; Pbindef(\mqBellSeq).clear;
        Ndef(\mqCave).clear(3);
        Ndef(\mqWater).clear(3);
        Ndef(\mqMix).clear(2);
        "Score Complete.".postln;
        Tdef(\mqScore).stop;
    });
    Tdef(\mqScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: FALLBACK
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)


// ============================================================
// ROUND 06 | MODE: DESIGN | FRAG #86
// STATUS: FIXED
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

// ---- Step 0: CC map ----
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64, hpf3: 65, lpf3: 66, rq3: 67, atk3: 68, dec3: 69, sus3: 70, rls3: 71, fx3: 72,
    delMix: 90, verbMix: 91, panic: 123
);

// ---- Step 1 & 2: MIDI discovery with fallback ----
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

// ---- Step 3: Boot, buses, synths, GUI ----
s.waitForBoot({
    var zoneNotesInit;

    ~ccVals = (
        vol1: 0.25, pan1: 0.0, mute1: 0.0, min1: 0, max1: 127, hpf1: 60, lpf1: 6000, rq1: 0.6, atk1: 0.002, dec1: 0.6, sus1: 0.0, rls1: 0.4, fx1: 0.0,
        vol2: 0.25, pan2: -0.35, mute2: 0.0, min2: 0, max2: 127, hpf2: 200, lpf2: 8000, rq2: 0.5, atk2: 0.002, dec2: 0.5, sus2: 0.0, rls2: 0.5, fx2: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 0, max3: 127, hpf3: 300, lpf3: 5000, rq3: 0.7, atk3: 0.01, dec3: 0.8, sus3: 0.3, rls3: 1.5, fx3: 0.0,
        delMix: 0.0, verbMix: 0.0
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.newClear(128);
    ~ui = ();

    // Zone 1: Caixa-Gunga sub body (berimbau's low bass gourd resonance)
    SynthDef(\berimZone1, { |freq=110, gate=1, amp=0.3, pan=0.0, vol=0.25, mute=0, hpf=60, lpf=6000, rq=0.6, atk=0.002, dec=0.6, sus=0, rls=0.4, fx=0|
        var env, exc, body, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        exc = Impulse.ar(0) * 0 + Decay2.ar(Impulse.ar(0), 0.001, 0.05 + (fx * 0.1)) * WhiteNoise.ar(0.4);
        body = DynKlank.ar(Ref([[freq, freq * 2.01, freq * 3.02], [1.0, 0.4, 0.15], [1.2, 0.6, 0.3]]), exc * (1 + (fx * 4)));
        sig = (body * env * amp).tanh * (1 - mute);
        sig = HPF.ar(LPF.ar(sig, lpf), hpf);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    // Zone 2: Dobrão metal clang (plucked-metal bright strike, Karplus-like)
    SynthDef(\berimZone2, { |freq=440, gate=1, amp=0.3, pan=(-0.35), vol=0.25, mute=0, hpf=200, lpf=8000, rq=0.5, atk=0.002, dec=0.5, sus=0, rls=0.5, fx=0|
        var env, exc, sig, ring;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        exc = WhiteNoise.ar(0.5) * Decay.ar(Impulse.ar(0), 0.003);
        ring = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.2 + (fx * 3));
        ring = AllpassC.ar(ring, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = RLPF.ar(ring, lpf, rq) * env * amp;
        sig = HPF.ar(sig, hpf) * (1 - mute);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    // Zone 3: Caxixi shaker texture (filtered noise swish)
    SynthDef(\berimZone3, { |freq=220, gate=1, amp=0.3, pan=0.35, vol=0.2, mute=0, hpf=300, lpf=5000, rq=0.7, atk=0.01, dec=0.8, sus=0.3, rls=1.5, fx=0|
        var env, noise, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        noise = BPF.ar(PinkNoise.ar(1), freq * 4, rq.clip(0.1, 1.0)) * (1 + (fx * 6));
        sig = (noise * env * amp).tanh;
        sig = HPF.ar(LPF.ar(sig, lpf), hpf) * (1 - mute);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    s.sync;

    // Safety limiter + master
    SynthDef(\safetyLimiter, { |delMix=0, verbMix=0|
        var sig = In.ar(0, 2);
        var del = DelayC.ar(sig, 0.5, 0.31) * delMix;
        sig = sig + del;
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, 0.85, 0.3);
        ReplaceOut.ar(0, LeakDC.ar(Limiter.ar(sig, 0.92, 0.01)));
    }).add;

    s.sync;
    ~master = Synth.new(\safetyLimiter, [\delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap], ~masterGroup, \addToTail);

    // Zone triggering helpers
    ~zoneDefs = [\berimZone1, \berimZone2, \berimZone3];

    MIDIdef.noteOn(\berimOn, { |vel, noteNum|
        3.do { |z|
            var zi = z + 1;
            var mn = ~ccVals[("min" ++ zi).asSymbol];
            var mx = ~ccVals[("max" ++ zi).asSymbol];
            if((noteNum >= mn) and: { noteNum <= mx }) {
                var args = [\freq, noteNum.midicps, \amp, vel / 127.0, \gate, 1,
                    \pan, ~buses[("pan" ++ zi).asSymbol].asMap,
                    \vol, ~buses[("vol" ++ zi).asSymbol].asMap,
                    \mute, ~buses[("mute" ++ zi).asSymbol].asMap,
                    \hpf, ~buses[("hpf" ++ zi).asSymbol].asMap,
                    \lpf, ~buses[("lpf" ++ zi).asSymbol].asMap,
                    \rq, ~buses[("rq" ++ zi).asSymbol].asMap,
                    \atk, ~buses[("atk" ++ zi).asSymbol].asMap,
                    \dec, ~buses[("dec" ++ zi).asSymbol].asMap,
                    \sus, ~buses[("sus" ++ zi).asSymbol].asMap,
                    \rls, ~buses[("rls" ++ zi).asSymbol].asMap,
                    \fx, ~buses[("fx" ++ zi).asSymbol].asMap];
                var syn = Synth(~zoneDefs[z], args, ~synthGroup, \addToTail);
                if(~zoneNotes[noteNum].isNil) { ~zoneNotes[noteNum] = [] };
                ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(syn);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\berimOff, { |vel, noteNum|
        if(~zoneNotes[noteNum].notNil) {
            ~zoneNotes[noteNum].do(_.set(\gate, 0));
            ~zoneNotes[noteNum] = [];
        };
    }, srcID: ~myUid);

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
                    { ks.contains("delMix") or: { ks.contains("verbMix") } } { norm }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            ~zoneNotes.do { |list| if(list.notNil) { list.do(_.set(\gate, 0)) } };
            ~zoneNotes = Array.newClear(128);
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var win, zoneNames, tabs;
        var screen = Window.availableBounds;
        var h = min(780, screen.height - 60);
        win = Window("Berimbau de Barriga", Rect((screen.width - 760) / 2, (screen.height - h) / 2, 760, h), scroll: true);
        ~mainWin = win;
        zoneNames = ["Caixa (Sub)", "Dobrão (Metal)", "Caxixi (Textura)"];
        ~zoneMeta = [
            (title: "Caixa", fxKey: \fx1, fxLabel: "Body Drive"),
            (title: "Dobrão", fxKey: \fx2, fxLabel: "Ring Decay"),
            (title: "Caxixi", fxKey: \fx3, fxLabel: "Swish Gain")
        ];
        ~zoneMeta.do { |zm, idx|
            var zi = idx + 1;
            var page = CompositeView(win, Rect(10, 10, 740, h - 110));
            var lbl = StaticText(page, Rect(10, 5, 720, 24)).string_(zoneNames[idx]).font_(Font.sansSerif(16, true));
            var zk = { |base| (base ++ zi).asSymbol };
            var knobs = [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, zm[\fxKey].asString.drop(2).asSymbol];
            knobs.do { |base, j|
                var key = if(base.isKindOf(Symbol) and: { base == zm[\fxKey].asString.drop(2).asSymbol }) { zm[\fxKey] } { zk.(base) };
                // EZSlider itself exposes value_/action; no .slider accessor in this build
                var ez = EZSlider(page, Rect(10 + (j * 70), 40, 66, 300), key.asString, ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
                    ~ccVals[key] = sl.value;
                    if(~buses[key].notNil) { ~buses[key].set(sl.value) };
                }, ~ccVals[key] ? 0, false, 9, 0);
                ~ui = ~ui ?? { () };
                ~ui[key] = ez;
            };
            Button(page, Rect(10, h - 170, 200, 26)).states_([[zm[\title], Color.white, Color.grey]]);
        };
        ~ui = ~ui ?? { () };
        ~ui[\delMix] = EZSlider(win, Rect(10, h - 100, 360, 24), "Delay Mix", ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
            ~ccVals[\delMix] = sl.value; ~buses[\delMix].set(sl.value) }, 0.0, false, 9, 0);
        ~ui[\verbMix] = EZSlider(win, Rect(380, h - 100, 360, 24), "Reverb Mix", ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
            ~ccVals[\verbMix] = sl.value; ~buses[\verbMix].set(sl.value) }, 0.0, false, 9, 0);
        Button(win, Rect(260, h - 55, 240, 34))
            .states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({
                ~zoneNotes.do { |list| if(list.notNil) { list.do(_.set(\gate, 0)) } };
                ~zoneNotes = Array.newClear(128);
            });
        win.front;

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
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: gungas metálicas (Layer 2), caixa/tambor de couro (Layer 1), viola/melodia modal (Layer 3), ar de terreiro (Layer 4)
Ndef(\gungas).fadeTime = 2;
Ndef(\caixa).fadeTime = 2;
Ndef(\viola).fadeTime = 3;
Ndef(\terreiro).fadeTime = 4;

// Layer 1: tambor de couro grave (bumbo/caixa) com 2o harmônico
Ndef(\caixa, { |t_trig=0, amp=0.22, freq=58, pan=(-0.2)|
    var env = Env.perc(0.002, 0.35, 1, -6).ar(0, K2A.ar(t_trig));
    var pitch = freq * EnvGen.kr(Env([2.2, 1, 1], [0.04, 1]), t_trig);
    var body = SinOsc.ar(pitch) + (SinOsc.ar(pitch * 2) * 0.25);
    var skin = LPF.ar(PinkNoise.ar(0.25), 2200) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.05);
    var sig = ((body * env) + skin).tanh * amp;
    Pan2.ar(sig, pan);
}).play;
Ndef(\caixa).set(\wet10, 0.15);

Pbindef(\caixaSeq,
    \dur, Pn(Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.75], 1), inf),
    \t_trig, 1,
    \freq, Pwrand([58, 64.5, 52], [0.7, 0.2, 0.1], inf),
    \amp, Pwhite(0.16, 0.24, inf)
);
Ndef(\caixa)[1] = \set -> Pbindef(\caixaSeq);
Ndef(\caixa).quant = 1;

// Layer 2: gungas de lata (percussão metálica nos tornozelos)
Ndef(\gungas, { |t_trig=0, amp=0.14, pan=0.35|
    var env = Env.perc(0.001, 0.12, 1, -9).ar(0, K2A.ar(t_trig));
    var ring = Ringz.ar(K2A.ar(t_trig), [2310, 3475, 5120, 6890], [0.06, 0.05, 0.04, 0.03]).sum;
    var clink = BPF.ar(WhiteNoise.ar(1), 4200, 0.08) * 12;
    var sig = ((ring * 0.6) + (clink * 0.4)) * env * amp;
    Balance2.ar(sig, sig, pan + SinOsc.kr(0.07, 0, 0.2));
}).play;
Ndef(\gungas).set(\wet11, 0.2);

Pbindef(\gungasSeq,
    \dur, Pn(Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], 1), inf),
    \t_trig, 1,
    \amp, Pwrand([0.10, 0.16, 0.22], [0.5, 0.35, 0.15], inf),
    \pan, Pwhite(0.2, 0.6, inf)
);
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);
Ndef(\gungas).quant = 1;

// Layer 3: viola de arco modal (voz melódica em modo menor/dórico)
Ndef(\viola, { |t_trig=0, freq=220, amp=0.16, cutoff=900, pan=(-0.5)|
    var env = Env([0, 1, 0.7, 0], [0.05, 0.6, 1.2]).ar(0, K2A.ar(t_trig));
    var f = freq * [1, 1.005, 0.997];
    var sig = Saw.ar(f) * 0.5 + Pulse.ar(f * 0.5, 0.4) * 0.3;
    sig = MoogFF.ar(sig, cutoff + SinOsc.kr(0.11, 0, 180), 2.2);
    sig = (sig * env * amp * 3).tanh;
    Balance2.ar(sig.sum, sig.sum, pan);
}).play;
Ndef(\viola).set(\wet10, 0.3);

Pbindef(\violaSeq,
    \dur, Pn(Pseq([1.5, 0.5, 1, 1], 1), inf),
    \t_trig, 1,
    \freq, Pn(Pseq([220, 261.6, 293.7, 207.7, 196], 1), inf),
    \cutoff, Pexprand(500, 1800, inf),
    \amp, Pwhite(0.12, 0.2, inf)
);
Ndef(\viola)[1] = \set -> Pbindef(\violaSeq);
Ndef(\viola).quant = 1;

// Layer 4: ar de terreiro (granulado e canopy)
Ndef(\terreiro, { |amp=0.05|
    var dust = Dust.ar(18!2) * 0.4;
    var hiss = BPF.ar(PinkNoise.ar(0.4!2), 3800, 0.6) * 4;
    var swell = LPF.ar(BrownNoise.ar(0.3!2), 300) * (0.6 + SinOsc.kr(0.05, 0, 0.4));
    (dust + hiss + swell) * amp;
}).play;
Ndef(\terreiro).set(\wet10, 0.35);

// Efeitos
Ndef(\caixa)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.3, 0.7, 0.4) };
Ndef(\viola)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.6, 0.8, 0.5) };
Ndef(\gungas)[11] = \filter -> { |in| CombC.ar(in, 0.5, 0.23, 2.0) * 0.5 };
)

// Ndef(\viola).xset(\cutoff, 1800); // Brilho da viola | Revert: Ndef(\viola).xset(\cutoff, 900);
// Pbindef(\gungasSeq, \dur, Pn(Pseq([0.125, 0.125, 0.25], 1), inf)); // Gungas em dobro | Revert: Pbindef(\gungasSeq, \dur, Pn(Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], 1), inf));
// Pbindef(\caixaSeq).stop; Ndef(\caixa).fadeTime = 4; Ndef(\caixa).clear(4); // Rollback caixa
// Ndef(\terreiro).set(\amp, 0.02); // Ar mais discreto | Revert: Ndef(\terreiro).set(\amp, 0.05);


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: PASS
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// Pantanal entardecer: corixo grave (Layer 1), araras em FM (Layer 2), tuiuiús modais (Layer 3), canopy de dusk (Layer 4)
Ndef(\corixo).fadeTime = 4;
Ndef(\araras).fadeTime = 2;
Ndef(\tuiuis).fadeTime = 2;
Ndef(\crepusculo).fadeTime = 5;

// Layer 1: corixo, pad grave com harmônico de 2a ordem e filtro Moog lento
Ndef(\corixo, { |amp=0.18, cutoff=420, pan=(-0.3)|
    var f = 55 * [0.995, 1, 1.004];
    var swell = 0.7 + (SinOsc.kr(0.03, 0, 0.3));
    var sig = (Saw.ar(f) * 0.5 + Pulse.ar(f * 0.5, 0.5) * 0.3).sum;
    sig = sig + (SinOsc.ar(110) * 0.12);
    sig = MoogFF.ar(sig, cutoff + SinOsc.kr(0.05, 0, 120), 1.2);
    sig = (sig * amp * swell).tanh;
    Pan2.ar(sig, pan);
}).play;
Ndef(\corixo).set(\wet10, 0.3);

// Layer 2: araras-azuis, chamados FM com índice decrescente e razão inarmônica
Ndef(\araras, { |t_trig=0, freq=660, amp=0.12, pan=0.4|
    var env = Env.perc(0.01, 0.5, 1, -4).ar(0, K2A.ar(t_trig));
    var modEnv = EnvGen.kr(Env.perc(0.005, 0.3, 1, -5), t_trig);
    var mod = SinOsc.ar(freq * 2.71) * (freq * 1.3 * modEnv);
    var car = SinOsc.ar(freq + mod);
    var sig = car * env * amp;
    Pan2.ar(sig, pan + SinOsc.kr(0.13, 0, 0.15));
}).play;
Ndef(\araras).set(\wet11, 0.25);

Pbindef(\ararasSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.35, 0.15], inf),
    \t_trig, 1,
    \freq, Pn(Pgeom(660, 1.12, 5), inf),
    \amp, Pwhite(0.08, 0.16, inf),
    \pan, Pwhite(0.2, 0.7, inf)
);
Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
Ndef(\araras).quant = 1;

// Layer 3: tuiuiús, clacks modais (exciter -> ressonadores harmônicos)
Ndef(\tuiuis, { |t_trig=0, amp=0.14, freq=180, pan=(-0.6)|
    var exc = Decay2.ar(K2A.ar(t_trig), 0.001, 0.02) * WhiteNoise.ar(1);
    var sig = Ringz.ar(exc, [freq, freq * 2.4, freq * 3.7], [0.5, 0.25, 0.12]).sum;
    sig = (sig * amp * 4).tanh;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\tuiuiSeq,
    \dur, Pn(Pseq([0.75, 0.25, 0.5, 1.0, 0.5, 0.25, 0.25, 0.5], 1), inf),
    \t_trig, 1,
    \freq, Pwrand([180, 240, 150], [0.6, 0.3, 0.1], inf),
    \amp, Pwhite(0.1, 0.18, inf),
    \pan, Pwhite((-0.8), (-0.2), inf)
);
Ndef(\tuiuis)[1] = \set -> Pbindef(\tuiuiSeq);
Ndef(\tuiuis).quant = 1;

// Layer 4: crepusculo, vento de mata, insetos (Dust) e brilho de horizonte
Ndef(\crepusculo, { |amp=0.05|
    var insects = Dust.ar(24 ! 2) * 0.35;
    var wind = BPF.ar(PinkNoise.ar(0.4 ! 2), 2600 + SinOsc.kr(0.04, 0, 700), 0.5) * 4;
    var warm = LPF.ar(BrownNoise.ar(0.25 ! 2), 260) * (0.6 + SinOsc.kr(0.05, 0, 0.4));
    (insects + wind + warm) * amp;
}).play;
Ndef(\crepusculo).set(\wet12, 0.4);

// Efeitos (slots 10..12, somente sinal 100% molhado)
Ndef(\corixo)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.5, 0.8, 0.4) };
Ndef(\araras)[11] = \filter -> { |in| CombC.ar(in, 0.5, 0.31, 1.5) * 0.4 };
Ndef(\crepusculo)[12] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.7, 0.9, 0.5) * 0.5 };
)

// Ndef(\corixo).xset(\cutoff, 700); // Mais luz no horizonte | Revert: Ndef(\corixo).xset(\cutoff, 420);
// Pbindef(\ararasSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.5, 0.3, 0.2], inf)); // Revoada acelera | Revert: Pbindef(\ararasSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.35, 0.15], inf));
// Pbindef(\tuiuiSeq, \freq, Pwrand([120, 180, 240], [0.3, 0.4, 0.3], inf)); // Tuiuiús mais graves | Revert: Pbindef(\tuiuiSeq, \freq, Pwrand([180, 240, 150], [0.6, 0.3, 0.1], inf));
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 4; Ndef(\araras).clear(4); // Rollback araras
// Ndef(\crepusculo).set(\amp, 0.02); // Noite mais discreta | Revert: Ndef(\crepusculo).set(\amp, 0.05);

