// E2E Scenario A: The Red Cyclone — Creation & Cross-Cutting Directive
// Model: gemini/gemini-2.5-flash
// Generated: 2026-09-03 12:53:42

// ========= Step 1 =========
//=========
(
// ADD_INSTRUMENT: Introducing a new Ndef for the "crimson cyclone" sound.
// It uses DynKlank for resonant body synthesis, excited by filtered noise,
// with an LFO sweeping the resonance frequency for a swirling "cyclone" effect.
// The `tanh` function adds "rubro" (crimson) saturation.
Ndef(\cyclone, { |freq=50, amp=0.3, pan=0, atk=0.01, rel=1.5, t_trig=1, resonanceFreq=100, spread=1.5, modRate=0.5, drive=1.0|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    var exciterNoise = WhiteNoise.ar(0.05); // Low level noise exciter
    var mod = LFSaw.ar(modRate).range(0.5, 1.5); // LFO for sweeping the resonance
    var currentResonanceFreq = resonanceFreq * mod; // Sweep the base resonance freq

    // Generate DynKlank modes dynamically based on currentResonanceFreq and spread
    var numModes = 16;
    var freqs = Array.fill(numModes, { |i| currentResonanceFreq * (1 + (i * spread/numModes)) });
    var amps = Array.fill(numModes, { |i| 1.0 / (i+1) }); // Decay amplitude for higher modes
    var decays = Array.fill(numModes, { |i| rel * (1 - (i/numModes*0.8)) }); // Shorter decays for higher modes

    var body = DynKlank.ar(
        BPF.ar(exciterNoise, currentResonanceFreq * 2, 0.1), // Noise exciter through BPF
        1, // input gain
        Ref(#[freqs, amps, decays])
    );

    var sig = (body * drive).tanh; // Apply tanh for "rubro" (crimson) saturation
    sig = sig * env * amp;
    Pan2.ar(sig, pan);
}).play;

// ADD_EFFECTS: Attaching a FreeVerb2 to Ndef(\cyclone) for spatial blurring, contributing to the "cyclone" feel.
Ndef(\cyclone)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.9, damp: 0.5) }; // blurring
// TWEAK_EFFECTS: Immediately activating the reverb for an expansive, swirling sound.
Ndef(\cyclone).xset(\wet10, 0.7); // The "cyclone" immediately fills the space
// Ndef(\cyclone).xset(\wet10, 0); // Revert tweak

// ADD_INSTRUMENT: Defining a Pbindef to sequence parameters for the \cyclone Ndef.
Pbindef(\cycloneSeq,
    \instrument, \cyclone, // Specifies the Ndef to control (JITLib will route this via slot)
    \dur, Pseq([2, 2, 4, 1], inf), // Slower, evolving rhythmic pattern for the cyclone
    \degree, Pseq([0, 2, 7, 5], inf), // Simple scale degrees for harmonic movement
    \midinote, Pkey(\degree) + 60, // Convert scale degree to a MIDI note (e.g., C4 for degree 0)
    \freq, Pkey(\midinote).midicps, // Convert MIDI note to frequency in Hz
    \amp, Pwhite(0.2, 0.4, inf), // Varying amplitude for dynamic intensity
    \resonanceFreq, Pseq([50, 70, 90, 60], inf), // Sweeping fundamental resonance for spectral movement
    \spread, Pseq([1.5, 1.8, 1.2], inf), // Varying harmonic spread for timbral changes
    \modRate, Pseq([0.3, 0.5, 0.7, 0.4], inf), // Modulating rate for the cyclone's swirl speed
    \t_trig, 1, // Continuous trigger for the Ndef's EnvGen
    \pan, Pseq([-0.7, 0.7, 0], inf), // Swirling pan for spatial movement
    \legato, 1.0 // Long notes for a continuous, drone-like texture
);

// Route the Pbindef to Ndef(\cyclone)'s control slot for sequencing.
Ndef(\cyclone)[1] = \set -> Pbindef(\cycloneSeq);
)

// ========= Step 2 =========
//=========
(
// 1. Allocate a buffer for the granular source (a short, high-frequency sine wave for shimmering/metallic texture)
~dreamSwarmBuf = Buffer.alloc(s, s.sampleRate * 0.1, 1); // 0.1 seconds long
~dreamSwarmBuf.loadCollection(Array.fill(~dreamSwarmBuf.numFrames, { |i|
    sin(i / ~dreamSwarmBuf.numFrames * 2pi * 1200) // A 1200Hz sine wave as the base for grains
}));

// 2. ADD_INSTRUMENT: Define Ndef(\dreamSwarm) for the "white swarms" and "silver nails"
// This Ndef uses granular synthesis to create shimmering, dense textures.
Ndef(\dreamSwarm, { |freq=880, amp=0.15, pan=0, grainDur=0.03, grainRate=40, posRand=0.8, pitchRand=0.02, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.005, 0.5), t_trig, doneAction: 2); // Overall amplitude envelope for the swarm
    var sig = GrainBuf.ar(
        2, // Stereo output
        Dust.kr(grainRate), // Trigger individual grains at a high rate for a "swarm" effect
        ~dreamSwarmBuf.bufnum, // Use the pre-allocated buffer as the grain source
        rate: freq / 1200 * (1 + (LFNoise1.kr(2).range(-1, 1) * pitchRand)), // Pitch scaling with slight random variation for shimmer
        pos: LFNoise1.kr(1).range(0, 1) * posRand + (1 - posRand) / 2, // Random position within the buffer, controlled by posRand
        dur: grainDur, // Duration of each grain
        pan: LFNoise2.kr(3).range(-1, 1), // Random pan for each grain for spatial diffusion
        maxOverlap: 100 // Allow many grains to overlap to create density
    );
    sig = sig * env * amp; // Apply the overall amplitude envelope
    Pan2.ar(sig, pan);
}).play;

// 3. ADD_INSTRUMENT: Define Pbindef(\dreamSwarmSeq) to control the granular instrument
Pbindef(\dreamSwarmSeq,
    \instrument, \dreamSwarm,
    \dur, Pexprand(0.1, 0.4, inf), // Vague, irregular rhythm for "dreams"
    \degree, Pwhite(10, 18, inf), // High register for "silver nails"
    \midinote, Pkey(\degree) + 60, // Translate degree to midinote, shifted to a higher octave
    \freq, Pkey(\midinote).midicps, // Convert midinote to frequency
    \amp, Pwhite(0.08, 0.18, inf), // Shimmering and varied dynamics
    \grainDur, Pwhite(0.01, 0.05, inf), // Short, varied grain durations for a lively texture
    \grainRate, Pwhite(30.0, 70.0, inf), // Dense swarm, varying grain trigger rate
    \posRand, 0.6, // Moderate position randomness within the buffer
    \pitchRand, Pwhite(0.01, 0.03, inf), // Small pitch variation for shimmer and movement
    \t_trig, 1, // Trigger the Ndef's internal envelope for each note event
    \pan, Pwhite(-0.8, 0.8, inf), // Wider stereo spread for the overall instrument
    \legato, Pwhite(0.5, 0.9, inf) // Sustained but not fully overlapping notes
);

// 4. Route Pbindef(\dreamSwarmSeq) to Ndef(\dreamSwarm)'s first slot
Ndef(\dreamSwarm)[1] = \set -> Pbindef(\dreamSwarmSeq);
)

// ========= Step 3 =========
(
//========= ADD_EFFECTS: Apply spacious cave reverb to Ndef(\cyclone) (Settling/Flashback)
// Replacing FreeVerb2 with GVerb for a larger, more cavernous sound.
Ndef(\cyclone)[10] = \filter -> { |in|
    var input = Mix.new(in); // GVerb expects a mono input
    GVerb.ar(input,
        \roomsize10.kr(70),    // Large room size for spaciousness
        \revtime10.kr(12),     // Long decay time for a deep cave
        \damp10.kr(0.4),       // Moderate damping for a brighter cave
        \inputbw10.kr(0.5),    // Input bandwidth
        \drylevel10.kr(0.2),   // Little dry signal for full immersion
        \earlyreflevel10.kr(0.8), // Prominent early reflections
        \taillevel10.kr(0.8),  // Strong tail
        \maxroomsize10.kr(100)
    )
};
// Ndef(\cyclone)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], \mix10.kr(0.7), \room10.kr(0.8), \damp10.kr(0.5)) }; // Revert tweak

//========= TWEAK_EFFECTS: Set wetness for Ndef(\cyclone) to immerse it in the cave (Settling/Flashback)
Ndef(\cyclone).xset(\wet10, 0.9);
// Ndef(\cyclone).xset(\wet10, 0.7); // Revert tweak

//========= ADD_EFFECTS: Apply spacious cave reverb to Ndef(\dreamSwarm) (Settling/Flashback)
Ndef(\dreamSwarm)[10] = \filter -> { |in|
    var input = Mix.new(in); // GVerb expects a mono input
    GVerb.ar(input,
        \roomsize10.kr(70),    // Large room size for spaciousness
        \revtime10.kr(12),     // Long decay time for a deep cave
        \damp10.kr(0.4),       // Moderate damping for a brighter cave
        \inputbw10.kr(0.5),    // Input bandwidth
        \drylevel10.kr(0.2),   // Little dry signal for full immersion
        \earlyreflevel10.kr(0.8), // Prominent early reflections
        \taillevel10.kr(0.8),  // Strong tail
        \maxroomsize10.kr(100)
    )
};
// Ndef(\dreamSwarm)[10].clear; // Revert tweak

//========= TWEAK_EFFECTS: Set wetness for Ndef(\dreamSwarm) to immerse it in the cave (Settling/Flashback)
Ndef(\dreamSwarm).xset(\wet10, 0.9);
// Ndef(\dreamSwarm).xset(\wet10, 0); // Revert tweak
)

// ========= Step 4 =========
//=========
(
// Settling (c): Gradually fade out the 'cyclone' layer to reduce complexity.
Pbindef(\cycloneSeq).stop;
Ndef(\cyclone).fadeTime = 8; // Set a fade time for a smooth dissolve
Ndef(\cyclone).clear(8); // Clear the Ndef after the fade
)

