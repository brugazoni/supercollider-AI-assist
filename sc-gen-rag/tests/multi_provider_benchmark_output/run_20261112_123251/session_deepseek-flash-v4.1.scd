// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-12T15:42:04.971580+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ============================================================
// BLOCK 1: "Vinte e sete anos" — the frozen restaurant moment
// Deep sub-drones (the marriage), suspended glass (the bottle),
// dry map-fold articulations, an Antarctic breath held back.
// ============================================================

// --- ADD_INSTRUMENT: coldDrone (the 27 quiet years) ---
Ndef(\coldDrone, {
    var freq = 55;
    var osc = Mix([
        SinOsc.ar(freq, 0, 0.5),
        SinOsc.ar(freq * 1.005, 0, 0.4),
        SinOsc.ar(freq * 2, 0, 0.14)
    ]);
    var sub  = SinOsc.ar(freq / 2, 0, 0.3);
    var lfo  = LFTri.kr(0.07).range(0.2, 0.45);
    var sig  = (osc + sub) * lfo;
    var filt = LPF.ar(sig, 420);
    Pan2.ar(filt, 0, 0.5);
}).play;
// Pbindef(\coldDroneSeq).stop; Ndef(\coldDrone).fadeTime = 2; Ndef(\coldDrone).clear(2); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: wineGlass (bottle suspended, immobile) ---
Ndef(\wineGlass, { |freq=3200, amp=0.15, rel=4, t_trig=0|
    var env      = EnvGen.ar(Env.perc(0.02, rel, 1, -6), t_trig);
    var partials = [1, 2.73, 5.4, 8.9, 13.2];
    var sig      = Mix(partials.collect({ |m, i|
        SinOsc.ar(freq * m, 0, 1 / (i + 1))
    }));
    var pan = SinOsc.kr(0.05).range(-0.55, 0.55);
    Pan2.ar(sig * env * amp, pan);
}).play;
// Pbindef(\glassSeq).stop; Ndef(\wineGlass).fadeTime = 2; Ndef(\wineGlass).clear(2); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: mapFold (procedural, obsessive folds) ---
Ndef(\mapFold, { |amp=0.3, freq=1800, q=0.15, t_trig=0|
    var env    = EnvGen.ar(Env.perc(0.001, 0.06, 1, -12), t_trig);
    var noise  = WhiteNoise.ar();
    var filt   = BPF.ar(noise, freq, q) * 12;
    var crunch = Clip.ar(filt * 2, -0.95, 0.95);
    Pan2.ar(crunch * env * amp, 0);
}).play;
// Pbindef(\foldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: antarcticWind (storm waiting in the wings) ---
Ndef(\antarcticWind, { |amp=0.0, cutoff=600, rq=0.9|
    var wind = BrownNoise.ar();
    var lfo  = LFNoise1.kr(0.3).range(300, 1100);
    var filt = RLPF.ar(wind, cutoff + lfo, rq);
    var pan  = LFNoise1.kr(0.12).range(-0.9, 0.9);
    Pan2.ar(filt * amp, pan);
}).play;
// Pbindef(\windSeq).stop; Ndef(\antarcticWind).fadeTime = 2; Ndef(\antarcticWind).clear(2); // Rollback: remove this instrument

// --- ADD_EFFECTS: cold hall reverb on the marriage drone ---
Ndef(\coldDrone)[10] = \filter -> { |in|
    var wet = LPF.ar(DelayC.ar(in, 0.4, [0.37, 0.43], 0.6), 1800); // LPFC -> LPF (vanilla UGen)
    wet;
};
Ndef(\coldDrone).set(\wet10, 0.35);
// Ndef(\coldDrone).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: shimmer delay on the suspended glass ---
Ndef(\wineGlass)[10] = \filter -> { |in|
    var d1 = DelayC.ar(in, 0.6, 0.29, 0.55);
    var d2 = DelayC.ar(in, 0.6, 0.41, 0.45);
    (in * 0.4) + (d1 + d2) * 0.6;
};
Ndef(\wineGlass).set(\wet10, 0.4);
// Ndef(\wineGlass).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: low-lit room on the map-fold clicks ---
Ndef(\mapFold)[10] = \filter -> { |in|
    var wet = RLPF.ar(HPF.ar(in, 400), 4000, 0.7);
    wet;
};
Ndef(\mapFold).set(\wet10, 0.25);
// Ndef(\mapFold).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: HPF + resonant veil on the held-back storm ---
Ndef(\antarcticWind)[10] = \filter -> { |in|
    var wet = RHPF.ar(BPF.ar(in, 800, 1.4) * 6.0, 200);
    wet;
};
Ndef(\antarcticWind).set(\wet10, 0.6);
// Ndef(\antarcticWind).set(\wet10, 0); // Rollback: disable this effect

// ============================================================
// SEQUENCES
// ============================================================

// The bottle glints at wide, irregular intervals
Pbindef(\glassSeq,
    \dur,   Pseq([3.5, 7.0, 5.2, 11.0], inf),
    \freq,  Pseq([3200, 2800, 3400, 2600], inf),
    \amp,   Pseq([0.12, 0.08, 0.15, 0.06], inf),
    \rel,   Pseq([6, 8, 5, 10], inf),
    \t_trig, 1
);
Ndef(\wineGlass)[1] = \set -> Pbindef(\glassSeq);

// The obsessive, procedural folding gesture
Pbindef(\foldSeq,
    \dur,   Pseq([0.5, 0.25, 0.25, 0.75, 1.0, 0.25], inf),
    \freq,  Pseq([1200, 1800, 2400, 900, 1600], inf),
    \q,     Pseq([0.1, 0.2, 0.15, 0.08], inf),
    \amp,   Pseq([0.25, 0.35, 0.15, 0.4, 0.2], inf),
    \t_trig, 1
);
Ndef(\mapFold)[1] = \set -> Pbindef(\foldSeq);

// The storm does not yet arrive — it only breathes on the horizon
Pbindef(\windSeq,
    \dur,   Pseq([8.0, 11.0, 9.0], inf),
    \amp,   Pseq([0.0, 0.0, 0.02, 0.0], inf),
    \cutoff, Pseq([500, 700, 600, 900], inf),
    \t_trig, 1
);
Ndef(\antarcticWind)[1] = \set -> Pbindef(\windSeq);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ============================================================
// BLOCK 2: "Era um sonho dantesco..." — Castro Alves, O Navio Negreiro
// The slave ship hold: clanking irons, whip cracks, groaning men,
// salt air, and lanterns reddening the deck with blood.
// ============================================================

// --- ADD_INSTRUMENT: chainRattle (tinir de ferros — clanking irons) ---
Ndef(\chainRattle, { |amp=0.35, freq=2200, q=0.05, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.001, 0.08, 1, -14), t_trig);
    var noise = WhiteNoise.ar();
    var metal = Mix([
        BPF.ar(noise, freq, q) * 15,
        BPF.ar(noise, freq * 1.7, q) * 10,
        BPF.ar(noise, freq * 2.9, q) * 6
    ]);
    var crunched = Fold.ar(metal * 2.2, -0.9, 0.9);
    Pan2.ar(crunched * env * amp, LFNoise1.kr(8).range(-0.7, 0.7));
}).play;
// Pbindef(\chainSeq).stop; Ndef(\chainRattle).fadeTime = 2; Ndef(\chainRattle).clear(2); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: whipCrack (estalar de açoite) ---
Ndef(\whipCrack, { |amp=0.5, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.0005, 0.15, 1, -18), t_trig);
    var noise = WhiteNoise.ar();
    var body = BPF.ar(noise, 3500, 0.6) * 8;
    var crack = HPF.ar(noise, 4000) * env;
    var thudEnv = EnvGen.ar(Env.perc(0.001, 0.06), t_trig);
    var thud = SinOsc.ar(80) * thudEnv * 0.6;
    Pan2.ar((body * env) + thud + (crack * 0.3), LFNoise0.kr(5).range(-0.5, 0.5));
}).play;
// Pbindef(\whipSeq).stop; Ndef(\whipCrack).fadeTime = 2; Ndef(\whipCrack).clear(2); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: groanChoir (homens gemendo sob a aragem salgada) ---
Ndef(\groanChoir, { |amp=0.28, cutoff=380, rq=0.4|
    var fundamental = 62;
    var voices = Mix([
        Saw.ar(fundamental * 0.5, 0.3),
        Saw.ar(fundamental * 0.503, 0.25),
        Saw.ar(fundamental * 0.751, 0.2),
        Saw.ar(fundamental * 1.0, 0.15)
    ]);
    var formant1 = BPF.ar(voices, 320, 0.5) * 3;
    var formant2 = BPF.ar(voices, 800, 0.7) * 2;
    var moan = formant1 + formant2;
    var lfo = LFNoise1.kr(0.4).range(0.3, 0.7);
    var breathe = LFNoise2.kr(0.15).range(0.4, 1.0);
    var sig = LPF.ar(moan, cutoff) * lfo * breathe;
    Pan2.ar(sig * amp, SinOsc.kr(0.09).range(-0.3, 0.3));
}).play;
// Pbindef(\groanSeq).stop; Ndef(\groanChoir).fadeTime = 4; Ndef(\groanChoir).clear(4); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: saltBreeze (aragem salgada — the sea held in the hold) ---
Ndef(\saltBreeze, { |amp=0.2, cutoff=1200|
    var wind = BrownNoise.ar();
    var salt = BPF.ar(PinkNoise.ar(), 2500, 0.9) * 3;
    var combined = (wind * 0.7) + (salt * 0.3);
    var filt = RLPF.ar(combined, cutoff + LFNoise1.kr(0.2).range(300, 900), 0.6);
    var pan = LFNoise1.kr(0.1).range(-0.95, 0.95);
    Pan2.ar(filt * amp, pan);
}).play;
// Pbindef(\breezeSeq).stop; Ndef(\saltBreeze).fadeTime = 3; Ndef(\saltBreeze).clear(3); // Rollback: remove this instrument

// --- ADD_INSTRUMENT: lanternGlow (luzernas avermelha o brilho) ---
Ndef(\lanternGlow, { |freq=440, amp=0.18, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.5, 6, 1, -2), t_trig);
    var partials = [1, 1.5, 2.33, 3.66, 5.1];
    var sig = Mix(partials.collect({ |m, i|
        SinOsc.ar(freq * m, 0, 1 / (i + 1).squared)
    }));
    var lfo = LFNoise1.kr(0.5).range(0.5, 1.0);
    var filtered = LPF.ar(sig, 1800);
    Pan2.ar(filtered * env * amp * lfo, 0);
}).play;
// Pbindef(\lanternSeq).stop; Ndef(\lanternGlow).fadeTime = 4; Ndef(\lanternGlow).clear(4); // Rollback: remove this instrument

// --- ADD_EFFECTS: harsh distortion on the chains (metal biting itself) ---
Ndef(\chainRattle)[10] = \filter -> { |in|
    var driven = (in * 5).tanh * 0.6;
    var eq = HPF.ar(driven, 800);
    eq;
};
Ndef(\chainRattle).set(\wet10, 0.55);
// Ndef(\chainRattle).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: cavernous hold reverb on the groaning choir ---
Ndef(\groanChoir)[10] = \filter -> { |in|
    var pre = DelayC.ar(in, 0.1, 0.08);
    var d1 = CombC.ar(pre, 1.2, 0.87, 4.5);
    var d2 = CombC.ar(pre, 1.4, 1.13, 5.2);
    var d3 = CombC.ar(pre, 1.6, 1.41, 6.0);
    (in * 0.3) + ((d1 + d2 + d3) * 0.25);
};
Ndef(\groanChoir).set(\wet10, 0.65);
// Ndef(\groanChoir).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: spectral shimmer on the blood-red lanterns ---
Ndef(\lanternGlow)[10] = \filter -> { |in|
    var shifted = FreqShift.ar(in, 3.5);
    var d1 = DelayC.ar(shifted, 0.8, 0.33, 0.5);
    (in * 0.5) + (d1 * 0.5);
};
Ndef(\lanternGlow).set(\wet10, 0.5);
// Ndef(\lanternGlow).set(\wet10, 0); // Rollback: disable this effect

// --- ADD_EFFECTS: resonant veil on the salt breeze ---
Ndef(\saltBreeze)[10] = \filter -> { |in|
    var wet = RHPF.ar(BPF.ar(in, 600, 1.2) * 5, 180);
    wet;
};
Ndef(\saltBreeze).set(\wet10, 0.4);
// Ndef(\saltBreeze).set(\wet10, 0); // Rollback: disable this effect

// ============================================================
// SEQUENCES
// ============================================================

// The chains: irregular, obsessive, endless clanking
Pbindef(\chainSeq,
    \dur,   Pseq([0.12, 0.08, 0.25, 0.4, 0.15, 0.09, 0.33, 0.5], inf),
    \freq,  Pseq([1800, 2400, 2200, 1600, 2800, 1900, 2100, 2500], inf),
    \q,     Pwhite(0.03, 0.08, inf),
    \amp,   Pwhite(0.15, 0.45, inf),
    \t_trig, 1
);
Ndef(\chainRattle)[1] = \set -> Pbindef(\chainSeq);

// The whip: sparse, violent, unannounced
Pbindef(\whipSeq,
    \dur,   Pseq([2.5, 0.3, 4.0, 0.25, 3.5, 0.2], inf),
    \amp,   Pseq([0.5, 0.3, 0.55, 0.35, 0.4, 0.25], inf),
    \t_trig, 1
);
Ndef(\whipCrack)[1] = \set -> Pbindef(\whipSeq);

// The groaning men — slow, rising and falling like a tide of pain
Pbindef(\groanSeq,
    \dur,   Pseq([8, 10, 6, 12], inf),
    \cutoff, Pseq([280, 350, 400, 320], inf),
    \amp,   Pseq([0.22, 0.3, 0.18, 0.28], inf),
    \t_trig, 1
);
Ndef(\groanChoir)[1] = \set -> Pbindef(\groanSeq);

// The salty air — inhale, exhale, inhale
Pbindef(\breezeSeq,
    \dur,   Pseq([6, 8, 5, 9], inf),
    \cutoff, Pseq([900, 1400, 1100, 700], inf),
    \amp,   Pseq([0.15, 0.25, 0.18, 0.12], inf),
    \t_trig, 1
);
Ndef(\saltBreeze)[1] = \set -> Pbindef(\breezeSeq);

// The lanterns — the deck turning red, one slow glint at a time
Pbindef(\lanternSeq,
    \dur,   Pseq([7, 5, 9, 6, 11], inf),
    \freq,  Pseq([330, 415, 293, 370, 246], inf),
    \amp,   Pseq([0.15, 0.2, 0.12, 0.18, 0.1], inf),
    \t_trig, 1
);
Ndef(\lanternGlow)[1] = \set -> Pbindef(\lanternSeq);
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
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

s.waitForBoot({

    // --- Clock tick: brass escapement click ---
    SynthDef(\tickClock, {
        |out=0, freq=2000, amp=0.3, pan=0, decay=0.08|
        var env = EnvGen.ar(Env.perc(0.0005, decay, 1, -6), doneAction: 2);
        var click = Impulse.ar(0) + (WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(0.0001, 0.004)));
        var res = Ringz.ar(click, freq, decay * 3, 0.8);
        var body = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.0005, decay * 2, 0.3, -4));
        var sig = (res + body) * env * amp;
        Pan2.ar(sig, pan);
    }).add;

    // --- Carillon bell: metallic FM ---
    SynthDef(\carillon, {
        |out=0, freq=440, amp=0.3, pan=0, decay=3.0|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);
        var mod = SinOsc.ar(freq * 2.76) * freq * 1.5 * EnvGen.ar(Env.perc(0.001, 0.3));
        var car = SinOsc.ar(freq + mod);
        var mod2 = SinOsc.ar(freq * 1.41) * freq * 0.8;
        var car2 = SinOsc.ar(freq * 2.01 + mod2);
        var sig = (car + (car2 * 0.6)) * env * amp;
        sig = LPF.ar(sig, 6000);
        Pan2.ar(sig, pan);
    }).add;

    // --- Gear scrape: brass teeth grinding ---
    SynthDef(\gearScrape, {
        |out=0, freq=1200, amp=0.2, pan=0, edur=0.15|
        var env = EnvGen.ar(Env.perc(0.005, edur, 1, -3), doneAction: 2);
        var noise = WhiteNoise.ar;
        var src = BPF.ar(noise, freq, 0.15) * 12;
        var grind = LFPulse.ar(freq * 0.05) * 0.5 + 0.5;
        var sig = src * grind * env * amp;
        Pan2.ar(sig, pan);
    }).add;

    // --- Pendulum wooden thunk ---
    SynthDef(\pendulumWood, {
        |out=0, freq=120, amp=0.4, pan=0, decay=0.6|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
        var click = Impulse.ar(0);
        var res = DynKlank.ar(`[
            [freq, freq*1.8, freq*2.7, freq*4.1],
            [1, 0.6, 0.3, 0.15],
            [0.4, 0.3, 0.2, 0.15]
        ], click, 1, 0, decay);
        var sig = res * env * amp;
        Pan2.ar(sig, pan);
    }).add;
    s.sync;

    // --- Continuous: breathing of time (beating drone) ---
    Ndef(\timeBreath, {
        |amp=0, cutoff=800|
        var base = 55;
        var detunes = [0, 0.03, -0.05, 0.07, -0.02];
        var sig = Mix(detunes.collect({ |d, i|
            SinOsc.ar(base * (1 + d) * (1 + LFNoise1.kr(0.05).range(-0.001, 0.001)), 0, 0.4 / (i+1))
        }));
        var sub = SinOsc.ar(base * 0.5, 0, 0.3);
        var breath = LFNoise1.kr(0.15).range(0.3, 1.0);
        var filt = LPF.ar(sig + sub, cutoff);
        Pan2.ar(filt * amp * breath, LFNoise1.kr(0.08).range(-0.6, 0.6));
    });

    // --- Continuous: brass hum of the workshop ---
    Ndef(\brassHum, {
        |amp=0, cutoff=2000|
        var sig = Mix([
            SinOsc.ar(220, 0, 0.3),
            SinOsc.ar(330, 0, 0.2),
            SinOsc.ar(440, 0, 0.15),
            SinOsc.ar(660, 0, 0.1)
        ]);
        var wobble = SinOsc.kr(0.3).range(0.95, 1.05);
        var filt = RLPF.ar(sig, cutoff * wobble, 0.4);
        var noise = BPF.ar(PinkNoise.ar, 3000, 0.5) * 0.5;
        Pan2.ar((filt + noise) * amp, 0);
    });

    // --- Master mix ---
    Ndef(\masterMix, {
        var sig = In.ar(~synthBus, 2);
        sig = sig + Ndef.ar(\timeBreath, 2);
        sig = sig + Ndef.ar(\brassHum, 2);
        sig;
    }).play;

    Ndef(\masterMix)[10] = \filter -> { |in|
        var d1 = CombC.ar(in, 1.5, 0.83, 3.5);
        var d2 = CombC.ar(in, 1.7, 1.21, 4.2);
        var d3 = AllpassC.ar(in, 0.5, 0.37, 2.0);
        (d1 + d2 + d3) * 0.4;
    };
    Ndef(\masterMix).set(\wet10, 0.3);
    s.sync;

    // --- Sequences ---
    Pbindef(\clockTickSeq,
        \instrument, \tickClock, \out, ~synthBus,
        \dur, Pwhite(0.48, 0.52, inf),
        \freq, Pwhite(1800, 2600, inf),
        \amp, Pwhite(0.08, 0.18, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \decay, Pwhite(0.05, 0.12, inf)
    );

    Pbindef(\clockTickSeq2,
        \instrument, \tickClock, \out, ~synthBus,
        \dur, Pwhite(0.49, 0.53, inf),
        \freq, Pwhite(1500, 2200, inf),
        \amp, Pwhite(0.06, 0.14, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \decay, Pwhite(0.06, 0.14, inf)
    );

    Pbindef(\pocketTickSeq,
        \instrument, \tickClock, \out, ~synthBus,
        \dur, Pwhite(0.24, 0.27, inf),
        \freq, Pwhite(3200, 4200, inf),
        \amp, Pwhite(0.03, 0.08, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \decay, Pwhite(0.02, 0.05, inf)
    );

    Pbindef(\carillonSeq,
        \instrument, \carillon, \out, ~synthBus,
        \dur, Pseq([4, 6, 5, 7, 3], inf),
        \freq, Pseq([523, 587, 659, 698, 784], inf),
        \amp, Pseq([0.15, 0.12, 0.18, 0.1, 0.14], inf),
        \pan, Pwhite(-0.6, 0.6, inf),
        \decay, Pwhite(2.5, 4.5, inf)
    );

    Pbindef(\gearSeq,
        \instrument, \gearScrape, \out, ~synthBus,
        \dur, Pseq([0.8, 1.2, 0.5, 2.0, 0.7], inf),
        \freq, Pwhite(800, 2400, inf),
        \amp, Pwhite(0.05, 0.15, inf),
        \pan, Pwhite(-0.9, 0.9, inf),
        \edur, Pwhite(0.08, 0.2, inf)
    );

    Pbindef(\woodSeq,
        \instrument, \pendulumWood, \out, ~synthBus,
        \dur, Pseq([1.0, 1.0, 1.0, 1.0], inf),
        \freq, Pseq([110, 130, 98, 120], inf),
        \amp, Pwhite(0.15, 0.3, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \decay, Pwhite(0.4, 0.8, inf)
    );

    s.sync;

    // --- MASTER SCORE ---
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Um relogio solitario acorda na oficina]".postln;
        Ndef(\brassHum).fadeTime = 5;
        Ndef(\brassHum).xset(\amp, 0.10, \cutoff, 1200);
        Ndef(\timeBreath).fadeTime = 6;
        Ndef(\timeBreath).xset(\amp, 0.05, \cutoff, 500);
        Pbindef(\clockTickSeq).play;
        15.do { |k|
            Ndef(\brassHum).xset(\cutoff, exprand(1000, 2200));
            Ndef(\timeBreath).xset(\amp, 0.05 + (k * 0.004));
            1.wait;
        };

        "0:15 - [Cue 2: Mais relogios, defasagens microscopicas]".postln;
        Pbindef(\clockTickSeq2).play;
        Pbindef(\pocketTickSeq).play;
        Pbindef(\woodSeq).play;
        20.do { |k|
            Ndef(\brassHum).xset(\cutoff, exprand(1200, 2800));
            Ndef(\timeBreath).xset(\cutoff, 500 + (k * 30));
            if (k % 5 == 0) { Ndef(\masterMix).set(\wet10, 0.3 + (k * 0.005)); };
            1.wait;
        };

        "0:35 - [Cue 3: Carrilhoes franceses entram]".postln;
        Pbindef(\carillonSeq).play;
        20.do { |k|
            Ndef(\brassHum).xset(\cutoff, exprand(1500, 3200));
            1.wait;
        };

        "0:55 - [Cue 4: Engrenagens rangem, o enxame se adensa]".postln;
        Pbindef(\gearSeq).play;
        20.do { |k|
            Ndef(\timeBreath).xset(\cutoff, 700 + (k * 40));
            Ndef(\brassHum).xset(\amp, 0.10 + (k * 0.003));
            1.wait;
        };

        "1:15 - [Cue 5: Settling - o respirar do tempo exposto]".postln;
        Pbindef(\pocketTickSeq).stop;
        Pbindef(\gearSeq).stop;
        Pbindef(\carillonSeq).stop;
        Ndef(\masterMix).set(\wet10, 0.5);
        15.do { |k|
            Ndef(\timeBreath).xset(\amp, 0.15 + (k * 0.005), \cutoff, exprand(400, 900));
            1.wait;
        };

        "1:30 - [Cue 6: Flashback - um carrilhao solitario]".postln;
        Pbindef(\clockTickSeq2).stop;
        Pbindef(\woodSeq).stop;
        Pbindef(\carillonSeq).play;
        12.do { |k|
            Ndef(\timeBreath).xset(\cutoff, exprand(300, 700));
            1.wait;
        };

        "1:42 - [Cue 7: Resolucao - o respirar do tempo]".postln;
        Pbindef(\clockTickSeq).stop;
        Pbindef(\carillonSeq).stop;
        Ndef(\brassHum).fadeTime = 5;
        Ndef(\brassHum).xset(\amp, 0);
        Ndef(\masterMix).set(\wet10, 0.65);
        12.do { |k|
            Ndef(\timeBreath).xset(\amp, 0.20 - (k * 0.012));
            1.wait;
        };

        "1:54 - [Fim: o tempo respira sozinho]".postln;
        Ndef(\timeBreath).xset(\amp, 0.02);
        4.wait;

        Pbindef(\clockTickSeq).stop; Pbindef(\clockTickSeq).clear;
        Pbindef(\clockTickSeq2).stop; Pbindef(\clockTickSeq2).clear;
        Pbindef(\pocketTickSeq).stop; Pbindef(\pocketTickSeq).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
        Pbindef(\gearSeq).stop; Pbindef(\gearSeq).clear;
        Pbindef(\woodSeq).stop; Pbindef(\woodSeq).clear;
        Ndef(\timeBreath).clear(3);
        Ndef(\brassHum).clear(3);
        Ndef(\masterMix).clear(3);
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

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // --- Discrete SynthDefs: gotas, estalactites, abóbadas ---
    SynthDef(\waterDrop, {
        var env, exc, freq, sig;
        freq = \freq.kr(400);
        env = EnvGen.ar(Env.perc(0.001, \decay.kr(2.5)), doneAction: 2);
        exc = Impulse.ar(0) + (PinkNoise.ar * 0.08);
        sig = DynKlank.ar(
            Ref([ [freq, freq*1.51, freq*2.31, freq*3.72, freq*5.13],
                  [1, 0.6, 0.4, 0.25, 0.15],
                  [1.5, 1.2, 0.9, 0.7, 0.5] ]),
            exc,
            decayscale: \decay.kr(2.5)
        );
        sig = sig * env * \amp.kr(0.3);
        sig = Pan2.ar(sig, \pan.kr(0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\stalactiteStrike, {
        var exc, freq, sig, env;
        freq = \freq.kr(220);
        env = EnvGen.ar(Env.perc(0.002, \decay.kr(3)), doneAction: 2);
        exc = Impulse.ar(0);
        sig = DynKlank.ar(
            Ref([ [freq, freq*2.76, freq*5.41, freq*8.93],
                  [1, 0.7, 0.45, 0.2],
                  [2.5, 1.8, 1.2, 0.8] ]),
            exc,
            decayscale: \decay.kr(3)
        );
        sig = sig * env * \amp.kr(0.25);
        sig = Pan2.ar(sig, \pan.kr(0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\caveBoom, {
        var sig, env, freq;
        freq = \freq.kr(45);
        env = EnvGen.ar(Env.perc(0.01, \decay.kr(6), 1, -4), doneAction: 2);
        sig = SinOsc.ar(freq) + (SinOsc.ar(freq*2) * 0.4) + (SinOsc.ar(freq*3) * 0.15);
        sig = sig + (LPF.ar(PinkNoise.ar, freq*4) * 0.3);
        sig = (sig * env * \amp.kr(0.3)).tanh;
        sig = Pan2.ar(sig, \pan.kr(0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef(\mineralChime, {
        var sig, env, freq;
        freq = \freq.kr(1200);
        env = EnvGen.ar(Env.perc(0.005, \decay.kr(4)), doneAction: 2);
        sig = Mix.fill(5, { |i|
            SinOsc.ar(freq * (i+1) * (1 + (i*0.003)), 0, 1/(i+1.5))
        });
        sig = sig * env * \amp.kr(0.15);
        sig = Pan2.ar(sig, \pan.kr(0));
        Out.ar(\out.kr(0), sig);
    }).add;

    s.sync;

    // --- Continuous textures: ar da gruta, cortinas minerais, espaço de gotejo ---
    Ndef(\caveAir, {
        var sig, lfo;
        lfo = LFNoise1.kr(0.1).range(0.7, 1.3);
        sig = LPF.ar(PinkNoise.ar(0.4), 200) + LPF.ar(BrownNoise.ar(0.5), 120);
        sig = sig + (SinOsc.ar(38) * 0.3) + (SinOsc.ar(76) * 0.15);
        sig = sig * lfo;
        Balance2.ar(sig, sig, 0, \amp.kr(0));
    });
    Ndef(\caveAir).fadeTime = 6;

    Ndef(\mineralDrone, {
        var sig, freqs;
        freqs = [523.25, 784.99, 1046.5, 1318.5];
        sig = Mix.ar(freqs.collect({ |f, i|
            SinOsc.ar(f * LFNoise1.kr(0.05).range(0.998, 1.002), 0, 1/(i+2))
        }));
        sig = sig * (1 + (SinOsc.kr(0.13) * 0.3));
        Balance2.ar(sig, sig, 0, \amp.kr(0));
    });
    Ndef(\mineralDrone).fadeTime = 8;

    Ndef(\dripSpace, {
        var sig;
        sig = BPF.ar(WhiteNoise.ar(0.1), 800, 0.8) * 0.5;
        sig = sig + (SinOsc.ar(60) * 0.2);
        Balance2.ar(sig, sig, 0, \amp.kr(0));
    });
    Ndef(\dripSpace).fadeTime = 5;

    Ndef(\masterMix, {
        var mix;
        mix = In.ar(~synthBus, 2);
        mix = mix + Ndef.ar(\caveAir, 2);
        mix = mix + Ndef.ar(\mineralDrone, 2);
        mix = mix + Ndef.ar(\dripSpace, 2);
        mix;
    });
    Ndef(\masterMix).fadeTime = 2;
    Ndef(\masterMix)[10] = \filter -> { |in|
        GVerb.ar(in, 90, 12, 0.7, 0.9, 0.6, 0, 0.7, 0.5);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.3);
    };
    Ndef(\masterMix).set(\wet10, 0.0, \wet11, 0.0);
    Ndef(\masterMix).play;
    s.sync;

    // --- Pbindefs ---
    Pbindef(\dropSeq,
        \instrument, \waterDrop, \out, ~synthBus,
        \dur, Pseq([0.8, 1.5, 0.6, 2.2, 1.1, 0.9, 1.7], inf),
        \freq, Pwhite(300, 900, inf),
        \decay, Pwhite(1.8, 3.5, inf),
        \amp, Pwhite(0.15, 0.35, inf),
        \pan, Pwhite(-0.8, 0.8, inf)
    );

    Pbindef(\stalaSeq,
        \instrument, \stalactiteStrike, \out, ~synthBus,
        \dur, Pseq([2.5, 1.8, 3.2, 2.0, 2.8], inf),
        \freq, Pseq([220, 261.6, 196, 293.7, 246.9], inf),
        \decay, Pwhite(2.5, 4.5, inf),
        \amp, Pwhite(0.12, 0.28, inf),
        \pan, Pwhite(-0.7, 0.7, inf)
    );

    Pbindef(\chimeSeq,
        \instrument, \mineralChime, \out, ~synthBus,
        \dur, Pexprand(1.5, 4.0, inf),
        \freq, Pwhite(900, 1800, inf),
        \decay, Pwhite(3.0, 5.5, inf),
        \amp, Pwhite(0.08, 0.18, inf),
        \pan, Pwhite(-0.9, 0.9, inf)
    );

    Pbindef(\boomSeq,
        \instrument, \caveBoom, \out, ~synthBus,
        \dur, Pseq([8, 12, 10, 14], inf),
        \freq, Pseq([38, 45, 42, 50], inf),
        \decay, Pwhite(5, 8, inf),
        \amp, Pwhite(0.2, 0.35, inf),
        \pan, Pwhite(-0.3, 0.3, inf)
    );

    s.sync;

    // --- MASTER SCORE ---
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: Entrada - o ar milenar da gruta desperta]".postln;
        Ndef(\caveAir).xset(\amp, 0.12);
        Pbindef(\dropSeq).play;
        15.do { |k|
            Ndef(\caveAir).xset(\amp, 0.12 + (k * 0.003));
            if (k % 3 == 0) { Ndef(\masterMix).set(\wet10, 0.05 + (k * 0.01)); };
            1.wait;
        };

        "0:15 - [Cue 2: Sete salões - a ressonância calcária se abre]".postln;
        Ndef(\mineralDrone).xset(\amp, 0.08);
        Pbindef(\stalaSeq).play;
        20.do { |k|
            Ndef(\mineralDrone).xset(\amp, 0.08 + (k * 0.002));
            Ndef(\caveAir).xset(\amp, 0.16 + (k * 0.002));
            1.wait;
        };

        "0:35 - [Cue 3: Cortinas minerais cintilam nas abóbadas úmidas]".postln;
        Pbindef(\chimeSeq).play;
        Ndef(\masterMix).set(\wet11, 0.35);
        20.do { |k|
            Ndef(\mineralDrone).xset(\amp, 0.12 + (k * 0.001));
            if (k % 4 == 0) { Ndef(\masterMix).set(\wet10, 0.25 + (k * 0.008)); };
            1.wait;
        };

        "0:55 - [Cue 4: Peter Lund adentra - gotas ecoam no escuro]".postln;
        Pbindef(\boomSeq).play;
        Ndef(\dripSpace).xset(\amp, 0.06);
        20.do { |k|
            Ndef(\dripSpace).xset(\amp, 0.06 + (k * 0.003));
            Ndef(\caveAir).xset(\amp, 0.18 + (k * 0.001));
            1.wait;
        };

        "1:15 - [Cue 5: Settling - apenas o gotejamento lento]".postln;
        Pbindef(\stalaSeq).stop;
        Pbindef(\chimeSeq).stop;
        Pbindef(\boomSeq).stop;
        Ndef(\mineralDrone).xset(\amp, 0.03);
        Ndef(\masterMix).set(\wet10, 0.5);
        15.do { |k|
            Ndef(\dripSpace).xset(\amp, 0.08 + (k * 0.002));
            Ndef(\caveAir).xset(\amp, 0.14 - (k * 0.003));
            1.wait;
        };

        "1:30 - [Cue 6: Ressonância profunda - o coração da gruta]".postln;
        Pbindef(\boomSeq).play;
        Ndef(\mineralDrone).xset(\amp, 0.10);
        15.do { |k|
            Ndef(\caveAir).xset(\amp, 0.16 + (k * 0.003));
            Ndef(\masterMix).set(\wet10, 0.5 + (k * 0.005));
            1.wait;
        };

        "1:45 - [Cue 7: Resolução - retorno ao primeiro gotejar]".postln;
        Pbindef(\boomSeq).stop;
        Ndef(\mineralDrone).xset(\amp, 0.04);
        Ndef(\dripSpace).xset(\amp, 0.05);
        15.do { |k|
            Ndef(\caveAir).xset(\amp, 0.14 - (k * 0.006));
            Ndef(\masterMix).set(\wet10, 0.6 - (k * 0.02));
            1.wait;
        };

        "2:00 - [Fim: o silêncio calcário respira]".postln;
        Ndef(\caveAir).xset(\amp, 0.03);
        Ndef(\mineralDrone).xset(\amp, 0.01);
        6.do { |k|
            Ndef(\dripSpace).xset(\amp, 0.04 - (k * 0.006));
            1.wait;
        };

        Pbindef(\dropSeq).stop; Pbindef(\dropSeq).clear;
        Pbindef(\stalaSeq).stop; Pbindef(\stalaSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Pbindef(\boomSeq).stop; Pbindef(\boomSeq).clear;
        Ndef(\dripSpace).clear(3);
        Ndef(\caveAir).clear(3);
        Ndef(\mineralDrone).clear(3);
        Ndef(\masterMix).clear(3);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

