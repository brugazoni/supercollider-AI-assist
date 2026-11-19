// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-13T11:42:00.655440+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\mapFold, { |freq=220, amp=0.12, pan=0, t_trig=0, cutoff=1800|
    var env = EnvGen.ar(Env.perc(0.003, 0.22, 1, -5), t_trig);
    var click = SinOsc.ar(freq * [1, 2.013], [0, 0.2]).sum;
    var fold = (click * 3).fold2(0.8);
    var sig = RLPF.ar(fold, cutoff, 0.18);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([1.5, 1.5, 0.75, 0.75, 0.375, 0.375, 0.75], inf),
    \freq, Pseq([330, 247, 294, 220, 330, 262, 196], inf),
    \cutoff, Pseq([1100, 1300, 900, 1600, 2200, 1200, 700], inf),
    \pan, Pwhite(-0.55, 0.55, inf),
    \amp, Pseq([0.08, 0.07, 0.09, 0.06, 0.1, 0.07, 0.05], inf),
    \t_trig, 1
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// Rollback: remove this instrument
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);

Ndef(\antarcticSilence, { |freq=55, amp=0.08, pan=0, t_trig=0, drift=0.15|
    var env = EnvGen.ar(Env.perc(0.2, 4.5, 1, -4), t_trig);
    var wind = SinOsc.kr(0.07).range(0.7, 1.3);
    var low = SinOsc.ar(freq * wind);
    var overtone = SinOsc.ar(freq * 2.01, 0, 0.35);
    var hiss = BPF.ar(WhiteNoise.ar, freq * 8, 0.3) * 0.12;
    var sig = (low + overtone + hiss) * env;
    Pan2.ar(sig * amp, pan + (SinOsc.kr(drift) * 0.25));
}).play;

Pbindef(\antarcticSeq,
    \dur, Pseq([3, 3, 2, 4], inf),
    \freq, Pseq([55, 55, 58.27, 51.91, 55], inf),
    \amp, Pseq([0.06, 0.07, 0.08, 0.09, 0.06], inf),
    \drift, Pseq([0.11, 0.17, 0.09, 0.21], inf),
    \pan, Pseq([0.15, -0.12, 0.08, -0.18], inf),
    \t_trig, 1
);
Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSeq);

// Blurring the growing silence into a distant, cold room; wetness starts closed.
Ndef(\antarcticSilence)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 0.82, 0.94, 0.35);
};
Ndef(\antarcticSilence).set(\wet10, 0);

// Rollback: remove this instrument
// Pbindef(\antarcticSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2);
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var master;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\clockworkTick, { |out=0, freq=2200, amp=0.08, pan=0, dur=0.16, tone=0.3|
        var env = EnvGen.ar(Env.perc(0.001, dur.max(0.05), 1, -8), doneAction: 2);
        var strike = WhiteNoise.ar(0.7) + SinOsc.ar(freq, 0, tone);
        var body = Ringz.ar(strike, [freq * 0.71, freq, freq * 1.49], [0.035, 0.06, 0.11]).sum;
        var sig = (strike * 0.12 + body * 0.35) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\clockworkChime, { |out=0, freq=660, amp=0.07, pan=0, dur=1.5|
        var env = EnvGen.ar(Env.perc(0.004, dur.max(0.05), 1, -4), doneAction: 2);
        var strike = Impulse.ar(0) + (WhiteNoise.ar(0.15) * EnvGen.ar(Env.perc(0.001, 0.025)));
        var modes = DynKlank.ar(Ref([[1, 2.37, 3.91, 5.44], [1, 0.42, 0.21, 0.11], [1.2, 0.8, 0.45, 0.3]]), strike, freq, decayscale: dur);
        Out.ar(out, Pan2.ar(modes * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\escapementAir, { |amp=0, rate=2.7, spread=0.7|
        var pulse = Impulse.kr(rate + (SinOsc.kr(0.13).range(-0.035, 0.035)));
        var tick = Decay2.ar(K2A.ar(pulse), 0.001, 0.045) * WhiteNoise.ar(0.35);
        var hum = SinOsc.ar([110, 110.7], 0, 0.018);
        var metal = Ringz.ar(tick, [1700, 2480], [0.05, 0.075]);
        Splay.ar([hum[0] + metal[0], hum[1] + metal[1]], spread, amp);
    });
    Ndef(\escapementAir).fadeTime = 3;
    Ndef(\escapementAir).set(\amp, 0);

    Ndef(\masterMix, {
        var events = In.ar(~synthBus, 2);
        var air = Ndef.ar(\escapementAir, 2);
        (events + air) * 0.72;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.28);
    };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\oficinaTicks,
        \instrument, \clockworkTick,
        \out, ~synthBus,
        \dur, Pseq([0.5, 0.5, 0.48, 0.52, 0.25, 0.25, 0.5, 0.75], inf),
        \freq, Pseq([2100, 2460, 1950, 2780, 2320, 1850, 2600, 2200], inf),
        \tone, Pseq([0.18, 0.24, 0.12, 0.28, 0.15, 0.31, 0.2, 0.16], inf),
        \dur, Pseq([0.11, 0.14, 0.12, 0.16, 0.09, 0.12, 0.15, 0.18], inf),
        \amp, Pseq([0.045, 0.055, 0.04, 0.06, 0.05, 0.04, 0.055, 0.045], inf),
        \pan, Pwhite(-0.9, 0.9, inf)
    );

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - Latão desperta: um pulso central, muitos tempos vizinhos.".postln;
        Ndef(\escapementAir).xset(\amp, 0.045, \rate, 2.4);
        Pbindef(\oficinaTicks).play;
        Ndef(\masterMix).set(\wet10, 0.12);
        5.wait;

        "0:05 - Escapamentos desalinhados; o tique atravessa a oficina.".postln;
        Pbindef(\oficinaTicks,
            \dur, Pseq([0.25, 0.5, 0.375, 0.25, 0.75, 0.375], inf),
            \freq, Pseq([2600, 1980, 3140, 2210, 1760, 2860], inf),
            \amp, Pseq([0.045, 0.06, 0.04, 0.055, 0.05, 0.045], inf)
        );
        4.do { |i|
            Ndef(\escapementAir).xset(\rate, 2.5 + (i * 0.22), \spread, 0.4 + (i * 0.12));
            Ndef(\masterMix).set(\wet10, 0.12 + (i * 0.04));
            2.wait;
        };

        "0:13 - Carrilhão francês: brilho modal sobre a engrenagem.".postln;
        Pbindef(\oficinaTicks).stop;
        0.25.wait;
        Pbindef(\oficinaChimes,
            \instrument, \clockworkChime,
            \out, ~synthBus,
            \dur, Pseq([2, 1.5, 2.5, 1], inf),
            \freq, Pseq([523, 659, 784, 587, 698, 880], inf),
            \amp, Pseq([0.045, 0.06, 0.05, 0.055, 0.04, 0.05], inf),
            \pan, Pseq([-0.55, 0.35, 0.65, -0.25, 0.2, -0.7], inf)
        ).play;
        Ndef(\escapementAir).xset(\amp, 0.025, \rate, 3.5);
        Ndef(\masterMix).set(\wet10, 0.38);
        6.wait;

        "0:19 - Limite: os tiques apertam, quase fundidos num único mecanismo.".postln;
        Pbindef(\oficinaChimes).stop;
        Pbindef(\oficinaTicks,
            \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.375], inf),
            \freq, Pseq([3100, 2250, 3450, 1880, 2700], inf),
            \amp, Pseq([0.035, 0.04, 0.05, 0.035, 0.045], inf)
        ).play;
        4.do { |i|
            Ndef(\escapementAir).xset(\rate, 4.2 + (i * 0.5));
            1.5.wait;
        };

        "0:25 - Flashback: resta o respirar entre duas engrenagens.".postln;
        Pbindef(\oficinaTicks).stop;
        Ndef(\escapementAir).xset(\amp, 0.035, \rate, 1.7, \spread, 0.2);
        Ndef(\masterMix).set(\wet10, 0.5);
        5.wait;

        "0:30 - Resolução: o pulso retorna, agora quase em uníssono.".postln;
        Pbindef(\oficinaTicks,
            \dur, Pseq([0.5, 0.5, 0.5, 1], inf),
            \freq, Pseq([2200, 2200, 2210, 2200], inf),
            \amp, Pseq([0.04, 0.035, 0.04, 0.025], inf)
        ).play;
        Ndef(\escapementAir).xset(\amp, 0.018, \rate, 2.0);
        Ndef(\masterMix).set(\wet10, 0.22);
        5.wait;

        "0:35 - Corte: o tempo segue, fora da oficina.".postln;
        Pbindef(\oficinaTicks).stop;
        Pbindef(\oficinaTicks).clear;
        Pbindef(\oficinaChimes).stop;
        Pbindef(\oficinaChimes).clear;
        Ndef(\escapementAir).clear(2);
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
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
    delMix: 60, verbMix: 61, panic: 123
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

s.waitForBoot({
    var zoneMeta, keyLists;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 70, hpf1: 25, lpf1: 180,
        rq1: 0.7, atk1: 0.01, dec1: 0.4, sus1: 0.7, rls1: 0.5, fx1: 0.0,
        vol2: 0.18, pan2: 0.35, mute2: 0.0, min2: 38, max2: 127, hpf2: 350, lpf2: 6500,
        rq2: 0.6, atk2: 0.005, dec2: 0.5, sus2: 0.0, rls2: 0.7, fx2: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });
    ~voices = List.new;

    SynthDef(\scopeCore, { |out=0, freq=110, gate=1, vol=0.22, pan=0, mute=0, hpf=25, lpf=180, rq=0.7, atk=0.01, dec=0.4, sus=0.7, rls=0.5, fx=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * (2.0 + (fx * 2.71)), 0, freq * (0.3 + (fx * 5)));
        sig = (SinOsc.ar(freq + mod) * 0.7) + (SinOscFB.ar(freq * 0.501, fx * 0.7) * 0.3);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1));
        sig = HPF.ar(sig, hpf.clip(20, 10000)) * env * vol * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\scopeTrace, { |out=0, freq=440, gate=1, vol=0.18, pan=0.35, mute=0, hpf=350, lpf=6500, rq=0.6, atk=0.005, dec=0.5, sus=0, rls=0.7, fx=0|
        var env, exc, sig, fold;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = WhiteNoise.ar(0.3) * EnvGen.kr(Env.perc(0.001, 0.025));
        sig = DynKlank.ar(Ref([[1, 2.71, 4.13, 6.8], [1, 0.55, 0.32, 0.2], [1.2, 0.8, 0.55, 0.3]]), exc + (SinOsc.ar(freq * 1.003) * 0.08), freqscale: freq);
        fold = Fold.ar(sig * (1 + (fx * 4)), -0.8, 0.8);
        sig = AllpassC.ar(fold, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1));
        sig = HPF.ar(sig, hpf.clip(20, 10000)) * env * vol * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\scopeDelay, { |in=0, out=0, mix=0|
        var dry, wet;
        dry = In.ar(in, 2);
        wet = CombC.ar(dry, 1.0, 0.27, 2.5);
        Out.ar(out, XFade2.ar(dry, wet, (mix.clip(0, 1) * 2) - 1));
    }).add;
    SynthDef(\scopeVerb, { |in=0, out=0, mix=0|
        var dry;
        dry = In.ar(in, 2);
        Out.ar(out, FreeVerb2.ar(dry[0], dry[1], mix.clip(0, 1), 0.82, 0.35));
    }).add;
    SynthDef(\scopeMaster, { |in=0|
        var sig;
        sig = LeakDC.ar(In.ar(in, 2));
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    ~delayBus = Bus.audio(s, 2);
    ~verbBus = Bus.audio(s, 2);
    ~outBus = Bus.audio(s, 2);
    ~delayFx = Synth.tail(~fxGroup, \scopeDelay, [\in, ~delayBus, \out, ~verbBus, \mix, ~buses.delMix.asMap]);
    ~verbFx = Synth.tail(~fxGroup, \scopeVerb, [\in, ~verbBus, \out, ~outBus, \mix, ~buses.verbMix.asMap]);
    ~masterFx = Synth.tail(~masterGroup, \scopeMaster, [\in, ~outBus]);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linlin(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("vol") or: { ks.contains("fx") } or: { ks.contains("mix") } } { norm }
                    { norm };
                if(key != \panic) {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);
    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~voices.do { |voice| voice.set(\gate, 0) }; ~voices.clear; ~zoneNotes = Array.fill(128, { List.new }) };
    }, ccNum: ~cc[\panic], srcID: ~myUid);
    MIDIdef.noteOn(\scopeOn, { |vel, noteNum|
        var base, keys, synthName, args, voice;
        base = if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) { 1 } { 0 };
        keys = if(base == 1) { [\vol1, \pan1, \mute1, \hpf1, \lpf1, \rq1, \atk1, \dec1, \sus1, \rls1, \fx1] } { [] };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) { keys = keys ++ [\vol2, \pan2, \mute2, \hpf2, \lpf2, \rq2, \atk2, \dec2, \sus2, \rls2, \fx2] };
        keys.do { |k|
            var z, suffix;
            suffix = k.asString.last.asString;
            z = suffix.asInteger;
            synthName = if(z == 1) { \scopeCore } { \scopeTrace };
            args = [\out, ~delayBus, \freq, noteNum.midicps, \gate, 1];
            [\vol, \pan, \mute, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx].do { |param|
                var key;
                key = (param.asString ++ z.asString).asSymbol;
                args = args ++ [param, ~buses[key].asMap];
            };
            voice = Synth.head(~synthGroup, synthName, args);
            ~zoneNotes[noteNum].add(voice);
            ~voices.add(voice);
        };
    }, srcID: ~myUid);
    MIDIdef.noteOff(\scopeOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |voice| voice.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);

    defer {
        var screen, bounds, height, width, pageHolder, zoneMeta, keyLists;
        if(~mainWin.notNil) { ~mainWin.close };
        screen = Window.availableBounds;
        width = 760;
        height = min(780, screen.height - 60);
        ~mainWin = Window("PHOSPHOR / LISSajous Modular", Rect((screen.width-width)/2, (screen.height-height)/2, width, height), scroll: true).front;
        pageHolder = CompositeView(~mainWin, Rect(10, 10, width-20, height-105));
        ~ui = ();
        zoneMeta = [
            (title: "01 / OSCILLATOR CORE", keys: [\vol1, \pan1, \mute1, \min1, \max1, \hpf1, \lpf1, \rq1, \atk1, \dec1, \sus1, \rls1, \fx1], fxLabel: "Harmonic fold"),
            (title: "02 / PHOSPHOR TRACE", keys: [\vol2, \pan2, \mute2, \min2, \max2, \hpf2, \lpf2, \rq2, \atk2, \dec2, \sus2, \rls2, \fx2], fxLabel: "Pinfield complexity")
        ];
        ~pages = Array.new;
        zoneMeta.do { |zm, idx|
            var page, title;
            page = CompositeView(pageHolder, Rect(0, 0, width-30, height-120));
            page.visible = (idx == 0);
            ~pages.add(page);
            title = StaticText(page, Rect(18, 8, 680, 30));
            title.string = zm[\title] ++ "   •   " ++ zm[\fxLabel];
            zm[\keys].do { |key, i|
                var row, label, lo, hi, spec, widget;
                row = i div: 2;
                label = key.asString;
                lo = if(label.matchRegexp("min|max")) { 0 } { if(label.contains("hpf")) { 20 } { 0 } };
                hi = if(label.matchRegexp("min|max")) { 127 } { if(label.matchRegexp("hpf|lpf")) { 18000 } { 1 } };
                spec = ControlSpec(lo, hi, if(label.matchRegexp("hpf|lpf")) { \exp } { \lin }, 0, ~ccVals[key]);
                widget = EZSlider(page, Rect(18 + ((i % 2) * 350), 48 + (row * 78), 330, 66), label ++ "  CC " ++ ~cc[key], spec, { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) }, ~ccVals[key]);
                ~ui[key] = widget;
            };
        };
        Button(~mainWin, Rect(18, height-82, 130, 30)).states_([["CORE"], ["CORE"]]).action_({ ~pages.do { |p, i| p.visible = (i == 0) } });
        Button(~mainWin, Rect(154, height-82, 130, 30)).states_([["TRACE"], ["TRACE"]]).action_({ ~pages.do { |p, i| p.visible = (i == 1) } });
        EZSlider(~mainWin, Rect(300, height-88, 190, 46), "Delay CC 60", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix]);
        EZSlider(~mainWin, Rect(495, height-88, 190, 46), "Reverb CC 61", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix]);
        Button(~mainWin, Rect(width-160, 12, 140, 30)).states_([["PANIC (ALL OFF)"]]).action_({
            ~voices.do { |voice| voice.set(\gate, 0) };
            ~voices.clear;
            ~zoneNotes = Array.fill(128, { List.new });
        });
        Routine({
            while { ~ui.notNil and: { ~mainWin.notNil and: { ~mainWin.isClosed.not } } } {
                ~ccVals.keysValuesDo { |k, v| if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v } };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
/* Congada — gungas, passos cadenciados e canto de cortejo */

// Chão grave: passo coletivo e ressonância sustentada
Ndef(\congadaChao, {
    var trig, env, freq, tone, pulse;
    trig = \t_trig.kr(0);
    freq = \freq.kr(55);
    env = EnvGen.kr(Env.perc(0.08, 3.6, 1, -4), trig);
    tone = (SinOsc.ar(freq) * 0.7) + (SinOsc.ar(freq * 2) * 0.3);
    pulse = SinOsc.kr(0.17).range(0.78, 1);
    Pan2.ar(tone * env * pulse, \pan.kr(0), \amp.kr(0.16));
}).fadeTime = 3;
Ndef(\congadaChao).play;
Ndef(\congadaChao)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35) };
Ndef(\congadaChao).set(\wet10, 0.22);

Pbindef(\congadaPasso,
    \freq, Pseq([48.99, 48.99, 55, 43.65, 48.99, 55, 48.99, 41.2], inf),
    \dur, Pwrand([0.5, 0.75, 1], [0.58, 0.28, 0.14], inf),
    \amp, Pwhite(0.11, 0.17, inf),
    \pan, Pwhite(-0.18, 0.18, inf),
    \t_trig, 1
);
Ndef(\congadaChao).quant = 1;
Ndef(\congadaChao)[1] = \set -> Pbindef(\congadaPasso);

// Gungas de lata: ataques brilhantes, irregulares e metálicos
Ndef(\congadaGungas, {
    var trig, env, freq, mod, bell, grit;
    trig = \t_trig.kr(0);
    freq = \freq.kr(880);
    env = EnvGen.kr(Env.perc(0.002, 0.24, 1, -6), trig);
    mod = SinOsc.ar(freq * 2.71) * (freq * 0.42);
    bell = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 3.51) * 0.28);
    grit = Decay2.ar(K2A.ar(trig), 0.001, 0.055) * WhiteNoise.ar(0.18);
    Pan2.ar((bell * env * 0.55) + grit, \pan.kr(0), \amp.kr(0.18));
}).fadeTime = 1.5;
Ndef(\congadaGungas).play;
Ndef(\congadaGungas)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.78, 0.3) };
Ndef(\congadaGungas).set(\wet10, 0.28);

Pbindef(\congadaGungaSeq,
    \freq, Pseq([783.99, 987.77, 1174.66, 987.77, 880, 1318.51, 1174.66, 880], inf) * Pwhite(0.985, 1.015, inf),
    \dur, Pwrand([0.25, 0.5, 0.75], [0.52, 0.34, 0.14], inf),
    \amp, Pwhite(0.12, 0.2, inf),
    \pan, Pwhite(-0.72, 0.72, inf),
    \t_trig, 1
);
Ndef(\congadaGungas).quant = 1;
Ndef(\congadaGungas)[1] = \set -> Pbindef(\congadaGungaSeq);

// Voz de cortejo: chamada modal em ondas sobre o ritmo
Ndef(\congadaCanto, {
    var trig, env, freq, voice, shimmer;
    trig = \t_trig.kr(0);
    freq = \freq.kr(196);
    env = EnvGen.kr(Env.perc(0.12, 1.35, 1, -3), trig);
    voice = (Saw.ar(freq) * 0.5) + (Pulse.ar(freq * 0.5, 0.42) * 0.35);
    voice = MoogFF.ar(voice, \cutoff.kr(1250) * SinOsc.kr(0.09).range(0.82, 1.18), 1.7);
    shimmer = SinOsc.ar(freq * 3) * 0.12;
    Pan2.ar((voice + shimmer) * env, \pan.kr(0), \amp.kr(0.12));
}).fadeTime = 2.5;
Ndef(\congadaCanto).play;
Ndef(\congadaCanto)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.84, 0.32) };
Ndef(\congadaCanto).set(\wet10, 0.34);

Pbindef(\congadaCantoSeq,
    \freq, Pseq([196, 220, 246.94, 293.66, 246.94, 220, 196, 174.61], inf),
    \dur, Pseq([2, 1, 1.5, 2.5, 1, 1.5, 2, 3], inf),
    \amp, Pwhite(0.09, 0.14, inf),
    \pan, Pwhite(-0.3, 0.3, inf),
    \cutoff, Pwhite(950, 1650, inf),
    \t_trig, 1
);
Ndef(\congadaCanto).quant = 1;
Ndef(\congadaCanto)[1] = \set -> Pbindef(\congadaCantoSeq);

// Ndef(\congadaCanto).xset(\cutoff, 1900); // Abrir o canto | Revert: Ndef(\congadaCanto).xset(\cutoff, 1250);
// Pbindef(\congadaGungaSeq, \dur, 0.25); // Gungas em dobro | Revert: Pbindef(\congadaGungaSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.52, 0.34, 0.14], inf));
// Pbindef(\congadaPasso).stop; Ndef(\congadaChao).fadeTime = 4; Ndef(\congadaChao).clear(4); // Rollback chão
// Pbindef(\congadaGungaSeq).stop; Ndef(\congadaGungas).fadeTime = 4; Ndef(\congadaGungas).clear(4); // Rollback gungas
// Pbindef(\congadaCantoSeq).stop; Ndef(\congadaCanto).fadeTime = 4; Ndef(\congadaCanto).clear(4); // Rollback canto
)

