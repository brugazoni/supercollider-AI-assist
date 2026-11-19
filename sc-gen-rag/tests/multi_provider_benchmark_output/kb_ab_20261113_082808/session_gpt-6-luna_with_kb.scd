// ============================================================
// MULTI-PROVIDER BENCHMARK: OpenAI GP6 Luna
// Model ID: openrouter:openai/gpt-6-luna
// Date: 2026-11-13T11:57:05.810095+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\anniversaryTension, { |freq=220, partnerFreq=220.7, amp=0.12, t_trig=0|
    var env, tones, sig;
    env = EnvGen.ar(Env.perc(0.4, 5.5, curve: -3), t_trig);
    tones = SinOsc.ar([freq, partnerFreq]) * [0.7, 0.65];
    sig = Splay.ar(tones) * env * amp;
    sig;
}).play;

Pbindef(\anniversarySeq,
    \dur, Pseq([4, 3, 5, 4], inf),
    \freq, Pseq([220, 246.94, 196, 220], inf),
    \partnerFreq, Pseq([220.7, 247.8, 196.5, 220.7], inf),
    \t_trig, 1,
    \amp, 0.12
);
Ndef(\anniversaryTension)[1] = \set -> Pbindef(\anniversarySeq);
// Pbindef(\anniversarySeq).stop; Ndef(\anniversaryTension).fadeTime = 2; Ndef(\anniversaryTension).clear(2); // Rollback: remove this instrument


Ndef(\mapFold, { |freq=1200, amp=0.1, t_trig=0, pan=0|
    var env, click, paper;
    env = EnvGen.ar(Env.perc(0.002, 0.16, curve: -8), t_trig);
    click = WhiteNoise.ar(0.35) + SinOsc.ar(freq, 0, 0.25);
    paper = BPF.ar(click, freq.clip(500, 7000), 0.22) * 5;
    Pan2.ar(paper * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([2.1, 1.9, 1.4, 0.8, 0.5, 0.35], inf),
    \freq, Pseq([900, 1200, 1600, 2400, 3100, 3800], inf),
    \t_trig, 1,
    \amp, Pseq([0.06, 0.07, 0.09, 0.11, 0.12, 0.14], inf),
    \pan, Pseq([-0.25, 0.2, 0.1, -0.15], inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument


Ndef(\antarcticSilence, { |freq=38, amp=0.12, cold=180|
    var wind, pressure, sig;
    wind = BPF.ar(PinkNoise.ar(0.3), LFNoise1.kr(0.06).range(90, 700), 0.35) * 2;
    pressure = SinOsc.ar(freq) * 0.35 + SinOsc.ar(freq * 2) * 0.12;
    sig = LPF.ar(wind, cold) + pressure;
    Splay.ar([sig, DelayC.ar(sig, 0.08, 0.045)]) * amp;
}).play;

Pbindef(\antarcticSeq,
    \dur, Pseq([8, 12, 16, 24], inf),
    \freq, Pseq([38, 36.7, 34.65, 32.7], inf),
    \cold, Pseq([500, 350, 240, 180], inf),
    \amp, Pseq([0.12, 0.1, 0.07, 0.035], inf)
);
Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSeq);
// Pbindef(\antarcticSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var tickPattern;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\brassTick, { |out=0, freq=1800, amp=0.08, pan=0, decay=0.12|
        var env, ring, click, sig;
        env = EnvGen.ar(Env.perc(0.001, decay.max(0.025), 1, -8), doneAction: 2);
        click = WhiteNoise.ar(0.18) + Impulse.ar(0, 0, 0.8);
        ring = Ringz.ar(click, [freq, freq * 1.503, freq * 2.617], [decay, decay * 0.72, decay * 0.48]).sum;
        sig = (ring * 0.22 + click * 0.08) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\bellTooth, { |out=0, freq=880, amp=0.06, pan=0, sustain=1.2|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.004, sustain.max(0.05), 1, -4), doneAction: 2);
        mod = SinOsc.ar(freq * 2.71) * freq * 1.8 * env;
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 2.03) * 0.25);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    Ndef(\clockBreath, { |rate=0.09, cutoff=1400, amp=0|
        var wind, beating, sig;
        wind = BPF.ar(PinkNoise.ar(0.12), LFNoise1.kr(rate).range(170, 520), 0.28) * 2;
        beating = SinOsc.ar([109, 109.17]) * [0.22, 0.2];
        sig = LPF.ar(wind, cutoff) + Mix(beating);
        Splay.ar([sig, DelayC.ar(sig, 0.08, 0.037)]) * amp;
    });

    Ndef(\gearCloud, { |density=4, brightness=1, amp=0|
        var trig, env, freq, sig;
        trig = Dust.ar(density);
        env = Decay2.ar(trig, 0.002, 0.11);
        freq = TExpRand.ar(700, 5400, trig) * brightness;
        sig = SinOsc.ar(freq) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.8, 0.8, trig));
    });

    Ndef(\clockMaster, {
        var discrete, air, cloud;
        discrete = In.ar(~synthBus, 2);
        air = Ndef.ar(\clockBreath, 2);
        cloud = Ndef.ar(\gearCloud, 2);
        discrete + air + cloud;
    });
    Ndef(\clockMaster)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.28);
    };
    Ndef(\clockMaster)[11] = \filter -> { |in|
        CombC.ar(in, 0.45, [0.173, 0.191], 1.4);
    };
    Ndef(\clockMaster).set(\wet10, 0, \wet11, 0);
    Ndef(\clockMaster).play;
    s.sync;

    Pbindef(\clockworkTicks,
        \instrument, \brassTick,
        \out, ~synthBus,
        \dur, Pseq([0.5, 0.47, 0.53, 0.49, 0.25, 0.75], inf),
        \freq, Pseq([1900, 2100, 1760, 2300, 2840, 1600], inf),
        \decay, Pwhite(0.055, 0.16, inf),
        \amp, Pseq([0.045, 0.06, 0.04, 0.055, 0.035, 0.065], inf),
        \pan, Pwhite(-0.75, 0.75, inf)
    );
    Pbindef(\clockworkBells,
        \instrument, \bellTooth,
        \out, ~synthBus,
        \dur, Pseq([4, 7, 5, 6], inf),
        \freq, Pseq([659.25, 783.99, 880, 587.33], inf),
        \sustain, Pwhite(0.65, 1.5, inf),
        \amp, 0.045,
        \pan, Pwhite(-0.5, 0.5, inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - [Cue 1: Brass teeth begin to disagree]".postln;
        Ndef(\clockBreath).fadeTime = 5;
        Ndef(\clockBreath).xset(\amp, 0.14, \cutoff, 1200);
        Ndef(\clockMaster).set(\wet10, 0.18);
        Pbindef(\clockworkTicks).play;
        5.do { |step|
            Ndef(\clockBreath).xset(\rate, 0.06 + (step * 0.025), \cutoff, 800 + (step * 330));
            3.wait;
        };

        "0:15 - [Cue 2: French chimes enter the swarm]".postln;
        Pbindef(\clockworkBells).play;
        Ndef(\gearCloud).fadeTime = 3;
        Ndef(\gearCloud).xset(\density, 8, \amp, 0.07);
        Ndef(\clockMaster).set(\wet10, 0.38, \wet11, 0.22);
        5.do { |step|
            Ndef(\gearCloud).xset(\density, 8 + (step * 5), \brightness, 0.8 + (step * 0.22));
            3.wait;
        };

        "0:30 - [Cue 3: The clockmaker closes his eyes]".postln;
        Pbindef(\clockworkTicks, \dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1], inf),
            \amp, Pseq([0.035, 0.035, 0.055, 0.04, 0.03, 0.06], inf));
        Ndef(\gearCloud).fadeTime = 2;
        Ndef(\gearCloud).xset(\amp, 0);
        Ndef(\clockBreath).fadeTime = 6;
        Ndef(\clockBreath).xset(\rate, 0.035, \cutoff, 620, \amp, 0.11);
        Ndef(\clockMaster).set(\wet10, 0.5, \wet11, 0.12);
        4.do { |step|
            if(step == 2) {
                Synth(\bellTooth, [\out, ~synthBus, \freq, 880, \amp, 0.055, \sustain, 2.4, \pan, 0]);
            };
            3.wait;
        };

        "0:42 - [Cue 4: Return to the first brass pulse]".postln;
        Pbindef(\clockworkTicks, \dur, Pseq([0.5, 0.47, 0.53, 0.49, 0.25, 0.75], inf),
            \freq, Pseq([1900, 2100, 1760, 2300, 2840, 1600], inf));
        Ndef(\clockBreath).xset(\rate, 0.09, \cutoff, 1200, \amp, 0.07);
        Ndef(\clockMaster).set(\wet10, 0.2, \wet11, 0);
        3.wait;

        "0:45 - [Extrinsic limit: the last tick]".postln;
        Pbindef(\clockworkTicks).stop;
        Pbindef(\clockworkTicks).clear;
        Pbindef(\clockworkBells).stop;
        Pbindef(\clockworkBells).clear;
        Ndef(\clockBreath).clear(2);
        Ndef(\gearCloud).clear(2);
        Ndef(\clockMaster).clear(2);
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
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
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
    var zoneArgs;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 67, hpf1: 25, lpf1: 180, rq1: 0.45, atk1: 0.01, dec1: 0.3, sus1: 0.72, rls1: 0.7, fx1: 0.0,
        vol2: 0.18, pan2: 0.25, mute2: 0.0, min2: 42, max2: 127, hpf2: 350, lpf2: 6500, rq2: 0.35, atk2: 0.005, dec2: 0.4, sus2: 0.0, rls2: 0.65, fx2: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { Array.new });

    SynthDef(\scopeBody, { |out=0, freq=110, amp=0.2, gate=1, vol=0.22, pan=0, mute=0, hpf=25, lpf=180, rq=0.45, fx=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(0.01, 0.3, 0.72, 0.7), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 0.5) * (freq * (1.2 + (fx * 4)));
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.003) * 0.45);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(20, 18000), rq.clip(0.05, 1));
        sig = (sig * (1 + (fx * 3))).tanh;
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1 - mute), pan));
    }).add;

    SynthDef(\scopePins, { |out=0, freq=440, amp=0.2, gate=1, vol=0.18, pan=0.25, mute=0, hpf=350, lpf=6500, rq=0.35, fx=0|
        var env, exc, partial, sig, sweep;
        env = EnvGen.kr(Env.adsr(0.005, 0.4, 0.0, 0.65), gate, doneAction: 2);
        exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.018));
        partial = SinOsc.ar(freq * 2.71) * 0.35 + SinOsc.ar(freq * 3.51) * 0.22;
        sig = CombL.ar(exc + partial, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.2);
        sweep = SinOsc.kr(0.17).range(0.75, 1.25);
        sig = AllpassC.ar(sig, 0.02, (0.0005 + (fx * 0.008)).clip(0.0005, 0.02), 0.08);
        sig = RLPF.ar(HPF.ar(sig, hpf), (lpf * sweep).clip(20, 18000), rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1 - mute), pan));
    }).add;

    SynthDef(\scopeSpace, { |in=0, delMix=0, verbMix=0|
        var sig, delayed, verb;
        sig = In.ar(in, 2);
        delayed = CombC.ar(sig, 0.5, [0.173, 0.191], 1.5);
        verb = FreeVerb2.ar(sig[0], sig[1], 1, 0.78, 0.3);
        Out.ar(0, XFade2.ar(sig, delayed, delMix.clip(0, 1) * 2 - 1)
            + (XFade2.ar(sig, verb, verbMix.clip(0, 1) * 2 - 1) - sig));
    }).add;

    SynthDef(\safetyLimiter, {
        var sig;
        sig = LeakDC.ar(In.ar(0, 2));
        ReplaceOut.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;

    s.sync;

    ~spaceFx = Synth.tail(~fxGroup, \scopeSpace, [\in, ~audioBus, \delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap]);
    ~safety = Synth.tail(~masterGroup, \safetyLimiter);

    zoneArgs = [
        [\vol, \vol1, \pan, \pan1, \mute, \mute1, \hpf, \hpf1, \lpf, \lpf1, \rq, \rq1, \fx, \fx1],
        [\vol, \vol2, \pan, \pan2, \mute, \mute2, \hpf, \hpf2, \lpf, \lpf2, \rq, \rq2, \fx, \fx2]
    ];

    MIDIdef.cc(\scopeCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.contains("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.contains("min|") or: { ks.contains("max") } } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("vol") or: { ks.contains("fx") } or: { ks.contains("Mix") } } { norm }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\scopeOn, { |vel, noteNum|
        var amp;
        amp = vel / 127.0;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\scopeBody, zoneArgs[0] ++ [\out, ~audioBus, \freq, noteNum.midicps, \amp, amp],
                    ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\scopePins, zoneArgs[1] ++ [\out, ~audioBus, \freq, noteNum.midicps, \amp, amp],
                    ~synthGroup)
            );
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\scopeOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |voice| voice.set(\gate, 0) };
        ~zoneNotes[noteNum] = Array.new;
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 0) {
            128.do { |n| ~zoneNotes[n].do { |voice| voice.set(\gate, 0) }; ~zoneNotes[n] = Array.new };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, w, h, pages, zoneMeta, bottom;
        if(~mainWin.notNil) { ~mainWin.close };
        bounds = Window.availableBounds;
        w = 680;
        h = min(760, bounds.height - 60);
        ~mainWin = Window("PHOSPHOR / Lissajous Modular", Rect(bounds.left + ((bounds.width - w) / 2), bounds.top + ((bounds.height - h) / 2), w, h), scroll: true).front;
        ~ui = ();
        pages = [CompositeView(~mainWin, Rect(0, 0, w, h - 80)), CompositeView(~mainWin, Rect(0, 0, w, h - 80))];
        zoneMeta = [
            (title: "01  ROTATING CORE — FM BODY", keys: [\vol1, \pan1, \mute1, \min1, \max1, \hpf1, \lpf1, \rq1, \fx1]),
            (title: "02  PHOSPHOR PINS — RESONANT TRACE", keys: [\vol2, \pan2, \mute2, \min2, \max2, \hpf2, \lpf2, \rq2, \fx2])
        ];
        zoneMeta.do { |zm, pageIdx|
            var page, title;
            page = pages[pageIdx];
            title = StaticText(page, Rect(20, 14, 620, 32));
            title.string = zm[\title];
            title.font = Font("Helvetica", 18);
            zm[\keys].do { |key, idx|
                var y, label, slider, spec;
                y = 58 + (idx * 58);
                label = key.asString;
                spec = case
                    { label.contains("lpf") } { ControlSpec(20, 18000, \exp, 0, ~ccVals[key]) }
                    { label.contains("hpf") } { ControlSpec(20, 18000, \exp, 0, ~ccVals[key]) }
                    { label.contains("min") or: { label.contains("max") } } { ControlSpec(0, 127, \lin, 1, ~ccVals[key]) }
                    { label.contains("pan") } { ControlSpec(-1, 1, \lin, 0, ~ccVals[key]) }
                    { label.contains("mute") } { ControlSpec(0, 1, \lin, 1, ~ccVals[key]) }
                    { label.contains("rq") } { ControlSpec(0.05, 1, \lin, 0, ~ccVals[key]) }
                    { ControlSpec(0, 1, \lin, 0, ~ccVals[key]) };
                slider = EZSlider(page, Rect(20, y, 620, 48), label ++ "  CC " ++ ~cc[key].asString, spec, { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) }, ~ccVals[key], layout: \horz);
                ~ui[key] = slider;
            };
        };
        bottom = CompositeView(~mainWin, Rect(0, h - 78, w, 78));
        [\delMix, \verbMix].do { |key, idx|
            var slider;
            slider = EZSlider(bottom, Rect(12 + (idx * 250), 8, 230, 48), key.asString ++ " CC " ++ ~cc[key].asString,
                ControlSpec(0, 1, \lin, 0, ~ccVals[key]), { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) }, ~ccVals[key], layout: \horz);
            ~ui[key] = slider;
        };
        Button(bottom, Rect(510, 14, 150, 38)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({
            128.do { |n| ~zoneNotes[n].do { |voice| voice.set(\gate, 0) }; ~zoneNotes[n] = Array.new };
        });
        Routine({
            while { ~ui.notNil and: { ~mainWin.notNil and: { ~mainWin.isClosed.not } } } {
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


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Layer 1: Processional low drum and harmonic foundation
Ndef(\congadaGround, { |freq=55, amp=0.14, pan=0, t_trig=0, tone=0.25|
    var env, body, pulse, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.004, 0.42);
    pulse = SinOsc.ar(freq * (1 + (env * 1.8))) * env;
    body = (SinOsc.ar(freq) * 0.55) + (SinOsc.ar(freq * 2) * 0.32);
    sig = body + (pulse * tone);
    Pan2.ar(sig * amp, pan);
}).fadeTime = 3;
Ndef(\congadaGround).play;

Ndef(\congadaGround)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35);
};
Ndef(\congadaGround).set(\wet10, 0.22);

Pbindef(\congadaGroundSeq,
    \dur, Pseq([1, 0.5, 0.5, 1.5, 0.5], inf),
    \midinote, Pseq([36, 36, 43, 36, 31, 36, 38, 36], inf),
    \freq, Pkey(\midinote).midicps,
    \tone, Pwhite(0.15, 0.4, inf),
    \amp, Pwhite(0.11, 0.16, inf),
    \pan, Pwhite(-0.12, 0.12, inf),
    \t_trig, 1
);
Ndef(\congadaGround).quant = 1;
Ndef(\congadaGround)[1] = \set -> Pbindef(\congadaGroundSeq);

// Layer 2: Cadenced metallic gungas and interlocking footfall rhythm
Ndef(\congadaGungas, { |freq=880, amp=0.11, pan=0, t_trig=0, ring=1.2, brightness=0.35|
    var env, mod, bell, rattle, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, ring);
    mod = SinOsc.ar(freq * 2.71) * (freq * brightness * env);
    bell = SinOsc.ar((freq + mod).clip(40, 12000)) * env;
    rattle = HPF.ar(WhiteNoise.ar, 4200) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.045);
    sig = bell * 0.7 + (rattle * 0.12);
    Pan2.ar(sig * amp, pan);
}).fadeTime = 2;
Ndef(\congadaGungas).play;

Ndef(\congadaGungas)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.28);
};
Ndef(\congadaGungas).set(\wet10, 0.28);

Pbindef(\congadaGungaSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.35, 0.1], inf),
    \midinote, Pseq([84, 91, 96, 88, 94, 103, 91, 98, 86, 96], inf),
    \freq, Pkey(\midinote).midicps,
    \ring, Pwhite(0.55, 1.35, inf),
    \brightness, Pwhite(0.18, 0.42, inf),
    \amp, Pwhite(0.07, 0.12, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \t_trig, 1
);
Ndef(\congadaGungas).quant = 1;
Ndef(\congadaGungas)[1] = \set -> Pbindef(\congadaGungaSeq);

// Layer 3: Modal call-and-response of the Congada procession
Ndef(\congadaSong, { |freq=440, amp=0.095, pan=0, t_trig=0, color=0.4|
    var env, mod, voice, overtone, sig;
    env = EnvGen.ar(Env([0, 1, 0.72, 0], [0.025, 0.22, 0.5]), t_trig);
    mod = SinOsc.ar(freq * 2.01) * (freq * color * env);
    voice = SinOsc.ar(freq + mod);
    overtone = SinOsc.ar(freq * 1.5, 0, 0.22) + SinOsc.ar(freq * 2, 0, 0.12);
    sig = (voice + overtone) * env;
    Pan2.ar(sig * amp, pan);
}).fadeTime = 4;
Ndef(\congadaSong).play;

Ndef(\congadaSong)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.8, 0.32);
};
Ndef(\congadaSong).set(\wet10, 0.32);

Pbindef(\congadaSongSeq,
    \dur, Pseq([2, 1, 1, 2, 1, 3], inf),
    \midinote, Pseq([60, 64, 67, 72, 69, 67, 62, 65, 69, 74, 72, 67], inf),
    \freq, Pkey(\midinote).midicps,
    \color, Pwhite(0.18, 0.55, inf),
    \amp, Pwhite(0.07, 0.105, inf),
    \pan, Pwhite(-0.45, 0.45, inf),
    \t_trig, 1
);
Ndef(\congadaSong).quant = 1;
Ndef(\congadaSong)[1] = \set -> Pbindef(\congadaSongSeq);

// Live adjustments and rollbacks
// Ndef(\congadaGround).xset(\tone, 0.4); // Thicken drum harmonics | Revert: Ndef(\congadaGround).xset(\tone, 0.25);
// Pbindef(\congadaGungaSeq, \dur, 0.25); // Tighten the ankle-bell pulse | Revert: Pbindef(\congadaGungaSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.35, 0.1], inf));
// Pbindef(\congadaGroundSeq).stop; Ndef(\congadaGround).fadeTime = 4; Ndef(\congadaGround).clear(4); // Rollback ground
// Pbindef(\congadaGungaSeq).stop; Ndef(\congadaGungas).fadeTime = 4; Ndef(\congadaGungas).clear(4); // Rollback gungas
// Pbindef(\congadaSongSeq).stop; Ndef(\congadaSong).fadeTime = 4; Ndef(\congadaSong).clear(4); // Rollback song
)

