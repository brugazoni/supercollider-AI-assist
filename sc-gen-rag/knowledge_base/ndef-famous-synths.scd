// =============================================================================
// 1. THE OBERHEIM 12dB FAMILY (Lush, Brassy, Wide)
// =============================================================================

// OBERHEIM 1: Plucky Arp
(
Ndef(\obArp).fadeTime = 0.5;
Ndef(\obArp, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var sig = Pulse.ar([freq, freq * 1.01], SinOsc.kr(1).range(0.1, 0.5));
    var env = EnvGen.kr(Env.perc(0.01, 0.2), t_trig);
    var fEnv = EnvGen.kr(Env.perc(0.01, 0.4), t_trig);
    sig = RLPF.ar(sig, 200 + (fEnv * 3000), \rq.kr(0.3));
    sig * env * 0.4;
}).play;
Ndef(\master) <<> Ndef(\obArp);

Ndef(\obArpSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\obArp).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minor, \degree, Pseq([0, 2, 4, 7, 12, 7, 4, 2], inf),
    \dur, 0.125, \octave, [4, 5], \t_trig, 1
)).play;
)

// OBERHEIM 2: Shimmering Drone
(
Ndef(\obDrone).fadeTime = 3;
Ndef(\obDrone, {
    var freq = \freq.kr(55);
    var pwm = SinOsc.kr([0.1, 0.12]).range(0.1, 0.9);
    var sig = Pulse.ar([freq, freq*1.5, freq*2.01], width: pwm).sum;
    var lfo = SinOsc.kr(0.05).exprange(300, 2000);
    sig = RLPF.ar(sig, lfo, 0.1);
    sig = sig + DelayC.ar(sig, 0.2, SinOsc.kr(0.2).range(0.01, 0.03));
    sig * 0.1 ! 2;
}).play;
Ndef(\master) <<> Ndef(\obDrone);
)

// OBERHEIM 3: Classic Brass Stabs
(
Ndef(\obBrass).fadeTime = 0.1;
Ndef(\obBrass, {
    var t_trig = \t_trig.tr(1);

    // 1. Array Control
    var freq = \freq.kr([110, 110, 110]);

    // Splay perfectly mixes our massive 12-oscillator stack (3 notes * 4 detuned saws)
    var sig = Splay.ar(Saw.ar(freq * [0.99, 1, 1.015, 1.02]));

    // 2. Perc Envelopes: These play out fully when hit by a t_trig.
    // I kept your original attack times to preserve that sluggish, brassy swell.
    var env = EnvGen.kr(Env.perc(attackTime: 0.1, releaseTime: 1.5), t_trig);
    var fEnv = EnvGen.kr(Env.perc(attackTime: 0.15, releaseTime: 1.0), t_trig);

    sig = RLPF.ar(sig, 400 + (fEnv * 4000), 0.5);
    sig * env * 0.3;
}).play;
Ndef(\master) <<> Ndef(\obBrass);

Ndef(\obBrassSeq, Pbind(
    \type, \set,
    \id, Pfunc({ Ndef(\obBrass).nodeID }),
    \args, #[\freq, \t_trig],
    // 3. Double-bracketed arrays: [[Note, Note, Note]]
    // This stops Pbind from splitting the chord and forces it to send the array to our Ndef.
    \midinote, Pseq([ [[48, 55, 60]], [[46, 53, 58]] ], inf),
    \dur, Pseq([1.5, 2.5], inf),
    \t_trig, 1
)).play;
)

// OBERHEIM 4: Fat Sub Bass
(
Ndef(\obBass, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(41.2);
    var sig = LFTri.ar(freq) + SinOsc.ar(freq * 0.5);
    var env = EnvGen.kr(Env.perc(0.01, 0.5), t_trig);
    sig = RLPF.ar(sig, 800, 0.8);
    (sig * env * 0.8 ! 2).tanh;
}).play;
Ndef(\master) <<> Ndef(\obBass);
Ndef(\obBass).xset(\t_trig, 1);
)

// OBERHEIM 5: Cinematic Noise Sweeps
(
Ndef(\obWind).fadeTime = 2;
Ndef(\obWind, {
    var sweep = LFSaw.kr(0.05).exprange(100, 8000);
    var sig = PinkNoise.ar(1);
    sig = RLPF.ar(sig, sweep, 0.05);
    sig * 0.2 ! 2;
}).play;
Ndef(\master) <<> Ndef(\obWind);
)

// =============================================================================
// 2. THE MOOG 24dB FAMILY (Fat, Driven, Punchy)
// =============================================================================

// MOOG 1: Berlin School Sequence
(
Ndef(\moogBerlin).fadeTime = 0;
Ndef(\moogBerlin, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(110);
    var sig = Saw.ar([freq, freq * 1.01]);
    var fEnv = EnvGen.kr(Env.perc(0.01, 0.2, 1, -4), t_trig);
    var env = EnvGen.kr(Env.perc(0.01, 0.3), t_trig);

    sig = MoogFF.ar(sig, 100 + (fEnv * 3000), 1.5);
    sig = sig * env;
    sig = sig + CombC.ar(sig, 0.5, [0.375, 0.5], 3, 0.5);
    (sig * 0.5).tanh;
}).play;
Ndef(\master) <<> Ndef(\moogBerlin);

Ndef(\moogBerlinSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\moogBerlin).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minor, \degree, Pseq([0, 7, 12, 10, 7, 3, 4, 7], inf),
    \dur, 0.25, \octave, 3, \t_trig, 1
)).play;
)

// MOOG 2: Self-Oscillating Drone (FIXED)
(
Ndef(\moogDrone).fadeTime = 4;
Ndef(\moogDrone, {
    var freq = \freq.kr(55);

    // FIXED: Removed the 0.1 amplitude constraint. Let the oscillator be loud.
    var sig = Pulse.ar(freq, 0.5);
    var lfo = SinOsc.kr(0.1).range(0.8, 1.2);

    sig = MoogFF.ar(sig, freq * 4 * lfo, 3.8);

    // FIXED: Pushing the gain up by 5 into the tanh function restores the
    // lost volume from the high resonance and gives it a nice analog bite.
    (sig * 5.0).tanh ! 2 * 0.3;
}).play;
Ndef(\master) <<> Ndef(\moogDrone);
)


// MOOG 3: 70s Funk Lead (FIXED)
(
Ndef(\moogLead).fadeTime = 0.5;
Ndef(\moogLead, {
    var t_trig = \t_trig.tr(1);
    var freq = Lag.kr(\freq.kr(440), 0.1);
    var mod = SinOsc.kr(6) * \vibrato.kr(5);
    var sig = Saw.ar(freq + mod);

    // FIXED: Changed asr to perc so the envelope ignores the length
    // of the trigger and plays out beautifully.
    var env = EnvGen.kr(Env.perc(attackTime: 0.05, releaseTime: 0.6), t_trig);

    sig = MoogFF.ar(sig, freq * 3, 2.0);
    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\moogLead);

Ndef(\moogLeadSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\moogLead).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minorPentatonic, \degree, Pwhite(0, 5, inf),
    \dur, Pwrand([0.25, 0.5, 1.0], [0.6, 0.3, 0.1], inf), \t_trig, 1
)).play;
)

// MOOG 4: Deep Techno Kick
(
Ndef(\moogKick).fadeTime = 0;
Ndef(\moogKick, {
    var t_trig = \t_trig.tr(1);
    var pEnv = EnvGen.kr(Env.perc(0.001, 0.15, 1, -8), t_trig);
    var env = EnvGen.kr(Env.perc(0.005, 0.4), t_trig);
    var sig = Pulse.ar(30, 0.5);
    sig = MoogFF.ar(sig, 40 + (pEnv * 400), 1.0);
    (sig * 3).tanh * env * 0.8 ! 2;
}).play;
Ndef(\master) <<> Ndef(\moogKick);

Ndef(\moogKickSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\moogKick).nodeID }), \args, #[\t_trig],
    \dur, 1, \t_trig, 1
)).play;
)

// MOOG 5: Squelch Bass
(
Ndef(\moogSquelch).fadeTime = 0;
Ndef(\moogSquelch, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(55);
    var sig = Saw.ar([freq, freq * 1.01]);
    var fEnv = EnvGen.kr(Env.perc(0.01, 0.2), t_trig);
    var env = EnvGen.kr(Env.perc(0.01, 0.3), t_trig);
    var randMod = TRand.kr(500, 4000, t_trig);

    sig = MoogFF.ar(sig, 100 + (fEnv * randMod), 2.8);
    (sig * 1.5).tanh * env * 0.4;
}).play;
Ndef(\master) <<> Ndef(\moogSquelch);

Ndef(\moogSquelchSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\moogSquelch).nodeID }), \args, #[\freq, \t_trig],
    \freq, 55, \dur, 0.25, \t_trig, 1
)).play;
)

// =============================================================================
// 3. THE ARP 2600 FAMILY (Raw, Sync, Semi-Modular)
// =============================================================================

// ARP 1: Sample & Hold Computer Bleeps
(
Ndef(\arpBleep).fadeTime = 1;
Ndef(\arpBleep, {
    var rate = \rate.kr(8);
    var s_h_pitch = LFNoise0.kr(rate).exprange(200, 2000);
    var s_h_filt = LFNoise0.kr(rate).exprange(500, 5000);

    var sig = Pulse.ar(s_h_pitch, 0.5);
    sig = BMoog.ar(sig, s_h_filt, 0.5, 0);
    sig * 0.2 ! 2;
}).play;
Ndef(\master) <<> Ndef(\arpBleep);
)

// ARP 2: Metallic Ring-Mod Drone
(
Ndef(\arpRingDrone).fadeTime = 3;
Ndef(\arpRingDrone, {
    var freq1 = \freq1.kr(50);
    var freq2 = \freq2.kr(123);
    var osc1 = Saw.ar(freq1);
    var osc2 = SinOsc.ar(freq2 + SinOsc.kr(0.1).range(-2, 2));

    var sig = osc1 * osc2;

    sig = BMoog.ar(sig, 1500, 0.2, 0);
    sig * 0.3 ! 2;
}).play;
Ndef(\master) <<> Ndef(\arpRingDrone);
)

// ARP 3: FM Bass
(
Ndef(\arpFMBass).fadeTime = 0;
Ndef(\arpFMBass, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(55);
    var fmEnv = EnvGen.kr(Env.perc(0.001, 0.1), t_trig);
    var mod = SinOsc.ar(freq * 2) * fmEnv * 500;
    var sig = SinOsc.ar(freq + mod);

    var env = EnvGen.kr(Env.perc(0.01, 0.4), t_trig);
    sig * env * 0.5 ! 2;
}).play;
Ndef(\master) <<> Ndef(\arpFMBass);

Ndef(\arpFMBassSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\arpFMBass).nodeID }), \args, #[\freq, \t_trig],
    \degree, Pseq([0, -2, 0, 3], inf), \octave, 2, \dur, 0.5, \t_trig, 1
)).play;
)

// ARP 4: Sci-Fi Laser FX
(
Ndef(\arpLaser).fadeTime = 0;
Ndef(\arpLaser, {
    var t_trig = \t_trig.tr(1);
    var pEnv = EnvGen.kr(Env([8, 1, 0.5], [0.1, 0.4], \exp), t_trig);
    var env = EnvGen.kr(Env.perc(0.01, 0.5), t_trig);

    var sig = SyncSaw.ar(100, 100 * pEnv);
    sig = BMoog.ar(sig, 4000, 0.4, 0);

    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\arpLaser);

Ndef(\arpLaserSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\arpLaser).nodeID }), \args, #[\t_trig],
    \dur, Pwhite(1.0, 3.0, inf), \t_trig, 1
)).play;
)

// ARP 5: Stutter Pad
(
Ndef(\arpStutter).fadeTime = 2;
Ndef(\arpStutter, {
    var freq = \freq.kr(110);
    var sig = Pulse.ar([freq, freq * 1.01], SinOsc.kr(0.2).range(0.1, 0.9));

    var gate = LFPulse.kr(16, width: 0.5);

	sig = BMoog.ar(sig, 2000, 0.1, 0);
    sig * gate * 0.3;
}).play;
Ndef(\master) <<> Ndef(\arpStutter);
)

// =============================================================================
// 4. THE BUCHLA FAMILY (West Coast, Wavefolding, Low Pass Gates)
// Concept: Instead of filtering a rich wave, we start with a Sine wave and
// FOLD it to create harmonics. We use Low Pass Gates (LPG) instead of ADSRs.
// =============================================================================

// BUCHLA 1: The "Bongo" Pluck (Classic LPG Vactrol strike)
(
Ndef(\buchlaBongo).fadeTime = 0.5;
Ndef(\buchlaBongo, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var fmRatio = \fmRatio.kr(1.51); // Non-integer for metallic/wood tones

    // Vactrol Envelope: Instant attack, steep exponential decay (-8)
    var lpgEnv = EnvGen.kr(Env.perc(0.001, 0.4, 1, -8), t_trig);

    // FM Setup
    var mod = SinOsc.ar(freq * fmRatio) * lpgEnv * 1000;
    var car = SinOsc.ar(freq + mod);

    // LPG Simulation: Envelope controls both amplitude AND a gentle lowpass
    var sig = LPF.ar(car, 200 + (lpgEnv * 3000));

    sig * lpgEnv * 0.5 ! 2;
}).play;
Ndef(\master) <<> Ndef(\buchlaBongo);

Ndef(\buchlaBongoSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\buchlaBongo).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.pelog, \degree, Pwhite(0, 7, inf),
    \dur, Pwrand([0.125, 0.25], [0.8, 0.2], inf), \t_trig, 1
)).play;
)

// BUCHLA 2: Complex Wavefolder Drone
(
Ndef(\buchlaDrone).fadeTime = 3;
Ndef(\buchlaDrone, {
    var freq = \freq.kr(55);
    // Slowly increasing the gain going into the wavefolder
    var foldDrive = SinOsc.kr(0.05).exprange(0.5, 5.0);

    var sig = SinOsc.ar([freq, freq * 1.01]);

    // The Buchla sound: Fold.ar bounces the wave back on itself when it exceeds bounds
    sig = Fold.ar(sig * foldDrive, -0.8, 0.8);

    // Add a little spring-like reverb
    sig = FreeVerb.ar(sig, 0.3, 0.9, 0.1);
    sig * 0.3;
}).play;
Ndef(\master) <<> Ndef(\buchlaDrone);
)

// BUCHLA 3: Timbres & Squelches (Modulated Fold)
(
Ndef(\buchlaSquish).fadeTime = 0.5;
Ndef(\buchlaSquish, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(110);
    var env = EnvGen.kr(Env.perc(0.01, 0.6), t_trig);
    var foldEnv = EnvGen.kr(Env.perc(0.1, 0.4), t_trig);

    var sig = LFTri.ar(freq);
    sig = Fold.ar(sig * (1 + (foldEnv * 4)), -0.5, 0.5);

    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\buchlaSquish);

Ndef(\buchlaSquishSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\buchlaSquish).nodeID }), \args, #[\freq, \t_trig],
    \freq, Pseq([110, 220, 165, 330], inf), \dur, 0.5, \t_trig, 1
)).play;
)

// BUCHLA 4: Uncertainty Arp (Randomized FM amounts)
(
Ndef(\buchlaAlien).fadeTime = 1;
Ndef(\buchlaAlien, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(440);
    // Sample & Hold effect on FM index
    var fmIndex = TRand.kr(100, 2000, t_trig);
    var lpgEnv = EnvGen.kr(Env.perc(0.005, 0.1, 1, -4), t_trig);

    var mod = SinOsc.ar(freq * 0.5) * fmIndex;
    var sig = SinOsc.ar(freq + mod);

    sig = LPF.ar(sig, 500 + (lpgEnv * 6000)) * lpgEnv;
    sig * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\buchlaAlien);

Ndef(\buchlaAlienSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\buchlaAlien).nodeID }), \args, #[\freq, \t_trig],
    \freq, Pexprand(200, 1000, inf), \dur, 0.125, \t_trig, 1
)).play;
)


// =============================================================================
// 5. ROLAND JUPITER-8 (Thick Polyphony, Cross-Mod, 24dB Filter)
// =============================================================================

// JUPITER 1: Cross-Modulation Lead (Audio-rate FM between VCOs)
(
Ndef(\jpLead).fadeTime = 0.5;
Ndef(\jpLead, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var xModDepth = \xmod.kr(300); // How hard Osc 2 pushes Osc 1

    var env = EnvGen.kr(Env.perc(0.05, 0.8), t_trig);

    var osc2 = Saw.ar(freq * 1.5); // Fixed interval for Osc 2
    var osc1 = Pulse.ar(freq + (osc2 * xModDepth), 0.5);

    var sig = Mix([osc1, osc2]) * 0.5;
    sig = MoogFF.ar(sig, 8000 * env, 0.5); // Jupiter had a great 24dB filter

    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\jpLead);

Ndef(\jpLeadSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\jpLead).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.dorian, \degree, Pseq([0, 2, 4, 7, 6, 4, 2, -1], inf),
    \dur, 0.25, \t_trig, 1
)).play;
)

// JUPITER 2: Lush String Pad (Detuned PWM)
(
Ndef(\jpPad).fadeTime = 3;
Ndef(\jpPad, {
    var freq = \freq.kr([110, 110]); // Array for chords
    var lfo = SinOsc.kr(0.4).range(0.1, 0.9);

    var osc1 = Pulse.ar(freq, width: lfo);
    var osc2 = Saw.ar(freq * 1.01);

    var sig = Splay.ar(osc1 + osc2);
    sig = MoogFF.ar(sig, 2500, 0.2);

    // Classic Roland 80s chorus simulation
    sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr([0.5, 0.6]).range(0.01, 0.02));

    sig * 0.3;
}).play;
Ndef(\master) <<> Ndef(\jpPad);

Ndef(\jpPadSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\jpPad).nodeID }), \args, #[\freq],
    \midinote, Pseq([ [[55, 59, 62]], [[53, 57, 60]] ], inf), \dur, 4
)).play;
)

// JUPITER 3: Sync Arp (Hard Sync with Envelope sweeping the Slave)
(
Ndef(\jpSync).fadeTime = 0.5;
Ndef(\jpSync, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(110);
    var env = EnvGen.kr(Env.perc(0.01, 0.5), t_trig);
    var sweepEnv = EnvGen.kr(Env.perc(0.01, 0.3), t_trig);

    var sig = SyncSaw.ar(freq, freq * (1 + (sweepEnv * 4)));
    sig = MoogFF.ar(sig, 6000, 0.5);

    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\jpSync);

Ndef(\jpSyncSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\jpSync).nodeID }), \args, #[\freq, \t_trig],
    \octave, Pseq([3, 4, 5, 4], inf), \degree, Pseq([0, 0, 0, 0], inf),
    \dur, 0.125, \t_trig, 1
)).play;
)

// JUPITER 4: Brassy Poly Chords
(
Ndef(\jpBrass).fadeTime = 0.5;
Ndef(\jpBrass, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr([220, 220, 220]);
    var env = EnvGen.kr(Env.perc(0.08, 1.2), t_trig);
    var fEnv = EnvGen.kr(Env.perc(0.12, 0.8), t_trig);

    var sig = Splay.ar(Saw.ar(freq * [0.995, 1, 1.005]));
    sig = MoogFF.ar(sig, 300 + (fEnv * 3000), 1.2);

    sig * env * 0.4;
}).play;
Ndef(\master) <<> Ndef(\jpBrass);
)


// =============================================================================
// 6. ROLAND JUNO (DCOs, Sub-Oscillator, and the Magic Chorus)
// =============================================================================

// JUNO 1: Classic Hover/Chord (Saw + Square + Sub + Chorus)
(
Ndef(\junoChord).fadeTime = 0.5;
Ndef(\junoChord, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr([220, 220, 220]);
    var env = EnvGen.kr(Env.perc(0.01, 1.5), t_trig);

    var saw = Saw.ar(freq);
    var pulse = Pulse.ar(freq, SinOsc.kr(0.3).range(0.2, 0.8));
    var sub = Pulse.ar(freq * 0.5, 0.5); // The classic Juno Sub

    var sig = Splay.ar(saw + pulse + sub) * 0.33;

    // Juno Chorus I Simulation (Rich, wide, slow)
    var chorus = DelayC.ar(sig, 0.05, SinOsc.kr([0.5, 0.55], [0, pi]).range(0.005, 0.015));

    // Juno filter setup: Static HPF into Enveloped LPF
    sig = HPF.ar(sig, 150);
    sig = MoogFF.ar(sig, 800 + (env * 4000), 0.5);

    sig = sig + chorus;

    sig * env * 0.4;
}).play;
Ndef(\master) <<> Ndef(\junoChord);

Ndef(\junoChordSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\junoChord).nodeID }), \args, #[\freq, \t_trig],
    \midinote, Pseq([ [[60, 64, 67]], [[55, 59, 62]], [[57, 60, 64]] ], inf),
    \dur, 2, \t_trig, 1
)).play;
)

// JUNO 2: Snappy Bass (Resonant, punchy envelope)
(
Ndef(\junoBass).fadeTime = 0.5;
Ndef(\junoBass, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(55);
    var env = EnvGen.kr(Env.perc(0.001, 0.4), t_trig);

    var sig = Saw.ar(freq) + Pulse.ar(freq * 0.5, 0.5); // Saw + Sub
    sig = MoogFF.ar(sig, 100 + (env * 2500), 2.5); // High resonance

    (sig * 1.5).tanh * env * 0.5 ! 2;
}).play;
Ndef(\master) <<> Ndef(\junoBass);

Ndef(\junoBassSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\junoBass).nodeID }), \args, #[\freq, \t_trig],
    \degree, Pseq([0, 0, 7, 0, 0, -2, 0, 3], inf), \octave, 3, \dur, 0.25, \t_trig, 1
)).play;
)

// JUNO 3: Shimmering Arp (PWM heavy)
(
Ndef(\junoArp).fadeTime = 0.5;
Ndef(\junoArp, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(440);
    var env = EnvGen.kr(Env.perc(0.01, 0.3), t_trig);

    var sig = Pulse.ar(freq, SinOsc.kr(1.5).range(0.1, 0.9));
    sig = MoogFF.ar(sig, 1000 + (env * 2000), 1.0);

    // Juno Chorus II Simulation (Faster, deeper)
    sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr([0.8, 0.85], [0, pi]).range(0.01, 0.025));

    sig * env * 0.3;
}).play;
Ndef(\master) <<> Ndef(\junoArp);

Ndef(\junoArpSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\junoArp).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minor, \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf),
    \dur, 0.125, \t_trig, 1
)).play;
)

// JUNO 4: Ghostly Pad (High pass filter focused)
(
Ndef(\junoPad).fadeTime = 3;
Ndef(\junoPad, {
    var freq = \freq.kr(110);
    var sig = Saw.ar([freq, freq*1.01]) + Pulse.ar([freq*2, freq*2.01], 0.5);

    // HPF cranked up to thin out the sound
    sig = HPF.ar(sig, 1000);
    sig = MoogFF.ar(sig, SinOsc.kr(0.1).exprange(1200, 4000), 0.5);

    sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr([0.4, 0.45]).range(0.01, 0.02));
    sig * 0.2;
}).play;
Ndef(\master) <<> Ndef(\junoPad);
)


// =============================================================================
// 7. YAMAHA CS-80 (Dual Layer, Ring Mod, Expressive Filtering)
// =============================================================================

// CS-80 1: Vangelis Brass (Blade Runner) - Dual Filter Setup
(
Ndef(\csBrass).fadeTime = 0.5;
Ndef(\csBrass, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr([110, 110, 110]);
    var env = EnvGen.kr(Env.perc(0.15, 1.5), t_trig);
    var fEnv = EnvGen.kr(Env.perc(0.2, 1.0), t_trig);

    // CS-80 detuned oscillators
    var sig = Splay.ar(Saw.ar(freq * [0.99, 1, 1.01]) + Pulse.ar(freq * [0.995, 1, 1.005], 0.5));

    // The CS-80 trick: A resonant HPF *before* the resonant LPF
    sig = HPF.ar(sig, 200 + (fEnv * 300), 1.5);
    sig = LPF.ar(sig, 800 + (fEnv * 3000), 1.5);

    sig * env * 0.4;
}).play;
Ndef(\master) <<> Ndef(\csBrass);

Ndef(\csBrassSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\csBrass).nodeID }), \args, #[\freq, \t_trig],
    \midinote, Pseq([ [[48, 55, 60]], [[46, 53, 58]] ], inf), \dur, 3, \t_trig, 1
)).play;
)

// CS-80 2: Global Ring Modulation Sequence
(
Ndef(\csRing).fadeTime = 0.5;
Ndef(\csRing, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var env = EnvGen.kr(Env.perc(0.01, 0.4), t_trig);

    var sig = Saw.ar(freq) + Saw.ar(freq * 1.01);

    // CS-80 Global Ring Modulator (Multiplier)
    var ringModFreq = \ringFreq.kr(80);
	sig = LPF.ar(sig, 2000);
    sig = sig * SinOsc.ar(ringModFreq);

    sig * env * 0.5 ! 2;
}).play;
Ndef(\master) <<> Ndef(\csRing);

Ndef(\csRingSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\csRing).nodeID }), \args, #[\freq, \t_trig],
    \freq, Pseq([220, 220, 440, 220], inf), \dur, 0.25, \t_trig, 1
)).play;
)

// CS-80 3: Gliding Sine/Saw Lead
(
Ndef(\csLead).fadeTime = 0.5;
Ndef(\csLead, {
    var t_trig = \t_trig.tr(1);
    var freq = Lag.kr(\freq.kr(440), 0.2); // Heavy glide
    var env = EnvGen.kr(Env.perc(0.05, 0.8), t_trig);

    // CS-80 lets you mix a pure Sine wave directly to the output to thicken it
    var saw = MoogFF.ar(Saw.ar(freq), 3000 * env, 0.5);
    var sine = SinOsc.ar(freq);

    var sig = (saw * 0.7) + (sine * 0.6);
    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\csLead);

Ndef(\csLeadSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\csLead).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minor, \degree, Pwhite(0, 10, inf), \dur, Pwrand([0.5, 1.0], [0.7, 0.3], inf), \t_trig, 1
)).play;
)

// CS-80 4: Expressive Pluck
(
Ndef(\csPluck).fadeTime = 0.5;
Ndef(\csPluck, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var env = EnvGen.kr(Env.perc(0.01, 0.5), t_trig);

    // Simulating pressure modulating the filter cutoff over time
    var pressureLFO = SinOsc.kr(4).range(0.8, 1.2);

    var sig = Saw.ar(freq);

    var cutoff = 100 + (2500 * env * pressureLFO);

    sig = LPF.ar(sig, cutoff);

    sig * env * 0.5 ! 2;
}).play;
Ndef(\master) <<> Ndef(\csPluck);

// The Sequence to trigger it
Ndef(\csPluckSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\csPluck).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.minor, \degree, Pseq([0, 2, 4, 7, 2, 4, 0, -1], inf),
    \dur, 0.25, \t_trig, 1
)).play;
)


// =============================================================================
// 8. FARFISA COMPACT (Transistor Organ, Divide-down, Bright/Buzzy)
// Concept: Organs don't usually have filter sweeps. Tone is created by summing
// multiple pulse/square waves across octaves, combined with vibrato.
// =============================================================================

// FARFISA 1: Psychedelic Rock Organ (60s style)
(
Ndef(\farfisaRock).fadeTime = 0.5;
Ndef(\farfisaRock, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr([220, 220, 220]); // Chords
    var env = EnvGen.kr(Env.perc(0.01, 1.0), t_trig);

    var vibrato = SinOsc.kr(7) * 3; // Fast, deep vibrato
    var baseFreq = freq + vibrato;

    // Organs sum octaves (16', 8', 4', 2')
    var osc16 = Pulse.ar(baseFreq * 0.5, 0.5) * 0.4;
    var osc8 = Pulse.ar(baseFreq, 0.1) * 0.8; // Narrow pulse = bright Farfisa tone
    var osc4 = Pulse.ar(baseFreq * 2, 0.5) * 0.3;

    var sig = Splay.ar(osc16 + osc8 + osc4);

    // Static EQ to emphasize the "buzz"
    sig = BPF.ar(sig, 2000, 1.5) + (sig * 0.5);

    sig * env * 0.3;
}).play;
Ndef(\master) <<> Ndef(\farfisaRock);

Ndef(\farfisaRockSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\farfisaRock).nodeID }), \args, #[\freq, \t_trig],
    \midinote, Pseq([ [[60, 64, 67]], [[60, 65, 69]] ], inf), \dur, 1, \t_trig, 1
)).play;
)

// FARFISA 2: Staccato Skank (Ska/Reggae organ chops)
(
Ndef(\farfisaChop).fadeTime = 0.5;
Ndef(\farfisaChop, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(440);
    // Extremely tight percussive envelope for organ stabs
    var env = EnvGen.kr(Env.perc(0.001, 0.15), t_trig);

    var sig = Pulse.ar(freq, 0.2) + Pulse.ar(freq * 2, 0.5);
    sig = LPF.ar(sig, 6000); // Tame the highest fizz

    sig * env * 0.4 ! 2;
}).play;
Ndef(\master) <<> Ndef(\farfisaChop);

Ndef(\farfisaChopSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\farfisaChop).nodeID }), \args, #[\freq, \t_trig],
    // Off-beat sequencing
    \dur, Pseq([0.25, Rest(0.25)], inf), \degree, 4, \t_trig, 1
)).play;
)

// FARFISA 3: The "Cheese" Drone (Multi-octave, heavily modulated)
(
Ndef(\farfisaDrone).fadeTime = 2;
Ndef(\farfisaDrone, {
    var freq = \freq.kr(110);
    var vibrato = SinOsc.kr(6.5) * 4;

    var sig = Mix.fill(4, { |i|
        // Creates 4 octaves (1, 2, 4, 8 multipliers)
        Pulse.ar((freq + vibrato) * (2 ** i), 0.1) * (0.5 ** i)
    });

    sig = sig + DelayC.ar(sig, 0.1, 0.05); // Spring reverb-ish slapback
    sig * 0.15 ! 2;
}).play;
Ndef(\master) <<> Ndef(\farfisaDrone);
)

// FARFISA 4: Dark Carnival (Detuned, beating organ)
(
Ndef(\farfisaCarnival).fadeTime = 0.5;
Ndef(\farfisaCarnival, {
    var t_trig = \t_trig.tr(1);
    var freq = \freq.kr(220);
    var env = EnvGen.kr(Env.perc(0.05, 0.5), t_trig);

    // Deliberately out of tune oscillators for that broken carousel vibe
    var sig = Pulse.ar(freq, 0.5) + Pulse.ar(freq * 1.02, 0.5);

    sig * env * 0.3 ! 2;
}).play;
Ndef(\master) <<> Ndef(\farfisaCarnival);

Ndef(\farfisaCarnivalSeq, Pbind(
    \type, \set, \id, Pfunc({ Ndef(\farfisaCarnival).nodeID }), \args, #[\freq, \t_trig],
    \scale, Scale.harmonicMinor, \degree, Pseq([0, 2, 1, -1], inf),
    \dur, 0.5, \t_trig, 1
)).play;
)