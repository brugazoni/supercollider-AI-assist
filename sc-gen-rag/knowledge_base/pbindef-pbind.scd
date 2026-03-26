/* =============================================================================
   SUPERCOLLIDER NDEF KNOWLEDGE BASE: SEQUENCING (PBIND, PDEF, PBINDEF)
   Target: Live Coding, JITLib, & Algorithmic Composition
   Concepts: Event Streams, Rests, Proxies, and \type, \set Routing
   =============================================================================
*/

// =============================================================================
// 0. SETUP & THE "ALWAYS-ON" SOUND SOURCES
// =============================================================================
(
s.options.numBuffers = 1024 * 4;
s.options.memSize = 8192 * 32;

s.waitForBoot({
	"Server Booted. Initializing Pattern Environment...".postln;

	if(Ndef.all[s].isNil) { Ndef.all.put(s, ProxySpace.new(s)) };

	// SET GLOBAL TEMPO (120 BPM = 2 beats per second)
	~t = TempoClock.default;
	~t.tempo = 120/60;

	Ndef.all[s].quant = 1.0;
	Ndef.all[s].fadeTime = 0; // Instant snapping for percussive synths

	// --- SYNTH A: FM Pluck ---
	Ndef(\fmPluck, {
		var freq = \freq.kr(440);
		var modIdx = \modIdx.kr(2);
		var pan = \pan.kr(0);

		// CRITICAL: t_trig (trigger) instead of gate
		var t_trig = \t_trig.tr(1);

		// CRITICAL: doneAction: 0 keeps the synth alive forever!
		var env = EnvGen.kr(Env.perc(0.01, 0.3), t_trig, doneAction: 0);

		var mod = SinOsc.ar(freq * 2) * (freq * modIdx * env);
		var car = SinOsc.ar(freq + mod);

		Pan2.ar(car * env * \amp.kr(0.4), pan);
	}).play;

	// --- SYNTH B: Sub Bass ---
	Ndef(\subBass, {
		var freq = \freq.kr(55);
		var t_trig = \t_trig.tr(1);
		var env = EnvGen.kr(Env.perc(0.05, 0.5), t_trig, doneAction: 0);

		var sig = SinOsc.ar(freq) + Pulse.ar(freq * 0.5, 0.5, 0.5);
		sig = LPF.ar(sig, 400);

		Pan2.ar(sig * env * \amp.kr(0.6), 0);
	}).play;

	"Pattern Environment Ready. Synths are running silently, awaiting triggers.".postln;
});
)


// =============================================================================
// 1. THE FOUNDATION: PBIND & RESTS
// Best for: Generating sequences of values to control a running Ndef.
// =============================================================================

(
~seqBasic = Pbind(
	\type, \set, // Tells the sequencer to update an existing synth
	\id, Pfunc({ Ndef(\fmPluck).group }), // Safely targets the Ndef
	\args, #[\freq, \t_trig, \modIdx, \pan], // MUST declare which args to send

	\dur, 0.25, // 16th notes

	// \degree automatically calculates frequencies based on a major scale.
	// We use the Symbol (\) to insert rests directly into the melody.
	\degree, Pseq([
		0, 4, \, 5, 0, 7, \, 4,
		5, 0, 7, \, 8, \, \, \
	], inf),

	\modIdx, Pwhite(1.0, 5.0, inf), // Randomize FM brightness
	\pan, Pseq([-0.5, 0.5], inf),   // Ping-pong pan
	\t_trig, 1 // Fire the trigger envelope on every non-rest note
).play(~t);
)

// Run this to stop the sequence:
~seqBasic.stop;


// =============================================================================
// 2. LIMITING SEQUENCES (Pfin & Pfindur)
// Best for: Fills, turnarounds, or sequences that should only play X times.
// =============================================================================

(
~fillPattern = Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\fmPluck).group }),
	\args, #[\freq, \t_trig, \modIdx],
	\dur, 1/8, // 32nd notes (very fast)
	\degree, Pseries(0, 1, inf), // Ascend by 1 scale degree every note
	\modIdx, 8,
	\t_trig, 1
);

// Pfin limits by NUMBER OF EVENTS (plays exactly 16 notes, then stops)
~fillPlayer = Pfin(16, ~fillPattern).play(~t);

// Alternatively, Pfindur limits by BEATS (plays for exactly 2 beats, then stops)
// ~fillPlayer = Pfindur(2, ~fillPattern).play(~t);
)


// =============================================================================
// 3. PDEF: THE PATTERN PROXY (Live Swapping)
// Best for: Swapping entirely different patterns on the fly without losing the beat.
// =============================================================================

(
Pdef(\mainGroove, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\fmPluck).group }),
	\args, #[\freq, \t_trig],
	\dur, 0.25,
	\degree, Pseq([0, 2, 4], inf),
	\t_trig, 1
)).quant_(4); // Quantize ensures swaps happen exactly on the downbeat

Pdef(\mainGroove).play(~t);
)

// LIVE SWAPPING (Run this block while the music is playing to hear it change):
(
Pdef(\mainGroove, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\fmPluck).group }),
	\args, #[\freq, \t_trig, \modIdx],
	\dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
	\degree, Pxrand([-4, -2, 0, 2, 3], inf), // Random, no immediate repeats
	\modIdx, Pseq([8, 2, 2, 5, 2], inf),
	\t_trig, 1
));
)


// =============================================================================
// 4. PBINDEF: THE LIVE CODING WORKHORSE (Key-by-Key Editing)
// Best for: Tweaking individual parameters of a running sequence.
// =============================================================================

// Stop previous patterns
Pdef(\mainGroove).stop;

(
// Initialize the Pbindef
Pbindef(\liveTweaks,
	\type, \set,
	\id, Pfunc({ Ndef(\fmPluck).group }),
	\args, #[\freq, \t_trig, \pan, \modIdx],

	\dur, 0.25,
	\degree, Pseq([0, 1, 2, 4, 5], inf),
	\modIdx, 2,
	\t_trig, 1
).play(~t, quant: 4);
)

// --- LIVE PERFORMANCE EXAMPLES (Run line by line to tweak the live sound) ---

// 1. Randomize the notes
Pbindef(\liveTweaks, \degree, Prand([0, 1, 3.1, 4.1, 5], inf));

// 2. Change the rhythm to be fast and chaotic
Pbindef(\liveTweaks, \dur, Pexprand(0.05, 0.2, inf));

// 3. Modulate the Pan
Pbindef(\liveTweaks, \pan, Pwhite(-0.8, 0.8, inf));

// 4. IMPORTANT: Overriding Pitch Models
// Pbindef remembers old keys. If you set \freq directly, it overrides \degree.
Pbindef(\liveTweaks, \freq, Pexprand(500, 1200, inf));

// 5. To go back to \degree, you MUST set \freq to nil!
Pbindef(\liveTweaks, \freq, nil, \degree, Pwhite(0, 7, inf), \dur, 0.25);

// Stop it when done
Pbindef(\liveTweaks).stop;


// =============================================================================
// 5. Pdefn: THE VALUE PROXY (Shared Data)
// Best for: Sharing a single melody or rhythm across multiple different synths.
// =============================================================================

// Define a shared melody and rhythm
Pdefn(\sharedMelody, Pseq([0, 4, 1, 5], inf));
Pdefn(\sharedRhythm, Pseq([0.25, 0.25, 0.5], inf));

(
// Assign it to Synth A (Pluck)
Pdef(\pluckPart, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\fmPluck).group }),
	\args, #[\freq, \t_trig],
	\dur, Pdefn(\sharedRhythm),
	\degree, Pdefn(\sharedMelody),
	\t_trig, 1
)).play(~t);

// Assign it to Synth B (Sub Bass)
Pdef(\bassPart, Pbind(
	\type, \set,
	\id, Pfunc({ Ndef(\subBass).group }),
	\args, #[\freq, \t_trig],
	\dur, Pdefn(\sharedRhythm),
	// Same melody, but pitched down an octave (-7 scale degrees)
	\degree, Pdefn(\sharedMelody) - 7,
	\t_trig, 1
)).play(~t);
)

// LIVE TWEAK: Change both synths instantly by updating the Pdefn
Pdefn(\sharedMelody, Pseq([-3, -2, 0, 2, 4], inf));
Pdefn(\sharedRhythm, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf));


// =============================================================================
// 6. CHAINING & PARALLEL PATTERNS (Pseq, Ppar, Ptpar)
// Best for: Building song structures and multi-layered sequences.
// =============================================================================

(
Pdef(\pluckPart).stop; Pdef(\bassPart).stop; // Clear the stage

// Define two distinct musical phrases for the Pluck
~phraseA = Pbind(\type, \set, \id, Pfunc({ Ndef(\fmPluck).group }), \args, #[\freq, \t_trig],
	\dur, 1/4, \degree, Pseq([0, 2, 3, 5], 1), \t_trig, 1);

~phraseB = Pbind(\type, \set, \id, Pfunc({ Ndef(\fmPluck).group }), \args, #[\freq, \t_trig],
	\dur, 1/4, \degree, Pseq([7, 5, 4, 2], 1), \t_trig, 1);

// Define a Bass phrase
~bassPhrase = Pbind(\type, \set, \id, Pfunc({ Ndef(\subBass).group }), \args, #[\freq, \t_trig],
	\dur, 1/2, \degree, Pseq([-7, -7], 1), \t_trig, 1);

// --- PSEQ: Play phrases sequentially ---
// Plays Phrase A, then Phrase B, looping infinitely
~songStructure = Pseq([~phraseA, ~phraseB], inf);

// --- PPAR: Play patterns simultaneously ---
// Plays the Pluck song structure AND the Bass phrase at the same time
~fullBand = Ppar([
	~songStructure,
	Pseq([~bassPhrase], inf) // Loop the bass phrase to keep up
], inf);

~conductor = ~fullBand.play(~t);
)

~conductor.stop;