// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T15:32:52.931187+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Frozen silence, dry friction of folding paper, and suspended wine bottle
// Evoking the brittle tension of 27 years compressed into an antarctic storm at a dinner table.

Ndef(\frozenAir, { |amp=0.25, pan=0, tilt=1200, detune=0.08, crackle=0.02|
    var sub, air, rub, sig;
    // Sub-bass fundamental for the physical weight of accumulated silence
    sub = SinOsc.ar(48 * [0.99, 1.01]) + (SinOsc.ar(96) * 0.3);
    // Suspended glass tension / wine bottle suspended in mid-air
    air = Ringz.ar(PinkNoise.ar(0.003), [2140, 2146] + (detune * 50), 2.5).sum;
    // Dry paper-folding friction (creasing the road map)
    rub = HPF.ar(Dust2.ar(crackle * 80) * PinkNoise.ar(0.15), 3500);
    sig = (sub * 0.7) + (air * 0.4) + (rub * 0.5);
    sig = LPF.ar(sig, tilt);
    Pan2.ar(sig, pan, amp);
}).play;

// ADD_INSTRUMENT: The pedantic unfolding - dry, micro-percussive mechanical creases
Ndef(\mapFolds, { |freq=820, amp=0.22, pan=(-0.2), foldRes=8.0, t_trig=0, decay=0.07|
    var trigSig, exc, body, click, sig;
    trigSig = K2A.ar(t_trig);
    exc = Decay2.ar(trigSig, 0.001, decay);
    // Sharp map crease transients
    click = HPF.ar(WhiteNoise.ar(exc), 4000) * 1.5;
    // Resonant geometric paper body
    body = BPF.ar(click * foldRes, freq.clip(200, 6000), 0.12) * 4.0;
    sig = (click * 0.3) + body;
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Pbindef(\mapSeq,
    \dur, Pseq([0.35, 0.15, 0.5, 0.2, 0.8, 0.25, 0.45], inf),
    \freq, Pseq([640, 920, 480, 1280, 510, 880, 320], inf),
    \decay, Pwhite(0.03, 0.12, inf),
    \pan, Pwhite(-0.6, 0.2, inf),
    \amp, Pseq([0.18, 0.24, 0.15, 0.28, 0.12, 0.22], inf),
    \t_trig, 1
);

Ndef(\mapFolds)[1] = \set -> Pbindef(\mapSeq);

// ADD_EFFECTS: Antarctic cold delay hanging in the restaurant
Ndef(\frozenAir)[10] = \filter -> { |in|
    var coldVerb;
    coldVerb = CombC.ar(in, 1.2, [0.45, 0.58], 4.5);
    LPF.ar(coldVerb, 2800);
};
Ndef(\frozenAir).xset(\wet10, 0.35);

// Rollback:
// Pbindef(\mapSeq).stop; Ndef(\mapFolds).clear(2); Ndef(\frozenAir).set(\wet10, 0); Ndef(\frozenAir).clear(4);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// Formal Archetype: Intrinsic Limit (b) transitioning from domestic silence into Castro Alves's "Navio Negreiro"
// Dantesque nightmare: clanking of chains, snapping whip, groaning oceanic abyss, and visceral inferno.

// ADD_INSTRUMENT: \correntes (Tinir de ferros - metallic clanking of chains, modal resonance)
Ndef(\correntes, { |freq=180, amp=0.28, pan=0, t_trig=0, metalDecay=0.8, drive=2.5|
    var trigSig, exc, modes, sig;
    trigSig = K2A.ar(t_trig);
    exc = PinkNoise.ar * Decay2.ar(trigSig, 0.001, 0.04);
    // Klank-style modal ring of iron shackles and chains
    modes = DynKlank.ar(
        `[
            freq * [1, 2.76, 5.4, 8.9, 11.2],
            [1, 0.6, 0.4, 0.25, 0.15],
            [metalDecay, metalDecay * 0.7, metalDecay * 0.4, 0.2, 0.1]
        ],
        exc
    );
    sig = LeakDC.ar((modes * drive).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\correntesSeq,
    \dur, Pseq([0.25, 0.5, 0.25, 0.75, 0.25, 0.25, 1.0], inf),
    \freq, Pseq([140, 185, 220, 165, 290, 130], inf),
    \metalDecay, Pwhite(0.4, 1.2, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pexprand(0.2, 0.38, inf),
    \t_trig, 1
);

Ndef(\correntes)[1] = \set -> Pbindef(\correntesSeq);

// ADD_INSTRUMENT: \acoite (Estalar de açoite - whip crack & oceanic groaning hull)
Ndef(\acoite, { |amp=0.35, pan=0, t_trig=0, whipTone=3200|
    var trigSig, crack, whipEnv, rumble, sig;
    trigSig = K2A.ar(t_trig);
    whipEnv = Decay2.ar(trigSig, 0.0005, 0.06);
    // Snapping whip: high-impact filtered noise with steep transient distortion
    crack = HPF.ar(WhiteNoise.ar, whipTone) * whipEnv;
    crack = (crack * 8.0).clip2(1.0);
    // Subterranean slave ship hull resonance and saltwater surge
    rumble = BPF.ar(BrownNoise.ar, 58, 0.25) * Decay.ar(trigSig, 1.8) * 4.0;
    sig = (crack * 0.7) + (rumble * 0.5);
    Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\acoiteSeq,
    \dur, Pseq([1.5, 2.25, 0.75, 3.0], inf),
    \whipTone, Pwhite(2500, 5200, inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \amp, Pseq([0.35, 0.45, 0.3, 0.5], inf),
    \t_trig, 1
);

Ndef(\acoite)[1] = \set -> Pbindef(\acoiteSeq);

// TWEAK_INSTRUMENT: Shift \frozenAir into blood-red, suffocating, dantesque sea atmosphere
Ndef(\frozenAir).xset(\tilt, 450, \crackle, 0.15, \detune, 0.4, \amp, 0.32);
// Ndef(\frozenAir).xset(\tilt, 1200, \crackle, 0.02, \detune, 0.08, \amp, 0.25); // Revert tweak

// TWEAK_SEQUENCE: Make \mapSeq stutter violently like frantic, desperate footsteps on the deck
Pbindef(\mapSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125], inf),
    \decay, Pwhite(0.01, 0.05, inf),
    \amp, Pwhite(0.1, 0.25, inf)
);
// Pbindef(\mapSeq, \dur, Pseq([0.35, 0.15, 0.5, 0.2, 0.8, 0.25, 0.45], inf), \decay, Pwhite(0.03, 0.12, inf), \amp, Pseq([0.18, 0.24, 0.15, 0.28, 0.12, 0.22], inf)); // Revert sequence

// ADD_EFFECTS: Cavernous, blood-drenched hold reverb on the chains
Ndef(\correntes)[10] = \filter -> { |in|
    var rev;
    rev = GVerb.ar(in, 180, 5.0, 0.4, 0.7, 15, -3.dbamp, -6.dbamp, -11.dbamp);
    LeakDC.ar(rev);
};
Ndef(\correntes).xset(\wet10, 0.45);
// Ndef(\correntes).set(\wet10, 0); // Rollback: disable this effect

// Rollback: remove added nightmare instruments
// Pbindef(\correntesSeq).stop; Ndef(\correntes).clear(2); Pbindef(\acoiteSeq).stop; Ndef(\acoite).clear(2);
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var clockRhythms;

    // Safety limiter initialization
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    // Discrete mechanical tick and escapement click
    SynthDef(\tickEscapement, {
        var hit, click, metal, env, sig;
        env = EnvGen.ar(Env.perc(\atk.kr(0.0005), \rel.kr(0.035), 1, -6), doneAction: 2);
        hit = WhiteNoise.ar * env;
        click = BPF.ar(hit, \tickFreq.kr(3200), \rq.kr(0.12)) * 4.0;
        metal = Ringz.ar(hit * 0.4, \resFreq.kr(1850), \ringTime.kr(0.025)) * 0.15;
        sig = (click + metal) * \amp.kr(0.2);
        Out.ar(~synthBus, Pan2.ar(sig, \pan.kr(0)));
    }).add;

    // French pendulum chime / chime hammer strike
    SynthDef(\carrilhao, {
        var exc, chime, strike, env, sig;
        env = EnvGen.ar(Env.perc(\atk.kr(0.001), \rel.kr(2.8), 1, -4), doneAction: 2);
        strike = HPF.ar(WhiteNoise.ar, 2500) * EnvGen.ar(Env.perc(0.0005, 0.015));
        exc = (Impulse.ar(0) * 0.8) + (strike * 0.25);
        chime = DynKlank.ar(
            `[
                \freq.kr(440) * [1.0, 2.756, 5.404, 8.93],
                [1.0, 0.45, 0.22, 0.1],
                [\rel.kr(2.8), \rel.kr(2.8) * 0.72, \rel.kr(2.8) * 0.45, 0.35]
            ],
            exc
        );
        sig = (chime + (strike * 0.1)) * env * \amp.kr(0.25);
        Out.ar(~synthBus, Pan2.ar(sig, \pan.kr(0)));
    }).add;

    s.sync;

    if (s.serverRunning) {
        ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
        Synth.tail(RootNode(s), \safetyLimiter);
    };

    // Continuous Ndefs: Swarm of microscopic brass gears and ticking machinery
    Ndef(\engrenagens, { |amp=0, gearRate=8.5, friction=0.35|
        var trigs, teeth, body, panSpread;
        trigs = Dust.ar([gearRate, gearRate * 1.08]);
        teeth = Decay.ar(trigs, 0.012) * BPF.ar(PinkNoise.ar, [2400, 3100] * LFNoise1.kr(0.2).range(0.9, 1.1), 0.2);
        body = Ringz.ar(teeth * friction, [850, 1120], 0.06) * 0.3;
        panSpread = Splay.ar(LeakDC.ar((teeth + body) * 2.5).tanh);
        panSpread * amp;
    });

    // The breathing room / temporal resonance: low hollow wooden pendulum casing
    Ndef(\tempoRespiro, { |amp=0, breathFreq=0.18, lpf=450|
        var breathLFO, casingRes, drift, sig, panPos;
        breathLFO = SinOsc.kr(breathFreq).range(0.1, 0.9);
        drift = LFNoise2.kr(0.3).bipolar(18);
        casingRes = DynKlank.ar(
            `[
                ([58, 116, 174, 232] + drift),
                [0.8, 0.5, 0.3, 0.15],
                [1.8, 1.5, 1.2, 0.8]
            ],
            PinkNoise.ar * 0.012
        );
        sig = LPF.ar(casingRes * breathLFO, lpf);
        panPos = SinOsc.kr(breathFreq * 0.5).range(-0.3, 0.3);
        sig = Pan2.ar(sig, panPos, amp);
        sig;
    });

    // Master Mixer Bus listener & French acoustic reverberation
    Ndef(\masterMix, {
        var discreteIn = In.ar(~synthBus, 2);
        var activeNdefs = Ndef(\engrenagens).ar(2) + Ndef(\tempoRespiro).ar(2);
        discreteIn + activeNdefs;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var dryWet = FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.25);
        LeakDC.ar(dryWet);
    };
    Ndef(\masterMix).set(\wet10, 0.15);
    Ndef(\masterMix).play;

    s.sync;

    // Chronological Master Score
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Escapamento Solitário: O silêncio da oficina de Santa Efigênia]".postln;
        Ndef(\tempoRespiro).fadeTime = 4.0;
        Ndef(\tempoRespiro).xset(\amp, 0.22, \breathFreq, 0.14);

        Pbindef(\tiqueSolitario,
            \instrument, \tickEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.495, 0.505], inf),
            \tickFreq, Pseq([2800, 2200], inf),
            \resFreq, 1400,
            \rel, 0.02,
            \pan, 0,
            \amp, 0.28
        ).play;

        4.do { |i|
            Ndef(\tempoRespiro).xset(\lpf, 380 + (i * 40));
            1.5.wait;
        };

        "0:06 - [Enxame de Latão: Duzentos relógios fora de fase]".postln;
        Ndef(\engrenagens).fadeTime = 3.0;
        Ndef(\engrenagens).xset(\amp, 0.32, \gearRate, 12);

        Pbindef(\defasagemMicro,
            \instrument, \tickEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.248, 0.127, 0.252, 0.123], inf),
            \tickFreq, Pwhite(2100, 4800, inf),
            \resFreq, Pexprand(900, 3200, inf),
            \ringTime, Pwhite(0.01, 0.04, inf),
            \pan, Pwhite(-0.85, 0.85, inf),
            \amp, Pexprand(0.08, 0.24, inf)
        ).play;

        Pbindef(\cronometrosBolso,
            \instrument, \tickEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.166, 0.168, 0.164, 0.167], inf),
            \tickFreq, Pwhite(4500, 6800, inf),
            \resFreq, 3800,
            \rel, 0.015,
            \pan, Pwhite(-0.6, 0.6, inf),
            \amp, 0.16
        ).play;

        4.do { |i|
            Ndef(\engrenagens).xset(\gearRate, 12 + (i * 3), \friction, 0.35 + (i * 0.1));
            Ndef(\masterMix).set(\wet10, 0.18 + (i * 0.03));
            2.0.wait;
        };

        "0:14 - [Carrilhões Franceses: Ressonância da madeira e bronze]".postln;
        Pbindef(\carrilhoesFranca,
            \instrument, \carrilhao,
            \out, ~synthBus,
            \dur, Pseq([2.5, 1.25, 1.25, 3.0, 2.0], inf),
            \freq, Pseq([392.0, 440.0, 329.63, 261.63, 523.25], inf),
            \rel, Pwhite(2.2, 3.6, inf),
            \pan, Pwhite(-0.5, 0.5, inf),
            \amp, 0.28
        ).play;

        5.do { |i|
            Ndef(\tempoRespiro).xset(\breathFreq, 0.18 + (i * 0.02), \lpf, 520 + (i * 60));
            Pbindef(\defasagemMicro, \dur, Pseq([0.124, 0.245, 0.129, 0.256, 0.121] * (1 - (i * 0.02)), inf));
            1.8.wait;
        };

        "0:23 - [O Respirar do Tempo: Desaceleração, alinhamento quase imperfeito]".postln;
        Ndef(\engrenagens).fadeTime = 4.0;
        Ndef(\engrenagens).xset(\amp, 0.12, \gearRate, 6);
        Ndef(\tempoRespiro).fadeTime = 3.0;
        Ndef(\tempoRespiro).xset(\amp, 0.38, \breathFreq, 0.09, \lpf, 320);
        Ndef(\masterMix).set(\wet10, 0.35);

        Pbindef(\carrilhoesFranca).stop;
        Pbindef(\cronometrosBolso).stop;

        Pbindef(\defasagemMicro,
            \dur, Pseq([0.25, 0.5, 0.251, 0.498], inf),
            \tickFreq, Pwhite(2400, 3600, inf),
            \amp, Pseq([0.18, 0.12, 0.16, 0.1], inf)
        );

        3.do { |i|
            Pbindef(\tiqueSolitario, \amp, 0.28 * (1 - (i * 0.15)));
            2.5.wait;
        };

        "0:30.5 - [Flashback & Settling: Um único pêndulo que desacelera na escuridão]".postln;
        Pbindef(\defasagemMicro).stop;
        Ndef(\engrenagens).fadeTime = 2.5;
        Ndef(\engrenagens).xset(\amp, 0);

        Pbindef(\ultimoTique,
            \instrument, \tickEscapement,
            \out, ~synthBus,
            \dur, Pseq([0.65, 0.72, 0.85, 1.1, 1.45], 1),
            \tickFreq, 1850,
            \resFreq, 1100,
            \rel, 0.045,
            \pan, 0,
            \amp, Pseries(0.22, -0.04, 5)
        ).play;

        4.wait;

        "0:34.5 - [Silêncio das engrenagens: Fechamento]".postln;
        Ndef(\tempoRespiro).fadeTime = 3.0;
        Ndef(\tempoRespiro).xset(\amp, 0);

        3.2.wait;

        // Scoped cleanup strictly for objects defined in this block
        Pbindef(\tiqueSolitario).stop; Pbindef(\tiqueSolitario).clear;
        Pbindef(\defasagemMicro).stop; Pbindef(\defasagemMicro).clear;
        Pbindef(\cronometrosBolso).stop; Pbindef(\cronometrosBolso).clear;
        Pbindef(\carrilhoesFranca).stop; Pbindef(\carrilhoesFranca).clear;
        Pbindef(\ultimoTique).stop; Pbindef(\ultimoTique).clear;

        Ndef(\engrenagens).clear(1);
        Ndef(\tempoRespiro).clear(1);
        Ndef(\masterMix).clear(1);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 04 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
s.waitForBoot({
    ~enableRecording = false;

    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Master Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 1. Water Drop impacting calcite pool with non-linear pitch downward chirp & modal ping
    SynthDef(\gotaCalcarea, {
        |out=0, freq=1200, resFreq=310, dropDecay=0.22, ringTime=2.5, pan=0, amp=0.3|
        var pitchenv = EnvGen.ar(Env([freq * 1.6, freq, freq * 0.72], [0.003, 0.04], \exp));
        var exciter = SinOsc.ar(pitchenv) * EnvGen.ar(Env.perc(0.001, dropDecay, 1, -4));
        var click = LPF.ar(PinkNoise.ar, 4500) * EnvGen.ar(Env.perc(0.0005, 0.008));
        var impact = exciter + (click * 0.4);
        var modes = DynKlank.ar(
            `[
                [resFreq, resFreq * 2.14, resFreq * 3.42, resFreq * 5.12],
                [0.7, 0.35, 0.2, 0.08],
                [ringTime, ringTime * 0.75, ringTime * 0.5, ringTime * 0.28]
            ],
            impact
        );
        var sig = (impact * 0.4) + (modes * 0.6);
        var env = EnvGen.ar(Env.perc(0.002, (ringTime + dropDecay).max(0.1)), doneAction: 2);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // 2. Stalactite / Stalagmite mineral percussion: lithophone crystal resonance
    SynthDef(\estalactitePancada, {
        |out=0, freq=520, decayTime=3.2, strikeHard=0.6, pan=0, amp=0.25|
        var impact = Impulse.ar(0) + (HPF.ar(WhiteNoise.ar, 1200) * EnvGen.ar(Env.perc(0.0002, 0.01)));
        var res = DynKlank.ar(
            `[
                freq * [1.0, 2.756, 5.404, 8.93],
                [1.0, 0.45 * strikeHard, 0.25 * strikeHard, 0.1],
                decayTime * [1.0, 0.6, 0.4, 0.2]
            ],
            impact
        );
        var body = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.005, 0.4)) * 0.2;
        var sig = (res + body) * EnvGen.ar(Env.perc(0.001, decayTime.max(0.1)), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // Continuous Vault Acoustics: Subterranean Air Swell across the seven chambers
    Ndef(\abobadaMaquine, {
        |amp=0, rumbleFreq=38, airCutoff=650, drift=0.1|
        var sub = SinOsc.ar(rumbleFreq * [1.0, 1.01] + (LFNoise2.kr(drift).bipolar(1.5)));
        var subHarm = SinOsc.ar(rumbleFreq * 2.02) * 0.35;
        var cavernWind = BPF.ar(
            PinkNoise.ar([0.7, 0.7]),
            LFNoise1.kr(0.08).exprange(80, airCutoff),
            LFNoise1.kr(0.15).range(0.15, 0.45)
        ) * 12.0;
        var deepEcho = CombL.ar(cavernWind, 0.8, SinOsc.kr([0.04, 0.053]).range(0.35, 0.65), 5.5);
        var sig = (sub + subHarm + cavernWind + (deepEcho * 0.4)) * amp;
        sig.tanh;
    });

    // Master Cathedral Reverb & Cavern Reflection Hub
    Ndef(\masterMix, {
        var busIn = In.ar(~synthBus, 2);
        var cavernIn = Ndef(\abobadaMaquine).ar(2);
        busIn + cavernIn;
    });

    // Vast Limestone Cavity Reverb (Salão dos Cristais / Salão das Fadas)
    Ndef(\masterMix)[10] = \filter -> { |in|
        GVerb.ar(
            in.sum * 0.65,
            roomsize: 260,
            revtime: 8.5,
            damping: 0.42,
            inputbw: 0.55,
            spread: 25,
            drylevel: 0.0,
            earlyreflevel: -9.dbamp,
            taillevel: -3.dbamp
        );
    };

    // Subterranean Resonances / Secondary Reflections
    Ndef(\masterMix)[11] = \filter -> { |in|
        CombC.ar(in, 1.4, [0.68, 0.93], 6.0) * 0.5;
    };

    Ndef(\masterMix).play;
    s.sync;

    // Timeline Score
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Salão I: O Descenso de Peter Lund - Vento Telúrico e Escuridão Mineral]".postln;
        Ndef(\masterMix).set(\wet10, 0.55, \wet11, 0.2);
        Ndef(\abobadaMaquine).fadeTime = 6.0;
        Ndef(\abobadaMaquine).xset(\amp, 0.38, \rumbleFreq, 34, \airCutoff, 420);

        Pbindef(\gotasIniciais,
            \instrument, \gotaCalcarea,
            \out, ~synthBus,
            \dur, Pseq([1.4, 2.1, 0.9, 3.2, 1.8], inf),
            \freq, Pexprand(950, 1600, inf),
            \resFreq, Pseq([220, 290, 180, 340, 250], inf),
            \ringTime, Pwhite(2.5, 4.2, inf),
            \pan, Pwhite(-0.75, 0.75, inf),
            \amp, Pexprand(0.18, 0.32, inf)
        ).play;

        4.do { |i|
            Ndef(\abobadaMaquine).xset(\airCutoff, 400 + (i * 90), \rumbleFreq, 34 + (i * 2));
            3.0.wait;
        };

        "0:12.5 - [Salão II: Véu de Noiva - Gotículas em Cortinas de Calcário]".postln;
        Pbindef(\cortinaCalcario,
            \instrument, \gotaCalcarea,
            \out, ~synthBus,
            \dur, Pseq([0.18, 0.22, 0.36, 0.14, 0.45], inf),
            \freq, Pwhite(1400, 2800, inf),
            \resFreq, Pseq([560, 680, 820, 490, 740], inf),
            \dropDecay, Pwhite(0.08, 0.16, inf),
            \ringTime, Pwhite(1.8, 3.0, inf),
            \pan, Pwhite(-0.9, 0.9, inf),
            \amp, Pexprand(0.1, 0.22, inf)
        ).play;

        Ndef(\masterMix).set(\wet10, 0.65, \wet11, 0.35);

        5.do { |i|
            Ndef(\abobadaMaquine).xset(\drift, 0.1 + (i * 0.05));
            Pbindef(\gotasIniciais, \dur, Pseq([1.2, 1.8, 0.8, 2.6] * (1 - (i * 0.04)), inf));
            2.5.wait;
        };

        "0:25 - [Salão dos Cristais: Litofones Ancestrais - Ressonância das Colunas Estalagmiticas]".postln;
        Pbindef(\litofones,
            \instrument, \estalactitePancada,
            \out, ~synthBus,
            \dur, Pseq([0.75, 1.25, 0.5, 1.5, 0.75, 2.0], inf),
            \freq, Pseq([164.81, 220.0, 246.94, 329.63, 196.0, 392.0], inf),
            \decayTime, Pwhite(3.8, 6.0, inf),
            \strikeHard, Pwhite(0.5, 0.9, inf),
            \pan, Pseq([-0.6, 0.6, -0.3, 0.3, -0.8, 0.8], inf),
            \amp, 0.35
        ).play;

        4.do { |i|
            Ndef(\abobadaMaquine).xset(\airCutoff, 750 + (i * 120), \amp, 0.45 + (i * 0.03));
            Ndef(\masterMix).set(\wet11, 0.35 + (i * 0.05));
            3.0.wait;
        };

        "0:37 - [A Cripta do Naturalista: Densidade Mineral Máxima e Turbulência Subterrânea]".postln;
        Pbindef(\cortinaCalcario,
            \dur, Pseq([0.09, 0.12, 0.15, 0.08, 0.18], inf),
            \freq, Pexprand(1800, 3600, inf),
            \amp, Pexprand(0.12, 0.26, inf)
        );

        Pbindef(\litofones,
            \dur, Pseq([0.375, 0.375, 0.75, 0.5, 1.0], inf),
            \decayTime, 5.0,
            \amp, 0.4
        );

        3.do { |i|
            Ndef(\abobadaMaquine).xset(\rumbleFreq, 42 - (i * 3), \airCutoff, 1100 - (i * 150));
            2.5.wait;
        };

        "0:44.5 - [Extinção do Eco: Retorno à Gota Solitária e Repouso Milenar]".postln;
        // Subtractive drop: silence the fast mineral cascades and heavy chords
        Pbindef(\cortinaCalcario).stop;
        Pbindef(\litofones).stop;

        Ndef(\abobadaMaquine).fadeTime = 7.0;
        Ndef(\abobadaMaquine).xset(\amp, 0.12, \rumbleFreq, 30, \airCutoff, 240);
        Ndef(\masterMix).set(\wet10, 0.75, \wet11, 0.15);

        // Flashback: single isolated drops vibrating infinitely in pitch black
        Pbindef(\gotaSolitaria,
            \instrument, \gotaCalcarea,
            \out, ~synthBus,
            \dur, Pseq([2.6, 3.4, 4.2], 1),
            \freq, Pseq([1100, 920, 780], 1),
            \resFreq, Pseq([210, 185, 160], 1),
            \dropDecay, 0.28,
            \ringTime, 5.5,
            \pan, Pseq([0.2, -0.3, 0.0], 1),
            \amp, Pseq([0.28, 0.22, 0.18], 1)
        ).play;

        8.0.wait;

        "0:52.5 - [Silêncio Absoluto da Gruta de Maquiné]".postln;
        Ndef(\abobadaMaquine).fadeTime = 4.0;
        Ndef(\abobadaMaquine).xset(\amp, 0);

        4.5.wait;

        // Scoped cleanup strictly for objects defined in this block
        Pbindef(\gotasIniciais).stop; Pbindef(\gotasIniciais).clear;
        Pbindef(\cortinaCalcario).stop; Pbindef(\cortinaCalcario).clear;
        Pbindef(\litofones).stop; Pbindef(\litofones).clear;
        Pbindef(\gotaSolitaria).stop; Pbindef(\gotaSolitaria).clear;

        Ndef(\abobadaMaquine).clear(2);
        Ndef(\masterMix).clear(2);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: PASS
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// ====================================================================
// INSTRUMENT: LISSAJOUS MATRIX — MODULAR CABINET & ANALOG PHOSPHOR CRT
// Zone 1: Pin-Matrix Sub (Tri/Saw West-Coast Wavefolder Core)
// Zone 2: Lissajous Harmonic Pluck (RingMod Resonator & Ratio Fold)
// Zone 3: Phosphor Tube Drift (Analog Splay Swarm with BPF Formants)
// ====================================================================

~cc = (
    // Zone 1: Pin-Matrix Sub
    vol1: 14, pan1: 15, mute1: 16, min1: 17, max1: 18,
    hpf1: 19, lpf1: 20, rq1: 21, atk1: 22, dec1: 23, sus1: 24, rls1: 25,
    fxFold1: 26,

    // Zone 2: Lissajous Harmonic Pluck
    vol2: 27, pan2: 28, mute2: 29, min2: 30, max2: 31,
    hpf2: 32, lpf2: 33, rq2: 34, atk2: 35, dec2: 36, sus2: 37, rls2: 38,
    fxLissajous2: 39,

    // Zone 3: Phosphor Tube Drift Pad
    vol3: 40, pan3: 41, mute3: 42, min3: 43, max3: 44,
    hpf3: 45, lpf3: 46, rq3: 47, atk3: 48, dec3: 49, sus3: 50, rls3: 51,
    fxPhosphor3: 52,

    // Global Master & Send FX
    delTime: 53, delFeedback: 54, delMix: 55,
    revTime: 56, revDamp: 57, revMix: 58,
    masterVol: 7, panic: 123
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
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 65,
        hpf1: 25.0, lpf1: 280.0, rq1: 0.8, atk1: 0.02, dec1: 0.35, sus1: 0.75, rls1: 0.45,
        fxFold1: 0.0,

        vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 100,
        hpf2: 180.0, lpf2: 4500.0, rq2: 0.5, atk2: 0.005, dec2: 0.4, sus2: 0.2, rls2: 0.8,
        fxLissajous2: 0.0,

        vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127,
        hpf3: 120.0, lpf3: 2800.0, rq3: 0.6, atk3: 0.8, dec3: 1.2, sus3: 0.85, rls3: 1.8,
        fxPhosphor3: 0.0,

        delTime: 0.33, delFeedback: 0.45, delMix: 0.0,
        revTime: 2.8, revDamp: 0.4, revMix: 0.0,
        masterVol: 0.82
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~dryBus = Bus.audio(s, 2);
    ~fxSendBus = Bus.audio(s, 2);

    // ZONE 1: Monophonic West-Coast Wavefolded Bass Sub
    SynthDef(\zone1_sub, {
        |out=0, freq=55, gate=1, vol=0.28, pan=0.0, mute=0,
         hpf=25, lpf=280, rq=0.8, atk=0.02, dec=0.35, sus=0.75, rls=0.45, fxFold1=0.0|
        var f, env, tri, saw, sig;
        f = Lag.kr(freq, 0.08);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        tri = LFTri.ar(f);
        saw = Saw.ar(f * 0.5);
        sig = XFade2.ar(tri, saw, (fxFold1 * 2 - 1).clip(-1, 1));
        sig = Fold.ar(sig * (1.0 + (fxFold1 * 7.0)), -0.85, 0.85);
        sig = MoogFF.ar(sig, lpf.clip(20, 18000), 3.5 * (1.0 - rq.clip(0.1, 1.0))) * 3.5;
        sig = HPF.ar(sig, hpf.clip(20, 1000));
        sig = sig * env * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ZONE 2: Lissajous Harmonic Pluck (Polyphonic Modulator / Wavefold Carrier)
    SynthDef(\zone2_pluck, {
        |out=0, fxSend=0, freq=220, gate=1, vel=0.7, vol=0.22, pan=(-0.35), mute=0,
         hpf=180, lpf=4500, rq=0.5, atk=0.005, dec=0.4, sus=0.2, rls=0.8, fxLissajous2=0.0|
        var env, car, mod, sig, ratio, exciter;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        ratio = 1.0 + (fxLissajous2 * 2.73);
        mod = SinOsc.ar(freq * ratio) * (freq * fxLissajous2 * 3.0);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        car = CombL.ar(exciter, 0.05, freq.reciprocal.clip(0.0001, 0.05), dec * 2.0);
        car = car + (SinOsc.ar(freq + mod) * 0.6);
        sig = Fold.ar(car * (1.0 + (fxLissajous2 * 3.5)), -0.75, 0.75);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 3000));
        sig = sig * env * (vel.linlin(0, 1, 0.4, 1.2)) * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
        Out.ar(fxSend, Pan2.ar(sig * 0.35, pan));
    }).add;

    // ZONE 3: CRT Phosphor Tube Drift Pad (Stereo Swarm & BPF Lissajous Orbit)
    SynthDef(\zone3_phosphor, {
        |out=0, fxSend=0, freq=330, gate=1, vol=0.18, pan=0.35, mute=0,
         hpf=120, lpf=2800, rq=0.6, atk=0.8, dec=1.2, sus=0.85, rls=1.8, fxPhosphor3=0.0|
        var env, lfoX, lfoY, detune, sig, bpf;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        lfoX = SinOsc.kr(0.2 + (fxPhosphor3 * 1.5), 0).linlin(-1, 1, 0.85, 1.15);
        lfoY = SinOsc.kr(0.28 + (fxPhosphor3 * 2.1), 0.5pi).linlin(-1, 1, 0.9, 1.25);
        detune = [-0.15, -0.07, 0.0, 0.08, 0.16] * (1.0 + (fxPhosphor3 * 2.5));
        sig = Splay.ar(VarSaw.ar(freq * (1 + detune), 0, (lfoX - 0.85).clip(0.1, 0.9)));
        bpf = BPF.ar(sig, (freq * lfoY * 2.0).clip(100, 12000), rq.clip(0.1, 1.0));
        sig = XFade2.ar(sig, bpf, (fxPhosphor3 * 2 - 1).clip(-1, 1));
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.1, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 2000));
        sig = sig * env * vol * (1.0 - mute);
        sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) };
        Out.ar(out, sig);
        Out.ar(fxSend, sig * 0.45);
    }).add;

    // MASTER FX: Analog Bucket-Brigade Delay & Phosphor Resonating Space
    SynthDef(\masterFX, {
        |inDry=0, inSend=1, out=0, delTime=0.33, delFeedback=0.45, delMix=0.0,
         revTime=2.8, revDamp=0.4, revMix=0.0, masterVol=0.82|
        var dry, send, dSig, rSig, mix;
        dry = In.ar(inDry, 2);
        send = In.ar(inSend, 2);
        dSig = CombC.ar(send, 1.2, delTime.clip(0.02, 1.0), delFeedback.clip(0, 0.95) * 4.0);
        dSig = LPF.ar(dSig, 4500);
        rSig = FreeVerb2.ar(send[0] + (dSig[0] * 0.2), send[1] + (dSig[1] * 0.2), 1.0, (revTime / 8.0).clip(0.1, 1.0), revDamp.clip(0, 1));
        mix = dry + (dSig * delMix) + (rSig * revMix);
        mix = LeakDC.ar(mix) * masterVol;
        mix = Limiter.ar(mix, 0.92, 0.01);
        ReplaceOut.ar(out, mix);
    }).add;

    s.sync;

    // Instantiate Master FX Chain
    ~fxSynth = Synth.tail(~masterGroup, \masterFX, [
        \inDry, ~dryBus, \inSend, ~fxSendBus, \out, 0,
        \delTime, ~buses[\delTime].asMap,
        \delFeedback, ~buses[\delFeedback].asMap,
        \delMix, ~buses[\delMix].asMap,
        \revTime, ~buses[\revTime].asMap,
        \revDamp, ~buses[\revDamp].asMap,
        \revMix, ~buses[\revMix].asMap,
        \masterVol, ~buses[\masterVol].asMap
    ]);

    // Voice Tracking
    ~zone1Mono = nil;
    ~zone1Notes = List.new;
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // MIDI CC Router (DRY loop)
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
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // MIDI Note On
    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        var freq = noteNum.midicps;
        var normVel = vel / 127.0;

        // Zone 1: Mono Sub
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes.add(noteNum);
            if(~zone1Mono.isNil) {
                ~zone1Mono = Synth.tail(~synthGroup, \zone1_sub, [
                    \out, ~dryBus, \freq, freq, \gate, 1,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                    \fxFold1, ~buses[\fxFold1].asMap
                ]);
            } {
                ~zone1Mono.set(\freq, freq);
            };
        };

        // Zone 2: Poly Pluck
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            var syn = Synth.tail(~synthGroup, \zone2_pluck, [
                \out, ~dryBus, \fxSend, ~fxSendBus, \freq, freq, \gate, 1, \vel, normVel,
                \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                \fxLissajous2, ~buses[\fxLissajous2].asMap
            ]);
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(syn);
        };

        // Zone 3: Poly Phosphor Tube
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            var syn = Synth.tail(~synthGroup, \zone3_phosphor, [
                \out, ~dryBus, \fxSend, ~fxSendBus, \freq, freq, \gate, 1,
                \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                \fxPhosphor3, ~buses[\fxPhosphor3].asMap
            ]);
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(syn);
        };
    }, srcID: ~myUid);

    // MIDI Note Off
    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        // Zone 1 Mono stack
        if(~zone1Notes.includes(noteNum)) {
            ~zone1Notes.remove(noteNum);
            if(~zone1Notes.isEmpty) {
                if(~zone1Mono.notNil) { ~zone1Mono.set(\gate, 0); ~zone1Mono = nil };
            } {
                if(~zone1Mono.notNil) { ~zone1Mono.set(\freq, ~zone1Notes.last.midicps) };
            };
        };

        // Zone 2 Poly release
        if(~zone2Notes[noteNum].notNil) {
            ~zone2Notes[noteNum].do { |sNode| if(sNode.notNil) { sNode.set(\gate, 0) } };
            ~zone2Notes[noteNum] = nil;
        };

        // Zone 3 Poly release
        if(~zone3Notes[noteNum].notNil) {
            ~zone3Notes[noteNum].do { |sNode| if(sNode.notNil) { sNode.set(\gate, 0) } };
            ~zone3Notes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    // Panic Function
    ~panicFunc = {
        if(~zone1Mono.notNil) { ~zone1Mono.set(\gate, 0); ~zone1Mono = nil };
        ~zone1Notes.clear;
        128.do { |idx|
            if(~zone2Notes[idx].notNil) { ~zone2Notes[idx].do { |sNode| sNode.set(\gate, 0) }; ~zone2Notes[idx] = nil };
            if(~zone3Notes[idx].notNil) { ~zone3Notes[idx].do { |sNode| sNode.set(\gate, 0) }; ~zone3Notes[idx] = nil };
        };
        "*** ALL VOICES FREED (PANIC) ***".postln;
    };

    MIDIdef.cc(\panicCC, { |val| if(val > 63) { ~panicFunc.value } }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ====================================================================
    // PAGINATED GUI (DRY Loop-Driven Layout)
    // ====================================================================
    defer {
        var screen, winW, winH, pages, tabBtns;
        screen = Window.availableBounds;
        winW = 820;
        winH = min(720, screen.height - 70);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("LISSAJOUS MATRIX — Modular CRT Phosphor Synthesizer", Rect((screen.width - winW) / 2, (screen.height - winH) / 2, winW, winH), resizable: false, scroll: true);
        ~mainWin.view.background = Color(0.08, 0.10, 0.08);

        // Header
        StaticText(~mainWin, Rect(20, 10, 780, 28))
            .string_("LISSAJOUS MATRIX // 3-ZONE MODULAR CONSOLE")
            .font_(Font("Monaco", 16, true))
            .stringColor_(Color(0.2, 0.95, 0.4));

        ~zoneMeta = [
            (id: 1, title: "ZONE 1: PIN-MATRIX SUB", fxKey: \fxFold1, fxLabel: "WaveFold"),
            (id: 2, title: "ZONE 2: LISSAJOUS PLUCK", fxKey: \fxLissajous2, fxLabel: "Lissajous Ratio"),
            (id: 3, title: "ZONE 3: PHOSPHOR DRIFT", fxKey: \fxPhosphor3, fxLabel: "CRT Orbit")
        ];

        ~ui = ();
        pages = Array.newClear(3);
        tabBtns = Array.newClear(3);

        // Tab Selector Buttons
        ~zoneMeta.do { |zm, pgIdx|
            tabBtns[pgIdx] = Button(~mainWin, Rect(20 + (pgIdx * 190), 45, 180, 32))
                .states_([
                    [zm.title, Color(0.8, 0.8, 0.8), Color(0.15, 0.22, 0.15)],
                    [zm.title, Color(0.1, 0.1, 0.1), Color(0.3, 0.9, 0.4)]
                ])
                .font_(Font("Monaco", 10, true))
                .value_(if(pgIdx == 0, 1, 0))
                .action_({
                    pages.do { |p, j|
                        p.visible = (j == pgIdx);
                        tabBtns[j].value = if(j == pgIdx, 1, 0);
                    };
                });
        };

        // Tab Page Construction via single loop
        ~zoneMeta.do { |zm, pgIdx|
            var zId, pView;
            zId = zm.id;
            pView = CompositeView(~mainWin, Rect(20, 85, 780, 430));
            pView.background = Color(0.12, 0.14, 0.12);
            pView.visible = (pgIdx == 0);
            pages[pgIdx] = pView;

            // Zone Enable & Key Range
            ~ui[("mute" ++ zId).asSymbol] = Button(pView, Rect(15, 15, 120, 26))
                .states_([
                    ["ZONE ACTIVE", Color(0.1, 0.1, 0.1), Color(0.2, 0.9, 0.4)],
                    ["MUTED", Color(0.9, 0.9, 0.9), Color(0.7, 0.2, 0.2)]
                ])
                .font_(Font("Monaco", 10, true))
                .value_(~ccVals[("mute" ++ zId).asSymbol])
                .action_({ |btn|
                    var v = btn.value.asFloat;
                    ~ccVals[("mute" ++ zId).asSymbol] = v;
                    ~buses[("mute" ++ zId).asSymbol].set(v);
                });

            ~ui[("range" ++ zId).asSymbol] = EZRanger(pView, Rect(150, 15, 340, 26), "KeyRange [CC" ++ ~cc[("min" ++ zId).asSymbol] ++ "]", ControlSpec(0, 127, \lin, 1), { |r|
                ~ccVals[("min" ++ zId).asSymbol] = r.value[0];
                ~ccVals[("max" ++ zId).asSymbol] = r.value[1];
                ~buses[("min" ++ zId).asSymbol].set(r.value[0]);
                ~buses[("max" ++ zId).asSymbol].set(r.value[1]);
            }, [~ccVals[("min" ++ zId).asSymbol], ~ccVals[("max" ++ zId).asSymbol]], false, 90, 45);
            ~ui[("range" ++ zId).asSymbol].setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.7, 0.4));

            // Sliders: Volume & Pan
            ~ui[("vol" ++ zId).asSymbol] = EZSlider(pView, Rect(15, 55, 360, 24), "Vol [CC" ++ ~cc[("vol" ++ zId).asSymbol] ++ "]", ControlSpec(0, 1, \lin), { |sl|
                ~ccVals[("vol" ++ zId).asSymbol] = sl.value;
                ~buses[("vol" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("vol" ++ zId).asSymbol]);
            ~ui[("vol" ++ zId).asSymbol].setColors(stringColor: Color.white);

            ~ui[("pan" ++ zId).asSymbol] = EZSlider(pView, Rect(390, 55, 370, 24), "Pan [CC" ++ ~cc[("pan" ++ zId).asSymbol] ++ "]", ControlSpec(-1, 1, \lin), { |sl|
                ~ccVals[("pan" ++ zId).asSymbol] = sl.value;
                ~buses[("pan" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("pan" ++ zId).asSymbol]);
            ~ui[("pan" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Filters
            ~ui[("hpf" ++ zId).asSymbol] = EZSlider(pView, Rect(15, 88, 360, 24), "HPF [CC" ++ ~cc[("hpf" ++ zId).asSymbol] ++ "]", ControlSpec(20, 10000, \exp), { |sl|
                ~ccVals[("hpf" ++ zId).asSymbol] = sl.value;
                ~buses[("hpf" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("hpf" ++ zId).asSymbol]);
            ~ui[("hpf" ++ zId).asSymbol].setColors(stringColor: Color.white);

            ~ui[("lpf" ++ zId).asSymbol] = EZSlider(pView, Rect(390, 88, 370, 24), "LPF [CC" ++ ~cc[("lpf" ++ zId).asSymbol] ++ "]", ControlSpec(40, 18000, \exp), { |sl|
                ~ccVals[("lpf" ++ zId).asSymbol] = sl.value;
                ~buses[("lpf" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("lpf" ++ zId).asSymbol]);
            ~ui[("lpf" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Envelope Knobs
            #[\atk, \dec, \sus, \rls].do { |eParam, kIdx|
                var kKey = (eParam ++ zId).asSymbol;
                var spec = if(eParam == \sus, ControlSpec(0, 1, \lin), ControlSpec(0.005, 5.0, \exp));
                ~ui[kKey] = EZKnob(pView, Rect(25 + (kIdx * 90), 125, 80, 95), eParam.asString.toUpper ++ " [CC" ++ ~cc[kKey] ++ "]", spec, { |kn|
                    ~ccVals[kKey] = kn.value;
                    ~buses[kKey].set(kn.value);
                }, ~ccVals[kKey]);
                ~ui[kKey].setColors(stringColor: Color.white);
            };

            // Resonance Knob
            ~ui[("rq" ++ zId).asSymbol] = EZKnob(pView, Rect(410, 125, 80, 95), "Q [CC" ++ ~cc[("rq" ++ zId).asSymbol] ++ "]", ControlSpec(0.05, 1.0, \lin), { |kn|
                ~ccVals[("rq" ++ zId).asSymbol] = kn.value;
                ~buses[("rq" ++ zId).asSymbol].set(kn.value);
            }, ~ccVals[("rq" ++ zId).asSymbol]);
            ~ui[("rq" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Character Effect Slider
            ~ui[zm.fxKey] = EZSlider(pView, Rect(15, 235, 745, 32), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]", ControlSpec(0.0, 1.0, \lin), { |sl|
                ~ccVals[zm.fxKey] = sl.value;
                ~buses[zm.fxKey].set(sl.value);
            }, ~ccVals[zm.fxKey]);
            ~ui[zm.fxKey].setColors(stringColor: Color(0.2, 0.95, 0.4), sliderColor: Color(0.1, 0.6, 0.2));
        };

        // Static Master / Send FX Strip
        StaticText(~mainWin, Rect(20, 525, 780, 20))
            .string_("CONSOLE BUS & MASTER PHOSPHOR MONITOR")
            .font_(Font("Monaco", 11, true))
            .stringColor_(Color(0.5, 0.8, 0.5));

        ~ui[\delMix] = EZSlider(~mainWin, Rect(20, 550, 370, 24), "Echo Mix [CC" ++ ~cc[\delMix] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\delMix] = sl.value;
            ~buses[\delMix].set(sl.value);
        }, ~ccVals[\delMix]);
        ~ui[\delMix].setColors(stringColor: Color.white);

        ~ui[\revMix] = EZSlider(~mainWin, Rect(410, 550, 370, 24), "Space Mix [CC" ++ ~cc[\revMix] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\revMix] = sl.value;
            ~buses[\revMix].set(sl.value);
        }, ~ccVals[\revMix]);
        ~ui[\revMix].setColors(stringColor: Color.white);

        ~ui[\masterVol] = EZSlider(~mainWin, Rect(20, 582, 540, 28), "MASTER [CC" ++ ~cc[\masterVol] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\masterVol] = sl.value;
            ~buses[\masterVol].set(sl.value);
        }, ~ccVals[\masterVol]);
        ~ui[\masterVol].setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.8, 0.3));

        // Panic Button
        Button(~mainWin, Rect(580, 582, 200, 28))
            .states_([["PANIC (ALL OFF) [CC123]", Color.white, Color(0.7, 0.1, 0.1)]])
            .font_(Font("Monaco", 10, true))
            .action_({ ~panicFunc.value });

        ~mainWin.front;

        // 20 FPS GUI Poller
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
    };
});
)

// To clean up if needed:
// ~panicFunc.value; ~mainWin.close; MIDIdef.freeAll;


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
s.waitForBoot({
    var zIdx;

    // STEP 0: CC Mapping Configuration
    ~cc = (
        vol1: 1, pan1: 2, mute1: 3, hpf1: 4, lpf1: 5, rq1: 6, atk1: 7, dec1: 8, sus1: 9, rls1: 10, fxCabaca: 11,
        vol2: 14, pan2: 15, mute2: 16, hpf2: 17, lpf2: 18, rq2: 19, atk2: 20, dec2: 21, sus2: 22, rls2: 23, fxDobrao: 24,
        vol3: 27, pan3: 28, mute3: 29, hpf3: 30, lpf3: 31, rq3: 32, atk3: 33, dec3: 34, sus3: 35, rls3: 36, fxCaxixi: 37,
        delMix: 80, delTime: 81, revMix: 82, revTime: 83, masterVol: 84, panic: 123
    );

    // Initial parameter values (Clean & dry startup)
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 28, max1: 72, hpf1: 35, lpf1: 4200, rq1: 0.45, atk1: 0.002, dec1: 1.8, sus1: 0.05, rls1: 0.6, fxCabaca: 0.0,
        vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 96, hpf2: 180, lpf2: 7500, rq2: 0.3, atk2: 0.001, dec2: 1.2, sus2: 0.1, rls2: 0.4, fxDobrao: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 800, lpf3: 12000, rq3: 0.6, atk3: 0.001, dec3: 0.25, sus3: 0.0, rls3: 0.15, fxCaxixi: 0.0,
        delMix: 0.0, delTime: 0.34, revMix: 0.0, revTime: 2.2, masterVol: 0.82
    );

    // STEP 1 & 2: MIDI Discovery with Hardware Fallback
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
    } ?? {
        MIDIClient.sources.first
    };

    if(~myInDevice.notNil) {
        MIDIIn.connect(0, ~myInDevice);
        ("MIDI connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
        ~myUid = ~myInDevice.uid;
    } {
        "Warning: No MIDI input device detected.".warn;
        ~myUid = nil;
    };

    // STEP 3: Audio Routing, Groups, Buses
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~busFx = Bus.audio(s, 2);
    ~busMaster = Bus.audio(s, 2);

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Voice Tracking Arrays
    ~notes1 = Array.newClear(128);
    ~notes2 = Array.newClear(128);
    ~notes3 = Array.newClear(128);

    // ZONE 1: Gunga & Cabaça Resonator (Tuned steel wire, wood tap, belly cavity resonance)
    SynthDef(\berimbauGunga, {
        |out=0, freq=110, gate=1, vel=0.8, vol=0.3, pan=0.0, mute=0,
         hpf=40, lpf=4500, rq=0.4, atk=0.002, dec=1.8, sus=0.05, rls=0.6, fxCabaca=0.0|
        var strike, wire, cabRes, modFreq, bellyProx, env, sig;

        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        bellyProx = Lag.kr(fxCabaca, 0.08);

        // Baqueta strike impulse + woody transient
        strike = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.012))) +
                 (HPF.ar(BrownNoise.ar, 600) * EnvGen.ar(Env.perc(0.002, 0.04)) * 1.5);

        // Arame steel wire resonator (comb with dispersion damp)
        modFreq = freq * (1 + (EnvGen.ar(Env.perc(0.001, 0.08)) * 0.035));
        wire = CombL.ar(strike, 0.05, modFreq.reciprocal.clip(0.0005, 0.04), dec * 2.2);
        wire = wire + (SinOsc.ar(modFreq * [1, 2.01, 3.02]) * [0.6, 0.25, 0.12] * EnvGen.ar(Env.perc(0.001, dec * 1.5))).sum;

        // Cabaça open acoustic chamber (BPF cavity formants modulated by belly distance)
        cabRes = BPF.ar(wire, (180 + (bellyProx * 260)), 0.18) * (2.8 + (bellyProx * 3.5));
        cabRes = cabRes + (BPF.ar(wire, (420 + (bellyProx * 480)), 0.22) * 1.8);
        cabRes = cabRes + (BPF.ar(wire, 950, 0.35) * 1.1);

        sig = wire + (cabRes * (0.6 + (bellyProx * 0.9)));
        sig = RLPF.ar(sig, lpf.clip(60, 18000), rq.clip(0.05, 1.0));
        sig = RHPF.ar(sig, hpf.clip(20, 10000), 0.7);
        sig = (sig * (1.0 + (bellyProx * 0.8))).tanh; // Acoustic belly coupling saturation

        sig = sig * env * (vel * 1.2) * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ZONE 2: Dobrão Modulations & Chiaco (Stone/coin edge metallic buzz, pitch bend, rasp)
    SynthDef(\berimbauDobrao, {
        |out=0, freq=165, gate=1, vel=0.7, vol=0.25, pan=(-0.35), mute=0,
         hpf=180, lpf=7500, rq=0.3, atk=0.001, dec=1.2, sus=0.1, rls=0.4, fxDobrao=0.0|
        var env, coinImp, bentFreq, wire, raspBuzz, sig, metalTension;

        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        metalTension = Lag.kr(fxDobrao, 0.05);

        // Dobrão pitch displacement (intervals typically minor/major 2nd or microtonal press)
        bentFreq = freq * (1.0 + (metalTension * 0.125));

        // Metal coin strike + loose metallic rattle
        coinImp = (Dust.ar(1200 * metalTension) * EnvGen.ar(Env.perc(0.01, 0.15)) * 0.4) +
                  (Impulse.ar(0) * 0.8);

        wire = CombL.ar(coinImp + (WhiteNoise.ar * 0.1), 0.03, bentFreq.reciprocal.clip(0.0002, 0.03), dec * 1.6);

        // Metal contact rasp (Ring modulation + high inharmonic cluster)
        raspBuzz = Ringz.ar(wire, [1250, 2480, 4120] * (1.0 + (metalTension * 0.3)), 0.08, [0.3, 0.2, 0.15]).sum;
        raspBuzz = (raspBuzz * (1.0 + (metalTension * 4.0))).fold2(0.6);

        sig = wire + (raspBuzz * (0.2 + (metalTension * 0.85)));
        sig = RLPF.ar(sig, lpf.clip(80, 18000), rq.clip(0.05, 1.0));
        sig = RHPF.ar(sig, hpf.clip(40, 10000), 0.8);

        sig = sig * env * (vel * 1.1) * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ZONE 3: Caxixi Basket Shaker (Woven wicker straw, dried seeds rattle)
    SynthDef(\berimbauCaxixi, {
        |out=0, freq=440, gate=1, vel=0.6, vol=0.2, pan=0.35, mute=0,
         hpf=800, lpf=12000, rq=0.6, atk=0.001, dec=0.25, sus=0.0, rls=0.15, fxCaxixi=0.0|
        var env, shake, seedBursts, wickerFriction, sig, density;

        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -6), gate, doneAction: 2);
        density = Lag.kr(fxCaxixi, 0.05);

        // Seed cluster collisions
        seedBursts = Dust2.ar(1800 + (density * 3200)) * EnvGen.ar(Env.perc(0.001, dec * 0.8));
        shake = WhiteNoise.ar * EnvGen.ar(Env.perc(atk, dec));

        // Wicker resonance bandpass filter array
        wickerFriction = BPF.ar(shake + seedBursts, [2200, 3800, 6400, 9200], [0.25, 0.2, 0.18, 0.15], [0.4, 0.3, 0.2, 0.15]).sum;
        wickerFriction = wickerFriction + (CombN.ar(wickerFriction, 0.01, (0.002 + (density * 0.004)), 0.03) * 0.35);

        sig = wickerFriction;
        sig = RLPF.ar(sig, lpf.clip(200, 18000), rq.clip(0.05, 1.0));
        sig = RHPF.ar(sig, hpf.clip(200, 12000), 0.7);

        sig = sig * env * (vel * 1.2) * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Master Space, Delay & Limiter Processor
    SynthDef(\berimbauMasterFX, {
        |in=0, out=0, delMix=0.0, delTime=0.34, revMix=0.0, revTime=2.2, masterVol=0.8|
        var dry, wetDel, wetRev, sig;

        dry = In.ar(in, 2);

        // Capoeira Roda circular slap-back echo
        wetDel = CombC.ar(dry, 1.2, Lag.kr(delTime, 0.1).clip(0.02, 1.0), Lag.kr(delTime, 0.1) * 2.8);
        wetDel = HPF.ar(LPF.ar(wetDel, 4800), 120);

        // Roda acoustic space reverberation
        wetRev = GVerb.ar(dry[0] + dry[1], 45, Lag.kr(revTime, 0.1).clip(0.2, 8.0), 0.45, 0.65, 18, -3.dbamp, -9.dbamp, -14.dbamp);

        sig = dry + (wetDel * Lag.kr(delMix, 0.08)) + (wetRev * Lag.kr(revMix, 0.08));
        sig = LeakDC.ar(sig * Lag.kr(masterVol, 0.05));
        sig = Limiter.ar(sig, 0.92, 0.01);

        Out.ar(out, sig);
    }).add;

    s.sync;

    // Instantiate Master FX Engine
    ~fxSynth = Synth.tail(~masterGroup, \berimbauMasterFX, [
        \in, ~busMaster,
        \out, 0,
        \delMix, ~buses[\delMix].asMap,
        \delTime, ~buses[\delTime].asMap,
        \revMix, ~buses[\revMix].asMap,
        \revTime, ~buses[\revTime].asMap,
        \masterVol, ~buses[\masterVol].asMap
    ]);

    // Panic Function
    ~panicFunc = {
        128.do { |i|
            if(~notes1[i].notNil) { ~notes1[i].do { |s| if(s.isPlaying) { s.set(\gate, 0) } }; ~notes1[i] = nil };
            if(~notes2[i].notNil) { ~notes2[i].do { |s| if(s.isPlaying) { s.set(\gate, 0) } }; ~notes2[i] = nil };
            if(~notes3[i].notNil) { ~notes3[i].do { |s| if(s.isPlaying) { s.set(\gate, 0) } }; ~notes3[i] = nil };
        };
        "BERIMBAU: All active voices released.".postln;
    };

    // MIDI Note ON Handler (Overlapping organic dynamic zones)
    MIDIdef.noteOn(\berimbauNoteOn, { |vel, num|
        var freq = num.midicps;
        var normVel = vel / 127.0;

        // Zone 1: Gunga & Cabaça Resonator
        if((num >= ~ccVals[\min1]) and: { num <= ~ccVals[\max1] }) {
            var syn = Synth.tail(~synthGroup, \berimbauGunga, [
                \out, ~busMaster, \freq, freq, \vel, normVel,
                \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                \fxCabaca, ~buses[\fxCabaca].asMap
            ]);
            ~notes1[num] = ~notes1[num].add(syn);
            syn.onFree({ ~notes1[num].remove(syn) });
        };

        // Zone 2: Dobrão Metallic Edge & Rasp
        if((num >= ~ccVals[\min2]) and: { num <= ~ccVals[\max2] }) {
            var syn = Synth.tail(~synthGroup, \berimbauDobrao, [
                \out, ~busMaster, \freq, freq, \vel, normVel,
                \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                \fxDobrao, ~buses[\fxDobrao].asMap
            ]);
            ~notes2[num] = ~notes2[num].add(syn);
            syn.onFree({ ~notes2[num].remove(syn) });
        };

        // Zone 3: Caxixi Rattle (Simultaneously percussed in the player's baqueta hand)
        if((num >= ~ccVals[\min3]) and: { num <= ~ccVals[\max3] }) {
            var syn = Synth.tail(~synthGroup, \berimbauCaxixi, [
                \out, ~busMaster, \freq, freq, \vel, normVel,
                \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                \fxCaxixi, ~buses[\fxCaxixi].asMap
            ]);
            ~notes3[num] = ~notes3[num].add(syn);
            syn.onFree({ ~notes3[num].remove(syn) });
        };
    }, srcID: ~myUid);

    // MIDI Note OFF Handler
    MIDIdef.noteOff(\berimbauNoteOff, { |vel, num|
        if(~notes1[num].notNil) { ~notes1[num].do { |s| s.set(\gate, 0) }; ~notes1[num] = nil };
        if(~notes2[num].notNil) { ~notes2[num].do { |s| s.set(\gate, 0) }; ~notes2[num] = nil };
        if(~notes3[num].notNil) { ~notes3[num].do { |s| s.set(\gate, 0) }; ~notes3[num] = nil };
    }, srcID: ~myUid);

    // Loop-Driven CC Dispatcher
    MIDIdef.cc(\berimbauCC, { |val, num|
        var norm = val / 127.0;
        if(num == ~cc[\panic]) {
            ~panicFunc.value;
        } {
            ~cc.keysValuesDo { |key, ccNum|
                if(num == ccNum) {
                    var ks = key.asString;
                    var v = case
                        { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                        { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                        { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                        { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.001, 5.0) }
                        { ks.matchRegexp("min|max") } { val }
                        { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                        { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                        { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                        { norm };
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);

    // STEP 4: Paginated Master GUI Construction
    defer {
        var screen = Window.availableBounds;
        var wWidth = 820;
        var wHeight = min(680, screen.height - 60);
        var tabBtns, pages;

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };

        ~mainWin = Window("BERIMBAU DE BARRIGA — Roda de Capoeira Console", Rect((screen.width - wWidth) * 0.5, (screen.height - wHeight) * 0.5, wWidth, wHeight), scroll: true);
        ~mainWin.background = Color(0.08, 0.09, 0.08);

        ~ui = ();

        // Header Title Banner
        StaticText(~mainWin, Rect(20, 12, 500, 24))
            .string_("BERIMBAU DE BARRIGA (AFRO-BRAZILIAN CORPHONE)")
            .font_(Font("Impact", 18))
            .stringColor_(Color(0.95, 0.85, 0.3));

        StaticText(~mainWin, Rect(20, 36, 600, 16))
            .string_("Verga de Biriba • Arame de Aço • Cabaça de Ressonância • Dobrão • Caxixi")
            .font_(Font("Helvetica", 10))
            .stringColor_(Color(0.6, 0.75, 0.5));

        // Zone Metadata for DRY Loop Construction
        ~zoneMeta = [
            (id: 1, title: "ZONA 1: GUNGA & CABAÇA (Low Cavity & Arame Wire)", fxKey: \fxCabaca, fxLabel: "Cabaça Belly Aperture (Muffled Cavity / Open Projector)"),
            (id: 2, title: "ZONA 2: DOBRÃO & CHIACO (Coin Friction, Buzz & Pitch Bend)", fxKey: \fxDobrao, fxLabel: "Dobrão Steel Press (Inharmonic Rattle / High Rasp)"),
            (id: 3, title: "ZONA 3: CAXIXI DE PALHA (Woven Basket Shaker & Dried Seeds)", fxKey: \fxCaxixi, fxLabel: "Seed Clatter Density (Straw Friction / Grit Impact)")
        ];

        tabBtns = Array.newClear(~zoneMeta.size);
        pages = Array.newClear(~zoneMeta.size);

        // Build Tab Switcher & Dynamic Zone CompositeViews
        ~zoneMeta.do { |zm, i|
            var zId = zm.id;
            var pView;

            tabBtns[i] = Button(~mainWin, Rect(20 + (i * 260), 62, 250, 28))
                .states_([
                    [zm.title.keep(28) ++ "...", Color.black, Color(0.85, 0.75, 0.2)],
                    [zm.title.keep(28) ++ "...", Color.white, Color(0.2, 0.35, 0.2)]
                ])
                .font_(Font("Monaco", 9, true))
                .action_({
                    pages.do { |p, pIdx| p.visible = (pIdx == i) };
                    tabBtns.do { |b, bi| b.value = if(bi == i, 0, 1) };
                });

            pView = CompositeView(~mainWin, Rect(20, 96, 780, 420));
            pView.background = Color(0.12, 0.14, 0.12);
            pages[i] = pView;

            // Zone Title & Keyrange Ranger
            StaticText(pView, Rect(15, 10, 360, 20))
                .string_(zm.title)
                .font_(Font("Monaco", 11, true))
                .stringColor_(Color(0.9, 0.8, 0.4));

            ~ui[("keyrange" ++ zId).asSymbol] = EZRanger(pView, Rect(380, 10, 385, 20), "Key Zone", ControlSpec(0, 127, \lin, 1), { |rng|
                ~ccVals[("min" ++ zId).asSymbol] = rng.value[0];
                ~ccVals[("max" ++ zId).asSymbol] = rng.value[1];
            }, [~ccVals[("min" ++ zId).asSymbol], ~ccVals[("max" ++ zId).asSymbol]]);
            ~ui[("keyrange" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Volume & Pan Sliders
            ~ui[("vol" ++ zId).asSymbol] = EZSlider(pView, Rect(15, 38, 360, 22), "Level [CC" ++ ~cc[("vol" ++ zId).asSymbol] ++ "]", ControlSpec(0, 1, \lin), { |sl|
                ~ccVals[("vol" ++ zId).asSymbol] = sl.value;
                ~buses[("vol" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("vol" ++ zId).asSymbol]);
            ~ui[("vol" ++ zId).asSymbol].setColors(stringColor: Color.white);

            ~ui[("pan" ++ zId).asSymbol] = EZSlider(pView, Rect(390, 38, 290, 22), "Pan [CC" ++ ~cc[("pan" ++ zId).asSymbol] ++ "]", ControlSpec(-1.0, 1.0, \lin), { |sl|
                ~ccVals[("pan" ++ zId).asSymbol] = sl.value;
                ~buses[("pan" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("pan" ++ zId).asSymbol]);
            ~ui[("pan" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Mute Button
            ~ui[("mute" ++ zId).asSymbol] = Button(pView, Rect(690, 38, 75, 22))
                .states_([["PLAY", Color.white, Color(0.2, 0.5, 0.2)], ["MUTE", Color.white, Color(0.7, 0.2, 0.2)]])
                .font_(Font("Monaco", 9, true))
                .value_(~ccVals[("mute" ++ zId).asSymbol].asInteger)
                .action_({ |btn|
                    ~ccVals[("mute" ++ zId).asSymbol] = btn.value.asFloat;
                    ~buses[("mute" ++ zId).asSymbol].set(btn.value.asFloat);
                });

            // Filter Sliders
            ~ui[("hpf" ++ zId).asSymbol] = EZSlider(pView, Rect(15, 68, 360, 22), "HPF [CC" ++ ~cc[("hpf" ++ zId).asSymbol] ++ "]", ControlSpec(20, 14000, \exp), { |sl|
                ~ccVals[("hpf" ++ zId).asSymbol] = sl.value;
                ~buses[("hpf" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("hpf" ++ zId).asSymbol]);
            ~ui[("hpf" ++ zId).asSymbol].setColors(stringColor: Color.white);

            ~ui[("lpf" ++ zId).asSymbol] = EZSlider(pView, Rect(390, 68, 375, 22), "LPF [CC" ++ ~cc[("lpf" ++ zId).asSymbol] ++ "]", ControlSpec(40, 18000, \exp), { |sl|
                ~ccVals[("lpf" ++ zId).asSymbol] = sl.value;
                ~buses[("lpf" ++ zId).asSymbol].set(sl.value);
            }, ~ccVals[("lpf" ++ zId).asSymbol]);
            ~ui[("lpf" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // ADSR Envelopes + Resonance Knobs
            #[\atk, \dec, \sus, \rls].do { |pName, kIdx|
                var kKey = (pName ++ zId).asSymbol;
                var spec = if(pName == \sus, ControlSpec(0, 1, \lin), ControlSpec(0.001, 5.0, \exp));
                ~ui[kKey] = EZKnob(pView, Rect(25 + (kIdx * 95), 102, 80, 92), pName.asString.toUpper ++ " [CC" ++ ~cc[kKey] ++ "]", spec, { |kn|
                    ~ccVals[kKey] = kn.value;
                    ~buses[kKey].set(kn.value);
                }, ~ccVals[kKey]);
                ~ui[kKey].setColors(stringColor: Color.white);
            };

            ~ui[("rq" ++ zId).asSymbol] = EZKnob(pView, Rect(420, 102, 80, 92), "Q [CC" ++ ~cc[("rq" ++ zId).asSymbol] ++ "]", ControlSpec(0.05, 1.0, \lin), { |kn|
                ~ccVals[("rq" ++ zId).asSymbol] = kn.value;
                ~buses[("rq" ++ zId).asSymbol].set(kn.value);
            }, ~ccVals[("rq" ++ zId).asSymbol]);
            ~ui[("rq" ++ zId).asSymbol].setColors(stringColor: Color.white);

            // Distinctive Character Effect Slider
            ~ui[zm.fxKey] = EZSlider(pView, Rect(15, 210, 750, 34), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]", ControlSpec(0.0, 1.0, \lin), { |sl|
                ~ccVals[zm.fxKey] = sl.value;
                ~buses[zm.fxKey].set(sl.value);
            }, ~ccVals[zm.fxKey]);
            ~ui[zm.fxKey].setColors(stringColor: Color(0.95, 0.85, 0.2), sliderColor: Color(0.5, 0.45, 0.1));
        };

        // Initialize First Tab Active
        pages.do { |p, pIdx| p.visible = (pIdx == 0) };
        tabBtns.do { |b, bi| b.value = if(bi == 0, 0, 1) };

        // Bottom Strip: Roda Echo, Reverb & Master Limiter Console
        StaticText(~mainWin, Rect(20, 528, 780, 18))
            .string_("ACOUSTIC RODA SLAPBACK DELAY & CIRCULAR SPACE REVERBERATION")
            .font_(Font("Monaco", 10, true))
            .stringColor_(Color(0.8, 0.7, 0.4));

        ~ui[\delMix] = EZSlider(~mainWin, Rect(20, 550, 375, 22), "Roda Slap [CC" ++ ~cc[\delMix] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\delMix] = sl.value;
            ~buses[\delMix].set(sl.value);
        }, ~ccVals[\delMix]);
        ~ui[\delMix].setColors(stringColor: Color.white);

        ~ui[\revMix] = EZSlider(~mainWin, Rect(410, 550, 385, 22), "Space Reverb [CC" ++ ~cc[\revMix] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\revMix] = sl.value;
            ~buses[\revMix].set(sl.value);
        }, ~ccVals[\revMix]);
        ~ui[\revMix].setColors(stringColor: Color.white);

        ~ui[\masterVol] = EZSlider(~mainWin, Rect(20, 580, 540, 26), "MASTER [CC" ++ ~cc[\masterVol] ++ "]", ControlSpec(0, 1, \lin), { |sl|
            ~ccVals[\masterVol] = sl.value;
            ~buses[\masterVol].set(sl.value);
        }, ~ccVals[\masterVol]);
        ~ui[\masterVol].setColors(stringColor: Color.white, sliderColor: Color(0.3, 0.7, 0.3));

        // Panic Button
        Button(~mainWin, Rect(580, 580, 215, 26))
            .states_([["PANIC (ALL OFF) [CC123]", Color.white, Color(0.7, 0.15, 0.15)]])
            .font_(Font("Monaco", 10, true))
            .action_({ ~panicFunc.value });

        ~mainWin.front;

        // 20 FPS GUI Polling Loop on AppClock
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
    };
});
}.value;
)

// To clean up if needed:
// ~panicFunc.value; ~mainWin.close; MIDIdef.freeAll;


// ============================================================
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// ==============================================================================
// CONGADA: Ternos de Congo, Moçambiques e Gungas de Tornozelo
// Processional rhythm of tin rattles (gungas), resonance boxes, and syncretic chant
// ==============================================================================

// --- Layer 1: Gungas de Lata (Ankle Tin Rattles & Shaken Metal Beads) ---
Ndef(\gungas).fadeTime = 2.5;
Ndef(\gungas, { |t_trig=0, pan=0, amp=0.22, bright=1.0, decTime=0.18|
    var trigA, exciter, metal, rattle, sig;
    trigA = K2A.ar(t_trig);
    exciter = Decay2.ar(trigA, 0.001, 0.015) * WhiteNoise.ar;
    // Resonant modes of sheet metal tin cans (gungas) with loose metal seeds inside
    metal = Ringz.ar(
        exciter,
        [820, 1420, 2180, 3450, 4800, 6200] * bright,
        [0.08, 0.06, 0.04, 0.03, 0.02, 0.015] * (decTime / 0.18)
    ).sum;
    rattle = Dust.ar(180) * Decay.ar(trigA, decTime) * 0.4;
    sig = HPF.ar(metal + rattle, 400);
    sig = (sig * 2.8).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\gungas)[10] = \filter -> { |in|
    CombC.ar(in, 0.2, [0.035, 0.048], 0.4) * 0.35 + (FreeVerb.ar(in, 1.0, 0.72, 0.3) * 0.65);
};
Ndef(\gungas).set(\wet10, 0.22);

Pbindef(\gungasSeq,
    \t_trig, 1,
    // Cadenced processional marching swing: 6/8 - 12/8 cross-rhythmic footsteps
    \dur, Pwrand([0.166, 0.333, 0.25], [0.65, 0.25, 0.10], inf),
    \bright, Pseq([1.0, 1.12, 0.95, 1.25, 1.05, 0.88], inf) * Pwhite(0.96, 1.04, inf),
    \decTime, Pwrand([0.08, 0.16, 0.24], [0.5, 0.35, 0.15], inf),
    \pan, Pwhite(-0.65, 0.65, inf),
    \amp, Pseq([0.24, 0.16, 0.19, 0.26, 0.15, 0.21], inf)
);
Ndef(\gungas).quant = 1;
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);

// --- Layer 2: Tambor de Congo / Caixa da Coroação (Resonant Wood & Skin) ---
Ndef(\tamborCongo).fadeTime = 3.0;
Ndef(\tamborCongo, { |t_trig=0, fund=65, click=1.0, tone=1.0, pan=0, amp=0.28|
    var trigA, bodyEnv, pEnv, body, clickSig, sig;
    trigA = K2A.ar(t_trig);
    pEnv = EnvGen.ar(Env([1.6, 1.0, 0.85], [0.015, 0.18], \exp), trigA);
    bodyEnv = EnvGen.ar(Env.perc(0.003, 0.38, 1, -4), trigA);
    // Membranophone shell saturation and sub weight
    body = SinOscFB.ar(fund * pEnv, 0.35 * tone) * bodyEnv;
    body = body + (Pulse.ar(fund * 0.5 * pEnv, 0.45) * bodyEnv * 0.3);
    clickSig = BPF.ar(WhiteNoise.ar, 1800 * tone, 0.3) * Decay2.ar(trigA, 0.001, 0.02) * click;
    sig = body + clickSig;
    sig = MoogFF.ar(sig, (fund * 12 * tone).clip(200, 12000), 1.2);
    sig = LeakDC.ar((sig * 1.5).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\tamborCongo)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 45, 2.2, 0.55, 0.4, 25, 0.dbamp, -9.dbamp, -14.dbamp);
};
Ndef(\tamborCongo).set(\wet10, 0.18);

Pbindef(\tamborSeq,
    \t_trig, 1,
    // Polyrhythmic cortege pulse
    \dur, Pseq([0.333, 0.166, 0.166, 0.333, 0.25, 0.25], inf),
    \fund, Pseq([58, 58, 65, 58, 73, 58], inf),
    \tone, Pseq([1.0, 0.85, 1.15, 0.9, 1.2, 0.8], inf),
    \click, Pseq([1.0, 0.4, 0.7, 0.9, 0.5, 0.8], inf),
    \pan, Pseq([(-0.2), 0.2, (-0.1), 0.15, 0.0, (-0.25)], inf),
    \amp, Pseq([0.28, 0.18, 0.22, 0.27, 0.20, 0.24], inf)
);
Ndef(\tamborCongo).quant = 1;
Ndef(\tamborCongo)[1] = \set -> Pbindef(\tamborSeq);

// --- Layer 3: Canto de Rosário / Moçambique Formant Drone (Call & Devotion) ---
Ndef(\cantoRosario).fadeTime = 4.0;
Ndef(\cantoRosario, { |t_trig=0, freq=196, vowel=0.5, pan=0, amp=0.18|
    var trigA, env, rawSource, monoSource, formantsA, formantsO, formantsU, formF, filtered, sig;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.25, 0.8, 1.2], -2), trigA);
    // Rich harmonic vocal cord model with gentle vibrato and detuned chorus
    rawSource = Splay.ar(Saw.ar(freq * [0.992, 1.0, 1.008] + SinOsc.kr(5.2, 0, freq * 0.012)));
    monoSource = rawSource.sum;
    // Formant filter arrays (/a/, /o/, /u/)
    formantsA = BPF.ar(monoSource, [800, 1200, 2600], 0.12).sum;
    formantsO = BPF.ar(monoSource, [500, 950, 2400], 0.10).sum;
    formantsU = BPF.ar(monoSource, [350, 700, 2200], 0.08).sum;
    filtered = SelectX.ar(vowel * 2.0, [formantsU, formantsO, formantsA]);
    sig = filtered * env * 4.5;
    sig = LeakDC.ar(sig.tanh);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25);
};
Ndef(\cantoRosario).set(\wet10, 0.35);

Pbindef(\cantoSeq,
    \t_trig, 1,
    \dur, Pseq([2.0, 1.5, 2.5, 3.0, 2.0], inf),
    // Modal prayer chants in praise of São Benedito and Nossa Senhora do Rosário (G pentatonic/dorian)
    \freq, Pseq([196.0, 220.0, 246.94, 293.66, 261.63], inf) * Pwrand([0.5, 1.0], [0.25, 0.75], inf),
    \vowel, Pseq([0.1, 0.6, 0.9, 0.4, 0.75], inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \amp, Pwhite(0.14, 0.20, inf)
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\cantoSeq);
)

// ==============================================================================
// LIVE PERFORMANCE CONTROLS & ROLLBACK
// ==============================================================================
// Ndef(\gungas).xset(\bright, 1.4); // Sharpen ankle tin rattles | Revert: Ndef(\gungas).xset(\bright, 1.0);
// Pbindef(\gungasSeq, \dur, 0.125); // Accelerate cortege footwork | Revert: Pbindef(\gungasSeq, \dur, Pwrand([0.166, 0.333, 0.25], [0.65, 0.25, 0.10], inf));
// Ndef(\tamborCongo).xset(\fund, 48); // Deepen ceremonial drum bass | Revert: Ndef(\tamborCongo).xset(\fund, 65);
// Pbindef(\cantoSeq, \vowel, 1.0); // Open vowel chant to full /a/ | Revert: Pbindef(\cantoSeq, \vowel, Pseq([0.1, 0.6, 0.9, 0.4, 0.75], inf));
// Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 3; Ndef(\gungas).clear(3); // Rollback gungas
// Pbindef(\tamborSeq).stop; Ndef(\tamborCongo).fadeTime = 3; Ndef(\tamborCongo).clear(3); // Rollback tambor
// Pbindef(\cantoSeq).stop; Ndef(\cantoRosario).fadeTime = 4; Ndef(\cantoRosario).clear(4); // Rollback canto


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: FIXED
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// --- Layer 1: Corixo Pantaneiro & Crepúsculo Incandescente (Water Surface, Camalotes, Horizon Drone) ---
Ndef(\pantanalCorixo).fadeTime = 4.0;
Ndef(\pantanalCorixo, { |t_trig=0, fund=55, morph=0.4, pan=0, amp=0.22|
    var trigA, subEnv, warmBed, rippleExciter, waterDroplets, sig;
    trigA = K2A.ar(t_trig);
    subEnv = EnvGen.ar(Env([0, 1, 0.85, 0], [1.2, 2.5, 3.5], \sin), trigA);
    // Incandescent evening heat: sub fundamental with slow beating detune and warm saturation
    warmBed = Splay.ar(
        Saw.ar(fund * [0.995, 1.0, 1.006, 1.99, 2.01]) * 0.4
        + (SinOsc.ar(fund * [0.5, 1.0, 1.5], 0, [0.8, 0.5, 0.25]).sum)
    );
    warmBed = MoogFF.ar(warmBed, (fund * 6 * (1 + (morph * 1.5))).clip(120, 2400), 1.8) * subEnv;
    // Water surface ripples through aquatic plants (camalotes & vitórias-régias)
    rippleExciter = Dust.ar(14 + (morph * 20)) * EnvGen.ar(Env.perc(0.002, 0.04), Dust.ar(12));
    waterDroplets = DynKlank.ar(
        `[[620, 880, 1240, 1680, 2350], [0.4, 0.35, 0.25, 0.2, 0.15], [0.15, 0.12, 0.08, 0.06, 0.04]],
        rippleExciter
    );
    waterDroplets = HPF.ar(waterDroplets, 400) * 0.35;
    sig = warmBed + waterDroplets;
    sig = LeakDC.ar((sig * 1.4).tanh);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\pantanalCorixo)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35);
};
Ndef(\pantanalCorixo).set(\wet10, 0.28);

Pbindef(\pantanalCorixoSeq,
    \t_trig, 1,
    \dur, Pseq([3.5, 4.0, 3.0, 4.5], inf),
    \fund, Pseq([49.0, 55.0, 51.91, 58.27], inf), // G1, A1, G#1, A#1 slow tectonic shifts
    \morph, Pseq([0.3, 0.55, 0.4, 0.7], inf),
    \pan, Pseq([(-0.15), 0.15, (-0.1), 0.05], inf),
    \amp, Pwhite(0.20, 0.26, inf)
);
Ndef(\pantanalCorixo).quant = 1;
Ndef(\pantanalCorixo)[1] = \set -> Pbindef(\pantanalCorixoSeq);

// --- Layer 2: Piúva Seco & Tuiuiús (Stately Wood Resonances, Bill Clattering) ---
Ndef(\tuiuiuVigil).fadeTime = 3.0;
Ndef(\tuiuiuVigil, { |t_trig=0, tone=720, resDec=0.18, pan=0, amp=0.18|
    var trigA, snap, woodBody, billClatter, sig;
    trigA = K2A.ar(t_trig);
    // Bill clattering (bater de bicos ritual) on dry piúva branches
    snap = WhiteNoise.ar * Decay2.ar(trigA, 0.001, 0.015);
    woodBody = DynKlank.ar(
        Ref([
            tone * [1.0, 1.72, 2.85, 4.12],
            [1.0, 0.6, 0.35, 0.2],
            [resDec, resDec * 0.7, resDec * 0.4, 0.04]
        ]),
        snap
    );
    billClatter = Ringz.ar(trigA * 0.4, tone * 0.82, 0.035).fold2(0.6);
    sig = (woodBody * 0.8) + billClatter;
    sig = HPF.ar(sig, 220);
    sig = LeakDC.ar(sig * 1.6);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\tuiuiuVigil)[10] = \filter -> { |in|
    CombC.ar(in, 0.3, [0.08, 0.11], 1.2);
};
Ndef(\tuiuiuVigil).set(\wet10, 0.20);

Pbindef(\tuiuiuVigilSeq,
    \t_trig, 1,
    // Spaced, stoic wooden taps with occasional rapid double-clatter
    \dur, Pwrand([0.25, 0.5, 0.75, 1.5, 0.125], [0.35, 0.25, 0.2, 0.1, 0.1], inf),
    \tone, Pseq([540, 680, 720, 480, 860, 620], inf),
    \resDec, Pwhite(0.08, 0.22, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pwrand([0.16, 0.22, 0.14], [0.6, 0.3, 0.1], inf)
);
Ndef(\tuiuiuVigil).quant = 1;
Ndef(\tuiuiuVigil)[1] = \set -> Pbindef(\tuiuiuVigilSeq);

// --- Layer 3: Araras-Azuis em Revoada (Wing Flaps, Screeches & Doppler Trajectory) ---
Ndef(\ararasAzuis).fadeTime = 3.0;
Ndef(\ararasAzuis, { |t_trig=0, freq=980, fMod=2.4, wingSpeed=6.5, pan=0, amp=0.17|
    var trigA, callEnv, wingEnv, wingFlap, mod, rawScreech, monoCall, form1, form2, sig;
    trigA = K2A.ar(t_trig);
    callEnv = EnvGen.ar(Env([0, 1, 0.8, 0], [0.06, 0.22, 0.35], \sin), trigA);
    wingEnv = EnvGen.ar(Env.perc(0.02, 0.75), trigA);
    // Low turbulent rush of broad wings cutting the twilight air
    wingFlap = BPF.ar(BrownNoise.ar, SinOsc.kr(wingSpeed).range(120, 380), 0.45) * 8.0 * wingEnv;
    // Screeching guttural vocality: harsh FM with ring-mod throat harmonics
    mod = SinOsc.ar(freq * fMod) * (freq * 1.8);
    rawScreech = Pulse.ar(freq + mod, 0.38) * callEnv;
    monoCall = rawScreech + (PinkNoise.ar * 0.2 * callEnv);
    // Vowel nasal throat resonances (/kraa-kraa/ of Anodorhynchus hyacinthinus)
    form1 = BPF.ar(monoCall, 1350, 0.15) * 4.5;
    form2 = BPF.ar(monoCall, 2450, 0.12) * 5.0;
    sig = Pan2.ar(wingFlap, pan.neg * 0.5) + Pan2.ar(form1 + form2, pan);
    sig = LeakDC.ar((sig * 1.5).tanh);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\ararasAzuis)[10] = \filter -> { |in|
    GVerb.ar(in[0] + in[1], 110, 3.8, 0.45, 0.6, 18, 0.dbamp, -8.dbamp, -14.dbamp);
};
Ndef(\ararasAzuis).set(\wet10, 0.25);

Pbindef(\ararasAzuisSeq,
    \t_trig, 1,
    // Polyrhythmic bursts resembling a vocal flock traversing the sky
    \dur, Pseq([0.75, 0.25, 0.5, 1.25, 0.33, 0.33, 1.5], inf),
    \freq, Pseq([880, 1120, 940, 1350, 780, 1050], inf),
    \fMod, Pseq([2.1, 2.7, 1.9, 3.1, 2.4], inf),
    \wingSpeed, Pwhite(5.5, 8.5, inf),
    \pan, Pn(Pseries(-0.85, 0.28, 7), inf), // Sweeping spatial flight across the horizon
    \amp, Pwhite(0.14, 0.22, inf)
);
Ndef(\ararasAzuis).quant = 1;
Ndef(\ararasAzuis)[1] = \set -> Pbindef(\ararasAzuisSeq);
)

