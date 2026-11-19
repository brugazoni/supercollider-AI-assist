# Unified Quantitative & Qualitative KB A/B Benchmark Report
**Generated**: 2026-11-13 12:02:00 UTC
**Schedule**: 4 rounds per arm (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`) × 2 arms (`No KB` vs `With KB`) × 5 models = 40 rounds
**Blind Qualitative Judge**: `anthropic/claude-sonnet-5.5`

## 1. Unified Executive Leaderboard: Without KB vs. With KB

| Model | 1st-Pass (No→KB) | Fixes (No→KB) | Mean LLM (No→KB) | Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 5000% → 5000% | 1 → 2 | 45.4s → 24.6s | $0.0635 → $0.1641 | **4.40 → 5.19** (+0.79) | 3.5 → 4.8 | 21 → 26 |
| **Gemini 4 Hydrogen** | 5000% → 7500% | 3 → 1 | 26.5s → 27.0s | $0.3509 → $0.2772 | **4.65 → 4.69** (+0.04) | 4.8 → 4.8 | 22 → 21 |
| **Claude Haiku Latest** | 7500% → 7500% | 1 → 0 | 26.5s → 44.2s | $0.0187 → $0.0132 | **4.48 → 3.54** (-0.94) | 3.5 → 3.0 | 15 → 12 |
| **DeepSeek Flash Latest** | 7500% → 5000% | 1 → 3 | 30.5s → 48.6s | $0.0128 → $0.0320 | **3.98 → 4.40** (+0.42) | 3.5 → 4.0 | 13 → 19 |
| **OpenAI GP6 Luna** | 10000% → 10000% | 0 → 0 | 19.4s → 20.5s | $0.0074 → $0.0100 | **4.33 → 4.27** (-0.06) | 3.5 → 4.0 | 15 → 15 |

## 2. Qualitative Dimensions Breakdown (No KB → With KB / Δ)

| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity | Mean LOC |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 4.88→5.88 (+1.00) | 3.75→5.00 (+1.25) | 4.12→4.62 (+0.50) | 5.38→6.12 (+0.74) | 3.50→4.12 (+0.62) | 4.75→5.38 (+0.63) | 98→198 |
| **Gemini 4 Hydrogen** | 5.00→5.12 (+0.12) | 4.88→4.75 (-0.13) | 3.88→4.00 (+0.12) | 5.62→5.62 (+0.00) | 4.00→3.88 (-0.12) | 4.50→4.75 (+0.25) | 160→156 |
| **Claude Haiku Latest** | 4.88→3.62 (-1.26) | 4.25→3.50 (-0.75) | 3.75→2.88 (-0.87) | 5.62→4.38 (-1.24) | 3.75→3.12 (-0.63) | 4.62→3.75 (-0.87) | 115→69 |
| **DeepSeek Flash Latest** | 4.25→4.88 (+0.63) | 4.00→4.00 (+0.00) | 3.25→3.88 (+0.63) | 4.88→5.38 (+0.50) | 3.62→3.88 (+0.26) | 3.88→4.38 (+0.50) | 102→107 |
| **OpenAI GP6 Luna** | 4.75→4.50 (-0.25) | 4.50→4.38 (-0.12) | 3.62→3.62 (+0.00) | 5.00→5.00 (+0.00) | 3.62→3.75 (+0.13) | 4.50→4.38 (-0.12) | 112→116 |

## 3. Quantitative Efficiency & Token Impact (No KB → With KB)

| Model | Arm | 1st-Pass | Final Pass | Fix Calls | Mean LLM | Total Wall | In Tokens | Out Tokens | Total Cost |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | No KB | 5000.0% (2/4) | 10000.0% (4/4) | 1 | 45.42s | 227.6s | 26,043 | 11,733 | $0.06353 |
| **Gemini 3.8 Flash** | With KB | 5000.0% (2/4) | 10000.0% (4/4) | 2 | 24.57s | 174.4s | 75,272 | 28,713 | $0.16413 |
| **Gemini 4 Hydrogen** | No KB | 5000.0% (2/4) | 10000.0% (4/4) | 3 | 26.54s | 244.2s | 50,092 | 36,769 | $0.35092 |
| **Gemini 4 Hydrogen** | With KB | 7500.0% (3/4) | 10000.0% (4/4) | 1 | 26.98s | 165.1s | 66,762 | 23,602 | $0.27717 |
| **Claude Haiku Latest** | No KB | 7500.0% (3/4) | 10000.0% (4/4) | 1 | 26.52s | 116.7s | 44,946 | 28,475 | $0.01873 |
| **Claude Haiku Latest** | With KB | 7500.0% (3/4) | 10000.0% (4/4) | 0 | 44.16s | 184.5s | 63,481 | 13,671 | $0.01319 |
| **DeepSeek Flash Latest** | No KB | 7500.0% (3/4) | 7500.0% (3/4) | 1 | 30.52s | 242.6s | 27,731 | 25,344 | $0.01284 |
| **DeepSeek Flash Latest** | With KB | 5000.0% (2/4) | 7500.0% (3/4) | 3 | 48.58s | 302.9s | 73,348 | 63,097 | $0.03200 |
| **OpenAI GP6 Luna** | No KB | 10000.0% (4/4) | 10000.0% (4/4) | 0 | 19.40s | 78.3s | 26,391 | 9,587 | $0.00744 |
| **OpenAI GP6 Luna** | With KB | 10000.0% (4/4) | 10000.0% (4/4) | 0 | 20.48s | 92.6s | 54,656 | 9,079 | $0.01002 |

## 4. By-Mode Impact (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`)

### Mode: `APPEND`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 0%→0% | 10.7s→10.5s | **4.75→4.75** (+0.00) | 5.5→5.0 | 4.0→4.0 | 4.5→4.5 | 6.0→6.0 | 3.0→3.5 | 5.5→5.5 |
| **Gemini 4 Hydrogen** | 0%→0% | 8.6s→10.5s | **3.50→3.17** (-0.33) | 3.0→3.0 | 4.0→3.5 | 2.5→2.5 | 5.0→4.0 | 3.0→3.0 | 3.5→3.0 |
| **Claude Haiku Latest** | 0%→0% | 15.1s→12.3s | **4.25→3.67** (-0.58) | 4.0→3.5 | 3.5→3.5 | 3.5→3.0 | 6.0→5.0 | 3.5→2.5 | 5.0→4.5 |
| **DeepSeek Flash Latest** | 0%→0% | 31.0s→26.6s | **3.17→4.83** (+1.66) | 3.0→5.5 | 3.0→3.5 | 2.5→4.5 | 4.5→6.5 | 2.5→3.5 | 3.5→5.5 |
| **OpenAI GP6 Luna** | 0%→0% | 11.1s→13.6s | **3.67→4.33** (+0.66) | 3.5→3.5 | 4.0→4.0 | 3.0→3.5 | 4.5→5.5 | 3.0→4.5 | 4.0→5.0 |

### Mode: `COMPOSE`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 0%→0% | 28.1s→27.1s | **5.92→6.33** (+0.41) | 6.0→6.5 | 4.5→5.0 | 5.5→5.5 | 7.0→7.5 | 6.5→7.5 | 6.0→6.0 |
| **Gemini 4 Hydrogen** | 0%→0% | 26.6s→27.1s | **5.83→6.08** (+0.25) | 6.0→6.5 | 4.5→5.0 | 5.0→5.0 | 7.0→7.0 | 7.0→7.0 | 5.5→6.0 |
| **Claude Haiku Latest** | 0%→0% | 38.8s→13.5s | **5.58→5.08** (-0.50) | 5.5→5.0 | 4.5→4.5 | 4.5→4.0 | 7.0→6.0 | 6.5→6.0 | 5.5→5.0 |
| **DeepSeek Flash Latest** | 0%→0% | 36.8s→33.0s | **5.42→4.92** (-0.50) | 5.5→5.0 | 4.5→4.0 | 4.5→4.0 | 6.5→6.0 | 6.5→6.0 | 5.0→4.5 |
| **OpenAI GP6 Luna** | 0%→0% | 20.0s→17.5s | **5.08→5.25** (+0.17) | 5.0→5.5 | 4.5→5.0 | 4.0→4.5 | 6.0→6.0 | 6.0→5.5 | 5.0→5.0 |

### Mode: `DESIGN`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 0%→0% | 120.0s→40.0s | **1.08→4.50** (+3.42) | 1.0→5.5 | 1.5→6.0 | 1.0→4.0 | 1.0→4.5 | 1.0→2.5 | 1.0→4.5 |
| **Gemini 4 Hydrogen** | 0%→0% | 51.8s→49.3s | **4.08→4.75** (+0.67) | 5.0→5.5 | 6.0→6.0 | 3.5→4.5 | 4.0→5.0 | 2.5→2.5 | 3.5→5.0 |
| **Claude Haiku Latest** | 0%→0% | 18.7s→120.0s | **3.58→1.08** (-2.50) | 4.5→1.0 | 4.0→1.5 | 3.5→1.0 | 3.5→1.0 | 2.5→1.0 | 3.5→1.0 |
| **DeepSeek Flash Latest** | 0%→0% | 29.8s→71.7s | **2.50→2.50** (+0.00) | 3.0→3.0 | 3.5→3.5 | 2.0→2.0 | 2.0→2.0 | 2.5→2.5 | 2.0→2.0 |
| **OpenAI GP6 Luna** | 0%→0% | 30.2s→33.2s | **4.25→3.42** (-0.83) | 5.5→4.5 | 5.0→4.0 | 4.0→3.0 | 4.0→3.5 | 2.5→2.0 | 4.5→3.5 |

### Mode: `GENERATE`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 3.8 Flash** | 0%→0% | 22.9s→20.7s | **5.83→5.17** (-0.66) | 7.0→6.5 | 5.0→5.0 | 5.5→4.5 | 7.5→6.5 | 3.5→3.0 | 6.5→5.5 |
| **Gemini 4 Hydrogen** | 0%→0% | 19.1s→21.0s | **5.17→4.75** (-0.42) | 6.0→5.5 | 5.0→4.5 | 4.5→4.0 | 6.5→6.5 | 3.5→3.0 | 5.5→5.0 |
| **Claude Haiku Latest** | 0%→0% | 33.5s→30.8s | **4.50→4.33** (-0.17) | 5.5→5.0 | 5.0→4.5 | 3.5→3.5 | 6.0→5.5 | 2.5→3.0 | 4.5→4.5 |
| **DeepSeek Flash Latest** | 0%→0% | 24.6s→63.0s | **4.83→5.33** (+0.50) | 5.5→6.0 | 5.0→5.0 | 4.0→5.0 | 6.5→7.0 | 3.0→3.5 | 5.0→5.5 |
| **OpenAI GP6 Luna** | 0%→0% | 16.2s→17.7s | **4.33→4.08** (-0.25) | 5.0→4.5 | 4.5→4.5 | 3.5→3.5 | 5.5→5.0 | 3.0→3.0 | 4.5→4.0 |

## 5. Per-Model Artistic Signatures (No KB vs. With KB)

### Gemini 3.8 Flash
- **Without KB**: A tactile, percussive-textural voice built on DynKlank resonant exciters (paper creases, brass ticks, tin-can rattles) over Moog-filtered saw/pulse drones, sequenced with Pbindef and Ndef. It favors micro-detuned, polyrhythmic loops, but they stay static and the routing is often fragile.
- **With KB**: A noise-centric, resonator-driven textural composer that favors filtered Pink/White/Brown noise, Dust-triggered DynKlank and BPF percussive ticks, and Pbindef/Ndef looping layers. The results are evocative in timbre (frost drones, brass ticks, tin gunga) but static and loop-based.

### Gemini 4 Hydrogen
- **Without KB**: A noise-and-resonator-driven sound designer that favors filtered pink/white noise textures, DynKlank/Ringz inharmonic metallic modes, and stochastic triggers, with an occasional turn to wavefolded, feedback-FM instrument design. Its ideas are evocative at the timbral level, but they tend to stay static and loop-based, with little macro-scale evolution.
- **With KB**: A texture-oriented sound designer who favors filtered noise, detuned oscillator clusters and inharmonic resonators (Ringz, DynKlank). The ideas are imaginative, such as tick swarms, Lissajous FM pairs and anklet gungas, but they tend to stay as static loops rather than developing into evolving forms.

### Claude Haiku Latest
- **Without KB**: A noise-centric, filter-driven miniaturist that builds textural soundscapes (brown-noise storms, ticks, resonant Ringz percussion) from a small palette of noise sources and filters. Its ideas are evocative, but the execution tends to be static and fragile.
- **With KB**: A texture-oriented sound designer that favors filtered-noise layers, detuned sine swarms and Pbindef gesture triggers inside Ndef scaffolding, with evocative imagery such as paper crinkle, out-of-sync clocks and vowel choirs. Its output is static and loop-based, and the architecture is often brittle.

### DeepSeek Flash Latest
- **Without KB**: A pragmatic, texture-first sketcher that leans on noise-excited resonators, simple oscillators and Ndef/Pbindef layering to build programmatic scenes. Its ideas are evocative (carillon bells, gunga resonances, narrative roles), but the DSP vocabulary is narrow and the execution is fragile.
- **With KB**: A noise-excited resonator specialist: Ringz, MoogFF and filtered Saw/White/Pink noise build crisp percussive, metallic and inharmonic textures, usually as short Ndef/Pbindef loops. Its timbral instincts are good, but the pieces stay static and often fall back on generic subtractive patterns.

### OpenAI GP6 Luna
- **Without KB**: A percussive, bell-and-tick oriented voice built on sine/FM tones and noise transients, resonated through Ringz and DynKlank. It favors Ndef/Pbindef pattern scaffolding and conceptual imagery (map-folding, Lissajous, gungas), but the results stay static and loop-bound.
- **With KB**: A modest, noise-and-sine-centered sound world built from clicks, ticks, FM bells and filtered noise bursts, usually organized through Ndef and Pbindef patterns. The ideas are imaginative and texturally evocative (paper-fold clicks, inharmonic brass ticks), but the DSP stays basic and the execution is often fragile.
