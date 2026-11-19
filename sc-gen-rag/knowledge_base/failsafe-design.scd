// Source: chimichango-carcara-synth.scd [Block 4]
// MODE: design
// THEME: Get the UID safely to lock incoming MIDIdefs
// KEYWORDS: combl, design, freeverb, get, incoming, lock, mididefs, rlpf, safely, saw, sinosc, the, uid
(
// Get the UID safely to lock incoming MIDIdefs
~myUid = if(~targetIn.notNil) { ~targetIn.uid } { nil };

// 1. Setup global control buses for dynamic CC modulation
~fmIndexBus = Bus.control(s, 1);
~fmIndexBus.set(1.5); // Default FM Index

~cutoffBus = Bus.control(s, 1);
~cutoffBus.set(1200); // Default Subtractive Cutoff

// 2. Create an array to keep track of playing polyphonic synths
~notes = Array.newClear(128);

// 3. Global CC Controls (Mod Wheel and Filter Cutoff)
MIDIdef.cc(\chimangoCC, {
	|val, num|
	// CC 1 (Mod Wheel) controls the intelligence/complexity of the FM layer
	if(num == 1) { ~fmIndexBus.set(val.linexp(0, 127, 0.1, 8.0)) };

	// CC 74 controls the earthy subtractive filter cutoff
	if(num == 74) { ~cutoffBus.set(val.linexp(0, 127, 200, 6000)) };
}, srcID: ~myUid);

// 4. Note ON: Instantiate the hybrid synth and store it
MIDIdef.noteOn(\chimangoOn,
	{
		|val, num, chan, src|

		// Safety check: release existing note if re-triggered
		if(~notes[num].notNil) { ~notes[num].set(\gate, 0) };

		~notes[num] = {
			arg fmIndex = 1.5, cutoff = 1200, gate = 1, freqMult = 1, ampMod = 1;
			var freq, amp, env, lagIndex, lagCutoff, mod, fm, sub, mix, panned, echo, verb, out;

			freq = num.midicps * freqMult;
			amp = val.linexp(1, 127, 0.01, 0.25) * ampMod;

			// Lag to prevent CC zipper noise
			lagIndex = Lag.kr(fmIndex, 0.1);
			lagCutoff = Lag.kr(cutoff, 0.1);

			// Raptor-like sharp attack and soaring release
			env = EnvGen.ar(Env.adsr(attackTime: 0.05, decayTime: 0.2, sustainLevel: 0.6, releaseTime: 1.2), gate, doneAction: 2);

			// --- The Raptor's Cry (FM Layer) ---
			// High-frequency vocal intelligence using pure SinOsc
			mod = SinOsc.ar(freq * 2.01) * freq * lagIndex;
			fm = SinOsc.ar(freq + mod);

			// --- Earthy Plumage (Subtractive Layer) ---
			// Warm, grounded sawtooth wave, passed through an RLPF
			sub = Saw.ar(freq * 0.5);
			sub = RLPF.ar(sub, lagCutoff, 0.3);

			// Mix the two distinct layers (FM bypasses the filter)
			mix = (fm * 0.5) + (sub * 0.5);

			// Stereo placement
			panned = Pan2.ar(mix * env * amp, 0);

			// --- Post-Filter Effects (Simulating Puerto Varas environments) ---
			// Spatial echoing
			echo = CombL.ar(panned, 0.3, 0.15, 2.5);

			// Atmospheric depth (100% wet internally)
			verb = FreeVerb.ar(panned + (echo * 0.4), 1.0, 0.85, 0.2);

			// Dynamically mix the dry/echo signal with the wet atmospheric reverb
			out = XFade2.ar(panned + (echo * 0.3), verb, -0.3);

			out;

		}.play(args: [\fmIndex, ~fmIndexBus.asMap, \cutoff, ~cutoffBus.asMap]);
	}, srcID: ~myUid
);

// 5. Note OFF: Find the active synth and release it gracefully
MIDIdef.noteOff(\chimangoOff,
	{
		|val, num, chan, src|
		if(~notes[num].notNil) {
			~notes[num].set(\gate, 0);
			~notes[num] = nil;
		}
	}, srcID: ~myUid
);
)

// Source: design-synth-butterfly-dance-MIDI.scd [Block 3]
// MODE: design
// THEME: A. CONTROL BUSES & INITIAL STATE DICTIONARY
// KEYWORDS: bpf, buses, control, design, dictionary, dynklank, freeverb2, fx_GroupA, fx_GroupB, fx_GroupC, fx_Master, hpf, initial, ringz, rlpf, state, zone1_Drum, zone2_Flicker, zone3_Flute, zone4_Drone, zone5_Pandean, zone6_Flutter
(
s.options.memSize = 131072;
s.boot;

s.waitForBoot({

    // A. CONTROL BUSES & INITIAL STATE DICTIONARY
    ~ccVals = (
        // Volumes (Conservative Headroom)
        vol1: 0.2, vol2: 0.3, vol3: 0.3, vol4: 0.2, vol5: 0.3, vol6: 0.3,
        // Panning Spread
        pan1: -0.2, pan2: 0.0, pan3: 0.2, pan4: 0.0, pan5: 0.0, pan6: 0.0,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0, mute5: 0.0, mute6: 0.0,

        // Key Ranges
        min1: 0, max1: 60, min2: 0, max2: 127, min3: 48, max3: 96,
        min4: 24, max4: 72, min5: 36, max5: 96, min6: 60, max6: 127,

        // Filters (Bracketed)
        hpf1: 20, hpf2: 150, hpf3: 300, hpf4: 80, hpf5: 200, hpf6: 1000,
        lpf1: 800, lpf2: 5000, lpf3: 10000, lpf4: 4000, lpf5: 8000, lpf6: 16000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0, rq5: 1.0, rq6: 1.0,

        // ADSR Defaults
        atk1: 0.01, dec1: 1.0, sus1: 1.0, rls1: 2.0,
        atk2: 0.01, dec2: 0.5, sus2: 0.2, rls2: 0.5,
        atk3: 1.5, dec3: 1.0, sus3: 1.0, rls3: 2.0,
        atk4: 0.8, dec4: 1.0, sus4: 1.0, rls4: 2.5,
        atk5: 2.0, dec5: 1.0, sus5: 1.0, rls5: 3.0,
        atk6: 0.5, dec6: 1.0, sus6: 1.0, rls6: 1.5,

        // Unique FX
        resDecay1: 0.5, grainDens2: 1.0, breathAmt3: 0.0,
        harmShift4: 1.0, formShift5: 1.0, flutterSpd6: 0.1,

        // Global FX (All start at 0.0 wet)
        mixA: 0.0, mixB: 0.0, mixC: 0.0,
        masterVerb: 0.0, masterDelay: 0.0, masterDelTime: 0.5
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // B. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroupA = Group.after(~synthGroup);
    ~fxGroupB = Group.after(~fxGroupA);
    ~fxGroupC = Group.after(~fxGroupB);
    ~masterGroup = Group.after(~fxGroupC);

    ~busA = Bus.audio(s, 2);
    ~busB = Bus.audio(s, 2);
    ~busC = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // C. SYNTHDEFS

    // ZONE 1: Great Drum Resonator (Mono, Physical Modeling)
    SynthDef(\zone1_Drum, { arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.2, pan=(-0.2), mute=0, hpf=20, lpf=800, rq=1, atk=0.01, dec=1.0, sus=1.0, rls=2.0, resDecay=0.5;
        var lagFreq = Lag.kr(freq, 0.2);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exciter = EnvGen.ar(Env.perc(0.001, 0.05)) * PinkNoise.ar;
        var freqs = [1.0, 1.5, 2.3, 3.5, 4.2] * lagFreq;
        var amps = [1.0, 0.6, 0.4, 0.2, 0.1];
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * resDecay;
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 2: Hand Drum Flicker (Poly, Granular/Noise)
    SynthDef(\zone2_Flicker, { arg out=0, freq=261.6, gate=1, vel=0.8, zoneVol=0.3, pan=0, mute=0, hpf=150, lpf=5000, rq=1, atk=0.01, dec=0.5, sus=0.2, rls=0.5, grainDens=1.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var trig = Dust.ar(grainDens);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05), trig);
        var sig = Ringz.ar(exciter, freq, 0.1);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig, sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Small Flute Breath (Poly, Subtractive)
    SynthDef(\zone3_Flute, { arg out=0, freq=523.25, gate=1, vel=0.8, zoneVol=0.3, pan=0.2, mute=0, hpf=300, lpf=10000, rq=1, atk=1.5, dec=1.0, sus=1.0, rls=2.0, breathAmt=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var noise = BPF.ar(PinkNoise.ar, freq, 0.1) * breathAmt * 4.0;
        var sig = SinOsc.ar(freq) + noise;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig, sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 4: Great Flute Drone (Mono, FM Synthesis)
    SynthDef(\zone4_Drone, { arg out=0, freq=130.8, gate=1, vel=0.8, zoneVol=0.2, pan=0, mute=0, hpf=80, lpf=4000, rq=1, atk=0.8, dec=1.0, sus=1.0, rls=2.5, harmShift=1.0;
        var lagFreq = Lag.kr(freq, 0.3);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var mod = SinOsc.ar(lagFreq * harmShift) * (harmShift * 300);
        var sig = SinOsc.ar(lagFreq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 5: Pandean Whisper (Poly/Paraphonic-feel, Formant)
    SynthDef(\zone5_Pandean, { arg out=0, freq=349.2, gate=1, vel=0.8, zoneVol=0.3, pan=0, mute=0, hpf=200, lpf=8000, rq=1, atk=2.0, dec=1.0, sus=1.0, rls=3.0, formShift=1.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Formant.ar(freq, freq * formShift, 400);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig, sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 6: Butterfly Flutter (Poly, Additive/Phasor)
    SynthDef(\zone6_Flutter, { arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.3, pan=0, mute=0, hpf=1000, lpf=16000, rq=1, atk=0.5, dec=1.0, sus=1.0, rls=1.5, flutterSpd=0.1;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var flutter = LFSaw.kr(flutterSpd).range(0.2, 1.0);
        var sig = Mix(Pulse.ar(freq * [1.0, 1.01, 0.99], 0.5)) * flutter * 0.3;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig, sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // FX SYNTHS
    SynthDef(\fx_GroupA, { |in, out, mixBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        sig = Compander.ar(sig, sig, 0.5, 1.0, 0.5, 0.01, 0.1);
        sig = sig + (FreeVerb2.ar(sig[0], sig[1], mix, 0.3, 0.8) * mix);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_GroupB, { |in, out, mixBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var chor = DelayC.ar(sig, 0.05, SinOsc.kr([0.5, 0.6]).range(0.01, 0.02));
        sig = sig + (chor * 0.5);
        sig = sig + (FreeVerb2.ar(sig[0], sig[1], mix, 0.6, 0.5) * mix);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_GroupC, { |in, out, mixBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var wide = [sig[0] + (sig[1]*0.5), sig[1] + (sig[0]*0.5)] * 0.7;
        sig = sig + (FreeVerb2.ar(wide[0], wide[1], mix, 0.8, 0.2) * mix);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_Master, { |in, out=0, verbBus, delMixBus, delTimeBus|
        var sig = In.ar(in, 2);
        var vMix = In.kr(verbBus);
        var dMix = In.kr(delMixBus);
        var dTime = Lag.kr(In.kr(delTimeBus), 0.1);
        var del;

        sig = sig + (FreeVerb2.ar(sig[0], sig[1], vMix, 0.9, 0.1) * vMix);
        del = CombC.ar(sig, 2.0, dTime, dTime * 4);
        sig = sig + (del * dMix);

        sig = HPF.ar(sig, 20);
        sig = LPF.ar(sig, 18000);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // D. INSTANTIATE EFFECTS
    ~fxA = Synth(\fx_GroupA, [\in, ~busA, \out, ~masterBus, \mixBus, ~buses.mixA], ~fxGroupA, \addToTail);
    ~fxB = Synth(\fx_GroupB, [\in, ~busB, \out, ~masterBus, \mixBus, ~buses.mixB], ~fxGroupB, \addToTail);
    ~fxC = Synth(\fx_GroupC, [\in, ~busC, \out, ~masterBus, \mixBus, ~buses.mixC], ~fxGroupC, \addToTail);
    ~fxM = Synth(\fx_Master, [\in, ~masterBus, \out, 0, \verbBus, ~buses.masterVerb, \delMixBus, ~buses.masterDelay, \delTimeBus, ~buses.masterDelTime], ~masterGroup, \addToTail);

    // E. SYNTH STATE & MIDI
    ~notes = Array.newClear(128);

    MIDIdef.cc(\kochoMaiCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.matchRegexp("lpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { key == \resDecay1 } { mapped.linexp(0, 1, 0.1, 4.0) }
                    { key == \grainDens2 } { mapped.linexp(0, 1, 1.0, 50.0) }
                    { key == \breathAmt3 } { mapped }
                    { key == \harmShift4 } { mapped.linexp(0, 1, 1.0, 10.0) }
                    { key == \formShift5 } { mapped.linexp(0, 1, 1.0, 10.0) }
                    { key == \flutterSpd6 } { mapped.linexp(0, 1, 0.1, 20.0) }
                    { key == \masterDelTime } { mapped.linexp(0, 1, 0.05, 2.0) }
                    { mapped }; // Default for vol, mixes

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\kochoMaiOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        // ZONE 1 (Mono - Kill previous Z1 synths)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes.do { |arr| if(arr.notNil) { arr.do { |syn| if(syn.defName == \zone1_Drum) { syn.set(\gate, 0) } } } };
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone1_Drum, [
                \out, ~busA, \freq, freq, \vel, vel, \gate, 1, \resDecay, ~buses.resDecay1.asMap,
                \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        // ZONE 2 (Poly)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Flicker, [
                \out, ~busA, \freq, freq, \vel, vel, \gate, 1, \grainDens, ~buses.grainDens2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // ZONE 3 (Poly)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone3_Flute, [
                \out, ~busB, \freq, freq, \vel, vel, \gate, 1, \breathAmt, ~buses.breathAmt3.asMap,
                \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        // ZONE 4 (Mono - Kill previous Z4 synths)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes.do { |arr| if(arr.notNil) { arr.do { |syn| if(syn.defName == \zone4_Drone) { syn.set(\gate, 0) } } } };
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Drone, [
                \out, ~busB, \freq, freq, \vel, vel, \gate, 1, \harmShift, ~buses.harmShift4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \hpf, ~buses.hpf4.asMap, \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };

        // ZONE 5 (Poly)
        if((noteNum >= ~ccVals[\min5]) and: { noteNum <= ~ccVals[\max5] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone5_Pandean, [
                \out, ~busB, \freq, freq, \vel, vel, \gate, 1, \formShift, ~buses.formShift5.asMap,
                \zoneVol, ~buses.vol5.asMap, \pan, ~buses.pan5.asMap, \mute, ~buses.mute5.asMap,
                \hpf, ~buses.hpf5.asMap, \lpf, ~buses.lpf5.asMap, \rq, ~buses.rq5.asMap,
                \atk, ~buses.atk5.asMap, \dec, ~buses.dec5.asMap, \sus, ~buses.sus5.asMap, \rls, ~buses.rls5.asMap
            ], target: ~synthGroup));
        };

        // ZONE 6 (Poly)
        if((noteNum >= ~ccVals[\min6]) and: { noteNum <= ~ccVals[\max6] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone6_Flutter, [
                \out, ~busC, \freq, freq, \vel, vel, \gate, 1, \flutterSpd, ~buses.flutterSpd6.asMap,
                \zoneVol, ~buses.vol6.asMap, \pan, ~buses.pan6.asMap, \mute, ~buses.mute6.asMap,
                \hpf, ~buses.hpf6.asMap, \lpf, ~buses.lpf6.asMap, \rq, ~buses.rq6.asMap,
                \atk, ~buses.atk6.asMap, \dec, ~buses.dec6.asMap, \sus, ~buses.sus6.asMap, \rls, ~buses.rls6.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\kochoMaiOff, { |vel, noteNum|
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    "kocho-Mai Butterfly Ensemble Initialized.".postln;
});
)

// Source: design-synth-butterfly-dance-MIDI.scd [Block 4]
// MODE: design
// THEME: STEP 4: PAGINATED GUI GENERATION
// KEYWORDS: design, generation, gui, hpf, paginated, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(6);
    var tabButtons = Array.newClear(6);
    var zoneNames = ["1: G. Drum", "2: H. Drum", "3: S. Flute", "4: G. Flute", "5: Pandean", "6: Flutter"];

    if(~kochoWin.notNil and: { ~kochoWin.isClosed.not }) { ~kochoWin.close };
    ~ui = ();

    ~kochoWin = Window("kocho-Mai Butterfly Ensemble", Rect(100, 100, 460, 800));
    ~kochoWin.view.background = Color.fromHexString("#2A2226");

    ~tabContainer = CompositeView(~kochoWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 2@0));
    ~pagesContainer = CompositeView(~kochoWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~kochoWin, Rect(15, 615, 430, 160));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#FFB6C1"), Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    zoneNames.do { |name, i|
        tabButtons[i] = Button(~tabContainer, 70@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.fromHexString("#FFB6C1")).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@8).background_(Color.gray(0.3));

        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.green(0.8));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.green(0.8));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.green(0.8));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.green(0.8));

        extraKnobs.value(box, kSize);
    };

    makeZone.value("Great Drum", 1, 0, { |box, kSize|
        ~ui[\resDecay1] = EZKnob(box, kSize, "ResDec " ++ ~cc[\resDecay1], ControlSpec(0.1, 4.0, \exp), { |kn| ~buses.resDecay1.set(kn.value); ~ccVals[\resDecay1] = kn.value; }, ~ccVals[\resDecay1]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });
    makeZone.value("Hand Drum", 2, 1, { |box, kSize|
        ~ui[\grainDens2] = EZKnob(box, kSize, "GrnDen " ++ ~cc[\grainDens2], ControlSpec(1.0, 50.0, \exp), { |kn| ~buses.grainDens2.set(kn.value); ~ccVals[\grainDens2] = kn.value; }, ~ccVals[\grainDens2]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });
    makeZone.value("Small Flute", 3, 2, { |box, kSize|
        ~ui[\breathAmt3] = EZKnob(box, kSize, "Breath " ++ ~cc[\breathAmt3], \amp, { |kn| ~buses.breathAmt3.set(kn.value); ~ccVals[\breathAmt3] = kn.value; }, ~ccVals[\breathAmt3]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });
    makeZone.value("Great Flute", 4, 3, { |box, kSize|
        ~ui[\harmShift4] = EZKnob(box, kSize, "HrmShf " ++ ~cc[\harmShift4], ControlSpec(1.0, 10.0, \exp), { |kn| ~buses.harmShift4.set(kn.value); ~ccVals[\harmShift4] = kn.value; }, ~ccVals[\harmShift4]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });
    makeZone.value("Pandean", 5, 4, { |box, kSize|
        ~ui[\formShift5] = EZKnob(box, kSize, "FrmShf " ++ ~cc[\formShift5], ControlSpec(1.0, 10.0, \exp), { |kn| ~buses.formShift5.set(kn.value); ~ccVals[\formShift5] = kn.value; }, ~ccVals[\formShift5]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });
    makeZone.value("Flutter", 6, 5, { |box, kSize|
        ~ui[\flutterSpd6] = EZKnob(box, kSize, "FlutSp " ++ ~cc[\flutterSpd6], ControlSpec(0.1, 20.0, \exp), { |kn| ~buses.flutterSpd6.set(kn.value); ~ccVals[\flutterSpd6] = kn.value; }, ~ccVals[\flutterSpd6]).setColors(stringColor: Color.fromHexString("#FFB6C1"));
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~fxContainer.background_(Color.gray(0.12, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 15@10, 10@10));
    StaticText(~fxContainer, 400@20).string_("ENSEMBLE EFFECTS").stringColor_(Color.fromHexString("#FFB6C1")).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\mixA] = EZSlider(~fxContainer, 190@30, "GrpA Mx " ++ ~cc[\mixA], \amp, { |sl| ~buses.mixA.set(sl.value); ~ccVals[\mixA] = sl.value; }, ~ccVals[\mixA], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\masterVerb] = EZSlider(~fxContainer, 190@30, "M.Verb " ++ ~cc[\masterVerb], \amp, { |sl| ~buses.masterVerb.set(sl.value); ~ccVals[\masterVerb] = sl.value; }, ~ccVals[\masterVerb], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\mixB] = EZSlider(~fxContainer, 190@30, "GrpB Mx " ++ ~cc[\mixB], \amp, { |sl| ~buses.mixB.set(sl.value); ~ccVals[\mixB] = sl.value; }, ~ccVals[\mixB], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\masterDelay] = EZSlider(~fxContainer, 190@30, "M.Dly Mx " ++ ~cc[\masterDelay], \amp, { |sl| ~buses.masterDelay.set(sl.value); ~ccVals[\masterDelay] = sl.value; }, ~ccVals[\masterDelay], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\mixC] = EZSlider(~fxContainer, 190@30, "GrpC Mx " ++ ~cc[\mixC], \amp, { |sl| ~buses.mixC.set(sl.value); ~ccVals[\mixC] = sl.value; }, ~ccVals[\mixC], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\masterDelTime] = EZSlider(~fxContainer, 190@30, "M.Dly Tm " ++ ~cc[\masterDelTime], ControlSpec(0.05, 2.0, \exp), { |sl| ~buses.masterDelTime.set(sl.value); ~ccVals[\masterDelTime] = sl.value; }, ~ccVals[\masterDelTime], labelWidth: 80).setColors(stringColor: Color.white);

    ~kochoWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~kochoWin.onClose = {
        ~guiRoutine.stop; ~kochoWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-butterfly-dance-MIDI.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~kochoWin.notNil and: { ~kochoWin.isClosed.not }) { ~kochoWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } });
    ~notes = nil;
};

~fxA.free; ~fxB.free; ~fxC.free; ~fxM.free;
~buses.keysValuesDo { |key, bus| bus.free };
~busA.free; ~busB.free; ~busC.free; ~masterBus.free;
~synthGroup.free; ~fxGroupA.free; ~fxGroupB.free; ~fxGroupC.free; ~masterGroup.free;

"kocho-Mai cleanup complete.".postln;
)

// Source: design-synth-dominostein-MIDI.scd [Block 3]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, freeverb2, fx_GroupReverbDelay, fx_Master, hpf, rlpf, saw, sinosc, zone1_Lebkuchen, zone2_Jelly, zone3_Marzipan, zone4_Chocolate
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. BUFFERS
    ~grainBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~grainBuf.sine1([1.0, 0.5, 0.25, 0.125], true, true, true);
    s.sync;

    ~wtBuf = Buffer.allocConsecutive(2, s, 2048, 1);
    s.sync;
    ~wtBuf[0].sine1([1], true, true, true); // Sine
    ~wtBuf[1].sine1((1..10).reciprocal, true, true, true); // Saw
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Adjusted volumes for ample headroom
        vol1: 0.2, vol2: 0.2, vol3: 0.2, vol4: 0.3,
        pan1: -0.2, pan2: 0.15, pan3: 0.0, pan4: 0.0,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Frequency bracketed key ranges
        min1: 0, max1: 127,
        min2: 0, max2: 127,
        min3: 0, max3: 127,
        min4: 0, max4: 127,

        lpf1: 8000, lpf2: 6000, lpf3: 10000, lpf4: 800,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 200, hpf2: 150, hpf3: 80, hpf4: 40,

        // ADSR Defaults
        atk1: 0.1, dec1: 0.3, sus1: 0.7, rls1: 0.5,
        atk2: 0.05, dec2: 0.2, sus2: 0.6, rls2: 0.8,
        atk3: 0.8, dec3: 0.5, sus3: 0.8, rls3: 2.0,
        atk4: 0.1, dec4: 0.3, sus4: 0.9, rls4: 1.0,

        // Specific Mods & Unique FX
        spice1: 0.0, wobble2: 0.0, glide3: 0.0, depth4: 0.0,

        // Global FX (Mixes at 0.0, Drive neutral at 1.0, Tone flat at 0.5)
        verbMix: 0.0, verbDec: 0.5, dlyMix: 0.0, dlyFb: 0.5, drive: 1.0, tone: 0.5
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS

    // GROUP FX: Reverb & Delay
    SynthDef(\fx_GroupReverbDelay, { |in, out, verbMixBus, verbDecBus, dlyMixBus, dlyFbBus|
        var sig = In.ar(in, 2);
        var verbMix = In.kr(verbMixBus);
        var verb = FreeVerb2.ar(sig[0], sig[1], verbMix, In.kr(verbDecBus), 0.5);
        var dlyMix = In.kr(dlyMixBus);
        var dlyFb = In.kr(dlyFbBus).linexp(0, 1, 0.1, 4.0);
        var dly = CombL.ar(verb, 1.0, [0.33, 0.44], dlyFb);
        Out.ar(out, verb + (dly * dlyMix));
    }).add;

    // MASTER FX: Drive, Tone (Tilt EQ), Limiter
    SynthDef(\fx_Master, { |in, out=0, driveBus, toneBus|
        var sig = In.ar(in, 2);
        var drive = In.kr(driveBus);
        var tone = In.kr(toneBus);
        var low, high;

        // Master Drive
        sig = (sig * drive).tanh / drive.max(1);

        // Master Tone (Tilt EQ Approximation around 800Hz)
        low = LPF.ar(sig, 800) * (1.0 - tone).linexp(0, 1, 0.5, 2.0);
        high = HPF.ar(sig, 800) * tone.linexp(0, 1, 0.5, 2.0);
        sig = low + high;

        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Lebkuchen Crumb Base (Granular)
    SynthDef(\zone1_Lebkuchen, { arg out=0, freq=440, gate=1, vel=0.8, bufnum, spice=0,
        vol=0.2, pan= -0.2, mute=0, atk=0.1, dec=0.3, sus=0.7, rls=0.5, hpf=200, lpf=8000, rq=1;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var trigRate = spice.linexp(0, 1, 5, 50);
        var trig = Impulse.ar(trigRate);
        var pos = LFNoise2.kr(0.1).range(0, 1);
        var rate = 1.0 + (spice * LFNoise1.kr(10).range(-0.5, 0.5));
        var sig = GrainBuf.ar(1, trig, 1.5/trigRate, bufnum, rate, pos, 2, 0);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * vol * (1 - mute)));
    }).add;

    // ZONE 2: Jelly Core (FM)
    SynthDef(\zone2_Jelly, { arg out=0, freq=440, gate=1, vel=0.8, wobble=0,
        vol=0.2, pan=0.15, mute=0, atk=0.05, dec=0.2, sus=0.6, rls=0.8, hpf=150, lpf=6000, rq=1;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var lfo = SinOsc.kr(wobble.linexp(0, 1, 0.1, 5)) * wobble;
        var mod = SinOsc.ar(freq * 2) * freq * (1 + (lfo * 2));
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * vol * (1 - mute)));
    }).add;

    // ZONE 3: Marzipan Smoothness (Wavetable)
    SynthDef(\zone3_Marzipan, { arg out=0, freq=440, gate=1, vel=0.8, bufnum, glide=0,
        vol=0.2, pan=0, mute=0, atk=0.8, dec=0.5, sus=0.8, rls=2.0, hpf=80, lpf=10000, rq=1;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var lfo = SinOsc.kr(glide.linexp(0, 1, 0.05, 2));
        var phase = glide * lfo * pi;
        var sig = COsc.ar(bufnum, freq * [0.99, 1.01], 1.0 + phase);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * vel * vol * (1 - mute)));
    }).add;

    // ZONE 4: Dark Chocolate Shell (Subtractive, Monophonic with Portamento)
    SynthDef(\zone4_Chocolate, { arg out=0, freq=65.4, gate=1, vel=0.8, depth=0,
        vol=0.3, pan=0, mute=0, atk=0.1, dec=0.3, sus=0.9, rls=1.0, hpf=40, lpf=800, rq=1;
        var lagFreq = Lag.kr(freq, 0.1);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Saw.ar(lagFreq) + Pulse.ar(lagFreq * 0.5, 0.5);
        var fold = sin(sig * depth.linexp(0, 1, 1, 5)) * 0.5;
        sig = SelectX.ar(depth, [sig, fold]);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf * depth.linexp(0, 1, 1.0, 0.2), rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * vol * (1 - mute)));
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~groupFx = Synth(\fx_GroupReverbDelay, [
        \in, ~groupBus, \out, ~masterBus,
        \verbMixBus, ~buses.verbMix, \verbDecBus, ~buses.verbDec,
        \dlyMixBus, ~buses.dlyMix, \dlyFbBus, ~buses.dlyFb
    ], ~fxGroup, \addToTail);

    ~masterFx = Synth(\fx_Master, [
        \in, ~masterBus, \out, 0,
        \driveBus, ~buses.drive, \toneBus, ~buses.tone
    ], ~masterGroup, \addToTail);

    // F. SYNTH STATE & MIDI
    ~notes = Array.newClear(128);
    ~chocoNotes = [];
    ~chocoSynth = nil;

    MIDIdef.cc(\dominoCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { key == \drive } { mapped.linexp(0, 1, 1.0, 10.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\dominoOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Polyphonic Zones (1, 2, 3)
        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone1_Lebkuchen, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \bufnum, ~grainBuf, \spice, ~buses.spice1.asMap,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Jelly, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \wobble, ~buses.wobble2.asMap,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone3_Marzipan, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \bufnum, ~wtBuf[0].bufnum, \glide, ~buses.glide3.asMap,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        // Monophonic Zone (4)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~chocoNotes = ~chocoNotes.add(noteNum);
            if(~chocoSynth.isNil) {
                ~chocoSynth = Synth(\zone4_Chocolate, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \depth, ~buses.depth4.asMap,
                    \vol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                    \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                    \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
                ], target: ~synthGroup);
            } {
                ~chocoSynth.set(\freq, freq, \gate, 1);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\dominoOff, { |vel, noteNum|
        // Polyphonic Release
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };

        // Monophonic Release Track
        if(~chocoNotes.includes(noteNum)) {
            ~chocoNotes.remove(noteNum);
            if(~chocoNotes.size > 0) {
                ~chocoSynth.set(\freq, ~chocoNotes.last.midicps);
            } {
                if(~chocoSynth.notNil) {
                    ~chocoSynth.set(\gate, 0);
                    ~chocoSynth = nil;
                };
            };
        };
    }, srcID: ~myUid);

    "Dominostein Ensemble Engine Initialized.".postln;
});
)

// Source: design-synth-dominostein-MIDI.scd [Block 4]
// MODE: design
// THEME: FIX: Added .notNil checks in the polling loop to prevent EZSlider/EZKnob from attempting to cast nil to float
// KEYWORDS: added, attempting, cast, checks, design, ezknob, ezslider, fix, float, hpf, loop, nil, notnil, polling, prevent, the
(
// FIX: Added .notNil checks in the polling loop to prevent EZSlider/EZKnob from attempting to cast nil to float
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~dominoWin.notNil and: { ~dominoWin.isClosed.not }) { ~dominoWin.close };
    ~ui = ();

    ~dominoWin = Window("Dominostein Ensemble", Rect(100, 100, 460, 800));
    ~dominoWin.view.background = Color.fromHexString("#2C1D11");

    ~tabContainer = CompositeView(~dominoWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~dominoWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~dominoWin, Rect(15, 615, 430, 160));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D2A679"), Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["LEBKUCHEN", "JELLY", "MARZIPAN", "CHOCOLATE"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 75@90;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 10@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        // Header & Mute
        StaticText(box, 230@30).string_("LAYER " ++ pref ++ ": " ++ name).stringColor_(Color.fromHexString("#F4D03F")).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        // Horizontal Mix & Mapping
        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@8).background_(Color.gray(0.3)); // Divider

        // Filters
        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        StaticText(box, 390@8).background_(Color.gray(0.3)); // Divider

        // Envelopes & Unique FX
        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#A9DFBF"));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#A9DFBF"));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#A9DFBF"));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#A9DFBF"));

        extraKnobs.value(box, kSize);
    };

    // Inject unique UI controls
    makeZone.value("Lebkuchen Crumb Base", 1, 0, { |box, kSize|
        ~ui[\spice1] = EZKnob(box, kSize, "Spice " ++ ~cc[\spice1], \amp, { |kn| ~buses.spice1.set(kn.value); ~ccVals[\spice1] = kn.value; }, ~ccVals[\spice1]).setColors(stringColor: Color.fromHexString("#F39C12"));
    });

    makeZone.value("Jelly Core", 2, 1, { |box, kSize|
        ~ui[\wobble2] = EZKnob(box, kSize, "Wobble " ++ ~cc[\wobble2], \amp, { |kn| ~buses.wobble2.set(kn.value); ~ccVals[\wobble2] = kn.value; }, ~ccVals[\wobble2]).setColors(stringColor: Color.fromHexString("#E74C3C"));
    });

    makeZone.value("Marzipan Smoothness", 3, 2, { |box, kSize|
        ~ui[\glide3] = EZKnob(box, kSize, "Glide " ++ ~cc[\glide3], \amp, { |kn| ~buses.glide3.set(kn.value); ~ccVals[\glide3] = kn.value; }, ~ccVals[\glide3]).setColors(stringColor: Color.fromHexString("#F1C40F"));
    });

    makeZone.value("Dark Chocolate Shell", 4, 3, { |box, kSize|
        ~ui[\depth4] = EZKnob(box, kSize, "Depth " ++ ~cc[\depth4], \amp, { |kn| ~buses.depth4.set(kn.value); ~ccVals[\depth4] = kn.value; }, ~ccVals[\depth4]).setColors(stringColor: Color.fromHexString("#8E44AD"));
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 15@10, 10@8));
    StaticText(~fxContainer, 400@20).string_("GLOBAL ENSEMBLE EFFECTS").stringColor_(Color.fromHexString("#F4D03F")).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\verbMix] = EZSlider(~fxContainer, 190@35, "Verb Mix (CC" ++ ~cc[\verbMix] ++ ")", \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 190@35, "Verb Dec (CC" ++ ~cc[\verbDecay] ++ ")", \amp, { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\dlyMix] = EZSlider(~fxContainer, 190@35, "Dly Mix (CC" ++ ~cc[\dlyMix] ++ ")", \amp, { |sl| ~buses.dlyMix.set(sl.value); ~ccVals[\dlyMix] = sl.value; }, ~ccVals[\dlyMix], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\dlyFb] = EZSlider(~fxContainer, 190@35, "Dly Fb (CC" ++ ~cc[\dlyFb] ++ ")", \amp, { |sl| ~buses.dlyFb.set(sl.value); ~ccVals[\dlyFb] = sl.value; }, ~ccVals[\dlyFb], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\drive] = EZSlider(~fxContainer, 190@35, "Drive (CC" ++ ~cc[\drive] ++ ")", ControlSpec(1.0, 10.0, \exp), { |sl| ~buses.drive.set(sl.value); ~ccVals[\drive] = sl.value; }, ~ccVals[\drive], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\tone] = EZSlider(~fxContainer, 190@35, "Tone (CC" ++ ~cc[\tone] ++ ")", \amp, { |sl| ~buses.tone.set(sl.value); ~ccVals[\tone] = sl.value; }, ~ccVals[\tone], labelWidth: 105).setColors(stringColor: Color.white);

    ~dominoWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            if(~ccVals.notNil) {
                ~ui.keysValuesDo { |key, widget|
                    var pref;
                    if(widget.notNil) {
                        if(key.asString.contains("range")) {
                            pref = key.asString.last.asString;
                            if(~ccVals[("min"++pref).asSymbol].notNil and: { ~ccVals[("max"++pref).asSymbol].notNil }) {
                                widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                            };
                        } {
                            if(~ccVals[key].notNil) {
                                widget.value = ~ccVals[key];
                            };
                        };
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~dominoWin.onClose = {
        ~guiRoutine.stop; ~dominoWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-dominostein-MIDI.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~dominoWin.notNil and: { ~dominoWin.isClosed.not }) { ~dominoWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } });
    ~notes = nil;
};

if(~chocoSynth.notNil) {
    ~chocoSynth.set(\gate, 0);
    ~chocoSynth = nil;
};

~groupFx.free; ~masterFx.free;
~buses.keysValuesDo { |key, bus| bus.free };
~groupBus.free; ~masterBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

if(~wtBuf.notNil) { ~wtBuf.do(_.free); ~wtBuf = nil; };
if(~grainBuf.notNil) { ~grainBuf.free };

"Dominostein Ensemble cleanup complete.".postln;
)

// Source: design-synth-example.scd [Block 1]
// MODE: design
// THEME: PASTE YOUR DEVICE NAME HERE:
// KEYWORDS: design, device, here, name, paste, your
(
// PASTE YOUR DEVICE NAME HERE:
var targetDeviceName = "loopMIDI Port";

~myInDevice = MIDIClient.sources.detect { |src| src.device == targetDeviceName };

~outIndex = MIDIClient.destinations.indexOf(
    MIDIClient.destinations.detect { |dest| dest.device == targetDeviceName }
);

// Connect MIDI In
if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    "MIDI IN connected successfully to: ".post; ~myInDevice.device.postln;

    // Store the UID globally so the Synth block can use it
    ~myUid = ~myInDevice.uid;
} {
    "Warning: MIDI IN device not found! Check the name string.".warn;
    ~myUid = nil;
};

// Connect MIDI Out
if(~outIndex.notNil) {
    ~mOut = MIDIOut(~outIndex);
    "MIDI OUT connected successfully.".postln;
} {
    "Warning: MIDI OUT device not found!".warn;
};
)

// Source: design-synth-example.scd [Block 2]
// MODE: design
// THEME: Wait for the server to boot before proceeding
// KEYWORDS: before, boot, design, for, proceeding, pulse, rlpf, server, the, wait
(
s.boot;

// Wait for the server to boot before proceeding
s.waitForBoot({

    // --- SYNTH STATE & BUSES ---
    // Array to store active Synth instances for polyphony
    ~notes = Array.newClear(128);

    // Control Bus for filter cutoff
    ~filterCutoffBus = Bus.control(s, 1);
    ~filterCutoffBus.set(5000); // Default CC value


    // --- MIDI CONTROLS (LOCKED TO ~myUid) ---
    // CC 74: Filter Cutoff
    MIDIdef.cc(\polySynthFilterCutoff, { |value, ccNum, channel, src|
        var mappedCutoff = value.linlin(0, 127, 80, 10000);
        ~filterCutoffBus.set(mappedCutoff);
    }, ccNum: 74, srcID: ~myUid);


    // Note ON: Instantiate the inline synth and store it
    MIDIdef.noteOn(\polySynthOn, { |velocity, noteNum, channel, src|
        var freq = noteNum.midicps;
        var amp = velocity / 127.0;

        // Safety check: release existing note if re-triggered
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].set(\gate, 0);
        };

        // Compile and play the synth inline
        ~notes[noteNum] = {
            arg freq=440, amp=0.5, gate=1,
            attack=0.01, decay=0.1, sustain=0.8, release=0.5,
            osc2Detune=0.002, pulseWidth=0.5, filterCutoff=5000,
            filterRes=0.1, pan=0.0;

            var env, osc1, osc2, mixedSig, filteredSig, panned;
            var cutoffLagged;

            // Smooth CC changes
            cutoffLagged = Lag.kr(filterCutoff, 0.02);

            // Oscillators
            osc1 = Pulse.ar(freq, pulseWidth);
            osc2 = Pulse.ar(freq * (1 + osc2Detune), pulseWidth);
            mixedSig = (osc1 + osc2) * 0.4;

            // Filter
            filteredSig = RLPF.ar(mixedSig, cutoffLagged, filterRes);

            // ADSR Envelope
            env = EnvGen.ar(Env.adsr(attack, decay, sustain, release), gate, doneAction: 2);

            // Panning & output formatting
            panned = Pan2.ar(filteredSig * env * amp, pan);

            panned;

        }.play(args: [
            \freq, freq,
            \amp, amp,
            \gate, 1,
            \filterCutoff, ~filterCutoffBus.asMap,
            \pan, (noteNum - 60) / 36.0.clip(-1.0, 1.0)
        ]);

    }, srcID: ~myUid);


    // Note OFF: Find the active synth and release it gracefully
    MIDIdef.noteOff(\polySynthOff, { |velocity, noteNum, channel, src|
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].set(\gate, 0); // Trigger release
            ~notes[noteNum] = nil;        // Clear reference
        };
    }, srcID: ~myUid);

    "PolySynth initialized and locked to UID: ".post; ~myUid.postln;
});
)

// Source: design-synth-example.scd [Block 3]
// MODE: design
// THEME: Free all MIDIdef functions
// KEYWORDS: all, design, free, functions, mididef
(
// Free all MIDIdef functions
MIDIdef.noteOn(\polySynthOn).free;
MIDIdef.noteOff(\polySynthOff).free;
MIDIdef.cc(\polySynthFilterCutoff).free;

// Release any currently active synths
if(~notes.notNil) {
    ~notes.do({ |synth, i|
        if(synth.notNil) {
            synth.set(\gate, 0);
        }
    });
    ~notes = nil;
};

// Free the control bus
if(~filterCutoffBus.notNil) {
    ~filterCutoffBus.free;
    ~filterCutoffBus = nil;
};

"PolySynth cleanup complete: MIDIdefs, active synths, and control buses have been freed.".postln;
)

// Source: design-synth-ragu-OSC.scd [Block 3]
// MODE: design
// THEME: A. CONTROL BUSES & STATE DICTIONARY
// KEYWORDS: bpf, buses, control, design, dictionary, fold, freeverb2, fx_GroupComp, fx_GroupVerb, fx_MasterDelay, fx_MasterEQ, fx_MasterLimiter, hpf, rlpf, saw, state, zone1_Meat, zone2_Tomato, zone3_Sauce, zone4_Pasta
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Volumes set to provide headroom
        vol1: 0.25, vol2: 0.3, vol3: 0.2, vol4: 0.15,
        pan1: 0.0, pan2: 0.15, pan3: 0.0, pan4: 0.0,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 48,
        min2: 49, max2: 72,
        min3: 36, max3: 96,
        min4: 73, max4: 127,

        // Filter Bracketing
        lpf1: 800, lpf2: 5000, lpf3: 10000, lpf4: 18000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 150, hpf3: 100, hpf4: 1000,

        // ADSR Defaults
        atk1: 0.5, dec1: 1.0, sus1: 1.0, rls1: 2.0,
        atk2: 0.1, dec2: 0.5, sus2: 0.7, rls2: 1.0,
        atk3: 2.0, dec3: 1.0, sus3: 1.0, rls3: 3.0,
        atk4: 0.01, dec4: 0.2, sus4: 0.0, rls4: 0.2,

        // Unique FX Default States
        maillard1: 0.0, zest2: 0.0, density3: 0.0, grains4: 0.0,

        // Global FX Default States (CRITICAL: Mixes at 0.0)
        verbMix: 0.0, verbDecay: 0.5,
        compThresh: 0.25, compRatio: 1.0, // Thresh 0.25 = -12dB, Ratio 1.0 = 1:1
        eqFreq: 1000.0, eqGain: 0.0,
        delayMix: 0.0, delayTime: 0.1
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // B. AUDIO ROUTING GROUPS & BUSES
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~verbBus = Bus.audio(s, 2);
    ~compBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);
    ~eqBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);

    // C. SYNTHDEFS

    // FX: Stew Pot Reverb
    SynthDef(\fx_GroupVerb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        var verb = FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.3);
        Out.ar(out, verb);
    }).add;

    // FX: Slow Cooker Compressor
    SynthDef(\fx_GroupComp, { |in, out, threshBus, ratioBus|
        var sig = In.ar(in, 2);
        var slope = 1.0 / max(1.0, In.kr(ratioBus));
        var comp = Compander.ar(sig, sig, In.kr(threshBus), 1.0, slope, 0.01, 0.1);
        Out.ar(out, comp);
    }).add;

    // FX: Master Mid-Range EQ
    SynthDef(\fx_MasterEQ, { |in, out, freqBus, gainBus|
        var sig = In.ar(in, 2);
        var eq = BPeakEQ.ar(sig, In.kr(freqBus), 1.0, In.kr(gainBus));
        Out.ar(out, eq);
    }).add;

    // FX: Steam Haze Delay
    SynthDef(\fx_MasterDelay, { |in, out, mixBus, timeBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var del = CombC.ar(sig, 1.0, In.kr(timeBus), 1.5);
        Out.ar(out, XFade2.ar(sig, del, mix * 2 - 1));
    }).add;

    // FX: Master Limiter
    SynthDef(\fx_MasterLimiter, { |in, out=0|
        var sig = In.ar(in, 2);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Braised Meat Base (Monophonic, Subtractive, Wavefolder)
    SynthDef(\zone1_Meat, {
        arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0,
            lpf=800, rq=1, hpf=20, atk=0.5, dec=1.0, sus=1.0, rls=2.0, maillard=0.0;
        var lagFreq = Lag.kr(freq, 0.1);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var osc1 = Saw.ar(lagFreq);
        var osc2 = Pulse.ar(lagFreq * 0.99, 0.5);
        var sig = (osc1 + osc2) * 0.5;
        // Maillard Reaction: Wavefolding saturation
        sig = Fold.ar(sig * (1 + (maillard * 4.0)), -0.8, 0.8);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 2: Tomato Purée Core (Polyphonic, FM, Zest Modulation)
    SynthDef(\zone2_Tomato, {
        arg out=0, freq=261.6, gate=1, vel=0.8, zoneVol=0.3, pan=0.15, mute=0,
            lpf=5000, rq=1, hpf=150, atk=0.1, dec=0.5, sus=0.7, rls=1.0, zest=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Zest adds acidic LFO movement to the FM index
        var modLfo = SinOsc.kr(zest.linexp(0, 1, 0.1, 10)) * zest * 3.0;
        var mod = SinOsc.ar(freq * 2.01) * freq * (1.5 + modLfo);
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Thickening Sauce Texture (Paraphonic, Granular/Noise)
    SynthDef(\zone3_Sauce, {
        arg out=0, freq=130.8, gate=1, vel=0.8, zoneVol=0.2, pan=0, mute=0,
            lpf=10000, rq=1, hpf=100, atk=2.0, dec=1.0, sus=1.0, rls=3.0, density=0.0;
        var lagFreq = Lag.kr(freq, 0.5);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Simmer Density controls trigger rate and noise amount
        var trig = Dust.ar(density.linexp(0, 1, 2, 60));
        var exciter = PinkNoise.ar * Decay.ar(trig, 0.05);
        var body = Resonz.ar(exciter, lagFreq * [1, 1.5, 2.0], 0.1).sum;
        var wash = WhiteNoise.ar * density * 0.1;
        var sig = body + wash;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Spread wide using Balance2
        Out.ar(out, Balance2.ar(sig, sig, pan, env * zoneVol * (1 - mute) * 4.0));
    }).add;

    // ZONE 4: Pasta & Bubbles Detail (Polyphonic, Percussive Noise)
    SynthDef(\zone4_Pasta, {
        arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.15, pan=0, mute=0,
            lpf=18000, rq=1, hpf=1000, atk=0.01, dec=0.2, sus=0.0, rls=0.2, grains=0.0;
        // Pasta grains lengthens the decay to simulate larger bubbles
        var actualDec = dec + (grains * 0.5);
        var actualRls = rls + (grains * 0.5);
        var env = EnvGen.kr(Env.adsr(atk, actualDec, sus, actualRls), gate, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.1);
        // Random pan per note within a narrow field
        var randPan = pan + Rand(-0.3, 0.3);
        Out.ar(out, Pan2.ar(sig, randPan, env * vel * zoneVol * 15.0 * (1 - mute)));
    }).add;

    s.sync;

    // D. INSTANTIATE EFFECTS
    ~verbFx = Synth(\fx_GroupVerb, [\in, ~groupBus, \out, ~verbBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~compFx = Synth(\fx_GroupComp, [\in, ~verbBus, \out, ~masterBus, \threshBus, ~buses.compThresh, \ratioBus, ~buses.compRatio], ~fxGroup, \addToTail);

    ~eqFx = Synth(\fx_MasterEQ, [\in, ~masterBus, \out, ~delayBus, \freqBus, ~buses.eqFreq, \gainBus, ~buses.eqGain], ~masterGroup, \addToTail);
    ~delayFx = Synth(\fx_MasterDelay, [\in, ~delayBus, \out, ~compBus, \mixBus, ~buses.delayMix, \timeBus, ~buses.delayTime], ~masterGroup, \addToTail);
    ~limiterFx = Synth(\fx_MasterLimiter, [\in, ~compBus, \out, 0], ~masterGroup, \addToTail);

    // E. SYNTH STATE & OSC
    ~notes = Array.newClear(128); // Polyphonic tracking (Zones 2 & 4)
    ~z1ActiveNotes = []; // Monophonic tracking (Zone 1)
    ~z3ActiveNotes = []; // Paraphonic tracking (Zone 3)
    ~z1Synth = nil;
    ~z3Synth = nil;

    OSCdef(\globalCC, { |msg|
        var num = msg[1].asInteger;
        var val = msg[2].asFloat;
        var mapped = val / 127.0;

        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { key == \verbDecay } { mapped.linlin(0, 1, 0.1, 5.0) }
                    { key == \compThresh } { mapped.linexp(0, 1, 0.001, 1.0) } // -60dB to 0dB amplitude
                    { key == \compRatio } { mapped.linlin(0, 1, 1.0, 10.0) }
                    { key == \eqFreq } { mapped.linexp(0, 1, 200, 5000) }
                    { key == \eqGain } { mapped.linlin(0, 1, -12.0, 12.0) }
                    { key == \delayTime } { mapped.linexp(0, 1, 0.01, 1.0) }
                    { mapped }; // Default 0-1 for Volumes, Unique FX, Mixes

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, '/ragu/cc');

    OSCdef(\raguOn, { |msg|
        var noteNum = msg[1].asInteger;
        var velRaw = msg[2].asFloat;
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Polyphonic Cleanup
        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        // ZONE 1 (Mono)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~z1ActiveNotes = ~z1ActiveNotes.add(noteNum);
            if(~z1Synth.isNil) {
                ~z1Synth = Synth(\zone1_Meat, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \maillard, ~buses.maillard1.asMap,
                    \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
                ], target: ~synthGroup);
            } {
                ~z1Synth.set(\freq, freq);
            };
        };

        // ZONE 2 (Poly)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Tomato, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \zest, ~buses.zest2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // ZONE 3 (Paraphonic)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~z3ActiveNotes = ~z3ActiveNotes.add(noteNum);
            if(~z3Synth.isNil) {
                ~z3Synth = Synth(\zone3_Sauce, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \density, ~buses.density3.asMap,
                    \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
                ], target: ~synthGroup);
            } {
                ~z3Synth.set(\freq, freq);
            };
        };

        // ZONE 4 (Poly)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Pasta, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \grains, ~buses.grains4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, '/ragu/noteOn');

    OSCdef(\raguOff, { |msg|
        var noteNum = msg[1].asInteger;

        // Poly Cleanup
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };

        // Mono Cleanup (Zone 1)
        ~z1ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z1ActiveNotes.isEmpty) {
            if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        } {
            if(~z1Synth.notNil) { ~z1Synth.set(\freq, ~z1ActiveNotes.last.midicps); };
        };

        // Paraphonic Cleanup (Zone 3)
        ~z3ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z3ActiveNotes.isEmpty) {
            if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };
        } {
            if(~z3Synth.notNil) { ~z3Synth.set(\freq, ~z3ActiveNotes.last.midicps); };
        };
    }, '/ragu/noteOff');

    "Neapolitan Ragù (OSC) Engine Initialized.".postln;
});
)

// Source: design-synth-ragu-OSC.scd [Block 4]
// MODE: design
// THEME: STEP 4: PAGINATED GUI
// KEYWORDS: design, gui, hpf, paginated, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
    ~ui = ();

    ~raguWin = Window("Neapolitan Ragù Synthesizer (OSC)", Rect(100, 100, 460, 800));
    ~raguWin.view.background = Color.fromHexString("#2C1D11"); // Deep rich brown

    ~tabContainer = CompositeView(~raguWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~raguWin, Rect(15, 65, 430, 500));
    ~fxContainer = CompositeView(~raguWin, Rect(15, 575, 430, 200));

    // 1. TAB CONTROLS
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D23B22"), Color.gray(0.3)); // Tomato Red
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["MEAT", "TOMATO", "SAUCE", "PASTA"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // 2. PAGINATED ZONE BUILDER
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.white).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(80, 80, 80)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@5).background_(Color.gray(0.3));

        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#F4A460"));

        extraKnobs.value(box, kSize);
    };

    makeZone.value("BRAISED MEAT BASE", 1, 0, { |box, kSize|
        ~ui[\maillard1] = EZKnob(box, kSize, "Maillard " ++ ~cc[\maillard1], \amp, { |kn| ~buses.maillard1.set(kn.value); ~ccVals[\maillard1] = kn.value; }, ~ccVals[\maillard1]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("TOMATO PURÉE CORE", 2, 1, { |box, kSize|
        ~ui[\zest2] = EZKnob(box, kSize, "Zest " ++ ~cc[\zest2], \amp, { |kn| ~buses.zest2.set(kn.value); ~ccVals[\zest2] = kn.value; }, ~ccVals[\zest2]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("THICKENING SAUCE", 3, 2, { |box, kSize|
        ~ui[\density3] = EZKnob(box, kSize, "Density " ++ ~cc[\density3], \amp, { |kn| ~buses.density3.set(kn.value); ~ccVals[\density3] = kn.value; }, ~ccVals[\density3]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("PASTA & BUBBLES", 4, 3, { |box, kSize|
        ~ui[\grains4] = EZKnob(box, kSize, "Grains " ++ ~cc[\grains4], \amp, { |kn| ~buses.grains4.set(kn.value); ~ccVals[\grains4] = kn.value; }, ~ccVals[\grains4]).setColors(stringColor: Color.red(0.8));
    });

    switchTab.value(0);

    // 3. BOTTOM: GLOBAL FX
    ~fxContainer.background_(Color.gray(0.1, 0.6)).decorator_(FlowLayout(Rect(0,0,430,200), 10@10, 8@8));
    StaticText(~fxContainer, 400@20).string_("POT & MASTER EFFECTS").stringColor_(Color.white).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\verbMix] = EZSlider(~fxContainer, 200@30, "Verb Mix " ++ ~cc[\verbMix], \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 200@30, "Verb Dec " ++ ~cc[\verbDecay], ControlSpec(0.1, 5.0, \exp), { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\compThresh] = EZSlider(~fxContainer, 200@30, "Cmp Thr " ++ ~cc[\compThresh], ControlSpec(0.001, 1.0, \exp), { |sl| ~buses.compThresh.set(sl.value); ~ccVals[\compThresh] = sl.value; }, ~ccVals[\compThresh], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\compRatio] = EZSlider(~fxContainer, 200@30, "Cmp Rat " ++ ~cc[\compRatio], ControlSpec(1.0, 10.0, \lin), { |sl| ~buses.compRatio.set(sl.value); ~ccVals[\compRatio] = sl.value; }, ~ccVals[\compRatio], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\eqFreq] = EZSlider(~fxContainer, 200@30, "EQ Freq " ++ ~cc[\eqFreq], ControlSpec(200, 5000, \exp), { |sl| ~buses.eqFreq.set(sl.value); ~ccVals[\eqFreq] = sl.value; }, ~ccVals[\eqFreq], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\eqGain] = EZSlider(~fxContainer, 200@30, "EQ Gain " ++ ~cc[\eqGain], ControlSpec(-12.0, 12.0, \lin), { |sl| ~buses.eqGain.set(sl.value); ~ccVals[\eqGain] = sl.value; }, ~ccVals[\eqGain], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\delayMix] = EZSlider(~fxContainer, 200@30, "Dly Mix " ++ ~cc[\delayMix], \amp, { |sl| ~buses.delayMix.set(sl.value); ~ccVals[\delayMix] = sl.value; }, ~ccVals[\delayMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\delayTime] = EZSlider(~fxContainer, 200@30, "Dly Time " ++ ~cc[\delayTime], ControlSpec(0.01, 1.0, \exp), { |sl| ~buses.delayTime.set(sl.value); ~ccVals[\delayTime] = sl.value; }, ~ccVals[\delayTime], labelWidth: 80).setColors(stringColor: Color.white);

    ~raguWin.front;

    // 4. DATA POLLING
    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~raguWin.onClose = {
        ~guiRoutine.stop; ~raguWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-ragu-v2-OSC.scd [Block 3]
// MODE: design
// THEME: A. CONTROL BUSES & STATE DICTIONARY
// KEYWORDS: bpf, buses, control, design, dictionary, fold, freeverb2, fx_GroupComp, fx_GroupVerb, fx_MasterDelay, fx_MasterEQ, fx_MasterLimiter, hpf, rlpf, saw, state, zone1_Meat, zone2_Tomato, zone3_Sauce, zone4_Pasta
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Volumes set to provide headroom
        vol1: 0.25, vol2: 0.3, vol3: 0.2, vol4: 0.15,
        pan1: 0.0, pan2: 0.15, pan3: 0.0, pan4: 0.0,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 48,
        min2: 49, max2: 72,
        min3: 36, max3: 96,
        min4: 73, max4: 127,

        // Filter Bracketing
        lpf1: 800, lpf2: 5000, lpf3: 10000, lpf4: 18000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 150, hpf3: 100, hpf4: 1000,

        // ADSR Defaults
        atk1: 0.5, dec1: 1.0, sus1: 1.0, rls1: 2.0,
        atk2: 0.1, dec2: 0.5, sus2: 0.7, rls2: 1.0,
        atk3: 2.0, dec3: 1.0, sus3: 1.0, rls3: 3.0,
        atk4: 0.01, dec4: 0.2, sus4: 0.0, rls4: 0.2,

        // Unique FX Default States
        maillard1: 0.0, zest2: 0.0, density3: 0.0, grains4: 0.0,

        // Global FX Default States (CRITICAL: Mixes at 0.0)
        verbMix: 0.0, verbDecay: 0.5,
        compThresh: 0.25, compRatio: 1.0, // Thresh 0.25 = -12dB, Ratio 1.0 = 1:1
        eqFreq: 1000.0, eqGain: 0.0,
        delayMix: 0.0, delayTime: 0.1
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // B. AUDIO ROUTING GROUPS & BUSES
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~verbBus = Bus.audio(s, 2);
    ~compBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);
    ~eqBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);

    // C. SYNTHDEFS

    // FX: Stew Pot Reverb
    SynthDef(\fx_GroupVerb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        var verb = FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.3);
        Out.ar(out, verb);
    }).add;

    // FX: Slow Cooker Compressor
    SynthDef(\fx_GroupComp, { |in, out, threshBus, ratioBus|
        var sig = In.ar(in, 2);
        var slope = 1.0 / max(1.0, In.kr(ratioBus));
        var comp = Compander.ar(sig, sig, In.kr(threshBus), 1.0, slope, 0.01, 0.1);
        Out.ar(out, comp);
    }).add;

    // FX: Master Mid-Range EQ
    SynthDef(\fx_MasterEQ, { |in, out, freqBus, gainBus|
        var sig = In.ar(in, 2);
        var eq = BPeakEQ.ar(sig, In.kr(freqBus), 1.0, In.kr(gainBus));
        Out.ar(out, eq);
    }).add;

    // FX: Steam Haze Delay
    SynthDef(\fx_MasterDelay, { |in, out, mixBus, timeBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var del = CombC.ar(sig, 1.0, In.kr(timeBus), 1.5);
        Out.ar(out, XFade2.ar(sig, del, mix * 2 - 1));
    }).add;

    // FX: Master Limiter
    SynthDef(\fx_MasterLimiter, { |in, out=0|
        var sig = In.ar(in, 2);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Braised Meat Base (Monophonic, Subtractive, Wavefolder)
    SynthDef(\zone1_Meat, {
        arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0,
            lpf=800, rq=1, hpf=20, atk=0.5, dec=1.0, sus=1.0, rls=2.0, maillard=0.0;
        var lagFreq = Lag.kr(freq, 0.1);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var osc1 = Saw.ar(lagFreq);
        var osc2 = Pulse.ar(lagFreq * 0.99, 0.5);
        var sig = (osc1 + osc2) * 0.5;
        // Maillard Reaction: Wavefolding saturation
        sig = Fold.ar(sig * (1 + (maillard * 4.0)), -0.8, 0.8);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 2: Tomato Purée Core (Polyphonic, FM, Zest Modulation)
    SynthDef(\zone2_Tomato, {
        arg out=0, freq=261.6, gate=1, vel=0.8, zoneVol=0.3, pan=0.15, mute=0,
            lpf=5000, rq=1, hpf=150, atk=0.1, dec=0.5, sus=0.7, rls=1.0, zest=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Zest adds acidic LFO movement to the FM index
        var modLfo = SinOsc.kr(zest.linexp(0, 1, 0.1, 10)) * zest * 3.0;
        var mod = SinOsc.ar(freq * 2.01) * freq * (1.5 + modLfo);
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Thickening Sauce Texture (Paraphonic, Granular/Noise)
    SynthDef(\zone3_Sauce, {
        arg out=0, freq=130.8, gate=1, vel=0.8, zoneVol=0.2, pan=0, mute=0,
            lpf=10000, rq=1, hpf=100, atk=2.0, dec=1.0, sus=1.0, rls=3.0, density=0.0;
        var lagFreq = Lag.kr(freq, 0.5);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Simmer Density controls trigger rate and noise amount
        var trig = Dust.ar(density.linexp(0, 1, 2, 60));
        var exciter = PinkNoise.ar * Decay.ar(trig, 0.05);
        var body = Resonz.ar(exciter, lagFreq * [1, 1.5, 2.0], 0.1).sum;
        var wash = WhiteNoise.ar * density * 0.1;
        var sig = body + wash;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Spread wide using Balance2
        Out.ar(out, Balance2.ar(sig, sig, pan, env * zoneVol * (1 - mute) * 4.0));
    }).add;

    // ZONE 4: Pasta & Bubbles Detail (Polyphonic, Percussive Noise)
    SynthDef(\zone4_Pasta, {
        arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.15, pan=0, mute=0,
            lpf=18000, rq=1, hpf=1000, atk=0.01, dec=0.2, sus=0.0, rls=0.2, grains=0.0;
        // Pasta grains lengthens the decay to simulate larger bubbles
        var actualDec = dec + (grains * 0.5);
        var actualRls = rls + (grains * 0.5);
        var env = EnvGen.kr(Env.adsr(atk, actualDec, sus, actualRls), gate, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.1);
        // Random pan per note within a narrow field
        var randPan = pan + Rand(-0.3, 0.3);
        Out.ar(out, Pan2.ar(sig, randPan, env * vel * zoneVol * 15.0 * (1 - mute)));
    }).add;

    s.sync;

    // D. INSTANTIATE EFFECTS
    ~verbFx = Synth(\fx_GroupVerb, [\in, ~groupBus, \out, ~verbBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~compFx = Synth(\fx_GroupComp, [\in, ~verbBus, \out, ~masterBus, \threshBus, ~buses.compThresh, \ratioBus, ~buses.compRatio], ~fxGroup, \addToTail);

    ~eqFx = Synth(\fx_MasterEQ, [\in, ~masterBus, \out, ~delayBus, \freqBus, ~buses.eqFreq, \gainBus, ~buses.eqGain], ~masterGroup, \addToTail);
    ~delayFx = Synth(\fx_MasterDelay, [\in, ~delayBus, \out, ~compBus, \mixBus, ~buses.delayMix, \timeBus, ~buses.delayTime], ~masterGroup, \addToTail);
    ~limiterFx = Synth(\fx_MasterLimiter, [\in, ~compBus, \out, 0], ~masterGroup, \addToTail);

    // E. SYNTH STATE & OSC
    ~notes = Array.newClear(128); // Polyphonic tracking (Zones 2 & 4)
    ~z1ActiveNotes = []; // Monophonic tracking (Zone 1)
    ~z3ActiveNotes = []; // Paraphonic tracking (Zone 3)
    ~z1Synth = nil;
    ~z3Synth = nil;

    OSCdef(\globalCC, { |msg|
        var num = msg[1].asInteger;
        var val = msg[2].asFloat;
        var mapped = val / 127.0;

        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { key == \verbDecay } { mapped.linlin(0, 1, 0.1, 5.0) }
                    { key == \compThresh } { mapped.linexp(0, 1, 0.001, 1.0) } // -60dB to 0dB amplitude
                    { key == \compRatio } { mapped.linlin(0, 1, 1.0, 10.0) }
                    { key == \eqFreq } { mapped.linexp(0, 1, 200, 5000) }
                    { key == \eqGain } { mapped.linlin(0, 1, -12.0, 12.0) }
                    { key == \delayTime } { mapped.linexp(0, 1, 0.01, 1.0) }
                    { mapped }; // Default 0-1 for Volumes, Unique FX, Mixes

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, '/ragu/cc');

    OSCdef(\raguOn, { |msg|
        var noteNum = msg[1].asInteger;
        var velRaw = msg[2].asFloat;
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Polyphonic Cleanup
        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        // ZONE 1 (Mono)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~z1ActiveNotes = ~z1ActiveNotes.add(noteNum);
            if(~z1Synth.isNil) {
                ~z1Synth = Synth(\zone1_Meat, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \maillard, ~buses.maillard1.asMap,
                    \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
                ], target: ~synthGroup);
            } {
                ~z1Synth.set(\freq, freq);
            };
        };

        // ZONE 2 (Poly)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Tomato, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \zest, ~buses.zest2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // ZONE 3 (Paraphonic)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~z3ActiveNotes = ~z3ActiveNotes.add(noteNum);
            if(~z3Synth.isNil) {
                ~z3Synth = Synth(\zone3_Sauce, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \density, ~buses.density3.asMap,
                    \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
                ], target: ~synthGroup);
            } {
                ~z3Synth.set(\freq, freq);
            };
        };

        // ZONE 4 (Poly)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Pasta, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \grains, ~buses.grains4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, '/ragu/noteOn');

    OSCdef(\raguOff, { |msg|
        var noteNum = msg[1].asInteger;

        // Poly Cleanup
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };

        // Mono Cleanup (Zone 1)
        ~z1ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z1ActiveNotes.isEmpty) {
            if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        } {
            if(~z1Synth.notNil) { ~z1Synth.set(\freq, ~z1ActiveNotes.last.midicps); };
        };

        // Paraphonic Cleanup (Zone 3)
        ~z3ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z3ActiveNotes.isEmpty) {
            if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };
        } {
            if(~z3Synth.notNil) { ~z3Synth.set(\freq, ~z3ActiveNotes.last.midicps); };
        };
    }, '/ragu/noteOff');

    // NEW: Master Panic OSC Listener
    OSCdef(\raguPanic, { |msg|
        // Clear Polyphonic Notes
        if(~notes.notNil) {
            ~notes.do { |arr, i|
                if(arr.notNil) {
                    arr.do(_.set(\gate, 0));
                    ~notes[i] = nil;
                }
            };
        };
        // Clear Monophonic Zone 1
        if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        ~z1ActiveNotes = [];
        // Clear Paraphonic Zone 3
        if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };
        ~z3ActiveNotes = [];

        "OSC: Master Note Off triggered.".postln;
    }, '/ragu/panic');

    "Neapolitan Ragù (OSC) Engine Initialized.".postln;
});
)

// Source: design-synth-ragu-v2-OSC.scd [Block 4]
// MODE: design
// THEME: STEP 4: PAGINATED GUI
// KEYWORDS: design, gui, hpf, paginated, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
    ~ui = ();

    ~raguWin = Window("Neapolitan Ragù Synthesizer (OSC)", Rect(100, 100, 460, 800));
    ~raguWin.view.background = Color.fromHexString("#2C1D11"); // Deep rich brown

    ~tabContainer = CompositeView(~raguWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~raguWin, Rect(15, 65, 430, 500));
    ~fxContainer = CompositeView(~raguWin, Rect(15, 575, 430, 200));

    // 1. TAB CONTROLS
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D23B22"), Color.gray(0.3)); // Tomato Red
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["MEAT", "TOMATO", "SAUCE", "PASTA"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // 2. PAGINATED ZONE BUILDER
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.white).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(80, 80, 80)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@5).background_(Color.gray(0.3));

        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#F4A460"));

        extraKnobs.value(box, kSize);
    };

    makeZone.value("BRAISED MEAT BASE", 1, 0, { |box, kSize|
        ~ui[\maillard1] = EZKnob(box, kSize, "Maillard " ++ ~cc[\maillard1], \amp, { |kn| ~buses.maillard1.set(kn.value); ~ccVals[\maillard1] = kn.value; }, ~ccVals[\maillard1]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("TOMATO PURÉE CORE", 2, 1, { |box, kSize|
        ~ui[\zest2] = EZKnob(box, kSize, "Zest " ++ ~cc[\zest2], \amp, { |kn| ~buses.zest2.set(kn.value); ~ccVals[\zest2] = kn.value; }, ~ccVals[\zest2]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("THICKENING SAUCE", 3, 2, { |box, kSize|
        ~ui[\density3] = EZKnob(box, kSize, "Density " ++ ~cc[\density3], \amp, { |kn| ~buses.density3.set(kn.value); ~ccVals[\density3] = kn.value; }, ~ccVals[\density3]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("PASTA & BUBBLES", 4, 3, { |box, kSize|
        ~ui[\grains4] = EZKnob(box, kSize, "Grains " ++ ~cc[\grains4], \amp, { |kn| ~buses.grains4.set(kn.value); ~ccVals[\grains4] = kn.value; }, ~ccVals[\grains4]).setColors(stringColor: Color.red(0.8));
    });

    switchTab.value(0);

    // 3. BOTTOM: GLOBAL FX
    ~fxContainer.background_(Color.gray(0.1, 0.6)).decorator_(FlowLayout(Rect(0,0,430,200), 10@10, 8@8));

    StaticText(~fxContainer, 280@20).string_("POT & MASTER EFFECTS").stringColor_(Color.white).font_(Font("Arial", 14, true)).align_(\right);

    // NEW: GUI Master Note Off Button
    Button(~fxContainer, 110@20).states_([
        ["PANIC (ALL OFF)", Color.white, Color.red(0.6)]
    ]).action_({
        // Clear Polyphonic
        if(~notes.notNil) {
            ~notes.do { |arr, i|
                if(arr.notNil) {
                    arr.do(_.set(\gate, 0));
                    ~notes[i] = nil;
                }
            };
        };
        // Clear Monophonic
        if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        ~z1ActiveNotes = [];
        // Clear Paraphonic
        if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };
        ~z3ActiveNotes = [];

        "GUI: Master Note Off triggered.".postln;
    });

    ~ui[\verbMix] = EZSlider(~fxContainer, 200@30, "Verb Mix " ++ ~cc[\verbMix], \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 200@30, "Verb Dec " ++ ~cc[\verbDecay], ControlSpec(0.1, 5.0, \exp), { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\compThresh] = EZSlider(~fxContainer, 200@30, "Cmp Thr " ++ ~cc[\compThresh], ControlSpec(0.001, 1.0, \exp), { |sl| ~buses.compThresh.set(sl.value); ~ccVals[\compThresh] = sl.value; }, ~ccVals[\compThresh], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\compRatio] = EZSlider(~fxContainer, 200@30, "Cmp Rat " ++ ~cc[\compRatio], ControlSpec(1.0, 10.0, \lin), { |sl| ~buses.compRatio.set(sl.value); ~ccVals[\compRatio] = sl.value; }, ~ccVals[\compRatio], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\eqFreq] = EZSlider(~fxContainer, 200@30, "EQ Freq " ++ ~cc[\eqFreq], ControlSpec(200, 5000, \exp), { |sl| ~buses.eqFreq.set(sl.value); ~ccVals[\eqFreq] = sl.value; }, ~ccVals[\eqFreq], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\eqGain] = EZSlider(~fxContainer, 200@30, "EQ Gain " ++ ~cc[\eqGain], ControlSpec(-12.0, 12.0, \lin), { |sl| ~buses.eqGain.set(sl.value); ~ccVals[\eqGain] = sl.value; }, ~ccVals[\eqGain], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\delayMix] = EZSlider(~fxContainer, 200@30, "Dly Mix " ++ ~cc[\delayMix], \amp, { |sl| ~buses.delayMix.set(sl.value); ~ccVals[\delayMix] = sl.value; }, ~ccVals[\delayMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\delayTime] = EZSlider(~fxContainer, 200@30, "Dly Time " ++ ~cc[\delayTime], ControlSpec(0.01, 1.0, \exp), { |sl| ~buses.delayTime.set(sl.value); ~ccVals[\delayTime] = sl.value; }, ~ccVals[\delayTime], labelWidth: 80).setColors(stringColor: Color.white);

    ~raguWin.front;

    // 4. DATA POLLING
    ~guiRoutine = Routine({
        loop {
            // Added safety check to prevent KeysValuesDo crash on close
            if(~ui.notNil and: { ~raguWin.isClosed.not }) {
                ~ui.keysValuesDo { |key, widget|
                    var pref;
                    if(widget.notNil) {
                        if(key.asString.contains("range")) {
                            pref = key.asString.last.asString;
                            widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                        } {
                            widget.value = ~ccVals[key];
                        };
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~raguWin.onClose = {
        ~guiRoutine.stop; ~raguWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-ragu-v3-MIDI.scd [Block 3]
// MODE: design
// THEME: A. CONTROL BUSES & STATE DICTIONARY
// KEYWORDS: bpf, buses, control, design, dictionary, freeverb2, fx_Del, fx_Master, fx_Sat, fx_Verb, hpf, rlpf, saw, sinosc, state, z1_Meat, z2_Sizzle, z3_Filter, z3_Osc, z4_Sauce, z5_Crown
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({
    // A. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Volumes (Headroom adjusted)
        vol1: 0.25, vol2: 0.3, vol3: 0.3, vol4: 0.2, vol5: 0.3,
        // Panning (Evenly distributed)
        pan1: 0.0, pan2: 0.1, pan3: -0.2, pan4: 0.2, pan5: 0.0,
        // Mutes
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0, mute5: 0.0,

        // Key Ranges
        min1: 0, max1: 48,
        min2: 49, max2: 127,
        min3: 49, max3: 72,
        min4: 49, max4: 84,
        min5: 72, max5: 127,

        // Filters
        lpf1: 8000, rq1: 1.0, hpf1: 20,
        lpf2: 20000, rq2: 1.0, hpf2: 4000,
        lpf3: 6000, rq3: 1.0, hpf3: 300,
        lpf4: 5000, rq4: 1.0, hpf4: 80,
        lpf5: 20000, rq5: 1.0, hpf5: 5000,

        // ADSR Envelopes
        atk1: 0.1, dec1: 0.3, sus1: 0.7, rls1: 1.0,
        atk2: 0.05, dec2: 0.2, sus2: 0.5, rls2: 0.5,
        atk3: 0.5, dec3: 0.5, sus3: 0.8, rls3: 1.0,
        atk4: 0.4, dec4: 0.5, sus4: 0.7, rls4: 1.5,
        atk5: 0.2, dec5: 0.3, sus5: 0.5, rls5: 2.0,

        // Unique FX
        fx1: 1.0, fx2: 0.0, fx3: 0.0, fx4: 0.0, fx5: 0.0,

        // Global FX (All wet mixes initialized to 0.0 for clean start)
        verbMix: 0.0, verbDec: 0.5, delMix: 0.0, delTime: 0.3, delFB: 0.3, satMix: 0.0, satDrive: 1.0
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // B. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~z3Bus = Bus.audio(s, 2);
    ~groupBus = Bus.audio(s, 2);
    ~satBus = Bus.audio(s, 2);
    ~delBus = Bus.audio(s, 2);
    ~verbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // C. SYNTHDEFS
    // Zone 1: Braised Meat (Monophonic, FM, Maillard Reaction)
    SynthDef(\z1_Meat, { arg out=0, freq=440, gate=1, vel=0.8, vol=0.25, pan=0, mute=0, lpf=8000, rq=1, hpf=20, atk=0.1, dec=0.3, sus=0.7, rls=1.0, fx=1.0;
        var lagFreq = Lag.kr(freq, 0.2);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var mod2 = SinOsc.ar(lagFreq * 3) * fx * 300;
        var mod1 = SinOsc.ar(lagFreq * 0.5 + mod2) * fx * 600;
        var sig = SinOsc.ar(lagFreq + mod1) + Pulse.ar(lagFreq, 0.5, 0.2);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vol * vel * (1 - mute)));
    }).add;

    // Zone 2: Sizzling Fat (Polyphonic, Noise, Dry Herb Crackle)
    SynthDef(\z2_Sizzle, { arg out=0, freq=440, gate=1, vel=0.8, vol=0.3, pan=0.1, mute=0, lpf=20000, rq=1, hpf=4000, atk=0.05, dec=0.2, sus=0.5, rls=0.5, fx=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var crackleSig = Dust.ar(fx * 20 + 2);
        var noise = WhiteNoise.ar * Decay.ar(crackleSig, 0.1) * (fx * 2 + 1);
        var steady = PinkNoise.ar * 0.2;
        var sig = BPF.ar(noise + steady, freq * 2, 0.5);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Balance2.ar(sig, sig, pan, env * vol * vel * (1 - mute)));
    }).add;

    // Zone 3: Tomato Purée (Paraphonic Source)
    SynthDef(\z3_Osc, { arg out=0, freq=440, gate=1;
        var env = EnvGen.kr(Env.asr(0.05, 1.0, 0.1), gate, doneAction: 2);
        var sig = SinOsc.ar(freq) + Pulse.ar(freq, 0.2, 0.3);
        Out.ar(out, Pan2.ar(sig * env, 0));
    }).add;

    // Zone 3: Tomato Purée (Paraphonic Filter, Acidic Zest)
    SynthDef(\z3_Filter, { arg in, out=0, gate=1, vol=0.3, pan=(-0.2), mute=0, lpf=6000, rq=1, hpf=300, atk=0.5, dec=0.5, sus=0.8, rls=1.0, fx=0.0;
        var sig = In.ar(in, 2);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var fRq = (rq - (fx * 0.8)).clip(0.05, 1.0);
        // Fix: Use collect to apply BPFs across the stereo array without collapsing to mono
        var formants = [0.5, 1.0, 2.0].collect({ |m| BPF.ar(sig, lpf * m, fRq) }).sum;
        sig = formants * (1 + (fx * 2));
        sig = HPF.ar(sig, hpf);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * vol * (1 - mute)));
    }).add;

    // Zone 4: Thickening Sauce (Polyphonic, Detuned Saws, Viscosity)
    SynthDef(\z4_Sauce, { arg out=0, freq=440, gate=1, vel=0.8, vol=0.2, pan=0.2, mute=0, lpf=5000, rq=1, hpf=80, atk=0.4, dec=0.5, sus=0.7, rls=1.5, fx=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var lfo = SinOsc.kr(fx * 5 + 0.1) * fx * 0.02;
        var sig = Saw.ar([freq * (1 - lfo), freq, freq * (1 + lfo)]);
        sig = Splay.ar(sig);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf * (1 + (lfo * 5)), rq);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * vol * vel * (1 - mute)));
    }).add;

    // Zone 5: Queen's Crown (Polyphonic, Additive, Truffle Shimmer)
    SynthDef(\z5_Crown, { arg out=0, freq=440, gate=1, vel=0.8, vol=0.3, pan=0, mute=0, lpf=20000, rq=1, hpf=5000, atk=0.2, dec=0.3, sus=0.5, rls=2.0, fx=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = SinOsc.ar(freq * [1, 2, 3, 4]) * [1, 0.5, 0.25, 0.125];
        var trem = SinOsc.kr(fx * 2 + 0.1).range(1 - fx, 1);
        var panMod = SinOsc.kr(fx + 0.05) * fx;
        sig = Mix(sig) * trem;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, (pan + panMod).clip(-1.0, 1.0), env * vol * vel * (1 - mute)));
    }).add;

    // Global FX Chain
    SynthDef(\fx_Sat, { arg in, out=0, mix=0, drive=1;
        var sig = In.ar(in, 2);
        var wet = (sig * drive).tanh / drive.max(1);
        Out.ar(out, XFade2.ar(sig, wet, mix * 2 - 1));
    }).add;

    SynthDef(\fx_Del, { arg in, out=0, mix=0, time=0.3, fb=0.3;
        var sig = In.ar(in, 2);
        var wet = CombC.ar(sig, 2.0, time, fb * 5);
        Out.ar(out, XFade2.ar(sig, wet, mix * 2 - 1));
    }).add;

    SynthDef(\fx_Verb, { arg in, out=0, mix=0, dec=0.5;
        var sig = In.ar(in, 2);
        var wet = FreeVerb2.ar(sig[0], sig[1], 1.0, dec, 0.5);
        Out.ar(out, XFade2.ar(sig, wet, mix * 2 - 1));
    }).add;

    SynthDef(\fx_Master, { arg in, out=0;
        var sig = In.ar(in, 2);
        sig = LPF.ar(sig, 18000);
        sig = Compander.ar(sig, sig, 0.9, 1.0, 0.1, 0.01, 0.1);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // D. INSTANTIATE EFFECTS
    ~satFx = Synth(\fx_Sat, [\in, ~groupBus, \out, ~satBus, \mix, ~buses.satMix.asMap, \drive, ~buses.satDrive.asMap], ~fxGroup, \addToTail);
    ~delFx = Synth(\fx_Del, [\in, ~satBus, \out, ~delBus, \mix, ~buses.delMix.asMap, \time, ~buses.delTime.asMap, \fb, ~buses.delFB.asMap], ~fxGroup, \addToTail);
    ~verbFx = Synth(\fx_Verb, [\in, ~delBus, \out, ~masterBus, \mix, ~buses.verbMix.asMap, \dec, ~buses.verbDec.asMap], ~fxGroup, \addToTail);
    ~masterFx = Synth(\fx_Master, [\in, ~masterBus, \out, 0], ~masterGroup, \addToTail);

    // E. SYNTH STATE & MIDI
    ~notes = Array.fill(6, { Array.newClear(128) });
    ~z1Notes = List.new;
    ~z1Synth = nil;
    ~z3Notes = List.new;
    ~z3FilterSynth = nil;

    MIDIdef.cc(\raguCC, { |val, num|
        var mapped = val / 127.0;
        ~ccVals.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { key == \fx1 } { mapped.linexp(0, 1, 1.0, 10.0) }
                    { key == \satDrive } { mapped.linexp(0, 1, 1.0, 15.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\raguOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Zone 1 (Mono)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~z1Notes.add(noteNum);
            if(~z1Synth.isNil) {
                ~z1Synth = Synth(\z1_Meat, [
                    \freq, freq, \vel, vel, \gate, 1, \out, ~groupBus,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap, \fx, ~buses.fx1.asMap
                ], target: ~synthGroup);
            } {
                ~z1Synth.set(\freq, freq, \vel, vel);
            };
        };

        // Zone 2 (Poly)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            if(~notes[2][noteNum].notNil) { ~notes[2][noteNum].do(_.set(\gate, 0)) };
            ~notes[2][noteNum] = ~notes[2][noteNum].add(Synth(\z2_Sizzle, [
                \freq, freq, \vel, vel, \gate, 1, \out, ~groupBus,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap, \fx, ~buses.fx2.asMap
            ], target: ~synthGroup));
        };

        // Zone 3 (Para)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            if(~z3Notes.isEmpty) {
                ~z3FilterSynth = Synth(\z3_Filter, [
                    \in, ~z3Bus, \out, ~groupBus, \gate, 1,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap, \fx, ~buses.fx3.asMap
                ], target: ~synthGroup, addAction: \addToTail);
            };
            ~z3Notes.add(noteNum);
            if(~notes[3][noteNum].notNil) { ~notes[3][noteNum].do(_.set(\gate, 0)) };
            ~notes[3][noteNum] = ~notes[3][noteNum].add(Synth(\z3_Osc, [
                \freq, freq, \gate, 1, \out, ~z3Bus
            ], target: ~synthGroup));
        };

        // Zone 4 (Poly)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            if(~notes[4][noteNum].notNil) { ~notes[4][noteNum].do(_.set(\gate, 0)) };
            ~notes[4][noteNum] = ~notes[4][noteNum].add(Synth(\z4_Sauce, [
                \freq, freq, \vel, vel, \gate, 1, \out, ~groupBus,
                \vol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap, \fx, ~buses.fx4.asMap
            ], target: ~synthGroup));
        };

        // Zone 5 (Poly)
        if((noteNum >= ~ccVals[\min5]) and: { noteNum <= ~ccVals[\max5] }) {
            if(~notes[5][noteNum].notNil) { ~notes[5][noteNum].do(_.set(\gate, 0)) };
            ~notes[5][noteNum] = ~notes[5][noteNum].add(Synth(\z5_Crown, [
                \freq, freq, \vel, vel, \gate, 1, \out, ~groupBus,
                \vol, ~buses.vol5.asMap, \pan, ~buses.pan5.asMap, \mute, ~buses.mute5.asMap,
                \lpf, ~buses.lpf5.asMap, \rq, ~buses.rq5.asMap, \hpf, ~buses.hpf5.asMap,
                \atk, ~buses.atk5.asMap, \dec, ~buses.dec5.asMap, \sus, ~buses.sus5.asMap, \rls, ~buses.rls5.asMap, \fx, ~buses.fx5.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\raguOff, { |velRaw, noteNum|
        // Zone 1
        ~z1Notes.remove(noteNum);
        if(~z1Notes.isEmpty) {
            if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        } {
            if(~z1Synth.notNil) { ~z1Synth.set(\freq, ~z1Notes.last.midicps); };
        };

        // Zones 2, 4, 5
        [2, 4, 5].do { |idx|
            if(~notes[idx][noteNum].notNil) {
                ~notes[idx][noteNum].do(_.set(\gate, 0));
                ~notes[idx][noteNum] = nil;
            };
        };

        // Zone 3
        ~z3Notes.remove(noteNum);
        if(~notes[3][noteNum].notNil) {
            ~notes[3][noteNum].do(_.set(\gate, 0));
            ~notes[3][noteNum] = nil;
        };
        if(~z3Notes.isEmpty) {
            if(~z3FilterSynth.notNil) { ~z3FilterSynth.set(\gate, 0); ~z3FilterSynth = nil; };
        };
    }, srcID: ~myUid);

    "Neapolitan Ragù Engine Initialized.".postln;
});
)

// Source: design-synth-ragu-v3-MIDI.scd [Block 4]
// MODE: design
// THEME: STEP 4: ADVANCED UI
// KEYWORDS: advanced, design, hpf, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(5);
    var tabButtons = Array.newClear(5);

    if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
    ~ui = ();

    ~raguWin = Window("Neapolitan Ragù Synthesizer", Rect(100, 100, 460, 800));
    ~raguWin.view.background = Color.fromHexString("#2A1E1E");

    ~tabContainer = CompositeView(~raguWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 5@0));
    ~pagesContainer = CompositeView(~raguWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~raguWin, Rect(15, 615, 430, 160));

    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.red(0.8), Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["MEAT", "FAT", "TOMATO", "SAUCE", "CROWN"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 82@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    makeZone = { |name, idx, pageIndex, uniqueName|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey, fxKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol; maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol; pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol; lKey = ("lpf"++pref).asSymbol; rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol; dKey = ("dec"++pref).asSymbol; sKey = ("sus"++pref).asSymbol; rlsKey = ("rls"++pref).asSymbol;
        fxKey = ("fx"++pref).asSymbol;

        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.red(0.8)).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 100).setColors(stringColor: Color.white);

        StaticText(box, 390@8).background_(Color.gray(0.3));

        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.green(0.8));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.green(0.8));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.green(0.8));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.green(0.8));

        ~ui[fxKey] = EZKnob(box, kSize, uniqueName ++ " " ++ ~cc[fxKey], if(idx==1, ControlSpec(1.0, 10.0, \exp), \amp), { |kn| ~buses[fxKey].set(kn.value); ~ccVals[fxKey] = kn.value; }, ~ccVals[fxKey]).setColors(stringColor: Color.yellow);
    };

    makeZone.value("Braised Meat", 1, 0, "Maillard");
    makeZone.value("Sizzling Fat", 2, 1, "Crackle");
    makeZone.value("Tomato Purée", 3, 2, "Acid Zest");
    makeZone.value("Thickening Sauce", 4, 3, "Viscosity");
    makeZone.value("Queen's Crown", 5, 4, "Truffle");

    switchTab.value(0);

    // GLOBAL FX
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 10@10, 10@5));
    StaticText(~fxContainer, 410@20).string_("GLOBAL EFFECTS").stringColor_(Color.red(0.8)).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\verbMix] = EZSlider(~fxContainer, 200@25, "VerbMx "++~cc[\verbMix], \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\verbDec] = EZSlider(~fxContainer, 200@25, "VerbDc "++~cc[\verbDec], \amp, { |sl| ~buses.verbDec.set(sl.value); ~ccVals[\verbDec] = sl.value; }, ~ccVals[\verbDec], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\delMix] = EZSlider(~fxContainer, 200@25, "DelMix "++~cc[\delMix], \amp, { |sl| ~buses.delMix.set(sl.value); ~ccVals[\delMix] = sl.value; }, ~ccVals[\delMix], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\delTime] = EZSlider(~fxContainer, 200@25, "DelTim "++~cc[\delTime], \amp, { |sl| ~buses.delTime.set(sl.value); ~ccVals[\delTime] = sl.value; }, ~ccVals[\delTime], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\delFB] = EZSlider(~fxContainer, 200@25, "DelFB "++~cc[\delFB], \amp, { |sl| ~buses.delFB.set(sl.value); ~ccVals[\delFB] = sl.value; }, ~ccVals[\delFB], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\satMix] = EZSlider(~fxContainer, 200@25, "SatMix "++~cc[\satMix], \amp, { |sl| ~buses.satMix.set(sl.value); ~ccVals[\satMix] = sl.value; }, ~ccVals[\satMix], labelWidth: 70).setColors(stringColor: Color.white);
    ~ui[\satDrive] = EZSlider(~fxContainer, 200@25, "SatDrv "++~cc[\satDrive], ControlSpec(1.0, 15.0, \exp), { |sl| ~buses.satDrive.set(sl.value); ~ccVals[\satDrive] = sl.value; }, ~ccVals[\satDrive], labelWidth: 70).setColors(stringColor: Color.white);

    ~raguWin.front;

    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~raguWin.onClose = {
        ~guiRoutine.stop; ~raguWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-ragu-v3-MIDI.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do { |s| if(s.notNil) { s.set(\gate, 0) } } } });
    ~notes = nil;
};

if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
if(~z3FilterSynth.notNil) { ~z3FilterSynth.set(\gate, 0); ~z3FilterSynth = nil; };

~satFx.free; ~delFx.free; ~verbFx.free; ~masterFx.free;
~buses.keysValuesDo { |key, bus| bus.free };
~groupBus.free; ~z3Bus.free; ~satBus.free; ~delBus.free; ~verbBus.free; ~masterBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

"Neapolitan Ragù cleanup complete.".postln;
)

// Source: design-synth-ragu-v4-MIDI.scd [Block 4]
// MODE: design
// THEME: STEP 4: ADVANCED UI
// KEYWORDS: advanced, design, hpf, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);
    var kSize = 80@95;

    if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
    ~ui = ();

    ~raguWin = Window("Neapolitan Ragù Synthesizer", Rect(100, 100, 460, 850));
    ~raguWin.view.background = Color.fromHexString("#2C1E16"); // Deep warm brown

    ~tabContainer = CompositeView(~raguWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~raguWin, Rect(15, 65, 430, 480));
    ~globalContainer = CompositeView(~raguWin, Rect(15, 555, 430, 270));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D35400"), Color.gray(0.3)); // Orange-red active tab
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["MEAT", "TOMATO", "SAUCE", "PASTA"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        // Header & Mute
        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.fromHexString("#F39C12")).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        // Horizontal Mix & Mapping
        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@8).background_(Color.gray(0.3)); // Divider

        // Filters
        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        // Envelopes
        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.green(0.8));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.green(0.8));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.green(0.8));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.green(0.8));

        StaticText(box, 390@8).background_(Color.gray(0.3)); // Divider

        extraKnobs.value(box);
    };

    // Inject unique UI controls
    makeZone.value("BRAISED MEAT", 1, 0, { |box|
        ~ui[\tenderizer] = EZKnob(box, kSize, "Tender " ++ ~cc[\tenderizer], \amp, { |kn| ~buses.tenderizer.set(kn.value); ~ccVals[\tenderizer] = kn.value; }, ~ccVals[\tenderizer]).setColors(stringColor: Color.fromHexString("#E74C3C"));
    });

    makeZone.value("TOMATO PUREE", 2, 1, { |box|
        ~ui[\sparkle] = EZKnob(box, kSize, "Sparkle " ++ ~cc[\sparkle], \amp, { |kn| ~buses.sparkle.set(kn.value); ~ccVals[\sparkle] = kn.value; }, ~ccVals[\sparkle]).setColors(stringColor: Color.fromHexString("#E74C3C"));
    });

    makeZone.value("THICKENING SAUCE", 3, 2, { |box|
        ~ui[\bubble] = EZKnob(box, kSize, "Bubble " ++ ~cc[\bubble], \amp, { |kn| ~buses.bubble.set(kn.value); ~ccVals[\bubble] = kn.value; }, ~ccVals[\bubble]).setColors(stringColor: Color.fromHexString("#E74C3C"));
    });

    makeZone.value("PASTA BODY", 4, 3, { |box|
        ~ui[\alDente] = EZKnob(box, kSize, "AlDente " ++ ~cc[\alDente], \amp, { |kn| ~buses.alDente.set(kn.value); ~ccVals[\alDente] = kn.value; }, ~ccVals[\alDente]).setColors(stringColor: Color.fromHexString("#E74C3C"));
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~globalContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,270), 15@15, 10@10));
    StaticText(~globalContainer, 400@20).string_("GLOBAL & GROUP EFFECTS").stringColor_(Color.fromHexString("#F39C12")).font_(Font("Arial", 14, true)).align_(\center);

    // Master Vol & Tune
    ~ui[\masterVol] = EZSlider(~globalContainer, 190@35, "M.Vol " ++ ~cc[\masterVol], \amp, { |sl| ~buses.masterVol.set(sl.value); ~ccVals[\masterVol] = sl.value; }, ~ccVals[\masterVol], labelWidth: 60).setColors(stringColor: Color.white);
    ~ui[\masterTune] = EZSlider(~globalContainer, 190@35, "Tune " ++ ~cc[\masterTune], ControlSpec(-12, 12, \lin, 1), { |sl| ~buses.masterTune.set(sl.value); ~ccVals[\masterTune] = sl.value; }, ~ccVals[\masterTune], labelWidth: 60).setColors(stringColor: Color.white);

    // Reducing Pot & Warm Glow
    ~ui[\drive] = EZKnob(~globalContainer, kSize, "Drive " ++ ~cc[\drive], \amp, { |kn| ~buses.drive.set(kn.value); ~ccVals[\drive] = kn.value; }, ~ccVals[\drive]).setColors(stringColor: Color.yellow(0.8));
    ~ui[\tone] = EZKnob(~globalContainer, kSize, "Tone " ++ ~cc[\tone], \amp, { |kn| ~buses.tone.set(kn.value); ~ccVals[\tone] = kn.value; }, ~ccVals[\tone]).setColors(stringColor: Color.yellow(0.8));
    ~ui[\glowMix] = EZKnob(~globalContainer, kSize, "GlwMix " ++ ~cc[\glowMix], \amp, { |kn| ~buses.glowMix.set(kn.value); ~ccVals[\glowMix] = kn.value; }, ~ccVals[\glowMix]).setColors(stringColor: Color.yellow(0.8));
    ~ui[\glowWidth] = EZKnob(~globalContainer, kSize, "GlwWdt " ++ ~cc[\glowWidth], \amp, { |kn| ~buses.glowWidth.set(kn.value); ~ccVals[\glowWidth] = kn.value; }, ~ccVals[\glowWidth]).setColors(stringColor: Color.yellow(0.8));

    // Master Reverb & EQ
    ~ui[\verbMix] = EZKnob(~globalContainer, kSize, "RevMix " ++ ~cc[\verbMix], \amp, { |kn| ~buses.verbMix.set(kn.value); ~ccVals[\verbMix] = kn.value; }, ~ccVals[\verbMix]).setColors(stringColor: Color.cyan(0.8));
    ~ui[\verbDecay] = EZKnob(~globalContainer, kSize, "RevDec " ++ ~cc[\verbDecay], \amp, { |kn| ~buses.verbDecay.set(kn.value); ~ccVals[\verbDecay] = kn.value; }, ~ccVals[\verbDecay]).setColors(stringColor: Color.cyan(0.8));
    ~ui[\hiShelf] = EZKnob(~globalContainer, kSize, "HiShlf " ++ ~cc[\hiShelf], ControlSpec(-12, 12, \lin), { |kn| ~buses.hiShelf.set(kn.value); ~ccVals[\hiShelf] = kn.value; }, ~ccVals[\hiShelf]).setColors(stringColor: Color.cyan(0.8));
    ~ui[\loShelf] = EZKnob(~globalContainer, kSize, "LoShlf " ++ ~cc[\loShelf], ControlSpec(-12, 12, \lin), { |kn| ~buses.loShelf.set(kn.value); ~ccVals[\loShelf] = kn.value; }, ~ccVals[\loShelf]).setColors(stringColor: Color.cyan(0.8));

    ~raguWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~raguWin.onClose = {
        ~guiRoutine.stop; ~raguWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-ragu-v4-MIDI.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } });
    ~notes = nil;
};

~groupFx.free; ~masterFx.free;
~buses.keysValuesDo { |key, bus| bus.free };
~groupBus.free; ~masterBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

if(~sauceBuf.notNil) { ~sauceBuf.free };

"Neapolitan Ragù cleanup complete.".postln;
)

// Source: design-synth-ragu.scd [Block 3]
// MODE: design
// THEME: A. CONTROL BUSES & STATE DICTIONARY
// KEYWORDS: bpf, buses, control, design, dictionary, fold, freeverb2, fx_GroupComp, fx_GroupVerb, fx_MasterDelay, fx_MasterEQ, fx_MasterLimiter, hpf, rlpf, saw, state, zone1_Meat, zone2_Tomato, zone3_Sauce, zone4_Pasta
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Volumes set to provide headroom
        vol1: 0.25, vol2: 0.3, vol3: 0.2, vol4: 0.15,
        pan1: 0.0, pan2: 0.15, pan3: 0.0, pan4: 0.0,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 48,
        min2: 49, max2: 72,
        min3: 36, max3: 96,
        min4: 73, max4: 127,

        // Filter Bracketing
        lpf1: 800, lpf2: 5000, lpf3: 10000, lpf4: 18000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 150, hpf3: 100, hpf4: 1000,

        // ADSR Defaults
        atk1: 0.5, dec1: 1.0, sus1: 1.0, rls1: 2.0,
        atk2: 0.1, dec2: 0.5, sus2: 0.7, rls2: 1.0,
        atk3: 2.0, dec3: 1.0, sus3: 1.0, rls3: 3.0,
        atk4: 0.01, dec4: 0.2, sus4: 0.0, rls4: 0.2,

        // Unique FX Default States
        maillard1: 0.0, zest2: 0.0, density3: 0.0, grains4: 0.0,

        // Global FX Default States (CRITICAL: Mixes at 0.0)
        verbMix: 0.0, verbDecay: 0.5,
        compThresh: 0.25, compRatio: 1.0, // Thresh 0.25 = -12dB, Ratio 1.0 = 1:1
        eqFreq: 1000.0, eqGain: 0.0,
        delayMix: 0.0, delayTime: 0.1
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // B. AUDIO ROUTING GROUPS & BUSES
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~verbBus = Bus.audio(s, 2);
    ~compBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);
    ~eqBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);

    // C. SYNTHDEFS

    // FX: Stew Pot Reverb
    SynthDef(\fx_GroupVerb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        var verb = FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.3);
        Out.ar(out, verb);
    }).add;

    // FX: Slow Cooker Compressor
    SynthDef(\fx_GroupComp, { |in, out, threshBus, ratioBus|
        var sig = In.ar(in, 2);
        var slope = 1.0 / max(1.0, In.kr(ratioBus));
        var comp = Compander.ar(sig, sig, In.kr(threshBus), 1.0, slope, 0.01, 0.1);
        Out.ar(out, comp);
    }).add;

    // FX: Master Mid-Range EQ
    SynthDef(\fx_MasterEQ, { |in, out, freqBus, gainBus|
        var sig = In.ar(in, 2);
        var eq = BPeakEQ.ar(sig, In.kr(freqBus), 1.0, In.kr(gainBus));
        Out.ar(out, eq);
    }).add;

    // FX: Steam Haze Delay
    SynthDef(\fx_MasterDelay, { |in, out, mixBus, timeBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var del = CombC.ar(sig, 1.0, In.kr(timeBus), 1.5);
        Out.ar(out, XFade2.ar(sig, del, mix * 2 - 1));
    }).add;

    // FX: Master Limiter
    SynthDef(\fx_MasterLimiter, { |in, out=0|
        var sig = In.ar(in, 2);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Braised Meat Base (Monophonic, Subtractive, Wavefolder)
    SynthDef(\zone1_Meat, {
        arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0,
            lpf=800, rq=1, hpf=20, atk=0.5, dec=1.0, sus=1.0, rls=2.0, maillard=0.0;
        var lagFreq = Lag.kr(freq, 0.1);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var osc1 = Saw.ar(lagFreq);
        var osc2 = Pulse.ar(lagFreq * 0.99, 0.5);
        var sig = (osc1 + osc2) * 0.5;
        // Maillard Reaction: Wavefolding saturation
        sig = Fold.ar(sig * (1 + (maillard * 4.0)), -0.8, 0.8);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 2: Tomato Purée Core (Polyphonic, FM, Zest Modulation)
    SynthDef(\zone2_Tomato, {
        arg out=0, freq=261.6, gate=1, vel=0.8, zoneVol=0.3, pan=0.15, mute=0,
            lpf=5000, rq=1, hpf=150, atk=0.1, dec=0.5, sus=0.7, rls=1.0, zest=0.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Zest adds acidic LFO movement to the FM index
        var modLfo = SinOsc.kr(zest.linexp(0, 1, 0.1, 10)) * zest * 3.0;
        var mod = SinOsc.ar(freq * 2.01) * freq * (1.5 + modLfo);
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        Out.ar(out, Pan2.ar(sig, pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Thickening Sauce Texture (Paraphonic, Granular/Noise)
    SynthDef(\zone3_Sauce, {
        arg out=0, freq=130.8, gate=1, vel=0.8, zoneVol=0.2, pan=0, mute=0,
            lpf=10000, rq=1, hpf=100, atk=2.0, dec=1.0, sus=1.0, rls=3.0, density=0.0;
        var lagFreq = Lag.kr(freq, 0.5);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Simmer Density controls trigger rate and noise amount
        var trig = Dust.ar(density.linexp(0, 1, 2, 60));
        var exciter = PinkNoise.ar * Decay.ar(trig, 0.05);
        var body = Resonz.ar(exciter, lagFreq * [1, 1.5, 2.0], 0.1).sum;
        var wash = WhiteNoise.ar * density * 0.1;
        var sig = body + wash;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Spread wide using Balance2
        Out.ar(out, Balance2.ar(sig, sig, pan, env * zoneVol * (1 - mute) * 4.0));
    }).add;

    // ZONE 4: Pasta & Bubbles Detail (Polyphonic, Percussive Noise)
    SynthDef(\zone4_Pasta, {
        arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.15, pan=0, mute=0,
            lpf=18000, rq=1, hpf=1000, atk=0.01, dec=0.2, sus=0.0, rls=0.2, grains=0.0;
        // Pasta grains lengthens the decay to simulate larger bubbles
        var actualDec = dec + (grains * 0.5);
        var actualRls = rls + (grains * 0.5);
        var env = EnvGen.kr(Env.adsr(atk, actualDec, sus, actualRls), gate, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.1);
        // Random pan per note within a narrow field
        var randPan = pan + Rand(-0.3, 0.3);
        Out.ar(out, Pan2.ar(sig, randPan, env * vel * zoneVol * 15.0 * (1 - mute)));
    }).add;

    s.sync;

    // D. INSTANTIATE EFFECTS
    ~verbFx = Synth(\fx_GroupVerb, [\in, ~groupBus, \out, ~verbBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~compFx = Synth(\fx_GroupComp, [\in, ~verbBus, \out, ~masterBus, \threshBus, ~buses.compThresh, \ratioBus, ~buses.compRatio], ~fxGroup, \addToTail);

    ~eqFx = Synth(\fx_MasterEQ, [\in, ~masterBus, \out, ~delayBus, \freqBus, ~buses.eqFreq, \gainBus, ~buses.eqGain], ~masterGroup, \addToTail);
    ~delayFx = Synth(\fx_MasterDelay, [\in, ~delayBus, \out, ~compBus, \mixBus, ~buses.delayMix, \timeBus, ~buses.delayTime], ~masterGroup, \addToTail);
    ~limiterFx = Synth(\fx_MasterLimiter, [\in, ~compBus, \out, 0], ~masterGroup, \addToTail);

    // E. SYNTH STATE & MIDI
    ~notes = Array.newClear(128); // Polyphonic tracking (Zones 2 & 4)
    ~z1ActiveNotes = []; // Monophonic tracking (Zone 1)
    ~z3ActiveNotes = []; // Paraphonic tracking (Zone 3)
    ~z1Synth = nil;
    ~z3Synth = nil;

    MIDIdef.cc(\raguCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { key == \verbDecay } { mapped.linlin(0, 1, 0.1, 5.0) }
                    { key == \compThresh } { mapped.linexp(0, 1, 0.001, 1.0) } // -60dB to 0dB amplitude
                    { key == \compRatio } { mapped.linlin(0, 1, 1.0, 10.0) }
                    { key == \eqFreq } { mapped.linexp(0, 1, 200, 5000) }
                    { key == \eqGain } { mapped.linlin(0, 1, -12.0, 12.0) }
                    { key == \delayTime } { mapped.linexp(0, 1, 0.01, 1.0) }
                    { mapped }; // Default 0-1 for Volumes, Unique FX, Mixes

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\raguOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Polyphonic Cleanup
        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        // ZONE 1 (Mono)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~z1ActiveNotes = ~z1ActiveNotes.add(noteNum);
            if(~z1Synth.isNil) {
                ~z1Synth = Synth(\zone1_Meat, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \maillard, ~buses.maillard1.asMap,
                    \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
                ], target: ~synthGroup);
            } {
                ~z1Synth.set(\freq, freq);
            };
        };

        // ZONE 2 (Poly)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Tomato, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \zest, ~buses.zest2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // ZONE 3 (Paraphonic)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~z3ActiveNotes = ~z3ActiveNotes.add(noteNum);
            if(~z3Synth.isNil) {
                ~z3Synth = Synth(\zone3_Sauce, [
                    \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \density, ~buses.density3.asMap,
                    \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
                ], target: ~synthGroup);
            } {
                ~z3Synth.set(\freq, freq);
            };
        };

        // ZONE 4 (Poly)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Pasta, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \grains, ~buses.grains4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\raguOff, { |vel, noteNum|
        // Poly Cleanup
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };

        // Mono Cleanup (Zone 1)
        ~z1ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z1ActiveNotes.isEmpty) {
            if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
        } {
            if(~z1Synth.notNil) { ~z1Synth.set(\freq, ~z1ActiveNotes.last.midicps); };
        };

        // Paraphonic Cleanup (Zone 3)
        ~z3ActiveNotes.removeAllSuchThat({ |n| n == noteNum });
        if(~z3ActiveNotes.isEmpty) {
            if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };
        } {
            if(~z3Synth.notNil) { ~z3Synth.set(\freq, ~z3ActiveNotes.last.midicps); };
        };
    }, srcID: ~myUid);

    "Neapolitan Ragù Engine Initialized.".postln;
});
)

// Source: design-synth-ragu.scd [Block 4]
// MODE: design
// THEME: STEP 4: PAGINATED GUI
// KEYWORDS: design, gui, hpf, paginated, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
    ~ui = ();

    ~raguWin = Window("Neapolitan Ragù Synthesizer", Rect(100, 100, 460, 800));
    ~raguWin.view.background = Color.fromHexString("#2C1D11"); // Deep rich brown

    ~tabContainer = CompositeView(~raguWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~raguWin, Rect(15, 65, 430, 500));
    ~fxContainer = CompositeView(~raguWin, Rect(15, 575, 430, 200));

    // 1. TAB CONTROLS
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D23B22"), Color.gray(0.3)); // Tomato Red
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["MEAT", "TOMATO", "SAUCE", "PASTA"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // 2. PAGINATED ZONE BUILDER
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.white).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(80, 80, 80)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 390@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 100).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 390@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 80).setColors(stringColor: Color.white);

        StaticText(box, 390@5).background_(Color.gray(0.3));

        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#F4A460"));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#F4A460"));

        extraKnobs.value(box, kSize);
    };

    makeZone.value("BRAISED MEAT BASE", 1, 0, { |box, kSize|
        ~ui[\maillard1] = EZKnob(box, kSize, "Maillard " ++ ~cc[\maillard1], \amp, { |kn| ~buses.maillard1.set(kn.value); ~ccVals[\maillard1] = kn.value; }, ~ccVals[\maillard1]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("TOMATO PURÉE CORE", 2, 1, { |box, kSize|
        ~ui[\zest2] = EZKnob(box, kSize, "Zest " ++ ~cc[\zest2], \amp, { |kn| ~buses.zest2.set(kn.value); ~ccVals[\zest2] = kn.value; }, ~ccVals[\zest2]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("THICKENING SAUCE", 3, 2, { |box, kSize|
        ~ui[\density3] = EZKnob(box, kSize, "Density " ++ ~cc[\density3], \amp, { |kn| ~buses.density3.set(kn.value); ~ccVals[\density3] = kn.value; }, ~ccVals[\density3]).setColors(stringColor: Color.red(0.8));
    });

    makeZone.value("PASTA & BUBBLES", 4, 3, { |box, kSize|
        ~ui[\grains4] = EZKnob(box, kSize, "Grains " ++ ~cc[\grains4], \amp, { |kn| ~buses.grains4.set(kn.value); ~ccVals[\grains4] = kn.value; }, ~ccVals[\grains4]).setColors(stringColor: Color.red(0.8));
    });

    switchTab.value(0);

    // 3. BOTTOM: GLOBAL FX
    ~fxContainer.background_(Color.gray(0.1, 0.6)).decorator_(FlowLayout(Rect(0,0,430,200), 10@10, 8@8));
    StaticText(~fxContainer, 400@20).string_("POT & MASTER EFFECTS").stringColor_(Color.white).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\verbMix] = EZSlider(~fxContainer, 200@30, "Verb Mix " ++ ~cc[\verbMix], \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 200@30, "Verb Dec " ++ ~cc[\verbDecay], ControlSpec(0.1, 5.0, \exp), { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\compThresh] = EZSlider(~fxContainer, 200@30, "Cmp Thr " ++ ~cc[\compThresh], ControlSpec(0.001, 1.0, \exp), { |sl| ~buses.compThresh.set(sl.value); ~ccVals[\compThresh] = sl.value; }, ~ccVals[\compThresh], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\compRatio] = EZSlider(~fxContainer, 200@30, "Cmp Rat " ++ ~cc[\compRatio], ControlSpec(1.0, 10.0, \lin), { |sl| ~buses.compRatio.set(sl.value); ~ccVals[\compRatio] = sl.value; }, ~ccVals[\compRatio], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\eqFreq] = EZSlider(~fxContainer, 200@30, "EQ Freq " ++ ~cc[\eqFreq], ControlSpec(200, 5000, \exp), { |sl| ~buses.eqFreq.set(sl.value); ~ccVals[\eqFreq] = sl.value; }, ~ccVals[\eqFreq], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\eqGain] = EZSlider(~fxContainer, 200@30, "EQ Gain " ++ ~cc[\eqGain], ControlSpec(-12.0, 12.0, \lin), { |sl| ~buses.eqGain.set(sl.value); ~ccVals[\eqGain] = sl.value; }, ~ccVals[\eqGain], labelWidth: 80).setColors(stringColor: Color.white);

    ~ui[\delayMix] = EZSlider(~fxContainer, 200@30, "Dly Mix " ++ ~cc[\delayMix], \amp, { |sl| ~buses.delayMix.set(sl.value); ~ccVals[\delayMix] = sl.value; }, ~ccVals[\delayMix], labelWidth: 80).setColors(stringColor: Color.white);
    ~ui[\delayTime] = EZSlider(~fxContainer, 200@30, "Dly Time " ++ ~cc[\delayTime], ControlSpec(0.01, 1.0, \exp), { |sl| ~buses.delayTime.set(sl.value); ~ccVals[\delayTime] = sl.value; }, ~ccVals[\delayTime], labelWidth: 80).setColors(stringColor: Color.white);

    ~raguWin.front;

    // 4. DATA POLLING
    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~raguWin.onClose = {
        ~guiRoutine.stop; ~raguWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-ragu.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~raguWin.notNil and: { ~raguWin.isClosed.not }) { ~raguWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } });
    ~notes = nil;
};

if(~z1Synth.notNil) { ~z1Synth.set(\gate, 0); ~z1Synth = nil; };
if(~z3Synth.notNil) { ~z3Synth.set(\gate, 0); ~z3Synth = nil; };

~verbFx.free; ~compFx.free; ~eqFx.free; ~delayFx.free; ~limiterFx.free;

~buses.keysValuesDo { |key, bus| bus.free };
~groupBus.free; ~verbBus.free; ~compBus.free; ~masterBus.free; ~eqBus.free; ~delayBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

"Neapolitan Ragù cleanup complete.".postln;
)

// Source: design-synth-sursock-MIDI.scd [Block 3]
// MODE: design
// THEME: A. INITIAL STATES DICTIONARY
// KEYWORDS: combl, design, dictionary, freeverb2, fx_Ancient, fx_Celestial, fx_Master, hpf, initial, rlpf, saw, sinosc, states, z1_Sol, z2_Luna, z3_Mars, z4_Merc, z5_Jup, z6_Juno, z7_Saturn
(
s.options.memSize = 131072;
s.boot;

s.waitForBoot({
    var i;

    // A. INITIAL STATES DICTIONARY
    ~ccVals = (
        // Volumes (Conservative for headroom)
        vol1: 0.3, vol2: 0.35, vol3: 0.25, vol4: 0.3, vol5: 0.2, vol6: 0.28, vol7: 0.25,
        // Panning (Distributed)
        pan1: 0.0, pan2: -0.4, pan3: 0.4, pan4: -0.2, pan5: 0.0, pan6: 0.2, pan7: 0.0,
        // Mutes (Off)
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0, mute5: 0.0, mute6: 0.0, mute7: 0.0,
        // Ranges
        min1: 0, min2: 0, min3: 0, min4: 0, min5: 0, min6: 0, min7: 0,
        max1: 127, max2: 127, max3: 127, max4: 127, max5: 127, max6: 127, max7: 127,
        // Filters
        lpf1: 12000, lpf2: 8000, lpf3: 5000, lpf4: 7000, lpf5: 10000, lpf6: 9000, lpf7: 5000,
        rq1: 0.2, rq2: 0.1, rq3: 0.5, rq4: 0.3, rq5: 0.3, rq6: 0.1, rq7: 0.4,
        hpf1: 80, hpf2: 200, hpf3: 150, hpf4: 300, hpf5: 60, hpf6: 100, hpf7: 40,
        // Envelopes
        atk1: 0.05, dec1: 0.4, sus1: 0.7, rls1: 0.5,
        atk2: 0.1, dec2: 0.8, sus2: 0.5, rls2: 1.0,
        atk3: 0.01, dec3: 0.1, sus3: 0.0, rls3: 0.2,
        atk4: 0.02, dec4: 0.3, sus4: 0.6, rls4: 0.4,
        atk5: 0.15, dec5: 0.6, sus5: 0.8, rls5: 0.8,
        atk6: 0.2, dec6: 1.0, sus6: 0.7, rls6: 1.2,
        atk7: 0.4, dec7: 2.0, sus7: 0.9, rls7: 3.0,
        // Unique FX (All 0.0)
        fxSol: 0.0, fxLuna: 0.0, fxMars: 0.0, fxMerc: 0.0, fxJup: 0.0, fxJuno: 0.0, fxSat: 0.0,
        // Group & Master FX (All wet mixes 0.0)
        celDelMix: 0.0, celDelTime: 0.33, celDelFb: 0.4,
        celVerbMix: 0.0, celVerbDec: 0.6,
        ancChoMix: 0.0, ancVerbMix: 0.0, ancVerbDec: 0.5,
        masterLpf: 18000, masterLim: 0.95, tapeDrive: 0.0
    );

    // B. CONTROL BUSES
    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~celestialBus = Bus.audio(s, 2);
    ~ancientBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS
    // Zone 1: Sol (FM - Bright/Bell)
    SynthDef(\z1_Sol, { arg out, freq=440, gate=1, vol=0.3, pan=0, mute=0, lpf=12000, rq=0.2, hpf=80, atk=0.05, dec=0.4, sus=0.7, rls=0.5, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var modIdx = 1 + (uniqueFx * 4);
        var modRatio = 1 + uniqueFx;
        var mod = SinOsc.ar(freq * modRatio) * freq * modIdx;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 2: Luna (Granular/Ethereal)
    SynthDef(\z2_Luna, { arg out, freq=440, gate=1, vol=0.35, pan=0, mute=0, lpf=8000, rq=0.1, hpf=200, atk=0.1, dec=0.8, sus=0.5, rls=1.0, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var trig = Dust.ar(15 + (uniqueFx * 30));
        var drift = LFNoise2.kr(2) * uniqueFx * 0.1;
        var sig = GrainSin.ar(1, trig, 0.08, freq * (1 + drift), 0);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 3: Mars (Plucked/Metallic impact)
    SynthDef(\z3_Mars, { arg out, freq=440, gate=1, vol=0.25, pan=0, mute=0, lpf=5000, rq=0.5, hpf=150, atk=0.01, dec=0.1, sus=0, rls=0.2, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05));
        var sig = CombL.ar(exc, 0.05, freq.reciprocal, rls);
        sig = (sig * (1 + (uniqueFx * 4))).tanh; // Impact Grit
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 4: Mercury (Wavetable/Complex Jitter)
    SynthDef(\z4_Merc, { arg out, freq=440, gate=1, vol=0.3, pan=0, mute=0, lpf=7000, rq=0.3, hpf=300, atk=0.02, dec=0.3, sus=0.6, rls=0.4, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var jitter = LFNoise0.kr(12) * uniqueFx * 0.05;
        var sig = Pulse.ar(freq * (1 + jitter), 0.5 + (uniqueFx * 0.3)) + Saw.ar(freq * 1.01);
        sig = sig * (1 - (LFNoise1.kr(20) * uniqueFx * 0.5)); // Amp jitter
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.5));
    }).add;

    // Zone 5: Jupiter (Supersaw Cosmic)
    SynthDef(\z5_Jup, { arg out, freq=440, gate=1, vol=0.2, pan=0, mute=0, lpf=10000, rq=0.3, hpf=60, atk=0.15, dec=0.6, sus=0.8, rls=0.8, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var detune = 0.01 + (uniqueFx * 0.03);
        var sig = Splay.ar(Saw.ar(freq * [1 - detune, 1, 1 + detune]));
        var orbitPan = pan + (SinOsc.kr(0.2) * uniqueFx);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Balance2.ar(sig[0], sig[1], orbitPan, env * vol * (1 - mute)));
    }).add;

    // Zone 6: Juno (Phase Mod Pad)
    SynthDef(\z6_Juno, { arg out, freq=440, gate=1, vol=0.28, pan=0, mute=0, lpf=9000, rq=0.1, hpf=100, atk=0.2, dec=1.0, sus=0.7, rls=1.2, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var shimmer = SinOsc.kr(0.5) * uniqueFx;
        var mod = SinOsc.ar(freq * 2.01) * (1 + shimmer);
        var sig = SinOsc.ar(freq + (mod * 300));
        var dynamicLpf = lpf * (1 + (shimmer * 0.5));
        sig = RLPF.ar(HPF.ar(sig, hpf), dynamicLpf.clip(20, 20000), 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 7: Saturn (Monophonic Deep FM)
    SynthDef(\z7_Saturn, { arg out, freq=110, gate=1, vol=0.25, pan=0, mute=0, lpf=5000, rq=0.4, hpf=40, atk=0.4, dec=2.0, sus=0.9, rls=3.0, uniqueFx=0;
        var lagFreq = Lag.kr(freq, 0.2);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var timeShift = SinOsc.kr(0.02) * uniqueFx;
        var mod = SinOsc.ar(lagFreq * (2 + timeShift)) * lagFreq * (1 + uniqueFx);
        var sig = SinOsc.ar(lagFreq * 0.5) + SinOsc.ar(lagFreq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.5));
    }).add;

    // FX Synths
    SynthDef(\fx_Celestial, { arg in, out, delMix, delTime, delFb, verbMix, verbDec;
        var sig = In.ar(in, 2);
        var delay = CombC.ar(sig, 2.0, delTime, delFb * 5);
        sig = (sig * (1 - delMix)) + (delay * delMix);
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, verbDec, 0.8);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_Ancient, { arg in, out, choMix, verbMix, verbDec;
        var sig = In.ar(in, 2);
        var chorus = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.5).range(0.01, 0.02));
        sig = (sig * (1 - choMix)) + (chorus * choMix);
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, verbDec, 0.2); // Damped, ancient verb
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_Master, { arg in, out, lpf, lim, drive;
        var sig = In.ar(in, 2);
        sig = LPF.ar(sig, lpf);
        sig = (sig * (1 + (drive * 5))).tanh / (1 + (drive * 2));
        sig = Limiter.ar(sig, lim, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~celestialFx = Synth(\fx_Celestial, [
        \in, ~celestialBus, \out, ~masterBus,
        \delMix, ~buses.celDelMix, \delTime, ~buses.celDelTime, \delFb, ~buses.celDelFb,
        \verbMix, ~buses.celVerbMix, \verbDec, ~buses.celVerbDec
    ], ~fxGroup, \addToTail);

    ~ancientFx = Synth(\fx_Ancient, [
        \in, ~ancientBus, \out, ~masterBus,
        \choMix, ~buses.ancChoMix, \verbMix, ~buses.ancVerbMix, \verbDec, ~buses.ancVerbDec
    ], ~fxGroup, \addToTail);

    ~masterFx = Synth(\fx_Master, [
        \in, ~masterBus, \out, 0,
        \lpf, ~buses.masterLpf, \lim, ~buses.masterLim, \drive, ~buses.tapeDrive
    ], ~masterGroup, \addToTail);

    // F. SYNTH STATE & MIDI
    ~notes = Array.fill(6, { Array.newClear(128) }); // Polyphonic zones 1-6
    ~saturnSynth = nil;
    ~saturnNote = nil;

    MIDIdef.cc(\sursockCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { kStr.contains("Time") } { mapped.linexp(0, 1, 0.01, 2.0) }
                    { kStr.contains("masterLim") } { mapped.linlin(0, 1, 0.5, 1.0) }
                    { mapped }; // Default 0-1 for Volumes, FX mixes, Drive, etc.

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\sursockOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        // Zone 1: Sol (Ancient Bus)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[0][noteNum] = ~notes[0][noteNum].add(Synth(\z1_Sol, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxSol.asMap,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        // Zone 2: Luna (Celestial Bus)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[1][noteNum] = ~notes[1][noteNum].add(Synth(\z2_Luna, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxLuna.asMap,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // Zone 3: Mars (Ancient Bus)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[2][noteNum] = ~notes[2][noteNum].add(Synth(\z3_Mars, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxMars.asMap,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        // Zone 4: Mercury (Celestial Bus)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[3][noteNum] = ~notes[3][noteNum].add(Synth(\z4_Merc, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxMerc.asMap,
                \vol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };

        // Zone 5: Jupiter (Ancient Bus)
        if((noteNum >= ~ccVals[\min5]) and: { noteNum <= ~ccVals[\max5] }) {
            ~notes[4][noteNum] = ~notes[4][noteNum].add(Synth(\z5_Jup, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxJup.asMap,
                \vol, ~buses.vol5.asMap, \pan, ~buses.pan5.asMap, \mute, ~buses.mute5.asMap,
                \lpf, ~buses.lpf5.asMap, \rq, ~buses.rq5.asMap, \hpf, ~buses.hpf5.asMap,
                \atk, ~buses.atk5.asMap, \dec, ~buses.dec5.asMap, \sus, ~buses.sus5.asMap, \rls, ~buses.rls5.asMap
            ], target: ~synthGroup));
        };

        // Zone 6: Juno (Celestial Bus)
        if((noteNum >= ~ccVals[\min6]) and: { noteNum <= ~ccVals[\max6] }) {
            ~notes[5][noteNum] = ~notes[5][noteNum].add(Synth(\z6_Juno, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxJuno.asMap,
                \vol, ~buses.vol6.asMap, \pan, ~buses.pan6.asMap, \mute, ~buses.mute6.asMap,
                \lpf, ~buses.lpf6.asMap, \rq, ~buses.rq6.asMap, \hpf, ~buses.hpf6.asMap,
                \atk, ~buses.atk6.asMap, \dec, ~buses.dec6.asMap, \sus, ~buses.sus6.asMap, \rls, ~buses.rls6.asMap
            ], target: ~synthGroup));
        };

        // Zone 7: Saturn (Monophonic, Ancient Bus)
        if((noteNum >= ~ccVals[\min7]) and: { noteNum <= ~ccVals[\max7] }) {
            if(~saturnSynth.isNil) {
                ~saturnSynth = Synth(\z7_Saturn, [
                    \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxSat.asMap,
                    \vol, ~buses.vol7.asMap, \pan, ~buses.pan7.asMap, \mute, ~buses.mute7.asMap,
                    \lpf, ~buses.lpf7.asMap, \rq, ~buses.rq7.asMap, \hpf, ~buses.hpf7.asMap,
                    \atk, ~buses.atk7.asMap, \dec, ~buses.dec7.asMap, \sus, ~buses.sus7.asMap, \rls, ~buses.rls7.asMap
                ], target: ~synthGroup);
            } {
                ~saturnSynth.set(\freq, freq, \gate, 1);
            };
            ~saturnNote = noteNum;
        };

    }, srcID: ~myUid);

    MIDIdef.noteOff(\sursockOff, { |vel, noteNum|
        // Polyphonic Zones
        ~notes.do { |zoneArray|
            if(zoneArray[noteNum].notNil) {
                zoneArray[noteNum].do(_.set(\gate, 0));
                zoneArray[noteNum] = nil;
            };
        };
        // Monophonic Saturn
        if(~saturnNote == noteNum) {
            if(~saturnSynth.notNil) {
                ~saturnSynth.set(\gate, 0);
                ~saturnSynth = nil;
            };
        };
    }, srcID: ~myUid);

    "Sursock Bronze V1.0 Engine Initialized.".postln;
});
)

// Source: design-synth-sursock-MIDI.scd [Block 4]
// MODE: design
// THEME: STEP 4: ADVANCED UI
// KEYWORDS: advanced, design, hpf, limiter, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(7);
    var tabButtons = Array.newClear(7);
    var zoneNames = ["Sol", "Luna", "Mars", "Mercury", "Jupiter", "Juno", "Saturn"];
    var uniqueFxNames = ["Radiance Spread", "Grain Drift", "Impact Grit", "Prophecy Jitter", "Planetary Orbit", "Veil Shimmer", "Temporal Shift"];
    var uniqueFxKeys = [\fxSol, \fxLuna, \fxMars, \fxMerc, \fxJup, \fxJuno, \fxSat];

    if(~surWin.notNil and: { ~surWin.isClosed.not }) { ~surWin.close };
    ~ui = ();

    // FIX 1: Increased window height from 800 to 860 to prevent clipping
    ~surWin = Window("The Sursock Bronze Control", Rect(100, 100, 680, 860));
    ~surWin.view.background = Color.fromHexString("#2C241B"); // Bronze-ish dark

    ~tabContainer = CompositeView(~surWin, Rect(15, 15, 650, 40)).decorator_(FlowLayout(Rect(0,0,650,40), 0@0, 5@0));
    ~pagesContainer = CompositeView(~surWin, Rect(15, 65, 650, 540));
    // FIX 2: Increased FX container height from 170 to 220
    ~fxContainer = CompositeView(~surWin, Rect(15, 615, 650, 220));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D4AF37"), Color.gray(0.3)); // Gold active
            b.states_([[zoneNames[i], textColor, bgColor]]);
        };
    };

    zoneNames.do { |name, i|
        tabButtons[i] = Button(~tabContainer, 88@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, fxName, fxKey|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 15@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        // Header & Mute
        StaticText(box, 450@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 18, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        // Horizontal Mix & Mapping
        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 600@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 120).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 600@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 120).setColors(stringColor: Color.white);

        StaticText(box, 600@8).background_(Color.gray(0.3)); // Divider

        // Filters
        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        // Envelopes
        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.green(0.8));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.green(0.8));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.green(0.8));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.green(0.8));

        // Unique FX
        StaticText(box, 600@8).background_(Color.gray(0.3)); // Divider
        ~ui[fxKey] = EZSlider(box, 600@40, fxName ++ " (" ++ ~cc[fxKey] ++ ")", \amp, { |sl| ~buses[fxKey].set(sl.value); ~ccVals[fxKey] = sl.value; }, ~ccVals[fxKey], labelWidth: 180).setColors(stringColor: Color.fromHexString("#D4AF37"));
    };

    7.do { |i| makeZone.value(zoneNames[i], i+1, i, uniqueFxNames[i], uniqueFxKeys[i]); };
    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    // FIX 3: Container uses the new 220 height in its internal layout bounds
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,650,220), 15@10, 10@10));
    StaticText(~fxContainer, 620@20).string_("CELESTIAL & ANCIENT GROUP FX").stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\celDelMix] = EZSlider(~fxContainer, 300@25, "Cel Delay (CC" ++ ~cc[\celDelMix] ++ ")", \amp, { |sl| ~buses.celDelMix.set(sl.value); ~ccVals[\celDelMix] = sl.value; }, ~ccVals[\celDelMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\celVerbMix] = EZSlider(~fxContainer, 300@25, "Cel Verb (CC" ++ ~cc[\celVerbMix] ++ ")", \amp, { |sl| ~buses.celVerbMix.set(sl.value); ~ccVals[\celVerbMix] = sl.value; }, ~ccVals[\celVerbMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\ancChoMix] = EZSlider(~fxContainer, 300@25, "Anc Chorus (CC" ++ ~cc[\ancChoMix] ++ ")", \amp, { |sl| ~buses.ancChoMix.set(sl.value); ~ccVals[\ancChoMix] = sl.value; }, ~ccVals[\ancChoMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\ancVerbMix] = EZSlider(~fxContainer, 300@25, "Anc Verb (CC" ++ ~cc[\ancVerbMix] ++ ")", \amp, { |sl| ~buses.ancVerbMix.set(sl.value); ~ccVals[\ancVerbMix] = sl.value; }, ~ccVals[\ancVerbMix], labelWidth: 120).setColors(stringColor: Color.white);

    StaticText(~fxContainer, 620@20).string_("MASTER FX").stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 14, true)).align_(\center);

    // FIX 4: Widened Master knobs slightly to prevent label text from overlapping on certain OS fonts
    ~ui[\masterLpf] = EZKnob(~fxContainer, 160@40, "Master LPF " ++ ~cc[\masterLpf], ControlSpec(20, 20000, \exp), { |kn| ~buses.masterLpf.set(kn.value); ~ccVals[\masterLpf] = kn.value; }, ~ccVals[\masterLpf], layout: \horz).setColors(stringColor: Color.white);
    ~ui[\masterLim] = EZKnob(~fxContainer, 160@40, "Limiter " ++ ~cc[\masterLim], ControlSpec(0.5, 1.0, \lin), { |kn| ~buses.masterLim.set(kn.value); ~ccVals[\masterLim] = kn.value; }, ~ccVals[\masterLim], layout: \horz).setColors(stringColor: Color.white);
    ~ui[\tapeDrive] = EZKnob(~fxContainer, 160@40, "Tape Drive " ++ ~cc[\tapeDrive], \amp, { |kn| ~buses.tapeDrive.set(kn.value); ~ccVals[\tapeDrive] = kn.value; }, ~ccVals[\tapeDrive], layout: \horz).setColors(stringColor: Color.white);

    ~surWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            ~ui.keysValuesDo { |key, widget|
                var pref;
                if(widget.notNil) {
                    if(key.asString.contains("range")) {
                        pref = key.asString.last.asString;
                        widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                    } {
                        widget.value = ~ccVals[key];
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~surWin.onClose = {
        ~guiRoutine.stop; ~surWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: design-synth-sursock-MIDI.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~surWin.notNil and: { ~surWin.isClosed.not }) { ~surWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do { |zoneArray|
        if(zoneArray.notNil) {
            zoneArray.do { |synths|
                if(synths.notNil) { synths.do(_.set(\gate, 0)) };
            };
        };
    };
    ~notes = nil;
};

if(~saturnSynth.notNil) { ~saturnSynth.set(\gate, 0); ~saturnSynth = nil; };

~celestialFx.free; ~ancientFx.free; ~masterFx.free;
~buses.keysValuesDo { |key, bus| bus.free };
~celestialBus.free; ~ancientBus.free; ~masterBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

"Sursock Bronze cleanup complete.".postln;
)

// Source: design-synth-sursock-OSC.scd [Block 3]
// MODE: design
// THEME: A. INITIAL STATES DICTIONARY
// KEYWORDS: combl, design, dictionary, freeverb2, fx_Ancient, fx_Celestial, fx_Master, hpf, initial, rlpf, saw, sinosc, states, z1_Sol, z2_Luna, z3_Mars, z4_Merc, z5_Jup, z6_Juno, z7_Saturn
(
s.options.memSize = 131072;
s.boot;

s.waitForBoot({
    var i;

    // A. INITIAL STATES DICTIONARY
    ~ccVals = (
        // Volumes (Conservative for headroom)
        vol1: 0.3, vol2: 0.35, vol3: 0.25, vol4: 0.3, vol5: 0.2, vol6: 0.28, vol7: 0.25,
        // Panning (Distributed)
        pan1: 0.0, pan2: -0.4, pan3: 0.4, pan4: -0.2, pan5: 0.0, pan6: 0.2, pan7: 0.0,
        // Mutes (Off)
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0, mute5: 0.0, mute6: 0.0, mute7: 0.0,
        // Ranges
        min1: 0, min2: 0, min3: 0, min4: 0, min5: 0, min6: 0, min7: 0,
        max1: 127, max2: 127, max3: 127, max4: 127, max5: 127, max6: 127, max7: 127,
        // Filters
        lpf1: 12000, lpf2: 8000, lpf3: 5000, lpf4: 7000, lpf5: 10000, lpf6: 9000, lpf7: 5000,
        rq1: 0.2, rq2: 0.1, rq3: 0.5, rq4: 0.3, rq5: 0.3, rq6: 0.1, rq7: 0.4,
        hpf1: 80, hpf2: 200, hpf3: 150, hpf4: 300, hpf5: 60, hpf6: 100, hpf7: 40,
        // Envelopes
        atk1: 0.05, dec1: 0.4, sus1: 0.7, rls1: 0.5,
        atk2: 0.1, dec2: 0.8, sus2: 0.5, rls2: 1.0,
        atk3: 0.01, dec3: 0.1, sus3: 0.0, rls3: 0.2,
        atk4: 0.02, dec4: 0.3, sus4: 0.6, rls4: 0.4,
        atk5: 0.15, dec5: 0.6, sus5: 0.8, rls5: 0.8,
        atk6: 0.2, dec6: 1.0, sus6: 0.7, rls6: 1.2,
        atk7: 0.4, dec7: 2.0, sus7: 0.9, rls7: 3.0,
        // Unique FX (All 0.0)
        fxSol: 0.0, fxLuna: 0.0, fxMars: 0.0, fxMerc: 0.0, fxJup: 0.0, fxJuno: 0.0, fxSat: 0.0,
        // Group & Master FX (All wet mixes 0.0)
        celDelMix: 0.0, celDelTime: 0.33, celDelFb: 0.4,
        celVerbMix: 0.0, celVerbDec: 0.6,
        ancChoMix: 0.0, ancVerbMix: 0.0, ancVerbDec: 0.5,
        masterLpf: 18000, masterLim: 0.95, tapeDrive: 0.0
    );

    // B. CONTROL BUSES
    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~celestialBus = Bus.audio(s, 2);
    ~ancientBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS
    SynthDef(\z1_Sol, { arg out, freq=440, gate=1, vol=0.3, pan=0, mute=0, lpf=12000, rq=0.2, hpf=80, atk=0.05, dec=0.4, sus=0.7, rls=0.5, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var modIdx = 1 + (uniqueFx * 4);
        var modRatio = 1 + uniqueFx;
        var mod = SinOsc.ar(freq * modRatio) * freq * modIdx;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.7));
    }).add;

    SynthDef(\z2_Luna, { arg out, freq=440, gate=1, vol=0.35, pan=0, mute=0, lpf=8000, rq=0.1, hpf=200, atk=0.1, dec=0.8, sus=0.5, rls=1.0, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var trig = Dust.ar(15 + (uniqueFx * 30));
        var drift = LFNoise2.kr(2) * uniqueFx * 0.1;
        var sig = GrainSin.ar(1, trig, 0.08, freq * (1 + drift), 0);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.7));
    }).add;

    SynthDef(\z3_Mars, { arg out, freq=440, gate=1, vol=0.25, pan=0, mute=0, lpf=5000, rq=0.5, hpf=150, atk=0.01, dec=0.1, sus=0, rls=0.2, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05));
        var delayTime = freq.reciprocal.clip(0.0001, 0.19);
        var sig = CombL.ar(exc, 0.2, delayTime, rls);
        sig = (sig * (1 + (uniqueFx * 4))).tanh;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.7));
    }).add;

    SynthDef(\z4_Merc, { arg out, freq=440, gate=1, vol=0.3, pan=0, mute=0, lpf=7000, rq=0.3, hpf=300, atk=0.02, dec=0.3, sus=0.6, rls=0.4, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var jitter = LFNoise0.kr(12) * uniqueFx * 0.05;
        var sig = Pulse.ar(freq * (1 + jitter), 0.5 + (uniqueFx * 0.3)) + Saw.ar(freq * 1.01);
        sig = sig * (1 - (LFNoise1.kr(20) * uniqueFx * 0.5));
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.4));
    }).add;

    SynthDef(\z5_Jup, { arg out, freq=440, gate=1, vol=0.2, pan=0, mute=0, lpf=10000, rq=0.3, hpf=60, atk=0.15, dec=0.6, sus=0.8, rls=0.8, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var detune = 0.01 + (uniqueFx * 0.03);
        var sig = Splay.ar(Saw.ar(freq * [1 - detune, 1, 1 + detune]));
        var orbitPan = pan + (SinOsc.kr(0.2) * uniqueFx);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Balance2.ar(sig[0], sig[1], orbitPan, env * vol * (1 - mute) * 0.7));
    }).add;

    SynthDef(\z6_Juno, { arg out, freq=440, gate=1, vol=0.28, pan=0, mute=0, lpf=9000, rq=0.1, hpf=100, atk=0.2, dec=1.0, sus=0.7, rls=1.2, uniqueFx=0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var lfo = SinOsc.kr(1 + (uniqueFx * 4));
        var mod = SinOsc.ar(freq * 2.01);
        var modIndex = 0.5 + (uniqueFx * 1.5) + (lfo * uniqueFx * 0.5);
        var sig = SinOsc.ar(freq, mod * modIndex);
        var octLayer = SinOsc.ar(freq * 4, mod * modIndex) * uniqueFx * 0.4;
        var dynamicLpf = lpf * (1 + (lfo * uniqueFx * 0.3));

		sig = sig + octLayer;
        sig = RLPF.ar(HPF.ar(sig, hpf), dynamicLpf.clip(20, 20000), 1.0 - rq.clip(0, 0.95));

        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.6));
    }).add;

    SynthDef(\z7_Saturn, { arg out, freq=110, gate=1, vol=0.25, pan=0, mute=0, lpf=5000, rq=0.4, hpf=40, atk=0.4, dec=2.0, sus=0.9, rls=3.0, uniqueFx=0;
        var lagFreq = Lag.kr(freq, 0.2);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var timeShift = SinOsc.kr(0.02) * uniqueFx;
        var mod = SinOsc.ar(lagFreq * (2 + timeShift)) * lagFreq * (1 + uniqueFx);
        var sig = SinOsc.ar(lagFreq * 0.5) + SinOsc.ar(lagFreq + mod);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, 1.0 - rq.clip(0, 0.95));
        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute) * 0.5));
    }).add;

    SynthDef(\fx_Celestial, { arg in, out, delMix, delTime, delFb, verbMix, verbDec;
        var sig = In.ar(in, 2);
        var delay = CombC.ar(sig, 2.0, delTime, delFb * 5);
        sig = (sig * (1 - delMix)) + (delay * delMix);
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, verbDec, 0.8);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_Ancient, { arg in, out, choMix, verbMix, verbDec;
        var sig = In.ar(in, 2);
        var chorus = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.5).range(0.01, 0.02));
        sig = (sig * (1 - choMix)) + (chorus * choMix);
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, verbDec, 0.2);
        Out.ar(out, sig);
    }).add;

    SynthDef(\fx_Master, { arg in, out, lpf, lim, drive;
        var sig = In.ar(in, 2);
        sig = LPF.ar(sig, lpf);
        sig = LeakDC.ar(sig);
        sig = (sig * (1 + (drive * 5))).tanh / (1 + (drive * 2));
        sig = Limiter.ar(sig, lim, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~celestialFx = Synth(\fx_Celestial, [
        \in, ~celestialBus, \out, ~masterBus,
        \delMix, ~buses.celDelMix.asMap, \delTime, ~buses.celDelTime.asMap, \delFb, ~buses.celDelFb.asMap,
        \verbMix, ~buses.celVerbMix.asMap, \verbDec, ~buses.celVerbDec.asMap
    ], ~fxGroup, \addToTail);

    ~ancientFx = Synth(\fx_Ancient, [
        \in, ~ancientBus, \out, ~masterBus,
        \choMix, ~buses.ancChoMix.asMap, \verbMix, ~buses.ancVerbMix.asMap, \verbDec, ~buses.ancVerbDec.asMap
    ], ~fxGroup, \addToTail);

    ~masterFx = Synth(\fx_Master, [
        \in, ~masterBus, \out, 0,
        \lpf, ~buses.masterLpf.asMap, \lim, ~buses.masterLim.asMap, \drive, ~buses.tapeDrive.asMap
    ], ~masterGroup, \addToTail);

    // F. SYNTH STATE & OSC
    ~notes = Array.fill(6, { Array.newClear(128) }); // Polyphonic zones 1-6
    ~saturnSynth = nil;
    ~saturnNote = nil;

    OSCdef(\sursockCC, { |msg|
        var num = msg[1].asInteger;
        var val = msg[2].asFloat;
        var mapped = val / 127.0;

        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { kStr.contains("Time") } { mapped.linexp(0, 1, 0.01, 2.0) }
                    { kStr.contains("masterLim") } { mapped.linlin(0, 1, 0.5, 1.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, '/sursock/cc');

    OSCdef(\sursockOn, { |msg|
        var noteNum = msg[1].asInteger;
        var freq = noteNum.midicps;

        // Zone 1: Sol (Ancient Bus)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[0][noteNum] = ~notes[0][noteNum].add(Synth(\z1_Sol, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxSol.asMap,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        // Zone 2: Luna (Celestial Bus)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[1][noteNum] = ~notes[1][noteNum].add(Synth(\z2_Luna, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxLuna.asMap,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        // Zone 3: Mars (Ancient Bus)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[2][noteNum] = ~notes[2][noteNum].add(Synth(\z3_Mars, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxMars.asMap,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        // Zone 4: Mercury (Celestial Bus)
        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[3][noteNum] = ~notes[3][noteNum].add(Synth(\z4_Merc, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxMerc.asMap,
                \vol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };

        // Zone 5: Jupiter (Ancient Bus)
        if((noteNum >= ~ccVals[\min5]) and: { noteNum <= ~ccVals[\max5] }) {
            ~notes[4][noteNum] = ~notes[4][noteNum].add(Synth(\z5_Jup, [
                \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxJup.asMap,
                \vol, ~buses.vol5.asMap, \pan, ~buses.pan5.asMap, \mute, ~buses.mute5.asMap,
                \lpf, ~buses.lpf5.asMap, \rq, ~buses.rq5.asMap, \hpf, ~buses.hpf5.asMap,
                \atk, ~buses.atk5.asMap, \dec, ~buses.dec5.asMap, \sus, ~buses.sus5.asMap, \rls, ~buses.rls5.asMap
            ], target: ~synthGroup));
        };

        // Zone 6: Juno (Celestial Bus)
        if((noteNum >= ~ccVals[\min6]) and: { noteNum <= ~ccVals[\max6] }) {
            ~notes[5][noteNum] = ~notes[5][noteNum].add(Synth(\z6_Juno, [
                \out, ~celestialBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxJuno.asMap,
                \vol, ~buses.vol6.asMap, \pan, ~buses.pan6.asMap, \mute, ~buses.mute6.asMap,
                \lpf, ~buses.lpf6.asMap, \rq, ~buses.rq6.asMap, \hpf, ~buses.hpf6.asMap,
                \atk, ~buses.atk6.asMap, \dec, ~buses.dec6.asMap, \sus, ~buses.sus6.asMap, \rls, ~buses.rls6.asMap
            ], target: ~synthGroup));
        };

        // Zone 7: Saturn (Monophonic, Ancient Bus)
        if((noteNum >= ~ccVals[\min7]) and: { noteNum <= ~ccVals[\max7] }) {
            if(~saturnSynth.isNil) {
                ~saturnSynth = Synth(\z7_Saturn, [
                    \out, ~ancientBus, \freq, freq, \gate, 1, \uniqueFx, ~buses.fxSat.asMap,
                    \vol, ~buses.vol7.asMap, \pan, ~buses.pan7.asMap, \mute, ~buses.mute7.asMap,
                    \lpf, ~buses.lpf7.asMap, \rq, ~buses.rq7.asMap, \hpf, ~buses.hpf7.asMap,
                    \atk, ~buses.atk7.asMap, \dec, ~buses.dec7.asMap, \sus, ~buses.sus7.asMap, \rls, ~buses.rls7.asMap
                ], target: ~synthGroup);
            } {
                ~saturnSynth.set(\freq, freq, \gate, 1);
            };
            ~saturnNote = noteNum;
        };

    }, '/sursock/noteOn');

    OSCdef(\sursockOff, { |msg|
        var noteNum = msg[1].asInteger;
        // Polyphonic Zones
        ~notes.do { |zoneArray|
            if(zoneArray[noteNum].notNil) {
                zoneArray[noteNum].do(_.set(\gate, 0));
                zoneArray[noteNum] = nil;
            };
        };
        // Monophonic Saturn
        if(~saturnNote == noteNum) {
            if(~saturnSynth.notNil) {
                ~saturnSynth.set(\gate, 0);
                ~saturnSynth = nil;
            };
        };
    }, '/sursock/noteOff');

    // Master Panic OSC Listener
    OSCdef(\sursockPanic, { |msg|
        if(~notes.notNil) {
            ~notes.do { |zoneArray|
                if(zoneArray.notNil) {
                    zoneArray.do { |synths, i|
                        if(synths.notNil) {
                            synths.do(_.set(\gate, 0));
                            zoneArray[i] = nil;
                        };
                    };
                };
            };
        };
        if(~saturnSynth.notNil) { ~saturnSynth.set(\gate, 0); ~saturnSynth = nil; };
        "OSC: Master Note Off triggered.".postln;
    }, '/sursock/panic');

    "Sursock Bronze V1.0 (OSC) Engine Initialized.".postln;
});
)

// Source: design-synth-sursock-OSC.scd [Block 4]
// MODE: design
// THEME: STEP 4: ADVANCED UI
// KEYWORDS: advanced, design, hpf, limiter, step
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(7);
    var tabButtons = Array.newClear(7);
    var zoneNames = ["Sol", "Luna", "Mars", "Mercury", "Jupiter", "Juno", "Saturn"];
    var uniqueFxNames = ["Radiance Spread", "Grain Drift", "Impact Grit", "Prophecy Jitter", "Planetary Orbit", "Veil Shimmer", "Temporal Shift"];
    var uniqueFxKeys = [\fxSol, \fxLuna, \fxMars, \fxMerc, \fxJup, \fxJuno, \fxSat];
    var screen, actualHeight, bounds;

    if(~surWin.notNil and: { ~surWin.isClosed.not }) { ~surWin.close };
    ~ui = ();

    screen = Window.availableBounds;
    actualHeight = min(860, screen.height - 50);
    bounds = Rect(0, 0, 680, actualHeight).center_(screen.center);

    ~surWin = Window("The Sursock Bronze Control (OSC)", bounds, scroll: true);
    ~surWin.view.background = Color.fromHexString("#2C241B"); // Bronze-ish dark

    ~tabContainer = CompositeView(~surWin, Rect(15, 15, 650, 40)).decorator_(FlowLayout(Rect(0,0,650,40), 0@0, 5@0));
    ~pagesContainer = CompositeView(~surWin, Rect(15, 65, 650, 540));
    ~fxContainer = CompositeView(~surWin, Rect(15, 615, 650, 220));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.fromHexString("#D4AF37"), Color.gray(0.3)); // Gold active
            b.states_([[zoneNames[i], textColor, bgColor]]);
        };
    };

    zoneNames.do { |name, i|
        tabButtons[i] = Button(~tabContainer, 88@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, fxName, fxKey|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.15, 0.9)).decorator_(FlowLayout(box.bounds, 15@15, 15@10)).visible_(false);
        pages[pageIndex] = box;

        mKey = ("mute"++pref).asSymbol;
        minKey = ("min"++pref).asSymbol;
        maxKey = ("max"++pref).asSymbol;
        vKey = ("vol"++pref).asSymbol;
        pKey = ("pan"++pref).asSymbol;
        hKey = ("hpf"++pref).asSymbol;
        lKey = ("lpf"++pref).asSymbol;
        rKey = ("rq"++pref).asSymbol;
        aKey = ("atk"++pref).asSymbol;
        dKey = ("dec"++pref).asSymbol;
        sKey = ("sus"++pref).asSymbol;
        rlsKey = ("rls"++pref).asSymbol;

        // Header & Mute
        StaticText(box, 450@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 18, true));
        ~ui[mKey] = Button(box, 140@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(60, 60, 60)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.red(0.6)]
        ]).action_({ |b| ~buses[mKey].set(b.value); ~ccVals[mKey] = b.value; });

        // Horizontal Mix & Mapping
        rLabel = "Keys (CC" ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")";
        ~ui[("range"++pref).asSymbol] = EZRanger(box, 600@35, rLabel, [0, 127, \lin, 1, 0], { |sl|
            ~ccVals[minKey] = sl.value[0]; ~ccVals[maxKey] = sl.value[1];
        }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 120).setColors(stringColor: Color.white);

        vLabel = "Vol (CC" ++ ~cc[vKey] ++ ")";
        ~ui[vKey] = EZSlider(box, 600@35, vLabel, \amp, { |sl| ~buses[vKey].set(sl.value); ~ccVals[vKey] = sl.value; }, ~ccVals[vKey], labelWidth: 120).setColors(stringColor: Color.white);

        StaticText(box, 600@8).background_(Color.gray(0.3)); // Divider

        // Filters
        ~ui[pKey] = EZKnob(box, kSize, "Pan " ++ ~cc[pKey], \bipolar, { |kn| ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value; }, ~ccVals[pKey]).setColors(stringColor: Color.white);
        ~ui[hKey] = EZKnob(box, kSize, "HPF " ++ ~cc[hKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value; }, ~ccVals[hKey]).setColors(stringColor: Color.white);
        ~ui[lKey] = EZKnob(box, kSize, "LPF " ++ ~cc[lKey], ControlSpec(20, 20000, \exp), { |kn| ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value; }, ~ccVals[lKey]).setColors(stringColor: Color.white);
        ~ui[rKey] = EZKnob(box, kSize, "Res " ++ ~cc[rKey], ControlSpec(1.0, 0.05, \exp), { |kn| ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value; }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        // Envelopes
        ~ui[aKey] = EZKnob(box, kSize, "Atk " ++ ~cc[aKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value; }, ~ccVals[aKey]).setColors(stringColor: Color.green(0.8));
        ~ui[dKey] = EZKnob(box, kSize, "Dec " ++ ~cc[dKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value; }, ~ccVals[dKey]).setColors(stringColor: Color.green(0.8));
        ~ui[sKey] = EZKnob(box, kSize, "Sus " ++ ~cc[sKey], \amp, { |kn| ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value; }, ~ccVals[sKey]).setColors(stringColor: Color.green(0.8));
        ~ui[rlsKey] = EZKnob(box, kSize, "Rls " ++ ~cc[rlsKey], ControlSpec(0.01, 10.0, \exp), { |kn| ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value; }, ~ccVals[rlsKey]).setColors(stringColor: Color.green(0.8));

        // Unique FX
        StaticText(box, 600@8).background_(Color.gray(0.3)); // Divider
        ~ui[fxKey] = EZSlider(box, 600@40, fxName ++ " (" ++ ~cc[fxKey] ++ ")", \amp, { |sl| ~buses[fxKey].set(sl.value); ~ccVals[fxKey] = sl.value; }, ~ccVals[fxKey], labelWidth: 180).setColors(stringColor: Color.fromHexString("#D4AF37"));
    };

    7.do { |i| makeZone.value(zoneNames[i], i+1, i, uniqueFxNames[i], uniqueFxKeys[i]); };
    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX & PANIC ---
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,650,220), 15@10, 10@10));

    StaticText(~fxContainer, 500@20).string_("CELESTIAL & ANCIENT GROUP FX").stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 14, true)).align_(\center);

    Button(~fxContainer, 110@20).states_([
        ["PANIC (ALL OFF)", Color.white, Color.red(0.6)]
    ]).action_({
        if(~notes.notNil) {
            ~notes.do { |zoneArray|
                if(zoneArray.notNil) {
                    zoneArray.do { |synths, i|
                        if(synths.notNil) {
                            synths.do(_.set(\gate, 0));
                            zoneArray[i] = nil;
                        };
                    };
                };
            };
        };
        if(~saturnSynth.notNil) { ~saturnSynth.set(\gate, 0); ~saturnSynth = nil; };
        "GUI: Master Note Off triggered.".postln;
    });

    ~ui[\celDelMix] = EZSlider(~fxContainer, 300@25, "Cel Delay (CC" ++ ~cc[\celDelMix] ++ ")", \amp, { |sl| ~buses.celDelMix.set(sl.value); ~ccVals[\celDelMix] = sl.value; }, ~ccVals[\celDelMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\celVerbMix] = EZSlider(~fxContainer, 300@25, "Cel Verb (CC" ++ ~cc[\celVerbMix] ++ ")", \amp, { |sl| ~buses.celVerbMix.set(sl.value); ~ccVals[\celVerbMix] = sl.value; }, ~ccVals[\celVerbMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\ancChoMix] = EZSlider(~fxContainer, 300@25, "Anc Chorus (CC" ++ ~cc[\ancChoMix] ++ ")", \amp, { |sl| ~buses.ancChoMix.set(sl.value); ~ccVals[\ancChoMix] = sl.value; }, ~ccVals[\ancChoMix], labelWidth: 120).setColors(stringColor: Color.white);
    ~ui[\ancVerbMix] = EZSlider(~fxContainer, 300@25, "Anc Verb (CC" ++ ~cc[\ancVerbMix] ++ ")", \amp, { |sl| ~buses.ancVerbMix.set(sl.value); ~ccVals[\ancVerbMix] = sl.value; }, ~ccVals[\ancVerbMix], labelWidth: 120).setColors(stringColor: Color.white);

    StaticText(~fxContainer, 620@20).string_("MASTER FX").stringColor_(Color.fromHexString("#D4AF37")).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\masterLpf] = EZKnob(~fxContainer, 160@40, "Master LPF " ++ ~cc[\masterLpf], ControlSpec(20, 20000, \exp), { |kn| ~buses.masterLpf.set(kn.value); ~ccVals[\masterLpf] = kn.value; }, ~ccVals[\masterLpf], layout: \horz).setColors(stringColor: Color.white);
    ~ui[\masterLim] = EZKnob(~fxContainer, 160@40, "Limiter " ++ ~cc[\masterLim], ControlSpec(0.5, 1.0, \lin), { |kn| ~buses.masterLim.set(kn.value); ~ccVals[\masterLim] = kn.value; }, ~ccVals[\masterLim], layout: \horz).setColors(stringColor: Color.white);
    ~ui[\tapeDrive] = EZKnob(~fxContainer, 160@40, "Tape Drive " ++ ~cc[\tapeDrive], \amp, { |kn| ~buses.tapeDrive.set(kn.value); ~ccVals[\tapeDrive] = kn.value; }, ~ccVals[\tapeDrive], layout: \horz).setColors(stringColor: Color.white);

    ~surWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            if(~ui.notNil and: { ~surWin.isClosed.not }) {
                ~ui.keysValuesDo { |key, widget|
                    var pref;
                    if(widget.notNil) {
                        if(key.asString.contains("range")) {
                            pref = key.asString.last.asString;
                            widget.value = [~ccVals[("min"++pref).asSymbol], ~ccVals[("max"++pref).asSymbol]];
                        } {
                            widget.value = ~ccVals[key];
                        };
                    };
                };
            };
            0.05.wait;
        }
    }).play(AppClock);

    ~surWin.onClose = {
        ~guiRoutine.stop; ~surWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: palmhouse-synth-v2.scd [Block 3]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, dynklank, freeverb2, fx_GroupReverb, fx_GroupTremolo, fx_Master, pulse, rlpf, sinosc, zone1_Earth, zone2_Iron, zone3_Foliage, zone4_Glass
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. BUFFERS
    ~wtBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~wtBuf.sine1([1, 0.6, 0.3, 0.15, 0.08, 0.04], true, true, true);
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        vol1: 0.8, vol2: 0.8, vol3: 0.8, vol4: 0.8,
        bassRes: 0.5, ironDecay: 0.5, folLfoRate: 2.0, folLfoDepth: 0.1,
        tremRate: 5.0, tremDepth: 0.5, verbMix: 0.3, verbDecay: 0.6
    );

    // Generate buses dynamically from the dictionary
    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS

    // --- EFFECTS ---
    SynthDef(\fx_GroupTremolo, { |in, out, rateBus, depthBus|
        var sig = In.ar(in, 2);
        var rate = In.kr(rateBus);
        var depth = In.kr(depthBus);
        var mod = SinOsc.kr(rate).range(1.0 - depth, 1.0);
        Out.ar(out, sig * mod);
    }).add;

    SynthDef(\fx_GroupReverb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var decay = In.kr(decayBus);
        var verb = FreeVerb2.ar(sig[0], sig[1], mix, decay, 0.2);
        Out.ar(out, verb);
    }).add;

    SynthDef(\fx_Master, { |in, out=0|
        var sig = In.ar(in, 2);
        sig = LPF.ar(sig, 14000);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // --- GENERATORS ---

    // Zone 1: Deep Earth (Velocity -> Sub Amplitude Exponentially)
    SynthDef(\zone1_Earth, { arg out=0, freq=65.41, gate=1, vel=0.8, resBus, zoneVol=1.0;
        var lagFreq = Lag.kr(freq, 0.3);
        var res = In.kr(resBus).linexp(0, 1, 1.0, 0.1);
        var env = EnvGen.kr(Env.asr(0.8, 1.0, 1.5), gate, doneAction: 2);
        var sig = Pulse.ar([lagFreq * 0.99, lagFreq * 1.01], 0.5) * 0.3;

        // VELOCITY MAPPING: Exponential curve for the sub oscillator
        var subVel = vel.pow(2);
        var sub = SinOsc.ar(lagFreq * 0.5) * 0.8 * subVel;

        sig = RLPF.ar(sig + sub, lagFreq * 4, res);
        sig = (sig * 1.5).tanh;
        Out.ar(out, Pan2.ar(sig * env * zoneVol, 0));
    }).add;

    // Zone 2: Cast Iron (Velocity -> Decay Time)
    SynthDef(\zone2_Iron, { arg out=0, freq=261.6, gate=1, vel=0.8, decayBus, zoneVol=1.0;
        // VELOCITY MAPPING: Harder strikes ring out longer
        var baseDecay = In.kr(decayBus).linlin(0, 1, 0.1, 4.0);
        var velDecay = vel.linlin(0.01, 1.0, 0.2, 1.5);
        var env = EnvGen.kr(Env.asr(0.01, 1.0, 1.0), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05));
        var freqs = [1, 2.76, 5.4, 8.9, 13.3] * freq;
        var amps = [1.0, 0.6, 0.3, 0.15, 0.05];
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * baseDecay * velDecay;
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = sig + CombC.ar(sig, 0.1, 0.02, 0.4, 0.3);
        Out.ar(out, Pan2.ar(sig * env * vel * zoneVol, 0));
    }).add;

    // Zone 3: Foliage Pad (Velocity Ignored + Internal LFO)
    SynthDef(\zone3_Foliage, { arg out=0, freq=523.25, gate=1, vel=0.8, rateBus, depthBus, bufnum, zoneVol=1.0;
        // INTERNAL MODULATION: LFO applied to the wavetable read frequency
        var lfo = SinOsc.kr(In.kr(rateBus)).range(1.0 - In.kr(depthBus), 1.0 + In.kr(depthBus));
        var env = EnvGen.kr(Env.asr(1.2, 1.0, 2.0), gate, doneAction: 2);

        // VELOCITY MAPPING: Ignored. Fixed amplitude used instead.
        var fixedAmp = 0.4;

        var sig = COsc.ar(bufnum, freq * [0.995, 1.005] * lfo, 1.0);
        sig = LPF.ar(sig, 3000);
        sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.015, 0.025), 0.6);
        Out.ar(out, Pan2.ar(sig * env * fixedAmp * zoneVol, 0));
    }).add;

    // Zone 4: Sparkling Glass (Internal Pitch Envelope)
    SynthDef(\zone4_Glass, { arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=1.0;
        var env = EnvGen.kr(Env.asr(0.05, 1.0, 1.5), gate, doneAction: 2);

        // INTERNAL MODULATION: Rapid transient pitch envelope
        var pitchEnv = EnvGen.kr(Env([2.5, 1.0], [0.08], \exp));

        var exciter = PinkNoise.ar;
        var sig = Resonz.ar(exciter, freq * [1, 2.01, 3.05] * pitchEnv, 0.005).sum;
        sig = sig + CombL.ar(sig, 0.2, 0.04, 1.5, 0.6);
        Out.ar(out, Pan2.ar(sig * env * vel * zoneVol * 25.0, 0));
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~tremoloFx = Synth(\fx_GroupTremolo, [
        \in, ~groupBus, \out, ~reverbBus,
        \rateBus, ~buses.tremRate, \depthBus, ~buses.tremDepth
    ], target: ~fxGroup, addAction: \addToTail);

    ~reverbFx = Synth(\fx_GroupReverb, [
        \in, ~reverbBus, \out, ~masterBus,
        \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay
    ], target: ~fxGroup, addAction: \addToTail);

    ~masterFx = Synth(\fx_Master, [
        \in, ~masterBus, \out, 0
    ], target: ~masterGroup, addAction: \addToTail);

    // F. SYNTH STATE & MIDI
    ~notes = Array.newClear(128);
    ~monoBassSynth = nil;
    ~monoBassNote = nil;

    MIDIdef.cc(\globalCC, { |val, num|
        var mapped = val / 127.0;
        case
            { num == ~cc.vol1 } { ~buses.vol1.set(mapped); ~ccVals[\vol1] = mapped; }
            { num == ~cc.vol2 } { ~buses.vol2.set(mapped); ~ccVals[\vol2] = mapped; }
            { num == ~cc.vol3 } { ~buses.vol3.set(mapped); ~ccVals[\vol3] = mapped; }
            { num == ~cc.vol4 } { ~buses.vol4.set(mapped); ~ccVals[\vol4] = mapped; }
            { num == ~cc.bassRes } { ~buses.bassRes.set(mapped); ~ccVals[\bassRes] = mapped; }
            { num == ~cc.ironDecay } { ~buses.ironDecay.set(mapped); ~ccVals[\ironDecay] = mapped; }
            { num == ~cc.folLfoRate } { var r = mapped.linlin(0,1,0.1,10); ~buses.folLfoRate.set(r); ~ccVals[\folLfoRate] = r; }
            { num == ~cc.folLfoDepth } { ~buses.folLfoDepth.set(mapped); ~ccVals[\folLfoDepth] = mapped; }
            { num == ~cc.tremRate } { var r = mapped.linlin(0,1,0.1,15); ~buses.tremRate.set(r); ~ccVals[\tremRate] = r; }
            { num == ~cc.tremDepth } { ~buses.tremDepth.set(mapped); ~ccVals[\tremDepth] = mapped; }
            { num == ~cc.verbMix } { ~buses.verbMix.set(mapped); ~ccVals[\verbMix] = mapped; }
            { num == ~cc.verbDecay } { ~buses.verbDecay.set(mapped); ~ccVals[\verbDecay] = mapped; };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\palmHouseOn, { |velocity, noteNum, channel, src|
        var freq = noteNum.midicps;
        var vel = velocity / 127.0; // Pass raw velocity

        if(noteNum <= ~splits.earthMax) {
            if(~monoBassSynth.isNil) {
                ~monoBassSynth = Synth(\zone1_Earth, [
                    \out, ~masterBus, \freq, freq, \vel, vel, \gate, 1,
                    \resBus, ~buses.bassRes, \zoneVol, ~buses.vol1.asMap
                ], target: ~synthGroup);
            } {
                ~monoBassSynth.set(\freq, freq, \vel, vel);
            };
            ~monoBassNote = noteNum;
        } {
            if(~notes[noteNum].notNil) { ~notes[noteNum].set(\gate, 0); };

            ~notes[noteNum] = case
                { noteNum <= ~splits.ironMax } {
                    Synth(\zone2_Iron, [
                        \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1,
                        \decayBus, ~buses.ironDecay, \zoneVol, ~buses.vol2.asMap
                    ], target: ~synthGroup);
                }
                { noteNum <= ~splits.foliageMax } {
                    Synth(\zone3_Foliage, [
                        \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1,
                        \rateBus, ~buses.folLfoRate, \depthBus, ~buses.folLfoDepth, \bufnum, ~wtBuf,
                        \zoneVol, ~buses.vol3.asMap
                    ], target: ~synthGroup);
                }
                { noteNum > ~splits.foliageMax } {
                    Synth(\zone4_Glass, [
                        \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1,
                        \zoneVol, ~buses.vol4.asMap
                    ], target: ~synthGroup);
                };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\palmHouseOff, { |velocity, noteNum, channel, src|
        if(noteNum <= ~splits.earthMax) {
            if(noteNum == ~monoBassNote) {
                if(~monoBassSynth.notNil) {
                    ~monoBassSynth.set(\gate, 0);
                    ~monoBassSynth = nil;
                    ~monoBassNote = nil;
                };
            };
        } {
            if(~notes[noteNum].notNil) {
                ~notes[noteNum].set(\gate, 0);
                ~notes[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    "Palm House V2 Engine Initialized.".postln;
});
)

// Source: palmhouse-synth-v2.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |synth, i| if(synth.notNil) { synth.set(\gate, 0); } });
    ~notes = nil;
};

if(~monoBassSynth.notNil) {
    ~monoBassSynth.set(\gate, 0);
    ~monoBassSynth = nil;
    ~monoBassNote = nil;
};

~tremoloFx.free;
~reverbFx.free;
~masterFx.free;

~buses.keysValuesDo { |key, bus| bus.free };

~groupBus.free;
~reverbBus.free;
~masterBus.free;

~synthGroup.free;
~fxGroup.free;
~masterGroup.free;

if(~wtBuf.notNil) { ~wtBuf.free };

"Palm House V2 cleanup complete.".postln;
)

// Source: palmhouse-synth-v3-OSC.scd [Block 3]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, dynklank, freeverb2, fx_GroupReverb, fx_GroupTremolo, fx_Master, hpf, rlpf, sinosc, zone1_Earth, zone2_Iron, zone3_Foliage, zone4_Glass
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. BUFFERS
    ~wtBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~wtBuf.sine1([1, 0.6, 0.3, 0.15, 0.08, 0.04], true, true, true);
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Adjusted volumes for better initial mix
        vol1: 0.3, vol2: 0.02, vol3: 0.3, vol4: 0.3,
        pan1: -0.75, pan2: -0.25, pan3: 0.25, pan4: 0.75,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 47,
        min2: 48, max2: 64,
        min3: 65, max3: 80,
        min4: 81, max4: 127,

        lpf1: 1500, lpf2: 15000, lpf3: 8000, lpf4: 15000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 100, hpf3: 150, hpf4: 300,

        // ADSR Defaults
        atk1: 0.8, dec1: 1.0, sus1: 1.0, rls1: 1.5,
        atk2: 0.01, dec2: 1.0, sus2: 1.0, rls2: 1.0,
        atk3: 1.2, dec3: 1.0, sus3: 1.0, rls3: 2.0,
        atk4: 0.05, dec4: 1.0, sus4: 1.0, rls4: 1.5,

        // Specific Mods & Unique FX
        ironDecay: 0.5, folLfoRate: 2.0, folLfoDepth: 0.0,
        drive1: 1.5, inharm2: 1.0, chorus3: 0.005, combDec4: 0.6,

        // Global FX
        tremRate: 5.0, tremDepth: 0.0, verbMix: 0.0, verbDecay: 0.6
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS
    SynthDef(\fx_GroupTremolo, { |in, out, rateBus, depthBus|
        var sig = In.ar(in, 2);
        var mod = SinOsc.kr(In.kr(rateBus)).range(1.0 - In.kr(depthBus), 1.0);
        Out.ar(out, sig * mod);
    }).add;

    SynthDef(\fx_GroupReverb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        Out.ar(out, FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.2));
    }).add;

    SynthDef(\fx_Master, { |in, out=0|
        var sig = Limiter.ar(LPF.ar(In.ar(in, 2), 14000), 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Deep Earth (Unique FX: Drive Saturation)
    SynthDef(\zone1_Earth, { arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=1500, rq=1, hpf=20, atk=0.8, dec=1.0, sus=1.0, rls=1.5, drive=1.5;
        var lagFreq = Lag.kr(freq, 0.3);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Pulse.ar([lagFreq * 0.99, lagFreq * 1.01], 0.5) * 0.3;
        sig = sig + (SinOsc.ar(lagFreq * 0.5) * 0.8 * vel.pow(2));
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Drive applied before tanh limiter for saturation
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * zoneVol * (1 - mute) * (sig * drive).tanh * 1.5));
    }).add;

    // ZONE 2: Cast Iron (Unique FX: Inharmonicity)
    SynthDef(\zone2_Iron, { arg out=0, freq=261.6, gate=1, vel=0.8, decay=0.5, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=100, atk=0.01, dec=1.0, sus=1.0, rls=1.0, inharm=1.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * (EnvGen.ar(Env.perc(0.001, 0.05)) + env);
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * decay.linlin(0, 1, 0.1, 4.0) * vel.linlin(0.01, 1.0, 0.2, 1.5);
        // Inharm multiplier stretches the upper partials out of tune
        var freqs = [1, 2.76 * inharm, 5.4 * inharm, 8.9 * inharm, 13.3 * inharm] * freq;
        var sig = DynKlank.ar(`[freqs, [1.0, 0.6, 0.3, 0.15, 0.05], rings], exciter);
        sig = sig + CombC.ar(sig, 0.1, 0.02, 0.4, 0.3);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sig, hpf), lpf, rq), pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Foliage Pad (Unique FX: Chorus Spread)
    SynthDef(\zone3_Foliage, { arg out=0, freq=523.25, gate=1, vel=0.8, rate=2.0, depth=0.0, bufnum, zoneVol=0.25, pan=0, mute=0, lpf=8000, rq=1, hpf=150, atk=1.2, dec=1.0, sus=1.0, rls=2.0, chorus=0.005;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Chorus determines the tuning offset of the stereo wavetable
        var sig = COsc.ar(bufnum, freq * [1.0 - chorus, 1.0 + chorus] * SinOsc.kr(rate).range(1.0 - depth, 1.0 + depth), 1.0);
        sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.015, 0.025), 0.6);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * 0.4 * zoneVol * (1 - mute)));
    }).add;

    // ZONE 4: Sparkling Glass (Unique FX: Comb Decay Time)
    SynthDef(\zone4_Glass, { arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=300, atk=0.05, dec=1.0, sus=1.0, rls=1.5, combDec=0.6;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Resonz.ar(PinkNoise.ar, freq * [1, 2.01, 3.05] * EnvGen.kr(Env([2.5, 1.0], [0.08], \exp)), 0.005).sum;
        // CombDec allows the metallic ringing echo to be shortened or vastly extended
        var sigComb = sig + CombL.ar(sig, 0.2, 0.04, combDec, 0.6);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sigComb, hpf), lpf, rq), pan, env * vel * zoneVol * 25.0 * (1 - mute)));
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~tremoloFx = Synth(\fx_GroupTremolo, [\in, ~groupBus, \out, ~reverbBus, \rateBus, ~buses.tremRate, \depthBus, ~buses.tremDepth], ~fxGroup, \addToTail);
    ~reverbFx = Synth(\fx_GroupReverb, [\in, ~reverbBus, \out, ~masterBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~masterFx = Synth(\fx_Master, [\in, ~masterBus, \out, 0], ~masterGroup, \addToTail);

    // F. SYNTH STATE & OSC
    ~notes = Array.newClear(128);

    OSCdef(\globalCC, { |msg|
        var num = msg[1].asInteger;
        var val = msg[2].asFloat;
        var mapped = val / 127.0;

        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { key == \folLfoRate } { mapped.linlin(0, 1, 0.1, 10) }
                    { key == \tremRate } { mapped.linlin(0, 1, 0.1, 15) }
                    { key == \drive1 } { mapped.linexp(0, 1, 1.0, 15.0) }
                    { key == \inharm2 } { mapped.linlin(0, 1, 1.0, 2.0) }
                    { key == \chorus3 } { mapped.linexp(0, 1, 0.001, 0.05) }
                    { key == \combDec4 } { mapped.linexp(0, 1, 0.1, 5.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, '/palm/cc');

    OSCdef(\palmHouseOn, { |msg|
        var noteNum = msg[1].asInteger;
        var velRaw = msg[2].asFloat;
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone1_Earth, [
                \out, ~masterBus, \freq, freq, \vel, vel, \gate, 1, \drive, ~buses.drive1.asMap,
                \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Iron, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \decay, ~buses.ironDecay.asMap, \inharm, ~buses.inharm2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone3_Foliage, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \bufnum, ~wtBuf, \chorus, ~buses.chorus3.asMap,
                \rate, ~buses.folLfoRate.asMap, \depth, ~buses.folLfoDepth.asMap,
                \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Glass, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \combDec, ~buses.combDec4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, '/palm/noteOn');

    OSCdef(\palmHouseOff, { |msg|
        var noteNum = msg[1].asInteger;
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };
    }, '/palm/noteOff');

    "Palm House V4.4 (OSC) Engine Initialized.".postln;
});
)

// Source: palmhouse-synth-v3.scd [Block 3]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, dynklank, freeverb2, fx_GroupReverb, fx_GroupTremolo, fx_Master, hpf, rlpf, sinosc, zone1_Earth, zone2_Iron, zone3_Foliage, zone4_Glass
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. BUFFERS
    ~wtBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~wtBuf.sine1([1, 0.6, 0.3, 0.15, 0.08, 0.04], true, true, true);
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Adjusted volumes for better initial mix
        vol1: 0.3, vol2: 0.02, vol3: 0.3, vol4: 0.3,
        pan1: -0.75, pan2: -0.25, pan3: 0.25, pan4: 0.75,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 47,
        min2: 48, max2: 64,
        min3: 65, max3: 80,
        min4: 81, max4: 127,

        lpf1: 1500, lpf2: 15000, lpf3: 8000, lpf4: 15000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 100, hpf3: 150, hpf4: 300,

        // ADSR Defaults
        atk1: 0.8, dec1: 1.0, sus1: 1.0, rls1: 1.5,
        atk2: 0.01, dec2: 1.0, sus2: 1.0, rls2: 1.0,
        atk3: 1.2, dec3: 1.0, sus3: 1.0, rls3: 2.0,
        atk4: 0.05, dec4: 1.0, sus4: 1.0, rls4: 1.5,

        // Specific Mods & Unique FX
        ironDecay: 0.5, folLfoRate: 2.0, folLfoDepth: 0.0,
        drive1: 1.5, inharm2: 1.0, chorus3: 0.005, combDec4: 0.6,

        // Global FX
        tremRate: 5.0, tremDepth: 0.0, verbMix: 0.0, verbDecay: 0.6
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS
    SynthDef(\fx_GroupTremolo, { |in, out, rateBus, depthBus|
        var sig = In.ar(in, 2);
        var mod = SinOsc.kr(In.kr(rateBus)).range(1.0 - In.kr(depthBus), 1.0);
        Out.ar(out, sig * mod);
    }).add;

    SynthDef(\fx_GroupReverb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        Out.ar(out, FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.2));
    }).add;

    SynthDef(\fx_Master, { |in, out=0|
        var sig = Limiter.ar(LPF.ar(In.ar(in, 2), 14000), 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Deep Earth (Unique FX: Drive Saturation)
    SynthDef(\zone1_Earth, { arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=1500, rq=1, hpf=20, atk=0.8, dec=1.0, sus=1.0, rls=1.5, drive=1.5;
        var lagFreq = Lag.kr(freq, 0.3);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Pulse.ar([lagFreq * 0.99, lagFreq * 1.01], 0.5) * 0.3;
        sig = sig + (SinOsc.ar(lagFreq * 0.5) * 0.8 * vel.pow(2));
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Drive applied before tanh limiter for saturation
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * zoneVol * (1 - mute) * (sig * drive).tanh * 1.5));
    }).add;

    // ZONE 2: Cast Iron (Unique FX: Inharmonicity)
    SynthDef(\zone2_Iron, { arg out=0, freq=261.6, gate=1, vel=0.8, decay=0.5, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=100, atk=0.01, dec=1.0, sus=1.0, rls=1.0, inharm=1.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * (EnvGen.ar(Env.perc(0.001, 0.05)) + env);
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * decay.linlin(0, 1, 0.1, 4.0) * vel.linlin(0.01, 1.0, 0.2, 1.5);
        // Inharm multiplier stretches the upper partials out of tune
        var freqs = [1, 2.76 * inharm, 5.4 * inharm, 8.9 * inharm, 13.3 * inharm] * freq;
        var sig = DynKlank.ar(`[freqs, [1.0, 0.6, 0.3, 0.15, 0.05], rings], exciter);
        sig = sig + CombC.ar(sig, 0.1, 0.02, 0.4, 0.3);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sig, hpf), lpf, rq), pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Foliage Pad (Unique FX: Chorus Spread)
    SynthDef(\zone3_Foliage, { arg out=0, freq=523.25, gate=1, vel=0.8, rate=2.0, depth=0.0, bufnum, zoneVol=0.25, pan=0, mute=0, lpf=8000, rq=1, hpf=150, atk=1.2, dec=1.0, sus=1.0, rls=2.0, chorus=0.005;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Chorus determines the tuning offset of the stereo wavetable
        var sig = COsc.ar(bufnum, freq * [1.0 - chorus, 1.0 + chorus] * SinOsc.kr(rate).range(1.0 - depth, 1.0 + depth), 1.0);
        sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.015, 0.025), 0.6);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * 0.4 * zoneVol * (1 - mute)));
    }).add;

    // ZONE 4: Sparkling Glass (Unique FX: Comb Decay Time)
    SynthDef(\zone4_Glass, { arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=300, atk=0.05, dec=1.0, sus=1.0, rls=1.5, combDec=0.6;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Resonz.ar(PinkNoise.ar, freq * [1, 2.01, 3.05] * EnvGen.kr(Env([2.5, 1.0], [0.08], \exp)), 0.005).sum;
        // CombDec allows the metallic ringing echo to be shortened or vastly extended
        sig = sig + CombL.ar(sig, 0.2, 0.04, combDec, 0.6);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sig, hpf), lpf, rq), pan, env * vel * zoneVol * 25.0 * (1 - mute)));
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~tremoloFx = Synth(\fx_GroupTremolo, [\in, ~groupBus, \out, ~reverbBus, \rateBus, ~buses.tremRate, \depthBus, ~buses.tremDepth], ~fxGroup, \addToTail);
    ~reverbFx = Synth(\fx_GroupReverb, [\in, ~reverbBus, \out, ~masterBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~masterFx = Synth(\fx_Master, [\in, ~masterBus, \out, 0], ~masterGroup, \addToTail);

    // F. SYNTH STATE & MIDI
    ~notes = Array.newClear(128);

    MIDIdef.cc(\globalCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { key == \folLfoRate } { mapped.linlin(0, 1, 0.1, 10) }
                    { key == \tremRate } { mapped.linlin(0, 1, 0.1, 15) }
                    { key == \drive1 } { mapped.linexp(0, 1, 1.0, 15.0) }
                    { key == \inharm2 } { mapped.linlin(0, 1, 1.0, 2.0) }
                    { key == \chorus3 } { mapped.linexp(0, 1, 0.001, 0.05) }
                    { key == \combDec4 } { mapped.linexp(0, 1, 0.1, 5.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\palmHouseOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone1_Earth, [
                \out, ~masterBus, \freq, freq, \vel, vel, \gate, 1, \drive, ~buses.drive1.asMap,
                \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Iron, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \decay, ~buses.ironDecay.asMap, \inharm, ~buses.inharm2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone3_Foliage, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \bufnum, ~wtBuf, \chorus, ~buses.chorus3.asMap,
                \rate, ~buses.folLfoRate.asMap, \depth, ~buses.folLfoDepth.asMap,
                \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Glass, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \combDec, ~buses.combDec4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\palmHouseOff, { |vel, noteNum|
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    "Palm House V4.4 Engine Initialized.".postln;
});
)

// Source: palmhouse-synth-v3.scd [Block 5]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.freeAll;

if(~notes.notNil) {
    ~notes.do({ |arr| if(arr.notNil) { arr.do(_.set(\gate, 0)) } });
    ~notes = nil;
};

~tremoloFx.free; ~reverbFx.free; ~masterFx.free;
~buses.keysValuesDo { |key, bus| bus.free };
~groupBus.free; ~reverbBus.free; ~masterBus.free;
~synthGroup.free; ~fxGroup.free; ~masterGroup.free;

if(~wtBuf.notNil) { ~wtBuf.free };

"Palm House V4.4 cleanup complete.".postln;
)

// Source: palmhouse-synth-v4-OSC.scd [Block 3]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, dynklank, freeverb2, fx_GroupReverb, fx_GroupTremolo, fx_Master, hpf, rlpf, sinosc, zone1_Earth, zone2_Iron, zone3_Foliage, zone4_Glass
(
s.options.memSize = 65536;
s.boot;

s.waitForBoot({

    // A. BUFFERS
    ~wtBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~wtBuf.sine1([1, 0.6, 0.3, 0.15, 0.08, 0.04], true, true, true);
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY
    ~ccVals = (
        // Adjusted volumes for better initial mix
        vol1: 0.3, vol2: 0.02, vol3: 0.3, vol4: 0.3,
        pan1: -0.75, pan2: -0.25, pan3: 0.25, pan4: 0.75,
        mute1: 0.0, mute2: 0.0, mute3: 0.0, mute4: 0.0,

        // Split Ranges
        min1: 0, max1: 47,
        min2: 48, max2: 64,
        min3: 65, max3: 80,
        min4: 81, max4: 127,

        lpf1: 1500, lpf2: 15000, lpf3: 8000, lpf4: 15000,
        rq1: 1.0, rq2: 1.0, rq3: 1.0, rq4: 1.0,
        hpf1: 20, hpf2: 100, hpf3: 150, hpf4: 300,

        // ADSR Defaults
        atk1: 0.8, dec1: 1.0, sus1: 1.0, rls1: 1.5,
        atk2: 0.01, dec2: 1.0, sus2: 1.0, rls2: 1.0,
        atk3: 1.2, dec3: 1.0, sus3: 1.0, rls3: 2.0,
        atk4: 0.05, dec4: 1.0, sus4: 1.0, rls4: 1.5,

        // Specific Mods & Unique FX
        ironDecay: 0.5, folLfoRate: 2.0, folLfoDepth: 0.0,
        drive1: 1.5, inharm2: 1.0, chorus3: 0.005, combDec4: 0.6,

        // Global FX
        tremRate: 5.0, tremDepth: 0.0, verbMix: 0.0, verbDecay: 0.6
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |key, val| ~buses[key] = Bus.control(s, 1).set(val) };

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS
    SynthDef(\fx_GroupTremolo, { |in, out, rateBus, depthBus|
        var sig = In.ar(in, 2);
        var mod = SinOsc.kr(In.kr(rateBus)).range(1.0 - In.kr(depthBus), 1.0);
        Out.ar(out, sig * mod);
    }).add;

    SynthDef(\fx_GroupReverb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        Out.ar(out, FreeVerb2.ar(sig[0], sig[1], In.kr(mixBus), In.kr(decayBus), 0.2));
    }).add;

    SynthDef(\fx_Master, { |in, out=0|
        var sig = Limiter.ar(LPF.ar(In.ar(in, 2), 14000), 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // ZONE 1: Deep Earth (Unique FX: Drive Saturation)
    SynthDef(\zone1_Earth, { arg out=0, freq=65.41, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=1500, rq=1, hpf=20, atk=0.8, dec=1.0, sus=1.0, rls=1.5, drive=1.5;
        var lagFreq = Lag.kr(freq, 0.3);
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Pulse.ar([lagFreq * 0.99, lagFreq * 1.01], 0.5) * 0.3;
        sig = sig + (SinOsc.ar(lagFreq * 0.5) * 0.8 * vel.pow(2));
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq);
        // Drive applied before tanh limiter for saturation
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * zoneVol * (1 - mute) * (sig * drive).tanh * 1.5));
    }).add;

    // ZONE 2: Cast Iron (Unique FX: Inharmonicity)
    SynthDef(\zone2_Iron, { arg out=0, freq=261.6, gate=1, vel=0.8, decay=0.5, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=100, atk=0.01, dec=1.0, sus=1.0, rls=1.0, inharm=1.0;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * (EnvGen.ar(Env.perc(0.001, 0.05)) + env);
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * decay.linlin(0, 1, 0.1, 4.0) * vel.linlin(0.01, 1.0, 0.2, 1.5);
        // Inharm multiplier stretches the upper partials out of tune
        var freqs = [1, 2.76 * inharm, 5.4 * inharm, 8.9 * inharm, 13.3 * inharm] * freq;
        var sig = DynKlank.ar(`[freqs, [1.0, 0.6, 0.3, 0.15, 0.05], rings], exciter);
        sig = sig + CombC.ar(sig, 0.1, 0.02, 0.4, 0.3);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sig, hpf), lpf, rq), pan, env * vel * zoneVol * (1 - mute)));
    }).add;

    // ZONE 3: Foliage Pad (Unique FX: Chorus Spread)
    SynthDef(\zone3_Foliage, { arg out=0, freq=523.25, gate=1, vel=0.8, rate=2.0, depth=0.0, bufnum, zoneVol=0.25, pan=0, mute=0, lpf=8000, rq=1, hpf=150, atk=1.2, dec=1.0, sus=1.0, rls=2.0, chorus=0.005;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Chorus determines the tuning offset of the stereo wavetable
        var sig = COsc.ar(bufnum, freq * [1.0 - chorus, 1.0 + chorus] * SinOsc.kr(rate).range(1.0 - depth, 1.0 + depth), 1.0);
        sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.015, 0.025), 0.6);
        Out.ar(out, Balance2.ar(sig[0], sig[1], pan, env * 0.4 * zoneVol * (1 - mute)));
    }).add;

    // ZONE 4: Sparkling Glass (Unique FX: Comb Decay Time)
    SynthDef(\zone4_Glass, { arg out=0, freq=1046.5, gate=1, vel=0.8, zoneVol=0.25, pan=0, mute=0, lpf=15000, rq=1, hpf=300, atk=0.05, dec=1.0, sus=1.0, rls=1.5, combDec=0.6;
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var sig = Resonz.ar(PinkNoise.ar, freq * [1, 2.01, 3.05] * EnvGen.kr(Env([2.5, 1.0], [0.08], \exp)), 0.005).sum;
        // CombDec allows the metallic ringing echo to be shortened or vastly extended
        var sigComb = sig + CombL.ar(sig, 0.2, 0.04, combDec, 0.6);
        Out.ar(out, Pan2.ar(RLPF.ar(HPF.ar(sigComb, hpf), lpf, rq), pan, env * vel * zoneVol * 25.0 * (1 - mute)));
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    ~tremoloFx = Synth(\fx_GroupTremolo, [\in, ~groupBus, \out, ~reverbBus, \rateBus, ~buses.tremRate, \depthBus, ~buses.tremDepth], ~fxGroup, \addToTail);
    ~reverbFx = Synth(\fx_GroupReverb, [\in, ~reverbBus, \out, ~masterBus, \mixBus, ~buses.verbMix, \decayBus, ~buses.verbDecay], ~fxGroup, \addToTail);
    ~masterFx = Synth(\fx_Master, [\in, ~masterBus, \out, 0], ~masterGroup, \addToTail);

    // F. SYNTH STATE & OSC
    ~notes = Array.newClear(128);

    OSCdef(\globalCC, { |msg|
        var num = msg[1].asInteger;
        var val = msg[2].asFloat;
        var mapped = val / 127.0;

        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|rls") } { mapped.linexp(0, 1, 0.01, 10.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { (val > 63).asInteger }
                    { key == \folLfoRate } { mapped.linlin(0, 1, 0.1, 10) }
                    { key == \tremRate } { mapped.linlin(0, 1, 0.1, 15) }
                    { key == \drive1 } { mapped.linexp(0, 1, 1.0, 15.0) }
                    { key == \inharm2 } { mapped.linlin(0, 1, 1.0, 2.0) }
                    { key == \chorus3 } { mapped.linexp(0, 1, 0.001, 0.05) }
                    { key == \combDec4 } { mapped.linexp(0, 1, 0.1, 5.0) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, '/palm/cc');

    OSCdef(\palmHouseOn, { |msg|
        var noteNum = msg[1].asInteger;
        var velRaw = msg[2].asFloat;
        var freq = noteNum.midicps;
        var vel = velRaw / 127.0;

        if(~notes[noteNum].notNil) { ~notes[noteNum].do(_.set(\gate, 0)) };
        ~notes[noteNum] = [];

        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone1_Earth, [
                \out, ~masterBus, \freq, freq, \vel, vel, \gate, 1, \drive, ~buses.drive1.asMap,
                \zoneVol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \hpf, ~buses.hpf1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone2_Iron, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \decay, ~buses.ironDecay.asMap, \inharm, ~buses.inharm2.asMap,
                \zoneVol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \hpf, ~buses.hpf2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone3_Foliage, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \bufnum, ~wtBuf, \chorus, ~buses.chorus3.asMap,
                \rate, ~buses.folLfoRate.asMap, \depth, ~buses.folLfoDepth.asMap,
                \zoneVol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap, \hpf, ~buses.hpf3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap
            ], target: ~synthGroup));
        };

        if((noteNum >= ~ccVals[\min4]) and: { noteNum <= ~ccVals[\max4] }) {
            ~notes[noteNum] = ~notes[noteNum].add(Synth(\zone4_Glass, [
                \out, ~groupBus, \freq, freq, \vel, vel, \gate, 1, \combDec, ~buses.combDec4.asMap,
                \zoneVol, ~buses.vol4.asMap, \pan, ~buses.pan4.asMap, \mute, ~buses.mute4.asMap,
                \lpf, ~buses.lpf4.asMap, \rq, ~buses.rq4.asMap, \hpf, ~buses.hpf4.asMap,
                \atk, ~buses.atk4.asMap, \dec, ~buses.dec4.asMap, \sus, ~buses.sus4.asMap, \rls, ~buses.rls4.asMap
            ], target: ~synthGroup));
        };
    }, '/palm/noteOn');

    OSCdef(\palmHouseOff, { |msg|
        var noteNum = msg[1].asInteger;
        if(~notes[noteNum].notNil) {
            ~notes[noteNum].do(_.set(\gate, 0));
            ~notes[noteNum] = nil;
        };
    }, '/palm/noteOff');

    // NEW: Master Panic OSC Listener
    OSCdef(\palmHousePanic, { |msg|
        if(~notes.notNil) {
            ~notes.do { |arr, i|
                if(arr.notNil) {
                    arr.do(_.set(\gate, 0));
                    ~notes[i] = nil;
                }
            };
            "OSC: Master Note Off triggered.".postln;
        };
    }, '/palm/panic');

    "Palm House V4.4 (OSC) Engine Initialized.".postln;
});
)

// Source: palmhouse-synth.scd [Block 2]
// MODE: design
// THEME: A. BUFFERS
// KEYWORDS: buffers, combl, design, dynklank, freeverb2, fx_GroupReverb, fx_GroupTremolo, fx_Master, pulse, rlpf, sinosc, zone1_Earth, zone2_Iron, zone3_Foliage, zone4_Glass
(
s.options.memSize = 65536; // Increased memory pool for reverb and buffers
s.boot;

s.waitForBoot({

    // A. BUFFERS
    // Generate an evolving wavetable for Zone 3 (Foliage Pad)
    ~wtBuf = Buffer.alloc(s, 2048, 1);
    s.sync;
    ~wtBuf.sine1([1, 0.6, 0.3, 0.15, 0.08, 0.04], true, true, true);
    s.sync;

    // B. CONTROL BUSES & STATE DICTIONARY (For safe GUI threading)
    ~ccVals = (
        vol1: 1.0, vol2: 1.0, vol3: 1.0, vol4: 1.0,
        bassRes: 0.5, ironDecay: 1.0, foliageCutoff: 2000, glassFb: 0.5,
        tremRate: 5.0, tremDepth: 0.5, verbMix: 0.3, verbDecay: 0.6
    );

    // Zone Mixer Volumes
    ~volZone1Bus = Bus.control(s, 1).set(~ccVals[\vol1]);
    ~volZone2Bus = Bus.control(s, 1).set(~ccVals[\vol2]);
    ~volZone3Bus = Bus.control(s, 1).set(~ccVals[\vol3]);
    ~volZone4Bus = Bus.control(s, 1).set(~ccVals[\vol4]);

    // Local & Global FX Parameters
    ~bassResBus = Bus.control(s, 1).set(~ccVals[\bassRes]);
    ~ironDecayBus = Bus.control(s, 1).set(~ccVals[\ironDecay]);
    ~foliageCutoffBus = Bus.control(s, 1).set(~ccVals[\foliageCutoff]);
    ~glassFbBus = Bus.control(s, 1).set(~ccVals[\glassFb]);

    ~tremoloRateBus = Bus.control(s, 1).set(~ccVals[\tremRate]);
    ~tremoloDepthBus = Bus.control(s, 1).set(~ccVals[\tremDepth]);
    ~verbMixBus = Bus.control(s, 1).set(~ccVals[\verbMix]);
    ~verbDecayBus = Bus.control(s, 1).set(~ccVals[\verbDecay]);

    // C. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus = Bus.audio(s, 2);
    ~reverbBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // D. SYNTHDEFS

    // --- EFFECTS ---
    SynthDef(\fx_GroupTremolo, { |in, out, rateBus, depthBus|
        var sig = In.ar(in, 2);
        var rate = In.kr(rateBus);
        var depth = In.kr(depthBus);
        var mod = SinOsc.kr(rate).range(1.0 - depth, 1.0);
        Out.ar(out, sig * mod);
    }).add;

    SynthDef(\fx_GroupReverb, { |in, out, mixBus, decayBus|
        var sig = In.ar(in, 2);
        var mix = In.kr(mixBus);
        var decay = In.kr(decayBus);
        var verb = FreeVerb2.ar(sig[0], sig[1], mix, decay, 0.2);
        Out.ar(out, verb);
    }).add;

    SynthDef(\fx_Master, { |in, out=0|
        var sig = In.ar(in, 2);
        sig = LPF.ar(sig, 14000); // Global EQ roll-off
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    // --- GENERATORS ---
    // Zone 1: Deep Earth & Warmth (Monophonic Pad)
    SynthDef(\zone1_Earth, { arg out=0, freq=65.41, gate=1, amp=0.5, resBus, zoneVol=1.0;
        var lagFreq = Lag.kr(freq, 0.3); // Portamento
        var res = In.kr(resBus).linexp(0, 1, 1.0, 0.1); // Map 0-1 to 1.0-0.1 (rq)
        var env = EnvGen.kr(Env.asr(0.8, 1.0, 1.5), gate, doneAction: 2);
        var sig = Pulse.ar([lagFreq * 0.99, lagFreq * 1.01], 0.5) * 0.3;
        var sub = SinOsc.ar(lagFreq * 0.5) * 0.5;
        sig = RLPF.ar(sig + sub, lagFreq * 4, res);
        sig = (sig * 1.5).tanh; // Local FX: Saturation warmth
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol, 0));
    }).add;

    // Zone 2: Cast Iron Resonances (Polyphonic Resonator)
    SynthDef(\zone2_Iron, { arg out=0, freq=261.6, gate=1, amp=0.5, decayBus, zoneVol=1.0;
        var decay = In.kr(decayBus).linlin(0, 1, 0.1, 3.0);
        var env = EnvGen.kr(Env.asr(0.01, 1.0, 1.0), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.05));
        var freqs = [1, 2.76, 5.4, 8.9, 13.3] * freq;
        var amps = [1.0, 0.6, 0.3, 0.15, 0.05];
        var rings = [1.0, 0.8, 0.6, 0.4, 0.2] * decay;
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        // Local FX: Short metallic CombC
        sig = sig + CombC.ar(sig, 0.1, 0.02, 0.4, 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol, 0));
    }).add;

    // Zone 3: Lush Tropical Foliage Pad (Polyphonic Wavetable)
    SynthDef(\zone3_Foliage, { arg out=0, freq=523.25, gate=1, amp=0.5, cutoffBus, bufnum, zoneVol=1.0;
        var cutoff = In.kr(cutoffBus).linexp(0, 1, 400, 8000);
        var env = EnvGen.kr(Env.asr(1.2, 1.0, 2.0), gate, doneAction: 2);
        var sig = COsc.ar(bufnum, freq * [0.995, 1.005], 1.0);
        sig = LPF.ar(sig, cutoff);
        // Local FX: Chorus
        sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.015, 0.025), 0.6);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol, 0));
    }).add;

    // Zone 4: Sparkling Glass & Air (Polyphonic Modal)
    SynthDef(\zone4_Glass, { arg out=0, freq=1046.5, gate=1, amp=0.5, fbBus, zoneVol=1.0;
        var fb = In.kr(fbBus).linexp(0, 1, 0.1, 2.5);
        var env = EnvGen.kr(Env.asr(0.05, 1.0, 1.5), gate, doneAction: 2);
        var exciter = PinkNoise.ar;
        var sig = Resonz.ar(exciter, freq * [1, 2.01, 3.05], 0.005).sum;
        // Local FX: CombL Shimmer
        sig = sig + CombL.ar(sig, 0.2, 0.04, fb, 0.6);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol * 25.0, 0)); // Resonz needs makeup gain
    }).add;

    s.sync;

    // E. INSTANTIATE EFFECTS
    // THE FIX: Added \addToTail so they execute in the correct chronological order!
    ~tremoloFx = Synth(\fx_GroupTremolo, [
        \in, ~groupBus,
        \out, ~reverbBus,
        \rateBus, ~tremoloRateBus,
        \depthBus, ~tremoloDepthBus
    ], target: ~fxGroup, addAction: \addToTail);

    ~reverbFx = Synth(\fx_GroupReverb, [
        \in, ~reverbBus,
        \out, ~masterBus,
        \mixBus, ~verbMixBus,
        \decayBus, ~verbDecayBus
    ], target: ~fxGroup, addAction: \addToTail);

    ~masterFx = Synth(\fx_Master, [
        \in, ~masterBus,
        \out, 0
    ], target: ~masterGroup, addAction: \addToTail);

    // F. SYNTH STATE & MIDI
    ~notes = Array.newClear(128);
    ~monoBassSynth = nil;
    ~monoBassNote = nil;

    // CC Mappings
    MIDIdef.cc(\mixerCC, { |val, num|
        var mapped = val.linlin(0, 127, 0.0, 1.0);
        case
            { num == 81 } { ~volZone1Bus.set(mapped); ~ccVals[\vol1] = mapped; }
            { num == 82 } { ~volZone2Bus.set(mapped); ~ccVals[\vol2] = mapped; }
            { num == 83 } { ~volZone3Bus.set(mapped); ~ccVals[\vol3] = mapped; }
            { num == 84 } { ~volZone4Bus.set(mapped); ~ccVals[\vol4] = mapped; };
    }, srcID: ~myUid);

    MIDIdef.cc(\paramsCC, { |val, num|
        var mapped = val.linlin(0, 127, 0.0, 1.0);
        var mappedRate = val.linlin(0, 127, 0.1, 15.0);
        case
            { num == 71 } { ~bassResBus.set(mapped); ~ccVals[\bassRes] = mapped; }
            { num == 72 } { ~ironDecayBus.set(mapped); ~ccVals[\ironDecay] = mapped; }
            { num == 73 } { ~foliageCutoffBus.set(mapped); ~ccVals[\foliageCutoff] = mapped; }
            { num == 74 } { ~glassFbBus.set(mapped); ~ccVals[\glassFb] = mapped; }
            { num == 75 } { ~tremoloRateBus.set(mappedRate); ~ccVals[\tremRate] = mappedRate; }
            { num == 76 } { ~tremoloDepthBus.set(mapped); ~ccVals[\tremDepth] = mapped; }
            { num == 77 } { ~verbMixBus.set(mapped); ~ccVals[\verbMix] = mapped; }
            { num == 78 } { ~verbDecayBus.set(mapped); ~ccVals[\verbDecay] = mapped; };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\palmHouseOn, { |velocity, noteNum, channel, src|
        var freq = noteNum.midicps;
        var amp = velocity / 127.0;

        // Zone 1: Deep Earth (Monophonic, <= 47)
        if(noteNum <= 47) {
            if(~monoBassSynth.isNil) {
                ~monoBassSynth = Synth(\zone1_Earth, [
                    \out, ~masterBus, // Bypasses group FX
                    \freq, freq, \amp, amp, \gate, 1,
                    \resBus, ~bassResBus, \zoneVol, ~volZone1Bus.asMap
                ], target: ~synthGroup);
            } {
                ~monoBassSynth.set(\freq, freq, \amp, amp);
            };
            ~monoBassNote = noteNum;
        } {
            // Polyphonic Zones (48 - 127)
            if(~notes[noteNum].notNil) { ~notes[noteNum].set(\gate, 0); };

            ~notes[noteNum] = case
                { noteNum >= 48 and: { noteNum <= 64 } } {
                    Synth(\zone2_Iron, [
                        \out, ~groupBus, \freq, freq, \amp, amp, \gate, 1,
                        \decayBus, ~ironDecayBus, \zoneVol, ~volZone2Bus.asMap
                    ], target: ~synthGroup);
                }
                { noteNum >= 65 and: { noteNum <= 80 } } {
                    Synth(\zone3_Foliage, [
                        \out, ~groupBus, \freq, freq, \amp, amp, \gate, 1,
                        \cutoffBus, ~foliageCutoffBus, \bufnum, ~wtBuf,
                        \zoneVol, ~volZone3Bus.asMap
                    ], target: ~synthGroup);
                }
                { noteNum >= 81 } {
                    Synth(\zone4_Glass, [
                        \out, ~groupBus, \freq, freq, \amp, amp, \gate, 1,
                        \fbBus, ~glassFbBus, \zoneVol, ~volZone4Bus.asMap
                    ], target: ~synthGroup);
                };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\palmHouseOff, { |velocity, noteNum, channel, src|
        if(noteNum <= 47) {
            if(noteNum == ~monoBassNote) {
                if(~monoBassSynth.notNil) {
                    ~monoBassSynth.set(\gate, 0);
                    ~monoBassSynth = nil;
                    ~monoBassNote = nil;
                };
            };
        } {
            if(~notes[noteNum].notNil) {
                ~notes[noteNum].set(\gate, 0);
                ~notes[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    "Palm House Conservatory Engine Initialized.".postln;
});
)

// Source: palmhouse-synth.scd [Block 3]
// MODE: design
// THEME: STEP 4: SUPERCOLLIDER GUI
// KEYWORDS: design, gui, step, supercollider
(
defer {
    if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };

    ~palmWin = Window("Palm House Conservatory Control", Rect(100, 100, 500, 800));
    ~palmWin.view.decorator = FlowLayout(~palmWin.view.bounds, 15@15, 0@15);
    ~palmWin.view.background = Color.fromHexString("#1E2A22"); // Deep foliage green

    // --- KEYBOARD ZONES VISUAL GUIDE ---
    StaticText(~palmWin, 470@25)
        .string_("PALM HOUSE HABITAT ZONES")
        .stringColor_(Color.green(0.8))
        .font_(Font("Arial", 16, true));

    StaticText(~palmWin, 470@80)
        .string_(
            "   Zone 1 [ <= 47 ]    Deep Earth & Warmth (Mono)\n" ++
            "   Zone 2 [ 48 - 64 ]  Cast Iron Resonances\n" ++
            "   Zone 3 [ 65 - 80 ]  Lush Tropical Foliage Pad\n" ++
            "   Zone 4 [ >= 81 ]    Sparkling Glass & Air"
        )
        .stringColor_(Color.white)
        .font_(Font("Courier", 13, true));

    // --- MIXER ---
    StaticText(~palmWin, 470@25)
        .string_("ZONE MIXER (CC 81-84)")
        .stringColor_(Color.green(0.8))
        .font_(Font("Arial", 14, true));

    ~slVol1 = EZSlider(~palmWin, 470@25, "Z1 Earth Vol", \amp, { |sl| ~volZone1Bus.set(sl.value); ~ccVals[\vol1] = sl.value; }, ~ccVals[\vol1], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slVol2 = EZSlider(~palmWin, 470@25, "Z2 Iron Vol", \amp, { |sl| ~volZone2Bus.set(sl.value); ~ccVals[\vol2] = sl.value; }, ~ccVals[\vol2], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slVol3 = EZSlider(~palmWin, 470@25, "Z3 Foliage Vol", \amp, { |sl| ~volZone3Bus.set(sl.value); ~ccVals[\vol3] = sl.value; }, ~ccVals[\vol3], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slVol4 = EZSlider(~palmWin, 470@25, "Z4 Glass Vol", \amp, { |sl| ~volZone4Bus.set(sl.value); ~ccVals[\vol4] = sl.value; }, ~ccVals[\vol4], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);

    // --- LOCAL PARAMS ---
    StaticText(~palmWin, 470@25)
        .string_("LOCAL TIMBRE CONTROLS (CC 71-74)")
        .stringColor_(Color.green(0.8))
        .font_(Font("Arial", 14, true));

    ~slBassRes = EZSlider(~palmWin, 470@25, "Z1 Bass Res", \amp, { |sl| ~bassResBus.set(sl.value); ~ccVals[\bassRes] = sl.value; }, ~ccVals[\bassRes], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slIronDec = EZSlider(~palmWin, 470@25, "Z2 Iron Decay", \amp, { |sl| ~ironDecayBus.set(sl.value); ~ccVals[\ironDecay] = sl.value; }, ~ccVals[\ironDecay], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slFolCut = EZSlider(~palmWin, 470@25, "Z3 Cutoff", \amp, { |sl| ~foliageCutoffBus.set(sl.value); ~ccVals[\foliageCutoff] = sl.value; }, ~ccVals[\foliageCutoff], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slGlassFb = EZSlider(~palmWin, 470@25, "Z4 Glass Shimmer", \amp, { |sl| ~glassFbBus.set(sl.value); ~ccVals[\glassFb] = sl.value; }, ~ccVals[\glassFb], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);

    // --- GLOBAL FX ---
    StaticText(~palmWin, 470@25)
        .string_("GROUP EFFECTS (CC 75-78)")
        .stringColor_(Color.green(0.8))
        .font_(Font("Arial", 14, true));

    ~slTremRate = EZSlider(~palmWin, 470@25, "Tremolo Rate", ControlSpec(0.1, 15.0, \exp), { |sl| ~tremoloRateBus.set(sl.value); ~ccVals[\tremRate] = sl.value; }, ~ccVals[\tremRate], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slTremDepth = EZSlider(~palmWin, 470@25, "Tremolo Depth", \amp, { |sl| ~tremoloDepthBus.set(sl.value); ~ccVals[\tremDepth] = sl.value; }, ~ccVals[\tremDepth], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slVerbMix = EZSlider(~palmWin, 470@25, "Reverb Mix", \amp, { |sl| ~verbMixBus.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);
    ~slVerbDec = EZSlider(~palmWin, 470@25, "Reverb Decay", \amp, { |sl| ~verbDecayBus.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 120)
        .setColors(stringColor: Color.white, numNormalColor: Color.white);

    ~palmWin.front;

    // Routine to safely update GUI from MIDIdef changes
    ~guiRoutine = Routine({
        loop {
            if(~slVol1.notNil) { ~slVol1.value = ~ccVals[\vol1] };
            if(~slVol2.notNil) { ~slVol2.value = ~ccVals[\vol2] };
            if(~slVol3.notNil) { ~slVol3.value = ~ccVals[\vol3] };
            if(~slVol4.notNil) { ~slVol4.value = ~ccVals[\vol4] };
            if(~slBassRes.notNil) { ~slBassRes.value = ~ccVals[\bassRes] };
            if(~slIronDec.notNil) { ~slIronDec.value = ~ccVals[\ironDecay] };
            if(~slFolCut.notNil) { ~slFolCut.value = ~ccVals[\foliageCutoff] };
            if(~slGlassFb.notNil) { ~slGlassFb.value = ~ccVals[\glassFb] };
            if(~slTremRate.notNil) { ~slTremRate.value = ~ccVals[\tremRate] };
            if(~slTremDepth.notNil) { ~slTremDepth.value = ~ccVals[\tremDepth] };
            if(~slVerbMix.notNil) { ~slVerbMix.value = ~ccVals[\verbMix] };
            if(~slVerbDec.notNil) { ~slVerbDec.value = ~ccVals[\verbDecay] };
            0.05.wait; // 20 fps
        }
    }).play(AppClock);

    ~palmWin.onClose = {
        ~guiRoutine.stop;
        ~palmWin = nil;
        ~slVol1 = nil; ~slVol2 = nil; ~slVol3 = nil; ~slVol4 = nil;
        ~slBassRes = nil; ~slIronDec = nil; ~slFolCut = nil; ~slGlassFb = nil;
        ~slTremRate = nil; ~slTremDepth = nil; ~slVerbMix = nil; ~slVerbDec = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: palmhouse-synth.scd [Block 4]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
if(~guiRoutine.notNil) { ~guiRoutine.stop };

MIDIdef.noteOn(\palmHouseOn).free;
MIDIdef.noteOff(\palmHouseOff).free;
MIDIdef.cc(\mixerCC).free;
MIDIdef.cc(\paramsCC).free;

if(~notes.notNil) {
    ~notes.do({ |synth, i| if(synth.notNil) { synth.set(\gate, 0); } });
    ~notes = nil;
};

if(~monoBassSynth.notNil) {
    ~monoBassSynth.set(\gate, 0);
    ~monoBassSynth = nil;
    ~monoBassNote = nil;
};

~tremoloFx.free;
~reverbFx.free;
~masterFx.free;

~volZone1Bus.free; ~volZone2Bus.free; ~volZone3Bus.free; ~volZone4Bus.free;
~bassResBus.free; ~ironDecayBus.free; ~foliageCutoffBus.free; ~glassFbBus.free;
~tremoloRateBus.free; ~tremoloDepthBus.free; ~verbMixBus.free; ~verbDecayBus.free;

~groupBus.free;
~reverbBus.free;
~masterBus.free;

~synthGroup.free;
~fxGroup.free;
~masterGroup.free;

if(~wtBuf.notNil) { ~wtBuf.free };

"Palm House cleanup complete.".postln;
)

// Source: rossoidae-synth.scd [Block 2]
// MODE: design
// THEME: A. CONTROL BUSES
// KEYWORDS: abyssFx, bpf, buses, control, design, dynklank, gverb, pinknoise, pulse, sinosc, tideFx, zone1_Crevice, zone2_Gravel, zone3_Algae, zone4_Operculum
(
s.options.memSize = 65536; // Increased memory pool to prevent alloc errors
s.boot;

s.waitForBoot({

    // A. CONTROL BUSES
    ~gravelDensityBus = Bus.control(s, 1).set(40);
    ~algaeCurrentBus = Bus.control(s, 1).set(0.5);
    ~tideMixBus = Bus.control(s, 1).set(0.4);
    ~abyssMixBus = Bus.control(s, 1).set(0.5);

    // NEW: Volume Control Buses for the Mixer
    ~volZone1Bus = Bus.control(s, 1).set(1.0);
    ~volZone2Bus = Bus.control(s, 1).set(1.0);
    ~volZone3Bus = Bus.control(s, 1).set(1.0);
    ~volZone4Bus = Bus.control(s, 1).set(1.0);

    // B. AUDIO ROUTING
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~tideBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // C. SYNTHDEFS

    // -- EFFECTS --
    SynthDef(\tideFx, { |out=0, mixBus, inBus|
        var sig = In.ar(inBus, 2);
        var mix = In.kr(mixBus);
        var chorus = DelayC.ar(sig, 0.1, SinOsc.kr(0.2).range(0.01, 0.04));
        var delay = CombC.ar(chorus, 1.0, 0.4, 3.0);
        Out.ar(out, sig + ((delay + chorus) * mix * 0.5));
    }).add;

    SynthDef(\abyssFx, { |out=0, mixBus, inBus|
        var sig = In.ar(inBus, 2);
        var mix = In.kr(mixBus);
        // maxroomsize capped at 100 to prevent massive memory overallocation
        var verb = GVerb.ar(sig.sum, roomsize: 90, revtime: 6.0, damping: 0.9, drylevel: 0, maxroomsize: 100);
        var outSig = (sig * (1 - mix)) + (verb * mix * 0.8);
        Out.ar(out, Limiter.ar(outSig, 0.9, 0.01));
    }).add;

    // -- GENERATORS (Added zoneVol argument to all) --
    SynthDef(\zone1_Crevice, { arg out=0, freq=440, amp=0.5, gate=1, vel=0.5, zoneVol=1.0;
        var laggedFreq = Lag.kr(freq, 0.3);
        var laggedVel = Lag.kr(vel, 0.1);
        var mod = SinOsc.ar(laggedFreq * 0.5) * laggedFreq * 1.5;
        var car = SinOsc.ar(laggedFreq + mod);
        var env = EnvGen.ar(Env.asr(0.3, 1.0, 0.8), gate, doneAction: 2);
        var cutoff = laggedVel.linlin(0, 1, 60, 600);
        var sig = LPF.ar(car, cutoff);
        Out.ar(out, Pan2.ar((sig * 3.0).tanh * env * amp * zoneVol * 1.5, 0));
    }).add;

    SynthDef(\zone2_Gravel, { arg out=0, freq=440, amp=0.5, gate=1, densityBus, zoneVol=1.0;
        var density = In.kr(densityBus);
        var env = EnvGen.ar(Env.asr(0.1, 1.0, 0.4), gate, doneAction: 2);
        var exciter = Dust.ar(density) + (PinkNoise.ar * 0.05);
        var fastLfo = SinOsc.kr(18).range(0.1, 1.0);
        var sig = RHPF.ar(exciter, freq, 0.2) * fastLfo;
        sig = sig.round(0.08);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol * 4.0, 0));
    }).add;

    SynthDef(\zone3_Algae, { arg out=0, freq=440, amp=0.5, gate=1, currentBus, zoneVol=1.0;
        var current = In.kr(currentBus);
        var env = EnvGen.ar(Env.asr(1.2, 1.0, 1.5), gate, doneAction: 2);
        var pwm1 = SinOsc.kr(current).range(0.1, 0.9);
        var pwm2 = SinOsc.kr(current * 0.8).range(0.1, 0.9);
        var sig = Pulse.ar([freq * 0.99, freq * 1.01], [pwm1, pwm2]).sum;
        var bpfSweep = SinOsc.kr(current * 0.4).exprange(freq * 0.6, freq * 3.0);
        sig = BPF.ar(sig, bpfSweep, 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol * 0.7, 0));
    }).add;

    SynthDef(\zone4_Operculum, { arg out=0, freq=440, amp=0.5, gate=1, zoneVol=1.0;
        var env = EnvGen.ar(Env.asr(0.001, 1.0, 0.1), gate, doneAction: 2);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015));
        var freqs = [freq, freq * 2.1, freq * 3.4, freq * 5.2];
        var amps = [1.0, 0.6, 0.3, 0.1];
        var decays = [0.15, 0.08, 0.04, 0.02];
        var sig = DynKlank.ar(`[freqs, amps, decays], exciter);
        sig = BHiShelf.ar(sig, 4000, 1.0, 8);
        Out.ar(out, Pan2.ar(sig * env * amp * zoneVol * 0.5, 0));
    }).add;

    s.sync;


    // D. INSTANTIATE EFFECTS
    ~tideGroupFx = Synth(\tideFx, [
        \out, ~masterBus,
        \inBus, ~tideBus,
        \mixBus, ~tideMixBus
    ], target: ~fxGroup);

    ~abyssMasterFx = Synth(\abyssFx, [
        \out, 0,
        \inBus, ~masterBus,
        \mixBus, ~abyssMixBus
    ], target: ~masterGroup);


    // E. SYNTH STATE & MIDI
    ~rissoidaeNotes = Array.newClear(128);
    ~creviceBass = nil;
    ~creviceNote = nil;

    MIDIdef.cc(\gravelDensityCC, { |val|
        var mapped = val.linlin(0, 127, 5, 150);
        ~gravelDensityBus.set(mapped);
        if(~slGravel.notNil) { defer { ~slGravel.value = mapped } };
    }, ccNum: 71, srcID: ~myUid);

    MIDIdef.cc(\algaeCurrentCC, { |val|
        var mapped = val.linlin(0, 127, 0.1, 5.0);
        ~algaeCurrentBus.set(mapped);
        if(~slAlgae.notNil) { defer { ~slAlgae.value = mapped } };
    }, ccNum: 72, srcID: ~myUid);

    MIDIdef.cc(\tideMixCC, { |val|
        var mapped = val.linlin(0, 127, 0.0, 1.0);
        ~tideMixBus.set(mapped);
        if(~slTide.notNil) { defer { ~slTide.value = mapped } };
    }, ccNum: 73, srcID: ~myUid);

    MIDIdef.cc(\abyssMixCC, { |val|
        var mapped = val.linlin(0, 127, 0.0, 1.0);
        ~abyssMixBus.set(mapped);
        if(~slAbyss.notNil) { defer { ~slAbyss.value = mapped } };
    }, ccNum: 74, srcID: ~myUid);


    MIDIdef.noteOn(\rissoidaeOn, { |velocity, noteNum, channel, src|
        var freq = noteNum.midicps;
        var amp = velocity / 127.0;

        // ZONE 1: Monophonic
        if(noteNum <= 47) {
            if(~creviceBass.isNil) {
                ~creviceBass = Synth(\zone1_Crevice, [
                    \out, ~masterBus, \freq, freq, \amp, amp, \gate, 1, \vel, amp,
                    \zoneVol, ~volZone1Bus.asMap // Map volume bus
                ], target: ~synthGroup);
            } {
                ~creviceBass.set(\freq, freq, \amp, amp, \vel, amp);
            };
            ~creviceNote = noteNum;

        } {
            // Polyphonic Zones
            if(~rissoidaeNotes[noteNum].notNil) { ~rissoidaeNotes[noteNum].set(\gate, 0); };

            ~rissoidaeNotes[noteNum] = case
                { noteNum >= 48 and: { noteNum <= 60 } } {
                    Synth(\zone2_Gravel, [
                        \out, ~tideBus, \freq, freq, \amp, amp, \gate, 1,
                        \densityBus, ~gravelDensityBus, \zoneVol, ~volZone2Bus.asMap
                    ], target: ~synthGroup);
                }
                { noteNum >= 61 and: { noteNum <= 76 } } {
                    Synth(\zone3_Algae, [
                        \out, ~tideBus, \freq, freq, \amp, amp, \gate, 1,
                        \currentBus, ~algaeCurrentBus, \zoneVol, ~volZone3Bus.asMap
                    ], target: ~synthGroup);
                }
                { noteNum >= 77 } {
                    Synth(\zone4_Operculum, [
                        \out, ~masterBus, \freq, freq, \amp, amp, \gate, 1,
                        \zoneVol, ~volZone4Bus.asMap
                    ], target: ~synthGroup);
                };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\rissoidaeOff, { |velocity, noteNum, channel, src|
        if(noteNum <= 47) {
            if(noteNum == ~creviceNote) {
                if(~creviceBass.notNil) {
                    ~creviceBass.set(\gate, 0);
                    ~creviceBass = nil;
                    ~creviceNote = nil;
                };
            };
        } {
            if(~rissoidaeNotes[noteNum].notNil) {
                ~rissoidaeNotes[noteNum].set(\gate, 0);
                ~rissoidaeNotes[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    "Rissoidae Synthesis Engine Initialized. Ready for DAW input.".postln;
});
)

// Source: rossoidae-synth.scd [Block 4]
// MODE: design
// THEME: STEP 5: CLEANUP
// KEYWORDS: cleanup, design, step
(
if(~rissoidaeWin.notNil and: { ~rissoidaeWin.isClosed.not }) { ~rissoidaeWin.close };

MIDIdef.noteOn(\rissoidaeOn).free;
MIDIdef.noteOff(\rissoidaeOff).free;
MIDIdef.cc(\gravelDensityCC).free;
MIDIdef.cc(\algaeCurrentCC).free;
MIDIdef.cc(\tideMixCC).free;
MIDIdef.cc(\abyssMixCC).free;

if(~rissoidaeNotes.notNil) {
    ~rissoidaeNotes.do({ |synth, i| if(synth.notNil) { synth.set(\gate, 0); } });
    ~rissoidaeNotes = nil;
};

if(~creviceBass.notNil) {
    ~creviceBass.set(\gate, 0);
    ~creviceBass = nil;
    ~creviceNote = nil;
};

~tideGroupFx.free;
~abyssMasterFx.free;

~gravelDensityBus.free;
~algaeCurrentBus.free;
~tideMixBus.free;
~abyssMixBus.free;
~volZone1Bus.free;
~volZone2Bus.free;
~volZone3Bus.free;
~volZone4Bus.free;

~tideBus.free;
~masterBus.free;

~synthGroup.free;
~fxGroup.free;
~masterGroup.free;

"Rissoidae cleanup complete: All MIDIdefs, Synths, FX, Buses, Groups, and GUI cleared.".postln;
)

// Source: 2026-11-04_12-01-59.scd [Block 1]
// MODE: design
// THEME: ABYSSAL RUVETTUS (Ruvettus pretiosus) SYNTHESIZER
// KEYWORDS: abyssal, allpassc, combl, design, fold, freeverb2, fx_abyssalReverb, fx_bathyalDelay, fx_masterLimiter, hpf, pretiosus, rlpf, ruvettus, synthesizer, z1_sub, z2_spine, z3_drifter
(
// ==========================================
// ABYSSAL RUVETTUS (Ruvettus pretiosus) SYNTHESIZER
// A Deep-Water Mesopelagic Sound Engine
// ==========================================

// STEP 0: GLOBAL CONFIGURATION (CC MAP)
~cc = (
    // Key Ranges (Min, Max)
    min1: 104, max1: 105,
    min2: 106, max2: 107,
    min3: 108, max3: 109,

    // Mixer (Vol, Pan, Mute)
    vol1: 80, vol2: 81, vol3: 82,
    pan1: 83, pan2: 84, pan3: 85,
    mute1: 100, mute2: 101, mute3: 102,

    // Filters (HPF, LPF, Res)
    hpf1: 86, hpf2: 87, hpf3: 88,
    lpf1: 89, lpf2: 90, lpf3: 91,
    rq1: 92,  rq2: 93,  rq3: 94,

    // ADSR Envelopes
    atk1: 20, dec1: 21, sus1: 22, rls1: 23,
    atk2: 24, dec2: 25, sus2: 26, rls2: 27,
    atk3: 28, dec3: 29, sus3: 30, rls3: 31,

    // Unique Zone FX
    fxPressure: 32, // Zone 1: Hydrostatic Pressure
    fxFriction: 33, // Zone 2: Scale Friction
    fxLipid: 34,    // Zone 3: Lipid Damping

    // Global FX Bus
    delTime: 74, delMix: 75,
    verbDec: 76, verbMix: 77,

    // Master / Panic
    panic: 120
);

// STEP 1 & 2: MIDI INITIALIZATION & DEVICE LOCKING
MIDIClient.init;
// Explicitly target device without connectAll
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    // Fallback 1: Arturia BeatStep Pro (skip secondary MIDIIN2 sysex port)
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    // Fallback 2: Any real external/hardware MIDI device (skip virtual/bridge/system ports)
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

// STEP 3: AUDIO SERVER, ROUTING & SYNTHESIS
s.options.memSize = 131072;
s.waitForBoot({
    // A. INITIAL PARAMETER STATES
    ~ccVals = (
        // Headroom Allocation & Gains
        vol1: 0.30, vol2: 0.18, vol3: 0.22,
        pan1: 0.0,  pan2: -0.35, pan3: 0.35,
        mute1: 0,   mute2: 0,    mute3: 0,

        // Key Ranges (Defaults: Full Overlap across 128 keys)
        min1: 0,   max1: 65,
        min2: 36,  max2: 100,
        min3: 30,  max3: 127,

        // Filters (Frequency Bracketing)
        hpf1: 25,    hpf2: 350,   hpf3: 160,
        lpf1: 180,   lpf2: 6500,  lpf3: 3200,
        rq1: 0.2,    rq2: 0.3,    rq3: 0.25,

        // Envelopes
        atk1: 0.08, dec1: 0.4, sus1: 0.8, rls1: 0.6,
        atk2: 0.01, dec2: 0.2, sus2: 0.1, rls2: 0.35,
        atk3: 0.50, dec3: 1.2, sus3: 0.7, rls3: 1.80,

        // Local Zone FX (Boots to 0.0 clean)
        fxPressure: 0.0,
        fxFriction: 0.0,
        fxLipid: 0.0,

        // Tiered Bus FX (Boots to 0.0 mix)
        delTime: 0.375, delMix: 0.0,
        verbDec: 0.75,  verbMix: 0.0
    );

    // B. CONTROL BUSES
    ~buses = ();
    ~ccVals.keysValuesDo { |key, val|
        ~buses[key] = Bus.control(s, 1).set(val);
    };

    // C. NODE HIERARCHY & AUDIO BUSES
    ~synthGroup  = Group.new(s);
    ~fxGroup     = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus   = Bus.audio(s, 2);
    ~delayBus   = Bus.audio(s, 2);
    ~reverbBus  = Bus.audio(s, 2);
    ~masterBus  = Bus.audio(s, 2);

    // D. SYNTHDEFS

    // Zone 1: Bathypelagic Sub (FM Glissando Bass + Wavefolding Diode Clipper)
    SynthDef(\z1_sub, {
        arg out, freq=55, gate=1, vol=0.3, pan=0.0, mute=0,
            hpf=25, lpf=180, rq=0.2,
            atk=0.08, dec=0.4, sus=0.8, rls=0.6,
            fxPressure=0.0;
        var lagFreq, env, mod, car, sig, drive, foldThresh;

        lagFreq = Lag.kr(freq, 0.2); // Mesopelagic heavy glide
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);

        // 2-Operator FM Foundation
        mod = SinOsc.ar(lagFreq * 0.5) * (lagFreq * 0.75);
        car = SinOsc.ar(lagFreq + mod);

        // Hydrostatic Pressure Wave-Folding (CC 32)
        drive = 1.0 + (fxPressure * 5.0);
        foldThresh = 1.0 - (fxPressure * 0.55);
        sig = Fold.ar(car * drive, foldThresh.neg, foldThresh);

        // Sub Bracketing Filters
        sig = HPF.ar(sig, hpf.clip(10, 500));
        sig = RLPF.ar(sig, lpf.clip(40, 2000), rq.clip(0.05, 1.0));

        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 2: Spiny Dermis (Plucked Comb Delay + Allpass Dispersion Friction)
    SynthDef(\z2_spine, {
        arg out, freq=440, gate=1, vol=0.18, pan=(-0.35), mute=0,
            hpf=350, lpf=6500, rq=0.3,
            atk=0.01, dec=0.2, sus=0.1, rls=0.35,
            fxFriction=0.0;
        var env, exciter, delayTime, sig, left, right;

        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        delayTime = freq.reciprocal.clip(0.0001, 0.05);

        // Tuned Resonant Pluck
        sig = CombL.ar(exciter, 0.05, delayTime, rls * 3.5);

        // Scale Friction: Allpass Dispersion Chain (CC 33)
        sig = AllpassC.ar(sig, 0.02, (fxFriction * 0.008) + 0.0005, 0.08);
        sig = (sig * (1.0 + (fxFriction * 1.5))).softclip;

        // Stereo Decorrelation
        left = HPF.ar(sig, hpf.clip(100, 4000));
        right = HPF.ar(DelayC.ar(sig, 0.01, 0.003), hpf.clip(100, 4000));
        left = RLPF.ar(left, lpf.clip(500, 18000), rq.clip(0.05, 1.0));
        right = RLPF.ar(right, lpf.clip(500, 18000), rq.clip(0.05, 1.0));

        Out.ar(out, Balance2.ar(left, right, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 3: Pelagic Solitude (Morphing Additive Pad + Lipid Damping)
    SynthDef(\z3_drifter, {
        arg out, freq=220, gate=1, vol=0.22, pan=0.35, mute=0,
            hpf=160, lpf=3200, rq=0.25,
            atk=0.5, dec=1.2, sus=0.7, rls=1.8,
            fxLipid=0.0;
        var env, lfo, oscA, oscB, sig, left, right, lipidShelf;

        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        lfo = SinOsc.kr(0.12).range(0.995, 1.005);

        // Dual detuned complex wavetable synthesis
        oscA = Saw.ar(freq * lfo) * 0.5 + Pulse.ar(freq * 0.501, 0.35, 0.4);
        oscB = Saw.ar(freq * (2.0 - lfo)) * 0.5 + Pulse.ar(freq * 0.499, 0.65, 0.4);

        sig = [oscA, oscB];

        // Filtering
        sig = HPF.ar(sig, hpf.clip(40, 3000));
        sig = RLPF.ar(sig, lpf.clip(200, 15000), rq.clip(0.05, 1.0));

        // Lipid Damping: Multi-stage Soft-Saturation Attenuator (CC 34)
        lipidShelf = (1.0 - (fxLipid * 0.75)).clip(0.15, 1.0);
        sig = LPF.ar(sig, (lpf * lipidShelf).clip(150, 18000));
        sig = (sig * (1.0 + (fxLipid * 2.0))).tanh * (1.0 / (1.0 + fxLipid));

        left = sig[0];
        right = sig[1];

        Out.ar(out, Balance2.ar(left, right, pan, env * vol * (1 - mute)));
    }).add;

    // Effects: Bathyal Ping-Pong Delay
    SynthDef(\fx_bathyalDelay, {
        arg in, out, delTime=0.375, delMix=0.0;
        var dry, wet, dL, dR;
        dry = In.ar(in, 2);
        dL = CombC.ar(dry[0] + (LocalIn.ar(2)[1] * 0.4), 1.5, delTime.clip(0.05, 1.4), 3.0);
        dR = CombC.ar(dry[1] + (dL * 0.35), 1.5, (delTime * 1.33).clip(0.05, 1.4), 3.0);
        LocalOut.ar(LPF.ar([dL, dR], 2800));
        wet = [dL, dR];
        Out.ar(out, (dry * (1 - delMix)) + (wet * delMix));
    }).add;

    // Effects: Abyssal Plate/Freeverb
    SynthDef(\fx_abyssalReverb, {
        arg in, out, verbDec=0.75, verbMix=0.0;
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 1.0, verbDec.clip(0.1, 0.98), 0.65);
        Out.ar(out, (sig * (1 - verbMix)) + (wet * verbMix));
    }).add;

    // Effects: Master Safety Limiter
    SynthDef(\fx_masterLimiter, {
        arg in, out=0;
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // E. INSTANTIATE TIERED EFFECTS WITH TAIL ORDERING
    ~delaySynth = Synth(\fx_bathyalDelay, [
        \in, ~groupBus, \out, ~delayBus,
        \delTime, ~buses.delTime.asMap,
        \delMix, ~buses.delMix.asMap
    ], ~fxGroup, \addToTail);

    ~reverbSynth = Synth(\fx_abyssalReverb, [
        \in, ~delayBus, \out, ~masterBus,
        \verbDec, ~buses.verbDec.asMap,
        \verbMix, ~buses.verbMix.asMap
    ], ~fxGroup, \addToTail);

    ~limiterSynth = Synth(\fx_masterLimiter, [
        \in, ~masterBus, \out, 0
    ], ~masterGroup, \addToTail);

    // F. MULTITIMBRAL ALLOCATION & MIDI RESPONDERS
    ~spineNotes = Array.newClear(128);
    ~drifterNotes = Array.newClear(128);
    ~subSynth = nil;
    ~subCurrentNote = nil;

    // CC Processing
    MIDIdef.cc(\ruvettusCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.005, 8.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { kStr.contains("delTime") } { mapped.linexp(0, 1, 0.05, 1.4) }
                    { kStr.contains("verbDec") } { mapped.linlin(0, 1, 0.1, 0.98) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    // Note On Processing
    MIDIdef.noteOn(\ruvettusOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;

        // Zone 1: Bathypelagic Sub (Monophonic with glissando)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            if(~subSynth.isNil) {
                ~subSynth = Synth(\z1_sub, [
                    \out, ~masterBus, \freq, freq, \gate, 1,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxPressure, ~buses.fxPressure.asMap
                ], target: ~synthGroup);
            } {
                ~subSynth.set(\freq, freq, \gate, 1);
            };
            ~subCurrentNote = noteNum;
        };

        // Zone 2: Spiny Dermis (Polyphonic)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~spineNotes[noteNum] = ~spineNotes[noteNum].add(Synth(\z2_spine, [
                \out, ~groupBus, \freq, freq, \gate, 1,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                \fxFriction, ~buses.fxFriction.asMap
            ], target: ~synthGroup));
        };

        // Zone 3: Pelagic Solitude (Polyphonic Pad)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~drifterNotes[noteNum] = ~drifterNotes[noteNum].add(Synth(\z3_drifter, [
                \out, ~groupBus, \freq, freq, \gate, 1,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                \fxLipid, ~buses.fxLipid.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    // Note Off Processing
    MIDIdef.noteOff(\ruvettusOff, { |vel, noteNum|
        // Zone 1 Mono Release
        if(~subCurrentNote == noteNum) {
            if(~subSynth.notNil) {
                ~subSynth.set(\gate, 0);
                ~subSynth = nil;
                ~subCurrentNote = nil;
            };
        };

        // Zone 2 Polyphonic Release
        if(~spineNotes[noteNum].notNil) {
            ~spineNotes[noteNum].do(_.set(\gate, 0));
            ~spineNotes[noteNum] = nil;
        };

        // Zone 3 Polyphonic Release
        if(~drifterNotes[noteNum].notNil) {
            ~drifterNotes[noteNum].do(_.set(\gate, 0));
            ~drifterNotes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    // MIDI Panic CC Listener
    MIDIdef.cc(\ruvettusPanic, { |val|
        if(val > 0) {
            if(~subSynth.notNil) { ~subSynth.set(\gate, 0); ~subSynth = nil; };
            ~spineNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~spineNotes[i] = nil; } };
            ~drifterNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~drifterNotes[i] = nil; } };
            "Abyssal Ruvettus: All Voices Silenced via Panic CC.".postln;
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    "Abyssal Ruvettus Synthesizer Audio Engine Initialized.".postln;


    // STEP 4: PAGINATED GRAPHICAL INTERFACE
defer {
    var makeZoneTab, switchTab;
    var pages = Array.newClear(3);
    var tabButtons = Array.newClear(3);
    var zoneTitles = ["Zone 1: Bathypelagic Sub", "Zone 2: Spiny Dermis", "Zone 3: Pelagic Solitude"];
    var screenBounds, winHeight, winRect;

    if(~ruvWin.notNil and: { ~ruvWin.isClosed.not }) { ~ruvWin.close };
    ~ui = ();

    screenBounds = Window.availableBounds;
    winHeight = min(800, screenBounds.height - 60);
    winRect = Rect(0, 0, 680, winHeight).center_(screenBounds.center);

    ~ruvWin = Window("Abyssal Ruvettus — Mesopelagic Synthesizer", winRect, scroll: true);
    ~ruvWin.view.background = Color.fromHexString("#0A121A"); // Deep oceanic abyss

    // UI Regions
    ~tabContainer = CompositeView(~ruvWin, Rect(20, 15, 640, 40)).decorator_(FlowLayout(Rect(0,0,640,40), 0@0, 8@0));
    ~pagesContainer = CompositeView(~ruvWin, Rect(20, 65, 640, 520));
    ~footerContainer = CompositeView(~ruvWin, Rect(20, 595, 640, 160));

    // Tab Switching Routine
    switchTab = { |idx|
        pages.do { |pg, i| if(pg.notNil) { pg.visible = (i == idx) } };
        tabButtons.do { |btn, i|
            var activeText = if(i == idx, Color.black, Color.white);
            var activeBg = if(i == idx, Color.fromHexString("#4682B4"), Color.gray(0.2)); // Steel blue active
            btn.states_([[zoneTitles[i], activeText, activeBg]]);
        };
    };

    zoneTitles.do { |title, i|
        tabButtons[i] = Button(~tabContainer, 205@36)
            .states_([[title, Color.white, Color.gray(0.25)]])
            .action_({ switchTab.value(i) });
    };

    // Zone Page Builder
    makeZoneTab = { |idx, name, fxName, fxKey|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;

        pref = idx.asString;
        kSize = 85@90;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.95)).decorator_(FlowLayout(box.bounds, 15@15, 14@10)).visible_(false);
        pages[idx-1] = box;

        mKey = ("mute" ++ pref).asSymbol;
        minKey = ("min" ++ pref).asSymbol;
        maxKey = ("max" ++ pref).asSymbol;
        vKey = ("vol" ++ pref).asSymbol;
        pKey = ("pan" ++ pref).asSymbol;
        hKey = ("hpf" ++ pref).asSymbol;
        lKey = ("lpf" ++ pref).asSymbol;
        rKey = ("rq" ++ pref).asSymbol;
        aKey = ("atk" ++ pref).asSymbol;
        dKey = ("dec" ++ pref).asSymbol;
        sKey = ("sus" ++ pref).asSymbol;
        rlsKey = ("rls" ++ pref).asSymbol;

        // Header & Mute Button
        StaticText(box, 430@30).string_(name).stringColor_(Color.fromHexString("#5dade2")).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 160@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(35, 75, 45)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(130, 40, 40)]
        ]).action_({ |b|
            ~buses[mKey].set(b.value);
            ~ccVals[mKey] = b.value;
        });

        // Key Split Bounds Ranger
        ~ui[("range" ++ pref).asSymbol] = EZRanger(box, 600@32, "Keys (CC " ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")",
            [0, 127, \lin, 1, 0], { |sl|
                ~ccVals[minKey] = sl.value[0];
                ~ccVals[maxKey] = sl.value[1];
            }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 140
        ).setColors(stringColor: Color.white);

        // Amplitude Slider
        ~ui[vKey] = EZSlider(box, 600@32, "Volume (CC " ++ ~cc[vKey] ++ ")",
            \amp, { |sl|
                ~buses[vKey].set(sl.value);
                ~ccVals[vKey] = sl.value;
            }, ~ccVals[vKey], labelWidth: 140
        ).setColors(stringColor: Color.white);

        StaticText(box, 600@4).background_(Color.gray(0.25)); // Visual divider

        // Stereo & Filter Knobs
        ~ui[pKey] = EZKnob(box, kSize, "Pan (CC " ++ ~cc[pKey] ++ ")", \bipolar, { |kn|
            ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value;
        }, ~ccVals[pKey]).setColors(stringColor: Color.white);

        ~ui[hKey] = EZKnob(box, kSize, "HPF (CC " ++ ~cc[hKey] ++ ")", ControlSpec(20, 20000, \exp), { |kn|
            ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value;
        }, ~ccVals[hKey]).setColors(stringColor: Color.white);

        ~ui[lKey] = EZKnob(box, kSize, "LPF (CC " ++ ~cc[lKey] ++ ")", ControlSpec(20, 20000, \exp), { |kn|
            ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value;
        }, ~ccVals[lKey]).setColors(stringColor: Color.white);

        ~ui[rKey] = EZKnob(box, kSize, "Res (CC " ++ ~cc[rKey] ++ ")", ControlSpec(1.0, 0.05, \exp), { |kn|
            ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value;
        }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        // Envelope Knobs
        ~ui[aKey] = EZKnob(box, kSize, "A (CC " ++ ~cc[aKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value;
        }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[dKey] = EZKnob(box, kSize, "D (CC " ++ ~cc[dKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value;
        }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[sKey] = EZKnob(box, kSize, "S (CC " ++ ~cc[sKey] ++ ")", \amp, { |kn|
            ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value;
        }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[rlsKey] = EZKnob(box, kSize, "R (CC " ++ ~cc[rlsKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value;
        }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        StaticText(box, 600@4).background_(Color.gray(0.25)); // Visual divider

        // Local Highlighted Signature Effect
        ~ui[fxKey] = EZSlider(box, 600@40, fxName ++ " (CC " ++ ~cc[fxKey] ++ ")",
            \amp, { |sl|
                ~buses[fxKey].set(sl.value);
                ~ccVals[fxKey] = sl.value;
            }, ~ccVals[fxKey], labelWidth: 200
        ).setColors(stringColor: Color.fromHexString("#f39c12"));
    };

    // Construct 3 Tab Pages
    makeZoneTab.value(1, "Zone 1: Bathypelagic Sub", "Hydrostatic Pressure", \fxPressure);
    makeZoneTab.value(2, "Zone 2: Spiny Dermis", "Scale Friction", \fxFriction);
    makeZoneTab.value(3, "Zone 3: Pelagic Solitude", "Lipid Damping", \fxLipid);
    switchTab.value(0);

    // Persistent Footer: Global Multi-Tier FX & Panic
    ~footerContainer.background_(Color.gray(0.08, 0.9)).decorator_(FlowLayout(~footerContainer.bounds, 15@10, 12@8));

    StaticText(~footerContainer, 460@24)
        .string_("BATHYAL DELAY & ABYSSAL REVERB (GLOBAL BUS)")
        .stringColor_(Color.fromHexString("#5dade2"))
        .font_(Font("Arial", 13, true));

    // Panic Button
    Button(~footerContainer, 130@24).states_([
        ["PANIC (CC 120)", Color.white, Color.red(0.55)]
    ]).action_({
        if(~subSynth.notNil) { ~subSynth.set(\gate, 0); ~subSynth = nil; };
        ~spineNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~spineNotes[i] = nil; } };
        ~drifterNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~drifterNotes[i] = nil; } };
        "Panic: All Voices Silenced from GUI.".postln;
    });

    ~ui[\delMix] = EZSlider(~footerContainer, 290@28, "Delay Mix (CC " ++ ~cc[\delMix] ++ ")",
        \amp, { |sl| ~buses.delMix.set(sl.value); ~ccVals[\delMix] = sl.value; }, ~ccVals[\delMix], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\delTime] = EZSlider(~footerContainer, 290@28, "Delay Time (CC " ++ ~cc[\delTime] ++ ")",
        ControlSpec(0.05, 1.4, \exp), { |sl| ~buses.delTime.set(sl.value); ~ccVals[\delTime] = sl.value; }, ~ccVals[\delTime], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\verbMix] = EZSlider(~footerContainer, 290@28, "Verb Mix (CC " ++ ~cc[\verbMix] ++ ")",
        \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\verbDec] = EZSlider(~footerContainer, 290@28, "Verb Decay (CC " ++ ~cc[\verbDec] ++ ")",
        ControlSpec(0.1, 0.98, \lin), { |sl| ~buses.verbDec.set(sl.value); ~ccVals[\verbDec] = sl.value; }, ~ccVals[\verbDec], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ruvWin.front;

    // Asynchronous GUI Poller (20 FPS)
    ~guiRoutine = Routine({
        loop {
            if(~ui.notNil and: { ~ruvWin.isClosed.not }) {
                ~ui.keysValuesDo { |key, widget|
                    var pref;
                    if(widget.notNil) {
                        if(key.asString.contains("range")) {
                            pref = key.asString.last.asString;
                            widget.value = [~ccVals[("min" ++ pref).asSymbol], ~ccVals[("max" ++ pref).asSymbol]];
                        } {
                            widget.value = ~ccVals[key];
                        };
                    };
                };
            };
            0.05.wait;
        };
    }).play(AppClock);

    ~ruvWin.onClose = {
        if(~guiRoutine.notNil) { ~guiRoutine.stop };
        ~ruvWin = nil;
        ~ui = nil;
        "Abyssal Ruvettus GUI Window closed.".postln;
    };
};
});
)

// Source: xappend-museta.scd [Block 1]
// MODE: design
// THEME: ABYSSAL RUVETTUS (Ruvettus pretiosus) SYNTHESIZER
// KEYWORDS: abyssal, allpassc, combl, design, fold, freeverb2, fx_abyssalReverb, fx_bathyalDelay, fx_masterLimiter, hpf, pretiosus, rlpf, ruvettus, synthesizer, z1_sub, z2_spine, z3_drifter
(
// ==========================================
// ABYSSAL RUVETTUS (Ruvettus pretiosus) SYNTHESIZER
// A Deep-Water Mesopelagic Sound Engine
// ==========================================

// STEP 0: GLOBAL CONFIGURATION (CC MAP)
~cc = (
    // Key Ranges (Min, Max)
    min1: 104, max1: 105,
    min2: 106, max2: 107,
    min3: 108, max3: 109,

    // Mixer (Vol, Pan, Mute)
    vol1: 80, vol2: 81, vol3: 82,
    pan1: 83, pan2: 84, pan3: 85,
    mute1: 100, mute2: 101, mute3: 102,

    // Filters (HPF, LPF, Res)
    hpf1: 86, hpf2: 87, hpf3: 88,
    lpf1: 89, lpf2: 90, lpf3: 91,
    rq1: 92,  rq2: 93,  rq3: 94,

    // ADSR Envelopes
    atk1: 20, dec1: 21, sus1: 22, rls1: 23,
    atk2: 24, dec2: 25, sus2: 26, rls2: 27,
    atk3: 28, dec3: 29, sus3: 30, rls3: 31,

    // Unique Zone FX
    fxPressure: 32, // Zone 1: Hydrostatic Pressure
    fxFriction: 33, // Zone 2: Scale Friction
    fxLipid: 34,    // Zone 3: Lipid Damping

    // Global FX Bus
    delTime: 74, delMix: 75,
    verbDec: 76, verbMix: 77,

    // Master / Panic
    panic: 120
);

// STEP 1 & 2: MIDI INITIALIZATION & DEVICE LOCKING
MIDIClient.init;
// Explicitly target device without connectAll
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    // Fallback 1: Arturia BeatStep Pro (skip secondary MIDIIN2 sysex port)
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    // Fallback 2: Any real external/hardware MIDI device (skip virtual/bridge/system ports)
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

// STEP 3: AUDIO SERVER, ROUTING & SYNTHESIS
s.options.memSize = 131072;
s.waitForBoot({
    // A. INITIAL PARAMETER STATES
    ~ccVals = (
        // Headroom Allocation & Gains
        vol1: 0.30, vol2: 0.18, vol3: 0.22,
        pan1: 0.0,  pan2: -0.35, pan3: 0.35,
        mute1: 0,   mute2: 0,    mute3: 0,

        // Key Ranges (Defaults: Full Overlap across 128 keys)
        min1: 0,   max1: 65,
        min2: 36,  max2: 100,
        min3: 30,  max3: 127,

        // Filters (Frequency Bracketing)
        hpf1: 25,    hpf2: 350,   hpf3: 160,
        lpf1: 180,   lpf2: 6500,  lpf3: 3200,
        rq1: 0.2,    rq2: 0.3,    rq3: 0.25,

        // Envelopes
        atk1: 0.08, dec1: 0.4, sus1: 0.8, rls1: 0.6,
        atk2: 0.01, dec2: 0.2, sus2: 0.1, rls2: 0.35,
        atk3: 0.50, dec3: 1.2, sus3: 0.7, rls3: 1.80,

        // Local Zone FX (Boots to 0.0 clean)
        fxPressure: 0.0,
        fxFriction: 0.0,
        fxLipid: 0.0,

        // Tiered Bus FX (Boots to 0.0 mix)
        delTime: 0.375, delMix: 0.0,
        verbDec: 0.75,  verbMix: 0.0
    );

    // B. CONTROL BUSES
    ~buses = ();
    ~ccVals.keysValuesDo { |key, val|
        ~buses[key] = Bus.control(s, 1).set(val);
    };

    // C. NODE HIERARCHY & AUDIO BUSES
    ~synthGroup  = Group.new(s);
    ~fxGroup     = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~groupBus   = Bus.audio(s, 2);
    ~delayBus   = Bus.audio(s, 2);
    ~reverbBus  = Bus.audio(s, 2);
    ~masterBus  = Bus.audio(s, 2);

    // D. SYNTHDEFS

    // Zone 1: Bathypelagic Sub (FM Glissando Bass + Wavefolding Diode Clipper)
    SynthDef(\z1_sub, {
        arg out, freq=55, gate=1, vol=0.3, pan=0.0, mute=0,
            hpf=25, lpf=180, rq=0.2,
            atk=0.08, dec=0.4, sus=0.8, rls=0.6,
            fxPressure=0.0;
        var lagFreq, env, mod, car, sig, drive, foldThresh;

        lagFreq = Lag.kr(freq, 0.2); // Mesopelagic heavy glide
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);

        // 2-Operator FM Foundation
        mod = SinOsc.ar(lagFreq * 0.5) * (lagFreq * 0.75);
        car = SinOsc.ar(lagFreq + mod);

        // Hydrostatic Pressure Wave-Folding (CC 32)
        drive = 1.0 + (fxPressure * 5.0);
        foldThresh = 1.0 - (fxPressure * 0.55);
        sig = Fold.ar(car * drive, foldThresh.neg, foldThresh);

        // Sub Bracketing Filters
        sig = HPF.ar(sig, hpf.clip(10, 500));
        sig = RLPF.ar(sig, lpf.clip(40, 2000), rq.clip(0.05, 1.0));

        Out.ar(out, Pan2.ar(sig, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 2: Spiny Dermis (Plucked Comb Delay + Allpass Dispersion Friction)
    SynthDef(\z2_spine, {
        arg out, freq=440, gate=1, vol=0.18, pan=(-0.35), mute=0,
            hpf=350, lpf=6500, rq=0.3,
            atk=0.01, dec=0.2, sus=0.1, rls=0.35,
            fxFriction=0.0;
        var env, exciter, delayTime, sig, left, right;

        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        delayTime = freq.reciprocal.clip(0.0001, 0.05);

        // Tuned Resonant Pluck
        sig = CombL.ar(exciter, 0.05, delayTime, rls * 3.5);

        // Scale Friction: Allpass Dispersion Chain (CC 33)
        sig = AllpassC.ar(sig, 0.02, (fxFriction * 0.008) + 0.0005, 0.08);
        sig = (sig * (1.0 + (fxFriction * 1.5))).softclip;

        // Stereo Decorrelation
        left = HPF.ar(sig, hpf.clip(100, 4000));
        right = HPF.ar(DelayC.ar(sig, 0.01, 0.003), hpf.clip(100, 4000));
        left = RLPF.ar(left, lpf.clip(500, 18000), rq.clip(0.05, 1.0));
        right = RLPF.ar(right, lpf.clip(500, 18000), rq.clip(0.05, 1.0));

        Out.ar(out, Balance2.ar(left, right, pan, env * vol * (1 - mute)));
    }).add;

    // Zone 3: Pelagic Solitude (Morphing Additive Pad + Lipid Damping)
    SynthDef(\z3_drifter, {
        arg out, freq=220, gate=1, vol=0.22, pan=0.35, mute=0,
            hpf=160, lpf=3200, rq=0.25,
            atk=0.5, dec=1.2, sus=0.7, rls=1.8,
            fxLipid=0.0;
        var env, lfo, oscA, oscB, sig, left, right, lipidShelf;

        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        lfo = SinOsc.kr(0.12).range(0.995, 1.005);

        // Dual detuned complex wavetable synthesis
        oscA = Saw.ar(freq * lfo) * 0.5 + Pulse.ar(freq * 0.501, 0.35, 0.4);
        oscB = Saw.ar(freq * (2.0 - lfo)) * 0.5 + Pulse.ar(freq * 0.499, 0.65, 0.4);

        sig = [oscA, oscB];

        // Filtering
        sig = HPF.ar(sig, hpf.clip(40, 3000));
        sig = RLPF.ar(sig, lpf.clip(200, 15000), rq.clip(0.05, 1.0));

        // Lipid Damping: Multi-stage Soft-Saturation Attenuator (CC 34)
        lipidShelf = (1.0 - (fxLipid * 0.75)).clip(0.15, 1.0);
        sig = LPF.ar(sig, (lpf * lipidShelf).clip(150, 18000));
        sig = (sig * (1.0 + (fxLipid * 2.0))).tanh * (1.0 / (1.0 + fxLipid));

        left = sig[0];
        right = sig[1];

        Out.ar(out, Balance2.ar(left, right, pan, env * vol * (1 - mute)));
    }).add;

    // Effects: Bathyal Ping-Pong Delay
    SynthDef(\fx_bathyalDelay, {
        arg in, out, delTime=0.375, delMix=0.0;
        var dry, wet, dL, dR;
        dry = In.ar(in, 2);
        dL = CombC.ar(dry[0] + (LocalIn.ar(2)[1] * 0.4), 1.5, delTime.clip(0.05, 1.4), 3.0);
        dR = CombC.ar(dry[1] + (dL * 0.35), 1.5, (delTime * 1.33).clip(0.05, 1.4), 3.0);
        LocalOut.ar(LPF.ar([dL, dR], 2800));
        wet = [dL, dR];
        Out.ar(out, (dry * (1 - delMix)) + (wet * delMix));
    }).add;

    // Effects: Abyssal Plate/Freeverb
    SynthDef(\fx_abyssalReverb, {
        arg in, out, verbDec=0.75, verbMix=0.0;
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 1.0, verbDec.clip(0.1, 0.98), 0.65);
        Out.ar(out, (sig * (1 - verbMix)) + (wet * verbMix));
    }).add;

    // Effects: Master Safety Limiter
    SynthDef(\fx_masterLimiter, {
        arg in, out=0;
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.95, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    // E. INSTANTIATE TIERED EFFECTS WITH TAIL ORDERING
    ~delaySynth = Synth(\fx_bathyalDelay, [
        \in, ~groupBus, \out, ~delayBus,
        \delTime, ~buses.delTime.asMap,
        \delMix, ~buses.delMix.asMap
    ], ~fxGroup, \addToTail);

    ~reverbSynth = Synth(\fx_abyssalReverb, [
        \in, ~delayBus, \out, ~masterBus,
        \verbDec, ~buses.verbDec.asMap,
        \verbMix, ~buses.verbMix.asMap
    ], ~fxGroup, \addToTail);

    ~limiterSynth = Synth(\fx_masterLimiter, [
        \in, ~masterBus, \out, 0
    ], ~masterGroup, \addToTail);

    // F. MULTITIMBRAL ALLOCATION & MIDI RESPONDERS
    ~spineNotes = Array.newClear(128);
    ~drifterNotes = Array.newClear(128);
    ~subSynth = nil;
    ~subCurrentNote = nil;

    // CC Processing
    MIDIdef.cc(\ruvettusCC, { |val, num|
        var mapped = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var kStr = key.asString;
                var finalVal = case
                    { kStr.matchRegexp("lpf|hpf") } { mapped.linexp(0, 1, 20, 20000) }
                    { kStr.contains("rq") } { mapped.linexp(0, 1, 1.0, 0.05) }
                    { kStr.contains("pan") } { mapped.linlin(0, 1, -1.0, 1.0) }
                    { kStr.matchRegexp("atk|dec|sus|rls") } { mapped.linexp(0, 1, 0.005, 8.0) }
                    { kStr.matchRegexp("min|max") } { val }
                    { kStr.contains("mute") } { if(val > 63, 1, 0) }
                    { kStr.contains("delTime") } { mapped.linexp(0, 1, 0.05, 1.4) }
                    { kStr.contains("verbDec") } { mapped.linlin(0, 1, 0.1, 0.98) }
                    { mapped };

                ~ccVals[key] = finalVal;
                if(~buses[key].notNil) { ~buses[key].set(finalVal) };
            };
        };
    }, srcID: ~myUid);

    // Note On Processing
    MIDIdef.noteOn(\ruvettusOn, { |velRaw, noteNum|
        var freq = noteNum.midicps;

        // Zone 1: Bathypelagic Sub (Monophonic with glissando)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            if(~subSynth.isNil) {
                ~subSynth = Synth(\z1_sub, [
                    \out, ~masterBus, \freq, freq, \gate, 1,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxPressure, ~buses.fxPressure.asMap
                ], target: ~synthGroup);
            } {
                ~subSynth.set(\freq, freq, \gate, 1);
            };
            ~subCurrentNote = noteNum;
        };

        // Zone 2: Spiny Dermis (Polyphonic)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~spineNotes[noteNum] = ~spineNotes[noteNum].add(Synth(\z2_spine, [
                \out, ~groupBus, \freq, freq, \gate, 1,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                \fxFriction, ~buses.fxFriction.asMap
            ], target: ~synthGroup));
        };

        // Zone 3: Pelagic Solitude (Polyphonic Pad)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~drifterNotes[noteNum] = ~drifterNotes[noteNum].add(Synth(\z3_drifter, [
                \out, ~groupBus, \freq, freq, \gate, 1,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                \fxLipid, ~buses.fxLipid.asMap
            ], target: ~synthGroup));
        };
    }, srcID: ~myUid);

    // Note Off Processing
    MIDIdef.noteOff(\ruvettusOff, { |vel, noteNum|
        // Zone 1 Mono Release
        if(~subCurrentNote == noteNum) {
            if(~subSynth.notNil) {
                ~subSynth.set(\gate, 0);
                ~subSynth = nil;
                ~subCurrentNote = nil;
            };
        };

        // Zone 2 Polyphonic Release
        if(~spineNotes[noteNum].notNil) {
            ~spineNotes[noteNum].do(_.set(\gate, 0));
            ~spineNotes[noteNum] = nil;
        };

        // Zone 3 Polyphonic Release
        if(~drifterNotes[noteNum].notNil) {
            ~drifterNotes[noteNum].do(_.set(\gate, 0));
            ~drifterNotes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    // MIDI Panic CC Listener
    MIDIdef.cc(\ruvettusPanic, { |val|
        if(val > 0) {
            if(~subSynth.notNil) { ~subSynth.set(\gate, 0); ~subSynth = nil; };
            ~spineNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~spineNotes[i] = nil; } };
            ~drifterNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~drifterNotes[i] = nil; } };
            "Abyssal Ruvettus: All Voices Silenced via Panic CC.".postln;
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    "Abyssal Ruvettus Synthesizer Audio Engine Initialized.".postln;


    // STEP 4: PAGINATED GRAPHICAL INTERFACE
defer {
    var makeZoneTab, switchTab;
    var pages = Array.newClear(3);
    var tabButtons = Array.newClear(3);
    var zoneTitles = ["Zone 1: Bathypelagic Sub", "Zone 2: Spiny Dermis", "Zone 3: Pelagic Solitude"];
    var screenBounds, winHeight, winRect;

    if(~ruvWin.notNil and: { ~ruvWin.isClosed.not }) { ~ruvWin.close };
    ~ui = ();

    screenBounds = Window.availableBounds;
    winHeight = min(800, screenBounds.height - 60);
    winRect = Rect(0, 0, 680, winHeight).center_(screenBounds.center);

    ~ruvWin = Window("Abyssal Ruvettus — Mesopelagic Synthesizer", winRect, scroll: true);
    ~ruvWin.view.background = Color.fromHexString("#0A121A"); // Deep oceanic abyss

    // UI Regions
    ~tabContainer = CompositeView(~ruvWin, Rect(20, 15, 640, 40)).decorator_(FlowLayout(Rect(0,0,640,40), 0@0, 8@0));
    ~pagesContainer = CompositeView(~ruvWin, Rect(20, 65, 640, 520));
    ~footerContainer = CompositeView(~ruvWin, Rect(20, 595, 640, 160));

    // Tab Switching Routine
    switchTab = { |idx|
        pages.do { |pg, i| if(pg.notNil) { pg.visible = (i == idx) } };
        tabButtons.do { |btn, i|
            var activeText = if(i == idx, Color.black, Color.white);
            var activeBg = if(i == idx, Color.fromHexString("#4682B4"), Color.gray(0.2)); // Steel blue active
            btn.states_([[zoneTitles[i], activeText, activeBg]]);
        };
    };

    zoneTitles.do { |title, i|
        tabButtons[i] = Button(~tabContainer, 205@36)
            .states_([[title, Color.white, Color.gray(0.25)]])
            .action_({ switchTab.value(i) });
    };

    // Zone Page Builder
    makeZoneTab = { |idx, name, fxName, fxKey|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;

        pref = idx.asString;
        kSize = 85@90;

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.95)).decorator_(FlowLayout(box.bounds, 15@15, 14@10)).visible_(false);
        pages[idx-1] = box;

        mKey = ("mute" ++ pref).asSymbol;
        minKey = ("min" ++ pref).asSymbol;
        maxKey = ("max" ++ pref).asSymbol;
        vKey = ("vol" ++ pref).asSymbol;
        pKey = ("pan" ++ pref).asSymbol;
        hKey = ("hpf" ++ pref).asSymbol;
        lKey = ("lpf" ++ pref).asSymbol;
        rKey = ("rq" ++ pref).asSymbol;
        aKey = ("atk" ++ pref).asSymbol;
        dKey = ("dec" ++ pref).asSymbol;
        sKey = ("sus" ++ pref).asSymbol;
        rlsKey = ("rls" ++ pref).asSymbol;

        // Header & Mute Button
        StaticText(box, 430@30).string_(name).stringColor_(Color.fromHexString("#5dade2")).font_(Font("Arial", 16, true));
        ~ui[mKey] = Button(box, 160@30).states_([
            ["ACTIVE (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(35, 75, 45)],
            ["MUTED (CC " ++ ~cc[mKey] ++ ")", Color.white, Color.new255(130, 40, 40)]
        ]).action_({ |b|
            ~buses[mKey].set(b.value);
            ~ccVals[mKey] = b.value;
        });

        // Key Split Bounds Ranger
        ~ui[("range" ++ pref).asSymbol] = EZRanger(box, 600@32, "Keys (CC " ++ ~cc[minKey] ++ "/" ++ ~cc[maxKey] ++ ")",
            [0, 127, \lin, 1, 0], { |sl|
                ~ccVals[minKey] = sl.value[0];
                ~ccVals[maxKey] = sl.value[1];
            }, [~ccVals[minKey], ~ccVals[maxKey]], labelWidth: 140
        ).setColors(stringColor: Color.white);

        // Amplitude Slider
        ~ui[vKey] = EZSlider(box, 600@32, "Volume (CC " ++ ~cc[vKey] ++ ")",
            \amp, { |sl|
                ~buses[vKey].set(sl.value);
                ~ccVals[vKey] = sl.value;
            }, ~ccVals[vKey], labelWidth: 140
        ).setColors(stringColor: Color.white);

        StaticText(box, 600@4).background_(Color.gray(0.25)); // Visual divider

        // Stereo & Filter Knobs
        ~ui[pKey] = EZKnob(box, kSize, "Pan (CC " ++ ~cc[pKey] ++ ")", \bipolar, { |kn|
            ~buses[pKey].set(kn.value); ~ccVals[pKey] = kn.value;
        }, ~ccVals[pKey]).setColors(stringColor: Color.white);

        ~ui[hKey] = EZKnob(box, kSize, "HPF (CC " ++ ~cc[hKey] ++ ")", ControlSpec(20, 20000, \exp), { |kn|
            ~buses[hKey].set(kn.value); ~ccVals[hKey] = kn.value;
        }, ~ccVals[hKey]).setColors(stringColor: Color.white);

        ~ui[lKey] = EZKnob(box, kSize, "LPF (CC " ++ ~cc[lKey] ++ ")", ControlSpec(20, 20000, \exp), { |kn|
            ~buses[lKey].set(kn.value); ~ccVals[lKey] = kn.value;
        }, ~ccVals[lKey]).setColors(stringColor: Color.white);

        ~ui[rKey] = EZKnob(box, kSize, "Res (CC " ++ ~cc[rKey] ++ ")", ControlSpec(1.0, 0.05, \exp), { |kn|
            ~buses[rKey].set(kn.value); ~ccVals[rKey] = kn.value;
        }, ~ccVals[rKey]).setColors(stringColor: Color.white);

        // Envelope Knobs
        ~ui[aKey] = EZKnob(box, kSize, "A (CC " ++ ~cc[aKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[aKey].set(kn.value); ~ccVals[aKey] = kn.value;
        }, ~ccVals[aKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[dKey] = EZKnob(box, kSize, "D (CC " ++ ~cc[dKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[dKey].set(kn.value); ~ccVals[dKey] = kn.value;
        }, ~ccVals[dKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[sKey] = EZKnob(box, kSize, "S (CC " ++ ~cc[sKey] ++ ")", \amp, { |kn|
            ~buses[sKey].set(kn.value); ~ccVals[sKey] = kn.value;
        }, ~ccVals[sKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        ~ui[rlsKey] = EZKnob(box, kSize, "R (CC " ++ ~cc[rlsKey] ++ ")", ControlSpec(0.005, 8.0, \exp), { |kn|
            ~buses[rlsKey].set(kn.value); ~ccVals[rlsKey] = kn.value;
        }, ~ccVals[rlsKey]).setColors(stringColor: Color.fromHexString("#85e35d"));

        StaticText(box, 600@4).background_(Color.gray(0.25)); // Visual divider

        // Local Highlighted Signature Effect
        ~ui[fxKey] = EZSlider(box, 600@40, fxName ++ " (CC " ++ ~cc[fxKey] ++ ")",
            \amp, { |sl|
                ~buses[fxKey].set(sl.value);
                ~ccVals[fxKey] = sl.value;
            }, ~ccVals[fxKey], labelWidth: 200
        ).setColors(stringColor: Color.fromHexString("#f39c12"));
    };

    // Construct 3 Tab Pages
    makeZoneTab.value(1, "Zone 1: Bathypelagic Sub", "Hydrostatic Pressure", \fxPressure);
    makeZoneTab.value(2, "Zone 2: Spiny Dermis", "Scale Friction", \fxFriction);
    makeZoneTab.value(3, "Zone 3: Pelagic Solitude", "Lipid Damping", \fxLipid);
    switchTab.value(0);

    // Persistent Footer: Global Multi-Tier FX & Panic
    ~footerContainer.background_(Color.gray(0.08, 0.9)).decorator_(FlowLayout(~footerContainer.bounds, 15@10, 12@8));

    StaticText(~footerContainer, 460@24)
        .string_("BATHYAL DELAY & ABYSSAL REVERB (GLOBAL BUS)")
        .stringColor_(Color.fromHexString("#5dade2"))
        .font_(Font("Arial", 13, true));

    // Panic Button
    Button(~footerContainer, 130@24).states_([
        ["PANIC (CC 120)", Color.white, Color.red(0.55)]
    ]).action_({
        if(~subSynth.notNil) { ~subSynth.set(\gate, 0); ~subSynth = nil; };
        ~spineNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~spineNotes[i] = nil; } };
        ~drifterNotes.do { |synths, i| if(synths.notNil) { synths.do(_.set(\gate, 0)); ~drifterNotes[i] = nil; } };
        "Panic: All Voices Silenced from GUI.".postln;
    });

    ~ui[\delMix] = EZSlider(~footerContainer, 290@28, "Delay Mix (CC " ++ ~cc[\delMix] ++ ")",
        \amp, { |sl| ~buses.delMix.set(sl.value); ~ccVals[\delMix] = sl.value; }, ~ccVals[\delMix], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\delTime] = EZSlider(~footerContainer, 290@28, "Delay Time (CC " ++ ~cc[\delTime] ++ ")",
        ControlSpec(0.05, 1.4, \exp), { |sl| ~buses.delTime.set(sl.value); ~ccVals[\delTime] = sl.value; }, ~ccVals[\delTime], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\verbMix] = EZSlider(~footerContainer, 290@28, "Verb Mix (CC " ++ ~cc[\verbMix] ++ ")",
        \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ui[\verbDec] = EZSlider(~footerContainer, 290@28, "Verb Decay (CC " ++ ~cc[\verbDec] ++ ")",
        ControlSpec(0.1, 0.98, \lin), { |sl| ~buses.verbDec.set(sl.value); ~ccVals[\verbDec] = sl.value; }, ~ccVals[\verbDec], labelWidth: 120
    ).setColors(stringColor: Color.white);

    ~ruvWin.front;

    // Asynchronous GUI Poller (20 FPS)
    ~guiRoutine = Routine({
        loop {
            if(~ui.notNil and: { ~ruvWin.isClosed.not }) {
                ~ui.keysValuesDo { |key, widget|
                    var pref;
                    if(widget.notNil) {
                        if(key.asString.contains("range")) {
                            pref = key.asString.last.asString;
                            widget.value = [~ccVals[("min" ++ pref).asSymbol], ~ccVals[("max" ++ pref).asSymbol]];
                        } {
                            widget.value = ~ccVals[key];
                        };
                    };
                };
            };
            0.05.wait;
        };
    }).play(AppClock);

    ~ruvWin.onClose = {
        if(~guiRoutine.notNil) { ~guiRoutine.stop };
        ~ruvWin = nil;
        ~ui = nil;
        "Abyssal Ruvettus GUI Window closed.".postln;
    };
};
});
)


// Source: session_2026-11-18_16-59-58
// MODE: design
// THEME: Ruvettus pretiosus é uma espécie de peixe pertencente à família Gempylidae com distribuição cosmopolita nos oceanos tropicais e temperados. Pode ser encontra...
(
~cc = IdentityDictionary.new;
~ccVals = IdentityDictionary.new;
~buses = IdentityDictionary.new;
~zoneMeta = [
    (title: "Ruvettus — Bathyal body", keys: [\vol1, \pan1, \mute1, \min1, \max1, \hpf1, \lpf1, \rq1, \atk1, \dec1, \sus1, \rls1, \fxPressure]),
    (title: "Ruvettus — Oil-slick dorsal", keys: [\vol2, \pan2, \mute2, \min2, \max2, \hpf2, \lpf2, \rq2, \atk2, \dec2, \sus2, \rls2, \fxIridescence])
];
~zoneMeta.do { |zm|
    zm[\keys].do { |key|
        ~ccVals[key] = case
            { key.asString.contains("vol") } { 0.2 }
            { key.asString.contains("pan") } { if(key == \pan1, 0.0, 0.35) }
            { key.asString.contains("mute") } { 0.0 }
            { key.asString.contains("min") } { if(key == \min1, 0, 36) }
            { key.asString.contains("max") } { if(key == \max1, 72, 127) }
            { key.asString.contains("hpf") } { if(key == \hpf1, 25, 350) }
            { key.asString.contains("lpf") } { if(key == \lpf1, 180, 6500) }
            { key.asString.contains("rq") } { 0.5 }
            { key.asString.contains("atk") } { 0.03 }
            { key.asString.contains("dec") } { 0.35 }
            { key.asString.contains("sus") } { 0.65 }
            { key.asString.contains("rls") } { 0.8 }
            { true } { 0.0 };
    };
};
[\delMix, \verbMix].do { |key| ~ccVals[key] = 0.0 };
~ccVals.keys.do { |key, idx| ~cc[key] = idx + 20 };

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~ruvInDevice = MIDIClient.sources.detect { |src|
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
        label.contains("bmt").not and: { label.contains("bome").not } and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not } and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not } and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };
if(~ruvInDevice.notNil) {
    MIDIIn.connect(0, ~ruvInDevice);
    ("MIDI IN connected to: " ++ ~ruvInDevice.device ++ " (" ++ ~ruvInDevice.name ++ ")").postln;
    ~ruvUid = ~ruvInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~ruvUid = nil;
};

s.waitForBoot({
    var keys, defaults;
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~ruvAudio = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    SynthDef(\ruvBathyal, { |out=0, freq=110, gate=1, vol=0.2, pan=0, mute=0, hpf=25, lpf=180, rq=0.5, atk=0.03, dec=0.35, sus=0.65, rls=0.8, fxPressure=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 0.5, 0, freq * (1 + (fxPressure * 3)));
        sig = SinOsc.ar((freq + mod).max(20)) * 0.7 + SinOsc.ar(freq * 0.5) * 0.3;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq.clip(0.05, 1));
        sig = (sig * (1 + (fxPressure * 3))).tanh;
        Out.ar(out, Pan2.ar(sig, pan, vol * env * (1 - mute)));
    }).add;

    SynthDef(\ruvOilskin, { |out=0, freq=440, gate=1, vol=0.2, pan=0.35, mute=0, hpf=350, lpf=6500, rq=0.5, atk=0.03, dec=0.35, sus=0.65, rls=0.8, fxIridescence=0|
        var env, exc, reson, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.025));
        reson = CombL.ar(exc, 0.05, freq.max(30).reciprocal.clip(0.0001, 0.05), 0.25 + (fxIridescence * 2));
        sig = SinOsc.ar(freq * 2.71, 0, 0.18) + reson;
        sig = AllpassC.ar(sig, 0.02, (fxIridescence * 0.008) + 0.0005, 0.08);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf, rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig, pan, vol * env * (1 - mute)));
    }).add;

    SynthDef(\ruvSpace, { |inbus=0, out=0, delMix=0, verbMix=0|
        var dry, delayed, wet, sig;
        dry = In.ar(inbus, 2);
        delayed = CombL.ar(dry, 1, 0.37, 2.4);
        wet = FreeVerb2.ar(dry[0], dry[1], 1, 0.72, 0.3);
        sig = dry + (delayed * delMix) + (wet * verbMix);
        Out.ar(out, sig);
    }).add;
    SynthDef(\ruvSafety, { |in=0|
        var sig;
        sig = LeakDC.ar(In.ar(in, 2));
        ReplaceOut.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    Synth.tail(~fxGroup, \ruvSpace, [\inbus, ~ruvAudio, \delMix, 0.0, \verbMix, 0.0]);
    Synth.tail(~masterGroup, \ruvSafety, [\in, 0]);
    ~ruvVoices = Array.fill(128, { List.new });

    MIDIdef.cc(\ruvCC, { |val, num|
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
                    { ks.contains("vol") } { norm * 0.35 }
                    { true } { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~ruvUid);
    MIDIdef.noteOn(\ruvOn, { |vel, noteNum|
        var freq;
        freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~ruvVoices[noteNum].add(Synth.head(~synthGroup, \ruvBathyal, [
                \out, ~ruvAudio, \freq, freq, \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap,
                \mute, ~buses[\mute1].asMap, \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap,
                \rq, ~buses[\rq1].asMap, \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap,
                \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap, \fxPressure, ~buses[\fxPressure].asMap
            ]));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~ruvVoices[noteNum].add(Synth.head(~synthGroup, \ruvOilskin, [
                \out, ~ruvAudio, \freq, freq, \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap,
                \mute, ~buses[\mute2].asMap, \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap,
                \rq, ~buses[\rq2].asMap, \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap,
                \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap, \fxIridescence, ~buses[\fxIridescence].asMap
            ]));
        };
    }, srcID: ~ruvUid);
    MIDIdef.noteOff(\ruvOff, { |vel, noteNum|
        ~ruvVoices[noteNum].do { |voice| voice.set(\gate, 0) };
        ~ruvVoices[noteNum].clear;
    }, srcID: ~ruvUid);
    MIDIdef.cc(\ruvPanic, { |val|
        if(val > 0) {
            ~ruvVoices.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; voices.clear };
        };
    }, ccNum: ~cc[\panic] ? 119, srcID: ~ruvUid);

    defer {
        var screen, bounds, width, height, x, y, pages, bottom, pageButtons;
        ~mainWin.tryPerform(\close);
        screen = Window.availableBounds;
        width = 720;
        height = (screen.height - 60).min(780);
        x = screen.left + ((screen.width - width) / 2);
        y = screen.top + ((screen.height - height) / 2);
        ~mainWin = Window("Ruvettus pretiosus — bathyal instrument", Rect(x, y, width, height), scroll: true);
        ~ui = IdentityDictionary.new;
        pages = List.new;
        pageButtons = List.new;
        ~zoneMeta.do { |zm, idx|
            var page, title, row, col, key, label, widget, spec;
            page = CompositeView(~mainWin, Rect(10, 42, width - 30, height - 132));
            pages.add(page);
            page.visible = (idx == 0);
            title = StaticText(page, Rect(12, 6, 550, 24)).string_(zm[\title]);
            zm[\keys].do { |param, k|
                row = (k / 3).floor;
                col = k % 3;
                label = param.asString ++ "  CC" ++ ~cc[param].asString;
                spec = case
                    { param.asString.contains("min") } { [0, 127, \linear, 1, 0] }
                    { param.asString.contains("max") } { [0, 127, \linear, 1, 127] }
                    { param.asString.contains("pan") } { [-1, 1, \linear, 0.01, ~ccVals[param]] }
                    { param.asString.contains("vol") } { [0, 0.35, \linear, 0.005, ~ccVals[param]] }
                    { param.asString.contains("mute") } { [0, 1, \linear, 1, ~ccVals[param]] }
                    { param.asString.contains("hpf") } { [20, 18000, \exp, 1, ~ccVals[param]] }
                    { param.asString.contains("lpf") } { [20, 18000, \exp, 1, ~ccVals[param]] }
                    { param.asString.contains("rq") } { [0.05, 1, \linear, 0.01, ~ccVals[param]] }
                    { param.asString.matchRegexp("atk|dec|sus|rls") } { [0.005, 5, \exp, 0.01, ~ccVals[param]] }
                    { true } { [0, 1, \linear, 0.01, ~ccVals[param]] };
                widget = EZSlider(page, Rect(12 + (col * 225), 42 + (row * 76), 210, 62), label, spec, { |sl|
                    ~ccVals[param] = sl.value;
                    ~buses[param].set(sl.value);
                }, ~ccVals[param], labelWidth: 115, numberWidth: 55);
                ~ui[param] = widget;
            };
            pageButtons.add(Button(~mainWin, Rect(12 + (idx * 170), 8, 160, 28))
                .states_([[zm[\title]]]
                ).action_({ pages.do { |pg| pg.visible = false }; page.visible = true }));
        };
        bottom = CompositeView(~mainWin, Rect(10, height - 76, width - 30, 60));
        EZSlider(bottom, Rect(4, 0, 220, 52), "Delay wet", [0, 1, \linear, 0.01, 0], { |sl|
            ~ccVals[\delMix] = sl.value;
            ~buses[\delMix].set(sl.value);
        }, 0);
        EZSlider(bottom, Rect(235, 0, 220, 52), "Reverb wet", [0, 1, \linear, 0.01, 0], { |sl|
            ~ccVals[\verbMix] = sl.value;
            ~buses[\verbMix].set(sl.value);
        }, 0);
        Button(bottom, Rect(480, 7, 190, 40)).states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({ ~ruvVoices.do { |voices| voices.do { |voice| voice.set(\gate, 0) }; voices.clear } });
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


// Source: session_2026-11-18_18-41-04
// MODE: design
// THEME: Finalize todas as camadas dentro de uma caverna.
(
~cc = (
    vol1: 10, pan1: 11, mute1: 12, min1: 13, max1: 14, hpf1: 15, lpf1: 16, rq1: 17, atk1: 18, dec1: 19, sus1: 20, rls1: 21, fx1: 22,
    vol2: 30, pan2: 31, mute2: 32, min2: 33, max2: 34, hpf2: 35, lpf2: 36, rq2: 37, atk2: 38, dec2: 39, sus2: 40, rls2: 41, fx2: 42,
    vol3: 50, pan3: 51, mute3: 52, min3: 53, max3: 54, hpf3: 55, lpf3: 56, rq3: 57, atk3: 58, dec3: 59, sus3: 60, rls3: 61, fx3: 62,
    delMix: 70, delTime: 71, delFb: 72, verbMix: 73, verbRoom: 74, verbDamp: 75, panic: 123
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

s.waitForBoot({
    ~ccVals = (
        vol1: 0.24, pan1: 0.0, mute1: 0.0, min1: 0, max1: 60, hpf1: 28, lpf1: 220, rq1: 0.45, atk1: 0.04, dec1: 0.35, sus1: 0.75, rls1: 0.8, fx1: 0.0,
        vol2: 0.20, pan2: (-0.32), mute2: 0.0, min2: 36, max2: 100, hpf2: 260, lpf2: 5500, rq2: 0.35, atk2: 0.005, dec2: 0.45, sus2: 0.25, rls2: 0.65, fx2: 0.0,
        vol3: 0.18, pan3: 0.32, mute3: 0.0, min3: 32, max3: 127, hpf3: 180, lpf3: 3800, rq3: 0.5, atk3: 0.45, dec3: 0.6, sus3: 0.8, rls3: 1.8, fx3: 0.0,
        delMix: 0.0, delTime: 0.34, delFb: 0.42, verbMix: 0.0, verbRoom: 0.86, verbDamp: 0.38
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~cavernaBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Zone 1: Subterraneo Telurico (monophonic/polyphonic deep cave sub with mineral fold)
    SynthDef(\cavernaSub, {
        |out=0, freq=55, amp=0.5, gate=1, vol=0.24, pan=0.0, mute=0.0, hpf=28, lpf=220, rq=0.45, atk=0.04, dec=0.35, sus=0.75, rls=0.8, fx=0.0|
        var env, mod, car, folded, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 0.5, 0, freq * (0.25 + (fx * 1.6)));
        car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 0.5) * 0.45);
        folded = Fold.ar(car * (1.0 + (fx * 3.5)), -0.85, 0.85);
        sig = XFade2.ar(car, folded, (fx * 2.0) - 1.0);
        sig = RLPF.ar(sig, lpf.clip(30, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 10000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Estalactite Ressonante (plucked cave stalactite with limestone dispersion)
    SynthDef(\cavernaGota, {
        |out=0, freq=440, amp=0.5, gate=1, vol=0.20, pan=(-0.32), mute=0.0, hpf=260, lpf=5500, rq=0.35, atk=0.005, dec=0.45, sus=0.25, rls=0.65, fx=0.0|
        var env, exc, comb, disp, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.018)) * 0.8;
        comb = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 0.4 + (dec * 2.5));
        disp = AllpassC.ar(comb, 0.025, (fx * 0.009) + 0.0004, 0.12);
        sig = XFade2.ar(comb, disp, (fx * 2.0) - 1.0);
        sig = RLPF.ar(sig, lpf.clip(60, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 3: Eco da Abobada (detuned cavernous choir/wind pad with humidity damping)
    SynthDef(\cavernaAbobada, {
        |out=0, freq=220, amp=0.5, gate=1, vol=0.18, pan=0.32, mute=0.0, hpf=180, lpf=3800, rq=0.5, atk=0.45, dec=0.6, sus=0.8, rls=1.8, fx=0.0|
        var env, detune, osc, dampCut, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        detune = [0.992, 0.997, 1.0, 1.004, 1.009];
        osc = Splay.ar(VarSaw.ar(freq * detune, 0, 0.35 + (fx * 0.35)) * 0.25);
        dampCut = lpf * (1.0 - (fx * 0.55));
        sig = RLPF.ar(osc, dampCut.clip(80, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    // Group Cavern FX & Master Limiter
    SynthDef(\cavernaFX, {
        |inBus=0, out=0, delMix=0.0, delTime=0.34, delFb=0.42, verbMix=0.0, verbRoom=0.86, verbDamp=0.38|
        var dry, del, verb, wet;
        dry = In.ar(inBus, 2);
        del = CombL.ar(dry, 1.2, delTime.clip(0.02, 1.0), (delFb * 4.5).clip(0.1, 5.0));
        wet = XFade2.ar(dry, del, (delMix * 2.0) - 1.0);
        verb = FreeVerb2.ar(wet[0], wet[1], 1.0, verbRoom.clip(0.0, 1.0), verbDamp.clip(0.0, 1.0));
        wet = XFade2.ar(wet, verb, (verbMix * 2.0) - 1.0);
        wet = LeakDC.ar(wet);
        wet = Limiter.ar(wet, 0.92, 0.01);
        Out.ar(out, wet);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \cavernaFX, [
        \inBus, ~cavernaBus.index,
        \out, 0,
        \delMix, ~buses[\delMix].asMap,
        \delTime, ~buses[\delTime].asMap,
        \delFb, ~buses[\delFb].asMap,
        \verbMix, ~buses[\verbMix].asMap,
        \verbRoom, ~buses[\verbRoom].asMap,
        \verbDamp, ~buses[\verbDamp].asMap
    ]);

    ~notes1 = Array.newClear(128);
    ~notes2 = Array.newClear(128);
    ~notes3 = Array.newClear(128);

    ~releaseAll = {
        128.do { |i|
            if(~notes1[i].notNil) { ~notes1[i].do(_.set(\gate, 0)); ~notes1[i] = nil };
            if(~notes2[i].notNil) { ~notes2[i].do(_.set(\gate, 0)); ~notes2[i] = nil };
            if(~notes3[i].notNil) { ~notes3[i].do(_.set(\gate, 0)); ~notes3[i] = nil };
        };
    };

    MIDIdef.noteOn(\cavernaOn, { |vel, noteNum|
        var amp = (vel / 127.0).linlin(0, 1, 0.12, 0.95);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes1[noteNum] = ~notes1[noteNum].add(Synth(\cavernaSub, [
                \out, ~cavernaBus.index, \freq, freq, \amp, amp,
                \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                \fx, ~buses[\fx1].asMap
            ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes2[noteNum] = ~notes2[noteNum].add(Synth(\cavernaGota, [
                \out, ~cavernaBus.index, \freq, freq, \amp, amp,
                \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                \fx, ~buses[\fx2].asMap
            ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes3[noteNum] = ~notes3[noteNum].add(Synth(\cavernaAbobada, [
                \out, ~cavernaBus.index, \freq, freq, \amp, amp,
                \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                \fx, ~buses[\fx3].asMap
            ], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\cavernaOff, { |vel, noteNum|
        if(~notes1[noteNum].notNil) { ~notes1[noteNum].do(_.set(\gate, 0)); ~notes1[noteNum] = nil };
        if(~notes2[noteNum].notNil) { ~notes2[noteNum].do(_.set(\gate, 0)); ~notes2[noteNum] = nil };
        if(~notes3[noteNum].notNil) { ~notes3[noteNum].do(_.set(\gate, 0)); ~notes3[noteNum] = nil };
    }, srcID: ~myUid);

    MIDIdef.cc(\cavernaCC, { |val, num|
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
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\cavernaPanic, { |val|
        if(val == 0) { ~releaseAll.value };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var screen = Window.availableBounds;
        var width = 760;
        var height = min(740, screen.height - 60);
        var pages = List.new;
        var tabBtns = List.new;
        var switchTab;
        var zoneMeta = [
            (title: "1: Subterraneo", idx: 1, fxLabel: "Mineral Fold"),
            (title: "2: Estalactite", idx: 2, fxLabel: "Calcario Disp"),
            (title: "3: Abobada", idx: 3, fxLabel: "Umidade")
        ];

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~ui = ();

        ~mainWin = Window("Caverna - Sintetizador Multitimbral", Rect(
            (screen.width - width) * 0.5,
            (screen.height - height) * 0.5,
            width, height
        ), scroll: true).background_(Color.gray(0.22));

        switchTab = { |activeIdx|
            pages.do { |pg, i| pg.visible = (i == activeIdx) };
            tabBtns.do { |b, i| b.value = if(i == activeIdx, 1, 0) };
        };

        zoneMeta.do { |zm, idx|
            var page = CompositeView(~mainWin, Rect(10, 42, width - 20, height - 155)).background_(Color.gray(0.86));
            var z = zm[\idx];
            var params = [
                [\vol, "Volume", ControlSpec(0, 1, \lin, 0.01)],
                [\pan, "Pan", ControlSpec(-1, 1, \lin, 0.01)],
                [\mute, "Mute (0/1)", ControlSpec(0, 1, \lin, 1)],
                [\min, "Min Note", ControlSpec(0, 127, \lin, 1)],
                [\max, "Max Note", ControlSpec(0, 127, \lin, 1)],
                [\hpf, "HPF (Hz)", ControlSpec(20, 18000, \exp, 1)],
                [\lpf, "LPF (Hz)", ControlSpec(20, 18000, \exp, 1)],
                [\rq, "Resonance", ControlSpec(1.0, 0.05, \exp, 0.01)],
                [\atk, "Attack", ControlSpec(0.005, 5.0, \exp, 0.005)],
                [\dec, "Decay", ControlSpec(0.005, 5.0, \exp, 0.005)],
                [\sus, "Sustain", ControlSpec(0, 1, \lin, 0.01)],
                [\rls, "Release", ControlSpec(0.005, 5.0, \exp, 0.005)],
                [\fx, zm[\fxLabel], ControlSpec(0, 1, \lin, 0.01)]
            ];

            pages.add(page);
            tabBtns.add(
                Button(~mainWin, Rect(10 + (idx * 190), 8, 180, 28))
                    .states_([[zm[\title], Color.black, Color.gray(0.78)], [zm[\title], Color.white, Color(0.2, 0.45, 0.72)]])
                    .action_({ switchTab.value(idx) })
            );

            StaticText(page, Rect(12, 8, 400, 22))
                .string_(zm[\title] ++ " (Zone " ++ z ++ ")")
                .font_(Font("Helvetica", 13, true));

            params.do { |p, pIdx|
                var key = (p[0].asString ++ z).asSymbol;
                var label = p[1] ++ " [CC " ++ ~cc[key] ++ "]";
                var sl = EZSlider(page, Rect(12, 36 + (pIdx * 34), width - 55, 28), label, p[2], { |ez|
                    ~ccVals[key] = ez.value;
                    if(~buses[key].notNil) { ~buses[key].set(ez.value) };
                }, initVal: ~ccVals[key], labelWidth: 165);
                ~ui[key] = sl;
            };
        };

        // Bottom Master Cavern FX & Panic Bar
        [
            [\delMix, "Eco Mix", ControlSpec(0, 1, \lin, 0.01), 10, height - 102],
            [\delTime, "Eco Time", ControlSpec(0.02, 1.0, \exp, 0.01), 10, height - 70],
            [\verbMix, "Cavern Verb", ControlSpec(0, 1, \lin, 0.01), 375, height - 102],
            [\verbRoom, "Cavern Size", ControlSpec(0, 1, \lin, 0.01), 375, height - 70]
        ].do { |item|
            var key = item[0];
            var sl = EZSlider(~mainWin, Rect(item[3], item[4], 355, 26), item[1] ++ " [CC " ++ ~cc[key] ++ "]", item[2], { |ez|
                ~ccVals[key] = ez.value;
                if(~buses[key].notNil) { ~buses[key].set(ez.value) };
            }, initVal: ~ccVals[key], labelWidth: 135);
            sl.setColors(Color.gray(0.22), Color.white);
            ~ui[key] = sl;
        };

        Button(~mainWin, Rect(10, height - 38, width - 20, 28))
            .states_([["PANIC (ALL NOTES OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({ ~releaseAll.value });

        switchTab.value(0);
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
