// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-12T00:44:06.054573+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: "Antarctic tension" - a sustained low wind drone (the silence before the storm) with sparse tapped ticks that accumulate as the argument builds
Ndef(\storm, { |amp=0.2, cutoff=400, swell=0.05, t_trig=0, pan=0|
    var swellLFO, wind, tap, sig;
    swellLFO = SinOsc.kr(swell).range(0.3, 1);
    wind = LPF.ar(PinkNoise.ar(0.6), cutoff * swellLFO);
    tap = Ringz.ar(Decay2.ar(K2A.ar(t_trig), 0.002, 0.03) * WhiteNoise.ar(0.8), 1800, 0.4) * 0.4;
    sig = (wind + tap) * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\stormPulse,
    \dur, Pseq([3, 3, 2, 1, 0.5, 0.25, 0.25], inf),
    \t_trig, 1,
    \amp, Pwhite(0.12, 0.25, inf),
    \cutoff, Pwhite(250.0, 600.0, inf),
    \pan, Pwhite(-0.3, 0.3, inf)
);

Ndef(\storm)[1] = \set -> Pbindef(\stormPulse);
)

// Pbindef(\stormPulse).stop; Ndef(\storm).fadeTime = 2; Ndef(\storm).clear(2); // Rollback: remove this instrument

