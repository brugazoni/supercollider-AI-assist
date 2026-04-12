

s.boot;

// 1. Initialize the MIDI client
MIDIClient.init;

// 2. Find specific IN and OUT devices dynamically (with safe fallbacks)
(
~targetIn = MIDIClient.sources.detect { |src| src.device.contains("loopMIDI Port") } ?? { MIDIClient.sources[0] };
~targetOut = MIDIClient.destinations.detect { |dest| dest.device.contains("loopMIDI Port") } ?? { MIDIClient.destinations[0] };

~outIndex = MIDIClient.destinations.indexOf(~targetOut);
)

// 3. Connect MIDI In ONLY to that device's port
(
if(~targetIn.notNil) {
	MIDIIn.connect(0, ~targetIn);
	"MIDI IN connected successfully to: ".post; ~targetIn.device.postln;
} {
	"Warning: MIDI IN device not found!".warn;
};
)

// 4. Connect MIDI Out for the external synthesizer sequence
(
if(~outIndex.notNil) {
	~mOut = MIDIOut(~outIndex);
	"MIDI OUT connected successfully.".postln;
} {
	"Warning: MIDI OUT device not found!".warn;
};
)

(
// Get the UID safely to lock incoming MIDIdefs
~myUid = if(~targetIn.notNil) { ~targetIn.uid } { nil };

// 1. Setup global control buses for dynamic CC modulation
~fmIndexBus = Bus.control(s, 1);
~fmIndexBus.set(1.5); // Default FM Index

~cutoffBus = Bus.control(s, 1);
~cutoffBus.set(1200); // Default Subtractive Cutoff

// 2. Create an array to keep track of playing polyphonic synths
~notes = Array.newClear(128);

// 3. Global CC Controls (Mod Wheel and Filter Cutoff)
MIDIdef.cc(\chimangoCC, {
	|val, num|
	// CC 1 (Mod Wheel) controls the intelligence/complexity of the FM layer
	if(num == 1) { ~fmIndexBus.set(val.linexp(0, 127, 0.1, 8.0)) };

	// CC 74 controls the earthy subtractive filter cutoff
	if(num == 74) { ~cutoffBus.set(val.linexp(0, 127, 200, 6000)) };
}, srcID: ~myUid);

// 4. Note ON: Instantiate the hybrid synth and store it
MIDIdef.noteOn(\chimangoOn,
	{
		|val, num, chan, src|

		// Safety check: release existing note if re-triggered
		if(~notes[num].notNil) { ~notes[num].set(\gate, 0) };

		~notes[num] = {
			arg fmIndex = 1.5, cutoff = 1200, gate = 1, freqMult = 1, ampMod = 1;
			var freq, amp, env, lagIndex, lagCutoff, mod, fm, sub, mix, panned, echo, verb, out;

			freq = num.midicps * freqMult;
			amp = val.linexp(1, 127, 0.01, 0.25) * ampMod;

			// Lag to prevent CC zipper noise
			lagIndex = Lag.kr(fmIndex, 0.1);
			lagCutoff = Lag.kr(cutoff, 0.1);

			// Raptor-like sharp attack and soaring release
			env = EnvGen.ar(Env.adsr(attackTime: 0.05, decayTime: 0.2, sustainLevel: 0.6, releaseTime: 1.2), gate, doneAction: 2);

			// --- The Raptor's Cry (FM Layer) ---
			// High-frequency vocal intelligence using pure SinOsc
			mod = SinOsc.ar(freq * 2.01) * freq * lagIndex;
			fm = SinOsc.ar(freq + mod);

			// --- Earthy Plumage (Subtractive Layer) ---
			// Warm, grounded sawtooth wave, passed through an RLPF
			sub = Saw.ar(freq * 0.5);
			sub = RLPF.ar(sub, lagCutoff, 0.3);

			// Mix the two distinct layers (FM bypasses the filter)
			mix = (fm * 0.5) + (sub * 0.5);

			// Stereo placement
			panned = Pan2.ar(mix * env * amp, 0);

			// --- Post-Filter Effects (Simulating Puerto Varas environments) ---
			// Spatial echoing
			echo = CombL.ar(panned, 0.3, 0.15, 2.5);

			// Atmospheric depth (100% wet internally)
			verb = FreeVerb.ar(panned + (echo * 0.4), 1.0, 0.85, 0.2);

			// Dynamically mix the dry/echo signal with the wet atmospheric reverb
			out = XFade2.ar(panned + (echo * 0.3), verb, -0.3);

			out;

		}.play(args: [\fmIndex, ~fmIndexBus.asMap, \cutoff, ~cutoffBus.asMap]);
	}, srcID: ~myUid
);

// 5. Note OFF: Find the active synth and release it gracefully
MIDIdef.noteOff(\chimangoOff,
	{
		|val, num, chan, src|
		if(~notes[num].notNil) {
			~notes[num].set(\gate, 0);
			~notes[num] = nil;
		}
	}, srcID: ~myUid
);
)

// ==========================================
// SEQUENCER (MIDI OUT to External Synth)
// ==========================================

(
// Algorithmic sequencer driving an external pad/noise synth
// Simulates the intelligent, erratic foraging of the chimango caracara
Pbindef(\chimangoSeq,
	\type, \midi,
	\midiout, ~mOut,
	\chan, 0,
	\midicmd, \noteOn,

	// Pitch: Intelligent, calculated problem-solving movements over a constrained scale
	\midinote, Pwalk(
		[55, 57, 58, 60, 62, 65, 67, 69], // Constrained scale array
		Pseq([1, 2, -1, 1, -2, 3, -1], inf), // Evolving step pattern
		1 // Direction
	),

	// Velocity: Dynamic interaction
	\amp, Pexprand(0.4, 0.85, inf),

	// Rhythm: Hesitant, probing durations mimicking a scavenging bird
	\dur, Pwrand(
		[0.125, 0.25, 0.5, 1.0],
		[0.4, 0.3, 0.2, 0.1], // Higher probability for quick movements, occasional pauses
		inf
	),

	// Legato controls the MIDI note length relative to \dur
	\legato, Pwhite(0.5, 1.2, inf)
).play(quant: 1);
)

// Live Coding Commands (Execute individually to interact):
// Pbindef(\chimangoSeq).stop;
// Pbindef(\chimangoSeq).play;
// Pbindef(\chimangoSeq, \dur, Pwrand([0.0625, 0.125, 0.5], [0.5, 0.3, 0.2], inf)); // Frantic insect hunting