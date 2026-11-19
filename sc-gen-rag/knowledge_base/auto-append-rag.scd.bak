// Source: append-baru-volcano-FIXED.scd
(
// 1. Volcanic Tectonic Rumble
Ndef(\baruBase, { |freq=55, rumble=4, amp=0.8, pan=0, t_shock=0, shockAmp=0.5|
    var shockEnv = EnvGen.ar(Env.perc(0.05, 4.0, curve: -4), t_shock);
    var noise = LFNoise1.ar(rumble) + PinkNoise.ar(0.5); // Boosted noise input
    var resFreq = freq * (1 + (shockEnv * 1.2));

    // Lowered the rq slightly to let more sound through, boosted makeup gain
    var sig = Resonz.ar(noise, resFreq, 0.4) * 6.0;

    // Added a slight harmonic so it translates to smaller speakers
    var sub = SinOsc.ar(freq * (1 - (shockEnv * 0.08))) * 0.7;
    var subHarmonic = SinOsc.ar(freq * 2) * 0.3;

    var out = (sig + sub + subHarmonic) * (1 + (shockEnv * shockAmp));
    out = LeakDC.ar(tanh(out * 1.3));
    Pan2.ar(out * amp, pan);
}).play;

// 2. High-Altitude Canopy & Wind
Ndef(\baruCanopy, { |freq=2200, rq=0.015, amp=0.5, pan=(-0.8), t_trig=0|
    var env = EnvGen.ar(Env.perc(0.3, 2.5), t_trig);
    var noise = WhiteNoise.ar(0.2) + PinkNoise.ar(0.2);

    // BPF needs massive makeup gain when rq is this low (multiplier increased to 12)
    var sig = BPF.ar(noise, freq * LFNoise2.kr(0.5).range(0.85, 1.15), rq) * 12.0;

    var ring = DynKlank.ar(
        Ref([ [freq, freq * 1.25, freq * 1.5], [0.3, 0.15, 0.1], [0.4, 0.3, 0.2] ]),
        PinkNoise.ar(0.05), // Boosted exciter
        decayscale: env + 0.05
    );
    var out = sig + (ring * env);
    Pan2.ar(out * amp, pan);
}).play;

// 3. Cloud Delay Effect
Ndef(\baruCanopy)[10] = \filter -> { |in|
    in + CombC.ar(in, 0.5, LFNoise1.kr(0.15).range(0.25, 0.45), 4.0);
};
Ndef(\baruCanopy).set(\wet10, 0.4); // Actually turn the delay up so you can hear it!

// 4. Idiomatic JITLib Sequencing for the Rumble
Ndef(\baruBase)[1] = \set -> Pbind(
    \args, #[\t_shock, \freq, \rumble, \shockAmp, \pan],
    \dur, Pwhite(4.0, 9.0, inf),
    \t_shock, 1,
    \freq, Pwhite(45.0, 65.0, inf),
    \rumble, Pwhite(3.0, 10.0, inf),
    \shockAmp, Pwhite(0.5, 0.9, inf),
    \pan, Pwhite(-0.2, 0.2, inf)
);

// 5. Idiomatic JITLib Sequencing for the Canopy
Ndef(\baruCanopy)[1] = \set -> Pbind(
    \args, #[\t_trig, \freq, \rq, \pan],
    \dur, Pseq([0.5, 1.5, 2.0, 1.0, 3.0], inf),
    \t_trig, 1,
    \freq, Pwhite(1500, 3200, inf),
    \rq, Pwhite(0.008, 0.02, inf),
    \pan, Pwhite(-0.95, -0.6, inf)
);
)

// Source: append-bird-bat-crater.scd
(
// ADD_INSTRUMENT: Ndef(\rearmouse)
// Represents Vespertilio murinus (parti-coloured bat) with high-frequency dual-tone FM sweeps.
Ndef(\rearmouse, { |freq=14000, amp=0.1, pan=0, atk=0.001, rel=0.04, sweep=0.6, color=0.5, t_trig=0|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);

    // FM sweep: starts high, sweeps down. Triggered via t_trig.
    var sweepEnv = EnvGen.ar(Env([3.0, 1.0], [1.0], \exp), t_trig, timeScale: rel * sweep);
    var f1 = freq * sweepEnv;
    var f2 = (freq * 0.55) * sweepEnv; // Lower "parti-coloured" component

    var osc1 = SinOsc.ar(f1);
    var osc2 = SinOsc.ar(f2);

    // Mix the two spectral components (color: 0 = low, 1 = high)
    var sig = XFade2.ar(osc2, osc1, color * 2 - 1);

    // High-frequency echolocation click transient
    var click = HPF.ar(PinkNoise.ar(0.15), 10000) * EnvGen.ar(Env.perc(0.001, 0.004), t_trig);

    sig = (sig + click) * env * amp;
    Pan2.ar(sig, pan);
}).play;

// SEQUENCE: Pbindef(\rearmouseSeq)
// Sequences rapid echolocation chirps and alternating two-tone social calls.
Ndef(\rearmouse)[1] = \set -> Pbindef(\rearmouseSeq,
    \dur, Pseq([0.06, 0.06, 0.12, 0.24, 0.06, 0.12], inf),
    \t_trig, 1,
    \freq, Pexprand(10000, 15000, inf),
    \sweep, Pwhite(0.3, 0.7, inf),
    \color, Pseq([0.2, 0.8, 0.4, 0.9, 0.3, 0.7], inf), // Alternating spectral balance
    \atk, 0.001,
    \rel, Pwhite(0.02, 0.08, inf),
    \amp, Pwhite(0.06, 0.14, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);

// ADD_EFFECTS: Echolocation reflection delay
Ndef(\rearmouse)[10] = \filter -> { |in|
    var delayTime = \delay.kr(0.06).clip(0.001, 0.2);
    var decayTime = \decay.kr(1.2).clip(0.01, 5.0);
    CombC.ar(in, 0.2, delayTime, decayTime);
};
Ndef(\rearmouse).xset(\wet10, 0); // Initialize wetness to 0

// TWEAK_SEQUENCE: Shift the rearmouse sequence to represent the autumn "twittering call".
// Lowering the frequencies into the human-audible range (3kHz - 6kHz) and altering durations to form a rhythmic twittering.
// This implements a Settling/Flashback (c) archetype, transforming the sparse ultrasonic clicks into a dense social texture.
Pbindef(\rearmouseSeq,
    \freq, Pexprand(3000, 6000, inf),
    \dur, Pseq([0.08, 0.04, 0.04, 0.16, 0.08], inf),
    \color, Pwhite(0.1, 0.5, inf)
);
// Pbindef(\rearmouseSeq, \freq, Pexprand(10000, 15000, inf)); // Revert sequence
// Pbindef(\rearmouseSeq, \dur, Pseq([0.06, 0.06, 0.12, 0.24, 0.06, 0.12], inf)); // Revert sequence
// Pbindef(\rearmouseSeq, \color, Pseq([0.2, 0.8, 0.4, 0.9, 0.3, 0.7], inf)); // Revert sequence

// TWEAK_EFFECTS: Activate the echolocation reflection delay to simulate the bat hunting and communicating in a forested environment.
Ndef(\rearmouse).xset(\delay, 0.04, \decay, 0.8);
// Ndef(\rearmouse).xset(\delay, 0.06, \decay, 1.2); // Revert tweak
Ndef(\rearmouse).xset(\wet10, 0.4);
// Ndef(\rearmouse).xset(\wet10, 0); // Revert tweak

// ADD_INSTRUMENT: Ndef(\giiwas)
// Represents the immense depth (594m) and sacred, crystalline blue of Giiwas (Crater Lake).
// Uses a resonant DynKlank bank to simulate the pure, cold, deep water column and volcanic basalt.
Ndef(\giiwas, { |freq=55, amp=0.2, pan=0, t_trig=0, decay=6.0|
    var env = EnvGen.ar(Env.perc(0.01, decay), t_trig);
    var exciter = PinkNoise.ar(0.015) * env;

    // Pure, crystalline resonant frequencies of the water column
    var freqs = [1, 2.001, 3.01, 4.05, 5.08, 8.12] * freq;
    var amps = [1.0, 0.6, 0.4, 0.3, 0.15, 0.08];
    var rings = [5.0, 4.0, 3.0, 2.5, 1.5, 0.8];

    var klank = DynKlank.ar(`[freqs, amps, rings], exciter, decayscale: decay);

    // A deep, sub-bass fundamental to represent the volcanic roots of Mount Mazama
    var sub = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.1, decay * 1.5), t_trig) * 0.4;

    var sig = klank + sub;
    Pan2.ar(sig * amp, pan);
}).play;

// SEQUENCE: Pbindef(\giiwasSeq)
// Sequences slow, deep, seismic pulses echoing through the caldera.
Ndef(\giiwas)[1] = \set -> Pbindef(\giiwasSeq,
    \dur, Pseq([6, 4, 8, 6], inf),
    \t_trig, 1,
    \freq, Pseq([55, 48.99, 65.41, 36.71], inf), // G, F, C, D (deep volcanic tones)
    \decay, Pwhite(5.0, 10.0, inf),
    \amp, 0.3,
    \pan, Pwhite(-0.2, 0.2, inf)
);

// ADD_EFFECTS: Vast caldera space reverb
// Simulates the immense open air and icy rim of Crater Lake in winter.
Ndef(\giiwas)[10] = \filter -> { |in|
    FreeVerb.ar(in, mix: 1.0, room: 0.95, damp: 0.15);
};
Ndef(\giiwas).xset(\wet10, 0); // Initialize wetness to 0

// TWEAK_EFFECTS: Fade in the caldera reverb to establish the vast, cold space.
Ndef(\giiwas).xset(\wet10, 0.6);
// Ndef(\giiwas).xset(\wet10, 0); // Revert tweak

// TWEAK_SEQUENCE: Transition the rearmouse sequence to represent frozen, icy air.
// Driving the frequency to its extreme high limits (Intrinsic Limit (b)) to simulate freezing wind.
Pbindef(\rearmouseSeq,
    \freq, Pexprand(14000, 19000, inf),
    \dur, Pseq([0.12, 0.24, 0.48], inf),
    \amp, Pwhite(0.02, 0.05, inf)
);
// Pbindef(\rearmouseSeq, \freq, Pexprand(3000, 6000, inf)); // Revert sequence
// Pbindef(\rearmouseSeq, \dur, Pseq([0.08, 0.04, 0.04, 0.16, 0.08], inf)); // Revert sequence
// Pbindef(\rearmouseSeq, \amp, Pwhite(0.06, 0.14, inf)); // Revert sequence
)

// Source: append-elephant.scd
(
Corrected for Ndef architecture

Ndef(\elephantRumble, { |freq=45, amp=0.3, pan=0, t_trig=0, cutoff=200, res=3.5, trumpet=0.2|
    // 1. Removed the 'gate' argument.
    // 2. Removed the ASR envelope. Ndef handles overall fading automatically!

    var triggerEnv = EnvGen.kr(Env.perc(0.08, 1.8, curve: -4), t_trig);

    // Sub-bass (with first-octave harmonic to ensure audibility on standard monitors)
    var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.6);

    // Mid-range heavy growl / trumpet simulation
    var pulseWidth = SinOsc.kr(0.15).range(0.35, 0.65);
    var voice = Pulse.ar(freq * [0.98, 1.02], pulseWidth) + Saw.ar(freq * 1.5);

    // High resonance Moog filter with dynamic sweep and makeup gain
    var filteredVoice = MoogFF.ar(voice, cutoff * (1 + (triggerEnv * 2.5)), res);
    var distortedVoice = (filteredVoice * 5.0).tanh * 0.35;

    var mix = (sub * 0.8) + (distortedVoice * trumpet);

    // 3. Removed the 'env' multiplication
    var sig = LeakDC.ar(mix) * amp;

    Splay.ar(sig, 0.5, center: pan);
}).play;

// ADD_EFFECTS: Spatial "savanna" blurring reverb in slot 10
Ndef(\elephantRumble)[10] = \filter -> { |in|
    var local = in + LocalIn.ar(2);
    local = DelayC.ar(local, 0.2, [0.12, 0.15]);
    LocalOut.ar(local * 0.45);
    HPF.ar(local, 90) * 0.7;
};
Ndef(\elephantRumble).set(\wet10, 0); // Initialized to 0 (dry)

// Native JITLib set-role mapping to Pbindef for sequencing
Ndef(\elephantRumble)[1] = \set -> Pbindef(\elephantSeq,
    \dur, Pseq([2.0, 1.0, 3.0, 2.0, 4.0], inf),
    \midinote, Pseq([36, 36, 41, 39, 34], inf),
    \freq, Pkey(\midinote).midicps,
    \t_trig, 1, // Triggers the perc envelope for the filter sweep
    \cutoff, Pkey(\midinote).midicps * Pwhite(2.0, 4.5, inf),
    \trumpet, Pseq([0.15, 0.4, 0.2, 0.5, 0.1], inf),
    \amp, Pwhite(0.25, 0.4, inf),
    \pan, Pseq([-0.3, 0.3, 0.0], inf)
);

// --- Sound Sources (Ndefs) ---

// The "Elephant": Heavy, low-frequency, saturated analog-style bass
Ndef(\elephant, { |freq=45, amp=0.5, cutoff=120, res=2.0, t_trig=0, pan=0|
	var env = EnvGen.ar(Env.perc(0.02, 1.5), t_trig);
	var filterEnv = EnvGen.ar(Env.perc(0.01, 0.8), t_trig);
	// Detuned oscillators + sub-bass
	var osc = Splay.ar(Saw.ar(freq * [0.99, 1.0, 1.01])) * 0.6;
	var sub = SinOsc.ar(freq * 0.5) * 0.8;
	var sig = osc + sub;
	// Resonant lowpass filtering
	sig = MoogFF.ar(sig, (cutoff * filterEnv.linexp(0, 1, 1, 6)).clip(20, 20000), res);
	sig = (sig * 2.5).tanh; // Saturation for weight
	sig = LeakDC.ar(sig);
	Pan2.ar(sig * env * amp, pan);
}).play;

// The "Percussion": Agile, transient-rich, metallic/noise-based dialogue partner
Ndef(\perch, { |freq=300, amp=0.4, decay=0.08, tone=3.0, noiseWet=0.5, t_trig=0, pan=0|
	var env = EnvGen.ar(Env.perc(0.002, decay), t_trig);
	var pitchEnv = EnvGen.ar(Env.perc(0.001, 0.02), t_trig);
	// Pitch-swept sine for the transient "knock"
	var knock = SinOsc.ar(freq * (1 + (pitchEnv * tone)));
	// Bandpassed noise for texture and "fizz" (with makeup gain for narrow BPF)
	var noise = BPF.ar(WhiteNoise.ar(), freq * 4, 0.15) * 12.0;
	var sig = (knock * (1 - noiseWet)) + (noise * noiseWet);
	sig = sig.clip2(1.0); // Mild digital clipping for edge
	Pan2.ar(sig * env * amp, pan);
}).play;


// --- Sequences (Pbindefs) ---

// Heavy, syncopated elephant steps
Pbindef(\elephantSeq,
	\type, \set,
	\id, Ndef(\elephant).group,
	\args, [\t_trig, \freq, \cutoff, \amp],
	\t_trig, 1,
	\dur, Pseq([1.5, 1.0, 1.5, 4.0], inf),
	\midinote, Pseq([36, 36, 39, 31], inf), // Low C, C, D#, G
	\freq, Pkey(\midinote).midicps,
	\cutoff, Pseq([130, 180, 220, 100], inf),
	\amp, 0.6
).play;

// Agile, conversational percussive elements dancing around the steps
Pbindef(\perchSeq,
	\type, \set,
	\id, Ndef(\perch).group,
	\args, [\t_trig, \freq, \decay, \tone, \noiseWet, \pan, \amp],
	\t_trig, 1,
	\dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.125, 0.125, 0.75], inf),
	\freq, Pseq([120, 350, 900, 180, 500, 80, 2000, 1500, 95], inf),
	\decay, Pseq([0.15, 0.08, 0.04, 0.12, 0.06, 0.25, 0.02, 0.03, 0.3], inf),
	\tone, Pseq([3.0, 1.5, 0.2, 2.5, 0.8, 4.0, 0.1, 0.1, 5.0], inf),
	\noiseWet, Pseq([0.3, 0.5, 0.8, 0.4, 0.6, 0.2, 0.9, 0.9, 0.1], inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\amp, Pseq([0.3, 0.2, 0.15, 0.25, 0.2, 0.35, 0.1, 0.1, 0.4], inf) * 0.8
).play;

// 1. SOUND SOURCES (Ndefs)
// Representing the warm, tactile, low-frequency interactions of elephants

// Low, resonant sliding hums representing trunk stroking and wrapping
Ndef(\trunkStroke, { |freq=80, amp=0.35, pan=0, t_trig=0, rq=0.06, morph=0.4|
    var env = EnvGen.ar(Env.perc(0.1, 2.0), t_trig);
    var osc1 = Saw.ar(freq * [0.99, 1.01]).sum;
    var osc2 = Pulse.ar(freq * 0.5, 0.35);
    var sig = SelectX.ar(morph, [osc1, osc2]);
    // Bandpass filter with high makeup gain to compensate for narrow bandwidth
    var filtered = BPF.ar(sig, freq * EnvGen.kr(Env([1, 1.8, 0.95], [0.15, 1.8], \exp), t_trig), rq) * 14.0;
    Pan2.ar(filtered.tanh * env * amp, pan);
}).play;

// Heavy, sudden low-frequency thuds representing disciplining kicks, slaps, and shoves
Ndef(\slapKick, { |freq=48, amp=0.6, pan=(-0.2), t_trig=0|
    var env = EnvGen.ar(Env.perc(0.005, 0.5, 1, -4), t_trig);
    var pEnv = EnvGen.ar(Env.perc(0.001, 0.06, 1, -8), t_trig);
    var sig = SinOsc.ar(freq + (pEnv * 90));
    sig = (sig * 1.8).tanh;
    sig = LPF.ar(sig, 180);
    Pan2.ar(sig * env * amp, pan);
}).play;

// Delicate, high-frequency textured clicks representing mouth/gland touching for chemical cues
Ndef(\chemTouch, { |freq=3200, amp=0.18, pan=0.3, t_trig=0, rq=0.015|
    var env = EnvGen.ar(Env.perc(0.001, 0.15, 1, -6), t_trig);
    var noise = WhiteNoise.ar;
    // Narrow bandpass filter with aggressive makeup gain for organic tactile friction
    var sig = BPF.ar(noise, freq * EnvGen.kr(Env([1.6, 1, 0.75], [0.03, 0.12]), t_trig), rq) * 18.0;
    Pan2.ar(sig * env * amp, pan);
}).play;


// 2. EFFECTS CHAINS (Ndef Slots)
// Initializing spatial/temporal blurring to simulate a vast savannah environment

Ndef(\trunkStroke)[10] = \filter -> { |in| FreeVerb.ar(in, 0.5, 0.85, 0.6) };
Ndef(\trunkStroke).set(\wet10, 0.25); // Subtle acoustic space

Ndef(\chemTouch)[10] = \filter -> { |in|
    // Soft stereo slapback delay to emulate physical proximity and reflections
    DelayC.ar(in, 0.2, [0.08, 0.11], 0.3) + in
};
Ndef(\chemTouch).set(\wet10, 0.4);


// 3. SEQUENCING (Pbindefs)
// Driving the narrative interactions of the elephant group

// Rhythmic, sliding trunk-strokes (gentle, breathing cadence)
Pbindef(\strokeSeq,
    \type, \set,
    \id, Ndef(\trunkStroke).group,
    \args, [\t_trig, \freq, \amp, \morph, \pan],
    \t_trig, 1,
    \dur, Pseq([1.5, 2.5, 3.0, 2.0], inf),
    \midinote, Pseq([36, 40, 38, 43], inf),
    \freq, Pkey(\midinote).midicps,
    \morph, Pwhite(0.2, 0.6, inf),
    \amp, Pwhite(0.25, 0.4, inf),
    \pan, Pwhite(-0.4, 0.4, inf)
).play;

// Sparse, sudden disciplinary slaps and shoves (irregular, authoritative)
Pbindef(\kickSeq,
    \type, \set,
    \id, Ndef(\slapKick).group,
    \args, [\t_trig, \freq, \amp, \pan],
    \t_trig, 1,
    \dur, Pseq([4.0, 5.5, 2.5, 6.0], inf), // Sparse and unpredictable
    \freq, Pwhite(42, 52, inf),
    \amp, Pseq([0.5, 0.7, 0.4, 0.8], inf),
    \pan, Pseq([-0.3, -0.1, -0.4], inf)
).play;

// Rapid, fluttering tactile/chemical exploration (excited, high-density)
Pbindef(\touchSeq,
    \type, \set,
    \id, Ndef(\chemTouch).group,
    \args, [\t_trig, \freq, \amp, \pan],
    \t_trig, 1,
    \dur, Pseq([
        Pseq([0.1, 0.12, 0.08, 0.15], 3), // Bursts of touching
        Prand([1.0, 1.5, 2.0], 1)         // Pauses to process cues
    ], inf),
    \freq, Pwhite(2800, 3800, inf),
    \amp, Pwhite(0.12, 0.22, inf),
    \pan, Pwhite(0.1, 0.6, inf)
).play;

// 1. Define the final resolving instrument (Resolution / Settling)
Ndef(\resonance, { |freq=220, amp=0.15, pan=0, t_trig=0, decay=5.0|
    // Exciter: soft pink noise burst + gentle impulse
    var env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
    var exc = PinkNoise.ar(0.01) * env;

    // Multichannel modal expansion (stereo)
    var sig = [1.0, 1.005].collect({ |detune|
        var freqs = freq * detune * [1, 1.2, 1.5, 1.875, 2.25, 3.0]; // Major 9th harmonic series
        var amps = [1.0, 0.6, 0.4, 0.3, 0.15, 0.08];
        var rings = decay * [1.0, 0.9, 0.8, 0.6, 0.4, 0.2];
        DynKlank.ar(`[freqs, amps, rings], exc)
    });

    sig = LeakDC.ar(sig);
    Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

// 2. Attach a spacious, blurring reverb effect (Settling / Resolution)
Ndef(\resonance)[10] = \filter -> { |in|
    var sig = in;
    // 6-stage stereo allpass diffusion for lush decay
    6.do {
        sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4.0);
    };
    sig;
};
Ndef(\resonance).set(\wet10, 0.6);

// 3. Sequence the final resolving chord progression (Resolution (a))
Pbindef(\resSeq,
    \type, \set,
    \id, Ndef(\resonance).group,
    \args, [\t_trig, \freq, \decay, \pan],

    \t_trig, 1,
    \dur, Pseq([2.0, 2.0, 3.0, 4.0, 8.0], 1), // Rhythmic deceleration (Settling)
    \midinote, Pseq([57, 62, 64, 67, 60], 1), // Tension (Am7 -> D7 -> Em -> G7) to Resolution (Cmaj)
    \decay, Pseq([4.0, 5.0, 6.0, 8.0, 12.0], 1), // Final note rings out the longest
    \pan, Pseq([-0.5, 0.5, -0.25, 0.25, 0.0], 1)
).play;

// 4. Extrinsic Limit (d): Schedule the final fade-out to absolute silence
fork {
    // Total duration of the sequence is 2+2+3+4+8 = 19 seconds
    19.wait;

    // Smoothly fade out the effect wetness first to dry the resolution
    Ndef(\resonance).xset(\wet10, 0.0);
    // Ndef(\resonance).xset(\wet10, 0.6); // Revert tweak

    4.wait;

    // Stop the sequence and clear the synthesizer with a long, elegant fade
    Pbindef(\resSeq).stop;
    // Pbindef(\resSeq).play; // Revert sequence stop

    Ndef(\resonance).fadeTime = 12.0;
    Ndef(\resonance).clear(12.0);
};
)

// Source: append-gallium.scd
(
// 1. Bauxite & Zinc Ore Drone: Soft, warm, but metallic-tinted background
Ndef(\bauxiteDrone, { |amp=0.12, cutoff=250, rq=0.1, detune=0.01|
	var osc, filter, metal, sig;
	osc = Splay.ar(Saw.ar([48, 48.2, 96, 96.3, 144] * (1 + (LFNoise1.kr(0.05) * detune))));
	filter = BPF.ar(osc, cutoff * LFNoise1.kr(0.1).exprange(0.9, 1.1), rq);
	// High resonant frequencies representing trace metallic elements
	metal = Ringz.ar(filter, [960, 1440, 1920], 0.1).sum * 0.03;
	sig = (filter * 0.7) + metal;
	sig * amp;
}).play;

// 2. Gallium Glass: Highly resonant, physical modeling of conchoidal metal/glass fractures
Ndef(\galliumGlass, { |freq=1000, amp=0.15, pan=0, coef=0.15, decay=1.5, t_trig=0|
	var env, noise, sig, ring;
	env = EnvGen.ar(Env.perc(0.0005, 0.01), t_trig);
	noise = WhiteNoise.ar(0.3) * env;
	// Pluck physical model for glassy/metallic impact
	sig = Pluck.ar(noise, t_trig, 0.02, freq.reciprocal.clip(0.0001, 0.02), decay, coef);
	// Conchoidal glassy ring
	ring = Ringz.ar(sig, freq * 3.14, 0.05) * 0.15;
	sig = (sig + ring) * amp;
	Pan2.ar(sig, pan);
}).play;

// 3. Silvery Space Effect: Comb delay and reverberation for the glassy fractures
Ndef(\galliumGlass)[10] = \filter -> { |in|
	var delay, verb;
	delay = CombC.ar(in, 0.2, [0.11, 0.17], 2.0);
	verb = FreeVerb.ar(in + (delay * 0.25), 0.6, 0.85, 0.4);
	in + (verb * 0.5);
};
Ndef(\galliumGlass).set(\wet10, 0); // Initializing wetness to 0 as per instructions

// 4. Sequence: Crystalline, fracturing glass patterns
Pbindef(\glassSeq,
	\type, \set,
	\id, Ndef(\galliumGlass).group,
	\args, #[\t_trig, \freq, \amp, \coef, \decay, \pan],
	\t_trig, 1,
	\dur, Prand([0.125, 0.25, 0.5, 1.0], inf),
	\midinote, Pseq([74, 81, 86, 88, 91, 95], inf) + Pwrand([0, 12, -12], [0.7, 0.2, 0.1], inf),
	\freq, Pkey(\midinote).midicps,
	\coef, Pwhite(0.05, 0.4, inf), // Varies damping to mimic varying fracture surfaces
	\decay, Pwhite(0.5, 2.0, inf),
	\amp, Pwhite(0.08, 0.2, inf),
	\pan, Pwhite(-0.7, 0.7, inf)
).play;

// 1. Define the Wood Surface Ndef using physical modeling (Pluck + Resonators)
Ndef(\woodSurface, { |freq=120, amp=0.4, pan=0, coef=0.6, decay=0.15, t_trig=0|
	var env, exciter, pluck, body, sig;

	// Fast, organic excitation burst
	env = EnvGen.ar(Env.perc(0.001, 0.04), t_trig);
	exciter = HPF.ar(PinkNoise.ar(0.9), 350) * env;

	// Pluck model simulating the strike/tap on a wooden plate
	pluck = Pluck.ar(exciter, t_trig, 0.2, freq.reciprocal.clip(0.001, 0.2), decay, coef);

	// Low-Q bandpass resonators mimicking the hollow body of a wooden surface
	body = Resonz.ar(pluck, [115, 230, 345], 0.2).sum * 1.6;

	sig = (pluck * 0.5) + (body * 0.5);
	sig = LeakDC.ar(sig);

	Pan2.ar(sig * amp, pan);
}).play;

// 2. Sequence the Wood Surface with a dry, tactile tapping pattern
Pbindef(\woodSeq,
	\type, \set,
	\id, Ndef(\woodSurface).group,
	\args, [\t_trig, \freq, \amp, \coef, \decay, \pan],

	\t_trig, 1,
	\dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25], inf), // Grounding, tactile rhythm
	\midinote, Pseq([45, 45, 48, 45, 50, 41], inf),
	\freq, Pkey(\midinote).midicps,
	\coef, Pwhite(0.55, 0.75, inf), // High coefficient limits high frequencies, emphasizing wood damping
	\decay, Pwhite(0.08, 0.18, inf), // Short decay times for dry, wooden impacts
	\amp, Pwhite(0.3, 0.5, inf),
	\pan, Pwhite(-0.3, 0.3, inf)
).play;
)

// Source: auto-append-arppegio.scd
(
Ndef(\sineArp, { |freq=440, amp=0.2, pan=0, atk=0.005, rel=0.1, detune=0.002, t_trig=0|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    // Three sine waves, slightly detuned for a fuller sound
    var sig = Splay.ar(SinOsc.ar(freq * [1, 1 + detune, 1 - detune]));
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\sineArpSeq,
    \type, \set,
    \id, Ndef(\sineArp).group,
    \args, [\t_trig, \amp, \pan, \detune], // Explicitly declare custom args
    \instrument, \sineArp, // Name for Pbindef to associate with Ndef
    \dur, Pseq([0.125, 0.125, 0.0625, 0.125], inf), // Fast arpeggio rhythm
    \degree, Pseq([0, 2, 4, 7, 9, 12, 11, 7], inf), // Arpeggio pattern
    \legato, 0.8,
    \amp, Pwhite(0.1, 0.25, inf),
    \t_trig, 1, // Trigger the envelope for each note
    \pan, Pwhite(-0.8, 0.8, inf),
    \detune, Pseq([0.001, 0.002, 0.003], inf) // Vary detune slightly
).play;

// ADD_INSTRUMENT: Introduce a new bass instrument with a triangle wave, filtered for warmth.
Ndef(\bass, { |freq=50, amp=0.3, pan=0, atk=0.01, rel=0.5, t_trig=0, cutoff=1500, rq=0.3| // Removed unused gate arg to fix override error
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    var osc = LFTri.ar(freq); // Triangle oscillator
    var sig = RLPF.ar(osc, cutoff, rq); // Resonant Low Pass Filter for bass character
    Pan2.ar(sig * env * amp, pan);
}).play;

// ADD_INSTRUMENT: Sequence the bass Ndef with a simple, foundational rhythm.
Pbindef(\bassLine,
    \type, \set,
    \id, Ndef(\bass).group,
    \args, [\t_trig, \amp, \pan, \cutoff, \freq], // Explicitly declare custom arguments
    \t_trig, 1,
    \degree, Pseq([0, 0, 7, 5, 0, 0, 2, 3], inf), // Simple root movement
    \octave, 3, // Keep it in the bass register
    \dur, Pseq([0.5, 0.5, 1, 1, 0.5, 0.5, 1, 1], inf),
    \amp, 0.2,
    \pan, Pseq([-0.3, 0.3, 0], inf), // Fixed invalid .coin.neg on pattern
    \cutoff, Pexprand(600, 1200, inf), // Slightly varying cutoff for texture
    \rq, 0.2 // Consistent resonance
).play;

// Set a driving electronic tempo
TempoClock.default.tempo = 130 / 60;

// --- NDEFS (Sound Sources) ---

// ADD_INSTRUMENT: Kick Drum
Ndef(\kick, { |freq=55, atk=0.005, rel=0.3, amp=0.7, pan=0, t_trig=0, sweep=5|
    // Fast pitch envelope for the 'click' and punch
    var pitchEnv = EnvGen.ar(Env.perc(0.001, 0.05, curve: -8), t_trig);
    // Amplitude envelope
    var env = EnvGen.ar(Env.perc(atk, rel, curve: -4), t_trig);

    // Core sine oscillator with pitch sweep
    var sig = SinOsc.ar(freq * (1 + (pitchEnv * sweep)));
    // Add a tiny noise burst for the transient
    var click = BPF.ar(WhiteNoise.ar, 1500, 2) * EnvGen.ar(Env.perc(0.001, 0.01), t_trig) * 0.3;

    // Combine and apply slight saturation for electronic warmth
    sig = (sig + click).tanh;

    Pan2.ar(sig * env * amp, pan);
}).play;

// ADD_INSTRUMENT: Snare Drum
Ndef(\snare, { |freq=180, atk=0.005, rel=0.25, amp=0.5, pan=0, t_trig=0, snappy=0.8|
    // Tonal body envelope
    var envTone = EnvGen.ar(Env.perc(atk, rel, curve: -4), t_trig);
    // Noise tail envelope (slightly longer)
    var envNoise = EnvGen.ar(Env.perc(atk, rel * 1.5, curve: -2), t_trig);

    // Tonal body (punch)
    var tone = SinOsc.ar(freq * (1 + (EnvGen.ar(Env.perc(0.001, 0.02), t_trig) * 2))) * envTone;
    // Noise tail (rattle)
    var noise = BPF.ar(WhiteNoise.ar, 2500, 1.5) * envNoise * snappy;

    var sig = (tone + noise).clip2(1.0); // Hard clip for aggressive electronic tone
    Pan2.ar(sig * amp, pan);
}).play;

// ADD_INSTRUMENT: Hi-Hat
Ndef(\hat, { |atk=0.005, rel=0.05, amp=0.3, pan=0, t_trig=0, cutoff=7000|
    var env = EnvGen.ar(Env.perc(atk, rel, curve: -6), t_trig);
    // High-passed noise for metallic sizzle
    var sig = HPF.ar(WhiteNoise.ar, cutoff);
    Pan2.ar(sig * env * amp, pan);
}).play;


// --- PBINDEFS (Sequences) ---

// 4-to-the-floor kick pattern
Pbindef(\seqKick,
    \type, \set,
    \id, Ndef(\kick).group,
    \args, [\t_trig, \amp, \rel, \sweep, \freq],
    \t_trig, 1,
    \dur, 0.5,
    \freq, 55,
    \sweep, 5,
    \rel, 0.3,
    \amp, 0.7
).play;

// Backbeat snare pattern
Pbindef(\seqSnare,
    \type, \set,
    \id, Ndef(\snare).group,
    \args, [\t_trig, \amp, \snappy],
    \t_trig, 1,
    \dur, 1,
    \timingOffset, 0.5, // Shift to the offbeats (2 and 4)
    \snappy, Pwhite(0.7, 0.9, inf), // Slight humanization of the noise tail
    \amp, 0.5
).play;

// 16th note hi-hat pattern with dynamic accents (simulating open/closed)
Pbindef(\seqHat,
    \type, \set,
    \id, Ndef(\hat).group,
    \args, [\t_trig, \amp, \rel, \pan, \cutoff],
    \t_trig, 1,
    \dur, 0.25,
    // Accent the offbeats
    \amp, Pseq([0.1, 0.05, 0.25, 0.05], inf),
    // Longer release on the offbeats for an "open hat" feel
    \rel, Pseq([0.05, 0.03, 0.15, 0.03], inf),
    \cutoff, Pwhite(7000, 8000, inf),
    \pan, Pwhite(-0.1, 0.1, inf)
).play;

Ndef(\bass, { |freq=55, amp=0.5, t_trig=0, cutoff=800, res=0.2, decay=0.3, pan=0|
    var env = EnvGen.kr(Env.perc(0.01, decay), t_trig);
    var osc = Saw.ar(freq) + Pulse.ar(freq / 2, 0.5);
    var sig = MoogFF.ar(osc, cutoff * (1 + (env * 2)), res * 4);
    sig = LeakDC.ar((sig * 1.8).tanh);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\bassSeq,
    \type, \set,
    \id, Pfunc { Ndef(\bass).group }, // Pfunc waits until playback to find the group
    \args, [\freq, \t_trig, \amp, \cutoff, \res, \decay, \pan], // \freq added

    \t_trig, 1,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
    \scale, Scale.minor,
    \octave, 2,
    \degree, Pseq([0, 0, 2, -2, 0], inf),

    \amp, 0.4,
    \cutoff, Pwhite(400, 1200, inf),
    \res, 0.3,
    \decay, Pseq([0.2, 0.1, 0.4, 0.1, 0.2], inf),
    \pan, 0
).play(quant: 1);
)

// Source: auto-append-bosque.scd
(
// --- 1. Sound Sources (Ndefs) ---

// The "bed of grass and crushed flowers" - a textured, low, warm pad with organic noise
Ndef(\grassBed, { |freq=110, amp=0.25, pan=0, cutoff=800, rq=0.4, t_trig=0, atk=2, rel=4|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    // Detuned sawtooths for the bed of grass
    var osc = Splay.ar(Saw.ar(freq * [0.99, 1.0, 1.01] * [1, 2, 0.5]));
    // Bandpassed pink noise for the "crushed flowers" texture (with makeup gain)
    var noise = BPF.ar(PinkNoise.ar(0.15), freq * 3, 0.08) * 12.0;
    var sig = RLPF.ar(osc + noise, cutoff, rq);
    Balance2.ar(sig[0], sig[1], pan, env * amp);
}).play;

// The "empty forest" - cold, sparse, bell-like FM tones (evoking the absence of fairies/families)
Ndef(\emptyForest, { |freq=440, amp=0.12, pan=0, t_trig=0, index=4, modRatio=3.14, atk=0.01, rel=3|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);
    // FM synthesis
    var mod = SinOsc.ar(freq * modRatio) * (freq * index);
    var car = SinOsc.ar(freq + mod);
    var sig = Pan2.ar(car * env * amp, pan);
    sig;
}).play;


// --- 2. Sequences (Pbindefs) ---

Pbindef(\grassSeq,
    \dur, Pseq([5, 4, 6], inf),
    \midinote, Pseq([43, 46, 41, 39], inf), // Melancholic, grounded natural minor root notes (G# / D# / F / C#)
    \t_trig, 1,
    \atk, 2.5,
    \rel, 5.0,
    \cutoff, Pwhite(500, 1000, inf),
    \rq, 0.35,
    \amp, 0.3,
    \pan, Pwhite(-0.3, 0.3, inf)
);

Pbindef(\forestSeq,
    \dur, Pseq([2.5, 3.5, 1.0, 5.0, 2.0], inf),
    \midinote, Pseq([\rest, 67, 70, \rest, 74, 65, \rest, 72], inf), // Sparse, lonely high tones
    \t_trig, 1,
    \atk, 0.02,
    \rel, 3.5,
    \index, Pwhite(2, 6, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, 0.1
);


// --- 3. Native Slot Routing ---

Ndef(\grassBed)[1] = \set -> Pbindef(\grassSeq);
Ndef(\emptyForest)[1] = \set -> Pbindef(\forestSeq);


// --- 4. Effect Chains (Initialized to 0) ---

// Spacey, desolate reverb for the empty forest
Ndef(\emptyForest)[10] = \filter -> { |in|
    FreeVerb.ar(in, mix: 1.0, room: 0.85, damp: 0.4);
};
Ndef(\emptyForest).set(\wet10, 0); // Initialize wetness to 0 (to be faded in later)

// Slapback delay to blur the crushed grass texture
Ndef(\grassBed)[10] = \filter -> { |in|
    in + DelayC.ar(in, 0.4, 0.24, 0.4);
};
Ndef(\grassBed).set(\wet10, 0); // Initialize wetness to 0

// 1. The Meadow (Warm, sun-drenched drone and chordal bed)
Ndef(\meadow, { |amp=0.15, cutoff=800, pan=0|
    var freqs = \freqs.kr([110, 165, 220, 330]);
    var sig = freqs.collect({ |f|
        var osc1 = Saw.ar(f * LFNoise1.kr(0.2).range(0.995, 1.005));
        var osc2 = Pulse.ar(f * 0.5 * LFNoise1.kr(0.15).range(0.99, 1.01), 0.5);
        var voice = (osc1 + osc2) * 0.5;
        RLPF.ar(voice, cutoff + LFNoise1.kr(0.5).range(-100, 100), 0.4);
    }).sum;
    // Apply warm saturation
    sig = (sig * 1.5).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

// 2. The Nightingale (Enchanted, chirping generative birdsong)
Ndef(\nightingale, { |freq=1500, amp=0.12, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.002, 0.15, curve: -6), t_trig);
    // Microtonal pitch sweep characteristic of birdsong
    var pitchEnv = EnvGen.ar(Env.perc(0.001, 0.08, curve: -4), t_trig) * 1800;
    // Soft FM modulation to add a sweet, realistic timbre
    var mod = SinOsc.ar(freq * 1.33) * env * 300;
    var sig = SinOsc.ar(freq + pitchEnv + mod);

    sig = HPF.ar(sig, 1000); // Keep it crisp and high-pitched
    Pan2.ar(sig * env * amp, pan);
}).play;

// 3. Effects Chain: Enchanted space reverb for the Nightingale
Ndef(\nightingale)[10] = \filter -> { |in|
    FreeVerb.ar(in, mix: 0.45, room: 0.85, damp: 0.2);
};
Ndef(\nightingale).set(\wet10, 0.45);

// 4. Sequences
Pbindef(\meadowSeq,
    \dur, 8,
    // Shifting modal chords representing the path through the meadow
    \freqs, Pseq([
        [[110, 165, 220, 293.66]], // Asus4
        [[110, 146.83, 220, 329.63]], // Dsus2
        [[98, 146.83, 196, 293.66]], // G major
        [[110, 165, 220, 330]] // A minor
    ], inf),
    \amp, 0.18,
    \cutoff, Pwhite(600, 1100, inf),
    \pan, Pwhite(-0.2, 0.2, inf)
);

Pbindef(\nightingaleSeq,
    // Rapid bird-like rhythmic gestures and pauses
    \dur, Pseq([0.08, 0.08, 0.12, 0.4, 0.05, 0.05, 0.1, 1.2], inf),
    \midinote, Pseq([84, 86, 89, 91, 93, 96, 89, 91], inf) + Pwhite(-1, 1, inf),
    \t_trig, 1,
    \amp, Pwhite(0.08, 0.18, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);

// 5. Connect sequences to instruments
Ndef(\meadow)[1] = \set -> Pbindef(\meadowSeq);
Ndef(\nightingale)[1] = \set -> Pbindef(\nightingaleSeq);

// 1. Define the physical model plucked string Ndef (monophonic node, re-triggered)
Ndef(\legendString, { |freq=220, amp=0.3, pan=0, t_trig=0, coef=0.4, decayTime=2|
    var exciter = WhiteNoise.ar(0.15) * EnvGen.ar(Env.perc(0.001, 0.015), t_trig);
    var sig = Pluck.ar(exciter, t_trig, freq.reciprocal, freq.reciprocal, decayTime, coef);
    sig = LeakDC.ar(sig);
    sig = HPF.ar(sig, 70);
    Pan2.ar(sig * amp, pan);
}).play;

// 2. Define the improvisational sequence evoking a "scene of legend"
Pbindef(\legendSeq,
    \dur, Pseq([0.2, 0.2, 0.4, 0.2, 0.6], inf), // Lively, improvisational pacing
    \degree, Pseq([0, 2, 4, 6, 7, 9, 11], inf), // Lydian scale for a legendary atmosphere
    \scale, Scale.lydian,
    \octave, Pwrand([4, 5, 6], [0.2, 0.6, 0.2], inf),
    \t_trig, 1,
    \coef, Pwhite(0.15, 0.55, inf), // Dynamic string damping (the "smile")
    \decayTime, Pwhite(1.5, 3.5, inf),
    \amp, Pwhite(0.2, 0.4, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

// 3. Native JITLib slot routing to bind sequence to the instrument
Ndef(\legendString)[1] = \set -> Pbindef(\legendSeq);

// 4. Add a "legendary space" echo/reverb effect in slot 10
Ndef(\legendString)[10] = \filter -> { |in|
    var delay = CombC.ar(in, 0.5, [0.25, 0.33], 3.0);
    FreeVerb.ar(in + (delay * 0.4), 0.8, 0.85, 0.4); // Return 100% wet signal
};

// Initialize wetness to 0 as per strict guidelines
Ndef(\legendString).set(\wet10, 0);

// 1. Define Pad Instrument (Deep, slow analog emulation)
Ndef(\pad, { |freq=110, amp=0.3, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(2.0, 6.0), t_trig);
    var sig = Splay.ar(Saw.ar(freq * [0.98, 1.0, 1.02]));
    Balance2.ar(sig[0], sig[1], pan, env * amp);
}).play;

// 2. Define Plink Instrument (Resonant subtractive synth)
Ndef(\plink, { |freq=440, amp=0.2, pan=0, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.05, 2.0), t_trig);
    var sig = Pulse.ar(freq, 0.4);
    Pan2.ar(sig * env * amp, pan);
}).play;

// 3. Sequences with reduced rhythm (Formal archetype: Settling (c) - sparse durations)
Pbindef(\padSeq,
    \dur, Pseq([6, 8, 4], inf), // Very slow, spacious rhythm
    \degree, Pseq([0, 2, -3], inf),
    \scale, Scale.minor,
    \t_trig, 1,
    \amp, 0.35,
    \pan, Pwhite(-0.4, 0.4, inf)
);

Pbindef(\plinkSeq,
    \dur, Pseq([12, 6, 8], inf), // Extremely reduced rhythm
    \degree, Pseq([4, 7, 3, 5], inf),
    \scale, Scale.minor,
    \t_trig, 1,
    \amp, 0.18,
    \pan, Pwhite(-0.8, 0.8, inf)
);

// Route sequences to Ndefs
Ndef(\pad)[1] = \set -> Pbindef(\padSeq);
Ndef(\plink)[1] = \set -> Pbindef(\plinkSeq);

// 4. Add Filter Effects to all layers (Immediate activation for muffled, dark aesthetic)
Ndef(\pad)[10] = \filter -> { |in| LPF.ar(in, \cutoff10.kr(350)) };
Ndef(\pad).xset(\wet10, 1.0); // Filter active

Ndef(\plink)[10] = \filter -> { |in| LPF.ar(in, \cutoff10.kr(700)) };
Ndef(\plink).xset(\wet10, 1.0); // Filter active
)

// Source: auto-append-coracao-avesso.scd
(
// 1. Coração pelo avesso (Heart inside out) - Heavy, distorted, asymmetrical heartbeat
Ndef(\heart, { |freq=55, amp=0.6, pan=0, drive=3, decay=0.3, t_trig=0|
    var env, osc, sig;
    env = EnvGen.ar(Env.perc(0.01, decay, curve: -4), t_trig);
    // Sub-bass with a first-octave harmonic to guarantee physical translation
    osc = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
    sig = osc * env;
    // Asymmetrical tube-like saturation to represent the heart turned "inside out"
    sig = LeakDC.ar(((sig + 0.15) * drive).tanh);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\heartSeq,
    \dur, Pseq([0.25, 0.55, 0.2, 0.6], inf), // Irregular, pumping heartbeat rhythm
    \freq, Pseq([52, 52, 48, 48], inf),
    \decay, Pseq([0.2, 0.4, 0.15, 0.3], inf),
    \drive, Pwhite(2.5, 4.5, inf),
    \amp, Pseq([0.7, 0.5, 0.6, 0.4], inf),
    \t_trig, 1
);
Ndef(\heart)[1] = \set -> Pbindef(\heartSeq);


// 2. A brisa sopra fogo (The breeze blows fire) - Fire crackle and sweeping hot wind
Ndef(\fireBreeze, { |cutoff=800, rq=0.15, crackleHz=12, amp=0.25, pan=0|
    var wind, crackle, sig;
    wind = PinkNoise.ar();
    // Narrow bandpass with high makeup gain to simulate whistling hot wind
    wind = BPF.ar(wind, cutoff, rq) * 12.0;
    // Crackling fire sparks
    crackle = Dust.ar(crackleHz) * 0.8;
    crackle = Ringz.ar(crackle, LFNoise1.kr(0.2).exprange(800, 3000), 0.01);
    sig = (wind + crackle).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\breezeSeq,
    \dur, 0.1,
    // Pseg sweeps from 200 to 1500 over 2 beats, then back to 200 over 2 beats, repeating infinitely
    \cutoff, Pseg([200, 1500, 200], [2, 2], \lin, inf),
    \crackleHz, Pwhite(5, 25, inf),
    \amp, Pwhite(0.15, 0.3, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);
Ndef(\fireBreeze)[1] = \set -> Pbindef(\breezeSeq);


// 3. O luar queima (The burning moonlight) - High, icy, metallic FM bells
Ndef(\moonBurn, { |freq=1200, modRatio=3.5, index=4, t_trig=0, amp=0.15, pan=0.5|
    var env, mod, car, sig;
    env = EnvGen.ar(Env.perc(0.002, 1.2, curve: -8), t_trig);
    mod = SinOsc.ar(freq * modRatio) * (freq * index * env);
    car = SinOsc.ar(freq + mod);
    // Ring modulation with high-frequency chaos to make the moonlight "burn"
    sig = car * SinOsc.ar(LFNoise2.kr(0.5).exprange(100, 800));
    sig = HPF.ar(sig, 400); // High-pass filter to keep it cold and sharp
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\moonSeq,
    \dur, Pseq([1.5, 2.5, 4.0, 1.0], inf),
    \freq, Pseq([880, 1200, 1500, 950], inf),
    \index, Pwhite(3.0, 8.0, inf),
    \amp, Pwhite(0.1, 0.2, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \t_trig, 1
);
Ndef(\moonBurn)[1] = \set -> Pbindef(\moonSeq);

// Burning spatial delay effect on the Moonlight
Ndef(\moonBurn)[10] = \filter -> { |in|
    var delay;
    delay = CombC.ar(in, 0.5, [0.25, 0.33], 3.0);
    in + (delay * 0.45);
};
Ndef(\moonBurn).set(\wet10, 0.5); // Initialize wetness for the burning moonlight atmosphere
)

// Source: auto-append-jardim.scd
(
// --- GARDEN DRONE (The waiting atmosphere in the garden) ---
Ndef(\garden, { |amp = 0.25, pan = 0, cutoff = 2500|
    var exc = Dust.ar([1.5, 2.5]) * 0.04 + (PinkNoise.ar(0.001) * LFNoise1.kr(0.2).range(0.1, 0.8));
    // Dreamy, elegant harmonic series (E major / C# minor feel)
    var freqs = [164.81, 246.94, 329.63, 440.0, 493.88, 659.25, 739.99];
    var rings = Array.fill(7, { rrand(2.0, 5.0) });
    var sig = DynKlank.ar(`[freqs, nil, rings], exc);
    sig = LPF.ar(sig, cutoff);
    sig = HPF.ar(sig, 100);
    Pan2.ar(sig * amp, pan);
}).play;

// --- HURRIED STEPS (The urgent, elegant ticking / footsteps of being late) ---
Ndef(\steps, { |freq = 440, amp = 0.2, pan = 0, t_trig = 0, decay = 0.12, fmIdx = 1.5|
    var env = EnvGen.ar(Env.perc(0.002, decay, curve: -6), t_trig);
    // FM synthesis for a metallic, high-heeled shoe / clockwork tick
    var mod = SinOsc.ar(freq * 3.5) * (freq * fmIdx) * env;
    var car = SinOsc.ar(freq + mod);
    var sig = Fold.ar(car * (1 + (env * 4)), -0.8, 0.8);
    // Low Pass Gate emulation
    sig = LPF.ar(sig, env.linexp(0, 1, 150, 9000));
    sig = LeakDC.ar(sig);
    Pan2.ar(sig * env * amp, pan);
}).play;

// --- EFFECT: Space/Garden Echoes ---
Ndef(\steps)[10] = \filter -> { |in|
    var delay = CombC.ar(in, 0.5, [0.25, 0.375], 3.0);
    LPF.ar(delay, 2000) * 0.5 + in;
};
Ndef(\steps).set(\wet10, 0.35); // Immediately active to paint the garden space

// --- SEQUENCE: Hurried, limping rhythm ("atrasada") ---
Pbindef(\stepsSeq,
    \type, \set,
    \id, Ndef(\steps).group,
    \args, [\t_trig, \freq, \amp, \decay, \pan],
    \t_trig, 1,
    \dur, Pseq([0.15, 0.15, 0.3, 0.15, 0.15, 0.45], inf), // Urgent, uneven gait
    \midinote, Pseq([76, 79, 81, 83, 81, 79, 76, 71], inf),
    \amp, Pwhite(0.12, 0.22, inf),
    \decay, Pseq([0.06, 0.14, 0.05, 0.1], inf),
    \pan, Pseq([-0.5, 0.5], inf)
).play;
)

// Source: auto-append-rimbaud.scd
(
// Deep flowing blue moat ("Lá embaixo escorre o fosso azul...")
Ndef(\moat, { |freq=36.71, amp=0.5, filterFreq=130, rq=0.08| // D1 sub-bass
    var sub = SinOsc.ar(freq) * 0.7 + SinOsc.ar(freq * 2) * 0.3; // First-octave harmonic for translation
    var noise = PinkNoise.ar(0.3);
    var lfo = SinOsc.kr(0.05).exprange(0.7, 2.5);
    var flow = BPF.ar(noise, filterFreq * lfo, rq) * 15.0; // Narrow BPF with makeup gain to prevent energy drop
    var sig = (sub + flow) * amp;
    sig = LPF.ar(sig, 350);
    sig = LeakDC.ar(sig);
    Pan2.ar(sig, SinOsc.kr(0.02).range(-0.5, 0.5));
}).play;

// Resonant citadel above ("...da cidadela.")
Ndef(\citadel, { |freq=220, amp=0.12, pan=0, t_trig=0, decay=3.0|
    var env = EnvGen.ar(Env.perc(0.002, decay), t_trig);
    // Stone-like grit exciter using waveshaping fold
    var exciter = (PinkNoise.ar(0.12) * env * 3.0).fold2(0.6);
    var freqs = freq * [1, 1.49, 2.18, 3.5, 5.05];
    var amps = [1.0, 0.5, 0.3, 0.15, 0.05];
    var rings = [decay, decay * 0.8, decay * 0.6, decay * 0.4, decay * 0.2];
    var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
    Pan2.ar(sig * amp, pan);
}).play;

// Add vast stone reverb to the citadel to establish the space immediately
Ndef(\citadel)[10] = \filter -> { |in|
    var sig = in;
    6.do {
        sig = AllpassN.ar(sig, 0.06, {ExpRand(0.001, 0.06)}!2, 4.0);
    };
    sig;
};
Ndef(\citadel).set(\wet10, 0.4);

// Sequence the citadel's cold, crystalline bell-strikes
Pbindef(\citadelSeq,
    \type, \set,
    \id, Ndef(\citadel),
    \args, #[\t_trig, \freq, \decay, \pan, \amp],
    \t_trig, 1,
    \dur, Pseq([1.5, 0.5, 2.0, 1.0, 3.0, 0.5, 0.5, 1.0], inf),
    \note, Pseq([0, 3, 7, 10, 12, 15, 19, 22], inf), // Cold minor 7/9/11 harmony
    \grootte, 50, // D3 root
    \midinote, Pkey(\note) + Pkey(\grootte),
    \freq, Pkey(\midinote).midicps,
    \decay, Pwhite(2.5, 5.0, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pwhite(0.08, 0.16, inf)
).play;

// 1. Define the skeletal, tranquil lead synth (tranquilamente um osso)
Ndef(\canoeLead, { |freq=220, amp=0.2, pan=0, atk=0.1, rel=1.2, t_trig=0, modIndex=1.2, vibRate=4, vibDepth=0.01|
	var env = EnvGen.ar(Env.perc(atk, rel, curve: -4), t_trig);
	var vibrato = SinOsc.kr(vibRate).bipolar(vibDepth);
	var pitch = freq * (1 + vibrato);
	var mod = SinOsc.ar(pitch * 1.5) * pitch * modIndex * env;
	var car = LFTri.ar(pitch + mod) * 0.6 + SinOsc.ar(pitch * 0.5) * 0.4;
	var sig = LPF.ar(car, freq * 2.5);
	Pan2.ar(sig * env * amp, pan);
}).play;

// 2. Add a spacey, watery delay effect to emulate the canoe's gentle drift
Ndef(\canoeLead)[10] = \filter -> { |in|
	var delay = CombC.ar(in, 0.5, [0.33, 0.45], 3.5);
	in + (delay * 0.5);
};

// Set wetness to a tranquil, spacious level
Ndef(\canoeLead).xset(\wet10, 0.45);
// Ndef(\canoeLead).xset(\wet10, 0); // Revert wetness to dry

// 3. Sequence the melody: a bare-bones, peaceful pentatonic chant
Pbindef(\canoeSeq,
	\type, \set,
	\id, Ndef(\canoeLead).group,
	\args, [\t_trig, \freq, \amp, \pan, \atk, \rel, \modIndex],
	\t_trig, 1,
	\scale, Scale.minorPentatonic,
	\octave, 5,
	\degree, Pseq([0, 2, 4, 7, 4, 2, 0, \rest], inf),
	\dur, Pseq([1.5, 0.5, 1.0, 2.0, 1.0, 1.0, 2.0, 1.0], inf) * 0.8,
	\atk, Pwhite(0.08, 0.15, inf),
	\rel, Pwhite(0.8, 1.5, inf),
	\modIndex, Pwhite(0.8, 2.0, inf),
	\amp, Pseq([0.15, 0.12, 0.14, 0.18, 0.11, 0.13, 0.15, 0.0], inf),
	\pan, Pseq([-0.3, 0.3, -0.1, 0.1, -0.4, 0.4], inf)
).play;

// --- Sound Sources ---

// 1. "Verdura, campos e pastos" - A lush, evolving background flora drone
Ndef(\greenery, { |freq=110, amp=0.25, pan=0, cutoff=1200, rq=0.6|
    var lfo = SinOsc.kr(0.08).range(0.3, 0.9);
    var osc1 = Saw.ar(freq * [0.995, 1.0, 1.005]);
    var osc2 = Pulse.ar(freq * 0.5 * [0.99, 1.01], 0.5);
    var sig = (osc1 * 0.5) + (osc2 * 0.5);

    // Moog-style resonant lowpass filter representing the wind in the woods
    sig = MoogFF.ar(sig, cutoff * lfo, rq * 3.5) * 2.5;
    sig = sig.tanh; // Warm saturation

    Pan2.ar(Splay.ar(sig), pan * 0.5);
}).play;

// 2. "Gravura, gado e gente" - Delicate, microtonal physical modeling plucks
Ndef(\engraving, { |freq=220, amp=0.15, pan=0, coef=0.4, decay=2.5, t_trig=0|
    var env = EnvGen.ar(Env.perc(0.001, decay), t_trig);
    // Exciter: Pink noise burst mixed with sparse dust clicks for organic texture
    var exciter = PinkNoise.ar(env * 0.4) + Dust.ar(8, env * 0.15);
    var sig = Pluck.ar(exciter, t_trig, 0.1, freq.reciprocal, decay, coef);

    // Low pass gate emulation: envelope modulates both amplitude and brightness
    sig = LPF.ar(sig, env.kr.linexp(0, 1, 150, 6000));

    Pan2.ar(sig, pan);
}).play;


// --- Effects Slots (Color Patches) ---

// "Manchas de cor" - A spatializing multi-tap delay on the greenery pad to paint color patches
Ndef(\greenery)[10] = \filter -> { |in|
    var delay = CombC.ar(in, 0.5, [0.25, 0.38], 4.0);
    in + (delay * 0.45);
};
// Initialize wetness to 0 (to be faded in dynamically)
Ndef(\greenery).set(\wet10, 0);


// --- Sequences ---

// Slow harmonic evolution for the fields/pastures drone
Pbindef(\seqGreenery,
    \type, \set,
    \id, Ndef(\greenery).group,
    \args, [\freq, \cutoff, \amp],

    \dur, 8,
    \degree, Pseq([0, 2, 4, -1], inf),
    \octave, 3,
    \cutoff, Pwhite(800, 1600, inf),
    \amp, 0.22
).play;

// Detailed, pointillistic microtonal engraving patterns (people, houses, cattle)
Pbindef(\seqEngraving,
    \type, \set,
    \id, Ndef(\engraving).group,
    \args, [\t_trig, \freq, \coef, \decay, \pan, \amp],

    \t_trig, 1,
    \dur, Pseq([0.125, 0.25, 0.125, 0.5, 0.25, 0.25], inf),
    \scale, Scale.major,
    \degree, Pseq([0, 2, 4, 7, 9, 11].scramble, inf),
    \octave, Pseq([5, 6, 7], inf),
    \coef, Pwhite(0.15, 0.65, inf),
    \decay, Pwhite(1.2, 3.5, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \amp, Pwhite(0.08, 0.18, inf)
).play;

// Extrinsic Limit (d): Sudden global fade-out to silence all active layers.
Pbindef.clear;
Ndef.clear(3.0); // Fade out all active Ndef proxies over 3 seconds

// ADD_INSTRUMENT: Ndef(\cyclone) - The Red Cyclone (Ciclone Rubro)
// A heavy, swirling, saturated vortex of sound representing a violent storm in the head.
Ndef(\cyclone, { |freq=55, amp=0.5, pan=0, t_trig=0, drive=4.0, rate=8, sweep=3000|
    var env, wind, core, sub, sig, fFreq;

    // Fast decay envelope for the percussive impact of the cyclone
    env = EnvGen.ar(Env.perc(0.005, 0.7, curve: -6), t_trig);

    // Cyclone Wind: Violent filtered pink noise modulated by a fast LFO
    wind = PinkNoise.ar(0.7) * LFTri.kr(rate * 1.5).range(0.3, 1.0);

    // Red Core: Detuned saw waves generating a rich, aggressive spectrum
    core = Splay.ar(Saw.ar(freq * [0.5, 0.99, 1.0, 1.01, 2.0]));

    // Sub-bass compensation: adding first-octave harmonic to prevent loss of low-end
    sub = SinOsc.ar(freq * 2, 0, 0.5);

    sig = Mix([wind * 0.3, core * 0.5, sub * 0.4]);

    // Resonant sweeping filter (Vortex) with high resonance
    fFreq = (freq * 1.5) + (sweep * env) + SinOsc.kr(rate).range(200, 1500);
    // MoogFF high resonance drops fundamental; compensated with 5.0 makeup gain into tanh
    sig = (MoogFF.ar(sig, fFreq.clip(20, 20000), 3.5) * 5.0).tanh;

    // Multi-band saturation / wavefolding for the "Red" (Rubro) texture
    sig = (sig * drive).fold2(0.8) * 0.5;

    // Binaural-style rapid panning (swirling around the head)
    sig = Pan2.ar(sig, SinOsc.kr(rate) + pan);

    sig * amp;
}).play;

// ADD_EFFECTS: Spatial blurring and feedback delay on Slot [10]
// Simulates the physical sensation of a spinning cyclone inside the skull
Ndef(\cyclone)[10] = \filter -> { |in|
    var delay;
    delay = CombC.ar(in, 0.2, [0.12, 0.15] * SinOsc.kr(0.2).range(0.95, 1.05), 1.8);
    in + (delay * 0.5);
};

// Initialize wetness of the spatial blur effect
Ndef(\cyclone).xset(\wet10, 0.4);

// TWEAK_SEQUENCE: Pbindef(\cycloneSeq)
// Sequences the violent rhythm of the cyclone, forcing rapid frequency sweeps and panning
Pbindef(\cycloneSeq,
    \type, \set,
    \id, Ndef(\cyclone).group,
    \args, [\t_trig, \freq, \amp, \rate, \sweep, \pan],

    \t_trig, 1,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25], inf),
    // Tectonic bass notes that shift into mid-range screams
    \midinote, Pseq([36, 48, 36, 51, 36, 43, 36, 57], inf),
    \freq, Pkey(\midinote).midicps,

    // Speed of the cyclone's rotation
    \rate, Pseq([6, 12, 8, 16], inf),
    \sweep, Pwhite(2000, 5000, inf),
    \amp, Pseq([0.6, 0.4, 0.5, 0.7, 0.4, 0.5], inf),
    \pan, Pwhite(-0.6, 0.6, inf)
).play;

// Ndef: "White swarm" and "silver nails"
Ndef(\enxame, { |freq=1200, amp=0.2, pan=0, t_trig=0, atk=0.1, rel=2.5, rq=0.02, noiseAmp=0.4, resAmp=0.2|
    var env = EnvGen.ar(Env.perc(atk, rel), t_trig);

    // "White swarms" - High-passed, band-passed noise with makeup gain
    var whiteSwarm = BPF.ar(WhiteNoise.ar(noiseAmp), freq * [1, 1.5], rq).sum * 8.0;

    // "Silver nails" - High frequency metallic ringz
    var silverNails = Ringz.ar(
        Dust.ar(12),
        freq * [2.5, 3.76, 5.0, 6.2],
        0.15
    ).sum * resAmp;

    var sig = (whiteSwarm + silverNails) * env;

    // Clean up DC offsets
    sig = LeakDC.ar(sig);

    Pan2.ar(sig * amp, pan + LFNoise1.kr(0.2).range(-0.2, 0.2));
}).play;

// "Vague dreams" - Ethereal, blurred delay space (Settling/Flashback preparation)
Ndef(\enxame)[10] = \filter -> { |in|
    var delay = CombC.ar(in, 0.6, [0.33, 0.45], 5.0);
    LPF.ar(delay, 3000) * 0.5 + in;
};
Ndef(\enxame).xset(\wet10, 0.5);

// Sequence the swarm
Pbindef(\seqEnxame,
    \type, \set,
    \id, Ndef(\enxame).group,
    \args, [\t_trig, \freq, \rq, \noiseAmp, \resAmp, \amp, \pan, \atk, \rel],

    \t_trig, 1,
    \dur, Pseq([0.75, 0.5, 1.0, 0.25, 1.5], inf),
    \midinote, Pseq([79, 81, 84, 86, 91, 93], inf), // High silver notes
    \freq, Pkey(\midinote).midicps,
    \rq, Pwhite(0.01, 0.04, inf),
    \noiseAmp, Pwhite(0.3, 0.6, inf),
    \resAmp, Pwhite(0.1, 0.3, inf),
    \amp, Pwhite(0.1, 0.25, inf),
    \atk, Pwhite(0.05, 0.2, inf),
    \rel, Pseq([2.0, 1.0, 3.0, 0.5], inf),
    \pan, Pwhite(-0.7, 0.7, inf)
).play;

// 1. Sound Sources
Ndef(\drone, { |freq=45, amp=0.25, cutoff=180|
    var wind = BPF.ar(PinkNoise.ar(0.6), LFNoise1.kr(0.1).exprange(120, 600), 0.4);
    var sub = SinOsc.ar(freq * [1, 2], 0, 0.15).sum;
    var sig = wind + sub;
    sig = LPF.ar(sig, cutoff);
    Pan2.ar(sig * amp, LFNoise1.kr(0.05));
});

Ndef(\drips, { |freq=1200, amp=0.4, pan=0, t_trig=0, decay=0.15|
    var exciter = Decay2.ar(t_trig, 0.0005, 0.008) * PinkNoise.ar(0.3);
    // Classic dynamic water drip pitch sweep (upwards then settling)
    var freqEnv = EnvGen.ar(Env([1.0, 1.7, 1.1], [0.001, 0.06], \exp), t_trig);
    var sig = Ringz.ar(exciter, freq * freqEnv, decay);
    sig = HPF.ar(sig, 200);
    Pan2.ar(sig * amp, pan);
});

// 2. The Cave (Spacious Reverb & Environmental Acoustics)
Ndef(\cave, {
    var dry = Ndef(\drips).ar(2) + Ndef(\drone).ar(2);
    var wet;
    // Pre-delay to simulate physical distance and cave size
    var pre = DelayC.ar(dry, 0.2, 0.06);
    // Generous, dark reverb
    wet = FreeVerb2.ar(pre[0], pre[1], mix: 1.0, room: 0.98, damp: 0.25);
    // High-frequency damping from wet rocky walls
    wet = LPF.ar(wet, 3000);
    // Long feedback echo taps reflecting off distant cavern structures
    wet = wet + CombC.ar(wet, 0.8, [0.33, 0.41], 5.0, 0.15);
    // Final output mix with safety limiting
    Limiter.ar((dry * 0.3) + (wet * 0.7), 0.95);
}).play;

// 3. Sequencing the Drips (Irregular natural dripping pattern)
Ndef(\drips)[1] = \set -> Pbindef(\dripSeq,
    \dur, Pseq([0.4, 0.2, 1.8, 0.6, 0.2, 0.2, 1.2], inf) * Pwhite(0.8, 1.3, inf),
    \t_trig, 1,
    \freq, Pwhite(1000, 2200, inf),
    \decay, Pwhite(0.12, 0.28, inf),
    \amp, Pwhite(0.2, 0.5, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);

// 1. Stop all active sequencing streams immediately to halt rhythmic movement
Pbindef(\leadSeq).stop;
Pbindef(\glitchSeq).stop;
Pbindef(\bassSeq).stop;
Pbindef(\padSeq).stop;

// 2. Staggered fade-out of audio sources to create a smooth, natural dissolution
// First, the high-frequency lead fades out over 4 seconds
Ndef(\lead).fadeTime = 4.0;
Ndef(\lead).clear(4.0);

// Next, the glitch/percussion texture dissolves over 8 seconds
Ndef(\glitch).fadeTime = 8.0;
Ndef(\glitch).clear(8.0);

// The sub-bass weight is removed over 12 seconds, leaving only the harmonic space
Ndef(\bass).fadeTime = 12.0;
Ndef(\bass).clear(12.0);

// Finally, the main ambient pad drone slowly dissolves over 20 seconds into silence
Ndef(\pad).fadeTime = 20.0;
Ndef(\pad).clear(20.0);
)

// Source: chimichango-carcara-synth.scd
(
// Algorithmic sequencer driving an external pad/noise synth
// Simulates the intelligent, erratic foraging of the chimango caracara
Pbindef(\chimangoSeq,
	\type, \midi,
	\midiout, ~mOut,
	\chan, 0,
	\midicmd, \noteOn,

	// Pitch: Intelligent, calculated problem-solving movements over a constrained scale
	\midinote, Pwalk(
		[55, 57, 58, 60, 62, 65, 67, 69], // Constrained scale array
		Pseq([1, 2, -1, 1, -2, 3, -1], inf), // Evolving step pattern
		1 // Direction
	),

	// Velocity: Dynamic interaction
	\amp, Pexprand(0.4, 0.85, inf),

	// Rhythm: Hesitant, probing durations mimicking a scavenging bird
	\dur, Pwrand(
		[0.125, 0.25, 0.5, 1.0],
		[0.4, 0.3, 0.2, 0.1], // Higher probability for quick movements, occasional pauses
		inf
	),

	// Legato controls the MIDI note length relative to \dur
	\legato, Pwhite(0.5, 1.2, inf)
).play(quant: 1);
)

// Source: compose-cognition-FIXED.scd
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    // Global Buffers for FFT and Delays
    ~fftBufA = Buffer.alloc(s, 2048);
    ~fftBufB = Buffer.alloc(s, 2048);
    ~delayBuf = Buffer.alloc(s, s.sampleRate * 5, 2);

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\sparkleGrain, { |out=0, freq=4000, amp=0.1, pan=0, dur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, dur), doneAction: 2);
        var sig = FSinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pulseEngine, { |out=0, freq=400, fmIndex=2, amp=0.2, pan=0, dur=0.1|
        var env = EnvGen.ar(Env.perc(0.005, dur), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\glassResonator, { |out=0, freq=2000, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        var exc = Impulse.ar(0);
        var sig = DynKlank.ar(`[[1, 2.04, 3.16, 4.42] * freq, [1, 0.7, 0.5, 0.2], [1, 0.8, 0.6, 0.4]], exc);
        Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    SynthDef(\thoughtPattern, { |out=0, freq=440, modRatio=2, modIndex=1, amp=0.2, gate=1, pan=0|
        var env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.5, 0.2), gate, doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * modIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\focusClick, { |out=0, freq=8000, amp=0.5, pan=0, dur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, dur), doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.05) * env * 10;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\dataStream, { |freq=100, cutoff=1000, rq=0.5, amp=0, lfoRate=0, lfoDepth=0|
        var lfo = SinOsc.kr(lfoRate).range(1 - lfoDepth, 1 + lfoDepth);
        var sig = Pulse.ar([freq, freq * 1.01] * lfo, 0.5) + Saw.ar([freq * 0.5, freq * 0.505]);
        sig = RLPF.ar(sig, (cutoff * lfo).clip(20, 18000), rq);
        sig * amp;
    });

    Ndef(\spectralFilter, { |amp=0, bandWidth=100, freqShift=0|
        var sigL = PinkNoise.ar(1);
        var sigR = PinkNoise.ar(1);
        var chainL = FFT(~fftBufA, sigL);
        var chainR = FFT(~fftBufB, sigR);
        var sig, centerFreq, rq;

        chainL = PV_BinScramble(chainL, 0.8, 0.1, 1);
        chainR = PV_BinScramble(chainR, 0.8, 0.1, 1);
        sig = IFFT([chainL, chainR]);

        centerFreq = freqShift.linlin(-500, 500, 100, 8000).clip(50, 15000);
        rq = (bandWidth / 2000).clip(0.01, 1.0);
        sig = BPF.ar(sig, centerFreq, rq);
        sig * amp * 10;
    });

    Ndef(\memoryEcho, { |delayTime=1.0, feedback=0.5, amp=0|
        var in = Ndef.ar(\dataStream, 2);
        var local = LocalIn.ar(2) + in;
        var delayed = BufDelayL.ar(~delayBuf.bufnum, local, delayTime.lag(0.1));
        LocalOut.ar(delayed * feedback);
        delayed * amp;
    });

    Ndef(\vocalicTexture, { |formantFreq=400, formantWidth=100, amp=0|
        var sig = Formant.ar([120, 122], formantFreq, formantWidth);
        sig = sig + Formant.ar([60, 61], formantFreq * 1.5, formantWidth * 0.8);
        sig * amp * 0.5;
    });

    Ndef(\recursiveFeedback, { |delayTime=0.2, feedback=0.9, amp=0|
        var in = Ndef.ar(\vocalicTexture, 2);
        var local = LocalIn.ar(2) + in;
        var delayed = DelayL.ar(local, 1.0, delayTime.lag(0.1));
        LocalOut.ar(delayed * feedback);
        delayed * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var data = Ndef.ar(\dataStream, 2);
        var echo = Ndef.ar(\memoryEcho, 2);
        var spec = Ndef.ar(\spectralFilter, 2);
        var voc = Ndef.ar(\vocalicTexture, 2);
        var rec = Ndef.ar(\recursiveFeedback, 2);
        synths + data + echo + spec + voc + rec;
    });

    // JITLib FX Slots
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.8, damp: 0.2) };
    Ndef(\masterMix)[11] = \filter -> { |in| DelayN.ar(in, 1.0, 0.3) };

    Ndef(\masterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\masterMix).play;

    s.sync;

// --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: Server Buffer]".postln;
        Ndef(\masterMix).set(\wet10, 0.1);
        0.5.wait;

        "0:00.5 - [Cue 2: Initial Acquisition]".postln;
        Pbindef(\acqGrains,
            \instrument, \sparkleGrain,
            \out, ~synthBus,
            \dur, Pexprand(0.01, 0.08, inf),
            \freq, Pexprand(2000, 8000, inf),
            \amp, Pexprand(0.05, 0.15, inf)
        ).play;

        // Active Wait: 7.5s
        7.do { Pbindef(\acqGrains, \pan, rrand(-0.8, 0.8)); 1.wait; };
        0.5.wait;

        "0:08.0 - [Cue 3: Data Stream Emerges]".postln;
        Pbindef(\acqGrains).stop;
        Ndef(\dataStream).fadeTime = 2.0;
        Ndef(\dataStream).xset(\cutoff, 200, \rq, 0.5, \amp, 0.5);

        // Active Wait: 10s
        5.do { |i| Ndef(\dataStream).xset(\cutoff, 200 + (i * 100)); 2.wait; };

        "0:18.0 - [Cue 4: Information Storage]".postln;
        Pbindef(\rhythmBlocks,
            \instrument, \pulseEngine,
            \out, ~synthBus,
            \dur, Pseq([0.3, 0.5, 0.2, 0.8], inf),
            \freq, Pseq([400, 800, 600, 1200], inf),
            \fmIndex, Pwhite(1.0, 3.0, inf),
            \amp, 0.2
        ).play;
        Ndef(\dataStream).fadeTime = 12.0;
        Ndef(\dataStream).xset(\freq, 80);

        // Active Wait: 12s
        6.do { 2.wait; };

        "0:30.0 - [Cue 5: Retrieval Flash]".postln;
        Pbindef(\rhythmBlocks).stop;
        Synth(\glassResonator, [\out, ~synthBus, \freq, 2000, \amp, 0.6]);
        3.wait;

        "0:33.0 - [Cue 6: Transformative Process]".postln;
        Ndef(\dataStream).fadeTime = 12.0;
        Ndef(\dataStream).xset(\lfoRate, 3.0, \lfoDepth, 0.5);
        6.do { 2.wait; };

        "0:45.0 - [Cue 7: Applied Complexity]".postln;
        Pbindef(\logicSeq,
            \instrument, \thoughtPattern,
            \out, ~synthBus,
            \dur, 0.25,
            \degree, Pseq([0, 2, 4, 7, 9, 12, 11, 7, 5, 2, 0], inf),
            \scale, Scale.minor,
            \modRatio, 2,
            \modIndex, Pseq([0.5, 1.2, 0.8, 1.5], inf),
            \amp, 0.3
        ).play;
        Ndef(\masterMix).fadeTime = 3.0;
        Ndef(\masterMix).xset(\wet10, 0.4);

        // Active Wait: 15s
        5.do { Pbindef(\logicSeq, \modRatio, rrand(1.0, 4.0)); 3.wait; };

        "1:00.0 - [Cue 8: Intrinsic Limit - Density Climax]".postln;
        Ndef(\dataStream).fadeTime = 10.0;
        Ndef(\dataStream).xset(\cutoff, 18000, \amp, 0.7);
        Pbindef(\logicSeq, \modIndex, 5.0, \dur, 0.125);
        5.do { 2.wait; };

        "1:10.0 - [Cue 9: Overload & Reset]".postln;
        Pbindef(\logicSeq).stop;
        Ndef(\dataStream).fadeTime = 0.5;
        Ndef(\dataStream).xset(\cutoff, 100, \amp, 0.1, \lfoDepth, 0);
        Ndef(\masterMix).fadeTime = 1.0;
        Ndef(\masterMix).xset(\wet10, 0.1);
        5.wait;

        "1:15.0 - [Cue 10: Lingering Data]".postln;
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\delayTime, 2.0, \feedback, 0.7, \amp, 1.0);
        Ndef(\dataStream).fadeTime = 5.0;
        Ndef(\dataStream).xset(\amp, 0.3);

        // Active Wait: 30s
        10.do { |i| Ndef(\memoryEcho).xset(\delayTime, 2.0 + (sin(i)*0.5)); 3.wait; };

        "1:45.0 - [Cue 11: Perceptual Filter]".postln;
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\amp, 0);
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0.2, \bandWidth, 100, \freqShift, 0);
        5.wait;

        "1:50.0 - [Cue 12: Organizing Sensory Info]".postln;
        Ndef(\spectralFilter).fadeTime = 15.0;
        Ndef(\spectralFilter).xset(\bandWidth, 1000, \freqShift, 200);
        5.do { 3.wait; };

        "2:05.0 - [Cue 13: Attention Snap]".postln;
        Ndef(\spectralFilter).set(\amp, 0);
        Pbindef(\attentionSnap,
            \instrument, \focusClick,
            \out, ~synthBus,
            \dur, 0.05,
            \freq, Pseq([8000, 12000, 6000], inf),
            \amp, 0.8
        ).play;
        Ndef(\masterMix).set(\wet10, 0);
        3.wait;

        "2:08.0 - [Cue 14: Filtering Irrelevance]".postln;
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0.1);
        Ndef(\spectralFilter).fadeTime = 7.0;
        Ndef(\spectralFilter).xset(\bandWidth, 50);
        Pbindef(\attentionSnap, \dur, Pseq([0.5, 1.0, 0.7], inf), \amp, 0.5);
        7.wait;

        "2:15.0 - [Cue 15: Working Memory]".postln;
        Pbindef(\attentionSnap).stop;
        Ndef(\spectralFilter).fadeTime = 1.0;
        Ndef(\spectralFilter).xset(\amp, 0);
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\freq, 440, \amp, 0.4, \cutoff, 10000, \lfoDepth, 0);
        Pbindef(\logicSeq,
            \dur, 0.5,
            \degree, Pseq([0, 2, 4, 7], inf),
            \modIndex, 1.0
        ).play;
        10.wait;

        "2:25.0 - [Cue 16: Long-Term Memory Echoes]".postln;
        Ndef(\memoryEcho).fadeTime = 15.0;
        Ndef(\memoryEcho).xset(\delayTime, 4.0, \feedback, 0.85, \amp, 1.0);
        Pbindef(\logicSeq, \degree, Pseq([0, 4, 7, 12], inf).stutter(2));
        5.do { 3.wait; };

        "2:40.0 - [Cue 17: Memory Distortion & Recall]".postln;
        10.do {
            Ndef(\memoryEcho).set(\delayTime, rrand(0.1, 5.0), \feedback, rrand(0.5, 0.95));
            0.5.wait;
        };
        Ndef(\memoryEcho).fadeTime = 1.0;
        Ndef(\memoryEcho).xset(\delayTime, 1.0, \feedback, 0.6);
        5.wait;

        "2:50.0 - [Cue 18: Thinking - Concept Formation]".postln;
        Ndef(\memoryEcho).fadeTime = 2.0;
        Ndef(\memoryEcho).xset(\amp, 0);
        Pbindef(\logicSeq,
            \degree, Ptuple([Pseq([0, 2, 4, 7], inf), Pseq([12, 10, 7, 5], inf)]),
            \dur, Pseq([0.2, 0.4, 0.3], inf)
        );
        Pbindef(\thoughtSeq,
            \instrument, \thoughtPattern,
            \out, ~synthBus,
            \dur, Pseq([0.6, 0.6, 1.2], inf),
            \freq, Pseq([300, 400, 500], inf),
            \modRatio, 1.5,
            \modIndex, 2,
            \amp, 0.25
        ).play;
        5.do { 3.wait; };

        "3:05.0 - [Cue 19: Reasoning & Problem Solving]".postln;
        Pbindef(\logicSeq, \degree, Pseq([Pwhite(0, 11, 8), Pseq([0, 4, 7], 1)], inf));
        Pbindef(\thoughtSeq, \freq, Pseq([Pwhite(200, 800, 4), Pseq([440, 550, 660], 1)], inf));
        Ndef(\masterMix).fadeTime = 5.0;
        Ndef(\masterMix).xset(\wet10, 0.6);
        10.do { 2.wait; };

        "3:25.0 - [Cue 20: Decision Making]".postln;
        Pbindef(\logicSeq).stop;
        Pbindef(\thoughtSeq).stop;
        Ndef(\dataStream).fadeTime = 0.5;
        Ndef(\dataStream).xset(\freq, 440, \amp, 0.5, \cutoff, 20000);
        5.wait;

        "3:30.0 - [Cue 21: Language - Acquisition]".postln;
        Ndef(\dataStream).fadeTime = 1.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\vocalicTexture).fadeTime = 2.0;
        Ndef(\vocalicTexture).xset(\formantFreq, 400, \formantWidth, 100, \amp, 0.3);
        10.wait;

        "3:40.0 - [Cue 22: Comprehension & Production]".postln;
        Ndef(\vocalicTexture).fadeTime = 15.0;
        Pbindef(\rhythmBlocks,
            \instrument, \focusClick,
            \out, ~synthBus,
            \dur, Pseq([0.1, 0.2, 0.1, 0.4], inf),
            \freq, Pwhite(1000, 3000, inf),
            \amp, 0.3
        ).play;
        5.do { Ndef(\vocalicTexture).xset(\formantFreq, [700, 1200, 900, 500].choose, \formantWidth, 50); 3.wait; };

        "3:55.0 - [Cue 23: Metacognition - Self-Reflection]".postln;
        Pbindef(\rhythmBlocks).stop;
        Ndef(\recursiveFeedback).fadeTime = 2.0;
        Ndef(\recursiveFeedback).xset(\delayTime, 0.2, \feedback, 0.9, \amp, 1.0);
        Ndef(\vocalicTexture).fadeTime = 5.0;
        Ndef(\vocalicTexture).xset(\amp, 0.2);
        5.do { 3.wait; };

        "4:10.0 - [Cue 24: Conscious & Unconscious]".postln;
        Ndef(\dataStream).fadeTime = 5.0;
        3.do {
            Ndef(\dataStream).xset(\amp, 0.6);
            2.5.wait;
            Ndef(\dataStream).xset(\amp, 0.1);
            2.5.wait;
        };

        "4:25.0 - [Cue 25: Controlled & Automatic]".postln;
        Ndef(\recursiveFeedback).fadeTime = 2.0;
        Ndef(\recursiveFeedback).xset(\amp, 0);
        15.do {
            Ndef(\dataStream).fadeTime = 0.1;
            Ndef(\dataStream).xset(\freq, [220, 440, 880, 1760].choose, \cutoff, [1000, 5000, 10000].choose, \amp, 0.4);
            Ndef(\spectralFilter).fadeTime = 0.1;
            Ndef(\spectralFilter).xset(\bandWidth, exprand(50, 2000), \freqShift, rrand(-500, 500), \amp, 0.2);
            1.wait;
        };

        "4:40.0 - [Cue 26: Final Cognitive Burst]".postln;
        Ndef(\dataStream).fadeTime = 5.0;
        Ndef(\dataStream).xset(\amp, 0.8);
        Ndef(\spectralFilter).fadeTime = 5.0;
        Ndef(\spectralFilter).xset(\amp, 0.4, \bandWidth, 5000, \freqShift, 0);
        Ndef(\masterMix).fadeTime = 3.0;
        Ndef(\masterMix).xset(\wet10, 0.9);
        10.do {
            Ndef(\dataStream).xset(\freq, exprand(1000, 10000));
            1.wait;
        };

        "4:50.0 - [Cue 27: Dissolution]".postln;
        Ndef(\dataStream).fadeTime = 2.0;
        Ndef(\dataStream).xset(\amp, 0);
        Ndef(\spectralFilter).fadeTime = 3.0;
        Ndef(\spectralFilter).xset(\amp, 0);
        10.do { |i|
            Ndef(\masterMix).set(\wet10, 0.9 - (i * 0.09));
            1.wait;
        };

        "5:00.0 - [Cue 28: Absolute Cessation]".postln;
        Pbindef.removeAll;
        Ndef.clear(15.0); // .clear() is valid here to entirely free and drop the proxies.
        "Server fading to silence...".postln;

        6.do { 5.wait; };

        Tdef.removeAll;
        "Score Complete. Absolute Cessation.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: compose-dance.scd
(
s.waitForBoot({
    // =====================================================================
    // PRE-SETUP: BUS ROUTING & BUFFERS
    // =====================================================================
    ~synthBus = Bus.audio(s, 2);

    // Pre-allocate global buffers for FFT to prevent real-time memory drops
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);

    s.sync;

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // =====================================================================
    // 1. DISCRETE EVENT SYNTHESIZERS (Node Safe)
    // =====================================================================

    // Physical model of a wooden bar strike (Tap/Gumboot)
    SynthDef(\tapPluck, { |out=0, freq=400, decayScale=0.1, pan=0, amp=0.5|
        // Short noise burst excitation
        var exc = PinkNoise.ar(EnvGen.ar(Env.perc(0.001, 0.01)));
        // Tuned resonators for wood-like physical modeling
        var sig = DynKlank.ar(
            Ref(#[
                [1.0, 1.42, 2.3, 3.2, 4.5],
                [1.0, 0.6, 0.4, 0.2, 0.1],
                [1.0, 0.8, 0.6, 0.4, 0.2]
            ]),
            exc,
            freqscale: freq,
            decayscale: decayScale
        );
        var env = EnvGen.ar(Env.perc(0.001, decayScale), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // 2-carrier, 2-modulator FM synthesizer (Fluid Gestures)
    SynthDef(\fluidGesture, { |out=0, freq=440, carRatio=1, modRatio=1.5, index=2, atk=0.1, rel=1, pan=0, amp=0.2|
        var env = EnvGen.ar(Env.linen(atk, rel * 0.2, rel * 0.8), doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * index * freq * env;
        var car = SinOsc.ar(freq * carRatio + mod);
        Out.ar(out, Pan2.ar(car * env * amp, pan));
    }).add;

    // Low-frequency, saturated subtractive synthesizer (Heavy Footfalls)
    SynthDef(\heavyImpact, { |out=0, freq=100, subFreq=40, cutoff=800, resonance=0.2, amp=0.6, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 1.5), doneAction: 2);
        var pitchEnv = EnvGen.kr(Env.perc(0.001, 0.1)).exprange(1.0, 2.5);
        var sig = SinOsc.ar(subFreq * pitchEnv) + Saw.ar(freq);
        sig = MoogFF.ar(sig, cutoff * EnvGen.kr(Env.perc(0.01, 0.5)).exprange(1, 4), resonance);
        sig = (sig * 2.0).tanh; // Saturation
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // =====================================================================
    // 2. CONTINUOUS TEXTURES & EFFECTS ARCHITECTURE (JITLib)
    // =====================================================================

    // Physical model of friction (Stage floor scraping)
    Ndef(\frictionStage, {
        var cutoff = \cutoff.kr(1000, 1);
        var amp = \amp.kr(0, 0.5);
        var noiseDens = \noiseDens.kr(0, 0.5);
        var n = WhiteNoise.ar + Dust.ar(noiseDens);
        var sig = Resonz.ar(n, cutoff * LFNoise2.kr(0.5).exprange(0.8, 1.2), 0.2);
        Pan2.ar(sig * amp, LFNoise1.kr(0.2));
    });

    // Theatrical space drone
    Ndef(\ensembleDrone, {
        var amp = \amp.kr(0, 2);
        var subAmp = \subAmp.kr(0, 2);
        var sig = Mix.fill(12, { |i|
            var f = 100 * (i+1) * 1.01;
            SinOsc.ar(f) * SinOsc.kr(0.05 * (i+1)).range(0, 1) * (1 / (i+1));
        });
        var sub = SinOsc.ar(40) * subAmp;
        Pan2.ar((sig + sub) * amp * 0.2, 0);
    });

    // Master Mixer & Effects Chain
    Ndef(\masterMix, {
        var discreteSynths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\frictionStage, 2) + Ndef.ar(\ensembleDrone, 2);
        discreteSynths + continuous;
    });

    // Slot 10: Spectral Resonance (FFT Delay)
    Ndef(\masterMix)[10] = \filter -> { |in|
        var smear = \smear.kr(0, 0.5);
        var shift = \shift.kr(0, 0.5);
        var chainL = FFT(~fftBufL, in[0]);
        var chainR = FFT(~fftBufR, in[1]);
        chainL = PV_MagSmear(chainL, smear);
        chainR = PV_MagSmear(chainR, smear);
        chainL = PV_MagShift(chainL, 1 + shift);
        chainR = PV_MagShift(chainR, 1 + shift);
        IFFT([chainL, chainR]);
    };

    // Slot 15: Kinetic Spatial Blur (Ping-Pong Delay)
    Ndef(\masterMix)[15] = \filter -> { |in|
        CombC.ar(in, 0.5, [0.125, 0.166], 2.0);
    };

    // Slot 20: Master Reverb
    Ndef(\masterMix)[20] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.85, damp: 0.3);
    };

    // Slot 30: Master Low-Pass Filter (For Form Operation B)
    Ndef(\masterMix)[30] = \filter -> { |in|
        LPF.ar(in, \masterLpf.kr(20000, 0.5));
    };

    // Initialize effect states
    Ndef(\masterMix).set(\wet10, 0, \wet15, 0, \wet20, 0.15, \wet30, 1.0, \masterLpf, 20000);
    Ndef(\masterMix).play;
    s.sync;

    // =====================================================================
    // 3. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        // --- PHASE I: Solo Imperative & Spatial Friction ---
        "0:00.0 - [Cue 1: Safety Initialization]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Solo Tap Ignition]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.5, 0.125, 0.125, 0.75], inf),
            \freq, Pseq([300, 400, 350, 450, 320], inf),
            \decayScale, 0.05,
            \pan, -0.8,
            \amp, 0.4
        ).play;
        5.5.wait;

        "0:06.0 - [Cue 3: Friction Entry]".postln;
        Ndef(\frictionStage).fadeTime = 4;
        Ndef(\frictionStage).xset(\amp, 0.25, \cutoff, 800);
        8.0.wait;

        "0:14.0 - [Cue 4: The Pivot]".postln;
        Pbindef(\tapSeq, \freq, Pseq([300, 400, 350, 450, 320] * 2.0, inf));
        4.5.wait;

        "0:18.5 - [Cue 5: Dynamic Suspension]".postln;
        Ndef(\ensembleDrone).fadeTime = 5;
        Ndef(\ensembleDrone).xset(\amp, 0.015); // approx -36dB
        // Active Wait State
        2.do { Ndef(\frictionStage).xset(\cutoff, rrand(800, 1200)); 5.75.wait; };

        "0:30.0 - [Cue 6: The Leap]".postln;
        Synth(\heavyImpact, [\out, ~synthBus, \amp, 0.8]);
        Pbindef(\tapSeq).stop;
        6.0.wait;

        "0:36.0 - [Cue 7: Fluid Counter-Response]".postln;
        Pbindef(\gestureSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, Pseq([2.0, 1.5, 3.0], inf),
            \freq, Pseq([600, 800, 550], inf),
            \carRatio, 1,
            \modRatio, 1.414,
            \index, Pwhite(1.5, 3.0),
            \atk, 0.5,
            \rel, 2.0,
            \pan, Pseq([0.5, 0.0, -0.5], inf),
            \amp, 0.3
        ).play;
        // Active Wait State
        2.do { Pbindef(\gestureSeq, \index, rrand(2.0, 4.0)); 4.5.wait; };

        "0:45.0 - [Cue 8: Floor Scraping Acceleration]".postln;
        Ndef(\frictionStage).xset(\cutoff, 2500);
        2.do { Ndef(\frictionStage).xset(\noiseDens, rrand(5, 10)); 5.0.wait; };

        "0:55.0 - [Cue 9: Synchronized Duo]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf), \pan, 0).play;
        3.do { Pbindef(\tapSeq, \amp, rrand(0.3, 0.5)); 4.0.wait; }; // 12s

        "1:07.0 - [Cue 10: Density Build]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.125, 0.125, 0.25], inf));
        Pbindef(\gestureSeq, \dur, Pseq([0.5, 0.75, 0.5], inf), \atk, 0.1, \rel, 0.5);
        8.0.wait;

        "1:15.0 - [Cue 11: Deceleration Arc]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, 1.0, 1.5], inf), \decayScale, 0.4);
        Pbindef(\gestureSeq, \dur, Pseq([2.0, 3.0], inf), \atk, 1.0, \rel, 3.0);
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.2, 0.4)); 5.0.wait; }; // 10s

        "1:25.0 - [Cue 12: Phase I Dissolve (Subtraction)]".postln;
        Pbindef(\tapSeq).stop;
        Pbindef(\gestureSeq).stop;
        Ndef(\frictionStage).xset(\cutoff, 600, \noiseDens, 0);
        5.0.wait;


        // --- PHASE II: Theatrical Architecture & Group Formations ---
        "1:30.0 - [Cue 13: Group Entrance]".postln;
        // Launch 3 parallel instances via Pbindefs
        Pbindef(\gesture1, \instrument, \fluidGesture, \out, ~synthBus, \dur, 1.0, \freq, 400, \carRatio, 1.0, \amp, 0.2).play;
        Pbindef(\gesture2, \instrument, \fluidGesture, \out, ~synthBus, \dur, 1.5, \freq, 400, \carRatio, 1.2, \amp, 0.2).play;
        Pbindef(\gesture3, \instrument, \fluidGesture, \out, ~synthBus, \dur, 2.0, \freq, 400, \carRatio, 1.5, \amp, 0.2).play;
        6.0.wait;

        "1:36.0 - [Cue 14: Spatial Expansion]".postln;
        Ndef(\masterMix).xset(\wet10, 0.6, \smear, 15);
        2.do { Ndef(\masterMix).xset(\shift, rrand(0.1, 0.3)); 4.5.wait; }; // 9s

        "1:45.0 - [Cue 15: The Rhythmic Grid]".postln;
        Pbindef(\tapSeq, \dur, 0.5, \freq, 600, \decayScale, 0.1, \pan, 0).play;
        7.5.wait;

        "1:52.5 - [Cue 16: Micro-Hesitation]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.5, Rest(0.5), 0.25, Rest(0.25), 0.5], inf));
        3.5.wait;

        "1:56.0 - [Cue 17: Baroque Refraction]".postln;
        Pbindef(\gesture1, \modRatio, 2.0, \index, 5);
        Pbindef(\gesture2, \modRatio, 3.0, \index, 4);
        Pbindef(\gesture3, \modRatio, 4.0, \index, 6);
        2.do { Ndef(\masterMix).xset(\smear, rrand(10, 20)); 5.5.wait; }; // 11s

        "2:07.0 - [Cue 18: Unison Strike]".postln;
        Synth(\heavyImpact, [\out, ~synthBus, \freq, 200, \subFreq, 80, \amp, 0.7]);
        4.0.wait;

        "2:11.0 - [Cue 19: The Empty Stage (Subtraction)]".postln;
        Pbindef(\gesture1).stop; Pbindef(\gesture2).stop; Pbindef(\gesture3).stop; Pbindef(\tapSeq).stop;
        Ndef(\masterMix).xset(\wet10, 0);
        2.do { Ndef(\frictionStage).xset(\amp, rrand(0.1, 0.2)); 4.5.wait; }; // 9s

        "2:20.0 - [Cue 20: Polyrhythmic Re-emergence]".postln;
        Pbindef(\tapSeq, \dur, 0.8, \freq, 400).play; // 5:4 ratio against 1.0
        Pbindef(\gesture1, \dur, 1.0, \freq, 300, \modRatio, 1.5).play; // 4:4
        2.do { Pbindef(\tapSeq, \pan, rrand(-0.5, 0.5)); 5.0.wait; }; // 10s

        "2:30.0 - [Cue 21: Spectral Swell]".postln;
        Ndef(\masterMix).xset(\wet10, 0.9, \smear, 30);
        8.0.wait;

        "2:38.0 - [Cue 22: The Athletic Leap]".postln;
        Pbindef(\athleticLeap, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([0.25, 0.25, 0.5], 4), \freq, Pseq([100, 150, 80], inf), \amp, 0.6).play;
        5.5.wait;

        "2:43.5 - [Cue 23: Harmonic Saturation]".postln;
        Pbindef(\gesture1, \index, 15);
        2.do { Ndef(\frictionStage).xset(\cutoff, rrand(3000, 5000)); 4.25.wait; }; // 8.5s

        "2:52.0 - [Cue 24: Kinetic Chaos]".postln;
        Pbindef(\tapSeq, \pan, Pwhite(-1.0, 1.0), \freq, Pwhite(400, 1200));
        Pbindef(\gesture1, \pan, Pwhite(-1.0, 1.0), \carRatio, Pwhite(0.5, 2.5));
        2.do { Ndef(\masterMix).xset(\smear, rrand(10, 40)); 5.0.wait; }; // 10s

        "3:02.0 - [Cue 25: The Climax Collapse]".postln;
        Pbindef(\tapSeq, \dur, 0.125);
        Pbindef(\gesture1, \dur, 0.125);
        2.do { Pbindef(\tapSeq, \freq, Pwhite(1000, 3000)); 5.0.wait; }; // 10s

        "3:12.0 - [Cue 26: The Trapdoor (Form Op C)]".postln;
        // INSTANT SUBTRACTION
        Pbindef.removeAll;
        Ndef(\masterMix).set(\wet10, 0, \wet15, 0, \wet20, 0.05);
        Ndef(\ensembleDrone).xset(\amp, 0);
        Ndef(\frictionStage).xset(\amp, 0);
        1.0.wait;


        // --- PHASE III: The Ritualistic Ground ---
        "3:13.0 - [Cue 27: Solo Ritual Tap]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pseq([1.0, 1.5, 0.5, 1.0], inf),
            \freq, 150,
            \decayScale, 0.03, // Ultra-dry
            \pan, 0,
            \amp, 0.6
        ).play;
        7.0.wait;

        "3:20.0 - [Cue 28: Earth Resonance]".postln;
        Ndef(\ensembleDrone).fadeTime = 10;
        Ndef(\ensembleDrone).xset(\amp, 0.1, \subAmp, 0.7);
        2.do { Ndef(\ensembleDrone).xset(\subAmp, rrand(0.6, 0.8)); 5.0.wait; }; // 10s

        "3:30.0 - [Cue 29: Stamping Patterns]".postln;
        Pbindef(\impactSeq,
            \instrument, \heavyImpact,
            \out, ~synthBus,
            \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf),
            \freq, 80,
            \subFreq, 35,
            \cutoff, 400,
            \amp, 0.7
        ).play;
        8.0.wait;

        "3:38.0 - [Cue 30: Metallic Accent]".postln;
        Pbindef(\metalSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, Pseq([Rest(1.5), 0.5, Rest(2.0)], inf),
            \freq, 1200,
            \modRatio, 3.14, // Inharmonic ring
            \index, 8,
            \atk, 0.01,
            \rel, 0.2,
            \amp, 0.3
        ).play;
        6.5.wait;

        "3:44.5 - [Cue 31: Ceremonial Call]".postln;
        Pbindef(\gestureSeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 4.0,
            \freq, Pseq([200, 220, 190, 250], inf),
            \atk, 2.0,
            \rel, 4.0,
            \amp, 0.4
        ).play;
        2.do { Pbindef(\gestureSeq, \index, rrand(1.5, 3.0)); 4.75.wait; }; // 9.5s

        "3:54.0 - [Cue 32: The Circle Expands]".postln;
        Pbindef(\impactSeq2, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf), \freq, 85, \subFreq, 38, \amp, 0.5, \pan, -0.5, \lag, 0.05).play;
        Pbindef(\impactSeq3, \instrument, \heavyImpact, \out, ~synthBus, \dur, Pseq([1.0, 0.5, 0.5, 2.0], inf), \freq, 75, \subFreq, 32, \amp, 0.5, \pan, 0.5, \lag, 0.08).play;
        8.0.wait;

        "4:02.0 - [Cue 33: Accelerando Ritual]".postln;
        Pbindef(\impactSeq, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        Pbindef(\impactSeq2, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        Pbindef(\impactSeq3, \dur, Pseq([0.5, 0.25, 0.25, 1.0], inf));
        2.do { Pbindef(\tapSeq, \dur, rrand(0.25, 0.5)); 5.0.wait; }; // 10s

        "4:12.0 - [Cue 34: Iron Resonance]".postln;
        Pbindef(\metalSeq, \rel, 2.0);
        6.0.wait;

        "4:18.0 - [Cue 35: The Breath of the Crowd]".postln;
        Ndef(\frictionStage).xset(\amp, 0.4, \cutoff, 400, \noiseDens, 0);
        // Modulate amplitude slowly for breathing
        7.0.wait;

        "4:25.0 - [Cue 36: Peak Ground Sync]".postln;
        Pbindef(\impactSeq, \dur, 0.5);
        Pbindef(\impactSeq2, \dur, 0.5);
        Pbindef(\impactSeq3, \dur, 0.5);
        Pbindef(\tapSeq, \dur, 0.5);
        2.do { Ndef(\ensembleDrone).xset(\subAmp, rrand(0.8, 1.0)); 5.0.wait; }; // 10s

        "4:35.0 - [Cue 37: Sub-Bass Extension]".postln;
        Pbindef(\impactSeq, \cutoff, 200);
        5.0.wait;

        "4:40.0 - [Cue 38: Ground Dissolve (Subtraction)]".postln;
        Pbindef(\metalSeq).stop;
        Pbindef(\impactSeq2).stop; Pbindef(\impactSeq3).stop;
        5.0.wait;


        // --- PHASE IV: Kinetic Saturation & Athletic Training ---
        "4:45.0 - [Cue 39: The Starting Gun]".postln;
        Pbindef(\impactSeq).stop; Pbindef(\gestureSeq).stop;
        Pbindef(\tapSeq, \dur, 0.0625, \freq, 800, \decayScale, 0.02, \amp, 0.3).play;
        4.5.wait;

        "4:49.5 - [Cue 40: Kinetic Engine Ignition]".postln;
        Pbindef(\bassEngine,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 0.25,
            \freq, Pseq([50, 50, 60, 55], inf),
            \carRatio, 1,
            \modRatio, 2,
            \index, 10,
            \atk, 0.01,
            \rel, 0.2,
            \amp, 0.6
        ).play;
        6.5.wait;

        "4:56.0 - [Cue 41: Spatial Blur]".postln;
        Ndef(\masterMix).xset(\wet15, 0.7); // Ping-pong delay ON
        8.0.wait;

        "5:04.0 - [Cue 42: Athletic Exertion]".postln;
        Ndef(\frictionStage).xset(\amp, 0.5, \cutoff, 4000, \noiseDens, 50);
        7.5.wait;

        "5:11.5 - [Cue 43: Poly-Metric Superposition]".postln;
        Pbindef(\poly1, \instrument, \tapPluck, \out, ~synthBus, \dur, 0.75, \freq, 1200, \amp, 0.3).play; // 3/4
        Pbindef(\poly2, \instrument, \tapPluck, \out, ~synthBus, \dur, 1.0, \freq, 1500, \amp, 0.3).play;  // 4/4
        Pbindef(\poly3, \instrument, \tapPluck, \out, ~synthBus, \dur, 0.625, \freq, 1800, \amp, 0.3).play; // 5/8
        2.do { Pbindef(\bassEngine, \index, rrand(10, 20)); 4.25.wait; }; // 8.5s

        "5:20.0 - [Cue 44: Harmonic Ascent]".postln;
        Pbindef(\bassEngine, \freq, Pseq([100, 100, 120, 110], inf));
        7.0.wait;

        "5:27.0 - [Cue 45: Glitch Interruption]".postln;
        Pbindef(\tapSeq, \dur, Pseq([0.0625, 0.0625, Rest(0.125)], inf));
        5.0.wait;

        "5:32.0 - [Cue 46: High-Velocity Unison]".postln;
        Pbindef(\poly1, \dur, 0.125); Pbindef(\poly2, \dur, 0.125); Pbindef(\poly3, \dur, 0.125);
        Pbindef(\bassEngine, \dur, 0.125);
        6.0.wait;

        "5:38.0 - [Cue 47: Intrinsic Limit Approach (Form Op B)]".postln;
        Pbindef(\tapSeq, \dur, 0.03125, \freq, 3000); // 64th notes
        Pbindef(\bassEngine, \dur, 0.0625, \freq, 200, \index, 30);
        7.0.wait;

        "5:45.0 - [Cue 48: Parametric Collapse]".postln;
        // Instantly sweep the master LPF down
        Ndef(\masterMix).set(\masterLpf, 20000); // ensure start point
        Ndef(\masterMix).xset(\masterLpf, 150); // 5-second fade down via default fadeTime? Wait, let's explicit fade
        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\masterLpf, 150);
        5.0.wait;

        "5:50.0 - [Cue 49: Afterglow]".postln;
        Pbindef.removeAll; // Kill all frantic patterns
        Ndef(\masterMix).set(\wet15, 0); // Delay off
        Ndef(\masterMix).set(\wet20, 1.0); // Massive Reverb
        2.do { Ndef(\ensembleDrone).xset(\amp, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "6:00.0 - [Cue 50: Re-establishing Breath]".postln;
        Ndef(\masterMix).xset(\masterLpf, 20000); // Open filter back up slowly
        Ndef(\frictionStage).xset(\amp, 0.2, \cutoff, 600, \noiseDens, 0);
        8.0.wait;

        "6:08.0 - [Cue 51: Phase IV Outflow]".postln;
        Ndef(\masterMix).xset(\wet10, 0); // Spectral delay off
        7.0.wait;


        // --- PHASE V: Dissolution & Return ---
        "6:15.0 - [Cue 52: The Memory of Movement]".postln;
        Pbindef(\memorySeq,
            \instrument, \fluidGesture,
            \out, ~synthBus,
            \dur, 4.0,
            \freq, Pseq([600, 800, 550], inf),
            \carRatio, 1,
            \modRatio, 1.414,
            \index, 1.5,
            \atk, 2.0,
            \rel, 4.0,
            \amp, 0.2
        ).play;
        8.0.wait;

        "6:23.0 - [Cue 53: Soft Grounding]".postln;
        Pbindef(\softImpact, \instrument, \heavyImpact, \out, ~synthBus, \dur, 3.0, \freq, 60, \subFreq, 30, \cutoff, 200, \amp, 0.4).play;
        7.0.wait;

        "6:30.0 - [Cue 54: Ghost Taps]".postln;
        Pbindef(\tapSeq,
            \instrument, \tapPluck,
            \out, ~synthBus,
            \dur, Pwhite(1.0, 3.0),
            \freq, Pwhite(300, 600),
            \decayScale, 0.05,
            \pan, Pwhite(-1.0, 1.0),
            \amp, 0.15
        ).play;
        2.do { Pbindef(\tapSeq, \amp, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "6:40.0 - [Cue 55: Spatial Condensation]".postln;
        // Pull panning to center
        Pbindef(\tapSeq, \pan, Pwhite(-0.2, 0.2));
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.4, 0.6)); 5.0.wait; }; // 10s

        "6:50.0 - [Cue 56: Return to Departure (Form Op A)]".postln;
        Pbindef(\memorySeq).stop;
        Pbindef(\softImpact).stop;
        Pbindef(\tapSeq, \pan, 0, \freq, Pseq([300, 400, 350], inf)); // Original motif
        2.do { Pbindef(\tapSeq, \decayScale, rrand(0.02, 0.05)); 5.0.wait; }; // 10s

        "7:00.0 - [Cue 57: The Final Solo]".postln;
        Pbindef(\tapSeq, \dur, Pseq([2.0, 3.0, 4.0], inf));
        2.do { Pbindef(\tapSeq, \amp, rrand(0.05, 0.1)); 5.0.wait; }; // 10s

        "7:10.0 - [Cue 58: The Long Fade-Out]".postln;
        Ndef(\frictionStage).clear(10);
        Ndef(\ensembleDrone).clear(10);
        2.do { Ndef(\masterMix).xset(\wet20, rrand(0.1, 0.2)); 5.0.wait; }; // 10s

        "7:20.0 - [Cue 59: The Last Step]".postln;
        Pbindef(\tapSeq).stop;
        Synth(\tapPluck, [\out, ~synthBus, \freq, 320, \decayScale, 0.1, \amp, 0.1, \pan, 0]);
        8.0.wait;

        "7:28.0 - [Cue 60: Post-Event Silence]".postln;
        2.0.wait;

        "7:30.0 - [Cue 61: Extrinsic Limit Termination (Form Op D)]".postln;
        // CRITICAL TERMINATION
        Tdef.removeAll;
        Pbindef.removeAll;
        Ndef.clear;
        ServerTree.removeAll;
        s.freeAll;
        "7:30.0 - Score Complete. Absolute Silence.".postln;
    });

    // Execute the score
    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: compose-day-in-two-minutes.scd
(
// Fix: Use Pexprand instead of non-existent Pexprange
Pbindef(\ufoSeq, \dur, Pwhite(0.05, 0.15), \freq, Pexprand(800, 3000), \modFreq, Pexprand(100, 800), \t_trig, 1);

Tdef(\april14_eventHorizon, {

    "0:00 - [Movement I: Antiquity & Empires]".postln;
    Ndef(\ancientRes).play;
    Ndef(\holyChoir).play;

    Ndef(\ancientRes)[1] = \set -> Pbindef(\ancientSeq);
    Ndef(\holyChoir)[1] = \set -> Pbindef(\choirSeq);

    // Fade in massive cathedral/battlefield reverb over 5 seconds
    Ndef(\ancientRes).xset(\wet10, 0.6);
    Ndef(\holyChoir).xset(\wet10, 0.6);

    15.wait;

    "0:15 - [The Battles Intensify]".postln;
    Pbindef(\ancientSeq, \dur, 0.5); // Escalate strikes
    Ndef(\ancientRes).set(\decayscale, 0.2); // Violent, staccato decay

    15.wait; // Now at 0:30

    "0:30 - [Movement II: The Nuremberg Anomaly]".postln;
    Pbindef(\ancientSeq).stop;
    Ndef(\ancientRes).clear(4);

    Ndef(\ufoSweep).play;
    Ndef(\ufoSweep)[1] = \set -> Pbindef(\ufoSeq);

    // Push choir to background, unleash alien FM bursts with wild panning
    Ndef(\holyChoir).xset(\amp, 0.2);
    Ndef(\ufoSweep).set(\modIndex, 5, \wet12, 1.0);

    20.wait; // Now at 0:50

    "0:50 - [Movement III: Gunfire & Tremors]".postln;
    Pbindef(\ufoSeq).stop;
    Ndef(\ufoSweep).clear(2);

    Ndef(\kinetoClick).play;
    Ndef(\kinetoClick)[1] = \set -> Pbindef(\kinetoSeq);

    // Harsh, dry slapback delay
    Ndef(\kinetoClick).set(\wet11, 0.15);

    10.wait; // Now at 1:00

    "1:00 - [The Ljubljana Earthquake]".postln;
    Ndef(\earthquakeBass).play;
    Ndef(\earthquakeBass)[1] = \set -> Pbindef(\quakeSeq);

    // Sweep bass LPF up to reveal rumble, sweep choir HPF up to prevent masking
    Ndef(\earthquakeBass).xset(\lpfFreq, 200);
    Ndef(\holyChoir).xset(\hpfFreq, 300);

    15.wait; // Now at 1:15

    "1:15 - [Movement IV: The Dawn of Modernity]".postln;
    Pbindef(\quakeSeq).stop;
    Ndef(\earthquakeBass).clear(5);

    // Relentless 16th note mechanical rhythm
    Pbindef(\kinetoSeq, \dur, 0.125);

    // Choir returns with modern, majestic voicings
    Ndef(\holyChoir).xset(\amp, 0.5);
    Pbindef(\choirSeq, \freq, Pseq([349.23, 440.00, 329.63], inf)); // F, A, E

    // Turn dry clicks into a whirring film projector
    Ndef(\kinetoClick).xset(\wet11, 0.6, \fbTime, 2.0);

    30.wait; // Now at 1:45

    "1:45 - [Movement V: The Fade into History]".postln;
    Pbindef(\kinetoSeq).stop;
    Ndef(\kinetoClick).clear(5);

    // Tape-stop pitch shift and wash into 100% wet reverb
    Ndef(\holyChoir).xset(\freqMult, 0.5, \wet10, 1.0);

    15.wait; // Now at 2:00

    "2:00 - [Absolute Silence]".postln;
    Pbindef(\choirSeq).stop;

    // 10-second unsegmented fade out to silence
    Ndef(\ancientRes).clear(10);
    Ndef(\holyChoir).clear(10);
    Ndef(\ufoSweep).clear(10);
    Ndef(\kinetoClick).clear(10);
    Ndef(\earthquakeBass).clear(10);

    "Score Complete.".postln;
});

// Create GUI
s.makeGui;
)

// Source: compose-engine.scd
(
s.waitForBoot({

    var masterScore;
    var timestamp = Date.getDate.stamp;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false;
    //~enableRecording = true;  // <--- UNCOMMENT TO ENABLE MULTITRACK RECORDING

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING, BUFFERS & RECORDING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/EnergyNexus_Multitrack/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        synths: Bus.audio(s, 2),
        coreEngine: Bus.audio(s, 2),
        potentialField: Bus.audio(s, 2),
        heatCore: Bus.audio(s, 2),
        geoHiss: Bus.audio(s, 2),
        transport: Bus.audio(s, 2),
        spectralGrind: Bus.audio(s, 2),
        convection: Bus.audio(s, 2),
        envHum: Bus.audio(s, 2),
        dissipation: Bus.audio(s, 2),
        master: 0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Pre-allocate FFT Buffers for Ndef(\spectralGrind)
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);
    ~fftBuf2L = Buffer.alloc(s, 2048);
    ~fftBuf2R = Buffer.alloc(s, 2048);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\gearClick, { |out=0, recOut, freq=800, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 2);
        var sig = SinOsc.ar(freq) * env;
        var noise = WhiteNoise.ar * env * 0.5;
        var finalSig = Pan2.ar(sig + noise, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\ticking, { |out=0, recOut, freq=2500, amp=0.3, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.02), doneAction: 2);
        var sig = BPF.ar(PinkNoise.ar, freq, 0.1) * env * 5;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\subBoom, { |out=0, recOut, freq=40, amp=0.8, pan=0|
        var env = EnvGen.ar(Env.perc(0.05, 2.5, curve: -4), doneAction: 2);
        var sig = SinOsc.ar(freq + (EnvGen.ar(Env.perc(0.01, 0.2)) * freq));
        var finalSig = Pan2.ar(sig.tanh, pan) * env * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\electricArc, { |out=0, recOut, freq=5000, amp=0.4, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.1), doneAction: 2);
        var sig = LFNoise0.ar(freq) * env;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\chemicalBubble, { |out=0, recOut, freq=600, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
        var sig = SinOsc.ar(freq * (1 + (LFNoise1.kr(50) * 0.5))) * env;
        var finalSig = Pan2.ar(sig, pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\nuclearBurst, { |out=0, recOut, freq=100, amp=0.6, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, 0.3), doneAction: 2);
        var sig = BrownNoise.ar * env;
		var finalSig;
        sig = RLPF.ar(sig, freq * XLine.ar(5, 1, 0.1), 0.1) * 3;
        finalSig = Pan2.ar(sig.fold2(0.8), pan) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\powerHum, { |out=0, recOut, amp=0.5, gate=1|
        var env = EnvGen.ar(Env.asr(0.5, 1, 0.1), gate, doneAction: 2);
        var sig = Splay.ar(SinOsc.ar([50, 50.3, 150, 151, 250.5]));
        var finalSig = sig.tanh * env * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\industrialKick, { |out=0, recOut, amp=0.8|
        var env = EnvGen.ar(Env.perc(0.01, 0.4), doneAction: 2);
        var sig = SinOsc.ar(XLine.ar(200, 40, 0.1)) * env;
		var finalSig;
        sig = sig + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.01, 0.05)) * 0.3);
        finalSig = Pan2.ar(sig.tanh, 0) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    SynthDef(\industrialClang, { |out=0, recOut, freq=400, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.01, 0.8), doneAction: 2);
        var sig = PMOsc.ar(freq, freq * 1.414, 3) * env;
        var finalSig = Pan2.ar(sig, 0) * amp;
        Out.ar(out, finalSig);
        Out.ar(recOut, finalSig);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\coreEngineHum, { |fmIndex=0.5, amp=0|
        var mod = SinOsc.ar(25) * fmIndex * 50;
        var sig = SinOsc.ar(50 + mod) + SinOsc.ar(50.5 + mod);
        sig = LPF.ar(sig, 400);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\coreEngineHum).play(~recBuses.coreEngine);

    Ndef(\potentialField, { |cutoff=50, amp=0|
        var sig = WhiteNoise.ar;
        sig = RLPF.ar(sig, cutoff, 0.05) * 5;
        Pan2.ar(sig * amp, SinOsc.kr(0.1));
    });
    Ndef(\potentialField).play(~recBuses.potentialField);

    Ndef(\heatCore, { |fmIndex=1, distortion=1, hpFreq=20, amp=0|
        var sig = Saw.ar([100, 101]) + Pulse.ar([50, 50.2], 0.3);
        sig = MoogFF.ar(sig, 800 + (fmIndex * 1000), 1.5);
        sig = (sig * distortion).tanh;
        sig = HPF.ar(sig, hpFreq);
        sig * amp * 0.4;
    });
    Ndef(\heatCore).play(~recBuses.heatCore);

    Ndef(\geoHiss, { |amp=0|
        var lpfEnv = LFNoise1.kr(8).exprange(500, 8000);
        var sig = WhiteNoise.ar(0.5) + PinkNoise.ar(0.5);
        sig = LPF.ar(sig, lpfEnv);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\geoHiss).play(~recBuses.geoHiss);

    Ndef(\transportRhythm, { |rate=2, amp=0|
        var trig = Impulse.ar(rate);
        var env = Decay2.ar(trig, 0.01, 0.3);
        var sig = SinOsc.ar(60) * env;
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\transportRhythm).play(~recBuses.transport);

    Ndef(\spectralGrind, { |amp=0|
        var sig1 = PinkNoise.ar;
        var sig2 = Saw.ar(LFNoise1.kr(2).exprange(50, 500));
        var chain1L = FFT(~fftBufL, sig1);
        var chain2L = FFT(~fftBuf2L, sig2);
        var chain1R = FFT(~fftBufR, sig1);
        var chain2R = FFT(~fftBuf2R, sig2);
        var processedL = PV_MagMul(chain1L, chain2L);
        var processedR = PV_MagMul(chain1R, chain2R);
        var out = [IFFT(processedL), IFFT(processedR)];
        out * amp * 0.05;
    });
    Ndef(\spectralGrind).play(~recBuses.spectralGrind);

    Ndef(\convectionSweep, { |amp=0, pitch=100|
        var sig = PinkNoise.ar;
        sig = BPF.ar(sig, pitch, 0.1) * 10;
        Pan2.ar(sig * amp, SinOsc.kr(0.05));
    });
    Ndef(\convectionSweep).play(~recBuses.convection);

    Ndef(\environmentalHum, { |amp=0|
        var sig = PMOsc.ar(60, 120, 2);
        Pan2.ar(sig.fold2(0.5) * amp, 0);
    });
    Ndef(\environmentalHum).play(~recBuses.envHum);

    Ndef(\dissipationTrail, { |delayTime=0.5, feedback=0.5, amp=0|
        var in = In.ar(~synthBus, 2) + Ndef.ar(\convectionSweep, 2);
        var sig = CombC.ar(in, 2.0, delayTime, feedback * 10);
        sig * amp;
    });
    Ndef(\dissipationTrail).play(~recBuses.dissipation);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var core = Ndef.ar(\coreEngineHum, 2) + Ndef.ar(\potentialField, 2);
        var heat = Ndef.ar(\heatCore, 2) + Ndef.ar(\geoHiss, 2);
        var ind = Ndef.ar(\transportRhythm, 2) + Ndef.ar(\spectralGrind, 2);
        var env = Ndef.ar(\convectionSweep, 2) + Ndef.ar(\environmentalHum, 2);
        var trail = Ndef.ar(\dissipationTrail, 2);

        synths + core + heat + ind + env + trail;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2);
        // JITLib auto-generates \wet10
        verb;
    };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var path;
        ~recSynths = ();
        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        ~recBuses.keysValuesDo { |name, bus|
            path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };
        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };
        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        var powerHumNode;

        if(~enableRecording) { ~startRecording.value; } { "--- PLAYBACK ONLY ---".postln; };

        "0:00 - [Cue 1: Server Init]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Mechanical Impulse]".postln;
        Pbindef(\gearClicks,
            \instrument, \gearClick,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([0.25, 0.25, 0.5, 0.125, 0.875], inf),
            \freq, Pexprand(600, 1200),
            \amp, 0.6,
            \pan, Pwhite(-0.3, 0.3)
        ).play;
        3.wait;

        "0:03.5 - [Cue 3: Core Engine Hum]".postln;
        Ndef(\coreEngineHum).fadeTime = 2;
        Ndef(\coreEngineHum).xset(\amp, 0.7);
        // Active wait for 6.5s
        3.do {
            Ndef(\coreEngineHum).xset(\fmIndex, rrand(0.5, 2.0));
            2.16.wait;
        };

        "0:10.0 - [Cue 4: Potential Fields Begin]".postln;
        Pbindef(\gearClicks, \dur, Pseq([0.5, 1.0, 1.5], inf)); // Thins out
        Ndef(\masterMix).xset(\wet10, 0.1);
        Ndef(\potentialField).fadeTime = 5;
        Ndef(\potentialField).xset(\amp, 0.5, \cutoff, 500);
        5.wait;

        "0:15.0 - [Cue 5: Precise Mechanisms]".postln;
        Pbindef(\gearClicks).stop; // Subtraction
        Ndef(\coreEngineHum).xset(\amp, 0.5);
        Pbindef(\tickingSequence,
            \instrument, \ticking,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, 0.125,
            \freq, Pseq([2500, 3000, 2000], inf),
            \amp, 0.4
        ).play;
        8.wait;

        "0:23.0 - [Cue 6: Gravitational Descent]".postln;
        Ndef(\potentialField).fadeTime = 7;
        Ndef(\potentialField).xset(\cutoff, 100);
        Pbindef(\gravityBoom,
            \instrument, \subBoom,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pwrand([2, 3, 5], [0.5, 0.3, 0.2], inf),
            \freq, 40,
            \amp, 0.9
        ).play;
        7.wait;

        "0:30.0 - [Cue 7: Electric Spark]".postln;
        Pbindef(\tickingSequence).stop; // Subtraction
        Ndef(\potentialField).set(\amp, 0); // Hard cut
        Pbindef(\electricArc,
            \instrument, \electricArc,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Prand([0.05, 0.1, 0.2], inf),
            \freq, Pexprand(3000, 8000),
            \amp, 0.5
        ).play;
        2.wait;

        "0:32.0 - [Cue 8: Heat Engine Ignition]".postln;
        Ndef(\heatCore).fadeTime = 3;
        Ndef(\heatCore).xset(\amp, 0.6);
        Pbindef(\electricArc, \dur, Pwrand([0.2, 0.5, 1.0], [0.7, 0.2, 0.1], inf));
        // Active wait: 10 seconds
        2.do { |i|
            Ndef(\heatCore).xset(\fmIndex, 1 + (i*2), \distortion, 1 + (i*0.5));
            5.wait;
        };

        "0:42.0 - [Cue 9: Geothermal Vent]".postln;
        Pbindef(\electricArc).stop; // Subtraction
        Ndef(\geoHiss).fadeTime = 0.5;
        Ndef(\geoHiss).xset(\amp, 0.5);
        4.wait;

        "0:46.0 - [Cue 10: Chemical Reaction]".postln;
        Ndef(\geoHiss).set(\amp, 0); // Subtraction
        Ndef(\masterMix).xset(\wet10, 0.5);
        Pbindef(\chemicalBubble,
            \instrument, \chemicalBubble,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pwhite(0.05, 0.3),
            \freq, Pexprand(400, 1200),
            \amp, 0.6
        ).play;
        6.wait;

        "0:52.0 - [Cue 11: Nuclear Core Reactivation]".postln;
        Pbindef(\chemicalBubble).stop; // Subtraction
        Ndef(\heatCore).xset(\amp, 0.8);
        Pbindef(\nuclearBurst,
            \instrument, \nuclearBurst,
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([1.5, 1.0, 0.5, 0.25], inf), // Accelerating density
            \freq, Pexprand(50, 200),
            \amp, 0.7
        ).play;
        8.wait;

        "1:00.0 - [Cue 12: Fission Cascade]".postln;
        Pbindef(\nuclearBurst, \dur, Pwhite(0.05, 0.15)); // Peak density
        Ndef(\heatCore).xset(\hpFreq, 500);
        // Active wait: 10 seconds
        2.do {
            Ndef(\heatCore).xset(\distortion, rrand(2.0, 4.0));
            5.wait;
        };

        "1:10.0 - [Cue 13: Power Grid Overload]".postln;
        Pbindef(\nuclearBurst).stop; // Subtraction
        Ndef(\heatCore).xset(\hpFreq, 20);
        powerHumNode = Synth(\powerHum, [\out, ~synthBus, \recOut, ~recBuses.synths, \amp, 0.8]);
        5.wait;

        "1:15.0 - [Cue 14: Abrupt Reset]".postln;
        Ndef(\heatCore).set(\amp, 0); // Hard cut
        powerHumNode.set(\gate, 0); // Hard cut via quick env
        Ndef(\masterMix).set(\wet10, 0.1);
        2.wait;

        "1:17.0 - [Cue 15: Mechanical Recall]".postln;
        Pbindef(\gearClicks, \dur, 1.0, \freq, 400).play;
        Ndef(\coreEngineHum).fadeTime = 3;
        Ndef(\coreEngineHum).xset(\amp, 0.7, \fmIndex, 0.5);
        8.wait;

        "1:25.0 - [Cue 16: Transportation Pulse]".postln;
        Pbindef(\gearClicks, \dur, 0.25);
        Ndef(\transportRhythm).fadeTime = 2;
        Ndef(\transportRhythm).xset(\amp, 0.8);
        // Active wait: 10 seconds
        5.do { |i|
            Ndef(\transportRhythm).xset(\rate, 2 + (i*0.5));
            2.wait;
        };

        "1:35.0 - [Cue 17: Industrial Grinding]".postln;
        Pbindef(\gearClicks).stop; // Subtraction
        Ndef(\coreEngineHum).fadeTime = 2;
        Ndef(\coreEngineHum).xset(\amp, 0);
        Ndef(\spectralGrind).fadeTime = 1;
        Ndef(\spectralGrind).xset(\amp, 0.8);
        7.wait;

        "1:42.0 - [Cue 18: Cutting and Crushing]".postln;
        Pbindef(\industrialRhythm,
            \instrument, Pseq([\industrialKick, \industrialClang, \industrialKick, \industrialClang], inf),
            \out, ~synthBus,
            \recOut, ~recBuses.synths,
            \dur, Pseq([0.5, 0.25, 0.25, 0.5], inf),
            \amp, 0.8
        ).play;
        8.wait;

        "1:50.0 - [Cue 19: Mixing Chaos]".postln;
        Pbindef(\industrialRhythm, \dur, Pwhite(0.125, 0.25));
        // Active wait: 7 seconds
        7.do {
            Ndef(\spectralGrind).xset(\amp, rrand(0.7, 1.0));
            1.wait;
        };

        "1:57.0 - [Cue 20: Convection Cell Rise]".postln;
        Pbindef(\industrialRhythm).stop; // Subtraction
        Ndef(\spectralGrind).set(\amp, 0); // Hard cut
        Pbindef(\gravityBoom).stop;

        Ndef(\convectionSweep).fadeTime = 4;
        Ndef(\convectionSweep).xset(\amp, 0.6);
        // Active wait: 8 seconds
        4.do { |i|
            Ndef(\convectionSweep).xset(\pitch, 100 + (i*100));
            2.wait;
        };

        "2:05.0 - [Cue 21: Environmental Heat]".postln;
        Ndef(\environmentalHum).fadeTime = 1;
        Ndef(\environmentalHum).xset(\amp, 0.4);
        6.wait;

        "2:11.0 - [Cue 22: Energy Dissipation Begins]".postln;
        Ndef(\environmentalHum).set(\amp, 0); // Subtraction
        Ndef(\convectionSweep).fadeTime = 10;
        Ndef(\convectionSweep).xset(\amp, 0, \pitch, 50);

        Ndef(\dissipationTrail).fadeTime = 2;
        Ndef(\dissipationTrail).xset(\amp, 1.0, \delayTime, 0.5, \feedback, 0.6);
        Ndef(\masterMix).xset(\wet10, 0.9);

        // Active wait: 10 seconds
        5.do {
            Ndef(\dissipationTrail).xset(\delayTime, rrand(0.4, 0.8));
            2.wait;
        };

        "2:21.0 - [Cue 23: Final Echoes]".postln;
        // Active wait: 9 seconds
        3.do { |i|
            Ndef(\dissipationTrail).xset(\delayTime, 1.0 + (i*0.2), \feedback, 0.6 - (i*0.1));
            3.wait;
        };

        "2:30.0 - [Cue 24: Absolute Silence (TERMINATION)]".postln;
        Ndef.clear(10);
        Pbindef.removeAll;

        10.wait; // Wait for the fade to complete

        ~stopRecording.value;
        Tdef.removeAll;
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    s.makeGui;
});
)

// Source: compose-helicopter.scd
(
s.waitForBoot({

    var masterScore;

    // --------------------------------------------------------------------
    // GLOBAL CONFIGURATION
    // --------------------------------------------------------------------
    ~enableRecording = false; // Fallback state
    //~enableRecording = true;  // <--- UNCOMMENT THIS LINE TO ENABLE RECORDING

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & RECORDING BUFFERS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    ~recFolder = "~/Desktop/SC_Multitrack_Recording/".standardizePath;
    File.mkdir(~recFolder);

    ~recBuses = (
        drone: Bus.audio(s, 2),
        flaps: Bus.audio(s, 2),
        ping: Bus.audio(s, 2),
        swirl: Bus.audio(s, 2),
        glitch: Bus.audio(s, 2),
        chopper: Bus.audio(s, 2),
        hum: Bus.audio(s, 2),
        granular: Bus.audio(s, 2),
        master: 0
    );

    ~recBufs = ();
    ~recBuses.keysValuesDo { |name, bus|
        ~recBufs[name] = Buffer.alloc(s, 65536, 2);
    };

    // Global FFT Buffers
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);

    // Granular Noise Buffer
    ~noiseBuf = Buffer.alloc(s, s.sampleRate * 2, 1);

    SynthDef(\diskRecorder, { |bus, bufnum|
        var sig = In.ar(bus, 2);
        DiskOut.ar(bufnum, sig);
    }).add;

    s.sync;

    // Fill noise buffer
    { RecordBuf.ar(WhiteNoise.ar, ~noiseBuf, loop: 0, doneAction: 2) }.play;
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\pteronFlaps, { |out=0, recOut, freq=4000, filterFreq=4000, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 2);
        var sig = WhiteNoise.ar;
        var final = Pan2.ar(sig * amp, pan);

        sig = BPF.ar(sig, filterFreq, 0.3) * env;

        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\metallicPing, { |out=0, recOut, freq=1800, decay=4, amp=0.3, pan=0, detune=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var sig = PMOsc.ar(freq * (1 + detune), freq * 2.1, 2) * env;
        var final = Pan2.ar(sig * amp, pan);
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\glitchFm, { |out=0, recOut, freq=5000, fmIndex=5, amp=0.15, pan=0, decay=0.05|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * fmIndex * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        var final = Pan2.ar(sig * amp, pan);
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\chopperPulse, { |out=0, recOut, freq=60, filterFreq=300, rq=0.6, amp=0.3, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction: 2);
        var sig = Pulse.ar(freq, 0.2);
        var final = Pan2.ar(sig * amp, pan);

        sig = RLPF.ar(sig, filterFreq, rq);
        sig = sig * (LFSaw.ar(15).range(0.1, 1));

        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    SynthDef(\airyGranular, { |out=0, recOut, buf, grainDur=0.05, rate=20, filterFreq=10000, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction: 2);
        var trig = Impulse.ar(rate);
        var sig = GrainBuf.ar(2, trig, grainDur, buf, 1, LFNoise1.ar(100).range(0, 1), 2, pan);
        var final;

		final = sig * amp;
        Out.ar(out, final);
        Out.ar(recOut, final);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\helixDrone, { |freq=60, modIndex=0.05, modFreq=5, filterFreq=100, rq=0.8, amp=0, pan=0|
        var mod = modIndex * 10 * SinOsc.ar(modFreq);
        var sig = PMOsc.ar(freq, freq * 1.5, mod);
        sig = RLPF.ar(sig, filterFreq, rq);
        Pan2.ar(sig * amp, pan);
    });
    Ndef(\helixDrone).play(~recBuses.drone);

	Ndef(\spectralSwirl, { |freqShift=0, amp=1, pan=0|
		var in = Ndef.ar(\helixDrone, 2);
		var sig;

		// FreqShift operates directly on the audio signal in Hz
		sig = FreqShift.ar(in, freqShift);

		Balance2.ar(sig[0], sig[1], pan, amp);
	});
    Ndef(\spectralSwirl).play(~recBuses.swirl);

    Ndef(\whirlyHum, { |freq=200, modRate=2, filterFreq=500, amp=0|
        var sig = PinkNoise.ar;
        sig = BPF.ar(sig, freq, 0.2) + HPF.ar(sig, filterFreq);
        sig = sig * SinOsc.ar(modRate).range(0.2, 1);
        Pan2.ar(sig * amp, 0);
    });
    Ndef(\whirlyHum).play(~recBuses.hum);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var drone = Ndef.ar(\helixDrone, 2);
        var swirl = Ndef.ar(\spectralSwirl, 2);
        var hum = Ndef.ar(\whirlyHum, 2);
        synths + drone + swirl + hum;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var delayTime = \delayTime.kr(0.5);
        CombC.ar(in, 2.0, delayTime, 3.0);
    };
    Ndef(\masterMix).set(\wet10, 0);

    Ndef(\masterMix)[20] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2);
    };
    Ndef(\masterMix).set(\wet20, 0);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // RECORDING CONTROL FUNCTIONS
    // --------------------------------------------------------------------
    ~startRecording = {
        var timestamp = Date.getDate.stamp;
        ~recSynths = ();

        "--- MULTITRACK RECORDING INITIALIZED ---".postln;
        "Saving to: %".format(~recFolder).postln;

        ~recBuses.keysValuesDo { |name, bus|
            var path = ~recFolder ++ timestamp ++ "_" ++ name ++ ".wav";
            ~recBufs[name].write(path, "wav", "int24", 0, 0, true);
        };

        ~recBuses.keysValuesDo { |name, bus|
            ~recSynths[name] = Synth.tail(RootNode(s), \diskRecorder, [\bus, bus, \bufnum, ~recBufs[name]]);
        };

        CmdPeriod.doOnce({ ~stopRecording.value });
    };

    ~stopRecording = {
        if(~recSynths.notNil) {
            "--- CLOSING AUDIO FILES ---".postln;
            ~recSynths.do(_.free);
            ~recBufs.do(_.close);
            ~recBufs.do(_.free);
            ~recSynths = nil;
            "Multitrack Recording Complete.".postln;
        };
    };

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {
        if(~enableRecording) {
            ~startRecording.value;
        } {
            "--- PLAYBACK ONLY (RECORDING DISABLED) ---".postln;
        };

        "0:00 - [Cue 1: Server Init (0.5s)]".postln;
        0.5.wait;

        "0:00.5 - [Cue 2: Helix Hum - Subterranean Stirrings (10.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 10;
        Ndef(\helixDrone).xset(\freq, 60, \modIndex, 0.1, \filterFreq, 120, \rq, 0.8, \amp, 0.25);
        2.do {
            Ndef(\helixDrone).xset(\modFreq, rrand(4.8, 5.2));
            5.wait;
        };

        "0:10.5 - [Cue 3: First Coil - Phase & Resonance (12.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 12;
        Ndef(\helixDrone).xset(\modIndex, 0.2, \modFreq, 8, \filterFreq, 250, \rq, 0.7);
        3.do { |i|
            Ndef(\helixDrone).xset(\pan, sin(i) * 0.2);
            4.wait;
        };

        "0:22.5 - [Cue 4: Pteron's Whispers - Irregular Gestures (8.0s)]".postln;
        Pbindef(\pteronFlaps,
            \instrument, \pteronFlaps,
            \out, ~synthBus,
            \recOut, ~recBuses.flaps,
            \freq, 4000,
            \dur, Prand([0.8, 1.2, 0.5], inf),
            \amp, Pseq([0.1, 0.05, 0.12], inf),
            \pan, Prand([-0.8, 0.8], inf)
        ).play;
        2.do { 4.wait; };

        "0:30.5 - [Cue 5: Convolutional Rise - Spectral Opening (15.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 15;
        Ndef(\helixDrone).xset(\filterFreq, 800, \modIndex, 0.35, \amp, 0.3);
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet20, 0.2); // Reverb up
        Pbindef(\pteronFlaps, \dur, Pseq([0.6, 0.9, 0.4], inf));

        3.do { 5.wait; };

        "0:45.5 - [Cue 6: Metallic Precision - Isolated & Clear (9.0s)]".postln;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        2.5.wait;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        3.5.wait;
        Synth(\metallicPing, [\out, ~synthBus, \recOut, ~recBuses.ping, \freq, 1800, \decay, 4.0, \amp, 0.3]);
        3.0.wait;

        "0:54.5 - [Cue 7: Helix Accelerando - Density & Panning (13.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 13;
        Ndef(\helixDrone).xset(\modFreq, 18, \amp, 0.35, \modIndex, 0.45);
        Pbindef(\pteronFlaps, \dur, Prand([0.3, 0.4, 0.2], inf), \amp, 0.25, \pan, Pwhite(-1.0, 1.0, inf));
        2.do { 6.5.wait; };

        "1:07.5 - [Cue 8: Spectral Bloom - Expansive & Shifting (18.0s)]".postln;
        Ndef(\spectralSwirl).fadeTime = 18;
        Ndef(\spectralSwirl).xset(\amp, 1);
        Ndef(\masterMix).fadeTime = 18;
        Ndef(\masterMix).xset(\wet10, 0.1); // Delay up slightly

        3.do { |i|
            var shift = [-50, 0, 50].wrapAt(i);
            Ndef(\spectralSwirl).xset(\freqShift, shift, \pan, sin(i * 0.5));
            6.wait;
        };

        "1:25.5 - [Cue 9: Fluttering Formations - Rhythmic & Focused (10.0s)]".postln;
        Pbindef(\pteronFlaps, \dur, Pseq([0.15, 0.25], inf), \amp, Pseq([0.3, 0.28], inf), \filterFreq, 6000);
        2.do { 5.wait; };

        "1:35.5 - [Cue 10: Momentum Hold - Static Energy (6.0s)]".postln;
        s.sync;
        6.wait;

        "1:41.5 - [Cue 11: Brief Deceleration - Tension Release (9.0s)]".postln;
        Pbindef(\pteronFlaps).stop; // SUBTRACTION
        Ndef(\helixDrone).fadeTime = 9;
        Ndef(\helixDrone).xset(\modFreq, 8, \modIndex, 0.1, \amp, 0.2);
        Ndef(\spectralSwirl).xset(\amp, 0.1);

        3.do { 3.wait; };

        "1:50.5 - [Cue 12: Resonant Depth - Reverb & Decay (15.0s)]".postln;
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet20, 0.6);
        Ndef(\helixDrone).fadeTime = 15;
        Ndef(\helixDrone).xset(\filterFreq, 200, \rq, 0.9, \amp, 0.15, \pan, 0);

        3.do { 5.wait; };

        "2:05.5 - [Cue 13: Metallic Echoes - Dissonant & Scattered (12.0s)]".postln;
        Pbindef(\pingSeq,
            \instrument, \metallicPing,
            \out, ~synthBus,
            \recOut, ~recBuses.ping,
            \dur, 0.5,
            \freq, Pwhite(1000, 2500, inf),
            \detune, Pwhite(-0.01, 0.01, inf),
            \amp, 0.2,
            \pan, Pwhite(-0.9, 0.9, inf)
        ).play;

        3.do { 4.wait; };

        "2:17.5 - [Cue 14: Helix Surge - Full Spectrum & Power (22.0s)]".postln;
        Ndef(\helixDrone).fadeTime = 22;
        Ndef(\helixDrone).xset(\modIndex, 0.9, \amp, 0.4, \modFreq, 25);
        Ndef(\spectralSwirl).xset(\amp, 0.7);

        // Complex sweeping over 22 seconds
        Ndef(\helixDrone).xset(\filterFreq, 1500);
        2.do { 5.5.wait; };
        Ndef(\helixDrone).xset(\filterFreq, 4000);
        2.do { 5.5.wait; };

        "2:39.5 - [Cue 15: Pteron's Climax - Max Density & Velocity (10.0s)]".postln;
        Pbindef(\pteronFlaps, \dur, 0.075, \amp, 0.4, \pan, Pseq([-1, 1], inf), \filterFreq, 8000).play;
        2.do { 5.wait; };

        "2:49.5 - [Cue 16: Abrupt Deconstruction - First Glitch (6.0s)]".postln;
        Pbindef(\pteronFlaps).stop;
        Pbindef(\pingSeq).stop;
        Ndef(\helixDrone).set(\modIndex, 0.1, \amp, 0.2); // HARD SET
        Ndef(\spectralSwirl).set(\amp, 0.1);
        s.sync;
        6.wait;

        "2:55.5 - [Cue 17: Glitchy Rebracket - High Freq Fragmentation (12.0s)]".postln;
        Pbindef(\glitchSeq,
            \instrument, \glitchFm,
            \out, ~synthBus,
            \recOut, ~recBuses.glitch,
            \dur, 0.2,
            \freq, Pwhite(5000, 8000, inf),
            \fmIndex, Pwhite(5, 10, inf),
            \amp, 0.15,
            \pan, Pwhite(-1.0, 1.0, inf),
            \decay, Pwhite(0.01, 0.05, inf)
        ).play;

        3.do { 4.wait; };

        "3:07.5 - [Cue 18: Chopper Pulse - Rhythmic Core (15.0s)]".postln;
        Pbindef(\chopperSeq,
            \instrument, \chopperPulse,
            \out, ~synthBus,
            \recOut, ~recBuses.chopper,
            \dur, Pseq([0.25, 0.15, 0.3, 0.1], inf),
            \freq, 60,
            \filterFreq, 300,
            \rq, 0.6,
            \amp, 0.3
        ).play;

        3.do { 5.wait; };

        "3:22.5 - [Cue 19: Whirly Hum - Growing Presence (18.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 18;
        Ndef(\whirlyHum).xset(\amp, 0.2, \freq, 800, \filterFreq, 1500);

        3.do { 6.wait; };

        "3:40.5 - [Cue 20: Linguistic Scramble - Rapid Glitches & Pan (12.0s)]".postln;
        Pbindef(\glitchSeq, \dur, 0.1);
        Ndef(\whirlyHum).fadeTime = 12;
        Ndef(\whirlyHum).xset(\modRate, 10, \amp, 0.25);

        3.do { 4.wait; };

        "3:52.5 - [Cue 21: Helipad Approach - Settling Down (9.0s)]".postln;
        Pbindef(\chopperSeq).stop;
        Pbindef(\glitchSeq).stop;
        Ndef(\whirlyHum).fadeTime = 9;
        Ndef(\whirlyHum).xset(\amp, 0.1, \freq, 400, \modRate, 2);

        3.do { 3.wait; };

        "4:01.5 - [Cue 22: Quadcopter Flutter - Agile & Delicate (15.0s)]".postln;
        Pbindef(\granularSeq,
            \instrument, \airyGranular,
            \out, ~synthBus,
            \recOut, ~recBuses.granular,
            \buf, ~noiseBuf,
            \grainDur, 0.05,
            \rate, 20,
            \filterFreq, 10000,
            \amp, 0.2,
            \pan, Pwhite(-0.7, 0.7, inf),
            \dur, 0.1, // Triggering envelope rapidly
            \grainRate, Pseq([20, 30, 25, 35], inf)
        ).play;

        3.do { 5.wait; };

        "4:16.5 - [Cue 23: Whirlybird Soar - Euphoric Ascent (18.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 18;
        Ndef(\whirlyHum).xset(\freq, 3000, \modRate, 15, \amp, 0.3);
        Pbindef(\granularSeq, \filterFreq, 12000);

        3.do { 6.wait; };

        "4:34.5 - [Cue 24: Chopper's Resurgence - Heavy & Distorted (12.0s)]".postln;
        Pbindef(\granularSeq).stop;
        Pbindef(\chopperSeq, \dur, Pseq([0.4, 0.6, 0.3], inf), \amp, 0.4, \filterFreq, 200, \rq, 0.9).play;

        3.do { 4.wait; };

        "4:46.5 - [Cue 25: Convoluted Descent - Winding Down (15.0s)]".postln;
        Ndef(\whirlyHum).fadeTime = 15;
        Ndef(\whirlyHum).xset(\freq, 200, \modRate, 1, \filterFreq, 400);
        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\wet10, 0.3, \delayTime, 0.5, \wet20, 0.5);
        Pbindef(\chopperSeq, \dur, Pwhite(0.5, 1.5, inf), \amp, Pgeom(0.4, 0.9, inf));

        3.do { 5.wait; };

        "5:01.5 - [Cue 26: Etymological Echoes - Return to Origin (18.0s)]".postln;
        Pbindef(\chopperSeq).stop;
        Ndef(\whirlyHum).xset(\amp, 0);
        Ndef(\helixDrone).fadeTime = 18;
        Ndef(\helixDrone).xset(\freq, 80, \modIndex, 0.08, \amp, 0.1, \filterFreq, 150);
        Ndef(\masterMix).xset(\wet20, 0.8, \wet10, 0.1);

        3.do { 6.wait; };

        "5:19.5 - [Cue 27: Lingering Resonance - Final Decay (10.0s)]".postln;
        Pbindef.removeAll; // Stop any stray patterns
        Ndef(\helixDrone).fadeTime = 10;
        Ndef(\helixDrone).xset(\amp, 0.05, \modIndex, 0.05);
        Ndef(\masterMix).xset(\wet20, 0.9);

        2.do { 5.wait; };

        "5:29.5 - [Cue 28: Absolute Stillness - Server Clear (6.5s)]".postln;
        Tdef.removeAll; // Stops itself and other Tdefs
        Ndef.clear(5.0); // 5 second fade out for all Ndefs

        ~stopRecording.value;

        5.5.wait;
        "Score Complete. Silence.".postln;
    });

    Tdef(\masterScore).play;
    s.makeGui;
});
)

// Source: compose-paro-taktsang.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~bellBus = Bus.audio(s, 2);
    ~pluckBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\sacredBell, { |out=0, freq=400, decay=5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2); // CRITICAL: doneAction 2
        var modFreq = freq * 1.4142; // Tritone/inharmonic relationship
        var mod = SinOsc.ar(modFreq) * freq * 2 * env;
        var sig = SinOsc.ar(freq + mod);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\vajraPluck, { |out=0, freq=400, decay=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2); // CRITICAL: doneAction 2
        var exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        // Safe Karplus-Strong modeling: clipping delay time to prevent buffer overrun
        var delayTime = freq.reciprocal.clip(0.0001, 0.19);
        var sig = Pluck.ar(exc, 1, 0.2, delayTime, decay, 0.4);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: Vast Shimmer
    Ndef(\mountainShimmer, { |bufFreq=6000, rate=0.5, amp=0|
        var trig = Dust.ar(rate * 10);
        var env = EnvGen.ar(Env.perc(0.1, 0.5), trig);
        var sig = BPF.ar(WhiteNoise.ar, LFNoise1.kr(0.2).exprange(bufFreq*0.8, bufFreq*1.2), 0.1);
        Pan2.ar(sig * env * amp * 12, SinOsc.kr(0.1));
    });

    // Movement II: PM Drone
    Ndef(\ancientResonance, { |freq=60, pmIndex=0.5, rq=0.5, amp=0|
        var modFreq = freq * 1.5;
        var pm = PMOsc.ar(freq, modFreq, pmIndex);
        var sig = RLPF.ar(pm, SinOsc.kr(0.05).exprange(100, 800), rq);
        Pan2.ar(sig * amp, 0);
    });

    // Movement III: Chaotic Glassy Edge
    Ndef(\cliffEdgeTexture, { |resFreq=1500, q=0.5, amp=0|
        var sig = Saw.ar(LFNoise1.kr(2).exprange(50, 200));
        sig = Resonz.ar(sig, resFreq, q);
        Pan2.ar(sig * amp * 15, SinOsc.kr(0.15)); // Makeup gain for Resonz
    });

    // Movement IV: Granular Climax
    Ndef(\spiritualSurge, { |grainSize=0.05, rate=20, panFreq=0.5, amp=0|
        var trig = Dust.ar(rate);
        var env = EnvGen.ar(Env.sine(grainSize), trig);
        var sig = WhiteNoise.ar * env;
        sig = BPF.ar(sig, LFNoise1.kr(1).exprange(1000, 5000), 0.3);
        Pan2.ar(sig * amp * 8, SinOsc.kr(panFreq));
    });

    // Sub-mixes for Discrete Patterns
    Ndef(\bellMix, { In.ar(~bellBus, 2) });
    Ndef(\pluckMix, { In.ar(~pluckBus, 2) });

    // Delay Echo on Plucks (Movement IV)
    Ndef(\pluckMix)[10] = \filter -> { |in|
        var wet = \echoWet.kr(0);
        var fb = \feedback.kr(0.6);
        var echo = CombC.ar(in, 1.0, 0.25, fb * 2);
        XFade2.ar(in, echo, wet * 2 - 1);
    };
    Ndef(\pluckMix).set(\echoWet, 0, \feedback, 0);

    // Master Mix Aggregation
    Ndef(\masterMix, {
        var sig = Ndef.ar(\mountainShimmer, 2) +
                  Ndef.ar(\ancientResonance, 2) +
                  Ndef.ar(\cliffEdgeTexture, 2) +
                  Ndef.ar(\spiritualSurge, 2) +
                  Ndef.ar(\bellMix, 2) +
                  Ndef.ar(\pluckMix, 2);
        // Master filter mapping
        sig = LPF.ar(sig, \masterLpf.kr(18000));
        sig * \amp.kr(1.0);
    });

    // Global Reverb
    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \reverbWet.kr(0.8);
        var verb = GVerb.ar(in.sum, 150, 5, 0.5, 0.5, 15, 0.1, 0.7, 0.5);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    Ndef(\masterMix).set(\reverbWet, 0.8, \amp, 1.0, \masterLpf, 18000);
    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        // ----------------------------------------------------------------
        "0:00 - [Cue 1: Whispers of the High Pass]".postln;
        // ----------------------------------------------------------------
        Ndef(\mountainShimmer).fadeTime = 3;
        Ndef(\mountainShimmer).xset(\amp, 0.6);
        Ndef(\masterMix).xset(\reverbWet, 0.8);

        // 40 seconds total: 8 loops x 5 seconds
        8.do { |i|
            Ndef(\mountainShimmer).xset(\rate, 0.5 + (i * 0.1));
            Ndef(\mountainShimmer).xset(\bufFreq, rrand(5000, 8000));
            5.wait;
        };

        // ----------------------------------------------------------------
        "0:40 - [Cue 2: The Secluded Grotto (SUBTRACTIVE SHIFT)]".postln;
        // ----------------------------------------------------------------
        Ndef(\mountainShimmer).fadeTime = 3;
        Ndef(\mountainShimmer).xset(\amp, 0);

        Ndef(\ancientResonance).fadeTime = 5;
        Ndef(\ancientResonance).xset(\amp, 0.5);

        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\reverbWet, 0.7);

        Pbindef(\grottoPulses,
            \instrument, \sacredBell,
            \out, ~bellBus,
            \dur, Pwhite(8.0, 12.0, inf),
            \decay, Pwhite(5.0, 7.0, inf),
            \freq, Pseq([300, 250, 400, 350], inf),
            \amp, 0.4,
            \pan, Pwhite(-0.4, 0.4, inf)
        ).play;

        // 45 seconds total: 9 loops x 5 seconds
        9.do { |i|
            Ndef(\ancientResonance).xset(\pmIndex, 0.5 + (i * 0.11)); // Sweep 0.5 -> 1.5
            Ndef(\ancientResonance).xset(\rq, rrand(0.3, 0.7));
            5.wait;
        };

        // ----------------------------------------------------------------
        "1:25 - [Cue 3: Tiger's Ascent (BUILDING TENSION)]".postln;
        // ----------------------------------------------------------------
        Ndef(\ancientResonance).fadeTime = 5;
        Ndef(\ancientResonance).xset(\amp, 0.3); // Recedes

        Ndef(\cliffEdgeTexture).fadeTime = 5;
        Ndef(\cliffEdgeTexture).xset(\amp, 0.4);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\reverbWet, 0.5);

        // 45 seconds total: 22 loops x 2 seconds + 1 second
        22.do { |i|
            Ndef(\cliffEdgeTexture).xset(\resFreq, 1500 + (i * 113.6)); // Sweep 1500 -> 4000
            Ndef(\cliffEdgeTexture).xset(\q, rrand(0.2, 0.8));
            2.wait;
        };
        1.wait;

        // ----------------------------------------------------------------
        "2:10 - [Cue 4: Vajrayana Summit (CLIMAX)]".postln;
        // ----------------------------------------------------------------
        Ndef(\cliffEdgeTexture).fadeTime = 3;
        Ndef(\cliffEdgeTexture).xset(\amp, 0.2); // Recedes further

        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\reverbWet, 0.4);

        Ndef(\pluckMix).fadeTime = 2;
        Ndef(\pluckMix).xset(\echoWet, 0.7, \feedback, 0.6);

        Ndef(\spiritualSurge).fadeTime = 5;
        Ndef(\spiritualSurge).xset(\amp, 0.5);

        Pbindef(\summitRhythm,
            \instrument, \vajraPluck,
            \out, ~pluckBus,
            \scale, Scale.lydian,
            \degree, Pwhite(0, 14, inf),
            \dur, Pwhite(0.05, 0.1, inf),
            \amp, 0.6,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        // 50 seconds total: 10 loops x 5 seconds
        10.do { |i|
            Ndef(\spiritualSurge).xset(\grainSize, 0.05 - (i * 0.004)); // Sweep down to 0.01
            Ndef(\spiritualSurge).xset(\rate, 20 + (i * 8));             // Sweep up to 100

            // Random octave jumps and amplitude pulses
            Pbindef(\summitRhythm, \octave, [4, 5, 6].choose);
            Pbindef(\summitRhythm, \amp, rrand(0.6, 0.9));
            5.wait;
        };

        // ----------------------------------------------------------------
        "3:00 - [Cue 5: Dissolution into Emptiness (MANDATED FADE)]".postln;
        // ----------------------------------------------------------------
        Pbindef(\summitRhythm).stop;

        Ndef(\spiritualSurge).fadeTime = 15;
        Ndef(\spiritualSurge).xset(\amp, 0);

        Ndef(\ancientResonance).fadeTime = 20;
        Ndef(\ancientResonance).xset(\amp, 0);

        Ndef(\cliffEdgeTexture).fadeTime = 25;
        Ndef(\cliffEdgeTexture).xset(\amp, 0);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\reverbWet, 0.9);

        Ndef(\pluckMix).fadeTime = 5;
        Ndef(\pluckMix).xset(\feedback, 0);

        // Wait 10 seconds in safe chunks
        2.do { 5.wait; };

        Ndef(\masterMix).fadeTime = 15;
        Ndef(\masterMix).xset(\amp, 0); // Fade out master volume

        Ndef(\pluckMix).fadeTime = 10;
        Ndef(\pluckMix).xset(\echoWet, 0);

        // Wait final 15 seconds in safe chunks
        3.do { 5.wait; };

        // ----------------------------------------------------------------
        "3:25 - [Termination]".postln;
        // ----------------------------------------------------------------
        Ndef.clear(5);
        Pbindef.removeAll;
        Tdef.removeAll;

        "3:30 - Server Silent. Journey Complete.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-constantinople-REVIEW.scd
(
s.waitForBoot({

    // --- TONAL/MODAL: Evolving Harmonic Drone ---
    // Uses additive chorusing, slow LFO filter sweeps, and wide stereo splay
    SynthDef(\evolvingDrone, {
        |out=0, freq=60, amp=0.2, gate=1, pan=0, lpfCenter=800|
        var env = EnvGen.ar(Env.asr(3, 1, 4, \sine), gate, doneAction: 2);
        // Chorus effect using slight frequency offsets
        var freqs = freq * [0.99, 1.0, 1.005, 1.01];
        var sig = Splay.ar(Saw.ar(freqs) * 0.3 + SinOsc.ar(freqs * 0.5));
        // Evolving filter
        var lfo = SinOsc.kr(0.1).range(0.5, 2.0);
        sig = RLPF.ar(sig, lpfCenter * lfo, 0.4);
        Out.ar(out, sig * env * amp);
    }).add;

    // --- SOLO: Expressive FM Voice ---
    // Clean, dynamic FM synthesis for modal solos
    SynthDef(\fmSolo, {
        |out=0, freq=440, amp=0.3, gate=1, pan=0, modIndex=3, modRatio=1.414|
        var env = EnvGen.ar(Env.asr(0.1, 1, 1.5, \sine), gate, doneAction: 2);
        // Envelope controlling the FM index for a brassy/plucked evolution
        var modEnv = EnvGen.kr(Env.perc(0.05, 1.5));
        var mod = SinOsc.ar(freq * modRatio) * freq * modIndex * modEnv;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig, pan, env * amp));
    }).add;

    // --- ATONAL/RHYTHMIC: Chaotic Phase Mod Swarm ---
    // High density, short durations, inharmonic ratios, chaotic panning
    SynthDef(\swarmNode, {
        |out=0, freq=400, amp=0.2, dur=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, dur, 1, -4), doneAction: 2);
        // Phase modulation with harsh inharmonic ratio
        var sig = PMOsc.ar(freq, freq * 1.732, LFNoise2.kr(5).range(1, 8));
        sig = HPF.ar(sig, 400); // Keep it out of the sub frequencies
        Out.ar(out, Pan2.ar(sig, pan, env * amp));
    }).add;

    s.sync;

    // =====================================================================
    // 2. GLOBAL EFFECTS (JITLib)
    // =====================================================================

    // Master Reverb Space - stays active through pauses to let tails ring
    Ndef(\masterSpace, {
        |revTime=6, damping=0.4, amp=1|
        var in = In.ar(\bus.kr(0), 2);
        var sig = GVerb.ar(in.sum, 200, revTime, damping, spread: 50, drylevel: 1, taillevel: 0.6);
        sig * amp;
    }).play;

    // Create an audio bus to route patterns into the Ndef
    ~fxBus = Bus.audio(s, 2);
    Ndef(\masterSpace).set(\bus, ~fxBus);

    // =====================================================================
    // 3. THE SCORE (Tdef - Gestural & Contrasting)
    // =====================================================================

    Tdef(\constantinopleScore, {
        var pause = 0.8; // Standardized short pause between gestures

        "0:00 - Gesture 1: Modal Drone & Sparse Solo (Tonal, Slow)".postln;
        // Wide stereo drone
        Pbindef(\droneSeq,
            \instrument, \evolvingDrone,
            \out, ~fxBus,
            \freq, Pseq([58, 65, 61, 58].midicps, inf), // Minor/Modal feel
            \dur, 8,
            \legato, 1.1, // Overlapping chords
            \lpfCenter, 600,
            \amp, 0.2
        ).play;

        4.wait;

        // Expressive center-panned solo
        Pbindef(\soloSeq,
            \instrument, \fmSolo,
            \out, ~fxBus,
            \scale, Scale.phrygian,
            \degree, Pseq([0, 1, 4, 3, 0], 1),
            \dur, Pseq([1.5, 0.5, 2, 2, 4], 1),
            \pan, Pwhite(-0.2, 0.2), // Slight movement
            \modIndex, Pseg([1, 4, 1], 10),
            \amp, 0.3
        ).play;

        10.wait; // Let the solo finish

        "0:14 - Terminate Gesture 1, let tails ring".postln;
        Pbindef(\droneSeq).stop;
        Pbindef(\soloSeq).stop;
        4.wait; // Wait for drone release
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:19 - Gesture 2: The Breach (Atonal, High Density, Polyphonic)".postln;
        // Fast, chaotic, atonal, violently bouncing across the stereo field
        Pbindef(\swarmSeq,
            \instrument, \swarmNode,
            \out, ~fxBus,
            \freq, Pwhite(200, 1500),
            \dur, Pwhite(0.02, 0.08), // Extreme rhythmic density
            \durNode, Pkey(\dur) * 1.5,
            \pan, Pwhite(-1.0, 1.0), // Hard panning
            \amp, 0.15
        ).play;

        6.wait;

        "0:25 - Terminate Gesture 2".postln;
        Pbindef(\swarmSeq).stop;
        2.wait; // Let short delays clear
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:28 - Gesture 3: Clash of Forces (Dense Drone vs Sparse Atonal bursts)".postln;
        Pbindef(\droneSeq, \dur, 4, \freq, Pseq([58, 59].midicps, inf), \lpfCenter, 1500).play; // Dissonant half-step drone

        // Occasional violent bursts intersecting the drone
        Pbindef(\swarmSeq,
            \dur, Pwrand([0.05, Rest(2)], [0.8, 0.2], inf),
            \freq, Pwhite(1000, 3000), // Higher spectral focus
            \amp, 0.1
        ).play;

        8.wait;

        "0:36 - Terminate Gesture 3".postln;
        Pbindef(\droneSeq).stop;
        Pbindef(\swarmSeq).stop;
        4.wait;
        pause.wait; // ** SILENCE / REVERB PAUSE **

        "0:41 - Gesture 4: Final Lament (Tonal Solo, Wide Empty Space)".postln;
        // Increase reverb time to simulate an empty, ruined basilica
        Ndef(\masterSpace).xset(\revTime, 12);

        Pbindef(\soloSeq,
            \scale, Scale.minor,
            \degree, Pseq([7, 4, 2, 0], 1),
            \dur, Pseq([2, 3, 3, 8], 1),
            \modIndex, Pseq([0.5, 1, 1.5, 0.2]), // Subdued, softer FM
            \pan, Pseq([-0.5, 0.5, -0.2, 0], 1), // Expressive, wide placement
            \amp, 0.2
        ).play;

        16.wait; // Let the 16 beats of the sequence play out

        "0:57 - Terminate Gesture 4".postln;
        // Nothing to stop, Pseq(..., 1) finished on its own.
        // Let the massive reverb tail fade out gracefully.
        Ndef(\masterSpace).fadeTime = 10;
        Ndef(\masterSpace).clear(10);

        10.wait;
        "Score Complete.".postln;
    });

    // Make GUI for easy viewing
    s.makeWindow;

    // Start the piece automatically for testing
    Tdef(\constantinopleScore).play;

});
)

// Source: composition-constantinople.scd
(
// --- CELESTIAL VOID ---
Ndef(\celestialVoid, {
    |freq=60, freqMult=1, amp=0.4, t_trig=1, hpfFreq=20, lpfFreq=1200|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 4, 4]), t_trig);
    var f = freq * freqMult;
    // Additive/Subtractive blend: rich saw for filtering, deep sine for sub
    var sig = Saw.ar([f, f * 1.01]) * 0.5 + SinOsc.ar([f * 0.5, f * 0.505]);
    sig = RLPF.ar(sig, lpfFreq, 0.5);
    sig = HPF.ar(sig, hpfFreq);
    sig * env * amp;
});

// Slot 10: GVerb (Vast Space)
Ndef(\celestialVoid)[10] = \filter -> { |in|
    GVerb.ar(in.sum, roomsize: 300, revtime: 10, damping: 0.5, inputbw: 0.5, spread: 15, drylevel: 0, earlyreflevel: 0.7, taillevel: 0.5)
};
Ndef(\celestialVoid).set(\wet10, 0);

// Slot 12: BPF (Spectral Emphasis)
Ndef(\celestialVoid)[12] = \filter -> { |in| BPF.ar(in, \bpfFreq.kr(1000), \rq.kr(0.5)) };
Ndef(\celestialVoid).set(\wet12, 0);


// --- OMEN CHIME ---
Ndef(\omenChime, {
    |freq=200, freqMult=1, amp=0.5, t_trig=1, modIndex=2, rel=4|
    var env = EnvGen.ar(Env.perc(0.01, rel), t_trig);
    var f = freq * freqMult;
    // Clean FM synthesis for metallic modal strikes
    var mod = SinOsc.ar(f * 1.414) * modIndex * f;
    var sig = SinOsc.ar([f + mod, f * 1.005 + mod]);
    sig * env * amp;
});

// Slot 10: GVerb (Resonant Decay)
Ndef(\omenChime)[10] = \filter -> { |in|
    GVerb.ar(in.sum, roomsize: 150, revtime: 5, damping: 0.5, inputbw: 0.5, spread: 15, drylevel: 0, earlyreflevel: 0.7, taillevel: 0.5)
};
Ndef(\omenChime).set(\wet10, 0);

// Slot 11: CombL Delay (Echoing Premonitions)
Ndef(\omenChime)[11] = \filter -> { |in| CombL.ar(in, 1.0, \delayTime.kr(0.3), \decayTime.kr(3)) };
Ndef(\omenChime).set(\wet11, 0);


// --- CRUMBLE TEXTURE ---
Ndef(\crumbleTexture, {
    |freq=400, amp=0.6, t_trig=1, dens=20|
    var env = EnvGen.ar(Env([0, 1, 0.5, 0], [0.05, 0.1, 0.1]), t_trig);
    var trig = Dust.ar(dens);
    // Granular sine cloud
    var sig = SinOsc.ar(TRand.ar(freq * 0.5, freq * 2, trig)) * EnvGen.ar(Env.perc(0.01, 0.05), trig);
    sig = Pan2.ar(sig, TRand.ar(-0.8, 0.8, trig));
    sig * env * amp;
});

// Slot 11: CombL Delay (Chaotic Reverberations)
Ndef(\crumbleTexture)[11] = \filter -> { |in| CombL.ar(in, 1.0, 0.1, 1) };
Ndef(\crumbleTexture).set(\wet11, 0);

// Slot 12: BPF (Focusing the Debris)
Ndef(\crumbleTexture)[12] = \filter -> { |in| BPF.ar(in, \bpfFreq.kr(1000), \rq.kr(0.2)) };
Ndef(\crumbleTexture).set(\wet12, 0);

// Void: Slow, wide pitch movements
Pbindef(\voidSeq, \dur, 8, \freq, Pn(Pseq([60, 65, 58, 67], 1), inf), \t_trig, 1);

// Chimes: Sparse, low-frequency, single hits
Pbindef(\chimeSeq, \dur, Pwrand([4, 6, 8], [0.5, 0.3, 0.2], inf), \freq, 100, \rel, 4, \t_trig, 1);

// Crumble: Short, dense bursts
Pbindef(\crumbleSeq, \dur, Pwrand([0.1, 0.15, 0.2], [0.5, 0.3, 0.2], inf), \dens, Pwhite(20, 50), \t_trig, 1);

[Ndef(\celestialVoid), Ndef(\omenChime), Ndef(\crumbleTexture)].do(_.quant_(1));

Tdef(\constantinopleScore, {

    "0:00 - [Movement I: Celestial Omen]".postln;
    Ndef(\celestialVoid).play;
    Ndef(\celestialVoid)[1] = \set -> Pbindef(\voidSeq);

    // Smoothly fade the vast space reverb over 10 seconds
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\wet10, 0.6);

    30.wait;

    "0:30 - [Omen's First Whisper]".postln;
    Ndef(\omenChime).play;
    Ndef(\omenChime)[1] = \set -> Pbindef(\chimeSeq);

    // Dry, immediate presence for the first omens
    Ndef(\omenChime).set(\wet10, 0.4, \wet11, 0);

    15.wait; // Now at 0:45

    "0:45 - [Movement II: Deepening Shadow]".postln;
    // Introduce minor-key inflections and increase chime density
    Pbindef(\voidSeq, \freq, Pn(Pseq([60, 63, 58, 65], 1), inf));
    Pbindef(\chimeSeq, \dur, Pwrand([2, 3, 4], [0.5, 0.3, 0.2], inf), \freq, Pn(Pseq([100, 105, 100, 95], 2), inf));

    // Slowly lower LPF to simulate encroaching darkness
    Ndef(\celestialVoid).fadeTime = 15;
    Ndef(\celestialVoid).xset(\lpfFreq, 800);

    // Fade in echoing premonitions
    Ndef(\omenChime).fadeTime = 8;
    Ndef(\omenChime).xset(\wet11, 0.3);
    Ndef(\omenChime).set(\amp, 0.5);

    25.wait; // Now at 1:10

    "1:10 - [Dread Intensifies]".postln;
    // Complex, slightly higher pitched chime patterns
    Pbindef(\chimeSeq, \freq, Pwrand([150, 180, 200, 160], [0.4, 0.3, 0.2, 0.1], inf));

    // Further darken the void
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\lpfFreq, 400, \amp, 0.3);

    // Lengthen and intensify the unsettling echoes
    Ndef(\omenChime).fadeTime = 5;
    Ndef(\omenChime).xset(\wet11, 0.5, \delayTime, 0.4);

    20.wait; // Now at 1:30

    "1:30 - [Movement III: The Fall]".postln;
    Ndef(\crumbleTexture).play;
    Ndef(\crumbleTexture)[1] = \set -> Pbindef(\crumbleSeq);

    // Rapid, dissonant clusters
    Pbindef(\chimeSeq, \dur, Pwhite(0.125, 0.25), \freq, Pwhite(250, 500));

    // Hard set to drastically thin and darken the pad, making space for the crumble
    Ndef(\celestialVoid).set(\lpfFreq, 200, \hpfFreq, 100);

    // Enter chaotic, reverberating wall of sound
    Ndef(\crumbleTexture).set(\wet11, 0.4, \wet12, 0.7, \bpfFreq, 1000, \amp, 0.6);
    Ndef(\omenChime).set(\wet11, 0.8, \delayTime, 0.6, \amp, 0.5);

    20.wait; // Now at 1:50

    "1:50 - [Aftermath / Lingering]".postln;
    Pbindef(\crumbleSeq).stop;
    Ndef(\crumbleTexture).clear(5); // Fade out the debris

    // Return to sparse, lower-frequency chime patterns with long decay
    Pbindef(\chimeSeq, \dur, Pwrand([3, 4, 5], [0.5, 0.3, 0.2], inf), \freq, Pwrand([100, 120], [0.8, 0.2], inf), \rel, 2);

    // Allow the low end of the void to return, but keep it muffled
    Ndef(\celestialVoid).fadeTime = 10;
    Ndef(\celestialVoid).xset(\hpfFreq, 50, \amp, 0.4);

    // Recede the echoes
    Ndef(\omenChime).fadeTime = 5;
    Ndef(\omenChime).xset(\wet11, 0.2, \delayTime, 0.2);

    25.wait; // Now at 2:15

    "2:15 - [Movement IV: Silence Descends]".postln;
    Pbindef(\chimeSeq).stop;
    Ndef(\omenChime).clear(15);

    // Expansive, dissipating sound fading into historical quietude
    Ndef(\celestialVoid).fadeTime = 15;
    Ndef(\celestialVoid).xset(\wet10, 0.9, \amp, 0.1, \lpfFreq, 100);

    30.wait; // Now at 2:45

    "2:45 - [Fade Out & Terminate]".postln;
    Pbindef(\voidSeq).stop;

    // Clear final nodes with a long, 15-second fade
    Ndef(\celestialVoid).clear(15);

    15.wait;
    "Score Complete.".postln;
});

// Create GUI
s.makeGui;
)

// Source: composition-day-in-three-minutes.scd
(
// --- Fade Times ---
Ndef(\warDrum).fadeTime = 2;
Ndef(\choirFM).fadeTime = 4;
Ndef(\skyAnomaly).fadeTime = 3;
Ndef(\fireNoise).fadeTime = 2;
Ndef(\brassSaw).fadeTime = 3;

// --- Ndef Instruments ---

Ndef(\warDrum, {
    |freq=200, freqMult=1, decayTime=1, amp=0.4, t_trig=1, hpfFreq=20|
    var env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
    var exciter = PinkNoise.ar * env;
    var freqs = [1, 1.4, 2.1, 2.7, 3.2] * (freq * freqMult);
    var amps = [1, 0.7, 0.5, 0.3, 0.1];
    var rings = [1, 0.8, 0.6, 0.4, 0.2];
    var sig = DynKlank.ar(`[freqs, amps, rings], exciter, decayscale: decayTime);
    sig = HPF.ar(sig, hpfFreq);
    Pan2.ar(sig * amp, 0);
});

Ndef(\choirFM, {
    |freq=440, freqMult=1, modIndex=2, modRatio=2, amp=0.3, t_trig=1, hpfFreq=20, decayTime=2|
    var env = EnvGen.ar(Env.perc(0.1, decayTime), t_trig);
    var mod = SinOsc.ar(freq * freqMult * modRatio) * (modIndex * freq * freqMult);
    var sig = SinOsc.ar((freq * freqMult) + mod);
    sig = HPF.ar(sig, hpfFreq);
    Pan2.ar(sig * env * amp, 0);
});

Ndef(\skyAnomaly, {
    |freq=3000, freqMult=1, lfoRate=20, lfoDepth=500, amp=0.25, t_trig=1, hpfFreq=20|
    var env = EnvGen.ar(Env.perc(0.01, 0.15), t_trig);
    var lfo = SinOsc.ar(lfoRate) * lfoDepth;
    var sig = SinOsc.ar((freq * freqMult) + lfo);
    sig = HPF.ar(sig, hpfFreq);
    Pan2.ar(sig * env * amp, 0);
});

Ndef(\fireNoise, {
    |bpfFreq=2000, rq=0.2, amp=0.3, t_trig=1, hpfFreq=20|
    var env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
    var sig = PinkNoise.ar + WhiteNoise.ar;
    sig = BPF.ar(sig, bpfFreq, rq);
    sig = HPF.ar(sig, hpfFreq);
    Pan2.ar(sig * env * amp, 0);
});

Ndef(\brassSaw, {
    |freq=200, freqMult=1, lpfFreq=2000, amp=0.35, t_trig=1, hpfFreq=20|
    var env = EnvGen.ar(Env.perc(0.05, 0.8), t_trig);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * 1.01]);
    sig = RLPF.ar(sig, lpfFreq, 0.3);
    sig = HPF.ar(sig, hpfFreq);
    sig * env * amp;
});

// Slot 10: Global Space (GVerb)
Ndef(\warDrum)[10] = \filter -> { |in| GVerb.ar(in.sum, 150, 5, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\warDrum).set(\wet10, 0);

Ndef(\choirFM)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\choirFM).set(\wet10, 0);

Ndef(\brassSaw)[10] = \filter -> { |in| GVerb.ar(in.sum, 150, 6, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\brassSaw).set(\wet10, 0);

// Slot 11: Celestial/Mechanical Echo (CombL)
Ndef(\skyAnomaly)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \delayDecay.kr(3)) };
Ndef(\skyAnomaly).set(\wet11, 0);

// Slot 12: Destruction Resonator (RLPF)
Ndef(\fireNoise)[12] = \filter -> { |in| RLPF.ar(in, \resFreq.kr(800), \resRq.kr(0.5)) };
Ndef(\fireNoise).set(\wet12, 0);

Pbindefs

Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf), \freq, Pwhite(150, 250), \t_trig, 1);
Pbindef(\choirSeq, \dur, 4, \freq, Pseq([220, 261.63, 329.63, 293.66], inf), \t_trig, 1);
Pbindef(\skySeq, \dur, Pwhite(0.05, 0.15), \freq, Pwhite(3000, 6000), \t_trig, 1);
Pbindef(\fireSeq, \dur, Pwhite(0.02, 0.1), \bpfFreq, Pwhite(2000, 6000), \t_trig, 1);
Pbindef(\brassSeq, \dur, 2, \freq, Pseq([110, 146.83, 164.81, 130.81], inf), \t_trig, 1);

[Ndef(\warDrum), Ndef(\choirFM), Ndef(\skyAnomaly), Ndef(\fireNoise), Ndef(\brassSaw)].do(_.quant_(1));

Tdef(\april14thScore, {

    "0:00 — Movement I: Antiquity & Empires (43 BC & 69 AD)".postln;
    Ndef(\warDrum).play;
    Ndef(\warDrum)[1] = \set -> Pbindef(\drumSeq);

    // Establish a vast, bloody Roman battlefield
    Ndef(\warDrum).xset(\wet10, 0.6);
    // Ndef(\warDrum).xset(\wet10, 0); // Revert to dry

    10.wait; // Now at 0:10

    "0:10 — The Holy Unions (966 & 972)".postln;
    Ndef(\choirFM).play;
    Ndef(\choirFM)[1] = \set -> Pbindef(\choirSeq);

    // Smooth, pure angelic sine tones
    Ndef(\choirFM).xset(\modIndex, 0.5, \wet10, 0.7);
    // Ndef(\choirFM).xset(\modIndex, 2, \wet10, 0); // Revert to complex FM dry

    Pbindef(\drumSeq, \dur, 1, \freq, 100); // Sparse, slow pulse
    // Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf), \freq, Pwhite(150, 250)); // Revert drums

    8.wait; // Now at 0:18

    "0:18 — The Medieval Clashes (1205, 1395, 1471)".postln;
    Ndef(\brassSaw).play;
    Ndef(\brassSaw)[1] = \set -> Pbindef(\brassSeq);

    // Hard set on decay, xset on brass filter, ducking choir
    Ndef(\warDrum).set(\decayTime, 2.0);
    // Ndef(\warDrum).set(\decayTime, 1); // Revert drum decay

    Ndef(\brassSaw).xset(\lpfFreq, 600); // Thick fog of Barnet
    // Ndef(\brassSaw).xset(\lpfFreq, 2000); // Revert brass filter

    Ndef(\choirFM).xset(\amp, 0.15); // Duck choir for dense harmonic brass
    // Ndef(\choirFM).xset(\amp, 0.3); // Revert choir amp

    Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25], [0.8, 0.2], inf), \freq, Pwhite(150, 300)); // Chaotic
    // Pbindef(\drumSeq, \dur, 1, \freq, 100); // Revert to sparse pulse

    12.wait; // Now at 0:30

    "0:30 — Movement II: The Nuremberg Sky (1561)".postln;
    Ndef(\warDrum).stop;
    Ndef(\brassSaw).stop;

    Ndef(\skyAnomaly).play;
    Ndef(\skyAnomaly)[1] = \set -> Pbindef(\skySeq);

    // Radical alien departure
    Ndef(\skyAnomaly).set(\wet11, 0.8, \delayDecay, 5);
    // Ndef(\skyAnomaly).set(\wet11, 0, \delayDecay, 3); // Revert anomaly delay

    15.wait; // Now at 0:45

    "0:45 — Movement III: Rebellions & Fire (1639, 1775, 1793, 1816, 1849)".postln;
    Ndef(\skyAnomaly).stop;

    Ndef(\warDrum).play;
    Ndef(\brassSaw).play;

    // Defiant swell of emancipation
    Ndef(\brassSaw).xset(\freqMult, 1.5, \lpfFreq, 3000);
    // Ndef(\brassSaw).xset(\freqMult, 1, \lpfFreq, 600); // Revert brass swell

    Ndef(\choirFM).xset(\amp, 0.1); // Duck choir further
    // Ndef(\choirFM).xset(\amp, 0.15); // Revert choir ducking

    Pbindef(\drumSeq, \dur, 0.5, \freq, 200); // Marching rhythm
    // Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25], [0.8, 0.2], inf)); // Revert marching rhythm

    20.wait; // Now at 1:05

    "1:05 — The Christiania Fire (1858)".postln;
    Ndef(\fireNoise).play;
    Ndef(\fireNoise)[1] = \set -> Pbindef(\fireSeq);

    // Crackle of burning city blocks
    Ndef(\fireNoise).xset(\bpfFreq, 4000);
    // Ndef(\fireNoise).xset(\bpfFreq, 2000); // Revert fire sweep

    15.wait; // Now at 1:20

    "1:20 — Movement IV: Assassinations (1865)".postln;
    Pbindef(\drumSeq).stop;
    Pbindef(\brassSeq).stop;
    Pbindef(\fireSeq).stop;
    Ndef(\brassSaw).stop;
    Ndef(\fireNoise).stop;

    // Dissonant minor interval
    Ndef(\choirFM).set(\freq, 146.83, \modRatio, 1.5, \decayTime, 8, \amp, 0.4);
    // Ndef(\choirFM).set(\freq, 440, \modRatio, 2, \decayTime, 2, \amp, 0.1); // Revert choir minor

    2.wait; // 1:22

    // Two incredibly loud, dry snaps
    Ndef(\warDrum).set(\freq, 800, \decayTime, 0.1, \amp, 0.8, \wet10, 0.1, \t_trig, 1);
    // Ndef(\warDrum).set(\freq, 200, \decayTime, 2.0, \amp, 0.4, \wet10, 0.6); // Revert drum state

    0.5.wait; // 1:22.5
    Ndef(\warDrum).set(\t_trig, 1);

    17.5.wait; // Now at 1:40

    "1:40 — The Wild West (1881)".postln;
    // Four Dead in Five Seconds Gunfight
    Ndef(\warDrum).set(\freq, 1500, \decayTime, 0.05, \amp, 0.8, \wet10, 0);
    // Ndef(\warDrum).set(\freq, 800, \decayTime, 0.1, \amp, 0.8, \wet10, 0.1); // Revert gunfight drums

    4.do {
        Ndef(\warDrum).set(\t_trig, 1);
        0.2.wait;
    };

    4.2.wait; // 0.8s + 4.2s = 5s. Now at 1:45

    "1:45 — Movement V: Modernity & The Kinetoscope (1890, 1894)".postln;
    Ndef(\skyAnomaly).play;
    Pbindef(\skySeq, \dur, 0.125, \freq, 4000).play; // Rigid 16th notes
    // Pbindef(\skySeq, \dur, Pwhite(0.05, 0.15), \freq, Pwhite(3000, 6000)); // Revert sky sequence

    // Dry mechanical clicking
    Ndef(\skyAnomaly).set(\wet11, 0);
    // Ndef(\skyAnomaly).set(\wet11, 0.8); // Revert mechanical anomaly

    // Warm, stable chords
    Ndef(\choirFM).xset(\freq, 261.63, \modRatio, 2, \modIndex, 1, \amp, 0.3);
    // Ndef(\choirFM).xset(\freq, 146.83, \modRatio, 1.5, \modIndex, 0.5, \amp, 0.4); // Revert choir chords

    15.wait; // Now at 2:00

    "2:00 — The Ljubljana Earthquake (1895)".postln;
    Ndef(\fireNoise).play;
    Pbindef(\fireSeq, \dur, 0.05, \bpfFreq, 1000).play;
    // Pbindef(\fireSeq, \dur, Pwhite(0.02, 0.1), \bpfFreq, Pwhite(2000, 6000)); // Revert fire sequence

    // Massive shaking sub-bass rumble
    Ndef(\fireNoise).set(\wet12, 1);
    Ndef(\fireNoise).xset(\resFreq, 60, \resRq, 0.1, \amp, 0.8);
    // Ndef(\fireNoise).set(\wet12, 0); Ndef(\fireNoise).xset(\amp, 0.3); // Revert earthquake

    // High-pass all other instruments to survive tectonic masking
    Ndef(\choirFM).xset(\hpfFreq, 400);
    Ndef(\skyAnomaly).xset(\hpfFreq, 400);
    // Ndef(\choirFM).xset(\hpfFreq, 20); Ndef(\skyAnomaly).xset(\hpfFreq, 20); // Revert high-pass

    10.wait; // Now at 2:10

    "2:10 — The Exposition Universelle (1900)".postln;
    Pbindef(\fireSeq).stop;
    Ndef(\fireNoise).stop;
    Ndef(\skyAnomaly).stop;

    Ndef(\brassSaw).play;

    // Unified major sequence
    Pbindef(\choirSeq, \dur, 2, \freq, Pseq([261.63, 329.63, 392.00, 523.25], inf));
    Pbindef(\brassSeq, \dur, 2, \freq, Pseq([130.81, 164.81, 196.00, 261.63], inf));
    // Pbindef(\choirSeq, \dur, 4, \freq, Pseq([220, 261.63, 329.63, 293.66], inf)); // Revert choir seq
    // Pbindef(\brassSeq, \dur, 2, \freq, Pseq([110, 146.83, 164.81, 130.81], inf)); // Revert brass seq

    Pbindef(\brassSeq).play;

    // Remove high-pass, open brass fully, massive shimmering reverb
    Ndef(\choirFM).xset(\hpfFreq, 20, \wet10, 0.8, \amp, 0.3);
    Ndef(\brassSaw).xset(\hpfFreq, 20, \lpfFreq, 8000, \wet10, 0.8, \amp, 0.3);
    // Ndef(\brassSaw).xset(\lpfFreq, 3000, \wet10, 0); // Revert brass exposition

    20.wait; // Now at 2:30

    "2:30 — Movement VI: The Event Horizon (Outro)".postln;
    Pbindef(\choirSeq).stop;
    Pbindef(\brassSeq).stop;
    // Sequences halt, leaving only the lush ringing reverb tails

    10.wait; // Now at 2:40

    "2:40 — The Final Fade".postln;
    // 20-second unsegmented organic fade to absolute black
    Ndef(\warDrum).clear(20);
    Ndef(\choirFM).clear(20);
    Ndef(\skyAnomaly).clear(20);
    Ndef(\fireNoise).clear(20);
    Ndef(\brassSaw).clear(20);

    20.wait; // Now at 3:00

    "3:00 — Terminate".postln;
    "Score Complete. Server left in total silence.".postln;
});
)

// Source: composition-feijoada-v2.scd
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================
SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Strict limiter to protect hardware
    sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

// =====================================================================
// 1. ARCHITECTURE, BUSES, & SYNTHDEFS
// =====================================================================
s.waitForBoot({

    // Dedicated Routing Buses
    ~revBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);
    ~gritBus = Bus.audio(s, 2);
    ~synthMixBus = Bus.audio(s, 2);

    // --- SYNTHDEFS (Discrete Events) ---

    SynthDef(\pulse, { |amp=0.1, pan=0, revSend=0.2|
        var sig = LPF.ar(Impulse.ar(0), 1000) + BPF.ar(WhiteNoise.ar, 1500, 0.5, 0.5);
        var env = EnvGen.ar(Env.perc(0.001, 0.1), doneAction: 2);
        sig = Pan2.ar(sig * env, pan) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    SynthDef(\grainSplat, { |amp=0.1, pan=0, pitch=1000, revSend=0.2|
        var env = EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);
        var sig = SinOsc.ar(pitch * XLine.kr(1, 0.5, 0.1)) * env;
        sig = sig + (PinkNoise.ar * env * 0.5);
        sig = BPF.ar(sig, pitch, 0.3);
        sig = Pan2.ar(sig, pan) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    SynthDef(\darkThump, { |amp=0.5, freq=30, decay=5, revSend=0.4|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var pitchEnv = XLine.kr(freq * 3, freq, 0.1);
        var sig = SinOsc.ar(pitchEnv) * env;
        sig = LPF.ar(sig, 100);
        sig = Pan2.ar(sig, 0) * amp;
        Out.ar(~synthMixBus, sig);
        Out.ar(~revBus, sig * revSend);
    }).add;

    s.sync;

    // --- NDEFS (Continuous Textures & Drones) ---
    Ndef.clear;

    Ndef(\feijaoBase, { |freq=50, amp=0, cutoff=200, rq=0.2, filterLfoFreq=0.1, filterLfoAmp=100, revSend=0.4|
        var sig = Saw.ar([freq, freq*1.01]);
        var lfo = SinOsc.kr(filterLfoFreq).range(cutoff, cutoff + filterLfoAmp);
        sig = RLPF.ar(sig, lfo.clip(20, 15000), rq);
        sig = sig * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\carneTextura, { |grainDensity=0.1, grainSpread=0.5, amp=0, freqMul=1, wetDry=0.2, revSend=0.2|
        var trig = Dust.ar(grainDensity * 50);
        var pan = TRand.ar(grainSpread.neg, grainSpread, trig);
        var freq = TRand.ar(1000, 5000, trig) * freqMul;
        var src = SinOsc.ar(freq) * 0.5 + BPF.ar(WhiteNoise.ar, freq, 0.1);
        var sig = GrainIn.ar(2, trig, TRand.ar(0.01, 0.05, trig), src, pan);
        var rev = FreeVerb2.ar(sig[0], sig[1], 1, 0.9, 0.1);
        sig = XFade2.ar(sig, rev, wetDry * 2 - 1) * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\acompanhamentos, { |amp=0, decay=0.5, freq1=800, freq2=1200, freq3=2500, revSend=0.3|
        var trig = Dust.ar(3);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01), trig);
        var sig = [freq1, freq2, freq3].collect({ |f| Ringz.ar(exciter, f, decay) }).sum;
        sig = Pan2.ar(sig, TRand.kr(-0.5, 0.5, trig)) * amp;
        Out.ar(~revBus, sig * revSend);
        sig;
    });

    Ndef(\historicalMurmur, { |modIndex=0.5, carrierFreq=200, feedbackGain=0.8, amp=0, filterCutoff=5000, revSend=0.2, gritSend=0|
        var fbIn = LocalIn.ar(1);
        var mod = SinOsc.ar(carrierFreq * 1.3 + (fbIn * feedbackGain * 1000)) * modIndex * carrierFreq;
        var sig = SinOsc.ar(carrierFreq + mod);
        sig = LeakDC.ar(sig);
        LocalOut.ar(sig);
        sig = LPF.ar(sig, filterCutoff.clip(20, 20000));
        sig = Pan2.ar(sig, 0) * amp;
        Out.ar(~revBus, sig * revSend);
        Out.ar(~gritBus, sig * gritSend);
        sig;
    });

    Ndef(\celebrationSynth, { |amp=0, detune=0.01, filterCutoff=800, filterRes=0.3, revSend=0.4, delaySend=0|
        var freqs = [60, 63, 67, 70].midicps;
        var sig = freqs.collect({ |f| Saw.ar([f, f * (1 + detune)]) }).sum;
        sig = RLPF.ar(sig, filterCutoff.clip(20, 20000), filterRes);
        sig = sig * amp;
        Out.ar(~revBus, sig * revSend);
        Out.ar(~delayBus, sig * delaySend);
        sig;
    });

    // --- EFFECTS & MASTER BUS ---

    Ndef(\globalReverb, { |roomsize=0.8, mix=0.4|
        var in = In.ar(~revBus, 2);
        XFade2.ar(in, FreeVerb2.ar(in[0], in[1], 1, roomsize, 0.2), mix * 2 - 1);
    });

    Ndef(\mainDelay, { |delaytime=0.375, feedback=0, mix=0|
        var in = In.ar(~delayBus, 2);
        XFade2.ar(in, CombC.ar(in, 2.0, delaytime, feedback * 10), mix * 2 - 1);
    });

    Ndef(\gritDistortion, { |drive=0, preHPF=100, mix=0|
        var in = In.ar(~gritBus, 2);
        var sig = HPF.ar(in, preHPF.clip(20, 10000));
        sig = LeakDC.ar(sig);
        sig = (sig * (1 + (drive * 20))).softclip;
        XFade2.ar(in, sig, mix * 2 - 1);
    });

    Ndef(\masterFilter, { |cutoff=20000, rq=1.0|
        var synths = In.ar(~synthMixBus, 2);
        var ndefs = Ndef.ar(\feijaoBase) + Ndef.ar(\carneTextura) + Ndef.ar(\acompanhamentos) +
                    Ndef.ar(\historicalMurmur) + Ndef.ar(\celebrationSynth);
        var fx = Ndef.ar(\globalReverb) + Ndef.ar(\mainDelay) + Ndef.ar(\gritDistortion);
        var mix = synths + ndefs + fx;
        RLPF.ar(mix, cutoff.clip(20, 20000), rq);
    }).play;

    // Control bus for dynamic amplitude scaling of Pbinds
    Ndef(\spiceAmp, { 0 });

    s.sync;

    // =====================================================================
    // 2. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        "0:00 - [Movement I: The Stew's Opening Aroma]".postln;
        Ndef(\feijaoBase).set(\freq, 50, \cutoff, 200, \rq, 0.2);
        Ndef(\feijaoBase).fadeTime = 15;
        Ndef(\feijaoBase).xset(\amp, 0.3);

        Ndef(\carneTextura).set(\amp, 0.15);
        Ndef(\carneTextura).fadeTime = 20;
        Ndef(\carneTextura).xset(\grainDensity, 0.3);

        Ndef(\globalReverb).set(\roomsize, 0.8, \mix, 0.4);

        30.wait;

        "0:30 - [Movement I: Popularity's Gentle Pulse]".postln;
        Ndef(\acompanhamentos).fadeTime = 5;
        Ndef(\acompanhamentos).xset(\amp, 0.15, \decay, 0.8);

        Ndef(\feijaoBase).fadeTime = 45;
        Ndef(\feijaoBase).xset(\cutoff, 400);

        45.wait;

        "1:15 - [Movement II: Ancient Echoes (SUBTRACTION)]".postln;
        // Kill the percussion to create a stark, empty contrast
        Ndef(\acompanhamentos).fadeTime = 8;
        Ndef(\acompanhamentos).xset(\amp, 0);

        // Push the base drone to the background
        Ndef(\feijaoBase).fadeTime = 10;
        Ndef(\feijaoBase).xset(\amp, 0.05, \cutoff, 150);

        Ndef(\historicalMurmur).set(\carrierFreq, 200, \feedbackGain, 0.8, \amp, 0.2, \modIndex, 0.5);

        Pbindef(\rhythmPortugues,
            \instrument, \pulse,
            \dur, 4,
            \amp, 0.1
        ).play;

        Ndef(\carneTextura).fadeTime = 10; Ndef(\carneTextura).xset(\grainDensity, 0.05, \amp, 0.1);
        Ndef(\historicalMurmur).fadeTime = 30; Ndef(\historicalMurmur).xset(\modIndex, 1.2);
        Ndef(\globalReverb).fadeTime = 15; Ndef(\globalReverb).xset(\mix, 0.2);

        45.wait;

        "2:00 - [Movement II: Scarcity's Grit]".postln;
        Ndef(\historicalMurmur).fadeTime = 30; Ndef(\historicalMurmur).xset(\gritSend, 1.0);
        Ndef(\gritDistortion).fadeTime = 30; Ndef(\gritDistortion).xset(\drive, 0.6, \mix, 0.5);
        Pbindef(\rhythmPortugues, \amp, 0.2, \dur, Pseq([4, 3.5, 0.5], inf));

        45.wait;

        "2:45 - [Movement III: Brazilian Adaptation Begins]".postln;
        Pbindef(\rhythmPortugues).stop;

        Ndef(\historicalMurmur).fadeTime = 2; Ndef(\historicalMurmur).xset(\gritSend, 0);
        Ndef(\gritDistortion).fadeTime = 2; Ndef(\gritDistortion).xset(\mix, 0);

        Ndef(\historicalMurmur).fadeTime = 15; Ndef(\historicalMurmur).xset(\modIndex, 0.8, \amp, 0.1);
        Ndef(\feijaoBase).fadeTime = 20; Ndef(\feijaoBase).xset(\amp, 0.25, \cutoff, 600);
        Ndef(\carneTextura).fadeTime = 15; Ndef(\carneTextura).xset(\grainDensity, 0.4, \amp, 0.3);

        30.wait;

        "3:15 - [Movement III: New Accompaniments (PARAMETER SHIFT)]".postln;
        // Bring \acompanhamentos back, but tight and clicking
        Ndef(\acompanhamentos).fadeTime = 5;
        Ndef(\acompanhamentos).xset(\amp, 0.2, \decay, 0.05, \freq1, 1500, \freq2, 2200, \freq3, 3500);

        Ndef(\spiceAmp, { Line.kr(0, 0.4, 20) });
        Pbindef(\brazilianSpice,
            \instrument, \grainSplat,
            \dur, Pseq([0.5, 0.7, 0.3], inf),
            \pitch, Pwhite(800, 2500),
            \pan, Pwhite(-0.8, 0.8),
            \amp, Ndef(\spiceAmp).asMap
        ).play;

        Ndef(\globalReverb).fadeTime = 20; Ndef(\globalReverb).xset(\mix, 0.35);

        60.wait;

        "4:15 - [Movement IV: The Burial of Bones & Comettant's Description]".postln;
        Pbindef(\enterroOssos,
            \instrument, \darkThump,
            \freq, 30,
            \amp, 0.5,
            \decay, 5,
            \dur, Pseq([5, 5, 5, Rest(inf)], 1)
        ).play;

        Ndef(\historicalMurmur).set(\amp, 0.05, \filterCutoff, 100);
        Ndef(\spiceAmp, { 0.1 });

        Ndef(\carneTextura).fadeTime = 5; Ndef(\carneTextura).xset(\freqMul, 2.5); // "Repugnant"

        5.wait;

        Ndef(\carneTextura).fadeTime = 5; Ndef(\carneTextura).xset(\freqMul, 1.0); // "Agreeable"

        10.wait;

        Ndef(\spiceAmp, { Line.kr(0.1, 0.4, 5) });

        30.wait;

        "5:00 - [Movement IV: G. Lobo's Legacy]".postln;
        Ndef(\celebrationSynth).set(\amp, 0.4, \delaySend, 1.0);
        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\detune, 0.03);

        Ndef(\mainDelay).fadeTime = 20; Ndef(\mainDelay).xset(\mix, 0.4, \feedback, 0.6);
        Ndef(\feijaoBase).fadeTime = 10; Ndef(\feijaoBase).xset(\amp, 0.35);
        Ndef(\carneTextura).fadeTime = 10; Ndef(\carneTextura).xset(\amp, 0.4);

        60.wait;

        "6:00 - [Movement V: The Grand Celebration]".postln;
        Pbindef(\enterroOssos).stop;

        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\amp, 0.6, \filterCutoff, 1200);
        Ndef(\spiceAmp, { Line.kr(0.4, 0.6, 20) });
        Pbindef(\brazilianSpice, \dur, Pseq([0.15, 0.2, 0.1], inf));

        Ndef(\feijaoBase).fadeTime = 15; Ndef(\feijaoBase).xset(\amp, 0.4, \cutoff, 800);
        // Bring acompanhamentos back to ringing for the climax
        Ndef(\acompanhamentos).fadeTime = 20; Ndef(\acompanhamentos).xset(\amp, 0.45, \decay, 0.8, \freq1, 800, \freq2, 1200, \freq3, 2500);
        Ndef(\globalReverb).fadeTime = 20; Ndef(\globalReverb).xset(\mix, 0.6, \roomsize, 0.9);
        Ndef(\masterFilter).fadeTime = 60; Ndef(\masterFilter).xset(\cutoff, 8000);

        60.wait;

        "7:00 - [Movement V: Peak of Abundance]".postln;
        Ndef(\mainDelay).set(\feedback, 0.7);

        45.wait;

        "7:45 - [Movement VI: Digestivo & Lingering Taste]".postln;
        Pbindef(\brazilianSpice).stop;

        Ndef(\celebrationSynth).fadeTime = 30; Ndef(\celebrationSynth).xset(\amp, 0);
        Ndef(\acompanhamentos).fadeTime = 25; Ndef(\acompanhamentos).xset(\amp, 0);
        Ndef(\carneTextura).fadeTime = 35; Ndef(\carneTextura).xset(\amp, 0);
        Ndef(\mainDelay).fadeTime = 20; Ndef(\mainDelay).xset(\mix, 0, \feedback, 0);
        Ndef(\globalReverb).fadeTime = 30; Ndef(\globalReverb).xset(\mix, 0.1, \roomsize, 0.3);

        30.wait;

        "8:15 - [Movement VI: The Last Memory]".postln;
        Ndef(\feijaoBase).fadeTime = 15; Ndef(\feijaoBase).xset(\amp, 0);
        Ndef(\historicalMurmur).fadeTime = 10; Ndef(\historicalMurmur).xset(\amp, 0);
        Ndef(\masterFilter).fadeTime = 15; Ndef(\masterFilter).xset(\cutoff, 200);

        15.wait;

        "8:30 - [Terminating]".postln;
        Pbindef.removeAll;
        Ndef.clear(5);

        "Score Complete.".postln;
    });

    s.makeGui;

    // Execute the composition
    Tdef(\masterScore).play;
});
)

// Source: composition-feijoada.scd
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter catches any peaks above 0.95 silently and transparently
    sig = Limiter.ar(sig, level: 0.95, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };


// =====================================================================
// 1. INSTRUMENTS & EFFECTS (JITLib)
// =====================================================================

// Initialize Master Bus
Ndef(\master, {
    var sig = Ndef.ar(\terra) + Ndef.ar(\semente) + Ndef.ar(\carne) + Ndef.ar(\fruta) + Ndef.ar(\vapor);
    sig.softclip; // Prevent harsh digital clipping before the limiter
}).play;

// --- INSTRUMENTS ---

Ndef(\terra, {
    |freq=50, freqMult=1, amp=0.4, ampMod=1, t_trig=1, lpfFreq=200, lpfFreqMult=1|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 4]), t_trig);
    var detune = SinOsc.kr(0.1).range(0.99, 1.01);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * detune]);
    var sub = Pulse.ar([freq * freqMult * 0.5, freq * freqMult * 0.505], 0.4);
    sig = RLPF.ar(sig + sub, lpfFreq * lpfFreqMult, 0.5);
    sig * env * amp * ampMod;
});

Ndef(\semente, {
    |freq=800, freqMult=1, amp=0.3, ampMod=1, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
    var noise = WhiteNoise.ar * env;
    var f = freq * freqMult;
    // Standard array formatting for dynamic UGen evaluation in DynKlank
    var freqs = [f, f * 1.4, f * 2.1, f * 2.7];
    var amps = [1.0, 0.6, 0.4, 0.2];
    var rings = [0.1, 0.08, 0.05, 0.02];
    var sig = DynKlank.ar(`[freqs, amps, rings], noise);
    Pan2.ar(sig * amp * ampMod, TRand.kr(-0.4, 0.4, t_trig));
});

Ndef(\carne, {
    |freq=150, freqMult=1, amp=0.3, ampMod=1, t_trig=1, modIndex=1|
    var env = EnvGen.ar(Env([0, 1, 0.7, 0], [0.5, 1.5, 2.5]), t_trig);
    var mFreq1 = freq * freqMult * 1.414;
    var mFreq2 = freq * freqMult * 0.5;
    var mod2 = SinOsc.ar(mFreq2) * (modIndex * 2) * mFreq2;
    var mod1 = SinOsc.ar(mFreq1 + mod2) * modIndex * mFreq1;
    var sig = SinOsc.ar([freq * freqMult, freq * freqMult * 1.01] + mod1);
    sig = LPF.ar(sig, 3000);
    sig * env * amp * ampMod;
});

Ndef(\fruta, {
    |freq=2500, freqMult=1, amp=0.15, ampMod=1, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.05, 0.5), t_trig);
    var pitchLfo = SinOsc.ar(15).range(0.98, 1.02);
    var ampLfo = SinOsc.ar(20).range(0.3, 1.0);
    var sig = SinOsc.ar([freq * freqMult * pitchLfo, freq * freqMult * pitchLfo * 1.01]);
    sig * env * amp * ampMod * ampLfo;
});

Ndef(\vapor, {
    |amp=0.2, ampMod=1, t_trig=1, bpfFreq=500, bpfFreqMult=1, sweepMod=0|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [1.0, 1.0, 2.5]), t_trig);
    var noise = PinkNoise.ar(1 ! 2);
    // sweepMod blends between external Pbindef control and internal slow sweep
    var slowSweep = SinOsc.kr(0.05).exprange(200, 800);
    var freq = XFade2.kr(bpfFreq, slowSweep, sweepMod * 2 - 1);
    var sig = BPF.ar(noise, freq * bpfFreqMult, 0.2);
    sig * env * amp * ampMod;
});

// --- EFFECTS (Master Slots) ---

// Slot 10: Master Verb (GVerb)
Ndef(\master)[10] = \filter -> { |in|
    var decay = \verbDecay.kr(4);
    GVerb.ar(in.sum, 150, decay, 0.5, 0.5, 15, 0.5, 0.7, 0.5);
};
Ndef(\master).set(\wet10, 0);

// Slot 11: Stew Diffusion (AllpassC Chain)
Ndef(\master)[11] = \filter -> { |in|
    var dly = \stewDelay.kr(0.1).clip(0.001, 1.9);
    var dec = \stewDecay.kr(1.0);
    var sig = AllpassC.ar(in, 2.0, [dly, dly * 1.1], dec);
    sig = AllpassC.ar(sig, 2.0, [dly * 0.9, dly * 1.05], dec);
    sig;
};
Ndef(\master).set(\wet11, 0);

// Slot 12: Flavor Filter (Dynamic multi-band)
Ndef(\master)[12] = \filter -> { |in|
    var bpfFreq = \flavorBpfFreq.kr(1000);
    var rq = \flavorRq.kr(1.0);
    var mix = \flavorMix.kr(0); // 0 = flat, 1 = filtered
    var filtered = BPF.ar(in, bpfFreq, rq) * (1 / rq.max(0.1).sqrt); // Gain compensation
    XFade2.ar(in, filtered, mix * 2 - 1);
};
Ndef(\master).set(\flavorMix, 0, \flavorBpfFreq, 1000, \flavorRq, 1.0);


// =====================================================================
// 2. PATTERNS
// =====================================================================

Pbindef(\terraSeq, \dur, 6, \freq, Pseq([50, 55, 48, 52], inf), \t_trig, 1);
Pbindef(\sementeSeq, \dur, 2, \freq, Pseq([800, 1200, 900], inf), \t_trig, 1);
Pbindef(\carneSeq, \dur, 4, \freq, Pseq([150, 180, 160], inf), \t_trig, 1);
Pbindef(\frutaSeq, \dur, Pwhite(0.5, 1.5), \freq, Pwhite(2000, 3500), \t_trig, 1);
Pbindef(\vaporSeq, \dur, 4, \bpfFreq, 500, \t_trig, 1); // Initial slow rhythmic state

[Ndef(\terra), Ndef(\semente), Ndef(\carne), Ndef(\fruta), Ndef(\vapor)].do(_.quant_(1));


// =====================================================================
// 3. THE SCRIPT (Tdef - 5 Minute Score)
// =====================================================================

Tdef(\feijoadaScore, {

    "0:00 - [Movement I: Raízes Antigas]".postln;
    Ndef(\terra)[1] = \set -> Pbindef(\terraSeq);
    Ndef(\semente)[1] = \set -> Pbindef(\sementeSeq);

    Ndef(\master).fadeTime = 12;
    Ndef(\master).xset(\wet10, 0.3); // Establish subtle space

    Ndef(\terra).fadeTime = 30;
    Ndef(\terra).xset(\lpfFreq, 400); // Slowly open foundation

    45.wait; // Now at 0:45

    "0:45 - [Portugal to Brazil: The Journey Begins]".postln;
    Ndef(\terra).fadeTime = 25;
    Ndef(\terra).xset(\freqMult, 1.15); // Upward pitch shift migration

    Pbindef(\sementeSeq, \dur, Pseq([1.5, 0.75, 0.5], inf)); // Rhythmic complexity

    Ndef(\master).fadeTime = 10;
    Ndef(\master).xset(\wet11, 0.1); // Introduce stew diffusion

    Ndef(\terra).fadeTime = 10;
    Ndef(\terra).xset(\ampMod, 1.3);

    25.wait; // Now at 1:10

    "1:10 - [Movement II: O Encontro Brasileiro]".postln;
    Ndef(\carne).set(\ampMod, 0); // Initialize at 0 for fade
    Ndef(\carne)[1] = \set -> Pbindef(\carneSeq);

    Ndef(\carne).fadeTime = 15;
    Ndef(\carne).xset(\ampMod, 1); // Fade in meats

    Ndef(\terra).fadeTime = 20;
    Ndef(\terra).xset(\lpfFreqMult, 1.5); // Reveal high-frequency content

    40.wait; // Now at 1:50

    "1:50 - [Brazilian Accompaniments Emerge]".postln;
    Ndef(\fruta).set(\ampMod, 0);
    Ndef(\fruta)[1] = \set -> Pbindef(\frutaSeq);

    Ndef(\fruta).fadeTime = 10;
    Ndef(\fruta).xset(\ampMod, 1); // Fade in bright accompaniments

    Ndef(\semente).fadeTime = 5;
    Ndef(\semente).xset(\ampMod, 1.4); // Bring granular texture forward

    30.wait; // Now at 2:20

    "2:20 - [Movement III: Sabor e Lenda]".postln;
    Ndef(\vapor).set(\sweepMod, 1); // Enable internal slow LFO sweep
    Ndef(\vapor)[1] = \set -> Pbindef(\vaporSeq);

    Pbindef(\sementeSeq, \dur, Pseq([1.8, 0.3, 0.9, 2.2], inf)); // Hesitant rhythm

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\flavorMix, 0.8, \flavorBpfFreq, 350, \flavorRq, 0.3); // Thicken the stew

    // Fruta dips slightly then returns (questioning flicker)
    Ndef(\fruta).fadeTime = 5;
    Ndef(\fruta).xset(\ampMod, 0.5);
    Routine({
        5.wait;
        Ndef(\fruta).xset(\ampMod, 1.0);
    }).play;

    50.wait; // Now at 3:10

    "3:10 - [Myth Debunked / Clarification]".postln;
    Pbindef(\sementeSeq, \dur, Pseq([1.0, 0.5], inf)); // Stabilize rhythm

    Ndef(\vapor).fadeTime = 20;
    Ndef(\vapor).xset(\bpfFreqMult, 4.0); // Sweep up from 500Hz to 2000Hz to thin out

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\flavorMix, 0); // Flatten out the flavor filter

    Ndef(\carne).fadeTime = 10;
    Ndef(\carne).xset(\modIndex, 1.5); // Add richness/definition

    40.wait; // Now at 3:50

    "3:50 - [Movement IV: A Feijoada Completa]".postln;
    Ndef(\vapor).set(\sweepMod, 0); // Hand control back to Pbindef entirely
    Pbindef(\vaporSeq, \dur, Pwhite(0.1, 0.25), \bpfFreq, Pwhite(1500, 2500)); // Bubbling
    Ndef(\vapor).xset(\bpfFreqMult, 1); // Reset multiplier

    Ndef(\master).fadeTime = 10;
    Ndef(\master).xset(\wet10, 0.65, \verbDecay, 8); // Grand celebratory space

    Ndef(\master).fadeTime = 8;
    Ndef(\master).xset(\stewDecay, 0.8, \stewDelay, 0.7, \wet11, 0.4); // Lush blended sound

    40.wait; // Now at 4:30

    "4:30 - [Movement V: O Banquete Final]".postln;
    Pbindef(\sementeSeq, \dur, Pseq([3.0, 2.0], inf));
    Pbindef(\frutaSeq, \dur, Pseq([2.0, 3.0], inf));
    Pbindef(\vaporSeq, \dur, Pseq([1.5, 2.0], inf));

    // Lingering warmth swell
    Ndef(\terra).fadeTime = 12.5;
    Ndef(\terra).xset(\ampMod, 1.5);
    Routine({
        12.5.wait;
        Ndef(\terra).fadeTime = 12.5;
        Ndef(\terra).xset(\ampMod, 0.3);
    }).play;

    Ndef(\master).fadeTime = 15;
    Ndef(\master).xset(\verbDecay, 12); // Extending the resonance

    30.wait; // Now at 5:00

    "5:00 - [Fade Out & Terminate]".postln;
    Pbindef(\terraSeq).stop;
    Pbindef(\sementeSeq).stop;
    Pbindef(\carneSeq).stop;
    Pbindef(\frutaSeq).stop;
    Pbindef(\vaporSeq).stop;

    Ndef(\terra).clear(20);
    Ndef(\semente).clear(20);
    Ndef(\carne).clear(20);
    Ndef(\fruta).clear(20);
    Ndef(\vapor).clear(20);

    // Allow effects to decay naturally before clearing master
    Routine({
        20.wait;
        Ndef(\master).clear;
        "Score Complete.".postln;
    }).play;

});

// Launch GUI
s.makeGui;
)

// Source: composition-haideng.scd
(
Ndef(\frailBreath).fadeTime = 4;
Ndef(\fingerChan).fadeTime = 4;
Ndef(\emptyCloud).fadeTime = 4;

// Additive synthesis bell-tone (frail, wavering)
Ndef(\frailBreath, {
    |freq=400, freqMult=1, amp=0.2, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.05, 1.5), t_trig);
    var f = freq * freqMult;
    // Cluster of closely tuned sine waves for natural beating vibrato
    var sig = SinOsc.ar([f, f * 1.005, f * 1.012, f * 0.99]) * [1, 0.8, 0.6, 0.9];
    Splay.ar(sig) * env * amp;
});

// Pure FM synthesis drone/strike (focused, immense pressure)
Ndef(\fingerChan, {
    |freq=150, freqMult=1, modIndex=0.1, hpfFreq=20, amp=0.2, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.01, 2.0), t_trig);
    var f = freq * freqMult;
    // Non-integer ratio for metallic, tense FM harmonics
    var mod = SinOsc.ar(f * 1.414) * f * modIndex;
    var sig = SinOsc.ar(f + mod);
    sig = HPF.ar(sig, hpfFreq);
    Pan2.ar(sig * env * amp, 0);
});

// Subtractive sine/triangle hybrid pad (deep, resonant, still)
Ndef(\emptyCloud, {
    |freq=100, freqMult=1, lpfFreq=2000, amp=0.3, t_trig=1|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 4, 4]), t_trig);
    var f = freq * freqMult;
    // Triangle provides harmonics for the filter, sine provides deep sub
    var sig = LFTri.ar([f, f * 1.01]) + SinOsc.ar([f * 0.5, f * 0.505]);
    sig = RLPF.ar(sig, lpfFreq, 0.5);
    sig * env * amp;
});

// --- EFFECTS ---

// Slot 10 (frailBreath): CombL delay for irregular, fluttering echoes
Ndef(\frailBreath)[10] = \filter -> { |in| CombL.ar(in, 0.5, 0.3, 3) };
Ndef(\frailBreath).set(\wet10, 0);

// Slot 10 (fingerChan): GVerb for massive Shaolin Temple acoustics
Ndef(\fingerChan)[10] = \filter -> { |in| GVerb.ar(in.sum, 150, 5, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\fingerChan).set(\wet10, 0);

// Slot 11 (emptyCloud): FreeVerb for infinite decay spiritual mist
Ndef(\emptyCloud)[11] = \filter -> { |in| FreeVerb.ar(in, 1, 0.95, 0.1) }; // Mix is 1 inside filter
Ndef(\emptyCloud).set(\wet11, 0);


// =====================================================================
// 2. PATTERNS
// =====================================================================

Pbindef(\breathSeq, \dur, Pwrand([1.5, 2.0, 3.0], [0.5, 0.3, 0.2], inf), \freq, Pwhite(600, 800, inf), \t_trig, 1);
Pbindef(\chanSeq, \dur, 2, \freq, 150, \t_trig, 1);
Pbindef(\cloudSeq, \dur, 6, \freq, Pseq([60, 65, 63, 58], inf), \t_trig, 1);

[Ndef(\frailBreath), Ndef(\fingerChan), Ndef(\emptyCloud)].do(_.quant_(1));

Tdef(\theNeverSick, {

    "0:00 - [Movement I: Frailty & The World]".postln;
    Ndef(\frailBreath).play;
    Ndef(\frailBreath)[1] = \set -> Pbindef(\breathSeq);

    // Slowly increase delay wetness to 40% over 15 seconds
    Ndef(\frailBreath).fadeTime = 15;
    Ndef(\frailBreath).xset(\wet10, 0.4);

    45.wait; // Now at 0:45

    "0:45 - [Movement II: The Pivot]".postln;
    // Shorten duration to simulate a quickening pulse
    Pbindef(\breathSeq, \dur, Pwrand([0.5, 0.75, 1.0], [0.6, 0.3, 0.1], inf));

    Ndef(\fingerChan).play;
    Ndef(\fingerChan)[1] = \set -> Pbindef(\chanSeq);
    Ndef(\fingerChan).set(\amp, 0.1, \modIndex, 0.1);

    // Sweep modIndex from 0.1 to 1.5 over 30 seconds
    Ndef(\fingerChan).fadeTime = 30;
    Ndef(\fingerChan).xset(\modIndex, 1.5);

    45.wait; // Now at 1:30

    "1:30 - [Movement III: One-Finger Chan (Climax)]".postln;
    Pbindef(\breathSeq).stop;
    Ndef(\frailBreath).clear(4); // Fades out the youth motif

    // Hard set to brilliant, piercing metallic focus
    Ndef(\fingerChan).set(\modIndex, 5.0, \amp, 0.25);

    // Push GVerb wetness to 70% over 8 seconds
    Ndef(\fingerChan).fadeTime = 8;
    Ndef(\fingerChan).xset(\wet10, 0.7);

    30.wait; // Now at 2:00

    "2:00 - [The Weight of the Feat]".postln;
    // Slowly sweep freqMult to create excruciating upward harmonic tension
    Ndef(\fingerChan).fadeTime = 15;
    Ndef(\fingerChan).xset(\freqMult, 1.05);

    30.wait; // Now at 2:30

    "2:30 - [Movement IV: Empty Cloud (Resolution)]".postln;
    Ndef(\emptyCloud).play;
    Ndef(\emptyCloud)[1] = \set -> Pbindef(\cloudSeq);

    // Immediately drop modIndex to release physical tension, carve out low end
    Ndef(\fingerChan).fadeTime = 12;
    Ndef(\fingerChan).xset(\modIndex, 1.0, \hpfFreq, 800);

    // Raise the spiritual mist reverb to 80% wet over 12 seconds
    Ndef(\emptyCloud).fadeTime = 12;
    Ndef(\emptyCloud).xset(\wet11, 0.8);

    30.wait; // Now at 3:00

    "3:00 - [Qigong Harmony]".postln;
    // Sweep the pad's filter downward to muffle harmonics into a deep bodily vibration
    Ndef(\emptyCloud).fadeTime = 15;
    Ndef(\emptyCloud).xset(\lpfFreq, 400);

    15.wait; // Now at 3:15

    "3:15 - [Movement V: Dissolution & Terminate]".postln;
    Pbindef(\chanSeq).stop;
    Pbindef(\cloudSeq).stop;

    // Majestic, 15-second unsegmented fade into absolute silence
    Ndef(\fingerChan).clear(15);
    Ndef(\emptyCloud).clear(15);

    "Score Complete. The lineage remains.".postln;
});
)

// Source: composition-isleofthedead-5-works-inspired-by.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------

    // Biomechanical Intrusions: Atonal FM plucks
    SynthDef(\biomechClick, { |out=0, freq=2000, modFreq=3000, fmIndex=5, dec=0.01, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, dec), doneAction: 2);
        var mod = SinOsc.ar(modFreq) * fmIndex * env;
        var sig = SinOsc.ar(freq + mod);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // The Signalis Loop: Wave-folded bass
    SynthDef(\waveBass, { |out=0, freq=55, foldAmount=0.5, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.25), doneAction: 2);
        var sig = LFTri.ar(freq);
        // Intense wavefolding simulating a Shaper buffer overdrive
        sig = Fold.ar(sig * (1 + (foldAmount * 15)), -0.5, 0.5);
        sig = RLPF.ar(sig, freq * 6, 0.4);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // The Signalis Loop: Fleshy Arp
    SynthDef(\leadArp, { |out=0, freq=440, amp=0.1, pan=0, cutoff=2500|
        var env = EnvGen.ar(Env.perc(0.005, 0.15), doneAction: 2);
        var sig = Pulse.ar(freq, 0.3);
        sig = MoogFF.ar(sig, cutoff * env + 150, 1.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: The Oarsman (Granular Waters)
    Ndef(\darkWaters, {
        var dens = \grainDens.kr(20);
        var spread = \panSpread.kr(0.8);
        var trig = Dust.ar(dens);

        // Asymmetrical LFO to emulate uneven rowing and waves
        var asymLFO = LFSaw.kr(0.05, 1).range(0.2, 1.0) * SinOsc.kr(0.13).range(0.5, 1.0);
        var noise = WhiteNoise.ar * asymLFO;

        // Dark, viscous filtering
        var filt = BPF.ar(noise, LFNoise2.kr(0.2).exprange(150, 1000), 0.4);

        var sig = GrainIn.ar(2, trig, 0.25, filt, spread * TRand.kr(-1, 1, trig));
        sig * \amp.kr(0);
    });

    // Movement III: Romantic Despair (Modal Resonator Bank)
    Ndef(\romanticSpectral, {
        var detune = \detuneAmount.kr(0);
        var base = 41.2; // E1
        var degrees = [0, 1, 4, 5, 7, 8, 10]; // Phrygian Dominant cluster

        var sig = Mix.fill(50, { |i|
            var deg = degrees.wrapAt(i);
            var oct = i div: 7;
            var idealFreq = (base.cpsmidi + deg + (oct * 12)).midicps;

            // Chaos pushes the pure sines into microtonal dissonance
            var drift = LFNoise2.kr(0.05).range(1, 1 + (detune * 0.12));
            SinOsc.ar(idealFreq * drift) * (1 / (i + 1).sqrt);
        });

        // Heavy resonant low-pass filter
        sig = RLPF.ar(sig, 1200, 0.15);
        Pan2.ar(sig * \amp.kr(0) * 0.015, 0);
    });

    // Master JITLib Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\darkWaters, 2) + Ndef.ar(\romanticSpectral, 2);
        synths + continuous;
    });

    // FX Slot 10: Abyss Reverb (Massive, dark reverberation)
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.98, damp: 0.85);
    };

    // FX Slot 20: Ruin Distortion (Kinetic sequence saturation)
    Ndef(\masterMix)[20] = \filter -> { |in|
        (in * 6).tanh * 0.6;
    };

    Ndef(\masterMix).set(\wet10, 0, \wet20, 0);
    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\avernusScore, {

        "0:00 - [Cue 1: The Oarsman (Brooding & Monolithic)]".postln;
        Ndef(\darkWaters).fadeTime = 5;
        Ndef(\darkWaters).set(\amp, 1.5);
        Ndef(\masterMix).set(\wet10, 0.3); // Slight reverb for the water

        // ACTIVE WAIT: 35 Seconds (Swell grain density unpredictably)
        7.do {
            Ndef(\darkWaters).xset(\grainDens, rrand(10.0, 60.0), \panSpread, rrand(0.3, 1.0));
            5.wait;
        };

        "0:35 - [Cue 2: Biomechanical Intrusions (Frantic & Metallic)]".postln;
        Pbindef(\gigerSeq,
            \instrument, \biomechClick,
            \out, ~synthBus,
            \dur, Pwhite(0.05, 0.35, inf),
            \freq, Pexprand(800, 5000, inf),
            \modFreq, Pkey(\freq) * Pwhite(0.5, 3.5, inf),
            \fmIndex, 5,
            \dec, 0.01,
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, 0.4
        ).play;

        // ACTIVE WAIT: 37 Seconds (Randomly spike fmIndex and shorten decay)
        12.do {
            Pbindef(\gigerSeq,
                \fmIndex, rrand(2.0, 18.0),
                \dec, rrand(0.002, 0.03)
            );
            3.wait;
        };
        1.wait;

        "1:12 - [Cue 3: Romantic Despair (Sweeping & Tragic)]".postln;
        // SPOTLIGHT RULE: HARD CONTRAST
        Pbindef(\gigerSeq).stop;
        Ndef(\darkWaters).set(\amp, 0); // Instant subtraction of waters

        Ndef(\romanticSpectral).set(\amp, 1, \detuneAmount, 0);
        Ndef(\masterMix).set(\wet10, 0.7); // Spike reverb wet mix

        // ACTIVE WAIT: 53 Seconds (Continuous xset sweep of detuneAmount into dissonance)
        53.do { |i|
            var progress = i / 53;
            Ndef(\romanticSpectral).set(\detuneAmount, progress * 4.5);
            1.wait;
        };

        "2:05 - [Cue 4: The Signalis Loop (Late-Stage Kinetic Euphoria)]".postln;
        // SPOTLIGHT RULE: INSTANT CLEARANCE
        Ndef(\romanticSpectral).clear;
        Ndef(\masterMix).set(\wet10, 0); // Reverb bypassed completely
        Ndef(\masterMix).set(\wet20, 1); // Ruin Distortion fully engaged

        // Aggressive wave-folded bass
        Pbindef(\signalisPulse,
            \instrument, \waveBass,
            \out, ~synthBus,
            \dur, 0.25,
            \freq, Pseq([41.2, 41.2, 46.25, 41.2], inf), // E1, F#1 rhythmic pedal
            \foldAmount, 0.2,
            \amp, 0.7
        ).play;

        // Frantic 16th-note Lydian Dominant sequence
        Pbindef(\fleshyArp,
            \instrument, \leadArp,
            \out, ~synthBus,
            \dur, 0.125,
            \freq, Pseq([0, 2, 4, 6, 7, 9, 10].midiratio * 164.81, inf) * Prand([1, 2], inf),
            \cutoff, Pexprand(800, 4000, inf),
            \pan, Pseq([-0.3, 0.3, -0.6, 0.6], inf),
            \amp, 0.3
        ).play;

        // ACTIVE WAIT: 50 Seconds (Automate aggression on the wavefolder)
        10.do {
            Pbindef(\signalisPulse, \foldAmount, rrand(0.2, 1.2));
            5.wait;
        };

        "2:55 - [Cue 5: The Isle Reclaimed (Abrupt Decrease & Long Fade)]".postln;
        // INSTANT TERMINATION OF KINETIC SEQUENCE
        Pbindef.removeAll;
        Ndef(\masterMix).set(\wet20, 0); // Distortion instantly off

        // RETURN TO POINT OF DEPARTURE
        Ndef(\darkWaters).set(\amp, 1.5, \grainDens, 15);
        Ndef(\masterMix).set(\wet10, 0.5); // Reverb back on for ghostly tail

        // 22-SECOND FADE OUT
        Ndef(\darkWaters).fadeTime = 22;
        Ndef(\masterMix).fadeTime = 22;

        Ndef(\darkWaters).xset(\amp, 0);
        Ndef(\masterMix).xset(\wet10, 0);

        // ACTIVE WAIT: 22 Seconds
        4.do {
            5.wait;
        };
        2.wait;

        "3:17 - [Termination: Absolute Silence]".postln;
        Ndef.clear;
        "Score Complete.".postln;
    });

    Tdef(\avernusScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead1.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\distantBell, { |out=0, freq=400, decayTime=5, ringTime=4, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decayTime), doneAction: 2);
        var exc = PinkNoise.ar(0.1) * EnvGen.ar(Env.perc(0.001, 0.05));
        var freqs = [1, 2.3, 3.5, 4.7, 5.1] * freq;
        var amps = [1, 0.6, 0.4, 0.2, 0.1];
        var decays = [1, 0.8, 0.6, 0.4, 0.2] * ringTime;
        var sig = DynKlank.ar(`[freqs, amps, decays], exc);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\windWhispers, { |out=0, startFreq=400, endFreq=200, glissTime=5, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.linen(glissTime * 0.2, glissTime * 0.6, glissTime * 0.2), doneAction: 2);
        var freqEnv = XLine.kr(startFreq, endFreq, glissTime);
        var sig = Saw.ar(freqEnv) + Pulse.ar(freqEnv * 1.01, 0.5);
        sig = BPF.ar(sig, freqEnv * 1.5, 0.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\sharpPluck, { |out=0, freq=400, fmIndex=2, decay=0.05, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * 2.41) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\mistyGrain, { |grainDens=0.5, grainSize=0.1, hpFreq=5000, amp=0, panPos=0|
        var trigs = Dust.ar(grainDens);
        var sig = GrainIn.ar(2, trigs, grainSize, WhiteNoise.ar, panPos);
        sig = HPF.ar(sig, hpFreq);
        sig * amp;
    });

    Ndef(\coldPad, { |filterFreq=8000, q=0.2, detune=0.01, amp=0|
        var sig = Saw.ar([100, 100 * (1 + detune)]) + Pulse.ar([50, 50 * (1 - detune)], 0.5);
        sig = RLPF.ar(sig, filterFreq, q.max(0.01));
        sig * amp;
    });

    Ndef(\oarStroke, { |freq=40, index=2, q=0.1, decay=6, amp=0|
        var t_trig = \t_trig.tr(0);
        var env = EnvGen.ar(Env.perc(0.1, decay), t_trig);
        var mod = SinOsc.ar(freq * 1.41) * index * freq * env;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, freq * 4, q.max(0.01));
        Pan2.ar(sig * env * amp, 0);
    });

    Ndef(\cypressDrone, { |carrierFreq=80, modIndex=4.0, detuneAmount=0.02, modSpeed=0.1, amp=0|
        var lfoDetune = LFSaw.kr(modSpeed).range(0.5, 1.5) * detuneAmount;
        var lfoMod = SinOsc.kr(modSpeed * 0.7).range(0.8, 1.2) * modIndex;
        var mod = SinOsc.ar(carrierFreq * 2.01) * lfoMod * carrierFreq;
        var sig = SinOsc.ar(carrierFreq + mod + [0, lfoDetune * carrierFreq]);
        sig = sig + SinOsc.ar((carrierFreq * 0.5) + mod + [lfoDetune * carrierFreq, 0]);
        sig * amp;
    });

    Ndef(\spectralDistortion, { |chaosAmount=0.2, hpFreq=1000, foldAmount=0.5, amp=0|
        var chaos = chaosAmount.linlin(0, 1, 1.0, 1.99); // Safe range for Crackle
        var sig = Crackle.ar(chaos ! 2);
        sig = sig + (LFNoise1.ar(400 ! 2) * chaosAmount);
        sig = HPF.ar(sig, hpFreq.max(100));
        sig = Fold.ar(sig * (1 + (foldAmount * 5)), -0.5, 0.5);
        sig * amp;
    });

    // Master JITLib Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\mistyGrain, 2) +
                         Ndef.ar(\coldPad, 2) +
                         Ndef.ar(\oarStroke, 2) +
                         Ndef.ar(\cypressDrone, 2) +
                         Ndef.ar(\spectralDistortion, 2);
        synths + continuous;
    });

    // Reverb FX Slot
    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \verbWet.kr(0.4);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.8);
        XFade2.ar(in, verb, wet * 2 - 1);
    };
    Ndef(\masterMix).set(\verbWet, 0.4);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        // ==========================================================
        "0:00 - [Cue 1: The Approach (Misty Shores)]".postln;
        // ==========================================================
        Ndef(\mistyGrain).fadeTime = 0.1; Ndef(\mistyGrain).xset(\amp, 0.6);
        Ndef(\coldPad).fadeTime = 0.1; Ndef(\coldPad).xset(\amp, 0.5);

        // Long fading automations
        Ndef(\mistyGrain).fadeTime = 20; Ndef(\mistyGrain).xset(\grainDens, 3.0);
        Ndef(\mistyGrain).fadeTime = 30; Ndef(\mistyGrain).xset(\hpFreq, 2000);
        Ndef(\coldPad).fadeTime = 40; Ndef(\coldPad).xset(\filterFreq, 1500, \q, 0.6);
        Ndef(\masterMix).fadeTime = 10; Ndef(\masterMix).xset(\verbWet, 0.7);

        Pbindef(\bellChimes,
            \instrument, \distantBell,
            \out, ~synthBus,
            \dur, Pwhite(4.0, 8.0, inf),
            \freq, Pexprand(800, 2500, inf),
            \decayTime, 5,
            \ringTime, 4,
            \amp, 0.15
        ).play;

        // ACTIVE WAIT: 42.5 seconds (8 loops of ~5.3s)
        8.do {
            Ndef(\coldPad).xset(\detune, rrand(0.005, 0.02));
            Ndef(\mistyGrain).xset(\panPos, rrand(-0.3, 0.3));
            5.3125.wait;
        };

        // ==========================================================
        "0:42.5 - [Cue 2: The Ferryman's Oar (Solemn Passage)]".postln;
        // ==========================================================
        Ndef(\oarStroke).fadeTime = 0.1; Ndef(\oarStroke).xset(\amp, 0.8);

        Pbindef(\oarSeq,
            \type, \set,
            \id, Pfunc({ Ndef(\oarStroke).nodeID }),
            \args, #[\t_trig, \freq, \index, \decay],
            \t_trig, 1,
            \dur, Pwhite(2.0, 5.0, inf),
            \freq, Pwhite(38.0, 43.0, inf),
            \index, Pwhite(1.5, 2.5, inf),
            \decay, Pwhite(6.0, 8.0, inf)
        ).play;

        Ndef(\mistyGrain).fadeTime = 7.5; Ndef(\mistyGrain).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 30; Ndef(\coldPad).xset(\filterFreq, 2500);

        Pbindef(\bellChimes, \dur, Pwhite(6.0, 10.0, inf), \amp, 0.05);

        // ACTIVE WAIT: 45.5 seconds (7 loops of 6.5s)
        7.do {
            Ndef(\oarStroke).xset(\q, rrand(0.1, 0.3));
            6.5.wait;
        };

        // ==========================================================
        "1:28.0 - [Cue 3: Isle's Embrace (Cypress Shadows)]".postln;
        // ==========================================================
        Ndef(\cypressDrone).fadeTime = 10;
        Ndef(\cypressDrone).xset(\amp, 0.7, \carrierFreq, 80, \modIndex, 4.0);

        Ndef(\oarStroke).fadeTime = 12; Ndef(\oarStroke).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 20; Ndef(\coldPad).xset(\filterFreq, 800);
        Ndef(\masterMix).fadeTime = 5; Ndef(\masterMix).xset(\verbWet, 0.9);

        // Subtractive Arrangement: Fade out bells and stop oar sequence
        fork {
            12.do { |i|
                Pbindef(\bellChimes, \amp, 0.05 * (1 - (i/11)));
                1.wait;
            };
            Pbindef(\bellChimes).stop;
            Pbindef(\oarSeq).stop;
        };

        Pbindef(\glissandi,
            \instrument, \windWhispers,
            \out, ~synthBus,
            \dur, Pwhite(5.0, 12.0, inf),
            \startFreq, Pseq([Pwhite(400, 600, 1), Pwhite(200, 300, 1)], inf),
            \endFreq, Pseq([Pwhite(200, 300, 1), Pwhite(400, 600, 1)], inf),
            \glissTime, Pwhite(3.0, 8.0, inf),
            \amp, 0.15
        ).play;

        // ACTIVE WAIT: 52 seconds (8 loops of 6.5s)
        8.do {
            Ndef(\cypressDrone).xset(\detuneAmount, rrand(0.01, 0.04));
            6.5.wait;
        };

        // ==========================================================
        "2:20.0 - [Cue 4: Echoes of the Departed (Unsettling Memories)]".postln;
        // ==========================================================
        Ndef(\spectralDistortion).fadeTime = 5; Ndef(\spectralDistortion).xset(\amp, 0.35);
        Ndef(\spectralDistortion).fadeTime = 15; Ndef(\spectralDistortion).xset(\chaosAmount, 0.8);

        Pbindef(\memoryFlashes,
            \instrument, \sharpPluck,
            \out, ~synthBus,
            \dur, Pwhite(0.5, 2.5, inf),
            \midinote, Pshuf([60, 62, 65, 68, 70, 71, 74], inf),
            \fmIndex, Pwhite(2.0, 6.0, inf),
            \decay, 0.05,
            \amp, 0.12
        ).play;

        Ndef(\cypressDrone).fadeTime = 10;
        Ndef(\cypressDrone).xset(\modIndex, 6.0, \detuneAmount, 0.06);
        Ndef(\masterMix).fadeTime = 5; Ndef(\masterMix).xset(\verbWet, 0.6);

        // Subtractive Arrangement: Fade out glissandi
        fork {
            5.do { |i|
                Pbindef(\glissandi, \amp, 0.15 * (1 - (i/4)));
                1.wait;
            };
            Pbindef(\glissandi).stop;
        };

        // ACTIVE WAIT: 30 seconds (6 loops of 5s)
        6.do {
            Ndef(\spectralDistortion).xset(\foldAmount, rrand(0.2, 0.8));
            5.wait;
        };

        // ==========================================================
        "2:50.0 - [Cue 5: Return to Silence (Dissolution)]".postln;
        // ==========================================================
        Pbindef(\memoryFlashes).stop;

        Ndef(\spectralDistortion).fadeTime = 5; Ndef(\spectralDistortion).xset(\amp, 0.0);
        Ndef(\cypressDrone).fadeTime = 25; Ndef(\cypressDrone).xset(\amp, 0.0);
        Ndef(\coldPad).fadeTime = 25; Ndef(\coldPad).xset(\amp, 0.0);
        Ndef(\masterMix).fadeTime = 25; Ndef(\masterMix).xset(\verbWet, 0.0);

        // ACTIVE WAIT: 25 seconds (5 loops of 5s)
        5.do {
            5.wait;
        };

        "3:15.0 - [Final Clearing]".postln;
        Ndef.clear(2.0);
        2.wait;

        "3:17.0 - [End]".postln;
        Tdef.removeAll;
        Pbindef.removeAll;
        s.freeAll;
        "Score Complete. Server Silent.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead2.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~sourceGroup = Group.new(s);
    ~fxGroup = Group.after(~sourceGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\oarStroke, { |out=0, freq=120, decay=1.0, pan=0, amp=0.8|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var exc = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.03));
        // Physical modeling of a wet, wooden thud
        var sig = Pluck.ar(exc, exc, 0.2, freq.reciprocal.clip(0.0001, 0.2), decay, 0.4);
        sig = LPF.ar(sig, 800) + (BPF.ar(exc, 400, 0.5) * 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\cliffResonance, { |out=0, freq=800, fmIndex=5, ringTime=4, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.05, ringTime), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.4142) * fmIndex * env * freq;
        var sig = SinOsc.ar(freq + mod);
        // Dedicated subtle delay for the resonant echoes
        var del = CombC.ar(sig, 1.0, 0.33, 3.0);
        sig = (sig * 0.7) + (del * 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\sepulchralKnock, { |out=0, freq=400, attack=0.001, decay=0.4, brightness=0.8, amp=1|
        var env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);
        var exc = WhiteNoise.ar * env;
        var sig = Resonz.ar(exc, freq, 0.05) * 30;
        sig = sig + (LPF.ar(exc, freq * 3) * brightness);
        // Short, dry internal room reflection
        sig = FreeVerb.ar(sig, 0.3, 0.1, 0.9);
        Out.ar(out, Pan2.ar(sig * amp, 0));
    }).add;

    SynthDef(\whiteFigureSwell, { |out=0, freq=880, swellTime=5, filterCutoff=2000, brightness=0.5, amp=0.4, gate=1|
        var env = EnvGen.ar(Env.asr(swellTime, 1, swellTime + 2), gate, doneAction: 2);
        var sig = Splay.ar(Saw.ar(freq * [0.99, 1, 1.01, 2.005]));
        sig = RLPF.ar(sig, filterCutoff * (1 + (brightness * env)), 0.4);
        Out.ar(out, sig * env * amp);
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\darkWaterDrone, {
        var lfo = SinOsc.kr(\lfoRate.kr(0.01)).exprange(\lfoMin.kr(80), \lfoMax.kr(150));
        var ampLfo = SinOsc.kr(0.05).range(0.8, 1.0);
        var sig = BrownNoise.ar(0.8) + Saw.ar([30, 30.2], 0.15);
        sig = RLPF.ar(sig, lfo, \q.kr(0.3));
        sig = RHPF.ar(sig, \hpFreq.kr(20).max(20), 0.5);
        sig * \amp.kr(0.6) * ampLfo;
    });

    Ndef(\cypressGrove, {
        var detune = \detuneAmount.kr(0.001);
        var dens = \density.kr(8);
        var spread = \pitchSpread.kr(0.02);
        var base = 110;
        var sig = Mix.fill(8, { |i|
            var freq = base * (1 + (i * spread)) * LFNoise2.kr(0.15).range(1-detune, 1+detune);
            SinOsc.ar(freq) * (1 / (i+1));
        });
        Splay.ar(sig) * \amp.kr(0.0); // Starts at 0, faded in later
    });

    Ndef(\spectralWhispers, {
        var sig = PinkNoise.ar(1);
        var dens = \grainDens.kr(5);
        var gSpread = \grainSpread.kr(0.8);
        var pShift = \pitchShift.kr(1.0);
        sig = BPF.ar(sig, \cutoff.kr(1200), 0.2);
        sig = PitchShift.ar(sig, 0.2, pShift, gSpread, dens/100);
        Pan2.ar(sig, LFNoise1.kr(0.1)) * \amp.kr(0.0); // Starts at 0
    });

    Ndef(\coffinHum, {
        var root = \rootFreq.kr(41.2); // E1
        var spread = \spread.kr(0.5);
        var sig = Mix.fill(3, { |i|
            SinOsc.ar(root + (i * spread)) + Pulse.ar(root * (i+1) + spread, 0.5, 0.05);
        });
        sig = LPF.ar(sig, 150);
        Splay.ar(sig) * \amp.kr(0.0); // Starts at 0
    });

    // Master Mixer: Sums discrete synths and continuous drones
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var drone = Ndef.ar(\darkWaterDrone, 2);
        var cypress = Ndef.ar(\cypressGrove, 2);
        var whispers = Ndef.ar(\spectralWhispers, 2);
        var coffin = Ndef.ar(\coffinHum, 2);
        synths + drone + cypress + whispers + coffin;
    });

    // Global Reverb Insert
    Ndef(\masterMix)[20] = \filter -> { |in|
        var wet = \wet20.kr(0.7);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: \revDecay.kr(0.9), damp: 0.1);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    Ndef(\masterMix).play(group: ~fxGroup);
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Somber Approach]".postln;
        Ndef(\darkWaterDrone).fadeTime = 5;
        Ndef(\darkWaterDrone).set(\amp, 0.7, \lfoMin, 80, \lfoMax, 150, \hpFreq, 20);
        Ndef(\masterMix).set(\wet20, 0.7, \revDecay, 0.85);

        Pbindef(\rowingRhythm,
            \instrument, \oarStroke,
            \out, ~synthBus,
            \dur, Pwhite(0.9, 1.1, inf) * 2.5, // ~40bpm, slightly irregular
            \freq, 90,
            \decay, 1.0,
            \amp, 0.6,
            \pan, Pseg([-0.6, 0.6, -0.6], [8, 8], \sine, inf) // Sweeping pan
        ).play;

        // Active Wait: 42 seconds (6 loops of 7s)
        6.do {
            // Micro-pacing: Subtle shifts in drone resonance
            Ndef(\darkWaterDrone).xset(\q, rrand(0.25, 0.4));
            7.wait;
        };

        "0:42 - [Cue 2: Islet's Imposing Form (SUBTRACTIVE CONTRAST)]".postln;
        Ndef(\cypressGrove).fadeTime = 5;
        Ndef(\cypressGrove).set(\amp, 0.5);
        Ndef(\darkWaterDrone).xset(\lfoMin, 150, \lfoMax, 300); // Sweep upwards
        Ndef(\cypressGrove).xset(\detuneAmount, 0.005); // Slowly detune

        Pbindef(\rowingRhythm).xset(\decay, 1.3); // Heavier, submerged strokes

        Pbindef(\rockEchoes,
            \instrument, \cliffResonance,
            \out, ~synthBus,
            \dur, Pseq([8, 12, 10, 9], inf), // Very sparse
            \freq, Pexprand(600, 1200, inf),
            \fmIndex, Pwhite(5.0, 10.0, inf),
            \ringTime, 6,
            \amp, 0.4,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        // Active Wait: 43 seconds (6 loops of 7.16s)
        6.do {
            // Micro-pacing: Evolving cypress density
            Ndef(\cypressGrove).xset(\pitchSpread, rrand(0.015, 0.03));
            7.16.wait;
        };

        "1:25 - [Cue 3: Sepulchral Echoes (SUBTRACTIVE ARRANGEMENT)]".postln;
        Ndef(\cypressGrove).fadeTime = 8;
        Ndef(\cypressGrove).xset(\amp, 0.15); // Subtraction for whispers

        Ndef(\darkWaterDrone).fadeTime = 15;
        Ndef(\darkWaterDrone).xset(\lfoMin, 100, \lfoMax, 180); // Sweep downwards

        Ndef(\spectralWhispers).fadeTime = 4;
        Ndef(\spectralWhispers).set(\amp, 0.6, \grainDens, 5, \grainSpread, 0.8);

        Pbindef(\rockEchoes, \dur, Pseq([5, 8, 7], inf)); // Slightly more frequent

        // Active Wait: 20 seconds until the Knock (4 loops of 5s)
        4.do {
            Ndef(\spectralWhispers).xset(\pitchShift, rrand(0.6, 1.4));
            5.wait;
        };

        "1:45 - [Cue 3.5: The Knock]".postln;
        Synth(\sepulchralKnock, [\out, ~synthBus, \freq, 450, \amp, 1.2]);
        Ndef(\masterMix).set(\wet20, 0.3); // Briefly dry for impact

        1.wait;
        Ndef(\masterMix).xset(\wet20, 0.7); // Return to wet
        4.wait;

        // Active Wait: Remaining 15 seconds of Cue 3
        3.do {
            Ndef(\spectralWhispers).xset(\pitchShift, rrand(0.6, 1.4));
            5.wait;
        };

        "2:05 - [Cue 4: The Threshold & Contemplation (SPOTLIGHT RULE)]".postln;
        Pbindef(\rowingRhythm).stop; // INSTANT SUBTRACTION

        Ndef(\darkWaterDrone).fadeTime = 10;
        Ndef(\darkWaterDrone).xset(\hpFreq, 100, \amp, 0.4); // High-pass and reduce

        Ndef(\coffinHum).fadeTime = 3;
        Ndef(\coffinHum).set(\amp, 0.7);

        Ndef(\spectralWhispers).fadeTime = 15;
        Ndef(\spectralWhispers).xset(\amp, 0.0); // Fade out whispers

        Ndef(\masterMix).xset(\revDecay, 0.95); // Lengthen reverb

        Pbindef(\figureGlow,
            \instrument, \whiteFigureSwell,
            \out, ~synthBus,
            \dur, 8,
            \legato, 1.1, // Overlapping pads
            \freq, Pseq([880, 932, 1046, 987], inf), // Ethereal slow melody
            \swellTime, 4,
            \filterCutoff, 1500,
            \amp, 0.5
        ).play;

        // Active Wait: 45 seconds (9 loops of 5s)
        9.do { |i|
            // Slowly increase brightness of the figure
            Pbindef(\figureGlow, \brightness, 0.2 + (i/9 * 0.8));
            5.wait;
        };

        "2:50 - [Cue 5: Dissolution into Afterlife (LONG FADE TO SILENCE)]".postln;
        Pbindef(\figureGlow).stop;
        Pbindef(\rockEchoes).stop;

        // Initiate long clears
        Ndef(\darkWaterDrone).clear(25);
        Ndef(\cypressGrove).clear(20);
        Ndef(\coffinHum).clear(22);

        // Fade out the master mix effects and volume
        Ndef(\masterMix).fadeTime = 27;
        Ndef(\masterMix).xset(\wet20, 1.0, \revDecay, 0.99); // Wash out completely before death

        // Active Wait: 27 seconds for the fade
        5.do {
            5.4.wait;
        };

        "3:17 - [Termination]".postln;
        Pbindef.removeAll;
        Ndef.clear;
        Tdef.removeAll;
        "Score Complete. Silence.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-isleofthedead3.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ALLOCATION
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~granBuf = Buffer.alloc(s, s.sampleRate * 2, 1);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\woodStrike, { |out=0, freq=100, strikeForce=0.5, decayTime=1.0, pan=0, amp=0.5|
        var env = EnvGen.ar(Env.perc(0.001, decayTime), doneAction: 2);
        var exciter = PinkNoise.ar(strikeForce) * EnvGen.ar(Env.perc(0.001, 0.05));
        var sig = Klank.ar(`[
            [freq, freq*1.5, freq*2.3, freq*3.8, freq*5.1],
            [1, 0.6, 0.4, 0.2, 0.1],
            [1, 0.8, 0.6, 0.4, 0.2]
        ], exciter, decayscale: decayTime);
        sig = sig * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\lifeBell, { |out=0, freq=440, fmRatio=2.1, fmIndex=2, decayTime=2.0, pan=0, amp=0.2|
        var env = EnvGen.ar(Env.perc(0.005, decayTime), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\spectralGrief, { |cutoff=40, hpFreq=10, pmIndex=1, amp=0|
        var mod = SinOsc.ar([50.2, 49.8]) * pmIndex * 100;
        var sig = SinOsc.ar([50, 51] + mod);
        sig = BPF.ar(sig, cutoff, 0.2) * 5;
        sig = HPF.ar(sig, hpFreq);
        sig * amp;
    });

    Ndef(\ruinFold, { |foldAmount=1, amp=0|
        var sig = LFSaw.ar([40, 41] + LFNoise1.kr(2).range(-5, 5));
        sig = Fold.ar(sig * foldAmount, -0.1, 0.1) * 10;
        sig = RLPF.ar(sig, LFNoise1.kr(0.5).exprange(100, 4000), 0.3);
        (sig * amp).tanh;
    });

    Ndef(\hermitageGranular, { |grainDens=10, amp=0|
        var in = Mix(In.ar(~synthBus, 2));
        var rec = RecordBuf.ar(in, ~granBuf, loop: 1);
        var trigs = Dust.ar(grainDens);
        var dur = TRand.ar(0.05, 0.3, trigs);
        var pos = (Phasor.ar(0, BufRateScale.kr(~granBuf), 0, BufFrames.kr(~granBuf)) / BufSampleRate.kr(~granBuf)) - TRand.ar(0.05, 1.5, trigs);
        var sig = TGrains.ar(2, trigs, ~granBuf, TRand.ar(0.5, 2.0, trigs), pos, dur, TRand.ar(-1, 1, trigs), 0.5, 2);
        sig * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\spectralGrief, 2) + Ndef.ar(\ruinFold, 2) + Ndef.ar(\hermitageGranular, 2);
        synths + continuous;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var wet = \wet10.kr(1.0);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.1);
        XFade2.ar(in, verb, wet * 2 - 1);
    };

    // Initialize parameters
    Ndef(\masterMix).set(\wet10, 1.0);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The English Cemetery (Grief & Conception)]".postln;
        Ndef(\masterMix).set(\wet10, 1.0);
        Ndef(\spectralGrief).set(\amp, 0.8, \cutoff, 40);

        // ACTIVE WAIT STATE: Sweep drone cutoff over 35 seconds
        35.do { |i|
            var targetCutoff = 40 * exp(i/34 * log(10)); // Sweeps 40 to ~400 logarithmically
            Ndef(\spectralGrief).xset(\cutoff, targetCutoff);
            1.wait;
        };

        "0:35 - [Cue 2: The Coffin (Rhythmic Awakening)]".postln;
        Pbindef(\coffinSeq,
            \instrument, \woodStrike,
            \out, ~synthBus,
            \dur, Pseq([1, 1, 0.5, 1.5, 2], inf),
            \freq, Pwhite(80, 120, inf),
            \pan, Pwhite(-0.4, 0.4, inf),
            \amp, 0.6
        ).play;

        // ACTIVE WAIT STATE: Mutate the wood strikes over 33 seconds
        33.do { |i|
            var prog = i/32;
            Pbindef(\coffinSeq,
                \strikeForce, 0.1 + (prog * 0.9),
                \decayTime, 1.5 - (prog * 1.3)
            );
            1.wait;
        };

        "1:08 - [Cue 3: Proliferation & Ruin]".postln;
        Pbindef(\coffinSeq).stop; // INSTANT SUBTRACTION
        Ndef(\spectralGrief).fadeTime = 2;
        Ndef(\spectralGrief).xset(\hpFreq, 150); // Make room for distortion low-end
        Ndef(\ruinFold).set(\foldAmount, 1, \amp, 0.5);

        // ACTIVE WAIT STATE: Drive wave-folder to maximum over 34 seconds
        34.do { |i|
            Ndef(\ruinFold).xset(\foldAmount, 1 + (i/33 * 49));
            1.wait;
        };

        "1:42 - [Cue 4: Isle of Life (Abrupt Decrease in Complexity)]".postln;
        // FORM OPERATION C: HARD CUT
        Ndef(\ruinFold).clear;
        Ndef(\spectralGrief).clear;
        Ndef(\masterMix).set(\wet10, 0.2); // Instant dry shift

        Pbindef(\lifeSeq,
            \instrument, \lifeBell,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \octave, Pseq([5, 6, 4, 5], inf),
            \degree, Pseq([0, 2, 4, 6, 7, 4, 2, 0] ++ [0, 4, 2, 7, 6, 2, 4, 1], inf),
            \dur, Pseq([0.125, 0.125, 0.25], inf),
            \fmRatio, Pwhite(1.5, 4.5, inf),
            \fmIndex, Pwhite(1.0, 3.0, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \amp, 0.35
        ).play;

        // ACTIVE WAIT STATE: Euphoric polyrhythms hold the space for 43 seconds
        43.do {
            // Micro-gestures to keep the FM texture alive
            Pbindef(\lifeSeq, \fmIndex, rrand(1.0, 4.0));
            1.wait;
        };

        "2:25 - [Cue 5: The Carlo Echo (Late-Stage Kinetic Energy)]".postln;
        Ndef(\hermitageGranular).set(\amp, 1.0, \grainDens, 10);
        Ndef(\masterMix).fadeTime = 2;
        Ndef(\masterMix).xset(\wet10, 0.8); // Reverb swells back up

        // ACTIVE WAIT STATE: Granular storm consumes the bells over 30 seconds
        30.do { |i|
            Ndef(\hermitageGranular).xset(\grainDens, 10 + (i/29 * 190));
            1.wait;
        };

        "2:55 - [Cue 6: The Long Fade (Explicit Termination)]".postln;
        Pbindef.removeAll; // Stop generating new discrete events immediately
        Ndef.clear(22);    // 22-second fade out on all continuous textures

        // ACTIVE WAIT STATE: Explicitly holding the thread open for the fade
        22.do {
            1.wait;
        };

        "3:17 - Server silent. Piece concludes.".postln;
        Tdef.removeAll;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-maroon-shining-parrot.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & ALLOCATION
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~splitBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        // Master Limiter set to 0.85 to prevent clipping during hyper-density
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe, doneAction: 2)
    // --------------------------------------------------------------------
    SynthDef(\maroonFmPluck, { |out=0, freq=800, modIndex=2, modRatio=1.414, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.15, 1, -4), doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * modIndex * freq * env;
        var car = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(car * env * amp, pan));
    }).add;

    SynthDef(\branchSnap, { |out=0, freq=400, tension=0.01, amp=1, pan=0|
        var exciterEnv = EnvGen.ar(Env.perc(0.001, 0.01));
        var exciter = WhiteNoise.ar * exciterEnv;
        var delayTime = freq.reciprocal.clip(0.0001, 0.05);
        var sig = Pluck.ar(exciter, 1, 0.1, delayTime, tension, 0.2);
        var env = EnvGen.ar(Env.perc(0.001, 0.6), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\waterResonator, { |out=0, freq=1200, amp=0.6, pan=0|
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        var freqs = [1, 1.5, 2.3, 3.8] * freq;
        var amps = [1, 0.6, 0.3, 0.1];
        var rings = [1, 0.8, 0.5, 0.2];
        var sig = DynKlank.ar(Ref([freqs, amps, rings]), exciter);
        var env = EnvGen.ar(Env.perc(0.001, 1.2), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\digitalFracture, { |out=0, freq=100, decimateRate=2000, amp=0.8, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.2, 1, -8), doneAction: 2);
        var sig = LFSaw.ar(freq);
        sig = Latch.ar(sig, Impulse.ar(decimateRate));
        sig = Fold.ar(sig * 8, -0.5, 0.5); // Wave-folding
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\woodPerc, { |out=0, freq=300, fmAmount=100, amp=0.7, pan=0|
        var env = EnvGen.ar(Env.perc(0.002, 0.15), doneAction: 2);
        var mod = SinOsc.ar(freq * 0.4) * fmAmount * env;
        var sig = SinOsc.ar(freq + mod);
        sig = BPF.ar(sig, freq * 1.2, 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\photonGrain, { |grainDensity=2, freq=800, amp=0|
        var trigs = Impulse.ar(grainDensity);
        var freqs = freq * [1, 1.01, 1.03];
        var sig = GrainSin.ar(2, trigs, 0.08, freqs, LFNoise1.kr(1), -1);
        sig.sum * amp;
    });

    Ndef(\insectSwarm, { |swarmWidth=0.2, amp=0|
        var sig = 30.collect {
            LFTri.ar(rrand(400.0, 6000.0)) * LFNoise1.kr(rrand(0.5, 4.0)).max(0)
        };
        Splay.ar(sig, spread: swarmWidth) * amp * 0.05;
    });

    Ndef(\mangroveVoid, { |freq=40, cutoff=400, amp=0|
        var mod = LFNoise2.kr(0.2).range(0.5, 2.5);
        var sig = PMOsc.ar(freq, freq * 1.5, mod);
        sig = sig + Feedback.ar(sig, 0.1);
        sig = LPF.ar(sig, cutoff);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\prehistoricDrift, { |detune=0, amp=0|
        var freqs = [120, 145, 170, 210] + detune;
        var sig = Splay.ar(Saw.ar(freqs));
        sig = RLPF.ar(sig, SinOsc.kr(0.1).exprange(300, 1200), 0.4);
        sig * amp * 0.2;
    });

    Ndef(\taveuniWinds, { |amp=0|
        var sig = BrownNoise.ar(1);
        sig = BPF.ar(sig, LFNoise1.kr(12).exprange(300, 7000), 0.15);
        Pan2.ar(sig, LFNoise1.kr(20)) * amp * 3;
    });

    Ndef(\canopyAscension, { |ascentRate=0.1, amp=0|
        var num = 12;
        var phase = Phasor.ar(0, ascentRate * SampleRate.ir.reciprocal, 0, 1);
        var sig = num.collect { |i|
            var p = (phase + (i/num)) % 1.0;
            var f = p.linexp(0, 1, 40, 12000);
            var a = (p * pi).sin; // Hanning windowing for smooth looping
            SinOsc.ar(f) * a;
        }.sum;
        Pan2.ar(sig * amp * 0.1, 0);
    });

    Ndef(\wingFlapLF, { |flapHz=1, amp=0|
        var osc = SinOsc.ar(50 + SinOsc.kr(flapHz, 0, 15));
        var am = (SinOsc.kr(flapHz) > 0).lag(0.1);
        Pan2.ar(osc * am * amp, 0);
    });

    Ndef(\binauralSplitter, { |amp=0|
        var in = In.ar(~splitBus, 2).sum;
        Pan2.ar(in, LFPulse.kr(18).range(-1, 1)) * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\photonGrain, 2) + Ndef.ar(\insectSwarm, 2) +
                         Ndef.ar(\mangroveVoid, 2) + Ndef.ar(\prehistoricDrift, 2) +
                         Ndef.ar(\taveuniWinds, 2) + Ndef.ar(\canopyAscension, 2) +
                         Ndef.ar(\wingFlapLF, 2) + Ndef.ar(\binauralSplitter, 2);
        synths + continuous;
    });

// --------------------------------------------------------------------
    // EFFECT 1: Global Canopy Reverb
    // --------------------------------------------------------------------
    Ndef(\masterMix)[10] = \filter -> { |in|
        // JITLib automatically handles the dry/wet crossfade via \wet10.
        // Just return the fully wet signal.
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.1);
    };
    Ndef(\masterMix).set(\wet10, 0.1);

    // --------------------------------------------------------------------
    // EFFECT 2: Spectral Degradation (FFT)
    // --------------------------------------------------------------------
    Ndef(\masterMix)[20] = \filter -> { |in|
        // Removed explicit \wet20.kr and XFade2.
        // .clear prevents garbage data and buffer initialization warnings.
        var chain = [FFT(LocalBuf(2048).clear, in[0]), FFT(LocalBuf(2048).clear, in[1])];
        chain = PV_BinShift(chain, \stretch.kr(1), \shift.kr(0));
        chain = PV_MagSmear(chain, \smear.kr(0));

        IFFT(chain);
    };
    Ndef(\masterMix).set(\wet20, 0);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: First Light]".postln;
        Ndef(\photonGrain).set(\amp, 1, \grainDensity, 2);
        Ndef(\masterMix).set(\wet10, 0.3); // Reverb wet mix at 0.3

        // Active Wait: Sweeping grain density up to 50Hz over 5.5s
        11.do { |i|
            Ndef(\photonGrain).xset(\grainDensity, 2 + (i * 4.36));
            0.5.wait;
        };

        "0:05.5 - [Cue 2: Maroon Glint]".postln;
        Pbindef(\agileCalls,
            \instrument, \maroonFmPluck,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.0625, 0.0625, 0.25], inf),
            \freq, Pexprand(2000, 6000, inf),
            \modIndex, Pwhite(1.0, 4.0, inf),
            \amp, 0.6,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        5.do { 0.5.wait; }; // 2.5s wait

        "0:08.0 - [Cue 3: Subtropical Humidity]".postln;
        Pbindef(\agileCalls).stop;
        Ndef(\insectSwarm).fadeTime = 2;
        Ndef(\insectSwarm).set(\amp, 1);
        Ndef(\photonGrain).xset(\freq, 400); // Widen/shift texture

        // Active Wait: 10 seconds of random amplitude modulation of noise bands
        10.do {
            Ndef(\insectSwarm).xset(\swarmWidth, rrand(0.2, 1.0));
            1.wait;
        };

        "0:18.0 - [Cue 4: Branch Snap]".postln;
        // Hard instant mutes
        Ndef(\photonGrain).set(\amp, 0);
        Ndef(\insectSwarm).set(\amp, 0);
        Synth(\branchSnap, [\out, ~synthBus, \freq, 200, \tension, 0.005, \amp, 1.0]);

        1.2.wait;

        "0:19.2 - [Cue 5: Mangrove Drop]".postln;
        Ndef(\mangroveVoid).fadeTime = 1;
        Ndef(\mangroveVoid).set(\amp, 0.8, \cutoff, 1000);

        // Active Wait: 6.8 seconds, sweeping low-pass filter down
        4.do { |i|
            Ndef(\mangroveVoid).xset(\cutoff, 1000 - (i * 200));
            1.7.wait;
        };

        "0:26.0 - [Cue 6: Aquatic Refraction]".postln;
        Pbindef(\dripRhythm,
            \instrument, \waterResonator,
            \out, ~synthBus,
            \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf),
            \freq, Pseq([1200, 1800, 900, 2400], inf),
            \amp, 0.5,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        7.do { 0.5.wait; }; // 3.5s wait

        "0:29.5 - [Cue 7: The Prehistoric Seed]".postln;
        Ndef(\mangroveVoid).fadeTime = 4;
        Ndef(\mangroveVoid).set(\amp, 0);
        Ndef(\prehistoricDrift).fadeTime = 2;
        Ndef(\prehistoricDrift).set(\amp, 1);

        // Active Wait: 10.5 seconds, shifting intonation ratios
        10.do { |i|
            Ndef(\prehistoricDrift).xset(\detune, i * 2.5);
            1.05.wait;
        };

        "0:40.0 - [Cue 8: Avian Glitch]".postln;
        Ndef(\prehistoricDrift).set(\amp, 0); // Hard mute
        Pbindef(\glitchSeq,
            \instrument, \digitalFracture,
            \out, ~synthBus,
            \dur, 0.0625,
            \freq, Pexprand(50, 500, inf),
            \decimateRate, Pwhite(500, 8000, inf),
            \amp, 0.7
        ).play;

        4.do { 0.525.wait; }; // 2.1s wait

        "0:42.1 - [Cue 9: Conspecific Mirror]".postln;
        Pbindef(\glitchSeq).stop;
        Ndef(\binauralSplitter).set(\amp, 1);

        // Dual sequences routed to the binaural splitter bus
        Pbindef(\agileCalls1,
            \instrument, \maroonFmPluck,
            \out, ~splitBus,
            \dur, 0.125,
            \freq, Pseq([3000, 4500, 3200], inf),
            \modIndex, 3,
            \amp, 0.6
        ).play;

        Pbindef(\agileCalls2,
            \instrument, \maroonFmPluck,
            \out, ~splitBus,
            \dur, 0.125,
            \freq, Pseq([3200, 4800, 3500], inf) * 1.05,
            \modIndex, 4,
            \amp, 0.6
        ).play;

        5.do { 1.18.wait; }; // 5.9s wait

        "0:48.0 - [Cue 10: Taveuni Winds]".postln;
        Pbindef(\agileCalls1).stop;
        Pbindef(\agileCalls2).stop;
        Ndef(\binauralSplitter).set(\amp, 0);
        Ndef(\taveuniWinds).fadeTime = 0.5;
        Ndef(\taveuniWinds).set(\amp, 1);

        9.do { 0.5.wait; }; // 4.5s wait

        "0:52.5 - [Cue 11: Sudden Void]".postln;
        Ndef(\taveuniWinds).set(\amp, 0); // Hard mute
        Ndef(\masterMix).set(\wet10, 1.0); // Absolute silence except infinite reverb tail

        1.5.wait;

        "0:54.0 - [Cue 12: Canopy Ascend]".postln;
        Ndef(\masterMix).set(\wet10, 0.2); // Reverb back to normal
        Ndef(\canopyAscension).set(\amp, 1, \ascentRate, 0.05);

        Pbindef(\agileCalls, \out, ~synthBus, \dur, Pwrand([0.125, 0.5, 1.0], [0.2, 0.5, 0.3], inf)).play;

        // Active Wait: 12 seconds, continuous upward sweeps
        12.do { |i|
            Ndef(\canopyAscension).xset(\ascentRate, 0.05 + (i * 0.08));
            1.wait;
        };

        "1:06.0 - [Cue 13: The Crimson Burst]".postln;
        Ndef(\canopyAscension).set(\amp, 0); // Kill ascension
        Pbindef(\agileCalls, \dur, 0.03125, \modIndex, 15, \freq, Pexprand(4000, 8000)); // 32nd notes

        4.do { 1.wait; }; // 4s wait

        "1:10.0 - [Cue 14: Island Drift]".postln;
        Pbindef(\agileCalls).stop;
        // Pitched up 3 octaves
        Ndef(\mangroveVoid).set(\freq, 40 * 8, \cutoff, 4000);
        Ndef(\mangroveVoid).fadeTime = 3;
        Ndef(\mangroveVoid).set(\amp, 0.6);

        9.do { 1.05.wait; }; // 9.5s wait (approx 9 * 1.05 = 9.45)
        0.05.wait;

        "1:19.5 - [Cue 15: Micro-Fracture]".postln;
        Synth(\digitalFracture, [\out, ~synthBus, \freq, 50, \decimateRate, 200, \amp, 1.0]);

        1.5.wait;

        "1:21.0 - [Cue 16: Southern Tonga Memory]".postln;
        Ndef(\mangroveVoid).set(\amp, 0);
        Ndef(\photonGrain).set(\freq, 200, \grainDensity, 15, \amp, 1); // Pitched down
        Ndef(\masterMix).set(\wet20, 1.0, \stretch, 0.5); // Route entirely into Spectral Degradation

        // Active Wait: 12 seconds, smearing the spectrum
        12.do { |i|
            Ndef(\masterMix).xset(\smear, i * 1.5);
            1.wait;
        };

        "1:33.0 - [Cue 17: Rhythmic Overgrowth]".postln;
        Ndef(\masterMix).set(\wet20, 0); // Spectral degrade OFF
        Ndef(\photonGrain).set(\amp, 0);

        Pbindef(\polyRhythm,
            \instrument, \woodPerc,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.125, 0.25, 0.0625, 0.0625, 0.375], inf),
            \freq, Pseq([300, 450, 200, 600, 800, 150], inf),
            \fmAmount, Pwhite(50, 300, inf),
            \amp, 0.8,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        7.do { 1.wait; }; // 7s wait

        "1:40.0 - [Cue 18: Symmetrical Flap]".postln;
        Pbindef(\polyRhythm).stop;
        Ndef(\wingFlapLF).set(\amp, 1, \flapHz, 1);

        // Active Wait: 4.2 seconds, mutating low-frequency sweeps
        4.do { |i|
            Ndef(\wingFlapLF).xset(\flapHz, 1 + (i * 1.25));
            1.05.wait;
        };

        "1:44.2 - [Cue 19: Dense Rainforest Matrix]".postln;
        Ndef(\photonGrain).set(\amp, 1, \freq, 800, \grainDensity, 40);
        Pbindef(\agileCalls, \dur, Pwrand([0.0625, 0.125], [0.7, 0.3], inf), \modIndex, 3).play;

        // Active Wait: 20.8 seconds cinematic climax with random mutes to avoid drone-out
        20.do {
            if(0.2.coin) { Ndef(\photonGrain).set(\amp, 0) } { Ndef(\photonGrain).set(\amp, 1) };
            if(0.3.coin) { Synth(\branchSnap, [\out, ~synthBus, \freq, rrand(150, 400), \tension, 0.01, \amp, 0.8]) };
            1.04.wait;
        };
        Ndef(\photonGrain).set(\amp, 1); // Reset for final fade

        "2:05.0 - [Cue 20: Extinction Event]".postln;
        // Route everything to spectral degradation
        Ndef(\masterMix).set(\wet20, 1.0, \stretch, 0.2, \smear, 15);

        // Global 25-second fade out of all Ndefs
        Ndef.clear(25);

        // Slowing down Pbindefs before stopping
        Pbindef(\agileCalls, \dur, Pgeom(0.125, 1.1, 25));

        // Active Wait: 25 seconds of calculated degradation
        25.do { |i|
            Ndef(\masterMix).xset(\stretch, 0.2 - (i * 0.007).max(0.01));
            1.wait;
        };

        // Absolute dead stop at exactly 2:30.0
        Pbindef.removeAll;
        Tdef.removeAll;
        "2:30.0 - Score Complete. Absolute Silence.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-maroon-shining-parrot2.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING, ALLOCATION & LATENCY
    // --------------------------------------------------------------------
    s.latency = 0.2; // Ensure stable scheduling
    ~synthBus = Bus.audio(s, 2);
    ~splitBus = Bus.audio(s, 2);

    // Allocate permanent FFT buffers to avoid LocalBuf race conditions in JITLib
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe, doneAction: 2)
    // --------------------------------------------------------------------
    SynthDef(\maroonFmPluck, { |out=0, freq=800, modIndex=2, modRatio=1.414, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.15, 1, -4), doneAction: 2);
        var mod = SinOsc.ar(freq * modRatio) * modIndex * freq * env;
        var car = SinOsc.ar(freq + mod);
        Out.ar(out, Pan2.ar(car * env * amp, pan));
    }).add;

    SynthDef(\branchSnap, { |out=0, freq=400, tension=0.01, amp=1, pan=0|
        var exciterEnv = EnvGen.ar(Env.perc(0.001, 0.01));
        var exciter = WhiteNoise.ar * exciterEnv;
        var delayTime = freq.reciprocal.clip(0.0001, 0.05);
        var sig = Pluck.ar(exciter, 1, 0.1, delayTime, tension, 0.2);
        var env = EnvGen.ar(Env.perc(0.001, 0.6), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\waterResonator, { |out=0, freq=1200, amp=0.6, pan=0|
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
        var freqs = [1, 1.5, 2.3, 3.8] * freq;
        var amps = [1, 0.6, 0.3, 0.1];
        var rings = [1, 0.8, 0.5, 0.2];
        var sig = DynKlank.ar(Ref([freqs, amps, rings]), exciter);
        var env = EnvGen.ar(Env.perc(0.001, 1.2), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\digitalFracture, { |out=0, freq=100, decimateRate=2000, amp=0.8, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, 0.2, 1, -8), doneAction: 2);
        var sig = LFSaw.ar(freq);
        sig = Latch.ar(sig, Impulse.ar(decimateRate));
        sig = Fold.ar(sig * 8, -0.5, 0.5); // Wave-folding
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\woodPerc, { |out=0, freq=300, fmAmount=100, amp=0.7, pan=0|
        var env = EnvGen.ar(Env.perc(0.002, 0.15), doneAction: 2);
        var mod = SinOsc.ar(freq * 0.4) * fmAmount * env;
        var sig = SinOsc.ar(freq + mod);
        sig = BPF.ar(sig, freq * 1.2, 0.5);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\photonGrain, { |grainDensity=2, freq=800, amp=0|
        var trigs = Impulse.ar(grainDensity);
        var freqs = freq * [1, 1.01, 1.03];
        var sig = GrainSin.ar(2, trigs, 0.08, freqs, LFNoise1.kr(1), -1);
        sig.sum * amp;
    });

    Ndef(\insectSwarm, { |swarmWidth=0.2, amp=0|
        var sig = 30.collect {
            LFTri.ar(rrand(400.0, 6000.0)) * LFNoise1.kr(rrand(0.5, 4.0)).max(0)
        };
        Splay.ar(sig, spread: swarmWidth) * amp * 0.05;
    });

    Ndef(\mangroveVoid, { |freq=40, cutoff=400, amp=0|
        var mod = LFNoise2.kr(0.2).range(0.5, 2.5);
        var sig = PMOsc.ar(freq, freq * 1.5, mod);
        sig = sig + Feedback.ar(sig, 0.1);
        sig = LPF.ar(sig, cutoff);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\prehistoricDrift, { |detune=0, amp=0|
        var freqs = [120, 145, 170, 210] + detune;
        var sig = Splay.ar(Saw.ar(freqs));
        sig = RLPF.ar(sig, SinOsc.kr(0.1).exprange(300, 1200), 0.4);
        sig * amp * 0.2;
    });

    Ndef(\taveuniWinds, { |amp=0|
        var sig = BrownNoise.ar(1);
        sig = BPF.ar(sig, LFNoise1.kr(12).exprange(300, 7000), 0.15);
        Pan2.ar(sig, LFNoise1.kr(20)) * amp * 3;
    });

    Ndef(\canopyAscension, { |ascentRate=0.1, amp=0|
        var num = 12;
        var phase = Phasor.ar(0, ascentRate * SampleRate.ir.reciprocal, 0, 1);
        var sig = num.collect { |i|
            var p = (phase + (i/num)) % 1.0;
            var f = p.linexp(0, 1, 40, 12000);
            var a = (p * pi).sin;
            SinOsc.ar(f) * a;
        }.sum;
        Pan2.ar(sig * amp * 0.1, 0);
    });

    Ndef(\wingFlapLF, { |flapHz=1, amp=0|
        var osc = SinOsc.ar(50 + SinOsc.kr(flapHz, 0, 15));
        var am = (SinOsc.kr(flapHz) > 0).lag(0.1);
        Pan2.ar(osc * am * amp, 0);
    });

    Ndef(\binauralSplitter, { |amp=0|
        var in = In.ar(~splitBus, 2).sum;
        Pan2.ar(in, LFPulse.kr(18).range(-1, 1)) * amp;
    });

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\photonGrain, 2) + Ndef.ar(\insectSwarm, 2) +
                         Ndef.ar(\mangroveVoid, 2) + Ndef.ar(\prehistoricDrift, 2) +
                         Ndef.ar(\taveuniWinds, 2) + Ndef.ar(\canopyAscension, 2) +
                         Ndef.ar(\wingFlapLF, 2) + Ndef.ar(\binauralSplitter, 2);
        synths + continuous;
    });

    // EFFECT 1: Global Canopy Reverb
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.95, damp: 0.1);
    };

    // EFFECT 2: Spectral Degradation (FFT)
    Ndef(\masterMix)[20] = \filter -> { |in|
        // Safely map to the globally allocated buffers
        var chain = [FFT(~fftBufL, in[0]), FFT(~fftBufR, in[1])];
        chain = PV_BinShift(chain, \stretch.kr(1), \shift.kr(0));
        chain = PV_MagSmear(chain, \smear.kr(0));

        IFFT(chain);
    };

    // Ensure Ndefs are fully playing before setting effect levels
    Ndef(\masterMix).play;
    s.sync;

    Ndef(\masterMix).set(\wet10, 0.1);
    Ndef(\masterMix).set(\wet20, 0);
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        0.5.wait; // Let the server breathe before starting

        "0:00 - [Cue 1: First Light]".postln;
        Ndef(\photonGrain).set(\amp, 1, \grainDensity, 2);
        Ndef(\masterMix).set(\wet10, 0.3);

        11.do { |i|
            Ndef(\photonGrain).xset(\grainDensity, 2 + (i * 4.36));
            0.5.wait;
        };

        "0:05.5 - [Cue 2: Maroon Glint]".postln;
        Pbindef(\agileCalls,
            \instrument, \maroonFmPluck,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.0625, 0.0625, 0.25], inf),
            \freq, Pexprand(2000, 6000, inf),
            \modIndex, Pwhite(1.0, 4.0, inf),
            \amp, 0.6,
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        5.do { 0.5.wait; };

        "0:08.0 - [Cue 3: Subtropical Humidity]".postln;
        Pbindef(\agileCalls).stop;
        Ndef(\insectSwarm).fadeTime = 2;
        Ndef(\insectSwarm).set(\amp, 1);
        Ndef(\photonGrain).xset(\freq, 400);

        10.do {
            Ndef(\insectSwarm).xset(\swarmWidth, rrand(0.2, 1.0));
            1.wait;
        };

        "0:18.0 - [Cue 4: Branch Snap]".postln;
        Ndef(\photonGrain).set(\amp, 0);
        Ndef(\insectSwarm).set(\amp, 0);
        Synth(\branchSnap, [\out, ~synthBus, \freq, 200, \tension, 0.005, \amp, 1.0]);

        1.2.wait;

        "0:19.2 - [Cue 5: Mangrove Drop]".postln;
        Ndef(\mangroveVoid).fadeTime = 1;
        Ndef(\mangroveVoid).set(\amp, 0.8, \cutoff, 1000);

        4.do { |i|
            Ndef(\mangroveVoid).xset(\cutoff, 1000 - (i * 200));
            1.7.wait;
        };

        "0:26.0 - [Cue 6: Aquatic Refraction]".postln;
        Pbindef(\dripRhythm,
            \instrument, \waterResonator,
            \out, ~synthBus,
            \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf),
            \freq, Pseq([1200, 1800, 900, 2400], inf),
            \amp, 0.5,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        7.do { 0.5.wait; };

        "0:29.5 - [Cue 7: The Prehistoric Seed]".postln;
        Ndef(\mangroveVoid).fadeTime = 4;
        Ndef(\mangroveVoid).set(\amp, 0);
        Ndef(\prehistoricDrift).fadeTime = 2;
        Ndef(\prehistoricDrift).set(\amp, 1);

        10.do { |i|
            Ndef(\prehistoricDrift).xset(\detune, i * 2.5);
            1.05.wait;
        };

        "0:40.0 - [Cue 8: Avian Glitch]".postln;
        Ndef(\prehistoricDrift).set(\amp, 0);
        Pbindef(\glitchSeq,
            \instrument, \digitalFracture,
            \out, ~synthBus,
            \dur, 0.0625,
            \freq, Pexprand(50, 500, inf),
            \decimateRate, Pwhite(500, 8000, inf),
            \amp, 0.7
        ).play;

        4.do { 0.525.wait; };

        "0:42.1 - [Cue 9: Conspecific Mirror]".postln;
        Pbindef(\glitchSeq).stop;
        Ndef(\binauralSplitter).set(\amp, 1);

        Pbindef(\agileCalls1,
            \instrument, \maroonFmPluck,
            \out, ~splitBus,
            \dur, 0.125,
            \freq, Pseq([3000, 4500, 3200], inf),
            \modIndex, 3,
            \amp, 0.6
        ).play;

        Pbindef(\agileCalls2,
            \instrument, \maroonFmPluck,
            \out, ~splitBus,
            \dur, 0.125,
            \freq, Pseq([3200, 4800, 3500], inf) * 1.05,
            \modIndex, 4,
            \amp, 0.6
        ).play;

        5.do { 1.18.wait; };

        "0:48.0 - [Cue 10: Taveuni Winds]".postln;
        Pbindef(\agileCalls1).stop;
        Pbindef(\agileCalls2).stop;
        Ndef(\binauralSplitter).set(\amp, 0);
        Ndef(\taveuniWinds).fadeTime = 0.5;
        Ndef(\taveuniWinds).set(\amp, 1);

        9.do { 0.5.wait; };

        "0:52.5 - [Cue 11: Sudden Void]".postln;
        Ndef(\taveuniWinds).set(\amp, 0);
        Ndef(\masterMix).set(\wet10, 1.0);

        1.5.wait;

        "0:54.0 - [Cue 12: Canopy Ascend]".postln;
        Ndef(\masterMix).set(\wet10, 0.2);
        Ndef(\canopyAscension).set(\amp, 1, \ascentRate, 0.05);

        Pbindef(\agileCalls, \out, ~synthBus, \dur, Pwrand([0.125, 0.5, 1.0], [0.2, 0.5, 0.3], inf)).play;

        12.do { |i|
            Ndef(\canopyAscension).xset(\ascentRate, 0.05 + (i * 0.08));
            1.wait;
        };

        "1:06.0 - [Cue 13: The Crimson Burst]".postln;
        Ndef(\canopyAscension).set(\amp, 0);
        Pbindef(\agileCalls, \dur, 0.03125, \modIndex, 15, \freq, Pexprand(4000, 8000));

        4.do { 1.wait; };

        "1:10.0 - [Cue 14: Island Drift]".postln;
        Pbindef(\agileCalls).stop;
        Ndef(\mangroveVoid).set(\freq, 40 * 8, \cutoff, 4000);
        Ndef(\mangroveVoid).fadeTime = 3;
        Ndef(\mangroveVoid).set(\amp, 0.6);

        9.do { 1.05.wait; };
        0.05.wait;

        "1:19.5 - [Cue 15: Micro-Fracture]".postln;
        Synth(\digitalFracture, [\out, ~synthBus, \freq, 50, \decimateRate, 200, \amp, 1.0]);

        1.5.wait;

        "1:21.0 - [Cue 16: Southern Tonga Memory]".postln;
        Ndef(\mangroveVoid).set(\amp, 0);
        Ndef(\photonGrain).set(\freq, 200, \grainDensity, 15, \amp, 1);
        Ndef(\masterMix).set(\wet20, 1.0, \stretch, 0.5);

        12.do { |i|
            Ndef(\masterMix).xset(\smear, i * 1.5);
            1.wait;
        };

        "1:33.0 - [Cue 17: Rhythmic Overgrowth]".postln;
        Ndef(\masterMix).set(\wet20, 0);
        Ndef(\photonGrain).set(\amp, 0);

        Pbindef(\polyRhythm,
            \instrument, \woodPerc,
            \out, ~synthBus,
            \dur, Pseq([0.125, 0.125, 0.25, 0.0625, 0.0625, 0.375], inf),
            \freq, Pseq([300, 450, 200, 600, 800, 150], inf),
            \fmAmount, Pwhite(50, 300, inf),
            \amp, 0.8,
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;

        7.do { 1.wait; };

        "1:40.0 - [Cue 18: Symmetrical Flap]".postln;
        Pbindef(\polyRhythm).stop;
        Ndef(\wingFlapLF).set(\amp, 1, \flapHz, 1);

        4.do { |i|
            Ndef(\wingFlapLF).xset(\flapHz, 1 + (i * 1.25));
            1.05.wait;
        };

        "1:44.2 - [Cue 19: Dense Rainforest Matrix]".postln;
        Ndef(\photonGrain).set(\amp, 1, \freq, 800, \grainDensity, 40);
        Pbindef(\agileCalls, \dur, Pwrand([0.0625, 0.125], [0.7, 0.3], inf), \modIndex, 3).play;

        20.do {
            if(0.2.coin) { Ndef(\photonGrain).set(\amp, 0) } { Ndef(\photonGrain).set(\amp, 1) };
            if(0.3.coin) { Synth(\branchSnap, [\out, ~synthBus, \freq, rrand(150, 400), \tension, 0.01, \amp, 0.8]) };
            1.04.wait;
        };
        Ndef(\photonGrain).set(\amp, 1);

        "2:05.0 - [Cue 20: Extinction Event]".postln;
        Ndef(\masterMix).set(\wet20, 1.0, \stretch, 0.2, \smear, 15);

        Ndef.clear(25);
        Pbindef(\agileCalls, \dur, Pgeom(0.125, 1.1, 25));

        25.do { |i|
            Ndef(\masterMix).xset(\stretch, 0.2 - (i * 0.007).max(0.01));
            1.wait;
        };

        Pbindef.removeAll;
        Tdef.removeAll;
        "2:30.0 - Score Complete. Absolute Silence.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-paodequeijo.scd
(
s.waitForBoot({

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    s.sync;

    // =====================================================================
    // 1. BUSES & ROUTING
    // =====================================================================
    ~dryBus = Bus.audio(s, 2);
    ~rhythmBus = Bus.audio(s, 2);

    // =====================================================================
    // 2. SYNTHDEFS (Discrete Events)
    // =====================================================================
    SynthDef(\salCrack, { |out=0, freq=8000, decay=0.05, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.3) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\mixThud, { |out=0, freq=100, rq=0.2, decayTime=0.2, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.01, decayTime), t_trig, doneAction: 2);
        var sig = RLPF.ar(Pulse.ar(freq) + WhiteNoise.ar(0.5), freq * 1.5, rq);
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\eggPluck, { |out=0, freq=400, modIndex=2, decay=0.3, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var mod = SinOsc.ar(freq * 2.01) * modIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\rollingTap, { |out=0, freq=1200, decay=0.02, amp=0.1, pan=0, t_trig=1|
        var env = EnvGen.ar(Env.perc(0.001, decay), t_trig, doneAction: 2);
        var sig = BPF.ar(WhiteNoise.ar, freq, 0.1) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    s.sync;

    // =====================================================================
    // 3. NDEFS & EFFECTS ARCHITECTURE
    // =====================================================================

    // -- Sound Sources --
    Ndef(\polvilhoAmbience, { |t_trig=1|
        var density = \density.kr(0.2);
        var hpFreq = \hpFreq.kr(6000);
        var lpFreq = \lpFreq.kr(20000);
        var rq = \rq.kr(0.9);
        var grainSize = \grainSize.kr(0.05);
        var gain = \gain.kr(0);

        var trig = Dust.ar(density * 200);
        var env = Decay2.ar(trig, 0.001, grainSize);
        var sig = WhiteNoise.ar * env;

        sig = RLPF.ar(sig, lpFreq.clip(20, 20000), rq.clip(0.01, 1.0));
        sig = HPF.ar(sig, hpFreq.clip(20, 20000));
        sig * gain ! 2;
    });

    Ndef(\leiteOleoDrone, { |t_trig=1|
        var freq1 = \freq1.kr(100);
        var freq2 = \freq2.kr(102);
        var fmIndex = \fmIndex.kr(0);
        var modFreq = \modFreq.kr(200);
        var gain = \gain.kr(0);

        var mod = SinOsc.ar(modFreq) * fmIndex * modFreq;
        var sig = SinOsc.ar([freq1 + mod, freq2 + mod]);
        sig * gain;
    });

    Ndef(\queijoTexture, { |t_trig=1|
        var foldAmount = \foldAmount.kr(0);
        var filtFreq = \filtFreq.kr(1500);
        var filtRQ = \filtRQ.kr(0.7);
        var gain = \gain.kr(0);
        var baseFreq = \freq.kr([150, 150, 150]); // Array for chords

        var mod = LPF.ar(WhiteNoise.ar, 500) * 100 * foldAmount;
        var sig = SinOsc.ar(baseFreq + mod);

        sig = Fold.ar(sig * 0.7 * (1 + foldAmount), -0.8, 0.8);
        sig = RLPF.ar(sig, filtFreq.clip(20, 20000), filtRQ.clip(0.01, 1.0));
        sig = Splay.ar(sig, spread: 0.8) * gain;
        sig;
    });

    // Fix: Removed unexpected standalone ( ) around this Ndef
    Ndef(\fornoHum, { |t_trig=1|
        var freq = \freq.kr(60);
        var crackDensity = \crackDensity.kr(0.5);
        var crackAmp = \crackAmp.kr(0.05);
        var hpFreq = \hpFreq.kr(200);
        var gain = \gain.kr(0);

        var drone = SinOsc.ar([freq, freq * 1.01]) + LFTri.ar([freq * 0.5, freq * 0.505]);
        var crackle = Dust2.ar(crackDensity ! 2) * crackAmp;
        var sig; // All var declarations must be at the top of the function

        crackle = RLPF.ar(crackle, 4000, 0.2);

        sig = (drone * 0.4) + crackle;
        sig = HPF.ar(sig, hpFreq.clip(20, 20000));
        sig * gain;
    });

    // -- Routing & Effects --
    Ndef(\delayTexture, { In.ar(~rhythmBus, 2) });
    Ndef(\delayTexture)[10] = \filter -> { |in|
        var del = DelayN.ar(in, 1.0, \delayTime.kr(0.3));
        in + (del * \feedback.kr(0.4));
    };
    Ndef(\delayTexture).set(\wet10, 0); // Initialized to 0

    Ndef(\master, {
        var sig = Ndef.ar(\polvilhoAmbience) +
                  Ndef.ar(\leiteOleoDrone) +
                  Ndef.ar(\queijoTexture) +
                  Ndef.ar(\fornoHum) +
                  Ndef.ar(\delayTexture) +
                  In.ar(~dryBus, 2);
        sig;
    });

    Ndef(\master)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.1);
    };
    Ndef(\master).set(\wet10, 0.1); // Master Reverb Wet/Dry

    Ndef(\master).play;

    s.sync;

    // =====================================================================
    // 4. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {

        "0:00 - [Movement I: Ingredientes Secos e Líquidos]".postln;
        Ndef(\polvilhoAmbience).set(\grainSize, 0.05, \density, 0.2, \hpFreq, 6000, \lpFreq, 20000, \rq, 0.9);
        Ndef(\polvilhoAmbience).fadeTime = 10;
        Ndef(\polvilhoAmbience).xset(\gain, -18.dbamp);

        Ndef(\leiteOleoDrone).fadeTime = 20;
        Ndef(\leiteOleoDrone).xset(\gain, -20.dbamp);

        25.wait;

        "0:25 - [Aquecendo]".postln;
        Ndef(\leiteOleoDrone).fadeTime = 20;
        Ndef(\leiteOleoDrone).xset(\fmIndex, 0.5, \modFreq, 200);

        Ndef(\polvilhoAmbience).fadeTime = 20;
        Ndef(\polvilhoAmbience).xset(\density, 0.4);

        20.wait;

        "0:45 - [Movement II: O Escaldo e a Mistura]".postln;
        Pbindef(\saltShot,
            \instrument, \salCrack,
            \freq, 8000,
            \decay, 0.05,
            \amp, -10.dbamp,
            \dur, Pseq([0.5, 0.5], 1),
            \out, ~dryBus
        ).play;

        Ndef(\polvilhoAmbience).fadeTime = 2;
        Ndef(\polvilhoAmbience).xset(\hpFreq, 800, \rq, 0.5, \lpFreq, 4000);
        Ndef(\leiteOleoDrone).set(\fmIndex, 0.8);

        15.wait;

        "1:00 - [Amassando o Polvilho]".postln;
        Ndef(\mixAmp, { Line.kr(-15.dbamp, -10.dbamp, 30) });
        Pbindef(\mixRhythm,
            \instrument, \mixThud,
            \freq, Pwhite(80, 120),
            \rq, 0.2,
            \decayTime, 0.2,
            \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.3, 0.2], inf),
            \amp, Ndef(\mixAmp),
            \out, ~dryBus
        ).play;

        Ndef(\polvilhoAmbience).fadeTime = 30;
        Ndef(\polvilhoAmbience).xset(\grainSize, 0.1, \density, 0.6, \hpFreq, 200, \lpFreq, 2000);

        45.wait;

        "1:45 - [Movement III: A Incorporação e a Riqueza]".postln;
        Pbindef(\eggSequence,
            \instrument, \eggPluck,
            \freq, Pseq([60, 62, 65, 67, 72, 69, 65, 79].midicps, 1),
            \modIndex, Pseq([2, 2.5, 3, 3.5, 4, 3, 2.5, 2], 1),
            \decay, 0.3,
            \amp, -12.dbamp,
            \dur, 1.25,
            \out, ~rhythmBus
        ).play;

        Pbindef(\mixRhythm, \dur, Pwrand([0.125, 0.25, 0.5], [0.4, 0.4, 0.2], inf));
        // Fix: Removed doneAction: 2 from Ndef to prevent premature node freeing
        Ndef(\mixAmp, { Line.kr(-10.dbamp, 0, 15) }); // Fade out mixRhythm

        Ndef(\polvilhoAmbience).fadeTime = 5;
        Ndef(\polvilhoAmbience).xset(\gain, -22.dbamp);

        25.wait;

        "2:10 - [O Queijo e a Homogeneidade]".postln;
        Pbindef(\mixRhythm).stop; // Ensure clean stop

        Ndef(\queijoTexture).set(\foldAmount, 4, \filtFreq, 1500, \filtRQ, 0.7);
        Ndef(\queijoTexture).fadeTime = 15;
        Ndef(\queijoTexture).xset(\gain, -10.dbamp);

        Ndef(\leiteOleoDrone).fadeTime = 5;
        Ndef(\leiteOleoDrone).xset(\fmIndex, 0.2);

        Ndef(\polvilhoAmbience).fadeTime = 10;
        Ndef(\polvilhoAmbience).xset(\gain, -28.dbamp);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0.25);

        35.wait;

        "2:45 - [Movement IV: Modelando e o Forno]".postln;
        Ndef(\rollAmp, { -18.dbamp });
        Pbindef(\rollRhythm,
            \instrument, \rollingTap,
            \freq, Pwhite(1000, 1500),
            \decay, 0.02,
            \dur, Pseq([0.25, 0.25, 0.5], inf),
            \amp, Ndef(\rollAmp),
            \out, ~rhythmBus
        ).play;

        Ndef(\queijoTexture).fadeTime = 10;
        Ndef(\queijoTexture).xset(\foldAmount, 2, \filtFreq, 800);

        Ndef(\delayTexture).set(\delayTime, 0.3, \feedback, 0.4);
        Ndef(\delayTexture).fadeTime = 2;
        Ndef(\delayTexture).xset(\wet10, 0.6);

        30.wait;

        "3:15 - [Assando no Forno]".postln;
        // Fix: Removed doneAction: 2 from Ndef
        Ndef(\rollAmp, { Line.kr(-18.dbamp, 0, 5) });
        Ndef(\delayTexture).fadeTime = 5;
        Ndef(\delayTexture).xset(\wet10, 0);

        fork { 5.wait; Pbindef(\rollRhythm).stop; };

        Ndef(\fornoHum).set(\freq, 60, \crackDensity, 0.5, \crackAmp, 0.05, \hpFreq, 200);
        Ndef(\fornoHum).fadeTime = 15;
        Ndef(\fornoHum).xset(\gain, -12.dbamp);

        Ndef(\queijoTexture).fadeTime = 10;
        Ndef(\queijoTexture).xset(\gain, -25.dbamp);

        Ndef(\polvilhoAmbience).fadeTime = 5;
        Ndef(\polvilhoAmbience).xset(\gain, 0);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0.4);

        30.wait;

        "3:45 - [Movement V: A Revelação e o Silêncio]".postln;
        Pbindef.removeAll;

        Ndef(\fornoHum).fadeTime = 2;
        Ndef(\fornoHum).xset(\gain, -10.dbamp);
        fork { 2.wait; Ndef(\fornoHum).fadeTime = 13; Ndef(\fornoHum).xset(\gain, -20.dbamp); };

        Ndef(\leiteOleoDrone).fadeTime = 5;
        Ndef(\leiteOleoDrone).xset(\gain, -15.dbamp);

        Ndef(\queijoTexture).set(\foldAmount, 0, \filtFreq, 300, \filtRQ, 0.9, \freq, [150, 200, 250]);
        Ndef(\queijoTexture).fadeTime = 2;
        Ndef(\queijoTexture).xset(\gain, -15.dbamp);

        15.wait;

        "4:00 - [Aroma e Silêncio]".postln;
        Ndef(\leiteOleoDrone).fadeTime = 15;
        Ndef(\leiteOleoDrone).xset(\gain, 0);

        Ndef(\queijoTexture).fadeTime = 15;
        Ndef(\queijoTexture).xset(\gain, 0);

        Ndef(\fornoHum).fadeTime = 15;
        Ndef(\fornoHum).xset(\gain, 0);

        Ndef(\master).fadeTime = 15;
        Ndef(\master).xset(\wet10, 0);

        15.wait;

        "4:15 - [Terminating]".postln;
        Ndef.clear(5);
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    s.makeGui;

});
)

// Source: composition-paodequeijo2.scd
(
s.waitForBoot({
    var masterScore;

    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // =====================================================================
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // =====================================================================
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // =====================================================================
    // 1. INSTRUMENTS & SYNTHS
    // =====================================================================

    SynthDef(\scaldBurst, { |out=0, amp=1|
        var env, noise, sig;
        env = EnvGen.ar(Env.perc(0.001, 3.0, 1, -8), doneAction: 2);
        noise = WhiteNoise.ar();
        sig = Fold.ar(noise * 2, -0.5, 0.5) * env;
        sig = BPF.ar(sig, XLine.kr(8000, 400, 3.0), 0.5);
        Out.ar(out, Pan2.ar(sig * amp, 0));
    }).add;

    SynthDef(\cheesePluck, { |out=0, freq=440, amp=0.1, pan=0, t_trig=1|
        var env, mod, sig;
        env = EnvGen.ar(Env.perc(0.005, 0.3), t_trig, doneAction: 2);
        mod = SinOsc.ar(freq * 3.02) * 1.5 * freq * env;
        sig = SinOsc.ar(freq + mod) * env;
        sig = HPF.ar(sig, 800);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\oiledGlide, { |out=0, freq=880, amp=0.1, pan=0, gate=1, glideTime=0.5|
        var smoothFreq, env, sig;
        smoothFreq = VarLag.kr(freq, glideTime, warp: \sine);
        env = EnvGen.ar(Env.asr(0.1, 1, 1.5), gate, doneAction: 2);
        sig = SinOsc.ar(smoothFreq);
        Out.ar(out, Pan2.ar(sig * amp * env, pan));
    }).add;

    s.sync;

    // =====================================================================
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // =====================================================================

    Ndef(\polvilhoDust, { |grainDens=2, grainDur=0.01, freqMult=1, amp=0|
        var trigs, env, freqs, sig;
        trigs = Dust.ar(grainDens);
        env = Decay2.ar(trigs, 0.001, grainDur);
        freqs = TExpRand.ar(2000, 9000, trigs) * freqMult;
        sig = SinOsc.ar(freqs) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.8, 0.8, trigs));
    });

    Ndef(\boilingLiquids, { |bubbleFreq=5, chaosParam=0.1, amp=0|
        var trigs, env, pitchEnv, freqs, mod, sig;
        trigs = Dust.ar(bubbleFreq);
        env = EnvGen.ar(Env.perc(0.01, 0.1), trigs);
        pitchEnv = EnvGen.ar(Env([1, 2, 1], [0.01, 0.05], \exp), trigs);
        freqs = TExpRand.ar(100, 800, trigs) * pitchEnv;
        mod = SinOsc.ar(freqs * 1.414) * chaosParam * freqs;
        sig = SinOsc.ar(freqs + mod) * env;
        Pan2.ar(sig * amp, TRand.ar(-0.5, 0.5, trigs));
    });

    Ndef(\doughDrone, { |cutoff=400, viscosity=0.1, amp=0|
        var freq, mod, sig;
        freq = 55;
        mod = SinOsc.ar(freq * 2.01) * viscosity * freq;
        sig = SinOsc.ar([freq, freq * 1.01] + mod);
        sig = LPF.ar(sig, cutoff);
        sig * amp;
    });

    Ndef(\ovenHeat, { |amp=0, spread=0.1, brightness=0.1|
        var root, ratios, freqs, sig;
        root = 110;
        ratios = [1, 5/4, 3/2, 15/8, 9/8 * 2, 11/8 * 2];
        freqs = root * ratios;
        sig = freqs.collect { |f, i|
            var detune = SinOsc.kr(0.1 + (i*0.03)).range(0.998, 1.002);
            SinOsc.ar(f * detune) * (1 / (i + 1)**(1-brightness));
        };
        sig = Splay.ar(sig, spread);
        sig = BPeakEQ.ar(sig, 400, 1.0, brightness * -12);
        sig * amp;
    });

    Ndef(\masterMix, {
        var synths, sig;
        synths = In.ar(~synthBus, 2);
        sig = Ndef.ar(\polvilhoDust, 2) +
              Ndef.ar(\boilingLiquids, 2) +
              Ndef.ar(\doughDrone, 2) +
              Ndef.ar(\ovenHeat, 2) +
              synths;
        sig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        var revTime, damp;
        revTime = \revTime.kr(0.2);
        damp = \damp.kr(0.5);
        FreeVerb2.ar(in[0], in[1], mix: 1, room: revTime, damp: damp);
    };
    Ndef(\masterMix).set(\wet10, 0.2);

    Ndef(\masterMix)[20] = \filter -> { |in|
        var drive;
        drive = \drive.kr(1.5);
        (in * drive).softclip;
    };
    Ndef(\masterMix).set(\wet20, 0);

    Ndef(\masterMix).play;

    s.sync;

    // =====================================================================
    // 3. THE SCRIPT (Tdef Score)
    // =====================================================================
    Tdef(\masterScore, {
        "0:00 - [Cue 1: The Dry Ingredients]".postln;
        Ndef(\polvilhoDust).fadeTime = 17;
        Ndef(\polvilhoDust).xset(\grainDens, 50, \amp, 0.6);

        17.wait;

        "0:17 - [Cue 2: Liquids in the Pan]".postln;
        Ndef(\boilingLiquids).fadeTime = 8;
        Ndef(\boilingLiquids).xset(\amp, 0.4);

        8.wait;

        "0:25 - [Cue 3: The Boil]".postln;
        Ndef(\boilingLiquids).fadeTime = 18;
        Ndef(\boilingLiquids).xset(\bubbleFreq, 40, \chaosParam, 2.0);

        18.wait;

        "0:43 - [Cue 4: The Scald (Escaldar)]".postln;
        Ndef(\boilingLiquids).set(\amp, 0);
        Synth(\scaldBurst, [\out, ~synthBus, \amp, 1.5]);

        3.wait;

        "0:46 - [Cue 5: Crumbling the Lumps (Desencaroçar)]".postln;
        Ndef(\polvilhoDust).fadeTime = 21;
        Ndef(\polvilhoDust).xset(\grainDur, 0.5, \freqMult, 0.3, \grainDens, 15);

        21.wait;

        "1:07 - [Cue 6: Kneading & Eggs]".postln;
        Ndef(\polvilhoDust).fadeTime = 5;
        Ndef(\polvilhoDust).xset(\amp, 0);

        Ndef(\doughDrone).fadeTime = 28;
        Ndef(\doughDrone).xset(\amp, 0.5, \cutoff, 1500, \viscosity, 1.5);

        28.wait;

        "1:35 - [Cue 7: The Canastra Cheese]".postln;
        Pbindef(\canastraSeq,
            \instrument, \cheesePluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \degree, Pseq([0, 2, 4, 6, 7, 4, 6, 2], inf) + Pwrand([0, 7, 14], [0.6, 0.3, 0.1], inf),
            \dur, Pexprand(0.1, 0.3, inf),
            \amp, 0.2,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        15.wait;

        "1:50 - [Cue 8: Oiled Hands (Enrolar)]".postln;
        Ndef(\doughDrone).fadeTime = 3;
        Ndef(\doughDrone).xset(\amp, 0);
        Pbindef(\canastraSeq).stop;

        Pbindef(\rollSeq,
            \instrument, \oiledGlide,
            \out, ~synthBus,
            \scale, Scale.major,
            \degree, Pseq([0, 4, 2, 5, 3, 7], inf),
            \octave, 6,
            \dur, 0.6,
            \glideTime, 0.6,
            \legato, 1.01,
            \amp, 0.15,
            \pan, Pseq([-0.5, 0.5, -0.3, 0.3], inf)
        ).play;

        15.wait;

        "2:05 - [Cue 9: The Oven (Baking & Expanding)]".postln;
        Pbindef(\rollSeq).stop;

        Ndef(\ovenHeat).fadeTime = 30;
        Ndef(\ovenHeat).xset(\amp, 0.6, \spread, 0.8, \brightness, 0.9);

        Ndef(\masterMix).fadeTime = 30;
        Ndef(\masterMix).xset(\wet20, 0.4, \revTime, 0.95);

        35.wait;

        "2:40 - [Cue 10: Golden Crust & Resolution]".postln;
        Ndef(\ovenHeat).fadeTime = 20;
        Ndef(\ovenHeat).xset(\amp, 0);
        Ndef(\masterMix).fadeTime = 20;
        Ndef(\masterMix).xset(\wet20, 0, \revTime, 0.2);

        18.wait;

        "2:58 - [Cue 11: Total Clearance]".postln;
        Pbindef.removeAll;
        Ndef.clear(2);

        2.wait;

        "3:00 - [End]".postln;
        Tdef.removeAll;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-paodequeijo3.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING & GROUPS
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------

    // Movement II: The Scald
    SynthDef(\scaldHiss, { |out=0, amp=1|
        var env = EnvGen.ar(Env.perc(0.01, 2.5, 1, -6), doneAction: 2);
        var sig = WhiteNoise.ar;
        sig = BPF.ar(sig, XLine.kr(9000, 1500, 2.5), 0.15);
        Out.ar(out, Pan2.ar(sig * env * amp * 8, 0));
    }).add;

    // Movement II: Dry physical modeling impulses
    SynthDef(\crumbleClick, { |out=0, freq=2000, decayTime=0.1, amp=0.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decayTime + 0.02), doneAction: 2);
        var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.005));
        var sig = Ringz.ar(exciter, freq, decayTime);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Movement III: Wave-folded subtractive bass
    SynthDef(\squelchBass, { |out=0, freq=55, foldAmount=2, amp=0.6|
        var env = EnvGen.ar(Env.perc(0.02, 0.4), doneAction: 2);
        var fEnv = EnvGen.ar(Env.perc(0.01, 0.25));
        var sig = SinOsc.ar(freq);
        sig = Fold.ar(sig * foldAmount, -0.5, 0.5);
        sig = RLPF.ar(sig, freq + (fEnv * 2000), 0.3);
        Out.ar(out, Pan2.ar(sig * env * amp, 0));
    }).add;

    // Movement V: Bright Lydian Plucks
    SynthDef(\ovenPluck, { |out=0, freq=440, cutoff=3000, pan=0, amp=0.3|
        var env = EnvGen.ar(Env.perc(0.01, 0.3), doneAction: 2);
        var sig = Pulse.ar(freq, 0.5) + Saw.ar(freq * 1.005);
        sig = RLPF.ar(sig, cutoff, 0.2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Movement I: The Boil
    Ndef(\boilGranular, { |grainDens=5, fmIndex=1, amp=0.6|
        var trigs = Dust.ar(grainDens);
        var carFreq = LFNoise1.kr(2).exprange(200, 600);
        var modFreq = carFreq * 1.414; // Tritone-ish modulation
        var sig = GrainFM.ar(2, trigs, 0.1, carFreq, modFreq, fmIndex, LFNoise1.kr(1));
        sig * amp;
    });

    // Movement III: Liquid splashes
    Ndef(\milkSplash, { |amp=0.4|
        var trigs = Dust.kr(0.8);
        var env = EnvGen.kr(Env.perc(0.005, 0.2), trigs);
        var freq = TRand.kr(1500, 4000, trigs);
        var mod = SinOsc.ar(freq * 2.5) * TRand.kr(1, 5, trigs) * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        Pan2.ar(sig * amp, TRand.kr(-0.6, 0.6, trigs));
    });

    // Movement IV: The Canastra Fold (PM Pad)
    Ndef(\canastraChords, { |amp=0.4, modIndex=1.5|
        var freqs = [261.63, 329.63, 392.00, 493.88]; // Cmaj7 Cluster
        var modFreqs = freqs * [1.059, 1.414, 1.059, 1.414]; // Min 2nd & Tritone ratios
        var sig = PMOsc.ar(freqs, modFreqs, SinOsc.kr(0.1).range(1, modIndex));
        sig = Splay.ar(sig);
        sig = LPF.ar(sig, 3000);
        sig * amp;
    });

    // Master Mixing & FX Chain
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\boilGranular, 2) + Ndef.ar(\milkSplash, 2) + Ndef.ar(\canastraChords, 2);
        synths + continuous;
    });

    Ndef(\heatReverb, { |revWet=0.1|
        var in = Ndef.ar(\masterMix, 2);
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.4);
        XFade2.ar(in, verb, revWet * 2 - 1);
    });

    Ndef(\masterGlue, {
        var in = Ndef.ar(\heatReverb, 2);
        // Compander acts as master bus glue
        var comp = Compander.ar(in, in, thresh: 0.4, slopeBelow: 1, slopeAbove: 0.3, clampTime: 0.01, relaxTime: 0.1);
        comp * 1.5;
    });

    Ndef(\masterGlue).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Boil (Anticipation & Heat)]".postln;
        Ndef(\boilGranular).fadeTime = 3;
        Ndef(\boilGranular).xset(\grainDens, 5, \fmIndex, 1);

        // ACTIVE WAIT: Sweeping density and FM index over 25 seconds
        25.do { |i|
            Ndef(\boilGranular).xset(
                \grainDens, 5 + (i * 4.6),
                \fmIndex, 1 + (i * 0.2)
            );
            1.wait;
        };

        "0:25 - [Cue 2: The Scald & Crumble (HARD CONTRAST)]".postln;
        // INSTANT SUBTRACTION
        Ndef(\boilGranular).stop;
        Ndef(\boilGranular).clear;

        // The Scald Impact
        Synth(\scaldHiss, [\out, ~synthBus, \amp, 1.2]);

        // The Crumble
        Pbindef(\crumbleSeq,
            \instrument, \crumbleClick,
            \out, ~synthBus,
            \dur, Pwhite(0.03125, 0.125, inf),
            \freq, Pexprand(1500, 9000, inf),
            \pan, Pwhite(-0.8, 0.8, inf),
            \decayTime, 0.1,
            \amp, 0.25
        ).play;

        // ACTIVE WAIT: Shrinking decay time to simulate lumps dissolving over 30 seconds
        30.do { |i|
            Pbindef(\crumbleSeq, \decayTime, 0.1 - (i * 0.0031));
            1.wait;
        };

        "0:55 - [Cue 3: The Knead (Viscous Rhythm)]".postln;
        Pbindef(\kneadBass,
            \instrument, \squelchBass,
            \out, ~synthBus,
            \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
            \midinote, Pseq([36, 36, 48, 36, 34], inf),
            \foldAmount, 2.0,
            \amp, 0.7
        ).play;

        // ACTIVE WAIT: Modulate dough stickiness (foldAmount) while milk splashes
        40.do {
            Pbindef(\kneadBass, \foldAmount, rrand(1.5, 4.5));
            1.wait;
        };

        "1:35 - [Cue 4: The Canastra Fold (Pungent Harmonics)]".postln;
        Ndef(\canastraChords).fadeTime = 8;
        Ndef(\canastraChords).xset(\amp, 0.5);
        Ndef(\heatReverb).xset(\revWet, 0.6); // Expanding the space

        // ACTIVE WAIT: Sweeping PM index for sharp flavor profile
        6.do {
            Ndef(\canastraChords).xset(\modIndex, rrand(1.5, 4.0));
            5.wait;
        };

        "2:05 - [Cue 5: The Oven (LATE-STAGE CLIMAX)]".postln;
        // SUBTRACTION & INJECTION
        Pbindef(\kneadBass).stop;
        Pbindef(\crumbleSeq).stop;

        Pbindef(\ovenArp,
            \instrument, \ovenPluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \degree, Pseq([0, 2, 4, 6, 7, 9, 11, 13], inf),
            \octave, Pseq([4, 5, 6, 7], inf),
            \dur, 0.125,
            \cutoff, 3000,
            \pan, 0,
            \amp, 0.4
        ).play;

        // ACTIVE WAIT: Frantic expansion over 35 seconds
        35.do {
            Pbindef(\ovenArp,
                \cutoff, rrand(2000, 8000),
                \pan, rrand(-0.8, 0.8)
            );
            1.wait;
        };

        "2:40 - [Cue 6: The Golden Crust (RESOLUTION & FADE)]".postln;
        Pbindef.removeAll; // Stop all rhythmic sequences immediately

        // 20-second fade out for all continuous textures and reverb
        Ndef(\canastraChords).clear(20);
        Ndef(\milkSplash).clear(20);
        Ndef(\heatReverb).clear(20);
        Ndef(\masterGlue).clear(20);

        20.wait;

        "3:00 - [Cue 7: Silence]".postln;
        Tdef.removeAll;
        "Piece concludes.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-plummage.scd
(
s.waitForBoot({
    // --------------------------------------------------------------------
    // PRE-SETUP: BUS & BUFFER ALLOCATION
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);

    // Allocate buffer for delicateWeave granular synthesis
    ~grainBuf = Buffer.alloc(s, s.sampleRate * 0.5, 1);
    s.sync;
    // Fill with a complex sine/fm burst for delicate textures
    ~grainBuf.loadCollection(Signal.sineFill(s.sampleRate * 0.5, [1, 0.5, 0.25, 0.125], [0, 0.5pi, pi, 1.5pi]).asArray);

    // Pre-allocate permanent global buffers for FFT to avoid LocalBuf JITLib race conditions
    ~fftBufL = Buffer.alloc(s, 2048);
    ~fftBufR = Buffer.alloc(s, 2048);
    ~fftModL = Buffer.alloc(s, 2048);
    ~fftModR = Buffer.alloc(s, 2048);
    ~fftDegBufL = Buffer.alloc(s, 2048);
    ~fftDegBufR = Buffer.alloc(s, 2048);

    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\featherPluck, { |out=0, freq=440, fmRatio=2.1, fmIndex=1.5, sustain=0.1, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, sustain, curve: -4), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        // High-pass to keep it delicate and percussive
        sig = HPF.ar(sig, 400);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\plumologyPing, { |out=0, freq=880, decay=4, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay, curve: -2), doneAction: 2);
        var sig = SinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------

    // Granular synthesis texture
    Ndef(\delicateWeave, { |density=10, rate=1, posSpeed=1, dur=0.1, amp=0|
        var trigs = Dust.ar(density);
        var pos = LFNoise2.kr(posSpeed).range(0.1, 0.9);
        var sig = TGrains.ar(2, trigs, ~grainBuf, rate, pos * BufDur.ir(~grainBuf), dur, TRand.kr(-0.8, 0.8, trigs), 0.5);
        sig = HPF.ar(sig, 1500) * amp;
        sig;
    });

    // Real-time spectral processing
    Ndef(\spectralPlume, { |modFreq=150, phaseShift=0, amp=0|
        var sig = PinkNoise.ar(1!2);
        var mod = SinOsc.ar(modFreq);
        var chainL = FFT(~fftBufL, sig[0]);
        var chainR = FFT(~fftBufR, sig[1]);
        var mChainL = FFT(~fftModL, mod);
        var mChainR = FFT(~fftModR, mod);

        chainL = PV_MagMul(chainL, mChainL);
        chainR = PV_MagMul(chainR, mChainR);
        chainL = PV_PhaseShift(chainL, phaseShift);
        chainR = PV_PhaseShift(chainR, phaseShift + 0.1);

        IFFT([chainL, chainR]) * amp;
    });

    // Slowly morphing drone
    Ndef(\moltDrone, { |fundFreq=40, formFreq=300, bwFreq=100, amp=0|
        var sig = Formant.ar(fundFreq + LFNoise2.kr(0.5, 2), formFreq, bwFreq);
        sig = LPF.ar(sig, formFreq * 2);
        Pan2.ar(sig * amp, 0);
    });

    // Dark, evolving pad
    Ndef(\eclipsePad, { |freq=60, cutoff=2000, modRate=0.5, rq=0.4, amp=0|
        var sig = Saw.ar([freq, freq*1.015]) + Pulse.ar([freq*0.5, freq*0.505], 0.5);
        var mod = LFPulse.kr(modRate).range(0.3, 1.0);
        sig = RLPF.ar(sig, cutoff * mod, rq);
        sig * amp;
    });

    // Smooth, sustained glissing texture
    Ndef(\flightEfficiency, { |baseFreq=200, decay=2, amp=0|
        var freqs = baseFreq * [1, 1.52, 2.33, 3.81];
        var amps = [1, 0.6, 0.3, 0.1];
        var rings = decay * [1, 0.8, 0.6, 0.4];
        var sig = DynKlank.ar(Ref([freqs, amps, rings]), PinkNoise.ar(0.005!2));
        sig * amp;
    });

    // Targeted FFT-based spectral degradation
    Ndef(\spectralDegrade, { |dMolt=0, dFlight=0, randComb=0.1, magDiv=1, amp=1|
        var in = (Ndef.ar(\moltDrone) * dMolt) + (Ndef.ar(\flightEfficiency) * dFlight);
        var chainL = FFT(~fftDegBufL, in[0]);
        var chainR = FFT(~fftDegBufR, in[1]);

        // Wipe a percentage of bins
        chainL = PV_RandComb(chainL, randComb, Impulse.kr(0.5));
        chainR = PV_RandComb(chainR, randComb, Impulse.kr(0.5));

        IFFT([chainL, chainR]) * amp;
    });

    // Master Mixer
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var continuous = Ndef.ar(\delicateWeave) +
                         Ndef.ar(\spectralPlume) +
                         Ndef.ar(\moltDrone) +
                         Ndef.ar(\eclipsePad) +
                         Ndef.ar(\flightEfficiency) +
                         Ndef.ar(\spectralDegrade);
        synths + continuous;
    });

    // Global Reverb via JITLib filter slot
    Ndef(\masterMix)[10] = \filter -> { |in|
        var verb = FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.85, damp: 0.3);
        verb;
    };
    Ndef(\masterMix).set(\wet10, 0.15); // Start with low reverb
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\plumageScore, {
        "0:00 - [Cue 1: Initial Glimmer]".postln;
        0.5.wait;
        Ndef(\delicateWeave).fadeTime = 0.8;
        Ndef(\delicateWeave).xset(\amp, 0.4, \density, 15, \rate, 1.5, \posSpeed, 2);

        "0:01.5 - [Cue 2: Emerging Patterns]".postln;
        1.wait;
        Pbindef(\intricateRhythm,
            \instrument, \featherPluck,
            \out, ~synthBus,
            \scale, Scale.lydian,
            \octave, Pwrand([6, 7], [0.7, 0.3], inf),
            \degree, Pseq([0, 2, 4, 7, 4, 2], inf),
            \dur, Pseq([0.125, 0.25, 0.125, 0.5], inf),
            \fmRatio, Pwhite(1.5, 3.5),
            \sustain, 0.05,
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5)
        ).play;

        "0:05.0 - [Cue 3: Overlapping Rows]".postln;
        3.5.wait;
        Ndef(\delicateWeave).xset(\rate, 0.2, \density, 30);
        Ndef(\spectralPlume).fadeTime = 3;
        Ndef(\spectralPlume).xset(\amp, 0.15, \modFreq, 200);

        "0:09.0 - [Cue 4: Color Morphs]".postln;
        4.wait;
        Pbindef(\intricateRhythm, \scale, Scale.diminished);
        // Active Wait: Random walk spectral parameters over 6s
        4.do {
            Ndef(\spectralPlume).xset(\modFreq, rrand(100, 600), \phaseShift, rrand(0.0, 3.14));
            1.5.wait;
        };

        "0:15.0 - [Cue 5: Organized Complexity]".postln;
        Pbindef(\intricateRhythm_2,
            \instrument, \featherPluck,
            \out, ~synthBus,
            \scale, Scale.diminished,
            \octave, 5,
            \degree, Pseq([0, -2, 3, 1], inf),
            \dur, 0.333,
            \fmRatio, 1.2,
            \sustain, 0.1,
            \amp, 0.12
        ).play;
        Ndef(\delicateWeave).xset(\density, 50);
        Ndef(\masterMix).xset(\wet10, 0.4);

        // Active wait for 8s
        4.do { Ndef(\delicateWeave).xset(\posSpeed, rrand(3.0, 8.0)); 2.wait; };

        "0:23.0 - [Cue 6: Transient Burst]".postln;
        Pbindef(\intricateRhythm, \amp, 0.4, \sustain, 0.3);
        1.wait;

        "0:24.0 - [Cue 7: Settling Arrangement]".postln;
        Pbindef(\intricateRhythm, \amp, 0.15, \sustain, 0.05);
        Ndef(\delicateWeave).xset(\density, 12, \rate, 0.5);

        // Active wait: 10s total, fading out rhythm_2
        5.do { |i|
            Pbindef(\intricateRhythm_2, \amp, 0.12 - (i * 0.024));
            2.wait;
        };
        Pbindef(\intricateRhythm_2).stop;

        "0:34.0 - [Cue 8: Species Variation]".postln;
        Pbindef(\intricateRhythm, \octave, 6, \degree, Pseq([1, 3, 5, 8], inf));
        Ndef(\spectralPlume).xset(\modFreq, 850);
        5.wait;

        "0:39.0 - [Cue 9: Age Class Shifts]".postln;
        Ndef(\eclipsePad).fadeTime = 5;
        Ndef(\eclipsePad).xset(\amp, 0.2, \cutoff, 4000, \modRate, 0.2);

        // Active wait: 7s
        3.do { Ndef(\eclipsePad).xset(\modRate, rrand(0.2, 0.8)); 2.33.wait; };

        "0:46.0 - [Cue 10: Underlying Structure]".postln;
        Ndef(\delicateWeave).xset(\density, 3, \rate, 0.05);
        Ndef(\spectralPlume).xset(\amp, 0.02);

        // Active wait: 12s
        6.do { |i|
            Ndef(\eclipsePad).xset(\cutoff, 4000 - (i*400));
            2.wait;
        };

        "0:58.0 - [Cue 11: Tracts Revealed]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\eclipsePad).set(\cutoff, 300); // HARD SET
        4.wait;

        "1:02.0 - [Cue 12: Preparing for Change]".postln;
        Ndef(\eclipsePad).xset(\amp, 0.4, \modRate, 1.5);
        // Active wait: 8s
        4.do { |i| Ndef(\eclipsePad).xset(\cutoff, 300 + (i*100)); 2.wait; };

        "1:10.0 - [Cue 13: First Tremor]".postln;
        Ndef(\moltDrone).fadeTime = 0.5;
        Ndef(\moltDrone).xset(\amp, 0.15, \fundFreq, 45, \formFreq, 150);
        2.5.wait;

        "1:12.5 - [Cue 14: Unfurling]".postln;
        Ndef(\eclipsePad).xset(\cutoff, 1800);
        // Active wait: 10s
        5.do { |i|
            Ndef(\moltDrone).xset(\formFreq, 200 + (i*150), \bwFreq, 100 + (i*80));
            2.wait;
        };

        "1:22.5 - [Cue 15: Breeding Plumage (SUBTRACTION)]".postln;
        Ndef(\eclipsePad).fadeTime = 2;
        Ndef(\eclipsePad).clear(2);
        Ndef(\moltDrone).xset(\amp, 0.4);

        Pbindef(\intricateRhythm,
            \scale, Scale.mixolydian,
            \dur, 0.125,
            \fmRatio, 4.5,
            \amp, 0.2
        ).play;
        8.wait;

        "1:30.5 - [Cue 16: Non-Breeding Contrast]".postln;
        Pbindef(\intricateRhythm).set(\fmRatio, 0.5); // HARD SET
        1.5.wait;

        "1:32.0 - [Cue 17: Partial Moult]".postln;
        Pbindef(\intricateRhythm, \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf));
        Ndef(\spectralDegrade).xset(\dMolt, 1, \amp, 1);

        // Active wait: 7s
        7.do { |i|
            Ndef(\spectralDegrade).xset(\randComb, 0.1 + (i*0.1));
            1.wait;
        };

        "1:39.0 - [Cue 18: Complete Moult (SUBTRACTION)]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\moltDrone).xset(\formFreq, 3000, \bwFreq, 2000);
        2.wait;
        Ndef(\moltDrone).clear(1);
        Ndef(\spectralDegrade).xset(\dMolt, 0);
        3.wait;

        "1:44.0 - [Cue 19: Brief Stillness]".postln;
        // Absolute silence except reverb
        1.wait;

        "1:45.0 - [Cue 20: Rejuvenation]".postln;
        Ndef(\delicateWeave).fadeTime = 5;
        Ndef(\delicateWeave).xset(\amp, 0.3, \density, 8, \rate, 1);
        6.wait;

        "1:51.0 - [Cue 21: New Growth]".postln;
        s.sync;
        Ndef(\spectralPlume).fadeTime = 6;
        Ndef(\spectralPlume).xset(\amp, 0.2, \modFreq, 1200, \phaseShift, 0);

        // Active wait: 8s
        4.do { |i|
            Ndef(\delicateWeave).xset(\posSpeed, 0.5 + i, \rate, 1 + (i*0.2));
            2.wait;
        };

        "1:59.0 - [Cue 22: Continuous Replacement]".postln;
        Ndef(\flightEfficiency).fadeTime = 4;
        Ndef(\flightEfficiency).xset(\amp, 0.35, \baseFreq, 150, \decay, 3);

        // Active wait: 12s
        6.do { |i|
            Ndef(\flightEfficiency).xset(\baseFreq, 150 + (i*15), \decay, 3 + (i*0.5));
            2.wait;
        };

        "2:11.0 - [Cue 23: Minimizing Loss]".postln;
        Ndef(\spectralPlume).xset(\amp, 0.3);
        Ndef(\delicateWeave).xset(\density, 20, \rate, 1.2, \posSpeed, 1);
        5.wait;

        "2:16.0 - [Cue 24: Wear of Tips]".postln;
        Ndef(\spectralDegrade).xset(\dFlight, 1, \randComb, 0.0);
        // Active wait: 7s
        7.do { |i|
            Ndef(\spectralDegrade).xset(\randComb, i * 0.12);
            1.wait;
        };

        "2:23.0 - [Cue 25: Juvenile Plumage (SUBTRACTION)]".postln;
        Ndef(\spectralDegrade).xset(\dFlight, 0);
        Ndef(\flightEfficiency).xset(\baseFreq, 400);
        7.wait;

        "2:33.0 - [Cue 26: First-Winter]".postln;
        Ndef(\flightEfficiency).xset(\baseFreq, 200, \decay, 1.5);
        Ndef(\masterMix).xset(\wet10, 0.6);
        10.wait;

        "2:41.0 - [Cue 27: Immature Succession]".postln;
        Pbindef(\intricateRhythm,
            \scale, Scale.minor,
            \octave, 4,
            \degree, Pwrand([0, 2, 4, 7], [0.4, 0.3, 0.2, 0.1], inf),
            \dur, Pwhite(2.0, 4.0),
            \sustain, 3.0,
            \fmRatio, 1.1,
            \amp, 0.25
        ).play;

        // Active wait: 15s
        5.do {
            Ndef(\flightEfficiency).xset(\baseFreq, rrand(180, 250));
            3.wait;
        };

        "2:56.0 - [Cue 28: Plumology's Dawn (SUBTRACTION)]".postln;
        Pbindef(\intricateRhythm).stop;
        Ndef(\flightEfficiency).clear(3);
        Ndef(\delicateWeave).xset(\density, 5, \rate, 0.5, \posSpeed, 0.1);
        7.wait;

        "3:03.0 - [Cue 29: Scientific Observation]".postln;
        Pbindef(\plumologySeq,
            \instrument, \plumologyPing,
            \out, ~synthBus,
            \scale, Scale.major,
            \octave, 6,
            \degree, Pseq([0, 4, 7, 11, 14], inf),
            \dur, Pwrand([1.5, 2.5, 3.0], [0.5, 0.3, 0.2], inf),
            \decay, 5,
            \amp, 0.3
        ).play;
        9.wait;

        "3:12.0 - [Cue 30: Unveiling Complexity]".postln;
        Ndef(\spectralPlume).xset(\amp, 0.4, \modFreq, 440, \phaseShift, 0);
        Pbindef(\plumologySeq,
            \degree, Pseq([[0, 4], [4, 7], [7, 11]], inf),
            \dur, 1.0
        );
        12.wait;

        "3:24.0 - [Cue 31: Synthesis of Knowledge (SUBTRACTION)]".postln;
        Ndef(\delicateWeave).clear(4);
        Ndef(\spectralPlume).xset(\modFreq, 880);
        Pbindef(\plumologySeq,
            \degree, [0, 4, 7, 11],
            \dur, 8.0,
            \decay, 8
        );
        8.wait;

        "3:32.0 - [Cue 32: Final Clarity]".postln;
        Pbindef(\plumologySeq).stop;
        Ndef(\spectralPlume).xset(\modFreq, 1760);
        6.wait;

        "3:38.0 - [Cue 33: Conclusion & Termination]".postln;
        Ndef(\spectralPlume).clear(10);

        2.wait; // 3:40.0
        Tdef.removeAll;

        1.wait; // 3:41.0
        Pbindef.removeAll;

        1.wait; // 3:42.0
        Ndef.clear(8);

        "Score Complete. Awaiting final silence.".postln;
    });

    Tdef(\plumageScore).play;
});

s.makeGui;
)

// Source: composition-rainforest.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    ~delayBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\waterDrip, { |out=0, freq=800, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, 0.15), doneAction: 2);
        var mod = SinOsc.ar(freq * 1.414) * 0.5 * freq * env;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\insectGranular, { |out=0, freq=8000, amp=0.1, pan=0, grainDur=0.05|
        var env = EnvGen.ar(Env.perc(0.001, grainDur), doneAction: 2);
        var sig = FSinOsc.ar(freq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\birdFM, { |out=0, freq=2000, modFreq=400, modIndex=2, amp=0.1, pan=0, dur=0.2|
        var env = EnvGen.ar(Env.perc(0.05, dur), doneAction: 2);
        var mod = SinOsc.ar(modFreq) * modIndex * freq;
        var sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\mammalGrowl, { |out=0, freq=80, rq=0.2, amp=0.1, pan=0, dur=0.5|
        var env = EnvGen.ar(Env.perc(0.1, dur), doneAction: 2);
        var sig = Saw.ar(freq) + BrownNoise.ar(0.5);
        sig = RLPF.ar(sig, XLine.kr(freq * 5, freq, dur), rq) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\speciesPing, { |out=0, freq=440, fmRatio=1, fmIndex=0, noiseMix=0, filterFreq=2000, decay=0.2, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var mod = SinOsc.ar(freq * fmRatio) * fmIndex * freq;
        var osc = SinOsc.ar(freq + mod);
        var noise = BPF.ar(WhiteNoise.ar, filterFreq, 0.2);
        var sig = XFade2.ar(osc, noise, noiseMix * 2 - 1) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\wetAmbience, { |lpf=800, amp=0|
        var noise = PinkNoise.ar(1);
        var sweeps = BPF.ar(noise, LFNoise2.kr(0.1).exprange(300, 2000), 0.5);
        var sig = LPF.ar(noise * 0.2 + sweeps, lpf);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\plantGrowth, { |freqMult=1, lpf=2000, amp=0|
        var trigs = Dust.kr(0.3) + Impulse.kr(0);
        var exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.01, 0.1), trigs);
        var freqs = [1, 1.5, 2.3, 3.8, 4.2] * 200 * freqMult;
        var amps = [1, 0.5, 0.3, 0.2, 0.1];
        var rings = [4, 3.5, 3, 2.5, 2];
        var sig = DynKlank.ar(`[freqs, amps, rings], exciter);
        sig = LPF.ar(sig, lpf);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\biodiversityDrone, { |spread=1, amp=0|
        var num = 12;
        var sig = num.collect { |i|
            var f = 100 * (i + 1) + LFNoise2.kr(0.1).range(-5, 5) * spread;
            SinOsc.ar(f) * LFNoise2.kr(0.2).exprange(0.01, 1) / num;
        }.sum;
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\riverFlow, { |filterFreq=100, amp=0|
        var sig = BrownNoise.ar();
        sig = RLPF.ar(sig, filterFreq, 0.3);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\delayNode, {
        In.ar(~delayBus, 2);
    });

    Ndef(\delayNode)[10] = \filter -> { |in|
        var dt = \delayTime.kr(0.3);
        CombC.ar(in, 1.0, dt, 3);
    };
    Ndef(\delayNode).set(\wet10, 1);

    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\wetAmbience, 2) + Ndef.ar(\plantGrowth, 2) + Ndef.ar(\biodiversityDrone, 2) + Ndef.ar(\riverFlow, 2);
        var delayed = Ndef.ar(\delayNode, 2);
        synths + cont + delayed;
    });

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], mix: 1, room: \reverbDecay.kr(0.9), damp: 0.2);
    };
    Ndef(\masterMix).set(\wet10, 0);

    Ndef(\masterMix).play;
    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: The Verdant Veil]".postln;
        Ndef(\wetAmbience).fadeTime = 5;
        Ndef(\wetAmbience).xset(\amp, 0.6, \lpf, 800);
        Ndef(\plantGrowth).fadeTime = 5;
        Ndef(\plantGrowth).xset(\amp, 0.4);
        Ndef(\masterMix).set(\wet10, 0.7, \reverbDecay, 0.9);

        // Active Wait: 55 seconds
        11.do { |i|
            var lpfTarg = if(i < 5, 400, 800);
            Ndef(\wetAmbience).xset(\lpf, lpfTarg);
            if(0.4.coin) {
                Synth(\waterDrip, [\out, ~synthBus, \freq, rrand(600, 1200), \pan, rrand(-0.5, 0.5), \amp, 0.1]);
            };
            5.wait;
        };

        "0:55 - [Cue 2: Unparalleled Richness]".postln;
        Ndef(\biodiversityDrone).fadeTime = 5;
        Ndef(\biodiversityDrone).xset(\amp, 0.3, \spread, 1.0);
        Ndef(\plantGrowth).xset(\freqMult, 0.8);
        Ndef(\wetAmbience).xset(\amp, 0.4);

        // Active Wait: 45 seconds
        9.do { |i|
            Ndef(\biodiversityDrone).xset(\spread, 1.0 + (i * 0.2));
            5.wait;
        };

        "1:40 - [Cue 3: Brief Pause & Shift]".postln;
        Ndef(\biodiversityDrone).fadeTime = 2;
        Ndef(\biodiversityDrone).xset(\amp, 0);
        Ndef(\plantGrowth).xset(\lpf, 100);
        Ndef(\masterMix).set(\wet10, 0.4);

        5.wait;

        "1:45 - [Cue 4: Million Insect Swarm]".postln;
        Pbindef(\swarmSeq,
            \instrument, \insectGranular,
            \out, ~synthBus,
            \dur, Pwhite(0.01, 0.05),
            \freq, Pexprand(6000, 12000),
            \grainDur, Pwhite(0.005, 0.02),
            \amp, Pexprand(0.02, 0.08),
            \pan, Pwhite(-0.8, 0.8)
        ).play;

        Ndef(\wetAmbience).xset(\lpf, 1200);
        Ndef(\masterMix).set(\wet10, 0.6, \reverbDecay, 0.7);

        // Active Wait: 40 seconds
        8.do { |i|
            Pbindef(\swarmSeq, \freq, Pexprand(6000 + (i*500), 12000 + (i*500)));
            5.wait;
        };

        "2:25 - [Cue 5: Tens of Thousands of Plants]".postln;
        Pbindef(\swarmSeq).stop;
        Ndef(\plantGrowth).xset(\lpf, 2000, \freqMult, 0.5);
        Ndef(\riverFlow).fadeTime = 5;
        Ndef(\riverFlow).xset(\amp, 0.5);

        // Active Wait: 35 seconds
        7.do { |i|
            var flowFreq = if(i < 3, 150, 50);
            Ndef(\riverFlow).xset(\filterFreq, flowFreq);
            5.wait;
        };

        "3:00 - [Cue 6: 2,000 Birds and Mammals]".postln;
        Pbindef(\birdSeq,
            \instrument, \birdFM,
            \out, ~delayBus,
            \dur, Pwrand([0.5, 1.5, 3.0], [0.5, 0.3, 0.2], inf),
            \freq, Pexprand(1000, 3000),
            \modFreq, Pexprand(200, 800),
            \modIndex, Pwhite(1.0, 5.0),
            \amp, 0.15,
            \pan, Pwhite(-0.6, 0.6)
        ).play;

        Pbindef(\mammalSeq,
            \instrument, \mammalGrowl,
            \out, ~synthBus,
            \dur, Pwrand([2.0, 4.0, 8.0], [0.6, 0.3, 0.1], inf),
            \freq, Pwhite(40, 120),
            \rq, Pwhite(0.1, 0.4),
            \amp, 0.25,
            \pan, Pwhite(-0.3, 0.3)
        ).play;

        Ndef(\riverFlow).xset(\amp, 0.6);

        // Active Wait: 45 seconds
        9.do { |i|
            Ndef(\delayNode).set(\delayTime, 0.2 + (i * 0.03));
            5.wait;
        };

        "3:45 - [Cue 7: Enumeration of Life]".postln;
        Pbindef(\speciesCountSeq,
            \instrument, \speciesPing,
            \out, ~synthBus,
            \dur, 0.5,
            \fmRatio, Pseq([1, 0.1, 3, 0, 0.5, 0], inf),
            \fmIndex, Pseq([0, 0, 5, 0, 2, 0], inf),
            \noiseMix, Pseq([0.1, 0, 0, 0, 0, 0.8], inf),
            \filterFreq, Pseq([2000, 1000, 5000, 200, 800, 4000], inf),
            \decay, Pseq([0.1, 0.3, 0.5, 0.2, 0.4, 0.05], inf),
            \freq, Pseq([600, 1500, 2500, 80, 300, 3000], inf) * Pwhite(0.9, 1.1),
            \amp, 0.15,
            \pan, Pwhite(-0.7, 0.7)
        ).play;

        // Active Wait: 45 seconds
        9.do { |i|
            Pbindef(\speciesCountSeq, \dur, 0.5 - (i * 0.03));
            5.wait;
        };

        "4:30 - [Cue 8: Invertebrate Surge & Climax]".postln;
        Pbindef(\swarmSeq).play;
        Ndef(\biodiversityDrone).fadeTime = 3;
        Ndef(\biodiversityDrone).xset(\amp, 0.5, \spread, 3.0);
        Ndef(\masterMix).set(\wet10, 0.8, \reverbDecay, 0.95);

        // Active Wait: 30 seconds
        6.do { |i|
            Pbindef(\speciesCountSeq, \dur, 0.1);
            Ndef(\biodiversityDrone).xset(\spread, 3 + i);
            5.wait;
        };

        "5:00 - [Cue 9: Final Dissolution]".postln;
        Pbindef.removeAll; // Hard stop all discrete events

        Ndef(\biodiversityDrone).fadeTime = 3;
        Ndef(\biodiversityDrone).xset(\amp, 0);

        Ndef(\wetAmbience).fadeTime = 15;
        Ndef(\wetAmbience).xset(\amp, 0);

        Ndef(\riverFlow).fadeTime = 15;
        Ndef(\riverFlow).xset(\amp, 0);

        Ndef(\plantGrowth).fadeTime = 15;
        Ndef(\plantGrowth).xset(\amp, 0);

        Ndef(\masterMix).set(\wet10, 0.9, \reverbDecay, 0.99);

        // Active Wait: 20 seconds
        4.do {
            5.wait;
        };

        "5:20 - TERMINATION".postln;
        Ndef.clear(5);
        5.wait;

        "Score Complete.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: composition-red-necked-grebe.scd
(
s.waitForBoot({
    var masterScore;

    // --------------------------------------------------------------------
    // PRE-SETUP: BUS ROUTING
    // --------------------------------------------------------------------
    ~synthBus = Bus.audio(s, 2);
    s.sync;

    // --------------------------------------------------------------------
    // 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
    // --------------------------------------------------------------------
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = Limiter.ar(sig, level: 0.85, dur: 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.removeAll;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };

    // --------------------------------------------------------------------
    // 1. INSTRUMENTS & SYNTHS (Node Safe)
    // --------------------------------------------------------------------
    SynthDef(\grebeCall, { |out=0, freq=800, decay=0.1, cutoff=2000, rq=0.2, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay), doneAction: 2);
        var fEnv = EnvGen.ar(Env.perc(0.01, decay * 1.5));
        var mod = SinOsc.ar(freq * 1.414) * freq * env * 0.5;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, (cutoff * fEnv).clip(20, 18000), rq);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    SynthDef(\rippleSplash, { |out=0, freq=1000, decay=0.2, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var sig = PinkNoise.ar * env;
        sig = BPF.ar(sig, freq, 0.3);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\insectBuzz, { |out=0, freq=6000, decay=0.02, density=15, amp=0.1, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        var sig = LFNoise0.ar(density * 100) * env;
        sig = HPF.ar(sig, freq);
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\chickChirp, { |out=0, freq=1800, decay=0.05, amp=0.2, pan=0|
        var env = EnvGen.ar(Env.perc(0.005, decay), doneAction: 2);
        var pEnv = EnvGen.ar(Env([1, 1.2, 1], [0.01, decay]));
        var sig = LFTri.ar(freq * pEnv) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    s.sync;

    // --------------------------------------------------------------------
    // 2. NDEFS & EFFECTS ARCHITECTURE
    // --------------------------------------------------------------------
    Ndef(\lakeSurface, { |grainRate=80, amp=0, rq=0.3|
        var rqLfo = SinOsc.kr(0.1).range(0.2, rq.max(0.2));
        var trigs = Dust.ar(grainRate);
        var sig = WhiteNoise.ar * EnvGen.ar(Env.perc(0.01, 0.05), trigs);
        sig = BPF.ar(sig, LFNoise2.kr(0.2).exprange(800, 3000), rqLfo);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\deepWaterResonance, { |freq=55, pmIndex=0.01, amp=0|
        var mod = SinOsc.ar(freq * 0.5) * pmIndex * 100;
        var sig = SinOsc.ar(freq + mod);
        sig = RLPF.ar(sig, freq * 4, 0.5);
        Pan2.ar(sig * amp, 0);
    });

    Ndef(\vegetationSway, { |lfoRate=0.2, cutoff=800, amp=0|
        var lfoAmp = SinOsc.kr(lfoRate).range(0.6, 1.0);
        var lfoCut = SinOsc.kr(lfoRate * 0.8).exprange(200, cutoff.max(201));
        var sig = Saw.ar([110, 111.5]) + Saw.ar([55, 55.2]);
        sig = LPF.ar(sig, lfoCut) * lfoAmp;
        sig * amp * 0.3;
    });

    Ndef(\communalHarmony, { |detuneAmount=0.005, amp=0|
        var freqs = [220, 275, 330, 440, 550];
        var lfos = { LFNoise2.kr(0.1).range(1 - detuneAmount, 1 + detuneAmount) } ! 5;
        var sig = Splay.ar(SinOsc.ar(freqs * lfos));
        sig * amp * 0.4;
    });

    // Master Mix & FX
    Ndef(\masterMix, {
        var synths = In.ar(~synthBus, 2);
        var cont = Ndef.ar(\lakeSurface, 2) +
                   Ndef.ar(\deepWaterResonance, 2) +
                   Ndef.ar(\vegetationSway, 2) +
                   Ndef.ar(\communalHarmony, 2);
        synths + cont;
    });

    // Delay FX
    Ndef(\masterMix)[10] = \filter -> { |in|
        // Fixed: JITLib automatically creates 'wet10' and handles crossfading.
        // Defining \wet10.kr manually causes a NamedControl default value conflict.
        CombL.ar(in, 0.5, 0.2, 1.5);
    };

    // Reverb FX
    Ndef(\masterMix)[11] = \filter -> { |in|
        // Fixed: JITLib automatically creates 'wet11' and handles crossfading.
        FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.8, damp: 0.4);
    };

    Ndef(\masterMix).set(\wet10, 0, \wet11, 0.4);
    Ndef(\masterMix).play;

    s.sync;

    // --------------------------------------------------------------------
    // 3. THE SCRIPT (Tdef Score)
    // --------------------------------------------------------------------
    Tdef(\masterScore, {

        "0:00 - [Cue 1: Dawn on the Lake]".postln;

        Ndef(\lakeSurface).fadeTime = 20;
        Ndef(\lakeSurface).xset(\amp, 0.4, \grainRate, 120, \rq, 0.4);

        Ndef(\deepWaterResonance).fadeTime = 15;
        Ndef(\deepWaterResonance).xset(\amp, 0.3);

        Pbindef(\rippleSeq,
            \instrument, \rippleSplash,
            \out, ~synthBus,
            \dur, Pwhite(1.5, 4.0, inf),
            \amp, Pseq([0.2, 0.5, 0.8], inf) * 0.3,
            \decay, Pseq([1, 2, 3], inf),
            \freq, Pexprand(600, 2000, inf),
            \pan, Prand([0.0, 0.5, -0.5], inf)
        ).play;

        // Active Wait: 25 seconds
        5.do {
            Ndef(\deepWaterResonance).xset(\pmIndex, rrand(0.01, 0.05));
            5.wait;
        };


        "0:25 - [Cue 2: Underwater Pursuit (HARD CONTRAST)]".postln;

        Ndef(\lakeSurface).fadeTime = 2;
        Ndef(\lakeSurface).xset(\amp, 0.1);
        Pbindef(\rippleSeq).stop;

        Ndef(\deepWaterResonance).fadeTime = 3;
        Ndef(\deepWaterResonance).xset(\amp, 0.6);
        Ndef(\masterMix).fadeTime = 3;
        Ndef(\masterMix).xset(\wet11, 0.2); // Drier reverb
        Ndef(\masterMix).xset(\wet10, 0.3); // Add subtle delay for pursuit

        Pbindef(\grebeMotif,
            \instrument, \grebeCall,
            \out, ~synthBus,
            \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf),
            \freq, Pseq([Pseries(800, -100, 3), Pseries(1200, -200, 4)], inf),
            \decay, 0.1,
            \cutoff, Pexprand(1500, 3000, inf),
            \rq, 0.2,
            \amp, 0.4,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;

        Pbindef(\insectDance,
            \instrument, \insectBuzz,
            \out, ~synthBus,
            \dur, Pwhite(0.1, 0.3, inf),
            \freq, Pwhite(4000, 8000, inf),
            \decay, Pseq([0.01, 0.02], inf),
            \density, Pseq([10, 20, 15], inf),
            \amp, 0.15,
            \pan, Pwhite(-0.8, 0.8, inf)
        ).play;

        // Active Wait: 25 seconds
        5.do { |i|
            if(i == 2, { Ndef(\deepWaterResonance).xset(\freq, 50) }); // Shift down
            if(i == 4, { Ndef(\deepWaterResonance).xset(\freq, 60) }); // Shift back
            Pbindef(\grebeMotif, \decay, rrand(0.05, 0.2));
            5.wait;
        };


        "0:50 - [Cue 3: Floating Sanctuary]".postln;

        Pbindef(\insectDance).stop;
        Pbindef(\grebeMotif, \dur, 2.0, \legato, 0.1, \amp, 0.2);

        Ndef(\deepWaterResonance).fadeTime = 5;
        Ndef(\deepWaterResonance).xset(\amp, 0.05);

        Ndef(\vegetationSway).fadeTime = 5;
        Ndef(\vegetationSway).xset(\amp, 0.4, \lfoRate, 0.1);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet11, 0.6); // Softer, expansive space

        Ndef(\lakeSurface).fadeTime = 5;
        Ndef(\lakeSurface).xset(\amp, 0.2, \grainRate, 60);

        Pbindef(\chicklet,
            \instrument, \chickChirp,
            \out, ~synthBus,
            \dur, Pwhite(0.5, 2.0, inf),
            \freq, Pwhite(1500, 2000, inf),
            \decay, 0.05,
            \amp, 0.2,
            \pan, Prand([0.1, 0.0, 0.2], inf)
        ).play;

        // Active Wait: 28 seconds
        7.do {
            Ndef(\vegetationSway).xset(\lfoRate, rrand(0.1, 0.3), \cutoff, rrand(600, 1200));
            4.wait;
        };


        "1:18 - [Cue 4: Communal Dance (LATE-STAGE KINETIC ENERGY)]".postln;

        Ndef(\vegetationSway).fadeTime = 5;
        Ndef(\vegetationSway).xset(\cutoff, 4000, \lfoRate, 0.4);

        Ndef(\communalHarmony).fadeTime = 15;
        Ndef(\communalHarmony).xset(\amp, 0.7);

        Ndef(\masterMix).fadeTime = 5;
        Ndef(\masterMix).xset(\wet11, 0.7); // Lush full sound

        Pbindef(\grebeMotif,
            \dur, Pseq([0.25, 0.5, 0.125], inf),
            \freq, Pwalk((400, 500 .. 1600), Pseq([1, 1, -1, 2, -1], inf), 1),
            \amp, 0.4
        );

        Pbindef(\rippleSeq,
            \dur, Pwhite(0.1, 0.4, inf),
            \decay, 0.05,
            \amp, 0.4,
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;

        Pbindef(\insectDance,
            \dur, Pwhite(0.05, 0.15, inf),
            \density, 50,
            \amp, 0.2
        ).play;

        Pbindef(\chicklet, \amp, 0.3);

        // Active Wait: 42 seconds
        7.do {
            Ndef(\communalHarmony).xset(\detuneAmount, rrand(0.005, 0.015));
            Pbindef(\rippleSeq, \freq, rrand(800, 3000));
            6.wait;
        };


        "2:00 - [Cue 5: Return to Stillness (TERMINATION)]".postln;

        // Instant subtraction of discrete events
        Pbindef(\grebeMotif).stop;
        Pbindef(\rippleSeq).stop;
        Pbindef(\insectDance).stop;
        Pbindef(\chicklet).stop;

        // Coordinated fade-outs
        Ndef(\communalHarmony).fadeTime = 20;
        Ndef(\communalHarmony).xset(\amp, 0.0);

        Ndef(\vegetationSway).fadeTime = 22;
        Ndef(\vegetationSway).xset(\amp, 0.0);

        Ndef(\lakeSurface).fadeTime = 25;
        Ndef(\lakeSurface).xset(\amp, 0.0);

        Ndef(\deepWaterResonance).fadeTime = 28;
        Ndef(\deepWaterResonance).xset(\amp, 0.0);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet11, 0.9); // Reverb blooms

        // Active Wait: 30 seconds
        6.do { |i|
            if(i == 3, {
                // At 15 seconds into the fade, start bringing down master volume
                Ndef(\masterMix).fadeTime = 15;
                Ndef(\masterMix).xset(\vol, 0.0);
            });
            5.wait;
        };

        "2:30 - Final Conclusion. Cleaning up.".postln;
        Pbindef.removeAll;
        Ndef.clear(2.0);
        Tdef.removeAll;
        "Score Complete. Server Silent.".postln;
    });

    Tdef(\masterScore).play;
});

s.makeGui;
)

// Source: flamenco.scd
(
Ndef class does not accept a global fadeTime

// Ndef(\golpe): Low-frequency, short-duration impulse (knuckle tap)
Ndef(\golpe).clear;
Ndef(\golpe, {
	|freq=180, rq=0.08, amp=0.4, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.005, 0.05), t_trig);
	// Use WhiteNoise with BPF for a more organic, woody tap sound
	sig = BPF.ar(WhiteNoise.ar(1), freq, rq);
	Pan2.ar(sig * env * amp, 0);
}).play;

// Ndef(\cajonKick): Deeper, slightly longer impulse (cajón bass)
Ndef(\cajonKick).clear;
Ndef(\cajonKick, {
	|freq=80, decayscale=1.0, amp=0.6, t_trig=1|
	var env, exciter, sig;
	env = EnvGen.ar(Env.perc(0.01, 0.15), t_trig);
	exciter = PinkNoise.ar * env;
	// DynKlank for a resonant body sound
	sig = DynKlank.ar(
		`[ // Changed from #[ to `[
			[1, 1.5, 2.1, 2.8] * freq, // Frequencies
			[1, 0.7, 0.4, 0.2],        // Amplitudes
			[0.15, 0.1, 0.08, 0.05]    // Ring times
		],
		exciter,
		decayscale: decayscale // Controls overall decay
	);
	sig = LPF.ar(sig, freq * 3); // Warm the kick
	Pan2.ar(sig * amp, Rand(-0.1, 0.1));
}).play;

// Ndef(\golpe) reverb
Ndef(\golpe)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.2, 0.2) };
Ndef(\golpe).set(\wet10, 0); // Initialize dry

Pbindef(\golpeSeq,
	\dur, 1/4,
	\amp, Pseq([0.6, 0.4, 0.6, 0.4], inf), // Accented pulse
	\t_trig, 1
);

Pbindef(\cajonKickSeq,
	\dur, 1/4,
	\legato, 0.7,
	\amp, Pseq([0.8, 0, 0.5, 0], inf), // Syncopated low-end
	\t_trig, 1
);

Ndef(\golpe).quant = 1;
Ndef(\cajonKick).quant = 1;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeq);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeq);

// Ndef(\cajonSnare): Sharper, mid-frequency click/thwack
Ndef(\cajonSnare).clear;
Ndef(\cajonSnare, {
	|freq=3000, rq=0.05, amp=0.3, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.08), t_trig);
	// BandPassFilter WhiteNoise for a sharp snare-like sound
	sig = BPF.ar(WhiteNoise.ar(1), freq, rq, 4);
	Pan2.ar(sig * env * amp, Rand(-0.3, 0.3));
}).play;

// Ndef(\palmas): Short, sharp, high-frequency claps
Ndef(\palmas).clear;
Ndef(\palmas, {
	|freq=8000, rq=0.01, amp=0.25, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.03), t_trig);
	// High-passed Crackle for a crisp clap texture
	sig = HPF.ar(Crackle.ar(1.9, 0.5), freq);
	Splay.ar(sig * env * amp); // Use Splay for wide stereo
}).play;

// Ndef(\rasgueado): Short, rich, percussive broadband sound for guitar strumming
Ndef(\rasgueado).clear;
Ndef(\rasgueado, {
	|freq=150, rq=0.1, amp=0.5, atk=0.01, rel=0.2, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	// Blip for rich harmonics, filtered for percussive strum
	sig = Blip.ar(freq, 20); // 20 harmonics
	sig = BPF.ar(sig, freq * 4, rq); // Shape it with a BPF
	Pan2.ar(sig * env * amp, Rand(-0.4, 0.4));
}).play;

// Ndef(\bass): Clean sine wave for a walking bassline
Ndef(\bass).clear;
Ndef(\bass, {
	|freq=60, amp=0.5, rel=0.7, filterFreq=200, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.01, rel), t_trig);
	sig = SinOsc.ar(freq);
	sig = LPF.ar(sig, filterFreq); // Keep it warm
	Pan2.ar(sig * env * amp, 0);
}).play;

// Ndef(\palmas) delay
Ndef(\palmas)[11] = \filter -> { |in| CombL.ar(in.sum, 0.2, 0.08, 0.3) }; // Short slapback
Ndef(\palmas).set(\wet11, 0);

// Ndef(\rasgueado) reverb
Ndef(\rasgueado)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.4, 0.3) };
Ndef(\rasgueado).set(\wet10, 0);

// Binary (4/4) rhythm
Pbindef(\cajonSnareSeq,
	\dur, 1/4,
	\amp, Pseq([0, 0.4, 0, 0.3], inf),
	\t_trig, 1
);

Pbindef(\palmasSeq,
	\dur, 1/4,
	\amp, Pseq([0.5, 0.7, 0.5, 0.7], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeq,
	\dur, 1/2,
	\amp, Pseq([0.6, 0.0, 0.4, 0.0], inf),
	\freq, Pseq([120, 150, 100, 130], inf),
	\t_trig, 1
);

Pbindef(\bassSeq,
	\dur, 1,
	\degree, Pseq([0, 2, 4, 5], inf) + 36, // Root, M2, M3, P4
	\amp, 0.4,
	\rel, 0.8,
	\t_trig, 1
);

Ndef(\cajonSnare).quant = 1;
Ndef(\palmas).quant = 1;
Ndef(\rasgueado).quant = 1;
Ndef(\bass).quant = 1;

Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeq);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeq);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeq);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeq);

// Ndef(\melodiaPluck): Karplus-Strong string model
Ndef(\melodiaPluck).clear;
Ndef(\melodiaPluck, {
	|freq=220, amp=0.7, bright=0.5, atk=0.005, rel=0.7, t_trig=1|
	var env, exciter, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	// Short noise burst for excitation
	exciter = WhiteNoise.ar(0.2) * EnvGen.ar(Env.perc(0.001, 0.005), t_trig);
	// Pluck UGen for string sound
	sig = Pluck.ar(exciter, t_trig, 0.5, 1/freq, 3, bright); // 0.5 is maxdelaytime, bright is coef
	Pan2.ar(sig * env * amp, Rand(-0.2, 0.2));
}).play;

// Ndef(\melodiaPluck) reverb and delay
Ndef(\melodiaPluck)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.4) };
Ndef(\melodiaPluck).set(\wet10, 0);

Ndef(\melodiaPluck)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 1.2) }; // Subtle, longer delay
Ndef(\melodiaPluck).set(\wet11, 0);

// 12-beat cycle for Soleá / Peteneras (accents on 12)
// ~soleaCycleDur will be dynamically set based on defaultQuant (1 beat = 1/4 dur in a 4/4 measure)
// So, if defaultQuant = 1, a 1/4 note gets 1 second. A 12-beat cycle should then be 12*1 second = 12 seconds.
// But compás is typically much faster. Let's make ~soleaCycleDur control the entire cycle duration.
// Let's assume t.tempo = 60/80 (0.75 beat duration) so a 12-beat cycle is 12 * 0.75 = 9 seconds
~soleaCycleDur = Pfunc { Pdef.defaultQuant.value * 12 * (60 / t.tempo) / 4 }; // 12 beats, scaled by actual tempo and then by 4/4 assumption. Simplified.

// Let's explicitly define a *base beat duration* for 12-beat cycles and use that as the fundamental `\dur` unit
~base12BeatUnit = Pfunc { Pdef.defaultQuant.value * (60 / t.tempo) * (1/4) }; // If t.tempo = 60 (1s/beat), this is 0.25s per 'unit'

Pbindef(\golpeSeqSolea,
	\dur, ~base12BeatUnit, // Each dur is 1/12th of the cycle duration
	\amp, Pseq([0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.7], inf), // Accent on 12
	\t_trig, 1
);

Pbindef(\cajonKickSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0.5, 0, 0, 0.4, 0, 0, 0.3, 0, 0, 0.5, 0, 0.8], inf),
	\t_trig, 1
);

Pbindef(\cajonSnareSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0, 0.2, 0, 0.2, 0, 0.3, 0, 0.2, 0.3, 0, 0, 0.4], inf),
	\t_trig, 1
);

Pbindef(\palmasSeqSolea,
	\dur, ~base12BeatUnit,
	\amp, Pseq([0.4, 0.6, 0.4, 0.6, 0.4, 0.7, 0.4, 0.6, 0.4, 0.6, 0.4, 0.8], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeqSolea,
	\dur, ~base12BeatUnit * Pseq(([2, 1, 2, 1, 2, 1, 2, 1].normalizeSum * 12), inf), // Longer strokes over the 12 beats
	\amp, Pseq([0.6, 0, 0.5, 0, 0.7, 0, 0.6, 0.0], inf),
	\freq, Pseq([130, 0, 100, 0, 150, 0, 120, 0], inf),
	\t_trig, Pseq([1, 0], inf) // Only trigger on downbeats for the longer strokes
);

Pbindef(\melodiaPluckSeq,
	\dur, ~base12BeatUnit * Pseq(([3, 1, 2, 2, 4].normalizeSum * 12), inf), // Slow, melancholic melody
	\degree, Pseq([0, -2, -4, -5, -7], inf) + 48, // C major scale in MIDI
	\amp, Pseq([0.7, 0.6, 0.7, 0.5, 0.8], inf),
	\rel, Pkey(\dur) * 0.8,
	\t_trig, 1
);

// 12-beat Bulerías cycle (accents on 3rd, 6th, 8th, 10th, 12th beats)
~baseBuleriasBeatUnit = Pfunc { Pdef.defaultQuant.value * (60 / t.tempo) * (1/4) }; // Faster overall unit

Pbindef(\golpeSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0.2, 0.2, 0.7, 0.2, 0.2, 0.7, 0.2, 0.7, 0.2, 0.7, 0.2, 0.8], inf),
	\t_trig, 1
);

Pbindef(\cajonKickSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0.5, 0, 0.8, 0, 0, 0.7, 0, 0.8, 0, 0.7, 0, 0.9], inf),
	\t_trig, 1
);

Pbindef(\cajonSnareSeqBulerias,
	\dur, ~baseBuleriasBeatUnit,
	\amp, Pseq([0, 0.3, 0.5, 0.2, 0.4, 0.6, 0.2, 0.5, 0.7, 0.3, 0.5, 0.8], inf),
	\t_trig, 1
);

Pbindef(\palmasSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq([2, 2, 2, 2, 2, 2], inf), // Palmas in groups of 6 beats (2 units each)
	\amp, Pseq([0.8, 0.7, 0.9, 0.7, 0.8, 1.0], inf),
	\t_trig, 1
);

Pbindef(\rasgueadoSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 0.5].normalizeSum * 12), inf), // Fast, intricate strumming
	\amp, Pseq([0.8, 0.6, 0.7, 0.9, 0.7, 0.8, 1.0, 0.8, 0.9], inf),
	\freq, Pseq([180, 200, 160, 220, 170, 190, 240, 180, 210], inf),
	\t_trig, 1
);

Pbindef(\melodiaPluckSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5].normalizeSum * 12), inf), // Faster, percussive melody
	\degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12], inf) + 60, // Higher and faster
	\amp, Pseq([0.8, 0.7, 0.6, 0.7, 0.9, 0.8, 0.7, 0.9], inf),
	\rel, Pkey(\dur) * 0.7,
	\t_trig, 1
);

// Ndef(\pads): Evolving, sustained chords with detuned sine waves
Ndef(\pads).clear;
Ndef(\pads, {
	|freq=110, amp=0.2, sus=5.0, detune=0.005, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [0.5, sus, 1.0], \sine), t_trig);
	// Mix of detuned sine waves for a lush pad
	sig = Mix.fill(4, { |i|
		var f = freq * (1 + (detune * (i-1.5)));
		// Replaced LFO with SinOsc.kr for the subtle pitch modulation
		SinOsc.ar(f + SinOsc.kr(0.1 + (i*0.02), 0, 2));
	});
	Splay.ar(sig * env * amp);
}).play;

// Ndef(\melodiaFree): Sustained, glissando-capable melodic voice (FM synthesis)
Ndef(\melodiaFree).clear;
Ndef(\melodiaFree, {
	|freq=220, amp=0.4, sus=4.0, modIndex=1.5, modFreq=200, sweepRate=0.05, t_trig=1|
	var env, mod, car, sweepLFO;
	env = EnvGen.ar(Env([0, 1, 1, 0], [1.0, sus, 2.0]), t_trig);
	sweepLFO = LFTri.ar(sweepRate).range(0.98, 1.02); // Slow pitch sweep
	mod = SinOsc.ar(modFreq * sweepLFO) * modIndex;
	car = SinOsc.ar(freq * sweepLFO + mod);
	Pan2.ar(car * env * amp, 0);
}).play;

// Ndef(\pads) reverb and delay
Ndef(\pads)[10] = \filter -> { |in| GVerb.ar(in.sum, 100, 8, 0.7, 0.8, 15, 0.5) }; // Lush GVerb
Ndef(\pads).set(\wet10, 0);

Ndef(\pads)[11] = \filter -> { |in| CombL.ar(in.sum, 1.5, 0.8, 5.0) }; // Long feedback delay
Ndef(\pads).set(\wet11, 0);

// Ndef(\melodiaFree) reverb and delay
Ndef(\melodiaFree)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.5) };
Ndef(\melodiaFree).set(\wet10, 0);

Ndef(\melodiaFree)[11] = \filter -> { |in| AllpassC.ar(in, 2.0, 1.0, 6.0) }; // Diffused long delay
Ndef(\melodiaFree).set(\wet11, 0);

// For ambient section, Pbindefs will be triggered manually or with very slow patterns.
Pbindef(\melodiaFreeSeq,
	\dur, 8, // Very long notes
	\freq, Pseq([110, 146.83, 98, 130.81], inf), // A2, D3, G2, C3
	\legato, 4, // Glissando between notes
	\amp, 0.6,
	\sus, Pkey(\dur) * 0.9,
	\t_trig, 1
);

Pbindef(\padsSeq,
	\dur, 16,
	\freq, Pseq([65.4, 82.4, 98, 130.8], inf), // C2, E2, G2, C3
	\amp, 0.3,
	\sus, 15,
	\t_trig, 1
);

// Define a master Ndef to apply global effects (e.g., low-pass filter).
// This Ndef will receive all audio from the main output bus (0 and 1) and process it.
Ndef(\masterMix).clear;
Ndef(\masterMix, {
	var in = In.ar(0, 2); // Receive audio from the main output bus
	var lpfCutoff = \lpfCutoff.kr(20000); // Global LPF cutoff frequency
	var lpfRes = \lpfRes.kr(0.1);
	var masterAmp = \amp.kr(1.0);
	in = RLPF.ar(in, lpfCutoff, lpfRes); // Apply global low-pass filter
	Out.ar(0, in * masterAmp); // Send processed audio back to the main output
}).play;

// Ensure all Ndefs are initially stopped and dry before setting up the first phase
Ndef(\golpe).stop; Ndef(\cajonKick).stop; Ndef(\cajonSnare).stop;
Ndef(\palmas).stop; Ndef(\rasgueado).stop; Ndef(\bass).stop;
Ndef(\melodiaPluck).stop; Ndef(\pads).stop; Ndef(\melodiaFree).stop;

// Clear patterns from any previous runs
Pbindef(\golpeSeq).stop; Pbindef(\cajonKickSeq).stop; Pbindef(\cajonSnareSeq).stop;
Pbindef(\palmasSeq).stop; Pbindef(\rasgueadoSeq).stop; Pbindef(\bassSeq).stop;
Pbindef(\golpeSeqSolea).stop; Pbindef(\cajonKickSeqSolea).stop; Pbindef(\cajonSnareSeqSolea).stop;
Pbindef(\palmasSeqSolea).stop; Pbindef(\rasgueadoSeqSolea).stop; Pbindef(\bassSeqSolea).stop;
Pbindef(\melodiaPluckSeq).stop; Pbindef(\golpeSeqBulerias).stop; Pbindef(\cajonKickSeqBulerias).stop;
Pbindef(\cajonSnareSeqBulerias).stop; Pbindef(\palmasSeqBulerias).stop; Pbindef(\rasgueadoSeqBulerias).stop;
Pbindef(\melodiaPluckSeqBulerias).stop; Pbindef(\bassSeqBulerias).stop; Pbindef(\padsSeq).stop;
Pbindef(\melodiaFreeSeq).stop; Pbindef(\golpeOutro).stop;

// Reset all wet levels to 0
Ndef(\golpe).set(\wet10, 0);
Ndef(\palmas).set(\wet11, 0); Ndef(\palmas).set(\wet10, 0); // Also adding reverb slot for later
Ndef(\rasgueado).set(\wet10, 0);
Ndef(\melodiaPluck).set(\wet10, 0, \wet11, 0);
Ndef(\pads).set(\wet10, 0, \wet11, 0);
Ndef(\melodiaFree).set(\wet10, 0, \wet11, 0);

// Bring in Phase I instruments and sequences
Ndef(\golpe).play;
Ndef(\cajonKick).play;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeq);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeq);

// Initial effect settings for Phase I
Ndef(\golpe).xset(\wet10, 0.2); // short, dry reverb
// Ndef(\golpe).xset(\wet10, 0); // Revert

// Set initial tempo
t.tempo = 60/80; // 80 BPM
// t.tempo = 60/60; // Revert

Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3); // Bring in cajon snare
// Ndef(\cajonSnare).xset(\amp, 0); // Revert
Ndef(\palmas).play; Ndef(\palmas).xset(\amp, 0.25); // Bring in palmas
// Ndef(\palmas).xset(\amp, 0); // Revert
Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.5); // Bring in rasgueado
// Ndef(\rasgueado).xset(\amp, 0); // Revert
Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.4); // Bring in bassline
// Ndef(\bass).xset(\amp, 0); // Revert

Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeq);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeq);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeq);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeq);

// Apply effects for Phase II
Ndef(\palmas).xset(\wet11, 0.1); // Add short delay to palmas
// Ndef(\palmas).xset(\wet11, 0); // Revert
Ndef(\rasgueado).xset(\wet10, 0.3); // Add short reverb to rasgueado
// Ndef(\rasgueado).xset(\wet10, 0); // Revert

// Stop current 4/4 patterns and switch to 12-beat soleá cycle patterns
Pbindef(\golpeSeq).stop; Pbindef(\cajonKickSeq).stop;
Pbindef(\cajonSnareSeq).stop; Pbindef(\palmasSeq).stop;
Pbindef(\rasgueadoSeq).stop; Pbindef(\bassSeq).stop;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqSolea);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqSolea);
Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqSolea);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqSolea);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqSolea);
// Define bassSeqSolea here for a richer bassline in 12-beat context
Pbindef(\bassSeqSolea,
	\dur, ~base12BeatUnit * Pseq(([3, 1, 2, 2, 4].normalizeSum * 12), inf),
	\degree, Pseq([0, -2, -4, -5, -7], inf) + 36,
	\amp, 0.45,
	\rel, Pkey(\dur) * 0.9,
	\t_trig, 1
);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeqSolea);

// Introduce melodic pluck
Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.7);
// Ndef(\melodiaPluck).xset(\amp, 0); // Revert
Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeq);

// Apply effects for Phase III
Ndef(\melodiaPluck).xset(\wet10, 0.5, \wet11, 0.3); // Medium decay reverb and subtle long delay
// Ndef(\melodiaPluck).xset(\wet10, 0, \wet11, 0); // Revert

// Slightly increase tempo
t.tempo = 60/70; // 70 BPM
// t.tempo = 60/80; // Revert

// Stop Soleá patterns and switch to Bulerías patterns
Pbindef(\golpeSeqSolea).stop; Pbindef(\cajonKickSeqSolea).stop;
Pbindef(\cajonSnareSeqSolea).stop; Pbindef(\palmasSeqSolea).stop;
Pbindef(\rasgueadoSeqSolea).stop; Pbindef(\bassSeqSolea).stop;
Pbindef(\melodiaPluckSeq).stop;

Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqBulerias);
Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias);
Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias);
Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqBulerias);
Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias);
Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias);

// Ndef(\bass) adapted for Bulerías
Pbindef(\bassSeqBulerias,
	\dur, ~baseBuleriasBeatUnit * Pseq(([1, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 0.5].normalizeSum * 12), inf),
	\degree, Pseq([0, 2, 4, 5, 7, 9, 11, 12], inf) + 36, // Adapted to faster rhythm
	\amp, 0.5,
	\rel, Pkey(\dur) * 0.7,
	\t_trig, 1
);
Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias);

// Increase rasgueado prominence and complexity
Ndef(\rasgueado).xset(\amp, 0.7);
// Ndef(\rasgueado).xset(\amp, 0.5); // Revert

// Apply effects for Phase IV
Ndef(\rasgueado).xset(\freq, 250, \rq, 0.08); // Sharper rasgueado, simulating hpFreq (no explicit hpFreq arg)
// Ndef(\rasgueado).xset(\freq, 150, \rq, 0.1); // Revert
Ndef(\palmas).xset(\wet11, 0.05); // Shorten delay time for tightness
// Ndef(\palmas).xset(\wet11, 0.1); // Revert

// Reduce reverb on most elements for a drier, more immediate sound
Ndef(\golpe).xset(\wet10, 0.1); // Less reverb
// Ndef(\golpe).xset(\wet10, 0.2); // Revert
Ndef(\rasgueado).xset(\wet10, 0.2); // Less reverb
// Ndef(\rasgueado).xset(\wet10, 0.3); // Revert
Ndef(\melodiaPluck).xset(\wet10, 0.3, \wet11, 0.1); // Less reverb and delay
// Ndef(\melodiaPluck).xset(\wet10, 0.5, \wet11, 0.3); // Revert

// Fastest tempo
t.tempo = 60/50; // 50 BPM (fastest)
// t.tempo = 60/70; // Revert

// Stop all rhythmic Pbindefs and fade out rhythmic Ndefs
Pbindef(\golpeSeqBulerias).stop; Pbindef(\cajonKickSeqBulerias).stop;
Pbindef(\cajonSnareSeqBulerias).stop; Pbindef(\palmasSeqBulerias).stop;
Pbindef(\rasgueadoSeqBulerias).stop; Pbindef(\bassSeqBulerias).stop;
Pbindef(\melodiaPluckSeqBulerias).stop;

// Clear Ndefs with fade time
Ndef(\golpe).clear(2); Ndef(\cajonKick).clear(2);
Ndef(\cajonSnare).clear(2); Ndef(\palmas).clear(2);
Ndef(\rasgueado).clear(2); Ndef(\bass).clear(2);
Ndef(\melodiaPluck).clear(2);

// Bring in pads and free melody
Ndef(\pads).play; Ndef(\pads).xset(\amp, 0.2); // Fade in pads
// Ndef(\pads).xset(\amp, 0); // Revert
Ndef(\melodiaFree).play; Ndef(\melodiaFree).xset(\amp, 0.4); // Fade in free melody
// Ndef(\melodiaFree).xset(\amp, 0); // Revert

Ndef(\pads)[1] = \set -> Pbindef(\padsSeq);
Ndef(\melodiaFree)[1] = \set -> Pbindef(\melodiaFreeSeq);

// Apply effects for Phase V
Ndef(\pads).xset(\wet10, 0.9, \wet11, 0.5); // Lush reverb and long delay for pads
// Ndef(\pads).xset(\wet10, 0, \wet11, 0); // Revert
Ndef(\melodiaFree).xset(\wet10, 0.8, \wet11, 0.6); // Long reverb and diffused delay for melody
// Ndef(\melodiaFree).xset(\wet10, 0, \wet11, 0); // Revert

// (No explicit tempo setting as it's free-form)

// Fade out ambient elements
Pbindef(\padsSeq).stop; Ndef(\pads).clear(2);
Pbindef(\melodiaFreeSeq).stop; Ndef(\melodiaFree).clear(2);

// Re-introduce rhythmic Ndefs, starting with kick and golpe
Ndef(\cajonKick).play; Ndef(\cajonKick).xset(\amp, 0.6); // Fade in
// Ndef(\cajonKick).xset(\amp, 0); // Revert
Ndef(\golpe).play; Ndef(\golpe).xset(\amp, 0.4); // Fade in
// Ndef(\golpe).xset(\amp, 0); // Revert

Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias); // Re-use Bulerías pattern
Ndef(\golpe)[1] = \set -> Pbindef(\golpeSeqBulerias);

// Gradually layer in palmas and snare
{
	Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3);
	Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias);
	Ndef(\palmas).play; Ndef(\palmas).xset(\amp, 0.25);
	Ndef(\palmas)[1] = \set -> Pbindef(\palmasSeqBulerias);
}.defer(4); // After 4 beats

// Rejoin rasgueado and melodic pluck
{
	Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.6);
	Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias);
	Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.75); // Slightly more prominent
	Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias);
	Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.5);
	Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias);
}.defer(8); // After 8 beats

// Tempo is brisk but controlled
t.tempo = 60/60; // 60 BPM (moderate brisk tempo)
// t.tempo = 60/50; // Revert to previous faster tempo

// Effects: Initially more reverb, then reduce
Ndef(\golpe).xset(\wet10, 0.3); // More reverb for softer re-entry
// Ndef(\golpe).xset(\wet10, 0.1); // Revert
Ndef(\rasgueado).xset(\wet10, 0.4); // More reverb
// Ndef(\rasgueado).xset(\wet10, 0.2); // Revert
Ndef(\melodiaPluck).xset(\wet10, 0.6, \wet11, 0.4); // More reverb/delay
// Ndef(\melodiaPluck).xset(\wet10, 0.3, \wet11, 0.1); // Revert

// Decelerate the rhythm
t.tempo = 60/80; // Slow down to 80 BPM
// t.tempo = 60/60; // Revert

// Sequentially stop Pbindefs and fade Ndefs
// Fade rasgueado first
Pbindef(\rasgueadoSeqBulerias).stop; Ndef(\rasgueado).clear(2);
// Ndef(\rasgueado).play; Ndef(\rasgueado).xset(\amp, 0.6); Ndef(\rasgueado)[1] = \set -> Pbindef(\rasgueadoSeqBulerias); // Revert

// Then bass and cajon snare
{ Pbindef(\bassSeqBulerias).stop; Ndef(\bass).clear(2); }.defer(4);
// { Ndef(\bass).play; Ndef(\bass).xset(\amp, 0.5); Ndef(\bass)[1] = \set -> Pbindef(\bassSeqBulerias); }.defer(4); // Revert
{ Pbindef(\cajonSnareSeqBulerias).stop; Ndef(\cajonSnare).clear(2); }.defer(4);
// { Ndef(\cajonSnare).play; Ndef(\cajonSnare).xset(\amp, 0.3); Ndef(\cajonSnare)[1] = \set -> Pbindef(\cajonSnareSeqBulerias); }.defer(4); // Revert

// Melodic pluck fades
{ Pbindef(\melodiaPluckSeqBulerias).stop; Ndef(\melodiaPluck).clear(3); }.defer(8);
// { Ndef(\melodiaPluck).play; Ndef(\melodiaPluck).xset(\amp, 0.75); Ndef(\melodiaPluck)[1] = \set -> Pbindef(\melodiaPluckSeqBulerias); }.defer(8); // Revert

// Increase global reverb for sense of vastness
Ndef(\golpe).xset(\wet10, 0.8);
// Ndef(\golpe).xset(\wet10, 0.3); // Revert
Ndef(\palmas).set(\wet10, 0); // Assign a reverb filter to palmas if not already
Ndef(\palmas)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.3) };
Ndef(\palmas).xset(\wet10, 0.7, \wet11, 0.3); // Introduce reverb + delay
// Ndef(\palmas).xset(\wet10, 0, \wet11, 0.05); // Revert

// End with sparse palmas and golpe, then a final accent from golpe.
// Gradually thin out palmas and kick
{ Pbindef(\cajonKickSeqBulerias).stop; Ndef(\cajonKick).clear(2); }.defer(12);
// { Ndef(\cajonKick).play; Ndef(\cajonKick).xset(\amp, 0.6); Ndef(\cajonKick)[1] = \set -> Pbindef(\cajonKickSeqBulerias); }.defer(12); // Revert

{
	Pbindef(\palmasSeqBulerias).stop; Ndef(\palmas).clear(2);
	Pbindef(\golpeSeqBulerias).stop; // Stop main patterns

	// A final sparse golpe pattern
	Pbindef(\golpeOutro, \dur, 1, \amp, Pseq([0.5, 0, 0.8, 0, 0.5, 0], inf), \t_trig, 1);
	Ndef(\golpe)[1] = \set -> Pbindef(\golpeOutro);
	Ndef(\golpe).xset(\freq, 100); // Deeper final taps
	// Ndef(\golpe).xset(\freq, 180); // Revert
}.defer(16);

// Final fade out for golpe and clear all
{
	Pbindef(\golpeOutro).stop;
	Ndef(\golpe).clear(5); // Long fade for the final taps
	Ndef(\masterMix).clear(5); // Fade out the global LPF
	Ndef.clear(6); // Clear all remaining Ndefs after masterMix fades
	t.tempo = 60/60; // Reset tempo to default
}.defer(24);
)

// Source: gemini-composition-hummingbird.scd
(
Strict Ndef Architecture

// Establish fade times for smooth .xset parameter sweeps
Ndef(\canopyPad).fadeTime = 4;
Ndef(\birdWings).fadeTime = 2;
Ndef(\serpentThreat).fadeTime = 3;
Ndef(\nectarNest).fadeTime = 4;

// Block 1 & 2: The Altitudinal Limit. Clean subtractive synthesis.
Ndef(\canopyPad, {
    |freq=130.81, freqMult=1, amp=0.25, t_trig=1, lpfFreq=2500, hpfFreq=150|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [4, 6, 4]), t_trig);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * 1.01]);
    var sub = SinOsc.ar([freq * freqMult * 0.5, freq * freqMult * 0.505]);
    sig = RLPF.ar(sig + sub, lpfFreq, 0.3);
    sig = HPF.ar(sig, hpfFreq);
    sig * env * amp;
});

// Block 3 & 4: The Bird. Pure sine FM pings for clean, distortion-free rapid fluttering.
Ndef(\birdWings, {
    |freq=880, freqMult=1, modFreq=1174.66, modIndex=1.2, amp=0.15, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.001, 0.04), t_trig);
    var mod = SinOsc.ar(modFreq) * modIndex * (freq * freqMult);
    var sig = SinOsc.ar((freq * freqMult) + mod);
    Pan2.ar(sig * env * amp, 0);
});

// Block 11: The Meteor Serpent. Filtered noise for an organic, prowling low-end threat.
Ndef(\serpentThreat, {
    |freq=45, freqMult=1, amp=0.4, t_trig=1, rq=0.08|
    var env = EnvGen.ar(Env.perc(0.5, 2.5), t_trig);
    var noise = PinkNoise.ar();
    var sig = BPF.ar(noise, freq * freqMult, rq);
    Pan2.ar(sig * env * amp, 0);
});

// Block 14 & 15: The Nest & Hatching. Physical modeling using DynKlank.
// strict adherence: specificationsArrayRef is a Ref to an array of 3 sub-arrays, uses decayscale.
Ndef(\nectarNest, {
    |freq=329.63, freqMult=1, amp=0.2, t_trig=1, decayscale=1|
    var env = EnvGen.ar(Env.perc(0.01, 0.15), t_trig);
    var exciter = WhiteNoise.ar() * env * 0.05;
    var specs = `[
        [1, 1.18, 1.41, 1.78], // relative frequencies
        [1, 0.5, 0.3, 0.1],    // amplitudes
        [1, 0.8, 0.5, 0.2]     // ring times
    ];
    var sig = DynKlank.ar(specs, exciter, freqscale: freq * freqMult, decayscale: decayscale);
    Pan2.ar(sig * amp, 0);
});

// Effects via JITLib Proxy Filter Slots (Initialized to 0 wetness)
Ndef(\canopyPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 180, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\canopyPad).set(\wet10, 0);

Ndef(\birdWings)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.08, \decayTime.kr(0.4)) };
Ndef(\birdWings).set(\wet11, 0);

// Using the "Mystic" chord/scale frequencies: C(130.8), F#(185), Bb(233.1), E(329.6), A(440), D(587.3)

Pbindef(\padSeq, \dur, 14, \freq, Pseq([130.81, 185.00, 233.08], inf), \t_trig, 1);

// 9:5 polyrhythmic structure for the wings (9 attacks vs 5 attacks) avoiding .flat on the pattern
Pbindef(\wingSeq,
    \dur, Pseq([
        1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9, 1/9,
        1/5, 1/5, 1/5, 1/5, 1/5
    ], inf),
    \freq, Pseq([880, 1174.66], inf),
    \t_trig, 1
);

Pbindef(\threatSeq, \dur, Pseq([4, 6, 8], inf), \freq, 45, \t_trig, 1);

Pbindef(\nestSeq, \dur, Pseq([0.5, 0.25, 0.75, 1], inf), \freq, Pseq([329.63, 440.00, 587.33], inf), \decayscale, 1.2, \t_trig, 1);

// Quantize to ensure synchronized entry when played
[Ndef(\canopyPad), Ndef(\birdWings), Ndef(\serpentThreat), Ndef(\nectarNest)].do(_.quant_(1));

Tdef(\fawnBreastedScore, {

    "0:00 - [Blocks 1 & 2: The Altitudinal Limit & Instinct]".postln;
    Ndef(\canopyPad).play;
    Ndef(\canopyPad)[1] = \set -> Pbindef(\padSeq);

    // Smoothly introduce the vast Andean spatial reverb
    Ndef(\canopyPad).xset(\wet10, 0.6, \lpfFreq, 1800);

    15.wait;

    "0:15 - [Blocks 3, 4 & 5: The Bird Hovering / Hunting Floaters]".postln;
    Ndef(\birdWings).play;
    Ndef(\birdWings)[1] = \set -> Pbindef(\wingSeq);

    // Snap a dry delay on the rapid 9:5 polyrhythm flutter
    Ndef(\birdWings).set(\wet11, 0.15);

    20.wait; // Now at 0:35

    "0:35 - [Blocks 6 & 7: Solitary Burden & Plague Alarm]".postln;
    // Alter global modifiers via .xset to avoid overriding Pbindef streams
    Ndef(\birdWings).xset(\freqMult, 1.25, \wet11, 0.4, \decayTime, 1.5);
    Ndef(\canopyPad).xset(\hpfFreq, 300); // The forest tension thins the low end

    15.wait; // Now at 0:50

    "0:50 - [Blocks 8, 9 & 10: Unpredictable Flight & The Meteor Serpent]".postln;
    Ndef(\serpentThreat).play;
    Ndef(\serpentThreat)[1] = \set -> Pbindef(\threatSeq);

    // The bird's flight becomes erratic and Doppler-shifted as it evades
    Ndef(\birdWings).xset(\freqMult, 1.5, \wet11, 0.7);
    Ndef(\canopyPad).xset(\lpfFreq, 800); // Muffle the background, focus on the threat

    25.wait; // Now at 1:15

    "1:15 - [Blocks 12 & 13: Buscar Nectar & Physiological Overdrive]".postln;
    Pbindef(\wingSeq, \dur, Pseq([1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/5, 1/5, 1/5, 1/5, 1/5], inf));

    Ndef(\birdWings).xset(\freqMult, 2.0); // Maximum hyper-drive pitch
    Ndef(\serpentThreat).xset(\freqMult, 0.5); // Threat loses ground, dropping in pitch

    25.wait; // Now at 1:40

    "1:40 - [Blocks 14 & 15: The Nest & Breakthrough / Hatching]".postln;
    Pbindef(\threatSeq).stop;
    Ndef(\serpentThreat).clear(5); // Threat dissipates into the jungle

    Ndef(\nectarNest).play;
    Ndef(\nectarNest)[1] = \set -> Pbindef(\nestSeq);

    // The bird calms, returning to the physical resonance of the nest
    Pbindef(\wingSeq, \dur, Pseq([1/5, 1/5, 1/5, 1/5, 1/5, 1/3, 1/3, 1/3], inf));
    Ndef(\birdWings).xset(\freqMult, 1.0, \wet11, 0.2, \decayTime, 0.2);
    Ndef(\canopyPad).xset(\lpfFreq, 3000, \hpfFreq, 100); // Forest opens back up

    25.wait; // Now at 2:05

    "2:05 - [Blocks 16, 17 & 18: Ecosystem Balance & Retreat]".postln;
    Pbindef(\nestSeq, \dur, Pseq([1, 1.5, 2], inf)); // Slowing down the physical modeling

    Ndef(\birdWings).xset(\freqMult, 0.75); // Retreating into the canopy
    Ndef(\canopyPad).xset(\lpfFreq, 400); // Light fading

    15.wait; // Now at 2:20

    "2:20 - [End of Day - .Clear]".postln;
    Pbindef(\padSeq).stop;
    Pbindef(\wingSeq).stop;
    Pbindef(\nestSeq).stop;

    // Clear all proxies with a long 10-second fade out
    Ndef(\canopyPad).clear(10);
    Ndef(\birdWings).clear(10);
    Ndef(\nectarNest).clear(10);

    "Score Complete. System Silent.".postln;
});
)

// Source: generate-craterlake.scd
(
Ndef(\deepBass).clear;
Ndef(\deepBass, {
	|freq=40, amp=0.5, t_trig=1|
	var env, sig, sub;
	env = EnvGen.ar(Env.perc(2, 6), t_trig);
	// LFTri provides harmonics for the filter, SinOsc provides foundational sub
	sig = LFTri.ar(freq) + SinOsc.ar(freq * 0.99);
	Pan2.ar(sig * env * amp, 0); // Narrow stereo for deep bass
}).play;

Ndef(\waterPad).clear;
Ndef(\waterPad, {
	|freq=150, amp=0.4, t_trig=1, atk=6, rel=8|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 0.8, 0], [atk, 2, rel]), t_trig);
	// Wide, ethereal pad using detuned saws
	sig = Saw.ar(freq * [0.99, 1.0, 1.015, 2.01]);
	sig = RLPF.ar(sig, freq * 4, 0.6);
	Splay.ar(sig) * env * amp;
}).play;

Ndef(\islandBell).clear;
Ndef(\islandBell, {
	|freq=600, amp=0.6, t_trig=1, pan=0|
	var env, mod, sig;
	env = EnvGen.ar(Env.perc(0.01, 5), t_trig);
	// FM Synthesis for resonant metallic strike
	mod = SinOsc.ar(freq * 1.414) * freq * 2 * EnvGen.ar(Env.perc(0.01, 1.5));
	sig = SinOsc.ar(freq + mod);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\phantomPulse).clear;
Ndef(\phantomPulse, {
	|freq=800, amp=0.3, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.005, 0.15), t_trig);
	// Ghostly filtered noise pulse
	sig = BPF.ar(WhiteNoise.ar, freq, 0.05);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\icyShimmer).clear;
Ndef(\icyShimmer, {
	|freq=2500, amp=0.2, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.05, 0.6), t_trig);
	// Crystalline high-frequency texture
	sig = SinOsc.ar(freq * [1, 1.02]) * LFNoise1.kr(15).range(0.2, 1);
	Pan2.ar(sig.sum * env * amp, pan);
}).play;

// deepBass Effects
Ndef(\deepBass)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.9, 0.5) };
Ndef(\deepBass).set(\wet10, 0);
Ndef(\deepBass)[11] = \filter -> { |in| RLPF.ar(in, \lpFreq.kr(80), 0.5) };
Ndef(\deepBass).set(\wet11, 1); // Filter always active to shape the rumble

// waterPad Effects
Ndef(\waterPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 100, 10, 0.7, 0.8) }; // Massive roomsize for vastness
Ndef(\waterPad).set(\wet10, 0);
Ndef(\waterPad)[11] = \filter -> { |in| CombL.ar(in, 1.0, \delayTime.kr(0.3), \decayTime.kr(3)) };
Ndef(\waterPad).set(\wet11, 0);

// islandBell Effects
Ndef(\islandBell)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.3) };
Ndef(\islandBell).set(\wet10, 0);

// phantomPulse Effects
Ndef(\phantomPulse)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.2) };
Ndef(\phantomPulse).set(\wet10, 0);
Ndef(\phantomPulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, \delayTime.kr(0.1), \decayTime.kr(0.8)) };
Ndef(\phantomPulse).set(\wet11, 0);

// icyShimmer Effects
Ndef(\icyShimmer)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.1) };
Ndef(\icyShimmer).set(\wet10, 0);
Ndef(\icyShimmer)[11] = \filter -> { |in|
	// Resonant filtering using dynamic arrays
	var sig = DynKlank.ar(Ref([[800, 1200, 1600], [1, 0.5, 0.2], [0.5, 0.8, 1.2]]), in.sum);
	Pan2.ar(sig, 0); // Restore to stereo field
};
Ndef(\icyShimmer).set(\wet11, 0);

// Slow, ancient geological pulses
Pbindef(\bassPulse, \dur, 10, \freq, Pseq([40, 42, 38, 40], inf), \amp, 0.5, \t_trig, 1);
Ndef(\deepBass).quant = 1;
Ndef(\deepBass)[1] = \set -> Pbindef(\bassPulse);

// Ethereal, extremely slow harmonic changes
Pbindef(\padFlow, \dur, 16, \freq, Pseq([ [[150, 225, 300]], [[140, 210, 280]], [[130, 195, 260]] ], inf), \amp, 0.35, \t_trig, 1);
Ndef(\waterPad).quant = 1;
Ndef(\waterPad)[1] = \set -> Pbindef(\padFlow);

// Sparse, isolated island strikes
Pbindef(\islandStrikes, \dur, Pwrand([8, 12, 16], [0.5, 0.3, 0.2], inf), \freq, Pwhite(600, 1000, inf), \pan, Pwhite(-0.5, 0.5, inf), \amp, 0.4, \t_trig, 1);
Ndef(\islandBell).quant = 1;
Ndef(\islandBell)[1] = \set -> Pbindef(\islandStrikes);

// Ghostly, barely perceptible irregular rhythms
Pbindef(\phantomRhythm, \dur, Pseq([0.5, 0.75, 1.25, Rest(3)], inf), \freq, Pexprand(700, 1200, inf), \pan, Pwhite(-0.8, 0.8, inf), \amp, 0.15, \t_trig, 1);
Ndef(\phantomPulse).quant = 1;
Ndef(\phantomPulse)[1] = \set -> Pbindef(\phantomRhythm);

// High-frequency granular bursts simulating ice
Pbindef(\shimmerGrains, \dur, Pwhite(0.15, 0.4, inf), \freq, Pexprand(2500, 6000, inf), \pan, Pwhite(-1.0, 1.0, inf), \amp, 0.1, \t_trig, 1);
Ndef(\icyShimmer).quant = 1;
Ndef(\icyShimmer)[1] = \set -> Pbindef(\shimmerGrains);
)

// Source: HIGH-T-custom-compose-240426.scd
(
s.waitForBoot({

    // -- SENTENCE 1 (Subtractive / AM)
    Ndef(\sentence1).ar(2);
    // FIXED: Renamed 'gate' to 'ctrlGate' to avoid JITLib collision
    Ndef(\sentence1, { |ctrlGate=0, freqMult=1, filterSweep=1000|
        var sig, env, alarm;
        env = EnvGen.kr(Env.asr(5, 1, 10), ctrlGate);
        sig = BrownNoise.ar(0.5);
        sig = RLPF.ar(sig, LFNoise2.kr(0.2).exprange(100, filterSweep), 0.1);
        alarm = SinOsc.ar([400, 405] * freqMult) * LFPulse.kr(4, 0, 0.5);
        sig = (sig + (alarm * 0.2)) * env;
        Pan2.ar(Mix(sig), SinOsc.kr(0.1));
    });
    Ndef(\sentence1)[10] = \filter -> { |in, wet10=0| Decimator.ar(in, 11025, 4) * wet10 + (in * (1-wet10)) };
    Ndef(\sentence1).set(\wet10, 0);

    // -- PHRASES A & B (FM & Sequencing)
    Ndef(\phrase_glass).ar(2);
    Ndef(\phrase_glass, { |t_trig=0, modIdx=2|
        var mod = SinOsc.ar(800) * modIdx;
        var car = SinOsc.ar(400 + mod);
        var env = EnvGen.kr(Env.perc(0.01, 4), t_trig);
        Pan2.ar(car * env * 0.3, LFNoise1.kr(1));
    });

    Pbindef(\phrase_glitch,
        \instrument, \default,
        \dur, Pseq([0.1, 0.1, 0.2, 0.05, 0.05, 0.5], 4),
        \degree, Pseq([0, 7, -2, 5, 12, \rest], inf),
        \amp, Pbrown(0.1, 0.4, 0.05),
        \pan, Pwhite(-0.8, 0.8)
    );

    // -- WORDS (Gestures < 2s)
    Ndef(\word_harsh).ar(2);
    Ndef(\word_harsh, { |t_trig=0|
        var sig = WhiteNoise.ar(1) * EnvGen.kr(Env.perc(0.001, 0.2), t_trig);
        Pan2.ar(sig, 0);
    });

    Ndef(\word_thud).ar(2);
    Ndef(\word_thud, { |t_trig=0|
        var sig = SinOsc.ar(XLine.kr(150, 30, 0.5)) * EnvGen.kr(Env.perc(0.01, 0.8), t_trig);
        Pan2.ar(sig * 0.8, 0);
    });

    // -- SENTENCE 4 (Wavetable/Modal Drone)
    Ndef(\sentence4).ar(2);
    // FIXED: Renamed 'gate' to 'ctrlGate'
    Ndef(\sentence4, { |ctrlGate=0, detune=0.01|
        var sig, env;
        env = EnvGen.kr(Env.asr(10, 1, 15), ctrlGate);
        sig = Mix.fill(6, { |i|
            SinOsc.ar(100 * (i+1) * LFNoise2.kr(0.1).range(1-detune, 1+detune))
            * (1/(i+1))
        });
        sig = sig * env * 0.2;
        Pan2.ar(sig, 0);
    });
    Ndef(\sentence4)[10] = \filter -> { |in, wet10=0| FreeVerb.ar(in, wet10, 0.9, 0.1) };
    Ndef(\sentence4).set(\wet10, 0);

    s.sync;
    "Setup Complete. You can now run Block 2.".postln;
});

// FIXED: Kills the routine if it is already running to prevent _RoutineResume crash
Tdef(\score).stop;

Tdef(\score, {
    "0:00 - SENTENCE 1: Firewall Red (Start)".postln;
    Ndef(\sentence1).play;
    // FIXED: Using \ctrlGate to hold the envelope open
    Ndef(\sentence1).set(\ctrlGate, 1, \filterSweep, 500);

    20.wait;

    "0:20 - SENTENCE 1: System Overwhelmed (FX Mod)".postln;
    Ndef(\sentence1).fadeTime = 10;
    Ndef(\sentence1).xset(\wet10, 0.8, \freqMult, 1.5, \filterSweep, 4000);

    20.wait;

    "0:40 - PHRASE A & B: Glass Variables & Glitch Sequences".postln;
    // FIXED: Closing the ctrlGate
    Ndef(\sentence1).set(\ctrlGate, 0);
    Ndef(\phrase_glass).play;
    Ndef(\phrase_glass).set(\t_trig, 1, \modIdx, 4);
    Pbindef(\phrase_glitch).play;

    7.wait;

    "0:47 - PHRASE VARIATION".postln;
    Ndef(\phrase_glass).set(\t_trig, 1, \modIdx, 10);

    3.wait;

    "0:50 - WORDS: Entropy Breakdown (Rapid Gestures)".postln;
    Pbindef(\phrase_glitch).stop;

    Ndef(\word_harsh).play; Ndef(\word_harsh).set(\t_trig, 1);
    0.4.wait;
    Ndef(\word_thud).play; Ndef(\word_thud).set(\t_trig, 1);
    0.6.wait;
    Ndef(\word_harsh).set(\t_trig, 1);
    0.2.wait;
    Ndef(\word_harsh).set(\t_trig, 1);
    0.8.wait;
    Ndef(\word_thud).set(\t_trig, 1);

    2.wait;

    "0:56 - SENTENCE 4: Existential Code (Choir Drone)".postln;
    Ndef(\sentence4).play;
    Ndef(\sentence4).set(\ctrlGate, 1, \wet10, 0.6);

    20.wait;

    "1:16 - SENTENCE 4: Defiance (Detuning)".postln;
    Ndef(\sentence4).fadeTime = 15;
    Ndef(\sentence4).xset(\detune, 0.15, \wet10, 0.9);

    20.wait;

    "1:36 - END OF COMPOSITION: Global Cleanup".postln;
    Ndef(\sentence4).set(\ctrlGate, 0);
    Ndef.clear(15);
    "Score Finished.".postln;

}).play;
)

// Source: HIGH-T-custom-compose-orbital-radio.scd
(
// Execute this entire block synchronously
s.waitForBoot({

    // 1. Critical Hardware Protection: Master Limiter
    SynthDef(\safetyLimiter, {
        var in = In.ar(0, 2);
        // Explicit 0.85 protection strictly specified in directives
        var safe = Limiter.ar(in, 0.85);
        ReplaceOut.ar(0, safe);
    }).add;

    s.sync;

    // Register Safety Limiter securely surviving all Cmd + . (ServerTree -> RootNode mapping)
    ServerTree.removeAll;
    ServerTree.add({
        Synth.tail(RootNode(s), \safetyLimiter);
    });
    // Trigger ServerTree explicitly on script init
    s.freeAll;

    s.sync;


    // ==========================================
    // "FRAGMENTED RADIO & ORBITAL STREAM" PROMPT INTERPRETATION
    // Adapting "Fluent", "Spacing", "Hungarian push circ", "radiation", "Sky", "embedded" into sonic properties
    // ==========================================

    // 2. Synthesizers setup (All instruments defined cleanly via NodeProxies as per Rule 3)

    // Instrument A: \dataPulsar -> Reflecting corrupted strings & coding elements
    Ndef(\dataPulsar).ar(2);
    Ndef(\dataPulsar).fadeTime = 0.5;
    Ndef(\dataPulsar, { |freq=400, amp=0.15, freqMult=1, ampMod=1, t_trig=1|
        var trigenv = EnvGen.kr(Env.perc(0.01, 0.1), t_trig); // Triggerable envelopment
        var panner = SinOsc.kr(12).range(-0.5, 0.5); // High speed panner -> localized stream feel
        // Sine synth priority for cleanliness, combining harmonics and smoothed high frequency rhythm
        var sig = SinOsc.ar([freq, freq*2] * freqMult) + LPF.ar(WhiteNoise.ar(0.1), freq * 1.5);
        Pan2.ar(sig.sum, panner) * trigenv * ampMod * amp;
    });

    // Proxy FX: Wet Mix = 0 initial. A ping pong spacing
    Ndef(\dataPulsar)[10] = \filter -> { |in| CombL.ar(in, 0.2, [0.12, 0.16], 1.5) };
    Ndef(\dataPulsar).set(\wet10, 0);


    // Instrument B: \skyPad -> Reflecting words "Fluent", "Ocean", "temporary", "gangster skyline" (thick but clean bass sweeps)
    Ndef(\skyPad).ar(2);
    Ndef(\skyPad).fadeTime = 3.5;
    Ndef(\skyPad, { |freq=110, amp=0.35, freqMult=1, ampMod=1, cutoff=800, rq=0.4, t_trig=1|
        // Utilizing a sustainable slow attack ASR requiring active resetting trigger protection without locking structure
        var slowEnv = EnvGen.kr(Env.asr(1.0, 1.0, 3.5), t_trig);
        var subOs = SinOsc.ar(freq * 0.5 * freqMult);
        var topOs = Saw.ar([freq * freqMult, freq * 1.015 * freqMult]);

        var sig = RLPF.ar(subOs + (topOs*0.3), cutoff, rq);
        sig = sig * slowEnv * ampMod * amp;
        Splay.ar(sig);
    });

    // Proxy FX: Grand Sky Verb initialized as wet10=0 strictly via set calls prior mapping automation
    Ndef(\skyPad)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], mix: 1, room: 0.9, damp: 0.2) };
    Ndef(\skyPad).set(\wet10, 0);


    s.sync;

    // 3. Start General UI as directed explicitly before structural triggering
    s.makeGui;


    // ==========================================
    // SCORE & ABSOLUTE TIME GESTURE SYSTEM
    // Using single explicit Time Sequence via Tdef -> Pbindef architecture control bounds
    // ==========================================

    Tdef(\hungarianRadiatorFlow, {

        "Initiating Sequence... Listening to Stream.".postln;

        // Immediate State Changes Setters via instant `.set` explicitly handling node values vs temporal `.xset` bindings.
        Ndef(\skyPad).set(\t_trig, 1, \cutoff, 400);
        Ndef(\dataPulsar).set(\freq, 400);

        1.wait;

        "Opening Sky Base Layer...".postln;
        Ndef(\skyPad).play;
        Ndef(\skyPad).xset(\freq, 60, \freqMult, 1, \wet10, 0.3);

        2.5.wait;

        "Data Packet Transmissions Beginning (Radiation & Output Hooks) ...".postln;
        Ndef(\dataPulsar).play;

        // Linking node rhythm controls into an outer pattern sending values structurally inward per spec definition rule handling target bindings manually:
        Pbindef(\codePingSweep,
            \type, \set,
            \id, Ndef(\dataPulsar).group,
            \args, [\freq, \freqMult, \t_trig, \ampMod],
            \t_trig, 1,
            \freq, Pxrand([400, 800, 600, 1200], inf),
            \ampMod, Pwhite(0.5, 1.2, inf),
            \dur, Prand([0.15, 0.1, 0.3], inf)
        ).play;

        4.wait;

        "Lifting Modulators & Effects Smoothly [Barber-Dur sweep action]".postln;
        Ndef(\skyPad).xset(\freqMult, 1.5, \cutoff, 1800, \wet10, 0.6); // Expanding via crossfading sweeps securely using xset proxy handling mapping rules explicitly
        Ndef(\dataPulsar).xset(\wet10, 0.45); // Turn Echo Stream Flow upwards smoothly

        5.wait;

        // Changing sequences dynamically over flow structure. Use pattern binding durations for sync modulation gestures
        Pbindef(\codePingSweep,
            \dur, Prand([0.05, 0.08, 0.02], inf),
            \freqMult, Pseq([1, 1.5, 2.0, 1.1], inf)
        );
        Ndef(\skyPad).xset(\ampMod, 1.4);

        6.wait;

        "Returning Signal toward Submerged Neutral Point ...".postln;
        Ndef(\skyPad).xset(\freqMult, 0.75, \cutoff, 300, \wet10, 0.8, \ampMod, 0.8);

        // Set hard rhythmic resets mapping specifically `.set()` instant constraints as requested cleanly over rulesets mappings checks natively avoiding overlapping overlaps failures bindings
        Pbindef(\codePingSweep, \dur, 0.5, \freq, 200, \freqMult, 1);
        Ndef(\dataPulsar).set(\ampMod, 0.5);

        4.wait;

        // Final Clearance phase procedures to adhere completely ending sequence logic rules accurately cleaning
        "End Routine Transmissions Commencing. Exiting Sequences gracefully.".postln;

        // Strict explicit shutdown pattern triggers stopping and long `.clear(xx)` procedures for all continuous instances proxies proxies correctly mapping explicitly per node
        Pbindef(\codePingSweep).stop;

        Ndef(\skyPad).clear(10);
        Ndef(\dataPulsar).clear(10);

        10.wait;

        "Operation Closed Properly.".postln;

    }).play;
});
)

// Source: HIGH-T-generate-resilience.scd
(
Ndef(\fmPad).clear;
Ndef(\fmPad, {
	|freq=200, modFreq=100, modIndex=1.5, amp=0.3, atk=1, rel=3, t_trig=1|
	var env, mod, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, 0.1, rel]), t_trig);
	mod = SinOsc.ar(modFreq) * modIndex * freq;
	// Stereo detune expansion
	sig = SinOsc.ar(freq + mod + [0, 1.5]);
	sig * env * amp;
}).play;

Ndef(\ksPluck).clear;
Ndef(\ksPluck, {
	|freq=440, decay=2, damp=0.4, amp=0.5, t_trig=1, pan=0|
	var env, exciter, sig;
	env = EnvGen.ar(Env.perc(0.001, 0.05), t_trig);
	exciter = WhiteNoise.ar * env;
	// Pluck.ar requires 1/freq for correct pitch delay time
	sig = Pluck.ar(exciter, t_trig, 0.2, 1/freq, decay, damp);
	Pan2.ar(sig * amp, pan);
}).play;

Ndef(\noisePerc).clear;
Ndef(\noisePerc, {
	|freq=8000, rq=0.3, rel=0.1, amp=0.2, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.001, rel), t_trig);
	sig = WhiteNoise.ar;
	sig = BPF.ar(sig, freq, rq);
	Pan2.ar(sig * env * amp, pan);
}).play;

// fmPad Reverb (Index 10)
Ndef(\fmPad)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.85, 0.1) };
Ndef(\fmPad).set(\wet10, 0);

// ksPluck Delay (Index 11)
Ndef(\ksPluck)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.375, 3) };
Ndef(\ksPluck).set(\wet11, 0);

// noisePerc Spatializer (Index 10)
Ndef(\noisePerc)[10] = \filter -> { |in| GVerb.ar(in.sum, 30, 1) * 0.5 };
Ndef(\noisePerc).set(\wet10, 0);

Pbindef(\padSeq,
	\dur, 4,
	\freq, Pseq([200, 180, 220, 150], inf),
	\modIndex, Pwhite(1.0, 2.0),
	\t_trig, 1
);
Ndef(\fmPad).quant = 1;
Ndef(\fmPad)[1] = \set -> Pbindef(\padSeq);

Pbindef(\pluckSeq,
	\dur, 0.5,
	\freq, Pseq([440, 660, 550, 880, 440, 330, 550, 770], inf),
	\pan, Pseq([-0.5, 0.5, -0.25, 0.25], inf),
	\t_trig, 1
);
Ndef(\ksPluck).quant = 1;
Ndef(\ksPluck)[1] = \set -> Pbindef(\pluckSeq);

Pbindef(\percSeq,
	\dur, 0.25,
	\freq, Pseq([8000, 400, 12000, 400, 8000, 400, 6000, 200], inf),
	\rq, Pseq([0.1, 0.8, 0.1, 0.8], inf),
	\rel, Pseq([0.05, 0.2, 0.05, 0.2], inf),
	\amp, Pseq([0.1, 0.3, 0.1, 0.2], inf),
	\t_trig, 1
);
Ndef(\noisePerc).quant = 1;
Ndef(\noisePerc)[1] = \set -> Pbindef(\percSeq);

Pbindef(\padSeq).stop;
Pbindef(\pluckSeq).stop;
Pbindef(\percSeq).stop;

Ndef(\fmPad).fadeTime = 8;
Ndef(\ksPluck).fadeTime = 8;
Ndef(\noisePerc).fadeTime = 8;

Ndef(\fmPad).clear(8);
Ndef(\ksPluck).clear(8);
Ndef(\noisePerc).clear(8);
)

// Source: HIGH-T-lexical-core.scd
(
{

    // 1. Force the ServerTree to run immediately so the limiter exists
    ServerTree.removeAll;
    ServerTree.add({
        SynthDef(\safetyLimiter, {
            var sig = In.ar(0, 2);
            sig = Limiter.ar(sig, 0.85, 0.01);
            ReplaceOut.ar(0, sig);
        }).play(RootNode(s), addAction: \addToTail);
    });
    ServerTree.run; // <--- Manually trigger it now

    s.freeAll;
    s.sync;

    Ndef.clear;
    Pbindef.clear;

	s.sync;
}

\lexical_compiler, {
        Ndef(\lexical_core).play;

        Ndef(\lexical_core)[1] = \set -> Pbindef(\lex_trig,
            \dur, Pwrand([0.015, 0.03, 0.075, 0.125], [0.5, 0.25, 0.15, 0.1], inf),
            \t_trig, 1,
            \freq, Pexprand(80, 2500, inf),
            \freqMult, Pwrand([1, 1.5, 2.33, 0.5], [0.4, 0.3, 0.2, 0.1], inf),
            \ampMod, Pseq([1, 1, 0.5, 1, 0, 1, 0.2], inf),
            \pan, Pwhite(-0.8, 0.8, inf)
        );

        4.wait;
        Ndef(\lexical_core).set(\chaos_idx, 0.65);
        2.8.wait;
        Ndef(\lexical_core).fadeTime = 4.0;
        Ndef(\lexical_core).xset(\wet11, 0.85, \crush, 6, \rate, 11025);
        // ... (rest of your wait logic)

        6.wait;
        "Execution complete.".postln;
    }
)

// Source: ndef-pbindef-slots-examples.scd
(
Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 2, 4, 5], inf), // Play a simple scale
    \dur, 0.25,                       // 1/4 second per note
    \amp, 0.2
).play;

Ndef(\mainOut)[0] = Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 3, 5, 7, 10, 12], inf),
    \dur, 0.25,
    \cutoff, 1500
);

Ndef(\mainOut)[1] = \filter -> { |in|
    // Mix the dry signal 'in' with a ping-pong delay
    in + CombC.ar(in, 0.5, [0.3, 0.4], 3, 0.5);
};

Ndef(\mainOut)[2] = \filter -> { |in|
    var verb = FreeVerb2.ar(in[0], in[1], mix: 0.4, room: 0.8);
    // Add a slow sweeping filter over everything
    RLPF.ar(verb, SinOsc.kr(0.1).exprange(300, 3000), 0.2);
};

Ndef(\mainOut)[1] = \filter -> { |in|
    (in * 5).tanh * 0.2; // Overdrive
};
)

// Source: new-test.scd
(
// Ndef(\osc1): Saw wave, foundational tone with an envelope
Ndef(\osc1).clear;
Ndef(\osc1, {
	|freq=220, amp=0.3, pan=0, atk=0.01, rel=0.2, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Saw.ar(freq);
	Pan2.ar(sig * env * amp, pan);
}).play;

// Ndef(\osc2): Pulse wave, contrasting timbre with an envelope
Ndef(\osc2).clear;
Ndef(\osc2, {
	|freq=110, amp=0.001, pan=0.4, width=0.3, atk=0.05, rel=0.5, t_trig=1|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Pulse.ar(freq, width);
	Pan2.ar(sig * env * amp, pan);
}).play;

// Reverb for Ndef(\osc1) on slot [10]
Ndef(\osc1)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) };
Ndef(\osc1).set(\wet10, 0); // Initialize reverb wetness to 0

// Sequence for Ndef(\osc1): Simple C major arpeggio
Pbindef(\osc1Seq,
	\instrument, \osc1,
	\degree, Pseq([0, 2, 4, 7], inf), // C major arpeggio
	\scale, Scale.major,
	\dur, 1,
	\amp, 1, // Full amplitude for pattern, controlled by Ndef's top-level amp
	\t_trig, 1
);
Ndef(\osc1).quant = 1; // Quantize sequence changes to the beat
Ndef(\osc1)[1] = \set -> Pbindef(\osc1Seq);

// Sequence for Ndef(\osc2): Sparse, low C minor notes for a drone-like quality
Pbindef(\osc2Seq,
	\instrument, \osc2,
	\degree, Pseq([-12, -5, -17], inf), // C minor notes an octave or two down
	\scale, Scale.minor,
	\dur, 4, // Long durations for a sustained, drone-like character
	\amp, 1, // Full amplitude for pattern, controlled by Ndef's top-level amp
	\t_trig, 1
);
Ndef(\osc2).quant = 1; // Quantize sequence changes to the beat
Ndef(\osc2)[1] = \set -> Pbindef(\osc2Seq);

// Fade in Ndef(\osc2) amplitude over its fadeTime (2 seconds)
Ndef(\osc2).xset(\amp, 0.2); // Introduce the contrasting pulse wave
// Ndef(\osc2).xset(\amp, 0.001); // Revert Ndef(\osc2) to initial silent state

// Fade in reverb on Ndef(\osc1) over its fadeTime (2 seconds)
Ndef(\osc1).xset(\wet10, 0.4); // Add subtle depth to the foundational saw wave
// Ndef(\osc1).xset(\wet10, 0); // Revert Ndef(\osc1) reverb mix to 0

// Set a longer fadeTime for the outro
Ndef(\osc1).fadeTime = 10;
Ndef(\osc2).fadeTime = 10;

// Fade out Ndef(\osc1) amplitude and reverb over 10 seconds
Ndef(\osc1).xset(\amp, 0.0, \wet10, 0.0); // Ndef(\osc1) fades out and its reverb disappears
// Ndef(\osc1).xset(\amp, 0.3, \wet10, 0.4); // Revert Ndef(\osc1) to previous state

// Fade out Ndef(\osc2) amplitude over 10 seconds
Ndef(\osc2).xset(\amp, 0.0); // Ndef(\osc2) fades out
// Ndef(\osc2).xset(\amp, 0.2); // Revert Ndef(\osc2) to previous state

// Wait for the fades to complete, then stop patterns and clear Ndefs
fork {
	10.wait; // Wait for the 10-second fadeTime applied above
	Pbindef(\osc1Seq).stop; // Stop Ndef(\osc1)'s pattern
	Pbindef(\osc2Seq).stop; // Stop Ndef(\osc2)'s pattern
	Ndef(\osc1).clear(2); // Clear Ndef(\osc1) after a short additional fade
	Ndef(\osc2).clear(2); // Clear Ndef(\osc2) after a short additional fade
	"Composition: Oscillator Test Patch ended cleanly.".postln;
};
)

// Source: oscillators.scd
(
// Ensure ProxySpace and Ndef system are initialized
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Oscillator Study Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;

	NdefMixer(s); // Optional, but good practice for a master mix
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = LeakDC.ar(in);
		Limiter.ar(sig, 0.95, 0.01);
	});
	"System Ready.".postln;
});

Ndef(\fmSynth).clear;
Ndef(\fmSynth, {
	|freq=60, modRatio=1.5, modIndex=0.5, amp=0.4, atk=0.1, rel=1.5, t_trig=1|
	var env, mod, car, sig;
	env = EnvGen.ar(Env([0, 1, 0], [atk, rel], \sin), t_trig); // Smooth sine attack/release
	mod = SinOsc.ar(freq * modRatio) * (freq * modIndex); // Modulator frequency and depth
	car = SinOsc.ar(freq + mod); // Carrier
	sig = Pan2.ar(car * env * amp, Rand(-0.5, 0.5));
}).play;

Ndef(\kick).clear;
Ndef(\kick, {
	|freq=40, clickFreq=120, amp=0.8, atk=0.005, rel=0.2, t_trig=1|
	var env, pitchEnv, sub, click, sig;
	env = EnvGen.ar(Env.perc(atk, rel, curve: -4), t_trig);
	pitchEnv = EnvGen.ar(Env([freq * 2, freq * 0.5, freq * 0.1], [atk, rel * 0.5, rel * 0.5], \exp), t_trig); // Descending pitch
	sub = SinOsc.ar(pitchEnv);
	click = WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(atk, atk * 2), t_trig);
	sig = LPF.ar(sub + click, freq * 3); // Low-pass to clean up click
	Pan2.ar(sig * env * amp, 0); // Mono, sub-bass
}).play;

Ndef(\sawLead).clear;
Ndef(\sawLead, {
	|freq=120, amp=0.0, atk=0.2, sus=0.5, rel=1.0, lpfFreq=500, lpfRq=0.5, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel], [-4, 0, -4]), t_trig); // ADSR-like
	sig = Saw.ar([freq, freq * 1.005]); // Slightly detuned for richness
	sig = RLPF.ar(sig, lpfFreq, lpfRq);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\pulseRhythm).clear;
Ndef(\pulseRhythm, {
	|freq=400, width=0.5, amp=0.0, atk=0.01, rel=0.1, t_trig=1, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig);
	sig = Pulse.ar(freq, width);
	Pan2.ar(sig * env * amp, pan);
}).play;

// --- fmSynth Effects ---
Ndef(\fmSynth)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.5) }; // Reverb (100% wet)
Ndef(\fmSynth).set(\wet10, 0);
Ndef(\fmSynth)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.15, 0.7) }; // Delay (100% wet)
Ndef(\fmSynth).set(\wet11, 0);
Ndef(\fmSynth)[12] = \filter -> { |in| (in * 2).tanh / 2 }; // Subtle Distortion
Ndef(\fmSynth).set(\wet12, 0);

// --- kick Effects ---
Ndef(\kick)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.3) }; // Reverb
Ndef(\kick).set(\wet10, 0);
Ndef(\kick)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.2, 1.2) }; // Longer Delay
Ndef(\kick).set(\wet11, 0);

// --- sawLead Effects ---
Ndef(\sawLead)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.4) }; // Reverb
Ndef(\sawLead).set(\wet10, 0);
Ndef(\sawLead)[11] = \filter -> { |in| CombL.ar(in, 0.3, 0.1, 1.0) }; // Delay
Ndef(\sawLead).set(\wet11, 0);
Ndef(\sawLead)[12] = \filter -> { |in| (in * 3).clip2(0.8) }; // Light Clipping
Ndef(\sawLead).set(\wet12, 0);

// --- pulseRhythm Effects ---
Ndef(\pulseRhythm)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.5, 0.2) }; // Reverb
Ndef(\pulseRhythm).set(\wet10, 0);
Ndef(\pulseRhythm)[12] = \filter -> { |in| (in * 5).fold2(0.5) }; // Distortion
Ndef(\pulseRhythm).set(\wet12, 0);

// --- fmSynth Sequence ---
Pbindef(\fmSeq,
    \instrument, \fmSynth,
    \degree, Pseq([0, 2, 4, 7, 5, 2, 0, (-3)], inf),
    \scale, Scale.minor,
    \dur, 2,
    \amp, 0.4,
    \t_trig, 1
);
Ndef(\fmSynth).quant = 1;
Ndef(\fmSynth)[1] = \set -> Pbindef(\fmSeq);

// --- kick Sequence ---
Pbindef(\kickSeq,
    \instrument, \kick,
    \freq, 30,
    \dur, 4, // Very slow pulse
    \amp, 0.05, // Very low volume
    \t_trig, 1
);
Ndef(\kick).quant = 1;
Ndef(\kick)[1] = \set -> Pbindef(\kickSeq);

// --- sawLead Sequence (initially inactive) ---
Pbindef(\sawSeq,
    \instrument, \sawLead,
    \degree, Pseq([7, 5, 4, 2], inf),
    \scale, Scale.major,
    \dur, 4,
    \legato, 3.5,
    \amp, 0.0, // Start silent
    \t_trig, 1
);
Ndef(\sawLead).quant = 1;
Ndef(\sawLead)[1] = \set -> Pbindef(\sawSeq);

// --- pulseRhythm Sequence (initially inactive) ---
Pbindef(\pulseSeq,
    \instrument, \pulseRhythm,
    \freq, Pseq([400, 800, 600, 1000], inf),
    \width, 0.3,
    \dur, 0.25,
    \amp, 0.0, // Start silent
    \t_trig, 1
);
Ndef(\pulseRhythm).quant = 1;
Ndef(\pulseRhythm)[1] = \set -> Pbindef(\pulseSeq);

Ndef(\fmSynth).fadeTime = 2;
Ndef(\kick).fadeTime = 2;
Pbindef(\fmSeq).play;
Pbindef(\kickSeq).play;

// fmSynth: low freq, gentle FM, long decay, sparse arpeggio
Ndef(\fmSynth).xset(\modIndex, 0.8, \atk, 0.5, \rel, 3.0); // Gentle FM, longer envelope
// Ndef(\fmSynth).xset(\modIndex, 0.5, \atk, 0.1, \rel, 1.5); // Revert

// kick: sub-bass, very slow
Pbindef(\kickSeq, \freq, 35, \dur, 4, \amp, 0.08); // Steady, very subtle
// Pbindef(\kickSeq, \freq, 30, \dur, 4, \amp, 0.05); // Revert

// fmSynth effects: subtle, long reverb and rhythmic delay
Ndef(\fmSynth).xset(\wet10, 0.5, \wet11, 0.3);
// Ndef(\fmSynth).xset(\wet10, 0, \wet11, 0); // Revert

// fmSynth: modIndex increases, brighter timbre
Ndef(\fmSynth).xset(\modIndex, 2.0); // Brighter, more complex harmonics
// Ndef(\fmSynth).xset(\modIndex, 0.8); // Revert

// fmSynth: freq range expands, rhythmic density increases, decay shortens
Pbindef(\fmSeq,
    \degree, Pseq([0, 4, 7, 12, 11, 7, 4, 0], inf), // Wider range
    \dur, 1.5, // Slightly faster
    \rel, 2.0 // Shorter release for more definition
);
// Pbindef(\fmSeq, \degree, Pseq([0, 2, 4, 7, 5, 2, 0, (-3)], inf), \dur, 2, \rel, 3.0); // Revert

// kick: rhythm subtly increases complexity
Pbindef(\kickSeq, \dur, Pseq([4, 2, 4, 2], inf), \amp, 0.1); // Occasional off-beat hit
// Pbindef(\kickSeq, \dur, 4, \amp, 0.08); // Revert

// fmSynth effects: subtle increase in reverb and delay
Ndef(\fmSynth).xset(\wet10, 0.6, \wet11, 0.4);
// Ndef(\fmSynth).xset(\wet10, 0.5, \wet11, 0.3); // Revert

Ndef(\sawLead).fadeTime = 3;
Pbindef(\sawSeq).play;

// sawLead: introduce, sustained, filtered, low in mix
Pbindef(\sawSeq, \amp, 0.3, \dur, 3.0, \legato, 2.8); // Bring in saw lead, sustained
// Pbindef(\sawSeq, \amp, 0.0); // Revert

// sawLead filter: slowly opens (lpfFreq sweeps upwards)
Ndef(\sawLead).xset(\lpfFreq, 3000, \lpfRq, 0.3, \pan, (-0.4)); // Filter opening, some pan
// Ndef(\sawLead).xset(\lpfFreq, 500, \lpfRq, 0.5, \pan, 0); // Revert

// sawLead effects: short, bright reverb added
Ndef(\sawLead).xset(\wet10, 0.4);
// Ndef(\sawLead).xset(\wet10, 0); // Revert

// fmSynth: pattern simplifies/syncopates, recedes slightly
Pbindef(\fmSeq,
    \degree, Pseq([0, 7, 0, 4], inf),
    \dur, 2, // Slower, more spacious
    \amp, 0.3 // Recede slightly
);
// Pbindef(\fmSeq, \degree, Pseq([0, 4, 7, 12, 11, 7, 4, 0], inf), \dur, 1.5, \amp, 0.4); // Revert

// kick: more driving, consistent beat
Pbindef(\kickSeq, \dur, 1, \amp, 0.15); // Four-on-the-floor
// Pbindef(\kickSeq, \dur, Pseq([4, 2, 4, 2], inf), \amp, 0.1); // Revert

Ndef(\pulseRhythm).fadeTime = 1;
Pbindef(\pulseSeq).play;

// pulseRhythm: introduce, fast, percussive
Pbindef(\pulseSeq, \amp, 0.2, \dur, 0.125, \pan, Pseq([0.5, (-0.5)], inf)); // Fast, aggressive pulse
// Pbindef(\pulseSeq, \amp, 0.0); // Revert

// pulseRhythm effects: subtle distortion
Ndef(\pulseRhythm).xset(\wet12, 0.5);
// Ndef(\pulseRhythm).xset(\wet12, 0); // Revert

// sawLead: filter opens fully, amp peaks
Ndef(\sawLead).xset(\lpfFreq, 8000, \amp, 0.6, \pan, 0.4); // Brightest timbre, peak amplitude
// Ndef(\sawLead).xset(\lpfFreq, 3000, \amp, 0.3, \pan, (-0.4)); // Revert

// fmSynth: modIndex increases again, shimmering quality
Ndef(\fmSynth).xset(\modIndex, 4.0, \rel, 1.0); // Bell-like sparkle
// Ndef(\fmSynth).xset(\modIndex, 2.0, \rel, 2.0); // Revert

// All Ndef's reverb swells slightly (applied to individual Ndefs for control)
Ndef(\fmSynth).xset(\wet10, 0.7);
Ndef(\sawLead).xset(\wet10, 0.6);
Ndef(\kick).xset(\wet10, 0.3);
Ndef(\pulseRhythm).xset(\wet10, 0.3);
// Ndef(\fmSynth).xset(\wet10, 0.6); Ndef(\sawLead).xset(\wet10, 0.4); Ndef(\kick).xset(\wet10, 0); Ndef(\pulseRhythm).xset(\wet10, 0); // Revert

// --- pulseRhythm stops and fades ---
Pbindef(\pulseSeq).stop;
Ndef(\pulseRhythm).fadeTime = 2;
Ndef(\pulseRhythm).clear(2); // Clear after 2 seconds
// Pbindef(\pulseSeq).play; Ndef(\pulseRhythm).clear; // Revert

// --- kick stops and fades ---
0.5.wait; // Short pause
Pbindef(\kickSeq).stop;
Ndef(\kick).fadeTime = 3;
Ndef(\kick).clear(3); // Clear after 3 seconds
// Pbindef(\kickSeq).play; Ndef(\kick).clear; // Revert

// --- sawLead filter closes, amplitude decreases, pattern simplifies, then stops ---
2.0.wait; // Pause before fading sawLead
Ndef(\sawLead).xset(\lpfFreq, 200, \amp, 0.1, \pan, 0); // Filter closes, amplitude drops
Pbindef(\sawSeq, \degree, Pseq([0, 0, 0, 0], inf), \dur, 8, \legato, 7.5); // Very simple drone
// Ndef(\sawLead).xset(\lpfFreq, 8000, \amp, 0.6, \pan, 0.4); Pbindef(\sawSeq, \degree, Pseq([7, 5, 4, 2], inf), \dur, 3.0, \legato, 2.8); // Revert

3.0.wait; // Pause
Pbindef(\sawSeq).stop;
Ndef(\sawLead).fadeTime = 4;
Ndef(\sawLead).clear(4); // Clear after 4 seconds
// Pbindef(\sawSeq).play; Ndef(\sawLead).clear; // Revert

// --- fmSynth reverts, reverb/delay increase, then fades ---
5.0.wait; // Pause
Ndef(\fmSynth).xset(\modIndex, 0.1, \freq, 40, \rel, 5.0, \atk, 2.0); // Pure tone, very long release
Pbindef(\fmSeq, \degree, Pseq([0, (-7)], inf), \dur, 8); // Very sparse, low pattern
Ndef(\fmSynth).xset(\wet10, 0.9, \wet11, 0.7); // Max out reverb and delay
// Ndef(\fmSynth).xset(\modIndex, 4.0, \freq, 60, \rel, 1.0, \atk, 0.1); Pbindef(\fmSeq, \degree, Pseq([0, 7, 0, 4], inf), \dur, 2); Ndef(\fmSynth).xset(\wet10, 0.7, \wet11, 0.4); // Revert

10.0.wait; // Long pause to let it echo
Pbindef(\fmSeq).stop;
Ndef(\fmSynth).fadeTime = 8; // Very long fade out
Ndef(\fmSynth).clear(8); // Clear after 8 seconds
// Pbindef(\fmSeq).play; Ndef(\fmSynth).clear; // Revert

"Composition Ended.".postln;
)

// Source: pulse.scd
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Composition Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 2.0;

	NdefMixer(s);

	// MASTER FX & LIMITER
	Ndef(\master).play;
	Ndef(\master).filter(100, { |in|
		var sig = LeakDC.ar(in);
		Limiter.ar(sig, 0.95, 0.01);
	});
});

Ndef(\sinePad).clear;
Ndef(\sinePad, {
	|freq=180, amp=0.1, t_trig=1, atk=4, rel=8, sus=4, lfoFreq=0.1, lfoDepth=0.005, detune=0.002, pan=0|
	var env, lfo, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel]), t_trig, doneAction: 0);
	lfo = SinOsc.kr(lfoFreq) * lfoDepth * freq; // Subtle vibrato
	sig = SinOsc.ar(freq + lfo) + SinOsc.ar((freq * (1 + detune)) + lfo); // Two detuned sines
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\sinePad).fadeTime = 4; // Long fade time for pad

Ndef(\pulseBase).clear;
Ndef(\pulseBase, {
	|freq=60, amp=0.15, t_trig=1, atk=0.5, rel=3, width=0.8, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = Pulse.ar([freq, freq * 1.005], width); // Slightly detuned for richness
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\pulseBase).fadeTime = 2; // Moderate fade time

Ndef(\sineLead).clear;
Ndef(\sineLead, {
	|freq=500, amp=0.2, t_trig=1, atk=0.01, rel=0.3, detune=0.003, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = SinOsc.ar(freq) + SinOsc.ar(freq * (1 + detune)); // Detuned for bell-like quality
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\sineLead).fadeTime = 1; // Shorter fade time for percussive element

Ndef(\sinePad)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) }; // in.sum for mono input
Ndef(\sinePad).set(\wet10, 0);

Ndef(\pulseBase)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.3) };
Ndef(\pulseBase).set(\wet10, 0);

Ndef(\sineLead)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.2) };
Ndef(\sineLead).set(\wet10, 0);

Ndef(\sinePad)[11] = \filter -> { |in| CombL.ar(in, 0.4, 0.3, 3) }; // Long evolving delay
Ndef(\sinePad).set(\wet11, 0);

Ndef(\sineLead)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.15, 1.2) }; // Shorter, shimmering delay
Ndef(\sineLead).set(\wet11, 0);

Ndef(\pulseBase)[12] = \filter -> { |in| (in * 2.0).fold2(0.8) }; // Gentle saturation
Ndef(\pulseBase).set(\wet12, 0);

Pbindef(\sinePadSeq,
	\degree, Pseq([0, 2, 4, 7, 5, 2, 0, -2], inf),
	\scale, Scale.minor,
	\dur, 8, // Very slow changes
	\amp, 0.1,
	\atk, 4, \rel, 8, \sus, 4, // Long envelope
	\lfoFreq, Pwhite(0.08, 0.12, inf),
	\lfoDepth, Pwhite(0.003, 0.007, inf),
	\detune, Pwhite(0.001, 0.003, inf),
	\t_trig, 1
);

Pbindef(\pulseSeq,
	\dur, Pseq([1.5, 1, 0.5, 2], inf), // Syncopated, slow rhythm
	\degree, Pseq([-12, -12.01, -12.02, -12], inf), // Very low pitch
	\scale, Scale.chromatic, // Chromatic scale doesn't matter for specific degree, just direct frequency
	\amp, 0.15,
	\atk, 0.5, \rel, 3,
	\width, Pwhite(0.7, 0.9, inf), // Fluctuate width slightly
	\pan, Pwhite((-0.5), 0.5, inf),
	\t_trig, 1
);

Pbindef(\sineLeadSeq,
	\dur, Pseq([0.25, 0.5, 0.25, 0.25], inf), // Arpeggiated rhythm
	\degree, Pseq([0, 2, 4, 5, 7, 5, 4, 2], inf), // Simple ascending/descending
	\scale, Scale.major,
	\amp, 0.2,
	\atk, 0.01, \rel, 0.3,
	\detune, 0.003,
	\pan, Pwhite((-0.7), 0.7, inf),
	\t_trig, 1
);

Ndef(\sinePad).set(\amp, 0.001); // Start almost silent for slow fade in
Ndef(\sinePad).xset(\amp, 0.1, \freq, 180, \lfoFreq, 0.1, \lfoDepth, 0.005, \detune, 0.002, \pan, 0); // Ethereal pad
Ndef(\sinePad).xset(\wet10, 0.7); // High reverb for vast soundscape

fork {
	20.wait; // Wait 20 seconds for sinePad to establish
	Ndef(\pulseBase).set(\amp, 0.001); // Start almost silent
	Ndef(\pulseBase).xset(\amp, 0.15, \freq, 60, \width, 0.85, \atk, 0.5, \rel, 3, \pan, 0); // Deep, soft pulse
	Ndef(\pulseBase).xset(\wet10, 0.6); // Moderate reverb for depth
};

fork {
	60.wait; // Wait for initial atmosphere to develop
	// \pulseBase gets Pbindef
	Pbindef(\pulseSeq).resume; // Ensure it's not accidentally stopped
	Ndef(\pulseBase).quant = 1;
	Ndef(\pulseBase)[1] = \set -> Pbindef(\pulseSeq);
	Pbindef(\pulseSeq, \amp, 0.2); // Increase amplitude slightly
	Ndef(\pulseBase).xset(\wet12, 0.3); // Add subtle saturation

	// \sineLead enters
	Ndef(\sineLead).set(\amp, 0.001); // Start silent for fade in
	Ndef(\sineLead).xset(\amp, 0.2); // Bring in sine lead
	Ndef(\sineLead).quant = 1;
	Ndef(\sineLead)[1] = \set -> Pbindef(\sineLeadSeq);
	Ndef(\sineLead).xset(\wet11, 0.4); // Add short delay

	// \sinePad adapts
	Ndef(\sinePad).xset(\lfoFreq, 0.15); // Slightly faster vibrato
};

fork {
	120.wait; // Wait for rhythmic incursion to develop
	// \sineLead becomes faster and richer
	Pbindef(\sineLeadSeq,
		\dur, Pseq([0.125, 0.25, 0.125, 0.125], inf), // Faster rhythm
		\degree, Pseq([7, 9, 11, 12, 14, 12, 11, 9], inf), // Higher arpeggio
		\detune, 0.005 // More noticeable detune
	);
	Ndef(\sineLead).xset(\amp, 0.3); // Increase volume
	Ndef(\sineLead).xset(\wet10, 0.8, \wet11, 0.6); // More reverb and delay

	// \sinePad introduces evolving chords
	Pbindef(\sinePadSeq).resume; // Ensure it's not accidentally stopped
	Ndef(\sinePad).quant = 1;
	Ndef(\sinePad)[1] = \set -> Pbindef(\sinePadSeq);
	Pbindef(\sinePadSeq, \dur, 6); // Slightly faster chord changes
	Ndef(\sinePad).xset(\detune, 0.004); // Increase detune for more beating
	Ndef(\sinePad).xset(\wet10, 0.9, \wet11, 0.5); // Maximize reverb, add delay

	// \pulseBase drops out and returns
	Pbindef(\pulseSeq).stop; // Pause the rhythmic pulse
	Ndef(\pulseBase).xset(\amp, 0.05, \freq, 40, \width, 0.95); // Sustain low drone
	20.wait; // Hold drone for a bit
	Pbindef(\pulseSeq,
		\dur, Pseq([4, 2, 8], inf), // Very sparse, slow pulse
		\amp, 0.1,
		\degree, Pseq([-12, -12, -13], inf) // Slightly different low notes
	).resume;
	Ndef(\pulseBase).quant = 1; // Re-engage Pbindef, but slowly
	Ndef(\pulseBase).xset(\wet12, 0.2); // Less saturation as it's sparser
};

fork {
	200.wait; // Wait for the peak to develop and sustain
	// \sineLead dissipates
	Pbindef(\sineLeadSeq,
		\dur, Pseq([1, 2, 4, 8], inf), // Slow down
		\degree, Pseq([5, 4, 2, 0], inf) // Descend
	);
	Ndef(\sineLead).xset(\amp, 0.1); // Reduce amplitude
	Ndef(\sineLead).xset(\wet10, 0.9, \wet11, 0.8); // Maximize effects
	15.wait;
	Pbindef(\sineLeadSeq).stop; // Stop sequence
	Ndef(\sineLead).xset(\amp, 0.0); // Ensure silence
	Ndef(\sineLead).clear(4); // Clear Ndef

	// \pulseBase dissipates
	Pbindef(\pulseSeq,
		\dur, Pseq([8, 16], inf), // Even slower
		\amp, 0.05 // Very quiet
	);
	Ndef(\pulseBase).xset(\wet10, 0.9); // Maximize reverb
	10.wait;
	Pbindef(\pulseSeq).stop; // Stop sequence
	Ndef(\pulseBase).xset(\amp, 0.0); // Ensure silence
	Ndef(\pulseBase).clear(6); // Clear Ndef

	// \sinePad is the last to fade
	Pbindef(\sinePadSeq, \dur, 12, \degree, Pseq([0, -2], inf)); // Slowest chord changes, settling
	Ndef(\sinePad).xset(\lfoFreq, 0.05, \detune, 0.001); // Slower LFO, less detune
	Ndef(\sinePad).xset(\wet10, 1.0, \wet11, 0.7); // Maximize effects
	20.wait;
	Pbindef(\sinePadSeq).stop; // Stop sequence
	Ndef(\sinePad).xset(\amp, 0.0); // Ensure silence
	Ndef(\sinePad).clear(10); // Clear Ndef with a very long fade
};
)

// Source: sync-composition-example.scd
(
// =====================================================================
// 0. SAFETY FIRST: PERSISTENT MASTER LIMITER
// =====================================================================

SynthDef(\safetyLimiter, {
    var sig = In.ar(0, 2);
    // Limiter catches any peaks above 0.95 silently and transparently
    sig = Limiter.ar(sig, level: 0.95, dur: 0.01);
    ReplaceOut.ar(0, sig);
}).add;

// Ensure the limiter survives Cmd+Period and sits at the absolute tail
ServerTree.removeAll;
ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
if(s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter) };


// =====================================================================
// 1. INSTRUMENTS & EFFECTS (JITLib)
// =====================================================================

// Set fade times to dictate how long .xset crossfades will take
Ndef(\voidPad).fadeTime = 4;
Ndef(\probePulse).fadeTime = 2;
Ndef(\solarWind).fadeTime = 3;

Ndef(\voidPad, {
    |freq=40, freqMult=1, amp=0.3, t_trig=1, hpfFreq=20, lpfFreq=2000|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 3]), t_trig);
    var sig = Saw.ar([freq * freqMult, freq * freqMult * 1.01]);
    var sub = SinOsc.ar([freq * freqMult * 0.5, freq * freqMult * 0.505]);
    sig = RLPF.ar(sig + sub, lpfFreq, 0.4);
    sig = HPF.ar(sig, hpfFreq);
    sig * env * amp;
});

Ndef(\probePulse, {
    |freq=2000, freqMult=1, modFreq=500, modIndex=1, amp=0.35, t_trig=1|
    var env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
    var mod = SinOsc.ar(modFreq) * modIndex * (freq * freqMult);
    var sig = SinOsc.ar((freq * freqMult) + mod);
    Pan2.ar(sig * env * amp, 0);
});

Ndef(\solarWind, {
    |amp=0.25, t_trig=1, bpfFreq=2000, bpfMult=1, rq=0.1|
    var env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
    var sig = Array.fill(4, { PinkNoise.ar() + (WhiteNoise.ar() * 0.5) });
    // Clean resonant synthesis replacing the previous overdrive logic
    sig = BPF.ar(sig, bpfFreq * bpfMult, rq);
    Splay.ar(sig) * env * amp;
});

// Reverb (Index 10)
Ndef(\voidPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\voidPad).set(\wet10, 0);

// Delay (Index 11)
Ndef(\probePulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \decayTime.kr(0.5)) };
Ndef(\probePulse).set(\wet11, 0);


// =====================================================================
// 2. PATTERNS
// =====================================================================

Pbindef(\voidSeq, \dur, 8, \freq, Pseq([40, 42, 38, 45], inf), \t_trig, 1);
Pbindef(\probeSeq, \dur, 2, \freq, 2000, \modFreq, 500, \modIndex, 1, \t_trig, 1);
Pbindef(\solarSeq, \dur, Pwhite(0.05, 0.15), \bpfFreq, Pwhite(1000, 5000), \rq, 0.1, \t_trig, 1);

[Ndef(\voidPad), Ndef(\probePulse), Ndef(\solarWind)].do(_.quant_(1));


// =====================================================================
// 3. THE SCRIPT (Tdef - 2 Minute Score)
// =====================================================================

Tdef(\parkerScore, {

    "0:00 - [Movement I: Launch]".postln;
    Ndef(\voidPad).play;
    Ndef(\voidPad)[1] = \set -> Pbindef(\voidSeq);

    // .xset smoothly introduces the huge space reverb over 4 seconds
    Ndef(\voidPad).xset(\wet10, 0.8, \lpfFreq, 800);

    15.wait;

    "0:15 - [The Probe Activates]".postln;
    Ndef(\probePulse).play;
    Ndef(\probePulse)[1] = \set -> Pbindef(\probeSeq);

    // .set snaps the dry delay immediately for a stark contrast to the pad
    Ndef(\probePulse).set(\wet11, 0.2);

    20.wait; // Now at 0:35

    "0:35 - [Movement II: Acceleration]".postln;
    Pbindef(\probeSeq, \dur, 0.5);

    // Smoothly shift the multiplier and open up the delay tails over 2 seconds
    Ndef(\probePulse).xset(\freqMult, 1.2, \wet11, 0.6, \decayTime, 2);
    Ndef(\voidPad).xset(\hpfFreq, 150); // Slowly begin thinning the low end

    25.wait; // Now at 1:00

    "1:00 - [Movement III: Piercing the Corona]".postln;
    Pbindef(\probeSeq, \dur, 0.125, \modIndex, 4); // Instantly shift to fast, metallic pings

    Ndef(\solarWind).play;
    Ndef(\solarWind)[1] = \set -> Pbindef(\solarSeq);

    // Massive crossfade: thin the pad entirely, open up the probe delay to near-infinite
    Ndef(\voidPad).xset(\hpfFreq, 600, \lpfFreq, 4000);
    Ndef(\probePulse).xset(\wet11, 0.9, \decayTime, 6);

    30.wait; // Now at 1:30

    "1:30 - [Movement IV: Exiting to Void]".postln;
    Pbindef(\solarSeq).stop;
    Ndef(\solarWind).clear(4); // Fade out the continuous noise proxy over 4s

    Pbindef(\probeSeq, \dur, 2, \modIndex, 1);

    // Doppler effect: smooth drop in the frequency modifier and pull back the delay
    Ndef(\probePulse).xset(\freqMult, 0.8, \wet11, 0.3, \decayTime, 0.5);

    20.wait; // Now at 1:50

    "1:50 - [Telemetry Outro]".postln;
    Ndef(\voidPad).xset(\lpfFreq, 300); // Muffle the pad into darkness
    Ndef(\probePulse).xset(\freqMult, 0.5); // Final power down pitch shift

    10.wait; // Now at 2:00

    "2:00 - [Fade Out & Terminate]".postln;
    Pbindef(\voidSeq).stop;
    Pbindef(\probeSeq).stop;

    // Clear final nodes with a long, 10-second fade
    Ndef(\voidPad).clear(10);
    Ndef(\probePulse).clear(10);

    "Score Complete.".postln;
});
)

// Source: test.scd
(
Ndef(\voidPad).clear;
Ndef(\voidPad, {
	|freq=40, amp=0.3, t_trig=1, hpfFreq=20|
	var env, sig, sub;
	env = EnvGen.ar(Env([0, 1, 0.8, 0], [2, 3, 3]), t_trig);
	sig = Saw.ar([freq, freq * 1.01]);
	sub = SinOsc.ar([freq * 0.5, freq * 0.505]);
	sig = RLPF.ar(sig + sub, freq * 3, 0.4);
	sig = HPF.ar(sig, hpfFreq);
	sig * env * amp;
}).play;

Ndef(\probePulse).clear;
Ndef(\probePulse, {
	|freq=2000, modFreq=500, modIndex=1, amp=0.35, t_trig=1|
	var env, mod, sig;
	env = EnvGen.ar(Env.perc(0.005, 0.1), t_trig);
	mod = SinOsc.ar(modFreq) * modIndex * freq;
	sig = SinOsc.ar(freq + mod);
	Pan2.ar(sig * env * amp, 0);
}).play;

Ndef(\venusGravity).clear;
Ndef(\venusGravity, {
	|freq=80, sweepDur=4, amp=0.5, t_trig=1, pan=0|
	var env, sweep, sig;
	env = EnvGen.ar(Env.perc(0.1, sweepDur), t_trig);
	sweep = EnvGen.ar(Env([freq * 6, freq, freq * 0.2], [0.1, sweepDur * 0.9], \exp), t_trig);
	sig = Pulse.ar(sweep, 0.3) + Saw.ar(sweep * 1.01);
	sig = RLPF.ar(sig, sweep * 1.5, 0.2);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\solarWind).clear;
Ndef(\solarWind, {
	|amp=0.25, t_trig=1, bpfFreq=2000, rq=0.1|
	var env, sig;
	env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
	sig = Array.fill(4, { PinkNoise.ar() + (WhiteNoise.ar() * 0.5) });
	sig = BPF.ar(sig, bpfFreq, rq);
	Splay.ar(sig) * env * amp;
}).play;

// Reverb (Index 10)
Ndef(\voidPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\voidPad).set(\wet10, 0);

// Delay (Index 11)
Ndef(\probePulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \decayTime.kr(0.5)) };
Ndef(\probePulse).set(\wet11, 0);

// Distortion (Index 12)
Ndef(\solarWind)[12] = \filter -> { |in| (in * \drive.kr(5)).tanh }; // Changed to tanh for warmer, smoother saturation
Ndef(\solarWind).set(\wet12, 0);

Pbindef(\voidSeq, \dur, 8, \freq, Pseq([40, 42, 38, 45], inf), \t_trig, 1);
Pbindef(\probeSeq, \dur, 2, \freq, 2000, \modFreq, 500, \modIndex, 1, \t_trig, 1);
Pbindef(\venusSeq, \dur, 8, \freq, 80, \sweepDur, 4, \pan, Pseq([-0.8, 0.8], inf), \t_trig, 1);
Pbindef(\solarSeq, \dur, Pwhite(0.05, 0.15), \bpfFreq, Pwhite(1000, 5000), \rq, 0.1, \t_trig, 1);

// Quantization for synchronization
Ndef(\voidPad).quant = 1;
Ndef(\probePulse).quant = 1;
Ndef(\venusGravity).quant = 1;
Ndef(\solarWind).quant = 1;

// Set fade times for smooth transitions
Ndef(\voidPad).fadeTime = 3;
Ndef(\probePulse).fadeTime = 1;
Ndef(\venusGravity).fadeTime = 2;
Ndef(\solarWind).fadeTime = 2;

Pbindef(\voidSeq).stop;
Pbindef(\probeSeq).stop;
Pbindef(\venusSeq).stop;
Pbindef(\solarSeq).stop;

Ndef(\voidPad).fadeTime = 8;
Ndef(\probePulse).fadeTime = 8;
Ndef(\venusGravity).fadeTime = 8;
Ndef(\solarWind).fadeTime = 8;

Ndef(\voidPad).clear(8);
Ndef(\probePulse).clear(8);
Ndef(\venusGravity).clear(8);
Ndef(\solarWind).clear(8);

Pbindef(\probeSeq, \freq, Pn(Pwhite(1800, 2500, 8), inf)); // Introduce high-pitched, erratic blips for navigation
// Pbindef(\probeSeq, \freq, 2000); // Revert to fixed frequency

Ndef.clear;
Pbindef.clear;

Ndef(\baseTone).clear;
Ndef(\baseTone, {
	|freq=100, amp=0.4, modFreq=0.2, modIndex=0.01, pan=0|
	var mod, sig;
	// Low-frequency amplitude modulation to give a "breathing" quality
	mod = SinOsc.ar(modFreq) * modIndex;
	sig = SinOsc.ar(freq * (1 + mod)); // Carrier modulated by LFO
	Pan2.ar(sig * amp, pan);
}).play;

// Reverb for baseTone (Index 10)
Ndef(\baseTone)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\baseTone).set(\wet10, 0); // Initially dry

// Delay for baseTone (Index 11) - defined but kept dry for now
Ndef(\baseTone)[11] = \filter -> { |in, delayTime=0.4, delFeedback=0.3| CombL.ar(in, delayTime, delayTime, delFeedback) };
Ndef(\baseTone).set(\wet11, 0);

Ndef(\baseTone).fadeTime = 8; // Set fade time for smooth crossfades
Ndef(\baseTone).xset(\amp, 0.3); // Slowly fade in the base tone
// Ndef(\baseTone).xset(\amp, 0); // Revert amp
Ndef(\baseTone).xset(\wet10, 0.4); // Gently introduce spacious reverb
// Ndef(\baseTone).xset(\wet10, 0); // Revert reverb

Ndef(\harmony).clear;
Ndef(\harmony, {
	|freq=150, amp=0.2, pan=(-0.6)|
	var sig;
	sig = SinOsc.ar(freq);
	Pan2.ar(sig * amp, pan);
}).play;

// Reverb for harmony (Index 10)
Ndef(\harmony)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\harmony).set(\wet10, 0); // Initially dry

// Pbindef for baseTone - gentle arpeggiation
Pbindef(\baseSeq,
	\dur, 2, // Slow, sustained notes
	\degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf), // Arpeggiated pattern
	\scale, Scale.majorPentatonic, // Simple, consonant scale
	\root, 40, // Base MIDI note
	\legato, 1.0 // Fully sustained
);
// Assign a scale-based frequency to baseTone. The Ndef's `freq` arg will be overwritten by this.
Pbindef(\baseSeq, \freq, Pkey(\degree).midicps);
Ndef(\baseTone).quant = 1;
Ndef(\baseTone)[1] = \set -> Pbindef(\baseSeq);

// Pbindef for harmony - slow panning and consonant intervals
Pbindef(\harmonySeq,
	\dur, 4, // Even slower notes for harmony
	\degree, Pseq([4, 7, 0, 2, 0, 7, 4, 7], inf), // Consonant to base tone, but shifting
	\scale, Scale.majorPentatonic,
	\root, 47, // Offset for harmony
	\legato, 1.0,
	\pan, Pseq([-0.6, 0.6, -0.4, 0.4, -0.2, 0.2, 0, 0], inf).wrap(-0.8, 0.8) // Slow, drifting pan
);
Pbindef(\harmonySeq, \freq, Pkey(\degree).midicps);
Ndef(\harmony).quant = 1;
Ndef(\harmony)[1] = \set -> Pbindef(\harmonySeq);

Ndef(\baseTone).xset(\wet11, 0.3); // Introduce subtle, long delay on baseTone
// Ndef(\baseTone).xset(\wet11, 0); // Revert delay

Ndef(\harmony).fadeTime = 6; // Set fade time for harmony
Ndef(\harmony).xset(\amp, 0.15); // Gently fade in the harmony tone
// Ndef(\harmony).xset(\amp, 0); // Revert amp
Ndef(\harmony).xset(\wet10, 0.3); // Gently introduce reverb on harmony
// Ndef(\harmony).xset(\wet10, 0); // Revert reverb

Pbindef(\baseSeq,
	\root, 52, // Shift base tone octave up
	// \root, 40, // Revert root
	\degree, Pseq([0, 3, 5, 8, 10, 8, 5, 3], inf) // New, slightly more dissonant arpeggio
	// \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf) // Revert degree
);
Ndef(\baseTone).xset(\modIndex, 0.03); // Amplitude modulation slightly more pronounced
// Ndef(\baseTone).xset(\modIndex, 0.01); // Revert modIndex

Pbindef(\harmonySeq,
	\root, 58, // Shift harmony root to create new intervals with baseTone
	// \root, 47, // Revert root
	\degree, Pseq([5, 8, 1, 3, 1, 8, 5, 8], inf), // New harmonic intervals
	// \degree, Pseq([4, 7, 0, 2, 0, 7, 4, 7], inf), // Revert degree
	\pan, Pseq([-0.8, 0.8, -0.6, 0.6, -0.4, 0.4, -0.2, 0.2], inf).wrap(-0.9, 0.9) // Wider, slightly faster pan
	// \pan, Pseq([-0.6, 0.6, -0.4, 0.4, -0.2, 0.2, 0, 0], inf).wrap(-0.8, 0.8) // Revert pan
);
)
