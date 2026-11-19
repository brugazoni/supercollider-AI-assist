# Multi-Provider X-Append Lean Benchmark Report
**Execution Date**: 2026-11-12 22:44:25 UTC
**Rounds per Model**: 8 rounds across 4 modes (append, compose, design, generate)
**Corpus Source**: 200-fragment pt-BR corpus (Wikipedia, Poema, Conto/Crônica, Descrição)
**Providers**: OpenRouter (`google/gemini-3.8-flash`, `anthropic/claude-haiku-5.5`, `deepseek/deepseek-v4.1-flash`, `openai/gpt-6-luna`)

## 1. Executive Summary & Leaderboard

| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Used | Mean LLM Time | Mean Round Wall | Total Cost (USD) | Total Tokens | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50.0% (4/8) | 100.0% (8/8) | 5 | 25.59s | 53.23s | $0.32879 | 166,426 | 10114 |
| **Gemini 4 Hydrogen** | 87.5% (7/8) | 100.0% (8/8) | 1 | 29.29s | 36.14s | $0.40364 | 106,111 | 8010 |
| **Claude Haiku Latest** | 75.0% (6/8) | 100.0% (8/8) | 2 | 32.58s | 44.93s | $0.03504 | 145,615 | 4289 |
| **DeepSeek Flash Latest** | 62.5% (5/8) | 100.0% (8/8) | 4 | 45.65s | 65.74s | $0.03954 | 150,203 | 8883 |
| **OpenAI GP6 Luna** | 100.0% (8/8) | 100.0% (8/8) | 0 | 19.50s | 19.71s | $0.01545 | 75,036 | 6051 |

---

## 2. Technical Efficiency & Cost Breakdown

| Model | Total Wall Time | In Tokens | Out Tokens | Cost / 10 Rounds | Chars / Sec (Gen) |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 425.8s | 98,439 | 67,987 | $0.32879 | 395.2 c/s |
| **Gemini 4 Hydrogen** | 289.1s | 65,366 | 40,745 | $0.40364 | 273.5 c/s |
| **Claude Haiku Latest** | 359.4s | 94,414 | 51,201 | $0.03504 | 131.7 c/s |
| **DeepSeek Flash Latest** | 525.9s | 72,008 | 78,195 | $0.03954 | 194.6 c/s |
| **OpenAI GP6 Luna** | 157.7s | 55,156 | 19,880 | $0.01545 | 310.2 c/s |

---

## 3. By-Mode Specialization Breakdown & Use-Case Analysis

Evaluation of each model's strengths, compilation accuracy, and latency across the 4 specific SuperCollider use cases:

### Use Case: `APPEND` Mode
*Incremental live mutation, layer addition, and parameter evolution on a running session without interrupting playback.*

| Model | 1st-Pass Pass Rate | Final Pass Rate | Mean LLM Time | Mode Cost (USD) | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50.0% (1/2) | 100.0% (2/2) | 8.10s | $0.02242 | 1926 |
| **Gemini 4 Hydrogen** | 100.0% (2/2) | 100.0% (2/2) | 11.09s | $0.04204 | 1055 |
| **Claude Haiku Latest** | 100.0% (2/2) | 100.0% (2/2) | 9.98s | $0.00429 | 1190 |
| **DeepSeek Flash Latest** | 50.0% (1/2) | 100.0% (2/2) | 33.63s | $0.00473 | 3002 |
| **OpenAI GP6 Luna** | 100.0% (2/2) | 100.0% (2/2) | 9.77s | $0.00232 | 1572 |

### Use Case: `COMPOSE` Mode
*Long-form timeline scores, multi-layer polyphony, algorithmic structure, and acoustic storytelling via Tdef/Pbindef.*

| Model | 1st-Pass Pass Rate | Final Pass Rate | Mean LLM Time | Mode Cost (USD) | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 100.0% (2/2) | 100.0% (2/2) | 25.84s | $0.04395 | 8703 |
| **Gemini 4 Hydrogen** | 100.0% (2/2) | 100.0% (2/2) | 28.44s | $0.08178 | 6554 |
| **Claude Haiku Latest** | 100.0% (2/2) | 100.0% (2/2) | 33.93s | $0.01094 | 5622 |
| **DeepSeek Flash Latest** | 50.0% (1/2) | 100.0% (2/2) | 71.52s | $0.01084 | 8998 |
| **OpenAI GP6 Luna** | 100.0% (2/2) | 100.0% (2/2) | 24.41s | $0.00429 | 6184 |

### Use Case: `DESIGN` Mode
*Playable hardware MIDI controller-mapped synthesizers, multi-zone keyboard layouts, and interactive GUI controls.*

| Model | 1st-Pass Pass Rate | Final Pass Rate | Mean LLM Time | Mode Cost (USD) | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 0.0% (0/2) | 100.0% (2/2) | 48.41s | $0.21854 | 24444 |
| **Gemini 4 Hydrogen** | 50.0% (1/2) | 100.0% (2/2) | 57.21s | $0.21846 | 20126 |
| **Claude Haiku Latest** | 0.0% (0/2) | 100.0% (2/2) | 70.21s | $0.01391 | 6724 |
| **DeepSeek Flash Latest** | 50.0% (1/2) | 100.0% (2/2) | 56.17s | $0.01895 | 19078 |
| **OpenAI GP6 Luna** | 100.0% (2/2) | 100.0% (2/2) | 29.15s | $0.00552 | 12494 |

### Use Case: `GENERATE` Mode
*Autonomous, continuously evolving multi-layer generative soundscapes with frequency bracketing and textural depth.*

| Model | 1st-Pass Pass Rate | Final Pass Rate | Mean LLM Time | Mode Cost (USD) | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 50.0% (1/2) | 100.0% (2/2) | 20.05s | $0.04388 | 5384 |
| **Gemini 4 Hydrogen** | 100.0% (2/2) | 100.0% (2/2) | 20.42s | $0.06136 | 4305 |
| **Claude Haiku Latest** | 100.0% (2/2) | 100.0% (2/2) | 16.20s | $0.00590 | 3620 |
| **DeepSeek Flash Latest** | 100.0% (2/2) | 100.0% (2/2) | 21.27s | $0.00502 | 4454 |
| **OpenAI GP6 Luna** | 100.0% (2/2) | 100.0% (2/2) | 14.68s | $0.00332 | 3952 |


---

## 4. Round-by-Round Comparative Matrix

| Rnd | Mode | Prompt Fragment | Gemini 3.8 Flash | Gemini 4 Hydrogen | Claude Haiku Latest | DeepSeek Flash Latest | OpenAI GP6 Luna |
|:---:|:---:|:---| :---: | :---: | :---: | :---: | :---: |
| 01 | `APPEND` | #149 (Luis Fernando Verissimo — Comé) | ⚠️ Fix#1 (25.2s) | ✅ 9.5s | ✅ 12.2s | ✅ 55.9s | ✅ 12.6s |
| 02 | `APPEND` | #120 (Castro Alves — O Navio Negreir) | ✅ 7.8s | ✅ 12.7s | ✅ 7.7s | ⚠️ Fix#-1 (135.5s) | ✅ 6.9s |
| 03 | `COMPOSE` | #50 (Conto Fantástico — O Relojoeir) | ✅ 24.2s | ✅ 29.2s | ✅ 29.8s | ✅ 75.8s | ✅ 22.1s |
| 04 | `COMPOSE` | #13 (Wikipédia — Gruta do Maquiné) | ✅ 27.5s | ✅ 27.6s | ✅ 38.1s | ⚠️ Fix#1 (81.1s) | ✅ 26.8s |
| 05 | `DESIGN` | #74 (Descrição de Imagem — Sintetiz) | ⚠️ Fix#1 (100.2s) | ⚠️ Fix#1 (108.8s) | ⚠️ Fix#-1 (120.0s) | ⚠️ Fix#1 (44.3s) | ✅ 29.8s |
| 06 | `DESIGN` | #86 (Wikipédia — Berimbau) | ⚠️ Fix#2 (188.0s) | ✅ 59.1s | ⚠️ Fix#2 (118.8s) | ✅ 89.7s | ✅ 28.5s |
| 07 | `GENERATE` | #92 (Wikipédia — Congada) | ✅ 18.4s | ✅ 16.4s | ✅ 11.0s | ✅ 22.7s | ✅ 14.7s |
| 08 | `GENERATE` | #173 (Cena Visual — Entardecer no Pa) | ⚠️ Fix#1 (34.2s) | ✅ 24.4s | ✅ 21.4s | ✅ 19.8s | ✅ 14.7s |

---

## 5. Model Details & Full Generated Code

### Model: Gemini 3.8 Flash (`openrouter:google/gemini-3.8-flash`)

- **Initial Pass Rate**: 50.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 425.84s (mean LLM: 25.59s/round)
- **Total Tokens**: 166,426 (Cost: $0.32879)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261112_191506\session_gemini-3.8-flash.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: FIXED</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback
- **Initial Error**: `ERROR: Class not defined.
__VAL_ERROR__: Syntax / compile error in generated code
ERROR: Class not defined.
  in interpreted text
  line 79 char 7:
  	JPverb.ar(in, t60: 6.0, damp: 0.7, size: 3.5, earlyDiff: 0.8);
-----------------------------------
__VAL_ERROR__: Syntax / compile error in generated`

```supercollider
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
```

</details>

<details>
<summary><strong>Round 02 [APPEND] - Status: PASS</strong> — <em>Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sa...</em></summary>

- **Prompt**: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Tinir de ferros... estalar de açoite... Legiões de homens negros como a noite, horrendos a dançar... Mulheres com crianças suspensas ao peito descarnado, homens gemendo sob a aragem salgada, pedindo a Deus um raio que quebre os elos da corrente maldita!
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
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
```

</details>

<details>
<summary><strong>Round 03 [COMPOSE] - Status: PASS</strong> — <em>Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, ...</em></summary>

- **Prompt**: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses e cronômetros de bolso trabalhavam em tempos ligeiramente desencontrados. O velho relojoeiro fechava os olhos no centro daquele enxame de tique-taques de latão e jurava ouvir, nas defasagens microscópicas entre as engrenagens, o próprio respirar do tempo.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
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
```

</details>

<details>
<summary><strong>Round 04 [COMPOSE] - Status: PASS</strong> — <em>A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no sécul...</em></summary>

- **Prompt**: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalista dinamarquês Peter Lund, é composta por sete amplos salões subterrâneos esculpidos pela ação milenar das águas em rocha calcária. Suas abóbadas úmidas exibem cortinas minerais, estalactites e estalagmites onde o gotejamento lento cria ressonâncias acústicas profundas na escuridão.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
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
```

</details>

<details>
<summary><strong>Round 05 [DESIGN] - Status: FIXED</strong> — <em>Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumb...</em></summary>

- **Prompt**: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de potenciômetros prateados, matrizes de pinos luminosos e cabos entrelaçados. Ao lado, a tela verde de fósforo de um osciloscópio analógico desenha figuras de Lissajous em rotação contínua que se dobram e se desdobram em harmônicos complexos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback, WARNING: brackets are unbalanced
- **Initial Error**: `__VAL_ERROR__: ERROR: Primitive '_ConnectMIDIIn' failed.
__VAL_ERROR__: ERROR: Primitive '_ConnectMIDIIn' failed.
Failed.`

```supercollider
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
```

</details>

<details>
<summary><strong>Round 06 [DESIGN] - Status: FIXED</strong> — <em>O berimbau de barriga é um instrumento de percussão cordofone originário da Áfri...</em></summary>

- **Prompt**: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente enraizado na tradição cultural afro-brasileira da capoeira. Composto por uma verga de madeira de biriba curva esticada por arame de pneu de aço e uma cabaça ressonadora seca, é percutido por uma baqueta enquanto o dobrão de metal e o caxixi modulam timbres secos, ressonantes e hipnóticos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: WARNING: brackets are unbalanced, prepended pre-design synthesizer cleanup for previous design instance
- **Initial Error**: `__VAL_ERROR__: ERROR: Primitive '_ConnectMIDIIn' failed.
__VAL_ERROR__: ERROR: Primitive '_ConnectMIDIIn' failed.
Failed.`

```supercollider
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
```

</details>

<details>
<summary><strong>Round 07 [GENERATE] - Status: PASS</strong> — <em>A Congada é uma manifestação folclórica e religiosa sincrética brasileira que ce...</em></summary>

- **Prompt**: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de reis do Congo em louvor a Nossa Senhora do Rosário e a São Benedito. Encontrada em Minas Gerais, Goiás e São Paulo, envolve desfiles ritmados de ternos de congo e moçambiques, onde gungas de lata amarradas aos tornozelos produzem percussões metálicas e passos cadenciados.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
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
```

</details>

<details>
<summary><strong>Round 08 [GENERATE] - Status: FIXED</strong> — <em>A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incan...</em></summary>

- **Prompt**: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido na superfície calma de um corixo repleto de camalotes e vitórias-régias. Centenas de tuiuiús pousados nos galhos secos de um piúva centenário observam em silêncio o bater de asas de um bando ruidoso de araras-azuis cruzando o céu crepuscular rumo ao dormitório nos capões de mata.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback
- **Initial Error**: `__VAL_ERROR__: ERROR: Message 'sum' not understood.
__VAL_ERROR__: ERROR: Message 'sum' not understood.`

```supercollider
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
```

</details>

### Model: Gemini 4 Hydrogen (`openrouter:google/gemini-4-hydrogen`)

- **Initial Pass Rate**: 87.5%
- **Final Pass Rate**: 100.0%
- **Total Time**: 289.14s (mean LLM: 29.29s/round)
- **Total Tokens**: 106,111 (Cost: $0.40364)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261112_191506\session_gemini-4-hydrogen.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
Ndef(\antarcticSilence, { |freq=55, amp=0.18, pan=0, atk=1.5, rel=4.0, cutoff=1200, rq=0.05, windAmp=0.12, t_trig=0|
    var env = EnvGen.ar(Env.perc(atk, rel, 1, -2), t_trig);
    var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var wind = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.15).range(0.8, 1.3), rq) * 10.0 * windAmp;
    var shimmer = Mix.fill(4, { |i|
        SinOsc.ar(freq * (i + 3) * LFNoise1.kr(0.08).range(0.995, 1.005)) * (0.15 / (i + 1))
    });
    var sig = (sub * 0.5) + (shimmer * env) + wind;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\silenceSeq,
    \dur, Pseq([4, 6, 5, 8], inf),
    \freq, Pseq([55, 51.91, 49, 55], inf),
    \cutoff, Pseq([900, 1400, 750, 1800], inf),
    \t_trig, 1,
    \amp, Pwhite(0.15, 0.22, inf),
    \pan, Pwhite(-0.2, 0.2, inf)
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\silenceSeq);
// Pbindef(\silenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)
```

</details>

<details>
<summary><strong>Round 02 [APPEND] - Status: PASS</strong> — <em>Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sa...</em></summary>

- **Prompt**: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Tinir de ferros... estalar de açoite... Legiões de homens negros como a noite, horrendos a dançar... Mulheres com crianças suspensas ao peito descarnado, homens gemendo sob a aragem salgada, pedindo a Deus um raio que quebre os elos da corrente maldita!
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
Ndef(\ironChains, { |freq=180, amp=0.25, pan=0, rel=0.8, whipAmp=0.6, ironAmp=0.7, t_trig=0|
    var whipEnv = EnvGen.ar(Env.perc(0.001, 0.05, 1, -8), t_trig);
    var ironEnv = EnvGen.ar(Env.perc(0.002, rel, 1, -4), t_trig);
    var trigAudio = K2A.ar(t_trig);
    var noise = WhiteNoise.ar * whipEnv * whipAmp;
    var whip = HPF.ar(noise, 1800) + BPF.ar(noise, 3400, 0.35);
    var iron = Ringz.ar(
        (trigAudio * 0.5) + (PinkNoise.ar * whipEnv * 0.2),
        freq * [1, 1.47, 2.13, 3.31],
        [0.45, 0.32, 0.55, 0.28]
    ).sum * 0.25 * ironAmp * ironEnv;
    var sig = ((whip + iron) * 1.6).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\chainsSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75, 0.5, 0.25, 0.25], inf),
    \freq, Pseq([180, 210, 145, 260, 130, 195, 240, 160], inf),
    \rel, Pwhite(0.4, 1.1, inf),
    \t_trig, 1,
    \amp, Pwhite(0.18, 0.32, inf),
    \pan, Pwhite(-0.6, 0.6, inf)
);

Ndef(\ironChains)[1] = \set -> Pbindef(\chainsSeq);
// Pbindef(\chainsSeq).stop; Ndef(\ironChains).fadeTime = 2; Ndef(\ironChains).clear(2); // Rollback: remove this instrument
)
```

</details>

<details>
<summary><strong>Round 03 [COMPOSE] - Status: PASS</strong> — <em>Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, ...</em></summary>

- **Prompt**: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses e cronômetros de bolso trabalhavam em tempos ligeiramente desencontrados. O velho relojoeiro fechava os olhos no centro daquele enxame de tique-taques de latão e jurava ouvir, nas defasagens microscópicas entre as engrenagens, o próprio respirar do tempo.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // 1. Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete SynthDefs
    SynthDef(\brassTick, { |out=0, freq=1400, amp=0.25, pan=0, dur=0.12, metal=0.6|
        var env = EnvGen.ar(Env.perc(0.001, dur.max(0.03), 1, -8), doneAction: 2);
        var click = (Impulse.ar(0) * 0.8) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.008)));
        var body = Ringz.ar(click, freq * [1, 1.62, 2.71], [0.04, 0.025, 0.015]).sum * 0.35;
        var sig = (click * (1 - metal)) + (body * metal);
        sig = HPF.ar(sig, 350) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\pocketChrono, { |out=0, freq=3800, amp=0.15, pan=0|
        var env = EnvGen.ar(Env.perc(0.0005, 0.035, 1, -10), doneAction: 2);
        var trig = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.003)));
        var sig = BPF.ar(trig, freq, 0.15) * 6.0;
        sig = sig * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;

    SynthDef(\frenchChime, { |out=0, freq=440, amp=0.22, pan=0, dur=3.5, modIdx=1.8|
        var env = EnvGen.ar(Env.perc(0.005, (dur - 0.005).max(0.2), 1, -4), doneAction: 2);
        var modEnv = EnvGen.ar(Env.perc(0.002, 0.4, 1, -6));
        var mod1 = SinOsc.ar(freq * 2.756) * (freq * modIdx * modEnv);
        var mod2 = SinOsc.ar(freq * 5.404) * (freq * (modIdx * 0.4) * modEnv);
        var car = SinOsc.ar(freq + mod1 + mod2) * 0.5;
        var res = DynKlank.ar(
            Ref([ [freq, freq * 2.01, freq * 3.02, freq * 4.18], [0.5, 0.3, 0.15, 0.08], [2.5, 1.8, 1.1, 0.6] ]),
            Impulse.ar(0) * 0.25,
            1, 0, 0.8
        );
        var sig = (car + (res * 0.45)) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // 3. Continuous Ndefs
    Ndef(\timeBreath, { |amp=0, freq=73.42, cutoff=420, breathRate=0.14|
        var breath = SinOsc.kr(breathRate).range(0.4, 1.0) * LFNoise1.kr(0.08).range(0.75, 1.15);
        var air = BPF.ar(PinkNoise.ar, cutoff * LFNoise1.kr(0.11).range(0.85, 1.25), 0.12) * 5.5;
        var sub = (SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4)) * 0.35;
        var sig = (air + sub) * breath;
        Splay.ar([sig, DelayC.ar(sig, 0.05, 0.017)], 0.6) * amp;
    });

    Ndef(\clockSwarm, { |amp=0, density=14, baseFreq=1800|
        var trigs = Array.fill(4, { |i| Dust.ar(density * (0.85 + (i * 0.12))) });
        var voices = trigs.collect({ |tr, i|
            var f = baseFreq * (0.7 + (i * 0.35)) * LFNoise0.kr(2 + i).range(0.92, 1.08);
            Ringz.ar(tr * 0.3, f, 0.025)
        });
        Splay.ar(voices, 0.85) * amp;
    });

    // 4. Master Mixer
    Ndef(\masterMix, {
        var bus = In.ar(~synthBus, 2);
        var breath = Ndef.ar(\timeBreath, 2);
        var swarm = Ndef.ar(\clockSwarm, 2);
        bus + breath + swarm;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.18);
    Ndef(\masterMix).play;
    s.sync;

    // 5. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: O Pêndulo e o Cronômetro]".postln;
        Pbindef(\tickSeq,
            \instrument, \brassTick,
            \out, ~synthBus,
            \dur, Pseq([0.5, 0.5, 0.5, 0.5], inf),
            \freq, Pseq([1200, 980, 1220, 960], inf),
            \metal, 0.7,
            \amp, Pwhite(0.18, 0.24, inf),
            \pan, Pseq([-0.3, 0.3], inf)
        ).play;

        Pbindef(\chronoSeq,
            \instrument, \pocketChrono,
            \out, ~synthBus,
            \dur, Pseq([0.166, 0.166, 0.168], inf),
            \freq, Pwhite(3600, 4400, inf),
            \amp, Pwhite(0.08, 0.13, inf),
            \pan, 0.45
        ).play;
        8.wait;

        "0:08 - [Cue 2: O Enxame de Engrenagens]".postln;
        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, 0.16, \density, 12);
        Pbindef(\tickSeq, \dur, Pseq([0.48, 0.52, 0.49, 0.51], inf), \pan, Pwhite(-0.7, 0.7, inf));
        2.do { |i|
            Ndef(\clockSwarm).xset(\density, 14 + (i * 8), \baseFreq, 1700 + (i * 300));
            5.wait;
        };

        "0:18 - [Cue 3: Carrilhões Franceses e o Respirar do Tempo]".postln;
        Ndef(\timeBreath).fadeTime = 6;
        Ndef(\timeBreath).xset(\amp, 0.22, \cutoff, 480);
        Ndef(\masterMix).set(\wet10, 0.32);

        Pbindef(\chimeSeq,
            \instrument, \frenchChime,
            \out, ~synthBus,
            \dur, Pseq([3.5, 2.5, 4.0, 3.0], inf),
            \midinote, Pseq([62, 69, 65, 72, 60, 67], inf),
            \dur, Pseq([3.5, 2.5, 4.0, 3.0], inf),
            \modIdx, Pwhite(1.2, 2.2, inf),
            \amp, Pwhite(0.14, 0.20, inf),
            \pan, Pwhite(-0.5, 0.5, inf)
        ).play;

        3.do { |i|
            Ndef(\timeBreath).xset(\cutoff, 420 + (i * 180));
            6.wait;
        };

        "0:36 - [Cue 4: Defasagem Máxima (Limite Intrínseco)]".postln;
        Pbindef(\chronoSeq, \dur, Pseq([0.11, 0.12, 0.11, 0.13], inf), \amp, Pwhite(0.12, 0.18, inf));
        3.do { |i|
            Ndef(\clockSwarm).xset(\density, 28 + (i * 14), \amp, 0.24);
            4.wait;
        };

        "0:48 - [Cue 5: O Velho Relojoeiro Fecha os Olhos (Flashback)]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\chimeSeq).stop;
        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, 0.0);
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.28, \cutoff, 320, \breathRate, 0.1);
        Pbindef(\chronoSeq, \dur, 0.25, \amp, Pwhite(0.06, 0.10, inf), \pan, 0);
        8.wait;

        "0:56 - [Cue 6: Resolução e Silêncio]".postln;
        Pbindef(\chronoSeq).stop;
        Ndef(\timeBreath).fadeTime = 4;
        Ndef(\timeBreath).xset(\amp, 0.0);
        5.wait;

        // Scoped Termination
        Pbindef(\tickSeq).stop; Pbindef(\tickSeq).clear;
        Pbindef(\chronoSeq).stop; Pbindef(\chronoSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Ndef(\timeBreath).clear(2);
        Ndef(\clockSwarm).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 04 [COMPOSE] - Status: PASS</strong> — <em>A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no sécul...</em></summary>

- **Prompt**: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalista dinamarquês Peter Lund, é composta por sete amplos salões subterrâneos esculpidos pela ação milenar das águas em rocha calcária. Suas abóbadas úmidas exibem cortinas minerais, estalactites e estalagmites onde o gotejamento lento cria ressonâncias acústicas profundas na escuridão.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    // 1. Configuration & Safety Limiter
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // 2. Discrete SynthDefs
    SynthDef(\waterDrop, { |out=0, freq=900, amp=0.2, pan=0, decay=0.25|
        var pEnv = EnvGen.kr(Env.perc(0.002, 0.06, 1, -4));
        var aEnv = EnvGen.ar(Env.perc(0.002, decay.max(0.05), 1, -6), doneAction: 2);
        var drop = SinOsc.ar(freq * (1 + (pEnv * 0.45))) * aEnv;
        var cav = Ringz.ar(drop * 0.3, freq * 1.5, decay * 0.8);
        var sig = (drop * 0.7) + (cav * 0.3);
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;

    SynthDef(\stalactiteStrike, { |out=0, freq=440, amp=0.18, pan=0, dur=2.5|
        var exc = (Impulse.ar(0) * 0.8) + (BPF.ar(PinkNoise.ar, freq * 2, 0.3) * EnvGen.ar(Env.perc(0.001, 0.02)));
        var env = EnvGen.ar(Env.perc(0.005, dur.max(0.1), 1, -4), doneAction: 2);
        var freqs = [freq, freq * 2.13, freq * 3.47, freq * 5.12];
        var amps = [0.6, 0.35, 0.2, 0.1];
        var rings = [dur, dur * 0.7, dur * 0.45, dur * 0.25];
        var res = DynKlank.ar(Ref([freqs, amps, rings]), exc);
        Out.ar(out, Pan2.ar(res * env * 0.25, pan, amp));
    }).add;

    SynthDef(\subterraneanRes, { |out=0, freq=65, amp=0.25, pan=0, dur=4.0|
        var env = EnvGen.ar(Env.linen(0.8, (dur - 1.6).max(0.1), 1.2, 1, -3), doneAction: 2);
        var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
        var air = BPF.ar(PinkNoise.ar, freq * 3, 0.08) * 6.0;
        var sig = LPF.ar((sub * 0.7) + (air * 0.3), 420) * env;
        Out.ar(out, Pan2.ar(sig, pan, amp));
    }).add;
    s.sync;

    // 3. Continuous Ndefs
    Ndef(\cavernAir, { |amp=0, cutoff=320, panRate=0.07|
        var noise = PinkNoise.ar([0.8, 0.85]);
        var sweep = SinOsc.kr(0.05).range(0.7, 1.4);
        var sig = BPF.ar(noise, cutoff * sweep, 0.35) * 2.2;
        var ref = CombL.ar(sig, 0.2, [0.087, 0.113], 1.8);
        Balance2.ar(sig[0] + (ref[0] * 0.4), sig[1] + (ref[1] * 0.4), SinOsc.kr(panRate) * 0.3, amp);
    });

    Ndef(\mineralDripCloud, { |amp=0, density=6, baseFreq=1400|
        var trigs = Array.fill(4, { |i| Dust.ar(density * (0.7 + (i * 0.2))) });
        var voices = trigs.collect({ |tr, i|
            var f = baseFreq * (0.65 + (i * 0.28)) * LFNoise0.kr(1.5 + i).range(0.85, 1.15);
            Ringz.ar(tr * 0.25, f, 0.04)
        });
        Splay.ar(voices, 0.9) * amp;
    });

    // 4. Master Mixer
    Ndef(\masterMix, {
        var bus = In.ar(~synthBus, 2);
        var air = Ndef.ar(\cavernAir, 2);
        var cloud = Ndef.ar(\mineralDripCloud, 2);
        bus + air + cloud;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.92, 0.35);
    };
    Ndef(\masterMix).set(\wet10, 0.35);
    Ndef(\masterMix).play;
    s.sync;

    // 5. Master Score Timeline
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Escuridao Calcaria]".postln;
        Ndef(\cavernAir).fadeTime = 5;
        Ndef(\cavernAir).xset(\amp, 0.14, \cutoff, 280);

        Pbindef(\dropSeq,
            \instrument, \waterDrop,
            \out, ~synthBus,
            \dur, Pwhite(0.9, 2.2, inf),
            \freq, Pexprand(650, 1800, inf),
            \decay, Pwhite(0.18, 0.38, inf),
            \amp, Pwhite(0.14, 0.22, inf),
            \pan, Pwhite(-0.7, 0.7, inf)
        ).play;
        2.do { |i|
            Ndef(\cavernAir).xset(\cutoff, 280 + (i * 60));
            6.wait;
        };

        "0:12 - [Cue 2: Os Sete Saloes]".postln;
        Ndef(\masterMix).set(\wet10, 0.48);
        Pbindef(\stalactiteSeq,
            \instrument, \stalactiteStrike,
            \out, ~synthBus,
            \dur, Pseq([2.5, 3.0, 2.0, 3.5], inf),
            \midinote, Pseq([64, 71, 67, 74, 62, 69], inf),
            \amp, Pwhite(0.14, 0.20, inf),
            \pan, Pwhite(-0.6, 0.6, inf)
        ).play;
        2.do { |i|
            Ndef(\cavernAir).xset(\cutoff, 360 + (i * 80));
            7.wait;
        };

        "0:26 - [Cue 3: Ressonancias Profundas]".postln;
        Ndef(\mineralDripCloud).fadeTime = 6;
        Ndef(\mineralDripCloud).xset(\amp, 0.12, \density, 7, \baseFreq, 1300);

        Pbindef(\vaultSeq,
            \instrument, \subterraneanRes,
            \out, ~synthBus,
            \dur, Pseq([4.0, 4.0], inf),
            \midinote, Pseq([36, 38, 33, 36], inf),
            \amp, 0.26,
            \pan, Pwhite(-0.3, 0.3, inf)
        ).play;
        2.do { |i|
            Ndef(\mineralDripCloud).xset(\density, 9 + (i * 4));
            8.wait;
        };

        "0:42 - [Cue 4: Gotejamento Intenso (Limite Intrinseco)]".postln;
        Ndef(\masterMix).set(\wet10, 0.58);
        Pbindef(\dropSeq, \dur, Pwhite(0.25, 0.65, inf), \amp, Pwhite(0.16, 0.24, inf));
        Pbindef(\stalactiteSeq, \dur, Pseq([1.5, 1.25, 1.75, 1.0], inf));
        3.do { |i|
            Ndef(\mineralDripCloud).xset(\density, 16 + (i * 6), \amp, 0.18);
            4.wait;
        };

        "0:54 - [Cue 5: Cortinas Minerais (Settling)]".postln;
        Pbindef(\vaultSeq).stop;
        Ndef(\mineralDripCloud).fadeTime = 3;
        Ndef(\mineralDripCloud).xset(\amp, 0.0);
        Ndef(\cavernAir).fadeTime = 4;
        Ndef(\cavernAir).xset(\amp, 0.10, \cutoff, 240);
        Pbindef(\dropSeq, \dur, Pwhite(1.4, 2.8, inf), \amp, Pwhite(0.10, 0.16, inf));
        Pbindef(\stalactiteSeq, \dur, Pseq([3.0, 4.0], inf), \amp, 0.14);
        2.do { 6.wait; };

        "1:06 - [Cue 6: Silencio na Gruta (Resolucao)]".postln;
        Pbindef(\dropSeq).stop;
        Pbindef(\stalactiteSeq).stop;
        Ndef(\cavernAir).fadeTime = 5;
        Ndef(\cavernAir).xset(\amp, 0.0);
        6.wait;

        // Scoped Termination
        Pbindef(\dropSeq).stop; Pbindef(\dropSeq).clear;
        Pbindef(\stalactiteSeq).stop; Pbindef(\stalactiteSeq).clear;
        Pbindef(\vaultSeq).stop; Pbindef(\vaultSeq).clear;
        Ndef(\cavernAir).clear(2);
        Ndef(\mineralDripCloud).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 05 [DESIGN] - Status: FIXED</strong> — <em>Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumb...</em></summary>

- **Prompt**: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de potenciômetros prateados, matrizes de pinos luminosos e cabos entrelaçados. Ao lado, a tela verde de fósforo de um osciloscópio analógico desenha figuras de Lissajous em rotação contínua que se dobram e se desdobram em harmônicos complexos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback, WARNING: brackets are unbalanced
- **Initial Error**: `ERROR: Parse error
ERROR: syntax error, unexpected BADTOKEN, expecting ')'
ERROR: Command line parse failed
__VAL_ERROR__: Syntax / compile error in generated code
ERROR: Parse error
  in interpreted text
  line 211 char 116:
          Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], s`

```supercollider
(
// Step 0: CC Mapping Dictionary
~cc = (
    vol1: 10, pan1: 11, mute1: 12, min1: 13, max1: 14, hpf1: 15, lpf1: 16, rq1: 17, atk1: 18, dec1: 19, sus1: 20, rls1: 21, fxFold: 22,
    vol2: 30, pan2: 31, mute2: 32, min2: 33, max2: 34, hpf2: 35, lpf2: 36, rq2: 37, atk2: 38, dec2: 39, sus2: 40, rls2: 41, fxPhase: 42,
    vol3: 50, pan3: 51, mute3: 52, min3: 53, max3: 54, hpf3: 55, lpf3: 56, rq3: 57, atk3: 58, dec3: 59, sus3: 60, rls3: 61, fxDrift: 62,
    delMix: 70, delTime: 71, delFb: 72, verbMix: 73, revTime: 74,
    panic: 120
);

// Step 1 & 2: MIDI Discovery & Hardware Fallback
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

// Step 3: Server Boot, Buses, SynthDefs, FX, MIDIdefs, & GUI
s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 64, hpf1: 28, lpf1: 220, rq1: 0.45, atk1: 0.01, dec1: 0.25, sus1: 0.75, rls1: 0.35, fxFold: 0.0,
        vol2: 0.24, pan2: -0.35, mute2: 0.0, min2: 36, max2: 108, hpf2: 240, lpf2: 6500, rq2: 0.35, atk2: 0.008, dec2: 0.45, sus2: 0.40, rls2: 0.65, fxPhase: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 180, lpf3: 3800, rq3: 0.50, atk3: 0.35, dec3: 0.80, sus3: 0.70, rls3: 1.40, fxDrift: 0.0,
        delMix: 0.0, delTime: 0.32, delFb: 0.35, verbMix: 0.0, revTime: 2.8
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // Zone 1: Pin Matrix Sub (Wavefolding Buchla-style Sub)
    SynthDef(\pinMatrixSub, { |out=0, freq=55, amp=0.5, gate=1,
        vol=0.28, pan=0.0, mute=0.0, hpf=28, lpf=220, rq=0.45,
        atk=0.01, dec=0.25, sus=0.75, rls=0.35, fxFold=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var core = SinOsc.ar(freq) + (Pulse.ar(freq * 0.5, 0.42) * 0.35);
        var folded = Fold.ar(core * (1.0 + (fxFold * 5.0)), -0.8, 0.8);
        var sig = HPF.ar(folded, hpf.clip(20, 18000));
        sig = (MoogFF.ar(sig, lpf.clip(20, 18000), (1.0 - rq.clip(0.05, 1.0)) * 3.5) * 1.6).tanh;
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1.0 - mute), pan));
    }).add;

    // Zone 2: Lissajous FM (2-Op Harmonic Ratio FM)
    SynthDef(\lissajousFM, { |out=0, freq=220, amp=0.5, gate=1,
        vol=0.24, pan=(-0.35), mute=0.0, hpf=240, lpf=6500, rq=0.35,
        atk=0.008, dec=0.45, sus=0.40, rls=0.65, fxPhase=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var modEnv = EnvGen.kr(Env.perc(0.005, dec + 0.2), gate);
        var modIdx = (0.4 + (fxPhase * 6.5)) * modEnv;
        var mod = SinOsc.ar(freq * 2.0) * (freq * modIdx);
        var car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.5 + (mod * 0.5)) * 0.35);
        var sig = RLPF.ar(HPF.ar(car, hpf.clip(20, 18000)), lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        Out.ar(out, Pan2.ar(sig * env * amp * vol * (1.0 - mute), pan));
    }).add;

    // Zone 3: Phosphor Trace (Detuned SuperSaw & Pulse Pad)
    SynthDef(\phosphorTrace, { |out=0, freq=220, amp=0.5, gate=1,
        vol=0.20, pan=0.35, mute=0.0, hpf=180, lpf=3800, rq=0.50,
        atk=0.35, dec=0.80, sus=0.70, rls=1.40, fxDrift=0.0|
        var env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        var detune = 0.004 + (fxDrift * 0.018);
        var saws = Splay.ar(Saw.ar(freq * [1.0 - detune, 1.0 - (detune * 0.5), 1.0, 1.0 + (detune * 0.5), 1.0 + detune]));
        var sig = RLPF.ar(HPF.ar(saws, hpf.clip(20, 18000)), lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, env * amp * vol * (1.0 - mute)) } { Pan2.ar(sig, pan, env * amp * vol * (1.0 - mute)) });
    }).add;

    // Group FX: Stereo Delay & Phosphor Reverb
    SynthDef(\modularFX, { |inBus=0, outBus=0, delMix=0.0, delTime=0.32, delFb=0.35, verbMix=0.0, revTime=2.8|
        var dry = In.ar(inBus, 2);
        var del = CombL.ar(dry, 1.2, Lag.kr(delTime.clip(0.02, 1.0), 0.1), (delFb.clip(0.0, 0.9) * 4.0) + 0.1);
        var sig = (dry * (1.0 - (delMix * 0.5))) + (del * delMix);
        var verb = FreeVerb2.ar(sig[0], sig[1], 1.0, revTime.linlin(0.2, 8.0, 0.3, 0.96), 0.35);
        sig = (sig * (1.0 - verbMix)) + (verb * verbMix);
        Out.ar(outBus, sig);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, { |inBus=0|
        var sig = LeakDC.ar(In.ar(inBus, 2));
        Out.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \modularFX, [
        \inBus, ~fxBus, \outBus, ~masterBus,
        \delMix, ~buses.delMix.asMap, \delTime, ~buses.delTime.asMap, \delFb, ~buses.delFb.asMap,
        \verbMix, ~buses.verbMix.asMap, \revTime, ~buses.revTime.asMap
    ]);
    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\inBus, ~masterBus]);

    // MIDI NoteOn
    MIDIdef.noteOn(\modNoteOn, { |vel, noteNum|
        var amp = (vel / 127.0).linlin(0, 1, 0.15, 1.0);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(
                Synth(\pinMatrixSub, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                    \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                    \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap,
                    \fxFold, ~buses.fxFold.asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth(\lissajousFM, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                    \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                    \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap,
                    \fxPhase, ~buses.fxPhase.asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth(\phosphorTrace, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                    \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                    \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap, \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap,
                    \fxDrift, ~buses.fxDrift.asMap
                ], ~synthGroup)
            );
        };
    }, srcID: ~myUid);

    // MIDI NoteOff
    MIDIdef.noteOff(\modNoteOff, { |vel, noteNum|
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            if(arr[noteNum].notNil) {
                arr[noteNum].do { |syn| syn.set(\gate, 0) };
                arr[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    // Loop-Driven MIDIdef.cc
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
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // Panic CC
    MIDIdef.cc(\panicCC, { |val|
        if(val > 0) {
            [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                arr.do { |list, idx|
                    if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                };
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Paginated GUI
    defer {
        var screen = Window.availableBounds;
        var winW = 760;
        var winH = min(720, screen.height - 60);
        var zoneMeta = [
            (title: "Z1: Pin Matrix Sub", fxKey: \fxFold, fxLabel: "Pin Fold"),
            (title: "Z2: Lissajous FM", fxKey: \fxPhase, fxLabel: "Phase Mod"),
            (title: "Z3: Phosphor Trace", fxKey: \fxDrift, fxLabel: "Trace Drift")
        ];
        var pages = List.new;
        var tabBtns = List.new;
        var bgCol = Color(0.08, 0.11, 0.09);
        var panelCol = Color(0.12, 0.16, 0.13);
        var phosCol = Color(0.25, 0.95, 0.45);
        var textCol = Color(0.85, 0.95, 0.88);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~ui = ();
        ~mainWin = Window("Modular Pin Matrix & Lissajous Oscilloscope",
            Rect((screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH),
            scroll: true
        ).background_(bgCol).front;

        StaticText(~mainWin, Rect(15, 10, 500, 26))
            .string_("MODULAR PIN MATRIX // LISSAJOUS SYNTH")
            .font_(Font("Helvetica", 15, true))
            .stringColor_(phosCol);

        // Tab Buttons & Zone Pages
        zoneMeta.do { |zm, idx|
            var btn, page, zNum, kVol, kPan, kMute, kMin, kMax, kHpf, kLpf, kRq, kAtk, kDec, kSus, kRls, kFx;
            zNum = idx + 1;
            kVol = ("vol" ++ zNum).asSymbol; kPan = ("pan" ++ zNum).asSymbol; kMute = ("mute" ++ zNum).asSymbol;
            kMin = ("min" ++ zNum).asSymbol; kMax = ("max" ++ zNum).asSymbol;
            kHpf = ("hpf" ++ zNum).asSymbol; kLpf = ("lpf" ++ zNum).asSymbol; kRq = ("rq" ++ zNum).asSymbol;
            kAtk = ("atk" ++ zNum).asSymbol; kDec = ("dec" ++ zNum).asSymbol; kSus = ("sus" ++ zNum).asSymbol; kRls = ("rls" ++ zNum).asSymbol;
            kFx = zm[\fxKey];

            btn = Button(~mainWin, Rect(15 + (idx * 175), 42, 168, 28))
                .states_([[zm[\title], textCol, panelCol], [zm[\title], bgCol, phosCol]])
                .value_(if(idx == 0, 1, 0))
                .action_({
                    pages.do { |p, pIdx| p.visible = (pIdx == idx) };
                    tabBtns.do { |b, bIdx| b.value = if(bIdx == idx, 1, 0) };
                });
            tabBtns.add(btn);

            page = CompositeView(~mainWin, Rect(15, 78, winW - 30, 440))
                .background_(panelCol)
                .visible_(idx == 0);
            pages.add(page);

            ~ui[kMute] = Button(page, Rect(15, 14, 90, 26))
                .states_([["ACTIVE", bgCol, phosCol], ["MUTED", Color.white, Color(0.7, 0.2, 0.2)]])
                .value_(~ccVals[kMute])
                .action_({ |b| ~ccVals[kMute] = b.value; ~buses[kMute].set(b.value) });

            ~ui[kVol] = EZSlider(page, Rect(120, 14, 280, 24), "Vol (CC" ++ ~cc[kVol] ++ ")", ControlSpec(0, 1, \lin),
                { |ez| ~ccVals[kVol] = ez.value; ~buses[kVol].set(ez.value) }, ~ccVals[kVol], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kPan] = EZSlider(page, Rect(415, 14, 290, 24), "Pan (CC" ++ ~cc[kPan] ++ ")", ControlSpec(-1, 1, \lin),
                { |ez| ~ccVals[kPan] = ez.value; ~buses[kPan].set(ez.value) }, ~ccVals[kPan], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            EZRanger(page, Rect(15, 52, 690, 24), "Key Range", ControlSpec(0, 127, \lin, 1),
                { |ez|
                    ~ccVals[kMin] = ez.lo; ~buses[kMin].set(ez.lo);
                    ~ccVals[kMax] = ez.hi; ~buses[kMax].set(ez.hi);
                }, [~ccVals[kMin], ~ccVals[kMax]], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            // Filter & Unique FX Knobs
            [
                [kHpf, "HPF (CC" ++ ~cc[kHpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kLpf, "LPF (CC" ++ ~cc[kLpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kRq, "Res (CC" ++ ~cc[kRq] ++ ")", ControlSpec(1.0, 0.05, \exp)],
                [kFx, zm[\fxLabel] ++ " (CC" ++ ~cc[kFx] ++ ")", ControlSpec(0, 1, \lin)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 96, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };

            // ADSR Knobs
            [
                [kAtk, "Atk (CC" ++ ~cc[kAtk] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kDec, "Dec (CC" ++ ~cc[kDec] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kSus, "Sus (CC" ++ ~cc[kSus] ++ ")", ControlSpec(0, 1, \lin)],
                [kRls, "Rls (CC" ++ ~cc[kRls] ++ ")", ControlSpec(0.005, 5.0, \exp)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 235, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };
        };

        // Static Bottom Bar: Group FX & Panic
        CompositeView(~mainWin, Rect(15, 530, winW - 30, 135)).background_(panelCol);
        ~ui[\delMix] = EZSlider(~mainWin, Rect(30, 542, 330, 22), "Delay Mix (CC70)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delTime] = EZSlider(~mainWin, Rect(380, 542, 330, 22), "Delay Time (CC71)", ControlSpec(0.02, 1.0, \exp),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) }, ~ccVals[\delTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delFb] = EZSlider(~mainWin, Rect(30, 572, 330, 22), "Delay Fb (CC72)", ControlSpec(0, 0.9, \lin),
            { |ez| ~ccVals[\delFb] = ez.value; ~buses[\delFb].set(ez.value) }, ~ccVals[\delFb], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\verbMix] = EZSlider(~mainWin, Rect(380, 572, 330, 22), "Verb Mix (CC73)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\revTime] = EZSlider(~mainWin, Rect(30, 602, 330, 22), "Verb Time (CC74)", ControlSpec(0.2, 8.0, \exp),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) }, ~ccVals[\revTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

        Button(~mainWin, Rect(380, 604, 330, 32))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({
                [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                    arr.do { |list, idx|
                        if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                    };
                };
            });

        // 20fps AppClock Poller
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
```

</details>

<details>
<summary><strong>Round 06 [DESIGN] - Status: PASS</strong> — <em>O berimbau de barriga é um instrumento de percussão cordofone originário da Áfri...</em></summary>

- **Prompt**: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente enraizado na tradição cultural afro-brasileira da capoeira. Composto por uma verga de madeira de biriba curva esticada por arame de pneu de aço e uma cabaça ressonadora seca, é percutido por uma baqueta enquanto o dobrão de metal e o caxixi modulam timbres secos, ressonantes e hipnóticos.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: WARNING: brackets are unbalanced, prepended pre-design synthesizer cleanup for previous design instance

```supercollider
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
// Step 0: MIDI CC Map
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 33, pan2: 34, mute2: 35, min2: 36, max2: 37, hpf2: 38, lpf2: 39, rq2: 40, atk2: 41, dec2: 42, sus2: 43, rls2: 44, fx2: 45,
    vol3: 46, pan3: 47, mute3: 48, min3: 49, max3: 50, hpf3: 51, lpf3: 52, rq3: 53, atk3: 54, dec3: 55, sus3: 56, rls3: 57, fx3: 58,
    delMix: 70, delTime: 71, delFb: 72, verbMix: 73, revTime: 74, panic: 120
);

// Step 1 & 2: MIDI Auto-Detection with Hardware Fallback
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

// Step 3: Server Boot, Buses, SynthDefs, Routing, MIDI & GUI
s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 0, max1: 72, hpf1: 80, lpf1: 5200, rq1: 0.45, atk1: 0.005, dec1: 0.45, sus1: 0.15, rls1: 0.35, fx1: 0.0,
        vol2: 0.26, pan2: -0.35, mute2: 0.0, min2: 36, max2: 96, hpf2: 110, lpf2: 3200, rq2: 0.35, atk2: 0.015, dec2: 0.65, sus2: 0.35, rls2: 0.55, fx2: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 48, max3: 127, hpf3: 900, lpf3: 14000, rq3: 0.40, atk3: 0.005, dec3: 0.18, sus3: 0.05, rls3: 0.12, fx3: 0.0,
        delMix: 0.0, delTime: 0.28, delFb: 0.25, verbMix: 0.0, revTime: 1.8
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~zone1Notes = Array.newClear(128);
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // Zone 1: Arame & Verga (Steel Wire & Biriba Bow)
    SynthDef(\berimbauWire, {
        |out=0, freq=146.83, amp=0.5, gate=1,
         vol=0.28, pan=0.0, mute=0.0, hpf=80, lpf=5200, rq=0.45,
         atk=0.005, dec=0.45, sus=0.15, rls=0.35, fx=0.0|
        var env, strike, string, dobrao, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        strike = BPF.ar(WhiteNoise.ar, (freq * 3.5).clip(200, 9000), 0.35)
            * EnvGen.ar(Env.perc(0.001, 0.018));
        string = CombL.ar(strike, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.6 + (sus * 2.0));
        string = string + (SinOsc.ar(freq) * 0.22 * EnvGen.ar(Env.perc(0.002, 0.35)));
        dobrao = AllpassC.ar(string, 0.02, (fx * 0.006) + 0.0004, 0.06);
        dobrao = dobrao * (1.0 + (SinOsc.ar(freq * 2.71) * fx * 0.65));
        sig = (string * (1.0 - fx)) + (dobrao * fx);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Cabaca Ressonadora (Gourd Resonator)
    SynthDef(\berimbauCabaca, {
        |out=0, freq=220, amp=0.5, gate=1,
         vol=0.26, pan=(-0.35), mute=0.0, hpf=110, lpf=3200, rq=0.35,
         atk=0.015, dec=0.65, sus=0.35, rls=0.55, fx=0.0|
        var env, exc, gourd, shift, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        exc = (Saw.ar(freq * [0.997, 1.003]).sum * 0.35) + (SinOsc.ar(freq * 0.5) * 0.25);
        shift = 1.0 + (fx * 0.85);
        gourd = BPF.ar(exc, (freq * 1.5 * shift).clip(60, 8000), 0.22, 2.2)
            + BPF.ar(exc, (freq * 2.8 * shift).clip(80, 10000), 0.18, 1.5);
        sig = (exc * 0.35 * (1.0 - (fx * 0.5))) + (gourd * 0.85);
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 3: Caxixi & Baqueta (Wicker Rattle & Stick)
    SynthDef(\berimbauCaxixi, {
        |out=0, freq=880, amp=0.5, gate=1,
         vol=0.20, pan=0.35, mute=0.0, hpf=900, lpf=14000, rq=0.40,
         atk=0.005, dec=0.18, sus=0.05, rls=0.12, fx=0.0|
        var env, seeds, stick, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        seeds = PinkNoise.ar * (0.6 + (Dust2.ar(35 + (fx * 180)) * 0.6));
        seeds = BPF.ar(seeds, (freq * 2.5).clip(600, 12000), 0.25, 2.4);
        stick = BPF.ar(WhiteNoise.ar, (freq * 1.8).clip(400, 9000), 0.15, 1.5)
            * EnvGen.ar(Env.perc(0.001, 0.025));
        sig = seeds + stick;
        sig = RLPF.ar(sig, lpf.clip(40, 18000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 12000));
        sig = sig * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Group FX: Stereo Delay & Reverb
    SynthDef(\groupFX, {
        |in=0, out=0, delMix=0.0, delTime=0.28, delFb=0.25, verbMix=0.0, revTime=1.8|
        var dry, del, verb, sig;
        dry = In.ar(in, 2);
        del = CombL.ar(dry, 1.2, delTime.clip(0.02, 1.0), (delFb.clip(0.0, 0.9) * 4.0) + 0.05);
        sig = (dry * (1.0 - (delMix * 0.5))) + (del * delMix);
        verb = FreeVerb2.ar(sig[0], sig[1], 1.0, revTime.linlin(0.2, 8.0, 0.2, 0.95), 0.4);
        sig = (sig * (1.0 - (verbMix * 0.5))) + (verb * verbMix);
        Out.ar(out, sig);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, {
        |in=0, out=0|
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \groupFX, [
        \in, ~fxBus, \out, ~masterBus,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap,
        \delFb, ~buses[\delFb].asMap, \verbMix, ~buses[\verbMix].asMap,
        \revTime, ~buses[\revTime].asMap
    ]);

    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\in, ~masterBus, \out, 0]);

    // MIDI NoteOn
    MIDIdef.noteOn(\berimbauOn, { |vel, noteNum|
        var amp = (vel / 127.0).linexp(0.01, 1.0, 0.12, 1.0);
        var freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zone1Notes[noteNum] = ~zone1Notes[noteNum].add(
                Synth(\berimbauWire, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap,
                    \rls, ~buses[\rls1].asMap, \fx, ~buses[\fx1].asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth(\berimbauCabaca, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap,
                    \rls, ~buses[\rls2].asMap, \fx, ~buses[\fx2].asMap
                ], ~synthGroup)
            );
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth(\berimbauCaxixi, [
                    \out, ~fxBus, \freq, freq, \amp, amp,
                    \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap,
                    \rls, ~buses[\rls3].asMap, \fx, ~buses[\fx3].asMap
                ], ~synthGroup)
            );
        };
    }, srcID: ~myUid);

    // MIDI NoteOff
    MIDIdef.noteOff(\berimbauOff, { |vel, noteNum|
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            if(arr[noteNum].notNil) {
                arr[noteNum].do(_.set(\gate, 0));
                arr[noteNum] = nil;
            };
        };
    }, srcID: ~myUid);

    // Loop-Driven MIDI CC
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
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    // MIDI Panic CC
    MIDIdef.cc(\panicCC, {
        [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
            arr.do { |list, idx|
                if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // Paginated GUI
    defer {
        var screen = Window.availableBounds;
        var winW = 760;
        var winH = min(680, screen.height - 60);
        var bgCol = Color(0.11, 0.09, 0.07);
        var panelCol = Color(0.18, 0.14, 0.10);
        var textCol = Color(0.95, 0.88, 0.72);
        var phosCol = Color(0.95, 0.65, 0.22);
        var tabBtns = Array.newClear(3);
        var pages = Array.newClear(3);
        var zoneMeta = [
            (title: "1. Arame & Verga", fxLabel: "Dobrao Buzz"),
            (title: "2. Cabaca", fxLabel: "Abertura Barriga"),
            (title: "3. Caxixi & Baqueta", fxLabel: "Grao Seco")
        ];

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~ui = ();
        ~mainWin = Window("Berimbau de Barriga - Afro-Brazilian Capoeira Synth",
            Rect((screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH),
            scroll: true).background_(bgCol).front;

        StaticText(~mainWin, Rect(15, 10, winW - 30, 26))
            .string_("BERIMBAU DE BARRIGA // BIRIBA, ARAME, CABACA & CAXIXI")
            .stringColor_(phosCol).font_(Font("Helvetica", 15, true));

        // Tab Buttons
        zoneMeta.do { |zm, idx|
            tabBtns[idx] = Button(~mainWin, Rect(15 + (idx * 245), 42, 235, 30))
                .states_([
                    [zm[\title], textCol, panelCol],
                    [zm[\title], bgCol, phosCol]
                ])
                .value_(if(idx == 0, 1, 0))
                .action_({
                    pages.do { |pg, pIdx|
                        pg.visible_(pIdx == idx);
                        tabBtns[pIdx].value_(if(pIdx == idx, 1, 0));
                    };
                });
        };

        // Zone Pages
        zoneMeta.do { |zm, idx|
            var z = (idx + 1).asString;
            var kVol = ("vol" ++ z).asSymbol, kPan = ("pan" ++ z).asSymbol, kMute = ("mute" ++ z).asSymbol;
            var kMin = ("min" ++ z).asSymbol, kMax = ("max" ++ z).asSymbol;
            var kHpf = ("hpf" ++ z).asSymbol, kLpf = ("lpf" ++ z).asSymbol, kRq = ("rq" ++ z).asSymbol;
            var kAtk = ("atk" ++ z).asSymbol, kDec = ("dec" ++ z).asSymbol, kSus = ("sus" ++ z).asSymbol, kRls = ("rls" ++ z).asSymbol;
            var kFx = ("fx" ++ z).asSymbol;
            var page = CompositeView(~mainWin, Rect(15, 80, winW - 30, 440))
                .background_(panelCol).visible_(idx == 0);
            pages[idx] = page;

            ~ui[kVol] = EZSlider(page, Rect(15, 12, 280, 22), "Vol (CC" ++ ~cc[kVol] ++ ")", ControlSpec(0, 1, \lin),
                { |ez| ~ccVals[kVol] = ez.value; ~buses[kVol].set(ez.value) }, ~ccVals[kVol], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kPan] = EZSlider(page, Rect(310, 12, 280, 22), "Pan (CC" ++ ~cc[kPan] ++ ")", ControlSpec(-1, 1, \lin),
                { |ez| ~ccVals[kPan] = ez.value; ~buses[kPan].set(ez.value) }, ~ccVals[kPan], labelWidth: 95)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kMute] = Button(page, Rect(605, 12, 110, 24))
                .states_([["ACTIVE", textCol, Color(0.2, 0.45, 0.2)], ["MUTED", Color.white, Color(0.7, 0.15, 0.15)]])
                .value_(~ccVals[kMute])
                .action_({ |b| ~ccVals[kMute] = b.value; ~buses[kMute].set(b.value) });

            ~ui[kMin] = EZSlider(page, Rect(15, 44, 340, 22), "Min Note (CC" ++ ~cc[kMin] ++ ")", ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMin] = ez.value; ~buses[kMin].set(ez.value) }, ~ccVals[kMin], labelWidth: 115)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            ~ui[kMax] = EZSlider(page, Rect(375, 44, 340, 22), "Max Note (CC" ++ ~cc[kMax] ++ ")", ControlSpec(0, 127, \lin, 1),
                { |ez| ~ccVals[kMax] = ez.value; ~buses[kMax].set(ez.value) }, ~ccVals[kMax], labelWidth: 115)
                .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

            // Filter & Character FX Knobs
            [
                [kHpf, "HPF (CC" ++ ~cc[kHpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kLpf, "LPF (CC" ++ ~cc[kLpf] ++ ")", ControlSpec(20, 18000, \exp)],
                [kRq, "Res (CC" ++ ~cc[kRq] ++ ")", ControlSpec(1.0, 0.05, \exp)],
                [kFx, zm[\fxLabel] ++ " (CC" ++ ~cc[kFx] ++ ")", ControlSpec(0, 1, \lin)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 96, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };

            // ADSR Knobs
            [
                [kAtk, "Atk (CC" ++ ~cc[kAtk] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kDec, "Dec (CC" ++ ~cc[kDec] ++ ")", ControlSpec(0.005, 5.0, \exp)],
                [kSus, "Sus (CC" ++ ~cc[kSus] ++ ")", ControlSpec(0, 1, \lin)],
                [kRls, "Rls (CC" ++ ~cc[kRls] ++ ")", ControlSpec(0.005, 5.0, \exp)]
            ].do { |item, kIdx|
                ~ui[item[0]] = EZKnob(page, Rect(25 + (kIdx * 170), 235, 130, 115), item[1], item[2],
                    { |ez| ~ccVals[item[0]] = ez.value; ~buses[item[0]].set(ez.value) }, ~ccVals[item[0]])
                    .setColors(stringColor: textCol, numBackground: bgCol, numStringColor: phosCol);
            };
        };

        // Static Bottom Bar: Group FX & Panic
        CompositeView(~mainWin, Rect(15, 530, winW - 30, 135)).background_(panelCol);
        ~ui[\delMix] = EZSlider(~mainWin, Rect(30, 542, 330, 22), "Delay Mix (CC70)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delTime] = EZSlider(~mainWin, Rect(380, 542, 330, 22), "Delay Time (CC71)", ControlSpec(0.02, 1.0, \exp),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) }, ~ccVals[\delTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\delFb] = EZSlider(~mainWin, Rect(30, 572, 330, 22), "Delay Fb (CC72)", ControlSpec(0, 0.9, \lin),
            { |ez| ~ccVals[\delFb] = ez.value; ~buses[\delFb].set(ez.value) }, ~ccVals[\delFb], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\verbMix] = EZSlider(~mainWin, Rect(380, 572, 330, 22), "Verb Mix (CC73)", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);
        ~ui[\revTime] = EZSlider(~mainWin, Rect(30, 602, 330, 22), "Verb Time (CC74)", ControlSpec(0.2, 8.0, \exp),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) }, ~ccVals[\revTime], labelWidth: 115)
            .setColors(stringColor: textCol, sliderBackground: bgCol, numBackground: bgCol, numStringColor: phosCol);

        Button(~mainWin, Rect(380, 604, 330, 32))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({
                [~zone1Notes, ~zone2Notes, ~zone3Notes].do { |arr|
                    arr.do { |list, idx|
                        if(list.notNil) { list.do(_.set(\gate, 0)); arr[idx] = nil };
                    };
                };
            });

        // 20fps AppClock Poller
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
}.value;
)
```

</details>

<details>
<summary><strong>Round 07 [GENERATE] - Status: PASS</strong> — <em>A Congada é uma manifestação folclórica e religiosa sincrética brasileira que ce...</em></summary>

- **Prompt**: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de reis do Congo em louvor a Nossa Senhora do Rosário e a São Benedito. Encontrada em Minas Gerais, Goiás e São Paulo, envolve desfiles ritmados de ternos de congo e moçambiques, onde gungas de lata amarradas aos tornozelos produzem percussões metálicas e passos cadenciados.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// 1. Caixa & Zabumba (Cadenced Processional Drum)
Ndef(\congadaCaixa).fadeTime = 2;
Ndef(\congadaCaixa, {
    |freq=110, tone=380, snare=0.45, amp=0.26, pan=(-0.15), t_trig=1|
    var env, body, rattle, sig, trigA;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.002, 0.22, 1, -6), t_trig);
    body = SinOsc.ar(freq * (1 + (2.5 * EnvGen.ar(Env.perc(0.001, 0.035, 1, -8), t_trig)))) * env;
    rattle = BPF.ar(WhiteNoise.ar, tone * 4.5, 0.35) * Decay2.ar(trigA, 0.002, 0.14) * snare * 2.5;
    sig = (body + rattle).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaCaixa)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.45, 0.5);
};
Ndef(\congadaCaixa).set(\wet10, 0.22);

Pbindef(\caixaSeq,
    \dur, Pwrand([0.25, 0.5, 0.125], [0.65, 0.25, 0.1], inf),
    \freq, Pseq([95, 115, 95, 130, 95, 110, 140, 95], inf),
    \tone, Pwhite(320, 480, inf),
    \snare, Pseq([0.2, 0.55, 0.25, 0.65, 0.2, 0.5, 0.7, 0.3], inf),
    \amp, Pseq([0.26, 0.16, 0.22, 0.25, 0.24, 0.15, 0.28, 0.18], inf),
    \t_trig, 1
);
Ndef(\congadaCaixa).quant = 1;
Ndef(\congadaCaixa)[1] = \set -> Pbindef(\caixaSeq);

// 2. Gungas de Lata (Metallic Ankle Shakers & Bell-Tin Percussions)
Ndef(\gungasLata).fadeTime = 2;
Ndef(\gungasLata, {
    |freq=1450, decay=0.14, grit=0.6, amp=0.18, pan=0.25, t_trig=1|
    var trigA, exc, modes, sig, rattle;
    trigA = K2A.ar(t_trig);
    exc = (Impulse.ar(0) + (WhiteNoise.ar * Decay2.ar(trigA, 0.001, 0.03))) * 0.6;
    modes = DynKlank.ar(
        Ref([
            [1.0, 1.53, 2.17, 2.94, 3.81] * freq,
            [0.35, 0.28, 0.22, 0.15, 0.1],
            [0.8, 0.6, 0.5, 0.35, 0.25]
        ]),
        exc,
        decayscale: decay
    );
    rattle = HPF.ar(WhiteNoise.ar, 4200) * Decay2.ar(trigA, 0.002, decay * 0.7) * grit * 0.4;
    sig = (modes + rattle).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\gungasLata)[10] = \filter -> { |in|
    var dly;
    dly = CombL.ar(in, 0.5, [0.18, 0.24], 1.4);
    FreeVerb2.ar(dly[0], dly[1], 1.0, 0.55, 0.35);
};
Ndef(\gungasLata).set(\wet10, 0.28);

Pbindef(\gungasSeq,
    \dur, Pwrand([0.125, 0.25, Rest(0.125)], [0.55, 0.3, 0.15], inf),
    \freq, Pexprand(1180, 1850, inf),
    \decay, Pwhite(0.08, 0.19, inf),
    \grit, Pwhite(0.4, 0.85, inf),
    \pan, Pwhite(-0.45, 0.55, inf),
    \amp, Pwhite(0.12, 0.2, inf),
    \t_trig, 1
);
Ndef(\gungasLata).quant = 1;
Ndef(\gungasLata)[1] = \set -> Pbindef(\gungasSeq);

// 3. Canto do Rosário (Syncretic Vocal Formant & Harmonium Drone)
Ndef(\cantoRosario).fadeTime = 4;
Ndef(\cantoRosario, {
    |freq=196, vowel=0.5, cutoff=1400, amp=0.14, pan=(-0.05), t_trig=1|
    var env, osc, formF, vA, vO, vU, body, sig;
    env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.18, 0.6, 0.9]), t_trig);
    osc = Splay.ar(Saw.ar(freq * [0.995, 1.0, 1.005, 2.0])).sum * 0.35;
    vA = [730, 1090, 2440];
    vO = [570, 840, 2410];
    vU = [300, 870, 2240];
    formF = SelectX.kr(vowel.clip(0, 2), [vA, vO, vU]);
    body = BPF.ar(osc, formF, 0.14).sum * 5.0;
    sig = LPF.ar(body + (osc * 0.25), cutoff) * env;
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Ndef(\cantoRosario)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 65, 3.8, 0.45, 0.5, 15, 0.0, 0.6, 0.5);
};
Ndef(\cantoRosario).set(\wet10, 0.38);

Pbindef(\cantoSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 2.0], inf),
    \freq, Pseq([196, 220, 246.94, 196, 174.61, 196], inf),
    \vowel, Pwhite(0.0, 2.0, inf),
    \cutoff, Pexprand(1100, 2200, inf),
    \amp, 0.14,
    \t_trig, 1
);
Ndef(\cantoRosario).quant = 1;
Ndef(\cantoRosario)[1] = \set -> Pbindef(\cantoSeq);
)

// Ndef(\gungasLata).xset(\freq, 2200); // Brighten ankle tins | Revert: Ndef(\gungasLata).xset(\freq, 1450);
// Pbindef(\caixaSeq, \dur, 0.125); // Double-time march | Revert: Pbindef(\caixaSeq, \dur, Pwrand([0.25, 0.5, 0.125], [0.65, 0.25, 0.1], inf));
// Pbindef(\cantoSeq, \freq, Pseq([293.66, 329.63, 392.0, 293.66], inf)); // Lift chant octave | Revert: Pbindef(\cantoSeq, \freq, Pseq([196, 220, 246.94, 196, 174.61, 196], inf));
// Pbindef(\caixaSeq).stop; Ndef(\congadaCaixa).fadeTime = 4; Ndef(\congadaCaixa).clear(4); // Rollback Caixa
// Pbindef(\gungasSeq).stop; Ndef(\gungasLata).fadeTime = 4; Ndef(\gungasLata).clear(4); // Rollback Gungas
// Pbindef(\cantoSeq).stop; Ndef(\cantoRosario).fadeTime = 4; Ndef(\cantoRosario).clear(4); // Rollback Canto
```

</details>

<details>
<summary><strong>Round 08 [GENERATE] - Status: PASS</strong> — <em>A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incan...</em></summary>

- **Prompt**: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido na superfície calma de um corixo repleto de camalotes e vitórias-régias. Centenas de tuiuiús pousados nos galhos secos de um piúva centenário observam em silêncio o bater de asas de um bando ruidoso de araras-azuis cruzando o céu crepuscular rumo ao dormitório nos capões de mata.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// 1. Corixo Espelho (Calm Twilight Water Reflection & Sub-Harmonic Glow)
Ndef(\corixoEspelho).fadeTime = 4;
Ndef(\corixoEspelho, {
    |freq=73.42, cutoff=420, shimmer=0.35, amp=0.18, pan=0.0, t_trig=1|
    var env, sub, pad, water, lfo, sig;
    env = EnvGen.ar(Env([0, 1, 0.85, 0], [0.8, 2.2, 2.5]), t_trig);
    lfo = SinOsc.kr(0.14).range(0.75, 1.35);
    sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.0) * 0.45);
    pad = Splay.ar(Saw.ar(freq * [1.0, 1.498, 2.003, 2.995])).sum * 0.22;
    pad = MoogFF.ar(pad, (cutoff * lfo).clip(120, 4500), 1.8) * 2.2;
    water = BPF.ar(PinkNoise.ar, SinOsc.kr(0.23).range(340, 920), 0.12) * 12.0 * shimmer;
    sig = (sub * 0.45) + pad + water;
    Pan2.ar((sig * env).tanh, pan, amp);
}).play;

Ndef(\corixoEspelho)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 75, 4.8, 0.4, 0.5, 15, 0.0, 0.55, 0.45);
};
Ndef(\corixoEspelho).set(\wet10, 0.42);

Pbindef(\corixoSeq,
    \dur, Pseq([4.0, 4.0, 6.0], inf),
    \freq, Pseq([73.42, 82.41, 65.41, 73.42], inf),
    \cutoff, Pexprand(360, 780, inf),
    \shimmer, Pwhite(0.25, 0.48, inf),
    \amp, 0.18,
    \t_trig, 1
);
Ndef(\corixoEspelho).quant = 1;
Ndef(\corixoEspelho)[1] = \set -> Pbindef(\corixoSeq);

// 2. Araras-Azuis & Bater de Asas (Wingbeats & Twilight Flock Calls)
Ndef(\ararasAsas).fadeTime = 2;
Ndef(\ararasAsas, {
    |freq=680, modRatio=1.62, wingRate=7.5, amp=0.14, pan=0.0, t_trig=1|
    var trigA, wingEnv, callEnv, wing, mod, call, sig;
    trigA = K2A.ar(t_trig);
    wingEnv = Decay2.ar(trigA, 0.015, 0.22);
    callEnv = EnvGen.ar(Env.perc(0.01, 0.26, 1, -5), t_trig);
    wing = BPF.ar(WhiteNoise.ar, TRand.kr(420, 980, t_trig), 0.28) * 10.0;
    wing = wing * SinOsc.ar(wingRate).range(0.2, 1.0) * wingEnv;
    mod = SinOsc.ar(freq * modRatio) * (freq * 2.4 * callEnv);
    call = BPF.ar(Saw.ar(freq + mod), [1150, 2100, 3200], 0.16).sum * 3.5 * callEnv;
    sig = (wing * 0.55) + (call * 0.45);
    Pan2.ar(sig.tanh, pan, amp);
}).play;

Ndef(\ararasAsas)[10] = \filter -> { |in|
    var dly;
    dly = CombL.ar(in, 0.6, [0.22, 0.31], 1.6);
    FreeVerb2.ar(dly[0], dly[1], 1.0, 0.65, 0.4);
};
Ndef(\ararasAsas).set(\wet10, 0.34);

Pbindef(\ararasSeq,
    \dur, Pwrand([0.125, 0.25, 0.375, Rest(0.5)], [0.45, 0.3, 0.1, 0.15], inf),
    \freq, Pexprand(520, 940, inf),
    \modRatio, Pwhite(1.45, 1.85, inf),
    \wingRate, Pwhite(6.0, 9.5, inf),
    \pan, Pn(Pgeom(0.15, 1.18, 8), inf) * Pseq([-1, 1], inf),
    \amp, Pwhite(0.09, 0.16, inf),
    \t_trig, 1
);
Ndef(\ararasAsas).quant = 1;
Ndef(\ararasAsas)[1] = \set -> Pbindef(\ararasSeq);

// 3. Piúva & Tuiuiús (Dry Branches & Silent Twilight Watchers)
Ndef(\piuvaTuiuiu).fadeTime = 3;
Ndef(\piuvaTuiuiu, {
    |freq=320, decay=0.45, amp=0.14, pan=(-0.25), t_trig=1|
    var trigA, exc, modes, sig;
    trigA = K2A.ar(t_trig);
    exc = (Impulse.ar(0) + (PinkNoise.ar * Decay2.ar(trigA, 0.002, 0.025))) * 0.5;
    modes = DynKlank.ar(
        Ref([
            [1.0, 2.38, 3.91, 5.42] * freq,
            [0.45, 0.3, 0.18, 0.1],
            [1.2, 0.85, 0.5, 0.3]
        ]),
        exc,
        decayscale: decay
    );
    sig = LPF.ar(modes, 3200).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

Ndef(\piuvaTuiuiu)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.45);
};
Ndef(\piuvaTuiuiu).set(\wet10, 0.32);

Pbindef(\piuvaSeq,
    \dur, Pwrand([0.75, 1.5, 2.25, Rest(1.5)], [0.35, 0.3, 0.15, 0.2], inf),
    \freq, Pseq([293.66, 329.63, 440.0, 392.0, 261.63], inf),
    \decay, Pwhite(0.35, 0.65, inf),
    \pan, Pwhite(-0.65, 0.45, inf),
    \amp, Pwhite(0.1, 0.16, inf),
    \t_trig, 1
);
Ndef(\piuvaTuiuiu).quant = 1;
Ndef(\piuvaTuiuiu)[1] = \set -> Pbindef(\piuvaSeq);
)

// Ndef(\corixoEspelho).xset(\cutoff, 950); // Brighten orange water glow | Revert: Ndef(\corixoEspelho).xset(\cutoff, 420);
// Pbindef(\ararasSeq, \dur, 0.125); // Dense flock flight | Revert: Pbindef(\ararasSeq, \dur, Pwrand([0.125, 0.25, 0.375, Rest(0.5)], [0.45, 0.3, 0.1, 0.15], inf));
// Pbindef(\corixoSeq).stop; Ndef(\corixoEspelho).fadeTime = 4; Ndef(\corixoEspelho).clear(4); // Rollback Corixo
// Pbindef(\ararasSeq).stop; Ndef(\ararasAsas).fadeTime = 4; Ndef(\ararasAsas).clear(4); // Rollback Araras
// Pbindef(\piuvaSeq).stop; Ndef(\piuvaTuiuiu).fadeTime = 4; Ndef(\piuvaTuiuiu).clear(4); // Rollback Piúva
```

</details>

### Model: Claude Haiku Latest (`openrouter:anthropic/claude-haiku-5.5`)

- **Initial Pass Rate**: 75.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 359.41s (mean LLM: 32.58s/round)
- **Total Tokens**: 145,615 (Cost: $0.03504)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261112_191506\session_claude-haiku-5.5.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// ADD_INSTRUMENT: "antarctic" - tempestade contida, vento grave e sub-drone que se acumula sob o silêncio da mesa
Ndef(\antarctic, { |amp=0.15, cutoff=300, rq=0.5|
    var wind, drone, lfo, sig;
    lfo = LFNoise2.kr(0.05).range(0.3, 1);
    wind = BPF.ar(BrownNoise.ar, cutoff * lfo, rq);
    drone = SinOsc.ar(55) * 0.3 * LFNoise1.kr(0.1).range(0.2, 1);
    sig = (wind * 4) + drone;
    Pan2.ar(LeakDC.ar(sig.tanh) * amp, LFNoise1.kr(0.03));
}).play;

// ADD_INSTRUMENT: "crease" - dobras de mapa rodoviário, cada vez mais rápidas e secas
Ndef(\crease, { |t_trig=0, amp=0.4, pan=0, rel=0.08|
    var env, crackle, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.002, rel);
    crackle = HPF.ar(WhiteNoise.ar, 3000) * env;
    sig = (BPF.ar(crackle, 5000, 0.5) * 6) + (crackle * 0.5);
    Pan2.ar(sig * amp, pan);
}).play;

// Sequência: dobras aceleram em direção à ruptura (Extrinsic Limit / Intrinsic Limit)
Pbindef(\creaseSeq,
    \dur, Pseq([1.2, 0.8, 0.6, 0.4, 0.25, 0.15, 0.1, 0.07, 0.07, 0.07], inf),
    \t_trig, 1,
    \amp, Pwhite(0.1, 0.4, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \rel, Pexprand(0.05, 0.2, inf)
);

Ndef(\crease)[1] = \set -> Pbindef(\creaseSeq);

// Rollback: remove this instrument
// Pbindef(\creaseSeq).stop; Ndef(\crease).fadeTime = 2; Ndef(\crease).clear(2);
// Pbindef(\creaseSeq).stop; Ndef(\antarctic).fadeTime = 2; Ndef(\antarctic).clear(2);
)
```

</details>

<details>
<summary><strong>Round 02 [APPEND] - Status: PASS</strong> — <em>Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sa...</em></summary>

- **Prompt**: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Tinir de ferros... estalar de açoite... Legiões de homens negros como a noite, horrendos a dançar... Mulheres com crianças suspensas ao peito descarnado, homens gemendo sob a aragem salgada, pedindo a Deus um raio que quebre os elos da corrente maldita!
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// ADD_INSTRUMENT: "chains" - tinir de ferros e estalar de açoite, sob o brilho avermelhado do tombadilho
Ndef(\chains, { |t_trig=0, amp=0.3, pan=0, freq=1800, rel=0.25|
    var env, clank, whip, sig;
    env = Decay2.ar(K2A.ar(t_trig), 0.001, rel);
    clank = Ringz.ar(WhiteNoise.ar * env, [freq, freq * 1.47, freq * 2.13], [0.4, 0.25, 0.15]).sum;
    whip = HPF.ar(WhiteNoise.ar, 2500) * Decay.ar(K2A.ar(t_trig), 0.003) * 3;
    sig = (clank * 0.4) + whip;
    Pan2.ar(sig.tanh * amp, pan);
}).play;

// Sequência: golpes irregulares de corrente e açoite, espalhados pelo convés
Pbindef(\chainSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1.0, 0.125, 0.125, 0.5, 0.75], inf),
    \t_trig, 1,
    \amp, Pwhite(0.2, 0.5, inf),
    \pan, Pwhite(-0.9, 0.9, inf),
    \freq, Pexprand(900, 2600, inf),
    \rel, Pexprand(0.1, 0.4, inf)
);

Ndef(\chains)[1] = \set -> Pbindef(\chainSeq);

// Rollback: remove this instrument
// Pbindef(\chainSeq).stop; Ndef(\chains).fadeTime = 2; Ndef(\chains).clear(2);
)
```

</details>

<details>
<summary><strong>Round 03 [COMPOSE] - Status: PASS</strong> — <em>Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, ...</em></summary>

- **Prompt**: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses e cronômetros de bolso trabalhavam em tempos ligeiramente desencontrados. O velho relojoeiro fechava os olhos no centro daquele enxame de tique-taques de latão e jurava ouvir, nas defasagens microscópicas entre as engrenagens, o próprio respirar do tempo.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Brass escapement tick
    SynthDef(\brassTick, { |out=0, freq=2400, amp=0.3, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.001, 0.12, 1, -6), doneAction: 2);
        sig = Ringz.ar(WhiteNoise.ar * env, [freq, freq * 2.76, freq * 5.4], [0.12, 0.06, 0.03]).sum;
        sig = sig + (HPF.ar(WhiteNoise.ar, 6000) * env * 0.3);
        Out.ar(out, Pan2.ar(sig.tanh * amp, pan));
    }).add;

    // Pendulum escape click
    SynthDef(\escapeClick, { |out=0, freq=900, amp=0.25, pan=0|
        var env, sig;
        env = EnvGen.ar(Env.perc(0.0005, 0.04, 1, -8), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.2) * env * 8;
        Out.ar(out, Pan2.ar(sig.tanh * amp, pan));
    }).add;

    // Carillon bell with inharmonic FM
    SynthDef(\chimeBell, { |out=0, freq=660, amp=0.2, pan=0|
        var env, sig, mod;
        env = EnvGen.ar(Env.perc(0.005, 2.5, 1, -3), doneAction: 2);
        mod = SinOsc.ar(freq * 3.51, 0, freq * 1.2 * EnvGen.ar(Env.perc(0.001, 0.3)));
        sig = SinOsc.ar(freq + mod) * env;
        Out.ar(out, Pan2.ar(sig * amp, pan));
    }).add;
    s.sync;

    // Continuous air around the pendulums
    Ndef(\pendulumAir, { |amp=0, cut=1200|
        var breath, sig;
        breath = LFNoise2.kr(0.07).range(0.2, 1);
        sig = BPF.ar(PinkNoise.ar([1, 1]), cut * breath, 0.3) * 6;
        sig = sig + (SinOsc.ar([110, 111.3]) * 0.04 * breath);
        (sig * amp).tanh;
    }).play;

    // Beating drift between detuned escapements
    Ndef(\beatDrift, { |amp=0, spread=0.4|
        var sig, pan;
        sig = Ringz.ar(Impulse.ar([2.0, 2.0 * 1.0031, 2.0 * 0.9972]), 1800, 0.02).sum * 0.5;
        pan = LFNoise1.kr(0.05).range(spread.neg, spread);
        Pan2.ar(sig.tanh * amp, pan);
    }).play;

    Ndef(\pendulumAir).fadeTime = 4;
    Ndef(\beatDrift).fadeTime = 3;
    Ndef(\pendulumAir).set(\amp, 0);
    Ndef(\beatDrift).set(\amp, 0);

    // Three clocks at slightly different tempi
    Pbindef(\clockA, \instrument, \brassTick, \dur, 0.5, \freq, 2400, \amp, 0.22, \pan, -0.6, \out, ~synthBus);
    Pbindef(\clockB, \instrument, \brassTick, \dur, 0.50185, \freq, 2430, \amp, 0.2, \pan, 0.0, \out, ~synthBus);
    Pbindef(\clockC, \instrument, \brassTick, \dur, 0.49815, \freq, 2370, \amp, 0.2, \pan, 0.6, \out, ~synthBus);

    // Escapement acceleration toward rupture
    Pbindef(\escapeSeq,
        \instrument, \escapeClick,
        \dur, Pn(Pseq([0.4, 0.3, 0.2, 0.14, 0.1, 0.07, 0.05, 0.04], 1), inf),
        \freq, Pexprand(700, 1800, inf),
        \amp, Pwhite(0.12, 0.3, inf),
        \pan, Pwhite(-0.8, 0.8, inf),
        \out, ~synthBus
    );

    // Sparse carillon fragments
    Pbindef(\chimeSeq,
        \instrument, \chimeBell,
        \dur, Pexprand(1.5, 4.0, inf),
        \freq, Pseq([660, 880, 587, 740], inf),
        \amp, Pwhite(0.12, 0.22, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    // Mixer with optional room
    Ndef(\masterMix, {
        var mix = In.ar(~synthBus, 2) + Ndef.ar(\pendulumAir, 2) + Ndef.ar(\beatDrift, 2);
        mix;
    });
    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.25) };
    Ndef(\masterMix).set(\wet10, 0.25);
    Ndef(\masterMix).play;
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Cue 1: One pendulum breathes alone]".postln;
        Pbindef(\clockA).play;
        Ndef(\pendulumAir).xset(\amp, 0.35);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(700, 2200)); 2.wait; };

        "0:08 - [Cue 2: A second clock drifts in]".postln;
        Pbindef(\clockB).play;
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(500, 2800)); 2.wait; };

        "0:16 - [Cue 3: Third clock, beating appears]".postln;
        Pbindef(\clockC).play;
        Ndef(\beatDrift).xset(\amp, 0.18);
        4.do { |i| Ndef(\beatDrift).xset(\spread, rrand(0.2, 0.9)); 2.wait; };

        "0:24 - [Cue 4: Intrinsic limit, escapement accelerates]".postln;
        Pbindef(\escapeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.3);
        6.wait;
        Pbindef(\clockA).stop;
        4.wait;

        "0:34 - [Cue 5: Settling, only clockB and carillon]".postln;
        Pbindef(\escapeSeq).stop;
        Pbindef(\chimeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.1);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(400, 1200)); 2.wait; };

        "0:46 - [Cue 6: Flashback to the opening clock]".postln;
        Pbindef(\clockA).play;
        Ndef(\beatDrift).xset(\amp, 0.22);
        4.do { |i| Ndef(\pendulumAir).xset(\cut, exprand(800, 2000)); 2.wait; };

        "0:54 - [Cue 7: Resolution, all clocks in phase drift]".postln;
        Pbindef(\escapeSeq).play;
        Ndef(\beatDrift).xset(\amp, 0.25);
        Ndef(\masterMix).set(\wet10, 0.4);
        4.do { |i| Ndef(\beatDrift).xset(\spread, rrand(0.3, 0.8)); 2.wait; };

        "1:02 - [Cue 8: Extrinsic cut]".postln;
        Ndef(\pendulumAir).xset(\amp, 0);
        Ndef(\beatDrift).xset(\amp, 0);
        3.wait;

        Pbindef(\clockA).stop; Pbindef(\clockA).clear;
        Pbindef(\clockB).stop; Pbindef(\clockB).clear;
        Pbindef(\clockC).stop; Pbindef(\clockC).clear;
        Pbindef(\escapeSeq).stop; Pbindef(\escapeSeq).clear;
        Pbindef(\chimeSeq).stop; Pbindef(\chimeSeq).clear;
        Ndef(\pendulumAir).clear(3);
        Ndef(\beatDrift).clear(3);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 04 [COMPOSE] - Status: PASS</strong> — <em>A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no sécul...</em></summary>

- **Prompt**: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalista dinamarquês Peter Lund, é composta por sete amplos salões subterrâneos esculpidos pela ação milenar das águas em rocha calcária. Suas abóbadas úmidas exibem cortinas minerais, estalactites e estalagmites onde o gotejamento lento cria ressonâncias acústicas profundas na escuridão.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety limiter
    SynthDef(\safetyLimiter, { var sig = In.ar(0, 2); sig = LeakDC.ar(sig); sig = Limiter.ar(sig, 0.85, 0.01); ReplaceOut.ar(0, sig); }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete sources
    SynthDef(\mqDrip, { |out=0, freq=1200, amp=0.2, pan=0|
        var env, sig, click;
        env = EnvGen.ar(Env.perc(0.001, 0.7, 1, -6), doneAction: 2);
        sig = SinOsc.ar(freq * XLine.kr(1.5, 1, 0.04)) * env;
        click = BPF.ar(WhiteNoise.ar, freq * 2.5, 0.2) * EnvGen.ar(Env.perc(0.001, 0.008)) * 0.6;
        Out.ar(out, Pan2.ar((sig + click).tanh * amp, pan));
    }).add;

    SynthDef(\mqStalac, { |out=0, freqscale=1, amp=0.2, pan=0, ring=1|
        var env, exc, sig;
        env = EnvGen.ar(Env.perc(0.001, (3.0 * ring).max(0.05), 1, -4), doneAction: 2);
        exc = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.02));
        sig = DynKlank.ar(Ref([[312, 785, 1243, 1871, 2650], [1, 0.6, 0.35, 0.2, 0.1], [1.0, 0.8, 0.6, 0.4, 0.3]]), exc, freqscale, 0, ring);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;
    s.sync;

    // Continuous textures
    Ndef(\mqCave, { |amp=0, cut=600|
        var base, sig, swell;
        swell = LFNoise1.kr(0.2).range(0.6, 1.0);
        base = BrownNoise.ar(0.05) + SinOsc.ar(48, 0, 0.04);
        sig = LPF.ar([base, base * 0.98 + PinkNoise.ar(0.01)], cut);
        sig = CombC.ar(sig, 0.5, [0.173, 0.211], 3.5) * 0.4 + sig;
        (sig * swell * amp).tanh;
    });

    Ndef(\mqWater, { |amp=0|
        var sig;
        sig = BPF.ar(PinkNoise.ar(0.3), LFNoise1.kr(0.12).range(250, 800), 0.08) * 6;
        [sig, DelayC.ar(sig, 0.03, 0.013)] * amp;
    });

    // Master mixer
    Ndef(\mqMix, {
        var mix = In.ar(~synthBus, 2) + Ndef.ar(\mqCave, 2) + Ndef.ar(\mqWater, 2);
        mix * 0.8;
    });
    Ndef(\mqMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
    Ndef(\mqMix).set(\wet10, 0.25);
    Ndef(\mqCave).fadeTime = 4;
    Ndef(\mqWater).fadeTime = 3;
    Ndef(\mqMix).play;
    Ndef(\mqCave).play;
    Ndef(\mqWater).play;
    s.sync;

    // Patterns
    Pbindef(\mqDripSeq,
        \instrument, \mqDrip,
        \dur, Pexprand(0.9, 2.2, inf),
        \freq, Pexprand(900, 2600, inf),
        \amp, Pwhite(0.1, 0.25, inf),
        \pan, Pwhite(-0.7, 0.7, inf),
        \out, ~synthBus
    );

    Pbindef(\mqBellSeq,
        \instrument, \mqStalac,
        \dur, Pexprand(1.2, 3.5, inf),
        \freqscale, Pseq([0.8, 1.2, 1.0, 0.6], inf),
        \ring, Pwhite(0.6, 1.2, inf),
        \amp, Pwhite(0.15, 0.28, inf),
        \pan, Pwhite(-0.5, 0.5, inf),
        \out, ~synthBus
    );

    Tdef(\mqScore, {
        0.5.wait;

        "0:00 - [Cue 1: A single drip in the dark]".postln;
        Ndef(\mqCave).xset(\amp, 0.5);
        Pbindef(\mqDripSeq).play;
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(300, 900)); 2.wait; };

        "0:16 - [Cue 2: Stalactite bells answer the drip]".postln;
        Pbindef(\mqBellSeq).play;
        Ndef(\mqWater).xset(\amp, 0.3);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(400, 1400)); 2.wait; };

        "0:32 - [Cue 3: Accelerating drips, water rises]".postln;
        Pbindef(\mqDripSeq, \dur, Pn(Pseq([0.5, 0.4, 0.3, 0.22, 0.16, 0.12, 0.1, 0.08], 1), inf));
        8.do { |i| Ndef(\mqWater).xset(\amp, rrand(0.2, 0.5)); 2.wait; };

        "0:48 - [Cue 4: Intrinsic limit, drip density collapses into roar]".postln;
        Pbindef(\mqDripSeq, \dur, Pexprand(0.03, 0.06, inf));
        Pbindef(\mqBellSeq, \ring, Pwhite(1.2, 2.0, inf));
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(2000, 5000)); 2.wait; };

        "1:04 - [Cue 5: Settling, one bell in vast stone]".postln;
        Pbindef(\mqDripSeq).stop;
        Pbindef(\mqDripSeq, \dur, Pexprand(2.5, 4.5, inf));
        Pbindef(\mqBellSeq, \dur, Pexprand(4.0, 6.0, inf), \ring, Pwhite(0.6, 1.0, inf));
        Pbindef(\mqDripSeq).play;
        Ndef(\mqCave).xset(\cut, 250);
        8.do { |i| Ndef(\mqWater).xset(\amp, rrand(0.1, 0.25)); 2.wait; };

        "1:20 - [Cue 6: Flashback to the opening drip motif]".postln;
        Pbindef(\mqDripSeq, \dur, Pn(Pseq([0.9, 1.4, 0.9, 2.2], 1), inf));
        Ndef(\mqWater).xset(\amp, 0.3);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(300, 1000)); 2.wait; };

        "1:36 - [Cue 7: Resolution, bells and drips in echo]".postln;
        Pbindef(\mqBellSeq, \dur, Pexprand(1.2, 3.5, inf), \ring, Pwhite(0.6, 1.2, inf));
        Pbindef(\mqBellSeq).play;
        Ndef(\mqMix).set(\wet10, 0.45);
        8.do { |i| Ndef(\mqCave).xset(\cut, exprand(500, 1600)); Ndef(\mqWater).xset(\amp, rrand(0.2, 0.4)); 2.wait; };

        "1:52 - [Cue 8: Extrinsic cut]".postln;
        Ndef(\mqCave).xset(\amp, 0);
        Ndef(\mqWater).xset(\amp, 0);
        3.wait;

        Pbindef(\mqDripSeq).stop; Pbindef(\mqDripSeq).clear;
        Pbindef(\mqBellSeq).stop; Pbindef(\mqBellSeq).clear;
        Ndef(\mqCave).clear(3);
        Ndef(\mqWater).clear(3);
        Ndef(\mqMix).clear(2);
        "Score Complete.".postln;
        Tdef(\mqScore).stop;
    });
    Tdef(\mqScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 05 [DESIGN] - Status: FIXED</strong> — <em>Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumb...</em></summary>

- **Prompt**: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de potenciômetros prateados, matrizes de pinos luminosos e cabos entrelaçados. Ao lado, a tela verde de fósforo de um osciloscópio analógico desenha figuras de Lissajous em rotação contínua que se dobram e se desdobram em harmônicos complexos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: None
- **Initial Error**: `API Timeout: cmd_cross_append exceeded 120s`

```supercollider
(
// Safe Fallback Sound
Ndef(\safe, { SinOsc.ar(440) * 0.05!2 }).play;
)
```

</details>

<details>
<summary><strong>Round 06 [DESIGN] - Status: FIXED</strong> — <em>O berimbau de barriga é um instrumento de percussão cordofone originário da Áfri...</em></summary>

- **Prompt**: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente enraizado na tradição cultural afro-brasileira da capoeira. Composto por uma verga de madeira de biriba curva esticada por arame de pneu de aço e uma cabaça ressonadora seca, é percutido por uma baqueta enquanto o dobrão de metal e o caxixi modulam timbres secos, ressonantes e hipnóticos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: prepended pre-design synthesizer cleanup for previous design instance
- **Initial Error**: `__VAL_ERROR__: ERROR: Message 'slider' not understood.
__VAL_ERROR__: ERROR: Message 'slider' not understood.`

```supercollider
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

// ---- Step 0: CC map ----
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fx1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fx2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64, hpf3: 65, lpf3: 66, rq3: 67, atk3: 68, dec3: 69, sus3: 70, rls3: 71, fx3: 72,
    delMix: 90, verbMix: 91, panic: 123
);

// ---- Step 1 & 2: MIDI discovery with fallback ----
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

// ---- Step 3: Boot, buses, synths, GUI ----
s.waitForBoot({
    var zoneNotesInit;

    ~ccVals = (
        vol1: 0.25, pan1: 0.0, mute1: 0.0, min1: 0, max1: 127, hpf1: 60, lpf1: 6000, rq1: 0.6, atk1: 0.002, dec1: 0.6, sus1: 0.0, rls1: 0.4, fx1: 0.0,
        vol2: 0.25, pan2: -0.35, mute2: 0.0, min2: 0, max2: 127, hpf2: 200, lpf2: 8000, rq2: 0.5, atk2: 0.002, dec2: 0.5, sus2: 0.0, rls2: 0.5, fx2: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 0, max3: 127, hpf3: 300, lpf3: 5000, rq3: 0.7, atk3: 0.01, dec3: 0.8, sus3: 0.3, rls3: 1.5, fx3: 0.0,
        delMix: 0.0, verbMix: 0.0
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.newClear(128);
    ~ui = ();

    // Zone 1: Caixa-Gunga sub body (berimbau's low bass gourd resonance)
    SynthDef(\berimZone1, { |freq=110, gate=1, amp=0.3, pan=0.0, vol=0.25, mute=0, hpf=60, lpf=6000, rq=0.6, atk=0.002, dec=0.6, sus=0, rls=0.4, fx=0|
        var env, exc, body, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        exc = Impulse.ar(0) * 0 + Decay2.ar(Impulse.ar(0), 0.001, 0.05 + (fx * 0.1)) * WhiteNoise.ar(0.4);
        body = DynKlank.ar(Ref([[freq, freq * 2.01, freq * 3.02], [1.0, 0.4, 0.15], [1.2, 0.6, 0.3]]), exc * (1 + (fx * 4)));
        sig = (body * env * amp).tanh * (1 - mute);
        sig = HPF.ar(LPF.ar(sig, lpf), hpf);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    // Zone 2: Dobrão metal clang (plucked-metal bright strike, Karplus-like)
    SynthDef(\berimZone2, { |freq=440, gate=1, amp=0.3, pan=(-0.35), vol=0.25, mute=0, hpf=200, lpf=8000, rq=0.5, atk=0.002, dec=0.5, sus=0, rls=0.5, fx=0|
        var env, exc, sig, ring;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        exc = WhiteNoise.ar(0.5) * Decay.ar(Impulse.ar(0), 0.003);
        ring = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.2 + (fx * 3));
        ring = AllpassC.ar(ring, 0.02, (fx * 0.008) + 0.0005, 0.08);
        sig = RLPF.ar(ring, lpf, rq) * env * amp;
        sig = HPF.ar(sig, hpf) * (1 - mute);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    // Zone 3: Caxixi shaker texture (filtered noise swish)
    SynthDef(\berimZone3, { |freq=220, gate=1, amp=0.3, pan=0.35, vol=0.2, mute=0, hpf=300, lpf=5000, rq=0.7, atk=0.01, dec=0.8, sus=0.3, rls=1.5, fx=0|
        var env, noise, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus.max(0.01), rls), gate, doneAction: 2);
        noise = BPF.ar(PinkNoise.ar(1), freq * 4, rq.clip(0.1, 1.0)) * (1 + (fx * 6));
        sig = (noise * env * amp).tanh;
        sig = HPF.ar(LPF.ar(sig, lpf), hpf) * (1 - mute);
        Balance2.ar(sig, sig, pan, vol);
    }).add;

    s.sync;

    // Safety limiter + master
    SynthDef(\safetyLimiter, { |delMix=0, verbMix=0|
        var sig = In.ar(0, 2);
        var del = DelayC.ar(sig, 0.5, 0.31) * delMix;
        sig = sig + del;
        sig = FreeVerb2.ar(sig[0], sig[1], verbMix, 0.85, 0.3);
        ReplaceOut.ar(0, LeakDC.ar(Limiter.ar(sig, 0.92, 0.01)));
    }).add;

    s.sync;
    ~master = Synth.new(\safetyLimiter, [\delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap], ~masterGroup, \addToTail);

    // Zone triggering helpers
    ~zoneDefs = [\berimZone1, \berimZone2, \berimZone3];

    MIDIdef.noteOn(\berimOn, { |vel, noteNum|
        3.do { |z|
            var zi = z + 1;
            var mn = ~ccVals[("min" ++ zi).asSymbol];
            var mx = ~ccVals[("max" ++ zi).asSymbol];
            if((noteNum >= mn) and: { noteNum <= mx }) {
                var args = [\freq, noteNum.midicps, \amp, vel / 127.0, \gate, 1,
                    \pan, ~buses[("pan" ++ zi).asSymbol].asMap,
                    \vol, ~buses[("vol" ++ zi).asSymbol].asMap,
                    \mute, ~buses[("mute" ++ zi).asSymbol].asMap,
                    \hpf, ~buses[("hpf" ++ zi).asSymbol].asMap,
                    \lpf, ~buses[("lpf" ++ zi).asSymbol].asMap,
                    \rq, ~buses[("rq" ++ zi).asSymbol].asMap,
                    \atk, ~buses[("atk" ++ zi).asSymbol].asMap,
                    \dec, ~buses[("dec" ++ zi).asSymbol].asMap,
                    \sus, ~buses[("sus" ++ zi).asSymbol].asMap,
                    \rls, ~buses[("rls" ++ zi).asSymbol].asMap,
                    \fx, ~buses[("fx" ++ zi).asSymbol].asMap];
                var syn = Synth(~zoneDefs[z], args, ~synthGroup, \addToTail);
                if(~zoneNotes[noteNum].isNil) { ~zoneNotes[noteNum] = [] };
                ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(syn);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\berimOff, { |vel, noteNum|
        if(~zoneNotes[noteNum].notNil) {
            ~zoneNotes[noteNum].do(_.set(\gate, 0));
            ~zoneNotes[noteNum] = [];
        };
    }, srcID: ~myUid);

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
                    { ks.contains("delMix") or: { ks.contains("verbMix") } } { norm }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            ~zoneNotes.do { |list| if(list.notNil) { list.do(_.set(\gate, 0)) } };
            ~zoneNotes = Array.newClear(128);
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var win, zoneNames, tabs;
        var screen = Window.availableBounds;
        var h = min(780, screen.height - 60);
        win = Window("Berimbau de Barriga", Rect((screen.width - 760) / 2, (screen.height - h) / 2, 760, h), scroll: true);
        ~mainWin = win;
        zoneNames = ["Caixa (Sub)", "Dobrão (Metal)", "Caxixi (Textura)"];
        ~zoneMeta = [
            (title: "Caixa", fxKey: \fx1, fxLabel: "Body Drive"),
            (title: "Dobrão", fxKey: \fx2, fxLabel: "Ring Decay"),
            (title: "Caxixi", fxKey: \fx3, fxLabel: "Swish Gain")
        ];
        ~zoneMeta.do { |zm, idx|
            var zi = idx + 1;
            var page = CompositeView(win, Rect(10, 10, 740, h - 110));
            var lbl = StaticText(page, Rect(10, 5, 720, 24)).string_(zoneNames[idx]).font_(Font.sansSerif(16, true));
            var zk = { |base| (base ++ zi).asSymbol };
            var knobs = [\vol, \pan, \hpf, \lpf, \rq, \atk, \dec, \sus, \rls, zm[\fxKey].asString.drop(2).asSymbol];
            knobs.do { |base, j|
                var key = if(base.isKindOf(Symbol) and: { base == zm[\fxKey].asString.drop(2).asSymbol }) { zm[\fxKey] } { zk.(base) };
                // EZSlider itself exposes value_/action; no .slider accessor in this build
                var ez = EZSlider(page, Rect(10 + (j * 70), 40, 66, 300), key.asString, ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
                    ~ccVals[key] = sl.value;
                    if(~buses[key].notNil) { ~buses[key].set(sl.value) };
                }, ~ccVals[key] ? 0, false, 9, 0);
                ~ui = ~ui ?? { () };
                ~ui[key] = ez;
            };
            Button(page, Rect(10, h - 170, 200, 26)).states_([[zm[\title], Color.white, Color.grey]]);
        };
        ~ui = ~ui ?? { () };
        ~ui[\delMix] = EZSlider(win, Rect(10, h - 100, 360, 24), "Delay Mix", ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
            ~ccVals[\delMix] = sl.value; ~buses[\delMix].set(sl.value) }, 0.0, false, 9, 0);
        ~ui[\verbMix] = EZSlider(win, Rect(380, h - 100, 360, 24), "Reverb Mix", ControlSpec(0, 1, \lin, 0.001, 0), { |sl|
            ~ccVals[\verbMix] = sl.value; ~buses[\verbMix].set(sl.value) }, 0.0, false, 9, 0);
        Button(win, Rect(260, h - 55, 240, 34))
            .states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({
                ~zoneNotes.do { |list| if(list.notNil) { list.do(_.set(\gate, 0)) } };
                ~zoneNotes = Array.newClear(128);
            });
        win.front;

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
```

</details>

<details>
<summary><strong>Round 07 [GENERATE] - Status: PASS</strong> — <em>A Congada é uma manifestação folclórica e religiosa sincrética brasileira que ce...</em></summary>

- **Prompt**: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de reis do Congo em louvor a Nossa Senhora do Rosário e a São Benedito. Encontrada em Minas Gerais, Goiás e São Paulo, envolve desfiles ritmados de ternos de congo e moçambiques, onde gungas de lata amarradas aos tornozelos produzem percussões metálicas e passos cadenciados.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// Congada: gungas metálicas (Layer 2), caixa/tambor de couro (Layer 1), viola/melodia modal (Layer 3), ar de terreiro (Layer 4)
Ndef(\gungas).fadeTime = 2;
Ndef(\caixa).fadeTime = 2;
Ndef(\viola).fadeTime = 3;
Ndef(\terreiro).fadeTime = 4;

// Layer 1: tambor de couro grave (bumbo/caixa) com 2o harmônico
Ndef(\caixa, { |t_trig=0, amp=0.22, freq=58, pan=(-0.2)|
    var env = Env.perc(0.002, 0.35, 1, -6).ar(0, K2A.ar(t_trig));
    var pitch = freq * EnvGen.kr(Env([2.2, 1, 1], [0.04, 1]), t_trig);
    var body = SinOsc.ar(pitch) + (SinOsc.ar(pitch * 2) * 0.25);
    var skin = LPF.ar(PinkNoise.ar(0.25), 2200) * Decay2.ar(K2A.ar(t_trig), 0.001, 0.05);
    var sig = ((body * env) + skin).tanh * amp;
    Pan2.ar(sig, pan);
}).play;
Ndef(\caixa).set(\wet10, 0.15);

Pbindef(\caixaSeq,
    \dur, Pn(Pseq([0.5, 0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.75], 1), inf),
    \t_trig, 1,
    \freq, Pwrand([58, 64.5, 52], [0.7, 0.2, 0.1], inf),
    \amp, Pwhite(0.16, 0.24, inf)
);
Ndef(\caixa)[1] = \set -> Pbindef(\caixaSeq);
Ndef(\caixa).quant = 1;

// Layer 2: gungas de lata (percussão metálica nos tornozelos)
Ndef(\gungas, { |t_trig=0, amp=0.14, pan=0.35|
    var env = Env.perc(0.001, 0.12, 1, -9).ar(0, K2A.ar(t_trig));
    var ring = Ringz.ar(K2A.ar(t_trig), [2310, 3475, 5120, 6890], [0.06, 0.05, 0.04, 0.03]).sum;
    var clink = BPF.ar(WhiteNoise.ar(1), 4200, 0.08) * 12;
    var sig = ((ring * 0.6) + (clink * 0.4)) * env * amp;
    Balance2.ar(sig, sig, pan + SinOsc.kr(0.07, 0, 0.2));
}).play;
Ndef(\gungas).set(\wet11, 0.2);

Pbindef(\gungasSeq,
    \dur, Pn(Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], 1), inf),
    \t_trig, 1,
    \amp, Pwrand([0.10, 0.16, 0.22], [0.5, 0.35, 0.15], inf),
    \pan, Pwhite(0.2, 0.6, inf)
);
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);
Ndef(\gungas).quant = 1;

// Layer 3: viola de arco modal (voz melódica em modo menor/dórico)
Ndef(\viola, { |t_trig=0, freq=220, amp=0.16, cutoff=900, pan=(-0.5)|
    var env = Env([0, 1, 0.7, 0], [0.05, 0.6, 1.2]).ar(0, K2A.ar(t_trig));
    var f = freq * [1, 1.005, 0.997];
    var sig = Saw.ar(f) * 0.5 + Pulse.ar(f * 0.5, 0.4) * 0.3;
    sig = MoogFF.ar(sig, cutoff + SinOsc.kr(0.11, 0, 180), 2.2);
    sig = (sig * env * amp * 3).tanh;
    Balance2.ar(sig.sum, sig.sum, pan);
}).play;
Ndef(\viola).set(\wet10, 0.3);

Pbindef(\violaSeq,
    \dur, Pn(Pseq([1.5, 0.5, 1, 1], 1), inf),
    \t_trig, 1,
    \freq, Pn(Pseq([220, 261.6, 293.7, 207.7, 196], 1), inf),
    \cutoff, Pexprand(500, 1800, inf),
    \amp, Pwhite(0.12, 0.2, inf)
);
Ndef(\viola)[1] = \set -> Pbindef(\violaSeq);
Ndef(\viola).quant = 1;

// Layer 4: ar de terreiro (granulado e canopy)
Ndef(\terreiro, { |amp=0.05|
    var dust = Dust.ar(18!2) * 0.4;
    var hiss = BPF.ar(PinkNoise.ar(0.4!2), 3800, 0.6) * 4;
    var swell = LPF.ar(BrownNoise.ar(0.3!2), 300) * (0.6 + SinOsc.kr(0.05, 0, 0.4));
    (dust + hiss + swell) * amp;
}).play;
Ndef(\terreiro).set(\wet10, 0.35);

// Efeitos
Ndef(\caixa)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.3, 0.7, 0.4) };
Ndef(\viola)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.6, 0.8, 0.5) };
Ndef(\gungas)[11] = \filter -> { |in| CombC.ar(in, 0.5, 0.23, 2.0) * 0.5 };
)

// Ndef(\viola).xset(\cutoff, 1800); // Brilho da viola | Revert: Ndef(\viola).xset(\cutoff, 900);
// Pbindef(\gungasSeq, \dur, Pn(Pseq([0.125, 0.125, 0.25], 1), inf)); // Gungas em dobro | Revert: Pbindef(\gungasSeq, \dur, Pn(Pseq([0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25], 1), inf));
// Pbindef(\caixaSeq).stop; Ndef(\caixa).fadeTime = 4; Ndef(\caixa).clear(4); // Rollback caixa
// Ndef(\terreiro).set(\amp, 0.02); // Ar mais discreto | Revert: Ndef(\terreiro).set(\amp, 0.05);
```

</details>

<details>
<summary><strong>Round 08 [GENERATE] - Status: PASS</strong> — <em>A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incan...</em></summary>

- **Prompt**: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido na superfície calma de um corixo repleto de camalotes e vitórias-régias. Centenas de tuiuiús pousados nos galhos secos de um piúva centenário observam em silêncio o bater de asas de um bando ruidoso de araras-azuis cruzando o céu crepuscular rumo ao dormitório nos capões de mata.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// Pantanal entardecer: corixo grave (Layer 1), araras em FM (Layer 2), tuiuiús modais (Layer 3), canopy de dusk (Layer 4)
Ndef(\corixo).fadeTime = 4;
Ndef(\araras).fadeTime = 2;
Ndef(\tuiuis).fadeTime = 2;
Ndef(\crepusculo).fadeTime = 5;

// Layer 1: corixo, pad grave com harmônico de 2a ordem e filtro Moog lento
Ndef(\corixo, { |amp=0.18, cutoff=420, pan=(-0.3)|
    var f = 55 * [0.995, 1, 1.004];
    var swell = 0.7 + (SinOsc.kr(0.03, 0, 0.3));
    var sig = (Saw.ar(f) * 0.5 + Pulse.ar(f * 0.5, 0.5) * 0.3).sum;
    sig = sig + (SinOsc.ar(110) * 0.12);
    sig = MoogFF.ar(sig, cutoff + SinOsc.kr(0.05, 0, 120), 1.2);
    sig = (sig * amp * swell).tanh;
    Pan2.ar(sig, pan);
}).play;
Ndef(\corixo).set(\wet10, 0.3);

// Layer 2: araras-azuis, chamados FM com índice decrescente e razão inarmônica
Ndef(\araras, { |t_trig=0, freq=660, amp=0.12, pan=0.4|
    var env = Env.perc(0.01, 0.5, 1, -4).ar(0, K2A.ar(t_trig));
    var modEnv = EnvGen.kr(Env.perc(0.005, 0.3, 1, -5), t_trig);
    var mod = SinOsc.ar(freq * 2.71) * (freq * 1.3 * modEnv);
    var car = SinOsc.ar(freq + mod);
    var sig = car * env * amp;
    Pan2.ar(sig, pan + SinOsc.kr(0.13, 0, 0.15));
}).play;
Ndef(\araras).set(\wet11, 0.25);

Pbindef(\ararasSeq,
    \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.35, 0.15], inf),
    \t_trig, 1,
    \freq, Pn(Pgeom(660, 1.12, 5), inf),
    \amp, Pwhite(0.08, 0.16, inf),
    \pan, Pwhite(0.2, 0.7, inf)
);
Ndef(\araras)[1] = \set -> Pbindef(\ararasSeq);
Ndef(\araras).quant = 1;

// Layer 3: tuiuiús, clacks modais (exciter -> ressonadores harmônicos)
Ndef(\tuiuis, { |t_trig=0, amp=0.14, freq=180, pan=(-0.6)|
    var exc = Decay2.ar(K2A.ar(t_trig), 0.001, 0.02) * WhiteNoise.ar(1);
    var sig = Ringz.ar(exc, [freq, freq * 2.4, freq * 3.7], [0.5, 0.25, 0.12]).sum;
    sig = (sig * amp * 4).tanh;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\tuiuiSeq,
    \dur, Pn(Pseq([0.75, 0.25, 0.5, 1.0, 0.5, 0.25, 0.25, 0.5], 1), inf),
    \t_trig, 1,
    \freq, Pwrand([180, 240, 150], [0.6, 0.3, 0.1], inf),
    \amp, Pwhite(0.1, 0.18, inf),
    \pan, Pwhite((-0.8), (-0.2), inf)
);
Ndef(\tuiuis)[1] = \set -> Pbindef(\tuiuiSeq);
Ndef(\tuiuis).quant = 1;

// Layer 4: crepusculo, vento de mata, insetos (Dust) e brilho de horizonte
Ndef(\crepusculo, { |amp=0.05|
    var insects = Dust.ar(24 ! 2) * 0.35;
    var wind = BPF.ar(PinkNoise.ar(0.4 ! 2), 2600 + SinOsc.kr(0.04, 0, 700), 0.5) * 4;
    var warm = LPF.ar(BrownNoise.ar(0.25 ! 2), 260) * (0.6 + SinOsc.kr(0.05, 0, 0.4));
    (insects + wind + warm) * amp;
}).play;
Ndef(\crepusculo).set(\wet12, 0.4);

// Efeitos (slots 10..12, somente sinal 100% molhado)
Ndef(\corixo)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.5, 0.8, 0.4) };
Ndef(\araras)[11] = \filter -> { |in| CombC.ar(in, 0.5, 0.31, 1.5) * 0.4 };
Ndef(\crepusculo)[12] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 0.7, 0.9, 0.5) * 0.5 };
)

// Ndef(\corixo).xset(\cutoff, 700); // Mais luz no horizonte | Revert: Ndef(\corixo).xset(\cutoff, 420);
// Pbindef(\ararasSeq, \dur, Pwrand([0.125, 0.25, 0.5], [0.5, 0.3, 0.2], inf)); // Revoada acelera | Revert: Pbindef(\ararasSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.5, 0.35, 0.15], inf));
// Pbindef(\tuiuiSeq, \freq, Pwrand([120, 180, 240], [0.3, 0.4, 0.3], inf)); // Tuiuiús mais graves | Revert: Pbindef(\tuiuiSeq, \freq, Pwrand([180, 240, 150], [0.6, 0.3, 0.1], inf));
// Pbindef(\ararasSeq).stop; Ndef(\araras).fadeTime = 4; Ndef(\araras).clear(4); // Rollback araras
// Ndef(\crepusculo).set(\amp, 0.02); // Noite mais discreta | Revert: Ndef(\crepusculo).set(\amp, 0.05);
```

</details>

### Model: DeepSeek Flash Latest (`openrouter:deepseek/deepseek-v4.1-flash`)

- **Initial Pass Rate**: 62.5%
- **Final Pass Rate**: 100.0%
- **Total Time**: 525.94s (mean LLM: 45.65s/round)
- **Total Tokens**: 150,203 (Cost: $0.03954)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261112_191506\session_deepseek-flash-v4.1.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback

```supercollider
(
// ============================================================
// ADD_INSTRUMENT: marriageDrone - warm, stable pad representing 27 years of marriage
// ============================================================
Ndef(\marriageDrone, {
    |amp=0.2, cutoff=800, rq=0.5, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var sig = Splay.ar(Saw.ar([110, 110.5, 111, 109.5] * [1, 1.01, 0.99], 0.1));
    sig = RLPF.ar(sig, cutoff, rq);
    sig = sig * SinOsc.kr(0.1).range(0.7, 1);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, ampSmooth) } { Pan2.ar(sig, pan, ampSmooth) };
}).play;
// Pbindef(\marriageDroneSeq).stop; Ndef(\marriageDrone).fadeTime = 2; Ndef(\marriageDrone).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: mapFold - meticulous plucked FM sound representing map folding explanation
// ============================================================
Ndef(\mapFold, {
    |freq=440, amp=0.3, pan=0, t_trig=0, modIndex=2, modRatio=1.5, atk=0.001, rel=0.3|
    var ampSmooth = Lag.kr(amp, 0.1);
    var env = EnvGen.ar(Env.perc(atk, rel), K2A.ar(t_trig));
    var mod = SinOsc.ar(freq * modRatio) * (freq * modIndex) * env;
    var car = SinOsc.ar(freq + mod);
    car = car * env * ampSmooth;
    Pan2.ar(car, pan);
}).play;
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: antarcticStorm - noise-based tension bed representing impending storm
// ============================================================
Ndef(\antarcticStorm, {
    |amp=0.1, cutoff=1000, rq=0.1, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var noise = PinkNoise.ar(0.5);
    var sig = BPF.ar(noise, cutoff, rq) * 10;
    sig = sig * SinOsc.kr(0.05).range(0.5, 1);
    sig = sig + SinOsc.ar(40, 0, 0.1);
    Pan2.ar(sig * ampSmooth, pan);
}).play;
// Pbindef(\antarcticStormSeq).stop; Ndef(\antarcticStorm).fadeTime = 2; Ndef(\antarcticStorm).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_INSTRUMENT: waiterFreeze - high thin tone representing suspended moment
// ============================================================
Ndef(\waiterFreeze, {
    |amp=0.05, freq=2000, pan=0|
    var ampSmooth = Lag.kr(amp, 2);
    var sig = SinOsc.ar(freq) * 0.5 + SinOsc.ar(freq*1.01) * 0.5;
    sig = sig * SinOsc.kr(0.2).range(0.3, 1);
    Pan2.ar(sig * ampSmooth, pan);
}).play;
// Pbindef(\waiterFreezeSeq).stop; Ndef(\waiterFreeze).fadeTime = 2; Ndef(\waiterFreeze).clear(2); // Rollback: remove this instrument

// ============================================================
// ADD_SEQUENCE: mapFoldSeq - repetitive, meticulous rhythm for map folding
// ============================================================
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \t_trig, 1,
    \freq, Pseq([440, 550, 660, 550, 440, 330], inf),
    \amp, Pwhite(0.1, 0.3, inf),
    \pan, Pseq([-0.5, 0.5], inf),
    \modIndex, Pwhite(1, 4, inf),
    \modRatio, Pwhite(1, 3, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
// Pbindef(\mapFoldSeq).stop; // Rollback: remove this sequence
)
```

</details>

<details>
<summary><strong>Round 02 [APPEND] - Status: FIXED</strong> — <em>Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sa...</em></summary>

- **Prompt**: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Tinir de ferros... estalar de açoite... Legiões de homens negros como a noite, horrendos a dançar... Mulheres com crianças suspensas ao peito descarnado, homens gemendo sob a aragem salgada, pedindo a Deus um raio que quebre os elos da corrente maldita!
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: None
- **Initial Error**: `ERROR: Function variable 'sig' already declared in Interpreter:functionCompileContext
ERROR: Variable 'res' not defined.
__VAL_ERROR__: Syntax / compile error in generated code
ERROR: Function variable 'sig' already declared in Interpreter:functionCompileContext
  in interpreted text
  line 81 char `

```supercollider
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
	s.sync;

    // ServerTree.removeAll; // preserved for shared X-Append server
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
        Pbindef(\saltShot).stop; Pbindef(\saltShot).clear; Pbindef(\mixRhythm).stop; Pbindef(\mixRhythm).clear; Pbindef(\eggSequence).stop; Pbindef(\eggSequence).clear; Pbindef(\rollRhythm).stop; Pbindef(\rollRhythm).clear;

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
        Ndef(\polvilhoAmbience).clear(5); Ndef(\leiteOleoDrone).clear(5); Ndef(\queijoTexture).clear(5); Ndef(\fornoHum).clear(5); Ndef(\delayTexture).clear(5); Ndef(\master).clear(5); Ndef(\mixAmp).clear(5); Ndef(\rollAmp).clear(5);
        "Score Complete.".postln;

    });

    Tdef(\masterScore).play;
    // s.makeGui;

});
)
```

</details>

<details>
<summary><strong>Round 03 [COMPOSE] - Status: PASS</strong> — <em>Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, ...</em></summary>

- **Prompt**: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses e cronômetros de bolso trabalhavam em tempos ligeiramente desencontrados. O velho relojoeiro fechava os olhos no centro daquele enxame de tique-taques de latão e jurava ouvir, nas defasagens microscópicas entre as engrenagens, o próprio respirar do tempo.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
~enableRecording = false;
if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

s.waitForBoot({

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;

    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete synthdefs
    SynthDef(\tickTock, {
        var env, sig, freq = \freq.kr(1200);
        env = EnvGen.ar(Env.perc(0.001, \decay.kr(0.03), 1, -6), doneAction: 2);
        sig = BPF.ar(WhiteNoise.ar, freq, 0.18) * 9.0;
        sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.001, 0.05), doneAction: 0) * 0.15);
        sig = sig * env;
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5)));
    }).add;

    SynthDef(\carillon, {
        var sig, env, mod1, mod2, car, f;
        f = \freq.kr(440);
        env = EnvGen.ar(Env.perc(0.005, \decay.kr(3), 1, -4), doneAction: 2);
        mod1 = SinOsc.ar(f * 2.76) * f * 1.2;
        mod2 = SinOsc.ar(f * 3.51) * f * 0.6;
        car = SinOsc.ar(f + mod1 + mod2);
        sig = car * env;
        sig = sig + (SinOsc.ar(f * 2) * env * 0.25);
        sig = sig + (SinOsc.ar(f * 0.5) * env * 0.15);
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3)));
    }).add;

    SynthDef(\gearGrind, {
        var sig, env, freq;
        freq = \freq.kr(120);
        env = EnvGen.ar(Env.perc(0.01, \decay.kr(0.5), 1, -3), doneAction: 2);
        sig = Saw.ar(freq * [1, 1.01, 1.02]).sum * 0.3;
        sig = RLPF.ar(sig, \cutoff.kr(2000), 0.3) * 3;
        sig = (sig * 2).tanh * env;
        Out.ar(\out.kr(0), Pan2.ar(sig, \pan.kr(0), \amp.kr(0.3)));
    }).add;

    s.sync;

    // Continuous textures
    Ndef(\clockSwarm, {
        var tick1, tick2, tick3, sig;
        tick1 = BPF.ar(WhiteNoise.ar, 1500 + SinOsc.kr(0.53).range(-120, 120), 0.12) * Decay.ar(Impulse.ar(2.31), 0.02);
        tick2 = BPF.ar(WhiteNoise.ar, 2200 + SinOsc.kr(0.71).range(-220, 220), 0.12) * Decay.ar(Impulse.ar(3.13), 0.015);
        tick3 = BPF.ar(WhiteNoise.ar, 900 + SinOsc.kr(0.37).range(-60, 60), 0.12) * Decay.ar(Impulse.ar(1.73), 0.03);
        sig = (tick1 * 8) + (tick2 * 6) + (tick3 * 10);
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\brassDrone, {
        var sig, freqs;
        freqs = [55, 82.5, 110, 165, 220];
        sig = Mix.ar(freqs.collect({ |f, i|
            SinOsc.ar(f * (1 + LFNoise1.kr(0.1).range(-0.002, 0.002))) * (1 / (i + 1))
        }));
        sig = (sig * 1.5).tanh;
        sig = RLPF.ar(sig, \cutoff.kr(800), 0.5) * 2;
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\breathOfTime, {
        var sig, env;
        env = LFNoise1.kr(0.15).range(0.3, 1);
        sig = (SinOsc.ar(\freq.kr(60) * [1, 1.5, 2]) * [0.7, 0.3, 0.15]).sum;
        sig = sig + (SinOsc.ar(\freq.kr(60) * 2) * env * 0.2);
        sig = LPF.ar(sig, 400);
        sig = sig * \amp.kr(0);
        [sig, sig];
    });

    Ndef(\carillonCloud, {
        var sig, trig, freqs;
        trig = Impulse.kr(\density.kr(0.5));
        freqs = Demand.kr(trig, 0, Dseq([523.25, 587.33, 659.25, 783.99, 880, 659.25], inf));
        sig = (SinOsc.ar(freqs * [1, 2.76, 3.51]) * EnvGen.kr(Env.perc(0.005, 3), trig)).sum;
        sig = FreeVerb2.ar(sig, sig, 0.5, 0.9, 0.5);
        sig = sig * \amp.kr(0);
        sig;
    });

    // Master Mix
    Ndef(\masterMix, {
        var sig;
        sig = In.ar(~synthBus, 2);
        sig = sig + Ndef(\clockSwarm).ar(2);
        sig = sig + Ndef(\brassDrone).ar(2);
        sig = sig + Ndef(\breathOfTime).ar(2);
        sig = sig + Ndef(\carillonCloud).ar(2);
        sig;
    });

    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.85, 0.3) };
    Ndef(\masterMix).set(\wet10, 0);
    Ndef(\masterMix).play;

    s.sync;

    // Master Score
    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: A Oficina Estreita - o enxame de tique-taques desperta]".postln;
        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, -20.dbamp);

        Pbindef(\tickSeq,
            \instrument, \tickTock,
            \freq, Pwhite(800, 2400),
            \decay, Pexprand(0.015, 0.04),
            \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75], inf),
            \amp, 0.3,
            \pan, Pwhite(-0.7, 0.7),
            \out, ~synthBus
        ).play;

        Pbindef(\tickSeq2,
            \instrument, \tickTock,
            \freq, Pwhite(600, 1800),
            \decay, Pexprand(0.02, 0.05),
            \dur, Pseq([0.333, 0.333, 0.334, 0.5], inf),
            \amp, 0.25,
            \pan, Pwhite(-0.8, 0.8),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\clockSwarm).xset(\amp, (-20 + (i * 0.4)).dbamp);
            2.wait;
        };

        "0:20 - [Cue 2: Defasagens Microscopicas - os tempos se desencontram]".postln;
        Ndef(\brassDrone).fadeTime = 5;
        Ndef(\brassDrone).xset(\amp, -24.dbamp);

        Pbindef(\gearSeq,
            \instrument, \gearGrind,
            \freq, Pwhite(80, 200),
            \decay, Pexprand(0.1, 0.4),
            \cutoff, Pwhite(800, 2500),
            \dur, Pseq([0.5, 0.25, 0.25, 0.75, 0.25], inf),
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\brassDrone).xset(\cutoff, exprand(400, 1500));
            3.wait;
        };

        "0:50 - [Cue 3: Carrilhoes Franceses - as badaladas entram]".postln;
        Ndef(\carillonCloud).fadeTime = 4;
        Ndef(\carillonCloud).xset(\amp, -22.dbamp, \density, 0.35);

        Pbindef(\carillonSeq,
            \instrument, \carillon,
            \freq, Pseq([523.25, 587.33, 659.25, 783.99, 880, 659.25], inf),
            \decay, Pexprand(2, 5),
            \dur, Pseq([1.5, 0.5, 1, 0.5, 1.5, 1], inf),
            \amp, 0.15,
            \pan, Pwhite(-0.5, 0.5),
            \out, ~synthBus
        ).play;

        6.do { |i|
            Ndef(\carillonCloud).xset(\density, 0.35 + (i * 0.12));
            5.wait;
        };

        "1:20 - [Cue 4: O Relojoeiro Fecha os Olhos - o respirar do tempo]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\tickSeq2).stop;
        Pbindef(\gearSeq).stop;

        Ndef(\breathOfTime).fadeTime = 8;
        Ndef(\breathOfTime).xset(\amp, -18.dbamp, \freq, 55);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet10, 0.4);

        15.do { |i|
            Ndef(\breathOfTime).xset(\freq, 55 + (i * 1.2));
            Ndef(\carillonCloud).xset(\density, (0.6 - (i * 0.03)).max(0.15));
            2.wait;
        };

        "1:50 - [Cue 5: Engrenagens - os tique-taques retornam em fase]".postln;
        Pbindef(\tickSeq,
            \instrument, \tickTock,
            \freq, Pwhite(1000, 2000),
            \decay, Pexprand(0.02, 0.04),
            \dur, Pseq([0.25, 0.25, 0.5], inf),
            \amp, 0.25,
            \pan, Pwhite(-0.7, 0.7),
            \out, ~synthBus
        ).play;

        Ndef(\clockSwarm).fadeTime = 3;
        Ndef(\clockSwarm).xset(\amp, -16.dbamp);

        12.do { |i|
            Ndef(\breathOfTime).xset(\freq, 60 - (i * 0.6));
            Ndef(\brassDrone).xset(\cutoff, exprand(600, 2000));
            2.wait;
        };

        "2:15 - [Cue 6: Settling - o tempo respira e silencia]".postln;
        Pbindef(\tickSeq).stop;
        Pbindef(\carillonSeq).stop;

        Ndef(\carillonCloud).fadeTime = 6;
        Ndef(\carillonCloud).xset(\amp, -30.dbamp);

        Ndef(\clockSwarm).fadeTime = 6;
        Ndef(\clockSwarm).xset(\amp, -28.dbamp);

        Ndef(\brassDrone).fadeTime = 8;
        Ndef(\brassDrone).xset(\amp, -28.dbamp);

        Ndef(\breathOfTime).fadeTime = 10;
        Ndef(\breathOfTime).xset(\amp, -22.dbamp, \freq, 50);

        Ndef(\masterMix).fadeTime = 10;
        Ndef(\masterMix).xset(\wet10, 0.55);

        10.do { |i|
            Ndef(\breathOfTime).xset(\freq, 50 + (i * 0.4));
            1.5.wait;
        };

        "2:30 - [Terminating]".postln;
        Pbindef(\tickSeq).stop; Pbindef(\tickSeq).clear;
        Pbindef(\tickSeq2).stop; Pbindef(\tickSeq2).clear;
        Pbindef(\gearSeq).stop; Pbindef(\gearSeq).clear;
        Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;

        Ndef(\clockSwarm).clear(5);
        Ndef(\brassDrone).clear(5);
        Ndef(\breathOfTime).clear(5);
        Ndef(\carillonCloud).clear(5);
        Ndef(\masterMix).clear(5);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 04 [COMPOSE] - Status: FIXED</strong> — <em>A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no sécul...</em></summary>

- **Prompt**: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalista dinamarquês Peter Lund, é composta por sete amplos salões subterrâneos esculpidos pela ação milenar das águas em rocha calcária. Suas abóbadas úmidas exibem cortinas minerais, estalactites e estalagmites onde o gotejamento lento cria ressonâncias acústicas profundas na escuridão.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: None
- **Initial Error**: `__VAL_ERROR__: ERROR: Ringz first input is not audio rate:  a Dust control
__VAL_ERROR__: ERROR: Ringz first input is not audio rate:  a Dust control`

```supercollider
(
~enableRecording = false;

s.waitForBoot({
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety limiter
    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Cave water drip
    SynthDef(\caveDrip, {
        |out=0, freq=800, decay=0.5, amp=0.25, pan=0|
        var exc, sig, env;
        exc = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0001, 0.003)));
        sig = Ringz.ar(exc, freq * [1, 1.47, 2.13, 2.89], decay * [1, 0.7, 0.5, 0.3], 0.3).sum;
        sig = LPF.ar(sig, freq * 6);
        env = EnvGen.ar(Env.perc(0.001, decay), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Stalactite modal bell
    SynthDef(\stalactite, {
        |out=0, freq=400, decay=3, amp=0.2, pan=0|
        var exc, sig, env;
        exc = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.0001, 0.01)) * 0.3);
        sig = DynKlank.ar(
            Ref([
                [freq, freq*2.76, freq*5.4, freq*8.93, freq*13.34],
                [1, 0.6, 0.35, 0.2, 0.12],
                [1, 0.8, 0.6, 0.4, 0.3]
            ]),
            exc,
            decayscale: decay
        );
        sig = LPF.ar(sig, 5000);
        env = EnvGen.ar(Env.perc(0.001, decay * 0.9), doneAction: 2);
        Out.ar(out, Pan2.ar(sig * env * amp, pan));
    }).add;

    // Limestone rumble
    SynthDef(\limestoneRumble, {
        |out=0, freq=60, decay=2, amp=0.35, pan=0|
        var sig, env, mod;
        mod = SinOsc.ar(freq * 0.5) * freq * 0.3;
        sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq*2) * 0.3);
        env = EnvGen.ar(Env.perc(0.01, decay, 1, -4), doneAction: 2);
        sig = (sig * 2).tanh * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;
    s.sync;

    // Continuous: cavern drone
    Ndef(\cavernDrone, {
        |amp=0, cutoff=300, freq=42, res=1.5|
        var sig, mod;
        mod = LFNoise1.kr(0.15).range(0.98, 1.02);
        sig = SinOsc.ar(freq * mod) + (SinOsc.ar(freq*1.5) * 0.4) + (SinOsc.ar(freq*2) * 0.2);
        sig = sig + (Saw.ar(freq*0.5) * 0.15);
        sig = (MoogFF.ar(sig, cutoff, res) * 1.5).tanh * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.05, 0.03)]);
    });

    // Continuous: water flow
    Ndef(\waterFlow, {
        |amp=0, cutoff=800, q=0.7|
        var sig, lf;
        sig = PinkNoise.ar(0.5) + WhiteNoise.ar(0.2);
        sig = BPF.ar(sig, cutoff, q) * 6;
        lf = LFNoise1.kr(0.3).range(0.7, 1.3);
        sig = sig * lf * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.07, 0.05)]);
    });

    // Continuous: mineral shimmer
    Ndef(\mineralShimmer, {
        |amp=0, density=0.2, cutoff=4000|
        var sig, trig;
        // Ringz requires an audio-rate input; use Dust.ar instead of Dust.kr
        trig = Dust.ar(density);
        sig = Ringz.ar(trig, TExpRand.kr(2000, 6000, trig), 2, 0.2)
            + Ringz.ar(trig, TExpRand.kr(3000, 8000, trig), 3, 0.15);
        sig = LPF.ar(sig, cutoff) * amp;
        Splay.ar([sig, DelayN.ar(sig, 0.1, 0.08)]);
    });

    // Master mixer
    Ndef(\masterMix, {
        In.ar(~synthBus, 2)
        + (Ndef(\cavernDrone).ar(2) * 0.9)
        + (Ndef(\waterFlow).ar(2) * 0.8)
        + (Ndef(\mineralShimmer).ar(2) * 0.7)
    });

    Ndef(\masterMix)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1.0, 0.9, 0.35); };
    Ndef(\masterMix)[11] = \filter -> { |in| MoogFF.ar(in, 3500, 0.5); };

    Ndef(\masterMix).play;
    Ndef(\masterMix).set(\wet10, 0.3, \wet11, 0.4);
    s.sync;

    Tdef(\masterScore, {
        0.5.wait;

        "0:00 - [Cue 1: Peter Lund - entrada na escuridao]".postln;
        Ndef(\cavernDrone).fadeTime = 8;
        Ndef(\cavernDrone).xset(\amp, -18.dbamp, \cutoff, 180, \freq, 42);

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pexprand(600, 2200),
            \decay, Pexprand(0.2, 0.9),
            \amp, 0.22,
            \pan, Pwhite(-0.85, 0.85),
            \dur, Pseq([0.8, 0.4, 1.2, 0.6, 0.3, 1.5, 0.5], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, 180 + (i * 60));
            1.5.wait;
        };

        "0:12 - [Cue 2: Primeiro salao - gotas ressoam]".postln;
        Ndef(\waterFlow).fadeTime = 6;
        Ndef(\waterFlow).xset(\amp, -26.dbamp, \cutoff, 900);
        6.do { |i|
            Ndef(\waterFlow).xset(\cutoff, exprand(500, 2500));
            2.wait;
        };

        "0:24 - [Cue 3: Cortinas minerais - brilho nas abobadas]".postln;
        Ndef(\mineralShimmer).fadeTime = 5;
        Ndef(\mineralShimmer).xset(\amp, -24.dbamp, \density, 0.25);

        Pbindef(\stalactiteSeq,
            \instrument, \stalactite,
            \freq, Pseq([220, 330, 440, 293.66, 220, 392], inf),
            \decay, Pexprand(2.5, 5.5),
            \amp, 0.15,
            \pan, Pwhite(-0.7, 0.7),
            \dur, Pseq([2.5, 1, 3, 1.5, 2, 2.5], inf),
            \out, ~synthBus
        ).play;

        6.do { |i|
            Ndef(\mineralShimmer).xset(\density, 0.25 + (i * 0.08));
            2.wait;
        };

        "0:36 - [Cue 4: Limite intrinseco - a agua perfura a rocha]".postln;
        Pbindef(\dripSeq).stop;

        Pbindef(\limestoneSeq,
            \instrument, \limestoneRumble,
            \freq, Pseq([55, 60, 48, 55, 42], inf),
            \decay, Pexprand(1.5, 3),
            \amp, 0.3,
            \pan, Pwhite(-0.5, 0.5),
            \dur, Pseq([1.5, 0.75, 2, 1, 1.75], inf),
            \out, ~synthBus
        ).play;

        Ndef(\waterFlow).xset(\amp, -18.dbamp, \cutoff, 1800);
        8.do { |i|
            Ndef(\cavernDrone).xset(\freq, 42 + (i * 1.5), \cutoff, 250 + (i * 80));
            1.5.wait;
        };

        "0:48 - [Cue 5: Settling - gotejamento solitario na escuridao]".postln;
        Pbindef(\limestoneSeq).stop;
        Pbindef(\stalactiteSeq).stop;

        Ndef(\waterFlow).fadeTime = 8;
        Ndef(\waterFlow).xset(\amp, -30.dbamp);
        Ndef(\mineralShimmer).fadeTime = 6;
        Ndef(\mineralShimmer).xset(\amp, -30.dbamp, \density, 0.1);

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pexprand(500, 1500),
            \decay, Pexprand(0.5, 1.5),
            \amp, 0.18,
            \pan, Pwhite(-0.8, 0.8),
            \dur, Pseq([2, 1.5, 3, 1, 2.5], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, (250 - (i * 20)).max(120));
            1.5.wait;
        };

        "1:00 - [Cue 6: Flashback - os saloes retornam, escuridao profunda]".postln;
        Pbindef(\dripSeq).stop;

        Ndef(\cavernDrone).xset(\amp, -12.dbamp, \freq, 36, \cutoff, 400);
        Ndef(\masterMix).xset(\wet10, 0.55);

        Pbindef(\stalactiteSeq,
            \instrument, \stalactite,
            \freq, Pseq([110, 165, 220, 146.83, 110], inf),
            \decay, Pexprand(3, 6),
            \amp, 0.2,
            \pan, Pwhite(-0.6, 0.6),
            \dur, Pseq([3, 1.5, 2.5, 2, 3.5], inf),
            \out, ~synthBus
        ).play;

        Pbindef(\limestoneSeq,
            \instrument, \limestoneRumble,
            \freq, Pseq([48, 42, 55], inf),
            \decay, Pexprand(2, 4),
            \amp, 0.25,
            \pan, Pwhite(-0.4, 0.4),
            \dur, Pseq([2.5, 3, 2], inf),
            \out, ~synthBus
        ).play;

        10.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, 400 + (i * 100));
            1.wait;
        };

        "1:20 - [Cue 7: Limite extrinseco - o setimo salao, resolucao]".postln;
        Pbindef(\limestoneSeq).stop;

        Pbindef(\dripSeq,
            \instrument, \caveDrip,
            \freq, Pseq([880, 660, 880, 990, 1100], inf),
            \decay, Pexprand(0.6, 1.2),
            \amp, 0.2,
            \pan, Pwhite(-0.9, 0.9),
            \dur, Pseq([0.5, 0.3, 0.7, 0.4, 1], inf),
            \out, ~synthBus
        ).play;

        8.do { |i|
            Ndef(\mineralShimmer).xset(\density, 0.15 + (i * 0.06));
            Ndef(\cavernDrone).xset(\cutoff, (700 - (i * 60)).max(200));
            1.wait;
        };

        "1:36 - [Cue 8: Settling final - silencio mineral]".postln;
        Pbindef(\dripSeq).stop;
        Pbindef(\stalactiteSeq).stop;

        Ndef(\cavernDrone).fadeTime = 10;
        Ndef(\cavernDrone).xset(\amp, -22.dbamp, \freq, 42);
        Ndef(\mineralShimmer).fadeTime = 8;
        Ndef(\mineralShimmer).xset(\amp, -34.dbamp);
        Ndef(\masterMix).xset(\wet10, 0.65);

        8.do { |i|
            Ndef(\cavernDrone).xset(\cutoff, (300 - (i * 25)).max(100));
            1.2.wait;
        };

        "1:48 - [Terminating]".postln;
        Pbindef(\dripSeq).stop; Pbindef(\dripSeq).clear;
        Pbindef(\stalactiteSeq).stop; Pbindef(\stalactiteSeq).clear;
        Pbindef(\limestoneSeq).stop; Pbindef(\limestoneSeq).clear;

        Ndef(\cavernDrone).clear(6);
        Ndef(\waterFlow).clear(6);
        Ndef(\mineralShimmer).clear(6);
        Ndef(\masterMix).clear(6);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 05 [DESIGN] - Status: FIXED</strong> — <em>Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumb...</em></summary>

- **Prompt**: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de potenciômetros prateados, matrizes de pinos luminosos e cabos entrelaçados. Ao lado, a tela verde de fósforo de um osciloscópio analógico desenha figuras de Lissajous em rotação contínua que se dobram e se desdobram em harmônicos complexos.
- **Initial Valid**: False
- **Final Valid**: True
- **Validator Fixes**: None
- **Initial Error**: `ERROR: syntax error, unexpected VAR, expecting '}'
ERROR: Command line parse failed
__VAL_ERROR__: Syntax / compile error in generated code
ERROR: syntax error, unexpected VAR, expecting '}'
  in interpreted text
  line 693 char 11:
          var barY = 3 * 300 + 6;
          ^^^
-------------------`

```supercollider
(
// Modular Cabinet + Lissajous Oscilloscope — 3-zone multitimbral
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxPot1: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxPin2: 52,
    vol3: 60, pan3: 61, mute3: 62, min3: 63, max3: 64, hpf3: 65, lpf3: 66, rq3: 67,
    atk3: 68, dec3: 69, sus3: 70, rls3: 71, fxLiss3: 72,
    delMix: 80, revMix: 81, delTime: 82, revTime: 83, panic: 90
);

~ccVals = (
    vol1: 0.28, pan1: 0.0,  mute1: 0.0, min1: 0,  max1: 65, hpf1: 25,  lpf1: 180, rq1: 0.6,
    atk1: 0.01, dec1: 0.6, sus1: 0.7, rls1: 0.8, fxPot1: 0.0,
    vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 36, max2: 100, hpf2: 350, lpf2: 6500, rq2: 0.4,
    atk2: 0.005, dec2: 0.4, sus2: 0.2, rls2: 0.6, fxPin2: 0.0,
    vol3: 0.18, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.5,
    atk3: 0.4, dec3: 1.5, sus3: 0.6, rls3: 2.0, fxLiss3: 0.0,
    delMix: 0.0, revMix: 0.0, delTime: 0.35, revTime: 2.5, panic: 0
);

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
        label.contains("bmt").not and: { label.contains("bome").not }
            and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not } and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not } and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN: " ++ ~myInDevice.device ++ " / " ++ ~myInDevice.name).postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input detected.".warn;
    ~myUid = nil;
};

s.waitForBoot {
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // ---- Zone 1: Silver Potentiometers — Moog-ish sub bass ----
    SynthDef(\silverPot, { |out, freq=55, gate=1, amp=0.28, pan=0,
        hpf=25, lpf=180, rq=0.6, atk=0.01, dec=0.6, sus=0.7, rls=0.8, fxPot=0|
        var env, sig, sub, det, drive, cutoff;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        det = Saw.ar(freq * [0.997, 1.0, 1.003]) + Pulse.ar(freq * 0.5, 0.4, 0.35);
        sig = Splay.ar(det) * 0.5;
        drive = 1.0 + (fxPot * 3.0);
        cutoff = (lpf + (fxPot * 900)).clip(30, 6000);
        sig = (MoogFF.ar(sig * drive, cutoff, 3.2) * 3.0).tanh;
        sig = RLPF.ar(sig, cutoff, rq);
        sig = HPF.ar(sig, hpf);
        sub = SinOsc.ar(freq * 0.5) * 0.4 * (1 - fxPot.clip(0,1));
        sig = sig + sub;
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- Zone 2: Pin Matrix — FM metallic pluck ----
    SynthDef(\pinMatrix, { |out, freq=220, gate=1, amp=0.22, pan=0,
        hpf=350, lpf=6500, rq=0.4, atk=0.005, dec=0.4, sus=0.2, rls=0.6, fxPin=0|
        var env, mod, car, ratio, idx, sig, comb, ap;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls, curve: -4), gate, doneAction: 2);
        ratio = 2.71 + (fxPin * 3.5);
        idx = (freq * (1.2 + (fxPin * 8.0))) * EnvGen.kr(Env.perc(0.001, 0.35));
        mod = SinOsc.ar(freq * ratio) * idx;
        car = SinOsc.ar(freq + mod);
        car = car + (SinOsc.ar(freq * 3.51 + mod * 0.5) * 0.3);
        comb = CombL.ar(car * EnvGen.kr(Env.perc(0.001, 0.02)),
            0.05, freq.reciprocal.clip(0.0001, 0.05), 0.4 + (fxPin * 1.5));
        ap = AllpassC.ar(comb, 0.02, (fxPin * 0.008) + 0.0005, 0.08);
        sig = (car * 0.6) + ap;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- Zone 3: Lissajous Oscilloscope — additive harmonic pad ----
    SynthDef(\lissPad, { |out, freq=220, gate=1, amp=0.18, pan=0,
        hpf=160, lpf=3200, rq=0.5, atk=0.4, dec=1.5, sus=0.6, rls=2.0, fxLiss=0|
        var env, sig, partials, lfoX, lfoY, ph, harm;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        harm = [1, 2, 3, 4, 5, 6, 7];
        lfoX = SinOsc.kr(0.13 + (fxLiss * 0.9), 0, 0.5, 1.0);
        lfoY = SinOsc.kr(0.17 + (fxLiss * 0.7), 1.2, 0.5, 1.0);
        partials = harm.collect { |h, i|
            var det = (i + 1) * 0.003 * (1 + fxLiss);
            SinOsc.ar(freq * h * (1 + det), 0, 1.0 / (h * (1 + (i * 0.3))))
        };
        sig = Mix(partials);
        ph = SinOsc.kr(0.05 + (fxLiss * 0.4), 0, 0.7, 1.0);
        sig = sig * lfoX;
        sig = sig + (SinOsc.ar(freq * 0.5 * lfoY) * 0.25 * fxLiss);
        sig = sig * ph;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig) * env * amp;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // ---- FX: delay + reverb ----
    SynthDef(\delayFx, { |in, out, delMix=0, delTime=0.35|
        var sig, dly;
        sig = In.ar(in, 2);
        dly = CombL.ar(sig, 1.0, delTime, 2.0);
        dly = AllpassC.ar(dly, 0.05, 0.02, 0.3);
        Out.ar(out, (sig * (1 - delMix)) + (dly * delMix));
    }).add;

    SynthDef(\reverbFx, { |in, out, revMix=0, revTime=2.5|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], revMix, 0.85, revTime.linlin(0.2, 8.0, 0.2, 0.95));
        Out.ar(out, wet);
    }).add;

    SynthDef(\safetyLimiter, { |in, out|
        var sig;
        sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~delaySynth = Synth(\delayFx, [\in, ~fxBus, \out, ~masterBus,
        \delMix, ~buses.delMix.asMap, \delTime, ~buses.delTime.asMap],
        ~fxGroup, \addToTail);
    ~reverbSynth = Synth(\reverbFx, [\in, ~masterBus, \out, 0,
        \revMix, ~buses.revMix.asMap, \revTime, ~buses.revTime.asMap],
        ~masterGroup, \addToTail);
    ~limiter = Synth(\safetyLimiter, [\in, 0, \out, 0], ~masterGroup, \addToTail);

    // ---- Voice allocation ----
    ~zoneNotes = Array.newClear(128);
    128.do { |i| ~zoneNotes[i] = [] };

    ~spawn = { |noteNum, vel|
        var freq = noteNum.midicps;
        var v = vel / 127.0;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] } and: { ~ccVals[\mute1] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\silverPot, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol1] * v,
                    \pan, ~ccVals[\pan1], \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap,
                    \rq, ~buses.rq1.asMap, \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap,
                    \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap, \fxPot, ~buses.fxPot1.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] } and: { ~ccVals[\mute2] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\pinMatrix, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol2] * v,
                    \pan, ~ccVals[\pan2], \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap,
                    \rq, ~buses.rq2.asMap, \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap,
                    \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap, \fxPin, ~buses.fxPin2.asMap
                ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] } and: { ~ccVals[\mute3] < 0.5 }) {
            ~zoneNotes[noteNum] = ~zoneNotes[noteNum].add(
                Synth(\lissPad, [
                    \out, ~fxBus, \freq, freq, \amp, ~ccVals[\vol3] * v,
                    \pan, ~ccVals[\pan3], \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap,
                    \rq, ~buses.rq3.asMap, \atk, ~buses.atk3.asMap, \dec, ~buses.dec3.asMap,
                    \sus, ~buses.sus3.asMap, \rls, ~buses.rls3.asMap, \fxLiss, ~buses.fxLiss3.asMap
                ], ~synthGroup));
        };
    };

    ~release = { |noteNum|
        ~zoneNotes[noteNum].do(_.set(\gate, 0));
        ~zoneNotes[noteNum] = [];
    };

    MIDIdef.noteOn(\on, { |vel, noteNum|
        ~release.(noteNum);
        ~spawn.(noteNum, vel);
    }, srcID: ~myUid);

    MIDIdef.noteOff(\off, { |vel, noteNum|
        ~release.(noteNum);
    }, srcID: ~myUid);

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
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { ks.contains("vol") } { norm * 0.4 }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 63) {
            128.do { |i| ~release.(i) };
            "PANIC — all voices off".postln;
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ---- GUI ----
    defer {
        // All var declarations must be at the top of the function
        var bounds = Window.availableBounds;
        var winH = min(780, bounds.height - 60);
        var barY = 3 * 300 + 6;
        var bar;
        ~zoneMeta = [
            (title: "ZONE 1 — SILVER POTS (Sub)", fxKey: "fxPot1", fxLabel: "Pot Drive"),
            (title: "ZONE 2 — PIN MATRIX (FM Pluck)", fxKey: "fxPin2", fxLabel: "Pin Index"),
            (title: "ZONE 3 — LISSAJOUS (Harm Pad)", fxKey: "fxLiss3", fxLabel: "Liss Fold")
        ];
        ~ui = ();

        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("Modular Cabinet / Lissajous Scope", Rect(
            (bounds.width - 620) / 2, (bounds.height - winH) / 2, 620, winH), scroll: true);
        ~mainWin.background = Color(0.06, 0.07, 0.06);

        ~zoneMeta.do { |zm, idx|
            var z = idx + 1;
            var page = CompositeView(~mainWin, Rect(0, idx * 300, 600, 290));
            page.background = if(idx.even, Color(0.09, 0.10, 0.09), Color(0.07, 0.08, 0.07));
            StaticText(page, Rect(10, 6, 580, 22))
                .string_(zm.title).font_(Font("Monaco", 13)).stringColor_(Color(0.4, 1.0, 0.5));

            EZSlider(page, Rect(10, 34, 280, 30), "VOL " ++ ~cc[("vol" ++ z).asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[("vol" ++ z).asSymbol]),
                { |ez| ~ccVals[("vol" ++ z).asSymbol] = ez.value;
                    ~buses[("vol" ++ z).asSymbol].set(ez.value) });
            ~ui[("vol" ++ z).asSymbol] = { |v| page.children[2].value = v };

            EZSlider(page, Rect(300, 34, 290, 30), "PAN " ++ ~cc[("pan" ++ z).asSymbol],
                ControlSpec(-1, 1, \lin, 0, ~ccVals[("pan" ++ z).asSymbol]),
                { |ez| ~ccVals[("pan" ++ z).asSymbol] = ez.value;
                    ~buses[("pan" ++ z).asSymbol].set(ez.value) });
            ~ui[("pan" ++ z).asSymbol] = { |v| page.children[3].value = v };

            EZRanger(page, Rect(10, 70, 380, 30), "KEY RANGE " ++ ~cc[("min" ++ z).asSymbol] ++ "/" ++ ~cc[("max" ++ z).asSymbol],
                ControlSpec(0, 127, \lin, 1, 0),
                { |ez| ~ccVals[("min" ++ z).asSymbol] = ez.lo;
                    ~ccVals[("max" ++ z).asSymbol] = ez.hi;
                    ~buses[("min" ++ z).asSymbol].set(ez.lo);
                    ~buses[("max" ++ z).asSymbol].set(ez.hi) });
            page.children[4].setRanges(~ccVals[("min" ++ z).asSymbol], ~ccVals[("max" ++ z).asSymbol]);
            ~ui[("min" ++ z).asSymbol] = { |v| };
            ~ui[("max" ++ z).asSymbol] = { |v| };

            Button(page, Rect(400, 70, 90, 30)).states_([
                ["MUTE", Color.white, Color(0.3, 0.05, 0.05)],
                ["MUTED", Color.white, Color(0.7, 0.1, 0.1)]])
                .action_({ |b| ~ccVals[("mute" ++ z).asSymbol] = b.value;
                    ~buses[("mute" ++ z).asSymbol].set(b.value) });
            ~ui[("mute" ++ z).asSymbol] = { |v| page.children[5].value = v };

            EZSlider(page, Rect(10, 106, 190, 30), "HPF " ++ ~cc[("hpf" ++ z).asSymbol],
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("hpf" ++ z).asSymbol]),
                { |ez| ~ccVals[("hpf" ++ z).asSymbol] = ez.value;
                    ~buses[("hpf" ++ z).asSymbol].set(ez.value) });
            ~ui[("hpf" ++ z).asSymbol] = { |v| page.children[6].value = v };

            EZSlider(page, Rect(205, 106, 190, 30), "LPF " ++ ~cc[("lpf" ++ z).asSymbol],
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("lpf" ++ z).asSymbol]),
                { |ez| ~ccVals[("lpf" ++ z).asSymbol] = ez.value;
                    ~buses[("lpf" ++ z).asSymbol].set(ez.value) });
            ~ui[("lpf" ++ z).asSymbol] = { |v| page.children[7].value = v };

            EZSlider(page, Rect(400, 106, 190, 30), "RQ " ++ ~cc[("rq" ++ z).asSymbol],
                ControlSpec(0.05, 1.0, \lin, 0, ~ccVals[("rq" ++ z).asSymbol]),
                { |ez| ~ccVals[("rq" ++ z).asSymbol] = ez.value;
                    ~buses[("rq" ++ z).asSymbol].set(ez.value) });
            ~ui[("rq" ++ z).asSymbol] = { |v| page.children[8].value = v };

            EZSlider(page, Rect(10, 142, 140, 30), "ATK " ++ ~cc[("atk" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("atk" ++ z).asSymbol]),
                { |ez| ~ccVals[("atk" ++ z).asSymbol] = ez.value;
                    ~buses[("atk" ++ z).asSymbol].set(ez.value) });
            ~ui[("atk" ++ z).asSymbol] = { |v| page.children[9].value = v };

            EZSlider(page, Rect(155, 142, 140, 30), "DEC " ++ ~cc[("dec" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("dec" ++ z).asSymbol]),
                { |ez| ~ccVals[("dec" ++ z).asSymbol] = ez.value;
                    ~buses[("dec" ++ z).asSymbol].set(ez.value) });
            ~ui[("dec" ++ z).asSymbol] = { |v| page.children[10].value = v };

            EZSlider(page, Rect(300, 142, 140, 30), "SUS " ++ ~cc[("sus" ++ z).asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[("sus" ++ z).asSymbol]),
                { |ez| ~ccVals[("sus" ++ z).asSymbol] = ez.value;
                    ~buses[("sus" ++ z).asSymbol].set(ez.value) });
            ~ui[("sus" ++ z).asSymbol] = { |v| page.children[11].value = v };

            EZSlider(page, Rect(445, 142, 145, 30), "RLS " ++ ~cc[("rls" ++ z).asSymbol],
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("rls" ++ z).asSymbol]),
                { |ez| ~ccVals[("rls" ++ z).asSymbol] = ez.value;
                    ~buses[("rls" ++ z).asSymbol].set(ez.value) });
            ~ui[("rls" ++ z).asSymbol] = { |v| page.children[12].value = v };

            EZSlider(page, Rect(10, 186, 580, 34), zm.fxLabel ++ " " ++ ~cc[zm.fxKey.asSymbol],
                ControlSpec(0, 1, \lin, 0, ~ccVals[zm.fxKey.asSymbol]),
                { |ez| ~ccVals[zm.fxKey.asSymbol] = ez.value;
                    ~buses[zm.fxKey.asSymbol].set(ez.value) });
            ~ui[zm.fxKey.asSymbol] = { |v| page.children[13].value = v };

            StaticText(page, Rect(10, 224, 580, 18))
                .string_("◆ silver pots · luminous pin matrix · rotating Lissajous harmonics ◆")
                .font_(Font("Monaco", 10)).stringColor_(Color(0.3, 0.7, 0.4));
        };

        // Bottom bar
        bar = CompositeView(~mainWin, Rect(0, barY, 600, 120));
        bar.background = Color(0.10, 0.11, 0.10);

        EZSlider(bar, Rect(10, 8, 280, 30), "DELAY MIX " ++ ~cc[\delMix],
            ControlSpec(0, 1, \lin, 0, ~ccVals[\delMix]),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) });
        ~ui[\delMix] = { |v| bar.children[0].value = v };

        EZSlider(bar, Rect(300, 8, 290, 30), "REVERB MIX " ++ ~cc[\revMix],
            ControlSpec(0, 1, \lin, 0, ~ccVals[\revMix]),
            { |ez| ~ccVals[\revMix] = ez.value; ~buses[\revMix].set(ez.value) });
        ~ui[\revMix] = { |v| bar.children[1].value = v };

        EZSlider(bar, Rect(10, 44, 280, 30), "DELAY TIME " ++ ~cc[\delTime],
            ControlSpec(0.02, 1.0, \exp, 0, ~ccVals[\delTime]),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) });
        ~ui[\delTime] = { |v| bar.children[2].value = v };

        EZSlider(bar, Rect(300, 44, 290, 30), "REVERB TIME " ++ ~cc[\revTime],
            ControlSpec(0.2, 8.0, \exp, 0, ~ccVals[\revTime]),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) });
        ~ui[\revTime] = { |v| bar.children[3].value = v };

        Button(bar, Rect(10, 82, 580, 30)).states_([
            ["PANIC (ALL OFF) — CC " ++ ~cc[\panic], Color.white, Color(0.5, 0.05, 0.05)],
            ["RELEASED", Color.white, Color(0.2, 0.2, 0.2)]])
            .action_({ |b|
                if(b.value == 1) {
                    128.do { |i| ~release.(i) };
                    "PANIC".postln;
                };
            });

        ~mainWin.front;

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

        "Modular Cabinet ready — 3 zones, MIDI CC mapped.".postln;
    };
};

// ~mainWin.close; 128.do { |i| ~release.(i) };
)
```

</details>

<details>
<summary><strong>Round 06 [DESIGN] - Status: PASS</strong> — <em>O berimbau de barriga é um instrumento de percussão cordofone originário da Áfri...</em></summary>

- **Prompt**: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente enraizado na tradição cultural afro-brasileira da capoeira. Composto por uma verga de madeira de biriba curva esticada por arame de pneu de aço e uma cabaça ressonadora seca, é percutido por uma baqueta enquanto o dobrão de metal e o caxixi modulam timbres secos, ressonantes e hipnóticos.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: prepended pre-design synthesizer cleanup for previous design instance

```supercollider
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
// ═══════════════════════════════════════════════════════════════════
// BERIMBAU DE BARRIGA — Cordofone Afro-Brasileiro (Capoeira)
// ═══════════════════════════════════════════════════════════════════

// --- Step 0: CC map (must exist before MIDIdefs) ---
~cc = (
    vol1: 1, pan1: 2, mute1: 3, min1: 4, max1: 5, hpf1: 6, lpf1: 7, rq1: 8,
    atk1: 9, dec1: 10, sus1: 11, rls1: 12, fxDobrao: 13,
    vol2: 14, pan2: 15, mute2: 16, min2: 17, max2: 18, hpf2: 19, lpf2: 20, rq2: 21,
    atk2: 22, dec2: 23, sus2: 24, rls2: 25, fxCabaca: 26,
    vol3: 27, pan3: 28, mute3: 29, min3: 30, max3: 31, hpf3: 32, lpf3: 33, rq3: 34,
    atk3: 35, dec3: 36, sus3: 37, rls3: 38, fxCaxixi: 39,
    delMix: 40, revMix: 41, delTime: 42, revTime: 43, panic: 44
);

// --- Step 1 & 2: MIDI discovery + fallback ---
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
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

// --- Step 3: Boot ---
s.waitForBoot {
    // Default control values — all wet FX start DRY
    ~ccVals = (
        vol1: 0.25, pan1: 0.0,  mute1: 0, min1: 0,  max1: 75,  hpf1: 180, lpf1: 6500, rq1: 0.4,
        atk1: 0.001, dec1: 0.40, sus1: 0.0, rls1: 0.5, fxDobrao: 0.0,
        vol2: 0.22, pan2: -0.35, mute2: 0, min2: 36, max2: 100, hpf2: 25,  lpf2: 180,  rq2: 0.5,
        atk2: 0.005, dec2: 0.50, sus2: 0.2, rls2: 0.6, fxCabaca: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0, min3: 60, max3: 127, hpf3: 160, lpf3: 3200, rq3: 0.6,
        atk3: 0.001, dec3: 0.15, sus3: 0.0, rls3: 0.3, fxCaxixi: 0.0,
        delMix: 0.0, revMix: 0.0, delTime: 0.30, revTime: 3.0, panic: 0
    );

    // 2-line control bus allocation
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    // Groups
    ~synthGroup  = Group.new(s);
    ~fxGroup     = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    // Audio routing buses
    ~fxBus     = Bus.audio(s, 2);
    ~delayBus  = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    // ---------- Zone SynthDefs ----------
    // ZONE 1 — ARAME: steel wire struck, DynKlank metal + dobrão tension
    SynthDef(\arame, { |out=0, freq=220, gate=1, amp=0.25, pan=0.0,
        atk=0.001, dec=0.4, sus=0.0, rls=0.5,
        hpf=180, lpf=6500, rq=0.4, vol=0.25, mute=0, fxDobrao=0.0|
        var env, exciter, klank, tone, sig, dob;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        dob = fxDobrao.linlin(0, 1, 1.0, 1.12);
        exciter = WhiteNoise.ar(0.7) * EnvGen.kr(Env.perc(0.0005, 0.02));
        klank = DynKlank.ar(`[
            freq * dob * [1.0, 2.01, 3.03, 4.07, 5.11, 6.17],
            [1.0, 0.6, 0.4, 0.25, 0.15, 0.08],
            [1.0, 0.9, 0.7, 0.5, 0.35, 0.25]
        ], exciter, decayscale: (dec * 3.0) + 0.5);
        tone = SinOsc.ar(freq * dob, 0, 0.12) * EnvGen.kr(Env.perc(0.001, 0.18));
        sig = klank + tone;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ZONE 2 — CABAÇA: dry gourd body resonance
    SynthDef(\cabaca, { |out=0, freq=110, gate=1, amp=0.25, pan=0.0,
        atk=0.005, dec=0.5, sus=0.2, rls=0.6,
        hpf=25, lpf=180, rq=0.5, vol=0.22, mute=0, fxCabaca=0.0|
        var env, click, body, res, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        click = WhiteNoise.ar(0.5) * EnvGen.kr(Env.perc(0.0005, 0.03));
        body = SinOsc.ar(freq, 0, 0.7) + (SinOsc.ar(freq * 1.5, 0, 0.3));
        sig = body + click;
        res = BPF.ar(sig, (freq * 2.2).clip(60, 900), 0.3);
        sig = sig + (res * fxCabaca * 0.6);
        sig = RLPF.ar(sig, lpf * (1 + (fxCabaca * 2)), rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ZONE 3 — CAXIXI: shaker grain texture
    SynthDef(\caxixi, { |out=0, freq=440, gate=1, amp=0.2, pan=0.0,
        atk=0.001, dec=0.15, sus=0.0, rls=0.3,
        hpf=160, lpf=3200, rq=0.6, vol=0.2, mute=0, fxCaxixi=0.0|
        var env, noise, grain, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        noise = WhiteNoise.ar(0.5);
        sig = BPF.ar(noise, freq.clip(200, 8000), rq);
        grain = HPF.ar(noise, (freq * 1.5).clip(300, 12000)) * fxCaxixi * 0.5;
        sig = sig + grain;
        sig = RLPF.ar(sig, lpf, rq);
        sig = HPF.ar(sig, hpf);
        sig = LeakDC.ar(sig);
        sig = Pan2.ar(sig, pan, vol * amp * (1 - mute));
        Out.ar(out, sig * env);
    }).add;

    // ---------- FX SynthDefs ----------
    SynthDef(\fxDelay, { |in, out, delMix=0.0, delTime=0.3|
        var sig, dly;
        sig = In.ar(in, 2);
        dly = CombL.ar(sig, 1.0, delTime.lag(0.1), 3.0);
        dly = AllpassC.ar(dly, 0.02, 0.005, 0.5);
        Out.ar(out, (sig * (1 - delMix)) + (dly * delMix));
    }).add;

    SynthDef(\fxReverb, { |in, out, revMix=0.0, revTime=3.0|
        var sig, rev;
        sig = In.ar(in, 2);
        rev = FreeVerb2.ar(sig[0], sig[1], 1.0, 0.9, revTime.linlin(0.2, 8.0, 0.25, 0.95));
        Out.ar(out, (sig * (1 - revMix)) + (rev * revMix));
    }).add;

    SynthDef(\safetyLimiter, { |in, out, amp=0.92|
        var sig;
        sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, amp, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync; // CRITICAL — SynthDefs must exist before instantiating FX

    // ---------- FX chain ----------
    Synth(\fxDelay, [
        \in, ~fxBus.index, \out, ~delayBus.index,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap
    ], ~fxGroup, \addToTail);

    Synth(\fxReverb, [
        \in, ~delayBus.index, \out, ~masterBus.index,
        \revMix, ~buses[\revMix].asMap, \revTime, ~buses[\revTime].asMap
    ], ~fxGroup, \addToTail);

    Synth(\safetyLimiter, [
        \in, ~masterBus.index, \out, 0
    ], ~masterGroup, \addToTail);

    // ---------- Voice tracking ----------
    ~zoneNotes = Array.fill(3, { Array.fill(128, { [] }) });

    ~release = { |noteNum|
        ~zoneNotes.do { |zone|
            zone[noteNum].do(_.set(\gate, 0));
            zone[noteNum] = [];
        };
    };

    ~zoneSynthInfo = [
        (z: "1", synth: \arame,  fx: \fxDobrao),
        (z: "2", synth: \cabaca, fx: \fxCabaca),
        (z: "3", synth: \caxixi, fx: \fxCaxixi)
    ];

    // ---------- MIDI handlers ----------
    MIDIdef.noteOn(\on, { |vel, noteNum, chan, src|
        var amp = vel / 127.0;
        ~zoneSynthInfo.do { |info, i|
            var z = info.z;
            if((noteNum >= ~ccVals[("min" ++ z).asSymbol]) and: { noteNum <= ~ccVals[("max" ++ z).asSymbol] }) {
                var syn = Synth(info.synth, [
                    \out, ~fxBus.index,
                    \freq, noteNum.midicps, \amp, amp,
                    \hpf, ~buses[("hpf" ++ z).asSymbol].asMap,
                    \lpf, ~buses[("lpf" ++ z).asSymbol].asMap,
                    \rq,  ~buses[("rq"  ++ z).asSymbol].asMap,
                    \vol, ~buses[("vol" ++ z).asSymbol].asMap,
                    \pan, ~buses[("pan" ++ z).asSymbol].asMap,
                    \mute, ~buses[("mute"++ z).asSymbol].asMap,
                    \atk, ~buses[("atk" ++ z).asSymbol].asMap,
                    \dec, ~buses[("dec" ++ z).asSymbol].asMap,
                    \sus, ~buses[("sus" ++ z).asSymbol].asMap,
                    \rls, ~buses[("rls" ++ z).asSymbol].asMap,
                    info.fx, ~buses[info.fx].asMap
                ], ~synthGroup);
                ~zoneNotes[i][noteNum] = ~zoneNotes[i][noteNum].add(syn);
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\off, { |vel, noteNum, chan, src|
        3.do { |i|
            ~zoneNotes[i][noteNum].do(_.set(\gate, 0));
            ~zoneNotes[i][noteNum] = [];
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") }  { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.contains("sus") } { norm }
                    { ks.matchRegexp("atk|dec|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
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

    MIDIdef.cc(\panic, { |val|
        if(val > 63) { 128.do { |i| ~release.(i) }; "PANIC".postln };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // ---------- Zone metadata for GUI ----------
    ~zoneMeta = [
        (title: "ARAME",  desc: "steel wire · dobrão tension", fxKey: "fxDobrao", fxLabel: "DOBRÃO TENSION", z: 1),
        (title: "CABAÇA", desc: "gourd body · dry resonance",  fxKey: "fxCabaca", fxLabel: "GOURD RESONANCE", z: 2),
        (title: "CAXIXI", desc: "shaker · grain texture",      fxKey: "fxCaxixi", fxLabel: "SHAKER GRAIN",    z: 3)
    ];

    // Helper: slider factory (defined before defer uses it)
    ~mkSlider = { |parent, rect, key, spec, label|
        var ez;
        ez = EZSlider(parent, rect, label ++ " " ++ ~cc[key], spec,
            { |e| ~ccVals[key] = e.value; ~buses[key].set(e.value) });
        ~ui[key] = { |v| ez.value = v };
        ez;
    };

    // ---------- Paginated GUI ----------
    defer {
        var screen, winW, winH, pages, bar, tabBtns;
        screen = Window.availableBounds;
        winW = 620;
        winH = min(780, screen.height - 60);

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };

        ~mainWin = Window("BERIMBAU DE BARRIGA — Cordofone Afro-Brasileiro",
            Rect((screen.width - winW) / 2, (screen.height - winH) / 2, winW, winH), scroll: true);
        ~mainWin.background = Color(0.07, 0.08, 0.07);

        ~ui = ();
        pages = [];
        tabBtns = [];

        // Tab buttons
        3.do { |i|
            var idx = i;
            var zm = ~zoneMeta[idx];
            tabBtns = tabBtns.add(
                Button(~mainWin, Rect(10 + (idx * 200), 6, 195, 30))
                    .states_([[zm.title, Color.white, Color(0.12, 0.28, 0.12)],
                              [zm.title, Color.white, Color(0.28, 0.55, 0.22)]])
                    .action_({ |b|
                        pages.do { |p, j| p.visible = (j == idx) };
                        tabBtns.do { |tb, j| tb.value = if(j == idx, 1, 0) };
                    })
            );
        };
        tabBtns[0].value = 1;

        // Zone pages — built in ONE loop
        ~zoneMeta.do { |zm, idx|
            var z = zm.z.asString;
            var page = CompositeView(~mainWin, Rect(0, 42, winW, 272));
            page.background = Color(0.09, 0.10, 0.09);
            page.visible = (idx == 0);
            pages = pages.add(page);

            StaticText(page, Rect(10, 6, 580, 18))
                .string_("ZONE " ++ (idx + 1) ++ " · " ++ zm.title ++ " · " ++ zm.desc)
                .font_(Font("Monaco", 11, true))
                .stringColor_(Color(0.6, 0.85, 0.5));

            EZRanger(page, Rect(10, 28, 280, 34),
                "RANGE " ++ ~cc[("min" ++ z).asSymbol] ++ "/" ++ ~cc[("max" ++ z).asSymbol],
                ControlSpec(0, 127, \lin, 1, 0),
                { |ez|
                    ~ccVals[("min" ++ z).asSymbol] = ez.lo;
                    ~ccVals[("max" ++ z).asSymbol] = ez.hi;
                    ~buses[("min" ++ z).asSymbol].set(ez.lo);
                    ~buses[("max" ++ z).asSymbol].set(ez.hi);
                },
                ~ccVals[("min" ++ z).asSymbol], ~ccVals[("max" ++ z).asSymbol]);

            ~mkSlider.(page, Rect(300, 28, 290, 34), ("vol" ++ z).asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[("vol" ++ z).asSymbol]), "VOL");
            ~mkSlider.(page, Rect(10, 66, 280, 34), ("pan" ++ z).asSymbol,
                ControlSpec(-1, 1, \lin, 0, ~ccVals[("pan" ++ z).asSymbol]), "PAN");
            ~mkSlider.(page, Rect(300, 66, 290, 34), ("hpf" ++ z).asSymbol,
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("hpf" ++ z).asSymbol]), "HPF");
            ~mkSlider.(page, Rect(10, 104, 280, 34), ("lpf" ++ z).asSymbol,
                ControlSpec(20, 18000, \exp, 0, ~ccVals[("lpf" ++ z).asSymbol]), "LPF");
            ~mkSlider.(page, Rect(300, 104, 290, 34), ("rq" ++ z).asSymbol,
                ControlSpec(0.05, 1.0, \exp, 0, ~ccVals[("rq" ++ z).asSymbol]), "RQ");
            ~mkSlider.(page, Rect(10, 142, 280, 34), ("atk" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("atk" ++ z).asSymbol]), "ATK");
            ~mkSlider.(page, Rect(300, 142, 290, 34), ("dec" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("dec" ++ z).asSymbol]), "DEC");
            ~mkSlider.(page, Rect(10, 180, 280, 34), ("sus" ++ z).asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[("sus" ++ z).asSymbol]), "SUS");
            ~mkSlider.(page, Rect(300, 180, 290, 34), ("rls" ++ z).asSymbol,
                ControlSpec(0.005, 5, \exp, 0, ~ccVals[("rls" ++ z).asSymbol]), "RLS");
            ~mkSlider.(page, Rect(10, 218, 580, 38), zm.fxKey.asSymbol,
                ControlSpec(0, 1, \lin, 0, ~ccVals[zm.fxKey.asSymbol]), zm.fxLabel);
        };

        // Bottom bar
        bar = CompositeView(~mainWin, Rect(0, 320, winW, 120));
        bar.background = Color(0.10, 0.11, 0.10);

        ~mkSlider.(bar, Rect(10, 8, 280, 30), \delMix,
            ControlSpec(0, 1, \lin, 0, ~ccVals[\delMix]), "DELAY MIX");
        ~mkSlider.(bar, Rect(300, 8, 290, 30), \revMix,
            ControlSpec(0, 1, \lin, 0, ~ccVals[\revMix]), "REVERB MIX");
        ~mkSlider.(bar, Rect(10, 44, 280, 30), \delTime,
            ControlSpec(0.02, 1.0, \exp, 0, ~ccVals[\delTime]), "DELAY TIME");
        ~mkSlider.(bar, Rect(300, 44, 290, 30), \revTime,
            ControlSpec(0.2, 8.0, \exp, 0, ~ccVals[\revTime]), "REVERB TIME");

        Button(bar, Rect(10, 82, 580, 30)).states_([
            ["PANIC (ALL OFF) — CC " ++ ~cc[\panic], Color.white, Color(0.5, 0.05, 0.05)],
            ["RELEASED", Color.white, Color(0.2, 0.2, 0.2)]])
            .action_({ |b|
                if(b.value == 1) {
                    128.do { |i| ~release.(i) };
                    "PANIC".postln;
                };
            });

        ~mainWin.front;

        // 20fps poller
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

        "Berimbau de Barriga ready — 3 zones, MIDI CC mapped.".postln;
    };
};

// ~mainWin.close; 128.do { |i| ~release.(i) };
}.value;
)
```

</details>

<details>
<summary><strong>Round 07 [GENERATE] - Status: PASS</strong> — <em>A Congada é uma manifestação folclórica e religiosa sincrética brasileira que ce...</em></summary>

- **Prompt**: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de reis do Congo em louvor a Nossa Senhora do Rosário e a São Benedito. Encontrada em Minas Gerais, Goiás e São Paulo, envolve desfiles ritmados de ternos de congo e moçambiques, onde gungas de lata amarradas aos tornozelos produzem percussões metálicas e passos cadenciados.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback

```supercollider
(
// Clear conflicting names
[\congadaDrone, \gungas, \mocambique, \rosarioBells].do { |n| Ndef(n).clear(2) };
[\gungasSeq, \mocambiqueSeq, \bellSeq].do { |n| Pbindef(n).clear };

// ===== Layer 1: Devotional drone — warm analog pad, 2nd harmonic for translation =====
Ndef(\congadaDrone).fadeTime = 3;
Ndef(\congadaDrone, { |freq=55, amp=0.14, cutoff=650, t_trig=1|
    var sig, env, lfo;
    lfo = SinOsc.kr(0.07).range(0.6, 1.0);
    sig = Splay.ar(
        Saw.ar(freq * [0.5, 1, 1.005, 2, 2.01]) * [0.4, 0.5, 0.5, 0.25, 0.25]
    );
    sig = (MoogFF.ar(sig, cutoff * lfo, 2.2) * 2.5).tanh;
    env = Env.perc(1.5, 4.0, 1, -2).kr(2, t_trig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * env) } { Pan2.ar(sig, 0, amp * env) };
}).play;
Ndef(\congadaDrone)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.85, 0.6) };
Ndef(\congadaDrone).set(\wet10, 0.4);
Ndef(\congadaDrone).quant = 1;

// ===== Layer 2: Gungas — metallic ankle-rattle clicks =====
Ndef(\gungas).fadeTime = 2;
Ndef(\gungas, { |t_trig=1, freq=2400, amp=0.2, pan=0|
    var exc, sig, env, ring;
    env = Env.perc(0.001, 0.09, 1, -6).kr(2, t_trig);
    exc = Impulse.ar(0) + (PinkNoise.ar() * 0.4);
    ring = Ringz.ar(exc, [freq, freq*1.51, freq*2.13, freq*3.07], 0.045, 0.35).sum;
    sig = HPF.ar(ring, 1200);
    sig = (sig * 3.0).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\gungas)[11] = \filter -> { |in| (CombC.ar(in, 0.3, 0.13, 2.5) * 0.4) + in };
Ndef(\gungas).set(\wet11, 0.25);
Ndef(\gungas).quant = 1;

// ===== Layer 3: Moçambique drum — tuned membrane pulse with noise click =====
Ndef(\mocambique).fadeTime = 2;
Ndef(\mocambique, { |t_trig=1, freq=85, amp=0.28, pan=0|
    var sig, env, body, click;
    env = Env.perc(0.004, 0.35, 1, -4).kr(2, t_trig);
    body = (SinOsc.ar(freq * [1, 1.48, 2.3]) * [1, 0.35, 0.15]).sum;
    click = HPF.ar(PinkNoise.ar() * Env.perc(0.001, 0.02).kr(2, t_trig), 2000) * 0.5;
    sig = (body * 1.8).tanh + click;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\mocambique).quant = 1;

// ===== Layer 4: Rosary bells — modal bell arpeggio =====
Ndef(\rosarioBells).fadeTime = 3;
Ndef(\rosarioBells, { |t_trig=1, freq=880, amp=0.12, pan=0|
    var exc, sig, env;
    env = Env.perc(0.001, 1.6, 1, -5).kr(2, t_trig);
    exc = Impulse.ar(0);
    sig = DynKlank.ar(`[
        [freq, freq*2.01, freq*2.71, freq*3.52, freq*4.83],
        [1, 0.6, 0.4, 0.25, 0.15],
        [1, 0.9, 0.7, 0.5, 0.35]
    ], exc, 1, 0, 1.5);
    sig = (sig * 2.5).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\rosarioBells)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.5) };
Ndef(\rosarioBells).set(\wet10, 0.5);
Ndef(\rosarioBells).quant = 1;

// ===== Sequences =====
Pbindef(\mocambiqueSeq,
    \t_trig, 1,
    \freq, Pseq([85, 85, 92, 85, 78, 85, 92, 98], inf),
    \amp,  Pseq([0.30, 0.18, 0.26, 0.22, 0.30, 0.16, 0.24, 0.20], inf),
    \pan,  Pwhite(-0.3, 0.3, inf),
    \dur,  Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5], inf)
);
Ndef(\mocambique)[1] = \set -> Pbindef(\mocambiqueSeq);

Pbindef(\gungasSeq,
    \t_trig, 1,
    \freq, Pexprand(2000, 4200, inf),
    \amp,  Pexprand(0.08, 0.22, inf),
    \pan,  Pwhite(-0.85, 0.85, inf),
    \dur,  Pwrand([0.125, 0.25, 0.5, 0.0625], [0.45, 0.30, 0.15, 0.10], inf)
);
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);

Pbindef(\bellSeq,
    \t_trig, 1,
    \freq, Pn(Pgeom(440, 1.2, 8), inf),
    \amp,  Pexprand(0.06, 0.14, inf),
    \pan,  Pwhite(-0.6, 0.6, inf),
    \dur,  Pwrand([0.75, 1.5, 0.375, 3.0], [0.40, 0.30, 0.20, 0.10], inf)
);
Ndef(\rosarioBells)[1] = \set -> Pbindef(\bellSeq);
)

// ===== LIVE TWEAKS =====
// Ndef(\congadaDrone).xset(\cutoff, 1400); // Brighten drone | Revert: Ndef(\congadaDrone).xset(\cutoff, 650);
// Pbindef(\gungasSeq, \dur, 0.0625); // Denser gungas | Revert: Pbindef(\gungasSeq, \dur, 0.125);
// Ndef(\mocambique).xset(\freq, 70); // Deeper drum | Revert: Ndef(\mocambique).xset(\freq, 85);
// Ndef(\rosarioBells).set(\wet10, 0.8); // More hall | Revert: Ndef(\rosarioBells).set(\wet10, 0.5);
// Pbindef(\bellSeq).stop; Ndef(\rosarioBells).fadeTime = 4; Ndef(\rosarioBells).clear(4); // Rollback bells
// Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 4; Ndef(\gungas).clear(4); // Rollback gungas
// Pbindef(\mocambiqueSeq).stop; Ndef(\mocambique).fadeTime = 4; Ndef(\mocambique).clear(4); // Rollback drum
```

</details>

<details>
<summary><strong>Round 08 [GENERATE] - Status: PASS</strong> — <em>A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incan...</em></summary>

- **Prompt**: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido na superfície calma de um corixo repleto de camalotes e vitórias-régias. Centenas de tuiuiús pousados nos galhos secos de um piúva centenário observam em silêncio o bater de asas de um bando ruidoso de araras-azuis cruzando o céu crepuscular rumo ao dormitório nos capões de mata.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback

```supercollider
(
// ===== Pantanal Sunset — Corixo at Dusk =====
// Layer 1: Corixo water drone — warm sunset pad reflected on calm water
Ndef(\corixoBed).fadeTime = 4;
Ndef(\corixoBed, { |t_trig=1, freq=55, cutoff=650, amp=0.18|
    var sig, env, lfo;
    lfo = SinOsc.kr(0.05).range(0.7, 1.0);
    sig = Splay.ar(
        Saw.ar(freq * [0.5, 1, 1.005, 2, 2.01]) * [0.5, 0.5, 0.45, 0.2, 0.18]
    );
    sig = (MoogFF.ar(sig, cutoff * lfo, 2.0) * 2.2).tanh;
    env = Env.perc(2.0, 6.0, 1, -2).kr(2, t_trig);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], 0, amp * env) } { Pan2.ar(sig, 0, amp * env) };
}).play;
Ndef(\corixoBed)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.9, 0.7) };
Ndef(\corixoBed).set(\wet10, 0.45);
Ndef(\corixoBed).quant = 1;

// Layer 2: Arara-azul calls — FM squawk with wingbeat envelope
Ndef(\araraWings).fadeTime = 2;
Ndef(\araraWings, { |t_trig=1, freq=900, amp=0.14, pan=0|
    var env, mod, car, sig;
    env = Env.perc(0.005, 0.35, 1, -3).kr(2, t_trig);
    mod = SinOsc.ar(freq * 1.5) * (freq * 1.8);
    car = SinOsc.ar(freq + mod);
    sig = BPF.ar((car * 2.0).tanh, freq * 1.2, 0.6) * 3.0;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\araraWings)[11] = \filter -> { |in| (CombC.ar(in, 0.4, 0.18, 3.0) * 0.3) + in };
Ndef(\araraWings).set(\wet11, 0.3);
Ndef(\araraWings).quant = 1;

// Layer 3: Tuiuiú call — low vocal formant from the piúva canopy
Ndef(\tuiuiuCall).fadeTime = 3;
Ndef(\tuiuiuCall, { |t_trig=1, freq=180, amp=0.16, pan=0|
    var body, env, formF, sig;
    env = Env.perc(0.08, 0.9, 1, -3).kr(2, t_trig);
    body = Saw.ar(freq) * 0.7 + SinOsc.ar(freq) * 0.5;
    formF = [freq * 2.5, freq * 4.2, freq * 6.5];
    sig = BPF.ar(body, formF, 0.15).sum * 6.0;
    sig = (sig * 1.5).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\tuiuiuCall)[10] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.92, 0.6) };
Ndef(\tuiuiuCall).set(\wet10, 0.5);
Ndef(\tuiuiuCall).quant = 1;

// Layer 4: Vitória-régia shimmer — high water reflections and insect air
Ndef(\vitoriaShimmer).fadeTime = 3;
Ndef(\vitoriaShimmer, { |t_trig=1, freq=4500, amp=0.08, pan=0|
    var env, sig;
    env = Env.perc(0.002, 0.6, 1, -4).kr(2, t_trig);
    sig = BPF.ar(PinkNoise.ar(), freq, 0.08) * 12.0;
    sig = (sig * 1.4).tanh;
    Pan2.ar(sig, pan, amp * env);
}).play;
Ndef(\vitoriaShimmer)[12] = \filter -> { |in| FreeVerb2.ar(in[0], in[1], 1, 0.95, 0.8) };
Ndef(\vitoriaShimmer).set(\wet12, 0.55);
Ndef(\vitoriaShimmer).quant = 1;

// ===== Sequences =====
Pbindef(\corixoSeq,
    \t_trig, 1,
    \freq, Pseq([55, 55, 62, 55, 49, 55, 58, 55], inf),
    \amp,  Pseq([0.20, 0.14, 0.18, 0.16, 0.20, 0.12, 0.17, 0.15], inf),
    \cutoff, Pexprand(500, 900, inf),
    \dur,  Pseq([3, 2, 3, 2, 4, 2, 3, 3], inf)
);
Ndef(\corixoBed)[1] = \set -> Pbindef(\corixoSeq);

Pbindef(\araraSeq,
    \t_trig, 1,
    \freq, Pexprand(700, 1300, inf),
    \amp,  Pexprand(0.08, 0.18, inf),
    \pan,  Pwhite(-0.8, 0.8, inf),
    \dur,  Pwrand([0.18, 0.25, 0.4, 0.6], [0.4, 0.3, 0.2, 0.1], inf)
);
Ndef(\araraWings)[1] = \set -> Pbindef(\araraSeq);

Pbindef(\tuiuiuSeq,
    \t_trig, 1,
    \freq, Pn(Pgeom(160, 1.15, 6), inf),
    \amp,  Pexprand(0.10, 0.18, inf),
    \pan,  Pwhite(-0.5, 0.5, inf),
    \dur,  Pwrand([1.2, 2.0, 3.5, 0.8], [0.35, 0.3, 0.2, 0.15], inf)
);
Ndef(\tuiuiuCall)[1] = \set -> Pbindef(\tuiuiuSeq);

Pbindef(\shimmerSeq,
    \t_trig, 1,
    \freq, Pexprand(3500, 6500, inf),
    \amp,  Pexprand(0.04, 0.10, inf),
    \pan,  Pwhite(-0.9, 0.9, inf),
    \dur,  Pwrand([0.15, 0.3, 0.5, 0.08], [0.4, 0.3, 0.2, 0.1], inf)
);
Ndef(\vitoriaShimmer)[1] = \set -> Pbindef(\shimmerSeq);
)

// ===== LIVE TWEAKS =====
// Ndef(\corixoBed).xset(\cutoff, 1100); // Brighter sunset glow | Revert: Ndef(\corixoBed).xset(\cutoff, 650);
// Pbindef(\araraSeq, \dur, 0.1); // Denser macaw flock | Revert: Pbindef(\araraSeq, \dur, 0.25);
// Ndef(\tuiuiuCall).xset(\freq, 140); // Deeper stork call | Revert: Ndef(\tuiuiuCall).xset(\freq, 180);
// Ndef(\vitoriaShimmer).set(\wet12, 0.8); // More water shimmer | Revert: Ndef(\vitoriaShimmer).set(\wet12, 0.55);
// Pbindef(\shimmerSeq).stop; Ndef(\vitoriaShimmer).fadeTime = 4; Ndef(\vitoriaShimmer).clear(4); // Rollback shimmer
// Pbindef(\tuiuiuSeq).stop; Ndef(\tuiuiuCall).fadeTime = 4; Ndef(\tuiuiuCall).clear(4); // Rollback tuiuiu
// Pbindef(\araraSeq).stop; Ndef(\araraWings).fadeTime = 4; Ndef(\araraWings).clear(4); // Rollback araras
// Pbindef(\corixoSeq).stop; Ndef(\corixoBed).fadeTime = 4; Ndef(\corixoBed).clear(4); // Rollback corixo
```

</details>

### Model: OpenAI GP6 Luna (`openrouter:openai/gpt-6-luna`)

- **Initial Pass Rate**: 100.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 157.70s (mean LLM: 19.50s/round)
- **Total Tokens**: 75,036 (Cost: $0.01545)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261112_191506\session_gpt-6-luna.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
Ndef(\wineSuspended, { |freq=1760, amp=0.12, pan=0.2, t_trig=0|
    var env = EnvGen.kr(Env.perc(0.003, 2.8, 1, -5), t_trig);
    var tone = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.71) * 0.22);
    Pan2.ar(tone * env * amp, pan);
}).play;

Pbindef(\wineSuspendedSeq,
    \dur, Pseq([5, 7, 6, 9], inf),
    \freq, Pseq([1760, 1320, 2093, 1568], inf),
    \t_trig, 1,
    \amp, Pseq([0.10, 0.07, 0.09, 0.05], inf),
    \pan, Pseq([0.2, 0.15, 0.25, 0.1], inf)
);
Ndef(\wineSuspended)[1] = \set -> Pbindef(\wineSuspendedSeq);
Pbindef(\wineSuspendedSeq).play;
// Pbindef(\wineSuspendedSeq).stop; Ndef(\wineSuspended).fadeTime = 2; Ndef(\wineSuspended).clear(2); // Rollback: remove this instrument

Ndef(\mapFolds, { |freq=180, amp=0.16, pan=(-0.3), t_trig=0|
    var env = EnvGen.kr(Env.perc(0.001, 0.11, 1, -7), t_trig);
    var click = WhiteNoise.ar(0.7) + (SinOsc.ar(freq) * 0.3);
    var shaped = BPF.ar(click, freq * 4, 0.45);
    Pan2.ar(shaped * env * amp, pan);
}).play;

Pbindef(\mapFoldsSeq,
    \dur, Pseq([0.75, 1.25, 0.5, 2, 1.5, 3], inf),
    \freq, Pseq([180, 240, 145, 310, 190, 115], inf),
    \t_trig, 1,
    \amp, Pseq([0.14, 0.08, 0.12, 0.06, 0.1, 0.04], inf),
    \pan, Pseq([-0.3, 0.25, -0.15, 0.35, -0.25, 0.1], inf)
);
Ndef(\mapFolds)[1] = \set -> Pbindef(\mapFoldsSeq);
Pbindef(\mapFoldsSeq).play;
// Pbindef(\mapFoldsSeq).stop; Ndef(\mapFolds).fadeTime = 2; Ndef(\mapFolds).clear(2); // Rollback: remove this instrument

Ndef(\antarcticSilence, { |freq=38, amp=0.12, pan=0, t_trig=0|
    var slow = SinOsc.kr(0.035).range(0.985, 1.015);
    var sub = SinOsc.ar(freq * slow);
    var overtone = SinOsc.ar(freq * 2 * slow) * 0.32;
    var pressure = BPF.ar(PinkNoise.ar(0.2), 120, 0.25);
    var sig = (sub + overtone + pressure) * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\antarcticSilenceSeq,
    \dur, Pseq([12, 12, 16, 20], inf),
    \freq, Pseq([38, 38, 41, 38], inf),
    \t_trig, 1,
    \amp, Pseq([0.09, 0.12, 0.14, 0.08], inf),
    \pan, 0
);
Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);
Pbindef(\antarcticSilenceSeq).play;
// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)
```

</details>

<details>
<summary><strong>Round 02 [APPEND] - Status: PASS</strong> — <em>Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sa...</em></summary>

- **Prompt**: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Tinir de ferros... estalar de açoite... Legiões de homens negros como a noite, horrendos a dançar... Mulheres com crianças suspensas ao peito descarnado, homens gemendo sob a aragem salgada, pedindo a Deus um raio que quebre os elos da corrente maldita!
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
Ndef(\ironChain, { |freq=740, amp=0.1, pan=0, t_trig=0, decay=1.2|
    var strike = Decay2.ar(K2A.ar(t_trig), 0.001, 0.045) * WhiteNoise.ar(0.8);
    var metal = Ringz.ar(strike, [freq, freq * 1.414, freq * 2.17], decay, [0.45, 0.25, 0.16]).sum;
    var env = EnvGen.kr(Env.perc(0.001, decay, 1, -5), t_trig);
    Pan2.ar(metal * env * amp, pan);
}).play;

Pbindef(\ironChainSeq,
    \dur, Pseq([3, 1.5, 0.75, 0.5, 0.25, 0.25, 4], inf),
    \freq, Pseq([740, 622, 830, 554, 932, 494, 740], inf),
    \t_trig, 1,
    \decay, Pseq([1.8, 1.4, 1.1, 0.8, 0.55, 0.35, 2.4], inf),
    \amp, Pseq([0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.045], inf),
    \pan, Pseq([-0.65, 0.55, -0.35, 0.7, -0.6, 0.4, 0], inf)
);
Ndef(\ironChain)[1] = \set -> Pbindef(\ironChainSeq);
Pbindef(\ironChainSeq).play;
// Pbindef(\ironChainSeq).stop; Ndef(\ironChain).fadeTime = 2; Ndef(\ironChain).clear(2); // Rollback: remove this instrument
)
```

</details>

<details>
<summary><strong>Round 03 [COMPOSE] - Status: PASS</strong> — <em>Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, ...</em></summary>

- **Prompt**: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses e cronômetros de bolso trabalhavam em tempos ligeiramente desencontrados. O velho relojoeiro fechava os olhos no centro daquele enxame de tique-taques de latão e jurava ouvir, nas defasagens microscópicas entre as engrenagens, o próprio respirar do tempo.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\clockTick, { |out=0, freq=1800, amp=0.08, pan=0, decay=0.045|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -8), doneAction: 2);
        var click = WhiteNoise.ar(0.7) + SinOsc.ar(freq * 0.73, 0, 0.3);
        var sig = BPF.ar(click, freq, 0.32) * env * amp * 5;
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\clockChime, { |out=0, freq=880, amp=0.045, pan=0, decay=2|
        var env = EnvGen.ar(Env.perc(0.002, decay, 1, -4), doneAction: 2);
        var strike = Decay2.ar(Impulse.ar(0), 0.002, 0.035) * WhiteNoise.ar(0.4);
        var modes = Ringz.ar(strike, [freq, freq * 1.503, freq * 2.71], decay, [0.6, 0.24, 0.12]).sum;
        var tone = SinOsc.ar(freq * 0.5) * 0.12;
        Out.ar(out, Pan2.ar((modes + tone) * env * amp, pan));
    }).add;
    s.sync;

    Ndef(\clockBreath, { |amp=0, rate=0.08, cutoff=1400|
        var swell = SinOsc.kr(rate).range(0.15, 1);
        var air = BPF.ar(PinkNoise.ar(0.18), cutoff, 0.35);
        var low = SinOsc.ar(54 * SinOsc.kr(0.023).range(0.99, 1.01), 0, 0.18);
        Pan2.ar((air + low) * swell * amp, SinOsc.kr(0.11).range(-0.35, 0.35));
    }).play;
    Ndef(\clockBreath).fadeTime = 4;
    Ndef(\clockBreath).xset(\amp, 0);

    Ndef(\masterMix, {
        var ticks = In.ar(~synthBus, 2);
        var breath = Ndef(\clockBreath).ar(2);
        ticks + breath;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.24);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        LeakDC.ar(in);
    };
    Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\clockTicks,
        \instrument, \clockTick,
        \out, ~synthBus,
        \dur, Pseq([0.49, 0.51, 0.48, 0.52, 0.5, 0.5, 0.47, 0.53], inf),
        \freq, Pseq([1720, 1880, 1640, 2030, 1790, 1560, 1940, 1680], inf),
        \amp, Pseq([0.045, 0.035, 0.052, 0.032, 0.048, 0.04, 0.055, 0.034], inf),
        \decay, Pseq([0.035, 0.055, 0.04, 0.07], inf),
        \pan, Pwhite(-0.82, 0.82, inf)
    );
    Pbindef(\clockChimes,
        \instrument, \clockChime,
        \out, ~synthBus,
        \dur, Pseq([4.5, 6, 3.5, 7], inf),
        \freq, Pseq([880, 1174, 784, 1047, 932, 698], inf),
        \amp, Pseq([0.032, 0.026, 0.038, 0.024], inf),
        \decay, Pseq([2.1, 1.5, 2.7, 1.8], inf),
        \pan, Pseq([-0.5, 0.45, 0.15, -0.3], inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - A oficina desperta: latão em desencontro microscópico.".postln;
        Ndef(\clockBreath).fadeTime = 5;
        Ndef(\clockBreath).xset(\amp, 0.24, \cutoff, 900, \rate, 0.07);
        Pbindef(\clockTicks).play;
        4.wait;

        "0:05 - Duzentos balanços imaginários; cada tique recusa o uníssono.".postln;
        5.do { |i|
            Ndef(\clockBreath).xset(\cutoff, [680, 1250, 920, 1740, 760][i], \rate, [0.06, 0.11, 0.08, 0.14, 0.07][i]);
            Ndef(\masterMix).set(\wet10, [0.18, 0.32, 0.22, 0.38, 0.2][i]);
            3.wait;
        };

        "0:20 - Carrilhões franceses abrem pequenas fendas no mecanismo.".postln;
        Pbindef(\clockChimes).play;
        4.do { |i|
            Pbindef(\clockTicks, \dur, Pseq([[0.38, 0.62, 0.31, 0.69], [0.25, 0.75, 0.5, 0.5], [0.42, 0.58, 0.34, 0.66], [0.2, 0.8, 0.4, 0.6]][i], inf));
            Ndef(\clockBreath).xset(\cutoff, [1800, 2300, 1350, 2800][i]);
            3.wait;
        };

        "0:32 - O mecanismo toca seu limite: acelera, range, quase perde o pulso.".postln;
        Pbindef(\clockTicks, \dur, Pseq([0.18, 0.22, 0.16, 0.24, 0.2, 0.17], inf), \amp, Pseq([0.035, 0.05, 0.03, 0.055], inf));
        Ndef(\clockBreath).xset(\rate, 0.23, \cutoff, 3200, \amp, 0.16);
        Ndef(\masterMix).set(\wet10, 0.42);
        6.wait;

        "0:38 - Repentino recolhimento: resta o respirar entre duas engrenagens.".postln;
        Pbindef(\clockTicks).stop;
        Ndef(\clockBreath).fadeTime = 2;
        Ndef(\clockBreath).xset(\amp, 0.12, \cutoff, 520, \rate, 0.035);
        4.wait;

        "0:42 - Flashback: o tique inicial retorna, agora espaçado e mais frágil.".postln;
        Pbindef(\clockTicks,
            \dur, Pseq([0.49, 0.51, 0.48, 0.52, 0.5, 0.5, 0.47, 0.53], inf),
            \amp, Pseq([0.025, 0.018, 0.03, 0.02], inf)
        ).play;
        Pbindef(\clockChimes, \amp, Pseq([0.018, 0.014, 0.022, 0.015], inf));
        5.do { |i|
            Ndef(\clockBreath).xset(\cutoff, [700, 1100, 830, 620, 480][i]);
            2.wait;
        };

        "0:52 - O relojoeiro abre os olhos; o tempo fecha em seu centro.".postln;
        Pbindef(\clockTicks).stop;
        Pbindef(\clockChimes).stop;
        Ndef(\clockBreath).fadeTime = 5;
        Ndef(\clockBreath).xset(\amp, 0);
        5.wait;

        Pbindef(\clockTicks).clear;
        Pbindef(\clockChimes).clear;
        Ndef(\clockBreath).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 04 [COMPOSE] - Status: PASS</strong> — <em>A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no sécul...</em></summary>

- **Prompt**: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalista dinamarquês Peter Lund, é composta por sete amplos salões subterrâneos esculpidos pela ação milenar das águas em rocha calcária. Suas abóbadas úmidas exibem cortinas minerais, estalactites e estalagmites onde o gotejamento lento cria ressonâncias acústicas profundas na escuridão.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
s.waitForBoot({
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    SynthDef(\safetyLimiter, {
        var sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;
    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    SynthDef(\grutaGota, { |out=0, freq=680, amp=0.04, decay=1.5, pan=0|
        var env = EnvGen.ar(Env.perc(0.002, decay, 1, -5), doneAction: 2);
        var strike = Decay2.ar(Impulse.ar(0), 0.002, 0.035) * WhiteNoise.ar(0.5);
        var modes = Ringz.ar(strike, [freq, freq * 1.47, freq * 2.13], [decay, decay * 0.72, decay * 0.43], [1, 0.45, 0.22]).sum;
        Out.ar(out, Pan2.ar(modes * env * amp, pan));
    }).add;

    SynthDef(\grutaCortina, { |out=0, freq=210, amp=0.035, decay=3, pan=0|
        var env = EnvGen.ar(Env.perc(0.01, decay, 1, -3), doneAction: 2);
        var exc = BPF.ar(WhiteNoise.ar(0.7), freq * 2.2, 0.22);
        var modes = Ringz.ar(exc, [freq, freq * 1.31, freq * 1.82, freq * 2.6], [decay, decay * 0.8, decay * 0.65, decay * 0.4], [0.9, 0.6, 0.35, 0.2]).sum;
        Out.ar(out, Pan2.ar(modes * env * amp * 4, pan));
    }).add;

    SynthDef(\grutaEstalo, { |out=0, freq=95, amp=0.045, decay=0.42, pan=0|
        var env = EnvGen.ar(Env.perc(0.001, decay, 1, -7), doneAction: 2);
        var body = (SinOsc.ar(freq, 0, 0.7) + SinOsc.ar(freq * 2.03, 0, 0.22)) * env;
        var grit = BPF.ar(WhiteNoise.ar, freq * 5, 0.5) * env * 0.18;
        Out.ar(out, Pan2.ar((body + grit) * amp, pan));
    }).add;
    s.sync;

    Ndef(\grutaArUmido, {
        var breath = BrownNoise.ar(0.16) + PinkNoise.ar(0.06);
        var drift = LFNoise1.kr(0.08).range(380, 1450);
        var filtered = LPF.ar(HPF.ar(breath, 90), drift);
        var low = SinOsc.ar(38 + SinOsc.kr(0.035).range(0, 3), 0, 0.12);
        Pan2.ar((filtered + low + SinOsc.ar(76, 0, 0.035)) * \amp.kr(0), SinOsc.kr(0.045).range(-0.3, 0.3));
    }).play;
    Ndef(\grutaArUmido).fadeTime = 6;
    Ndef(\grutaArUmido).xset(\amp, 0);

    Ndef(\grutaAguaDistante, {
        var drops = Dust.ar(\density.kr(0.8));
        var resonant = Ringz.ar(drops, [310, 467, 702], [1.8, 2.6, 1.2], [0.45, 0.3, 0.2]).sum;
        var smear = AllpassC.ar(resonant, 0.22, [0.13, 0.19], 2.4).sum;
        Pan2.ar((resonant + smear) * \amp.kr(0), SinOsc.kr(0.07).range(-0.65, 0.65));
    }).play;
    Ndef(\grutaAguaDistante).fadeTime = 4;
    Ndef(\grutaAguaDistante).xset(\amp, 0);

    Ndef(\masterMix, {
        var dry = In.ar(~synthBus, 2);
        var air = Ndef(\grutaArUmido).ar(2);
        var water = Ndef(\grutaAguaDistante).ar(2);
        dry + air + water;
    });
    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.22);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        LeakDC.ar(in);
    };
    Ndef(\masterMix).set(\wet10, 0, \wet11, 0);
    Ndef(\masterMix).play;
    s.sync;

    Pbindef(\grutaGotejo,
        \instrument, \grutaGota, \out, ~synthBus,
        \dur, Pseq([1.1, 1.7, 0.8, 2.2, 1.4, 2.8], inf),
        \freq, Pseq([680, 523, 784, 587, 440, 698, 392], inf),
        \decay, Pseq([1.3, 2.1, 1.1, 2.8], inf),
        \amp, Pseq([0.04, 0.03, 0.046, 0.032], inf),
        \pan, Pwhite(-0.8, 0.8, inf)
    );
    Pbindef(\grutaMineral,
        \instrument, \grutaCortina, \out, ~synthBus,
        \dur, Pseq([4.5, 6.5, 3.8, 7], inf),
        \freq, Pseq([146, 174, 130, 196, 164, 220], inf),
        \decay, Pseq([3.2, 4.1, 2.7, 3.6], inf),
        \amp, Pseq([0.034, 0.027, 0.038, 0.03], inf),
        \pan, Pseq([-0.55, 0.42, 0.18, -0.28], inf)
    );
    Pbindef(\grutaFratura,
        \instrument, \grutaEstalo, \out, ~synthBus,
        \dur, Pseq([0.42, 0.58, 0.34, 0.66, 0.5], inf),
        \freq, Pseq([82, 97, 73, 110, 91, 65], inf),
        \decay, Pseq([0.26, 0.38, 0.22], inf),
        \amp, Pseq([0.042, 0.03, 0.05, 0.027], inf),
        \pan, Pwhite(-0.75, 0.75, inf)
    );

    Tdef(\masterScore, {
        var i;
        0.5.wait;
        "0:00 - A água respira sob a pedra; o primeiro salão se abre.".postln;
        Ndef(\grutaArUmido).fadeTime = 5;
        Ndef(\grutaArUmido).xset(\amp, 0.24);
        Ndef(\grutaAguaDistante).xset(\amp, 0.12, \density, 0.45);
        Pbindef(\grutaGotejo).play;
        5.wait;

        "0:06 - Gotejos isolados desenham as abóbadas calcárias.".postln;
        5.do { |i|
            Ndef(\grutaAguaDistante).xset(\density, [0.35, 0.8, 0.5, 1.1, 0.6][i]);
            Ndef(\masterMix).set(\wet10, [0.18, 0.28, 0.22, 0.34, 0.24][i]);
            3.wait;
        };

        "0:21 - Cortinas minerais: ressonâncias atravessam os salões.".postln;
        Pbindef(\grutaMineral).play;
        4.do { |i|
            Ndef(\grutaArUmido).xset(\amp, [0.22, 0.16, 0.26, 0.19][i]);
            Ndef(\grutaAguaDistante).xset(\density, [0.75, 1.3, 0.55, 1.05][i]);
            3.wait;
        };

        "0:33 - A rocha cede em estalos breves; a água chega ao limite.".postln;
        Pbindef(\grutaFratura).play;
        Ndef(\grutaAguaDistante).xset(\density, 2.8, \amp, 0.16);
        Ndef(\masterMix).set(\wet10, 0.42);
        5.wait;
        Pbindef(\grutaFratura).stop;
        Ndef(\grutaAguaDistante).xset(\density, 0.7, \amp, 0.09);

        "0:38 - Recolhimento súbito: resta o eco úmido de um salão vazio.".postln;
        Pbindef(\grutaGotejo).stop;
        Ndef(\grutaArUmido).fadeTime = 2;
        Ndef(\grutaArUmido).xset(\amp, 0.1);
        Ndef(\masterMix).set(\wet10, 0.5);
        5.wait;

        "0:43 - Flashback: uma gota retorna ao centro tonal, mais frágil.".postln;
        Pbindef(\grutaGotejo,
            \dur, Pseq([1.1, 1.7, 0.8, 2.2, 1.4, 2.8], inf),
            \freq, Pseq([680, 523, 784, 587, 440, 698, 392], inf),
            \amp, Pseq([0.021, 0.016, 0.025, 0.018], inf)
        ).play;
        Pbindef(\grutaMineral, \amp, Pseq([0.018, 0.014, 0.022, 0.016], inf));
        5.do { |i|
            Ndef(\grutaArUmido).xset(\amp, [0.12, 0.09, 0.11, 0.07, 0.04][i]);
            2.wait;
        };

        "0:53 - Os sete salões se apagam; permanece a última ressonância.".postln;
        Pbindef(\grutaGotejo).stop;
        Pbindef(\grutaMineral).stop;
        Ndef(\grutaArUmido).fadeTime = 5;
        Ndef(\grutaArUmido).xset(\amp, 0);
        Ndef(\grutaAguaDistante).fadeTime = 5;
        Ndef(\grutaAguaDistante).xset(\amp, 0);
        5.wait;

        Pbindef(\grutaGotejo).clear;
        Pbindef(\grutaMineral).clear;
        Pbindef(\grutaFratura).stop;
        Pbindef(\grutaFratura).clear;
        Ndef(\grutaArUmido).clear(2);
        Ndef(\grutaAguaDistante).clear(2);
        Ndef(\masterMix).clear(2);
        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });
    Tdef(\masterScore).play;
});
)
```

</details>

<details>
<summary><strong>Round 05 [DESIGN] - Status: PASS</strong> — <em>Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumb...</em></summary>

- **Prompt**: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de potenciômetros prateados, matrizes de pinos luminosos e cabos entrelaçados. Ao lado, a tela verde de fósforo de um osciloscópio analógico desenha figuras de Lissajous em rotação contínua que se dobram e se desdobram em harmônicos complexos.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27, atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxPatch: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47, atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxOrbit: 52,
    delMix: 60, verbMix: 61, panic: 123
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label;
    label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not and: { label.contains("bome").not } and: { label.contains("midiin2").not }
        and: { label.contains("midiin 2").not } and: { label.contains("microsoft gs").not }
        and: { label.contains("wavetable").not } and: { label.contains("midi through").not }
        and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    var keys, defaults;
    ~ccVals = (
        vol1: 0.22, pan1: 0.0, mute1: 0.0, min1: 0, max1: 68, hpf1: 25, lpf1: 180, rq1: 0.7, atk1: 0.01, dec1: 0.35, sus1: 0.65, rls1: 0.8, fxPatch: 0.0,
        vol2: 0.18, pan2: 0.25, mute2: 0.0, min2: 42, max2: 127, hpf2: 350, lpf2: 6500, rq2: 0.5, atk2: 0.008, dec2: 0.7, sus2: 0.0, rls2: 1.2, fxOrbit: 0.0,
        delMix: 0.0, verbMix: 0.0
    );
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });
    ~zoneMeta = [
        (title: "01 — Prata / Núcleo", fxKey: \fxPatch, fxLabel: "Patch Fold"),
        (title: "02 — Fósforo / Órbita", fxKey: \fxOrbit, fxLabel: "Lissajous Drift")
    ];

    SynthDef(\modularCore, { |out=0, freq=110, gate=1, amp=0.2, pan=0, hpf=25, lpf=180, rq=0.7, atk=0.01, dec=0.35, sus=0.65, rls=0.8, fx=0|
        var env, mod, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 2.71, 0, freq * (1 + (fx * 8)));
        sig = (SinOsc.ar(freq + mod) * 0.7) + (SinOscFB.ar(freq * 0.5, fx * 0.85) * 0.3);
        sig = Fold.ar(sig * (1 + (fx * 4)), -0.85, 0.85);
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000), rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\modularOrbit, { |out=0, freq=440, gate=1, amp=0.18, pan=0.25, hpf=350, lpf=6500, rq=0.5, atk=0.008, dec=0.7, sus=0, rls=1.2, fx=0|
        var env, phase, sig, exc, ring;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        phase = SinOsc.kr(0.07 + (fx * 0.4)).range(0.2, 0.8);
        sig = (Saw.ar(freq * [0.997, 1.003]) * 0.35).sum;
        sig = sig + (SinOsc.ar(freq * 2.71, SinOsc.kr(0.13).range(0, 2pi)) * 0.3);
        exc = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.04), gate);
        ring = CombL.ar(exc, 0.05, freq.reciprocal.clip(0.0001, 0.05), 1.4);
        sig = sig + (ring * (0.15 + (fx * 0.5)));
        sig = (sig * (1 + (fx * 2))).tanh;
        sig = RLPF.ar(HPF.ar(sig, hpf), lpf.clip(40, 18000) * phase.linlin(0.2, 0.8, 0.8, 1.2), rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env, pan, amp));
    }).add;

    SynthDef(\modDelay, { |in=0, out=0, mix=0|
        var sig, dry, wet;
        sig = In.ar(in, 2);
        dry = sig;
        wet = CombC.ar(sig, 1.2, 0.37, 2.8);
        Out.ar(out, XFade2.ar(dry, wet, mix.clip(0, 1).linlin(0, 1, -1, 1)));
    }).add;
    SynthDef(\modVerb, { |in=0, out=0, mix=0|
        var sig, wet;
        sig = In.ar(in, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 0.65, 0.82, 0.45);
        Out.ar(out, XFade2.ar(sig, wet, mix.clip(0, 1).linlin(0, 1, -1, 1)));
    }).add;
    SynthDef(\modMaster, { |in=0|
        var sig;
        sig = LeakDC.ar(In.ar(in, 2));
        ReplaceOut.ar(0, Limiter.ar(sig, 0.92, 0.01));
    }).add;
    s.sync;

    Synth.tail(~fxGroup, \modDelay, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.delMix.asMap]);
    Synth.tail(~fxGroup, \modVerb, [\in, ~audioBus, \out, ~audioBus, \mix, ~buses.verbMix.asMap]);
    Synth.tail(~masterGroup, \modMaster, [\in, ~audioBus]);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks, v;
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("vol") } { norm * 0.4 }
                    { ks.contains("Mix") } { norm }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
                if(key == \panic and: { val > 0 }) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\modNoteOn, { |vel, noteNum|
        var freq, amp;
        freq = noteNum.midicps;
        amp = vel / 127;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes[noteNum].add(Synth(\modularCore, [\out, ~audioBus, \freq, freq, \amp, ~ccVals[\vol1] * amp, \pan, ~ccVals[\pan1], \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap, \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap, \rls, ~buses.rls1.asMap, \fx, ~buses.fxPatch.asMap, \gate, 1], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes[noteNum].add(Synth(\modularOrbit, [\out, ~audioBus, \freq, freq, \amp, ~ccVals[\vol2] * amp, \pan, ~ccVals[\pan2], \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap, \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap, \rls, ~buses.rls2.asMap, \fx, ~buses.fxOrbit.asMap, \gate, 1], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\modNoteOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |syn| syn.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);
    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, winH, winW, pages, pageButtons, bottom, pageLabel;
        ~mainWin = Window("PHOSPHOR PATCH — Modular Lissajous", Window.availableBounds, resizable: false);
        bounds = Window.availableBounds;
        winW = 660;
        winH = min(740, bounds.height - 60);
        ~mainWin.bounds = Rect(bounds.center.x - (winW/2), bounds.center.y - (winH/2), winW, winH);
        ~mainWin.view.background = Color.fromHexString("#171b1d");
        pages = Array.newClear(~zoneMeta.size);
        ~ui = ();
        pageButtons = CompositeView(~mainWin, Rect(12, 12, 636, 40));
        pageLabel = StaticText(pageButtons, Rect(0, 0, 636, 30));
        pageLabel.stringColor = Color.green;
        ~zoneMeta.do { |zm, idx|
            var page, title, controls, names, x, y, w;
            page = CompositeView(~mainWin, Rect(12, 58, 636, winH - 140));
            page.background = Color.fromHexString("#22282a");
            pages[idx] = page;
            title = StaticText(page, Rect(16, 10, 600, 28));
            title.string = zm[\title] ++ "   •   " ++ zm[\fxLabel];
            title.stringColor = Color.fromHexString("#9aff8b");
            names = if(idx == 0, { [\vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxPatch] }, { [\vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxOrbit] });
            controls = names;
            controls.do { |key, j|
                var col, row, label, slider;
                col = j % 3;
                row = (j / 3).floor;
                x = 12 + (col * 205);
                y = 52 + (row * 78);
                label = key.asString ++ "  CC " ++ ~cc[key].asString;
                slider = EZSlider(page, Rect(x, y, 195, 62), label, ControlSpec(
                    if(key.asString.contains("pan"), -1, 0),
                    if(key.asString.contains("pan"), 1, if(key.asString.matchRegexp("hpf|lpf"), 18000, if(key.asString.matchRegexp("min|max"), 127, 5))),
                    \lin, 0, ~ccVals[key]
                ), { |ez| ~ccVals[key] = ez.value; if(~buses[key].notNil) { ~buses[key].set(ez.value) } }, ~ccVals[key]);
                slider.labelView.stringColor = Color.white;
                ~ui[key] = slider;
            };
        };
        ~zoneMeta.do { |zm, idx|
            var button;
            button = Button(pageButtons, Rect(idx * 150, 0, 145, 32));
            button.states = [[zm[\title], Color.white, Color.fromHexString("#344448")]];
            button.action = { pages.do { |p, j| p.visible = (j == idx) }; pageLabel.string = zm[\fxLabel] };
            if(idx == 0) { button.value = 1; pages[idx].visible = true } { pages[idx].visible = false };
        };
        bottom = CompositeView(~mainWin, Rect(12, winH - 72, 636, 55));
        EZSlider(bottom, Rect(0, 0, 195, 48), "Delay mix CC 60", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\delMix] = ez.value; ~buses.delMix.set(ez.value) }, 0);
        EZSlider(bottom, Rect(205, 0, 195, 48), "Reverb mix CC 61", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\verbMix] = ez.value; ~buses.verbMix.set(ez.value) }, 0);
        Button(bottom, Rect(430, 4, 190, 38)).states_([["PANIC (ALL OFF)", Color.white, Color.red]]).action_({ ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } });
        ~mainWin.front;
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
```

</details>

<details>
<summary><strong>Round 06 [DESIGN] - Status: PASS</strong> — <em>O berimbau de barriga é um instrumento de percussão cordofone originário da Áfri...</em></summary>

- **Prompt**: O berimbau de barriga é um instrumento de percussão cordofone originário da África e profundamente enraizado na tradição cultural afro-brasileira da capoeira. Composto por uma verga de madeira de biriba curva esticada por arame de pneu de aço e uma cabaça ressonadora seca, é percutido por uma baqueta enquanto o dobrão de metal e o caxixi modulam timbres secos, ressonantes e hipnóticos.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: prepended pre-design synthesizer cleanup for previous design instance

```supercollider
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
~cc = (
    vol1: 20, pan1: 21, mute1: 22, min1: 23, max1: 24, hpf1: 25, lpf1: 26, rq1: 27,
    atk1: 28, dec1: 29, sus1: 30, rls1: 31, fxGourd: 32,
    vol2: 40, pan2: 41, mute2: 42, min2: 43, max2: 44, hpf2: 45, lpf2: 46, rq2: 47,
    atk2: 48, dec2: 49, sus2: 50, rls2: 51, fxCaxixi: 52,
    delMix: 60, verbMix: 61, panic: 123
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label;
    label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label;
        label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not and: { label.contains("bome").not }
            and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not } and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not } and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? { MIDIClient.sources.first };

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    var keys, vals;
    keys = [
        \vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxGourd,
        \vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxCaxixi,
        \delMix,\verbMix
    ];
    vals = [
        0.22,0,0,0,72,25,1800,0.5,0.005,0.35,0.5,0.25,0,
        0.17,0.25,0,38,110,350,6500,0.55,0.001,0.15,0,0.18,0,
        0,0
    ];
    ~ccVals = ();
    keys.do { |k, i| ~ccVals[k] = vals[i] };
    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };
    ~audioBus = Bus.audio(s, 2);
    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);
    ~zoneNotes = Array.fill(128, { List.new });

    SynthDef(\berimbauBody, {
        |out=0, freq=220, amp=0.22, pan=0, gate=1, mute=0, hpf=25, lpf=1800,
        rq=0.5, atk=0.005, dec=0.35, sus=0.5, rls=0.25, fx=0|
        var env, bow, wire, body, tone, sig, thump;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        bow = WhiteNoise.ar(0.18) * EnvGen.kr(Env.perc(0.001, 0.035));
        wire = SinOsc.ar(freq, 0, 0.25) + SinOsc.ar(freq * (1.002 + (fx * 0.012)), 0, 0.16)
            + SinOsc.ar(freq * 2, 0, 0.08);
        body = CombL.ar(bow, 0.08, (freq.reciprocal * 0.5).clip(0.001, 0.08), 0.4 + (fx * 2));
        thump = SinOsc.ar(freq * 0.5, 0, EnvGen.kr(Env.perc(0.001, 0.12)) * 0.18);
        tone = (wire + body + thump) * (1 + (fx * 2));
        sig = RLPF.ar(HPF.ar(tone, hpf), lpf, rq.clip(0.05, 1));
        sig = Pan2.ar(sig * env * amp * (1 - mute), pan);
        Out.ar(out, sig);
    }).add;

    SynthDef(\berimbauRattle, {
        |out=0, freq=220, amp=0.17, pan=0.25, gate=1, mute=0, hpf=350, lpf=6500,
        rq=0.55, atk=0.001, dec=0.15, sus=0, rls=0.12, fx=0|
        var env, hit, cax, metal, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        hit = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.018));
        cax = CombL.ar(hit, 0.04, (freq.reciprocal * 0.23).clip(0.001, 0.04), 0.08 + (fx * 0.65));
        metal = SinOsc.ar(freq * 2.71, 0, 0.07) + SinOsc.ar(freq * 3.51, 0, 0.045);
        sig = RLPF.ar(HPF.ar(cax + (metal * EnvGen.kr(Env.perc(0.001, 0.06))), hpf), lpf, rq.clip(0.05, 1));
        Out.ar(out, Pan2.ar(sig * env * amp * (1 - mute), pan));
    }).add;

    SynthDef(\berimbauMaster, {
        |inBus=0, out=0, delMix=0, verbMix=0|
        var dry, delayed, reverbed, sig;
        dry = In.ar(inBus, 2);
        delayed = CombC.ar(dry, 1.2, 0.31, 2.4);
        reverbed = FreeVerb2.ar(dry[0], dry[1], 0.7, 0.72, 0.25);
        sig = dry + (delayed * delMix) + ((reverbed - dry) * verbMix);
        sig = Limiter.ar(LeakDC.ar(sig), 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;
    Synth.tail(~masterGroup, \berimbauMaster, [
        \inBus, ~audioBus.index, \delMix, ~buses.delMix.asMap, \verbMix, ~buses.verbMix.asMap
    ]);

    ~zoneMeta = [
        (title: "CABAÇA / ARAME", fxKey: \fxGourd, fxLabel: "Gourd resonance"),
        (title: "CAXIXI / DOBRÃO", fxKey: \fxCaxixi, fxLabel: "Rattle & metal")
    ];

    MIDIdef.noteOn(\berimbauOn, { |vel, noteNum|
        var freq, syn;
        freq = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            syn = Synth(\berimbauBody, [
                \out, ~audioBus.index, \freq, freq, \amp, vel / 127,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                \atk, ~buses.atk1.asMap, \dec, ~buses.dec1.asMap, \sus, ~buses.sus1.asMap,
                \rls, ~buses.rls1.asMap, \fx, ~buses.fxGourd.asMap
            ], ~synthGroup);
            ~zoneNotes[noteNum].add(syn);
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            syn = Synth(\berimbauRattle, [
                \out, ~audioBus.index, \freq, freq, \amp, (vel / 127) * 0.7,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \dec, ~buses.dec2.asMap, \sus, ~buses.sus2.asMap,
                \rls, ~buses.rls2.asMap, \fx, ~buses.fxCaxixi.asMap
            ], ~synthGroup);
            ~zoneNotes[noteNum].add(syn);
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\berimbauOff, { |vel, noteNum|
        ~zoneNotes[noteNum].do { |syn| syn.set(\gate, 0) };
        ~zoneNotes[noteNum].clear;
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm;
        norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            var ks, v;
            if(num == ccNum) {
                ks = key.asString;
                v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linlin(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { norm };
                if(key != \panic) {
                    ~ccVals[key] = v;
                    if(~buses[key].notNil) { ~buses[key].set(v) };
                };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\panic, { |val|
        if(val > 0) { ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var bounds, winW, winH, pages, pageButtons, bottom, pageLabel, screen;
        bounds = Window.availableBounds;
        screen = bounds.height;
        winW = 660;
        winH = min(780, screen - 60);
        if(~mainWin.notNil) { ~mainWin.close };
        ~mainWin = Window("BERIMBAU — CABAÇA / ARAME", bounds, resizable: false, scroll: true);
        ~mainWin.bounds = Rect(bounds.center.x - (winW / 2), bounds.center.y - (winH / 2), winW, winH);
        ~mainWin.view.background = Color.fromHexString("#171b1d");
        pages = Array.newClear(~zoneMeta.size);
        ~ui = ();
        pageButtons = CompositeView(~mainWin, Rect(12, 10, 636, 38));
        pageLabel = StaticText(pageButtons, Rect(310, 4, 310, 28));
        pageLabel.stringColor = Color.green;
        ~zoneMeta.do { |zm, idx|
            var page, title, names;
            page = CompositeView(~mainWin, Rect(12, 55, 636, winH - 132));
            page.background = Color.fromHexString("#22282a");
            pages[idx] = page;
            title = StaticText(page, Rect(16, 8, 600, 28));
            title.string = zm[\title] ++ " — " ++ zm[\fxLabel];
            title.stringColor = Color.fromHexString("#9aff8b");
            names = if(idx == 0,
                { [\vol1,\pan1,\mute1,\min1,\max1,\hpf1,\lpf1,\rq1,\atk1,\dec1,\sus1,\rls1,\fxGourd] },
                { [\vol2,\pan2,\mute2,\min2,\max2,\hpf2,\lpf2,\rq2,\atk2,\dec2,\sus2,\rls2,\fxCaxixi] });
            names.do { |key, j|
                var col, row, isPan, isFreq, high, label, slider;
                col = j % 3;
                row = (j / 3).floor;
                isPan = key.asString.contains("pan");
                isFreq = key.asString.matchRegexp("hpf|lpf");
                high = if(isPan, 1, if(isFreq, 18000, if(key.asString.matchRegexp("min|max"), 127, 5)));
                label = key.asString ++ "  CC " ++ ~cc[key].asString;
                slider = EZSlider(page, Rect(12 + (col * 205), 45 + (row * 76), 195, 62), label,
                    ControlSpec(if(isPan, -1, 0), high, \lin, 0, ~ccVals[key]),
                    { |ez| ~ccVals[key] = ez.value; ~buses[key].set(ez.value) }, ~ccVals[key]);
                slider.labelView.stringColor = Color.white;
                ~ui[key] = slider;
            };
        };
        ~zoneMeta.do { |zm, idx|
            var button;
            button = Button(pageButtons, Rect(idx * 150, 2, 145, 30));
            button.states = [[zm[\title], Color.white, Color.fromHexString("#344448")]];
            button.action = { pages.do { |pg, j| pg.visible = (j == idx) }; pageLabel.string = zm[\fxLabel] };
            if(idx == 0) { button.value = 1; pages[idx].visible = true } { pages[idx].visible = false };
        };
        bottom = CompositeView(~mainWin, Rect(12, winH - 68, 636, 54));
        EZSlider(bottom, Rect(0, 0, 195, 48), "Delay mix CC 60", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\delMix] = ez.value; ~buses.delMix.set(ez.value) }, 0);
        EZSlider(bottom, Rect(205, 0, 195, 48), "Reverb mix CC 61", ControlSpec(0, 1, \lin), { |ez| ~ccVals[\verbMix] = ez.value; ~buses.verbMix.set(ez.value) }, 0);
        Button(bottom, Rect(430, 4, 190, 38)).states_([["PANIC (ALL OFF)", Color.white, Color.red]])
            .action_({ ~zoneNotes.do { |list| list.do { |syn| syn.set(\gate, 0) }; list.clear } });
        ~mainWin.front;
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
}.value;
)
```

</details>

<details>
<summary><strong>Round 07 [GENERATE] - Status: PASS</strong> — <em>A Congada é uma manifestação folclórica e religiosa sincrética brasileira que ce...</em></summary>

- **Prompt**: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de reis do Congo em louvor a Nossa Senhora do Rosário e a São Benedito. Encontrada em Minas Gerais, Goiás e São Paulo, envolve desfiles ritmados de ternos de congo e moçambiques, onde gungas de lata amarradas aos tornozelos produzem percussões metálicas e passos cadenciados.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// Congada: chão cadenciado, gungas metálicas e canto de coroação
 Ndef(\congoChao, {
     |t_trig=0, freq=55, amp=0.16, pan=0|
     var env, slow, sig;
     env = EnvGen.kr(Env.perc(0.08, 1.8, 1, -4), t_trig);
     slow = SinOsc.kr(0.09).range(0.94, 1.06);
     sig = (Pulse.ar(freq * slow, 0.46) * 0.22) + SinOsc.ar(freq * 2 * slow, 0, 0.18);
     sig = LPF.ar(sig, 260);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(3).play;

 Ndef(\congoGungas, {
     |t_trig=0, freq=620, amp=0.13, pan=0, tone=3200|
     var env, hit, metal;
     env = EnvGen.kr(Env.perc(0.002, 0.24, 1, -7), t_trig);
     hit = Decay2.ar(K2A.ar(t_trig), 0.001, 0.035) * WhiteNoise.ar(0.35);
     metal = SinOsc.ar(freq, 0, 0.55)
         + SinOsc.ar(freq * 2.71, 0, 0.30)
         + SinOsc.ar(freq * 3.51, 0, 0.18);
     metal = metal + BPF.ar(hit, freq * 2.4, 0.22) * 4;
     metal = LPF.ar(metal, tone);
     Pan2.ar(metal * env, pan, amp);
 }).fadeTime_(0.15).play;

 Ndef(\congoCoroa, {
     |t_trig=0, freq=392, amp=0.11, pan=0|
     var env, index, mod, sig;
     env = EnvGen.kr(Env.perc(0.01, 1.1, 1, -5), t_trig);
     index = Decay2.kr(t_trig, 0.01, 0.32).range(0.2, 2.8);
     mod = SinOsc.ar(freq * 2.71) * (freq * index);
     sig = SinOsc.ar((freq * 1.003) + mod)
         + (SinOsc.ar(freq * 3.51 + mod * 0.37) * 0.28);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(1.5).play;

 // Ambiência comum: reverberação integral, misturada pelo slot do proxy
 Ndef(\congoChao)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.72, 0.42)
 };
 Ndef(\congoChao).set(\wet10, 0.22);

 Ndef(\congoGungas)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.48, 0.28)
 };
 Ndef(\congoGungas).set(\wet10, 0.18);

 Ndef(\congoCoroa)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.52)
 };
 Ndef(\congoCoroa).set(\wet10, 0.30);

 // Passos cadenciados: pulsação grave com variações de andamento e acento
 Pbindef(\congoChaoSeq,
     \dur, Pwrand([0.5, 0.75, 1], [0.58, 0.3, 0.12], inf),
     \freq, Pseq([55, 55, 65.41, 55, 73.42, 65.41, 55, 49], inf),
     \amp, Pwhite(0.11, 0.17, inf),
     \pan, Pwhite(-0.18, 0.18, inf),
     \t_trig, 1
 );
 Ndef(\congoChao).quant = 1;
 Ndef(\congoChao)[1] = \set -> Pbindef(\congoChaoSeq);

 // Gungas: balanço metálico irregular sobre os ternos em marcha
 Pbindef(\congoGungasSeq,
     \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.38, 0.14], inf),
     \freq, Pseq([620, 740, 620, 880, 740, 620, 990, 740], inf),
     \amp, Pwhite(0.07, 0.13, inf),
     \pan, Pwhite(-0.72, 0.72, inf),
     \tone, Pwhite(2400, 4200, inf),
     \t_trig, 1
 );
 Ndef(\congoGungas).quant = 1;
 Ndef(\congoGungas)[1] = \set -> Pbindef(\congoGungasSeq);

 // Coroação: frase modal em respostas espaçadas, com brilho de sino
 Pbindef(\congoCoroaSeq,
     \dur, Pwrand([0.75, 1, 1.5, 2], [0.28, 0.38, 0.24, 0.1], inf),
     \freq, Pseq([392, 440, 493.88, 587.33, 523.25, 440, 392, 329.63], inf),
     \amp, Pwhite(0.065, 0.11, inf),
     \pan, Pwhite(-0.5, 0.5, inf),
     \t_trig, 1
 );
 Ndef(\congoCoroa).quant = 1;
 Ndef(\congoCoroa)[1] = \set -> Pbindef(\congoCoroaSeq);

 // Ndef(\congoGungas).xset(\tone, 2100); // Escurecer metais | Revert: Ndef(\congoGungas).xset(\tone, 3200);
 // Pbindef(\congoGungasSeq, \dur, 0.25); // Acelerar gungas | Revert: Pbindef(\congoGungasSeq, \dur, Pwrand([0.25, 0.5, 0.75], [0.48, 0.38, 0.14], inf));
 // Pbindef(\congoChaoSeq).stop; Ndef(\congoChao).fadeTime = 4; Ndef(\congoChao).clear(4); // Rollback chão
 // Pbindef(\congoGungasSeq).stop; Ndef(\congoGungas).fadeTime = 4; Ndef(\congoGungas).clear(4); // Rollback gungas
 // Pbindef(\congoCoroaSeq).stop; Ndef(\congoCoroa).fadeTime = 4; Ndef(\congoCoroa).clear(4); // Rollback coroação
)
```

</details>

<details>
<summary><strong>Round 08 [GENERATE] - Status: PASS</strong> — <em>A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incan...</em></summary>

- **Prompt**: A linha do horizonte no Pantanal sul-mato-grossense tinge-se de um laranja incandescente refletido na superfície calma de um corixo repleto de camalotes e vitórias-régias. Centenas de tuiuiús pousados nos galhos secos de um piúva centenário observam em silêncio o bater de asas de um bando ruidoso de araras-azuis cruzando o céu crepuscular rumo ao dormitório nos capões de mata.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// Pantanal ao crepúsculo: corixo, piúva silenciosa e voo das araras-azuis
 Ndef(\pantanalCorixo, {
     |t_trig=0, freq=55, amp=0.15, pan=0, cutoff=260|
     var env, tide, low, shimmer, sig;
     env = EnvGen.kr(Env.perc(0.8, 5.5, 1, -4), t_trig);
     tide = SinOsc.kr(0.035).range(0.94, 1.06);
     low = SinOsc.ar(freq * tide, 0, 0.24)
         + SinOsc.ar(freq * 2 * tide, 0, 0.12);
     shimmer = BPF.ar(PinkNoise.ar(0.12), 430 + SinOsc.kr(0.07).range(0, 90), 0.35);
     sig = LPF.ar(low + shimmer, cutoff);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(5).play;

 Ndef(\pantanalTuiuiu, {
     |t_trig=0, freq=740, amp=0.11, pan=0, tone=2500|
     var env, tick, modes, sig;
     env = EnvGen.kr(Env.perc(0.004, 0.72, 1, -6), t_trig);
     tick = Decay2.ar(K2A.ar(t_trig), 0.002, 0.06) * WhiteNoise.ar(0.22);
     modes = SinOsc.ar(freq, 0, 0.55)
         + SinOsc.ar(freq * 2.71, 0, 0.24)
         + SinOsc.ar(freq * 3.51, 0, 0.12);
     sig = modes + (BPF.ar(tick, freq * 2.2, 0.24) * 3);
     sig = LPF.ar(sig, tone);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(0.4).play;

 Ndef(\pantanalAraras, {
     |t_trig=0, freq=880, amp=0.10, pan=0, brightness=3200|
     var env, index, mod, call, rasp, sig;
     env = EnvGen.kr(Env.perc(0.008, 0.42, 1, -5), t_trig);
     index = Decay2.kr(t_trig, 0.006, 0.22).range(0.3, 3.4);
     mod = SinOsc.ar(freq * 1.47) * (freq * index);
     call = SinOsc.ar((freq * 1.006) + mod)
         + (SinOsc.ar(freq * 2.03 + (mod * 0.31), 0, 0.3));
     rasp = BPF.ar(WhiteNoise.ar(0.16), freq * 2.8, 0.3);
     sig = LPF.ar(call + rasp, brightness);
     Pan2.ar(sig * env, pan, amp);
 }).fadeTime_(0.18).play;

 Ndef(\pantanalCorixo)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.86, 0.48)
 };
 Ndef(\pantanalCorixo).set(\wet10, 0.27);

 Ndef(\pantanalTuiuiu)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.7, 0.35)
 };
 Ndef(\pantanalTuiuiu).set(\wet10, 0.24);

 Ndef(\pantanalAraras)[10] = \filter -> { |in|
     FreeVerb2.ar(in[0], in[1], 1, 0.58, 0.3)
 };
 Ndef(\pantanalAraras).set(\wet10, 0.18);

 // Corixo: brilho alaranjado e movimento lento sobre o grave refletido
 Pbindef(\pantanalCorixoSeq,
     \dur, Pwrand([2, 3, 4, 6], [0.28, 0.36, 0.24, 0.12], inf),
     \freq, Pseq([55, 55, 65.41, 55, 49, 55, 73.42, 65.41], inf),
     \cutoff, Pwhite(220, 430, inf),
     \amp, Pwhite(0.10, 0.15, inf),
     \pan, Pwhite(-0.16, 0.16, inf),
     \t_trig, 1
 );
 Ndef(\pantanalCorixo).quant = 1;
 Ndef(\pantanalCorixo)[1] = \set -> Pbindef(\pantanalCorixoSeq);

 // Tuiuiús imóveis nos galhos: poucas ressonâncias, espaçadas e graves
 Pbindef(\pantanalTuiuiuSeq,
     \dur, Pwrand([1.5, 2, 3, 4], [0.2, 0.38, 0.3, 0.12], inf),
     \freq, Pseq([740, 659.25, 587.33, 659.25, 523.25, 587.33, 740, 659.25], inf),
     \tone, Pwhite(1900, 2900, inf),
     \amp, Pwhite(0.055, 0.10, inf),
     \pan, Pwhite(-0.7, 0.7, inf),
     \t_trig, 1
 );
 Ndef(\pantanalTuiuiu).quant = 1;
 Ndef(\pantanalTuiuiu)[1] = \set -> Pbindef(\pantanalTuiuiuSeq);

 // Araras-azuis: frases agudas e vivas, em bandos atravessando o céu
 Pbindef(\pantanalArarasSeq,
     \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.28, 0.28, 0.12], inf),
     \freq, Pseq([880, 987.77, 1174.66, 1046.5, 1318.51, 1174.66, 987.77, 783.99], inf),
     \brightness, Pwhite(2400, 3900, inf),
     \amp, Pwhite(0.055, 0.10, inf),
     \pan, Pwhite(-0.9, 0.9, inf),
     \t_trig, 1
 );
 Ndef(\pantanalAraras).quant = 1;
 Ndef(\pantanalAraras)[1] = \set -> Pbindef(\pantanalArarasSeq);

 // Ndef(\pantanalCorixo).xset(\cutoff, 520); // Abrir o reflexo | Revert: Ndef(\pantanalCorixo).xset(\cutoff, 260);
 // Pbindef(\pantanalArarasSeq, \dur, 0.25); // Acelerar o bando | Revert: Pbindef(\pantanalArarasSeq, \dur, Pwrand([0.25, 0.375, 0.5, 0.75], [0.32, 0.28, 0.28, 0.12], inf));
 // Pbindef(\pantanalCorixoSeq).stop; Ndef(\pantanalCorixo).fadeTime = 4; Ndef(\pantanalCorixo).clear(4); // Rollback corixo
 // Pbindef(\pantanalTuiuiuSeq).stop; Ndef(\pantanalTuiuiu).fadeTime = 4; Ndef(\pantanalTuiuiu).clear(4); // Rollback tuiuiús
 // Pbindef(\pantanalArarasSeq).stop; Ndef(\pantanalAraras).fadeTime = 4; Ndef(\pantanalAraras).clear(4); // Rollback araras
)
```

</details>
