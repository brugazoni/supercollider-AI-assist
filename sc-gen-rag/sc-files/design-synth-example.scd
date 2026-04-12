// ==========================================
// STEP 1:
// Check the Post Window to find the exact name of your MIDI device.
// ==========================================
MIDIClient.init;

// ==========================================
// STEP 2: CONNECTION
// Paste your device name into the variable below, then evaluate this block.
// ==========================================
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

// ==========================================
// STEP 3: AUDIO SERVER & SYNTHESIS
// Once your MIDI is connected, evaluate this block to boot the server
// and instantiate the polyphonic synth locked to your device.
// ==========================================
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


// ==========================================
// STEP 4: CLEANUP
// Evaluate this block when you are done to stop sounds and free memory.
// ==========================================
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