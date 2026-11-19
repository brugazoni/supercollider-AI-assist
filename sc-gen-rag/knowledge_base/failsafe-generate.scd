// Source: HIGH-T-generate-resilience.scd [Block 1]
// MODE: generate
// THEME: Stereo detune expansion
// KEYWORDS: bpf, detune, expansion, fmPad, generate, ksPluck, noisePerc, sinosc, stereo, whitenoise
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
)

// Source: append-arroio.scd [Block 1]
// MODE: generate
// THEME: Archetype: Exposition / Settling into delicate organic emergence
// KEYWORDS: archetype, arroio, bpf, delicate, emergence, exposition, freeverb2, generate, hpf, into, latidos, latidosSeq, organic, rlpf, rosaPad, rosaSeq, saw, settling, sinosc
(
// === ARROIO, CHUVISCO, LATIDOS AO LONGE, VIDA NOVA AO ROSA ===
// Archetype: Exposition / Settling into delicate organic emergence

// 1. Arroio sussurra & chuvisco: Whispering stream, gentle filtered fluid turbulence and drizzle
Ndef(\arroio, { |amp=0.28, lpf=3600|
    var noise = PinkNoise.ar(0.35) + BrownNoise.ar(0.2);
    var streamLow = BPF.ar(noise, LFNoise1.kr(0.8!2).range(350, 950), 0.2) * 4.5;
    var streamHigh = BPF.ar(noise, LFNoise2.kr(2.5!2).range(1100, 2900), 0.1) * 5.0;
    var chuvisco = Dust2.ar(LFNoise1.kr(0.4).range(18, 55)!2) * 0.14;
    var sig = LPF.ar(streamLow + streamHigh + chuvisco, lpf);
    sig * amp;
}).play;

// 2. Latidos ao longe: Muffled organic bark-like calls echoing in the far distance
Ndef(\latidos, { |freq=150, amp=0.22, t_trig=0, pan=(-0.4), distCut=850|
    var env = EnvGen.ar(Env.perc(0.015, 0.22, curve: -4), t_trig);
    var pitchEnv = EnvGen.ar(Env([1.9, 1.0, 0.75], [0.035, 0.18], \exp), t_trig);
    var osc = SinOscFB.ar(freq * pitchEnv, 0.75) + Pulse.ar(freq * 0.5 * pitchEnv, 0.35, 0.4);
    var filtered = LPF.ar(HPF.ar(osc, 100), distCut);
    var sig = LeakDC.ar(filtered * env);
    Pan2.ar(sig * amp, pan);
}).play;

// Distant spatial blur for the barks
Ndef(\latidos)[10] = \filter -> { |in|
    CombC.ar(LPF.ar(in, 1000), 0.6, [0.36, 0.44], 3.2);
};
Ndef(\latidos).set(\wet10, 0.65);

Pbindef(\latidosSeq,
    \dur, Pseq([4.0, 0.28, 5.2, 0.22, 0.3, 6.0], inf),
    \freq, Pseq([145, 160, 138, 170, 155, 140], inf),
    \distCut, Pwhite(650, 1050, inf),
    \pan, Pwhite(-0.7, -0.3, inf),
    \amp, Pwhite(0.18, 0.26, inf),
    \t_trig, 1
);
Ndef(\latidos)[1] = \set -> Pbindef(\latidosSeq);

// 3. Vida nova, ao rosa: Luminous, warm pastel harmonic pad blooming like dawn light
Ndef(\rosaPad, { |freq=220, amp=0.2, t_trig=0, pan=0, cutoff=1800, rq=0.45|
    var env = EnvGen.ar(Env.linen(1.5, 3.0, 2.8, curve: \sin), t_trig);
    var lfo = SinOsc.kr([0.18, 0.27, 0.13, 0.35]).range(-1.2, 1.2);
    var osc = Splay.ar(Saw.ar(freq * [0.994, 1.0, 1.007, 2.002] + lfo));
    var sub = SinOsc.ar(freq * 0.5) * 0.35;
    var sig = RLPF.ar(osc + sub, cutoff.clip(250, 9000), rq);
    Balance2.ar(sig[0], sig[1], pan, amp * env);
}).play;

// Gentle shimmer reverb for the rose dawn pad
Ndef(\rosaPad)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.25);
};
Ndef(\rosaPad).set(\wet10, 0.45);

Pbindef(\rosaSeq,
    \dur, Pseq([5.5, 4.5, 6.0, 4.0], inf),
    \midinote, Pseq([49, 53, 56, 58, 61, 65], inf), // Warm Db major / F minor tenderness
    \cutoff, Pwhite(1200, 2600, inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \amp, 0.22,
    \t_trig, 1
);
Ndef(\rosaPad)[1] = \set -> Pbindef(\rosaSeq);
)

// Source: append-baru-volcano-FIXED.scd [Block 1]
// MODE: generate
// THEME: 1. Volcanic Tectonic Rumble
// KEYWORDS: baruBase, baruCanopy, bpf, dynklank, generate, leakdc, pinknoise, rumble, sinosc, tectonic, volcanic, whitenoise
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

// Source: append-elephant.scd [Block 2]
// MODE: generate
// THEME: The "Elephant": Heavy, low-frequency, saturated analog-style bass
// KEYWORDS: analog, bass, bpf, elephant, elephantSeq, frequency, generate, heavy, leakdc, low, moogff, perch, perchSeq, saturated, saw, sinosc, style, the, whitenoise
(
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
)

// Source: append-elephant.scd [Block 3]
// MODE: generate
// THEME: 1. SOUND SOURCES (Ndefs)
// KEYWORDS: bpf, chemTouch, freeverb, generate, kickSeq, ndefs, pulse, saw, sinosc, slapKick, sources, strokeSeq, touchSeq, trunkStroke, whitenoise
(
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
)

// Source: append-gallium.scd [Block 1]
// MODE: generate
// THEME: 1. Bauxite & Zinc Ore Drone: Soft, warm, but metallic-tinted background
// KEYWORDS: background, bauxite, bauxiteDrone, bpf, but, drone, freeverb, galliumGlass, generate, glassSeq, metallic, ore, ringz, saw, soft, tinted, warm, whitenoise, zinc
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
)

// Source: auto-append-arppegio.scd [Block 3]
// MODE: generate
// THEME: Set a driving electronic tempo
// KEYWORDS: bpf, driving, electronic, generate, hat, hpf, kick, seqHat, seqKick, seqSnare, set, sinosc, snare, tempo, whitenoise
(
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
)

// Source: auto-append-bosque.scd [Block 1]
// MODE: generate
// THEME: The "bed of grass and crushed flowers" - a textured, low, warm pad with organic noise
// KEYWORDS: bed, bpf, crushed, emptyForest, flowers, forestSeq, freeverb, generate, grass, grassBed, grassSeq, low, noise, organic, pad, pinknoise, rlpf, saw, sinosc, textured, the, warm
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
)

// Source: auto-append-bosque.scd [Block 2]
// MODE: generate
// THEME: 1. The Meadow (Warm, sun-drenched drone and chordal bed)
// KEYWORDS: bed, chordal, drenched, drone, freeverb, generate, hpf, meadow, meadowSeq, nightingale, nightingaleSeq, pulse, rlpf, saw, sinosc, sun, the, warm
(
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
)

// Source: auto-append-bosque.scd [Block 4]
// MODE: generate
// THEME: 1. Define Pad Instrument (Deep, slow analog emulation)
// KEYWORDS: analog, deep, define, emulation, generate, instrument, pad, padSeq, plink, plinkSeq, pulse, saw, slow
(
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

// Source: auto-append-coracao-avesso.scd [Block 1]
// MODE: generate
// THEME: 1. Coração pelo avesso (Heart inside out) - Heavy, distorted, asymmetrical heartbeat
// KEYWORDS: asymmetrical, avesso, bpf, breezeSeq, cora, distorted, fireBreeze, generate, heart, heartSeq, heartbeat, heavy, hpf, inside, leakdc, moonBurn, moonSeq, out, pelo, pinknoise, ringz, sinosc
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

// Source: auto-append-jardim.scd [Block 1]
// MODE: generate
// THEME: Dreamy, elegant harmonic series (E major / C# minor feel)
// KEYWORDS: dreamy, dynklank, elegant, feel, fold, garden, generate, harmonic, hpf, leakdc, major, minor, pinknoise, series, sinosc, steps, stepsSeq
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

// Source: auto-append-rimbaud.scd [Block 1]
// MODE: generate
// THEME: Deep flowing blue moat ("Lá embaixo escorre o fosso azul...")
// KEYWORDS: azul, blue, bpf, citadel, citadelSeq, deep, dynklank, embaixo, escorre, flowing, fosso, generate, leakdc, moat, pinknoise, sinosc
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
)

// Source: auto-append-rimbaud.scd [Block 3]
// MODE: generate
// THEME: 1. "Verdura, campos e pastos" - A lush, evolving background flora drone
// KEYWORDS: background, campos, drone, engraving, evolving, flora, generate, greenery, lush, moogff, pastos, pinknoise, pulse, saw, seqEngraving, seqGreenery, sinosc, verdura
(
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
)

// Source: auto-append-rimbaud.scd [Block 5]
// MODE: generate
// THEME: ADD_INSTRUMENT: Ndef(\cyclone) - The Red Cyclone (Ciclone Rubro)
// KEYWORDS: add, ciclone, cyclone, cycloneSeq, generate, instrument, moogff, ndef, pinknoise, red, rubro, saw, sinosc, the
(
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
)

// Source: auto-append-rimbaud.scd [Block 7]
// MODE: generate
// THEME: 1. Sound Sources
// KEYWORDS: bpf, cave, dripSeq, drips, drone, freeverb2, generate, hpf, pinknoise, ringz, sinosc, sources
(
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
)

// Source: composition-constantinople.scd [Block 2]
// MODE: generate
// THEME: Additive/Subtractive blend: rich saw for filtering, deep sine for sub
// KEYWORDS: additive, blend, bpf, celestialVoid, combl, crumbleTexture, deep, filtering, for, generate, gverb, hpf, omenChime, rich, rlpf, saw, sine, sub, subtractive
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
)

// Source: composition-day-in-three-minutes.scd [Block 2]
// MODE: generate
// THEME: 1. INSTRUMENTS & EFFECTS (JITLib)
// KEYWORDS: bpf, brassSaw, choirFM, dynklank, effects, fireNoise, generate, hpf, instruments, jitlib, rlpf, saw, sinosc, skyAnomaly, warDrum
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
)

// Source: composition-haideng.scd [Block 1]
// MODE: generate
// THEME: Additive synthesis bell-tone (frail, wavering)
// KEYWORDS: additive, bell, breathSeq, chanSeq, cloudSeq, combl, emptyCloud, fingerChan, frail, frailBreath, freeverb, generate, gverb, hpf, rlpf, sinosc, synthesis, tone, wavering
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
)

// Source: flamenco.scd [Block 2]
// MODE: generate
// THEME: Use WhiteNoise with BPF for a more organic, woody tap sound
// KEYWORDS: bpf, cajonKick, dynklank, for, generate, golpe, more, organic, pinknoise, tap, use, whitenoise, woody
(
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
)

// Source: flamenco.scd [Block 5]
// MODE: generate
// THEME: BandPassFilter WhiteNoise for a sharp snare-like sound
// KEYWORDS: bandpassfilter, bass, bpf, cajonSnare, for, generate, hpf, like, palmas, rasgueado, sharp, sinosc, snare, whitenoise
(
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
)

// Source: flamenco.scd [Block 12]
// MODE: generate
// THEME: Mix of detuned sine waves for a lush pad
// KEYWORDS: detuned, for, generate, lush, melodiaFree, mix, pad, pads, sine, sinosc, waves
(
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
)

// Source: gemini-composition-hummingbird.scd [Block 1]
// MODE: generate
// THEME: Establish fade times for smooth .xset parameter sweeps
// KEYWORDS: birdWings, bpf, canopyPad, combl, dynklank, establish, fade, for, generate, gverb, hpf, nectarNest, parameter, rlpf, serpentThreat, smooth, sweeps, times, xset
(
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
)

// Source: generate-craterlake.scd [Block 1]
// MODE: generate
// THEME: LFTri provides harmonics for the filter, SinOsc provides foundational sub
// KEYWORDS: bpf, deepBass, filter, for, foundational, generate, harmonics, icyShimmer, islandBell, lftri, phantomPulse, provides, rlpf, saw, sinosc, sub, the, waterPad, whitenoise
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
)

// Source: new-test.scd [Block 1]
// MODE: generate
// THEME: --- OSCILLATOR TEST PATCH INSTRUMENTS ---
// KEYWORDS: generate, instruments, osc1, osc2, oscillator, patch, pulse, saw, test
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
)

// Source: oscillators.scd [Block 2]
// MODE: generate
// THEME: --- INSTRUMENTS ---
// KEYWORDS: fmSynth, generate, instruments, kick, pulse, pulseRhythm, rlpf, saw, sawLead, sinosc, whitenoise
(
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
)

// Source: 2026-09-16_15-51-09.scd [Block 1]
// MODE: generate
// THEME: Archetype: Exposition / Settling into delicate organic emergence
// KEYWORDS: archetype, arroio, bpf, delicate, emergence, exposition, freeverb2, generate, hpf, into, latidos, latidosSeq, organic, rlpf, rosaPad, rosaSeq, saw, settling, sinosc
(
// === ARROIO, CHUVISCO, LATIDOS AO LONGE, VIDA NOVA AO ROSA ===
// Archetype: Exposition / Settling into delicate organic emergence

// 1. Arroio sussurra & chuvisco: Whispering stream, gentle filtered fluid turbulence and drizzle
Ndef(\arroio, { |amp=0.28, lpf=3600|
    var noise = PinkNoise.ar(0.35) + BrownNoise.ar(0.2);
    var streamLow = BPF.ar(noise, LFNoise1.kr(0.8!2).range(350, 950), 0.2) * 4.5;
    var streamHigh = BPF.ar(noise, LFNoise2.kr(2.5!2).range(1100, 2900), 0.1) * 5.0;
    var chuvisco = Dust2.ar(LFNoise1.kr(0.4).range(18, 55)!2) * 0.14;
    var sig = LPF.ar(streamLow + streamHigh + chuvisco, lpf);
    sig * amp;
}).play;

// 2. Latidos ao longe: Muffled organic bark-like calls echoing in the far distance
Ndef(\latidos, { |freq=150, amp=0.22, t_trig=0, pan=(-0.4), distCut=850|
    var env = EnvGen.ar(Env.perc(0.015, 0.22, curve: -4), t_trig);
    var pitchEnv = EnvGen.ar(Env([1.9, 1.0, 0.75], [0.035, 0.18], \exp), t_trig);
    var osc = SinOscFB.ar(freq * pitchEnv, 0.75) + Pulse.ar(freq * 0.5 * pitchEnv, 0.35, 0.4);
    var filtered = LPF.ar(HPF.ar(osc, 100), distCut);
    var sig = LeakDC.ar(filtered * env);
    Pan2.ar(sig * amp, pan);
}).play;

// Distant spatial blur for the barks
Ndef(\latidos)[10] = \filter -> { |in|
    CombC.ar(LPF.ar(in, 1000), 0.6, [0.36, 0.44], 3.2);
};
Ndef(\latidos).set(\wet10, 0.65);

Pbindef(\latidosSeq,
    \dur, Pseq([4.0, 0.28, 5.2, 0.22, 0.3, 6.0], inf),
    \freq, Pseq([145, 160, 138, 170, 155, 140], inf),
    \distCut, Pwhite(650, 1050, inf),
    \pan, Pwhite(-0.7, -0.3, inf),
    \amp, Pwhite(0.18, 0.26, inf),
    \t_trig, 1
);
Ndef(\latidos)[1] = \set -> Pbindef(\latidosSeq);

// 3. Vida nova, ao rosa: Luminous, warm pastel harmonic pad blooming like dawn light
Ndef(\rosaPad, { |freq=220, amp=0.2, t_trig=0, pan=0, cutoff=1800, rq=0.45|
    var env = EnvGen.ar(Env.linen(1.5, 3.0, 2.8, curve: \sin), t_trig);
    var lfo = SinOsc.kr([0.18, 0.27, 0.13, 0.35]).range(-1.2, 1.2);
    var osc = Splay.ar(Saw.ar(freq * [0.994, 1.0, 1.007, 2.002] + lfo));
    var sub = SinOsc.ar(freq * 0.5) * 0.35;
    var sig = RLPF.ar(osc + sub, cutoff.clip(250, 9000), rq);
    Balance2.ar(sig[0], sig[1], pan, amp * env);
}).play;

// Gentle shimmer reverb for the rose dawn pad
Ndef(\rosaPad)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.25);
};
Ndef(\rosaPad).set(\wet10, 0.45);

Pbindef(\rosaSeq,
    \dur, Pseq([5.5, 4.5, 6.0, 4.0], inf),
    \midinote, Pseq([49, 53, 56, 58, 61, 65], inf), // Warm Db major / F minor tenderness
    \cutoff, Pwhite(1200, 2600, inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \amp, 0.22,
    \t_trig, 1
);
Ndef(\rosaPad)[1] = \set -> Pbindef(\rosaSeq);
)

// Source: 2026-10-07_11-27-02.scd [Block 4]
// MODE: generate
// THEME: - 0:6:12.94 -
// KEYWORDS: bpf, choirHigh, choirLow, generate, hpf, pulse, saw, sinosc
(
Ndef(\choirHigh).ar(2);
Ndef(\choirLow).ar(2);

Ndef(\choirHigh, {
	|f1=293.66, f2=349.23, f3=440.00, f4=587.33, amp=0.18, atk=0.15, sus=1.8, rel=1.0,
	formant1=450, formant2=800, formant3=2400, rq=0.12, vibRate=5.2, vibDepth=0.012, t_trig=1|
	var env, vib, freqs, oscs, formants, sig;
	env = EnvGen.ar(Env([0, 1, 0.85, 0], [atk, sus, rel], [\sine, \sine, -4]), t_trig);
	vib = SinOsc.kr(vibRate + LFNoise2.kr(1.0).bipolar(0.3)) * vibDepth;
	freqs = [f1, f2, f3, f4] * (1 + vib);
	oscs = freqs.collect({ |f|
		(Saw.ar(f * [0.998, 1.002]) * 0.6) + (Pulse.ar(f, 0.42) * 0.4)
	}).flat;
	formants = [formant1, formant2, formant3].collect({ |fForm|
		BPF.ar(oscs, fForm, rq) * 2.8
	}).sum;
	sig = HPF.ar(formants, 220);
	Splay.ar(sig) * env * amp;
}).play;

Ndef(\choirLow, {
	|f1=73.42, f2=110.00, amp=0.22, atk=0.2, sus=1.8, rel=1.2,
	formant1=350, formant2=650, formant3=2200, rq=0.15, vibRate=4.8, vibDepth=0.008, subAmp=0.35, t_trig=1|
	var env, vib, freqs, oscs, sub, formants, sig;
	env = EnvGen.ar(Env([0, 1, 0.9, 0], [atk, sus, rel], [\sine, \sine, -4]), t_trig);
	vib = SinOsc.kr(vibRate + LFNoise2.kr(0.8).bipolar(0.2)) * vibDepth;
	freqs = [f1, f2] * (1 + vib);
	oscs = freqs.collect({ |f|
		Saw.ar(f * [0.999, 1.001])
	}).flat;
	sub = SinOsc.ar(f1 * 0.5) * subAmp;
	formants = [formant1, formant2, formant3].collect({ |fForm|
		BPF.ar(oscs, fForm, rq) * 2.4
	}).sum;
	sig = (formants.sum * 0.7) + sub;
	sig = LPF.ar(sig, 3800);
	Pan2.ar(sig * env * amp, 0);
}).play;
)

// Source: 2026-11-04_12-01-59.scd [Block 4]
// MODE: generate
// THEME: - 0:8:50.71 -
// KEYWORDS: bpf, combl, coral, coralSeq, costas, dynklank, freeverb, generate, hpf, meseta, mesetaSeq, moogff, pireneus
(
// --- PENÍNSULA IBÉRICA INSTRUMENTS ---
Ndef(\pireneus, {
	|freq=55, cutoff=260, rq=0.35, noiseLevel=0.06, amp=0.35, pan=0|
	var detune, osc1, osc2, lfo, wind, filter, sig;
	detune = LFNoise2.kr(0.08).bipolar(0.008);
	osc1 = Saw.ar(freq * (1 + detune));
	osc2 = Saw.ar((freq * 0.5) * (1 - detune));
	lfo = LFNoise2.kr(0.12).exprange(cutoff * 0.6, cutoff * 1.7);
	wind = PinkNoise.ar(noiseLevel) * LFNoise1.kr(0.25).range(0.2, 1.0);
	sig = osc1 + osc2 + wind;
	filter = MoogFF.ar(sig, lfo.clip(30, 3500), rq * 3.0);
	filter = LeakDC.ar(filter.tanh);
	Pan2.ar(filter * amp, pan);
}).play;
Ndef(\costas, {
	|amp=0.25, swellRate=0.07, centerFreq=600, rq=0.75|
	var swellL, swellR, noise, bpf, brf, sig;
	swellL = SinOsc.kr(swellRate).range(0.25, 1.0);
	swellR = SinOsc.kr(swellRate, pi * 0.5).range(0.25, 1.0);
	noise = BrownNoise.ar([swellL, swellR]);
	brf = BRF.ar(noise, LFNoise1.kr([0.08, 0.11]).exprange(centerFreq * 0.5, centerFreq * 1.5), rq);
	bpf = BPF.ar(noise, LFNoise2.kr([0.06, 0.09]).exprange(180, 1100), 0.5) * 2.2;
	sig = (brf * 0.6) + (bpf * 0.4);
	sig = LeakDC.ar(sig);
	sig * amp;
}).play;
Ndef(\coral, {
	|freq=146.83, amp=0.32, t_trig=1, atk=0.45, sus=2.7, rel=0.65,
	 vPhase=0.5, vibratoDepth=0.006, vibratoRate=4.5, brightness=1.0|
	var env, vib, f0, chords, osc, vowelO, vowelA, vowelE, formants, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel], \sin), t_trig);
	vib = SinOsc.kr(vibratoRate).bipolar(vibratoDepth);
	f0 = freq * (1 + vib);
	chords = [f0 * 0.5, f0, f0 * 1.5, f0 * 2.0, f0 * 2.5];
	osc = chords.collect({ |f|
		(Saw.ar(f) * 0.5) + (Pulse.ar(f * 1.002, 0.42) * 0.5)
	});
	vowelO = [500, 900, 2400];
	vowelA = [800, 1200, 2500];
	vowelE = [400, 2000, 2600];
	formants = [0, 1, 2].collect({ |i|
		var fForm = SelectX.kr(vPhase * 2, [vowelO[i], vowelA[i], vowelE[i]]) * brightness;
		BPF.ar(osc, fForm, 0.12) * 3.5;
	}).sum;
	sig = Splay.ar(formants);
	sig = HPF.ar(sig, 120);
	sig = LeakDC.ar(sig);
	sig * env * amp;
}).play;
Ndef(\meseta, {
	|freq=220, amp=0.22, t_trig=1, decayscale=1.1, pan=0, ringMod=0.25|
	var env, exciter, modalFreqs, modalAmps, modalRings, sig, rmod;
	env = EnvGen.ar(Env.perc(0.002, 0.08), t_trig);
	exciter = (WhiteNoise.ar(0.35) + Dust.ar(40, 0.25)) * env;
	modalFreqs = [freq, freq * 2.02, freq * 3.01, freq * 4.45, freq * 5.82];
	modalAmps = [0.4, 0.25, 0.2, 0.1, 0.05];
	modalRings = [0.8, 0.6, 0.4, 0.25, 0.15];
	sig = DynKlank.ar(
		`[modalFreqs, modalAmps, modalRings],
		exciter,
		freqscale: 1,
		freqoffset: 0,
		decayscale: decayscale
	);
	rmod = sig * SinOsc.ar(freq * 0.5) * ringMod;
	sig = (sig * (1 - (ringMod * 0.5))) + rmod;
	sig = LeakDC.ar(sig);
	Pan2.ar(sig * amp, pan);
}).play;

// --- PENÍNSULA IBÉRICA EFFECTS ---

// Coral Reverb (Stone Cathedral Nave)
Ndef(\coral)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.88, 0.25) };
Ndef(\coral).set(\wet10, 0.45);

// Coral Saturation (Warm Choral Tape Compression)
Ndef(\coral)[12] = \filter -> { |in| (in * 1.4).fold2(0.85) };
Ndef(\coral).set(\wet12, 0.15);

// Meseta Dry Reverb
Ndef(\meseta)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.5, 0.3) };
Ndef(\meseta).set(\wet10, 0.1);

// Meseta Spatial Echo Delay
Ndef(\meseta)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 2.0) };
Ndef(\meseta).set(\wet11, 0.35);

// Pirenéus Vast Mountain Decay
Ndef(\pireneus)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.15) };
Ndef(\pireneus).set(\wet10, 0.25);

// Costas Oceanic Diffuse Reverb
Ndef(\costas)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8, 0.4) };
Ndef(\costas).set(\wet10, 0.2);

// --- PENÍNSULA IBÉRICA SEQUENCES ---

[Ndef(\coral), Ndef(\meseta), Ndef(\pireneus), Ndef(\costas)].do(_.quant_(1));

Pbindef(\coralSeq,
	\dur, Pn(Pseq([4.0, 4.0, 2.0, 2.0, 4.0, 2.0, 2.0, 4.0], 1), inf),
	\freq, Pn(Pseq([146.83, 155.56, 174.61, 146.83, 196.00, 174.61, 155.56, 146.83], 1), inf),
	\vPhase, Pn(Pseq([0.1, 0.5, 0.85, 0.5, 0.0, 0.7, 0.35, 0.5], 1), inf),
	\atk, 0.4,
	\sus, Pkey(\dur) * 0.75,
	\rel, 0.65,
	\t_trig, 1
);
Ndef(\coral)[1] = \set -> Pbindef(\coralSeq);

Pbindef(\mesetaSeq,
	\dur, Pn(Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], 1), inf),
	\freq, Pn(Pseq([293.66, 311.13, 349.23, 311.13, 392.00, 349.23, 293.66, 440.00, 392.00, 311.13, 293.66, 220.00], 1), inf),
	\pan, Pn(Pseq([-0.15, 0.15, -0.05, 0.1, -0.2, 0.2], 1), inf),
	\decayscale, Pwhite(0.8, 1.5, inf),
	\t_trig, 1
);
Ndef(\meseta)[1] = \set -> Pbindef(\mesetaSeq);
)

// Source: 2026-11-16_20-29-00.scd [Block 2]
// MODE: generate
// THEME: Layer 1: restrained sub-harmonic pulse, a steady ground beneath the claim
// KEYWORDS: beneath, bpf, claim, freeverb2, generate, ground, harmonic, hpf, pasmoSub, pasmoSubSeq, pasmoTicks, pasmoTicksSeq, pasmoVoice, pasmoVoiceSeq, pulse, restrained, saw, sinosc, steady, sub, the
(
// Layer 1: restrained sub-harmonic pulse, a steady ground beneath the claim
 Ndef(\pasmoSub, {
  |freq=55, amp=0.16, pan=0, t_trig=0, rel=1.8|
  var env, tone, drift;
  env = EnvGen.kr(Env.perc(0.08, rel, 1, -4), t_trig);
  drift = SinOsc.kr(0.07).range(0.97, 1.03);
  tone = SinOsc.ar(freq * drift) + (SinOsc.ar(freq * 2 * drift) * 0.38);
  Pan2.ar(tone * env, pan, amp);
 }).fadeTime = 4;
 Ndef(\pasmoSub).play;
 Ndef(\pasmoSub)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.32, 0.45)
 };
 Ndef(\pasmoSub).set(\wet10, 0.18);
 Pbindef(\pasmoSubSeq,
  \freq, Pseq([55, 55, 49, 55, 62, 55, 49, 52], inf),
  \dur, Pseq([1, 0.75, 1.25, 0.5, 1, 0.75, 1.5, 0.5], inf),
  \rel, Pwhite(1.1, 2.2, inf),
  \amp, 0.15, \pan, 0, \t_trig, 1
 );
 Ndef(\pasmoSub).quant = 1;
 Ndef(\pasmoSub)[1] = \set -> Pbindef(\pasmoSubSeq);

 // Layer 2: dry, irregular ticks; the pulse refuses to perform astonishment
 Ndef(\pasmoTicks, {
  |freq=420, amp=0.12, pan=(-0.25), t_trig=0, decay=0.09, cutoff=3200|
  var env, body, click;
  env = EnvGen.kr(Env.perc(0.002, decay, 1, -7), t_trig);
  body = (Pulse.ar(freq, 0.34) * 0.55) + (WhiteNoise.ar * 0.12);
  click = HPF.ar(body, 180) * env;
  Pan2.ar(LPF.ar(click, cutoff), pan, amp);
 }).fadeTime = 2;
 Ndef(\pasmoTicks).play;
 Ndef(\pasmoTicks)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.18, 0.35)
 };
 Ndef(\pasmoTicks).set(\wet10, 0.12);
 Pbindef(\pasmoTicksSeq,
  \freq, Pseq([420, 630, 470, 840, 520, 390, 760, 560], inf),
  \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.18, 0.38, 0.12], inf),
  \decay, Pwhite(0.035, 0.12, inf),
  \cutoff, Pwhite(2100, 4600, inf),
  \pan, Pwhite(-0.65, 0.65, inf),
  \amp, 0.11, \t_trig, 1
 );
 Ndef(\pasmoTicks).quant = 1;
 Ndef(\pasmoTicks)[1] = \set -> Pbindef(\pasmoTicksSeq);

 // Layer 3: a formant-like voice, clear syllabic shapes edged by instability
 Ndef(\pasmoVoice, {
  |freq=146.83, amp=0.13, pan=0.1, t_trig=0, vowel=0, rel=0.48, cutoff=4200|
  var env, source, formants, voiced, wobble;
  env = EnvGen.kr(Env.perc(0.025, rel, 1, -3), t_trig);
  wobble = SinOsc.kr(0.19).range(0.992, 1.008);
  source = (Saw.ar(freq * wobble) * 0.52) + (Pulse.ar(freq * 0.5, 0.42) * 0.28);
  formants = SelectX.kr(vowel, [[700, 1200, 2550], [480, 980, 2150], [360, 760, 1850]]);
  voiced = BPF.ar(source, formants, 0.16).sum * 5.0;
  Pan2.ar(LPF.ar(voiced, cutoff) * env, pan, amp);
 }).fadeTime = 3;
 Ndef(\pasmoVoice).play;
 Ndef(\pasmoVoice)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.46, 0.62)
 };
 Ndef(\pasmoVoice).set(\wet10, 0.28);
 Pbindef(\pasmoVoiceSeq,
  \freq, Pseq([146.83, 164.81, 196, 174.61, 130.81, 146.83, 220, 164.81], inf),
  \dur, Pseq([1.5, 0.75, 1, 0.5, 1.75, 0.75, 1.25, 0.5], inf),
  \vowel, Pseq([0, 0, 1, 1, 2, 0, 2, 1], inf),
  \rel, Pwhite(0.32, 0.72, inf),
  \pan, Pwhite(-0.35, 0.35, inf),
  \cutoff, Pwhite(3100, 5400, inf),
  \amp, 0.12, \t_trig, 1
 );
 Ndef(\pasmoVoice).quant = 1;
 Ndef(\pasmoVoice)[1] = \set -> Pbindef(\pasmoVoiceSeq);

 // Live tweaks and rollbacks
 // Ndef(\pasmoVoice).xset(\cutoff, 5600); // Open the voice | Revert: Ndef(\pasmoVoice).xset(\cutoff, 4200);
 // Pbindef(\pasmoTicksSeq, \dur, 0.125); // Tighten the pulse | Revert: Pbindef(\pasmoTicksSeq, \dur, 0.375);
 // Pbindef(\pasmoSubSeq).stop; Ndef(\pasmoSub).fadeTime = 4; Ndef(\pasmoSub).clear(4); // Rollback sub
 // Pbindef(\pasmoTicksSeq).stop; Ndef(\pasmoTicks).fadeTime = 4; Ndef(\pasmoTicks).clear(4); // Rollback ticks
 // Pbindef(\pasmoVoiceSeq).stop; Ndef(\pasmoVoice).fadeTime = 4; Ndef(\pasmoVoice).clear(4); // Rollback voice
)

// Source: 2026-11-16_20-29-00.scd [Block 3]
// MODE: generate
// THEME: Camada 1: chão profundo, húmus e terra sob a cama de grama
// KEYWORDS: bosqueEstalos, bosqueEstalosSeq, bosqueHumus, bosqueHumusSeq, bosquePetalas, bosquePetalasSeq, bpf, cama, camada, freeverb2, generate, grama, hpf, mus, pinknoise, profundo, saw, sinosc, sob, terra
(
// Camada 1: chão profundo, húmus e terra sob a cama de grama
Ndef(\bosqueHumus).fadeTime = 5;
Ndef(\bosqueHumus, {
    |freq=55, amp=0.16, pan=(-0.2), cutoff=260, t_trig=1|
    var env, drift, tone, sub;
    env = EnvGen.kr(Env.perc(0.8, 7.0, 1, -4), t_trig);
    drift = SinOsc.kr(0.07).range(0.94, 1.06);
    tone = LPF.ar(
        (Saw.ar(freq * drift) * 0.018) +
        (SinOsc.ar(freq * 2 * drift) * 0.045),
        cutoff + SinOsc.kr(0.11).range(0, 90)
    );
    sub = tone * env * amp;
    Pan2.ar(sub, pan);
}).play;

Ndef(\bosqueHumus)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.38, 0.52)
};
Ndef(\bosqueHumus).set(\wet10, 0.22);

Pbindef(\bosqueHumusSeq,
    \freq, Pseq([43.65, 55, 65.41, 49], inf),
    \amp, Pwhite(0.11, 0.17, inf),
    \pan, Pwhite(-0.35, 0.25, inf),
    \cutoff, Pwhite(190, 340, inf),
    \dur, Pwrand([2, 3, 4], [0.45, 0.35, 0.2], inf),
    \t_trig, 1
);
Ndef(\bosqueHumus).quant = 1;
Ndef(\bosqueHumus)[1] = \set -> Pbindef(\bosqueHumusSeq);

// Camada 2: sementes, gravetos e flores esmagadas em pequenos estalos
Ndef(\bosqueEstalos).fadeTime = 2;
Ndef(\bosqueEstalos, {
    |freq=420, amp=0.12, pan=0, t_trig=1|
    var env, click, body, shimmer;
    env = EnvGen.kr(Env.perc(0.003, 0.19, 1, -6), t_trig);
    click = Decay2.ar(K2A.ar(t_trig), 0.002, 0.045);
    body = (WhiteNoise.ar(0.16) * click) +
        (SinOsc.ar(freq, 0, 0.12) * env);
    shimmer = HPF.ar(body, 900) * 0.55;
    Pan2.ar((body + shimmer) * amp, pan);
}).play;

Ndef(\bosqueEstalos)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.2, 0.38)
};
Ndef(\bosqueEstalos).set(\wet10, 0.14);

Pbindef(\bosqueEstalosSeq,
    \freq, Pseq([330, 440, 523.25, 392, 659.25, 349.23], inf),
    \amp, Pwhite(0.07, 0.13, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.35, 0.17], inf),
    \t_trig, 1
);
Ndef(\bosqueEstalos).quant = 1;
Ndef(\bosqueEstalos)[1] = \set -> Pbindef(\bosqueEstalosSeq);

// Camada 3: tênues ressonâncias florais, sem brilho mágico
Ndef(\bosquePetalas).fadeTime = 4;
Ndef(\bosquePetalas, {
    |freq=261.63, amp=0.11, pan=0.35, t_trig=1|
    var env, mod, voice, air, sway;
    env = EnvGen.kr(Env.perc(0.015, 1.8, 1, -3), t_trig);
    sway = SinOsc.kr(0.09).range(0.985, 1.015);
    mod = SinOsc.ar(freq * 2.71, 0, freq * 0.12 * env);
    voice = SinOsc.ar((freq * sway) + mod) * 0.7;
    voice = voice + (SinOsc.ar(freq * 1.503 * sway) * 0.2 * env);
    air = BPF.ar(PinkNoise.ar(0.025), freq * 3.2, 0.45);
    Pan2.ar((voice * env + air * env) * amp, pan);
}).play;

Ndef(\bosquePetalas)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.48, 0.68)
};
Ndef(\bosquePetalas).set(\wet10, 0.25);

Pbindef(\bosquePetalasSeq,
    \freq, Pseq([261.63, 293.66, 349.23, 392, 329.63, 293.66], inf),
    \amp, Pwhite(0.075, 0.12, inf),
    \pan, Pwhite(-0.65, 0.65, inf),
    \dur, Pwrand([1, 1.5, 2], [0.45, 0.35, 0.2], inf),
    \t_trig, 1
);
Ndef(\bosquePetalas).quant = 1;
Ndef(\bosquePetalas)[1] = \set -> Pbindef(\bosquePetalasSeq);

// Ajustes ao vivo e reversões
// Ndef(\bosqueHumus).xset(\cutoff, 420); // Abrir o chão | Revert: Ndef(\bosqueHumus).xset(\cutoff, 260);
// Pbindef(\bosqueEstalos, \dur, 0.25); // Mais movimento | Revert: Pbindef(\bosqueEstalos, \dur, 0.5);
// Ndef(\bosqueHumus).fadeTime = 4; Ndef(\bosqueHumus).clear(4); // Rollback
// Ndef(\bosqueEstalos).fadeTime = 4; Ndef(\bosqueEstalos).clear(4); // Rollback
// Ndef(\bosquePetalas).fadeTime = 4; Ndef(\bosquePetalas).clear(4); // Rollback
)

// Source: 2026-11-16_20-29-00.scd [Block 6]
// MODE: generate
// THEME: - 0:3:46.5 -
// KEYWORDS: brasaSeq, feridasPulso, ferroBrasa, freeverb2, generate, memoriaSeq, pulsoSeq, rancorAmor, ringz, sinosc, whitenoise
(
Ndef(\ferroBrasa, { |freq=43, amp=0.16, cutoff=420, t_trig=1|
    var env, slow, sub, harmonics, sig;
    env = EnvGen.ar(Env([0, 1, 1, 0], [0.8, 3.2, 2.0]), t_trig);
    slow = SinOsc.kr(0.07).range(0.92, 1.08);
    sub = SinOsc.ar(freq * slow) * 0.7;
    harmonics = LFTri.ar([freq * 2, freq * 2.015]) * 0.3;
    sig = (sub ! 2) + harmonics;
    sig = LPF.ar(sig, cutoff);
    sig * env * amp;
}).fadeTime_(6).play;

Ndef(\ferroBrasa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35)
};
Ndef(\ferroBrasa).set(\wet10, 0.16);

Pbindef(\brasaSeq,
    \dur, 6,
    \freq, Pseq([43, 43, 38, 41], inf),
    \cutoff, Pseq([360, 520, 410, 680], inf),
    \amp, 0.16,
    \t_trig, 1
);
Ndef(\ferroBrasa).quant = 1;
Ndef(\ferroBrasa)[1] = \set -> Pbindef(\brasaSeq);

Ndef(\feridasPulso, { |freq=170, amp=0.13, t_trig=1|
    var env, click, body, tone, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.22, 1, -6), t_trig);
    click = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.018), t_trig);
    body = Ringz.ar(click, freq, 0.14);
    tone = SinOsc.ar(freq * 1.49) * EnvGen.ar(Env.perc(0.004, 0.12), t_trig);
    sig = body + (tone * 0.35);
    Pan2.ar(sig * env * amp, SinOsc.kr(0.13).range(-0.65, 0.65));
}).fadeTime_(2).play;

Ndef(\feridasPulso)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.25)
};
Ndef(\feridasPulso).set(\wet10, 0.12);

Pbindef(\pulsoSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.32, 0.13], inf),
    \freq, Pseq([170, 220, 146.8, 196, 130.8, 246.9], inf),
    \amp, Pseq([0.13, 0.07, 0.11, 0.06, 0.14, 0.08], inf),
    \t_trig, 1
);
Ndef(\feridasPulso).quant = 1;
Ndef(\feridasPulso)[1] = \set -> Pbindef(\pulsoSeq);

Ndef(\rancorAmor, { |freq=440, amp=0.12, index=1.8, t_trig=1|
    var env, clangEnv, mod, carrier, harmonics, sig;
    env = EnvGen.ar(Env.perc(0.01, 1.8, 1, -4), t_trig);
    clangEnv = EnvGen.ar(Env.perc(0.003, 0.3, 1, -5), t_trig);
    mod = SinOsc.ar(freq * 1.414) * freq * index * clangEnv;
    carrier = SinOsc.ar(freq + mod);
    harmonics = SinOsc.ar(freq * [2.01, 3.02]) * [0.35, 0.2];
    sig = carrier + harmonics.sum;
    sig = (sig * 1.4).tanh;
    Pan2.ar(sig * env * amp, SinOsc.kr(0.09).range(-0.75, 0.75));
}).fadeTime_(4).play;

Ndef(\rancorAmor)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.22)
};
Ndef(\rancorAmor).set(\wet10, 0.24);

Pbindef(\memoriaSeq,
    \dur, Pseq([1.5, 0.75, 2.25, 1, 1.5, 3], inf),
    \freq, Pseq([440, 523.25, 392, 349.23, 466.16, 329.63], inf),
    \index, Pseq([1.8, 0.7, 2.4, 1.1, 2.1, 0.8], inf),
    \amp, Pseq([0.12, 0.09, 0.11, 0.1, 0.12, 0.08], inf),
    \t_trig, 1
);
Ndef(\rancorAmor).quant = 1;
Ndef(\rancorAmor)[1] = \set -> Pbindef(\memoriaSeq);

// Live adjustments and rollbacks
// Ndef(\ferroBrasa).xset(\cutoff, 900); // Expose the fire | Revert: Ndef(\ferroBrasa).xset(\cutoff, 420);
// Pbindef(\pulsoSeq, \dur, 0.125); // Fracture the pulse | Revert: Pbindef(\pulsoSeq, \dur, 0.5);
// Ndef(\ferroBrasa).fadeTime = 4; Ndef(\ferroBrasa).clear(4); // Rollback
// Ndef(\feridasPulso).fadeTime = 4; Ndef(\feridasPulso).clear(4); // Rollback
// Ndef(\rancorAmor).fadeTime = 4; Ndef(\rancorAmor).clear(4); // Rollback
)

// Source: 2026-11-16_20-29-00.scd [Block 7]
// MODE: generate
// THEME: - 0:3:54.85 -
// KEYWORDS: brasaSeq, feridasPulso, ferroBrasa, freeverb2, generate, memoriaSeq, pulsoSeq, rancorAmor, ringz, sinosc, whitenoise
(
Ndef(\ferroBrasa, { |freq=43, amp=0.16, cutoff=420, t_trig=1|
    var env, slow, sub, harmonics, sig;
    env = EnvGen.ar(Env([0, 1, 1, 0], [0.8, 3.2, 2.0]), t_trig);
    slow = SinOsc.kr(0.07).range(0.92, 1.08);
    sub = SinOsc.ar(freq * slow) * 0.7;
    harmonics = LFTri.ar([freq * 2, freq * 2.015]) * 0.3;
    sig = (sub ! 2) + harmonics;
    sig = LPF.ar(sig, cutoff);
    sig * env * amp;
}).fadeTime_(6).play;

Ndef(\ferroBrasa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35)
};
Ndef(\ferroBrasa).set(\wet10, 0.16);

Pbindef(\brasaSeq,
    \dur, 6,
    \freq, Pseq([43, 43, 38, 41], inf),
    \cutoff, Pseq([360, 520, 410, 680], inf),
    \amp, 0.16,
    \t_trig, 1
);
Ndef(\ferroBrasa).quant = 1;
Ndef(\ferroBrasa)[1] = \set -> Pbindef(\brasaSeq);

Ndef(\feridasPulso, { |freq=170, amp=0.13, t_trig=1|
    var env, click, body, tone, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.22, 1, -6), t_trig);
    click = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.018), t_trig);
    body = Ringz.ar(click, freq, 0.14);
    tone = SinOsc.ar(freq * 1.49) * EnvGen.ar(Env.perc(0.004, 0.12), t_trig);
    sig = body + (tone * 0.35);
    Pan2.ar(sig * env * amp, SinOsc.kr(0.13).range(-0.65, 0.65));
}).fadeTime_(2).play;

Ndef(\feridasPulso)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.25)
};
Ndef(\feridasPulso).set(\wet10, 0.12);

Pbindef(\pulsoSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.32, 0.13], inf),
    \freq, Pseq([170, 220, 146.8, 196, 130.8, 246.9], inf),
    \amp, Pseq([0.13, 0.07, 0.11, 0.06, 0.14, 0.08], inf),
    \t_trig, 1
);
Ndef(\feridasPulso).quant = 1;
Ndef(\feridasPulso)[1] = \set -> Pbindef(\pulsoSeq);

Ndef(\rancorAmor, { |freq=440, amp=0.12, index=1.8, t_trig=1|
    var env, clangEnv, mod, carrier, harmonics, sig;
    env = EnvGen.ar(Env.perc(0.01, 1.8, 1, -4), t_trig);
    clangEnv = EnvGen.ar(Env.perc(0.003, 0.3, 1, -5), t_trig);
    mod = SinOsc.ar(freq * 1.414) * freq * index * clangEnv;
    carrier = SinOsc.ar(freq + mod);
    harmonics = SinOsc.ar(freq * [2.01, 3.02]) * [0.35, 0.2];
    sig = carrier + harmonics.sum;
    sig = (sig * 1.4).tanh;
    Pan2.ar(sig * env * amp, SinOsc.kr(0.09).range(-0.75, 0.75));
}).fadeTime_(4).play;

Ndef(\rancorAmor)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.22)
};
Ndef(\rancorAmor).set(\wet10, 0.24);

Pbindef(\memoriaSeq,
    \dur, Pseq([1.5, 0.75, 2.25, 1, 1.5, 3], inf),
    \freq, Pseq([440, 523.25, 392, 349.23, 466.16, 329.63], inf),
    \index, Pseq([1.8, 0.7, 2.4, 1.1, 2.1, 0.8], inf),
    \amp, Pseq([0.12, 0.09, 0.11, 0.1, 0.12, 0.08], inf),
    \t_trig, 1
);
Ndef(\rancorAmor).quant = 1;
Ndef(\rancorAmor)[1] = \set -> Pbindef(\memoriaSeq);

// Live adjustments and rollbacks
Ndef(\ferroBrasa).xset(\cutoff, 900); // Expose the fire | Revert: Ndef(\ferroBrasa).xset(\cutoff, 420);
// Pbindef(\pulsoSeq, \dur, 0.125); // Fracture the pulse | Revert: Pbindef(\pulsoSeq, \dur, 0.5);
// Ndef(\ferroBrasa).fadeTime = 4; Ndef(\ferroBrasa).clear(4); // Rollback
// Ndef(\feridasPulso).fadeTime = 4; Ndef(\feridasPulso).clear(4); // Rollback
// Ndef(\rancorAmor).fadeTime = 4; Ndef(\rancorAmor).clear(4); // Rollback
)

// Source: test.scd [Block 1]
// MODE: generate
// THEME: --- PARKER SOLAR PROBE INSTRUMENTS ---
// KEYWORDS: bpf, generate, hpf, instruments, parker, probe, probePulse, pulse, rlpf, saw, sinosc, solar, solarWind, venusGravity, voidPad
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
)

// Source: xappend-duquesa.scd [Block 2]
// MODE: generate
// THEME: Layer 1: restrained sub-harmonic pulse, a steady ground beneath the claim
// KEYWORDS: beneath, bpf, claim, freeverb2, generate, ground, harmonic, hpf, pasmoSub, pasmoSubSeq, pasmoTicks, pasmoTicksSeq, pasmoVoice, pasmoVoiceSeq, pulse, restrained, saw, sinosc, steady, sub, the
(
// Layer 1: restrained sub-harmonic pulse, a steady ground beneath the claim
 Ndef(\pasmoSub, {
  |freq=55, amp=0.16, pan=0, t_trig=0, rel=1.8|
  var env, tone, drift;
  env = EnvGen.kr(Env.perc(0.08, rel, 1, -4), t_trig);
  drift = SinOsc.kr(0.07).range(0.97, 1.03);
  tone = SinOsc.ar(freq * drift) + (SinOsc.ar(freq * 2 * drift) * 0.38);
  Pan2.ar(tone * env, pan, amp);
 }).fadeTime = 4;
 Ndef(\pasmoSub).play;
 Ndef(\pasmoSub)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.32, 0.45)
 };
 Ndef(\pasmoSub).set(\wet10, 0.18);
 Pbindef(\pasmoSubSeq,
  \freq, Pseq([55, 55, 49, 55, 62, 55, 49, 52], inf),
  \dur, Pseq([1, 0.75, 1.25, 0.5, 1, 0.75, 1.5, 0.5], inf),
  \rel, Pwhite(1.1, 2.2, inf),
  \amp, 0.15, \pan, 0, \t_trig, 1
 );
 Ndef(\pasmoSub).quant = 1;
 Ndef(\pasmoSub)[1] = \set -> Pbindef(\pasmoSubSeq);

 // Layer 2: dry, irregular ticks; the pulse refuses to perform astonishment
 Ndef(\pasmoTicks, {
  |freq=420, amp=0.12, pan=(-0.25), t_trig=0, decay=0.09, cutoff=3200|
  var env, body, click;
  env = EnvGen.kr(Env.perc(0.002, decay, 1, -7), t_trig);
  body = (Pulse.ar(freq, 0.34) * 0.55) + (WhiteNoise.ar * 0.12);
  click = HPF.ar(body, 180) * env;
  Pan2.ar(LPF.ar(click, cutoff), pan, amp);
 }).fadeTime = 2;
 Ndef(\pasmoTicks).play;
 Ndef(\pasmoTicks)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.18, 0.35)
 };
 Ndef(\pasmoTicks).set(\wet10, 0.12);
 Pbindef(\pasmoTicksSeq,
  \freq, Pseq([420, 630, 470, 840, 520, 390, 760, 560], inf),
  \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.18, 0.38, 0.12], inf),
  \decay, Pwhite(0.035, 0.12, inf),
  \cutoff, Pwhite(2100, 4600, inf),
  \pan, Pwhite(-0.65, 0.65, inf),
  \amp, 0.11, \t_trig, 1
 );
 Ndef(\pasmoTicks).quant = 1;
 Ndef(\pasmoTicks)[1] = \set -> Pbindef(\pasmoTicksSeq);

 // Layer 3: a formant-like voice, clear syllabic shapes edged by instability
 Ndef(\pasmoVoice, {
  |freq=146.83, amp=0.13, pan=0.1, t_trig=0, vowel=0, rel=0.48, cutoff=4200|
  var env, source, formants, voiced, wobble;
  env = EnvGen.kr(Env.perc(0.025, rel, 1, -3), t_trig);
  wobble = SinOsc.kr(0.19).range(0.992, 1.008);
  source = (Saw.ar(freq * wobble) * 0.52) + (Pulse.ar(freq * 0.5, 0.42) * 0.28);
  formants = SelectX.kr(vowel, [[700, 1200, 2550], [480, 980, 2150], [360, 760, 1850]]);
  voiced = BPF.ar(source, formants, 0.16).sum * 5.0;
  Pan2.ar(LPF.ar(voiced, cutoff) * env, pan, amp);
 }).fadeTime = 3;
 Ndef(\pasmoVoice).play;
 Ndef(\pasmoVoice)[10] = \filter -> { |in|
  FreeVerb2.ar(in[0], in[1], 1, 0.46, 0.62)
 };
 Ndef(\pasmoVoice).set(\wet10, 0.28);
 Pbindef(\pasmoVoiceSeq,
  \freq, Pseq([146.83, 164.81, 196, 174.61, 130.81, 146.83, 220, 164.81], inf),
  \dur, Pseq([1.5, 0.75, 1, 0.5, 1.75, 0.75, 1.25, 0.5], inf),
  \vowel, Pseq([0, 0, 1, 1, 2, 0, 2, 1], inf),
  \rel, Pwhite(0.32, 0.72, inf),
  \pan, Pwhite(-0.35, 0.35, inf),
  \cutoff, Pwhite(3100, 5400, inf),
  \amp, 0.12, \t_trig, 1
 );
 Ndef(\pasmoVoice).quant = 1;
 Ndef(\pasmoVoice)[1] = \set -> Pbindef(\pasmoVoiceSeq);

 // Live tweaks and rollbacks
 // Ndef(\pasmoVoice).xset(\cutoff, 5600); // Open the voice | Revert: Ndef(\pasmoVoice).xset(\cutoff, 4200);
 // Pbindef(\pasmoTicksSeq, \dur, 0.125); // Tighten the pulse | Revert: Pbindef(\pasmoTicksSeq, \dur, 0.375);
 // Pbindef(\pasmoSubSeq).stop; Ndef(\pasmoSub).fadeTime = 4; Ndef(\pasmoSub).clear(4); // Rollback sub
 // Pbindef(\pasmoTicksSeq).stop; Ndef(\pasmoTicks).fadeTime = 4; Ndef(\pasmoTicks).clear(4); // Rollback ticks
 // Pbindef(\pasmoVoiceSeq).stop; Ndef(\pasmoVoice).fadeTime = 4; Ndef(\pasmoVoice).clear(4); // Rollback voice
)

// Source: xappend-duquesa.scd [Block 3]
// MODE: generate
// THEME: Camada 1: chão profundo, húmus e terra sob a cama de grama
// KEYWORDS: bosqueEstalos, bosqueEstalosSeq, bosqueHumus, bosqueHumusSeq, bosquePetalas, bosquePetalasSeq, bpf, cama, camada, freeverb2, generate, grama, hpf, mus, pinknoise, profundo, saw, sinosc, sob, terra
(
// Camada 1: chão profundo, húmus e terra sob a cama de grama
Ndef(\bosqueHumus).fadeTime = 5;
Ndef(\bosqueHumus, {
    |freq=55, amp=0.16, pan=(-0.2), cutoff=260, t_trig=1|
    var env, drift, tone, sub;
    env = EnvGen.kr(Env.perc(0.8, 7.0, 1, -4), t_trig);
    drift = SinOsc.kr(0.07).range(0.94, 1.06);
    tone = LPF.ar(
        (Saw.ar(freq * drift) * 0.018) +
        (SinOsc.ar(freq * 2 * drift) * 0.045),
        cutoff + SinOsc.kr(0.11).range(0, 90)
    );
    sub = tone * env * amp;
    Pan2.ar(sub, pan);
}).play;

Ndef(\bosqueHumus)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.38, 0.52)
};
Ndef(\bosqueHumus).set(\wet10, 0.22);

Pbindef(\bosqueHumusSeq,
    \freq, Pseq([43.65, 55, 65.41, 49], inf),
    \amp, Pwhite(0.11, 0.17, inf),
    \pan, Pwhite(-0.35, 0.25, inf),
    \cutoff, Pwhite(190, 340, inf),
    \dur, Pwrand([2, 3, 4], [0.45, 0.35, 0.2], inf),
    \t_trig, 1
);
Ndef(\bosqueHumus).quant = 1;
Ndef(\bosqueHumus)[1] = \set -> Pbindef(\bosqueHumusSeq);

// Camada 2: sementes, gravetos e flores esmagadas em pequenos estalos
Ndef(\bosqueEstalos).fadeTime = 2;
Ndef(\bosqueEstalos, {
    |freq=420, amp=0.12, pan=0, t_trig=1|
    var env, click, body, shimmer;
    env = EnvGen.kr(Env.perc(0.003, 0.19, 1, -6), t_trig);
    click = Decay2.ar(K2A.ar(t_trig), 0.002, 0.045);
    body = (WhiteNoise.ar(0.16) * click) +
        (SinOsc.ar(freq, 0, 0.12) * env);
    shimmer = HPF.ar(body, 900) * 0.55;
    Pan2.ar((body + shimmer) * amp, pan);
}).play;

Ndef(\bosqueEstalos)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.2, 0.38)
};
Ndef(\bosqueEstalos).set(\wet10, 0.14);

Pbindef(\bosqueEstalosSeq,
    \freq, Pseq([330, 440, 523.25, 392, 659.25, 349.23], inf),
    \amp, Pwhite(0.07, 0.13, inf),
    \pan, Pwhite(-0.8, 0.8, inf),
    \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.35, 0.17], inf),
    \t_trig, 1
);
Ndef(\bosqueEstalos).quant = 1;
Ndef(\bosqueEstalos)[1] = \set -> Pbindef(\bosqueEstalosSeq);

// Camada 3: tênues ressonâncias florais, sem brilho mágico
Ndef(\bosquePetalas).fadeTime = 4;
Ndef(\bosquePetalas, {
    |freq=261.63, amp=0.11, pan=0.35, t_trig=1|
    var env, mod, voice, air, sway;
    env = EnvGen.kr(Env.perc(0.015, 1.8, 1, -3), t_trig);
    sway = SinOsc.kr(0.09).range(0.985, 1.015);
    mod = SinOsc.ar(freq * 2.71, 0, freq * 0.12 * env);
    voice = SinOsc.ar((freq * sway) + mod) * 0.7;
    voice = voice + (SinOsc.ar(freq * 1.503 * sway) * 0.2 * env);
    air = BPF.ar(PinkNoise.ar(0.025), freq * 3.2, 0.45);
    Pan2.ar((voice * env + air * env) * amp, pan);
}).play;

Ndef(\bosquePetalas)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.48, 0.68)
};
Ndef(\bosquePetalas).set(\wet10, 0.25);

Pbindef(\bosquePetalasSeq,
    \freq, Pseq([261.63, 293.66, 349.23, 392, 329.63, 293.66], inf),
    \amp, Pwhite(0.075, 0.12, inf),
    \pan, Pwhite(-0.65, 0.65, inf),
    \dur, Pwrand([1, 1.5, 2], [0.45, 0.35, 0.2], inf),
    \t_trig, 1
);
Ndef(\bosquePetalas).quant = 1;
Ndef(\bosquePetalas)[1] = \set -> Pbindef(\bosquePetalasSeq);

// Ajustes ao vivo e reversões
// Ndef(\bosqueHumus).xset(\cutoff, 420); // Abrir o chão | Revert: Ndef(\bosqueHumus).xset(\cutoff, 260);
// Pbindef(\bosqueEstalos, \dur, 0.25); // Mais movimento | Revert: Pbindef(\bosqueEstalos, \dur, 0.5);
// Ndef(\bosqueHumus).fadeTime = 4; Ndef(\bosqueHumus).clear(4); // Rollback
// Ndef(\bosqueEstalos).fadeTime = 4; Ndef(\bosqueEstalos).clear(4); // Rollback
// Ndef(\bosquePetalas).fadeTime = 4; Ndef(\bosquePetalas).clear(4); // Rollback
)

// Source: xappend-duquesa.scd [Block 6]
// MODE: generate
// THEME: Xduquesa sound structure with \ferroBrasa, \feridasPulso
// KEYWORDS: brasaSeq, feridasPulso, feridaspulso, ferroBrasa, ferrobrasa, freeverb2, generate, memoriaSeq, pulsoSeq, rancorAmor, ringz, sinosc, structure, whitenoise, xduquesa
(
Ndef(\ferroBrasa, { |freq=43, amp=0.16, cutoff=420, t_trig=1|
    var env, slow, sub, harmonics, sig;
    env = EnvGen.ar(Env([0, 1, 1, 0], [0.8, 3.2, 2.0]), t_trig);
    slow = SinOsc.kr(0.07).range(0.92, 1.08);
    sub = SinOsc.ar(freq * slow) * 0.7;
    harmonics = LFTri.ar([freq * 2, freq * 2.015]) * 0.3;
    sig = (sub ! 2) + harmonics;
    sig = LPF.ar(sig, cutoff);
    sig * env * amp;
}).fadeTime_(6).play;

Ndef(\ferroBrasa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.35)
};
Ndef(\ferroBrasa).set(\wet10, 0.16);

Pbindef(\brasaSeq,
    \dur, 6,
    \freq, Pseq([43, 43, 38, 41], inf),
    \cutoff, Pseq([360, 520, 410, 680], inf),
    \amp, 0.16,
    \t_trig, 1
);
Ndef(\ferroBrasa).quant = 1;
Ndef(\ferroBrasa)[1] = \set -> Pbindef(\brasaSeq);

Ndef(\feridasPulso, { |freq=170, amp=0.13, t_trig=1|
    var env, click, body, tone, sig;
    env = EnvGen.ar(Env.perc(0.002, 0.22, 1, -6), t_trig);
    click = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.018), t_trig);
    body = Ringz.ar(click, freq, 0.14);
    tone = SinOsc.ar(freq * 1.49) * EnvGen.ar(Env.perc(0.004, 0.12), t_trig);
    sig = body + (tone * 0.35);
    Pan2.ar(sig * env * amp, SinOsc.kr(0.13).range(-0.65, 0.65));
}).fadeTime_(2).play;

Ndef(\feridasPulso)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.25)
};
Ndef(\feridasPulso).set(\wet10, 0.12);

Pbindef(\pulsoSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.55, 0.32, 0.13], inf),
    \freq, Pseq([170, 220, 146.8, 196, 130.8, 246.9], inf),
    \amp, Pseq([0.13, 0.07, 0.11, 0.06, 0.14, 0.08], inf),
    \t_trig, 1
);
Ndef(\feridasPulso).quant = 1;
Ndef(\feridasPulso)[1] = \set -> Pbindef(\pulsoSeq);

Ndef(\rancorAmor, { |freq=440, amp=0.12, index=1.8, t_trig=1|
    var env, clangEnv, mod, carrier, harmonics, sig;
    env = EnvGen.ar(Env.perc(0.01, 1.8, 1, -4), t_trig);
    clangEnv = EnvGen.ar(Env.perc(0.003, 0.3, 1, -5), t_trig);
    mod = SinOsc.ar(freq * 1.414) * freq * index * clangEnv;
    carrier = SinOsc.ar(freq + mod);
    harmonics = SinOsc.ar(freq * [2.01, 3.02]) * [0.35, 0.2];
    sig = carrier + harmonics.sum;
    sig = (sig * 1.4).tanh;
    Pan2.ar(sig * env * amp, SinOsc.kr(0.09).range(-0.75, 0.75));
}).fadeTime_(4).play;

Ndef(\rancorAmor)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.22)
};
Ndef(\rancorAmor).set(\wet10, 0.24);

Pbindef(\memoriaSeq,
    \dur, Pseq([1.5, 0.75, 2.25, 1, 1.5, 3], inf),
    \freq, Pseq([440, 523.25, 392, 349.23, 466.16, 329.63], inf),
    \index, Pseq([1.8, 0.7, 2.4, 1.1, 2.1, 0.8], inf),
    \amp, Pseq([0.12, 0.09, 0.11, 0.1, 0.12, 0.08], inf),
    \t_trig, 1
);
Ndef(\rancorAmor).quant = 1;
Ndef(\rancorAmor)[1] = \set -> Pbindef(\memoriaSeq);

// Live adjustments and rollbacks

)

// Source: xappend-museta.scd [Block 4]
// MODE: generate
// THEME: --- Quiet new textures (uncomment to reduce volume to ~1/10) ---
// KEYWORDS: bpf, combl, coral, coralSeq, costas, dynklank, freeverb, generate, hpf, meseta, mesetaSeq, moogff, new, pireneus, quiet, reduce, textures, uncomment, volume
(
// --- PENÍNSULA IBÉRICA INSTRUMENTS ---
Ndef(\pireneus, {
	|freq=55, cutoff=260, rq=0.35, noiseLevel=0.06, amp=0.35, pan=0|
	var detune, osc1, osc2, lfo, wind, filter, sig;
	detune = LFNoise2.kr(0.08).bipolar(0.008);
	osc1 = Saw.ar(freq * (1 + detune));
	osc2 = Saw.ar((freq * 0.5) * (1 - detune));
	lfo = LFNoise2.kr(0.12).exprange(cutoff * 0.6, cutoff * 1.7);
	wind = PinkNoise.ar(noiseLevel) * LFNoise1.kr(0.25).range(0.2, 1.0);
	sig = osc1 + osc2 + wind;
	filter = MoogFF.ar(sig, lfo.clip(30, 3500), rq * 3.0);
	filter = LeakDC.ar(filter.tanh);
	Pan2.ar(filter * amp, pan);
}).play;
Ndef(\costas, {
	|amp=0.25, swellRate=0.07, centerFreq=600, rq=0.75|
	var swellL, swellR, noise, bpf, brf, sig;
	swellL = SinOsc.kr(swellRate).range(0.25, 1.0);
	swellR = SinOsc.kr(swellRate, pi * 0.5).range(0.25, 1.0);
	noise = BrownNoise.ar([swellL, swellR]);
	brf = BRF.ar(noise, LFNoise1.kr([0.08, 0.11]).exprange(centerFreq * 0.5, centerFreq * 1.5), rq);
	bpf = BPF.ar(noise, LFNoise2.kr([0.06, 0.09]).exprange(180, 1100), 0.5) * 2.2;
	sig = (brf * 0.6) + (bpf * 0.4);
	sig = LeakDC.ar(sig);
	sig * amp;
}).play;
Ndef(\coral, {
	|freq=146.83, amp=0.32, t_trig=1, atk=0.45, sus=2.7, rel=0.65,
	 vPhase=0.5, vibratoDepth=0.006, vibratoRate=4.5, brightness=1.0|
	var env, vib, f0, chords, osc, vowelO, vowelA, vowelE, formants, sig;
	env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel], \sin), t_trig);
	vib = SinOsc.kr(vibratoRate).bipolar(vibratoDepth);
	f0 = freq * (1 + vib);
	chords = [f0 * 0.5, f0, f0 * 1.5, f0 * 2.0, f0 * 2.5];
	osc = chords.collect({ |f|
		(Saw.ar(f) * 0.5) + (Pulse.ar(f * 1.002, 0.42) * 0.5)
	});
	vowelO = [500, 900, 2400];
	vowelA = [800, 1200, 2500];
	vowelE = [400, 2000, 2600];
	formants = [0, 1, 2].collect({ |i|
		var fForm = SelectX.kr(vPhase * 2, [vowelO[i], vowelA[i], vowelE[i]]) * brightness;
		BPF.ar(osc, fForm, 0.12) * 3.5;
	}).sum;
	sig = Splay.ar(formants);
	sig = HPF.ar(sig, 120);
	sig = LeakDC.ar(sig);
	sig * env * amp;
}).play;
Ndef(\meseta, {
	|freq=220, amp=0.22, t_trig=1, decayscale=1.1, pan=0, ringMod=0.25|
	var env, exciter, modalFreqs, modalAmps, modalRings, sig, rmod;
	env = EnvGen.ar(Env.perc(0.002, 0.08), t_trig);
	exciter = (WhiteNoise.ar(0.35) + Dust.ar(40, 0.25)) * env;
	modalFreqs = [freq, freq * 2.02, freq * 3.01, freq * 4.45, freq * 5.82];
	modalAmps = [0.4, 0.25, 0.2, 0.1, 0.05];
	modalRings = [0.8, 0.6, 0.4, 0.25, 0.15];
	sig = DynKlank.ar(
		`[modalFreqs, modalAmps, modalRings],
		exciter,
		freqscale: 1,
		freqoffset: 0,
		decayscale: decayscale
	);
	rmod = sig * SinOsc.ar(freq * 0.5) * ringMod;
	sig = (sig * (1 - (ringMod * 0.5))) + rmod;
	sig = LeakDC.ar(sig);
	Pan2.ar(sig * amp, pan);
}).play;

// --- PENÍNSULA IBÉRICA EFFECTS ---

// Coral Reverb (Stone Cathedral Nave)
Ndef(\coral)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.88, 0.25) };
Ndef(\coral).set(\wet10, 0.45);

// Coral Saturation (Warm Choral Tape Compression)
Ndef(\coral)[12] = \filter -> { |in| (in * 1.4).fold2(0.85) };
Ndef(\coral).set(\wet12, 0.15);

// Meseta Dry Reverb
Ndef(\meseta)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.5, 0.3) };
Ndef(\meseta).set(\wet10, 0.1);

// Meseta Spatial Echo Delay
Ndef(\meseta)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 2.0) };
Ndef(\meseta).set(\wet11, 0.35);

// Pirenéus Vast Mountain Decay
Ndef(\pireneus)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.15) };
Ndef(\pireneus).set(\wet10, 0.25);

// Costas Oceanic Diffuse Reverb
Ndef(\costas)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8, 0.4) };
Ndef(\costas).set(\wet10, 0.2);

// --- PENÍNSULA IBÉRICA SEQUENCES ---

[Ndef(\coral), Ndef(\meseta), Ndef(\pireneus), Ndef(\costas)].do(_.quant_(1));

Pbindef(\coralSeq,
	\dur, Pn(Pseq([4.0, 4.0, 2.0, 2.0, 4.0, 2.0, 2.0, 4.0], 1), inf),
	\freq, Pn(Pseq([146.83, 155.56, 174.61, 146.83, 196.00, 174.61, 155.56, 146.83], 1), inf),
	\vPhase, Pn(Pseq([0.1, 0.5, 0.85, 0.5, 0.0, 0.7, 0.35, 0.5], 1), inf),
	\atk, 0.4,
	\sus, Pkey(\dur) * 0.75,
	\rel, 0.65,
	\t_trig, 1
);
Ndef(\coral)[1] = \set -> Pbindef(\coralSeq);

Pbindef(\mesetaSeq,
	\dur, Pn(Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], 1), inf),
	\freq, Pn(Pseq([293.66, 311.13, 349.23, 311.13, 392.00, 349.23, 293.66, 440.00, 392.00, 311.13, 293.66, 220.00], 1), inf),
	\pan, Pn(Pseq([-0.15, 0.15, -0.05, 0.1, -0.2, 0.2], 1), inf),
	\decayscale, Pwhite(0.8, 1.5, inf),
	\t_trig, 1
);
Ndef(\meseta)[1] = \set -> Pbindef(\mesetaSeq);
)

// Source: xappend-oceano.scd [Block 3]
// MODE: generate
// THEME: --- Quiet new textures (uncomment to reduce volume to ~1/10) ---
// KEYWORDS: bpf, choirHigh, choirLow, generate, hpf, new, pulse, quiet, reduce, saw, sinosc, textures, uncomment, volume
(
Ndef(\choirHigh).ar(2);
Ndef(\choirLow).ar(2);

Ndef(\choirHigh, {
	|f1=293.66, f2=349.23, f3=440.00, f4=587.33, amp=0.18, atk=0.15, sus=1.8, rel=1.0,
	formant1=450, formant2=800, formant3=2400, rq=0.12, vibRate=5.2, vibDepth=0.012, t_trig=1|
	var env, vib, freqs, oscs, formants, sig;
	env = EnvGen.ar(Env([0, 1, 0.85, 0], [atk, sus, rel], [\sine, \sine, -4]), t_trig);
	vib = SinOsc.kr(vibRate + LFNoise2.kr(1.0).bipolar(0.3)) * vibDepth;
	freqs = [f1, f2, f3, f4] * (1 + vib);
	oscs = freqs.collect({ |f|
		(Saw.ar(f * [0.998, 1.002]) * 0.6) + (Pulse.ar(f, 0.42) * 0.4)
	}).flat;
	formants = [formant1, formant2, formant3].collect({ |fForm|
		BPF.ar(oscs, fForm, rq) * 2.8
	}).sum;
	sig = HPF.ar(formants, 220);
	Splay.ar(sig) * env * amp;
}).play;

Ndef(\choirLow, {
	|f1=73.42, f2=110.00, amp=0.22, atk=0.2, sus=1.8, rel=1.2,
	formant1=350, formant2=650, formant3=2200, rq=0.15, vibRate=4.8, vibDepth=0.008, subAmp=0.35, t_trig=1|
	var env, vib, freqs, oscs, sub, formants, sig;
	env = EnvGen.ar(Env([0, 1, 0.9, 0], [atk, sus, rel], [\sine, \sine, -4]), t_trig);
	vib = SinOsc.kr(vibRate + LFNoise2.kr(0.8).bipolar(0.2)) * vibDepth;
	freqs = [f1, f2] * (1 + vib);
	oscs = freqs.collect({ |f|
		Saw.ar(f * [0.999, 1.001])
	}).flat;
	sub = SinOsc.ar(f1 * 0.5) * subAmp;
	formants = [formant1, formant2, formant3].collect({ |fForm|
		BPF.ar(oscs, fForm, rq) * 2.4
	}).sum;
	sig = (formants.sum * 0.7) + sub;
	sig = LPF.ar(sig, 3800);
	Pan2.ar(sig * env * amp, 0);
}).play;
)


// Source: session_2026-11-18_12-43-32
// MODE: generate
// THEME: A Classe République foi uma classe de couraçados operada pela Marinha Nacional Francesa, composta pelo République e Patrie. Suas construções começaram em 190...
(
Ndef(\arsenalBrest, { |freq=55, amp=0.12, cutoff=180, t_trig=0|
	var env, pulse, harmonics, sig;
	env = Decay2.ar(K2A.ar(t_trig), 0.03, 1.4);
	pulse = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
	harmonics = LFTri.ar([freq * 3, freq * 3.02]) * [0.12, 0.1];
	sig = LPF.ar((pulse * 0.7) + harmonics.sum, cutoff);
	Pan2.ar(sig * env * amp, -0.25);
}).fadeTime_(4).play;

Pbindef(\arsenalBrestSeq,
	\dur, Pseq([1, 1, 0.5, 0.5, 2], inf),
	\freq, Pseq([55, 55, 61.74, 55, 49], inf),
	\cutoff, Pseq([150, 190, 240, 170, 130], inf),
	\amp, 0.12,
	\t_trig, 1
);
Ndef(\arsenalBrest)[1] = \set -> Pbindef(\arsenalBrestSeq);

// Pbindef(\arsenalBrestSeq).stop; Ndef(\arsenalBrest).fadeTime = 2; Ndef(\arsenalBrest).clear(2); // Rollback: remove this instrument

Ndef(\deuxCuirasses, { |freq=73.42, amp=0.08, beatRate=0.12, t_trig=0|
	var env, drift, low, upper, sig;
	env = EnvGen.ar(Env.perc(0.08, 3.5), t_trig);
	drift = SinOsc.kr(beatRate).range(0.985, 1.015);
	low = SinOsc.ar(freq * drift) * 0.65;
	upper = SinOsc.ar(freq * 2.01 * drift) * 0.2;
	sig = low + upper;
	Pan2.ar(sig * env * amp, 0.25);
}).fadeTime_(5).play;

Pbindef(\deuxCuirassesSeq,
	\dur, Pseq([3, 3, 2, 4], inf),
	\freq, Pseq([73.42, 82.41, 73.42, 65.41], inf),
	\amp, 0.08,
	\t_trig, 1
);
Ndef(\deuxCuirasses)[1] = \set -> Pbindef(\deuxCuirassesSeq);

// Pbindef(\deuxCuirassesSeq).stop; Ndef(\deuxCuirasses).fadeTime = 2; Ndef(\deuxCuirasses).clear(2); // Rollback: remove this instrument

Ndef(\miseALeau, { |freq=659.25, amp=0.07, decayTime=2.2, t_trig=0, pan=0|
	var trig, env, clang, shimmer, sig;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.01, decayTime);
	clang = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.71) * 0.45);
	shimmer = BPF.ar(WhiteNoise.ar * env, freq * 3.1, 0.12) * 2.5;
	sig = (clang * env) + shimmer;
	Pan2.ar(sig * amp, pan);
}).fadeTime_(3).play;

Pbindef(\miseALeauSeq,
	\dur, Pseq([4, 6, 4, 8], inf),
	\freq, Pseq([659.25, 587.33, 523.25, 783.99], inf),
	\decayTime, Pseq([2.2, 2.8, 1.8, 3.2], inf),
	\amp, 0.07,
	\pan, Pseq([-0.5, 0.5, -0.25, 0.25], inf),
	\t_trig, 1
);
Ndef(\miseALeau)[1] = \set -> Pbindef(\miseALeauSeq);

// Pbindef(\miseALeauSeq).stop; Ndef(\miseALeau).fadeTime = 2; Ndef(\miseALeau).clear(2); // Rollback: remove this instrument

// Four later hulls diverge into a successor design: slowly open the shipyard's spectral range.
Ndef(\arsenalBrest).xset(\cutoff, 420);
// Ndef(\arsenalBrest).xset(\cutoff, 180); // Revert: restore the initial shipyard timbre
)


// Source: session_2026-11-18_16-59-58
// MODE: generate
// THEME: O Monotrilho de Poços de Caldas foi um sistema de monotrilho que servia a cidade de Poços de Caldas, no estado de Minas Gerais. A linha elevada interligava o...
(
// Camada 1: grave contínuo, como o peso do monotrilho elevado sobre a cidade
Ndef(\monorailBed, { |freq=55, amp=0.12, pan=0, t_trig=0|
	var env, drift, tone;
	env = EnvGen.kr(Env.perc(0.8, 3.8, 1, -4), t_trig);
	drift = SinOsc.kr(0.035).range(0.94, 1.06);
	tone = SinOsc.ar(freq * drift, 0, 0.65)
		+ SinOsc.ar(freq * 2 * drift, 0, 0.28)
		+ (LPF.ar(PinkNoise.ar, 170) * 0.12);
	Pan2.ar(tone * env, pan, amp);
}).fadeTime = 4;
Ndef(\monorailBed).play;
Ndef(\monorailBed)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1, 0.7, 0.25);
};
Ndef(\monorailBed).set(\wet10, 0.22);
Pbindef(\seqMonorailBed,
	\dur, Pwrand([2, 3, 4], [0.45, 0.35, 0.2], inf),
	\freq, Pseq([49, 55, 61.74, 55, 46.25, 55], inf),
	\amp, 0.12, \t_trig, 1
);
Ndef(\monorailBed).quant = 1;
Ndef(\monorailBed)[1] = \set -> Pbindef(\seqMonorailBed);

// Camada 2: rodas e emendas dos trilhos, num pulso irregular de travessia
Ndef(\monorailRail, { |freq=220, amp=0.11, pan=0, t_trig=0, tone=0.4|
	var env, click, body, sway;
	env = EnvGen.kr(Env.perc(0.003, 0.19, 1, -6), t_trig);
	sway = SinOsc.kr(0.17).range(-0.65, 0.65);
	click = Decay2.ar(K2A.ar(t_trig), 0.002, 0.035) * WhiteNoise.ar(0.5);
	body = SinOsc.ar(freq, 0, 0.32) + BPF.ar(click, freq * 3.2, 0.22);
	body = body + (BPF.ar(click, freq * 7, 0.18) * 0.35);
	Pan2.ar(body * env, (pan + sway).clip(-1, 1), amp);
}).fadeTime = 2;
Ndef(\monorailRail).play;
Ndef(\monorailRail)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1, 0.52, 0.2);
};
Ndef(\monorailRail).set(\wet10, 0.16);
Pbindef(\seqMonorailRail,
	\dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.35, 0.25, 0.3, 0.1], inf),
	\freq, Pseq([196, 220, 246.94, 220, 164.81, 220, 293.66, 246.94], inf),
	\pan, Pwhite(-0.7, 0.7, inf), \amp, 0.11, \tone, 0.4, \t_trig, 1
);
Ndef(\monorailRail).quant = 1;
Ndef(\monorailRail)[1] = \set -> Pbindef(\seqMonorailRail);

// Camada 3: estações como pequenas luzes e sinais ao longo dos seis quilômetros
Ndef(\monorailSignal, { |freq=660, amp=0.09, pan=0, t_trig=0, index=2|
	var env, mod, bell, air, drift;
	env = EnvGen.kr(Env.perc(0.006, 1.4, 1, -5), t_trig);
	drift = SinOsc.kr(0.09).range(0.985, 1.015);
	mod = SinOsc.ar(freq * 2.71 * drift) * (freq * index * env * 0.16);
	bell = SinOsc.ar((freq * drift) + mod, 0, 0.6)
		+ SinOsc.ar(freq * 3.51 * drift, 0, 0.13);
	air = BPF.ar(WhiteNoise.ar, 3200, 0.25) * Decay2.ar(K2A.ar(t_trig), 0.01, 0.24) * 0.12;
	Pan2.ar((bell * env) + air, pan, amp);
}).fadeTime = 3;
Ndef(\monorailSignal).play;
Ndef(\monorailSignal)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1, 0.84, 0.3);
};
Ndef(\monorailSignal).set(\wet10, 0.3);
Pbindef(\seqMonorailSignal,
	\dur, Pwrand([0.5, 0.75, 1, 1.5], [0.25, 0.3, 0.3, 0.15], inf),
	\freq, Pseq([659.25, 783.99, 880, 783.99, 587.33, 659.25, 987.77, 880], inf),
	\pan, Pwhite(-0.8, 0.8, inf), \amp, 0.09, \index, Pwhite(1.2, 2.8, inf), \t_trig, 1
);
Ndef(\monorailSignal).quant = 1;
Ndef(\monorailSignal)[1] = \set -> Pbindef(\seqMonorailSignal);

// Ajustes ao vivo e reversões
// Ndef(\monorailBed).xset(\freq, 61.74); // Elevar o grave | Revert: Ndef(\monorailBed).xset(\freq, 55);
// Pbindef(\seqMonorailRail, \dur, 0.25); // Trilhos em dobro | Revert: Pbindef(\seqMonorailRail, \dur, 0.5);
// Pbindef(\seqMonorailBed).stop; Ndef(\monorailBed).fadeTime = 4; Ndef(\monorailBed).clear(4); // Rollback
// Pbindef(\seqMonorailRail).stop; Ndef(\monorailRail).fadeTime = 4; Ndef(\monorailRail).clear(4); // Rollback
// Pbindef(\seqMonorailSignal).stop; Ndef(\monorailSignal).fadeTime = 4; Ndef(\monorailSignal).clear(4); // Rollback
)


// Source: session_2026-11-18_18-39-14
// MODE: generate
// THEME: Já tenho novas máquinas de mitos e um mágico cenário para os ritos.
(
// Layer 1: \mitoMaquina — Mechanical-ritualistic myth machine (sub + wavefolded gear pulse)
Ndef(\mitoMaquina).fadeTime = 4;
Ndef(\mitoMaquina, { |freq=55, amp=0.18, pan=0.0, t_trig=1, cutoff=520, foldAmt=1.6, gearRate=0.14|
	var trig, env, lfo, sub, gears, folded, sig;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.02, 2.4);
	lfo = SinOsc.kr(gearRate).range(0.85, 1.15);
	sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.0) * 0.45);
	gears = Saw.ar([freq * 1.5, freq * 1.507] * lfo).sum * 0.35;
	folded = Fold.ar((sub + gears) * foldAmt, -0.75, 0.75);
	sig = MoogFF.ar(folded, (cutoff * lfo).clip(120, 4500), 2.2) * 1.6;
	sig = LeakDC.ar(sig).tanh;
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\mitoMaquina)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.65, 0.35)
};
Ndef(\mitoMaquina)[11] = \filter -> { |in|
	CombL.ar(in, 0.6, [0.28, 0.37], 1.8)
};
Ndef(\mitoMaquina).set(\wet10, 0.22, \wet11, 0.16);

Pbindef(\mitoMaquinaSeq,
	\dur, Pseq([2.0, 2.0, 1.5, 2.5], inf),
	\freq, Pseq([55, 55, 49, 61.74], inf),
	\cutoff, Pseq([420, 680, 510, 840], inf),
	\foldAmt, Pwhite(1.3, 2.1, inf),
	\amp, 0.17,
	\pan, Pwhite(-0.2, 0.2, inf),
	\t_trig, 1
);
Ndef(\mitoMaquina).quant = 1;
Ndef(\mitoMaquina)[1] = \set -> Pbindef(\mitoMaquinaSeq);

// Layer 2: \ritoCenario — Magical ritual stage (modal bronze & glass ceremonial bells)
Ndef(\ritoCenario).fadeTime = 3;
Ndef(\ritoCenario, { |freq=440, amp=0.14, pan=0.0, t_trig=1, decay=1.6, modIdx=0.8|
	var env, mod1, mod2, bell, shimmer, sig;
	env = EnvGen.kr(Env.perc(0.004, decay.clip(0.2, 4.0), 1, -4), t_trig);
	mod1 = SinOsc.ar(freq * 2.71) * (freq * modIdx * env);
	mod2 = SinOsc.ar(freq * 3.53) * (freq * 0.45 * env);
	bell = SinOsc.ar(freq + mod1 + mod2) * 0.65;
	shimmer = SinOsc.ar(freq * 1.502) * 0.25 * env;
	sig = LeakDC.ar(bell + shimmer);
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\ritoCenario)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.28)
};
Ndef(\ritoCenario).set(\wet10, 0.38);

Pbindef(\ritoCenarioSeq,
	\dur, Pwrand([0.5, 0.75, 1.25, 2.0], [0.35, 0.3, 0.2, 0.15], inf),
	\scale, Scale.harmonicMinor,
	\root, 9,
	\octave, Pwrand([5, 6], [0.7, 0.3], inf),
	\degree, Pseq([0, 2, 4, 7, 5, 4, 2, 1], inf),
	\decay, Pwhite(1.1, 2.4, inf),
	\modIdx, Pexprand(0.35, 1.2, inf),
	\amp, Pwhite(0.09, 0.15, inf),
	\pan, Pwhite(-0.75, 0.75, inf),
	\t_trig, 1
);
Ndef(\ritoCenario).quant = 1;
Ndef(\ritoCenario)[1] = \set -> Pbindef(\ritoCenarioSeq);

// Layer 3: \cantoArcano — Arcane ritual formant choir (evolving vowel resonators)
Ndef(\cantoArcano).fadeTime = 5;
Ndef(\cantoArcano, { |freq=220, amp=0.16, pan=0.0, t_trig=1, vowel=0.5, dur=2.5|
	var env, body, f1, f2, f3, formants, breath, sig;
	env = EnvGen.kr(Env([0, 1, 1, 0], [0.35, (dur - 1.15).max(0.2), 0.8]), t_trig);
	body = (Saw.ar([freq, freq * 1.004]) + (SinOsc.ar(freq * 0.5) * 0.4)).sum;
	f1 = LinExp.kr(vowel.clip(0, 1), 0, 1, 280, 740);
	f2 = LinExp.kr(vowel.clip(0, 1), 0, 1, 720, 1950);
	f3 = LinExp.kr(vowel.clip(0, 1), 0, 1, 2100, 2900);
	formants = BPF.ar(body, [f1, f2, f3], 0.14).sum * 3.8;
	breath = BPF.ar(PinkNoise.ar(0.18), f2, 0.25) * 2.5;
	sig = LeakDC.ar(formants + breath).tanh;
	Pan2.ar(sig * env * amp, pan);
}).play;

Ndef(\cantoArcano)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.32)
};
Ndef(\cantoArcano).set(\wet10, 0.34);

Pbindef(\cantoArcanoSeq,
	\dur, Pseq([2.5, 2.5, 3.0, 2.0], inf),
	\scale, Scale.harmonicMinor,
	\root, 9,
	\octave, 4,
	\degree, Pseq([0, 4, 3, 2], inf),
	\vowel, Pwhite(0.15, 0.85, inf),
	\amp, Pwhite(0.12, 0.17, inf),
	\pan, Pseq([-0.4, 0.4, -0.25, 0.25], inf),
	\t_trig, 1
);
Ndef(\cantoArcano).quant = 1;
Ndef(\cantoArcano)[1] = \set -> Pbindef(\cantoArcanoSeq);

// Ndef(\mitoMaquina).xset(\cutoff, 1400); // Open myth machine filter | Revert: Ndef(\mitoMaquina).xset(\cutoff, 520);
// Pbindef(\ritoCenarioSeq, \dur, 0.25); // Accelerate ritual bells | Revert: Pbindef(\ritoCenarioSeq, \dur, Pwrand([0.5, 0.75, 1.25, 2.0], [0.35, 0.3, 0.2, 0.15], inf));
// Pbindef(\mitoMaquinaSeq).stop; Ndef(\mitoMaquina).fadeTime = 4; Ndef(\mitoMaquina).clear(4); // Rollback
// Pbindef(\ritoCenarioSeq).stop; Ndef(\ritoCenario).fadeTime = 4; Ndef(\ritoCenario).clear(4); // Rollback
// Pbindef(\cantoArcanoSeq).stop; Ndef(\cantoArcano).fadeTime = 4; Ndef(\cantoArcano).clear(4); // Rollback
)
