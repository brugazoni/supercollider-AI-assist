// X-Append Lean Prompt 20-Round Stress Test Session


// === Round 01 [APPEND] Frag #149 (conto_cronica) ===
(
// Archetype: Intrinsic Limit (b) / Settling (c) - Frozen tension of the suspended wine bottle and the antarctic silence
// ADD_INSTRUMENT: \mapFold - Dry, papery friction impulses representing the obsessive road map demonstration
Ndef(\mapFold, { |amp=0.18, pan=0, t_trig=0, foldRate=12, resFreq=3200, rq=0.08, decayTime=0.08|
	var trig, env, crackle, sig;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.002, decayTime);
	crackle = PinkNoise.ar * Dust.ar(foldRate * 80);
	sig = BPF.ar(crackle, resFreq, rq) * 12.0;
	sig = Fold.ar(sig * 4.0, -0.6, 0.6);
	Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
	\dur, Pseq([0.15, 0.1, 0.25, 0.1, 0.4, 0.2], inf),
	\t_trig, 1,
	\resFreq, Pseq([2400, 3600, 1800, 4200, 2800], inf),
	\decayTime, Pwhite(0.04, 0.12, inf),
	\pan, Pseq([-0.4, -0.2, 0.3, 0.1, -0.3], inf),
	\amp, Pwhite(0.12, 0.22, inf)
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// ADD_INSTRUMENT: \antarcticSilence - Glacial, ominous sub-frequency tension hanging like the suspended bottle
Ndef(\antarcticSilence, { |freq=48, amp=0.28, pan=0, t_trig=0, tone=180, freeze=0.2|
	var env, sub, harmonic, frostNoise, sig;
	env = EnvGen.ar(Env.perc(0.8, 4.5, 1, -4), K2A.ar(t_trig));
	sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
	harmonic = SinOscFB.ar(freq * 1.5, freeze * 1.2) * 0.2;
	frostNoise = BPF.ar(WhiteNoise.ar, tone, 0.1) * 8.0 * (1 - freeze);
	sig = (sub + harmonic + frostNoise).tanh;
	sig = LPF.ar(sig, tone * 2.5);
	Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\antarcticSeq,
	\dur, Pseq([4.0, 3.5, 5.0], inf),
	\t_trig, 1,
	\freq, Pseq([43.65, 41.2, 46.25], inf), // F1, E1, F#1 micro-dissonances
	\tone, Pseq([140, 190, 120], inf),
	\freeze, Pseq([0.3, 0.7, 0.5], inf),
	\pan, Pseq([0.1, -0.1, 0], inf),
	\amp, 0.3
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSeq);

// ADD_EFFECTS: Vast spatial freeze simulating the suspended, unmoving restaurant room
Ndef(\antarcticSilence)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.95, damp: 0.2);
};
Ndef(\antarcticSilence).set(\wet10, 0.45);
// Ndef(\antarcticSilence).set(\wet10, 0); // Rollback: disable this effect

// Rollback:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\antarcticSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2);
)

// === Round 02 [DESIGN] Frag #50 (conto_cronica) ===
(
// ==============================================================================
// HORLOGE ÉPHÉMÈRE: Oficina de Santa Efigênia
// Multitimbral Kinetic-Acoustic Horology Synthesizer
// Zone 1: Escapement Pendulum (Grandfather Clock Sub-Impulse + Wooden Resonator)
// Zone 2: French Carrillon (Inharmonic Chimes, Ring-Modulated Brass Rods)
// Zone 3: Swarm Horology (Micro-Phased Pocket Escapement Tick Cascade)
// ==============================================================================

// Step 0: MIDI CC Assignment Map
~cc = (
    // Zone 1: Pendulum Core
    vol1: 1, pan1: 2, mute1: 3, min1: 4, max1: 5,
    hpf1: 6, lpf1: 7, rq1: 8, atk1: 9, dec1: 10, sus1: 11, rls1: 12,
    pendWeight: 13, // Unique Character FX: Escapement deadweight & wood body saturation

    // Zone 2: Carrillon Français
    vol2: 14, pan2: 15, mute2: 16, min2: 17, max2: 18,
    hpf2: 19, lpf2: 20, rq2: 21, atk2: 22, dec2: 23, sus2: 24, rls2: 25,
    rodInharm: 26,  // Unique Character FX: Metallic inharmonicity & strike dispersion

    // Zone 3: Micro-Escapement Swarm
    vol3: 27, pan3: 28, mute3: 29, min3: 30, max3: 31,
    hpf3: 32, lpf3: 33, rq3: 34, atk3: 35, dec3: 36, sus3: 37, rls3: 38,
    gearDrift: 39,  // Unique Character FX: Micro-phase escapement jitter rate

    // Master / Spatial
    delTime: 40, delMix: 41, revTime: 42, verbMix: 43, masterVol: 44, panic: 45
);

// Step 1 & 2: MIDI Auto-Detection with Hardware Fallback
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
    ("HORLOGE: MIDI Connected -> " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "HORLOGE WARNING: No MIDI controller found. Operating on internal GUI mode.".warn;
    ~myUid = nil;
};

// Step 3: Synthesis Engine & Audio Architecture
s.waitForBoot({
    // Initial parameter state: FX and wet mixes boot strictly DRY (0.0)
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 21, max1: 65,
        hpf1: 28.0, lpf1: 420.0, rq1: 0.7, atk1: 0.005, dec1: 0.85, sus1: 0.01, rls1: 0.45,
        pendWeight: 0.0,

        vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 48, max2: 108,
        hpf2: 240.0, lpf2: 7500.0, rq2: 0.6, atk2: 0.003, dec2: 1.8, sus2: 0.15, rls2: 1.2,
        rodInharm: 0.0,

        vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 36, max3: 127,
        hpf3: 850.0, lpf3: 11000.0, rq3: 0.5, atk3: 0.002, dec3: 0.12, sus3: 0.02, rls3: 0.18,
        gearDrift: 0.0,

        delTime: 0.24, delMix: 0.0, revTime: 2.8, verbMix: 0.0, masterVol: 0.82
    );

    // Dynamic Control Buses
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Execution Order Groups
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Audio Busses
    ~busDry = Bus.audio(s, 2);
    ~busFX = Bus.audio(s, 2);

    // Active Note Tracker for Polyphonic Voices
    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // --- SYNTHDEF ZONE 1: Escapement Pendulum (Grandfather Core Sub) ---
    SynthDef(\horlogeZone1, {
        |out=0, freq=45, gate=1, amp=0.25, pan=0.0, mute=0,
         hpf=28, lpf=420, rq=0.7, atk=0.005, dec=0.85, sus=0.01, rls=0.45,
         pendWeight=0.0|
        var env, exciter, sub, woodBody, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        // Escapement impulse click
        exciter = Impulse.ar(0.0) + (Dust.ar(3) * 0.15);
        // Low pendulum thud (damped sine + low triangle)
        sub = SinOsc.ar(freq * [0.998, 1.002]).sum * 0.6;
        sub = sub + (LFTri.ar(freq * 0.5) * 0.4);
        // Wooden cabinet acoustic resonance
        woodBody = DynKlank.ar(
            `[[freq * 1.5, freq * 2.34, freq * 3.88], [0.4, 0.25, 0.1], [0.35, 0.2, 0.12]],
            exciter
        );
        sig = sub + woodBody;
        // Unique FX: Pendulum Deadweight Saturation
        sig = (sig * (1.0 + (pendWeight * 4.0))).tanh * (1.0 / (1.0 + (pendWeight * 1.5)));
        sig = HPF.ar(sig, hpf);
        sig = RLPF.ar(sig, lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        sig = sig * env * amp * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- SYNTHDEF ZONE 2: Carrillon Français (French Clock Inharmonic Rods) ---
    SynthDef(\horlogeZone2, {
        |out=0, freq=440, gate=1, amp=0.25, pan=(-0.35), mute=0,
         hpf=240, lpf=7500, rq=0.6, atk=0.003, dec=1.8, sus=0.15, rls=1.2,
         rodInharm=0.0|
        var env, strike, mod, car, rods, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -5), gate, doneAction: 2);
        // Brass hammer strike transient
        strike = Decay2.ar(Impulse.ar(0.0), 0.001, 0.015) * PinkNoise.ar;
        // Inharmonic bell FM: non-integer ratios (1:2.71 & 1:4.18)
        mod = SinOsc.ar(freq * (2.71 + (rodInharm * 1.14))) * (freq * (1.2 + (rodInharm * 3.5)));
        car = SinOsc.ar(freq + mod);
        // Struck chime rod bank via Comb and allpass dispersion
        rods = CombL.ar(strike + (car * 0.5), 0.04, freq.reciprocal.clip(0.0001, 0.04), 1.6);
        rods = AllpassC.ar(rods, 0.02, (rodInharm * 0.008) + 0.001, 0.15);
        sig = (car * 0.5) + (rods * 0.5);
        sig = HPF.ar(sig, hpf);
        sig = RLPF.ar(sig, lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        sig = sig * env * amp * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- SYNTHDEF ZONE 3: Swarm Horology (Micro-Phased Pocket Watch Cascade) ---
    SynthDef(\horlogeZone3, {
        |out=0, freq=1200, gate=1, amp=0.2, pan=0.35, mute=0,
         hpf=850, lpf=11000, rq=0.5, atk=0.002, dec=0.12, sus=0.02, rls=0.18,
         gearDrift=0.0|
        var env, ticks, tooth, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, curve: -6), gate, doneAction: 2);
        // Gear tooth escapement friction (clusters of clicks micro-phased by drift)
        ticks = Impulse.ar([12.0 + (gearDrift * 35.0), 16.0 + (gearDrift * 47.0)]);
        tooth = Decay.ar(ticks, 0.004) * (WhiteNoise.ar * 0.75 + SinOsc.ar(freq * 3.12, 0, 0.25));
        tooth = BPF.ar(tooth, [freq, freq * 1.62], rq.clip(0.05, 1.0)).sum;
        // Fold escapement impact for brass crunch
        sig = Fold.ar(tooth * (2.0 + (gearDrift * 6.0)), -0.85, 0.85);
        sig = HPF.ar(sig, hpf);
        sig = LPF.ar(sig, lpf.clip(20, 18000));
        sig = sig * env * amp * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // --- SYNTHDEF FX & MASTER ---
    SynthDef(\horlogeFX, {
        |inBus=0, outBus=0, delTime=0.24, delMix=0.0, revTime=2.8, verbMix=0.0, masterVol=0.82|
        var dry, dSig, vSig, sig;
        dry = In.ar(inBus, 2);
        // Tape-like clock reflection delay with allpass smoothing
        dSig = CombC.ar(dry, 1.2, delTime.clip(0.02, 1.0), delTime * 2.8);
        dSig = AllpassC.ar(dSig, 0.04, 0.025, 0.12);
        // Spatial French Workshop Reverb
        vSig = GVerb.ar(dry[0] + (dry[1] * 0.5), 120, revTime.clip(0.2, 8.0), 0.45, 0.35, 15, 0, 0.7, 0.5);
        sig = (dry * (1.0 - (delMix * 0.45) - (verbMix * 0.45))) + (dSig * delMix) + (vSig * verbMix);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig * masterVol, 0.92, 0.01);
        Out.ar(outBus, sig);
    }).add;

    // Guarantee all SynthDefs are compiled on the server before instantiating audio graph
    s.sync;

    // Instantiate Master FX Engine
    ~fxSynth = Synth.tail(~fxGroup, \horlogeFX, [
        \inBus, ~busDry,
        \outBus, 0,
        \delTime, ~buses.delTime.asMap,
        \delMix, ~buses.delMix.asMap,
        \revTime, ~buses.revTime.asMap,
        \verbMix, ~buses.verbMix.asMap,
        \masterVol, ~buses.masterVol.asMap
    ]);

    // MIDI Note-On Polyphonic Handler
    MIDIdef.noteOn(\horlogeNoteOn, { |vel, noteNum|
        var vNorm = vel / 127.0;

        // Zone 1: Escapement Pendulum
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            var syn = Synth.head(~synthGroup, \horlogeZone1, [
                \out, ~busDry,
                \freq, noteNum.midicps,
                \amp, ~buses.vol1.asMap,
                \pan, ~buses.pan1.asMap,
                \mute, ~buses.mute1.asMap,
                \hpf, ~buses.hpf1.asMap,
                \lpf, ~buses.lpf1.asMap,
                \rq, ~buses.rq1.asMap,
                \atk, ~buses.atk1.asMap,
                \dec, ~buses.dec1.asMap,
                \sus, ~buses.sus1.asMap,
                \rls, ~buses.rls1.asMap,
                \pendWeight, ~buses.pendWeight.asMap
            ]);
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(syn);
        };

        // Zone 2: Carrillon Français
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            var syn = Synth.head(~synthGroup, \horlogeZone2, [
                \out, ~busDry,
                \freq, noteNum.midicps,
                \amp, ~buses.vol2.asMap,
                \pan, ~buses.pan2.asMap,
                \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap,
                \lpf, ~buses.lpf2.asMap,
                \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap,
                \dec, ~buses.dec2.asMap,
                \sus, ~buses.sus2.asMap,
                \rls, ~buses.rls2.asMap,
                \rodInharm, ~buses.rodInharm.asMap
            ]);
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(syn);
        };

        // Zone 3: Micro-Escapement Swarm
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            var syn = Synth.head(~synthGroup, \horlogeZone3, [
                \out, ~busDry,
                \freq, noteNum.midicps,
                \amp, ~buses.vol3.asMap,
                \pan, ~buses.pan3.asMap,
                \mute, ~buses.mute3.asMap,
                \hpf, ~buses.hpf3.asMap,
                \lpf, ~buses.lpf3.asMap,
                \rq, ~buses.rq3.asMap,
                \atk, ~buses.atk3.asMap,
                \dec, ~buses.dec3.asMap,
                \sus, ~buses.sus3.asMap,
                \rls, ~buses.rls3.asMap,
                \gearDrift, ~buses.gearDrift.asMap
            ]);
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(syn);
        };
    }, srcID: ~myUid);

    // MIDI Note-Off Handler
    MIDIdef.noteOff(\horlogeNoteOff, { |vel, noteNum|
        if(~zone1Notes[noteNum].notNil) {
            ~zone1Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
            ~zone1Notes[noteNum] = nil;
        };
        if(~zone2Notes[noteNum].notNil) {
            ~zone2Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
            ~zone2Notes[noteNum] = nil;
        };
        if(~zone3Notes[noteNum].notNil) {
            ~zone3Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
            ~zone3Notes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    // Panic Function
    ~panicFunc = {
        ~synthGroup.set(\gate, 0);
        128.do { |i|
            ~zone1Notes[i] = nil;
            ~zone2Notes[i] = nil;
            ~zone3Notes[i] = nil;
        };
        "HORLOGE: PANIC - All voices released.".postln;
    };

    MIDIdef.cc(\horlogePanic, { |val|
        if(val > 63) { ~panicFunc.value };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Loop-Driven MIDI CC Routing
    MIDIdef.cc(\horlogeCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.002, 4.0) }
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

    // GUI Initialization inside defer
    defer {
        var screen, winW, winH, pages, tabBtns, zoneMeta;
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };

        screen = Window.availableBounds;
        winW = 860;
        winH = min(720, screen.height - 60);

        ~mainWin = Window("OFICINA DE SANTA EFIGÊNIA // Horloge Éphémère", Rect(
            (screen.width - winW) * 0.5,
            (screen.height - winH) * 0.5,
            winW, winH
        ), scroll: true).front;
        ~mainWin.view.background = Color(0.12, 0.11, 0.10);

        ~ui = ();

        // Title Header
        StaticText(~mainWin, Rect(20, 12, winW - 40, 28))
            .string_("DUZENTOS RELÓGIOS // O RESPIRAR DO TEMPO")
            .font_(Font("Georgia", 18, true))
            .stringColor_(Color(0.88, 0.76, 0.55));

        // Tab Navigation Buttons
        pages = Array.newClear(3);
        tabBtns = Array.newClear(3);

        zoneMeta = [
            (id: 1, title: "I. ESCAPEMENT PENDULUM (Grandfather Sub)", fxKey: \pendWeight, fxLabel: "Pendulum Weight", defCol: Color(0.35, 0.22, 0.12)),
            (id: 2, title: "II. CARRILLON FRANÇAIS (Inharmonic Bells)", fxKey: \rodInharm, fxLabel: "Rod Inharmonicity", defCol: Color(0.22, 0.28, 0.32)),
            (id: 3, title: "III. SWARM HOROLOGY (Pocket Escapements)", fxKey: \gearDrift, fxLabel: "Gear Micro-Drift", defCol: Color(0.28, 0.25, 0.16))
        ];

        zoneMeta.do { |zm, pageIdx|
            tabBtns[pageIdx] = Button(~mainWin, Rect(20 + (pageIdx * 270), 48, 260, 32))
                .states_([
                    [zm.title, Color(0.7, 0.7, 0.7), Color(0.18, 0.18, 0.18)],
                    [zm.title, Color(0.1, 0.1, 0.1), Color(0.85, 0.72, 0.45)]
                ])
                .font_(Font("Helvetica", 11, true))
                .action_({
                    pages.do { |pg, j| pg.visible = (j == pageIdx) };
                    tabBtns.do { |b, j| b.value = if(j == pageIdx, 1, 0) };
                });
        };

        // Zone Pages Construction Loop
        zoneMeta.do { |zm, pageIdx|
            var p = CompositeView(~mainWin, Rect(20, 88, winW - 40, 480));
            var zi = zm.id.asString;
            p.background = Color(0.15, 0.14, 0.13);
            p.visible = (pageIdx == 0);
            pages[pageIdx] = p;

            // Zone Volume & Pan & Mute
            ~ui[("vol" ++ zi).asSymbol] = EZSlider(p, Rect(20, 20, 360, 24), "Vol CC" ++ ~cc[("vol" ++ zi).asSymbol],
                ControlSpec(0.0, 1.0, \lin, 0.01),
                { |sl| ~ccVals[("vol" ++ zi).asSymbol] = sl.value; ~buses[("vol" ++ zi).asSymbol].set(sl.value) },
                ~ccVals[("vol" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white, sliderBackground: Color(0.25, 0.25, 0.25));

            ~ui[("pan" ++ zi).asSymbol] = EZSlider(p, Rect(20, 52, 360, 24), "Pan CC" ++ ~cc[("pan" ++ zi).asSymbol],
                ControlSpec(-1.0, 1.0, \lin, 0.01),
                { |sl| ~ccVals[("pan" ++ zi).asSymbol] = sl.value; ~buses[("pan" ++ zi).asSymbol].set(sl.value) },
                ~ccVals[("pan" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white, sliderBackground: Color(0.25, 0.25, 0.25));

            ~ui[("mute" ++ zi).asSymbol] = Button(p, Rect(400, 20, 90, 56))
                .states_([
                    ["MUTE (Off)", Color.white, Color(0.25, 0.25, 0.25)],
                    ["MUTED", Color.white, Color(0.7, 0.2, 0.2)]
                ])
                .value_(~ccVals[("mute" ++ zi).asSymbol].asInteger)
                .action_({ |b|
                    ~ccVals[("mute" ++ zi).asSymbol] = b.value.asFloat;
                    ~buses[("mute" ++ zi).asSymbol].set(b.value.asFloat);
                });

            // Key Zone Bounds
            ~ui[("range" ++ zi).asSymbol] = EZRanger(p, Rect(510, 20, 280, 56), "KeyZone CC" ++ ~cc[("min" ++ zi).asSymbol],
                ControlSpec(0, 127, \lin, 1),
                { |rng|
                    ~ccVals[("min" ++ zi).asSymbol] = rng.value[0];
                    ~ccVals[("max" ++ zi).asSymbol] = rng.value[1];
                },
                [~ccVals[("min" ++ zi).asSymbol], ~ccVals[("max" ++ zi).asSymbol]]
            ).setColors(stringColor: Color.white);

            // Filter Knobs
            ~ui[("hpf" ++ zi).asSymbol] = EZKnob(p, Rect(40, 100, 80, 90), "HPF\nCC" ++ ~cc[("hpf" ++ zi).asSymbol],
                ControlSpec(20, 18000, \exp),
                { |k| ~ccVals[("hpf" ++ zi).asSymbol] = k.value; ~buses[("hpf" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("hpf" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            ~ui[("lpf" ++ zi).asSymbol] = EZKnob(p, Rect(140, 100, 80, 90), "LPF\nCC" ++ ~cc[("lpf" ++ zi).asSymbol],
                ControlSpec(20, 18000, \exp),
                { |k| ~ccVals[("lpf" ++ zi).asSymbol] = k.value; ~buses[("lpf" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("lpf" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            ~ui[("rq" ++ zi).asSymbol] = EZKnob(p, Rect(240, 100, 80, 90), "Reso (RQ)\nCC" ++ ~cc[("rq" ++ zi).asSymbol],
                ControlSpec(0.05, 1.0, \lin),
                { |k| ~ccVals[("rq" ++ zi).asSymbol] = k.value; ~buses[("rq" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("rq" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            // Envelope Knobs
            ~ui[("atk" ++ zi).asSymbol] = EZKnob(p, Rect(380, 100, 80, 90), "Atk\nCC" ++ ~cc[("atk" ++ zi).asSymbol],
                ControlSpec(0.002, 4.0, \exp),
                { |k| ~ccVals[("atk" ++ zi).asSymbol] = k.value; ~buses[("atk" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("atk" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            ~ui[("dec" ++ zi).asSymbol] = EZKnob(p, Rect(480, 100, 80, 90), "Dec\nCC" ++ ~cc[("dec" ++ zi).asSymbol],
                ControlSpec(0.01, 5.0, \exp),
                { |k| ~ccVals[("dec" ++ zi).asSymbol] = k.value; ~buses[("dec" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("dec" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            ~ui[("sus" ++ zi).asSymbol] = EZKnob(p, Rect(580, 100, 80, 90), "Sus\nCC" ++ ~cc[("sus" ++ zi).asSymbol],
                ControlSpec(0.0, 1.0, \lin),
                { |k| ~ccVals[("sus" ++ zi).asSymbol] = k.value; ~buses[("sus" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("sus" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            ~ui[("rls" ++ zi).asSymbol] = EZKnob(p, Rect(680, 100, 80, 90), "Rls\nCC" ++ ~cc[("rls" ++ zi).asSymbol],
                ControlSpec(0.02, 5.0, \exp),
                { |k| ~ccVals[("rls" ++ zi).asSymbol] = k.value; ~buses[("rls" ++ zi).asSymbol].set(k.value) },
                ~ccVals[("rls" ++ zi).asSymbol]
            ).setColors(stringColor: Color.white);

            // Unique Character FX Slider
            ~ui[zm.fxKey] = EZSlider(p, Rect(40, 230, 720, 36), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]",
                ControlSpec(0.0, 1.0, \lin, 0.01),
                { |sl| ~ccVals[zm.fxKey] = sl.value; ~buses[zm.fxKey].set(sl.value) },
                ~ccVals[zm.fxKey]
            ).setColors(stringColor: Color(0.95, 0.85, 0.65), sliderBackground: zm.defCol);
        };

        tabBtns[0].value = 1;

        // Static Master / FX Bottom Bar
        ~ui[\delTime] = EZSlider(~mainWin, Rect(30, 580, 220, 24), "DelTime CC40",
            ControlSpec(0.02, 1.0, \exp),
            { |sl| ~ccVals[\delTime] = sl.value; ~buses.delTime.set(sl.value) },
            ~ccVals[\delTime]
        ).setColors(stringColor: Color.white);

        ~ui[\delMix] = EZSlider(~mainWin, Rect(30, 610, 220, 24), "DelMix CC41",
            ControlSpec(0.0, 1.0, \lin),
            { |sl| ~ccVals[\delMix] = sl.value; ~buses.delMix.set(sl.value) },
            ~ccVals[\delMix]
        ).setColors(stringColor: Color.white);

        ~ui[\revTime] = EZSlider(~mainWin, Rect(270, 580, 220, 24), "RevTime CC42",
            ControlSpec(0.2, 8.0, \exp),
            { |sl| ~ccVals[\revTime] = sl.value; ~buses.revTime.set(sl.value) },
            ~ccVals[\revTime]
        ).setColors(stringColor: Color.white);

        ~ui[\verbMix] = EZSlider(~mainWin, Rect(270, 610, 220, 24), "VerbMix CC43",
            ControlSpec(0.0, 1.0, \lin),
            { |sl| ~ccVals[\verbMix] = sl.value; ~buses.verbMix.set(sl.value) },
            ~ccVals[\verbMix]
        ).setColors(stringColor: Color.white);

        ~ui[\masterVol] = EZSlider(~mainWin, Rect(510, 580, 180, 54), "Master CC44",
            ControlSpec(0.0, 1.0, \lin),
            { |sl| ~ccVals[\masterVol] = sl.value; ~buses.masterVol.set(sl.value) },
            ~ccVals[\masterVol], layout: \vert
        ).setColors(stringColor: Color(0.9, 0.8, 0.6));

        Button(~mainWin, Rect(710, 585, 120, 48))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.65, 0.15, 0.15)]])
            .font_(Font("Helvetica", 11, true))
            .action_({ ~panicFunc.value }); // wrap function value call so action_ receives a function

        // GUI Poller Routine (20 fps AppClock)
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

// === Round 03 [APPEND] Frag #139 (poema) ===
(
// ADD_INSTRUMENT: \morroBic - Hilltop perspective, mechanical traffic, ocean spray, and sketching paths with an uncapped Bic pen
Ndef(\morroBic, { |freq=440, amp=0.22, pan=0, t_trig=0, penScratch=0.3, seaRum=0.4, busGrowl=55|
    var trig = K2A.ar(t_trig);
    var penEnv = Decay2.ar(trig, 0.002, 0.12);
    var penSig = HPF.ar(WhiteNoise.ar, 3200) * penEnv * penScratch;
    var penTone = SinOsc.ar(freq + (penSig * 300)) * penEnv;
    var busOsc = (Pulse.ar(busGrowl * [0.99, 1.01], SinOsc.kr(0.2).range(0.2, 0.5)) * 0.5).tanh;
    var busFilt = MoogFF.ar(busOsc, busGrowl * 4, 2.5);
    var seaNoise = PinkNoise.ar * LFNoise2.kr(0.15).range(0.05, seaRum);
    var seaWaves = BPF.ar(seaNoise, LFNoise1.kr(0.1).exprange(120, 1800), 0.4) * 4.0;
    var dry = (penTone * 0.7) + (penSig * 0.8) + (busFilt * 0.4) + seaWaves;
    Pan2.ar(dry * amp, pan);
}).play;

Pbindef(\morroBicSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.375, 0.25], inf),
    \t_trig, 1,
    \degree, Pseq([0, 4, 7, 9, 11, 12, 14, 7], inf),
    \octave, Pseq([5, 6, 6, 5], inf),
    \busGrowl, Pseq([45, 52, 48, 55], inf),
    \penScratch, Pwhite(0.2, 0.6, inf),
    \seaRum, Pwhite(0.3, 0.6, inf),
    \pan, Pseq([-0.6, 0.2, 0.6, -0.3], inf),
    \amp, Pwhite(0.18, 0.28, inf)
);

Ndef(\morroBic)[1] = \set -> Pbindef(\morroBicSeq);

// Rollback: remove this instrument
// Pbindef(\morroBicSeq).stop; Ndef(\morroBic).fadeTime = 2; Ndef(\morroBic).clear(2);
)

// === Round 04 [COMPOSE] Frag #92 (wikipedia) ===
(
s.waitForBoot({
    var s = Server.default;
    ~enableRecording = false;

    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // --- Safety Limiter ---
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // --- Discrete Synths: Gungas, Caixas, & Choro Flute / Canto ---
    SynthDef(\gungaTin, { |out=0, freq=1800, amp=0.25, pan=0, ring=0.08, rattle=0.6|
        var env = EnvGen.ar(Env.perc(0.001, ring, 1, -6), doneAction: 2);
        var click = Impulse.ar(0);
        var shell = Klank.ar(`[
            [freq, freq * 1.41, freq * 2.22, freq * 2.95, freq * 4.12],
            [1, 0.7, 0.5, 0.35, 0.2],
            [ring, ring * 0.8, ring * 0.6, ring * 0.4, ring * 0.2]
        ], click);
        var gravel = BPF.ar(WhiteNoise.ar, freq * 1.8, 0.2) * Decay.ar(Dust.ar(380), 0.02) * rattle;
        var sig = (shell + gravel) * env * amp;
        sig = LeakDC.ar(sig);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\caixaCongo, { |out=0, freq=140, amp=0.3, pan=0, snare=0.5, dur=0.25|
        var rel = (dur.max(0.05));
        var envSkin = EnvGen.ar(Env.perc(0.002, rel * 0.8, 1, -4));
        var envSnare = EnvGen.ar(Env.perc(0.001, rel, 1, -5), doneAction: 2);
        var pitchEnv = XLine.ar(freq * 1.6, freq, 0.02);
        var skin = SinOsc.ar(pitchEnv) * envSkin;
        var wires = HPF.ar(WhiteNoise.ar, 800) * envSnare * snare;
        var sig = (skin + wires) * amp;
        sig = (sig * 1.8).tanh;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\pifanoCanto, { |out=0, freq=440, amp=0.2, pan=0, dur=1.0, vibrato=4.5|
        var rel = (dur - 0.08).max(0.08);
        var env = EnvGen.ar(Env.linen(0.06, rel, 0.06, 1, \sin), doneAction: 2);
        var vib = SinOsc.kr(vibrato).range(0.988, 1.012);
        var breath = BPF.ar(PinkNoise.ar, freq * 2, 0.3) * 0.15;
        var pipe = SinOsc.ar(freq * vib, 0, 0.7) + SinOsc.ar(freq * 2 * vib, 0, 0.25);
        var sig = (pipe + breath) * env * amp;
        sig = (sig * 1.2).fold2(0.85);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // --- Continuous Procession Drone / Processional Ambience ---
    Ndef(\congadaDrone, { |amp=0, bannerSweep=0.1, dustRate=8|
        var wind = BPF.ar(BrownNoise.ar, SinOsc.kr(0.08).exprange(80, 240), 0.3) * 2.0;
        var banner = CombL.ar(wind, 0.05, LFNoise1.kr(bannerSweep).range(0.008, 0.035), 0.2);
        var sandFootsteps = Dust.ar(dustRate) * Decay.ar(Impulse.ar(dustRate * 0.5), 0.04);
        var gravelScrape = HPF.ar(WhiteNoise.ar, 4500) * sandFootsteps * 0.6;
        var sig = Splay.ar([wind, banner, gravelScrape]);
        sig * amp;
    });

    Ndef(\congadaDrone).fadeTime = 3;

    // --- Master Bus Routing & Processing ---
    Ndef(\masterMix, {
        var synthSig = In.ar(~synthBus, 2);
        var ambSig = Ndef.ar(\congadaDrone, 2);
        synthSig + ambSig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.3);
    };

    Ndef(\masterMix).play;
    Ndef(\masterMix).set(\wet10, 0.15);

    s.sync;

    // --- Master Timeline ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [CUE 1: Chegada dos Ternos de Moçambique: Gungas de Lata nos Tornozelos]".postln;
        Ndef(\congadaDrone).xset(\amp, 0.35, \dustRate, 14);

        Pbindef(\gungaFootsteps,
            \instrument, \gungaTin,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25], inf),
            \freq, Pseq([1600, 1750, 1550, 1920, 1700, 2100], inf),
            \ring, Pexprand(0.04, 0.12, inf),
            \rattle, Pwhite(0.4, 0.8, inf),
            \pan, Pseq([-0.65, 0.65, -0.4, 0.4, -0.8, 0.8], inf),
            \amp, Pseq([0.22, 0.18, 0.28, 0.2, 0.24, 0.19], inf)
        ).play;

        // Active evolution of the arrival stride
        3.do { |idx|
            Ndef(\congadaDrone).xset(\bannerSweep, 0.1 + (idx * 0.1));
            Pbindef(\gungaFootsteps, \amp, 0.22 + (idx * 0.04));
            3.wait;
        };

        "0:10 - [CUE 2: Entrada das Caixas de Congo e Batucada Sincopada]".postln;
        Pbindef(\caixaPattern,
            \instrument, \caixaCongo,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.125, 0.125, 0.25, 0.25, 0.125, 0.125, 0.25], inf),
            \freq, Pseq([130, 160, 145, 120, 170, 140], inf),
            \snare, Pseq([0.3, 0.7, 0.4, 0.8, 0.5, 0.9], inf),
            \pan, Pseq([0.15, -0.15, 0.25, -0.25], inf),
            \amp, Pseq([0.32, 0.22, 0.25, 0.35, 0.24, 0.28], inf)
        ).play;

        Ndef(\masterMix).set(\wet10, 0.22);

        4.do { |step|
            Pbindef(\gungaFootsteps, \rattle, 0.4 + (step * 0.12));
            3.wait;
        };

        "0:22 - [CUE 3: Louvor e Coroação dos Reis do Congo: Canto do Pífano]".postln;
        Pbindef(\cantoRosario,
            \instrument, \pifanoCanto,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.75, 0.25, 1.0, 0.5, 1.5], inf),
            \midinote, Pseq([67, 71, 72, 74, 76, 74, 72, 71, 69, 67], inf),
            \vibrato, Pwhite(4.0, 6.0, inf),
            \pan, Pseq([0.1, -0.2, 0.2, -0.1], inf),
            \amp, 0.28
        ).play;

        // Swelling cadence of devotions
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.22 + (i * 0.04));
            Ndef(\congadaDrone).xset(\amp, 0.35 + (i * 0.05));
            3.5.wait;
        };

        "0:36 - [CUE 4: Clímax Rítmico - Moçambique e Ternos em Uníssono]".postln;
        Pbindef(\caixaPattern,
            \dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.125], inf),
            \amp, 0.38
        );
        Pbindef(\gungaFootsteps,
            \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25], inf),
            \amp, 0.32
        );
        Pbindef(\cantoRosario,
            \midinote, Pseq([74, 76, 79, 81, 79, 76, 74, 72], inf),
            \amp, 0.32
        );

        6.wait;

        "0:42 - [CUE 5: Despedida do Cortejo e Retirada na Estrada de Terra]".postln;
        Pbindef(\cantoRosario).stop;
        Pbindef(\caixaPattern).stop;

        // The gungas slowly fade away as steps move further down the road
        Pbindef(\gungaFootsteps,
            \dur, Pseq([0.5, 0.5, 0.75, 0.25], inf),
            \amp, Pseq([0.2, 0.14, 0.16, 0.1], inf)
        );
        Ndef(\masterMix).set(\wet10, 0.45);
        Ndef(\congadaDrone).xset(\amp, 0.12);

        6.wait;

        Pbindef(\gungaFootsteps).stop;
        Ndef(\congadaDrone).xset(\amp, 0.0);

        3.wait;

        "0:51 - [Score Complete: Final Silêncio Sagrado]".postln;

        // Scoped cleanup
        Pbindef(\gungaFootsteps).clear;
        Pbindef(\caixaPattern).clear;
        Pbindef(\cantoRosario).clear;

        Ndef(\congadaDrone).clear(2);
        Ndef(\masterMix).clear(2);

        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

// === Round 05 [APPEND] Frag #120 (poema) ===
(
// --- FORMAL ARCHETYPE: Intrinsic Limit (b) / Dantesque Rupture ---
// Transition from silent procession into the visceral horror of the slave ship (Navio Negreiro).
// Clanging metallic irons, whip-crack transients, and agonized modal moaning.

Ndef(\tombadilhoDantesco, { |t_trig=0, amp=0.35, pan=0, whipGain=1.2, chainTone=820, groanPitch=65|
    var trig = K2A.ar(t_trig);
    var whipEnv = Decay.ar(trig, 0.04);
    var whip = HPF.ar(WhiteNoise.ar, 1800) * whipEnv * whipGain;
    var chainEnv = Decay2.ar(trig, 0.002, 0.35);
    var chainModes = [1.0, 1.42, 2.11, 2.76, 3.4, 4.18] * chainTone;
    var chainAmps = [1.0, 0.6, 0.45, 0.3, 0.2, 0.15];
    var chainRings = [0.25, 0.2, 0.18, 0.12, 0.08, 0.05];
    var chains = DynKlank.ar(Ref([chainModes, chainAmps, chainRings]), PinkNoise.ar * chainEnv * 0.12);
    var groanEnv = EnvGen.ar(Env.perc(0.08, 0.9, 1, -2), trig);
    var groanMod = SinOsc.ar(groanPitch * 0.5) * (groanPitch * 1.5);
    var groan = SinOsc.ar(groanPitch + groanMod) * groanEnv * 0.4;
    var sig = whip + chains + groan;
    sig = (sig * 1.6).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\tombadilhoSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25, 0.125, 0.375], inf),
    \t_trig, 1,
    \chainTone, Pseq([720, 840, 960, 680, 1100, 780], inf),
    \groanPitch, Pseq([55, 62, 58, 48, 65, 52], inf),
    \whipGain, Pseq([1.4, 0.4, 0.6, 1.8, 0.3, 1.1, 0.5, 2.0], inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pseq([0.32, 0.22, 0.25, 0.38, 0.24, 0.35], inf)
);

Ndef(\tombadilhoDantesco)[1] = \set -> Pbindef(\tombadilhoSeq);

// Slot 10: Cavernous, blood-drenched hull resonance
Ndef(\tombadilhoDantesco)[10] = \filter -> { |in|
    var rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.35);
    var darkHull = LPF.ar(CombC.ar(rev, 0.2, 0.08, 1.4), 3200);
    LeakDC.ar(darkHull);
};
Ndef(\tombadilhoDantesco).xset(\wet10, 0.45);

// Rollback: remove this instrument and its reverberant processing
// Pbindef(\tombadilhoSeq).stop; Ndef(\tombadilhoDantesco).fadeTime = 2; Ndef(\tombadilhoDantesco).clear(2);
)

// === Round 06 [COMPOSE] Frag #13 (wikipedia) ===
(
s.waitForBoot({
    var s = Server.default;

    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // --- Safety Limiter ---
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // --- Discrete Sound Sources ---
    // Acoustic water droplets striking mineral calcite
    SynthDef(\maquineDrop, { |out=0, freq=1200, depthDecay=1.8, dripMod=4.2, pan=0, amp=0.3|
        var env = EnvGen.ar(Env.perc(0.0005, depthDecay, 1, -6), doneAction: 2);
        var pitchEnv = XLine.ar(freq * dripMod, freq, 0.018);
        var exc = SinOsc.ar(pitchEnv);
        var modes = [1.0, 2.76, 5.4, 8.9] * freq;
        var amps = [1.0, 0.35, 0.15, 0.05];
        var rings = [depthDecay, depthDecay * 0.7, depthDecay * 0.4, 0.05];
        var res = DynKlank.ar(Ref([modes, amps, rings]), exc * 0.15, decayscale: depthDecay);
        var sig = (exc * 0.4) + (res * 0.6);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Stalactite / Stalagmite Lithophone Percussion (Lund's Hammer)
    SynthDef(\stalactiteStrike, { |out=0, freq=340, strikeAmp=0.4, ringTime=2.2, pan=0|
        var impact = HPF.ar(LPF.ar(WhiteNoise.ar, 6000), 1200) * EnvGen.ar(Env.perc(0.001, 0.012));
        var click = Impulse.ar(0) * 0.8;
        var exciter = impact + click;
        var modes = [1.0, 2.32, 4.15, 6.7, 9.4] * freq;
        var amps = [1.0, 0.5, 0.28, 0.18, 0.08];
        var rings = [ringTime, ringTime * 0.8, ringTime * 0.5, ringTime * 0.3, 0.1];
        var mineral = DynKlank.ar(Ref([modes, amps, rings]), exciter, decayscale: ringTime);
        var sig = (mineral * 0.8 + (exciter * 0.2)) * strikeAmp;
        var env = EnvGen.ar(Env.perc(0.002, ringTime.max(0.1), 1, -4), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env, pan));
    }).add;

    s.sync;

    // --- Continuous Textures ---
    // The cavernous breath: low subterranean hum & subterranean draft
    Ndef(\abobadaHum, { |amp=0, cutoff=140, airSpread=0.3|
        var rumbles = Splay.ar(SinOsc.ar([32, 32.5, 64, 64.7, 96] * 0.5));
        var subAir = BPF.ar(PinkNoise.ar(0.8), [180, 280, 520], 0.08).sum;
        var sig = (rumbles * 0.7) + (subAir * airSpread);
        sig = LPF.ar(sig, cutoff);
        sig * amp;
    });

    // Mineral condensation veil (sparkling high water seep)
    Ndef(\calcitaShimmer, { |amp=0, shimmerFreq=3400|
        var dustTrig = Dust.ar(18);
        var grains = Ringz.ar(dustTrig, LFNoise1.kr(0.2).exprange(shimmerFreq * 0.8, shimmerFreq * 1.6), 0.15);
        var stereoPanned = Pan2.ar(grains * 0.08, LFNoise2.kr(0.4));
        stereoPanned * amp;
    });

    // --- Master Mixer and Seven-Chamber Cavern Reverberation ---
    Ndef(\masterMix, {
        var discrete = In.ar(~synthBus, 2);
        var hum = Ndef(\abobadaHum).ar(2);
        var shimmer = Ndef(\calcitaShimmer).ar(2);
        discrete + hum + shimmer;
    });

    // Subterranean Acoustic Chamber (Huge Karstic Vault)
    Ndef(\masterMix)[10] = \filter -> { |in|
        var wetRev = FreeVerb2.ar(in[0], in[1], 1.0, 0.98, 0.3);
        var earlyEcho = CombC.ar(wetRev, 0.3, [0.087, 0.113], 2.8);
        LeakDC.ar((wetRev * 0.6) + (earlyEcho * 0.4));
    };
    Ndef(\masterMix).set(\wet10, 0.45);
    Ndef(\masterMix).play;

    s.sync;

    // --- Narrative Master Score ---
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [CUE 1: Entrada nas Trevas - Os 7 Salões e o Vento Subterrâneo]".postln;
        Ndef(\abobadaHum).fadeTime = 4;
        Ndef(\abobadaHum).xset(\amp, 0.4, \cutoff, 180);

        Pbindef(\gotasLentas,
            \instrument, \maquineDrop,
            \out, ~synthBus,
            \dur, Pseq([1.8, 2.4, 1.2, 3.1, 0.9, 2.7], inf),
            \freq, Pseq([1100, 1340, 980, 1520, 890, 1260], inf),
            \depthDecay, Pwhite(2.5, 4.0, inf),
            \dripMod, Pwhite(3.2, 5.0, inf),
            \pan, Pwhite(-0.75, 0.75, inf),
            \amp, 0.28
        ).play;

        // Active breath exploration across subterranean chambers
        4.do { |i|
            Ndef(\abobadaHum).xset(\cutoff, 120 + (i * 35));
            2.5.wait;
        };

        "0:10 - [CUE 2: Cortinas Minerais - A Condensação e os Cristais de Calcita]".postln;
        Ndef(\calcitaShimmer).fadeTime = 3;
        Ndef(\calcitaShimmer).xset(\amp, 0.32, \shimmerFreq, 3200);

        // Accelerated droplets in chamber of statues
        Pbindef(\gotasLentas,
            \dur, Pseq([0.6, 0.8, 0.4, 1.1, 0.3, 0.9], inf),
            \amp, 0.34
        );

        3.do { |i|
            Ndef(\calcitaShimmer).xset(\shimmerFreq, 2800 + (i * 600));
            Ndef(\masterMix).set(\wet10, 0.48 + (i * 0.04));
            3.0.wait;
        };

        "0:19 - [CUE 3: Lund Percute as Estalactites - O Órgão Litofônico da Gruta]".postln;
        // Peter Lund's exploration with hammer strikes against resonant limestone columns
        Pbindef(\litofoneLund,
            \instrument, \stalactiteStrike,
            \out, ~synthBus,
            \dur, Pseq([0.35, 0.35, 0.7, 0.35, 0.525, 0.175, 0.8], inf),
            \freq, Pseq([180, 240, 270, 320, 360, 480, 540, 405], inf),
            \ringTime, Pseq([2.8, 3.4, 2.2, 4.0, 1.8], inf),
            \strikeAmp, Pseq([0.38, 0.28, 0.34, 0.45, 0.3], inf),
            \pan, Pseq([-0.6, 0.5, -0.3, 0.4, 0.0], inf)
        ).play;

        4.do { |i|
            Ndef(\abobadaHum).xset(\airSpread, 0.3 + (i * 0.15));
            Ndef(\masterMix).set(\wet10, 0.58 + (i * 0.03));
            2.8.wait;
        };

        "0:30 - [CUE 4: Limite Intrínseco - A Caverna Profunda / Ressonância Extrema]".postln;
        // High density of resonant drops and strikes, saturation of acoustic vault
        Pbindef(\gotasLentas,
            \dur, Pseq([0.15, 0.22, 0.18, 0.35, 0.12, 0.28], inf),
            \freq, Pseq([1400, 1850, 2200, 1150, 950, 2600], inf),
            \amp, 0.42
        );
        Pbindef(\litofoneLund,
            \dur, Pseq([0.175, 0.175, 0.35, 0.175, 0.35], inf),
            \freq, Pseq([135, 202.5, 270, 337.5, 405, 506.25], inf),
            \strikeAmp, 0.44
        );
        Ndef(\masterMix).set(\wet10, 0.78);
        Ndef(\abobadaHum).xset(\amp, 0.55, \cutoff, 380);

        4.do { |i|
            Ndef(\calcitaShimmer).xset(\amp, 0.4 - (i * 0.08));
            2.0.wait;
        };

        "0:38 - [CUE 5: Assentamento e Memória - O Retorno da Escuridão Secular]".postln;
        // Abrupt cut of the hammer strikes; pure solitary water drops remaining in darkness
        Pbindef(\litofoneLund).stop;
        Ndef(\calcitaShimmer).fadeTime = 3;
        Ndef(\calcitaShimmer).xset(\amp, 0.0);

        Pbindef(\gotasLentas,
            \dur, Pseq([2.2, 3.8, 2.9, 4.5], inf),
            \freq, Pseq([920, 1150, 840, 1020], inf),
            \amp, Pseq([0.22, 0.18, 0.15, 0.12], inf),
            \depthDecay, 4.5
        );

        Ndef(\masterMix).set(\wet10, 0.52);
        Ndef(\abobadaHum).fadeTime = 5;
        Ndef(\abobadaHum).xset(\amp, 0.2, \cutoff, 95);

        4.do { |i|
            Ndef(\abobadaHum).xset(\amp, 0.2 - (i * 0.04));
            2.2.wait;
        };

        "0:47 - [CUE 6: Gota Final e Silêncio Geológico]".postln;
        Pbindef(\gotasLentas).stop;
        Ndef(\abobadaHum).fadeTime = 4;
        Ndef(\abobadaHum).xset(\amp, 0.0);

        4.wait;

        "0:51 - [Score Complete: Maquiné em Repouso]".postln;

        // Scoped cleanup of this piece's resources
        Pbindef(\gotasLentas).clear;
        Pbindef(\litofoneLund).clear;
        Ndef(\abobadaHum).clear(2);
        Ndef(\calcitaShimmer).clear(2);
        Ndef(\masterMix).clear(2);

        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

// === Round 07 [COMPOSE] Frag #170 (conto_cronica) ===
(
s.waitForBoot({
    // Config and Audio Routing Setup
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete Synths: Crystal Bell, Glacial Drop, Scarlet Decree
    SynthDef(\redomaCristal, {
        |out=0, freq=1200, amp=0.25, pan=0, ring=3.2, damp=0.2|
        var strike, sig, env;
        env = EnvGen.ar(Env.perc(0.002, ring.max(0.1), 1, -4), doneAction: 2);
        strike = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015)));
        sig = DynKlank.ar(
            `[
                [freq, freq * 2.002, freq * 3.014, freq * 4.412, freq * 5.67],
                [1.0, 0.45, 0.25, 0.18, 0.08],
                [ring, ring * 0.85, ring * 0.6, ring * 0.4, ring * 0.25]
            ],
            strike,
            decayscale: ring
        );
        sig = sig * env * amp;
        sig = LPF.ar(sig, 12000);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\gotaNevada, {
        |out=0, freq=800, amp=0.2, pan=0, bend=1.8, dur=0.4|
        var fEnv, sig, env;
        fEnv = EnvGen.ar(Env([freq * bend, freq], [dur * 0.2], \exp));
        env = EnvGen.ar(Env.perc(0.002, (dur - 0.002).max(0.05), 1, -6), doneAction: 2);
        sig = SinOsc.ar(fEnv);
        sig = sig + (SinOsc.ar(fEnv * 2.01) * 0.2);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\mantoEscarlate, {
        |out=0, freq=75, amp=0.3, pan=0, dur=1.8, res=2.4|
        var sig, env, fEnv;
        env = EnvGen.ar(Env.perc(0.04, (dur - 0.04).max(0.1), 1, -2), doneAction: 2);
        fEnv = EnvGen.ar(Env([freq * 8, freq * 1.5, freq], [dur * 0.25, dur * 0.75], \exp));
        sig = Pulse.ar([freq, freq * 1.006], 0.35).sum;
        sig = MoogFF.ar(sig, fEnv.clip(40, 14000), res) * 2.8;
        sig = (sig * 1.4).tanh;
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // Continuous Proxies: Pensamento Azul, Vento Matinal, Sabios da Barba Prateada
    Ndef(\pensamentoAzul, {
        |amp=0.0, fund=329.63, breath=0.2| // E4 pure spring modal
        var lfo, waves, sig;
        lfo = SinOsc.kr(0.15).range(0.998, 1.002);
        waves = Mix.fill(4, { |i|
            var f = fund * (i + 1) * lfo;
            SinOsc.ar(f, 0, (1 / (i + 1.2))) * SinOsc.kr(0.08 + (i * 0.04)).range(0.2, 1.0);
        });
        sig = waves * 0.3;
        sig = sig + (LPF.ar(PinkNoise.ar, 1800) * breath * 0.15);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, 0) * amp;
        sig;
    });

    Ndef(\ventoMatinal, {
        |amp=0.0, gustFreq=450, rq=0.18, pan=0|
        var noise, sig, sweep;
        sweep = LFNoise2.kr(0.3).exprange(gustFreq * 0.5, gustFreq * 2.4);
        noise = WhiteNoise.ar;
        sig = BPF.ar(noise, sweep, rq) * 12.0;
        sig = Pan2.ar(sig, pan) * amp;
        sig;
    });

    Ndef(\barbaPrateada, {
        |amp=0.0, shimmer=4400|
        var mod, sig;
        mod = LFNoise1.kr(1.2).bipolar(0.012);
        sig = GrainSin.ar(2, Dust.ar(32), 0.08, shimmer * (1 + mod), LFNoise1.kr(0.4));
        sig = HPF.ar(sig, 2200) * amp;
        sig;
    });

    // Master Bus & Effect Architecture
    Ndef(\masterMix, {
        var busSig = In.ar(~synthBus, 2);
        var azul = Ndef.ar(\pensamentoAzul, 2);
        var vento = Ndef.ar(\ventoMatinal, 2);
        var prata = Ndef.ar(\barbaPrateada, 2);
        busSig + azul + vento + prata;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.88, damp: 0.15);
    };

    Ndef(\masterMix).set(\wet10, 0.28);
    Ndef(\masterMix).play;

    s.sync;

    // Timeline Choreography
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [CUE 1: O Despertar do Rei e a Ideia Azul]".postln;
        // Pure high mountain spring thought awakens
        Ndef(\pensamentoAzul).fadeTime = 3.0;
        Ndef(\pensamentoAzul).xset(\amp, 0.42, \fund, 329.63, \breath, 0.1);

        Pbindef(\gotasAzuis,
            \instrument, \gotaNevada,
            \out, ~synthBus,
            \dur, Pseq([1.2, 0.8, 1.4, 0.6, 2.0], inf),
            \freq, Pseq([659.25, 987.77, 1318.5, 880, 1174.6], inf),
            \bend, 1.35,
            \pan, Pwhite(-0.5, 0.5, inf),
            \amp, 0.26
        ).play;

        4.do { |i|
            Ndef(\pensamentoAzul).xset(\breath, 0.1 + (i * 0.05));
            2.0.wait;
        };

        "0:08 - [CUE 2: Os Sabios de Barba Prateada e as Redomas de Cristal]".postln;
        // High shimmers and crystalline dome resonance encompass the blue idea
        Ndef(\barbaPrateada).fadeTime = 2.5;
        Ndef(\barbaPrateada).xset(\amp, 0.35, \shimmer, 5200);

        Pbindef(\cristalSabios,
            \instrument, \redomaCristal,
            \out, ~synthBus,
            \dur, Pseq([0.9, 1.35, 0.45, 1.8], inf),
            \freq, Pseq([1318.5, 1567.98, 1975.53, 2637.0], inf),
            \ring, Pseq([3.5, 4.2, 2.8, 5.0], inf),
            \pan, Pseq([-0.7, 0.7, -0.3, 0.3], inf),
            \amp, 0.28
        ).play;

        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.32 + (i * 0.04));
            Ndef(\barbaPrateada).xset(\shimmer, 4800 + (i * 350));
            2.2.wait;
        };

        "0:17 - [CUE 3: A Entrada dos Ministros de Manto Escarlate]".postln;
        // Deep authoritative royal presence enters the sanctuary
        Pbindef(\ministrosCorte,
            \instrument, \mantoEscarlate,
            \out, ~synthBus,
            \dur, Pseq([1.8, 1.2, 1.8, 2.4], inf),
            \freq, Pseq([55, 73.42, 65.41, 82.41], inf),
            \res, 2.8,
            \amp, 0.38,
            \pan, Pseq([-0.4, 0.4, 0.0], inf)
        ).play;

        Pbindef(\gotasAzuis,
            \dur, Pseq([0.45, 0.45, 0.9, 0.3, 0.6], inf),
            \amp, 0.22
        );

        4.do { |i|
            Ndef(\pensamentoAzul).xset(\fund, 329.63 * (1 + (i * 0.04)));
            2.5.wait;
        };

        "0:27 - [CUE 4: O Medo do Sopro - O Vento Matinal que Desfaz Bolhas]".postln;
        // Rising gusts of atmospheric turbulence threaten the crystal domes
        Ndef(\ventoMatinal).fadeTime = 2.0;
        Ndef(\ventoMatinal).xset(\amp, 0.45, \gustFreq, 650, \rq, 0.24);

        Pbindef(\cristalSabios,
            \dur, Pseq([0.225, 0.225, 0.45, 0.225, 0.45], inf),
            \freq, Pseq([1975.53, 2349.32, 2637.0, 3135.96, 3951.0], inf),
            \ring, 1.8,
            \amp, 0.35
        );

        Ndef(\masterMix).set(\wet10, 0.55);

        4.do { |i|
            Ndef(\ventoMatinal).xset(\gustFreq, 600 + (i * 300), \amp, 0.45 + (i * 0.08));
            2.0.wait;
        };

        "0:35 - [CUE 5: Limite Extremo - A Bolha Prestes a Dissolver]".postln;
        // Hyper-resonant tension: wind sweeps over crystalline edges at maximum intensity
        Ndef(\pensamentoAzul).xset(\fund, 659.25, \breath, 0.6);
        Pbindef(\ministrosCorte,
            \dur, 0.6,
            \freq, Pseq([110, 123.47, 98.0, 130.81], inf),
            \amp, 0.42
        );

        3.do { |i|
            Ndef(\ventoMatinal).xset(\pan, (i % 2 * 1.6) - 0.8);
            Ndef(\masterMix).set(\wet10, 0.65 + (i * 0.05));
            1.8.wait;
        };

        "0:41 - [CUE 6: O Estalo e o Assentamento - Pureza Imaculada]".postln;
        // Abrupt cut of courtiers, wind, and frantic bells; only the pure blue water remains
        Pbindef(\ministrosCorte).stop;
        Pbindef(\cristalSabios).stop;
        Ndef(\ventoMatinal).fadeTime = 1.5;
        Ndef(\ventoMatinal).xset(\amp, 0.0);
        Ndef(\barbaPrateada).fadeTime = 2.0;
        Ndef(\barbaPrateada).xset(\amp, 0.0);

        Ndef(\pensamentoAzul).fadeTime = 4.0;
        Ndef(\pensamentoAzul).xset(\amp, 0.35, \fund, 329.63, \breath, 0.05);

        Pbindef(\gotasAzuis,
            \dur, Pseq([1.8, 2.4, 3.2], inf),
            \freq, Pseq([1318.5, 987.77, 659.25], inf),
            \bend, 1.15,
            \amp, 0.25
        );

        Ndef(\masterMix).set(\wet10, 0.35);

        4.do { |i|
            Ndef(\pensamentoAzul).xset(\amp, 0.32 - (i * 0.06));
            2.0.wait;
        };

        "0:49 - [CUE 7: Resolucao - A Ultima Redoma Transparente]".postln;
        Pbindef(\gotasAzuis).stop;

        // One single pristine dome bell tone resonates into infinity
        Pbindef(\cristalSabios,
            \dur, Pseq([6.0]),
            \freq, 1318.5,
            \ring, 7.0,
            \amp, 0.32,
            \pan, 0.0
        ).play;

        Ndef(\pensamentoAzul).fadeTime = 5.0;
        Ndef(\pensamentoAzul).xset(\amp, 0.0);

        5.0.wait;

        "0:54 - [Score Complete: A Ideia Azul Preservada]".postln;

        // Scoped cleanup of this block's resources
        Pbindef(\gotasAzuis).clear;
        Pbindef(\cristalSabios).clear;
        Pbindef(\ministrosCorte).clear;

        Ndef(\pensamentoAzul).clear(2);
        Ndef(\ventoMatinal).clear(2);
        Ndef(\barbaPrateada).clear(2);
        Ndef(\masterMix).clear(2);

        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

// === Round 08 [APPEND] Frag #129 (poema) ===
(
// Settling/Flashback (c): Disarm worldly functional measurements into organic stillness
// Dissolving prior rigid structures, evoking Manoel de Barros' unmeasured waters, frogs, and birds

Ndef(\rioPedras, { |amp=0.22, pan=0, flow=0.8, tilt=1200, res=0.3|
    var water = PinkNoise.ar(0.5) + BrownNoise.ar(0.4);
    var modL = LFNoise1.kr(0.18).range(400, 2200);
    var modR = LFNoise1.kr(0.23).range(380, 2400);
    var stone = BPF.ar(water, [modL, modR] * flow, res).sum;
    var trickle = Dust2.ar(8);
    var drops = Ringz.ar(trickle * 0.05, TExpRand.ar(1200, 3200, trickle), 0.12);
    var sig = LPF.ar(stone + drops, tilt);
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\raSilencio, { |amp=0.0, pan=0, t_trig=0, freq=180, decay=0.8, wet=0.5|
    var trig = K2A.ar(t_trig);
    var click = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01), trig));
    var chirpEnv = EnvGen.ar(Env([0.8, 1.8, 0.6], [0.03, 0.22], \exp), trig);
    var mudHop = SinOsc.ar(freq * chirpEnv) * EnvGen.ar(Env.perc(0.005, decay, 1, -4), trig);
    var ring = Ringz.ar(click * 0.02, freq * [1.5, 2.3], 0.25).sum;
    var sig = (mudHop + ring).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\raSeq,
    \dur, Pseq([4.0, 6.5, 3.2, 8.0, 5.5], inf),
    \t_trig, 1,
    \freq, Pseq([140, 220, 165, 195, 130], inf),
    \decay, Pwhite(0.4, 1.2, inf),
    \amp, Pwhite(0.28, 0.42, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\raSilencio)[1] = \set -> Pbindef(\raSeq);

Ndef(\raSilencio)[10] = \filter -> { |in|
    // Replaced non-vanilla JPverb with FreeVerb2
    FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.4);
};
Ndef(\raSilencio).set(\wet10, 0.35);

// Rollback for this sound:
// Pbindef(\raSeq).stop; Ndef(\raSilencio).fadeTime = 2; Ndef(\raSilencio).clear(2); Ndef(\rioPedras).fadeTime = 2; Ndef(\rioPedras).clear(2);
)

// === Round 09 [GENERATE] Frag #55 (conto_cronica) ===
(
// Mariana à meia-noite: matracas secas, tochas crepitantes e o dobre fúnebre do sino da Sé

// Layer 1: As Matracas de Madeira (Rhythmic dry ratchet / wooden clatter over stone)
Ndef(\matracasMariana).fadeTime = 2.5;
Ndef(\matracasMariana, { |amp=0.22, pan=0.0, t_trig=1, baseFreq=480, crackleDecay=0.06|
    var trig = K2A.ar(t_trig);
    var burstEnv = EnvGen.ar(Env.perc(0.0005, crackleDecay, 1, -6), trig);
    var exciter = (WhiteNoise.ar * burstEnv) + (Impulse.ar(0) * 0.3);
    var woodModes = [1.0, 1.48, 2.15, 3.24];
    var woodRings = [0.05, 0.035, 0.02, 0.012];
    var body = DynKlank.ar(
        `[woodModes * baseFreq, [0.8, 0.5, 0.35, 0.2], woodRings],
        exciter
    );
    var slap = HPF.ar(body, 120);
    Pan2.ar((slap * 1.6).tanh * amp, pan);
}).play;

Ndef(\matracasMariana)[10] = \filter -> { |in|
    CombL.ar(in, 0.2, [0.038, 0.047], 0.4) + in;
};
Ndef(\matracasMariana).set(\wet10, 0.22);

Pbindef(\matracasSeq,
    \dur, Pseq([0.35, 0.35, 0.7, 0.35, 0.35, 0.35, 1.05], inf),
    \t_trig, 1,
    \baseFreq, Pseq([440, 480, 420, 460, 510, 470, 390], inf),
    \crackleDecay, Pwhite(0.04, 0.08, inf),
    \amp, Pseq([0.22, 0.25, 0.28, 0.21, 0.24, 0.26, 0.32], inf),
    \pan, Pwhite(-0.45, 0.45, inf)
);
Ndef(\matracasMariana).quant = 1;
Ndef(\matracasMariana)[1] = \set -> Pbindef(\matracasSeq);

// Layer 2: Tochas de Cera e Vento Noturno da Serra (Wax fire crackle + cold ridge gusts)
Ndef(\tochasVento).fadeTime = 3.0;
Ndef(\tochasVento, { |amp=0.18, windCut=600, windRes=0.2|
    var windLfo = LFNoise2.kr(0.12).exprange(180, 1200);
    var coldWind = BPF.ar(BrownNoise.ar(0.8) + PinkNoise.ar(0.2), windLfo * windCut.linlin(200, 1200, 0.5, 1.8), windRes) * 4.0;
    var flameHiss = BPF.ar(PinkNoise.ar(0.3), LFNoise1.kr(0.5).range(1800, 3200), 0.4);
    var sparksTrig = Dust.ar(14);
    var sparks = Ringz.ar(sparksTrig * 0.1, TExpRand.ar(2400, 6800, sparksTrig), TRand.ar(0.003, 0.02, sparksTrig));
    var torch = (coldWind * 0.7) + (flameHiss * 0.4) + sparks;
    Pan2.ar(HPF.ar(torch, 70) * amp, LFNoise1.kr(0.15).range(-0.5, 0.5));
}).play;

// Layer 3: O Dobre Lento do Sino da Sé (Somber, deep colonial bronze bell)
Ndef(\sinoDaSe).fadeTime = 4.0;
Ndef(\sinoDaSe, { |amp=0.26, pan=(-0.25), t_trig=1, fund=108, strikeDecay=7.0|
    var trig = K2A.ar(t_trig);
    var strike = (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015), trig)) + (Impulse.ar(0) * 0.4);
    var partials = [0.5, 1.0, 1.19, 1.51, 2.0, 2.74, 3.42, 4.2];
    var amps = [0.7, 1.0, 0.85, 0.6, 0.45, 0.3, 0.2, 0.1];
    var rings = [1.2, 1.0, 0.9, 0.75, 0.6, 0.45, 0.35, 0.25] * strikeDecay;
    var bronze = DynKlank.ar(
        `[partials * fund, amps, rings],
        strike
    );
    var hum = SinOsc.ar(fund * 0.5) * EnvGen.ar(Env.perc(0.08, strikeDecay * 1.3), trig) * 0.35;
    var sig = LeakDC.ar(bronze * 0.15 + hum);
    Pan2.ar(sig.tanh * amp, pan);
}).play;

Ndef(\sinoDaSe)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.94, 0.3);
};
Ndef(\sinoDaSe).set(\wet10, 0.45);

Pbindef(\sinoSeq,
    \dur, Pseq([6.5, 7.5, 8.0, 7.0], inf),
    \t_trig, 1,
    \fund, Pseq([110, 103.8, 110, 98], inf),
    \strikeDecay, Pwhite(6.5, 9.0, inf),
    \amp, Pseq([0.28, 0.24, 0.27, 0.23], inf),
    \pan, Pwhite(-0.35, -0.15, inf)
);
Ndef(\sinoDaSe).quant = 1;
Ndef(\sinoDaSe)[1] = \set -> Pbindef(\sinoSeq);
)

// Live Performance Controls:
// Ndef(\matracasMariana).xset(\crackleDecay, 0.12); // Heavier wood impact | Revert: Ndef(\matracasMariana).xset(\crackleDecay, 0.06);
// Pbindef(\matracasSeq, \dur, 0.25); // Accelerate penitent march | Revert: Pbindef(\matracasSeq, \dur, Pseq([0.35, 0.35, 0.7, 0.35, 0.35, 0.35, 1.05], inf));
// Ndef(\sinoDaSe).set(\wet10, 0.7); // Displace bell into distant mist | Revert: Ndef(\sinoDaSe).set(\wet10, 0.45);
// Pbindef(\matracasSeq).stop; Ndef(\matracasMariana).fadeTime = 3; Ndef(\matracasMariana).clear(3); // Rollback Matracas
// Ndef(\tochasVento).fadeTime = 3; Ndef(\tochasVento).clear(3); // Rollback Tochas
// Pbindef(\sinoSeq).stop; Ndef(\sinoDaSe).fadeTime = 5; Ndef(\sinoDaSe).clear(5); // Rollback Sino da Sé

// === Round 10 [GENERATE] Frag #155 (conto_cronica) ===
(
// Eduardo na Biblioteca Pública de Belo Horizonte: Passos apressados, pulso ofegante, salão solene e o tilintar da sineta

// Layer 1: Passos nas Escadarias de Pedra & Coração Ofegante (Footsteps on granite stairs & pulsing heartbeat)
Ndef(\passosCoracao).fadeTime = 2.5;
Ndef(\passosCoracao, { |amp=0.24, pan=0.0, t_trig=1, stepDecay=0.08, pulseFreq=56|
    var trig = K2A.ar(t_trig);
    var heartEnv = EnvGen.ar(Env.perc(0.02, 0.22, 1, -4), trig);
    var heartSub = SinOsc.ar(pulseFreq * (1 + (heartEnv * 0.4))) * heartEnv;
    var heartThud = (heartSub + (LPF.ar(BrownNoise.ar, 110) * heartEnv * 1.8)).tanh;

    var stoneHitEnv = EnvGen.ar(Env.perc(0.001, stepDecay, 1, -7), trig);
    var stoneRes = DynKlank.ar(
        `[[320, 680, 1420, 2850], [0.8, 0.5, 0.3, 0.15], [0.04, 0.03, 0.018, 0.008]],
        PinkNoise.ar * stoneHitEnv
    );
    var sig = (heartThud * 0.9) + (stoneRes * 0.22);
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\passosCoracao)[10] = \filter -> { |in|
    CombL.ar(in, 0.3, [0.065, 0.082], 0.6) + in;
};
Ndef(\passosCoracao).set(\wet10, 0.25);

Pbindef(\passosSeq,
    \dur, Pseq([0.38, 0.28, 0.42, 0.26, 0.36, 0.3], inf),
    \t_trig, 1,
    \pulseFreq, Pseq([54, 58, 55, 62, 57, 60], inf),
    \stepDecay, Pwhite(0.06, 0.11, inf),
    \amp, Pseq([0.24, 0.21, 0.26, 0.22, 0.25, 0.28], inf),
    \pan, Pwhite(-0.25, 0.25, inf)
);
Ndef(\passosCoracao).quant = 1;
Ndef(\passosCoracao)[1] = \set -> Pbindef(\passosSeq);

// Layer 2: Salão Alto, Folhear de Páginas & Silêncio Solene (High library vault air, distant book pages)
Ndef(\salaoSilencio).fadeTime = 3.5;
Ndef(\salaoSilencio, { |amp=0.2, filterCut=1400|
    var airDrift = LFNoise2.kr(0.08).exprange(450, 1800);
    var vaultAir = BPF.ar(PinkNoise.ar(0.35) + BrownNoise.ar(0.15), airDrift, 0.28) * 8.0;

    var pageTrig = Dust.ar(1.8);
    var pageEnv = Decay2.ar(pageTrig, 0.008, TRand.ar(0.05, 0.18, pageTrig));
    var pageNoise = HPF.ar(WhiteNoise.ar * pageEnv, TRand.ar(2200, 5200, pageTrig));
    var pageWhisper = BPF.ar(pageNoise, TRand.ar(1800, 4200, pageTrig), 0.35) * 2.8;

    var sig = LPF.ar(vaultAir + pageWhisper, filterCut);
    Pan2.ar(sig * amp, LFNoise1.kr(0.12).range(-0.4, 0.4));
}).play;

Ndef(\salaoSilencio)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.95, 0.25);
};
Ndef(\salaoSilencio).set(\wet10, 0.4);

// Layer 3: O Tilintar Suave da Sineta de Latão na Porta de Carvalho (Brass bell chime in reverberant hall)
Ndef(\sinetaLatao).fadeTime = 3.0; // Fixed non-ASCII symbol in symbol name (\sinetaLatão -> \sinetaLatao)
Ndef(\sinetaLatao, { |amp=0.22, pan=0.35, t_trig=1, fund=2480, ringTime=4.2|
    var trig = K2A.ar(t_trig);
    var strike = (Impulse.ar(0) * 0.45) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.006), trig));
    var chimeModes = [1.0, 2.76, 4.08, 5.42, 8.15];
    var chimeAmps  = [1.0, 0.65, 0.4, 0.25, 0.12];
    var chimeRings = [1.0, 0.75, 0.55, 0.38, 0.2] * ringTime;

    var chime = DynKlank.ar(
        `[chimeModes * fund, chimeAmps, chimeRings],
        strike
    );
    var woodDoorThud = LPF.ar(BrownNoise.ar, 180) * EnvGen.ar(Env.perc(0.01, 0.35), trig) * 0.3;
    var sig = (chime * 0.14) + woodDoorThud;
    Pan2.ar(sig.tanh * amp, pan);
}).play;

Ndef(\sinetaLatao)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.18);
};
Ndef(\sinetaLatao).set(\wet10, 0.52);

Pbindef(\sinetaSeq,
    \dur, Pseq([5.2, 6.8, 4.6, 7.5], inf),
    \t_trig, 1,
    \fund, Pseq([2480, 2520, 2460, 2500], inf),
    \ringTime, Pwhite(3.8, 5.2, inf),
    \amp, Pseq([0.22, 0.18, 0.24, 0.19], inf),
    \pan, Pseq([0.35, -0.28, 0.42, -0.32], inf)
);
Ndef(\sinetaLatao).quant = 1;
Ndef(\sinetaLatao)[1] = \set -> Pbindef(\sinetaSeq);
)

// === Round 11 [GENERATE] Frag #57 (conto_cronica) ===
(
// Engenho de Cana: Roda d'água pesada, eixos rangentes de maçaranduba, fervura de tachas e canto cadenciado

// Layer 1: Roda d'Água & Levada do Riacho (Heavy water wheel rotation, rushing flow, wooden paddles plunging)
Ndef(\rodaEngenho).fadeTime = 3.0;
Ndef(\rodaEngenho, { |amp=0.26, pan=0.0, speed=0.42|
    var rotCycle = LFSaw.kr(speed, 0).range(0, 1);
    var waterRush = RLPF.ar(BrownNoise.ar, LinExp.kr(rotCycle, 0, 1, 140, 780), 0.38) * 1.6;
    var splashTrig = Impulse.kr(speed * 4);
    var splashEnv = Decay2.kr(splashTrig, 0.04, 0.45);
    var splash = BPF.ar(PinkNoise.ar, TRand.kr(800, 2400, splashTrig), 0.22) * splashEnv * 4.2;
    var deepRumble = SinOsc.ar(48 + (rotCycle * 14)) * rotCycle * 0.35;
    var sig = (waterRush + splash + deepRumble).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\rodaEngenho)[10] = \filter -> { |in|
    CombL.ar(in, 0.2, [0.08, 0.11], 0.8) + in;
};
Ndef(\rodaEngenho).set(\wet10, 0.22);

// Layer 2: Rangido dos Eixos de Maçaranduba & Moenda (Dense friction friction synthesis, crushing wood and cane stalks)
Ndef(\moendaMacaranduba).fadeTime = 2.5;
Ndef(\moendaMacaranduba, { |amp=0.22, pan=(-0.25), t_trig=1, frictionPitch=280, squeakDur=0.65|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.03, squeakDur * 0.7, squeakDur * 0.27], \sin), trig);
    var modLfo = SinOsc.ar(TRand.kr(12, 28, t_trig)) * 90;
    var frictionFm = SinOsc.ar(frictionPitch + modLfo) * env;
    var woodFormants = BPF.ar(frictionFm + (PinkNoise.ar * 0.3 * env), [260, 680, 1420], 0.08).sum * 12.0;
    var crushCrack = HPF.ar(WhiteNoise.ar, 1800) * Decay.ar(Dust.ar(35) * env, 0.015) * 1.4;
    var sig = ((woodFormants * 0.7) + crushCrack).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\moendaMacaranduba)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.45);
};
Ndef(\moendaMacaranduba).set(\wet10, 0.28);

Pbindef(\moendaSeq,
    \dur, Pseq([1.4, 0.9, 1.8, 1.2, 0.7, 1.5], inf),
    \t_trig, 1,
    \frictionPitch, Pseq([240, 310, 195, 360, 220, 290], inf),
    \squeakDur, Pwhite(0.45, 0.85, inf),
    \amp, Pexprand(0.18, 0.26, inf),
    \pan, Pseq([-0.35, -0.15, -0.4, -0.2], inf)
);
Ndef(\moendaMacaranduba).quant = 1;
Ndef(\moendaMacaranduba)[1] = \set -> Pbindef(\moendaSeq);

// Layer 3: Fervura das Tachas de Cobre & Borbulhar do Melado (Viscous bubbling texture, copper resonance)
Ndef(\tachasMelado).fadeTime = 3.5;
Ndef(\tachasMelado, { |amp=0.2, pan=0.3|
    var bubbleTrig = Dust.ar(18);
    var bubbleFreq = TExpRand.ar(180, 850, bubbleTrig);
    var bubbleDecay = TRand.ar(0.015, 0.065, bubbleTrig);
    var bubbleSweep = XLine.ar(1.4, 0.8, bubbleDecay);
    var bubble = SinOsc.ar(bubbleFreq * bubbleSweep) * Decay2.ar(bubbleTrig, 0.002, bubbleDecay);
    var copperHum = DynKlank.ar(
        `[[412, 824, 1280, 2150], [0.4, 0.25, 0.12, 0.08], [1.2, 0.9, 0.6, 0.4]],
        PinkNoise.ar(0.015) + (bubble * 0.18)
    );
    var steam = BPF.ar(WhiteNoise.ar, LFNoise2.kr(0.2).range(3200, 5800), 0.28) * 0.15;
    var sig = (bubble * 1.5) + (copperHum * 0.35) + steam;
    Pan2.ar(sig.tanh * amp, pan);
}).play;

Ndef(\tachasMelado)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.3);
};
Ndef(\tachasMelado).set(\wet10, 0.32);

// Layer 4: Canto Cadenciado dos Trabalhadores (Resonant vocal formants over a modal pentatonic drone)
Ndef(\cantoTrabalhadores).fadeTime = 4.0;
Ndef(\cantoTrabalhadores, { |amp=0.18, pan=0.1, t_trig=1, noteFreq=110, vowel=0.0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.08, 1.8, 1, -2), trig);
    var vocalExciter = Saw.ar(noteFreq * [0.995, 1.005]).sum * env;
    var fA = [700, 1200, 2600];
    var fO = [450, 850, 2400];
    var fU = [320, 700, 2200];
    var formants = SelectX.kr(vowel, [fO, fA, fU]);
    var vocalBody = BPF.ar(vocalExciter, formants, 0.09).sum * 8.0;
    var sig = vocalBody.tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Ndef(\cantoTrabalhadores)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.2);
};
Ndef(\cantoTrabalhadores).set(\wet10, 0.42);

Pbindef(\cantoSeq,
    \dur, Pseq([2.2, 2.2, 4.4, 2.2, 2.2, 4.4], inf),
    \t_trig, 1,
    \noteFreq, Pseq([98, 110, 130.8, 110, 146.8, 130.8], inf), // G2, A2, C3, A2, D3, C3
    \vowel, Pseq([0.2, 0.8, 1.6, 0.4, 1.2, 0.9], inf),
    \amp, Pseq([0.16, 0.19, 0.22, 0.17, 0.21, 0.18], inf),
    \pan, Pseq([-0.15, 0.2, -0.1, 0.25, 0.0, 0.15], inf)
);
Ndef(\cantoTrabalhadores).quant = 1;
Ndef(\cantoTrabalhadores)[1] = \set -> Pbindef(\cantoSeq);
)

// Live performance tweaks & rollbacks:
// Ndef(\rodaEngenho).xset(\speed, 0.65); // Speed up waterwheel | Revert: Ndef(\rodaEngenho).xset(\speed, 0.42);
// Pbindef(\moendaSeq, \dur, Pseq([0.7, 0.45, 0.9], inf)); // Faster groaning | Revert: Pbindef(\moendaSeq, \dur, Pseq([1.4, 0.9, 1.8, 1.2, 0.7, 1.5], inf));
// Ndef(\tachasMelado).set(\wet10, 0.55); // Deepen copper vat reverb | Revert: Ndef(\tachasMelado).set(\wet10, 0.32);
// Pbindef(\cantoSeq, \noteFreq, Pseq([110, 130.8, 146.8, 164.8], inf)); // Shift chant register | Revert: Pbindef(\cantoSeq, \noteFreq, Pseq([98, 110, 130.8, 110, 146.8, 130.8], inf));
// Ndef(\rodaEngenho).fadeTime = 4; Ndef(\rodaEngenho).clear(4); // Rollback Roda d'Água
// Pbindef(\moendaSeq).stop; Ndef(\moendaMacaranduba).fadeTime = 3; Ndef(\moendaMacaranduba).clear(3); // Rollback Moenda
// Ndef(\tachasMelado).fadeTime = 4; Ndef(\tachasMelado).clear(4); // Rollback Tachas de Melado
// Pbindef(\cantoSeq).stop; Ndef(\cantoTrabalhadores).fadeTime = 4; Ndef(\cantoTrabalhadores).clear(4); // Rollback Canto

// === Round 12 [DESIGN] Frag #74 (descricao_imagem) ===
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
// STEP 0: CC Mapping
~cc = (
    vol1: 7, pan1: 10, mute1: 14, min1: 20, max1: 21, hpf1: 22, lpf1: 23, rq1: 24, atk1: 25, dec1: 26, sus1: 27, rls1: 28, fxMatrixFold: 29,
    vol2: 31, pan2: 32, mute2: 33, min2: 34, max2: 35, hpf2: 36, lpf2: 37, rq2: 38, atk2: 39, dec2: 40, sus2: 41, rls2: 42, fxLissajousOrbit: 43,
    vol3: 45, pan3: 46, mute3: 47, min3: 48, max3: 49, hpf3: 50, lpf3: 51, rq3: 52, atk3: 53, dec3: 54, sus3: 55, rls3: 56, fxPhosphorGlow: 57,
    delMix: 85, delTime: 86, delFdbk: 87, verbMix: 88, revTime: 89, masterVol: 90, panic: 111
);

// STEP 1 & 2: MIDI Auto-Detection with Fallback
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

// STEP 3: Server Boot, Synthesis & Interface
s.waitForBoot({
    // Initial parameter values (Clean & Dry startup)
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 68, hpf1: 24, lpf1: 850, rq1: 0.45, atk1: 0.02, dec1: 0.35, sus1: 0.75, rls1: 0.4, fxMatrixFold: 0.0,
        vol2: 0.22, pan2: (-0.32), mute2: 0.0, min2: 36, max2: 104, hpf2: 80, lpf2: 3800, rq2: 0.32, atk2: 0.005, dec2: 0.25, sus2: 0.55, rls2: 0.35, fxLissajousOrbit: 0.0,
        vol3: 0.18, pan3: 0.32, mute3: 0.0, min3: 48, max3: 127, hpf3: 180, lpf3: 5400, rq3: 0.28, atk3: 0.45, dec3: 0.8, sus3: 0.85, rls3: 1.2, fxPhosphorGlow: 0.0,
        delMix: 0.0, delTime: 0.28, delFdbk: 0.35, verbMix: 0.0, revTime: 2.2, masterVol: 0.85
    );

    // Dynamic 2-line Control Bus Allocation
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Group Architecture & Audio Buses
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~busFx = Bus.audio(s, 2);

    // Active Note Tracker for Polyphony
    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // SynthDefs
    // Zone 1: Sub Matrix Buchla Sub-Bass (Wavefolded analog triangle/saw)
    SynthDef(\zone1SubMatrix, {
        |out=0, freq=55, gate=1, vel=64, vol=0.28, pan=0.0, mute=0,
         hpf=24, lpf=850, rq=0.45, atk=0.02, dec=0.35, sus=0.75, rls=0.4, fxMatrixFold=0.0|
        var env, osc, foldDrive, folded, sig, vNorm;
        vNorm = vel / 127.0;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        osc = VarSaw.ar(freq * [0.998, 1.002], 0, 0.2).sum + SinOsc.ar(freq * 0.5, 0, 0.4);
        foldDrive = 1.0 + (fxMatrixFold * 8.0 * (vNorm + 0.2));
        folded = Fold.ar(osc * foldDrive, -0.75, 0.75);
        sig = MoogFF.ar(folded, lpf.clip(20, 18000), (1.0 - rq) * 3.5);
        sig = HPF.ar(sig, hpf.clip(20, 18000));
        sig = (sig * (1.0 + (fxMatrixFold * 1.5))).tanh * env * vol * vNorm * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Lissajous Modulator (Cross-modulated dual-sine analog oscillators)
    SynthDef(\zone2Lissajous, {
        |out=0, freq=220, gate=1, vel=64, vol=0.22, pan=(-0.32), mute=0,
         hpf=80, lpf=3800, rq=0.32, atk=0.005, dec=0.25, sus=0.55, rls=0.35, fxLissajousOrbit=0.0|
        var env, ratio, mod, car, sig, vNorm, lissEnv;
        vNorm = vel / 127.0;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        ratio = 1.503 + (fxLissajousOrbit * 1.497); // Shifts from clean 3:2 to complex inharmonic ratio
        lissEnv = Line.kr(0.0, 1.0, dec) * fxLissajousOrbit;
        mod = SinOsc.ar(freq * ratio, 0, freq * (0.8 + (lissEnv * 2.5)));
        car = SinOsc.ar(freq + mod) * 0.5 + Pulse.ar(freq * 0.999, 0.45, 0.3);
        sig = RLPF.ar(car, lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 18000));
        sig = sig * env * vol * vNorm * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 3: Phosphor Glow Canopy (Warm analog detuned drone/pad)
    SynthDef(\zone3Phosphor, {
        |out=0, freq=440, gate=1, vel=64, vol=0.18, pan=0.32, mute=0,
         hpf=180, lpf=5400, rq=0.28, atk=0.45, dec=0.8, sus=0.85, rls=1.2, fxPhosphorGlow=0.0|
        var env, oscs, shimmer, sig, vNorm;
        vNorm = vel / 127.0;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        oscs = Splay.ar(Saw.ar(freq * [0.985, 0.993, 1.0, 1.007, 1.015])) * 0.4;
        shimmer = SinOscFB.ar(freq * 2.001, fxPhosphorGlow * 1.2) * (fxPhosphorGlow * 0.35);
        sig = oscs + shimmer;
        sig = MoogFF.ar(sig, lpf.clip(20, 18000), (1.0 - rq) * 2.8);
        sig = HPF.ar(sig, hpf.clip(20, 18000));
        sig = (sig * (1.0 + (fxPhosphorGlow * 2.0))).tanh * env * vol * vNorm * (1 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    // Master Space/Time Processor
    SynthDef(\modularMasterFx, {
        |inBus=0, out=0, delMix=0.0, delTime=0.28, delFdbk=0.35, verbMix=0.0, revTime=2.2, masterVol=0.85|
        var dry, delayed, delL, delR, verbed, wet, sig;
        dry = In.ar(inBus, 2);
        delL = CombL.ar(dry[0], 1.2, delTime.clip(0.02, 1.1), delFdbk.linlin(0, 1, 0.1, 4.5));
        delR = CombL.ar(dry[1], 1.2, (delTime * 1.33).clip(0.02, 1.1), delFdbk.linlin(0, 1, 0.1, 4.5));
        delayed = [delL, delR];
        wet = (dry * (1 - delMix)) + (delayed * delMix);
        verbed = FreeVerb2.ar(wet[0], wet[1], 1.0, revTime.linlin(0.2, 8.0, 0.4, 0.98), 0.3);
        sig = (wet * (1 - verbMix)) + (verbed * verbMix);
        sig = LeakDC.ar(sig) * masterVol;
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync; // CRITICAL: Wait for SynthDefs before instantiating master FX

    // Instantiate Master FX
    ~masterFxSynth = Synth.tail(~masterGroup, \modularMasterFx, [
        \inBus, ~busFx, \out, 0,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap, \delFdbk, ~buses[\delFdbk].asMap,
        \verbMix, ~buses[\verbMix].asMap, \revTime, ~buses[\revTime].asMap, \masterVol, ~buses[\masterVol].asMap
    ]);

    // MIDI CC Handling (DRY Loop-Driven Pattern)
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

    // Note On/Off Handlers
    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        // Zone 1
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            var syn = Synth.tail(~synthGroup, \zone1SubMatrix, [
                \out, ~busFx, \freq, noteNum.midicps, \vel, vel,
                \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                \fxMatrixFold, ~buses[\fxMatrixFold].asMap
            ]);
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(syn);
        };
        // Zone 2
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            var syn = Synth.tail(~synthGroup, \zone2Lissajous, [
                \out, ~busFx, \freq, noteNum.midicps, \vel, vel,
                \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                \fxLissajousOrbit, ~buses[\fxLissajousOrbit].asMap
            ]);
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(syn);
        };
        // Zone 3
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            var syn = Synth.tail(~synthGroup, \zone3Phosphor, [
                \out, ~busFx, \freq, noteNum.midicps, \vel, vel,
                \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                \fxPhosphorGlow, ~buses[\fxPhosphorGlow].asMap
            ]);
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(syn);
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        ~zone1Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
        ~zone1Notes[noteNum] = nil;
        ~zone2Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
        ~zone2Notes[noteNum] = nil;
        ~zone3Notes[noteNum].do { |s| if(s.notNil) { s.set(\gate, 0) } };
        ~zone3Notes[noteNum] = nil;
    }, srcID: ~myUid);

    // Panic Function
    ~panicFunc = {
        ~zone1Notes.do { |arr| arr.do { |s| if(s.notNil) { s.set(\gate, 0) } } };
        ~zone2Notes.do { |arr| arr.do { |s| if(s.notNil) { s.set(\gate, 0) } } };
        ~zone3Notes.do { |arr| arr.do { |s| if(s.notNil) { s.set(\gate, 0) } } };
        ~zone1Notes.fill(nil); ~zone2Notes.fill(nil); ~zone3Notes.fill(nil);
        "Panic: All active voice gates set to 0".postln;
    };
    MIDIdef.cc(\panicCC, { |val| if(val > 0) { ~panicFunc.value } }, ccNum: ~cc[\panic], srcID: ~myUid);

    // GUI Construction
    defer {
        var screen, winW, winH, tabW, tabH, tabBtnW, pageViews, tabButtons;
        screen = Window.availableBounds;
        winW = 860;
        winH = min(720, screen.height - 60);
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("MODULAR CABINET // LISSAJOUS OSCILLOSCOPE", Rect((screen.width - winW) / 2, (screen.height - winH) / 2, winW, winH), scroll: true);
        ~mainWin.view.background = Color(0.12, 0.13, 0.14);
        ~ui = ();

        tabH = 34;
        tabBtnW = (winW - 40) / 3;
        pageViews = Array.newClear(3);
        tabButtons = Array.newClear(3);

        ~zoneMeta = [
            (id: 1, title: "ZONE 1: MATRIX WAVEFOLDER (SUB)", fxKey: \fxMatrixFold, fxLabel: "Pin Matrix Fold"),
            (id: 2, title: "ZONE 2: LISSAJOUS CORE (LEAD)", fxKey: \fxLissajousOrbit, fxLabel: "Beam Orbit Mod"),
            (id: 3, title: "ZONE 3: PHOSPHOR CANOPY (PAD)", fxKey: \fxPhosphorGlow, fxLabel: "Phosphor Glow")
        ];

        // Tab Switch Buttons
        ~zoneMeta.do { |zm, i|
            tabButtons[i] = Button(~mainWin, Rect(20 + (i * tabBtnW), 15, tabBtnW - 4, tabH))
                .states_([
                    [zm.title, Color.gray(0.7), Color(0.18, 0.2, 0.22)],
                    [zm.title, Color(0.2, 1.0, 0.4), Color(0.08, 0.12, 0.1)]
                ])
                .font_(Font("Monaco", 11, true))
                .action_({
                    pageViews.do { |pv, j| pv.visible = (j == i) };
                    tabButtons.do { |tb, j| tb.value = if(j == i, 1, 0) };
                });
        };

        // Zone Page Generator
        ~zoneMeta.do { |zm, i|
            var p = CompositeView(~mainWin, Rect(20, 58, winW - 40, winH - 220));
            var zid = zm.id.asString;
            p.background = Color(0.15, 0.17, 0.18);
            pageViews[i] = p;

            StaticText(p, Rect(20, 10, 400, 24)).string_(zm.title).font_(Font("Monaco", 13, true)).stringColor_(Color(0.2, 1.0, 0.4));

            // Zone Controls
            ~ui[("vol" ++ zid).asSymbol] = EZSlider(p, Rect(20, 45, 240, 22), "Vol [CC" ++ ~cc[("vol" ++ zid).asSymbol] ++ "]", \amp, { |sl|
                ~ccVals[("vol" ++ zid).asSymbol] = sl.value; ~buses[("vol" ++ zid).asSymbol].set(sl.value);
            }, ~ccVals[("vol" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("pan" ++ zid).asSymbol] = EZSlider(p, Rect(280, 45, 240, 22), "Pan [CC" ++ ~cc[("pan" ++ zid).asSymbol] ++ "]", \bipolar, { |sl|
                ~ccVals[("pan" ++ zid).asSymbol] = sl.value; ~buses[("pan" ++ zid).asSymbol].set(sl.value);
            }, ~ccVals[("pan" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("mute" ++ zid).asSymbol] = Button(p, Rect(540, 44, 90, 24))
                .states_([["ACTIVE", Color.black, Color(0.3, 0.8, 0.4)], ["MUTED", Color.white, Color(0.8, 0.2, 0.2)]])
                .action_({ |btn|
                    var v = btn.value.asFloat;
                    ~ccVals[("mute" ++ zid).asSymbol] = v; ~buses[("mute" ++ zid).asSymbol].set(v);
                });

            ~ui[("range" ++ zid).asSymbol] = EZRanger(p, Rect(20, 80, 500, 22), "Zone Key Range", ControlSpec(0, 127, \lin, 1), { |rg|
                ~ccVals[("min" ++ zid).asSymbol] = rg.value[0]; ~ccVals[("max" ++ zid).asSymbol] = rg.value[1];
            }, [~ccVals[("min" ++ zid).asSymbol], ~ccVals[("max" ++ zid).asSymbol]]).setColors(stringColor: Color.white);

            // Knobs Row
            ~ui[("hpf" ++ zid).asSymbol] = EZKnob(p, Rect(20, 120, 85, 95), "HPF CC" ++ ~cc[("hpf" ++ zid).asSymbol], ControlSpec(20, 18000, \exp), { |kb|
                ~ccVals[("hpf" ++ zid).asSymbol] = kb.value; ~buses[("hpf" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("hpf" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("lpf" ++ zid).asSymbol] = EZKnob(p, Rect(115, 120, 85, 95), "LPF CC" ++ ~cc[("lpf" ++ zid).asSymbol], ControlSpec(20, 18000, \exp), { |kb|
                ~ccVals[("lpf" ++ zid).asSymbol] = kb.value; ~buses[("lpf" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("lpf" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("rq" ++ zid).asSymbol] = EZKnob(p, Rect(210, 120, 85, 95), "Res CC" ++ ~cc[("rq" ++ zid).asSymbol], ControlSpec(0.05, 1.0, \exp), { |kb|
                ~ccVals[("rq" ++ zid).asSymbol] = kb.value; ~buses[("rq" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("rq" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            // Unique Character FX Knob
            ~ui[zm.fxKey] = EZKnob(p, Rect(315, 120, 95, 95), zm.fxLabel ++ " CC" ++ ~cc[zm.fxKey], ControlSpec(0.0, 1.0, \lin), { |kb|
                ~ccVals[zm.fxKey] = kb.value; ~buses[zm.fxKey].set(kb.value);
            }, ~ccVals[zm.fxKey]).setColors(stringColor: Color(0.2, 1.0, 0.4));

            // Envelope Controls
            ~ui[("atk" ++ zid).asSymbol] = EZKnob(p, Rect(425, 120, 80, 95), "Atk CC" ++ ~cc[("atk" ++ zid).asSymbol], ControlSpec(0.005, 5.0, \exp), { |kb|
                ~ccVals[("atk" ++ zid).asSymbol] = kb.value; ~buses[("atk" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("atk" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("dec" ++ zid).asSymbol] = EZKnob(p, Rect(510, 120, 80, 95), "Dec CC" ++ ~cc[("dec" ++ zid).asSymbol], ControlSpec(0.005, 5.0, \exp), { |kb|
                ~ccVals[("dec" ++ zid).asSymbol] = kb.value; ~buses[("dec" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("dec" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("sus" ++ zid).asSymbol] = EZKnob(p, Rect(595, 120, 80, 95), "Sus CC" ++ ~cc[("sus" ++ zid).asSymbol], \amp, { |kb|
                ~ccVals[("sus" ++ zid).asSymbol] = kb.value; ~buses[("sus" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("sus" ++ zid).asSymbol]).setColors(stringColor: Color.white);

            ~ui[("rls" ++ zid).asSymbol] = EZKnob(p, Rect(680, 120, 80, 95), "Rls CC" ++ ~cc[("rls" ++ zid).asSymbol], ControlSpec(0.005, 5.0, \exp), { |kb|
                ~ccVals[("rls" ++ zid).asSymbol] = kb.value; ~buses[("rls" ++ zid).asSymbol].set(kb.value);
            }, ~ccVals[("rls" ++ zid).asSymbol]).setColors(stringColor: Color.white);
        };

        // Static Master Bottom Bar
        ~botBar = CompositeView(~mainWin, Rect(20, winH - 150, winW - 40, 135)).background_(Color(0.1, 0.11, 0.12));
        StaticText(~botBar, Rect(15, 8, 300, 20)).string_("ANALOG MASTER RACK & SPACE PROCESSOR").font_(Font("Monaco", 11, true)).stringColor_(Color.white);

        ~ui[\delMix] = EZSlider(~botBar, Rect(15, 32, 240, 20), "Delay Mix [CC" ++ ~cc[\delMix] ++ "]", \amp, { |sl|
            ~ccVals[\delMix] = sl.value; ~buses[\delMix].set(sl.value);
        }, ~ccVals[\delMix]).setColors(stringColor: Color.white);

        ~ui[\delTime] = EZSlider(~botBar, Rect(15, 58, 240, 20), "Delay Time [CC" ++ ~cc[\delTime] ++ "]", ControlSpec(0.02, 1.0, \exp), { |sl|
            ~ccVals[\delTime] = sl.value; ~buses[\delTime].set(sl.value);
        }, ~ccVals[\delTime]).setColors(stringColor: Color.white);

        ~ui[\verbMix] = EZSlider(~botBar, Rect(275, 32, 240, 20), "Verb Mix [CC" ++ ~cc[\verbMix] ++ "]", \amp, { |sl|
            ~ccVals[\verbMix] = sl.value; ~buses[\verbMix].set(sl.value);
        }, ~ccVals[\verbMix]).setColors(stringColor: Color.white);

        ~ui[\revTime] = EZSlider(~botBar, Rect(275, 58, 240, 20), "Verb Time [CC" ++ ~cc[\revTime] ++ "]", ControlSpec(0.2, 8.0, \lin), { |sl|
            ~ccVals[\revTime] = sl.value; ~buses[\revTime].set(sl.value);
        }, ~ccVals[\revTime]).setColors(stringColor: Color.white);

        ~ui[\masterVol] = EZSlider(~botBar, Rect(15, 88, 500, 24), "MASTER OUT [CC" ++ ~cc[\masterVol] ++ "]", \amp, { |sl|
            ~ccVals[\masterVol] = sl.value; ~buses[\masterVol].set(sl.value);
        }, ~ccVals[\masterVol]).setColors(stringColor: Color(0.2, 1.0, 0.4));

        Button(~botBar, Rect(545, 35, 240, 75))
            .states_([["PANIC (ALL VOICES OFF)", Color.white, Color(0.7, 0.15, 0.15)]])
            .font_(Font("Monaco", 12, true))
            .action_({ ~panicFunc.value });

        // Set Tab 0 Active
        pageViews.do { |pv, j| pv.visible = (j == 0) };
        tabButtons.do { |tb, j| tb.value = if(j == 0, 1, 0) };

        ~mainWin.front;
    };

    // Compact AppClock Poller (20fps)
    Routine({
        while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
            if(~ui.notNil) {
                ~ccVals.keysValuesDo { |k, v|
                    if(~ui[k].notNil and: { v.notNil }) {
                        if(~ui[k].isKindOf(Button)) {
                            ~ui[k].value = v.asInteger;
                        } {
                            ~ui[k].value = v;
                        };
                    };
                };
            };
            0.05.wait;
        };
    }).play(AppClock);
});
}.value;
)

// CLEANUP REFERENCE (DO NOT RUN AUTOMATICALLY):
// (
//   MIDIdef.freeAll;
//   ~synthGroup.free; ~fxGroup.free; ~masterGroup.free;
//   ~buses.do(_.free); ~busFx.free;
//   if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
// )

// === Round 13 [APPEND] Frag #125 (poema) ===
(
// --- FORMAL MOVE: Intrinsic Limit (b) transition into Resolution / Dawn (a) ---
// Embodying: "compasso torto da cidade grande" (asymmetric urban heartbeat),
// "faço do vento a minha própria asa" (airy noise resonance), and "amanhece sempre" (radiant dawn).

// 1. ADD_INSTRUMENT: CoracaoTorto (Skewed urban pulse & resonant wing/wind drone)
Ndef(\coracaoAsa, { |t_trig=0, freq=55, foldAmt=1.8, windRes=0.08, amp=0.22, pan=0|
    var trig = K2A.ar(t_trig);
    var heartEnv = EnvGen.ar(Env.perc(0.008, 0.28, curve: -4), trig);
    var wingEnv  = EnvGen.ar(Env.perc(0.12, 1.4, curve: -2), trig);

    // Deep chest heartbeat with asymmetrical wavefolding (using LFTri instead of DPW3Tri)
    var sub = SinOsc.ar(freq * [1, 2.01]) + (LFTri.ar(freq * 0.5) * 0.4);
    var subSaturated = Fold.ar(sub * foldAmt * (heartEnv + 0.2), -0.7, 0.7);

    // Wind as wing: filtered turbulent noise responding to the stride
    var noise = PinkNoise.ar() * wingEnv;
    var wind = BPF.ar(noise, [freq * 8, freq * 12.3], windRes) * 12.0;

    // Luminous dawn harmonic bloom
    var dawnSines = Mix.fill(4, { |i|
        SinOsc.ar(freq * (i + 1) * 2, 0, 0.1 / (i + 1))
    }) * wingEnv;

    var sig = (subSaturated * heartEnv * 1.4) + wind + dawnSines;
    Pan2.ar(LeakDC.ar(sig.sum), pan, amp);
}).play;

// 2. Pattern: Asymmetrical city beat ("compasso torto": 3/16, 5/16, 2/16, 6/16)
Pbindef(\coracaoSeq,
    \dur, Pseq([0.1875, 0.3125, 0.125, 0.375], inf),
    \t_trig, 1,
    \midinote, Pseq([36, 38, 33, 41, 43, 48], inf),
    \foldAmt, Pwhite(1.5, 3.2, inf),
    \windRes, Pwhite(0.03, 0.12, inf),
    \amp, Pseq([0.28, 0.2, 0.24, 0.18], inf),
    \pan, Pseq([-0.35, 0.35, -0.15, 0.2], inf)
);

// 3. Inject pattern into proxy slot
Ndef(\coracaoAsa)[1] = \set -> Pbindef(\coracaoSeq);

// 4. ADD_EFFECTS: Vast spatializer for the abyss/dawn horizon
Ndef(\coracaoAsa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.9, damp: 0.25);
};
Ndef(\coracaoAsa).xset(\wet10, 0.35);

// Rollback:
// Pbindef(\coracaoSeq).stop; Ndef(\coracaoAsa).fadeTime = 2; Ndef(\coracaoAsa).clear(2); // Rollback: remove this instrument
// Ndef(\coracaoAsa).set(\wet10, 0); // Rollback: disable this effect
)

// === Round 14 [COMPOSE] Frag #178 (descricao_imagem) ===
(
s.waitForBoot({
    var s = Server.default;
    ~enableRecording = false;

    // 1. Bus and Safety Limiter Architecture
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

    // 2. Discrete Physical Modeling Synths
    // Arara-Canindé screech & aerodynamic wing flap
    SynthDef(\araraGrito, { |out=0, freq=1800, bend=1.35, dur=0.45, amp=0.25, pan=0, foldAmt=2.2|
        var fEnv = EnvGen.ar(Env([freq, freq * bend, freq * 0.72], [dur * 0.28, dur * 0.72], \exp));
        var ampEnv = EnvGen.ar(Env.perc(0.015, (dur - 0.015).max(0.05), curve: -4), doneAction: 2);
        // Dual harsh FM vocal tract
        var mod = SinOsc.ar(fEnv * 2.84) * (fEnv * 1.6);
        var car = SinOsc.ar(fEnv + mod) + (Saw.ar(fEnv * 0.5) * 0.4);
        var folded = Fold.ar(car * foldAmt, -0.75, 0.75);
        var filtered = BPF.ar(folded, [fEnv, fEnv * 1.6], 0.18).sum * 2.2;
        var sig = Pan2.ar(filtered * ampEnv, pan, amp);
        Out.ar(out, sig);
    }).add;

    // Fervedouro hydro-acoustic bubbling & suspended mineral sand
    SynthDef(\fervedouroGota, { |out=0, baseFreq=480, rise=2.4, dur=0.18, amp=0.2, pan=0|
        var pitEnv = EnvGen.ar(Env([baseFreq, baseFreq * rise, baseFreq * 0.85], [dur * 0.35, dur * 0.65], \exp));
        var env = EnvGen.ar(Env.perc(0.003, (dur - 0.003).max(0.02), curve: -6), doneAction: 2);
        var sine = SinOsc.ar(pitEnv) * 1.2;
        var sandGrit = BPF.ar(WhiteNoise.ar(), pitEnv * 4.2, 0.22) * 2.8;
        var bubble = (sine + sandGrit).tanh;
        var sig = Pan2.ar(bubble * env, pan, amp);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // 3. Continuous Ndef Textures
    // Falésias de Arenito: Resonant arid wind and towering warm sandstone reflection
    Ndef(\falesiasVento, { |amp=0, windCut=1200, res=0.15|
        var n = PinkNoise.ar([1, 1]);
        var gusts = LFNoise2.kr([0.2, 0.17]).range(0.3, 1.0);
        var cliff = DynKlank.ar(
            `[ [82.4, 164.8, 246.9, 329.6, 493.8], [0.8, 0.6, 0.4, 0.25, 0.15], [2.2, 2.5, 1.8, 1.4, 0.9] ],
            BPF.ar(n, windCut * gusts, res)
        ) * 0.04;
        var sub = SinOsc.ar([41.2, 41.5]) * 0.22 * gusts;
        (cliff + sub) * amp;
    });
    Ndef(\falesiasVento).fadeTime = 3;

    // Veredas de Buritis: Rustling giant fan palms and subterranean aquifer pressure
    Ndef(\veredasPalmas, { |amp=0, rustleRate=8, aquaFreq=98|
        var rustleTrig = Dust.ar(rustleRate ! 2);
        var fronds = Decay2.ar(rustleTrig, 0.01, 0.12) * BPF.ar(WhiteNoise.ar(), [2400, 3100], 0.2) * 4.5;
        var waterBed = SinOsc.ar(aquaFreq * [1, 1.015]) * LFPulse.kr(0.35, 0, 0.4).range(0.2, 0.6);
        waterBed = (waterBed + (fronds * 0.6)).tanh;
        waterBed * amp;
    });
    Ndef(\veredasPalmas).fadeTime = 2.5;

    // 4. Master Mixer & Spatial Processing
    Ndef(\masterMix, {
        var busSig = In.ar(~synthBus, 2);
        var falesias = Ndef.ar(\falesiasVento, 2);
        var veredas = Ndef.ar(\veredasPalmas, 2);
        busSig + falesias + veredas;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.22);
    };
    Ndef(\masterMix).set(\wet10, 0.24);

    Ndef(\masterMix)[11] = \filter -> { |in|
        CombL.ar(in, 0.35, [0.18, 0.24], 1.8);
    };
    Ndef(\masterMix).set(\wet11, 0.0);

    Ndef(\masterMix).play;
    s.sync;

    // 5. Pattern Sequencing Definitions
    Pbindef(\araraFlock,
        \instrument, \araraGrito,
        \out, ~synthBus,
        \dur, Pseq([0.18, 0.12, 0.24, 0.09, 0.36], inf),
        \freq, Pexprand(1100, 2400, inf),
        \bend, Pwhite(1.15, 1.6, inf),
        \foldAmt, Pwhite(1.8, 3.2, inf),
        \amp, Pwhite(0.12, 0.22, inf),
        \pan, Pwhite(-0.85, 0.85, inf)
    );

    Pbindef(\fervedouroRhythm,
        \instrument, \fervedouroGota,
        \out, ~synthBus,
        \dur, Pseq([0.08, 0.06, 0.14, 0.09, 0.11, 0.05], inf),
        \baseFreq, Pexprand(320, 850, inf),
        \rise, Pwhite(1.8, 3.4, inf),
        \amp, Pwhite(0.14, 0.26, inf),
        \pan, Pwhite(-0.6, 0.6, inf)
    );

    // 6. Chronological Score Timeline (~110 seconds)
    Tdef(\masterScore, {
        0.5.wait;

        // Cue 1: 0:00 - The Monolithic Red Sandstone Walls (Serra do Espírito Santo)
        "0:00 - [Cue 1: Silhueta da Serra e Vento no Arenito]".postln;
        Ndef(\falesiasVento).xset(\amp, 0.45, \windCut, 850, \res, 0.2);
        Ndef(\masterMix).set(\wet10, 0.35);

        4.do { |i|
            Ndef(\falesiasVento).xset(\windCut, 700 + (i * 180));
            3.0.wait;
        };

        // Cue 2: 0:12 - Green Veredas and Deep Buriti Aquifers
        "0:12 - [Cue 2: Estandartes Verdes e Nascentes de Buritis]".postln;
        Ndef(\veredasPalmas).xset(\amp, 0.38, \rustleRate, 6, \aquaFreq, 92);
        2.do { |i|
            Ndef(\falesiasVento).xset(\res, 0.1 + (i * 0.05));
            4.0.wait;
        };

        // Cue 3: 0:20 - Turquesa Fervedouro: Suspended White Sands Boil
        "0:20 - [Cue 3: Águas Azul-Turquesa e Areia Branca Fervilhante]".postln;
        Ndef(\masterMix).set(\wet11, 0.18);
        Pbindef(\fervedouroRhythm).play;

        3.do { |i|
            Ndef(\veredasPalmas).xset(\rustleRate, 9 + (i * 4));
            Pbindef(\fervedouroRhythm, \amp, Pwhite(0.16 + (i * 0.03), 0.28 + (i * 0.02), inf));
            4.0.wait;
        };

        // Cue 4: 0:32 - First Cries of Yellow and Cobalt (Araras-Canindé Calling)
        "0:32 - [Cue 4: Primeiros Revoares de Amarelo e Azul]".postln;
        Pbindef(\araraFlock, \dur, Pseq([0.45, 0.38, 0.62], inf), \amp, Pwhite(0.12, 0.18, inf));
        Pbindef(\araraFlock).play;

        4.do { |i|
            Ndef(\falesiasVento).xset(\windCut, 1200 + (i * 220));
            3.0.wait;
        };

        // Cue 5: 0:44 - Spiral Ascent: Kinetic Climax Against the Pure Sky
        "0:44 - [Cue 5: Decolagem em Espiral Veloz Contra o Céu do Jalapão]".postln;
        Pbindef(\araraFlock,
            \dur, Pseq([0.11, 0.08, 0.15, 0.07, 0.2], inf),
            \freq, Pexprand(1400, 3100, inf),
            \amp, Pwhite(0.18, 0.28, inf),
            \foldAmt, Pwhite(2.5, 4.0, inf)
        );
        Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0.32);

        5.do { |i|
            Ndef(\veredasPalmas).xset(\aquaFreq, 110 + (i * 12));
            Pbindef(\fervedouroRhythm, \dur, Pseq([0.05, 0.04, 0.08, 0.06], inf));
            2.5.wait;
        };

        // Cue 6: 0:56 - Intrinsic Limit: Blinding Sun and Aerodynamic Thermal
        "0:56 - [Cue 6: Limiar Térmico e Resplendor Solar]".postln;
        Pbindef(\araraFlock, \dur, Pseq([0.06, 0.05, 0.09], inf), \freq, Pexprand(2200, 3800, inf));
        Ndef(\falesiasVento).xset(\windCut, 3400, \res, 0.08);
        4.0.wait;

        // Cue 7: 1:00 - Settling & Dispersion: Araras Glide High Over the Plateau
        "1:00 - [Cue 7: Asas Planando Sobre o Arenito Infinito]".postln;
        Pbindef(\araraFlock).stop;
        Ndef(\masterMix).set(\wet11, 0.08);
        Ndef(\falesiasVento).xset(\amp, 0.28, \windCut, 680, \res, 0.22);
        Pbindef(\fervedouroRhythm, \dur, Pseq([0.16, 0.12, 0.28], inf), \amp, Pwhite(0.08, 0.15, inf));

        3.do { |i|
            Ndef(\veredasPalmas).xset(\rustleRate, (7 - (i * 2)).max(2));
            4.0.wait;
        };

        // Cue 8: 1:12 - Return to the Fervedouro Springs (Resolution)
        "1:12 - [Cue 8: Resolução - O Sussurro das Veredas e Águas Claras]".postln;
        Pbindef(\araraFlock,
            \dur, Pseq([1.4, 2.1, 1.8], inf),
            \freq, Pexprand(950, 1600, inf),
            \amp, Pwhite(0.06, 0.11, inf),
            \foldAmt, 1.4
        );
        Pbindef(\araraFlock).play;

        3.do { |i|
            Ndef(\falesiasVento).xset(\amp, 0.2 - (i * 0.05));
            Ndef(\veredasPalmas).xset(\amp, 0.22 - (i * 0.05));
            4.0.wait;
        };

        // Cue 9: 1:24 - Extrinsic Limit: Evaporation into Pure Sky Silence
        "1:24 - [Cue 9: Dissolução no Azul Imaculado]".postln;
        Pbindef(\araraFlock).stop;
        Pbindef(\fervedouroRhythm).stop;
        Ndef(\falesiasVento).xset(\amp, 0.0);
        Ndef(\veredasPalmas).xset(\amp, 0.0);
        6.0.wait;

        // Scoped Termination
        Pbindef(\araraFlock).clear;
        Pbindef(\fervedouroRhythm).clear;
        Ndef(\falesiasVento).clear(2);
        Ndef(\veredasPalmas).clear(2);
        Ndef(\masterMix).clear(2);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)

// === Round 15 [DESIGN] Frag #85 (wikipedia) ===
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
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\subtractiveDesign).fadeTime = 1.5;
Ndef(\subtractiveDesign, {
    |freq=65.41, detune=0.0141, sawMix=0.69, pulseMix=0.31,
     pw=0.49, pwmRate=2.38, pwmDepth=0.13,
     subAmp=0.17, noiseAmp=0.027,
     cutoff=3217.2, rq=0.55, hpf=82.8,
     filtEnvAmt=1309.7, lfoRate=1.62, lfoDepth=487.2,
     atk=0.171, dec=0.59, sus=0.63, rls=1.25,
     pan=(0.01), amp=0.32, t_trig=1|
    var env, filtEnv, freqs, pwm, sawSig, pulseSig, subSig, noiseSig, sig, dynCutoff;

    env = EnvGen.ar(Env([0, 1, sus, 0], [atk, dec, rls], \sin), t_trig);
    filtEnv = EnvGen.ar(Env.perc(atk.max(0.005), (dec + rls).clip(0.1, 2.5)), t_trig);

    freqs = freq * [1 - detune, 1, 1 + detune];
    pwm = (pw + (SinOsc.kr(pwmRate) * pwmDepth)).clip(0.08, 0.92);

    sawSig = Splay.ar(Saw.ar(freqs));
    pulseSig = Splay.ar(Pulse.ar(freqs, pwm));
    subSig = SinOsc.ar(freq * 0.5) * subAmp;
    noiseSig = PinkNoise.ar * noiseAmp;

    sig = (sawSig * sawMix) + (pulseSig * pulseMix) + subSig + noiseSig;

    dynCutoff = (cutoff + (filtEnv * filtEnvAmt) + (SinOsc.kr(lfoRate) * lfoDepth)).clip(60, 18000);
    sig = RLPF.ar(sig, dynCutoff, rq.clip(0.08, 0.95));
    sig = HPF.ar(sig, hpf.clip(20, 2000));
    sig = (sig * 1.4).tanh;

    sig = Balance2.ar(sig[0], sig[1], pan) * env * amp;
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\subtractiveDesign)[10] = \filter -> { |in|
    CombL.ar(in, 0.5, 0.125, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.15);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.69, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.37);

Pbindef(\subtractiveDesignSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \freq, (65.41 * (2 ** (Prand([0, 2, 3, 5, 7, 8, 10], inf) / 12))),
    \t_trig, 1
);
Ndef(\subtractiveDesign)[1] = \set -> Pbindef(\subtractiveDesignSeq);

// Live MIDI control (loopMIDI -> BeatStep Pro -> any external hardware MIDI)
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
    MIDIClient.sources.first
};
if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ~myUid = ~myInDevice.uid;
    ("Design Fallback MIDI connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
} {
    ~myUid = nil;
};
MIDIdef.noteOn(\subtractiveDesignMidiOn, { |vel, noteNum|
    Pbindef(\subtractiveDesignSeq).stop;
    Ndef(\subtractiveDesign).set(\freq, noteNum.midicps, \amp, vel.linlin(1, 127, 0.12, 0.42), \t_trig, 1);
}, srcID: ~myUid);
MIDIdef.cc(\subtractiveDesignMidiCC, { |val, num|
    if((num == 1) or: { num == 74 }) {
        Ndef(\subtractiveDesign).set(\cutoff, val.linexp(0, 127, 120, 14000));
    };
}, srcID: ~myUid);
}.value;
)

// === Round 16 [GENERATE] Frag #113 (poema) ===
(
// Manuel Bandeira - "O Último Poema": terno, ardente, límpido, trágico
var sRoot = 48.midicps; // C3 tonal center

// --- Layer 1: Chama Límpida (Pure Crystalline Resonant Bell / Diamond Flame) ---
Ndef(\diamante).fadeTime = 3.0;
Ndef(\diamante, {
    |freq=523.25, pan=0.0, amp=0.22, bright=1.0, decay=2.8, t_trig=1|
    var trigA, exciter, modes, rings, sig, env;
    trigA = K2A.ar(t_trig);
    exciter = Decay2.ar(trigA, 0.001, 0.02) * WhiteNoise.ar(0.12);
    // Crystalline inharmonic modes (diamond purity)
    modes = freq * [1.0, 2.76, 4.07, 5.43, 6.82, 8.21];
    rings = [1.0, 0.72, 0.54, 0.41, 0.28, 0.19] * decay;
    sig = DynKlank.ar(Ref([modes, [0.35, 0.22, 0.16, 0.12, 0.08, 0.05] * bright, rings]), exciter);
    env = EnvGen.ar(Env.perc(0.002, decay.max(0.1)), t_trig);
    sig = sig * env;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\diamante)[10] = \filter -> { |in|
    CombL.ar(in, 0.6, [0.375, 0.5], 2.4);
};
Ndef(\diamante).set(\wet10, 0.28);

Ndef(\diamante)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.2);
};
Ndef(\diamante).set(\wet11, 0.42);

// --- Layer 2: Soluço sem Lágrimas (Ardent, Tender Broken Breath Pad) ---
Ndef(\amantes).fadeTime = 4.0;
Ndef(\amantes, {
    |freq=130.81, pan=0.0, amp=0.24, cutoff=1400, res=2.2, t_trig=1|
    var detune, oscs, filterEnv, ampEnv, sig, flutter, sob;
    flutter = SinOsc.kr(4.8, 0, 0.012);
    detune = [0.994, 1.0, 1.006] * (1 + flutter);
    // Warm tender saw-pulse hybrid
    oscs = Splay.ar(Pulse.ar(freq * detune, SinOsc.kr(0.18).range(0.35, 0.65)) + Saw.ar(freq * detune * 0.5, 0.5));
    // The "sob": a choked, tender swell and sudden settling
    filterEnv = EnvGen.ar(Env([ cutoff * 0.5, cutoff * 2.2, cutoff * 0.8, cutoff * 0.4 ], [0.3, 0.7, 1.8], \exp), t_trig);
    ampEnv = EnvGen.ar(Env([0, 1, 0.75, 0], [0.25, 0.85, 2.2], \sin), t_trig);
    // Moog resonant warmth
    sig = MoogFF.ar(oscs, filterEnv.clip(40, 16000), res) * 2.8;
    sob = PinkNoise.ar(0.015) * EnvGen.ar(Env.perc(0.08, 0.6), t_trig);
    sig = LeakDC.ar(sig + sob).tanh;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp * ampEnv) } { Pan2.ar(sig, pan, amp * ampEnv) };
}).play;

Ndef(\amantes)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.4);
};
Ndef(\amantes).set(\wet10, 0.35);

// --- Layer 3: Flores Quase sem Perfume (Delicate Inaudible Air & Harmonic Glass) ---
Ndef(\flores).fadeTime = 5.0;
Ndef(\flores, {
    |fund=65.41, amp=0.18, pan=0.0|
    var breeze, slowLfo, formantBank, freqs, sig;
    slowLfo = SinOsc.kr(0.07).range(0.2, 0.8);
    breeze = PinkNoise.ar(0.08) * LFNoise2.kr(0.2).range(0.3, 1.0);
    freqs = fund * [3, 4, 5, 7, 9, 11];
    formantBank = freqs.collect { |f, i|
        var bpfSig = BPF.ar(breeze, f * SinOsc.kr(0.04 + (i * 0.01)).range(0.98, 1.02), 0.018) * 12.0;
        Pan2.ar(bpfSig, SinOsc.kr(0.1 + (i * 0.05)))
    }.sum;
    sig = formantBank * slowLfo;
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\flores)[10] = \filter -> { |in|
    CombL.ar(in, 0.8, [0.55, 0.72], 3.2);
};
Ndef(\flores).set(\wet10, 0.3);

// --- Pattern Sequencing ---
// C Minor add9 / Ab maj7 emotional farewell harmony
Pbindef(\diamanteSeq,
    \dur, Pwrand([0.5, 0.75, 1.0, 1.5], [0.35, 0.3, 0.2, 0.15], inf),
    \midinote, Pseq([72, 75, 74, 70, 79, 75, 82, 79, 74, 72, 67, 70], inf),
    \bright, Pwhite(0.7, 1.25, inf),
    \decay, Pwhite(2.2, 3.8, inf),
    \pan, Pwhite(-0.55, 0.55, inf),
    \amp, Pwhite(0.14, 0.22, inf),
    \t_trig, 1
);
Ndef(\diamante).quant = 1;
Ndef(\diamante)[1] = \set -> Pbindef(\diamanteSeq);

Pbindef(\amantesSeq,
    \dur, Pseq([3.0, 3.5, 4.0, 3.5], inf),
    \midinote, Pseq([
        [48, 55, 58, 62], // Cm9 (desespero contido)
        [44, 51, 58, 63], // Abmaj7#11 (ternura)
        [46, 53, 56, 60], // Bb add9 (chama)
        [43, 50, 55, 58]  // Gm7 (o beijo derradeiro)
    ], inf),
    \cutoff, Pwhite(1100, 1900, inf),
    \res, Pwhite(1.8, 2.6, inf),
    \amp, 0.22,
    \t_trig, 1
);
Ndef(\amantes).quant = 1;
Ndef(\amantes)[1] = \set -> Pbindef(\amantesSeq);
)

// Live Performance Controls:
// Ndef(\diamante).xset(\decay, 5.0); // Prolong crystalline diamond ring | Revert: Ndef(\diamante).xset(\decay, 2.8);
// Pbindef(\diamanteSeq, \dur, 0.25); // Accelerate diamond precipitation | Revert: Pbindef(\diamanteSeq, \dur, Pwrand([0.5, 0.75, 1.0, 1.5], [0.35, 0.3, 0.2, 0.15], inf));
// Ndef(\amantes).xset(\cutoff, 3400); // Unleash ardent desperate cry | Revert: Ndef(\amantes).xset(\cutoff, 1400);
// Pbindef(\amantesSeq, \dur, 2.0); // Hasten parting cadence | Revert: Pbindef(\amantesSeq, \dur, Pseq([3.0, 3.5, 4.0, 3.5], inf));
// Pbindef(\diamanteSeq).stop; Ndef(\diamante).fadeTime = 4; Ndef(\diamante).clear(4); // Rollback diamante
// Pbindef(\amantesSeq).stop; Ndef(\amantes).fadeTime = 4; Ndef(\amantes).clear(4); // Rollback amantes
// Ndef(\flores).fadeTime = 4; Ndef(\flores).clear(4); // Rollback flores

// === Round 17 [COMPOSE] Frag #19 (wikipedia) ===
(
s.waitForBoot({
    var clockTones, tensionCables;

    // --- 1. Audio Bus & Master Limiter Setup ---
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

    // --- 2. Discrete Synthesis: Clock Tower Chime & Steel Funicular Cables ---
    SynthDef(\clockChime, {
        |out=0, freq=330, amp=0.22, pan=0.0, ringTime=4.5|
        var strike, partials, sig, env;
        env = EnvGen.ar(Env.perc(0.002, ringTime, 1.0, -4), doneAction: 2);
        strike = Impulse.ar(0) + (PinkNoise.ar(0.3) * EnvGen.ar(Env.perc(0.001, 0.015)));
        // Inharmonic English station bell partial ratios
        partials = DynKlank.ar(
            `[
                freq * [0.5, 1.0, 1.22, 1.58, 2.01, 2.76, 3.42],
                [0.7, 1.0, 0.45, 0.35, 0.25, 0.15, 0.08],
                [1.2, 1.0, 0.8, 0.65, 0.5, 0.35, 0.2] * ringTime
            ],
            strike
        );
        sig = partials * env;
        sig = (sig * 1.5).tanh * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\funicularCable, {
        |out=0, freq=92, tension=1.2, decay=3.2, amp=0.25, pan=(-0.25)|
        var exciter, string, env, damp;
        env = EnvGen.ar(Env.perc(0.01, decay, 1.0, -3), doneAction: 2);
        exciter = GrayNoise.ar(0.25) * EnvGen.ar(Env.perc(0.005, 0.08));
        damp = SinOsc.kr(0.3).range(0.15, 0.45);
        // Stiff vibrating steel cable under strain
        string = Pluck.ar(
            exciter,
            1,
            0.2,
            (freq * tension).reciprocal.clip(0.0002, 0.19),
            decay,
            damp
        );
        string = HPF.ar(string, 45);
        string = (MoogFF.ar(string, freq * 8, 1.8) * 2.2).tanh;
        Out.ar(out, Pan2.ar(string * env * amp, pan));
    }).add;

    SynthDef(\steamVent, {
        |out=0, dur=1.8, amp=0.18, pan=0.3|
        var noise, env, flt;
        env = EnvGen.ar(Env([0, 1, 0.4, 0], [0.08, dur * 0.4, dur * 0.52]), doneAction: 2);
        noise = WhiteNoise.ar(0.4) + BrownNoise.ar(0.6);
        flt = BPF.ar(noise, XLine.kr(2800, 750, dur), 0.25) * 4.0;
        Out.ar(out, Pan2.ar(flt * env * amp, pan));
    }).add;

    s.sync;

    // --- 3. Continuous Ndefs: Serra do Mar Fog & Atlantic Moisture Winds ---
    Ndef(\neblinaVento).fadeTime = 3.5;
    Ndef(\neblinaVento, {
        |amp=0.0, windCut=420, gust=0.15|
        var air, seaWind, fogSwell, subDrone, sig, panCtrl;
        air = PinkNoise.ar(0.12) * LFNoise2.kr(0.18).range(0.4, 1.2);
        seaWind = BPF.ar(air, [windCut, windCut * 1.62], 0.14) * 8.0;
        fogSwell = CombL.ar(seaWind, 0.4, [0.18, 0.24], 1.8);
        subDrone = SinOsc.ar([46.25, 46.8]) * 0.12; // Low mountain escarpment mass
        sig = (seaWind + fogSwell + subDrone) * (1.0 + (LFNoise1.kr(0.4) * gust));
        panCtrl = LFNoise1.kr(0.1).range(-0.4, 0.4);
        if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], panCtrl, amp) } { Pan2.ar(sig, panCtrl, amp) };
    });

    Ndef(\funicularWhine).fadeTime = 4.0;
    Ndef(\funicularWhine, {
        |amp=0.0, pullFreq=184|
        var steel, mod, lfo;
        lfo = SinOsc.kr(0.22).range(0.92, 1.08);
        mod = Pulse.ar(pullFreq * lfo, 0.12, 0.3) * SinOsc.ar(pullFreq * 2.01, 0, 0.4);
        steel = DynKlank.ar(
            `[
                pullFreq * [1, 2.34, 3.82, 5.2],
                [0.4, 0.25, 0.15, 0.08],
                [1.5, 1.2, 0.9, 0.6]
            ],
            mod
        );
        steel = HPF.ar(steel, 120);
        steel = Pan2.ar(steel, SinOsc.kr(0.12) * 0.6, amp * 0.25);
        (steel * 1.8).tanh;
    });

    // Master Mixer & Atmosphere Convolver
    Ndef(\masterMix).fadeTime = 2.0;
    Ndef(\masterMix, {
        var inSynths = In.ar(~synthBus, 2);
        var inWind = Ndef.ar(\neblinaVento, 2);
        var inWhine = Ndef.ar(\funicularWhine, 2);
        inSynths + inWind + inWhine;
    });

    // Space: Victorian Fog Reverb and Funicular Slapback
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.18);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        CombL.ar(in, 0.5, [0.28, 0.35], 2.2);
    };
    Ndef(\masterMix).set(\wet10, 0.38, \wet11, 0.12);
    Ndef(\masterMix).play;
    s.sync;

    // --- 4. Chronological Score (Timeline ~100s) ---
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Paranapiacaba: Neblina sobre a Serra do Mar]".postln;
        Ndef(\neblinaVento).play;
        Ndef(\neblinaVento).xset(\amp, 0.26, \windCut, 380);

        // Slow atmospheric breathing (Atlantic wind meets mountain wall)
        6.do { |i|
            Ndef(\neblinaVento).xset(\windCut, exprand(320, 680), \gust, rrand(0.1, 0.35));
            2.5.wait;
        };

        "0:15 - [O Grande Relógio Desperta entre a Bruma]".postln;
        // Westminster-inspired historical bell sequence
        // Fixed non-ASCII characters in symbol names (\relogioStation and \cabosAco)
        Pbindef(\relogioStation,
            \instrument, \clockChime,
            \out, ~synthBus,
            \dur, Pseq([1.5, 1.5, 1.5, 2.5, 1.5, 1.5, 2.0, 3.5], 1),
            \midinote, Pseq([68, 64, 66, 59, 59, 66, 68, 64], 1),
            \amp, 0.24,
            \ringTime, 5.0,
            \pan, Pwhite(-0.25, 0.25, inf)
        ).play;

        15.5.wait;

        "0:31 - [Tensão Mecânica: Os Cabos do Funicular Estalam]".postln;
        Ndef(\funicularWhine).play;
        Ndef(\funicularWhine).xset(\amp, 0.18, \pullFreq, 148);

        Pbindef(\cabosAco,
            \instrument, \funicularCable,
            \out, ~synthBus,
            \dur, Pwrand([0.75, 1.0, 1.5, 2.0], [0.4, 0.3, 0.2, 0.1], inf),
            \freq, Pseq([73.4, 82.4, 98.0, 110.0, 123.47], inf),
            \tension, Pwhite(0.98, 1.24, inf),
            \decay, Pwhite(2.5, 4.2, inf),
            \amp, Pwhite(0.18, 0.26, inf),
            \pan, Pwhite(-0.6, 0.4, inf)
        ).play;

        // Active evolution of mechanical pull and steam releases
        4.do { |i|
            Synth(\steamVent, [\out, ~synthBus, \dur, rrand(1.2, 2.4), \amp, 0.14, \pan, 0.4]);
            Ndef(\funicularWhine).xset(\pullFreq, rrand(140, 210));
            Ndef(\neblinaVento).xset(\windCut, exprand(450, 950), \gust, 0.4);
            3.2.wait;
        };

        "0:44 - [Densificação da Neblina: Clímax Hidrostático]".postln;
        Ndef(\masterMix).set(\wet10, 0.58, \wet11, 0.28);
        Ndef(\neblinaVento).xset(\amp, 0.38, \windCut, 1150);

        // Accelerated station clock chimes through damp fog
        Pbindef(\relogioStation,
            \instrument, \clockChime,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.75, 0.5, 1.0, 0.5, 0.75, 2.5], 2),
            \midinote, Pseq([64, 68, 71, 76, 75, 71, 68, 64], inf),
            \amp, 0.22,
            \ringTime, 3.8,
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;

        13.0.wait;

        "0:57 - [Extrinsic Limit: Estiramento Máximo dos Cabos]".postln;
        Pbindef(\cabosAco, \dur, 0.5, \tension, 1.45, \decay, 1.8);
        Ndef(\funicularWhine).xset(\pullFreq, 280, \amp, 0.25);
        Synth(\steamVent, [\out, ~synthBus, \dur, 3.2, \amp, 0.22, \pan, 0.0]);

        6.0.wait;

        "1:03 - [Settling: O Eco Vazio dos Trilhos Abandonados]".postln;
        Pbindef(\cabosAco).stop;
        Pbindef(\relogioStation).stop;
        Ndef(\funicularWhine).fadeTime = 6.0;
        Ndef(\funicularWhine).xset(\amp, 0.0);
        Ndef(\masterMix).set(\wet10, 0.65, \wet11, 0.1);
        Ndef(\neblinaVento).xset(\amp, 0.22, \windCut, 310);

        // Single solitary toll echoing into the valley
        Synth(\clockChime, [\out, ~synthBus, \freq, 164.81, \amp, 0.3, \ringTime, 8.5, \pan, 0.0]);

        8.0.wait;

        "1:11 - [Dissolução Total na Névoa Atlântica]".postln;
        Ndef(\neblinaVento).fadeTime = 7.0;
        Ndef(\neblinaVento).xset(\amp, 0.0);

        7.5.wait;

        // Scoped Termination (Shared Server Safe)
        Pbindef(\relogioStation).stop; Pbindef(\relogioStation).clear;
        Pbindef(\cabosAco).stop; Pbindef(\cabosAco).clear;
        Ndef(\neblinaVento).clear(1);
        Ndef(\funicularWhine).clear(1);
        Ndef(\masterMix).clear(1);

        "Score Complete: Paranapiacaba desvanecida na serra.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)
