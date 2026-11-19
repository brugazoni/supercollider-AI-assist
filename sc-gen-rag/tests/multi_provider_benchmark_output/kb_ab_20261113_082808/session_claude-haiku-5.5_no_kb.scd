// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-13T11:36:01.364971+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: storm - tempestade antártica latente (drone de ruído que sustenta a tensão do silêncio)
Ndef(\storm, {
    var swell, cut, sig;
    swell = LFNoise2.kr(0.05).range(0.15, 0.55);
    cut = LFNoise2.kr(0.08).exprange(120, 900);
    sig = BrownNoise.ar(0.6) + PinkNoise.ar(0.15);
    sig = LPF.ar(sig, cut) * swell;
    Pan2.ar(sig, LFNoise2.kr(0.03), 0.8);
}).play;
// Rollback: remove this instrument
// Ndef(\storm).fadeTime = 2; Ndef(\storm).clear(2);

// ADD_INSTRUMENT: paper - dobras do mapa rodoviário (crepitar irregular, pequenas ruturas no silêncio)
Ndef(\paper, { |t_trig=0, amp=0.4, pan=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.12, 1, -6), t_trig);
    sig = BPF.ar(WhiteNoise.ar, 2500, 0.3) * 8.0;
    sig = sig * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\paperSeq,
    \dur, Prand([0.25, 0.5, 1.25, 2.5], inf),
    \t_trig, 1,
    \amp, Pexprand(0.1, 0.45, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
).play;

Ndef(\paper)[1] = \set -> Pbindef(\paperSeq);
// Rollback: remove this instrument
// Pbindef(\paperSeq).stop; Ndef(\paper).fadeTime = 2; Ndef(\paper).clear(2);

// ADD_INSTRUMENT: glass - garrafa de vinho suspensa no ar (tom de vidro raro, longo, quase imóvel)
Ndef(\glass, { |t_trig=0, freq=196, amp=0.25, pan=0|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.001, 4.5), t_trig);
    sig = SinOsc.ar(freq * [1, 2.76, 5.4], 0, [1, 0.4, 0.15]).sum;
    sig = sig * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\glassSeq,
    \dur, Pseq([8, 12], inf),
    \freq, Pseq([196, 146.83], inf),
    \t_trig, 1,
    \amp, 0.25,
    \pan, 0
).play;

Ndef(\glass)[1] = \set -> Pbindef(\glassSeq);
// Rollback: remove this instrument
// Pbindef(\glassSeq).stop; Ndef(\glass).fadeTime = 2; Ndef(\glass).clear(2);
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

    // Safety limiter
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete voices
    SynthDef(\escapeTick, { |freq=2400, amp=0.3, out=0, decay=0.03|
        var env, noise, sig;
        env = EnvGen.ar(Env.perc(0.0005, decay), doneAction: 2);
        noise = HPF.ar(WhiteNoise.ar, 3000) * 0.6 * env;
        sig = Ringz.ar(noise, freq, 0.03) + (Ringz.ar(noise, freq * 2.37, 0.02) * 0.4);
        Out.ar(out, Pan2.ar(sig * amp, LFNoise1.kr(0.2)));
    }).add;

    SynthDef(\pendKnock, { |freq=110, amp=0.25, out=0, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, 0.25, 1, -5), doneAction: 2);
        sig = Ringz.ar(Impulse.ar(0), [freq, freq * 2.76], [0.6, 0.3]).sum * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\chime, { |freq=660, amp=0.2, out=0|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.005, 3.5, 1, -4), doneAction: 2);
        mod = SinOsc.ar(freq * 3.51) * freq * 1.8 * EnvGen.ar(Env.perc(0.001, 0.4));
        sig = SinOsc.ar(freq + mod) * env * amp;
        Out.ar(out, Pan2.ar(sig, 0));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\breath, { |amp=0|
        var body, env;
        body = SinOsc.ar(55 * [1, 1.003], 0, 0.2).sum + LPF.ar(PinkNoise.ar(0.15), 180);
        env = LFNoise2.kr(0.04).range(0.1, 0.9);
        Pan2.ar(body * env * amp, 0);
    });
    Ndef(\breath).fadeTime = 4;

    Ndef(\murmur, { |amp=0|
        var clicks, sig, swell;
        clicks = Mix.fill(24, { |i|
            Impulse.ar(2.0 + (i * 0.0137)) * LFNoise1.kr(0.5 + (i * 0.01)).range(0.05, 0.3)
        });
        sig = BPF.ar(clicks, 2800, 0.5) * 12;
        swell = LFNoise1.kr(0.1).range(0.3, 1);
        Pan2.ar(sig * swell * amp, LFNoise1.kr(0.05));
    });
    Ndef(\murmur).fadeTime = 3;

    // Sequences
    Pbindef(\clockSeq,
        \instrument, \escapeTick,
        \dur, Pn(Pseq([0.5, 0.5, 0.5137, 0.4863, 0.5019], 1), inf),
        \freq, Pwhite(1800.0, 3200.0, inf),
        \amp, Pexprand(0.04, 0.12, inf),
        \decay, 0.03,
        \out, ~synthBus
    );

    Pbindef(\pendSeq,
        \instrument, \pendKnock,
        \dur, Pseq([2.0, 2.0, 2.0, 2.02], inf),
        \freq, Pseq([110, 110, 112.5], inf),
        \amp, 0.25,
        \pan, Pwhite(-0.4, 0.4, inf),
        \out, ~synthBus
    );

    // Master mixer
    Ndef(\masterMix, {
        var bus, extra;
        bus = In.ar(~synthBus, 2);
        extra = Ndef(\murmur).ar(2) + Ndef(\breath).ar(2);
        (bus + extra).tanh;
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25) };
    Ndef(\masterMix).set(\wet10, 0.3);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        var d;
        0.5.wait;

        "0:00 - [Cue 1: Respiração do tempo, o ar da oficina]".postln;
        Ndef(\breath).play;
        Ndef(\breath).xset(\amp, 0.5);
        6.wait;

        "0:06 - [Cue 2: Murmúrio dos duzentos relógios]".postln;
        Ndef(\murmur).play;
        Ndef(\murmur).xset(\amp, 0.35);
        Pbindef(\pendSeq).play;
        8.wait;

        "0:14 - [Cue 3: Entram os tiques, defasagens microscópicas]".postln;
        Pbindef(\clockSeq).play;
        5.do { |i|
            Ndef(\breath).xset(\amp, exprand(0.3, 0.7));
            2.wait;
        };

        "0:24 - [Cue 4: Limite intrínseco, aceleração até a densidade extrema]".postln;
        4.do { |i|
            d = 0.5 * ((0.12 / 0.5) ** (i / 3.0));
            Pbindef(\clockSeq, \dur, Pn(Pseq([d, d, d * 1.0274, d * 0.9726, d * 1.0095], inf)));
            2.5.wait;
        };

        "0:34 - [Cue 5: Corte seco e carrilhão]".postln;
        Pbindef(\clockSeq).stop;
        3.do { |i|
            Synth(\chime, [\freq, [660, 880, 495][i], \out, ~synthBus]);
            1.5.wait;
        };

        "0:40 - [Cue 6: Assentamento, tiques esparsos e frágeis]".postln;
        Pbindef(\clockSeq, \dur, Pseq([1.7, 2.3, 1.9], inf));
        Pbindef(\clockSeq).play;
        Ndef(\murmur).xset(\amp, 0.1);
        8.wait;
        Pbindef(\clockSeq, \dur, Pseq([1.3, 2.7, 2.1], inf));
        8.wait;

        "0:56 - [Cue 7: Resolução, retorno ao motivo inicial]".postln;
        Pbindef(\clockSeq, \dur, Pn(Pseq([0.5, 0.5, 0.5137, 0.4863, 0.5019], 1), inf));
        Ndef(\murmur).xset(\amp, 0.35);
        Ndef(\breath).xset(\amp, 0.5);
        8.wait;
        6.wait;

        "1:10 - [Cue 8: Flashback ao carrilhão e ao murmúrio]".postln;
        Synth(\chime, [\freq, 660, \out, ~synthBus]);
        Ndef(\murmur).xset(\amp, 0.5);
        8.wait;

        "1:20 - [Cue 9: Finale extrínseco, o relógio para]".postln;
        Ndef(\murmur).xset(\amp, 0.0);
        Ndef(\breath).xset(\amp, 0.0);
        Pbindef(\pendSeq).stop;
        Pbindef(\clockSeq).stop;
        6.wait;

        Pbindef(\clockSeq).stop; Pbindef(\clockSeq).clear;
        Pbindef(\pendSeq).stop; Pbindef(\pendSeq).clear;
        Ndef(\murmur).clear(2);
        Ndef(\breath).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: PASS
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Step 0: CC map
~cc = (
    vol1: 1, pan1: 2, mute1: 3, min1: 4, max1: 5, hpf1: 6, lpf1: 7, rq1: 8, atk1: 9, dec1: 10, sus1: 11, rls1: 12, fxPressure: 13,
    vol2: 14, pan2: 15, mute2: 16, min2: 17, max2: 18, hpf2: 19, lpf2: 20, rq2: 21, atk2: 22, dec2: 23, sus2: 24, rls2: 25, fxFriction: 26,
    vol3: 27, pan3: 28, mute3: 29, min3: 30, max3: 31, hpf3: 32, lpf3: 33, rq3: 34, atk3: 35, dec3: 36, sus3: 37, rls3: 38, fxLipid: 39,
    delMix: 40, verbMix: 41, panic: 42
);

// Step 1 & 2: MIDI discovery
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

// Step 3: Boot, state, synths, GUI
s.waitForBoot({
    var zoneNames;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 127, hpf1: 60.0, lpf1: 4000.0, rq1: 0.5, atk1: 0.01, dec1: 0.5, sus1: 0.7, rls1: 1.0, fxPressure: 0.0,
        vol2: 0.2, pan2: -0.35, mute2: 0.0, min2: 0, max2: 127, hpf2: 350.0, lpf2: 6500.0, rq2: 0.4, atk2: 0.002, dec2: 0.4, sus2: 0.0, rls2: 0.6, fxFriction: 0.0,
        vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 0, max3: 127, hpf3: 160.0, lpf3: 3200.0, rq3: 0.6, atk3: 1.5, dec3: 2.0, sus3: 0.8, rls3: 3.0, fxLipid: 0.0,
        delMix: 0.0, verbMix: 0.0, panic: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.newClear(128);

    SynthDef(\lissZone1, { |out=0, freq=110, gate=1, vol=0.2, pan=0, hpf=60, lpf=4000, rq=0.5, atk=0.01, dec=0.5, sus=0.7, rls=1, fxPressure=0, mute=0|
        var env, mod, car, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 1.01) * (freq * (1.5 + (fxPressure * 4.0)));
        car = SinOsc.ar(freq + mod) + Fold.ar(SinOsc.ar(freq * 0.5) * (1.0 + (fxPressure * 5.0)), -0.8, 0.8) * 0.4;
        sig = HPF.ar(LPF.ar(car, lpf), hpf) * env * vol * (1 - mute);
        Out.ar(out, Balance2.ar(sig, sig, pan));
    }).add;

    SynthDef(\lissZone2, { |out=0, freq=440, gate=1, vol=0.2, pan=(-0.35), hpf=350, lpf=6500, rq=0.4, atk=0.002, dec=0.4, sus=0, rls=0.6, fxFriction=0, mute=0|
        var env, sig, comb;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        comb = CombL.ar(WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02)), 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.5);
        sig = AllpassC.ar(comb, 0.02, (fxFriction * 0.008) + 0.0005, 0.08);
        sig = HPF.ar(RLPF.ar(sig, lpf, rq), hpf) * env * vol * (1 - mute);
        Out.ar(out, Balance2.ar(sig, sig, pan));
    }).add;

    SynthDef(\lissZone3, { |out=0, freq=220, gate=1, vol=0.18, pan=0.35, hpf=160, lpf=3200, rq=0.6, atk=1.5, dec=2, sus=0.8, rls=3, fxLipid=0, mute=0|
        var env, sig, cut;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        cut = lpf * (1.0 - (fxLipid * 0.8));
        sig = Splay.ar(Saw.ar(freq * [0.98, 0.99, 1, 1.01, 1.02]));
        sig = MoogFF.ar(sig, cut, 0.2);
        sig = (sig * 4.0).tanh * env * vol * (1 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    SynthDef(\lissFX, { |in=0, out=0, delMix=0, verbMix=0|
        var sig = In.ar(in, 2);
        var del = CombL.ar(sig, 0.5, 0.25, 2.0) * delMix;
        var rev = FreeVerb2.ar(sig[0], sig[1], verbMix, 0.85, 0.25);
        Out.ar(out, (sig + del + rev).tanh);
    }).add;

    s.sync;

    ~fxSynth = Synth.new(\lissFX, [\in, 0, \out, 0, \delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap], ~masterGroup, \addToTail);

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
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\zoneOn, { |vel, noteNum|
        var zones = [
            [\lissZone1, 0, 65, \vol1, \pan1, \hpf1, \lpf1, \rq1, \atk1, \dec1, \sus1, \rls1, \fxPressure, \min1, \max1],
            [\lissZone2, 36, 100, \vol2, \pan2, \hpf2, \lpf2, \rq2, \atk2, \dec2, \sus2, \rls2, \fxFriction, \min2, \max2],
            [\lissZone3, 30, 127, \vol3, \pan3, \hpf3, \lpf3, \rq3, \atk3, \dec3, \sus3, \rls3, \fxLipid, \min3, \max3]
        ];
        zones.do { |z|
            if((noteNum >= ~ccVals[z[13]]) and: { noteNum <= ~ccVals[z[14]] }) {
                if((noteNum >= z[1]) and: { noteNum <= z[2] }) {
                    var f = noteNum.midicps;
                    var syn = Synth(z[0], [\freq, f, \gate, 1, \vol, ~ccVals[z[3]], \pan, ~ccVals[z[4]],
                        \hpf, ~ccVals[z[5]], \lpf, ~ccVals[z[6]], \rq, ~ccVals[z[7]],
                        \atk, ~ccVals[z[8]], \dec, ~ccVals[z[9]], \sus, ~ccVals[z[10]], \rls, ~ccVals[z[11]],
                        \fxPressure, ~ccVals[z[12]], \fxFriction, ~ccVals[z[12]], \fxLipid, ~ccVals[z[12]]], ~synthGroup);
                    ~zoneNotes[noteNum] = (~zoneNotes[noteNum] ?? { [] }).add(syn);
                };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\zoneOff, { |vel, noteNum|
        if(~zoneNotes[noteNum].notNil) {
            ~zoneNotes[noteNum].do(_.set(\gate, 0));
            ~zoneNotes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val, num|
        if(val > 63) {
            ~zoneNotes.do { |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } };
            ~zoneNotes = Array.newClear(128);
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var zoneMeta = [
            (title: "Zone 1: Sub Body", fxKey: \fxPressure, fxLabel: "Pressure"),
            (title: "Zone 2: Lissajous Pluck", fxKey: \fxFriction, fxLabel: "Friction"),
            (title: "Zone 3: CRT Canopy", fxKey: \fxLipid, fxLabel: "Lipid")
        ];
        var screen = Window.availableBounds;
        var winH = min(780, screen.height - 60);
        var pages = [];
        if(~mainWin.notNil) { ~mainWin.close };
        ~ui = ();
        ~mainWin = Window("Oscilloscope Modular", Rect((screen.width - 620) / 2, (screen.height - winH) / 2, 620, winH), scroll: true);
        ~mainWin.background = Color.new(0.08, 0.1, 0.09);
        ~mainWin.front;
        zoneMeta.do { |zm, idx|
            var page = CompositeView(~mainWin, Rect(10, 10, 600, winH - 120));
            var pgTitle = StaticText(page, Rect(10, 6, 580, 24)).string_(zm[\title]).stringColor_(Color.green(0.8));
            var base = (idx + 1).asString;
            var prefix = "vol" ++ base;
            [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls].do { |p, j|
                var key = (p ++ base).asSymbol;
                var ccNum = ~cc[key];
                var ez = EZSlider(page, Rect(10, 40 + (j * 40), 580, 36), "% (CC %)".format(key, ccNum), ControlSpec(0, 1, \lin));
                ez.action = { |sl| ~ccVals[key] = sl.value; if(~buses[key].notNil) { ~buses[key].set(sl.value) } };
                ~ui[key] = ez;
            };
            pages = pages.add(page);
        };
        ~mainWin.onClose = { ~ui = nil };
        Button(~mainWin, Rect(10, winH - 100, 300, 30)).states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({ ~zoneNotes.do { |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } }; ~zoneNotes = Array.newClear(128) });
        EZSlider(~mainWin, Rect(10, winH - 60, 290, 24), "Delay", ControlSpec(0, 1, \lin))
            .action_({ |sl| ~ccVals[\delMix] = sl.value; ~buses.delMix.set(sl.value) });
        EZSlider(~mainWin, Rect(310, winH - 60, 290, 24), "Reverb", ControlSpec(0, 1, \lin))
            .action_({ |sl| ~ccVals[\verbMix] = sl.value; ~buses.verbMix.set(sl.value) });
    };

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
});
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Bombo: low congada drum with pitch drop and a quiet tuned drone
Ndef(\bombo).fadeTime = 2;
Ndef(\bombo, { |t_trig=0, freq=55, amp=0.22, drone=0.05|
    var drumEnv, pitchEnv, drum, hum, sig;
    drumEnv = EnvGen.ar(Env.perc(0.004, 0.7, 1, -5), t_trig);
    pitchEnv = EnvGen.ar(Env.perc(0.001, 0.09, 1, -6), t_trig);
    drum = SinOsc.ar(freq * (1 + (pitchEnv * 1.2))) * drumEnv;
    drum = drum + (SinOsc.ar(freq * 2.01) * drumEnv * 0.12);
    hum = SinOsc.ar(freq * [1, 1.005]).sum * drone * SinOsc.kr(0.07).range(0.6, 1);
    sig = ((drum * amp) + hum).tanh;
    Pan2.ar(LeakDC.ar(sig), 0, 1)
}).play;

Pbindef(\bomboSeq,
    \dur, Pseq([1, 0.5, 0.5, 0.75, 0.25, 0.25, 1], inf),
    \freq, Pseq([55, 55, 65, 49, 55, 73.42, 55], inf),
    \amp, 0.2,
    \t_trig, 1
);
Ndef(\bombo).quant = 1;
Ndef(\bombo)[1] = \set -> Pbindef(\bomboSeq);

// Gungas: tin-ankle metallic jingles via excited resonator bank
Ndef(\gunga).fadeTime = 2;
Ndef(\gunga, { |t_trig=0, pan=0, tone=1, amp=0.14|
    var exc, metal, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.0005, 0.012) * WhiteNoise.ar(1);
    metal = Ringz.ar(exc, [2480, 3725, 5230] * tone, [0.22, 0.16, 0.09]).sum;
    sig = (metal * 3 * amp).tanh;
    Pan2.ar(HPF.ar(sig, 900), pan, 1)
}).play;

Pbindef(\gungaSeq,
    \dur, Pwrand([0.25, 0.5, 0.125], [0.6, 0.3, 0.1], inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \tone, Pwrand([1, 1.12, 0.9], [0.6, 0.25, 0.15], inf),
    \amp, Pexprand(0.08, 0.16, inf),
    \t_trig, 1
);
Ndef(\gunga).quant = 1;
Ndef(\gunga)[1] = \set -> Pbindef(\gungaSeq);
Ndef(\gunga)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.5) };
Ndef(\gunga).set(\wet10, 0.3);

// Congo drum: pitched body with noise slap, call-and-response panning
Ndef(\congo).fadeTime = 2;
Ndef(\congo, { |t_trig=0, freq=220, pan=(-0.3), amp=0.18|
    var env, body, slap, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.28, 1, -6), t_trig);
    body = SinOsc.ar(freq * (1 + (EnvGen.ar(Env.perc(0.001, 0.05, 1, -8), t_trig) * 0.8))) * env;
    slap = BPF.ar(WhiteNoise.ar, 1800, 0.4) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.03) * 4;
    sig = ((body + slap) * amp).tanh;
    Pan2.ar(sig, pan, 1)
}).play;

Pbindef(\congoSeq,
    \dur, Pseq([0.5, 0.5, 1, 0.5, 0.5, 0.5, 1.5], inf),
    \freq, Pseq([196, 220, 196, 261.63, 220, 196, 174.61], inf),
    \pan, Pseq([-0.35, 0.35], inf),
    \amp, 0.2,
    \t_trig, 1
);
Ndef(\congo).quant = 1;
Ndef(\congo)[1] = \set -> Pbindef(\congoSeq);
Ndef(\congo)[10] = \filter -> { |in| CombC.ar(in, 0.25, 0.23, 1.2) + in };
Ndef(\congo).set(\wet10, 0.2);

// Canopy: warm detuned saw bed with slow filter breathing
Ndef(\canopy).fadeTime = 4;
Ndef(\canopy, { |cutoff=700, amp=0.05|
    var lfo, sig;
    lfo = SinOsc.kr(0.05).range(0.7, 1.0);
    sig = Splay.ar(Saw.ar(110 * [0.99, 1, 1.01, 1.5]));
    sig = LPF.ar(sig, cutoff * lfo);
    sig * amp
}).play;
Ndef(\canopy)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.6) };
Ndef(\canopy).set(\wet10, 0.4);

// Live tweaks and rollbacks
// Ndef(\gunga).xset(\tone, 1.3); // Higher metal | Revert: Ndef(\gunga).xset(\tone, 1);
// Pbindef(\congoSeq, \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.75], inf)); // Double-time | Revert: Pbindef(\congoSeq, \dur, Pseq([0.5, 0.5, 1, 0.5, 0.5, 0.5, 1.5], inf));
// Ndef(\canopy).xset(\cutoff, 1400); // Brighter bed | Revert: Ndef(\canopy).xset(\cutoff, 700);
// Pbindef(\bomboSeq, \amp, 0.3); // Heavier bombo | Revert: Pbindef(\bomboSeq, \amp, 0.2);
// Pbindef(\gungaSeq).stop; Ndef(\gunga).fadeTime = 4; Ndef(\gunga).clear(4); // Rollback
)

