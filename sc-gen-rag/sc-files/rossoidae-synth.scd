// ==========================================
// STEP 1: DISCOVERY
// ==========================================
MIDIClient.init;

// ==========================================
// STEP 2: CONNECTION
// Paste your single loopMIDI port name below.
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


// ==========================================
// STEP 4: SUPERCOLLIDER GUI
// ==========================================
(
defer {
    if(~rissoidaeWin.notNil and: { ~rissoidaeWin.isClosed.not }) { ~rissoidaeWin.close };

    // Increased window height to accommodate the new mixer sliders
    ~rissoidaeWin = Window("Rissoidae Micro-Benthic Control", Rect(100, 100, 480, 700));
    ~rissoidaeWin.view.decorator = FlowLayout(~rissoidaeWin.view.bounds, 15@15, 0@15);
    ~rissoidaeWin.view.background = Color.fromHexString("#0B1320");

    // --- KEYBOARD ZONES VISUAL GUIDE ---
    StaticText(~rissoidaeWin, 450@25)
        .string_("RISSOIDAE HABITAT ZONES")
        .stringColor_(Color.cyan)
        .font_(Font("Arial", 16, true));

    StaticText(~rissoidaeWin, 450@80)
        .string_(
            "   Zone 1 [ <= 47 ]    Benthonella Sub-Crevice (Mono)\n" ++
            "   Zone 2 [ 48 - 60 ]  Amphirissoa Gravel Scatter\n" ++
            "   Zone 3 [ 61 - 76 ]  Archaschenia Algae Pad\n" ++
            "   Zone 4 [ >= 77 ]    Alvania Operculum Strike"
        )
        .stringColor_(Color.white)
        .font_(Font("Courier", 13, true));

    // --- NEW: ZONE VOLUMES (MIXER) ---
    StaticText(~rissoidaeWin, 450@25)
        .string_("ZONE MIXER VOLUMES")
        .stringColor_(Color.cyan)
        .font_(Font("Arial", 14, true));

    ~slVol1 = EZSlider(~rissoidaeWin, 450@25, "Z1 Crevice Vol", \amp, { |sl|
        ~volZone1Bus.set(sl.value);
    }, 1.0, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~slVol2 = EZSlider(~rissoidaeWin, 450@25, "Z2 Gravel Vol", \amp, { |sl|
        ~volZone2Bus.set(sl.value);
    }, 1.0, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~slVol3 = EZSlider(~rissoidaeWin, 450@25, "Z3 Algae Vol", \amp, { |sl|
        ~volZone3Bus.set(sl.value);
    }, 1.0, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~slVol4 = EZSlider(~rissoidaeWin, 450@25, "Z4 Strike Vol", \amp, { |sl|
        ~volZone4Bus.set(sl.value);
    }, 1.0, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    // --- GUI SLIDERS & CC MAPPINGS ---
    StaticText(~rissoidaeWin, 450@25)
        .string_("LOCAL & GROUP CONTROLS")
        .stringColor_(Color.cyan)
        .font_(Font("Arial", 14, true));

    ~slGravel = EZSlider(~rissoidaeWin, 450@25, "Gravel Density", \freq, { |sl|
        ~gravelDensityBus.set(sl.value);
    }, 40, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~slAlgae = EZSlider(~rissoidaeWin, 450@25, "Algae Current", \amp, { |sl|
        ~algaeCurrentBus.set(sl.value);
    }, 0.5, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~slTide = EZSlider(~rissoidaeWin, 450@25, "Tide Chorus Mix", \amp, { |sl|
        ~tideMixBus.set(sl.value);
    }, 0.4, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    StaticText(~rissoidaeWin, 450@25)
        .string_("GLOBAL EFFECTS")
        .stringColor_(Color.cyan)
        .font_(Font("Arial", 14, true));

    ~slAbyss = EZSlider(~rissoidaeWin, 450@25, "Abyss Reverb", \amp, { |sl|
        ~abyssMixBus.set(sl.value);
    }, 0.5, labelWidth: 100, numberWidth: 50)
        .setColors(stringColor: Color.white, numNormalColor: Color.white, labelBackground: Color.clear);

    ~rissoidaeWin.front;
    ~rissoidaeWin.onClose = {
        ~rissoidaeWin = nil;
        ~slVol1 = nil;
        ~slVol2 = nil;
        ~slVol3 = nil;
        ~slVol4 = nil;
        ~slGravel = nil;
        ~slAlgae = nil;
        ~slTide = nil;
        ~slAbyss = nil;
        "GUI Closed.".postln;
    };
};
)


// ==========================================
// STEP 5: CLEANUP
// ==========================================
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