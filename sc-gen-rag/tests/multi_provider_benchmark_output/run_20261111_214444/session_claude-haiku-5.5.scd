// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-12T01:29:44.638481+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: "Silêncio antártico" - low wind drone with sparse paper-fold crackles (the map being folded)
Ndef(\tempestade, { |t_trig=0, amp=0.25, cutoff=300, rq=0.6|
    var env, wind, crackle, sub, lfo, sig;
    lfo = SinOsc.kr(0.03).range(0.4, 1);
    env = EnvGen.ar(Env.perc(0.02, 0.6), t_trig);
    wind = RLPF.ar(BrownNoise.ar(0.6), cutoff * lfo, rq);
    crackle = HPF.ar(WhiteNoise.ar(0.4), 3000) * Decay.ar(K2A.ar(t_trig), 0.06);
    sub = (SinOsc.ar(38) * 0.3 + SinOsc.ar(76) * 0.08) * lfo;
    sig = ((wind * 0.8) + sub + (crackle * 0.6) + (wind * env * 0.3)) * amp;
    Pan2.ar(sig.tanh, SinOsc.kr(0.07) * 0.3);
}).fadeTime_(3).play;

Pbindef(\silencio,
    \dur, Pseq([1.5, 0.5, 0.25, 0.25, 2, 0.75], inf),
    \t_trig, Pseq([1, 0, 1, 1, 0, 1], inf),
    \amp, Pseq([0.2, 0.25, 0.3, 0.35, 0.3, 0.4], inf),
    \cutoff, Pseq([200, 260, 340, 420, 380, 500], inf),
    \rq, Pwhite(0.4, 0.8, inf)
);

// Route the pattern into the proxy's slot
Ndef(\tempestade)[1] = \set -> Pbindef(\silencio);
// Rollback: remove this instrument
// Pbindef(\silencio).stop; Ndef(\tempestade).fadeTime = 2; Ndef(\tempestade).clear(2);
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

s.waitForBoot({
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // tick of a pendulum escapement
    SynthDef(\tictac, { |out=0, freq=2000, amp=0.1, decay=0.03|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        exc = Impulse.ar(0);
        sig = Ringz.ar(exc, freq, decay * 4) + HPF.ar(WhiteNoise.ar(0.05) * env, 4000);
        Out.ar(out, Pan2.ar(sig * env * amp, LFNoise1.kr(0.3).range(-0.5, 0.5)));
    }).add;

    // brass chime of a French carillon
    SynthDef(\carrilhao, { |out=0, freq=440, amp=0.3, pan=0|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.004, 2.2, 1, -5), doneAction: 2);
        exc = Impulse.ar(0) + (PinkNoise.ar(0.02) * EnvGen.ar(Env.perc(0.001, 0.03)));
        sig = DynKlank.ar(Ref([[freq, freq * 2.76, freq * 5.4, freq * 8.93], [1, 0.5, 0.25, 0.1], [1, 0.6, 0.35, 0.2]]), exc, decayscale: 1.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;
    s.sync;

    // two hundred clocks slightly out of phase
    Ndef(\enxame, { |amp=0, cutoff=4000|
        var sig;
        sig = Splay.ar(Array.fill(16, { |i|
            var rate, tk;
            rate = 2.9 + (i * 0.0137);
            tk = Impulse.ar(rate, i * 0.0625);
            Ringz.ar(tk, 2200 + (i * 53), 0.04)
        }));
        LPF.ar(sig, cutoff) * amp * 0.5;
    }).fadeTime_(4).play;

    // breath of time: beating detuned sines
    Ndef(\respiro, { |amp=0, freq=55|
        var breath, sig;
        breath = SinOsc.kr(0.08).range(0.2, 1);
        sig = Splay.ar([SinOsc.ar(freq, 0, 0.3), SinOsc.ar(freq * 1.0007, 0, 0.3), SinOsc.ar(freq * 2.003, 0, 0.08)]);
        LPF.ar(sig * breath, 500) * amp;
    }).fadeTime_(5).play;

    Ndef(\masterMix, { var inp; inp = In.ar(~synthBus, 2) + Ndef.ar(\enxame, 2) + Ndef.ar(\respiro, 2); inp.tanh * 0.8 });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.8, 0.3) };
    Ndef(\masterMix).set(\wet10, 0.25);
    Ndef(\masterMix).play;

    Pbindef(\ticks,
        \instrument, \tictac,
        \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 0.75], inf),
        \freq, Pwhite(1400.0, 3000.0, inf),
        \amp, Pwhite(0.05, 0.14, inf),
        \decay, 0.025,
        \out, ~synthBus
    );

    Pbindef(\carrilhoes,
        \instrument, \carrilhao,
        \dur, Pseq([2.5, 1.5, 2.0, 3.0], inf),
        \freq, Pseq([523.25, 659.25, 783.99, 659.25], inf),
        \amp, 0.22,
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Oficina em silêncio, o respiro do tempo]".postln;
        Ndef(\enxame).xset(\amp, 0.6);
        Ndef(\respiro).xset(\amp, 0.7);
        8.wait;

        "0:08 - [Cue 2: Os tiques entram, defasagens microscópicas]".postln;
        Pbindef(\ticks).play;
        4.do { |i| Ndef(\enxame).xset(\cutoff, exprand(1500, 6000)); 2.wait; };

        "0:16 - [Cue 3: Carrilhões respondem ao enxame]".postln;
        Pbindef(\carrilhoes).play;
        4.do { |i| Ndef(\enxame).xset(\cutoff, exprand(2000, 9000)); 2.wait; };

        "0:24 - [Cue 4: Limite intrínseco, a oficina se aperta]".postln;
        Pbindef(\ticks, \dur, Pseq([0.25, 0.25, 0.125, 0.125], inf));
        4.do { |i| Ndef(\enxame).xset(\cutoff, exprand(6000, 16000)); Ndef(\masterMix).set(\wet10, 0.25 + (i * 0.1)); 3.wait; };

        "0:36 - [Cue 5: Settling, só o respiro e um tique]".postln;
        Pbindef(\carrilhoes).stop;
        Pbindef(\ticks).stop;
        Ndef(\enxame).xset(\amp, 0.1);
        8.wait;

        "0:44 - [Cue 6: Flashback, o enxame retorna acelerado]".postln;
        Pbindef(\ticks, \dur, Pseq([0.125, 0.125, 0.25], inf), \freq, Pwhite(2400.0, 4200.0, inf));
        Pbindef(\ticks).play;
        Ndef(\enxame).xset(\amp, 0.6);
        4.do { |i| Ndef(\enxame).xset(\cutoff, exprand(3000, 12000)); 2.wait; };

        "0:56 - [Cue 7: Resolução, retorno ao centro de 523 Hz]".postln;
        Pbindef(\carrilhoes, \freq, Pseq([523.25, 523.25, 659.25, 523.25], inf));
        Pbindef(\carrilhoes).play;
        Ndef(\enxame).xset(\cutoff, 3500);
        8.wait;

        "1:04 - [Cue 8: Extrinsic limit, o relógio para]".postln;
        Pbindef(\ticks).stop;
        Ndef(\enxame).xset(\amp, 0);
        Ndef(\respiro).xset(\amp, 0);
        6.wait;

        Pbindef(\ticks).stop; Pbindef(\ticks).clear;
        Pbindef(\carrilhoes).stop; Pbindef(\carrilhoes).clear;
        Ndef(\enxame).clear(2);
        Ndef(\respiro).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    }).play;
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
    |freq=73.42, detune=0.0236, sawMix=0.41, pulseMix=0.59,
     pw=0.58, pwmRate=2.25, pwmDepth=0.21,
     subAmp=0.28, noiseAmp=0.038,
     cutoff=1836.2, rq=0.22, hpf=128.1,
     filtEnvAmt=2916.3, lfoRate=2.22, lfoDepth=534.7,
     atk=0.18, dec=0.58, sus=0.71, rls=1.1,
     pan=(-0.05), amp=0.24, t_trig=1|
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
Ndef(\subtractiveDesign).set(\wet10, 0.32);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.55, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.29);

Pbindef(\subtractiveDesignSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
    \freq, (73.42 * (2 ** (Prand([0, 2, 3, 7, 8], inf) / 12))),
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
// Congada: gungas metálicas, caixa e canto em formantes
Ndef(\congadaGunga).fadeTime = 2;
Ndef(\congadaCaixa).fadeTime = 2;
Ndef(\congadaCanto).fadeTime = 3;

// Gungas: metallic ankle-tin clusters excited by noise bursts
Ndef(\congadaGunga, {
    |freq=1800, amp=0.18, pan=(-0.35), t_trig=1, ring=0.09|
    var exc, metal, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.001, 0.012) * WhiteNoise.ar;
    metal = DynKlank.ar(
        Ref([
            [freq, freq * 1.51, freq * 2.27, freq * 3.40],
            [1.0, 0.7, 0.5, 0.3],
            [ring, ring * 0.8, ring * 0.6, ring * 0.5]
        ]),
        exc, 1
    );
    sig = (metal * 0.6).tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\congadaGunga).quant = 1;
Ndef(\congadaGunga)[11] = \filter -> { |in|
    CombL.ar(in, 0.3, 0.13, 0.9);
};
Ndef(\congadaGunga).set(\wet11, 0.22);

// Caixa: drum body with a pitch drop plus a snare-like hiss
Ndef(\congadaCaixa, {
    |amp=0.22, pan=(0.3), t_trig=1, tone=190|
    var env, body, hiss, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, 0.09);
    body = SinOsc.ar(tone * (1 + (env * 0.5)), 0, env * 0.8);
    hiss = HPF.ar(WhiteNoise.ar, 3000) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.18) * 0.5;
    sig = (body + hiss).tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\congadaCaixa).quant = 1;

// Canto: sawtooth through three parallel formant bands, call-and-response voice
Ndef(\congadaCanto, {
    |freq=220, amp=0.16, pan=(-0.2), t_trig=1, atk=0.05, rel=0.9, cutoff=1400|
    var env, src, lfo, formF, body, sig;
    env = EnvGen.ar(Env.perc(atk, rel, 1, -4), t_trig);
    src = Saw.ar(freq);
    lfo = SinOsc.kr(0.11).range(0.85, 1.15);
    formF = [700, 1200, 2600] * lfo;
    body = BPF.ar(src, formF, 0.12).sum * 8 * env;
    sig = LPF.ar(body, cutoff).tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\congadaCanto).quant = 1;
Ndef(\congadaCanto)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.7, 0.4);
};
Ndef(\congadaCanto).set(\wet10, 0.3);

// Patterns: moçambique-like gunga cycle with stochastic accents
Pbindef(\congadaGungaSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.5, 0.25], inf),
    \freq, Pwrand([1800, 2400, 3000], [0.6, 0.3, 0.1], inf),
    \amp, Pwhite(0.10, 0.20, inf),
    \pan, Pwhite(-0.6, -0.2, inf),
    \ring, Pwrand([0.07, 0.10, 0.14], [0.5, 0.35, 0.15], inf),
    \t_trig, 1
);
Ndef(\congadaGunga)[1] = \set -> Pbindef(\congadaGungaSeq);

// Caixa: syncopated drum pulse, occasional pitch variants
Pbindef(\congadaCaixaSeq,
    \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \tone, Pwrand([180, 210, 240], [0.6, 0.3, 0.1], inf),
    \amp, Pwhite(0.14, 0.24, inf),
    \pan, Pwhite(0.1, 0.4, inf),
    \t_trig, 1
);
Ndef(\congadaCaixa)[1] = \set -> Pbindef(\congadaCaixaSeq);

// Canto: modal melody in D-minor-like colour, long and short phrases
Pbindef(\congadaCantoSeq,
    \dur, Pseq([1.5, 0.5, 1, 2], inf),
    \freq, Pseq([220, 261.63, 293.66, 329.63, 293.66, 261.63, 220, 196], inf),
    \rel, Pwhite(0.6, 1.4, inf),
    \atk, 0.05,
    \pan, Pwhite(-0.4, 0.1, inf),
    \t_trig, 1
);
Ndef(\congadaCanto)[1] = \set -> Pbindef(\congadaCantoSeq);

// Live tweaks (uncomment to use)
// Ndef(\congadaGunga).xset(\ring, 0.16); // Longer metal ring | Revert: Ndef(\congadaGunga).xset(\ring, 0.09);
// Pbindef(\congadaCaixaSeq, \dur, Pseq([0.25, 0.25, 0.5], inf)); // Faster caixa | Revert: Pbindef(\congadaCaixaSeq, \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], inf));
// Pbindef(\congadaCantoSeq, \rel, 2.5); // Sustained canto | Revert: Pbindef(\congadaCantoSeq, \rel, Pwhite(0.6, 1.4, inf));
// Ndef(\congadaCanto).set(\wet10, 0.6); // More reverb | Revert: Ndef(\congadaCanto).set(\wet10, 0.3);
// Ndef(\congadaCaixa).fadeTime = 4; Pbindef(\congadaCaixaSeq).stop; // Rollback caixa | Restart: Pbindef(\congadaCaixaSeq).play;
)


// ============================================================
// ROUND 05 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: \correntes, "tinir de ferros" (chain clanks) with a sparse lightning crack.
// Form: Intrinsic Limit. The chains ring until the prayer for a bolt that breaks them.
Ndef(\correntes).fadeTime = 2;
Ndef(\correntes, {
    |freq=2600, amp=0.12, pan=(0.0), t_trig=1, ring=0.05, crack=0|
    var exc, clank, thunder, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.0005, 0.006) * WhiteNoise.ar;
    clank = DynKlank.ar(
        Ref([
            [freq, freq * 1.37, freq * 2.9],
            [1.0, 0.6, 0.35],
            [ring, ring * 0.7, ring * 0.4]
        ]),
        exc, 1
    );
    thunder = LPF.ar(BrownNoise.ar, 180) * Decay2.ar(K2A.ar(t_trig), 0.02, 1.8) * crack;
    sig = ((clank * 0.5) + (thunder * 0.9)).tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\correntes).quant = 1;

Pbindef(\correntesSeq,
    \dur, Pseq([2, 0.5, 0.5, 1.5, 0.25, 0.25, 4], inf),
    \freq, Pwrand([2600, 3100, 1900], [0.5, 0.3, 0.2], inf),
    \amp, Pwhite(0.08, 0.16, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \ring, Pwrand([0.04, 0.06, 0.09], [0.5, 0.3, 0.2], inf),
    \crack, Pseq([0, 0, 0, 0, 0, 0, 1], inf),
    \t_trig, 1
);
Ndef(\correntes)[1] = \set -> Pbindef(\correntesSeq);

// Rollback: remove this instrument
// Pbindef(\correntesSeq).stop; Ndef(\correntes).fadeTime = 2; Ndef(\correntes).clear(2);
)


// ============================================================
// ROUND 06 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
// Gruta do Maquiné: limestone drips, chamber drones, and bells
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete sources: stalactite drip and bell-like stalagmite tones
    SynthDef(\grutaDrip, { |freq=1200, amp=0.2, pan=0, rel=1.2, out=0|
        var exc, body, env, sig;
        env = EnvGen.ar(Env.perc(0.001, rel, 1, -6), doneAction: 2);
        exc = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.003)));
        body = Ringz.ar(exc, [freq, freq * 1.73, freq * 2.41], [rel * 0.5, rel * 0.3, rel * 0.2]).sum;
        sig = body * env * amp * 0.5;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\grutaBell, { |freq=440, amp=0.15, pan=0, rel=3, out=0|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.005, rel, 1, -5), doneAction: 2);
        mod = SinOsc.ar(freq * 2.71, 0, freq * 3 * EnvGen.kr(Env.perc(0.001, 0.8)));
        sig = SinOsc.ar(freq + mod) * env;
        sig = (sig + (SinOsc.ar(freq * 3.51) * env * 0.15)) * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // Continuous chamber drone, silent until faded in
    Ndef(\grutaDrone).fadeTime = 4;
    Ndef(\grutaDrone, { |amp=0, cut=300, drift=0.05|
        var lfo, tones, rumble, sig;
        lfo = LFNoise2.kr(drift).range(0.98, 1.02);
        tones = SinOsc.ar([55, 82.5, 110] * lfo, 0, [0.5, 0.3, 0.2]).sum;
        rumble = BPF.ar(PinkNoise.ar(0.5), cut, 0.08) * 6;
        sig = LPF.ar(tones + rumble, cut * 2).tanh * amp;
        Pan2.ar(sig, LFNoise1.kr(0.07).range(-0.4, 0.4));
    });

    // Master mix with reverb on slot 10
    Ndef(\grutaMix, { In.ar(~synthBus, 2) + Ndef(\grutaDrone).ar(2) });
    Ndef(\grutaMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25) };
    Ndef(\grutaMix).set(\wet10, 0.35);
    Ndef(\grutaMix).play;
    s.sync;

    // Pattern definitions
    Pbindef(\gutaDripSeq,
        \instrument, \grutaDrip,
        \dur, Pseq([0.75, 0.5, 1.25, 0.5, 0.25, 1.0, 0.75], inf),
        \freq, Pwrand([1200, 1500, 1800, 2400], [0.4, 0.3, 0.2, 0.1], inf),
        \amp, Pwhite(0.12, 0.22, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \rel, Pwhite(0.8, 1.8, inf),
        \out, ~synthBus
    );

    Pbindef(\gutaBellSeq,
        \instrument, \grutaBell,
        \dur, Pseq([2.5, 1.5, 3, 1], inf),
        \freq, Pseq([110, 146.83, 164.81, 130.81, 98] * 2, inf),
        \amp, 0.14,
        \pan, Pwhite(-0.5, 0.5, inf),
        \rel, Pwhite(2.0, 4.0, inf),
        \out, ~synthBus
    );

    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: Silêncio úmido, o drone da câmara emerge]".postln;
        Ndef(\grutaDrone).xset(\amp, 0.25);
        8.wait;

        "0:08 - [Cue 2: Gotejamento lento nas estalactites]".postln;
        Pbindef(\gutaDripSeq).play;
        4.do { |i| Ndef(\grutaDrone).xset(\cut, exprand(200, 500)); 2.wait; };

        "0:16 - [Cue 3: Sinos de estalagmite, a ressonância se abre]".postln;
        Pbindef(\gutaBellSeq).play;
        4.do { |i| Ndef(\grutaDrone).xset(\cut, exprand(300, 900)); 4.wait; };

        "0:32 - [Cue 4: Limite intrínseco, a queda acelera até o extremo]".postln;
        Pbindef(\gutaDripSeq, \dur, Pseq([0.25, 0.125, 0.0625, 0.2], inf));
        4.do { |i| Ndef(\grutaDrone).xset(\cut, 2000 - (i * 300)); 2.wait; };

        "0:40 - [Cue 5: Assentamento, as gotas se rarefazem]".postln;
        Pbindef(\gutaDripSeq).stop;
        Pbindef(\gutaDripSeq, \dur, Pseq([0.75, 0.5, 1.25, 0.5, 0.25, 1.0, 0.75], inf));
        Ndef(\grutaDrone).xset(\cut, 180);
        8.wait;

        "0:48 - [Cue 6: Retorno, o gotejamento inicial revisita a abóbada]".postln;
        Pbindef(\gutaDripSeq).play;
        4.do { |i| Ndef(\grutaDrone).xset(\cut, exprand(220, 480)); 3.wait; };

        "1:00 - [Cue 7: Sinos rarefeitos sobre o drone]".postln;
        Pbindef(\gutaDripSeq).stop;
        4.do { |i| Ndef(\grutaDrone).xset(\drift, exprand(0.02, 0.2)); 4.wait; };

        "1:16 - [Cue 8: Extinção, o salão volta ao escuro]".postln;
        Ndef(\grutaDrone).xset(\amp, 0);
        4.wait;

        Pbindef(\gutaDripSeq).stop; Pbindef(\gutaDripSeq).clear;
        Pbindef(\gutaBellSeq).stop; Pbindef(\gutaBellSeq).clear;
        Ndef(\grutaDrone).clear(2);
        Ndef(\grutaMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 07 | MODE: DESIGN | FRAG #170
// STATUS: FALLBACK
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
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\subtractiveDesign).fadeTime = 1.5;
Ndef(\subtractiveDesign, {
    |freq=73.42, detune=0.026, sawMix=0.59, pulseMix=0.41,
     pw=0.43, pwmRate=1.36, pwmDepth=0.16,
     subAmp=0.25, noiseAmp=0.011,
     cutoff=1424.3, rq=0.48, hpf=68.5,
     filtEnvAmt=1879.0, lfoRate=2.78, lfoDepth=1063.1,
     atk=0.19, dec=0.27, sus=0.64, rls=0.43,
     pan=(-0.01), amp=0.23, t_trig=1|
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
    CombL.ar(in, 0.5, 0.125, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.31);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.54, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.26);

Pbindef(\subtractiveDesignSeq,
    \dur, Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf),
    \freq, (73.42 * (2 ** (Prand([0, 2, 3, 7, 8], inf) / 12))),
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
}.value;
)


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #129
// STATUS: PASS
// PROMPT: O que não tem utilidade nenhuma é o que sustenta o mundo. Aprendi com os passarinhos a arte de desap...
// ============================================================
(
// rio sobre pedras lisas, lodo e silêncio da tarde
Ndef(\rioPedras).fadeTime = 3;
Ndef(\rioPedras, {
    |amp=0.16, swellRate=0.05, pan=0|
    var bed, swell, drops, sig;
    bed = PinkNoise.ar(0.6);
    bed = BPF.ar(bed, LFNoise2.kr(0.07).range(350, 1200), 0.45) * 5;
    swell = 0.55 + (0.45 * SinOsc.kr(swellRate));
    drops = Ringz.ar(Dust.ar(0.7) * 0.25, LFNoise1.kr(0.23).range(800, 2400), 0.09);
    sig = ((bed * swell) + drops).tanh;
    Pan2.ar(LeakDC.ar(sig), pan + SinOsc.kr(0.03, 0, 0.5), amp);
}).play;

Ndef(\rioPedras)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.5);
};
Ndef(\rioPedras).set(\wet11, 0.3);

// rã no lodo: salto, gota e anel de ondas
Ndef(\rana).fadeTime = 1;
Ndef(\rana, {
    |freq=260, dec=0.35, pan=(-0.3), amp=0.2, t_trig=1|
    var env, pitch, body, splash, sig;
    env = EnvGen.ar(Env.perc(0.004, dec, 1, -5), t_trig);
    pitch = EnvGen.ar(Env([1.6, 1], [0.09], \exp), t_trig);
    body = SinOsc.ar(freq * pitch) * env;
    splash = Ringz.ar(PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015), t_trig), freq * 3.7, 0.04) * 0.8;
    sig = (body + splash).tanh * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\rana)[10] = \filter -> { |in|
    CombL.ar(in, 0.3, 0.19, 2.2) * 0.6;
};
Ndef(\rana).set(\wet10, 0.35);

// pássaros que cantam sem nome: FM em razões inarmônicas
Ndef(\passaros).fadeTime = 1.5;
Ndef(\passaros, {
    |freq=1800, index=2.4, dec=0.3, pan=0.4, amp=0.12, t_trig=1|
    var env, mod, car, sig;
    env = EnvGen.ar(Env.perc(0.01, dec, 1, -4), t_trig);
    mod = SinOsc.ar(freq * 2.71) * (freq * index * 0.2) * env;
    car = SinOsc.ar(freq + mod);
    sig = car * env * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\passaros)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.8, 0.3);
};
Ndef(\passaros).set(\wet11, 0.35);

Pbindef(\ranaSeq,
    \dur, Pwrand([0.5, 1.5, 2.5, 4.0], [0.3, 0.3, 0.25, 0.15], inf),
    \freq, Pexprand(160, 340, inf),
    \dec, Pwhite(0.2, 0.55, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \t_trig, 1
);
Ndef(\rana).quant = 1;
Ndef(\rana)[1] = \set -> Pbindef(\ranaSeq);

Pbindef(\passarosSeq,
    \dur, Pwrand([0.25, 0.5, 1.0, 2.0], [0.3, 0.3, 0.25, 0.15], inf),
    \freq, Pn(Pgeom(1500, 1.12, 5), inf),
    \index, Pwhite(1.5, 3.5, inf),
    \dec, Pwhite(0.12, 0.35, inf),
    \pan, Pwhite(0.1, 0.9, inf),
    \t_trig, 1
);
Ndef(\passaros).quant = 1;
Ndef(\passaros)[1] = \set -> Pbindef(\passarosSeq);
)

// Ndef(\rana).xset(\dec, 0.8); // Ressonância longa | Revert: Ndef(\rana).xset(\dec, 0.35);
// Pbindef(\passarosSeq, \dur, 0.125); // Revoada rápida | Revert: Pbindef(\passarosSeq, \dur, 0.25);
// Ndef(\rioPedras).xset(\swellRate, 0.12); // Maré mais viva | Revert: Ndef(\rioPedras).xset(\swellRate, 0.05);
// Ndef(\rioPedras).set(\wet11, 0.6); // Mais espaço | Revert: Ndef(\rioPedras).set(\wet11, 0.3);
// Pbindef(\ranaSeq).stop; Ndef(\rana).clear(4); // Rollback da rã
// Ndef(\passaros).clear(4); Pbindef(\passarosSeq).stop; // Rollback dos pássaros


// ============================================================
// ROUND 09 | MODE: COMPOSE | FRAG #55
// STATUS: PASS
// PROMPT: Passava da meia-noite quando as matracas de madeira começaram a bater compassadas no calçamento de p...
// ============================================================
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // matraca de madeira no calçamento
    SynthDef(\penitMatraca, { |out=0, amp=0.3, pan=0, dec=0.12, freq=1400|
        var env, body, sig;
        env = EnvGen.ar(Env.perc(0.001, dec, 1, -6), doneAction: 2);
        body = BPF.ar(WhiteNoise.ar, freq, 0.08) * 12;
        body = body + (Ringz.ar(Impulse.ar(0), freq * 0.5, 0.03) * 0.5);
        sig = (body * env * amp).tanh;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // sino da Sé, parciais inarmônicos
    SynthDef(\penitSino, { |out=0, amp=0.25, pan=0, freq=98, dec=6|
        var env, exc, sig, freqs;
        env = EnvGen.ar(Env.perc(0.002, dec, 1, -3), doneAction: 2);
        exc = Impulse.ar(0) * 0.5 + (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02)));
        freqs = [1, 2.0, 2.76, 3.9, 5.4] * freq;
        sig = DynKlank.ar(Ref([freqs, [1, 0.6, 0.45, 0.3, 0.2], [1.0, 0.8, 0.6, 0.5, 0.4]]), exc, 1, 0, 2.5);
        sig = (sig * env * amp).tanh;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // estalos das tochas de cera
    SynthDef(\penitCera, { |out=0, amp=0.2, pan=0, dec=0.08|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, dec, 1, -8), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, LFNoise1.kr(40).range(1800, 4500), 0.2) * 8 * env;
        Out.ar(~synthBus.index ? out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // vento da serra
    Ndef(\penitVento).fadeTime = 4;
    Ndef(\penitVento, { |amp=0, cut=400|
        var gust, sig;
        gust = LFNoise2.kr(0.15).range(0.2, 1.0);
        sig = BPF.ar(BrownNoise.ar, LFNoise1.kr(0.2).range(cut * 0.7, cut * 1.4), 0.4) * 6 * gust;
        ([sig, sig * 0.8 + DelayN.ar(sig, 0.03, 0.011)]).tanh * amp;
    }).play;

    // brasa grave das tochas
    Ndef(\penitBrasa).fadeTime = 3;
    Ndef(\penitBrasa, { |amp=0|
        var hum, crackle, sig;
        hum = (SinOsc.ar([55, 55.4]) * 0.5) + (SinOsc.ar(110) * 0.15);
        crackle = Crackle.ar(1.9) * 0.1;
        sig = (hum * LFNoise1.kr(0.5).range(0.6, 1)) + crackle;
        (sig * amp).tanh;
    }).play;

    Ndef(\masterMix, { In.ar(~synthBus, 2) + Ndef.ar(\penitVento, 2) + Ndef.ar(\penitBrasa, 2) });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.3);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\penitMatracaSeq,
        \instrument, \penitMatraca,
        \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 1.0], inf),
        \freq, Pwhite(1100, 1800, inf),
        \dec, Pwhite(0.08, 0.14, inf),
        \amp, Pwhite(0.2, 0.35, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    Pbindef(\penitCeraSeq,
        \instrument, \penitCera,
        \dur, Pexprand(0.05, 0.6, inf),
        \amp, Pwhite(0.05, 0.2, inf),
        \pan, Pwhite(-0.9, 0.9, inf),
        \dec, Pwhite(0.03, 0.12, inf),
        \out, ~synthBus
    );

    Pbindef(\penitSinoSeq,
        \instrument, \penitSino,
        \dur, Pn(4.0, inf),
        \freq, Pn(98, inf),
        \dec, Pn(6, inf),
        \amp, Pn(0.3, inf),
        \pan, Pn(0, inf),
        \out, ~synthBus
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Vento da serra e brasa]".postln;
        Ndef(\penitVento).xset(\amp, 0.25);
        Ndef(\penitBrasa).xset(\amp, 0.08);
        4.wait;

        "0:04 - [Cue 2: Matracas no pé-de-moleque]".postln;
        Pbindef(\penitMatracaSeq).play;
        8.wait;

        "0:12 - [Cue 3: Tochas estalam, vento sobe]".postln;
        Pbindef(\penitCeraSeq).play;
        4.do { |i| Ndef(\penitVento).xset(\cut, 500 + (i * 300)); 3.wait; };

        "0:24 - [Cue 4: Dobre lento da Sé]".postln;
        Pbindef(\penitMatracaSeq).stop;
        Pbindef(\penitSinoSeq).play;
        4.do { |i| Ndef(\penitVento).xset(\cut, 1400 + (i * 100)); 4.wait; };

        "0:40 - [Cue 5: Limite intrínseco, cadência acelera]".postln;
        Pbindef(\penitMatracaSeq).play;
        Pbindef(\penitMatracaSeq, \dur, Pexprand(0.07, 0.3, inf));
        Ndef(\penitBrasa).xset(\amp, 0.14);
        4.do { |i| Ndef(\penitVento).xset(\cut, 2400 - (i * 250)); 4.wait; };

        "0:56 - [Cue 6: Assentamento, texturas frágeis]".postln;
        Pbindef(\penitMatracaSeq).stop;
        Pbindef(\penitCeraSeq).stop;
        Ndef(\penitVento).xset(\cut, 300);
        8.wait;

        "1:04 - [Cue 7: Retorno, flashback da primeira matraca]".postln;
        Pbindef(\penitMatracaSeq, \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 1.0], inf), \amp, Pwhite(0.12, 0.2, inf));
        Pbindef(\penitMatracaSeq).play;
        12.wait;

        "1:16 - [Cue 8: Resolução com o dobre]".postln;
        Pbindef(\penitMatracaSeq).stop;
        Pbindef(\penitSinoSeq).play;
        Ndef(\penitVento).xset(\amp, 0.18, \cut, 450);
        Ndef(\penitBrasa).xset(\amp, 0.1);
        8.wait;

        "1:24 - [Cue 9: Extrinsic: corte composto]".postln;
        Ndef(\penitVento).xset(\amp, 0);
        Ndef(\penitBrasa).xset(\amp, 0);
        6.wait;

        Pbindef(\penitMatracaSeq).stop; Pbindef(\penitMatracaSeq).clear;
        Pbindef(\penitCeraSeq).stop; Pbindef(\penitCeraSeq).clear;
        Pbindef(\penitSinoSeq).stop; Pbindef(\penitSinoSeq).clear;
        Ndef(\penitVento).clear(4);
        Ndef(\penitBrasa).clear(4);
        Ndef(\masterMix).clear(4);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 10 | MODE: APPEND | FRAG #155
// STATUS: PASS
// PROMPT: Eduardo subiu correndo os degraus de pedra da biblioteca pública de Belo Horizonte com o coração bat...
// ============================================================
(
// ADD_INSTRUMENT: passos na escadaria de pedra (subida correndo)
Ndef(\passosPedra, { |t_trig=0, freq=1800, amp=0.3, pan=0, dec=0.05|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.001, dec), t_trig);
    sig = BPF.ar(PinkNoise.ar, freq, 0.15) * 10 * env;
    Pan2.ar(sig * amp, pan);
});

Pbindef(\passosSeq,
    \dur, Pseq([0.5, 0.02, 0.45, 0.02, 0.4, 0.02, 0.36, 0.02, 0.32, 0.02, 0.3, 0.02, 0.28, 0.02, 0.26, 0.02, 0.25, 0.02, 0.6, 0.02], 1),
    \t_trig, Pseq([1, 0], inf),
    \freq, Pwhite(1300, 2200, inf),
    \pan, Pseq([(-0.35), 0.35], inf),
    \amp, Pwhite(0.2, 0.35, inf)
);
Ndef(\passosPedra)[1] = \set -> Pbindef(\passosSeq);
Ndef(\passosPedra).play;

// ADD_INSTRUMENT: coração de Eduardo (batidas aceleradas)
Ndef(\coracaoEduardo, { |t_trig=0, freq=58, amp=0.25|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.004, 0.2, 1, -5), t_trig);
    sig = (SinOsc.ar(freq) * env) + (LPF.ar(WhiteNoise.ar, 120) * env * 0.3);
    Pan2.ar((sig * amp).tanh, 0);
});

Pbindef(\coracaoSeq,
    \dur, Pseq([0.9, 0.02, 0.75, 0.02, 0.62, 0.02, 0.52, 0.02, 0.44, 0.02, 0.38, 0.02, 0.33, 0.02, 0.3, 0.02, 0.28, 0.02, 0.27, 0.02], inf),
    \t_trig, Pseq([1, 0], inf),
    \amp, Pwhite(0.2, 0.3, inf)
);
Ndef(\coracaoEduardo)[1] = \set -> Pbindef(\coracaoSeq);
Ndef(\coracaoEduardo).play;

// ADD_INSTRUMENT: porta de carvalho rangendo (dispara após a subida)
Ndef(\portaCarvalho, { |t_trig=0, amp=0.12, pan=(-0.4)|
    var env, creak, sig;
    env = EnvGen.ar(Env.perc(0.3, 2.2, 1, -2), t_trig);
    creak = BPF.ar(BrownNoise.ar, XLine.kr(120, 260, 2.6), 0.04) * 25;
    sig = (creak * env) + (LFSaw.ar(55) * 0.02 * env);
    Pan2.ar(sig * amp, pan);
});

Pbindef(\portaSeq,
    \dur, Pseq([4.0, 0.02, 3.0, 0.02], 1),
    \t_trig, Pseq([0, 1, 0, 0], 1),
    \amp, Pwhite(0.1, 0.14, inf)
);
Ndef(\portaCarvalho)[1] = \set -> Pbindef(\portaSeq);
Ndef(\portaCarvalho).play;

// ADD_INSTRUMENT: sineta da porta (tilintar suave no salão silencioso)
Ndef(\sinetaBiblio, { |t_trig=0, amp=0.12, pan=0.25|
    var env, exc, sig;
    env = EnvGen.ar(Env.perc(0.001, 2.5), t_trig);
    exc = WhiteNoise.ar * 0.02 * EnvGen.ar(Env.perc(0.001, 0.01), t_trig);
    sig = Klank.ar(`[[2093, 2794, 3136, 4186], [1, 0.5, 0.35, 0.2], [2.5, 1.8, 1.2, 0.9]], exc);
    Pan2.ar(sig * env * amp, pan);
});

Pbindef(\sinetaSeq,
    \dur, Pseq([7.0, 0.02, 0.15, 0.02, 0.1, 0.02, 3.0], 1),
    \t_trig, Pseq([0, 1, 0, 1, 0, 0, 0], 1)
);
Ndef(\sinetaBiblio)[1] = \set -> Pbindef(\sinetaSeq);

// ADD_EFFECTS: reverberação de salão (inicialmente silenciosa)
Ndef(\sinetaBiblio)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.4);
};
Ndef(\sinetaBiblio).set(\wet10, 0);
// Ndef(\sinetaBiblio).set(\wet10, 0); // Rollback: disable this effect
Ndef(\sinetaBiblio).play;

// Sequências de porta e sineta iniciam com o ritmo dos passos
Pbindef(\coracaoSeq).play;
Pbindef(\passosSeq).play;
Pbindef(\portaSeq).play;
Pbindef(\sinetaSeq).play;
)

// Rollback: remove these instruments
// Pbindef(\passosSeq).stop; Ndef(\passosPedra).fadeTime = 2; Ndef(\passosPedra).clear(2);
// Pbindef(\coracaoSeq).stop; Ndef(\coracaoEduardo).fadeTime = 2; Ndef(\coracaoEduardo).clear(2);
// Pbindef(\portaSeq).stop; Ndef(\portaCarvalho).fadeTime = 2; Ndef(\portaCarvalho).clear(2);
// Pbindef(\sinetaSeq).stop; Ndef(\sinetaBiblio).fadeTime = 2; Ndef(\sinetaBiblio).clear(2);

