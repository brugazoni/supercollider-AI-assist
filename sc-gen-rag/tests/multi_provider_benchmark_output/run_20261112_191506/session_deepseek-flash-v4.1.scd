// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-12T22:33:01.945926+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ============================================================
// ADD_INSTRUMENT: marriageDrone - warm, stable pad representing 27 years of marriage
// ============================================================
Ndef(\marriageDrone, {
    |amp=0.2, cutoff=800, rq=0.5, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var sig = Splay.ar(Saw.ar([110, 110.5, 111, 109.5] * [1, 1.01, 0.99], 0.1));
    sig = RLPF.ar(sig, cutoff, rq);
    sig = sig * SinOsc.kr(0.1).range(0.7, 1);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, ampSmooth) } { Pan2.ar(sig, pan, ampSmooth) };
}).play;
// Pbindef(\marriageDroneSeq).stop; Ndef(\marriageDrone).fadeTime = 2; Ndef(\marriageDrone).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: mapFold - meticulous plucked FM sound representing map folding explanation
// ============================================================
Ndef(\mapFold, {
    |freq=440, amp=0.3, pan=0, t_trig=0, modIndex=2, modRatio=1.5, atk=0.001, rel=0.3|
    var ampSmooth = Lag.kr(amp, 0.1);
    var env = EnvGen.ar(Env.perc(atk, rel), K2A.ar(t_trig));
    var mod = SinOsc.ar(freq * modRatio) * (freq * modIndex) * env;
    var car = SinOsc.ar(freq + mod);
    car = car * env * ampSmooth;
    Pan2.ar(car, pan);
}).play;
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: antarcticStorm - noise-based tension bed representing impending storm
// ============================================================
Ndef(\antarcticStorm, {
    |amp=0.1, cutoff=1000, rq=0.1, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var noise = PinkNoise.ar(0.5);
    var sig = BPF.ar(noise, cutoff, rq) * 10;
    sig = sig * SinOsc.kr(0.05).range(0.5, 1);
    sig = sig + SinOsc.ar(40, 0, 0.1);
    Pan2.ar(sig * ampSmooth, pan);
}).play;
// Pbindef(\antarcticStormSeq).stop; Ndef(\antarcticStorm).fadeTime = 2; Ndef(\antarcticStorm).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: waiterFreeze - high thin tone representing suspended moment
// ============================================================
Ndef(\waiterFreeze, {
    |amp=0.05, freq=2000, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var sig = SinOsc.ar(freq) * 0.5 + SinOsc.ar(freq*1.01) * 0.5;
    sig = sig * SinOsc.kr(0.2).range(0.3, 1);
    Pan2.ar(sig * ampSmooth, pan);
}).play;
// Pbindef(\waiterFreezeSeq).stop; Ndef(\waiterFreeze).fadeTime = 2; Ndef(\waiterFreeze).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_SEQUENCE: mapFoldSeq - repetitive, meticulous rhythm for map folding
// ============================================================
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \t_trig, 1,
    \freq, Pseq([440, 550, 660, 550, 440, 330], inf),
    \amp, Pwhite(0.1, 0.3, inf),
    \pan, Pseq([-0.5, 0.5], inf),
    \modIndex, Pwhite(1, 4, inf),
    \modRatio, Pwhite(1, 3, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
// Pbindef(\mapFoldSeq).stop; // Rollback: remove this sequence
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: FALLBACK
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
s.waitForBoot({

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
	s.sync;

    // ServerTree.removeAll; // preserved for shared X-Append server
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    s.sync;

    // =====================================================================
    // 1. BUSES & ROUTING
    // =====================================================================
    ~dryBus = Bus.audio(s, 2);
    ~rhythmBus = Bus.audio(s, 2);

    // =====================================================================
    // 2. SYNTHDEFS (Discrete Events)
    // =====================================================================
    SynthDef(\salCrack, { |out=0, freq=8000, decay=0.05, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.3) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\mixThud, { |out=0, freq=100, rq=0.2, decayTime=0.2, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.01, decayTime), t_trig, doneAction: 2);
        var sig = RLPF.ar(Pulse.ar(freq) + WhiteNoise.ar(0.5), freq * 1.5, rq);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\eggPluck, { |out=0, freq=400, modIndex=2, decay=0.3, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var mod = SinOsc.ar(freq * 2.01) * modIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\rollingTap, { |out=0, freq=1200, decay=0.02, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.1) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    s.sync;

    // =====================================================================
    // 3. NDEFS & EFFECTS ARCHITECTURE
    // =====================================================================

    // -- Sound Sources --
    Ndef(\polvilhoAmbience, { |t_trig=1|
        var density = \density.kr(0.2);
        var hpFreq = \hpFreq.kr(6000);
        var lpFreq = \lpFreq.kr(20000);
        var rq = \rq.kr(0.9);
        var grainSize = \grainSize.kr(0.05);
        var gain = \gain.kr(0);

        var trig = Dust.ar(density * 200);
        var env = Decay2.ar(trig, 0.001, grainSize);
        var sig = WhiteNoise.ar * env;

        sig = RLPF.ar(sig, lpFreq.clip(20, 20000), rq.clip(0.01, 1.0));
        sig = HPF.ar(sig, hpFreq.clip(20, 20000));
        sig * gain ! 2;
    });

    Ndef(\leiteOleoDrone, { |t_trig=1|
        var freq1 = \freq1.kr(100);
        var freq2 = \freq2.kr(102);
        var fmIndex = \fmIndex.kr(0);
        var modFreq = \modFreq.kr(200);
        var gain = \gain.kr(0);

        var mod = SinOsc.ar(modFreq) * fmIndex * modFreq;
        var sig = SinOsc.ar([freq1 + mod, freq2 + mod]);
        sig * gain;
    });

    Ndef(\queijoTexture, { |t_trig=1|
        var foldAmount = \foldAmount.kr(0);
        var filtFreq = \filtFreq.kr(1500);
        var filtRQ = \filtRQ.kr(0.7);
        var gain = \gain.kr(0);
        var baseFreq = \freq.kr([150, 150, 150]); // Array for chords

        var mod = LPF.ar(WhiteNoise.ar, 500) * 100 * foldAmount;
        var sig = SinOsc.ar(baseFreq + mod);

        sig = Fold.ar(sig * 0.7 * (1 + foldAmount), -0.8, 0.8);
        sig = RLPF.ar(sig, filtFreq.clip(20, 20000), filtRQ.clip(0.01, 1.0));
        sig = Splay.ar(sig, spread: 0.8) * gain;
        sig;
    });

    // Fix: Removed unexpected standalone ( ) around this Ndef
    Ndef(\fornoHum, { |t_trig=1|
        var freq = \freq.kr(60);
        var crackDensity = \crackDensity.kr(0.5);
        var crackAmp = \crackAmp.kr(0.05);
        var hpFreq = \hpFreq.kr(200);
        var gain = \gain.kr(0);

        var drone = SinOsc.ar([freq, freq * 1.01]) + LFTri.ar([freq * 0.5, freq * 0.505]);
        var crackle = Dust2.ar(crackDensity ! 2) * crackAmp;
        var sig; // All var declarations must be at the top of the function

        crackle = RLPF.ar(crackle, 4000, 0.2);

        sig = (drone * 0.4) + crackle;
        sig = HPF.ar(sig, hpFreq.clip(20, 20000));
        sig * gain;
    });

    // -- Routing & Effects --
    Ndef(\delayTexture, { In.ar(~rhythmBus, 2) });
    Ndef(\delayTexture)[10] = \filter -> { |in|
        var del = DelayN.ar(in, 1.0, \delayTime.kr(0.3));
        in + (del * \feedback.kr(0.4));
    };
    Ndef(\delayTexture).set(\wet10, 0); // Initialized to 0

    Ndef(\master, {
        var sig = Ndef.ar(\polvilhoAmbience) +
                  Ndef.ar(\leiteOleoDrone) +
                  Ndef.ar(\queijoTexture) +
                  Ndef.ar(\fornoHum) +
                  Ndef.ar(\delayTexture) +
                  In.ar(~dryBus, 2);
        sig;
    });

    Ndef(\master)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.1);
    };
    Ndef(\master).set(\wet10, 0.1); // Master Reverb Wet/Dry

    Ndef(\master).play;

    s.sync;

    // =====================================================================
    // 4. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        "0:00 - [Movement I: Ingredientes Secos e Líquidos]".postln;
        Ndef(\polvilhoAmbience).set(\grainSize, 0.05, \density, 0.2, \hpFreq, 6000, \lpFreq, 20000, \rq, 0.9);
        Ndef(\polvilhoAmbience).fadeTime = 10;
        Ndef(\polvilhoAmbience).xset(\gain, -18.dbamp);

        Ndef(\leiteOleoDrone).fadeTime = 20;
        Ndef(\leiteOleoDrone).xset(\gain, -20.dbamp);

        25.wait;

        "0:25 - [Aquecendo]".postln;
        Ndef(\leiteOleoDrone).fadeTime = 20;
        Ndef(\leiteOleoDrone).xset(\fmIndex, 0.5, \modFreq, 200);

        Ndef(\polvilhoAmbience).fadeTime = 20;
        Ndef(\polvilhoAmbience).xset(\density, 0.4);

        20.wait;

        "0:45 - [Movement II: O Escaldo e a Mistura]".postln;
        Pbindef(\saltShot,
            \instrument, \salCrack,
            \freq, 8000,
            \decay, 0.05,
            \amp, -10.dbamp,
            \dur, Pseq([0.5, 0.5], 1),
            \out, ~dryBus
        ).play;

        Ndef(\polvilhoAmbience).fadeTime = 2;
        Ndef(\polvilhoAmbience).xset(\hpFreq, 800, \rq, 0.5, \lpFreq, 4000);
        Ndef(\leiteOleoDrone).set(\fmIndex, 0.8);

        15.wait;

        "1:00 - [Amassando o Polvilho]".postln;
        Ndef(\mixAmp, { Line.kr(-15.dbamp, -10.dbamp, 30) });
        Pbindef(\mixRhythm,
            \instrument, \mixThud,
            \freq, Pwhite(80, 120),
            \rq, 0.2,
            \decayTime, 0.2,
            \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.3, 0.2], inf),
            \amp, Ndef(\mixAmp),
            \out, ~dryBus
        ).play;

        Ndef(\polvilhoAmbience).fadeTime = 30;
        Ndef(\polvilhoAmbience).xset(\grainSize, 0.1, \density, 0.6, \hpFreq, 200, \lpFreq, 2000);

        45.wait;

        "1:45 - [Movement III: A Incorporação e a Riqueza]".postln;
        Pbindef(\eggSequence,
            \instrument, \eggPluck,
            \freq, Pseq([60, 62, 65, 67, 72, 69, 65, 79].midicps, 1),
            \modIndex, Pseq([2, 2.5, 3, 3.5, 4, 3, 2.5, 2], 1),
            \decay, 0.3,
            \amp, -12.dbamp,
            \dur, 1.25,
            \out, ~rhythmBus
        ).play;

        Pbindef(\mixRhythm, \dur, Pwrand([0.125, 0.25, 0.5], [0.4, 0.4, 0.2], inf));
        // Fix: Removed doneAction: 2 from Ndef to prevent premature node freeing
        Ndef(\mixAmp, { Line.kr(-10.dbamp, 0, 15) }); // Fade out mixRhythm

        Ndef(\polvilhoAmbience).fadeTime = 5;
        Ndef(\polvilhoAmbience).xset(\gain, -22.dbamp);

        25.wait;

        "2:10 - [O Queijo e a Homogeneidade]".postln;
        Pbindef(\mixRhythm).stop; // Ensure clean stop

        Ndef(\queijoTexture).set(\foldAmount, 4, \filtFreq, 1500, \filtRQ, 0.7);
        Ndef(\queijoTexture).fadeTime = 15;
        Ndef(\queijoTexture).xset(\gain, -10.dbamp);

        Ndef(\leiteOleoDrone).fadeTime = 5;
        Ndef(\leiteOleoDrone).xset(\fmIndex, 0.2);

        Ndef(\polvilhoAmbience).fadeTime = 10;
        Ndef(\polvilhoAmbience).xset(\gain, -28.dbamp);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0.25);

        35.wait;

        "2:45 - [Movement IV: Modelando e o Forno]".postln;
        Ndef(\rollAmp, { -18.dbamp });
        Pbindef(\rollRhythm,
            \instrument, \rollingTap,
            \freq, Pwhite(1000, 1500),
            \decay, 0.02,
            \dur, Pseq([0.25, 0.25, 0.5], inf),
            \amp, Ndef(\rollAmp),
            \out, ~rhythmBus
        ).play;

        Ndef(\queijoTexture).fadeTime = 10;
        Ndef(\queijoTexture).xset(\foldAmount, 2, \filtFreq, 800);

        Ndef(\delayTexture).set(\delayTime, 0.3, \feedback, 0.4);
        Ndef(\delayTexture).fadeTime = 2;
        Ndef(\delayTexture).xset(\wet10, 0.6);

        30.wait;

        "3:15 - [Assando no Forno]".postln;
        // Fix: Removed doneAction: 2 from Ndef
        Ndef(\rollAmp, { Line.kr(-18.dbamp, 0, 5) });
        Ndef(\delayTexture).fadeTime = 5;
        Ndef(\delayTexture).xset(\wet10, 0);

        fork { 5.wait; Pbindef(\rollRhythm).stop; };

        Ndef(\fornoHum).set(\freq, 60, \crackDensity, 0.5, \crackAmp, 0.05, \hpFreq, 200);
        Ndef(\fornoHum).fadeTime = 15;
        Ndef(\fornoHum).xset(\gain, -12.dbamp);

        Ndef(\queijoTexture).fadeTime = 10;
        Ndef(\queijoTexture).xset(\gain, -25.dbamp);

        Ndef(\polvilhoAmbience).fadeTime = 5;
        Ndef(\polvilhoAmbience).xset(\gain, 0);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0.4);

        30.wait;

        "3:45 - [Movement V: A Revelação e o Silêncio]".postln;
        Pbindef(\saltShot).stop; Pbindef(\saltShot).clear; Pbindef(\mixRhythm).stop; Pbindef(\mixRhythm).clear; Pbindef(\eggSequence).stop; Pbindef(\eggSequence).clear; Pbindef(\rollRhythm).stop; Pbindef(\rollRhythm).clear;

        Ndef(\fornoHum).fadeTime = 2;
        Ndef(\fornoHum).xset(\gain, -10.dbamp);
        fork { 2.wait; Ndef(\fornoHum).fadeTime = 13; Ndef(\fornoHum).xset(\gain, -20.dbamp); };

        Ndef(\leiteOleoDrone).fadeTime = 5;
        Ndef(\leiteOleoDrone).xset(\gain, -15.dbamp);

        Ndef(\queijoTexture).set(\foldAmount, 0, \filtFreq, 300, \filtRQ, 0.9, \freq, [150, 200, 250]);
        Ndef(\queijoTexture).fadeTime = 2;
        Ndef(\queijoTexture).xset(\gain, -15.dbamp);

        15.wait;

        "4:00 - [Aroma e Silêncio]".postln;
        Ndef(\leiteOleoDrone).fadeTime = 15;
        Ndef(\leiteOleoDrone).xset(\gain, 0);

        Ndef(\queijoTexture).fadeTime = 15;
        Ndef(\queijoTexture).xset(\gain, 0);

        Ndef(\fornoHum).fadeTime = 15;
        Ndef(\fornoHum).xset(\gain, 0);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0);

        15.wait;

        "4:15 - [Terminating]".postln;
        Ndef(\polvilhoAmbience).clear(5); Ndef(\leiteOleoDrone).clear(5); Ndef(\queijoTexture).clear(5); Ndef(\fornoHum).clear(5); Ndef(\delayTexture).clear(5); Ndef(\master).clear(5); Ndef(\mixAmp).clear(5); Ndef(\rollAmp).clear(5);
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    // s.makeGui;

});
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

s.waitForBoot({

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete synthdefs
    SynthDef(\tickTock, {
        var env, sig, freq = \freq.kr(1200);
        env = EnvGen.ar(Env.perc(0.001, \decay.kr(0.03), 1, -6), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.18) * 9.0;
        sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 0) * 0.15);
        sig = sig * env;
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
    }).add;

    SynthDef(\carillon, {
        var sig, env, mod1, mod2, car, f;
        f = \freq.kr(440);
        env = EnvGen.ar(Env.perc(0.005, \decay.kr(3), 1, -4), doneAction: 2);
        mod1 = SinOsc.ar(f * 2.76) * f * 1.2;
        mod2 = SinOsc.ar(f * 3.51) * f * 0.6;
        car = SinOsc.ar(f + mod1 + mod2);
        sig = car * env;
        sig = sig + (SinOsc.ar(f * 2) * env * 0.25);
        sig = sig + (SinOsc.ar(f * 0.5) * env * 0.15);
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3)));
    }).add;

    SynthDef(\gearGrind, {
        var sig, env, freq;
        freq = \freq.kr(120);
        env = EnvGen.ar(Env.perc(0.01, \decay.kr(0.5), 1, -3), doneAction: 2);
        sig = Saw.ar(freq * [1, 1.01, 1.02]).sum * 0.3;
        sig = RLPF.ar(sig, \cutoff.kr(2000), 0.3) * 3;
        sig = (sig * 2).tanh * env;
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3)));
    }).add;

    s.sync;

    // Continuous textures
    Ndef(\clockSwarm, {
        var tick1, tick2, tick3, sig;
        tick1 = BPF.ar(WhiteNoise.ar, 1500 + SinOsc.kr(0.53).range(-120, 120), 0.12) * Decay.ar(Impulse.ar(2.31), 0.02);
        tick2 = BPF.ar(WhiteNoise.ar, 2200 + SinOsc.kr(0.71).range(-220, 220), 0.12) * Decay.ar(Impulse.ar(3.13), 0.015);
        tick3 = BPF.ar(WhiteNoise.ar, 900 + SinOsc.kr(0.37).range(-60, 60), 0.12) * Decay.ar(Impulse.ar(1.73), 0.03);
        sig = (tick1 * 8) + (tick2 * 6) + (tick3 * 10);
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\brassDrone, {
        var sig, freqs;
        freqs = [55, 82.5, 110, 165, 220];
        sig = Mix.ar(freqs.collect({ |f, i|
            SinOsc.ar(f * (1 + LFNoise1.kr(0.1).range(-0.002, 0.002))) * (1 / (i + 1))
        }));
        sig = (sig * 1.5).tanh;
        sig = RLPF.ar(sig, \cutoff.kr(800), 0.5) * 2;
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\breathOfTime, {
        var sig, env;
        env = LFNoise1.kr(0.15).range(0.3, 1);
        sig = (SinOsc.ar(\freq.kr(60) * [1, 1.5, 2]) * [0.7, 0.3, 0.15]).sum;
        sig = sig + (SinOsc.ar(\freq.kr(60) * 2) * env * 0.2);
        sig = LPF.ar(sig, 400);
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\carillonCloud, {
        var sig, trig, freqs;
        trig = Impulse.kr(\density.kr(0.5));
        freqs = Demand.kr(trig, 0, Dseq([523.25, 587.33, 659.25, 783.99, 880, 659.25], inf));
        sig = (SinOsc.ar(freqs * [1, 2.76, 3.51]) * EnvGen.kr(Env.perc(0.005, 3), trig)).sum;
        sig = FreeVerb2.ar(sig, sig, 0.5, 0.9, 0.5);
        sig = sig * \amp.kr(0);
        sig;
    });

    // Master Mix
    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2);
        sig = sig + Ndef(\clockSwarm).ar(2);
        sig = sig + Ndef(\brassDrone).ar(2);
        sig = sig + Ndef(\breathOfTime).ar(2);
        sig = sig + Ndef(\carillonCloud).ar(2);
        sig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;

    s.sync;

    // Master Score
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Estreita - o enxame de tique-taques desperta]".postln;
        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, -20.dbamp);

        Pbindef(\tickSeq,
            \instrument, \tickTock,
            \freq, Pwhite(800, 2400),
            \decay, Pexprand(0.015, 0.04),
            \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
            \amp, 0.3,
            \pan, Pwhite(-0.7, 0.7),
            \out, ~synthBus
        ).play;

        Pbindef(\tickSeq2,
            \instrument, \tickTock,
            \freq, Pwhite(600, 1800),
            \decay, Pexprand(0.02, 0.05),
            \dur, Pseq([0.333, 0.333, 0.334, 0.5], inf),
            \amp, 0.25,
            \pan, Pwhite(-0.8, 0.8),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\clockSwarm).xset(\amp, (-20 + (i * 0.4)).dbamp);
            2.wait;
        };

        "0:20 - [Cue 2: Defasagens Microscopicas - os tempos se desencontram]".postln;
        Ndef(\brassDrone).fadeTime = 5;
        Ndef(\brassDrone).xset(\amp, -24.dbamp);

        Pbindef(\gearSeq,
            \instrument, \gearGrind,
            \freq, Pwhite(80, 200),
            \decay, Pexprand(0.1, 0.4),
            \cutoff, Pwhite(800, 2500),
            \dur, Pseq([0.5, 0.25, 0.25, 0.75, 0.25], inf),
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\brassDrone).xset(\cutoff, exprand(400, 1500));
            3.wait;
        };

        "0:50 - [Cue 3: Carrilhoes Franceses - as badaladas entram]".postln;
        Ndef(\carillonCloud).fadeTime = 4;
        Ndef(\carillonCloud).xset(\amp, -22.dbamp, \density, 0.35);

        Pbindef(\carillonSeq,
            \instrument, \carillon,
            \freq, Pseq([523.25, 587.33, 659.25, 783.99, 880, 659.25], inf),
            \decay, Pexprand(2, 5),
            \dur, Pseq([1.5, 0.5, 1, 0.5, 1.5, 1], inf),
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5),
            \out, ~synthBus
        ).play;

        6.do { |i|
            Ndef(\carillonCloud).xset(\density, 0.35 + (i * 0.12));
            5.wait;
        };

        "1:20 - [Cue 4: O Relojoeiro Fecha os Olhos - o respirar do tempo]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\tickSeq2).stop;
        Pbindef(\gearSeq).stop;

        Ndef(\breathOfTime).fadeTime = 8;
        Ndef(\breathOfTime).xset(\amp, -18.dbamp, \freq, 55);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet10, 0.4);

        15.do { |i|
            Ndef(\breathOfTime).xset(\freq, 55 + (i * 1.2));
            Ndef(\carillonCloud).xset(\density, (0.6 - (i * 0.03)).max(0.15));
            2.wait;
        };

        "1:50 - [Cue 5: Engrenagens - os tique-taques retornam em fase]".postln;
        Pbindef(\tickSeq,
            \instrument, \tickTock,
            \freq, Pwhite(1000, 2000),
            \decay, Pexprand(0.02, 0.04),
            \dur, Pseq([0.25, 0.25, 0.5], inf),
            \amp, 0.25,
            \pan, Pwhite(-0.7, 0.7),
            \out, ~synthBus
        ).play;

        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, -16.dbamp);

        12.do { |i|
            Ndef(\breathOfTime).xset(\freq, 60 - (i * 0.6));
            Ndef(\brassDrone).xset(\cutoff, exprand(600, 2000));
            2.wait;
        };

        "2:15 - [Cue 6: Settling - o tempo respira e silencia]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\carillonSeq).stop;

        Ndef(\carillonCloud).fadeTime = 6;
        Ndef(\carillonCloud).xset(\amp, -30.dbamp);

        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, -28.dbamp);

        Ndef(\brassDrone).fadeTime = 8;
        Ndef(\brassDrone).xset(\amp, -28.dbamp);

        Ndef(\breathOfTime).fadeTime = 10;
        Ndef(\breathOfTime).xset(\amp, -22.dbamp, \freq, 50);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet10, 0.55);

        10.do { |i|
            Ndef(\breathOfTime).xset(\freq, 50 + (i * 0.4));
            1.5.wait;
        };

        "2:30 - [Terminating]".postln;
        Pbindef(\tickSeq).stop; Pbindef(\tickSeq).clear;
        Pbindef(\tickSeq2).stop; Pbindef(\tickSeq2).clear;
        Pbindef(\gearSeq).stop; Pbindef(\gearSeq).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;

        Ndef(\clockSwarm).clear(5);
        Ndef(\brassDrone).clear(5);
        Ndef(\breathOfTime).clear(5);
        Ndef(\carillonCloud).clear(5);
        Ndef(\masterMix).clear(5);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 04 | MODE: COMPOSE | FRAG #13
// STATUS: FIXED
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
~enableRecording = false;

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

    // Cave water drip
    SynthDef(\caveDrip, {
        |out=0, freq=800, decay=0.5, amp=0.25, pan=0|
        var exc, sig, env;
        exc = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0001, 0.003)));
        sig = Ringz.ar(exc, freq * [1, 1.47, 2.13, 2.89], decay * [1, 0.7, 0.5, 0.3], 0.3).sum;
        sig = LPF.ar(sig, freq * 6);
        env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Stalactite modal bell
    SynthDef(\stalactite, {
        |out=0, freq=400, decay=3, amp=0.2, pan=0|
        var exc, sig, env;
        exc = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.0001, 0.01)) * 0.3);
        sig = DynKlank.ar(
            Ref([
                [freq, freq*2.76, freq*5.4, freq*8.93, freq*13.34],
                [1, 0.6, 0.35, 0.2, 0.12],
                [1, 0.8, 0.6, 0.4, 0.3]
            ]),
            exc,
            decayscale: decay
        );
        sig = LPF.ar(sig, 5000);
        env = EnvGen.ar(Env.perc(0.001, decay * 0.9), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Limestone rumble
    SynthDef(\limestoneRumble, {
        |out=0, freq=60, decay=2, amp=0.35, pan=0|
        var sig, env, mod;
        mod = SinOsc.ar(freq * 0.5) * freq * 0.3;
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq*2) * 0.3);
        env = EnvGen.ar(Env.perc(0.01, decay, 1, -4), doneAction: 2);
        sig = (sig * 2).tanh * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // Continuous: cavern drone
    Ndef(\cavernDrone, {
        |amp=0, cutoff=300, freq=42, res=1.5|
        var sig, mod;
        mod = LFNoise1.kr(0.15).range(0.98, 1.02);
        sig = SinOsc.ar(freq * mod) + (SinOsc.ar(freq*1.5) * 0.4) + (SinOsc.ar(freq*2) * 0.2);
        sig = sig + (Saw.ar(freq*0.5) * 0.15);
        sig = (MoogFF.ar(sig, cutoff, res) * 1.5).tanh * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.05, 0.03)]);
    });

    // Continuous: water flow
    Ndef(\waterFlow, {
        |amp=0, cutoff=800, q=0.7|
        var sig, lf;
        sig = PinkNoise.ar(0.5) + WhiteNoise.ar(0.2);
        sig = BPF.ar(sig, cutoff, q) * 6;
        lf = LFNoise1.kr(0.3).range(0.7, 1.3);
        sig = sig * lf * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.07, 0.05)]);
    });

    // Continuous: mineral shimmer
    Ndef(\mineralShimmer, {
        |amp=0, density=0.2, cutoff=4000|
        var sig, trig;
        // Ringz requires an audio-rate input; use Dust.ar instead of Dust.kr
        trig = Dust.ar(density);
        sig = Ringz.ar(trig, TExpRand.kr(2000, 6000, trig), 2, 0.2)
            + Ringz.ar(trig, TExpRand.kr(3000, 8000, trig), 3, 0.15);
        sig = LPF.ar(sig, cutoff) * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.1, 0.08)]);
    });

    // Master mixer
    Ndef(\masterMix, {
        In.ar(~synthBus, 2)
        + (Ndef(\cavernDrone).ar(2) * 0.9)
        + (Ndef(\waterFlow).ar(2) * 0.8)
        + (Ndef(\mineralShimmer).ar(2) * 0.7)
    });

    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.35); };
    Ndef(\masterMix)[11] = \filter -> { |in| MoogFF.ar(in, 3500, 0.5); };

    Ndef(\masterMix).play;
    Ndef(\masterMix).set(\wet10, 0.3, \wet11, 0.4);
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: Peter Lund - entrada na escuridao]".postln;
        Ndef(\cavernDrone).fadeTime = 8;
        Ndef(\cavernDrone).xset(\amp, -18.dbamp, \cutoff, 180, \freq, 42);

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pexprand(600, 2200),
            \decay, Pexprand(0.2, 0.9),
            \amp, 0.22,
            \pan, Pwhite(-0.85, 0.85),
            \dur, Pseq([0.8, 0.4, 1.2, 0.6, 0.3, 1.5, 0.5], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, 180 + (i * 60));
            1.5.wait;
        };

        "0:12 - [Cue 2: Primeiro salao - gotas ressoam]".postln;
        Ndef(\waterFlow).fadeTime = 6;
        Ndef(\waterFlow).xset(\amp, -26.dbamp, \cutoff, 900);
        6.do { |i|
            Ndef(\waterFlow).xset(\cutoff, exprand(500, 2500));
            2.wait;
        };

        "0:24 - [Cue 3: Cortinas minerais - brilho nas abobadas]".postln;
        Ndef(\mineralShimmer).fadeTime = 5;
        Ndef(\mineralShimmer).xset(\amp, -24.dbamp, \density, 0.25);

        Pbindef(\stalactiteSeq,
            \instrument, \stalactite,
            \freq, Pseq([220, 330, 440, 293.66, 220, 392], inf),
            \decay, Pexprand(2.5, 5.5),
            \amp, 0.15,
            \pan, Pwhite(-0.7, 0.7),
            \dur, Pseq([2.5, 1, 3, 1.5, 2, 2.5], inf),
            \out, ~synthBus
        ).play;

        6.do { |i|
            Ndef(\mineralShimmer).xset(\density, 0.25 + (i * 0.08));
            2.wait;
        };

        "0:36 - [Cue 4: Limite intrinseco - a agua perfura a rocha]".postln;
        Pbindef(\dripSeq).stop;

        Pbindef(\limestoneSeq,
            \instrument, \limestoneRumble,
            \freq, Pseq([55, 60, 48, 55, 42], inf),
            \decay, Pexprand(1.5, 3),
            \amp, 0.3,
            \pan, Pwhite(-0.5, 0.5),
            \dur, Pseq([1.5, 0.75, 2, 1, 1.75], inf),
            \out, ~synthBus
        ).play;

        Ndef(\waterFlow).xset(\amp, -18.dbamp, \cutoff, 1800);
        8.do { |i|
            Ndef(\cavernDrone).xset(\freq, 42 + (i * 1.5), \cutoff, 250 + (i * 80));
            1.5.wait;
        };

        "0:48 - [Cue 5: Settling - gotejamento solitario na escuridao]".postln;
        Pbindef(\limestoneSeq).stop;
        Pbindef(\stalactiteSeq).stop;

        Ndef(\waterFlow).fadeTime = 8;
        Ndef(\waterFlow).xset(\amp, -30.dbamp);
        Ndef(\mineralShimmer).fadeTime = 6;
        Ndef(\mineralShimmer).xset(\amp, -30.dbamp, \density, 0.1);

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pexprand(500, 1500),
            \decay, Pexprand(0.5, 1.5),
            \amp, 0.18,
            \pan, Pwhite(-0.8, 0.8),
            \dur, Pseq([2, 1.5, 3, 1, 2.5], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, (250 - (i * 20)).max(120));
            1.5.wait;
        };

        "1:00 - [Cue 6: Flashback - os saloes retornam, escuridao profunda]".postln;
        Pbindef(\dripSeq).stop;

        Ndef(\cavernDrone).xset(\amp, -12.dbamp, \freq, 36, \cutoff, 400);
        Ndef(\masterMix).xset(\wet10, 0.55);

        Pbindef(\stalactiteSeq,
            \instrument, \stalactite,
            \freq, Pseq([110, 165, 220, 146.83, 110], inf),
            \decay, Pexprand(3, 6),
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6),
            \dur, Pseq([3, 1.5, 2.5, 2, 3.5], inf),
            \out, ~synthBus
        ).play;

        Pbindef(\limestoneSeq,
            \instrument, \limestoneRumble,
            \freq, Pseq([48, 42, 55], inf),
            \decay, Pexprand(2, 4),
            \amp, 0.25,
            \pan, Pwhite(-0.4, 0.4),
            \dur, Pseq([2.5, 3, 2], inf),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, 400 + (i * 100));
            1.wait;
        };

        "1:20 - [Cue 7: Limite extrinseco - o setimo salao, resolucao]".postln;
        Pbindef(\limestoneSeq).stop;

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pseq([880, 660, 880, 990, 1100], inf),
            \decay, Pexprand(0.6, 1.2),
            \amp, 0.2,
            \pan, Pwhite(-0.9, 0.9),
            \dur, Pseq([0.5, 0.3, 0.7, 0.4, 1], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\mineralShimmer).xset(\density, 0.15 + (i * 0.06));
            Ndef(\cavernDrone).xset(\cutoff, (700 - (i * 60)).max(200));
            1.wait;
        };

        "1:36 - [Cue 8: Settling final - silencio mineral]".postln;
        Pbindef(\dripSeq).stop;
        Pbindef(\stalactiteSeq).stop;

        Ndef(\cavernDrone).fadeTime = 10;
        Ndef(\cavernDrone).xset(\amp, -22.dbamp, \freq, 42);
        Ndef(\mineralShimmer).fadeTime = 8;
        Ndef(\mineralShimmer).xset(\amp, -34.dbamp);
        Ndef(\masterMix).xset(\wet10, 0.65);

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, (300 - (i * 25)).max(100));
            1.2.wait;
        };

        "1:48 - [Terminating]".postln;
        Pbindef(\dripSeq).stop; Pbindef(\dripSeq).clear;
        Pbindef(\stalactiteSeq).stop; Pbindef(\stalactiteSeq).clear;
        Pbindef(\limestoneSeq).stop; Pbindef(\limestoneSeq).clear;

        Ndef(\cavernDrone).clear(6);
        Ndef(\waterFlow).clear(6);
        Ndef(\mineralShimmer).clear(6);
        Ndef(\masterMix).clear(6);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Modular Cabinet + Lissajous Oscilloscope — 3-zone multitimbral
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxPot1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxPin2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64, hpf3: 65, lpf3: 66, rq3: 67,
    atk3: 68, dec3: 69, sus3: 70, rls3: 71, fxLiss3: 72,
    delMix: 80, revMix: 81, delTime: 82, revTime: 83, panic: 90
);

~ccVals = (
    vol1: 0.28, pan1: 0.0,  mute1: 0.0, min1: 0,  max1: 65, hpf1: 25,  lpf1: 180, rq1: 0.6,
    atk1: 0.01, dec1: 0.6, sus1: 0.7, rls1: 0.8, fxPot1: 0.0,
    vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 100, hpf2: 350, lpf2: 6500, rq2: 0.4,
    atk2: 0.005, dec2: 0.4, sus2: 0.2, rls2: 0.6, fxPin2: 0.0,
    vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.5,
    atk3: 0.4, dec3: 1.5, sus3: 0.6, rls3: 2.0, fxLiss3: 0.0,
    delMix: 0.0, revMix: 0.0, delTime: 0.35, revTime: 2.5, panic: 0
);

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
    ("MIDI IN: " ++ ~myInDevice.device ++ " / " ++ ~myInDevice.name).postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input detected.".warn;
    ~myUid = nil;
};

s.waitForBoot {
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // ---- Zone 1: Silver Potentiometers — Moog-ish sub bass ----
    SynthDef(\silverPot, { |out, freq=55, gate=1, amp=0.28, pan=0,
        hpf=25, lpf=180, rq=0.6, atk=0.01, dec=0.6, sus=0.7, rls=0.8, fxPot=0|
        var env, sig, sub, det, drive, cutoff;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        det = Saw.ar(freq * [0.997, 1.0, 1.003]) + Pulse.ar(freq * 0.5, 0.4, 0.35);
        sig = Splay.ar(det) * 0.5;
        drive = 1.0 + (fxPot * 3.0);
        cutoff = (lpf + (fxPot * 900)).clip(30, 6000);
        sig = (MoogFF.ar(sig * drive, cutoff, 3.2) * 3.0).tanh;
        sig = RLPF.ar(sig, cutoff, rq);
        sig = HPF.ar(sig, hpf);
        sub = SinOsc.ar(freq * 0.5) * 0.4 * (1 - fxPot.clip(0,1));
        sig = sig + sub;
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- Zone 2: Pin Matrix — FM metallic pluck ----
    SynthDef(\pinMatrix, { |out, freq=220, gate=1, amp=0.22, pan=0,
        hpf=350, lpf=6500, rq=0.4, atk=0.005, dec=0.4, sus=0.2, rls=0.6, fxPin=0|
        var env, mod, car, ratio, idx, sig, comb, ap;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        ratio = 2.71 + (fxPin * 3.5);
        idx = (freq * (1.2 + (fxPin * 8.0))) * EnvGen.kr(Env.perc(0.001, 0.35));
        mod = SinOsc.ar(freq * ratio) * idx;
        car = SinOsc.ar(freq + mod);
        car = car + (SinOsc.ar(freq * 3.51 + mod * 0.5) * 0.3);
        comb = CombL.ar(car * EnvGen.kr(Env.perc(0.001, 0.02)),
            0.05, freq.reciprocal.clip(0.0001, 0.05), 0.4 + (fxPin * 1.5));
        ap = AllpassC.ar(comb, 0.02, (fxPin * 0.008) + 0.0005, 0.08);
        sig = (car * 0.6) + ap;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- Zone 3: Lissajous Oscilloscope — additive harmonic pad ----
    SynthDef(\lissPad, { |out, freq=220, gate=1, amp=0.18, pan=0,
        hpf=160, lpf=3200, rq=0.5, atk=0.4, dec=1.5, sus=0.6, rls=2.0, fxLiss=0|
        var env, sig, partials, lfoX, lfoY, ph, harm;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        harm = [1, 2, 3, 4, 5, 6, 7];
        lfoX = SinOsc.kr(0.13 + (fxLiss * 0.9), 0, 0.5, 1.0);
        lfoY = SinOsc.kr(0.17 + (fxLiss * 0.7), 1.2, 0.5, 1.0);
        partials = harm.collect { |h, i|
            var det = (i + 1) * 0.003 * (1 + fxLiss);
            SinOsc.ar(freq * h * (1 + det), 0, 1.0 / (h * (1 + (i * 0.3))))
        };
        sig = Mix(partials);
        ph = SinOsc.kr(0.05 + (fxLiss * 0.4), 0, 0.7, 1.0);
        sig = sig * lfoX;
        sig = sig + (SinOsc.ar(freq * 0.5 * lfoY) * 0.25 * fxLiss);
        sig = sig * ph;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- FX: delay + reverb ----
    SynthDef(\delayFx, { |in, out, delMix=0, delTime=0.35|
        var sig, dly;
        sig = In.ar(in, 2);
        dly = CombL.ar(sig, 1.0, delTime, 2.0);
        dly = AllpassC.ar(dly, 0.05, 0.02, 0.3);
        Out.ar(out, (sig * (1 - delMix)) + (dly * delMix));
    }).add;

    SynthDef(\reverbFx, { |in, out, revMix=0, revTime=2.5|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], revMix, 0.85, revTime.linlin(0.2, 8.0, 0.2, 0.95));
        Out.ar(out, wet);
    }).add;

    SynthDef(\safetyLimiter, { |in, out|
        var sig;
        sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~delaySynth = Synth(\delayFx, [\in, ~fxBus, \out, ~masterBus,
        \delMix, ~buses.delMix.asMap, \delTime, ~buses.delTime.asMap],
        ~fxGroup, \addToTail);
    ~reverbSynth = Synth(\reverbFx, [\in, ~masterBus, \out, 0,
        \revMix, ~buses.revMix.asMap, \revTime, ~buses.revTime.asMap],
        ~masterGroup, \addToTail);
    ~limiter = Synth(\safetyLimiter, [\in, 0, \out, 0], ~masterGroup, \addToTail);

    // ---- Voice allocation ----
    ~zoneNotes = Array.newClear(128);
    128.do { |i| ~zoneNotes[i] = [] };

    ~spawn = { |noteNum, vel|
        var freq = noteNum.midicps;
        var v = vel / 127.0;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] } and: { ~ccVals[\mute1] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\silverPot, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol1] * v,
                    \pan, ~ccVals[\pan1], \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap,
                    \rq, ~buses.rq1.asMap, \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap,
                    \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap, \fxPot, ~buses.fxPot1.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] } and: { ~ccVals[\mute2] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\pinMatrix, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol2] * v,
                    \pan, ~ccVals[\pan2], \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap,
                    \rq, ~buses.rq2.asMap, \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap,
                    \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap, \fxPin, ~buses.fxPin2.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] } and: { ~ccVals[\mute3] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\lissPad, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol3] * v,
                    \pan, ~ccVals[\pan3], \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap,
                    \rq, ~buses.rq3.asMap, \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap,
                    \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap, \fxLiss, ~buses.fxLiss3.asMap
                ], ~synthGroup));
        };
    };

    ~release = { |noteNum|
        ~zoneNotes[noteNum].do(_.set(\gate, 0));
        ~zoneNotes[noteNum] = [];
    };

    MIDIdef.noteOn(\on, { |vel, noteNum|
        ~release.(noteNum);
        ~spawn.(noteNum, vel);
    }, srcID: ~myUid);

    MIDIdef.noteOff(\off, { |vel, noteNum|
        ~release.(noteNum);
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
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { ks.contains("vol") } { norm * 0.4 }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            128.do { |i| ~release.(i) };
            "PANIC — all voices off".postln;
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ---- GUI ----
    defer {
        // All var declarations must be at the top of the function
        var bounds = Window.availableBounds;
        var winH = min(780, bounds.height - 60);
        var barY = 3 * 300 + 6;
        var bar;
        ~zoneMeta = [
            (title: "ZONE 1 — SILVER POTS (Sub)", fxKey: "fxPot1", fxLabel: "Pot Drive"),
            (title: "ZONE 2 — PIN MATRIX (FM Pluck)", fxKey: "fxPin2", fxLabel: "Pin Index"),
            (title: "ZONE 3 — LISSAJOUS (Harm Pad)", fxKey: "fxLiss3", fxLabel: "Liss Fold")
        ];
        ~ui = ();

        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("Modular Cabinet / Lissajous Scope", Rect(
            (bounds.width - 620) / 2, (bounds.height - winH) / 2, 620, winH), scroll: true);
        ~mainWin.background = Color(0.06, 0.07, 0.06);

        ~zoneMeta.do { |zm, idx|
            var z = idx + 1;
            var page = CompositeView(~mainWin, Rect(0, idx * 300, 600, 290));
            page.background = if(idx.even, Color(0.09, 0.10, 0.09), Color(0.07, 0.08, 0.07));
            StaticText(page, Rect(10, 6, 580, 22))
                .string_(zm.title).font_(Font("Monaco", 13)).stringColor_(Color(0.4, 1.0, 0.5));

            EZSlider(page, Rect(10, 34, 280, 30), "VOL " ++ ~cc[("vol" ++ z).asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[("vol" ++ z).asSymbol]),
                { |ez| ~ccVals[("vol" ++ z).asSymbol] = ez.value;
                    ~buses[("vol" ++ z).asSymbol].set(ez.value) });
            ~ui[("vol" ++ z).asSymbol] = { |v| page.children[2].value = v };

            EZSlider(page, Rect(300, 34, 290, 30), "PAN " ++ ~cc[("pan" ++ z).asSymbol],
                ControlSpec(-1, 1, \lin, 0, ~ccVals[("pan" ++ z).asSymbol]),
                { |ez| ~ccVals[("pan" ++ z).asSymbol] = ez.value;
                    ~buses[("pan" ++ z).asSymbol].set(ez.value) });
            ~ui[("pan" ++ z).asSymbol] = { |v| page.children[3].value = v };

            EZRanger(page, Rect(10, 70, 380, 30), "KEY RANGE " ++ ~cc[("min" ++ z).asSymbol] ++ "/" ++ ~cc[("max" ++ z).asSymbol],
                ControlSpec(0, 127, \lin, 1, 0),
                { |ez| ~ccVals[("min" ++ z).asSymbol] = ez.lo;
                    ~ccVals[("max" ++ z).asSymbol] = ez.hi;
                    ~buses[("min" ++ z).asSymbol].set(ez.lo);
                    ~buses[("max" ++ z).asSymbol].set(ez.hi) });
            page.children[4].setRanges(~ccVals[("min" ++ z).asSymbol], ~ccVals[("max" ++ z).asSymbol]);
            ~ui[("min" ++ z).asSymbol] = { |v| };
            ~ui[("max" ++ z).asSymbol] = { |v| };

            Button(page, Rect(400, 70, 90, 30)).states_([
                ["MUTE", Color.white, Color(0.3, 0.05, 0.05)],
                ["MUTED", Color.white, Color(0.7, 0.1, 0.1)]])
                .action_({ |b| ~ccVals[("mute" ++ z).asSymbol] = b.value;
                    ~buses[("mute" ++ z).asSymbol].set(b.value) });
            ~ui[("mute" ++ z).asSymbol] = { |v| page.children[5].value = v };

            EZSlider(page, Rect(10, 106, 190, 30), "HPF " ++ ~cc[("hpf" ++ z).asSymbol],
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("hpf" ++ z).asSymbol]),
                { |ez| ~ccVals[("hpf" ++ z).asSymbol] = ez.value;
                    ~buses[("hpf" ++ z).asSymbol].set(ez.value) });
            ~ui[("hpf" ++ z).asSymbol] = { |v| page.children[6].value = v };

            EZSlider(page, Rect(205, 106, 190, 30), "LPF " ++ ~cc[("lpf" ++ z).asSymbol],
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("lpf" ++ z).asSymbol]),
                { |ez| ~ccVals[("lpf" ++ z).asSymbol] = ez.value;
                    ~buses[("lpf" ++ z).asSymbol].set(ez.value) });
            ~ui[("lpf" ++ z).asSymbol] = { |v| page.children[7].value = v };

            EZSlider(page, Rect(400, 106, 190, 30), "RQ " ++ ~cc[("rq" ++ z).asSymbol],
                ControlSpec(0.05, 1.0, \lin, 0, ~ccVals[("rq" ++ z).asSymbol]),
                { |ez| ~ccVals[("rq" ++ z).asSymbol] = ez.value;
                    ~buses[("rq" ++ z).asSymbol].set(ez.value) });
            ~ui[("rq" ++ z).asSymbol] = { |v| page.children[8].value = v };

            EZSlider(page, Rect(10, 142, 140, 30), "ATK " ++ ~cc[("atk" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("atk" ++ z).asSymbol]),
                { |ez| ~ccVals[("atk" ++ z).asSymbol] = ez.value;
                    ~buses[("atk" ++ z).asSymbol].set(ez.value) });
            ~ui[("atk" ++ z).asSymbol] = { |v| page.children[9].value = v };

            EZSlider(page, Rect(155, 142, 140, 30), "DEC " ++ ~cc[("dec" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("dec" ++ z).asSymbol]),
                { |ez| ~ccVals[("dec" ++ z).asSymbol] = ez.value;
                    ~buses[("dec" ++ z).asSymbol].set(ez.value) });
            ~ui[("dec" ++ z).asSymbol] = { |v| page.children[10].value = v };

            EZSlider(page, Rect(300, 142, 140, 30), "SUS " ++ ~cc[("sus" ++ z).asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[("sus" ++ z).asSymbol]),
                { |ez| ~ccVals[("sus" ++ z).asSymbol] = ez.value;
                    ~buses[("sus" ++ z).asSymbol].set(ez.value) });
            ~ui[("sus" ++ z).asSymbol] = { |v| page.children[11].value = v };

            EZSlider(page, Rect(445, 142, 145, 30), "RLS " ++ ~cc[("rls" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("rls" ++ z).asSymbol]),
                { |ez| ~ccVals[("rls" ++ z).asSymbol] = ez.value;
                    ~buses[("rls" ++ z).asSymbol].set(ez.value) });
            ~ui[("rls" ++ z).asSymbol] = { |v| page.children[12].value = v };

            EZSlider(page, Rect(10, 186, 580, 34), zm.fxLabel ++ " " ++ ~cc[zm.fxKey.asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[zm.fxKey.asSymbol]),
                { |ez| ~ccVals[zm.fxKey.asSymbol] = ez.value;
                    ~buses[zm.fxKey.asSymbol].set(ez.value) });
            ~ui[zm.fxKey.asSymbol] = { |v| page.children[13].value = v };

            StaticText(page, Rect(10, 224, 580, 18))
                .string_("◆ silver pots · luminous pin matrix · rotating Lissajous harmonics ◆")
                .font_(Font("Monaco", 10)).stringColor_(Color(0.3, 0.7, 0.4));
        };

        // Bottom bar
        bar = CompositeView(~mainWin, Rect(0, barY, 600, 120));
        bar.background = Color(0.10, 0.11, 0.10);

        EZSlider(bar, Rect(10, 8, 280, 30), "DELAY MIX " ++ ~cc[\delMix],
            ControlSpec(0, 1, \lin, 0, ~ccVals[\delMix]),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) });
        ~ui[\delMix] = { |v| bar.children[0].value = v };

        EZSlider(bar, Rect(300, 8, 290, 30), "REVERB MIX " ++ ~cc[\revMix],
            ControlSpec(0, 1, \lin, 0, ~ccVals[\revMix]),
            { |ez| ~ccVals[\revMix] = ez.value; ~buses[\revMix].set(ez.value) });
        ~ui[\revMix] = { |v| bar.children[1].value = v };

        EZSlider(bar, Rect(10, 44, 280, 30), "DELAY TIME " ++ ~cc[\delTime],
            ControlSpec(0.02, 1.0, \exp, 0, ~ccVals[\delTime]),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) });
        ~ui[\delTime] = { |v| bar.children[2].value = v };

        EZSlider(bar, Rect(300, 44, 290, 30), "REVERB TIME " ++ ~cc[\revTime],
            ControlSpec(0.2, 8.0, \exp, 0, ~ccVals[\revTime]),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) });
        ~ui[\revTime] = { |v| bar.children[3].value = v };

        Button(bar, Rect(10, 82, 580, 30)).states_([
            ["PANIC (ALL OFF) — CC " ++ ~cc[\panic], Color.white, Color(0.5, 0.05, 0.05)],
            ["RELEASED", Color.white, Color(0.2, 0.2, 0.2)]])
            .action_({ |b|
                if(b.value == 1) {
                    128.do { |i| ~release.(i) };
                    "PANIC".postln;
                };
            });

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

        "Modular Cabinet ready — 3 zones, MIDI CC mapped.".postln;
    };
};

// ~mainWin.close; 128.do { |i| ~release.(i) };
)


// ============================================================
// ROUND 06 | MODE: DESIGN | FRAG #86
// STATUS: PASS
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
{
// ═══════════════════════════════════════════════════════════════════
// BERIMBAU DE BARRIGA — Cordofone Afro-Brasileiro (Capoeira)
// ═══════════════════════════════════════════════════════════════════

// --- Step 0: CC map (must exist before MIDIdefs) ---
~cc = (
    vol1: 1, pan1: 2, mute1: 3, min1: 4, max1: 5, hpf1: 6, lpf1: 7, rq1: 8,
    atk1: 9, dec1: 10, sus1: 11, rls1: 12, fxDobrao: 13,
    vol2: 14, pan2: 15, mute2: 16, min2: 17, max2: 18, hpf2: 19, lpf2: 20, rq2: 21,
    atk2: 22, dec2: 23, sus2: 24, rls2: 25, fxCabaca: 26,
    vol3: 27, pan3: 28, mute3: 29, min3: 30, max3: 31, hpf3: 32, lpf3: 33, rq3: 34,
    atk3: 35, dec3: 36, sus3: 37, rls3: 38, fxCaxixi: 39,
    delMix: 40, revMix: 41, delTime: 42, revTime: 43, panic: 44
);

// --- Step 1 & 2: MIDI discovery + fallback ---
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
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

// --- Step 3: Boot ---
s.waitForBoot {
    // Default control values — all wet FX start DRY
    ~ccVals = (
        vol1: 0.25, pan1: 0.0,  mute1: 0, min1: 0,  max1: 75,  hpf1: 180, lpf1: 6500, rq1: 0.4,
        atk1: 0.001, dec1: 0.40, sus1: 0.0, rls1: 0.5, fxDobrao: 0.0,
        vol2: 0.22, pan2: -0.35, mute2: 0, min2: 36, max2: 100, hpf2: 25,  lpf2: 180,  rq2: 0.5,
        atk2: 0.005, dec2: 0.50, sus2: 0.2, rls2: 0.6, fxCabaca: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0, min3: 60, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.6,
        atk3: 0.001, dec3: 0.15, sus3: 0.0, rls3: 0.3, fxCaxixi: 0.0,
        delMix: 0.0, revMix: 0.0, delTime: 0.30, revTime: 3.0, panic: 0
    );

    // 2-line control bus allocation
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Groups
    ~synthGroup  = Group.new(s);
    ~fxGroup     = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Audio routing buses
    ~fxBus     = Bus.audio(s, 2);
    ~delayBus  = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // ---------- Zone SynthDefs ----------
    // ZONE 1 — ARAME: steel wire struck, DynKlank metal + dobrão tension
    SynthDef(\arame, { |out=0, freq=220, gate=1, amp=0.25, pan=0.0,
        atk=0.001, dec=0.4, sus=0.0, rls=0.5,
        hpf=180, lpf=6500, rq=0.4, vol=0.25, mute=0, fxDobrao=0.0|
        var env, exciter, klank, tone, sig, dob;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        dob = fxDobrao.linlin(0, 1, 1.0, 1.12);
        exciter = WhiteNoise.ar(0.7) * EnvGen.kr(Env.perc(0.0005, 0.02));
        klank = DynKlank.ar(`[
            freq * dob * [1.0, 2.01, 3.03, 4.07, 5.11, 6.17],
            [1.0, 0.6, 0.4, 0.25, 0.15, 0.08],
            [1.0, 0.9, 0.7, 0.5, 0.35, 0.25]
        ], exciter, decayscale: (dec * 3.0) + 0.5);
        tone = SinOsc.ar(freq * dob, 0, 0.12) * EnvGen.kr(Env.perc(0.001, 0.18));
        sig = klank + tone;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ZONE 2 — CABAÇA: dry gourd body resonance
    SynthDef(\cabaca, { |out=0, freq=110, gate=1, amp=0.25, pan=0.0,
        atk=0.005, dec=0.5, sus=0.2, rls=0.6,
        hpf=25, lpf=180, rq=0.5, vol=0.22, mute=0, fxCabaca=0.0|
        var env, click, body, res, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        click = WhiteNoise.ar(0.5) * EnvGen.kr(Env.perc(0.0005, 0.03));
        body = SinOsc.ar(freq, 0, 0.7) + (SinOsc.ar(freq * 1.5, 0, 0.3));
        sig = body + click;
        res = BPF.ar(sig, (freq * 2.2).clip(60, 900), 0.3);
        sig = sig + (res * fxCabaca * 0.6);
        sig = RLPF.ar(sig, lpf * (1 + (fxCabaca * 2)), rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ZONE 3 — CAXIXI: shaker grain texture
    SynthDef(\caxixi, { |out=0, freq=440, gate=1, amp=0.2, pan=0.0,
        atk=0.001, dec=0.15, sus=0.0, rls=0.3,
        hpf=160, lpf=3200, rq=0.6, vol=0.2, mute=0, fxCaxixi=0.0|
        var env, noise, grain, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        noise = WhiteNoise.ar(0.5);
        sig = BPF.ar(noise, freq.clip(200, 8000), rq);
        grain = HPF.ar(noise, (freq * 1.5).clip(300, 12000)) * fxCaxixi * 0.5;
        sig = sig + grain;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ---------- FX SynthDefs ----------
    SynthDef(\fxDelay, { |in, out, delMix=0.0, delTime=0.3|
        var sig, dly;
        sig = In.ar(in, 2);
        dly = CombL.ar(sig, 1.0, delTime.lag(0.1), 3.0);
        dly = AllpassC.ar(dly, 0.02, 0.005, 0.5);
        Out.ar(out, (sig * (1 - delMix)) + (dly * delMix));
    }).add;

    SynthDef(\fxReverb, { |in, out, revMix=0.0, revTime=3.0|
        var sig, rev;
        sig = In.ar(in, 2);
        rev = FreeVerb2.ar(sig[0], sig[1], 1.0, 0.9, revTime.linlin(0.2, 8.0, 0.25, 0.95));
        Out.ar(out, (sig * (1 - revMix)) + (rev * revMix));
    }).add;

    SynthDef(\safetyLimiter, { |in, out, amp=0.92|
        var sig;
        sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, amp, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync; // CRITICAL — SynthDefs must exist before instantiating FX

    // ---------- FX chain ----------
    Synth(\fxDelay, [
        \in, ~fxBus.index, \out, ~delayBus.index,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap
    ], ~fxGroup, \addToTail);

    Synth(\fxReverb, [
        \in, ~delayBus.index, \out, ~masterBus.index,
        \revMix, ~buses[\revMix].asMap, \revTime, ~buses[\revTime].asMap
    ], ~fxGroup, \addToTail);

    Synth(\safetyLimiter, [
        \in, ~masterBus.index, \out, 0
    ], ~masterGroup, \addToTail);

    // ---------- Voice tracking ----------
    ~zoneNotes = Array.fill(3, { Array.fill(128, { [] }) });

    ~release = { |noteNum|
        ~zoneNotes.do { |zone|
            zone[noteNum].do(_.set(\gate, 0));
            zone[noteNum] = [];
        };
    };

    ~zoneSynthInfo = [
        (z: "1", synth: \arame,  fx: \fxDobrao),
        (z: "2", synth: \cabaca, fx: \fxCabaca),
        (z: "3", synth: \caxixi, fx: \fxCaxixi)
    ];

    // ---------- MIDI handlers ----------
    MIDIdef.noteOn(\on, { |vel, noteNum, chan, src|
        var amp = vel / 127.0;
        ~zoneSynthInfo.do { |info, i|
            var z = info.z;
            if((noteNum >= ~ccVals[("min" ++ z).asSymbol]) and: { noteNum <= ~ccVals[("max" ++ z).asSymbol] }) {
                var syn = Synth(info.synth, [
                    \out, ~fxBus.index,
                    \freq, noteNum.midicps, \amp, amp,
                    \hpf, ~buses[("hpf" ++ z).asSymbol].asMap,
                    \lpf, ~buses[("lpf" ++ z).asSymbol].asMap,
                    \rq,  ~buses[("rq"  ++ z).asSymbol].asMap,
                    \vol, ~buses[("vol" ++ z).asSymbol].asMap,
                    \pan, ~buses[("pan" ++ z).asSymbol].asMap,
                    \mute, ~buses[("mute"++ z).asSymbol].asMap,
                    \atk, ~buses[("atk" ++ z).asSymbol].asMap,
                    \dec, ~buses[("dec" ++ z).asSymbol].asMap,
                    \sus, ~buses[("sus" ++ z).asSymbol].asMap,
                    \rls, ~buses[("rls" ++ z).asSymbol].asMap,
                    info.fx, ~buses[info.fx].asMap
                ], ~synthGroup);
                ~zoneNotes[i][noteNum] = ~zoneNotes[i][noteNum].add(syn);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\off, { |vel, noteNum, chan, src|
        3.do { |i|
            ~zoneNotes[i][noteNum].do(_.set(\gate, 0));
            ~zoneNotes[i][noteNum] = [];
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") }  { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.contains("sus") } { norm }
                    { ks.matchRegexp("atk|dec|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
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

    MIDIdef.cc(\panic, { |val|
        if(val > 63) { 128.do { |i| ~release.(i) }; "PANIC".postln };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ---------- Zone metadata for GUI ----------
    ~zoneMeta = [
        (title: "ARAME",  desc: "steel wire · dobrão tension", fxKey: "fxDobrao", fxLabel: "DOBRÃO TENSION", z: 1),
        (title: "CABAÇA", desc: "gourd body · dry resonance",  fxKey: "fxCabaca", fxLabel: "GOURD RESONANCE", z: 2),
        (title: "CAXIXI", desc: "shaker · grain texture",      fxKey: "fxCaxixi", fxLabel: "SHAKER GRAIN",    z: 3)
    ];

    // Helper: slider factory (defined before defer uses it)
    ~mkSlider = { |parent, rect, key, spec, label|
        var ez;
        ez = EZSlider(parent, rect, label ++ " " ++ ~cc[key], spec,
            { |e| ~ccVals[key] = e.value; ~buses[key].set(e.value) });
        ~ui[key] = { |v| ez.value = v };
        ez;
    };

    // ---------- Paginated GUI ----------
    defer {
        var screen, winW, winH, pages, bar, tabBtns;
        screen = Window.availableBounds;
        winW = 620;
        winH = min(780, screen.height - 60);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };

        ~mainWin = Window("BERIMBAU DE BARRIGA — Cordofone Afro-Brasileiro",
            Rect((screen.width - winW) / 2, (screen.height - winH) / 2, winW, winH), scroll: true);
        ~mainWin.background = Color(0.07, 0.08, 0.07);

        ~ui = ();
        pages = [];
        tabBtns = [];

        // Tab buttons
        3.do { |i|
            var idx = i;
            var zm = ~zoneMeta[idx];
            tabBtns = tabBtns.add(
                Button(~mainWin, Rect(10 + (idx * 200), 6, 195, 30))
                    .states_([[zm.title, Color.white, Color(0.12, 0.28, 0.12)],
                              [zm.title, Color.white, Color(0.28, 0.55, 0.22)]])
                    .action_({ |b|
                        pages.do { |p, j| p.visible = (j == idx) };
                        tabBtns.do { |tb, j| tb.value = if(j == idx, 1, 0) };
                    })
            );
        };
        tabBtns[0].value = 1;

        // Zone pages — built in ONE loop
        ~zoneMeta.do { |zm, idx|
            var z = zm.z.asString;
            var page = CompositeView(~mainWin, Rect(0, 42, winW, 272));
            page.background = Color(0.09, 0.10, 0.09);
            page.visible = (idx == 0);
            pages = pages.add(page);

            StaticText(page, Rect(10, 6, 580, 18))
                .string_("ZONE " ++ (idx + 1) ++ " · " ++ zm.title ++ " · " ++ zm.desc)
                .font_(Font("Monaco", 11, true))
                .stringColor_(Color(0.6, 0.85, 0.5));

            EZRanger(page, Rect(10, 28, 280, 34),
                "RANGE " ++ ~cc[("min" ++ z).asSymbol] ++ "/" ++ ~cc[("max" ++ z).asSymbol],
                ControlSpec(0, 127, \lin, 1, 0),
                { |ez|
                    ~ccVals[("min" ++ z).asSymbol] = ez.lo;
                    ~ccVals[("max" ++ z).asSymbol] = ez.hi;
                    ~buses[("min" ++ z).asSymbol].set(ez.lo);
                    ~buses[("max" ++ z).asSymbol].set(ez.hi);
                },
                ~ccVals[("min" ++ z).asSymbol], ~ccVals[("max" ++ z).asSymbol]);

            ~mkSlider.(page, Rect(300, 28, 290, 34), ("vol" ++ z).asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[("vol" ++ z).asSymbol]), "VOL");
            ~mkSlider.(page, Rect(10, 66, 280, 34), ("pan" ++ z).asSymbol,
                ControlSpec(-1, 1, \lin, 0, ~ccVals[("pan" ++ z).asSymbol]), "PAN");
            ~mkSlider.(page, Rect(300, 66, 290, 34), ("hpf" ++ z).asSymbol,
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("hpf" ++ z).asSymbol]), "HPF");
            ~mkSlider.(page, Rect(10, 104, 280, 34), ("lpf" ++ z).asSymbol,
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("lpf" ++ z).asSymbol]), "LPF");
            ~mkSlider.(page, Rect(300, 104, 290, 34), ("rq" ++ z).asSymbol,
                ControlSpec(0.05, 1.0, \exp, 0, ~ccVals[("rq" ++ z).asSymbol]), "RQ");
            ~mkSlider.(page, Rect(10, 142, 280, 34), ("atk" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("atk" ++ z).asSymbol]), "ATK");
            ~mkSlider.(page, Rect(300, 142, 290, 34), ("dec" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("dec" ++ z).asSymbol]), "DEC");
            ~mkSlider.(page, Rect(10, 180, 280, 34), ("sus" ++ z).asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[("sus" ++ z).asSymbol]), "SUS");
            ~mkSlider.(page, Rect(300, 180, 290, 34), ("rls" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("rls" ++ z).asSymbol]), "RLS");
            ~mkSlider.(page, Rect(10, 218, 580, 38), zm.fxKey.asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[zm.fxKey.asSymbol]), zm.fxLabel);
        };

        // Bottom bar
        bar = CompositeView(~mainWin, Rect(0, 320, winW, 120));
        bar.background = Color(0.10, 0.11, 0.10);

        ~mkSlider.(bar, Rect(10, 8, 280, 30), \delMix,
            ControlSpec(0, 1, \lin, 0, ~ccVals[\delMix]), "DELAY MIX");
        ~mkSlider.(bar, Rect(300, 8, 290, 30), \revMix,
            ControlSpec(0, 1, \lin, 0, ~ccVals[\revMix]), "REVERB MIX");
        ~mkSlider.(bar, Rect(10, 44, 280, 30), \delTime,
            ControlSpec(0.02, 1.0, \exp, 0, ~ccVals[\delTime]), "DELAY TIME");
        ~mkSlider.(bar, Rect(300, 44, 290, 30), \revTime,
            ControlSpec(0.2, 8.0, \exp, 0, ~ccVals[\revTime]), "REVERB TIME");

        Button(bar, Rect(10, 82, 580, 30)).states_([
            ["PANIC (ALL OFF) — CC " ++ ~cc[\panic], Color.white, Color(0.5, 0.05, 0.05)],
            ["RELEASED", Color.white, Color(0.2, 0.2, 0.2)]])
            .action_({ |b|
                if(b.value == 1) {
                    128.do { |i| ~release.(i) };
                    "PANIC".postln;
                };
            });

        ~mainWin.front;

        // 20fps poller
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

        "Berimbau de Barriga ready — 3 zones, MIDI CC mapped.".postln;
    };
};

// ~mainWin.close; 128.do { |i| ~release.(i) };
}.value;
)


// ============================================================
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Clear conflicting names
[\congadaDrone, \gungas, \mocambique, \rosarioBells].do { |n| Ndef(n).clear(2) };
[\gungasSeq, \mocambiqueSeq, \bellSeq].do { |n| Pbindef(n).clear };

// ===== Layer 1: Devotional drone — warm analog pad, 2nd harmonic for translation =====
Ndef(\congadaDrone).fadeTime = 3;
Ndef(\congadaDrone, { |freq=55, amp=0.14, cutoff=650, t_trig=1|
    var sig, env, lfo;
    lfo = SinOsc.kr(0.07).range(0.6, 1.0);
    sig = Splay.ar(
        Saw.ar(freq * [0.5, 1, 1.005, 2, 2.01]) * [0.4, 0.5, 0.5, 0.25, 0.25]
    );
    sig = (MoogFF.ar(sig, cutoff * lfo, 2.2) * 2.5).tanh;
    env = Env.perc(1.5, 4.0, 1, -2).kr(2, t_trig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * env) } { Pan2.ar(sig, 0, amp * env) };
}).play;
Ndef(\congadaDrone)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.6) };
Ndef(\congadaDrone).set(\wet10, 0.4);
Ndef(\congadaDrone).quant = 1;

// ===== Layer 2: Gungas — metallic ankle-rattle clicks =====
Ndef(\gungas).fadeTime = 2;
Ndef(\gungas, { |t_trig=1, freq=2400, amp=0.2, pan=0|
    var exc, sig, env, ring;
    env = Env.perc(0.001, 0.09, 1, -6).kr(2, t_trig);
    exc = Impulse.ar(0) + (PinkNoise.ar() * 0.4);
    ring = Ringz.ar(exc, [freq, freq*1.51, freq*2.13, freq*3.07], 0.045, 0.35).sum;
    sig = HPF.ar(ring, 1200);
    sig = (sig * 3.0).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\gungas)[11] = \filter -> { |in| (CombC.ar(in, 0.3, 0.13, 2.5) * 0.4) + in };
Ndef(\gungas).set(\wet11, 0.25);
Ndef(\gungas).quant = 1;

// ===== Layer 3: Moçambique drum — tuned membrane pulse with noise click =====
Ndef(\mocambique).fadeTime = 2;
Ndef(\mocambique, { |t_trig=1, freq=85, amp=0.28, pan=0|
    var sig, env, body, click;
    env = Env.perc(0.004, 0.35, 1, -4).kr(2, t_trig);
    body = (SinOsc.ar(freq * [1, 1.48, 2.3]) * [1, 0.35, 0.15]).sum;
    click = HPF.ar(PinkNoise.ar() * Env.perc(0.001, 0.02).kr(2, t_trig), 2000) * 0.5;
    sig = (body * 1.8).tanh + click;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\mocambique).quant = 1;

// ===== Layer 4: Rosary bells — modal bell arpeggio =====
Ndef(\rosarioBells).fadeTime = 3;
Ndef(\rosarioBells, { |t_trig=1, freq=880, amp=0.12, pan=0|
    var exc, sig, env;
    env = Env.perc(0.001, 1.6, 1, -5).kr(2, t_trig);
    exc = Impulse.ar(0);
    sig = DynKlank.ar(`[
        [freq, freq*2.01, freq*2.71, freq*3.52, freq*4.83],
        [1, 0.6, 0.4, 0.25, 0.15],
        [1, 0.9, 0.7, 0.5, 0.35]
    ], exc, 1, 0, 1.5);
    sig = (sig * 2.5).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\rosarioBells)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.5) };
Ndef(\rosarioBells).set(\wet10, 0.5);
Ndef(\rosarioBells).quant = 1;

// ===== Sequences =====
Pbindef(\mocambiqueSeq,
    \t_trig, 1,
    \freq, Pseq([85, 85, 92, 85, 78, 85, 92, 98], inf),
    \amp,  Pseq([0.30, 0.18, 0.26, 0.22, 0.30, 0.16, 0.24, 0.20], inf),
    \pan,  Pwhite(-0.3, 0.3, inf),
    \dur,  Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], inf)
);
Ndef(\mocambique)[1] = \set -> Pbindef(\mocambiqueSeq);

Pbindef(\gungasSeq,
    \t_trig, 1,
    \freq, Pexprand(2000, 4200, inf),
    \amp,  Pexprand(0.08, 0.22, inf),
    \pan,  Pwhite(-0.85, 0.85, inf),
    \dur,  Pwrand([0.125, 0.25, 0.5, 0.0625], [0.45, 0.30, 0.15, 0.10], inf)
);
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);

Pbindef(\bellSeq,
    \t_trig, 1,
    \freq, Pn(Pgeom(440, 1.2, 8), inf),
    \amp,  Pexprand(0.06, 0.14, inf),
    \pan,  Pwhite(-0.6, 0.6, inf),
    \dur,  Pwrand([0.75, 1.5, 0.375, 3.0], [0.40, 0.30, 0.20, 0.10], inf)
);
Ndef(\rosarioBells)[1] = \set -> Pbindef(\bellSeq);
)

// ===== LIVE TWEAKS =====
// Ndef(\congadaDrone).xset(\cutoff, 1400); // Brighten drone | Revert: Ndef(\congadaDrone).xset(\cutoff, 650);
// Pbindef(\gungasSeq, \dur, 0.0625); // Denser gungas | Revert: Pbindef(\gungasSeq, \dur, 0.125);
// Ndef(\mocambique).xset(\freq, 70); // Deeper drum | Revert: Ndef(\mocambique).xset(\freq, 85);
// Ndef(\rosarioBells).set(\wet10, 0.8); // More hall | Revert: Ndef(\rosarioBells).set(\wet10, 0.5);
// Pbindef(\bellSeq).stop; Ndef(\rosarioBells).fadeTime = 4; Ndef(\rosarioBells).clear(4); // Rollback bells
// Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 4; Ndef(\gungas).clear(4); // Rollback gungas
// Pbindef(\mocambiqueSeq).stop; Ndef(\mocambique).fadeTime = 4; Ndef(\mocambique).clear(4); // Rollback drum


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: PASS
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// ===== Pantanal Sunset — Corixo at Dusk =====
// Layer 1: Corixo water drone — warm sunset pad reflected on calm water
Ndef(\corixoBed).fadeTime = 4;
Ndef(\corixoBed, { |t_trig=1, freq=55, cutoff=650, amp=0.18|
    var sig, env, lfo;
    lfo = SinOsc.kr(0.05).range(0.7, 1.0);
    sig = Splay.ar(
        Saw.ar(freq * [0.5, 1, 1.005, 2, 2.01]) * [0.5, 0.5, 0.45, 0.2, 0.18]
    );
    sig = (MoogFF.ar(sig, cutoff * lfo, 2.0) * 2.2).tanh;
    env = Env.perc(2.0, 6.0, 1, -2).kr(2, t_trig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * env) } { Pan2.ar(sig, 0, amp * env) };
}).play;
Ndef(\corixoBed)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.7) };
Ndef(\corixoBed).set(\wet10, 0.45);
Ndef(\corixoBed).quant = 1;

// Layer 2: Arara-azul calls — FM squawk with wingbeat envelope
Ndef(\araraWings).fadeTime = 2;
Ndef(\araraWings, { |t_trig=1, freq=900, amp=0.14, pan=0|
    var env, mod, car, sig;
    env = Env.perc(0.005, 0.35, 1, -3).kr(2, t_trig);
    mod = SinOsc.ar(freq * 1.5) * (freq * 1.8);
    car = SinOsc.ar(freq + mod);
    sig = BPF.ar((car * 2.0).tanh, freq * 1.2, 0.6) * 3.0;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\araraWings)[11] = \filter -> { |in| (CombC.ar(in, 0.4, 0.18, 3.0) * 0.3) + in };
Ndef(\araraWings).set(\wet11, 0.3);
Ndef(\araraWings).quant = 1;

// Layer 3: Tuiuiú call — low vocal formant from the piúva canopy
Ndef(\tuiuiuCall).fadeTime = 3;
Ndef(\tuiuiuCall, { |t_trig=1, freq=180, amp=0.16, pan=0|
    var body, env, formF, sig;
    env = Env.perc(0.08, 0.9, 1, -3).kr(2, t_trig);
    body = Saw.ar(freq) * 0.7 + SinOsc.ar(freq) * 0.5;
    formF = [freq * 2.5, freq * 4.2, freq * 6.5];
    sig = BPF.ar(body, formF, 0.15).sum * 6.0;
    sig = (sig * 1.5).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\tuiuiuCall)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.92, 0.6) };
Ndef(\tuiuiuCall).set(\wet10, 0.5);
Ndef(\tuiuiuCall).quant = 1;

// Layer 4: Vitória-régia shimmer — high water reflections and insect air
Ndef(\vitoriaShimmer).fadeTime = 3;
Ndef(\vitoriaShimmer, { |t_trig=1, freq=4500, amp=0.08, pan=0|
    var env, sig;
    env = Env.perc(0.002, 0.6, 1, -4).kr(2, t_trig);
    sig = BPF.ar(PinkNoise.ar(), freq, 0.08) * 12.0;
    sig = (sig * 1.4).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\vitoriaShimmer)[12] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.95, 0.8) };
Ndef(\vitoriaShimmer).set(\wet12, 0.55);
Ndef(\vitoriaShimmer).quant = 1;

// ===== Sequences =====
Pbindef(\corixoSeq,
    \t_trig, 1,
    \freq, Pseq([55, 55, 62, 55, 49, 55, 58, 55], inf),
    \amp,  Pseq([0.20, 0.14, 0.18, 0.16, 0.20, 0.12, 0.17, 0.15], inf),
    \cutoff, Pexprand(500, 900, inf),
    \dur,  Pseq([3, 2, 3, 2, 4, 2, 3, 3], inf)
);
Ndef(\corixoBed)[1] = \set -> Pbindef(\corixoSeq);

Pbindef(\araraSeq,
    \t_trig, 1,
    \freq, Pexprand(700, 1300, inf),
    \amp,  Pexprand(0.08, 0.18, inf),
    \pan,  Pwhite(-0.8, 0.8, inf),
    \dur,  Pwrand([0.18, 0.25, 0.4, 0.6], [0.4, 0.3, 0.2, 0.1], inf)
);
Ndef(\araraWings)[1] = \set -> Pbindef(\araraSeq);

Pbindef(\tuiuiuSeq,
    \t_trig, 1,
    \freq, Pn(Pgeom(160, 1.15, 6), inf),
    \amp,  Pexprand(0.10, 0.18, inf),
    \pan,  Pwhite(-0.5, 0.5, inf),
    \dur,  Pwrand([1.2, 2.0, 3.5, 0.8], [0.35, 0.3, 0.2, 0.15], inf)
);
Ndef(\tuiuiuCall)[1] = \set -> Pbindef(\tuiuiuSeq);

Pbindef(\shimmerSeq,
    \t_trig, 1,
    \freq, Pexprand(3500, 6500, inf),
    \amp,  Pexprand(0.04, 0.10, inf),
    \pan,  Pwhite(-0.9, 0.9, inf),
    \dur,  Pwrand([0.15, 0.3, 0.5, 0.08], [0.4, 0.3, 0.2, 0.1], inf)
);
Ndef(\vitoriaShimmer)[1] = \set -> Pbindef(\shimmerSeq);
)

// ===== LIVE TWEAKS =====
// Ndef(\corixoBed).xset(\cutoff, 1100); // Brighter sunset glow | Revert: Ndef(\corixoBed).xset(\cutoff, 650);
// Pbindef(\araraSeq, \dur, 0.1); // Denser macaw flock | Revert: Pbindef(\araraSeq, \dur, 0.25);
// Ndef(\tuiuiuCall).xset(\freq, 140); // Deeper stork call | Revert: Ndef(\tuiuiuCall).xset(\freq, 180);
// Ndef(\vitoriaShimmer).set(\wet12, 0.8); // More water shimmer | Revert: Ndef(\vitoriaShimmer).set(\wet12, 0.55);
// Pbindef(\shimmerSeq).stop; Ndef(\vitoriaShimmer).fadeTime = 4; Ndef(\vitoriaShimmer).clear(4); // Rollback shimmer
// Pbindef(\tuiuiuSeq).stop; Ndef(\tuiuiuCall).fadeTime = 4; Ndef(\tuiuiuCall).clear(4); // Rollback tuiuiu
// Pbindef(\araraSeq).stop; Ndef(\araraWings).fadeTime = 4; Ndef(\araraWings).clear(4); // Rollback araras
// Pbindef(\corixoSeq).stop; Ndef(\corixoBed).fadeTime = 4; Ndef(\corixoBed).clear(4); // Rollback corixo

