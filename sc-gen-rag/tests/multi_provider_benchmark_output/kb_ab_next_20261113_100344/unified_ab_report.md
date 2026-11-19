# Unified Quantitative & Qualitative KB A/B Benchmark Report
**Generated**: 2026-11-13 13:49:16 UTC
**Schedule**: 4 rounds per arm (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`) × 2 arms (`No KB` vs `With KB`) × 4 models = 32 rounds
**Blind Qualitative Judge**: `anthropic/claude-opus-5.5`

## 1. Unified Executive Leaderboard: Without KB vs. With KB

| Model | 1st-Pass (No→KB) | Fixes (No→KB) | Mean LLM (No→KB) | Cost (No→KB) | Qual Overall (No→KB / Δ) | Portfolio Var (No→KB) | Unique UGens (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 75% → 50% | 2 → 1 | 54.0s → 68.7s | $0.3353 → $0.2293 | **5.71 → 5.37** (-0.34) | 4.5 → 4.5 | 20 → 20 |
| **Claude Sonnet 5.5** | 100% → 75% | 0 → 0 | 18.7s → 44.6s | $0.2195 → $0.2105 | **5.15 → 4.67** (-0.48) | 4.0 → 4.0 | 16 → 16 |
| **DeepSeek V4 Pro** | 50% → 25% | 3 → 1 | 66.8s → 105.6s | $0.1056 → $0.0492 | **4.11 → 3.00** (-1.11) | 3.8 → 2.5 | 15 → 14 |
| **OpenAI GPT-6.1 Sol** | 100% → 75% | 0 → 2 | 31.4s → 30.0s | $0.1544 → $0.2885 | **6.12 → 6.39** (+0.27) | 4.5 → 4.5 | 16 → 16 |

## 2. Qualitative Dimensions Breakdown (No KB → With KB / Δ)

| Model | Variety | Technical Depth | Compositional Audacity | Prompt Coherence | Compositional Arcs | Creativity | Mean LOC |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 6.00→5.62 (-0.38) | 5.88→5.12 (-0.76) | 5.00→4.88 (-0.12) | 6.62→6.25 (-0.37) | 4.88→4.62 (-0.26) | 5.88→5.75 (-0.13) | 138→121 |
| **Claude Sonnet 5.5** | 5.75→4.88 (-0.87) | 5.75→4.62 (-1.13) | 4.38→4.00 (-0.38) | 6.00→5.50 (-0.50) | 3.88→4.12 (+0.24) | 5.12→4.88 (-0.24) | 121→72 |
| **DeepSeek V4 Pro** | 4.00→3.00 (-1.00) | 4.88→3.00 (-1.88) | 3.38→2.62 (-0.76) | 5.00→3.50 (-1.50) | 3.50→2.75 (-0.75) | 3.88→3.12 (-0.76) | 84→52 |
| **OpenAI GPT-6.1 Sol** | 5.88→6.00 (+0.12) | 6.88→7.00 (+0.12) | 5.12→5.50 (+0.38) | 7.12→7.50 (+0.38) | 5.25→5.62 (+0.37) | 6.50→6.75 (+0.25) | 143→140 |

## 3. Quantitative Efficiency & Token Impact (No KB → With KB)

| Model | Arm | 1st-Pass | Final Pass | Fix Calls | Mean LLM | Total Wall | In Tokens | Out Tokens | Total Cost |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | No KB | 75.0% (3/4) | 75.0% (3/4) | 2 | 54.02s | 432.6s | 37,163 | 26,098 | $0.33531 |
| **Gemini 4 Carbon** | With KB | 50.0% (2/4) | 100.0% (4/4) | 1 | 68.75s | 449.8s | 48,299 | 13,267 | $0.22927 |
| **Claude Sonnet 5.5** | No KB | 100.0% (4/4) | 100.0% (4/4) | 0 | 18.69s | 81.6s | 43,026 | 13,342 | $0.21947 |
| **Claude Sonnet 5.5** | With KB | 75.0% (3/4) | 100.0% (4/4) | 0 | 44.62s | 243.7s | 64,949 | 8,065 | $0.21054 |
| **DeepSeek V4 Pro** | No KB | 50.0% (2/4) | 75.0% (3/4) | 3 | 66.80s | 456.9s | 44,510 | 43,705 | $0.10561 |
| **DeepSeek V4 Pro** | With KB | 25.0% (1/4) | 100.0% (4/4) | 1 | 105.58s | 534.8s | 31,993 | 13,582 | $0.04917 |
| **OpenAI GPT-6.1 Sol** | No KB | 100.0% (4/4) | 100.0% (4/4) | 0 | 31.36s | 126.5s | 26,332 | 10,169 | $0.15436 |
| **OpenAI GPT-6.1 Sol** | With KB | 75.0% (3/4) | 100.0% (4/4) | 2 | 30.04s | 180.4s | 63,074 | 16,240 | $0.28854 |

## 4. By-Mode Impact (`APPEND`, `COMPOSE`, `DESIGN`, `GENERATE`)

### Mode: `APPEND`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 100%→0% | 30.9s→34.4s | **6.75→6.67** (-0.08) | 7.0→7.0 | 7.0→6.5 | 6.0→6.0 | 8.0→8.0 | 5.0→5.0 | 7.5→7.5 |
| **Claude Sonnet 5.5** | 100%→100% | 10.1s→24.6s | **4.33→5.50** (+1.17) | 5.0→6.0 | 5.5→5.5 | 3.5→4.5 | 5.0→6.5 | 2.5→4.5 | 4.5→6.0 |
| **DeepSeek V4 Pro** | 100%→100% | 71.3s→82.6s | **3.92→4.17** (+0.25) | 3.5→4.5 | 5.0→5.0 | 3.0→3.5 | 5.0→5.0 | 2.5→2.5 | 4.5→4.5 |
| **OpenAI GPT-6.1 Sol** | 100%→100% | 16.7s→18.9s | **5.33→6.83** (+1.50) | 4.5→5.5 | 6.0→7.0 | 4.5→6.0 | 6.5→8.0 | 4.5→7.0 | 6.0→7.5 |

### Mode: `COMPOSE`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 100%→100% | 58.3s→76.3s | **7.33→7.42** (+0.09) | 7.0→7.5 | 6.5→6.5 | 6.5→6.5 | 8.5→8.5 | 8.0→8.0 | 7.5→7.5 |
| **Claude Sonnet 5.5** | 100%→100% | 16.8s→18.6s | **5.83→6.83** (+1.00) | 6.0→6.5 | 5.5→6.0 | 5.0→6.0 | 6.5→8.0 | 6.5→7.5 | 5.5→7.0 |
| **DeepSeek V4 Pro** | 100%→0% | 55.5s→99.8s | **5.33→5.83** (+0.50) | 4.5→5.5 | 5.0→5.0 | 4.5→5.0 | 6.5→7.0 | 6.5→6.5 | 5.0→6.0 |
| **OpenAI GPT-6.1 Sol** | 100%→100% | 36.9s→34.5s | **7.58→7.42** (-0.16) | 7.0→7.0 | 7.0→7.0 | 6.5→6.5 | 8.5→8.5 | 8.5→8.0 | 8.0→7.5 |

### Mode: `DESIGN`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 0%→0% | 85.6s→120.0s | **2.58→1.00** (-1.58) | 3.0→1.0 | 4.0→1.0 | 2.0→1.0 | 2.5→1.0 | 2.0→1.0 | 2.0→1.0 |
| **Claude Sonnet 5.5** | 100%→0% | 33.5s→120.0s | **5.17→1.00** (-4.17) | 6.0→1.0 | 6.0→1.0 | 4.5→1.0 | 6.0→1.0 | 3.0→1.0 | 5.5→1.0 |
| **DeepSeek V4 Pro** | 0%→0% | 93.9s→120.0s | **2.83→1.00** (-1.83) | 3.0→1.0 | 4.0→1.0 | 2.5→1.0 | 3.0→1.0 | 2.5→1.0 | 2.0→1.0 |
| **OpenAI GPT-6.1 Sol** | 100%→0% | 39.7s→33.7s | **5.42→5.25** (-0.17) | 5.5→5.0 | 7.5→7.0 | 4.5→4.5 | 6.0→6.0 | 3.5→3.5 | 5.5→5.5 |

### Mode: `GENERATE`
| Model | 1st-Pass (No→KB) | LLM Time (No→KB) | Qual Overall (No→KB / Δ) | Var (No→KB) | Tech (No→KB) | Aud (No→KB) | Coh (No→KB) | Arc (No→KB) | Cre (No→KB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Gemini 4 Carbon** | 100%→100% | 41.2s→44.3s | **6.17→6.42** (+0.25) | 7.0→7.0 | 6.0→6.5 | 5.5→6.0 | 7.5→7.5 | 4.5→4.5 | 6.5→7.0 |
| **Claude Sonnet 5.5** | 100%→100% | 14.4s→15.3s | **5.25→5.33** (+0.08) | 6.0→6.0 | 6.0→6.0 | 4.5→4.5 | 6.5→6.5 | 3.5→3.5 | 5.0→5.5 |
| **DeepSeek V4 Pro** | 0%→0% | 46.5s→120.0s | **4.33→1.00** (-3.33) | 5.0→1.0 | 5.5→1.0 | 3.5→1.0 | 5.5→1.0 | 2.5→1.0 | 4.0→1.0 |
| **OpenAI GPT-6.1 Sol** | 100%→100% | 32.1s→33.0s | **6.17→6.08** (-0.09) | 6.5→6.5 | 7.0→7.0 | 5.0→5.0 | 7.5→7.5 | 4.5→4.0 | 6.5→6.5 |

## 5. Per-Model Artistic Signatures (No KB vs. With KB)

### Gemini 4 Carbon
- **Without KB**: A texture-first, foley-minded model that favours noise-excited resonators (DynKlank, Ringz, BPF-filtered Pink/White noise) to render tactile, material imagery like paper, gears and tin cans. Its pieces sit in Ndef/Pbindef loop ecosystems with little long-form dramaturgy.
- **With KB**: A noise-and-resonator texturalist that favors filtered noise, Dust-excited DynKlank modal bodies, and subtractive Saw/RLPF voices, often with witty conceptual programmatic hooks such as map-folding creases and tin-can pellets. Its work is organized as Ndef/Pbindef live-coding loops rather than shaped compositions.

### Claude Sonnet 5.5
- **Without KB**: A noise-and-resonator modeler that favors excited physical-modeling textures (DynKlank, Ringz, filtered noise bursts) to evoke concrete objects like glass, clockwork and tin rattles, delivered in competent but formally static Ndef/Pbindef loops.
- **With KB**: A resonator-centric noise sculptor that favors filtered noise excitations fed through DynKlank and Ringz banks to evoke glassy, metallic, or ritual-percussive timbres, organized via Ndef/Pbindef loops rather than through-composed form. When it lands, it shows a sensitivity to texture and polyrhythmic drift, but its structural thinking is static and its output is erratic.

### DeepSeek V4 Pro
- **Without KB**: A pragmatic live-coding sketcher that favors Ndef/Pbindef scaffolding around filtered noise, sine tones and DynKlank resonators. Its textures are percussive and granular-leaning, but it treats the prompt's poetic imagery as a loose label rather than a structural or timbral blueprint.
- **With KB**: When it engages, this model leans toward resonator-based textures (Ringz, DynKlank) and spread-based swarm ideas built in an Ndef/Pbindef live-coding style. Half its rounds collapse into a lone SinOsc fallback, so its personality is inconsistent and mostly undeveloped.

### OpenAI GPT-6.1 Sol
- **Without KB**: A noise-and-resonator texturalist who favors filtered Pink/White noise, Ringz and DynKlank percussion clusters, and phase-drifting impulse swarms to evoke mechanical or obsessive programmatic imagery. Conceptual metaphors tend to be sharper than the formal architecture built to carry them.
- **With KB**: A texture-and-gesture composer drawn to noise-band filtering, resonant modal banks (DynKlank/Ringz) and conceptually precise events, such as counted strikes and phasing impulse swarms. It favors concept-driven micro-structures over broad timbral exploration.
