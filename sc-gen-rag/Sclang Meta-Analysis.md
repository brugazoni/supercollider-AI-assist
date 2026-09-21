# Sclang Meta-Analysis: Generated Code Features & Vocabulary

**Target Project**: SC-Gen-RAG (SuperCollider LLM Code Generation)
**Purpose**: This documentation compiles a comprehensive list of SuperCollider classes, methods, and architectural features used throughout the AI-generated `.scd` files in this project. It serves as a grounded reference for LLMs generating SuperCollider code, providing concrete evidence of which features are successfully utilized and thus mitigating hallucinations of non-existent or unsupported SC features.

---

## 1. Architectural Context (From Scratchpad)

The generated SuperCollider code fundamentally relies on two mutually exclusive architectures. LLMs MUST adhere strictly to the rules of whichever architecture is chosen, as mixing them leads to runtime errors or dropped voices.

### Architecture A: JITLib (Ndef / Pbindef)
- **Primary Use**: Live coding, incremental composition, timeline composition.
- **Key Classes**: `Ndef`, `Pbindef`, `Tdef`.
- **Rules**:
  - Exclusively uses `Ndef` for synthesis and routing. 
  - Exclusively uses `Pbindef` mapped to `Ndef[1]` for pattern sequencing.
  - Envelope triggering uses `t_trig` (e.g., `Env.perc` multiplied by `amp`); NEVER use `Env.asr`/`Env.adsr` or `doneAction: 2`.
  - Effects are routed via slots `Ndef(\name)[10]`, `[11]`, etc. Crossfading is handled via `.xset(\wet10, val)`.
  - NEVER use the `<<<>` operator.

### Architecture B: SynthDef (Pre-compiled Synths)
- **Primary Use**: Multi-zone MIDI/OSC synthesizers and design pipelines.
- **Key Classes**: `SynthDef`, `Synth`, `MIDIdef`, `OSCdef`, `Group`, `Bus`.
- **Rules**:
  - Uses pre-compiled `SynthDef` and instantiates `Synth` objects.
  - Voice management relies on `doneAction: 2` and ADSR envelopes.
  - Group-based execution order (`synthGroup -> fxGroup -> masterGroup`).
  - Audio bus routing between groups.
  - Driven by MIDI/OSC (no pattern sequencing).

---

## 2. Comprehensive Vocabulary of Used Classes

Based on static analysis of 87 AI-generated `.scd` files within `sc-gen-rag/sc-files/` and `sc-gen-rag/knowledge_base/`, here is the comprehensive list of SuperCollider classes successfully utilized by the LLM (ordered by frequency):

### Core Architecture & Routing
- `Ndef` (3061) - Backbone of JITLib architecture.
- `Pbindef` (829) - Backbone of pattern sequencing.
- `Out` (253), `In` (209), `Bus` (149), `ReplaceOut` (31), `LocalIn` (8), `LocalOut` (8) - Signal routing.
- `SynthDef` (252), `Synth` (210) - Pre-compiled architecture.
- `Group` (62), `RootNode` (62), `ServerTree` (64), `Server` (24) - Node management.

### Pattern & Sequencing (Event Streams)
- `Pseq` (400)
- `Pwhite` (266), `Pwrand` (54), `Pexprand` (44), `Prand` (13), `Pxrand` (3)
- `Pfunc` (55), `Pkey` (21)
- `Pbind` (43), `Pn` (40), `Pseg` (9), `Pdefn` (8), `Pgeom` (7), `Ptuple` (4), `Pshuf` (3)

### Oscillators & Noise Generators
- `SinOsc` (424), `Saw` (85), `Pulse` (71), `LFSaw` (11), `LFPulse` (11), `LFTri` (18)
- `WhiteNoise` (81), `PinkNoise` (74), `BrownNoise` (14), `Dust` (40), `Crackle` (5)
- `PMOsc` (11), `COsc` (6), `VOsc` (4), `Blip` (3), `SyncSaw` (3), `Formant` (4)
- `Impulse` (20), `Phasor` (6), `LFNoise1` (49), `LFNoise2` (23), `LFNoise0` (8)

### Envelopes & Control Rates
- `Env` (416), `EnvGen` (414)
- `Line` (6), `XLine` (13)
- `ControlSpec` (127), `CC` (77)

### Filters & EQs
- `RLPF` (125), `HPF` (110), `LPF` (94), `BPF` (74), `RHPF` (3)
- `MoogFF` (24), `BMoog` (4)
- `Ringz` (17), `Klank` (3), `DynKlank` (31), `Resonz` (14), `Formlet` (0)
- `BPeakEQ` (5)

### Spatialization & Panning
- `Pan2` (284), `Pan` (14), `Balance2` (25)
- `Splay` (45)

### Effects (Reverbs, Delays, Dynamics)
- **Reverb**: `FreeVerb2` (47), `FreeVerb` (44), `GVerb` (20)
- **Delay**: `CombL` (42), `CombC` (35), `DelayC` (21), `DelayL` (3), `AllpassC` (5)
- **Dynamics/Math**: `Limiter` (61), `Compander` (8), `LeakDC` (28), `Mix` (31), `Fold` (20), `Lag` (26), `Decay` (11), `Decay2` (5), `Latch` (3)

### Buffers & Granular
- `Buffer` (40), `BufFrames` (6), `BufRateScale` (4), `SampleRate` (4), `LocalBuf` (4)
- `PlayBuf` (0), `TGrains` (3), `GrainBuf` (7), `GrainSin` (4), `GrainIn` (3)

### Timing & Threading
- `Tdef` (86), `Routine` (18), `AppClock` (14), `TempoClock` (7)
- `Cue` (294), `Score` (28)

### GUI & Interface
- `Color` (530), `EZKnob` (162), `EZSlider` (107), `Rect` (75), `StaticText` (55), `CompositeView` (51), `FlowLayout` (42), `Font` (39), `Button` (27), `Window` (16), `EZRanger` (12)

### MIDI & OSC
- `MIDIdef` (61), `MIDIClient` (30), `MIDIIn` (12), `OSC` (23), `OSCdef` (23), `NetAddr` (5)

---

## 3. Comprehensive Vocabulary of Used Methods

The following methods are widely and successfully used within the LLM-generated SC code (ordered by frequency):

- **UGen Rates**: `.ar` (2867), `.kr` (853), `.ir` (6)
- **Node/Proxy Control**: `.set` (892), `.xset` (686), `.play` (546), `.stop` (271), `.free` (220), `.clear` (207), `.fadeTime` (449), `.add` (338), `.freeAll` (23)
- **Control Routing**: `.asMap` (674), `.control` (36)
- **Math/Mapping**: `.value` (717), `.range` (109), `.exprange` (47), `.linexp` (94), `.linlin` (58), `.clip` (54), `.clip2` (5), `.tanh` (54), `.midicps` (48), `.midiratio` (5), `.dbamp` (18), `.abs` (3), `.pow` (9), `.reciprocal` (16), `.sqrt` (7), `.neg` (6), `.wrap` (6), `.sum` (76)
- **Envelopes**: `.perc` (279), `.adsr` (60), `.asr` (25)
- **Collections/Iterators**: `.do` (325), `.removeAll` (74), `.keysValuesDo` (56), `.contains` (55), `.all` (44), `.fill` (17), `.collect` (13), `.detect` (14), `.put` (11), `.choose` (5)
- **Timing/Sync**: `.wait` (477), `.sync` (135), `.waitForBoot` (57), `.defer` (8)
- **Debugging/Type Conv**: `.postln` (562), `.post` (18), `.warn` (14), `.asSymbol` (183), `.asString` (60), `.asFloat` (9), `.asInteger` (23)

---

## 4. Most Common Argument Symbols (Feature Tokens)

The following `\symbols` are the most heavily utilized for parameter routing in `Ndef` and `SynthDef` definitions, reflecting the standard interface the LLM expects to build:

- **Volume/Pan**: `\amp` (766), `\pan` (205), `\vol` (24)
- **Frequency**: `\freq` (529), `\midinote` (28), `\detune` (18), `\pitch` (11)
- **Timing/Triggers**: `\dur` (453), `\t_trig` (280), `\gate` (169), `\legato` (14), `\rate` (43)
- **Routing**: `\out` (246), `\in` (54), `\master` (153)
- **Envelopes**: `\atk` (82), `\decay` (65), `\sus` (64), `\dec` (60), `\rls` (57), `\rel` (40)
- **Effects & JITLib Routing**: `\wet10` (246), `\wet11` (116), `\wet12` (35), `\wet20` (33)
- **Filters**: `\cutoff` (72), `\lpf` (64), `\hpf` (57), `\rq` (98)
- **Modulation**: `\modIndex` (63), `\modFreq` (27), `\fmIndex` (20)
- **Misc**: `\masterMix` (230), `\safetyLimiter` (90), `\degree` (84), `\scale` (38), `\drive` (34), `\delayTime` (47), `\verbMix` (49), `\verbDecay` (47)

---

## 5. Key Hallucination Pitfalls to Avoid (Derived from Analysis & System Instructions)

By relying *only* on the vocabulary proven above, the LLM avoids several classic SC hallucinations:
1. **Lethal Finite Pattern Trap**: Never wrap finite generators (like `Pseq([1,2,3], 1)`) in `Pn(..., inf)`. The data proves `Pseq(..., inf)` is the supported infinite looping paradigm.
2. **Envelope/Trigger Trap**: The vocabulary shows heavy reliance on `\t_trig` and `.perc`. Do NOT use `Env.asr`/`Env.adsr` mapped to `\t_trig` (they require a `\gate` which must eventually go to 0).
3. **Dead Delay Trap**: Delay networks explicitly rely on `CombL` and `CombC`. Using standard `DelayN`/`DelayC` without feedback paths usually results in flat, dead sounds.
4. **GVerb Phasing**: Note the reliance on `.sum` in the methods list. `GVerb.ar` expects a mono input; providing a stereo array causes phase cancellation. Always `.sum` stereo inputs before `GVerb`.
5. **No `doneAction: 2` in Ndefs**: The complete absence of `doneAction: 2` in the most common Ndef-driven architecture is critical. JITLib handles its own lifecycle.
