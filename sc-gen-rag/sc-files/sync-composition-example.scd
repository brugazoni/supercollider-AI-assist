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

// To execute the piece:
Tdef(\parkerScore).play;

// To halt the piece midway:
Tdef(\parkerScore).stop; Ndef.clear; Pbindef.clear;