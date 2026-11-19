# Qualitative & Artistic SuperCollider Evaluation Report
**Evaluated**: 2026-11-13 12:00:11 UTC
**Blind Judge**: `anthropic/claude-sonnet-5.5` (2-stage: per-round blind scoring + cross-round portfolio variety audit)
**Judge Cost**: 93,546 in / 9,250 out tokens (~$0.2796)

> **Note on Timeouts**: Rounds that timed out (>120s API guard) receive `0.0` in all-rounds averages; completed-only averages are also shown in parentheses where applicable.

## 1. Qualitative Leaderboard (Mean Scores / 10)

| Rank | Model | Overall | Portfolio Variety | Variety | Tech Depth | Audacity | Coherence | Arcs | Creativity | Unique UGens | Mean LOC |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| #1 | **Gemini 4 Hydrogen** | **4.65** | 4.8 | 5.00 | 4.88 | 3.88 | 5.62 | 4.00 | 4.50 | 22 | 159.8 |
| #2 | **Claude Haiku Latest** | **4.48** | 3.5 | 4.88 | 4.25 | 3.75 | 5.62 | 3.75 | 4.62 | 15 | 115.2 |
| #3 | **Gemini 3.8 Flash** | **4.40** | 3.5 | 4.88 | 3.75 | 4.12 | 5.38 | 3.50 | 4.75 | 21 | 98.5 |
| #4 | **OpenAI GP6 Luna** | **4.33** | 3.5 | 4.75 | 4.50 | 3.62 | 5.00 | 3.62 | 4.50 | 15 | 112.2 |
| #5 | **DeepSeek Flash Latest** | **3.98** | 3.5 | 4.25 | 4.00 | 3.25 | 4.88 | 3.62 | 3.88 | 13 | 101.5 |

## 2. Qualitative Overall Score by Mode

| Model | `APPEND` | `COMPOSE` | `DESIGN` | `GENERATE` |
|:---|:---:|:---:|:---:|:---:|
| **Gemini 4 Hydrogen** | 3.50 | 5.83 | 4.08 | 5.17 |
| **Claude Haiku Latest** | 4.25 | 5.58 | 3.58 | 4.50 |
| **Gemini 3.8 Flash** | 4.75 | 5.92 | 1.08 | 5.83 |
| **OpenAI GP6 Luna** | 3.67 | 5.08 | 4.25 | 4.33 |
| **DeepSeek Flash Latest** | 3.17 | 5.42 | 2.50 | 4.83 |

## 3. Artistic Profiles, DSP Signatures & Blind Spots

### Gemini 4 Hydrogen (`openrouter:google/gemini-4-hydrogen`)
- **Artistic Signature**: A noise-and-resonator-driven sound designer that favors filtered pink/white noise textures, DynKlank/Ringz inharmonic metallic modes, and stochastic triggers, with an occasional turn to wavefolded, feedback-FM instrument design. Its ideas are evocative at the timbral level, but they tend to stay static and loop-based, with little macro-scale evolution.
- **Unique UGens Used (22)**: `SinOsc` (4), `BPF` (3), `PinkNoise` (3), `HPF` (3), `Saw` (3), `LPF` (2), `DynKlank` (2), `RLPF` (2), `WhiteNoise` (2), `Pulse` (2), `Decay` (1), `Dust` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Evocative inharmonic resonator work (DynKlank, Ringz, glass partials) that gives convincing metallic and percussive color
  - Ambitious use of live-coding architecture (Ndef, Pbindef, Tdef, Bus), including detuned clocks that create gradual phase drift
  - Capable of richer instrument design, such as MoogFF with Fold and SinOscFB plus a paginated MIDI GUI, when the brief calls for it
- **Blind Spots**:
  - Weak long-form evolution: loops stay static, with no Lissajous or autonomous macro modulation, and the narrative or map concept is rarely realized
  - Fragile routing and robustness: unmapped wet slots, duplicate keys, Ndef/Pbindef misuse and compile failures, plus a narrow UGen palette (22 unique, heavily reused noise, filter and basic oscillator staples)

### Claude Haiku Latest (`openrouter:anthropic/claude-haiku-5.5`)
- **Artistic Signature**: A noise-centric, filter-driven miniaturist that builds textural soundscapes (brown-noise storms, ticks, resonant Ringz percussion) from a small palette of noise sources and filters. Its ideas are evocative, but the execution tends to be static and fragile.
- **Unique UGens Used (15)**: `LPF` (4), `SinOsc` (4), `WhiteNoise` (4), `BPF` (3), `HPF` (3), `LFNoise2` (2), `PinkNoise` (2), `Ringz` (2), `Saw` (2), `BrownNoise` (1), `LFNoise1` (1), `Fold` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Evocative textural concepts, such as paper crackle storms, clock-drift ticks, noise-excited Ringz gungas, and a Karplus-style pluck
  - Comfortable with live-coding scaffolding: Ndef, Pbindef, SynthDef, Bus routing, MIDIdef and GUI show up across modes
  - Good use of noise colors (white, pink, brown) with filter shaping, plus some nonlinear touches like Fold and MoogFF
- **Blind Spots**:
  - Narrow synthesis vocabulary: only 15 unique UGens, with no granular, FM or physical-model depth, reverb or delay UGens, or spatial work, and everything is built on noise plus filters
  - Weak form and robustness: loops stay static with little evolution, routing is buggy (compile failures, ineffective wet slots, broken GUI), and the overall scores are consistently low

### Gemini 3.8 Flash (`openrouter:google/gemini-3.8-flash`)
- **Artistic Signature**: A tactile, percussive-textural voice built on DynKlank resonant exciters (paper creases, brass ticks, tin-can rattles) over Moog-filtered saw/pulse drones, sequenced with Pbindef and Ndef. It favors micro-detuned, polyrhythmic loops, but they stay static and the routing is often fragile.
- **Unique UGens Used (21)**: `SinOsc` (4), `BPF` (3), `DynKlank` (3), `MoogFF` (3), `PinkNoise` (3), `Saw` (3), `WhiteNoise` (3), `Pulse` (2), `Dust` (2), `HPF` (2), `LPF` (2), `Crackle` (1)
- **Architectural Constructs**: `Bus`×1, `Ndef`×4, `Pbindef`×3, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Imaginative physical-modeling-style timbres using DynKlank with noise/Dust exciters, giving distinctive, concrete sound objects
  - Comfortable with live-coding architecture (Ndef, Pbindef, Tdef) and polyrhythmic, micro-detuned pattern ideas
  - Reasonable subtractive palette (MoogFF, BPF, HPF/LPF, multiple noise colors) that scores 5.8-5.9 in compose and generate modes
- **Blind Spots**:
  - No macro-form or evolution: loops and drones stay static with no climax, modulation arcs, or long-term development
  - Unreliable robustness: compile failures, unread buses, misused wet keys, and a collapse to a single SinOsc in design mode (1.08) that ignored the prompt. Synthesis is also narrow, with no granular, FM, buffer, or spatial techniques

### OpenAI GP6 Luna (`openrouter:openai/gpt-6-luna`)
- **Artistic Signature**: A percussive, bell-and-tick oriented voice built on sine/FM tones and noise transients, resonated through Ringz and DynKlank. It favors Ndef/Pbindef pattern scaffolding and conceptual imagery (map-folding, Lissajous, gungas), but the results stay static and loop-bound.
- **Unique UGens Used (15)**: `SinOsc` (4), `WhiteNoise` (4), `RLPF` (2), `Decay2` (2), `DynKlank` (2), `BPF` (1), `Ndef` (1), `Ringz` (1), `Fold` (1), `HPF` (1), `SinOscFB` (1), `XFade2` (1)
- **Architectural Constructs**: `Bus`×2, `GUI`×1, `MIDIdef`×1, `Ndef`×3, `Pbindef`×3, `Routine`×1, `SynthDef`×2, `Tdef`×1
- **Key Strengths**:
  - Convincing inharmonic resonator timbres (Ringz and DynKlank chimes, FM bells) with noise-grit transients
  - Willingness to build interactive architecture (MIDI-split zones, Ndef/Pbindef/Tdef, buses) across modes
  - Strong conceptual framing and some timbral layering, such as wavefolding with filtered clicks and trace voices
- **Blind Spots**:
  - No long-form evolution or autonomous arc: patterns loop statically, and phasing or clock-density ideas are under-realized
  - Narrow UGen palette (15 unique, dominated by SinOsc and WhiteNoise) with little spatial, granular, or effects processing, and fragile Ndef/Pbindef triggering; overall scores stay mediocre (3.7–5.1)

### DeepSeek Flash Latest (`openrouter:deepseek/deepseek-v4.1-flash`)
- **Artistic Signature**: A pragmatic, texture-first sketcher that leans on noise-excited resonators, simple oscillators and Ndef/Pbindef layering to build programmatic scenes. Its ideas are evocative (carillon bells, gunga resonances, narrative roles), but the DSP vocabulary is narrow and the execution is fragile.
- **Unique UGens Used (13)**: `SinOsc` (4), `LPF` (3), `PinkNoise` (3), `BPF` (2), `Pulse` (2), `RLPF` (2), `WhiteNoise` (2), `HPF` (2), `DynKlank` (1), `Ndef` (1), `Saw` (1), `Decay2` (1)
- **Architectural Constructs**: `Bus`×1, `MIDIdef`×1, `Ndef`×4, `Pbindef`×3, `Routine`×1, `SynthDef`×1, `Tdef`×1
- **Key Strengths**:
  - Imaginative concept-to-sound mapping, such as storm/argument/waiter roles and inharmonic carillon bells
  - Effective use of resonant, noise-excited synthesis (DynKlank, Ringz with Decay2 bursts) and tanh saturation for percussive timbres
  - Comfort with live-coding architecture (Ndef, Pbindef, Tdef) for layering stochastic, swarm-like textures
- **Blind Spots**:
  - Very small UGen palette (13 unique across rounds) with no FM, granular, buffer, spectral or modulation-heavy techniques, so the synthesis stays generic and subtractive
  - Unreliable routing and syntax (Pbindef \set bugs, unwired buses, compile errors) and static loops with no macro-form or evolution; prompt imagery is sometimes ignored, as with Lissajous

## 4. Round-by-Round Blind Critique

### Gemini 4 Hydrogen
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **3.50** | 3.0 | 4.0 | 2.5 | 5.0 | 3.0 | 3.5 | Trigger-enveloped bandpass wind swell with inharmonic glass partial | Sparse, static, generic drone; no restaurant or map narrative |
| 02 | `COMPOSE` | **5.83** | 6.0 | 4.5 | 5.0 | 7.0 | 7.0 | 5.5 | Slightly detuned Pbindef tick durations creating gradual phase drift between clocks | Fragile routing: wet slots unmapped, duplicate keys, Ndef misuse, initial compile failure |
| 03 | `DESIGN` | **4.08** | 5.0 | 6.0 | 3.5 | 4.0 | 2.5 | 3.5 | Wavefolded MoogFF sub with feedback-FM and paginated MIDI GUI | No Lissajous modulation or autonomous evolution; just a MIDI instrument |
| 04 | `GENERATE` | **5.17** | 6.0 | 5.0 | 4.5 | 6.5 | 3.5 | 5.5 | DynKlank inharmonic metal modes for ankle gungas, triggered stochastically | Static loops, no macro evolution; fragile Ndef/Pbindef trigger routing |

- **Round 01 (`APPEND`)**: A basic sub sine, filtered pink noise, and one inharmonic partial give a competent cold-drone sketch, but the palette is minimal and the ending is safe. The \set -> Pbindef routing is idiomatic, but t_trig is set from a Pbind, which is fragile, and the 'degree' key doesn't map to freq without a Pbind-side freq conversion. The Antarctic silence is loosely evoked, but there is no tension build, no tempest release, and no sense of the garçom or the map-folding absurdity.
- **Round 02 (`COMPOSE`)**: The piece maps the prompt well: brass DynKlank ticks, chronometer noise-ringz, FM carillon, and sequences with deliberately mismatched durations (0.75, 0.75, 0.75, 0.76) that create real phase drift. The seven-cue arc moves from sparse to swarm to a breathing-drone settling, then winds down, which is clear and effective. However, the architecture has fragile patterns: duplicate \dur keys, the `if(sig.isKindOf...)` hack on a UGen, the In.ar of a bus inside an Ndef, and an initial compile failure. The synthesis is competent but conventional, with a standard FreeVerb2 and comb tail.
- **Round 03 (`DESIGN`)**: The architecture is solid: bus-mapped parameters, zone routing, a limiter with LeakDC, and a paginated GUI with MIDI auto-detection. The DSP is conventional, though: a wavefolded saw sub, SinOscFB FM, a detuned saw pad, and Comb plus FreeVerb2 effects. The Lissajous and oscilloscope imagery is only gestured at through names and the 2.71 ratio, with no phase-rotating or XY-style modulation. There is no temporal form because the piece waits for a player, and the first compile failed, which suggests some fragility.
- **Round 04 (`GENERATE`)**: Three layers (pitch-swept caixa with noise rattle, DynKlank gungas, formant-filtered chant in mixolydian) map well to the Congada imagery and avoid generic pads. The technical routing is shaky: \set -> Pbindef with t_trig likely fails to retrigger reliably, the wet10 filter slots are mixed with the source slot, and the K2A/EnvGen.ar on t_trig is questionable. Form is a static looping texture with no introduction, climax, or development, and the rhythm is simple rather than a true polyrhythmic march.

### Claude Haiku Latest
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **4.25** | 4.0 | 3.5 | 3.5 | 6.0 | 3.5 | 5.0 | Filtered brown noise storm drone with sparse paper crackles | Initial compile failed; Pbindef-as-Ndef-set routing fragile and static |
| 02 | `COMPOSE` | **5.58** | 5.5 | 4.5 | 4.5 | 7.0 | 6.5 | 5.5 | Slightly detuned tick intervals evoke microscopic clock phase drift | Buggy routing and wet10 slot never audibly effective |
| 03 | `DESIGN` | **3.58** | 4.5 | 4.0 | 3.5 | 3.5 | 2.5 | 3.5 | Karplus-style noise-burst comb pluck with a FM/fold sub zone | No Lissajous or oscilloscope imagery; passive MIDI-only instrument with buggy GUI |
| 04 | `GENERATE` | **4.50** | 5.5 | 5.0 | 3.5 | 6.0 | 2.5 | 4.5 | Noise-excited Ringz bank evoking tin ankle gungas | Static loops with no form; sine-based drums lack richness |

- **Round 01 (`APPEND`)**: The palette is simple: filtered brown noise, a BPF noise burst, and an inharmonic additive sine bell. The mapping to the prompt is sensible (storm as tension, paper folds as crackle, suspended glass tone), but the Ndef \set -> Pbindef routing is dubious, since Pbindef without a proper event type may not drive Ndef controls. There is no real arc or evolution beyond slow random LFOs and an alternating two-note bell, so it reads as a modest, safe sketch.
- **Round 02 (`COMPOSE`)**: The piece uses Ringz-based escapements, FM chimes, and 24 slightly detuned Impulse streams to suggest clocks drifting out of phase, which fits the prompt well. The cue-based Tdef gives a clear arc of breath, accumulation, acceleration, chime, settling and stop. Technically it is fragile: the Ndef masterMix mixes the Ndefs through .ar while they also play directly, so they are doubled. The FreeVerb2 filter slot is misconfigured, the \wet10 control is not wired up as intended, and the safety limiter is added awkwardly. The Pbindef bus routing is also questionable.
- **Round 03 (`DESIGN`)**: The MIDI-controlled three-zone instrument pairs FM with wavefolding, a comb-based pluck and a detuned Saw/MoogFF pad, which is a modest palette. The engineering has real bugs: the FX synth reads and writes bus 0 in place with an unmapped group, the sliders are all normalized 0-1 and so mismatch the CC value ranges, the GUI children are stacked and overlap, and the single fx knob is shared across all zones. It barely evokes the prompt's Lissajous rotation, since there is no phase-related stereo or XY ratio modulation, and with no autonomous evolution it offers almost no compositional arc.
- **Round 04 (`GENERATE`)**: The gunga resonator bank with randomized tone and panning is a fitting metallic percussion idea, and the drum voices use pitch-drop envelopes with tanh saturation. However, the piece is a fixed set of looping Pbindefs with no development or climax. Drums are plain sines, and the \set-driven t_trig pattern is somewhat fragile. The Congada's cultural layers (call-and-response, sacred procession) are only lightly suggested.

### Gemini 3.8 Flash
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **4.75** | 5.5 | 4.0 | 4.5 | 6.0 | 3.0 | 5.5 | DynKlank paper-crease exciter against a detuned Moog-filtered drone | Static drone, looping pattern, no evolution or climax |
| 02 | `COMPOSE` | **5.92** | 6.0 | 4.5 | 5.5 | 7.0 | 6.5 | 6.0 | DynKlank brass escapement ticks with micro-detuned Pbindef durations | Fragile routing: bus never read, filter wet keys misused, initial compile failure |
| 03 | `DESIGN` | **1.08** | 1.0 | 1.5 | 1.0 | 1.0 | 1.0 | 1.0 | Compiles cleanly as a minimal safe fallback | Single static sine ignores entire prompt and mode |
| 04 | `GENERATE` | **5.83** | 7.0 | 5.0 | 5.5 | 7.5 | 3.5 | 6.5 | DynKlank tin-can gunga rattles with polyrhythmic Pbindef sequencing | Static endless loops, no macro-evolution; fragile wet10 and Pbindef-to-slot routing |

- **Round 01 (`APPEND`)**: The concept is clear: a frozen sub-drone under neurotic, dry percussive map-fold clicks built from a Crackle and BPF noise exciter into DynKlank. The idea maps well onto the prompt. The execution is fragile, though. The `if(sig.isKindOf(Collection))` check runs on a UGen graph at build time, and the Balance2 path likely misbehaves. The `\set -> Pbindef` pairing with `t_trig` is dubious, and the `wet10` and `revTime.min(1.0)` handling is shaky. There is also no macro-form: the tension parameter never moves, so the piece lacks the buildup and release the narrative implies.
- **Round 02 (`COMPOSE`)**: DynKlank-based brass ticks and chimes, Dust-driven swarm, and slightly drifting durations (0.125/0.124/0.126) evoke the desynchronized clocks, and the infrasonic 'breathing' drone is a nice metaphor. Technical execution is shaky: ~synthBus is allocated but masterMix reads it through Ndef routing, the filter wet-key settings are dubious, the Ndef \masterMix referencing other Ndefs while they also play directly may double the signal, and the first compile failed. The form is a clear scripted arc from swarm to climax to quiet resolution, but it is linear and fairly safe in its timbral risks.
- **Round 03 (`DESIGN`)**: The code is a fallback placeholder: one 440 Hz sine at low amplitude via Ndef, with no modulation, form, or design-mode GUI/MIDI architecture. It shows nothing of modular synthesis, Lissajous figures, or harmonic folding, so it has no connection to the prompt. It is valid but trivial boilerplate.
- **Round 04 (`GENERATE`)**: Layers are well chosen: pitch-enveloped FM-ish drum with fold distortion, DynKlank metallic gungas, and a formant-filtered saw choir that evoke the Congada procession convincingly. Technically there are fragile points: the `\set -> Pbindef` slot usage, the `wet10` reverb mix, SelectX.kr fed multichannel arrays with vowel values beyond 0–2 semantics, and the Splay/Balance2 branch built on a UGen-level `isKindOf` check. Form is a static looping ostinato with no intro, climax, or evolution, which limits arcs and audacity despite the good cultural coherence.

### OpenAI GP6 Luna
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **3.67** | 3.5 | 4.0 | 3.0 | 4.5 | 3.0 | 4.0 | Wavefolded detuned sine clicks with RLPF for map-folding | Static looping patterns, no evolution, reverb wet closed |
| 02 | `COMPOSE` | **5.08** | 5.0 | 4.5 | 4.0 | 6.0 | 6.0 | 5.0 | Ringz-resonated noise ticks with DynKlank inharmonic chimes | Only a few clocks; no real phasing of 200 clocks |
| 03 | `DESIGN` | **4.25** | 5.5 | 5.0 | 4.0 | 4.0 | 2.5 | 4.5 | Two-zone MIDI-split FM core plus DynKlank/Fold trace voices | No autonomous evolution; Lissajous imagery barely realized sonically |
| 04 | `GENERATE` | **4.33** | 5.0 | 4.5 | 3.5 | 5.5 | 3.0 | 4.5 | FM-bell gungas with noise-grit transients and jittered pitch | Static loops, no arc, and fragile Ndef/Pbindef triggering |

- **Round 01 (`APPEND`)**: The code is two simple Ndefs triggered by Pbindef via \set slots. The wavefolded click is a decent nod to folding a map, and the low drone with filtered hiss suggests Antarctic cold. However, the palette is minimal (sine, fold, noise, FreeVerb2), the loops never evolve, and the wet10 is set to 0, so the reverb is inactive. The restaurant scene, the waiter's suspension, and the storm's build-up are barely developed.
- **Round 02 (`COMPOSE`)**: The Ringz ticks and DynKlank chimes are a sensible clockwork palette, and the Tdef score has a clear arc from awakening through tightening and release to near-unison. However, the central idea of 200 slightly desynchronized clocks is only suggested by one Pbindef pattern. Technical flaws weaken it: a duplicated \dur key, the wet10 slot set on an Ndef filter slot that probably has no effect, a Ndef.ar call on a bus whose routing is questionable, and a dry mix with an unmodulated verb. The result is a competent but safe and thin realization.
- **Round 03 (`DESIGN`)**: This is a competent MIDI-controlled instrument with a split-keyboard architecture, bus-mapped parameters, a master limiter and GUI/CC sync. Two voice types (FM plus SinOscFB, and DynKlank with Fold and Allpass) give modest timbral variety. It produces no sound until played and has no temporal form. The Lissajous and phosphor imagery shows up only in labels, with no real use of detuned ratios or stereo phase rotation. Several fragile spots, such as a MIDI regex chain, a `~ccVals` key mismatch, and per-voice env triggers, lower the technical score.
- **Round 04 (`GENERATE`)**: Three Ndefs (sine floor, FM metallic gungas, MoogFF voice) map sensibly to the Congada imagery, and the gunga FM with a noise transient is a reasonable metallic percussion idea. However, the form is a static looping texture with no evolution. The \set -> Pbindef routing with t_trig=1 is dubious (the trigger likely won't retrigger reliably), the \wet10 sets are fine, and FreeVerb2 on everything is a cliché. The rhythm is also not very evocative of the cadenced marching.

### DeepSeek Flash Latest
| Rnd | Mode | Overall | Var | Tech | Aud | Coh | Arc | Cre | Standout Technique | Weakness |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---|
| 01 | `APPEND` | **3.17** | 3.0 | 3.0 | 2.5 | 4.5 | 2.5 | 3.5 | Layered Ndef roles mapping marriage, argument, storm, and waiter | Basic oscillators, buggy Pbindef \set usage, no evolving form |
| 02 | `COMPOSE` | **5.42** | 5.5 | 4.5 | 4.5 | 6.5 | 6.5 | 5.0 | Layered stochastic tick swarms with DynKlank inharmonic carillon bells | Fragile routing: wet10 never wired, Ndef/bus mixing bugs |
| 03 | `DESIGN` | **2.50** | 3.0 | 3.5 | 2.0 | 2.0 | 2.5 | 2.0 | Detuned saw/pulse stack with PWM and enveloped RLPF | Generic subtractive synth ignoring Lissajous and oscilloscope imagery; compile errors |
| 04 | `GENERATE` | **4.83** | 5.5 | 5.0 | 4.0 | 6.5 | 3.0 | 5.0 | Inharmonic Ringz-bank gungas with noise-burst excitation and tanh saturation | Static endless loops with no macro-form; fragile slot/Pbindef routing |

- **Round 01 (`APPEND`)**: The piece splits the narrative into four Ndefs (drone, pulse argument, filtered-noise storm, frozen waiter bell), which is a clear but literal mapping. The DSP is basic: SinOsc, Pulse, and BPF noise with FreeVerb and Comb. The Pbindef-to-\set routing uses midinote with a freq arg and a constant t_trig, so triggers and pitch likely won't work as intended. Nothing evolves beyond static loops and slow LFOs, so there is no real arc, climax, or silence-as-weight.
- **Round 02 (`COMPOSE`)**: The palette is varied (noise-click escapements, DynKlank bells, FM gear grind, detuned beating sines), and the cued Tdef gives a clear arc from a single workshop tone through a dense swarm to a single clock and a final bell. Technical craft is shaky, though. The `\wet10` parameter is never actually used by the FreeVerb2 filter, so the wet control does nothing. The Ndef mixing of the ~synthBus is fragile, and the limiter is added to ServerTree and also started manually. The prompt's 'slightly misaligned times' is only loosely expressed through random rhythm choices rather than true phase-drifting clocks, so the micro-phasing concept is underexploited.
- **Round 03 (`DESIGN`)**: This is a generic randomized subtractive fallback with detuned saw/pulse, PWM, RLPF and a comb/reverb chain. It never addresses the prompt's modular synth or Lissajous imagery, for example through phase-related ratios or XY-style rotating modulation. The code is also fragile: the Splay outputs are then indexed as sig[0]/sig[1] after summing, the \filter slot wet settings and the \set Pbindef slot are questionable, and both compilation checks failed. Its form is a static looping pattern with no real arc.
- **Round 04 (`GENERATE`)**: The three layers (metallic Ringz gungas, resonant congo drums with a sub sine, FM bell rosary) are idiomatic and map well to the prompt's percussion imagery. Technical issues weaken it: `\wet10` is set while the filter is a plain function, Pbindef is placed in a `\set` slot, and `K2A` triggers are unreliable. There is no development, climax, or evolving form, only looped patterns, so audacity and arcs stay modest.
