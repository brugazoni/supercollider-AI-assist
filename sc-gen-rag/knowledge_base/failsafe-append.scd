// Source: HIGH-T-generate-resilience.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: fmPad Reverb (Index 10)
// KEYWORDS: add_effects, append, combl, fmPad, fmpad, freeverb, gverb, index, ksPluck, noisePerc, reverb
(
// fmPad Reverb (Index 10)
Ndef(\fmPad)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.85, 0.1) };
Ndef(\fmPad).set(\wet10, 0);

// ksPluck Delay (Index 11)
Ndef(\ksPluck)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.375, 3) };
Ndef(\ksPluck).set(\wet11, 0);

// noisePerc Spatializer (Index 10)
Ndef(\noisePerc)[10] = \filter -> { |in| GVerb.ar(in.sum, 30, 1) * 0.5 };
Ndef(\noisePerc).set(\wet10, 0);
)

// Source: HIGH-T-generate-resilience.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: --- RESILIENCE SEQUENCES ---
// KEYWORDS: add_instrument, append, fmPad, ksPluck, noisePerc, padSeq, percSeq, pluckSeq, resilience, sequences
(
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
)

// Source: HIGH-T-generate-resilience.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Ndef(\noisePerc).xset(\wet10, 0); // Revert percussion verb
// KEYWORDS: add_instrument, append, fmPad, ksPluck, ndef, noisePerc, noiseperc, padSeq, percSeq, percussion, pluckSeq, revert, verb, wet, xset
(
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

// Source: append-arroio.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \sinos — Delicate metallic modal bells ("flor de pessegueiro", "sinos longínquos", "gazela arisca")
// KEYWORDS: add, add_effects, append, arisca, bells, delicate, flor, gazela, hpf, instrument, long, metallic, modal, nquos, pessegueiro, pinknoise, ringz, sinos, sinosSeq
(
// ADD_INSTRUMENT: \sinos — Delicate metallic modal bells ("flor de pessegueiro", "sinos longínquos", "gazela arisca")
// Resonant physical model excited by soft impulse strikes with wide stereophonic decay
Ndef(\sinos, { |freq=660, amp=0.18, pan=0, decay=2.8, brightness=1.2, t_trig=0|
    var trig = K2A.ar(t_trig);
    var exciter = Decay2.ar(trig, 0.0008, 0.015) * PinkNoise.ar(0.12);
    var modes = freq * [1.0, 2.003, 3.015, 4.22, 5.43, 6.78];
    var modeAmps = [1.0, 0.65, 0.4, 0.3, 0.18, 0.1] * [1, brightness, brightness * 0.8, brightness * 0.6, brightness * 0.4, brightness * 0.3];
    var modeDecays = decay * [1.0, 0.82, 0.65, 0.45, 0.3, 0.18];
    var sig = Ringz.ar(exciter, modes, modeDecays, modeAmps).sum;
    sig = HPF.ar(sig, 250);
    Pan2.ar(sig * amp, pan);
}).play;

// Distant space & diffusion slot for atmospheric distance
Ndef(\sinos)[10] = \filter -> { |in|
    var delayed = CombC.ar(in, 0.6, [0.37, 0.49], 3.2);
    LPF.ar(delayed, 3200);
};
Ndef(\sinos).xset(\wet10, 0.55);

// Agile, skittish sequence ("gazela arisca") leaping across delicate pentatonic intervals
Pbindef(\sinosSeq,
    \dur, Pwrand([0.25, 0.5, 0.75, 1.25, 2.5], [0.35, 0.3, 0.15, 0.1, 0.1], inf),
    \midinote, Pxrand([69, 72, 74, 76, 79, 81, 84, 86, 91], inf), // A minor / Hirajoshi-leaning pentatonic
    \decay, Pwhite(1.8, 3.8, inf),
    \brightness, Pwhite(0.7, 1.5, inf),
    \amp, Pexprand(0.08, 0.22, inf),
    \pan, Pwhite(-0.75, 0.75, inf),
    \t_trig, 1
);

// Route native pattern stream to proxy control bus
Ndef(\sinos)[1] = \set -> Pbindef(\sinosSeq);
)

// Source: append-arroio.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \queda - Cascading water, fizzing foam, and modal resonance suspended on jasper
// KEYWORDS: add, add_effects, append, bpf, brownnoise, cascading, dynklank, fizzing, foam, freeverb2, hpf, instrument, jasper, modal, pinknoise, queda, quedaSeq, resonance, suspended, water
(
// ADD_INSTRUMENT: \queda - Cascading water, fizzing foam, and modal resonance suspended on jasper
Ndef(\queda, { |freq=440, amp=0.28, pan=0, t_trig=0, decay=2.6, bright=4200, foamAmp=0.22|
	var trig, exciter, foam, modes, rings, jasper, sig;

	trig = K2A.ar(t_trig);

	// Aerated turbulence and spray
	foam = HPF.ar(WhiteNoise.ar, bright) * Decay2.ar(trig, 0.01, 0.5) * foamAmp;
	foam = foam + (BPF.ar(PinkNoise.ar, LFNoise1.kr(0.4).exprange(1200, 5200), 0.25) * 0.15);

	// Hydrodynamic surge exciting mineral modes
	exciter = (LPF.ar(BrownNoise.ar, 750) * Decay2.ar(trig, 0.008, 0.2) * 2.2) + (foam * 0.4);

	// Jasper coast inharmonic modal bank
	modes = freq * [1.0, 1.74, 2.58, 3.86, 5.21];
	rings = [1.8, 1.5, 1.1, 0.7, 0.4] * decay;
	jasper = DynKlank.ar(`[modes, [0.35, 0.25, 0.2, 0.12, 0.07], rings], exciter);

	sig = (jasper * 0.65) + Splay.ar(foam * [0.8, 1.2]);
	Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

Pbindef(\quedaSeq,
	\dur, Pseq([0.75, 0.5, 1.0, 0.25, 1.5, 0.5], inf),
	\t_trig, 1,
	\midinote, Pseq([55, 62, 67, 71, 74, 69], inf), // Suspended mineral harmony
	\decay, Pwhite(2.0, 3.5, inf),
	\bright, Pwhite(3200, 7800, inf),
	\foamAmp, Pwhite(0.18, 0.32, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\amp, 0.28
);

Ndef(\queda)[1] = \set -> Pbindef(\quedaSeq);

// ADD_EFFECTS: Slot 10 - Expansive suspension mist
Ndef(\queda)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.18)
};
Ndef(\queda).xset(\wet10, 0.42);
// Ndef(\queda).xset(\wet10, 0); // Revert tweak
)

// Source: append-arroio.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: "tronco" — low wooden modal resonance providing a solid grounding anchor in the valley
// KEYWORDS: add, add_effects, anchor, append, grounding, instrument, leakdc, low, modal, pinknoise, providing, resonance, ringz, sinosc, solid, the, tronco, troncoSeq, valley, wooden
(
// ADD_INSTRUMENT: "tronco" — low wooden modal resonance providing a solid grounding anchor in the valley
Ndef(\tronco, { |freq=65.4, amp=0.45, pan=0, decayTime=2.2, damp=1400, t_trig=0|
	var trig = K2A.ar(t_trig);
	var exciter = (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015), trig) * 0.8)
		+ (LPF.ar(Impulse.ar(0), 3000) * EnvGen.ar(Env.perc(0.0005, 0.008), trig) * 0.6);
	var modes = [1.0, 1.88, 2.76, 4.15];
	var amps = [1.0, 0.5, 0.3, 0.12];
	var ringTimes = [decayTime, decayTime * 0.65, decayTime * 0.38, decayTime * 0.18];
	var res = modes.collect({ |m, i|
		Ringz.ar(exciter, freq * m, ringTimes[i]) * amps[i]
	}).sum;
	var sub = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.02, decayTime * 0.8), trig) * 0.35;
	var sig = LeakDC.ar(LPF.ar(res + sub, damp).tanh) * amp;
	Pan2.ar(sig, pan);
}).play;

// Sequence for tronco: deliberate, low fundamental cadences anchoring the valley texture (Settling / Resolution archetype)
Pbindef(\troncoSeq,
	\dur, Pseq([4, 3, 5, 4], inf),
	\midinote, Pseq([36, 31, 38, 33], inf), // C2, G1, D2, A1
	\decayTime, Pseq([2.2, 2.8, 1.9, 3.2], inf),
	\damp, Pwhite(1000, 1600, inf),
	\amp, Pseq([0.48, 0.42, 0.52, 0.45], inf),
	\pan, Pseq([0, -0.2, 0.2, 0], inf),
	\t_trig, 1
);

Ndef(\tronco)[1] = \set -> Pbindef(\troncoSeq);

// Slot 10: resonant woody body / valley acoustic reflection
Ndef(\tronco)[10] = \filter -> { |in|
	CombC.ar(LPF.ar(in, 1800), 0.5, [0.18, 0.26], 2.2);
};
Ndef(\tronco).xset(\wet10, 0.28);
// Ndef(\tronco).xset(\wet10, 0); // Revert tweak
)

// Source: append-arroio.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Extrinsic Limit (d): Finalize piece — stop all sequencers and dissolve all layers into silence
// KEYWORDS: add_instrument, all, append, arroio, dissolve, extrinsic, finalize, into, latidos, latidosSeq, layers, limit, piece, queda, quedaSeq, rosaPad, rosaSeq, sequencers, silence, sinos, sinosSeq, stop, tronco, troncoSeq
(
// Extrinsic Limit (d): Finalize piece — stop all sequencers and dissolve all layers into silence

// 1. Stop all active Pbindef streams
Pbindef(\latidosSeq).stop;
Pbindef(\troncoSeq).stop;
Pbindef(\sinosSeq).stop;
Pbindef(\quedaSeq).stop;
Pbindef(\rosaSeq).stop;

// 2. Staggered fade and clearance of all active sound generators
Ndef(\latidos).fadeTime = 3;
Ndef(\latidos).clear(3);

Ndef(\tronco).fadeTime = 4;
Ndef(\tronco).clear(4);

Ndef(\sinos).fadeTime = 6;
Ndef(\sinos).clear(6);

Ndef(\queda).fadeTime = 8;
Ndef(\queda).clear(8);

Ndef(\rosaPad).fadeTime = 12;
Ndef(\rosaPad).clear(12);

Ndef(\arroio).fadeTime = 14;
Ndef(\arroio).clear(14);
)

// Source: append-arroio.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \pedraBranca — Resonant mineral physical modeling for nocturnal, crystalline contemplation (Settling/Archetype c)
// KEYWORDS: add, add_effects, append, archetype, contemplation, crystalline, for, freeverb2, instrument, leakdc, mineral, modeling, nocturnal, pedraBranca, pedraSeq, pedrabranca, physical, pinknoise, resonant, ringz, settling
(
// ADD_INSTRUMENT: \pedraBranca — Resonant mineral physical modeling for nocturnal, crystalline contemplation (Settling/Archetype c)
Ndef(\pedraBranca, { |freq=440, amp=0.2, decayTime=2.5, pan=0, t_trig=0|
	var trig, exc, modes, modeAmps, modeDecays, sig;
	trig = K2A.ar(t_trig);
	exc = (Decay2.ar(trig, 0.001, 0.02) * PinkNoise.ar(0.6)) + (trig * 0.25);
	modes = [1, 2.756, 5.404, 8.933, 11.21];
	modeAmps = [1, 0.55, 0.35, 0.2, 0.1];
	modeDecays = [decayTime, decayTime * 0.65, decayTime * 0.45, decayTime * 0.3, decayTime * 0.18];
	sig = Mix.fill(modes.size, { |i|
		Ringz.ar(exc, (freq * modes[i]).clip(20, 18000), modeDecays[i], modeAmps[i])
	});
	sig = LeakDC.ar(sig) * 0.22;
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\pedraSeq,
	\dur, Pseq([1.5, 1.0, 0.75, 2.25, 1.25, 0.75, 2.0], inf),
	\midinote, Pseq([60, 67, 71, 74, 69, 72, 79, 76], inf),
	\decayTime, Pwhite(2.0, 3.5, inf),
	\amp, Pwhite(0.2, 0.32, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\t_trig, 1
);

Ndef(\pedraBranca)[1] = \set -> Pbindef(\pedraSeq);

// ADD_EFFECTS: Slot [10] creates a pure stone-chamber reverberation space
Ndef(\pedraBranca)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.25);
};
Ndef(\pedraBranca).set(\wet10, 0.38);
// Ndef(\pedraBranca).set(\wet10, 0); // Revert wetness
)

// Source: append-arroio.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \rioSena (Formal Archetype: Settling/Flashback (c) — evoking the flowing Seine and nostalgic memories)
// KEYWORDS: add, add_effects, append, archetype, bpf, brownnoise, dynklank, evoking, flashback, flowing, formal, hpf, instrument, memories, nostalgic, pinknoise, rioSena, riosena, seine, senaSeq, settling, sinosc, the
(
// ADD_INSTRUMENT: \rioSena (Formal Archetype: Settling/Flashback (c) — evoking the flowing Seine and nostalgic memories)
Ndef(\rioSena, { |freq=260, amp=0.22, pan=0, t_trig=0, decay=2.2, flow=0.35, cutoff=1800|
	var env, exciter, modes, tones, water, sig;
	env = EnvGen.ar(Env.perc(0.02, decay, 1, -4), t_trig);
	exciter = PinkNoise.ar(0.06) * EnvGen.ar(Env.perc(0.001, 0.035), t_trig);
	exciter = exciter + (SinOsc.ar(freq * 2.5) * EnvGen.ar(Env.perc(0.001, 0.015), t_trig) * 0.12);
	modes = freq * [1, 1.498, 2.01, 2.76, 3.42];
	tones = DynKlank.ar(`[modes, [0.4, 0.25, 0.2, 0.12, 0.08], [decay, decay * 0.85, decay * 0.65, decay * 0.45, decay * 0.3]], exciter);
	water = BPF.ar(BrownNoise.ar, SinOsc.kr(flow * [0.65, 1.15]).range(160, 560), 0.38) * 0.14;
	sig = (tones * env) + water;
	sig = LPF.ar(sig, cutoff);
	Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

// ADD_EFFECTS: Comb reverberation blurring water droplets into long memory reflections
Ndef(\rioSena)[10] = \filter -> { |in|
	var wet;
	wet = CombC.ar(in, 0.6, [0.375, 0.5], 2.8);
	wet = HPF.ar(wet, 120);
	wet;
};
Ndef(\rioSena).xset(\wet10, 0.35);

// Fluid sequence contour reflecting nostalgic sorrow and release
Pbindef(\senaSeq,
	\dur, Pseq([0.75, 0.5, 0.75, 1.0, 0.5, 1.5], inf),
	\midinote, Pseq([57, 60, 64, 65, 62, 59, 60, 67], inf),
	\decay, Pwhite(1.6, 2.6, inf),
	\pan, Pwhite(-0.4, 0.4, inf),
	\amp, Pwhite(0.18, 0.25, inf),
	\cutoff, Pexprand(1400, 3000, inf),
	\t_trig, 1
);

Ndef(\rioSena)[1] = \set -> Pbindef(\senaSeq);
)

// Source: append-arroio.scd [Block 8]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \cobra — serpentine, wavefolded FM bass winding towards low subterranean frequencies
// KEYWORDS: add, add_effects, allpassc, append, bass, cobra, cobraSeq, frequencies, instrument, leakdc, low, rioSena, rlpf, serpentine, sinosc, subterranean, towards, wavefolded, winding
(
// ADD_INSTRUMENT: \cobra — serpentine, wavefolded FM bass winding towards low subterranean frequencies
Ndef(\cobra, { |freq=55, amp=0.24, pan=0, t_trig=0, glide=0.22, fold=1.6, cutoff=850, rq=0.35, rel=1.8|
	var lagFreq, env, mod, osc, folded, filt, sig;
	lagFreq = VarLag.kr(freq, glide, \sin);
	env = EnvGen.ar(Env.perc(0.06, rel, 1, -4), K2A.ar(t_trig));
	mod = SinOsc.ar(lagFreq * 1.5) * (lagFreq * 0.75);
	osc = SinOsc.ar(lagFreq + mod);
	folded = (osc * fold).fold2(0.85) * 1.15;
	filt = RLPF.ar(folded, (cutoff * env + 45).clip(30, 10000), rq);
	sig = LeakDC.ar(filt);
	Pan2.ar(sig * env * amp, pan);
}).play;

// ADD_EFFECTS: Undulating spatial dispersion for the serpent's trajectory
Ndef(\cobra)[10] = \filter -> { |in|
	AllpassC.ar(in, 0.2, SinOsc.kr([0.07, 0.11]).range(0.03, 0.07), 2.2);
};
Ndef(\cobra).set(\wet10, 0.35);

// Pbindef: Descending winding trajectory, inexorably slithering down to the lowest grave tones
Pbindef(\cobraSeq,
	\dur, Pseq([0.5, 0.75, 0.25, 1.0, 0.5, 1.5], inf),
	\midinote, Pseq([45, 46, 43, 44, 40, 38, 35, 33], inf),
	\glide, Pseq([0.2, 0.35, 0.15, 0.45], inf),
	\fold, Pwhite(1.2, 2.4, inf),
	\cutoff, Pexprand(550, 2200, inf),
	\rel, Pseq([1.4, 0.9, 1.8, 2.4], inf),
	\amp, 0.22,
	\pan, Pseq([-0.45, 0.35, -0.2, 0.5, -0.6, 0.1], inf),
	\t_trig, 1
);
Ndef(\cobra)[1] = \set -> Pbindef(\cobraSeq);

// TWEAK_EFFECTS: Expanding reverberant comb space on \rioSena towards oceanic diffusion (Resolution towards the sea)
Ndef(\rioSena).xset(\wet10, 0.55);
// Ndef(\rioSena).xset(\wet10, 0.35); // Revert tweak
)

// Source: append-arroio.scd [Block 9]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: History.end;
// KEYWORDS: append, bpf, brownnoise, end, freeverb2, history, jaguar, live_patch, rlpf
(
Ndef(\jaguar).clear;
Ndef(\jaguar, {
	|freq=100, dur=1.8, amp=0.8, t_trig=1|
	var ampEnv, pitchEnv, filterEnv, jitter, vocalFolds, breath, roar, formants, bodyRes, snd;

	ampEnv = EnvGen.ar(Env([0, 1, 0.7, 0], [0.05, 0.3, 0.65] * dur, [-4, -2, -4]), t_trig);
	pitchEnv = EnvGen.ar(Env([150, 50, 25], [0.2, 0.8] * dur, \exp), t_trig) * (freq/100);
	filterEnv = EnvGen.ar(Env([1500, 700, 200], [0.3, 0.7] * dur, \exp), t_trig);

	jitter = LFNoise1.kr(20).range(0.9, 1.1);
	vocalFolds = SyncSaw.ar(pitchEnv * jitter, pitchEnv * jitter * 2.5);
	breath = BrownNoise.ar() * EnvGen.ar(Env.perc(0.05, dur * 0.8), t_trig) * 0.5;

	roar = (vocalFolds + breath) * 3;
	roar = roar.fold2(0.8).cubed;

	formants = BPF.ar(roar, [filterEnv, filterEnv * 2.2, filterEnv * 3.5], [0.3, 0.4, 0.5]).sum;
	bodyRes = RLPF.ar(roar, pitchEnv * 4, 0.6) * 0.5;

	snd = (formants + bodyRes) * ampEnv;
	snd = FreeVerb2.ar(snd, snd, 0.15, 0.6, 0.2);
	snd * amp;
}).play;
)

// Source: append-arroio.scd [Block 10]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Arroio sound structure with \jaguar
// KEYWORDS: add_instrument, append, arroio, jagSeq, jaguar, structure
(
Pbindef(\jagSeq, \dur, 3, \dur_attr, 2.2, \t_trig, 1);
Ndef(\jaguar).quant = 1;
Ndef(\jaguar)[1] = \set -> Pbindef(\jagSeq);
)

// Source: append-arroio.scd [Block 11]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Arroio sound structure with \jaguar
// KEYWORDS: add_effects, allpassc, append, arroio, gverb, jaguar, structure
(
Ndef(\jaguar)[10] = \filter -> { |in| GVerb.ar(in.sum, 150, 6) };
Ndef(\jaguar).set(\wet10, 0);
Ndef(\jaguar)[11] = \filter -> { |in| AllpassC.ar(in, 1, 0.4, 4) };
Ndef(\jaguar).set(\wet11, 0);
Ndef(\jaguar)[12] = \filter -> { |in| (in * 6).wrap2(0.8) };
Ndef(\jaguar).set(\wet12, 0);
)

// Source: append-bird-bat-crater.scd [Block 1]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: ADD_INSTRUMENT: Ndef(\rearmouse)
// KEYWORDS: add, append, hpf, instrument, live_patch, ndef, pinknoise, rearmouse, sinosc
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
)

// Source: append-bird-bat-crater.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: SEQUENCE: Pbindef(\rearmouseSeq)
// KEYWORDS: add_instrument, append, pbindef, rearmouse, rearmouseSeq, rearmouseseq, sequence
(
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
)

// Source: append-bird-bat-crater.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_EFFECTS: Echolocation reflection delay
// KEYWORDS: add, add_effects, append, delay, echolocation, effects, rearmouse, reflection
(
// ADD_EFFECTS: Echolocation reflection delay
Ndef(\rearmouse)[10] = \filter -> { |in|
    var delayTime = \delay.kr(0.06).clip(0.001, 0.2);
    var decayTime = \decay.kr(1.2).clip(0.01, 5.0);
    CombC.ar(in, 0.2, delayTime, decayTime);
};
Ndef(\rearmouse).xset(\wet10, 0); // Initialize wetness to 0
)

// Source: append-bird-bat-crater.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: TWEAK_SEQUENCE: Shift the rearmouse sequence to represent the autumn "twittering call".
// KEYWORDS: add_instrument, append, autumn, call, rearmouse, rearmouseSeq, represent, sequence, shift, the, tweak, twittering
(
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
)

// Source: append-bird-bat-crater.scd [Block 5]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: ADD_INSTRUMENT: Ndef(\giiwas)
// KEYWORDS: add, append, dynklank, giiwas, instrument, live_patch, ndef, pinknoise, sinosc
(
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
)

// Source: append-bird-bat-crater.scd [Block 6]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: SEQUENCE: Pbindef(\giiwasSeq)
// KEYWORDS: add_instrument, append, giiwas, giiwasSeq, giiwasseq, pbindef, sequence
(
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
)

// Source: append-bird-bat-crater.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_EFFECTS: Vast caldera space reverb
// KEYWORDS: add, add_effects, append, caldera, effects, freeverb, giiwas, reverb, space, vast
(
// ADD_EFFECTS: Vast caldera space reverb
// Simulates the immense open air and icy rim of Crater Lake in winter.
Ndef(\giiwas)[10] = \filter -> { |in|
    FreeVerb.ar(in, mix: 1.0, room: 0.95, damp: 0.15);
};
Ndef(\giiwas).xset(\wet10, 0); // Initialize wetness to 0
)

// Source: append-bird-bat-crater.scd [Block 8]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: TWEAK_EFFECTS: Fade in the caldera reverb to establish the vast, cold space.
// KEYWORDS: add_instrument, append, caldera, cold, effects, establish, fade, giiwas, rearmouseSeq, reverb, space, the, tweak, vast
(
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

// Source: append-cilios.scd [Block 1]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \cilios — whispering, resonant noise flutter evoking the fragile blink of eyelashes
// KEYWORDS: add, add_instrument, append, blink, bpf, cilios, ciliosSeq, evoking, eyelashes, flutter, fragile, instrument, leakdc, noise, pinknoise, resonant, ringz, sinosc, the, whispering, whitenoise
(
// ADD_INSTRUMENT: \cilios — whispering, resonant noise flutter evoking the fragile blink of eyelashes
Ndef(\cilios).fadeTime = 3;
Ndef(\cilios, { |freq=980, amp=0.18, pan=0, atk=0.12, rel=2.2, rq=0.025, flutter=6, t_trig=0|
	var trigAr, env, flutterSig, noise, exc, res, sig;
	trigAr = K2A.ar(t_trig);
	env = EnvGen.ar(Env.perc(atk, rel, 1, -3), trigAr);
	flutterSig = SinOsc.kr(flutter).range(0.5, 1.0);
	noise = (PinkNoise.ar * 0.6) + (WhiteNoise.ar * 0.15);
	// Narrow BPF with makeup gain for delicate airy excitation
	exc = BPF.ar(noise, freq, rq) * 12.0;
	// Resonant micro-modes resembling glass-like silken flutter
	res = Ringz.ar(exc, [freq, freq * 1.503, freq * 2.01], 0.35).sum * 0.25;
	sig = LeakDC.ar((exc + res) * env * flutterSig * amp);
	Pan2.ar(sig, pan);
}).play;

Pbindef(\ciliosSeq,
	\dur, Pseq([3.0, 2.5, 4.0, 1.5, 3.5], inf),
	\freq, Pseq([840, 1120, 1340, 670, 980, 1680], inf),
	\atk, Pwhite(0.08, 0.22, inf),
	\rel, Pwhite(1.6, 3.0, inf),
	\rq, Pwhite(0.018, 0.035, inf),
	\flutter, Pwhite(4.5, 8.5, inf),
	\amp, Pwhite(0.12, 0.2, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\t_trig, 1
);

Ndef(\cilios)[1] = \set -> Pbindef(\ciliosSeq);

// Pbindef(\ciliosSeq).stop; Ndef(\cilios).fadeTime = 2; Ndef(\cilios).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \piolhos — delicate electric crackles and high-frequency micro-bursts evoking crushing lice under fingernails
// KEYWORDS: add, add_instrument, append, bpf, bursts, crackles, crushing, delicate, electric, evoking, fingernails, frequency, high, hpf, instrument, leakdc, lice, micro, piolhos, piolhosSeq, sinosc, under, whitenoise
(
// ADD_INSTRUMENT: \piolhos — delicate electric crackles and high-frequency micro-bursts evoking crushing lice under fingernails
Ndef(\piolhos, { |freq=3400, amp=0.3, pan=0, t_trig=0, clickDecay=0.018, body=0.4|
	var trig, env, popPitch, pop, snapNoise, sig;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.0003, clickDecay);
	popPitch = freq * (1 + (env * 5));
	pop = SinOsc.ar(popPitch) * env;
	snapNoise = BPF.ar(WhiteNoise.ar, freq * 1.6, 0.12) * env * 4.0;
	sig = (pop + snapNoise);
	sig = LeakDC.ar(sig.fold2(0.85));
	sig = HPF.ar(sig, 1200);
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\piolhosSeq,
	\dur, Prand([0.0625, 0.0625, 0.125, 0.1875, Pseq([0.03125, 0.03125], 1)], inf),
	\t_trig, 1,
	\midinote, Pwhite(84, 104),
	\clickDecay, Pwhite(0.006, 0.032, inf),
	\amp, Pwhite(0.18, 0.38, inf),
	\pan, Pwhite(-0.75, 0.75, inf)
);

Ndef(\piolhos)[1] = \set -> Pbindef(\piolhosSeq);

// Pbindef(\piolhosSeq).stop; Ndef(\piolhos).fadeTime = 2; Ndef(\piolhos).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: "gaita" - languid, drunken reed voice with breathing noise and drifting microtones
// KEYWORDS: add, add_instrument, append, bpf, breathing, drifting, drunken, gaita, gaitaSeq, instrument, languid, leakdc, microtones, noise, pinknoise, pulse, reed, saw, sinosc, voice
(
// ADD_INSTRUMENT: "gaita" - languid, drunken reed voice with breathing noise and drifting microtones
Ndef(\gaita, { |freq=220, amp=0.25, pan=0, t_trig=0, atk=0.7, rel=2.8, reed=0.5, breath=0.18, detune=2.0|
	var trig = K2A.ar(t_trig);
	var env = EnvGen.ar(Env.perc(atk, rel, curve: -2), trig);
	var breathNoise = PinkNoise.ar() * breath * LFNoise1.kr(3).range(0.6, 1.2);
	var f0 = freq + LFNoise2.kr(1.2).bipolar(detune);
	var osc1 = Pulse.ar(f0, LFNoise1.kr(0.4).range(0.35, 0.65));
	var osc2 = Saw.ar(f0 * 1.005);
	var sub = SinOsc.ar(f0 * 0.5) * 0.25;
	var raw = (osc1 * 0.45) + (osc2 * 0.45) + sub + breathNoise;
	var reedFilt = BPF.ar(raw, [f0 * 1.5, f0 * 2.8, f0 * 4.2], [0.3, 0.25, 0.35]).sum * 2.5;
	var sig = (reedFilt * reed) + (raw * (1 - reed));
	sig = LPF.ar(sig, (freq * 5).clip(300, 7500));
	sig = LeakDC.ar((sig * 2.2).tanh) * env * amp;
	Pan2.ar(sig, pan);
}).play;

Pbindef(\gaitaSeq,
	\dur, Pseq([2.5, 1.5, 3.0, 2.0, 4.0], inf),
	\midinote, Pseq([55, 58, 62, 60, 57, 53, 55], inf),
	\detune, Pwhite(1.5, 4.0, inf),
	\atk, Pwhite(0.6, 1.4, inf),
	\rel, Pwhite(2.2, 4.2, inf),
	\amp, Pwhite(0.22, 0.32, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\t_trig, 1
);

Ndef(\gaita)[1] = \set -> Pbindef(\gaitaSeq);

// Pbindef(\gaitaSeq).stop; Ndef(\gaita).fadeTime = 2; Ndef(\gaita).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_EFFECTS: Vast spatial reverb across all layers to initiate a Settling (c) / spatial expansion phase
// KEYWORDS: across, add, add_effects, all, append, cilios, effects, expansion, freeverb2, gaita, initiate, layers, phase, piolhos, reverb, settling, spatial, vast
(
// ADD_EFFECTS: Vast spatial reverb across all layers to initiate a Settling (c) / spatial expansion phase

// 1. Layer: \cilios
Ndef(\cilios)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.25);
};
Ndef(\cilios).xset(\wet10, 0.45);
// Ndef(\cilios).set(\wet10, 0); // Rollback: disable reverb on \cilios

// 2. Layer: \gaita
Ndef(\gaita)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.95, damp: 0.2);
};
Ndef(\gaita).xset(\wet10, 0.4);
// Ndef(\gaita).set(\wet10, 0); // Rollback: disable reverb on \gaita

// 3. Layer: \piolhos
Ndef(\piolhos)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.9, damp: 0.35);
};
Ndef(\piolhos).xset(\wet10, 0.5);
// Ndef(\piolhos).set(\wet10, 0); // Rollback: disable reverb on \piolhos
)

// Source: append-cilios.scd [Block 5]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \arAzul — Expansive resonant breeze and microtonal blooming floral clusters (Settling/Resolution)
// KEYWORDS: add, add_effects, append, arAzul, arAzulSeq, arazul, blooming, bpf, breeze, clusters, expansive, floral, freeverb2, instrument, microtonal, pinknoise, resolution, resonant, settling, sinosc
(
// ADD_INSTRUMENT: \arAzul — Expansive resonant breeze and microtonal blooming floral clusters (Settling/Resolution)
Ndef(\arAzul, { |freq=220, amp=0.22, pan=0, atk=1.2, rel=3.5, chaos=0.3, cutoff=3500, t_trig=0|
	var env = EnvGen.ar(Env.perc(atk, rel, curve: -2), t_trig);
	var airExciter = PinkNoise.ar(0.35);
	var air = BPF.ar(airExciter, (freq * [1, 1.498, 2.01]).clip(40, 16000), 0.1).sum;
	var bloom = Mix.fill(5, { |i|
		SinOsc.ar(
			freq * (i * 0.618 + 1) * LFNoise2.kr(0.3 + (i * 0.1)).bipolar(chaos * 0.03).midiratio,
			0,
			(1 / (i + 1).sqrt)
		)
	});
	var sig = (air * 0.3) + (bloom * env * 0.7);
	sig = LPF.ar(sig, cutoff.clip(100, 18000));
	Pan2.ar(sig * amp, pan);
}).play;

Ndef(\arAzul).fadeTime = 3;

Pbindef(\arAzulSeq,
	\dur, Pseq([1.5, 2.0, 1.0, 2.5, 3.0], inf),
	\midinote, Pseq([55, 59, 62, 66, 69, 71, 74], inf),
	\t_trig, 1,
	\atk, Pwhite(0.8, 2.0, inf),
	\rel, Pwhite(2.5, 5.0, inf),
	\chaos, Pwhite(0.2, 0.6, inf),
	\cutoff, Pwhite(2500, 6000, inf),
	\amp, Pwhite(0.18, 0.28, inf),
	\pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\arAzul)[1] = \set -> Pbindef(\arAzulSeq);

// ADD_EFFECTS: Vast spatial resonance invoking the opening window
Ndef(\arAzul)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.96, damp: 0.15);
};
Ndef(\arAzul).set(\wet10, 0.55);

// Ndef(\arAzul).set(\wet10, 0); // Rollback: disable this effect
// Pbindef(\arAzulSeq).stop; Ndef(\arAzul).fadeTime = 2; Ndef(\arAzul).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 6]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Settling (c): Dissolve peripheral textures, leaving only \arAzul suspended in resonance
// KEYWORDS: add_instrument, append, arazul, cilios, ciliosSeq, dissolve, gaita, gaitaSeq, leaving, only, peripheral, piolhos, piolhosSeq, resonance, settling, suspended, textures
(
// Settling (c): Dissolve peripheral textures, leaving only \arAzul suspended in resonance

// Stop active sequences
Pbindef(\ciliosSeq).stop;
Pbindef(\gaitaSeq).stop;
Pbindef(\piolhosSeq).stop;

// Staggered fade out and clear proxies
Ndef(\piolhos).fadeTime = 4;
Ndef(\piolhos).clear(4);

Ndef(\cilios).fadeTime = 6;
Ndef(\cilios).clear(6);

Ndef(\gaita).fadeTime = 8;
Ndef(\gaita).clear(8);
)

// Source: append-cilios.scd [Block 7]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Intrinsic Limit (b) - surging cyclone of turbulent low air carrying dual modal voices and silver resonant swarms
// KEYWORDS: add_instrument, air, append, archetype, bpf, carrying, cicloneRubro, cicloneSeq, cyclone, dual, fold, formal, intrinsic, limit, low, modal, moogff, pinknoise, resonant, ringz, saw, silver, surging, swarms, turbulent, voices
(
// --- ADD_INSTRUMENT: Ciclone Rubro & Duas Irmãs ---
// Formal archetype: Intrinsic Limit (b) - surging cyclone of turbulent low air carrying dual modal voices and silver resonant swarms
Ndef(\cicloneRubro, { |freq=55, amp=0.28, pan=0, t_trig=0, swirlRate=0.35, ffreq=320, rq=0.22, silverCut=3400|
	var trig, env, storm, sisters, silverSwarm, sig;

	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.06, 1.9);

	// Ciclone rubro: deep filtered noise swept by slow chaotic low-frequency agitation
	storm = PinkNoise.ar * LFNoise1.kr(swirlRate.max(0.01) * [1.13, 0.87]).exprange(0.4, 1.4);
	storm = BPF.ar(storm, (ffreq * LFNoise2.kr(0.4 ! 2).exprange(0.75, 1.45)).clip(50, 4500), rq) * 7.5;

	// Duas irmãs: twin detuned wavefolded saws looming at the center
	sisters = Saw.ar(freq * [0.994, 1.006]);
	sisters = Fold.ar(sisters * 2.8, -0.75, 0.75);
	sisters = MoogFF.ar(sisters, (freq * 3.5 * (1 + (env * 1.6))).clip(80, 7500), 2.6) * 2.2;

	// Enxames brancos / unhas de prata: crystalline metallic modal ringing excited by fast dust bursts
	silverSwarm = Dust.ar(24 ! 2) * Decay.ar(trig, 0.3);
	silverSwarm = Ringz.ar(silverSwarm, silverCut * [1.0, 1.34], 0.18).tanh * 0.45;

	sig = LeakDC.ar((storm * 0.7) + (sisters * 0.85) + silverSwarm);
	sig = Balance2.ar(sig[0], sig[1], pan, amp * (0.6 + (env * 0.4)));
	sig;
}).play;

Pbindef(\cicloneSeq,
	\dur, Pseq([1.5, 0.75, 0.75, 2.0, 1.0], inf),
	\midinote, Pseq([34, 34, 46, 36, 41], inf), // Deep twin modal foundation (Bb0, Bb1, C1, F1)
	\t_trig, 1,
	\ffreq, Pseq([220, 380, 560, 300, 440], inf),
	\swirlRate, Pwhite(0.25, 0.8, inf),
	\rq, Pwhite(0.12, 0.25, inf),
	\silverCut, Pseq([2800, 3600, 4400, 3200], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\amp, 0.28
);

Ndef(\cicloneRubro)[1] = \set -> Pbindef(\cicloneSeq);

// Pbindef(\cicloneSeq).stop; Ndef(\cicloneRubro).fadeTime = 2; Ndef(\cicloneRubro).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 8]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. ADD_EFFECTS: Low-pass filter at 500 Hz on \cicloneRubro
// KEYWORDS: add, add_effects, append, bpf, cicloneRubro, ciclonerubro, effects, filter, low, pass, piolhos, piolhosSeq
(
// --- Settling / Flashback (c): Subdue cyclone with 500 Hz LPF and restore micro-parasitic "piolhos" texture ---

// 1. ADD_EFFECTS: Low-pass filter at 500 Hz on \cicloneRubro
Ndef(\cicloneRubro)[10] = \filter -> { |in, cutoff=500|
    LPF.ar(in, cutoff);
};
Ndef(\cicloneRubro).set(\wet10, 1);
// Ndef(\cicloneRubro).set(\wet10, 0); // Rollback: disable this effect

// 2. ADD_INSTRUMENT: Return of the high-register crackle/micro-click "piolhos" texture
Ndef(\piolhos, { |amp=0.25, freq=4500, rq=0.03, rel=0.03, pan=0, t_trig=0|
    var env, click, res, sig;
    env = EnvGen.ar(Env.perc(0.0005, rel), K2A.ar(t_trig));
    click = Dust2.ar(120) + Impulse.ar(0);
    res = BPF.ar(click, freq.clip(1000, 14000), rq) * 14.0;
    sig = (res * 2.5).fold2(0.9);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\piolhosSeq,
    \dur, Pseq([0.125, 0.0625, 0.0625, 0.25, 0.125, 0.0625], inf),
    \freq, Pexprand(2800, 9500, inf),
    \rq, Pwhite(0.015, 0.06, inf),
    \rel, Pwhite(0.01, 0.04, inf),
    \amp, Pwhite(0.2, 0.4, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \t_trig, 1
);

Ndef(\piolhos)[1] = \set -> Pbindef(\piolhosSeq);
// Pbindef(\piolhosSeq).stop; Ndef(\piolhos).fadeTime = 2; Ndef(\piolhos).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 9]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Flashback (c): Reintroduce the harmonica texture with an agile, rapid melody
// KEYWORDS: add_instrument, agile, append, bpf, flashback, gaita, gaitaSeq, harmonica, leakdc, melody, pulse, rapid, reintroduce, saw, sinosc, texture, the
(
// Flashback (c): Reintroduce the harmonica texture with an agile, rapid melody
Ndef(\gaita, { |freq=440, amp=0.22, t_trig=0, pan=0, atk=0.015, rel=0.18, brightness=2.8, vibRate=6.0, vibDepth=0.012|
	var env = EnvGen.ar(Env.perc(atk, rel, 1, -4), t_trig);
	var vib = SinOsc.kr(vibRate).bipolar(vibDepth * freq);
	var f = (freq + vib).max(40);
	var osc1 = Pulse.ar(f * [0.998, 1.002], 0.42);
	var osc2 = Saw.ar(f * [1.001, 0.999]) * 0.35;
	var osc3 = Pulse.ar(f * 2, 0.25) * 0.25;
	var sig = osc1 + osc2 + osc3;
	var form1 = BPF.ar(sig, (f * brightness).clip(120, 8000), 0.35) * 2.2;
	var form2 = BPF.ar(sig, (f * 1.5).clip(180, 6000), 0.4) * 1.5;
	var shaped = LeakDC.ar(((sig * 0.35 + form1 + form2) * 1.5).tanh);
	var out = Balance2.ar(shaped[0], shaped[1], pan, env * amp);
	out;
}).play;

Pbindef(\gaitaSeq,
	\dur, Pseq([0.125, 0.125, 0.125, 0.125, 0.25, 0.125, 0.125], inf),
	\scale, Scale.minor,
	\root, 2,
	\octave, 5,
	\degree, Pseq([
		0, 2, 3, 4, 3, 2, 0,
		7, 5, 4, 3, 2, 0, -1,
		0, 3, 5, 7, 8, 7, 5,
		4, 3, 2, 0, 2, 4, 2
	], inf),
	\amp, Pexprand(0.18, 0.26, inf),
	\t_trig, 1,
	\rel, Pseq([0.12, 0.12, 0.14, 0.12, 0.26, 0.12, 0.16], inf),
	\brightness, Pwhite(2.2, 3.4, inf),
	\pan, Pwhite(-0.4, 0.4, inf)
);

Ndef(\gaita)[1] = \set -> Pbindef(\gaitaSeq);

// Pbindef(\gaitaSeq).stop; Ndef(\gaita).fadeTime = 2; Ndef(\gaita).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 10]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Resolution (a) & Settling (c)
// KEYWORDS: add_instrument, append, arAzul, arAzulSeq, archetype, cicloneRubro, cicloneSeq, formal, gaita, gaitaSeq, piolhos, piolhosSeq, resolution, settling, wet10
(
// Formal archetype: Resolution (a) & Settling (c)
// Final gesture: Submerge harmonic spectrum into sub-bass, expand reverb to total wash, then dissolve all layers in staggered progression into silence.

// 1. Gesture: Dynamic spectral and spatial shift towards final dissolution
Ndef(\cicloneRubro).xset(\cutoff, 60); // Deep low-pass drop to anchor the fundamental
// Ndef(\cicloneRubro).xset(\cutoff, 1800); // Revert tweak
Ndef(\arAzul).xset(\wet10, 1.0); // Full wet spatialization into diffuse reverb tail
// Ndef(\arAzul).xset(\wet10, 0.4); // Revert tweak

// 2. Stop all active sequencing streams
Pbindef(\piolhosSeq).stop;
Pbindef(\gaitaSeq).stop;
Pbindef(\cicloneSeq).stop;
Pbindef(\arAzulSeq).stop;

// 3. Staggered fade-outs: granular/percussive textures cut first,
// melodic voice dissolves, sub drone recedes, and the reverberant cloud dissipates into total silence.
Ndef(\piolhos).fadeTime = 2;
Ndef(\piolhos).clear(2);

Ndef(\wet10).fadeTime = 2;
Ndef(\wet10).clear(2);

Ndef(\gaita).fadeTime = 5;
Ndef(\gaita).clear(5);

Ndef(\cicloneRubro).fadeTime = 8;
Ndef(\cicloneRubro).clear(8);

Ndef(\arAzul).fadeTime = 12;
Ndef(\arAzul).clear(12);
)

// Source: append-cilios.scd [Block 11]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Intrinsic Limit (b) - initiating the session with high-velocity, driven wavefolded bass pulse and snappy syncopation
// KEYWORDS: add_instrument, append, archetype, bass, driven, fold, formal, high, initiating, intrinsic, leakdc, limit, moogff, motor, motorSeq, pulse, saw, session, sinosc, snappy, syncopation, the, velocity, wavefolded
(
// --- ADD_INSTRUMENT: Motor ---
// Formal archetype: Intrinsic Limit (b) - initiating the session with high-velocity, driven wavefolded bass pulse and snappy syncopation
Ndef(\motor, { |freq=55, amp=0.32, pan=0, t_trig=0, fold=1.5, cutoff=1200, res=2.4, decay=0.25|
	var trig, env, sub, core, folded, filtered, sig;

	trig = K2A.ar(t_trig);
	env = EnvGen.ar(Env.perc(0.003, decay, 1, -4), trig);

	// Sub-bass fundamental reinforcement to guarantee physical translation
	sub = SinOsc.ar(freq * 0.5) * env * 0.8;

	// Core twin detuned oscillators fed into nonlinear Buchla-style wavefolding
	core = Pulse.ar(freq * [0.996, 1.004], 0.38) + Saw.ar(freq * 1.001);
	folded = Fold.ar(core * (fold + (env * 2.8)), -0.8, 0.8);

	// Moog filter sweep driven hard with makeup saturation
	filtered = (MoogFF.ar(folded, (cutoff * (1 + (env * 3.6))).clip(50, 15000), res) * 2.4).tanh;

	sig = LeakDC.ar(filtered + sub);
	Balance2.ar(sig[0], sig[1], pan, amp * (0.35 + (env * 0.65)));
}).play;

Pbindef(\motorSeq,
	\dur, Pseq([0.25, 0.25, 0.125, 0.125, 0.25, 0.5, 0.25, 0.25], inf),
	\midinote, Pseq([36, 36, 48, 36, 39, 36, 41, 42], inf),
	\t_trig, 1,
	\decay, Pseq([0.18, 0.22, 0.08, 0.12, 0.38, 0.48, 0.15, 0.26], inf),
	\cutoff, Pseq([900, 1600, 3200, 1100, 2200, 800, 4100, 1400], inf),
	\fold, Pwhite(1.4, 3.0, inf),
	\res, Pseq([2.2, 2.5, 3.1, 2.3, 2.8, 2.0, 3.3, 2.6], inf),
	\pan, Pseq([-0.2, 0.2, -0.4, 0.4, 0.0], inf),
	\amp, 0.32
);

Ndef(\motor)[1] = \set -> Pbindef(\motorSeq);

// Pbindef(\motorSeq).stop; Ndef(\motor).fadeTime = 2; Ndef(\motor).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 12]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Settling (c) - an isolated, rhythmic ticking and muffled chamber resonance; the sound of an inaccessible interior
// KEYWORDS: add_instrument, append, archetype, chamber, dynklank, formal, hpf, inaccessible, interior, isolated, leakdc, muffled, resonance, rhythmic, sala5, sala5Seq, settling, sinosc, the, ticking, whitenoise
(
// --- ADD_INSTRUMENT: Sala Fechada (5 Horas) ---
// Formal archetype: Settling (c) - an isolated, rhythmic ticking and muffled chamber resonance; the sound of an inaccessible interior
Ndef(\sala5, { |freq=330, amp=0.25, pan=0.2, t_trig=0, roomCut=650, damping=0.08|
	var trig, env, tick, woodRes, chamber, sig;

	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.002, 0.12);

	// Impulso seco de relógio / batimento na porta fechada
	tick = WhiteNoise.ar * Decay.ar(trig, 0.008);
	tick = HPF.ar(tick, 1200) * 1.8;

	// Ressonância modal de madeira/caixa confinada
	woodRes = DynKlank.ar(
		`[
			freq * [1, 2.14, 3.42, 5.12],
			[0.8, 0.4, 0.25, 0.1],
			[damping, damping * 0.7, damping * 0.5, damping * 0.3]
		],
		tick + (Impulse.ar(0) * env)
	);

	// Espaço abafado: reflexão através de anteparo/parede
	chamber = LPF.ar(woodRes + (SinOsc.ar(freq * 0.5) * env * 0.4), roomCut);
	sig = LeakDC.ar(chamber * 2.0);

	sig = Pan2.ar(sig * amp, pan);
	sig;
}).play;

Pbindef(\sala5Seq,
	// Ciclo de 5 batimentos com compasso assimétrico (o tempo das 5)
	\dur, Pseq([0.25, 0.25, 0.25, 0.25, 0.5], inf),
	\midinote, Pseq([
		69, 57, 57, 57, 60, // A4 com quatro batimentos abafados
		69, 57, 57, 57, 64  // Variação de quinto pulso
	], inf),
	\t_trig, 1,
	\roomCut, Pseq([450, 520, 480, 500, 780], inf),
	\damping, Pseq([0.06, 0.05, 0.05, 0.05, 0.14], inf),
	\amp, Pseq([0.32, 0.18, 0.16, 0.19, 0.28], inf),
	\pan, Pseq([0.35, 0.2, 0.25, 0.15, 0.4], inf)
);

Ndef(\sala5)[1] = \set -> Pbindef(\sala5Seq);

// Pbindef(\sala5Seq).stop; Ndef(\sala5).fadeTime = 2; Ndef(\sala5).clear(2); // Rollback: remove this instrument
)

// Source: append-cilios.scd [Block 13]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Resolution (a) - introducing warm, resonant morning greeting tones over \motor and \sala5
// KEYWORDS: add_instrument, append, archetype, bomDia, bomDiaSeq, bpf, formal, greeting, introducing, leakdc, morning, motor, over, resolution, resonant, sala, sinosc, tones, warm, whitenoise
(
// --- ADD_INSTRUMENT: Bom Dia (Morning Chimes & Syllabic Formants) ---
// Formal archetype: Resolution (a) - introducing warm, resonant morning greeting tones over \motor and \sala5
Ndef(\bomDia, { |freq=440, amp=0.24, pan=0, t_trig=0, vowel=1.0, decayTime=0.8, brightness=2.2|
	var trig, env, osc, f1, f2, f3, formants, sig;

	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.008, decayTime.clip(0.1, 3.5));

	// Dual FM carrier with gentle feedback warmth
	osc = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.005) * 0.35);
	osc = osc + (SinOscFB.ar(freq * 0.5, 0.25) * 0.25);

	// Vowel-like acoustic formant peaks mimicking the spoken inflection of "Bom dia"
	f1 = (freq * vowel.clip(0.8, 3.2)).clip(220, 2800);
	f2 = (f1 * 1.85 * brightness.clip(0.5, 3.5)).clip(450, 6000);
	f3 = (f1 * 2.8).clip(900, 9500);

	formants = BPF.ar(osc, f1, 0.18) * 4.2;
	formants = formants + (BPF.ar(osc, f2, 0.22) * 3.0);
	formants = formants + (BPF.ar(WhiteNoise.ar * env, f3, 0.1) * 1.4);

	sig = LeakDC.ar((osc * 0.2) + formants).tanh;
	sig = Pan2.ar(sig * env * amp, pan);
	sig;
}).play;

Pbindef(\bomDiaSeq,
	\dur, Pseq([0.35, 0.65, 0.35, 1.15], inf), // Rhythmic cadence: "Bom - di - a... Bom - di - a..."
	\scale, Scale.major,
	\root, 2, // D major
	\octave, 5,
	\degree, Pseq([
		0, 4, 0, 7,
		2, 5, 2, 9,
		4, 7, 4, 11,
		0, 4, 2, 7
	], inf),
	\vowel, Pseq([0.9, 2.2, 0.9, 2.5], inf), // Alternates round nasal 'Bom' with bright open 'Dia'
	\decayTime, Pseq([0.45, 0.85, 0.45, 1.2], inf),
	\brightness, Pwhite(1.8, 2.6, inf),
	\amp, Pexprand(0.2, 0.27, inf),
	\pan, Pseq([-0.35, 0.35, -0.2, 0.2], inf),
	\t_trig, 1
);

Ndef(\bomDia)[1] = \set -> Pbindef(\bomDiaSeq);

// Pbindef(\bomDiaSeq).stop; Ndef(\bomDia).fadeTime = 2; Ndef(\bomDia).clear(2); // Rollback: remove this instrument
)

// Source: append-elephant.scd [Block 1]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Removed the 'gate' argument.
// KEYWORDS: add_effects, append, argument, elephantRumble, elephantSeq, gate, hpf, leakdc, moogff, pulse, removed, saw, sinosc, the
(
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
)

// Source: append-elephant.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Define the final resolving instrument (Resolution / Settling)
// KEYWORDS: add_effects, append, define, dynklank, final, instrument, leakdc, pinknoise, resSeq, resolution, resolving, resonance, settling, the
(
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

// Source: append-gallium.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: 1. Define the Wood Surface Ndef using physical modeling (Pluck + Resonators)
// KEYWORDS: add_instrument, append, define, hpf, leakdc, modeling, ndef, physical, pinknoise, pluck, resonators, surface, the, using, wood, woodSeq, woodSurface
(
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

// Source: append-vermelho.scd [Block 1]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Macaw vocalizations ("araras") echoing through the tropical forest canopy
// KEYWORDS: add, add_instrument, append, araras, ararasSeq, bpf, canopy, echoing, forest, instrument, macaw, pulse, saw, sinosc, the, through, tropical, vocalizations
(
// ADD_INSTRUMENT: Macaw vocalizations ("araras") echoing through the tropical forest canopy
Ndef(\araras, { |freq=820, amp=0.25, pan=0, atk=0.018, rel=0.35, bend=1.8, fmAmt=320, f1=1200, f2=2600, rq=0.14, t_trig=0|
	var trig_a = K2A.ar(t_trig);
	var pitchenv = EnvGen.ar(Env([bend, 1, 0.72], [atk * 2, rel], [-2, -4]), trig_a);
	var ampEnv = EnvGen.ar(Env.perc(atk, rel, 1, -3), trig_a);
	var f = (freq * pitchenv).clip(80, 8000);
	var mod = SinOsc.ar(f * 1.5) * fmAmt * EnvGen.ar(Env.perc(atk * 0.5, rel * 0.7), trig_a);
	var osc = Saw.ar(f + mod) + (Pulse.ar(f * 0.5, 0.35) * 0.45);
	var form1 = BPF.ar(osc, f1.clip(200, 8000), rq) * 7;
	var form2 = BPF.ar(osc, f2.clip(400, 12000), rq) * 5;
	var sig = (form1 + form2 + (osc * 0.15)).tanh;
	Balance2.ar(sig, DelayC.ar(sig, 0.02, 0.007), pan, amp * ampEnv);
}).play;

Pbindef(\ararasSeq,
	\dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1.25], inf),
	\freq, Pseq([740, 920, 680, 1080, 810, 590], inf),
	\bend, Pseq([1.9, 1.45, 2.2, 1.6, 2.05, 1.35], inf),
	\f1, Pseq([1150, 1450, 980, 1650, 1280, 920], inf),
	\f2, Pseq([2450, 2950, 2150, 3300, 2650, 1950], inf),
	\atk, Pseq([0.015, 0.02, 0.03, 0.016, 0.025, 0.04], inf),
	\rel, Pseq([0.28, 0.35, 0.2, 0.45, 0.3, 0.55], inf),
	\amp, Pwhite(0.2, 0.3, inf),
	\pan, Pwhite(-0.75, 0.75, inf),
	\t_trig, 1
);

Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 2; Ndef(\araras).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \avesDupla — Dual single-winged birds flying in intertwined pair (Jian / Biyi)
// KEYWORDS: add, add_instrument, append, avesDupla, avesSeq, avesdupla, birds, biyi, dual, flying, instrument, intertwined, jian, pair, pinknoise, ringz, single, sinosc, winged
(
// ADD_INSTRUMENT: \avesDupla — Dual single-winged birds flying in intertwined pair (Jian / Biyi)
Ndef(\avesDupla, { |freq=520, amp=0.25, pan=0, t_trig=0, flutter=7, spread=0.012, ringDec=0.5|
    var trig, env, wingEnv;
    var f1, f2, exciter, res1, res2, sig;

    trig = K2A.ar(t_trig);
    env = Decay2.ar(trig, 0.015, ringDec);
    wingEnv = SinOsc.kr(flutter, [0, pi]).range(0.2, 1.0);

    f1 = freq * (1 - spread);
    f2 = freq * (1 + spread);

    exciter = PinkNoise.ar(0.12) + Dust2.ar(flutter * 6, 0.25);

    res1 = (Ringz.ar(exciter * wingEnv[0], f1, ringDec) * 0.6) + (Ringz.ar(exciter * wingEnv[0], f1 * 2.02, ringDec * 0.5) * 0.25);
    res2 = (Ringz.ar(exciter * wingEnv[1], f2, ringDec) * 0.6) + (Ringz.ar(exciter * wingEnv[1], f2 * 1.98, ringDec * 0.5) * 0.25);

    sig = Balance2.ar(res1, res2, pan);
    sig * env * amp;
}).play;

Pbindef(\avesSeq,
    \dur, Pseq([0.375, 0.25, 0.375, 0.5, 0.25, 0.75], inf),
    \midinote, Pseq([72, 74, 79, 77, 84, 81, 76, 79], inf),
    \t_trig, 1,
    \amp, Pexprand(0.18, 0.32, inf),
    \flutter, Pwhite(6.0, 12.0, inf),
    \spread, Pwhite(0.008, 0.025, inf),
    \ringDec, Pwhite(0.35, 0.75, inf),
    \pan, Pwhite(-0.4, 0.4, inf)
);

Ndef(\avesDupla)[1] = \set -> Pbindef(\avesSeq);

// Pbindef(\avesSeq).stop; Ndef(\avesDupla).fadeTime = 2; Ndef(\avesDupla).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: "foneTrauma" - Telephonic message artifact with resonant teardrop chirps and traumatic saturation
// KEYWORDS: add, add_instrument, append, artifact, bpf, chirps, foneSeq, foneTrauma, fonetrauma, instrument, leakdc, message, pinknoise, resonant, saturation, sinosc, teardrop, telephonic, traumatic
(
// ADD_INSTRUMENT: "foneTrauma" - Telephonic message artifact with resonant teardrop chirps and traumatic saturation
Ndef(\foneTrauma, { |freq=697, freq2=1209, amp=0.22, pan=0, atk=0.003, rel=0.35, drive=3.5, bpfFreq=1100, rq=0.3, t_trig=0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);
    var tearDropEnv = Decay2.ar(trig, 0.002, 0.08) * 320;
    var dtmf = SinOsc.ar([freq, freq2] + tearDropEnv).sum * 0.5;
    var click = PinkNoise.ar * Decay.ar(trig, 0.008) * 0.4;
    var sig = dtmf + click;
    sig = (sig * drive).tanh;
    sig = BPF.ar(sig, bpfFreq, rq) * 4.0;
    sig = LeakDC.ar(sig);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\foneSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.5, 0.25, 0.75, 0.375], inf),
    \freq, Pseq([697, 770, 852, 941, 770, 697, 852], inf),
    \freq2, Pseq([1209, 1336, 1477, 1209, 1336, 1209, 1477], inf),
    \bpfFreq, Pseq([950, 1200, 1600, 850, 1400, 1100, 1300], inf),
    \rq, Pseq([0.25, 0.2, 0.35, 0.15], inf),
    \rel, Pseq([0.15, 0.22, 0.45, 0.1, 0.6, 0.2, 0.3], inf),
    \pan, Pwhite(-0.75, 0.75, inf),
    \amp, Pexprand(0.18, 0.28, inf),
    \t_trig, 1
);

Ndef(\foneTrauma)[1] = \set -> Pbindef(\foneSeq);

// Pbindef(\foneSeq).stop; Ndef(\foneTrauma).fadeTime = 2; Ndef(\foneTrauma).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 4]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: Settling (c): Reducing amplitude of the bird texture to clear spectral space and recede into background
// KEYWORDS: amplitude, append, avesSeq, background, bird, clear, into, recede, reducing, settling, space, spectral, texture, the, tweak_sequence
(
// Settling (c): Reducing amplitude of the bird texture to clear spectral space and recede into background
Pbindef(\avesSeq, \amp, 0.07);
// Pbindef(\avesSeq, \amp, 0.25); // Revert sequence
)

// Source: append-vermelho.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \ouricoCrepusculo — aquatic inharmonic spines and twilight resonance
// KEYWORDS: add, add_instrument, append, aquatic, dynklank, inharmonic, instrument, leakdc, ouricoCrepusculo, ouricoSeq, ouricocrepusculo, resonance, sinosc, spines, twilight, whitenoise
(
// ADD_INSTRUMENT: \ouricoCrepusculo — aquatic inharmonic spines and twilight resonance
Ndef(\ouricoCrepusculo, { |freq=220, amp=0.25, pan=0, t_trig=0, decayTime=0.8, brightness=1200, spineRes=0.4|
	var trigA, exciter, modalFreqs, modalAmps, modalRings, res, sig;

	trigA = K2A.ar(t_trig);
	exciter = Decay2.ar(trigA, 0.002, 0.04) * WhiteNoise.ar(0.6)
		+ (Decay.ar(trigA, 0.005) * SinOsc.ar(freq * 3.5, 0, 0.4));

	modalFreqs = freq * [1.0, 1.414, 2.73, 4.15, 6.28] * LFNoise1.kr(0.2).range(0.98, 1.02);
	modalAmps = [1.0, 0.7, 0.5, 0.35, 0.2] * spineRes;
	modalRings = [1.0, 0.8, 0.6, 0.4, 0.3] * decayTime;

	res = DynKlank.ar(`[modalFreqs, modalAmps, modalRings], exciter);
	sig = LPF.ar(res, brightness.clip(200, 14000));
	sig = LeakDC.ar(sig * 1.5).tanh;

	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\ouricoSeq,
	\dur, Pseq([0.25, 0.5, 0.25, 0.75, 0.25], inf),
	\midinote, Pseq([43, 46, 50, 53, 57, 58, 62], inf),
	\decayTime, Pwhite(0.4, 1.6, inf),
	\brightness, Pexprand(800, 4500, inf),
	\spineRes, Pwhite(0.3, 0.7, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\amp, Pexprand(0.18, 0.32, inf),
	\t_trig, 1
);

Ndef(\ouricoCrepusculo)[1] = \set -> Pbindef(\ouricoSeq);
// Pbindef(\ouricoSeq).stop; Ndef(\ouricoCrepusculo).fadeTime = 2; Ndef(\ouricoCrepusculo).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_EFFECTS: Low-pass filter at 600 Hz on \ouricoCrepusculo to darken timbre (Settling)
// KEYWORDS: add, add_effects, append, crepPerc, crepPercSeq, darken, effects, filter, hpf, leakdc, low, ouricoCrepusculo, ouricocrepusculo, pass, settling, sinosc, timbre, whitenoise
(
// ADD_EFFECTS: Low-pass filter at 600 Hz on \ouricoCrepusculo to darken timbre (Settling)
Ndef(\ouricoCrepusculo)[10] = \filter -> { |in, cutoff=600|
    LPF.ar(in, cutoff.clip(20, 20000));
};
Ndef(\ouricoCrepusculo).set(\wet10, 1.0);
// Ndef(\ouricoCrepusculo).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Low, tactile percussion layer with pitch-bent body and transient snap
Ndef(\crepPerc, { |freq=55, amp=0.35, pan=0, t_trig=0, tone=140, decay=0.25, click=0.015|
    var tr = K2A.ar(t_trig);
    var pitchEnv = EnvGen.ar(Env.perc(0.001, 0.05), tr) * tone;
    var body = SinOsc.ar(freq + pitchEnv) * EnvGen.ar(Env.perc(0.005, decay), tr);
    var transient = HPF.ar(WhiteNoise.ar, 1200) * EnvGen.ar(Env.perc(0.001, click), tr) * 0.35;
    var sig = LeakDC.ar((body + transient).tanh);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\crepPercSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \t_trig, 1,
    \freq, Pseq([55, 48, 62, 50, 55], inf),
    \tone, Pseq([160, 90, 220, 110, 150], inf),
    \decay, Pseq([0.3, 0.15, 0.12, 0.4, 0.22], inf),
    \amp, Pseq([0.4, 0.25, 0.32, 0.45, 0.28], inf),
    \pan, Pseq([0, -0.2, 0.25, 0, 0.1], inf)
);

Ndef(\crepPerc)[1] = \set -> Pbindef(\crepPercSeq);
// Pbindef(\crepPercSeq).stop; Ndef(\crepPerc).fadeTime = 2; Ndef(\crepPerc).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Settling (c): Apply spatial blurring (reverb) and attenuate all texture layers, leaving percussion upfront
// KEYWORDS: add_effects, all, append, apply, araras, ararasSeq, attenuate, avesDupla, avesSeq, blurring, foneSeq, foneTrauma, freeverb, layers, leaving, ouricoCrepusculo, ouricoSeq, percussion, reverb, settling, spatial, texture, upfront
(
// Settling (c): Apply spatial blurring (reverb) and attenuate all texture layers, leaving percussion upfront

// 1. Texture: \araras
Ndef(\araras)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.82, 0.4) };
Ndef(\araras).xset(\wet11, 0.45);
// Ndef(\araras).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\ararasSeq, \amp, 0.07); // Settling (c): reduce texture amplitude
// Pbindef(\ararasSeq, \amp, 0.2); // Revert sequence

// 2. Texture: \avesDupla
Ndef(\avesDupla)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.85, 0.45) };
Ndef(\avesDupla).xset(\wet11, 0.5);
// Ndef(\avesDupla).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\avesSeq, \amp, 0.06); // Settling (c): reduce texture amplitude
// Pbindef(\avesSeq, \amp, 0.18); // Revert sequence

// 3. Texture: \foneTrauma
Ndef(\foneTrauma)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.8, 0.5) };
Ndef(\foneTrauma).xset(\wet11, 0.4);
// Ndef(\foneTrauma).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\foneSeq, \amp, 0.05); // Settling (c): reduce texture amplitude
// Pbindef(\foneSeq, \amp, 0.15); // Revert sequence

// 4. Texture: \ouricoCrepusculo (retaining existing Slot 10 LPF)
Ndef(\ouricoCrepusculo)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.9, 0.35) };
Ndef(\ouricoCrepusculo).xset(\wet11, 0.55);
// Ndef(\ouricoCrepusculo).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\ouricoSeq, \amp, 0.06); // Settling (c): reduce texture amplitude
// Pbindef(\ouricoSeq, \amp, 0.2); // Revert sequence
)

// Source: append-vermelho.scd [Block 8]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \troncoPinheiro - Deep resonant modal wood synthesis providing harmonic grounding ("apoio no vale")
// KEYWORDS: add, add_effects, apoio, append, deep, dynklank, freeverb, grounding, harmonic, instrument, leakdc, modal, pinheiroSeq, pinknoise, providing, resonant, sinosc, synthesis, troncoPinheiro, troncopinheiro, vale, wood
(
// ADD_INSTRUMENT: \troncoPinheiro - Deep resonant modal wood synthesis providing harmonic grounding ("apoio no vale")
Ndef(\troncoPinheiro, { |freq=55, t_trig=0, amp=0.35, decay=2.5, woodiness=0.6, cutoff=800, pan=0|
    var trig = K2A.ar(t_trig);
    var exc = Decay.ar(trig, 0.003) * PinkNoise.ar(0.8) + (Trig.ar(trig, SampleDur.ir) * 0.5);
    var modes = [1, 2.32, 4.17, 6.8, 9.4] * freq;
    var rings = [1, 0.7, 0.5, 0.3, 0.15] * decay;
    var amps = [1, 0.6, 0.4, 0.25, 0.1];
    var wood = DynKlank.ar(`[modes, amps, rings], exc);
    var sub = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.01, decay * 1.2), trig);
    var sig = (wood * woodiness) + (sub * 0.4);
    sig = LPF.ar(sig, cutoff);
    sig = LeakDC.ar(sig.tanh);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\pinheiroSeq,
    \dur, Pseq([4, 3, 5, 4], inf),
    \freq, Pseq([33, 31, 35, 28], inf).midicps, // Deep rooted fundamentals (A1, G1, B1, E1)
    \decay, Pwhite(2.0, 3.5, inf),
    \woodiness, Pwhite(0.5, 0.8, inf),
    \cutoff, Pwhite(600, 1100, inf),
    \amp, 0.38,
    \t_trig, 1,
    \pan, Pseq([0, -0.15, 0.15], inf)
);

Ndef(\troncoPinheiro)[1] = \set -> Pbindef(\pinheiroSeq);

// ADD_EFFECTS: Deep valley spatialization on slot 11
Ndef(\troncoPinheiro)[11] = \filter -> { |in|
    FreeVerb.ar(in, 1.0, 0.88, 0.3);
};
Ndef(\troncoPinheiro).set(\wet11, 0.35);
// Ndef(\troncoPinheiro).set(\wet11, 0); // Rollback: disable this effect

// Rollback: remove this instrument
// Pbindef(\pinheiroSeq).stop; Ndef(\troncoPinheiro).fadeTime = 2; Ndef(\troncoPinheiro).clear(2);
)

// Source: append-vermelho.scd [Block 9]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Settling (c) - Strip down texture to isolate tronco de pinheiro and percussion
// KEYWORDS: add_instrument, append, araras, ararasSeq, archetype, avesDupla, avesSeq, down, foneSeq, foneTrauma, formal, isolate, ouricoCrepusculo, ouricoSeq, percussion, pinheiro, settling, strip, texture, tronco
(
// Formal archetype: Settling (c) - Strip down texture to isolate tronco de pinheiro and percussion
Pbindef(\ararasSeq).stop;
Ndef(\araras).fadeTime = 3;
Ndef(\araras).clear(3);

Pbindef(\avesSeq).stop;
Ndef(\avesDupla).fadeTime = 3;
Ndef(\avesDupla).clear(3);

Pbindef(\foneSeq).stop;
Ndef(\foneTrauma).fadeTime = 3;
Ndef(\foneTrauma).clear(3);

Pbindef(\ouricoSeq).stop;
Ndef(\ouricoCrepusculo).fadeTime = 3;
Ndef(\ouricoCrepusculo).clear(3);
)

// Source: append-vermelho.scd [Block 10]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \borboleta
// KEYWORDS: add, add_instrument, append, borboleta, borboletaSeq, bpf, instrument, sinosc, whitenoise
(
// ADD_INSTRUMENT: \borboleta
// Introduces a fleeting, delicate high-register timbre to evoke the brief, agile flight of a butterfly across the existing texture.
Ndef(\borboleta, { |freq=1400, amp=0.15, pan=0, atk=0.003, rel=0.12, modRatio=2.76, modIndex=1.8, flutter=22, t_trig=0|
	var env = EnvGen.ar(Env.perc(atk, rel, curve: -6), t_trig);
	var wingFlap = SinOsc.ar(flutter).range(0.25, 1.0);
	var mod = SinOsc.ar(freq * modRatio) * (freq * modIndex * env);
	var car = SinOsc.ar(freq + mod);
	var air = BPF.ar(WhiteNoise.ar, freq * 1.5, 0.2) * 0.4;
	var sig = (car + air) * env * wingFlap * amp;
	Pan2.ar(sig, pan);
}).play;

Pbindef(\borboletaSeq,
	\dur, Pwrand([0.0625, 0.125, 0.1875], [0.45, 0.45, 0.1], inf),
	\midinote, Pseq([79, 83, 86, 88, 91, 95, 93, 86], inf) + Pwhite(-0.15, 0.15, inf),
	\flutter, Pwhite(16.0, 32.0, inf),
	\modIndex, Pwhite(0.8, 2.6, inf),
	\rel, Pwhite(0.05, 0.14, inf),
	\pan, Pwhite(-0.75, 0.75, inf),
	\amp, Pexprand(0.09, 0.18, inf),
	\t_trig, 1
);

Ndef(\borboleta)[1] = \set -> Pbindef(\borboletaSeq);
// Pbindef(\borboletaSeq).stop; Ndef(\borboleta).fadeTime = 2; Ndef(\borboleta).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 11]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Settling / Flashback (c): Remove \troncoPinheiro to declutter texture, recall \araras calls
// KEYWORDS: add_instrument, append, araras, ararasSeq, bpf, calls, declutter, flashback, leakdc, pinheiroSeq, pulse, recall, remove, settling, sinosc, texture, troncoPinheiro, troncopinheiro
(
// Settling / Flashback (c): Remove \troncoPinheiro to declutter texture, recall \araras calls

// 1. Remove \troncoPinheiro
Pbindef(\pinheiroSeq).stop;
Ndef(\troncoPinheiro).fadeTime = 2.5;
Ndef(\troncoPinheiro).clear(2.5);
// Rollback: Re-instantiate pinheiro if needed

// 2. Return of \araras (Bright, chirping FM modal calls)
Ndef(\araras, { |freq=1600, sweep=1.4, fmod=3.2, modDepth=1200, amp=0.2, pan=0, atk=0.01, rel=0.22, rq=0.2, t_trig=0|
	var trig = K2A.ar(t_trig);
	var env = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);
	var pitchEnv = EnvGen.ar(Env([sweep, 1.0, 0.7], [atk * 2, rel], \exp), trig);
	var f = freq * pitchEnv;
	var mod = SinOsc.ar(f * fmod) * modDepth * env;
	var car = SinOsc.ar(f + mod);
	var body = BPF.ar(car + (Pulse.ar(f * 0.5, 0.4) * 0.3), f.clip(100, 18000), rq) * 2.0;
	var sig = LeakDC.ar(body) * env * amp;
	Pan2.ar(sig, pan);
}).play;

Pbindef(\ararasSeq,
	\dur, Pwrand([0.125, 0.25, 0.375, 0.75], [0.4, 0.3, 0.2, 0.1], inf),
	\freq, Pseq([1200, 1500, 1850, 1320, 2200, 1680], inf),
	\sweep, Pwhite(1.2, 1.8, inf),
	\modDepth, Pexprand(600, 2500, inf),
	\fmod, Pseq([2.0, 3.14, 2.5, 4.0], inf),
	\atk, 0.008,
	\rel, Pwhite(0.12, 0.28, inf),
	\amp, Pwhite(0.14, 0.22, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\t_trig, 1
);

Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 2; Ndef(\araras).clear(2); // Rollback: remove this instrument
)

// Source: append-vermelho.scd [Block 12]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Resolution (a) & Extrinsic Limit (d): Concluding cadence resolving to tonic, followed by a staggered fade-out
// KEYWORDS: add_instrument, append, araras, ararasSeq, borboleta, borboletaSeq, cadence, concluding, crepPerc, crepPercSeq, extrinsic, fade, followed, limit, out, resolution, resolving, staggered, tonic, wet10, wet11
(
// Resolution (a) & Extrinsic Limit (d): Concluding cadence resolving to tonic, followed by a staggered fade-out

// 1. Concluding phrase: rhythmic deceleration and harmonic resolution
Pbindef(\ararasSeq, \dur, Pseq([0.5, 0.75, 1.25, 3], 1), \degree, Pseq([4, 2, 1, 0], 1));
Pbindef(\borboletaSeq, \dur, Pseq([0.25, 0.5, 1.25, 3], 1), \degree, Pseq([7, 4, 2, 0], 1));
Pbindef(\crepPercSeq, \dur, Pseq([0.5, 0.75, 1.25, 3], 1), \amp, Pseq([0.25, 0.18, 0.1, 0.04], 1));

// 2. Staggered extinction: percussion cuts first, harmony dissolves into silence
fork {
    4.5.wait; // Allow the final resolution chord to sound

    Pbindef(\crepPercSeq).stop;
    Ndef(\crepPerc).fadeTime = 2;
    Ndef(\crepPerc).clear(2);

    2.wait;
    Pbindef(\borboletaSeq).stop;
    Ndef(\borboleta).fadeTime = 4;
    Ndef(\borboleta).clear(4);

    2.wait;
    Pbindef(\ararasSeq).stop;
    Ndef(\araras).fadeTime = 6;
    Ndef(\araras).clear(6);

    // Clear auxiliary effect proxies
    Ndef(\wet10).fadeTime = 2;
    Ndef(\wet10).clear(2);
    Ndef(\wet11).fadeTime = 2;
    Ndef(\wet11).clear(2);
};
)

// Source: append-vermelho.scd [Block 13]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Concluding gesture: Resonant modal pad resolving to a deep, peaceful tonic (Resolution & Extrinsic Limit)
// KEYWORDS: add_effects, append, coda, codaSeq, concluding, deep, extrinsic, freeverb2, gesture, limit, modal, pad, peaceful, pulse, resolution, resolving, resonant, rlpf, saw, sinosc, tonic
(
// Concluding gesture: Resonant modal pad resolving to a deep, peaceful tonic (Resolution & Extrinsic Limit)
Ndef(\coda, { |freq=220, amp=0.25, pan=0, t_trig=0, rel=3.5, cutoff=1800, rq=0.4|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.03, rel, 1, -4), trig);
    var osc = Saw.ar(freq * [0.997, 1.003]) + Pulse.ar(freq * 0.5, 0.4, 0.35) + SinOsc.ar(freq, 0, 0.2);
    var filt = RLPF.ar(osc, cutoff.clip(60, 18000), rq.clip(0.1, 1.0));
    var sig = filt * env * amp;
    Balance2.ar(sig[0], sig[1], pan);
}).play;

// Settling space: Expansive resonant reverberation
Ndef(\coda)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.45);
};
Ndef(\coda).set(\wet10, 0.55);

// Concluding cadential sequence resolving to fundamental tonic
Pbindef(\codaSeq,
    \dur, Pseq([1.5, 1.5, 2.0, 2.5, 6.0], 1),
    \midinote, Pseq([67, 65, 62, 58, 46], 1), // G4 -> F4 -> D4 -> Bb3 -> Bb2
    \rel, Pseq([2.5, 2.5, 3.5, 4.5, 8.5], 1),
    \cutoff, Pseq([2600, 2200, 1700, 1300, 850], 1),
    \amp, Pseq([0.22, 0.20, 0.18, 0.16, 0.26], 1),
    \pan, Pseq([-0.3, 0.3, -0.2, 0.2, 0.0], 1),
    \t_trig, 1
);

Ndef(\coda)[1] = \set -> Pbindef(\codaSeq);

// Extrinsic Limit: Programmed extinction resolving into silence after final ring-out
fork {
    14.wait;
    Pbindef(\codaSeq).stop;
    Ndef(\coda).fadeTime = 5;
    Ndef(\coda).clear(5);
};
// Pbindef(\codaSeq).stop; Ndef(\coda).fadeTime = 2; Ndef(\coda).clear(2); // Rollback: remove this instrument
)

// Source: auto-append-arppegio.scd [Block 1]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Three sine waves, slightly detuned for a fuller sound
// KEYWORDS: add_instrument, append, detuned, for, fuller, sine, sineArp, sineArpSeq, sinosc, slightly, three, waves
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
)

// Source: auto-append-arppegio.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Introduce a new bass instrument with a triangle wave, filtered for warmth.
// KEYWORDS: add, add_instrument, append, bass, bassLine, filtered, for, instrument, introduce, new, rlpf, triangle, warmth, wave
(
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
)

// Source: auto-append-arppegio.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Arppegio sound structure with \bass
// KEYWORDS: add_instrument, append, arppegio, bass, bassSeq, leakdc, moogff, pulse, saw, structure
(
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

// Source: auto-append-bosque.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Define the physical model plucked string Ndef (monophonic node, re-triggered)
// KEYWORDS: add_effects, append, define, freeverb, hpf, leakdc, legendSeq, legendString, model, monophonic, ndef, node, physical, plucked, string, the, triggered, whitenoise
(
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
)

// Source: auto-append-eclipse.scd [Block 1]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Eclipse: Engulf the existing \mystery body in darkness using a heavy low-pass filter
// KEYWORDS: add_effects, append, body, darkness, eclipse, engulf, existing, filter, heavy, low, luz, luzSeq, mystery, pass, sinosc, the, using
(
// 1. Eclipse: Engulf the existing \mystery body in darkness using a heavy low-pass filter
Ndef(\mystery)[11] = \filter -> { |in, lpCutoff=130|
    LPF.ar(in, lpCutoff.lag(4.0));
};
Ndef(\mystery).xset(\wet11, 0.95);
Ndef(\mystery).xset(\lpCutoff, 120);
// Ndef(\mystery).xset(\wet11, 0); // Revert eclipse filter

// 2. Light Returns: Introduce \luz, a shimmering, high-frequency FM-glass voice
Ndef(\luz, { |freq=880, amp=0.12, pan=0, t_trig=0, feedback=0.4, detune=1.008, decay=1.5|
    var env, mod, car, sig;
    env = EnvGen.ar(Env.perc(0.005, decay, 1, -6), K2A.ar(t_trig));
    mod = SinOscFB.ar(freq * 3.5, feedback) * (freq * 2.2);
    car = SinOsc.ar(freq * [1, detune] + mod);
    sig = car * env * amp;
    Balance2.ar(sig[0], sig[1], pan);
}).play;

// 3. Sequence the light with a delicate, crystalline pattern emerging from the shadow
Pbindef(\luzSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1.0], inf),
    \midinote, Pseq([74, 81, 83, 88, 93, 95], inf),
    \t_trig, 1,
    \decay, Pwhite(0.5, 2.0, inf),
    \feedback, Pwhite(0.1, 0.6, inf),
    \amp, Pwhite(0.05, 0.12, inf),
    \pan, Pseq([-0.75, 0.75, -0.25, 0.25], inf)
);

Ndef(\luz)[1] = \set -> Pbindef(\luzSeq);
)

// Source: auto-append-eclipse.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. ADD_INSTRUMENT: Introduce \deriva, a drift-based, non-metric spectral drone
// KEYWORDS: add, add_effects, append, based, deriva, derivaSeq, drift, drone, freeverb, instrument, introduce, luzSeq, metric, mystery, mysterySeq, non, sinosc, spectral
(
// 1. ADD_INSTRUMENT: Introduce \deriva, a drift-based, non-metric spectral drone
Ndef(\deriva, { |amp=0.12, pan=0, detune=0.015, fb=0.85, cutoff=1400, t_trig=0|
	var freq, mod, oscs, sig;
	freq = \freq.kr(110).lag(3.0);
	mod = SinOsc.kr([0.02, 0.04, 0.07, 0.11]) * 180;
	oscs = Array.fill(4, { |i|
		SinOscFB.ar(
			(freq * (i * 0.5 + 1)) + mod[i] + LFNoise1.kr(0.15).bipolar(detune * freq),
			fb * LFNoise2.kr(0.04).range(0.3, 0.9)
		) * (1 / (i + 1.8));
	});
	sig = Splay.ar(oscs);
	sig = LPF.ar(sig, cutoff.lag(1.5));
	Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

Pbindef(\derivaSeq,
	\dur, Pwhite(5.0, 10.0, inf), // Floating, non-arithmetic rhythm
	\midinote, Pseq([41, 48, 55, 60, 65], inf),
	\cutoff, Pwhite(600, 1600, inf),
	\detune, Pwhite(0.01, 0.03, inf),
	\amp, Pwhite(0.08, 0.15, inf)
);

Ndef(\deriva)[1] = \set -> Pbindef(\derivaSeq);


// 2. TWEAK_SEQUENCE: Dissolve the metrics of active Pbindefs (Settling / Anti-Arithmetic)
Pbindef(\luzSeq, \dur, Pwhite(3.0, 7.0, inf)); // Break the grid into wide, unpredictable durations
// Pbindef(\luzSeq, \dur, 0.25); // Revert sequence

Pbindef(\mysterySeq, \dur, Pwhite(4.5, 9.0, inf)); // Melt the "drums" and metric accents into slow, drifting clouds
// Pbindef(\mysterySeq, \dur, 0.5); // Revert sequence


// 3. ADD_EFFECTS & TWEAK_EFFECTS: Wash away the structural borders of \mystery with diffusion
Ndef(\mystery)[12] = \filter -> { |in|
	FreeVerb.ar(in, mix: 1.0, room: 0.95, damp: 0.1);
};

Ndef(\mystery).xset(\wet12, 0.75);
// Ndef(\mystery).xset(\wet12, 0); // Revert tweak
)

// Source: auto-append-eclipse.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Add new instrument: \contento (The physical/vocal representation of discontent)
// KEYWORDS: add, add_effects, append, bpf, contento, contentoSeq, derivaSeq, discontent, instrument, latch, luzSeq, mystery, new, physical, pinknoise, representation, the, vocal
(
// 1. Add new instrument: \contento (The physical/vocal representation of discontent)
Ndef(\contento, { |freq=110, amp=0.25, pan=0, t_trig=0, decay=0.8, formant=1000, rq=0.15, coef=0.4|
    var env, exciter, pluck, vocal, sig;
    env = EnvGen.ar(Env.perc(0.001, 0.05), K2A.ar(t_trig));
    exciter = PinkNoise.ar(env);
    pluck = Pluck.ar(exciter, K2A.ar(t_trig), 0.1, freq.reciprocal, 3.0, coef);
    vocal = BPF.ar(pluck, formant, rq) * 12.0;
    sig = (pluck * 0.4) + (vocal * 0.6);
    sig = sig.tanh;
    Pan2.ar(sig * amp, pan);
}).play;

// 2. Sequence the new instrument with an irregular driving rhythm (dancing feet, singing tongue)
Pbindef(\contentoSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25], inf),
    \midinote, Pseq([36, 48, 43, 55, 36, 60, 58, 48], inf),
    \t_trig, 1,
    \amp, Pwhite(0.2, 0.35, inf),
    \decay, Pseq([0.2, 0.4, 0.8, 0.3], inf),
    \formant, Pexprand(400, 2200, inf),
    \rq, 0.12,
    \coef, Pwhite(0.1, 0.5, inf),
    \pan, Pseq([-0.5, 0.5], inf)
);

Ndef(\contento)[1] = \set -> Pbindef(\contentoSeq);

// 3. Add lo-fi/discontent effect slot to \contento (Grit / Insatiability)
Ndef(\contento)[10] = \filter -> { |in|
    var sig, rate;
    rate = \sr.kr(6000);
    sig = Latch.ar(in, Impulse.ar(rate));
    sig.round(0.5**(\bits.kr(4)));
};
Ndef(\contento).xset(\wet10, 0.4);
// Ndef(\contento).xset(\wet10, 0); // Revert effect

// 4. Tweaking existing elements to drive them to an Intrinsic Limit (b) due to discontent
Pbindef(\derivaSeq, \dur, 0.125); // Speed up movement
// Pbindef(\derivaSeq, \dur, 0.25); // Revert sequence

Pbindef(\luzSeq, \dur, 0.25); // Increase visual flicker
// Pbindef(\luzSeq, \dur, 0.5); // Revert sequence

Ndef(\mystery).xset(\wet12, 0.95); // Drive the spatial reverb to its absolute limit
// Ndef(\mystery).xset(\wet12, 0.75); // Revert tweak
)

// Source: auto-append-eclipse.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Intrinsic Limit (b): Accelerate all active sequences to their absolute limit, bringing tomorrow's density into the immediate present.
// KEYWORDS: absolute, accelerate, active, add_instrument, all, append, bringing, contento, contentoSeq, density, deriva, derivaSeq, immediate, into, intrinsic, limit, luz, luzSeq, mystery, mysterySeq, present, sequences, the, their, tomorrow
(
// Intrinsic Limit (b): Accelerate all active sequences to their absolute limit, bringing tomorrow's density into the immediate present.
TempoClock.default.tempo = 165 / 60;
// TempoClock.default.tempo = 110 / 60; // Revert tempo

Pbindef(\contentoSeq, \dur, Pseq([0.125, 0.125, 0.125, 0.25], inf));
// Pbindef(\contentoSeq, \dur, Pseq([0.25, 0.25, 0.5], inf)); // Revert sequence

Pbindef(\derivaSeq, \dur, Pseq([0.0625, 0.0625, 0.125], inf));
// Pbindef(\derivaSeq, \dur, Pseq([0.5, 0.25, 0.25], inf)); // Revert sequence

Pbindef(\luzSeq, \dur, Pseq([0.125, 0.125, 0.25], inf));
// Pbindef(\luzSeq, \dur, Pseq([1.0, 0.5], inf)); // Revert sequence

Pbindef(\mysterySeq, \dur, Pseq([0.25, 0.25, 0.5], inf));
// Pbindef(\mysterySeq, \dur, Pseq([2.0, 1.0], inf)); // Revert sequence

// Tweak instrument parameters to match this sudden shift to the immediate now
Ndef(\contento).xset(\rate, 48);
// Ndef(\contento).xset(\rate, 12); // Revert tweak

Ndef(\mystery).xset(\lpCutoff, 14000);
// Ndef(\mystery).xset(\lpCutoff, 3000); // Revert tweak

Ndef(\luz).xset(\atk, 0.001, \rel, 0.12);
// Ndef(\luz).xset(\atk, 0.08, \rel, 1.8); // Revert tweak

Ndef(\deriva).xset(\freqMult, 2.0);
// Ndef(\deriva).xset(\freqMult, 1.0); // Revert tweak
)

// Source: auto-append-eclipse.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Finalizing the piece: Staggered fade-out (Archetype c & d)
// KEYWORDS: add_instrument, append, archetype, contento, contentoSeq, deriva, derivaSeq, fade, finalizing, freeverb, luz, luzSeq, mystery, mysterySeq, out, piece, staggered, the
(
// Finalizing the piece: Staggered fade-out (Archetype c & d)
// First, halt all active pattern sequencers to stop generating new events
Pbindef(\contentoSeq).stop;
Pbindef(\derivaSeq).stop;
Pbindef(\luzSeq).stop;
Pbindef(\mysterySeq).stop;

// Stagger the fade-outs of the sound sources to create a clean, composed exit.
// 1. Quick fade for the rhythmic, bitcrushed 'contento' layer
Ndef(\contento).fadeTime = 4.0;
Ndef(\contento).clear(4.0);

// 2. Smooth fade for the 'deriva' layer
Ndef(\deriva).fadeTime = 6.0;
Ndef(\deriva).clear(6.0);

// 3. Long, dissolving fade for the 'luz' texture
Ndef(\luz).fadeTime = 12.0;
Ndef(\luz).clear(12.0);

// 4. Ultra-long fade for 'mystery' to let its rich comb delay (slot 10)
// and deep FreeVerb (slot 12) tails evaporate into silence over 20 seconds.
Ndef(\mystery).fadeTime = 20.0;
Ndef(\mystery).clear(20.0);
)

// Source: auto-append-rimbaud.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: 1. Define the skeletal, tranquil lead synth (tranquilamente um osso)
// KEYWORDS: add_effects, append, canoeLead, canoeSeq, define, lead, osso, sinosc, skeletal, synth, the, tranquil, tranquilamente
(
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
)

// Source: auto-append-rimbaud.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: "White swarms" - High-passed, band-passed noise with makeup gain
// KEYWORDS: add_effects, append, band, bpf, enxame, gain, high, leakdc, makeup, noise, passed, ringz, seqEnxame, swarms, white, whitenoise
(
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
)

// Source: auto-append-rimbaud.scd [Block 8]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: 1. Stop all active sequencing streams immediately to halt rhythmic movement
// KEYWORDS: active, add_instrument, all, append, bass, bassSeq, glitch, glitchSeq, halt, immediately, lead, leadSeq, movement, pad, padSeq, rhythmic, sequencing, stop, streams
(
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

// Source: chimichango-carcara-synth.scd [Block 5]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: Algorithmic sequencer driving an external pad/noise synth
// KEYWORDS: algorithmic, append, chimangoSeq, driving, external, noise, pad, sequencer, synth, tweak_sequence
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

// Source: compose-day-in-two-minutes.scd [Block 2]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: Fix: Use Pexprand instead of non-existent Pexprange
// KEYWORDS: append, existent, fix, instead, non, pexprand, pexprange, tweak_sequence, ufoSeq, use
(
// Fix: Use Pexprand instead of non-existent Pexprange
Pbindef(\ufoSeq, \dur, Pwhite(0.05, 0.15), \freq, Pexprand(800, 3000), \modFreq, Pexprand(100, 800), \t_trig, 1);
)

// Source: composition-constantinople.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Void: Slow, wide pitch movements
// KEYWORDS: add_instrument, append, celestialVoid, chimeSeq, crumbleSeq, crumbleTexture, movements, omenChime, pitch, slow, void, voidSeq, wide
(
// Void: Slow, wide pitch movements
Pbindef(\voidSeq, \dur, 8, \freq, Pn(Pseq([60, 65, 58, 67], 1), inf), \t_trig, 1);

// Chimes: Sparse, low-frequency, single hits
Pbindef(\chimeSeq, \dur, Pwrand([4, 6, 8], [0.5, 0.3, 0.2], inf), \freq, 100, \rel, 4, \t_trig, 1);

// Crumble: Short, dense bursts
Pbindef(\crumbleSeq, \dur, Pwrand([0.1, 0.15, 0.2], [0.5, 0.3, 0.2], inf), \dens, Pwhite(20, 50), \t_trig, 1);

[Ndef(\celestialVoid), Ndef(\omenChime), Ndef(\crumbleTexture)].do(_.quant_(1));
)

// Source: composition-day-in-three-minutes.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Slot 10: Global Space (GVerb)
// KEYWORDS: add_effects, append, brassSaw, choirFM, combl, fireNoise, global, gverb, rlpf, skyAnomaly, slot, space, warDrum
(
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
)

// Source: composition-day-in-three-minutes.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: 2. SEQUENCES (Pbindefs)
// KEYWORDS: add_instrument, append, brassSaw, brassSeq, choirFM, choirSeq, drumSeq, fireNoise, fireSeq, pbindefs, sequences, skyAnomaly, skySeq, warDrum
(
Pbindef(\drumSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.6, 0.3, 0.1], inf), \freq, Pwhite(150, 250), \t_trig, 1);
Pbindef(\choirSeq, \dur, 4, \freq, Pseq([220, 261.63, 329.63, 293.66], inf), \t_trig, 1);
Pbindef(\skySeq, \dur, Pwhite(0.05, 0.15), \freq, Pwhite(3000, 6000), \t_trig, 1);
Pbindef(\fireSeq, \dur, Pwhite(0.02, 0.1), \bpfFreq, Pwhite(2000, 6000), \t_trig, 1);
Pbindef(\brassSeq, \dur, 2, \freq, Pseq([110, 146.83, 164.81, 130.81], inf), \t_trig, 1);

[Ndef(\warDrum), Ndef(\choirFM), Ndef(\skyAnomaly), Ndef(\fireNoise), Ndef(\brassSaw)].do(_.quant_(1));
)

// Source: flamenco.scd [Block 1]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Set a base fadeTime for Ndefs for smoother transitions, and initialize globals
// KEYWORDS: append, base, fadetime, for, globals, initialize, live_patch, ndefs, set, smoother, transitions
(
t = TempoClock.default; // Initialize 't' so t.tempo operations work
Pdef.defaultQuant = 1;  // Initialize to prevent nil errors in Pfunc calculations
)

// Source: flamenco.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- I. INTRODUCCIÓN: EL LATIDO EFFECTS ---
// KEYWORDS: add_effects, append, effects, freeverb, golpe, introducci, latido
(
// Ndef(\golpe) reverb
Ndef(\golpe)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.2, 0.2) };
Ndef(\golpe).set(\wet10, 0); // Initialize dry
)

// Source: flamenco.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: --- I. INTRODUCCIÓN: EL LATIDO SEQUENCES ---
// KEYWORDS: add_instrument, append, cajonKick, cajonKickSeq, golpe, golpeSeq, introducci, latido, sequences
(
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
)

// Source: flamenco.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- II. EXPLORACIÓN BINARIA Y TERNARIA EFFECTS ---
// KEYWORDS: add_effects, append, binaria, combl, effects, exploraci, freeverb, palmas, rasgueado, ternaria
(
// Ndef(\palmas) delay
Ndef(\palmas)[11] = \filter -> { |in| CombL.ar(in.sum, 0.2, 0.08, 0.3) }; // Short slapback
Ndef(\palmas).set(\wet11, 0);

// Ndef(\rasgueado) reverb
Ndef(\rasgueado)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.4, 0.3) };
Ndef(\rasgueado).set(\wet10, 0);
)

// Source: flamenco.scd [Block 7]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Binary (4/4) rhythm
// KEYWORDS: add_instrument, append, bass, bassSeq, binary, cajonSnare, cajonSnareSeq, palmas, palmasSeq, rasgueado, rasgueadoSeq, rhythm
(
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
)

// Source: flamenco.scd [Block 8]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Short noise burst for excitation
// KEYWORDS: append, burst, excitation, for, live_patch, melodiaPluck, noise, short, whitenoise
(
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
)

// Source: flamenco.scd [Block 9]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- III. LA RUEDA DE DOCE EFFECTS ---
// KEYWORDS: add_effects, append, combl, doce, effects, freeverb, iii, melodiaPluck, rueda
(
// Ndef(\melodiaPluck) reverb and delay
Ndef(\melodiaPluck)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.4) };
Ndef(\melodiaPluck).set(\wet10, 0);

Ndef(\melodiaPluck)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.25, 1.2) }; // Subtle, longer delay
Ndef(\melodiaPluck).set(\wet11, 0);
)

// Source: flamenco.scd [Block 10]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: 12-beat cycle for Soleá / Peteneras (accents on 12)
// KEYWORDS: accents, append, beat, cajonKickSeqSolea, cajonSnareSeqSolea, cycle, for, golpeSeqSolea, melodiaPluckSeq, palmasSeqSolea, peteneras, rasgueadoSeqSolea, sole, tweak_sequence
(
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
)

// Source: flamenco.scd [Block 11]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: 12-beat Bulerías cycle (accents on 3rd, 6th, 8th, 10th, 12th beats)
// KEYWORDS: accents, append, beat, beats, buler, cajonKickSeqBulerias, cajonSnareSeqBulerias, cycle, golpeSeqBulerias, melodiaPluckSeqBulerias, palmasSeqBulerias, rasgueadoSeqBulerias, tweak_sequence
(
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
)

// Source: flamenco.scd [Block 13]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- V. AIRE LIBRE EFFECTS ---
// KEYWORDS: add_effects, aire, allpassc, append, combl, effects, freeverb, gverb, libre, melodiaFree, pads
(
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
)

// Source: flamenco.scd [Block 14]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: For ambient section, Pbindefs will be triggered manually or with very slow patterns.
// KEYWORDS: ambient, append, for, manually, melodiaFreeSeq, padsSeq, patterns, pbindefs, section, slow, triggered, tweak_sequence, very, will
(
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
)

// Source: flamenco.scd [Block 15]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Define a master Ndef to apply global effects (e.g., low-pass filter).
// KEYWORDS: append, apply, define, effects, filter, global, live_patch, low, master, masterMix, ndef, pass, rlpf
(
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
)

// Source: flamenco.scd [Block 16]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Ensure all Ndefs are initially stopped and dry before setting up the first phase
// KEYWORDS: add_instrument, all, append, are, bass, bassSeq, bassSeqBulerias, bassSeqSolea, before, cajonKick, cajonKickSeq, cajonKickSeqBulerias, cajonKickSeqSolea, cajonSnare, cajonSnareSeq, cajonSnareSeqBulerias, cajonSnareSeqSolea, dry, ensure, first, golpe, golpeOutro, golpeSeq, golpeSeqBulerias, golpeSeqSolea, initially, melodiaFree, melodiaFreeSeq, melodiaPluck, melodiaPluckSeq, melodiaPluckSeqBulerias, ndefs, pads, padsSeq, palmas, palmasSeq, palmasSeqBulerias, palmasSeqSolea, phase, rasgueado, rasgueadoSeq, rasgueadoSeqBulerias, rasgueadoSeqSolea, setting, stopped, the
(
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
)

// Source: flamenco.scd [Block 17]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: --- LIVE CODING TWEAKS (Simulated Performance Progression) ---
// KEYWORDS: add_instrument, append, bass, bassSeq, cajonSnare, cajonSnareSeq, coding, live, palmas, palmasSeq, performance, progression, rasgueado, rasgueadoSeq, simulated, tweaks
(
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
)

// Source: flamenco.scd [Block 18]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Stop current 4/4 patterns and switch to 12-beat soleá cycle patterns
// KEYWORDS: add_instrument, append, bass, bassSeq, bassSeqSolea, beat, cajonKick, cajonKickSeq, cajonKickSeqSolea, cajonSnare, cajonSnareSeq, cajonSnareSeqSolea, current, cycle, golpe, golpeSeq, golpeSeqSolea, melodiaPluck, melodiaPluckSeq, palmas, palmasSeq, palmasSeqSolea, patterns, rasgueado, rasgueadoSeq, rasgueadoSeqSolea, sole, stop, switch
(
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
)

// Source: flamenco.scd [Block 19]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Stop Soleá patterns and switch to Bulerías patterns
// KEYWORDS: add_instrument, append, bass, bassSeqBulerias, bassSeqSolea, buler, cajonKick, cajonKickSeqBulerias, cajonKickSeqSolea, cajonSnare, cajonSnareSeqBulerias, cajonSnareSeqSolea, golpe, golpeSeqBulerias, golpeSeqSolea, melodiaPluck, melodiaPluckSeq, melodiaPluckSeqBulerias, palmas, palmasSeqBulerias, palmasSeqSolea, patterns, rasgueado, rasgueadoSeqBulerias, rasgueadoSeqSolea, sole, stop, switch
(
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
)

// Source: flamenco.scd [Block 20]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Stop all rhythmic Pbindefs and fade out rhythmic Ndefs
// KEYWORDS: add_instrument, all, append, bass, bassSeqBulerias, cajonKick, cajonKickSeqBulerias, cajonSnare, cajonSnareSeqBulerias, fade, golpe, golpeSeqBulerias, melodiaFree, melodiaFreeSeq, melodiaPluck, melodiaPluckSeqBulerias, ndefs, out, pads, padsSeq, palmas, palmasSeqBulerias, pbindefs, rasgueado, rasgueadoSeqBulerias, rhythmic, stop
(
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
)

// Source: flamenco.scd [Block 21]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Fade out ambient elements
// KEYWORDS: add_instrument, ambient, append, bass, bassSeqBulerias, cajonKick, cajonKickSeqBulerias, cajonSnare, cajonSnareSeqBulerias, elements, fade, golpe, golpeSeqBulerias, melodiaFree, melodiaFreeSeq, melodiaPluck, melodiaPluckSeqBulerias, out, pads, padsSeq, palmas, palmasSeqBulerias, rasgueado, rasgueadoSeqBulerias
(
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
)

// Source: flamenco.scd [Block 22]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Decelerate the rhythm
// KEYWORDS: add_effects, append, bass, bassSeqBulerias, cajonKick, cajonKickSeqBulerias, cajonSnare, cajonSnareSeqBulerias, decelerate, freeverb, golpe, golpeOutro, golpeSeqBulerias, masterMix, melodiaPluck, melodiaPluckSeqBulerias, palmas, palmasSeqBulerias, rasgueado, rasgueadoSeqBulerias, rhythm, the
(
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

// Source: gemini-composition-hummingbird.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Using the "Mystic" chord/scale frequencies: C(130.8), F#(185), Bb(233.1), E(329.6), A(440), D(587.3)
// KEYWORDS: add_instrument, append, birdWings, canopyPad, chord, frequencies, mystic, nectarNest, nestSeq, padSeq, scale, serpentThreat, the, threatSeq, using, wingSeq
(
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
)

// Source: generate-craterlake.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: deepBass Effects
// KEYWORDS: add_effects, append, combl, deepBass, deepbass, dynklank, effects, freeverb, gverb, icyShimmer, islandBell, phantomPulse, rlpf, waterPad
(
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
)

// Source: generate-craterlake.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Slow, ancient geological pulses
// KEYWORDS: add_instrument, ancient, append, bassPulse, deepBass, geological, icyShimmer, islandBell, islandStrikes, padFlow, phantomPulse, phantomRhythm, pulses, shimmerGrains, slow, waterPad
(
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

// Source: ndef-pbindef-slots-examples.scd [Block 1]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Let's define a very simple custom synthesizer to use later.
// KEYWORDS: append, custom, define, later, let, live_patch, ping, saw, simple, synthesizer, use, very
(
SynthDef(\ping, { |out=0, freq=440, amp=0.1, pan=0, gate=1, cutoff=2000|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.5), gate, doneAction: 2);
    sig = LPF.ar(Saw.ar(freq), cutoff);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Source: ndef-pbindef-slots-examples.scd [Block 2]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: Pbindef is used for sequencing (Event Patterns).
// KEYWORDS: append, event, for, mySeq, patterns, pbindef, sequencing, tweak_sequence, used
(
Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 2, 4, 5], inf), // Play a simple scale
    \dur, 0.25,                       // 1/4 second per note
    \amp, 0.2
).play;
)

// Source: ndef-pbindef-slots-examples.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: SLOT 0: The Source.
// KEYWORDS: add_instrument, append, mainOut, mySeq, slot, source, the
(
Ndef(\mainOut)[0] = Pbindef(\mySeq,
    \instrument, \ping,
    \degree, Pseq([0, 3, 5, 7, 10, 12], inf),
    \dur, 0.25,
    \cutoff, 1500
);
)

// Source: ndef-pbindef-slots-examples.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Mix the dry signal 'in' with a ping-pong delay
// KEYWORDS: add_effects, append, delay, dry, mainOut, mix, ping, pong, signal, the
(
Ndef(\mainOut)[1] = \filter -> { |in|
    // Mix the dry signal 'in' with a ping-pong delay
    in + CombC.ar(in, 0.5, [0.3, 0.4], 3, 0.5);
};
)

// Source: ndef-pbindef-slots-examples.scd [Block 5]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Add a slow sweeping filter over everything
// KEYWORDS: add, add_effects, append, everything, filter, freeverb2, mainOut, over, rlpf, sinosc, slow, sweeping
(
Ndef(\mainOut)[2] = \filter -> { |in|
    var verb = FreeVerb2.ar(in[0], in[1], mix: 0.4, room: 0.8);
    // Add a slow sweeping filter over everything
    RLPF.ar(verb, SinOsc.kr(0.1).exprange(300, 3000), 0.2);
};
)

// Source: ndef-pbindef-slots-examples.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Put a totally different effect into Slot 1 (e.g., distortion):
// KEYWORDS: add_effects, append, different, distortion, effect, into, mainOut, put, slot, totally
(
Ndef(\mainOut)[1] = \filter -> { |in|
    (in * 5).tanh * 0.2; // Overdrive
};
)

// Source: new-test.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Reverb for Ndef(\osc1) on slot [10]
// KEYWORDS: add_effects, append, for, freeverb, ndef, osc, osc1, reverb, slot
(
// Reverb for Ndef(\osc1) on slot [10]
Ndef(\osc1)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) };
Ndef(\osc1).set(\wet10, 0); // Initialize reverb wetness to 0
)

// Source: new-test.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Sequence for Ndef(\osc1): Simple C major arpeggio
// KEYWORDS: add_instrument, append, arpeggio, for, major, ndef, osc, osc1, osc1Seq, osc2, osc2Seq, sequence, simple
(
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
)

// Source: new-test.scd [Block 4]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: Fade in Ndef(\osc2) amplitude over its fadeTime (2 seconds)
// KEYWORDS: amplitude, append, fade, fadetime, its, ndef, osc, osc1, osc2, over, seconds, tweak_instrument
(
// Fade in Ndef(\osc2) amplitude over its fadeTime (2 seconds)
Ndef(\osc2).xset(\amp, 0.2); // Introduce the contrasting pulse wave
// Ndef(\osc2).xset(\amp, 0.001); // Revert Ndef(\osc2) to initial silent state

// Fade in reverb on Ndef(\osc1) over its fadeTime (2 seconds)
Ndef(\osc1).xset(\wet10, 0.4); // Add subtle depth to the foundational saw wave
// Ndef(\osc1).xset(\wet10, 0); // Revert Ndef(\osc1) reverb mix to 0
)

// Source: new-test.scd [Block 5]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: Set a longer fadeTime for the outro
// KEYWORDS: append, fadetime, for, longer, osc1, osc2, outro, set, the, tweak_instrument
(
// Set a longer fadeTime for the outro
Ndef(\osc1).fadeTime = 10;
Ndef(\osc2).fadeTime = 10;

// Fade out Ndef(\osc1) amplitude and reverb over 10 seconds
Ndef(\osc1).xset(\amp, 0.0, \wet10, 0.0); // Ndef(\osc1) fades out and its reverb disappears
// Ndef(\osc1).xset(\amp, 0.3, \wet10, 0.4); // Revert Ndef(\osc1) to previous state

// Fade out Ndef(\osc2) amplitude over 10 seconds
Ndef(\osc2).xset(\amp, 0.0); // Ndef(\osc2) fades out
// Ndef(\osc2).xset(\amp, 0.2); // Revert Ndef(\osc2) to previous state
)

// Source: new-test.scd [Block 6]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Wait for the fades to complete, then stop patterns and clear Ndefs
// KEYWORDS: add_instrument, append, clear, complete, fades, for, ndefs, osc1, osc1Seq, osc2, osc2Seq, patterns, stop, the, then, wait
(
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

// Source: oscillators.scd [Block 1]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Ensure ProxySpace and Ndef system are initialized
// KEYWORDS: append, are, ensure, initialized, leakdc, limiter, live_patch, master, ndef, proxyspace, system
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
)

// Source: oscillators.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- EFFECTS ---
// KEYWORDS: add_effects, append, combl, effects, fmSynth, freeverb, kick, pulseRhythm, sawLead
(
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
)

// Source: oscillators.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: --- SEQUENCES ---
// KEYWORDS: add_instrument, append, fmSeq, fmSynth, kick, kickSeq, pulseRhythm, pulseSeq, sawLead, sawSeq, sequences
(
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
)

// Source: oscillators.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: fmSynth: low freq, gentle FM, long decay, sparse arpeggio
// KEYWORDS: add_instrument, append, arpeggio, decay, fmSeq, fmSynth, fmsynth, freq, gentle, kick, kickSeq, long, low, sparse
(
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
)

// Source: oscillators.scd [Block 6]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: fmSynth: modIndex increases, brighter timbre
// KEYWORDS: add_instrument, append, brighter, fmSeq, fmSynth, fmsynth, increases, kickSeq, modindex, timbre
(
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
)

// Source: oscillators.scd [Block 7]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: sawLead: introduce, sustained, filtered, low in mix
// KEYWORDS: add_instrument, append, filtered, fmSeq, introduce, kickSeq, low, mix, sawLead, sawSeq, sawlead, sustained
(
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
)

// Source: oscillators.scd [Block 8]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: pulseRhythm: introduce, fast, percussive
// KEYWORDS: add_instrument, append, fast, fmSynth, introduce, kick, percussive, pulseRhythm, pulseSeq, pulserhythm, sawLead
(
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
)

// Source: oscillators.scd [Block 9]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: --- 5. Outro: Dissolution and Fade (Duration: ~60 seconds) ---
// KEYWORDS: add_instrument, append, dissolution, duration, fade, fmSeq, fmSynth, kick, kickSeq, outro, pulseRhythm, pulseSeq, sawLead, sawSeq, seconds
(
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

// Source: palmhouse-synth-v2.scd [Block 4]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: STEP 4: ADVANCED UI (Knobs & Vertical Sliders)
// KEYWORDS: advanced, append, knobs, sliders, step, tweak_instrument, vertical
(
defer {
    if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };

    ~palmWin = Window("Palm House Conservatory Control", Rect(100, 100, 640, 520));
    ~palmWin.view.decorator = FlowLayout(~palmWin.view.bounds, 15@15, 10@15);
    ~palmWin.view.background = Color.fromHexString("#1E2A22");

    // --- VERTICAL MIXER (Left Side) ---
    ~mixerView = CompositeView(~palmWin, 250@300);
    ~mixerView.decorator = FlowLayout(~mixerView.bounds, 5@5, 15@0);

    StaticText(~mixerView, 240@25).string_("ZONE MIXER").stringColor_(Color.cyan).font_(Font("Arial", 14, true)).align_(\center);

    ~slVol1 = EZSlider(~mixerView, 45@250, "Earth", \amp, { |sl| ~buses.vol1.set(sl.value); ~ccVals[\vol1] = sl.value; }, ~ccVals[\vol1], layout: \vert)
        .setColors(stringColor: Color.white);
    ~slVol2 = EZSlider(~mixerView, 45@250, "Iron", \amp, { |sl| ~buses.vol2.set(sl.value); ~ccVals[\vol2] = sl.value; }, ~ccVals[\vol2], layout: \vert)
        .setColors(stringColor: Color.white);
    ~slVol3 = EZSlider(~mixerView, 45@250, "Foliage", \amp, { |sl| ~buses.vol3.set(sl.value); ~ccVals[\vol3] = sl.value; }, ~ccVals[\vol3], layout: \vert)
        .setColors(stringColor: Color.white);
    ~slVol4 = EZSlider(~mixerView, 45@250, "Glass", \amp, { |sl| ~buses.vol4.set(sl.value); ~ccVals[\vol4] = sl.value; }, ~ccVals[\vol4], layout: \vert)
        .setColors(stringColor: Color.white);

    // --- TIMBRE & MOD KNOBS (Right Side) ---
    ~modView = CompositeView(~palmWin, 340@300);
    ~modView.decorator = FlowLayout(~modView.bounds, 10@5, 20@20);

    StaticText(~modView, 320@25).string_("TIMBRE & LFO MODULATION").stringColor_(Color.cyan).font_(Font("Arial", 14, true)).align_(\center);

    ~knBassRes = EZKnob(~modView, 80@100, "Z1 Res", \amp, { |kn| ~buses.bassRes.set(kn.value); ~ccVals[\bassRes] = kn.value; }, ~ccVals[\bassRes])
        .setColors(stringColor: Color.white);
    ~knIronDec = EZKnob(~modView, 80@100, "Z2 Decay", \amp, { |kn| ~buses.ironDecay.set(kn.value); ~ccVals[\ironDecay] = kn.value; }, ~ccVals[\ironDecay])
        .setColors(stringColor: Color.white);
    ~knFolRate = EZKnob(~modView, 80@100, "Z3 LFO Hz", ControlSpec(0.1, 10, \exp), { |kn| ~buses.folLfoRate.set(kn.value); ~ccVals[\folLfoRate] = kn.value; }, ~ccVals[\folLfoRate])
        .setColors(stringColor: Color.yellow);
    ~knFolDep = EZKnob(~modView, 80@100, "Z3 LFO Dep", \amp, { |kn| ~buses.folLfoDepth.set(kn.value); ~ccVals[\folLfoDepth] = kn.value; }, ~ccVals[\folLfoDepth])
        .setColors(stringColor: Color.yellow);

    // --- GLOBAL FX (Bottom) ---
    ~fxView = CompositeView(~palmWin, 610@150);
    ~fxView.decorator = FlowLayout(~fxView.bounds, 5@5, 5@10);

    StaticText(~fxView, 600@25).string_("GLOBAL GROUP EFFECTS").stringColor_(Color.cyan).font_(Font("Arial", 14, true));

    // FIXED: Removed the non-existent 'labelBackground' argument
    ~slTremRate = EZSlider(~fxView, 290@25, "Trem Rate", ControlSpec(0.1, 15.0, \exp), { |sl| ~buses.tremRate.set(sl.value); ~ccVals[\tremRate] = sl.value; }, ~ccVals[\tremRate])
        .setColors(stringColor: Color.white);
    ~slVerbMix = EZSlider(~fxView, 290@25, "Verb Mix", \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix])
        .setColors(stringColor: Color.white);
    ~slTremDepth = EZSlider(~fxView, 290@25, "Trem Depth", \amp, { |sl| ~buses.tremDepth.set(sl.value); ~ccVals[\tremDepth] = sl.value; }, ~ccVals[\tremDepth])
        .setColors(stringColor: Color.white);
    ~slVerbDec = EZSlider(~fxView, 290@25, "Verb Decay", \amp, { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay])
        .setColors(stringColor: Color.white);

    ~palmWin.front;

    // GUI Polling Loop
    ~guiRoutine = Routine({
        loop {
            if(~slVol1.notNil) { ~slVol1.value = ~ccVals[\vol1] };
            if(~slVol2.notNil) { ~slVol2.value = ~ccVals[\vol2] };
            if(~slVol3.notNil) { ~slVol3.value = ~ccVals[\vol3] };
            if(~slVol4.notNil) { ~slVol4.value = ~ccVals[\vol4] };
            if(~knBassRes.notNil) { ~knBassRes.value = ~ccVals[\bassRes] };
            if(~knIronDec.notNil) { ~knIronDec.value = ~ccVals[\ironDecay] };
            if(~knFolRate.notNil) { ~knFolRate.value = ~ccVals[\folLfoRate] };
            if(~knFolDep.notNil) { ~knFolDep.value = ~ccVals[\folLfoDepth] };
            if(~slTremRate.notNil) { ~slTremRate.value = ~ccVals[\tremRate] };
            if(~slTremDepth.notNil) { ~slTremDepth.value = ~ccVals[\tremDepth] };
            if(~slVerbMix.notNil) { ~slVerbMix.value = ~ccVals[\verbMix] };
            if(~slVerbDec.notNil) { ~slVerbDec.value = ~ccVals[\verbDecay] };
            0.05.wait;
        }
    }).play(AppClock);

    ~palmWin.onClose = {
        ~guiRoutine.stop;
        ~palmWin = nil;
        ~slVol1 = nil; ~slVol2 = nil; ~slVol3 = nil; ~slVol4 = nil;
        ~knBassRes = nil; ~knIronDec = nil; ~knFolRate = nil; ~knFolDep = nil;
        ~slTremRate = nil; ~slTremDepth = nil; ~slVerbMix = nil; ~slVerbDec = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: palmhouse-synth-v3-OSC.scd [Block 4]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: STEP 4: ADVANCED UI (New FX & Sized Knobs)
// KEYWORDS: advanced, append, hpf, knobs, new, sized, step, tweak_instrument
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
    ~ui = ();

    ~palmWin = Window("Palm House Conservatory Control V4.4 (OSC)", Rect(100, 100, 460, 800));
    ~palmWin.view.background = Color.fromHexString("#1E2A22");

    ~tabContainer = CompositeView(~palmWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~palmWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~palmWin, Rect(15, 615, 430, 160));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.cyan, Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["EARTH", "IRON", "FOLIAGE", "GLASS"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95; // Sweet spot: slightly smaller to fit third row comfortably

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
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
        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.cyan).font_(Font("Arial", 16, true));
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

        extraKnobs.value(box, kSize);
    };

    // Inject unique UI controls
    makeZone.value("DEEP EARTH", 1, 0, { |box, kSize|
        ~ui[\drive1] = EZKnob(box, kSize, "Drive " ++ ~cc[\drive1], ControlSpec(1.0, 15.0, \exp), { |kn| ~buses.drive1.set(kn.value); ~ccVals[\drive1] = kn.value; }, ~ccVals[\drive1]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("CAST IRON", 2, 1, { |box, kSize|
        ~ui[\ironDecay] = EZKnob(box, kSize, "DecMod " ++ ~cc[\ironDecay], \amp, { |kn| ~buses.ironDecay.set(kn.value); ~ccVals[\ironDecay] = kn.value; }, ~ccVals[\ironDecay]).setColors(stringColor: Color.yellow);
        ~ui[\inharm2] = EZKnob(box, kSize, "Inharm " ++ ~cc[\inharm2], ControlSpec(1.0, 2.0, \lin), { |kn| ~buses.inharm2.set(kn.value); ~ccVals[\inharm2] = kn.value; }, ~ccVals[\inharm2]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("FOLIAGE PAD", 3, 2, { |box, kSize|
        ~ui[\folLfoRate] = EZKnob(box, kSize, "LFOHz " ++ ~cc[\folLfoRate], ControlSpec(0.1, 10, \exp), { |kn| ~buses.folLfoRate.set(kn.value); ~ccVals[\folLfoRate] = kn.value; }, ~ccVals[\folLfoRate]).setColors(stringColor: Color.yellow);
        ~ui[\folLfoDepth] = EZKnob(box, kSize, "LFODep " ++ ~cc[\folLfoDepth], \amp, { |kn| ~buses.folLfoDepth.set(kn.value); ~ccVals[\folLfoDepth] = kn.value; }, ~ccVals[\folLfoDepth]).setColors(stringColor: Color.yellow);
        ~ui[\chorus3] = EZKnob(box, kSize, "Chorus " ++ ~cc[\chorus3], ControlSpec(0.001, 0.05, \exp), { |kn| ~buses.chorus3.set(kn.value); ~ccVals[\chorus3] = kn.value; }, ~ccVals[\chorus3]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("SPARKLING GLASS", 4, 3, { |box, kSize|
        ~ui[\combDec4] = EZKnob(box, kSize, "CmbDec " ++ ~cc[\combDec4], ControlSpec(0.1, 5.0, \exp), { |kn| ~buses.combDec4.set(kn.value); ~ccVals[\combDec4] = kn.value; }, ~ccVals[\combDec4]).setColors(stringColor: Color.cyan);
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 15@15, 10@10));
    StaticText(~fxContainer, 400@20).string_("GLOBAL GROUP EFFECTS").stringColor_(Color.cyan).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\tremRate] = EZSlider(~fxContainer, 190@40, "Trem Hz (CC" ++ ~cc[\tremRate] ++ ")", ControlSpec(0.1, 15.0, \exp), { |sl| ~buses.tremRate.set(sl.value); ~ccVals[\tremRate] = sl.value; }, ~ccVals[\tremRate], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbMix] = EZSlider(~fxContainer, 190@40, "Verb Mix (CC" ++ ~cc[\verbMix] ++ ")", \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\tremDepth] = EZSlider(~fxContainer, 190@40, "Trem Dep (CC" ++ ~cc[\tremDepth] ++ ")", \amp, { |sl| ~buses.tremDepth.set(sl.value); ~ccVals[\tremDepth] = sl.value; }, ~ccVals[\tremDepth], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 190@40, "Verb Dec (CC" ++ ~cc[\verbDecay] ++ ")", \amp, { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 105).setColors(stringColor: Color.white);

    ~palmWin.front;

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

    ~palmWin.onClose = {
        ~guiRoutine.stop; ~palmWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: palmhouse-synth-v3.scd [Block 4]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: STEP 4: ADVANCED UI (New FX & Sized Knobs)
// KEYWORDS: advanced, append, hpf, knobs, new, sized, step, tweak_instrument
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
    ~ui = ();

    ~palmWin = Window("Palm House Conservatory Control V4.4", Rect(100, 100, 460, 800));
    ~palmWin.view.background = Color.fromHexString("#1E2A22");

    ~tabContainer = CompositeView(~palmWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~palmWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~palmWin, Rect(15, 615, 430, 160));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.cyan, Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["EARTH", "IRON", "FOLIAGE", "GLASS"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95; // Sweet spot: slightly smaller to fit third row comfortably

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
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
        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.cyan).font_(Font("Arial", 16, true));
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

        extraKnobs.value(box, kSize);
    };

    // Inject unique UI controls
    makeZone.value("DEEP EARTH", 1, 0, { |box, kSize|
        ~ui[\drive1] = EZKnob(box, kSize, "Drive " ++ ~cc[\drive1], ControlSpec(1.0, 15.0, \exp), { |kn| ~buses.drive1.set(kn.value); ~ccVals[\drive1] = kn.value; }, ~ccVals[\drive1]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("CAST IRON", 2, 1, { |box, kSize|
        ~ui[\ironDecay] = EZKnob(box, kSize, "DecMod " ++ ~cc[\ironDecay], \amp, { |kn| ~buses.ironDecay.set(kn.value); ~ccVals[\ironDecay] = kn.value; }, ~ccVals[\ironDecay]).setColors(stringColor: Color.yellow);
        ~ui[\inharm2] = EZKnob(box, kSize, "Inharm " ++ ~cc[\inharm2], ControlSpec(1.0, 2.0, \lin), { |kn| ~buses.inharm2.set(kn.value); ~ccVals[\inharm2] = kn.value; }, ~ccVals[\inharm2]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("FOLIAGE PAD", 3, 2, { |box, kSize|
        ~ui[\folLfoRate] = EZKnob(box, kSize, "LFOHz " ++ ~cc[\folLfoRate], ControlSpec(0.1, 10, \exp), { |kn| ~buses.folLfoRate.set(kn.value); ~ccVals[\folLfoRate] = kn.value; }, ~ccVals[\folLfoRate]).setColors(stringColor: Color.yellow);
        ~ui[\folLfoDepth] = EZKnob(box, kSize, "LFODep " ++ ~cc[\folLfoDepth], \amp, { |kn| ~buses.folLfoDepth.set(kn.value); ~ccVals[\folLfoDepth] = kn.value; }, ~ccVals[\folLfoDepth]).setColors(stringColor: Color.yellow);
        ~ui[\chorus3] = EZKnob(box, kSize, "Chorus " ++ ~cc[\chorus3], ControlSpec(0.001, 0.05, \exp), { |kn| ~buses.chorus3.set(kn.value); ~ccVals[\chorus3] = kn.value; }, ~ccVals[\chorus3]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("SPARKLING GLASS", 4, 3, { |box, kSize|
        ~ui[\combDec4] = EZKnob(box, kSize, "CmbDec " ++ ~cc[\combDec4], ControlSpec(0.1, 5.0, \exp), { |kn| ~buses.combDec4.set(kn.value); ~ccVals[\combDec4] = kn.value; }, ~ccVals[\combDec4]).setColors(stringColor: Color.cyan);
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 15@15, 10@10));
    StaticText(~fxContainer, 400@20).string_("GLOBAL GROUP EFFECTS").stringColor_(Color.cyan).font_(Font("Arial", 14, true)).align_(\center);

    ~ui[\tremRate] = EZSlider(~fxContainer, 190@40, "Trem Hz (CC" ++ ~cc[\tremRate] ++ ")", ControlSpec(0.1, 15.0, \exp), { |sl| ~buses.tremRate.set(sl.value); ~ccVals[\tremRate] = sl.value; }, ~ccVals[\tremRate], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbMix] = EZSlider(~fxContainer, 190@40, "Verb Mix (CC" ++ ~cc[\verbMix] ++ ")", \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\tremDepth] = EZSlider(~fxContainer, 190@40, "Trem Dep (CC" ++ ~cc[\tremDepth] ++ ")", \amp, { |sl| ~buses.tremDepth.set(sl.value); ~ccVals[\tremDepth] = sl.value; }, ~ccVals[\tremDepth], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 190@40, "Verb Dec (CC" ++ ~cc[\verbDecay] ++ ")", \amp, { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 105).setColors(stringColor: Color.white);

    ~palmWin.front;

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

    ~palmWin.onClose = {
        ~guiRoutine.stop; ~palmWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: palmhouse-synth-v4-OSC.scd [Block 4]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: STEP 4: ADVANCED UI (New FX & Sized Knobs)
// KEYWORDS: advanced, append, hpf, knobs, new, sized, step, tweak_instrument
(
defer {
    var makeZone, switchTab;
    var pages = Array.newClear(4);
    var tabButtons = Array.newClear(4);

    if(~palmWin.notNil and: { ~palmWin.isClosed.not }) { ~palmWin.close };
    ~ui = ();

    ~palmWin = Window("Palm House Conservatory Control V4.4 (OSC)", Rect(100, 100, 460, 800));
    ~palmWin.view.background = Color.fromHexString("#1E2A22");

    ~tabContainer = CompositeView(~palmWin, Rect(15, 15, 430, 40)).decorator_(FlowLayout(Rect(0,0,430,40), 0@0, 10@0));
    ~pagesContainer = CompositeView(~palmWin, Rect(15, 65, 430, 540));
    ~fxContainer = CompositeView(~palmWin, Rect(15, 615, 430, 160));

    // --- 1. TAB CONTROLS ---
    switchTab = { |idx|
        pages.do { |p, i| if(p.notNil) { p.visible = (i == idx) } };
        tabButtons.do { |b, i|
            var textColor = if(i == idx, Color.black, Color.white);
            var bgColor = if(i == idx, Color.cyan, Color.gray(0.3));
            b.states_([[b.states[0][0], textColor, bgColor]]);
        };
    };

    ["EARTH", "IRON", "FOLIAGE", "GLASS"].do { |name, i|
        tabButtons[i] = Button(~tabContainer, 95@35).states_([[name, Color.white, Color.gray(0.3)]]).action_({ switchTab.value(i) });
    };

    // --- 2. PAGINATED ZONE BUILDER ---
    makeZone = { |name, idx, pageIndex, extraKnobs|
        var box, pref, kSize;
        var mKey, minKey, maxKey, vKey, pKey, hKey, lKey, rKey, aKey, dKey, sKey, rlsKey;
        var rLabel, vLabel;

        pref = idx.asString;
        kSize = 80@95; // Sweet spot: slightly smaller to fit third row comfortably

        box = CompositeView(~pagesContainer, ~pagesContainer.bounds.moveTo(0,0));
        box.background_(Color.gray(0.12, 0.8)).decorator_(FlowLayout(box.bounds, 15@15, 12@10)).visible_(false);
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
        StaticText(box, 230@30).string_("ZONE " ++ pref ++ ": " ++ name).stringColor_(Color.cyan).font_(Font("Arial", 16, true));
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

        extraKnobs.value(box, kSize);
    };

    // Inject unique UI controls
    makeZone.value("DEEP EARTH", 1, 0, { |box, kSize|
        ~ui[\drive1] = EZKnob(box, kSize, "Drive " ++ ~cc[\drive1], ControlSpec(1.0, 15.0, \exp), { |kn| ~buses.drive1.set(kn.value); ~ccVals[\drive1] = kn.value; }, ~ccVals[\drive1]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("CAST IRON", 2, 1, { |box, kSize|
        ~ui[\ironDecay] = EZKnob(box, kSize, "DecMod " ++ ~cc[\ironDecay], \amp, { |kn| ~buses.ironDecay.set(kn.value); ~ccVals[\ironDecay] = kn.value; }, ~ccVals[\ironDecay]).setColors(stringColor: Color.yellow);
        ~ui[\inharm2] = EZKnob(box, kSize, "Inharm " ++ ~cc[\inharm2], ControlSpec(1.0, 2.0, \lin), { |kn| ~buses.inharm2.set(kn.value); ~ccVals[\inharm2] = kn.value; }, ~ccVals[\inharm2]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("FOLIAGE PAD", 3, 2, { |box, kSize|
        ~ui[\folLfoRate] = EZKnob(box, kSize, "LFOHz " ++ ~cc[\folLfoRate], ControlSpec(0.1, 10, \exp), { |kn| ~buses.folLfoRate.set(kn.value); ~ccVals[\folLfoRate] = kn.value; }, ~ccVals[\folLfoRate]).setColors(stringColor: Color.yellow);
        ~ui[\folLfoDepth] = EZKnob(box, kSize, "LFODep " ++ ~cc[\folLfoDepth], \amp, { |kn| ~buses.folLfoDepth.set(kn.value); ~ccVals[\folLfoDepth] = kn.value; }, ~ccVals[\folLfoDepth]).setColors(stringColor: Color.yellow);
        ~ui[\chorus3] = EZKnob(box, kSize, "Chorus " ++ ~cc[\chorus3], ControlSpec(0.001, 0.05, \exp), { |kn| ~buses.chorus3.set(kn.value); ~ccVals[\chorus3] = kn.value; }, ~ccVals[\chorus3]).setColors(stringColor: Color.cyan);
    });

    makeZone.value("SPARKLING GLASS", 4, 3, { |box, kSize|
        ~ui[\combDec4] = EZKnob(box, kSize, "CmbDec " ++ ~cc[\combDec4], ControlSpec(0.1, 5.0, \exp), { |kn| ~buses.combDec4.set(kn.value); ~ccVals[\combDec4] = kn.value; }, ~ccVals[\combDec4]).setColors(stringColor: Color.cyan);
    });

    switchTab.value(0);

    // --- 3. BOTTOM: GLOBAL FX ---
    ~fxContainer.background_(Color.gray(0.1, 0.4)).decorator_(FlowLayout(Rect(0,0,430,160), 15@15, 10@10));

    StaticText(~fxContainer, 280@20).string_("GLOBAL GROUP EFFECTS").stringColor_(Color.cyan).font_(Font("Arial", 14, true)).align_(\right);

    // NEW: GUI Master Note Off Button
    Button(~fxContainer, 110@20).states_([
        ["PANIC (ALL OFF)", Color.white, Color.red(0.6)]
    ]).action_({
        if(~notes.notNil) {
            ~notes.do { |arr, i|
                if(arr.notNil) {
                    arr.do(_.set(\gate, 0));
                    ~notes[i] = nil;
                }
            };
            "GUI: Master Note Off triggered.".postln;
        };
    });

    ~ui[\tremRate] = EZSlider(~fxContainer, 190@40, "Trem Hz (CC" ++ ~cc[\tremRate] ++ ")", ControlSpec(0.1, 15.0, \exp), { |sl| ~buses.tremRate.set(sl.value); ~ccVals[\tremRate] = sl.value; }, ~ccVals[\tremRate], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbMix] = EZSlider(~fxContainer, 190@40, "Verb Mix (CC" ++ ~cc[\verbMix] ++ ")", \amp, { |sl| ~buses.verbMix.set(sl.value); ~ccVals[\verbMix] = sl.value; }, ~ccVals[\verbMix], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\tremDepth] = EZSlider(~fxContainer, 190@40, "Trem Dep (CC" ++ ~cc[\tremDepth] ++ ")", \amp, { |sl| ~buses.tremDepth.set(sl.value); ~ccVals[\tremDepth] = sl.value; }, ~ccVals[\tremDepth], labelWidth: 105).setColors(stringColor: Color.white);
    ~ui[\verbDecay] = EZSlider(~fxContainer, 190@40, "Verb Dec (CC" ++ ~cc[\verbDecay] ++ ")", \amp, { |sl| ~buses.verbDecay.set(sl.value); ~ccVals[\verbDecay] = sl.value; }, ~ccVals[\verbDecay], labelWidth: 105).setColors(stringColor: Color.white);

    ~palmWin.front;

    // --- 4. DATA POLLING ---
    ~guiRoutine = Routine({
        loop {
            // Added safety check to prevent KeysValuesDo crash on close
            if(~ui.notNil and: { ~palmWin.isClosed.not }) {
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

    ~palmWin.onClose = {
        ~guiRoutine.stop; ~palmWin = nil; ~ui = nil;
        "GUI Closed.".postln;
    };
};
)

// Source: pulse.scd [Block 1]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Pulse sound structure with \master
// KEYWORDS: append, leakdc, limiter, live_patch, master, pulse, structure
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
)

// Source: pulse.scd [Block 2]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: --- PULSE & SINE WEAVE INSTRUMENTS ---
// KEYWORDS: append, instruments, live_patch, pulse, sine, sinePad, sinosc, weave
(
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
)

// Source: pulse.scd [Block 3]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Ndef(\pulseBase): Low-frequency pulse wave for rhythmic and textural foundation
// KEYWORDS: append, for, foundation, frequency, live_patch, low, ndef, pulse, pulseBase, pulsebase, rhythmic, textural, wave
(
Ndef(\pulseBase).clear;
Ndef(\pulseBase, {
	|freq=60, amp=0.15, t_trig=1, atk=0.5, rel=3, width=0.8, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = Pulse.ar([freq, freq * 1.005], width); // Slightly detuned for richness
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\pulseBase).fadeTime = 2; // Moderate fade time
)

// Source: pulse.scd [Block 4]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Ndef(\sineLead): Percussive or melodic sine waves for lead lines and arpeggios
// KEYWORDS: append, arpeggios, for, lead, lines, live_patch, melodic, ndef, percussive, sine, sineLead, sinelead, sinosc, waves
(
Ndef(\sineLead).clear;
Ndef(\sineLead, {
	|freq=500, amp=0.2, t_trig=1, atk=0.01, rel=0.3, detune=0.003, pan=0|
	var env, sig;
	env = EnvGen.ar(Env.perc(atk, rel), t_trig, doneAction: 0);
	sig = SinOsc.ar(freq) + SinOsc.ar(freq * (1 + detune)); // Detuned for bell-like quality
	Pan2.ar(sig * env * amp, pan);
}).play;
Ndef(\sineLead).fadeTime = 1; // Shorter fade time for percussive element
)

// Source: pulse.scd [Block 5]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: --- PULSE & SINE WEAVE EFFECTS ---
// KEYWORDS: add_effects, append, effects, freeverb, pulse, pulseBase, sine, sineLead, sinePad, weave
(
Ndef(\sinePad)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.8, 0.5) }; // in.sum for mono input
Ndef(\sinePad).set(\wet10, 0);

Ndef(\pulseBase)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.7, 0.3) };
Ndef(\pulseBase).set(\wet10, 0);

Ndef(\sineLead)[10] = \filter -> { |in| FreeVerb.ar(in.sum, 1, 0.6, 0.2) };
Ndef(\sineLead).set(\wet10, 0);
)

// Source: pulse.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Delay (slot 11) - Primarily on \sineLead and \sinePad
// KEYWORDS: add_effects, append, combl, delay, primarily, sineLead, sinePad, sinelead, sinepad, slot
(
Ndef(\sinePad)[11] = \filter -> { |in| CombL.ar(in, 0.4, 0.3, 3) }; // Long evolving delay
Ndef(\sinePad).set(\wet11, 0);

Ndef(\sineLead)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.15, 1.2) }; // Shorter, shimmering delay
Ndef(\sineLead).set(\wet11, 0);
)

// Source: pulse.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Distortion/Saturation (slot 12) - Subtle on \pulseBase
// KEYWORDS: add_effects, append, distortion, pulseBase, pulsebase, saturation, slot, subtle
(
Ndef(\pulseBase)[12] = \filter -> { |in| (in * 2.0).fold2(0.8) }; // Gentle saturation
Ndef(\pulseBase).set(\wet12, 0);
)

// Source: pulse.scd [Block 8]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: --- PULSE & SINE WEAVE SEQUENCES (Will be introduced in stages) ---
// KEYWORDS: append, introduced, pulse, pulseSeq, sequences, sine, sineLeadSeq, sinePadSeq, stages, tweak_sequence, weave, will
(
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
)

// Source: pulse.scd [Block 9]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: --- PULSE & SINE WEAVE LIVE COMPOSITION ---
// KEYWORDS: append, composition, live, pulse, sine, sinePad, tweak_instrument, weave
(
Ndef(\sinePad).set(\amp, 0.001); // Start almost silent for slow fade in
Ndef(\sinePad).xset(\amp, 0.1, \freq, 180, \lfoFreq, 0.1, \lfoDepth, 0.005, \detune, 0.002, \pan, 0); // Ethereal pad
Ndef(\sinePad).xset(\wet10, 0.7); // High reverb for vast soundscape
)

// Source: pulse.scd [Block 10]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: Ndef(\pulseBase) enters after \sinePad has established itself
// KEYWORDS: after, append, enters, established, has, itself, ndef, pulseBase, pulsebase, sinepad, tweak_instrument
(
fork {
	20.wait; // Wait 20 seconds for sinePad to establish
	Ndef(\pulseBase).set(\amp, 0.001); // Start almost silent
	Ndef(\pulseBase).xset(\amp, 0.15, \freq, 60, \width, 0.85, \atk, 0.5, \rel, 3, \pan, 0); // Deep, soft pulse
	Ndef(\pulseBase).xset(\wet10, 0.6); // Moderate reverb for depth
};
)

// Source: pulse.scd [Block 11]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: \pulseBase gets Pbindef
// KEYWORDS: add_instrument, append, gets, pbindef, pulseBase, pulseSeq, pulsebase, sineLead, sineLeadSeq, sinePad
(
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
)

// Source: pulse.scd [Block 12]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: \sineLead becomes faster and richer
// KEYWORDS: add_instrument, append, becomes, faster, pulseBase, pulseSeq, richer, sineLead, sineLeadSeq, sinePad, sinePadSeq, sinelead
(
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
)

// Source: pulse.scd [Block 13]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: \sineLead dissipates
// KEYWORDS: add_instrument, append, dissipates, pulseBase, pulseSeq, sineLead, sineLeadSeq, sinePad, sinePadSeq, sinelead
(
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

// Source: 2026-09-16_15-51-09.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \sinos — Delicate metallic modal bells ("flor de pessegueiro", "sinos longínquos", "gazela arisca")
// KEYWORDS: add, add_effects, append, arisca, bells, delicate, flor, gazela, hpf, instrument, long, metallic, modal, nquos, pessegueiro, pinknoise, ringz, sinos, sinosSeq
(
// ADD_INSTRUMENT: \sinos — Delicate metallic modal bells ("flor de pessegueiro", "sinos longínquos", "gazela arisca")
// Resonant physical model excited by soft impulse strikes with wide stereophonic decay
Ndef(\sinos, { |freq=660, amp=0.18, pan=0, decay=2.8, brightness=1.2, t_trig=0|
    var trig = K2A.ar(t_trig);
    var exciter = Decay2.ar(trig, 0.0008, 0.015) * PinkNoise.ar(0.12);
    var modes = freq * [1.0, 2.003, 3.015, 4.22, 5.43, 6.78];
    var modeAmps = [1.0, 0.65, 0.4, 0.3, 0.18, 0.1] * [1, brightness, brightness * 0.8, brightness * 0.6, brightness * 0.4, brightness * 0.3];
    var modeDecays = decay * [1.0, 0.82, 0.65, 0.45, 0.3, 0.18];
    var sig = Ringz.ar(exciter, modes, modeDecays, modeAmps).sum;
    sig = HPF.ar(sig, 250);
    Pan2.ar(sig * amp, pan);
}).play;

// Distant space & diffusion slot for atmospheric distance
Ndef(\sinos)[10] = \filter -> { |in|
    var delayed = CombC.ar(in, 0.6, [0.37, 0.49], 3.2);
    LPF.ar(delayed, 3200);
};
Ndef(\sinos).xset(\wet10, 0.55);

// Agile, skittish sequence ("gazela arisca") leaping across delicate pentatonic intervals
Pbindef(\sinosSeq,
    \dur, Pwrand([0.25, 0.5, 0.75, 1.25, 2.5], [0.35, 0.3, 0.15, 0.1, 0.1], inf),
    \midinote, Pxrand([69, 72, 74, 76, 79, 81, 84, 86, 91], inf), // A minor / Hirajoshi-leaning pentatonic
    \decay, Pwhite(1.8, 3.8, inf),
    \brightness, Pwhite(0.7, 1.5, inf),
    \amp, Pexprand(0.08, 0.22, inf),
    \pan, Pwhite(-0.75, 0.75, inf),
    \t_trig, 1
);

// Route native pattern stream to proxy control bus
Ndef(\sinos)[1] = \set -> Pbindef(\sinosSeq);
)

// Source: 2026-09-16_15-51-09.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \queda - Cascading water, fizzing foam, and modal resonance suspended on jasper
// KEYWORDS: add, add_effects, append, bpf, brownnoise, cascading, dynklank, fizzing, foam, freeverb2, hpf, instrument, jasper, modal, pinknoise, queda, quedaSeq, resonance, suspended, water
(
// ADD_INSTRUMENT: \queda - Cascading water, fizzing foam, and modal resonance suspended on jasper
Ndef(\queda, { |freq=440, amp=0.28, pan=0, t_trig=0, decay=2.6, bright=4200, foamAmp=0.22|
	var trig, exciter, foam, modes, rings, jasper, sig;

	trig = K2A.ar(t_trig);

	// Aerated turbulence and spray
	foam = HPF.ar(WhiteNoise.ar, bright) * Decay2.ar(trig, 0.01, 0.5) * foamAmp;
	foam = foam + (BPF.ar(PinkNoise.ar, LFNoise1.kr(0.4).exprange(1200, 5200), 0.25) * 0.15);

	// Hydrodynamic surge exciting mineral modes
	exciter = (LPF.ar(BrownNoise.ar, 750) * Decay2.ar(trig, 0.008, 0.2) * 2.2) + (foam * 0.4);

	// Jasper coast inharmonic modal bank
	modes = freq * [1.0, 1.74, 2.58, 3.86, 5.21];
	rings = [1.8, 1.5, 1.1, 0.7, 0.4] * decay;
	jasper = DynKlank.ar(`[modes, [0.35, 0.25, 0.2, 0.12, 0.07], rings], exciter);

	sig = (jasper * 0.65) + Splay.ar(foam * [0.8, 1.2]);
	Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

Pbindef(\quedaSeq,
	\dur, Pseq([0.75, 0.5, 1.0, 0.25, 1.5, 0.5], inf),
	\t_trig, 1,
	\midinote, Pseq([55, 62, 67, 71, 74, 69], inf), // Suspended mineral harmony
	\decay, Pwhite(2.0, 3.5, inf),
	\bright, Pwhite(3200, 7800, inf),
	\foamAmp, Pwhite(0.18, 0.32, inf),
	\pan, Pwhite(-0.6, 0.6, inf),
	\amp, 0.28
);

Ndef(\queda)[1] = \set -> Pbindef(\quedaSeq);

// ADD_EFFECTS: Slot 10 - Expansive suspension mist
Ndef(\queda)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.18)
};
Ndef(\queda).xset(\wet10, 0.42);
// Ndef(\queda).xset(\wet10, 0); // Revert tweak
)

// Source: 2026-09-16_15-51-09.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: "tronco" — low wooden modal resonance providing a solid grounding anchor in the valley
// KEYWORDS: add, add_effects, anchor, append, grounding, instrument, leakdc, low, modal, pinknoise, providing, resonance, ringz, sinosc, solid, the, tronco, troncoSeq, valley, wooden
(
// ADD_INSTRUMENT: "tronco" — low wooden modal resonance providing a solid grounding anchor in the valley
Ndef(\tronco, { |freq=65.4, amp=0.45, pan=0, decayTime=2.2, damp=1400, t_trig=0|
	var trig = K2A.ar(t_trig);
	var exciter = (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015), trig) * 0.8)
		+ (LPF.ar(Impulse.ar(0), 3000) * EnvGen.ar(Env.perc(0.0005, 0.008), trig) * 0.6);
	var modes = [1.0, 1.88, 2.76, 4.15];
	var amps = [1.0, 0.5, 0.3, 0.12];
	var ringTimes = [decayTime, decayTime * 0.65, decayTime * 0.38, decayTime * 0.18];
	var res = modes.collect({ |m, i|
		Ringz.ar(exciter, freq * m, ringTimes[i]) * amps[i]
	}).sum;
	var sub = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.02, decayTime * 0.8), trig) * 0.35;
	var sig = LeakDC.ar(LPF.ar(res + sub, damp).tanh) * amp;
	Pan2.ar(sig, pan);
}).play;

// Sequence for tronco: deliberate, low fundamental cadences anchoring the valley texture (Settling / Resolution archetype)
Pbindef(\troncoSeq,
	\dur, Pseq([4, 3, 5, 4], inf),
	\midinote, Pseq([36, 31, 38, 33], inf), // C2, G1, D2, A1
	\decayTime, Pseq([2.2, 2.8, 1.9, 3.2], inf),
	\damp, Pwhite(1000, 1600, inf),
	\amp, Pseq([0.48, 0.42, 0.52, 0.45], inf),
	\pan, Pseq([0, -0.2, 0.2, 0], inf),
	\t_trig, 1
);

Ndef(\tronco)[1] = \set -> Pbindef(\troncoSeq);

// Slot 10: resonant woody body / valley acoustic reflection
Ndef(\tronco)[10] = \filter -> { |in|
	CombC.ar(LPF.ar(in, 1800), 0.5, [0.18, 0.26], 2.2);
};
Ndef(\tronco).xset(\wet10, 0.28);
// Ndef(\tronco).xset(\wet10, 0); // Revert tweak
)

// Source: 2026-09-16_15-51-09.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Extrinsic Limit (d): Finalize piece — stop all sequencers and dissolve all layers into silence
// KEYWORDS: add_instrument, all, append, arroio, dissolve, extrinsic, finalize, into, latidos, latidosSeq, layers, limit, piece, queda, quedaSeq, rosaPad, rosaSeq, sequencers, silence, sinos, sinosSeq, stop, tronco, troncoSeq
(
// Extrinsic Limit (d): Finalize piece — stop all sequencers and dissolve all layers into silence

// 1. Stop all active Pbindef streams
Pbindef(\latidosSeq).stop;
Pbindef(\troncoSeq).stop;
Pbindef(\sinosSeq).stop;
Pbindef(\quedaSeq).stop;
Pbindef(\rosaSeq).stop;

// 2. Staggered fade and clearance of all active sound generators
Ndef(\latidos).fadeTime = 3;
Ndef(\latidos).clear(3);

Ndef(\tronco).fadeTime = 4;
Ndef(\tronco).clear(4);

Ndef(\sinos).fadeTime = 6;
Ndef(\sinos).clear(6);

Ndef(\queda).fadeTime = 8;
Ndef(\queda).clear(8);

Ndef(\rosaPad).fadeTime = 12;
Ndef(\rosaPad).clear(12);

Ndef(\arroio).fadeTime = 14;
Ndef(\arroio).clear(14);
)

// Source: 2026-09-16_15-51-09.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \pedraBranca — Resonant mineral physical modeling for nocturnal, crystalline contemplation (Settling/Archetype c)
// KEYWORDS: add, add_effects, append, archetype, contemplation, crystalline, for, freeverb2, instrument, leakdc, mineral, modeling, nocturnal, pedraBranca, pedraSeq, pedrabranca, physical, pinknoise, resonant, ringz, settling
(
// ADD_INSTRUMENT: \pedraBranca — Resonant mineral physical modeling for nocturnal, crystalline contemplation (Settling/Archetype c)
Ndef(\pedraBranca, { |freq=440, amp=0.2, decayTime=2.5, pan=0, t_trig=0|
	var trig, exc, modes, modeAmps, modeDecays, sig;
	trig = K2A.ar(t_trig);
	exc = (Decay2.ar(trig, 0.001, 0.02) * PinkNoise.ar(0.6)) + (trig * 0.25);
	modes = [1, 2.756, 5.404, 8.933, 11.21];
	modeAmps = [1, 0.55, 0.35, 0.2, 0.1];
	modeDecays = [decayTime, decayTime * 0.65, decayTime * 0.45, decayTime * 0.3, decayTime * 0.18];
	sig = Mix.fill(modes.size, { |i|
		Ringz.ar(exc, (freq * modes[i]).clip(20, 18000), modeDecays[i], modeAmps[i])
	});
	sig = LeakDC.ar(sig) * 0.22;
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\pedraSeq,
	\dur, Pseq([1.5, 1.0, 0.75, 2.25, 1.25, 0.75, 2.0], inf),
	\midinote, Pseq([60, 67, 71, 74, 69, 72, 79, 76], inf),
	\decayTime, Pwhite(2.0, 3.5, inf),
	\amp, Pwhite(0.2, 0.32, inf),
	\pan, Pwhite(-0.5, 0.5, inf),
	\t_trig, 1
);

Ndef(\pedraBranca)[1] = \set -> Pbindef(\pedraSeq);

// ADD_EFFECTS: Slot [10] creates a pure stone-chamber reverberation space
Ndef(\pedraBranca)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.25);
};
Ndef(\pedraBranca).set(\wet10, 0.38);
// Ndef(\pedraBranca).set(\wet10, 0); // Revert wetness
)

// Source: 2026-09-16_15-51-09.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \rioSena (Formal Archetype: Settling/Flashback (c) — evoking the flowing Seine and nostalgic memories)
// KEYWORDS: add, add_effects, append, archetype, bpf, brownnoise, dynklank, evoking, flashback, flowing, formal, hpf, instrument, memories, nostalgic, pinknoise, rioSena, riosena, seine, senaSeq, settling, sinosc, the
(
// ADD_INSTRUMENT: \rioSena (Formal Archetype: Settling/Flashback (c) — evoking the flowing Seine and nostalgic memories)
Ndef(\rioSena, { |freq=260, amp=0.22, pan=0, t_trig=0, decay=2.2, flow=0.35, cutoff=1800|
	var env, exciter, modes, tones, water, sig;
	env = EnvGen.ar(Env.perc(0.02, decay, 1, -4), t_trig);
	exciter = PinkNoise.ar(0.06) * EnvGen.ar(Env.perc(0.001, 0.035), t_trig);
	exciter = exciter + (SinOsc.ar(freq * 2.5) * EnvGen.ar(Env.perc(0.001, 0.015), t_trig) * 0.12);
	modes = freq * [1, 1.498, 2.01, 2.76, 3.42];
	tones = DynKlank.ar(`[modes, [0.4, 0.25, 0.2, 0.12, 0.08], [decay, decay * 0.85, decay * 0.65, decay * 0.45, decay * 0.3]], exciter);
	water = BPF.ar(BrownNoise.ar, SinOsc.kr(flow * [0.65, 1.15]).range(160, 560), 0.38) * 0.14;
	sig = (tones * env) + water;
	sig = LPF.ar(sig, cutoff);
	Balance2.ar(sig[0], sig[1], pan, amp);
}).play;

// ADD_EFFECTS: Comb reverberation blurring water droplets into long memory reflections
Ndef(\rioSena)[10] = \filter -> { |in|
	var wet;
	wet = CombC.ar(in, 0.6, [0.375, 0.5], 2.8);
	wet = HPF.ar(wet, 120);
	wet;
};
Ndef(\rioSena).xset(\wet10, 0.35);

// Fluid sequence contour reflecting nostalgic sorrow and release
Pbindef(\senaSeq,
	\dur, Pseq([0.75, 0.5, 0.75, 1.0, 0.5, 1.5], inf),
	\midinote, Pseq([57, 60, 64, 65, 62, 59, 60, 67], inf),
	\decay, Pwhite(1.6, 2.6, inf),
	\pan, Pwhite(-0.4, 0.4, inf),
	\amp, Pwhite(0.18, 0.25, inf),
	\cutoff, Pexprand(1400, 3000, inf),
	\t_trig, 1
);

Ndef(\rioSena)[1] = \set -> Pbindef(\senaSeq);
)

// Source: 2026-09-17_14-53-11.scd [Block 1]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Macaw vocalizations ("araras") echoing through the tropical forest canopy
// KEYWORDS: add, add_instrument, append, araras, ararasSeq, bpf, canopy, echoing, forest, instrument, macaw, pulse, saw, sinosc, the, through, tropical, vocalizations
(
// ADD_INSTRUMENT: Macaw vocalizations ("araras") echoing through the tropical forest canopy
Ndef(\araras, { |freq=820, amp=0.25, pan=0, atk=0.018, rel=0.35, bend=1.8, fmAmt=320, f1=1200, f2=2600, rq=0.14, t_trig=0|
	var trig_a = K2A.ar(t_trig);
	var pitchenv = EnvGen.ar(Env([bend, 1, 0.72], [atk * 2, rel], [-2, -4]), trig_a);
	var ampEnv = EnvGen.ar(Env.perc(atk, rel, 1, -3), trig_a);
	var f = (freq * pitchenv).clip(80, 8000);
	var mod = SinOsc.ar(f * 1.5) * fmAmt * EnvGen.ar(Env.perc(atk * 0.5, rel * 0.7), trig_a);
	var osc = Saw.ar(f + mod) + (Pulse.ar(f * 0.5, 0.35) * 0.45);
	var form1 = BPF.ar(osc, f1.clip(200, 8000), rq) * 7;
	var form2 = BPF.ar(osc, f2.clip(400, 12000), rq) * 5;
	var sig = (form1 + form2 + (osc * 0.15)).tanh;
	Balance2.ar(sig, DelayC.ar(sig, 0.02, 0.007), pan, amp * ampEnv);
}).play;

Pbindef(\ararasSeq,
	\dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1.25], inf),
	\freq, Pseq([740, 920, 680, 1080, 810, 590], inf),
	\bend, Pseq([1.9, 1.45, 2.2, 1.6, 2.05, 1.35], inf),
	\f1, Pseq([1150, 1450, 980, 1650, 1280, 920], inf),
	\f2, Pseq([2450, 2950, 2150, 3300, 2650, 1950], inf),
	\atk, Pseq([0.015, 0.02, 0.03, 0.016, 0.025, 0.04], inf),
	\rel, Pseq([0.28, 0.35, 0.2, 0.45, 0.3, 0.55], inf),
	\amp, Pwhite(0.2, 0.3, inf),
	\pan, Pwhite(-0.75, 0.75, inf),
	\t_trig, 1
);

Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 2; Ndef(\araras).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 2]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \avesDupla — Dual single-winged birds flying in intertwined pair (Jian / Biyi)
// KEYWORDS: add, add_instrument, append, avesDupla, avesSeq, avesdupla, birds, biyi, dual, flying, instrument, intertwined, jian, pair, pinknoise, ringz, single, sinosc, winged
(
// ADD_INSTRUMENT: \avesDupla — Dual single-winged birds flying in intertwined pair (Jian / Biyi)
Ndef(\avesDupla, { |freq=520, amp=0.25, pan=0, t_trig=0, flutter=7, spread=0.012, ringDec=0.5|
    var trig, env, wingEnv;
    var f1, f2, exciter, res1, res2, sig;

    trig = K2A.ar(t_trig);
    env = Decay2.ar(trig, 0.015, ringDec);
    wingEnv = SinOsc.kr(flutter, [0, pi]).range(0.2, 1.0);

    f1 = freq * (1 - spread);
    f2 = freq * (1 + spread);

    exciter = PinkNoise.ar(0.12) + Dust2.ar(flutter * 6, 0.25);

    res1 = (Ringz.ar(exciter * wingEnv[0], f1, ringDec) * 0.6) + (Ringz.ar(exciter * wingEnv[0], f1 * 2.02, ringDec * 0.5) * 0.25);
    res2 = (Ringz.ar(exciter * wingEnv[1], f2, ringDec) * 0.6) + (Ringz.ar(exciter * wingEnv[1], f2 * 1.98, ringDec * 0.5) * 0.25);

    sig = Balance2.ar(res1, res2, pan);
    sig * env * amp;
}).play;

Pbindef(\avesSeq,
    \dur, Pseq([0.375, 0.25, 0.375, 0.5, 0.25, 0.75], inf),
    \midinote, Pseq([72, 74, 79, 77, 84, 81, 76, 79], inf),
    \t_trig, 1,
    \amp, Pexprand(0.18, 0.32, inf),
    \flutter, Pwhite(6.0, 12.0, inf),
    \spread, Pwhite(0.008, 0.025, inf),
    \ringDec, Pwhite(0.35, 0.75, inf),
    \pan, Pwhite(-0.4, 0.4, inf)
);

Ndef(\avesDupla)[1] = \set -> Pbindef(\avesSeq);

// Pbindef(\avesSeq).stop; Ndef(\avesDupla).fadeTime = 2; Ndef(\avesDupla).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: "foneTrauma" - Telephonic message artifact with resonant teardrop chirps and traumatic saturation
// KEYWORDS: add, add_instrument, append, artifact, bpf, chirps, foneSeq, foneTrauma, fonetrauma, instrument, leakdc, message, pinknoise, resonant, saturation, sinosc, teardrop, telephonic, traumatic
(
// ADD_INSTRUMENT: "foneTrauma" - Telephonic message artifact with resonant teardrop chirps and traumatic saturation
Ndef(\foneTrauma, { |freq=697, freq2=1209, amp=0.22, pan=0, atk=0.003, rel=0.35, drive=3.5, bpfFreq=1100, rq=0.3, t_trig=0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);
    var tearDropEnv = Decay2.ar(trig, 0.002, 0.08) * 320;
    var dtmf = SinOsc.ar([freq, freq2] + tearDropEnv).sum * 0.5;
    var click = PinkNoise.ar * Decay.ar(trig, 0.008) * 0.4;
    var sig = dtmf + click;
    sig = (sig * drive).tanh;
    sig = BPF.ar(sig, bpfFreq, rq) * 4.0;
    sig = LeakDC.ar(sig);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\foneSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.5, 0.25, 0.75, 0.375], inf),
    \freq, Pseq([697, 770, 852, 941, 770, 697, 852], inf),
    \freq2, Pseq([1209, 1336, 1477, 1209, 1336, 1209, 1477], inf),
    \bpfFreq, Pseq([950, 1200, 1600, 850, 1400, 1100, 1300], inf),
    \rq, Pseq([0.25, 0.2, 0.35, 0.15], inf),
    \rel, Pseq([0.15, 0.22, 0.45, 0.1, 0.6, 0.2, 0.3], inf),
    \pan, Pwhite(-0.75, 0.75, inf),
    \amp, Pexprand(0.18, 0.28, inf),
    \t_trig, 1
);

Ndef(\foneTrauma)[1] = \set -> Pbindef(\foneSeq);

// Pbindef(\foneSeq).stop; Ndef(\foneTrauma).fadeTime = 2; Ndef(\foneTrauma).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 4]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: Settling (c): Reducing amplitude of the bird texture to clear spectral space and recede into background
// KEYWORDS: amplitude, append, avesSeq, background, bird, clear, into, recede, reducing, settling, space, spectral, texture, the, tweak_sequence
(
// Settling (c): Reducing amplitude of the bird texture to clear spectral space and recede into background
Pbindef(\avesSeq, \amp, 0.07);
// Pbindef(\avesSeq, \amp, 0.25); // Revert sequence
)

// Source: 2026-09-17_14-53-11.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \ouricoCrepusculo — aquatic inharmonic spines and twilight resonance
// KEYWORDS: add, add_instrument, append, aquatic, dynklank, inharmonic, instrument, leakdc, ouricoCrepusculo, ouricoSeq, ouricocrepusculo, resonance, sinosc, spines, twilight, whitenoise
(
// ADD_INSTRUMENT: \ouricoCrepusculo — aquatic inharmonic spines and twilight resonance
Ndef(\ouricoCrepusculo, { |freq=220, amp=0.25, pan=0, t_trig=0, decayTime=0.8, brightness=1200, spineRes=0.4|
	var trigA, exciter, modalFreqs, modalAmps, modalRings, res, sig;

	trigA = K2A.ar(t_trig);
	exciter = Decay2.ar(trigA, 0.002, 0.04) * WhiteNoise.ar(0.6)
		+ (Decay.ar(trigA, 0.005) * SinOsc.ar(freq * 3.5, 0, 0.4));

	modalFreqs = freq * [1.0, 1.414, 2.73, 4.15, 6.28] * LFNoise1.kr(0.2).range(0.98, 1.02);
	modalAmps = [1.0, 0.7, 0.5, 0.35, 0.2] * spineRes;
	modalRings = [1.0, 0.8, 0.6, 0.4, 0.3] * decayTime;

	res = DynKlank.ar(`[modalFreqs, modalAmps, modalRings], exciter);
	sig = LPF.ar(res, brightness.clip(200, 14000));
	sig = LeakDC.ar(sig * 1.5).tanh;

	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\ouricoSeq,
	\dur, Pseq([0.25, 0.5, 0.25, 0.75, 0.25], inf),
	\midinote, Pseq([43, 46, 50, 53, 57, 58, 62], inf),
	\decayTime, Pwhite(0.4, 1.6, inf),
	\brightness, Pexprand(800, 4500, inf),
	\spineRes, Pwhite(0.3, 0.7, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\amp, Pexprand(0.18, 0.32, inf),
	\t_trig, 1
);

Ndef(\ouricoCrepusculo)[1] = \set -> Pbindef(\ouricoSeq);
// Pbindef(\ouricoSeq).stop; Ndef(\ouricoCrepusculo).fadeTime = 2; Ndef(\ouricoCrepusculo).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_EFFECTS: Low-pass filter at 600 Hz on \ouricoCrepusculo to darken timbre (Settling)
// KEYWORDS: add, add_effects, append, crepPerc, crepPercSeq, darken, effects, filter, hpf, leakdc, low, ouricoCrepusculo, ouricocrepusculo, pass, settling, sinosc, timbre, whitenoise
(
// ADD_EFFECTS: Low-pass filter at 600 Hz on \ouricoCrepusculo to darken timbre (Settling)
Ndef(\ouricoCrepusculo)[10] = \filter -> { |in, cutoff=600|
    LPF.ar(in, cutoff.clip(20, 20000));
};
Ndef(\ouricoCrepusculo).set(\wet10, 1.0);
// Ndef(\ouricoCrepusculo).set(\wet10, 0); // Rollback: disable this effect

// ADD_INSTRUMENT: Low, tactile percussion layer with pitch-bent body and transient snap
Ndef(\crepPerc, { |freq=55, amp=0.35, pan=0, t_trig=0, tone=140, decay=0.25, click=0.015|
    var tr = K2A.ar(t_trig);
    var pitchEnv = EnvGen.ar(Env.perc(0.001, 0.05), tr) * tone;
    var body = SinOsc.ar(freq + pitchEnv) * EnvGen.ar(Env.perc(0.005, decay), tr);
    var transient = HPF.ar(WhiteNoise.ar, 1200) * EnvGen.ar(Env.perc(0.001, click), tr) * 0.35;
    var sig = LeakDC.ar((body + transient).tanh);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\crepPercSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \t_trig, 1,
    \freq, Pseq([55, 48, 62, 50, 55], inf),
    \tone, Pseq([160, 90, 220, 110, 150], inf),
    \decay, Pseq([0.3, 0.15, 0.12, 0.4, 0.22], inf),
    \amp, Pseq([0.4, 0.25, 0.32, 0.45, 0.28], inf),
    \pan, Pseq([0, -0.2, 0.25, 0, 0.1], inf)
);

Ndef(\crepPerc)[1] = \set -> Pbindef(\crepPercSeq);
// Pbindef(\crepPercSeq).stop; Ndef(\crepPerc).fadeTime = 2; Ndef(\crepPerc).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Settling (c): Apply spatial blurring (reverb) and attenuate all texture layers, leaving percussion upfront
// KEYWORDS: add_effects, all, append, apply, araras, ararasSeq, attenuate, avesDupla, avesSeq, blurring, foneSeq, foneTrauma, freeverb, layers, leaving, ouricoCrepusculo, ouricoSeq, percussion, reverb, settling, spatial, texture, upfront
(
// Settling (c): Apply spatial blurring (reverb) and attenuate all texture layers, leaving percussion upfront

// 1. Texture: \araras
Ndef(\araras)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.82, 0.4) };
Ndef(\araras).xset(\wet11, 0.45);
// Ndef(\araras).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\ararasSeq, \amp, 0.07); // Settling (c): reduce texture amplitude
// Pbindef(\ararasSeq, \amp, 0.2); // Revert sequence

// 2. Texture: \avesDupla
Ndef(\avesDupla)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.85, 0.45) };
Ndef(\avesDupla).xset(\wet11, 0.5);
// Ndef(\avesDupla).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\avesSeq, \amp, 0.06); // Settling (c): reduce texture amplitude
// Pbindef(\avesSeq, \amp, 0.18); // Revert sequence

// 3. Texture: \foneTrauma
Ndef(\foneTrauma)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.8, 0.5) };
Ndef(\foneTrauma).xset(\wet11, 0.4);
// Ndef(\foneTrauma).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\foneSeq, \amp, 0.05); // Settling (c): reduce texture amplitude
// Pbindef(\foneSeq, \amp, 0.15); // Revert sequence

// 4. Texture: \ouricoCrepusculo (retaining existing Slot 10 LPF)
Ndef(\ouricoCrepusculo)[11] = \filter -> { |in| FreeVerb.ar(in, 1.0, 0.9, 0.35) };
Ndef(\ouricoCrepusculo).xset(\wet11, 0.55);
// Ndef(\ouricoCrepusculo).set(\wet11, 0); // Rollback: disable this effect
Pbindef(\ouricoSeq, \amp, 0.06); // Settling (c): reduce texture amplitude
// Pbindef(\ouricoSeq, \amp, 0.2); // Revert sequence
)

// Source: 2026-09-17_14-53-11.scd [Block 8]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \troncoPinheiro - Deep resonant modal wood synthesis providing harmonic grounding ("apoio no vale")
// KEYWORDS: add, add_effects, apoio, append, deep, dynklank, freeverb, grounding, harmonic, instrument, leakdc, modal, pinheiroSeq, pinknoise, providing, resonant, sinosc, synthesis, troncoPinheiro, troncopinheiro, vale, wood
(
// ADD_INSTRUMENT: \troncoPinheiro - Deep resonant modal wood synthesis providing harmonic grounding ("apoio no vale")
Ndef(\troncoPinheiro, { |freq=55, t_trig=0, amp=0.35, decay=2.5, woodiness=0.6, cutoff=800, pan=0|
    var trig = K2A.ar(t_trig);
    var exc = Decay.ar(trig, 0.003) * PinkNoise.ar(0.8) + (Trig.ar(trig, SampleDur.ir) * 0.5);
    var modes = [1, 2.32, 4.17, 6.8, 9.4] * freq;
    var rings = [1, 0.7, 0.5, 0.3, 0.15] * decay;
    var amps = [1, 0.6, 0.4, 0.25, 0.1];
    var wood = DynKlank.ar(`[modes, amps, rings], exc);
    var sub = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.01, decay * 1.2), trig);
    var sig = (wood * woodiness) + (sub * 0.4);
    sig = LPF.ar(sig, cutoff);
    sig = LeakDC.ar(sig.tanh);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\pinheiroSeq,
    \dur, Pseq([4, 3, 5, 4], inf),
    \freq, Pseq([33, 31, 35, 28], inf).midicps, // Deep rooted fundamentals (A1, G1, B1, E1)
    \decay, Pwhite(2.0, 3.5, inf),
    \woodiness, Pwhite(0.5, 0.8, inf),
    \cutoff, Pwhite(600, 1100, inf),
    \amp, 0.38,
    \t_trig, 1,
    \pan, Pseq([0, -0.15, 0.15], inf)
);

Ndef(\troncoPinheiro)[1] = \set -> Pbindef(\pinheiroSeq);

// ADD_EFFECTS: Deep valley spatialization on slot 11
Ndef(\troncoPinheiro)[11] = \filter -> { |in|
    FreeVerb.ar(in, 1.0, 0.88, 0.3);
};
Ndef(\troncoPinheiro).set(\wet11, 0.35);
// Ndef(\troncoPinheiro).set(\wet11, 0); // Rollback: disable this effect

// Rollback: remove this instrument
// Pbindef(\pinheiroSeq).stop; Ndef(\troncoPinheiro).fadeTime = 2; Ndef(\troncoPinheiro).clear(2);
)

// Source: 2026-09-17_14-53-11.scd [Block 9]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Formal archetype: Settling (c) - Strip down texture to isolate tronco de pinheiro and percussion
// KEYWORDS: add_instrument, append, araras, ararasSeq, archetype, avesDupla, avesSeq, down, foneSeq, foneTrauma, formal, isolate, ouricoCrepusculo, ouricoSeq, percussion, pinheiro, settling, strip, texture, tronco
(
// Formal archetype: Settling (c) - Strip down texture to isolate tronco de pinheiro and percussion
Pbindef(\ararasSeq).stop;
Ndef(\araras).fadeTime = 3;
Ndef(\araras).clear(3);

Pbindef(\avesSeq).stop;
Ndef(\avesDupla).fadeTime = 3;
Ndef(\avesDupla).clear(3);

Pbindef(\foneSeq).stop;
Ndef(\foneTrauma).fadeTime = 3;
Ndef(\foneTrauma).clear(3);

Pbindef(\ouricoSeq).stop;
Ndef(\ouricoCrepusculo).fadeTime = 3;
Ndef(\ouricoCrepusculo).clear(3);
)

// Source: 2026-09-17_14-53-11.scd [Block 10]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: \borboleta
// KEYWORDS: add, add_instrument, append, borboleta, borboletaSeq, bpf, instrument, sinosc, whitenoise
(
// ADD_INSTRUMENT: \borboleta
// Introduces a fleeting, delicate high-register timbre to evoke the brief, agile flight of a butterfly across the existing texture.
Ndef(\borboleta, { |freq=1400, amp=0.15, pan=0, atk=0.003, rel=0.12, modRatio=2.76, modIndex=1.8, flutter=22, t_trig=0|
	var env = EnvGen.ar(Env.perc(atk, rel, curve: -6), t_trig);
	var wingFlap = SinOsc.ar(flutter).range(0.25, 1.0);
	var mod = SinOsc.ar(freq * modRatio) * (freq * modIndex * env);
	var car = SinOsc.ar(freq + mod);
	var air = BPF.ar(WhiteNoise.ar, freq * 1.5, 0.2) * 0.4;
	var sig = (car + air) * env * wingFlap * amp;
	Pan2.ar(sig, pan);
}).play;

Pbindef(\borboletaSeq,
	\dur, Pwrand([0.0625, 0.125, 0.1875], [0.45, 0.45, 0.1], inf),
	\midinote, Pseq([79, 83, 86, 88, 91, 95, 93, 86], inf) + Pwhite(-0.15, 0.15, inf),
	\flutter, Pwhite(16.0, 32.0, inf),
	\modIndex, Pwhite(0.8, 2.6, inf),
	\rel, Pwhite(0.05, 0.14, inf),
	\pan, Pwhite(-0.75, 0.75, inf),
	\amp, Pexprand(0.09, 0.18, inf),
	\t_trig, 1
);

Ndef(\borboleta)[1] = \set -> Pbindef(\borboletaSeq);
// Pbindef(\borboletaSeq).stop; Ndef(\borboleta).fadeTime = 2; Ndef(\borboleta).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 11]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Settling / Flashback (c): Remove \troncoPinheiro to declutter texture, recall \araras calls
// KEYWORDS: add_instrument, append, araras, ararasSeq, bpf, calls, declutter, flashback, leakdc, pinheiroSeq, pulse, recall, remove, settling, sinosc, texture, troncoPinheiro, troncopinheiro
(
// Settling / Flashback (c): Remove \troncoPinheiro to declutter texture, recall \araras calls

// 1. Remove \troncoPinheiro
Pbindef(\pinheiroSeq).stop;
Ndef(\troncoPinheiro).fadeTime = 2.5;
Ndef(\troncoPinheiro).clear(2.5);
// Rollback: Re-instantiate pinheiro if needed

// 2. Return of \araras (Bright, chirping FM modal calls)
Ndef(\araras, { |freq=1600, sweep=1.4, fmod=3.2, modDepth=1200, amp=0.2, pan=0, atk=0.01, rel=0.22, rq=0.2, t_trig=0|
	var trig = K2A.ar(t_trig);
	var env = EnvGen.ar(Env.perc(atk, rel, 1, -4), trig);
	var pitchEnv = EnvGen.ar(Env([sweep, 1.0, 0.7], [atk * 2, rel], \exp), trig);
	var f = freq * pitchEnv;
	var mod = SinOsc.ar(f * fmod) * modDepth * env;
	var car = SinOsc.ar(f + mod);
	var body = BPF.ar(car + (Pulse.ar(f * 0.5, 0.4) * 0.3), f.clip(100, 18000), rq) * 2.0;
	var sig = LeakDC.ar(body) * env * amp;
	Pan2.ar(sig, pan);
}).play;

Pbindef(\ararasSeq,
	\dur, Pwrand([0.125, 0.25, 0.375, 0.75], [0.4, 0.3, 0.2, 0.1], inf),
	\freq, Pseq([1200, 1500, 1850, 1320, 2200, 1680], inf),
	\sweep, Pwhite(1.2, 1.8, inf),
	\modDepth, Pexprand(600, 2500, inf),
	\fmod, Pseq([2.0, 3.14, 2.5, 4.0], inf),
	\atk, 0.008,
	\rel, Pwhite(0.12, 0.28, inf),
	\amp, Pwhite(0.14, 0.22, inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\t_trig, 1
);

Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 2; Ndef(\araras).clear(2); // Rollback: remove this instrument
)

// Source: 2026-09-17_14-53-11.scd [Block 12]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Resolution (a) & Extrinsic Limit (d): Concluding cadence resolving to tonic, followed by a staggered fade-out
// KEYWORDS: add_instrument, append, araras, ararasSeq, borboleta, borboletaSeq, cadence, concluding, crepPerc, crepPercSeq, extrinsic, fade, followed, limit, out, resolution, resolving, staggered, tonic, wet10, wet11
(
// Resolution (a) & Extrinsic Limit (d): Concluding cadence resolving to tonic, followed by a staggered fade-out

// 1. Concluding phrase: rhythmic deceleration and harmonic resolution
Pbindef(\ararasSeq, \dur, Pseq([0.5, 0.75, 1.25, 3], 1), \degree, Pseq([4, 2, 1, 0], 1));
Pbindef(\borboletaSeq, \dur, Pseq([0.25, 0.5, 1.25, 3], 1), \degree, Pseq([7, 4, 2, 0], 1));
Pbindef(\crepPercSeq, \dur, Pseq([0.5, 0.75, 1.25, 3], 1), \amp, Pseq([0.25, 0.18, 0.1, 0.04], 1));

// 2. Staggered extinction: percussion cuts first, harmony dissolves into silence
fork {
    4.5.wait; // Allow the final resolution chord to sound

    Pbindef(\crepPercSeq).stop;
    Ndef(\crepPerc).fadeTime = 2;
    Ndef(\crepPerc).clear(2);

    2.wait;
    Pbindef(\borboletaSeq).stop;
    Ndef(\borboleta).fadeTime = 4;
    Ndef(\borboleta).clear(4);

    2.wait;
    Pbindef(\ararasSeq).stop;
    Ndef(\araras).fadeTime = 6;
    Ndef(\araras).clear(6);

    // Clear auxiliary effect proxies
    Ndef(\wet10).fadeTime = 2;
    Ndef(\wet10).clear(2);
    Ndef(\wet11).fadeTime = 2;
    Ndef(\wet11).clear(2);
};
)

// Source: 2026-09-17_14-53-11.scd [Block 13]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Concluding gesture: Resonant modal pad resolving to a deep, peaceful tonic (Resolution & Extrinsic Limit)
// KEYWORDS: add_effects, append, coda, codaSeq, concluding, deep, extrinsic, freeverb2, gesture, limit, modal, pad, peaceful, pulse, resolution, resolving, resonant, rlpf, saw, sinosc, tonic
(
// Concluding gesture: Resonant modal pad resolving to a deep, peaceful tonic (Resolution & Extrinsic Limit)
Ndef(\coda, { |freq=220, amp=0.25, pan=0, t_trig=0, rel=3.5, cutoff=1800, rq=0.4|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.03, rel, 1, -4), trig);
    var osc = Saw.ar(freq * [0.997, 1.003]) + Pulse.ar(freq * 0.5, 0.4, 0.35) + SinOsc.ar(freq, 0, 0.2);
    var filt = RLPF.ar(osc, cutoff.clip(60, 18000), rq.clip(0.1, 1.0));
    var sig = filt * env * amp;
    Balance2.ar(sig[0], sig[1], pan);
}).play;

// Settling space: Expansive resonant reverberation
Ndef(\coda)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.45);
};
Ndef(\coda).set(\wet10, 0.55);

// Concluding cadential sequence resolving to fundamental tonic
Pbindef(\codaSeq,
    \dur, Pseq([1.5, 1.5, 2.0, 2.5, 6.0], 1),
    \midinote, Pseq([67, 65, 62, 58, 46], 1), // G4 -> F4 -> D4 -> Bb3 -> Bb2
    \rel, Pseq([2.5, 2.5, 3.5, 4.5, 8.5], 1),
    \cutoff, Pseq([2600, 2200, 1700, 1300, 850], 1),
    \amp, Pseq([0.22, 0.20, 0.18, 0.16, 0.26], 1),
    \pan, Pseq([-0.3, 0.3, -0.2, 0.2, 0.0], 1),
    \t_trig, 1
);

Ndef(\coda)[1] = \set -> Pbindef(\codaSeq);

// Extrinsic Limit: Programmed extinction resolving into silence after final ring-out
fork {
    14.wait;
    Pbindef(\codaSeq).stop;
    Ndef(\coda).fadeTime = 5;
    Ndef(\coda).clear(5);
};
// Pbindef(\codaSeq).stop; Ndef(\coda).fadeTime = 2; Ndef(\coda).clear(2); // Rollback: remove this instrument
)

// Source: 2026-10-07_11-27-02.scd [Block 1]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Oceanic depth: vast body of water, tidal swells and deep benthic pressure
// KEYWORDS: add_effects, append, benthic, body, brownnoise, deep, depth, freeverb2, hpf, oceanPulses, oceanSwell, oceanic, pinknoise, pressure, rlpf, sinosc, swells, tidal, vast, water
(
// Oceanic depth: vast body of water, tidal swells and deep benthic pressure
Ndef(\oceanSwell, { |amp=0.55, pan=0, t_trig=1, atk=3.5, rel=5.5, cutoff=350, rq=0.45, subFreq=42|
	var trig, env, swell, sub, foam, sigL, sigR;
	trig = K2A.ar(t_trig);
	env = EnvGen.ar(Env.perc(atk, rel, curve: [2, -2]), trig);
	swell = RLPF.ar(BrownNoise.ar(0.85), (cutoff + (env * 600)).clip(40, 4000), rq);
	sub = SinOsc.ar(subFreq) * 0.35 + (SinOsc.ar(subFreq * 2) * 0.15);
	foam = HPF.ar(PinkNoise.ar(0.18) * env.pow(1.5), 1800);
	sigL = swell + sub + foam;
	sigR = swell + (sub * 0.98) + DelayN.ar(foam, 0.04, 0.035);
	sigL = LeakDC.ar(sigL);
	sigR = LeakDC.ar(sigR);
	Balance2.ar(sigL * amp, sigR * amp, pan);
}).play;

Pbindef(\oceanPulses,
	\dur, Pseq([6, 8, 7, 9], inf),
	\t_trig, 1,
	\atk, Pwhite(2.5, 4.5, inf),
	\rel, Pwhite(4.0, 7.0, inf),
	\cutoff, Pexprand(220, 650, inf),
	\subFreq, Prand([38.89, 43.65, 49.0], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\amp, Pwhite(0.45, 0.65, inf)
);

Ndef(\oceanSwell)[1] = \set -> Pbindef(\oceanPulses);

// Vast spatial resonance: abyssal expanse
Ndef(\oceanSwell)[10] = \filter -> { |in|
	var rev;
	rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.4);
	LPF.ar(rev, 2500);
};
Ndef(\oceanSwell).set(\wet10, 0.45);
// Ndef(\oceanSwell).set(\wet10, 0); // Rollback: disable this effect
// Pbindef(\oceanPulses).stop; Ndef(\oceanSwell).fadeTime = 2; Ndef(\oceanSwell).clear(2); // Rollback: remove this instrument
)

// Source: 2026-10-07_11-27-02.scd [Block 3]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Oceanic depth: vast body of water, tidal swells and deep benthic pressure
// KEYWORDS: add_effects, append, benthic, body, brownnoise, deep, depth, freeverb2, hpf, oceanPulses, oceanSwell, oceanic, pinknoise, pressure, rlpf, sinosc, swells, tidal, vast, water
(
// Oceanic depth: vast body of water, tidal swells and deep benthic pressure
Ndef(\oceanSwell, { |amp=0.55, pan=0, t_trig=1, atk=3.5, rel=5.5, cutoff=350, rq=0.45, subFreq=42|
	var trig, env, swell, sub, foam, sigL, sigR;
	trig = K2A.ar(t_trig);
	env = EnvGen.ar(Env.perc(atk, rel, curve: [2, -2]), trig);
	swell = RLPF.ar(BrownNoise.ar(0.85), (cutoff + (env * 600)).clip(40, 4000), rq);
	sub = SinOsc.ar(subFreq) * 0.35 + (SinOsc.ar(subFreq * 2) * 0.15);
	foam = HPF.ar(PinkNoise.ar(0.18) * env.pow(1.5), 1800);
	sigL = swell + sub + foam;
	sigR = swell + (sub * 0.98) + DelayN.ar(foam, 0.04, 0.035);
	sigL = LeakDC.ar(sigL);
	sigR = LeakDC.ar(sigR);
	Balance2.ar(sigL * amp, sigR * amp, pan);
}).play;

Pbindef(\oceanPulses,
	\dur, Pseq([6, 8, 7, 9], inf),
	\t_trig, 1,
	\atk, Pwhite(2.5, 4.5, inf),
	\rel, Pwhite(4.0, 7.0, inf),
	\cutoff, Pexprand(220, 650, inf),
	\subFreq, Prand([38.89, 43.65, 49.0], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\amp, Pwhite(0.45, 0.65, inf)
);

Ndef(\oceanSwell)[1] = \set -> Pbindef(\oceanPulses);

// Vast spatial resonance: abyssal expanse
Ndef(\oceanSwell)[10] = \filter -> { |in|
	var rev;
	rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.4);
	LPF.ar(rev, 2500);
};
Ndef(\oceanSwell).set(\wet10, 0.45);
// Ndef(\oceanSwell).set(\wet10, 0); // Rollback: disable this effect
// Pbindef(\oceanPulses).stop; Ndef(\oceanSwell).fadeTime = 2; Ndef(\oceanSwell).clear(2); // Rollback: remove this instrument
)

// Source: 2026-10-07_11-27-02.scd [Block 5]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: High Choir Reverb & Ensemble Chorus
// KEYWORDS: add_effects, append, choir, choirHigh, choirLow, chorus, ensemble, freeverb2, high, reverb, sinosc
(
// High Choir Reverb & Ensemble Chorus
Ndef(\choirHigh)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.88, 0.3) };
Ndef(\choirHigh).set(\wet10, 0.25);

Ndef(\choirHigh)[11] = \filter -> { |in|
	CombC.ar(in, 0.05, [0.022, 0.029] + (SinOsc.kr([0.25, 0.33]).range(-0.0015, 0.0015)), 0.35)
};
Ndef(\choirHigh).set(\wet11, 0.15);

// Low Choir Reverb & Space
Ndef(\choirLow)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.25) };
Ndef(\choirLow).set(\wet10, 0.25);

Ndef(\choirLow)[11] = \filter -> { |in|
	CombC.ar(in, 0.05, [0.031, 0.038] + (SinOsc.kr([0.2, 0.27]).range(-0.001, 0.001)), 0.2)
};
Ndef(\choirLow).set(\wet11, 0.08);
)

// Source: 2026-10-07_11-27-02.scd [Block 6]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Movement 1: Static Loop / Exposition — Hieratic Blocks
// KEYWORDS: add_instrument, append, blocks, choirHigh, choirHighSeq, choirLow, choirLowSeq, exposition, hieratic, loop, movement, static
(
// Movement 1: Static Loop / Exposition — Hieratic Blocks
Pbindef(\choirHighSeq,
	\dur, 4.0,
	\sus, 1.8,
	\rel, 1.0,
	\f1, Pseq([293.66, 293.66, 293.66, 329.63], inf),
	\f2, Pseq([349.23, 349.23, 349.23, 392.00], inf),
	\f3, Pseq([440.00, 440.00, 466.16, 440.00], inf),
	\f4, Pseq([587.33, 466.16, 587.33, 554.37], inf),
	\t_trig, 1
);

Pbindef(\choirLowSeq,
	\dur, 4.0,
	\sus, 1.8,
	\rel, 1.2,
	\f1, Pseq([73.42, 58.27, 49.00, 55.00], inf),
	\f2, Pseq([110.00, 87.31, 73.42, 82.41], inf),
	\t_trig, 1
);

Ndef(\choirHigh).quant = 1;
Ndef(\choirLow).quant = 1;

Ndef(\choirHigh)[1] = \set -> Pbindef(\choirHighSeq);
Ndef(\choirLow)[1] = \set -> Pbindef(\choirLowSeq);
)

// Source: 2026-10-07_11-27-02.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: Glaciais e Vulcões — subterranean volcanic pulse clashed with resonant glacial ice fissures
// KEYWORDS: add, add_effects, append, clashed, fissures, freeverb2, glaciais, glacial, hpf, ice, instrument, moogff, pinknoise, pulse, resonant, ringz, sinosc, subterranean, tectonicIce, tectonicIceSeq, volcanic, vulc
(
// ADD_INSTRUMENT: Glaciais e Vulcões — subterranean volcanic pulse clashed with resonant glacial ice fissures
Ndef(\tectonicIce, { |freq=45, amp=0.35, pan=0, t_trig=0, magmaDrive=2.0, iceCutoff=4500, iceDecay=0.18, cutoff=320|
    var trigAudio, magmaEnv, iceEnv;
    var sub, magmaSig, iceNoise, icePluck, sig;

    trigAudio = K2A.ar(t_trig);
    magmaEnv = Decay2.ar(trigAudio, 0.04, 1.8);
    iceEnv = Decay2.ar(trigAudio, 0.001, iceDecay);

    // Volcanic magma: heavy sub-bass with reinforced 2nd harmonic, non-linear saturation and resonant Moog filter
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4);
    magmaSig = LeakDC.ar((sub * magmaDrive).fold2(0.7) * 2.5);
    magmaSig = MoogFF.ar(magmaSig, (cutoff * magmaEnv.range(0.8, 3.5)).clip(20, 18000), 2.8) * 3.0;

    // Glacial ice: sudden sharp brittle cracks with resonant crystalline ringing modes
    iceNoise = PinkNoise.ar * iceEnv;
    icePluck = Ringz.ar(iceNoise, [freq * 16, freq * 24.3, freq * 31.7], iceDecay).sum * 0.15;
    icePluck = HPF.ar(icePluck, 1200);

    sig = (magmaSig * magmaEnv) + icePluck;
    sig = sig.tanh;
    Pan2.ar(sig * amp, pan);
}).play;

// ADD_EFFECTS: Deep cavernous space reflecting subterranean vents and glacial chasms
Ndef(\tectonicIce)[10] = \filter -> { |in|
    var verb;
    verb = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.95, damp: 0.2);
    verb;
};
Ndef(\tectonicIce).xset(\wet10, 0.35);

// Sequences seismic eruptions and brittle glacial fracture intervals
Pbindef(\tectonicIceSeq,
    \dur, Pseq([1.5, 0.75, 0.75, 2.0, 1.0], inf),
    \midinote, Pseq([34, 31, 36, 29, 34], inf),
    \freq, Pkey(\midinote).midicps,
    \t_trig, 1,
    \magmaDrive, Pwhite(1.8, 4.5, inf),
    \iceDecay, Pwhite(0.08, 0.32, inf),
    \cutoff, Pexprand(180, 600, inf),
    \amp, Pwhite(0.28, 0.45, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\tectonicIce)[1] = \set -> Pbindef(\tectonicIceSeq);
// Pbindef(\tectonicIceSeq).stop; Ndef(\tectonicIce).fadeTime = 2; Ndef(\tectonicIce).clear(2); // Rollback: remove this instrument
)

// Source: 2026-10-07_11-27-02.scd [Block 8]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Settling (c): Global spectral dampening — submerging all active layers under an 800 Hz low-pass filter
// KEYWORDS: active, add_effects, all, append, choirHigh, choirLow, dampening, filter, global, layers, low, masterMix, oceanSwell, pass, seaBreeze, settling, spectral, submerging, tectonicIce, under
(
// Settling (c): Global spectral dampening — submerging all active layers under an 800 Hz low-pass filter

Ndef(\choirHigh)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\choirHigh).xset(\wet12, 1);
// Ndef(\choirHigh).set(\wet12, 0); // Rollback: disable choirHigh low-pass filter

Ndef(\choirLow)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\choirLow).xset(\wet12, 1);
// Ndef(\choirLow).set(\wet12, 0); // Rollback: disable choirLow low-pass filter

Ndef(\masterMix)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\masterMix).xset(\wet12, 1);
// Ndef(\masterMix).set(\wet12, 0); // Rollback: disable masterMix low-pass filter

Ndef(\oceanSwell)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\oceanSwell).xset(\wet12, 1);
// Ndef(\oceanSwell).set(\wet12, 0); // Rollback: disable oceanSwell low-pass filter

Ndef(\seaBreeze)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\seaBreeze).xset(\wet12, 1);
// Ndef(\seaBreeze).set(\wet12, 0); // Rollback: disable seaBreeze low-pass filter

Ndef(\tectonicIce)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\tectonicIce).xset(\wet12, 1);
// Ndef(\tectonicIce).set(\wet12, 0); // Rollback: disable tectonicIce low-pass filter
)

// Source: 2026-11-04_12-01-59.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
// KEYWORDS: add, add_instrument, append, binding, bpf, catalytic, cellular, coenzyme, dynklank, fad, fold, instrument, krebsSeq, leakdc, nad, pinknoise, pulse, respiration, sinosc
(
// ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
Ndef(\coenzyme, { |freq=220, amp=0.25, pan=0, t_trig=0, bindDecay=0.35, foldAmt=0.3, modRatio=3.14, rq=0.25|
    var trig, env, mod, car, folded, exciter, resFreqs, res, sig;
    trig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.002, bindDecay, 1, -4), trig);
    mod = SinOsc.ar(freq * modRatio) * (freq * env * 2.8);
    car = SinOsc.ar(freq + mod);
    folded = Fold.ar(car * (1 + (foldAmt * 8)), -0.7, 0.7);
    exciter = PinkNoise.ar * Decay2.ar(trig, 0.001, 0.015);
    resFreqs = freq * [1, 2.16, 3.42, 5.8];
    res = DynKlank.ar(`[resFreqs, [0.8, 0.4, 0.2, 0.1], [0.25, 0.18, 0.12, 0.08]], exciter);
    sig = (folded * 0.65) + (res * 0.35);
    sig = BPF.ar(sig, (freq * 2.2).clip(120, 9500), rq) * 2.8 + (sig * 0.4);
    sig = LeakDC.ar(sig) * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\krebsSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25, 0.125, 0.375], inf),
    \midinote, Pseq([48, 55, 60, 63, 58, 62, 67, 51], inf),
    \t_trig, 1,
    \amp, Pexprand(0.18, 0.32, inf),
    \bindDecay, Pseq([0.18, 0.28, 0.09, 0.45, 0.22, 0.12, 0.55, 0.25], inf),
    \foldAmt, Pwhite(0.1, 0.55, inf),
    \modRatio, Pseq([2.0, 3.14, 1.5, 4.2], inf),
    \rq, Pwhite(0.18, 0.4, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\coenzyme)[1] = \set -> Pbindef(\krebsSeq);

// Pbindef(\krebsSeq).stop; Ndef(\coenzyme).fadeTime = 2; Ndef(\coenzyme).clear(2); // Rollback: remove this instrument
)

// Source: 2026-11-04_12-01-59.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
// KEYWORDS: add, add_instrument, append, binding, bpf, catalytic, cellular, coenzyme, dynklank, fad, fold, instrument, krebsSeq, leakdc, nad, pinknoise, pulse, respiration, sinosc
(
// ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
Ndef(\coenzyme, { |freq=220, amp=0.25, pan=0, t_trig=0, bindDecay=0.35, foldAmt=0.3, modRatio=3.14, rq=0.25|
    var trig, env, mod, car, folded, exciter, resFreqs, res, sig;
    trig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.002, bindDecay, 1, -4), trig);
    mod = SinOsc.ar(freq * modRatio) * (freq * env * 2.8);
    car = SinOsc.ar(freq + mod);
    folded = Fold.ar(car * (1 + (foldAmt * 8)), -0.7, 0.7);
    exciter = PinkNoise.ar * Decay2.ar(trig, 0.001, 0.015);
    resFreqs = freq * [1, 2.16, 3.42, 5.8];
    res = DynKlank.ar(`[resFreqs, [0.8, 0.4, 0.2, 0.1], [0.25, 0.18, 0.12, 0.08]], exciter);
    sig = (folded * 0.65) + (res * 0.35);
    sig = BPF.ar(sig, (freq * 2.2).clip(120, 9500), rq) * 2.8 + (sig * 0.4);
    sig = LeakDC.ar(sig) * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\krebsSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25, 0.125, 0.375], inf),
    \midinote, Pseq([48, 55, 60, 63, 58, 62, 67, 51], inf),
    \t_trig, 1,
    \amp, Pexprand(0.18, 0.32, inf),
    \bindDecay, Pseq([0.18, 0.28, 0.09, 0.45, 0.22, 0.12, 0.55, 0.25], inf),
    \foldAmt, Pwhite(0.1, 0.55, inf),
    \modRatio, Pseq([2.0, 3.14, 1.5, 4.2], inf),
    \rq, Pwhite(0.18, 0.4, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\coenzyme)[1] = \set -> Pbindef(\krebsSeq);

Pbindef(\krebsSeq).stop; Ndef(\coenzyme).fadeTime = 2; Ndef(\coenzyme).clear(2); // Rollback: remove this instrument
)

// Source: 2026-11-04_12-01-59.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \mulhacen
// KEYWORDS: add, add_effects, append, bpf, dynklank, freeverb, instrument, leakdc, mulhacen, mulhacenSeq, pinknoise, sinosc
(
// ADD_INSTRUMENT: \mulhacen
// Evoking the highest peak of the Iberian Peninsula (3478.6m) in Sierra Nevada: glacial modal resonance and altitude wind sweeps.
Ndef(\mulhacen, { |freq=347.86, amp=0.22, pan=0, atk=0.02, rel=2.8, t_trig=0, brightness=1.8, ringDecay=3.2|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, curve: -3), trig);
    var click = PinkNoise.ar(0.12) * EnvGen.ar(Env.perc(0.001, 0.02), trig);
    var harmRatios = [1.0, 1.498, 2.0, 2.756, 3.478, 4.0];
    var harmAmps = [0.8, 0.5, 0.4, 0.25, 0.18, 0.1];
    var harmDecays = [1.0, 0.85, 0.7, 0.5, 0.4, 0.3] * ringDecay;
    var modal = DynKlank.ar(
        Ref([harmRatios * freq, harmAmps, harmDecays]),
        click,
        decayscale: env + 0.05
    );
    var wind = BPF.ar(PinkNoise.ar(0.2), freq * brightness, 0.12) * EnvGen.ar(Env.perc(0.1, rel * 0.9), trig) * 6.0;
    var sub = SinOsc.ar(freq * 0.5) * env * 0.25;
    var sig = LeakDC.ar((modal * 0.6) + wind + sub);
    Pan2.ar(sig * amp, pan);
}).play;

// Cold, expansive high-altitude reverb
Ndef(\mulhacen)[10] = \filter -> { |in|
    FreeVerb.ar(in, 1.0, 0.92, 0.15);
};
Ndef(\mulhacen).set(\wet10, 0.35);

// Sequences ascending alpine pitch gestures around the 3478.6m altitude benchmark
Pbindef(\mulhacenSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 1.0, 3.0, 2.0], inf),
    \t_trig, 1,
    \freq, Pseq([347.86, 347.86 * 1.25, 347.86 * 1.5, 347.86 * 1.125, 347.86 * 1.75, 347.86 * 2.0], inf),
    \atk, Pwhite(0.01, 0.05, inf),
    \rel, Pwhite(2.2, 3.8, inf),
    \brightness, Pwhite(1.5, 2.8, inf),
    \ringDecay, Pwhite(2.5, 4.5, inf),
    \amp, Pwhite(0.18, 0.26, inf),
    \pan, Pseq([-0.4, 0.4, -0.2, 0.2, 0.0], inf)
);

Ndef(\mulhacen)[1] = \set -> Pbindef(\mulhacenSeq);

// Pbindef(\mulhacenSeq).stop; Ndef(\mulhacen).fadeTime = 2; Ndef(\mulhacen).clear(2); // Rollback: remove this instrument
)

// Source: 2026-11-04_12-01-59.scd [Block 8]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Extrinsic Limit (d) / Settling (c): Composed final fade-out of all voices and textures
// KEYWORDS: add_instrument, all, append, coenzyme, composed, coral, coralSeq, costas, extrinsic, fade, final, krebsSeq, limit, meseta, mesetaSeq, mulhacen, mulhacenSeq, out, pireneus, settling, textures, voices
(
// Extrinsic Limit (d) / Settling (c): Composed final fade-out of all voices and textures

// 1. Cease all rhythmic and sequence triggers immediately
Pbindef(\coralSeq).stop;
Pbindef(\krebsSeq).stop;
Pbindef(\mesetaSeq).stop;
Pbindef(\mulhacenSeq).stop;

// 2. Staggered fade out: dissolve mid/plucked textures first
Ndef(\coral).fadeTime = 4;
Ndef(\coral).clear(4);

Ndef(\meseta).fadeTime = 5;
Ndef(\meseta).clear(5);

// 3. Dissolve harmonic drones, sub frequencies, and resonant spaces into silence
Ndef(\coenzyme).fadeTime = 8;
Ndef(\coenzyme).clear(8);

Ndef(\costas).fadeTime = 8;
Ndef(\costas).clear(8);

Ndef(\mulhacen).fadeTime = 10;
Ndef(\mulhacen).clear(10);

Ndef(\pireneus).fadeTime = 10;
Ndef(\pireneus).clear(10);
)

// Source: test.scd [Block 2]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Reverb (Index 10)
// KEYWORDS: add_effects, append, combl, gverb, index, probePulse, reverb, solarWind, voidPad
(
// Reverb (Index 10)
Ndef(\voidPad)[10] = \filter -> { |in| GVerb.ar(in.sum, 200, 8, 0.5, 0.5, 15, 0.5, 0.7, 0.5) };
Ndef(\voidPad).set(\wet10, 0);

// Delay (Index 11)
Ndef(\probePulse)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.15, \decayTime.kr(0.5)) };
Ndef(\probePulse).set(\wet11, 0);

// Distortion (Index 12)
Ndef(\solarWind)[12] = \filter -> { |in| (in * \drive.kr(5)).tanh }; // Changed to tanh for warmer, smoother saturation
Ndef(\solarWind).set(\wet12, 0);
)

// Source: test.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Quantization for synchronization
// KEYWORDS: add_instrument, append, for, probePulse, probeSeq, quantization, solarSeq, solarWind, synchronization, venusGravity, venusSeq, voidPad, voidSeq
(
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
)

// Source: test.scd [Block 4]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Pbindef(\probeSeq, \dur, 0.0625, \freq, Pn(Pgeom(1500, 1.15, 12), inf)); // Revert Doppler
// KEYWORDS: add_instrument, append, doppler, dur, freq, inf, pbindef, pgeom, probePulse, probeSeq, probeseq, revert, solarSeq, solarWind, venusGravity, venusSeq, voidPad, voidSeq
(
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
)

// Source: test.scd [Block 5]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: --- BLOCK 1: TWEAK_SEQUENCE ---
// KEYWORDS: append, block, probeSeq, sequence, tweak, tweak_sequence
(
Pbindef(\probeSeq, \freq, Pn(Pwhite(1800, 2500, 8), inf)); // Introduce high-pitched, erratic blips for navigation
// Pbindef(\probeSeq, \freq, 2000); // Revert to fixed frequency
)

// Source: test.scd [Block 7]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Test sound structure with synthesizer
// KEYWORDS: append, live_patch, structure, synthesizer, test
(
t = TempoClock.default;
t.tempo = 60/60; // 60 BPM
Pdef.defaultQuant = 1; // Quantize patterns to 1 beat by default
)

// Source: test.scd [Block 9]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: Low-frequency amplitude modulation to give a "breathing" quality
// KEYWORDS: amplitude, append, baseTone, breathing, frequency, give, live_patch, low, modulation, quality, sinosc
(
Ndef(\baseTone).clear;
Ndef(\baseTone, {
	|freq=100, amp=0.4, modFreq=0.2, modIndex=0.01, pan=0|
	var mod, sig;
	// Low-frequency amplitude modulation to give a "breathing" quality
	mod = SinOsc.ar(modFreq) * modIndex;
	sig = SinOsc.ar(freq * (1 + mod)); // Carrier modulated by LFO
	Pan2.ar(sig * amp, pan);
}).play;
)

// Source: test.scd [Block 10]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Reverb for baseTone (Index 10)
// KEYWORDS: add_effects, append, baseTone, basetone, combl, for, freeverb, index, reverb
(
// Reverb for baseTone (Index 10)
Ndef(\baseTone)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\baseTone).set(\wet10, 0); // Initially dry

// Delay for baseTone (Index 11) - defined but kept dry for now
Ndef(\baseTone)[11] = \filter -> { |in, delayTime=0.4, delFeedback=0.3| CombL.ar(in, delayTime, delayTime, delFeedback) };
Ndef(\baseTone).set(\wet11, 0);
)

// Source: test.scd [Block 11]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: --- Section 1: Gentle Unveiling (Intro) LIVE CODING TWEAKS ---
// KEYWORDS: append, baseTone, coding, gentle, intro, live, section, tweak_instrument, tweaks, unveiling
(
Ndef(\baseTone).fadeTime = 8; // Set fade time for smooth crossfades
Ndef(\baseTone).xset(\amp, 0.3); // Slowly fade in the base tone
// Ndef(\baseTone).xset(\amp, 0); // Revert amp
Ndef(\baseTone).xset(\wet10, 0.4); // Gently introduce spacious reverb
// Ndef(\baseTone).xset(\wet10, 0); // Revert reverb
)

// Source: test.scd [Block 12]
// MODE: append
// TYPE: LIVE_PATCH
// THEME: --- Section 2: Drifting Harmonies (Development) INSTRUMENTS ---
// KEYWORDS: append, development, drifting, harmonies, harmony, instruments, live_patch, section, sinosc
(
Ndef(\harmony).clear;
Ndef(\harmony, {
	|freq=150, amp=0.2, pan=(-0.6)|
	var sig;
	sig = SinOsc.ar(freq);
	Pan2.ar(sig * amp, pan);
}).play;
)

// Source: test.scd [Block 13]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Reverb for harmony (Index 10)
// KEYWORDS: add_effects, append, for, freeverb, harmony, index, reverb
(
// Reverb for harmony (Index 10)
Ndef(\harmony)[10] = \filter -> { |in, revDecay=0.8| FreeVerb.ar(in.sum, 1, 0.7, revDecay) };
Ndef(\harmony).set(\wet10, 0); // Initially dry
)

// Source: test.scd [Block 14]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Assign a scale-based frequency to baseTone. The Ndef's `freq` arg will be overwritten by this.
// KEYWORDS: add_instrument, append, arg, assign, baseSeq, baseTone, based, basetone, freq, frequency, harmony, harmonySeq, ndef, overwritten, scale, the, will
(
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
)

// Source: test.scd [Block 15]
// MODE: append
// TYPE: TWEAK_INSTRUMENT
// THEME: --- Section 2: Drifting Harmonies (Development) LIVE CODING TWEAKS ---
// KEYWORDS: append, baseTone, coding, development, drifting, harmonies, harmony, live, section, tweak_instrument, tweaks
(
Ndef(\baseTone).xset(\wet11, 0.3); // Introduce subtle, long delay on baseTone
// Ndef(\baseTone).xset(\wet11, 0); // Revert delay

Ndef(\harmony).fadeTime = 6; // Set fade time for harmony
Ndef(\harmony).xset(\amp, 0.15); // Gently fade in the harmony tone
// Ndef(\harmony).xset(\amp, 0); // Revert amp
Ndef(\harmony).xset(\wet10, 0.3); // Gently introduce reverb on harmony
// Ndef(\harmony).xset(\wet10, 0); // Revert reverb
)

// Source: test.scd [Block 16]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: \root, 40, // Revert root
// KEYWORDS: add_instrument, append, baseSeq, baseTone, revert, root
(
Pbindef(\baseSeq,
	\root, 52, // Shift base tone octave up
	// \root, 40, // Revert root
	\degree, Pseq([0, 3, 5, 8, 10, 8, 5, 3], inf) // New, slightly more dissonant arpeggio
	// \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf) // Revert degree
);
Ndef(\baseTone).xset(\modIndex, 0.03); // Amplitude modulation slightly more pronounced
// Ndef(\baseTone).xset(\modIndex, 0.01); // Revert modIndex
)

// Source: test.scd [Block 17]
// MODE: append
// TYPE: TWEAK_SEQUENCE
// THEME: \root, 47, // Revert root
// KEYWORDS: append, harmonySeq, revert, root, tweak_sequence
(
Pbindef(\harmonySeq,
	\root, 58, // Shift harmony root to create new intervals with baseTone
	// \root, 47, // Revert root
	\degree, Pseq([5, 8, 1, 3, 1, 8, 5, 8], inf), // New harmonic intervals
	// \degree, Pseq([4, 7, 0, 2, 0, 7, 4, 7], inf), // Revert degree
	\pan, Pseq([-0.8, 0.8, -0.6, 0.6, -0.4, 0.4, -0.2, 0.2], inf).wrap(-0.9, 0.9) // Wider, slightly faster pan
	// \pan, Pseq([-0.6, 0.6, -0.4, 0.4, -0.2, 0.2, 0, 0], inf).wrap(-0.8, 0.8) // Revert pan
);
)

// Source: xappend-museta.scd [Block 3]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
// KEYWORDS: add, add_instrument, append, binding, bpf, catalytic, cellular, coenzyme, dynklank, fad, fold, instrument, krebsSeq, leakdc, nad, pinknoise, pulse, respiration, sinosc
(
// ADD_INSTRUMENT: Catalytic binding of coenzyme (NAD/FAD cellular respiration pulse)
Ndef(\coenzyme, { |freq=220, amp=0.25, pan=0, t_trig=0, bindDecay=0.35, foldAmt=0.3, modRatio=3.14, rq=0.25|
    var trig, env, mod, car, folded, exciter, resFreqs, res, sig;
    trig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.002, bindDecay, 1, -4), trig);
    mod = SinOsc.ar(freq * modRatio) * (freq * env * 2.8);
    car = SinOsc.ar(freq + mod);
    folded = Fold.ar(car * (1 + (foldAmt * 8)), -0.7, 0.7);
    exciter = PinkNoise.ar * Decay2.ar(trig, 0.001, 0.015);
    resFreqs = freq * [1, 2.16, 3.42, 5.8];
    res = DynKlank.ar(`[resFreqs, [0.8, 0.4, 0.2, 0.1], [0.25, 0.18, 0.12, 0.08]], exciter);
    sig = (folded * 0.65) + (res * 0.35);
    sig = BPF.ar(sig, (freq * 2.2).clip(120, 9500), rq) * 2.8 + (sig * 0.4);
    sig = LeakDC.ar(sig) * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\krebsSeq,
    \dur, Pseq([0.25, 0.125, 0.125, 0.5, 0.25, 0.25, 0.125, 0.375], inf),
    \midinote, Pseq([48, 55, 60, 63, 58, 62, 67, 51], inf),
    \t_trig, 1,
    \amp, Pexprand(0.18, 0.32, inf),
    \bindDecay, Pseq([0.18, 0.28, 0.09, 0.45, 0.22, 0.12, 0.55, 0.25], inf),
    \foldAmt, Pwhite(0.1, 0.55, inf),
    \modRatio, Pseq([2.0, 3.14, 1.5, 4.2], inf),
    \rq, Pwhite(0.18, 0.4, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\coenzyme)[1] = \set -> Pbindef(\krebsSeq);

Pbindef(\krebsSeq).stop; Ndef(\coenzyme).fadeTime = 2; Ndef(\coenzyme).clear(2); // Rollback: remove this instrument
)

// Source: xappend-museta.scd [Block 5]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: \mulhacen
// KEYWORDS: add, add_effects, append, bpf, dynklank, freeverb, instrument, leakdc, mulhacen, mulhacenSeq, pinknoise, sinosc
(
// ADD_INSTRUMENT: \mulhacen
// Evoking the highest peak of the Iberian Peninsula (3478.6m) in Sierra Nevada: glacial modal resonance and altitude wind sweeps.
Ndef(\mulhacen, { |freq=347.86, amp=0.22, pan=0, atk=0.02, rel=2.8, t_trig=0, brightness=1.8, ringDecay=3.2|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, curve: -3), trig);
    var click = PinkNoise.ar(0.12) * EnvGen.ar(Env.perc(0.001, 0.02), trig);
    var harmRatios = [1.0, 1.498, 2.0, 2.756, 3.478, 4.0];
    var harmAmps = [0.8, 0.5, 0.4, 0.25, 0.18, 0.1];
    var harmDecays = [1.0, 0.85, 0.7, 0.5, 0.4, 0.3] * ringDecay;
    var modal = DynKlank.ar(
        Ref([harmRatios * freq, harmAmps, harmDecays]),
        click,
        decayscale: env + 0.05
    );
    var wind = BPF.ar(PinkNoise.ar(0.2), freq * brightness, 0.12) * EnvGen.ar(Env.perc(0.1, rel * 0.9), trig) * 6.0;
    var sub = SinOsc.ar(freq * 0.5) * env * 0.25;
    var sig = LeakDC.ar((modal * 0.6) + wind + sub);
    Pan2.ar(sig * amp, pan);
}).play;

// Cold, expansive high-altitude reverb
Ndef(\mulhacen)[10] = \filter -> { |in|
    FreeVerb.ar(in, 1.0, 0.92, 0.15);
};
Ndef(\mulhacen).set(\wet10, 0.35);

// Sequences ascending alpine pitch gestures around the 3478.6m altitude benchmark
Pbindef(\mulhacenSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 1.0, 3.0, 2.0], inf),
    \t_trig, 1,
    \freq, Pseq([347.86, 347.86 * 1.25, 347.86 * 1.5, 347.86 * 1.125, 347.86 * 1.75, 347.86 * 2.0], inf),
    \atk, Pwhite(0.01, 0.05, inf),
    \rel, Pwhite(2.2, 3.8, inf),
    \brightness, Pwhite(1.5, 2.8, inf),
    \ringDecay, Pwhite(2.5, 4.5, inf),
    \amp, Pwhite(0.18, 0.26, inf),
    \pan, Pseq([-0.4, 0.4, -0.2, 0.2, 0.0], inf)
);

Ndef(\mulhacen)[1] = \set -> Pbindef(\mulhacenSeq);

// Pbindef(\mulhacenSeq).stop; Ndef(\mulhacen).fadeTime = 2; Ndef(\mulhacen).clear(2); // Rollback: remove this instrument
)

// Source: xappend-museta.scd [Block 7]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Extrinsic Limit (d) / Settling (c): Composed final fade-out of all voices and textures
// KEYWORDS: add_instrument, all, append, coenzyme, composed, coral, coralSeq, costas, extrinsic, fade, final, krebsSeq, limit, meseta, mesetaSeq, mulhacen, mulhacenSeq, out, pireneus, settling, textures, voices
(
// Extrinsic Limit (d) / Settling (c): Composed final fade-out of all voices and textures

// 1. Cease all rhythmic and sequence triggers immediately
Pbindef(\coralSeq).stop;
Pbindef(\krebsSeq).stop;
Pbindef(\mesetaSeq).stop;
Pbindef(\mulhacenSeq).stop;

// 2. Staggered fade out: dissolve mid/plucked textures first
Ndef(\coral).fadeTime = 4;
Ndef(\coral).clear(4);

Ndef(\meseta).fadeTime = 5;
Ndef(\meseta).clear(5);

// 3. Dissolve harmonic drones, sub frequencies, and resonant spaces into silence
Ndef(\coenzyme).fadeTime = 8;
Ndef(\coenzyme).clear(8);

Ndef(\costas).fadeTime = 8;
Ndef(\costas).clear(8);

Ndef(\mulhacen).fadeTime = 10;
Ndef(\mulhacen).clear(10);

Ndef(\pireneus).fadeTime = 10;
Ndef(\pireneus).clear(10);
)

// Source: xappend-oceano.scd [Block 1]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Oceanic depth: vast body of water, tidal swells and deep benthic pressure
// KEYWORDS: add_effects, append, benthic, body, brownnoise, deep, depth, freeverb2, hpf, oceanPulses, oceanSwell, oceanic, pinknoise, pressure, rlpf, sinosc, swells, tidal, vast, water
(
// Oceanic depth: vast body of water, tidal swells and deep benthic pressure
Ndef(\oceanSwell, { |amp=0.55, pan=0, t_trig=1, atk=3.5, rel=5.5, cutoff=350, rq=0.45, subFreq=42|
	var trig, env, swell, sub, foam, sigL, sigR;
	trig = K2A.ar(t_trig);
	env = EnvGen.ar(Env.perc(atk, rel, curve: [2, -2]), trig);
	swell = RLPF.ar(BrownNoise.ar(0.85), (cutoff + (env * 600)).clip(40, 4000), rq);
	sub = SinOsc.ar(subFreq) * 0.35 + (SinOsc.ar(subFreq * 2) * 0.15);
	foam = HPF.ar(PinkNoise.ar(0.18) * env.pow(1.5), 1800);
	sigL = swell + sub + foam;
	sigR = swell + (sub * 0.98) + DelayN.ar(foam, 0.04, 0.035);
	sigL = LeakDC.ar(sigL);
	sigR = LeakDC.ar(sigR);
	Balance2.ar(sigL * amp, sigR * amp, pan);
}).play;

Pbindef(\oceanPulses,
	\dur, Pseq([6, 8, 7, 9], inf),
	\t_trig, 1,
	\atk, Pwhite(2.5, 4.5, inf),
	\rel, Pwhite(4.0, 7.0, inf),
	\cutoff, Pexprand(220, 650, inf),
	\subFreq, Prand([38.89, 43.65, 49.0], inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\amp, Pwhite(0.45, 0.65, inf)
);

Ndef(\oceanSwell)[1] = \set -> Pbindef(\oceanPulses);

// Vast spatial resonance: abyssal expanse
Ndef(\oceanSwell)[10] = \filter -> { |in|
	var rev;
	rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.92, damp: 0.4);
	LPF.ar(rev, 2500);
};
Ndef(\oceanSwell).set(\wet10, 0.45);
// Ndef(\oceanSwell).set(\wet10, 0); // Rollback: disable this effect
// Pbindef(\oceanPulses).stop; Ndef(\oceanSwell).fadeTime = 2; Ndef(\oceanSwell).clear(2); // Rollback: remove this instrument
)

// Source: xappend-oceano.scd [Block 4]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: High Choir Reverb & Ensemble Chorus
// KEYWORDS: add_effects, append, choir, choirHigh, choirLow, chorus, ensemble, freeverb2, high, reverb, sinosc
(
// High Choir Reverb & Ensemble Chorus
Ndef(\choirHigh)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.88, 0.3) };
Ndef(\choirHigh).set(\wet10, 0.25);

Ndef(\choirHigh)[11] = \filter -> { |in|
	CombC.ar(in, 0.05, [0.022, 0.029] + (SinOsc.kr([0.25, 0.33]).range(-0.0015, 0.0015)), 0.35)
};
Ndef(\choirHigh).set(\wet11, 0.15);

// Low Choir Reverb & Space
Ndef(\choirLow)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.25) };
Ndef(\choirLow).set(\wet10, 0.25);

Ndef(\choirLow)[11] = \filter -> { |in|
	CombC.ar(in, 0.05, [0.031, 0.038] + (SinOsc.kr([0.2, 0.27]).range(-0.001, 0.001)), 0.2)
};
Ndef(\choirLow).set(\wet11, 0.08);
)

// Source: xappend-oceano.scd [Block 5]
// MODE: append
// TYPE: ADD_INSTRUMENT
// THEME: Movement 1: Static Loop / Exposition — Hieratic Blocks
// KEYWORDS: add_instrument, append, blocks, choirHigh, choirHighSeq, choirLow, choirLowSeq, exposition, hieratic, loop, movement, static
(
// Movement 1: Static Loop / Exposition — Hieratic Blocks
Pbindef(\choirHighSeq,
	\dur, 4.0,
	\sus, 1.8,
	\rel, 1.0,
	\f1, Pseq([293.66, 293.66, 293.66, 329.63], inf),
	\f2, Pseq([349.23, 349.23, 349.23, 392.00], inf),
	\f3, Pseq([440.00, 440.00, 466.16, 440.00], inf),
	\f4, Pseq([587.33, 466.16, 587.33, 554.37], inf),
	\t_trig, 1
);

Pbindef(\choirLowSeq,
	\dur, 4.0,
	\sus, 1.8,
	\rel, 1.2,
	\f1, Pseq([73.42, 58.27, 49.00, 55.00], inf),
	\f2, Pseq([110.00, 87.31, 73.42, 82.41], inf),
	\t_trig, 1
);

Ndef(\choirHigh).quant = 1;
Ndef(\choirLow).quant = 1;

Ndef(\choirHigh)[1] = \set -> Pbindef(\choirHighSeq);
Ndef(\choirLow)[1] = \set -> Pbindef(\choirLowSeq);
)

// Source: xappend-oceano.scd [Block 6]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: ADD_INSTRUMENT: Glaciais e Vulcões — subterranean volcanic pulse clashed with resonant glacial ice fissures
// KEYWORDS: add, add_effects, append, clashed, fissures, freeverb2, glaciais, glacial, hpf, ice, instrument, moogff, pinknoise, pulse, resonant, ringz, sinosc, subterranean, tectonicIce, tectonicIceSeq, volcanic, vulc
(
// ADD_INSTRUMENT: Glaciais e Vulcões — subterranean volcanic pulse clashed with resonant glacial ice fissures
Ndef(\tectonicIce, { |freq=45, amp=0.35, pan=0, t_trig=0, magmaDrive=2.0, iceCutoff=4500, iceDecay=0.18, cutoff=320|
    var trigAudio, magmaEnv, iceEnv;
    var sub, magmaSig, iceNoise, icePluck, sig;

    trigAudio = K2A.ar(t_trig);
    magmaEnv = Decay2.ar(trigAudio, 0.04, 1.8);
    iceEnv = Decay2.ar(trigAudio, 0.001, iceDecay);

    // Volcanic magma: heavy sub-bass with reinforced 2nd harmonic, non-linear saturation and resonant Moog filter
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4);
    magmaSig = LeakDC.ar((sub * magmaDrive).fold2(0.7) * 2.5);
    magmaSig = MoogFF.ar(magmaSig, (cutoff * magmaEnv.range(0.8, 3.5)).clip(20, 18000), 2.8) * 3.0;

    // Glacial ice: sudden sharp brittle cracks with resonant crystalline ringing modes
    iceNoise = PinkNoise.ar * iceEnv;
    icePluck = Ringz.ar(iceNoise, [freq * 16, freq * 24.3, freq * 31.7], iceDecay).sum * 0.15;
    icePluck = HPF.ar(icePluck, 1200);

    sig = (magmaSig * magmaEnv) + icePluck;
    sig = sig.tanh;
    Pan2.ar(sig * amp, pan);
}).play;

// ADD_EFFECTS: Deep cavernous space reflecting subterranean vents and glacial chasms
Ndef(\tectonicIce)[10] = \filter -> { |in|
    var verb;
    verb = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.95, damp: 0.2);
    verb;
};
Ndef(\tectonicIce).xset(\wet10, 0.35);

// Sequences seismic eruptions and brittle glacial fracture intervals
Pbindef(\tectonicIceSeq,
    \dur, Pseq([1.5, 0.75, 0.75, 2.0, 1.0], inf),
    \midinote, Pseq([34, 31, 36, 29, 34], inf),
    \freq, Pkey(\midinote).midicps,
    \t_trig, 1,
    \magmaDrive, Pwhite(1.8, 4.5, inf),
    \iceDecay, Pwhite(0.08, 0.32, inf),
    \cutoff, Pexprand(180, 600, inf),
    \amp, Pwhite(0.28, 0.45, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\tectonicIce)[1] = \set -> Pbindef(\tectonicIceSeq);
// Pbindef(\tectonicIceSeq).stop; Ndef(\tectonicIce).fadeTime = 2; Ndef(\tectonicIce).clear(2); // Rollback: remove this instrument
)

// Source: xappend-oceano.scd [Block 7]
// MODE: append
// TYPE: ADD_EFFECTS
// THEME: Settling (c): Global spectral dampening — submerging all active layers under an 800 Hz low-pass filter
// KEYWORDS: active, add_effects, all, append, choirHigh, choirLow, dampening, filter, global, layers, low, masterMix, oceanSwell, pass, seaBreeze, settling, spectral, submerging, tectonicIce, under
(
// Settling (c): Global spectral dampening — submerging all active layers under an 800 Hz low-pass filter

Ndef(\choirHigh)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\choirHigh).xset(\wet12, 1);
// Ndef(\choirHigh).set(\wet12, 0); // Rollback: disable choirHigh low-pass filter

Ndef(\choirLow)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\choirLow).xset(\wet12, 1);
// Ndef(\choirLow).set(\wet12, 0); // Rollback: disable choirLow low-pass filter

Ndef(\masterMix)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\masterMix).xset(\wet12, 1);
// Ndef(\masterMix).set(\wet12, 0); // Rollback: disable masterMix low-pass filter

Ndef(\oceanSwell)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\oceanSwell).xset(\wet12, 1);
// Ndef(\oceanSwell).set(\wet12, 0); // Rollback: disable oceanSwell low-pass filter

Ndef(\seaBreeze)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\seaBreeze).xset(\wet12, 1);
// Ndef(\seaBreeze).set(\wet12, 0); // Rollback: disable seaBreeze low-pass filter

Ndef(\tectonicIce)[12] = \filter -> { |in| LPF.ar(in, 800) };
Ndef(\tectonicIce).xset(\wet12, 1);
// Ndef(\tectonicIce).set(\wet12, 0); // Rollback: disable tectonicIce low-pass filter
)


// Source: session_2026-11-18_16-59-57
// MODE: append
// THEME: A Classe République foi uma classe de couraçados operada pela Marinha Nacional Francesa, composta pelo République e Patrie. Suas construções começaram em 190...
(
Ndef(\republique, { |freq=110, amp=0.12, pan=(-0.3), t_trig=0, index=2|
    var env = EnvGen.ar(Env.perc(0.01, 1.8), t_trig);
    var mod = SinOsc.ar(freq * 2.76) * (freq * index * env);
    var sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.5) * 0.3);
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\seqRepublique,
    \dur, Pseq([1, 0.5, 0.5, 1.5], inf),
    \freq, Pseq([110, 110, 146.83, 123.47, 98], inf),
    \index, Pseq([1.5, 2.2, 3, 2, 1.2], inf),
    \t_trig, 1,
    \amp, Pseq([0.12, 0.09, 0.11, 0.1], inf)
);
Ndef(\republique)[1] = \set -> Pbindef(\seqRepublique);

Ndef(\patrie, { |freq=220, amp=0.08, pan=0.3, t_trig=0, tone=0.4|
    var env = EnvGen.ar(Env.perc(0.002, 0.65), t_trig);
    var exciter = WhiteNoise.ar(0.18) + Impulse.ar(0, 0, 0.7);
    var metal = Ringz.ar(exciter, [freq, freq * 1.41, freq * 2.17], [0.8, 0.55, 0.35]).sum;
    var sig = LPF.ar(metal, freq * (4 + (tone * 12)));
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\seqPatrie,
    \dur, Pseq([2, 1, 1, 2.5], inf),
    \freq, Pseq([329.63, 392, 293.66, 349.23], inf),
    \tone, Pseq([0.25, 0.6, 0.4, 0.8], inf),
    \t_trig, 1,
    \amp, Pseq([0.07, 0.09, 0.08, 0.07], inf)
);
Ndef(\patrie)[1] = \set -> Pbindef(\seqPatrie);

Ndef(\republique)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 0.32, 0.7, 0.35);
};
Ndef(\republique).set(\wet10, 0); // Eco de expansão naval; wet inicia desativado.
Ndef(\patrie)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 0.42, 0.82, 0.25);
};
Ndef(\patrie).set(\wet10, 0); // Reverberação metálica, reservada para ampliar a tensão.

// Pbindef(\seqRepublique).stop; Ndef(\republique).fadeTime = 2; Ndef(\republique).clear(2); // Rollback: remove this instrument
// Pbindef(\seqPatrie).stop; Ndef(\patrie).fadeTime = 2; Ndef(\patrie).clear(2); // Rollback: remove this instrument
// Ndef(\republique).set(\wet10, 0); // Rollback: disable this effect
// Ndef(\patrie).set(\wet10, 0); // Rollback: disable this effect
)


// Source: session_2026-11-18_16-59-58
// MODE: append
// THEME: A Classe République foi uma classe de couraçados operada pela Marinha Nacional Francesa, composta pelo République e Patrie. Suas construções começaram em 190...
(
Ndef(\classeRepublique, { |freq=110, amp=0.08, pan=0, t_trig=0, tone=0.4|
    var env = EnvGen.ar(Env.perc(0.015, 1.8), t_trig);
    var hull = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.01) * 0.35);
    var metal = BPF.ar(WhiteNoise.ar, (freq * 8).clip(300, 5000), 0.08) * 5;
    var sig = (hull + (metal * tone)) * env * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\seqClasseRepublique,
    \dur, Pseq([1, 1, 0.5, 0.5, 2], inf),
    \freq, Pseq([110, 123.47, 146.83, 164.81, 146.83, 123.47], inf),
    \amp, 0.08,
    \tone, Pseq([0.25, 0.35, 0.5, 0.65, 0.4], inf),
    \pan, Pseq([-0.25, 0.25], inf),
    \t_trig, 1
);
Ndef(\classeRepublique)[1] = \set -> Pbindef(\seqClasseRepublique);

// Pbindef(\seqClasseRepublique).stop; Ndef(\classeRepublique).fadeTime = 2; Ndef(\classeRepublique).clear(2); // Rollback: remove this instrument
)


// Source: session_2026-11-18_18-36-52
// MODE: append
// THEME: Escorre sob a ponte o rio Sena e em nossos amores a lembrança minha cena.
(
// Rio Sena: fluxo contínuo sob a ponte (ruído filtrado e ressonância grave)
Ndef(\rioSena, { |amp=0.14, cutoff=720, flowRate=0.11, pan=0|
	var tide, noise, bridge, sig;
	tide = SinOsc.kr(flowRate).range(0.65, 1.0);
	noise = PinkNoise.ar(0.35) + (BrownNoise.ar(0.18));
	noise = LPF.ar(noise, cutoff * SinOsc.kr(0.07).range(0.8, 1.35));
	bridge = SinOsc.ar([55, 55.4], 0, 0.08) + (BPF.ar(noise, 180, 0.35) * 1.4);
	sig = [noise + bridge[0], DelayC.ar(noise, 0.06, SinOsc.kr(0.13).range(0.008, 0.032)) + bridge[1]];
	if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp * tide) } { Pan2.ar(sig, pan, amp * tide) };
}).fadeTime_(4).play;

Ndef(\rioSena)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.35);
};
Ndef(\rioSena).set(\wet10, 0.28);

// Lembrança: notas delicadas de memória e afeto
Ndef(\lembranca, { |freq=440, amp=0.16, pan=0, t_trig=0, decay=1.8, warmth=1.2|
	var trig, env, mod, tone, sig;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.015, decay.clip(0.2, 4.0));
	mod = SinOsc.ar(freq * 2.0) * (freq * 0.45 * env);
	tone = SinOsc.ar(freq + mod, 0, 0.65) + SinOsc.ar(freq * 0.5, 0, 0.25);
	sig = LPF.ar(tone, (freq * warmth * 2.5).clip(300, 5000));
	Pan2.ar(sig * env * amp, pan);
}).fadeTime_(3).play;

Pbindef(\lembrancaSeq,
	\dur, Pseq([1.5, 0.75, 1.25, 2.0, 1.0, 1.5], inf),
	\scale, Scale.minor,
	\root, 9, // Lá menor
	\octave, 4,
	\degree, Pseq([0, 2, 4, 5, 4, 2, 0, -1], inf),
	\decay, Pwhite(1.4, 2.4, inf),
	\warmth, Pwhite(1.0, 1.6, inf),
	\amp, Pexprand(0.11, 0.17, inf),
	\pan, Pwhite(-0.45, 0.45, inf),
	\t_trig, 1
);

Ndef(\lembranca)[1] = \set -> Pbindef(\lembrancaSeq);

// Pbindef(\lembrancaSeq).stop; Ndef(\lembranca).fadeTime = 2; Ndef(\lembranca).clear(2); // Rollback: remove this instrument
// Ndef(\rioSena).fadeTime = 2; Ndef(\rioSena).clear(2); // Rollback: remove this instrument
)


// Source: session_2026-11-18_18-37-22
// MODE: append
// THEME: Longo demais, Marcial, seu epigrama, diz o veloz que não escreve nada, de quem ninguém reclama.
(
// ADD_INSTRUMENT: Epigrama (sharp, swift, staccato voice contrasting the sustained layers)
// Formal archetype: Intrinsic Limit (b) - introducing terse, high-velocity rhythmic punctuation
Ndef(\epigrama, { |freq=660, amp=0.14, pan=0, t_trig=0, decay=0.09, bite=2.5|
    var trig, env, mod, osc, click, sig;

    trig = K2A.ar(t_trig);
    env = Decay2.ar(trig, 0.002, decay.clip(0.03, 0.4));

    mod = SinOsc.ar(freq * 3.14) * (freq * bite * env);
    osc = SinOsc.ar(freq + mod);
    click = BPF.ar(WhiteNoise.ar, (freq * 2.5).clip(400, 9000), 0.25) * 2.5;

    sig = LeakDC.ar((osc * 0.7) + (click * 0.3)).tanh;
    Pan2.ar(sig * env * amp, pan);
}).play;

Pbindef(\epigramaSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.375], inf),
    \scale, Scale.minor,
    \root, 0,
    \octave, Pwrand([5, 6], [0.7, 0.3], inf),
    \degree, Pseq([0, 4, 2, 7, 5, 4, 1, 0], inf),
    \decay, Pwhite(0.04, 0.12, inf),
    \bite, Pwhite(1.8, 3.6, inf),
    \amp, Pexprand(0.09, 0.16, inf),
    \pan, Pseq([-0.55, 0.55, -0.25, 0.35], inf),
    \t_trig, 1
);

Ndef(\epigrama)[1] = \set -> Pbindef(\epigramaSeq);

// Pbindef(\epigramaSeq).stop; Ndef(\epigrama).fadeTime = 2; Ndef(\epigrama).clear(2); // Rollback: remove this instrument
)


// Source: session_2026-11-19_13-34-21
// MODE: append
// THEME: Capitu olhou para mim com uns olhos tão profundos e serenos que pareciam duas vagas de ressaca recolhendo a espuma da praia. Não disse nada durante minutos; ...
(
Ndef(\capituMar, { |amp=0.12, cutoff=720, tideRate=0.07, drift=0.025|
	var tide, foam, undertow, left, right;
	tide = SinOsc.kr(tideRate).range(0.35, 0.85);
	foam = PinkNoise.ar(0.22) + (BrownNoise.ar(0.12));
	foam = LPF.ar(foam, cutoff * SinOsc.kr(0.035).range(0.65, 1.35));
	undertow = SinOsc.ar([48, 48.4], 0, 0.11) + (BPF.ar(foam, 190, 0.36) * 1.4);
	left = foam + undertow[0];
	right = DelayC.ar(foam, 0.08, SinOsc.kr(0.11).range(0.012, 0.055)) + undertow[1];
	[left, right] * tide * amp;
}).fadeTime_(4).play;

Pbindef(\capituMarSeq,
	\dur, Pseq([3, 2, 4, 2.5], inf),
	\cutoff, Pseq([680, 540, 820, 620], inf),
	\tideRate, 0.07,
	\amp, 0.12
);
Ndef(\capituMar)[1] = \set -> Pbindef(\capituMarSeq);

Ndef(\capituMar)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 0.9, 0.78, 0.28)
};
Ndef(\capituMar).set(\wet10, 0);

Ndef(\capituRelogio, { |freq=72, amp=0, t_trig=0, pan=0|
	var trig, env, body, overtone, tick;
	trig = K2A.ar(t_trig);
	env = Decay2.ar(trig, 0.004, 0.36);
	body = SinOsc.ar(freq, 0, 0.45) + SinOsc.ar(freq * 2.01, 0, 0.16);
	overtone = SinOsc.ar(freq * 5.03, 0, 0.035);
	tick = BPF.ar(WhiteNoise.ar, 1250, 0.22) * Decay2.ar(trig, 0.001, 0.025) * 0.35;
	Pan2.ar((body + overtone + tick) * env * amp, pan);
}).fadeTime_(2).play;

Pbindef(\capituRelogioSeq,
	\dur, Pseq([1, 1, 1, 1, 1, 1, 1, 1], inf),
	\freq, Pseq([72, 72, 72, 72, 74, 72, 72, 72], inf),
	\t_trig, 1,
	\amp, 0.13,
	\pan, 0
);
Ndef(\capituRelogio)[1] = \set -> Pbindef(\capituRelogioSeq);

Ndef(\capituRelogio)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 0.75, 0.62, 0.18)
};
Ndef(\capituRelogio).set(\wet10, 0);

// Pbindef(\capituRelogioSeq).stop; Ndef(\capituRelogio).fadeTime = 2; Ndef(\capituRelogio).clear(2); // Rollback: remove this instrument
// Pbindef(\capituMarSeq).stop; Ndef(\capituMar).fadeTime = 2; Ndef(\capituMar).clear(2); // Rollback: remove this instrument
)
