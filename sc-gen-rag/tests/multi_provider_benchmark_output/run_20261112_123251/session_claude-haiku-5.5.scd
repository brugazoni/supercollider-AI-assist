// ============================================================
// MULTI-PROVIDER BENCHMARK: Claude Haiku Latest
// Model ID: openrouter:anthropic/claude-haiku-5.5
// Date: 2026-11-12T15:37:28.044573+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// Ndef(\antarctica): drone de vento gelado que sustenta o silêncio tenso entre o casal
Ndef(\antarctica, { |freq=38, amp=0.25, cutoff=320, gust=0.15|
    var wind, drone, sig;
    wind = BPF.ar(PinkNoise.ar, LFNoise2.kr(gust).range(180, 700), 0.35) * LFNoise1.kr(0.12).range(0.15, 1.0);
    drone = SinOsc.ar(freq * [1, 1.5]).sum * 0.25;
    sig = LPF.ar(wind * 0.7 + drone, cutoff);
    [sig * amp, DelayC.ar(sig, 0.03, 0.017) * amp]
}).play;

// Ndef(\creases): cliques secos de dobras de mapa, disparados pelo Pbindef
// freq agora é argumento do SynthDef (\freq.kr não é válido dentro de uma UGen-function)
Ndef(\creases, { |amp=0.2, t_trig=0, rq=0.04, pan=0, freq=1200|
    var env, sig;
    env = EnvGen.ar(Env.perc(0.001, 0.3), t_trig);
    sig = BPF.ar(WhiteNoise.ar, freq, rq) * env * 9;
    Pan2.ar(sig, pan, amp)
}).play;

// Sequência esparsa: longas pausas (silêncio pesado) interrompidas por dobras
Pbindef(\creaseSeq,
    \dur, Pseq([3, 2.5, 0.5, 0.25, 4, 1], inf),
    \t_trig, 1,
    \freq, Pseq([1200, 900, 1500, 700, 1100, 2000], inf),
    \amp, Pwhite(0.05, 0.2, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\creases)[1] = \set -> Pbindef(\creaseSeq);

// Rollback: remove these instruments
// Pbindef(\creaseSeq).stop; Ndef(\creases).fadeTime = 2; Ndef(\creases).clear(2);
// Pbindef(\antarcticaSeq).stop; Ndef(\antarctica).fadeTime = 2; Ndef(\antarctica).clear(2);
)


// ============================================================
// ROUND 02 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// Ndef(\chains): tinir de ferros e estalos de açoite, o terror mecânico da corrente
Ndef(\chains, { |freq=800, amp=0.2, t_trig=0, decay=0.6, pan=0|
    var exc, clank, crack, sig;
    exc = Decay2.ar(K2A.ar(t_trig), 0.001, 0.01) * WhiteNoise.ar;
    clank = Ringz.ar(exc, [freq, freq * 1.47, freq * 2.13], [decay * 0.7, decay * 0.45, decay * 0.25]).sum;
    crack = HPF.ar(WhiteNoise.ar, 3000) * EnvGen.ar(Env.perc(0.0005, 0.04), t_trig) * 2;
    sig = (clank * 0.5 + crack).tanh;
    Pan2.ar(sig * amp, pan)
}).play;

// Sequência de correntes: pulsos irregulares que se adensam, como o castigo que não cessa
Pbindef(\chainSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1.5, 0.125, 0.125, 2, 0.75], inf),
    \t_trig, 1,
    \freq, Pwhite(400, 1200, inf),
    \decay, Pwhite(0.2, 0.8, inf),
    \amp, Pexprand(0.05, 0.3, inf),
    \pan, Pwhite(-0.9, 0.9, inf)
);

Ndef(\chains)[1] = \set -> Pbindef(\chainSeq);

// Rollback: remove this instrument
// Pbindef(\chainSeq).stop; Ndef(\chains).fadeTime = 2; Ndef(\chains).clear(2);
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

	SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
	s.sync;
	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// Tic-tac de escapamento metálico
	SynthDef(\tictac, { |out=0, freq=2400, amp=0.3, pan=0, decay=0.03|
		var env, exc, sig;
		env = EnvGen.ar(Env.perc(0.0005, decay), doneAction: 2);
		exc = HPF.ar(WhiteNoise.ar, 1500) * env;
		sig = Ringz.ar(exc, [freq, freq * 2.37, freq * 3.9], [0.02, 0.012, 0.008]).sum;
		sig = (sig * 0.6 + (exc * 0.2)).tanh;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	// Carrilhão com parciais inarmônicas
	SynthDef(\carrilhao, { |out=0, freq=880, amp=0.2, pan=0|
		var env, sig;
		env = EnvGen.ar(Env.perc(0.002, 2.5, 1, -6), doneAction: 2);
		sig = (SinOsc.ar(freq * [1, 2.76, 5.4]) * [1, 0.3, 0.1]).sum * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;
	s.sync;

	// Zumbido de pêndulos desafinados
	Ndef(\pendulo, { |amp=0, beat=0.7, cutoff=900|
		var base, sig;
		base = 220 * [1, 1.0023, 0.9981, 1.0009];
		sig = SinOsc.ar(base).sum * 0.2;
		sig = LPF.ar(sig * (LFPulse.kr(beat * 0.5, 0, 0.3).lag(0.02) + 0.1), cutoff);
		[sig * amp, DelayC.ar(sig, 0.03, 0.013) * amp];
	});
	Ndef(\pendulo).fadeTime = 3;

	// Respiração do tempo: ruído filtrado errante
	Ndef(\aliento, { |amp=0, rate=0.05|
		var sig;
		sig = BPF.ar(PinkNoise.ar, LFNoise2.kr(rate).range(200, 900), 0.3) * LFNoise1.kr(0.1).range(0.1, 1.0);
		[sig * amp, DelayC.ar(sig, 0.02, 0.011) * amp];
	});
	Ndef(\aliento).fadeTime = 4;

	Ndef(\masterMix, { In.ar(~synthBus, 2) });
	Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.8, 0.3) };
	Ndef(\masterMix).set(\wet10, 0.25);

	// Relógios com deriva microscópica entre si
	Pbindef(\relogioA, \instrument, \tictac, \dur, 0.5, \freq, 2400, \amp, 0.10, \pan, (-0.7), \decay, 0.03, \out, ~synthBus);
	Pbindef(\relogioB, \instrument, \tictac, \dur, 0.5017, \freq, 2550, \amp, 0.08, \pan, 0.6, \decay, 0.025, \out, ~synthBus);
	Pbindef(\relogioC, \instrument, \tictac, \dur, 0.4991, \freq, 2210, \amp, 0.08, \pan, 0.1, \decay, 0.035, \out, ~synthBus);
	Pbindef(\relogioD, \instrument, \tictac, \dur, 0.5046, \freq, 2880, \amp, 0.07, \pan, (-0.2), \decay, 0.02, \out, ~synthBus);

	Pbindef(\campainha,
		\instrument, \carrilhao,
		\dur, Pseq([4, 2.5, 6, 1.5], inf),
		\freq, Pseq([880, 1108, 660, 990], inf),
		\amp, 0.15,
		\pan, Pwhite(-0.5, 0.5, inf),
		\out, ~synthBus
	);

	// Sem .wait fora da Tdef
	Ndef(\pendulo).play(~synthBus.index, 2);
	Ndef(\aliento).play(~synthBus.index, 2);
	Ndef(\masterMix).play;
	s.sync;

	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - [Cue 1: Oficina silenciosa, um único pêndulo]".postln;
		Ndef(\pendulo).xset(\amp, 0.12);
		Pbindef(\relogioA).play;
		8.wait;

		"0:08 - [Cue 2: Carrilhões desencontrados]".postln;
		Pbindef(\relogioB).play;
		Pbindef(\relogioC).play;
		10.wait;

		"0:18 - [Cue 3: O respirar do tempo]".postln;
		Ndef(\aliento).xset(\amp, 0.18);
		4.do { |i|
			Ndef(\aliento).xset(\rate, exprand(0.03, 0.3));
			Ndef(\pendulo).xset(\cutoff, exprand(400, 2400));
			3.wait;
		};

		"0:30 - [Cue 4: Campainhas entre os ponteiros]".postln;
		Pbindef(\campainha).play;
		Pbindef(\relogioD).play;
		10.wait;

		"0:40 - [Cue 5: Limite intrínseco - deriva máxima]".postln;
		8.do { |i|
			Pbindef(\relogioD, \dur, 0.5 + (0.09 * (i + 1) / 8));
			Pbindef(\relogioB, \dur, 0.5 - (0.04 * (i + 1) / 8));
			2.wait;
		};

		"0:58 - [Cue 6: Assentamento - apenas um pêndulo frágil]".postln;
		Pbindef(\relogioB).stop;
		Pbindef(\relogioC).stop;
		Pbindef(\relogioD).stop;
		Pbindef(\campainha).stop;
		Ndef(\aliento).xset(\amp, 0.02);
		10.wait;

		"1:10 - [Cue 7: Resolução - todos retornam ao compasso inicial]".postln;
		Pbindef(\relogioB, \dur, 0.5017).play;
		Pbindef(\relogioC, \dur, 0.4991).play;
		Pbindef(\relogioD, \dur, 0.5).play;
		Pbindef(\campainha).play;
		Ndef(\aliento).xset(\amp, 0.18);
		12.wait;

		"1:24 - [Cue 8: Extrínseco - a última badalada]".postln;
		Ndef(\pendulo).xset(\amp, 0);
		Ndef(\aliento).xset(\amp, 0);
		6.wait;

		Pbindef(\relogioA).stop; Pbindef(\relogioA).clear;
		Pbindef(\relogioB).stop; Pbindef(\relogioB).clear;
		Pbindef(\relogioC).stop; Pbindef(\relogioC).clear;
		Pbindef(\relogioD).stop; Pbindef(\relogioD).clear;
		Pbindef(\campainha).stop; Pbindef(\campainha).clear;
		Ndef(\pendulo).clear(3);
		Ndef(\aliento).clear(3);
		Ndef(\masterMix).clear(3);
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

	SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
	s.sync;
	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// Gota d'água com estalo de superfície
	SynthDef(\pingoGota, { |out=0, freq=1800, amp=0.2, pan=0|
		var env, pitchEnv, sig;
		env = EnvGen.ar(Env.perc(0.001, 0.4, 1, -7), doneAction: 2);
		pitchEnv = EnvGen.ar(Env.perc(0.001, 0.05));
		sig = SinOsc.ar(freq * (1 + (pitchEnv * 0.6))) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	// Estalactite: ressonância modal excitada por ruído
	SynthDef(\estalactite, { |out=0, freq=220, amp=0.2, pan=0, ring=3|
		var env, exc, sig;
		env = EnvGen.ar(Env.perc(0.001, ring, 1, -4), doneAction: 2);
		exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01));
		sig = DynKlank.ar(Ref([ [freq, freq * 2.41, freq * 3.87, freq * 5.13], [1, 0.5, 0.25, 0.12], [1, 0.8, 0.6, 0.4] ]), exc);
		Out.ar(out, Pan2.ar(sig * env * amp, pan));
	}).add;

	// Gongo de salão: parciais harmônicas com ataque lento
	SynthDef(\gongoCaverna, { |out=0, freq=110, amp=0.2, pan=0|
		var env, sig;
		env = EnvGen.ar(Env.perc(0.005, 6, 1, -3), doneAction: 2);
		sig = (SinOsc.ar(freq * [1, 2.0, 3.01]) * [1, 0.4, 0.15]).sum * env;
		Out.ar(out, Pan2.ar(sig.tanh * amp, pan));
	}).add;
	s.sync;

	// Abóbada úmida: gotas filtradas em pentes de ressonância
	Ndef(\abobada, { |amp=0, rate=0.5, cut=600|
		var exc, sig;
		exc = (Dust.ar(rate) * 0.6) + (PinkNoise.ar * 0.02);
		sig = LPF.ar(exc, cut);
		sig = [
			CombL.ar(sig, 0.5, 0.231, 3) + CombL.ar(sig, 0.5, 0.297, 3),
			CombL.ar(sig, 0.5, 0.263, 3) + CombL.ar(sig, 0.5, 0.311, 3)
		];
		sig = AllpassC.ar(sig, 0.05, [0.023, 0.031], 1);
		sig * amp;
	});
	Ndef(\abobada).fadeTime = 4;

	// Névoa mineral: ruído filtrado errante
	Ndef(\nevoaMineral, { |amp=0|
		var sig;
		sig = BPF.ar(PinkNoise.ar, LFNoise2.kr(0.07).range(180, 700), 0.2) * 8;
		sig = sig * LFNoise1.kr(0.2).range(0.2, 1);
		[sig * amp, DelayC.ar(sig, 0.03, 0.017) * amp];
	});
	Ndef(\nevoaMineral).fadeTime = 4;

	Ndef(\masterMix, { In.ar(~synthBus, 2) + Ndef.ar(\abobada, 2) + Ndef.ar(\nevoaMineral, 2) });
	Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.4) };
	Ndef(\masterMix).set(\wet10, 0.3);
	Ndef(\masterMix).play;
	s.sync;

	// Sequências discretas roteadas ao mixer
	Pbindef(\gotas,
		\instrument, \pingoGota,
		\dur, Pexprand(0.25, 1.2, inf),
		\freq, Pwhite(1400, 3200, inf),
		\amp, 0.08,
		\pan, Pwhite(-0.8, 0.8, inf),
		\out, ~synthBus
	);

	Pbindef(\estalagmites,
		\instrument, \estalactite,
		\dur, Pseq([2, 2, 1.5, 3], inf),
		\freq, Pseq([55, 82.4, 65.4, 73.4], inf),
		\amp, 0.25,
		\ring, 5,
		\pan, (-0.4),
		\out, ~synthBus
	);

	Pbindef(\gongos,
		\instrument, \gongoCaverna,
		\dur, Pseq([7, 5, 9], inf),
		\freq, Pseq([55, 41.2, 48.9], inf),
		\amp, 0.3,
		\pan, 0,
		\out, ~synthBus
	);

	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - [Cue 1: Entrada na gruta, gotejo isolado]".postln;
		Ndef(\abobada).xset(\amp, 0.15);
		Pbindef(\gotas).play;
		8.wait;

		"0:08 - [Cue 2: Ressonância das abóbadas]".postln;
		Ndef(\abobada).xset(\amp, 0.22);
		Pbindef(\estalagmites).play;
		6.do { |i|
			Ndef(\abobada).xset(\cut, exprand(300, 2000));
			3.wait;
		};

		"0:26 - [Cue 3: Salões em cascata, gongos]".postln;
		Pbindef(\gotas).stop;
		Pbindef(\gongos).play;
		Ndef(\nevoaMineral).xset(\amp, 0.12);
		4.do { |i|
			Ndef(\abobada).xset(\rate, exprand(0.3, 2.0));
			2.wait;
		};
		8.wait;

		"0:46 - [Cue 4: Limite intrínseco - gotejo máximo]".postln;
		Pbindef(\gotas).play;
		8.do { |i|
			Pbindef(\gotas, \dur, Pexprand(0.04, 0.5 - (i * 0.05), inf));
			2.wait;
		};

		"1:02 - [Cue 5: Assentamento - uma gota frágil]".postln;
		Pbindef(\gotas).stop;
		Pbindef(\estalagmites).stop;
		Pbindef(\gongos).stop;
		Ndef(\abobada).xset(\amp, 0.05);
		Ndef(\nevoaMineral).xset(\amp, 0.04);
		10.wait;

		"1:12 - [Cue 6: Resolução - retorno ao gotejo inicial]".postln;
		Pbindef(\gotas, \dur, Pexprand(0.25, 1.2, inf)).play;
		Pbindef(\estalagmites).play;
		Ndef(\abobada).xset(\amp, 0.2);
		12.wait;

		"1:26 - [Cue 7: Extrínseco - último gongo]".postln;
		Pbindef(\gotas).stop;
		Pbindef(\gongos).play;
		6.wait;
		Ndef(\abobada).xset(\amp, 0);
		Ndef(\nevoaMineral).xset(\amp, 0);
		5.wait;

		Pbindef(\gotas).stop; Pbindef(\gotas).clear;
		Pbindef(\estalagmites).stop; Pbindef(\estalagmites).clear;
		Pbindef(\gongos).stop; Pbindef(\gongos).clear;
		Ndef(\abobada).clear(3);
		Ndef(\nevoaMineral).clear(3);
		Ndef(\masterMix).clear(3);
		"Score Complete.".postln;
		Tdef(\masterScore).stop;
	});
	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 05 | MODE: DESIGN | FRAG #74
// STATUS: PASS
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// Step 0: parameter map, defaults and specs
~paramKeys = [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx, \mute, \min, \max];
~synthKeys = [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx];
~cc = ();
3.do { |i| ~paramKeys.do { |k, j| ~cc[(k ++ (i + 1)).asSymbol] = 20 + (i * 13) + j } };
~cc[\delMix] = 80; ~cc[\verbMix] = 81; ~cc[\delTime] = 82; ~cc[\revTime] = 83; ~cc[\masterVol] = 84; ~cc[\panic] = 123;
~zoneDefaults = [
    (vol: 0.25, pan: 0, hpf: 30, lpf: 900, rq: 0.5, atk: 0.01, dec: 0.4, sus: 0.8, rls: 0.8, fx: 0.0, mute: 0, min: 0, max: 50),
    (vol: 0.22, pan: (-0.35), hpf: 120, lpf: 6000, rq: 0.3, atk: 0.02, dec: 0.6, sus: 0.6, rls: 1.2, fx: 0.0, mute: 0, min: 40, max: 96),
    (vol: 0.18, pan: 0.35, hpf: 160, lpf: 3000, rq: 0.2, atk: 1.5, dec: 1.0, sus: 0.7, rls: 3.0, fx: 0.0, mute: 0, min: 30, max: 127)
];
~groupDefaults = (delMix: 0.0, verbMix: 0.0, delTime: 0.3, revTime: 2.0, masterVol: 0.9);
~zoneMeta = [(title: "I SUB", fxLabel: "FOLD"), (title: "II LISSAJOUS", fxLabel: "FM"), (title: "III PHOSFORO", fxLabel: "GHOST")];
~pageTitles = ["I SUB", "II LISSAJOUS", "III PHOSFORO", "MASTER"];
~zoneDefs = [\subZone, \lissa, \phos];
~zoneNotes = Array.fill(3, { Array.fill(128, { [] }) });
~specs = (
    vol: ControlSpec(0, 1, \lin), pan: ControlSpec(-1, 1, \lin), hpf: ControlSpec(20, 2000, \exp),
    lpf: ControlSpec(40, 18000, \exp), rq: ControlSpec(0.05, 1, \exp), atk: ControlSpec(0.005, 5, \exp),
    dec: ControlSpec(0.005, 5, \exp), sus: ControlSpec(0, 1, \lin), rls: ControlSpec(0.01, 8, \exp),
    fx: ControlSpec(0, 1, \lin), mute: ControlSpec(0, 1, \lin, 1), min: ControlSpec(0, 127, \lin, 1),
    max: ControlSpec(0, 127, \lin, 1), delMix: ControlSpec(0, 1, \lin), verbMix: ControlSpec(0, 1, \lin),
    delTime: ControlSpec(0.02, 1, \exp), revTime: ControlSpec(0.2, 8, \exp), masterVol: ControlSpec(0, 1.5, \lin)
);
~ccVals = ();
3.do { |i| ~zoneDefaults[i].keysValuesDo { |k, v| ~ccVals[(k ++ (i + 1)).asSymbol] = v } };
~groupDefaults.keysValuesDo { |k, v| ~ccVals[k] = v };

// MIDI auto-detection with hardware fallback
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
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    // Control buses, groups and audio bus
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~synthBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zArgs = { |z|
        var a = [];
        ~synthKeys.do { |k| a = a ++ [k, ~buses[(k ++ z).asSymbol].asMap] };
        a
    };

    // Zone 1: sub-bass with Moog ladder and fold drive
    SynthDef(\subZone, { |out=0, freq=55, gate=1, vel=1, vol=0.25, pan=0, hpf=30, lpf=900, rq=0.5, atk=0.01, dec=0.4, sus=0.8, rls=0.8, fx=0|
        var env, fq, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        fq = Lag.kr(freq, 0.15);
        sig = Saw.ar(fq * [1, 1.004]) * 0.5 + (Pulse.ar(fq * 0.5, 0.4) * 0.3);
        sig = MoogFF.ar(sig, lpf.clip(40, 18000), rq * 3.5);
        sig = (sig * (1 + (fx * 5))).tanh * (1 / (1 + (fx * 0.5)));
        sig = HPF.ar(sig, hpf);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, vol * env * vel) } { Pan2.ar(sig, pan, vol * env * vel) });
    }).add;

    // Zone 2: Lissajous lead, phase-rotating stereo figures with FM and folding
    SynthDef(\lissa, { |out=0, freq=220, gate=1, vel=1, vol=0.22, pan=(-0.35), hpf=120, lpf=6000, rq=0.3, atk=0.02, dec=0.6, sus=0.6, rls=1.2, fx=0|
        var env, rot, x, y, sig;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        rot = SinOsc.kr(0.11).range(0, 6.2832);
        x = SinOsc.ar(freq + (SinOsc.ar(freq * 2.01) * fx * freq * 2));
        y = SinOsc.ar(freq * 1.5, rot) + (SinOsc.ar(freq * 3.01) * fx * 0.3);
        sig = [x, y] * (1 + (fx * 3));
        sig = Fold.ar(sig * 0.7, -0.8, 0.8);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000), rq.clip(0.05, 1));
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, vol * env * vel) } { Pan2.ar(sig, pan, vol * env * vel) });
    }).add;

    // Zone 3: detuned phosphor pad with allpass ghost trails
    SynthDef(\phos, { |out=0, freq=110, gate=1, vel=1, vol=0.18, pan=0.35, hpf=160, lpf=3000, rq=0.2, atk=1.5, dec=1.0, sus=0.7, rls=3.0, fx=0|
        var env, sig, ghost;
        env = EnvGen.ar(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        sig = Splay.ar(Saw.ar(freq * [0.995, 1, 1.005, 1.01]) * 0.25);
        ghost = AllpassC.ar(sig, 0.2, (fx * 0.15) + 0.01, 1.5);
        sig = sig + (ghost * fx);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000), rq.clip(0.05, 1));
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, vol * env * vel) } { Pan2.ar(sig, pan, vol * env * vel) });
    }).add;

    // Master: delay, reverb, safety limiter
    SynthDef(\masterFx, { |in=0, out=0, delMix=0, verbMix=0, delTime=0.3, revTime=2.0, vol=0.9|
        var sig;
        sig = In.ar(in, 2);
        sig = sig + (CombL.ar(sig, 1.0, delTime.clip(0.02, 1.0), 2.0) * delMix);
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix.clip(0, 1), (revTime / 8).clip(0.1, 0.98), 0.5);
        Out.ar(out, Limiter.ar(LeakDC.ar(sig * vol), 0.92, 0.01));
    }).add;
    s.sync;

    ~masterSynth = Synth(\masterFx, [
        \in, ~synthBus.index, \out, 0,
        \delMix, ~buses[\delMix].asMap, \verbMix, ~buses[\verbMix].asMap,
        \delTime, ~buses[\delTime].asMap, \revTime, ~buses[\revTime].asMap,
        \vol, ~buses[\masterVol].asMap
    ], ~masterGroup, \addToTail);

    // Overlapping zone note-on
    MIDIdef.noteOn(\noteOnZones, { |vel, noteNum|
        3.do { |i|
            var z = i + 1;
            var lo = ~ccVals[("min" ++ z).asSymbol];
            var hi = ~ccVals[("max" ++ z).asSymbol];
            if((noteNum >= lo) and: { noteNum <= hi } and: { ~ccVals[("mute" ++ z).asSymbol] < 0.5 }) {
                var syn = Synth(~zoneDefs[i], [\freq, noteNum.midicps, \gate, 1, \vel, vel / 127, \out, ~synthBus.index] ++ ~zArgs.value(z), ~synthGroup);
                ~zoneNotes[i][noteNum] = ~zoneNotes[i][noteNum].add(syn);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\noteOffZones, { |vel, noteNum|
        3.do { |i|
            ~zoneNotes[i][noteNum].do { |sy| sy.set(\gate, 0) };
            ~zoneNotes[i][noteNum] = [];
        };
    }, srcID: ~myUid);

    // Panic: release all zone voices
    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            3.do { |i|
                ~zoneNotes[i].do { |arr| arr.do { |sy| sy.set(\gate, 0) } };
                ~zoneNotes[i] = Array.fill(128, { [] });
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Loop-driven CC mapping
    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum and: { ~ccVals.includesKey(key) }) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // Paginated GUI
    defer {
        var scr = Window.availableBounds;
        var winW = 540;
        var winH = min(780, scr.height - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~ui = ();
        ~pages = [];
        ~mainWin = Window("Cabinet Lissajous", Rect((scr.width - winW) / 2, (scr.height - winH) / 2, winW, winH), scroll: true);
        4.do { |pgIdx|
            var btn = Button(~mainWin, Rect(10 + (pgIdx * 130), 8, 122, 30));
            btn.states_([[~pageTitles[pgIdx], Color.white, Color.gray(0.2)]]);
            btn.action_({ ~pages.do { |p, j| p.visible = (j == pgIdx) } });
        };
        ~zoneMeta.do { |zm, pgIdx|
            var page = CompositeView(~mainWin, Rect(10, 50, winW - 20, winH - 100));
            page.visible = (pgIdx == 0);
            ~pages = ~pages.add(page);
            ~paramKeys.do { |pk, j|
                var key = (pk ++ (pgIdx + 1)).asSymbol;
                var lbl = pk.asString ++ "  CC" ++ ~cc[key].asString ++ (if(pk == \fx) { "  [" ++ zm[\fxLabel] ++ "]" } { "" });
                var sl = EZSlider(page, Rect(10, 10 + (j * 36), winW - 50, 30), lbl, ~specs[pk], { |sl2|
                    var v = sl2.value;
                    ~ccVals[key] = v;
                    ~buses[key].set(v);
                }, ~ccVals[key]);
                ~ui[key] = sl;
            };
        };
        {
            var mpage = CompositeView(~mainWin, Rect(10, 50, winW - 20, winH - 100));
            mpage.visible = false;
            ~pages = ~pages.add(mpage);
            [\delMix, \verbMix, \delTime, \revTime, \masterVol].do { |k, j|
                var sl = EZSlider(mpage, Rect(10, 10 + (j * 36), winW - 50, 30), k.asString ++ "  CC" ++ ~cc[k].asString, ~specs[k], { |sl2|
                    var v = sl2.value;
                    ~ccVals[k] = v;
                    ~buses[k].set(v);
                }, ~ccVals[k]);
                ~ui[k] = sl;
            };
        }.value;
        Button(~mainWin, Rect(10, winH - 40, 200, 30)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({
            3.do { |i|
                ~zoneNotes[i].do { |arr| arr.do { |sy| sy.set(\gate, 0) } };
                ~zoneNotes[i] = Array.fill(128, { [] });
            };
        });
        ~mainWin.front;
    };

    // Compact 20fps AppClock poller
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
});
)


// ============================================================
// ROUND 06 | MODE: DESIGN | FRAG #86
// STATUS: PASS
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
{
// Step 0: CC map
~cc = (
    vol1: 1, pan1: 2, mute1: 3, min1: 4, max1: 5, hpf1: 6, lpf1: 7, rq1: 8, atk1: 9, dec1: 10, sus1: 11, rls1: 12, fx1: 13,
    vol2: 14, pan2: 15, mute2: 16, min2: 17, max2: 18, hpf2: 19, lpf2: 20, rq2: 21, atk2: 22, dec2: 23, sus2: 24, rls2: 25, fx2: 26,
    vol3: 27, pan3: 28, mute3: 29, min3: 30, max3: 31, hpf3: 32, lpf3: 33, rq3: 34, atk3: 35, dec3: 36, sus3: 37, rls3: 38, fx3: 39,
    delMix: 40, verbMix: 41, delTime: 42, revTime: 43, masterVol: 44, panic: 45
);

// MIDI auto-detection with fallback
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
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

~pageTitles = ["Corda 1 Berimbau", "Corda 2 Dobrão", "Corda 3 Caxixi", "Master FX"];
~zoneMeta = [
    (title: "Verga (Corpo)", fxKey: \fx1, fxLabel: "Arame Vibrato"),
    (title: "Dobrão (Metal)", fxKey: \fx2, fxLabel: "Buzz Metálico"),
    (title: "Caxixi (Chocalho)", fxKey: \fx3, fxLabel: "Grão Sêmola")
];
~paramKeys = [\vol, \pan, \mute, \min, \max, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, \fx];
~specs = (
    vol: [0, 1, \lin, 0, 0.25].asSpec, pan: [-1, 1, \lin, 0, 0].asSpec,
    mute: [0, 1, \lin, 1, 0].asSpec, min: [0, 127, \lin, 1, 0].asSpec, max: [0, 127, \lin, 1, 127].asSpec,
    hpf: [20, 4000, \exp, 0, 40].asSpec, lpf: [200, 18000, \exp, 0, 12000].asSpec,
    rq: [0.05, 1, \exp, 0, 0.4].asSpec, atk: [0.001, 2, \exp, 0, 0.002].asSpec,
    dec: [0.01, 4, \exp, 0, 0.6].asSpec, sus: [0, 1, \lin, 0, 0.3].asSpec, rls: [0.01, 5, \exp, 0, 0.5].asSpec,
    fx: [0, 1, \lin, 0, 0].asSpec, delMix: [0, 1, \lin, 0, 0].asSpec, verbMix: [0, 1, \lin, 0, 0].asSpec,
    delTime: [0.02, 1, \exp, 0, 0.3].asSpec, revTime: [0.2, 8, \exp, 0, 2].asSpec, masterVol: [0, 1, \lin, 0, 0.8].asSpec
);

s.waitForBoot({
    var ccDefaults;
    ~ccVals = ();
    ~cc.keysDo { |k| ~ccVals[k] = 0.0 };
    ~ccVals.keysDo { |k| ~ccVals[k] = 0.0 };
    [\vol1, \vol2, \vol3].do { |k| ~ccVals[k] = 0.25 };
    [\pan1, \pan2, \pan3].do { |k, i| ~ccVals[k] = [0.0, -0.35, 0.35][i] };
    [\mute1, \mute2, \mute3].do { |k| ~ccVals[k] = 0.0 };
    [\min1, \min2, \min3].do { |k| ~ccVals[k] = 0 };
    [\max1, \max2, \max3].do { |k| ~ccVals[k] = 127 };
    ~ccVals[\hpf1] = 40; ~ccVals[\hpf2] = 180; ~ccVals[\hpf3] = 1200;
    ~ccVals[\lpf1] = 3200; ~ccVals[\lpf2] = 6500; ~ccVals[\lpf3] = 9000;
    ~ccVals[\rq1] = 0.4; ~ccVals[\rq2] = 0.4; ~ccVals[\rq3] = 0.4;
    ~ccVals[\atk1] = 0.002; ~ccVals[\atk2] = 0.002; ~ccVals[\atk3] = 0.002;
    ~ccVals[\dec1] = 0.6; ~ccVals[\dec2] = 0.35; ~ccVals[\dec3] = 0.12;
    ~ccVals[\sus1] = 0.3; ~ccVals[\sus2] = 0.2; ~ccVals[\sus3] = 0.0;
    ~ccVals[\rls1] = 0.5; ~ccVals[\rls2] = 0.4; ~ccVals[\rls3] = 0.2;
    ~ccVals[\delTime] = 0.3; ~ccVals[\revTime] = 2.0; ~ccVals[\masterVol] = 0.8;
    ~ccVals[\fx1] = 0.0; ~ccVals[\fx2] = 0.0; ~ccVals[\fx3] = 0.0;
    ~ccVals[\delMix] = 0.0; ~ccVals[\verbMix] = 0.0;

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { [] }) ! 3;

    // Berimbau string voice: stiff wire pluck, gourd resonance, bow-stick pluck
    SynthDef(\berimbau, { |out=0, freq=110, amp=0.5, gate=1, pan=0, zone=1,
        vol=0.25, mute=0, hpf=40, lpf=3200, rq=0.4, atk=0.002, dec=0.6, sus=0.3, rls=0.5,
        fx=0, dry=1|
        var exc, body, sig, env, bodyFreqs, bodyAmps, bodyRings, wob;
        var noiseTone;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        // Baqueta strike: short noisy click
        exc = WhiteNoise.ar(0.6) * EnvGen.ar(Env.perc(0.0005, 0.012));
        // Wire string: Karplus-like comb excitation with wire buzz (fx)
        wob = SinOsc.kr(5.5 + (fx * 4)).range(1 - (fx * 0.02), 1 + (fx * 0.02));
        body = CombL.ar(exc, 0.1, (freq * wob).reciprocal.clip(0.0001, 0.1), 0.02 + (dec * 2.5));
        // Gourd (cabaça) resonator: DynKlank bank
        bodyFreqs = [freq * 1.0, freq * 2.76, freq * 5.4, freq * 8.93];
        bodyAmps = [0.8, 0.25, 0.1, 0.05];
        bodyRings = [0.9, 0.5, 0.25, 0.12];
        sig = DynKlank.ar(Ref([bodyFreqs, bodyAmps, bodyRings]), body, decayscale: 1 + dec);
        // Wire buzz saturation (fxBuzz)
        sig = (sig * (1.0 + (fx * 3.0))).tanh;
        sig = HPF.ar(sig, hpf);
        sig = RLPF.ar(sig, lpf, rq);
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, Balance2.ar(sig, sig, pan));
    }).add;

    // Caxixi: granular seed shaker (rattle grain texture)
    SynthDef(\caxixi, { |out=0, amp=0.5, gate=1, pan=0, vol=0.25, mute=0,
        hpf=1200, lpf=9000, rq=0.4, atk=0.002, dec=0.12, sus=0, rls=0.2, fx=0|
        var env, grains, sig, rate;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        rate = 60 + (fx * 200);
        grains = Dust.ar(rate) * WhiteNoise.ar(0.8);
        sig = BPF.ar(grains, 3800 + (fx * 2000), 0.6) * 4.0;
        sig = HPF.ar(sig, hpf);
        sig = RLPF.ar(sig, lpf, rq);
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, Balance2.ar(sig, sig, pan));
    }).add;

    // Dobrão: metal coin strike ring
    SynthDef(\dobrao, { |out=0, freq=1800, amp=0.5, gate=1, pan=0, vol=0.25, mute=0,
        hpf=180, lpf=6500, rq=0.4, atk=0.002, dec=0.35, sus=0.2, rls=0.4, fx=0|
        var env, exc, sig, rings;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = WhiteNoise.ar(0.4) * EnvGen.ar(Env.perc(0.0003, 0.008));
        rings = DynKlank.ar(Ref([[freq, freq * 2.51, freq * 3.37], [1, 0.4, 0.2], [0.5, 0.3, 0.2]]), exc);
        sig = (rings * (1.0 + (fx * 2.0))).tanh;
        sig = HPF.ar(sig, hpf);
        sig = RLPF.ar(sig, lpf, rq);
        sig = sig * env * amp * vol * (1 - mute);
        Out.ar(out, Balance2.ar(sig, sig, pan));
    }).add;

    // Master group FX: delay/reverb + limiter
    SynthDef(\masterFx, { |inBus=0, delMix=0, verbMix=0, delTime=0.3, revTime=2, masterVol=0.8|
        var sig, del, verb;
        sig = In.ar(inBus, 2);
        del = CombL.ar(sig, 1.0, delTime, revTime * 0.5) * delMix;
        verb = FreeVerb.ar(sig, 1, 0.6, 0.4) * verbMix;
        sig = (sig + del + verb) * masterVol;
        sig = LeakDC.ar(sig);
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;

    s.sync;

    ~masterSynth = Synth.new(\masterFx, [
        \inBus, 0,
        \delMix, ~buses[\delMix].asMap,
        \verbMix, ~buses[\verbMix].asMap,
        \delTime, ~buses[\delTime].asMap,
        \revTime, ~buses[\revTime].asMap,
        \masterVol, ~buses[\masterVol].asMap
    ], ~masterGroup, \addToTail);

    // Note playing: zones overlap
    MIDIdef.noteOn(\zoneOn, { |vel, noteNum|
        var amp = vel / 127.0;
        var zoneSynth, zoneIdx;
        // Zone 1: Verga (low body)
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[0][noteNum] = ~zoneNotes[0][noteNum].add(
                Synth(\berimbau, [
                    \freq, noteNum.midicps, \amp, amp, \pan, ~ccVals[\pan1],
                    \vol, ~buses[\vol1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap,
                    \rq, ~buses[\rq1].asMap, \atk, ~buses[\atk1].asMap,
                    \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap,
                    \rls, ~buses[\rls1].asMap, \fx, ~buses[\fx1].asMap
                ], ~synthGroup, \addToTail)
            );
        };
        // Zone 2: Dobrão (metal ring)
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[1][noteNum] = ~zoneNotes[1][noteNum].add(
                Synth(\dobrao, [
                    \freq, noteNum.midicps, \amp, amp, \pan, ~ccVals[\pan2],
                    \vol, ~buses[\vol2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap,
                    \rq, ~buses[\rq2].asMap, \atk, ~buses[\atk2].asMap,
                    \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap,
                    \rls, ~buses[\rls2].asMap, \fx, ~buses[\fx2].asMap
                ], ~fxGroup, \addToTail)
            );
        };
        // Zone 3: Caxixi (seed shaker)
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zoneNotes[2][noteNum] = ~zoneNotes[2][noteNum].add(
                Synth(\caxixi, [
                    \amp, amp, \pan, ~ccVals[\pan3],
                    \vol, ~buses[\vol3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap,
                    \rq, ~buses[\rq3].asMap, \atk, ~buses[\atk3].asMap,
                    \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap,
                    \rls, ~buses[\rls3].asMap, \fx, ~buses[\fx3].asMap
                ], ~fxGroup, \addToTail)
            );
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\zoneOff, { |vel, noteNum|
        3.do { |i|
            ~zoneNotes[i][noteNum].do { |sy| sy.set(\gate, 0) };
            ~zoneNotes[i][noteNum] = [];
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            3.do { |i|
                ~zoneNotes[i].do { |arr| arr.do { |sy| sy.set(\gate, 0) } };
                ~zoneNotes[i] = Array.fill(128, { [] });
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum and: { ~ccVals.includesKey(key) }) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    defer {
        var scr = Window.availableBounds;
        var winW = 540;
        var winH = min(780, scr.height - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~ui = ();
        ~pages = [];
        ~mainWin = Window("Berimbau de Barriga", Rect((scr.width - winW) / 2, (scr.height - winH) / 2, winW, winH), scroll: true);
        4.do { |pgIdx|
            var btn = Button(~mainWin, Rect(10 + (pgIdx * 130), 8, 122, 30));
            btn.states_([[~pageTitles[pgIdx], Color.white, Color.gray(0.2)]]);
            btn.action_({ ~pages.do { |p, j| p.visible = (j == pgIdx) } });
        };
        ~zoneMeta.do { |zm, pgIdx|
            var page = CompositeView(~mainWin, Rect(10, 50, winW - 20, winH - 100));
            page.visible = (pgIdx == 0);
            ~pages = ~pages.add(page);
            ~paramKeys.do { |pk, j|
                var key = (pk ++ (pgIdx + 1)).asSymbol;
                var lbl = pk.asString ++ "  CC" ++ ~cc[key].asString ++ (if(pk == \fx) { "  [" ++ zm[\fxLabel] ++ "]" } { "" });
                var sl = EZSlider(page, Rect(10, 10 + (j * 36), winW - 50, 30), lbl, ~specs[pk], { |sl2|
                    var v = sl2.value;
                    ~ccVals[key] = v;
                    ~buses[key].set(v);
                }, ~ccVals[key]);
                ~ui[key] = sl;
            };
        };
        {
            var mpage = CompositeView(~mainWin, Rect(10, 50, winW - 20, winH - 100));
            mpage.visible = false;
            ~pages = ~pages.add(mpage);
            [\delMix, \verbMix, \delTime, \revTime, \masterVol].do { |k, j|
                var sl = EZSlider(mpage, Rect(10, 10 + (j * 36), winW - 50, 30), k.asString ++ "  CC" ++ ~cc[k].asString, ~specs[k], { |sl2|
                    var v = sl2.value;
                    ~ccVals[k] = v;
                    ~buses[k].set(v);
                }, ~ccVals[k]);
                ~ui[k] = sl;
            };
        }.value;
        Button(~mainWin, Rect(10, winH - 40, 200, 30)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({
            3.do { |i|
                ~zoneNotes[i].do { |arr| arr.do { |sy| sy.set(\gate, 0) } };
                ~zoneNotes[i] = Array.fill(128, { [] });
            };
        });
        ~mainWin.front;
    };

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
});
}.value;
)


// ============================================================
// ROUND 07 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: gungas metálicas, tambores de caixa e bordão grave
Ndef(\congada_gunga).fadeTime = 0.8;
Ndef(\congada_tambor).fadeTime = 0.8;
Ndef(\congada_bordao).fadeTime = 3;

Ndef(\congada_gunga, { |t_trig=0, amp=0.16, pan=(-0.3), cut=6500, rq=0.3|
    var env, noise, metal, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, 0.12);
    noise = WhiteNoise.ar(env);
    metal = Ringz.ar(noise, [3150, 4710, 6230, 7980] * (1 + SinOsc.kr(0.07).range(0, 0.01)), [0.05, 0.04, 0.03, 0.02]).sum;
    sig = (metal * 0.35 + HPF.ar(noise, 3000) * 0.2).tanh;
    sig = BPF.ar(sig, cut, rq) * 8 + (sig * 0.3);
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Ndef(\congada_tambor, { |t_trig=0, amp=0.20, pan=0.2, tone=110|
    var pitchEnv, env, body, click, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.003, 0.38);
    pitchEnv = Decay2.ar(K2A.ar(t_trig), 0.001, 0.06);
    body = SinOsc.ar(tone * (1 + (pitchEnv * 2))) * env;
    click = BPF.ar(WhiteNoise.ar, 2500, 0.5) * Decay2.ar(K2A.ar(t_trig), 0.0005, 0.012) * 2;
    sig = (body + click).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congada_bordao, { |amp=0.10, rate=0.25|
    var sub, harm, pulse, sig;
    sub = SinOsc.ar(55) * 0.6;
    harm = SinOsc.ar(110, 0, 0.12);
    pulse = SinOsc.kr(rate).range(0.6, 1.0);
    sig = (sub + harm) * pulse;
    sig = LPF.ar(sig, 400);
    Balance2.ar(sig, sig, 0, amp);
}).play;

Ndef(\congada_gunga)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.7, 0.5);
};
Ndef(\congada_gunga).set(\wet10, 0.25);

Ndef(\congada_tambor)[10] = \filter -> { |in|
    var mono = in.sum;
    GVerb.ar(mono, 20, 2.5, 0.4, 0.5, 15, 1, 0.5, 0.3).dup;
};
Ndef(\congada_tambor).set(\wet10, 0.15);

Pbindef(\gungaSeq,
    \t_trig, 1,
    \dur, Pwrand([0.25, 0.5, 0.125], [0.6, 0.3, 0.1], inf),
    \amp, Pexprand(0.10, 0.20, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \cut, Pexprand(4000, 8000, inf)
);

Pbindef(\tamborSeq,
    \t_trig, 1,
    \dur, Pseq([1, 0.5, 0.5, 1, 0.75, 0.25], inf),
    \amp, Pexprand(0.12, 0.22, inf),
    \pan, Pseq([0.2, -0.2, 0.3, -0.3], inf),
    \tone, Pseq([110, 82.4, 110, 146.8], inf)
);

Ndef(\congada_gunga).quant = 1;
Ndef(\congada_tambor).quant = 1;
Ndef(\congada_gunga)[1] = \set -> Pbindef(\gungaSeq);
Ndef(\congada_tambor)[1] = \set -> Pbindef(\tamborSeq);
)

// Ndef(\congada_gunga).xset(\cut, 2200); // Escurecer metal | Revert: Ndef(\congada_gunga).xset(\cut, 6500);
// Pbindef(\gungaSeq, \dur, 0.125); // Gunga em dobro | Revert: Pbindef(\gungaSeq, \dur, 0.25);
// Pbindef(\tamborSeq, \tone, Pseq([82.4, 73.4], inf)); // Bordão grave | Revert: Pbindef(\tamborSeq, \tone, Pseq([110, 82.4, 110, 146.8], inf));
// Ndef(\congada_tambor).set(\wet10, 0.4); // Mais reverb | Revert: Ndef(\congada_tambor).set(\wet10, 0.15);
// Pbindef(\gungaSeq).stop; Ndef(\congada_gunga).clear(4); // Rollback gungas
// Pbindef(\tamborSeq).stop; Ndef(\congada_tambor).clear(4); // Rollback tambores
// Ndef(\congada_bordao).xset(\amp, 0.0); // Silenciar bordão | Revert: Ndef(\congada_bordao).xset(\amp, 0.10);


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #173
// STATUS: PASS
// PROMPT: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido n...
// ============================================================
(
// Pantanal ao crepúsculo: pad de pôr do sol, corixo com gotas e araras em revoada
Ndef(\pant_pad).fadeTime = 4;
Ndef(\pant_corixo).fadeTime = 3;
Ndef(\pant_araras).fadeTime = 1;

// Camada 1: pad harmônico morno, filtro Moog com varredura lenta do pôr do sol
Ndef(\pant_pad, { |amp=0.10, cut=900, gain=1.5, drift=0.2|
    var lfo, sig;
    lfo = SinOsc.kr(drift * 0.05).range(0.5, 1.0);
    sig = Splay.ar(Saw.ar(55 * [1, 1.004, 0.997, 2.01]) * 0.2);
    sig = MoogFF.ar(sig, cut * lfo, gain);
    (sig * amp * 3).tanh;
}).play;

// Camada 2: corixo, ruído rosa filtrado e gotas ressonantes em camalotes
Ndef(\pant_corixo, { |amp=0.07, rate=0.1|
    var gust, drops, sig;
    gust = LPF.ar(PinkNoise.ar, 300 + SinOsc.kr(rate).range(0, 150)) * 0.5;
    drops = Ringz.ar(Dust.ar(4), [380, 560, 910, 1320], [0.08, 0.06, 0.05, 0.04]).sum;
    sig = gust + (drops * 0.4);
    Pan2.ar(sig.tanh, SinOsc.kr(0.03).range(-0.5, 0.5), amp);
}).play;

// Camada 3: grasnados de araras-azuis, FM disparada por trigger
Ndef(\pant_araras, { |t_trig=0, amp=0.14, pan=0.5, freq=900|
    var env, modEnv, mod, vib, car;
    env = Decay2.ar(K2A.ar(t_trig), 0.02, 0.45);
    modEnv = Decay2.ar(K2A.ar(t_trig), 0.005, 0.2);
    vib = 1 + (SinOsc.kr(6) * 0.02);
    mod = SinOsc.ar(freq * 2.71 * vib) * (freq * 1.8 * modEnv);
    car = SinOsc.ar((freq * vib) + mod) * env;
    Pan2.ar(car.tanh, pan, amp);
}).play;

// Reverberação de ambiente aberto (wet externo)
Ndef(\pant_pad)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.4);
};
Ndef(\pant_pad).set(\wet10, 0.3);

Ndef(\pant_araras)[10] = \filter -> { |in|
    var mono = in.sum;
    GVerb.ar(mono, 30, 3.0, 0.5, 0.5, 15, 1, 0.5, 0.3).dup;
};
Ndef(\pant_araras).set(\wet10, 0.25);

// Padrão infinito de revoada: intervalos irregulares, alturas e pan aleatórios
Pbindef(\pantArarasSeq,
    \t_trig, 1,
    \dur, Pwrand([0.5, 1, 2.5, 0.25], [0.35, 0.35, 0.15, 0.15], inf),
    \freq, Pexprand(600, 1400, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pexprand(0.08, 0.14, inf)
);

Ndef(\pant_araras).quant = 1;
Ndef(\pant_araras)[1] = \set -> Pbindef(\pantArarasSeq);
)

// Ndef(\pant_pad).xset(\cut, 1800); // Sol mais alto | Revert: Ndef(\pant_pad).xset(\cut, 900);
// Pbindef(\pantArarasSeq, \dur, Pwrand([0.25, 0.5], [0.6, 0.4], inf)); // Revoada agitada | Revert: Pbindef(\pantArarasSeq, \dur, Pwrand([0.5, 1, 2.5, 0.25], [0.35, 0.35, 0.15, 0.15], inf));
// Ndef(\pant_araras).set(\wet10, 0.5); // Mais eco nas araras | Revert: Ndef(\pant_araras).set(\wet10, 0.25);
// Ndef(\pant_corixo).xset(\rate, 0.3); // Água mais agitada | Revert: Ndef(\pant_corixo).xset(\rate, 0.1);
// Ndef(\pant_pad).stop; Ndef(\pant_pad).clear(6); // Rollback pad
// Pbindef(\pantArarasSeq).stop; Ndef(\pant_araras).clear(3); // Rollback araras
// Ndef(\pant_corixo).clear(4); // Rollback corixo

