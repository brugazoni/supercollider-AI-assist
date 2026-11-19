// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GPT-6.1 Sol
// Model ID: openrouter:openai/gpt-6.1-sol
// Date: 2026-11-13T13:42:34.961474+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT — Vinte e sete anos: uma explicação excessivamente meticulosa.
// Settling (c): depois de 27 pequenas dobras, a frase fica suspensa.
Ndef(\dobrasDoMapa, { |freq=440, amp=0.1, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.002, 0.17, 1, -6), t_trig);
    var papel = BPF.ar(WhiteNoise.ar(0.3), 3800, 0.5) * env;
    var explicacao = SinOsc.ar(
        freq + (SinOsc.ar(freq * 2.01) * freq * 0.6 * env)
    ) * env;
    Pan2.ar((explicacao * 0.65 + papel) * amp, pan);
}).play;

Pbindef(\dobrasDoMapaSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75, 0.5], inf),
    \freq, Pseq([64, 64, 67, 66, 64, 61, 64, 67, 66].midicps, inf),
    \amp, Pseq([Pseq([0.1, 0.075, 0.09], 9), Pn(0, inf)], 1),
    \pan, Pseq([-0.25, -0.2, -0.15, -0.2, -0.25, -0.1], inf),
    \t_trig, 1
);
Ndef(\dobrasDoMapa)[1] = \set -> Pbindef(\dobrasDoMapaSeq);

// Rollback: remove this instrument
// Pbindef(\dobrasDoMapaSeq).stop; Ndef(\dobrasDoMapa).fadeTime = 2; Ndef(\dobrasDoMapa).clear(2);


// ADD_INSTRUMENT — A garrafa imóvel; o silêncio ganha massa.
// Intrinsic Limit (b): a tempestade aproxima-se, mas nunca chega a rebentar.
Ndef(\silencioAntartico, { |freq=46.249, amp=0.01, cutoff=350, tension=0|
    var vento = PinkNoise.ar(0.4 ! 2);
    var gelo = Splay.ar(
        SinOsc.ar(freq * [4, 4.013, 5.99, 6.017], 0, [0.09, 0.07, 0.04, 0.04])
    );
    var fundo = SinOsc.ar(freq, 0, 0.35)
        + SinOsc.ar(freq * 2, 0, 0.12);
    var pressao = LPF.ar(vento, cutoff)
        * LFNoise2.kr(0.13 ! 2).range(0.3, 0.8);
    var sig = pressao + (gelo * tension) + fundo;
    LeakDC.ar(sig).tanh * amp;
}).play;

Pbindef(\silencioAntarticoSeq,
    \dur, 0.5,
    \freq, 46.249,
    \amp, Pseg(
        Pseq([0.008, 0.015, 0.15, 0.15], 1),
        Pseq([10, 24, 3600], 1),
        \lin
    ),
    \cutoff, Pseg(
        Pseq([220, 220, 1600, 1600], 1),
        Pseq([10, 24, 3600], 1),
        \exp
    ),
    \tension, Pseg(
        Pseq([0, 0.05, 1, 1], 1),
        Pseq([10, 24, 3600], 1),
        \lin
    )
);
Ndef(\silencioAntartico)[1] = \set -> Pbindef(\silencioAntarticoSeq);

// Rollback: remove this instrument
// Pbindef(\silencioAntarticoSeq).stop; Ndef(\silencioAntartico).fadeTime = 2; Ndef(\silencioAntartico).clear(2);
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Latão, madeira, mola.
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\efigeniaEscape, { |out=0, freq=1900, amp=0.07, pan=0, dur=0.1|
        var env, exc, metal, wood;
        env = EnvGen.ar(Env.perc(0.0005, dur.max(0.025), 1, -7), doneAction: 2);
        exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0003, 0.003));
        metal = Ringz.ar(exc, freq * [1, 1.73, 2.61], [0.018, 0.012, 0.008]).sum;
        wood = LPF.ar(exc, 1600) * 2;
        Out.ar(out, Pan2.ar((metal * 0.35 + wood) * env, pan, amp));
    }).add;
    s.sync;

    SynthDef(\efigeniaCarrilhao, { |out=0, freq=440, amp=0.1, pan=0, dur=3|
        var env, strike, body;
        env = EnvGen.ar(Env.perc(0.003, dur.max(0.1), 1, -5), doneAction: 2);
        strike = PinkNoise.ar * EnvGen.ar(Env.perc(0.0007, 0.012));
        body = DynKlank.ar(Ref([
            [1, 2.003, 2.756, 4.07, 5.43, 6.79] * freq,
            [1, 0.5, 0.27, 0.16, 0.1, 0.06],
            [2.8, 2.1, 1.6, 1.1, 0.7, 0.4]
        ]), strike, decayscale: 0.8);
        Out.ar(out, Pan2.ar((body * 0.45).tanh * env, pan, amp));
    }).add;
    s.sync;

    SynthDef(\efigeniaMola, { |out=0, freq=130, amp=0.08, pan=0, dur=0.7|
        var env, winding, sig;
        env = EnvGen.ar(Env.perc(0.004, dur.max(0.05)), doneAction: 2);
        winding = XLine.kr(3.4, 1, dur.max(0.05));
        sig = SinOsc.ar(freq * winding,
            SinOsc.ar(freq * 3.17) * env * 3);
        sig = HPF.ar(sig + (BPF.ar(WhiteNoise.ar, 3400, 0.35) * 0.2), 160);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;
    s.sync;

    // Relógios independentes: a defasagem é o instrumento.
    Ndef(\efigeniaPendulos, { |amp=0, drift=1, brightness=1|
        var clocks;
        clocks = Array.fill(12, { |idx|
            var rate, trig, exc, ring, pos;
            rate = (1.91 + (idx * 0.0173)) * drift;
            trig = Impulse.ar(rate, idx / 12);
            exc = Decay2.ar(trig, 0.0003, 0.003) * WhiteNoise.ar;
            ring = Ringz.ar(exc,
                (960 + (idx * 173)) * brightness,
                0.012 + (idx * 0.001));
            pos = idx.linlin(0, 11, -0.9, 0.9);
            Pan2.ar(HPF.ar(ring, 500), pos, 0.1);
        });
        Mix(clocks) * amp;
    });
    Ndef(\efigeniaRespirar, { |amp=0, freq=110, opening=450, breath=0.15|
        var pulse, air, partials;
        pulse = SinOsc.kr(breath).range(0.1, 1).squared;
        air = BPF.ar(PinkNoise.ar(0.5 ! 2), opening, 0.4) * pulse;
        partials = Splay.ar(SinOsc.ar(freq * [1, 1.0021, 2, 3.001],
            0, [0.2, 0.16, 0.06, 0.025]));
        (air + (partials * pulse)) * amp;
    });
    Ndef(\efigeniaPendulos).fadeTime = 2;
    Ndef(\efigeniaRespirar).fadeTime = 4;
    Ndef(\masterMix, {
        In.ar(~synthBus, 2)
        + Ndef.ar(\efigeniaPendulos, 2)
        + Ndef.ar(\efigeniaRespirar, 2);
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.6);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        AllpassC.ar(in, 0.12, [0.037, 0.053], 0.45);
    };
    Ndef(\masterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - A porta estreita; um pêndulo.".postln;
        Pbindef(\efigeniaTiques,
            \instrument, \efigeniaEscape, \out, ~synthBus,
            \dur, Pseq([0.503, 0.497], inf),
            \freq, Pseq([1700, 1260], inf),
            \amp, Pseq([0.1, 0.065], inf),
            \pan, -0.35
        ).play(TempoClock.new(1));
        4.do { |idx|
            Ndef(\masterMix).set(\wet10, idx * 0.035);
            2.wait;
        };

        "0:08 - Duzentos mecanismos, nenhum uníssono.".postln;
        Ndef(\efigeniaPendulos).xset(\amp, 0.24);
        6.do { |idx|
            Ndef(\efigeniaPendulos).xset(\brightness, 0.8 + (idx * 0.075));
            Synth(\efigeniaMola, [\out, ~synthBus, \freq, 120 + (idx * 23),
                \amp, 0.055, \pan, idx.linlin(0, 5, 0.7, -0.7)]);
            3.wait;
        };

        "0:26 - Carrilhões franceses atravessam o enxame.".postln;
        Pbindef(\efigeniaTiques).stop;
        Ndef(\efigeniaPendulos).xset(\amp, 0.12);
        Pbindef(\efigeniaSinos,
            \instrument, \efigeniaCarrilhao, \out, ~synthBus,
            \dur, Pseq([1.5, 1, 2, 0.5, 3], inf),
            \midinote, Pseq([69, 73, 71, 64, 69, 76, 73, 64], inf),
            \amp, Pseq([0.11, 0.075, 0.09, 0.06], inf),
            \pan, Pseq([0.5, -0.4, 0.2, -0.15], inf)
        ).play(TempoClock.new(1));
        4.do { |idx|
            Ndef(\masterMix).set(\wet10, 0.18 + (idx * 0.04));
            Ndef(\efigeniaPendulos).xset(\drift, 1 + (idx * 0.003));
            4.wait;
        };

        "0:42 - O cronômetro aberto: dentes e espirais.".postln;
        Pbindef(\efigeniaSinos).stop;
        Ndef(\masterMix).set(\wet10, 0.08, \wet11, 0.2);
        Pbindef(\efigeniaTiques, \dur, Pseq([0.125, 0.125, 0.251, 0.124, 0.375], inf),
            \freq, Pseq([2300, 3200, 1700, 4100, 2100], inf),
            \amp, 0.065, \pan, Pwhite(-0.7, 0.7)).play;
        6.do { |idx|
            Ndef(\efigeniaPendulos).xset(\drift, 1 + (idx * 0.13),
                \brightness, 1.1 + (idx * 0.09), \amp, 0.17);
            2.wait;
        };

        "0:54 - Limite da corda; o relojoeiro fecha os olhos.".postln;
        Pbindef(\efigeniaTiques).stop;
        Ndef(\efigeniaPendulos).fadeTime = 0.2;
        Ndef(\efigeniaPendulos).xset(\amp, 0);
        Ndef(\masterMix).set(\wet11, 0, \wet10, 0.35);
        Synth(\efigeniaMola, [\out, ~synthBus, \freq, 330, \amp, 0.12, \dur, 1.5]);
        2.wait;
        Ndef(\efigeniaRespirar).xset(\amp, 0.3);
        5.do { |idx|
            Ndef(\efigeniaRespirar).xset(\opening, 400 + (idx * 160),
                \breath, 0.13 + (idx * 0.006));
            4.wait;
        };

        "1:16 - Nas defasagens, o respirar do tempo.".postln;
        Ndef(\efigeniaPendulos).fadeTime = 5;
        Ndef(\efigeniaPendulos).xset(\amp, 0.095, \drift, 1, \brightness, 0.85);
        Pbindef(\efigeniaTiques, \dur, Pseq([0.503, 0.497], inf),
            \freq, Pseq([1700, 1260], inf), \amp, 0.045, \pan, -0.35).play;
        4.do { |idx|
            Ndef(\efigeniaRespirar).xset(\opening, 880 - (idx * 140),
                \amp, 0.26 - (idx * 0.045));
            3.wait;
        };

        "1:28 - O último latão guarda a oficina.".postln;
        Pbindef(\efigeniaTiques).stop;
        Synth(\efigeniaCarrilhao, [\out, ~synthBus, \freq, 440,
            \amp, 0.075, \dur, 5, \pan, 0.1]);
        Ndef(\efigeniaPendulos).xset(\amp, 0);
        Ndef(\efigeniaRespirar).fadeTime = 6;
        Ndef(\efigeniaRespirar).xset(\amp, 0);
        6.wait;
        Pbindef(\efigeniaTiques).clear;
        Pbindef(\efigeniaSinos).clear;
        Ndef(\efigeniaPendulos).clear(2);
        Ndef(\efigeniaRespirar).clear(2);
        Ndef(\masterMix).clear(2);
        2.wait;
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
~cc = (delMix: 90, verbMix: 91, panic: 123);
~params = [\vol, \pan, \mute, \min, \max, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx];
2.do { |idx|
    ~params.do { |p, j| ~cc[(p.asString ++ (idx + 1)).asSymbol] = 20 + (idx * 20) + j };
};
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
    ~myUid = ~myInDevice.uid;
    ("MIDI IN: " ++ ~myInDevice.device ++ " / " ++ ~myInDevice.name).postln;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};
s.waitForBoot({
    ~zoneMeta = [
        (title: "01 / Gabinete — prata e cabos", fxKey: \fx1, fxLabel: "Dobra de tensao"),
        (title: "02 / Fosforo — orbitas Lissajous", fxKey: \fx2, fxLabel: "Rotacao de fase")
    ];
    ~key = { |p, idx| (p.asString ++ (idx + 1)).asSymbol };
    ~ccVals = (delMix: 0.0, verbMix: 0.0);
    [
        [0.22, 0.0, 0, 0, 78, 25, 2400, 0.65, 0.015, 0.35, 0.65, 0.7, 0.0],
        [0.18, 0.35, 0, 36, 127, 160, 4800, 0.75, 0.18, 0.8, 0.7, 1.8, 0.0]
    ].do { |values, idx|
        ~params.do { |p, j| ~ccVals[~key.(p, idx)] = values[j] };
    };
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~mixBus = Bus.audio(s, 2);
    ~tailBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~notes = Array.fill(2, { Array.newClear(128) });
    2.do { |idx|
        SynthDef(("fosforoVoice" ++ idx).asSymbol, {
            |out=0, freq=220, gate=1, velocity=0.7, vol=0.2, pan=0, mute=0,
            hpf=25, lpf=4000, rq=0.7, atk=0.01, dec=0.4, sus=0.7, rls=1, fx=0|
            var sig, env, folded, phase, orbit, cutoff;
            env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
            if(idx == 0) {
                sig = (VarSaw.ar(freq * [0.998, 1.002], 0, 0.46).sum * 0.24)
                    + SinOsc.ar(freq * 0.5, 0, 0.32);
                folded = (sig * (1 + (fx * 7))).fold2(0.8);
                sig = (sig * (1 - fx)) + (folded * fx);
                cutoff = (lpf * (0.55 + (env * 0.45))).clip(20, 18000);
                sig = HPF.ar(RLPF.ar(sig, cutoff, rq.clip(0.1, 1)), hpf.clip(20, 18000));
                sig = Pan2.ar(sig, pan, vol * velocity * env * (1 - mute));
            } {
                phase = SinOsc.ar(freq * 1.5, 0, 0.55);
                orbit = SinOsc.kr(0.09).range(0, 2pi);
                sig = [
                    SinOsc.ar(freq, phase + (orbit * fx)),
                    SinOsc.ar(freq * 1.001, phase + (orbit.neg * fx))
                ] * 0.45;
                folded = (sig * (1 + (fx * 4))).fold2(0.8);
                sig = (sig * (1 - fx)) + (folded * fx);
                sig = HPF.ar(RLPF.ar(sig, lpf.clip(20, 18000), rq.clip(0.1, 1)), hpf.clip(20, 18000));
                sig = if(sig.isKindOf(Collection)) {
                    Balance2.ar(sig[0], sig[1], pan, vol * velocity * env * (1 - mute))
                } {
                    Pan2.ar(sig, pan, vol * velocity * env * (1 - mute))
                };
            };
            Out.ar(out, sig);
        }).add;
    };
    SynthDef(\fosforoSpace, { |in=0, out=0, delMix=0, verbMix=0|
        var dry, echo, sig, verb;
        dry = In.ar(in, 2);
        echo = CombC.ar(dry, 0.6, [0.281, 0.377], 2.5) * 0.45;
        sig = dry + (echo * Lag.kr(delMix, 0.1));
        verb = FreeVerb2.ar(sig[0], sig[1], 1, 0.8, 0.55);
        Out.ar(out, (sig * (1 - verbMix)) + (verb * verbMix));
    }).add;
    SynthDef(\fosforoMaster, { |in=0|
        var sig = LeakDC.ar(In.ar(in, 2));
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;
    ~space = Synth(\fosforoSpace, [\in, ~mixBus, \out, ~tailBus,
        \delMix, ~buses[\delMix].asMap, \verbMix, ~buses[\verbMix].asMap], ~fxGroup, \addToTail);
    ~master = Synth(\fosforoMaster, [\in, ~tailBus], ~masterGroup, \addToTail);
    ~release = { |note|
        2.do { |idx|
            ~notes[idx][note].do { |voice| voice.set(\gate, 0) };
            ~notes[idx][note] = nil;
        };
    };
    ~panic = {
        ~synthGroup.set(\gate, 0);
        2.do { |idx| ~notes[idx] = Array.newClear(128) };
    };
    MIDIdef.noteOn(\fosforoOn, { |vel, note, chan|
        if(vel == 0) { ~release.(note) } {
            2.do { |idx|
                var args;
                if((note >= ~ccVals[~key.(\min, idx)]) and: { note <= ~ccVals[~key.(\max, idx)] }) {
                    args = [\out, ~mixBus, \freq, note.midicps, \velocity, (vel / 127).sqrt];
                    ~params.reject { |p| [\min, \max].includes(p) }.do { |p|
                        args = args ++ [p, ~buses[~key.(p, idx)].asMap];
                    };
                    ~notes[idx][note] = ~notes[idx][note].add(
                        Synth(("fosforoVoice" ++ idx).asSymbol, args, ~synthGroup)
                    );
                };
            };
        };
    }, srcID: ~myUid);
    MIDIdef.noteOff(\fosforoOff, { |vel, note| ~release.(note) }, srcID: ~myUid);
    ~specFor = { |key|
        var text = key.asString;
        case
        { text.contains("hpf") or: { text.contains("lpf") } } { ControlSpec(20, 18000, \exp) }
        { text.contains("pan") } { ControlSpec(-1, 1) }
        { text.contains("rq") } { ControlSpec(0.1, 1, \exp) }
        { text.contains("atk") or: { text.contains("dec") } or: { text.contains("rls") } } { ControlSpec(0.005, 5, \exp) }
        { text.contains("min") or: { text.contains("max") } } { ControlSpec(0, 127, \lin, 1) }
        { text.contains("mute") } { ControlSpec(0, 1, \lin, 1) }
        { ControlSpec(0, 1) };
    };
    ~setValue = { |key, value| ~ccVals[key] = value; ~buses[key].set(value) };
    MIDIdef.cc(\fosforoCC, { |val, num|
        ~cc.keysValuesDo { |key, ccNum|
            if((num == ccNum) and: { key != \panic }) {
                ~setValue.(key, ~specFor.(key).map(val / 127));
            };
        };
    }, srcID: ~myUid);
    MIDIdef.cc(\panic, { |val| if(val > 0) { ~panic.() } }, ccNum: ~cc[\panic], srcID: ~myUid);
    defer {
        var screen, height, pages, bar;
        screen = Window.availableBounds;
        height = 780.min(screen.height - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("FOSFORO / Gabinete modular", Rect(0, 0, 760, height), scroll: true).front;
        ~mainWin.bounds = Rect(
            screen.left + ((screen.width - 760) / 2),
            screen.top + ((screen.height - height) / 2),
            760, height
        );
        ~mainWin.view.background = Color.gray(0.09);
        ~ui = ();
        pages = Array.newClear(2);
        ~zoneMeta.do { |zm, idx|
            var page, range, low, high;
            Button(~mainWin, Rect(12 + (idx * 368), 10, 360, 32))
            .states_([[zm[\title], Color.green, Color.gray(0.18)]])
            .action_({ pages.do { |p, j| p.visible = (j == idx) } });
            page = CompositeView(~mainWin, Rect(12, 52, 728, 520));
            pages[idx] = page;
            page.visible = (idx == 0);
            low = ~key.(\min, idx); high = ~key.(\max, idx);
            range = EZRanger(page, Rect(8, 8, 704, 40),
                "Teclas / CC " ++ ~cc[low] ++ "," ++ ~cc[high], ControlSpec(0, 127, \lin, 1),
                { |w| ~setValue.(low, w.value[0]); ~setValue.(high, w.value[1]) },
                [~ccVals[low], ~ccVals[high]], labelWidth: 145);
            ~params.reject { |p| [\min, \max, \fx].includes(p) }.do { |p, j|
                var key = ~key.(p, idx);
                ~ui[key] = EZSlider(page, Rect(8, 58 + (j * 36), 590, 30),
                    p.asString ++ " / CC " ++ ~cc[key], ~specFor.(key),
                    { |w| ~setValue.(key, w.value) }, ~ccVals[key], labelWidth: 120);
            };
            ~ui[zm[\fxKey]] = EZKnob(page, Rect(624, 80, 80, 90),
                "CC " ++ ~cc[zm[\fxKey]], ControlSpec(0, 1),
                { |w| ~setValue.(zm[\fxKey], w.value) }, 0);
            StaticText(page, Rect(604, 182, 120, 70)).string_(zm[\fxLabel]).stringColor_(Color.green);
        };
        bar = CompositeView(~mainWin, Rect(12, 580, 728, 126));
        [\delMix, \verbMix].do { |key, j|
            ~ui[key] = EZSlider(bar, Rect(8, j * 36, 704, 30),
                key.asString ++ " / CC " ++ ~cc[key], ControlSpec(0, 1),
                { |w| ~setValue.(key, w.value) }, 0, labelWidth: 145);
        };
        Button(bar, Rect(8, 78, 704, 34)).states_([["PANIC (ALL OFF)", Color.white, Color.red(0.65)]])
        .action_({ ~panic.() });
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil and: { ~mainWin.isClosed.not }) {
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


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Cortejo imaginado: caixas graves, gungas nos passos e resposta cantada.
// Evocação sintética, sem pretender reproduzir um terno específico.
Ndef(\rosarioChao).fadeTime = 3;
Ndef(\rosarioGungas).fadeTime = 2;
Ndef(\rosarioCanto).fadeTime = 5;

// Chão: couro, madeira e o peso alternado dos passos.
Ndef(\rosarioChao, { |t_trig=1, freq=73.42, amp=0.18, pan=0, decay=0.32|
    var env, bend, skin, strike, body;
    env = EnvGen.ar(Env.perc(0.003, decay.max(0.05), 1, -5), t_trig);
    bend = EnvGen.kr(Env.perc(0.001, 0.055), t_trig);
    skin = SinOsc.ar(freq * (1 + (bend * 0.65)));
    skin = skin + (SinOsc.ar(freq * 2.03, 0, 0.24));
    strike = BPF.ar(PinkNoise.ar, 1250, 0.5);
    strike = strike * Decay2.ar(K2A.ar(t_trig), 0.001, 0.035);
    body = (skin * env) + (strike * 0.45);
    body = LeakDC.ar((body * 1.3).tanh);
    Pan2.ar(body, pan, amp);
}).play;

Ndef(\rosarioChao)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.38, 0.7);
};
Ndef(\rosarioChao).set(\wet10, 0.12);

Pbindef(\rosarioChaoSeq,
    \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5], inf),
    \freq, Pseq([73.42, 73.42, 110, 98, 73.42], inf),
    \decay, Pseq([0.38, 0.24, 0.16, 0.18, 0.32], inf),
    \amp, Pseq([0.2, 0.13, 0.09, 0.12, 0.17], inf),
    \pan, Pseq([-0.12, 0.12, -0.08, 0.08, 0], inf),
    \t_trig, 1
);
Ndef(\rosarioChao).quant = 1;
Ndef(\rosarioChao)[1] = \set -> Pbindef(\rosarioChaoSeq);

// Gungas: pequenos impactos de lata, com ressonâncias desencontradas.
Ndef(\rosarioGungas, { |t_trig=1, freq=1750, amp=0.11, pan=0, ring=0.12|
    var hit, scatter, exciter, modes, grit, sig;
    hit = Decay2.ar(K2A.ar(t_trig), 0.001, 0.026);
    scatter = Dust.ar(95) * Decay2.ar(K2A.ar(t_trig), 0.002, 0.095);
    exciter = WhiteNoise.ar * (hit + (scatter * 0.2));
    modes = DynKlank.ar(Ref([
        [1, 1.413, 1.927, 2.631, 3.17],
        [0.4, 0.28, 0.18, 0.12, 0.07],
        [0.09, 0.13, 0.07, 0.11, 0.05]
    ]), exciter, freqscale: freq, decayscale: ring / 0.12);
    grit = BPF.ar(exciter, 6500, 0.16) * 12;
    sig = HPF.ar((modes * 0.23) + (grit * 0.18), 1400);
    sig = sig.tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\rosarioGungas)[10] = \filter -> { |in|
    CombC.ar(in, 0.4, [0.143, 0.217], 0.65);
};
Ndef(\rosarioGungas)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.52, 0.52);
};
Ndef(\rosarioGungas).set(\wet10, 0.13, \wet11, 0.2);

Pbindef(\rosarioGungasSeq,
    \dur, Pseq([
        0.25, 0.25, 0.25, 0.25,
        0.25, 0.125, 0.125, 0.25, 0.25,
        0.25, 0.25, Rest(0.25), 0.25,
        0.25, 0.25, 0.25, 0.25
    ], inf),
    \freq, Pexprand(1450, 2350, inf),
    \ring, Pwhite(0.07, 0.17, inf),
    \pan, Pseq([-0.55, 0.45, -0.35, 0.6], inf),
    \amp, Pseq([0.12, 0.08, 0.1, 0.07, 0.13, 0.08, 0.09], inf),
    \t_trig, 1
);
Ndef(\rosarioGungas).quant = 1;
Ndef(\rosarioGungas)[1] = \set -> Pbindef(\rosarioGungasSeq);

// Canto sem palavras: chamada, limite ascendente, retorno e resposta.
Ndef(\rosarioCanto, { |t_trig=1, freq=220, amp=0.13, pan=0, vowel=0, air=0.08|
    var env, pitch, body, formants, voice, sig;
    env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.13, 0.55, 0.55]), t_trig);
    pitch = Lag.kr(freq, 0.09) * SinOsc.kr(5.1).range(0.997, 1.003);
    body = Saw.ar(pitch * [0.997, 1, 1.004], 0.2).sum;
    body = body + (PinkNoise.ar * air);
    formants = [
        SelectX.kr(vowel, [650, 430, 350]),
        SelectX.kr(vowel, [1100, 900, 1800]),
        SelectX.kr(vowel, [2600, 2400, 2800])
    ];
    voice = BPF.ar(body, formants, 0.13).sum * 11;
    sig = HPF.ar(voice, 260) * env * 0.48;
    Pan2.ar(sig.tanh, (pan + SinOsc.kr(0.037, 0, 0.16)).clip(-1, 1), amp);
}).play;

Ndef(\rosarioCanto)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.79, 0.6);
};
Ndef(\rosarioCanto).set(\wet10, 0.32);
Pbindef(\rosarioCantoSeq,
    \dur, Pseq([1, 1, 2, 1, 1, 2, Rest(2)], inf),
    \midinote, Pseq([62, 65, 67, 69, 67, 62, 65, 64, 62, 57, 60, 62], inf),
    \vowel, Pseq([0, 0.5, 1, 0, 1.7, 1], inf),
    \amp, Pwhite(0.1, 0.15, inf),
    \pan, Pseq([-0.2, -0.2, 0.2, 0.2], inf),
    \t_trig, 1
);
Ndef(\rosarioCanto).quant = 1;
Ndef(\rosarioCanto)[1] = \set -> Pbindef(\rosarioCantoSeq);

// Ndef(\rosarioCanto).xset(\air, 0.2); // Mais sopro | Reverter: Ndef(\rosarioCanto).xset(\air, 0.08);
// Pbindef(\rosarioChaoSeq, \dur, 0.25); // Adensar | Reverter: Pbindef(\rosarioChaoSeq, \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.5], inf));
// Ndef(\rosarioGungas).set(\wet10, 0.3); // Ecos | Reverter: Ndef(\rosarioGungas).set(\wet10, 0.13);
// Ndef(\rosarioCanto).set(\wet10, 0.5); // Distância | Reverter: Ndef(\rosarioCanto).set(\wet10, 0.32);
// Pbindef(\rosarioChaoSeq).stop; Ndef(\rosarioChao).clear(4); // Retirar chão
// Pbindef(\rosarioGungasSeq).stop; Ndef(\rosarioGungas).clear(4); // Retirar gungas
// Pbindef(\rosarioCantoSeq).stop; Ndef(\rosarioCanto).clear(6); // Retirar canto
)

