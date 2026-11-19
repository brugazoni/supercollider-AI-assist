// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-13T11:28:09.539952+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Formal Archetype: Intrinsic Limit (b) / Settling (c)
// Narrative: 27 years of suppressed domestic tension cracking over the folding of a road map; 
// crisp, neurotic percussive folding/creasing gestures suspended over a frozen, Antarctic-weight drone.

// --- INSTRUMENT 1: The Antarctic Silence / Suspended Wine Bottle (Deep Tension Drone) ---
Ndef(\antarcticDrone, { |freq=48, tension=0.2, amp=0.28, pan=0, detune=0.08|
    var sub, body, air, sig;
    sub = SinOsc.ar([freq, freq * 1.005] + (SinOsc.kr(0.05).range(detune.neg, detune))) * 0.6;
    body = MoogFF.ar(
        Saw.ar([freq * 0.5, freq * 0.502]) + Pulse.ar([freq, freq * 1.5], 0.3, 0.4),
        freq * LinExp.kr(tension, 0, 1, 1.5, 12),
        2.5
    ) * 3.0;
    air = BPF.ar(PinkNoise.ar, [freq * 8, freq * 12], 0.15).sum * (tension * 0.15);
    sig = (sub + body.tanh + air);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

// --- INSTRUMENT 2: The Map Folding (Obsessive, Dry, Neurotic Frictional Pulses) ---
Ndef(\mapFold, { |freq=1200, res=0.1, rq=0.04, amp=0.22, pan=0, t_trig=0, foldDrive=2.0|
    var trigSig, env, noise, foldImp, exciter, resSig, sig;
    trigSig = K2A.ar(t_trig);
    env = Decay2.ar(trigSig, 0.001, 0.035);
    noise = BPF.ar(WhiteNoise.ar, freq, rq) * 12.0;
    foldImp = Crackle.ar(1.97) * env;
    exciter = (noise + foldImp) * env;
    resSig = DynKlank.ar(
        `[
            [freq * 0.7, freq, freq * 1.42, freq * 2.18],
            [0.8, 1.0, 0.5, 0.25],
            [0.02, 0.04, 0.015, 0.01]
        ],
        exciter,
        decayscale: res
    );
    sig = (resSig * foldDrive).fold2(0.85);
    Pan2.ar(sig * amp, pan);
}).play;

// Sequence: Neurotic, detailed micro-foldings, precise mechanical repetition
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.5, 0.125, 0.375, 1.0], inf),
    \t_trig, 1,
    \freq, Pseq([1800, 2400, 1200, 3200, 2100, 950, 4200], inf),
    \rq, Pwhite(0.015, 0.06, inf),
    \res, Pseq([0.02, 0.05, 0.01, 0.08, 0.03], inf),
    \foldDrive, Pwhite(1.5, 3.8, inf),
    \pan, Pseq([-0.6, 0.4, -0.2, 0.7, -0.4, 0.1, 0.8], inf),
    \amp, Pseq([0.18, 0.22, 0.15, 0.28, 0.19, 0.12, 0.3], inf)
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// --- EFFECT: Frozen Cold Glaze on the Map Foldings (Frozen Reverberant Room) ---
Ndef(\mapFold)[10] = \filter -> { |in, revTime=4.5, damp=0.2|
    var rev = FreeVerb2.ar(in[0], in[1], 1.0, revTime.min(1.0), damp);
    rev * 0.9;
};
Ndef(\mapFold).set(\wet10, 0.18);

// Rollback:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Ndef(\antarcticDrone).fadeTime = 3; Ndef(\antarcticDrone).clear(3);
// Ndef(\mapFold).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockTdef;

    // Safety limiter and master bus setup
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

    // Discrete SynthDef: Brass Escapement Tick & Pocket Chronometer Click
    SynthDef(\horologyTick, {
        |out=0, freq=2800, dec=0.03, metalDec=0.08, amp=0.18, pan=0, drive=1.4, tone=1.0|
        var click, body, brass, env, sig;
        env = EnvGen.ar(Env.perc(0.0005, dec.max(0.005), 1, -8), doneAction: 2);
        click = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0001, 0.003));
        body = SinOsc.ar(freq * Line.kr(1.8, 1.0, 0.004)) * env;
        brass = DynKlank.ar(
            `[
                [freq * 0.8, freq * 1.37, freq * 2.22, freq * 3.45],
                [0.7, 0.9, 0.5, 0.3],
                [metalDec * 0.4, metalDec, metalDec * 0.6, metalDec * 0.3]
            ],
            click + (body * 0.3),
            freqscale: tone
        );
        sig = (body + (brass * 0.85) * drive).fold2(0.9);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    // Discrete SynthDef: Resonant French Pendulum Chime (Carrilhão)
    SynthDef(\frenchChime, {
        |out=0, freq=440, ring=2.5, amp=0.2, pan=0, strikeDamp=0.02|
        var hammer, chime, env, sig;
        env = EnvGen.ar(Env.perc(0.001, ring.max(0.1), 1, -4), doneAction: 2);
        hammer = LPF.ar(WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, strikeDamp)), freq * 6);
        chime = DynKlank.ar(
            `[
                [freq, freq * 2.76, freq * 5.4, freq * 8.91],
                [1.0, 0.45, 0.25, 0.12],
                [ring, ring * 0.7, ring * 0.4, ring * 0.2]
            ],
            hammer
        );
        sig = chime * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // Continuous Ndef 1: The Collective Clock Swarm (Defasagem / Gear Friction)
    Ndef(\clockSwarm, {
        |amp=0, density=28, spread=0.8, filterFreq=3200, drift=0.15|
        var trigs, gearTeeth, springs, woodCase, swarm, panCtrl;
        trigs = Dust.ar(density ! 2);
        gearTeeth = Decay.ar(trigs, 0.008) * BPF.ar(GrayNoise.ar(0.8 ! 2), filterFreq, 0.2);
        springs = Ringz.ar(trigs * 0.4, [1840, 2460] + SinOsc.kr(0.08, [0, pi]).range(drift.neg * 80, drift * 80), 0.04);
        woodCase = LPF.ar(HPF.ar(gearTeeth + springs, 160), 6500);
        swarm = woodCase * amp;
        panCtrl = SinOsc.kr(0.12).range(spread.neg * 0.4, spread * 0.4);
        if(swarm.isKindOf(Collection)) { Balance2.ar(swarm[0], swarm[1], panCtrl) } { Pan2.ar(swarm, panCtrl) };
    });

    // Continuous Ndef 2: "O Próprio Respirar do Tempo" (The Time-Breathe Infrasonic Swell)
    Ndef(\timeBreathe, {
        |amp=0, rate=0.12, cutoff=180, res=0.25, drive=1.5|
        var lfo, sub, brassRes, breath;
        lfo = SinOsc.kr(rate).range(0.1, 1.0);
        sub = SinOsc.ar([46.25, 46.4] + (lfo * 2.5)) * 0.5;
        brassRes = MoogFF.ar(
            PinkNoise.ar(0.3 ! 2) + Saw.ar([92.5, 93.2], 0.15),
            cutoff * lfo.linlin(0.1, 1.0, 0.8, 3.5),
            res * 3.8
        ) * drive;
        breath = (sub + brassRes).tanh * amp;
        if(breath.isKindOf(Collection)) { Balance2.ar(breath[0], breath[1], 0) } { Pan2.ar(breath, 0) };
    });

    // Master Mixer with Chamber Reverb and Narrow Mechanical Delay
    Ndef(\masterMix, {
        var busIn = In.ar(~synthBus, 2);
        var swarmIn = Ndef.ar(\clockSwarm, 2);
        var breathIn = Ndef.ar(\timeBreathe, 2);
        busIn + swarmIn + breathIn;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.35);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        CombL.ar(in, 0.25, [0.082, 0.114], 1.2);
    };

    Ndef(\masterMix).set(\wet10, 0.0);
    Ndef(\masterMix).set(\wet11, 0.0);
    Ndef(\masterMix).play;

    s.sync;

    // Fixed-Timeline Master Choreography
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [A Oficina de Santa Efigênia: O Enxame Desalinhado]".postln;

        // Transition from active previous map/antarctic state
        if (Ndef(\antarcticDrone).isPlaying) { Ndef(\antarcticDrone).fadeTime = 3; Ndef(\antarcticDrone).clear(3); };
        if (Ndef(\mapFold).isPlaying) { Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); };

        Ndef(\masterMix).set(\wet10, 0.12);
        Ndef(\masterMix).set(\wet11, 0.08);

        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).set(\amp, 0.25, \density, 18, \filterFreq, 2800);

        // Intricate polyrhythmic ticking patterns with microscopic phase shifts
        Pbindef(\chronometerTick,
            \instrument, \horologyTick,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.124, 0.126, 0.123, 0.127], inf),
            \freq, Pseq([2400, 3100, 2200, 3600, 2800], inf),
            \dec, Pwhite(0.015, 0.038, inf),
            \metalDec, Pwhite(0.04, 0.09, inf),
            \tone, Pwhite(0.92, 1.15, inf),
            \drive, Pwhite(1.2, 2.2, inf),
            \pan, Pseq([-0.7, -0.3, 0.2, 0.6, -0.1], inf),
            \amp, Pseq([0.16, 0.11, 0.2, 0.14, 0.18], inf)
        ).play;

        // Active waiting loop: Gradual accumulation of phase-displaced pocket watches
        6.do { |i|
            Ndef(\clockSwarm).set(\density, 20 + (i * 7), \filterFreq, 2800 + (i * 200));
            Pbindef(\chronometerTick).set(\drive, 1.2 + (i * 0.2));
            2.5.wait;
        };

        "0:15 - [O Pêndulo Maior: Carrilhão Francês ecoa na estreiteza]".postln;
        Pbindef(\pendulumChime,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([3.0, 2.75, 3.25, 2.5], inf),
            \freq, Pseq([220, 293.66, 329.63, 196], inf),
            \ring, Pwhite(2.8, 4.2, inf),
            \pan, Pseq([-0.4, 0.5, -0.2, 0.3], inf),
            \amp, 0.22
        ).play;

        4.do { |i|
            Ndef(\clockSwarm).set(\spread, 0.4 + (i * 0.15));
            3.0.wait;
        };

        "0:27 - [A Defasagem Extrema: O Enxame em Clímax Mecânico]".postln;
        // Intrinsic Limit (b): Frequency density and gearing driven to saturation
        Ndef(\masterMix).set(\wet10, 0.22);
        Ndef(\masterMix).set(\wet11, 0.18);
        Ndef(\clockSwarm).fadeTime = 2;
        Ndef(\clockSwarm).set(\density, 85, \filterFreq, 5200, \drift, 0.4, \amp, 0.38);

        Pbindef(\chronometerTick).set(
            \dur, Pseq([0.0625, 0.0618, 0.0632, 0.0620], inf),
            \amp, 0.14
        );

        3.do { |i|
            Ndef(\clockSwarm).set(\filterFreq, 5200 + (i * 600));
            Pbindef(\pendulumChime).set(\freq, (220 * (1.1 ** (i + 1))));
            2.8.wait;
        };

        "0:35 - [O Olhar Interior: Fechando os Olhos no Vazio do Tempo]".postln;
        // Settling / Flashback (c): Abrupt drop of mechanical chatter into the breathing resonator
        Pbindef(\chronometerTick).stop;
        Ndef(\clockSwarm).fadeTime = 4;
        Ndef(\clockSwarm).set(\amp, 0.04, \filterFreq, 1400);

        Ndef(\timeBreathe).fadeTime = 3;
        Ndef(\timeBreathe).set(\amp, 0.42, \rate, 0.1, \cutoff, 240, \drive, 2.1);
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\masterMix).set(\wet11, 0.25);

        // Solitary, slow escapement tick deep in the stillness
        Pbindef(\chronometerTick,
            \instrument, \horologyTick,
            \out, ~synthBus,
            \dur, Pseq([1.6, 2.2, 1.8, 2.4], inf),
            \freq, Pseq([1400, 1120, 1680, 980], inf),
            \dec, 0.06,
            \metalDec, 0.16,
            \tone, 0.85,
            \drive, 1.1,
            \pan, 0,
            \amp, 0.24
        ).play;

        4.do { |i|
            Ndef(\timeBreathe).set(\rate, 0.08 + (i * 0.02), \cutoff, 220 + (i * 40));
            3.0.wait;
        };

        "0:47 - [Resolução: O Respirar do Tempo se Suspende no Latão]".postln;
        // Resolution (a): Return to pristine single chime resonance fading into air
        Pbindef(\pendulumChime).stop;
        Pbindef(\pendulumChime,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([4.0], 1),
            \freq, 440,
            \ring, 6.0,
            \pan, 0,
            \amp, 0.26
        ).play;

        Pbindef(\chronometerTick).stop;
        Ndef(\clockSwarm).fadeTime = 4;
        Ndef(\clockSwarm).set(\amp, 0.0);
        Ndef(\timeBreathe).fadeTime = 5;
        Ndef(\timeBreathe).set(\amp, 0.0);

        5.0.wait;

        "0:52 - [Final: Extrinsic Limit]".postln;
        Pbindef(\chronometerTick).stop;
        Pbindef(\chronometerTick).clear;
        Pbindef(\pendulumChime).stop;
        Pbindef(\pendulumChime).clear;

        Ndef(\clockSwarm).clear(1);
        Ndef(\timeBreathe).clear(1);
        Ndef(\masterMix).clear(2);

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
// Congada Mineira: Dança, Gungas de Lata, Tambores de Terno e Louvação Processional
s.latency = 0.05;

// Layer 1: Tambor de Congo / Alfáia Grave (Pulsos Cadenciados de Terra e Fé)
Ndef(\tamborCongo).fadeTime = 2;
Ndef(\tamborCongo, { |t_trig=0, freq=58, decay=0.45, tone=0.2, click=0.8, pan=0, amp=0.24|
    var trigA, bodyEnv, pitchEnv, clickSig, bodySig, sig;
    trigA = K2A.ar(t_trig);
    bodyEnv = EnvGen.ar(Env.perc(0.003, decay, 1, -5), trigA);
    pitchEnv = EnvGen.ar(Env.perc(0.001, 0.07, 1, -4), trigA);
    clickSig = HPF.ar(LPF.ar(WhiteNoise.ar, 3800), 1200) * EnvGen.ar(Env.perc(0.0005, 0.015), trigA) * click;
    bodySig = SinOsc.ar((freq * (1 + (pitchEnv * 1.6))) + (SinOsc.ar(freq * 1.5) * (pitchEnv * 25))) * bodyEnv;
    bodySig = bodySig + (SinOsc.ar(freq * 2.02) * bodyEnv * 0.35);
    sig = LeakDC.ar(((bodySig * 1.4) + clickSig + (Fold.ar(bodySig * 2.5, -0.6, 0.6) * tone)).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

// Layer 2: Gungas de Lata (Chocalhos Metálicos de Tornozelo nos Moçambiques)
Ndef(\gungasLata).fadeTime = 2;
Ndef(\gungasLata, { |t_trig=0, rattleDur=0.18, brt=4200, res=0.15, pan=0, amp=0.22|
    var trigA, exciter, envRattle, resBank, sig;
    trigA = K2A.ar(t_trig);
    envRattle = EnvGen.ar(Env.perc(0.002, rattleDur, 1, -6), trigA);
    exciter = (Dust2.ar(3200) * 0.4) + (WhiteNoise.ar * 0.3) * envRattle;
    // Ressonância metálica oca de lata de conserva e esferas de ferro
    resBank = DynKlank.ar(
        `[
            [1320, 1840, 2460, 3720, 5210, 7150],
            [0.9, 0.7, 0.65, 0.45, 0.3, 0.2],
            [0.08, 0.06, 0.09, 0.04, 0.03, 0.02]
        ],
        exciter,
        decayscale: rattleDur * 1.2
    );
    sig = HPF.ar(resBank, 600);
    sig = BPF.ar(sig, brt, res) * 8.0 + (sig * 0.4);
    sig = (sig * 1.8).softclip;
    Pan2.ar(sig, pan, amp);
}).play;

// Layer 3: Louvor Processional / Canto das Irmandades de São Benedito
Ndef(\louvorVocal).fadeTime = 3;
Ndef(\louvorVocal, { |t_trig=0, freq=220, dur=1.8, vowel=0.2, pan=0, amp=0.18|
    var trigA, env, osc, formF, vA, vO, vU, vocalBody, sig;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env([0, 1, 0.7, 0], [0.12, (dur - 0.4).max(0.1), 0.28], [-2, -1, -3]), trigA);
    osc = Saw.ar(freq * [0.995, 1.0, 1.006]).sum + Pulse.ar(freq * 0.5, 0.48, 0.2);
    // Formantes vocais corais: A (800, 1200, 2500), O (500, 900, 2400), U (350, 750, 2400)
    vA = [800, 1200, 2500];
    vO = [500, 900, 2400];
    vU = [350, 750, 2400];
    formF = SelectX.kr(vowel, [vA, vO, vU]);
    vocalBody = BPF.ar(osc, formF, [0.12, 0.14, 0.18]).sum * 4.2;
    sig = MoogFF.ar(vocalBody, freq * 8, 1.2) * env;
    Pan2.ar(sig, pan, amp);
}).play;

// Layer 4: Neblina Espiritual / Resonância das Montanhas e Fitas Coloridas
Ndef(\procEspiritual).fadeTime = 4;
Ndef(\procEspiritual, { |pan=0, amp=0.14|
    var n1, n2, pad, breath, sig;
    n1 = PinkNoise.ar * 0.08;
    n2 = Dust.ar(14) * 0.2;
    breath = BPF.ar(n1 + n2, SinOsc.kr(0.08).range(420, 1100), 0.25) * 8.0;
    pad = SinOsc.ar([110, 165, 220, 330] * SinOsc.kr(0.05, 0, 0.005, 1)).sum * 0.12;
    sig = Splay.ar([breath, pad, DelayC.ar(breath, 0.2, [0.08, 0.15])].flat);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

// Reverb Processional das Igrejas Coloniais
Ndef(\tamborCongo)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35) };
Ndef(\tamborCongo).set(\wet10, 0.24);

Ndef(\gungasLata)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.8, 0.6) };
Ndef(\gungasLata).set(\wet10, 0.32);

Ndef(\louvorVocal)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.88, 0.5) };
Ndef(\louvorVocal).set(\wet10, 0.42);

// Padrões Rítmicos: O Toque do Terno de Moçambique (Compasso Cadenciado Polirrítmico)
Ndef(\tamborCongo).quant = 1;
Pbindef(\seqTambor,
    \dur, Pseq([0.375, 0.125, 0.25, 0.25, 0.5, 0.5], inf),
    \freq, Pseq([55, 62, 55, 58, 55, 52], inf),
    \decay, Pseq([0.48, 0.22, 0.38, 0.3, 0.55, 0.42], inf),
    \tone, Pwhite(0.15, 0.32, inf),
    \pan, Pseq([-0.15, 0.12, -0.08, 0.18, 0, -0.1], inf),
    \amp, Pseq([0.28, 0.19, 0.24, 0.21, 0.3, 0.22], inf),
    \t_trig, 1
);
Ndef(\tamborCongo)[1] = \set -> Pbindef(\seqTambor);

// Chocalhar de Tornozelo dos Dançantes (Gungas sincopadas de lata)
Ndef(\gungasLata).quant = 1;
Pbindef(\seqGungas,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.5], inf),
    \rattleDur, Pseq([0.08, 0.14, 0.22, 0.07, 0.13, 0.25, 0.18, 0.09, 0.12, 0.28], inf),
    \brt, Pwhite(3600, 5600, inf),
    \res, Pwhite(0.12, 0.25, inf),
    \pan, Pseq([0.45, -0.42, 0.35, -0.38, 0.4, -0.45], inf),
    \amp, Pseq([0.18, 0.24, 0.28, 0.16, 0.23, 0.27, 0.22, 0.17, 0.21, 0.26], inf),
    \t_trig, 1
);
Ndef(\gungasLata)[1] = \set -> Pbindef(\seqGungas);

// Louvação Antifonal (Linha Melódica Penitencial / Coroação)
Ndef(\louvorVocal).quant = 1;
Pbindef(\seqLouvor,
    \dur, Pseq([2.0, 1.0, 1.0, 2.0, 2.0], inf),
    \freq, Pseq([
        220, 246.94, 261.63, 220, 196,
        220, 293.66, 261.63, 246.94, 220
    ], inf),
    \durEnv, Pseq([1.8, 0.9, 0.9, 1.8, 1.9], inf),
    \vowel, Pseq([0.1, 0.8, 1.6, 0.3, 1.1], inf),
    \pan, Pseq([0.15, -0.15, 0.25, -0.2, 0], inf),
    \amp, 0.19,
    \t_trig, 1
);
Ndef(\louvorVocal)[1] = \set -> Pbindef(\seqLouvor);
)

// Live-coding Tweaks & Rollbacks:
// Ndef(\gungasLata).xset(\brt, 6800); // Mais brilho metálico de lata | Revert: Ndef(\gungasLata).xset(\brt, 4200);
// Pbindef(\seqTambor, \freq, Pseq([65, 73, 65, 69, 65, 62], inf)); // Tom mais alto | Revert: Pbindef(\seqTambor, \freq, Pseq([55, 62, 55, 58, 55, 52], inf));
// Pbindef(\seqGungas).stop; Ndef(\gungasLata).fadeTime = 3; Ndef(\gungasLata).clear(3); // Rollback Gungas
// Pbindef(\seqTambor).stop; Ndef(\tamborCongo).fadeTime = 3; Ndef(\tamborCongo).clear(3); // Rollback Tambores
// Pbindef(\seqLouvor).stop; Ndef(\louvorVocal).fadeTime = 4; Ndef(\louvorVocal).clear(4); // Rollback Louvor

