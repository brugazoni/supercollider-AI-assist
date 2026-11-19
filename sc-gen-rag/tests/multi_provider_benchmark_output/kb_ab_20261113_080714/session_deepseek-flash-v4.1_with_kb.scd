// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-13T11:20:49.400597+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ═══════════════════════════════════════════════════════════════════
// "Vinte e Sete Anos" — The Suspended Bottle
// A domestic silence acquiring the weight of an Antarctic storm
// ═══════════════════════════════════════════════════════════════════

// ─── INSTRUMENTS (Ndefs) ───────────────────────────────────────────

// The frozen wine bottle — a suspended, trembling tone held in air
Ndef(\suspendedBottle, { |freq=220, amp=0.22, tremRate=0.7, detune=1.003|
    var osc, trem, sig;
    osc = SinOsc.ar([freq, freq*detune, freq*2.01, freq*0.5]) * [1, 0.7, 0.25, 0.4];
    trem = SinOsc.kr(tremRate).range(0.82, 1.0);
    sig = Splay.ar(osc) * trem;
    sig * amp;
}).play;

// The 27 years — a patient, unbroken pulse of quiet order
Ndef(\twentySevenYears, { |freq=110, amp=0.14, pulseRate=0.28|
    var pulse, osc, sig;
    pulse = LFPulse.kr(pulseRate, 0, 0.45).range(0.15, 1.0);
    osc = LFTri.ar([freq, freq*1.5]) + SinOsc.ar(freq*0.5, 0, 0.6);
    sig = RLPF.ar(osc, 850, 0.6);
    sig * pulse * amp;
}).play;

// The map folding — meticulous, obsessive paper creases
Ndef(\mapFold, { |amp=0.35, pan=0, t_trig=0, bright=1|
    var env, noise, sig;
    env = EnvGen.ar(Env.perc(0.001, 0.09), K2A.ar(t_trig));
    noise = WhiteNoise.ar;
    sig = BPF.ar(noise, 2500*bright, 0.4) * 12;
    sig = sig + (BPF.ar(noise, 6200*bright, 0.55) * 6);
    Pan2.ar(sig * env * amp, pan);
}).play;

// The Antarctic weight — deep sub rumble of a storm about to break
Ndef(\antarcticWeight, { |amp=0.12, freq=32, modRate=0.07|
    var mod, sub, harmonic, rumble, sig;
    mod = LFNoise1.kr(modRate).range(0.7, 1.3);
    sub = SinOsc.ar(freq * mod);
    harmonic = SinOsc.ar(freq * 2 * mod, 0, 0.55);
    rumble = LPF.ar(BrownNoise.ar(0.35), 130);
    sig = (sub + harmonic + rumble);
    Pan2.ar(sig * amp, 0);
}).play;

// Restaurant murmur — distant, indifferent ambience
Ndef(\restaurantMurmur, { |amp=0.07, cutoff=650|
    var noise, sig;
    noise = PinkNoise.ar;
    sig = LPF.ar(noise, cutoff) * 4;
    sig = sig + (BPF.ar(noise, 1800, 0.3) * 2);
    Pan2.ar(sig * amp, LFNoise2.kr(0.2).range(-0.4, 0.4));
}).play;

// ─── EFFECTS ───────────────────────────────────────────────────────

// Frozen-moment reverb on the suspended bottle
Ndef(\suspendedBottle)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.92, 0.4) };
Ndef(\suspendedBottle).set(\wet10, 0.35);

// Obsessive repetition delay on the map folds
Ndef(\mapFold)[10] = \filter -> { |in| CombL.ar(in, 0.4, 0.28, 2.5) };
Ndef(\mapFold).set(\wet10, 0.22);

// Pressure saturation on the Antarctic weight
Ndef(\antarcticWeight)[10] = \filter -> { |in|
    var sig;
    sig = (in * 3.5).tanh;
    LeakDC.ar(sig);
};
Ndef(\antarcticWeight).set(\wet10, 0.4);

// ─── SEQUENCES ─────────────────────────────────────────────────────

// The methodical rhythm of folding a road map, section by section
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25, 0.125, 0.125], inf),
    \t_trig, 1,
    \amp, Pseq([0.5, 0.3, 0.4, 0.55, 0.3, 0.4, 0.28, 0.35], inf),
    \bright, Pwhite(0.8, 1.4, inf),
    \pan, Pwhite(-0.5, 0.5, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// The slow harmonic cycle of 27 patient years
Pbindef(\twentySevenSeq,
    \dur, 4,
    \freq, Pseq([110, 130.81, 146.83, 110, 98, 110], inf),
    \pulseRate, Pseq([0.28, 0.32, 0.22, 0.28], inf),
    \amp, 0.14
);
Ndef(\twentySevenYears)[1] = \set -> Pbindef(\twentySevenSeq);

// The bottle, suspended — occasional shifts of held pitch
Pbindef(\bottleSeq,
    \dur, Pseq([8, 12, 16, 10], inf),
    \freq, Pseq([220, 246.94, 220, 196, 220, 261.63], inf),
    \tremRate, Pseq([0.7, 0.9, 0.5, 0.7], inf),
    \amp, 0.22
);
Ndef(\suspendedBottle)[1] = \set -> Pbindef(\bottleSeq);

// ─── ROLLBACK (comment out / uncomment to remove this block) ───────
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\twentySevenSeq).stop; Ndef(\twentySevenYears).fadeTime = 2; Ndef(\twentySevenYears).clear(2);
// Pbindef(\bottleSeq).stop; Ndef(\suspendedBottle).fadeTime = 2; Ndef(\suspendedBottle).clear(2);
// Ndef(\antarcticWeight).fadeTime = 2; Ndef(\antarcticWeight).clear(2);
// Ndef(\restaurantMurmur).fadeTime = 2; Ndef(\restaurantMurmur).clear(2);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ═══════════════════════════════════════════════════════════════════
// MOVEMENT II: "O Navio Negreiro" — The Slave Ship
// A dantesque dream: clanking irons, cracking whips, groaning legions,
// a desperate prayer begging for lightning to break the cursed chains.
// ═══════════════════════════════════════════════════════════════════

// ─── STRUCTURAL CUT: fade out the domestic scene (Intrinsic Limit b) ──
// The gentle 27-year silence dissolves into the nightmare.
Pbindef(\bottleSeq).stop;
Pbindef(\twentySevenSeq).stop;
Pbindef(\mapFoldSeq).stop;
Ndef(\suspendedBottle).fadeTime = 3; Ndef(\suspendedBottle).clear(3);
Ndef(\twentySevenYears).fadeTime = 3; Ndef(\twentySevenYears).clear(3);
Ndef(\mapFold).fadeTime = 3; Ndef(\mapFold).clear(3);
Ndef(\restaurantMurmur).fadeTime = 3; Ndef(\restaurantMurmur).clear(3);
// Rollback: re-evaluate the previous composition block to restore the domestic scene.

// ─── NEW INSTRUMENTS (Ndefs) ──────────────────────────────────────

// Clanking Irons — metallic chains of the slave hold
Ndef(\chainClank, { |t_trig=0, amp=0.4, baseFreq=800, decay=0.3, pan=0|
    var exc, env, sig;
    env = EnvGen.ar(Env.perc(0.001, decay), K2A.ar(t_trig));
    exc = Impulse.ar(0) + (WhiteNoise.ar * 0.5);
    sig = Klank.ar(`[[baseFreq, baseFreq * 1.5, baseFreq * 2.3, baseFreq * 3.7], nil,
        [0.9, 0.7, 0.5, 0.3]], exc * env, 1, 0, decay);
    Pan2.ar(sig * amp, pan);
}).play;

// Whip Crack — the stinging lash of the açoite
Ndef(\whipCrack, { |t_trig=0, amp=0.7, cut=4000, pan=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.0005, 0.06), K2A.ar(t_trig));
    sig = WhiteNoise.ar;
    sig = BPF.ar(sig, cut, 0.3) * 8;
    sig = sig + (HPF.ar(sig, 2000) * 2);
    sig = (sig * env * 2.5).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

// Groaning Wind — men moaning under the salt spray
Ndef(\groanWind, { |amp=0.3, baseFreq=80, moanRate=0.1, spread=1|
    var osc, mod, env, sig;
    mod = LFNoise1.kr(moanRate.dup(4)).range(0.9, 1.1);
    osc = SinOsc.ar(baseFreq * [1, 1.5, 2.3, 3.1] * mod, 0, [1, 0.6, 0.3, 0.15]);
    env = LFNoise1.kr(0.07).range(0.5, 1.0);
    sig = Splay.ar(osc) * env;
    sig = LPF.ar(sig, 400);
    sig * amp;
}).play;

// Storm Surge — the rising tempest of the Atlantic
Ndef(\stormSurge, { |amp=0.25, rate=0.15, rq=0.2|
    var mod, sig;
    mod = LFNoise1.kr(rate).range(150, 800);
    sig = WhiteNoise.ar;
    sig = RLPF.ar(sig, mod, rq) * 2;
    sig = sig + (BPF.ar(sig, 1200, 0.5) * 0.5);
    Pan2.ar(sig * amp, 0);
}).play;

// Desperate Prayer — a fragile, imploring chorale
Ndef(\desperatePrayer, { |amp=0.18, baseFreq=440|
    var osc, env, sig;
    osc = SinOsc.ar([baseFreq, baseFreq * 1.2, baseFreq * 1.5, baseFreq * 1.8, baseFreq * 2.0],
        0, [1, 0.6, 0.4, 0.3, 0.2]);
    env = LFTri.kr(0.05).range(0.3, 1.0);
    sig = Splay.ar(osc) * env;
    sig = LPF.ar(sig, 2500);
    sig * amp;
}).play;

// Desperate Drum — a horrendous, ritualistic dance pulse
Ndef(\desperateDrum, { |t_trig=0, amp=0.5, freq=60, decay=0.8|
    var env, pitchEnv, sig;
    env = EnvGen.ar(Env.perc(0.005, decay), K2A.ar(t_trig));
    pitchEnv = EnvGen.ar(Env([freq * 1.5, freq], [0.1], -4), K2A.ar(t_trig));
    sig = SinOsc.ar(pitchEnv) * env;
    sig = sig + (LFTri.ar(pitchEnv * 0.5) * 0.3 * env);
    sig = LPF.ar(sig, 200);
    Pan2.ar(sig * amp, 0);
}).play;

// ─── EFFECTS ───────────────────────────────────────────────────────

// Saturation and cavernous reverb on the chains
Ndef(\chainClank)[10] = \filter -> { |in| (in * 2.5).tanh };
Ndef(\chainClank).set(\wet10, 0.6);
Ndef(\chainClank)[11] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.3) };
Ndef(\chainClank).set(\wet11, 0.3);

// Short slapback delay on the whip cracks
Ndef(\whipCrack)[10] = \filter -> { |in| CombC.ar(in, 0.2, 0.15, 1.5) };
Ndef(\whipCrack).set(\wet10, 0.4);

// Vast, cold reverb on the groans
Ndef(\groanWind)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.95, 0.5) };
Ndef(\groanWind).set(\wet10, 0.5);

// Slight distortion on the drum to evoke horror
Ndef(\desperateDrum)[10] = \filter -> { |in| (in * 2.0).tanh };
Ndef(\desperateDrum).set(\wet10, 0.3);

// ─── SEQUENCES ─────────────────────────────────────────────────────

Pbindef(\chainSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.25, 0.125, 0.125, 0.5], inf),
    \t_trig, 1,
    \amp, Pseq([0.3, 0.5, 0.4, 0.6, 0.3, 0.2, 0.5], inf),
    \baseFreq, Pseq([800, 950, 1100, 750, 600, 850, 1000], inf),
    \decay, Pseq([0.2, 0.3, 0.15, 0.4, 0.25, 0.1, 0.3], inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);
Ndef(\chainClank)[1] = \set -> Pbindef(\chainSeq);

Pbindef(\whipSeq,
    \dur, Pseq([1, 0.5, 1.5, 0.75, 2, 0.25, 1.25], inf),
    \t_trig, 1,
    \amp, Pwhite(0.4, 0.9, inf),
    \cut, Pwhite(3000, 6000, inf),
    \pan, Pwhite(-0.5, 0.5, inf)
);
Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);

Pbindef(\groanSeq,
    \dur, 6,
    \baseFreq, Pseq([70, 85, 65, 90, 75, 60], inf),
    \amp, Pseq([0.2, 0.35, 0.25, 0.3, 0.4, 0.2], inf),
    \moanRate, Pseq([0.1, 0.15, 0.08, 0.12], inf)
);
Ndef(\groanWind)[1] = \set -> Pbindef(\groanSeq);

Pbindef(\prayerSeq,
    \dur, 10,
    \baseFreq, Pseq([440, 392, 349.23, 415.30, 466.16, 440], inf),
    \amp, Pseq([0.15, 0.2, 0.18, 0.22, 0.16, 0.2], inf)
);
Ndef(\desperatePrayer)[1] = \set -> Pbindef(\prayerSeq);

Pbindef(\drumSeq,
    \dur, Pseq([0.75, 0.25, 0.5, 0.25, 0.75, 0.5], inf),
    \t_trig, 1,
    \amp, Pseq([0.5, 0.3, 0.6, 0.4, 0.7, 0.5], inf),
    \freq, Pseq([60, 55, 65, 58, 62, 57], inf),
    \decay, Pseq([0.8, 0.5, 1.0, 0.6, 0.9, 0.7], inf)
);
Ndef(\desperateDrum)[1] = \set -> Pbindef(\drumSeq);

// ─── TWEAK EXISTING: intensify the Antarctic weight into the storm ──
Ndef(\antarcticWeight).xset(\amp, 0.25, \modRate, 0.15);
// Ndef(\antarcticWeight).xset(\amp, 0.12, \modRate, 0.07); // Revert storm intensification

// ─── ROLLBACK FOR NEW INSTRUMENTS ────────────────────────────────
// Pbindef(\chainSeq).stop; Ndef(\chainClank).fadeTime = 2; Ndef(\chainClank).clear(2); // Rollback: remove this instrument
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2); // Rollback: remove this instrument
// Pbindef(\groanSeq).stop; Ndef(\groanWind).fadeTime = 2; Ndef(\groanWind).clear(2); // Rollback: remove this instrument
// Pbindef(\prayerSeq).stop; Ndef(\desperatePrayer).fadeTime = 2; Ndef(\desperatePrayer).clear(2); // Rollback: remove this instrument
// Pbindef(\drumSeq).stop; Ndef(\desperateDrum).fadeTime = 2; Ndef(\desperateDrum).clear(2); // Rollback: remove this instrument
// Ndef(\stormSurge).fadeTime = 2; Ndef(\stormSurge).clear(2); // Rollback: remove this instrument
// Ndef(\chainClank).set(\wet10, 0, \wet11, 0); // Rollback: disable effects
// Ndef(\whipCrack).set(\wet10, 0); // Rollback: disable effect
// Ndef(\groanWind).set(\wet10, 0); // Rollback: disable effect
// Ndef(\desperateDrum).set(\wet10, 0); // Rollback: disable effect

)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var totalDur = 130;

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

    // ── Discrete SynthDefs ──
    SynthDef(\brassTick, { |out=0, amp=0.3, pan=0, freq=2400, decay=0.08|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0005, decay, 1, -6), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.3) * env;
        sig = sig + ((SinOsc.ar(freq * [1, 1.51, 2.03]) * env * 0.2).sum);
        sig = sig + (SinOsc.ar(freq * 0.5) * env * 0.15);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\carillonBell, { |out=0, amp=0.4, pan=0, freq=440, decay=4.0|
        var exc, sig, env;
        env = EnvGen.ar(Env.perc(0.005, decay, 1, -4), doneAction: 2);
        exc = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02)));
        sig = DynKlank.ar(`[
            freq * [1, 2.01, 2.76, 4.07, 5.43, 6.78, 8.21],
            [1, 0.6, 0.45, 0.3, 0.22, 0.15, 0.1],
            [decay, decay*0.8, decay*0.65, decay*0.5, decay*0.4, decay*0.3, decay*0.25]
        ], exc);
        sig = sig * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pendulumStrike, { |out=0, amp=0.25, pan=0, freq=180, decay=0.6|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
        sig = (SinOsc.ar(freq * [1, 2.4, 3.7]) * [1, 0.4, 0.2]).sum * env;
        sig = sig + (BPF.ar(WhiteNoise.ar, freq*4, 0.5) * env * 0.3);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\gearGrind, { |out=0, amp=0.2, pan=0, rate=1|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.01, 0.15, 1, -3), doneAction: 2);
        sig = Latch.ar(WhiteNoise.ar, Impulse.ar(rate * 3000));
        sig = BPF.ar(sig, 1200, 0.4) * 3.0 * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // ── Continuous Ndefs ──
    Ndef(\tickSwarm, { |amp=0, density=8, spread=1|
        var trigs, sig, freqs;
        trigs = Dust.ar(density * [1, 1.007, 0.993, 1.013]);
        freqs = TExpRand.ar(1800, 4200, trigs);
        sig = BPF.ar(WhiteNoise.ar, freqs, 0.2) * Decay2.ar(trigs, 0.0005, 0.02);
        Splay.ar(sig, spread) * amp;
    });

    Ndef(\pendulumDrone, { |amp=0, swayRate=0.3, baseFreq=55|
        var lfo, sig;
        lfo = SinOsc.kr(swayRate * [1, 1.02, 0.98]);
        sig = SinOsc.ar(baseFreq * [1, 1.5, 2.01]) * lfo.range(0.2, 1);
        sig = LPF.ar(sig.sum, 400);
        sig = sig + (SinOsc.ar(baseFreq * 2) * 0.3);
        Pan2.ar(sig * amp, SinOsc.kr(swayRate * 0.5));
    });

    Ndef(\clockmakerBreath, { |amp=0, breathRate=0.12|
        var env, sig;
        env = LFNoise2.kr(breathRate).range(0.3, 1.0);
        sig = PinkNoise.ar(0.3) * env;
        sig = BPF.ar(sig, 500, 0.6) * 4.0;
        sig = sig + ((SinOsc.ar([110, 110.3, 165]) * 0.15 * env).sum);
        sig = LPF.ar(sig, 2000);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\tickSwarm, 2) + Ndef.ar(\pendulumDrone, 2) + Ndef.ar(\clockmakerBreath, 2);
        synths + cont;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25);
    };
    Ndef(\masterMix).set(\wet10, 0.2);

    Ndef(\masterMix)[11] = \filter -> { |in|
        var dly = CombC.ar(in, 0.5, [0.19, 0.23], 2.5);
        in + (dly * 0.3);
    };
    Ndef(\masterMix).set(\wet11, 0.15);

    Ndef(\masterMix).play;
    s.sync;

    // ── Chronological Score ──
    Tdef(\masterScore, {
        "0:00 - [Cue 1: A Oficina Estreita]".postln;
        Ndef(\tickSwarm).fadeTime = 6;
        Ndef(\tickSwarm).xset(\amp, 0.35, \density, 6);
        Ndef(\pendulumDrone).fadeTime = 8;
        Ndef(\pendulumDrone).xset(\amp, 0.15);

        6.do { |i|
            if (0.7.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(1800, 3600),
                    \amp, rrand(0.15, 0.35), \pan, rrand(-0.7, 0.7), \decay, rrand(0.04, 0.12)]);
            };
            if (0.4.coin) {
                Synth(\gearGrind, [\out, ~synthBus, \rate, rrand(0.8, 1.4),
                    \amp, rrand(0.06, 0.14), \pan, rrand(-0.5, 0.5)]);
            };
            4.wait;
        };

        "0:24 - [Cue 2: Duzentos Pendulos Desencontrados]".postln;
        Ndef(\tickSwarm).xset(\density, 18, \spread, 1.0);
        Ndef(\pendulumDrone).xset(\amp, 0.28, \swayRate, 0.4);

        13.do { |i|
            Synth(\pendulumStrike, [\out, ~synthBus,
                \freq, [120, 150, 180, 210, 240].choose,
                \amp, rrand(0.12, 0.25), \pan, rrand(-0.8, 0.8),
                \decay, rrand(0.4, 0.9)]);
            if (0.3.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(2000, 4000),
                    \amp, rrand(0.1, 0.25), \pan, rrand(-0.7, 0.7)]);
            };
            2.wait;
        };

        "0:50 - [Cue 3: Carrilhoes Franceses]".postln;
        Ndef(\tickSwarm).xset(\amp, 0.2);
        Ndef(\masterMix).set(\wet10, 0.45);

        10.do { |i|
            var notes = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50];
            Synth(\carillonBell, [\out, ~synthBus,
                \freq, notes.wrapAt(i + [0, 2, 4].choose),
                \amp, rrand(0.15, 0.3), \pan, rrand(-0.6, 0.6),
                \decay, rrand(3.0, 6.0)]);
            if (0.5.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(2400, 4800),
                    \amp, rrand(0.08, 0.18), \pan, rrand(-0.6, 0.6)]);
            };
            3.wait;
        };

        "1:20 - [Cue 4: O Respirar do Tempo]".postln;
        Ndef(\clockmakerBreath).fadeTime = 10;
        Ndef(\clockmakerBreath).xset(\amp, 0.4, \breathRate, 0.1);
        Ndef(\tickSwarm).fadeTime = 8;
        Ndef(\tickSwarm).xset(\amp, 0.08, \density, 4);
        Ndef(\pendulumDrone).xset(\amp, 0.35, \swayRate, 0.15, \baseFreq, 48);
        Ndef(\masterMix).set(\wet10, 0.6, \wet11, 0.25);

        5.do { |i|
            Ndef(\clockmakerBreath).xset(\breathRate, 0.08 + (i * 0.02));
            Synth(\pendulumStrike, [\out, ~synthBus,
                \freq, rrand(80, 130), \amp, rrand(0.1, 0.2),
                \pan, rrand(-0.5, 0.5), \decay, rrand(1.5, 3.0)]);
            5.wait;
        };

        "1:45 - [Cue 5: O Tique-Taque Retorna]".postln;
        Ndef(\clockmakerBreath).fadeTime = 6;
        Ndef(\clockmakerBreath).xset(\amp, 0.12);
        Ndef(\tickSwarm).fadeTime = 4;
        Ndef(\tickSwarm).xset(\amp, 0.32, \density, 10);
        Ndef(\pendulumDrone).xset(\amp, 0.18);
        Ndef(\masterMix).set(\wet10, 0.3, \wet11, 0.12);

        9.do { |i|
            if (0.6.coin) {
                Synth(\brassTick, [\out, ~synthBus, \freq, rrand(1800, 3600),
                    \amp, rrand(0.12, 0.28), \pan, rrand(-0.7, 0.7)]);
            };
            2.wait;
        };

        "2:03 - [Cue 6: Silencio das Engrenagens]".postln;
        Ndef(\tickSwarm).fadeTime = 6;
        Ndef(\tickSwarm).xset(\amp, 0);
        Ndef(\pendulumDrone).fadeTime = 6;
        Ndef(\pendulumDrone).xset(\amp, 0);
        Ndef(\clockmakerBreath).fadeTime = 6;
        Ndef(\clockmakerBreath).xset(\amp, 0);
        Ndef(\masterMix).set(\wet10, 0, \wet11, 0);

        5.wait;

        Ndef(\tickSwarm).clear(3);
        Ndef(\pendulumDrone).clear(3);
        Ndef(\clockmakerBreath).clear(3);
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 04 | MODE: COMPOSE | FRAG #13
// STATUS: FALLBACK
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)

