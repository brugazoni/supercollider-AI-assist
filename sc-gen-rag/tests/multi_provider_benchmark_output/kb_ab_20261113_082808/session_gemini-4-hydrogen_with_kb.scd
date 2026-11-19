// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Hydrogen
// Model ID: openrouter:google/gemini-4-hydrogen
// Date: 2026-11-13T11:46:13.306231+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\antarcticSilence).fadeTime = 4;
Ndef(\antarcticSilence, { |freq=55, amp=0.3, pan=0, cutoff=600, rq=0.2, windAmp=0.15, t_trig=0|
    var env, sub, body, wind, sig;
    env = EnvGen.ar(Env.perc(1.5, 4.0, 1, -2), t_trig);
    sub = (SinOsc.ar(freq) * 0.5) + (SinOsc.ar(freq * 2) * 0.25);
    body = Splay.ar(LFTri.ar(freq * [0.995, 1.0, 1.005, 1.502])) * 0.4;
    wind = BPF.ar(PinkNoise.ar(1), cutoff * LFNoise1.kr(0.1).range(0.7, 1.3), rq) * 4.0 * windAmp;
    sig = Balance2.ar(body[0] + sub + wind, body[1] + sub + wind, pan, amp * (0.4 + (0.6 * env)));
    sig;
}).play;

Pbindef(\silenceSeq,
    \dur, Pseq([4, 6, 5], inf),
    \degree, Pseq([0, -2, -3, -5], inf),
    \octave, 3,
    \cutoff, Pwhite(300, 900, inf),
    \t_trig, 1,
    \amp, Pwhite(0.25, 0.4, inf)
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\silenceSeq);
// Pbindef(\silenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // 0. SAFETY LIMITER
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 1. DISCRETE SYNTHDEFS
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.15, pan=0, decay=0.04, bright=1.0|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, decay.max(0.01), 1, -6), doneAction: 2);
        exc = (Impulse.ar(0) * 0.8) + (WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(0.0005, 0.005)));
        sig = Ringz.ar(exc, freq, decay) + (Ringz.ar(exc, freq * 2.13, decay * 0.6) * 0.4 * bright);
        sig = HPF.ar(sig, 600);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\frenchChime, { |out=0, freq=660, amp=0.12, pan=0, dur=2.5, modIdx=1.2|
        var env, modEnv, mod, sig, klank;
        env = EnvGen.ar(Env.perc(0.005, dur.max(0.2), 1, -4), doneAction: 2);
        modEnv = EnvGen.ar(Env.perc(0.001, 0.25));
        mod = SinOsc.ar(freq * 2.71) * freq * modIdx * modEnv;
        sig = SinOsc.ar(freq + mod) * 0.5;
        klank = DynKlank.ar(
            Ref([ [freq, freq * 2.0, freq * 3.01, freq * 4.16], [1, 0.5, 0.3, 0.15], [dur, dur * 0.7, dur * 0.4, dur * 0.2] ]),
            Impulse.ar(0) * 0.15
        );
        sig = (sig + klank) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\pendulumSwing, { |out=0, freq=75, amp=0.25, pan=0|
        var env, pEnv, thud, air, sig;
        env = EnvGen.ar(Env.perc(0.01, 0.45, 1, -5), doneAction: 2);
        pEnv = EnvGen.kr(Env([freq * 1.8, freq], [0.04], \exp));
        thud = SinOsc.ar(pEnv) * 0.8 + (SinOsc.ar(pEnv * 2.0) * 0.25);
        air = BPF.ar(PinkNoise.ar(0.4), 320, 0.6) * EnvGen.ar(Env.perc(0.05, 0.35));
        sig = (thud + air) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // 2. CONTINUOUS NDEFS & MASTER MIX
    Ndef(\clockSwarm, { |amp=0, density=12, baseFreq=1800, detune=0.08|
        var trigL, trigR, tickL, tickR, sig;
        trigL = Dust.ar(density) + Impulse.ar(density * 0.37);
        trigR = Dust.ar(density * (1 + detune)) + Impulse.ar(density * 0.37 * (1 - (detune * 0.5)));
        tickL = Ringz.ar(trigL * 0.15, TExpRand.ar(baseFreq * 0.7, baseFreq * 1.6, trigL), 0.035);
        tickR = Ringz.ar(trigR * 0.15, TExpRand.ar(baseFreq * 0.7, baseFreq * 1.6, trigR), 0.035);
        sig = HPF.ar([tickL, tickR], 500) * amp;
        sig;
    });

    Ndef(\timeBreath, { |amp=0, freq=110, breathRate=0.14, cutoff=700|
        var breath, freqs, pad, air, sig;
        breath = SinOsc.kr(breathRate).range(0.25, 1.0);
        freqs = [freq, freq * 1.5, freq * 2.0, freq * 2.502, freq * 3.0];
        pad = Splay.ar(SinOsc.ar(freqs * LFNoise2.kr(0.08 ! 5).range(0.996, 1.004))) * 0.35;
        air = BPF.ar(PinkNoise.ar(0.5), cutoff * breath.linlin(0.25, 1.0, 0.7, 1.4), 0.35) * 2.5;
        sig = Balance2.ar(pad[0] + (air * 0.25), pad[1] + (air * 0.25), 0, amp * breath);
        sig;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\clockSwarm, 2) + Ndef.ar(\timeBreath, 2);
        synths + cont;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: \room.kr(0.75), damp: \damp.kr(0.4));
    };
    Ndef(\masterMix).set(\wet10, 0.15);

    Ndef(\masterMix).play;
    s.sync;

    // 3. CHRONOLOGICAL SCORE
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Estreita]".postln;
        Pbindef(\pendulumSeq,
            \instrument, \pendulumSwing,
            \out, ~synthBus,
            \dur, 1.5,
            \freq, Pseq([72, 68], inf),
            \pan, Pseq([-0.35, 0.35], inf),
            \amp, 0.28
        ).play;

        Pbindef(\tickSeq,
            \instrument, \brassTick,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.25, 0.125, 0.375], inf),
            \freq, Pexprand(1800, 3200, inf),
            \decay, Pwhite(0.025, 0.055, inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, Pwhite(0.08, 0.16, inf)
        ).play;

        3.do { |i|
            Ndef(\masterMix).xset(\wet10, 0.15 + (i * 0.05));
            6.wait;
        };

        "0:18 - [Cue 2: Enxame de Latão]".postln;
        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, 0.35, \density, 14, \baseFreq, 2100);

        Pbindef(\chimeSeq,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([3.0, 2.5, 4.0], inf),
            \degree, Pseq([0, 4, 2, 7, 5], inf),
            \octave, 5,
            \dur, Pseq([2.5, 3.5, 2.0], inf),
            \pan, Pwhite(-0.6, 0.6, inf),
            \amp, Pwhite(0.08, 0.14, inf)
        ).play;

        4.do { |i|
            Pbindef(\tickSeq, \dur, Pseq([0.125, 0.125, 0.166, 0.25], inf));
            Ndef(\clockSwarm).xset(\density, 16 + (i * 5));
            6.wait;
        };

        "0:42 - [Cue 3: Defasagens Microscópicas]".postln;
        Ndef(\clockSwarm).fadeTime = 4;
        Ndef(\clockSwarm).xset(\amp, 0.45, \density, 42, \detune, 0.18, \baseFreq, 2800);
        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet10, 0.42, \room, 0.85);

        4.do { |i|
            Ndef(\clockSwarm).xset(\baseFreq, 2800 + (i * 350));
            5.wait;
        };

        "1:02 - [Cue 4: O Respirar do Tempo]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\pendulumSeq).stop;
        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, 0.04, \density, 4, \baseFreq, 1400);

        Ndef(\timeBreath).fadeTime = 5;
        Ndef(\timeBreath).xset(\amp, 0.48, \freq, 110, \breathRate, 0.14, \cutoff, 650);
        Ndef(\masterMix).xset(\wet10, 0.55, \room, 0.9);

        4.do { |i|
            Ndef(\timeBreath).xset(\cutoff, 550 + (i * 120));
            5.5.wait;
        };

        "1:24 - [Cue 5: Resolução na Ladeira]".postln;
        Pbindef(\chimeSeq).stop;
        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, 0);
        Ndef(\timeBreath).fadeTime = 8;
        Ndef(\timeBreath).xset(\amp, 0);
        Synth(\pendulumSwing, [\out, ~synthBus, \freq, 68, \amp, 0.22, \pan, 0]);

        8.wait;

        Pbindef(\tickSeq).clear;
        Pbindef(\chimeSeq).clear;
        Pbindef(\pendulumSeq).clear;
        Ndef(\clockSwarm).clear(2);
        Ndef(\timeBreath).clear(2);
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
// =====================================================================
// MODULAR PHOSPHOR LISSAJOUS — MULTITIMBRAL MIDI + PAGINATED GUI
// =====================================================================

// 0. CC MAP
~cc = (
    vol1: 10, pan1: 11, mute1: 12, min1: 13, max1: 14, hpf1: 15, lpf1: 16, rq1: 17, atk1: 18, dec1: 19, sus1: 20, rls1: 21, fx1: 22,
    vol2: 30, pan2: 31, mute2: 32, min2: 33, max2: 34, hpf2: 35, lpf2: 36, rq2: 37, atk2: 38, dec2: 39, sus2: 40, rls2: 41, fx2: 42,
    vol3: 50, pan3: 51, mute3: 52, min3: 53, max3: 54, hpf3: 55, lpf3: 56, rq3: 57, atk3: 58, dec3: 59, sus3: 60, rls3: 61, fx3: 62,
    delTime: 70, delMix: 71, revTime: 72, verbMix: 73,
    panic: 120
);

// 1 & 2. MIDI AUTO-DETECTION WITH HARDWARE FALLBACK
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

// 3. SERVER BOOT, BUSES, GROUPS, SYNTHDEFS, MIDI & GUI
s.waitForBoot({
    var screen, winW, winH;

    ~ccVals = (
        vol1: 0.25, pan1: 0.0, mute1: 0.0, min1: 0, max1: 60, hpf1: 28, lpf1: 240, rq1: 0.45, atk1: 0.015, dec1: 0.25, sus1: 0.7, rls1: 0.35, fx1: 0.0,
        vol2: 0.22, pan2: (-0.30), mute2: 0.0, min2: 36, max2: 108, hpf2: 220, lpf2: 5200, rq2: 0.35, atk2: 0.02, dec2: 0.35, sus2: 0.6, rls2: 0.6, fx2: 0.0,
        vol3: 0.20, pan3: 0.30, mute3: 0.0, min3: 24, max3: 127, hpf3: 160, lpf3: 3400, rq3: 0.5, atk3: 0.45, dec3: 0.6, sus3: 0.75, rls3: 1.4, fx3: 0.0,
        delTime: 0.32, delMix: 0.0, revTime: 2.8, verbMix: 0.0
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Zone 1: Matrix Pin Sub (Monophonic Buchla Wavefolder + MoogFF)
    SynthDef(\matrixSub, { |out=0, freq=55, vel=0.8, gate=1, vol=0.25, pan=0.0, mute=0.0,
        hpf=28, lpf=240, rq=0.45, atk=0.015, dec=0.25, sus=0.7, rls=0.35, fx=0.0|
        var env, fLag, sig, folded;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        fLag = Lag.kr(freq, 0.12);
        sig = SinOsc.ar(fLag) + (Saw.ar(fLag * 0.5) * 0.4);
        folded = Fold.ar(sig * (1.0 + (fx * 4.5)), -0.8, 0.8);
        sig = XFade2.ar(sig, folded, (fx * 2.0 - 1.0).clip(-1, 1));
        sig = (MoogFF.ar(sig, lpf.clip(30, 18000), (1.0 - rq).linlin(0, 1, 0.5, 3.6)) * 2.8).tanh;
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = Pan2.ar(sig * env * vel * vol * (1.0 - mute), pan);
        Out.ar(out, sig);
    }).add;

    // Zone 2: Lissajous Harmonics (Polyphonic Rotating X-Y FM)
    SynthDef(\lissajousFM, { |out=0, freq=220, vel=0.8, gate=1, vol=0.22, pan=(-0.30), mute=0.0,
        hpf=220, lpf=5200, rq=0.35, atk=0.02, dec=0.35, sus=0.6, rls=0.6, fx=0.0|
        var env, rot, modX, modY, sigX, sigY, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        rot = SinOsc.kr(0.35 + (fx * 5.0)).range(0.0, 1.0);
        modX = SinOsc.ar(freq * 1.5) * (freq * (0.4 + (fx * 3.2)));
        modY = SinOsc.ar(freq * 2.0) * (freq * (0.3 + (fx * 2.8)));
        sigX = SinOsc.ar(freq + modX, rot * 1.57);
        sigY = SinOsc.ar((freq * 1.003) + modY, (1.0 - rot) * 1.57);
        sig = [sigX, sigY];
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, env * vel * vol * (1.0 - mute)) } { Pan2.ar(sig, pan, env * vel * vol * (1.0 - mute)) };
        Out.ar(out, sig);
    }).add;

    // Zone 3: Phosphor Canopy (Polyphonic Detuned Analog Pad + Allpass Dispersion)
    SynthDef(\phosphorPad, { |out=0, freq=220, vel=0.8, gate=1, vol=0.20, pan=0.30, mute=0.0,
        hpf=160, lpf=3400, rq=0.5, atk=0.45, dec=0.6, sus=0.75, rls=1.4, fx=0.0|
        var env, sig, disp;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = Splay.ar(VarSaw.ar(freq * [0.992, 0.998, 1.0, 1.003, 1.009], 0, 0.35));
        disp = AllpassC.ar(sig, 0.03, (fx * 0.015) + 0.001, 0.12);
        sig = XFade2.ar(sig, disp, (fx * 2.0 - 1.0).clip(-1, 1));
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, env * vel * vol * (1.0 - mute)) } { Pan2.ar(sig, pan, env * vel * vol * (1.0 - mute)) };
        Out.ar(out, sig);
    }).add;

    // Group FX: Stereo Delay + FreeVerb2
    SynthDef(\groupFX, { |inBus=0, outBus=0, delTime=0.32, delMix=0.0, revTime=2.8, verbMix=0.0|
        var sig, del, verb;
        sig = In.ar(inBus, 2);
        del = CombL.ar(sig, 1.5, delTime.clip(0.02, 1.2), 2.5);
        sig = XFade2.ar(sig, sig + del, (delMix * 2.0 - 1.0).clip(-1, 1));
        verb = FreeVerb2.ar(sig[0], sig[1], 1.0, revTime.linlin(0.2, 8.0, 0.2, 0.96), 0.35);
        sig = XFade2.ar(sig, verb, (verbMix * 2.0 - 1.0).clip(-1, 1));
        Out.ar(outBus, sig);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, { |inBus=0, out=0|
        var sig = In.ar(inBus, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \groupFX, [
        \inBus, ~fxBus, \outBus, ~masterBus,
        \delTime, ~buses[\delTime].asMap, \delMix, ~buses[\delMix].asMap,
        \revTime, ~buses[\revTime].asMap, \verbMix, ~buses[\verbMix].asMap
    ]);
    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\inBus, ~masterBus, \out, 0]);

    // Voice Tracking
    ~subSynth = nil;
    ~subNote = nil;
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    ~panicAll = {
        if(~subSynth.notNil) { ~subSynth.set(\gate, 0); ~subSynth = nil; ~subNote = nil };
        128.do { |n|
            if(~zone2Notes[n].notNil) { ~zone2Notes[n].do(_.set(\gate, 0)); ~zone2Notes[n] = nil };
            if(~zone3Notes[n].notNil) { ~zone3Notes[n].do(_.set(\gate, 0)); ~zone3Notes[n] = nil };
        };
    };

    // MIDI Note On
    MIDIdef.noteOn(\modularNoteOn, { |vel, noteNum|
        var vNorm = (vel / 127.0).clip(0.05, 1.0);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~subNote = noteNum;
            if(~subSynth.isNil) {
                ~subSynth = Synth.head(~synthGroup, \matrixSub, [
                    \out, ~fxBus, \freq, freq, \vel, vNorm, \gate, 1,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap,
                    \rls, ~buses[\rls1].asMap, \fx, ~buses[\fx1].asMap
                ]);
            } {
                ~subSynth.set(\freq, freq, \vel, vNorm, \gate, 1);
            };
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth.head(~synthGroup, \lissajousFM, [
                    \out, ~fxBus, \freq, freq, \vel, vNorm, \gate, 1,
                    \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap,
                    \rls, ~buses[\rls2].asMap, \fx, ~buses[\fx2].asMap
                ])
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth.head(~synthGroup, \phosphorPad, [
                    \out, ~fxBus, \freq, freq, \vel, vNorm, \gate, 1,
                    \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap,
                    \rls, ~buses[\rls3].asMap, \fx, ~buses[\fx3].asMap
                ])
            );
        };
    }, srcID: ~myUid);

    // MIDI Note Off
    MIDIdef.noteOff(\modularNoteOff, { |vel, noteNum|
        if((~subNote == noteNum) and: { ~subSynth.notNil }) {
            ~subSynth.set(\gate, 0);
            ~subSynth = nil;
            ~subNote = nil;
        };
        if(~zone2Notes[noteNum].notNil) {
            ~zone2Notes[noteNum].do(_.set(\gate, 0));
            ~zone2Notes[noteNum] = nil;
        };
        if(~zone3Notes[noteNum].notNil) {
            ~zone3Notes[noteNum].do(_.set(\gate, 0));
            ~zone3Notes[noteNum] = nil;
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

    MIDIdef.cc(\panicCC, { |val|
        if(val > 0) { ~panicAll.value };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // 4. PAGINATED GUI (VANILLA CLASSES ONLY)
    defer {
        var tabBtns, pages, zoneMeta, bgCol, panelCol, accentCol, textCol;
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };

        screen = Window.availableBounds;
        winW = 760;
        winH = min(720, screen.height - 60);
        bgCol = Color(0.08, 0.10, 0.09);
        panelCol = Color(0.13, 0.16, 0.14);
        accentCol = Color(0.22, 0.85, 0.45);
        textCol = Color(0.85, 0.95, 0.88);

        ~mainWin = Window("Modular Phosphor Lissajous",
            Rect((screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH),
            scroll: true
        ).background_(bgCol);

        ~ui = ();
        zoneMeta = [
            (title: "1. Matrix Pin Sub", fxKey: \fx1, fxLabel: "Pin Fold"),
            (title: "2. Lissajous FM", fxKey: \fx2, fxLabel: "XY Rotation"),
            (title: "3. Phosphor Pad", fxKey: \fx3, fxLabel: "Dispersion")
        ];

        tabBtns = Array.newClear(zoneMeta.size);
        pages = Array.newClear(zoneMeta.size);

        zoneMeta.do { |zm, idx|
            var zNum = idx + 1;
            var kVol = ("vol" ++ zNum).asSymbol;
            var kPan = ("pan" ++ zNum).asSymbol;
            var kMute = ("mute" ++ zNum).asSymbol;
            var kMin = ("min" ++ zNum).asSymbol;
            var kMax = ("max" ++ zNum).asSymbol;
            var kHpf = ("hpf" ++ zNum).asSymbol;
            var kLpf = ("lpf" ++ zNum).asSymbol;
            var kRq = ("rq" ++ zNum).asSymbol;
            var kAtk = ("atk" ++ zNum).asSymbol;
            var kDec = ("dec" ++ zNum).asSymbol;
            var kSus = ("sus" ++ zNum).asSymbol;
            var kRls = ("rls" ++ zNum).asSymbol;
            var kFx = zm[\fxKey];
            var pg, knobSpecs;

            tabBtns[idx] = Button(~mainWin, Rect(16 + (idx * 244), 12, 236, 32))
                .states_([[zm[\title], textCol, panelCol], [zm[\title], bgCol, accentCol]])
                .value_(if(idx == 0, 1, 0))
                .action_({
                    zoneMeta.size.do { |j|
                        pages[j].visible_(j == idx);
                        tabBtns[j].value_(if(j == idx, 1, 0));
                    };
                });

            pg = CompositeView(~mainWin, Rect(16, 54, 728, 490))
                .background_(panelCol)
                .visible_(idx == 0);
            pages[idx] = pg;

            StaticText(pg, Rect(16, 12, 400, 24))
                .string_(zm[\title] ++ " — Analog Matrix & Phosphor Scope")
                .stringColor_(accentCol);

            ~ui[kMute] = Button(pg, Rect(590, 12, 120, 26))
                .states_([["ACTIVE", bgCol, accentCol], ["MUTED", textCol, Color(0.65, 0.2, 0.2)]])
                .value_(~ccVals[kMute])
                .action_({ |b|
                    ~ccVals[kMute] = b.value;
                    ~buses[kMute].set(b.value);
                });

            EZSlider(pg, Rect(16, 48, 340, 24), "Min Note (CC" ++ ~cc[kMin] ++ ")",
                ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMin] = ez.value }, ~ccVals[kMin], labelWidth: 130)
                .setColors(stringColor: textCol, sliderBackground: bgCol, knobColor: accentCol)
                .do({ |ez| ~ui[kMin] = ez });

            EZSlider(pg, Rect(372, 48, 340, 24), "Max Note (CC" ++ ~cc[kMax] ++ ")",
                ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMax] = ez.value }, ~ccVals[kMax], labelWidth: 130)
                .setColors(stringColor: textCol, sliderBackground: bgCol, knobColor: accentCol)
                .do({ |ez| ~ui[kMax] = ez });

            knobSpecs = [
                [kVol, "Vol", ControlSpec(0, 1, \lin)],
                [kPan, "Pan", ControlSpec(-1, 1, \lin)],
                [kHpf, "HPF", ControlSpec(20, 12000, \exp)],
                [kLpf, "LPF", ControlSpec(20, 18000, \exp)],
                [kRq, "Resonance", ControlSpec(1.0, 0.05, \exp)],
                [kFx, zm[\fxLabel], ControlSpec(0, 1, \lin)],
                [kAtk, "Attack", ControlSpec(0.005, 5.0, \exp)],
                [kDec, "Decay", ControlSpec(0.005, 5.0, \exp)],
                [kSus, "Sustain", ControlSpec(0.005, 1.0, \lin)],
                [kRls, "Release", ControlSpec(0.005, 5.0, \exp)]
            ];

            knobSpecs.do { |sp, kIdx|
                var key = sp[0];
                var col = kIdx % 5;
                var row = (kIdx / 5).floor;
                var xPos = 24 + (col * 140);
                var yPos = 96 + (row * 130);
                ~ui[key] = EZKnob(pg, Rect(xPos, yPos, 110, 110),
                    sp[1] ++ " (CC" ++ ~cc[key] ++ ")",
                    sp[2],
                    { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) },
                    ~ccVals[key]
                ).setColors(stringColor: textCol, knobColors: [panelCol, accentCol, bgCol, textCol]);
            };
        };

        // Static Bottom Bar: Group FX + Panic
        EZSlider(~mainWin, Rect(16, 560, 280, 24), "Delay Mix (CC" ++ ~cc[\delMix] ++ ")",
            ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 130)
            .setColors(stringColor: textCol, sliderBackground: panelCol, knobColor: accentCol)
            .do({ |ez| ~ui[\delMix] = ez });

        EZSlider(~mainWin, Rect(16, 594, 280, 24), "Verb Mix (CC" ++ ~cc[\verbMix] ++ ")",
            ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 130)
            .setColors(stringColor: textCol, sliderBackground: panelCol, knobColor: accentCol)
            .do({ |ez| ~ui[\verbMix] = ez });

        Button(~mainWin, Rect(544, 564, 200, 48))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({ ~panicAll.value });

        ~mainWin.front;

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
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// 1. LAYER 1: Caixa & Tambor de Congada (Marching Drum & Snare)
Ndef(\caixaCongada).fadeTime = 2;
Ndef(\caixaCongada, { |freq=95, amp=0.26, pan=0, t_trig=1, snareMix=0.35, tone=1200|
    var env, pEnv, body, snare, sig;
    env = EnvGen.ar(Env.perc(0.003, 0.28, 1, -5), t_trig);
    pEnv = EnvGen.ar(Env.perc(0.001, 0.06, 1, -4), t_trig);
    body = SinOsc.ar(freq * (1 + (pEnv * 1.8))) * env;
    body = body + (SinOsc.ar(freq * 2) * env * 0.25);
    snare = BPF.ar(WhiteNoise.ar, tone, 0.45) * 4.0 * Decay2.ar(K2A.ar(t_trig), 0.002, 0.14);
    sig = (body + (snare * snareMix) * 1.6).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\caixaCongada)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.45, 0.5);
};
Ndef(\caixaCongada).set(\wet10, 0.22);

Pbindef(\seqCaixa,
    \t_trig, 1,
    \dur, Pwrand([0.25, 0.125, 0.5], [0.55, 0.35, 0.10], inf),
    \freq, Pseq([82, 95, 82, 110, 82, 95, 130, 95], inf),
    \snareMix, Pseq([0.15, 0.45, 0.2, 0.55, 0.15, 0.4, 0.5, 0.3], inf),
    \tone, Pwhite(1100, 1800, inf),
    \amp, Pseq([0.28, 0.16, 0.22, 0.25, 0.28, 0.14, 0.24, 0.18], inf)
);
Ndef(\caixaCongada).quant = 1;
Ndef(\caixaCongada)[1] = \set -> Pbindef(\seqCaixa);

// 2. LAYER 2: Gungas de Lata (Metallic Ankle Shakers & Cadenced Steps)
Ndef(\gungasLata).fadeTime = 2;
Ndef(\gungasLata, { |freq=1850, amp=0.18, pan=0, t_trig=1, decay=0.18|
    var trigA, exciter, freqs, amps, rings, sig;
    trigA = K2A.ar(t_trig);
    exciter = HPF.ar(WhiteNoise.ar, 2400) * Decay2.ar(trigA, 0.002, 0.045);
    exciter = exciter + (Impulse.ar(0) * 0.2);
    freqs = freq * [1.0, 1.47, 2.13, 2.89, 3.62];
    amps = [0.4, 0.35, 0.3, 0.2, 0.15];
    rings = [0.12, 0.09, 0.07, 0.05, 0.04];
    sig = DynKlank.ar(Ref([freqs, amps, rings]), exciter, decayscale: decay * 5);
    sig = HPF.ar(sig, 900) * 0.6;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    CombL.ar(in, 0.4, [0.125, 0.1875], 1.2);
};
Ndef(\gungasLata).set(\wet10, 0.18);

Pbindef(\seqGungas,
    \t_trig, 1,
    \dur, Pseq([0.25, 0.25, 0.125, 0.125, 0.25], inf),
    \freq, Pwrand([1650, 1850, 2100, 2400], [0.3, 0.35, 0.25, 0.1], inf),
    \decay, Pwhite(0.12, 0.24, inf),
    \pan, Pseq([-0.45, 0.45, -0.35, 0.5, 0.0], inf),
    \amp, Pseq([0.18, 0.14, 0.12, 0.16, 0.19], inf)
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\seqGungas);

// 3. LAYER 3: Canto do Rosário (Devotional Modal Voice & Horn-like Pad)
Ndef(\cantoRosario).fadeTime = 4;
Ndef(\cantoRosario, { |freq=293.66, amp=0.16, pan=0, t_trig=1, cutoff=1400|
    var env, vib, osc, filt, sig;
    env = EnvGen.ar(Env([0, 1, 0.75, 0], [0.08, 0.45, 0.65], -3), t_trig);
    vib = SinOsc.kr(4.8).range(0.994, 1.006);
    osc = Splay.ar(Saw.ar(freq * vib * [0.996, 1.0, 1.004]) + Pulse.ar(freq * 0.5, 0.4, 0.35));
    filt = MoogFF.ar(osc, (cutoff + (env * 900)).clip(80, 12000), 1.8) * 1.8;
    sig = filt * env;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.75, 0.35);
};
Ndef(\cantoRosario).set(\wet10, 0.42);

Pbindef(\seqCanto,
    \t_trig, 1,
    \dur, Pseq([1.0, 0.5, 0.5, 1.0, 1.0, Rest(1.0)], inf),
    \scale, Scale.mixolydian,
    \degree, Pseq([0, 2, 4, 3, 2, 0, 4, 5, 4, 2, 1, 0], inf),
    \octave, 4,
    \cutoff, Pwhite(1100, 2000, inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \amp, 0.16
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\seqCanto);
)

// --- Live-Coding Tweaks & Rollbacks ---
// Ndef(\caixaCongada).xset(\tone, 2200, \wet10, 0.35); // Brighter snare | Revert: Ndef(\caixaCongada).xset(\tone, 1300, \wet10, 0.22);
// Pbindef(\seqGungas, \dur, 0.125); // Double-time ankle gungas | Revert: Pbindef(\seqGungas, \dur, Pseq([0.25, 0.25, 0.125, 0.125, 0.25], inf));
// Pbindef(\seqCaixa).stop; Ndef(\caixaCongada).fadeTime = 4; Ndef(\caixaCongada).clear(4); // Rollback Caixa
// Pbindef(\seqGungas).stop; Ndef(\gungasLata).fadeTime = 4; Ndef(\gungasLata).clear(4); // Rollback Gungas
// Pbindef(\seqCanto).stop; Ndef(\cantoRosario).fadeTime = 4; Ndef(\cantoRosario).clear(4); // Rollback Canto

