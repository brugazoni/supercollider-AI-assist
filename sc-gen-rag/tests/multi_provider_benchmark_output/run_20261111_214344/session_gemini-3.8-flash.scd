// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T00:43:45.739571+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: \mapFold - Dry, precise, repetitive paper-folding clicks and rustles
Ndef(\mapFold, { |amp=0.25, pan=0, t_trig=0, foldFreq=3200, res=0.15, rel=0.04|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.001, rel, 1, -6), trig);
    var click = WhiteNoise.ar * env;
    var paper = BPF.ar(click, foldFreq, res) * 12.0;
    var body = Ringz.ar(click * 0.2, [foldFreq * 0.5, foldFreq * 1.2], 0.02).sum;
    var sig = (paper + body).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 0.5], inf),
    \t_trig, 1,
    \foldFreq, Pseq([2800, 3400, 4200, 2600, 4800, 3100], inf),
    \rel, Pwhite(0.02, 0.06, inf),
    \pan, Pseq([-0.3, 0.3, -0.1, 0.2], inf),
    \amp, Pseq([0.18, 0.22, 0.28, 0.15], inf)
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// ADD_INSTRUMENT: \antarcticSilence - Tension-heavy sub-harmonic drone & icy glacial air
Ndef(\antarcticSilence, { |amp=0.35, pan=0, t_trig=0, fund=46.25, windCutoff=800, rumble=0.4|
    var trig = K2A.ar(t_trig);
    var sub = SinOsc.ar(fund) * 0.7 + SinOsc.ar(fund * 2) * 0.3;
    var subSaturated = (sub * 2.5).tanh * rumble;
    var coldAir = BPF.ar(PinkNoise.ar, SinOsc.kr(0.08).range(400, windCutoff), 0.15) * 8.0;
    var frost = HPF.ar(Dust2.ar(8) * 0.2, 5000);
    var sig = Splay.ar([subSaturated + frost, coldAir]);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\antarcticSilenceSeq,
    \dur, Pseq([4.0, 6.0, 8.0], inf),
    \t_trig, 1,
    \fund, Pseq([46.25, 43.65, 41.2], inf), // Sub Bb0, A0, Ab0
    \windCutoff, Pseq([600, 950, 750, 1200], inf),
    \rumble, Pseq([0.35, 0.5, 0.6], inf),
    \pan, Pseq([0, 0.1, -0.1], inf),
    \amp, 0.32
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);

// ADD_INSTRUMENT: \suspendedWine - Suspended crystalline glass friction/resonance held in mid-air
Ndef(\suspendedWine, { |amp=0.18, pan=0, t_trig=0, freq=880, atk=1.5, rel=3.0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, 1, 2), trig);
    var glass = DynKlank.ar(
        `[
            [freq, freq * 2.12, freq * 3.42, freq * 4.78],
            [0.5, 0.25, 0.15, 0.08],
            [2.5, 2.0, 1.5, 1.2]
        ],
        BPF.ar(WhiteNoise.ar, freq * 1.5, 0.05) * 0.05
    );
    var tone = SinOsc.ar(freq * [0.999, 1.001]).sum * 0.2;
    var sig = Pan2.ar((glass + tone) * env * amp, pan);
    sig;
}).play;

Pbindef(\suspendedWineSeq,
    \dur, Pseq([3.0, 5.0, 4.0], inf),
    \t_trig, 1,
    \freq, Pseq([1174.66, 1108.73, 1046.5], inf), // D6, C#6, C6 descending tension
    \atk, Pseq([1.0, 1.8, 0.8], inf),
    \rel, Pseq([3.0, 4.5, 3.5], inf),
    \pan, Pseq([0.4, -0.4, 0.2], inf),
    \amp, 0.16
);

Ndef(\suspendedWine)[1] = \set -> Pbindef(\suspendedWineSeq);

// Rollback:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2);
// Pbindef(\suspendedWineSeq).stop; Ndef(\suspendedWine).fadeTime = 2; Ndef(\suspendedWine).clear(2);
)

