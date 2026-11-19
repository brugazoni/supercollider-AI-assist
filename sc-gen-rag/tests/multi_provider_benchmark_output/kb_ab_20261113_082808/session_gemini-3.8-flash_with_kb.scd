// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-13T11:43:18.918611+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Formal Archetype: Intrinsic Limit (b) / Settling (c)
// Dramatic scene: 27 years of repressed silence erupting over folding a road map.
// Layers:
// 1. \mapFold: Tactile, brittle paper clicks & creases (friction, precision, obsession).
// 2. \antarcticSilence: Heavy, sub-zero glacial drone swelling beneath the frozen restaurant table.

// --- INSTRUMENT 1: Road Map Folding (Dry paper creases & snapping folds) ---
Ndef(\mapFold, { |freq=3200, rq=0.08, amp=0.25, pan=0, t_trig=0, crackle=0.4|
    var env, noise, exciter, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.08, curve: -6), t_trig);
    exciter = (WhiteNoise.ar * crackle) + Dust2.ar(800 * crackle);
    // Sharp resonant creases of dry paper folding
    sig = BPF.ar(exciter, freq.clip(200, 12000), rq) * 14.0;
    sig = (sig * 1.5).fold2(0.7);
    Pan2.ar(sig * env * amp, pan);
}).play;

// Delay & spatial dispersion for the awkward dining room echo
Ndef(\mapFold)[10] = \filter -> { |in|
    CombC.ar(in, 0.3, [0.09, 0.13], 1.2);
};
Ndef(\mapFold).set(\wet10, 0.15);

// Precise, pedantic rhythmic folding instructions
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.5, 0.25, 0.125, 0.75], inf),
    \freq, Pseq([2800, 4200, 1900, 5600, 3100, 6800, 2200], inf),
    \rq, Pwhite(0.03, 0.12, inf),
    \crackle, Pseq([0.3, 0.6, 0.2, 0.8, 0.4], inf),
    \pan, Pseq([-0.4, 0.4, -0.2, 0.2, 0], inf),
    \amp, Pseq([0.18, 0.22, 0.15, 0.28, 0.12], inf),
    \t_trig, 1
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// --- INSTRUMENT 2: Antarctic Storm (The petrified, freezing weight of 27 years) ---
Ndef(\antarcticSilence, { |freq=48, amp=0.35, pan=0, t_trig=0, frost=0.6, stormCut=600|
    var env, sub, rumbles, wind, sig;
    env = EnvGen.ar(Env.perc(0.4, 4.0, curve: -2), t_trig);
    // Sub rumble + overtone for monitor clarity
    sub = SinOsc.ar(freq) * 0.6 + SinOsc.ar(freq * 2) * 0.3;
    // Cold, suspended wind vortex
    wind = BPF.ar(BrownNoise.ar, SinOsc.kr(0.08).range(120, stormCut), 0.35) * 8.0;
    // Icy, crystalline frost beating (glassware on the verge of shattering)
    rumbles = DynKlank.ar(`[
        [freq * 1.5, freq * 2.76, freq * 4.12, freq * 7.3],
        [0.4, 0.25, 0.15, 0.08],
        [1.5, 2.0, 1.2, 0.8]
    ], PinkNoise.ar(0.02 * frost));

    sig = sub + wind + rumbles;
    sig = LeakDC.ar(sig);
    Pan2.ar(sig * env * amp, pan);
}).play;

// Freezing chamber reverb: Suspended bottle, zero motion
Ndef(\antarcticSilence)[10] = \filter -> { |in|
    FreeVerb.ar(in, 1, 0.92, 0.15);
};
Ndef(\antarcticSilence).set(\wet10, 0.35);

// Slow, menacing surges of accumulated marital pressure
Pbindef(\antarcticSeq,
    \dur, Pseq([4, 3, 5, 6], inf),
    \freq, Pseq([43.65, 41.2, 38.89, 43.65], inf), // Sub-bass F, E, Eb
    \stormCut, Pseq([400, 750, 300, 950], inf),
    \frost, Pseq([0.4, 0.7, 0.3, 0.85], inf),
    \amp, Pseq([0.3, 0.38, 0.32, 0.42], inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \t_trig, 1
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSeq);

// Rollback:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\antarcticSeq).stop; Ndef(\antarcticSilence).fadeTime = 3; Ndef(\antarcticSilence).clear(3);
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
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

    // --- Instruments ---
    // Escapement / Pendulum Tick: Resonant brass click with wood body
    SynthDef(\clockTick, { |out=0, freq=2400, bodyFreq=220, decay=0.035, amp=0.15, pan=0|
        var click, body, sig, env;
        env = EnvGen.ar(Env.perc(0.0005, decay.max(0.005), curve: -8), doneAction: 2);
        click = BPF.ar(Impulse.ar(0) * 10 + (WhiteNoise.ar * 0.4), freq.clip(400, 12000), 0.12) * 8.0;
        body = Ringz.ar(Impulse.ar(0), bodyFreq.clip(80, 800), decay * 2.5) * 0.35;
        sig = (click + body) * env;
        sig = (sig * 2.2).tanh;
        Out.ar(out, Pan2.ar(sig * amp, pan.clip(-1, 1)));
    }).add;

    // French Ormolu Chime: Struck metallic bell with non-integer inharmonic ratios
    SynthDef(\carrilhao, { |out=0, freq=880, dur=2.4, ring=2.0, amp=0.2, pan=0|
        var exciter, sig, env;
        env = EnvGen.ar(Env.perc(0.001, dur.max(0.1), curve: -4), doneAction: 2);
        exciter = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.008)));
        sig = DynKlank.ar(Ref([
            [freq, freq * 1.414, freq * 2.76, freq * 5.4, freq * 8.91],
            [1.0, 0.65, 0.4, 0.25, 0.12],
            [ring, ring * 0.85, ring * 0.6, ring * 0.4, ring * 0.25]
        ]), exciter);
        sig = sig * env * 0.25;
        Out.ar(out, Pan2.ar(sig * amp, pan.clip(-1, 1)));
    }).add;

    // Escapement Gear Creak & Friction
    SynthDef(\escapementCreak, { |out=0, freq=450, dur=0.15, amp=0.15, pan=0|
        var env, noise, sig;
        env = EnvGen.ar(Env.linen(0.005, (dur - 0.02).max(0.01), 0.015), doneAction: 2);
        noise = Crackle.ar(1.95) * 0.3 + PinkNoise.ar(0.7);
        sig = Resonz.ar(noise, freq.clip(100, 4000), 0.05) * 16.0;
        sig = (sig * 1.8).fold2(0.85) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan.clip(-1, 1)));
    }).add;

    s.sync;

    // --- Continuous Textures ---
    // The Swarm: 200 desynchronized balance wheels breathing together
    Ndef(\horologySwarm, { |amp=0, rate=5.2, chaos=0.35, filtCut=3200|
        var clk, trigArr, freqs, clicks, brassDrone, sig;
        clk = Impulse.ar(rate + LFNoise2.kr(0.2).range(chaos.neg, chaos));
        trigArr = Dust.ar(rate * [12, 15, 18, 22, 27, 33]);
        freqs = [1800, 2400, 3100, 4200, 5600, 7100];
        clicks = Mix.fill(6, { |i|
            var tr = trigArr[i];
            var env = Decay2.ar(tr, 0.0003, 0.018);
            var bpf = BPF.ar(WhiteNoise.ar * env, freqs[i] * LFNoise1.kr(0.3).range(0.96, 1.04), 0.08) * 12.0;
            Pan2.ar(bpf, LFNoise1.kr(0.4 + (i * 0.1)).range(-0.85, 0.85));
        });
        brassDrone = DynKlank.ar(Ref([
            [130.81, 196.0, 261.63, 392.0],
            [0.5, 0.3, 0.2, 0.1],
            [1.8, 1.5, 1.2, 0.8]
        ]), PinkNoise.ar(0.015)) * LFNoise2.kr(0.1).range(0.2, 0.6);
        sig = clicks + Pan2.ar(brassDrone, 0);
        sig = LPF.ar(sig, filtCut.clip(200, 16000));
        sig * amp;
    });

    // Breath of Time: Airflow and micro-phase interference of hundreds of pendulum swings
    Ndef(\pendulumBreathing, { |amp=0, period=2.8, depth=0.7, bright=600|
        var breathLFO, airNoise, springDrone, panCtrl, sig;
        breathLFO = SinOsc.kr(period.reciprocal).range(1 - depth, 1);
        airNoise = BPF.ar(BrownNoise.ar, SinOsc.kr(period.reciprocal * 0.5).range(180, bright), 0.4) * 8.0;
        springDrone = VarSaw.ar([55, 55.3], 0, 0.15) * 0.15;
        springDrone = LPF.ar(springDrone, SinOsc.kr(period.reciprocal).range(150, 450));
        sig = (airNoise * breathLFO) + springDrone;
        panCtrl = SinOsc.kr(period.reciprocal * 0.5).range(-0.4, 0.4);
        sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], panCtrl) } { Pan2.ar(sig, panCtrl) };
        sig * amp;
    });

    // --- Master Bus & Workshop Acoustics ---
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var textures = Ndef.ar(\horologySwarm, 2) + Ndef.ar(\pendulumBreathing, 2);
        synths + textures;
    });

    // Slot 10: Narrow wooden workshop acoustics with resonant delay
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.45);
    };
    Ndef(\masterMix).set(\wet10, 0.25);

    // Slot 11: Subtle fluttering metallic reflections (inter-gear reverberance)
    Ndef(\masterMix)[11] = \filter -> { |in|
        CombL.ar(in, 0.2, [0.038, 0.047] * SinOsc.kr(0.08).range(0.98, 1.02), 0.8);
    };
    Ndef(\masterMix).set(\wet11, 0.0);

    Ndef(\masterMix).play;
    s.sync;

    // --- Timeline Score ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Adormecida e os Primeiros Escapamentos]".postln;
        // Fade previous piece leftovers smoothly
        Ndef(\antarcticSilence).fadeTime = 3;
        Ndef(\antarcticSilence).xset(\amp, 0);
        Ndef(\mapFold).fadeTime = 2;
        Ndef(\mapFold).xset(\amp, 0);
        Pbindef(\antarcticSeq).stop;
        Pbindef(\mapFoldSeq).stop;

        Ndef(\pendulumBreathing).fadeTime = 6;
        Ndef(\pendulumBreathing).xset(\amp, 0.35, \period, 3.2, \bright, 450);

        // Slow grandfather clock pulse
        Pbindef(\pendulumSeq,
            \instrument, \clockTick,
            \out, ~synthBus,
            \dur, Pseq([0.62, 0.58], inf),
            \freq, Pseq([1800, 1400], inf),
            \bodyFreq, Pseq([110, 95], inf),
            \decay, 0.045,
            \amp, 0.26,
            \pan, Pseq([-0.35, 0.35], inf)
        ).play;

        // Active Wait 1: Emergence of brass pocket watches
        4.do { |i|
            Ndef(\pendulumBreathing).xset(\depth, 0.4 + (i * 0.1));
            3.wait;
        };

        "0:12 - [Cue 2: O Enxame Desfasado de Latão]".postln;
        Ndef(\horologySwarm).fadeTime = 8;
        Ndef(\horologySwarm).xset(\amp, 0.38, \rate, 6.0, \chaos, 0.4, \filtCut, 2800);
        Ndef(\masterMix).set(\wet11, 0.25);

        // Fast staggered chronometer ticking (phasing polyrhythms)
        Pbindef(\chronoSwarm,
            \instrument, \clockTick,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.13, 0.12, 0.24, 0.125, 0.115], inf),
            \freq, Pexprand(3200, 8500, inf),
            \bodyFreq, Pwhite(280, 520, inf),
            \decay, Pwhite(0.015, 0.035, inf),
            \amp, Pexprand(0.08, 0.2, inf),
            \pan, Pwhite(-0.75, 0.75, inf)
        ).play;

        // Active Wait 2: Microscopic slippage of the escapement teeth
        6.do { |i|
            Synth(\escapementCreak, [
                \out, ~synthBus,
                \freq, exprand(300, 1600),
                \dur, rrand(0.08, 0.2),
                \amp, 0.14,
                \pan, rrand(-0.6, 0.6)
            ]);
            Ndef(\horologySwarm).xset(\filtCut, 2800 + (i * 350));
            3.5.wait;
        };

        "0:33 - [Cue 3: Os Carrilhões Franceses Despertam]".postln;
        Ndef(\masterMix).set(\wet10, 0.42);

        // Chimes chiming out of sync: antique harmonics floating above the chatter
        Pbindef(\frenchChimes,
            \instrument, \carrilhao,
            \out, ~synthBus,
            \dur, Pseq([1.75, 1.25, 2.0, 0.75, 2.5, 1.5], inf),
            \midinote, Pseq([67, 71, 74, 76, 72, 69, 64, 79], inf),
            \freq, Pkey(\midinote).midicps,
            \dur_note, Pwhite(2.5, 4.0, inf),
            \ring, Pwhite(2.2, 3.8, inf),
            \amp, Pwhite(0.12, 0.24, inf),
            \pan, Pseq([-0.6, 0.5, -0.3, 0.7, -0.1, 0.2], inf)
        ).play;

        // Active Wait 3: Dense mechanical polyphony
        5.do { |i|
            Pbindef(\chronoSwarm, \dur, Pseq([0.125 - (i * 0.005), 0.13, 0.12 + (i * 0.003), 0.2], inf));
            Ndef(\horologySwarm).xset(\rate, 6.0 + (i * 0.8));
            4.wait;
        };

        "0:53 - [Cue 4: Intrinsic Limit - O Vórtice dos Duzentos Relógios]".postln;
        // Peak kinetic density: every gear winding toward extreme tension
        Ndef(\horologySwarm).fadeTime = 4;
        Ndef(\horologySwarm).xset(\amp, 0.55, \chaos, 1.8, \filtCut, 7500);
        Ndef(\pendulumBreathing).xset(\period, 1.4, \bright, 1400, \amp, 0.45);
        Ndef(\masterMix).set(\wet11, 0.4);

        Pbindef(\pendulumSeq, \dur, 0.25, \amp, 0.32);

        3.do { |i|
            Synth(\carrilhao, [
                \out, ~synthBus,
                \freq, [523.25, 659.25, 783.99, 1046.5].choose,
                \dur, 4.5,
                \ring, 4.0,
                \amp, 0.28,
                \pan, rrand(-0.8, 0.8)
            ]);
            2.5.wait;
        };

        "1:01 - [Cue 5: O Velho Relojoeiro Fecha os Olhos (Settling)]".postln;
        // Abrupt cut of the frantic chimes & high ticks: down to the bare, breathing core
        Pbindef(\frenchChimes).stop;
        Pbindef(\chronoSwarm).stop;
        Ndef(\horologySwarm).fadeTime = 3;
        Ndef(\horologySwarm).xset(\amp, 0.08, \filtCut, 1200);

        Ndef(\masterMix).set(\wet10, 0.55, \wet11, 0.05);

        // The true "respirar do tempo": deep, resonant, unified respiratory oscillation
        Ndef(\pendulumBreathing).fadeTime = 4;
        Ndef(\pendulumBreathing).xset(\amp, 0.5, \period, 4.5, \depth, 0.95, \bright, 320);

        // Soft, singular grandfather pendulum heartbeat
        Pbindef(\pendulumSeq,
            \dur, Pseq([1.125, 1.125], inf),
            \freq, 1100,
            \bodyFreq, 72,
            \decay, 0.065,
            \amp, 0.22,
            \pan, Pseq([-0.15, 0.15], inf)
        );

        // Active Wait 4: Contemplative microscopic defasagens
        4.do { |i|
            Synth(\escapementCreak, [
                \out, ~synthBus,
                \freq, 280,
                \dur, 0.22,
                \amp, 0.08,
                \pan, if(i.even, 0.2.neg, 0.2)
            ]);
            3.5.wait;
        };

        "1:15 - [Cue 6: Extrinsic Limit - O Tempo Dissolve-se no Vácuo]".postln;
        // Subtle final French bell sounding the hour before silence
        Synth(\carrilhao, [\out, ~synthBus, \freq, 440, \dur, 5.0, \ring, 4.5, \amp, 0.22, \pan, 0]);

        Pbindef(\pendulumSeq).stop;
        Ndef(\horologySwarm).fadeTime = 5;
        Ndef(\horologySwarm).xset(\amp, 0);

        Ndef(\pendulumBreathing).fadeTime = 6;
        Ndef(\pendulumBreathing).xset(\amp, 0);

        6.wait;

        // Clean termination of block-specific resources
        Pbindef(\pendulumSeq).stop;
        Pbindef(\pendulumSeq).clear;
        Pbindef(\chronoSwarm).stop;
        Pbindef(\chronoSwarm).clear;
        Pbindef(\frenchChimes).stop;
        Pbindef(\frenchChimes).clear;

        Ndef(\horologySwarm).clear(1);
        Ndef(\pendulumBreathing).clear(1);
        Ndef(\masterMix).clear(2);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
var win, tabs, tabBtns, zoneViews, curTab = 0;

~cc = IdentityDictionary[
    \vol1 -> 14, \pan1 -> 15, \mute1 -> 16, \min1 -> 17, \max1 -> 18,
    \hpf1 -> 19, \lpf1 -> 20, \rq1 -> 21, \atk1 -> 22, \dec1 -> 23, \sus1 -> 24, \rls1 -> 25, \fxFold -> 26,
    \vol2 -> 27, \pan2 -> 28, \mute2 -> 29, \min2 -> 30, \max2 -> 31,
    \hpf2 -> 32, \lpf2 -> 33, \rq2 -> 34, \atk2 -> 35, \dec2 -> 36, \sus2 -> 37, \rls2 -> 38, \fxLissRatio -> 39,
    \vol3 -> 40, \pan3 -> 41, \mute3 -> 42, \min3 -> 43, \max3 -> 44,
    \hpf3 -> 45, \lpf3 -> 46, \rq3 -> 47, \atk3 -> 48, \dec3 -> 49, \sus3 -> 50, \rls3 -> 51, \fxMatrixRing -> 52,
    \delMix -> 53, \delTime -> 54, \revMix -> 55, \revTime -> 56, \panic -> 57
];

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

s.waitForBoot({
    ~ccVals = IdentityDictionary[
        \vol1 -> 0.28, \pan1 -> 0.0, \mute1 -> 0.0, \min1 -> 24, \max1 -> 65,
        \hpf1 -> 28.0, \lpf1 -> 1800.0, \rq1 -> 0.45, \atk1 -> 0.02, \dec1 -> 0.3, \sus1 -> 0.8, \rls1 -> 0.4, \fxFold -> 0.0,
        \vol2 -> 0.22, \pan2 -> (-0.35), \mute2 -> 0.0, \min2 -> 36, \max2 -> 96,
        \hpf2 -> 90.0, \lpf2 -> 5200.0, \rq2 -> 0.35, \atk2 -> 0.01, \dec2 -> 0.2, \sus2 -> 0.7, \rls2 -> 0.5, \fxLissRatio -> 0.0,
        \vol3 -> 0.18, \pan3 -> 0.35, \mute3 -> 0.0, \min3 -> 48, \max3 -> 120,
        \hpf3 -> 220.0, \lpf3 -> 7500.0, \rq3 -> 0.25, \atk3 -> 0.005, \dec3 -> 0.15, \sus3 -> 0.5, \rls3 -> 0.3, \fxMatrixRing -> 0.0,
        \delMix -> 0.0, \delTime -> 0.28, \revMix -> 0.0, \revTime -> 2.4
    ];

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~busSubMix = Bus.audio(s, 2);
    ~busFxSend = Bus.audio(s, 2);

    SynthDef(\lissajousSub, {
        |out=0, fxBus=0, freq=55, gate=1, vel=1, vol=0.25, pan=0, mute=0,
         hpf=30, lpf=2000, rq=0.4, atk=0.01, dec=0.2, sus=0.8, rls=0.3, fxFold=0|
        var env, sig, fmod, lfo;
        lfo = SinOsc.kr(0.2).range(0.99, 1.01);
        fmod = freq * lfo;
        sig = SinOsc.ar(fmod) * 0.6 + Saw.ar(fmod * 0.5, 0.4);
        sig = Fold.ar(sig * (1.0 + (fxFold * 8.0)), -0.75, 0.75);
        sig = MoogFF.ar(sig, lpf.clip(20, 20000), (1.0 - rq) * 3.8);
        sig = HPF.ar(sig, hpf.clip(20, 18000));
        sig = LeakDC.ar(sig);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        sig = Pan2.ar(sig * env * vel * vol * (1.0 - mute), pan);
        Out.ar(out, sig);
        Out.ar(fxBus, sig * 0.4);
    }).add;

    SynthDef(\phosphorBeam, {
        |out=0, fxBus=0, freq=220, gate=1, vel=1, vol=0.2, pan=(-0.35), mute=0,
         hpf=100, lpf=5000, rq=0.3, atk=0.01, dec=0.3, sus=0.7, rls=0.4, fxLissRatio=0|
        var env, sigX, sigY, ratio, morph, combined;
        ratio = 1.0 + (fxLissRatio * 3.0);
        sigX = SinOsc.ar(freq * [0.998, 1.002]);
        sigY = VarSaw.ar(freq * ratio, 0, SinOsc.kr(0.4).range(0.1, 0.9));
        combined = Splay.ar([sigX[0] * sigY, sigX[1] + (sigY * 0.5)]);
        morph = (combined * (1.0 + (fxLissRatio * 3.0))).tanh;
        morph = RLPF.ar(morph, lpf.clip(20, 20000), rq.clip(0.05, 1.0));
        morph = HPF.ar(morph, hpf.clip(20, 18000));
        morph = LeakDC.ar(morph);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls, curve: -3), gate, doneAction: 2);
        morph = if(morph.isKindOf(Collection)) { Balance2.ar(morph[0], morph[1], pan, env * vel * vol * (1.0 - mute)) } { Pan2.ar(morph, pan, env * vel * vol * (1.0 - mute)) };
        Out.ar(out, morph);
        Out.ar(fxBus, morph * 0.5);
    }).add;

    SynthDef(\pinMatrixPluck, {
        |out=0, fxBus=0, freq=440, gate=1, vel=1, vol=0.18, pan=0.35, mute=0,
         hpf=200, lpf=8000, rq=0.2, atk=0.005, dec=0.2, sus=0.4, rls=0.3, fxMatrixRing=0|
        var env, exciter, sig, ringMod;
        exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015));
        sig = CombL.ar(exciter, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.2);
        ringMod = sig * SinOsc.ar(freq * (1.5 + (fxMatrixRing * 4.25)));
        sig = XFade2.ar(sig, ringMod, (fxMatrixRing * 2.0) - 1.0);
        sig = RLPF.ar(sig, lpf.clip(20, 20000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 18000));
        sig = LeakDC.ar(sig);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        sig = Pan2.ar(sig * env * vel * vol * (1.0 - mute), pan);
        Out.ar(out, sig);
        Out.ar(fxBus, sig * 0.6);
    }).add;

    SynthDef(\analogSpaceFX, {
        |inBus=0, outBus=0, delMix=0, delTime=0.25, revMix=0, revTime=2.0|
        var dry, delayed, reverbed, wet;
        dry = In.ar(inBus, 2);
        delayed = CombL.ar(dry, 1.5, delTime.clip(0.02, 1.2), 3.0);
        wet = dry + (delayed * delMix);
        reverbed = GVerb.ar(wet[0] + wet[1], 140, revTime.clip(0.3, 8.0), 0.5, 0.6, 15, 0, 0.7, 0.5);
        wet = (dry * (1.0 - (revMix * 0.5))) + (reverbed * revMix);
        Out.ar(outBus, wet);
    }).add;

    SynthDef(\safetyMaster, {
        |inBus=0, out=0|
        var sig = In.ar(inBus, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        ReplaceOut.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \analogSpaceFX, [
        \inBus, ~busFxSend,
        \outBus, ~busSubMix,
        \delMix, ~buses.delMix.asMap,
        \delTime, ~buses.delTime.asMap,
        \revMix, ~buses.revMix.asMap,
        \revTime, ~buses.revTime.asMap
    ]);

    ~masterSynth = Synth.tail(~masterGroup, \safetyMaster, [
        \inBus, ~busSubMix,
        \out, 0
    ]);

    ~polyNotes1 = Array.newClear(128);
    ~polyNotes2 = Array.newClear(128);
    ~polyNotes3 = Array.newClear(128);

    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        var amp = vel / 127.0;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~polyNotes1[noteNum] = ~polyNotes1[noteNum].add(
                Synth.head(~synthGroup, \lissajousSub, [
                    \out, ~busSubMix, \fxBus, ~busFxSend, \freq, noteNum.midicps, \vel, amp,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxFold, ~buses.fxFold.asMap
                ])
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~polyNotes2[noteNum] = ~polyNotes2[noteNum].add(
                Synth.head(~synthGroup, \phosphorBeam, [
                    \out, ~busSubMix, \fxBus, ~busFxSend, \freq, noteNum.midicps, \vel, amp,
                    \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                    \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                    \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                    \fxLissRatio, ~buses.fxLissRatio.asMap
                ])
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~polyNotes3[noteNum] = ~polyNotes3[noteNum].add(
                Synth.head(~synthGroup, \pinMatrixPluck, [
                    \out, ~busSubMix, \fxBus, ~busFxSend, \freq, noteNum.midicps, \vel, amp,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                    \fxMatrixRing, ~buses.fxMatrixRing.asMap
                ])
            );
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        ~polyNotes1[noteNum].do(_.set(\gate, 0));
        ~polyNotes1[noteNum] = nil;
        ~polyNotes2[noteNum].do(_.set(\gate, 0));
        ~polyNotes2[noteNum] = nil;
        ~polyNotes3[noteNum].do(_.set(\gate, 0));
        ~polyNotes3[noteNum] = nil;
    }, srcID: ~myUid);

    ~panicFunc = {
        128.do { |i|
            ~polyNotes1[i].do(_.set(\gate, 0));
            ~polyNotes2[i].do(_.set(\gate, 0));
            ~polyNotes3[i].do(_.set(\gate, 0));
        };
        ~polyNotes1 = Array.newClear(128);
        ~polyNotes2 = Array.newClear(128);
        ~polyNotes3 = Array.newClear(128);
    };

    MIDIdef.cc(\panicCC, { |val| if(val > 63) { ~panicFunc.value } }, ccNum: ~cc[\panic], srcID: ~myUid);

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
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.2) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.3, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    defer {
        var screen = Window.availableBounds;
        var wH = min(740, screen.height - 60);
        var zmList;

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("MODULAR LABORATORY // PHOSPHOR LISSAJOUS CORE", Rect((screen.width - 860) / 2, (screen.height - wH) / 2, 860, wH), resizable: false, scroll: true);
        ~mainWin.view.background = Color.new255(18, 20, 22);

        ~ui = ();
        tabBtns = Array.newClear(3);
        zoneViews = Array.newClear(3);

        zmList = [
            (title: "ZONE 1: LISSAJOUS SUB CORE", fxKey: \fxFold, fxLabel: "WaveFold", z: 1),
            (title: "ZONE 2: PHOSPHOR BEAM OSC", fxKey: \fxLissRatio, fxLabel: "BeamHarmonics", z: 2),
            (title: "ZONE 3: PIN-MATRIX PATCH", fxKey: \fxMatrixRing, fxLabel: "MatrixRingMod", z: 3)
        ];

        3.do { |idx|
            tabBtns[idx] = Button(~mainWin, Rect(20 + (idx * 270), 15, 260, 36))
                .states_([
                    [zmList[idx].title, Color.new255(140, 240, 160), Color.new255(28, 38, 32)],
                    [zmList[idx].title, Color.black, Color.new255(60, 230, 110)]
                ])
                .font_(Font("Monaco", 11, true))
                .action_({
                    curTab = idx;
                    3.do { |j|
                        zoneViews[j].visible = (j == curTab);
                        tabBtns[j].value = if(j == curTab, 1, 0);
                    };
                });
        };
        tabBtns[0].value = 1;

        zmList.do { |zm, idx|
            var z = zm.z;
            var vKey = ("vol" ++ z).asSymbol;
            var pKey = ("pan" ++ z).asSymbol;
            var mKey = ("mute" ++ z).asSymbol;
            var minK = ("min" ++ z).asSymbol;
            var maxK = ("max" ++ z).asSymbol;
            var hKey = ("hpf" ++ z).asSymbol;
            var lKey = ("lpf" ++ z).asSymbol;
            var rKey = ("rq" ++ z).asSymbol;
            var aKey = ("atk" ++ z).asSymbol;
            var dKey = ("dec" ++ z).asSymbol;
            var sKey = ("sus" ++ z).asSymbol;
            var rlKey = ("rls" ++ z).asSymbol;
            var zv;

            zv = CompositeView(~mainWin, Rect(20, 60, 820, 520));
            zv.background = Color.new255(24, 28, 30);
            zv.visible = (idx == 0);
            zoneViews[idx] = zv;

            StaticText(zv, Rect(20, 15, 400, 24))
                .string_(zm.title)
                .font_(Font("Monaco", 14, true))
                .stringColor_(Color.new255(80, 255, 140));

            ~ui[vKey] = EZSlider(zv, Rect(20, 50, 380, 22), "Vol [CC" ++ ~cc[vKey] ++ "]", \amp, { |sl|
                ~ccVals[vKey] = sl.value; ~buses[vKey].set(sl.value);
            }, ~ccVals[vKey]);

            ~ui[pKey] = EZSlider(zv, Rect(20, 80, 380, 22), "Pan [CC" ++ ~cc[pKey] ++ "]", \bipolar, { |sl|
                ~ccVals[pKey] = sl.value; ~buses[pKey].set(sl.value);
            }, ~ccVals[pKey]);

            ~ui[mKey] = Button(zv, Rect(420, 50, 80, 24))
                .states_([["MUTE", Color.white, Color.new255(50, 50, 50)], ["MUTED", Color.white, Color.new255(180, 40, 40)]])
                .action_({ |btn|
                    var mVal = btn.value.asFloat;
                    ~ccVals[mKey] = mVal; ~buses[mKey].set(mVal);
                });

            ~ui[minK] = EZSlider(zv, Rect(20, 115, 380, 22), "KeyMin [CC" ++ ~cc[minK] ++ "]", ControlSpec(0, 127, \lin, 1), { |sl|
                ~ccVals[minK] = sl.value;
            }, ~ccVals[minK]);

            ~ui[maxK] = EZSlider(zv, Rect(420, 115, 380, 22), "KeyMax [CC" ++ ~cc[maxK] ++ "]", ControlSpec(0, 127, \lin, 1), { |sl|
                ~ccVals[maxK] = sl.value;
            }, ~ccVals[maxK]);

            ~ui[hKey] = EZKnob(zv, Rect(30, 160, 85, 95), "HPF [CC" ++ ~cc[hKey] ++ "]", \freq, { |kn|
                ~ccVals[hKey] = kn.value; ~buses[hKey].set(kn.value);
            }, ~ccVals[hKey]);

            ~ui[lKey] = EZKnob(zv, Rect(135, 160, 85, 95), "LPF [CC" ++ ~cc[lKey] ++ "]", \freq, { |kn|
                ~ccVals[lKey] = kn.value; ~buses[lKey].set(kn.value);
            }, ~ccVals[lKey]);

            ~ui[rKey] = EZKnob(zv, Rect(240, 160, 85, 95), "Reso [CC" ++ ~cc[rKey] ++ "]", ControlSpec(1.0, 0.05, \lin), { |kn|
                ~ccVals[rKey] = kn.value; ~buses[rKey].set(kn.value);
            }, ~ccVals[rKey]);

            ~ui[zm.fxKey] = EZKnob(zv, Rect(345, 160, 105, 95), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]", \unipolar, { |kn|
                ~ccVals[zm.fxKey] = kn.value; ~buses[zm.fxKey].set(kn.value);
            }, ~ccVals[zm.fxKey]);

            ~ui[aKey] = EZKnob(zv, Rect(30, 280, 85, 95), "Atk [CC" ++ ~cc[aKey] ++ "]", ControlSpec(0.005, 4.0, \exp), { |kn|
                ~ccVals[aKey] = kn.value; ~buses[aKey].set(kn.value);
            }, ~ccVals[aKey]);

            ~ui[dKey] = EZKnob(zv, Rect(135, 280, 85, 95), "Dec [CC" ++ ~cc[dKey] ++ "]", ControlSpec(0.01, 4.0, \exp), { |kn|
                ~ccVals[dKey] = kn.value; ~buses[dKey].set(kn.value);
            }, ~ccVals[dKey]);

            ~ui[sKey] = EZKnob(zv, Rect(240, 280, 85, 95), "Sus [CC" ++ ~cc[sKey] ++ "]", \unipolar, { |kn|
                ~ccVals[sKey] = kn.value; ~buses[sKey].set(kn.value);
            }, ~ccVals[sKey]);

            ~ui[rlKey] = EZKnob(zv, Rect(345, 280, 85, 95), "Rls [CC" ++ ~cc[rlKey] ++ "]", ControlSpec(0.02, 5.0, \exp), { |kn|
                ~ccVals[rlKey] = kn.value; ~buses[rlKey].set(kn.value);
            }, ~ccVals[rlKey]);
        };

        ~ui[\delMix] = EZSlider(~mainWin, Rect(25, 595, 280, 20), "SpaceDelay [CC" ++ ~cc[\delMix] ++ "]", \unipolar, { |sl|
            ~ccVals[\delMix] = sl.value; ~buses.delMix.set(sl.value);
        }, ~ccVals[\delMix]);

        ~ui[\delTime] = EZSlider(~mainWin, Rect(25, 620, 280, 20), "DelayRate [CC" ++ ~cc[\delTime] ++ "]", ControlSpec(0.02, 1.2, \exp), { |sl|
            ~ccVals[\delTime] = sl.value; ~buses.delTime.set(sl.value);
        }, ~ccVals[\delTime]);

        ~ui[\revMix] = EZSlider(~mainWin, Rect(325, 595, 280, 20), "GVerbWet [CC" ++ ~cc[\revMix] ++ "]", \unipolar, { |sl|
            ~ccVals[\revMix] = sl.value; ~buses.revMix.set(sl.value);
        }, ~ccVals[\revMix]);

        ~ui[\revTime] = EZSlider(~mainWin, Rect(325, 620, 280, 20), "ChamberTime [CC" ++ ~cc[\revTime] ++ "]", ControlSpec(0.3, 8.0, \lin), { |sl|
            ~ccVals[\revTime] = sl.value; ~buses.revTime.set(sl.value);
        }, ~ccVals[\revTime]);

        Button(~mainWin, Rect(630, 595, 200, 45))
            .states_([["PANIC (KILL VOICES)", Color.white, Color.new255(160, 30, 30)]])
            .font_(Font("Monaco", 12, true))
            .action_({ ~panicFunc.value });

        ~mainWin.front;

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
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: Ternos de Congo, Moçambiques, Gungas Metálicas e Canto Sagrado

// 1. Layer 1: Gungas de Lata (Rattling Tin Shakers & Ankle Bells)
Ndef(\gungas, { |t_trig=0, amp=0.22, pan=0, metalFreq=3400, rattleDec=0.08|
    var trigA, trigEnv, noiseBurst, rattle, modal, sig;
    trigA = K2A.ar(t_trig);
    trigEnv = Decay2.ar(trigA, 0.001, rattleDec);

    // Stochastic seed beads inside the tin can
    noiseBurst = WhiteNoise.ar * Dust.ar(140).range(0.3, 1.0);

    // Dynamic metallic tin resonance (DynKlank with Ref)
    modal = DynKlank.ar(
        `[[metalFreq, metalFreq * 1.48, metalFreq * 2.12, metalFreq * 3.19],
          [0.8, 0.6, 0.5, 0.3],
          [0.05, 0.08, 0.04, 0.03]],
        noiseBurst * trigEnv
    );

    // Combined rattle impact and resonant metallic body
    rattle = (modal * 0.7) + (HPF.ar(noiseBurst * trigEnv, 4000) * 0.5);
    sig = Pan2.ar(rattle.softclip, pan, amp);
    sig;
}).play;
Ndef(\gungas).fadeTime = 3;

// Spatial street procession ambience for Gungas
Ndef(\gungas)[10] = \filter -> { |in|
    var earlyRef = CombC.ar(in, 0.2, [0.031, 0.047], 0.6);
    FreeVerb2.ar(in[0] + earlyRef[0], in[1] + earlyRef[1], 1, 0.55, 0.4);
};
Ndef(\gungas).set(\wet10, 0.32);

// 2. Layer 2: Tambores de Congo / Caixas de Folia (Deep Skin & Wooden Shell)
Ndef(\tamborCongo, { |t_trig=0, freq=68, amp=0.35, pan=0, stickTight=0.015, toneDec=0.45|
    var trigA, strikeEnv, bodyEnv, pitchEnv, strike, membrane, woodShell, sig;
    trigA = K2A.ar(t_trig);
    strikeEnv = Decay2.ar(trigA, 0.001, stickTight);
    bodyEnv = Decay2.ar(trigA, 0.01, toneDec);

    // Pitch sweep of the stretched leather drumhead
    pitchEnv = freq * (1 + (1.6 * Decay.ar(trigA, 0.025)));
    strike = BPF.ar(PinkNoise.ar, 1200, 0.4) * strikeEnv * 4.0;

    // Resonant membrane fundamental & 2nd harmonic
    membrane = (SinOsc.ar(pitchEnv) * 0.8) + (SinOsc.ar(pitchEnv * 1.58) * 0.45);
    membrane = membrane * bodyEnv;

    // Wooden barrel cavity resonance
    woodShell = BPF.ar(membrane + strike, freq * 2.8, 0.15) * 6.0;

    sig = (membrane + strike + (woodShell * 0.4)).tanh;
    sig = Pan2.ar(sig, pan, amp);
    sig;
}).play;
Ndef(\tamborCongo).fadeTime = 3;

// Earthy street room response for the drums
Ndef(\tamborCongo)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.4, 0.6);
};
Ndef(\tamborCongo).set(\wet10, 0.2);

// 3. Layer 3: Louvor e Coroação (Vocal Vowel Formants & Accordion Breath)
Ndef(\louvorVocal, { |t_trig=0, freq=220, amp=0.2, pan=0, vowel=0.5, vibrato=4.8|
    var trigA, env, fVib, source, bodyMono, f1, f2, f3, formants, accordion, sig;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env([0, 1, 0.7, 0], [0.12, 0.6, 0.9], [2, -2, -3]), trigA);

    // Slow organic vibrato for the vocal line
    fVib = freq * (1 + (SinOsc.kr(vibrato).range(-0.012, 0.012)));

    // Reed oscillator (vocal cords + sanfona accordion texture)
    source = Saw.ar([fVib, fVib * 1.006]) * 0.5;
    source = source + (Pulse.ar(fVib * 0.5, 0.45) * 0.3);
    bodyMono = source.sum;

    // Vocal Formant Resonators (/o/ to /a/ blend, Nossa Senhora do Rosário)
    f1 = SelectX.kr(vowel, [450, 750, 600]);
    f2 = SelectX.kr(vowel, [800, 1200, 1050]);
    f3 = SelectX.kr(vowel, [2800, 2400, 2600]);

    formants = (BPF.ar(bodyMono, f1, 0.12) * 9.0)
             + (BPF.ar(bodyMono, f2, 0.14) * 8.0)
             + (BPF.ar(bodyMono, f3, 0.18) * 6.0);

    // Warm Moog filter rounding
    accordion = (MoogFF.ar(formants, 3800, 1.2) * 1.8).tanh;
    sig = Pan2.ar(accordion * env, pan, amp);
    sig;
}).play;
Ndef(\louvorVocal).fadeTime = 4;

// Church plaza reverberation for the procession chant
Ndef(\louvorVocal)[10] = \filter -> { |in|
    var delayed = CombL.ar(in, 0.5, [0.26, 0.39], 2.2);
    FreeVerb2.ar(in[0] + (delayed[0] * 0.4), in[1] + (delayed[1] * 0.4), 1, 0.82, 0.3);
};
Ndef(\louvorVocal).set(\wet10, 0.38);

// --- Sequences (Cadências de Congos e Moçambiques) ---

// Gunga ankle shaker rhythm (syncopated 6/8 - 12/8 march)
Pbindef(\seqGungas,
    \t_trig, 1,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \metalFreq, Pwhite(3100, 3900, inf),
    \rattleDec, Pwrand([0.06, 0.11, 0.16], [0.65, 0.25, 0.1], inf),
    \pan, Pwhite(-0.55, 0.55, inf),
    \amp, Pseq([0.22, 0.14, 0.24, 0.16, 0.15, 0.26], inf)
);
Ndef(\gungas).quant = 1;
Ndef(\gungas)[1] = \set -> Pbindef(\seqGungas);

// Tambor grave congo cadence (driving syncopated low-end)
Pbindef(\seqTambor,
    \t_trig, 1,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \freq, Pseq([55, 62, 55, 73, 55], inf),
    \toneDec, Pwrand([0.35, 0.5, 0.25], [0.6, 0.3, 0.1], inf),
    \pan, Pseq([0, -0.15, 0.15, 0, 0.1], inf),
    \amp, Pseq([0.38, 0.24, 0.28, 0.34, 0.32], inf)
);
Ndef(\tamborCongo).quant = 1;
Ndef(\tamborCongo)[1] = \set -> Pbindef(\seqTambor);

// Hino / Canto da coroação (Mixolydian modal devotion)
Pbindef(\seqLouvor,
    \t_trig, 1,
    \dur, Pseq([1.0, 0.5, 0.5, 1.5, 0.5], inf),
    \midinote, Pseq([57, 60, 62, 64, 62, 60, 59, 57], inf),
    \freq, Pkey(\midinote).midicps,
    \vowel, Pseq([0.1, 0.4, 0.8, 0.5, 0.2], inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \amp, Pwhite(0.18, 0.26, inf)
);
Ndef(\louvorVocal).quant = 1;
Ndef(\louvorVocal)[1] = \set -> Pbindef(\seqLouvor);
)

// Live performance tweaks:
// Ndef(\gungas).xset(\metalFreq, 4500); // Sharpen gungas metal sound | Revert: Ndef(\gungas).xset(\metalFreq, 3400);
// Pbindef(\seqTambor, \dur, Pseq([0.25, 0.25, 0.25, 0.25], inf)); // Accelerando marching steps | Revert: Pbindef(\seqTambor, \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf));
// Ndef(\louvorVocal).set(\wet10, 0.65); // Cathedral expansion | Revert: Ndef(\louvorVocal).set(\wet10, 0.38);
// Pbindef(\seqGungas).stop; Ndef(\gungas).fadeTime = 3; Ndef(\gungas).clear(3); // Rollback Gungas
// Pbindef(\seqTambor).stop; Ndef(\tamborCongo).fadeTime = 3; Ndef(\tamborCongo).clear(3); // Rollback Tambores
// Pbindef(\seqLouvor).stop; Ndef(\louvorVocal).fadeTime = 4; Ndef(\louvorVocal).clear(4); // Rollback Louvor

