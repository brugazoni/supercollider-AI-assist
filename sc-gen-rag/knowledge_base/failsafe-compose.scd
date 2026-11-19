// Source: HIGH-T-custom-compose-240426.scd [Block 2]
// MODE: compose
// THEME: FIXED: Kills the routine if it is already running to prevent _RoutineResume crash
// KEYWORDS: already, compose, crash, fixed, kills, phrase_glass, phrase_glitch, prevent, routine, routineresume, running, sentence1, sentence4, the, word_harsh, word_thud
(
// FIXED: Kills the routine if it is already running to prevent _RoutineResume crash
Tdef(\score).stop;

Tdef(\score, {
    "0:00 - SENTENCE 1: Firewall Red (Start)".postln;
    Ndef(\sentence1).play;
    // FIXED: Using \ctrlGate to hold the envelope open
    Ndef(\sentence1).set(\ctrlGate, 1, \filterSweep, 500);

    20.wait;

    "0:20 - SENTENCE 1: System Overwhelmed (FX Mod)".postln;
    Ndef(\sentence1).fadeTime = 10;
    Ndef(\sentence1).xset(\wet10, 0.8, \freqMult, 1.5, \filterSweep, 4000);

    20.wait;

    "0:40 - PHRASE A & B: Glass Variables & Glitch Sequences".postln;
    // FIXED: Closing the ctrlGate
    Ndef(\sentence1).set(\ctrlGate, 0);
    Ndef(\phrase_glass).play;
    Ndef(\phrase_glass).set(\t_trig, 1, \modIdx, 4);
    Pbindef(\phrase_glitch).play;

    7.wait;

    "0:47 - PHRASE VARIATION".postln;
    Ndef(\phrase_glass).set(\t_trig, 1, \modIdx, 10);

    3.wait;

    "0:50 - WORDS: Entropy Breakdown (Rapid Gestures)".postln;
    Pbindef(\phrase_glitch).stop;

    Ndef(\word_harsh).play; Ndef(\word_harsh).set(\t_trig, 1);
    0.4.wait;
    Ndef(\word_thud).play; Ndef(\word_thud).set(\t_trig, 1);
    0.6.wait;
    Ndef(\word_harsh).set(\t_trig, 1);
    0.2.wait;
    Ndef(\word_harsh).set(\t_trig, 1);
    0.8.wait;
    Ndef(\word_thud).set(\t_trig, 1);

    2.wait;

    "0:56 - SENTENCE 4: Existential Code (Choir Drone)".postln;
    Ndef(\sentence4).play;
    Ndef(\sentence4).set(\ctrlGate, 1, \wet10, 0.6);

    20.wait;

    "1:16 - SENTENCE 4: Defiance (Detuning)".postln;
    Ndef(\sentence4).fadeTime = 15;
    Ndef(\sentence4).xset(\detune, 0.15, \wet10, 0.9);

    20.wait;

    "1:36 - END OF COMPOSITION: Global Cleanup".postln;
    Ndef(\sentence4).set(\ctrlGate, 0);
    Ndef.clear(15);
    "Score Finished.".postln;

}).play;
)

// Source: HIGH-T-custom-compose-orbital-radio.scd [Block 1]
// MODE: compose
// THEME: Execute this entire block synchronously
// KEYWORDS: block, codePingSweep, combl, compose, dataPulsar, entire, execute, freeverb2, rlpf, safetyLimiter, saw, sinosc, skyPad, synchronously, whitenoise
(
// Execute this entire block synchronously
s.waitForBoot({

    // 1. Critical Hardware Protection: Master Limiter
    SynthDef(\safetyLimiter, {
        var in = In.ar(0, 2);
        // Explicit 0.85 protection strictly specified in directives
        var safe = Limiter.ar(in, 0.85);
        ReplaceOut.ar(0, safe);
    }).add;

    s.sync;

    // Register Safety Limiter securely surviving all Cmd + . (ServerTree -> RootNode mapping)
    ServerTree.removeAll;
    ServerTree.add({
        Synth.tail(RootNode(s), \safetyLimiter);
    });
    // Trigger ServerTree explicitly on script init
    s.freeAll;

    s.sync;


    // ==========================================
    // "FRAGMENTED RADIO & ORBITAL STREAM" PROMPT INTERPRETATION
    // Adapting "Fluent", "Spacing", "Hungarian push circ", "radiation", "Sky", "embedded" into sonic properties
    // ==========================================

    // 2. Synthesizers setup (All instruments defined cleanly via NodeProxies as per Rule 3)

    // Instrument A: \dataPulsar -> Reflecting corrupted strings & coding elements
    Ndef(\dataPulsar).ar(2);
    Ndef(\dataPulsar).fadeTime = 0.5;
    Ndef(\dataPulsar, { |freq=400, amp=0.15, freqMult=1, ampMod=1, t_trig=1|
        var trigenv = EnvGen.kr(Env.perc(0.01, 0.1), t_trig); // Triggerable envelopment
        var panner = SinOsc.kr(12).range(-0.5, 0.5); // High speed panner -> localized stream feel
        // Sine synth priority for cleanliness, combining harmonics and smoothed high frequency rhythm
        var sig = SinOsc.ar([freq, freq*2] * freqMult) + LPF.ar(WhiteNoise.ar(0.1), freq * 1.5);
        Pan2.ar(sig.sum, panner) * trigenv * ampMod * amp;
    });

    // Proxy FX: Wet Mix = 0 initial. A ping pong spacing
    Ndef(\dataPulsar)[10] = \filter -> { |in| CombL.ar(in, 0.2, [0.12, 0.16], 1.5) };
    Ndef(\dataPulsar).set(\wet10, 0);


    // Instrument B: \skyPad -> Reflecting words "Fluent", "Ocean", "temporary", "gangster skyline" (thick but clean bass sweeps)
    Ndef(\skyPad).ar(2);
    Ndef(\skyPad).fadeTime = 3.5;
    Ndef(\skyPad, { |freq=110, amp=0.35, freqMult=1, ampMod=1, cutoff=800, rq=0.4, t_trig=1|
        // Utilizing a sustainable slow attack ASR requiring active resetting trigger protection without locking structure
        var slowEnv = EnvGen.kr(Env.asr(1.0, 1.0, 3.5), t_trig);
        var subOs = SinOsc.ar(freq * 0.5 * freqMult);
        var topOs = Saw.ar([freq * freqMult, freq * 1.015 * freqMult]);

        var sig = RLPF.ar(subOs + (topOs*0.3), cutoff, rq);
        sig = sig * slowEnv * ampMod * amp;
        Splay.ar(sig);
    });

    // Proxy FX: Grand Sky Verb initialized as wet10=0 strictly via set calls prior mapping automation
    Ndef(\skyPad)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2) };
    Ndef(\skyPad).set(\wet10, 0);


    s.sync;

    // 3. Start General UI as directed explicitly before structural triggering
    s.makeGui;


    // ==========================================
    // SCORE & ABSOLUTE TIME GESTURE SYSTEM
    // Using single explicit Time Sequence via Tdef -> Pbindef architecture control bounds
    // ==========================================

    Tdef(\hungarianRadiatorFlow, {

        "Initiating Sequence... Listening to Stream.".postln;

        // Immediate State Changes Setters via instant `.set` explicitly handling node values vs temporal `.xset` bindings.
        Ndef(\skyPad).set(\t_trig, 1, \cutoff, 400);
        Ndef(\dataPulsar).set(\freq, 400);

        1.wait;

        "Opening Sky Base Layer...".postln;
        Ndef(\skyPad).play;
        Ndef(\skyPad).xset(\freq, 60, \freqMult, 1, \wet10, 0.3);

        2.5.wait;

        "Data Packet Transmissions Beginning (Radiation & Output Hooks) ...".postln;
        Ndef(\dataPulsar).play;

        // Linking node rhythm controls into an outer pattern sending values structurally inward per spec definition rule handling target bindings manually:
        Pbindef(\codePingSweep,
            \type, \set,
            \id, Ndef(\dataPulsar).group,
            \args, [\freq, \freqMult, \t_trig, \ampMod],
            \t_trig, 1,
            \freq, Pxrand([400, 800, 600, 1200], inf),
            \ampMod, Pwhite(0.5, 1.2, inf),
            \dur, Prand([0.15, 0.1, 0.3], inf)
        ).play;

        4.wait;

        "Lifting Modulators & Effects Smoothly [Barber-Dur sweep action]".postln;
        Ndef(\skyPad).xset(\freqMult, 1.5, \cutoff, 1800, \wet10, 0.6); // Expanding via crossfading sweeps securely using xset proxy handling mapping rules explicitly
        Ndef(\dataPulsar).xset(\wet10, 0.45); // Turn Echo Stream Flow upwards smoothly

        5.wait;

        // Changing sequences dynamically over flow structure. Use pattern binding durations for sync modulation gestures
        Pbindef(\codePingSweep,
            \dur, Prand([0.05, 0.08, 0.02], inf),
            \freqMult, Pseq([1, 1.5, 2.0, 1.1], inf)
        );
        Ndef(\skyPad).xset(\ampMod, 1.4);

        6.wait;

        "Returning Signal toward Submerged Neutral Point ...".postln;
        Ndef(\skyPad).xset(\freqMult, 0.75, \cutoff, 300, \wet10, 0.8, \ampMod, 0.8);

        // Set hard rhythmic resets mapping specifically `.set()` instant constraints as requested cleanly over rulesets mappings checks natively avoiding overlapping overlaps failures bindings
        Pbindef(\codePingSweep, \dur, 0.5, \freq, 200, \freqMult, 1);
        Ndef(\dataPulsar).set(\ampMod, 0.5);

        4.wait;

        // Final Clearance phase procedures to adhere completely ending sequence logic rules accurately cleaning
        "End Routine Transmissions Commencing. Exiting Sequences gracefully.".postln;

        // Strict explicit shutdown pattern triggers stopping and long `.clear(xx)` procedures for all continuous instances proxies proxies correctly mapping explicitly per node
        Pbindef(\codePingSweep).stop;

        Ndef(\skyPad).clear(10);
        Ndef(\dataPulsar).clear(10);

        10.wait;

        "Operation Closed Properly.".postln;

    }).play;
});
)

// Source: compose-cognition-FIXED.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS & BUFFER ROUTING
// KEYWORDS: acqGrains, attentionSnap, bpf, buffer, bus, compose, dataStream, dynklank, focusClick, formant, freeverb2, glassResonator, logicSeq, masterMix, memoryEcho, pre, pulseEngine, recursiveFeedback, rhythmBlocks, rlpf, routing, safetyLimiter, saw, setup, sparkleGrain, spectralFilter, thoughtPattern, thoughtSeq, vocalicTexture
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    // Global Buffers for FFT and Delays
    ~fftBufA = Buffer.alloc(s, 2048);
    ~fftBufB = Buffer.alloc(s, 2048);
    ~delayBuf = Buffer.alloc(s, s.sampleRate * 5, 2);

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\sparkleGrain, { |out=0, freq=4000, amp=0.1, pan=0, dur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, dur), doneAction: 2);
        var sig = FSinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pulseEngine, { |out=0, freq=400, fmIndex=2, amp=0.2, pan=0, dur=0.1|
        var env = EnvGen.ar(Env.perc(0.005, dur), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\glassResonator, { |out=0, freq=2000, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        var exc = Impulse.ar(0);
        var sig = DynKlank.ar(`[[1, 2.04, 3.16, 4.42] * freq, [1, 0.7, 0.5, 0.2], [1, 0.8, 0.6, 0.4]], exc);
        Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    SynthDef(\thoughtPattern, { |out=0, freq=440, modRatio=2, modIndex=1, amp=0.2, gate=1, pan=0|
        var env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.5, 0.2), gate, doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * modIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\focusClick, { |out=0, freq=8000, amp=0.5, pan=0, dur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, dur), doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.05) * env * 10;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\dataStream, { |freq=100, cutoff=1000, rq=0.5, amp=0, lfoRate=0, lfoDepth=0|
        var lfo = SinOsc.kr(lfoRate).range(1 - lfoDepth, 1 + lfoDepth);
        var sig = Pulse.ar([freq, freq * 1.01] * lfo, 0.5) + Saw.ar([freq * 0.5, freq * 0.505]);
        sig = RLPF.ar(sig, (cutoff * lfo).clip(20, 18000), rq);
        sig * amp;
    });

    Ndef(\spectralFilter, { |amp=0, bandWidth=100, freqShift=0|
        var sigL = PinkNoise.ar(1);
        var sigR = PinkNoise.ar(1);
        var chainL = FFT(~fftBufA, sigL);
        var chainR = FFT(~fftBufB, sigR);
        var sig, centerFreq, rq;

        chainL = PV_BinScramble(chainL, 0.8, 0.1, 1);
        chainR = PV_BinScramble(chainR, 0.8, 0.1, 1);
        sig = IFFT([chainL, chainR]);

        centerFreq = freqShift.linlin(-500, 500, 100, 8000).clip(50, 15000);
        rq = (bandWidth / 2000).clip(0.01, 1.0);
        sig = BPF.ar(sig, centerFreq, rq);
        sig * amp * 10;
    });

    Ndef(\memoryEcho, { |delayTime=1.0, feedback=0.5, amp=0|
        var in = Ndef.ar(\dataStream, 2);
        var local = LocalIn.ar(2) + in;
        var delayed = BufDelayL.ar(~delayBuf.bufnum, local, delayTime.lag(0.1));
        LocalOut.ar(delayed * feedback);
        delayed * amp;
    });

    Ndef(\vocalicTexture, { |formantFreq=400, formantWidth=100, amp=0|
        var sig = Formant.ar([120, 122], formantFreq, formantWidth);
        sig = sig + Formant.ar([60, 61], formantFreq * 1.5, formantWidth * 0.8);
        sig * amp * 0.5;
    });

    Ndef(\recursiveFeedback, { |delayTime=0.2, feedback=0.9, amp=0|
        var in = Ndef.ar(\vocalicTexture, 2);
        var local = LocalIn.ar(2) + in;
        var delayed = DelayL.ar(local, 1.0, delayTime.lag(0.1));
        LocalOut.ar(delayed * feedback);
        delayed * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var data = Ndef.ar(\dataStream, 2);
        var echo = Ndef.ar(\memoryEcho, 2);
        var spec = Ndef.ar(\spectralFilter, 2);
        var voc = Ndef.ar(\vocalicTexture, 2);
        var rec = Ndef.ar(\recursiveFeedback, 2);
        synths + data + echo + spec + voc + rec;
    });

    // JITLib FX Slots
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.8, damp: 0.2) };
    Ndef(\masterMix)[11] = \filter -> { |in| DelayN.ar(in, 1.0, 0.3) };

    Ndef(\masterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\masterMix).play;

    s.sync;

// --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: Server Buffer]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        0.5.wait;

        "0:00.5 - [Cue 2: Initial Acquisition]".postln;
        Pbindef(\acqGrains,
            \instrument, \sparkleGrain,
            \out, ~synthBus,
            \dur, Pexprand(0.01, 0.08, inf),
            \freq, Pexprand(2000, 8000, inf),
            \amp, Pexprand(0.05, 0.15, inf)
        ).play;

        // Active Wait: 7.5s
        7.do { Pbindef(\acqGrains, \pan, rrand(-0.8, 0.8)); 1.wait; };
        0.5.wait;

        "0:08.0 - [Cue 3: Data Stream Emerges]".postln;
        Pbindef(\acqGrains).stop;
        Ndef(\dataStream).fadeTime = 2.0;
        Ndef(\dataStream).xset(\cutoff, 200, \rq, 0.5, \amp, 0.5);

        // Active Wait: 10s
        5.do { |i| Ndef(\dataStream).xset(\cutoff, 200 + (i * 100)); 2.wait; };

        "0:18.0 - [Cue 4: Information Storage]".postln;
        Pbindef(\rhythmBlocks,
            \instrument, \pulseEngine,
            \out, ~synthBus,
            \dur, Pseq([0.3, 0.5, 0.2, 0.8], inf),
            \freq, Pseq([400, 800, 600, 1200], inf),
            \fmIndex, Pwhite(1.0, 3.0, inf),
            \amp, 0.2
        ).play;
        Ndef(\dataStream).fadeTime = 12.0;
        Ndef(\dataStream).xset(\freq, 80);

        // Active Wait: 12s
        6.do { 2.wait; };

        "0:30.0 - [Cue 5: Retrieval Flash]".postln;
        Pbindef(\rhythmBlocks).stop;
        Synth(\glassResonator, [\out, ~synthBus, \freq, 2000, \amp, 0.6]);
        3.wait;

        "0:33.0 - [Cue 6: Transformative Process]".postln;
        Ndef(\dataStream).fadeTime = 12.0;
        Ndef(\dataStream).xset(\lfoRate, 3.0, \lfoDepth, 0.5);
        6.do { 2.wait; };

        "0:45.0 - [Cue 7: Applied Complexity]".postln;
        Pbindef(\logicSeq,
            \instrument, \thoughtPattern,
            \out, ~synthBus,
            \dur, 0.25,
            \degree, Pseq([0, 2, 4, 7, 9, 12, 11, 7, 5, 2, 0], inf),
            \scale, Scale.minor,
            \modRatio, 2,
            \modIndex, Pseq([0.5, 1.2, 0.8, 1.5], inf),
            \amp, 0.3
        ).play;
        Ndef(\masterMix).fadeTime = 3.0;
        Ndef(\masterMix).xset(\wet10, 0.4);

        // Active Wait: 15s
        5.do { Pbindef(\logicSeq, \modRatio, rrand(1.0, 4.0)); 3.wait; };

        "1:00.0 - [Cue 8: Intrinsic Limit - Density Climax]".postln;
        Ndef(\dataStream).fadeTime = 10.0;
        Ndef(\dataStream).xset(\cutoff, 18000, \amp, 0.7);
        Pbindef(\logicSeq, \modIndex, 5.0, \dur, 0.125);
        5.do { 2.wait; };

        "1:10.0 - [Cue 9: Overload & Reset]".postln;
        Pbindef(\logicSeq).stop;
        Ndef(\dataStream).fadeTime = 0.5;
        Ndef(\dataStream).xset(\cutoff, 100, \amp, 0.1, \lfoDepth, 0);
        Ndef(\masterMix).fadeTime = 1.0;
        Ndef(\masterMix).xset(\wet10, 0.1);
        5.wait;

        "1:15.0 - [Cue 10: Lingering Data]".postln;
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\delayTime, 2.0, \feedback, 0.7, \amp, 1.0);
        Ndef(\dataStream).fadeTime = 5.0;
        Ndef(\dataStream).xset(\amp, 0.3);

        // Active Wait: 30s
        10.do { |i| Ndef(\memoryEcho).xset(\delayTime, 2.0 + (sin(i)*0.5)); 3.wait; };

        "1:45.0 - [Cue 11: Perceptual Filter]".postln;
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\amp, 0);
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0.2, \bandWidth, 100, \freqShift, 0);
        5.wait;

        "1:50.0 - [Cue 12: Organizing Sensory Info]".postln;
        Ndef(\spectralFilter).fadeTime = 15.0;
        Ndef(\spectralFilter).xset(\bandWidth, 1000, \freqShift, 200);
        5.do { 3.wait; };

        "2:05.0 - [Cue 13: Attention Snap]".postln;
        Ndef(\spectralFilter).set(\amp, 0);
        Pbindef(\attentionSnap,
            \instrument, \focusClick,
            \out, ~synthBus,
            \dur, 0.05,
            \freq, Pseq([8000, 12000, 6000], inf),
            \amp, 0.8
        ).play;
        Ndef(\masterMix).set(\wet10, 0);
        3.wait;

        "2:08.0 - [Cue 14: Filtering Irrelevance]".postln;
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0.1);
        Ndef(\spectralFilter).fadeTime = 7.0;
        Ndef(\spectralFilter).xset(\bandWidth, 50);
        Pbindef(\attentionSnap, \dur, Pseq([0.5, 1.0, 0.7], inf), \amp, 0.5);
        7.wait;

        "2:15.0 - [Cue 15: Working Memory]".postln;
        Pbindef(\attentionSnap).stop;
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0);
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\freq, 440, \amp, 0.4, \cutoff, 10000, \lfoDepth, 0);
        Pbindef(\logicSeq,
            \dur, 0.5,
            \degree, Pseq([0, 2, 4, 7], inf),
            \modIndex, 1.0
        ).play;
        10.wait;

        "2:25.0 - [Cue 16: Long-Term Memory Echoes]".postln;
        Ndef(\memoryEcho).fadeTime = 15.0;
        Ndef(\memoryEcho).xset(\delayTime, 4.0, \feedback, 0.85, \amp, 1.0);
        Pbindef(\logicSeq, \degree, Pseq([0, 4, 7, 12], inf).stutter(2));
        5.do { 3.wait; };

        "2:40.0 - [Cue 17: Memory Distortion & Recall]".postln;
        10.do {
            Ndef(\memoryEcho).set(\delayTime, rrand(0.1, 5.0), \feedback, rrand(0.5, 0.95));
            0.5.wait;
        };
        Ndef(\memoryEcho).fadeTime = 1.0;
        Ndef(\memoryEcho).xset(\delayTime, 1.0, \feedback, 0.6);
        5.wait;

        "2:50.0 - [Cue 18: Thinking - Concept Formation]".postln;
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\amp, 0);
        Pbindef(\logicSeq,
            \degree, Ptuple([Pseq([0, 2, 4, 7], inf), Pseq([12, 10, 7, 5], inf)]),
            \dur, Pseq([0.2, 0.4, 0.3], inf)
        );
        Pbindef(\thoughtSeq,
            \instrument, \thoughtPattern,
            \out, ~synthBus,
            \dur, Pseq([0.6, 0.6, 1.2], inf),
            \freq, Pseq([300, 400, 500], inf),
            \modRatio, 1.5,
            \modIndex, 2,
            \amp, 0.25
        ).play;
        5.do { 3.wait; };

        "3:05.0 - [Cue 19: Reasoning & Problem Solving]".postln;
        Pbindef(\logicSeq, \degree, Pseq([Pwhite(0, 11, 8), Pseq([0, 4, 7], 1)], inf));
        Pbindef(\thoughtSeq, \freq, Pseq([Pwhite(200, 800, 4), Pseq([440, 550, 660], 1)], inf));
        Ndef(\masterMix).fadeTime = 5.0;
        Ndef(\masterMix).xset(\wet10, 0.6);
        10.do { 2.wait; };

        "3:25.0 - [Cue 20: Decision Making]".postln;
        Pbindef(\logicSeq).stop;
        Pbindef(\thoughtSeq).stop;
        Ndef(\dataStream).fadeTime = 0.5;
        Ndef(\dataStream).xset(\freq, 440, \amp, 0.5, \cutoff, 20000);
        5.wait;

        "3:30.0 - [Cue 21: Language - Acquisition]".postln;
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\vocalicTexture).fadeTime = 2.0;
        Ndef(\vocalicTexture).xset(\formantFreq, 400, \formantWidth, 100, \amp, 0.3);
        10.wait;

        "3:40.0 - [Cue 22: Comprehension & Production]".postln;
        Ndef(\vocalicTexture).fadeTime = 15.0;
        Pbindef(\rhythmBlocks,
            \instrument, \focusClick,
            \out, ~synthBus,
            \dur, Pseq([0.1, 0.2, 0.1, 0.4], inf),
            \freq, Pwhite(1000, 3000, inf),
            \amp, 0.3
        ).play;
        5.do { Ndef(\vocalicTexture).xset(\formantFreq, [700, 1200, 900, 500].choose, \formantWidth, 50); 3.wait; };

        "3:55.0 - [Cue 23: Metacognition - Self-Reflection]".postln;
        Pbindef(\rhythmBlocks).stop;
        Ndef(\recursiveFeedback).fadeTime = 2.0;
        Ndef(\recursiveFeedback).xset(\delayTime, 0.2, \feedback, 0.9, \amp, 1.0);
        Ndef(\vocalicTexture).fadeTime = 5.0;
        Ndef(\vocalicTexture).xset(\amp, 0.2);
        5.do { 3.wait; };

        "4:10.0 - [Cue 24: Conscious & Unconscious]".postln;
        Ndef(\dataStream).fadeTime = 5.0;
        3.do {
            Ndef(\dataStream).xset(\amp, 0.6);
            2.5.wait;
            Ndef(\dataStream).xset(\amp, 0.1);
            2.5.wait;
        };

        "4:25.0 - [Cue 25: Controlled & Automatic]".postln;
        Ndef(\recursiveFeedback).fadeTime = 2.0;
        Ndef(\recursiveFeedback).xset(\amp, 0);
        15.do {
            Ndef(\dataStream).fadeTime = 0.1;
            Ndef(\dataStream).xset(\freq, [220, 440, 880, 1760].choose, \cutoff, [1000, 5000, 10000].choose, \amp, 0.4);
            Ndef(\spectralFilter).fadeTime = 0.1;
            Ndef(\spectralFilter).xset(\bandWidth, exprand(50, 2000), \freqShift, rrand(-500, 500), \amp, 0.2);
            1.wait;
        };

        "4:40.0 - [Cue 26: Final Cognitive Burst]".postln;
        Ndef(\dataStream).fadeTime = 5.0;
        Ndef(\dataStream).xset(\amp, 0.8);
        Ndef(\spectralFilter).fadeTime = 5.0;
        Ndef(\spectralFilter).xset(\amp, 0.4, \bandWidth, 5000, \freqShift, 0);
        Ndef(\masterMix).fadeTime = 3.0;
        Ndef(\masterMix).xset(\wet10, 0.9);
        10.do {
            Ndef(\dataStream).xset(\freq, exprand(1000, 10000));
            1.wait;
        };

        "4:50.0 - [Cue 27: Dissolution]".postln;
        Ndef(\dataStream).fadeTime = 2.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\spectralFilter).fadeTime = 3.0;
        Ndef(\spectralFilter).xset(\amp, 0);
        10.do { |i|
            Ndef(\masterMix).set(\wet10, 0.9 - (i * 0.09));
            1.wait;
        };

        "5:00.0 - [Cue 28: Absolute Cessation]".postln;
        Pbindef.removeAll;
        Ndef.clear(15.0); // .clear() is valid here to entirely free and drop the proxies.
        "Server fading to silence...".postln;

        6.do { 5.wait; };

        Tdef.removeAll;
        "Score Complete. Absolute Cessation.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: compose-dance.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & BUFFERS
// KEYWORDS: athleticLeap, bassEngine, buffers, bus, compose, dynklank, ensembleDrone, fluidGesture, freeverb2, frictionStage, gesture1, gesture2, gesture3, gestureSeq, heavyImpact, impactSeq, impactSeq2, impactSeq3, masterMix, memorySeq, metalSeq, moogff, pinknoise, poly1, poly2, poly3, pre, routing, safetyLimiter, saw, setup, sinosc, softImpact, tapPluck, tapSeq
(
s.waitForBoot({
    // =====================================================================
    // PRE-SETUP: BUS ROUTING & BUFFERS
    // =====================================================================
    ~synthBus = Bus.audio(s, 2);

    // Pre-allocate global buffers for FFT to prevent real-time memory drops
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);

    s.sync;

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // =====================================================================
    // 1. DISCRETE EVENT SYNTHESIZERS (Node Safe)
    // =====================================================================

    // Physical model of a wooden bar strike (Tap/Gumboot)
    SynthDef(\tapPluck, { |out=0, freq=400, decayScale=0.1, pan=0, amp=0.5|
        // Short noise burst excitation
        var exc = PinkNoise.ar(EnvGen.ar(Env.perc(0.001, 0.01)));
        // Tuned resonators for wood-like physical modeling
        var sig = DynKlank.ar(
            Ref(#[
                [1.0, 1.42, 2.3, 3.2, 4.5],
                [1.0, 0.6, 0.4, 0.2, 0.1],
                [1.0, 0.8, 0.6, 0.4, 0.2]
            ]),
            exc,
            freqscale: freq,
            decayscale: decayScale
        );
        var env = EnvGen.ar(Env.perc(0.001, decayScale), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // 2-carrier, 2-modulator FM synthesizer (Fluid Gestures)
    SynthDef(\fluidGesture, { |out=0, freq=440, carRatio=1, modRatio=1.5, index=2, atk=0.1, rel=1, pan=0, amp=0.2|
        var env = EnvGen.ar(Env.linen(atk, rel * 0.2, rel * 0.8), doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * index * freq * env;
        var car = SinOsc.ar(freq * carRatio + mod);
        Out.ar(out, Pan2.ar(car * env * amp, pan));
    }).add;

    // Low-frequency, saturated subtractive synthesizer (Heavy Footfalls)
    SynthDef(\heavyImpact, { |out=0, freq=100, subFreq=40, cutoff=800, resonance=0.2, amp=0.6, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        var pitchEnv = EnvGen.kr(Env.perc(0.001, 0.1)).exprange(1.0, 2.5);
        var sig = SinOsc.ar(subFreq * pitchEnv) + Saw.ar(freq);
        sig = MoogFF.ar(sig, cutoff * EnvGen.kr(Env.perc(0.01, 0.5)).exprange(1, 4), resonance);
        sig = (sig * 2.0).tanh; // Saturation
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // =====================================================================
    // 2. CONTINUOUS TEXTURES & EFFECTS ARCHITECTURE (JITLib)
    // =====================================================================

    // Physical model of friction (Stage floor scraping)
    Ndef(\frictionStage, {
        var cutoff = \cutoff.kr(1000, 1);
        var amp = \amp.kr(0, 0.5);
        var noiseDens = \noiseDens.kr(0, 0.5);
        var n = WhiteNoise.ar + Dust.ar(noiseDens);
        var sig = Resonz.ar(n, cutoff * LFNoise2.kr(0.5).exprange(0.8, 1.2), 0.2);
        Pan2.ar(sig * amp, LFNoise1.kr(0.2));
    });

    // Theatrical space drone
    Ndef(\ensembleDrone, {
        var amp = \amp.kr(0, 2);
        var subAmp = \subAmp.kr(0, 2);
        var sig = Mix.fill(12, { |i|
            var f = 100 * (i+1) * 1.01;
            SinOsc.ar(f) * SinOsc.kr(0.05 * (i+1)).range(0, 1) * (1 / (i+1));
        });
        var sub = SinOsc.ar(40) * subAmp;
        Pan2.ar((sig + sub) * amp * 0.2, 0);
    });

    // Master Mixer & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\frictionStage, 2) + Ndef.ar(\ensembleDrone, 2);
        discreteSynths + continuous;
    });

    // Slot 10: Spectral Resonance (FFT Delay)
    Ndef(\masterMix)[10] = \filter -> { |in|
        var smear = \smear.kr(0, 0.5);
        var shift = \shift.kr(0, 0.5);
        var chainL = FFT(~fftBufL, in[0]);
        var chainR = FFT(~fftBufR, in[1]);
        chainL = PV_MagSmear(chainL, smear);
        chainR = PV_MagSmear(chainR, smear);
        chainL = PV_MagShift(chainL, 1 + shift);
        chainR = PV_MagShift(chainR, 1 + shift);
        IFFT([chainL, chainR]);
    };

    // Slot 15: Kinetic Spatial Blur (Ping-Pong Delay)
    Ndef(\masterMix)[15] = \filter -> { |in|
        CombC.ar(in, 0.5, [0.125, 0.166], 2.0);
    };

    // Slot 20: Master Reverb
    Ndef(\masterMix)[20] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.85, damp: 0.3);
    };

    // Slot 30: Master Low-Pass Filter (For Form Operation B)
    Ndef(\masterMix)[30] = \filter -> { |in|
        LPF.ar(in, \masterLpf.kr(20000, 0.5));
    };

    // Initialize effect states
    Ndef(\masterMix).set(\wet10, 0, \wet15, 0, \wet20, 0.15, \wet30, 1.0, \masterLpf, 20000);
    Ndef(\masterMix).play;
    s.sync;

    // =====================================================================
    // 3. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        // --- PHASE I: Solo Imperative & Spatial Friction ---
        "0:00.0 - [Cue 1: Safety Initialization]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Solo Tap Ignition]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.5, 0.125, 0.125, 0.75], inf),
            \freq, Pseq([300, 400, 350, 450, 320], inf),
            \decayScale, 0.05,
            \pan, -0.8,
            \amp, 0.4
        ).play;
        5.5.wait;

        "0:06.0 - [Cue 3: Friction Entry]".postln;
        Ndef(\frictionStage).fadeTime = 4;
        Ndef(\frictionStage).xset(\amp, 0.25, \cutoff, 800);
        8.0.wait;

        "0:14.0 - [Cue 4: The Pivot]".postln;
        Pbindef(\tapSeq, \freq, Pseq([300, 400, 350, 450, 320] * 2.0, inf));
        4.5.wait;

        "0:18.5 - [Cue 5: Dynamic Suspension]".postln;
        Ndef(\ensembleDrone).fadeTime = 5;
        Ndef(\ensembleDrone).xset(\amp, 0.015); // approx -36dB
        // Active Wait State
        2.do { Ndef(\frictionStage).xset(\cutoff, rrand(800, 1200)); 5.75.wait; };

        "0:30.0 - [Cue 6: The Leap]".postln;
        Synth(\heavyImpact, [\out, ~synthBus, \amp, 0.8]);
        Pbindef(\tapSeq).stop;
        6.0.wait;

        "0:36.0 - [Cue 7: Fluid Counter-Response]".postln;
        Pbindef(\gestureSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, Pseq([2.0, 1.5, 3.0], inf),
            \freq, Pseq([600, 800, 550], inf),
            \carRatio, 1,
            \modRatio, 1.414,
            \index, Pwhite(1.5, 3.0),
            \atk, 0.5,
            \rel, 2.0,
            \pan, Pseq([0.5, 0.0, -0.5], inf),
            \amp, 0.3
        ).play;
        // Active Wait State
        2.do { Pbindef(\gestureSeq, \index, rrand(2.0, 4.0)); 4.5.wait; };

        "0:45.0 - [Cue 8: Floor Scraping Acceleration]".postln;
        Ndef(\frictionStage).xset(\cutoff, 2500);
        2.do { Ndef(\frictionStage).xset(\noiseDens, rrand(5, 10)); 5.0.wait; };

        "0:55.0 - [Cue 9: Synchronized Duo]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf), \pan, 0).play;
        3.do { Pbindef(\tapSeq, \amp, rrand(0.3, 0.5)); 4.0.wait; }; // 12s

        "1:07.0 - [Cue 10: Density Build]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.125, 0.125, 0.25], inf));
        Pbindef(\gestureSeq, \dur, Pseq([0.5, 0.75, 0.5], inf), \atk, 0.1, \rel, 0.5);
        8.0.wait;

        "1:15.0 - [Cue 11: Deceleration Arc]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, 1.0, 1.5], inf), \decayScale, 0.4);
        Pbindef(\gestureSeq, \dur, Pseq([2.0, 3.0], inf), \atk, 1.0, \rel, 3.0);
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.2, 0.4)); 5.0.wait; }; // 10s

        "1:25.0 - [Cue 12: Phase I Dissolve (Subtraction)]".postln;
        Pbindef(\tapSeq).stop;
        Pbindef(\gestureSeq).stop;
        Ndef(\frictionStage).xset(\cutoff, 600, \noiseDens, 0);
        5.0.wait;


        // --- PHASE II: Theatrical Architecture & Group Formations ---
        "1:30.0 - [Cue 13: Group Entrance]".postln;
        // Launch 3 parallel instances via Pbindefs
        Pbindef(\gesture1, \instrument, \fluidGesture, \out, ~synthBus, \dur, 1.0, \freq, 400, \carRatio, 1.0, \amp, 0.2).play;
        Pbindef(\gesture2, \instrument, \fluidGesture, \out, ~synthBus, \dur, 1.5, \freq, 400, \carRatio, 1.2, \amp, 0.2).play;
        Pbindef(\gesture3, \instrument, \fluidGesture, \out, ~synthBus, \dur, 2.0, \freq, 400, \carRatio, 1.5, \amp, 0.2).play;
        6.0.wait;

        "1:36.0 - [Cue 14: Spatial Expansion]".postln;
        Ndef(\masterMix).xset(\wet10, 0.6, \smear, 15);
        2.do { Ndef(\masterMix).xset(\shift, rrand(0.1, 0.3)); 4.5.wait; }; // 9s

        "1:45.0 - [Cue 15: The Rhythmic Grid]".postln;
        Pbindef(\tapSeq, \dur, 0.5, \freq, 600, \decayScale, 0.1, \pan, 0).play;
        7.5.wait;

        "1:52.5 - [Cue 16: Micro-Hesitation]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, Rest(0.5), 0.25, Rest(0.25), 0.5], inf));
        3.5.wait;

        "1:56.0 - [Cue 17: Baroque Refraction]".postln;
        Pbindef(\gesture1, \modRatio, 2.0, \index, 5);
        Pbindef(\gesture2, \modRatio, 3.0, \index, 4);
        Pbindef(\gesture3, \modRatio, 4.0, \index, 6);
        2.do { Ndef(\masterMix).xset(\smear, rrand(10, 20)); 5.5.wait; }; // 11s

        "2:07.0 - [Cue 18: Unison Strike]".postln;
        Synth(\heavyImpact, [\out, ~synthBus, \freq, 200, \subFreq, 80, \amp, 0.7]);
        4.0.wait;

        "2:11.0 - [Cue 19: The Empty Stage (Subtraction)]".postln;
        Pbindef(\gesture1).stop; Pbindef(\gesture2).stop; Pbindef(\gesture3).stop; Pbindef(\tapSeq).stop;
        Ndef(\masterMix).xset(\wet10, 0);
        2.do { Ndef(\frictionStage).xset(\amp, rrand(0.1, 0.2)); 4.5.wait; }; // 9s

        "2:20.0 - [Cue 20: Polyrhythmic Re-emergence]".postln;
        Pbindef(\tapSeq, \dur, 0.8, \freq, 400).play; // 5:4 ratio against 1.0
        Pbindef(\gesture1, \dur, 1.0, \freq, 300, \modRatio, 1.5).play; // 4:4
        2.do { Pbindef(\tapSeq, \pan, rrand(-0.5, 0.5)); 5.0.wait; }; // 10s

        "2:30.0 - [Cue 21: Spectral Swell]".postln;
        Ndef(\masterMix).xset(\wet10, 0.9, \smear, 30);
        8.0.wait;

        "2:38.0 - [Cue 22: The Athletic Leap]".postln;
        Pbindef(\athleticLeap, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([0.25, 0.25, 0.5], 4), \freq, Pseq([100, 150, 80], inf), \amp, 0.6).play;
        5.5.wait;

        "2:43.5 - [Cue 23: Harmonic Saturation]".postln;
        Pbindef(\gesture1, \index, 15);
        2.do { Ndef(\frictionStage).xset(\cutoff, rrand(3000, 5000)); 4.25.wait; }; // 8.5s

        "2:52.0 - [Cue 24: Kinetic Chaos]".postln;
        Pbindef(\tapSeq, \pan, Pwhite(-1.0, 1.0), \freq, Pwhite(400, 1200));
        Pbindef(\gesture1, \pan, Pwhite(-1.0, 1.0), \carRatio, Pwhite(0.5, 2.5));
        2.do { Ndef(\masterMix).xset(\smear, rrand(10, 40)); 5.0.wait; }; // 10s

        "3:02.0 - [Cue 25: The Climax Collapse]".postln;
        Pbindef(\tapSeq, \dur, 0.125);
        Pbindef(\gesture1, \dur, 0.125);
        2.do { Pbindef(\tapSeq, \freq, Pwhite(1000, 3000)); 5.0.wait; }; // 10s

        "3:12.0 - [Cue 26: The Trapdoor (Form Op C)]".postln;
        // INSTANT SUBTRACTION
        Pbindef.removeAll;
        Ndef(\masterMix).set(\wet10, 0, \wet15, 0, \wet20, 0.05);
        Ndef(\ensembleDrone).xset(\amp, 0);
        Ndef(\frictionStage).xset(\amp, 0);
        1.0.wait;


        // --- PHASE III: The Ritualistic Ground ---
        "3:13.0 - [Cue 27: Solo Ritual Tap]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pseq([1.0, 1.5, 0.5, 1.0], inf),
            \freq, 150,
            \decayScale, 0.03, // Ultra-dry
            \pan, 0,
            \amp, 0.6
        ).play;
        7.0.wait;

        "3:20.0 - [Cue 28: Earth Resonance]".postln;
        Ndef(\ensembleDrone).fadeTime = 10;
        Ndef(\ensembleDrone).xset(\amp, 0.1, \subAmp, 0.7);
        2.do { Ndef(\ensembleDrone).xset(\subAmp, rrand(0.6, 0.8)); 5.0.wait; }; // 10s

        "3:30.0 - [Cue 29: Stamping Patterns]".postln;
        Pbindef(\impactSeq,
            \instrument, \heavyImpact,
            \out, ~synthBus,
            \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf),
            \freq, 80,
            \subFreq, 35,
            \cutoff, 400,
            \amp, 0.7
        ).play;
        8.0.wait;

        "3:38.0 - [Cue 30: Metallic Accent]".postln;
        Pbindef(\metalSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, Pseq([Rest(1.5), 0.5, Rest(2.0)], inf),
            \freq, 1200,
            \modRatio, 3.14, // Inharmonic ring
            \index, 8,
            \atk, 0.01,
            \rel, 0.2,
            \amp, 0.3
        ).play;
        6.5.wait;

        "3:44.5 - [Cue 31: Ceremonial Call]".postln;
        Pbindef(\gestureSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 4.0,
            \freq, Pseq([200, 220, 190, 250], inf),
            \atk, 2.0,
            \rel, 4.0,
            \amp, 0.4
        ).play;
        2.do { Pbindef(\gestureSeq, \index, rrand(1.5, 3.0)); 4.75.wait; }; // 9.5s

        "3:54.0 - [Cue 32: The Circle Expands]".postln;
        Pbindef(\impactSeq2, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf), \freq, 85, \subFreq, 38, \amp, 0.5, \pan, -0.5, \lag, 0.05).play;
        Pbindef(\impactSeq3, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf), \freq, 75, \subFreq, 32, \amp, 0.5, \pan, 0.5, \lag, 0.08).play;
        8.0.wait;

        "4:02.0 - [Cue 33: Accelerando Ritual]".postln;
        Pbindef(\impactSeq, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        Pbindef(\impactSeq2, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        Pbindef(\impactSeq3, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        2.do { Pbindef(\tapSeq, \dur, rrand(0.25, 0.5)); 5.0.wait; }; // 10s

        "4:12.0 - [Cue 34: Iron Resonance]".postln;
        Pbindef(\metalSeq, \rel, 2.0);
        6.0.wait;

        "4:18.0 - [Cue 35: The Breath of the Crowd]".postln;
        Ndef(\frictionStage).xset(\amp, 0.4, \cutoff, 400, \noiseDens, 0);
        // Modulate amplitude slowly for breathing
        7.0.wait;

        "4:25.0 - [Cue 36: Peak Ground Sync]".postln;
        Pbindef(\impactSeq, \dur, 0.5);
        Pbindef(\impactSeq2, \dur, 0.5);
        Pbindef(\impactSeq3, \dur, 0.5);
        Pbindef(\tapSeq, \dur, 0.5);
        2.do { Ndef(\ensembleDrone).xset(\subAmp, rrand(0.8, 1.0)); 5.0.wait; }; // 10s

        "4:35.0 - [Cue 37: Sub-Bass Extension]".postln;
        Pbindef(\impactSeq, \cutoff, 200);
        5.0.wait;

        "4:40.0 - [Cue 38: Ground Dissolve (Subtraction)]".postln;
        Pbindef(\metalSeq).stop;
        Pbindef(\impactSeq2).stop; Pbindef(\impactSeq3).stop;
        5.0.wait;


        // --- PHASE IV: Kinetic Saturation & Athletic Training ---
        "4:45.0 - [Cue 39: The Starting Gun]".postln;
        Pbindef(\impactSeq).stop; Pbindef(\gestureSeq).stop;
        Pbindef(\tapSeq, \dur, 0.0625, \freq, 800, \decayScale, 0.02, \amp, 0.3).play;
        4.5.wait;

        "4:49.5 - [Cue 40: Kinetic Engine Ignition]".postln;
        Pbindef(\bassEngine,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 0.25,
            \freq, Pseq([50, 50, 60, 55], inf),
            \carRatio, 1,
            \modRatio, 2,
            \index, 10,
            \atk, 0.01,
            \rel, 0.2,
            \amp, 0.6
        ).play;
        6.5.wait;

        "4:56.0 - [Cue 41: Spatial Blur]".postln;
        Ndef(\masterMix).xset(\wet15, 0.7); // Ping-pong delay ON
        8.0.wait;

        "5:04.0 - [Cue 42: Athletic Exertion]".postln;
        Ndef(\frictionStage).xset(\amp, 0.5, \cutoff, 4000, \noiseDens, 50);
        7.5.wait;

        "5:11.5 - [Cue 43: Poly-Metric Superposition]".postln;
        Pbindef(\poly1, \instrument, \tapPluck, \out, ~synthBus, \dur, 0.75, \freq, 1200, \amp, 0.3).play; // 3/4
        Pbindef(\poly2, \instrument, \tapPluck, \out, ~synthBus, \dur, 1.0, \freq, 1500, \amp, 0.3).play;  // 4/4
        Pbindef(\poly3, \instrument, \tapPluck, \out, ~synthBus, \dur, 0.625, \freq, 1800, \amp, 0.3).play; // 5/8
        2.do { Pbindef(\bassEngine, \index, rrand(10, 20)); 4.25.wait; }; // 8.5s

        "5:20.0 - [Cue 44: Harmonic Ascent]".postln;
        Pbindef(\bassEngine, \freq, Pseq([100, 100, 120, 110], inf));
        7.0.wait;

        "5:27.0 - [Cue 45: Glitch Interruption]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.0625, 0.0625, Rest(0.125)], inf));
        5.0.wait;

        "5:32.0 - [Cue 46: High-Velocity Unison]".postln;
        Pbindef(\poly1, \dur, 0.125); Pbindef(\poly2, \dur, 0.125); Pbindef(\poly3, \dur, 0.125);
        Pbindef(\bassEngine, \dur, 0.125);
        6.0.wait;

        "5:38.0 - [Cue 47: Intrinsic Limit Approach (Form Op B)]".postln;
        Pbindef(\tapSeq, \dur, 0.03125, \freq, 3000); // 64th notes
        Pbindef(\bassEngine, \dur, 0.0625, \freq, 200, \index, 30);
        7.0.wait;

        "5:45.0 - [Cue 48: Parametric Collapse]".postln;
        // Instantly sweep the master LPF down
        Ndef(\masterMix).set(\masterLpf, 20000); // ensure start point
        Ndef(\masterMix).xset(\masterLpf, 150); // 5-second fade down via default fadeTime? Wait, let's explicit fade
        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\masterLpf, 150);
        5.0.wait;

        "5:50.0 - [Cue 49: Afterglow]".postln;
        Pbindef.removeAll; // Kill all frantic patterns
        Ndef(\masterMix).set(\wet15, 0); // Delay off
        Ndef(\masterMix).set(\wet20, 1.0); // Massive Reverb
        2.do { Ndef(\ensembleDrone).xset(\amp, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "6:00.0 - [Cue 50: Re-establishing Breath]".postln;
        Ndef(\masterMix).xset(\masterLpf, 20000); // Open filter back up slowly
        Ndef(\frictionStage).xset(\amp, 0.2, \cutoff, 600, \noiseDens, 0);
        8.0.wait;

        "6:08.0 - [Cue 51: Phase IV Outflow]".postln;
        Ndef(\masterMix).xset(\wet10, 0); // Spectral delay off
        7.0.wait;


        // --- PHASE V: Dissolution & Return ---
        "6:15.0 - [Cue 52: The Memory of Movement]".postln;
        Pbindef(\memorySeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 4.0,
            \freq, Pseq([600, 800, 550], inf),
            \carRatio, 1,
            \modRatio, 1.414,
            \index, 1.5,
            \atk, 2.0,
            \rel, 4.0,
            \amp, 0.2
        ).play;
        8.0.wait;

        "6:23.0 - [Cue 53: Soft Grounding]".postln;
        Pbindef(\softImpact, \instrument, \heavyImpact, \out, ~synthBus, \dur, 3.0, \freq, 60, \subFreq, 30, \cutoff, 200, \amp, 0.4).play;
        7.0.wait;

        "6:30.0 - [Cue 54: Ghost Taps]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pwhite(1.0, 3.0),
            \freq, Pwhite(300, 600),
            \decayScale, 0.05,
            \pan, Pwhite(-1.0, 1.0),
            \amp, 0.15
        ).play;
        2.do { Pbindef(\tapSeq, \amp, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "6:40.0 - [Cue 55: Spatial Condensation]".postln;
        // Pull panning to center
        Pbindef(\tapSeq, \pan, Pwhite(-0.2, 0.2));
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.4, 0.6)); 5.0.wait; }; // 10s

        "6:50.0 - [Cue 56: Return to Departure (Form Op A)]".postln;
        Pbindef(\memorySeq).stop;
        Pbindef(\softImpact).stop;
        Pbindef(\tapSeq, \pan, 0, \freq, Pseq([300, 400, 350], inf)); // Original motif
        2.do { Pbindef(\tapSeq, \decayScale, rrand(0.02, 0.05)); 5.0.wait; }; // 10s

        "7:00.0 - [Cue 57: The Final Solo]".postln;
        Pbindef(\tapSeq, \dur, Pseq([2.0, 3.0, 4.0], inf));
        2.do { Pbindef(\tapSeq, \amp, rrand(0.05, 0.1)); 5.0.wait; }; // 10s

        "7:10.0 - [Cue 58: The Long Fade-Out]".postln;
        Ndef(\frictionStage).clear(10);
        Ndef(\ensembleDrone).clear(10);
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "7:20.0 - [Cue 59: The Last Step]".postln;
        Pbindef(\tapSeq).stop;
        Synth(\tapPluck, [\out, ~synthBus, \freq, 320, \decayScale, 0.1, \amp, 0.1, \pan, 0]);
        8.0.wait;

        "7:28.0 - [Cue 60: Post-Event Silence]".postln;
        2.0.wait;

        "7:30.0 - [Cue 61: Extrinsic Limit Termination (Form Op D)]".postln;
        // CRITICAL TERMINATION
        Tdef.removeAll;
        Pbindef.removeAll;
        Ndef.clear;
        ServerTree.removeAll;
        s.freeAll;
        "7:30.0 - Score Complete. Absolute Silence.".postln;
    });

    // Execute the score
    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: compose-day-in-two-minutes.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: compose, first, limiter, master, persistent, safety, safetyLimiter
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter caps any peaks at 0.85 silently and transparently
    sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };
)

// Source: compose-day-in-two-minutes.scd [Block 3]
// MODE: compose
// THEME: 3. THE SCRIPT (Tdef - 2 Minute Score)
// KEYWORDS: ancientRes, ancientSeq, choirSeq, compose, earthquakeBass, holyChoir, hpf, kinetoClick, kinetoSeq, minute, quakeSeq, score, script, tdef, the, ufoSeq, ufoSweep
(
Tdef(\april14_eventHorizon, {

    "0:00 - [Movement I: Antiquity & Empires]".postln;
    Ndef(\ancientRes).play;
    Ndef(\holyChoir).play;

    Ndef(\ancientRes)[1] = \set -> Pbindef(\ancientSeq);
    Ndef(\holyChoir)[1] = \set -> Pbindef(\choirSeq);

    // Fade in massive cathedral/battlefield reverb over 5 seconds
    Ndef(\ancientRes).xset(\wet10, 0.6);
    Ndef(\holyChoir).xset(\wet10, 0.6);

    15.wait;

    "0:15 - [The Battles Intensify]".postln;
    Pbindef(\ancientSeq, \dur, 0.5); // Escalate strikes
    Ndef(\ancientRes).set(\decayscale, 0.2); // Violent, staccato decay

    15.wait; // Now at 0:30

    "0:30 - [Movement II: The Nuremberg Anomaly]".postln;
    Pbindef(\ancientSeq).stop;
    Ndef(\ancientRes).clear(4);

    Ndef(\ufoSweep).play;
    Ndef(\ufoSweep)[1] = \set -> Pbindef(\ufoSeq);

    // Push choir to background, unleash alien FM bursts with wild panning
    Ndef(\holyChoir).xset(\amp, 0.2);
    Ndef(\ufoSweep).set(\modIndex, 5, \wet12, 1.0);

    20.wait; // Now at 0:50

    "0:50 - [Movement III: Gunfire & Tremors]".postln;
    Pbindef(\ufoSeq).stop;
    Ndef(\ufoSweep).clear(2);

    Ndef(\kinetoClick).play;
    Ndef(\kinetoClick)[1] = \set -> Pbindef(\kinetoSeq);

    // Harsh, dry slapback delay
    Ndef(\kinetoClick).set(\wet11, 0.15);

    10.wait; // Now at 1:00

    "1:00 - [The Ljubljana Earthquake]".postln;
    Ndef(\earthquakeBass).play;
    Ndef(\earthquakeBass)[1] = \set -> Pbindef(\quakeSeq);

    // Sweep bass LPF up to reveal rumble, sweep choir HPF up to prevent masking
    Ndef(\earthquakeBass).xset(\lpfFreq, 200);
    Ndef(\holyChoir).xset(\hpfFreq, 300);

    15.wait; // Now at 1:15

    "1:15 - [Movement IV: The Dawn of Modernity]".postln;
    Pbindef(\quakeSeq).stop;
    Ndef(\earthquakeBass).clear(5);

    // Relentless 16th note mechanical rhythm
    Pbindef(\kinetoSeq, \dur, 0.125);

    // Choir returns with modern, majestic voicings
    Ndef(\holyChoir).xset(\amp, 0.5);
    Pbindef(\choirSeq, \freq, Pseq([349.23, 440.00, 329.63], inf)); // F, A, E

    // Turn dry clicks into a whirring film projector
    Ndef(\kinetoClick).xset(\wet11, 0.6, \fbTime, 2.0);

    30.wait; // Now at 1:45

    "1:45 - [Movement V: The Fade into History]".postln;
    Pbindef(\kinetoSeq).stop;
    Ndef(\kinetoClick).clear(5);

    // Tape-stop pitch shift and wash into 100% wet reverb
    Ndef(\holyChoir).xset(\freqMult, 0.5, \wet10, 1.0);

    15.wait; // Now at 2:00

    "2:00 - [Absolute Silence]".postln;
    Pbindef(\choirSeq).stop;

    // 10-second unsegmented fade out to silence
    Ndef(\ancientRes).clear(10);
    Ndef(\holyChoir).clear(10);
    Ndef(\ufoSweep).clear(10);
    Ndef(\kinetoClick).clear(10);
    Ndef(\earthquakeBass).clear(10);

    "Score Complete.".postln;
});

// Create GUI
s.makeGui;

)

// Source: compose-engine.scd [Block 1]
// MODE: compose
// THEME: GLOBAL CONFIGURATION
// KEYWORDS: bpf, chemicalBubble, compose, configuration, convectionSweep, coreEngineHum, diskRecorder, dissipationTrail, electricArc, environmentalHum, freeverb2, gearClick, gearClicks, geoHiss, global, gravityBoom, heatCore, hpf, industrialClang, industrialKick, industrialRhythm, masterMix, moogff, nuclearBurst, potentialField, powerHum, rlpf, safetyLimiter, saw, spectralGrind, subBoom, ticking, tickingSequence, transportRhythm
(
s.waitForBoot({

    var masterScore;
    var timestamp = Date.getDate.stamp;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false;
    //~enableRecording = true;  // <--- UNCOMMENT TO ENABLE MULTITRACK RECORDING

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING, BUFFERS & RECORDING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/EnergyNexus_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        synths: Bus.audio(s, 2),
        coreEngine: Bus.audio(s, 2),
        potentialField: Bus.audio(s, 2),
        heatCore: Bus.audio(s, 2),
        geoHiss: Bus.audio(s, 2),
        transport: Bus.audio(s, 2),
        spectralGrind: Bus.audio(s, 2),
        convection: Bus.audio(s, 2),
        envHum: Bus.audio(s, 2),
        dissipation: Bus.audio(s, 2),
        master: 0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Pre-allocate FFT Buffers for Ndef(\spectralGrind)
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);
    ~fftBuf2L = Buffer.alloc(s, 2048);
    ~fftBuf2R = Buffer.alloc(s, 2048);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\gearClick, { |out=0, recOut, freq=800, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 2);
        var sig = SinOsc.ar(freq) * env;
        var noise = WhiteNoise.ar * env * 0.5;
        var finalSig = Pan2.ar(sig + noise, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\ticking, { |out=0, recOut, freq=2500, amp=0.3, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.02), doneAction: 2);
        var sig = BPF.ar(PinkNoise.ar, freq, 0.1) * env * 5;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\subBoom, { |out=0, recOut, freq=40, amp=0.8, pan=0|
        var env = EnvGen.ar(Env.perc(0.05, 2.5, curve: -4), doneAction: 2);
        var sig = SinOsc.ar(freq + (EnvGen.ar(Env.perc(0.01, 0.2)) * freq));
        var finalSig = Pan2.ar(sig.tanh, pan) * env * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\electricArc, { |out=0, recOut, freq=5000, amp=0.4, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.1), doneAction: 2);
        var sig = LFNoise0.ar(freq) * env;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\chemicalBubble, { |out=0, recOut, freq=600, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
        var sig = SinOsc.ar(freq * (1 + (LFNoise1.kr(50) * 0.5))) * env;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\nuclearBurst, { |out=0, recOut, freq=100, amp=0.6, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, 0.3), doneAction: 2);
        var sig = BrownNoise.ar * env;
		var finalSig;
        sig = RLPF.ar(sig, freq * XLine.ar(5, 1, 0.1), 0.1) * 3;
        finalSig = Pan2.ar(sig.fold2(0.8), pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\powerHum, { |out=0, recOut, amp=0.5, gate=1|
        var env = EnvGen.ar(Env.asr(0.5, 1, 0.1), gate, doneAction: 2);
        var sig = Splay.ar(SinOsc.ar([50, 50.3, 150, 151, 250.5]));
        var finalSig = sig.tanh * env * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\industrialKick, { |out=0, recOut, amp=0.8|
        var env = EnvGen.ar(Env.perc(0.01, 0.4), doneAction: 2);
        var sig = SinOsc.ar(XLine.ar(200, 40, 0.1)) * env;
		var finalSig;
        sig = sig + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.01, 0.05)) * 0.3);
        finalSig = Pan2.ar(sig.tanh, 0) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\industrialClang, { |out=0, recOut, freq=400, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.01, 0.8), doneAction: 2);
        var sig = PMOsc.ar(freq, freq * 1.414, 3) * env;
        var finalSig = Pan2.ar(sig, 0) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\coreEngineHum, { |fmIndex=0.5, amp=0|
        var mod = SinOsc.ar(25) * fmIndex * 50;
        var sig = SinOsc.ar(50 + mod) + SinOsc.ar(50.5 + mod);
        sig = LPF.ar(sig, 400);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\coreEngineHum).play(~recBuses.coreEngine);

    Ndef(\potentialField, { |cutoff=50, amp=0|
        var sig = WhiteNoise.ar;
        sig = RLPF.ar(sig, cutoff, 0.05) * 5;
        Pan2.ar(sig * amp, SinOsc.kr(0.1));
    });
    Ndef(\potentialField).play(~recBuses.potentialField);

    Ndef(\heatCore, { |fmIndex=1, distortion=1, hpFreq=20, amp=0|
        var sig = Saw.ar([100, 101]) + Pulse.ar([50, 50.2], 0.3);
        sig = MoogFF.ar(sig, 800 + (fmIndex * 1000), 1.5);
        sig = (sig * distortion).tanh;
        sig = HPF.ar(sig, hpFreq);
        sig * amp * 0.4;
    });
    Ndef(\heatCore).play(~recBuses.heatCore);

    Ndef(\geoHiss, { |amp=0|
        var lpfEnv = LFNoise1.kr(8).exprange(500, 8000);
        var sig = WhiteNoise.ar(0.5) + PinkNoise.ar(0.5);
        sig = LPF.ar(sig, lpfEnv);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\geoHiss).play(~recBuses.geoHiss);

    Ndef(\transportRhythm, { |rate=2, amp=0|
        var trig = Impulse.ar(rate);
        var env = Decay2.ar(trig, 0.01, 0.3);
        var sig = SinOsc.ar(60) * env;
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\transportRhythm).play(~recBuses.transport);

    Ndef(\spectralGrind, { |amp=0|
        var sig1 = PinkNoise.ar;
        var sig2 = Saw.ar(LFNoise1.kr(2).exprange(50, 500));
        var chain1L = FFT(~fftBufL, sig1);
        var chain2L = FFT(~fftBuf2L, sig2);
        var chain1R = FFT(~fftBufR, sig1);
        var chain2R = FFT(~fftBuf2R, sig2);
        var processedL = PV_MagMul(chain1L, chain2L);
        var processedR = PV_MagMul(chain1R, chain2R);
        var out = [IFFT(processedL), IFFT(processedR)];
        out * amp * 0.05;
    });
    Ndef(\spectralGrind).play(~recBuses.spectralGrind);

    Ndef(\convectionSweep, { |amp=0, pitch=100|
        var sig = PinkNoise.ar;
        sig = BPF.ar(sig, pitch, 0.1) * 10;
        Pan2.ar(sig * amp, SinOsc.kr(0.05));
    });
    Ndef(\convectionSweep).play(~recBuses.convection);

    Ndef(\environmentalHum, { |amp=0|
        var sig = PMOsc.ar(60, 120, 2);
        Pan2.ar(sig.fold2(0.5) * amp, 0);
    });
    Ndef(\environmentalHum).play(~recBuses.envHum);

    Ndef(\dissipationTrail, { |delayTime=0.5, feedback=0.5, amp=0|
        var in = In.ar(~synthBus, 2) + Ndef.ar(\convectionSweep, 2);
        var sig = CombC.ar(in, 2.0, delayTime, feedback * 10);
        sig * amp;
    });
    Ndef(\dissipationTrail).play(~recBuses.dissipation);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var core = Ndef.ar(\coreEngineHum, 2) + Ndef.ar(\potentialField, 2);
        var heat = Ndef.ar(\heatCore, 2) + Ndef.ar(\geoHiss, 2);
        var ind = Ndef.ar(\transportRhythm, 2) + Ndef.ar(\spectralGrind, 2);
        var env = Ndef.ar(\convectionSweep, 2) + Ndef.ar(\environmentalHum, 2);
        var trail = Ndef.ar(\dissipationTrail, 2);

        synths + core + heat + ind + env + trail;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2);
        // JITLib auto-generates \wet10
        verb;
    };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var path;
        ~recSynths = ();
        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };
        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };
        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        var powerHumNode;

        if(~enableRecording) { ~startRecording.value; } { "--- PLAYBACK ONLY ---".postln; };

        "0:00 - [Cue 1: Server Init]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Mechanical Impulse]".postln;
        Pbindef(\gearClicks,
            \instrument, \gearClick,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([0.25, 0.25, 0.5, 0.125, 0.875], inf),
            \freq, Pexprand(600, 1200),
            \amp, 0.6,
            \pan, Pwhite(-0.3, 0.3)
        ).play;
        3.wait;

        "0:03.5 - [Cue 3: Core Engine Hum]".postln;
        Ndef(\coreEngineHum).fadeTime = 2;
        Ndef(\coreEngineHum).xset(\amp, 0.7);
        // Active wait for 6.5s
        3.do {
            Ndef(\coreEngineHum).xset(\fmIndex, rrand(0.5, 2.0));
            2.16.wait;
        };

        "0:10.0 - [Cue 4: Potential Fields Begin]".postln;
        Pbindef(\gearClicks, \dur, Pseq([0.5, 1.0, 1.5], inf)); // Thins out
        Ndef(\masterMix).xset(\wet10, 0.1);
        Ndef(\potentialField).fadeTime = 5;
        Ndef(\potentialField).xset(\amp, 0.5, \cutoff, 500);
        5.wait;

        "0:15.0 - [Cue 5: Precise Mechanisms]".postln;
        Pbindef(\gearClicks).stop; // Subtraction
        Ndef(\coreEngineHum).xset(\amp, 0.5);
        Pbindef(\tickingSequence,
            \instrument, \ticking,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, 0.125,
            \freq, Pseq([2500, 3000, 2000], inf),
            \amp, 0.4
        ).play;
        8.wait;

        "0:23.0 - [Cue 6: Gravitational Descent]".postln;
        Ndef(\potentialField).fadeTime = 7;
        Ndef(\potentialField).xset(\cutoff, 100);
        Pbindef(\gravityBoom,
            \instrument, \subBoom,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pwrand([2, 3, 5], [0.5, 0.3, 0.2], inf),
            \freq, 40,
            \amp, 0.9
        ).play;
        7.wait;

        "0:30.0 - [Cue 7: Electric Spark]".postln;
        Pbindef(\tickingSequence).stop; // Subtraction
        Ndef(\potentialField).set(\amp, 0); // Hard cut
        Pbindef(\electricArc,
            \instrument, \electricArc,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Prand([0.05, 0.1, 0.2], inf),
            \freq, Pexprand(3000, 8000),
            \amp, 0.5
        ).play;
        2.wait;

        "0:32.0 - [Cue 8: Heat Engine Ignition]".postln;
        Ndef(\heatCore).fadeTime = 3;
        Ndef(\heatCore).xset(\amp, 0.6);
        Pbindef(\electricArc, \dur, Pwrand([0.2, 0.5, 1.0], [0.7, 0.2, 0.1], inf));
        // Active wait: 10 seconds
        2.do { |i|
            Ndef(\heatCore).xset(\fmIndex, 1 + (i*2), \distortion, 1 + (i*0.5));
            5.wait;
        };

        "0:42.0 - [Cue 9: Geothermal Vent]".postln;
        Pbindef(\electricArc).stop; // Subtraction
        Ndef(\geoHiss).fadeTime = 0.5;
        Ndef(\geoHiss).xset(\amp, 0.5);
        4.wait;

        "0:46.0 - [Cue 10: Chemical Reaction]".postln;
        Ndef(\geoHiss).set(\amp, 0); // Subtraction
        Ndef(\masterMix).xset(\wet10, 0.5);
        Pbindef(\chemicalBubble,
            \instrument, \chemicalBubble,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pwhite(0.05, 0.3),
            \freq, Pexprand(400, 1200),
            \amp, 0.6
        ).play;
        6.wait;

        "0:52.0 - [Cue 11: Nuclear Core Reactivation]".postln;
        Pbindef(\chemicalBubble).stop; // Subtraction
        Ndef(\heatCore).xset(\amp, 0.8);
        Pbindef(\nuclearBurst,
            \instrument, \nuclearBurst,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([1.5, 1.0, 0.5, 0.25], inf), // Accelerating density
            \freq, Pexprand(50, 200),
            \amp, 0.7
        ).play;
        8.wait;

        "1:00.0 - [Cue 12: Fission Cascade]".postln;
        Pbindef(\nuclearBurst, \dur, Pwhite(0.05, 0.15)); // Peak density
        Ndef(\heatCore).xset(\hpFreq, 500);
        // Active wait: 10 seconds
        2.do {
            Ndef(\heatCore).xset(\distortion, rrand(2.0, 4.0));
            5.wait;
        };

        "1:10.0 - [Cue 13: Power Grid Overload]".postln;
        Pbindef(\nuclearBurst).stop; // Subtraction
        Ndef(\heatCore).xset(\hpFreq, 20);
        powerHumNode = Synth(\powerHum, [\out, ~synthBus, \recOut, ~recBuses.synths, \amp, 0.8]);
        5.wait;

        "1:15.0 - [Cue 14: Abrupt Reset]".postln;
        Ndef(\heatCore).set(\amp, 0); // Hard cut
        powerHumNode.set(\gate, 0); // Hard cut via quick env
        Ndef(\masterMix).set(\wet10, 0.1);
        2.wait;

        "1:17.0 - [Cue 15: Mechanical Recall]".postln;
        Pbindef(\gearClicks, \dur, 1.0, \freq, 400).play;
        Ndef(\coreEngineHum).fadeTime = 3;
        Ndef(\coreEngineHum).xset(\amp, 0.7, \fmIndex, 0.5);
        8.wait;

        "1:25.0 - [Cue 16: Transportation Pulse]".postln;
        Pbindef(\gearClicks, \dur, 0.25);
        Ndef(\transportRhythm).fadeTime = 2;
        Ndef(\transportRhythm).xset(\amp, 0.8);
        // Active wait: 10 seconds
        5.do { |i|
            Ndef(\transportRhythm).xset(\rate, 2 + (i*0.5));
            2.wait;
        };

        "1:35.0 - [Cue 17: Industrial Grinding]".postln;
        Pbindef(\gearClicks).stop; // Subtraction
        Ndef(\coreEngineHum).fadeTime = 2;
        Ndef(\coreEngineHum).xset(\amp, 0);
        Ndef(\spectralGrind).fadeTime = 1;
        Ndef(\spectralGrind).xset(\amp, 0.8);
        7.wait;

        "1:42.0 - [Cue 18: Cutting and Crushing]".postln;
        Pbindef(\industrialRhythm,
            \instrument, Pseq([\industrialKick, \industrialClang, \industrialKick, \industrialClang], inf),
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([0.5, 0.25, 0.25, 0.5], inf),
            \amp, 0.8
        ).play;
        8.wait;

        "1:50.0 - [Cue 19: Mixing Chaos]".postln;
        Pbindef(\industrialRhythm, \dur, Pwhite(0.125, 0.25));
        // Active wait: 7 seconds
        7.do {
            Ndef(\spectralGrind).xset(\amp, rrand(0.7, 1.0));
            1.wait;
        };

        "1:57.0 - [Cue 20: Convection Cell Rise]".postln;
        Pbindef(\industrialRhythm).stop; // Subtraction
        Ndef(\spectralGrind).set(\amp, 0); // Hard cut
        Pbindef(\gravityBoom).stop;

        Ndef(\convectionSweep).fadeTime = 4;
        Ndef(\convectionSweep).xset(\amp, 0.6);
        // Active wait: 8 seconds
        4.do { |i|
            Ndef(\convectionSweep).xset(\pitch, 100 + (i*100));
            2.wait;
        };

        "2:05.0 - [Cue 21: Environmental Heat]".postln;
        Ndef(\environmentalHum).fadeTime = 1;
        Ndef(\environmentalHum).xset(\amp, 0.4);
        6.wait;

        "2:11.0 - [Cue 22: Energy Dissipation Begins]".postln;
        Ndef(\environmentalHum).set(\amp, 0); // Subtraction
        Ndef(\convectionSweep).fadeTime = 10;
        Ndef(\convectionSweep).xset(\amp, 0, \pitch, 50);

        Ndef(\dissipationTrail).fadeTime = 2;
        Ndef(\dissipationTrail).xset(\amp, 1.0, \delayTime, 0.5, \feedback, 0.6);
        Ndef(\masterMix).xset(\wet10, 0.9);

        // Active wait: 10 seconds
        5.do {
            Ndef(\dissipationTrail).xset(\delayTime, rrand(0.4, 0.8));
            2.wait;
        };

        "2:21.0 - [Cue 23: Final Echoes]".postln;
        // Active wait: 9 seconds
        3.do { |i|
            Ndef(\dissipationTrail).xset(\delayTime, 1.0 + (i*0.2), \feedback, 0.6 - (i*0.1));
            3.wait;
        };

        "2:30.0 - [Cue 24: Absolute Silence (TERMINATION)]".postln;
        Ndef.clear(10);
        Pbindef.removeAll;

        10.wait; // Wait for the fade to complete

        ~stopRecording.value;
        Tdef.removeAll;
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    s.makeGui;
});
)

// Source: compose-helicopter.scd [Block 1]
// MODE: compose
// THEME: GLOBAL CONFIGURATION
// KEYWORDS: airyGranular, bpf, chopperPulse, chopperSeq, compose, configuration, diskRecorder, freeverb2, glitchFm, glitchSeq, global, granularSeq, helixDrone, hpf, masterMix, metallicPing, pingSeq, pteronFlaps, pulse, rlpf, safetyLimiter, sinosc, spectralSwirl, whirlyHum
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state
    //~enableRecording = true;  // <--- UNCOMMENT THIS LINE TO ENABLE RECORDING

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Multitrack_Recording/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        drone: Bus.audio(s, 2),
        flaps: Bus.audio(s, 2),
        ping: Bus.audio(s, 2),
        swirl: Bus.audio(s, 2),
        glitch: Bus.audio(s, 2),
        chopper: Bus.audio(s, 2),
        hum: Bus.audio(s, 2),
        granular: Bus.audio(s, 2),
        master: 0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Global FFT Buffers
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);

    // Granular Noise Buffer
    ~noiseBuf = Buffer.alloc(s, s.sampleRate * 2, 1);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // Fill noise buffer
    { RecordBuf.ar(WhiteNoise.ar, ~noiseBuf, loop: 0, doneAction: 2) }.play;
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\pteronFlaps, { |out=0, recOut, freq=4000, filterFreq=4000, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 2);
        var sig = WhiteNoise.ar;
        var final = Pan2.ar(sig * amp, pan);

        sig = BPF.ar(sig, filterFreq, 0.3) * env;

        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\metallicPing, { |out=0, recOut, freq=1800, decay=4, amp=0.3, pan=0, detune=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var sig = PMOsc.ar(freq * (1 + detune), freq * 2.1, 2) * env;
        var final = Pan2.ar(sig * amp, pan);
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\glitchFm, { |out=0, recOut, freq=5000, fmIndex=5, amp=0.15, pan=0, decay=0.05|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * fmIndex * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        var final = Pan2.ar(sig * amp, pan);
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\chopperPulse, { |out=0, recOut, freq=60, filterFreq=300, rq=0.6, amp=0.3, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction: 2);
        var sig = Pulse.ar(freq, 0.2);
        var final = Pan2.ar(sig * amp, pan);

        sig = RLPF.ar(sig, filterFreq, rq);
        sig = sig * (LFSaw.ar(15).range(0.1, 1));

        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\airyGranular, { |out=0, recOut, buf, grainDur=0.05, rate=20, filterFreq=10000, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
        var trig = Impulse.ar(rate);
        var sig = GrainBuf.ar(2, trig, grainDur, buf, 1, LFNoise1.ar(100).range(0, 1), 2, pan);
        var final;

		final = sig * amp;
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\helixDrone, { |freq=60, modIndex=0.05, modFreq=5, filterFreq=100, rq=0.8, amp=0, pan=0|
        var mod = modIndex * 10 * SinOsc.ar(modFreq);
        var sig = PMOsc.ar(freq, freq * 1.5, mod);
        sig = RLPF.ar(sig, filterFreq, rq);
        Pan2.ar(sig * amp, pan);
    });
    Ndef(\helixDrone).play(~recBuses.drone);

	Ndef(\spectralSwirl, { |freqShift=0, amp=1, pan=0|
		var in = Ndef.ar(\helixDrone, 2);
		var sig;

		// FreqShift operates directly on the audio signal in Hz
		sig = FreqShift.ar(in, freqShift);

		Balance2.ar(sig[0], sig[1], pan, amp);
	});
    Ndef(\spectralSwirl).play(~recBuses.swirl);

    Ndef(\whirlyHum, { |freq=200, modRate=2, filterFreq=500, amp=0|
        var sig = PinkNoise.ar;
        sig = BPF.ar(sig, freq, 0.2) + HPF.ar(sig, filterFreq);
        sig = sig * SinOsc.ar(modRate).range(0.2, 1);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\whirlyHum).play(~recBuses.hum);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var drone = Ndef.ar(\helixDrone, 2);
        var swirl = Ndef.ar(\spectralSwirl, 2);
        var hum = Ndef.ar(\whirlyHum, 2);
        synths + drone + swirl + hum;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var delayTime = \delayTime.kr(0.5);
        CombC.ar(in, 2.0, delayTime, 3.0);
    };
    Ndef(\masterMix).set(\wet10, 0);

    Ndef(\masterMix)[20] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2);
    };
    Ndef(\masterMix).set(\wet20, 0);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            var path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        "0:00 - [Cue 1: Server Init (0.5s)]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Helix Hum - Subterranean Stirrings (10.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 10;
        Ndef(\helixDrone).xset(\freq, 60, \modIndex, 0.1, \filterFreq, 120, \rq, 0.8, \amp, 0.25);
        2.do {
            Ndef(\helixDrone).xset(\modFreq, rrand(4.8, 5.2));
            5.wait;
        };

        "0:10.5 - [Cue 3: First Coil - Phase & Resonance (12.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 12;
        Ndef(\helixDrone).xset(\modIndex, 0.2, \modFreq, 8, \filterFreq, 250, \rq, 0.7);
        3.do { |i|
            Ndef(\helixDrone).xset(\pan, sin(i) * 0.2);
            4.wait;
        };

        "0:22.5 - [Cue 4: Pteron's Whispers - Irregular Gestures (8.0s)]".postln;
        Pbindef(\pteronFlaps,
            \instrument, \pteronFlaps,
            \out, ~synthBus,
            \recOut, ~recBuses.flaps,
            \freq, 4000,
            \dur, Prand([0.8, 1.2, 0.5], inf),
            \amp, Pseq([0.1, 0.05, 0.12], inf),
            \pan, Prand([-0.8, 0.8], inf)
        ).play;
        2.do { 4.wait; };

        "0:30.5 - [Cue 5: Convolutional Rise - Spectral Opening (15.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 15;
        Ndef(\helixDrone).xset(\filterFreq, 800, \modIndex, 0.35, \amp, 0.3);
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet20, 0.2); // Reverb up
        Pbindef(\pteronFlaps, \dur, Pseq([0.6, 0.9, 0.4], inf));

        3.do { 5.wait; };

        "0:45.5 - [Cue 6: Metallic Precision - Isolated & Clear (9.0s)]".postln;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        2.5.wait;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        3.5.wait;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        3.0.wait;

        "0:54.5 - [Cue 7: Helix Accelerando - Density & Panning (13.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 13;
        Ndef(\helixDrone).xset(\modFreq, 18, \amp, 0.35, \modIndex, 0.45);
        Pbindef(\pteronFlaps, \dur, Prand([0.3, 0.4, 0.2], inf), \amp, 0.25, \pan, Pwhite(-1.0, 1.0, inf));
        2.do { 6.5.wait; };

        "1:07.5 - [Cue 8: Spectral Bloom - Expansive & Shifting (18.0s)]".postln;
        Ndef(\spectralSwirl).fadeTime = 18;
        Ndef(\spectralSwirl).xset(\amp, 1);
        Ndef(\masterMix).fadeTime = 18;
        Ndef(\masterMix).xset(\wet10, 0.1); // Delay up slightly

        3.do { |i|
            var shift = [-50, 0, 50].wrapAt(i);
            Ndef(\spectralSwirl).xset(\freqShift, shift, \pan, sin(i * 0.5));
            6.wait;
        };

        "1:25.5 - [Cue 9: Fluttering Formations - Rhythmic & Focused (10.0s)]".postln;
        Pbindef(\pteronFlaps, \dur, Pseq([0.15, 0.25], inf), \amp, Pseq([0.3, 0.28], inf), \filterFreq, 6000);
        2.do { 5.wait; };

        "1:35.5 - [Cue 10: Momentum Hold - Static Energy (6.0s)]".postln;
        s.sync;
        6.wait;

        "1:41.5 - [Cue 11: Brief Deceleration - Tension Release (9.0s)]".postln;
        Pbindef(\pteronFlaps).stop; // SUBTRACTION
        Ndef(\helixDrone).fadeTime = 9;
        Ndef(\helixDrone).xset(\modFreq, 8, \modIndex, 0.1, \amp, 0.2);
        Ndef(\spectralSwirl).xset(\amp, 0.1);

        3.do { 3.wait; };

        "1:50.5 - [Cue 12: Resonant Depth - Reverb & Decay (15.0s)]".postln;
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet20, 0.6);
        Ndef(\helixDrone).fadeTime = 15;
        Ndef(\helixDrone).xset(\filterFreq, 200, \rq, 0.9, \amp, 0.15, \pan, 0);

        3.do { 5.wait; };

        "2:05.5 - [Cue 13: Metallic Echoes - Dissonant & Scattered (12.0s)]".postln;
        Pbindef(\pingSeq,
            \instrument, \metallicPing,
            \out, ~synthBus,
            \recOut, ~recBuses.ping,
            \dur, 0.5,
            \freq, Pwhite(1000, 2500, inf),
            \detune, Pwhite(-0.01, 0.01, inf),
            \amp, 0.2,
            \pan, Pwhite(-0.9, 0.9, inf)
        ).play;

        3.do { 4.wait; };

        "2:17.5 - [Cue 14: Helix Surge - Full Spectrum & Power (22.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 22;
        Ndef(\helixDrone).xset(\modIndex, 0.9, \amp, 0.4, \modFreq, 25);
        Ndef(\spectralSwirl).xset(\amp, 0.7);

        // Complex sweeping over 22 seconds
        Ndef(\helixDrone).xset(\filterFreq, 1500);
        2.do { 5.5.wait; };
        Ndef(\helixDrone).xset(\filterFreq, 4000);
        2.do { 5.5.wait; };

        "2:39.5 - [Cue 15: Pteron's Climax - Max Density & Velocity (10.0s)]".postln;
        Pbindef(\pteronFlaps, \dur, 0.075, \amp, 0.4, \pan, Pseq([-1, 1], inf), \filterFreq, 8000).play;
        2.do { 5.wait; };

        "2:49.5 - [Cue 16: Abrupt Deconstruction - First Glitch (6.0s)]".postln;
        Pbindef(\pteronFlaps).stop;
        Pbindef(\pingSeq).stop;
        Ndef(\helixDrone).set(\modIndex, 0.1, \amp, 0.2); // HARD SET
        Ndef(\spectralSwirl).set(\amp, 0.1);
        s.sync;
        6.wait;

        "2:55.5 - [Cue 17: Glitchy Rebracket - High Freq Fragmentation (12.0s)]".postln;
        Pbindef(\glitchSeq,
            \instrument, \glitchFm,
            \out, ~synthBus,
            \recOut, ~recBuses.glitch,
            \dur, 0.2,
            \freq, Pwhite(5000, 8000, inf),
            \fmIndex, Pwhite(5, 10, inf),
            \amp, 0.15,
            \pan, Pwhite(-1.0, 1.0, inf),
            \decay, Pwhite(0.01, 0.05, inf)
        ).play;

        3.do { 4.wait; };

        "3:07.5 - [Cue 18: Chopper Pulse - Rhythmic Core (15.0s)]".postln;
        Pbindef(\chopperSeq,
            \instrument, \chopperPulse,
            \out, ~synthBus,
            \recOut, ~recBuses.chopper,
            \dur, Pseq([0.25, 0.15, 0.3, 0.1], inf),
            \freq, 60,
            \filterFreq, 300,
            \rq, 0.6,
            \amp, 0.3
        ).play;

        3.do { 5.wait; };

        "3:22.5 - [Cue 19: Whirly Hum - Growing Presence (18.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 18;
        Ndef(\whirlyHum).xset(\amp, 0.2, \freq, 800, \filterFreq, 1500);

        3.do { 6.wait; };

        "3:40.5 - [Cue 20: Linguistic Scramble - Rapid Glitches & Pan (12.0s)]".postln;
        Pbindef(\glitchSeq, \dur, 0.1);
        Ndef(\whirlyHum).fadeTime = 12;
        Ndef(\whirlyHum).xset(\modRate, 10, \amp, 0.25);

        3.do { 4.wait; };

        "3:52.5 - [Cue 21: Helipad Approach - Settling Down (9.0s)]".postln;
        Pbindef(\chopperSeq).stop;
        Pbindef(\glitchSeq).stop;
        Ndef(\whirlyHum).fadeTime = 9;
        Ndef(\whirlyHum).xset(\amp, 0.1, \freq, 400, \modRate, 2);

        3.do { 3.wait; };

        "4:01.5 - [Cue 22: Quadcopter Flutter - Agile & Delicate (15.0s)]".postln;
        Pbindef(\granularSeq,
            \instrument, \airyGranular,
            \out, ~synthBus,
            \recOut, ~recBuses.granular,
            \buf, ~noiseBuf,
            \grainDur, 0.05,
            \rate, 20,
            \filterFreq, 10000,
            \amp, 0.2,
            \pan, Pwhite(-0.7, 0.7, inf),
            \dur, 0.1, // Triggering envelope rapidly
            \grainRate, Pseq([20, 30, 25, 35], inf)
        ).play;

        3.do { 5.wait; };

        "4:16.5 - [Cue 23: Whirlybird Soar - Euphoric Ascent (18.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 18;
        Ndef(\whirlyHum).xset(\freq, 3000, \modRate, 15, \amp, 0.3);
        Pbindef(\granularSeq, \filterFreq, 12000);

        3.do { 6.wait; };

        "4:34.5 - [Cue 24: Chopper's Resurgence - Heavy & Distorted (12.0s)]".postln;
        Pbindef(\granularSeq).stop;
        Pbindef(\chopperSeq, \dur, Pseq([0.4, 0.6, 0.3], inf), \amp, 0.4, \filterFreq, 200, \rq, 0.9).play;

        3.do { 4.wait; };

        "4:46.5 - [Cue 25: Convoluted Descent - Winding Down (15.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 15;
        Ndef(\whirlyHum).xset(\freq, 200, \modRate, 1, \filterFreq, 400);
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet10, 0.3, \delayTime, 0.5, \wet20, 0.5);
        Pbindef(\chopperSeq, \dur, Pwhite(0.5, 1.5, inf), \amp, Pgeom(0.4, 0.9, inf));

        3.do { 5.wait; };

        "5:01.5 - [Cue 26: Etymological Echoes - Return to Origin (18.0s)]".postln;
        Pbindef(\chopperSeq).stop;
        Ndef(\whirlyHum).xset(\amp, 0);
        Ndef(\helixDrone).fadeTime = 18;
        Ndef(\helixDrone).xset(\freq, 80, \modIndex, 0.08, \amp, 0.1, \filterFreq, 150);
        Ndef(\masterMix).xset(\wet20, 0.8, \wet10, 0.1);

        3.do { 6.wait; };

        "5:19.5 - [Cue 27: Lingering Resonance - Final Decay (10.0s)]".postln;
        Pbindef.removeAll; // Stop any stray patterns
        Ndef(\helixDrone).fadeTime = 10;
        Ndef(\helixDrone).xset(\amp, 0.05, \modIndex, 0.05);
        Ndef(\masterMix).xset(\wet20, 0.9);

        2.do { 5.wait; };

        "5:29.5 - [Cue 28: Absolute Stillness - Server Clear (6.5s)]".postln;
        Tdef.removeAll; // Stops itself and other Tdefs
        Ndef.clear(5.0); // 5 second fade out for all Ndefs

        ~stopRecording.value;

        5.5.wait;
        "Score Complete. Silence.".postln;
    });

    Tdef(\masterScore).play;
    s.makeGui;
});
)

// Source: compose-paro-taktsang.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING
// KEYWORDS: ancientResonance, bellMix, bpf, bus, cliffEdgeTexture, compose, grottoPulses, gverb, masterMix, mountainShimmer, pluckMix, pre, rlpf, routing, sacredBell, safetyLimiter, saw, setup, sinosc, spiritualSurge, summitRhythm, vajraPluck, whitenoise
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~bellBus = Bus.audio(s, 2);
    ~pluckBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\sacredBell, { |out=0, freq=400, decay=5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2); // CRITICAL: doneAction 2
        var modFreq = freq * 1.4142; // Tritone/inharmonic relationship
        var mod = SinOsc.ar(modFreq) * freq * 2 * env;
        var sig = SinOsc.ar(freq + mod);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\vajraPluck, { |out=0, freq=400, decay=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2); // CRITICAL: doneAction 2
        var exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        // Safe Karplus-Strong modeling: clipping delay time to prevent buffer overrun
        var delayTime = freq.reciprocal.clip(0.0001, 0.19);
        var sig = Pluck.ar(exc, 1, 0.2, delayTime, decay, 0.4);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: Vast Shimmer
    Ndef(\mountainShimmer, { |bufFreq=6000, rate=0.5, amp=0|
        var trig = Dust.ar(rate * 10);
        var env = EnvGen.ar(Env.perc(0.1, 0.5), trig);
        var sig = BPF.ar(WhiteNoise.ar, LFNoise1.kr(0.2).exprange(bufFreq*0.8, bufFreq*1.2), 0.1);
        Pan2.ar(sig * env * amp * 12, SinOsc.kr(0.1));
    });

    // Movement II: PM Drone
    Ndef(\ancientResonance, { |freq=60, pmIndex=0.5, rq=0.5, amp=0|
        var modFreq = freq * 1.5;
        var pm = PMOsc.ar(freq, modFreq, pmIndex);
        var sig = RLPF.ar(pm, SinOsc.kr(0.05).exprange(100, 800), rq);
        Pan2.ar(sig * amp, 0);
    });

    // Movement III: Chaotic Glassy Edge
    Ndef(\cliffEdgeTexture, { |resFreq=1500, q=0.5, amp=0|
        var sig = Saw.ar(LFNoise1.kr(2).exprange(50, 200));
        sig = Resonz.ar(sig, resFreq, q);
        Pan2.ar(sig * amp * 15, SinOsc.kr(0.15)); // Makeup gain for Resonz
    });

    // Movement IV: Granular Climax
    Ndef(\spiritualSurge, { |grainSize=0.05, rate=20, panFreq=0.5, amp=0|
        var trig = Dust.ar(rate);
        var env = EnvGen.ar(Env.sine(grainSize), trig);
        var sig = WhiteNoise.ar * env;
        sig = BPF.ar(sig, LFNoise1.kr(1).exprange(1000, 5000), 0.3);
        Pan2.ar(sig * amp * 8, SinOsc.kr(panFreq));
    });

    // Sub-mixes for Discrete Patterns
    Ndef(\bellMix, { In.ar(~bellBus, 2) });
    Ndef(\pluckMix, { In.ar(~pluckBus, 2) });

    // Delay Echo on Plucks (Movement IV)
    Ndef(\pluckMix)[10] = \filter -> { |in|
        var wet = \echoWet.kr(0);
        var fb = \feedback.kr(0.6);
        var echo = CombC.ar(in, 1.0, 0.25, fb * 2);
        XFade2.ar(in, echo, wet * 2 - 1);
    };
    Ndef(\pluckMix).set(\echoWet, 0, \feedback, 0);

    // Master Mix Aggregation
    Ndef(\masterMix, {
        var sig = Ndef.ar(\mountainShimmer, 2) +
                  Ndef.ar(\ancientResonance, 2) +
                  Ndef.ar(\cliffEdgeTexture, 2) +
                  Ndef.ar(\spiritualSurge, 2) +
                  Ndef.ar(\bellMix, 2) +
                  Ndef.ar(\pluckMix, 2);
        // Master filter mapping
        sig = LPF.ar(sig, \masterLpf.kr(18000));
        sig * \amp.kr(1.0);
    });

    // Global Reverb
    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \reverbWet.kr(0.8);
        var verb = GVerb.ar(in.sum, 150, 5, 0.5, 0.5, 15, 0.1, 0.7, 0.5);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    Ndef(\masterMix).set(\reverbWet, 0.8, \amp, 1.0, \masterLpf, 18000);
    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        // ----------------------------------------------------------------
        "0:00 - [Cue 1: Whispers of the High Pass]".postln;
        // ----------------------------------------------------------------
        Ndef(\mountainShimmer).fadeTime = 3;
        Ndef(\mountainShimmer).xset(\amp, 0.6);
        Ndef(\masterMix).xset(\reverbWet, 0.8);

        // 40 seconds total: 8 loops x 5 seconds
        8.do { |i|
            Ndef(\mountainShimmer).xset(\rate, 0.5 + (i * 0.1));
            Ndef(\mountainShimmer).xset(\bufFreq, rrand(5000, 8000));
            5.wait;
        };

        // ----------------------------------------------------------------
        "0:40 - [Cue 2: The Secluded Grotto (SUBTRACTIVE SHIFT)]".postln;
        // ----------------------------------------------------------------
        Ndef(\mountainShimmer).fadeTime = 3;
        Ndef(\mountainShimmer).xset(\amp, 0);

        Ndef(\ancientResonance).fadeTime = 5;
        Ndef(\ancientResonance).xset(\amp, 0.5);

        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\reverbWet, 0.7);

        Pbindef(\grottoPulses,
            \instrument, \sacredBell,
            \out, ~bellBus,
            \dur, Pwhite(8.0, 12.0, inf),
            \decay, Pwhite(5.0, 7.0, inf),
            \freq, Pseq([300, 250, 400, 350], inf),
            \amp, 0.4,
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;

        // 45 seconds total: 9 loops x 5 seconds
        9.do { |i|
            Ndef(\ancientResonance).xset(\pmIndex, 0.5 + (i * 0.11)); // Sweep 0.5 -> 1.5
            Ndef(\ancientResonance).xset(\rq, rrand(0.3, 0.7));
            5.wait;
        };

        // ----------------------------------------------------------------
        "1:25 - [Cue 3: Tiger's Ascent (BUILDING TENSION)]".postln;
        // ----------------------------------------------------------------
        Ndef(\ancientResonance).fadeTime = 5;
        Ndef(\ancientResonance).xset(\amp, 0.3); // Recedes

        Ndef(\cliffEdgeTexture).fadeTime = 5;
        Ndef(\cliffEdgeTexture).xset(\amp, 0.4);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\reverbWet, 0.5);

        // 45 seconds total: 22 loops x 2 seconds + 1 second
        22.do { |i|
            Ndef(\cliffEdgeTexture).xset(\resFreq, 1500 + (i * 113.6)); // Sweep 1500 -> 4000
            Ndef(\cliffEdgeTexture).xset(\q, rrand(0.2, 0.8));
            2.wait;
        };
        1.wait;

        // ----------------------------------------------------------------
        "2:10 - [Cue 4: Vajrayana Summit (CLIMAX)]".postln;
        // ----------------------------------------------------------------
        Ndef(\cliffEdgeTexture).fadeTime = 3;
        Ndef(\cliffEdgeTexture).xset(\amp, 0.2); // Recedes further

        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\reverbWet, 0.4);

        Ndef(\pluckMix).fadeTime = 2;
        Ndef(\pluckMix).xset(\echoWet, 0.7, \feedback, 0.6);

        Ndef(\spiritualSurge).fadeTime = 5;
        Ndef(\spiritualSurge).xset(\amp, 0.5);

        Pbindef(\summitRhythm,
            \instrument, \vajraPluck,
            \out, ~pluckBus,
            \scale, Scale.lydian,
            \degree, Pwhite(0, 14, inf),
            \dur, Pwhite(0.05, 0.1, inf),
            \amp, 0.6,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        // 50 seconds total: 10 loops x 5 seconds
        10.do { |i|
            Ndef(\spiritualSurge).xset(\grainSize, 0.05 - (i * 0.004)); // Sweep down to 0.01
            Ndef(\spiritualSurge).xset(\rate, 20 + (i * 8));             // Sweep up to 100

            // Random octave jumps and amplitude pulses
            Pbindef(\summitRhythm, \octave, [4, 5, 6].choose);
            Pbindef(\summitRhythm, \amp, rrand(0.6, 0.9));
            5.wait;
        };

        // ----------------------------------------------------------------
        "3:00 - [Cue 5: Dissolution into Emptiness (MANDATED FADE)]".postln;
        // ----------------------------------------------------------------
        Pbindef(\summitRhythm).stop;

        Ndef(\spiritualSurge).fadeTime = 15;
        Ndef(\spiritualSurge).xset(\amp, 0);

        Ndef(\ancientResonance).fadeTime = 20;
        Ndef(\ancientResonance).xset(\amp, 0);

        Ndef(\cliffEdgeTexture).fadeTime = 25;
        Ndef(\cliffEdgeTexture).xset(\amp, 0);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\reverbWet, 0.9);

        Ndef(\pluckMix).fadeTime = 5;
        Ndef(\pluckMix).xset(\feedback, 0);

        // Wait 10 seconds in safe chunks
        2.do { 5.wait; };

        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\amp, 0); // Fade out master volume

        Ndef(\pluckMix).fadeTime = 10;
        Ndef(\pluckMix).xset(\echoWet, 0);

        // Wait final 15 seconds in safe chunks
        3.do { 5.wait; };

        // ----------------------------------------------------------------
        "3:25 - [Termination]".postln;
        // ----------------------------------------------------------------
        Ndef.clear(5);
        Pbindef.removeAll;
        Tdef.removeAll;

        "3:30 - Server Silent. Journey Complete.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: compose-radioplay1.scd [Block 1]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & CLOCK FIX
// KEYWORDS: bellRing, bpf, clock, clockBell, compose, configuration, diskRecorder, dogHowl, doorCreak, doorSlam, fireCrackle, fix, footsteps, freeverb2, global, gunShot, kineticRun, masterMix, moogff, phoneBell, pianoGhost, pianoTheme, pinknoise, ringz, safetyLimiter, scraping, sinosc, spectralGhost, squeakGrains, staccatoClick, tensionBass, thud, warmPad, windTexture
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & CLOCK FIX
    // --------------------------------------------------------------------
    s.latency = nil;

    ~enableRecording = false; // Fallback state
    //~enableRecording = true;  // <--- UNCOMMENT THIS LINE TO ENABLE RECORDING

    // --------------------------------------------------------------------
    // EXPLICIT NODE ORDERING (Guarantees FX reads Synths)
    // --------------------------------------------------------------------
    ~srcGroup = Group.new(s);
    ~fxGroup = Group.after(~srcGroup);

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Multitrack_Recording/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        creak: Bus.audio(s, 2),
        piano: Bus.audio(s, 2),
        bell: Bus.audio(s, 2),
        click: Bus.audio(s, 2),
        howl: Bus.audio(s, 2),
        thud: Bus.audio(s, 2),
        tensionBass: Bus.audio(s, 2),
        windTexture: Bus.audio(s, 2),
        spectralGhost: Bus.audio(s, 2),
        warmPad: Bus.audio(s, 2),
        fireCrackle: Bus.audio(s, 2),
        master: Bus.new(\audio, 0, 2, s) // Master hardware out
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    ~fftBufL = Buffer.alloc(s, 2048, 1);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS
    // --------------------------------------------------------------------
    SynthDef(\squeakGrains, { |out=0, recOut=0, amp=0.5, pan=0, freq=1200, res=0.01|
        var env, freqs, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
        freqs = freq * [1, 1.2, 1.5, 1.8];
        sig = Klank.ar(`[freqs, nil, Array.fill(4, res)], BrownNoise.ar * env) * 0.1;
        finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\pianoGhost, { |out=0, recOut=0, freq=440, amp=0.5, pan=0, stiffness=1, dec=2|
        var env, exc, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.005, dec), doneAction: 2);
        exc = WhiteNoise.ar(0.1) * EnvGen.ar(Env.perc(0.001, 0.02));
        sig = Pluck.ar(exc, exc, 0.2, freq.reciprocal, dec, coef: stiffness.linlin(0, 10, 0.5, 0.99));
        sig = sig + (SinOsc.ar(freq * 1.5) * SinOsc.ar(freq * 0.5) * stiffness.linlin(0, 10, 0, 1) * env);
        finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\phoneBell, { |out=0, recOut=0, freq=800, amp=0.5, pan=0|
        var env, mod, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        mod = SinOsc.ar(25) * 200;
        sig = SinOsc.ar(freq + mod) * 0.5 + SinOsc.ar(freq * 1.2 + mod) * 0.5;
        finalSig = Pan2.ar(sig * env, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\staccatoClick, { |out=0, recOut=0, freq=440, fmIndex=1, amp=0.5, pan=0, dec=0.05|
        var env, mod, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.001, dec), doneAction: 2);
        mod = SinOsc.ar(freq * 2.4) * fmIndex * freq * env;
        sig = SinOsc.ar(freq + mod) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\gunShot, { |out=0, recOut=0, amp=1.0, pan=0|
        var env, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.001, 0.5, 1, -8), doneAction: 2);
        sig = WhiteNoise.ar * env;
        sig = LPF.ar(sig, XLine.kr(20000, 1000, 0.2)) + BPF.ar(sig, 100, 0.5, 2);
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\dogHowl, { |out=0, recOut=0, freq=800, amp=0.5, pan=0|
        var env, mod, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.5, 2.0), doneAction: 2);
        mod = LFNoise1.kr(50) * 100;
        sig = SinOsc.ar(freq + mod) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\thud, { |out=0, recOut=0, amp=0.8, pan=0|
        var env, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);
        sig = SinOsc.ar(XLine.kr(100, 30, 0.1)) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // (CRITICAL FIX: renamed 'amp' args to 'vol' to avoid JITLib shadowing)
    // --------------------------------------------------------------------
    Ndef(\tensionBass).parentGroup = ~srcGroup;
    Ndef(\tensionBass, { |cutoff=400, modFreq=0.1, vol=0, drive=1, harm=1|
        var mod = LFSaw.ar(modFreq).range(0.5, 2);
        var sig = PMOsc.ar(50 * harm, 150 * harm, mod * 3 * drive);
        sig = MoogFF.ar(sig, cutoff, 2.5);
        Pan2.ar(sig * vol, 0);
    });
    Ndef(\tensionBass).play(out: ~recBuses.tensionBass.index, numChannels: 2);

    Ndef(\windTexture).parentGroup = ~srcGroup;
    Ndef(\windTexture, { |lfoRate=0.2, lpf=2000, vol=0|
        var lfo = SinOsc.kr(lfoRate).range(200, lpf);
        // CRITICAL FIX: Replaced PinkNoise with heavily gained WhiteNoise
        var sig = (BPF.ar(WhiteNoise.ar, lfo, 0.2) * 15).softclip;
        Pan2.ar(sig * vol, SinOsc.kr(lfoRate * 0.5));
    });
    Ndef(\windTexture).play(out: ~recBuses.windTexture.index, numChannels: 2);

    Ndef(\spectralGhost).parentGroup = ~srcGroup;
    Ndef(\spectralGhost, { |vol=0, freeze=0, shift=1|
        var in = Ndef.ar(\tensionBass, 2)[0] + (WhiteNoise.ar * 0.1);
        var chain = FFT(~fftBufL, in);
        chain = PV_MagFreeze(chain, freeze);
        chain = PV_BinShift(chain, shift);
        Pan2.ar(IFFT(chain) * vol, 0);
    });
    Ndef(\spectralGhost).play(out: ~recBuses.spectralGhost.index, numChannels: 2);

    Ndef(\warmPad).parentGroup = ~srcGroup;
    Ndef(\warmPad, { |detune=0, vol=0|
        var sig = Mix(SinOsc.ar([220, 220 + detune, 330, 330 + (detune*1.5), 440], 0, 0.2));
        var am = SinOsc.kr(4).range(0.8, 1);
        Pan2.ar(sig * am * vol, 0);
    });
    Ndef(\warmPad).play(out: ~recBuses.warmPad.index, numChannels: 2);

    Ndef(\fireCrackle).parentGroup = ~srcGroup;
    Ndef(\fireCrackle, { |dens=20, lpf=5000, vol=0|
        var trigs = Dust.ar(dens);
        var sig = Ringz.ar(trigs, TRand.ar(400, 8000, trigs), 0.005);
        sig = LPF.ar(sig, lpf);
        Pan2.ar(sig * vol, TRand.ar(-0.8, 0.8, trigs));
    });
    Ndef(\fireCrackle).play(out: ~recBuses.fireCrackle.index, numChannels: 2);

    Ndef(\masterMix).parentGroup = ~fxGroup;
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus.index, 2);
        var continuous = Ndef.ar(\tensionBass, 2) + Ndef.ar(\windTexture, 2) +
                         Ndef.ar(\spectralGhost, 2) + Ndef.ar(\warmPad, 2) + Ndef.ar(\fireCrackle, 2);
        synths + continuous;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2);
    };

    Ndef(\masterMix)[20] = \filter -> { |in|
        var cutoff = \masterLpf.kr(20000);
        LPF.ar(in, cutoff);
    };

    Ndef(\masterMix).set(\wet10, 0, \masterLpf, 20000);
    Ndef(\masterMix).play(out: 0, numChannels: 2);

    s.sync;

    1.wait; // Safety buffer before playback

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;

        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus.index, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        "ACT I: THE WARNING".postln;
        "0:00.0 - [Cue 1: Server Buffer (0.5s)]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: The Squeaking Door (4.0s)]".postln;
        Pbindef(\doorCreak,
            \instrument, \squeakGrains,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.creak.index,
            \dur, Pexprand(0.02, 0.15),
            \freq, Pbrown(500, 1500, 100),
            \amp, 0.8
        ).play;

        16.do { 0.25.wait; Pbindef(\doorCreak, \freq, rrand(800, 2000)); };

        "0:04.5 - [Cue 3: The Snap (1.5s)]".postln;
        Pbindef(\doorCreak).stop;
        Synth(\staccatoClick, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \freq, 2000, \fmIndex, 5, \amp, 0.8], target: ~srcGroup);
        1.5.wait;

        "0:06.0 - [Cue 4: Tension Void (8.0s)]".postln;
        Ndef(\tensionBass).fadeTime = 3;
        Ndef(\tensionBass).set(\vol, 0.8, \cutoff, 400); // FIX: vol instead of amp
        4.do { |i| Ndef(\tensionBass).xset(\modFreq, 0.1 + (i*0.05)); 2.wait; };

        "0:14.0 - [Cue 5: The Hound (2.5s)]".postln;
        Pbindef(\dogHowl,
            \instrument, \dogHowl,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.howl.index,
            \freq, Pseq([1200, 1400], 1),
            \dur, 1.25,
            \amp, 0.5
        ).play;
        2.5.wait;

        "0:16.5 - [Cue 6: Abrupt Settling (1.5s)]".postln;
        Pbindef(\dogHowl).stop;
        Ndef(\tensionBass).xset(\cutoff, 200);
        1.5.wait;

        "0:18.0 - [Cue 7: The Clock (10.0s)]".postln;
        Pbindef(\clockBell,
            \instrument, \phoneBell,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.bell.index,
            \freq, Pwhite(600, 1000),
            \amp, Pgeom(0.6, 0.8, 10),
            \dur, 1.0
        ).play;
        5.do { 2.wait; };

        "0:28.0 - [Cue 8: The Wire Rings (2.0s)]".postln;
        Pbindef(\bellRing,
            \instrument, \phoneBell,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.bell.index,
            \freq, 1500, \dur, 0.125, \amp, 0.4
        ).play;
        2.wait;

        "0:30.0 - [Cue 9: The Voice (5.0s)]".postln;
        Ndef(\tensionBass).fadeTime = 2;
        Ndef(\tensionBass).xset(\harm, 4, \drive, 3);
        5.do { 1.wait; };

        "0:35.0 - [Cue 10: The Motif (1.5s)]".postln;
        Pbindef(\pianoTheme,
            \instrument, \pianoGhost,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.piano.index,
            \freq, Pseq([659.25, 622.25, 587.33], 1),
            \dur, 0.5, \stiffness, 1, \amp, 0.8
        ).play;
        1.5.wait;

        "0:36.5 - [Cue 11: Subtractive Drone (11.5s)]".postln;
        Pbindef(\pianoTheme).stop; Pbindef(\bellRing).stop; Pbindef(\clockBell).stop;
        Ndef(\masterMix).set(\wet10, 0.8);
        11.do { |i| Ndef(\tensionBass).xset(\cutoff, 400 + (i*50)); 1.wait; };
        0.5.wait;

        "0:48.0 - [Cue 12: Wires Cut (1.0s)]".postln;
        Ndef(\masterMix).set(\masterLpf, 50);
        1.wait;

        "0:49.0 - [Cue 13: False Echo (2.0s)]".postln;
        Ndef(\tensionBass).set(\vol, 0);
        2.wait;

        "0:51.0 - [Cue 14: Dead Ignition (7.0s)]".postln;
        Ndef(\masterMix).set(\masterLpf, 20000);
        Ndef(\masterMix).set(\wet10, 0.1);
        Pbindef(\kineticRun,
            \instrument, \staccatoClick,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.click.index,
            \freq, Pexprand(100, 800),
            \fmIndex, Pexprand(1, 10),
            \dur, Pseq([0.125, 0.25, 0.125, 0.5], inf),
            \amp, 0.6
        ).play;
        7.do { |i| Pbindef(\kineticRun, \fmIndex, Pwhite(1, 10 + i)); 1.wait; };

        "0:58.0 - [Cue 15: Bridge Out (2.5s)]".postln;
        Synth(\staccatoClick, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \freq, 100, \fmIndex, 50, \amp, 0.9, \dec, 1.5], target: ~srcGroup);
        2.5.wait;

        "1:00.5 - [Cue 16: The Wind (12.0s)]".postln;
        Pbindef(\kineticRun).stop;
        Ndef(\windTexture).fadeTime = 3;
        Ndef(\windTexture).set(\vol, 0.8, \lfoRate, 0.2); // FIX: vol
        6.do { |i| Ndef(\windTexture).xset(\lpf, 2000 + (i*500)); 2.wait; };

        "1:12.5 - [Cue 17: Hound Return (1.5s)]".postln;
        Pbindef(\dogHowl, \freq, Pseq([1400, 1600], 1), \dur, 0.75).play;
        1.5.wait;

        "1:14.0 - [Cue 18: Approaching Lights (5.0s)]".postln;
        Ndef(\windTexture).xset(\lfoRate, 4);
        5.do { |i| Ndef(\windTexture).xset(\vol, 0.6 + (i*0.05)); 1.wait; };

        "1:19.0 - [Cue 19: The Slam (1.0s)]".postln;
        Pbindef(\doorSlam,
            \instrument, \gunShot,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.click.index,
            \amp, 0.7, \dur, Pseq([0.2, 0.8], 1)
        ).play;
        1.wait;

        "1:20.0 - [Cue 20: False Relief (10.0s)]".postln;
        Ndef(\windTexture).fadeTime = 5; Ndef(\windTexture).xset(\vol, 0);
        Ndef(\warmPad).fadeTime = 4; Ndef(\warmPad).set(\vol, 0.6, \detune, 0); // FIX: vol
        5.do { 2.wait; };

        "1:30.0 - [Cue 21: Engine Restarts (2.5s)]".postln;
        Pbindef(\kineticRun, \dur, 0.25, \freq, Pseq([300, 400], inf), \fmIndex, 2).play;
        2.5.wait;

        "1:32.5 - [Cue 22: Reality Shifts (8.5s)]".postln;
        4.do { |i| Ndef(\warmPad).xset(\detune, (i+1) * 5); 2.wait; };
        0.5.wait;

        "1:41.0 - [Cue 23: The Ring (1.5s)]".postln;
        Pbindef(\bellRing, \dur, 0.0625, \freq, 2000).play;
        1.5.wait; Pbindef(\bellRing).stop;

        "1:42.5 - [Cue 24: Aggressive Motif (10.0s)]".postln;
        Pbindef(\pianoTheme, \freq, Pwhite(200, 1000), \dur, 0.125, \stiffness, 2, \amp, 0.7).play;
        5.do { 2.wait; };

        "1:52.5 - [Cue 25: Panic Build (7.5s)]".postln;
        7.do { |i| Pbindef(\pianoTheme, \stiffness, i + 2); 1.wait; };
        0.5.wait;

        "ACT II: THE VOID & THE FLIGHT".postln;
        "2:00.0 - [Cue 26: Face at the Window (1.2s)]".postln;
        Pbindef(\pianoTheme).stop;
        Synth(\staccatoClick, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \freq, 3000, \fmIndex, 20, \amp, 0.8, \dec, 1], target: ~srcGroup);
        1.2.wait;

        "2:01.2 - [Cue 27: Panic Rhythm (3.8s)]".postln;
        Pbindef(\kineticRun, \dur, 0.03125, \freq, Pwhite(1000, 3000), \fmIndex, Pwhite(1, 10)).play;
        3.do { 1.wait; }; 0.8.wait;

        "2:05.0 - [Cue 28: Lights Out (6.0s)]".postln;
        Pbindef.removeAll;
        Ndef(\warmPad).set(\vol, 0); Ndef(\windTexture).set(\vol, 0); Ndef(\tensionBass).set(\vol, 0);
        6.wait;

        "2:11.0 - [Cue 29: The Murder (0.8s)]".postln;
        Ndef(\spectralGhost).set(\vol, 1.0, \freeze, 1, \shift, 2); // FIX: vol
        0.8.wait;

        "2:11.8 - [Cue 30: Aftermath Drone (4.2s)]".postln;
        Ndef(\tensionBass).fadeTime = 2;
        Ndef(\tensionBass).set(\vol, 0.4, \cutoff, 80, \harm, 0.5, \drive, 1);
        4.do { 1.wait; }; 0.2.wait;

        "2:16.0 - [Cue 31: Suspicion (8.0s)]".postln;
        Pbindef(\scraping,
            \instrument, \squeakGrains,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.creak.index,
            \dur, Pwhite(0.1, 0.5), \freq, Pwhite(2000, 5000), \amp, 0.5
        ).play;
        4.do { |i| Ndef(\tensionBass).xset(\cutoff, 80 + (i*100)); 2.wait; };

        "2:24.0 - [Cue 32: The Cigarette Case (1.5s)]".postln;
        Synth(\staccatoClick, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \freq, 400, \fmIndex, 0, \amp, 0.7], target: ~srcGroup);
        1.5.wait;

        "2:25.5 - [Cue 33: Evidence (12.0s)]".postln;
        Ndef(\spectralGhost).fadeTime = 5;
        Ndef(\spectralGhost).set(\vol, 0.6, \shift, 1.2, \freeze, 0.5);
        6.do { |i| Ndef(\spectralGhost).xset(\shift, 1.2 + (i*0.1)); 2.wait; };

        "2:37.5 - [Cue 34: Police Dial (2.5s)]".postln;
        Pbindef(\kineticRun,
            \instrument, \staccatoClick,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.click.index,
            \dur, 0.05, \freq, Pseq([500, 520, 500, 530], inf), \fmIndex, 5
        ).play;
        2.5.wait;

        "2:40.0 - [Cue 35: The Voice Returns (3.0s)]".postln;
        Pbindef(\kineticRun).stop;
        Ndef(\masterMix).set(\wet10, 0);
        Pbindef(\pianoTheme,
            \instrument, \pianoGhost,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.piano.index,
            \freq, Pseq([659.25, 622.25, 587.33], 2), \dur, 0.5, \amp, 0.8, \stiffness, 1
        ).play;
        3.wait;

        "2:43.0 - [Cue 36: Flight Initiated (7.0s)]".postln;
        Pbindef(\pianoTheme).stop;
        Ndef(\windTexture).fadeTime = 1; Ndef(\windTexture).set(\vol, 0.7, \lfoRate, 8);
        7.do { 1.wait; };

        "2:50.0 - [Cue 37: Footsteps (1.5s)]".postln;
        Pbindef(\footsteps,
            \instrument, \gunShot,
            \group, ~srcGroup,
            \out, ~synthBus.index, \recOut, ~recBuses.click.index,
            \amp, 0.4, \dur, 0.3
        ).play;
        1.5.wait;

        "2:51.5 - [Cue 38: The Chase (8.5s)]".postln;
        Pbindef(\footsteps).stop;
        // CRITICAL FIX: The .max(0.02) clamps the shrinking rhythm to a floor of 20ms, preventing the geometric zero-duration node crash!
        Pbindef(\kineticRun, \dur, Pgeom(0.2, 0.9, inf).max(0.02), \freq, Pwhite(200, 800), \fmIndex, 2, \amp, 0.6).play;
        4.do { 2.wait; }; 0.5.wait;

        "3:00.0 - [Cue 39: Hound Pursuit (2.0s)]".postln;
        Pbindef(\dogHowl, \freq, Pwhite(1000, 2000), \dur, 0.5, \pan, Pwhite(-1.0, 1.0)).play;
        2.wait;

        "3:02.0 - [Cue 40: The Fire (10.0s)]".postln;
        Pbindef(\kineticRun).stop; Pbindef(\dogHowl).stop; Ndef(\windTexture).set(\vol, 0);
        Ndef(\fireCrackle).fadeTime = 2;
        Ndef(\fireCrackle).set(\vol, 0.8, \dens, 50); // FIX: vol
        5.do { |i| Ndef(\fireCrackle).xset(\dens, 50 + (i*10)); 2.wait; };

        "3:12.0 - [Cue 41: Glass Break (1.2s)]".postln;
        10.do { Synth(\staccatoClick, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \freq, rrand(3000, 8000), \fmIndex, rrand(10, 20), \amp, 0.6], target: ~srcGroup); 0.05.wait; };
        0.7.wait;

        "3:13.2 - [Cue 42: The Inner Sanctum (6.8s)]".postln;
        Ndef(\fireCrackle).xset(\lpf, 500);
        Ndef(\tensionBass).fadeTime = 2; Ndef(\tensionBass).set(\vol, 0.5, \cutoff, 200);
        3.do { 2.wait; }; 0.8.wait;

        "3:20.0 - [Cue 43: Final Ring (1.5s)]".postln;
        Pbindef(\bellRing, \dur, 0.1, \freq, 2500, \amp, 0.7).play;
        1.5.wait; Pbindef(\bellRing).stop;

        "3:21.5 - [Cue 44: One Hour (8.5s)]".postln;
        Ndef(\tensionBass).xset(\harm, 0.85);
        4.do { |i| Ndef(\tensionBass).xset(\modFreq, 1 + i); 2.wait; }; 0.5.wait;

        "3:30.0 - [Cue 45: Hysteria (10.0s)]".postln;
        Ndef(\fireCrackle).xset(\dens, 500, \lpf, 5000);
        Pbindef(\kineticRun, \dur, 0.03, \freq, Pwhite(500, 5000), \fmIndex, Pbrown(10, 50, 5)).play;
        5.do { |i| Ndef(\tensionBass).xset(\drive, 5 + i); 2.wait; };

        "3:40.0 - [Cue 46: Abrupt Stop (2.0s)]".postln;
        Pbindef.removeAll;
        Ndef(\tensionBass).set(\vol, 0);
        Ndef(\windTexture).set(\vol, 0);
        Ndef(\spectralGhost).set(\vol, 0);
        Ndef(\warmPad).set(\vol, 0);
        Ndef(\fireCrackle).set(\vol, 0);
        2.wait;

        "3:42.0 - [Cue 47: The Theme (12.0s)]".postln;
        Ndef(\masterMix).set(\wet10, 0.6);
        Pbindef(\pianoTheme, \freq, Pseq([659.25, 622.25, 587.33, 523.25, 493.88, 440], 2), \dur, 1.0, \stiffness, 1, \amp, 0.8).play;
        6.do { 2.wait; };

        "ACT III: THE TWIST".postln;
        "3:54.0 - [Cue 48: The Ghost Approaches (6.0s)]".postln;
        Pbindef(\thud, \instrument, \thud, \group, ~srcGroup, \out, ~synthBus.index, \recOut, ~recBuses.thud.index, \dur, 1.0, \amp, 0.8).play;
        6.wait;

        "4:00.0 - [Cue 49: The Door (1.5s)]".postln;
        Pbindef(\doorCreak, \dur, Pexprand(0.02, 0.1), \freq, Pwhite(200, 500)).play;
        1.5.wait; Pbindef(\doorCreak).stop;

        "4:01.5 - [Cue 50: Confrontation (8.5s)]".postln;
        Ndef(\tensionBass).set(\vol, 0.4, \cutoff, 100);
        Ndef(\spectralGhost).set(\vol, 0.7, \freeze, 1, \shift, 0.5);
        4.do { 2.wait; }; 0.5.wait;

        "4:10.0 - [Cue 51: Gunfire (1.2s)]".postln;
        Synth(\gunShot, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \amp, 1.0], target: ~srcGroup); 0.6.wait;
        Synth(\gunShot, [\out, ~synthBus.index, \recOut, ~recBuses.click.index, \amp, 1.0], target: ~srcGroup); 0.6.wait;

        "4:11.2 - [Cue 52: Immortal (4.8s)]".postln;
        Ndef(\tensionBass).set(\vol, 0); Ndef(\spectralGhost).set(\vol, 0); Pbindef.removeAll;
        4.do { 1.wait; }; 0.8.wait;

        "4:16.0 - [Cue 53: The Dead Speak (10.0s)]".postln;
        Ndef(\spectralGhost).fadeTime = 5;
        Ndef(\spectralGhost).set(\vol, 0.8, \shift, 0.2);
        5.do { |i| Ndef(\spectralGhost).xset(\shift, 0.2 + (i*0.05)); 2.wait; };

        "4:26.0 - [Cue 54: Hysteria Peak (2.0s)]".postln;
        Pbindef(\kineticRun, \dur, 0.05, \freq, Pwhite(1000, 4000), \fmIndex, 10).play;
        2.wait;

        "4:28.0 - [Cue 55: The Confession (12.0s)]".postln;
        Ndef(\tensionBass).fadeTime = 12;
        Ndef(\tensionBass).set(\vol, 0.6, \harm, 3, \drive, 5);
        Ndef(\tensionBass).xset(\harm, 0.1);
        6.do { 2.wait; };

        "4:40.0 - [Cue 56: The Twist (1.5s)]".postln;
        Ndef(\tensionBass).set(\vol, 0); Ndef(\spectralGhost).set(\vol, 0);
        Pbindef(\pianoTheme, \freq, Pseq([523.25, 659.25, 783.99]), \dur, 0.5, \stiffness, 0, \amp, 0.9).play;
        1.5.wait;

        "4:41.5 - [Cue 57: Sarcastic Kineticism (8.5s)]".postln;
        Pbindef(\kineticRun, \dur, Pseq([0.125, 0.125, 0.25], inf), \freq, Pseq([800, 1200, 600, 900], inf), \fmIndex, 1).play;
        4.do { 2.wait; }; 0.5.wait;

        "4:50.0 - [Cue 58: Resolution Sequences (10.0s)]".postln;
        Pbindef(\pianoTheme, \freq, Pseq([523.25, 587.33, 659.25, 783.99], inf), \dur, 0.25, \stiffness, 0.5).play;
        5.do { 2.wait; };

        "5:00.0 - [Cue 59: The Final Build (30.0s)]".postln;
        15.do { |i|
            Pbindef(\kineticRun, \fmIndex, 1 + i, \dur, Pseq([0.125, 0.125, 0.25] / (1 + (i*0.05)), inf));
            Pbindef(\pianoTheme, \stiffness, 0.5 + (i*0.1));
            2.wait;
        };

        "5:30.0 - [Cue 60: The Termination (30.0s)]".postln;
        Pbindef(\kineticRun, \dur, 0.015625, \fmIndex, 20);
        Pbindef(\pianoTheme, \dur, 0.03125, \stiffness, 5);
        15.do { 2.wait; };

        "6:00.0 - TERMINATION".postln;
        ~stopRecording.value;
        Pbindef.removeAll;
        Ndef.clear;
        Tdef.removeAll;
        "Score Complete.".postln;
    });

    Tdef(\masterScore).play;
});
)

// Source: compose-spacecraft.scd [Block 1]
// MODE: compose
// THEME: GLOBAL CONFIGURATION
// KEYWORDS: aeroFriction, bpf, clampThud, compose, configuration, cryoHiss, dataStream, diskRecorder, dynklank, fold, freeverb2, glassSeq, global, mainEngine, masterMix, noiseSweep, orbitalGlass, rlpf, safetyLimiter, sinosc, telemetryBlip
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state
    //~enableRecording = true;  // <--- UNCOMMENT THIS LINE TO ENABLE RECORDING

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Multitrack_Recording_Ballistic/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        telemetry: Bus.audio(s, 2),
        thud: Bus.audio(s, 2),
        glass: Bus.audio(s, 2),
        hiss: Bus.audio(s, 2),
        engine: Bus.audio(s, 2),
        aero: Bus.audio(s, 2),
        master: 0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    ~fftBufL = Buffer.alloc(s, 2048, 1);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\telemetryBlip, { |out=0, recOut, freq=1000, freqMult=1, amp=0.1, pan=0|
        var finalSig;
        var env = EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 2);
        var f = freq * freqMult;
        var mod = LFSaw.ar(f * 1.414) * f * 2 * env;
        var sig = SinOsc.ar(f + mod) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\clampThud, { |out=0, recOut, amp=1, decayscale=1|
        var finalSig;
        var env = EnvGen.ar(Env.perc(0.01, 2 * decayscale), doneAction: 2);
        var sig = SinOsc.ar(XLine.ar(800, 40, 0.05)) * env;
        var noise = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.1));
        sig = sig + Pluck.ar(noise, noise, 0.1, 1/60, 2 * decayscale, 0.5);
        sig = sig.tanh * amp;
        finalSig = Pan2.ar(sig, 0);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\orbitalGlass, { |out=0, recOut, freq=400, freqMult=1, amp=0.5, pan=0, atk=0.1, rel=4|
        var finalSig;
        var env = EnvGen.ar(Env.perc(atk, rel), doneAction: 2);
        var exciter = PinkNoise.ar(0.05) * EnvGen.ar(Env.perc(0.01, 0.1));
        var f = freq * freqMult;
        var sig = DynKlank.ar(Ref([[f, f*1.5, f*2.1, f*3.5], [1, 0.5, 0.3, 0.1], [1, 0.8, 0.6, 0.4]]), exciter, decayscale: rel);
        finalSig = Pan2.ar(sig * env * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\noiseSweep, { |out=0, recOut|
        var finalSig;
        var env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        var sig = WhiteNoise.ar * env * 0.3;
        finalSig = Pan2.ar(sig, Line.kr(-1, 1, 1.5));
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE (FIXED)
    // --------------------------------------------------------------------
    Ndef(\cryoHiss, { |ventFreq=400, amp=0|
        var noise = WhiteNoise.ar(0.5) + PinkNoise.ar(0.5);
        var sig = BPF.ar(noise, ventFreq, 0.2) * 3;
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\cryoHiss).play(~recBuses.hiss);
    Ndef(\cryoHiss).fadeTime = 4;

    Ndef(\mainEngine, { |thrustIndex=0, amp=0|
        var freqs = [40, 40.5, 39.5, 80, 81, 79, 20, 20.1];
        var mod = SinOsc.ar(freqs * 2.1) * (thrustIndex * 10) * freqs;
        var sig = SinOsc.ar(freqs + mod);
        sig = Fold.ar(sig * (1 + (thrustIndex * 5)), -0.5, 0.5);
        sig = RLPF.ar(sig, 100 + (thrustIndex * 6000), 0.3);
        Pan2.ar(Mix(sig) * amp * 0.5, 0);
    });
    Ndef(\mainEngine).play(~recBuses.engine);
    Ndef(\mainEngine).fadeTime = 2;

    Ndef(\aeroFriction, { |amp=0, density=0.1|
        var sig = WhiteNoise.ar(1);
        var chain = FFT(~fftBufL, sig);
        chain = PV_RandComb(chain, density, Impulse.kr(10));
        sig = IFFT(chain);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\aeroFriction).play(~recBuses.aero);
    Ndef(\aeroFriction).fadeTime = 1.5;

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var hiss = Ndef.ar(\cryoHiss, 2);
        var engine = Ndef.ar(\mainEngine, 2);
        var aero = Ndef.ar(\aeroFriction, 2);
        synths + hiss + engine + aero;
    });

    // Space Reverb
    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: \room.kr(0.9), damp: 0.2);
        verb;
    };
    Ndef(\masterMix).set(\wet10, 0);

    // Structural Stress Gating
    Ndef(\masterMix)[11] = \filter -> { |in|
        var stress = LFNoise0.kr(\stressRate.kr(0)).range(1 - \stressDepth.kr(0), 1);
        in * stress;
    };
    Ndef(\masterMix).set(\wet11, 1);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;

        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        "0:00 - [Cue 1: System Boot]".postln;
        0.5.wait;
        Synth(\clampThud, [\out, ~synthBus, \recOut, ~recBuses.thud, \amp, 0.8]);
        1.0.wait;

        "0:01.5 - [Cue 2: Cryogenic Venting]".postln;
        Ndef(\cryoHiss).set(\amp, 0.6);
        8.do { |i|
            Ndef(\cryoHiss).xset(\ventFreq, 400 + (i * 50));
            1.wait;
        };
        0.5.wait;

        "0:10.0 - [Cue 3: Telemetry Burst A]".postln;
        Pbindef(\dataStream,
            \instrument, \telemetryBlip,
            \out, ~synthBus,
            \recOut, ~recBuses.telemetry,
            \dur, 0.0625,
            \freq, Pxrand([800, 1200, 2000, 2400], inf),
            \freqMult, 1,
            \amp, 0.2,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;
        1.2.wait;

        "0:11.2 - [Cue 4: Metallic Echo]".postln;
        Pbindef(\dataStream).stop;
        Synth(\clampThud, [\out, ~synthBus, \recOut, ~recBuses.thud, \amp, 1.0]);
        Ndef(\masterMix).xset(\wet10, 0.6);
        3.do { 1.wait; };
        0.8.wait;

        "0:15.0 - [Cue 5: Telemetry Burst B]".postln;
        Pbindef(\dataStream, \freqMult, 1.5).play;
        2.do { 1.wait; };
        0.5.wait;

        "0:17.5 - [Cue 6: Ignition Sequence Start]".postln;
        Ndef(\cryoHiss).xset(\ventFreq, 150);
        8.do { |i|
            Ndef(\cryoHiss).xset(\amp, 0.6 + (i * 0.05));
            1.wait;
        };
        0.5.wait;

        "0:26.0 - [Cue 7: Pre-Flight Glitch]".postln;
        Pbindef(\dataStream, \dur, 0.03125, \freqMult, Pwhite(2.0, 5.0, inf));
        2.do { 1.wait; };
        0.1.wait;

        "0:28.1 - [Cue 8: The Spark]".postln;
        Pbindef(\dataStream).stop;
        Ndef(\mainEngine).set(\amp, 0.1, \thrustIndex, 0.01);
        6.do { 1.wait; };
        0.9.wait;

        "0:35.0 - [Cue 9: Liftoff / Flash]".postln;
        Ndef(\mainEngine).set(\amp, 0.8);
        3.do {
            Synth(\clampThud, [\out, ~synthBus, \recOut, ~recBuses.thud, \amp, 1.2]);
            0.15.wait;
        };
        1.55.wait;

        "0:37.0 - [Cue 10: Ascent Trajectory]".postln;
        8.do { |i|
            Ndef(\mainEngine).xset(\thrustIndex, (i+1) * 0.1);
            1.wait;
        };

        "0:45.0 - [Cue 11: Shockwave / Transonic]".postln;
        Ndef(\aeroFriction).set(\amp, 0.7, \density, 0.1);
        1.wait;
        0.5.wait;

        "0:46.5 - [Cue 12: Max Q Buildup]".postln;
        9.do { |i|
            Ndef(\mainEngine).xset(\thrustIndex, 0.8 + (i * 0.05));
            Ndef(\aeroFriction).xset(\density, 0.1 + (i * 0.05));
            1.wait;
        };
        0.5.wait;

        "0:56.0 - [Cue 13: Structural Stress]".postln;
        Ndef(\masterMix).set(\stressRate, 12, \stressDepth, 0.8);
        2.do { 1.wait; };
        0.2.wait;

        "0:58.2 - [Cue 14: Reaching Intrinsic Limit]".postln;
        9.do { |i|
            Ndef(\mainEngine).xset(\thrustIndex, 1.2 + (i * 0.1));
            Ndef(\aeroFriction).xset(\density, 0.6 + (i * 0.04));
            Ndef(\masterMix).set(\stressRate, 12 + (i * 2));
            1.wait;
        };
        0.8.wait;

        "1:08.0 - [Cue 15: Main Engine Cutoff]".postln;
        Ndef(\mainEngine).set(\amp, 0);
        Ndef(\aeroFriction).set(\amp, 0);
        Ndef(\masterMix).set(\stressDepth, 0);
        1.wait;
        0.5.wait;

        "1:09.5 - [Cue 16: Stage Separation]".postln;
        Synth(\clampThud, [\out, ~synthBus, \recOut, ~recBuses.thud, \amp, 1.2, \decayscale, 4]);
        5.do { 1.wait; };
        0.5.wait;

        "1:15.0 - [Cue 17: Vacuum Ignition]".postln;
        Ndef(\mainEngine).set(\amp, 0.3, \thrustIndex, 0.0);
        1.wait;
        0.8.wait;

        "1:16.8 - [Cue 18: Orbital Coasting]".postln;
        Ndef(\mainEngine).fadeTime = 8.2;
        Ndef(\mainEngine).xset(\amp, 0);
        8.do { 1.wait; };
        0.2.wait;

        "1:25.0 - [Cue 19: Payload Fairing Deploy]".postln;
        Synth(\noiseSweep, [\out, ~synthBus, \recOut, ~recBuses.thud]);
        1.wait;
        0.5.wait;

        "1:26.5 - [Cue 20: Orbital Insertion]".postln;
        Ndef(\masterMix).xset(\wet10, 0.9, \room, 0.95);
        Pbindef(\glassSeq,
            \instrument, \orbitalGlass,
            \out, ~synthBus,
            \recOut, ~recBuses.glass,
            \dur, Pwhite(2.0, 4.0, inf),
            \freq, Pxrand([300, 450, 600, 750, 900], inf),
            \freqMult, 1,
            \amp, 0.4,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;
        9.do { 1.wait; };
        0.5.wait;

        "1:36.0 - [Cue 21: Thruster Micro-Bursts]".postln;
        3.do {
            Ndef(\cryoHiss).set(\amp, 0.5, \ventFreq, 2000);
            0.1.wait;
            Ndef(\cryoHiss).set(\amp, 0);
            0.7.wait;
        };
        0.1.wait;

        "1:38.5 - [Cue 22: Solar Array Deployment]".postln;
        Pbindef(\glassSeq, \freqMult, Pseq([0.5, 1, 2, 4, 8], inf));
        9.do { 1.wait; };
        0.5.wait;

        "1:48.0 - [Cue 23: Handshake Ping]".postln;
        Pbindef(\dataStream, \dur, 1.0, \freqMult, 1, \amp, 0.1).play;
        3.do { 1.wait; };

        "1:51.0 - [Cue 24: Deep Space Swell]".postln;
        Ndef(\masterMix).xset(\room, 0.99);
        9.do { 1.wait; };

        "2:00.0 - [Cue 25: Signal Degradation]".postln;
        Pbindef(\dataStream, \amp, Pwhite(0.0, 0.1, inf));
        2.do { 1.wait; };
        0.5.wait;

        "2:02.5 - [Cue 26: The Long Fade]".postln;
        Pbindef.removeAll;
        Ndef(\cryoHiss).fadeTime = 12.5; Ndef(\cryoHiss).xset(\amp, 0);
        Ndef(\mainEngine).fadeTime = 12.5; Ndef(\mainEngine).xset(\amp, 0);
        Ndef(\aeroFriction).fadeTime = 12.5; Ndef(\aeroFriction).xset(\amp, 0);
        Ndef(\masterMix).fadeTime = 12.5; Ndef(\masterMix).xset(\wet10, 0);

        12.do { 1.wait; };
        0.5.wait;

        "2:15.0 - [Cue 27: Absolute Termination]".postln;
        ~stopRecording.value;
        Tdef.removeAll;
        Pbindef.removeAll;
        Ndef.clear;

        3.do { 5.wait; };

        "Score Complete. Server Silent.".postln;
    });

    Tdef(\masterScore).play;
    s.makeGui;
});
)

// Source: composition-constantinople-REVIEW.scd [Block 1]
// MODE: compose
// THEME: Uses additive chorusing, slow LFO filter sweeps, and wide stereo splay
// KEYWORDS: additive, chorusing, compose, droneSeq, evolvingDrone, filter, fmSolo, gverb, hpf, lfo, masterSpace, rlpf, saw, sinosc, slow, soloSeq, splay, stereo, swarmNode, swarmSeq, sweeps, uses, wide
(
s.waitForBoot({

    // --- TONAL/MODAL: Evolving Harmonic Drone ---
    // Uses additive chorusing, slow LFO filter sweeps, and wide stereo splay
    SynthDef(\evolvingDrone, {
        |out=0, freq=60, amp=0.2, gate=1, pan=0, lpfCenter=800|
        var env = EnvGen.ar(Env.asr(3, 1, 4, \sine), gate, doneAction: 2);
        // Chorus effect using slight frequency offsets
        var freqs = freq * [0.99, 1.0, 1.005, 1.01];
        var sig = Splay.ar(Saw.ar(freqs) * 0.3 + SinOsc.ar(freqs * 0.5));
        // Evolving filter
        var lfo = SinOsc.kr(0.1).range(0.5, 2.0);
        sig = RLPF.ar(sig, lpfCenter * lfo, 0.4);
        Out.ar(out, sig * env * amp);
    }).add;

    // --- SOLO: Expressive FM Voice ---
    // Clean, dynamic FM synthesis for modal solos
    SynthDef(\fmSolo, {
        |out=0, freq=440, amp=0.3, gate=1, pan=0, modIndex=3, modRatio=1.414|
        var env = EnvGen.ar(Env.asr(0.1, 1, 1.5, \sine), gate, doneAction: 2);
        // Envelope controlling the FM index for a brassy/plucked evolution
        var modEnv = EnvGen.kr(Env.perc(0.05, 1.5));
        var mod = SinOsc.ar(freq * modRatio) * freq * modIndex * modEnv;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig, pan, env * amp));
    }).add;

    // --- ATONAL/RHYTHMIC: Chaotic Phase Mod Swarm ---
    // High density, short durations, inharmonic ratios, chaotic panning
    SynthDef(\swarmNode, {
        |out=0, freq=400, amp=0.2, dur=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, dur, 1, -4), doneAction: 2);
        // Phase modulation with harsh inharmonic ratio
        var sig = PMOsc.ar(freq, freq * 1.732, LFNoise2.kr(5).range(1, 8));
        sig = HPF.ar(sig, 400); // Keep it out of the sub frequencies
        Out.ar(out, Pan2.ar(sig, pan, env * amp));
    }).add;

    s.sync;

    // =====================================================================
    // 2. GLOBAL EFFECTS (JITLib)
    // =====================================================================

    // Master Reverb Space - stays active through pauses to let tails ring
    Ndef(\masterSpace, {
        |revTime=6, damping=0.4, amp=1|
        var in = In.ar(\bus.kr(0), 2);
        var sig = GVerb.ar(in.sum, 200, revTime, damping, spread: 50, drylevel: 1, taillevel: 0.6);
        sig * amp;
    }).play;

    // Create an audio bus to route patterns into the Ndef
    ~fxBus = Bus.audio(s, 2);
    Ndef(\masterSpace).set(\bus, ~fxBus);

    // =====================================================================
    // 3. THE SCORE (Tdef - Gestural & Contrasting)
    // =====================================================================

    Tdef(\constantinopleScore, {
        var pause = 0.8; // Standardized short pause between gestures

        "0:00 - Gesture 1: Modal Drone & Sparse Solo (Tonal, Slow)".postln;
        // Wide stereo drone
        Pbindef(\droneSeq,
            \instrument, \evolvingDrone,
            \out, ~fxBus,
            \freq, Pseq([58, 65, 61, 58].midicps, inf), // Minor/Modal feel
            \dur, 8,
            \legato, 1.1, // Overlapping chords
            \lpfCenter, 600,
            \amp, 0.2
        ).play;

        4.wait;

        // Expressive center-panned solo
        Pbindef(\soloSeq,
            \instrument, \fmSolo,
            \out, ~fxBus,
            \scale, Scale.phrygian,
            \degree, Pseq([0, 1, 4, 3, 0], 1),
            \dur, Pseq([1.5, 0.5, 2, 2, 4], 1),
            \pan, Pwhite(-0.2, 0.2), // Slight movement
            \modIndex, Pseg([1, 4, 1], 10),
            \amp, 0.3
        ).play;

        10.wait; // Let the solo finish

        "0:14 - Terminate Gesture 1, let tails ring".postln;
        Pbindef(\droneSeq).stop;
        Pbindef(\soloSeq).stop;
        4.wait; // Wait for drone release
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:19 - Gesture 2: The Breach (Atonal, High Density, Polyphonic)".postln;
        // Fast, chaotic, atonal, violently bouncing across the stereo field
        Pbindef(\swarmSeq,
            \instrument, \swarmNode,
            \out, ~fxBus,
            \freq, Pwhite(200, 1500),
            \dur, Pwhite(0.02, 0.08), // Extreme rhythmic density
            \durNode, Pkey(\dur) * 1.5,
            \pan, Pwhite(-1.0, 1.0), // Hard panning
            \amp, 0.15
        ).play;

        6.wait;

        "0:25 - Terminate Gesture 2".postln;
        Pbindef(\swarmSeq).stop;
        2.wait; // Let short delays clear
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:28 - Gesture 3: Clash of Forces (Dense Drone vs Sparse Atonal bursts)".postln;
        Pbindef(\droneSeq, \dur, 4, \freq, Pseq([58, 59].midicps, inf), \lpfCenter, 1500).play; // Dissonant half-step drone

        // Occasional violent bursts intersecting the drone
        Pbindef(\swarmSeq,
            \dur, Pwrand([0.05, Rest(2)], [0.8, 0.2], inf),
            \freq, Pwhite(1000, 3000), // Higher spectral focus
            \amp, 0.1
        ).play;

        8.wait;

        "0:36 - Terminate Gesture 3".postln;
        Pbindef(\droneSeq).stop;
        Pbindef(\swarmSeq).stop;
        4.wait;
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:41 - Gesture 4: Final Lament (Tonal Solo, Wide Empty Space)".postln;
        // Increase reverb time to simulate an empty, ruined basilica
        Ndef(\masterSpace).xset(\revTime, 12);

        Pbindef(\soloSeq,
            \scale, Scale.minor,
            \degree, Pseq([7, 4, 2, 0], 1),
            \dur, Pseq([2, 3, 3, 8], 1),
            \modIndex, Pseq([0.5, 1, 1.5, 0.2]), // Subdued, softer FM
            \pan, Pseq([-0.5, 0.5, -0.2, 0], 1), // Expressive, wide placement
            \amp, 0.2
        ).play;

        16.wait; // Let the 16 beats of the sequence play out

        "0:57 - Terminate Gesture 4".postln;
        // Nothing to stop, Pseq(..., 1) finished on its own.
        // Let the massive reverb tail fade out gracefully.
        Ndef(\masterSpace).fadeTime = 10;
        Ndef(\masterSpace).clear(10);

        10.wait;
        "Score Complete.".postln;
    });

    // Make GUI for easy viewing
    s.makeWindow;

    // Start the piece automatically for testing
    Tdef(\constantinopleScore).play;

});
)

// Source: composition-constantinople.scd [Block 1]
// MODE: compose
// THEME: Limiter catches any peaks above 0.85 silently and transparently
// KEYWORDS: above, any, catches, compose, limiter, peaks, safetyLimiter, silently, transparently
(
SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter catches any peaks above 0.85 silently and transparently
    sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };
)

// Source: composition-constantinople.scd [Block 4]
// MODE: compose
// THEME: Smoothly fade the vast space reverb over 10 seconds
// KEYWORDS: celestialVoid, chimeSeq, compose, crumbleSeq, crumbleTexture, fade, omenChime, over, reverb, seconds, smoothly, space, the, vast, voidSeq
(
Tdef(\constantinopleScore, {

    "0:00 - [Movement I: Celestial Omen]".postln;
    Ndef(\celestialVoid).play;
    Ndef(\celestialVoid)[1] = \set -> Pbindef(\voidSeq);

    // Smoothly fade the vast space reverb over 10 seconds
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\wet10, 0.6);

    30.wait;

    "0:30 - [Omen's First Whisper]".postln;
    Ndef(\omenChime).play;
    Ndef(\omenChime)[1] = \set -> Pbindef(\chimeSeq);

    // Dry, immediate presence for the first omens
    Ndef(\omenChime).set(\wet10, 0.4, \wet11, 0);

    15.wait; // Now at 0:45

    "0:45 - [Movement II: Deepening Shadow]".postln;
    // Introduce minor-key inflections and increase chime density
    Pbindef(\voidSeq, \freq, Pn(Pseq([60, 63, 58, 65], 1), inf));
    Pbindef(\chimeSeq, \dur, Pwrand([2, 3, 4], [0.5, 0.3, 0.2], inf), \freq, Pn(Pseq([100, 105, 100, 95], 2), inf));

    // Slowly lower LPF to simulate encroaching darkness
    Ndef(\celestialVoid).fadeTime = 15;
    Ndef(\celestialVoid).xset(\lpfFreq, 800);

    // Fade in echoing premonitions
    Ndef(\omenChime).fadeTime = 8;
    Ndef(\omenChime).xset(\wet11, 0.3);
    Ndef(\omenChime).set(\amp, 0.5);

    25.wait; // Now at 1:10

    "1:10 - [Dread Intensifies]".postln;
    // Complex, slightly higher pitched chime patterns
    Pbindef(\chimeSeq, \freq, Pwrand([150, 180, 200, 160], [0.4, 0.3, 0.2, 0.1], inf));

    // Further darken the void
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\lpfFreq, 400, \amp, 0.3);

    // Lengthen and intensify the unsettling echoes
    Ndef(\omenChime).fadeTime = 5;
    Ndef(\omenChime).xset(\wet11, 0.5, \delayTime, 0.4);

    20.wait; // Now at 1:30

    "1:30 - [Movement III: The Fall]".postln;
    Ndef(\crumbleTexture).play;
    Ndef(\crumbleTexture)[1] = \set -> Pbindef(\crumbleSeq);

    // Rapid, dissonant clusters
    Pbindef(\chimeSeq, \dur, Pwhite(0.125, 0.25), \freq, Pwhite(250, 500));

    // Hard set to drastically thin and darken the pad, making space for the crumble
    Ndef(\celestialVoid).set(\lpfFreq, 200, \hpfFreq, 100);

    // Enter chaotic, reverberating wall of sound
    Ndef(\crumbleTexture).set(\wet11, 0.4, \wet12, 0.7, \bpfFreq, 1000, \amp, 0.6);
    Ndef(\omenChime).set(\wet11, 0.8, \delayTime, 0.6, \amp, 0.5);

    20.wait; // Now at 1:50

    "1:50 - [Aftermath / Lingering]".postln;
    Pbindef(\crumbleSeq).stop;
    Ndef(\crumbleTexture).clear(5); // Fade out the debris

    // Return to sparse, lower-frequency chime patterns with long decay
    Pbindef(\chimeSeq, \dur, Pwrand([3, 4, 5], [0.5, 0.3, 0.2], inf), \freq, Pwrand([100, 120], [0.8, 0.2], inf), \rel, 2);

    // Allow the low end of the void to return, but keep it muffled
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\hpfFreq, 50, \amp, 0.4);

    // Recede the echoes
    Ndef(\omenChime).fadeTime = 5;
    Ndef(\omenChime).xset(\wet11, 0.2, \delayTime, 0.2);

    25.wait; // Now at 2:15

    "2:15 - [Movement IV: Silence Descends]".postln;
    Pbindef(\chimeSeq).stop;
    Ndef(\omenChime).clear(15);

    // Expansive, dissipating sound fading into historical quietude
    Ndef(\celestialVoid).fadeTime = 15;
    Ndef(\celestialVoid).xset(\wet10, 0.9, \amp, 0.1, \lpfFreq, 100);

    30.wait; // Now at 2:45

    "2:45 - [Fade Out & Terminate]".postln;
    Pbindef(\voidSeq).stop;

    // Clear final nodes with a long, 15-second fade
    Ndef(\celestialVoid).clear(15);

    15.wait;
    "Score Complete.".postln;
});

// Create GUI
s.makeGui;
)

// Source: composition-day-in-three-minutes.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: compose, first, limiter, master, persistent, safety, safetyLimiter
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Strict limiter to ensure 5 simultaneous proxies never exceed 0.85
    sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

s.makeGui;
)

// Source: composition-day-in-three-minutes.scd [Block 5]
// MODE: compose
// THEME: Establish a vast, bloody Roman battlefield
// KEYWORDS: battlefield, bloody, brassSaw, brassSeq, choirFM, choirSeq, compose, drumSeq, establish, fireNoise, fireSeq, roman, skyAnomaly, skySeq, vast, warDrum
(
Tdef(\april14thScore, {

    "0:00 — Movement I: Antiquity & Empires (43 BC & 69 AD)".postln;
    Ndef(\warDrum).play;
    Ndef(\warDrum)[1] = \set -> Pbindef(\drumSeq);

    // Establish a vast, bloody Roman battlefield
    Ndef(\warDrum).xset(\wet10, 0.6);
    // Ndef(\warDrum).xset(\wet10, 0); // Revert to dry

    10.wait; // Now at 0:10

    "0:10 — The Holy Unions (966 & 972)".postln;
    Ndef(\choirFM).play;
    Ndef(\choirFM)[1] = \set -> Pbindef(\choirSeq);

    // Smooth, pure angelic sine tones
    Ndef(\choirFM).xset(\modIndex, 0.5, \wet10, 0.7);
    // Ndef(\choirFM).xset(\modIndex, 2, \wet10, 0); // Revert to complex FM dry

    Pbindef(\drumSeq, \dur, 1, \freq, 100); // Sparse, slow pulse
    // Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf), \freq, Pwhite(150, 250)); // Revert drums

    8.wait; // Now at 0:18

    "0:18 — The Medieval Clashes (1205, 1395, 1471)".postln;
    Ndef(\brassSaw).play;
    Ndef(\brassSaw)[1] = \set -> Pbindef(\brassSeq);

    // Hard set on decay, xset on brass filter, ducking choir
    Ndef(\warDrum).set(\decayTime, 2.0);
    // Ndef(\warDrum).set(\decayTime, 1); // Revert drum decay

    Ndef(\brassSaw).xset(\lpfFreq, 600); // Thick fog of Barnet
    // Ndef(\brassSaw).xset(\lpfFreq, 2000); // Revert brass filter

    Ndef(\choirFM).xset(\amp, 0.15); // Duck choir for dense harmonic brass
    // Ndef(\choirFM).xset(\amp, 0.3); // Revert choir amp

    Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25], [0.8, 0.2], inf), \freq, Pwhite(150, 300)); // Chaotic
    // Pbindef(\drumSeq, \dur, 1, \freq, 100); // Revert to sparse pulse

    12.wait; // Now at 0:30

    "0:30 — Movement II: The Nuremberg Sky (1561)".postln;
    Ndef(\warDrum).stop;
    Ndef(\brassSaw).stop;

    Ndef(\skyAnomaly).play;
    Ndef(\skyAnomaly)[1] = \set -> Pbindef(\skySeq);

    // Radical alien departure
    Ndef(\skyAnomaly).set(\wet11, 0.8, \delayDecay, 5);
    // Ndef(\skyAnomaly).set(\wet11, 0, \delayDecay, 3); // Revert anomaly delay

    15.wait; // Now at 0:45

    "0:45 — Movement III: Rebellions & Fire (1639, 1775, 1793, 1816, 1849)".postln;
    Ndef(\skyAnomaly).stop;

    Ndef(\warDrum).play;
    Ndef(\brassSaw).play;

    // Defiant swell of emancipation
    Ndef(\brassSaw).xset(\freqMult, 1.5, \lpfFreq, 3000);
    // Ndef(\brassSaw).xset(\freqMult, 1, \lpfFreq, 600); // Revert brass swell

    Ndef(\choirFM).xset(\amp, 0.1); // Duck choir further
    // Ndef(\choirFM).xset(\amp, 0.15); // Revert choir ducking

    Pbindef(\drumSeq, \dur, 0.5, \freq, 200); // Marching rhythm
    // Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25], [0.8, 0.2], inf)); // Revert marching rhythm

    20.wait; // Now at 1:05

    "1:05 — The Christiania Fire (1858)".postln;
    Ndef(\fireNoise).play;
    Ndef(\fireNoise)[1] = \set -> Pbindef(\fireSeq);

    // Crackle of burning city blocks
    Ndef(\fireNoise).xset(\bpfFreq, 4000);
    // Ndef(\fireNoise).xset(\bpfFreq, 2000); // Revert fire sweep

    15.wait; // Now at 1:20

    "1:20 — Movement IV: Assassinations (1865)".postln;
    Pbindef(\drumSeq).stop;
    Pbindef(\brassSeq).stop;
    Pbindef(\fireSeq).stop;
    Ndef(\brassSaw).stop;
    Ndef(\fireNoise).stop;

    // Dissonant minor interval
    Ndef(\choirFM).set(\freq, 146.83, \modRatio, 1.5, \decayTime, 8, \amp, 0.4);
    // Ndef(\choirFM).set(\freq, 440, \modRatio, 2, \decayTime, 2, \amp, 0.1); // Revert choir minor

    2.wait; // 1:22

    // Two incredibly loud, dry snaps
    Ndef(\warDrum).set(\freq, 800, \decayTime, 0.1, \amp, 0.8, \wet10, 0.1, \t_trig, 1);
    // Ndef(\warDrum).set(\freq, 200, \decayTime, 2.0, \amp, 0.4, \wet10, 0.6); // Revert drum state

    0.5.wait; // 1:22.5
    Ndef(\warDrum).set(\t_trig, 1);

    17.5.wait; // Now at 1:40

    "1:40 — The Wild West (1881)".postln;
    // Four Dead in Five Seconds Gunfight
    Ndef(\warDrum).set(\freq, 1500, \decayTime, 0.05, \amp, 0.8, \wet10, 0);
    // Ndef(\warDrum).set(\freq, 800, \decayTime, 0.1, \amp, 0.8, \wet10, 0.1); // Revert gunfight drums

    4.do {
        Ndef(\warDrum).set(\t_trig, 1);
        0.2.wait;
    };

    4.2.wait; // 0.8s + 4.2s = 5s. Now at 1:45

    "1:45 — Movement V: Modernity & The Kinetoscope (1890, 1894)".postln;
    Ndef(\skyAnomaly).play;
    Pbindef(\skySeq, \dur, 0.125, \freq, 4000).play; // Rigid 16th notes
    // Pbindef(\skySeq, \dur, Pwhite(0.05, 0.15), \freq, Pwhite(3000, 6000)); // Revert sky sequence

    // Dry mechanical clicking
    Ndef(\skyAnomaly).set(\wet11, 0);
    // Ndef(\skyAnomaly).set(\wet11, 0.8); // Revert mechanical anomaly

    // Warm, stable chords
    Ndef(\choirFM).xset(\freq, 261.63, \modRatio, 2, \modIndex, 1, \amp, 0.3);
    // Ndef(\choirFM).xset(\freq, 146.83, \modRatio, 1.5, \modIndex, 0.5, \amp, 0.4); // Revert choir chords

    15.wait; // Now at 2:00

    "2:00 — The Ljubljana Earthquake (1895)".postln;
    Ndef(\fireNoise).play;
    Pbindef(\fireSeq, \dur, 0.05, \bpfFreq, 1000).play;
    // Pbindef(\fireSeq, \dur, Pwhite(0.02, 0.1), \bpfFreq, Pwhite(2000, 6000)); // Revert fire sequence

    // Massive shaking sub-bass rumble
    Ndef(\fireNoise).set(\wet12, 1);
    Ndef(\fireNoise).xset(\resFreq, 60, \resRq, 0.1, \amp, 0.8);
    // Ndef(\fireNoise).set(\wet12, 0); Ndef(\fireNoise).xset(\amp, 0.3); // Revert earthquake

    // High-pass all other instruments to survive tectonic masking
    Ndef(\choirFM).xset(\hpfFreq, 400);
    Ndef(\skyAnomaly).xset(\hpfFreq, 400);
    // Ndef(\choirFM).xset(\hpfFreq, 20); Ndef(\skyAnomaly).xset(\hpfFreq, 20); // Revert high-pass

    10.wait; // Now at 2:10

    "2:10 — The Exposition Universelle (1900)".postln;
    Pbindef(\fireSeq).stop;
    Ndef(\fireNoise).stop;
    Ndef(\skyAnomaly).stop;

    Ndef(\brassSaw).play;

    // Unified major sequence
    Pbindef(\choirSeq, \dur, 2, \freq, Pseq([261.63, 329.63, 392.00, 523.25], inf));
    Pbindef(\brassSeq, \dur, 2, \freq, Pseq([130.81, 164.81, 196.00, 261.63], inf));
    // Pbindef(\choirSeq, \dur, 4, \freq, Pseq([220, 261.63, 329.63, 293.66], inf)); // Revert choir seq
    // Pbindef(\brassSeq, \dur, 2, \freq, Pseq([110, 146.83, 164.81, 130.81], inf)); // Revert brass seq

    Pbindef(\brassSeq).play;

    // Remove high-pass, open brass fully, massive shimmering reverb
    Ndef(\choirFM).xset(\hpfFreq, 20, \wet10, 0.8, \amp, 0.3);
    Ndef(\brassSaw).xset(\hpfFreq, 20, \lpfFreq, 8000, \wet10, 0.8, \amp, 0.3);
    // Ndef(\brassSaw).xset(\lpfFreq, 3000, \wet10, 0); // Revert brass exposition

    20.wait; // Now at 2:30

    "2:30 — Movement VI: The Event Horizon (Outro)".postln;
    Pbindef(\choirSeq).stop;
    Pbindef(\brassSeq).stop;
    // Sequences halt, leaving only the lush ringing reverb tails

    10.wait; // Now at 2:40

    "2:40 — The Final Fade".postln;
    // 20-second unsegmented organic fade to absolute black
    Ndef(\warDrum).clear(20);
    Ndef(\choirFM).clear(20);
    Ndef(\skyAnomaly).clear(20);
    Ndef(\fireNoise).clear(20);
    Ndef(\brassSaw).clear(20);

    20.wait; // Now at 3:00

    "3:00 — Terminate".postln;
    "Score Complete. Server left in total silence.".postln;
});
)

// Source: composition-feijoada-v2.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: acompanhamentos, bpf, brazilianSpice, carneTextura, celebrationSynth, compose, darkThump, enterroOssos, feijaoBase, first, freeverb2, globalReverb, grainSplat, gritDistortion, historicalMurmur, hpf, limiter, mainDelay, master, masterFilter, persistent, pulse, rhythmPortugues, ringz, rlpf, safety, safetyLimiter, saw, spiceAmp
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================
SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Strict limiter to protect hardware
    sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

// =====================================================================
// 1. ARCHITECTURE, BUSES, & SYNTHDEFS
// =====================================================================
s.waitForBoot({

    // Dedicated Routing Buses
    ~revBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);
    ~gritBus = Bus.audio(s, 2);
    ~synthMixBus = Bus.audio(s, 2);

    // --- SYNTHDEFS (Discrete Events) ---

    SynthDef(\pulse, { |amp=0.1, pan=0, revSend=0.2|
        var sig = LPF.ar(Impulse.ar(0), 1000) + BPF.ar(WhiteNoise.ar, 1500, 0.5, 0.5);
        var env = EnvGen.ar(Env.perc(0.001, 0.1), doneAction: 2);
        sig = Pan2.ar(sig * env, pan) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    SynthDef(\grainSplat, { |amp=0.1, pan=0, pitch=1000, revSend=0.2|
        var env = EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);
        var sig = SinOsc.ar(pitch * XLine.kr(1, 0.5, 0.1)) * env;
        sig = sig + (PinkNoise.ar * env * 0.5);
        sig = BPF.ar(sig, pitch, 0.3);
        sig = Pan2.ar(sig, pan) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    SynthDef(\darkThump, { |amp=0.5, freq=30, decay=5, revSend=0.4|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var pitchEnv = XLine.kr(freq * 3, freq, 0.1);
        var sig = SinOsc.ar(pitchEnv) * env;
        sig = LPF.ar(sig, 100);
        sig = Pan2.ar(sig, 0) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    s.sync;

    // --- NDEFS (Continuous Textures & Drones) ---
    Ndef.clear;

    Ndef(\feijaoBase, { |freq=50, amp=0, cutoff=200, rq=0.2, filterLfoFreq=0.1, filterLfoAmp=100, revSend=0.4|
        var sig = Saw.ar([freq, freq*1.01]);
        var lfo = SinOsc.kr(filterLfoFreq).range(cutoff, cutoff + filterLfoAmp);
        sig = RLPF.ar(sig, lfo.clip(20, 15000), rq);
        sig = sig * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\carneTextura, { |grainDensity=0.1, grainSpread=0.5, amp=0, freqMul=1, wetDry=0.2, revSend=0.2|
        var trig = Dust.ar(grainDensity * 50);
        var pan = TRand.ar(grainSpread.neg, grainSpread, trig);
        var freq = TRand.ar(1000, 5000, trig) * freqMul;
        var src = SinOsc.ar(freq) * 0.5 + BPF.ar(WhiteNoise.ar, freq, 0.1);
        var sig = GrainIn.ar(2, trig, TRand.ar(0.01, 0.05, trig), src, pan);
        var rev = FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.1);
        sig = XFade2.ar(sig, rev, wetDry * 2 - 1) * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\acompanhamentos, { |amp=0, decay=0.5, freq1=800, freq2=1200, freq3=2500, revSend=0.3|
        var trig = Dust.ar(3);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01), trig);
        var sig = [freq1, freq2, freq3].collect({ |f| Ringz.ar(exciter, f, decay) }).sum;
        sig = Pan2.ar(sig, TRand.kr(-0.5, 0.5, trig)) * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\historicalMurmur, { |modIndex=0.5, carrierFreq=200, feedbackGain=0.8, amp=0, filterCutoff=5000, revSend=0.2, gritSend=0|
        var fbIn = LocalIn.ar(1);
        var mod = SinOsc.ar(carrierFreq * 1.3 + (fbIn * feedbackGain * 1000)) * modIndex * carrierFreq;
        var sig = SinOsc.ar(carrierFreq + mod);
        sig = LeakDC.ar(sig);
        LocalOut.ar(sig);
        sig = LPF.ar(sig, filterCutoff.clip(20, 20000));
        sig = Pan2.ar(sig, 0) * amp;
        Out.ar(~revBus, sig * revSend);
        Out.ar(~gritBus, sig * gritSend);
        sig;
    });

    Ndef(\celebrationSynth, { |amp=0, detune=0.01, filterCutoff=800, filterRes=0.3, revSend=0.4, delaySend=0|
        var freqs = [60, 63, 67, 70].midicps;
        var sig = freqs.collect({ |f| Saw.ar([f, f * (1 + detune)]) }).sum;
        sig = RLPF.ar(sig, filterCutoff.clip(20, 20000), filterRes);
        sig = sig * amp;
        Out.ar(~revBus, sig * revSend);
        Out.ar(~delayBus, sig * delaySend);
        sig;
    });

    // --- EFFECTS & MASTER BUS ---

    Ndef(\globalReverb, { |roomsize=0.8, mix=0.4|
        var in = In.ar(~revBus, 2);
        XFade2.ar(in, FreeVerb2.ar(in[0], in[1], 1, roomsize, 0.2), mix * 2 - 1);
    });

    Ndef(\mainDelay, { |delaytime=0.375, feedback=0, mix=0|
        var in = In.ar(~delayBus, 2);
        XFade2.ar(in, CombC.ar(in, 2.0, delaytime, feedback * 10), mix * 2 - 1);
    });

    Ndef(\gritDistortion, { |drive=0, preHPF=100, mix=0|
        var in = In.ar(~gritBus, 2);
        var sig = HPF.ar(in, preHPF.clip(20, 10000));
        sig = LeakDC.ar(sig);
        sig = (sig * (1 + (drive * 20))).softclip;
        XFade2.ar(in, sig, mix * 2 - 1);
    });

    Ndef(\masterFilter, { |cutoff=20000, rq=1.0|
        var synths = In.ar(~synthMixBus, 2);
        var ndefs = Ndef.ar(\feijaoBase) + Ndef.ar(\carneTextura) + Ndef.ar(\acompanhamentos) +
                    Ndef.ar(\historicalMurmur) + Ndef.ar(\celebrationSynth);
        var fx = Ndef.ar(\globalReverb) + Ndef.ar(\mainDelay) + Ndef.ar(\gritDistortion);
        var mix = synths + ndefs + fx;
        RLPF.ar(mix, cutoff.clip(20, 20000), rq);
    }).play;

    // Control bus for dynamic amplitude scaling of Pbinds
    Ndef(\spiceAmp, { 0 });

    s.sync;

    // =====================================================================
    // 2. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        "0:00 - [Movement I: The Stew's Opening Aroma]".postln;
        Ndef(\feijaoBase).set(\freq, 50, \cutoff, 200, \rq, 0.2);
        Ndef(\feijaoBase).fadeTime = 15;
        Ndef(\feijaoBase).xset(\amp, 0.3);

        Ndef(\carneTextura).set(\amp, 0.15);
        Ndef(\carneTextura).fadeTime = 20;
        Ndef(\carneTextura).xset(\grainDensity, 0.3);

        Ndef(\globalReverb).set(\roomsize, 0.8, \mix, 0.4);

        30.wait;

        "0:30 - [Movement I: Popularity's Gentle Pulse]".postln;
        Ndef(\acompanhamentos).fadeTime = 5;
        Ndef(\acompanhamentos).xset(\amp, 0.15, \decay, 0.8);

        Ndef(\feijaoBase).fadeTime = 45;
        Ndef(\feijaoBase).xset(\cutoff, 400);

        45.wait;

        "1:15 - [Movement II: Ancient Echoes (SUBTRACTION)]".postln;
        // Kill the percussion to create a stark, empty contrast
        Ndef(\acompanhamentos).fadeTime = 8;
        Ndef(\acompanhamentos).xset(\amp, 0);

        // Push the base drone to the background
        Ndef(\feijaoBase).fadeTime = 10;
        Ndef(\feijaoBase).xset(\amp, 0.05, \cutoff, 150);

        Ndef(\historicalMurmur).set(\carrierFreq, 200, \feedbackGain, 0.8, \amp, 0.2, \modIndex, 0.5);

        Pbindef(\rhythmPortugues,
            \instrument, \pulse,
            \dur, 4,
            \amp, 0.1
        ).play;

        Ndef(\carneTextura).fadeTime = 10; Ndef(\carneTextura).xset(\grainDensity, 0.05, \amp, 0.1);
        Ndef(\historicalMurmur).fadeTime = 30; Ndef(\historicalMurmur).xset(\modIndex, 1.2);
        Ndef(\globalReverb).fadeTime = 15; Ndef(\globalReverb).xset(\mix, 0.2);

        45.wait;

        "2:00 - [Movement II: Scarcity's Grit]".postln;
        Ndef(\historicalMurmur).fadeTime = 30; Ndef(\historicalMurmur).xset(\gritSend, 1.0);
        Ndef(\gritDistortion).fadeTime = 30; Ndef(\gritDistortion).xset(\drive, 0.6, \mix, 0.5);
        Pbindef(\rhythmPortugues, \amp, 0.2, \dur, Pseq([4, 3.5, 0.5], inf));

        45.wait;

        "2:45 - [Movement III: Brazilian Adaptation Begins]".postln;
        Pbindef(\rhythmPortugues).stop;

        Ndef(\historicalMurmur).fadeTime = 2; Ndef(\historicalMurmur).xset(\gritSend, 0);
        Ndef(\gritDistortion).fadeTime = 2; Ndef(\gritDistortion).xset(\mix, 0);

        Ndef(\historicalMurmur).fadeTime = 15; Ndef(\historicalMurmur).xset(\modIndex, 0.8, \amp, 0.1);
        Ndef(\feijaoBase).fadeTime = 20; Ndef(\feijaoBase).xset(\amp, 0.25, \cutoff, 600);
        Ndef(\carneTextura).fadeTime = 15; Ndef(\carneTextura).xset(\grainDensity, 0.4, \amp, 0.3);

        30.wait;

        "3:15 - [Movement III: New Accompaniments (PARAMETER SHIFT)]".postln;
        // Bring \acompanhamentos back, but tight and clicking
        Ndef(\acompanhamentos).fadeTime = 5;
        Ndef(\acompanhamentos).xset(\amp, 0.2, \decay, 0.05, \freq1, 1500, \freq2, 2200, \freq3, 3500);

        Ndef(\spiceAmp, { Line.kr(0, 0.4, 20) });
        Pbindef(\brazilianSpice,
            \instrument, \grainSplat,
            \dur, Pseq([0.5, 0.7, 0.3], inf),
            \pitch, Pwhite(800, 2500),
            \pan, Pwhite(-0.8, 0.8),
            \amp, Ndef(\spiceAmp).asMap
        ).play;

        Ndef(\globalReverb).fadeTime = 20; Ndef(\globalReverb).xset(\mix, 0.35);

        60.wait;

        "4:15 - [Movement IV: The Burial of Bones & Comettant's Description]".postln;
        Pbindef(\enterroOssos,
            \instrument, \darkThump,
            \freq, 30,
            \amp, 0.5,
            \decay, 5,
            \dur, Pseq([5, 5, 5, Rest(inf)], 1)
        ).play;

        Ndef(\historicalMurmur).set(\amp, 0.05, \filterCutoff, 100);
        Ndef(\spiceAmp, { 0.1 });

        Ndef(\carneTextura).fadeTime = 5; Ndef(\carneTextura).xset(\freqMul, 2.5); // "Repugnant"

        5.wait;

        Ndef(\carneTextura).fadeTime = 5; Ndef(\carneTextura).xset(\freqMul, 1.0); // "Agreeable"

        10.wait;

        Ndef(\spiceAmp, { Line.kr(0.1, 0.4, 5) });

        30.wait;

        "5:00 - [Movement IV: G. Lobo's Legacy]".postln;
        Ndef(\celebrationSynth).set(\amp, 0.4, \delaySend, 1.0);
        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\detune, 0.03);

        Ndef(\mainDelay).fadeTime = 20; Ndef(\mainDelay).xset(\mix, 0.4, \feedback, 0.6);
        Ndef(\feijaoBase).fadeTime = 10; Ndef(\feijaoBase).xset(\amp, 0.35);
        Ndef(\carneTextura).fadeTime = 10; Ndef(\carneTextura).xset(\amp, 0.4);

        60.wait;

        "6:00 - [Movement V: The Grand Celebration]".postln;
        Pbindef(\enterroOssos).stop;

        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\amp, 0.6, \filterCutoff, 1200);
        Ndef(\spiceAmp, { Line.kr(0.4, 0.6, 20) });
        Pbindef(\brazilianSpice, \dur, Pseq([0.15, 0.2, 0.1], inf));

        Ndef(\feijaoBase).fadeTime = 15; Ndef(\feijaoBase).xset(\amp, 0.4, \cutoff, 800);
        // Bring acompanhamentos back to ringing for the climax
        Ndef(\acompanhamentos).fadeTime = 20; Ndef(\acompanhamentos).xset(\amp, 0.45, \decay, 0.8, \freq1, 800, \freq2, 1200, \freq3, 2500);
        Ndef(\globalReverb).fadeTime = 20; Ndef(\globalReverb).xset(\mix, 0.6, \roomsize, 0.9);
        Ndef(\masterFilter).fadeTime = 60; Ndef(\masterFilter).xset(\cutoff, 8000);

        60.wait;

        "7:00 - [Movement V: Peak of Abundance]".postln;
        Ndef(\mainDelay).set(\feedback, 0.7);

        45.wait;

        "7:45 - [Movement VI: Digestivo & Lingering Taste]".postln;
        Pbindef(\brazilianSpice).stop;

        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\amp, 0);
        Ndef(\acompanhamentos).fadeTime = 25; Ndef(\acompanhamentos).xset(\amp, 0);
        Ndef(\carneTextura).fadeTime = 35; Ndef(\carneTextura).xset(\amp, 0);
        Ndef(\mainDelay).fadeTime = 20; Ndef(\mainDelay).xset(\mix, 0, \feedback, 0);
        Ndef(\globalReverb).fadeTime = 30; Ndef(\globalReverb).xset(\mix, 0.1, \roomsize, 0.3);

        30.wait;

        "8:15 - [Movement VI: The Last Memory]".postln;
        Ndef(\feijaoBase).fadeTime = 15; Ndef(\feijaoBase).xset(\amp, 0);
        Ndef(\historicalMurmur).fadeTime = 10; Ndef(\historicalMurmur).xset(\amp, 0);
        Ndef(\masterFilter).fadeTime = 15; Ndef(\masterFilter).xset(\cutoff, 200);

        15.wait;

        "8:30 - [Terminating]".postln;
        Pbindef.removeAll;
        Ndef.clear(5);

        "Score Complete.".postln;
    });

    s.makeGui;

    // Execute the composition
    Tdef(\masterScore).play;
});
)

// Source: composition-feijoada.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: allpassc, bpf, carne, carneSeq, compose, dynklank, first, fruta, frutaSeq, gverb, limiter, master, persistent, rlpf, safety, safetyLimiter, saw, semente, sementeSeq, terra, terraSeq, vapor, vaporSeq
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter catches any peaks above 0.95 silently and transparently
    sig = Limiter.ar(sig, level: 0.95, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };


// =====================================================================
// 1. INSTRUMENTS & EFFECTS (JITLib)
// =====================================================================

// Initialize Master Bus
Ndef(\master, {
    var sig = Ndef.ar(\terra) + Ndef.ar(\semente) + Ndef.ar(\carne) + Ndef.ar(\fruta) + Ndef.ar(\vapor);
    sig.softclip; // Prevent harsh digital clipping before the limiter
}).play;

// --- INSTRUMENTS ---

Ndef(\terra, {
    |freq=50, freqMult=1, amp=0.4, ampMod=1, t_trig=1, lpfFreq=200, lpfFreqMult=1|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 4]), t_trig);
    var detune = SinOsc.kr(0.1).range(0.99, 1.01);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * detune]);
    var sub = Pulse.ar([freq * freqMult * 0.5, freq * freqMult * 0.505], 0.4);
    sig = RLPF.ar(sig + sub, lpfFreq * lpfFreqMult, 0.5);
    sig * env * amp * ampMod;
});

Ndef(\semente, {
    |freq=800, freqMult=1, amp=0.3, ampMod=1, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
    var noise = WhiteNoise.ar * env;
    var f = freq * freqMult;
    // Standard array formatting for dynamic UGen evaluation in DynKlank
    var freqs = [f, f * 1.4, f * 2.1, f * 2.7];
    var amps = [1.0, 0.6, 0.4, 0.2];
    var rings = [0.1, 0.08, 0.05, 0.02];
    var sig = DynKlank.ar(`[freqs, amps, rings], noise);
    Pan2.ar(sig * amp * ampMod, TRand.kr(-0.4, 0.4, t_trig));
});

Ndef(\carne, {
    |freq=150, freqMult=1, amp=0.3, ampMod=1, t_trig=1, modIndex=1|
    var env = EnvGen.ar(Env([0, 1, 0.7, 0], [0.5, 1.5, 2.5]), t_trig);
    var mFreq1 = freq * freqMult * 1.414;
    var mFreq2 = freq * freqMult * 0.5;
    var mod2 = SinOsc.ar(mFreq2) * (modIndex * 2) * mFreq2;
    var mod1 = SinOsc.ar(mFreq1 + mod2) * modIndex * mFreq1;
    var sig = SinOsc.ar([freq * freqMult, freq * freqMult * 1.01] + mod1);
    sig = LPF.ar(sig, 3000);
    sig * env * amp * ampMod;
});

Ndef(\fruta, {
    |freq=2500, freqMult=1, amp=0.15, ampMod=1, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.05, 0.5), t_trig);
    var pitchLfo = SinOsc.ar(15).range(0.98, 1.02);
    var ampLfo = SinOsc.ar(20).range(0.3, 1.0);
    var sig = SinOsc.ar([freq * freqMult * pitchLfo, freq * freqMult * pitchLfo * 1.01]);
    sig * env * amp * ampMod * ampLfo;
});

Ndef(\vapor, {
    |amp=0.2, ampMod=1, t_trig=1, bpfFreq=500, bpfFreqMult=1, sweepMod=0|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [1.0, 1.0, 2.5]), t_trig);
    var noise = PinkNoise.ar(1 ! 2);
    // sweepMod blends between external Pbindef control and internal slow sweep
    var slowSweep = SinOsc.kr(0.05).exprange(200, 800);
    var freq = XFade2.kr(bpfFreq, slowSweep, sweepMod * 2 - 1);
    var sig = BPF.ar(noise, freq * bpfFreqMult, 0.2);
    sig * env * amp * ampMod;
});

// --- EFFECTS (Master Slots) ---

// Slot 10: Master Verb (GVerb)
Ndef(\master)[10] = \filter -> { |in|
    var decay = \verbDecay.kr(4);
    GVerb.ar(in.sum, 150, decay, 0.5, 0.5, 15, 0.5, 0.7, 0.5);
};
Ndef(\master).set(\wet10, 0);

// Slot 11: Stew Diffusion (AllpassC Chain)
Ndef(\master)[11] = \filter -> { |in|
    var dly = \stewDelay.kr(0.1).clip(0.001, 1.9);
    var dec = \stewDecay.kr(1.0);
    var sig = AllpassC.ar(in, 2.0, [dly, dly * 1.1], dec);
    sig = AllpassC.ar(sig, 2.0, [dly * 0.9, dly * 1.05], dec);
    sig;
};
Ndef(\master).set(\wet11, 0);

// Slot 12: Flavor Filter (Dynamic multi-band)
Ndef(\master)[12] = \filter -> { |in|
    var bpfFreq = \flavorBpfFreq.kr(1000);
    var rq = \flavorRq.kr(1.0);
    var mix = \flavorMix.kr(0); // 0 = flat, 1 = filtered
    var filtered = BPF.ar(in, bpfFreq, rq) * (1 / rq.max(0.1).sqrt); // Gain compensation
    XFade2.ar(in, filtered, mix * 2 - 1);
};
Ndef(\master).set(\flavorMix, 0, \flavorBpfFreq, 1000, \flavorRq, 1.0);


// =====================================================================
// 2. PATTERNS
// =====================================================================

Pbindef(\terraSeq, \dur, 6, \freq, Pseq([50, 55, 48, 52], inf), \t_trig, 1);
Pbindef(\sementeSeq, \dur, 2, \freq, Pseq([800, 1200, 900], inf), \t_trig, 1);
Pbindef(\carneSeq, \dur, 4, \freq, Pseq([150, 180, 160], inf), \t_trig, 1);
Pbindef(\frutaSeq, \dur, Pwhite(0.5, 1.5), \freq, Pwhite(2000, 3500), \t_trig, 1);
Pbindef(\vaporSeq, \dur, 4, \bpfFreq, 500, \t_trig, 1); // Initial slow rhythmic state

[Ndef(\terra), Ndef(\semente), Ndef(\carne), Ndef(\fruta), Ndef(\vapor)].do(_.quant_(1));


// =====================================================================
// 3. THE SCRIPT (Tdef - 5 Minute Score)
// =====================================================================

Tdef(\feijoadaScore, {

    "0:00 - [Movement I: Raízes Antigas]".postln;
    Ndef(\terra)[1] = \set -> Pbindef(\terraSeq);
    Ndef(\semente)[1] = \set -> Pbindef(\sementeSeq);

    Ndef(\master).fadeTime = 12;
    Ndef(\master).xset(\wet10, 0.3); // Establish subtle space

    Ndef(\terra).fadeTime = 30;
    Ndef(\terra).xset(\lpfFreq, 400); // Slowly open foundation

    45.wait; // Now at 0:45

    "0:45 - [Portugal to Brazil: The Journey Begins]".postln;
    Ndef(\terra).fadeTime = 25;
    Ndef(\terra).xset(\freqMult, 1.15); // Upward pitch shift migration

    Pbindef(\sementeSeq, \dur, Pseq([1.5, 0.75, 0.5], inf)); // Rhythmic complexity

    Ndef(\master).fadeTime = 10;
    Ndef(\master).xset(\wet11, 0.1); // Introduce stew diffusion

    Ndef(\terra).fadeTime = 10;
    Ndef(\terra).xset(\ampMod, 1.3);

    25.wait; // Now at 1:10

    "1:10 - [Movement II: O Encontro Brasileiro]".postln;
    Ndef(\carne).set(\ampMod, 0); // Initialize at 0 for fade
    Ndef(\carne)[1] = \set -> Pbindef(\carneSeq);

    Ndef(\carne).fadeTime = 15;
    Ndef(\carne).xset(\ampMod, 1); // Fade in meats

    Ndef(\terra).fadeTime = 20;
    Ndef(\terra).xset(\lpfFreqMult, 1.5); // Reveal high-frequency content

    40.wait; // Now at 1:50

    "1:50 - [Brazilian Accompaniments Emerge]".postln;
    Ndef(\fruta).set(\ampMod, 0);
    Ndef(\fruta)[1] = \set -> Pbindef(\frutaSeq);

    Ndef(\fruta).fadeTime = 10;
    Ndef(\fruta).xset(\ampMod, 1); // Fade in bright accompaniments

    Ndef(\semente).fadeTime = 5;
    Ndef(\semente).xset(\ampMod, 1.4); // Bring granular texture forward

    30.wait; // Now at 2:20

    "2:20 - [Movement III: Sabor e Lenda]".postln;
    Ndef(\vapor).set(\sweepMod, 1); // Enable internal slow LFO sweep
    Ndef(\vapor)[1] = \set -> Pbindef(\vaporSeq);

    Pbindef(\sementeSeq, \dur, Pseq([1.8, 0.3, 0.9, 2.2], inf)); // Hesitant rhythm

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\flavorMix, 0.8, \flavorBpfFreq, 350, \flavorRq, 0.3); // Thicken the stew

    // Fruta dips slightly then returns (questioning flicker)
    Ndef(\fruta).fadeTime = 5;
    Ndef(\fruta).xset(\ampMod, 0.5);
    Routine({
        5.wait;
        Ndef(\fruta).xset(\ampMod, 1.0);
    }).play;

    50.wait; // Now at 3:10

    "3:10 - [Myth Debunked / Clarification]".postln;
    Pbindef(\sementeSeq, \dur, Pseq([1.0, 0.5], inf)); // Stabilize rhythm

    Ndef(\vapor).fadeTime = 20;
    Ndef(\vapor).xset(\bpfFreqMult, 4.0); // Sweep up from 500Hz to 2000Hz to thin out

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\flavorMix, 0); // Flatten out the flavor filter

    Ndef(\carne).fadeTime = 10;
    Ndef(\carne).xset(\modIndex, 1.5); // Add richness/definition

    40.wait; // Now at 3:50

    "3:50 - [Movement IV: A Feijoada Completa]".postln;
    Ndef(\vapor).set(\sweepMod, 0); // Hand control back to Pbindef entirely
    Pbindef(\vaporSeq, \dur, Pwhite(0.1, 0.25), \bpfFreq, Pwhite(1500, 2500)); // Bubbling
    Ndef(\vapor).xset(\bpfFreqMult, 1); // Reset multiplier

    Ndef(\master).fadeTime = 10;
    Ndef(\master).xset(\wet10, 0.65, \verbDecay, 8); // Grand celebratory space

    Ndef(\master).fadeTime = 8;
    Ndef(\master).xset(\stewDecay, 0.8, \stewDelay, 0.7, \wet11, 0.4); // Lush blended sound

    40.wait; // Now at 4:30

    "4:30 - [Movement V: O Banquete Final]".postln;
    Pbindef(\sementeSeq, \dur, Pseq([3.0, 2.0], inf));
    Pbindef(\frutaSeq, \dur, Pseq([2.0, 3.0], inf));
    Pbindef(\vaporSeq, \dur, Pseq([1.5, 2.0], inf));

    // Lingering warmth swell
    Ndef(\terra).fadeTime = 12.5;
    Ndef(\terra).xset(\ampMod, 1.5);
    Routine({
        12.5.wait;
        Ndef(\terra).fadeTime = 12.5;
        Ndef(\terra).xset(\ampMod, 0.3);
    }).play;

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\verbDecay, 12); // Extending the resonance

    30.wait; // Now at 5:00

    "5:00 - [Fade Out & Terminate]".postln;
    Pbindef(\terraSeq).stop;
    Pbindef(\sementeSeq).stop;
    Pbindef(\carneSeq).stop;
    Pbindef(\frutaSeq).stop;
    Pbindef(\vaporSeq).stop;

    Ndef(\terra).clear(20);
    Ndef(\semente).clear(20);
    Ndef(\carne).clear(20);
    Ndef(\fruta).clear(20);
    Ndef(\vapor).clear(20);

    // Allow effects to decay naturally before clearing master
    Routine({
        20.wait;
        Ndef(\master).clear;
        "Score Complete.".postln;
    }).play;

});

// Launch GUI
s.makeGui;
)

// Source: composition-haideng.scd [Block 2]
// MODE: compose
// THEME: Slowly increase delay wetness to 40% over 15 seconds
// KEYWORDS: breathSeq, chanSeq, cloudSeq, compose, delay, emptyCloud, fingerChan, frailBreath, gverb, increase, over, seconds, slowly, wetness
(
Tdef(\theNeverSick, {

    "0:00 - [Movement I: Frailty & The World]".postln;
    Ndef(\frailBreath).play;
    Ndef(\frailBreath)[1] = \set -> Pbindef(\breathSeq);

    // Slowly increase delay wetness to 40% over 15 seconds
    Ndef(\frailBreath).fadeTime = 15;
    Ndef(\frailBreath).xset(\wet10, 0.4);

    45.wait; // Now at 0:45

    "0:45 - [Movement II: The Pivot]".postln;
    // Shorten duration to simulate a quickening pulse
    Pbindef(\breathSeq, \dur, Pwrand([0.5, 0.75, 1.0], [0.6, 0.3, 0.1], inf));

    Ndef(\fingerChan).play;
    Ndef(\fingerChan)[1] = \set -> Pbindef(\chanSeq);
    Ndef(\fingerChan).set(\amp, 0.1, \modIndex, 0.1);

    // Sweep modIndex from 0.1 to 1.5 over 30 seconds
    Ndef(\fingerChan).fadeTime = 30;
    Ndef(\fingerChan).xset(\modIndex, 1.5);

    45.wait; // Now at 1:30

    "1:30 - [Movement III: One-Finger Chan (Climax)]".postln;
    Pbindef(\breathSeq).stop;
    Ndef(\frailBreath).clear(4); // Fades out the youth motif

    // Hard set to brilliant, piercing metallic focus
    Ndef(\fingerChan).set(\modIndex, 5.0, \amp, 0.25);

    // Push GVerb wetness to 70% over 8 seconds
    Ndef(\fingerChan).fadeTime = 8;
    Ndef(\fingerChan).xset(\wet10, 0.7);

    30.wait; // Now at 2:00

    "2:00 - [The Weight of the Feat]".postln;
    // Slowly sweep freqMult to create excruciating upward harmonic tension
    Ndef(\fingerChan).fadeTime = 15;
    Ndef(\fingerChan).xset(\freqMult, 1.05);

    30.wait; // Now at 2:30

    "2:30 - [Movement IV: Empty Cloud (Resolution)]".postln;
    Ndef(\emptyCloud).play;
    Ndef(\emptyCloud)[1] = \set -> Pbindef(\cloudSeq);

    // Immediately drop modIndex to release physical tension, carve out low end
    Ndef(\fingerChan).fadeTime = 12;
    Ndef(\fingerChan).xset(\modIndex, 1.0, \hpfFreq, 800);

    // Raise the spiritual mist reverb to 80% wet over 12 seconds
    Ndef(\emptyCloud).fadeTime = 12;
    Ndef(\emptyCloud).xset(\wet11, 0.8);

    30.wait; // Now at 3:00

    "3:00 - [Qigong Harmony]".postln;
    // Sweep the pad's filter downward to muffle harmonics into a deep bodily vibration
    Ndef(\emptyCloud).fadeTime = 15;
    Ndef(\emptyCloud).xset(\lpfFreq, 400);

    15.wait; // Now at 3:15

    "3:15 - [Movement V: Dissolution & Terminate]".postln;
    Pbindef(\chanSeq).stop;
    Pbindef(\cloudSeq).stop;

    // Majestic, 15-second unsegmented fade into absolute silence
    Ndef(\fingerChan).clear(15);
    Ndef(\emptyCloud).clear(15);

    "Score Complete. The lineage remains.".postln;
});
)

// Source: composition-isleofthedead-5-works-inspired-by.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING
// KEYWORDS: biomechClick, bpf, bus, compose, darkWaters, fleshyArp, fold, freeverb2, gigerSeq, leadArp, masterMix, moogff, pre, rlpf, romanticSpectral, routing, safetyLimiter, setup, signalisPulse, sinosc, waveBass
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------

    // Biomechanical Intrusions: Atonal FM plucks
    SynthDef(\biomechClick, { |out=0, freq=2000, modFreq=3000, fmIndex=5, dec=0.01, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, dec), doneAction: 2);
        var mod = SinOsc.ar(modFreq) * fmIndex * env;
        var sig = SinOsc.ar(freq + mod);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // The Signalis Loop: Wave-folded bass
    SynthDef(\waveBass, { |out=0, freq=55, foldAmount=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.25), doneAction: 2);
        var sig = LFTri.ar(freq);
        // Intense wavefolding simulating a Shaper buffer overdrive
        sig = Fold.ar(sig * (1 + (foldAmount * 15)), -0.5, 0.5);
        sig = RLPF.ar(sig, freq * 6, 0.4);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // The Signalis Loop: Fleshy Arp
    SynthDef(\leadArp, { |out=0, freq=440, amp=0.1, pan=0, cutoff=2500|
        var env = EnvGen.ar(Env.perc(0.005, 0.15), doneAction: 2);
        var sig = Pulse.ar(freq, 0.3);
        sig = MoogFF.ar(sig, cutoff * env + 150, 1.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: The Oarsman (Granular Waters)
    Ndef(\darkWaters, {
        var dens = \grainDens.kr(20);
        var spread = \panSpread.kr(0.8);
        var trig = Dust.ar(dens);

        // Asymmetrical LFO to emulate uneven rowing and waves
        var asymLFO = LFSaw.kr(0.05, 1).range(0.2, 1.0) * SinOsc.kr(0.13).range(0.5, 1.0);
        var noise = WhiteNoise.ar * asymLFO;

        // Dark, viscous filtering
        var filt = BPF.ar(noise, LFNoise2.kr(0.2).exprange(150, 1000), 0.4);

        var sig = GrainIn.ar(2, trig, 0.25, filt, spread * TRand.kr(-1, 1, trig));
        sig * \amp.kr(0);
    });

    // Movement III: Romantic Despair (Modal Resonator Bank)
    Ndef(\romanticSpectral, {
        var detune = \detuneAmount.kr(0);
        var base = 41.2; // E1
        var degrees = [0, 1, 4, 5, 7, 8, 10]; // Phrygian Dominant cluster

        var sig = Mix.fill(50, { |i|
            var deg = degrees.wrapAt(i);
            var oct = i div: 7;
            var idealFreq = (base.cpsmidi + deg + (oct * 12)).midicps;

            // Chaos pushes the pure sines into microtonal dissonance
            var drift = LFNoise2.kr(0.05).range(1, 1 + (detune * 0.12));
            SinOsc.ar(idealFreq * drift) * (1 / (i + 1).sqrt);
        });

        // Heavy resonant low-pass filter
        sig = RLPF.ar(sig, 1200, 0.15);
        Pan2.ar(sig * \amp.kr(0) * 0.015, 0);
    });

    // Master JITLib Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\darkWaters, 2) + Ndef.ar(\romanticSpectral, 2);
        synths + continuous;
    });

    // FX Slot 10: Abyss Reverb (Massive, dark reverberation)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.98, damp: 0.85);
    };

    // FX Slot 20: Ruin Distortion (Kinetic sequence saturation)
    Ndef(\masterMix)[20] = \filter -> { |in|
        (in * 6).tanh * 0.6;
    };

    Ndef(\masterMix).set(\wet10, 0, \wet20, 0);
    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\avernusScore, {

        "0:00 - [Cue 1: The Oarsman (Brooding & Monolithic)]".postln;
        Ndef(\darkWaters).fadeTime = 5;
        Ndef(\darkWaters).set(\amp, 1.5);
        Ndef(\masterMix).set(\wet10, 0.3); // Slight reverb for the water

        // ACTIVE WAIT: 35 Seconds (Swell grain density unpredictably)
        7.do {
            Ndef(\darkWaters).xset(\grainDens, rrand(10.0, 60.0), \panSpread, rrand(0.3, 1.0));
            5.wait;
        };

        "0:35 - [Cue 2: Biomechanical Intrusions (Frantic & Metallic)]".postln;
        Pbindef(\gigerSeq,
            \instrument, \biomechClick,
            \out, ~synthBus,
            \dur, Pwhite(0.05, 0.35, inf),
            \freq, Pexprand(800, 5000, inf),
            \modFreq, Pkey(\freq) * Pwhite(0.5, 3.5, inf),
            \fmIndex, 5,
            \dec, 0.01,
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, 0.4
        ).play;

        // ACTIVE WAIT: 37 Seconds (Randomly spike fmIndex and shorten decay)
        12.do {
            Pbindef(\gigerSeq,
                \fmIndex, rrand(2.0, 18.0),
                \dec, rrand(0.002, 0.03)
            );
            3.wait;
        };
        1.wait;

        "1:12 - [Cue 3: Romantic Despair (Sweeping & Tragic)]".postln;
        // SPOTLIGHT RULE: HARD CONTRAST
        Pbindef(\gigerSeq).stop;
        Ndef(\darkWaters).set(\amp, 0); // Instant subtraction of waters

        Ndef(\romanticSpectral).set(\amp, 1, \detuneAmount, 0);
        Ndef(\masterMix).set(\wet10, 0.7); // Spike reverb wet mix

        // ACTIVE WAIT: 53 Seconds (Continuous xset sweep of detuneAmount into dissonance)
        53.do { |i|
            var progress = i / 53;
            Ndef(\romanticSpectral).set(\detuneAmount, progress * 4.5);
            1.wait;
        };

        "2:05 - [Cue 4: The Signalis Loop (Late-Stage Kinetic Euphoria)]".postln;
        // SPOTLIGHT RULE: INSTANT CLEARANCE
        Ndef(\romanticSpectral).clear;
        Ndef(\masterMix).set(\wet10, 0); // Reverb bypassed completely
        Ndef(\masterMix).set(\wet20, 1); // Ruin Distortion fully engaged

        // Aggressive wave-folded bass
        Pbindef(\signalisPulse,
            \instrument, \waveBass,
            \out, ~synthBus,
            \dur, 0.25,
            \freq, Pseq([41.2, 41.2, 46.25, 41.2], inf), // E1, F#1 rhythmic pedal
            \foldAmount, 0.2,
            \amp, 0.7
        ).play;

        // Frantic 16th-note Lydian Dominant sequence
        Pbindef(\fleshyArp,
            \instrument, \leadArp,
            \out, ~synthBus,
            \dur, 0.125,
            \freq, Pseq([0, 2, 4, 6, 7, 9, 10].midiratio * 164.81, inf) * Prand([1, 2], inf),
            \cutoff, Pexprand(800, 4000, inf),
            \pan, Pseq([-0.3, 0.3, -0.6, 0.6], inf),
            \amp, 0.3
        ).play;

        // ACTIVE WAIT: 50 Seconds (Automate aggression on the wavefolder)
        10.do {
            Pbindef(\signalisPulse, \foldAmount, rrand(0.2, 1.2));
            5.wait;
        };

        "2:55 - [Cue 5: The Isle Reclaimed (Abrupt Decrease & Long Fade)]".postln;
        // INSTANT TERMINATION OF KINETIC SEQUENCE
        Pbindef.removeAll;
        Ndef(\masterMix).set(\wet20, 0); // Distortion instantly off

        // RETURN TO POINT OF DEPARTURE
        Ndef(\darkWaters).set(\amp, 1.5, \grainDens, 15);
        Ndef(\masterMix).set(\wet10, 0.5); // Reverb back on for ghostly tail

        // 22-SECOND FADE OUT
        Ndef(\darkWaters).fadeTime = 22;
        Ndef(\masterMix).fadeTime = 22;

        Ndef(\darkWaters).xset(\amp, 0);
        Ndef(\masterMix).xset(\wet10, 0);

        // ACTIVE WAIT: 22 Seconds
        4.do {
            5.wait;
        };
        2.wait;

        "3:17 - [Termination: Absolute Silence]".postln;
        Ndef.clear;
        "Score Complete.".postln;
    });

    Tdef(\avernusScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead1.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING
// KEYWORDS: bellChimes, bpf, bus, coldPad, compose, cypressDrone, distantBell, dynklank, fold, freeverb2, glissandi, hpf, masterMix, memoryFlashes, mistyGrain, oarSeq, oarStroke, pre, rlpf, routing, safetyLimiter, setup, sharpPluck, spectralDistortion, windWhispers
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\distantBell, { |out=0, freq=400, decayTime=5, ringTime=4, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decayTime), doneAction: 2);
        var exc = PinkNoise.ar(0.1) * EnvGen.ar(Env.perc(0.001, 0.05));
        var freqs = [1, 2.3, 3.5, 4.7, 5.1] * freq;
        var amps = [1, 0.6, 0.4, 0.2, 0.1];
        var decays = [1, 0.8, 0.6, 0.4, 0.2] * ringTime;
        var sig = DynKlank.ar(`[freqs, amps, decays], exc);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\windWhispers, { |out=0, startFreq=400, endFreq=200, glissTime=5, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.linen(glissTime * 0.2, glissTime * 0.6, glissTime * 0.2), doneAction: 2);
        var freqEnv = XLine.kr(startFreq, endFreq, glissTime);
        var sig = Saw.ar(freqEnv) + Pulse.ar(freqEnv * 1.01, 0.5);
        sig = BPF.ar(sig, freqEnv * 1.5, 0.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\sharpPluck, { |out=0, freq=400, fmIndex=2, decay=0.05, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * 2.41) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\mistyGrain, { |grainDens=0.5, grainSize=0.1, hpFreq=5000, amp=0, panPos=0|
        var trigs = Dust.ar(grainDens);
        var sig = GrainIn.ar(2, trigs, grainSize, WhiteNoise.ar, panPos);
        sig = HPF.ar(sig, hpFreq);
        sig * amp;
    });

    Ndef(\coldPad, { |filterFreq=8000, q=0.2, detune=0.01, amp=0|
        var sig = Saw.ar([100, 100 * (1 + detune)]) + Pulse.ar([50, 50 * (1 - detune)], 0.5);
        sig = RLPF.ar(sig, filterFreq, q.max(0.01));
        sig * amp;
    });

    Ndef(\oarStroke, { |freq=40, index=2, q=0.1, decay=6, amp=0|
        var t_trig = \t_trig.tr(0);
        var env = EnvGen.ar(Env.perc(0.1, decay), t_trig);
        var mod = SinOsc.ar(freq * 1.41) * index * freq * env;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, freq * 4, q.max(0.01));
        Pan2.ar(sig * env * amp, 0);
    });

    Ndef(\cypressDrone, { |carrierFreq=80, modIndex=4.0, detuneAmount=0.02, modSpeed=0.1, amp=0|
        var lfoDetune = LFSaw.kr(modSpeed).range(0.5, 1.5) * detuneAmount;
        var lfoMod = SinOsc.kr(modSpeed * 0.7).range(0.8, 1.2) * modIndex;
        var mod = SinOsc.ar(carrierFreq * 2.01) * lfoMod * carrierFreq;
        var sig = SinOsc.ar(carrierFreq + mod + [0, lfoDetune * carrierFreq]);
        sig = sig + SinOsc.ar((carrierFreq * 0.5) + mod + [lfoDetune * carrierFreq, 0]);
        sig * amp;
    });

    Ndef(\spectralDistortion, { |chaosAmount=0.2, hpFreq=1000, foldAmount=0.5, amp=0|
        var chaos = chaosAmount.linlin(0, 1, 1.0, 1.99); // Safe range for Crackle
        var sig = Crackle.ar(chaos ! 2);
        sig = sig + (LFNoise1.ar(400 ! 2) * chaosAmount);
        sig = HPF.ar(sig, hpFreq.max(100));
        sig = Fold.ar(sig * (1 + (foldAmount * 5)), -0.5, 0.5);
        sig * amp;
    });

    // Master JITLib Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\mistyGrain, 2) +
                         Ndef.ar(\coldPad, 2) +
                         Ndef.ar(\oarStroke, 2) +
                         Ndef.ar(\cypressDrone, 2) +
                         Ndef.ar(\spectralDistortion, 2);
        synths + continuous;
    });

    // Reverb FX Slot
    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \verbWet.kr(0.4);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.8);
        XFade2.ar(in, verb, wet * 2 - 1);
    };
    Ndef(\masterMix).set(\verbWet, 0.4);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        // ==========================================================
        "0:00 - [Cue 1: The Approach (Misty Shores)]".postln;
        // ==========================================================
        Ndef(\mistyGrain).fadeTime = 0.1; Ndef(\mistyGrain).xset(\amp, 0.6);
        Ndef(\coldPad).fadeTime = 0.1; Ndef(\coldPad).xset(\amp, 0.5);

        // Long fading automations
        Ndef(\mistyGrain).fadeTime = 20; Ndef(\mistyGrain).xset(\grainDens, 3.0);
        Ndef(\mistyGrain).fadeTime = 30; Ndef(\mistyGrain).xset(\hpFreq, 2000);
        Ndef(\coldPad).fadeTime = 40; Ndef(\coldPad).xset(\filterFreq, 1500, \q, 0.6);
        Ndef(\masterMix).fadeTime = 10; Ndef(\masterMix).xset(\verbWet, 0.7);

        Pbindef(\bellChimes,
            \instrument, \distantBell,
            \out, ~synthBus,
            \dur, Pwhite(4.0, 8.0, inf),
            \freq, Pexprand(800, 2500, inf),
            \decayTime, 5,
            \ringTime, 4,
            \amp, 0.15
        ).play;

        // ACTIVE WAIT: 42.5 seconds (8 loops of ~5.3s)
        8.do {
            Ndef(\coldPad).xset(\detune, rrand(0.005, 0.02));
            Ndef(\mistyGrain).xset(\panPos, rrand(-0.3, 0.3));
            5.3125.wait;
        };

        // ==========================================================
        "0:42.5 - [Cue 2: The Ferryman's Oar (Solemn Passage)]".postln;
        // ==========================================================
        Ndef(\oarStroke).fadeTime = 0.1; Ndef(\oarStroke).xset(\amp, 0.8);

        Pbindef(\oarSeq,
            \type, \set,
            \id, Pfunc({ Ndef(\oarStroke).nodeID }),
            \args, #[\t_trig, \freq, \index, \decay],
            \t_trig, 1,
            \dur, Pwhite(2.0, 5.0, inf),
            \freq, Pwhite(38.0, 43.0, inf),
            \index, Pwhite(1.5, 2.5, inf),
            \decay, Pwhite(6.0, 8.0, inf)
        ).play;

        Ndef(\mistyGrain).fadeTime = 7.5; Ndef(\mistyGrain).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 30; Ndef(\coldPad).xset(\filterFreq, 2500);

        Pbindef(\bellChimes, \dur, Pwhite(6.0, 10.0, inf), \amp, 0.05);

        // ACTIVE WAIT: 45.5 seconds (7 loops of 6.5s)
        7.do {
            Ndef(\oarStroke).xset(\q, rrand(0.1, 0.3));
            6.5.wait;
        };

        // ==========================================================
        "1:28.0 - [Cue 3: Isle's Embrace (Cypress Shadows)]".postln;
        // ==========================================================
        Ndef(\cypressDrone).fadeTime = 10;
        Ndef(\cypressDrone).xset(\amp, 0.7, \carrierFreq, 80, \modIndex, 4.0);

        Ndef(\oarStroke).fadeTime = 12; Ndef(\oarStroke).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 20; Ndef(\coldPad).xset(\filterFreq, 800);
        Ndef(\masterMix).fadeTime = 5; Ndef(\masterMix).xset(\verbWet, 0.9);

        // Subtractive Arrangement: Fade out bells and stop oar sequence
        fork {
            12.do { |i|
                Pbindef(\bellChimes, \amp, 0.05 * (1 - (i/11)));
                1.wait;
            };
            Pbindef(\bellChimes).stop;
            Pbindef(\oarSeq).stop;
        };

        Pbindef(\glissandi,
            \instrument, \windWhispers,
            \out, ~synthBus,
            \dur, Pwhite(5.0, 12.0, inf),
            \startFreq, Pseq([Pwhite(400, 600, 1), Pwhite(200, 300, 1)], inf),
            \endFreq, Pseq([Pwhite(200, 300, 1), Pwhite(400, 600, 1)], inf),
            \glissTime, Pwhite(3.0, 8.0, inf),
            \amp, 0.15
        ).play;

        // ACTIVE WAIT: 52 seconds (8 loops of 6.5s)
        8.do {
            Ndef(\cypressDrone).xset(\detuneAmount, rrand(0.01, 0.04));
            6.5.wait;
        };

        // ==========================================================
        "2:20.0 - [Cue 4: Echoes of the Departed (Unsettling Memories)]".postln;
        // ==========================================================
        Ndef(\spectralDistortion).fadeTime = 5; Ndef(\spectralDistortion).xset(\amp, 0.35);
        Ndef(\spectralDistortion).fadeTime = 15; Ndef(\spectralDistortion).xset(\chaosAmount, 0.8);

        Pbindef(\memoryFlashes,
            \instrument, \sharpPluck,
            \out, ~synthBus,
            \dur, Pwhite(0.5, 2.5, inf),
            \midinote, Pshuf([60, 62, 65, 68, 70, 71, 74], inf),
            \fmIndex, Pwhite(2.0, 6.0, inf),
            \decay, 0.05,
            \amp, 0.12
        ).play;

        Ndef(\cypressDrone).fadeTime = 10;
        Ndef(\cypressDrone).xset(\modIndex, 6.0, \detuneAmount, 0.06);
        Ndef(\masterMix).fadeTime = 5; Ndef(\masterMix).xset(\verbWet, 0.6);

        // Subtractive Arrangement: Fade out glissandi
        fork {
            5.do { |i|
                Pbindef(\glissandi, \amp, 0.15 * (1 - (i/4)));
                1.wait;
            };
            Pbindef(\glissandi).stop;
        };

        // ACTIVE WAIT: 30 seconds (6 loops of 5s)
        6.do {
            Ndef(\spectralDistortion).xset(\foldAmount, rrand(0.2, 0.8));
            5.wait;
        };

        // ==========================================================
        "2:50.0 - [Cue 5: Return to Silence (Dissolution)]".postln;
        // ==========================================================
        Pbindef(\memoryFlashes).stop;

        Ndef(\spectralDistortion).fadeTime = 5; Ndef(\spectralDistortion).xset(\amp, 0.0);
        Ndef(\cypressDrone).fadeTime = 25; Ndef(\cypressDrone).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 25; Ndef(\coldPad).xset(\amp, 0.0);
        Ndef(\masterMix).fadeTime = 25; Ndef(\masterMix).xset(\verbWet, 0.0);

        // ACTIVE WAIT: 25 seconds (5 loops of 5s)
        5.do {
            5.wait;
        };

        "3:15.0 - [Final Clearing]".postln;
        Ndef.clear(2.0);
        2.wait;

        "3:17.0 - [End]".postln;
        Tdef.removeAll;
        Pbindef.removeAll;
        s.freeAll;
        "Score Complete. Server Silent.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead2.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & GROUPS
// KEYWORDS: bpf, bus, cliffResonance, coffinHum, compose, cypressGrove, darkWaterDrone, figureGlow, freeverb, freeverb2, groups, masterMix, oarStroke, pre, rlpf, rockEchoes, routing, rowingRhythm, safetyLimiter, saw, sepulchralKnock, setup, sinosc, spectralWhispers, whiteFigureSwell
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~sourceGroup = Group.new(s);
    ~fxGroup = Group.after(~sourceGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\oarStroke, { |out=0, freq=120, decay=1.0, pan=0, amp=0.8|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.03));
        // Physical modeling of a wet, wooden thud
        var sig = Pluck.ar(exc, exc, 0.2, freq.reciprocal.clip(0.0001, 0.2), decay, 0.4);
        sig = LPF.ar(sig, 800) + (BPF.ar(exc, 400, 0.5) * 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\cliffResonance, { |out=0, freq=800, fmIndex=5, ringTime=4, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.05, ringTime), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.4142) * fmIndex * env * freq;
        var sig = SinOsc.ar(freq + mod);
        // Dedicated subtle delay for the resonant echoes
        var del = CombC.ar(sig, 1.0, 0.33, 3.0);
        sig = (sig * 0.7) + (del * 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\sepulchralKnock, { |out=0, freq=400, attack=0.001, decay=0.4, brightness=0.8, amp=1|
        var env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);
        var exc = WhiteNoise.ar * env;
        var sig = Resonz.ar(exc, freq, 0.05) * 30;
        sig = sig + (LPF.ar(exc, freq * 3) * brightness);
        // Short, dry internal room reflection
        sig = FreeVerb.ar(sig, 0.3, 0.1, 0.9);
        Out.ar(out, Pan2.ar(sig * amp, 0));
    }).add;

    SynthDef(\whiteFigureSwell, { |out=0, freq=880, swellTime=5, filterCutoff=2000, brightness=0.5, amp=0.4, gate=1|
        var env = EnvGen.ar(Env.asr(swellTime, 1, swellTime + 2), gate, doneAction: 2);
        var sig = Splay.ar(Saw.ar(freq * [0.99, 1, 1.01, 2.005]));
        sig = RLPF.ar(sig, filterCutoff * (1 + (brightness * env)), 0.4);
        Out.ar(out, sig * env * amp);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\darkWaterDrone, {
        var lfo = SinOsc.kr(\lfoRate.kr(0.01)).exprange(\lfoMin.kr(80), \lfoMax.kr(150));
        var ampLfo = SinOsc.kr(0.05).range(0.8, 1.0);
        var sig = BrownNoise.ar(0.8) + Saw.ar([30, 30.2], 0.15);
        sig = RLPF.ar(sig, lfo, \q.kr(0.3));
        sig = RHPF.ar(sig, \hpFreq.kr(20).max(20), 0.5);
        sig * \amp.kr(0.6) * ampLfo;
    });

    Ndef(\cypressGrove, {
        var detune = \detuneAmount.kr(0.001);
        var dens = \density.kr(8);
        var spread = \pitchSpread.kr(0.02);
        var base = 110;
        var sig = Mix.fill(8, { |i|
            var freq = base * (1 + (i * spread)) * LFNoise2.kr(0.15).range(1-detune, 1+detune);
            SinOsc.ar(freq) * (1 / (i+1));
        });
        Splay.ar(sig) * \amp.kr(0.0); // Starts at 0, faded in later
    });

    Ndef(\spectralWhispers, {
        var sig = PinkNoise.ar(1);
        var dens = \grainDens.kr(5);
        var gSpread = \grainSpread.kr(0.8);
        var pShift = \pitchShift.kr(1.0);
        sig = BPF.ar(sig, \cutoff.kr(1200), 0.2);
        sig = PitchShift.ar(sig, 0.2, pShift, gSpread, dens/100);
        Pan2.ar(sig, LFNoise1.kr(0.1)) * \amp.kr(0.0); // Starts at 0
    });

    Ndef(\coffinHum, {
        var root = \rootFreq.kr(41.2); // E1
        var spread = \spread.kr(0.5);
        var sig = Mix.fill(3, { |i|
            SinOsc.ar(root + (i * spread)) + Pulse.ar(root * (i+1) + spread, 0.5, 0.05);
        });
        sig = LPF.ar(sig, 150);
        Splay.ar(sig) * \amp.kr(0.0); // Starts at 0
    });

    // Master Mixer: Sums discrete synths and continuous drones
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var drone = Ndef.ar(\darkWaterDrone, 2);
        var cypress = Ndef.ar(\cypressGrove, 2);
        var whispers = Ndef.ar(\spectralWhispers, 2);
        var coffin = Ndef.ar(\coffinHum, 2);
        synths + drone + cypress + whispers + coffin;
    });

    // Global Reverb Insert
    Ndef(\masterMix)[20] = \filter -> { |in|
        var wet = \wet20.kr(0.7);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: \revDecay.kr(0.9), damp: 0.1);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    Ndef(\masterMix).play(group: ~fxGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Somber Approach]".postln;
        Ndef(\darkWaterDrone).fadeTime = 5;
        Ndef(\darkWaterDrone).set(\amp, 0.7, \lfoMin, 80, \lfoMax, 150, \hpFreq, 20);
        Ndef(\masterMix).set(\wet20, 0.7, \revDecay, 0.85);

        Pbindef(\rowingRhythm,
            \instrument, \oarStroke,
            \out, ~synthBus,
            \dur, Pwhite(0.9, 1.1, inf) * 2.5, // ~40bpm, slightly irregular
            \freq, 90,
            \decay, 1.0,
            \amp, 0.6,
            \pan, Pseg([-0.6, 0.6, -0.6], [8, 8], \sine, inf) // Sweeping pan
        ).play;

        // Active Wait: 42 seconds (6 loops of 7s)
        6.do {
            // Micro-pacing: Subtle shifts in drone resonance
            Ndef(\darkWaterDrone).xset(\q, rrand(0.25, 0.4));
            7.wait;
        };

        "0:42 - [Cue 2: Islet's Imposing Form (SUBTRACTIVE CONTRAST)]".postln;
        Ndef(\cypressGrove).fadeTime = 5;
        Ndef(\cypressGrove).set(\amp, 0.5);
        Ndef(\darkWaterDrone).xset(\lfoMin, 150, \lfoMax, 300); // Sweep upwards
        Ndef(\cypressGrove).xset(\detuneAmount, 0.005); // Slowly detune

        Pbindef(\rowingRhythm).xset(\decay, 1.3); // Heavier, submerged strokes

        Pbindef(\rockEchoes,
            \instrument, \cliffResonance,
            \out, ~synthBus,
            \dur, Pseq([8, 12, 10, 9], inf), // Very sparse
            \freq, Pexprand(600, 1200, inf),
            \fmIndex, Pwhite(5.0, 10.0, inf),
            \ringTime, 6,
            \amp, 0.4,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 43 seconds (6 loops of 7.16s)
        6.do {
            // Micro-pacing: Evolving cypress density
            Ndef(\cypressGrove).xset(\pitchSpread, rrand(0.015, 0.03));
            7.16.wait;
        };

        "1:25 - [Cue 3: Sepulchral Echoes (SUBTRACTIVE ARRANGEMENT)]".postln;
        Ndef(\cypressGrove).fadeTime = 8;
        Ndef(\cypressGrove).xset(\amp, 0.15); // Subtraction for whispers

        Ndef(\darkWaterDrone).fadeTime = 15;
        Ndef(\darkWaterDrone).xset(\lfoMin, 100, \lfoMax, 180); // Sweep downwards

        Ndef(\spectralWhispers).fadeTime = 4;
        Ndef(\spectralWhispers).set(\amp, 0.6, \grainDens, 5, \grainSpread, 0.8);

        Pbindef(\rockEchoes, \dur, Pseq([5, 8, 7], inf)); // Slightly more frequent

        // Active Wait: 20 seconds until the Knock (4 loops of 5s)
        4.do {
            Ndef(\spectralWhispers).xset(\pitchShift, rrand(0.6, 1.4));
            5.wait;
        };

        "1:45 - [Cue 3.5: The Knock]".postln;
        Synth(\sepulchralKnock, [\out, ~synthBus, \freq, 450, \amp, 1.2]);
        Ndef(\masterMix).set(\wet20, 0.3); // Briefly dry for impact

        1.wait;
        Ndef(\masterMix).xset(\wet20, 0.7); // Return to wet
        4.wait;

        // Active Wait: Remaining 15 seconds of Cue 3
        3.do {
            Ndef(\spectralWhispers).xset(\pitchShift, rrand(0.6, 1.4));
            5.wait;
        };

        "2:05 - [Cue 4: The Threshold & Contemplation (SPOTLIGHT RULE)]".postln;
        Pbindef(\rowingRhythm).stop; // INSTANT SUBTRACTION

        Ndef(\darkWaterDrone).fadeTime = 10;
        Ndef(\darkWaterDrone).xset(\hpFreq, 100, \amp, 0.4); // High-pass and reduce

        Ndef(\coffinHum).fadeTime = 3;
        Ndef(\coffinHum).set(\amp, 0.7);

        Ndef(\spectralWhispers).fadeTime = 15;
        Ndef(\spectralWhispers).xset(\amp, 0.0); // Fade out whispers

        Ndef(\masterMix).xset(\revDecay, 0.95); // Lengthen reverb

        Pbindef(\figureGlow,
            \instrument, \whiteFigureSwell,
            \out, ~synthBus,
            \dur, 8,
            \legato, 1.1, // Overlapping pads
            \freq, Pseq([880, 932, 1046, 987], inf), // Ethereal slow melody
            \swellTime, 4,
            \filterCutoff, 1500,
            \amp, 0.5
        ).play;

        // Active Wait: 45 seconds (9 loops of 5s)
        9.do { |i|
            // Slowly increase brightness of the figure
            Pbindef(\figureGlow, \brightness, 0.2 + (i/9 * 0.8));
            5.wait;
        };

        "2:50 - [Cue 5: Dissolution into Afterlife (LONG FADE TO SILENCE)]".postln;
        Pbindef(\figureGlow).stop;
        Pbindef(\rockEchoes).stop;

        // Initiate long clears
        Ndef(\darkWaterDrone).clear(25);
        Ndef(\cypressGrove).clear(20);
        Ndef(\coffinHum).clear(22);

        // Fade out the master mix effects and volume
        Ndef(\masterMix).fadeTime = 27;
        Ndef(\masterMix).xset(\wet20, 1.0, \revDecay, 0.99); // Wash out completely before death

        // Active Wait: 27 seconds for the fade
        5.do {
            5.4.wait;
        };

        "3:17 - [Termination]".postln;
        Pbindef.removeAll;
        Ndef.clear;
        Tdef.removeAll;
        "Score Complete. Silence.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead3.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS & BUFFER ALLOCATION
// KEYWORDS: allocation, bpf, buffer, bus, coffinSeq, compose, fold, freeverb2, hermitageGranular, hpf, lifeBell, lifeSeq, masterMix, pre, rlpf, ruinFold, safetyLimiter, setup, sinosc, spectralGrief, woodStrike
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ALLOCATION
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~granBuf = Buffer.alloc(s, s.sampleRate * 2, 1);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\woodStrike, { |out=0, freq=100, strikeForce=0.5, decayTime=1.0, pan=0, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.001, decayTime), doneAction: 2);
        var exciter = PinkNoise.ar(strikeForce) * EnvGen.ar(Env.perc(0.001, 0.05));
        var sig = Klank.ar(`[
            [freq, freq*1.5, freq*2.3, freq*3.8, freq*5.1],
            [1, 0.6, 0.4, 0.2, 0.1],
            [1, 0.8, 0.6, 0.4, 0.2]
        ], exciter, decayscale: decayTime);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\lifeBell, { |out=0, freq=440, fmRatio=2.1, fmIndex=2, decayTime=2.0, pan=0, amp=0.2|
        var env = EnvGen.ar(Env.perc(0.005, decayTime), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\spectralGrief, { |cutoff=40, hpFreq=10, pmIndex=1, amp=0|
        var mod = SinOsc.ar([50.2, 49.8]) * pmIndex * 100;
        var sig = SinOsc.ar([50, 51] + mod);
        sig = BPF.ar(sig, cutoff, 0.2) * 5;
        sig = HPF.ar(sig, hpFreq);
        sig * amp;
    });

    Ndef(\ruinFold, { |foldAmount=1, amp=0|
        var sig = LFSaw.ar([40, 41] + LFNoise1.kr(2).range(-5, 5));
        sig = Fold.ar(sig * foldAmount, -0.1, 0.1) * 10;
        sig = RLPF.ar(sig, LFNoise1.kr(0.5).exprange(100, 4000), 0.3);
        (sig * amp).tanh;
    });

    Ndef(\hermitageGranular, { |grainDens=10, amp=0|
        var in = Mix(In.ar(~synthBus, 2));
        var rec = RecordBuf.ar(in, ~granBuf, loop: 1);
        var trigs = Dust.ar(grainDens);
        var dur = TRand.ar(0.05, 0.3, trigs);
        var pos = (Phasor.ar(0, BufRateScale.kr(~granBuf), 0, BufFrames.kr(~granBuf)) / BufSampleRate.kr(~granBuf)) - TRand.ar(0.05, 1.5, trigs);
        var sig = TGrains.ar(2, trigs, ~granBuf, TRand.ar(0.5, 2.0, trigs), pos, dur, TRand.ar(-1, 1, trigs), 0.5, 2);
        sig * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\spectralGrief, 2) + Ndef.ar(\ruinFold, 2) + Ndef.ar(\hermitageGranular, 2);
        synths + continuous;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \wet10.kr(1.0);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.1);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    // Initialize parameters
    Ndef(\masterMix).set(\wet10, 1.0);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The English Cemetery (Grief & Conception)]".postln;
        Ndef(\masterMix).set(\wet10, 1.0);
        Ndef(\spectralGrief).set(\amp, 0.8, \cutoff, 40);

        // ACTIVE WAIT STATE: Sweep drone cutoff over 35 seconds
        35.do { |i|
            var targetCutoff = 40 * exp(i/34 * log(10)); // Sweeps 40 to ~400 logarithmically
            Ndef(\spectralGrief).xset(\cutoff, targetCutoff);
            1.wait;
        };

        "0:35 - [Cue 2: The Coffin (Rhythmic Awakening)]".postln;
        Pbindef(\coffinSeq,
            \instrument, \woodStrike,
            \out, ~synthBus,
            \dur, Pseq([1, 1, 0.5, 1.5, 2], inf),
            \freq, Pwhite(80, 120, inf),
            \pan, Pwhite(-0.4, 0.4, inf),
            \amp, 0.6
        ).play;

        // ACTIVE WAIT STATE: Mutate the wood strikes over 33 seconds
        33.do { |i|
            var prog = i/32;
            Pbindef(\coffinSeq,
                \strikeForce, 0.1 + (prog * 0.9),
                \decayTime, 1.5 - (prog * 1.3)
            );
            1.wait;
        };

        "1:08 - [Cue 3: Proliferation & Ruin]".postln;
        Pbindef(\coffinSeq).stop; // INSTANT SUBTRACTION
        Ndef(\spectralGrief).fadeTime = 2;
        Ndef(\spectralGrief).xset(\hpFreq, 150); // Make room for distortion low-end
        Ndef(\ruinFold).set(\foldAmount, 1, \amp, 0.5);

        // ACTIVE WAIT STATE: Drive wave-folder to maximum over 34 seconds
        34.do { |i|
            Ndef(\ruinFold).xset(\foldAmount, 1 + (i/33 * 49));
            1.wait;
        };

        "1:42 - [Cue 4: Isle of Life (Abrupt Decrease in Complexity)]".postln;
        // FORM OPERATION C: HARD CUT
        Ndef(\ruinFold).clear;
        Ndef(\spectralGrief).clear;
        Ndef(\masterMix).set(\wet10, 0.2); // Instant dry shift

        Pbindef(\lifeSeq,
            \instrument, \lifeBell,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \octave, Pseq([5, 6, 4, 5], inf),
            \degree, Pseq([0, 2, 4, 6, 7, 4, 2, 0] ++ [0, 4, 2, 7, 6, 2, 4, 1], inf),
            \dur, Pseq([0.125, 0.125, 0.25], inf),
            \fmRatio, Pwhite(1.5, 4.5, inf),
            \fmIndex, Pwhite(1.0, 3.0, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, 0.35
        ).play;

        // ACTIVE WAIT STATE: Euphoric polyrhythms hold the space for 43 seconds
        43.do {
            // Micro-gestures to keep the FM texture alive
            Pbindef(\lifeSeq, \fmIndex, rrand(1.0, 4.0));
            1.wait;
        };

        "2:25 - [Cue 5: The Carlo Echo (Late-Stage Kinetic Energy)]".postln;
        Ndef(\hermitageGranular).set(\amp, 1.0, \grainDens, 10);
        Ndef(\masterMix).fadeTime = 2;
        Ndef(\masterMix).xset(\wet10, 0.8); // Reverb swells back up

        // ACTIVE WAIT STATE: Granular storm consumes the bells over 30 seconds
        30.do { |i|
            Ndef(\hermitageGranular).xset(\grainDens, 10 + (i/29 * 190));
            1.wait;
        };

        "2:55 - [Cue 6: The Long Fade (Explicit Termination)]".postln;
        Pbindef.removeAll; // Stop generating new discrete events immediately
        Ndef.clear(22);    // 22-second fade out on all continuous textures

        // ACTIVE WAIT STATE: Explicitly holding the thread open for the fade
        22.do {
            1.wait;
        };

        "3:17 - Server silent. Piece concludes.".postln;
        Tdef.removeAll;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-paodequeijo.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, compose, delayTexture, eggPluck, eggSequence, first, fold, fornoHum, freeverb2, hpf, leiteOleoDrone, limiter, master, mixAmp, mixRhythm, mixThud, persistent, polvilhoAmbience, queijoTexture, rlpf, rollAmp, rollRhythm, rollingTap, safety, safetyLimiter, salCrack, saltShot, sinosc
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

    ServerTree.removeAll;
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
        Pbindef.removeAll;

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
        Ndef.clear(5);
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    s.makeGui;

});
)

// Source: composition-paodequeijo2.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: boilingLiquids, bpf, canastraSeq, cheesePluck, compose, doughDrone, first, fold, freeverb2, hpf, limiter, master, masterMix, oiledGlide, ovenHeat, persistent, polvilhoDust, rollSeq, safety, safetyLimiter, scaldBurst, sinosc, whitenoise
(
s.waitForBoot({
    var masterScore;

    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // =====================================================================
    // 1. INSTRUMENTS & SYNTHS
    // =====================================================================

    SynthDef(\scaldBurst, { |out=0, amp=1|
        var env, noise, sig;
        env = EnvGen.ar(Env.perc(0.001, 3.0, 1, -8), doneAction: 2);
        noise = WhiteNoise.ar();
        sig = Fold.ar(noise * 2, -0.5, 0.5) * env;
        sig = BPF.ar(sig, XLine.kr(8000, 400, 3.0), 0.5);
        Out.ar(out, Pan2.ar(sig * amp, 0));
    }).add;

    SynthDef(\cheesePluck, { |out=0, freq=440, amp=0.1, pan=0, t_trig=1|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.005, 0.3), t_trig, doneAction: 2);
        mod = SinOsc.ar(freq * 3.02) * 1.5 * freq * env;
        sig = SinOsc.ar(freq + mod) * env;
        sig = HPF.ar(sig, 800);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\oiledGlide, { |out=0, freq=880, amp=0.1, pan=0, gate=1, glideTime=0.5|
        var smoothFreq, env, sig;
        smoothFreq = VarLag.kr(freq, glideTime, warp: \sine);
        env = EnvGen.ar(Env.asr(0.1, 1, 1.5), gate, doneAction: 2);
        sig = SinOsc.ar(smoothFreq);
        Out.ar(out, Pan2.ar(sig * amp * env, pan));
    }).add;

    s.sync;

    // =====================================================================
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // =====================================================================

    Ndef(\polvilhoDust, { |grainDens=2, grainDur=0.01, freqMult=1, amp=0|
        var trigs, env, freqs, sig;
        trigs = Dust.ar(grainDens);
        env = Decay2.ar(trigs, 0.001, grainDur);
        freqs = TExpRand.ar(2000, 9000, trigs) * freqMult;
        sig = SinOsc.ar(freqs) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.8, 0.8, trigs));
    });

    Ndef(\boilingLiquids, { |bubbleFreq=5, chaosParam=0.1, amp=0|
        var trigs, env, pitchEnv, freqs, mod, sig;
        trigs = Dust.ar(bubbleFreq);
        env = EnvGen.ar(Env.perc(0.01, 0.1), trigs);
        pitchEnv = EnvGen.ar(Env([1, 2, 1], [0.01, 0.05], \exp), trigs);
        freqs = TExpRand.ar(100, 800, trigs) * pitchEnv;
        mod = SinOsc.ar(freqs * 1.414) * chaosParam * freqs;
        sig = SinOsc.ar(freqs + mod) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.5, 0.5, trigs));
    });

    Ndef(\doughDrone, { |cutoff=400, viscosity=0.1, amp=0|
        var freq, mod, sig;
        freq = 55;
        mod = SinOsc.ar(freq * 2.01) * viscosity * freq;
        sig = SinOsc.ar([freq, freq * 1.01] + mod);
        sig = LPF.ar(sig, cutoff);
        sig * amp;
    });

    Ndef(\ovenHeat, { |amp=0, spread=0.1, brightness=0.1|
        var root, ratios, freqs, sig;
        root = 110;
        ratios = [1, 5/4, 3/2, 15/8, 9/8 * 2, 11/8 * 2];
        freqs = root * ratios;
        sig = freqs.collect { |f, i|
            var detune = SinOsc.kr(0.1 + (i*0.03)).range(0.998, 1.002);
            SinOsc.ar(f * detune) * (1 / (i + 1)**(1-brightness));
        };
        sig = Splay.ar(sig, spread);
        sig = BPeakEQ.ar(sig, 400, 1.0, brightness * -12);
        sig * amp;
    });

    Ndef(\masterMix, {
        var synths, sig;
        synths = In.ar(~synthBus, 2);
        sig = Ndef.ar(\polvilhoDust, 2) +
              Ndef.ar(\boilingLiquids, 2) +
              Ndef.ar(\doughDrone, 2) +
              Ndef.ar(\ovenHeat, 2) +
              synths;
        sig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var revTime, damp;
        revTime = \revTime.kr(0.2);
        damp = \damp.kr(0.5);
        FreeVerb2.ar(in[0], in[1], mix: 1, room: revTime, damp: damp);
    };
    Ndef(\masterMix).set(\wet10, 0.2);

    Ndef(\masterMix)[20] = \filter -> { |in|
        var drive;
        drive = \drive.kr(1.5);
        (in * drive).softclip;
    };
    Ndef(\masterMix).set(\wet20, 0);

    Ndef(\masterMix).play;

    s.sync;

    // =====================================================================
    // 3. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {
        "0:00 - [Cue 1: The Dry Ingredients]".postln;
        Ndef(\polvilhoDust).fadeTime = 17;
        Ndef(\polvilhoDust).xset(\grainDens, 50, \amp, 0.6);

        17.wait;

        "0:17 - [Cue 2: Liquids in the Pan]".postln;
        Ndef(\boilingLiquids).fadeTime = 8;
        Ndef(\boilingLiquids).xset(\amp, 0.4);

        8.wait;

        "0:25 - [Cue 3: The Boil]".postln;
        Ndef(\boilingLiquids).fadeTime = 18;
        Ndef(\boilingLiquids).xset(\bubbleFreq, 40, \chaosParam, 2.0);

        18.wait;

        "0:43 - [Cue 4: The Scald (Escaldar)]".postln;
        Ndef(\boilingLiquids).set(\amp, 0);
        Synth(\scaldBurst, [\out, ~synthBus, \amp, 1.5]);

        3.wait;

        "0:46 - [Cue 5: Crumbling the Lumps (Desencaroçar)]".postln;
        Ndef(\polvilhoDust).fadeTime = 21;
        Ndef(\polvilhoDust).xset(\grainDur, 0.5, \freqMult, 0.3, \grainDens, 15);

        21.wait;

        "1:07 - [Cue 6: Kneading & Eggs]".postln;
        Ndef(\polvilhoDust).fadeTime = 5;
        Ndef(\polvilhoDust).xset(\amp, 0);

        Ndef(\doughDrone).fadeTime = 28;
        Ndef(\doughDrone).xset(\amp, 0.5, \cutoff, 1500, \viscosity, 1.5);

        28.wait;

        "1:35 - [Cue 7: The Canastra Cheese]".postln;
        Pbindef(\canastraSeq,
            \instrument, \cheesePluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \degree, Pseq([0, 2, 4, 6, 7, 4, 6, 2], inf) + Pwrand([0, 7, 14], [0.6, 0.3, 0.1], inf),
            \dur, Pexprand(0.1, 0.3, inf),
            \amp, 0.2,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        15.wait;

        "1:50 - [Cue 8: Oiled Hands (Enrolar)]".postln;
        Ndef(\doughDrone).fadeTime = 3;
        Ndef(\doughDrone).xset(\amp, 0);
        Pbindef(\canastraSeq).stop;

        Pbindef(\rollSeq,
            \instrument, \oiledGlide,
            \out, ~synthBus,
            \scale, Scale.major,
            \degree, Pseq([0, 4, 2, 5, 3, 7], inf),
            \octave, 6,
            \dur, 0.6,
            \glideTime, 0.6,
            \legato, 1.01,
            \amp, 0.15,
            \pan, Pseq([-0.5, 0.5, -0.3, 0.3], inf)
        ).play;

        15.wait;

        "2:05 - [Cue 9: The Oven (Baking & Expanding)]".postln;
        Pbindef(\rollSeq).stop;

        Ndef(\ovenHeat).fadeTime = 30;
        Ndef(\ovenHeat).xset(\amp, 0.6, \spread, 0.8, \brightness, 0.9);

        Ndef(\masterMix).fadeTime = 30;
        Ndef(\masterMix).xset(\wet20, 0.4, \revTime, 0.95);

        35.wait;

        "2:40 - [Cue 10: Golden Crust & Resolution]".postln;
        Ndef(\ovenHeat).fadeTime = 20;
        Ndef(\ovenHeat).xset(\amp, 0);
        Ndef(\masterMix).fadeTime = 20;
        Ndef(\masterMix).xset(\wet20, 0, \revTime, 0.2);

        18.wait;

        "2:58 - [Cue 11: Total Clearance]".postln;
        Pbindef.removeAll;
        Ndef.clear(2);

        2.wait;

        "3:00 - [End]".postln;
        Tdef.removeAll;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-paodequeijo3.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & GROUPS
// KEYWORDS: boilGranular, bpf, bus, canastraChords, compose, crumbleClick, crumbleSeq, fold, freeverb2, groups, heatReverb, kneadBass, masterGlue, masterMix, milkSplash, ovenArp, ovenPluck, pre, ringz, rlpf, routing, safetyLimiter, saw, scaldHiss, setup, squelchBass
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------

    // Movement II: The Scald
    SynthDef(\scaldHiss, { |out=0, amp=1|
        var env = EnvGen.ar(Env.perc(0.01, 2.5, 1, -6), doneAction: 2);
        var sig = WhiteNoise.ar;
        sig = BPF.ar(sig, XLine.kr(9000, 1500, 2.5), 0.15);
        Out.ar(out, Pan2.ar(sig * env * amp * 8, 0));
    }).add;

    // Movement II: Dry physical modeling impulses
    SynthDef(\crumbleClick, { |out=0, freq=2000, decayTime=0.1, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decayTime + 0.02), doneAction: 2);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.005));
        var sig = Ringz.ar(exciter, freq, decayTime);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Movement III: Wave-folded subtractive bass
    SynthDef(\squelchBass, { |out=0, freq=55, foldAmount=2, amp=0.6|
        var env = EnvGen.ar(Env.perc(0.02, 0.4), doneAction: 2);
        var fEnv = EnvGen.ar(Env.perc(0.01, 0.25));
        var sig = SinOsc.ar(freq);
        sig = Fold.ar(sig * foldAmount, -0.5, 0.5);
        sig = RLPF.ar(sig, freq + (fEnv * 2000), 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    // Movement V: Bright Lydian Plucks
    SynthDef(\ovenPluck, { |out=0, freq=440, cutoff=3000, pan=0, amp=0.3|
        var env = EnvGen.ar(Env.perc(0.01, 0.3), doneAction: 2);
        var sig = Pulse.ar(freq, 0.5) + Saw.ar(freq * 1.005);
        sig = RLPF.ar(sig, cutoff, 0.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: The Boil
    Ndef(\boilGranular, { |grainDens=5, fmIndex=1, amp=0.6|
        var trigs = Dust.ar(grainDens);
        var carFreq = LFNoise1.kr(2).exprange(200, 600);
        var modFreq = carFreq * 1.414; // Tritone-ish modulation
        var sig = GrainFM.ar(2, trigs, 0.1, carFreq, modFreq, fmIndex, LFNoise1.kr(1));
        sig * amp;
    });

    // Movement III: Liquid splashes
    Ndef(\milkSplash, { |amp=0.4|
        var trigs = Dust.kr(0.8);
        var env = EnvGen.kr(Env.perc(0.005, 0.2), trigs);
        var freq = TRand.kr(1500, 4000, trigs);
        var mod = SinOsc.ar(freq * 2.5) * TRand.kr(1, 5, trigs) * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        Pan2.ar(sig * amp, TRand.kr(-0.6, 0.6, trigs));
    });

    // Movement IV: The Canastra Fold (PM Pad)
    Ndef(\canastraChords, { |amp=0.4, modIndex=1.5|
        var freqs = [261.63, 329.63, 392.00, 493.88]; // Cmaj7 Cluster
        var modFreqs = freqs * [1.059, 1.414, 1.059, 1.414]; // Min 2nd & Tritone ratios
        var sig = PMOsc.ar(freqs, modFreqs, SinOsc.kr(0.1).range(1, modIndex));
        sig = Splay.ar(sig);
        sig = LPF.ar(sig, 3000);
        sig * amp;
    });

    // Master Mixing & FX Chain
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\boilGranular, 2) + Ndef.ar(\milkSplash, 2) + Ndef.ar(\canastraChords, 2);
        synths + continuous;
    });

    Ndef(\heatReverb, { |revWet=0.1|
        var in = Ndef.ar(\masterMix, 2);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.4);
        XFade2.ar(in, verb, revWet * 2 - 1);
    });

    Ndef(\masterGlue, {
        var in = Ndef.ar(\heatReverb, 2);
        // Compander acts as master bus glue
        var comp = Compander.ar(in, in, thresh: 0.4, slopeBelow: 1, slopeAbove: 0.3, clampTime: 0.01, relaxTime: 0.1);
        comp * 1.5;
    });

    Ndef(\masterGlue).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Boil (Anticipation & Heat)]".postln;
        Ndef(\boilGranular).fadeTime = 3;
        Ndef(\boilGranular).xset(\grainDens, 5, \fmIndex, 1);

        // ACTIVE WAIT: Sweeping density and FM index over 25 seconds
        25.do { |i|
            Ndef(\boilGranular).xset(
                \grainDens, 5 + (i * 4.6),
                \fmIndex, 1 + (i * 0.2)
            );
            1.wait;
        };

        "0:25 - [Cue 2: The Scald & Crumble (HARD CONTRAST)]".postln;
        // INSTANT SUBTRACTION
        Ndef(\boilGranular).stop;
        Ndef(\boilGranular).clear;

        // The Scald Impact
        Synth(\scaldHiss, [\out, ~synthBus, \amp, 1.2]);

        // The Crumble
        Pbindef(\crumbleSeq,
            \instrument, \crumbleClick,
            \out, ~synthBus,
            \dur, Pwhite(0.03125, 0.125, inf),
            \freq, Pexprand(1500, 9000, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \decayTime, 0.1,
            \amp, 0.25
        ).play;

        // ACTIVE WAIT: Shrinking decay time to simulate lumps dissolving over 30 seconds
        30.do { |i|
            Pbindef(\crumbleSeq, \decayTime, 0.1 - (i * 0.0031));
            1.wait;
        };

        "0:55 - [Cue 3: The Knead (Viscous Rhythm)]".postln;
        Pbindef(\kneadBass,
            \instrument, \squelchBass,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
            \midinote, Pseq([36, 36, 48, 36, 34], inf),
            \foldAmount, 2.0,
            \amp, 0.7
        ).play;

        // ACTIVE WAIT: Modulate dough stickiness (foldAmount) while milk splashes
        40.do {
            Pbindef(\kneadBass, \foldAmount, rrand(1.5, 4.5));
            1.wait;
        };

        "1:35 - [Cue 4: The Canastra Fold (Pungent Harmonics)]".postln;
        Ndef(\canastraChords).fadeTime = 8;
        Ndef(\canastraChords).xset(\amp, 0.5);
        Ndef(\heatReverb).xset(\revWet, 0.6); // Expanding the space

        // ACTIVE WAIT: Sweeping PM index for sharp flavor profile
        6.do {
            Ndef(\canastraChords).xset(\modIndex, rrand(1.5, 4.0));
            5.wait;
        };

        "2:05 - [Cue 5: The Oven (LATE-STAGE CLIMAX)]".postln;
        // SUBTRACTION & INJECTION
        Pbindef(\kneadBass).stop;
        Pbindef(\crumbleSeq).stop;

        Pbindef(\ovenArp,
            \instrument, \ovenPluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \degree, Pseq([0, 2, 4, 6, 7, 9, 11, 13], inf),
            \octave, Pseq([4, 5, 6, 7], inf),
            \dur, 0.125,
            \cutoff, 3000,
            \pan, 0,
            \amp, 0.4
        ).play;

        // ACTIVE WAIT: Frantic expansion over 35 seconds
        35.do {
            Pbindef(\ovenArp,
                \cutoff, rrand(2000, 8000),
                \pan, rrand(-0.8, 0.8)
            );
            1.wait;
        };

        "2:40 - [Cue 6: The Golden Crust (RESOLUTION & FADE)]".postln;
        Pbindef.removeAll; // Stop all rhythmic sequences immediately

        // 20-second fade out for all continuous textures and reverb
        Ndef(\canastraChords).clear(20);
        Ndef(\milkSplash).clear(20);
        Ndef(\heatReverb).clear(20);
        Ndef(\masterGlue).clear(20);

        20.wait;

        "3:00 - [Cue 7: Silence]".postln;
        Tdef.removeAll;
        "Piece concludes.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-plummage.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS & BUFFER ALLOCATION
// KEYWORDS: allocation, buffer, bus, compose, delicateWeave, dynklank, eclipsePad, featherPluck, flightEfficiency, formant, freeverb2, hpf, intricateRhythm, intricateRhythm_2, masterMix, moltDrone, plumologyPing, plumologySeq, pre, rlpf, safetyLimiter, saw, setup, spectralDegrade, spectralPlume
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ALLOCATION
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    // Allocate buffer for delicateWeave granular synthesis
    ~grainBuf = Buffer.alloc(s, s.sampleRate * 0.5, 1);
    s.sync;
    // Fill with a complex sine/fm burst for delicate textures
    ~grainBuf.loadCollection(Signal.sineFill(s.sampleRate * 0.5, [1, 0.5, 0.25, 0.125], [0, 0.5pi, pi, 1.5pi]).asArray);

    // Pre-allocate permanent global buffers for FFT to avoid LocalBuf JITLib race conditions
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);
    ~fftModL = Buffer.alloc(s, 2048);
    ~fftModR = Buffer.alloc(s, 2048);
    ~fftDegBufL = Buffer.alloc(s, 2048);
    ~fftDegBufR = Buffer.alloc(s, 2048);

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\featherPluck, { |out=0, freq=440, fmRatio=2.1, fmIndex=1.5, sustain=0.1, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, sustain, curve: -4), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        // High-pass to keep it delicate and percussive
        sig = HPF.ar(sig, 400);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\plumologyPing, { |out=0, freq=880, decay=4, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay, curve: -2), doneAction: 2);
        var sig = SinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Granular synthesis texture
    Ndef(\delicateWeave, { |density=10, rate=1, posSpeed=1, dur=0.1, amp=0|
        var trigs = Dust.ar(density);
        var pos = LFNoise2.kr(posSpeed).range(0.1, 0.9);
        var sig = TGrains.ar(2, trigs, ~grainBuf, rate, pos * BufDur.ir(~grainBuf), dur, TRand.kr(-0.8, 0.8, trigs), 0.5);
        sig = HPF.ar(sig, 1500) * amp;
        sig;
    });

    // Real-time spectral processing
    Ndef(\spectralPlume, { |modFreq=150, phaseShift=0, amp=0|
        var sig = PinkNoise.ar(1!2);
        var mod = SinOsc.ar(modFreq);
        var chainL = FFT(~fftBufL, sig[0]);
        var chainR = FFT(~fftBufR, sig[1]);
        var mChainL = FFT(~fftModL, mod);
        var mChainR = FFT(~fftModR, mod);

        chainL = PV_MagMul(chainL, mChainL);
        chainR = PV_MagMul(chainR, mChainR);
        chainL = PV_PhaseShift(chainL, phaseShift);
        chainR = PV_PhaseShift(chainR, phaseShift + 0.1);

        IFFT([chainL, chainR]) * amp;
    });

    // Slowly morphing drone
    Ndef(\moltDrone, { |fundFreq=40, formFreq=300, bwFreq=100, amp=0|
        var sig = Formant.ar(fundFreq + LFNoise2.kr(0.5, 2), formFreq, bwFreq);
        sig = LPF.ar(sig, formFreq * 2);
        Pan2.ar(sig * amp, 0);
    });

    // Dark, evolving pad
    Ndef(\eclipsePad, { |freq=60, cutoff=2000, modRate=0.5, rq=0.4, amp=0|
        var sig = Saw.ar([freq, freq*1.015]) + Pulse.ar([freq*0.5, freq*0.505], 0.5);
        var mod = LFPulse.kr(modRate).range(0.3, 1.0);
        sig = RLPF.ar(sig, cutoff * mod, rq);
        sig * amp;
    });

    // Smooth, sustained glissing texture
    Ndef(\flightEfficiency, { |baseFreq=200, decay=2, amp=0|
        var freqs = baseFreq * [1, 1.52, 2.33, 3.81];
        var amps = [1, 0.6, 0.3, 0.1];
        var rings = decay * [1, 0.8, 0.6, 0.4];
        var sig = DynKlank.ar(Ref([freqs, amps, rings]), PinkNoise.ar(0.005!2));
        sig * amp;
    });

    // Targeted FFT-based spectral degradation
    Ndef(\spectralDegrade, { |dMolt=0, dFlight=0, randComb=0.1, magDiv=1, amp=1|
        var in = (Ndef.ar(\moltDrone) * dMolt) + (Ndef.ar(\flightEfficiency) * dFlight);
        var chainL = FFT(~fftDegBufL, in[0]);
        var chainR = FFT(~fftDegBufR, in[1]);

        // Wipe a percentage of bins
        chainL = PV_RandComb(chainL, randComb, Impulse.kr(0.5));
        chainR = PV_RandComb(chainR, randComb, Impulse.kr(0.5));

        IFFT([chainL, chainR]) * amp;
    });

    // Master Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\delicateWeave) +
                         Ndef.ar(\spectralPlume) +
                         Ndef.ar(\moltDrone) +
                         Ndef.ar(\eclipsePad) +
                         Ndef.ar(\flightEfficiency) +
                         Ndef.ar(\spectralDegrade);
        synths + continuous;
    });

    // Global Reverb via JITLib filter slot
    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.85, damp: 0.3);
        verb;
    };
    Ndef(\masterMix).set(\wet10, 0.15); // Start with low reverb
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\plumageScore, {
        "0:00 - [Cue 1: Initial Glimmer]".postln;
        0.5.wait;
        Ndef(\delicateWeave).fadeTime = 0.8;
        Ndef(\delicateWeave).xset(\amp, 0.4, \density, 15, \rate, 1.5, \posSpeed, 2);

        "0:01.5 - [Cue 2: Emerging Patterns]".postln;
        1.wait;
        Pbindef(\intricateRhythm,
            \instrument, \featherPluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \octave, Pwrand([6, 7], [0.7, 0.3], inf),
            \degree, Pseq([0, 2, 4, 7, 4, 2], inf),
            \dur, Pseq([0.125, 0.25, 0.125, 0.5], inf),
            \fmRatio, Pwhite(1.5, 3.5),
            \sustain, 0.05,
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5)
        ).play;

        "0:05.0 - [Cue 3: Overlapping Rows]".postln;
        3.5.wait;
        Ndef(\delicateWeave).xset(\rate, 0.2, \density, 30);
        Ndef(\spectralPlume).fadeTime = 3;
        Ndef(\spectralPlume).xset(\amp, 0.15, \modFreq, 200);

        "0:09.0 - [Cue 4: Color Morphs]".postln;
        4.wait;
        Pbindef(\intricateRhythm, \scale, Scale.diminished);
        // Active Wait: Random walk spectral parameters over 6s
        4.do {
            Ndef(\spectralPlume).xset(\modFreq, rrand(100, 600), \phaseShift, rrand(0.0, 3.14));
            1.5.wait;
        };

        "0:15.0 - [Cue 5: Organized Complexity]".postln;
        Pbindef(\intricateRhythm_2,
            \instrument, \featherPluck,
            \out, ~synthBus,
            \scale, Scale.diminished,
            \octave, 5,
            \degree, Pseq([0, -2, 3, 1], inf),
            \dur, 0.333,
            \fmRatio, 1.2,
            \sustain, 0.1,
            \amp, 0.12
        ).play;
        Ndef(\delicateWeave).xset(\density, 50);
        Ndef(\masterMix).xset(\wet10, 0.4);

        // Active wait for 8s
        4.do { Ndef(\delicateWeave).xset(\posSpeed, rrand(3.0, 8.0)); 2.wait; };

        "0:23.0 - [Cue 6: Transient Burst]".postln;
        Pbindef(\intricateRhythm, \amp, 0.4, \sustain, 0.3);
        1.wait;

        "0:24.0 - [Cue 7: Settling Arrangement]".postln;
        Pbindef(\intricateRhythm, \amp, 0.15, \sustain, 0.05);
        Ndef(\delicateWeave).xset(\density, 12, \rate, 0.5);

        // Active wait: 10s total, fading out rhythm_2
        5.do { |i|
            Pbindef(\intricateRhythm_2, \amp, 0.12 - (i * 0.024));
            2.wait;
        };
        Pbindef(\intricateRhythm_2).stop;

        "0:34.0 - [Cue 8: Species Variation]".postln;
        Pbindef(\intricateRhythm, \octave, 6, \degree, Pseq([1, 3, 5, 8], inf));
        Ndef(\spectralPlume).xset(\modFreq, 850);
        5.wait;

        "0:39.0 - [Cue 9: Age Class Shifts]".postln;
        Ndef(\eclipsePad).fadeTime = 5;
        Ndef(\eclipsePad).xset(\amp, 0.2, \cutoff, 4000, \modRate, 0.2);

        // Active wait: 7s
        3.do { Ndef(\eclipsePad).xset(\modRate, rrand(0.2, 0.8)); 2.33.wait; };

        "0:46.0 - [Cue 10: Underlying Structure]".postln;
        Ndef(\delicateWeave).xset(\density, 3, \rate, 0.05);
        Ndef(\spectralPlume).xset(\amp, 0.02);

        // Active wait: 12s
        6.do { |i|
            Ndef(\eclipsePad).xset(\cutoff, 4000 - (i*400));
            2.wait;
        };

        "0:58.0 - [Cue 11: Tracts Revealed]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\eclipsePad).set(\cutoff, 300); // HARD SET
        4.wait;

        "1:02.0 - [Cue 12: Preparing for Change]".postln;
        Ndef(\eclipsePad).xset(\amp, 0.4, \modRate, 1.5);
        // Active wait: 8s
        4.do { |i| Ndef(\eclipsePad).xset(\cutoff, 300 + (i*100)); 2.wait; };

        "1:10.0 - [Cue 13: First Tremor]".postln;
        Ndef(\moltDrone).fadeTime = 0.5;
        Ndef(\moltDrone).xset(\amp, 0.15, \fundFreq, 45, \formFreq, 150);
        2.5.wait;

        "1:12.5 - [Cue 14: Unfurling]".postln;
        Ndef(\eclipsePad).xset(\cutoff, 1800);
        // Active wait: 10s
        5.do { |i|
            Ndef(\moltDrone).xset(\formFreq, 200 + (i*150), \bwFreq, 100 + (i*80));
            2.wait;
        };

        "1:22.5 - [Cue 15: Breeding Plumage (SUBTRACTION)]".postln;
        Ndef(\eclipsePad).fadeTime = 2;
        Ndef(\eclipsePad).clear(2);
        Ndef(\moltDrone).xset(\amp, 0.4);

        Pbindef(\intricateRhythm,
            \scale, Scale.mixolydian,
            \dur, 0.125,
            \fmRatio, 4.5,
            \amp, 0.2
        ).play;
        8.wait;

        "1:30.5 - [Cue 16: Non-Breeding Contrast]".postln;
        Pbindef(\intricateRhythm).set(\fmRatio, 0.5); // HARD SET
        1.5.wait;

        "1:32.0 - [Cue 17: Partial Moult]".postln;
        Pbindef(\intricateRhythm, \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf));
        Ndef(\spectralDegrade).xset(\dMolt, 1, \amp, 1);

        // Active wait: 7s
        7.do { |i|
            Ndef(\spectralDegrade).xset(\randComb, 0.1 + (i*0.1));
            1.wait;
        };

        "1:39.0 - [Cue 18: Complete Moult (SUBTRACTION)]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\moltDrone).xset(\formFreq, 3000, \bwFreq, 2000);
        2.wait;
        Ndef(\moltDrone).clear(1);
        Ndef(\spectralDegrade).xset(\dMolt, 0);
        3.wait;

        "1:44.0 - [Cue 19: Brief Stillness]".postln;
        // Absolute silence except reverb
        1.wait;

        "1:45.0 - [Cue 20: Rejuvenation]".postln;
        Ndef(\delicateWeave).fadeTime = 5;
        Ndef(\delicateWeave).xset(\amp, 0.3, \density, 8, \rate, 1);
        6.wait;

        "1:51.0 - [Cue 21: New Growth]".postln;
        s.sync;
        Ndef(\spectralPlume).fadeTime = 6;
        Ndef(\spectralPlume).xset(\amp, 0.2, \modFreq, 1200, \phaseShift, 0);

        // Active wait: 8s
        4.do { |i|
            Ndef(\delicateWeave).xset(\posSpeed, 0.5 + i, \rate, 1 + (i*0.2));
            2.wait;
        };

        "1:59.0 - [Cue 22: Continuous Replacement]".postln;
        Ndef(\flightEfficiency).fadeTime = 4;
        Ndef(\flightEfficiency).xset(\amp, 0.35, \baseFreq, 150, \decay, 3);

        // Active wait: 12s
        6.do { |i|
            Ndef(\flightEfficiency).xset(\baseFreq, 150 + (i*15), \decay, 3 + (i*0.5));
            2.wait;
        };

        "2:11.0 - [Cue 23: Minimizing Loss]".postln;
        Ndef(\spectralPlume).xset(\amp, 0.3);
        Ndef(\delicateWeave).xset(\density, 20, \rate, 1.2, \posSpeed, 1);
        5.wait;

        "2:16.0 - [Cue 24: Wear of Tips]".postln;
        Ndef(\spectralDegrade).xset(\dFlight, 1, \randComb, 0.0);
        // Active wait: 7s
        7.do { |i|
            Ndef(\spectralDegrade).xset(\randComb, i * 0.12);
            1.wait;
        };

        "2:23.0 - [Cue 25: Juvenile Plumage (SUBTRACTION)]".postln;
        Ndef(\spectralDegrade).xset(\dFlight, 0);
        Ndef(\flightEfficiency).xset(\baseFreq, 400);
        7.wait;

        "2:33.0 - [Cue 26: First-Winter]".postln;
        Ndef(\flightEfficiency).xset(\baseFreq, 200, \decay, 1.5);
        Ndef(\masterMix).xset(\wet10, 0.6);
        10.wait;

        "2:41.0 - [Cue 27: Immature Succession]".postln;
        Pbindef(\intricateRhythm,
            \scale, Scale.minor,
            \octave, 4,
            \degree, Pwrand([0, 2, 4, 7], [0.4, 0.3, 0.2, 0.1], inf),
            \dur, Pwhite(2.0, 4.0),
            \sustain, 3.0,
            \fmRatio, 1.1,
            \amp, 0.25
        ).play;

        // Active wait: 15s
        5.do {
            Ndef(\flightEfficiency).xset(\baseFreq, rrand(180, 250));
            3.wait;
        };

        "2:56.0 - [Cue 28: Plumology's Dawn (SUBTRACTION)]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\flightEfficiency).clear(3);
        Ndef(\delicateWeave).xset(\density, 5, \rate, 0.5, \posSpeed, 0.1);
        7.wait;

        "3:03.0 - [Cue 29: Scientific Observation]".postln;
        Pbindef(\plumologySeq,
            \instrument, \plumologyPing,
            \out, ~synthBus,
            \scale, Scale.major,
            \octave, 6,
            \degree, Pseq([0, 4, 7, 11, 14], inf),
            \dur, Pwrand([1.5, 2.5, 3.0], [0.5, 0.3, 0.2], inf),
            \decay, 5,
            \amp, 0.3
        ).play;
        9.wait;

        "3:12.0 - [Cue 30: Unveiling Complexity]".postln;
        Ndef(\spectralPlume).xset(\amp, 0.4, \modFreq, 440, \phaseShift, 0);
        Pbindef(\plumologySeq,
            \degree, Pseq([[0, 4], [4, 7], [7, 11]], inf),
            \dur, 1.0
        );
        12.wait;

        "3:24.0 - [Cue 31: Synthesis of Knowledge (SUBTRACTION)]".postln;
        Ndef(\delicateWeave).clear(4);
        Ndef(\spectralPlume).xset(\modFreq, 880);
        Pbindef(\plumologySeq,
            \degree, [0, 4, 7, 11],
            \dur, 8.0,
            \decay, 8
        );
        8.wait;

        "3:32.0 - [Cue 32: Final Clarity]".postln;
        Pbindef(\plumologySeq).stop;
        Ndef(\spectralPlume).xset(\modFreq, 1760);
        6.wait;

        "3:38.0 - [Cue 33: Conclusion & Termination]".postln;
        Ndef(\spectralPlume).clear(10);

        2.wait; // 3:40.0
        Tdef.removeAll;

        1.wait; // 3:41.0
        Pbindef.removeAll;

        1.wait; // 3:42.0
        Ndef.clear(8);

        "Score Complete. Awaiting final silence.".postln;
    });

    Tdef(\plumageScore).play;
});

s.makeGui;
)

// Source: composition-rainforest.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING
// KEYWORDS: biodiversityDrone, birdFM, birdSeq, bpf, bus, compose, delayNode, dynklank, freeverb2, insectGranular, mammalGrowl, mammalSeq, masterMix, plantGrowth, pre, riverFlow, rlpf, routing, safetyLimiter, saw, setup, sinosc, speciesCountSeq, speciesPing, swarmSeq, waterDrip, wetAmbience
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\waterDrip, { |out=0, freq=800, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * 0.5 * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\insectGranular, { |out=0, freq=8000, amp=0.1, pan=0, grainDur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, grainDur), doneAction: 2);
        var sig = FSinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\birdFM, { |out=0, freq=2000, modFreq=400, modIndex=2, amp=0.1, pan=0, dur=0.2|
        var env = EnvGen.ar(Env.perc(0.05, dur), doneAction: 2);
        var mod = SinOsc.ar(modFreq) * modIndex * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\mammalGrowl, { |out=0, freq=80, rq=0.2, amp=0.1, pan=0, dur=0.5|
        var env = EnvGen.ar(Env.perc(0.1, dur), doneAction: 2);
        var sig = Saw.ar(freq) + BrownNoise.ar(0.5);
        sig = RLPF.ar(sig, XLine.kr(freq * 5, freq, dur), rq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\speciesPing, { |out=0, freq=440, fmRatio=1, fmIndex=0, noiseMix=0, filterFreq=2000, decay=0.2, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq;
        var osc = SinOsc.ar(freq + mod);
        var noise = BPF.ar(WhiteNoise.ar, filterFreq, 0.2);
        var sig = XFade2.ar(osc, noise, noiseMix * 2 - 1) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\wetAmbience, { |lpf=800, amp=0|
        var noise = PinkNoise.ar(1);
        var sweeps = BPF.ar(noise, LFNoise2.kr(0.1).exprange(300, 2000), 0.5);
        var sig = LPF.ar(noise * 0.2 + sweeps, lpf);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\plantGrowth, { |freqMult=1, lpf=2000, amp=0|
        var trigs = Dust.kr(0.3) + Impulse.kr(0);
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.01, 0.1), trigs);
        var freqs = [1, 1.5, 2.3, 3.8, 4.2] * 200 * freqMult;
        var amps = [1, 0.5, 0.3, 0.2, 0.1];
        var rings = [4, 3.5, 3, 2.5, 2];
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = LPF.ar(sig, lpf);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\biodiversityDrone, { |spread=1, amp=0|
        var num = 12;
        var sig = num.collect { |i|
            var f = 100 * (i + 1) + LFNoise2.kr(0.1).range(-5, 5) * spread;
            SinOsc.ar(f) * LFNoise2.kr(0.2).exprange(0.01, 1) / num;
        }.sum;
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\riverFlow, { |filterFreq=100, amp=0|
        var sig = BrownNoise.ar();
        sig = RLPF.ar(sig, filterFreq, 0.3);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\delayNode, {
        In.ar(~delayBus, 2);
    });

    Ndef(\delayNode)[10] = \filter -> { |in|
        var dt = \delayTime.kr(0.3);
        CombC.ar(in, 1.0, dt, 3);
    };
    Ndef(\delayNode).set(\wet10, 1);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\wetAmbience, 2) + Ndef.ar(\plantGrowth, 2) + Ndef.ar(\biodiversityDrone, 2) + Ndef.ar(\riverFlow, 2);
        var delayed = Ndef.ar(\delayNode, 2);
        synths + cont + delayed;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: \reverbDecay.kr(0.9), damp: 0.2);
    };
    Ndef(\masterMix).set(\wet10, 0);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Verdant Veil]".postln;
        Ndef(\wetAmbience).fadeTime = 5;
        Ndef(\wetAmbience).xset(\amp, 0.6, \lpf, 800);
        Ndef(\plantGrowth).fadeTime = 5;
        Ndef(\plantGrowth).xset(\amp, 0.4);
        Ndef(\masterMix).set(\wet10, 0.7, \reverbDecay, 0.9);

        // Active Wait: 55 seconds
        11.do { |i|
            var lpfTarg = if(i < 5, 400, 800);
            Ndef(\wetAmbience).xset(\lpf, lpfTarg);
            if(0.4.coin) {
                Synth(\waterDrip, [\out, ~synthBus, \freq, rrand(600, 1200), \pan, rrand(-0.5, 0.5), \amp, 0.1]);
            };
            5.wait;
        };

        "0:55 - [Cue 2: Unparalleled Richness]".postln;
        Ndef(\biodiversityDrone).fadeTime = 5;
        Ndef(\biodiversityDrone).xset(\amp, 0.3, \spread, 1.0);
        Ndef(\plantGrowth).xset(\freqMult, 0.8);
        Ndef(\wetAmbience).xset(\amp, 0.4);

        // Active Wait: 45 seconds
        9.do { |i|
            Ndef(\biodiversityDrone).xset(\spread, 1.0 + (i * 0.2));
            5.wait;
        };

        "1:40 - [Cue 3: Brief Pause & Shift]".postln;
        Ndef(\biodiversityDrone).fadeTime = 2;
        Ndef(\biodiversityDrone).xset(\amp, 0);
        Ndef(\plantGrowth).xset(\lpf, 100);
        Ndef(\masterMix).set(\wet10, 0.4);

        5.wait;

        "1:45 - [Cue 4: Million Insect Swarm]".postln;
        Pbindef(\swarmSeq,
            \instrument, \insectGranular,
            \out, ~synthBus,
            \dur, Pwhite(0.01, 0.05),
            \freq, Pexprand(6000, 12000),
            \grainDur, Pwhite(0.005, 0.02),
            \amp, Pexprand(0.02, 0.08),
            \pan, Pwhite(-0.8, 0.8)
        ).play;

        Ndef(\wetAmbience).xset(\lpf, 1200);
        Ndef(\masterMix).set(\wet10, 0.6, \reverbDecay, 0.7);

        // Active Wait: 40 seconds
        8.do { |i|
            Pbindef(\swarmSeq, \freq, Pexprand(6000 + (i*500), 12000 + (i*500)));
            5.wait;
        };

        "2:25 - [Cue 5: Tens of Thousands of Plants]".postln;
        Pbindef(\swarmSeq).stop;
        Ndef(\plantGrowth).xset(\lpf, 2000, \freqMult, 0.5);
        Ndef(\riverFlow).fadeTime = 5;
        Ndef(\riverFlow).xset(\amp, 0.5);

        // Active Wait: 35 seconds
        7.do { |i|
            var flowFreq = if(i < 3, 150, 50);
            Ndef(\riverFlow).xset(\filterFreq, flowFreq);
            5.wait;
        };

        "3:00 - [Cue 6: 2,000 Birds and Mammals]".postln;
        Pbindef(\birdSeq,
            \instrument, \birdFM,
            \out, ~delayBus,
            \dur, Pwrand([0.5, 1.5, 3.0], [0.5, 0.3, 0.2], inf),
            \freq, Pexprand(1000, 3000),
            \modFreq, Pexprand(200, 800),
            \modIndex, Pwhite(1.0, 5.0),
            \amp, 0.15,
            \pan, Pwhite(-0.6, 0.6)
        ).play;

        Pbindef(\mammalSeq,
            \instrument, \mammalGrowl,
            \out, ~synthBus,
            \dur, Pwrand([2.0, 4.0, 8.0], [0.6, 0.3, 0.1], inf),
            \freq, Pwhite(40, 120),
            \rq, Pwhite(0.1, 0.4),
            \amp, 0.25,
            \pan, Pwhite(-0.3, 0.3)
        ).play;

        Ndef(\riverFlow).xset(\amp, 0.6);

        // Active Wait: 45 seconds
        9.do { |i|
            Ndef(\delayNode).set(\delayTime, 0.2 + (i * 0.03));
            5.wait;
        };

        "3:45 - [Cue 7: Enumeration of Life]".postln;
        Pbindef(\speciesCountSeq,
            \instrument, \speciesPing,
            \out, ~synthBus,
            \dur, 0.5,
            \fmRatio, Pseq([1, 0.1, 3, 0, 0.5, 0], inf),
            \fmIndex, Pseq([0, 0, 5, 0, 2, 0], inf),
            \noiseMix, Pseq([0.1, 0, 0, 0, 0, 0.8], inf),
            \filterFreq, Pseq([2000, 1000, 5000, 200, 800, 4000], inf),
            \decay, Pseq([0.1, 0.3, 0.5, 0.2, 0.4, 0.05], inf),
            \freq, Pseq([600, 1500, 2500, 80, 300, 3000], inf) * Pwhite(0.9, 1.1),
            \amp, 0.15,
            \pan, Pwhite(-0.7, 0.7)
        ).play;

        // Active Wait: 45 seconds
        9.do { |i|
            Pbindef(\speciesCountSeq, \dur, 0.5 - (i * 0.03));
            5.wait;
        };

        "4:30 - [Cue 8: Invertebrate Surge & Climax]".postln;
        Pbindef(\swarmSeq).play;
        Ndef(\biodiversityDrone).fadeTime = 3;
        Ndef(\biodiversityDrone).xset(\amp, 0.5, \spread, 3.0);
        Ndef(\masterMix).set(\wet10, 0.8, \reverbDecay, 0.95);

        // Active Wait: 30 seconds
        6.do { |i|
            Pbindef(\speciesCountSeq, \dur, 0.1);
            Ndef(\biodiversityDrone).xset(\spread, 3 + i);
            5.wait;
        };

        "5:00 - [Cue 9: Final Dissolution]".postln;
        Pbindef.removeAll; // Hard stop all discrete events

        Ndef(\biodiversityDrone).fadeTime = 3;
        Ndef(\biodiversityDrone).xset(\amp, 0);

        Ndef(\wetAmbience).fadeTime = 15;
        Ndef(\wetAmbience).xset(\amp, 0);

        Ndef(\riverFlow).fadeTime = 15;
        Ndef(\riverFlow).xset(\amp, 0);

        Ndef(\plantGrowth).fadeTime = 15;
        Ndef(\plantGrowth).xset(\amp, 0);

        Ndef(\masterMix).set(\wet10, 0.9, \reverbDecay, 0.99);

        // Active Wait: 20 seconds
        4.do {
            5.wait;
        };

        "5:20 - TERMINATION".postln;
        Ndef.clear(5);
        5.wait;

        "Score Complete.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-red-necked-grebe.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING
// KEYWORDS: bpf, bus, chickChirp, chicklet, combl, communalHarmony, compose, deepWaterResonance, freeverb2, grebeCall, grebeMotif, hpf, insectBuzz, insectDance, lakeSurface, masterMix, pre, rippleSeq, rippleSplash, rlpf, routing, safetyLimiter, saw, setup, vegetationSway
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\grebeCall, { |out=0, freq=800, decay=0.1, cutoff=2000, rq=0.2, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var fEnv = EnvGen.ar(Env.perc(0.01, decay * 1.5));
        var mod = SinOsc.ar(freq * 1.414) * freq * env * 0.5;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, (cutoff * fEnv).clip(20, 18000), rq);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\rippleSplash, { |out=0, freq=1000, decay=0.2, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var sig = PinkNoise.ar * env;
        sig = BPF.ar(sig, freq, 0.3);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\insectBuzz, { |out=0, freq=6000, decay=0.02, density=15, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var sig = LFNoise0.ar(density * 100) * env;
        sig = HPF.ar(sig, freq);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\chickChirp, { |out=0, freq=1800, decay=0.05, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var pEnv = EnvGen.ar(Env([1, 1.2, 1], [0.01, decay]));
        var sig = LFTri.ar(freq * pEnv) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\lakeSurface, { |grainRate=80, amp=0, rq=0.3|
        var rqLfo = SinOsc.kr(0.1).range(0.2, rq.max(0.2));
        var trigs = Dust.ar(grainRate);
        var sig = WhiteNoise.ar * EnvGen.ar(Env.perc(0.01, 0.05), trigs);
        sig = BPF.ar(sig, LFNoise2.kr(0.2).exprange(800, 3000), rqLfo);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\deepWaterResonance, { |freq=55, pmIndex=0.01, amp=0|
        var mod = SinOsc.ar(freq * 0.5) * pmIndex * 100;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, freq * 4, 0.5);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\vegetationSway, { |lfoRate=0.2, cutoff=800, amp=0|
        var lfoAmp = SinOsc.kr(lfoRate).range(0.6, 1.0);
        var lfoCut = SinOsc.kr(lfoRate * 0.8).exprange(200, cutoff.max(201));
        var sig = Saw.ar([110, 111.5]) + Saw.ar([55, 55.2]);
        sig = LPF.ar(sig, lfoCut) * lfoAmp;
        sig * amp * 0.3;
    });

    Ndef(\communalHarmony, { |detuneAmount=0.005, amp=0|
        var freqs = [220, 275, 330, 440, 550];
        var lfos = { LFNoise2.kr(0.1).range(1 - detuneAmount, 1 + detuneAmount) } ! 5;
        var sig = Splay.ar(SinOsc.ar(freqs * lfos));
        sig * amp * 0.4;
    });

    // Master Mix & FX
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\lakeSurface, 2) +
                   Ndef.ar(\deepWaterResonance, 2) +
                   Ndef.ar(\vegetationSway, 2) +
                   Ndef.ar(\communalHarmony, 2);
        synths + cont;
    });

    // Delay FX
    Ndef(\masterMix)[10] = \filter -> { |in|
        // Fixed: JITLib automatically creates 'wet10' and handles crossfading.
        // Defining \wet10.kr manually causes a NamedControl default value conflict.
        CombL.ar(in, 0.5, 0.2, 1.5);
    };

    // Reverb FX
    Ndef(\masterMix)[11] = \filter -> { |in|
        // Fixed: JITLib automatically creates 'wet11' and handles crossfading.
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.8, damp: 0.4);
    };

    Ndef(\masterMix).set(\wet10, 0, \wet11, 0.4);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: Dawn on the Lake]".postln;

        Ndef(\lakeSurface).fadeTime = 20;
        Ndef(\lakeSurface).xset(\amp, 0.4, \grainRate, 120, \rq, 0.4);

        Ndef(\deepWaterResonance).fadeTime = 15;
        Ndef(\deepWaterResonance).xset(\amp, 0.3);

        Pbindef(\rippleSeq,
            \instrument, \rippleSplash,
            \out, ~synthBus,
            \dur, Pwhite(1.5, 4.0, inf),
            \amp, Pseq([0.2, 0.5, 0.8], inf) * 0.3,
            \decay, Pseq([1, 2, 3], inf),
            \freq, Pexprand(600, 2000, inf),
            \pan, Prand([0.0, 0.5, -0.5], inf)
        ).play;

        // Active Wait: 25 seconds
        5.do {
            Ndef(\deepWaterResonance).xset(\pmIndex, rrand(0.01, 0.05));
            5.wait;
        };


        "0:25 - [Cue 2: Underwater Pursuit (HARD CONTRAST)]".postln;

        Ndef(\lakeSurface).fadeTime = 2;
        Ndef(\lakeSurface).xset(\amp, 0.1);
        Pbindef(\rippleSeq).stop;

        Ndef(\deepWaterResonance).fadeTime = 3;
        Ndef(\deepWaterResonance).xset(\amp, 0.6);
        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\wet11, 0.2); // Drier reverb
        Ndef(\masterMix).xset(\wet10, 0.3); // Add subtle delay for pursuit

        Pbindef(\grebeMotif,
            \instrument, \grebeCall,
            \out, ~synthBus,
            \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf),
            \freq, Pseq([Pseries(800, -100, 3), Pseries(1200, -200, 4)], inf),
            \decay, 0.1,
            \cutoff, Pexprand(1500, 3000, inf),
            \rq, 0.2,
            \amp, 0.4,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;

        Pbindef(\insectDance,
            \instrument, \insectBuzz,
            \out, ~synthBus,
            \dur, Pwhite(0.1, 0.3, inf),
            \freq, Pwhite(4000, 8000, inf),
            \decay, Pseq([0.01, 0.02], inf),
            \density, Pseq([10, 20, 15], inf),
            \amp, 0.15,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Active Wait: 25 seconds
        5.do { |i|
            if(i == 2, { Ndef(\deepWaterResonance).xset(\freq, 50) }); // Shift down
            if(i == 4, { Ndef(\deepWaterResonance).xset(\freq, 60) }); // Shift back
            Pbindef(\grebeMotif, \decay, rrand(0.05, 0.2));
            5.wait;
        };


        "0:50 - [Cue 3: Floating Sanctuary]".postln;

        Pbindef(\insectDance).stop;
        Pbindef(\grebeMotif, \dur, 2.0, \legato, 0.1, \amp, 0.2);

        Ndef(\deepWaterResonance).fadeTime = 5;
        Ndef(\deepWaterResonance).xset(\amp, 0.05);

        Ndef(\vegetationSway).fadeTime = 5;
        Ndef(\vegetationSway).xset(\amp, 0.4, \lfoRate, 0.1);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet11, 0.6); // Softer, expansive space

        Ndef(\lakeSurface).fadeTime = 5;
        Ndef(\lakeSurface).xset(\amp, 0.2, \grainRate, 60);

        Pbindef(\chicklet,
            \instrument, \chickChirp,
            \out, ~synthBus,
            \dur, Pwhite(0.5, 2.0, inf),
            \freq, Pwhite(1500, 2000, inf),
            \decay, 0.05,
            \amp, 0.2,
            \pan, Prand([0.1, 0.0, 0.2], inf)
        ).play;

        // Active Wait: 28 seconds
        7.do {
            Ndef(\vegetationSway).xset(\lfoRate, rrand(0.1, 0.3), \cutoff, rrand(600, 1200));
            4.wait;
        };


        "1:18 - [Cue 4: Communal Dance (LATE-STAGE KINETIC ENERGY)]".postln;

        Ndef(\vegetationSway).fadeTime = 5;
        Ndef(\vegetationSway).xset(\cutoff, 4000, \lfoRate, 0.4);

        Ndef(\communalHarmony).fadeTime = 15;
        Ndef(\communalHarmony).xset(\amp, 0.7);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet11, 0.7); // Lush full sound

        Pbindef(\grebeMotif,
            \dur, Pseq([0.25, 0.5, 0.125], inf),
            \freq, Pwalk((400, 500 .. 1600), Pseq([1, 1, -1, 2, -1], inf), 1),
            \amp, 0.4
        );

        Pbindef(\rippleSeq,
            \dur, Pwhite(0.1, 0.4, inf),
            \decay, 0.05,
            \amp, 0.4,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        Pbindef(\insectDance,
            \dur, Pwhite(0.05, 0.15, inf),
            \density, 50,
            \amp, 0.2
        ).play;

        Pbindef(\chicklet, \amp, 0.3);

        // Active Wait: 42 seconds
        7.do {
            Ndef(\communalHarmony).xset(\detuneAmount, rrand(0.005, 0.015));
            Pbindef(\rippleSeq, \freq, rrand(800, 3000));
            6.wait;
        };


        "2:00 - [Cue 5: Return to Stillness (TERMINATION)]".postln;

        // Instant subtraction of discrete events
        Pbindef(\grebeMotif).stop;
        Pbindef(\rippleSeq).stop;
        Pbindef(\insectDance).stop;
        Pbindef(\chicklet).stop;

        // Coordinated fade-outs
        Ndef(\communalHarmony).fadeTime = 20;
        Ndef(\communalHarmony).xset(\amp, 0.0);

        Ndef(\vegetationSway).fadeTime = 22;
        Ndef(\vegetationSway).xset(\amp, 0.0);

        Ndef(\lakeSurface).fadeTime = 25;
        Ndef(\lakeSurface).xset(\amp, 0.0);

        Ndef(\deepWaterResonance).fadeTime = 28;
        Ndef(\deepWaterResonance).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet11, 0.9); // Reverb blooms

        // Active Wait: 30 seconds
        6.do { |i|
            if(i == 3, {
                // At 15 seconds into the fade, start bringing down master volume
                Ndef(\masterMix).fadeTime = 15;
                Ndef(\masterMix).xset(\vol, 0.0);
            });
            5.wait;
        };

        "2:30 - Final Conclusion. Cleaning up.".postln;
        Pbindef.removeAll;
        Ndef.clear(2.0);
        Tdef.removeAll;
        "Score Complete. Server Silent.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: gemini-composition-hummingbird.scd [Block 3]
// MODE: compose
// THEME: Smoothly introduce the vast Andean spatial reverb
// KEYWORDS: andean, birdWings, canopyPad, compose, introduce, nectarNest, nestSeq, padSeq, reverb, serpentThreat, smoothly, spatial, the, threatSeq, vast, wingSeq
(
Tdef(\fawnBreastedScore, {

    "0:00 - [Blocks 1 & 2: The Altitudinal Limit & Instinct]".postln;
    Ndef(\canopyPad).play;
    Ndef(\canopyPad)[1] = \set -> Pbindef(\padSeq);

    // Smoothly introduce the vast Andean spatial reverb
    Ndef(\canopyPad).xset(\wet10, 0.6, \lpfFreq, 1800);

    15.wait;

    "0:15 - [Blocks 3, 4 & 5: The Bird Hovering / Hunting Floaters]".postln;
    Ndef(\birdWings).play;
    Ndef(\birdWings)[1] = \set -> Pbindef(\wingSeq);

    // Snap a dry delay on the rapid 9:5 polyrhythm flutter
    Ndef(\birdWings).set(\wet11, 0.15);

    20.wait; // Now at 0:35

    "0:35 - [Blocks 6 & 7: Solitary Burden & Plague Alarm]".postln;
    // Alter global modifiers via .xset to avoid overriding Pbindef streams
    Ndef(\birdWings).xset(\freqMult, 1.25, \wet11, 0.4, \decayTime, 1.5);
    Ndef(\canopyPad).xset(\hpfFreq, 300); // The forest tension thins the low end

    15.wait; // Now at 0:50

    "0:50 - [Blocks 8, 9 & 10: Unpredictable Flight & The Meteor Serpent]".postln;
    Ndef(\serpentThreat).play;
    Ndef(\serpentThreat)[1] = \set -> Pbindef(\threatSeq);

    // The bird's flight becomes erratic and Doppler-shifted as it evades
    Ndef(\birdWings).xset(\freqMult, 1.5, \wet11, 0.7);
    Ndef(\canopyPad).xset(\lpfFreq, 800); // Muffle the background, focus on the threat

    25.wait; // Now at 1:15

    "1:15 - [Blocks 12 & 13: Buscar Nectar & Physiological Overdrive]".postln;
    Pbindef(\wingSeq, \dur, Pseq([1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/5, 1/5, 1/5, 1/5, 1/5], inf));

    Ndef(\birdWings).xset(\freqMult, 2.0); // Maximum hyper-drive pitch
    Ndef(\serpentThreat).xset(\freqMult, 0.5); // Threat loses ground, dropping in pitch

    25.wait; // Now at 1:40

    "1:40 - [Blocks 14 & 15: The Nest & Breakthrough / Hatching]".postln;
    Pbindef(\threatSeq).stop;
    Ndef(\serpentThreat).clear(5); // Threat dissipates into the jungle

    Ndef(\nectarNest).play;
    Ndef(\nectarNest)[1] = \set -> Pbindef(\nestSeq);

    // The bird calms, returning to the physical resonance of the nest
    Pbindef(\wingSeq, \dur, Pseq([1/5, 1/5, 1/5, 1/5, 1/5, 1/3, 1/3, 1/3], inf));
    Ndef(\birdWings).xset(\freqMult, 1.0, \wet11, 0.2, \decayTime, 0.2);
    Ndef(\canopyPad).xset(\lpfFreq, 3000, \hpfFreq, 100); // Forest opens back up

    25.wait; // Now at 2:05

    "2:05 - [Blocks 16, 17 & 18: Ecosystem Balance & Retreat]".postln;
    Pbindef(\nestSeq, \dur, Pseq([1, 1.5, 2], inf)); // Slowing down the physical modeling

    Ndef(\birdWings).xset(\freqMult, 0.75); // Retreating into the canopy
    Ndef(\canopyPad).xset(\lpfFreq, 400); // Light fading

    15.wait; // Now at 2:20

    "2:20 - [End of Day - .Clear]".postln;
    Pbindef(\padSeq).stop;
    Pbindef(\wingSeq).stop;
    Pbindef(\nestSeq).stop;

    // Clear all proxies with a long 10-second fade out
    Ndef(\canopyPad).clear(10);
    Ndef(\birdWings).clear(10);
    Ndef(\nectarNest).clear(10);

    "Score Complete. System Silent.".postln;
});
)

// Source: composition-iotd-v1.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & GROUPS
// KEYWORDS: bus, coffinBass, compose, darkWaters, ferrymanKnock, fold, freeverb2, groups, limiter, masterMix, moogff, pinknoise, pre, processionSeq, routing, safetyLimiter, setup, shroudSeq, sinosc, whiteShroud
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~sourceGroup = Group.new(s);
    ~fxGroup = Group.after(~sourceGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\whiteShroud, { |out=0, freq=1000, decayTime=1, amp=0.1, pan=0|
        var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        // Strict adherence to Klank formatting with Ref
        var sig = Klank.ar(`[
            [1, 2.15, 3.2, 4.8],
            [1, 0.6, 0.4, 0.1],
            [1, 0.7, 0.5, 0.2]
        ], exc, freqscale: freq, decayscale: decayTime);

        var env = EnvGen.ar(Env.perc(0.001, decayTime + 0.1), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\coffinBass, { |out=0, freq=41.2, foldAmount=5, filterEnvAmount=1, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.25), doneAction: 2);
        var fEnv = EnvGen.ar(Env.perc(0.01, 0.2));
        var sig = SinOsc.ar(freq);

        // Aggressive wave-folding
        sig = Fold.ar(sig * foldAmount, -0.5, 0.5);

        // Subtractive filter with envelope
        sig = MoogFF.ar(sig, (freq * 2) + (fEnv * 2000 * filterEnvAmount), 1.5);
        sig = LeakDC.ar(sig); // Prevent DC offset from folding

        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\darkWaters, { |pmIndex=2, lpfCutoff=800, amp=0.8|
        var mod = LFNoise2.kr(0.1).range(0.9, 1.1);
        var sig = PMOsc.ar(50, 25 * mod, pmIndex);
        var sub = SinOsc.ar(25);
        sig = sig + (sub * 0.5); // Viscous sub-weight
        sig = LPF.ar(sig, lpfCutoff);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\ferrymanKnock, { |dustDens=0.5, amp=0|
        var trigs = Dust.ar(dustDens);
        var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01), trigs);
        var freq = 40;
        // Karplus-Strong physical modeling
        var sig = Pluck.ar(exc, trigs, 0.2, freq.reciprocal.clip(0.0001, 0.2), 1.0, 0.5);
        Pan2.ar(sig * amp, TRand.ar(-0.5, 0.5, trigs));
    });

    // Master Mixer: Combines Synths and Ndefs
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var waters = Ndef.ar(\darkWaters, 2);
        var knock = Ndef.ar(\ferrymanKnock, 2);
        synths + waters + knock;
    });

    // Slot 10: Cypress Reverb (Massive, dark, highly dampened)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.9);
    };

    // Initialize Mixer
    Ndef(\masterMix).set(\wet10, 0.6);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\isleOfTheDead, {

        "0:00 - [Movement I: The Monolithic Waters]".postln;
        Ndef(\darkWaters).fadeTime = 5;
        Ndef(\darkWaters).set(\amp, 0.8, \pmIndex, 1.5, \lpfCutoff, 800);
        Ndef(\masterMix).set(\wet10, 0.6);

        // Active Wait: 42.5 seconds. Micro-gestural sweeps of PM Index.
        6.do {
            Ndef(\darkWaters).xset(\pmIndex, rrand(1.5, 4.0));
            7.wait;
        };
        0.5.wait;

        "0:42.5 - [Movement II: The Shroud (Stark Contrast)]".postln;
        // Subtractive arrangement: Choke the drone
        Ndef(\darkWaters).fadeTime = 10;
        Ndef(\darkWaters).xset(\lpfCutoff, 150);

        Pbindef(\shroudSeq,
            \instrument, \whiteShroud,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \dur, Pwhite(1.5, 3.0, inf),
            \freq, Pexprand(800, 2500, inf),
            \amp, 0.15
        ).play;

        // Active Wait: 35.5 seconds. Randomizing decay and pan.
        7.do {
            Pbindef(\shroudSeq, \decayTime, rrand(0.5, 3.0), \pan, rrand(-0.6, 0.6));
            5.wait;
        };
        0.5.wait;

        "1:18.0 - [Movement III: The Knock (Micro-Gestural Agitation)]".postln;
        Ndef(\ferrymanKnock).fadeTime = 54.5;
        Ndef(\ferrymanKnock).set(\amp, 1.0);
        Ndef(\ferrymanKnock).xset(\dustDens, 35); // Exponential density rise

        // Active Wait: 54.5 seconds. Accelerating the shroud sequence.
        10.do { |i|
            var newDur = max(0.1, 1.5 - (i * 0.13));
            Pbindef(\shroudSeq, \dur, Pwhite(newDur, newDur + 0.3, inf));
            5.wait;
        };
        4.5.wait;

        "2:12.5 - [Movement IV: The Retroactive Procession (Kinetic Climax)]".postln;
        // Spotlight Rule: Stop Shroud, Mute Waters completely.
        Pbindef(\shroudSeq).stop;
        Ndef(\darkWaters).set(\amp, 0);

        // Bypass Reverb for violent dryness
        Ndef(\masterMix).set(\wet10, 0);

        Pbindef(\processionSeq,
            \instrument, \coffinBass,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \dur, 0.125, // 16th notes
            \freq, Pseq([41.2, 41.2, 41.2, 44, 41.2, 36.7, 41.2, 48], inf),
            \amp, 0.7
        ).play;

        // Active Wait: 39.5 seconds. Frantic parameter randomization.
        7.do {
            Pbindef(\processionSeq, \foldAmount, rrand(3.0, 12.0), \filterEnvAmount, rrand(0.5, 2.5));
            5.wait;
        };
        4.5.wait;

        "2:52.0 - [Movement V: The Extrinsic Limit (Termination via Fade)]".postln;
        // Instant termination of kinetic elements
        Pbindef.removeAll;

        // Restore Reverb for the ghostly smear
        Ndef(\masterMix).set(\wet10, 1.0);

        // 25-second forced global fade-out
        Ndef.clear(25);

        // Active Wait: 25 seconds to conclude the piece.
        5.do {
            5.wait;
        };

        "3:17.0 - Score Complete. Silence reached.".postln;

    });

    Tdef(\isleOfTheDead).play;
});

s.makeGui;
)

// Source: composition-iotd-v2.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & GROUPS
// KEYWORDS: boatSeq, bpf, bus, compose, cypressSeq, fold, formant, freeverb2, griefSputter, groups, masterMix, pre, rlpf, routing, safetyLimiter, saw, setup, shroudLFO, spectralShroud, theKnock, waveCypress, woodyPluck
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~sourceGroup = Group.new(s);
    ~fxGroup = Group.after(~sourceGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\woodyPluck, { |out=0, freq=220, decayTime=1, strikePosition=0.5, amp=0.5, pan=0|
        var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        // Pluck delaytime is 1/freq. Max delay bounded to 0.2s to prevent buffer overflow.
        var sig = Pluck.ar(exc, 1, 0.2, freq.reciprocal.clip(0.0001, 0.2), decayTime, strikePosition);
        var env = EnvGen.ar(Env.perc(0.001, decayTime), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\theKnock, { |out=0, amp=1|
        var env = EnvGen.ar(Env.perc(0.001, 4.0, 1, -4), doneAction: 2);
        var freqEnv = XLine.ar(150, 30, 0.2);
        var sig = SinOsc.ar(freqEnv) + Pulse.ar(freqEnv, 0.5, 0.2);
        sig = RLPF.ar(sig, XLine.ar(800, 80, 0.3), 0.4);
        Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    SynthDef(\waveCypress, { |out=0, freq=440, foldAmount=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.15, 1, -2), doneAction: 2);
        var mod = SinOsc.ar(freq * 0.5) * freq * foldAmount;
        var sig = SinOsc.ar(freq + mod);
        // Aggressive wave-folding
        sig = Fold.ar(sig * (1 + (foldAmount * 10)), -0.5, 0.5);
        sig = RHPF.ar(sig, 800, 0.3); // High pass to clear the low end
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\spectralShroud, { |pmIndex=1.5, lpfFreq=8000, amp=0|
        var freqs = [55, 110, 165, 220]; // Choral stack
        var sig = freqs.collect { |f|
            var mod = SinOsc.ar(f * 1.414) * pmIndex * SinOsc.kr(Rand(0.05, 0.1)).range(0.5, 1.5);
            PMOsc.ar(f, f * 1.01, mod)
        }.sum;
        sig = LPF.ar(sig, lpfFreq);
        sig = BPF.ar(sig, [400, 800, 1200], 0.3).sum + (sig * 0.3); // Formant-like emphasis
        Pan2.ar(sig * amp * 0.15, 0);
    });

    Ndef(\griefSputter, { |grainDensity=5, amp=0|
        var trigs = Dust.ar(grainDensity);
        var env = EnvGen.ar(Env.perc(0.005, 0.05), trigs);
        var freqs = TRand.ar(400, 3000, trigs);
        var sig = Saw.ar(freqs) * env;
        sig = RLPF.ar(sig, freqs * 2, 0.2);
        Pan2.ar(sig * amp, TRand.ar(-0.8, 0.8, trigs));
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\spectralShroud, 2) + Ndef.ar(\griefSputter, 2);
        synths + continuous;
    });

    // Slot 10: Algorithmic Reverb with Sub-Ducking
    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: \decaySize.kr(0.9), damp: 0.8);
        var duckCtrl = LPF.ar(in[0] + in[1], 150); // Isolate massive sub-frequencies
        verb = Compander.ar(verb, duckCtrl,
            thresh: 0.15,
            slopeBelow: 1,
            slopeAbove: 0.1, // Heavy ducking when sub is present
            clampTime: 0.01,
            relaxTime: 0.4
        );
        verb;
    };

    Ndef(\masterMix).play(group: ~fxGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\bernaScore, {

        "0:00 - [Cue 1: The Wood Panel (Intimate Stillness)]".postln;
        Ndef(\masterMix).fadeTime = 1;
        Ndef(\masterMix).set(\wet10, 0.1, \decaySize, 0.3); // Very dry, intimate space

        Pbindef(\boatSeq,
            \instrument, \woodyPluck,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.5, 0.25, 0.125, 0.875], inf),
            \freq, Pseq([220, 110, 330, 165, 82.5], inf),
            \decayTime, Pwhite(0.2, 1.5, inf),
            \amp, Pwhite(0.3, 0.6, inf)
        ).play;

        // ACTIVE WAIT: 42 Seconds (21 loops of 2s)
        21.do {
            Pbindef(\boatSeq,
                \strikePosition, rrand(0.1, 0.9),
                \pan, rrand(-0.4, 0.4)
            );
            2.wait;
        };

        "0:42 - [Cue 2: The White Shroud (Subtractive Awe)]".postln;
        Pbindef(\boatSeq).stop; // Instant subtraction

        // Sweep reverb to massive scale over 4 seconds
        Ndef(\masterMix).fadeTime = 4;
        Ndef(\masterMix).xset(\wet10, 0.85, \decaySize, 0.95);

        // Swell the shroud drone
        Ndef(\spectralShroud).fadeTime = 5;
        Ndef(\spectralShroud).xset(\amp, 1.0);

        // Apply 12-second LFO to pmIndex for breathing motion
        Ndef(\shroudLFO, { SinOsc.kr(1/12).range(1.0, 4.0) });
        Ndef(\spectralShroud).map(\pmIndex, Ndef(\shroudLFO));

        // ACTIVE WAIT: 33 Seconds (11 loops of 3s)
        11.do { |i|
            // Micro-modulations to the LPF to keep it alive
            Ndef(\spectralShroud).xset(\lpfFreq, rrand(6000, 9000));
            3.wait;
        };

        "1:15 - [Cue 3: The Knock & Active Mourning]".postln;
        // The Knock - Jarring impact
        Synth(\theKnock, [\out, ~synthBus, \amp, 2.5], target: ~sourceGroup);

        // Initiate granular mourning
        Ndef(\griefSputter).fadeTime = 0.5;
        Ndef(\griefSputter).xset(\amp, 0.6);

        // ACTIVE WAIT: 50 Seconds (25 loops of 2s)
        // Escalating the granular density from 5Hz to 200Hz
        25.do { |i|
            var dens = 5 + ((i / 24) * 195);
            Ndef(\griefSputter).xset(\grainDensity, dens);
            // Agitate the depth field
            Ndef(\masterMix).xset(\decaySize, rrand(0.7, 0.95));
            2.wait;
        };

        "2:05 - [Cue 4: The Enclosed Grove (Late-Stage Kinetic Energy)]".postln;
        // SPOTLIGHT RULE: Choke the shroud drone to make room
        Ndef(\spectralShroud).unmap(\pmIndex);
        Ndef(\spectralShroud).fadeTime = 2;
        Ndef(\spectralShroud).xset(\lpfFreq, 300, \amp, 0.5);

        // Bring reverb forward slightly for aggressive arps
        Ndef(\masterMix).xset(\wet10, 0.6, \decaySize, 0.6);

        Pbindef(\cypressSeq,
            \instrument, \waveCypress,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \dur, 0.125, // Frantic 16th notes
            \scale, Scale.harmonicMinor,
            \degree, Pseq([0, 2, 4, 7, 5, 3, 2, -1], inf),
            \amp, 0.5
        ).play;

        // ACTIVE WAIT: 45 Seconds (15 loops of 3s)
        15.do {
            Pbindef(\cypressSeq,
                \foldAmount, rrand(0.3, 1.0),
                \octave, [4, 5, 6, 7].wchoose([0.1, 0.4, 0.4, 0.1]),
                \pan, rrand(-0.8, 0.8)
            );
            3.wait;
        };

        "2:50 - [Cue 5: The Crossing (Long Fade to Silence)]".postln;
        // Instant termination of kinetic sequences
        Pbindef.removeAll;

        // Massive 27-second fade out of all drones and reverb
        Ndef.clear(27);

        27.wait;

        "3:17 - [Absolute Silence. Score Complete.]".postln;
        Tdef.removeAll;
    });

    Tdef(\bernaScore).play;
});

s.makeGui;
)

// Source: composition-iotd-v3.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS & GROUP ROUTING
// KEYWORDS: bus, chancelleryShadow, compose, etchSeq, etchingScratch, ferrymanKnock, fold, freeverb2, group, lunarGlow, marchSeq, masterMix, oarSeq, panicStab, pinknoise, pre, ringz, rlpf, routing, safetyLimiter, setup, sinosc, spectralFreeze, tombReverb
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & GROUP ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~freezeBus = Bus.audio(s, 2);
    s.sync;

    ~sourceGroup = Group.new(s);
    ~fxGroup = Group.after(~sourceGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\ferrymanKnock, { |out=0, revOut=0, revSend=0.0, freezeOut=0, freezeSend=0.0, freq=300, decayTime=1.0, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.01));
        var exciter = PinkNoise.ar(0.5) * env;

        // Woody physical modeling via dual Ringz
        var body = Ringz.ar(exciter, freq, decayTime);
        var click = Ringz.ar(exciter, freq * 2.3, decayTime * 0.3);
        var sig = (body + click) * 0.2;

        var panned = Pan2.ar(sig * amp, pan);
        var lifeEnv = EnvGen.ar(Env.linen(0.0, decayTime, 0.1), doneAction: 2); // CRITICAL: doneAction 2

        Out.ar(out, panned * lifeEnv);
        Out.ar(revOut, panned * lifeEnv * revSend);
        Out.ar(freezeOut, panned * lifeEnv * freezeSend);
    }).add;

    SynthDef(\etchingScratch, { |out=0, freq=8000, grainDensity=50, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, 0.05), doneAction: 2);
        var dust = Dust2.ar(grainDensity);
        var sig = Ringz.ar(dust, freq, 0.01) * 0.5;
        Out.ar(out, Pan2.ar(sig * amp * env, pan));
    }).add;

    SynthDef(\panicStab, { |out=0, freq=200, fmIndex=4, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
        var modEnv = EnvGen.ar(Env.perc(0.001, 0.05));
        var mod = SinOsc.ar(freq * 1.618) * fmIndex * freq * modEnv; // Non-integer, atonal ratio
        var sig = SinOsc.ar(freq + mod);
        sig = (sig * 1.5).tanh;
        Out.ar(out, Pan2.ar(sig * amp * env, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: The Pale Water Drone
    Ndef(\lunarGlow, {
        var pmIndex = \pmIndex.kr(0.5);
        var freq = 55; // Cold, low fundamental
        var mod = SinOsc.ar(freq * 2.01) * pmIndex;
        var sig = Mix.fill(6, { |i|
            var f = freq * (i + 1);
            SinOsc.ar(f + mod) * (1 / ((i + 1) ** 1.2))
        });
        // Suspended, cold shimmer
        sig = sig + DelayC.ar(sig, 0.2, SinOsc.kr(0.03).range(0.01, 0.04));
        Pan2.ar(sig * \amp.kr(0.0), 0);
    });

    // Movement IV: The Chancellery Shadow
    Ndef(\chancelleryShadow, {
        var foldBase = \foldAmount.kr(0.5);
        // Erratic modulation via LFNoise1 as requested
        var foldMod = foldBase + LFNoise1.kr(3).range(0, 0.4);
        var freq = 41.2; // E1
        var sig = LFSaw.ar(freq) + SinOsc.ar(freq * 0.5);

        sig = Fold.ar(sig * (1 + (foldMod * 12)), -0.5, 0.5);
        sig = RLPF.ar(sig, LFNoise1.kr(1.5).exprange(200, 1500), 0.4);
        Pan2.ar(sig * \amp.kr(0.0), 0);
    });

    // FX: Tomb Reverb
    Ndef(\tombReverb, {
        var in = In.ar(~reverbBus, 2);
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.98, damp: 0.1);
    });

    // FX: Spectral Freeze
    Ndef(\spectralFreeze, {
        var in = In.ar(~freezeBus, 2);
        var chainL = FFT(LocalBuf(1024), in[0]);
        var chainR = FFT(LocalBuf(1024), in[1]);
        chainL = PV_MagSmear(chainL, 40);
        chainR = PV_MagSmear(chainR, 40);
        [IFFT(chainL), IFFT(chainR)] * 0.6;
    });

    // Master Mix: Routes all discrete synths to out 0
    Ndef(\masterMix, {
        In.ar(~synthBus, 2);
    });

    // Start Ndefs in their respective groups
    Ndef(\lunarGlow).play(group: ~sourceGroup);
    Ndef(\chancelleryShadow).play(group: ~sourceGroup);
    Ndef(\tombReverb).play(group: ~fxGroup);
    Ndef(\spectralFreeze).play(group: ~fxGroup);
    Ndef(\masterMix).play(group: ~fxGroup);

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Pale Water]".postln;
        Ndef(\lunarGlow).fadeTime = 5;
        Ndef(\lunarGlow).set(\amp, 0.35, \pmIndex, 0.2);

        Pbindef(\oarSeq,
            \instrument, \ferrymanKnock,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \revOut, ~reverbBus,
            \freezeOut, ~freezeBus,
            \revSend, 0.4,
            \freezeSend, 0.3,
            \dur, Pwhite(4.0, 8.0, inf),
            \freq, Pwhite(150, 250, inf),
            \decayTime, 1.5,
            \amp, 0.7,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;

        // ACTIVE WAIT STATE: 38 seconds broken into 19 loops of 2s
        19.do { |i|
            // Slow, complex LFO modulating pmIndex
            Ndef(\lunarGlow).xset(\pmIndex, 0.2 + (sin(i * 0.3) * 0.4));
            2.wait;
        };

        "0:38 - [Cue 2: Sharp Inscriptions (SUBTRACTION)]".postln;
        Ndef(\lunarGlow).fadeTime = 2;
        Ndef(\lunarGlow).xset(\amp, 0.05); // Drastic amplitude drop
        Pbindef(\oarSeq).stop; // Stop the oars

        Pbindef(\etchSeq,
            \instrument, \etchingScratch,
            \group, ~sourceGroup,
            \out, ~synthBus, // Dry (no reverb send)
            \dur, Pwhite(0.05, 0.15, inf),
            \grainDensity, Pwhite(50, 150, inf),
            \freq, Pexprand(6000, 12000, inf),
            \pan, Pwhite(-0.9, 0.9, inf), // Rapid stereo darting
            \amp, 0.25
        ).play;

        // ACTIVE WAIT STATE: 34 seconds (1:12 - 0:38)
        17.do {
            Pbindef(\etchSeq, \grainDensity, rrand(80, 200));
            2.wait;
        };

        "1:12 - [Cue 3: The Multiplied Image]".postln;
        // Expand into dense polyrhythm
        Pbindef(\etchSeq, \dur, Pseq([0.125, 0.0625, 0.0625, 0.125, 0.25], inf));

        // Re-introduce oars: Pitched up, shortened, rigid 16th grid
        Pbindef(\oarSeq,
            \dur, 0.25,
            \freq, Pseq([800, 950, 850, 1100], inf),
            \decayTime, 0.05,
            \revSend, 0.1,
            \freezeSend, 0.1,
            \amp, 0.4
        ).play;

        // ACTIVE WAIT STATE: 58 seconds (2:10 - 1:12)
        // Continuously increase grainDensity to maximum
        29.do { |i|
            var dens = 200 + (i * 40); // Scales up to ~1360
            Pbindef(\etchSeq, \grainDensity, dens);
            2.wait;
        };

        "2:10 - [Cue 4: Late-Stage Kinetic Obsession (SPOTLIGHT)]".postln;
        // HARD CUT
        Pbindef.removeAll; // Instantly stops oarSeq and etchSeq
        Ndef(\lunarGlow).stop; // Hard kill to prevent frequency masking

        Ndef(\chancelleryShadow).fadeTime = 0.1;
        Ndef(\chancelleryShadow).set(\amp, 0.65, \foldAmount, 0.5);

        Pbindef(\marchSeq,
            \instrument, \panicStab,
            \group, ~sourceGroup,
            \out, ~synthBus,
            \dur, Pwrand([0.125, 0.25, 0.375], [0.5, 0.3, 0.2], inf), // Asymmetrical, panicked
            \freq, Pexprand(100, 600, inf),
            \fmIndex, Pwhite(4.0, 9.0, inf),
            \amp, 0.6,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // ACTIVE WAIT STATE: 40 seconds (2:50 - 2:10)
        20.do {
            // Erratic base foldAmount shifts
            Ndef(\chancelleryShadow).xset(\foldAmount, rrand(0.3, 0.9));
            2.wait;
        };

        "2:50 - [Cue 5: The Extrinsic Limit (THE LONG FADE)]".postln;
        Pbindef(\marchSeq).stop; // Instantly terminate violent rhythms

        // Initiate strict 27-second fade-out of ALL Ndefs (bass, reverb, freeze, mix)
        Ndef.clear(27);

        // ACTIVE WAIT STATE: 27 seconds (3:17 - 2:50)
        13.do { 2.wait; };
        1.wait;

        "3:17 - [Cue 6: Absolute Silence]".postln;
        Tdef.removeAll;
        "Score Complete.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-iotd-v4.scd [Block 1]
// MODE: compose
// THEME: PRE-SETUP: BUS ROUTING & MASTER MIX ARCHITECTURE
// KEYWORDS: architecture, bus, compose, doorKnock, dynklank, ferryman, freeverb2, goldenCopper, hpf, knockSeq, master, masterMix, mix, moogff, oarStroke, pre, raidSeq, ringz, routing, safetyLimiter, setup, shrapnel, sinosc, vaultSwarm
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & MASTER MIX ARCHITECTURE
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe, doneAction: 2)
    // --------------------------------------------------------------------

    // Hyper-dry physical modeling knock (wood/bone)
    SynthDef(\doorKnock, { |out=0, amp=1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.08), doneAction: 2);
        var exc = WhiteNoise.ar * env;
        // 3 resonant frequencies mimicking a hollow wooden panel
        var sig = Ringz.ar(exc, 450, 0.08) + Ringz.ar(exc, 800, 0.05) + Ringz.ar(exc, 1200, 0.02);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    // Deep subtractive sweep for the Ferryman's oars
    SynthDef(\oarStroke, { |out=0, amp=1, sweepStart=600, sweepEnd=40, atk=2, rel=2|
        var env = EnvGen.ar(Env([0, 1, 0], [atk, rel], \sin), doneAction: 2);
        var sweep = XLine.kr(sweepStart, sweepEnd, atk+rel);
        var noise = PinkNoise.ar(0.7) + BrownNoise.ar(0.7);
        var sig = MoogFF.ar(noise, sweep, 1.5);
        var sub = SinOsc.ar(sweep.clip(20, 100)) * 0.5; // Deep water displacement
        Out.ar(out, Pan2.ar((sig + sub) * env * amp, 0));
    }).add;

    // Aggressively wave-folded high-frequency bursts
    SynthDef(\shrapnel, { |out=0, freq=2000, foldAmount=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.08), doneAction: 2);
        var sig = SinOsc.ar(freq) * (1 + (foldAmount * 20));
        sig = sig.fold2(0.5) * 1.5; // Brutal wavefolding
        sig = HPF.ar(sig, 1000); // Keep out of the low end
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I & V: The Golden Copper Drone
    Ndef(\goldenCopper, { |amp=0, modalDecay=3, filterFreq=3000|
        var freqs = [261.63, 294.33, 327.03, 367.92, 392.44, 441.49, 490.55]; // C Lydian Ratios
        var exc = PinkNoise.ar * 0.002 + (Dust.ar(0.5) * 0.01);
        var sig = DynKlank.ar(`[freqs, nil, freqs.collect{modalDecay}], exc);
        sig = LPF.ar(sig, filterFreq);
        sig = Splay.ar(sig);
        // Internal reverb keeps the drone lush while the knock remains dry
        sig = FreeVerb2.ar(sig[0], sig[1], mix: 0.5, room: 0.9, damp: 0.2);
        sig * amp;
    });

    // Movement III: The Vault Swarm (Granular/FM)
    Ndef(\vaultSwarm, { |grainDensity=2, amp=0|
        var trig = Dust.ar(grainDensity);
        var freq = TRand.ar(800, 4000, trig);
        var env = Decay2.ar(trig, 0.001, 0.05);
        var mod = SinOsc.ar(freq * 2.3) * freq * 2 * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.8, 0.8, trig));
    });

    // Master JITLib Mixer
    Ndef(\masterMix, {
        In.ar(~synthBus, 2) + Ndef.ar(\goldenCopper, 2) + Ndef.ar(\vaultSwarm, 2);
    });

    // Slot 10: Ruin Distortion (Used in Movement IV)
    Ndef(\masterMix)[10] = \filter -> { |in|
        (in * 6).fold2(0.8).tanh * 0.4;
    };
    Ndef(\masterMix).set(\wet10, 0); // Start dry

    // Slot 20: Abyss Reverb (Used in Movement V)
    Ndef(\masterMix)[20] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.1);
    };
    Ndef(\masterMix).set(\wet20, 0); // Start dry

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Golden Copper (Dream Picture)]".postln;
        Ndef(\goldenCopper).fadeTime = 5;
        Ndef(\goldenCopper).xset(\amp, 0.7, \filterFreq, 3000);

        Pbindef(\knockSeq,
            \instrument, \doorKnock,
            \out, ~synthBus,
            \dur, Pwhite(8.0, 12.0, inf),
            \amp, 0.9,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;

        // ACTIVE WAIT: 42.5 seconds total
        10.do {
            Ndef(\goldenCopper).xset(\modalDecay, rrand(2.5, 4.0));
            4.25.wait;
        };

        "0:42.5 - [Cue 2: The Ferryman's Wake (HARD CONTRAST)]".postln;
        Pbindef(\knockSeq).stop;
        Ndef(\goldenCopper).fadeTime = 0.1;
        Ndef(\goldenCopper).xset(\amp, 0); // Instant subtraction of warmth

        Pbindef(\ferryman,
            \instrument, \oarStroke,
            \out, ~synthBus,
            \dur, 4.0,
            \atk, 2.0,
            \rel, 2.0,
            \sweepStart, Pwhite(500, 800, inf),
            \sweepEnd, 40,
            \amp, 1.4
        ).play;

        // ACTIVE WAIT: 35.5 seconds total
        7.do {
            5.07.wait;
        };

        "1:18.0 - [Cue 3: The Vault's Agitation]".postln;
        Ndef(\vaultSwarm).fadeTime = 2;
        Ndef(\vaultSwarm).xset(\amp, 0.6);

        // ACTIVE WAIT: 54 seconds total (Continuous non-repeating arc)
        18.do { |i|
            var arcProgress = i / 17; // 0.0 to 1.0
            var newDensity = 2 + (arcProgress * 198); // 2Hz to 200Hz
            var newAtk = 2.0 - (arcProgress * 1.8); // 2.0s down to 0.2s
            var newSweep = 40 + (arcProgress * 300); // 40Hz up to 340Hz

            Ndef(\vaultSwarm).xset(\grainDensity, newDensity);
            // Choking the ferryman's oars
            Pbindef(\ferryman, \atk, newAtk, \sweepEnd, newSweep);

            3.wait;
        };

        "2:12.0 - [Cue 4: Phosphorus & Shrapnel (CLIMAX)]".postln;
        Pbindef(\ferryman).stop; // SPOTLIGHT RULE: Low end muted
        Ndef(\masterMix).set(\wet10, 0.8); // Ruin Distortion ON

        Pbindef(\raidSeq,
            \instrument, \shrapnel,
            \out, ~synthBus,
            \dur, Pwrand([0.125, 0.0625], [0.7, 0.3], inf), // Frantic 16th/32nd notes
            \freq, Pexprand(1000, 6000, inf),
            \foldAmount, Pwhite(0.1, 1.0, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, 0.65
        ).play;

        // ACTIVE WAIT: 43 seconds total
        10.do {
            Ndef(\vaultSwarm).xset(\grainDensity, rrand(150, 300));
            4.3.wait;
        };

        "2:55.0 - [Cue 5: Silver Gelatin (THE LONG FADE)]".postln;
        // INSTANT TERMINATION OF KINETIC ENERGY
        Pbindef.removeAll;

        // Sudden ghostly recall of the copper panel
        Ndef(\goldenCopper).fadeTime = 0.1;
        Ndef(\goldenCopper).set(\amp, 0.4, \modalDecay, 8, \filterFreq, 8000); // Cold, hollow
        Ndef(\masterMix).set(\wet10, 0); // Distortion INSTANTLY OFF
        Ndef(\masterMix).set(\wet20, 0.8); // Abyss Reverb ON for the wash

        0.1.wait; // Micro-wait to let the recall hit the reverb bus

        // Strict 22-second fade out of all textures
        Ndef.clear(22);

        21.9.wait;

        "3:17.0 - [Absolute Silence. Score Complete.]".postln;
        Tdef.removeAll;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: 2026-10-07_11-27-02.scd [Block 2]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & LATENCY
// KEYWORDS: beakClatter, bpf, clatterSeq, compose, configuration, diskRecorder, freeverb2, global, gullCluster, hpf, latency, masterMix, ringz, rlpf, safetyLimiter, saw, seaBreeze, seagullCry, squallBurst, subDescent, wingFlap, wingSeq
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & LATENCY
    // --------------------------------------------------------------------
    s.latency = 0.2;
    ~enableRecording = false; // Fallback state (set to true to record multitrack)

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & MULTITRACK RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Gaivotas_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        seagull: Bus.audio(s, 2),
        beak:    Bus.audio(s, 2),
        wing:    Bus.audio(s, 2),
        breeze:  Bus.audio(s, 2),
        squall:  Bus.audio(s, 2),
        master:  0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig;
        sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------

    // Avian FM Call / Cry
    SynthDef(\seagullCry, {
        |out=0, recOut=0, fStart=1600, fMid=2900, fEnd=1400, dur=0.6,
         modIndexStart=0.3, modIndexMid=3.2, modIndexEnd=0.1, modRatio=1.414,
         vibRate=8, vibDepth=25, lpfFreq=16000, amp=0.25, pan=0|

        var env, pEnv, mEnv, mod, sig, vibrato, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.08 * dur, 0.42 * dur, 0.5 * dur], [-3, -1, -4]), doneAction: 2);
        pEnv = EnvGen.ar(Env([fStart, fMid, fEnd], [0.35 * dur, 0.65 * dur], [3, -3]));
        mEnv = EnvGen.ar(Env([modIndexStart, modIndexMid, modIndexEnd], [0.3 * dur, 0.7 * dur], [2, -2]));

        vibrato = SinOsc.ar(vibRate) * vibDepth;
        mod = SinOsc.ar((pEnv + vibrato) * modRatio) * (pEnv * mEnv);
        sig = SinOsc.ar(pEnv + vibrato + mod);
        sig = LPF.ar(sig, lpfFreq.clip(200, 19000));
        sig = sig * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Brittle Beak Clatter (Dual Resonator Impulse)
    SynthDef(\beakClatter, {
        |out=0, recOut=0, freq1=2500, freq2=3850, decayTime=0.035, amp=0.28, pan=0|
        var env, exciter, r1, r2, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.0005, decayTime + 0.02), doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003));
        r1 = Ringz.ar(exciter, freq1, decayTime);
        r2 = Ringz.ar(exciter, freq2, decayTime * 0.75);
        sig = (r1 + (r2 * 0.7)) * env * amp;
        sig = HPF.ar(sig, 800);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Wing Flap (Subtractive Low-frequency Swoosh)
    SynthDef(\wingFlap, {
        |out=0, recOut=0, dur=0.38, fStart=420, fEnd=55, rq=0.45, amp=0.35, pan=0|
        var env, fEnv, noise, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.02, dur, 1, -4), doneAction: 2);
        fEnv = XLine.ar(fStart, fEnd, dur);
        noise = PinkNoise.ar;
        sig = BPF.ar(noise, fEnv, rq) * 4.0;
        sig = (sig * 1.5).tanh * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Granular Squall Burst
    SynthDef(\squallBurst, {
        |out=0, recOut=0, dur=0.5, density=180, centerFreq=3200, amp=0.3, pan=0|
        var env, trigs, freqs, grains, finalSig;

        env = EnvGen.ar(Env.sine(dur), doneAction: 2);
        trigs = Dust.ar(density);
        freqs = TRand.ar(centerFreq * 0.5, centerFreq * 1.8, trigs);
        grains = Ringz.ar(trigs, freqs, TRand.ar(0.002, 0.015, trigs));
        grains = grains * env * amp;

        finalSig = Pan2.ar(grains, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Sub-Audible Edge Descent (Cue 19: 300 Hz -> 20 Hz Flutter)
    SynthDef(\subDescent, {
        |out=0, recOut=0, dur=9.0, startFreq=300, endFreq=20, amp=0.28, pan=0|
        var env, fEnv, flutterRate, flutter, sig, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.9, 0], [0.5, dur - 1.5, 1.0], [2, 0, -3]), doneAction: 2);
        fEnv = XLine.ar(startFreq, endFreq, dur);
        flutterRate = XLine.ar(8, 28, dur);
        flutter = LFPulse.ar(flutterRate, 0, 0.45);
        sig = SinOsc.ar(fEnv) + (Saw.ar(fEnv * 2) * 0.2);
        sig = (sig * flutter) * env * amp;
        sig = LeakDC.ar(sig);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & JITLIB ROUTING
    // --------------------------------------------------------------------

    // Littoral Atmosphere (Sea Breeze & Coastal Wash)
    Ndef(\seaBreeze, {
        |amp=0.0, lpf=8000, hpf=60, gust=0.0, modRate=0.12|
        var pNoise, bNoise, lfo1, lfo2, res1, res2, sig;

        pNoise = PinkNoise.ar;
        bNoise = BrownNoise.ar;

        lfo1 = LFNoise2.kr(modRate).exprange(250, 1400);
        lfo2 = LFNoise2.kr(modRate * 1.4).exprange(800, 3200);

        res1 = Resonz.ar(pNoise, lfo1, 0.35) * 2.2;
        res2 = Resonz.ar(bNoise, lfo2, 0.45) * 1.8;

        sig = (pNoise * 0.3) + res1 + res2;
        sig = sig + (WhiteNoise.ar * gust * LFNoise1.kr(4).range(0.2, 1.0));
        sig = RLPF.ar(sig, lpf.clip(100, 18000), 0.7);
        sig = HPF.ar(sig, hpf.clip(20, 1000));

        sig * amp;
    });
    Ndef(\seaBreeze).play(~recBuses.breeze);

    // Master Aggregator & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths, continuousBreeze;
        discreteSynths = In.ar(~synthBus, 2);
        continuousBreeze = Ndef.ar(\seaBreeze, 2);
        discreteSynths + continuousBreeze;
    });

    // Slot 10: Dynamic Littoral Reverb (Crossfader automatically governed by \wet10)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.32);
    };
    Ndef(\masterMix).set(\wet10, 0.25);

    Ndef(\masterMix).play(0);

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp, path;
        timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Destination: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        s.sync;

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING MULTITRACK AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Closed Successfully.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: 2:00.0 Exact Duration)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK MODE (RECORDING DISABLED) ---".postln;
        };

        // 0:00.0 — [Cue 1: Initial Breath & Avian Impulse (2.5s)]
        "0:00.0 - [Cue 1: Initial Breath & Avian Impulse]".postln;
        0.5.wait;
        Ndef(\masterMix).set(\wet10, 0.3);
        Ndef(\seaBreeze).fadeTime = 1.0;
        Ndef(\seaBreeze).xset(\amp, -18.dbamp, \lpf, 4500, \hpf, 80, \gust, 0.0);

        0.7.wait;
        // Solitary sharp seagull call at 0:01.2
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 0.75, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.25, \pan, 0.1
        ]);

        1.3.wait;

        // 0:02.5 — [Cue 2: Solitary Glissando Spike (2.5s)]
        "0:02.5 - [Cue 2: Solitary Glissando Spike]".postln;
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 1.8, \modIndexStart, 0.5, \modIndexMid, 4.2, \modIndexEnd, 0.3,
            \vibRate, 14, \vibDepth, 80, \amp, 0.3, \pan, -0.3
        ]);

        2.5.wait;

        // 0:05.0 — [Cue 3: The Saline Void (Form Operation C, 9.5s)]
        "0:05.0 - [Cue 3: The Saline Void (Abrupt cut to low-complexity rumble)]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.28, \lpf, 180, \hpf, 30, \gust, 0.0);

        // Active Wait: 9.5 seconds divided into micro-shifts
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.04));
            3.0.wait;
        };
        0.5.wait;

        // 0:14.5 — [Cue 4: Hyper-Kinetic Beak Clatter (1.7s)]
        "0:14.5 - [Cue 4: Hyper-Kinetic Beak Clatter]".postln;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.02); // Spotlight rule: duck wind
        Ndef(\masterMix).set(\wet10, 0.05); // Bone-dry space

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, Pseq([0.05, 0.04, 0.06, 0.035, 0.055], inf),
            \freq1, Pexprand(2200, 3400, inf),
            \freq2, Pexprand(3500, 5200, inf),
            \decayTime, Pwhite(0.015, 0.04, inf),
            \amp, Pwhite(0.22, 0.32, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        1.7.wait;

        // 0:16.2 — [Cue 5: Swelling Wingbeat Resonances (7.8s)]
        "0:16.2 - [Cue 5: Swelling Wingbeat Resonances]".postln;
        Pbindef(\clatterSeq).stop;

        Ndef(\masterMix).set(\wet10, 0.35);
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.22, \lpf, 3500, \hpf, 80);

        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, Pseq([0.38, 0.32, 0.28, 0.24, 0.22, 0.20, 0.18, 0.16, 0.16], inf),
            \durFlap, 0.3,
            \fStart, Pseries(300, 15, inf).clip(300, 550),
            \fEnd, 55,
            \amp, Pseries(0.22, 0.015, inf).clip(0.22, 0.38),
            \pan, Pseq([-0.4, 0.4, -0.2, 0.2], inf)
        ).play;

        // Active Wait: 7.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2000 + (i * 600));
            1.95.wait;
        };

        // 0:24.0 — [Cue 6: Violent Wind Shear (2.5s)]
        "0:24.0 - [Cue 6: Violent Wind Shear]".postln;
        Pbindef(\wingSeq).stop; // Mute wing flaps instantly
        Ndef(\masterMix).set(\wet10, 0.15);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.45, \lpf, 9000, \hpf, 120, \gust, 0.85);

        2.5.wait;

        // 0:26.5 — [Cue 7: Pitch Ceiling Cry Arc (Form Operation B, 9.5s)]
        "0:26.5 - [Cue 7: Pitch Ceiling Cry Arc (Ascending toward Nyquist/Ceiling)]".postln;
        Ndef(\seaBreeze).fadeTime = 1.5;
        Ndef(\seaBreeze).xset(\amp, 0.1, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.35);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.45, 0.4, 0.35, 0.3, 0.28, 0.25, 0.22, 0.2, 0.18], inf),
            \fStart, Pseries(2000, 380, inf).clip(2000, 11500),
            \fMid, Pseries(2800, 420, inf).clip(2800, 13000),
            \fEnd, Pseries(1900, 360, inf).clip(1900, 11000),
            \durCall, 0.32,
            \modIndexMid, Pseries(2.0, 0.3, inf).clip(2.0, 7.5),
            \amp, Pseries(0.2, 0.012, inf).clip(0.2, 0.34),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active Wait: 9.5 seconds
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.35 + (i * 0.05));
            2.375.wait;
        };

        // 0:36.0 — [Cue 8: Dry Staccato Snap (1.2s)]
        "0:36.0 - [Cue 8: Dry Staccato Snap (Sudden subtraction)]".postln;
        Pbindef(\gullCluster).stop; // INSTANT SUBTRACTION
        Ndef(\masterMix).set(\wet10, 0.02);

        // 3 dry beak snaps
        3.do { |i|
            Synth(\beakClatter, [
                \out, ~synthBus,
                \recOut, ~recBuses.beak,
                \freq1, 2600 + (i * 400),
                \freq2, 4100 + (i * 300),
                \decayTime, 0.025,
                \amp, 0.36,
                \pan, (i - 1) * 0.4
            ]);
            0.4.wait;
        };

        // 0:37.2 — [Cue 9: Sub-Aquatic Murmur & Muffled Glides (9.8s)]
        "0:37.2 - [Cue 9: Sub-Aquatic Murmur & Muffled Glides]".postln;
        Ndef(\masterMix).set(\wet10, 0.8); // Deep resonant space
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.3, \lpf, 450, \hpf, 40, \gust, 0.0);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([2.2, 2.8, 3.2], inf),
            \fStart, Pseq([700, 850, 620], inf),
            \fMid, Pseq([1100, 1250, 950], inf),
            \fEnd, Pseq([550, 600, 480], inf),
            \durCall, 1.8,
            \lpfFreq, 900,
            \modIndexMid, 1.5,
            \amp, 0.22,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 9.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 380 + (i * 40));
            2.45.wait;
        };

        // 0:47.0 — [Cue 10: Aggressive Territorial Dart (2.5s)]
        "0:47.0 - [Cue 10: Aggressive Territorial Dart]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.1;
        Ndef(\seaBreeze).xset(\amp, 0.05);

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.07,
            \freq1, Pwhite(2800, 4200, inf),
            \freq2, Pwhite(4500, 6000, inf),
            \decayTime, 0.02,
            \amp, 0.28,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Rapid downward shrieks
        fork {
            3.do { |i|
                Synth(\seagullCry, [
                    \out, ~synthBus,
                    \recOut, ~recBuses.seagull,
                    \fStart, 4200 - (i * 400),
                    \fMid, 3500 - (i * 300),
                    \fEnd, 1100,
                    \dur, 0.55,
                    \modIndexMid, 4.5,
                    \vibRate, 16,
                    \amp, 0.28,
                    \pan, (i.even.if(0.5, -0.5))
                ]);
                0.7.wait;
            };
        };

        2.5.wait;

        // 0:49.5 — [Cue 11: Mid-Air Stasis (2.0s)]
        "0:49.5 - [Cue 11: Mid-Air Stasis]".postln;
        Pbindef(\clatterSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.65); // Pure suspended reverberation

        // Single sustained crystalline tone
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 2400, \fMid, 2400, \fEnd, 2400,
            \dur, 1.9, \modIndexStart, 0.0, \modIndexMid, 0.0, \modIndexEnd, 0.0,
            \vibRate, 0, \vibDepth, 0, \amp, 0.24, \pan, 0
        ]);

        2.0.wait;

        // 0:51.5 — [Cue 12: Microtonal Polyphonic Choir (10.5s)]
        "0:51.5 - [Cue 12: Microtonal Polyphonic Choir]".postln;
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.18, \lpf, 4000, \hpf, 70);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.35, 0.55, 0.4, 0.7, 0.3], inf),
            \fStart, Pseq([1760, 1845, 1920, 2030, 2150, 2270, 2390], inf),
            \fMid, Pseq([2400, 2520, 2610, 2780, 2900, 3050, 3180], inf),
            \fEnd, Pseq([1650, 1720, 1800, 1910, 2010, 2120, 2220], inf),
            \durCall, Pwhite(0.5, 0.9, inf),
            \modIndexMid, Pwhite(1.2, 2.8, inf),
            \amp, 0.2,
            \pan, Pseq([-0.7, -0.3, 0.0, 0.3, 0.7, 0.4, -0.4], inf)
        ).play;

        // Active Wait: 10.5 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.1 + (i * 0.05));
            3.5.wait;
        };

        // 1:02.0 — [Cue 13: Granular Squall Interruption (2.8s)]
        "1:02.0 - [Cue 13: Granular Squall Interruption]".postln;
        Pbindef(\gullCluster).stop; // Mute colony
        Ndef(\masterMix).set(\wet10, 0.2);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.7);

        Synth(\squallBurst, [
            \out, ~synthBus,
            \recOut, ~recBuses.squall,
            \dur, 2.5,
            \density, 240,
            \centerFreq, 3800,
            \amp, 0.32,
            \pan, 0
        ]);

        2.8.wait;

        // 1:04.8 — [Cue 14: Salt Drift & Resonant Breakers (9.2s)]
        "1:04.8 - [Cue 14: Salt Drift & Resonant Breakers]".postln;
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.26, \lpf, 3200, \hpf, 50, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.55);

        // Distant echoing gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([3.0, 3.2, 2.8], inf),
            \fStart, Pseq([1900, 2200, 1750], inf),
            \fMid, Pseq([2700, 3100, 2400], inf),
            \fEnd, Pseq([1600, 1850, 1450], inf),
            \durCall, 1.4,
            \modIndexMid, 1.8,
            \amp, 0.18,
            \pan, Pseq([0.6, -0.6, 0.3], inf)
        ).play;

        // Active Wait: 9.2 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2800 + (i * 200));
            2.3.wait;
        };

        // 1:14.0 — [Cue 15: Metallic Chirp Jolt (1.8s)]
        "1:14.0 - [Cue 15: Metallic Chirp Jolt]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.15);

        // 3 high-index FM transient chirps at 0.0s, 0.4s, 0.7s
        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 3800, \fMid, 5200, \fEnd, 2900, \dur, 0.22,
            \modIndexMid, 6.0, \amp, 0.26, \pan, -0.5
        ]);
        0.4.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4200, \fMid, 5600, \fEnd, 3200, \dur, 0.2,
            \modIndexMid, 6.8, \amp, 0.28, \pan, 0.5
        ]);
        0.3.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4600, \fMid, 6100, \fEnd, 3600, \dur, 0.25,
            \modIndexMid, 7.5, \amp, 0.3, \pan, 0.0
        ]);
        1.1.wait;

        // 1:15.8 — [Cue 16: Return to Point of Departure (Form Operation A, 10.7s)]
        "1:15.8 - [Cue 16: Return to Point of Departure (Restatement of Opening Solitary Motif)]".postln;
        Ndef(\masterMix).set(\wet10, 0.65); // Rich spatial envelopment
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.2, \lpf, 4000, \hpf, 70, \gust, 0.0);

        // Solitary Opening Motif restatement
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 1.2, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.26, \pan, 0.0
        ]);

        2.5.wait;

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 2.0, \modIndexStart, 0.4, \modIndexMid, 3.8, \modIndexEnd, 0.2,
            \vibRate, 12, \vibDepth, 60, \amp, 0.28, \pan, -0.2
        ]);

        // Active Wait remaining: 8.2 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.03));
            2.73.wait;
        };

        // 1:26.5 — [Cue 17: Frenzied Feeding Swarm Climax (3.5s)]
        "1:26.5 - [Cue 17: Frenzied Feeding Swarm Climax]".postln;
        Ndef(\masterMix).set(\wet10, 0.25);
        Ndef(\seaBreeze).fadeTime = 0.5;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.5);

        // Layer 1: Frantic gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.16, 0.14, 0.2, 0.15], inf),
            \fStart, Pexprand(1800, 3600, inf),
            \fMid, Pexprand(3500, 5800, inf),
            \fEnd, Pexprand(1400, 2800, inf),
            \durCall, 0.25,
            \modIndexMid, 4.0,
            \amp, 0.28,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Layer 2: Rapid beak clattering
        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.06,
            \freq1, Pexprand(2500, 4000, inf),
            \freq2, Pexprand(4200, 6200, inf),
            \decayTime, 0.02,
            \amp, 0.24,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Layer 3: Flapping
        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, 0.18,
            \durFlap, 0.2,
            \fStart, 480, \fEnd, 60,
            \amp, 0.28,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.5.wait;

        // 1:30.0 — [Cue 18: Hard Vacuum Cut (2.0s)]
        "1:30.0 - [Cue 18: Hard Vacuum Cut (Instant subtraction)]".postln;
        Pbindef(\gullCluster).stop;
        Pbindef(\clatterSeq).stop;
        Pbindef(\wingSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.75); // Reverb tail hangs alone

        2.0.wait;

        // 1:32.0 — [Cue 19: Descent to Sub-Audible Edge (Form Operation B, 9.5s)]
        "1:32.0 - [Cue 19: Descent to Sub-Audible Edge (300 Hz to 20 Hz)]".postln;
        Ndef(\masterMix).set(\wet10, 0.2);

        Synth(\subDescent, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, 9.0,
            \startFreq, 300,
            \endFreq, 20,
            \amp, 0.32,
            \pan, 0
        ]);

        // Active Wait: 9.5 seconds
        3.do { |i|
            Ndef(\masterMix).set(\wet10, 0.2 + (i * 0.1));
            3.16.wait;
        };

        // 1:41.5 — [Cue 20: Ghost Squawk Fragment (2.5s)]
        "1:41.5 - [Cue 20: Ghost Squawk Fragment]".postln;
        Ndef(\masterMix).set(\wet10, 0.85);

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 4500, \fMid, 4700, \fEnd, 4300,
            \dur, 0.4, \modIndexMid, 0.4,
            \lpfFreq, 5000, \amp, 0.12, \pan, 0.2
        ]);

        2.5.wait;

        // 1:44.0 — [Cue 21: Total Evacuation & Dissolution (Form Operation D, 16.0s)]
        "1:44.0 - [Cue 21: Total Evacuation & Dissolution]".postln;

        // Stop all discrete event generation
        Pbindef.all.do(_.stop);

        // 12-second fade-out on all continuous sound proxies
        Ndef(\seaBreeze).fadeTime = 12.0;
        Ndef(\seaBreeze).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 12.0;
        Ndef(\masterMix).xset(\wet10, 0.0);

        // Stop recording before audio stream vanishes
        if(~enableRecording) {
            ~stopRecording.value;
        };

        // Active Wait through the 12-second decay
        4.do {
            3.0.wait;
        };

        // 1:56.0 - 2:00.0: Final evacuation & hard clearance
        "1:56.0 - Final clearing of proxies and nodes...".postln;
        Ndef.clear(3.0);
        4.0.wait;

        "2:00.0 - Score Complete. Total Silence.".postln;
        Pbindef.removeAll;
        Tdef.removeAll;
    });

    s.sync;

    // Start Master Score
    Tdef(\masterScore).play;

});

s.makeGui;
)

// Source: 2026-10-07_11-27-02.scd [Block 9]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & LATENCY
// KEYWORDS: beakClatter, bpf, clatterSeq, compose, configuration, diskRecorder, freeverb2, global, gullCluster, hpf, latency, masterMix, ringz, rlpf, safetyLimiter, saw, seaBreeze, seagullCry, squallBurst, subDescent, wingFlap, wingSeq
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & LATENCY
    // --------------------------------------------------------------------
    s.latency = 0.2;
    ~enableRecording = false; // Fallback state (set to true to record multitrack)

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & MULTITRACK RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Gaivotas_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        seagull: Bus.audio(s, 2),
        beak:    Bus.audio(s, 2),
        wing:    Bus.audio(s, 2),
        breeze:  Bus.audio(s, 2),
        squall:  Bus.audio(s, 2),
        master:  0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig;
        sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------

    // Avian FM Call / Cry
    SynthDef(\seagullCry, {
        |out=0, recOut=0, fStart=1600, fMid=2900, fEnd=1400, dur=0.6,
         modIndexStart=0.3, modIndexMid=3.2, modIndexEnd=0.1, modRatio=1.414,
         vibRate=8, vibDepth=25, lpfFreq=16000, amp=0.25, pan=0|

        var env, pEnv, mEnv, mod, sig, vibrato, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.08 * dur, 0.42 * dur, 0.5 * dur], [-3, -1, -4]), doneAction: 2);
        pEnv = EnvGen.ar(Env([fStart, fMid, fEnd], [0.35 * dur, 0.65 * dur], [3, -3]));
        mEnv = EnvGen.ar(Env([modIndexStart, modIndexMid, modIndexEnd], [0.3 * dur, 0.7 * dur], [2, -2]));

        vibrato = SinOsc.ar(vibRate) * vibDepth;
        mod = SinOsc.ar((pEnv + vibrato) * modRatio) * (pEnv * mEnv);
        sig = SinOsc.ar(pEnv + vibrato + mod);
        sig = LPF.ar(sig, lpfFreq.clip(200, 19000));
        sig = sig * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Brittle Beak Clatter (Dual Resonator Impulse)
    SynthDef(\beakClatter, {
        |out=0, recOut=0, freq1=2500, freq2=3850, decayTime=0.035, amp=0.28, pan=0|
        var env, exciter, r1, r2, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.0005, decayTime + 0.02), doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003));
        r1 = Ringz.ar(exciter, freq1, decayTime);
        r2 = Ringz.ar(exciter, freq2, decayTime * 0.75);
        sig = (r1 + (r2 * 0.7)) * env * amp;
        sig = HPF.ar(sig, 800);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Wing Flap (Subtractive Low-frequency Swoosh)
    SynthDef(\wingFlap, {
        |out=0, recOut=0, dur=0.38, fStart=420, fEnd=55, rq=0.45, amp=0.35, pan=0|
        var env, fEnv, noise, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.02, dur, 1, -4), doneAction: 2);
        fEnv = XLine.ar(fStart, fEnd, dur);
        noise = PinkNoise.ar;
        sig = BPF.ar(noise, fEnv, rq) * 4.0;
        sig = (sig * 1.5).tanh * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Granular Squall Burst
    SynthDef(\squallBurst, {
        |out=0, recOut=0, dur=0.5, density=180, centerFreq=3200, amp=0.3, pan=0|
        var env, trigs, freqs, grains, finalSig;

        env = EnvGen.ar(Env.sine(dur), doneAction: 2);
        trigs = Dust.ar(density);
        freqs = TRand.ar(centerFreq * 0.5, centerFreq * 1.8, trigs);
        grains = Ringz.ar(trigs, freqs, TRand.ar(0.002, 0.015, trigs));
        grains = grains * env * amp;

        finalSig = Pan2.ar(grains, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Sub-Audible Edge Descent (Cue 19: 300 Hz -> 20 Hz Flutter)
    SynthDef(\subDescent, {
        |out=0, recOut=0, dur=9.0, startFreq=300, endFreq=20, amp=0.28, pan=0|
        var env, fEnv, flutterRate, flutter, sig, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.9, 0], [0.5, dur - 1.5, 1.0], [2, 0, -3]), doneAction: 2);
        fEnv = XLine.ar(startFreq, endFreq, dur);
        flutterRate = XLine.ar(8, 28, dur);
        flutter = LFPulse.ar(flutterRate, 0, 0.45);
        sig = SinOsc.ar(fEnv) + (Saw.ar(fEnv * 2) * 0.2);
        sig = (sig * flutter) * env * amp;
        sig = LeakDC.ar(sig);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & JITLIB ROUTING
    // --------------------------------------------------------------------

    // Littoral Atmosphere (Sea Breeze & Coastal Wash)
    Ndef(\seaBreeze, {
        |amp=0.0, lpf=8000, hpf=60, gust=0.0, modRate=0.12|
        var pNoise, bNoise, lfo1, lfo2, res1, res2, sig;

        pNoise = PinkNoise.ar;
        bNoise = BrownNoise.ar;

        lfo1 = LFNoise2.kr(modRate).exprange(250, 1400);
        lfo2 = LFNoise2.kr(modRate * 1.4).exprange(800, 3200);

        res1 = Resonz.ar(pNoise, lfo1, 0.35) * 2.2;
        res2 = Resonz.ar(bNoise, lfo2, 0.45) * 1.8;

        sig = (pNoise * 0.3) + res1 + res2;
        sig = sig + (WhiteNoise.ar * gust * LFNoise1.kr(4).range(0.2, 1.0));
        sig = RLPF.ar(sig, lpf.clip(100, 18000), 0.7);
        sig = HPF.ar(sig, hpf.clip(20, 1000));

        sig * amp;
    });
    Ndef(\seaBreeze).play(~recBuses.breeze);

    // Master Aggregator & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths, continuousBreeze;
        discreteSynths = In.ar(~synthBus, 2);
        continuousBreeze = Ndef.ar(\seaBreeze, 2);
        discreteSynths + continuousBreeze;
    });

    // Slot 10: Dynamic Littoral Reverb (Crossfader automatically governed by \wet10)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.32);
    };
    Ndef(\masterMix).set(\wet10, 0.25);

    Ndef(\masterMix).play(0);

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp, path;
        timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Destination: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        s.sync;

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING MULTITRACK AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Closed Successfully.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: 2:00.0 Exact Duration)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK MODE (RECORDING DISABLED) ---".postln;
        };

        // 0:00.0 — [Cue 1: Initial Breath & Avian Impulse (2.5s)]
        "0:00.0 - [Cue 1: Initial Breath & Avian Impulse]".postln;
        0.5.wait;
        Ndef(\masterMix).set(\wet10, 0.3);
        Ndef(\seaBreeze).fadeTime = 1.0;
        Ndef(\seaBreeze).xset(\amp, -18.dbamp, \lpf, 4500, \hpf, 80, \gust, 0.0);

        0.7.wait;
        // Solitary sharp seagull call at 0:01.2
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 0.75, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.25, \pan, 0.1
        ]);

        1.3.wait;

        // 0:02.5 — [Cue 2: Solitary Glissando Spike (2.5s)]
        "0:02.5 - [Cue 2: Solitary Glissando Spike]".postln;
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 1.8, \modIndexStart, 0.5, \modIndexMid, 4.2, \modIndexEnd, 0.3,
            \vibRate, 14, \vibDepth, 80, \amp, 0.3, \pan, -0.3
        ]);

        2.5.wait;

        // 0:05.0 — [Cue 3: The Saline Void (Form Operation C, 9.5s)]
        "0:05.0 - [Cue 3: The Saline Void (Abrupt cut to low-complexity rumble)]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.28, \lpf, 180, \hpf, 30, \gust, 0.0);

        // Active Wait: 9.5 seconds divided into micro-shifts
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.04));
            3.0.wait;
        };
        0.5.wait;

        // 0:14.5 — [Cue 4: Hyper-Kinetic Beak Clatter (1.7s)]
        "0:14.5 - [Cue 4: Hyper-Kinetic Beak Clatter]".postln;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.02); // Spotlight rule: duck wind
        Ndef(\masterMix).set(\wet10, 0.05); // Bone-dry space

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, Pseq([0.05, 0.04, 0.06, 0.035, 0.055], inf),
            \freq1, Pexprand(2200, 3400, inf),
            \freq2, Pexprand(3500, 5200, inf),
            \decayTime, Pwhite(0.015, 0.04, inf),
            \amp, Pwhite(0.22, 0.32, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        1.7.wait;

        // 0:16.2 — [Cue 5: Swelling Wingbeat Resonances (7.8s)]
        "0:16.2 - [Cue 5: Swelling Wingbeat Resonances]".postln;
        Pbindef(\clatterSeq).stop;

        Ndef(\masterMix).set(\wet10, 0.35);
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.22, \lpf, 3500, \hpf, 80);

        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, Pseq([0.38, 0.32, 0.28, 0.24, 0.22, 0.20, 0.18, 0.16, 0.16], inf),
            \durFlap, 0.3,
            \fStart, Pseries(300, 15, inf).clip(300, 550),
            \fEnd, 55,
            \amp, Pseries(0.22, 0.015, inf).clip(0.22, 0.38),
            \pan, Pseq([-0.4, 0.4, -0.2, 0.2], inf)
        ).play;

        // Active Wait: 7.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2000 + (i * 600));
            1.95.wait;
        };

        // 0:24.0 — [Cue 6: Violent Wind Shear (2.5s)]
        "0:24.0 - [Cue 6: Violent Wind Shear]".postln;
        Pbindef(\wingSeq).stop; // Mute wing flaps instantly
        Ndef(\masterMix).set(\wet10, 0.15);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.45, \lpf, 9000, \hpf, 120, \gust, 0.85);

        2.5.wait;

        // 0:26.5 — [Cue 7: Pitch Ceiling Cry Arc (Form Operation B, 9.5s)]
        "0:26.5 - [Cue 7: Pitch Ceiling Cry Arc (Ascending toward Nyquist/Ceiling)]".postln;
        Ndef(\seaBreeze).fadeTime = 1.5;
        Ndef(\seaBreeze).xset(\amp, 0.1, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.35);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.45, 0.4, 0.35, 0.3, 0.28, 0.25, 0.22, 0.2, 0.18], inf),
            \fStart, Pseries(2000, 380, inf).clip(2000, 11500),
            \fMid, Pseries(2800, 420, inf).clip(2800, 13000),
            \fEnd, Pseries(1900, 360, inf).clip(1900, 11000),
            \durCall, 0.32,
            \modIndexMid, Pseries(2.0, 0.3, inf).clip(2.0, 7.5),
            \amp, Pseries(0.2, 0.012, inf).clip(0.2, 0.34),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active Wait: 9.5 seconds
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.35 + (i * 0.05));
            2.375.wait;
        };

        // 0:36.0 — [Cue 8: Dry Staccato Snap (1.2s)]
        "0:36.0 - [Cue 8: Dry Staccato Snap (Sudden subtraction)]".postln;
        Pbindef(\gullCluster).stop; // INSTANT SUBTRACTION
        Ndef(\masterMix).set(\wet10, 0.02);

        // 3 dry beak snaps
        3.do { |i|
            Synth(\beakClatter, [
                \out, ~synthBus,
                \recOut, ~recBuses.beak,
                \freq1, 2600 + (i * 400),
                \freq2, 4100 + (i * 300),
                \decayTime, 0.025,
                \amp, 0.36,
                \pan, (i - 1) * 0.4
            ]);
            0.4.wait;
        };

        // 0:37.2 — [Cue 9: Sub-Aquatic Murmur & Muffled Glides (9.8s)]
        "0:37.2 - [Cue 9: Sub-Aquatic Murmur & Muffled Glides]".postln;
        Ndef(\masterMix).set(\wet10, 0.8); // Deep resonant space
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.3, \lpf, 450, \hpf, 40, \gust, 0.0);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([2.2, 2.8, 3.2], inf),
            \fStart, Pseq([700, 850, 620], inf),
            \fMid, Pseq([1100, 1250, 950], inf),
            \fEnd, Pseq([550, 600, 480], inf),
            \durCall, 1.8,
            \lpfFreq, 900,
            \modIndexMid, 1.5,
            \amp, 0.22,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 9.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 380 + (i * 40));
            2.45.wait;
        };

        // 0:47.0 — [Cue 10: Aggressive Territorial Dart (2.5s)]
        "0:47.0 - [Cue 10: Aggressive Territorial Dart]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.1;
        Ndef(\seaBreeze).xset(\amp, 0.05);

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.07,
            \freq1, Pwhite(2800, 4200, inf),
            \freq2, Pwhite(4500, 6000, inf),
            \decayTime, 0.02,
            \amp, 0.28,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Rapid downward shrieks
        fork {
            3.do { |i|
                Synth(\seagullCry, [
                    \out, ~synthBus,
                    \recOut, ~recBuses.seagull,
                    \fStart, 4200 - (i * 400),
                    \fMid, 3500 - (i * 300),
                    \fEnd, 1100,
                    \dur, 0.55,
                    \modIndexMid, 4.5,
                    \vibRate, 16,
                    \amp, 0.28,
                    \pan, (i.even.if(0.5, -0.5))
                ]);
                0.7.wait;
            };
        };

        2.5.wait;

        // 0:49.5 — [Cue 11: Mid-Air Stasis (2.0s)]
        "0:49.5 - [Cue 11: Mid-Air Stasis]".postln;
        Pbindef(\clatterSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.65); // Pure suspended reverberation

        // Single sustained crystalline tone
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 2400, \fMid, 2400, \fEnd, 2400,
            \dur, 1.9, \modIndexStart, 0.0, \modIndexMid, 0.0, \modIndexEnd, 0.0,
            \vibRate, 0, \vibDepth, 0, \amp, 0.24, \pan, 0
        ]);

        2.0.wait;

        // 0:51.5 — [Cue 12: Microtonal Polyphonic Choir (10.5s)]
        "0:51.5 - [Cue 12: Microtonal Polyphonic Choir]".postln;
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.18, \lpf, 4000, \hpf, 70);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.35, 0.55, 0.4, 0.7, 0.3], inf),
            \fStart, Pseq([1760, 1845, 1920, 2030, 2150, 2270, 2390], inf),
            \fMid, Pseq([2400, 2520, 2610, 2780, 2900, 3050, 3180], inf),
            \fEnd, Pseq([1650, 1720, 1800, 1910, 2010, 2120, 2220], inf),
            \durCall, Pwhite(0.5, 0.9, inf),
            \modIndexMid, Pwhite(1.2, 2.8, inf),
            \amp, 0.2,
            \pan, Pseq([-0.7, -0.3, 0.0, 0.3, 0.7, 0.4, -0.4], inf)
        ).play;

        // Active Wait: 10.5 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.1 + (i * 0.05));
            3.5.wait;
        };

        // 1:02.0 — [Cue 13: Granular Squall Interruption (2.8s)]
        "1:02.0 - [Cue 13: Granular Squall Interruption]".postln;
        Pbindef(\gullCluster).stop; // Mute colony
        Ndef(\masterMix).set(\wet10, 0.2);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.7);

        Synth(\squallBurst, [
            \out, ~synthBus,
            \recOut, ~recBuses.squall,
            \dur, 2.5,
            \density, 240,
            \centerFreq, 3800,
            \amp, 0.32,
            \pan, 0
        ]);

        2.8.wait;

        // 1:04.8 — [Cue 14: Salt Drift & Resonant Breakers (9.2s)]
        "1:04.8 - [Cue 14: Salt Drift & Resonant Breakers]".postln;
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.26, \lpf, 3200, \hpf, 50, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.55);

        // Distant echoing gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([3.0, 3.2, 2.8], inf),
            \fStart, Pseq([1900, 2200, 1750], inf),
            \fMid, Pseq([2700, 3100, 2400], inf),
            \fEnd, Pseq([1600, 1850, 1450], inf),
            \durCall, 1.4,
            \modIndexMid, 1.8,
            \amp, 0.18,
            \pan, Pseq([0.6, -0.6, 0.3], inf)
        ).play;

        // Active Wait: 9.2 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2800 + (i * 200));
            2.3.wait;
        };

        // 1:14.0 — [Cue 15: Metallic Chirp Jolt (1.8s)]
        "1:14.0 - [Cue 15: Metallic Chirp Jolt]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.15);

        // 3 high-index FM transient chirps at 0.0s, 0.4s, 0.7s
        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 3800, \fMid, 5200, \fEnd, 2900, \dur, 0.22,
            \modIndexMid, 6.0, \amp, 0.26, \pan, -0.5
        ]);
        0.4.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4200, \fMid, 5600, \fEnd, 3200, \dur, 0.2,
            \modIndexMid, 6.8, \amp, 0.28, \pan, 0.5
        ]);
        0.3.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4600, \fMid, 6100, \fEnd, 3600, \dur, 0.25,
            \modIndexMid, 7.5, \amp, 0.3, \pan, 0.0
        ]);
        1.1.wait;

        // 1:15.8 — [Cue 16: Return to Point of Departure (Form Operation A, 10.7s)]
        "1:15.8 - [Cue 16: Return to Point of Departure (Restatement of Opening Solitary Motif)]".postln;
        Ndef(\masterMix).set(\wet10, 0.65); // Rich spatial envelopment
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.2, \lpf, 4000, \hpf, 70, \gust, 0.0);

        // Solitary Opening Motif restatement
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 1.2, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.26, \pan, 0.0
        ]);

        2.5.wait;

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 2.0, \modIndexStart, 0.4, \modIndexMid, 3.8, \modIndexEnd, 0.2,
            \vibRate, 12, \vibDepth, 60, \amp, 0.28, \pan, -0.2
        ]);

        // Active Wait remaining: 8.2 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.03));
            2.73.wait;
        };

        // 1:26.5 — [Cue 17: Frenzied Feeding Swarm Climax (3.5s)]
        "1:26.5 - [Cue 17: Frenzied Feeding Swarm Climax]".postln;
        Ndef(\masterMix).set(\wet10, 0.25);
        Ndef(\seaBreeze).fadeTime = 0.5;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.5);

        // Layer 1: Frantic gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.16, 0.14, 0.2, 0.15], inf),
            \fStart, Pexprand(1800, 3600, inf),
            \fMid, Pexprand(3500, 5800, inf),
            \fEnd, Pexprand(1400, 2800, inf),
            \durCall, 0.25,
            \modIndexMid, 4.0,
            \amp, 0.28,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Layer 2: Rapid beak clattering
        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.06,
            \freq1, Pexprand(2500, 4000, inf),
            \freq2, Pexprand(4200, 6200, inf),
            \decayTime, 0.02,
            \amp, 0.24,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Layer 3: Flapping
        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, 0.18,
            \durFlap, 0.2,
            \fStart, 480, \fEnd, 60,
            \amp, 0.28,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.5.wait;

        // 1:30.0 — [Cue 18: Hard Vacuum Cut (2.0s)]
        "1:30.0 - [Cue 18: Hard Vacuum Cut (Instant subtraction)]".postln;
        Pbindef(\gullCluster).stop;
        Pbindef(\clatterSeq).stop;
        Pbindef(\wingSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.75); // Reverb tail hangs alone

        2.0.wait;

        // 1:32.0 — [Cue 19: Descent to Sub-Audible Edge (Form Operation B, 9.5s)]
        "1:32.0 - [Cue 19: Descent to Sub-Audible Edge (300 Hz to 20 Hz)]".postln;
        Ndef(\masterMix).set(\wet10, 0.2);

        Synth(\subDescent, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, 9.0,
            \startFreq, 300,
            \endFreq, 20,
            \amp, 0.32,
            \pan, 0
        ]);

        // Active Wait: 9.5 seconds
        3.do { |i|
            Ndef(\masterMix).set(\wet10, 0.2 + (i * 0.1));
            3.16.wait;
        };

        // 1:41.5 — [Cue 20: Ghost Squawk Fragment (2.5s)]
        "1:41.5 - [Cue 20: Ghost Squawk Fragment]".postln;
        Ndef(\masterMix).set(\wet10, 0.85);

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 4500, \fMid, 4700, \fEnd, 4300,
            \dur, 0.4, \modIndexMid, 0.4,
            \lpfFreq, 5000, \amp, 0.12, \pan, 0.2
        ]);

        2.5.wait;

        // 1:44.0 — [Cue 21: Total Evacuation & Dissolution (Form Operation D, 16.0s)]
        "1:44.0 - [Cue 21: Total Evacuation & Dissolution]".postln;

        // Stop all discrete event generation
        Pbindef.all.do(_.stop);

        // 12-second fade-out on all continuous sound proxies
        Ndef(\seaBreeze).fadeTime = 12.0;
        Ndef(\seaBreeze).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 12.0;
        Ndef(\masterMix).xset(\wet10, 0.0);

        // Stop recording before audio stream vanishes
        if(~enableRecording) {
            ~stopRecording.value;
        };

        // Active Wait through the 12-second decay
        4.do {
            3.0.wait;
        };

        // 1:56.0 - 2:00.0: Final evacuation & hard clearance
        "1:56.0 - Final clearing of proxies and nodes...".postln;
        Ndef.clear(3.0);
        4.0.wait;

        "2:00.0 - Score Complete. Total Silence.".postln;
        Pbindef.removeAll;
        Tdef.removeAll;
    });

    s.sync;

    // Start Master Score
    Tdef(\masterScore).play;

});

s.makeGui;
)

// Source: 2026-10-07_11-27-02.scd [Block 10]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & LATENCY
// KEYWORDS: beakClatter, bpf, clatterSeq, compose, configuration, diskRecorder, freeverb2, global, gullCluster, hpf, latency, masterMix, ringz, rlpf, safetyLimiter, saw, seaBreeze, seagullCry, squallBurst, subDescent, wingFlap, wingSeq
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & LATENCY
    // --------------------------------------------------------------------
    s.latency = 0.2;
    ~enableRecording = false; // Fallback state (set to true to record multitrack)

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & MULTITRACK RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Gaivotas_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        seagull: Bus.audio(s, 2),
        beak:    Bus.audio(s, 2),
        wing:    Bus.audio(s, 2),
        breeze:  Bus.audio(s, 2),
        squall:  Bus.audio(s, 2),
        master:  0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig;
        sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------

    // Avian FM Call / Cry
    SynthDef(\seagullCry, {
        |out=0, recOut=0, fStart=1600, fMid=2900, fEnd=1400, dur=0.6,
         modIndexStart=0.3, modIndexMid=3.2, modIndexEnd=0.1, modRatio=1.414,
         vibRate=8, vibDepth=25, lpfFreq=16000, amp=0.25, pan=0|

        var env, pEnv, mEnv, mod, sig, vibrato, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.08 * dur, 0.42 * dur, 0.5 * dur], [-3, -1, -4]), doneAction: 2);
        pEnv = EnvGen.ar(Env([fStart, fMid, fEnd], [0.35 * dur, 0.65 * dur], [3, -3]));
        mEnv = EnvGen.ar(Env([modIndexStart, modIndexMid, modIndexEnd], [0.3 * dur, 0.7 * dur], [2, -2]));

        vibrato = SinOsc.ar(vibRate) * vibDepth;
        mod = SinOsc.ar((pEnv + vibrato) * modRatio) * (pEnv * mEnv);
        sig = SinOsc.ar(pEnv + vibrato + mod);
        sig = LPF.ar(sig, lpfFreq.clip(200, 19000));
        sig = sig * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Brittle Beak Clatter (Dual Resonator Impulse)
    SynthDef(\beakClatter, {
        |out=0, recOut=0, freq1=2500, freq2=3850, decayTime=0.035, amp=0.28, pan=0|
        var env, exciter, r1, r2, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.0005, decayTime + 0.02), doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003));
        r1 = Ringz.ar(exciter, freq1, decayTime);
        r2 = Ringz.ar(exciter, freq2, decayTime * 0.75);
        sig = (r1 + (r2 * 0.7)) * env * amp;
        sig = HPF.ar(sig, 800);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Wing Flap (Subtractive Low-frequency Swoosh)
    SynthDef(\wingFlap, {
        |out=0, recOut=0, dur=0.38, fStart=420, fEnd=55, rq=0.45, amp=0.35, pan=0|
        var env, fEnv, noise, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.02, dur, 1, -4), doneAction: 2);
        fEnv = XLine.ar(fStart, fEnd, dur);
        noise = PinkNoise.ar;
        sig = BPF.ar(noise, fEnv, rq) * 4.0;
        sig = (sig * 1.5).tanh * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Granular Squall Burst
    SynthDef(\squallBurst, {
        |out=0, recOut=0, dur=0.5, density=180, centerFreq=3200, amp=0.3, pan=0|
        var env, trigs, freqs, grains, finalSig;

        env = EnvGen.ar(Env.sine(dur), doneAction: 2);
        trigs = Dust.ar(density);
        freqs = TRand.ar(centerFreq * 0.5, centerFreq * 1.8, trigs);
        grains = Ringz.ar(trigs, freqs, TRand.ar(0.002, 0.015, trigs));
        grains = grains * env * amp;

        finalSig = Pan2.ar(grains, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Sub-Audible Edge Descent (Cue 19: 300 Hz -> 20 Hz Flutter)
    SynthDef(\subDescent, {
        |out=0, recOut=0, dur=9.0, startFreq=300, endFreq=20, amp=0.28, pan=0|
        var env, fEnv, flutterRate, flutter, sig, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.9, 0], [0.5, dur - 1.5, 1.0], [2, 0, -3]), doneAction: 2);
        fEnv = XLine.ar(startFreq, endFreq, dur);
        flutterRate = XLine.ar(8, 28, dur);
        flutter = LFPulse.ar(flutterRate, 0, 0.45);
        sig = SinOsc.ar(fEnv) + (Saw.ar(fEnv * 2) * 0.2);
        sig = (sig * flutter) * env * amp;
        sig = LeakDC.ar(sig);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & JITLIB ROUTING
    // --------------------------------------------------------------------

    // Littoral Atmosphere (Sea Breeze & Coastal Wash)
    Ndef(\seaBreeze, {
        |amp=0.0, lpf=8000, hpf=60, gust=0.0, modRate=0.12|
        var pNoise, bNoise, lfo1, lfo2, res1, res2, sig;

        pNoise = PinkNoise.ar;
        bNoise = BrownNoise.ar;

        lfo1 = LFNoise2.kr(modRate).exprange(250, 1400);
        lfo2 = LFNoise2.kr(modRate * 1.4).exprange(800, 3200);

        res1 = Resonz.ar(pNoise, lfo1, 0.35) * 2.2;
        res2 = Resonz.ar(bNoise, lfo2, 0.45) * 1.8;

        sig = (pNoise * 0.3) + res1 + res2;
        sig = sig + (WhiteNoise.ar * gust * LFNoise1.kr(4).range(0.2, 1.0));
        sig = RLPF.ar(sig, lpf.clip(100, 18000), 0.7);
        sig = HPF.ar(sig, hpf.clip(20, 1000));

        sig * amp;
    });
    Ndef(\seaBreeze).play(~recBuses.breeze);

    // Master Aggregator & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths, continuousBreeze;
        discreteSynths = In.ar(~synthBus, 2);
        continuousBreeze = Ndef.ar(\seaBreeze, 2);
        discreteSynths + continuousBreeze;
    });

    // Slot 10: Dynamic Littoral Reverb (Crossfader automatically governed by \wet10)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.32);
    };
    Ndef(\masterMix).set(\wet10, 0.25);

    Ndef(\masterMix).play(0);

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp, path;
        timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Destination: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        s.sync;

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING MULTITRACK AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Closed Successfully.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: 2:00.0 Exact Duration)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK MODE (RECORDING DISABLED) ---".postln;
        };

        // 0:00.0 — [Cue 1: Initial Breath & Avian Impulse (2.5s)]
        "0:00.0 - [Cue 1: Initial Breath & Avian Impulse]".postln;
        0.5.wait;
        Ndef(\masterMix).set(\wet10, 0.3);
        Ndef(\seaBreeze).fadeTime = 1.0;
        Ndef(\seaBreeze).xset(\amp, -18.dbamp, \lpf, 4500, \hpf, 80, \gust, 0.0);

        0.7.wait;
        // Solitary sharp seagull call at 0:01.2
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 0.75, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.25, \pan, 0.1
        ]);

        1.3.wait;

        // 0:02.5 — [Cue 2: Solitary Glissando Spike (2.5s)]
        "0:02.5 - [Cue 2: Solitary Glissando Spike]".postln;
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 1.8, \modIndexStart, 0.5, \modIndexMid, 4.2, \modIndexEnd, 0.3,
            \vibRate, 14, \vibDepth, 80, \amp, 0.3, \pan, -0.3
        ]);

        2.5.wait;

        // 0:05.0 — [Cue 3: The Saline Void (Form Operation C, 9.5s)]
        "0:05.0 - [Cue 3: The Saline Void (Abrupt cut to low-complexity rumble)]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.28, \lpf, 180, \hpf, 30, \gust, 0.0);

        // Active Wait: 9.5 seconds divided into micro-shifts
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.04));
            3.0.wait;
        };
        0.5.wait;

        // 0:14.5 — [Cue 4: Hyper-Kinetic Beak Clatter (1.7s)]
        "0:14.5 - [Cue 4: Hyper-Kinetic Beak Clatter]".postln;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.02); // Spotlight rule: duck wind
        Ndef(\masterMix).set(\wet10, 0.05); // Bone-dry space

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, Pseq([0.05, 0.04, 0.06, 0.035, 0.055], inf),
            \freq1, Pexprand(2200, 3400, inf),
            \freq2, Pexprand(3500, 5200, inf),
            \decayTime, Pwhite(0.015, 0.04, inf),
            \amp, Pwhite(0.22, 0.32, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        1.7.wait;

        // 0:16.2 — [Cue 5: Swelling Wingbeat Resonances (7.8s)]
        "0:16.2 - [Cue 5: Swelling Wingbeat Resonances]".postln;
        Pbindef(\clatterSeq).stop;

        Ndef(\masterMix).set(\wet10, 0.35);
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.22, \lpf, 3500, \hpf, 80);

        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, Pseq([0.38, 0.32, 0.28, 0.24, 0.22, 0.20, 0.18, 0.16, 0.16], inf),
            \durFlap, 0.3,
            \fStart, Pseries(300, 15, inf).clip(300, 550),
            \fEnd, 55,
            \amp, Pseries(0.22, 0.015, inf).clip(0.22, 0.38),
            \pan, Pseq([-0.4, 0.4, -0.2, 0.2], inf)
        ).play;

        // Active Wait: 7.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2000 + (i * 600));
            1.95.wait;
        };

        // 0:24.0 — [Cue 6: Violent Wind Shear (2.5s)]
        "0:24.0 - [Cue 6: Violent Wind Shear]".postln;
        Pbindef(\wingSeq).stop; // Mute wing flaps instantly
        Ndef(\masterMix).set(\wet10, 0.15);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.45, \lpf, 9000, \hpf, 120, \gust, 0.85);

        2.5.wait;

        // 0:26.5 — [Cue 7: Pitch Ceiling Cry Arc (Form Operation B, 9.5s)]
        "0:26.5 - [Cue 7: Pitch Ceiling Cry Arc (Ascending toward Nyquist/Ceiling)]".postln;
        Ndef(\seaBreeze).fadeTime = 1.5;
        Ndef(\seaBreeze).xset(\amp, 0.1, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.35);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.45, 0.4, 0.35, 0.3, 0.28, 0.25, 0.22, 0.2, 0.18], inf),
            \fStart, Pseries(2000, 380, inf).clip(2000, 11500),
            \fMid, Pseries(2800, 420, inf).clip(2800, 13000),
            \fEnd, Pseries(1900, 360, inf).clip(1900, 11000),
            \durCall, 0.32,
            \modIndexMid, Pseries(2.0, 0.3, inf).clip(2.0, 7.5),
            \amp, Pseries(0.2, 0.012, inf).clip(0.2, 0.34),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active Wait: 9.5 seconds
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.35 + (i * 0.05));
            2.375.wait;
        };

        // 0:36.0 — [Cue 8: Dry Staccato Snap (1.2s)]
        "0:36.0 - [Cue 8: Dry Staccato Snap (Sudden subtraction)]".postln;
        Pbindef(\gullCluster).stop; // INSTANT SUBTRACTION
        Ndef(\masterMix).set(\wet10, 0.02);

        // 3 dry beak snaps
        3.do { |i|
            Synth(\beakClatter, [
                \out, ~synthBus,
                \recOut, ~recBuses.beak,
                \freq1, 2600 + (i * 400),
                \freq2, 4100 + (i * 300),
                \decayTime, 0.025,
                \amp, 0.36,
                \pan, (i - 1) * 0.4
            ]);
            0.4.wait;
        };

        // 0:37.2 — [Cue 9: Sub-Aquatic Murmur & Muffled Glides (9.8s)]
        "0:37.2 - [Cue 9: Sub-Aquatic Murmur & Muffled Glides]".postln;
        Ndef(\masterMix).set(\wet10, 0.8); // Deep resonant space
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.3, \lpf, 450, \hpf, 40, \gust, 0.0);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([2.2, 2.8, 3.2], inf),
            \fStart, Pseq([700, 850, 620], inf),
            \fMid, Pseq([1100, 1250, 950], inf),
            \fEnd, Pseq([550, 600, 480], inf),
            \durCall, 1.8,
            \lpfFreq, 900,
            \modIndexMid, 1.5,
            \amp, 0.22,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 9.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 380 + (i * 40));
            2.45.wait;
        };

        // 0:47.0 — [Cue 10: Aggressive Territorial Dart (2.5s)]
        "0:47.0 - [Cue 10: Aggressive Territorial Dart]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.1;
        Ndef(\seaBreeze).xset(\amp, 0.05);

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.07,
            \freq1, Pwhite(2800, 4200, inf),
            \freq2, Pwhite(4500, 6000, inf),
            \decayTime, 0.02,
            \amp, 0.28,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Rapid downward shrieks
        fork {
            3.do { |i|
                Synth(\seagullCry, [
                    \out, ~synthBus,
                    \recOut, ~recBuses.seagull,
                    \fStart, 4200 - (i * 400),
                    \fMid, 3500 - (i * 300),
                    \fEnd, 1100,
                    \dur, 0.55,
                    \modIndexMid, 4.5,
                    \vibRate, 16,
                    \amp, 0.28,
                    \pan, (i.even.if(0.5, -0.5))
                ]);
                0.7.wait;
            };
        };

        2.5.wait;

        // 0:49.5 — [Cue 11: Mid-Air Stasis (2.0s)]
        "0:49.5 - [Cue 11: Mid-Air Stasis]".postln;
        Pbindef(\clatterSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.65); // Pure suspended reverberation

        // Single sustained crystalline tone
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 2400, \fMid, 2400, \fEnd, 2400,
            \dur, 1.9, \modIndexStart, 0.0, \modIndexMid, 0.0, \modIndexEnd, 0.0,
            \vibRate, 0, \vibDepth, 0, \amp, 0.24, \pan, 0
        ]);

        2.0.wait;

        // 0:51.5 — [Cue 12: Microtonal Polyphonic Choir (10.5s)]
        "0:51.5 - [Cue 12: Microtonal Polyphonic Choir]".postln;
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.18, \lpf, 4000, \hpf, 70);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.35, 0.55, 0.4, 0.7, 0.3], inf),
            \fStart, Pseq([1760, 1845, 1920, 2030, 2150, 2270, 2390], inf),
            \fMid, Pseq([2400, 2520, 2610, 2780, 2900, 3050, 3180], inf),
            \fEnd, Pseq([1650, 1720, 1800, 1910, 2010, 2120, 2220], inf),
            \durCall, Pwhite(0.5, 0.9, inf),
            \modIndexMid, Pwhite(1.2, 2.8, inf),
            \amp, 0.2,
            \pan, Pseq([-0.7, -0.3, 0.0, 0.3, 0.7, 0.4, -0.4], inf)
        ).play;

        // Active Wait: 10.5 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.1 + (i * 0.05));
            3.5.wait;
        };

        // 1:02.0 — [Cue 13: Granular Squall Interruption (2.8s)]
        "1:02.0 - [Cue 13: Granular Squall Interruption]".postln;
        Pbindef(\gullCluster).stop; // Mute colony
        Ndef(\masterMix).set(\wet10, 0.2);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.7);

        Synth(\squallBurst, [
            \out, ~synthBus,
            \recOut, ~recBuses.squall,
            \dur, 2.5,
            \density, 240,
            \centerFreq, 3800,
            \amp, 0.32,
            \pan, 0
        ]);

        2.8.wait;

        // 1:04.8 — [Cue 14: Salt Drift & Resonant Breakers (9.2s)]
        "1:04.8 - [Cue 14: Salt Drift & Resonant Breakers]".postln;
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.26, \lpf, 3200, \hpf, 50, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.55);

        // Distant echoing gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([3.0, 3.2, 2.8], inf),
            \fStart, Pseq([1900, 2200, 1750], inf),
            \fMid, Pseq([2700, 3100, 2400], inf),
            \fEnd, Pseq([1600, 1850, 1450], inf),
            \durCall, 1.4,
            \modIndexMid, 1.8,
            \amp, 0.18,
            \pan, Pseq([0.6, -0.6, 0.3], inf)
        ).play;

        // Active Wait: 9.2 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2800 + (i * 200));
            2.3.wait;
        };

        // 1:14.0 — [Cue 15: Metallic Chirp Jolt (1.8s)]
        "1:14.0 - [Cue 15: Metallic Chirp Jolt]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.15);

        // 3 high-index FM transient chirps at 0.0s, 0.4s, 0.7s
        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 3800, \fMid, 5200, \fEnd, 2900, \dur, 0.22,
            \modIndexMid, 6.0, \amp, 0.26, \pan, -0.5
        ]);
        0.4.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4200, \fMid, 5600, \fEnd, 3200, \dur, 0.2,
            \modIndexMid, 6.8, \amp, 0.28, \pan, 0.5
        ]);
        0.3.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4600, \fMid, 6100, \fEnd, 3600, \dur, 0.25,
            \modIndexMid, 7.5, \amp, 0.3, \pan, 0.0
        ]);
        1.1.wait;

        // 1:15.8 — [Cue 16: Return to Point of Departure (Form Operation A, 10.7s)]
        "1:15.8 - [Cue 16: Return to Point of Departure (Restatement of Opening Solitary Motif)]".postln;
        Ndef(\masterMix).set(\wet10, 0.65); // Rich spatial envelopment
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.2, \lpf, 4000, \hpf, 70, \gust, 0.0);

        // Solitary Opening Motif restatement
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 1.2, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.26, \pan, 0.0
        ]);

        2.5.wait;

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 2.0, \modIndexStart, 0.4, \modIndexMid, 3.8, \modIndexEnd, 0.2,
            \vibRate, 12, \vibDepth, 60, \amp, 0.28, \pan, -0.2
        ]);

        // Active Wait remaining: 8.2 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.03));
            2.73.wait;
        };

        // 1:26.5 — [Cue 17: Frenzied Feeding Swarm Climax (3.5s)]
        "1:26.5 - [Cue 17: Frenzied Feeding Swarm Climax]".postln;
        Ndef(\masterMix).set(\wet10, 0.25);
        Ndef(\seaBreeze).fadeTime = 0.5;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.5);

        // Layer 1: Frantic gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.16, 0.14, 0.2, 0.15], inf),
            \fStart, Pexprand(1800, 3600, inf),
            \fMid, Pexprand(3500, 5800, inf),
            \fEnd, Pexprand(1400, 2800, inf),
            \durCall, 0.25,
            \modIndexMid, 4.0,
            \amp, 0.28,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Layer 2: Rapid beak clattering
        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.06,
            \freq1, Pexprand(2500, 4000, inf),
            \freq2, Pexprand(4200, 6200, inf),
            \decayTime, 0.02,
            \amp, 0.24,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Layer 3: Flapping
        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, 0.18,
            \durFlap, 0.2,
            \fStart, 480, \fEnd, 60,
            \amp, 0.28,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.5.wait;

        // 1:30.0 — [Cue 18: Hard Vacuum Cut (2.0s)]
        "1:30.0 - [Cue 18: Hard Vacuum Cut (Instant subtraction)]".postln;
        Pbindef(\gullCluster).stop;
        Pbindef(\clatterSeq).stop;
        Pbindef(\wingSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.75); // Reverb tail hangs alone

        2.0.wait;

        // 1:32.0 — [Cue 19: Descent to Sub-Audible Edge (Form Operation B, 9.5s)]
        "1:32.0 - [Cue 19: Descent to Sub-Audible Edge (300 Hz to 20 Hz)]".postln;
        Ndef(\masterMix).set(\wet10, 0.2);

        Synth(\subDescent, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, 9.0,
            \startFreq, 300,
            \endFreq, 20,
            \amp, 0.32,
            \pan, 0
        ]);

        // Active Wait: 9.5 seconds
        3.do { |i|
            Ndef(\masterMix).set(\wet10, 0.2 + (i * 0.1));
            3.16.wait;
        };

        // 1:41.5 — [Cue 20: Ghost Squawk Fragment (2.5s)]
        "1:41.5 - [Cue 20: Ghost Squawk Fragment]".postln;
        Ndef(\masterMix).set(\wet10, 0.85);

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 4500, \fMid, 4700, \fEnd, 4300,
            \dur, 0.4, \modIndexMid, 0.4,
            \lpfFreq, 5000, \amp, 0.12, \pan, 0.2
        ]);

        2.5.wait;

        // 1:44.0 — [Cue 21: Total Evacuation & Dissolution (Form Operation D, 16.0s)]
        "1:44.0 - [Cue 21: Total Evacuation & Dissolution]".postln;

        // Stop all discrete event generation
        Pbindef.all.do(_.stop);

        // 12-second fade-out on all continuous sound proxies
        Ndef(\seaBreeze).fadeTime = 12.0;
        Ndef(\seaBreeze).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 12.0;
        Ndef(\masterMix).xset(\wet10, 0.0);

        // Stop recording before audio stream vanishes
        if(~enableRecording) {
            ~stopRecording.value;
        };

        // Active Wait through the 12-second decay
        4.do {
            3.0.wait;
        };

        // 1:56.0 - 2:00.0: Final evacuation & hard clearance
        "1:56.0 - Final clearing of proxies and nodes...".postln;
        Ndef.clear(3.0);
        4.0.wait;

        "2:00.0 - Score Complete. Total Silence.".postln;
        Pbindef.removeAll;
        Tdef.removeAll;
    });

    s.sync;

    // Start Master Score
    Tdef(\masterScore).play;

});

s.makeGui;
)

// Source: 2026-11-04_12-01-59.scd [Block 2]
// MODE: compose
// THEME: GLOBAL CONFIGURATION
// KEYWORDS: agrilus_boreSeq, agrilus_chitinDrone, agrilus_chitinSeq, agrilus_click, agrilus_diskRecorder, agrilus_fx, agrilus_galleryRes, agrilus_mandibleSeq, agrilus_modalWood, agrilus_woodBore, bpf, compose, configuration, dynklank, freeverb2, global, moogff, ringz, rlpf, safetyLimiter
(
s.waitForBoot({

    var recFolder;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state (toggle to true if multitrack capture needed)
    s.latency = 0.2;

    // --------------------------------------------------------------------
    // PRE-SETUP: GROUPS, BUFFERS & ROUTING BUSES
    // --------------------------------------------------------------------
    ~agrilus_group = Group.new(s);
    ~agrilus_synthBus = Bus.audio(s, 2);

    // Global FFT buffers allocated safely outside JITLib dynamic graphs
    ~agrilus_fftBufL = Buffer.alloc(s, 2048);
    ~agrilus_fftBufR = Buffer.alloc(s, 2048);

    recFolder = "~/Desktop/SC_Multitrack_Agrilus/".standardizePath;
    File.mkdir(recFolder);
    ~agrilus_recFolder = recFolder;

    ~agrilus_recBuses = (
        click: Bus.audio(s, 2),
        bore: Bus.audio(s, 2),
        modal: Bus.audio(s, 2),
        drone: Bus.audio(s, 2),
        gallery: Bus.audio(s, 2),
        master: Bus.audio(s, 2)
    );

    ~agrilus_recBufs = ();
    ~agrilus_recBuses.keysValuesDo { |name, bus|
        ~agrilus_recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\agrilus_diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    // Safe append to ServerTree without wiping server context
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------
    SynthDef(\agrilus_click, { |out=0, recOut=0, freq=3200, freqMult=1, ringTime=0.02, amp=0.25, pan=0, sweep=0|
        var env, swEnv, pFreq, imp, res, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.0005, ringTime.clip(0.001, 0.25)), doneAction: 2);
        swEnv = Line.ar(1, 1 + sweep, ringTime.clip(0.001, 0.25));
        pFreq = (freq * freqMult * swEnv).clip(200, 19000);
        imp = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.002)));
        res = Ringz.ar(imp, pFreq, ringTime.clip(0.001, 0.25));
        sig = (res * 0.12) + (imp * 0.35);
        sig = LeakDC.ar(sig) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\agrilus_woodBore, { |out=0, recOut=0, freq=300, freqMult=1, roughness=40, resFreq=1200, amp=0.3, pan=0, dur=0.2|
        var env, trig, noise, filterBank, sig, finalSig, effFreq;
        env = EnvGen.ar(Env.linen(0.005, dur * 0.7, dur * 0.3), doneAction: 2);
        trig = Dust.ar(roughness.clip(5, 600));
        noise = WhiteNoise.ar * Decay2.ar(trig, 0.0005, 0.015);
        effFreq = (freq * freqMult).clip(80, 8000);
        filterBank = [1, 1.48, 2.2, 3.1, 4.3].collect { |m|
            BPF.ar(noise, (resFreq * m).clip(100, 16000), 0.12) * (1 / m.sqrt)
        }.sum;
        sig = (filterBank * 2.8) + RLPF.ar(noise, effFreq, 0.35);
        sig = sig.tanh * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\agrilus_modalWood, { |out=0, recOut=0, freq=180, decayscale=0.1, amp=0.4, pan=0|
        var env, exciter, freqs, amps, rings, klank, sig, finalSig, decaySafe;
        decaySafe = decayscale.clip(0.005, 1.5);
        env = EnvGen.ar(Env.perc(0.001, decaySafe + 0.12), doneAction: 2);
        exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.006));
        freqs = [1, 2.14, 3.42, 5.11, 7.8] * freq;
        amps = [1, 0.6, 0.4, 0.25, 0.15];
        rings = [1, 0.8, 0.6, 0.4, 0.2] * decaySafe;
        klank = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = (klank * 0.5) + (exciter * 0.25);
        sig = LeakDC.ar(sig) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\agrilus_chitinDrone, { |freq=110, carrierRatio=3.5, modIndex=1.2, subAmp=0.2, amp=0, pan=0, subPulse=0|
        var carFreq, modFreq, mod, car1, car2, sub, sig;
        carFreq = freq.clip(30, 2000);
        modFreq = carFreq * carrierRatio;
        mod = SinOsc.ar(modFreq) * (modFreq * modIndex);
        car1 = SinOsc.ar(carFreq + mod);
        car2 = SinOsc.ar((carFreq * 1.503) + (mod * 0.7));
        sub = SinOsc.ar(carFreq * 0.5) * subAmp;
        sub = sub + (Pulse.ar(40, 0.3) * subPulse * 0.4);
        sig = (car1 * 0.5) + (car2 * 0.4) + sub;
        sig = MoogFF.ar(sig, (carFreq * 8).clip(200, 16000), 1.2);
        Pan2.ar(sig * amp, pan);
    });
    Ndef(\agrilus_chitinDrone).play(~agrilus_recBuses.drone, group: ~agrilus_group);

    Ndef(\agrilus_galleryRes, { |delTime=0.08, decay=2.5, amp=0|
        var inSig, dL, dR, sig;
        inSig = In.ar(~agrilus_synthBus, 2) * 0.6;
        dL = CombC.ar(inSig[0] + (Dust2.ar(3) * 0.015), 0.5, delTime.clip(0.005, 0.45), decay);
        dR = CombC.ar(inSig[1] + (Dust2.ar(3) * 0.015), 0.5, (delTime * 1.23).clip(0.005, 0.45), decay);
        sig = [dL, dR];
        sig = HPF.ar(sig, 120);
        sig = LPF.ar(sig, 7000);
        sig * amp;
    });
    Ndef(\agrilus_galleryRes).play(~agrilus_recBuses.gallery, group: ~agrilus_group);

    Ndef(\agrilus_fx, {
        var synths, drone, gallery, mixed;
        synths = In.ar(~agrilus_synthBus, 2);
        drone = Ndef.ar(\agrilus_chitinDrone, 2);
        gallery = Ndef.ar(\agrilus_galleryRes, 2);
        mixed = synths + drone + gallery;
        Out.ar(~agrilus_recBuses.master, mixed);
        mixed;
    });

    // Auto-crossfaded JITLib filter slot (External control via \wet10)
    Ndef(\agrilus_fx)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.35);
    };

    Ndef(\agrilus_fx).play(out: 0, group: ~agrilus_group);
    s.sync;

    Ndef(\agrilus_fx).set(\wet10, 0.0);
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~agrilus_startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;
        ~agrilus_recSynths = ();

        "--- [AGRILUS] MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~agrilus_recFolder).postln;

        ~agrilus_recBuses.keysValuesDo { |name, bus|
            path = ~agrilus_recFolder ++ timestamp ++ "_agrilus_" ++ name ++ ".wav";
            ~agrilus_recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~agrilus_recBuses.keysValuesDo { |name, bus|
            ~agrilus_recSynths[name] = Synth.tail(RootNode(s), \agrilus_diskRecorder, [
                \bus, bus,
                \bufnum, ~agrilus_recBufs[name]
            ]);
        };

        CmdPeriod.doOnce({ ~agrilus_stopRecording.value });
    };

    ~agrilus_stopRecording = {
        if(~agrilus_recSynths.notNil) {
            "--- [AGRILUS] CLOSING AUDIO FILES ---".postln;
            ~agrilus_recSynths.do(_.free);
            ~agrilus_recBufs.do(_.close);
            ~agrilus_recBufs.do(_.free);
            ~agrilus_recSynths = nil;
            "Multitrack Recording Closed Safely.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Timeline Score: 130.0s Absolute Timeline)
    // --------------------------------------------------------------------
    Tdef(\agrilus_timeline, {

        // --- 0:00.0 - Initialization Breathing Room (0.5s) ---
        if(~enableRecording) {
            ~agrilus_startRecording.value;
        } {
            "--- [AGRILUS] PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };
        0.5.wait;

        // --- 0:00.5 - [Cue 1: Iridescent Emergence (2.3s)] ---
        "0:00.5 - [Cue 1: Iridescent Emergence]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.0);
        Pbindef(\agrilus_chitinSeq,
            \instrument, \agrilus_click,
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \dur, Pseq([0.0625, 0.125, 0.0625, 0.0625, 0.1875], inf),
            \freq, Pseq([3520, 4186, 5587, 4978, 6271], inf),
            \freqMult, 1.0,
            \ringTime, 0.015,
            \amp, 0.22,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;
        2.3.wait;

        // --- 0:02.8 - [Cue 2: Chitinous Tap (1.2s)] ---
        "0:02.8 - [Cue 2: Chitinous Tap]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 280,
            \decayscale, 0.08,
            \amp, 0.5,
            \pan, -0.85
        ], ~agrilus_group);
        1.2.wait;

        // --- 0:04.0 - [Cue 3: Micro-Boring Friction (7.2s)] ---
        "0:04.0 - [Cue 3: Micro-Boring Friction]".postln;
        Pbindef(\agrilus_boreSeq,
            \instrument, \agrilus_woodBore,
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.bore,
            \dur, Pseq([0.15, 0.2, 0.1, 0.25], inf),
            \freq, 280,
            \freqMult, 1.0,
            \roughness, Pseg(Pseq([25, 120], 1), 7.0, \exp),
            \resFreq, 1100,
            \durParam, 0.18,
            \amp, 0.32,
            \pan, 0
        ).play;

        // Active wait: 7.2s (2.4s x 3)
        3.do { |i|
            Pbindef(\agrilus_chitinSeq, \pan, rrand(-0.6, 0.6));
            2.4.wait;
        };

        // --- 0:11.2 - [Cue 4: Vascular Snap (1.2s) - Form Operation C] ---
        "0:11.2 - [Cue 4: Vascular Snap]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_chitinSeq).stop;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 420,
            \decayscale, 0.02,
            \amp, 0.6,
            \pan, 0.1
        ], ~agrilus_group);
        1.2.wait;

        // --- 0:12.4 - [Cue 5: Phloem Resonance (6.2s)] ---
        "0:12.4 - [Cue 5: Phloem Resonance]".postln;
        Ndef(\agrilus_galleryRes).fadeTime = 1.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.35, \delTime, 0.09, \decay, 2.8);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseq([0.5, 0.75, 0.25, 0.5], inf),
            \freq, Pseq([2200, 3100, 1900], inf),
            \ringTime, 0.03,
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active wait: 6.2s (3.1s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, [0.08, 0.11].at(i));
            3.1.wait;
        };

        // --- 0:18.6 - [Cue 6: Stridulation Cluster (1.5s)] ---
        "0:18.6 - [Cue 6: Stridulation Cluster]".postln;
        Pbindef(\agrilus_chitinSeq,
            \dur, 0.03125,
            \freq, Pexprand(4000, 9000, inf),
            \ringTime, 0.002,
            \amp, 0.3,
            \pan, Pseq([-0.8, 0.8], inf)
        );
        1.5.wait;

        // --- 0:20.1 - [Cue 7: Metallic Buprestid Drone (8.3s)] ---
        "0:20.1 - [Cue 7: Metallic Buprestid Drone]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_chitinDrone).fadeTime = 2.5;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.45, \freq, 110, \carrierRatio, 3.5, \modIndex, 1.2, \subAmp, 0.25);

        // Active wait: 8.3s (4.15s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\modIndex, 1.2 + ((i + 1) * 0.4));
            4.15.wait;
        };

        // --- 0:28.4 - [Cue 8: Mandibular Jolt (1.8s)] ---
        "0:28.4 - [Cue 8: Mandibular Jolt]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 85,
            \decayscale, 0.35,
            \amp, 0.7,
            \pan, 0
        ], ~agrilus_group);
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.25); // Duck drone
        1.8.wait;

        // --- 0:30.2 - [Cue 9: Xylem Excavation (7.8s)] ---
        "0:30.2 - [Cue 9: Xylem Excavation]".postln;
        Pbindef(\agrilus_boreSeq,
            \dur, Pseq([0.1, 0.05, 0.05, 0.2], inf),
            \freq, 240,
            \freqMult, 1.0,
            \roughness, Pwhite(60, 140, inf),
            \resFreq, 1350,
            \durParam, 0.12,
            \amp, 0.38,
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;

        // Active wait: 7.8s (3.9s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\freq, 110 + (i * 8));
            3.9.wait;
        };

        // --- 0:38.0 - [Cue 10: Micro-Rotary Acceleration (2.5s)] ---
        "0:38.0 - [Cue 10: Micro-Rotary Acceleration]".postln;
        Pbindef(\agrilus_boreSeq,
            \freqMult, Pseg(Pseq([1.0, 2.8], 1), 2.5, \exp),
            \roughness, Pseg(Pseq([100, 320], 1), 2.5, \exp)
        );
        2.5.wait;

        // --- 0:40.5 - [Cue 11: Bark Fracture (1.5s)] ---
        "0:40.5 - [Cue 11: Bark Fracture]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Ndef(\agrilus_fx).set(\wet10, 0.8);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 1800,
            \ringTime, 0.08,
            \amp, 0.55,
            \pan, 0.3
        ], ~agrilus_group);
        1.5.wait;

        // --- 0:42.0 - [Cue 12: Sub-Cortical Shimmer (9.5s)] ---
        "0:42.0 - [Cue 12: Sub-Cortical Shimmer]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.35);
        Ndef(\agrilus_chitinDrone).fadeTime = 3.0;
        Ndef(\agrilus_chitinDrone).xset(\modIndex, 4.8, \amp, 0.4, \carrierRatio, 4.25);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pwhite(0.2, 0.7, inf),
            \freq, Pexprand(2500, 8500, inf),
            \ringTime, 0.05,
            \amp, 0.18,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active wait: 9.5s (3.16s x 3)
        3.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\freq, 115 + (i * 12));
            3.16.wait;
        };

        // --- 0:51.5 - [Cue 13: Serrated Scrape (1.7s)] ---
        "0:51.5 - [Cue 13: Serrated Scrape]".postln;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 4800,
            \sweep, 2.5,
            \ringTime, 0.15,
            \amp, 0.45,
            \pan, -0.6
        ], ~agrilus_group);
        1.7.wait;

        // --- 0:53.2 - [Cue 14: Resonant Gallery (8.8s)] ---
        "0:53.2 - [Cue 14: Resonant Gallery]".postln;
        Ndef(\agrilus_galleryRes).fadeTime = 2.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.5, \decay, 4.2);

        // Active wait: 8.8s (4.4s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, [0.065, 0.12].at(i));
            4.4.wait;
        };

        // --- 1:02.0 - [Cue 15: Flight Muscle Twitch (2.6s)] ---
        "1:02.0 - [Cue 15: Flight Muscle Twitch]".postln;
        Ndef(\agrilus_chitinDrone).xset(\subPulse, 1.0, \amp, 0.55);
        Pbindef(\agrilus_chitinSeq,
            \dur, 0.0625,
            \freq, Pseq([6000, 7200, 8400, 6800], inf),
            \ringTime, 0.005,
            \amp, 0.28
        );
        2.6.wait;

        // --- 1:04.6 - [Cue 16: Spectral Elytra (9.4s)] ---
        "1:04.6 - [Cue 16: Spectral Elytra]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_fx).set(\wet10, 0.2);
        Ndef(\agrilus_chitinDrone).fadeTime = 2.0;
        Ndef(\agrilus_chitinDrone).xset(\modIndex, 7.5, \carrierRatio, 2.76, \amp, 0.65, \subPulse, 0.0);

        // Active wait: 9.4s (4.7s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\carrierRatio, 2.76 + (i * 0.4));
            4.7.wait;
        };

        // --- 1:14.0 - [Cue 17: Acoustic Dislodgment (1.5s)] ---
        "1:14.0 - [Cue 17: Acoustic Dislodgment]".postln;
        Ndef(\agrilus_galleryRes).set(\amp, 0.0);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 1200,
            \ringTime, 0.01,
            \amp, 0.6,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 1:15.5 - [Cue 18: The Deep Tunneling Arc (9.3s)] ---
        "1:15.5 - [Cue 18: The Deep Tunneling Arc]".postln;
        Ndef(\agrilus_chitinDrone).fadeTime = 1.5;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.2, \modIndex, 0.8, \freq, 75);
        Pbindef(\agrilus_boreSeq,
            \dur, Pseq([0.18, 0.09, 0.09, 0.27], inf),
            \freq, Pwhite(150, 320, inf),
            \freqMult, 1.0,
            \roughness, Pseq([40, 75, 120, 90], inf),
            \resFreq, 650,
            \durParam, 0.16,
            \amp, 0.42,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active wait: 9.3s (3.1s x 3)
        3.do { |i|
            Pbindef(\agrilus_boreSeq, \resFreq, 650 + (i * 120));
            3.1.wait;
        };

        // --- 1:24.8 - [Cue 19: Pith Impact (1.2s)] ---
        "1:24.8 - [Cue 19: Pith Impact]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 140,
            \decayscale, 0.005,
            \amp, 0.65,
            \pan, 0
        ], ~agrilus_group);
        1.2.wait;

        // --- 1:26.0 - [Cue 20: Drill Saturation (10.5s) - Form Operation B] ---
        "1:26.0 - [Cue 20: Drill Saturation]".postln;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.35, \modIndex, 3.5);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseg(Pseq([0.08, 0.005], 1), 10.0, \exp),
            \freq, Pexprand(3000, 10000, inf),
            \ringTime, 0.004,
            \amp, 0.25,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        Pbindef(\agrilus_boreSeq,
            \dur, Pseg(Pseq([0.12, 0.008], 1), 10.0, \exp),
            \roughness, Pseg(Pseq([80, 500], 1), 10.0, \exp),
            \amp, 0.45
        ).play;

        // Active wait: 10.5s (3.5s x 3)
        3.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\modIndex, 3.5 + (i * 1.5));
            3.5.wait;
        };

        // --- 1:36.5 - [Cue 21: Flashback: Dry Bark Echo (1.5s) - Form Operation C] ---
        "1:36.5 - [Cue 21: Flashback: Dry Bark Echo]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_chitinDrone).set(\amp, 0.0);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 3520,
            \ringTime, 0.015,
            \amp, 0.25,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 1:38.0 - [Cue 22: Iridescent Dispersion (9.2s)] ---
        "1:38.0 - [Cue 22: Iridescent Dispersion]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.55);
        Ndef(\agrilus_galleryRes).fadeTime = 2.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.3, \delTime, 0.14, \decay, 4.5);

        // Active wait: 9.2s (4.6s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, 0.14 - (i * 0.03));
            4.6.wait;
        };

        // --- 1:47.2 - [Cue 23: Kinetic Wing Release (1.8s)] ---
        "1:47.2 - [Cue 23: Kinetic Wing Release]".postln;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 2200,
            \sweep, 3.0,
            \ringTime, 0.18,
            \amp, 0.4,
            \pan, 0.4
        ], ~agrilus_group);
        1.8.wait;

        // --- 1:49.0 - [Cue 24: Return to Point of Departure (10.5s) - Form Operation A] ---
        "1:49.0 - [Cue 24: Return to Point of Departure]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.05);
        Ndef(\agrilus_galleryRes).fadeTime = 4.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.0);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseq([0.125, 0.25, 0.125, 0.375], inf),
            \freq, Pseq([3520, 4186, 5587, 4978], inf),
            \freqMult, 1.0,
            \ringTime, 0.012,
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        // Active wait: 10.5s (3.5s x 3)
        3.do { |i|
            Pbindef(\agrilus_chitinSeq, \amp, 0.2 - (i * 0.05));
            3.5.wait;
        };

        // --- 1:59.5 - [Cue 25: Final Mandible Strike (1.5s)] ---
        "1:59.5 - [Cue 25: Final Mandible Strike]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 3100,
            \ringTime, 0.008,
            \amp, 0.22,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 2:01.0 - [Cue 26: Extrinsic Fade & Safe Release (9.0s) - Form Operation D] ---
        "2:01.0 - [Cue 26: Extrinsic Fade & Safe Release]".postln;
        Ndef(\agrilus_chitinDrone).fadeTime = 8.0;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.0);
        Ndef(\agrilus_galleryRes).fadeTime = 8.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.0);
        Ndef(\agrilus_fx).fadeTime = 8.0;
        Ndef(\agrilus_fx).xset(\amp, 0.0);

        // Active wait: 9.0s (3.0s x 3)
        3.do { |i|
            3.0.wait;
        };

        // Isolated piece-specific cleanup strictly preserving surrounding server sessions
        ~agrilus_stopRecording.value;

        Pbindef(\agrilus_chitinSeq).stop;
        Pbindef(\agrilus_chitinSeq).clear;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_boreSeq).clear;
        Pbindef(\agrilus_mandibleSeq).stop;
        Pbindef(\agrilus_mandibleSeq).clear;

        Ndef(\agrilus_chitinDrone).stop;
        Ndef(\agrilus_chitinDrone).clear;
        Ndef(\agrilus_galleryRes).stop;
        Ndef(\agrilus_galleryRes).clear;
        Ndef(\agrilus_fx).stop;
        Ndef(\agrilus_fx).clear;

        ~agrilus_fftBufL.free;
        ~agrilus_fftBufR.free;
        ~agrilus_group.free;

        Tdef(\agrilus_timeline).stop;
        "--- [AGRILUS] Score Complete. Server preserved. ---".postln;
    });

    Tdef(\agrilus_timeline).play;
});
)

// Source: 2026-11-04_12-01-59.scd [Block 7]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & MULTI-TRACK RECORDING SETUP
// KEYWORDS: bpf, compose, configuration, dynklank, freeverb2, global, hpf, lit_cavitation, lit_clicks, lit_crustClick, lit_diskRecorder, lit_hydroDrone, lit_masterFX, lit_modalBasin, lit_neriticSwell, lit_safetyLimiter, lit_sprayImpact, lit_surge, moogff, multi, recording, setup, sinosc, track
(
s.waitForBoot({
    var masterScore;

    s.latency = 0.2;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & MULTI-TRACK RECORDING SETUP
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state

    ~lit_recFolder = "~/Desktop/SC_Litoral_Recording/".standardizePath;
    File.mkdir(~lit_recFolder);

    // Dedicated routing buses
    ~lit_synthBus = Bus.audio(s, 2);

    // Multitrack buses
    ~lit_recBuses = (
        clicks: Bus.audio(s, 2),
        surge: Bus.audio(s, 2),
        spray: Bus.audio(s, 2),
        swell: Bus.audio(s, 2),
        hydro: Bus.audio(s, 2),
        master: 0
    );

    ~lit_recBufs = ();
    ~lit_recBuses.keysValuesDo { |name, bus|
        ~lit_recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Dedicated FFT buffers to prevent dynamic LocalBuf collisions
    ~lit_fftBufL = Buffer.alloc(s, 2048, 1);
    ~lit_fftBufR = Buffer.alloc(s, 2048, 1);

    SynthDef(\lit_diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER (Shared-Server Safe)
    // --------------------------------------------------------------------
    SynthDef(\lit_safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \lit_safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \lit_safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. SYNTHDEFS (Discrete Events - Fully Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\lit_crustClick, { |out=0, recOut=0, freq=5000, freqMult=1, amp=0.2, pan=0, ring=0.015|
        var env = EnvGen.ar(Env.perc(0.0005, ring.clip(0.002, 0.08)), doneAction: 2);
        var f = (freq * freqMult).clip(150, 18000);
        var mod = SinOsc.ar(f * 1.83) * (f * 0.4);
        var sig = SinOsc.ar(f + mod) * env;
        var noise = HPF.ar(WhiteNoise.ar, 6000) * EnvGen.ar(Env.perc(0.0001, 0.005));
        var finalSig;

        sig = (sig * 0.8) + (noise * 0.2);
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_modalBasin, { |out=0, recOut=0, freq=62, amp=0.3, pan=0, decayScale=0.5, rq=0.08|
        var env = EnvGen.ar(Env.perc(0.01, (decayScale * 2.2).clip(0.1, 8.0)), doneAction: 2);
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.002, 0.03));
        var freqs = [1.0, 2.14, 3.42, 5.12, 7.28] * freq;
        var amps  = [1.0, 0.65, 0.45, 0.28, 0.15];
        var rings = [1.8, 1.4,  1.1,  0.8,  0.5] * decayScale;
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        var finalSig;

        sig = LeakDC.ar(sig) * env;
        sig = BPF.ar(sig, (freq * 3).clip(40, 16000), rq.clip(0.01, 1.0)) * 2.0 + (sig * 0.5);
        finalSig = Pan2.ar(sig.tanh * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_sprayImpact, { |out=0, recOut=0, freq=120, cutoff=4000, amp=0.5, pan=0, rel=0.6|
        var env = EnvGen.ar(Env.perc(0.003, rel), doneAction: 2);
        var noise = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, rel * 0.8));
        var click = HPF.ar(WhiteNoise.ar * 2.0, 2000) * EnvGen.ar(Env.perc(0.0002, 0.01));
        var body = SinOsc.ar(XLine.ar(freq * 3, freq * 0.5, 0.08)) * EnvGen.ar(Env.perc(0.005, rel * 0.5));
        var sig, finalSig;

        noise = MoogFF.ar(noise, cutoff.clip(100, 18000), 2.0) * 2.5;
        sig = (noise + click + body).fold2(0.9) * env;
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_cavitation, { |out=0, recOut=0, freq=35, amp=0.6, pan=0|
        var pEnv = XLine.ar(freq * 4, freq, 0.09);
        var env = EnvGen.ar(Env.perc(0.004, 0.8, curve: -4), doneAction: 2);
        var sig = SinOsc.ar(pEnv) * env;
        var finalSig;

        sig = (sig * 2.0).tanh;
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE (Continuous & Filter Slots)
    // --------------------------------------------------------------------
    Ndef(\lit_hydroDrone, { |amp=0, cutoff=1800, rq=0.4, rmFreq=48, rmDepth=0, spread=0.5|
        var noise = PinkNoise.ar(0.6) + BrownNoise.ar(0.4);
        var rm = SinOsc.ar(rmFreq);
        var sig = BPF.ar(noise, cutoff.clip(50, 16000), rq.clip(0.05, 1.0)) * (2.0 / rq.sqrt);
        sig = XFade2.ar(sig, sig * rm, (rmDepth * 2) - 1);
        sig = sig + CombC.ar(sig, 0.2, [0.035, 0.048] * (1 + (spread * 0.05)), 1.2, 0.3);
        sig = LeakDC.ar(sig);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\lit_hydroDrone).play(~lit_recBuses.hydro);

    Ndef(\lit_neriticSwell, { |amp=0, baseFreq=42, tideDepth=0.5, lpf=800, panSpeed=0.1, subMix=0.7|
        var carrier, mod1, mod2, sig, sub;
        var modFreq1 = baseFreq * 1.5;
        var modFreq2 = baseFreq * 0.75;
        var panMod = SinOsc.kr(panSpeed);

        mod2 = SinOsc.ar(modFreq2) * (modFreq2 * tideDepth * 1.5);
        mod1 = SinOsc.ar(modFreq1 + mod2) * (modFreq1 * tideDepth);
        carrier = SinOsc.ar(baseFreq + mod1);

        sub = SinOsc.ar(baseFreq * 0.5) * subMix;
        sig = (carrier * 0.6) + sub;
        sig = LPF.ar(sig, lpf.clip(40, 18000));
        sig = LeakDC.ar(sig).tanh;

        Pan2.ar(sig * amp, panMod);
    });
    Ndef(\lit_neriticSwell).play(~lit_recBuses.swell);

    Ndef(\lit_masterFX, {
        var synths = In.ar(~lit_synthBus, 2);
        var hydro = Ndef.ar(\lit_hydroDrone, 2);
        var swell = Ndef.ar(\lit_neriticSwell, 2);
        synths + hydro + swell;
    });

    // Reverb / Diffusion Filter Slot (wet10 generated internally by JITLib)
    Ndef(\lit_masterFX)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.35);
        verb;
    };
    Ndef(\lit_masterFX).set(\wet10, 0.0);

    Ndef(\lit_masterFX).play;
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~lit_startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;

        ~lit_recSynths = ();

        "--- LITORAL MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving files to: %".format(~lit_recFolder).postln;

        ~lit_recBuses.keysValuesDo { |name, bus|
            path = ~lit_recFolder ++ timestamp ++ "_lit_" ++ name ++ ".wav";
            ~lit_recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~lit_recBuses.keysValuesDo { |name, bus|
            ~lit_recSynths[name] = Synth.tail(RootNode(s), \lit_diskRecorder, [\bus, bus, \bufnum, ~lit_recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~lit_stopRecording.value });
    };

    ~lit_stopRecording = {
        if(~lit_recSynths.notNil) {
            "--- CLOSING LITORAL AUDIO FILES ---".postln;
            ~lit_recSynths.do(_.free);
            ~lit_recBufs.do(_.close);
            ~lit_recBufs.do(_.free);
            ~lit_recSynths = nil;
            "Litoral Multitrack Recording Closed Safely.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: Absolute Duration 150.0s)
    // --------------------------------------------------------------------
    Tdef(\lit_timeline, {
        if(~enableRecording) {
            ~lit_startRecording.value;
        } {
            "--- LITORAL PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        // ================================================================
        // PHASE I: SUPRATIDAL ZONE (0:00.0 - 0:28.0)
        // ================================================================

        // 0:00.0 — [Cue 0: Safety Breathing Room (0.5s)]
        0.5.wait;

        // 0:00.5 — [Cue 1: Crystalline Spray Ignition (1.8s)]
        "0:00.5 - [Cue 1: Crystalline Spray Ignition]".postln;
        Ndef(\lit_masterFX).set(\wet10, 0.0);
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125, // Fast 64th notes
            \freq, Pexprand(4000, 9000, inf),
            \freqMult, 1.0,
            \ring, Pwhite(0.005, 0.02, inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, Pwhite(0.12, 0.25, inf)
        ).play;
        1.8.wait;

        // 0:02.3 — [Cue 2: Micro-Fracture Shift (1.8s)]
        "0:02.3 - [Cue 2: Micro-Fracture Shift]".postln;
        Pbindef(\lit_clicks,
            \freqMult, 0.72,
            \dur, Pseq([0.03125, 0.0625, 0.03125], inf),
            \amp, Pwhite(0.15, 0.3, inf)
        );
        1.8.wait;

        // 0:04.1 — [Cue 3: Subtractive Salt Flat Drone (9.3s)]
        "0:04.1 - [Cue 3: Subtractive Salt Flat Drone]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.35, \cutoff, 1800, \rq, 0.4, \rmDepth, 0.0);

        Pbindef(\lit_clicks,
            \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf),
            \freqMult, 1.0,
            \amp, 0.1
        );

        // Active Wait: 9.3s -> 3 iterations
        3.do { |i|
            Ndef(\lit_hydroDrone).xset(\cutoff, 1600 + (i * 120));
            3.1.wait;
        };

        // 0:13.4 — [Cue 4: Saline Crackle Snap (1.2s)]
        "0:13.4 - [Cue 4: Saline Crackle Snap]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 380,
            \cutoff, 12000,
            \amp, 0.45,
            \pan, 0.2,
            \rel, 0.25
        ]);
        1.2.wait;

        // 0:14.6 — [Cue 5: Supratidal Wind & Modulation (7.2s)]
        "0:14.6 - [Cue 5: Supratidal Wind & Modulation]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 1.0;
        Ndef(\lit_hydroDrone).xset(\rq, 0.12, \rmFreq, 48, \rmDepth, 0.65, \amp, 0.45);

        // Active Wait: 7.2s -> 2 iterations
        2.do { |i|
            Ndef(\lit_hydroDrone).xset(\cutoff, 1400 + (i * 400));
            3.6.wait;
        };

        // 0:21.8 — [Cue 6: Kinetic Gravel Scuff (1.4s)]
        "0:21.8 - [Cue 6: Kinetic Gravel Scuff]".postln;
        Pbindef(\lit_clicks,
            \dur, 0.04,
            \freq, Pseq([3100, 4800, 2900, 5200, 7100], inf),
            \freqMult, 1.35,
            \ring, 0.008,
            \amp, 0.32
        );
        1.4.wait;

        // 0:23.2 — [Cue 7: Receding Foam Swell (4.8s)]
        "0:23.2 - [Cue 7: Receding Foam Swell]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.2, \cutoff, 800, \rq, 0.5, \rmDepth, 0.1);
        Ndef(\lit_masterFX).set(\wet10, 0.45);
        4.8.wait;

        // ================================================================
        // PHASE II: INTERTIDAL SWASH & BASIN DYNAMICS (0:28.0 - 1:12.5)
        // ================================================================

        // 0:28.0 — [Cue 8: Hydraulic Slam (1.2s)]
        "0:28.0 - [Cue 8: Hydraulic Slam]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 85,
            \cutoff, 6500,
            \amp, 0.7,
            \pan, -0.1,
            \rel, 1.1
        ]);
        Ndef(\lit_masterFX).set(\wet10, 0.35);

        Pbindef(\lit_surge,
            \instrument, \lit_modalBasin,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.surge,
            \dur, Pseq([0.8, 1.2, 0.6, 1.4], inf),
            \freq, 62,
            \decayScale, 0.4,
            \rq, 0.15,
            \pan, Pwhite(-0.5, 0.5, inf),
            \amp, 0.35
        ).play;
        1.2.wait;

        // 0:29.2 — [Cue 9: Modal Basin Resonance (9.3s)]
        "0:29.2 - [Cue 9: Modal Basin Resonance]".postln;
        // Active Wait: 9.3s -> 3 iterations
        3.do { |i|
            Pbindef(\lit_surge, \decayScale, 0.4 + (i * 0.35), \amp, 0.35 + (i * 0.05));
            3.1.wait;
        };

        // 0:38.5 — [Cue 10: Wave Crest Break (1.6s)]
        "0:38.5 - [Cue 10: Wave Crest Break]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.2;
        Ndef(\lit_hydroDrone).xset(\amp, 0.65, \cutoff, 9500, \rq, 0.6, \rmDepth, 0.0);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 140,
            \cutoff, 11000,
            \amp, 0.55,
            \pan, 0.35,
            \rel, 0.8
        ]);
        1.6.wait;

        // 0:40.1 — [Cue 11: Intertidal Undertow (8.2s)]
        "0:40.1 - [Cue 11: Intertidal Undertow (SUBTRACTION)]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.8;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0); // Subtraction

        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, Pwhite(0.04, 0.12, inf),
            \freq, Pexprand(2200, 6000, inf),
            \freqMult, 0.85,
            \ring, 0.01,
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, Pwhite(0.08, 0.18, inf)
        ).play;

        // Active Wait: 8.2s -> 2 iterations
        2.do { |i|
            Pbindef(\lit_surge, \decayScale, 1.2 - (i * 0.3));
            4.1.wait;
        };

        // 0:48.3 — [Cue 12: Cavitation Pop (1.4s)]
        "0:48.3 - [Cue 12: Cavitation Pop]".postln;
        Synth(\lit_cavitation, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 35,
            \amp, 0.75,
            \pan, 0.0
        ]);
        1.4.wait;

        // 0:49.7 — [Cue 13: Rising High-Water Mark (8.5s) - Form Operation B]
        "0:49.7 - [Cue 13: Rising High-Water Mark (Intrinsic Limit)]".postln;
        Pbindef(\lit_clicks, \dur, 0.02, \amp, 0.15);

        // Active Wait: 8.5s -> 3 iterations approaching saturation limit
        3.do { |i|
            var factor = (i + 1) / 3.0;
            Pbindef(\lit_surge,
                \dur, 0.5 - (factor * 0.25),
                \decayScale, 1.2 + (factor * 1.8),
                \amp, 0.35 + (factor * 0.2)
            );
            Ndef(\lit_masterFX).set(\wet10, 0.35 + (factor * 0.25));
            2.83.wait;
        };

        // 0:58.2 — [Cue 14: Saturation Threshold (2.4s)]
        "0:58.2 - [Cue 14: Saturation Threshold]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 70,
            \cutoff, 15000,
            \amp, 0.75,
            \pan, 0.0,
            \rel, 2.0
        ]);
        Pbindef(\lit_surge, \decayScale, 3.2, \amp, 0.55);
        2.4.wait;

        // 1:00.6 — [Cue 15: The Tidal Void (1.4s) - Form Operation C]
        "1:00.6 - [Cue 15: The Tidal Void (RADICAL SUBTRACTION)]".postln;
        Pbindef(\lit_surge).stop;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_hydroDrone).fadeTime = 0.05;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0);
        Ndef(\lit_masterFX).set(\wet10, 0.0); // Reverb wet cut dry

        // Single isolated tide-pool droplet
        Synth(\lit_crustClick, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \freq, 3200,
            \ring, 0.06,
            \amp, 0.25,
            \pan, 0.1
        ]);
        1.4.wait;

        // 1:02.0 — [Cue 16: Tide-Pool Reflection (10.5s)]
        "1:02.0 - [Cue 16: Tide-Pool Reflection]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.18, \baseFreq, 124, \tideDepth, 0.15, \lpf, 2200, \subMix, 0.2);

        // Active Wait: 10.5s -> 3 iterations
        3.do { |i|
            if(i == 1) {
                Synth(\lit_crustClick, [
                    \out, ~lit_synthBus,
                    \recOut, ~lit_recBuses.clicks,
                    \freq, 4800,
                    \ring, 0.05,
                    \amp, 0.18,
                    \pan, -0.3
                ]);
            };
            3.5.wait;
        };

        // ================================================================
        // PHASE III: SUBMERGED NERITIC SHELF (1:12.5 - 1:55.0)
        // ================================================================

        // 1:12.5 — [Cue 17: Submersion Plunge (1.7s)]
        "1:12.5 - [Cue 17: Submersion Plunge]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 1.5;
        Ndef(\lit_neriticSwell).xset(\lpf, 180, \baseFreq, 42, \subMix, 0.8, \amp, 0.5);
        1.7.wait;

        // 1:14.2 — [Cue 18: Neritic Mass (10.6s)]
        "1:14.2 - [Cue 18: Neritic Mass]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 4.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.65, \tideDepth, 2.2, \baseFreq, 38, \lpf, 260);

        // Active Wait: 10.6s -> 3 iterations
        3.do { |i|
            Ndef(\lit_neriticSwell).xset(\tideDepth, 2.0 + (i * 0.6));
            3.53.wait;
        };

        // 1:24.8 — [Cue 19: Bioluminescent Trigger (2.3s)]
        "1:24.8 - [Cue 19: Bioluminescent Trigger]".postln;
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125,
            \freq, Pexprand(6000, 12000, inf),
            \freqMult, 1.0,
            \ring, Pwhite(0.003, 0.01, inf),
            \pan, Pwhite(-0.9, 0.9, inf),
            \amp, 0.15
        ).play;
        2.3.wait;

        // 1:27.1 — [Cue 20: Shelf-Break Drop-off (8.3s)]
        "1:27.1 - [Cue 20: Shelf-Break Drop-off]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\baseFreq, 28, \tideDepth, 3.8, \panSpeed, 0.05);

        // Active Wait: 8.3s -> 2 iterations
        2.do { |i|
            Ndef(\lit_neriticSwell).xset(\lpf, 220 - (i * 40));
            4.15.wait;
        };

        // 1:35.4 — [Cue 21: Abyssal Ping (1.4s)]
        "1:35.4 - [Cue 21: Abyssal Ping]".postln;
        Ndef(\lit_masterFX).set(\wet10, 0.6);
        Synth(\lit_modalBasin, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.surge,
            \freq, 185,
            \decayScale, 3.8,
            \rq, 0.02,
            \amp, 0.45,
            \pan, 0.0
        ]);
        1.4.wait;

        // 1:36.8 — [Cue 22: Pelagic Pressure Field (10.4s)]
        "1:36.8 - [Cue 22: Pelagic Pressure Field]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.75, \tideDepth, 4.2);

        // Active Wait: 10.4s -> 3 iterations
        3.do { |i|
            Ndef(\lit_neriticSwell).xset(\baseFreq, 32 + (i * 3));
            3.46.wait;
        };

        // 1:47.2 — [Cue 23: Shear-Stress Turbulence (2.3s)]
        "1:47.2 - [Cue 23: Shear-Stress Turbulence]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.4;
        Ndef(\lit_hydroDrone).xset(\amp, 0.6, \cutoff, 420, \rq, 0.2, \rmDepth, 0.5, \rmFreq, 24);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 50,
            \cutoff, 1200,
            \amp, 0.65,
            \pan, -0.4,
            \rel, 1.2
        ]);
        2.3.wait;

        // 1:49.5 — [Cue 24: Sub-Marine Vortex (5.5s)]
        "1:49.5 - [Cue 24: Sub-Marine Vortex]".postln;
        Ndef(\lit_neriticSwell).xset(\panSpeed, 0.8, \lpf, 380);
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.35, \cutoff, 250);

        // Active Wait: 5.5s -> 2 iterations
        2.do { |i|
            Ndef(\lit_neriticSwell).xset(\tideDepth, 3.5 - (i * 0.8));
            2.75.wait;
        };

        // ================================================================
        // PHASE IV: HORIZON DISPERSION & TERMINATION (1:55.0 - 2:30.0)
        // ================================================================

        // 1:55.0 — [Cue 25: Flashback to the Surface (1.2s) - Form Operation A]
        "1:55.0 - [Cue 25: Flashback to the Surface (Form Operation A)]".postln;
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125,
            \freq, Pexprand(4500, 9500, inf),
            \freqMult, 1.0,
            \ring, 0.012,
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, 0.28
        ).play;
        1.2.wait;

        // 1:56.2 — [Cue 26: Dual-Horizon Friction (11.2s)]
        "1:56.2 - [Cue 26: Dual-Horizon Friction]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.5, \baseFreq, 38, \lpf, 200, \panSpeed, 0.1);

        // Active Wait: 11.2s -> 3 iterations
        3.do { |i|
            Pbindef(\lit_clicks, \freqMult, 1.0 + (i * 0.15));
            3.73.wait;
        };

        // 2:07.4 — [Cue 27: Cavitation Impact (2.2s)]
        "2:07.4 - [Cue 27: Cavitation Impact]".postln;
        Synth(\lit_cavitation, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 40,
            \amp, 0.7,
            \pan, 0.0
        ]);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 110,
            \cutoff, 5000,
            \amp, 0.5,
            \pan, 0.2,
            \rel, 0.5
        ]);
        2.2.wait;

        // 2:09.6 — [Cue 28: Evaporation & Updraft (8.4s)]
        "2:09.6 - [Cue 28: Evaporation & Updraft (SUBTRACTION)]".postln;
        // Subtraction: cut sub-bass, move into suspended high vapor
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\subMix, 0.0, \baseFreq, 380, \tideDepth, 0.2, \lpf, 12000, \amp, 0.25);
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0);
        Ndef(\lit_masterFX).set(\wet10, 0.7);

        // Active Wait: 8.4s -> 2 iterations
        2.do { |i|
            Pbindef(\lit_clicks, \amp, 0.18 - (i * 0.07));
            4.2.wait;
        };

        // 2:18.0 — [Cue 29: White-Water Dispersion (2.5s)]
        "2:18.0 - [Cue 29: White-Water Dispersion]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.12, \baseFreq, 620);
        2.5.wait;

        // 2:20.5 — [Cue 30: Residual Spectral Tail (8.0s)]
        "2:20.5 - [Cue 30: Residual Spectral Tail]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 6.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.0);
        Ndef(\lit_masterFX).fadeTime = 6.0;

        // Active Wait: 8.0s -> 2 iterations
        2.do { |i|
            if(i == 1) {
                Ndef(\lit_masterFX).set(\wet10, 0.2);
            };
            4.0.wait;
        };

        // 2:28.5 — [Cue 31: Extrinsic Local Termination (1.5s) - Form Operation D]
        "2:28.5 - [Cue 31: Extrinsic Local Termination (Form Operation D)]".postln;
        1.5.wait;

        // Absolute precise stop at 150.0s (2:30.0)
        "2:30.0 - Score Complete. Performing Clean Local Termination.".postln;

        // Stop multitrack recorder safely
        ~lit_stopRecording.value;

        // Stop & Clear ONLY local Pbindefs
        Pbindef(\lit_clicks).stop;
        Pbindef(\lit_clicks).clear;
        Pbindef(\lit_surge).stop;
        Pbindef(\lit_surge).clear;

        // Stop & Clear ONLY local Ndefs
        Ndef(\lit_hydroDrone).stop(0.1);
        Ndef(\lit_hydroDrone).clear;
        Ndef(\lit_neriticSwell).stop(0.1);
        Ndef(\lit_neriticSwell).clear;
        Ndef(\lit_masterFX).stop(0.1);
        Ndef(\lit_masterFX).clear;

        // Free dedicated buffers & buses
        ~lit_fftBufL.free;
        ~lit_fftBufR.free;
        ~lit_synthBus.free;
        ~lit_recBuses.keysValuesDo { |name, bus|
            if(bus.isKindOf(Bus)) { bus.free };
        };

        // Stop ONLY local timeline Tdef
        Tdef(\lit_timeline).stop;
    });

    s.sync;

    // Start master score
    Tdef(\lit_timeline).play;
});
)

// Source: 2026-11-16_20-29-00.scd [Block 1]
// MODE: compose
// THEME: History, as it was on Mon Nov 16 20:35:27 2026.
// KEYWORDS: allpassc, bpf, compose, duchessBell, duchessFrame, dynklank, freeverb2, gazeDrone, history, masterMix, mon, nov, portraitBreath, safetyLimiter, saw, sinosc, wallScratch, was
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

    SynthDef(\duchessBell, { |out=0, freq=440, amp=0.12, pan=0, decay=2.5, strike=0.2|
        var env, hit, modes, sig;
        env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        hit = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.025))) + (SinOsc.ar(freq * 1.7) * strike);
        modes = DynKlank.ar(Ref([[1, 2.71, 4.13, 6.8], [1, 0.55, 0.31, 0.16], [1, 0.72, 0.45, 0.28]]), hit, freq);
        sig = (modes * env * amp).tanh;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\wallScratch, { |out=0, freq=280, amp=0.08, pan=0, dur=0.35|
        var env, grit, reson, sig;
        env = EnvGen.ar(Env.perc(0.004, dur.max(0.05), 1, -4), doneAction: 2);
        grit = BPF.ar(WhiteNoise.ar, freq.clip(100, 6000), 0.16) * 8;
        reson = AllpassC.ar(grit, 0.08, LFNoise1.kr(8).range(0.004, 0.07), 0.18);
        sig = (grit * 0.45 + reson * 0.55).tanh * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    Ndef(\portraitBreath, { |amp=0, cutoff=1500, sway=0.08|
        var breath, pulse, tone;
        breath = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.12).range(350, cutoff), 0.55);
        pulse = SinOsc.kr(0.17).range(0.18, 1);
        tone = SinOsc.ar([73, 73.6]) * 0.12;
        Splay.ar([breath * pulse, tone], sway, amp);
    });
    Ndef(\gazeDrone, { |amp=0, freq=110, edge=0.2|
        var source, shimmer, sig;
        source = Saw.ar([freq, freq * 1.006]) * 0.12;
        shimmer = SinOsc.ar([freq * 2.71, freq * 2.73]) * edge;
        sig = LPF.ar(source + shimmer, SinOsc.kr(0.09).range(260, 1200));
        Splay.ar(sig.tanh, 0.65, amp);
    });
    Ndef(\portraitBreath).fadeTime = 3;
    Ndef(\gazeDrone).fadeTime = 4;

    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2) + Ndef(\portraitBreath).ar(2) + Ndef(\gazeDrone).ar(2);
        sig;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.24)
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        [DelayC.ar(in[0], 0.45, 0.31), DelayC.ar(in[1], 0.45, 0.37)]
    };
    Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0.12);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\duchessFrame,
        \instrument, \duchessBell,
        \out, ~synthBus,
        \midinote, Pseq([62, 69, 66, 74, 69, 62], inf),
        \dur, Pseq([2.4, 1.2, 2.4, 1.2, 3.6, 2.4], inf),
        \amp, Pseq([0.12, 0.07, 0.09, 0.13, 0.07, 0.1], inf),
        \decay, Pwhite(1.5, 3.2),
        \strike, Pwhite(0.08, 0.28),
        \pan, Pwhite(-0.55, 0.55)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - A portrait fixed to the wall; the room listens.".postln;
        Ndef(\portraitBreath).xset(\amp, 0.16, \cutoff, 900, \sway, 0.12);
        Ndef(\gazeDrone).xset(\amp, 0.05, \freq, 110, \edge, 0.12);
        Pbindef(\duchessFrame).play;
        4.do { |i|
            Ndef(\portraitBreath).xset(\cutoff, [700, 1200, 850, 1600][i]);
            3.wait;
        };

        "0:12 - A measured gaze; the frame begins to answer.".postln;
        6.do { |i|
            Synth(\wallScratch, [
                \out, ~synthBus, \freq, [380, 720, 540, 1100, 460, 900][i],
                \amp, 0.045, \pan, [-0.6, 0.4, -0.2, 0.65, -0.45, 0.15][i],
                \dur, 0.28
            ]);
            if (i % 2 == 0) {
                Synth(\duchessBell, [
                    \out, ~synthBus, \freq, [155, 207, 174][i / 2],
                    \amp, 0.07, \decay, 2.2, \pan, 0.2
                ]);
            };
            1.7.wait;
        };

        "0:23 - The painted stillness reaches its limit.".postln;
        Ndef(\gazeDrone).xset(\amp, 0.11, \freq, 146, \edge, 0.75);
        4.do { |i|
            Ndef(\gazeDrone).xset(\freq, [146, 196, 233, 293][i], \edge, [0.3, 0.5, 0.7, 0.95][i]);
            Synth(\wallScratch, [\out, ~synthBus, \freq, 1200 + (i * 380), \amp, 0.055, \pan, 0.5 - (i * 0.3), \dur, 0.55]);
            2.wait;
        };

        "0:31 - Sudden settling: only breath behind the varnish.".postln;
        Pbindef(\duchessFrame).stop;
        Ndef(\gazeDrone).xset(\amp, 0);
        3.wait;
        3.do { |i|
            Synth(\duchessBell, [\out, ~synthBus, \freq, [155, 207, 155][i], \amp, 0.045, \decay, 3.5, \pan, 0]);
            Ndef(\portraitBreath).xset(\cutoff, [460, 620, 380][i], \amp, 0.11);
            3.wait;
        };

        "0:40 - Flashback: the first notes return, smaller.".postln;
        Ndef(\gazeDrone).xset(\amp, 0.035, \freq, 110, \edge, 0.08);
        2.do { |i|
            Synth(\duchessBell, [\out, ~synthBus, \freq, [155, 207][i], \amp, 0.035, \decay, 2.8, \pan, 0]);
            3.wait;
        };

        "0:46 - The portrait remains; the sound cuts away.".postln;
        Pbindef(\duchessFrame).stop;
        Pbindef(\duchessFrame).clear;
        Ndef(\portraitBreath).clear(3);
        Ndef(\gazeDrone).clear(3);
        3.wait;
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    }).play;
});
)

// Source: 2026-11-16_20-29-00.scd [Block 4]
// MODE: compose
// THEME: - 0:1:33.84 -
// KEYWORDS: allpassc, bpf, compose, dynklank, freeverb2, pinknoise, safetyLimiter, sentidoAr, sentidoHorizonte, sentidoLingua, sentidoLinguaSeq, sentidoToque, sentidoToqueSeq, sentidosMix, sinosc
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

    SynthDef(\sentidoToque, { |out=0, freq=440, amp=0.1, pan=0, decay=0.2|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        exc = WhiteNoise.ar * env;
        sig = DynKlank.ar(Ref([[1, 2.71, 4.13], [1, 0.42, 0.2], [0.08, 0.16, 0.24]]), exc, freq);
        sig = (sig * 0.3).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\sentidoLingua, { |out=0, freq=220, amp=0.1, pan=0, decay=0.5|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        mod = SinOsc.ar(freq * 2.73) * freq * 1.4 * env;
        sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    Ndef(\sentidoAr, { |amp=0, rate=0.17, tone=320|
        var breath, shimmer;
        breath = BPF.ar(PinkNoise.ar, SinOsc.kr(rate).range(180, tone * 2), 0.24) * 4;
        shimmer = SinOsc.ar([tone, tone * 1.003], 0, 0.08);
        Splay.ar([breath * 0.12, shimmer]) * amp;
    });
    Ndef(\sentidoHorizonte, { |amp=0, drift=0.08, pitch=55|
        var low, upper, pulse;
        pulse = SinOsc.kr(drift).range(0.2, 0.8);
        low = SinOsc.ar(pitch) * 0.16 + SinOsc.ar(pitch * 2) * 0.08;
        upper = LFTri.ar(pitch * 3.01) * 0.035;
        [low + upper, low - upper] * pulse * amp;
    });

    Ndef(\sentidosMix, {
        var sig;
        sig = In.ar(~synthBus, 2) + Ndef.ar(\sentidoAr, 2) + Ndef.ar(\sentidoHorizonte, 2);
        sig;
    });
    Ndef(\sentidosMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.7, 0.28) };
    Ndef(\sentidosMix)[11] = \filter -> { |in| AllpassC.ar(in, 0.2, [0.11, 0.14], 1.2) };
    Ndef(\sentidosMix).set(\wet10, 0.18, \wet11, 0.12);
    Ndef(\sentidosMix).play;
    s.sync;

    Pbindef(\sentidoToqueSeq,
        \instrument, \sentidoToque, \out, ~synthBus,
        \scale, Scale.minor, \degree, Pseq([0, 3, 5, 2, 7, 5, 1], inf),
        \octave, Pseq([5, 6, 5, 7], inf), \dur, Pseq([0.25, 0.5, 0.25, 0.75], inf),
        \decay, Pwhite(0.08, 0.24), \amp, 0.12, \pan, Pwhite(-0.8, 0.8)
    );
    Pbindef(\sentidoLinguaSeq,
        \instrument, \sentidoLingua, \out, ~synthBus,
        \midinote, Pseq([60, 63, 67, 70, 67, 65, 72], inf),
        \dur, Pseq([1, 0.5, 0.5, 1.5], inf), \decay, 0.55,
        \amp, 0.075, \pan, Pwhite(-0.5, 0.5)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - O corpo já sabe: pés, olhos, língua.".postln;
        Ndef(\sentidoAr).fadeTime = 4;
        Ndef(\sentidoAr).xset(\amp, 0.35, \rate, 0.17, \tone, 320);
        Pbindef(\sentidoToqueSeq).play;
        5.wait;
        "0:05 - A pele responde; o toque encontra superfícies.".postln;
        Pbindef(\sentidoLinguaSeq).play;
        Ndef(\sentidoHorizonte).fadeTime = 5;
        Ndef(\sentidoHorizonte).xset(\amp, 0.22, \pitch, 55);
        6.wait;
        3.do { |i|
            Ndef(\sentidoAr).xset(\tone, [460, 730, 1080][i], \rate, [0.31, 0.49, 0.22][i]);
            Pbindef(\sentidoToqueSeq, \dur, Pseq([[0.25, 0.25, 0.5, 0.125], [0.5, 0.25, 0.25, 0.375], [0.125, 0.375, 0.25, 0.5]][i], inf));
            4.wait;
        };
        "0:23 - O desejo excede a medida: o horizonte se aproxima.".postln;
        Ndef(\sentidoHorizonte).xset(\pitch, 92, \drift, 0.23, \amp, 0.3);
        Pbindef(\sentidoLinguaSeq, \midinote, Pseq([72, 75, 79, 82, 87, 84, 79], inf), \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf));
        6.wait;
        "0:29 - Limite: a respiração acelera até quase virar luz.".postln;
        3.do { |i|
            Ndef(\sentidoAr).xset(\tone, [1400, 2100, 3000][i], \rate, [0.7, 1.1, 1.8][i]);
            2.wait;
        };
        "0:35 - Queda súbita; resta um pulso, uma lembrança.".postln;
        Pbindef(\sentidoToqueSeq).stop;
        Ndef(\sentidoAr).xset(\amp, 0.06);
        Ndef(\sentidoHorizonte).xset(\pitch, 55, \drift, 0.08, \amp, 0.14);
        Pbindef(\sentidoLinguaSeq, \midinote, Pseq([60, 63, 67, 63], inf), \dur, 1, \amp, 0.045);
        5.wait;
        "0:40 - Resolução: e se o próximo sentido fosse o gesto?".postln;
        Ndef(\sentidoAr).xset(\tone, 320, \rate, 0.17, \amp, 0.12);
        Pbindef(\sentidoLinguaSeq).stop;
        4.wait;
        Pbindef(\sentidoToqueSeq).clear;
        Pbindef(\sentidoLinguaSeq).clear;
        Ndef(\sentidoAr).clear(2);
        Ndef(\sentidoHorizonte).clear(2);
        Ndef(\sentidosMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

// Source: 2026-11-16_20-29-00.scd [Block 5]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, compose, delayTexture, eggPluck, eggSequence, first, fold, fornoHum, freeverb2, hpf, leiteOleoDrone, limiter, master, mixAmp, mixRhythm, mixThud, persistent, polvilhoAmbience, queijoTexture, rlpf, rollAmp, rollRhythm, rollingTap, safety, safetyLimiter, salCrack, saltShot, sinosc
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

// Source: 2026-11-16_20-29-00.scd [Block 8]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, compose, delayTexture, eggPluck, eggSequence, first, fold, fornoHum, freeverb2, hpf, leiteOleoDrone, limiter, master, mixAmp, mixRhythm, mixThud, persistent, polvilhoAmbience, queijoTexture, rlpf, rollAmp, rollRhythm, rollingTap, safety, safetyLimiter, salCrack, saltShot, sinosc
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

// Source: sync-composition-example.scd [Block 1]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, combl, compose, first, gverb, hpf, limiter, master, persistent, probePulse, probeSeq, rlpf, safety, safetyLimiter, saw, solarSeq, solarWind, voidPad, voidSeq
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter catches any peaks above 0.95 silently and transparently
    sig = Limiter.ar(sig, level: 0.95, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };


// =====================================================================
// 1. INSTRUMENTS & EFFECTS (JITLib)
// =====================================================================

// Set fade times to dictate how long .xset crossfades will take
Ndef(\voidPad).fadeTime = 4;
Ndef(\probePulse).fadeTime = 2;
Ndef(\solarWind).fadeTime = 3;

Ndef(\voidPad, {
    |freq=40, freqMult=1, amp=0.3, t_trig=1, hpfFreq=20, lpfFreq=2000|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 3]), t_trig);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * 1.01]);
    var sub = SinOsc.ar([freq * freqMult * 0.5, freq * freqMult * 0.505]);
    sig = RLPF.ar(sig + sub, lpfFreq, 0.4);
    sig = HPF.ar(sig, hpfFreq);
    sig * env * amp;
});

Ndef(\probePulse, {
    |freq=2000, freqMult=1, modFreq=500, modIndex=1, amp=0.35, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
    var mod = SinOsc.ar(modFreq) * modIndex * (freq * freqMult);
    var sig = SinOsc.ar((freq * freqMult) + mod);
    Pan2.ar(sig * env * amp, 0);
});

Ndef(\solarWind, {
    |amp=0.25, t_trig=1, bpfFreq=2000, bpfMult=1, rq=0.1|
    var env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
    var sig = Array.fill(4, { PinkNoise.ar() + (WhiteNoise.ar() * 0.5) });
    // Clean resonant synthesis replacing the previous overdrive logic
    sig = BPF.ar(sig, bpfFreq * bpfMult, rq);
    Splay.ar(sig) * env * amp;
});

// Reverb (Index 10)
Ndef(\voidPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\voidPad).set(\wet10, 0);

// Delay (Index 11)
Ndef(\probePulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \decayTime.kr(0.5)) };
Ndef(\probePulse).set(\wet11, 0);


// =====================================================================
// 2. PATTERNS
// =====================================================================

Pbindef(\voidSeq, \dur, 8, \freq, Pseq([40, 42, 38, 45], inf), \t_trig, 1);
Pbindef(\probeSeq, \dur, 2, \freq, 2000, \modFreq, 500, \modIndex, 1, \t_trig, 1);
Pbindef(\solarSeq, \dur, Pwhite(0.05, 0.15), \bpfFreq, Pwhite(1000, 5000), \rq, 0.1, \t_trig, 1);

[Ndef(\voidPad), Ndef(\probePulse), Ndef(\solarWind)].do(_.quant_(1));


// =====================================================================
// 3. THE SCRIPT (Tdef - 2 Minute Score)
// =====================================================================

Tdef(\parkerScore, {

    "0:00 - [Movement I: Launch]".postln;
    Ndef(\voidPad).play;
    Ndef(\voidPad)[1] = \set -> Pbindef(\voidSeq);

    // .xset smoothly introduces the huge space reverb over 4 seconds
    Ndef(\voidPad).xset(\wet10, 0.8, \lpfFreq, 800);

    15.wait;

    "0:15 - [The Probe Activates]".postln;
    Ndef(\probePulse).play;
    Ndef(\probePulse)[1] = \set -> Pbindef(\probeSeq);

    // .set snaps the dry delay immediately for a stark contrast to the pad
    Ndef(\probePulse).set(\wet11, 0.2);

    20.wait; // Now at 0:35

    "0:35 - [Movement II: Acceleration]".postln;
    Pbindef(\probeSeq, \dur, 0.5);

    // Smoothly shift the multiplier and open up the delay tails over 2 seconds
    Ndef(\probePulse).xset(\freqMult, 1.2, \wet11, 0.6, \decayTime, 2);
    Ndef(\voidPad).xset(\hpfFreq, 150); // Slowly begin thinning the low end

    25.wait; // Now at 1:00

    "1:00 - [Movement III: Piercing the Corona]".postln;
    Pbindef(\probeSeq, \dur, 0.125, \modIndex, 4); // Instantly shift to fast, metallic pings

    Ndef(\solarWind).play;
    Ndef(\solarWind)[1] = \set -> Pbindef(\solarSeq);

    // Massive crossfade: thin the pad entirely, open up the probe delay to near-infinite
    Ndef(\voidPad).xset(\hpfFreq, 600, \lpfFreq, 4000);
    Ndef(\probePulse).xset(\wet11, 0.9, \decayTime, 6);

    30.wait; // Now at 1:30

    "1:30 - [Movement IV: Exiting to Void]".postln;
    Pbindef(\solarSeq).stop;
    Ndef(\solarWind).clear(4); // Fade out the continuous noise proxy over 4s

    Pbindef(\probeSeq, \dur, 2, \modIndex, 1);

    // Doppler effect: smooth drop in the frequency modifier and pull back the delay
    Ndef(\probePulse).xset(\freqMult, 0.8, \wet11, 0.3, \decayTime, 0.5);

    20.wait; // Now at 1:50

    "1:50 - [Telemetry Outro]".postln;
    Ndef(\voidPad).xset(\lpfFreq, 300); // Muffle the pad into darkness
    Ndef(\probePulse).xset(\freqMult, 0.5); // Final power down pitch shift

    10.wait; // Now at 2:00

    "2:00 - [Fade Out & Terminate]".postln;
    Pbindef(\voidSeq).stop;
    Pbindef(\probeSeq).stop;

    // Clear final nodes with a long, 10-second fade
    Ndef(\voidPad).clear(10);
    Ndef(\probePulse).clear(10);

    "Score Complete.".postln;
});
)

// Source: xappend-duquesa.scd [Block 1]
// MODE: compose
// THEME: Xduquesa sound structure with \portraitBreath, \gazeDrone
// KEYWORDS: allpassc, bpf, compose, duchessBell, duchessFrame, dynklank, freeverb2, gazeDrone, gazedrone, masterMix, portraitBreath, portraitbreath, safetyLimiter, saw, sinosc, structure, wallScratch, xduquesa
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

    SynthDef(\duchessBell, { |out=0, freq=440, amp=0.12, pan=0, decay=2.5, strike=0.2|
        var env, hit, modes, sig;
        env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        hit = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.025))) + (SinOsc.ar(freq * 1.7) * strike);
        modes = DynKlank.ar(Ref([[1, 2.71, 4.13, 6.8], [1, 0.55, 0.31, 0.16], [1, 0.72, 0.45, 0.28]]), hit, freq);
        sig = (modes * env * amp).tanh;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\wallScratch, { |out=0, freq=280, amp=0.08, pan=0, dur=0.35|
        var env, grit, reson, sig;
        env = EnvGen.ar(Env.perc(0.004, dur.max(0.05), 1, -4), doneAction: 2);
        grit = BPF.ar(WhiteNoise.ar, freq.clip(100, 6000), 0.16) * 8;
        reson = AllpassC.ar(grit, 0.08, LFNoise1.kr(8).range(0.004, 0.07), 0.18);
        sig = (grit * 0.45 + reson * 0.55).tanh * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    Ndef(\portraitBreath, { |amp=0, cutoff=1500, sway=0.08|
        var breath, pulse, tone;
        breath = BPF.ar(PinkNoise.ar, LFNoise1.kr(0.12).range(350, cutoff), 0.55);
        pulse = SinOsc.kr(0.17).range(0.18, 1);
        tone = SinOsc.ar([73, 73.6]) * 0.12;
        Splay.ar([breath * pulse, tone], sway, amp);
    });
    Ndef(\gazeDrone, { |amp=0, freq=110, edge=0.2|
        var source, shimmer, sig;
        source = Saw.ar([freq, freq * 1.006]) * 0.12;
        shimmer = SinOsc.ar([freq * 2.71, freq * 2.73]) * edge;
        sig = LPF.ar(source + shimmer, SinOsc.kr(0.09).range(260, 1200));
        Splay.ar(sig.tanh, 0.65, amp);
    });
    Ndef(\portraitBreath).fadeTime = 3;
    Ndef(\gazeDrone).fadeTime = 4;

    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2) + Ndef(\portraitBreath).ar(2) + Ndef(\gazeDrone).ar(2);
        sig;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.24)
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        [DelayC.ar(in[0], 0.45, 0.31), DelayC.ar(in[1], 0.45, 0.37)]
    };
    Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0.12);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\duchessFrame,
        \instrument, \duchessBell,
        \out, ~synthBus,
        \midinote, Pseq([62, 69, 66, 74, 69, 62], inf),
        \dur, Pseq([2.4, 1.2, 2.4, 1.2, 3.6, 2.4], inf),
        \amp, Pseq([0.12, 0.07, 0.09, 0.13, 0.07, 0.1], inf),
        \decay, Pwhite(1.5, 3.2),
        \strike, Pwhite(0.08, 0.28),
        \pan, Pwhite(-0.55, 0.55)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - A portrait fixed to the wall; the room listens.".postln;
        Ndef(\portraitBreath).xset(\amp, 0.16, \cutoff, 900, \sway, 0.12);
        Ndef(\gazeDrone).xset(\amp, 0.05, \freq, 110, \edge, 0.12);
        Pbindef(\duchessFrame).play;
        4.do { |i|
            Ndef(\portraitBreath).xset(\cutoff, [700, 1200, 850, 1600][i]);
            3.wait;
        };

        "0:12 - A measured gaze; the frame begins to answer.".postln;
        6.do { |i|
            Synth(\wallScratch, [
                \out, ~synthBus, \freq, [380, 720, 540, 1100, 460, 900][i],
                \amp, 0.045, \pan, [-0.6, 0.4, -0.2, 0.65, -0.45, 0.15][i],
                \dur, 0.28
            ]);
            if (i % 2 == 0) {
                Synth(\duchessBell, [
                    \out, ~synthBus, \freq, [155, 207, 174][i / 2],
                    \amp, 0.07, \decay, 2.2, \pan, 0.2
                ]);
            };
            1.7.wait;
        };

        "0:23 - The painted stillness reaches its limit.".postln;
        Ndef(\gazeDrone).xset(\amp, 0.11, \freq, 146, \edge, 0.75);
        4.do { |i|
            Ndef(\gazeDrone).xset(\freq, [146, 196, 233, 293][i], \edge, [0.3, 0.5, 0.7, 0.95][i]);
            Synth(\wallScratch, [\out, ~synthBus, \freq, 1200 + (i * 380), \amp, 0.055, \pan, 0.5 - (i * 0.3), \dur, 0.55]);
            2.wait;
        };

        "0:31 - Sudden settling: only breath behind the varnish.".postln;
        Pbindef(\duchessFrame).stop;
        Ndef(\gazeDrone).xset(\amp, 0);
        3.wait;
        3.do { |i|
            Synth(\duchessBell, [\out, ~synthBus, \freq, [155, 207, 155][i], \amp, 0.045, \decay, 3.5, \pan, 0]);
            Ndef(\portraitBreath).xset(\cutoff, [460, 620, 380][i], \amp, 0.11);
            3.wait;
        };

        "0:40 - Flashback: the first notes return, smaller.".postln;
        Ndef(\gazeDrone).xset(\amp, 0.035, \freq, 110, \edge, 0.08);
        2.do { |i|
            Synth(\duchessBell, [\out, ~synthBus, \freq, [155, 207][i], \amp, 0.035, \decay, 2.8, \pan, 0]);
            3.wait;
        };

        "0:46 - The portrait remains; the sound cuts away.".postln;
        Pbindef(\duchessFrame).stop;
        Pbindef(\duchessFrame).clear;
        Ndef(\portraitBreath).clear(3);
        Ndef(\gazeDrone).clear(3);
        3.wait;
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    }).play;
});
)

// Source: xappend-duquesa.scd [Block 4]
// MODE: compose
// THEME: --- Quiet new textures (uncomment to reduce volume to ~1/10) ---
// KEYWORDS: allpassc, bpf, compose, dynklank, freeverb2, new, pinknoise, quiet, reduce, safetyLimiter, sentidoAr, sentidoHorizonte, sentidoLingua, sentidoLinguaSeq, sentidoToque, sentidoToqueSeq, sentidosMix, sinosc, textures, uncomment, volume
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

    SynthDef(\sentidoToque, { |out=0, freq=440, amp=0.1, pan=0, decay=0.2|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        exc = WhiteNoise.ar * env;
        sig = DynKlank.ar(Ref([[1, 2.71, 4.13], [1, 0.42, 0.2], [0.08, 0.16, 0.24]]), exc, freq);
        sig = (sig * 0.3).tanh;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\sentidoLingua, { |out=0, freq=220, amp=0.1, pan=0, decay=0.5|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        mod = SinOsc.ar(freq * 2.73) * freq * 1.4 * env;
        sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    Ndef(\sentidoAr, { |amp=0, rate=0.17, tone=320|
        var breath, shimmer;
        breath = BPF.ar(PinkNoise.ar, SinOsc.kr(rate).range(180, tone * 2), 0.24) * 4;
        shimmer = SinOsc.ar([tone, tone * 1.003], 0, 0.08);
        Splay.ar([breath * 0.12, shimmer]) * amp;
    });
    Ndef(\sentidoHorizonte, { |amp=0, drift=0.08, pitch=55|
        var low, upper, pulse;
        pulse = SinOsc.kr(drift).range(0.2, 0.8);
        low = SinOsc.ar(pitch) * 0.16 + SinOsc.ar(pitch * 2) * 0.08;
        upper = LFTri.ar(pitch * 3.01) * 0.035;
        [low + upper, low - upper] * pulse * amp;
    });

    Ndef(\sentidosMix, {
        var sig;
        sig = In.ar(~synthBus, 2) + Ndef.ar(\sentidoAr, 2) + Ndef.ar(\sentidoHorizonte, 2);
        sig;
    });
    Ndef(\sentidosMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.7, 0.28) };
    Ndef(\sentidosMix)[11] = \filter -> { |in| AllpassC.ar(in, 0.2, [0.11, 0.14], 1.2) };
    Ndef(\sentidosMix).set(\wet10, 0.18, \wet11, 0.12);
    Ndef(\sentidosMix).play;
    s.sync;

    Pbindef(\sentidoToqueSeq,
        \instrument, \sentidoToque, \out, ~synthBus,
        \scale, Scale.minor, \degree, Pseq([0, 3, 5, 2, 7, 5, 1], inf),
        \octave, Pseq([5, 6, 5, 7], inf), \dur, Pseq([0.25, 0.5, 0.25, 0.75], inf),
        \decay, Pwhite(0.08, 0.24), \amp, 0.12, \pan, Pwhite(-0.8, 0.8)
    );
    Pbindef(\sentidoLinguaSeq,
        \instrument, \sentidoLingua, \out, ~synthBus,
        \midinote, Pseq([60, 63, 67, 70, 67, 65, 72], inf),
        \dur, Pseq([1, 0.5, 0.5, 1.5], inf), \decay, 0.55,
        \amp, 0.075, \pan, Pwhite(-0.5, 0.5)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - O corpo já sabe: pés, olhos, língua.".postln;
        Ndef(\sentidoAr).fadeTime = 4;
        Ndef(\sentidoAr).xset(\amp, 0.35, \rate, 0.17, \tone, 320);
        Pbindef(\sentidoToqueSeq).play;
        5.wait;
        "0:05 - A pele responde; o toque encontra superfícies.".postln;
        Pbindef(\sentidoLinguaSeq).play;
        Ndef(\sentidoHorizonte).fadeTime = 5;
        Ndef(\sentidoHorizonte).xset(\amp, 0.22, \pitch, 55);
        6.wait;
        3.do { |i|
            Ndef(\sentidoAr).xset(\tone, [460, 730, 1080][i], \rate, [0.31, 0.49, 0.22][i]);
            Pbindef(\sentidoToqueSeq, \dur, Pseq([[0.25, 0.25, 0.5, 0.125], [0.5, 0.25, 0.25, 0.375], [0.125, 0.375, 0.25, 0.5]][i], inf));
            4.wait;
        };
        "0:23 - O desejo excede a medida: o horizonte se aproxima.".postln;
        Ndef(\sentidoHorizonte).xset(\pitch, 92, \drift, 0.23, \amp, 0.3);
        Pbindef(\sentidoLinguaSeq, \midinote, Pseq([72, 75, 79, 82, 87, 84, 79], inf), \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf));
        6.wait;
        "0:29 - Limite: a respiração acelera até quase virar luz.".postln;
        3.do { |i|
            Ndef(\sentidoAr).xset(\tone, [1400, 2100, 3000][i], \rate, [0.7, 1.1, 1.8][i]);
            2.wait;
        };
        "0:35 - Queda súbita; resta um pulso, uma lembrança.".postln;
        Pbindef(\sentidoToqueSeq).stop;
        Ndef(\sentidoAr).xset(\amp, 0.06);
        Ndef(\sentidoHorizonte).xset(\pitch, 55, \drift, 0.08, \amp, 0.14);
        Pbindef(\sentidoLinguaSeq, \midinote, Pseq([60, 63, 67, 63], inf), \dur, 1, \amp, 0.045);
        5.wait;
        "0:40 - Resolução: e se o próximo sentido fosse o gesto?".postln;
        Ndef(\sentidoAr).xset(\tone, 320, \rate, 0.17, \amp, 0.12);
        Pbindef(\sentidoLinguaSeq).stop;
        4.wait;
        Pbindef(\sentidoToqueSeq).clear;
        Pbindef(\sentidoLinguaSeq).clear;
        Ndef(\sentidoAr).clear(2);
        Ndef(\sentidoHorizonte).clear(2);
        Ndef(\sentidosMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)

// Source: xappend-duquesa.scd [Block 5]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, compose, delayTexture, eggPluck, eggSequence, first, fold, fornoHum, freeverb2, hpf, leiteOleoDrone, limiter, master, mixAmp, mixRhythm, mixThud, persistent, polvilhoAmbience, queijoTexture, rlpf, rollAmp, rollRhythm, rollingTap, safety, safetyLimiter, salCrack, saltShot, sinosc
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

// Source: xappend-duquesa.scd [Block 7]
// MODE: compose
// THEME: 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// KEYWORDS: bpf, compose, delayTexture, eggPluck, eggSequence, first, fold, fornoHum, freeverb2, hpf, leiteOleoDrone, limiter, master, mixAmp, mixRhythm, mixThud, persistent, polvilhoAmbience, queijoTexture, rlpf, rollAmp, rollRhythm, rollingTap, safety, safetyLimiter, salCrack, saltShot, sinosc
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

// Source: xappend-museta.scd [Block 2]
// MODE: compose
// THEME: GLOBAL CONFIGURATION
// KEYWORDS: agrilus_boreSeq, agrilus_chitinDrone, agrilus_chitinSeq, agrilus_click, agrilus_diskRecorder, agrilus_fx, agrilus_galleryRes, agrilus_mandibleSeq, agrilus_modalWood, agrilus_woodBore, bpf, compose, configuration, dynklank, freeverb2, global, moogff, ringz, rlpf, safetyLimiter
(
s.waitForBoot({

    var recFolder;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state (toggle to true if multitrack capture needed)
    s.latency = 0.2;

    // --------------------------------------------------------------------
    // PRE-SETUP: GROUPS, BUFFERS & ROUTING BUSES
    // --------------------------------------------------------------------
    ~agrilus_group = Group.new(s);
    ~agrilus_synthBus = Bus.audio(s, 2);

    // Global FFT buffers allocated safely outside JITLib dynamic graphs
    ~agrilus_fftBufL = Buffer.alloc(s, 2048);
    ~agrilus_fftBufR = Buffer.alloc(s, 2048);

    recFolder = "~/Desktop/SC_Multitrack_Agrilus/".standardizePath;
    File.mkdir(recFolder);
    ~agrilus_recFolder = recFolder;

    ~agrilus_recBuses = (
        click: Bus.audio(s, 2),
        bore: Bus.audio(s, 2),
        modal: Bus.audio(s, 2),
        drone: Bus.audio(s, 2),
        gallery: Bus.audio(s, 2),
        master: Bus.audio(s, 2)
    );

    ~agrilus_recBufs = ();
    ~agrilus_recBuses.keysValuesDo { |name, bus|
        ~agrilus_recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\agrilus_diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    // Safe append to ServerTree without wiping server context
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------
    SynthDef(\agrilus_click, { |out=0, recOut=0, freq=3200, freqMult=1, ringTime=0.02, amp=0.25, pan=0, sweep=0|
        var env, swEnv, pFreq, imp, res, sig, finalSig;
        env = EnvGen.ar(Env.perc(0.0005, ringTime.clip(0.001, 0.25)), doneAction: 2);
        swEnv = Line.ar(1, 1 + sweep, ringTime.clip(0.001, 0.25));
        pFreq = (freq * freqMult * swEnv).clip(200, 19000);
        imp = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.002)));
        res = Ringz.ar(imp, pFreq, ringTime.clip(0.001, 0.25));
        sig = (res * 0.12) + (imp * 0.35);
        sig = LeakDC.ar(sig) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\agrilus_woodBore, { |out=0, recOut=0, freq=300, freqMult=1, roughness=40, resFreq=1200, amp=0.3, pan=0, dur=0.2|
        var env, trig, noise, filterBank, sig, finalSig, effFreq;
        env = EnvGen.ar(Env.linen(0.005, dur * 0.7, dur * 0.3), doneAction: 2);
        trig = Dust.ar(roughness.clip(5, 600));
        noise = WhiteNoise.ar * Decay2.ar(trig, 0.0005, 0.015);
        effFreq = (freq * freqMult).clip(80, 8000);
        filterBank = [1, 1.48, 2.2, 3.1, 4.3].collect { |m|
            BPF.ar(noise, (resFreq * m).clip(100, 16000), 0.12) * (1 / m.sqrt)
        }.sum;
        sig = (filterBank * 2.8) + RLPF.ar(noise, effFreq, 0.35);
        sig = sig.tanh * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\agrilus_modalWood, { |out=0, recOut=0, freq=180, decayscale=0.1, amp=0.4, pan=0|
        var env, exciter, freqs, amps, rings, klank, sig, finalSig, decaySafe;
        decaySafe = decayscale.clip(0.005, 1.5);
        env = EnvGen.ar(Env.perc(0.001, decaySafe + 0.12), doneAction: 2);
        exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.006));
        freqs = [1, 2.14, 3.42, 5.11, 7.8] * freq;
        amps = [1, 0.6, 0.4, 0.25, 0.15];
        rings = [1, 0.8, 0.6, 0.4, 0.2] * decaySafe;
        klank = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = (klank * 0.5) + (exciter * 0.25);
        sig = LeakDC.ar(sig) * env;
        finalSig = Pan2.ar(sig * amp, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\agrilus_chitinDrone, { |freq=110, carrierRatio=3.5, modIndex=1.2, subAmp=0.2, amp=0, pan=0, subPulse=0|
        var carFreq, modFreq, mod, car1, car2, sub, sig;
        carFreq = freq.clip(30, 2000);
        modFreq = carFreq * carrierRatio;
        mod = SinOsc.ar(modFreq) * (modFreq * modIndex);
        car1 = SinOsc.ar(carFreq + mod);
        car2 = SinOsc.ar((carFreq * 1.503) + (mod * 0.7));
        sub = SinOsc.ar(carFreq * 0.5) * subAmp;
        sub = sub + (Pulse.ar(40, 0.3) * subPulse * 0.4);
        sig = (car1 * 0.5) + (car2 * 0.4) + sub;
        sig = MoogFF.ar(sig, (carFreq * 8).clip(200, 16000), 1.2);
        Pan2.ar(sig * amp, pan);
    });
    Ndef(\agrilus_chitinDrone).play(~agrilus_recBuses.drone, group: ~agrilus_group);

    Ndef(\agrilus_galleryRes, { |delTime=0.08, decay=2.5, amp=0|
        var inSig, dL, dR, sig;
        inSig = In.ar(~agrilus_synthBus, 2) * 0.6;
        dL = CombC.ar(inSig[0] + (Dust2.ar(3) * 0.015), 0.5, delTime.clip(0.005, 0.45), decay);
        dR = CombC.ar(inSig[1] + (Dust2.ar(3) * 0.015), 0.5, (delTime * 1.23).clip(0.005, 0.45), decay);
        sig = [dL, dR];
        sig = HPF.ar(sig, 120);
        sig = LPF.ar(sig, 7000);
        sig * amp;
    });
    Ndef(\agrilus_galleryRes).play(~agrilus_recBuses.gallery, group: ~agrilus_group);

    Ndef(\agrilus_fx, {
        var synths, drone, gallery, mixed;
        synths = In.ar(~agrilus_synthBus, 2);
        drone = Ndef.ar(\agrilus_chitinDrone, 2);
        gallery = Ndef.ar(\agrilus_galleryRes, 2);
        mixed = synths + drone + gallery;
        Out.ar(~agrilus_recBuses.master, mixed);
        mixed;
    });

    // Auto-crossfaded JITLib filter slot (External control via \wet10)
    Ndef(\agrilus_fx)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.35);
    };

    Ndef(\agrilus_fx).play(out: 0, group: ~agrilus_group);
    s.sync;

    Ndef(\agrilus_fx).set(\wet10, 0.0);
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~agrilus_startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;
        ~agrilus_recSynths = ();

        "--- [AGRILUS] MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~agrilus_recFolder).postln;

        ~agrilus_recBuses.keysValuesDo { |name, bus|
            path = ~agrilus_recFolder ++ timestamp ++ "_agrilus_" ++ name ++ ".wav";
            ~agrilus_recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~agrilus_recBuses.keysValuesDo { |name, bus|
            ~agrilus_recSynths[name] = Synth.tail(RootNode(s), \agrilus_diskRecorder, [
                \bus, bus,
                \bufnum, ~agrilus_recBufs[name]
            ]);
        };

        CmdPeriod.doOnce({ ~agrilus_stopRecording.value });
    };

    ~agrilus_stopRecording = {
        if(~agrilus_recSynths.notNil) {
            "--- [AGRILUS] CLOSING AUDIO FILES ---".postln;
            ~agrilus_recSynths.do(_.free);
            ~agrilus_recBufs.do(_.close);
            ~agrilus_recBufs.do(_.free);
            ~agrilus_recSynths = nil;
            "Multitrack Recording Closed Safely.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Timeline Score: 130.0s Absolute Timeline)
    // --------------------------------------------------------------------
    Tdef(\agrilus_timeline, {

        // --- 0:00.0 - Initialization Breathing Room (0.5s) ---
        if(~enableRecording) {
            ~agrilus_startRecording.value;
        } {
            "--- [AGRILUS] PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };
        0.5.wait;

        // --- 0:00.5 - [Cue 1: Iridescent Emergence (2.3s)] ---
        "0:00.5 - [Cue 1: Iridescent Emergence]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.0);
        Pbindef(\agrilus_chitinSeq,
            \instrument, \agrilus_click,
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \dur, Pseq([0.0625, 0.125, 0.0625, 0.0625, 0.1875], inf),
            \freq, Pseq([3520, 4186, 5587, 4978, 6271], inf),
            \freqMult, 1.0,
            \ringTime, 0.015,
            \amp, 0.22,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;
        2.3.wait;

        // --- 0:02.8 - [Cue 2: Chitinous Tap (1.2s)] ---
        "0:02.8 - [Cue 2: Chitinous Tap]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 280,
            \decayscale, 0.08,
            \amp, 0.5,
            \pan, -0.85
        ], ~agrilus_group);
        1.2.wait;

        // --- 0:04.0 - [Cue 3: Micro-Boring Friction (7.2s)] ---
        "0:04.0 - [Cue 3: Micro-Boring Friction]".postln;
        Pbindef(\agrilus_boreSeq,
            \instrument, \agrilus_woodBore,
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.bore,
            \dur, Pseq([0.15, 0.2, 0.1, 0.25], inf),
            \freq, 280,
            \freqMult, 1.0,
            \roughness, Pseg(Pseq([25, 120], 1), 7.0, \exp),
            \resFreq, 1100,
            \durParam, 0.18,
            \amp, 0.32,
            \pan, 0
        ).play;

        // Active wait: 7.2s (2.4s x 3)
        3.do { |i|
            Pbindef(\agrilus_chitinSeq, \pan, rrand(-0.6, 0.6));
            2.4.wait;
        };

        // --- 0:11.2 - [Cue 4: Vascular Snap (1.2s) - Form Operation C] ---
        "0:11.2 - [Cue 4: Vascular Snap]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_chitinSeq).stop;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 420,
            \decayscale, 0.02,
            \amp, 0.6,
            \pan, 0.1
        ], ~agrilus_group);
        1.2.wait;

        // --- 0:12.4 - [Cue 5: Phloem Resonance (6.2s)] ---
        "0:12.4 - [Cue 5: Phloem Resonance]".postln;
        Ndef(\agrilus_galleryRes).fadeTime = 1.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.35, \delTime, 0.09, \decay, 2.8);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseq([0.5, 0.75, 0.25, 0.5], inf),
            \freq, Pseq([2200, 3100, 1900], inf),
            \ringTime, 0.03,
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active wait: 6.2s (3.1s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, [0.08, 0.11].at(i));
            3.1.wait;
        };

        // --- 0:18.6 - [Cue 6: Stridulation Cluster (1.5s)] ---
        "0:18.6 - [Cue 6: Stridulation Cluster]".postln;
        Pbindef(\agrilus_chitinSeq,
            \dur, 0.03125,
            \freq, Pexprand(4000, 9000, inf),
            \ringTime, 0.002,
            \amp, 0.3,
            \pan, Pseq([-0.8, 0.8], inf)
        );
        1.5.wait;

        // --- 0:20.1 - [Cue 7: Metallic Buprestid Drone (8.3s)] ---
        "0:20.1 - [Cue 7: Metallic Buprestid Drone]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_chitinDrone).fadeTime = 2.5;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.45, \freq, 110, \carrierRatio, 3.5, \modIndex, 1.2, \subAmp, 0.25);

        // Active wait: 8.3s (4.15s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\modIndex, 1.2 + ((i + 1) * 0.4));
            4.15.wait;
        };

        // --- 0:28.4 - [Cue 8: Mandibular Jolt (1.8s)] ---
        "0:28.4 - [Cue 8: Mandibular Jolt]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 85,
            \decayscale, 0.35,
            \amp, 0.7,
            \pan, 0
        ], ~agrilus_group);
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.25); // Duck drone
        1.8.wait;

        // --- 0:30.2 - [Cue 9: Xylem Excavation (7.8s)] ---
        "0:30.2 - [Cue 9: Xylem Excavation]".postln;
        Pbindef(\agrilus_boreSeq,
            \dur, Pseq([0.1, 0.05, 0.05, 0.2], inf),
            \freq, 240,
            \freqMult, 1.0,
            \roughness, Pwhite(60, 140, inf),
            \resFreq, 1350,
            \durParam, 0.12,
            \amp, 0.38,
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;

        // Active wait: 7.8s (3.9s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\freq, 110 + (i * 8));
            3.9.wait;
        };

        // --- 0:38.0 - [Cue 10: Micro-Rotary Acceleration (2.5s)] ---
        "0:38.0 - [Cue 10: Micro-Rotary Acceleration]".postln;
        Pbindef(\agrilus_boreSeq,
            \freqMult, Pseg(Pseq([1.0, 2.8], 1), 2.5, \exp),
            \roughness, Pseg(Pseq([100, 320], 1), 2.5, \exp)
        );
        2.5.wait;

        // --- 0:40.5 - [Cue 11: Bark Fracture (1.5s)] ---
        "0:40.5 - [Cue 11: Bark Fracture]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Ndef(\agrilus_fx).set(\wet10, 0.8);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 1800,
            \ringTime, 0.08,
            \amp, 0.55,
            \pan, 0.3
        ], ~agrilus_group);
        1.5.wait;

        // --- 0:42.0 - [Cue 12: Sub-Cortical Shimmer (9.5s)] ---
        "0:42.0 - [Cue 12: Sub-Cortical Shimmer]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.35);
        Ndef(\agrilus_chitinDrone).fadeTime = 3.0;
        Ndef(\agrilus_chitinDrone).xset(\modIndex, 4.8, \amp, 0.4, \carrierRatio, 4.25);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pwhite(0.2, 0.7, inf),
            \freq, Pexprand(2500, 8500, inf),
            \ringTime, 0.05,
            \amp, 0.18,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active wait: 9.5s (3.16s x 3)
        3.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\freq, 115 + (i * 12));
            3.16.wait;
        };

        // --- 0:51.5 - [Cue 13: Serrated Scrape (1.7s)] ---
        "0:51.5 - [Cue 13: Serrated Scrape]".postln;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 4800,
            \sweep, 2.5,
            \ringTime, 0.15,
            \amp, 0.45,
            \pan, -0.6
        ], ~agrilus_group);
        1.7.wait;

        // --- 0:53.2 - [Cue 14: Resonant Gallery (8.8s)] ---
        "0:53.2 - [Cue 14: Resonant Gallery]".postln;
        Ndef(\agrilus_galleryRes).fadeTime = 2.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.5, \decay, 4.2);

        // Active wait: 8.8s (4.4s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, [0.065, 0.12].at(i));
            4.4.wait;
        };

        // --- 1:02.0 - [Cue 15: Flight Muscle Twitch (2.6s)] ---
        "1:02.0 - [Cue 15: Flight Muscle Twitch]".postln;
        Ndef(\agrilus_chitinDrone).xset(\subPulse, 1.0, \amp, 0.55);
        Pbindef(\agrilus_chitinSeq,
            \dur, 0.0625,
            \freq, Pseq([6000, 7200, 8400, 6800], inf),
            \ringTime, 0.005,
            \amp, 0.28
        );
        2.6.wait;

        // --- 1:04.6 - [Cue 16: Spectral Elytra (9.4s)] ---
        "1:04.6 - [Cue 16: Spectral Elytra]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_fx).set(\wet10, 0.2);
        Ndef(\agrilus_chitinDrone).fadeTime = 2.0;
        Ndef(\agrilus_chitinDrone).xset(\modIndex, 7.5, \carrierRatio, 2.76, \amp, 0.65, \subPulse, 0.0);

        // Active wait: 9.4s (4.7s x 2)
        2.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\carrierRatio, 2.76 + (i * 0.4));
            4.7.wait;
        };

        // --- 1:14.0 - [Cue 17: Acoustic Dislodgment (1.5s)] ---
        "1:14.0 - [Cue 17: Acoustic Dislodgment]".postln;
        Ndef(\agrilus_galleryRes).set(\amp, 0.0);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 1200,
            \ringTime, 0.01,
            \amp, 0.6,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 1:15.5 - [Cue 18: The Deep Tunneling Arc (9.3s)] ---
        "1:15.5 - [Cue 18: The Deep Tunneling Arc]".postln;
        Ndef(\agrilus_chitinDrone).fadeTime = 1.5;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.2, \modIndex, 0.8, \freq, 75);
        Pbindef(\agrilus_boreSeq,
            \dur, Pseq([0.18, 0.09, 0.09, 0.27], inf),
            \freq, Pwhite(150, 320, inf),
            \freqMult, 1.0,
            \roughness, Pseq([40, 75, 120, 90], inf),
            \resFreq, 650,
            \durParam, 0.16,
            \amp, 0.42,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active wait: 9.3s (3.1s x 3)
        3.do { |i|
            Pbindef(\agrilus_boreSeq, \resFreq, 650 + (i * 120));
            3.1.wait;
        };

        // --- 1:24.8 - [Cue 19: Pith Impact (1.2s)] ---
        "1:24.8 - [Cue 19: Pith Impact]".postln;
        Synth(\agrilus_modalWood, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.modal,
            \freq, 140,
            \decayscale, 0.005,
            \amp, 0.65,
            \pan, 0
        ], ~agrilus_group);
        1.2.wait;

        // --- 1:26.0 - [Cue 20: Drill Saturation (10.5s) - Form Operation B] ---
        "1:26.0 - [Cue 20: Drill Saturation]".postln;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.35, \modIndex, 3.5);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseg(Pseq([0.08, 0.005], 1), 10.0, \exp),
            \freq, Pexprand(3000, 10000, inf),
            \ringTime, 0.004,
            \amp, 0.25,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        Pbindef(\agrilus_boreSeq,
            \dur, Pseg(Pseq([0.12, 0.008], 1), 10.0, \exp),
            \roughness, Pseg(Pseq([80, 500], 1), 10.0, \exp),
            \amp, 0.45
        ).play;

        // Active wait: 10.5s (3.5s x 3)
        3.do { |i|
            Ndef(\agrilus_chitinDrone).xset(\modIndex, 3.5 + (i * 1.5));
            3.5.wait;
        };

        // --- 1:36.5 - [Cue 21: Flashback: Dry Bark Echo (1.5s) - Form Operation C] ---
        "1:36.5 - [Cue 21: Flashback: Dry Bark Echo]".postln;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_chitinSeq).stop;
        Ndef(\agrilus_chitinDrone).set(\amp, 0.0);
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 3520,
            \ringTime, 0.015,
            \amp, 0.25,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 1:38.0 - [Cue 22: Iridescent Dispersion (9.2s)] ---
        "1:38.0 - [Cue 22: Iridescent Dispersion]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.55);
        Ndef(\agrilus_galleryRes).fadeTime = 2.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.3, \delTime, 0.14, \decay, 4.5);

        // Active wait: 9.2s (4.6s x 2)
        2.do { |i|
            Ndef(\agrilus_galleryRes).xset(\delTime, 0.14 - (i * 0.03));
            4.6.wait;
        };

        // --- 1:47.2 - [Cue 23: Kinetic Wing Release (1.8s)] ---
        "1:47.2 - [Cue 23: Kinetic Wing Release]".postln;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 2200,
            \sweep, 3.0,
            \ringTime, 0.18,
            \amp, 0.4,
            \pan, 0.4
        ], ~agrilus_group);
        1.8.wait;

        // --- 1:49.0 - [Cue 24: Return to Point of Departure (10.5s) - Form Operation A] ---
        "1:49.0 - [Cue 24: Return to Point of Departure]".postln;
        Ndef(\agrilus_fx).set(\wet10, 0.05);
        Ndef(\agrilus_galleryRes).fadeTime = 4.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.0);
        Pbindef(\agrilus_chitinSeq,
            \dur, Pseq([0.125, 0.25, 0.125, 0.375], inf),
            \freq, Pseq([3520, 4186, 5587, 4978], inf),
            \freqMult, 1.0,
            \ringTime, 0.012,
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        // Active wait: 10.5s (3.5s x 3)
        3.do { |i|
            Pbindef(\agrilus_chitinSeq, \amp, 0.2 - (i * 0.05));
            3.5.wait;
        };

        // --- 1:59.5 - [Cue 25: Final Mandible Strike (1.5s)] ---
        "1:59.5 - [Cue 25: Final Mandible Strike]".postln;
        Pbindef(\agrilus_chitinSeq).stop;
        Synth(\agrilus_click, [
            \out, ~agrilus_synthBus,
            \recOut, ~agrilus_recBuses.click,
            \freq, 3100,
            \ringTime, 0.008,
            \amp, 0.22,
            \pan, 0
        ], ~agrilus_group);
        1.5.wait;

        // --- 2:01.0 - [Cue 26: Extrinsic Fade & Safe Release (9.0s) - Form Operation D] ---
        "2:01.0 - [Cue 26: Extrinsic Fade & Safe Release]".postln;
        Ndef(\agrilus_chitinDrone).fadeTime = 8.0;
        Ndef(\agrilus_chitinDrone).xset(\amp, 0.0);
        Ndef(\agrilus_galleryRes).fadeTime = 8.0;
        Ndef(\agrilus_galleryRes).xset(\amp, 0.0);
        Ndef(\agrilus_fx).fadeTime = 8.0;
        Ndef(\agrilus_fx).xset(\amp, 0.0);

        // Active wait: 9.0s (3.0s x 3)
        3.do { |i|
            3.0.wait;
        };

        // Isolated piece-specific cleanup strictly preserving surrounding server sessions
        ~agrilus_stopRecording.value;

        Pbindef(\agrilus_chitinSeq).stop;
        Pbindef(\agrilus_chitinSeq).clear;
        Pbindef(\agrilus_boreSeq).stop;
        Pbindef(\agrilus_boreSeq).clear;
        Pbindef(\agrilus_mandibleSeq).stop;
        Pbindef(\agrilus_mandibleSeq).clear;

        Ndef(\agrilus_chitinDrone).stop;
        Ndef(\agrilus_chitinDrone).clear;
        Ndef(\agrilus_galleryRes).stop;
        Ndef(\agrilus_galleryRes).clear;
        Ndef(\agrilus_fx).stop;
        Ndef(\agrilus_fx).clear;

        ~agrilus_fftBufL.free;
        ~agrilus_fftBufR.free;
        ~agrilus_group.free;

        Tdef(\agrilus_timeline).stop;
        "--- [AGRILUS] Score Complete. Server preserved. ---".postln;
    });

    Tdef(\agrilus_timeline).play;
});
)

// Source: xappend-museta.scd [Block 6]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & MULTI-TRACK RECORDING SETUP
// KEYWORDS: bpf, compose, configuration, dynklank, freeverb2, global, hpf, lit_cavitation, lit_clicks, lit_crustClick, lit_diskRecorder, lit_hydroDrone, lit_masterFX, lit_modalBasin, lit_neriticSwell, lit_safetyLimiter, lit_sprayImpact, lit_surge, moogff, multi, recording, setup, sinosc, track
(
s.waitForBoot({
    var masterScore;

    s.latency = 0.2;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & MULTI-TRACK RECORDING SETUP
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state

    ~lit_recFolder = "~/Desktop/SC_Litoral_Recording/".standardizePath;
    File.mkdir(~lit_recFolder);

    // Dedicated routing buses
    ~lit_synthBus = Bus.audio(s, 2);

    // Multitrack buses
    ~lit_recBuses = (
        clicks: Bus.audio(s, 2),
        surge: Bus.audio(s, 2),
        spray: Bus.audio(s, 2),
        swell: Bus.audio(s, 2),
        hydro: Bus.audio(s, 2),
        master: 0
    );

    ~lit_recBufs = ();
    ~lit_recBuses.keysValuesDo { |name, bus|
        ~lit_recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Dedicated FFT buffers to prevent dynamic LocalBuf collisions
    ~lit_fftBufL = Buffer.alloc(s, 2048, 1);
    ~lit_fftBufR = Buffer.alloc(s, 2048, 1);

    SynthDef(\lit_diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER (Shared-Server Safe)
    // --------------------------------------------------------------------
    SynthDef(\lit_safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \lit_safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \lit_safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. SYNTHDEFS (Discrete Events - Fully Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\lit_crustClick, { |out=0, recOut=0, freq=5000, freqMult=1, amp=0.2, pan=0, ring=0.015|
        var env = EnvGen.ar(Env.perc(0.0005, ring.clip(0.002, 0.08)), doneAction: 2);
        var f = (freq * freqMult).clip(150, 18000);
        var mod = SinOsc.ar(f * 1.83) * (f * 0.4);
        var sig = SinOsc.ar(f + mod) * env;
        var noise = HPF.ar(WhiteNoise.ar, 6000) * EnvGen.ar(Env.perc(0.0001, 0.005));
        var finalSig;

        sig = (sig * 0.8) + (noise * 0.2);
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_modalBasin, { |out=0, recOut=0, freq=62, amp=0.3, pan=0, decayScale=0.5, rq=0.08|
        var env = EnvGen.ar(Env.perc(0.01, (decayScale * 2.2).clip(0.1, 8.0)), doneAction: 2);
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.002, 0.03));
        var freqs = [1.0, 2.14, 3.42, 5.12, 7.28] * freq;
        var amps  = [1.0, 0.65, 0.45, 0.28, 0.15];
        var rings = [1.8, 1.4,  1.1,  0.8,  0.5] * decayScale;
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        var finalSig;

        sig = LeakDC.ar(sig) * env;
        sig = BPF.ar(sig, (freq * 3).clip(40, 16000), rq.clip(0.01, 1.0)) * 2.0 + (sig * 0.5);
        finalSig = Pan2.ar(sig.tanh * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_sprayImpact, { |out=0, recOut=0, freq=120, cutoff=4000, amp=0.5, pan=0, rel=0.6|
        var env = EnvGen.ar(Env.perc(0.003, rel), doneAction: 2);
        var noise = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, rel * 0.8));
        var click = HPF.ar(WhiteNoise.ar * 2.0, 2000) * EnvGen.ar(Env.perc(0.0002, 0.01));
        var body = SinOsc.ar(XLine.ar(freq * 3, freq * 0.5, 0.08)) * EnvGen.ar(Env.perc(0.005, rel * 0.5));
        var sig, finalSig;

        noise = MoogFF.ar(noise, cutoff.clip(100, 18000), 2.0) * 2.5;
        sig = (noise + click + body).fold2(0.9) * env;
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\lit_cavitation, { |out=0, recOut=0, freq=35, amp=0.6, pan=0|
        var pEnv = XLine.ar(freq * 4, freq, 0.09);
        var env = EnvGen.ar(Env.perc(0.004, 0.8, curve: -4), doneAction: 2);
        var sig = SinOsc.ar(pEnv) * env;
        var finalSig;

        sig = (sig * 2.0).tanh;
        finalSig = Pan2.ar(sig * amp, pan);

        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE (Continuous & Filter Slots)
    // --------------------------------------------------------------------
    Ndef(\lit_hydroDrone, { |amp=0, cutoff=1800, rq=0.4, rmFreq=48, rmDepth=0, spread=0.5|
        var noise = PinkNoise.ar(0.6) + BrownNoise.ar(0.4);
        var rm = SinOsc.ar(rmFreq);
        var sig = BPF.ar(noise, cutoff.clip(50, 16000), rq.clip(0.05, 1.0)) * (2.0 / rq.sqrt);
        sig = XFade2.ar(sig, sig * rm, (rmDepth * 2) - 1);
        sig = sig + CombC.ar(sig, 0.2, [0.035, 0.048] * (1 + (spread * 0.05)), 1.2, 0.3);
        sig = LeakDC.ar(sig);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\lit_hydroDrone).play(~lit_recBuses.hydro);

    Ndef(\lit_neriticSwell, { |amp=0, baseFreq=42, tideDepth=0.5, lpf=800, panSpeed=0.1, subMix=0.7|
        var carrier, mod1, mod2, sig, sub;
        var modFreq1 = baseFreq * 1.5;
        var modFreq2 = baseFreq * 0.75;
        var panMod = SinOsc.kr(panSpeed);

        mod2 = SinOsc.ar(modFreq2) * (modFreq2 * tideDepth * 1.5);
        mod1 = SinOsc.ar(modFreq1 + mod2) * (modFreq1 * tideDepth);
        carrier = SinOsc.ar(baseFreq + mod1);

        sub = SinOsc.ar(baseFreq * 0.5) * subMix;
        sig = (carrier * 0.6) + sub;
        sig = LPF.ar(sig, lpf.clip(40, 18000));
        sig = LeakDC.ar(sig).tanh;

        Pan2.ar(sig * amp, panMod);
    });
    Ndef(\lit_neriticSwell).play(~lit_recBuses.swell);

    Ndef(\lit_masterFX, {
        var synths = In.ar(~lit_synthBus, 2);
        var hydro = Ndef.ar(\lit_hydroDrone, 2);
        var swell = Ndef.ar(\lit_neriticSwell, 2);
        synths + hydro + swell;
    });

    // Reverb / Diffusion Filter Slot (wet10 generated internally by JITLib)
    Ndef(\lit_masterFX)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.35);
        verb;
    };
    Ndef(\lit_masterFX).set(\wet10, 0.0);

    Ndef(\lit_masterFX).play;
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~lit_startRecording = {
        var timestamp = Date.getDate.stamp;
        var path;

        ~lit_recSynths = ();

        "--- LITORAL MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving files to: %".format(~lit_recFolder).postln;

        ~lit_recBuses.keysValuesDo { |name, bus|
            path = ~lit_recFolder ++ timestamp ++ "_lit_" ++ name ++ ".wav";
            ~lit_recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~lit_recBuses.keysValuesDo { |name, bus|
            ~lit_recSynths[name] = Synth.tail(RootNode(s), \lit_diskRecorder, [\bus, bus, \bufnum, ~lit_recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~lit_stopRecording.value });
    };

    ~lit_stopRecording = {
        if(~lit_recSynths.notNil) {
            "--- CLOSING LITORAL AUDIO FILES ---".postln;
            ~lit_recSynths.do(_.free);
            ~lit_recBufs.do(_.close);
            ~lit_recBufs.do(_.free);
            ~lit_recSynths = nil;
            "Litoral Multitrack Recording Closed Safely.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: Absolute Duration 150.0s)
    // --------------------------------------------------------------------
    Tdef(\lit_timeline, {
        if(~enableRecording) {
            ~lit_startRecording.value;
        } {
            "--- LITORAL PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        // ================================================================
        // PHASE I: SUPRATIDAL ZONE (0:00.0 - 0:28.0)
        // ================================================================

        // 0:00.0 — [Cue 0: Safety Breathing Room (0.5s)]
        0.5.wait;

        // 0:00.5 — [Cue 1: Crystalline Spray Ignition (1.8s)]
        "0:00.5 - [Cue 1: Crystalline Spray Ignition]".postln;
        Ndef(\lit_masterFX).set(\wet10, 0.0);
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125, // Fast 64th notes
            \freq, Pexprand(4000, 9000, inf),
            \freqMult, 1.0,
            \ring, Pwhite(0.005, 0.02, inf),
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, Pwhite(0.12, 0.25, inf)
        ).play;
        1.8.wait;

        // 0:02.3 — [Cue 2: Micro-Fracture Shift (1.8s)]
        "0:02.3 - [Cue 2: Micro-Fracture Shift]".postln;
        Pbindef(\lit_clicks,
            \freqMult, 0.72,
            \dur, Pseq([0.03125, 0.0625, 0.03125], inf),
            \amp, Pwhite(0.15, 0.3, inf)
        );
        1.8.wait;

        // 0:04.1 — [Cue 3: Subtractive Salt Flat Drone (9.3s)]
        "0:04.1 - [Cue 3: Subtractive Salt Flat Drone]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.35, \cutoff, 1800, \rq, 0.4, \rmDepth, 0.0);

        Pbindef(\lit_clicks,
            \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf),
            \freqMult, 1.0,
            \amp, 0.1
        );

        // Active Wait: 9.3s -> 3 iterations
        3.do { |i|
            Ndef(\lit_hydroDrone).xset(\cutoff, 1600 + (i * 120));
            3.1.wait;
        };

        // 0:13.4 — [Cue 4: Saline Crackle Snap (1.2s)]
        "0:13.4 - [Cue 4: Saline Crackle Snap]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 380,
            \cutoff, 12000,
            \amp, 0.45,
            \pan, 0.2,
            \rel, 0.25
        ]);
        1.2.wait;

        // 0:14.6 — [Cue 5: Supratidal Wind & Modulation (7.2s)]
        "0:14.6 - [Cue 5: Supratidal Wind & Modulation]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 1.0;
        Ndef(\lit_hydroDrone).xset(\rq, 0.12, \rmFreq, 48, \rmDepth, 0.65, \amp, 0.45);

        // Active Wait: 7.2s -> 2 iterations
        2.do { |i|
            Ndef(\lit_hydroDrone).xset(\cutoff, 1400 + (i * 400));
            3.6.wait;
        };

        // 0:21.8 — [Cue 6: Kinetic Gravel Scuff (1.4s)]
        "0:21.8 - [Cue 6: Kinetic Gravel Scuff]".postln;
        Pbindef(\lit_clicks,
            \dur, 0.04,
            \freq, Pseq([3100, 4800, 2900, 5200, 7100], inf),
            \freqMult, 1.35,
            \ring, 0.008,
            \amp, 0.32
        );
        1.4.wait;

        // 0:23.2 — [Cue 7: Receding Foam Swell (4.8s)]
        "0:23.2 - [Cue 7: Receding Foam Swell]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.2, \cutoff, 800, \rq, 0.5, \rmDepth, 0.1);
        Ndef(\lit_masterFX).set(\wet10, 0.45);
        4.8.wait;

        // ================================================================
        // PHASE II: INTERTIDAL SWASH & BASIN DYNAMICS (0:28.0 - 1:12.5)
        // ================================================================

        // 0:28.0 — [Cue 8: Hydraulic Slam (1.2s)]
        "0:28.0 - [Cue 8: Hydraulic Slam]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 85,
            \cutoff, 6500,
            \amp, 0.7,
            \pan, -0.1,
            \rel, 1.1
        ]);
        Ndef(\lit_masterFX).set(\wet10, 0.35);

        Pbindef(\lit_surge,
            \instrument, \lit_modalBasin,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.surge,
            \dur, Pseq([0.8, 1.2, 0.6, 1.4], inf),
            \freq, 62,
            \decayScale, 0.4,
            \rq, 0.15,
            \pan, Pwhite(-0.5, 0.5, inf),
            \amp, 0.35
        ).play;
        1.2.wait;

        // 0:29.2 — [Cue 9: Modal Basin Resonance (9.3s)]
        "0:29.2 - [Cue 9: Modal Basin Resonance]".postln;
        // Active Wait: 9.3s -> 3 iterations
        3.do { |i|
            Pbindef(\lit_surge, \decayScale, 0.4 + (i * 0.35), \amp, 0.35 + (i * 0.05));
            3.1.wait;
        };

        // 0:38.5 — [Cue 10: Wave Crest Break (1.6s)]
        "0:38.5 - [Cue 10: Wave Crest Break]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.2;
        Ndef(\lit_hydroDrone).xset(\amp, 0.65, \cutoff, 9500, \rq, 0.6, \rmDepth, 0.0);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 140,
            \cutoff, 11000,
            \amp, 0.55,
            \pan, 0.35,
            \rel, 0.8
        ]);
        1.6.wait;

        // 0:40.1 — [Cue 11: Intertidal Undertow (8.2s)]
        "0:40.1 - [Cue 11: Intertidal Undertow (SUBTRACTION)]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.8;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0); // Subtraction

        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, Pwhite(0.04, 0.12, inf),
            \freq, Pexprand(2200, 6000, inf),
            \freqMult, 0.85,
            \ring, 0.01,
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, Pwhite(0.08, 0.18, inf)
        ).play;

        // Active Wait: 8.2s -> 2 iterations
        2.do { |i|
            Pbindef(\lit_surge, \decayScale, 1.2 - (i * 0.3));
            4.1.wait;
        };

        // 0:48.3 — [Cue 12: Cavitation Pop (1.4s)]
        "0:48.3 - [Cue 12: Cavitation Pop]".postln;
        Synth(\lit_cavitation, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 35,
            \amp, 0.75,
            \pan, 0.0
        ]);
        1.4.wait;

        // 0:49.7 — [Cue 13: Rising High-Water Mark (8.5s) - Form Operation B]
        "0:49.7 - [Cue 13: Rising High-Water Mark (Intrinsic Limit)]".postln;
        Pbindef(\lit_clicks, \dur, 0.02, \amp, 0.15);

        // Active Wait: 8.5s -> 3 iterations approaching saturation limit
        3.do { |i|
            var factor = (i + 1) / 3.0;
            Pbindef(\lit_surge,
                \dur, 0.5 - (factor * 0.25),
                \decayScale, 1.2 + (factor * 1.8),
                \amp, 0.35 + (factor * 0.2)
            );
            Ndef(\lit_masterFX).set(\wet10, 0.35 + (factor * 0.25));
            2.83.wait;
        };

        // 0:58.2 — [Cue 14: Saturation Threshold (2.4s)]
        "0:58.2 - [Cue 14: Saturation Threshold]".postln;
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 70,
            \cutoff, 15000,
            \amp, 0.75,
            \pan, 0.0,
            \rel, 2.0
        ]);
        Pbindef(\lit_surge, \decayScale, 3.2, \amp, 0.55);
        2.4.wait;

        // 1:00.6 — [Cue 15: The Tidal Void (1.4s) - Form Operation C]
        "1:00.6 - [Cue 15: The Tidal Void (RADICAL SUBTRACTION)]".postln;
        Pbindef(\lit_surge).stop;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_hydroDrone).fadeTime = 0.05;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0);
        Ndef(\lit_masterFX).set(\wet10, 0.0); // Reverb wet cut dry

        // Single isolated tide-pool droplet
        Synth(\lit_crustClick, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \freq, 3200,
            \ring, 0.06,
            \amp, 0.25,
            \pan, 0.1
        ]);
        1.4.wait;

        // 1:02.0 — [Cue 16: Tide-Pool Reflection (10.5s)]
        "1:02.0 - [Cue 16: Tide-Pool Reflection]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.18, \baseFreq, 124, \tideDepth, 0.15, \lpf, 2200, \subMix, 0.2);

        // Active Wait: 10.5s -> 3 iterations
        3.do { |i|
            if(i == 1) {
                Synth(\lit_crustClick, [
                    \out, ~lit_synthBus,
                    \recOut, ~lit_recBuses.clicks,
                    \freq, 4800,
                    \ring, 0.05,
                    \amp, 0.18,
                    \pan, -0.3
                ]);
            };
            3.5.wait;
        };

        // ================================================================
        // PHASE III: SUBMERGED NERITIC SHELF (1:12.5 - 1:55.0)
        // ================================================================

        // 1:12.5 — [Cue 17: Submersion Plunge (1.7s)]
        "1:12.5 - [Cue 17: Submersion Plunge]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 1.5;
        Ndef(\lit_neriticSwell).xset(\lpf, 180, \baseFreq, 42, \subMix, 0.8, \amp, 0.5);
        1.7.wait;

        // 1:14.2 — [Cue 18: Neritic Mass (10.6s)]
        "1:14.2 - [Cue 18: Neritic Mass]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 4.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.65, \tideDepth, 2.2, \baseFreq, 38, \lpf, 260);

        // Active Wait: 10.6s -> 3 iterations
        3.do { |i|
            Ndef(\lit_neriticSwell).xset(\tideDepth, 2.0 + (i * 0.6));
            3.53.wait;
        };

        // 1:24.8 — [Cue 19: Bioluminescent Trigger (2.3s)]
        "1:24.8 - [Cue 19: Bioluminescent Trigger]".postln;
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125,
            \freq, Pexprand(6000, 12000, inf),
            \freqMult, 1.0,
            \ring, Pwhite(0.003, 0.01, inf),
            \pan, Pwhite(-0.9, 0.9, inf),
            \amp, 0.15
        ).play;
        2.3.wait;

        // 1:27.1 — [Cue 20: Shelf-Break Drop-off (8.3s)]
        "1:27.1 - [Cue 20: Shelf-Break Drop-off]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\baseFreq, 28, \tideDepth, 3.8, \panSpeed, 0.05);

        // Active Wait: 8.3s -> 2 iterations
        2.do { |i|
            Ndef(\lit_neriticSwell).xset(\lpf, 220 - (i * 40));
            4.15.wait;
        };

        // 1:35.4 — [Cue 21: Abyssal Ping (1.4s)]
        "1:35.4 - [Cue 21: Abyssal Ping]".postln;
        Ndef(\lit_masterFX).set(\wet10, 0.6);
        Synth(\lit_modalBasin, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.surge,
            \freq, 185,
            \decayScale, 3.8,
            \rq, 0.02,
            \amp, 0.45,
            \pan, 0.0
        ]);
        1.4.wait;

        // 1:36.8 — [Cue 22: Pelagic Pressure Field (10.4s)]
        "1:36.8 - [Cue 22: Pelagic Pressure Field]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.75, \tideDepth, 4.2);

        // Active Wait: 10.4s -> 3 iterations
        3.do { |i|
            Ndef(\lit_neriticSwell).xset(\baseFreq, 32 + (i * 3));
            3.46.wait;
        };

        // 1:47.2 — [Cue 23: Shear-Stress Turbulence (2.3s)]
        "1:47.2 - [Cue 23: Shear-Stress Turbulence]".postln;
        Ndef(\lit_hydroDrone).fadeTime = 0.4;
        Ndef(\lit_hydroDrone).xset(\amp, 0.6, \cutoff, 420, \rq, 0.2, \rmDepth, 0.5, \rmFreq, 24);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 50,
            \cutoff, 1200,
            \amp, 0.65,
            \pan, -0.4,
            \rel, 1.2
        ]);
        2.3.wait;

        // 1:49.5 — [Cue 24: Sub-Marine Vortex (5.5s)]
        "1:49.5 - [Cue 24: Sub-Marine Vortex]".postln;
        Ndef(\lit_neriticSwell).xset(\panSpeed, 0.8, \lpf, 380);
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.35, \cutoff, 250);

        // Active Wait: 5.5s -> 2 iterations
        2.do { |i|
            Ndef(\lit_neriticSwell).xset(\tideDepth, 3.5 - (i * 0.8));
            2.75.wait;
        };

        // ================================================================
        // PHASE IV: HORIZON DISPERSION & TERMINATION (1:55.0 - 2:30.0)
        // ================================================================

        // 1:55.0 — [Cue 25: Flashback to the Surface (1.2s) - Form Operation A]
        "1:55.0 - [Cue 25: Flashback to the Surface (Form Operation A)]".postln;
        Pbindef(\lit_clicks,
            \instrument, \lit_crustClick,
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.clicks,
            \dur, 0.03125,
            \freq, Pexprand(4500, 9500, inf),
            \freqMult, 1.0,
            \ring, 0.012,
            \pan, Pwhite(-0.7, 0.7, inf),
            \amp, 0.28
        ).play;
        1.2.wait;

        // 1:56.2 — [Cue 26: Dual-Horizon Friction (11.2s)]
        "1:56.2 - [Cue 26: Dual-Horizon Friction]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.5, \baseFreq, 38, \lpf, 200, \panSpeed, 0.1);

        // Active Wait: 11.2s -> 3 iterations
        3.do { |i|
            Pbindef(\lit_clicks, \freqMult, 1.0 + (i * 0.15));
            3.73.wait;
        };

        // 2:07.4 — [Cue 27: Cavitation Impact (2.2s)]
        "2:07.4 - [Cue 27: Cavitation Impact]".postln;
        Synth(\lit_cavitation, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 40,
            \amp, 0.7,
            \pan, 0.0
        ]);
        Synth(\lit_sprayImpact, [
            \out, ~lit_synthBus,
            \recOut, ~lit_recBuses.spray,
            \freq, 110,
            \cutoff, 5000,
            \amp, 0.5,
            \pan, 0.2,
            \rel, 0.5
        ]);
        2.2.wait;

        // 2:09.6 — [Cue 28: Evaporation & Updraft (8.4s)]
        "2:09.6 - [Cue 28: Evaporation & Updraft (SUBTRACTION)]".postln;
        // Subtraction: cut sub-bass, move into suspended high vapor
        Ndef(\lit_neriticSwell).fadeTime = 3.0;
        Ndef(\lit_neriticSwell).xset(\subMix, 0.0, \baseFreq, 380, \tideDepth, 0.2, \lpf, 12000, \amp, 0.25);
        Ndef(\lit_hydroDrone).fadeTime = 2.0;
        Ndef(\lit_hydroDrone).xset(\amp, 0.0);
        Ndef(\lit_masterFX).set(\wet10, 0.7);

        // Active Wait: 8.4s -> 2 iterations
        2.do { |i|
            Pbindef(\lit_clicks, \amp, 0.18 - (i * 0.07));
            4.2.wait;
        };

        // 2:18.0 — [Cue 29: White-Water Dispersion (2.5s)]
        "2:18.0 - [Cue 29: White-Water Dispersion]".postln;
        Pbindef(\lit_clicks).stop;
        Ndef(\lit_neriticSwell).fadeTime = 2.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.12, \baseFreq, 620);
        2.5.wait;

        // 2:20.5 — [Cue 30: Residual Spectral Tail (8.0s)]
        "2:20.5 - [Cue 30: Residual Spectral Tail]".postln;
        Ndef(\lit_neriticSwell).fadeTime = 6.0;
        Ndef(\lit_neriticSwell).xset(\amp, 0.0);
        Ndef(\lit_masterFX).fadeTime = 6.0;

        // Active Wait: 8.0s -> 2 iterations
        2.do { |i|
            if(i == 1) {
                Ndef(\lit_masterFX).set(\wet10, 0.2);
            };
            4.0.wait;
        };

        // 2:28.5 — [Cue 31: Extrinsic Local Termination (1.5s) - Form Operation D]
        "2:28.5 - [Cue 31: Extrinsic Local Termination (Form Operation D)]".postln;
        1.5.wait;

        // Absolute precise stop at 150.0s (2:30.0)
        "2:30.0 - Score Complete. Performing Clean Local Termination.".postln;

        // Stop multitrack recorder safely
        ~lit_stopRecording.value;

        // Stop & Clear ONLY local Pbindefs
        Pbindef(\lit_clicks).stop;
        Pbindef(\lit_clicks).clear;
        Pbindef(\lit_surge).stop;
        Pbindef(\lit_surge).clear;

        // Stop & Clear ONLY local Ndefs
        Ndef(\lit_hydroDrone).stop(0.1);
        Ndef(\lit_hydroDrone).clear;
        Ndef(\lit_neriticSwell).stop(0.1);
        Ndef(\lit_neriticSwell).clear;
        Ndef(\lit_masterFX).stop(0.1);
        Ndef(\lit_masterFX).clear;

        // Free dedicated buffers & buses
        ~lit_fftBufL.free;
        ~lit_fftBufR.free;
        ~lit_synthBus.free;
        ~lit_recBuses.keysValuesDo { |name, bus|
            if(bus.isKindOf(Bus)) { bus.free };
        };

        // Stop ONLY local timeline Tdef
        Tdef(\lit_timeline).stop;
    });

    s.sync;

    // Start master score
    Tdef(\lit_timeline).play;
});
)

// Source: xappend-oceano.scd [Block 2]
// MODE: compose
// THEME: GLOBAL CONFIGURATION & LATENCY
// KEYWORDS: beakClatter, bpf, clatterSeq, compose, configuration, diskRecorder, freeverb2, global, gullCluster, hpf, latency, masterMix, ringz, rlpf, safetyLimiter, saw, seaBreeze, seagullCry, squallBurst, subDescent, wingFlap, wingSeq
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION & LATENCY
    // --------------------------------------------------------------------
    s.latency = 0.2;
    ~enableRecording = false; // Fallback state (set to true to record multitrack)

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & MULTITRACK RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Gaivotas_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        seagull: Bus.audio(s, 2),
        beak:    Bus.audio(s, 2),
        wing:    Bus.audio(s, 2),
        breeze:  Bus.audio(s, 2),
        squall:  Bus.audio(s, 2),
        master:  0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig;
        sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe: doneAction: 2)
    // --------------------------------------------------------------------

    // Avian FM Call / Cry
    SynthDef(\seagullCry, {
        |out=0, recOut=0, fStart=1600, fMid=2900, fEnd=1400, dur=0.6,
         modIndexStart=0.3, modIndexMid=3.2, modIndexEnd=0.1, modRatio=1.414,
         vibRate=8, vibDepth=25, lpfFreq=16000, amp=0.25, pan=0|

        var env, pEnv, mEnv, mod, sig, vibrato, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.08 * dur, 0.42 * dur, 0.5 * dur], [-3, -1, -4]), doneAction: 2);
        pEnv = EnvGen.ar(Env([fStart, fMid, fEnd], [0.35 * dur, 0.65 * dur], [3, -3]));
        mEnv = EnvGen.ar(Env([modIndexStart, modIndexMid, modIndexEnd], [0.3 * dur, 0.7 * dur], [2, -2]));

        vibrato = SinOsc.ar(vibRate) * vibDepth;
        mod = SinOsc.ar((pEnv + vibrato) * modRatio) * (pEnv * mEnv);
        sig = SinOsc.ar(pEnv + vibrato + mod);
        sig = LPF.ar(sig, lpfFreq.clip(200, 19000));
        sig = sig * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Brittle Beak Clatter (Dual Resonator Impulse)
    SynthDef(\beakClatter, {
        |out=0, recOut=0, freq1=2500, freq2=3850, decayTime=0.035, amp=0.28, pan=0|
        var env, exciter, r1, r2, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.0005, decayTime + 0.02), doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003));
        r1 = Ringz.ar(exciter, freq1, decayTime);
        r2 = Ringz.ar(exciter, freq2, decayTime * 0.75);
        sig = (r1 + (r2 * 0.7)) * env * amp;
        sig = HPF.ar(sig, 800);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Wing Flap (Subtractive Low-frequency Swoosh)
    SynthDef(\wingFlap, {
        |out=0, recOut=0, dur=0.38, fStart=420, fEnd=55, rq=0.45, amp=0.35, pan=0|
        var env, fEnv, noise, sig, finalSig;

        env = EnvGen.ar(Env.perc(0.02, dur, 1, -4), doneAction: 2);
        fEnv = XLine.ar(fStart, fEnd, dur);
        noise = PinkNoise.ar;
        sig = BPF.ar(noise, fEnv, rq) * 4.0;
        sig = (sig * 1.5).tanh * env * amp;

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Granular Squall Burst
    SynthDef(\squallBurst, {
        |out=0, recOut=0, dur=0.5, density=180, centerFreq=3200, amp=0.3, pan=0|
        var env, trigs, freqs, grains, finalSig;

        env = EnvGen.ar(Env.sine(dur), doneAction: 2);
        trigs = Dust.ar(density);
        freqs = TRand.ar(centerFreq * 0.5, centerFreq * 1.8, trigs);
        grains = Ringz.ar(trigs, freqs, TRand.ar(0.002, 0.015, trigs));
        grains = grains * env * amp;

        finalSig = Pan2.ar(grains, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    // Sub-Audible Edge Descent (Cue 19: 300 Hz -> 20 Hz Flutter)
    SynthDef(\subDescent, {
        |out=0, recOut=0, dur=9.0, startFreq=300, endFreq=20, amp=0.28, pan=0|
        var env, fEnv, flutterRate, flutter, sig, finalSig;

        env = EnvGen.ar(Env([0, 1, 0.9, 0], [0.5, dur - 1.5, 1.0], [2, 0, -3]), doneAction: 2);
        fEnv = XLine.ar(startFreq, endFreq, dur);
        flutterRate = XLine.ar(8, 28, dur);
        flutter = LFPulse.ar(flutterRate, 0, 0.45);
        sig = SinOsc.ar(fEnv) + (Saw.ar(fEnv * 2) * 0.2);
        sig = (sig * flutter) * env * amp;
        sig = LeakDC.ar(sig);

        finalSig = Pan2.ar(sig, pan);
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & JITLIB ROUTING
    // --------------------------------------------------------------------

    // Littoral Atmosphere (Sea Breeze & Coastal Wash)
    Ndef(\seaBreeze, {
        |amp=0.0, lpf=8000, hpf=60, gust=0.0, modRate=0.12|
        var pNoise, bNoise, lfo1, lfo2, res1, res2, sig;

        pNoise = PinkNoise.ar;
        bNoise = BrownNoise.ar;

        lfo1 = LFNoise2.kr(modRate).exprange(250, 1400);
        lfo2 = LFNoise2.kr(modRate * 1.4).exprange(800, 3200);

        res1 = Resonz.ar(pNoise, lfo1, 0.35) * 2.2;
        res2 = Resonz.ar(bNoise, lfo2, 0.45) * 1.8;

        sig = (pNoise * 0.3) + res1 + res2;
        sig = sig + (WhiteNoise.ar * gust * LFNoise1.kr(4).range(0.2, 1.0));
        sig = RLPF.ar(sig, lpf.clip(100, 18000), 0.7);
        sig = HPF.ar(sig, hpf.clip(20, 1000));

        sig * amp;
    });
    Ndef(\seaBreeze).play(~recBuses.breeze);

    // Master Aggregator & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths, continuousBreeze;
        discreteSynths = In.ar(~synthBus, 2);
        continuousBreeze = Ndef.ar(\seaBreeze, 2);
        discreteSynths + continuousBreeze;
    });

    // Slot 10: Dynamic Littoral Reverb (Crossfader automatically governed by \wet10)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.32);
    };
    Ndef(\masterMix).set(\wet10, 0.25);

    Ndef(\masterMix).play(0);

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp, path;
        timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Destination: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        s.sync;

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING MULTITRACK AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Closed Successfully.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score: 2:00.0 Exact Duration)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK MODE (RECORDING DISABLED) ---".postln;
        };

        // 0:00.0 — [Cue 1: Initial Breath & Avian Impulse (2.5s)]
        "0:00.0 - [Cue 1: Initial Breath & Avian Impulse]".postln;
        0.5.wait;
        Ndef(\masterMix).set(\wet10, 0.3);
        Ndef(\seaBreeze).fadeTime = 1.0;
        Ndef(\seaBreeze).xset(\amp, -18.dbamp, \lpf, 4500, \hpf, 80, \gust, 0.0);

        0.7.wait;
        // Solitary sharp seagull call at 0:01.2
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 0.75, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.25, \pan, 0.1
        ]);

        1.3.wait;

        // 0:02.5 — [Cue 2: Solitary Glissando Spike (2.5s)]
        "0:02.5 - [Cue 2: Solitary Glissando Spike]".postln;
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 1.8, \modIndexStart, 0.5, \modIndexMid, 4.2, \modIndexEnd, 0.3,
            \vibRate, 14, \vibDepth, 80, \amp, 0.3, \pan, -0.3
        ]);

        2.5.wait;

        // 0:05.0 — [Cue 3: The Saline Void (Form Operation C, 9.5s)]
        "0:05.0 - [Cue 3: The Saline Void (Abrupt cut to low-complexity rumble)]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.28, \lpf, 180, \hpf, 30, \gust, 0.0);

        // Active Wait: 9.5 seconds divided into micro-shifts
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.04));
            3.0.wait;
        };
        0.5.wait;

        // 0:14.5 — [Cue 4: Hyper-Kinetic Beak Clatter (1.7s)]
        "0:14.5 - [Cue 4: Hyper-Kinetic Beak Clatter]".postln;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.02); // Spotlight rule: duck wind
        Ndef(\masterMix).set(\wet10, 0.05); // Bone-dry space

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, Pseq([0.05, 0.04, 0.06, 0.035, 0.055], inf),
            \freq1, Pexprand(2200, 3400, inf),
            \freq2, Pexprand(3500, 5200, inf),
            \decayTime, Pwhite(0.015, 0.04, inf),
            \amp, Pwhite(0.22, 0.32, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        1.7.wait;

        // 0:16.2 — [Cue 5: Swelling Wingbeat Resonances (7.8s)]
        "0:16.2 - [Cue 5: Swelling Wingbeat Resonances]".postln;
        Pbindef(\clatterSeq).stop;

        Ndef(\masterMix).set(\wet10, 0.35);
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.22, \lpf, 3500, \hpf, 80);

        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, Pseq([0.38, 0.32, 0.28, 0.24, 0.22, 0.20, 0.18, 0.16, 0.16], inf),
            \durFlap, 0.3,
            \fStart, Pseries(300, 15, inf).clip(300, 550),
            \fEnd, 55,
            \amp, Pseries(0.22, 0.015, inf).clip(0.22, 0.38),
            \pan, Pseq([-0.4, 0.4, -0.2, 0.2], inf)
        ).play;

        // Active Wait: 7.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2000 + (i * 600));
            1.95.wait;
        };

        // 0:24.0 — [Cue 6: Violent Wind Shear (2.5s)]
        "0:24.0 - [Cue 6: Violent Wind Shear]".postln;
        Pbindef(\wingSeq).stop; // Mute wing flaps instantly
        Ndef(\masterMix).set(\wet10, 0.15);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.45, \lpf, 9000, \hpf, 120, \gust, 0.85);

        2.5.wait;

        // 0:26.5 — [Cue 7: Pitch Ceiling Cry Arc (Form Operation B, 9.5s)]
        "0:26.5 - [Cue 7: Pitch Ceiling Cry Arc (Ascending toward Nyquist/Ceiling)]".postln;
        Ndef(\seaBreeze).fadeTime = 1.5;
        Ndef(\seaBreeze).xset(\amp, 0.1, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.35);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.45, 0.4, 0.35, 0.3, 0.28, 0.25, 0.22, 0.2, 0.18], inf),
            \fStart, Pseries(2000, 380, inf).clip(2000, 11500),
            \fMid, Pseries(2800, 420, inf).clip(2800, 13000),
            \fEnd, Pseries(1900, 360, inf).clip(1900, 11000),
            \durCall, 0.32,
            \modIndexMid, Pseries(2.0, 0.3, inf).clip(2.0, 7.5),
            \amp, Pseries(0.2, 0.012, inf).clip(0.2, 0.34),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Active Wait: 9.5 seconds
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.35 + (i * 0.05));
            2.375.wait;
        };

        // 0:36.0 — [Cue 8: Dry Staccato Snap (1.2s)]
        "0:36.0 - [Cue 8: Dry Staccato Snap (Sudden subtraction)]".postln;
        Pbindef(\gullCluster).stop; // INSTANT SUBTRACTION
        Ndef(\masterMix).set(\wet10, 0.02);

        // 3 dry beak snaps
        3.do { |i|
            Synth(\beakClatter, [
                \out, ~synthBus,
                \recOut, ~recBuses.beak,
                \freq1, 2600 + (i * 400),
                \freq2, 4100 + (i * 300),
                \decayTime, 0.025,
                \amp, 0.36,
                \pan, (i - 1) * 0.4
            ]);
            0.4.wait;
        };

        // 0:37.2 — [Cue 9: Sub-Aquatic Murmur & Muffled Glides (9.8s)]
        "0:37.2 - [Cue 9: Sub-Aquatic Murmur & Muffled Glides]".postln;
        Ndef(\masterMix).set(\wet10, 0.8); // Deep resonant space
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.3, \lpf, 450, \hpf, 40, \gust, 0.0);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([2.2, 2.8, 3.2], inf),
            \fStart, Pseq([700, 850, 620], inf),
            \fMid, Pseq([1100, 1250, 950], inf),
            \fEnd, Pseq([550, 600, 480], inf),
            \durCall, 1.8,
            \lpfFreq, 900,
            \modIndexMid, 1.5,
            \amp, 0.22,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 9.8 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 380 + (i * 40));
            2.45.wait;
        };

        // 0:47.0 — [Cue 10: Aggressive Territorial Dart (2.5s)]
        "0:47.0 - [Cue 10: Aggressive Territorial Dart]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.1);
        Ndef(\seaBreeze).fadeTime = 0.1;
        Ndef(\seaBreeze).xset(\amp, 0.05);

        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.07,
            \freq1, Pwhite(2800, 4200, inf),
            \freq2, Pwhite(4500, 6000, inf),
            \decayTime, 0.02,
            \amp, 0.28,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Rapid downward shrieks
        fork {
            3.do { |i|
                Synth(\seagullCry, [
                    \out, ~synthBus,
                    \recOut, ~recBuses.seagull,
                    \fStart, 4200 - (i * 400),
                    \fMid, 3500 - (i * 300),
                    \fEnd, 1100,
                    \dur, 0.55,
                    \modIndexMid, 4.5,
                    \vibRate, 16,
                    \amp, 0.28,
                    \pan, (i.even.if(0.5, -0.5))
                ]);
                0.7.wait;
            };
        };

        2.5.wait;

        // 0:49.5 — [Cue 11: Mid-Air Stasis (2.0s)]
        "0:49.5 - [Cue 11: Mid-Air Stasis]".postln;
        Pbindef(\clatterSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.65); // Pure suspended reverberation

        // Single sustained crystalline tone
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 2400, \fMid, 2400, \fEnd, 2400,
            \dur, 1.9, \modIndexStart, 0.0, \modIndexMid, 0.0, \modIndexEnd, 0.0,
            \vibRate, 0, \vibDepth, 0, \amp, 0.24, \pan, 0
        ]);

        2.0.wait;

        // 0:51.5 — [Cue 12: Microtonal Polyphonic Choir (10.5s)]
        "0:51.5 - [Cue 12: Microtonal Polyphonic Choir]".postln;
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.18, \lpf, 4000, \hpf, 70);

        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.35, 0.55, 0.4, 0.7, 0.3], inf),
            \fStart, Pseq([1760, 1845, 1920, 2030, 2150, 2270, 2390], inf),
            \fMid, Pseq([2400, 2520, 2610, 2780, 2900, 3050, 3180], inf),
            \fEnd, Pseq([1650, 1720, 1800, 1910, 2010, 2120, 2220], inf),
            \durCall, Pwhite(0.5, 0.9, inf),
            \modIndexMid, Pwhite(1.2, 2.8, inf),
            \amp, 0.2,
            \pan, Pseq([-0.7, -0.3, 0.0, 0.3, 0.7, 0.4, -0.4], inf)
        ).play;

        // Active Wait: 10.5 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.1 + (i * 0.05));
            3.5.wait;
        };

        // 1:02.0 — [Cue 13: Granular Squall Interruption (2.8s)]
        "1:02.0 - [Cue 13: Granular Squall Interruption]".postln;
        Pbindef(\gullCluster).stop; // Mute colony
        Ndef(\masterMix).set(\wet10, 0.2);
        Ndef(\seaBreeze).fadeTime = 0.2;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.7);

        Synth(\squallBurst, [
            \out, ~synthBus,
            \recOut, ~recBuses.squall,
            \dur, 2.5,
            \density, 240,
            \centerFreq, 3800,
            \amp, 0.32,
            \pan, 0
        ]);

        2.8.wait;

        // 1:04.8 — [Cue 14: Salt Drift & Resonant Breakers (9.2s)]
        "1:04.8 - [Cue 14: Salt Drift & Resonant Breakers]".postln;
        Ndef(\seaBreeze).fadeTime = 3.0;
        Ndef(\seaBreeze).xset(\amp, 0.26, \lpf, 3200, \hpf, 50, \gust, 0.05);
        Ndef(\masterMix).set(\wet10, 0.55);

        // Distant echoing gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([3.0, 3.2, 2.8], inf),
            \fStart, Pseq([1900, 2200, 1750], inf),
            \fMid, Pseq([2700, 3100, 2400], inf),
            \fEnd, Pseq([1600, 1850, 1450], inf),
            \durCall, 1.4,
            \modIndexMid, 1.8,
            \amp, 0.18,
            \pan, Pseq([0.6, -0.6, 0.3], inf)
        ).play;

        // Active Wait: 9.2 seconds
        4.do { |i|
            Ndef(\seaBreeze).xset(\lpf, 2800 + (i * 200));
            2.3.wait;
        };

        // 1:14.0 — [Cue 15: Metallic Chirp Jolt (1.8s)]
        "1:14.0 - [Cue 15: Metallic Chirp Jolt]".postln;
        Pbindef(\gullCluster).stop;
        Ndef(\masterMix).set(\wet10, 0.15);

        // 3 high-index FM transient chirps at 0.0s, 0.4s, 0.7s
        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 3800, \fMid, 5200, \fEnd, 2900, \dur, 0.22,
            \modIndexMid, 6.0, \amp, 0.26, \pan, -0.5
        ]);
        0.4.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4200, \fMid, 5600, \fEnd, 3200, \dur, 0.2,
            \modIndexMid, 6.8, \amp, 0.28, \pan, 0.5
        ]);
        0.3.wait;

        Synth(\seagullCry, [
            \out, ~synthBus, \recOut, ~recBuses.seagull,
            \fStart, 4600, \fMid, 6100, \fEnd, 3600, \dur, 0.25,
            \modIndexMid, 7.5, \amp, 0.3, \pan, 0.0
        ]);
        1.1.wait;

        // 1:15.8 — [Cue 16: Return to Point of Departure (Form Operation A, 10.7s)]
        "1:15.8 - [Cue 16: Return to Point of Departure (Restatement of Opening Solitary Motif)]".postln;
        Ndef(\masterMix).set(\wet10, 0.65); // Rich spatial envelopment
        Ndef(\seaBreeze).fadeTime = 2.0;
        Ndef(\seaBreeze).xset(\amp, 0.2, \lpf, 4000, \hpf, 70, \gust, 0.0);

        // Solitary Opening Motif restatement
        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1800, \fMid, 2600, \fEnd, 1500,
            \dur, 1.2, \modIndexStart, 0.2, \modIndexMid, 2.5, \modIndexEnd, 0.1,
            \amp, 0.26, \pan, 0.0
        ]);

        2.5.wait;

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 1200, \fMid, 3800, \fEnd, 3200,
            \dur, 2.0, \modIndexStart, 0.4, \modIndexMid, 3.8, \modIndexEnd, 0.2,
            \vibRate, 12, \vibDepth, 60, \amp, 0.28, \pan, -0.2
        ]);

        // Active Wait remaining: 8.2 seconds
        3.do { |i|
            Ndef(\seaBreeze).xset(\modRate, 0.08 + (i * 0.03));
            2.73.wait;
        };

        // 1:26.5 — [Cue 17: Frenzied Feeding Swarm Climax (3.5s)]
        "1:26.5 - [Cue 17: Frenzied Feeding Swarm Climax]".postln;
        Ndef(\masterMix).set(\wet10, 0.25);
        Ndef(\seaBreeze).fadeTime = 0.5;
        Ndef(\seaBreeze).xset(\amp, 0.35, \lpf, 8000, \gust, 0.5);

        // Layer 1: Frantic gull calls
        Pbindef(\gullCluster,
            \instrument, \seagullCry,
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, Pseq([0.16, 0.14, 0.2, 0.15], inf),
            \fStart, Pexprand(1800, 3600, inf),
            \fMid, Pexprand(3500, 5800, inf),
            \fEnd, Pexprand(1400, 2800, inf),
            \durCall, 0.25,
            \modIndexMid, 4.0,
            \amp, 0.28,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Layer 2: Rapid beak clattering
        Pbindef(\clatterSeq,
            \instrument, \beakClatter,
            \out, ~synthBus,
            \recOut, ~recBuses.beak,
            \dur, 0.06,
            \freq1, Pexprand(2500, 4000, inf),
            \freq2, Pexprand(4200, 6200, inf),
            \decayTime, 0.02,
            \amp, 0.24,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        // Layer 3: Flapping
        Pbindef(\wingSeq,
            \instrument, \wingFlap,
            \out, ~synthBus,
            \recOut, ~recBuses.wing,
            \dur, 0.18,
            \durFlap, 0.2,
            \fStart, 480, \fEnd, 60,
            \amp, 0.28,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.5.wait;

        // 1:30.0 — [Cue 18: Hard Vacuum Cut (2.0s)]
        "1:30.0 - [Cue 18: Hard Vacuum Cut (Instant subtraction)]".postln;
        Pbindef(\gullCluster).stop;
        Pbindef(\clatterSeq).stop;
        Pbindef(\wingSeq).stop;
        Ndef(\seaBreeze).fadeTime = 0.05;
        Ndef(\seaBreeze).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.75); // Reverb tail hangs alone

        2.0.wait;

        // 1:32.0 — [Cue 19: Descent to Sub-Audible Edge (Form Operation B, 9.5s)]
        "1:32.0 - [Cue 19: Descent to Sub-Audible Edge (300 Hz to 20 Hz)]".postln;
        Ndef(\masterMix).set(\wet10, 0.2);

        Synth(\subDescent, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \dur, 9.0,
            \startFreq, 300,
            \endFreq, 20,
            \amp, 0.32,
            \pan, 0
        ]);

        // Active Wait: 9.5 seconds
        3.do { |i|
            Ndef(\masterMix).set(\wet10, 0.2 + (i * 0.1));
            3.16.wait;
        };

        // 1:41.5 — [Cue 20: Ghost Squawk Fragment (2.5s)]
        "1:41.5 - [Cue 20: Ghost Squawk Fragment]".postln;
        Ndef(\masterMix).set(\wet10, 0.85);

        Synth(\seagullCry, [
            \out, ~synthBus,
            \recOut, ~recBuses.seagull,
            \fStart, 4500, \fMid, 4700, \fEnd, 4300,
            \dur, 0.4, \modIndexMid, 0.4,
            \lpfFreq, 5000, \amp, 0.12, \pan, 0.2
        ]);

        2.5.wait;

        // 1:44.0 — [Cue 21: Total Evacuation & Dissolution (Form Operation D, 16.0s)]
        "1:44.0 - [Cue 21: Total Evacuation & Dissolution]".postln;

        // Stop all discrete event generation
        Pbindef.all.do(_.stop);

        // 12-second fade-out on all continuous sound proxies
        Ndef(\seaBreeze).fadeTime = 12.0;
        Ndef(\seaBreeze).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 12.0;
        Ndef(\masterMix).xset(\wet10, 0.0);

        // Stop recording before audio stream vanishes
        if(~enableRecording) {
            ~stopRecording.value;
        };

        // Active Wait through the 12-second decay
        4.do {
            3.0.wait;
        };

        // 1:56.0 - 2:00.0: Final evacuation & hard clearance
        "1:56.0 - Final clearing of proxies and nodes...".postln;
        Ndef.clear(3.0);
        4.0.wait;

        "2:00.0 - Score Complete. Total Silence.".postln;
        Pbindef.removeAll;
        Tdef.removeAll;
    });

    s.sync;

    // Start Master Score
    Tdef(\masterScore).play;

});

s.makeGui;
)


// Source: session_2026-11-18_16-59-57
// MODE: compose
// THEME: Mar Mediterrâneo é um mar entre a Europa, África e Ásia, tendo abertura e comunicação direta com o Oceano Atlântico através do estreito de Gibraltar e o Orie...
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\medSafetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \medSafetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \medSafetyLimiter); };

    SynthDef(\medGlassBuoy, { |out=0, freq=660, amp=0.1, pan=0, decay=1|
        var env = EnvGen.ar(Env.perc(0.002, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * 2.71) * (freq * 0.7 * env);
        var sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.51) * 0.35);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\medSaltSnap, { |out=0, freq=1800, amp=0.08, pan=0, decay=0.18|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var noise = BPF.ar(WhiteNoise.ar, freq, 0.18) * 7;
        var tone = SinOsc.ar(freq * 0.52);
        var sig = (noise + tone * 0.25) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\medTideThump, { |out=0, freq=72, amp=0.1, pan=0, decay=1.2|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var body = SinOsc.ar(freq * [1, 2.03], 0, [0.65, 0.3]).sum;
        var grit = LPF.ar(WhiteNoise.ar, 280) * 0.12;
        Out.ar(out, Pan2.ar((body + grit) * env, pan, amp));
    }).add;
    s.sync;

    Ndef(\medOceanSwell, { |amp=0, cutoff=900, rate=0.09|
        var breath = SinOsc.kr(rate).range(0.12, 1);
        var wash = PinkNoise.ar(0.22) + (SinOsc.ar([47, 48.3]) * 0.12);
        var filtered = LPF.ar(wash, cutoff);
        [filtered, DelayC.ar(filtered, 0.08, SinOsc.kr(0.13).range(0.012, 0.06))] * breath * amp;
    });

    Ndef(\medStraitCurrent, { |amp=0, drift=0.12, tone=430|
        var pulse = SinOsc.kr(drift).range(0.25, 1);
        var current = BPF.ar(PinkNoise.ar(0.35), tone, 0.42) * 3;
        var low = SinOsc.ar([55, 55.7], 0, 0.12);
        [current + low[0], current + low[1]] * pulse * amp;
    });

    Ndef(\medMasterMix, {
        var dry = In.ar(~synthBus, 2);
        var sea = Ndef.ar(\medOceanSwell, 2);
        var strait = Ndef.ar(\medStraitCurrent, 2);
        dry + sea + strait;
    });
    Ndef(\medMasterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.86, 0.24)
    };
    Ndef(\medMasterMix)[11] = \filter -> { |in|
        AllpassC.ar(in, 0.18, [0.11, 0.14], 1.2)
    };
    Ndef(\medMasterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\medMasterMix).play;
    s.sync;

    Pbindef(\medBuoySeq,
        \instrument, \medGlassBuoy, \out, ~synthBus,
        \dur, Pseq([1.5, 0.75, 1.25, 2, 0.5, 1], inf),
        \freq, Pseq([659, 784, 880, 988, 784, 698], inf),
        \decay, Pseq([1.1, 0.7, 1.4, 0.8], inf),
        \amp, 0.075, \pan, Pwhite(-0.7, 0.7)
    );

    Pbindef(\medSaltSeq,
        \instrument, \medSaltSnap, \out, ~synthBus,
        \dur, Pseq([0.25, 0.75, 0.5, 1.25, 0.25, 0.5], inf),
        \freq, Pexprand(900, 4200),
        \decay, Pwhite(0.06, 0.22),
        \amp, 0.035, \pan, Pwhite(-0.9, 0.9)
    );

    Pbindef(\medTideSeq,
        \instrument, \medTideThump, \out, ~synthBus,
        \dur, Pseq([2, 1, 1.5, 2.5], inf),
        \freq, Pseq([73, 82, 73, 65], inf),
        \decay, 1.35, \amp, 0.07, \pan, 0
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - A bacia respira; a linha costeira emerge.".postln;
        Ndef(\medOceanSwell).fadeTime = 4;
        Ndef(\medOceanSwell).xset(\amp, 0.19, \cutoff, 750, \rate, 0.08);
        Pbindef(\medBuoySeq).play;
        5.wait;

        "0:06 - O estreito de Gibraltar: corrente estreita, passagem atlântica.".postln;
        Ndef(\medStraitCurrent).fadeTime = 2;
        Ndef(\medStraitCurrent).xset(\amp, 0.12, \drift, 0.16, \tone, 680);
        Pbindef(\medSaltSeq).play;
        4.do { |i|
            Ndef(\medStraitCurrent).xset(\tone, [680, 1100, 520, 1450][i]);
            2.wait;
        };

        "0:18 - Mar interior em movimento; águas e margens se entrelaçam.".postln;
        Pbindef(\medTideSeq).play;
        Ndef(\medOceanSwell).xset(\cutoff, 1800, \rate, 0.13);
        Ndef(\medMasterMix).set(\wet10, 0.26, \wet11, 0.14);
        4.do { |i|
            Pbindef(\medSaltSeq, \dur, Pseq([[0.25, 0.5, 0.25, 1][i], 0.75, 0.5], inf));
            Ndef(\medOceanSwell).xset(\cutoff, [1200, 2600, 900, 1900][i]);
            2.wait;
        };

        "0:27 - Flashback: a superfície rareia, restam boias distantes.".postln;
        Pbindef(\medSaltSeq).stop;
        Pbindef(\medTideSeq).stop;
        Ndef(\medStraitCurrent).fadeTime = 3;
        Ndef(\medStraitCurrent).xset(\amp, 0.025, \tone, 360);
        Ndef(\medOceanSwell).xset(\amp, 0.09, \cutoff, 520);
        Ndef(\medMasterMix).set(\wet10, 0.12, \wet11, 0.08);
        5.wait;

        "0:32 - Retorno ao pulso inicial; a bacia se fecha em calma.".postln;
        Pbindef(\medBuoySeq, \freq, Pseq([659, 784, 880, 988, 784, 698], inf));
        Pbindef(\medBuoySeq).play;
        Ndef(\medOceanSwell).xset(\amp, 0.12, \cutoff, 820, \rate, 0.08);
        5.wait;

        "0:37 - Corte final: o Mediterrâneo permanece entre três continentes.".postln;
        Pbindef(\medBuoySeq).stop;
        Pbindef(\medSaltSeq).stop;
        Pbindef(\medTideSeq).stop;
        Ndef(\medOceanSwell).clear(2);
        Ndef(\medStraitCurrent).clear(2);
        Ndef(\medMasterMix).clear(2);
        Pbindef(\medBuoySeq).clear;
        Pbindef(\medSaltSeq).clear;
        Pbindef(\medTideSeq).clear;
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// Source: session_2026-11-18_18-38-27
// MODE: compose
// THEME: Vendo que meu quarto é pobre de sapê, andorinhas do rio vão e vêm com desdém.
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // 1. Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete SynthDefs
    SynthDef(\sapePalha, { |out=0, freq=1400, amp=0.1, pan=0, decay=0.14|
        var env = EnvGen.ar(Env.perc(0.002, decay.max(0.03), 1, -6), doneAction: 2);
        var rustle = BPF.ar(WhiteNoise.ar, freq, 0.22) * 5.5;
        var reed = Pluck.ar(WhiteNoise.ar * env, 1, 0.05, freq.reciprocal.clip(0.0002, 0.045), decay * 1.4, 0.45);
        var sig = (rustle * 0.45) + (reed * 0.65);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\andorinhaCanto, { |out=0, freq=2200, amp=0.09, pan=0, dur=0.18, sweep=1.45|
        var env = EnvGen.ar(Env.perc(0.004, dur.max(0.04), 1, -4), doneAction: 2);
        var fEnv = EnvGen.kr(Env([freq, freq * sweep, freq * 0.82], [dur * 0.35, dur * 0.65], \exp));
        var mod = SinOsc.ar(fEnv * 2.13) * (fEnv * 0.45 * env);
        var sig = SinOsc.ar(fEnv + mod) + (SinOsc.ar(fEnv * 1.5) * 0.25);
        var panLine = Line.kr(pan, pan.neg, dur.max(0.05));
        Out.ar(out, Pan2.ar(sig * env, panLine, amp));
    }).add;

    SynthDef(\asaVento, { |out=0, freq=620, amp=0.08, pan=0, dur=0.25|
        var env = EnvGen.ar(Env.sine(dur.max(0.05)), doneAction: 2);
        var flutter = LFPulse.kr(28, 0, 0.4).range(0.3, 1.0);
        var sig = BPF.ar(PinkNoise.ar, freq, 0.35) * 4.0 * flutter;
        var panLine = Line.kr(pan, (pan + 0.6).clip(-1, 1), dur.max(0.05));
        Out.ar(out, Pan2.ar(sig * env, panLine, amp));
    }).add;
    s.sync;

    // 3. Continuous Ndefs
    Ndef(\rioCorrente, { |amp=0, cutoff=680, rate=0.14|
        var flow = PinkNoise.ar(0.28) + (SinOsc.ar([62, 62.7]) * 0.08);
        var ripple = SinOsc.kr(rate).range(0.55, 1.0);
        var filtered = LPF.ar(flow, cutoff);
        [filtered, DelayC.ar(filtered, 0.06, SinOsc.kr(0.19).range(0.008, 0.042))] * ripple * amp;
    });

    Ndef(\quartoVazio, { |amp=0, tone=195|
        var air = BPF.ar(BrownNoise.ar(0.4), tone, 0.25) * 3.5;
        var hum = SinOsc.ar([tone * 0.5, tone * 0.504], 0, 0.06);
        (air ! 2) + hum * amp;
    });

    // 4. Master Mix
    Ndef(\sapeMasterMix, {
        var dry = In.ar(~synthBus, 2);
        var rio = Ndef.ar(\rioCorrente, 2);
        var quarto = Ndef.ar(\quartoVazio, 2);
        dry + rio + quarto;
    });
    Ndef(\sapeMasterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35)
    };
    Ndef(\sapeMasterMix).set(\wet10, 0);
    Ndef(\sapeMasterMix).play;
    s.sync;

    // 5. Patterns
    Pbindef(\sapeSeq,
        \instrument, \sapePalha, \out, ~synthBus,
        \dur, Pseq([0.35, 0.15, 0.5, 0.25, 0.75], inf),
        \freq, Pexprand(900, 2800),
        \decay, Pwhite(0.06, 0.16),
        \amp, 0.075, \pan, Pwhite(-0.6, 0.6)
    );

    Pbindef(\andorinhaSeq,
        \instrument, \andorinhaCanto, \out, ~synthBus,
        \dur, Pseq([0.2, 0.15, 0.65, 0.12, 0.18, 0.9], inf),
        \freq, Pseq([1950, 2400, 2850, 2150, 3100, 2600], inf),
        \sweep, Pwhite(1.25, 1.75),
        \amp, 0.07, \pan, Pseq([-0.85, 0.85, -0.7, 0.75], inf)
    );

    Pbindef(\asaSeq,
        \instrument, \asaVento, \out, ~synthBus,
        \dur, Pseq([0.8, 1.2, 0.5, 1.5], inf),
        \freq, Pexprand(480, 1100),
        \amp, 0.065, \pan, Pwhite(-0.9, 0.3)
    );

    // 6. Master Score
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - O quarto pobre de sapê: palha seca e ar parado.".postln;
        Ndef(\quartoVazio).fadeTime = 3;
        Ndef(\quartoVazio).xset(\amp, 0.18, \tone, 185);
        Pbindef(\sapeSeq).play;
        5.wait;

        "0:05 - O rio corre além; primeiras andorinhas passam.".postln;
        Ndef(\rioCorrente).fadeTime = 3;
        Ndef(\rioCorrente).xset(\amp, 0.16, \cutoff, 720, \rate, 0.14);
        Ndef(\sapeMasterMix).set(\wet10, 0.18);
        Pbindef(\asaSeq).play;
        Pbindef(\andorinhaSeq).play;
        6.wait;

        "0:11 - Vão e vêm com desdém: voos rápidos e rasantes.".postln;
        4.do { |i|
            Ndef(\rioCorrente).xset(\cutoff, [950, 1600, 1200, 2200][i], \rate, [0.22, 0.35, 0.28, 0.45][i]);
            Pbindef(\andorinhaSeq, \dur, Pseq([[0.12, 0.12, 0.35, 0.15][i], 0.18, 0.45], inf));
            2.5.wait;
        };

        "0:21 - Limite intrínseco: o bando acelera e quase desaparece no alto.".postln;
        Pbindef(\sapeSeq).stop;
        Ndef(\quartoVazio).xset(\amp, 0.04);
        3.do { |i|
            Pbindef(\andorinhaSeq, \freq, Pseq([2800, 3400, 3900] + (i * 350), inf));
            2.wait;
        };

        "0:27 - Queda súbita (settling): restam apenas o sapê e o quarto vazio.".postln;
        Pbindef(\andorinhaSeq).stop;
        Pbindef(\asaSeq).stop;
        Ndef(\rioCorrente).xset(\amp, 0.05, \cutoff, 420);
        Ndef(\quartoVazio).xset(\amp, 0.16, \tone, 185);
        Ndef(\sapeMasterMix).set(\wet10, 0.08);
        Pbindef(\sapeSeq).play;
        6.wait;

        "0:33 - Último rasante indiferente e corte final.".postln;
        Pbindef(\andorinhaSeq, \dur, Pseq([0.2, 0.8, 1.5], inf), \amp, 0.05);
        Pbindef(\andorinhaSeq).play;
        4.wait;

        Pbindef(\sapeSeq).stop;
        Pbindef(\andorinhaSeq).stop;
        Pbindef(\asaSeq).stop;
        Pbindef(\sapeSeq).clear;
        Pbindef(\andorinhaSeq).clear;
        Pbindef(\asaSeq).clear;
        Ndef(\rioCorrente).clear(2);
        Ndef(\quartoVazio).clear(2);
        Ndef(\sapeMasterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
