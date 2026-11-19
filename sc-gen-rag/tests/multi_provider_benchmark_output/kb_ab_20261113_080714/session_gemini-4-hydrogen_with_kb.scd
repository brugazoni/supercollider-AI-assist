// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Hydrogen
// Model ID: openrouter:google/gemini-4-hydrogen
// Date: 2026-11-13T11:17:42.558042+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\antarcticSilence).fadeTime = 4;

Ndef(\antarcticSilence, { |freq=55, amp=0.35, cutoff=600, res=0.4, iceMix=0.2, pan=0, t_trig=1|
	var env, sub, body, ice, sig, filt;
	env = EnvGen.ar(Env.perc(0.8, 6.0, 1, -2), t_trig);
	sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4);
	body = Splay.ar(Saw.ar(freq * [0.995, 1.0, 1.005, 1.502]));
	ice = BPF.ar(PinkNoise.ar(1), LFNoise1.kr(0.3).range(2500, 6000), 0.04) * 8.0;
	filt = RLPF.ar(body, cutoff + (env * 400), res);
	sig = (filt * 0.5) + (sub * 0.35) + (ice * iceMix);
	if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp * (0.4 + (env * 0.6))) } { Pan2.ar(sig, pan, amp * (0.4 + (env * 0.6))) };
}).play;

Pbindef(\antarcticSilenceSeq,
	\dur, Pseq([6.0, 4.0, 8.0], inf),
	\degree, Pseq([0, -1, -3], inf),
	\octave, 2,
	\cutoff, Pwhite(350, 750, inf),
	\iceMix, Pwhite(0.1, 0.3, inf),
	\pan, Pwhite(-0.2, 0.2, inf),
	\t_trig, 1
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);

// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
Ndef(\ironChains).fadeTime = 2;

Ndef(\ironChains, { |freq=420, amp=0.25, modIndex=4.0, whipMix=0.4, pan=0, t_trig=0|
	var env, whipEnv, mod, metal, whip, chains, sig;
	env = EnvGen.ar(Env.perc(0.002, 0.35, 1, -6), t_trig);
	whipEnv = EnvGen.ar(Env.perc(0.001, 0.05, 1, -10), t_trig);
	mod = SinOsc.ar(freq * 3.41) * (freq * modIndex * env);
	metal = SinOsc.ar(freq + mod) * env;
	chains = Ringz.ar(K2A.ar(t_trig), freq * [1.0, 2.76, 4.13], 0.4).sum * 0.15;
	whip = HPF.ar(WhiteNoise.ar(1), 2200) * whipEnv;
	sig = (metal * 0.5) + chains + (whip * whipMix);
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\ironChainsSeq,
	\dur, Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1.0], inf),
	\freq, Pexprand(300, 950, inf),
	\modIndex, Pwhite(2.5, 6.0, inf),
	\whipMix, Pseq([0.2, 0.1, 0.7, 0.15, 0.5, 0.1], inf),
	\pan, Pwhite(-0.7, 0.7, inf),
	\amp, Pwhite(0.15, 0.3, inf),
	\t_trig, 1
);

Ndef(\ironChains)[1] = \set -> Pbindef(\ironChainsSeq);

// Pbindef(\ironChainsSeq).stop; Ndef(\ironChains).fadeTime = 2; Ndef(\ironChains).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
	~enableRecording = false;
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// 0. SAFETY LIMITER
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;
	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// 1. DISCRETE INSTRUMENTS
	SynthDef(\brassTick, { |out=0, freq=1800, amp=0.15, pan=0, decay=0.04, bright=1.0|
		var env, exc, res, sig;
		env = EnvGen.ar(Env.perc(0.0005, decay, 1, -8), doneAction: 2);
		exc = Impulse.ar(0) + (WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(0.0002, 0.004)));
		res = Ringz.ar(exc, freq * [1.0, 2.37, 4.18], decay * [1.0, 0.6, 0.35]).sum;
		sig = HPF.ar(res, 400 * bright) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	SynthDef(\frenchChime, { |out=0, freq=523.25, amp=0.18, pan=0, dur=2.5, modIdx=2.2|
		var env, modEnv, mod1, mod2, car, sig;
		env = EnvGen.ar(Env.perc(0.004, dur.max(0.2), 1, -4), doneAction: 2);
		modEnv = EnvGen.ar(Env.perc(0.001, (dur * 0.35).max(0.05), 1, -6));
		mod1 = SinOsc.ar(freq * 2.71) * (freq * modIdx * modEnv);
		mod2 = SinOsc.ar(freq * 3.51) * (freq * (modIdx * 0.5) * modEnv);
		car = SinOsc.ar(freq + mod1 + mod2);
		sig = LPF.ar(car, 6500) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	SynthDef(\pendulumSwing, { |out=0, freq=82, amp=0.25, pan=0|
		var env, thump, air, sig;
		env = EnvGen.ar(Env.perc(0.02, 0.65, 1, -5), doneAction: 2);
		thump = SinOsc.ar(freq * XLine.kr(1.4, 1.0, 0.04)) * EnvGen.ar(Env.perc(0.002, 0.18));
		air = BPF.ar(PinkNoise.ar(1), 240, 0.35) * EnvGen.ar(Env.perc(0.08, 0.45));
		sig = (thump * 0.7) + (air * 0.5);
		Out.ar(out, Pan2.ar(sig * amp * env, pan));
	}).add;
	s.sync;

	// 2. CONTINUOUS TEXTURES & MASTER MIX
	Ndef(\gearSwarm, { |amp=0, dens=18, centerFreq=2200, spread=0.7|
		var trig1, trig2, tick1, tick2, sig;
		trig1 = Dust.ar(dens);
		trig2 = Impulse.ar((dens * 0.35).clip(1, 30)) + Dust.ar(dens * 0.5);
		tick1 = Ringz.ar(trig1, TExpRand.ar(centerFreq * 0.6, centerFreq * 1.8, trig1), 0.025);
		tick2 = Ringz.ar(trig2, TExpRand.ar(centerFreq * 0.9, centerFreq * 2.4, trig2), 0.018);
		sig = Pan2.ar(tick1, TRand.ar(spread.neg, spread, trig1)) +
		      Pan2.ar(tick2, TRand.ar(spread.neg, spread, trig2));
		LPF.ar(sig, 7500) * amp * 0.35;
	});

	Ndef(\timeBreath, { |amp=0, root=110, cutoff=500, breathRate=0.14|
		var lfo, freqs, voices, sig;
		lfo = SinOsc.kr(breathRate).range(0.25, 1.0);
		freqs = root * [0.5, 1.0, 1.004, 1.5, 2.0, 2.007];
		voices = freqs.collect { |f, idx|
			var det = LFNoise2.kr(0.08 + (idx * 0.02)).range(0.997, 1.003);
			(SinOsc.ar(f * det) * 0.7) + (LFTri.ar(f * det) * 0.3);
		};
		sig = Splay.ar(voices, 0.65);
		sig = LPF.ar(sig, cutoff * lfo.linlin(0.25, 1.0, 0.6, 1.4));
		sig * lfo * amp;
	});

	Ndef(\masterMix, {
		var synths, swarm, breath;
		synths = In.ar(~synthBus, 2);
		swarm = Ndef.ar(\gearSwarm, 2);
		breath = Ndef.ar(\timeBreath, 2);
		synths + swarm + breath;
	});

	Ndef(\masterMix)[10] = \filter -> { |in|
		FreeVerb2.ar(in[0], in[1], 1.0, \room.kr(0.65), \damp.kr(0.45));
	};
	Ndef(\masterMix).set(\wet10, 0.22);
	Ndef(\masterMix).play;
	s.sync;

	// 3. CHRONOLOGICAL SCORE
	Tdef(\masterScore, {
		0.5.wait;

		"0:00 - [Cue 1: A Oficina Estreita]".postln;
		Pbindef(\pendulumSeq,
			\instrument, \pendulumSwing,
			\out, ~synthBus,
			\dur, 1.0,
			\freq, Pseq([82, 78], inf),
			\pan, Pseq([-0.25, 0.25], inf),
			\amp, 0.22
		).play;

		Pbindef(\tickSeq,
			\instrument, \brassTick,
			\out, ~synthBus,
			\dur, Pseq([0.5, 0.5, 0.49, 0.51], inf),
			\freq, Pseq([1800, 1450, 1820, 1430], inf),
			\decay, 0.035,
			\pan, Pwhite(-0.4, 0.4, inf),
			\amp, 0.14
		).play;
		8.wait;

		"0:08 - [Cue 2: O Enxame de Latão]".postln;
		Pbindef(\pocketSeq,
			\instrument, \brassTick,
			\out, ~synthBus,
			\dur, Pseq([0.165, 0.168, 0.162, 0.17], inf),
			\freq, Pexprand(2400, 4800, inf),
			\decay, 0.02,
			\bright, 1.4,
			\pan, Pwhite(-0.85, 0.85, inf),
			\amp, Pwhite(0.06, 0.12, inf)
		).play;

		Ndef(\gearSwarm).fadeTime = 6;
		Ndef(\gearSwarm).xset(\amp, 0.45, \dens, 22);

		4.do { |i|
			Ndef(\gearSwarm).xset(\dens, 22 + (i * 10), \centerFreq, 2000 + (i * 350));
			5.wait;
		};

		"0:28 - [Cue 3: Carrilhões Franceses]".postln;
		Pbindef(\chimeSeq,
			\instrument, \frenchChime,
			\out, ~synthBus,
			\dur, Pseq([2.5, 1.5, 3.0, 2.0], inf),
			\degree, Pseq([0, 4, 7, 5, 2, 9], inf),
			\scale, Scale.major,
			\octave, Pseq([5, 6, 5], inf),
			\modIdx, Pwhite(1.5, 2.8, inf),
			\pan, Pwhite(-0.6, 0.6, inf),
			\amp, 0.15
		).play;

		Ndef(\masterMix).set(\wet10, 0.35);
		4.do { |i|
			Pbindef(\tickSeq, \dur, Pseq([0.48, 0.52, 0.47, 0.53] * (1 - (i * 0.03)), inf));
			5.wait;
		};

		"0:48 - [Cue 4: Defasagem Máxima e Silêncio dos Olhos Fechados]".postln;
		Ndef(\gearSwarm).fadeTime = 3;
		Ndef(\gearSwarm).xset(\dens, 75, \amp, 0.6);
		4.wait;

		// Settling / Flashback (c): abrupt drop to stark fragility
		Pbindef(\pocketSeq).stop;
		Pbindef(\tickSeq).stop;
		Ndef(\gearSwarm).fadeTime = 1.5;
		Ndef(\gearSwarm).xset(\amp, 0.08, \dens, 6);

		Ndef(\timeBreath).fadeTime = 5;
		Ndef(\timeBreath).xset(\amp, 0.38, \root, 110, \cutoff, 650);
		Ndef(\masterMix).set(\wet10, 0.48);

		4.do { |i|
			Ndef(\timeBreath).xset(\cutoff, 550 + (i * 180));
			5.wait;
		};

		"1:12 - [Cue 5: O Respirar do Tempo]".postln;
		Pbindef(\chimeSeq, \dur, Pseq([4.0, 3.5, 5.0], inf), \amp, 0.11);
		Pbindef(\pendulumSeq, \dur, 1.25, \amp, 0.16);
		Ndef(\timeBreath).xset(\breathRate, 0.18, \cutoff, 900);

		3.do { |i|
			Ndef(\timeBreath).xset(\amp, 0.42 - (i * 0.06));
			5.wait;
		};

		"1:27 - [Cue 6: Retorno e Repouso]".postln;
		// Resolution (a): return to single steady tick & pendulum
		Pbindef(\chimeSeq).stop;
		Ndef(\gearSwarm).fadeTime = 4;
		Ndef(\gearSwarm).xset(\amp, 0);
		Ndef(\timeBreath).fadeTime = 6;
		Ndef(\timeBreath).xset(\amp, 0);

		Pbindef(\tickSeq, \dur, 0.5, \freq, Pseq([1800, 1450], inf), \amp, 0.1).play;
		6.wait;

		// Extrinsic Limit (d): composed fade to silence
		Pbindef(\pendulumSeq).stop;
		Pbindef(\tickSeq).stop;
		Ndef(\masterMix).fadeTime = 4;
		Ndef(\masterMix).set(\wet10, 0.1);
		4.wait;

		Pbindef(\pendulumSeq).clear;
		Pbindef(\tickSeq).clear;
		Pbindef(\pocketSeq).clear;
		Pbindef(\chimeSeq).clear;
		Ndef(\gearSwarm).clear(2);
		Ndef(\timeBreath).clear(2);
		Ndef(\masterMix).clear(2);
		"Score Complete.".postln;
		Tdef(\masterScore).stop;
	});

	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 04 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
s.waitForBoot({
	~enableRecording = false;
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// 1. SAFETY LIMITER
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;
	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// 2. DISCRETE SYNTHDEFS (Cavernous Limestone & Water)
	SynthDef(\calcitaDrop, { |out=0, freq=1200, decay=0.35, pan=0, amp=0.2|
		var env, pitchEnv, sig, res;
		env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), doneAction: 2);
		pitchEnv = XLine.kr(freq * 1.45, freq, 0.025);
		sig = SinOsc.ar(pitchEnv) * env;
		res = Ringz.ar(sig, freq * [1.0, 2.02, 3.14], [0.25, 0.15, 0.08]).sum * 0.18;
		sig = (sig * 0.7) + res;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	SynthDef(\stalactiteModal, { |out=0, freq=220, bright=0.6, dur=2.5, pan=0, amp=0.18|
		var env, exc, freqs, amps, rings, sig;
		env = EnvGen.ar(Env.linen(0.01, (dur - 0.5).max(0.05), 0.49), doneAction: 2);
		exc = (Impulse.ar(0) * 0.6) + (BPF.ar(PinkNoise.ar, freq * 2.5, 0.25) * EnvGen.ar(Env.perc(0.002, 0.04)));
		freqs = freq * [1.0, 1.58, 2.24, 3.12, 4.08];
		amps = [1.0, 0.55, 0.35, 0.2 * bright, 0.1 * bright];
		rings = [2.8, 2.2, 1.6, 1.1, 0.7] * (dur * 0.5).clip(0.3, 2.0);
		sig = DynKlank.ar(Ref([freqs, amps, rings]), exc);
		sig = LPF.ar(sig, (freq * 6).clip(200, 14000));
		Out.ar(out, Pan2.ar(sig * env * amp, pan));
	}).add;

	SynthDef(\mineralCurtain, { |out=0, freq=110, foldAmt=1.5, dur=4.0, pan=0, amp=0.15|
		var env, sig, mod;
		env = EnvGen.ar(Env.linen(0.4, (dur - 1.2).max(0.1), 0.8), doneAction: 2);
		mod = LFNoise2.kr(0.4).range(0.99, 1.01);
		sig = Mix([
			SinOsc.ar(freq * mod) * 0.6,
			SinOsc.ar(freq * 1.502 * mod) * 0.3,
			LFTri.ar(freq * 2.0) * 0.2
		]);
		sig = Fold.ar(sig * foldAmt, -0.7, 0.7) * 0.6;
		sig = BPF.ar(sig, freq * [1, 2, 3], 0.35).sum * 2.5;
		Out.ar(out, Pan2.ar(sig * env * amp, pan));
	}).add;
	s.sync;

	// 3. CONTINUOUS TEXTURES & MASTER MIXER
	Ndef(\cavernAir, { |amp=0, cutoff=280, lfoRate=0.07|
		var lfo, sig;
		lfo = SinOsc.kr(lfoRate).range(0.5, 1.0);
		sig = BrownNoise.ar(0.6) + (PinkNoise.ar(0.25));
		sig = RLPF.ar(sig, cutoff * lfo, 0.45);
		sig = sig + (SinOsc.ar(48) * 0.12) + (SinOsc.ar(96) * 0.06);
		Pan2.ar(sig * amp, LFNoise2.kr(0.05).range(-0.3, 0.3));
	});

	Ndef(\subterraneanStream, { |amp=0, centerFreq=650, rq=0.25|
		var n1, n2, sig;
		n1 = BPF.ar(WhiteNoise.ar, centerFreq * LFNoise2.kr(0.3).range(0.85, 1.15), rq) * 4.5;
		n2 = BPF.ar(PinkNoise.ar, (centerFreq * 1.6) * LFNoise2.kr(0.22).range(0.9, 1.1), rq) * 3.5;
		sig = Splay.ar([n1, n2], 0.6);
		sig * amp;
	});

	Ndef(\masterMix, {
		var synths, air, stream;
		synths = In.ar(~synthBus, 2);
		air = Ndef.ar(\cavernAir, 2);
		stream = Ndef.ar(\subterraneanStream, 2);
		synths + air + stream;
	});

	Ndef(\masterMix)[10] = \filter -> { |in|
		FreeVerb2.ar(in[0], in[1], 1.0, \room.kr(0.88), \damp.kr(0.35));
	};
	Ndef(\masterMix)[11] = \filter -> { |in|
		CombC.ar(in, 0.8, [0.37, 0.53], 3.2);
	};
	Ndef(\masterMix).set(\wet10, 0.45, \wet11, 0.0);
	Ndef(\masterMix).play;
	s.sync;

	// 4. CHRONOLOGICAL SCORE (7 Salões da Gruta do Maquiné)
	Tdef(\masterScore, {
		0.5.wait;

		"0:00 - [Cue 1: O Vestíbulo e o Primeiro Gotejar]".postln;
		Ndef(\cavernAir).fadeTime = 6;
		Ndef(\cavernAir).xset(\amp, 0.35, \cutoff, 240);

		Pbindef(\dripSeq,
			\instrument, \calcitaDrop,
			\out, ~synthBus,
			\dur, Pwhite(0.8, 2.4, inf),
			\freq, Pexprand(900, 2600, inf),
			\decay, Pwhite(0.2, 0.5, inf),
			\pan, Pwhite(-0.7, 0.7, inf),
			\amp, Pwhite(0.12, 0.24, inf)
		).play;

		3.do { |i|
			Ndef(\cavernAir).xset(\cutoff, 240 + (i * 40));
			4.wait;
		};

		"0:12 - [Cue 2: Salão das Cortinas Minerais]".postln;
		Ndef(\masterMix).set(\wet10, 0.62, \wet11, 0.22);

		Pbindef(\curtainSeq,
			\instrument, \mineralCurtain,
			\out, ~synthBus,
			\dur, Pseq([4.0, 3.5, 5.0], inf),
			\degree, Pseq([0, 2, -2, 3], inf),
			\scale, Scale.minor,
			\octave, 3,
			\foldAmt, Pwhite(1.2, 2.2, inf),
			\pan, Pwhite(-0.5, 0.5, inf),
			\amp, 0.16
		).play;

		4.do { |i|
			Ndef(\cavernAir).xset(\cutoff, 360 + (i * 50));
			4.wait;
		};

		"0:28 - [Cue 3: As Estalactites de Peter Lund]".postln;
		Pbindef(\dripSeq, \dur, Pwhite(0.25, 0.9, inf), \amp, Pwhite(0.08, 0.18, inf));

		Pbindef(\stalactiteSeq,
			\instrument, \stalactiteModal,
			\out, ~synthBus,
			\dur, Pseq([1.5, 0.75, 2.25, 1.0], inf),
			\degree, Pseq([0, 4, 7, 5, 2, 9], inf),
			\scale, Scale.dorian,
			\octave, Pseq([4, 5, 4], inf),
			\bright, Pwhite(0.4, 0.85, inf),
			\pan, Pwhite(-0.65, 0.65, inf),
			\amp, 0.18
		).play;

		4.do { |i|
			Ndef(\masterMix).set(\room, 0.85 + (i * 0.03));
			5.wait;
		};

		"0:48 - [Cue 4: Águas Subterrâneas (Intrinsic Limit)]".postln;
		Ndef(\subterraneanStream).fadeTime = 6;
		Ndef(\subterraneanStream).xset(\amp, 0.28, \centerFreq, 520);
		Pbindef(\dripSeq, \dur, Pwhite(0.08, 0.32, inf), \freq, Pexprand(1200, 4200, inf));

		3.do { |i|
			Ndef(\subterraneanStream).xset(\centerFreq, 520 + (i * 220), \rq, 0.22 - (i * 0.04));
			4.wait;
		};

		"1:00 - [Cue 5: Sétimo Salão — Escuridão e Eco (Settling)]".postln;
		// Settling (c): abrupt drop to stark subterranean fragility
		Pbindef(\curtainSeq).stop;
		Pbindef(\stalactiteSeq).stop;
		Ndef(\subterraneanStream).fadeTime = 2;
		Ndef(\subterraneanStream).xset(\amp, 0.05);
		Ndef(\cavernAir).fadeTime = 3;
		Ndef(\cavernAir).xset(\amp, 0.2, \cutoff, 180);
		Ndef(\masterMix).set(\wet10, 0.78, \wet11, 0.35);

		Pbindef(\dripSeq, \dur, Pwhite(1.2, 2.8, inf), \freq, Pexprand(700, 1600, inf), \amp, 0.16);
		8.wait;

		"1:08 - [Cue 6: Retorno à Superfície (Resolution & Extrinsic Limit)]".postln;
		// Resolution (a): return to opening single-drop motif & fade out
		Ndef(\subterraneanStream).fadeTime = 5;
		Ndef(\subterraneanStream).xset(\amp, 0);
		Ndef(\cavernAir).fadeTime = 8;
		Ndef(\cavernAir).xset(\amp, 0);
		Pbindef(\dripSeq, \dur, 2.0, \amp, 0.1);
		6.wait;

		Pbindef(\dripSeq).stop;
		Ndef(\masterMix).fadeTime = 4;
		Ndef(\masterMix).set(\wet10, 0.2, \wet11, 0);
		4.wait;

		Pbindef(\dripSeq).clear;
		Pbindef(\curtainSeq).clear;
		Pbindef(\stalactiteSeq).clear;
		Ndef(\cavernAir).clear(2);
		Ndef(\subterraneanStream).clear(2);
		Ndef(\masterMix).clear(2);
		"Score Complete.".postln;
		Tdef(\masterScore).stop;
	});

	Tdef(\masterScore).play;
});
)

