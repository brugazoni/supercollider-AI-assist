// ============================================================
// MULTI-PROVIDER BENCHMARK: DeepSeek Flash Latest
// Model ID: openrouter:deepseek/deepseek-v4.1-flash
// Date: 2026-11-12T01:58:52.341738+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ============================================================
// "O Mapa Dobrado" — Scene I: The 27-year silence fractures
// ============================================================

// --- THE LONG MARRIAGE: warm, patient analog drone ---
Ndef(\marriagePad, { |freq=110, amp=0.15, cutoff=800, atk=0.05, rel=9, t_trig=1|
    var env, osc, sig;
    env = EnvGen.ar(Env.perc(atk, rel, 1, -3), t_trig);
    osc = Splay.ar(Saw.ar(freq * [0.994, 1.0, 1.006]) + Pulse.ar(freq * 0.5, 0.4, 0.4));
    sig = RLPF.ar(osc, cutoff, 0.55);
    sig = LeakDC.ar(sig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * env) } { Pan2.ar(sig, 0, amp * env) };
}).play;

Ndef(\marriagePad)[10] = \filter -> { |in|
    var sig = in + DelayC.ar(in, 0.05, SinOsc.kr([0.27, 0.31]).range(0.008, 0.019));
    sig;
};
Ndef(\marriagePad).set(\wet10, 0.35);

Ndef(\marriagePad)[11] = \filter -> { |in|
    FreeVerb.ar(in, 0.72, 0.9, 0.4);
};
Ndef(\marriagePad).set(\wet11, 0.4);

Pbindef(\marriageSeq,
    \dur,    Pseq([4, 4, 8, 4, 6, 10], inf),
    \freq,   Pseq([110, 110, 98, 110, 123.47, 110], inf),
    \cutoff, Pseq([600, 700, 850, 620, 900, 520], inf),
    \t_trig, 1,
    \amp,    Pwhite(0.10, 0.17, inf)
);
Ndef(\marriagePad)[1] = \set -> Pbindef(\marriageSeq);

// --- THE ANTARCTIC TEMPEST: tense, breath-holding noise + low strings ---
Ndef(\antarcticWind, { |amp=0.09, cutoff=420, rq=0.28|
    var lfo, noise, strings, sig;
    lfo    = SinOsc.kr(0.067).range(0.72, 1.32);
    noise  = BPF.ar(PinkNoise.ar(0.35), cutoff * lfo, rq) * 14;
    strings = SinOsc.ar([55, 55.4], 0, 0.14) + SinOsc.ar([82.4, 82.9], 0, 0.07);
    sig = LeakDC.ar(noise + strings);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp) } { Pan2.ar(sig, 0, amp) };
}).play;

Ndef(\antarcticWind)[10] = \filter -> { |in|
    FreeVerb.ar(in, 0.88, 0.96, 0.6);
};
Ndef(\antarcticWind).set(\wet10, 0.55);

// --- THE WAITER, FROZEN: high suspended pings with drifting echo ---
Ndef(\wineGlass, { |freq=2400, amp=0.2, decay=2.5, pan=0, t_trig=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), K2A.ar(t_trig));
    sig = SinOsc.ar(freq)
        + SinOsc.ar(freq * 2.41, 0, 0.3)
        + SinOsc.ar(freq * 3.73, 0, 0.15);
    sig = sig * env * amp;
    Pan2.ar(sig, pan);
}).play;

Ndef(\wineGlass)[10] = \filter -> { |in|
    var dly = CombC.ar(in, 0.5, [0.31, 0.37], 3.2);
    in + (dly * 0.42);
};
Ndef(\wineGlass).set(\wet10, 0.35);

Pbindef(\wineGlassSeq,
    \dur,    Pseq([1.7, 3.2, 2.1, 5.5, 2.8, 4.3, 1.4, 6.2], inf),
    \freq,   Pseq([2400, 2850, 3200, 2100, 2650, 3600, 2250, 3050], inf),
    \decay,  Pwhite(1.4, 3.6, inf),
    \pan,    Pwhite(-0.85, 0.85, inf),
    \t_trig, 1,
    \amp,    Pwhite(0.07, 0.19, inf)
);
Ndef(\wineGlass)[1] = \set -> Pbindef(\wineGlassSeq);

// --- THE MAP FOLDING: methodical, absurdly precise creases ---
Ndef(\mapFold, { |freq=180, amp=0.15, cutoff=1200, rel=0.25, pan=0, t_trig=0|
    var env, body, click, sig;
    env   = EnvGen.ar(Env.perc(0.001, rel, 1, -4), K2A.ar(t_trig));
    body  = SinOsc.ar(freq, 0, 0.7);
    click = HPF.ar(WhiteNoise.ar(0.4), 3000);
    sig   = RLPF.ar(body + ((click) * EnvGen.ar(Env.perc(0.0005, 0.02))), cutoff, 0.4);
    sig   = LeakDC.ar(sig) * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur,    Pseq([0.34, 0.34, 0.17, 0.34, 0.68, 0.17, 0.17, 0.51], inf),
    \freq,   Pseq([180, 220, 260, 200, 240, 160, 280, 195], inf),
    \cutoff, Pseq([900, 1200, 1500, 1100, 820, 1300, 1000, 950], inf),
    \pan,    Pseq([-0.4, 0.4, -0.3, 0.5, 0.0, -0.5, 0.3, 0.1], inf),
    \t_trig, 1,
    \amp,    Pwhite(0.08, 0.18, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
)

// Rollback: Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Rollback: Pbindef(\wineGlassSeq).stop; Ndef(\wineGlass).fadeTime = 2; Ndef(\wineGlass).clear(2);
// Rollback: Ndef(\antarcticWind).fadeTime = 3; Ndef(\antarcticWind).clear(3);
// Rollback: Pbindef(\marriageSeq).stop; Ndef(\marriagePad).fadeTime = 4; Ndef(\marriagePad).clear(4);


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

s.waitForBoot({
    // Safety limiter first
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // --- Discrete brass tick-tock ---
    SynthDef(\brassTick, {
        |out=0, freq=1500, amp=0.2, pan=0, decay=0.05|
        var exc, sig, env;
        env = EnvGen.ar(Env.perc(0.0005, decay, 1, -8), doneAction: 2);
        exc = Impulse.ar(0) + (WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(0.0002, 0.004)));
        sig = Ringz.ar(exc, freq, decay, 0.6);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- French carillon bell (modal) ---
    SynthDef(\carillonBell, {
        |out=0, freq=440, amp=0.2, pan=0, decay=6|
        var exc, sig, env;
        exc = Impulse.ar(0) + (WhiteNoise.ar(0.2) * EnvGen.ar(Env.perc(0.0005, 0.008)));
        sig = DynKlank.ar(
            Ref([
                freq * [1, 2.0, 2.76, 3.0, 4.07, 5.43],
                [1, 0.6, 0.4, 0.3, 0.2, 0.12],
                [decay, decay*0.9, decay*0.7, decay*0.6, decay*0.5, decay*0.4]
            ]),
            exc
        );
        env = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- Pocket chronometer ping ---
    SynthDef(\pocketChron, {
        |out=0, freq=2600, amp=0.15, pan=0, decay=1.8|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, decay, 1, -7), doneAction: 2);
        sig = SinOsc.ar(freq) + SinOsc.ar(freq*2.41, 0, 0.3) + SinOsc.ar(freq*3.73, 0, 0.12);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- Gear scrape burst ---
    SynthDef(\gearScrape, {
        |out=0, freq=800, amp=0.15, pan=0, decay=0.3|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.005, decay, 1, -5), doneAction: 2);
        sig = BPF.ar(PinkNoise.ar(0.5), freq, 0.15) * 8;
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // --- Continuous: the breathing of time ---
    Ndef(\breathOfTime, { |amp=0, cutoff=600, breathRate=0.09|
        var breath, noise, droneL, droneR, sig;
        breath = SinOsc.kr(breathRate).range(0.5, 1.5);
        noise  = BPF.ar(PinkNoise.ar(0.3), cutoff * breath, 0.3) * 6;
        droneL = SinOsc.ar(55, 0, 0.12) + SinOsc.ar(82.4, 0, 0.06);
        droneR = SinOsc.ar(55.3, 0, 0.12) + SinOsc.ar(82.9, 0, 0.06);
        sig = LeakDC.ar([noise + droneL, noise + droneR]);
        sig * amp;
    });
    Ndef(\breathOfTime).fadeTime = 6;

    // --- Continuous: swarm of detuned ticking gears ---
    Ndef(\gearSwarm, { |amp=0, baseRate=6, spread=0.05, cutoff=2500|
        var sig;
        sig = Mix.fill(8, { |i|
            var r = baseRate * (1 + (spread * (i - 3.5) / 3.5));
            var trig = Impulse.ar(r);
            Ringz.ar(trig, 1200 + (i * 180), 0.012, 0.12);
        });
        sig = RLPF.ar(sig, cutoff, 0.6);
        sig = LeakDC.ar([sig, DelayC.ar(sig, 0.05, 0.004)]);
        sig * amp;
    });
    Ndef(\gearSwarm).fadeTime = 4;

    // --- Master mixer ---
    Ndef(\masterMix, {
        var dry = In.ar(~synthBus, 2);
        var b = Ndef(\breathOfTime).ar(2);
        var g = Ndef(\gearSwarm).ar(2);
        dry + b + g;
    }).play;
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.35); };
    Ndef(\masterMix)[11] = \filter -> { |in| DelayC.ar(in, 0.5, 0.3); };
    Ndef(\masterMix).set(\wet10, 0.3, \wet11, 0.2);
    s.sync;

    // --- Sequences ---
    Pbindef(\tickSeqA,
        \instrument, \brassTick,
        \dur, 0.5,
        \freq, 1500,
        \decay, 0.05,
        \pan, (-0.3),
        \amp, Pwhite(0.08, 0.14, inf),
        \out, ~synthBus
    );
    Pbindef(\tickSeqB,
        \instrument, \brassTick,
        \dur, 0.507,
        \freq, 1750,
        \decay, 0.05,
        \pan, 0.3,
        \amp, Pwhite(0.08, 0.14, inf),
        \out, ~synthBus
    );
    Pbindef(\carillonSeq,
        \instrument, \carillonBell,
        \dur, Pseq([2.5, 1.5, 2.0, 3.0, 1.5, 2.5], inf),
        \freq, Pseq([523.25, 659.25, 587.33, 523.25, 698.46, 587.33], inf),
        \decay, Pwhite(4, 8, inf),
        \pan, Pwhite(-0.6, 0.6, inf),
        \amp, Pwhite(0.08, 0.16, inf),
        \out, ~synthBus
    );
    Pbindef(\chronSeq,
        \instrument, \pocketChron,
        \dur, Pseq([0.7, 1.3, 0.9, 2.1, 1.1, 0.6], inf),
        \freq, Pseq([2600, 3100, 2400, 2900, 3400, 2200], inf),
        \decay, Pwhite(1.0, 2.5, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \amp, Pwhite(0.05, 0.13, inf),
        \out, ~synthBus
    );
    Pbindef(\scrapeSeq,
        \instrument, \gearScrape,
        \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75, 0.25], inf),
        \freq, Pseq([800, 1200, 600, 1500, 900, 1100], inf),
        \decay, Pwhite(0.1, 0.4, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \amp, Pwhite(0.06, 0.14, inf),
        \out, ~synthBus
    );

    // --- Chronological score ---
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: The shop awakens - gear swarm and breath]".postln;
        Ndef(\breathOfTime).xset(\amp, 0.5, \cutoff, 500, \breathRate, 0.07);
        Ndef(\gearSwarm).xset(\amp, 0.4, \baseRate, 6, \spread, 0.04, \cutoff, 2200);

        8.do { |i|
            Ndef(\breathOfTime).xset(\cutoff, exprand(400, 900));
            Ndef(\gearSwarm).xset(\cutoff, exprand(1800, 3000));
            1.5.wait;
        };

        "0:12 - [Cue 2: Two hundred pendulums drift out of phase]".postln;
        Pbindef(\tickSeqA).play;
        Pbindef(\tickSeqB).play;

        8.do { |i|
            Ndef(\gearSwarm).xset(\baseRate, rrand(5, 9));
            1.5.wait;
        };

        "0:24 - [Cue 3: French carillons enter]".postln;
        Pbindef(\carillonSeq).play;
        Ndef(\breathOfTime).xset(\cutoff, 700);

        8.do { |i|
            Ndef(\gearSwarm).xset(\spread, rrand(0.02, 0.08));
            Ndef(\breathOfTime).xset(\breathRate, rrand(0.05, 0.12));
            2.wait;
        };

        "0:40 - [Cue 4: Microscopic offsets - chronometers]".postln;
        Pbindef(\chronSeq).play;
        Pbindef(\scrapeSeq).play;

        8.do { |i|
            Ndef(\gearSwarm).xset(\cutoff, exprand(1500, 3500));
            2.wait;
        };

        "0:56 - [Cue 5: The swarm intensifies]".postln;
        Ndef(\gearSwarm).xset(\amp, 0.6, \baseRate, 12);
        Ndef(\breathOfTime).xset(\amp, 0.6, \cutoff, 1000);

        6.do { |i|
            Ndef(\gearSwarm).xset(\baseRate, rrand(10, 16));
            Ndef(\breathOfTime).xset(\cutoff, exprand(800, 1400));
            2.wait;
        };

        "1:08 - [Cue 6: Settling - only the breathing remains]".postln;
        Pbindef(\tickSeqA).stop; Pbindef(\tickSeqB).stop;
        Pbindef(\scrapeSeq).stop;
        Ndef(\gearSwarm).xset(\amp, 0.15);
        Ndef(\breathOfTime).xset(\amp, 0.45, \cutoff, 400, \breathRate, 0.05);

        8.do { |i|
            Ndef(\breathOfTime).xset(\cutoff, exprand(300, 600));
            1.5.wait;
        };

        "1:20 - [Cue 7: Flashback - carillon and chronometer return softly]".postln;
        Ndef(\gearSwarm).xset(\amp, 0.3);
        Ndef(\breathOfTime).xset(\amp, 0.5, \cutoff, 600);

        6.do { |i|
            Ndef(\breathOfTime).xset(\breathRate, rrand(0.04, 0.1));
            2.wait;
        };

        "1:32 - [Cue 8: Resolution - the breathing of time]".postln;
        Pbindef(\carillonSeq).stop;
        Pbindef(\chronSeq).stop;
        Ndef(\gearSwarm).xset(\amp, 0.0);
        Ndef(\breathOfTime).xset(\amp, 0.4, \cutoff, 350, \breathRate, 0.04);

        10.do { |i|
            Ndef(\breathOfTime).xset(\cutoff, exprand(250, 500));
            1.5.wait;
        };

        "1:47 - [Cue 9: Finale - fade]".postln;
        Ndef(\breathOfTime).xset(\amp, 0.0);
        3.wait;

        "Score Complete.".postln;
        Pbindef(\tickSeqA).stop; Pbindef(\tickSeqA).clear;
        Pbindef(\tickSeqB).stop; Pbindef(\tickSeqB).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
        Pbindef(\chronSeq).stop; Pbindef(\chronSeq).clear;
        Pbindef(\scrapeSeq).stop; Pbindef(\scrapeSeq).clear;
        Ndef(\breathOfTime).fadeTime = 3; Ndef(\breathOfTime).clear(3);
        Ndef(\gearSwarm).fadeTime = 3; Ndef(\gearSwarm).clear(3);
        Ndef(\masterMix).fadeTime = 3; Ndef(\masterMix).clear(3);
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #139
// STATUS: PASS
// PROMPT: olho do alto do morro e vejo a cidade estendida como um couro de boi secando ao sol do meio-dia. car...
// ============================================================
(
var screen, winW, winH;

~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24,
    hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, diesel1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44,
    hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, friction2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64,
    hpf3: 65, lpf3: 66, rq3: 67,
    atk3: 68, dec3: 69, sus3: 70, rls3: 71, wind3: 72,
    delTime: 80, delMix: 81, revTime: 82, revMix: 83, panic: 90
);

~ccVals = (
    vol1: 0.22, pan1: 0.0, mute1: 0, min1: 0, max1: 65,
    hpf1: 25, lpf1: 180, rq1: 1.0,
    atk1: 0.01, dec1: 0.3, sus1: 0.6, rls1: 0.5, diesel1: 0.0,
    vol2: 0.20, pan2: -0.35, mute2: 0, min2: 36, max2: 100,
    hpf2: 350, lpf2: 6500, rq2: 0.7,
    atk2: 0.005, dec2: 0.4, sus2: 0.1, rls2: 0.6, friction2: 0.0,
    vol3: 0.18, pan3: 0.35, mute3: 0, min3: 30, max3: 127,
    hpf3: 160, lpf3: 3200, rq3: 0.8,
    atk3: 0.6, dec3: 1.5, sus3: 0.7, rls3: 1.8, wind3: 0.0,
    delTime: 0.3, delMix: 0.0, revTime: 3.0, revMix: 0.0, panic: 0
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
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN: " ++ ~myInDevice.device ++ " / " ++ ~myInDevice.name).postln;
    ~myUid = ~myInDevice.uid;
} {
    "No MIDI input detected.".warn;
    ~myUid = nil;
};

s.waitForBoot {
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Zone 1: Ônibus Azul - diesel FM sub with wavefolder
    SynthDef(\busSub, { |out=0, freq=60, gate=1, amp=0.22, pan=0,
        hpf=25, lpf=180, rq=1.0, atk=0.01, dec=0.3, sus=0.6, rls=0.5, diesel=0.0|
        var env, mod, car, sig, fold, glide;
        glide = Lag.kr(freq, 0.15);
        mod = SinOsc.ar(glide * (1.5 + (diesel * 2.5))) * (glide * (2 + (diesel * 8)));
        car = SinOsc.ar(glide + mod);
        fold = Fold.ar(car * (1 + (diesel * 3)), -0.8, 0.8);
        sig = (fold * 0.6) + (Saw.ar(glide * 0.5) * 0.3);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = (sig * (1 + (diesel * 1.5))).tanh * (1 / (1 + diesel));
        sig = LeakDC.ar(sig);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    // Zone 2: Formigas Mecânicas - comb pluck with allpass friction
    SynthDef(\antPluck, { |out=0, freq=440, gate=1, amp=0.20, pan=0,
        hpf=350, lpf=6500, rq=0.7, atk=0.005, dec=0.4, sus=0.1, rls=0.6, friction=0.0|
        var exciter, comb, sig, env, ap;
        exciter = WhiteNoise.ar(0.8) * EnvGen.ar(Env.perc(0.0005, 0.02));
        comb = CombL.ar(exciter, 0.05, freq.reciprocal.clip(0.0002, 0.05), dec + 0.5);
        ap = AllpassC.ar(comb, 0.02, (friction * 0.008) + 0.0005, 0.08);
        sig = (comb * 0.7) + (ap * 0.5);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    // Zone 3: Vento no Cabelo - detuned additive pad with wind noise
    SynthDef(\windPad, { |out=0, freq=440, gate=1, amp=0.18, pan=0,
        hpf=160, lpf=3200, rq=0.8, atk=0.6, dec=1.5, sus=0.7, rls=1.8, wind=0.0|
        var sig, env, det, noise, filt;
        det = Splay.ar(Saw.ar(freq * [0.98, 0.995, 1.0, 1.005, 1.02]));
        noise = WhiteNoise.ar(0.15) * (0.3 + (wind * 1.5));
        filt = BPF.ar(noise, freq * 2, 0.3);
        sig = (det * 0.6) + filt;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = LeakDC.ar(sig);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp * env) } { Pan2.ar(sig, pan, amp * env) });
    }).add;

    SynthDef(\fxDelay, { |in=0, out=0, delTime=0.3, delMix=0.0|
        var sig, d;
        sig = In.ar(in, 2);
        d = DelayC.ar(sig, 1.0, delTime, 0.6);
        d = AllpassC.ar(d, 0.05, 0.02, 0.3);
        Out.ar(out, (sig * (1 - delMix)) + (d * delMix));
    }).add;

    SynthDef(\fxVerb, { |in=0, out=0, revTime=3.0, revMix=0.0|
        var sig, v;
        sig = In.ar(in, 2);
        v = FreeVerb2.ar(sig[0], sig[1], 0.7, revTime.min(1.0).clip(0.1, 0.99), 0.5);
        Out.ar(out, (sig * (1 - revMix)) + (v * revMix));
    }).add;

    SynthDef(\safetyLimiter, { |in=0|
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;

    s.sync;

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    Synth(\fxDelay, [\in, ~fxBus, \out, ~masterBus,
        \delTime, ~buses[\delTime].asMap, \delMix, ~buses[\delMix].asMap],
        ~fxGroup, \addToTail);
    Synth(\fxVerb, [\in, ~masterBus, \out, 0,
        \revTime, ~buses[\revTime].asMap, \revMix, ~buses[\revMix].asMap],
        ~masterGroup, \addToTail);
    Synth(\safetyLimiter, [\in, 0], ~masterGroup, \addToTail);

    ~zoneNotes = Array.newClear(128);

    MIDIdef.noteOn(\on, { |vel, noteNum|
        var mute1 = 1 - ~ccVals[\mute1];
        var mute2 = 1 - ~ccVals[\mute2];
        var mute3 = 1 - ~ccVals[\mute3];
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[noteNum] = (~zoneNotes[noteNum] ?? []).add(
                Synth(\busSub, [
                    \out, ~fxBus, \freq, noteNum.midicps, \gate, 1,
                    \amp, ~ccVals[\vol1] * (vel / 127) * mute1,
                    \pan, ~ccVals[\pan1],
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap,
                    \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap,
                    \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                    \diesel, ~buses[\diesel1].asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[noteNum] = (~zoneNotes[noteNum] ?? []).add(
                Synth(\antPluck, [
                    \out, ~fxBus, \freq, noteNum.midicps, \gate, 1,
                    \amp, ~ccVals[\vol2] * (vel / 127) * mute2,
                    \pan, ~ccVals[\pan2],
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap,
                    \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap,
                    \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                    \friction, ~buses[\friction2].asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zoneNotes[noteNum] = (~zoneNotes[noteNum] ?? []).add(
                Synth(\windPad, [
                    \out, ~fxBus, \freq, noteNum.midicps, \gate, 1,
                    \amp, ~ccVals[\vol3] * (vel / 127) * mute3,
                    \pan, ~ccVals[\pan3],
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap,
                    \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap,
                    \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                    \wind, ~buses[\wind3].asMap
                ], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\off, { |vel, noteNum|
        if(~zoneNotes[noteNum].notNil) {
            ~zoneNotes[noteNum].do(_.set(\gate, 0));
            ~zoneNotes[noteNum] = nil;
        };
    }, srcID: ~myUid);

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

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            ~zoneNotes.do { |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } };
            ~zoneNotes = Array.newClear(128);
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds = Window.availableBounds;
        var wH = min(780, bounds.height - 60);
        var wW = 660;
        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("Alto do Morro", Rect(
            bounds.left + ((bounds.width - wW) / 2),
            bounds.top + ((bounds.height - wH) / 2),
            wW, wH), scroll: true);
        ~mainWin.background = Color(0.08, 0.08, 0.10);

        ~ui = ();
        ~zoneMeta = [
            (title: "1: Ônibus Azul", fxKey: "diesel1", fxLabel: "DIESEL"),
            (title: "2: Formigas Mecânicas", fxKey: "friction2", fxLabel: "FRICTION"),
            (title: "3: Vento no Cabelo", fxKey: "wind3", fxLabel: "WIND")
        ];

        ~mainWin.view.decorator = FlowLayout(~mainWin.view.bounds, 6@6, 6@6);

        ~zoneMeta.do { |zm, idx|
            var z = idx + 1;
            var zs = z.asString;
            var page = CompositeView(~mainWin, 640@380);
            page.background = Color(0.10, 0.10, 0.13);
            page.decorator = FlowLayout(page.bounds, 6@6, 6@6);

            StaticText(page, 620@24)
                .string_(zm[\title] ++ "   |   CC " ++ ~cc[("min"++zs).asSymbol]
                    ++ "-" ++ ~cc[("max"++zs).asSymbol])
                .font_(Font("Helvetica", 14, true))
                .stringColor_(Color(0.9, 0.85, 0.7));

            ~ui[("mute"++zs).asSymbol] = Button(page, 90@24)
                .states_([["MUTE", Color.white, Color(0.5,0.1,0.1)],
                          ["ON", Color.white, Color(0.1,0.4,0.15)]])
                .action_({ |b|
                    var nv = if(b.value == 1, 1.0, 0.0);
                    ~ccVals[("mute"++zs).asSymbol] = nv;
                    ~buses[("mute"++zs).asSymbol].set(nv);
                });

            ~ui[("min"++zs).asSymbol] = EZRanger(page, 220@24)
                .lo_(~ccVals[("min"++zs).asSymbol])
                .hi_(~ccVals[("max"++zs).asSymbol])
                .action_({ |ez|
                    ~ccVals[("min"++zs).asSymbol] = ez.lo;
                    ~ccVals[("max"++zs).asSymbol] = ez.hi;
                    ~buses[("min"++zs).asSymbol].set(ez.lo);
                    ~buses[("max"++zs).asSymbol].set(ez.hi);
                });

            [("vol"++zs).asSymbol, ("pan"++zs).asSymbol,
             ("hpf"++zs).asSymbol, ("lpf"++zs).asSymbol,
             ("rq"++zs).asSymbol, ("atk"++zs).asSymbol,
             ("dec"++zs).asSymbol, ("sus"++zs).asSymbol,
             ("rls"++zs).asSymbol, zm[\fxKey].asSymbol].do { |k|
                var ks = k.asString;
                var lo = case
                    { ks.matchRegexp("lpf|hpf") } { 20 }
                    { ks.contains("rq") } { 0.05 }
                    { ks.contains("pan") } { -1.0 }
                    { ks.matchRegexp("atk|dec|sus|rls") } { 0.005 }
                    { 0.0 };
                var hi = case
                    { ks.matchRegexp("lpf|hpf") } { 18000 }
                    { ks.contains("rq") } { 1.0 }
                    { ks.contains("pan") } { 1.0 }
                    { ks.matchRegexp("atk|dec|sus|rls") } { 5.0 }
                    { 1.0 };
                var label = if(k == zm[\fxKey].asSymbol, zm[\fxLabel],
                    ks.replace(zs, "").toUpper);
                ~ui[k] = EZSlider(page, 80@90,
                    label ++ " (" ++ ~cc[k] ++ ")",
                    ControlSpec(lo, hi, \lin, 0.001, ~ccVals[k]),
                    { |ez| ~ccVals[k] = ez.value; ~buses[k].set(ez.value) });
            };
        };

        StaticText(~mainWin, 620@20).string_("MASTER FX")
            .stringColor_(Color(0.8,0.8,0.6))
            .font_(Font("Helvetica", 13, true));
        [\delTime, \delMix, \revTime, \revMix].do { |k|
            ~ui[k] = EZSlider(~mainWin, 140@80,
                k.asString ++ " (" ++ ~cc[k] ++ ")",
                ControlSpec(0, 1, \lin, 0.001, ~ccVals[k]),
                { |ez| ~ccVals[k] = ez.value; ~buses[k].set(ez.value) });
        };

        Button(~mainWin, 200@40)
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.7,0.05,0.05)]])
            .action_({
                ~zoneNotes.do { |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } };
                ~zoneNotes = Array.newClear(128);
            });

        ~mainWin.front;

        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }
                            and: { ~ui[k].isKindOf(EZRanger).not }) {
                            ~ui[k].value = v;
                        };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
};
)

// cleanup:
// ~mainWin.close;
// ~zoneNotes.do { |a| if(a.notNil) { a.do(_.free) } };
// ~fxGroup.freeAll; ~masterGroup.freeAll;


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: FIXED
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// API error: expected string or bytes-like object, got 'NoneType'
)


// ============================================================
// ROUND 05 | MODE: APPEND | FRAG #120
// STATUS: FIXED
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// --- Tinir de ferros: iron chains dragging across the deck ---
Ndef(\ironChain, { |amp=0.3, pan=0, t_trig=0, fund=180, decay=1.2|
    var exc = Decay2.ar(K2A.ar(t_trig), 0.0005, 0.02) * PinkNoise.ar(0.7);
    var freqs = fund * [1, 2.37, 3.71, 5.13, 7.42, 9.89];
    var rings = Ringz.ar(exc, freqs, decay * (1 - ((0..5) * 0.09)));
    var sig = HPF.ar(rings.sum, 350);
    var comp = (sig * 2.5).tanh;
    Pan2.ar(comp * amp, pan);
}).play;

Ndef(\ironChain)[10] = \filter -> { |in|
    // Decimator is sc3-plugins only; vanilla bitcrush equivalent
    Latch.ar(in, Impulse.ar(12000)).round(0.5 ** 10);
};
Ndef(\ironChain).xset(\wet10, 0.22);
// Ndef(\ironChain).xset(\wet10, 0); // Rollback: disable bitcrush

Pbindef(\ironChainSeq,
    \dur, Pseq([0.3, 0.15, 0.4, 0.22, 0.8, 0.12, 0.5], inf),
    \t_trig, 1,
    \amp, Pexprand(0.12, 0.4, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \fund, Pseq([160, 220, 180, 260, 140, 300], inf),
    \decay, Pwhite(0.8, 2.2, inf)
);
Ndef(\ironChain)[1] = \set -> Pbindef(\ironChainSeq);

// --- Estalar de açoite: whip crack across flesh ---
Ndef(\whipLash, { |amp=0.5, pan=0, t_trig=0, cut=3500, rq=0.4|
    var env = EnvGen.ar(Env.perc(0.0001, 0.07, 1, -8), t_trig);
    var noise = WhiteNoise.ar;
    var bp = BPF.ar(noise, cut, rq) * 12;
    var crack = bp * env;
    var bodyFreq = XLine.kr(1900, 70, 0.06);
    var body = SinOsc.ar(bodyFreq) * EnvGen.ar(Env.perc(0.0001, 0.09), t_trig) * 0.35;
    Pan2.ar((crack + body) * amp, pan);
}).play;

Pbindef(\whipSeq,
    \dur, Pseq([1.2, 0.4, 2.0, 0.9, 3.5], inf),
    \t_trig, 1,
    \amp, Pwhite(0.35, 0.65, inf),
    \pan, Pwhite(-0.5, 0.5, inf),
    \cut, Pwhite(2200, 5000, inf)
);
Ndef(\whipLash)[1] = \set -> Pbindef(\whipSeq);

// --- Homens gemendo: moaning voices under salty wind ---
Ndef(\moanVoices, { |freq=110, amp=0.14, pan=0, cut=1800|
    var base = Saw.ar(freq * [0.99, 1.0, 1.01]);
    var form = [700, 1220, 2600];
    var voiced = form.collect { |f| BPF.ar(base.sum, f, 0.1) * 7 }.sum;
    var sub = SinOsc.ar(freq * 0.5) * 0.45;
    var sig = LPF.ar(voiced, cut) + sub;
    var slow = SinOsc.kr(0.13).range(0.5, 1.0);
    var breath = PinkNoise.ar(0.06) * slow;
    Pan2.ar((sig * amp * slow) + (breath * amp), pan);
}).play;

Ndef(\moanVoices)[10] = \filter -> { |in|
    FreeVerb.ar(in.sum * 0.7, 0.85, 0.94, 0.5);
};
Ndef(\moanVoices).xset(\wet10, 0.45);
// Ndef(\moanVoices).xset(\wet10, 0); // Rollback: disable reverb

Pbindef(\moanSeq,
    \dur, Pseq([6, 5, 8, 7], inf),
    \freq, Pseq([110, 98, 130.8, 87.3], inf),
    \amp, Pwhite(0.10, 0.20, inf),
    \pan, Pwhite(-0.4, 0.4, inf)
);
Ndef(\moanVoices)[1] = \set -> Pbindef(\moanSeq);

// --- Um raio que quebre os elos da corrente maldita ---
Ndef(\thunderRoll, { |amp=0.5, pan=0, t_trig=0, decay=6|
    var env = Decay2.ar(K2A.ar(t_trig), 0.08, decay);
    var noise = PinkNoise.ar(0.8) + BrownNoise.ar(0.6);
    var lp = LPF.ar(noise, 180) * 4.5;
    var sub = SinOsc.ar(45) * env * 0.55;
    var subH = SinOsc.ar(90) * env * 0.25;
    var rumble = lp * env;
    Pan2.ar((rumble + sub + subH) * amp, pan);
}).play;

Ndef(\thunderRoll)[10] = \filter -> { |in|
    var v = FreeVerb.ar(in.sum * 0.6, 0.92, 0.97, 0.6);
    (in * 0.3) + (v * 0.9);
};
Ndef(\thunderRoll).xset(\wet10, 0.7);
// Ndef(\thunderRoll).xset(\wet10, 0); // Rollback: disable cavern reverb

Pbindef(\thunderSeq,
    \dur, Pseq([18, 24, 12], inf),
    \t_trig, 1,
    \amp, Pwhite(0.5, 0.85, inf),
    \decay, Pwhite(4, 9, inf),
    \pan, Pwhite(-0.3, 0.3, inf)
);
Ndef(\thunderRoll)[1] = \set -> Pbindef(\thunderSeq);

// Rollback: remove these instruments
// Pbindef(\ironChainSeq).stop; Ndef(\ironChain).fadeTime = 2; Ndef(\ironChain).clear(2);
// Pbindef(\whipSeq).stop;      Ndef(\whipLash).fadeTime = 2;  Ndef(\whipLash).clear(2);
// Pbindef(\moanSeq).stop;      Ndef(\moanVoices).fadeTime = 2;Ndef(\moanVoices).clear(2);
// Pbindef(\thunderSeq).stop;   Ndef(\thunderRoll).fadeTime = 2;Ndef(\thunderRoll).clear(2);
)


// ============================================================
// ROUND 06 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
s.sync;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

// --- Gota d'água calcária: drip with pitch-swept resonance ---
SynthDef(\dripDrop, { |out=0, amp=0.4, pan=0, freq=900, decay=1.4|
    var excEnv = EnvGen.ar(Env.perc(0.0005, 0.02));
    var exc = WhiteNoise.ar(0.6) * excEnv + Impulse.ar(0) * 0.5;
    var body = SinOsc.ar(XLine.kr(freq * 1.6, freq * 0.7, 0.05)) * EnvGen.ar(Env.perc(0.001, 0.08));
    var rings = Ringz.ar(exc, freq * [1, 2.71, 4.23, 5.83], decay * [1, 0.8, 0.6, 0.45]);
    var aenv = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);
    Out.ar(out, Pan2.ar((rings.sum * 0.4 + body * 0.5) * aenv * amp, pan));
}).add;

// --- Estalactite: modal DynKlank bell struck by noise+impulse ---
SynthDef(\stalactite, { |out=0, amp=0.3, pan=0, freq=220, decay=4|
    var excEnv = EnvGen.ar(Env.perc(0.001, 0.03));
    var exc = WhiteNoise.ar * excEnv + Impulse.ar(0) * 0.3;
    var freqs = freq * [1, 2.13, 3.41, 4.77, 6.12, 8.91];
    var amps  = [1, 0.7, 0.5, 0.35, 0.25, 0.15];
    var rings = [1, 1.4, 1.9, 2.6, 3.4, 4.5];
    var klank = DynKlank.ar(Ref([freqs, amps, rings]), exc);
    var aenv = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
    Out.ar(out, Pan2.ar(klank * aenv * amp, pan));
}).add;

// --- Ressonância profunda das abóbadas ---
SynthDef(\caveBoom, { |out=0, amp=0.5, pan=0, decay=8|
    var env = EnvGen.ar(Env.perc(0.05, decay, 1, -3), doneAction: 2);
    var sub = SinOsc.ar(38) * 0.7 + SinOsc.ar(76) * 0.3;
    var rumble = LPF.ar(BrownNoise.ar, 90) * 3;
    Out.ar(out, Pan2.ar((sub + rumble) * env * amp, pan));
}).add;

// --- Cortina mineral: shimmering high resonance ---
SynthDef(\waterChime, { |out=0, amp=0.3, pan=0, freq=1400, decay=2.5|
    var excEnv = EnvGen.ar(Env.perc(0.001, 0.01));
    var exc = Impulse.ar(0) + WhiteNoise.ar * 0.3 * excEnv;
    var sig = Ringz.ar(exc, freq * [1, 1.61, 2.42, 3.83], decay * [1, 0.8, 0.6, 0.45]).sum;
    var aenv = EnvGen.ar(Env.perc(0.001, decay, 1, -6), doneAction: 2);
    Out.ar(out, Pan2.ar(sig * aenv * amp * 0.5, pan));
}).add;
s.sync;

// --- Ar frio da gruta: low drone bed ---
Ndef(\caveAir, { |amp=0, cut=180|
    var base = SinOsc.ar([38.5, 39.2, 57.8]) * 0.3;
    var rumble = LPF.ar(BrownNoise.ar(0.6), cut) * 2;
    var slow = SinOsc.kr(0.07).range(0.6, 1.0);
    Pan2.ar((base.sum + rumble) * slow * amp, 0);
});

// --- Cortinas minerais: BPF shimmer from pink noise ---
Ndef(\mineralCurtain, { |amp=0, cut=2800, rq=0.02|
    var noise = PinkNoise.ar(0.4);
    var bp = BPF.ar(noise, cut, rq) * 12;
    var shimmer = bp * SinOsc.kr(0.23).range(0.3, 1.0);
    var high = HPF.ar(WhiteNoise.ar(0.05), 6000);
    Pan2.ar((shimmer + high) * amp, SinOsc.kr(0.11));
});

// --- Fluxo de água milenar ---
Ndef(\waterFlow, { |amp=0, cut=900|
    var n = PinkNoise.ar(0.5);
    var bp = BPF.ar(n, cut, 0.3) * 4;
    var mod = SinOsc.kr(0.4).range(600, 1400);
    var sig = BPF.ar(n, mod, 0.15) * 5;
    Pan2.ar((bp + sig) * amp, SinOsc.kr(0.17).range(-0.6, 0.6));
});

Ndef(\masterMix, {
    var dry = In.ar(~synthBus, 2);
    var air = Ndef(\caveAir).ar(2);
    var curtain = Ndef(\mineralCurtain).ar(2);
    var flow = Ndef(\waterFlow).ar(2);
    dry + air + curtain + flow;
});
Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.35) };
Ndef(\masterMix).set(\wet10, 0.35);
Ndef(\masterMix).play;
s.sync;

Tdef(\masterScore, {
    0.5.wait;
    "0:00 - [Cue 1: Entrada - ar frio, primeiras gotas]".postln;
    Ndef(\caveAir).xset(\amp, 0.35, \cut, 180);
    Ndef(\waterFlow).xset(\amp, 0.15);
    Pbindef(\dripSeq,
        \instrument, \dripDrop, \out, ~synthBus,
        \dur, Pexprand(0.4, 2.5, inf),
        \freq, Pexprand(500, 2400, inf),
        \amp, Pexprand(0.15, 0.4, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \decay, Pexprand(0.6, 2.0, inf)
    ).play;
    6.do { |i|
        Ndef(\waterFlow).xset(\cut, exprand(600, 1500));
        Ndef(\caveAir).xset(\cut, exprand(120, 260));
        2.wait;
    };

    "0:13 - [Cue 2: Primeiros salões - estalactites]".postln;
    Pbindef(\stalactiteSeq,
        \instrument, \stalactite, \out, ~synthBus,
        \dur, Pseq([3, 2, 4, 2.5, 5, 1.5], inf),
        \freq, Pseq([220, 293, 261, 349, 196, 392, 174], inf),
        \amp, Pwhite(0.15, 0.35, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \decay, Pwhite(2.5, 5.5, inf)
    ).play;
    8.do { |i|
        Ndef(\mineralCurtain).xset(\cut, exprand(1800, 5000), \rq, exprand(0.01, 0.05));
        Ndef(\caveAir).xset(\cut, exprand(140, 320));
        2.wait;
    };

    "0:30 - [Cue 3: Cortinas minerais - shimmer]".postln;
    Ndef(\mineralCurtain).xset(\amp, 0.22);
    Ndef(\waterFlow).xset(\amp, 0.25);
    Pbindef(\waterChimeSeq,
        \instrument, \waterChime, \out, ~synthBus,
        \dur, Pexprand(1.5, 4.5, inf),
        \freq, Pexprand(900, 3200, inf),
        \amp, Pexprand(0.15, 0.35, inf),
        \pan, Pwhite(-0.9, 0.9, inf),
        \decay, Pexprand(1.5, 3.5, inf)
    ).play;
    6.do { |i|
        Ndef(\mineralCurtain).xset(\cut, exprand(2500, 6000));
        Ndef(\waterFlow).xset(\cut, exprand(700, 1800));
        2.wait;
    };

    "0:43 - [Cue 4: Peter Lund escuta - settling]".postln;
    Pbindef(\dripSeq).stop;
    Pbindef(\stalactiteSeq).stop;
    Ndef(\waterFlow).xset(\amp, 0.08);
    Ndef(\mineralCurtain).xset(\amp, 0.12);
    Ndef(\caveAir).xset(\amp, 0.45, \cut, 140);
    Pbindef(\stalactiteSeq,
        \instrument, \stalactite, \out, ~synthBus,
        \dur, Pseq([6, 4, 7, 5], inf),
        \freq, Pseq([174, 196, 220, 261], inf),
        \amp, Pwhite(0.08, 0.18, inf),
        \pan, Pwhite(-0.4, 0.4, inf),
        \decay, Pwhite(4, 7, inf)
    ).play;
    8.do { |i| Ndef(\caveAir).xset(\cut, exprand(110, 200)); 1.5.wait; };

    "0:55 - [Cue 5: Abóbadas profundas - booms]".postln;
    Pbindef(\boomSeq,
        \instrument, \caveBoom, \out, ~synthBus,
        \dur, Pseq([10, 8, 12, 7], inf),
        \amp, Pwhite(0.4, 0.7, inf),
        \decay, Pwhite(6, 10, inf),
        \pan, Pwhite(-0.3, 0.3, inf)
    ).play;
    Ndef(\caveAir).xset(\amp, 0.55);
    Ndef(\mineralCurtain).xset(\amp, 0.25);
    Ndef(\waterFlow).xset(\amp, 0.3);
    Pbindef(\dripSeq,
        \instrument, \dripDrop, \out, ~synthBus,
        \dur, Pexprand(0.3, 1.8, inf),
        \freq, Pexprand(600, 2800, inf),
        \amp, Pexprand(0.2, 0.45, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \decay, Pexprand(0.8, 2.5, inf)
    ).play;
    8.do { |i|
        Pbindef(\dripSeq, \dur, Pexprand(0.15, 1.2, inf));
        Ndef(\mineralCurtain).xset(\cut, exprand(3000, 7000));
        1.5.wait;
    };

    "1:10 - [Cue 6: Clímax - ressonância total]".postln;
    Ndef(\masterMix).set(\wet10, 0.55);
    Ndef(\caveAir).xset(\amp, 0.7, \cut, 220);
    Ndef(\mineralCurtain).xset(\amp, 0.35);
    Ndef(\waterFlow).xset(\amp, 0.4);
    Pbindef(\boomSeq, \dur, Pseq([4, 3, 5, 3.5], inf));
    8.do { |i|
        Ndef(\caveAir).xset(\cut, exprand(180, 380));
        Ndef(\mineralCurtain).xset(\cut, exprand(3500, 8000));
        Ndef(\waterFlow).xset(\cut, exprand(800, 2000));
        1.5.wait;
    };

    "1:22 - [Cue 7: Escuridão silenciosa - settling]".postln;
    Pbindef(\boomSeq).stop;
    Pbindef(\dripSeq).stop;
    Pbindef(\waterChimeSeq).stop;
    Pbindef(\stalactiteSeq).stop;
    Ndef(\masterMix).set(\wet10, 0.4);
    Ndef(\caveAir).xset(\amp, 0.35);
    Ndef(\mineralCurtain).xset(\amp, 0.1);
    Ndef(\waterFlow).xset(\amp, 0.15);
    Pbindef(\dripSeq,
        \instrument, \dripDrop, \out, ~synthBus,
        \dur, Pseq([2, 3.5, 1.5, 4, 2.5], 1),
        \freq, Pexprand(700, 1800, inf),
        \amp, Pwhite(0.15, 0.3, inf),
        \pan, Pwhite(-0.6, 0.6, inf),
        \decay, Pwhite(1.5, 3, inf)
    ).play;
    12.do { |i| Ndef(\caveAir).xset(\cut, exprand(90, 180)); 1.wait; };

    "1:35 - [Cue 8: Fim - última gota]".postln;
    Pbindef(\dripSeq).stop;
    Ndef(\caveAir).xset(\amp, 0.15);
    Ndef(\waterFlow).xset(\amp, 0.05);
    Ndef(\mineralCurtain).xset(\amp, 0.05);
    6.do { |i| Ndef(\caveAir).xset(\cut, exprand(80, 140)); 1.wait; };
    Ndef(\caveAir).xset(\amp, 0);
    Ndef(\waterFlow).xset(\amp, 0);
    Ndef(\mineralCurtain).xset(\amp, 0);
    Ndef(\masterMix).set(\wet10, 0);
    3.wait;

    "Score Complete.".postln;
    Pbindef(\dripSeq).stop; Pbindef(\dripSeq).clear;
    Pbindef(\stalactiteSeq).stop; Pbindef(\stalactiteSeq).clear;
    Pbindef(\waterChimeSeq).stop; Pbindef(\waterChimeSeq).clear;
    Pbindef(\boomSeq).stop; Pbindef(\boomSeq).clear;
    Ndef(\caveAir).clear(2);
    Ndef(\mineralCurtain).clear(2);
    Ndef(\waterFlow).clear(2);
    Ndef(\masterMix).clear(2);
    Tdef(\masterScore).stop;
});
Tdef(\masterScore).play;
)


// ============================================================
// ROUND 07 | MODE: DESIGN | FRAG #170
// STATUS: PASS
// PROMPT: O rei acordou com uma ideia azul na cabeça. Não era um pássaro nem uma flor de lavanda: era um pensa...
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
// ============ Step 0: CC map ============
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 33, pan2: 34, mute2: 35, min2: 36, max2: 37, hpf2: 38, lpf2: 39, rq2: 40,
    atk2: 41, dec2: 42, sus2: 43, rls2: 44, fx2: 45,
    vol3: 46, pan3: 47, mute3: 48, min3: 49, max3: 50, hpf3: 51, lpf3: 52, rq3: 53,
    atk3: 54, dec3: 55, sus3: 56, rls3: 57, fx3: 58,
    delMix: 59, delTime: 60, revMix: 61, revTime: 62, master: 63, panic: 65
);

// ============ Step 1 & 2: MIDI discovery + hardware fallback ============
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
        label.contains("bmt").not and: { label.contains("bome").not }
            and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not } and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not } and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

// ============ Step 3: Boot & build ============
s.waitForBoot {
    // Blue clarity: sub thought, crystal vessel, soap bubble
    ~ccVals = (
        vol1: 0.25, pan1: 0.0, mute1: 0.0, min1: 0, max1: 65, hpf1: 25, lpf1: 180, rq1: 0.4,
        atk1: 0.01, dec1: 0.3, sus1: 0.7, rls1: 1.5, fx1: 0.0,
        vol2: 0.22, pan2: -0.35, mute2: 0.0, min2: 36, max2: 100, hpf2: 350, lpf2: 6500, rq2: 0.3,
        atk2: 0.001, dec2: 0.8, sus2: 0.0, rls2: 0.6, fx2: 0.0,
        vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.5,
        atk3: 0.6, dec3: 1.0, sus3: 0.7, rls3: 2.5, fx3: 0.0,
        delMix: 0.0, delTime: 0.375, revMix: 0.0, revTime: 3.0, master: 0.7, panic: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~synthBus = Bus.audio(s, 2);
    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // ---------- Zone 1: Blue Thought (FM sub, wavefolded clarity) ----------
    SynthDef(\blueThought, { |out=0, freq=110, gate=1, amp=1, vol=0.25, pan=0,
        hpf=25, lpf=180, rq=0.4, atk=0.01, dec=0.3, sus=0.7, rls=1.5, fx1=0, mute=0|
        var env, sig, mod, car, fold;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 1.005) * (freq * (1.0 + (fx1 * 4.0)));
        car = SinOsc.ar(freq + mod);
        fold = Fold.ar(car * (1.0 + (fx1 * 3.0)), -0.8, 0.8);
        sig = LeakDC.ar(fold) * 0.5;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = (sig * (1.0 + (fx1 * 2.0))).tanh * (1.0 / (1.0 + fx1));
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---------- Zone 2: Crystal Vessel (comb pluck + allpass dispersion) ----------
    SynthDef(\crystalVessel, { |out=0, freq=440, gate=1, amp=1, vol=0.22, pan=(-0.35),
        hpf=350, lpf=6500, rq=0.3, atk=0.001, dec=0.8, sus=0.0, rls=0.6, fx2=0, mute=0|
        var env, exc, comb, disp, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        comb = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), dec * 3);
        disp = AllpassC.ar(comb, 0.02, (fx2 * 0.008) + 0.0005, 0.08);
        sig = (comb + (disp * fx2)) * 0.5;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---------- Zone 3: Soap Bubble (detuned additive pad, lipid shimmer) ----------
    SynthDef(\soapBubble, { |out=0, freq=440, gate=1, amp=1, vol=0.18, pan=0.35,
        hpf=160, lpf=3200, rq=0.5, atk=0.6, dec=1.0, sus=0.7, rls=2.5, fx3=0, mute=0|
        var env, sig, det;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        det = Saw.ar(freq * [0.995, 1, 1.005]) + Pulse.ar(freq * 0.501, 0.35, 0.4);
        sig = Splay.ar(det * 0.4);
        sig = sig + (SinOsc.ar(freq * 2.0) * 0.15 * SinOsc.kr(fx3.linlin(0, 1, 0.1, 8.0)).range(0.4, 1.0));
        sig = MoogFF.ar(sig, lpf, 2.0 + (fx3 * 2.0)) * 3.0;
        sig = HPF.ar(sig, hpf);
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    // ---------- FX ----------
    SynthDef(\fxDelay, { |in, out, delMix=0, delTime=0.375|
        var sig, del;
        sig = In.ar(in, 2);
        del = DelayC.ar(sig, 1.0, delTime.clip(0.02, 0.9), 0.5);
        Out.ar(out, sig + (del * delMix));
    }).add;

    SynthDef(\fxVerb, { |in, out, revMix=0, revTime=3.0|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], revMix, revTime.clip(0.2, 8.0).linlin(0.2, 8.0, 0.5, 0.98), 0.5);
        Out.ar(out, wet);
    }).add;

    SynthDef(\safetyLimiter, { |in, out, amp=0.7|
        var sig;
        sig = In.ar(in, 2);
        sig = LeakDC.ar(sig) * amp;
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxDelay = Synth(\fxDelay, [\in, ~synthBus, \out, ~fxBus,
        \delMix, ~buses.delMix.asMap, \delTime, ~buses.delTime.asMap], ~fxGroup, \addToTail);
    ~fxVerb = Synth(\fxVerb, [\in, ~fxBus, \out, ~masterBus,
        \revMix, ~buses.revMix.asMap, \revTime, ~buses.revTime.asMap], ~fxGroup, \addToTail);
    ~master = Synth(\safetyLimiter, [\in, ~masterBus, \out, 0,
        \amp, ~buses.master.asMap], ~masterGroup, \addToTail);

    // ---------- MIDIdefs ----------
    MIDIdef.noteOn(\zoneOn, { |vel, noteNum|
        var vAmp = vel.linexp(1, 127, 0.15, 1.0);
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes[noteNum] = (~zone1Notes[noteNum] ? []).add(
                Synth(\blueThought, [
                    \out, ~synthBus, \freq, noteNum.midicps, \amp, vAmp,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap,
                    \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fx1, ~buses.fx1.asMap, \mute, ~buses.mute1.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = (~zone2Notes[noteNum] ? []).add(
                Synth(\crystalVessel, [
                    \out, ~synthBus, \freq, noteNum.midicps, \amp, vAmp,
                    \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap,
                    \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                    \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap,
                    \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                    \fx2, ~buses.fx2.asMap, \mute, ~buses.mute2.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = (~zone3Notes[noteNum] ? []).add(
                Synth(\soapBubble, [
                    \out, ~synthBus, \freq, noteNum.midicps, \amp, vAmp,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap,
                    \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap,
                    \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                    \fx3, ~buses.fx3.asMap, \mute, ~buses.mute3.asMap
                ], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\zoneOff, { |vel, noteNum|
        ~zone1Notes[noteNum].do(_.set(\gate, 0));
        ~zone2Notes[noteNum].do(_.set(\gate, 0));
        ~zone3Notes[noteNum].do(_.set(\gate, 0));
        ~zone1Notes[noteNum] = []; ~zone2Notes[noteNum] = []; ~zone3Notes[noteNum] = [];
    }, srcID: ~myUid);

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

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                arr.do { |a| if(a.notNil) { a.do(_.set(\gate, 0)) } };
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ---------- Paginated GUI ----------
    ~zoneMeta = [
        (title: "BLUE THOUGHT",   fxKey: \fx1, fxLabel: "FOLD DEPTH", z: 1),
        (title: "CRYSTAL VESSEL", fxKey: \fx2, fxLabel: "DISPERSION", z: 2),
        (title: "SOAP BUBBLE",    fxKey: \fx3, fxLabel: "SHIMMER",    z: 3)
    ];

    defer {
        var bounds = Window.availableBounds;
        var winH = min(780, bounds.height - 60);
        var pages = [];
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("The King's Blue Idea — Crystal Vessels",
            Rect((bounds.width - 900) / 2, (bounds.height - winH) / 2, 900, winH));
        ~ui = ();

        ~zoneMeta.do { |zm, idx|
            var z = zm.z;
            var v = CompositeView(~mainWin, Rect(8, 44, 884, winH - 90));
            v.decorator = FlowLayout(v.bounds, 6@6, 6@6);
            v.visible = false;
            [\vol, \pan, \mute, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, zm.fxKey].do { |c|
                var k = if(c == zm.fxKey) { zm.fxKey } { (c.asString ++ z).asSymbol };
                var sp = case
                    { c == \vol } { ControlSpec(0, 1) }
                    { c == \pan } { ControlSpec(-1, 1) }
                    { c == \mute } { ControlSpec(0, 1) }
                    { c == \hpf } { ControlSpec(20, 18000, \exp) }
                    { c == \lpf } { ControlSpec(20, 18000, \exp) }
                    { c == \rq } { ControlSpec(0.05, 1.0) }
                    { [c == \atk, c == \dec, c == \sus, c == \rls].any } { ControlSpec(0.005, 5, \exp) }
                    { true } { ControlSpec(0, 1) };
                var lb = (if(c == zm.fxKey) { zm.fxLabel } { c.asString.toUpper }) ++ " CC" ++ ~cc[k];
                ~ui[k] = EZSlider(v, 195@44, lb, sp,
                    { |ez| ~ccVals[k] = ez.value; if(~buses[k].notNil) { ~buses[k].set(ez.value) } },
                    ~ccVals[k]);
            };
            pages = pages.add(v);
        };

        ~masterPage = CompositeView(~mainWin, Rect(8, 44, 884, winH - 90));
        ~masterPage.decorator = FlowLayout(~masterPage.bounds, 6@6, 6@6);
        ~masterPage.visible = true;
        [\delMix, \delTime, \revMix, \revTime, \master].do { |c|
            var sp = case
                { c == \delTime } { ControlSpec(0.02, 1.0) }
                { c == \revTime } { ControlSpec(0.2, 8.0) }
                { true } { ControlSpec(0, 1) };
            ~ui[c] = EZSlider(~masterPage, 260@30, c.asString.toUpper ++ " CC" ++ ~cc[c], sp,
                { |ez| ~ccVals[c] = ez.value; if(~buses[c].notNil) { ~buses[c].set(ez.value) } },
                ~ccVals[c]);
        };
        Button(~masterPage, Rect(0, 0, 220, 44))
            .states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({
                [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                    arr.do { |a| if(a.notNil) { a.do(_.set(\gate, 0)) } };
                };
            });

        ~zoneMeta.do { |zm, i|
            Button(~mainWin, Rect(8 + (i * 150), 10, 145, 26))
                .states_([[zm.title, Color.white, Color.blue(0.55)]])
                .action_({ pages.do { |pv, j| pv.visible = (j == i) }; ~masterPage.visible = false });
        };
        Button(~mainWin, Rect(8 + (~zoneMeta.size * 150), 10, 145, 26))
            .states_([["MASTER FX", Color.white, Color.gray(0.5)]])
            .action_({ pages.do(_.visible = false); ~masterPage.visible = true });

        ~mainWin.front;
    };

    // ---------- 20fps poller ----------
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

    "The King's Blue Idea — ready (2/3 zones on keys).".postln;
};
}.value;
)

// ~mainWin.close; ~master.free; ~fxDelay.free; ~fxVerb.free;
// ~zone1Notes.do(_.do(_.free)); ~zone2Notes.do(_.do(_.free)); ~zone3Notes.do(_.do(_.free));


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #129
// STATUS: PASS
// PROMPT: O que não tem utilidade nenhuma é o que sustenta o mundo. Aprendi com os passarinhos a arte de desap...
// ============================================================
(
// ===== LAYER 1: RIVER BED — sub drone, water over smooth stones =====
Ndef(\rioPedras, { |amp=0.16, cutoff=520|
    var freq = 55;
    var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var saws = Saw.ar(freq * [1, 1.005, 2.01, 3.02], 0.1).sum;
    var body = (sub * 0.5) + saws;
    var lfo = SinOsc.kr(0.07).range(0.6, 1.0);
    var water = BPF.ar(PinkNoise.ar(0.4), LFNoise1.kr(0.2).range(900, 2600), 0.4) * 12;
    var sig = MoogFF.ar(body, cutoff * lfo, 2.5) * 2.2;
    sig = LeakDC.ar((sig + water) * amp);
    Pan2.ar(sig, SinOsc.kr(0.05).range(-0.3, 0.3));
}).play;
Ndef(\rioPedras).fadeTime = 6;
Ndef(\rioPedras)[10] = \filter -> { |in| FreeVerb.ar(in, 0.85, 0.95, 0.5) };
Ndef(\rioPedras).set(\wet10, 0.42);

// ===== LAYER 2: FROG IN THE MUD — modal plop, universe trembling =====
Ndef(\raLodo, { |amp=0.22, t_trig=1, freq=180|
    var env = Decay2.ar(K2A.ar(t_trig), 0.003, 0.07);
    var exc = PinkNoise.ar(1) * env;
    var klank = DynKlank.ar(Ref([
        [freq, freq * 1.7, freq * 2.4, freq * 3.1],
        [1, 0.6, 0.35, 0.2],
        [0.4, 0.3, 0.2, 0.15]
    ]), exc, 1, 0, 1.2);
    var thud = SinOsc.ar(freq * 0.5) * Decay2.ar(K2A.ar(t_trig), 0.005, 0.15) * 0.5;
    var sig = (klank + thud) * amp;
    Pan2.ar(sig, TRand.kr(-0.6, 0.6, t_trig));
}).play;
Ndef(\raLodo).fadeTime = 3;
Ndef(\raLodo)[10] = \filter -> { |in| FreeVerb.ar(in, 0.8, 0.9, 0.45) };
Ndef(\raLodo).set(\wet10, 0.3);

// ===== LAYER 3: UNNAMED BIRD — FM bell voice, singing in silence =====
Ndef(\passaroSemNome, { |amp=0.18, t_trig=1, freq=880, idx=3|
    var env = Decay2.ar(K2A.ar(t_trig), 0.004, 0.55);
    var mod = SinOsc.ar(freq * 2.71) * (freq * idx);
    var car = SinOsc.ar(freq + mod);
    var sig = car * env * amp;
    Pan2.ar(sig, TRand.kr(-0.85, 0.85, t_trig));
}).play;
Ndef(\passaroSemNome).fadeTime = 4;
Ndef(\passaroSemNome)[10] = \filter -> { |in| FreeVerb.ar(in, 0.9, 0.94, 0.55) };
Ndef(\passaroSemNome).set(\wet10, 0.5);

// ===== LAYER 4: AFTERNOON SILENCE — high wind hiss + shimmer canopy =====
Ndef(\tardeSilencio, { |amp=0.1, cutoff=4200|
    var hiss = BPF.ar(WhiteNoise.ar(0.3), LFNoise1.kr(0.15).range(3000, 7000), 0.3) * 8;
    var shimmer = SinOsc.ar([2200, 3300, 4400] * SinOsc.kr(0.03).range(0.99, 1.01), 0, 0.02).sum;
    var sig = (hiss + shimmer) * amp;
    Pan2.ar(sig, LFNoise1.kr(0.1).range(-0.9, 0.9));
}).play;
Ndef(\tardeSilencio).fadeTime = 8;
Ndef(\tardeSilencio)[10] = \filter -> { |in| FreeVerb.ar(in, 0.95, 0.97, 0.6) };
Ndef(\tardeSilencio).set(\wet10, 0.6);

// ===== SEQUENCES =====
Pbindef(\rioPedrasSeq, \dur, 6, \cutoff, Pn(Pgeom(420, 1.08, 10), inf));
Ndef(\rioPedras)[1] = \set -> Pbindef(\rioPedrasSeq);
Ndef(\rioPedras).quant = 1;

Pbindef(\raLodoSeq,
    \t_trig, 1,
    \dur, Pwrand([0.5, 1.2, 2.5, 4.0], [0.4, 0.3, 0.2, 0.1], inf),
    \freq, Pexprand(120, 260, inf),
    \amp, Pwhite(0.15, 0.26, inf)
);
Ndef(\raLodo)[1] = \set -> Pbindef(\raLodoSeq);
Ndef(\raLodo).quant = 1;

Pbindef(\passaroSemNomeSeq,
    \t_trig, 1,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.6, 0.3, 0.1], inf),
    \freq, Pn(Pgeom(660, 1.12, 8), inf),
    \idx, Pwhite(1.5, 4.5, inf),
    \amp, Pwhite(0.1, 0.2, inf)
);
Ndef(\passaroSemNome)[1] = \set -> Pbindef(\passaroSemNomeSeq);
Ndef(\passaroSemNome).quant = 1;

Pbindef(\tardeSilencioSeq, \dur, 5, \cutoff, Pn(Pgeom(3500, 1.06, 8), inf));
Ndef(\tardeSilencio)[1] = \set -> Pbindef(\tardeSilencioSeq);
Ndef(\tardeSilencio).quant = 1;
)

// Ndef(\rioPedras).xset(\cutoff, 900); // Brighten river | Revert: Ndef(\rioPedras).xset(\cutoff, 520);
// Pbindef(\raLodoSeq, \dur, 0.25); // Faster frog jumps | Revert: Pbindef(\raLodoSeq, \dur, Pwrand([0.5, 1.2, 2.5, 4.0], [0.4, 0.3, 0.2, 0.1], inf));
// Ndef(\passaroSemNome).xset(\idx, 6); // Brighter bird FM | Revert: Ndef(\passaroSemNome).xset(\idx, 3);
// Ndef(\tardeSilencio).xset(\amp, 0.18); // Louder canopy | Revert: Ndef(\tardeSilencio).xset(\amp, 0.1);
// Pbindef(\rioPedrasSeq).stop; Ndef(\rioPedras).fadeTime = 6; Ndef(\rioPedras).clear(6); // Rollback river
// Pbindef(\raLodoSeq).stop; Ndef(\raLodo).fadeTime = 3; Ndef(\raLodo).clear(3); // Rollback frog
// Pbindef(\passaroSemNomeSeq).stop; Ndef(\passaroSemNome).fadeTime = 4; Ndef(\passaroSemNome).clear(4); // Rollback bird
// Pbindef(\tardeSilencioSeq).stop; Ndef(\tardeSilencio).fadeTime = 8; Ndef(\tardeSilencio).clear(8); // Rollback silence


// ============================================================
// ROUND 09 | MODE: COMPOSE | FRAG #55
// STATUS: PASS
// PROMPT: Passava da meia-noite quando as matracas de madeira começaram a bater compassadas no calçamento de p...
// ============================================================
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

s.waitForBoot({
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // ===== MATRACA: wooden clapper on cobblestone =====
    SynthDef(\matraca, { |out=0, amp=0.3, freq=420, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.15, 1, -6), doneAction: 2);
        var wood = DynKlank.ar(Ref([
            [freq, freq*2.1, freq*3.4, freq*5.2],
            [1, 0.55, 0.3, 0.15],
            [0.06, 0.04, 0.03, 0.02]
        ]), PinkNoise.ar(1) * env, 1, 0, 1);
        var click = BPF.ar(WhiteNoise.ar(1), freq*2, 0.5) * 12 * EnvGen.ar(Env.perc(0.0005, 0.02));
        var sig = MoogFF.ar((wood + click) * amp, 2400, 1.5);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ===== SINO DA SÉ: slow church bell =====
    SynthDef(\sinoSe, { |out=0, amp=0.35, freq=110, pan=0|
        var env = EnvGen.ar(Env.perc(0.003, 8, 1, -3), doneAction: 2);
        var hit = PinkNoise.ar(1) * EnvGen.ar(Env.perc(0.001, 0.02));
        var bell = DynKlank.ar(Ref([
            [freq, freq*2.01, freq*2.98, freq*4.05, freq*5.43, freq*6.79],
            [1, 0.7, 0.5, 0.35, 0.22, 0.15],
            [8, 7, 6, 5, 4, 3]
        ]), hit, 1, 0, 1);
        var body = SinOsc.ar(freq*0.5) * EnvGen.ar(Env.perc(0.01, 6)) * 0.3;
        Out.ar(out, Pan2.ar((bell + body) * env * amp, pan));
    }).add;

    // ===== PASSO: footstep on cobblestone =====
    SynthDef(\passo, { |out=0, amp=0.15, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);
        var stone = BPF.ar(PinkNoise.ar(1), 900, 0.8) * 14;
        Out.ar(out, Pan2.ar(stone * env * amp, pan));
    }).add;

    s.sync;

    // ===== VENTO DA SERRA: cold mountain wind =====
    Ndef(\ventoSerra, { |amp=0.09, cutoff=1400|
        var wind = BPF.ar(PinkNoise.ar(0.5), LFNoise1.kr(0.15).range(400, 2200), 0.4) * 10;
        var whistle = SinOsc.ar(LFNoise1.kr(0.2).range(600, 1400), 0, 0.02) * LFNoise1.kr(0.3).range(0, 1);
        Pan2.ar((wind + whistle) * amp, LFNoise1.kr(0.08).range(-0.7, 0.7));
    });
    Ndef(\ventoSerra).fadeTime = 8;
    Ndef(\ventoSerra)[10] = \filter -> { |in| FreeVerb.ar(in, 0.9, 0.95, 0.55) };
    Ndef(\ventoSerra).set(\wet10, 0.45);

    // ===== TOCHA: crackling wax torch =====
    Ndef(\tocha, { |amp=0.12|
        var crackle = Dust.ar(35) * 0.5;
        var body = BPF.ar(PinkNoise.ar(0.3), LFNoise1.kr(4).range(1200, 2800), 0.5) * 6;
        Pan2.ar((crackle + body) * amp, LFNoise1.kr(1).range(-0.6, 0.6));
    });
    Ndef(\tocha).fadeTime = 4;
    Ndef(\tocha)[10] = \filter -> { |in| FreeVerb.ar(in, 0.85, 0.9, 0.4) };
    Ndef(\tocha).set(\wet10, 0.3);

    // ===== MASTER MIX =====
    Ndef(\masterMix, {
        var sig = In.ar(~synthBus, 2);
        sig + Ndef.ar(\ventoSerra, 2) + Ndef.ar(\tocha, 2);
    }).play;
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.4) };
    Ndef(\masterMix).set(\wet10, 0.25);
    s.sync;

    // ===== SEQUENCES =====
    Pbindef(\matracaSeq,
        \instrument, \matraca, \out, ~synthBus,
        \dur, Pwrand([0.5, 0.5, 1.0, 0.25], [0.4, 0.3, 0.2, 0.1], inf),
        \freq, Pwhite(380, 520, inf),
        \amp, Pwhite(0.15, 0.3, inf),
        \pan, Pwhite(-0.7, 0.7, inf)
    );
    Pbindef(\sinoSeq,
        \instrument, \sinoSe, \out, ~synthBus,
        \dur, Pseq([4, 4, 4, 4, 8], inf),
        \freq, Pseq([110, 110, 98, 110, 82], inf),
        \amp, Pwhite(0.2, 0.35, inf),
        \pan, Pwhite(-0.3, 0.3, inf)
    );
    Pbindef(\passoSeq,
        \instrument, \passo, \out, ~synthBus,
        \dur, Pwrand([0.3, 0.3, 0.6], [0.5, 0.3, 0.2], inf),
        \amp, Pwhite(0.08, 0.18, inf),
        \pan, Pwhite(-0.5, 0.5, inf)
    );

    // ===== SCORE =====
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: sino distante, vento da serra]".postln;
        Ndef(\ventoSerra).xset(\amp, 0.05);
        Ndef(\tocha).xset(\amp, 0.0);
        Pbindef(\sinoSeq).play;
        Synth(\sinoSe, [\out, ~synthBus, \freq, 110, \amp, 0.22, \pan, 0.2]);
        15.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(600, 2400));
            1.0.wait;
        };

        "0:15 - [Cue 2: matracas se aproximam]".postln;
        Ndef(\tocha).xset(\amp, 0.06);
        Pbindef(\matracaSeq).play;
        Pbindef(\passoSeq).play;
        15.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(500, 2000));
            if (i % 3 == 0) { Synth(\sinoSe, [\out, ~synthBus, \freq, [110, 98].choose, \amp, 0.18, \pan, rrand(-0.5, 0.5)]); };
            1.2.wait;
        };

        "0:33 - [Cue 3: procissão passa, intensidade máxima]".postln;
        Ndef(\tocha).xset(\amp, 0.14);
        Pbindef(\matracaSeq, \dur, Pwrand([0.5, 0.25, 0.5, 1.0], [0.4, 0.3, 0.2, 0.1], inf));
        Pbindef(\matracaSeq, \amp, Pwhite(0.25, 0.45, inf));
        Pbindef(\passoSeq, \amp, Pwhite(0.12, 0.22, inf));
        18.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(800, 3000));
            if (i % 4 == 0) { Synth(\sinoSe, [\out, ~synthBus, \freq, [110, 82, 98].choose, \amp, 0.3, \pan, rrand(-0.6, 0.6)]); };
            1.0.wait;
        };

        "0:51 - [Cue 4: afastamento, silêncio retorna]".postln;
        Pbindef(\matracaSeq, \amp, Pwhite(0.1, 0.2, inf));
        Pbindef(\matracaSeq, \dur, Pwrand([0.75, 1.0, 1.5], [0.4, 0.4, 0.2], inf));
        Ndef(\tocha).xset(\amp, 0.05);
        15.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(400, 1600));
            1.2.wait;
        };

        "1:09 - [Cue 5: último dobre do sino]".postln;
        Pbindef(\matracaSeq).stop;
        Pbindef(\passoSeq).stop;
        Ndef(\tocha).xset(\amp, 0.0);
        Synth(\sinoSe, [\out, ~synthBus, \freq, 82, \amp, 0.4, \pan, 0]);
        10.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(300, 1200));
            1.5.wait;
        };

        "1:24 - [Cue 6: dissolução]".postln;
        Ndef(\ventoSerra).xset(\amp, 0.02);
        Pbindef(\sinoSeq).stop;
        8.do { |i|
            Ndef(\ventoSerra).xset(\cutoff, exprand(300, 900));
            1.5.wait;
        };

        "Score Complete.".postln;
        Pbindef(\matracaSeq).stop; Pbindef(\matracaSeq).clear;
        Pbindef(\sinoSeq).stop; Pbindef(\sinoSeq).clear;
        Pbindef(\passoSeq).stop; Pbindef(\passoSeq).clear;
        Ndef(\ventoSerra).clear(4);
        Ndef(\tocha).clear(4);
        Ndef(\masterMix).clear(4);
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 10 | MODE: APPEND | FRAG #155
// STATUS: PASS
// PROMPT: Eduardo subiu correndo os degraus de pedra da biblioteca pública de Belo Horizonte com o coração bat...
// ============================================================
(
// === NOVA CENA: Biblioteca Pública de Belo Horizonte ===
// Eduardo corre, coração na garganta, sineta da porta, Baudelaire, silêncio.

// --- Coração acelerado: batida pulsante (double-thump) ---
Ndef(\coracaoAcelerado, { |amp=0.5, t_trig=0, freq=48|
    var env = EnvGen.ar(Env.perc(0.002, 0.18, 1, -5), t_trig);
    var pitchEnv = EnvGen.ar(Env([1.25, 1, 0.85], [0.03, 0.18]), t_trig);
    var body = SinOsc.ar(freq * pitchEnv) * env;
    var sub = SinOsc.ar(freq * 0.5) * env * 0.6;
    var thud = LPF.ar(WhiteNoise.ar(0.3) * env, 150);
    Pan2.ar((body + sub + thud) * amp, 0);
}).play;
Ndef(\coracaoAcelerado).fadeTime = 0.5;
Ndef(\coracaoAcelerado)[10] = \filter -> { |in| FreeVerb.ar(in, 0.6, 0.85, 0.3) };
Ndef(\coracaoAcelerado).set(\wet10, 0.12);

Pbindef(\coracaoAceleradoSeq,
    \dur, Pseq([0.30, 0.13, 0.42, 0.12, 0.58], inf),
    \t_trig, 1,
    \freq, Pseq([48, 46, 48, 44, 42], inf),
    \amp, Pwhite(0.35, 0.55, inf),
    \pan, 0
);
Ndef(\coracaoAcelerado)[1] = \set -> Pbindef(\coracaoAceleradoSeq);
// Pbindef(\coracaoAceleradoSeq).stop; Ndef(\coracaoAcelerado).fadeTime = 2; Ndef(\coracaoAcelerado).clear(2); // Rollback

// --- Sineta da porta: sino pequeno, alto e cristalino ---
Ndef(\sinetaBiblioteca, { |amp=0.28, t_trig=0, freq=4200, pan=0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.001, 2.5, 1, -3), t_trig);
    var exc = trig + (PinkNoise.ar(0.4) * EnvGen.ar(Env.perc(0.0005, 0.008), t_trig));
    var bell = DynKlank.ar(Ref([
        [freq, freq*2.76, freq*5.4, freq*8.9],
        [1, 0.5, 0.25, 0.12],
        [1.8, 1.2, 0.8, 0.5]
    ]), exc, 1, 0, 1);
    var shimmer = SinOsc.ar(freq) * env * 0.08;
    Pan2.ar((bell * 0.45 + shimmer) * amp, pan);
}).play;
Ndef(\sinetaBiblioteca).fadeTime = 3;
Ndef(\sinetaBiblioteca)[10] = \filter -> { |in| FreeVerb.ar(in, 0.7, 0.9, 0.5) };
Ndef(\sinetaBiblioteca).set(\wet10, 0.35);

Pbindef(\sinetaBibliotecaSeq,
    \dur, Pseq([0.30, 5.0, 0.40, 7.5, 0.25, 4.0], inf),
    \t_trig, Pseq([1, 0, 1, 0, 1, 0], inf),
    \freq, Pwhite(3800, 4700, inf),
    \amp, Pwhite(0.14, 0.32, inf),
    \pan, Pwhite(-0.5, 0.5, inf)
);
Ndef(\sinetaBiblioteca)[1] = \set -> Pbindef(\sinetaBibliotecaSeq);
// Pbindef(\sinetaBibliotecaSeq).stop; Ndef(\sinetaBiblioteca).fadeTime = 2; Ndef(\sinetaBiblioteca).clear(2); // Rollback

// --- Porta de carvalho: rangido grave e pesado ---
Ndef(\portaCarvalho, { |amp=0.32, t_trig=0, freq=120|
    var env = EnvGen.ar(Env.perc(0.2, 2.5, 1, -2), t_trig);
    var creakRate = LFNoise1.kr(2).range(300, 1200);
    var creak = BPF.ar(PinkNoise.ar(1), creakRate, 0.15) * 20 * env;
    var wood = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.001, 0.8, 1, -4), t_trig) * 0.6;
    var thud = LPF.ar(WhiteNoise.ar(0.8) * EnvGen.ar(Env.perc(0.001, 0.15, 1, -6), t_trig), 300);
    Pan2.ar((creak + wood + thud) * amp, 0);
}).play;
Ndef(\portaCarvalho).fadeTime = 3;
Ndef(\portaCarvalho)[10] = \filter -> { |in| FreeVerb.ar(in, 0.85, 0.92, 0.55) };
Ndef(\portaCarvalho).set(\wet10, 0.3);

Pbindef(\portaCarvalhoSeq,
    \dur, Pseq([0.1, 11, 8], inf),
    \t_trig, Pseq([1, 0, 0], inf),
    \freq, Pseq([120, 100, 132], inf),
    \amp, Pwhite(0.25, 0.4, inf)
);
Ndef(\portaCarvalho)[1] = \set -> Pbindef(\portaCarvalhoSeq);
// Pbindef(\portaCarvalhoSeq).stop; Ndef(\portaCarvalho).fadeTime = 2; Ndef(\portaCarvalho).clear(2); // Rollback

// --- Páginas de Baudelaire: folhear suave de papel ---
Ndef(\paginasBaudelaire, { |amp=0.18, t_trig=0, pan=0|
    var env = EnvGen.ar(Env.perc(0.01, 0.35, 1, -4), t_trig);
    var brush = BPF.ar(PinkNoise.ar(1), 4500, 0.8) * 4;
    var crinkle = HPF.ar(WhiteNoise.ar(0.3), 3500) * EnvGen.ar(Env.perc(0.001, 0.05), t_trig);
    Pan2.ar((brush * env + crinkle) * amp, pan);
}).play;
Ndef(\paginasBaudelaire).fadeTime = 2;
Ndef(\paginasBaudelaire)[10] = \filter -> { |in| FreeVerb.ar(in, 0.75, 0.9, 0.4) };
Ndef(\paginasBaudelaire).set(\wet10, 0.25);

Pbindef(\paginasBaudelaireSeq,
    \dur, Pwhite(0.6, 1.4, inf),
    \t_trig, 1,
    \amp, Pwhite(0.08, 0.18, inf),
    \pan, Pwhite(-0.5, 0.5, inf)
);
Ndef(\paginasBaudelaire)[1] = \set -> Pbindef(\paginasBaudelaireSeq);
// Pbindef(\paginasBaudelaireSeq).stop; Ndef(\paginasBaudelaire).fadeTime = 2; Ndef(\paginasBaudelaire).clear(2); // Rollback

// --- Silêncio do salão: drone sutil do ar da biblioteca ---
Ndef(\silencioSala, { |amp=0.075|
    var room = BPF.ar(PinkNoise.ar(0.3), 300, 0.6) * 8;
    var air = BPF.ar(PinkNoise.ar(0.12), LFNoise1.kr(0.07).range(800, 2000), 0.9) * 4;
    var hum = (SinOsc.ar(50) * 0.4 + SinOsc.ar(60) * 0.25) * LFNoise1.kr(0.05).range(0.6, 1);
    Pan2.ar((room + air + hum) * amp, LFNoise1.kr(0.04).range(-0.4, 0.4));
}).play;
Ndef(\silencioSala).fadeTime = 6;
Ndef(\silencioSala)[10] = \filter -> { |in| FreeVerb.ar(in, 0.98, 0.97, 0.7) };
Ndef(\silencioSala).set(\wet10, 0.6);
// Ndef(\silencioSala).fadeTime = 6; Ndef(\silencioSala).clear(6); // Rollback
)

