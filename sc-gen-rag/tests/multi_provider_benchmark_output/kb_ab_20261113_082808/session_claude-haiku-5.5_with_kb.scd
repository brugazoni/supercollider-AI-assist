// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-13T11:48:58.378516+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Ndef(\antarcticStorm), a low pressured drone for the frozen silence before the storm breaks
Ndef(\antarcticStorm, {
    |amp=0.4, cutoff=180, swell=0.05|
    var wind, gust, sig;
    wind = PinkNoise.ar(0.6);
    gust = LFNoise2.kr(swell).range(0.2, 1.0);
    sig = LPF.ar(wind, cutoff * gust.linexp(0.2, 1.0, 0.5, 1.5));
    sig = sig + (SinOsc.ar(38, 0, 0.08) * gust);
    Pan2.ar(sig * amp, LFNoise1.kr(0.03).range(-0.3, 0.3));
}).play;

// ADD_INSTRUMENT: Ndef(\mapCrinkle), dry paper crackle of the road map being folded, one impulse per gesture
Ndef(\mapCrinkle, {
    |t_trig=0, amp=0.3, freq=3000, decay=0.12, pan=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.002, decay), t_trig);
    sig = BPF.ar(WhiteNoise.ar, freq, 0.2) * 8;
    sig = sig * env * amp;
    Pan2.ar(sig, pan);
}).play;

// Sparse, irregular gesture pattern: the explanation that will not stop, each fold a tense micro-event
Pbindef(\silenceSeq,
    \dur, Pseq([1.5, 0.5, 0.25, 0.25, 2.0, 0.75], inf),
    \t_trig, 1,
    \freq, Pwhite(2000, 5000, inf),
    \decay, Pexprand(0.05, 0.3, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pseq([0.5, 0.2, 0.15, 0.1, 0.6, 0.2], inf)
).play;

// Route the pattern into the crinkle proxy
Ndef(\mapCrinkle)[1] = \set -> Pbindef(\silenceSeq);

// ADD_EFFECTS: Slot [10] on the storm, a cavernous room that makes the silence feel vast; wetness starts at 0
Ndef(\antarcticStorm)[10] = \filter -> { |in|
    FreeVerb.ar(in, 1, 0.9, 0.7);
};
Ndef(\antarcticStorm).set(\wet10, 0); // Rollback: disable this effect

// Rollback: remove this instrument
// Pbindef(\silenceSeq).stop; Ndef(\mapCrinkle).fadeTime = 2; Ndef(\mapCrinkle).clear(2);
// Ndef(\antarcticStorm).fadeTime = 2; Ndef(\antarcticStorm).clear(2);
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var dummy;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete clock-tick and chime voices
    SynthDef(\gearTick, { |out=0, freq=3200, amp=0.2, pan=0, t_trig=1|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, 0.05, 1, -10), t_trig, doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.08) * 12;
        sig = sig * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\brassChime, { |out=0, freq=880, amp=0.1, pan=0|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.003, 2.2, 1, -6), doneAction: 2);
        mod = SinOsc.ar(freq * 2.71) * freq * 0.8 * env;
        sig = SinOsc.ar(freq + mod) * env;
        sig = sig + Ringz.ar(Impulse.ar(0), [freq * 2.0, freq * 3.51], [1.4, 0.8], [0.4, 0.2]);
        sig = HPF.ar(sig, 300);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pendulumKnock, { |out=0, freq=180, amp=0.3, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.002, 0.35, 1, -8), doneAction: 2);
        sig = SinOsc.ar(freq * XLine.kr(1.4, 1, 0.08)) * env;
        sig = sig + (SinOsc.ar(freq * 2) * env * 0.3);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // Continuous breathing of the mechanism
    Ndef(\escapementBreath, { |amp=0, rate=0.4, spread=0.4|
        var phase, env, sig;
        phase = LFTri.kr(rate).range(0.0, 1.0);
        env = phase.squared;
        sig = BPF.ar(PinkNoise.ar(0.6), 900 + (phase * 400), 0.3) * 6;
        sig = sig + (SinOsc.ar(60, 0, 0.05) * env);
        Pan2.ar(sig * env * amp, LFNoise1.kr(0.05).range(spread.neg, spread));
    });

    // Drifting shimmer of many out-of-sync clocks
    Ndef(\clockSwarm, { |amp=0, detune=0.6|
        var sig = 12.collect { |i|
            var f = 1400 + (i * 37) + LFNoise2.kr(0.1 + (i * 0.01)).range(detune.neg * 20, detune * 20);
            SinOsc.ar(f) * LFNoise2.kr(0.2 + (i * 0.02)).exprange(0.005, 1) / 12;
        }.sum;
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\escapementBreath)[10] = \filter -> { |in|
        var delay = CombC.ar(in, 0.5, [0.21, 0.34], 2.5);
        in + (delay * 0.4);
    };
    Ndef(\escapementBreath).set(\wet10, 0);

    Ndef(\clockSwarm)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.8, 0.4);
    };
    Ndef(\clockSwarm).set(\wet10, 0);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\escapementBreath, 2) + Ndef.ar(\clockSwarm, 2);
        synths + cont;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.7, 0.3);
    };
    Ndef(\masterMix).set(\wet10, 0.15);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Two Hundred Pendulums]".postln;
        Ndef(\escapementBreath).fadeTime = 4;
        Ndef(\escapementBreath).xset(\amp, 0.5);
        Pbindef(\tickSeq,
            \instrument, \gearTick,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.5, 0.25, 0.25], inf),
            \freq, Pwhite(2800, 3600, inf),
            \amp, Pwhite(0.05, 0.12, inf),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;
        8.do { |i|
            Pbindef(\tickSeq, \freq, Pwhite(2800 + (i * 120), 3600 + (i * 150), inf));
            1.wait;
        };

        "0:08 - [Cue 2: Carrilhões Franceses]".postln;
        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, 0.2, \detune, 0.6);
        Pbindef(\chimeSeq,
            \instrument, \brassChime,
            \out, ~synthBus,
            \dur, Pseq([2.0, 1.5, 3.0, 2.5], inf),
            \freq, Pseq([659.25, 523.25, 587.33, 392.0], inf),
            \amp, Pexprand(0.05, 0.12, inf),
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;
        4.do { |i|
            Ndef(\clockSwarm).xset(\detune, 0.6 + (i * 0.2));
            2.wait;
        };

        "0:16 - [Cue 3: Defasagem Microscópica]".postln;
        Pbindef(\tickSeq, \dur, Pseq([0.25, 0.2, 0.3, 0.22], inf));
        Ndef(\escapementBreath).xset(\rate, 1.2, \spread, 0.8);
        Ndef(\masterMix).set(\wet10, 0.3);
        6.do { |i|
            Ndef(\escapementBreath).xset(\rate, 0.8 + (i * 0.2));
            2.wait;
        };

        "0:28 - [Cue 4: Pêndulos em Fuga]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\chimeSeq).stop;
        Pbindef(\knockSeq,
            \instrument, \pendulumKnock,
            \out, ~synthBus,
            \dur, Pseq([0.9, 1.1, 0.8, 1.3], inf),
            \freq, Pwhite(150, 210, inf),
            \amp, Pwhite(0.15, 0.3, inf),
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;
        Ndef(\clockSwarm).xset(\amp, 0.4, \detune, 1.4);
        Ndef(\escapementBreath).xset(\amp, 0.2);
        8.do { |i|
            Pbindef(\knockSeq, \freq, Pwhite(150 + (i * 15), 210 + (i * 20), inf));
            1.wait;
        };

        "0:38 - [Cue 5: O Respirar do Tempo]".postln;
        Pbindef(\knockSeq).stop;
        Ndef(\clockSwarm).xset(\amp, 0.08, \detune, 0.2);
        Ndef(\escapementBreath).fadeTime = 8;
        Ndef(\escapementBreath).xset(\amp, 0.6, \rate, 0.25);
        Pbindef(\chimeSeq).play;
        6.do { |i|
            Ndef(\escapementBreath).xset(\rate, 0.25 + (i * 0.02));
            2.wait;
        };

        "0:50 - [Cue 6: Resolução no Centro]".postln;
        Pbindef(\tickSeq, \dur, Pseq([0.5, 0.5, 0.5, 0.25, 0.25], inf)).play;
        Ndef(\masterMix).set(\wet10, 0.15);
        Ndef(\escapementBreath).xset(\amp, 0.3);
        Ndef(\clockSwarm).xset(\amp, 0.1);
        4.do { |i| Ndef(\clockSwarm).xset(\detune, 0.2 + (i * 0.1)); 2.wait; };

        "0:58 - [Cue 7: Settling]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\chimeSeq).stop;
        Ndef(\clockSwarm).fadeTime = 10;
        Ndef(\clockSwarm).xset(\amp, 0);
        Ndef(\escapementBreath).fadeTime = 10;
        Ndef(\escapementBreath).xset(\amp, 0.1, \rate, 0.2);
        4.do { |i| Ndef(\escapementBreath).xset(\rate, 0.2 - (i * 0.02)); 2.wait; };

        "1:06 - [Terminating]".postln;
        Pbindef(\tickSeq).stop; Pbindef(\tickSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Pbindef(\knockSeq).stop; Pbindef(\knockSeq).clear;
        Ndef(\escapementBreath).clear(4);
        Ndef(\clockSwarm).clear(4);
        Ndef(\masterMix).clear(4);
        "Score Complete.".postln;
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
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: gungas (tin rattles), conga-style pulse and a sung choir layer
Ndef(\gungaRattle, { |amp=0.2, t_trig=0, pan=0, decay=0.09|
    var env, noise, sig;
    env = EnvGen.ar(Env.perc(0.001, decay, 1, -6), t_trig);
    noise = BPF.ar(WhiteNoise.ar, [3100, 4700, 6900], 0.04, 6).sum;
    sig = (noise * env * 10).tanh;
    Pan2.ar(sig * amp, pan);
}).play;
Ndef(\gungaRattle).fadeTime = 2;
Ndef(\gungaRattle).quant = 1;
Ndef(\gungaRattle)[1] = \set -> Pbindef(\gungaSeq);

Pbindef(\gungaSeq,
    \t_trig, 1,
    \dur, Pseq([0.25, 0.25, 0.125, 0.125, 0.25, 0.25, 0.5], inf),
    \decay, Pwhite(0.05, 0.12, inf),
    \amp, Pseq([0.25, 0.12, 0.18, 0.12, 0.25, 0.12, 0.2], inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);

// Caixa-like conga pulse with a pitch-dropping body and a dry slap
Ndef(\congaDrum, { |amp=0.3, freq=110, t_trig=0, pan=0|
    var env, pitch, body, slap;
    env = EnvGen.ar(Env.perc(0.002, 0.45, 1, -4), t_trig);
    pitch = EnvGen.ar(Env.perc(0.001, 0.07), t_trig);
    body = SinOsc.ar(freq + (pitch * freq * 1.8)) * env;
    slap = HPF.ar(WhiteNoise.ar, 2500) * EnvGen.ar(Env.perc(0.001, 0.03), t_trig) * 0.3;
    Pan2.ar((body + slap).tanh * amp, pan);
}).play;
Ndef(\congaDrum).fadeTime = 3;
Ndef(\congaDrum).quant = 1;
Ndef(\congaDrum)[1] = \set -> Pbindef(\congaSeq);

Pbindef(\congaSeq,
    \t_trig, 1,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25, 0.5], inf),
    \freq, Pseq([98, 98, 130.81, 98, 98, 146.83, 110, 98], inf),
    \amp, Pwhite(0.18, 0.3, inf),
    \pan, Pwhite(-0.4, 0.4, inf)
);

// Sung choir: detuned saws through drifting vowel formants (mono body, then stereo)
Ndef(\congaChoir, { |freq=196, amp=0.1, pan=(-0.2)|
    var body, formF, sig, vowel;
    vowel = LFTri.kr(0.05).range(0, 1);
    body = Saw.ar(freq * [1, 1.004]).sum * 0.25;
    formF = [700, 1220, 2600] + (vowel * [-220, 580, 100]);
    sig = BPF.ar(body, formF, 0.12).sum * 8;
    Pan2.ar(sig.tanh * amp, pan);
}).play;
Ndef(\congaChoir).fadeTime = 6;
Ndef(\congaChoir).quant = 1;
Ndef(\congaChoir)[1] = \set -> Pbindef(\choirSeq);

Ndef(\congaChoir)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.4);
};
Ndef(\congaChoir).set(\wet10, 0.35);

Pbindef(\choirSeq,
    \dur, Pseq([2, 2, 1.5, 2.5], inf),
    \freq, Pseq([196, 220, 261.63, 174.61], inf),
    \amp, Pwhite(0.08, 0.12, inf),
    \pan, Pwhite(-0.3, 0.3, inf)
);

// Live tweaks (uncomment to use)
// Ndef(\gungaRattle).xset(\decay, 0.16); // Longer metallic ring | Revert: Ndef(\gungaRattle).xset(\decay, 0.09);
// Pbindef(\gungaSeq, \dur, Pseq([0.125, 0.125, 0.25], inf)); // Double-time shaker | Revert: Pbindef(\gungaSeq, \dur, Pseq([0.25, 0.25, 0.125, 0.125, 0.25, 0.25, 0.5], inf));
// Pbindef(\congaSeq, \freq, Pseq([82.41, 98, 82.41, 110], inf)); // Lower terreiro | Revert: Pbindef(\congaSeq, \freq, Pseq([98, 98, 130.81, 98, 98, 146.83, 110, 98], inf));
// Ndef(\congaChoir).xset(\amp, 0.2); // Bring choir forward | Revert: Ndef(\congaChoir).xset(\amp, 0.1);
// Ndef(\congaChoir).set(\wet10, 0.6); // Cathedral-like Rosário | Revert: Ndef(\congaChoir).set(\wet10, 0.35);
// Ndef(\gungaRattle).clear(4); Ndef(\congaDrum).clear(4); Ndef(\congaChoir).clear(6); // Rollback: fade out all layers
)

