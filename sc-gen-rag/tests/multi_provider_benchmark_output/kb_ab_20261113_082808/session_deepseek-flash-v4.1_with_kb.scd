// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-13T11:52:02.888495+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ============================================================
// "Vinte e Sete Anos" — O Mapa Dobrado no Restaurante
// Um silêncio com o peso de uma tempestade antártica
// ============================================================

// --- 1. MARRIAGE DRONE: vinte e sete anos de estabilidade paciente ---
// Dois saws levemente desafinados + sub-osc, filtro Moog ressonante
Ndef(\marriageDrone, { |freq=55, amp=0.22, cutoff=800, drift=0.015|
    var osc, sub, sig, lfo;
    lfo = SinOsc.kr(0.03).range(1 - drift, 1 + drift);
    osc = Splay.ar(Saw.ar(freq * [0.5, 0.997, 1.0, 1.003] * lfo));
    sub = SinOsc.ar(freq * 0.5, 0, 0.6);
    sig = Mix([osc * 0.5, sub * 0.4]);
    sig = MoogFF.ar(sig, cutoff, 2.5) * 3.0;
    sig = sig.tanh;
    sig * amp;
}).play;

Ndef(\marriageDrone)[10] = \filter -> { |in|
    GVerb.ar(Mix(in), 80, 8, 0.6, 0.5, 15, 0.5, 0.6, 0.5);
};
Ndef(\marriageDrone).set(\wet10, 0.35);

// --- 2. MAP FOLD: gestos geométricos precisos ao dobrar o mapa ---
// Excitação por ruído curto + Ringz, dobra via Fold.ar (Buchla)
Ndef(\mapFold, { |freq=800, amp=0.3, pan=0, t_trig=1, foldAmt=1.5, decay=0.15|
    var env, exciter, sig;
    env = EnvGen.ar(Env.perc(0.001, decay), t_trig);
    exciter = WhiteNoise.ar(0.6) * EnvGen.ar(Env.perc(0.0005, 0.004), t_trig);
    sig = Ringz.ar(exciter, freq, 0.08) + Ringz.ar(exciter, freq * 1.618, 0.05);
    sig = Fold.ar(sig * foldAmt, -0.7, 0.7);
    sig = RLPF.ar(sig, freq * 2.5, 0.3);
    Pan2.ar(sig * env * amp, pan);
}).play;

// --- 3. GLASS SUSPENDED: o garçom imóvel com a garrafa no ar ---
// Síntese aditiva com batimento sutil (três parciais levemente desafinadas)
Ndef(\glassSuspended, { |freq=1200, amp=0.2, pan=0, t_trig=1, rel=6|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.01, rel, 1, -4), t_trig);
    sig = SinOsc.ar([freq, freq * 1.004, freq * 2.01]) * [1, 0.7, 0.3];
    sig = Splay.ar(sig);
    sig = sig * env * amp;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) };
}).play;

// --- 4. ANTARCTIC WIND: a tempestade prestes a desabar ---
// Pink + Brown noise por BPF ressonante com LFO, mais um LPF que dá corpo
Ndef(\antarcticWind, { |amp=0.15, cutoff=400, rq=0.05, rate=0.08|
    var noise, sig, lfo;
    noise = PinkNoise.ar(0.5) + BrownNoise.ar(0.3);
    lfo = LFNoise1.kr(rate).range(0.5, 1.5);
    sig = BPF.ar(noise, cutoff * lfo, rq) * 15;
    sig = sig + (LPF.ar(noise, cutoff * 0.5) * 0.4);
    sig * amp;
}).play;

Ndef(\antarcticWind)[10] = \filter -> { |in|
    GVerb.ar(Mix(in), 200, 12, 0.9, 0.5, 20, 0.5, 0.7, 0.5);
};
Ndef(\antarcticWind).set(\wet10, 0.5);

// ============================================================
// SEQUENCES
// ============================================================

// Dobrar o mapa: ritmo preciso, quase didático, com pausas de silêncio
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.125, 0.25, 0.125, 0.5, 0.25, 0.125, 0.125, 0.375], inf),
    \freq, Pseq([600, 900, 750, 1200, 800, 500, 950, 700], inf),
    \foldAmt, Pwhite(1.0, 2.5, inf),
    \decay, Pwhite(0.08, 0.25, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pwhite(0.15, 0.35, inf),
    \t_trig, 1
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// Os sinos suspensos: esparsos, longos, quase congelados
Pbindef(\glassSeq,
    \dur, Pseq([4, 6, 3, 8, 5], inf),
    \freq, Pseq([1200, 1600, 900, 1800, 1350], inf),
    \rel, Pwhite(4, 9, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pwhite(0.12, 0.22, inf),
    \t_trig, 1
);
Ndef(\glassSuspended)[1] = \set -> Pbindef(\glassSeq);

// ============================================================
// ROLLBACK (para desfazer toda a adição se o som for inutilizável)
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\glassSeq).stop; Ndef(\glassSuspended).fadeTime = 2; Ndef(\glassSuspended).clear(2);
// Ndef(\marriageDrone).fadeTime = 3; Ndef(\marriageDrone).clear(3);
// Ndef(\antarcticWind).fadeTime = 3; Ndef(\antarcticWind).clear(3);
// ============================================================
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Instruments
    SynthDef(\brassTick, { |out=0, freq=1200, amp=0.1, pan=0, decay=0.08|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.0005, decay, 1, -6), doneAction: 2);
        exc = WhiteNoise.ar(0.5) + Impulse.ar(0);
        sig = Ringz.ar(exc, freq, decay) + Ringz.ar(exc, freq * 2.71, decay * 0.5);
        sig = HPF.ar(sig, 400);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\carillonBell, { |out=0, freq=440, amp=0.2, pan=0, decay=4|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        mod = SinOsc.ar(freq * 2.76) * freq * 1.5 * env;
        sig = SinOsc.ar(freq + mod);
        sig = sig + SinOsc.ar(freq * 1.003, 0, 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\pendulumThud, { |out=0, freq=60, amp=0.3, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.005, 0.6, 1, -4), doneAction: 2);
        sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2, 0, 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\brassSwarm, { |density=12, amp=0|
        var trigs, env, freqs, sig;
        trigs = Dust.ar(density);
        env = Decay2.ar(trigs, 0.0005, 0.02);
        freqs = TExpRand.ar(1500, 5000, trigs);
        sig = Ringz.ar(Impulse.ar(0) + WhiteNoise.ar(0.4), freqs, 0.015);
        sig = HPF.ar(sig, 600);
        Pan2.ar(sig * env * amp, TRand.ar(-0.9, 0.9, trigs));
    });

    Ndef(\timeBreath, { |freq=55, amp=0, breathRate=0.15|
        var lfo, osc, sig;
        lfo = SinOsc.kr(breathRate).range(0.3, 1.0);
        osc = Splay.ar(SinOsc.ar(freq * [1, 1.002, 1.005, 0.998, 2, 3]));
        sig = MoogFF.ar(osc, 200 + (lfo * 800), 2.0) * 3;
        sig = sig.tanh;
        sig * amp * lfo;
    });

    Ndef(\carillonDrone, { |amp=0, freq=220|
        var sig;
        sig = SinOsc.ar(freq * [1, 2.76, 5.4, 8.93]) * [1, 0.5, 0.3, 0.15];
        sig = Splay.ar(sig);
        sig = sig * SinOsc.kr(0.07).range(0.5, 1.0);
        sig * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\brassSwarm, 2) + Ndef.ar(\timeBreath, 2) + Ndef.ar(\carillonDrone, 2);
        synths + cont;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, \revTime.kr(0.85), 0.3);
    };
    Ndef(\masterMix).set(\wet10, 0.3);
    Ndef(\masterMix).play;
    s.sync;

    // Sequences
    Pbindef(\brassTickSeq,
        \instrument, \brassTick,
        \out, ~synthBus,
        \dur, Pwhite(0.05, 0.4),
        \freq, Pwhite(800, 3500),
        \decay, Pwhite(0.02, 0.15),
        \pan, Pwhite(-0.9, 0.9),
        \amp, Pwhite(0.04, 0.12)
    ).play;

    Pbindef(\carillonSeq,
        \instrument, \carillonBell,
        \out, ~synthBus,
        \dur, Pseq([2.5, 4.2, 3.1, 5.5], inf),
        \freq, Pseq([440, 523, 392, 587], inf),
        \decay, Pwhite(3, 7),
        \pan, Pwhite(-0.5, 0.5),
        \amp, Pwhite(0.08, 0.18)
    ).play;

    Pbindef(\pendulumSeq,
        \instrument, \pendulumThud,
        \out, ~synthBus,
        \dur, Pseq([1.02, 0.98, 1.03, 0.97], inf),
        \freq, Pseq([55, 58, 52, 60], inf),
        \pan, Pwhite(-0.4, 0.4),
        \amp, Pwhite(0.15, 0.28)
    ).play;

    // Score
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Estreita da Ladeira]".postln;
        Ndef(\brassSwarm).fadeTime = 6;
        Ndef(\brassSwarm).xset(\amp, 0.35, \density, 12);
        Ndef(\masterMix).set(\wet10, 0.35, \revTime, 0.7);

        22.do { |i|
            Ndef(\brassSwarm).xset(\density, 12 + (i * 0.8));
            if (0.3.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(900, 3000), \pan, rrand(-0.9, 0.9), \amp, rrand(0.05, 0.15), \decay, rrand(0.02, 0.1)]);
            };
            1.wait;
        };

        "0:22 - [Cue 2: Pêndulos e Carrilhões Franceses]".postln;
        Ndef(\carillonDrone).fadeTime = 8;
        Ndef(\carillonDrone).xset(\amp, 0.12, \freq, 220);
        Ndef(\masterMix).set(\wet10, 0.45, \revTime, 0.9);

        26.do { |i|
            Ndef(\carillonDrone).xset(\freq, 220 * (1 + (i * 0.002)));
            if (0.25.coin) {
                Synth(\carillonBell, [\out, ~synthBus, \freq, [392, 440, 523, 587].choose, \pan, rrand(-0.6, 0.6), \amp, rrand(0.06, 0.14), \decay, rrand(3, 6)]);
            };
            1.wait;
        };

        "0:48 - [Cue 3: O Relojoeiro Fecha os Olhos]".postln;
        Ndef(\brassSwarm).fadeTime = 6;
        Ndef(\brassSwarm).xset(\amp, 0.15, \density, 6);
        Ndef(\timeBreath).fadeTime = 10;
        Ndef(\timeBreath).xset(\amp, 0.4, \freq, 55, \breathRate, 0.12);
        Ndef(\masterMix).set(\wet10, 0.55, \revTime, 1.0);

        22.do { |i|
            Ndef(\timeBreath).xset(\breathRate, 0.10 + (i * 0.008));
            if (0.2.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(600, 1800), \pan, rrand(-0.7, 0.7), \amp, rrand(0.03, 0.08), \decay, rrand(0.05, 0.2)]);
            };
            1.wait;
        };

        "1:10 - [Cue 4: Defasagens Microscópicas]".postln;
        Ndef(\timeBreath).xset(\freq, 55, \breathRate, 0.25);
        Ndef(\carillonDrone).xset(\freq, 220);
        Ndef(\brassSwarm).xset(\amp, 0.4, \density, 30);
        Ndef(\masterMix).set(\wet10, 0.5, \revTime, 0.95);

        28.do { |i|
            Ndef(\timeBreath).xset(\freq, 55 * (1 + (i * 0.0015)));
            Ndef(\carillonDrone).xset(\freq, 220 * (1 - (i * 0.001)));
            if (0.35.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(1200, 5000), \pan, rrand(-0.9, 0.9), \amp, rrand(0.04, 0.12), \decay, rrand(0.02, 0.08)]);
            };
            1.wait;
        };

        "1:38 - [Cue 5: O Respirar do Tempo]".postln;
        Ndef(\brassSwarm).fadeTime = 8;
        Ndef(\brassSwarm).xset(\amp, 0.08, \density, 5);
        Ndef(\carillonDrone).fadeTime = 10;
        Ndef(\carillonDrone).xset(\amp, 0.06, \freq, 110);
        Ndef(\timeBreath).fadeTime = 8;
        Ndef(\timeBreath).xset(\amp, 0.5, \freq, 55, \breathRate, 0.08);
        Ndef(\masterMix).set(\wet10, 0.7, \revTime, 1.0);

        20.do { |i|
            Ndef(\timeBreath).xset(\breathRate, 0.08 - (i * 0.002));
            1.wait;
        };

        "1:58 - [Terminating]".postln;
        Pbindef(\brassTickSeq).stop; Pbindef(\brassTickSeq).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
        Pbindef(\pendulumSeq).stop; Pbindef(\pendulumSeq).clear;

        Ndef(\brassSwarm).clear(3);
        Ndef(\timeBreath).clear(3);
        Ndef(\carillonDrone).clear(3);
        Ndef(\masterMix).clear(3);

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
    |freq=98.0, detune=0.0246, sawMix=0.36, pulseMix=0.64,
     pw=0.76, pwmRate=0.96, pwmDepth=0.21,
     subAmp=0.27, noiseAmp=0.043,
     cutoff=3013.4, rq=0.52, hpf=119.7,
     filtEnvAmt=1205.5, lfoRate=2.19, lfoDepth=489.0,
     atk=0.108, dec=0.61, sus=0.69, rls=0.41,
     pan=(-0.15), amp=0.35, t_trig=1|
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
    CombL.ar(in, 0.5, 0.25, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.12);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.53, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.2);

Pbindef(\subtractiveDesignSeq,
    \dur, Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf),
    \freq, (98.0 * (2 ** (Prand([0, 2, 3, 7, 8], inf) / 12))),
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
// Congada procession: tin gungas, atabaque pulse, harmonic terno bed
Ndef(\congadaTerno).fadeTime = 3;
Ndef(\congadaTerno, { |root=55, cutoff=880, amp=0.11, spread=0.7, bright=0.35|
    var freqs, sig, mono, form, sub, lfo;
    freqs = root * [1, 1.005, 1.5, 2.0, 2.01, 3.0];
    sig = Splay.ar(Saw.ar(freqs, 0.06), spread);
    lfo = SinOsc.kr(0.07).range(120, 520);
    sig = MoogFF.ar(sig, (cutoff + lfo).clip(80, 6000), 2.4);
    sig = (sig * 2.2).tanh;
    mono = sig.sum;
    form = BPF.ar(mono, [520, 940, 2300], 0.16).sum * 9.0;
    sig = sig + Pan2.ar(form * 0.35, SinOsc.kr(0.05));
    sub = SinOsc.ar(root * 0.5, 0, 0.08);
    sig = sig + Pan2.ar(sub, 0);
    sig = LPF.ar(sig, 1800 + (bright * 1200));
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp) } { Pan2.ar(sig, 0, amp) };
}).play;
Ndef(\congadaTerno)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.78, 0.55) };
Ndef(\congadaTerno).set(\wet10, 0.18);

Ndef(\congadaGungas).fadeTime = 1.2;
Ndef(\congadaGungas, { |t_trig=1, freq=2400, amp=0.16, pan=0, decay=0.08|
    var trig, env, exc, ring, sig, hiss;
    trig = K2A.ar(t_trig);
    env = Decay2.ar(trig, 0.001, decay);
    exc = (WhiteNoise.ar(0.75) + PinkNoise.ar(0.35)) * env;
    ring = Ringz.ar(exc, freq * [1, 1.47, 2.09, 2.73, 3.41], decay * [1.4, 1.15, 0.9, 0.7, 0.55], 0.28);
    ring = HPF.ar(ring, 900);
    sig = Splay.ar(ring, 0.9);
    hiss = BPF.ar(WhiteNoise.ar(0.25) * env, (freq * 4).clip(1200, 12000), 0.13) * 11.0;
    sig = sig + Pan2.ar(hiss, pan);
    sig = (sig * 1.4).tanh;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;
Ndef(\congadaGungas)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.62, 0.45) };
Ndef(\congadaGungas).set(\wet10, 0.24);
Ndef(\congadaGungas)[11] = \filter -> { |in| var d; d = CombC.ar(in, 0.35, [0.16, 0.23], 2.2); d };
Ndef(\congadaGungas).set(\wet11, 0.16);

Ndef(\congadaTambor).fadeTime = 1.5;
Ndef(\congadaTambor, { |t_trig=1, freq=85, amp=0.2, pan=0, decay=0.35|
    var trig, env, pitchEnv, body, slap, sig;
    trig = K2A.ar(t_trig);
    env = Decay2.ar(trig, 0.002, decay);
    pitchEnv = 1 + (Decay2.ar(trig, 0.001, 0.06) * 1.7);
    body = SinOsc.ar(freq * pitchEnv, 0, 0.75) * env;
    body = body + (SinOsc.ar(freq * 2.01, 0, 0.14) * env);
    slap = BPF.ar(WhiteNoise.ar(0.55) * Decay2.ar(trig, 0.001, 0.045), 1500, 0.65) * 0.9;
    sig = LPF.ar(body + slap, 900 + (env * 1200));
    sig = (sig * 1.3).tanh;
    Pan2.ar(sig, pan, amp);
}).play;
Ndef(\congadaTambor)[10] = \filter -> { |in| GVerb.ar(in.sum, 22, 1.8, 0.55, 0.7, 15, 0, 0.35, 0.4) };
Ndef(\congadaTambor).set(\wet10, 0.14);

Ndef(\congadaTambor).quant = 1;
Pbindef(\congadaTamborSeq,
    \t_trig, 1,
    \dur, Pseq([0.375, 0.1875, 0.1875, 0.25, 0.5, 0.1875, 0.1875, 0.375], inf),
    \freq, Pseq([85, 85, 94, 78, 105, 85, 70, 94], inf),
    \decay, Pwhite(0.18, 0.45, inf),
    \amp, Pseq([0.22, 0.15, 0.18, 0.25, 0.19, 0.16, 0.24, 0.17], inf),
    \pan, Pwhite(-0.35, 0.35, inf)
);
Ndef(\congadaTambor)[1] = \set -> Pbindef(\congadaTamborSeq);

Ndef(\congadaGungas).quant = 1;
Pbindef(\congadaGungasSeq,
    \t_trig, 1,
    \dur, Pwrand([0.125, 0.1875, 0.25, 0.375, Rest(0.25)], [0.4, 0.15, 0.28, 0.12, 0.05], inf),
    \freq, Pexprand(1500, 4300, inf),
    \decay, Pexprand(0.025, 0.12, inf),
    \amp, Pwrand([0.1, 0.16, 0.22], [0.5, 0.35, 0.15], inf),
    \pan, Pwhite(-0.85, 0.85, inf)
);
Ndef(\congadaGungas)[1] = \set -> Pbindef(\congadaGungasSeq);
)

// Ndef(\congadaTerno).xset(\cutoff, 1500); // Brighten terno | Revert: Ndef(\congadaTerno).xset(\cutoff, 880);
// Pbindef(\congadaGungasSeq, \dur, Pwrand([0.0625, 0.125, 0.25], [0.45, 0.4, 0.15], inf)); // Double-time gungas | Revert: Pbindef(\congadaGungasSeq, \dur, Pwrand([0.125, 0.1875, 0.25, 0.375, Rest(0.25)], [0.4, 0.15, 0.28, 0.12, 0.05], inf));
// Ndef(\congadaGungas).xset(\wet11, 0.28); // More tin slapback | Revert: Ndef(\congadaGungas).xset(\wet11, 0.16);
// Ndef(\congadaTambor).fadeTime = 4; Ndef(\congadaTambor).clear(4); // Rollback tambor
// Ndef(\congadaGungas).fadeTime = 4; Ndef(\congadaGungas).clear(4); // Rollback gungas
// Ndef(\congadaTerno).fadeTime = 4; Ndef(\congadaTerno).clear(4); // Rollback terno

