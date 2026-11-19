# Multi-Provider X-Append Lean Benchmark Report
**Execution Date**: 2026-11-12 00:44:35 UTC
**Rounds per Model**: 1 rounds across 4 modes (append, compose, design, generate)
**Corpus Source**: 200-fragment pt-BR corpus (Wikipedia, Poema, Conto/Crônica, Descrição)
**Providers**: OpenRouter (`google/gemini-3.8-flash`, `anthropic/claude-haiku-5.5`, `deepseek/deepseek-v4.1-flash`, `openai/gpt-6-luna`)

## 1. Executive Summary & Leaderboard

| Provider / Model | 1st-Pass Pass Rate | Final Pass Rate | Auto-Fix Used | Mean LLM Time | Mean Round Wall | Total Cost (USD) | Total Tokens | Mean Chars |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 100.0% (1/1) | 100.0% (1/1) | 0 | 14.78s | 20.31s | $0.01074 | 8,251 | 3176 |
| **Claude Haiku Latest** | 100.0% (1/1) | 100.0% (1/1) | 0 | 8.68s | 8.73s | $0.00193 | 12,080 | 897 |
| **DeepSeek Flash Latest** | 100.0% (1/1) | 100.0% (1/1) | 0 | 6.80s | 6.87s | $0.00349 | 8,804 | 2529 |
| **OpenAI GP6 Luna** | 100.0% (1/1) | 100.0% (1/1) | 0 | 14.06s | 14.12s | $0.00154 | 7,827 | 2590 |

---

## 2. Technical Efficiency & Cost Breakdown

| Model | Total Wall Time | In Tokens | Out Tokens | Cost / 10 Rounds | Chars / Sec (Gen) |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 20.3s | 6,734 | 1,517 | $0.01074 | 214.9 c/s |
| **Claude Haiku Latest** | 8.7s | 10,278 | 1,802 | $0.00193 | 103.3 c/s |
| **DeepSeek Flash Latest** | 6.9s | 6,574 | 2,230 | $0.00349 | 371.9 c/s |
| **OpenAI GP6 Luna** | 14.1s | 6,329 | 1,498 | $0.00154 | 184.2 c/s |

---

## 3. Round-by-Round Comparative Matrix

| Rnd | Mode | Prompt Fragment | Gemini 3.8 Flash | Claude Haiku Latest | DeepSeek Flash Latest | OpenAI GP6 Luna |
|:---:|:---:|:---| :---: | :---: | :---: | :---: |
| 01 | `APPEND` | #149 (Luis Fernando Verissimo — Comé) | ✅ 14.8s | ✅ 8.7s | ✅ 6.8s | ✅ 14.1s |

---

## 4. Model Details & Full Generated Code

### Model: Gemini 3.8 Flash (`openrouter:google/gemini-3.8-flash`)

- **Initial Pass Rate**: 100.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 20.31s (mean LLM: 14.78s/round)
- **Total Tokens**: 8,251 (Cost: $0.01074)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261111_214344\session_gemini-3.8-flash.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: wrapped Balance2.ar(sig[0], sig[1]) in isKindOf(Collection) guard with Pan2 fallback

```supercollider
(
// ADD_INSTRUMENT: \mapFold - Dry, precise, repetitive paper-folding clicks and rustles
Ndef(\mapFold, { |amp=0.25, pan=0, t_trig=0, foldFreq=3200, res=0.15, rel=0.04|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(0.001, rel, 1, -6), trig);
    var click = WhiteNoise.ar * env;
    var paper = BPF.ar(click, foldFreq, res) * 12.0;
    var body = Ringz.ar(click * 0.2, [foldFreq * 0.5, foldFreq * 1.2], 0.02).sum;
    var sig = (paper + body).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.125, 0.125, 0.5], inf),
    \t_trig, 1,
    \foldFreq, Pseq([2800, 3400, 4200, 2600, 4800, 3100], inf),
    \rel, Pwhite(0.02, 0.06, inf),
    \pan, Pseq([-0.3, 0.3, -0.1, 0.2], inf),
    \amp, Pseq([0.18, 0.22, 0.28, 0.15], inf)
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// ADD_INSTRUMENT: \antarcticSilence - Tension-heavy sub-harmonic drone & icy glacial air
Ndef(\antarcticSilence, { |amp=0.35, pan=0, t_trig=0, fund=46.25, windCutoff=800, rumble=0.4|
    var trig = K2A.ar(t_trig);
    var sub = SinOsc.ar(fund) * 0.7 + SinOsc.ar(fund * 2) * 0.3;
    var subSaturated = (sub * 2.5).tanh * rumble;
    var coldAir = BPF.ar(PinkNoise.ar, SinOsc.kr(0.08).range(400, windCutoff), 0.15) * 8.0;
    var frost = HPF.ar(Dust2.ar(8) * 0.2, 5000);
    var sig = Splay.ar([subSaturated + frost, coldAir]);
    if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

Pbindef(\antarcticSilenceSeq,
    \dur, Pseq([4.0, 6.0, 8.0], inf),
    \t_trig, 1,
    \fund, Pseq([46.25, 43.65, 41.2], inf), // Sub Bb0, A0, Ab0
    \windCutoff, Pseq([600, 950, 750, 1200], inf),
    \rumble, Pseq([0.35, 0.5, 0.6], inf),
    \pan, Pseq([0, 0.1, -0.1], inf),
    \amp, 0.32
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\antarcticSilenceSeq);

// ADD_INSTRUMENT: \suspendedWine - Suspended crystalline glass friction/resonance held in mid-air
Ndef(\suspendedWine, { |amp=0.18, pan=0, t_trig=0, freq=880, atk=1.5, rel=3.0|
    var trig = K2A.ar(t_trig);
    var env = EnvGen.ar(Env.perc(atk, rel, 1, 2), trig);
    var glass = DynKlank.ar(
        `[
            [freq, freq * 2.12, freq * 3.42, freq * 4.78],
            [0.5, 0.25, 0.15, 0.08],
            [2.5, 2.0, 1.5, 1.2]
        ],
        BPF.ar(WhiteNoise.ar, freq * 1.5, 0.05) * 0.05
    );
    var tone = SinOsc.ar(freq * [0.999, 1.001]).sum * 0.2;
    var sig = Pan2.ar((glass + tone) * env * amp, pan);
    sig;
}).play;

Pbindef(\suspendedWineSeq,
    \dur, Pseq([3.0, 5.0, 4.0], inf),
    \t_trig, 1,
    \freq, Pseq([1174.66, 1108.73, 1046.5], inf), // D6, C#6, C6 descending tension
    \atk, Pseq([1.0, 1.8, 0.8], inf),
    \rel, Pseq([3.0, 4.5, 3.5], inf),
    \pan, Pseq([0.4, -0.4, 0.2], inf),
    \amp, 0.16
);

Ndef(\suspendedWine)[1] = \set -> Pbindef(\suspendedWineSeq);

// Rollback:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2);
// Pbindef(\antarcticSilenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2);
// Pbindef(\suspendedWineSeq).stop; Ndef(\suspendedWine).fadeTime = 2; Ndef(\suspendedWine).clear(2);
)
```

</details>

### Model: Claude Haiku Latest (`openrouter:anthropic/claude-haiku-5.5`)

- **Initial Pass Rate**: 100.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 8.73s (mean LLM: 8.68s/round)
- **Total Tokens**: 12,080 (Cost: $0.00193)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261111_214344\session_claude-haiku-5.5.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// ADD_INSTRUMENT: "Antarctic tension" - a sustained low wind drone (the silence before the storm) with sparse tapped ticks that accumulate as the argument builds
Ndef(\storm, { |amp=0.2, cutoff=400, swell=0.05, t_trig=0, pan=0|
    var swellLFO, wind, tap, sig;
    swellLFO = SinOsc.kr(swell).range(0.3, 1);
    wind = LPF.ar(PinkNoise.ar(0.6), cutoff * swellLFO);
    tap = Ringz.ar(Decay2.ar(K2A.ar(t_trig), 0.002, 0.03) * WhiteNoise.ar(0.8), 1800, 0.4) * 0.4;
    sig = (wind + tap) * amp;
    Pan2.ar(sig, pan);
}).play;

Pbindef(\stormPulse,
    \dur, Pseq([3, 3, 2, 1, 0.5, 0.25, 0.25], inf),
    \t_trig, 1,
    \amp, Pwhite(0.12, 0.25, inf),
    \cutoff, Pwhite(250.0, 600.0, inf),
    \pan, Pwhite(-0.3, 0.3, inf)
);

Ndef(\storm)[1] = \set -> Pbindef(\stormPulse);
)

// Pbindef(\stormPulse).stop; Ndef(\storm).fadeTime = 2; Ndef(\storm).clear(2); // Rollback: remove this instrument
```

</details>

### Model: DeepSeek Flash Latest (`openrouter:deepseek/deepseek-v4.1-flash`)

- **Initial Pass Rate**: 100.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 6.87s (mean LLM: 6.80s/round)
- **Total Tokens**: 8,804 (Cost: $0.00349)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261111_214344\session_deepseek-flash-v4.1.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
// ============================================================
// Opening: The Dinner Table Before the Storm
// 27 years of silence, a suspended wine bottle, Antarctic pressure
// ============================================================

// --- Deep drone: twenty-seven years of unspoken weight ---
Ndef(\marriageDrone, {
    var freq = 42;
    var base = SinOsc.ar(freq) * 0.5 + SinOsc.ar(freq * 2) * 0.3;
    var shimmer = Saw.ar(freq * 3) * 0.06;
    var mod = LFNoise2.kr(0.05).range(0.9, 1.1);
    var sig = (base + shimmer) * mod;
    var filt = MoogFF.ar(sig, 180 + LFNoise1.kr(0.08).range(0, 320), 2.6);
    filt = (filt * 1.6).tanh;
    Pan2.ar(filt * 0.35, 0);
}).play;
// Pbindef(\marriageDroneSeq).stop; Ndef(\marriageDrone).fadeTime = 2; Ndef(\marriageDrone).clear(2); // Rollback

// --- Frozen waiter: the bottle suspended, held breath ---
Ndef(\frozenWaiter, {
    var freqs = [880, 1320, 1760, 2640];
    var sig = freqs.collect({ |f, i|
        SinOsc.ar(f * LFNoise2.kr(0.1).range(0.995, 1.005), 0, 1/(i + 2))
    }).sum;
    var susp = SinOsc.kr(0.07).range(0.45, 1.0);
    var breath = LFNoise1.kr(0.25).range(0.6, 1.0);
    Pan2.ar(sig * susp * breath * 0.13, LFNoise1.kr(0.1).range(-0.35, 0.35));
}).play;
// Pbindef(\frozenWaiterSeq).stop; Ndef(\frozenWaiter).fadeTime = 2; Ndef(\frozenWaiter).clear(2); // Rollback

// --- Map folder: dry, careful, exact percussion (the explanation) ---
Ndef(\mapFold, { |t_trig=0, amp=0.4, pan=0, freq=1200|
    var env = EnvGen.ar(Env.perc(0.001, 0.09, 1, -4), K2A.ar(t_trig));
    var noise = BPF.ar(WhiteNoise.ar, freq, 0.14) * 13;
    var body = SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.001, 0.05));
    Pan2.ar((noise + (body * 0.3)) * env * amp, pan);
}).play;
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback

// --- Effect: heavy Antarctic reverb-space on the drone (low wetness, awaiting storm) ---
Ndef(\marriageDrone)[10] = \filter -> { |in|
    var sig = in;
    sig + (CombC.ar(sig, 2.5, 1.73, 6.0) * 0.35) + (CombC.ar(sig, 2.5, 2.31, 5.0) * 0.28);
};
Ndef(\marriageDrone).set(\wet10, 0.28);
// Ndef(\marriageDrone).set(\wet10, 0); // Rollback: disable this effect

// --- Sequence: the folding explanation, dry and irregular ---
Pbindef(\mapFoldSeq,
    \dur, Pseq([0.25, 0.125, 0.5, 0.375, 0.125, 0.25, 0.75, 0.125], inf),
    \t_trig, 1,
    \amp, Pwhite(0.15, 0.45, inf),
    \freq, Pwhite(800, 2400, inf),
    \pan, Pwhite(-0.7, 0.7, inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);
)
```

</details>

### Model: OpenAI GP6 Luna (`openrouter:openai/gpt-6-luna`)

- **Initial Pass Rate**: 100.0%
- **Final Pass Rate**: 100.0%
- **Total Time**: 14.12s (mean LLM: 14.06s/round)
- **Total Tokens**: 7,827 (Cost: $0.00154)
- **Executable SuperCollider File**: `C:\Users\Bruno Gazoni\Desktop\supercollider-project\supercollider-AI-assist\sc-gen-rag\tests\multi_provider_benchmark_output\run_20261111_214344\session_gpt-6-luna.scd`

#### Round Code Dumps:

<details>
<summary><strong>Round 01 [APPEND] - Status: PASS</strong> — <em>O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão p...</em></summary>

- **Prompt**: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, até a noite em que ele decidiu explicar detalhadamente na mesa do restaurante como se dobrava corretamente um mapa rodoviário. O garçom permaneceu imóvel com a garrafa de vinho suspensa no ar enquanto o silêncio entre os dois adquiriu o peso de uma tempestade antártica prestes a desabar.
- **Initial Valid**: True
- **Final Valid**: True
- **Validator Fixes**: None

```supercollider
(
Ndef(\mapFold, { |freq=180, amp=0.12, pan=(-0.25), t_trig=0, brightness=1800|
    var env = EnvGen.kr(Env.perc(0.002, 0.16, 1, -7), t_trig);
    var click = BPF.ar(WhiteNoise.ar, brightness, 0.22) * 5;
    var crease = SinOsc.ar(freq * [1, 2.01]).sum * 0.18;
    Pan2.ar((click + crease) * env * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 1, 0.5, 0.5, 1.5], inf),
    \freq, Pseq([196, 196, 220, 196, 174.61, 196, 164.81], inf),
    \brightness, Pseq([900, 2600, 1400, 4200, 1100, 3200, 700], inf),
    \t_trig, 1,
    \amp, Pseq([0.11, 0.07, 0.09, 0.045, 0.1, 0.06, 0.035], inf),
    \pan, Pseq([-0.3, -0.2, -0.1, 0, -0.25, -0.15, 0.1], inf)
);
Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove this instrument

Ndef(\stormSilence, { |freq=55, amp=0.11, pan=0, t_trig=0, cutoff=240|
    var env = EnvGen.kr(Env.perc(0.08, 8, 1, -4), t_trig);
    var slow = SinOsc.kr(0.035).range(0.75, 1.15);
    var sub = SinOsc.ar(freq) * 0.55;
    var overtone = SinOsc.ar(freq * 2.01) * 0.24;
    var coldAir = LPF.ar(WhiteNoise.ar, cutoff) * 0.018;
    Pan2.ar((sub + overtone + coldAir) * env * slow * amp, pan);
}).play;

Pbindef(\stormSilenceSeq,
    \dur, Pseq([4, 3, 5, 2, 6], inf),
    \freq, Pseq([55, 58.27, 55, 51.91, 55], inf),
    \cutoff, Pseq([180, 320, 210, 450, 150], inf),
    \t_trig, 1,
    \amp, Pseq([0.12, 0.085, 0.11, 0.075, 0.13], inf),
    \pan, Pseq([-0.05, 0.04, 0, 0.08, -0.04], inf)
);
Ndef(\stormSilence)[1] = \set -> Pbindef(\stormSilenceSeq);

// Pbindef(\stormSilenceSeq).stop; Ndef(\stormSilence).fadeTime = 2; Ndef(\stormSilence).clear(2); // Rollback: remove this instrument

Ndef(\suspendedWine, { |freq=880, amp=0.035, pan=0.55, t_trig=0, tone=5300|
    var env = EnvGen.kr(Env.perc(0.003, 2.8, 1, -5), t_trig);
    var ping = SinOsc.ar(freq) + (SinOsc.ar(freq * 2.76) * 0.28) + (SinOsc.ar(freq * 4.13) * 0.12);
    var shimmer = BPF.ar(WhiteNoise.ar, tone, 0.035) * 1.4;
    Pan2.ar((ping * 0.16 + shimmer * 0.025) * env * amp, pan);
}).play;

Pbindef(\suspendedWineSeq,
    \dur, Pseq([7, 11, 9, 13], inf),
    \freq, Pseq([880, 830.61, 932.33, 880], inf),
    \tone, Pseq([4300, 6100, 4900, 7200], inf),
    \t_trig, 1,
    \amp, Pseq([0.04, 0.028, 0.035, 0.022], inf),
    \pan, Pseq([0.55, 0.62, 0.48, 0.58], inf)
);
Ndef(\suspendedWine)[1] = \set -> Pbindef(\suspendedWineSeq);

// Pbindef(\suspendedWineSeq).stop; Ndef(\suspendedWine).fadeTime = 2; Ndef(\suspendedWine).clear(2); // Rollback: remove this instrument
)
```

</details>
