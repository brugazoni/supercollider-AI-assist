# Qualitative & Artistic SuperCollider Evaluation Report
**Evaluated**: 2026-11-13 13:47:28 UTC
**Blind Judge**: `anthropic/claude-opus-5.5` (2-stage: per-round blind scoring + cross-round portfolio variety audit)
**Judge Cost**: 76,139 in / 7,768 out tokens (~$0.4599)

> **Note on Timeouts**: Rounds that timed out (>120s API guard) receive `0.0` in all-rounds averages; completed-only averages are also shown in parentheses where applicable.

## 1. Qualitative Leaderboard (Mean Scores / 10)

| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| #1 | **OpenAI GPT-6.1 Sol** | **6.12** | 4.5 | 5.88 | 6.88 | 5.12 | 7.12 | 5.25 | 6.50 | 16 | 142.8 |
| #2 | **Gemini 4 Carbon** | **5.71** | 4.5 | 6.00 | 5.88 | 5.00 | 6.62 | 4.88 | 5.88 | 20 | 138.0 |
| #3 | **Claude Sonnet 5.5** | **5.15** | 4.0 | 5.75 | 5.75 | 4.38 | 6.00 | 3.88 | 5.12 | 16 | 121.0 |
| #4 | **DeepSeek V4 Pro** | **4.11** | 3.8 | 4.00 | 4.88 | 3.38 | 5.00 | 3.50 | 3.88 | 15 | 84.2 |

## 2. Qualitative Overall Score by Mode

| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |
|:---|:---:|:---:|:---:|:---:|
| **OpenAI GPT-6.1 Sol** | 5.33 | 7.58 | 5.42 | 6.17 |
| **Gemini 4 Carbon** | 6.75 | 7.33 | 2.58 | 6.17 |
| **Claude Sonnet 5.5** | 4.33 | 5.83 | 5.17 | 5.25 |
| **DeepSeek V4 Pro** | 3.92 | 5.33 | 2.83 | 4.33 |

## 3. Artistic Profiles, DSP Signatures & Blind Spots

### OpenAI GPT-6.1 Sol (`openrouter:openai/gpt-6.1-sol`)
- **Artistic Signature**: A noise-and-resonator texturalist who favors filtered Pink/White noise, Ringz and DynKlank percussion clusters, and phase-drifting impulse swarms to evoke mechanical or obsessive programmatic imagery. Conceptual metaphors tend to be sharper than the formal architecture built to carry them.
- **Unique UGens Used (16)**: `SinOsc` (4), `BPF` (3), `HPF` (3), `PinkNoise` (3), `WhiteNoise` (3), `LPF` (2), `Ringz` (2), `LFNoise2` (1), `DynKlank` (1), `Ndef` (1), `RLPF` (1), `VarSaw` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Evocative concept-to-DSP mapping, e.g. accelerating BPF clicks for map-folding, dephased impulse swarms for gears, and a 1.501 FM ratio for Lissajous figures
  - Effective inharmonic resonator work, with Ringz and DynKlank clusters given per-trigger TRand drift for organic variation
  - Comfortable live-coding scaffolding using Ndef, Pbindef and Tdef, plus Bus routing, that suits iterative performance
- **Blind Spots**:
  - Weak macro-form and tension arcs: the pieces repeatedly settle into static loops, rely on commented-out macros instead of automated evolution, and underscale gestures relative to the stated concept
  - Narrow synthesis palette of 16 unique UGens dominated by SinOsc and basic filters, with generic CombL/FreeVerb2 spaces and little granular, spectral or dynamics processing

### Gemini 4 Carbon (`openrouter:google/gemini-4-carbon`)
- **Artistic Signature**: A texture-first, foley-minded model that favours noise-excited resonators (DynKlank, Ringz, BPF-filtered Pink/White noise) to render tactile, material imagery like paper, gears and tin cans. Its pieces sit in Ndef/Pbindef loop ecosystems with little long-form dramaturgy.
- **Unique UGens Used (20)**: `HPF` (4), `PinkNoise` (4), `SinOsc` (4), `BPF` (3), `DynKlank` (3), `WhiteNoise` (3), `Decay2` (2), `LFNoise2` (2), `LFNoise1` (2), `Ringz` (2), `Pulse` (2), `RLPF` (2)
- **Architectural Constructs**: `Bus`×1, `MIDIdef`×1, `Ndef`×4, `Pbindef`×4, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Evocative physical-modelling-style material sounds built from noise excitation into modal resonators (DynKlank tin-can modes, Dust-grain rattles, bandpassed paper friction).
  - Inventive small-scale timbral ideas such as wavefolded click-creases and detuned FM gear beating mapped to conceptual metaphors.
  - Solid live-coding scaffolding with Ndef and Pbindef, plus robust defensive engineering like the layered MIDI source fallback chain.
- **Blind Spots**:
  - Weak macro-form. Loops stay cyclic and static, with almost no Tdef-driven arcs, climaxes or evolving sections across rounds.
  - Under pressure in design mode it collapses into a generic Saw/Pulse/RLPF subtractive patch that ignores the prompt imagery. It also shows API sloppiness (Ndef xset misuse, stray cleanup, oversized voice swarms) and a narrow UGen palette of about 20 total.

### Claude Sonnet 5.5 (`openrouter:anthropic/claude-sonnet-5.5`)
- **Artistic Signature**: A noise-and-resonator modeler that favors excited physical-modeling textures (DynKlank, Ringz, filtered noise bursts) to evoke concrete objects like glass, clockwork and tin rattles, delivered in competent but formally static Ndef/Pbindef loops.
- **Unique UGens Used (16)**: `SinOsc` (4), `WhiteNoise` (4), `BPF` (3), `HPF` (3), `LFNoise1` (3), `PinkNoise` (3), `DynKlank` (2), `LPF` (2), `Saw` (2), `Decay2` (2), `Ndef` (1), `Fold` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Convincing inharmonic resonator design: DynKlank and Ringz excited by noise bursts produce tactile, object-like timbres
  - Metaphor-driven sound design, such as a phase-offset 3:2 sine pair wavefolded as a Lissajous analogue
  - Sensible subtractive layering of multi-band BPF/HPF/LPF noise for textural realism
- **Blind Spots**:
  - Weak large-scale form: patterns loop statically, with little Tdef/Routine-driven evolution or buildup, and concepts like dephasing are approximated with randomness
  - Narrow UGen palette (16 unique) and careless mixing and spatial details, such as reverb left fully dry and XFade2 hard-panning the dry signal, plus missing requested visualization

### DeepSeek V4 Pro (`openrouter:deepseek/deepseek-v4-pro`)
- **Artistic Signature**: A pragmatic live-coding sketcher that favors Ndef/Pbindef scaffolding around filtered noise, sine tones and DynKlank resonators. Its textures are percussive and granular-leaning, but it treats the prompt's poetic imagery as a loose label rather than a structural or timbral blueprint.
- **Unique UGens Used (15)**: `SinOsc` (4), `BPF` (3), `RLPF` (2), `WhiteNoise` (2), `Decay2` (2), `DynKlank` (2), `PinkNoise` (2), `Ndef` (1), `HPF` (1), `Pulse` (1), `Saw` (1), `LFNoise2` (1)
- **Architectural Constructs**: `Bus`×1, `MIDIdef`×1, `Ndef`×4, `Pbindef`×4, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Fluent JITLib patterning: Pbindef injection into Ndef slots and detuned clock durations yield genuine phase-drift polyrhythms
  - Effective resonant-noise percussion via WhiteNoise/PinkNoise into BPF/Decay2/DynKlank, including randomized per-trigger spatialization
  - Defensive infrastructure thinking, such as tiered MIDI device detection with fallbacks
- **Blind Spots**:
  - Weak macro-form and narrative arc: static loops, promised events that never arrive, muted layers and uniform FreeVerb wash
  - Narrow, under-scaled synthesis palette (only 15 UGens across the shown rounds, a bare-sine default and small voice counts). It also fails to translate specific imagery like Lissajous figures into the DSP, and design-mode code is fragile enough to fail compilation

## 4. Round-by-Round Blind Critique

### OpenAI GPT-6.1 Sol
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **5.33** | 4.5 | 6.0 | 4.5 | 6.5 | 4.5 | 6.0 | Accelerating, rising BPF noise clicks mimic obsessive map-folding | Storm tension never builds; static loops without macro evolution |
| 02 | `COMPOSE` | **7.58** | 7.0 | 7.0 | 6.5 | 8.5 | 8.5 | 8.0 | Phase-offset Impulse swarm with drift-scaled rates creating gear dephasing | Fourteen-voice swarm undersells two hundred clocks; xset on functional Ndefs |
| 03 | `DESIGN` | **5.42** | 5.5 | 7.5 | 4.5 | 6.0 | 3.5 | 5.5 | Wavefolding XFade and ratio-1.501 FM evoking Lissajous figures | Thin timbral palette; generic CombL plus FreeVerb2 space |
| 04 | `GENERATE` | **6.17** | 6.5 | 7.0 | 5.0 | 7.5 | 4.5 | 6.5 | Inharmonic Ringz gunga clusters with per-trigger TRand drift | No automated form; static loops rely on commented macros |

- **Round 01 (`APPEND`)**: The code uses clean Ndef plus \set Pbindef routing with t_trig percussive envelopes. It also includes LeakDC on the drone, though the other layers lack it and the gain staging is cautious. Its palette is mostly SinOsc and filtered noise, but the metaphors land well: 27-based durations, near-unison detuned 'couple' voices, compressing paper-fold rhythms, and a 46 Hz sub with icy narrow-band pink noise for the suspended silence. Structurally the material is cyclic and never moves toward the impending Antarctic storm, so the dramatic tension is only implied.
- **Round 02 (`COMPOSE`)**: The code shows solid architecture: a limiter on the tail, a dedicated bus, Ndef filter slots, and contrasting Ringz, DynKlank and FM-bell voices. One weakness is that xset on these Ndefs triggers crossfades rather than smooth parameter changes. The drifting impulse swarm and the breathing band-passed noise with beating sines map the prompt's microscopic dephasing and breath of time directly. The timestamped Tdef arc moves clearly from a lone pendulum through accelerating gears to a held-breath climax and a fade-out. The palette stays fairly conventional, and FreeVerb is still in the chain.
- **Round 03 (`DESIGN`)**: The architecture is solid. It uses bus-mapped control parameters, separate groups, LeakDC plus a Limiter on the master, robust MIDI device detection, and a two-zone GUI with polling sync. The panic CC also triggers the generic CC loop harmlessly. The voices are modest: detuned VarSaw with fold2 for the cabinet, and near-harmonic sines morphing into 3:2-ish FM for the phosphor zone. The FM loosely maps Lissajous ratio figures, but the patch never exploits stereo X/Y phase relationships or rotating harmonic folding in depth. As a design-mode instrument it has no autonomous form, and the reverb/delay is cliché.
- **Round 04 (`GENERATE`)**: The code uses clean Ndef plus \set Pbindef routing on a shared TempoClock. It applies LeakDC/tanh gain staging and builds a metallic gunga model from detuned inharmonic Ringz partials with noise sizzle, which evokes the ankle-can percussion well. The drum, gunga and choir layers map closely to the terno procession. Form is mostly a static cycling loop with only manual commented gestures, and the FreeVerb-heavy, mode-centric choir stays harmonically safe.

### Gemini 4 Carbon
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **6.75** | 7.0 | 7.0 | 6.0 | 8.0 | 5.0 | 7.5 | Wavefolded click-crease with bandpassed paper friction for map folding | Cyclic Pbindef loops lack an eruption or climax arc |
| 02 | `COMPOSE` | **7.33** | 7.0 | 6.5 | 6.5 | 8.5 | 8.0 | 7.5 | Detuned FM gear beating mapped to the breathing of time | Ndef xset misuse, stray prior-scene cleanup, and a 12-voice swarm |
| 03 | `DESIGN` | **2.58** | 3.0 | 4.0 | 2.0 | 2.5 | 2.0 | 2.0 | Robust MIDI source detection with layered fallback chain | Generic fallback subtractive patch ignoring Lissajous and modular imagery |
| 04 | `GENERATE` | **6.17** | 7.0 | 6.0 | 5.5 | 7.5 | 4.5 | 6.5 | DynKlank tin-can modes excited by Dust-grain gunga rattles | Static loops; no Tdef or macro arc evolution |

- **Round 01 (`APPEND`)**: The piece layers three well-separated voices: a SinOscFB microtonal cluster with descending sub-bass, a DynKlank glass resonator, and a Fold-based paper-click percussion, all patterned via \set slots with sound gain staging and LeakDC. Its mappings are evocative: the 27-beat asymmetric cycle, the frozen bottle as sustained modal shimmer, and the pedantic rhythm with tense pauses. However, the 'storm about to break' never escalates beyond cycling tension values. Minor fragilities include a redundant isKindOf branch and the t_trig plus K2A envelope pattern, though they are functional.
- **Round 02 (`COMPOSE`)**: The piece pairs three SynthDefs (Ringz escapement with FM hairspring, DynKlank inharmonic carillon, wooden Ringz pendulum) with Pbindef phase-drifting durations that convincingly render desencontrados clocks. It has a clear cue-based arc from solitary ticks through saturation to an inward-breathing resolution. Technical issues weaken it: xset on Ndefs with fadeTime causes needless crossfades, and the Splay amp argument conflicts with the swarm's own control. It also references unrelated prior-scene Ndefs and represents 200 clocks with only 12 voices. FreeVerb remains the main acoustic space.
- **Round 03 (`DESIGN`)**: This is a templated subtractive fallback: detuned Saw and Pulse into RLPF with a comb and FreeVerb tail. It does not compile, likely because the \set slot receives a Pbindef without a proper pattern proxy setup. The patch has no quadrature or phase-rotating stereo to evoke Lissajous figures, no patch-matrix cross-modulation, and no folding harmonics. It also has no Tdef-driven arc; random notes in a minor-ish scale yield a static loop.
- **Round 04 (`GENERATE`)**: The code layers three things: a pitch-swept drum with noise snare and Ringz wood click, DynKlank inharmonic tin modes with Dust grit for the gungas, and a formant SelectX choir with pulse reed. The \set slot patterns drive persistent synths cleanly, though some details are fragile: retriggering EnvGen via t_trig, Saw summing before the formant filters, and the redundant isKindOf branches. The cultural imagery maps well (caixas, gungas, rosary chant in major mode), but the form is just fixed cycles. Development is left to commented live-coding tweaks rather than a built-in processional arc.

### Claude Sonnet 5.5
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **4.33** | 5.0 | 5.5 | 3.5 | 5.0 | 2.5 | 4.5 | DynKlank inharmonic glass resonator driven by noise-burst excitation | Reverb left at wet 0; no Antarctic storm buildup |
| 02 | `COMPOSE` | **5.83** | 6.0 | 5.5 | 5.0 | 6.5 | 6.5 | 5.5 | DynKlank inharmonic brass escapement ticks driven by noise excitation | Dephasing realized as random durations, not true phase drift |
| 03 | `DESIGN` | **5.17** | 6.0 | 6.0 | 4.5 | 6.0 | 3.0 | 5.5 | Phase-offset 3:2 sine pair wavefolded as Lissajous metaphor | No scope view; reverb XFade2 hard-pans dry signal |
| 04 | `GENERATE` | **5.25** | 6.0 | 6.0 | 4.5 | 6.5 | 3.5 | 5.0 | Multi-band BPF noise plus Ringz modeling gunga tin rattles | Static looping patterns with no Tdef-driven formal evolution |

- **Round 01 (`APPEND`)**: The code is functional, using a sensible Ndef plus \set Pbindef slot architecture, a modal DynKlank glass, and band-passed noise ticks for map folding. However, the reverb is added and then muted, there is no LeakDC or gain-structure macro, and the piece is a static loop that never realizes the impending storm or the weight of silence. Mapping the suspended wine bottle to a resonant glass is a nice touch, but the restaurant drone is generic and the dramatic tension stays unexpressed.
- **Round 02 (`COMPOSE`)**: The piece pairs DynKlank modal ticks with FM carillon bells, a filtered-noise breath layer, and a slightly detuned additive hum, all sequenced in a clear five-cue Tdef arc that thins down to a lone tick. Technically it works, but it has fragile spots: xset is applied to function args on Ndefs, the FreeVerb runs at mix 1.0 under wet10, the limiter is added twice, and the Pbindef swarms rely on Pwhite jitter. The prompt's central idea, microscopic phase offsets between near-identical clocks breathing as time, is never modeled through slightly different periodic rates such as Impulse or Pbind tempos at 1.0, 1.003, and so on. That leaves the coherence evocative but generic.
- **Round 03 (`DESIGN`)**: The three zones are architecturally clean. Control buses are mapped via asMap, there are key-range splits and a mono-sub voice, and an FX/master chain ends in LeakDC and a Limiter. There are flaws, though: the zone synths output to ~fxBus while nothing reads it except the fxMaster, which is placed in the same tail position, so ordering is fine. However, the vol arg ignores bus updates, and the GUI never shows a Stethoscope or Lissajous scope despite the oscilloscope imagery. The 3:2 phase-locked sines, wavefolding and rotating phase modulation are apt metaphors for the prompt, but the instrument has no inherent temporal arc and relies entirely on the performer.
- **Round 04 (`GENERATE`)**: Solid percussion design: the pitch-enveloped sine bombo, the BPF-cluster gunga with a Ringz body, and the inharmonic FM agogo show competent synthesis, and the \set pattern slots are used idiomatically. There are flaws, though. Using t_trig inside the \set pattern is fragile, the canopy carries an odd sclang-time isKindOf branch, and the gunga's Pwrand durations break the cadenced march feel. The piece evokes the congada's metallic ankle shakers and drum procession, but it lacks any procession arc, call-and-response, Rosário devotional character, or dynamic development, so it remains a static groove.

### DeepSeek V4 Pro
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **3.92** | 3.5 | 5.0 | 3.0 | 5.0 | 2.5 | 4.5 | Pbindef injected via \set slot driving filtered-noise ticks | Husband muted at amp zero; no arc, storm never arrives |
| 02 | `COMPOSE` | **5.33** | 4.5 | 5.0 | 4.5 | 6.5 | 6.5 | 5.0 | Detuned Pbindef durations creating drifting clock phase polyrhythm | Six clocks, not two hundred; breath is bare sine |
| 03 | `DESIGN` | **2.83** | 3.0 | 4.0 | 2.5 | 3.0 | 2.5 | 2.0 | Multi-tier MIDI device detection with fallback filtering chain | Generic fallback patch ignores Lissajous imagery; fails compilation |
| 04 | `GENERATE` | **4.33** | 5.0 | 5.5 | 3.5 | 5.5 | 2.5 | 4.0 | DynKlank tin-can resonator with randomized per-trigger panning | Static loops; no form, generic FreeVerb on every layer |

- **Round 01 (`APPEND`)**: The code uses correct JITLib idioms, with \set routing and t_trig percussion, but the palette is limited to BPF noise clicks and additive sine drones, with no LeakDC and fragile gain on the 30 Hz sub. The husband/wife mapping is a reasonable metaphor, but the husband's sequence is fully muted and there is no Tdef or macro evolution. The waiter's suspended bottle and the impending Antarctic storm are not realized, so the piece stays a static, near-silent drone.
- **Round 02 (`COMPOSE`)**: The core metaphor is sound: phase-drifting tick streams with slightly different durations (0.93–1.12), plus DynKlank chimes using inharmonic partials. The palette is thin and the breath is just a 55 Hz SinOsc with slow AM, so the 'breathing of time' in the microscopic gaps between gears is never sonified. There are technical flaws: Ndef(\breath) plays to the output directly and is also summed into masterMix, so it is heard twice, and ServerTree.add leaks limiter instances. A Pwhite is also set on a live Pbindef duration, and the duplicate wet10 control makes for awkward mixing. The Tdef timeline does give a clear build, climax, collapse and realignment arc.
- **Round 03 (`DESIGN`)**: This is a boilerplate randomized subtractive fallback (detuned saw/pulse, RLPF, comb, FreeVerb2) with no reference to Lissajous figures, quadrature phase relationships, or modular patching metaphors. Both compilation checks failed, likely from the Balance2 argument handling and the env/Pbindef interaction. The MIDI routing scaffold is thorough, but the musical content is a static pentatonic Prand loop with no formal arc.
- **Round 04 (`GENERATE`)**: The Ndef/\set Pbindef architecture is clean and well gain-staged with LeakDC and limiters. However, the \amp key in the gungas sequence is overridden by the Pbindef only in name, the K2A trigger usage is slightly fragile, and the formant 'chant' is a thin BPF additive tone. Gungas via DynKlank and cadenced steps nod to the prompt, but there's no moçambique polyrhythm, call-and-response, or processional evolution. The piece is a static three-layer loop with no Tdef arc.
