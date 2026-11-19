# Qualitative & Artistic SuperCollider Evaluation Report
**Evaluated**: 2026-11-13 13:49:16 UTC
**Blind Judge**: `anthropic/claude-opus-5.5` (2-stage: per-round blind scoring + cross-round portfolio variety audit)
**Judge Cost**: 64,862 in / 7,977 out tokens (~$0.4190)

> **Note on Timeouts**: Rounds that timed out (>120s API guard) receive `0.0` in all-rounds averages; completed-only averages are also shown in parentheses where applicable.

## 1. Qualitative Leaderboard (Mean Scores / 10)

| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| #1 | **OpenAI GPT-6.1 Sol** | **6.39** | 4.5 | 6.00 | 7.00 | 5.50 | 7.50 | 5.62 | 6.75 | 16 | 140.0 |
| #2 | **Gemini 4 Carbon** | **5.37** | 4.5 | 5.62 | 5.12 | 4.88 | 6.25 | 4.62 | 5.75 | 20 | 120.8 |
| #3 | **Claude Sonnet 5.5** | **4.67** | 4.0 | 4.88 | 4.62 | 4.00 | 5.50 | 4.12 | 4.88 | 16 | 72.2 |
| #4 | **DeepSeek V4 Pro** | **3.00** | 2.5 | 3.00 | 3.00 | 2.62 | 3.50 | 2.75 | 3.12 | 14 | 52.2 |

## 2. Qualitative Overall Score by Mode

| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |
|:---|:---:|:---:|:---:|:---:|
| **OpenAI GPT-6.1 Sol** | 6.83 | 7.42 | 5.25 | 6.08 |
| **Gemini 4 Carbon** | 6.67 | 7.42 | 1.00 | 6.42 |
| **Claude Sonnet 5.5** | 5.50 | 6.83 | 1.00 | 5.33 |
| **DeepSeek V4 Pro** | 4.17 | 5.83 | 1.00 | 1.00 |

## 3. Artistic Profiles, DSP Signatures & Blind Spots

### OpenAI GPT-6.1 Sol (`openrouter:openai/gpt-6.1-sol`)
- **Artistic Signature**: A texture-and-gesture composer drawn to noise-band filtering, resonant modal banks (DynKlank/Ringz) and conceptually precise events, such as counted strikes and phasing impulse swarms. It favors concept-driven micro-structures over broad timbral exploration.
- **Unique UGens Used (16)**: `SinOsc` (4), `BPF` (3), `PinkNoise` (3), `WhiteNoise` (3), `HPF` (3), `LPF` (2), `Decay2` (2), `DynKlank` (2), `LFNoise2` (1), `Ndef` (1), `Ringz` (1), `RLPF` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Strong conceptual framing with precise, countable gestures (e.g., 27 FM strikes followed by silence) that give pieces clear dramaturgy
  - Effective use of modal resonators (DynKlank, Ringz) with Dust/Decay2 excitation for convincing inharmonic, percussive and metallic timbres
  - Solid rhythmic-process thinking, such as detuned, phase-staggered Impulse clocks producing emergent phasing textures
- **Blind Spots**:
  - Narrow synthesis palette across rounds: 16 unique UGens, heavily reliant on SinOsc plus filtered noise, with generic FreeVerb tails and little granular, wavetable, physical-model or spectral work
  - Weak long-form evolution and code hygiene: static loops lacking Tdef/Pattern-driven arcs, abrupt parameter jumps, and sclang-only constructs (an `if` on a Collection) misused inside a SynthDef

### Gemini 4 Carbon (`openrouter:google/gemini-4-carbon`)
- **Artistic Signature**: A noise-and-resonator texturalist that favors filtered noise, Dust-excited DynKlank modal bodies, and subtractive Saw/RLPF voices, often with witty conceptual programmatic hooks such as map-folding creases and tin-can pellets. Its work is organized as Ndef/Pbindef live-coding loops rather than shaped compositions.
- **Unique UGens Used (20)**: `SinOsc` (4), `BPF` (3), `DynKlank` (3), `HPF` (3), `RLPF` (3), `WhiteNoise` (3), `PinkNoise` (2), `Saw` (2), `Decay2` (2), `Dust` (2), `LFNoise1` (2), `Fold` (1)
- **Architectural Constructs**: `Bus`×1, `Ndef`×4, `Pbindef`×3, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Convincing physical-modeling-style textures built from impulsive excitation (Dust, Decay2) driving modal resonators (DynKlank, Ringz).
  - Inventive rhythmic ideas, notably the phase-drifting Pbindef pendulums at slightly detuned durations (0.487/0.5/0.519) that produce Reich-like process music.
  - Imaginative mapping of programmatic concepts onto DSP, such as using Fold wavefolding on noise bursts to suggest paper creases, layered over a solid filter-chain vocabulary (BPF, HPF, RLPF, MoogFF).
- **Blind Spots**:
  - Weak macro-form: pieces loop statically without climaxes, collapses, or long-range evolution, and it lacks Tdef/Routine-driven structural arcs.
  - Reliability problems: the design round collapsed into a single-SinOsc placeholder that ignored the modular and Lissajous requirements, and other rounds contained code bugs (duplicate \dur keys, a DynKlank frequency-scale bug, stray scene references).

### Claude Sonnet 5.5 (`openrouter:anthropic/claude-sonnet-5.5`)
- **Artistic Signature**: A resonator-centric noise sculptor that favors filtered noise excitations fed through DynKlank and Ringz banks to evoke glassy, metallic, or ritual-percussive timbres, organized via Ndef/Pbindef loops rather than through-composed form. When it lands, it shows a sensitivity to texture and polyrhythmic drift, but its structural thinking is static and its output is erratic.
- **Unique UGens Used (16)**: `SinOsc` (4), `BPF` (3), `LFNoise1` (3), `PinkNoise` (3), `WhiteNoise` (3), `DynKlank` (2), `LPF` (2), `Saw` (2), `Ringz` (2), `RLPF` (1), `Dust` (1), `Ndef` (1)
- **Architectural Constructs**: `Bus`×1, `Ndef`×4, `Pbindef`×3, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Idiomatic use of modal resonators (DynKlank, Ringz) excited by Pink/White noise and Dust to create convincing inharmonic, physical-model-like timbres such as glass tones and tin shakers
  - Rhythmic ingenuity in pattern space, notably detuned Pbindef durations that produce phasing clock drift
  - Comfortable with JITLib live-coding architecture (Ndef, Pbindef, Tdef) for layered, modular sound design
- **Blind Spots**:
  - Weak macro-form: pieces cycle, reset, or loop statically instead of building arcs, climaxes, or collapses, and Tdef-driven processional structure is rarely exploited
  - Unreliable under design-mode demands, including a trivial SinOsc fallback that ignored the prompt, plus a narrow UGen palette (16 total) with no FM, granular, spectral, or spatial processing and occasional API misuse such as xset on Ndef

### DeepSeek V4 Pro (`openrouter:deepseek/deepseek-v4-pro`)
- **Artistic Signature**: When it engages, this model leans toward resonator-based textures (Ringz, DynKlank) and spread-based swarm ideas built in an Ndef/Pbindef live-coding style. Half its rounds collapse into a lone SinOsc fallback, so its personality is inconsistent and mostly undeveloped.
- **Unique UGens Used (14)**: `SinOsc` (4), `LFTri` (2), `WhiteNoise` (2), `PinkNoise` (1), `Pluck` (1), `RLPF` (1), `Ringz` (1), `BPF` (1), `Decay2` (1), `DynKlank` (1), `LFNoise2` (1), `LFPulse` (1)
- **Architectural Constructs**: `Bus`×1, `Ndef`×4, `Pbindef`×2, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Conceptual sound-design ideas such as the 30-voice detuned LFPulse swarm that maps phase drift through spread
  - Use of resonant filtering (Ringz, DynKlank, BPF with Decay2) to turn noise bursts into evocative physical-object timbres
  - Familiarity with JITLib constructs (Ndef, Pbindef, Tdef) for modular, live-patchable architectures
- **Blind Spots**:
  - Frequent total failure modes: design and generate rounds produced trivial single-sine placeholders that ignored the prompt entirely, including the Congada percussion brief
  - Shallow musical development and generic defaults: static loops, C major harmony at odds with the expressive intent, stock FreeVerb2, plain sine ticks, and fragile bus/limiter routing

## 4. Round-by-Round Blind Critique

### OpenAI GPT-6.1 Sol
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **6.83** | 5.5 | 7.0 | 6.0 | 8.0 | 7.0 | 7.5 | Exactly 27 FM paper-fold strikes, then suspended silence | Limited synthesis palette; the storm drone is mostly sine and noise |
| 02 | `COMPOSE` | **7.42** | 7.0 | 7.0 | 6.5 | 8.5 | 8.0 | 7.5 | Twelve detuned Impulse clocks with staggered phases creating phasing swarm | Only twelve clocks; mid-section drift jumps break microscopic-dephasing subtlety |
| 03 | `DESIGN` | **5.25** | 5.0 | 7.0 | 4.5 | 6.0 | 3.5 | 5.5 | Phase-rotating stereo SinOsc pair evoking Lissajous orbits | Dead sclang `if` on Collection inside SynthDef; generic FreeVerb tail |
| 04 | `GENERATE` | **6.08** | 6.5 | 7.0 | 5.0 | 7.5 | 4.0 | 6.5 | DynKlank inharmonic tin modes with Dust scatter for gungas | Static loops; no Tdef-driven arc or cortejo evolution |

- **Round 01 (`APPEND`)**: The FM-plus-bandpassed-noise 'fold' instrument plays exactly 27 events and then falls silent, a clever numeric metaphor for the 27 years and the halted explanation. The Pseg-driven Antarctic drone builds tension that never breaks, which fits the frozen waiter and the storm 'prestes a desabar'. Architecture is clean: \set slots, LeakDC, tanh, and rollback notes are all present. The timbres, however, stay conventional: sine partials, pink noise and simple FM.
- **Round 02 (`COMPOSE`)**: The piece builds its percussion from noise-excited Ringz escapements, DynKlank carillons with inharmonic French-bell partials, FM spring windings, and a breathing BPF-noise layer. The core metaphor works: detuned pendulum rates make the dephasing the instrument, which captures the prompt's idea well. The Tdef shapes a clear arc from a single pendulum, through the swarm and chimes, to the breath and a final strike. On the technical side, the in-Ndef Ringz clocks never fade with xset envelopes but simply drop to amp 0. The 0.13 drift steps also become coarse detunings rather than microscopic phase shifts, and the reverb and allpass effects slots are fairly conventional.
- **Round 03 (`DESIGN`)**: Solid MIDI/GUI architecture with bus-mapped parameters, grouped routing, LeakDC and a limiter on the master, though the language-side `isKindOf` check inside the SynthDef is fragile, dead logic. The synthesis is modest: wavefolding VarSaw plus a stereo phase-modulated sine pair whose slow orbit nods to rotating Lissajous figures, but the palette is thin and FreeVerb-clichéd. As a design instrument it has no autonomous temporal arc, and the phosphor/modular imagery is only lightly translated into DSP.
- **Round 04 (`GENERATE`)**: The code uses clean Ndef design with \set pattern slots, \filter reverb and comb slots, LeakDC, and tanh saturation. Its three-layer texture maps well onto the prompt: pitch-bent skins for the caixas, inharmonic DynKlank metal with jittered Dust for the ankle gungas, and a formant call-and-response voice. Weaknesses include possible t_trig/K2A trigger fragility in \set contexts and the FreeVerb2 cliché. The rhythms are simple and the piece runs as an unchanging loop apart from commented manual tweaks, so it never builds the processional development of a desfile.

### Gemini 4 Carbon
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **6.67** | 7.0 | 6.5 | 6.0 | 8.0 | 5.0 | 7.5 | Wavefolded noise bursts emulating pedantic map-folding paper creases | Static looping sequences; storm never actually collapses or climaxes |
| 02 | `COMPOSE` | **7.42** | 7.5 | 6.5 | 6.5 | 8.5 | 8.0 | 7.5 | Phase-drifting Pbindef pendulums at 0.487/0.5/0.519 durations | Duplicate \dur keys, a DynKlank frequency-scale bug, and stray references to other scenes |
| 03 | `DESIGN` | **1.00** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | None; a single fallback sine tone | Trivial placeholder ignores modular, Lissajous, and design requirements |
| 04 | `GENERATE` | **6.42** | 7.0 | 6.5 | 6.0 | 7.5 | 4.5 | 7.0 | DynKlank tin-can modes excited by Dust pellet grains | No macro form evolution; static looping patterns throughout |

- **Round 01 (`APPEND`)**: The piece combines folded and bandpassed noise, DynKlank glass resonance, and a MoogFF sub cluster with GVerb. The Ndef slot routing via \set and \filter is idiomatic, but the GVerb filter sums to mono, there is a fragile isKindOf branch, and the \set Pbindef ignores the SynthDef envelope semantics. The prompt mapping is evocative: methodical folding rhythms, a frozen bottle shimmer, and 8+8+11=27-beat barometric drops. Form stays as three independent loops without a macro arc toward the promised storm.
- **Round 02 (`COMPOSE`)**: The piece maps the prompt well. Three pendulums with slightly mismatched periods give Reich-like drift. A Dust/CombL swarm stands in for the two hundred clocks, and a breathing additive/noise pad blooms when the watchmaker closes his eyes. The timbres are varied: DynKlank brass escapements, FM pocket watches, FM-plus-modal carillons, and a ratcheting spring. There are several technical flaws. The carillon Pbindef has two \dur keys, so the later one silently overrides the first. The escapamento passes freq/1000 to DynKlank as its frequency scale. The score also stops and resets Pbindefs and Ndefs from other scenes, and the master bus is summed without much gain management. The four-cue arc builds toward saturation and then settles into breath, which gives convincing narrative pacing.
- **Round 03 (`DESIGN`)**: The code is a safe-fallback 440 Hz sine at low amplitude, produced after the initial compilation failed. It has no modulation, patching metaphor, stereo phase play for Lissajous figures, GUI, or MIDI architecture as design mode expects. It also has no temporal evolution and no connection to the prompt's imagery of the modular cabinet and oscilloscope.
- **Round 04 (`GENERATE`)**: The code layers three instruments. The first is a pitch-enveloped caixa with a tanh drive. The second is a convincing gunga rattle built from Dust-excited DynKlank inharmonic modes. The third is a formant-morphing Mixolydian 'canto' with an FM bell accent, which maps well onto the procession and devotional imagery. Technically it is mostly sound. However, the GVerb filter is fed a summed signal, which collapses the stereo image. The `if isKindOf` branches are odd boilerplate. The `\set` patterns rely on `t_trig` behaving correctly. Structurally the piece is a static loop. There is no Tdef or macro arc to stage the parade's arrival, climax, or departure beyond the commented live tweaks.

### Claude Sonnet 5.5
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **5.50** | 6.0 | 5.5 | 4.5 | 6.5 | 4.5 | 6.0 | DynKlank glassy waiter tone with long-attack suspended excitation | Storm cycles and resets instead of building to collapse |
| 02 | `COMPOSE` | **6.83** | 6.5 | 6.0 | 6.0 | 8.0 | 7.5 | 7.0 | Detuned Pbindef durations creating phasing clock drift | Short piece; bell partials generic, xset misuse on Ndef |
| 03 | `DESIGN` | **1.00** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | Compiles cleanly as a minimal fallback Ndef | Trivial sine fallback ignores the prompt and design-mode requirements |
| 04 | `GENERATE` | **5.33** | 6.0 | 6.0 | 4.5 | 6.5 | 3.5 | 5.5 | Ringz-tuned inharmonic noise bursts emulating gunga tin shakers | Static loops with no Tdef-driven processional arc |

- **Round 01 (`APPEND`)**: The palette is reasonably varied. It includes FM plucks with a noise-burst 'paper fold', BPF-pink-noise room tone, detuned saw drone with tanh saturation, and DynKlank resonators. Weaknesses include wet10 set to 0 on the comb effect, which makes it dead code, the unused t_trig in mesaHum, and an absent master gain stage. The storm Pseq loops back to low tension every 32 seconds rather than escalating to the 'about to collapse' climax. The waiter's glass tone works as a clever image of suspension, and the pedantic arpeggio captures the map lecture. Overall the form stays static and loop-based, with no true silence contrast or rupture.
- **Round 02 (`COMPOSE`)**: The phasing between near-identical durations (0.5, 0.503, 0.497) maps directly onto the prompt's microscopic gear offsets. DynKlank escapement ticks, FM carillon, and a Ringz Dust swarm give a reasonable palette. There is a clear arc from a lone clock through the swarm and the chime to the breath and a return to one tick. Several technical problems undercut it. Ndef xset crossfades the whole proxy rather than modulating smoothly. The Pgeom dur gets reassigned every loop iteration. Pbindef \clockA is re-played after stop, and since clear wipes it, the earlier keys persist only by chance. The "breath" is a fairly generic filtered-noise pad, and the whole piece lasts under a minute.
- **Round 03 (`DESIGN`)**: The code is a single 440 Hz SinOsc fallback with no modulation, routing, GUI, MIDI or scope architecture, so design mode is entirely unmet. It never touches the modular cabinet, pin matrices or rotating Lissajous imagery, which invites quadrature oscillators, phase-drifting ratios or a scope view. There is no form, evolution or creative mapping; it is placeholder boilerplate.
- **Round 04 (`GENERATE`)**: The code uses sound Ndef architecture: \set slot Pbindef sequencing, \filter FX slots, LeakDC and tanh drum saturation, and formant vowel morphing via SelectX. One fragility is that the Gunga CombL runs on raw stereo without a gain trim, so its output could build up. The gungas are rendered convincingly as metallic Ringz noise, and the chant formants nod to the ternos de congo. However, the rhythm is a generic syncopated loop rather than a congo or moçambique cadence, and nothing evolves over time to suggest procession or coronation.

### DeepSeek V4 Pro
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **4.17** | 4.5 | 5.0 | 3.5 | 5.0 | 2.5 | 4.5 | Ringz-resonated noise burst as suspended wine bottle glint | Static loops; C major scale trivializes the domestic tension |
| 02 | `COMPOSE` | **5.83** | 5.5 | 5.0 | 5.0 | 7.0 | 6.5 | 6.0 | 30-voice detuned LFPulse swarm mapping phase drift via spread | Plain sine ticks, generic FreeVerb2, and fragile bus/limiter handling |
| 03 | `DESIGN` | **1.00** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | None; only a fallback sine tone | Trivial fallback ignores prompt, design mode, and synthesis entirely |
| 04 | `GENERATE` | **1.00** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | None; a single static sine fallback tone | Fallback placeholder ignores the Congada percussion prompt entirely |

- **Round 01 (`APPEND`)**: The code is functional and uses NodeProxy slot routing correctly, with \filter and \set sources. Several flaws weaken it: the Ringz exciter is multiplied by a redundant outer envelope, the GVerb in.sum produces a mono-to-stereo mismatch, and the CombC and tanh effects sit at wet 0, so they never sound. Musically, the C-major Pluck sequence and sine-plus-pink-noise drone illustrate the scene literally, but there is no Tdef or macro evolution toward the 'storm about to break' that the prompt builds up.
- **Round 02 (`COMPOSE`)**: The 30-voice swarm with incrementally detuned rates is a direct and effective metaphor for desynchronized clocks, and the Tdef score has clear cues from awakening through peak drift to settling. DSP craft is modest: ticks are bare SinOsc/Decay2 rather than brassy metallic resonators. The carillon DynKlank uses non-French partials with a redundant env gate, the Synth.tail limiter can be duplicated, and the intermediate bus is never cleared. The 'breath of time' is a simple LFTri-modulated sine drone, so the poetic core of the piece remains underdeveloped.
- **Round 03 (`DESIGN`)**: The code is a single 440 Hz sine fallback at low amplitude. It has no modular patching metaphor, no Lissajous or harmonic folding, and no GUI or MIDI architecture despite DESIGN mode. It compiles, but the output is boilerplate with no musical form or connection to the prompt.
- **Round 04 (`GENERATE`)**: The code is a 440 Hz sine fallback, produced after the initial compilation failed, with no synthesis design, rhythm, or form. It never attempts the metallic gunga ankle-rattle percussion, the processional cadence, or the moçambique ensemble textures the prompt calls for. It compiles, but artistically it is trivial boilerplate.
