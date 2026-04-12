// ==========================================
// STEP 1: DISCOVERY
// ==========================================
MIDIClient.init;

// Boot sound to ensure server is alive (optional)
{SinOsc.ar(440, 0, 0.1) * EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2)}.play;

// ==========================================
// STEP 2: CONNECTION
// Paste your specific target device name below.
// ==========================================
(
var inDeviceName = "loopMIDI Port";

~myInDevice = MIDIClient.sources.detect { |src| src.device == inDeviceName };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    "MIDI IN connected successfully to: ".post; ~myInDevice.device.postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: MIDI IN device not found!".warn;
    ~myUid = nil;
};
)

// ==========================================
// STEP 3: AUDIO SERVER, ROUTING & SYNTHESIS
// ==========================================
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


// ==========================================
// STEP 4: SUPERCOLLIDER GUI
// ==========================================
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


// ==========================================
// STEP 5: CLEANUP
// ==========================================
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