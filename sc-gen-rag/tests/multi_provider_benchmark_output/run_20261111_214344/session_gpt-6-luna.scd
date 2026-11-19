// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-12T00:44:21.651073+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\mapFold, { |freq=180, amp=0.12, pan=(-0.25), t_trig=0, brightness=1800|
    var env = EnvGen.kr(Env.perc(0.002, 0.16, 1, -7), t_trig);
    var click = BPF.ar(WhiteNoise.ar, brightness, 0.22) * 5;
    var crease = SinOsc.ar(freq * [1, 2.01]).sum * 0.18;
    Pan2.ar((click + crease) * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1, 0.5, 0.5, 1.5], inf),
    \freq, Pseq([196, 196, 220, 196, 174.61, 196, 164.81], inf),
    \brightness, Pseq([900, 2600, 1400, 4200, 1100, 3200, 700], inf),
    \t_trig, 1,
    \amp, Pseq([0.11, 0.07, 0.09, 0.045, 0.1, 0.06, 0.035], inf),
    \pan, Pseq([-0.3, -0.2, -0.1, 0, -0.25, -0.15, 0.1], inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

Ndef(\stormSilence, { |freq=55, amp=0.11, pan=0, t_trig=0, cutoff=240|
    var env = EnvGen.kr(Env.perc(0.08, 8, 1, -4), t_trig);
    var slow = SinOsc.kr(0.035).range(0.75, 1.15);
    var sub = SinOsc.ar(freq) * 0.55;
    var overtone = SinOsc.ar(freq * 2.01) * 0.24;
    var coldAir = LPF.ar(WhiteNoise.ar, cutoff) * 0.018;
    Pan2.ar((sub + overtone + coldAir) * env * slow * amp, pan);
}).play;

Pbindef(\stormSilenceSeq,
    \dur, Pseq([4, 3, 5, 2, 6], inf),
    \freq, Pseq([55, 58.27, 55, 51.91, 55], inf),
    \cutoff, Pseq([180, 320, 210, 450, 150], inf),
    \t_trig, 1,
    \amp, Pseq([0.12, 0.085, 0.11, 0.075, 0.13], inf),
    \pan, Pseq([-0.05, 0.04, 0, 0.08, -0.04], inf)
);
Ndef(\stormSilence)[1] = \set -> Pbindef(\stormSilenceSeq);

// Pbindef(\stormSilenceSeq).stop; Ndef(\stormSilence).fadeTime = 2; Ndef(\stormSilence).clear(2); // Rollback: remove this instrument

Ndef(\suspendedWine, { |freq=880, amp=0.035, pan=0.55, t_trig=0, tone=5300|
    var env = EnvGen.kr(Env.perc(0.003, 2.8, 1, -5), t_trig);
    var ping = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.76) * 0.28) + (SinOsc.ar(freq * 4.13) * 0.12);
    var shimmer = BPF.ar(WhiteNoise.ar, tone, 0.035) * 1.4;
    Pan2.ar((ping * 0.16 + shimmer * 0.025) * env * amp, pan);
}).play;

Pbindef(\suspendedWineSeq,
    \dur, Pseq([7, 11, 9, 13], inf),
    \freq, Pseq([880, 830.61, 932.33, 880], inf),
    \tone, Pseq([4300, 6100, 4900, 7200], inf),
    \t_trig, 1,
    \amp, Pseq([0.04, 0.028, 0.035, 0.022], inf),
    \pan, Pseq([0.55, 0.62, 0.48, 0.58], inf)
);
Ndef(\suspendedWine)[1] = \set -> Pbindef(\suspendedWineSeq);

// Pbindef(\suspendedWineSeq).stop; Ndef(\suspendedWine).fadeTime = 2; Ndef(\suspendedWine).clear(2); // Rollback: remove this instrument
)

