// E2E Scenario A: The Red Cyclone — Creation & Cross-Cutting Directive
// Model: gemini/gemini-2.5-flash
// Generated: 2026-09-04 12:36:14

// ========= Step 1 =========
(
// ADD_INSTRUMENT: The crimson cyclone arrives at your head
Ndef(\cyclone, { |freq=50, amp=0.3, pan=0, atk=0.01, dec=0.5, sus=0.5, rel=1.0,
                  cutoff=1200, res=0.6, drive=0.8, modFreq=0.5, modDepth=0.3,
                  detune=0.002, t_trig=1|
    var env = EnvGen.ar(Env.adsr(atk, dec, sus, rel), K2A.ar(t_trig));
    // SuperSaw-like detuned saws for a thick, dense sound
    var osc = Splay.ar(Saw.ar(freq * [1 - detune, 1, 1 + detune]));
    // Moog-style filter with LFO modulation for swirling motion
    var lfo = SinOsc.kr(modFreq).range(1 - modDepth, 1 + modDepth);
    var filtered = MoogFF.ar(osc, cutoff * lfo, res);
    // Distortion for "crimson" and aggressive feel
    var distorted = Fold.ar(filtered * drive, -0.8, 0.8);
    Pan2.ar(distorted * env * amp, pan);
}).play;

// ADD_EFFECTS: Phaser for swirling "cyclone" motion
Ndef(\cyclone)[10] = \filter -> { |in|
    Phaser.ar(in, rate: 1.2, depth: 0.5, feedback: 0.8, mix: 1.0);
};
Ndef(\cyclone).xset(\wet10, 0); // Initialize wetness to 0

// ADD_INSTRUMENT: Sequence for the cyclone's arrival
Pbindef(\cycloneSeq,
    \dur, Pseq([1.0, 0.5, 1.0, 0.5, 0.75, 0.75], inf), // Driving, slightly varied rhythm
    \degree, Pseq([0, 5, 7, 12, 7, 5], inf) + 36, // Low, powerful melodic fragments (C3 scale)
    \freq, Pfunc { |e| e.degree.midicps },
    \amp, Pwhite(0.2, 0.4, inf), // Dynamic amplitude variation
    \pan, Pseq([-0.7, 0.7, 0, -0.5, 0.5], inf), // Panning movement for spatialization
    \cutoff, Pwhite(800, 3000, inf), // Varied filter cutoff for timbral shifts
    \res, Pwhite(0.5, 0.8, inf), // Resonance to emphasize filtering
    \drive, Pwhite(0.8, 1.5, inf), // Variable distortion amount
    \modFreq, Pwhite(0.4, 0.8, inf), // LFO frequency for filter modulation
    \modDepth, Pwhite(0.2, 0.5, inf), // LFO depth for filter modulation
    \t_trig, 1 // Trigger for the Ndef's envelope
);

// Inject the Pbindef into the Ndef's slot for sequencing
Ndef(\cyclone)[1] = \set -> Pbindef(\cycloneSeq);
Pbindef(\cycloneSeq).play;
)

// ========= Step 2 =========
(
// ADD_INSTRUMENT: Silver Grains / Dream Swarm
// Prompt: "Implora a enxames brancos de seus sonhos vagos, mãos de unhas cor de prata."
// This Ndef uses granular synthesis to create a shimmering, ethereal cloud of sound ("enxames brancos", "sonhos vagos").
// The higher pitches and subtle pitch variation aim for the "prata" (silver) quality.

// Allocate a buffer for granular synthesis, using a simple sine wave as source.
// This allows for a pure, dreamy base that can be modulated for shimmer.
Buffer.freeAll; // Clear any previously allocated buffers to prevent conflicts
~silverBuf = Buffer.alloc(s, s.sampleRate * 1.0, 1, { |buf|
    buf.data = Signal.sineFill(buf.numFrames, 1, [1.0]); // A simple sine wave
});

Ndef(\silverGrains, { |freq=880, amp=0.2, pan=0, t_trig=0,
                        grainDensity=100, grainDur=0.05,
                        posSpread=0.5, pitchSpread=0.05|
    var env = EnvGen.ar(Env.perc(0.01, 1.5, 1, -4), t_trig, doneAction: 0); // Long, dreamy release envelope
    var grainTrig = Dust.ar(grainDensity * env); // Triggers individual grains, gated by the main envelope
    var rateRand = TRand.ar(1 - pitchSpread, 1 + pitchSpread, grainTrig); // Randomize pitch slightly for shimmer
    var posRand = TRand.ar(0.0, 1.0, grainTrig); // Randomize grain start position in buffer
    var panRand = TRand.ar(-1.0, 1.0, grainTrig) * posSpread; // Randomize pan for spatial "swarm" effect

    var sig = GrainBuf.ar(
        numChannels: 2,
        trigger: grainTrig,
        dur: grainDur,
        sndBuf: ~silverBuf,
        rate: freq / 440 * rateRand, // Base freq scaled and modulated by random pitch spread
        pos: posRand,
        interp: 2, // Linear interpolation for smoothness
        pan: pan + panRand, // Base pan with random spread
        envbuf: -1 // Use internal Hann window for grains
    );
    sig = sig * amp * env;
    Out.ar(0, sig); // Output stereo signal
}).play;

// ADD_EFFECTS: Reverb for "vague dreams" and spatial depth
// Initializing wetness to 0. The user can activate it later.
Ndef(\silverGrains)[10] = \filter -> { |in| FreeVerb.ar(in, mix: 1.0, room: 0.9, damp: 0.5) }; // Lush reverb
Ndef(\silverGrains).xset(\wet10, 0); // Revert tweak: Ndef(\silverGrains).xset(\wet10, 0);

// ADD_INSTRUMENT (Pbindef): Sequence for \silverGrains
// This sequence provides the "vague" and "shimmering" movements for the granular swarm.
Pbindef(\silverSeq,
    \instrument, \silverGrains, // Link to the Ndef
    \dur, Pseq([2, 1.5, 3, 2.5], inf), // Slow, evolving rhythmic pacing for dreaminess
    \degree, Pseq([0, 7, 12, 19, 24, 12, 7, 0] + 12, inf), // Higher pitches for "silver" and ethereal feel
    \amp, Pwhite(0.05, 0.15, inf), // Soft, varying amplitude
    \t_trig, 1, // Trigger the Ndef's main envelope for each note
    \grainDensity, Pseq([150, 200, 100, 250], inf), // Varying swarm density
    \grainDur, Pseq([0.03, 0.06, 0.04, 0.07], inf), // Varying grain duration
    \posSpread, Pseq([0.3, 0.6, 0.4, 0.7], inf), // Position randomization for "vague" spatial movement
    \pitchSpread, Pseq([0.01, 0.03, 0.005, 0.02], inf), // Subtle pitch spread for "shimmer"
    \pan, Pseq([-0.7, 0.7, 0], inf) // Panning across the stereo field
).play;
)

// ========= Step 3 =========
(
// ADD_EFFECTS: Initiating Settling/Flashback with spacious cave reverb across all Ndefs.
Ndef(\cyclone)[11] = \filter -> { |in|
    GVerb.ar(in, room: 1.0, reverbtime: 10.0, damp: 0.5, drylevel: 0.0, earlylevel: 0.7, taillevel: 1.0);
};
Ndef(\cyclone).xset(\wet11, 0.8); // Activating spacious cave reverb for \cyclone
// Ndef(\cyclone).xset(\wet11, 0); // Revert tweak
// Ndef(\cyclone)[11] = nil; // Revert effect

Ndef(\silverGrains)[11] = \filter -> { |in|
    GVerb.ar(in, room: 1.0, reverbtime: 10.0, damp: 0.5, drylevel: 0.0, earlylevel: 0.7, taillevel: 1.0);
};
Ndef(\silverGrains).xset(\wet11, 0.8); // Activating spacious cave reverb for \silverGrains
// Ndef(\silverGrains).xset(\wet11, 0); // Revert tweak
// Ndef(\silverGrains)[11] = nil; // Revert effect
)

// ========= Step 4 =========
(
// FADE_OUT: Silencing \cyclone layers to initiate a settling phase.
Pbindef(\cycloneSeq).stop;
Ndef(\cyclone).fadeTime = 5;
Ndef(\cyclone).clear(5);
)

