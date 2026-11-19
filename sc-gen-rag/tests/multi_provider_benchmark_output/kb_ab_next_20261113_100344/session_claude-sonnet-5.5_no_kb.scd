// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Sonnet 5.5
// Model ID: openrouter:anthropic/claude-sonnet-5.5
// Date: 2026-11-13T13:11:01.642237+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Restaurant ambience: a low room-tone drone, a suspended wine-bottle glass, and tense map-folding ticks
Ndef(\roomTone, {
    |freq=55, amp=0.12, pan=0, cutoff=400|
    var sig, noise, sub;
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4) + (Saw.ar(freq * 1.005) * 0.15);
    noise = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.1).range(0.7, 1.4), 0.5) * 2.0;
    sig = LPF.ar(sub + noise, cutoff * 2);
    sig = sig * LFNoise1.kr(0.2).range(0.7, 1.0);
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\glassTension, {
    |freq=880, amp=0.08, pan=0, t_trig=0, decay=6|
    var env, exc, sig;
    env = EnvGen.ar(Env.perc(0.5, 3), t_trig);
    exc = BPF.ar(WhiteNoise.ar, freq, 0.05) * 8.0 * env;
    sig = DynKlank.ar(
        Ref([[freq, freq * 2.76, freq * 5.4, freq * 1.5], [0.5, 0.3, 0.2, 0.25], [decay, decay * 0.7, decay * 0.5, decay * 0.8]]),
        exc,
        decayscale: 1
    );
    sig = sig * 0.2;
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\mapFold, {
    |freq=2200, amp=0.15, pan=0, t_trig=0, rel=0.06, cutoff=5000|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.002, rel, 1, -6), t_trig);
    sig = BPF.ar(WhiteNoise.ar, freq, 0.3) * 3.0;
    sig = HPF.ar(sig, 1200);
    sig = LPF.ar(sig, cutoff);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\glassSeq,
    \dur, Pseq([8, 6, 10, 12], inf),
    \t_trig, 1,
    \freq, Pseq([880, 932, 987, 830], inf),
    \amp, Pwhite(0.06, 0.12, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \decay, Pwhite(4, 8, inf)
);
Ndef(\glassTension)[1] = \set -> Pbindef(\glassSeq);

Pbindef(\foldSeq,
    \dur, Pseq([0.5, 0.5, 0.25, 0.25, 1, 2], inf),
    \t_trig, 1,
    \freq, Pwhite(1800, 3600, inf),
    \rel, Pwhite(0.04, 0.14, inf),
    \cutoff, Pwhite(3500, 7000, inf),
    \amp, Pwhite(0.08, 0.2, inf),
    \pan, Pwhite(-0.8, 0.8, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\foldSeq);

// Effects: spacious restaurant reverb, wet at 0
Ndef(\glassTension)[10] = \filter -> { |in|
    FreeVerb.ar(in, 0.8, 0.9, 0.4);
};
Ndef(\glassTension).set(\wet10, 0);
// Ndef(\glassTension).set(\wet10, 0); // Rollback: disable this effect

// Rollback commented lines
// Pbindef(\glassSeq).stop; Ndef(\glassTension).fadeTime = 2; Ndef(\glassTension).clear(2); // Rollback: remove this instrument
// Pbindef(\foldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument
// Ndef(\roomTone).fadeTime = 2; Ndef(\roomTone).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
    var tickRoutine;
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Brass escapement tick
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.2, pan=0, dur=0.1, ring=0.3|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, (dur * 0.8).max(0.05), 1, -6), doneAction: 2);
        exc = Decay2.ar(Impulse.ar(0), 0.0005, 0.004) * WhiteNoise.ar;
        sig = DynKlank.ar(Ref([[freq, freq * 2.43, freq * 3.9, freq * 5.7], [0.6, 0.4, 0.3, 0.15], [0.08, 0.06, 0.04, 0.03]]), exc * 6, decayscale: ring);
        sig = (sig * 2).tanh * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    // Carillon chime bell FM
    SynthDef(\frenchChime, { |out=0, freq=660, amp=0.15, pan=0, dur=4|
        var env, idx, mod, sig;
        env = EnvGen.ar(Env.perc(0.003, (dur - 0.2).max(0.5), 1, -5), doneAction: 2);
        idx = EnvGen.ar(Env.perc(0.001, 0.6)) * 3;
        mod = SinOsc.ar(freq * 2.71) * freq * idx;
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 4.1) * 0.15 * env);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;
    s.sync;

    // Breathing of time: filtered noise swell
    Ndef(\timeBreath, { |amp=0, cutoff=500|
        var sig = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.15).range(0.6, 1.5), 0.3) * 3;
        sig = sig * (SinOsc.kr(0.2).range(0.3, 1));
        sig = sig + (SinOsc.ar([55, 55.4]) * 0.2);
        Splay.ar(sig * amp);
    });
    Ndef(\brassHum, { |amp=0, freq=220|
        var sig = Mix.fill(6, { |i| SinOsc.ar(freq * (i + 1) * (1 + (i * 0.003)), 0, 0.15 / (i + 1)) });
        sig = sig * LFNoise1.kr(0.3).range(0.5, 1);
        Splay.ar([sig, DelayC.ar(sig, 0.05, 0.02)] * amp);
    });
    s.sync;

    Ndef(\masterMix, {
        var a = In.ar(~synthBus, 2);
        a + Ndef.ar(\timeBreath, 2) + Ndef.ar(\brassHum, 2);
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.8, 0.3) };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - Cue 1: a few ticks".postln;
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.15);
        Ndef(\masterMix).set(\wet10, 0.25);
        Pbindef(\ticks,
            \instrument, \brassTick, \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.25, 0.75], inf),
            \freq, Pwhite(1800, 3200, inf),
            \amp, Pwhite(0.05, 0.12, inf),
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;
        8.do { Ndef(\timeBreath).xset(\cutoff, exprand(300, 1500)); 1.wait; };

        "0:09 - Cue 2: swarm of 200 clocks".postln;
        Pbindef(\ticks, \dur, Pwhite(0.08, 0.22, inf), \amp, Pwhite(0.04, 0.14, inf), \freq, Pwhite(1200, 5000, inf));
        Pbindef(\swarm2,
            \instrument, \brassTick, \out, ~synthBus,
            \dur, Pwhite(0.1, 0.19, inf), \freq, Pwhite(900, 4200, inf),
            \amp, Pwhite(0.03, 0.1, inf), \pan, Pwhite(-1.0, 1.0, inf), \ring, Pwhite(0.5, 2, inf)
        ).play;
        Ndef(\brassHum).fadeTime = 5;
        Ndef(\brassHum).xset(\amp, 0.12);
        8.do { Ndef(\brassHum).xset(\freq, [220, 233, 247, 196].choose); 1.5.wait; };

        "0:21 - Cue 3: carillon chimes".postln;
        Pbindef(\chimes,
            \instrument, \frenchChime, \out, ~synthBus,
            \dur, Pseq([3, 2, 4, 3], inf),
            \freq, Pseq([523, 659, 784, 587, 698], inf),
            \amp, Pwhite(0.08, 0.14, inf), \pan, Pwhite(-0.5, 0.5, inf)
        ).play;
        Ndef(\masterMix).set(\wet10, 0.4);
        6.do { Ndef(\timeBreath).xset(\cutoff, exprand(400, 2500)); 2.wait; };

        "0:33 - Cue 4: dephasing peak".postln;
        Pbindef(\ticks, \dur, Pwhite(0.03, 0.08, inf));
        Pbindef(\swarm2, \dur, Pwhite(0.03, 0.09, inf));
        Ndef(\timeBreath).xset(\amp, 0.25);
        6.do { |i| Ndef(\brassHum).xset(\freq, 220 * (1 + (i * 0.01))); 1.wait; };

        "0:39 - Cue 5: settling, only the breath".postln;
        Pbindef(\ticks).stop; Pbindef(\swarm2).stop; Pbindef(\chimes).stop;
        Ndef(\brassHum).xset(\amp, 0);
        Ndef(\timeBreath).fadeTime = 3;
        Ndef(\timeBreath).xset(\amp, 0.18);
        Pbindef(\lone,
            \instrument, \brassTick, \out, ~synthBus,
            \dur, Pseq([2, 2, 3], inf), \freq, 2400, \amp, 0.12, \pan, 0, \ring, 1
        ).play;
        6.do { 1.wait; };
        Pbindef(\lone).stop;
        Ndef(\timeBreath).xset(\amp, 0);
        4.wait;

        "Score Complete.".postln;
        Pbindef(\ticks).clear; Pbindef(\swarm2).clear; Pbindef(\chimes).clear; Pbindef(\lone).clear;
        Ndef(\timeBreath).clear(2); Ndef(\brassHum).clear(2); Ndef(\masterMix).clear(2);
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
    vol1:20, pan1:21, mute1:22, hpf1:23, lpf1:24, rq1:25, atk1:26, dec1:27, sus1:28, rls1:29, fx1:30,
    vol2:31, pan2:32, mute2:33, hpf2:34, lpf2:35, rq2:36, atk2:37, dec2:38, sus2:39, rls2:40, fx2:41,
    vol3:42, pan3:43, mute3:44, hpf3:45, lpf3:46, rq3:47, atk3:48, dec3:49, sus3:50, rls3:51, fx3:52,
    min1:53, max1:54, min2:55, max2:56, min3:57, max3:58,
    delMix:59, revMix:60, panic:123
);

// Step 1 & 2: MIDI discovery with fallback
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

// Step 3: boot
s.waitForBoot({
    ~ccVals = (
        vol1:0.28, pan1:0.0, mute1:0.0, hpf1:30, lpf1:900, rq1:0.5, atk1:0.01, dec1:0.3, sus1:0.8, rls1:0.6, fx1:0.0,
        vol2:0.2, pan2:(-0.35), mute2:0.0, hpf2:300, lpf2:6000, rq2:0.4, atk2:0.005, dec2:0.5, sus2:0.2, rls2:0.8, fx2:0.0,
        vol3:0.16, pan3:0.35, mute3:0.0, hpf3:160, lpf3:3200, rq3:0.5, atk3:0.8, dec3:0.5, sus3:0.8, rls3:2.0, fx3:0.0,
        min1:0, max1:65, min2:36, max2:100, min3:30, max3:127,
        delMix:0.0, revMix:0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~fxBus = Bus.audio(s, 2);

    // Zone 1: Lissajous Sub (phase-locked sine pair, wavefolded)
    SynthDef(\lissSub, { |out=0, freq=60, gate=1, vol=0.2, pan=0, mute=0, hpf=30, lpf=900, rq=0.5, atk=0.01, dec=0.3, sus=0.8, rls=0.6, fx=0|
        var env, f, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        f = Lag.kr(freq, 0.08);
        sig = SinOsc.ar(f) + SinOsc.ar(f * 1.5 * (1 + (SinOsc.kr(0.13) * 0.002)), pi/2) * 0.5;
        sig = Fold.ar(sig * (1.0 + (fx * 5.0)), -0.8, 0.8);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000), rq);
        Out.ar(out, Pan2.ar(sig * env * (1 - mute), pan, vol));
    }).add;

    // Zone 2: Patch-pin FM pluck with comb dispersion
    SynthDef(\pinPluck, { |out=0, freq=440, gate=1, vol=0.2, pan=0, mute=0, hpf=300, lpf=6000, rq=0.4, atk=0.005, dec=0.5, sus=0.2, rls=0.8, fx=0|
        var env, mod, sig, ex;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 2.71) * freq * EnvGen.ar(Env.perc(0.001, 0.4)) * 3;
        sig = SinOsc.ar(freq + mod);
        ex = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        sig = sig * 0.6 + CombL.ar(ex, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.5);
        sig = AllpassC.ar(sig, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(100, 18000), rq);
        Out.ar(out, Pan2.ar(sig * env * (1 - mute), pan, vol));
    }).add;

    // Zone 3: Phosphor pad (detuned stereo saws, rotating phase)
    SynthDef(\phosphorPad, { |out=0, freq=220, gate=1, vol=0.16, pan=0, mute=0, hpf=160, lpf=3200, rq=0.5, atk=0.8, dec=0.5, sus=0.8, rls=2.0, fx=0|
        var env, sig, rot;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = Splay.ar(Saw.ar(freq * [0.98, 0.99, 1, 1.01, 1.02]));
        rot = SinOsc.ar(0.1 + (fx * 4), [0, pi/2]).range(0.3, 1);
        sig = sig * rot;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(100, 18000), rq);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, vol) } { Pan2.ar(sig, pan, vol) } * env * (1 - mute));
    }).add;

    SynthDef(\fxMaster, { |in=0, out=0, delMix=0, revMix=0|
        var dry, del, rev, sig;
        dry = In.ar(in, 2);
        del = CombL.ar(dry, 1.0, 0.375, 3);
        sig = dry + (del * delMix);
        rev = FreeVerb2.ar(sig[0], sig[1], 1.0, 0.8, 0.5);
        sig = XFade2.ar(sig, rev, (revMix * 2) - 1);
        sig = LeakDC.ar(sig);
        Out.ar(out, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    ~fxSynth = Synth(\fxMaster, [\in, ~fxBus, \out, 0,
        \delMix, ~buses[\delMix].asMap, \revMix, ~buses[\revMix].asMap], ~masterGroup, \addToTail);

    ~zoneNotes = Array.fill(3, { Array.newClear(128) });
    ~subSynth = nil;
    ~names = [\lissSub, \pinPluck, \phosphorPad];
    ~stdKeys = [\vol, \pan, \mute, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx];

    MIDIdef.noteOn(\synthOn, { |vel, noteNum|
        3.do { |z|
            var n = z + 1, lo = ~ccVals[("min" ++ n).asSymbol], hi = ~ccVals[("max" ++ n).asSymbol];
            var args, syn;
            if((noteNum >= lo) and: { noteNum <= hi }) {
                args = [\out, ~fxBus, \freq, noteNum.midicps, \vol, ~ccVals[("vol" ++ n).asSymbol] * (vel / 127.0 + 0.3)];
                ~stdKeys.do { |k|
                    if(k != \vol) { args = args ++ [k, ~buses[(k.asString ++ n).asSymbol].asMap] };
                };
                if(z == 0) {
                    if(~subSynth.notNil) { ~subSynth.set(\freq, noteNum.midicps) } {
                        ~subSynth = Synth(~names[z], args, ~synthGroup);
                        ~zoneNotes[0][noteNum] = [~subSynth];
                    };
                } {
                    syn = Synth(~names[z], args, ~synthGroup);
                    ~zoneNotes[z][noteNum] = ~zoneNotes[z][noteNum].add(syn);
                };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\synthOff, { |vel, noteNum|
        3.do { |z| if(z > 0) { ~zoneNotes[z][noteNum].do(_.set(\gate, 0)); ~zoneNotes[z][noteNum] = nil } };
        if(~subSynth.notNil) {
            ~subSynth.set(\gate, 0);
            ~subSynth = nil;
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
                    { norm };
                if(ks != "panic") {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);

    ~panicAll = {
        ~synthGroup.set(\gate, 0);
        ~subSynth = nil;
        ~zoneNotes = Array.fill(3, { Array.newClear(128) });
    };
    MIDIdef.cc(\panic, { |val| if(val > 63) { ~panicAll.value } }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var screen = Window.availableBounds;
        var h = min(780, screen.height - 60);
        var zoneMeta, pages, tabs, yBase;
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("Lissajous Modular Cabinet", Rect(screen.left + ((screen.width - 980) / 2), screen.top + 20, 980, h), scroll: true).front;
        ~mainWin.background = Color(0.05, 0.1, 0.06);
        ~ui = ();
        zoneMeta = [
            (title: "Z1 Phase Sub", fxKey: \fx1, fxLabel: "Fold"),
            (title: "Z2 Pin Pluck", fxKey: \fx2, fxLabel: "Dispersion"),
            (title: "Z3 Phosphor Pad", fxKey: \fx3, fxLabel: "Rotation")
        ];
        pages = List.new;
        tabs = List.new;
        zoneMeta.do { |zm, idx|
            var n = idx + 1;
            var page = CompositeView(~mainWin, Rect(10, 50, 960, 600)).background_(Color(0.08, 0.16, 0.1));
            var keys = [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls];
            var rng;
            pages.add(page);
            StaticText(page, Rect(10, 5, 400, 25)).string_(zm[\title]).stringColor_(Color.green);
            tabs.add(Button(~mainWin, Rect(10 + (idx * 150), 10, 140, 30))
                .states_([[zm[\title], Color.white, Color(0.1, 0.25, 0.15)]])
                .action_({ pages.do(_.visible_(false)); page.visible_(true) }));
            page.visible_(idx == 0);
            ~ui[("mute" ++ n).asSymbol] = Button(page, Rect(420, 5, 80, 25))
                .states_([["Mute", Color.white, Color.gray], ["MUTED", Color.black, Color.red]])
                .action_({ |b| var v = b.value.asFloat; ~ccVals[("mute" ++ n).asSymbol] = v; ~buses[("mute" ++ n).asSymbol].set(v) });
            rng = EZRanger(page, Rect(10, 40, 500, 25), "Keys " ++ ~cc[("min" ++ n).asSymbol] ++ "/" ++ ~cc[("max" ++ n).asSymbol],
                ControlSpec(0, 127, \lin, 1), { |ez|
                    ~ccVals[("min" ++ n).asSymbol] = ez.lo; ~ccVals[("max" ++ n).asSymbol] = ez.hi;
                    ~buses[("min" ++ n).asSymbol].set(ez.lo); ~buses[("max" ++ n).asSymbol].set(ez.hi);
                }, [~ccVals[("min" ++ n).asSymbol], ~ccVals[("max" ++ n).asSymbol]]);
            keys.do { |k, j|
                var kk = (k.asString ++ n).asSymbol;
                var spec = case
                    { (k == \hpf) or: { k == \lpf } } { ControlSpec(20, 18000, \exp) }
                    { k == \rq } { ControlSpec(0.05, 1.0, \lin) }
                    { k == \pan } { ControlSpec(-1, 1, \lin) }
                    { (k == \atk) or: { k == \dec } or: { k == \sus } or: { k == \rls } } { ControlSpec(0.005, 5.0, \exp) }
                    { ControlSpec(0, 1, \lin) };
                ~ui[kk] = EZKnob(page, Rect(10 + ((j % 6) * 90), 80 + ((j div: 6) * 110), 80, 90),
                    k.asString ++ " " ++ ~cc[kk], spec, { |ez| ~ccVals[kk] = ez.value; ~buses[kk].set(ez.value) }, ~ccVals[kk]);
            };
            ~ui[zm[\fxKey]] = EZKnob(page, Rect(10, 310, 80, 90), zm[\fxLabel] ++ " " ++ ~cc[zm[\fxKey]],
                ControlSpec(0, 1, \lin), { |ez| ~ccVals[zm[\fxKey]] = ez.value; ~buses[zm[\fxKey]].set(ez.value) }, 0.0);
        };
        yBase = h - 90;
        ~ui[\delMix] = EZSlider(~mainWin, Rect(10, yBase, 300, 25), "Delay " ++ ~cc[\delMix], ControlSpec(0, 1),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, 0.0);
        ~ui[\revMix] = EZSlider(~mainWin, Rect(320, yBase, 300, 25), "Reverb " ++ ~cc[\revMix], ControlSpec(0, 1),
            { |ez| ~ccVals[\revMix] = ez.value; ~buses[\revMix].set(ez.value) }, 0.0);
        Button(~mainWin, Rect(640, yBase, 200, 30))
            .states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({ ~panicAll.value });

        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil } and: { k.asString.contains("mute").not }
                            and: { k.asString.matchRegexp("min|max").not }) { ~ui[k].value = v };
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
// Congada: sub drum bed, gunga tin shakers, caixa/agogo bell voice, canopy
Ndef(\congaBombo).fadeTime = 1;
Ndef(\congaBombo, { |t_trig=0, freq=55, amp=0.26, pan=0|
	var env, pitchEnv, sig, click;
	env = EnvGen.ar(Env.perc(0.004, 0.6, 1, -6), t_trig);
	pitchEnv = EnvGen.ar(Env.perc(0.001, 0.12, 1, -6), t_trig);
	sig = SinOsc.ar(freq * (1 + (pitchEnv * 1.8)));
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	click = LPF.ar(WhiteNoise.ar, 1800) * EnvGen.ar(Env.perc(0.001, 0.02), t_trig) * 0.3;
	sig = ((sig * env * 1.6).tanh + click) * amp;
	Pan2.ar(sig, pan);
}).play;

Ndef(\congaGunga).fadeTime = 1;
Ndef(\congaGunga, { |t_trig=0, freq=5200, amp=0.12, pan=0, rq=0.25|
	var env, noise, sig, ring;
	env = Decay2.ar(K2A.ar(t_trig), 0.002, 0.11);
	noise = WhiteNoise.ar;
	sig = BPF.ar(noise, freq * [1, 1.31, 1.77], rq).sum * 6;
	ring = Ringz.ar(noise * Decay.ar(K2A.ar(t_trig), 0.005), freq * 0.7, 0.15) * 0.15;
	sig = HPF.ar((sig + ring) * env, 2500);
	Pan2.ar(sig * amp, pan);
}).play;

Ndef(\congaAgogo).fadeTime = 2;
Ndef(\congaAgogo, { |t_trig=0, freq=660, amp=0.15, pan=0.3|
	var env, idxEnv, mod, sig;
	env = EnvGen.ar(Env.perc(0.002, 0.7, 1, -7), t_trig);
	idxEnv = EnvGen.ar(Env.perc(0.001, 0.15, 1, -5), t_trig);
	mod = SinOsc.ar(freq * 1.504) * freq * (0.5 + (idxEnv * 3));
	sig = SinOsc.ar(freq + mod) * env;
	sig = sig + (SinOsc.ar(freq * 2.76) * env * 0.2);
	Pan2.ar(sig * amp, pan);
}).play;

Ndef(\congaCanopy).fadeTime = 4;
Ndef(\congaCanopy, {
	var wind, lfo, sig;
	lfo = SinOsc.kr(0.07).range(900, 2600);
	wind = BPF.ar(PinkNoise.ar, lfo, 0.3) * 8;
	sig = Splay.ar([wind, BPF.ar(PinkNoise.ar, lfo * 1.3, 0.3) * 8]);
	sig = sig + (Splay.ar(SinOsc.ar([110, 165, 220.5] * LFNoise1.kr(0.1).range(0.99, 1.01)) * 0.05));
	if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, 0.1) } { Pan2.ar(sig, 0, 0.1) };
}).play;

Ndef(\congaAgogo)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.5, 0.5) };
Ndef(\congaAgogo).set(\wet10, 0.25);
Ndef(\congaCanopy)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.4) };
Ndef(\congaCanopy).set(\wet10, 0.4);

Pbindef(\congaBomboSeq,
	\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25], inf),
	\freq, Pwrand([55, 62, 49], [0.7, 0.2, 0.1], inf),
	\amp, Pseq([0.3, 0.18, 0.2, 0.26, 0.28, 0.18, 0.22], inf),
	\pan, Pwhite(-0.1, 0.1, inf),
	\t_trig, 1);
Ndef(\congaBombo).quant = 1;
Ndef(\congaBombo)[1] = \set -> Pbindef(\congaBomboSeq);

Pbindef(\congaGungaSeq,
	\dur, Pwrand([0.125, 0.25, 0.0625], [0.6, 0.3, 0.1], inf),
	\freq, Pexprand(4200, 7500, inf),
	\amp, Pwhite(0.05, 0.16, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\t_trig, 1);
Ndef(\congaGunga).quant = 1;
Ndef(\congaGunga)[1] = \set -> Pbindef(\congaGungaSeq);

Pbindef(\congaAgogoSeq,
	\dur, Pseq([Rest(0.5), 0.5, 0.25, 0.25, Rest(0.5), 0.5, 0.5, 0.5], inf),
	\freq, Pseq([660, 880, 784, 990, 660, 740], inf) * Pwrand([1, 1.5, 0.5], [0.8, 0.1, 0.1], inf),
	\amp, Pwhite(0.1, 0.2, inf),
	\pan, Pwhite(0.1, 0.6, inf),
	\t_trig, 1);
Ndef(\congaAgogo).quant = 1;
Ndef(\congaAgogo)[1] = \set -> Pbindef(\congaAgogoSeq);
)

// Ndef(\congaGunga).xset(\rq, 0.12); // Tighter tin | Revert: Ndef(\congaGunga).xset(\rq, 0.25);
// Pbindef(\congaBomboSeq, \dur, 0.25); // Faster march | Revert: Pbindef(\congaBomboSeq, \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25], inf));
// Ndef(\congaCanopy).set(\wet10, 0.7); // Wetter | Revert: Ndef(\congaCanopy).set(\wet10, 0.4);
// Pbindef(\congaBomboSeq).stop; Ndef(\congaBombo).clear(4); // Rollback bombo
// Pbindef(\congaGungaSeq).stop; Ndef(\congaGunga).clear(4); // Rollback gunga
// Pbindef(\congaAgogoSeq).stop; Ndef(\congaAgogo).clear(4); // Rollback agogo
// Ndef(\congaCanopy).clear(4); // Rollback canopy

