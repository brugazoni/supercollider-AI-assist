// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GPT-6.1 Sol
// Model ID: openrouter:openai/gpt-6.1-sol
// Date: 2026-11-13T13:20:00.218194+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Vinte e sete anos: duas vozes próximas, presas à mesma etiqueta.
// (a) Resolução aparente: retornos delicados à mesma mesa.
Ndef(\mesa27, { |freq=220, amp=0.1, pan=0, t_trig=0|
    var env = EnvGen.kr(Env.perc(0.025, 2.7), t_trig);
    var voices = SinOsc.ar(freq * [1, 1.003], [0, 0.3]).sum * 0.35;
    var glass = SinOsc.ar(freq * 3.002) * env.squared * 0.12;
    Pan2.ar((voices + glass) * env * amp, pan);
}).play;

Pbindef(\mesa27Seq,
    \dur, Pseq([2.7, 2.7, 5.4], inf),
    \freq, Pseq([220, 277.18, 220, 220, 261.63, 220], inf),
    \amp, 0.1,
    \pan, Pseq([-0.25, 0.25, 0], inf),
    \t_trig, 1
);
Ndef(\mesa27)[1] = \set -> Pbindef(\mesa27Seq);

// As dobras do mapa: pequenas instruções excessivamente precisas.
// (b) Limite intrínseco: a explicação comprime-se até virar atrito.
Ndef(\dobrasMapa, { |freq=1200, amp=0.05, rel=0.08, pan=0, t_trig=0|
    var env = EnvGen.kr(Env.perc(0.002, rel), t_trig);
    var paper = BPF.ar(WhiteNoise.ar, freq, 0.25) * 3;
    var edge = SinOsc.ar(freq * 1.47) * 0.12;
    Pan2.ar(HPF.ar(paper + edge, 650) * env * amp, pan);
}).play;

Pbindef(\dobrasMapaSeq,
    \dur, Pseq([0.5, 0.5, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 6], inf),
    \freq, Pseq([1100, 1400, 1700, 2100, 2400, 2800, 3200, 3600, 900], inf),
    \rel, Pseq([0.12, 0.1, 0.08, 0.07, 0.05, 0.04, 0.03, 0.02, 0.15], inf),
    \amp, Pseq([0.04, 0.045, 0.05, 0.055, 0.06, 0.06, 0.065, 0.065, 0.015], inf),
    \pan, Pseq([-0.4, 0.4], inf),
    \t_trig, 1
);
Ndef(\dobrasMapa)[1] = \set -> Pbindef(\dobrasMapaSeq);

// O vinho suspenso: o silêncio ganha massa, mas a tempestade não cai.
// (c) Suspensão: espectro quase imóvel sob os gestos da mesa.
Ndef(\silencioAntartico, { |freq=46.25, amp=0.13, ice=0.045|
    var breath = LFNoise2.kr(0.035).range(0.35, 0.8);
    var pressure = SinOsc.ar(freq) * 0.6 + (SinOsc.ar(freq * 2) * 0.22);
    var frost = BPF.ar(PinkNoise.ar, [1830, 2790], 0.025) * 9;
    var field = Splay.ar(frost) * ice;
    var low = Pan2.ar(pressure * amp * breath, 0);
    LeakDC.ar(LPF.ar(low + field, 3400));
}).play;

Pbindef(\silencioAntarticoSeq,
    \dur, 10.8,
    \freq, Pseq([46.25, 46.25, 46.08, 46.25], inf)
);
Ndef(\silencioAntartico)[1] = \set -> Pbindef(\silencioAntarticoSeq);

// Rollback: retirar as camadas adicionadas.
 // Pbindef(\mesa27Seq).stop; Ndef(\mesa27).fadeTime = 2; Ndef(\mesa27).clear(2); // Rollback: remove this instrument
 // Pbindef(\dobrasMapaSeq).stop; Ndef(\dobrasMapa).fadeTime = 2; Ndef(\dobrasMapa).clear(2); // Rollback: remove this instrument
 // Pbindef(\silencioAntarticoSeq).stop; Ndef(\silencioAntartico).fadeTime = 2; Ndef(\silencioAntartico).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var oficinaClock = TempoClock.new(1);
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

    // Latão, caixa de nogueira, mola de bolso.
    SynthDef(\efigeniaDente, { |out=0, freq=2100, amp=0.06, pan=0, rel=0.055|
        var env = EnvGen.ar(Env.perc(0.0005, rel.max(0.015)), doneAction: 2);
        var strike = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0003, 0.004));
        var metal = Ringz.ar(strike, freq * [1, 1.731, 2.63], [0.012, 0.023, 0.009]).sum;
        var tooth = SinOsc.ar(freq * 0.47) * env;
        Out.ar(out, Pan2.ar((metal * 0.7 + (tooth * 0.15)) * env * amp, pan));
    }).add;
    s.sync;

    SynthDef(\efigeniaPendulo, { |out=0, freq=185, amp=0.1, pan=0, rel=0.32|
        var env = EnvGen.ar(Env.perc(0.002, rel.max(0.03)), doneAction: 2);
        var wood = DynKlank.ar(Ref([
            [1, 2.09, 3.82, 5.17],
            [1, 0.45, 0.2, 0.08],
            [0.12, 0.07, 0.04, 0.025]
        ]), PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.006)), freqscale: freq);
        Out.ar(out, Pan2.ar(LPF.ar(wood, 4200) * env * amp, pan));
    }).add;
    s.sync;

    SynthDef(\efigeniaCarrilhao, { |out=0, freq=440, amp=0.1, pan=0, rel=5|
        var env = EnvGen.ar(Env.perc(0.003, rel.max(0.1), curve: -5), doneAction: 2);
        var hammer = EnvGen.ar(Env.perc(0.001, 0.065));
        var bell = SinOsc.ar(freq * [1, 2.006, 2.997, 4.17, 6.81],
            SinOsc.ar(freq * 1.413) * hammer * 2,
            [0.6, 0.23, 0.12, 0.07, 0.035]).sum;
        Out.ar(out, Pan2.ar(bell * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\efigeniaEnxame, { |amp=0, rate=2, drift=0.003, brilho=4800|
        var swarm = Mix.fill(14, { |i|
            var tick = Impulse.ar(rate * (1 + ((i - 6.5) * drift)), i / 14);
            var shell = Ringz.ar(tick * 0.0018,
                1250 + (i * 217), 0.012 + ((i % 3) * 0.008));
            Pan2.ar(shell, (i / 6.5) - 1);
        });
        LPF.ar(swarm, brilho) * amp;
    });
    Ndef(\efigeniaEnxame).fadeTime = 2;

    Ndef(\efigeniaRespirar, { |amp=0, freq=110, abertura=1100, ritmo=0.14|
        var lungs = SinOsc.kr(ritmo, 4.71).range(0, 1).squared;
        var air = BPF.ar(PinkNoise.ar, [abertura, abertura * 1.31], 0.13) * 2;
        var beating = SinOsc.ar(freq * [1, 1.004]) * 0.17;
        (air + beating) * lungs * amp;
    });
    Ndef(\efigeniaRespirar).fadeTime = 4;

    Ndef(\masterMix, {
        In.ar(~synthBus, 2)
        + Ndef.ar(\efigeniaEnxame, 2)
        + Ndef.ar(\efigeniaRespirar, 2);
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1, 0.66, 0.53);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        AllpassC.ar(in, 0.2, [0.071, 0.113], 0.7);
    };
    Ndef(\masterMix).set(\wet10, 0.13, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 — A porta estreita; um único pêndulo.".postln;
        Pbindef(\efigeniaPasso,
            \instrument, \efigeniaPendulo, \out, ~synthBus,
            \dur, Pseq([0.502, 0.498], inf),
            \freq, Pseq([185, 153], inf),
            \amp, Pseq([0.15, 0.105], inf),
            \pan, Pseq([-0.25, 0.25], inf)
        ).play(oficinaClock);
        2.do { |i|
            Ndef(\efigeniaEnxame).xset(\amp, 0.12 + (i * 0.13), \drift, 0.0015);
            4.wait;
        };

        "0:08 — As prateleiras respondem, sem concordar.".postln;
        Pbindef(\efigeniaBolso,
            \instrument, \efigeniaDente, \out, ~synthBus,
            \dur, Pseq([0.247, 0.251, 0.249, 0.257], inf),
            \freq, Pseq([2700, 3400, 2350, 4100, 2900], inf),
            \rel, 0.035, \amp, Pseq([0.055, 0.025, 0.04, 0.028], inf),
            \pan, Pseq([0.65, 0.45, -0.6, -0.35, 0.1], inf)
        ).play(oficinaClock);
        4.do { |i|
            Ndef(\efigeniaEnxame).xset(\amp, 0.35, \drift, 0.002 + (i * 0.001));
            4.wait;
        };

        "0:24 — Carrilhão francês, dourado pela poeira.".postln;
        Pbindef(\efigeniaBolso).stop;
        Pbindef(\efigeniaSinos,
            \instrument, \efigeniaCarrilhao, \out, ~synthBus,
            \dur, Pseq([1.5, 0.5, 1, 3, 2], inf),
            \midinote, Pseq([76, 72, 74, 67, 60, 64, 67, 72], inf),
            \amp, 0.095, \rel, 4.5,
            \pan, Pseq([-0.45, 0.1, 0.45, -0.1], inf)
        ).play(oficinaClock);
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.16 + (i * 0.035));
            Ndef(\efigeniaEnxame).xset(\brilho, 4500 - (i * 450));
            4.wait;
        };

        "0:40 — O relojoeiro fecha os olhos.".postln;
        Pbindef(\efigeniaSinos).stop;
        Pbindef(\efigeniaPasso).stop;
        Ndef(\efigeniaEnxame).xset(\amp, 0.08);
        Ndef(\efigeniaRespirar).xset(\amp, 0.2, \freq, 110);
        3.do { |i|
            Ndef(\efigeniaRespirar).xset(\abertura, 650 + (i * 210));
            4.wait;
        };

        "0:52 — As diferenças microscópicas tornam-se engrenagens.".postln;
        Pbindef(\efigeniaBolso, \dur, Pseq([0.127, 0.123, 0.126, 0.119], inf),
            \amp, 0.045).play(oficinaClock);
        Ndef(\efigeniaRespirar).xset(\amp, 0);
        6.do { |i|
            Ndef(\efigeniaEnxame).xset(\amp, 0.4, \rate, 2 + (i * 0.8),
                \drift, 0.004 + (i * 0.004), \brilho, 3800 + (i * 650));
            Ndef(\masterMix).set(\wet11, i * 0.055);
            2.wait;
        };
        4.do { |i|
            Pbindef(\efigeniaBolso, \dur, 0.09 - (i * 0.015), \rel, 0.018);
            Ndef(\efigeniaEnxame).xset(\rate, 8 + (i * 4));
            1.wait;
        };

        "1:08 — Uma mola chega ao limite; o mundo prende o ar.".postln;
        Pbindef(\efigeniaBolso).stop;
        Ndef(\efigeniaEnxame).set(\amp, 0);
        Ndef(\masterMix).set(\wet11, 0, \wet10, 0.3);
        Synth(\efigeniaCarrilhao, [\out, ~synthBus, \freq, 880, \amp, 0.07, \rel, 6]);
        2.wait;
        Ndef(\efigeniaRespirar).xset(\amp, 0.24, \ritmo, 0.125, \abertura, 780);
        3.do { |i|
            Ndef(\efigeniaRespirar).xset(\freq, 110 + (i * 0.08));
            4.wait;
        };

        "1:22 — O respirar do tempo, entre dois dentes.".postln;
        Pbindef(\efigeniaPasso, \amp, Pseq([0.09, 0.055], inf)).play(oficinaClock);
        4.do { |i|
            Ndef(\efigeniaEnxame).xset(\amp, 0.06 + (i * 0.025),
                \rate, 2, \drift, 0.001, \brilho, 2600);
            Ndef(\efigeniaRespirar).xset(\abertura, 1000 - (i * 120));
            4.wait;
        };

        "1:38 — A oficina continua; a escuta se afasta.".postln;
        Synth(\efigeniaCarrilhao, [\out, ~synthBus, \freq, 261.6256, \amp, 0.065, \rel, 7]);
        Ndef(\efigeniaRespirar).xset(\amp, 0);
        4.wait;
        Ndef(\efigeniaEnxame).xset(\amp, 0);
        Pbindef(\efigeniaPasso, \amp, Pseq([0.045, 0.025], inf));
        4.wait;
        Pbindef(\efigeniaPasso).stop;
        4.wait;

        Pbindef(\efigeniaPasso).clear;
        Pbindef(\efigeniaBolso).stop; Pbindef(\efigeniaBolso).clear;
        Pbindef(\efigeniaSinos).stop; Pbindef(\efigeniaSinos).clear;
        Ndef(\efigeniaEnxame).clear(2);
        Ndef(\efigeniaRespirar).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play(oficinaClock);
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: PASS
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
~cc = ();
[\vol, \pan, \mute, \min, \max, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx].do { |name, i|
    2.do { |z| ~cc[(name.asString ++ (z + 1)).asSymbol] = 20 + (z * 13) + i };
};
~cc.putAll((delMix: 90, verbMix: 91, master: 92, panic: 123));

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
    ~zoneMeta = [
        (title: "01 | Gabinete — cobre e tensão", fxKey: \fx1, fxLabel: "Dobras de tensão"),
        (title: "02 | Fósforo — órbitas de Lissajous", fxKey: \fx2, fxLabel: "Rotação harmônica")
    ];
    ~key = { |name, z| (name.asString ++ (z + 1)).asSymbol };
    ~ccVals = (delMix: 0.0, verbMix: 0.0, master: 0.7);
    [
        [0.23, 0, 0, 0, 72, 25, 650, 0.7, 0.015, 0.3, 0.65, 0.7, 0.0],
        [0.18, 0.35, 0, 40, 127, 160, 4200, 0.6, 0.12, 0.7, 0.7, 2.0, 0.0]
    ].do { |values, z|
        [\vol, \pan, \mute, \min, \max, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx].do { |name, i|
            ~ccVals[~key.(name, z)] = values[i];
        };
    };
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~specs = ();
    ~ccVals.keysDo { |k|
        var text = k.asString;
        ~specs[k] = case
        { text.contains("hpf") or: { text.contains("lpf") } } { ControlSpec(20, 18000, \exp) }
        { text.contains("pan") } { ControlSpec(-1, 1) }
        { text.contains("rq") } { ControlSpec(0.05, 1, \exp) }
        { text.contains("atk") or: { text.contains("dec") } or: { text.contains("rls") } } { ControlSpec(0.005, 8, \exp) }
        { text.contains("min") or: { text.contains("max") } } { ControlSpec(0, 127, \lin, 1) }
        { text.contains("mute") } { ControlSpec(0, 1, \lin, 1) }
        { ControlSpec(0, 1) };
    };
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~cabinetBus = Bus.audio(s, 2);
    ~cabinetMasterBus = Bus.audio(s, 2);
    ~zoneNotes = Array.fill(2, { Array.newClear(128) });

    2.do { |z|
        SynthDef(("phosphorVoice" ++ z).asSymbol, {
            |out=0, freq=220, vel=0.7, gate=1, vol=0.2, pan=0, mute=0,
            hpf=25, lpf=4000, rq=0.7, atk=0.01, dec=0.3, sus=0.7, rls=1, fx=0|
            var env, sig, clean, altered, motion;
            env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
            motion = SinOsc.kr(0.13, 0, 0.002, 1);
            if(z == 0) {
                clean = (VarSaw.ar(freq * [0.998, 1.002], 0, 0.45).sum * 0.22)
                    + SinOsc.ar(freq * 0.5, 0, 0.35);
                altered = (clean * (1 + (fx * 7))).fold2(0.85);
                sig = XFade2.ar(clean, altered, (fx * 2) - 1);
            } {
                clean = SinOsc.ar(freq * motion, 0, 0.55)
                    + SinOsc.ar(freq * 2.005, 0, 0.15)
                    + SinOsc.ar(freq * 3.002, 0, 0.08);
                altered = SinOsc.ar(
                    freq * motion + (SinOsc.ar(freq * 1.501) * freq * fx * 3),
                    SinOsc.kr(0.19, 0, fx * 3), 0.6
                );
                sig = XFade2.ar(clean, altered, (fx * 2) - 1);
            };
            sig = HPF.ar(RLPF.ar(sig, lpf.clip(30, 18000), rq.clip(0.05, 1)), hpf.clip(20, 18000));
            Out.ar(out, Pan2.ar(sig, pan, env * vel * vol * (1 - mute)));
        }).add;
    };
    SynthDef(\phosphorSpace, { |in=0, out=0, delMix=0, verbMix=0|
        var dry, echo, signal, room;
        dry = In.ar(in, 2);
        echo = CombL.ar(dry, 1, [0.281, 0.377], 2.2);
        signal = dry + (echo * delMix * 0.4);
        room = FreeVerb2.ar(signal[0], signal[1], 1, 0.78, 0.55);
        Out.ar(out, (signal * (1 - (verbMix * 0.35))) + (room * verbMix * 0.5));
    }).add;
    SynthDef(\phosphorSafety, { |in=0, master=0.7|
        var signal = LeakDC.ar(In.ar(in, 2)) * master;
        Out.ar(0, Limiter.ar(signal, 0.92, 0.01));
    }).add;
    s.sync;
    ~cabinetFX = Synth(\phosphorSpace, [
        \in, ~cabinetBus, \out, ~cabinetMasterBus,
        \delMix, ~buses[\delMix].asMap, \verbMix, ~buses[\verbMix].asMap
    ], ~fxGroup, \addToTail);
    ~cabinetSafety = Synth(\phosphorSafety, [
        \in, ~cabinetMasterBus, \master, ~buses[\master].asMap
    ], ~masterGroup, \addToTail);

    ~releaseNote = { |note|
        ~zoneNotes.do { |notes|
            notes[note].do { |voice| voice.set(\gate, 0) };
            notes[note] = nil;
        };
    };
    ~panic = {
        128.do { |note| ~releaseNote.(note) };
        ~synthGroup.set(\gate, 0);
    };
    MIDIdef.noteOn(\phosphorOn, { |vel, noteNum|
        if(vel == 0) { ~releaseNote.(noteNum) } {
            2.do { |z|
                var args;
                if((noteNum >= ~ccVals[~key.(\min, z)]) and: { noteNum <= ~ccVals[~key.(\max, z)] }) {
                    args = [\out, ~cabinetBus, \freq, noteNum.midicps, \vel, (vel / 127).sqrt];
                    [\vol, \pan, \mute, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx].do { |name|
                        args = args ++ [name, ~buses[~key.(name, z)].asMap];
                    };
                    ~zoneNotes[z][noteNum] = ~zoneNotes[z][noteNum].add(
                        Synth(("phosphorVoice" ++ z).asSymbol, args, ~synthGroup)
                    );
                };
            };
        };
    }, srcID: ~myUid);
    MIDIdef.noteOff(\phosphorOff, { |vel, noteNum| ~releaseNote.(noteNum) }, srcID: ~myUid);
    MIDIdef.cc(\phosphorCC, { |val, num|
        ~cc.keysValuesDo { |key, number|
            if((num == number) and: { ~specs[key].notNil }) {
                var value = ~specs[key].map(val / 127);
                ~ccVals[key] = value;
                ~buses[key].set(value);
            };
        };
    }, srcID: ~myUid);
    MIDIdef.cc(\panic, { |val| if(val > 0) { ~panic.value } }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var screen, height, pages, ranges;
        screen = Window.availableBounds;
        height = 730.min(screen.height - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("Gabinete / Fósforo — MIDI", Rect(0, 0, 790, height), scroll: true).front;
        ~mainWin.view.background = Color.gray(0.09);
        ~mainWin.bounds = ~mainWin.bounds.moveTo(
            screen.left + ((screen.width - 790) / 2), screen.top + ((screen.height - height) / 2)
        );
        ~ui = ();
        pages = Array.newClear(2);
        ranges = Array.newClear(2);
        ~zoneMeta.do { |zm, idx|
            var page, range, lowKey, highKey;
            page = CompositeView(~mainWin, Rect(12, 52, 760, 500));
            pages[idx] = page;
            page.visible = idx == 0;
            page.background = Color.gray(0.15);
            Button(~mainWin, Rect(12 + (idx * 380), 10, 374, 32))
                .states_([[zm[\title], Color.green, Color.gray(0.18)]])
                .action_({ pages.do { |p, j| p.visible = j == idx } });
            lowKey = ~key.(\min, idx); highKey = ~key.(\max, idx);
            StaticText(page, Rect(15, 8, 720, 24)).string_(
                "Zona sobreposta | limites CC " ++ ~cc[lowKey] ++ "/" ++ ~cc[highKey]
            ).stringColor_(Color.green);
            range = EZRanger(page, Rect(15, 36, 725, 36), "Teclas", ControlSpec(0, 127, \lin, 1), { |widget|
                [lowKey, highKey].do { |k, i|
                    ~ccVals[k] = widget.value[i]; ~buses[k].set(widget.value[i]);
                };
            }, [~ccVals[lowKey], ~ccVals[highKey]], labelWidth: 65);
            ranges[idx] = range;
            [\vol, \pan, \hpf, \lpf, \rq, \mute].do { |name, i|
                var key = ~key.(name, idx);
                ~ui[key] = EZSlider(page, Rect(15, 90 + (i * 40), 725, 32),
                    name.asString ++ " CC" ++ ~cc[key], ~specs[key], { |widget|
                        ~ccVals[key] = widget.value; ~buses[key].set(widget.value);
                    }, ~ccVals[key], labelWidth: 110);
            };
            [\atk, \dec, \sus, \rls, \fx].do { |name, i|
                var key = ~key.(name, idx);
                ~ui[key] = EZKnob(page, Rect(22 + (i * 145), 355, 130, 115),
                    if(name == \fx, zm[\fxLabel], name.asString) ++ " CC" ++ ~cc[key],
                    ~specs[key], { |widget|
                        ~ccVals[key] = widget.value; ~buses[key].set(widget.value);
                    }, ~ccVals[key]);
            };
        };
        [\delMix, \verbMix, \master].do { |key, i|
            ~ui[key] = EZSlider(~mainWin, Rect(15, 565 + (i * 35), 755, 30),
                key.asString ++ " CC" ++ ~cc[key], ~specs[key], { |widget|
                    ~ccVals[key] = widget.value; ~buses[key].set(widget.value);
                }, ~ccVals[key], labelWidth: 130);
        };
        Button(~mainWin, Rect(15, 677, 755, 32))
            .states_([["PANIC (ALL OFF)", Color.white, Color.red(0.65)]])
            .action_({ ~panic.value });
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil and: { ~mainWin.isClosed.not }) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                    ranges.do { |widget, z|
                        if(widget.notNil) { widget.value = [~ccVals[~key.(\min, z)], ~ccVals[~key.(\max, z)]] };
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
var cortejoClock;
cortejoClock = TempoClock.new(96 / 60);

// Cortejo imaginado: caixas graves, passos de gunga e resposta coral.
// Evocação sintética, não transcrição de um terno ou canto tradicional.
// Pulso de chão: couro grave com segunda harmônica e toque de madeira.
Ndef(\rosarioChao).fadeTime = 2;
Ndef(\rosarioChao, { |t_trig=1, freq=73.4, amp=0.19, toque=0.4, pan=0|
    var env, bend, couro, madeira, pele, sig;
    env = EnvGen.kr(Env.perc(0.003, 0.36, 1, -5), t_trig);
    bend = EnvGen.kr(Env.perc(0.001, 0.065), t_trig);
    couro = SinOsc.ar(freq * (1 + (bend * 0.65)));
    couro = couro + (SinOsc.ar(freq * 2.01) * 0.24);
    pele = BPF.ar(PinkNoise.ar, 470, 0.5);
    pele = pele * EnvGen.kr(Env.perc(0.001, 0.075), t_trig);
    madeira = Ringz.ar(
        Decay2.ar(K2A.ar(t_trig), 0.001, 0.008) * 0.2,
        [670, 1030, 1590], [0.035, 0.024, 0.018]
    ).sum;
    sig = (couro * env) + (pele * 0.7) + (madeira * toque);
    Pan2.ar(LeakDC.ar(sig).tanh, pan, amp);
}).play;
Ndef(\rosarioChao)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.38, 0.64);
};
Ndef(\rosarioChao).set(\wet10, 0.09);
Pbindef(\rosarioChaoSeq,
    \dur, Pseq([0.75, 0.25, 0.5, 0.5, 0.75, 0.25, 0.5, 0.5], inf),
    \freq, Pseq([73.4, 98, 73.4, 82.4, 73.4, 110, 73.4, 98], inf),
    \amp, Pseq([0.21, 0.1, 0.16, 0.12, 0.2, 0.09, 0.17, 0.13], inf),
    \toque, Pwhite(0.25, 0.7, inf),
    \pan, Pwhite(-0.12, 0.12, inf),
    \t_trig, 1
);
Pbindef(\rosarioChaoSeq).clock = cortejoClock;
Ndef(\rosarioChao).clock = cortejoClock;
Ndef(\rosarioChao).quant = 1;
Ndef(\rosarioChao)[1] = \set -> Pbindef(\rosarioChaoSeq);

// Latas nos tornozelos: cada passo abre um pequeno feixe metálico.
Ndef(\rosarioGungas).fadeTime = 2;
Ndef(\rosarioGungas, { |t_trig=1, freq=1850, amp=0.1, pan=0, cauda=0.12|
    var exc, metal, areia, env, drift, sig;
    drift = TRand.kr(0.94, 1.06, t_trig);
    exc = WhiteNoise.ar * Decay2.ar(K2A.ar(t_trig), 0.001, 0.018);
    metal = Ringz.ar(
        exc * 0.09,
        freq * drift * [1, 1.37, 1.91, 2.63],
        cauda * [1, 0.71, 0.49, 0.32]
    ).sum;
    env = EnvGen.kr(Env.perc(0.002, cauda, 1, -6), t_trig);
    areia = BPF.ar(WhiteNoise.ar, [3400, 5900], 0.16).sum * 11;
    sig = HPF.ar((metal * 0.6) + (areia * env * 0.24), 1100);
    Pan2.ar(sig.tanh, pan, amp);
}).play;
Ndef(\rosarioGungas)[10] = \filter -> { |in|
    CombC.ar(in, 0.3, [0.113, 0.157], 0.32);
};
Ndef(\rosarioGungas)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.47, 0.58);
};
Ndef(\rosarioGungas).set(\wet10, 0.12, \wet11, 0.16);
Pbindef(\rosarioGungasSeq,
    \dur, Pseq([
        Pseq([0.5, 0.25, 0.25, 0.5, 0.5], 6),
        Pwrand([0.25, 0.5, 0.75], [0.55, 0.35, 0.1], 8),
        Pseq([0.5, 0.5, 0.5, 0.5], 2)
    ], inf),
    \freq, Pexprand(1450, 2450, inf),
    \amp, Pseq([0.12, 0.055, 0.075, 0.1, 0.06, 0.095], inf),
    \cauda, Pwhite(0.065, 0.17, inf),
    \pan, Pseq([-0.48, 0.4, -0.3, 0.5], inf),
    \t_trig, 1
);
Pbindef(\rosarioGungasSeq).clock = cortejoClock;
Ndef(\rosarioGungas).clock = cortejoClock;
Ndef(\rosarioGungas).quant = 1;
Ndef(\rosarioGungas)[1] = \set -> Pbindef(\rosarioGungasSeq);

// Resposta sem palavras: arco modal que repousa e volta ao chamado.
Ndef(\rosarioVozes).fadeTime = 4;
Ndef(\rosarioVozes, { |t_trig=1, freq=220, amp=0.12, brilho=1, pan=0|
    var env, body, formants, voz, breath, sig;
    env = EnvGen.kr(Env([0, 1, 0.75, 0], [0.22, 0.65, 0.65]), t_trig);
    body = Saw.ar(freq * [0.995, 1, 1.006] * SinOsc.kr(4.7).range(0.998, 1.002)).sum * 0.22;
    formants = [650, 1150, 2650] * brilho * SinOsc.kr(0.037).range(0.94, 1.06);
    voz = BPF.ar(body, formants, [0.15, 0.12, 0.1]).sum * 3;
    breath = BPF.ar(PinkNoise.ar, 3200, 0.2) * 0.14;
    sig = (voz + breath) * env;
    Pan2.ar(sig.tanh, pan + SinOsc.kr(0.071).range(-0.12, 0.12), amp);
}).play;
Ndef(\rosarioVozes)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.78, 0.48);
};
Ndef(\rosarioVozes).set(\wet10, 0.32);
Pbindef(\rosarioVozesSeq,
    \dur, Pseq([2, 2, 1.5, 2.5, 2, 2, 4, 4], inf),
    \freq, Pseq([57, 60, 62, 64, 62, 60, 57, 55].midicps, inf),
    \amp, Pseq([0.12, 0.1, 0.13, 0.11, 0.12, 0.1, 0.09, 0.075], inf),
    \pan, Pwhite(-0.2, 0.2, inf),
    \t_trig, 1
);
Pbindef(\rosarioVozesSeq).clock = cortejoClock;
Ndef(\rosarioVozes).clock = cortejoClock;
Ndef(\rosarioVozes).quant = 1;
Ndef(\rosarioVozes)[1] = \set -> Pbindef(\rosarioVozesSeq);

// Ndef(\rosarioVozes).xset(\brilho, 1.2); // Abrir | Voltar: Ndef(\rosarioVozes).xset(\brilho, 1);
// Pbindef(\rosarioGungasSeq, \dur, 0.25); // Dobrar | Voltar: Pbindef(\rosarioGungasSeq, \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf));
// Ndef(\rosarioVozes).set(\wet10, 0.5); // Distância | Voltar: Ndef(\rosarioVozes).set(\wet10, 0.32);
// cortejoClock.tempo = 88/60; // Recolher | Voltar: cortejoClock.tempo = 96/60;
// Pbindef(\rosarioChaoSeq).stop; Ndef(\rosarioChao).clear(4); // Retirar chão
// Pbindef(\rosarioGungasSeq).stop; Ndef(\rosarioGungas).clear(4); // Retirar gungas
// Pbindef(\rosarioVozesSeq).stop; Ndef(\rosarioVozes).clear(6); // Retirar resposta
)

