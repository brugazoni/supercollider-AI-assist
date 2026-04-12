// =====================================================================
// 1. STARTUP
// =====================================================================
// Boot the audio server before doing anything else.
s.boot;

// Let's define a very simple custom synthesizer to use later.
// Evaluate this block.
(
SynthDef(\ping, { |out=0, freq=440, amp=0.1, pan=0, gate=1, cutoff=2000|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.5), gate, doneAction: 2);
    sig = LPF.ar(Saw.ar(freq), cutoff);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// =====================================================================
// 2. Ndef (NodeProxy Definition)
// =====================================================================
// Ndef is used for continuous audio or control signals.
// Think of it as a virtual mixer channel that you can plug synths into.

// Evaluate this to start playing an Ndef named \drone.
// At first, it's silent because we haven't told it what to play!
Ndef(\drone).play;

// Now, let's plug a sound into it. Evaluate this:
Ndef(\drone, { SinOsc.ar([150, 152]) * 0.1 });

// The magic of Ndef: we can change the sound ON THE FLY without stopping it.
// Evaluate this and hear it crossfade into a new sound.
Ndef(\drone).fadeTime = 2; // Set a 2-second crossfade
Ndef(\drone, { Saw.ar([75, 76]) * LPF.ar(BrownNoise.ar, 400) * 0.2 });

// Stop the drone for now.
Ndef(\drone).stop;


// =====================================================================
// 3. Pbindef (Pattern Bind Definition)
// =====================================================================
// Pbindef is used for sequencing (Event Patterns).
// Like Ndef, it lets you change the sequence on the fly.

// Evaluate this to start a sequence using our \ping SynthDef.
(
Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 2, 4, 5], inf), // Play a simple scale
    \dur, 0.25,                       // 1/4 second per note
    \amp, 0.2
).play;
)

// While it's playing, evaluate this to change just the melody!
Pbindef(\mySeq, \degree, Pseq([0, 7, 5, 4, 2, -1], inf));

// Now change the speed:
Pbindef(\mySeq, \dur, Prand([0.125, 0.25], inf));

// Stop the pattern.
Pbindef(\mySeq).stop;


// =====================================================================
// 4. THE GRAND COMBO: Pbindef inside Ndef + Effect Slots
// =====================================================================
// Here is where it gets incredibly powerful.
// You can route a Pbindef directly into an Ndef.
// This allows you to sequence notes, but process the entire audio
// stream through "Effect Slots" (indexes).

// First, start an Ndef channel and play it.
Ndef(\mainOut).play;

// SLOT 0: The Source.
// We put our Pbindef into slot 0 of the Ndef.
// Note: We don't use .play on the Pbindef here, the Ndef plays it for us!
(
Ndef(\mainOut)[0] = Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 3, 5, 7, 10, 12], inf),
    \dur, 0.25,
    \cutoff, 1500
);
)

// SLOT 1: The First Effect (Delay)
// We use \filter -> { |in| ... } to grab the audio from the previous
// slot (Slot 0) and process it.
(
Ndef(\mainOut)[1] = \filter -> { |in|
    // Mix the dry signal 'in' with a ping-pong delay
    in + CombC.ar(in, 0.5, [0.3, 0.4], 3, 0.5);
};
)

// SLOT 2: The Second Effect (Reverb + Lowpass Filter)
// This grabs the audio from Slot 1 (which now includes the delay).
(
Ndef(\mainOut)[2] = \filter -> { |in|
    var verb = FreeVerb2.ar(in[0], in[1], mix: 0.4, room: 0.8);
    // Add a slow sweeping filter over everything
    RLPF.ar(verb, SinOsc.kr(0.1).exprange(300, 3000), 0.2);
};
)

// HOW TO MANAGE SLOTS:
// You can dynamically change or remove effects without breaking the audio chain!

// Evaluate this to remove the delay (Slot 1):
Ndef(\mainOut)[1] = nil;

// Put a totally different effect into Slot 1 (e.g., distortion):
(
Ndef(\mainOut)[1] = \filter -> { |in|
    (in * 5).tanh * 0.2; // Overdrive
};
)

// And you can still change the sequence playing in Slot 0!
Pbindef(\mySeq, \dur, 0.125, \degree, Pseq([0, 12, 0, 7], inf));

// =====================================================================
// 5. CLEANUP
// =====================================================================
// Clear out the Ndef to stop sound and free server memory.
Ndef(\mainOut).clear;