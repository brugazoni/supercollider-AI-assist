// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-12T00:44:14.781577+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ============================================================
// Opening: The Dinner Table Before the Storm
// 27 years of silence, a suspended wine bottle, Antarctic pressure
// ============================================================

// --- Deep drone: twenty-seven years of unspoken weight ---
Ndef(\marriageDrone, {
    var freq = 42;
    var base = SinOsc.ar(freq) * 0.5 + SinOsc.ar(freq * 2) * 0.3;
    var shimmer = Saw.ar(freq * 3) * 0.06;
    var mod = LFNoise2.kr(0.05).range(0.9, 1.1);
    var sig = (base + shimmer) * mod;
    var filt = MoogFF.ar(sig, 180 + LFNoise1.kr(0.08).range(0, 320), 2.6);
    filt = (filt * 1.6).tanh;
    Pan2.ar(filt * 0.35, 0);
}).play;
// Pbindef(\marriageDroneSeq).stop; Ndef(\marriageDrone).fadeTime = 2; Ndef(\marriageDrone).clear(2); // Rollback

// --- Frozen waiter: the bottle suspended, held breath ---
Ndef(\frozenWaiter, {
    var freqs = [880, 1320, 1760, 2640];
    var sig = freqs.collect({ |f, i|
        SinOsc.ar(f * LFNoise2.kr(0.1).range(0.995, 1.005), 0, 1/(i + 2))
    }).sum;
    var susp = SinOsc.kr(0.07).range(0.45, 1.0);
    var breath = LFNoise1.kr(0.25).range(0.6, 1.0);
    Pan2.ar(sig * susp * breath * 0.13, LFNoise1.kr(0.1).range(-0.35, 0.35));
}).play;
// Pbindef(\frozenWaiterSeq).stop; Ndef(\frozenWaiter).fadeTime = 2; Ndef(\frozenWaiter).clear(2); // Rollback

// --- Map folder: dry, careful, exact percussion (the explanation) ---
Ndef(\mapFold, { |t_trig=0, amp=0.4, pan=0, freq=1200|
    var env = EnvGen.ar(Env.perc(0.001, 0.09, 1, -4), K2A.ar(t_trig));
    var noise = BPF.ar(WhiteNoise.ar, freq, 0.14) * 13;
    var body = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.001, 0.05));
    Pan2.ar((noise + (body * 0.3)) * env * amp, pan);
}).play;
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback

// --- Effect: heavy Antarctic reverb-space on the drone (low wetness, awaiting storm) ---
Ndef(\marriageDrone)[10] = \filter -> { |in|
    var sig = in;
    sig + (CombC.ar(sig, 2.5, 1.73, 6.0) * 0.35) + (CombC.ar(sig, 2.5, 2.31, 5.0) * 0.28);
};
Ndef(\marriageDrone).set(\wet10, 0.28);
// Ndef(\marriageDrone).set(\wet10, 0); // Rollback: disable this effect

// --- Sequence: the folding explanation, dry and irregular ---
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.125, 0.5, 0.375, 0.125, 0.25, 0.75, 0.125], inf),
    \t_trig, 1,
    \amp, Pwhite(0.15, 0.45, inf),
    \freq, Pwhite(800, 2400, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
)

