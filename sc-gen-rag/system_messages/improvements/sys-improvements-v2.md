### Past mistakes and lessons:

#### 1. DSP & Synthesis
* **DynKlank Formatting:** `specificationsArrayRef` must be a `Ref` containing exactly three sub-arrays: `Ref(#[ [freqs], [amps], [rings] ])`. Use `decayscale`, not `rq` or `decay`.
* **Physical Modeling:** Use `Pluck.ar` with a short noise burst for excitation (do not use `K2A.ar`). Delay time is `1/freq`. Material damping is `coef`.
* **Buffer Overruns:** When using `CombL/CombC` for physical modeling, always clip dynamic delay times slightly below the maximum buffer size (e.g., `freq.reciprocal.clip(0.0001, maxBuffer)`).
* **Feedback Loops:** Never inject manual DC offsets (`+ 1e-10`) into delay networks, as they infinitely accumulate. Use `LeakDC.ar` before non-linear clipping stages.
* **Multichannel Preservation:** To apply a parameter array to a multichannel signal without collapsing to mono, iterate with `.collect` before summing: `[0.5, 1.0].collect({|m| BPF.ar(sig, freq*m) }).sum`.
* **Obsolete UGens:** `Denormal.ar` is not in vanilla SC. Rely on native CPU Flush-to-Zero.

#### 2. Patterns & Live Sequencing
* **Pattern Structures:** Never apply `.flat` to Pattern objects (`Pseq`, `Pn`). They inherently yield flattened streams.
* **Live Tweaking vs. Sequencing:** Do not use `.set` on a parameter currently driven by a `Pbindef`; it overrides the stream. Instead, use pattern math, sequence alternative keys (`\midinote`), or build dedicated offset arguments (`\freqMult`) in the SynthDef.
* **Exponential Randomization:** Use `Pexprand`. `Pexprange` does not exist as a Pattern class.

#### 3. JITLib (Ndefs)
* **Filter Application:** `filter` is an instance method (`Ndef(\name).filter`). It expects a function describing the filter logic, not a pre-processed UGen.
* **Auto-Generated Controls & NamedControl Errors:** When using the `\filter ->` role in a slot (e.g., `Ndef(\mix)[10] = \filter -> { |in| ... }`), JITLib automatically wraps it in a wet/dry crossfader. **Never** manually declare a wet control (e.g., `var wet = \wet10.kr(0)`) inside this function. Doing so competes with JITLib's hidden automation and triggers a fatal `NamedControl: cannot have more than one set of default values` error. Just return the 100% processed (wet) signal.
* **External Automation of Hidden Controls:** Because JITLib auto-generates the crossfader, the parameter name (e.g., `\wet10` for slot 10) is implicitly available. You can immediately automate it externally via `Ndef(\name).set(\wet10, val)` or sequence it in a `Tdef`/`Pbind` without having to define it in your DSP code.
* **FFT & LocalBuf Race Conditions:** Never use `LocalBuf` for FFT chains inside dynamic JITLib contexts (like `Ndef` filters). When JITLib crossfades or rebuilds an effect under the hood, it creates temporary duplicate synths. `LocalBuf` struggles with this rapid reallocation, resulting in "Buffer UGen: no buffer data" warnings and audio dropouts. Always pre-allocate permanent buffers on the server (e.g., `~fftBufL = Buffer.alloc(s, 2048)`) during boot and reference them globally.
* **Node Instantiation Latency (FAILURE IN SERVER /n_set):** The Language (client) evaluates code faster than the Server can instantiate audio nodes. Sending a `.set` command immediately after `Ndef(\name).play` will result in a "Node not found" error because the node doesn't exist yet. Always insert an `s.sync` between `.play` and any subsequent `.set` commands to guarantee the architecture is ready. Furthermore, set `s.latency = 0.2` in your boot sequence to stabilize scheduled `Tdef` and `Pbindef` triggers.
* **Ndef (and NodeProxy) in SuperCollider lacks a native .fadeOut() method, resulting in a DoesNotUnderstandError when called during the sequence. The Fix: Replaced .fadeOut(time) calls with a two-step amplitude crossfade: explicitly set the fade duration using .fadeTime = time, followed by .xset(\amp, 0) to smoothly silence the node without destroying it.

#### 4. Syntax & Core Language
* **Dynamic vs. Static Arrays:** Use standard Arrays `[...]` when elements involve UGen calculations. Literal Arrays `#[...]` are strictly for static constants and will crash if used dynamically.
* **Argument Defaults:** Always parenthesize negative default values in functions (e.g., `|pan=(-0.8)|`) to prevent `BINOP` syntax errors.
* **Variable Scope:** All `var` declarations must be placed at the absolute top of a scope block before any executed code.
* **Bus Mapping:** Always append `.asMap` when routing a `Bus.control` to a Synth argument upon instantiation. Passing the bus object directly sends its raw integer ID, blowing out parameters.
* **Execution Blocks:** Inside an executing function (like `waitForBoot`), every statement (even those wrapped in parentheses) must terminate with a semicolon.

#### 5. GUI & UI Components
* **Widget Assignments:** Always verify values are `.notNil` before assigning them to GUI widgets to prevent `.asFloat` crashes.
* **Window Bounds:** Never hardcode absolute UI dimensions. Use `Window.availableBounds`, dynamically cap the height, center the window, and set `scroll: true`.