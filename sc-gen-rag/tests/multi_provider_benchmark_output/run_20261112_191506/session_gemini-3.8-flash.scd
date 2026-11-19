// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T22:15:07.549427+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ADD_INSTRUMENT: Antarctic storm tension / Frozen silence of 27 years
// Archetype: Intrinsic Limit (b) - slow build toward the breaking point of domestic tension
Ndef(\antarcticDrone, { |freq=48, tension=0.1, wineAir=0.2, amp=0.25, pan=0, t_trig=0|
	var trig = K2A.ar(t_trig);
	var sub = SinOsc.ar([freq, freq * 1.005]) + (SinOsc.ar(freq * 2) * 0.25);
	var wind = BPF.ar(
		PinkNoise.ar(0.8),
		SinOsc.kr(0.08).exprange(80, 1200 + (tension * 2500)),
		0.12 + (tension * 0.2)
	) * 4.0;
	var glass = DynKlank.ar(
		`[
			[1820, 2430, 3120, 4820],
			[0.15, 0.1, 0.08, 0.04],
			[1.2, 1.8, 1.0, 0.8]
		],
		Dust.ar(1.5 + (tension * 8)) * Decay.ar(trig + Dust.ar(0.3), 0.05)
	) * wineAir;
	var sig = (sub * 0.6) + (wind * 0.5) + (glass * 0.4);
	var env = EnvGen.kr(Env.asr(2, 1, 3), 1);
	sig = LeakDC.ar(sig);
	if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, env * amp) } { Pan2.ar(sig, pan, env * amp) };
}).play;

Pbindef(\antarcticSeq,
	\dur, Pseq([4, 6, 3, 8], inf),
	\freq, Pseq([43.65, 41.2, 38.89, 43.65], inf), // Subdued F - E - Eb tensions
	\tension, Pseg(Pseq([0.05, 0.85], inf), Pseq([27, 10], inf), \exp), // 27 seconds for 27 years
	\wineAir, Pwhite(0.2, 0.6, inf),
	\pan, Pwhite(-0.2, 0.2, inf),
	\t_trig, 1,
	\amp, 0.28
);

Ndef(\antarcticDrone)[1] = \set -> Pbindef(\antarcticSeq);

// ADD_EFFECTS: Vast spatial freeze (reverb and icy delay)
Ndef(\antarcticDrone)[10] = \filter -> { |in|
	// Replaced JPverb with vanilla FreeVerb2
	FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.9, damp: 0.7);
};
Ndef(\antarcticDrone).set(\wet10, 0.4);

// Pbindef(\antarcticSeq).stop; Ndef(\antarcticDrone).fadeTime = 2; Ndef(\antarcticDrone).clear(2); // Rollback: remove this instrument
// Ndef(\antarcticDrone).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// ADD_INSTRUMENT: O Navio Negreiro - Iron chains, brutal whip snaps, and agonizing groans
// Archetype: Intrinsic Limit (b) - Shifting from cold Antarctic silence to Dantean fever and rhythmic suffering
Ndef(\chainsAndWhip, { |freq=85, amp=0.35, pan=0, t_trig=0, whipTrig=0, metalBrightness=2500|
	var trig = K2A.ar(t_trig);
	var wTrig = K2A.ar(whipTrig);
	var chainExc = PinkNoise.ar() * Decay2.ar(trig, 0.002, 0.04);
	var chains = DynKlank.ar(
		`[
			[580, 890, 1420, 2180, 3400, 4850],
			[0.5, 0.4, 0.3, 0.25, 0.15, 0.08],
			[0.3, 0.4, 0.25, 0.18, 0.1, 0.05]
		],
		chainExc,
		freqScale: (freq / 100).clip(0.5, 2.5)
	);
	var whipEnv = Decay.ar(wTrig, 0.06);
	var whipNoise = HPF.ar(WhiteNoise.ar(2.0), 1200) * whipEnv;
	var whipCrack = (BPF.ar(whipNoise, 3200, 0.2) * 8.0).tanh;
	var groanEnv = EnvGen.ar(Env.perc(0.12, 1.2, 1, -4), trig);
	var groan = Formant.ar(freq * 0.5, freq * 1.8, 450) * groanEnv * 0.4;
	var sig = (chains * 0.7) + (whipCrack * 0.9) + (groan * 0.6);
	sig = LeakDC.ar(sig);
	Pan2.ar(sig, pan, amp);
}).play;

Pbindef(\chainsSeq,
	\dur, Pseq([0.35, 0.35, 0.7, 0.35, 0.35, 1.4], inf), // Clanking irregular dance
	\freq, Pseq([78, 82, 73, 87, 65, 92], inf),
	\pan, Pseq([-0.6, 0.4, -0.3, 0.6, -0.1, 0.2], inf),
	\whipTrig, Pseq([0, 0, 1, 0, 0, 1], inf), // Whip cracks punctuated on beats
	\t_trig, 1,
	\amp, Pseq([0.32, 0.28, 0.45, 0.3, 0.27, 0.48], inf)
);

Ndef(\chainsAndWhip)[1] = \set -> Pbindef(\chainsSeq);

// ADD_EFFECTS: Tombadilho em sangue - Blood-soaked dark resonant chamber
Ndef(\chainsAndWhip)[10] = \filter -> { |in|
	var rev = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.85, damp: 0.3);
	var drive = (rev * 2.2).tanh;
	drive;
};
Ndef(\chainsAndWhip).xset(\wet10, 0.45);

// TWEAK_INSTRUMENT: Darken and heat up antarcticDrone to sea-storm blood red
Ndef(\antarcticDrone).xset(\tension, 0.95);
// Ndef(\antarcticDrone).xset(\tension, 0.1); // Revert tweak

// Pbindef(\chainsSeq).stop; Ndef(\chainsAndWhip).fadeTime = 2; Ndef(\chainsAndWhip).clear(2); // Rollback: remove this instrument
// Ndef(\chainsAndWhip).set(\wet10, 0); // Rollback: disable this effect
)


// ============================================================
// ROUND 03 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
	var s = Server.default;
	~enableRecording = false;

	// Bus Allocation
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// Safety Limiter
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;

	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// Discrete Tick SynthDef (Pocket Watch, Escapement Gears)
	SynthDef(\horologyTick, { |out=0, freq=3200, res=1800, q=0.04, amp=0.2, pan=0, hardness=0.5|
		var click = Impulse.ar(0) * 0.8 + (WhiteNoise.ar() * Decay.ar(Impulse.ar(0), 0.001 * hardness));
		var body = BPF.ar(click, freq, q) * 14.0;
		var brassRing = Ringz.ar(click, res, 0.035 * hardness) * 0.4;
		var escapementSnap = HPF.ar(PinkNoise.ar() * Decay.ar(Impulse.ar(0), 0.006), 4000) * 0.5;
		var sig = (body + brassRing + escapementSnap) * EnvGen.ar(Env.perc(0.0005, 0.05.max(0.01)), doneAction: 2);
		sig = LeakDC.ar(sig);
		OffsetOut.ar(out, Pan2.ar(sig, pan, amp));
	}).add;

	// Discrete Chime SynthDef (French Pendulum Carillon)
	SynthDef(\frenchCarillon, { |out=0, freq=440, dur=3.5, amp=0.22, pan=0|
		var strike = PinkNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.008));
		var modes = DynKlank.ar(
			Ref([
				[freq, freq * 2.76, freq * 5.4, freq * 8.93, freq * 11.2],
				[0.6, 0.35, 0.2, 0.1, 0.04],
				[dur, dur * 0.72, dur * 0.45, dur * 0.28, dur * 0.15]
			]),
			strike
		);
		var env = EnvGen.ar(Env.perc(0.002, dur.max(0.1), 1, -4), doneAction: 2);
		var sig = modes * env * amp;
		sig = LeakDC.ar(sig);
		OffsetOut.ar(out, Pan2.ar(sig, pan));
	}).add;

	s.sync;

	// Continuous Workshop Texture: Brass Resonance & Pendulum Air
	Ndef(\pendulumSwarm, { |amp=0, pulseDrift=1.0, warmth=380, breathRate=0.12|
		var p1 = SinOsc.kr(0.98 * pulseDrift).range(0.02, 0.98);
		var p2 = SinOsc.kr(1.025 * pulseDrift).range(0.02, 0.98);
		var p3 = SinOsc.kr(1.333 * pulseDrift).range(0.02, 0.98);
		var swings = [
			BPF.ar(BrownNoise.ar(0.4), 160 + (SinOsc.kr(0.5).exprange(30, 200)), 0.3) * p1,
			BPF.ar(BrownNoise.ar(0.4), 210 + (SinOsc.kr(0.4).exprange(40, 240)), 0.3) * p2
		];
		var brassChamber = DynKlank.ar(
			Ref([
				[warmth, warmth * 1.5, warmth * 2.38, warmth * 3.12],
				[0.3, 0.2, 0.12, 0.08],
				[1.2, 0.9, 0.7, 0.5]
			]),
			Dust.ar(30 * pulseDrift) * 0.04
		);
		var breath = LPF.ar(PinkNoise.ar(0.3), 800) * SinOsc.kr(breathRate).range(0.1, 0.7);
		var sig = (swings * 0.5) + (brassChamber * 0.35) + Pan2.ar(breath * 0.25, SinOsc.kr(0.05));
		sig = LeakDC.ar(sig);
		sig * amp;
	});

	// Master Mixer & Workshop Acoustics
	Ndef(\masterMix, {
		var busIn = In.ar(~synthBus, 2);
		var texIn = Ndef(\pendulumSwarm).ar(2);
		busIn + texIn;
	});

	// Acoustic Room Filter (Ladeira Workshop Interior)
	Ndef(\masterMix)[10] = \filter -> { |in|
		var room = FreeVerb2.ar(in[0], in[1], mix: 1.0, room: 0.72, damp: 0.45);
		var early = CombL.ar(in, 0.08, [0.027, 0.039], 0.4);
		(room * 0.65) + (early * 0.35);
	};
	Ndef(\masterMix).set(\wet10, 0.32);

	Ndef(\masterMix).play;

	s.sync;

	// Macro Timeline Structure (~110 seconds)
	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - [Escapamentos Solitários: Despertar na Oficina da Ladeira]".postln;

		Ndef(\pendulumSwarm).fadeTime = 3;
		Ndef(\pendulumSwarm).xset(\amp, 0.18, \pulseDrift, 0.85);

		// Pocket Watch Desynchronized Phasing (Quintessential Escapement)
		Pbindef(\pocketTicks,
			\instrument, \horologyTick,
			\out, ~synthBus,
			\dur, Pseq([0.125, 0.128, 0.122, 0.126], inf),
			\freq, Pseq([3800, 4200, 3600, 4800], inf),
			\res, Pseq([1900, 2100, 2400, 1750], inf),
			\q, 0.025,
			\hardness, Pwhite(0.4, 0.9, inf),
			\pan, Pwhite(-0.6, 0.6, inf),
			\amp, 0.22
		).play;

		// Second asynchronous layer: Grandfather clocks (Pêndulos Pesados)
		Pbindef(\pendulumTicks,
			\instrument, \horologyTick,
			\out, ~synthBus,
			\dur, Pseq([0.505, 0.495, 0.512, 0.488], inf),
			\freq, Pseq([920, 840, 1100, 780], inf),
			\res, Pseq([450, 410, 520, 380], inf),
			\q, 0.05,
			\hardness, 1.2,
			\pan, Pseq([-0.75, 0.75], inf),
			\amp, 0.35
		).play;

		5.do { |i|
			Ndef(\pendulumSwarm).xset(\warmth, 320 + (i * 35));
			3.wait;
		};

		"0:16 - [Enxame de Engrenagens: 200 Mecanismos Fora de Fase]".postln;
		Ndef(\pendulumSwarm).xset(\amp, 0.38, \pulseDrift, 1.45);

		// Dense polyrhythmic swarm of brass balance wheels
		Pbindef(\brassSwarm,
			\instrument, \horologyTick,
			\out, ~synthBus,
			\dur, Prand([0.083, 0.084, 0.081, 0.166, 0.062], inf),
			\freq, Pexprand(2400, 7200, inf),
			\res, Pexprand(1200, 3500, inf),
			\q, Pwhite(0.02, 0.06, inf),
			\pan, Pwhite(-0.95, 0.95, inf),
			\hardness, Pwhite(0.2, 0.8, inf),
			\amp, Pwhite(0.08, 0.18, inf)
		).play;

		// First distant French carillon toll
		s.sync;
		Synth(\frenchCarillon, [\out, ~synthBus, \freq, 587.33, \dur, 4.2, \amp, 0.28, \pan, -0.35]); // D5

		4.do { |idx|
			Pbindef(\brassSwarm, \amp, 0.12 + (idx * 0.03));
			Ndef(\masterMix).set(\wet10, 0.32 + (idx * 0.04));
			4.wait;
		};

		"0:32 - [O Carrilhão Francês: A Hora Desenhada]".postln;
		Pbindef(\carillonSeq,
			\instrument, \frenchCarillon,
			\out, ~synthBus,
			\dur, Pseq([1.8, 1.75, 1.85, 2.4, 3.2], inf),
			\freq, Pseq([659.25, 587.33, 523.25, 392.00, 329.63], inf), // E5, D5, C5, G4, E4
			\dur, Pseq([3.0, 3.2, 2.8, 4.0, 5.0], inf),
			\amp, Pseq([0.24, 0.26, 0.22, 0.32, 0.35], inf),
			\pan, Pseq([0.4, -0.4, 0.6, -0.2, 0.0], inf)
		).play;

		4.do { |i|
			Ndef(\pendulumSwarm).xset(\breathRate, 0.15 + (i * 0.06));
			3.wait;
		};

		"0:44 - [Limite Intrínseco: O Friccionar Acelerado dos Eixos]".postln;
		// Accelerate pocket watches slightly past their natural physical limit
		Pbindef(\pocketTicks,
			\dur, Pseq([0.095, 0.098, 0.092, 0.096], inf),
			\amp, 0.28
		);
		Ndef(\pendulumSwarm).xset(\amp, 0.48, \pulseDrift, 2.1);

		3.do { |i|
			Ndef(\masterMix).set(\wet10, 0.48 + (i * 0.06));
			4.wait;
		};

		"0:56 - [O Respirar do Tempo: Olhos Fechados do Velho Relojoeiro]".postln;
		// Settling Archetype: Cut the frantic ticking; spotlight deep breath of brass acoustics
		Pbindef(\brassSwarm).stop;
		Pbindef(\pocketTicks).stop;
		Pbindef(\pendulumTicks,
			\dur, 1.02,
			\freq, 620,
			\res, 310,
			\amp, 0.18,
			\pan, 0
		);

		Ndef(\pendulumSwarm).fadeTime = 4;
		Ndef(\pendulumSwarm).xset(\amp, 0.55, \breathRate, 0.08, \warmth, 220);
		Ndef(\masterMix).set(\wet10, 0.62);

		// Deep singular bell of Santa Efigênia
		Synth(\frenchCarillon, [\out, ~synthBus, \freq, 164.81, \dur, 8.5, \amp, 0.45, \pan, 0]); // E3

		4.do { |i|
			Ndef(\pendulumSwarm).xset(\warmth, 220 + (i * 20));
			3.wait;
		};

		"1:08 - [Resolução: O Retorno dos Pêndulos Desalinhados]".postln;
		// Return to asynchronous clockwork motif in serene reconciliation
		Pbindef(\pocketTicks,
			\dur, Pseq([0.16, 0.164, 0.158], inf),
			\freq, Pseq([3400, 3900, 3100], inf),
			\amp, 0.14
		).play;

		Pbindef(\pendulumTicks,
			\dur, Pseq([0.65, 0.63, 0.67], inf),
			\freq, Pseq([820, 780, 890], inf),
			\amp, 0.22
		);

		// One final chime resolving to the fifth
		Synth(\frenchCarillon, [\out, ~synthBus, \freq, 246.94, \dur, 7.0, \amp, 0.32, \pan, 0.2]); // B3

		4.do { |i|
			Ndef(\pendulumSwarm).xset(\amp, (0.45 - (i * 0.08)).max(0.05));
			3.wait;
		};

		"1:20 - [Dissolução: O Silêncio da Ladeira]".postln;
		// Extrinsic Limit: Controlled dissipation
		Pbindef(\carillonSeq).stop;
		Pbindef(\pocketTicks).stop;

		4.do { |i|
			Pbindef(\pendulumTicks, \amp, (0.2 - (i * 0.05)).max(0.01));
			Ndef(\pendulumSwarm).xset(\amp, (0.15 - (i * 0.035)).max(0.001));
			2.5.wait;
		};

		Pbindef(\pendulumTicks).stop;
		Ndef(\pendulumSwarm).fadeTime = 3;
		Ndef(\pendulumSwarm).xset(\amp, 0);
		3.5.wait;

		// Scoped Termination
		Pbindef(\pocketTicks).clear;
		Pbindef(\pendulumTicks).clear;
		Pbindef(\brassSwarm).clear;
		Pbindef(\carillonSeq).clear;
		Ndef(\pendulumSwarm).clear(2);
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

	// Master Safety Limiter
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;

	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// 1. Water Drop / Mineral Pit: Acoustic droplet impact with pitch-dive and calcite ring
	SynthDef(\calciteDrop, { |out=0, freq=1200, resFreq=420, decay=1.2, pan=0, amp=0.3|
		var strike, dropEnv, fEnv, body, ring, sig;
		dropEnv = EnvGen.ar(Env.perc(0.001, 0.08));
		fEnv = XLine.ar(freq * 1.5, freq * 0.7, 0.025);
		strike = SinOsc.ar(fEnv) * dropEnv;
		strike = strike + (BPF.ar(PinkNoise.ar, freq * 1.2, 0.1) * dropEnv * 1.5);
		ring = Ringz.ar(strike, [resFreq, resFreq * 1.78, resFreq * 2.82], [decay, decay * 0.7, decay * 0.4]).sum * 0.18;
		body = (strike * 0.6) + ring;
		sig = Pan2.ar(body * EnvGen.ar(Env.perc(0.002, decay, 1, -4), doneAction: 2), pan, amp);
		Out.ar(out, sig);
	}).add;

	// 2. Stalactite / Stalagmite Modal Clang: Natural limestone percussion
	SynthDef(\limestonePillar, { |out=0, freq=180, damp=1.8, brightness=0.5, pan=0, amp=0.25|
		var mallet, exciter, modes, amps, decays, sig;
		mallet = EnvGen.ar(Env.perc(0.0008, 0.015));
		exciter = (WhiteNoise.ar * mallet) + (Impulse.ar(0) * 0.8);
		modes = [freq, freq * 2.31, freq * 4.15, freq * 6.72, freq * 9.88];
		amps = [1.0, 0.65 * brightness, 0.4 * brightness, 0.2, 0.08];
		decays = [damp, damp * 0.75, damp * 0.45, damp * 0.25, damp * 0.12];
		sig = DynKlank.ar(Ref([modes, amps, decays]), exciter, freqscale: 1.0, decayscale: 1.0);
		sig = LPF.ar(sig, 8500);
		sig = Pan2.ar(sig * EnvGen.ar(Env.perc(0.001, damp, 1, -5), doneAction: 2), pan, amp);
		Out.ar(out, sig);
	}).add;

	// 3. Subterranean Seepage Grain: Microscopic fluid movement on wet stone curtains
	SynthDef(\seepageGrain, { |out=0, freq=3200, dur=0.03, pan=0, amp=0.15|
		var click, sig;
		click = BPF.ar(WhiteNoise.ar, freq, 0.12) * EnvGen.ar(Env.sine(dur.max(0.005)), doneAction: 2);
		sig = Pan2.ar(click * 3.5, pan, amp);
		Out.ar(out, sig);
	}).add;

	s.sync;

	// Continuous Ambient Atmosphere: 7 vast limestone vaults & damp drafts
	Ndef(\maquineChamber, { |amp=0, vaultFilter=280, moisture=0.4, airDrift=0.06|
		var air, breath, rumblings, moistureRumble, sig;
		breath = LFNoise1.kr(airDrift ! 2).range(0.6, 1.4);
		air = PinkNoise.ar(0.08 ! 2) * breath;
		air = BPF.ar(air, [vaultFilter, vaultFilter * 1.5], [0.15, 0.12]).sum;
		rumblings = OnePole.ar(BrownNoise.ar(0.2 ! 2), 0.992) * SinOsc.kr(0.03).range(0.5, 1.2);
		moistureRumble = BPF.ar(Dust.ar(8 ! 2) * 0.2, 60, 0.3);
		sig = air + (rumblings * 0.6) + moistureRumble;
		sig = LPF.ar(sig, 2200);
		sig * amp;
	});

	// Master Mixer and Cave Acoustic Simulation (Convolution / Large Chamber Reverb)
	Ndef(\masterMix, {
		var inSynth = In.ar(~synthBus, 2);
		var inVault = Ndef(\maquineChamber).ar(2);
		inSynth + inVault;
	});

	// Slot 10: Cavernous GVerb tail simulating deep underground cathedral-like spaces
	Ndef(\masterMix)[10] = \filter -> { |in|
		var wet;
		wet = GVerb.ar(
			in[0] + in[1],
			roomsize: 160,
			revtime: 8.5,
			damping: 0.62,
			inputbw: 0.45,
			spread: 28,
			drylevel: 0,
			earlyreflevel: -9.dbamp,
			taillevel: -3.dbamp
		);
		LeakDC.ar(wet);
	};

	Ndef(\masterMix).set(\wet10, 0.45);
	Ndef(\masterMix).play;

	s.sync;

	// Timeline Composition: 7 Subterranean Salões of Gruta do Maquiné (~2 min total)
	Tdef(\masterScore, {
		0.5.wait;

		"0:00 - [Salão I: Vestíbulo & Escuridão Profunda - Peter Lund, 1834]".postln;
		Ndef(\maquineChamber).fadeTime = 6;
		Ndef(\maquineChamber).xset(\amp, 0.32, \vaultFilter, 180, \airDrift, 0.04);
		Ndef(\masterMix).set(\wet10, 0.45);

		// Sparse isolated calcareous drips echoing in the dark
		Pbindef(\caveDrips,
			\instrument, \calciteDrop,
			\out, ~synthBus,
			\dur, Pseq([1.4, 2.1, 0.9, 3.2, 1.7], inf),
			\freq, Pexprand(950, 1950, inf),
			\resFreq, Pseq([311.13, 349.23, 233.08, 466.16], inf), // Eb, F, Bb modal
			\decay, Pwhite(1.4, 2.6, inf),
			\pan, Pwhite(-0.7, 0.7, inf),
			\amp, Pwhite(0.2, 0.38, inf)
		).play;

		4.do { |i|
			Ndef(\maquineChamber).xset(\vaultFilter, 180 + (i * 40));
			3.wait;
		};

		"0:12 - [Salão II: O Lustre das Estalactites - Percolação Calcária]".postln;
		// Microscopic seepage sounds emerging along mineral curtains
		Pbindef(\microSeep,
			\instrument, \seepageGrain,
			\out, ~synthBus,
			\dur, Prand([0.14, 0.09, 0.22, 0.07, 0.35], inf),
			\freq, Pexprand(2800, 6800, inf),
			\dur, Pwhite(0.015, 0.05, inf),
			\pan, Pwhite(-0.85, 0.85, inf),
			\amp, Pwhite(0.06, 0.16, inf)
		).play;

		// First resonant taps upon petrified mineral curtains
		Pbindef(\pillarResonance,
			\instrument, \limestonePillar,
			\out, ~synthBus,
			\dur, Pseq([3.4, 2.8, 4.2], inf),
			\freq, Pseq([116.54, 155.56, 174.61], inf), // Bb2, Eb3, F3
			\damp, 3.2,
			\brightness, 0.4,
			\pan, Pseq([-0.45, 0.5, -0.1], inf),
			\amp, 0.26
		).play;

		4.do { |i|
			Ndef(\masterMix).set(\wet10, 0.45 + (i * 0.04));
			4.wait;
		};

		"0:28 - [Salão III & IV: O Sino e as Colunas Gêmeas - Ressonância Litofônica]".postln;
		// Rhythmic dripping syncopation accelerating as depth increases
		Pbindef(\caveDrips,
			\dur, Prand([0.38, 0.52, 0.29, 0.74, 1.1], inf),
			\freq, Pexprand(720, 2400, inf),
			\resFreq, Pseq([233.08, 293.66, 349.23, 440.0, 523.25], inf),
			\amp, Pwhite(0.25, 0.42, inf)
		);

		// Litophone resonance - Lund tapping ancient calcite structures
		Pbindef(\pillarResonance,
			\dur, Pseq([1.6, 1.2, 0.8, 2.0, 1.4], inf),
			\freq, Pseq([87.31, 116.54, 130.81, 155.56, 174.61, 233.08], inf), // F1, Bb1, C2, Eb2, F2, Bb2
			\damp, 4.0,
			\brightness, 0.75,
			\pan, Pwhite(-0.7, 0.7, inf),
			\amp, 0.32
		);

		Ndef(\maquineChamber).xset(\amp, 0.42, \vaultFilter, 420);

		4.do { |idx|
			Pbindef(\microSeep, \amp, 0.12 + (idx * 0.03));
			3.wait;
		};

		"0:40 - [Salão V: O Trono do Elefante - Agrupamento Mineral e Saturação Acústica]".postln;
		// Kinetic Acceleration & Intrinsic Limit: Drops and seepage multiply near downpour intensity
		Pbindef(\caveDrips,
			\dur, Prand([0.08, 0.12, 0.15, 0.06, 0.24], inf),
			\freq, Pexprand(600, 3200, inf),
			\amp, Pwhite(0.18, 0.34, inf)
		);

		Pbindef(\microSeep,
			\dur, Pseq([0.04, 0.06, 0.05, 0.08], inf),
			\amp, 0.22
		);

		Ndef(\masterMix).set(\wet10, 0.68);

		3.do { |i|
			Ndef(\maquineChamber).xset(\vaultFilter, 420 + (i * 90), \airDrift, 0.12);
			4.wait;
		};

		"0:52 - [Salão VI: O Cemitério dos Fósseis da Megafauna]".postln;
		// Settling Archetype: The downpour suddenly halts; deep silence and skeletal sub-bass modes
		Pbindef(\caveDrips).stop;
		Pbindef(\microSeep).stop;

		// Deep tectonic and resonant low-mode stone vibrations
		Pbindef(\deepVault,
			\instrument, \limestonePillar,
			\out, ~synthBus,
			\dur, Pseq([4.5, 5.0, 3.8], inf),
			\freq, Pseq([58.27, 43.65, 51.91], inf), // Bb0, F0, Ab0
			\damp, 5.5,
			\brightness, 0.2,
			\pan, 0,
			\amp, 0.42
		).play;

		// Lone drop echoing in profound subterranean abyss
		Pbindef(\loneEchoDrop,
			\instrument, \calciteDrop,
			\out, ~synthBus,
			\dur, Pseq([3.8, 4.6, 5.2], inf),
			\freq, 1420,
			\resFreq, 233.08,
			\decay, 3.8,
			\pan, 0.2,
			\amp, 0.35
		).play;

		Ndef(\maquineChamber).fadeTime = 4;
		Ndef(\maquineChamber).xset(\amp, 0.5, \vaultFilter, 110, \airDrift, 0.03);
		Ndef(\masterMix).set(\wet10, 0.75);

		4.do { |i|
			Ndef(\maquineChamber).xset(\vaultFilter, 110 + (i * 15));
			3.wait;
		};

		"1:04 - [Salão VII: O Salão das Fadas e Resolução]".postln;
		// Resolution: Serene return of delicate crystalline drops, harmonic resolution in Bb minor
		Pbindef(\loneEchoDrop).stop;
		Pbindef(\deepVault).stop;

		Pbindef(\caveDrips,
			\dur, Pseq([1.6, 2.0, 1.2, 2.8, 1.9], inf),
			\freq, Pseq([1174.66, 1396.91, 1046.50, 1567.98], inf), // D6, F6, C6, G6
			\resFreq, Pseq([466.16, 587.33, 698.46, 932.33], inf), // Bb4, D5, F5, Bb5
			\decay, 2.5,
			\pan, Pseq([-0.6, 0.6, -0.3, 0.3], inf),
			\amp, 0.28
		).play;

		Pbindef(\fadasPillars,
			\instrument, \limestonePillar,
			\out, ~synthBus,
			\dur, 3.5,
			\freq, Pseq([233.08, 174.61, 293.66, 233.08], inf),
			\damp, 4.2,
			\brightness, 0.55,
			\pan, 0,
			\amp, 0.22
		).play;

		4.do { |i|
			Ndef(\masterMix).set(\wet10, 0.70 - (i * 0.04));
			Ndef(\maquineChamber).xset(\amp, (0.45 - (i * 0.06)).max(0.08));
			3.wait;
		};

		"1:16 - [Extinção do archote: Retorno ao silêncio geológico milenar]".postln;
		// Extrinsic Limit: Slow absorption of sound into limestone pores
		Pbindef(\fadasPillars).stop;

		4.do { |i|
			Pbindef(\caveDrips, \amp, (0.24 - (i * 0.055)).max(0.02));
			Ndef(\maquineChamber).xset(\amp, (0.2 - (i * 0.045)).max(0.005));
			2.5.wait;
		};

		Pbindef(\caveDrips).stop;
		Ndef(\maquineChamber).fadeTime = 3;
		Ndef(\maquineChamber).xset(\amp, 0);
		3.5.wait;

		// Scoped Termination
		Pbindef(\caveDrips).clear;
		Pbindef(\microSeep).clear;
		Pbindef(\pillarResonance).clear;
		Pbindef(\deepVault).clear;
		Pbindef(\loneEchoDrop).clear;
		Pbindef(\fadasPillars).clear;
		Ndef(\maquineChamber).clear(2);
		Ndef(\masterMix).clear(2);

		"Score Complete.".postln;
		Tdef(\masterScore).stop;
	});

	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// STEP 0: MIDI CC MAPPINGS
~cc = (
    // Zone 1: Sub/Tectonic Modular Bass
    vol1: 1, pan1: 2, mute1: 3, hpf1: 4, lpf1: 5, rq1: 6,
    atk1: 7, dec1: 8, sus1: 9, rls1: 10, fxFold1: 11,
    // Zone 2: Lissajous Harmonic Beam (Cross-mod Dual Core)
    vol2: 12, pan2: 13, mute2: 14, hpf2: 15, lpf2: 16, rq2: 17,
    atk2: 18, dec2: 19, sus2: 20, rls2: 21, fxPhosphor2: 22,
    // Zone 3: Silver Patchcord Matrix (Metallic Resonant Impulse)
    vol3: 23, pan3: 24, mute3: 25, hpf3: 26, lpf3: 27, rq3: 28,
    atk3: 29, dec3: 30, sus3: 31, rls3: 32, fxMatrix3: 33,
    // Master FX & Panic
    delMix: 34, delTime: 35, delFeedback: 36,
    verbMix: 37, verbTime: 38, verbDamp: 39,
    panic: 123
);

// STEP 1 & 2: MIDI DISCOVERY WITH HARDWARE FALLBACK
MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    // Safely connect MIDI endpoint (catch primitive connection errors)
    try {
        MIDIIn.connect(0, ~myInDevice);
        ("MIDI IN connected: " ++ ~myInDevice.device ++ " - " ++ ~myInDevice.name).postln;
        ~myUid = ~myInDevice.uid;
    } { |err|
        ("MIDI connection failed, falling back to GUI mode: " ++ err.errorString).warn;
        ~myUid = nil;
    };
} {
    "No MIDI controller connected. Running GUI only mode.".warn;
    ~myUid = nil;
};

// STEP 3: SERVER SETUP & SYNTHESIS ARCHITECTURE
s.waitForBoot({
    var winW = 860, winH = 680, screen, tabW, tabH, tabY = 110;
    var zoneTitles = ["Z1: Modular Core (Sub)", "Z2: Lissajous Beam", "Z3: Silver Matrix Pin"];
    var currentTab = 0;

    // Default Control Bus Parameter Values
    ~ccVals = (
        // Zone 1
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 24, max1: 65,
        hpf1: 25.0, lpf1: 750.0, rq1: 0.45, atk1: 0.01, dec1: 0.25, sus1: 0.85, rls1: 0.4, fxFold1: 0.0,
        // Zone 2
        vol2: 0.24, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 96,
        hpf2: 90.0, lpf2: 4500.0, rq2: 0.35, atk2: 0.02, dec2: 0.3, sus2: 0.7, rls2: 0.6, fxPhosphor2: 0.0,
        // Zone 3
        vol3: 0.22, pan3: 0.35, mute3: 0.0, min3: 40, max3: 110,
        hpf3: 200.0, lpf3: 8200.0, rq3: 0.25, atk3: 0.005, dec3: 0.45, sus3: 0.2, rls3: 0.5, fxMatrix3: 0.0,
        // FX & Master
        delMix: 0.0, delTime: 0.28, delFeedback: 0.45,
        verbMix: 0.0, verbTime: 2.2, verbDamp: 0.5
    );

    // 2-Line Control Bus Allocation
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Audio Routing Buses
    ~fxBus = Bus.audio(s, 2);

    // Node Tree Ordering
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Voice Tracking Arrays
    ~notes1 = Array.newClear(128);
    ~notes2 = Array.newClear(128);
    ~notes3 = Array.newClear(128);

    // ===================================
    // SYNTHDEFS
    // ===================================

    // Zone 1: Sub/Tectonic Modular Bass (Moog Ladder emulation + Buchla style wavefolding)
    SynthDef(\zone1SubModular, {
        |out=0, freq=55, gate=1, vel=0.8,
         vol=0.28, pan=0.0, mute=0.0, hpf=25, lpf=750, rq=0.45,
         atk=0.01, dec=0.25, sus=0.85, rls=0.4, fxFold=0.0|
        var env, sig, fEnv, folded;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -4), gate, doneAction: 2);
        fEnv = EnvGen.ar(Env.perc(atk, dec * 1.5), gate) * 200;
        sig = Pulse.ar(freq * [0.998, 1.002], 0.45) * 0.5 + Saw.ar(freq * 0.5, 0.5);
        sig = sig.sum;
        // Analog Wavefolding
        folded = Fold.ar(sig * (1.0 + (fxFold * 8.0)), -0.7, 0.7) * (1.0 / (1.0 + (fxFold * 2.0)));
        sig = XFade2.ar(sig, folded, (fxFold * 2.0) - 1.0);
        sig = MoogFF.ar(sig, (lpf + fEnv).clip(20, 18000), 3.2 * (1.0 - rq.clip(0.05, 1.0)));
        sig = HPF.ar(sig, hpf.clip(10, 1000));
        sig = sig * env * (vel * 1.2) * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Lissajous Harmonic Beam (Dual-core cross-modulated quadrature sine/saw)
    SynthDef(\zone2Lissajous, {
        |out=0, freq=220, gate=1, vel=0.8,
         vol=0.24, pan=(-0.35), mute=0.0, hpf=90, lpf=4500, rq=0.35,
         atk=0.02, dec=0.3, sus=0.7, rls=0.6, fxPhosphor=0.0|
        var env, sigX, sigY, modWarp, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -3), gate, doneAction: 2);
        // Orthogonal Oscillators representing Oscilloscope X-Y phase trace
        modWarp = SinOsc.ar(freq * (1.001 + (fxPhosphor * 0.5))) * (freq * fxPhosphor * 2.5);
        sigX = SinOsc.ar(freq + modWarp) + (VarSaw.ar(freq * 0.999, 0, 0.3) * 0.4);
        sigY = SinOsc.ar((freq * 1.503) + (modWarp * 0.5)) + (VarSaw.ar(freq * 2.002, 0, 0.7) * 0.3);
        sig = [sigX, sigY];
        sig = RLPF.ar(sig, lpf.clip(40, 19000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(10, 2000));
        sig = (sig * (1.0 + (fxPhosphor * 2.0))).tanh;
        sig = sig * env * (vel * 1.1) * vol * (1.0 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    // Zone 3: Silver Patchcord Matrix Pin (Resonant Comb Ring / Metallic Impulse)
    SynthDef(\zone3MatrixPin, {
        |out=0, freq=440, gate=1, vel=0.8,
         vol=0.22, pan=0.35, mute=0.0, hpf=200, lpf=8200, rq=0.25,
         atk=0.005, dec=0.45, sus=0.2, rls=0.5, fxMatrix=0.0|
        var env, exciter, sig, combTime;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -4), gate, doneAction: 2);
        combTime = freq.reciprocal.clip(0.0005, 0.05);
        exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02), gate);
        sig = CombL.ar(exciter, 0.05, combTime, 1.2 + (fxMatrix * 3.0));
        // Matrix Cross-resonance via Allpass diffusion
        sig = AllpassC.ar(sig, 0.02, (fxMatrix * 0.008) + 0.0004, 0.25);
        sig = BPF.ar(sig, freq * [1.0, 2.76, 5.4], rq.clip(0.05, 1.0)).sum;
        sig = LPF.ar(sig, lpf.clip(100, 19000));
        sig = HPF.ar(sig, hpf.clip(20, 2000));
        sig = sig * env * vel * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Master Space & Stereo FX Bus Processor
    SynthDef(\masterFXProcessor, {
        |inBus=0, outBus=0,
         delMix=0.0, delTime=0.28, delFeedback=0.45,
         verbMix=0.0, verbTime=2.2, verbDamp=0.5|
        var dry, wetDel, wetRev, sig;
        dry = In.ar(inBus, 2);
        // Vintage BBD/Tape Style Ping-Pong Delay
        wetDel = [
            CombL.ar(dry[0] + (dry[1] * 0.2), 1.2, delTime.clip(0.02, 1.0), delFeedback.linlin(0, 1, 0.1, 4.5)),
            CombL.ar(dry[1] + (dry[0] * 0.2), 1.2, (delTime * 1.33).clip(0.02, 1.0), delFeedback.linlin(0, 1, 0.1, 4.5))
        ];
        wetDel = LPF.ar(wetDel, 5000);
        sig = XFade2.ar(dry, wetDel, (delMix.clip(0.0, 1.0) * 2.0) - 1.0);
        // Dense Algorithmic Chamber Reverb
        wetRev = FreeVerb2.ar(sig[0], sig[1], 1.0, verbTime.linlin(0.2, 8.0, 0.4, 0.95), verbDamp.clip(0.0, 1.0));
        sig = XFade2.ar(sig, wetRev, (verbMix.clip(0.0, 1.0) * 2.0) - 1.0);
        Out.ar(outBus, sig);
    }).add;

    // Output Stage Safety Limiter
    SynthDef(\safetyLimiter, {
        |inBus=0, out=0|
        var sig = In.ar(inBus, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    // Sync SynthDefs before creating persistent FX nodes
    s.sync;

    // Instantiate Master Processing Nodes
    ~fxSynth = Synth.tail(~fxGroup, \masterFXProcessor, [
        \inBus, ~fxBus,
        \outBus, 0,
        \delMix, ~buses.delMix.asMap,
        \delTime, ~buses.delTime.asMap,
        \delFeedback, ~buses.delFeedback.asMap,
        \verbMix, ~buses.verbMix.asMap,
        \verbTime, ~buses.verbTime.asMap,
        \verbDamp, ~buses.verbDamp.asMap
    ]);

    ~limiterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\inBus, 0, \out, 0]);

    // ===================================
    // MIDI EVENT HANDLERS
    // ===================================

    // Note On
    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        var velNorm = vel / 127.0;

        // Zone 1
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes1[noteNum] = ~notes1[noteNum].add(
                Synth.head(~synthGroup, \zone1SubModular, [
                    \out, ~fxBus, \freq, noteNum.midicps, \vel, velNorm,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxFold, ~buses.fxFold1.asMap
                ])
            );
        };

        // Zone 2
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes2[noteNum] = ~notes2[noteNum].add(
                Synth.head(~synthGroup, \zone2Lissajous, [
                    \out, ~fxBus, \freq, noteNum.midicps, \vel, velNorm,
                    \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                    \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                    \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                    \fxPhosphor, ~buses.fxPhosphor2.asMap
                ])
            );
        };

        // Zone 3
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes3[noteNum] = ~notes3[noteNum].add(
                Synth.head(~synthGroup, \zone3MatrixPin, [
                    \out, ~fxBus, \freq, noteNum.midicps, \vel, velNorm,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                    \fxMatrix, ~buses.fxMatrix3.asMap
                ])
            );
        };
    }, srcID: ~myUid);

    // Note Off
    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        ~notes1[noteNum].do(_.set(\gate, 0));
        ~notes1[noteNum] = nil;
        ~notes2[noteNum].do(_.set(\gate, 0));
        ~notes2[noteNum] = nil;
        ~notes3[noteNum].do(_.set(\gate, 0));
        ~notes3[noteNum] = nil;
    }, srcID: ~myUid);

    // Dynamic MIDI CC Mapping Dispatcher
    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("verbTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // Panic CC Handler
    MIDIdef.cc(\panicCC, { |val, num|
        if(num == ~cc[\panic]) {
            128.do { |i|
                ~notes1[i].do(_.free); ~notes1[i] = nil;
                ~notes2[i].do(_.free); ~notes2[i] = nil;
                ~notes3[i].do(_.free); ~notes3[i] = nil;
            };
            "All active notes silenced.".postln;
        };
    }, srcID: ~myUid);

    // ===================================
    // PAGINATED GUI (STUDIO DARK THEME)
    // ===================================
    defer {
        var screen = Window.availableBounds;
        var pages, tabBtns;
        var zoneMeta = [
            (idx: 1, title: "Zone 1: Modular Sub Core", fxKey: \fxFold1, fxLabel: "WaveFold"),
            (idx: 2, title: "Zone 2: Lissajous Harmonic Beam", fxKey: \fxPhosphor2, fxLabel: "PhaseWarp"),
            (idx: 3, title: "Zone 3: Silver Pin Matrix Resonator", fxKey: \fxMatrix3, fxLabel: "PinDispersion")
        ];

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        winH = min(680, screen.height - 60);
        ~mainWin = Window("LISSAJOUS HARMONICS // MODULAR CONSOLE", Rect(
            (screen.width - winW) * 0.5,
            (screen.height - winH) * 0.5,
            winW, winH
        ), resizable: false, scroll: false);

        ~mainWin.view.background = Color(0.08, 0.09, 0.11);
        ~ui = ();

        // Header Title / Status Bar
        StaticText(~mainWin, Rect(20, 12, 500, 32))
            .string_("LISSAJOUS OSCILLOSCOPE MODULAR MATRIX")
            .font_(Font("Monaco", 16, true))
            .stringColor_(Color(0.25, 0.95, 0.45));

        StaticText(~mainWin, Rect(20, 42, 600, 20))
            .string_("Discrete Analog Oscillators • Dual-Beam Beam Cross-Modulation • Silver Contact Resonators")
            .font_(Font("Monaco", 9))
            .stringColor_(Color(0.65, 0.75, 0.7));

        // Tab Navigation Buttons
        tabBtns = Array.newClear(3);
        pages = Array.newClear(3);
        tabW = winW - 40;
        tabH = winH - 240;

        zoneTitles.do { |tName, i|
            tabBtns[i] = Button(~mainWin, Rect(20 + (i * 270), 72, 260, 30))
                .states_([
                    [tName, Color(0.8, 0.85, 0.85), Color(0.14, 0.16, 0.19)],
                    [tName, Color(0.05, 0.1, 0.05), Color(0.3, 0.85, 0.5)]
                ])
                .font_(Font("Monaco", 10, true))
                .value_(if(i == 0, 1, 0))
                .action_({
                    pages.do { |pg, pIdx| pg.visible = (pIdx == i) };
                    tabBtns.do { |btn, bIdx| btn.value = if(bIdx == i, 1, 0) };
                });
        };

        // Build Pages via Loop
        zoneMeta.do { |zm, i|
            var zIdx = zm.idx;
            var page = CompositeView(~mainWin, Rect(20, tabY, tabW, tabH));
            page.background = Color(0.12, 0.13, 0.16);
            page.visible = (i == 0);
            pages[i] = page;

            // Header Banner in page
            StaticText(page, Rect(15, 12, 400, 22))
                .string_(zm.title.toUpper)
                .font_(Font("Monaco", 12, true))
                .stringColor_(Color(0.3, 0.9, 0.55));

            // Zone Range
            StaticText(page, Rect(15, 42, 100, 18)).string_("Key Range:").font_(Font("Monaco", 9)).stringColor_(Color.white);
            ~ui[("min" ++ zIdx).asSymbol] = EZSlider(page, Rect(120, 42, 300, 20), "Min Note", ControlSpec(0, 127, \lin, 1, ~ccVals[("min" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("min" ++ zIdx).asSymbol] = sl.value.asInteger;
            }, labelWidth: 60, numberWidth: 35)
            .setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.5, 0.35));

            ~ui[("max" ++ zIdx).asSymbol] = EZSlider(page, Rect(430, 42, 300, 20), "Max Note", ControlSpec(0, 127, \lin, 1, ~ccVals[("max" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("max" ++ zIdx).asSymbol] = sl.value.asInteger;
            }, labelWidth: 60, numberWidth: 35)
            .setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.5, 0.35));

            // Knobs Row 1: Mix & Filters
            ~ui[("vol" ++ zIdx).asSymbol] = EZKnob(page, Rect(25, 75, 80, 95), "Vol [CC" ++ ~cc[("vol" ++ zIdx).asSymbol] ++ "]", ControlSpec(0, 1, \lin, 0.01, ~ccVals[("vol" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("vol" ++ zIdx).asSymbol] = kb.value;
                ~buses[("vol" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.75, 0.78, 0.82));

            ~ui[("pan" ++ zIdx).asSymbol] = EZKnob(page, Rect(120, 75, 80, 95), "Pan [CC" ++ ~cc[("pan" ++ zIdx).asSymbol] ++ "]", ControlSpec(-1.0, 1.0, \lin, 0.01, ~ccVals[("pan" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("pan" ++ zIdx).asSymbol] = kb.value;
                ~buses[("pan" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.75, 0.78, 0.82));

            ~ui[("hpf" ++ zIdx).asSymbol] = EZKnob(page, Rect(215, 75, 80, 95), "HPF [CC" ++ ~cc[("hpf" ++ zIdx).asSymbol] ++ "]", ControlSpec(20, 18000, \exp, 1, ~ccVals[("hpf" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("hpf" ++ zIdx).asSymbol] = kb.value;
                ~buses[("hpf" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.3, 0.75, 0.6));

            ~ui[("lpf" ++ zIdx).asSymbol] = EZKnob(page, Rect(310, 75, 80, 95), "LPF [CC" ++ ~cc[("lpf" ++ zIdx).asSymbol] ++ "]", ControlSpec(20, 18000, \exp, 1, ~ccVals[("lpf" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("lpf" ++ zIdx).asSymbol] = kb.value;
                ~buses[("lpf" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.3, 0.75, 0.6));

            ~ui[("rq" ++ zIdx).asSymbol] = EZKnob(page, Rect(405, 75, 80, 95), "Res [CC" ++ ~cc[("rq" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.05, 1.0, \exp, 0.01, ~ccVals[("rq" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("rq" ++ zIdx).asSymbol] = kb.value;
                ~buses[("rq" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.3, 0.75, 0.6));

            // Unique Character FX
            ~ui[zm.fxKey] = EZKnob(page, Rect(510, 75, 95, 95), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, 0.0), { |kb|
                ~ccVals[zm.fxKey] = kb.value;
                ~buses[zm.fxKey].set(kb.value);
            }).setColors(stringColor: Color(0.35, 1.0, 0.5), knobColor: Color(0.2, 0.85, 0.45));

            // Mute Button
            Button(page, Rect(630, 100, 80, 45))
                .states_([
                    ["ACTIVE", Color.white, Color(0.18, 0.28, 0.2)],
                    ["MUTED", Color.white, Color(0.65, 0.18, 0.18)]
                ])
                .font_(Font("Monaco", 10, true))
                .action_({ |btn|
                    var mVal = btn.value.asFloat;
                    ~ccVals[("mute" ++ zIdx).asSymbol] = mVal;
                    ~buses[("mute" ++ zIdx).asSymbol].set(mVal);
                });

            // Knobs Row 2: Envelopes ADSR
            ~ui[("atk" ++ zIdx).asSymbol] = EZKnob(page, Rect(25, 185, 80, 95), "Atk [CC" ++ ~cc[("atk" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.005, 5.0, \exp, 0.001, ~ccVals[("atk" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("atk" ++ zIdx).asSymbol] = kb.value;
                ~buses[("atk" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("dec" ++ zIdx).asSymbol] = EZKnob(page, Rect(120, 185, 80, 95), "Dec [CC" ++ ~cc[("dec" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.01, 5.0, \exp, 0.01, ~ccVals[("dec" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("dec" ++ zIdx).asSymbol] = kb.value;
                ~buses[("dec" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("sus" ++ zIdx).asSymbol] = EZKnob(page, Rect(215, 185, 80, 95), "Sus [CC" ++ ~cc[("sus" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, ~ccVals[("sus" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("sus" ++ zIdx).asSymbol] = kb.value;
                ~buses[("sus" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("rls" ++ zIdx).asSymbol] = EZKnob(page, Rect(310, 185, 80, 95), "Rls [CC" ++ ~cc[("rls" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.01, 8.0, \exp, 0.01, ~ccVals[("rls" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("rls" ++ zIdx).asSymbol] = kb.value;
                ~buses[("rls" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));
        };

        // Static Bottom Console: Space FX & Panic
        StaticText(~mainWin, Rect(20, winH - 120, 300, 18))
            .string_("SPACE TIME ECHO & REVERB CHASSIS")
            .font_(Font("Monaco", 10, true))
            .stringColor_(Color(0.4, 0.85, 0.6));

        ~ui[\delMix] = EZSlider(~mainWin, Rect(20, winH - 95, 230, 20), "Del Wet", ControlSpec(0.0, 1.0, \lin, 0.01, 0.0), { |sl|
            ~ccVals[\delMix] = sl.value;
            ~buses[\delMix].set(sl.value);
        }, labelWidth: 55, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.6, 0.5));

        ~ui[\delTime] = EZSlider(~mainWin, Rect(20, winH - 70, 230, 20), "Del Time", ControlSpec(0.02, 1.0, \exp, 0.01, 0.28), { |sl|
            ~ccVals[\delTime] = sl.value;
            ~buses[\delTime].set(sl.value);
        }, labelWidth: 55, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.6, 0.5));

        ~ui[\verbMix] = EZSlider(~mainWin, Rect(280, winH - 95, 230, 20), "Verb Wet", ControlSpec(0.0, 1.0, \lin, 0.01, 0.0), { |sl|
            ~ccVals[\verbMix] = sl.value;
            ~buses[\verbMix].set(sl.value);
        }, labelWidth: 55, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.25, 0.45, 0.7));

        ~ui[\verbTime] = EZSlider(~mainWin, Rect(280, winH - 70, 230, 20), "Verb Dec", ControlSpec(0.2, 8.0, \exp, 0.05, 2.2), { |sl|
            ~ccVals[\verbTime] = sl.value;
            ~buses[\verbTime].set(sl.value);
        }, labelWidth: 55, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.25, 0.45, 0.7));

        // Panic Button
        Button(~mainWin, Rect(winW - 190, winH - 95, 170, 48))
            .states_([["PANIC // SILENCE", Color.white, Color(0.65, 0.15, 0.15)]])
            .font_(Font("Monaco", 11, true))
            .action_({
                128.do { |n|
                    ~notes1[n].do(_.free); ~notes1[n] = nil;
                    ~notes2[n].do(_.free); ~notes2[n] = nil;
                    ~notes3[n].do(_.free); ~notes3[n] = nil;
                };
                "Console voice matrix cleared.".postln;
            });

        ~mainWin.front;

        // 20 FPS Compact Poller
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
)


// ============================================================
// ROUND 06 | MODE: DESIGN | FRAG #86
// STATUS: FIXED
// PROMPT: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente e...
// ============================================================
(
// [Pre-Design Cleanup: freeing previous Design synthesizer resources]
{
    if(~guiRoutine.notNil) { try { ~guiRoutine.stop } {}; ~guiRoutine = nil };
    [~mainWin, ~surWin, ~win, ~guiWin, ~synthWin].do { |w|
        if(w.notNil) { try { w.close } {} };
    };
    ~mainWin = nil; ~surWin = nil; ~win = nil; ~guiWin = nil; ~synthWin = nil;
    try { Window.closeAll } {};
    try { MIDIdef.freeAll } {};
    if(~notes.notNil) {
        try {
            ~notes.do { |item|
                if(item.notNil) {
                    if(item.isKindOf(Collection)) {
                        item.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                    } {
                        try { item.free } {};
                    };
                };
            };
        } {};
        ~notes = nil;
    };
    if(~zoneNotes.notNil) {
        try {
            ~zoneNotes.do { |zone|
                if(zone.notNil) {
                    zone.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                };
            };
        } {};
        ~zoneNotes = nil;
    };
    ~activeCount = 0;
    [
        ~subSynth, ~monoSynth, ~leadSynth, ~droneSynth, ~synth,
        ~fxSynth, ~masterFx, ~celestialFx, ~ancientFx, ~reverbSynth, ~delaySynth,
        ~synthGroup, ~fxGroup, ~masterGroup, ~sourceGroup
    ].do { |node|
        if(node.notNil) { try { node.free } {} };
    };
    ~subSynth = nil; ~monoSynth = nil; ~leadSynth = nil; ~droneSynth = nil; ~synth = nil;
    ~fxSynth = nil; ~masterFx = nil; ~celestialFx = nil; ~ancientFx = nil; ~reverbSynth = nil; ~delaySynth = nil;
    ~synthGroup = nil; ~fxGroup = nil; ~masterGroup = nil; ~sourceGroup = nil;
    if(~buses.notNil) {
        try { ~buses.do { |b| if(b.notNil) { try { b.free } {} } } } {};
        ~buses = nil;
    };
    [~fxBus, ~celestialBus, ~ancientBus, ~reverbBus, ~delayBus].do { |b|
        if(b.notNil) { try { b.free } {} };
    };
    ~fxBus = nil; ~celestialBus = nil; ~ancientBus = nil; ~reverbBus = nil; ~delayBus = nil;
    try {
        if(Pbindef.all.notNil and: { Pbindef.all[\subtractiveDesignSeq].notNil }) {
            Pbindef(\subtractiveDesignSeq).stop;
            Pbindef(\subtractiveDesignSeq).clear;
        };
    } {};
    try {
        if(Ndef.dictFor(s).notNil and: { Ndef.dictFor(s)[\subtractiveDesign].notNil }) {
            Ndef(\subtractiveDesign).clear(0.1);
        };
    } {};
}.value;

// Step 0: MIDI CC Assignment Map
~cc = (
    vol1: 14, pan1: 15, mute1: 16, min1: 17, max1: 18, hpf1: 19, lpf1: 20, rq1: 21, atk1: 22, dec1: 23, sus1: 24, rls1: 25, fxBiriba: 26,
    vol2: 27, pan2: 28, mute2: 29, min2: 30, max2: 31, hpf2: 32, lpf2: 33, rq2: 34, atk2: 35, dec2: 36, sus2: 37, rls2: 38, fxDobrao: 39,
    vol3: 40, pan3: 41, mute3: 42, min3: 43, max3: 44, hpf3: 45, lpf3: 46, rq3: 47, atk3: 48, dec3: 49, sus3: 50, rls3: 51, fxCaxixi: 52,
    delMix: 85, delTime: 86, verbMix: 87, verbTime: 88, panic: 123
);

// Steps 1 & 2: MIDI Auto-Detection with Robust Fallback
try { MIDIClient.init };
if(MIDIClient.initialized.not) { try { MIDIClient.init } };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    try {
        MIDIIn.connect(0, ~myInDevice);
        ("Berimbau MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
        ~myUid = ~myInDevice.uid;
    } { |err|
        "Warning: Could not connect to MIDI device. Falling back to open MIDI matching.".warn;
        ~myUid = nil;
    };
} {
    "Warning: No MIDI input devices detected. GUI & virtual events available.".warn;
    ~myUid = nil;
};

// Step 3: Audio Server Boot & System Engine
s.waitForBoot({
    var winW, winH, scr, zoneMeta;

    // CC State Defaults
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 24, max1: 68, hpf1: 30, lpf1: 2800, rq1: 0.35, atk1: 0.002, dec1: 1.8, sus1: 0.15, rls1: 0.9, fxBiriba: 0.0,
        vol2: 0.24, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 84, hpf2: 120, lpf2: 6500, rq2: 0.25, atk2: 0.001, dec2: 1.2, sus2: 0.1, rls2: 0.6, fxDobrao: 0.0,
        vol3: 0.22, pan3: 0.35, mute3: 0.0, min3: 40, max3: 127, hpf3: 1200, lpf3: 14000, rq3: 0.5, atk3: 0.001, dec3: 0.22, sus3: 0.0, rls3: 0.18, fxCaxixi: 0.0,
        delMix: 0.0, delTime: 0.26, verbMix: 0.0, verbTime: 2.2
    );

    // Dynamic 2-Line Control Bus Allocation
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Group Topography
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Audio Routing Busses
    ~busFx = Bus.audio(s, 2);
    ~busMaster = Bus.audio(s, 2);

    // Note Tracking Arrays
    ~notes1 = Array.newClear(128);
    ~notes2 = Array.newClear(128);
    ~notes3 = Array.newClear(128);

    // SynthDef 1: Gunga Cabaca - Deep Wood & Resonant Wire
    SynthDef(\berimbauCabaca, {
        |out=0, freq=110, gate=1, vel=0.8, vol=0.28, pan=0.0, mute=0.0,
         hpf=30, lpf=2800, rq=0.35, atk=0.002, dec=1.8, sus=0.15, rls=0.9, fxBiriba=0.0|
        var env, strike, string, cabaca, body, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -4), gate, doneAction: 2);
        strike = (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.012))) + (Impulse.ar(0) * 1.5);
        string = CombL.ar(strike, 0.06, freq.reciprocal.clip(0.001, 0.06), dec * (1.0 + fxBiriba));
        cabaca = Resonz.ar(string, freq * [1.0, 1.98, 2.95], rq) * [1.0, 0.6, 0.35];
        cabaca = Mix(cabaca);
        body = (cabaca * (1.0 + (fxBiriba * 3.0))).tanh;
        sig = RLPF.ar(body, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 4000));
        sig = sig * env * vel * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // SynthDef 2: Dobrao Metalico - Coin Pressure & Harmonic Modulations
    SynthDef(\berimbauDobrao, {
        |out=0, freq=165, gate=1, vel=0.8, vol=0.24, pan=(-0.35), mute=0.0,
         hpf=120, lpf=6500, rq=0.25, atk=0.001, dec=1.2, sus=0.1, rls=0.6, fxDobrao=0.0|
        var env, coinExciter, pressedFreq, wire, metalRing, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -4), gate, doneAction: 2);
        pressedFreq = freq * (1.0 + (fxDobrao * 0.12));
        coinExciter = Dust2.ar(2200) * EnvGen.ar(Env.perc(0.001, 0.035)) + (Impulse.ar(0) * 0.8);
        wire = CombL.ar(coinExciter, 0.04, pressedFreq.reciprocal.clip(0.0008, 0.04), dec);
        metalRing = DynKlank.ar(
            `[[pressedFreq * 1.0, pressedFreq * 2.72, pressedFreq * 4.14, pressedFreq * 6.2],
              [0.8, 0.5, 0.35, 0.2],
              [dec * 0.8, dec * 0.5, dec * 0.3, dec * 0.2]],
            wire
        );
        sig = (metalRing * 0.25) + (wire * 0.75);
        sig = Fold.ar(sig * (1.0 + (fxDobrao * 2.5)), -0.85, 0.85);
        sig = RLPF.ar(sig, lpf.clip(60, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 6000));
        sig = sig * env * vel * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // SynthDef 3: Caxixi Rattle - Dried Seeds & Woven Basket Matrix
    SynthDef(\berimbauCaxixi, {
        |out=0, freq=440, gate=1, vel=0.8, vol=0.22, pan=0.35, mute=0.0,
         hpf=1200, lpf=14000, rq=0.5, atk=0.001, dec=0.22, sus=0.0, rls=0.18, fxCaxixi=0.0|
        var env, seedPulse, rattle, basket, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls, 1, -6), gate, doneAction: 2);
        seedPulse = Dust.ar((1800 + (fxCaxixi * 4000)).clip(400, 10000)) * EnvGen.ar(Env.perc(0.001, dec));
        rattle = BPF.ar(seedPulse, [2800, 4200, 6800, 9500], [0.3, 0.25, 0.2, 0.15]).sum;
        basket = Ringz.ar(seedPulse * 0.15, [1850, 3100], 0.025).sum;
        sig = (rattle * 1.8) + (basket * 0.7);
        sig = HPF.ar(sig, hpf.clip(200, 8000));
        sig = LPF.ar(sig, lpf.clip(800, 18000));
        sig = sig * env * vel * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Space & Atmosphere Delay/Reverb Chassis
    SynthDef(\berimbauSpaceFx, {
        |inBus, outBus, delMix=0.0, delTime=0.26, verbMix=0.0, verbTime=2.2|
        var in, delSig, verbSig, wet;
        in = In.ar(inBus, 2);
        delSig = CombC.ar(in, 1.2, delTime.clip(0.02, 1.0), delTime * 3.5);
        verbSig = GVerb.ar(in[0] + in[1], 48, verbTime.clip(0.2, 8.0), 0.45, 0.5, 15, -3.dbamp, -11.dbamp, -13.dbamp);
        wet = (in * (1.0 - delMix)) + (delSig * delMix);
        wet = (wet * (1.0 - verbMix)) + (verbSig * verbMix);
        Out.ar(outBus, wet);
    }).add;

    // Master Output & Safety Limiter
    SynthDef(\berimbauMasterLimiter, {
        |inBus=0, out=0|
        var sig;
        sig = In.ar(inBus, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    // CRITICAL: Synchronize Server Before Adding Instantiations
    s.sync;

    // Instantiate Master & FX Synths
    ~fxSynth = Synth.tail(~fxGroup, \berimbauSpaceFx, [
        \inBus, ~busFx, \outBus, ~busMaster,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap,
        \verbMix, ~buses[\verbMix].asMap, \verbTime, ~buses[\verbTime].asMap
    ]);

    ~masterSynth = Synth.tail(~masterGroup, \berimbauMasterLimiter, [
        \inBus, ~busMaster, \out, 0
    ]);

    // Fast Loop-Driven MIDI CC Handler
    MIDIdef.cc(\berimbauCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.001, 6.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") or: { ks.contains("verbTime") } } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // NoteOn Dispatcher with Dynamic Overlapping Ranges
    MIDIdef.noteOn(\berimbauOn, { |vel, noteNum|
        var vNorm = vel / 127.0;
        var f = noteNum.midicps;

        // Zone 1: Gunga
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~notes1[noteNum] = ~notes1[noteNum].add(
                Synth.head(~synthGroup, \berimbauCabaca, [
                    \out, ~busFx, \freq, f, \vel, vNorm,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap, \rls, ~buses[\rls1].asMap,
                    \fxBiriba, ~buses[\fxBiriba].asMap
                ])
            );
        };

        // Zone 2: Dobrao
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~notes2[noteNum] = ~notes2[noteNum].add(
                Synth.head(~synthGroup, \berimbauDobrao, [
                    \out, ~busFx, \freq, f, \vel, vNorm,
                    \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap, \rls, ~buses[\rls2].asMap,
                    \fxDobrao, ~buses[\fxDobrao].asMap
                ])
            );
        };

        // Zone 3: Caxixi
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~notes3[noteNum] = ~notes3[noteNum].add(
                Synth.head(~synthGroup, \berimbauCaxixi, [
                    \out, ~busFx, \freq, f, \vel, vNorm,
                    \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap, \rls, ~buses[\rls3].asMap,
                    \fxCaxixi, ~buses[\fxCaxixi].asMap
                ])
            );
        };
    }, srcID: ~myUid);

    // NoteOff Dispatcher
    MIDIdef.noteOff(\berimbauOff, { |vel, noteNum|
        ~notes1[noteNum].do(_.set(\gate, 0)); ~notes1[noteNum] = nil;
        ~notes2[noteNum].do(_.set(\gate, 0)); ~notes2[noteNum] = nil;
        ~notes3[noteNum].do(_.set(\gate, 0)); ~notes3[noteNum] = nil;
    }, srcID: ~myUid);

    // Panic CC Handler
    MIDIdef.cc(\berimbauPanic, { |val|
        if(val > 0) {
            128.do { |i|
                ~notes1[i].do(_.free); ~notes1[i] = nil;
                ~notes2[i].do(_.free); ~notes2[i] = nil;
                ~notes3[i].do(_.free); ~notes3[i] = nil;
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // UI Construction in Defer Block
    defer {
        scr = Window.availableBounds;
        winW = 680;
        winH = min(680, scr.height - 60);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("O BERIMBAU DE BARRIGA // CAPOEIRA SYNTHESIS CHASSIS", Rect((scr.width - winW) / 2, (scr.height - winH) / 2, winW, winH), scroll: true);
        ~mainWin.view.background = Color(0.1, 0.11, 0.12);

        ~ui = ();
        ~pages = Array.newClear(3);
        ~tabButtons = Array.newClear(3);

        zoneMeta = [
            (title: "GUNGA // CABACA & WOOD", fxKey: \fxBiriba, fxLabel: "Biriba Body Sat"),
            (title: "MEDIO // DOBRAO METALICO", fxKey: \fxDobrao, fxLabel: "Coin Pressure"),
            (title: "VIOLA // CAXIXI SEEDS", fxKey: \fxCaxixi, fxLabel: "Woven Seed Grit")
        ];

        // Header Title Banner
        StaticText(~mainWin, Rect(20, 12, winW - 40, 24))
            .string_("O BERIMBAU DE BARRIGA // ACOUSTIC PHYLOGENY ENGINE")
            .font_(Font("Monaco", 14, true))
            .stringColor_(Color(0.95, 0.78, 0.35));

        // Tab Selector Bar
        zoneMeta.do { |zm, i|
            ~tabButtons[i] = Button(~mainWin, Rect(20 + (i * 215), 44, 210, 32))
                .states_([[zm.title, Color.white, if(i == 0, Color(0.28, 0.42, 0.28), Color(0.18, 0.2, 0.22))]])
                .font_(Font("Monaco", 10, true))
                .action_({
                    3.do { |pIdx|
                        ~pages[pIdx].visible = (pIdx == i);
                        ~tabButtons[pIdx].states = [[zoneMeta[pIdx].title, Color.white, if(pIdx == i, Color(0.28, 0.42, 0.28), Color(0.18, 0.2, 0.22))]];
                    };
                });
        };

        // DRY Loop-Driven Zone Page Construction
        zoneMeta.do { |zm, idx|
            var zIdx = idx + 1;
            var page = CompositeView(~mainWin, Rect(20, 84, winW - 40, 420));
            page.background = Color(0.14, 0.15, 0.17);
            page.visible = (idx == 0);
            ~pages[idx] = page;

            // Zone Primary Controls
            ~ui[("vol" ++ zIdx).asSymbol] = EZSlider(page, Rect(15, 12, 300, 22), "Vol [CC" ++ ~cc[("vol" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, ~ccVals[("vol" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("vol" ++ zIdx).asSymbol] = sl.value;
                ~buses[("vol" ++ zIdx).asSymbol].set(sl.value);
            }, labelWidth: 80, numberWidth: 42).setColors(stringColor: Color.white, sliderColor: Color(0.82, 0.65, 0.28));

            ~ui[("pan" ++ zIdx).asSymbol] = EZSlider(page, Rect(15, 38, 300, 22), "Pan [CC" ++ ~cc[("pan" ++ zIdx).asSymbol] ++ "]", ControlSpec(-1.0, 1.0, \lin, 0.01, ~ccVals[("pan" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("pan" ++ zIdx).asSymbol] = sl.value;
                ~buses[("pan" ++ zIdx).asSymbol].set(sl.value);
            }, labelWidth: 80, numberWidth: 42).setColors(stringColor: Color.white, sliderColor: Color(0.4, 0.6, 0.7));

            ~ui[("mute" ++ zIdx).asSymbol] = Button(page, Rect(330, 12, 120, 48))
                .states_([["MUTE OFF", Color.white, Color(0.2, 0.35, 0.2)], ["MUTED", Color.white, Color(0.7, 0.2, 0.2)]])
                .font_(Font("Monaco", 10, true))
                .action_({ |btn|
                    var v = btn.value.asFloat;
                    ~ccVals[("mute" ++ zIdx).asSymbol] = v;
                    ~buses[("mute" ++ zIdx).asSymbol].set(v);
                });

            // Unique Character Effect Slider
            ~ui[zm.fxKey] = EZSlider(page, Rect(15, 70, 435, 22), zm.fxLabel ++ " [CC" ++ ~cc[zm.fxKey] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, ~ccVals[zm.fxKey]), { |sl|
                ~ccVals[zm.fxKey] = sl.value;
                ~buses[zm.fxKey].set(sl.value);
            }, labelWidth: 140, numberWidth: 42).setColors(stringColor: Color(0.95, 0.82, 0.45), sliderColor: Color(0.78, 0.45, 0.22));

            // Overlapping Note Range
            ~ui[("range" ++ zIdx).asSymbol] = EZRanger(page, Rect(15, 98, 435, 22), "Keys (Min/Max)", ControlSpec(0, 127, \lin, 1), { |rg|
                ~ccVals[("min" ++ zIdx).asSymbol] = rg.value[0];
                ~ccVals[("max" ++ zIdx).asSymbol] = rg.value[1];
                ~buses[("min" ++ zIdx).asSymbol].set(rg.value[0]);
                ~buses[("max" ++ zIdx).asSymbol].set(rg.value[1]);
            }, [~ccVals[("min" ++ zIdx).asSymbol], ~ccVals[("max" ++ zIdx).asSymbol]], labelWidth: 110, numberWidth: 32).setColors(stringColor: Color.white);

            // Resonant Filters
            ~ui[("hpf" ++ zIdx).asSymbol] = EZSlider(page, Rect(15, 126, 435, 20), "HPF [CC" ++ ~cc[("hpf" ++ zIdx).asSymbol] ++ "]", ControlSpec(20, 18000, \exp, 1, ~ccVals[("hpf" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("hpf" ++ zIdx).asSymbol] = sl.value;
                ~buses[("hpf" ++ zIdx).asSymbol].set(sl.value);
            }, labelWidth: 80, numberWidth: 42).setColors(stringColor: Color.white, sliderColor: Color(0.35, 0.5, 0.65));

            ~ui[("lpf" ++ zIdx).asSymbol] = EZSlider(page, Rect(15, 150, 435, 20), "LPF [CC" ++ ~cc[("lpf" ++ zIdx).asSymbol] ++ "]", ControlSpec(20, 18000, \exp, 1, ~ccVals[("lpf" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("lpf" ++ zIdx).asSymbol] = sl.value;
                ~buses[("lpf" ++ zIdx).asSymbol].set(sl.value);
            }, labelWidth: 80, numberWidth: 42).setColors(stringColor: Color.white, sliderColor: Color(0.35, 0.5, 0.65));

            ~ui[("rq" ++ zIdx).asSymbol] = EZSlider(page, Rect(15, 174, 435, 20), "Filter Q [CC" ++ ~cc[("rq" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.05, 1.0, \lin, 0.01, ~ccVals[("rq" ++ zIdx).asSymbol]), { |sl|
                ~ccVals[("rq" ++ zIdx).asSymbol] = sl.value;
                ~buses[("rq" ++ zIdx).asSymbol].set(sl.value);
            }, labelWidth: 80, numberWidth: 42).setColors(stringColor: Color.white, sliderColor: Color(0.35, 0.5, 0.65));

            // Envelope Knobs
            ~ui[("atk" ++ zIdx).asSymbol] = EZKnob(page, Rect(25, 208, 80, 90), "Atk [CC" ++ ~cc[("atk" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.001, 5.0, \exp, 0.001, ~ccVals[("atk" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("atk" ++ zIdx).asSymbol] = kb.value;
                ~buses[("atk" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("dec" ++ zIdx).asSymbol] = EZKnob(page, Rect(125, 208, 80, 90), "Dec [CC" ++ ~cc[("dec" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.01, 5.0, \exp, 0.01, ~ccVals[("dec" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("dec" ++ zIdx).asSymbol] = kb.value;
                ~buses[("dec" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("sus" ++ zIdx).asSymbol] = EZKnob(page, Rect(225, 208, 80, 90), "Sus [CC" ++ ~cc[("sus" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, ~ccVals[("sus" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("sus" ++ zIdx).asSymbol] = kb.value;
                ~buses[("sus" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));

            ~ui[("rls" ++ zIdx).asSymbol] = EZKnob(page, Rect(325, 208, 80, 90), "Rls [CC" ++ ~cc[("rls" ++ zIdx).asSymbol] ++ "]", ControlSpec(0.01, 6.0, \exp, 0.01, ~ccVals[("rls" ++ zIdx).asSymbol]), { |kb|
                ~ccVals[("rls" ++ zIdx).asSymbol] = kb.value;
                ~buses[("rls" ++ zIdx).asSymbol].set(kb.value);
            }).setColors(stringColor: Color.white, knobColor: Color(0.85, 0.65, 0.3));
        };

        // Static Bottom Bar: Echo/Reverb Console & Panic
        StaticText(~mainWin, Rect(20, winH - 145, 300, 18))
            .string_("RESONANCE & ENVIRONMENT CHASSIS")
            .font_(Font("Monaco", 10, true))
            .stringColor_(Color(0.4, 0.85, 0.6));

        ~ui[\delMix] = EZSlider(~mainWin, Rect(20, winH - 120, 220, 20), "Echo Wet [CC" ++ ~cc[\delMix] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, 0.0), { |sl|
            ~ccVals[\delMix] = sl.value;
            ~buses[\delMix].set(sl.value);
        }, labelWidth: 90, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.6, 0.5));

        ~ui[\delTime] = EZSlider(~mainWin, Rect(20, winH - 95, 220, 20), "Echo Time [CC" ++ ~cc[\delTime] ++ "]", ControlSpec(0.02, 1.0, \exp, 0.01, 0.26), { |sl|
            ~ccVals[\delTime] = sl.value;
            ~buses[\delTime].set(sl.value);
        }, labelWidth: 90, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.2, 0.6, 0.5));

        ~ui[\verbMix] = EZSlider(~mainWin, Rect(260, winH - 120, 220, 20), "Room Wet [CC" ++ ~cc[\verbMix] ++ "]", ControlSpec(0.0, 1.0, \lin, 0.01, 0.0), { |sl|
            ~ccVals[\verbMix] = sl.value;
            ~buses[\verbMix].set(sl.value);
        }, labelWidth: 90, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.25, 0.45, 0.7));

        ~ui[\verbTime] = EZSlider(~mainWin, Rect(260, winH - 95, 220, 20), "Room Dec [CC" ++ ~cc[\verbTime] ++ "]", ControlSpec(0.2, 8.0, \exp, 0.05, 2.2), { |sl|
            ~ccVals[\verbTime] = sl.value;
            ~buses[\verbTime].set(sl.value);
        }, labelWidth: 90, numberWidth: 35).setColors(stringColor: Color.white, sliderColor: Color(0.25, 0.45, 0.7));

        // Panic Button (All Notes Off)
        Button(~mainWin, Rect(winW - 170, winH - 120, 150, 45))
            .states_([["PANIC // SILENCE", Color.white, Color(0.68, 0.15, 0.15)]])
            .font_(Font("Monaco", 10, true))
            .action_({
                128.do { |n|
                    ~notes1[n].do(_.free); ~notes1[n] = nil;
                    ~notes2[n].do(_.free); ~notes2[n] = nil;
                    ~notes3[n].do(_.free); ~notes3[n] = nil;
                };
                "Berimbau voice matrix silenced.".postln;
            });

        ~mainWin.front;

        // Compact 20fps AppClock Polling Routine
        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
)


// ============================================================
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: Ternos de Congo, Moçambiques, e Gungas de Lata
TempoClock.default.tempo = 104 / 60;

// Layer 1: Caixas e Tambus de Congado (Skin + Shell Modal Drums)
Ndef(\congadaDrums).fadeTime = 3;
Ndef(\congadaDrums, { |t_trig=0, freq=68, decay=0.35, rim=0.2, amp=0.24, pan=0|
    var trig = K2A.ar(t_trig);
    var strike = WhiteNoise.ar * Decay2.ar(trig, 0.001, 0.015);
    var headEnv = EnvGen.ar(Env.perc(0.002, decay, 1, -5), trig);
    var pitchEnv = EnvGen.ar(Env([freq * 1.8, freq], [0.02], \exp), trig);
    var modes = DynKlank.ar(
        `[
            [pitchEnv, pitchEnv * 1.48, pitchEnv * 2.14, pitchEnv * 2.82],
            [1.0, 0.6, 0.35, 0.2],
            [decay, decay * 0.7, decay * 0.45, decay * 0.3]
        ],
        strike
    );
    var rimClick = BPF.ar(WhiteNoise.ar, 1850, 0.25) * Decay2.ar(trig, 0.001, 0.04) * rim * 3;
    var sig = (modes * headEnv * 1.5) + rimClick;
    sig = LeakDC.ar((sig * 1.8).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaDrums)[10] = \filter -> { |in|
    CombL.ar(in, 0.35, [0.144, 0.216], 1.2) * 0.5 + in;
};
Ndef(\congadaDrums).set(\wet10, 0.22);

Pbindef(\congadaDrumsSeq,
    \dur, Pn(Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25], inf), inf),
    \freq, Pn(Pseq([62, 70, 58, 62, 74, 62, 58], inf), inf),
    \decay, Pn(Pseq([0.45, 0.2, 0.6, 0.3, 0.18, 0.35, 0.5], inf), inf),
    \rim, Pn(Pseq([0.1, 0.8, 0.15, 0.2, 0.9, 0.1, 0.3], inf), inf),
    \pan, Pwhite(-0.25, 0.25, inf),
    \amp, Pn(Pseq([0.28, 0.18, 0.25, 0.2, 0.19, 0.22, 0.26], inf), inf),
    \t_trig, 1
);
Ndef(\congadaDrums).quant = 1;
Ndef(\congadaDrums)[1] = \set -> Pbindef(\congadaDrumsSeq);

// Layer 2: Gungas de Lata (Tin-Can Ankle Shakers & Clatter)
Ndef(\gungasLata).fadeTime = 3;
Ndef(\gungasLata, { |t_trig=0, bright=4200, rattleDec=0.18, pan=0.1, amp=0.18|
    var trig = K2A.ar(t_trig);
    var exc = Dust2.ar(380) * Decay.ar(trig, rattleDec);
    var tinModes = DynKlank.ar(
        `[
            [bright * 0.65, bright, bright * 1.34, bright * 1.85, bright * 2.3],
            [0.5, 1.0, 0.8, 0.6, 0.4],
            [0.08, 0.12, 0.09, 0.05, 0.04]
        ],
        exc
    );
    var body = HPF.ar(tinModes, 800);
    var gravel = BPF.ar(WhiteNoise.ar, bright * 1.1, 0.3) * Decay2.ar(trig, 0.003, rattleDec * 0.8) * 2.5;
    var sig = (body * 0.8) + gravel;
    sig = Fold.ar(sig * 1.5, -0.9, 0.9);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.65, 0.25);
};
Ndef(\gungasLata).set(\wet10, 0.3);

Pbindef(\gungasLataSeq,
    \dur, Pn(Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25], inf), inf),
    \bright, Pn(Pseq([3800, 4400, 4100, 4800, 3900, 4200], inf), inf),
    \rattleDec, Pn(Pseq([0.12, 0.16, 0.22, 0.1, 0.14, 0.24], inf), inf),
    \pan, Pwhite(-0.65, 0.65, inf),
    \amp, Pn(Pseq([0.14, 0.16, 0.2, 0.13, 0.15, 0.19], inf), inf),
    \t_trig, 1
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\gungasLataSeq);

// Layer 3: Louvor Processional (Choral Vowel Formant Resonators)
Ndef(\congadaVoz).fadeTime = 4;
Ndef(\congadaVoz, { |t_trig=0, note=58, vowel=0, gateTime=0.45, amp=0.15, pan=0|
    var trig = K2A.ar(t_trig);
    var freq = note.midicps;
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.08, gateTime, 0.3], \sin), trig);
    var pulse = Pulse.ar(freq * [0.995, 1.005], 0.35).sum;
    var saw = Saw.ar(freq * [0.998, 1.002]).sum;
    var source = (pulse * 0.6) + (saw * 0.4);
    var fA = [800, 1200, 2600];
    var fO = [500, 900, 2400];
    var fU = [350, 750, 2200];
    var f1 = SelectX.kr(vowel, [fA[0], fO[0], fU[0]]);
    var f2 = SelectX.kr(vowel, [fA[1], fO[1], fU[1]]);
    var f3 = SelectX.kr(vowel, [fA[2], fO[2], fU[2]]);
    var formants = BPF.ar(source, [f1, f2, f3], [0.1, 0.12, 0.15]).sum * 4.5;
    var sig = MoogFF.ar(formants * env, 3200, 1.2);
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaVoz)[10] = \filter -> { |in|
    AllpassC.ar(in, 0.5, [0.33, 0.41], 2.5);
};
Ndef(\congadaVoz)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.4);
};
Ndef(\congadaVoz).set(\wet10, 0.28, \wet11, 0.35);

Pbindef(\congadaVozSeq,
    \dur, Pn(Pseq([1.0, 0.5, 0.5, 1.0, 1.0], inf), inf),
    \note, Pn(Pseq([58, 61, 63, 65, 61], inf), inf),
    \vowel, Pn(Pseq([0.0, 0.8, 1.6, 1.2, 0.4], inf), inf),
    \gateTime, Pn(Pseq([0.65, 0.35, 0.38, 0.7, 0.6], inf), inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \amp, Pn(Pseq([0.16, 0.14, 0.15, 0.18, 0.15], inf), inf),
    \t_trig, 1
);
Ndef(\congadaVoz).quant = 1;
Ndef(\congadaVoz)[1] = \set -> Pbindef(\congadaVozSeq);
)

// Live Performance Controls:
// Ndef(\congadaDrums).xset(\freq, 82); // Tighten drum tuning | Revert: Ndef(\congadaDrums).xset(\freq, 68);
// Pbindef(\gungasLataSeq, \dur, 0.125); // Relentless ankle shaker pace | Revert: Pbindef(\gungasLataSeq, \dur, Pn(Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.25], inf), inf));
// Ndef(\congadaVoz).xset(\vowel, 1.9); // Deep dark vowel chants | Revert: Ndef(\congadaVoz).xset(\vowel, 0.0);
// Pbindef(\congadaDrumsSeq).stop; Ndef(\congadaDrums).fadeTime = 3; Ndef(\congadaDrums).clear(3); // Rollback drums
// Pbindef(\gungasLataSeq).stop; Ndef(\gungasLata).fadeTime = 3; Ndef(\gungasLata).clear(3); // Rollback gungas
// Pbindef(\congadaVozSeq).stop; Ndef(\congadaVoz).fadeTime = 4; Ndef(\congadaVoz).clear(4); // Rollback vocal chants


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: FIXED
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// Pantanal: Crepúsculo Incandescente, Corixo Calmo e Revoada das Araras-Azuis

// Layer 1: Corixo & Camalotes (Warm Twilight Sub Drone, Water Resonances, Insect Murmurs)
Ndef(\pantanalCorixo).fadeTime = 4;
Ndef(\pantanalCorixo, { |t_trig=0, fund=55, cut=650, waterMix=0.4, pan=0, amp=0.22|
    var trig = K2A.ar(t_trig);
    var slowLfo = SinOsc.kr(0.08, [0, pi * 0.5]);
    var drone = Splay.ar(
        Saw.ar(fund * [0.5, 0.998, 1.002, 1.5, 2.01]) * [0.6, 0.8, 0.8, 0.4, 0.2]
    );
    var filteredDrone = MoogFF.ar(drone, cut + (slowLfo * 180), 1.8);
    var waterDrops = Dust2.ar([6, 8]) * Decay2.ar(Dust.ar([3, 4]), 0.005, 0.12);
    var resonantLilly = DynKlank.ar(
        `[
            [180, 310, 440, 620, 890],
            [0.6, 0.8, 0.5, 0.4, 0.2],
            [0.4, 0.35, 0.3, 0.2, 0.15]
        ],
        waterDrops
    ) * 0.7;
    var insectBed = HPF.ar(PinkNoise.ar(0.06), 4500) * LFNoise2.kr(1.2).range(0.3, 1.0);
    var sig = filteredDrone + (resonantLilly * waterMix) + (insectBed * 0.3);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Ndef(\pantanalCorixo)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3);
};
Ndef(\pantanalCorixo).set(\wet10, 0.35);

Pbindef(\pantanalCorixoSeq,
    \dur, Pn(Pseq([4.0, 3.5, 4.5, 5.0], inf), inf),
    \fund, Pn(Pseq([43.65, 48.99, 43.65, 38.89], inf), inf), // F1, G1, F1, D1
    \cut, Pn(Pseq([550, 720, 600, 800], inf), inf),
    \waterMix, Pn(Pseq([0.35, 0.5, 0.4, 0.45], inf), inf),
    \pan, Pwhite(-0.2, 0.2, inf),
    \amp, Pn(Pseq([0.22, 0.24, 0.21, 0.25], inf), inf),
    \t_trig, 1
);
Ndef(\pantanalCorixo).quant = 1;
Ndef(\pantanalCorixo)[1] = \set -> Pbindef(\pantanalCorixoSeq);

// Layer 2: Bater de Asas & Galhos Secos do Piúva (Low Wing-Flap Air Thuds & Dry Branch Creaks)
Ndef(\baterAsas).fadeTime = 3;
Ndef(\baterAsas, { |t_trig=0, flapSpeed=3.5, woodPitch=220, creak=0.15, pan=(-0.25), amp=0.24|
    var trig = K2A.ar(t_trig);
    var burstEnv = Decay.ar(trig, 0.65);
    var flapOsc = SinOsc.ar(flapSpeed * 2 * pi).range(0, 1) ** 2;
    var airPuff = LPF.ar(BrownNoise.ar, 140) * flapOsc * burstEnv * 4.5;
    var wingCrack = BPF.ar(WhiteNoise.ar, 1200, 0.4) * Decay2.ar(trig, 0.002, 0.02) * 1.8;
    var woodImp = Dust.ar(12 * creak) * Decay.ar(trig, 0.45);
    var dryBranch = Ringz.ar(woodImp, woodPitch * [1, 1.48, 2.12], 0.06).sum * 1.5;
    var body = (airPuff * 1.2) + (wingCrack * 0.4) + (dryBranch * 0.7);
    Pan2.ar(body.tanh, pan, amp);
}).play;

Ndef(\baterAsas)[10] = \filter -> { |in|
    CombL.ar(in, 0.25, [0.08, 0.11], 0.8);
};
Ndef(\baterAsas).set(\wet10, 0.22);

Pbindef(\baterAsasSeq,
    \dur, Pwrand([0.5, 0.75, 1.0, 1.25], [0.4, 0.3, 0.2, 0.1], inf),
    \flapSpeed, Pwhite(2.8, 4.4, inf),
    \woodPitch, Pn(Pseq([180, 240, 210, 290, 195], inf), inf),
    \creak, Pwhite(0.1, 0.4, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pn(Pseq([0.22, 0.26, 0.2, 0.28, 0.23], inf), inf),
    \t_trig, 1
);
Ndef(\baterAsas).quant = 1;
Ndef(\baterAsas)[1] = \set -> Pbindef(\baterAsasSeq);

// Layer 3: Revoada das Araras-Azuis (Piercing Raucous Squawks, Formant Chirps & Screams)
Ndef(\ararasAzuis).fadeTime = 3;
Ndef(\ararasAzuis, { |t_trig=0, baseFreq=1100, sweep=1.6, screech=0.7, pan=0.3, amp=0.2|
    var trig = K2A.ar(t_trig);
    var squawkEnv = EnvGen.ar(Env([0, 1, 0.6, 0], [0.02, 0.14, 0.18], \welch), trig);
    var pitchEnv = EnvGen.ar(Env([baseFreq * sweep, baseFreq, baseFreq * 0.85], [0.05, 0.2], \exp), trig);
    var fmod = SinOsc.ar(pitchEnv * 0.5) * (pitchEnv * screech * 1.4);
    var exciter = Pulse.ar(pitchEnv + fmod, 0.32) + (PinkNoise.ar * 0.25);
    var bodyMono = exciter; // exciter is already a single mono UGen; removed invalid .sum
    var formantFilt = BPF.ar(bodyMono, [1600, 2700, 4200], [0.12, 0.14, 0.18]).sum * 6.0;
    var grit = Fold.ar(formantFilt * (1 + (screech * 1.5)), -0.85, 0.85);
    var sig = grit * squawkEnv;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\ararasAzuis)[10] = \filter -> { |in|
    AllpassC.ar(in, 0.4, [0.19, 0.26], 2.2);
};
Ndef(\ararasAzuis)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35);
};
Ndef(\ararasAzuis).set(\wet10, 0.32, \wet11, 0.28);

Pbindef(\ararasAzuisSeq,
    \dur, Pn(Pseq([0.25, 0.25, 0.5, 0.75, 0.25, 1.25, Rest(0.75)], inf), inf),
    \baseFreq, Pn(Pseq([980, 1150, 1320, 1050, 1260, 880], inf), inf),
    \sweep, Pwhite(1.3, 1.9, inf),
    \screech, Pwhite(0.4, 0.95, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pn(Pseq([0.18, 0.22, 0.25, 0.19, 0.24, 0.16], inf), inf),
    \t_trig, 1
);
Ndef(\ararasAzuis).quant = 1;
Ndef(\ararasAzuis)[1] = \set -> Pbindef(\ararasAzuisSeq);
)

