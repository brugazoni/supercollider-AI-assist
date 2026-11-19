// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-13T11:16:05.589702+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Ndef(\mapFold)
// Granular friction and dry paper creasing: mechanical pedantry unfolding at the restaurant table
Ndef(\mapFold, { |amp=0.25, pan=0, t_trig=0, freq=3200, rq=0.08, crackle=1.5, foldAtk=0.002, foldRel=0.09|
    var trigSig = K2A.ar(t_trig);
    var exciter = WhiteNoise.ar * Dust.ar(crackle * 40).range(0.2, 1.0);
    var env = Decay2.ar(trigSig, foldAtk, foldRel);
    var body = BPF.ar(exciter, freq.clip(400, 12000), rq) * 12.0;
    var sharpFold = (body * 2.5).fold2(0.6);
    Pan2.ar(sharpFold * env * amp, pan);
}).play;

// Paper crease sequencing: compulsive, rigid folding gestures
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.18, 0.12, 0.35, 0.15, 0.7, 0.25], inf),
    \freq, Pseq([2400, 3600, 1800, 4800, 2100, 5600], inf),
    \rq, Pwhite(0.04, 0.12, inf),
    \crackle, Pwhite(1.0, 3.5, inf),
    \amp, Pseq([0.22, 0.15, 0.28, 0.18, 0.32, 0.19], inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \t_trig, 1
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// ADD_EFFECTS: Slapback echo evoking the stiff acoustic confines of a hushed restaurant
Ndef(\mapFold)[10] = \filter -> { |in|
    CombC.ar(in, 0.2, [0.08, 0.11], 0.8) * 0.7;
};
Ndef(\mapFold).set(\wet10, 0.25);
// Ndef(\mapFold).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Ndef(\wineSuspension)
// The waiter's suspended wine bottle: a glassy, fragile, frozen resonant tone held in mid-air
Ndef(\wineSuspension, { |freq=987.77, amp=0.18, pan=0.2, glassRQ=0.015, t_trig=0, rel=3.5|
    var trigSig = K2A.ar(t_trig);
    var strike = Impulse.ar(0.0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01), trigSig));
    var ring = Ringz.ar(strike, [freq, freq * 1.503, freq * 2.01], [rel, rel * 0.75, rel * 0.5]);
    var sig = Splay.ar(ring) * 0.04;
    var hum = SinOsc.ar(freq * [0.999, 1.001]) * 0.05 * EnvGen.kr(Env.sine(rel), trigSig);
    Balance2.ar(sig[0] + hum[0], sig[1] + hum[1], pan, amp);
}).play;

// Infrequent, delicate glass vibrations suspended above the table
Pbindef(\wineSeq,
    \dur, Pseq([3.0, 4.5, 2.5, 5.0], inf),
    \freq, Pseq([987.77, 880.0, 1174.66, 987.77], inf), // B5, A5, D6 tension
    \rel, Pwhite(3.0, 5.5, inf),
    \amp, Pwhite(0.12, 0.22, inf),
    \pan, Pwhite(0.1, 0.35, inf),
    \t_trig, 1
);
Ndef(\wineSuspension)[1] = \set -> Pbindef(\wineSeq);

// ADD_INSTRUMENT: Ndef(\antarcticStorm)
// The catastrophic weight of 27 years of compressed silence: glacial sub-bass and freezing howling drone
Ndef(\antarcticStorm, { |amp=0.28, fund=43.65, cutoff=280, drive=2.5, spread=0.6| // F1 fundamental
    var sub = SinOsc.ar(fund) + (SinOsc.ar(fund * 2) * 0.35);
    var coldAir = PinkNoise.ar * LFNoise2.kr(0.15).range(0.2, 0.8);
    var resonantIce = BPF.ar(WhiteNoise.ar, SinOsc.kr(0.04, [0, pi]).range(450, 1400), 0.06) * 8.0;
    var core = sub + (coldAir * 0.4) + (resonantIce * 0.3);
    var filtered = (MoogFF.ar(core, cutoff.clip(50, 3500), 2.8) * drive).tanh;
    Splay.ar(filtered, spread, amp);
}).play;

// Slow glacial expansion of filter pressure: accumulating Antarctic storm front
Pbindef(\stormSeq,
    \dur, 4.0,
    \cutoff, Pseq([180, 220, 290, 360, 480, 320, 240], inf),
    \drive, Pwhite(2.0, 3.8, inf),
    \amp, Pseq([0.22, 0.25, 0.28, 0.33, 0.38, 0.30], inf)
);
Ndef(\antarcticStorm)[1] = \set -> Pbindef(\stormSeq);

// ADD_EFFECTS: Vast abyssal reverb on the storm, creating an unbearable frozen expanse
Ndef(\antarcticStorm)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.94, 0.15);
};
Ndef(\antarcticStorm).xset(\wet10, 0.45);
// Ndef(\antarcticStorm).xset(\wet10, 0); // Rollback: disable this effect

// Rollbacks:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\wineSeq).stop; Ndef(\wineSuspension).fadeTime = 2; Ndef(\wineSuspension).clear(2);
// Pbindef(\stormSeq).stop; Ndef(\antarcticStorm).fadeTime = 3; Ndef(\antarcticStorm).clear(3);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: FIXED
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ==============================================================================
// FORMAL DIRECTION: INTRINSIC LIMIT (b) -> ABYSSAL CATACLYSM
// Castro Alves: "O Navio Negreiro" (Tragedy on the high seas, blood, chains, whip)
// ==============================================================================

// 1. TWEAK & MUTATE EXISTING LAYERS: From Antarctic silence to the blood-red slave deck
// Submerge \antarcticStorm into a suffocating, blood-soaked subterranean heave
Ndef(\antarcticStorm).xset(\fund, 32.7, \cutoff, 160, \drive, 5.0, \amp, 0.45);
// Ndef(\antarcticStorm).xset(\fund, 43.65, \cutoff, 280, \drive, 2.5, \amp, 0.28); // Revert tweak

// Re-purpose \mapFold into violent, splintering deck friction & snapping timbers
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.08, 0.08, 0.24, 0.12, 0.48], inf),
    \freq, Pseq([1200, 800, 2200, 600, 3100], inf),
    \rq, 0.2,
    \crackle, 8.0,
    \amp, Pseq([0.35, 0.28, 0.45, 0.3, 0.5], inf)
);
// Pbindef(\mapFoldSeq, \dur, Pseq([0.18, 0.12, 0.35, 0.15, 0.7, 0.25], inf), \freq, Pseq([2400, 3600, 1800, 4800, 2100, 5600], inf), \rq, 0.08, \crackle, 1.5, \amp, 0.25); // Revert sequence

// Twist \wineSuspension into a desperate, harmonic death cry ("pedindo a Deus um raio")
Pbindef(\wineSeq,
    \dur, Pseq([0.75, 1.25, 0.5, 2.0], inf),
    \freq, Pseq([466.16, 440.0, 587.33, 311.13], inf), // Bb4, A4, D5, Eb4 (Dantesque lament)
    \rel, Pwhite(1.2, 2.4, inf),
    \amp, Pwhite(0.25, 0.4, inf)
);
// Pbindef(\wineSeq, \dur, Pseq([3.0, 4.5, 2.5, 5.0], inf), \freq, Pseq([987.77, 880.0, 1174.66, 987.77], inf), \rel, 3.5, \amp, 0.18); // Revert sequence

// 2. ADD_INSTRUMENT: Ndef(\ironChains)
// "Tinir de ferros": Heavy clanking metallic iron links and Shackles (Klank modal bank + harsh FM ping)
Ndef(\ironChains, { |amp=0.32, pan=0, t_trig=0, metalDecay=0.8, brightness=1.0|
    var trigSig = K2A.ar(t_trig);
    var strike = PinkNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.03), trigSig);
    var click = Impulse.ar(0.0) * EnvGen.ar(Env.perc(0.0001, 0.008), trigSig);
    var freqs = [320, 680, 1240, 1920, 3110, 4450] * brightness;
    var rings = [metalDecay, metalDecay * 0.7, metalDecay * 0.5, metalDecay * 0.3, 0.15, 0.08];
    var modes = DynKlank.ar(`[freqs, [0.6, 0.5, 0.4, 0.3, 0.2, 0.1], rings], strike + (click * 0.5));
    var grit = (modes * 2.5).fold2(0.8);
    Pan2.ar(grit * amp, pan);
}).play;

Pbindef(\ironChainsSeq,
    \dur, Pseq([0.25, 0.5, 0.25, 0.25, 0.75, 0.5, 0.25, 0.25], inf),
    \brightness, Pseq([0.9, 1.1, 0.85, 1.3, 0.95, 1.05], inf),
    \metalDecay, Pwhite(0.4, 1.1, inf),
    \amp, Pseq([0.35, 0.25, 0.38, 0.28, 0.42, 0.3, 0.28, 0.45], inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \t_trig, 1
);
Ndef(\ironChains)[1] = \set -> Pbindef(\ironChainsSeq);

// ADD_EFFECTS: Slap echo across the wet wooden hull
Ndef(\ironChains)[10] = \filter -> { |in|
    CombC.ar(in, 0.3, [0.06, 0.09], 1.2) * 0.8;
};
Ndef(\ironChains).xset(\wet10, 0.35);
// Ndef(\ironChains).set(\wet10, 0); // Rollback: disable this effect

// 3. ADD_INSTRUMENT: Ndef(\whipCrack)
// "Estalar de açoite": Explosive white-noise transient cutting into stinging resonance and tail
Ndef(\whipCrack, { |amp=0.4, pan=0, t_trig=0, stingFreq=2800|
    var trigSig = K2A.ar(t_trig);
    var snapEnv = EnvGen.ar(Env.perc(0.0002, 0.04, curve: -8), trigSig);
    var tailEnv = EnvGen.ar(Env.perc(0.01, 0.4, curve: -4), trigSig);
    var crack = WhiteNoise.ar * snapEnv;
    var sting = BPF.ar(crack + (PinkNoise.ar * tailEnv), stingFreq, 0.15) * 14.0;
    var subImpact = SinOsc.ar(XLine.ar(180, 45, 0.05)) * snapEnv * 0.7;
    var sig = (crack * 2.0) + sting + subImpact;
    Pan2.ar(sig.clip2(0.9) * amp, pan);
}).play;

Pbindef(\whipSeq,
    \dur, Pseq([3.0, 2.5, 4.0, 1.5, 3.5], inf),
    \stingFreq, Pseq([3400, 2600, 4200, 2200], inf),
    \amp, Pwhite(0.4, 0.65, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \t_trig, 1
);
Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);

// ADD_EFFECTS: Vast abyssal sea spray and damp horror reverberation
Ndef(\whipCrack)[10] = \filter -> { |in|
    FreeVerb.ar(in, 1.0, 0.88, 0.2);
};
Ndef(\whipCrack).xset(\wet10, 0.4);
// Ndef(\whipCrack).set(\wet10, 0); // Rollback: disable this effect

// Rollbacks:
// Pbindef(\ironChainsSeq).stop; Ndef(\ironChains).fadeTime = 2; Ndef(\ironChains).clear(2);
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2);
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

    // --- SynthDefs: Brass Gears, Pendulum Escapements, French Carillons ---
    SynthDef(\escapementTick, { |out=0, freq=3200, amp=0.15, pan=0, damp=0.015, body=280|
        var env = EnvGen.ar(Env.perc(0.0003, damp, curve: -8), doneAction: 2);
        var click = PinkNoise.ar * env * 2.0;
        var tooth = SinOsc.ar(XLine.ar(freq * 1.5, freq * 0.7, damp)) * env;
        var woodBox = BPF.ar(click, body, 0.25) * 6.0;
        var sig = (tooth + click + woodBox).fold2(0.9);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\carrilhaoChime, { |out=0, freq=880, amp=0.2, pan=0, ring=2.5, strikeRate=0.002|
        var strikeEnv = EnvGen.ar(Env.perc(0.0002, strikeRate), doneAction: 0);
        var ringEnv = EnvGen.ar(Env.perc(0.002, ring, 1, -5), doneAction: 2);
        var imp = WhiteNoise.ar * strikeEnv;
        var freqs = freq * [1.0, 2.76, 5.4, 8.93];
        var amps = [0.8, 0.5, 0.35, 0.2];
        var decays = [ring, ring * 0.7, ring * 0.5, ring * 0.3];
        var bell = DynKlank.ar(`[freqs, amps, decays], imp);
        var sig = bell * ringEnv;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pocketWatchPulse, { |out=0, freq=5400, amp=0.08, pan=0|
        var env = EnvGen.ar(Env.perc(0.0001, 0.007, 1, -10), doneAction: 2);
        var pulse = HPF.ar(WhiteNoise.ar, freq) * env;
        var ping = SinOsc.ar(freq) * env * 0.5;
        Out.ar(out, Pan2.ar((pulse + ping) * amp, pan));
    }).add;

    s.sync;

    // --- Continuous Ndefs: Swarming Pendulums & The Breath of Time ---
    Ndef(\pendulumSwarm, { |amp=0, polySpeed=1.0, dispersion=0.1|
        var freqs = [0.82, 0.94, 1.01, 1.13, 1.27, 1.41] * polySpeed;
        var swings = freqs.collect { |f, idx|
            var lfo = SinOsc.ar(f, idx * 0.5);
            var friction = BPF.ar(BrownNoise.ar, 180 + (idx * 45), 0.15) * (lfo.max(0) ** 3);
            var sweep = SinOsc.ar(55 + (idx * 11), 0, 0.3) * (lfo.abs ** 2);
            Pan2.ar((friction * 4.0) + sweep, SinOsc.kr(f * 0.5, idx * 0.3));
        };
        Mix(swings) * amp;
    });

    Ndef(\timeBreath, { |amp=0, morph=0.2, lpf=600|
        var lungsL = PinkNoise.ar * LFNoise2.kr(0.08).range(0.05, 0.95);
        var lungsR = BrownNoise.ar * LFNoise2.kr(0.07).range(0.05, 0.95);
        var subHarmonic = SinOsc.ar([43.65, 44.0], 0, 0.35);
        var wash = [lungsL, lungsR] + subHarmonic;
        wash = RLPF.ar(wash, (lpf * LFNoise1.kr(0.1).exprange(0.8, 1.3)).clip(80, 4500), 0.35);
        wash = (wash * (1.0 + (morph * 2.5))).tanh;
        wash * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\pendulumSwarm, 2) + Ndef.ar(\timeBreath, 2);
        synths + continuous;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.0);

    Ndef(\masterMix)[11] = \filter -> { |in|
        CombC.ar(in, 0.3, [0.08, 0.113], 1.2);
    };
    Ndef(\masterMix).set(\wet11, 0.0);

    Ndef(\masterMix).play;
    s.sync;

    // --- Chronological Master Score ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Movement I: The Narrow Workshop of Santa Efigênia]".postln;
        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\wet10, 0.22, \wet11, 0.15);

        // Slow, heavy grand pendulum starts swaying
        Ndef(\pendulumSwarm).fadeTime = 4;
        Ndef(\pendulumSwarm).xset(\amp, 0.45, \polySpeed, 0.9);

        // Desynchronized pocket watch escapement clicks (polymetric phasing)
        Pbindef(\pocketWatchSeq,
            \instrument, \pocketWatchPulse,
            \out, ~synthBus,
            \dur, Pseq([0.12, 0.13, 0.11, 0.125, 0.14], inf),
            \freq, Pexprand(4800, 7200),
            \amp, Pwhite(0.04, 0.09),
            \pan, Pwhite(-0.7, 0.7)
        ).play;

        4.do { |i|
            Ndef(\pendulumSwarm).xset(\dispersion, 0.1 + (i * 0.08));
            3.wait;
        };

        "0:13 - [Movement II: The Hundred Escapements Align and Blur]".postln;
        // Wooden clocks and brass levers rattling at unaligned tempos
        Pbindef(\escapementSeq,
            \instrument, \escapementTick,
            \out, ~synthBus,
            \dur, Pseq([0.245, 0.252, 0.248, 0.495, 0.251, 0.127], inf),
            \freq, Pseq([2800, 3600, 2200, 4400, 3100], inf),
            \body, Pwhite(220, 520, inf),
            \damp, Pwhite(0.008, 0.035, inf),
            \pan, Pwhite(-0.85, 0.85, inf),
            \amp, Pwhite(0.18, 0.32, inf)
        ).play;

        // Active micro-shifts in rhythmic tension
        5.do { |i|
            Pbindef(\escapementSeq, \dur, Pseq([0.24 + (i * 0.003), 0.25 - (i * 0.002), 0.125], inf));
            Ndef(\masterMix).xset(\wet11, 0.18 + (i * 0.04));
            3.wait;
        };

        "0:28 - [Movement III: Les Carrillons Français]".postln;
        // Distant ornate clock-chimes drifting out of phase
        Pbindef(\chimeSeq,
            \instrument, \carrilhaoChime,
            \out, ~synthBus,
            \dur, Pseq([1.75, 2.33, 1.25, 3.1, 0.85], inf),
            \freq, Pseq([587.33, 659.25, 880.0, 783.99, 1046.5], inf), // D5, E5, A5, G5, C6
            \ring, Pwhite(2.2, 4.5, inf),
            \pan, Pwhite(-0.6, 0.6, inf),
            \amp, Pwhite(0.12, 0.25, inf)
        ).play;

        Ndef(\masterMix).xset(\wet10, 0.45);

        4.do { |i|
            Pbindef(\pocketWatchSeq, \amp, 0.06 + (i * 0.02));
            Ndef(\pendulumSwarm).xset(\polySpeed, 0.95 + (i * 0.05));
            3.5.wait;
        };

        "0:42 - [Movement IV: The Horologist Closes His Eyes]".postln;
        // Intrinsic Limit reached: sudden subtractive plunge into the subterranean "Breath of Time"
        Pbindef(\escapementSeq).stop;
        Pbindef(\pocketWatchSeq).stop;

        Ndef(\timeBreath).fadeTime = 3;
        Ndef(\timeBreath).xset(\amp, 0.55, \morph, 0.6, \lpf, 1200);

        Ndef(\pendulumSwarm).fadeTime = 6;
        Ndef(\pendulumSwarm).xset(\amp, 0.2, \polySpeed, 0.65);

        // One lonely, hyper-slowed French carillon tolling deep in the mist
        Pbindef(\chimeSeq,
            \dur, Pseq([4.0, 5.0, 4.5], inf),
            \freq, Pseq([293.66, 329.63, 220.0], inf), // D4, E4, A3
            \ring, 5.0,
            \amp, 0.28
        );

        3.do { |i|
            Ndef(\timeBreath).xset(\lpf, 900 - (i * 200), \morph, 0.4 - (i * 0.1));
            4.wait;
        };

        "0:54 - [Movement V: Resolving to the Singularity of Time]".postln;
        // Flashback: A single, delicate, perfectly centered watch escapement continues
        Pbindef(\chimeSeq).stop;
        Pbindef(\chimeSeq).clear;

        Pbindef(\soloEscapement,
            \instrument, \escapementTick,
            \out, ~synthBus,
            \dur, 1.0,
            \freq, 3400,
            \body, 320,
            \damp, 0.012,
            \pan, 0.0,
            \amp, 0.16
        ).play;

        Ndef(\timeBreath).fadeTime = 6;
        Ndef(\timeBreath).xset(\amp, 0);

        Ndef(\pendulumSwarm).fadeTime = 6;
        Ndef(\pendulumSwarm).xset(\amp, 0);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet10, 0.6, \wet11, 0.0);

        6.wait;

        "1:00 - [Extrinsic Limit: Fade Out & Terminate]".postln;
        Pbindef(\soloEscapement).stop;
        Pbindef(\soloEscapement).clear;
        Pbindef(\escapementSeq).clear;
        Pbindef(\pocketWatchSeq).clear;

        Ndef(\pendulumSwarm).clear(2);
        Ndef(\timeBreath).clear(2);
        Ndef(\masterMix).clear(2);

        2.wait;
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
    // Configuration & Safety Limiter
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

    // Discrete Sound Sources: Mineral Dripping & Stalactite Resonance
    SynthDef(\calcDrip, { |out=0, freq=1600, tone=550, decay=0.18, pan=0, amp=0.2|
        var dropEnv = EnvGen.ar(Env.perc(0.001, 0.035));
        var pitch = freq * (1 + (dropEnv * 1.8));
        var body = SinOsc.ar(pitch);
        var resExc = PinkNoise.ar * dropEnv;
        var cavity = Ringz.ar(resExc + (body * 0.4), tone, decay);
        var full = (body * 0.4) + (cavity * 0.6);
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var sig = Pan2.ar(full * env, pan, amp);
        Out.ar(out, sig);
    }).add;

    SynthDef(\stalactiteChime, { |out=0, freq=440, decayscale=2.5, pan=0, amp=0.18|
        var trg = Impulse.ar(0);
        var exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.008), trg);
        var freqs = [1, 2.756, 5.404, 8.932] * freq;
        var amps = [0.6, 0.3, 0.15, 0.08];
        var rings = [1.0, 0.7, 0.4, 0.2] * decayscale;
        var sig = DynKlank.ar(Ref([freqs, amps, rings]), exc, decayscale: decayscale);
        var env = EnvGen.ar(Env.perc(0.001, decayscale.clip(0.1, 8.0)), doneAction: 2);
        sig = HPF.ar(sig, 120);
        sig = Pan2.ar(sig * env, pan, amp);
        Out.ar(out, sig);
    }).add;

    SynthDef(\paleoSub, { |out=0, freq=42, dur=6.0, pan=0, amp=0.3|
        var env = EnvGen.ar(Env.sine(dur), doneAction: 2);
        var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.25);
        var air = BPF.ar(BrownNoise.ar, freq * 3, 0.4) * 0.4;
        var sig = (sub + air) * env;
        sig = (sig * 1.5).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // Continuous Subterranean Textures: 7 Limestone Chambers & Humid Condensation
    Ndef(\cavernDrone, { |amp=0, roomSize=280, breath=0.08|
        var air = BrownNoise.ar * 0.6;
        var lfo = SinOsc.kr(breath).range(0.6, 1.2);
        var f1 = [52, 65, 87, 104, 131, 174, 220] * lfo;
        var modes = DynKlank.ar(Ref([f1, Array.fill(7, { 0.14 }), Array.fill(7, { 4.5 })]), air * 0.04);
        var sub = SinOsc.ar(38) * 0.35;
        var sig = (modes + sub);
        sig = LPF.ar(sig, roomSize * 3);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\vaultCondensation, { |amp=0, grainRate=14, hiCut=3200|
        var d = Dust.ar([grainRate, grainRate * 1.2]);
        var dripNoise = Decay2.ar(d, 0.002, 0.04) * WhiteNoise.ar;
        var banded = BPF.ar(dripNoise, [2800, 4200, 5600], 0.15).sum;
        var sig = LPF.ar(banded, hiCut);
        sig * amp;
    });

    // Master Mix with Maquiné Vault Reverb & Slapback Echoes
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\cavernDrone, 2) + Ndef.ar(\vaultCondensation, 2);
        synths + cont;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.96, 0.15);
    };
    Ndef(\masterMix).set(\wet10, 0.45);

    Ndef(\masterMix)[11] = \filter -> { |in|
        var delay = CombC.ar(in, 0.4, [0.18, 0.27], 2.8);
        delay;
    };
    Ndef(\masterMix).set(\wet11, 0.22);

    Ndef(\masterMix).play;
    s.sync;

    // Fixed-Timeline Score: 105 seconds (~1:45)
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: Entrance to Salão das Fadas (Peter Lund 1834)]".postln;
        Ndef(\cavernDrone).fadeTime = 6;
        Ndef(\cavernDrone).xset(\amp, 0.45, \roomSize, 220, \breath, 0.06);

        Ndef(\vaultCondensation).fadeTime = 8;
        Ndef(\vaultCondensation).xset(\amp, 0.22, \grainRate, 10);

        Pbindef(\dripSeq,
            \instrument, \calcDrip,
            \out, ~synthBus,
            \dur, Pseq([0.8, 1.2, 0.4, 1.6, 2.1], inf),
            \freq, Pwhite(1200, 2200, inf),
            \tone, Pseq([380, 440, 520, 310], inf),
            \decay, Pwhite(0.2, 0.45, inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, Pwhite(0.15, 0.28, inf)
        ).play;

        // Active Wait: 18s (Slow descent into limestone dark)
        6.do { |i|
            Ndef(\cavernDrone).xset(\roomSize, 200 + (i * 20));
            3.wait;
        };

        "0:18 - [Cue 2: Salão do Sino (Lithophonic Mineral Bells)]".postln;
        // Naturalist's hammer taps calcified spires; mineral resonances bloom
        Pbindef(\stalactiteSeq,
            \instrument, \stalactiteChime,
            \out, ~synthBus,
            \dur, Pseq([1.5, 2.25, 0.75, 3.0, 1.5], inf),
            \freq, Pseq([220, 293.66, 329.63, 440, 587.33], inf),
            \decayscale, Pwhite(3.2, 5.5, inf),
            \pan, Pwhite(-0.85, 0.85, inf),
            \amp, Pwhite(0.2, 0.35, inf)
        ).play;

        Ndef(\masterMix).set(\wet10, 0.65, \wet11, 0.35);

        // Active Wait: 24s (Traveling deeper into the 7 halls)
        6.do { |i|
            Ndef(\vaultCondensation).xset(\grainRate, 12 + (i * 3), \hiCut, 2800 + (i * 200));
            4.wait;
        };

        "0:42 - [Cue 3: Tectonic Drift & Paleontological Silence]".postln;
        // Intrinsic Limit: Deep geological compression, fossil horizons
        Pbindef(\stalactiteSeq,
            \dur, Pseq([3.0, 4.5, 2.0], inf),
            \freq, Pseq([146.83, 164.81, 110.0], inf),
            \decayscale, 6.0,
            \amp, 0.4
        );

        Ndef(\cavernDrone).fadeTime = 4;
        Ndef(\cavernDrone).xset(\amp, 0.65, \roomSize, 450, \breath, 0.12);

        // Subterranean tectonic pulses
        Pbindef(\subSeq,
            \instrument, \paleoSub,
            \out, ~synthBus,
            \dur, Pseq([6.0, 8.0, 7.0], inf),
            \freq, Pseq([34, 40, 31], inf),
            \durLen, 7.0,
            \pan, Pwhite(-0.2, 0.2, inf),
            \amp, 0.45
        ).play;

        // Active Wait: 24s (Sub-bass vibration in the limestone massif)
        4.do { |i|
            Pbindef(\dripSeq, \freq, Pexprand(900, 2600), \decay, 0.35 + (i * 0.05));
            6.wait;
        };

        "1:06 - [Cue 4: Cortinas Minerais (Accelerating Water Metronomes)]".postln;
        // Micro-kinetic burst: mineral curtains weeping after heavy rain
        Pbindef(\dripSeq,
            \dur, Pseq([0.15, 0.22, 0.12, 0.3, 0.18, 0.1], inf),
            \freq, Pseq([1800, 2400, 1600, 3100, 2100, 2800], inf),
            \tone, Pwhite(450, 850, inf),
            \amp, Pwhite(0.12, 0.24, inf)
        );

        Ndef(\masterMix).set(\wet10, 0.75, \wet11, 0.45);

        // Active Wait: 20s
        5.do { |i|
            Ndef(\vaultCondensation).xset(\grainRate, 30 + (i * 6));
            4.wait;
        };

        "1:26 - [Cue 5: Resolution & Flashback (A Single Drop in Pitch Black)]".postln;
        // Settling: Stop sub and complex sequences, leaving pristine isolated drip
        Pbindef(\stalactiteSeq).stop;
        Pbindef(\subSeq).stop;
        Ndef(\cavernDrone).fadeTime = 8;
        Ndef(\cavernDrone).xset(\amp, 0.08);

        Ndef(\vaultCondensation).fadeTime = 6;
        Ndef(\vaultCondensation).xset(\amp, 0.04);

        Pbindef(\dripSeq,
            \dur, 3.2,
            \freq, 1480,
            \tone, 420,
            \decay, 0.6,
            \pan, 0.0,
            \amp, 0.3
        );

        // Reverb tail blooming out
        Ndef(\masterMix).fadeTime = 6;
        Ndef(\masterMix).xset(\wet10, 0.85, \wet11, 0.1);

        // Active Wait: 14s
        3.do { |i|
            Ndef(\cavernDrone).xset(\roomSize, 120 - (i * 30));
            4.66.wait;
        };

        "1:40 - [Extrinsic Limit: Complete Subterranean Blackout]".postln;
        Pbindef(\dripSeq).stop;
        Pbindef(\dripSeq).clear;
        Pbindef(\stalactiteSeq).clear;
        Pbindef(\subSeq).clear;

        Ndef(\cavernDrone).clear(4);
        Ndef(\vaultCondensation).clear(4);
        Ndef(\masterMix).clear(5);

        5.0.wait;
        "Score Complete. Maquiné silent.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

