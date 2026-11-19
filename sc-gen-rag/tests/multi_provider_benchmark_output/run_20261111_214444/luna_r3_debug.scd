(
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
    delMix: 60, verbMix: 61, panic: 62
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
    var makeZone, zoneKeys;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 72, hpf1: 28, lpf1: 220,
        rq1: 0.7, atk1: 0.03, dec1: 0.4, sus1: 0.55, rls1: 1.2, fx1: 0.0,
        vol2: 0.18, pan2: 0.35, mute2: 0.0, min2: 45, max2: 127, hpf2: 350, lpf2: 6500,
        rq2: 0.7, atk2: 0.01, dec2: 0.35, sus2: 0.0, rls2: 0.65, fx2: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });
    ~zoneMeta = [
        (title: "Sol quente / couro da cidade", fxKey: \fx1, fxLabel: "Asfalto"),
        (title: "Mar nas pedras / caneta ao vento", fxKey: \fx2, fxLabel: "Espuma")
    ];

    SynthDef(\morroBody, { |out=0, freq=110, gate=1, vol=0.2, pan=0, hpf=25, lpf=220, rq=0.7,
        atk=0.03, dec=0.4, sus=0.5, rls=1, fx=0|
        var env, sub, bus, harmonics, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sub = SinOsc.ar(freq * [1, 1.003]) * 0.35;
        bus = SinOsc.ar(freq * 2.01) * 0.12;
        harmonics = Saw.ar(freq * [0.5, 1.01]) * 0.12;
        sig = Mix(sub) + Mix(bus) + Mix(harmonics);
        sig = (sig * (1 + (fx * 2))).tanh;
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1));
        sig = HPF.ar(sig, hpf.clip(20, 10000)) * env * vol * (1 - 0);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\morroSea, { |out=0, freq=440, gate=1, vol=0.18, pan=0.35, hpf=350, lpf=6500, rq=0.7,
        atk=0.01, dec=0.35, sus=0, rls=0.65, fx=0|
        var env, exc, metal, fm, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = Decay2.ar(Impulse.ar(0), 0.001, 0.025) * WhiteNoise.ar(0.4);
        metal = DynKlank.ar(Ref([[1, 2.71, 4.13, 6.8], [1, 0.6, 0.32, 0.16], [1.2, 0.8, 0.5, 0.3]]), exc, freqscale: freq);
        fm = SinOsc.ar(freq * 1.51, SinOsc.ar(freq * 2.71) * (fx * 3)) * 0.18;
        sig = (metal * 0.32) + fm;
        sig = AllpassC.ar(sig, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = LPF.ar(HPF.ar(sig, hpf.clip(20, 10000)), lpf.clip(40, 18000));
        sig = sig * env * vol * (1 - 0);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\morroFX, { |inbus=0, delMix=0, verbMix=0|
        var dry, delayed, wet;
        dry = In.ar(inbus, 2);
        delayed = CombC.ar(dry, 0.45, SinOsc.kr(0.07).range(0.18, 0.28), 2.2);
        wet = FreeVerb2.ar(dry[0] + (delayed[0] * delMix), dry[1] + (delayed[1] * delMix), verbMix, 0.75, 0.35);
        Out.ar(0, LeakDC.ar(wet));
    }).add;

    SynthDef(\morroLimit, {
        var sig;
        sig = Limiter.ar(LeakDC.ar(In.ar(0, 2)), 0.92, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ~fx = Synth.tail(~fxGroup, \morroFX, [\inbus, ~audioBus, \delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap]);
    ~limiter = Synth.tail(~masterGroup, \morroLimit);
    makeZone = { |idx, defName, noteNum|
        var suffix, args;
        suffix = (idx + 1).asString;
        args = [
            \out, ~audioBus, \freq, noteNum.midicps,
            \vol, ~buses[("vol" ++ suffix).asSymbol].asMap,
            \pan, ~buses[("pan" ++ suffix).asSymbol].asMap,
            \hpf, ~buses[("hpf" ++ suffix).asSymbol].asMap,
            \lpf, ~buses[("lpf" ++ suffix).asSymbol].asMap,
            \rq, ~buses[("rq" ++ suffix).asSymbol].asMap,
            \atk, ~buses[("atk" ++ suffix).asSymbol].asMap,
            \dec, ~buses[("dec" ++ suffix).asSymbol].asMap,
            \sus, ~buses[("sus" ++ suffix).asSymbol].asMap,
            \rls, ~buses[("rls" ++ suffix).asSymbol].asMap,
            \fx, ~buses[("fx" ++ suffix).asSymbol].asMap
        ];
        Synth.head(~synthGroup, defName, args);
    };

    MIDIdef.noteOn(\morroOn, { |vel, noteNum|
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[noteNum].add(makeZone.(0, \morroBody, noteNum));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[noteNum].add(makeZone.(1, \morroSea, noteNum));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\morroOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |voice| voice.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1, 1) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("vol") or: { ks.contains("fx") } or: { ks.contains("Mix") } } { norm }
                    { norm };
                if(key != \panic) {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~zoneNotes.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; voices.clear } };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, winH, winW, top, pages, bottom, ui, zoneKeys, addSlider;
        bounds = Window.availableBounds;
        winW = 760;
        winH = min(780, bounds.height - 60);
        ~mainWin.tryPerform(\close);
        ~mainWin = Window("Morro — cidade, mar e caminhos", Rect(bounds.left + ((bounds.width - winW) / 2), bounds.top + 30, winW, winH), scroll: true);
        ~mainWin.background = Color(0.08, 0.09, 0.12);
        ~ui = ();
        pages = PageLayout(~mainWin, winW @ (winH - 60), margin: 8);
        zoneKeys = [
            [\vol1, \pan1, \mute1, \min1, \max1, \hpf1, \lpf1, \rq1, \atk1, \dec1, \sus1, \rls1, \fx1],
            [\vol2, \pan2, \mute2, \min2, \max2, \hpf2, \lpf2, \rq2, \atk2, \dec2, \sus2, \rls2, \fx2]
        ];
        ~zoneMeta.do { |zm, idx|
            var page, keys, row, col, key, spec, slider, title;
            page = CompositeView(pages, winW @ (winH - 105));
            page.background = Color(0.11, 0.13, 0.17);
            title = StaticText(page, Rect(18, 10, 700, 30));
            title.string = zm[\title];
            title.stringColor = Color(0.9, 0.8, 0.58);
            title.font = Font("Helvetica", 18);
            keys = zoneKeys[idx];
            keys.do { |k, j|
                row = (j / 3).floor;
                col = j % 3;
                key = k;
                spec = case
                    { key.asString.contains("min") or: { key.asString.contains("max") } } { ControlSpec(0, 127, \lin, 1) }
                    { key.asString.contains("pan") } { ControlSpec(-1, 1, \lin, 0.01) }
                    { key.asString.contains("hpf") } { ControlSpec(20, 10000, \exp, 1) }
                    { key.asString.contains("lpf") } { ControlSpec(40, 18000, \exp, 1) }
                    { key.asString.contains("atk") or: { key.asString.contains("dec") } or: { key.asString.contains("rls") } } { ControlSpec(0.005, 5, \exp, 0.01) }
                    { key.asString.contains("rq") } { ControlSpec(0.05, 1, \lin, 0.01) }
                    { key.asString.contains("mute") or: { key.asString.contains("sus") } or: { key.asString.contains("fx") } or: { key.asString.contains("vol") } } { ControlSpec(0, 1, \lin, 0.01) }
                    {  } { ControlSpec(0, 1, \lin, 0.01) };
                slider = EZSlider(page, Rect(18 + (col * 235), 55 + (row * 76), 220, 62),
                    key.asString ++ "  CC" ++ ~cc[key].asString, spec,
                    { |ez| ~ccVals[key] = ez.value; if(~buses[key].notNil) { ~buses[key].set(ez.value) } },
                    ~ccVals[key], layout: \vert);
                ~ui[key] = slider;
            };
        };
        bottom = CompositeView(~mainWin, Rect(8, winH - 48, winW - 16, 40));
        addSlider = { |key, x, label|
            var spec;
            spec = ControlSpec(0, 1, \lin, 0.01);
            ~ui[key] = EZSlider(bottom, Rect(x, 0, 210, 36), label ++ " CC" ++ ~cc[key].asString, spec,
                { |ez| ~ccVals[key] = ez.value; if(~buses[key].notNil) { ~buses[key].set(ez.value) } },
                ~ccVals[key], layout: \horz);
        };
        addSlider.(\delMix, 5, "Delay");
        addSlider.(\verbMix, 230, "Reverb");
        Button(bottom, Rect(475, 3, 190, 32)).states_([["PANIC (ALL OFF)", Color.white, Color(0.65, 0.08, 0.08)]])
            .action_({ ~zoneNotes.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; voices.clear } });
        ~mainWin.front;
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