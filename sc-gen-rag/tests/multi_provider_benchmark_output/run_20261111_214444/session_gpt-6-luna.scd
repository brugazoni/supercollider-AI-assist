// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-12T02:38:53.071222+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\foldedMap, { |freq=180, amp=0.12, pan=(-0.35), t_trig=0, brightness=900|
    var env = EnvGen.kr(Env.perc(0.002, 0.22), t_trig);
    var click = Decay2.ar(K2A.ar(t_trig), 0.001, 0.025) * WhiteNoise.ar;
    var tone = SinOsc.ar(freq) + (Pulse.ar(freq * 0.5, 0.18) * 0.22);
    var sig = (BPF.ar(click, brightness, 0.16) * 3) + (tone * env);
    Pan2.ar(LPF.ar(sig, brightness * 2) * amp, pan);
}).play;

Pbindef(\foldedMapSeq,
    \dur, Pseq([0.75, 0.25, 1.25, 0.5, 0.5, 2], inf),
    \freq, Pseq([196, 207.65, 174.61, 220, 185, 164.81], inf),
    \brightness, Pseq([1200, 700, 1600, 620, 1100, 500], inf),
    \amp, Pwhite(0.07, 0.14, inf),
    \pan, Pseq([-0.4, 0.25, -0.2, 0.35], inf),
    \t_trig, 1
);
Ndef(\foldedMap)[1] = \set -> Pbindef(\foldedMapSeq);
// Rollback: Pbindef(\foldedMapSeq).stop; Ndef(\foldedMap).fadeTime = 2; Ndef(\foldedMap).clear(2); // remove the map-fold instrument

Ndef(\suspendedWine, { |freq=659.25, amp=0.07, pan=0.45, t_trig=0, ring=4|
    var exc = Decay2.ar(K2A.ar(t_trig), 0.003, 0.12) * WhiteNoise.ar(0.35);
    var glass = Ringz.ar(exc, [freq, freq * 1.497, freq * 2.01], ring).sum;
    Pan2.ar(glass * amp, pan);
}).play;

Pbindef(\suspendedWineSeq,
    \dur, Pseq([3, 2.5, 4, 3.5], inf),
    \freq, Pseq([659.25, 622.25, 587.33, 554.37, 622.25], inf),
    \ring, Pseq([4.5, 5.5, 6, 7], inf),
    \amp, Pseq([0.045, 0.06, 0.05, 0.07], inf),
    \pan, Pseq([0.45, 0.25, 0.5, 0.32], inf),
    \t_trig, 1
);
Ndef(\suspendedWine)[1] = \set -> Pbindef(\suspendedWineSeq);
// Rollback: Pbindef(\suspendedWineSeq).stop; Ndef(\suspendedWine).fadeTime = 2; Ndef(\suspendedWine).clear(2); // remove the suspended-wine instrument

Ndef(\polarSilence, { |freq=55, amp=0.075, pan=0, t_trig=0, pressure=0.2|
    var drift = SinOsc.kr(0.035).range(0.985, 1.015);
    var breath = SinOsc.kr(0.11).range(0.75, 1);
    var sub = SinOsc.ar(freq * drift) * 0.65;
    var upper = SinOsc.ar(freq * 2 * drift, SinOsc.kr(0.07) * pressure) * 0.35;
    var grit = LPF.ar(PinkNoise.ar(0.08), 180 + (SinOsc.kr(0.08).range(0, 130)));
    var sig = (sub + upper + grit) * breath;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\polarSilenceSeq,
    \dur, Pseq([6, 5, 7, 4], inf),
    \freq, Pseq([55, 55, 51.91, 55, 58.27], inf),
    \pressure, Pseq([0.12, 0.2, 0.32, 0.48], inf),
    \amp, Pseq([0.07, 0.075, 0.08, 0.09], inf),
    \pan, Pseq([0, -0.08, 0.08, 0], inf),
    \t_trig, 1
);
Ndef(\polarSilence)[1] = \set -> Pbindef(\polarSilenceSeq);
// Rollback: Pbindef(\polarSilenceSeq).stop; Ndef(\polarSilence).fadeTime = 2; Ndef(\polarSilence).clear(2); // remove the polar-silence instrument

// Settling: blur the map's tiny gestures into the accumulating silence; initially bypassed.
Ndef(\foldedMap)[10] = \filter -> { |in|
    CombC.ar(in, 0.45, SinOsc.kr(0.07).range(0.08, 0.31), 1.8)
};
Ndef(\foldedMap).set(\wet10, 0);
// Rollback: Ndef(\foldedMap).set(\wet10, 0); // disable the blurring effect

// Settling: let the wine-glass tones hang as if the waiter has stopped mid-pour; initially bypassed.
Ndef(\suspendedWine)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 0.85, 0.95, 0.65)
};
Ndef(\suspendedWine).set(\wet10, 0);
// Rollback: Ndef(\suspendedWine).set(\wet10, 0); // disable the suspended-glass effect

// Settling: soften the approaching storm into a distant, cold haze; initially bypassed.
Ndef(\polarSilence)[10] = \filter -> { |in|
    LPF.ar(FreeVerb2.ar(in[0], in[1], 0.75, 0.9, 0.45), 1400)
};
Ndef(\polarSilence).set(\wet10, 0);
// Rollback: Ndef(\polarSilence).set(\wet10, 0); // disable the polar haze
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

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\brassTick, { |out=0, freq=900, amp=0.1, pan=0, decay=0.12, tone=0.4|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var strike = Decay2.ar(Impulse.ar(0), 0.001, 0.018) * WhiteNoise.ar;
        var body = Ringz.ar(strike, [freq, freq * 1.51, freq * 2.37], [decay, decay * 0.7, decay * 0.45]).sum;
        var click = BPF.ar(strike, freq * 1.7, 0.3) * 2;
        var sig = (body * tone) + (click * (1 - tone));
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\clockChime, { |out=0, freq=660, amp=0.08, pan=0, dur=1.2|
        var env = EnvGen.ar(Env.perc(0.004, dur), doneAction: 2);
        var exc = Decay2.ar(Impulse.ar(0), 0.002, 0.06) * WhiteNoise.ar(0.45);
        var modes = Ringz.ar(exc, [freq, freq * 1.496, freq * 2.03, freq * 2.71], [2.4, 1.8, 1.2, 0.7]).sum;
        Out.ar(out, Pan2.ar(modes * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\escapementAir, { |amp=0, drift=0.006, cutoff=2400|
        var phase = SinOsc.kr([0.31, 0.317]).range(0, 1);
        var tick = Impulse.ar([1.997, 2.013] * (1 + (SinOsc.kr(0.023) * drift)));
        var noise = Decay2.ar(tick, 0.001, 0.035) * WhiteNoise.ar(0.3);
        var tooth = SinOsc.ar([1160, 1217] * (1 + (phase * drift))) * Decay2.ar(tick, 0.001, 0.09);
        var sig = [noise[0] + tooth[0], noise[1] + tooth[1]];
        LPF.ar(sig, cutoff) * amp;
    });
    Ndef(\breathOfTime, { |amp=0, freq=55, swell=0.1|
        var slow = SinOsc.kr(0.071).range(0.72, 1);
        var sub = SinOsc.ar(freq * [1, 1.006]) * 0.2;
        var harmonics = SinOsc.ar(freq * [2.01, 2.04]) * 0.07;
        var air = BPF.ar(PinkNoise.ar([0.035, 0.03]), [180, 193], 0.65);
        (sub + harmonics + air) * slow * (1 + (SinOsc.kr(0.13) * swell)) * amp;
    });
    Ndef(\escapementAir).fadeTime = 2;
    Ndef(\breathOfTime).fadeTime = 4;

    Ndef(\masterMix, {
        var bus = In.ar(~synthBus, 2);
        var air = Ndef(\escapementAir).ar;
        var breath = Ndef(\breathOfTime).ar;
        LeakDC.ar(bus + air + breath);
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 0.82, 0.86, 0.22)
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        Limiter.ar(in, 0.82, 0.02)
    };
    Ndef(\masterMix).set(\wet10, 0.18, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\atelierTicks,
        \instrument, \brassTick,
        \out, ~synthBus,
        \dur, Pseq([0.5, 0.5, 0.25, 0.75, 0.5, 1], inf),
        \freq, Pseq([1080, 920, 1120, 840, 980, 760, 1260], inf),
        \decay, Pseq([0.08, 0.11, 0.07, 0.14], inf),
        \tone, Pwhite(0.25, 0.75, inf),
        \amp, Pwhite(0.035, 0.065, inf),
        \pan, Pwhite(-0.9, 0.9, inf)
    );

    Pbindef(\frenchChime,
        \instrument, \clockChime,
        \out, ~synthBus,
        \dur, Pseq([3, 2.5, 4, 3.5], inf),
        \freq, Pseq([659.25, 622.25, 587.33, 554.37, 622.25], inf),
        \dur, Pkey(\dur),
        \amp, Pseq([0.035, 0.05, 0.04, 0.055], inf),
        \pan, Pseq([-0.62, 0.48, -0.25, 0.7, 0.1], inf)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - A oficina desperta: duzentos balanços quase coincidentes.".postln;
        Ndef(\escapementAir).xset(\amp, 0.16, \drift, 0.004, \cutoff, 2800);
        Pbindef(\atelierTicks).play;
        5.do { |i|
            Ndef(\escapementAir).xset(\drift, 0.002 + (i * 0.0018), \cutoff, 1800 + (i * 420));
            2.wait;
        };

        "0:10 - O latão se separa em pequenos campos de pulsação.".postln;
        Ndef(\breathOfTime).xset(\amp, 0.22, \freq, 55, \swell, 0.18);
        Pbindef(\frenchChime).play;
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.15 + (i * 0.08));
            Ndef(\escapementAir).xset(\drift, 0.012 + (i * 0.009));
            2.wait;
        };

        "0:18 - Defasagem extrema: cada escape roça o limite da síncope.".postln;
        3.do { |i|
            Ndef(\escapementAir).xset(\drift, 0.055 + (i * 0.025), \cutoff, 3300 + (i * 500));
            Ndef(\breathOfTime).xset(\swell, 0.35 + (i * 0.18));
            2.wait;
        };

        "0:24 - Flashback: restam o sopro e um carrilhão distante.".postln;
        Pbindef(\atelierTicks).stop;
        Ndef(\escapementAir).xset(\amp, 0.035, \drift, 0.003, \cutoff, 1300);
        Ndef(\breathOfTime).xset(\amp, 0.14, \swell, 0.06);
        Ndef(\masterMix).set(\wet10, 0.42);
        4.wait;

        "0:28 - O relojoeiro fecha os olhos; os pêndulos reencontram o centro.".postln;
        Ndef(\escapementAir).xset(\amp, 0.12, \drift, 0.004, \cutoff, 2200);
        Ndef(\breathOfTime).xset(\amp, 0.1, \freq, 55, \swell, 0.08);
        Pbindef(\atelierTicks).play;
        3.do { |i|
            Ndef(\masterMix).set(\wet10, 0.32 - (i * 0.1));
            2.wait;
        };

        "0:34 - Corte: o último tique cai no silêncio.".postln;
        Pbindef(\atelierTicks).stop;
        Pbindef(\atelierTicks).clear;
        Pbindef(\frenchChime).stop;
        Pbindef(\frenchChime).clear;
        Ndef(\escapementAir).clear(2);
        Ndef(\breathOfTime).clear(3);
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #139
// STATUS: FALLBACK
// PROMPT: olho do alto do morro e vejo a cidade estendida como um couro de boi secando ao sol do meio-dia. car...
// ============================================================
(
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\subtractiveDesign).fadeTime = 1.5;
Ndef(\subtractiveDesign, {
    |freq=55.0, detune=0.0218, sawMix=0.59, pulseMix=0.41,
     pw=0.38, pwmRate=1.27, pwmDepth=0.1,
     subAmp=0.12, noiseAmp=0.051,
     cutoff=1246.1, rq=0.44, hpf=154.4,
     filtEnvAmt=4770.0, lfoRate=1.08, lfoDepth=755.8,
     atk=0.055, dec=0.46, sus=0.6, rls=1.2,
     pan=(-0.31), amp=0.28, t_trig=1|
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
    CombL.ar(in, 0.5, 0.1875, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.2);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.68, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.43);

Pbindef(\subtractiveDesignSeq,
    \dur, Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf),
    \freq, (55.0 * (2 ** (Prand([0, 3, 5, 7, 10], inf) / 12))),
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
// Congada: passo cadenciado, gungas metálicas e canto de procissão.
Ndef(\congadaBed).fadeTime = 4;
Ndef(\congadaBed, {
    |freq=55, amp=0.12, pan=0, t_trig=1|
    var slow, pulse, sub, harmonics, sig;
    slow = SinOsc.kr(0.035).range(0.92, 1.08);
    pulse = Decay2.ar(K2A.ar(t_trig), 0.08, 1.8);
    sub = SinOsc.ar(freq * slow) * 0.65;
    harmonics = SinOsc.ar(freq * [2, 3, 4], 0, [0.22, 0.12, 0.06]).sum;
    sig = (sub + harmonics) * (0.45 + (pulse * 0.2));
    Pan2.ar(sig, pan, amp);
}).play;
Ndef(\congadaBed)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.55, 0.22);
};
Ndef(\congadaBed).set(\wet10, 0.28);

Pbindef(\congadaBedSeq,
    \dur, Pwrand([0.5, 1, 2], [0.5, 0.35, 0.15], inf),
    \freq, Pseq([55, 55, 65.41, 73.42], inf),
    \t_trig, 1
);
Ndef(\congadaBed).quant = 1;
Ndef(\congadaBed)[1] = \set -> Pbindef(\congadaBedSeq);

// Gungas: metallic ankle bells answering the steady procession.
Ndef(\congadaGungas).fadeTime = 0.8;
Ndef(\congadaGungas, {
    |freq=880, amp=0.17, pan=0, t_trig=1|
    var hit, rattle, modes, tone, sig;
    hit = Decay2.ar(K2A.ar(t_trig), 0.002, 0.16);
    rattle = Dust.ar(18) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.22);
    modes = SinOsc.ar(freq * [1, 1.47, 2.31, 3.76], 0, [0.45, 0.24, 0.16, 0.08]).sum;
    tone = Ringz.ar(WhiteNoise.ar * hit, freq * [1, 1.47, 2.31], [0.14, 0.2, 0.11], [0.4, 0.24, 0.16]).sum;
    sig = ((modes * hit) + (tone * 0.55) + (rattle * 0.08)).tanh;
    Pan2.ar(sig, pan, amp);
}).play;
Ndef(\congadaGungas)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.42, 0.2);
};
Ndef(\congadaGungas).set(\wet10, 0.22);

Pbindef(\congadaGungasSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.35, 0.1], inf),
    \freq, Pseq([784, 880, 988, 880, 659, 784, 880, 1175], inf),
    \pan, Pwhite(-0.65, 0.65, inf),
    \t_trig, 1
);
Ndef(\congadaGungas).quant = 1;
Ndef(\congadaGungas)[1] = \set -> Pbindef(\congadaGungasSeq);

// Moçambique pulse: low drum strokes and a bright, restrained answering voice.
Ndef(\congadaPulse).fadeTime = 1.2;
Ndef(\congadaPulse, {
    |freq=196, amp=0.16, pan=0, t_trig=1|
    var env, thump, click, body, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.004, 0.28);
    thump = SinOsc.ar(freq * (1 + (env * 1.8))) * env;
    click = BPF.ar(WhiteNoise.ar * env, 2400, 0.7) * 0.35;
    body = SinOsc.ar(freq * [1, 2.02], 0, [0.32, 0.1]).sum * env;
    sig = (thump * 0.55) + (click * 0.18) + body;
    Pan2.ar(sig, pan, amp);
}).play;
Ndef(\congadaPulse)[10] = \filter -> { |in|
    CombL.ar(in, 0.3, 0.1875, 0.7);
};
Ndef(\congadaPulse).set(\wet10, 0.13);
Ndef(\congadaPulse)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.5, 0.18);
};
Ndef(\congadaPulse).set(\wet11, 0.18);

Pbindef(\congadaPulseSeq,
    \dur, Pwrand([0.5, 0.25, 0.75, 1], [0.45, 0.25, 0.2, 0.1], inf),
    \freq, Pseq([146.83, 196, 220, 196, 164.81, 196], inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \t_trig, 1
);
Ndef(\congadaPulse).quant = 1;
Ndef(\congadaPulse)[1] = \set -> Pbindef(\congadaPulseSeq);

// Live tweaks and rollbacks:
// Ndef(\congadaBed).xset(\amp, 0.16); // Fuller bed | Revert: Ndef(\congadaBed).xset(\amp, 0.12);
// Pbindef(\congadaGungasSeq, \dur, 0.25); // Tighter bells | Revert: Pbindef(\congadaGungasSeq, \dur, 0.5);
// Pbindef(\congadaBedSeq).stop; Ndef(\congadaBed).fadeTime = 4; Ndef(\congadaBed).clear(4); // Rollback
// Pbindef(\congadaGungasSeq).stop; Ndef(\congadaGungas).fadeTime = 4; Ndef(\congadaGungas).clear(4); // Rollback
// Pbindef(\congadaPulseSeq).stop; Ndef(\congadaPulse).fadeTime = 4; Ndef(\congadaPulse).clear(4); // Rollback
)


// ============================================================
// ROUND 05 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
 // Novo estrato: ferro que tinine sobre um lamento suspenso; tensão espectral sem imitar vozes humanas.
Ndef(\chainLament).fadeTime = 3;
Ndef(\chainLament, {
    |freq=110, amp=0.12, pan=0, t_trig=1, metal=1|
    var hit, clang, breath, drone, sig;
    hit = Decay2.ar(K2A.ar(t_trig), 0.003, 0.7);
    clang = Ringz.ar(
        WhiteNoise.ar * hit,
        freq * [1, 1.414, 2.37, 3.91],
        [0.32, 0.48, 0.22, 0.16],
        [0.35, 0.22, 0.12, 0.08]
    ).sum * metal;
    breath = BPF.ar(PinkNoise.ar, freq * 5, 0.18) * 0.035;
    drone = SinOsc.ar(freq * [1, 1.503], 0, [0.08, 0.035]).sum;
    sig = (clang + (breath * hit) + (drone * (0.18 + (hit * 0.22)))).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\chainLamentSeq,
    \dur, Pseq([1.5, 0.5, 1, 2, 0.5, 1.5], inf),
    \freq, Pseq([110, 116.54, 103.83, 123.47, 98, 110], inf),
    \metal, Pseq([1, 0.35, 0.8, 0.25, 0.65, 1], inf),
    \pan, Pwhite(-0.55, 0.55, inf),
    \amp, Pseq([0.12, 0.07, 0.1, 0.06, 0.09, 0.12], inf),
    \t_trig, 1
);
Ndef(\chainLament).quant = 1;
Ndef(\chainLament)[1] = \set -> Pbindef(\chainLamentSeq);

// Flashback/settling: sparse, lengthening gaps let the metallic resonance hang in the air.
// Pbindef(\chainLamentSeq, \dur, Pseq([1.5, 0.5, 1, 2, 0.5, 1.5], inf)); // Revert sequence
// Pbindef(\chainLamentSeq).stop; Ndef(\chainLament).fadeTime = 3; Ndef(\chainLament).clear(3); // Rollback: remove this instrument
)


// ============================================================
// ROUND 06 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
s.waitForBoot({
    var caveBus;
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };
    caveBus = ~synthBus;

    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\caveDrop, { |out=0, freq=440, amp=0.1, pan=0, decay=3|
        var env, drop, modes, sig;
        env = EnvGen.ar(Env.perc(0.002, decay), doneAction: 2);
        drop = WhiteNoise.ar * env;
        modes = Ringz.ar(drop, freq * [1, 1.49, 2.23, 3.17], [decay, decay * 0.72, decay * 0.48, decay * 0.3], [0.16, 0.12, 0.08, 0.045]).sum;
        sig = (modes * 0.7 + SinOsc.ar(freq * 0.5, 0, env * 0.08)).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\caveScrape, { |out=0, freq=160, amp=0.07, pan=0, dur=0.4|
        var env, grit, reson, sig;
        env = EnvGen.ar(Env.perc(0.003, dur.max(0.05)), doneAction: 2);
        grit = BPF.ar(WhiteNoise.ar, freq * [1, 2.7, 4.1], [0.18, 0.13, 0.1]).sum * 3;
        reson = Ringz.ar(grit * env, freq * [1, 1.42, 2.6], [0.18, 0.24, 0.12], [0.1, 0.07, 0.04]).sum;
        sig = (reson + grit * env * 0.12).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\cavePulse, { |out=0, freq=55, amp=0.08, pan=0, dur=1|
        var env, low, overtone, sig;
        env = EnvGen.ar(Env.perc(0.01, dur.max(0.05)), doneAction: 2);
        low = SinOsc.ar(freq * (1 + env * 1.8)) * env;
        overtone = SinOsc.ar(freq * 2.03) * env * 0.18;
        sig = (low * 0.65 + overtone).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    Ndef(\maquineDrips, {
        |amp=0, tone=600, motion=0.1|
        var pulse, droplets, reson, air, sig;
        pulse = Dust2.ar(1.1 + (motion * 5));
        droplets = Decay2.ar(pulse, 0.003, 0.18) * WhiteNoise.ar(0.35);
        reson = Ringz.ar(droplets, tone * [1, 1.47, 2.31], [1.3, 2.2, 3.6], [0.2, 0.13, 0.08]).sum;
        air = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.08).range(180, 900), 0.4) * 0.025;
        sig = reson + air;
        Splay.ar([sig, DelayC.ar(sig, 0.2, 0.13)], 0.7, amp);
    });

    Ndef(\maquineVault, {
        |amp=0, freq=55, breath=0.08|
        var sub, overtone, wind, sig;
        sub = SinOsc.ar(freq) * 0.23 + SinOsc.ar(freq * 2) * 0.1;
        overtone = SinOsc.ar(freq * [1.5, 2.01, 3.02], 0, [0.035, 0.025, 0.012]).sum;
        wind = LPF.ar(PinkNoise.ar, LFNoise1.kr(0.05).range(240, 1100)) * breath;
        sig = (sub + overtone + wind).tanh;
        Splay.ar([sig, DelayC.ar(sig, 0.3, 0.19)], 0.45, amp);
    });

    Ndef(\maquineDrips).fadeTime = 3;
    Ndef(\maquineVault).fadeTime = 5;
    Ndef(\maquineDrips).set(\amp, 0);
    Ndef(\maquineVault).set(\amp, 0);

    Ndef(\maquineMix, {
        var sig, drip, vault;
        drip = Ndef.ar(\maquineDrips, 2);
        vault = Ndef.ar(\maquineVault, 2);
        sig = In.ar(caveBus, 2) + drip + vault;
        sig;
    });
    Ndef(\maquineMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, 0.86, 0.23);
    };
    Ndef(\maquineMix)[11] = \filter -> { |in|
        LPF.ar(in, 12500);
    };
    Ndef(\maquineMix).set(\wet10, 0.32, \wet11, 0.18);
    Ndef(\maquineMix).play;
    s.sync;

    Tdef(\masterScore, {
        var dripSeq, scrapeSeq, pulseSeq;
        0.5.wait;
        "0:00 - Sete salões: a água desenha o primeiro eco.".postln;
        Ndef(\maquineVault).xset(\amp, 0.12, \freq, 55);
        Ndef(\maquineDrips).xset(\amp, 0.08, \tone, 520, \motion, 0.08);
        4.do { |i|
            Ndef(\maquineDrips).xset(\tone, [480, 620, 740, 560][i], \motion, 0.08 + (i * 0.035));
            2.wait;
        };

        "0:08 - Estalactites: gotas isoladas acendem as abóbadas.".postln;
        Pbindef(\maquineDropSeq,
            \instrument, \caveDrop, \out, caveBus,
            \dur, Pseq([1.5, 0.5, 2, 0.75, 1.25, 0.5], inf),
            \freq, Pseq([659, 784, 988, 740, 587, 880, 659], inf),
            \decay, Pseq([3.2, 1.8, 4.2, 2.4], inf),
            \amp, Pseq([0.075, 0.05, 0.09, 0.055], inf),
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;
        8.do { |i|
            Ndef(\maquineDrips).xset(\tone, [740, 880, 620, 990][i % 4]);
            1.wait;
        };

        "0:16 - A rocha responde: fricção mineral e ressonância funda.".postln;
        Pbindef(\maquineDropSeq).stop;
        Ndef(\maquineDrips).xset(\amp, 0.035);
        Pbindef(\maquineScrapeSeq,
            \instrument, \caveScrape, \out, caveBus,
            \dur, Pseq([0.25, 0.5, 0.25, 1, 0.75, 0.5], inf),
            \freq, Pseq([180, 260, 145, 330, 210, 390, 160], inf),
            \dur, Pseq([0.35, 0.22, 0.5, 0.3], inf),
            \amp, Pseq([0.055, 0.035, 0.06, 0.04], inf),
            \pan, Pwhite(-0.75, 0.75, inf)
        ).play;
        6.do { |i|
            Ndef(\maquineVault).xset(\freq, [55, 61.7, 73.4, 82.4, 98, 110][i], \breath, 0.05 + (i * 0.008));
            1.wait;
        };

        "0:22 - Limite: a câmara se estreita até o brilho agudo.".postln;
        Pbindef(\maquineScrapeSeq, \freq, Pseq([390, 520, 660, 880, 1175, 1480], inf), \dur, Pseq([0.18, 0.25, 0.18, 0.5], inf));
        Ndef(\maquineDrips).xset(\tone, 1800, \motion, 0.8);
        5.do { |i|
            Ndef(\maquineDrips).xset(\tone, [1100, 1450, 1900, 2400, 3100][i]);
            1.wait;
        };

        "0:27 - Flashback: a agitação cessa; resta o gotejo.".postln;
        Pbindef(\maquineScrapeSeq).stop;
        Ndef(\maquineDrips).xset(\amp, 0.045, \tone, 659, \motion, 0.04);
        Ndef(\maquineVault).xset(\amp, 0.06, \freq, 55, \breath, 0.025);
        4.wait;

        "0:31 - O pulso da água atravessa o calcário.".postln;
        Pbindef(\maquinePulseSeq,
            \instrument, \cavePulse, \out, caveBus,
            \dur, Pseq([1, 0.5, 0.5, 1.5, 0.75], inf),
            \freq, Pseq([55, 55, 82.4, 73.4, 55, 110], inf),
            \amp, Pseq([0.08, 0.055, 0.065, 0.075], inf),
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;
        5.do { |i|
            Ndef(\maquineDrips).xset(\tone, [520, 620, 740, 659, 520][i]);
            1.wait;
        };

        "0:36 - Resolução: o centro grave retorna, ecos se apagam.".postln;
        Pbindef(\maquinePulseSeq).stop;
        Ndef(\maquineDrips).xset(\amp, 0.035, \tone, 659);
        Ndef(\maquineVault).xset(\amp, 0.08, \freq, 55);
        3.wait;
        Pbindef(\maquineDropSeq).stop;
        Ndef(\maquineDrips).xset(\amp, 0);
        3.wait;
        Pbindef(\maquineDropSeq).clear;
        Pbindef(\maquineScrapeSeq).clear;
        Pbindef(\maquinePulseSeq).clear;
        Ndef(\maquineDrips).clear(2);
        Ndef(\maquineVault).clear(3);
        Ndef(\maquineMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 07 | MODE: DESIGN | FRAG #170
// STATUS: PASS
// PROMPT: O rei acordou com uma ideia azul na cabeça. Não era um pássaro nem uma flor de lavanda: era um pensa...
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
{
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64, hpf3: 65, lpf3: 66, rq3: 67, atk3: 68, dec3: 69, sus3: 70, rls3: 71, fx3: 72,
    delMix: 80, verbMix: 81, panic: 82
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label;
    label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not and: { label.contains("bome").not }
            and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not } and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not } and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    var zoneNotes, zoneMeta, keyDefaults;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 68, hpf1: 25, lpf1: 180, rq1: 0.7, atk1: 0.02, dec1: 0.35, sus1: 0.7, rls1: 0.8, fx1: 0.0,
        vol2: 0.2, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 100, hpf2: 350, lpf2: 6500, rq2: 0.65, atk2: 0.005, dec2: 0.35, sus2: 0.25, rls2: 0.55, fx2: 0.0,
        vol3: 0.17, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.55, atk3: 0.8, dec3: 1.8, sus3: 0.6, rls3: 3.5, fx3: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    zoneNotes = Array.fill(128, { List.new });
    ~zoneNotes = zoneNotes;

    SynthDef(\blueIdea1, { |out=0, freq=110, gate=1, amp=0.2, pan=0, hpf=25, lpf=180, rq=0.7, atk=0.02, dec=0.35, sus=0.7, rls=0.8, mute=0, fx=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 1.5) * (freq * (0.2 + (fx * 4)));
        sig = SinOsc.ar(freq + mod) * 0.7 + SinOsc.ar(freq * 0.5) * 0.3;
        sig = LPF.ar(HPF.ar(sig, hpf), lpf) * env * amp * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    SynthDef(\blueIdea2, { |out=0, freq=440, gate=1, amp=0.2, pan=0, hpf=350, lpf=6500, rq=0.65, atk=0.005, dec=0.35, sus=0.25, rls=0.55, mute=0, fx=0|
        var env, exc, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.025));
        sig = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.2);
        sig = AllpassC.ar(sig, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = LPF.ar(HPF.ar(sig, hpf), lpf) * env * amp * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    SynthDef(\blueIdea3, { |out=0, freq=660, gate=1, amp=0.17, pan=0, hpf=160, lpf=3200, rq=0.55, atk=0.8, dec=1.8, sus=0.6, rls=3.5, mute=0, fx=0|
        var env, drift, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        drift = SinOsc.kr(0.08, 0, 0.004 + (fx * 0.03));
        sig = (Saw.ar(freq * (1 + drift)) * 0.35) + (Pulse.ar(freq * 1.501, 0.42) * 0.18) + SinOsc.ar(freq * 2.71, 0, 0.18);
        sig = LPF.ar(HPF.ar(sig, hpf), lpf) * env * amp * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    SynthDef(\blueDelay, { |in=0, out=0, mix=0|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = CombC.ar(sig, 1.0, 0.31, 2.5);
        Out.ar(out, sig + (wet * mix));
    }).add;
    SynthDef(\blueVerb, { |in=0, out=0, mix=0|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 0.75, 0.82, 0.25);
        Out.ar(out, sig + (wet * mix));
    }).add;
    SynthDef(\blueMaster, { |in=0, out=0|
        var sig;
        sig = LeakDC.ar(In.ar(in, 2));
        Out.ar(out, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    ~delaySynth = Synth.tail(~fxGroup, \blueDelay, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.delMix.asMap]);
    ~verbSynth = Synth.tail(~fxGroup, \blueVerb, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.verbMix.asMap]);
    ~masterSynth = Synth.tail(~masterGroup, \blueMaster, [\in, ~audioBus, \out, 0]);

    ~zoneMeta = [
        (id: 1, title: "01 • Fonte / sub", fxKey: \fx1, fxLabel: "Cristal"),
        (id: 2, title: "02 • Manto escarlate / gotas", fxKey: \fx2, fxLabel: "Lapidação"),
        (id: 3, title: "03 • Ideia azul / ar", fxKey: \fx3, fxLabel: "Brisa")
    ];
    ~zoneMeta.do { |zm|
        var defName;
        defName = [\blueIdea1, \blueIdea2, \blueIdea3][zm.id - 1];
        ~ccVals.keys.select { |k| k.asString.endsWith(zm.id.asString) }.do { |k|
            // Parameters are mapped at note creation below.
        };
    };

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.contains("lpf") or: { ks.contains("hpf") } } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.contains("atk") or: { ks.contains("dec") } or: { ks.contains("rls") } } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.contains("sus") or: { ks.contains("vol") } or: { ks.contains("fx") } or: { ks.contains("mix") } } { norm }
                    { ks.contains("min") or: { ks.contains("max") } } { val }
                    { ks.contains("mute") or: { ks.contains("panic") } } { if(val > 63, 1.0, 0.0) }
                    { norm };
                if(key != \panic) {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
        if(num == ~cc[\panic] and: { val > 63 }) {
            ~zoneNotes.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\blueNoteOn, { |vel, noteNum, chan, src|
        var idx, id, lo, hi, pars, defName, voice;
        ~zoneMeta.do { |zm|
            idx = zm.id;
            id = idx.asString;
            lo = ~ccVals[("min" ++ id).asSymbol];
            hi = ~ccVals[("max" ++ id).asSymbol];
            if((noteNum >= lo) and: { noteNum <= hi }) {
                pars = [\amp, (vel / 127.0) * ~ccVals[("vol" ++ id).asSymbol],
                    \pan, ~buses[("pan" ++ id).asSymbol].asMap,
                    \hpf, ~buses[("hpf" ++ id).asSymbol].asMap,
                    \lpf, ~buses[("lpf" ++ id).asSymbol].asMap,
                    \rq, ~buses[("rq" ++ id).asSymbol].asMap,
                    \atk, ~buses[("atk" ++ id).asSymbol].asMap,
                    \dec, ~buses[("dec" ++ id).asSymbol].asMap,
                    \sus, ~buses[("sus" ++ id).asSymbol].asMap,
                    \rls, ~buses[("rls" ++ id).asSymbol].asMap,
                    \mute, ~buses[("mute" ++ id).asSymbol].asMap,
                    \fx, ~buses[("fx" ++ id).asSymbol].asMap,
                    \freq, noteNum.midicps, \out, ~audioBus];
                defName = [\blueIdea1, \blueIdea2, \blueIdea3][idx - 1];
                voice = Synth.head(~synthGroup, defName, pars);
                ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(voice);
            };
        };
    }, srcID: ~myUid);
    MIDIdef.noteOff(\blueNoteOff, { |vel, noteNum, chan, src|
        ~zoneNotes[noteNum].do { |voice| voice.set(\gate, 0) };
        ~zoneNotes[noteNum] = List.new;
    }, srcID: ~myUid);

    defer {
        var screen, bounds, width, height, win, pages, currentPage, nav, bottom, ui, specs, pageViews;
        screen = Window.availableBounds;
        width = 960;
        height = min(780, screen.height - 60);
        bounds = Rect((screen.width - width) / 2, (screen.height - height) / 2, width, height);
        if(~mainWin.notNil) { ~mainWin.close };
        win = Window("A ideia azul — instrumento de cristal", bounds, scroll: true);
        ~mainWin = win;
        ui = IdentityDictionary.new;
        ~ui = ui;
        nav = CompositeView(win, Rect(0, 0, width, 42));
        pages = CompositeView(win, Rect(0, 44, width, height - 128));
        pageViews = List.new;
        currentPage = 0;
        ~zoneMeta.do { |zm, idx|
            var page, title, col, row, keys, labels, k, spec, widget, y, x;
            page = CompositeView(pages, Rect(0, 0, width, height - 128));
            page.visible = (idx == 0);
            pageViews.add(page);
            StaticText(page, Rect(18, 8, 700, 28)).string = zm.title;
            keys = [\vol, \pan, \mute, \min, \max, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, zm.fxKey];
            labels = ["Volume", "Pan", "Mute", "Nota min", "Nota max", "HPF", "LPF", "Res", "Attack", "Decay", "Sustain", "Release", zm.fxLabel];
            keys.do { |key, j|
                var fullKey, label, val, lo, hi, bounds2;
                fullKey = if(key == zm.fxKey, { key }, { (key.asString ++ zm.id.asString).asSymbol });
                label = labels[j] ++ "  CC " ++ (~cc[fullKey] ? 0).asString;
                val = ~ccVals[fullKey] ? 0;
                lo = if(key == \pan, { -1.0 }, { if(key == \min or: { key == \max }, { 0 }, { 0 }) });
                hi = if(key == \pan, { 1.0 }, { if(key == \min or: { key == \max }, { 127 }, { 1 }) });
                if(key == \hpf or: { key == \lpf }) { lo = 20; hi = 18000 };
                if(key == \atk or: { key == \dec or: { key == \rls } }) { lo = 0.005; hi = 5 };
                bounds2 = Rect(20 + ((j % 4) * 230), 48 + ((j div: 4) * 140), 210, 118);
                widget = EZSlider(page, bounds2, label, ControlSpec(lo, hi, if(lo > 0 and: { key != \min and: { key != \max } }, { \exp }, { \lin }), 0, val), { |ez|
                    ~ccVals[fullKey] = ez.value;
                    if(~buses[fullKey].notNil) { ~buses[fullKey].set(ez.value) };
                }, val, layout: \vert);
                ui[fullKey] = widget;
            };
        };
        ~zoneMeta.do { |zm, idx|
            var button;
            button = Button(nav, Rect(12 + (idx * 210), 6, 195, 30))
                .states_([[zm.title]]);
            button.action_({
                pageViews.do { |view, j| view.visible = (j == idx) };
            });
        };
        bottom = CompositeView(win, Rect(0, height - 78, width, 72));
        EZSlider(bottom, Rect(12, 2, 260, 62), "Delay CC 80", ControlSpec(0, 1, \lin, 0, 0), { |ez| ~ccVals[\delMix] = ez.value; ~buses.delMix.set(ez.value) }, 0);
        EZSlider(bottom, Rect(285, 2, 260, 62), "Reverb CC 81", ControlSpec(0, 1, \lin, 0, 0), { |ez| ~ccVals[\verbMix] = ez.value; ~buses.verbMix.set(ez.value) }, 0);
        Button(bottom, Rect(590, 12, 220, 42)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({
            ~zoneNotes.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; };
        });
        win.front;
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil and: { ~mainWin.isClosed.not }) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
}.value;
)


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #129
// STATUS: PASS
// PROMPT: O que não tem utilidade nenhuma é o que sustenta o mundo. Aprendi com os passarinhos a arte de desap...
// ============================================================
(
Ndef(\riverUnmeasured, {
    |freq=55, amp=0.12, pan=0, t_trig=1|
    var env, drift, tone, harmonics;
    env = EnvGen.kr(Env.perc(1.2, 7.0, 1, -4), t_trig);
    drift = SinOsc.kr(0.035).range(0.985, 1.015);
    tone = SinOsc.ar(freq * drift, 0, 0.7) + SinOsc.ar(freq * 2 * drift, 0, 0.22);
    harmonics = SinOsc.ar(freq * 3 * drift, 0, 0.08);
    Pan2.ar((tone + harmonics) * env, pan, amp);
}).fadeTime = 5;
Ndef(\riverUnmeasured).play;
Ndef(\riverUnmeasured)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.25)
};
Ndef(\riverUnmeasured).set(\wet10, 0.32);
Pbindef(\riverUnmeasuredSeq,
    \freq, Pseq([43.65, 49, 55, 41.2, 46.25, 55], inf),
    \dur, Pwrand([3, 4, 5, 6], [0.3, 0.35, 0.2, 0.15], inf),
    \amp, Pwhite(0.085, 0.13, inf),
    \pan, Pwhite(-0.35, 0.35, inf),
    \t_trig, 1
);
Ndef(\riverUnmeasured).quant = 1;
Ndef(\riverUnmeasured)[1] = \set -> Pbindef(\riverUnmeasuredSeq);

// A small leap in the mud: a soft, resonant pulse with room around it.
Ndef(\mudRipple, {
    |freq=180, amp=0.14, pan=0, t_trig=1|
    var env, body, knock, shimmer;
    env = EnvGen.kr(Env.perc(0.003, 0.48, 1, -7), t_trig);
    knock = SinOsc.ar(freq * 0.72, 0, 0.42);
    body = SinOsc.ar(freq, 0, 0.32) + SinOsc.ar(freq * 2.71, 0, 0.12);
    shimmer = BPF.ar(PinkNoise.ar, freq * 3.2, 0.22) * 2.5;
    Pan2.ar((knock + body + shimmer) * env, pan, amp);
}).fadeTime = 2;
Ndef(\mudRipple).play;
Ndef(\mudRipple)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.28)
};
Ndef(\mudRipple).set(\wet10, 0.24);
Pbindef(\mudRippleSeq,
    \freq, Pseq([196, 247, 164.8, 220, 293.66, 185], inf),
    \dur, Pwrand([0.5, 0.75, 1, 1.5], [0.36, 0.28, 0.24, 0.12], inf),
    \amp, Pwhite(0.09, 0.15, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \t_trig, 1
);
Ndef(\mudRipple).quant = 1;
Ndef(\mudRipple)[1] = \set -> Pbindef(\mudRippleSeq);

// Unnamed birdsong: bright, brief FM bells drifting through the afternoon.
Ndef(\namelessBirds, {
    |freq=660, amp=0.11, pan=0, t_trig=1|
    var env, strike, mod, carrier, air;
    env = EnvGen.kr(Env.perc(0.006, 1.6, 1, -5), t_trig);
    strike = Decay2.ar(K2A.ar(t_trig), 0.002, 0.22);
    mod = SinOsc.ar(freq * 2.71, 0, freq * 1.8 * strike);
    carrier = SinOsc.ar(freq + mod, 0, 0.72);
    air = BPF.ar(WhiteNoise.ar, freq * 2.4, 0.18) * 1.7;
    Pan2.ar((carrier + air) * env, pan, amp);
}).fadeTime = 3;
Ndef(\namelessBirds).play;
Ndef(\namelessBirds)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.8, 0.32)
};
Ndef(\namelessBirds).set(\wet10, 0.38);
Pbindef(\namelessBirdsSeq,
    \freq, Pseq([659.25, 783.99, 587.33, 880, 698.46, 523.25, 987.77], inf),
    \dur, Pwrand([0.75, 1, 1.5, 2.5], [0.22, 0.34, 0.28, 0.16], inf),
    \amp, Pwhite(0.075, 0.12, inf),
    \pan, Pwhite(-0.9, 0.9, inf),
    \t_trig, 1
);
Ndef(\namelessBirds).quant = 1;
Ndef(\namelessBirds)[1] = \set -> Pbindef(\namelessBirdsSeq);

// Ndef(\riverUnmeasured).xset(\amp, 0.16); // Lift the river | Revert: Ndef(\riverUnmeasured).xset(\amp, 0.12);
// Pbindef(\mudRippleSeq, \dur, 0.25); // Quicker mud-leaps | Revert: Pbindef(\mudRippleSeq, \dur, 0.75);
// Ndef(\riverUnmeasured).fadeTime = 4; Ndef(\riverUnmeasured).clear(4); // Rollback river
// Ndef(\mudRipple).fadeTime = 4; Ndef(\mudRipple).clear(4); // Rollback ripples
// Ndef(\namelessBirds).fadeTime = 4; Ndef(\namelessBirds).clear(4); // Rollback birds
)


// ============================================================
// ROUND 09 | MODE: COMPOSE | FRAG #55
// STATUS: PASS
// PROMPT: Passava da meia-noite quando as matracas de madeira começaram a bater compassadas no calçamento de p...
// ============================================================
(
s.waitForBoot({
    var marianaBus;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };
    marianaBus = ~synthBus;

    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\marianaMatraca, {
        |out=0, freq=180, amp=0.16, pan=0, dur=0.18, t_trig=1|
        var env, click, wood, rattle;
        env = EnvGen.ar(Env.perc(0.001, dur.max(0.05), 1, -8), t_trig, doneAction: 2);
        click = HPF.ar(WhiteNoise.ar, 1100) * EnvGen.ar(Env.perc(0.001, 0.035));
        wood = SinOsc.ar(freq, 0, 0.7) + SinOsc.ar(freq * 2.73, 0, 0.22);
        rattle = BPF.ar(WhiteNoise.ar, freq * 5, 0.3) * 1.8;
        Out.ar(out, Pan2.ar((click + wood + rattle) * env, pan, amp));
    }).add;

    SynthDef(\marianaSino, {
        |out=0, freq=220, amp=0.15, pan=0, dur=5, t_trig=1|
        var env, strike, modes;
        env = EnvGen.ar(Env.perc(0.01, dur.max(0.05), 1, -3), t_trig, doneAction: 2);
        strike = Decay2.ar(K2A.ar(t_trig), 0.004, 0.18);
        modes = SinOsc.ar(freq, 0, 0.55)
            + SinOsc.ar(freq * 2.71, 0, 0.26)
            + SinOsc.ar(freq * 4.18, 0, 0.12)
            + BPF.ar(WhiteNoise.ar, freq * 3.1, 0.16) * strike * 2;
        Out.ar(out, Pan2.ar(modes * env, pan, amp));
    }).add;
    s.sync;

    Ndef(\marianaSerra, {
        |amp=0, cutoff=900, rate=0.08|
        var wind, gust, low, high;
        gust = LFNoise1.kr(rate).range(0.12, 0.8);
        wind = BPF.ar(PinkNoise.ar, SinOsc.kr(0.025).range(180, 520), 0.4);
        low = SinOsc.ar(48 + SinOsc.kr(0.04).range(-1.5, 1.5), 0, 0.25);
        high = LPF.ar(wind, cutoff) * gust * 2;
        Splay.ar([low, high]) * amp;
    }).fadeTime = 4;
    Ndef(\marianaSerra).play;

    Ndef(\marianaChamas, {
        |amp=0, flicker=3|
        var flame, crackle, body;
        flame = LFNoise1.kr(flicker).range(0.15, 0.75);
        crackle = Decay2.ar(Dust.ar(2.5), 0.001, 0.025) * WhiteNoise.ar;
        body = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.7).range(700, 2400), 0.3) * flame;
        Pan2.ar((body + crackle) * amp, LFNoise1.kr(0.15).range(-0.7, 0.7));
    }).fadeTime = 2;
    Ndef(\marianaChamas).play;

    Ndef(\marianaMix, {
        var dry, air, fire;
        dry = In.ar(marianaBus, 2);
        air = Ndef(\marianaSerra).ar(2);
        fire = Ndef(\marianaChamas).ar(2);
        LeakDC.ar(dry + air + fire);
    });
    Ndef(\marianaMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.22)
    };
    Ndef(\marianaMix)[11] = \filter -> { |in|
        LPF.ar(in, 7800)
    };
    Ndef(\marianaMix).set(\wet10, 0.22, \wet11, 0.18);
    Ndef(\marianaMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - Madrugada: o vento frio atravessa a rua de pedra.".postln;
        Ndef(\marianaSerra).xset(\amp, 0.16, \cutoff, 650);
        Ndef(\marianaChamas).xset(\amp, 0.035);
        4.do { |i|
            Ndef(\marianaSerra).xset(\cutoff, 420 + (i * 260), \rate, 0.06 + (i * 0.025));
            2.wait;
        };

        "0:08 - As matracas começam, madeira seca contra o calçamento.".postln;
        Pbindef(\marianaMatracas,
            \instrument, \marianaMatraca,
            \out, marianaBus,
            \freq, Pseq([196, 164.8, 185, 146.8, 174.6, 164.8, 220, 146.8], inf),
            \dur, Pseq([0.72, 0.72, 1.08, 0.5, 0.72, 1.44], inf),
            \amp, Pwhite(0.11, 0.17, inf),
            \pan, Pwhite(-0.65, 0.65, inf),
            \t_trig, 1
        ).play;
        12.wait;

        "0:20 - O dobre lento se ergue entre as fachadas fechadas.".postln;
        Pbindef(\marianaMatracas).stop;
        Pbindef(\marianaSino,
            \instrument, \marianaSino,
            \out, marianaBus,
            \freq, Pseq([146.83, 0, 146.83, 130.81, 146.83], inf),
            \dur, Pseq([4, 3, 5, 4, 6], inf),
            \amp, Pseq([0.17, 0, 0.13, 0.12, 0.16], inf),
            \pan, Pseq([-0.15, 0, 0.15, 0, 0], inf),
            \t_trig, 1
        ).play;
        Ndef(\marianaSerra).xset(\amp, 0.1, \cutoff, 1100);
        3.do { |i|
            Ndef(\marianaChamas).xset(\amp, 0.025 + (i * 0.012));
            3.wait;
        };

        "0:29 - As tochas estalam; a procissão acelera por instantes.".postln;
        Pbindef(\marianaSino).stop;
        Pbindef(\marianaMatracas,
            \dur, Pseq([0.36, 0.36, 0.54, 0.72, 0.36, 1.08], inf),
            \freq, Pseq([196, 220, 164.8, 185, 146.8, 220, 174.6], inf),
            \amp, Pwhite(0.12, 0.19, inf)
        ).play;
        8.wait;

        "0:37 - Um sino isolado: silêncio frágil nos vãos das casas.".postln;
        Pbindef(\marianaMatracas).stop;
        Ndef(\marianaChamas).xset(\amp, 0.012);
        Ndef(\marianaSerra).xset(\amp, 0.07, \cutoff, 480);
        Synth(\marianaSino, [\out, marianaBus, \freq, 146.83, \amp, 0.16, \dur, 7, \pan, 0]);
        6.wait;

        "0:43 - Flashback: três passos compassados, e o dobre responde.".postln;
        Pbindef(\marianaMatracas,
            \dur, Pseq([0.72, 0.72, 1.44], inf),
            \freq, Pseq([196, 164.8, 146.8], inf),
            \amp, 0.12
        ).play;
        Pbindef(\marianaSino,
            \instrument, \marianaSino,
            \out, marianaBus,
            \freq, Pseq([146.83, 0, 130.81], inf),
            \dur, Pseq([4, 3, 5], inf),
            \amp, Pseq([0.13, 0, 0.1], inf),
            \t_trig, 1
        ).play;
        6.wait;

        "0:49 - A procissão desaparece; resta o ar da serra.".postln;
        Pbindef(\marianaMatracas).stop;
        Pbindef(\marianaSino).stop;
        Ndef(\marianaChamas).xset(\amp, 0);
        Ndef(\marianaSerra).xset(\amp, 0.045, \cutoff, 360);
        5.wait;
        Ndef(\marianaSerra).xset(\amp, 0);
        3.wait;

        Pbindef(\marianaMatracas).stop;
        Pbindef(\marianaMatracas).clear;
        Pbindef(\marianaSino).stop;
        Pbindef(\marianaSino).clear;
        Ndef(\marianaSerra).clear(2);
        Ndef(\marianaChamas).clear(2);
        Ndef(\marianaMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    }).play;
});
)


// ============================================================
// ROUND 10 | MODE: APPEND | FRAG #155
// STATUS: PASS
// PROMPT: Eduardo subiu correndo os degraus de pedra da biblioteca pública de Belo Horizonte com o coração bat...
// ============================================================
(
Ndef(\bibliotecaSino, { |freq=220, amp=0.12, pan=0, t_trig=0, brilho=0.5|
    var env, strike, bell, rustle, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.32, 1, -6), t_trig);
    strike = Decay2.ar(K2A.ar(t_trig), 0.002, 0.045);
    bell = SinOsc.ar(freq, 0, 0.45)
        + SinOsc.ar(freq * 2.71, 0, 0.22)
        + SinOsc.ar(freq * 4.16, 0, 0.1);
    rustle = BPF.ar(WhiteNoise.ar, freq * 5, 0.32) * strike * brilho;
    sig = (bell * env) + rustle;
    Pan2.ar(sig * amp, pan);
}).fadeTime = 1;
Ndef(\bibliotecaSino).play;

Pbindef(\bibliotecaSinoSeq,
    \dur, Pseq([0.18, 0.18, 0.16, 0.14, 0.12, 0.12, 0.1, 0.1, 0.32, 0.24, 0.2, 0.16, 0.12, 0.12, 0.12, 0.45, 0.72, 1.1], inf),
    \freq, Pseq([92, 110, 123, 110, 138, 123, 164, 138, 185, 220, 246, 277, 330, 370, 440, 554, 740, 988], inf),
    \amp, Pseq([0.045, 0.05, 0.055, 0.06, 0.065, 0.07, 0.075, 0.08, 0.08, 0.075, 0.07, 0.065, 0.06, 0.055, 0.05, 0.045, 0.035, 0.025], inf),
    \pan, Pseq([-0.65, -0.5, -0.35, -0.2, 0, 0.2, 0.35, 0.5, 0.55, 0.4, 0.25, 0.1, -0.1, -0.25, -0.4, -0.2, 0, 0], inf),
    \brilho, Pseq([0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25, 0.18, 0.12], inf),
    \t_trig, 1
);
Ndef(\bibliotecaSino)[1] = \set -> Pbindef(\bibliotecaSinoSeq);

// Eduardo corre pelos degraus; o tilintar final resolve a urgência num eco delicado.
 // Pbindef(\bibliotecaSinoSeq).stop; Ndef(\bibliotecaSino).fadeTime = 2; Ndef(\bibliotecaSino).clear(2); // Rollback: remove this instrument
)

