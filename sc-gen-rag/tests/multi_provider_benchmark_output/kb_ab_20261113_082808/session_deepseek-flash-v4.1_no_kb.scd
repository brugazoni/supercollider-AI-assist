// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-13T11:37:58.098969+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Marriage drone
Ndef(\marriage, { |freq=55, amp=0.1, pan=0| 
    var lfo = SinOsc.kr(0.1).range(100, 300);
    var sig = SinOsc.ar(freq * [0.99, 1.01], 0, 0.5).sum;
    sig = sig + SinOsc.ar(freq*2, 0, 0.2);
    sig = LPF.ar(sig, lfo);
    Pan2.ar(sig * amp, pan);
}).play;
// Rollback: Ndef(\marriage).fadeTime = 2; Ndef(\marriage).clear(2);

// Argument instrument
Ndef(\argument, { |freq=440, amp=0.3, pan=0, t_trig=0, cutoff=2000|
    var env = EnvGen.ar(Env.perc(0.001, 0.2), t_trig);
    var sig = Pulse.ar(freq, 0.5) * 0.5;
    sig = RLPF.ar(sig, cutoff, 0.1);
    Pan2.ar(sig * env * amp, pan);
}).play;
// Rollback: Pbindef(\argSeq).stop; Ndef(\argument).fadeTime = 2; Ndef(\argument).clear(2);

// Argument sequence
Pbindef(\argSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5], inf),
    \midinote, Pseq([60, 63, 67, 70], inf),
    \t_trig, 1,
    \amp, Pwhite(0.1, 0.4, inf),
    \cutoff, Pseq([1000, 2000, 4000, 800], inf),
    \pan, Pseq([-0.5, 0.5], inf)
);
Ndef(\argument)[1] = \set -> Pbindef(\argSeq);

// Antarctic storm
Ndef(\antarctic, { |amp=0.1, pan=0, cutoff=8000, rq=0.5|
    var lfo = SinOsc.kr(0.05).range(0.5, 1.5);
    var sig = WhiteNoise.ar(0.5);
    sig = BPF.ar(sig, cutoff * lfo, rq);
    sig = sig * 10;
    Pan2.ar(sig * amp, pan);
}).play;
// Rollback: Ndef(\antarctic).fadeTime = 2; Ndef(\antarctic).clear(2);

// Reverb on antarctic
Ndef(\antarctic)[10] = \filter -> { |in| FreeVerb.ar(in, 0.8, 0.9, 0.5) };
Ndef(\antarctic).set(\wet10, 0.3);
// Rollback: Ndef(\antarctic).set(\wet10, 0); // Rollback: disable reverb

// Waiter frozen
Ndef(\waiter, { |freq=1200, amp=0.2, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.01, 3.0), t_trig);
    var sig = SinOsc.ar(freq) * 0.5;
    sig = sig + SinOsc.ar(freq*2.01, 0, 0.2);
    Pan2.ar(sig * env * amp, pan);
}).play;
// Rollback: Pbindef(\waiterSeq).stop; Ndef(\waiter).fadeTime = 2; Ndef(\waiter).clear(2);

// Waiter sequence
Pbindef(\waiterSeq,
    \dur, Pseq([4, 6, 5], inf),
    \midinote, Pseq([84, 88, 91], inf),
    \t_trig, 1,
    \amp, 0.2
);
Ndef(\waiter)[1] = \set -> Pbindef(\waiterSeq);

// Delay on argument
Ndef(\argument)[10] = \filter -> { |in| CombC.ar(in, 0.5, 0.25, 2) };
Ndef(\argument).set(\wet10, 0.2);
// Rollback: Ndef(\argument).set(\wet10, 0); // Rollback: disable delay
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

    // Escapement click — brass tick
    SynthDef(\clockTick, {
        |out=0, freq=800, amp=0.3, pan=0, dur=0.08|
        var env, click, res;
        env = EnvGen.ar(Env.perc(0.0005, dur, 1, -6), doneAction: 2);
        click = Impulse.ar(0) + WhiteNoise.ar(0.8);
        res = BPF.ar(click, freq, 0.15) * 12;
        res = res + SinOsc.ar(freq * 0.5, 0, 0.3);
        Out.ar(out, Pan2.ar(res * env * amp, pan));
    }).add;

    // Pocket chronometer — tiny high tick
    SynthDef(\pocketTick, {
        |out=0, freq=2400, amp=0.15, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0003, 0.03, 1, -8), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar(0.9), freq, 0.25) * 15;
        sig = sig + SinOsc.ar(freq, 0, 0.15);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // French carillon — inharmonic modal bell
    SynthDef(\carillon, {
        |out=0, freq=220, amp=0.3, pan=0, decay=4|
        var env, sig, exc, partials;
        env = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);
        exc = Impulse.ar(0) + PinkNoise.ar(0.4);
        partials = [1, 2.01, 2.71, 4.15, 5.43, 7.09];
        sig = DynKlank.ar(Ref([partials * freq, [1, 0.7, 0.5, 0.35, 0.25, 0.15], [decay, decay*0.8, decay*0.6, decay*0.5, decay*0.4, decay*0.3]]), exc);
        sig = sig * 0.05;
        sig = LPF.ar(sig, 6000);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Brass gear grind — metallic scrape
    SynthDef(\gearGrind, {
        |out=0, freq=400, amp=0.2, pan=0, dur=0.3|
        var env, sig, fm;
        env = EnvGen.ar(Env.perc(0.01, dur, 1, -3), doneAction: 2);
        fm = SinOsc.ar(freq * 1.5, 0, freq * 2);
        sig = SinOsc.ar(freq + fm) * 0.5;
        sig = sig + BPF.ar(WhiteNoise.ar(0.5), freq * 3, 0.1) * 3;
        sig = sig.fold2(1.0) * 0.5;
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // Breathing of time — slow inhale/exhale drone
    Ndef(\breathOfTime, {
        |amp=0, cutoff=1200, breathRate=0.08|
        var breath, sig, sub;
        breath = SinOsc.kr(breathRate).range(0.3, 1.0);
        sig = BPF.ar(PinkNoise.ar(0.5), cutoff * breath, 0.4) * 8;
        sub = SinOsc.ar(55, 0, 0.3) + SinOsc.ar(110, 0, 0.15);
        sig = sig + sub;
        sig = LPF.ar(sig, 2400);
        Pan2.ar(sig * amp, 0);
    }).play;

    // Pendulum beating — detuned sines
    Ndef(\pendulumSwell, {
        |amp=0, freq=110|
        var sig, lfo;
        lfo = SinOsc.kr(0.15).range(0.5, 1.5);
        sig = SinOsc.ar(freq * [0.99, 1.0, 1.01], 0, 0.3).sum;
        sig = sig + SinOsc.ar(freq * 2 * [0.995, 1.005], 0, 0.1).sum;
        sig = LPF.ar(sig, 800 * lfo);
        Pan2.ar(sig * amp, 0);
    }).play;

    s.sync;

    // Master mix
    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2);
        sig = sig + Ndef.ar(\breathOfTime, 2);
        sig = sig + Ndef.ar(\pendulumSwell, 2);
        sig;
    }).play;

    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.85, 0.9, 0.35) };
    s.sync;
    Ndef(\masterMix).set(\wet10, 0.0);

    s.sync;

    Tdef(\masterScore, {
        var tickR, pocketR, carR, gearR, finalR;
        0.5.wait;

        "0:00 - [Cue 1: workshop tone]".postln;
        Ndef(\breathOfTime).fadeTime = 4;
        Ndef(\breathOfTime).xset(\amp, 0.15, \cutoff, 800);
        Ndef(\masterMix).set(\wet10, 0.2);
        6.do { |i| Ndef(\breathOfTime).xset(\cutoff, exprand(400, 1600)); 2.wait; };

        "0:13 - [Cue 2: first ticks]".postln;
        tickR = Routine({
            inf.do {
                Synth(\clockTick, [\out, ~synthBus, \freq, exprand(400, 1200), \amp, rrand(0.15, 0.35), \pan, rrand(-0.7, 0.7), \dur, rrand(0.05, 0.12)]);
                [0.5, 0.75, 1.0, 1.25, 1.5].choose.wait;
            }
        }).play;
        8.wait;

        "0:21 - [Cue 3: pocket chronometers]".postln;
        pocketR = Routine({
            inf.do {
                Synth(\pocketTick, [\out, ~synthBus, \freq, exprand(1800, 3200), \amp, rrand(0.08, 0.18), \pan, rrand(-0.9, 0.9)]);
                [0.25, 0.5, 0.75].choose.wait;
            }
        }).play;
        8.wait;

        "0:29 - [Cue 4: carillons out of phase]".postln;
        carR = Routine({
            var notes = [220, 246.94, 261.63, 293.66, 329.63, 349.23];
            inf.do {
                Synth(\carillon, [\out, ~synthBus, \freq, notes.choose * [1, 0.5, 2].choose, \amp, rrand(0.15, 0.3), \pan, rrand(-0.8, 0.8), \decay, rrand(2.5, 5)]);
                rrand(1.5, 3.5).wait;
            }
        }).play;
        10.wait;

        "0:39 - [Cue 5: dense ticking swarm]".postln;
        tickR.stop;
        tickR = Routine({
            inf.do {
                Synth(\clockTick, [\out, ~synthBus, \freq, exprand(300, 1500), \amp, rrand(0.1, 0.25), \pan, rrand(-0.9, 0.9), \dur, rrand(0.04, 0.1)]);
                [0.15, 0.2, 0.25, 0.3].choose.wait;
            }
        }).play;
        Ndef(\pendulumSwell).fadeTime = 3;
        Ndef(\pendulumSwell).xset(\amp, 0.2, \freq, 110);
        8.do { |i| Ndef(\pendulumSwell).xset(\freq, [110, 138.59, 164.81, 220].choose); 2.wait; };

        "0:55 - [Cue 6: brass gears grind]".postln;
        gearR = Routine({
            inf.do {
                Synth(\gearGrind, [\out, ~synthBus, \freq, exprand(200, 800), \amp, rrand(0.08, 0.2), \pan, rrand(-0.7, 0.7), \dur, rrand(0.15, 0.4)]);
                rrand(0.8, 2.0).wait;
            }
        }).play;
        10.wait;

        "1:05 - [Cue 7: breathing of time swells]".postln;
        Ndef(\breathOfTime).xset(\amp, 0.28, \cutoff, 1400);
        Ndef(\masterMix).set(\wet10, 0.45);
        6.do { |i| Ndef(\breathOfTime).xset(\cutoff, exprand(600, 2600)); 2.wait; };

        "1:17 - [Cue 8: intrinsic limit — density peak]".postln;
        tickR.stop;
        tickR = Routine({
            inf.do {
                Synth(\clockTick, [\out, ~synthBus, \freq, exprand(200, 2000), \amp, rrand(0.08, 0.2), \pan, rrand(-1, 1), \dur, rrand(0.03, 0.08)]);
                [0.08, 0.1, 0.12, 0.15].choose.wait;
            }
        }).play;
        8.wait;

        "1:25 - [Cue 9: settling — flashback to single clock]".postln;
        tickR.stop; pocketR.stop; carR.stop; gearR.stop;
        Ndef(\pendulumSwell).xset(\amp, 0.0);
        Ndef(\breathOfTime).xset(\amp, 0.08, \cutoff, 500);
        Ndef(\masterMix).set(\wet10, 0.3);
        2.wait;
        finalR = Routine({
            inf.do {
                Synth(\clockTick, [\out, ~synthBus, \freq, 700, \amp, 0.3, \pan, 0, \dur, 0.1]);
                1.0.wait;
            }
        }).play;
        8.wait;

        "1:35 - [Cue 10: final carillon]".postln;
        Synth(\carillon, [\out, ~synthBus, \freq, 220, \amp, 0.35, \pan, 0, \decay, 6]);
        3.wait;
        Synth(\carillon, [\out, ~synthBus, \freq, 164.81, \amp, 0.3, \pan, 0, \decay, 7]);
        5.wait;

        "1:43 - [Cue 11: fade]".postln;
        finalR.stop;
        Ndef(\breathOfTime).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.5);
        4.wait;

        "Score Complete.".postln;
        Ndef(\breathOfTime).clear(3);
        Ndef(\pendulumSwell).clear(3);
        Ndef(\masterMix).clear(3);
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
    |freq=55.0, detune=0.0136, sawMix=0.39, pulseMix=0.61,
     pw=0.81, pwmRate=2.13, pwmDepth=0.11,
     subAmp=0.34, noiseAmp=0.059,
     cutoff=2723.6, rq=0.49, hpf=110.7,
     filtEnvAmt=2939.3, lfoRate=2.04, lfoDepth=963.0,
     atk=0.078, dec=0.35, sus=0.75, rls=0.99,
     pan=(0.23), amp=0.31, t_trig=1|
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
    CombL.ar(in, 0.5, 0.375, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.26);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.68, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.43);

Pbindef(\subtractiveDesignSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
    \freq, (55.0 * (2 ** (Prand([0, 2, 4, 7, 9], inf) / 12))),
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
// --- CONGADA: gungas de lata, tambores de congo, sinos do rosário ---
Ndef(\gungas).fadeTime = 2;
Ndef(\gungas, {
    |t_trig=1, freq=2400, amp=0.18, pan=(-0.3), ring=0.35|
    var exc, metal, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.0005, 0.018) * (PinkNoise.ar * 0.6 + 0.4);
    metal = Ringz.ar(exc, freq * [1, 1.47, 2.13, 2.78, 3.61], ring, [1, 0.7, 0.5, 0.35, 0.22]).sum;
    metal = HPF.ar(metal, 900);
    metal = (metal * 1.2).tanh;
    sig = Pan2.ar(metal, pan) * amp;
    LeakDC.ar(sig);
}).play;
Ndef(\gungas)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.6, 0.4); };
Ndef(\gungas).set(\wet10, 0.28);

Ndef(\congo).fadeTime = 2;
Ndef(\congo, {
    |t_trig=1, freq=110, amp=0.22, pan=0.0, decay=0.35, pitch=1.0|
    var exc, body, sub, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.002, decay) * (PinkNoise.ar * 0.7 + 0.5);
    body = Ringz.ar(exc, freq * [1, 1.59, 2.14, 2.9] * pitch,
        [0.14, 0.26, 0.38, 0.55], [0.9, 0.5, 0.3, 0.18]).sum;
    sub = SinOsc.ar(freq * 0.5) * Decay2.ar(K2A.ar(t_trig), 0.005, 0.28) * 0.45;
    body = LPF.ar(body + sub, 1800);
    sig = Pan2.ar(body, pan) * amp;
    (sig * 1.3).tanh;
}).play;
Ndef(\congo)[10] = \filter -> { |in| CombL.ar(in, 0.4, 0.18, 1.2); };
Ndef(\congo).set(\wet10, 0.18);

Ndef(\rosario).fadeTime = 3;
Ndef(\rosario, {
    |t_trig=1, freq=880, amp=0.12, pan=0.4, decay=1.2|
    var exc, mod, bell, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.001, 0.008);
    mod = SinOsc.ar(freq * 3.51) * freq * 0.8;
    bell = SinOsc.ar(freq + mod) * exc;
    bell = bell + (Ringz.ar(exc, freq * [1, 2.76, 5.4, 8.93],
        decay * [1, 0.7, 0.5, 0.3], [1, 0.5, 0.3, 0.15]).sum * 0.5);
    sig = Pan2.ar(bell, pan) * amp;
    LeakDC.ar(sig);
}).play;
Ndef(\rosario)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.5); };
Ndef(\rosario).set(\wet10, 0.42);

// --- Sequências: passos cadenciados e toques de congo ---
Pbindef(\gungasSeq,
    \dur, Pwrand([0.125, 0.25, 0.375], [0.55, 0.35, 0.1], inf),
    \freq, Pexprand(1800, 3200, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pwhite(0.08, 0.2, inf),
    \t_trig, 1
);
Ndef(\gungas).quant = 1;
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);

Pbindef(\congoSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.75], inf),
    \freq, Pseq([110, 110, 146.83, 110, 164.81, 130.81], inf),
    \pitch, Pwrand([1.0, 1.0, 0.75, 1.5], [0.5, 0.3, 0.12, 0.08], inf),
    \amp, Pwhite(0.16, 0.26, inf),
    \t_trig, 1
);
Ndef(\congo).quant = 1;
Ndef(\congo)[1] = \set -> Pbindef(\congoSeq);

Pbindef(\rosarioSeq,
    \dur, Pseq([0.75, 0.75, 0.5, 1.0, 0.5, 0.5], inf),
    \freq, Pn(Pgeom(660, 1.122, 8), inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \amp, Pwhite(0.07, 0.14, inf),
    \t_trig, 1
);
Ndef(\rosario).quant = 1;
Ndef(\rosario)[1] = \set -> Pbindef(\rosarioSeq);
)

// Ndef(\congo).xset(\amp, 0.32); // Louder drums | Revert: Ndef(\congo).xset(\amp, 0.22);
// Pbindef(\gungasSeq, \dur, 0.0625); // Double-time gungas | Revert: Pbindef(\gungasSeq, \dur, Pwrand([0.125,0.25,0.375],[0.55,0.35,0.1],inf));
// Ndef(\rosario).xset(\wet10, 0.7); // More reverb on bells | Revert: Ndef(\rosario).xset(\wet10, 0.42);
// Pbindef(\congoSeq).stop; Ndef(\congo).fadeTime = 4; Ndef(\congo).clear(4); // Rollback congo
// Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 4; Ndef(\gungas).clear(4); // Rollback gungas
// Pbindef(\rosarioSeq).stop; Ndef(\rosario).fadeTime = 4; Ndef(\rosario).clear(4); // Rollback rosario

