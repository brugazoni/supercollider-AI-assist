// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek V4 Pro
// Model ID: openrouter:deepseek/deepseek-v4-pro
// Date: 2026-11-13T13:12:23.277721+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// --- Husband's Instrument: Percussive map-folding explanation ---
// The sound of precise, almost obsessive articulation.
// Initially silent (amp=0) – the 27-year silence before the explanation.
Ndef(\husband, { |freq=800, amp=0, pan=0.3, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.001, 0.08, curve: -4), t_trig);
    var sig = BPF.ar(WhiteNoise.ar, freq, 0.05) * env * amp;
    Pan2.ar(sig, pan);
}).play;

// Sequence: the methodical “folding” steps, currently muted.
Pbindef(\husbandSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \freq, Pseq([800, 1200, 600, 1000, 1400, 800], inf),
    \amp, 0,   // silence – the argument has not yet begun
    \t_trig, 1,
    \pan, Pwhite(-0.2, 0.5, inf)
);

// Inject sequence into JITLib slot (native routing, no \instrument needed)
Ndef(\husband)[1] = \set -> Pbindef(\husbandSeq);

// Rollback: remove husband instrument
// Pbindef(\husbandSeq).stop; Ndef(\husband).fadeTime = 2; Ndef(\husband).clear(2); // Rollback

// --- Wife's Instrument: The weight of silence, an Antarctic storm brewing ---
// A low drone that slowly breathes, carrying the tension.
Ndef(\wife, { |amp=0.05, cutoff=200, rq=0.4, pan=(-0.8)|
    var sub = SinOsc.ar(30, 0, 0.6);  // tectonic rumble
    var mid = SinOsc.ar(55, 0, 0.2) + SinOsc.ar(55*2, 0, 0.1) + SinOsc.ar(55*3, 0, 0.05);
    var sig = sub + mid;
    sig = RLPF.ar(sig, cutoff + SinOsc.kr(0.03, 0, 50), rq); // slow filter creep
    Pan2.ar(sig * amp, pan);
}).play;

// Rollback: remove wife instrument
// Ndef(\wife).fadeTime = 3; Ndef(\wife).clear(3); // Rollback
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockDurBase = 1.0; // 60 BPM
    ~enableRecording = false;
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

    // Discrete SynthDefs
    SynthDef(\tick, { |out=0, freq=3000, amp=0.5, pan=0|
        var sig = Decay2.ar(Impulse.ar(0), 0.0003, 0.02);
        sig = BPF.ar(sig, freq, 0.1) * amp;
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);
    }).add;

    SynthDef(\carrilhao, { |out=0, amp=0.3, pan=0, freq=1200, decay=3, t_trig=1|
        var exciter = EnvGen.ar(Env.perc(0.001, 0.02), t_trig) * WhiteNoise.ar(0.3);
        var sig = DynKlank.ar(`[
            [freq*1, freq*2.76, freq*5.4, freq*8.9],
            [1, 0.7, 0.5, 0.3],
            [0.5, 0.7, 0.9, 1.2]
        ], exciter, decayscale: decay);
        sig = sig * amp * EnvGen.kr(Env.linen(0.01, decay, 0.1), doneAction:2);
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);
    }).add;
    s.sync;

    // Continuous Ndefs
    Ndef(\breath, { |amp=0, pan=0|
        var freq = 55;
        var mod = SinOsc.kr(0.1, 0, 0.5, 0.5);
        var sig = SinOsc.ar(freq) * mod;
        sig = sig * amp;
        Pan2.ar(sig, pan);
    }).play;
    Ndef(\breath).fadeTime = 4;

    Ndef(\masterMix, {
        var in = In.ar(~synthBus, 2) + Ndef.ar(\breath, 2);
        var verb = FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25);
        var wet = (in * (1 - \wet10.kr(0.3))) + (verb * \wet10.kr(0.3));
        wet;
    }).play;
    s.sync;

    // Pbindefs for clock lines (initially silent)
    Pbindef(\clock1, \instrument, \tick, \dur, 1, \freq, 3000, \amp, Pseq([0], inf), \pan, 0, \out, ~synthBus).play;
    Pbindef(\clock2, \instrument, \tick, \dur, 1.034, \freq, 2800, \amp, Pseq([0], inf), \pan, -0.3, \out, ~synthBus).play;
    Pbindef(\clock3, \instrument, \tick, \dur, 0.967, \freq, 3200, \amp, Pseq([0], inf), \pan, 0.4, \out, ~synthBus).play;
    Pbindef(\clock4, \instrument, \tick, \dur, 1.07, \freq, 2600, \amp, Pseq([0], inf), \pan, -0.6, \out, ~synthBus).play;
    Pbindef(\clock5, \instrument, \tick, \dur, 0.93, \freq, 3400, \amp, Pseq([0], inf), \pan, 0.7, \out, ~synthBus).play;
    Pbindef(\clock6, \instrument, \tick, \dur, 1.12, \freq, 2500, \amp, Pseq([0], inf), \pan, -0.8, \out, ~synthBus).play;

    Pbindef(\carr1, \instrument, \carrilhao, \dur, Pwhite(3, 6), \freq, Pwhite(800, 1600), \amp, Pseq([0], inf), \pan, Pwhite(-0.5, 0.5), \out, ~synthBus).play;
    Pbindef(\carr2, \instrument, \carrilhao, \dur, Pwhite(4, 8), \freq, Pwhite(600, 1200), \amp, Pseq([0], inf), \pan, Pwhite(-0.5, 0.5), \out, ~synthBus).play;
    s.sync;

    // Master timeline
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - Sparse ticks, breath fade in".postln;
        Ndef(\breath).xset(\amp, 0.15);
        Pbindef(\clock1).set(\amp, 0.12);
        4.wait;
        Pbindef(\clock2).set(\amp, 0.1);
        3.wait;
        Pbindef(\clock3).set(\amp, 0.08);
        3.wait;

        "0:10 - Add more clocks and first carillon".postln;
        Pbindef(\clock4).set(\amp, 0.1);
        Pbindef(\carr1).set(\amp, 0.25);
        5.wait;
        Pbindef(\clock5).set(\amp, 0.09);
        3.wait;
        Pbindef(\clock6).set(\amp, 0.07);
        4.wait;

        "0:25 - Full polyrhythmic swarm".postln;
        Pbindef(\carr2).set(\amp, 0.2);
        // Active loop: modulate tick frequencies slightly
        5.do { |i|
            Pbindef(\clock1).set(\freq, rrand(2900, 3100));
            Pbindef(\clock3).set(\freq, rrand(3100, 3300));
            2.wait;
        };
        4.wait;

        "0:45 - Climax density, then settling".postln;
        Ndef(\breath).xset(\amp, 0.3);
        Pbindef(\carr1).set(\dur, Pwhite(1, 3)); // faster chimes
        6.wait;

        // Abrupt drop: stop all clocks except clock1, fade carillons
        "1:00 - Settling: the watchmaker closes eyes".postln;
        Pbindef(\clock2).stop; Pbindef(\clock2).clear;
        Pbindef(\clock3).stop; Pbindef(\clock3).clear;
        Pbindef(\clock4).stop; Pbindef(\clock4).clear;
        Pbindef(\clock5).stop; Pbindef(\clock5).clear;
        Pbindef(\clock6).stop; Pbindef(\clock6).clear;
        Pbindef(\carr1).set(\amp, 0);
        Pbindef(\carr2).set(\amp, 0);
        Pbindef(\clock1).set(\amp, 0.08); // lone tick
        Ndef(\breath).xset(\amp, 0.4);
        8.wait;

        // Reintroduce a few clocks in near-sync, breathing dominates
        "1:10 - Resolution: clocks align slowly".postln;
        Pbindef(\clock2, \instrument, \tick, \dur, 1.01, \freq, 2800, \amp, 0.06, \pan, -0.2, \out, ~synthBus).play;
        Pbindef(\clock3, \instrument, \tick, \dur, 0.99, \freq, 3200, \amp, 0.07, \pan, 0.2, \out, ~synthBus).play;
        // Gradually slow the breathing rate
        4.do { |i|
            Ndef(\breath).xset(\amp, 0.4 - (i*0.05));
            3.wait;
        };
        // Final fade
        "1:30 - Fade out".postln;
        Pbindef(\clock1).set(\amp, 0.04);
        Pbindef(\clock2).set(\amp, 0.03);
        Pbindef(\clock3).set(\amp, 0.03);
        5.wait;
        Pbindef(\clock1).stop; Pbindef(\clock1).clear;
        Pbindef(\clock2).stop; Pbindef(\clock2).clear;
        Pbindef(\clock3).stop; Pbindef(\clock3).clear;
        Ndef(\breath).clear(3);
        3.wait;

        "Score Complete.".postln;
        // Cleanup only our own objects
        [\clock1, \clock2, \clock3, \clock4, \clock5, \clock6, \carr1, \carr2].do { |n| Pbindef(n).stop; Pbindef(n).clear; };
        Ndef(\breath).clear(2);
        Ndef(\masterMix).clear(2);
        Tdef(\masterScore).stop;
    }).play;
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
    |freq=130.81, detune=0.0304, sawMix=0.36, pulseMix=0.64,
     pw=0.64, pwmRate=2.73, pwmDepth=0.06,
     subAmp=0.27, noiseAmp=0.01,
     cutoff=1065.7, rq=0.51, hpf=98.9,
     filtEnvAmt=3295.8, lfoRate=0.57, lfoDepth=669.7,
     atk=0.03, dec=0.51, sus=0.76, rls=0.83,
     pan=(0.18), amp=0.32, t_trig=1|
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
Ndef(\subtractiveDesign).set(\wet10, 0.17);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.69, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.32);

Pbindef(\subtractiveDesignSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \freq, (130.81 * (2 ** (Prand([0, 2, 4, 7, 9], inf) / 12))),
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
// STATUS: FIXED
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada soundscape: gungas (tin-can ankle percussion), cadenced steps, and a religious chant
// Layer 1: Metallic gungas (tin cans) via DynKlank
Ndef(\congadaGungas).fadeTime = 2;
Ndef(\congadaGungas, {
    |t_trig=1, amp=0.18, cutoff=6000, rq=0.3, pan=0|
    var exciter, sig, panTrig;
    exciter = Decay2.ar(K2A.ar(t_trig), 0.001, 0.02) * PinkNoise.ar(0.6);
    panTrig = TRand.kr(-0.85, 0.85, t_trig);
    sig = DynKlank.ar(
        `[[800, 1200, 1800, 2400, 3200, 4500], nil, [0.08, 0.06, 0.05, 0.04, 0.03, 0.02]],
        exciter,
        freqscale: LFNoise2.kr(0.1).range(0.99, 1.01),
        decayscale: 0.3
    );
    sig = LPF.ar(sig, cutoff.clip(1000, 10000), rq.clip(0.1, 0.9));
    sig = Pan2.ar(sig, panTrig, amp);
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\congadaGungas).quant = 1;
Ndef(\congadaGungas)[10] = \filter -> { |in|
    FreeVerb.ar(in, 0.5, 0.6, 0.4);
};
Ndef(\congadaGungas).set(\wet10, 0.25);

Pbindef(\congadaGungasSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.25, 0.5], inf),
    \amp, Pexprand(0.1, 0.25, inf),
    \t_trig, 1
);
Ndef(\congadaGungas)[1] = \set -> Pbindef(\congadaGungasSeq);

// Layer 2: Cadenced footsteps (low drum pulse)
Ndef(\congadaSteps).fadeTime = 2;
Ndef(\congadaSteps, {
    |t_trig=1, freq=60, amp=0.22, pan=0|
    var env, body, noise, sig, panTrig;
    env = EnvGen.ar(Env.perc(0.001, 0.15), t_trig);
    body = SinOsc.ar(freq, 0, 0.5) + SinOsc.ar(freq/2, 0, 0.3);
    noise = BPF.ar(PinkNoise.ar * Decay2.ar(K2A.ar(t_trig), 0.005, 0.1), 200, 0.5);
    sig = (body + noise) * env;
    panTrig = TRand.kr(-0.7, 0.7, t_trig);
    sig = Pan2.ar(sig, panTrig, amp);
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\congadaSteps).quant = 1;
Ndef(\congadaSteps)[10] = \filter -> { |in|
    FreeVerb.ar(in, 0.4, 0.5, 0.3);
};
Ndef(\congadaSteps).set(\wet10, 0.15);

Pbindef(\congadaStepsSeq,
    \dur, Pseq([0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.5], inf),
    \freq, Pseq([60, 60, 60, 60, 65, 60], inf),
    \t_trig, 1
);
Ndef(\congadaSteps)[1] = \set -> Pbindef(\congadaStepsSeq);

// Layer 3: Religious chant (vocal formant-like additive synthesis)
Ndef(\congadaChant).fadeTime = 2;
Ndef(\congadaChant, {
    |t_trig=1, freq=261.63, sus=0.8, amp=0.2, pan=0|
    var env, sig, formantFreq, vowelMorph;
    env = EnvGen.ar(Env([0,1,1,0], [0.05, sus.max(0.05), 0.2]), t_trig);
    sig = SinOsc.ar(freq * [1, 2, 3, 4, 5], 0, [1, 0.5, 0.3, 0.2, 0.1]).sum;
    vowelMorph = SinOsc.kr(0.18).range(0,1);
    // Fix: convert constant formant frequencies to audio rate with DC.ar for SelectX.ar
    formantFreq = SelectX.ar(vowelMorph, [DC.ar([800, 1200]), DC.ar([500, 900])]);
    sig = BPF.ar(sig, formantFreq, 0.12).sum;
    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan, 1);
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\congadaChant).quant = 1;
Ndef(\congadaChant)[10] = \filter -> { |in|
    FreeVerb.ar(in, 0.6, 0.7, 0.5);
};
Ndef(\congadaChant).set(\wet10, 0.35);

Pbindef(\congadaChantSeq,
    \dur, Pseq([2, 2, 1, 1, 3], inf),
    \freq, Pseq(([60, 62, 64, 67, 69] + 12).midicps, inf), // pentatonic an octave higher
    \sus, Pkey(\dur) - 0.25,
    \t_trig, 1
);
Ndef(\congadaChant)[1] = \set -> Pbindef(\congadaChantSeq);

// Live coding tweaks (commented out)
// Ndef(\congadaGungas).xset(\cutoff, 3500); // Darken gungas | Revert: Ndef(\congadaGungas).xset(\cutoff, 6000);
// Pbindef(\congadaGungasSeq, \dur, Pseq([0.125, 0.125, 0.25], inf)); // Double-time gungas | Revert: Pbindef(\congadaGungasSeq, \dur, Pseq([0.25, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.25, 0.5], inf));
// Pbindef(\congadaStepsSeq).stop; Ndef(\congadaSteps).fadeTime = 3; Ndef(\congadaSteps).clear(3); // Remove steps
// Ndef(\congadaChant).xset(\amp, 0.3); // Louder chant | Revert: Ndef(\congadaChant).xset(\amp, 0.2);
)

