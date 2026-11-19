// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 3.8 Flash
// Model ID: openrouter:google/gemini-3.8-flash
// Date: 2026-11-12T00:44:46.005178+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: FIXED
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
// ARCHETYPE: Settling/Flashback (c) transitioning into an Intrinsic Limit (b)
// Narrative translation: Dry paper folds (delicate, obsessive explanation) amidst the suspended, 
// freezing weight of a room-temperature silence and an imminent Antarctic storm.

// 1. Map Folds: Thin, dry, geometric rustling and crisp transient creases (Buchla-style wavefolded FM clicks)
Ndef(\mapFold, { |freq=340, amp=0.18, pan=0, foldAmt=2.5, t_trig=0, rel=0.06|
	var trigAudio = K2A.ar(t_trig);
	var env = Decay2.ar(trigAudio, 0.002, rel);
	var mod = SinOsc.ar(freq * 3.7) * (freq * 1.8);
	var osc = SinOsc.ar(freq + mod);
	var folded = Fold.ar(osc * foldAmt, -0.6, 0.6);
	var crackle = HPF.ar(PinkNoise.ar, 3500) * Decay.ar(trigAudio, 0.015) * 1.2;
	var sig = LeakDC.ar((folded + crackle) * env);
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\mapFoldSeq,
	\dur, Pseq([0.25, 0.25, 0.125, 0.375, 0.5, 0.125, 0.125], inf),
	\freq, Pseq([280, 310, 420, 240, 560, 310, 390], inf),
	\foldAmt, Pwhite(1.8, 4.2, inf),
	\rel, Pwhite(0.04, 0.09, inf),
	\pan, Pseq([-0.4, 0.3, -0.1, 0.5, -0.6, 0.2], inf),
	\amp, Pwhite(0.12, 0.22, inf),
	\t_trig, 1
);

Ndef(\mapFold)[1] = \set -> Pbindef(\mapFoldSeq);

// 2. Suspended Wine & Antarctic Pressure: Low-frequency sub-rumble + frozen crystalline overtones
Ndef(\antarcticSilence, { |freq=48, amp=0.28, resCutoff=420, chillSpread=0.35|
	var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4);
	var air = BPF.ar(WhiteNoise.ar, [freq * 18, freq * 24.3], 0.02) * 12.0;
	var drone = Saw.ar([freq * 0.5, freq * 0.505]);
	var filtered = MoogFF.ar(drone, resCutoff + (SinOsc.kr(0.08).range(-40, 80)), 3.2) * 3.0;
	var sig = LeakDC.ar((sub * 0.8) + filtered.tanh + (air.sum * chillSpread));
	var pan = SinOsc.kr(0.05).range(-0.3, 0.3);
	// Fixed syntax error and ensured clean stereo output via Balance2
	if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan, amp) } { Pan2.ar(sig, pan, amp) };
}).play;

// Space and refrigeration: Subdued comb reflections simulating rigid glass and silence
Ndef(\antarcticSilence)[10] = \filter -> { |in|
	CombC.ar(in, 0.2, [0.073, 0.089], 2.2) * 0.4 + in;
};
Ndef(\antarcticSilence).set(\wet10, 0.35);

// Rollback commands:
// Pbindef(\mapFoldSeq).stop; Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); // Rollback: remove map fold
// Ndef(\antarcticSilence).fadeTime = 3; Ndef(\antarcticSilence).clear(3); // Rollback: remove silence drone
// Ndef(\antarcticSilence).set(\wet10, 0); // Rollback: disable silence comb
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: PASS
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
	var s = Server.default;
	~enableRecording = false;

	// Master audio bus for discrete synths
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// 1. Safety Limiter Setup
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;

	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter); });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// Fade out existing remnants gracefully
	if (Ndef(\mapFold).isPlaying) { Ndef(\mapFold).fadeTime = 2; Ndef(\mapFold).clear(2); };
	if (Pbindef(\mapFoldSeq).isPlaying) { Pbindef(\mapFoldSeq).stop; };
	if (Ndef(\antarcticSilence).isPlaying) { Ndef(\antarcticSilence).fadeTime = 3; Ndef(\antarcticSilence).clear(3); };

	// 2. Custom Discrete SynthDefs (Brass Gear Clicks, Pocket Escapements, Wooden Grandfather Pendulums)
	SynthDef(\brassEscapement, { |out=0, freq=2800, amp=0.15, pan=0, ring=0.03, drive=1.5|
		var click = Impulse.ar(0);
		var metal = PinkNoise.ar * Decay.ar(click, 0.003);
		var res = Ringz.ar(metal + (click * 0.6), [freq, freq * 1.62, freq * 2.71], [ring, ring * 0.7, ring * 0.4]).sum;
		var folded = Fold.ar(res * drive, -0.7, 0.7);
		var env = EnvGen.ar(Env.perc(0.0005, ring.max(0.02) * 1.5), doneAction: 2);
		var sig = LeakDC.ar(folded * env * amp * 3.5);
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	SynthDef(\frenchChime, { |out=0, freq=660, amp=0.12, pan=0, dur=2.5|
		var exciter = WhiteNoise.ar * EnvGen.ar(Env.perc(0.0002, 0.004));
		var modes = [1.0, 2.76, 5.4, 8.93];
		var freqs = freq * modes;
		var amps = [1.0, 0.5, 0.25, 0.1];
		var decays = [dur, dur * 0.7, dur * 0.4, dur * 0.2];
		var sig = DynKlank.ar(`[freqs, amps, decays], exciter);
		var env = EnvGen.ar(Env.perc(0.001, dur.max(0.1)), doneAction: 2);
		sig = Pan2.ar(sig * env * amp * 0.8, pan);
		Out.ar(out, sig);
	}).add;

	SynthDef(\pendulumThud, { |out=0, freq=75, amp=0.25, pan=0, bodyDecay=0.22|
		var click = Impulse.ar(0);
		var wood = Ringz.ar(click, [freq, freq * 2.1, freq * 3.6], [bodyDecay, bodyDecay * 0.4, bodyDecay * 0.2]).sum;
		var sub = SinOsc.ar(XLine.ar(freq * 1.5, freq * 0.6, 0.08)) * Decay2.ar(click, 0.005, bodyDecay);
		var env = EnvGen.ar(Env.perc(0.001, bodyDecay.max(0.05)), doneAction: 2);
		var sig = LeakDC.ar((wood * 0.8 + sub) * env * amp * 2.0);
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	s.sync;

	// 3. Continuous Textures (The Swarming Room & Breathing Mechanism)
	// Micro-phase clock swarm: 8 asynchronously detuned pulse oscillators simulating 200 tiny escapements
	Ndef(\clockSwarm, { |amp=0, baseTempo=3.2, drift=0.08, cut=4200|
		var rates = [1, 1.004, 0.993, 1.018, 0.985, 1.025, 0.978, 1.012] * baseTempo;
		var pulses = rates.collect { |rate, i|
			var tr = Impulse.ar(rate + LFNoise1.kr(0.2).range(drift.neg, drift));
			var snap = Decay.ar(tr, 0.003) * WhiteNoise.ar;
			var ping = Ringz.ar(snap, 1800 + (i * 340), 0.02);
			Pan2.ar(ping, (i / 3.5) - 1.0);
		}.sum;
		var sig = HPF.ar(pulses, 400);
		sig = LPF.ar(sig, cut);
		sig * amp;
	});

	// The living organism: "o próprio respirar do tempo" (Slow bellows of brass and resonant pendulum chambers)
	Ndef(\timeBreath, { |amp=0, swellFreq=0.12, warmth=180|
		var lfo = SinOsc.kr(swellFreq).range(0.2, 1.0);
		var sub = SinOsc.ar(warmth * 0.5) + (SinOsc.ar(warmth) * 0.4);
		var friction = BPF.ar(PinkNoise.ar, warmth * 4 * lfo, 0.08) * 1.5;
		var air = (friction + (sub * 0.5)) * lfo;
		var stereoAir = Pan2.ar(air, SinOsc.kr(swellFreq * 0.5).range(-0.4, 0.4));
		LeakDC.ar(stereoAir) * amp;
	});

	// Master Mixer & Shared Acoustic Chamber
	Ndef(\masterMix, {
		var busIn = In.ar(~synthBus, 2);
		var swarm = Ndef.ar(\clockSwarm, 2);
		var breath = Ndef.ar(\timeBreath, 2);
		var mix = busIn + swarm + breath;
		mix;
	});

	// Slot 10: French workshop acoustic reverb (narrow, highly reflective stone and wood room)
	Ndef(\masterMix)[10] = \filter -> { |in|
		FreeVerb2.ar(in[0], in[1], 1.0, 0.65, 0.35);
	};
	Ndef(\masterMix).set(\wet10, 0.18);

	// Slot 11: Metallic gear resonance delay
	Ndef(\masterMix)[11] = \filter -> { |in|
		CombC.ar(in, 0.25, [0.083, 0.114], 1.2) * 0.6;
	};
	Ndef(\masterMix).set(\wet11, 0.0);

	Ndef(\masterMix).play;
	s.sync;

	// 4. Chronological Score Routine
	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - [CUE 1: The Narrow Workshop on Santa Efigênia - Solitary escapement]".postln;

		// Solitary pocket chronometer ticking in the dark
		Pbindef(\pocketWatch,
			\instrument, \brassEscapement,
			\dur, 0.5,
			\freq, Pseq([3400, 3100], inf),
			\ring, 0.015,
			\drive, 1.2,
			\pan, -0.2,
			\amp, 0.16,
			\out, ~synthBus
		).play;

		4.do { |i|
			Pbindef(\pocketWatch, \dur, 0.5 + (i * 0.003));
			1.5.wait;
		};

		"0:06 - [CUE 2: The French Chimes stir in mismatched intervals]".postln;
		Pbindef(\chimes,
			\instrument, \frenchChime,
			\dur, Pseq([3.0, 2.5, 4.0, 1.5, 2.0], inf),
			\freq, Pseq([523.25, 659.25, 783.99, 587.33, 880.0], inf),
			\durEnv, Pwhite(1.8, 3.2, inf),
			\pan, Pwhite(-0.7, 0.7, inf),
			\amp, 0.11,
			\out, ~synthBus
		).play;

		// Grandfather pendulum thud anchors the polyrhythm
		Pbindef(\heavyPendulum,
			\instrument, \pendulumThud,
			\dur, 1.0,
			\freq, Pseq([68, 62], inf),
			\bodyDecay, 0.3,
			\pan, 0.1,
			\amp, 0.28,
			\out, ~synthBus
		).play;

		4.do { |i|
			Pbindef(\pocketWatch, \freq, Pseq([3400 + (i * 80), 3100 - (i * 40)], inf));
			2.0.wait;
		};

		"0:14 - [CUE 3: The 200 Clocks Awaken - Swarm of microscopic defasagens]".postln;
		Ndef(\clockSwarm).fadeTime = 4;
		Ndef(\clockSwarm).xset(\amp, 0.32, \baseTempo, 3.6, \drift, 0.12);
		Ndef(\masterMix).set(\wet11, 0.22); // Add subtle metallic reflections

		// Rapid off-beat escapement cluster
		Pbindef(\brassCluster,
			\instrument, \brassEscapement,
			\dur, Pseq([0.166, 0.167, 0.25, 0.125, 0.125, 0.333], inf),
			\freq, Pwhite(2200, 4800, inf),
			\ring, Pwhite(0.01, 0.04, inf),
			\pan, Pwhite(-0.85, 0.85, inf),
			\amp, Pwhite(0.08, 0.18, inf),
			\out, ~synthBus
		).play;

		5.do { |i|
			Ndef(\clockSwarm).xset(\cut, 2500 + (i * 600), \drift, 0.08 + (i * 0.03));
			1.8.wait;
		};

		"0:23 - [CUE 4: Intrinsic Limit - Mechanical overdrive & Phase saturation]".postln;
		// Accelerate pendulums and chimes toward an unstable limit
		Pbindef(\heavyPendulum, \dur, 0.5, \freq, 85, \amp, 0.35);
		Pbindef(\chimes, \dur, Pseq([0.5, 0.75, 0.25, 0.5], inf), \amp, 0.16);
		Ndef(\clockSwarm).xset(\baseTempo, 5.8, \drift, 0.35, \amp, 0.45);
		Ndef(\masterMix).set(\wet10, 0.45, \wet11, 0.4);

		3.do { |i|
			Pbindef(\brassCluster, \freq, Pwhite(3000 + (i * 500), 5500 + (i * 500), inf));
			1.5.wait;
		};

		"0:28 - [CUE 5: Flashback/Settling - The Watchmaker shuts his eyes]".postln;
		// Abruptly cut away the clatter; let only the living breath remain
		Pbindef(\brassCluster).stop;
		Pbindef(\chimes).stop;
		Pbindef(\heavyPendulum, \dur, 2.0, \freq, 55, \amp, 0.2, \bodyDecay, 0.45);
		Ndef(\clockSwarm).fadeTime = 3;
		Ndef(\clockSwarm).xset(\amp, 0.05, \cut, 1200);

		// "O próprio respirar do tempo" emerges
		Ndef(\timeBreath).fadeTime = 4;
		Ndef(\timeBreath).xset(\amp, 0.38, \swellFreq, 0.15, \warmth, 140);
		Ndef(\masterMix).set(\wet10, 0.55, \wet11, 0.1);

		6.do { |i|
			Ndef(\timeBreath).xset(\warmth, 140 - (i * 8), \swellFreq, 0.12 - (i * 0.01));
			2.0.wait;
		};

		"0:40 - [CUE 6: Extrinsic Limit - Suspended breath and single fading tick]".postln;
		Pbindef(\heavyPendulum).stop;
		Ndef(\clockSwarm).fadeTime = 2;
		Ndef(\clockSwarm).xset(\amp, 0);

		// Solitary terminal tick echoing out
		Pbindef(\pocketWatch,
			\dur, 1.8,
			\freq, 2200,
			\ring, 0.08,
			\amp, 0.12,
			\pan, 0
		);

		4.do { |i|
			Ndef(\timeBreath).xset(\amp, 0.3 - (i * 0.07));
			1.5.wait;
		};

		Pbindef(\pocketWatch).stop;
		Ndef(\timeBreath).fadeTime = 2.5;
		Ndef(\timeBreath).clear(2.5);
		Ndef(\masterMix).fadeTime = 2.5;
		Ndef(\masterMix).clear(2.5);

		3.0.wait;

		// Clean up block-specific objects
		Pbindef(\pocketWatch).clear;
		Pbindef(\frenchChime).clear;
		Pbindef(\heavyPendulum).clear;
		Pbindef(\brassCluster).clear;
		Pbindef(\chimes).clear;
		Ndef(\clockSwarm).clear(0.5);

		"Score Complete: Workshop silenced.".postln;
		Tdef(\masterScore).stop;
	});

	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #139
// STATUS: FIXED
// PROMPT: olho do alto do morro e vejo a cidade estendida como um couro de boi secando ao sol do meio-dia. car...
// ============================================================
(
var screen, winW, winH;
~cc = (
    vol1: 1, pan1: 2, mute1: 3, hpf1: 4, lpf1: 5, rq1: 6, atk1: 7, rls1: 8, fxSubRoar: 9,
    vol2: 10, pan2: 11, mute2: 12, hpf2: 13, lpf2: 14, rq2: 15, atk2: 16, rls2: 17, fxFormigaPitched: 18,
    vol3: 19, pan3: 20, mute3: 21, hpf3: 22, lpf3: 23, rq3: 24, atk3: 25, rls3: 26, fxBicWind: 27,
    delMix: 28, delTime: 29, revMix: 30, revTime: 31, panic: 32
);

MIDIClient.init;
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        (src.device.asString ++ " " ++ src.name.asString).toLower.contains("midiin2").not
    }
} ?? {
    MIDIClient.sources.first
};

if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ("MIDI IN connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
    ~myUid = ~myInDevice.uid;
} {
    "Warning: No MIDI input devices detected.".warn;
    ~myUid = nil;
};

s.waitForBoot({
    ~ccVals = (
        vol1: 0.28, pan1: 0.0, mute1: 0.0, min1: 21, max1: 60, hpf1: 28, lpf1: 450, rq1: 0.45, atk1: 0.08, rls1: 0.8, fxSubRoar: 0.0,
        vol2: 0.22, pan2: (-0.35), mute2: 0.0, min2: 40, max2: 96, hpf2: 200, lpf2: 5200, rq2: 0.35, atk2: 0.005, rls2: 0.35, fxFormigaPitched: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 55, max3: 110, hpf3: 350, lpf3: 7500, rq3: 0.25, atk3: 0.12, rls3: 1.6, fxBicWind: 0.0,
        delMix: 0.0, delTime: 0.28, revMix: 0.0, revTime: 2.2
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~synthBus = Bus.audio(s, 2);
    ~fxBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~zoneNotes1 = Array.newClear(128);
    ~zoneNotes2 = Array.newClear(128);
    ~zoneNotes3 = Array.newClear(128);

    SynthDef(\zone1SubCouro, {
        |out=0, freq=55, gate=1, vel=0.7, vol=0.25, pan=0.0, mute=0,
         hpf=30, lpf=400, rq=0.5, atk=0.05, rls=0.6, fxSubRoar=0.0|
        var env, sig, sub1, sub2, wavefold;
        env = EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: 2);
        sub1 = LFTri.ar(freq * [0.998, 1.002]);
        sub2 = Pulse.ar(freq * 0.5, 0.45) * 0.4;
        sig = (sub1 + sub2) * (1.0 + (fxSubRoar * 4.0));
        wavefold = Fold.ar(sig, -0.7, 0.7);
        sig = RLPF.ar(wavefold, lpf.clip(20, 18000), rq.clip(0.02, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 1000));
        sig = (sig * (1.0 + (fxSubRoar * 1.5))).tanh;
        sig = sig * env * (vel.linlin(0, 1, 0.25, 1.0)) * vol * (1 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    SynthDef(\zone2FormigaChassi, {
        |out=0, freq=220, gate=1, vel=0.7, vol=0.22, pan=(-0.35), mute=0,
         hpf=150, lpf=4500, rq=0.3, atk=0.005, rls=0.3, fxFormigaPitched=0.0|
        var env, exciter, comb, sig, mod;
        env = EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 2.83) * (freq * fxFormigaPitched * 2.0);
        exciter = Impulse.ar(freq * 0.5) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015)));
        comb = CombL.ar(exciter, 0.04, (freq + mod).reciprocal.clip(0.0002, 0.04), 0.2 + (fxFormigaPitched * 0.5));
        sig = (comb * 0.7) + Pulse.ar(freq + mod, 0.25, 0.3);
        sig = MoogFF.ar(sig, lpf.clip(40, 18000), (1.0 - rq) * 3.5);
        sig = HPF.ar(sig, hpf.clip(20, 5000));
        sig = sig * env * (vel.linlin(0, 1, 0.3, 1.0)) * vol * (1 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    SynthDef(\zone3BicVento, {
        |out=0, freq=440, gate=1, vel=0.7, vol=0.2, pan=0.35, mute=0,
         hpf=300, lpf=7000, rq=0.25, atk=0.1, rls=1.5, fxBicWind=0.0|
        var env, noise, saw, sig, detune;
        env = EnvGen.kr(Env.asr(atk, 1, rls), gate, doneAction: 2);
        noise = PinkNoise.ar * (0.2 + (fxBicWind * 0.8));
        detune = freq * [0.992, 0.997, 1.0, 1.003, 1.008];
        // Replaced non-vanilla DPW4Saw with Saw
        saw = Splay.ar(Saw.ar(detune) + Formant.ar(detune * 0.5, freq * 1.5, 300));
        sig = (saw * 0.6) + (noise * 0.4);
        sig = BPF.ar(sig, lpf.clip(40, 16000), rq.clip(0.05, 1.0));
        sig = HPF.ar(sig, hpf.clip(20, 6000));
        sig = sig * env * (vel.linlin(0, 1, 0.35, 1.0)) * vol * (1 - mute);
        Out.ar(out, if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) });
    }).add;

    SynthDef(\globalFxProcessor, {
        |inBus=0, outBus=0, delMix=0.0, delTime=0.25, revMix=0.0, revTime=2.0|
        var inSig, wetDel, wetRev, drySig, outSig;
        inSig = In.ar(inBus, 2);
        drySig = inSig;
        wetDel = [
            CombC.ar(inSig[0], 1.2, delTime.clip(0.02, 1.0), 2.2),
            CombC.ar(inSig[1], 1.2, (delTime * 1.05).clip(0.02, 1.0), 2.2)
        ];
        wetRev = FreeVerb2.ar(inSig[0], inSig[1], 1.0, (revTime / 8.0).clip(0.1, 0.98), 0.5);
        outSig = drySig + (wetDel * delMix) + (wetRev * revMix);
        Out.ar(outBus, outSig);
    }).add;

    SynthDef(\masterLimiter, {
        |inBus=0, out=0|
        var sig;
        sig = In.ar(inBus, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.new(\globalFxProcessor, [
        \inBus, ~synthBus,
        \outBus, ~fxBus,
        \delMix, ~buses.delMix.asMap,
        \delTime, ~buses.delTime.asMap,
        \revMix, ~buses.revMix.asMap,
        \revTime, ~buses.revTime.asMap
    ], ~fxGroup, \addToTail);

    ~masterSynth = Synth.new(\masterLimiter, [
        \inBus, ~fxBus,
        \out, 0
    ], ~masterGroup, \addToTail);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
                    { ks.matchRegexp("min|max") } { val }
                    { ks.contains("mute") } { if(val > 63, 1.0, 0.0) }
                    { ks.contains("delTime") } { norm.linexp(0, 1, 0.02, 1.0) }
                    { ks.contains("revTime") } { norm.linexp(0, 1, 0.2, 8.0) }
                    { norm };
                ~ccVals[key] = v;
                if(~buses[key].notNil) { ~buses[key].set(v) };
            };
        };
    }, srcID: ~myUid);

    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        var vNorm = vel / 127.0;
        var f = noteNum.midicps;
        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~zoneNotes1[noteNum] = ~zoneNotes1[noteNum].add(Synth(\zone1SubCouro, [
                \out, ~synthBus, \freq, f, \vel, vNorm,
                \vol, ~buses.vol1.asMap, \pan, ~buses.pan1.asMap, \mute, ~buses.mute1.asMap,
                \hpf, ~buses.hpf1.asMap, \lpf, ~buses.lpf1.asMap, \rq, ~buses.rq1.asMap,
                \atk, ~buses.atk1.asMap, \rls, ~buses.rls1.asMap, \fxSubRoar, ~buses.fxSubRoar.asMap
            ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zoneNotes2[noteNum] = ~zoneNotes2[noteNum].add(Synth(\zone2FormigaChassi, [
                \out, ~synthBus, \freq, f, \vel, vNorm,
                \vol, ~buses.vol2.asMap, \pan, ~buses.pan2.asMap, \mute, ~buses.mute2.asMap,
                \hpf, ~buses.hpf2.asMap, \lpf, ~buses.lpf2.asMap, \rq, ~buses.rq2.asMap,
                \atk, ~buses.atk2.asMap, \rls, ~buses.rls2.asMap, \fxFormigaPitched, ~buses.fxFormigaPitched.asMap
            ], ~synthGroup));
        };
        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zoneNotes3[noteNum] = ~zoneNotes3[noteNum].add(Synth(\zone3BicVento, [
                \out, ~synthBus, \freq, f, \vel, vNorm,
                \vol, ~buses.vol3.asMap, \pan, ~buses.pan3.asMap, \mute, ~buses.mute3.asMap,
                \hpf, ~buses.hpf3.asMap, \lpf, ~buses.lpf3.asMap, \rq, ~buses.rq3.asMap,
                \atk, ~buses.atk3.asMap, \rls, ~buses.rls3.asMap, \fxBicWind, ~buses.fxBicWind.asMap
            ], ~synthGroup));
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        ~zoneNotes1[noteNum].do(_.set(\gate, 0));
        ~zoneNotes1[noteNum] = nil;
        ~zoneNotes2[noteNum].do(_.set(\gate, 0));
        ~zoneNotes2[noteNum] = nil;
        ~zoneNotes3[noteNum].do(_.set(\gate, 0));
        ~zoneNotes3[noteNum] = nil;
    }, srcID: ~myUid);

    MIDIdef.cc(\panicCC, { |val|
        if(val > 63) {
            ~synthGroup.set(\gate, 0);
            128.do { |i|
                ~zoneNotes1[i] = nil;
                ~zoneNotes2[i] = nil;
                ~zoneNotes3[i] = nil;
            };
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    defer {
        var zoneViews, tabBtns;
        screen = Window.availableBounds;
        winW = 680;
        winH = min(580, screen.height - 60);
        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        ~mainWin = Window("Alto do Morro // Couro & Caneta Bic", Rect((screen.width - winW) / 2, (screen.height - winH) / 2, winW, winH), scroll: true).front;
        ~mainWin.view.background = Color(0.12, 0.13, 0.15);

        ~ui = ();
        tabBtns = Array.newClear(3);
        zoneViews = Array.newClear(3);

        ~zoneMeta = [
            (title: "Zona 1: Couro / Sub-Mar", fxKey: \fxSubRoar, fxLabel: "Couro Roar (CC9)"),
            (title: "Zona 2: Formigas Mecanicas", fxKey: \fxFormigaPitched, fxLabel: "Engrenagem FM (CC18)"),
            (title: "Zona 3: Brisa do Topo & Caneta Bic", fxKey: \fxBicWind, fxLabel: "Sopro/Traco (CC27)")
        ];

        3.do { |pageIdx|
            tabBtns[pageIdx] = Button(~mainWin, Rect(20 + (pageIdx * 210), 15, 200, 32))
                .states_([[~zoneMeta[pageIdx].title, Color.white, Color(0.2, 0.22, 0.25)]])
                .action_({
                    3.do { |j|
                        zoneViews[j].visible = (j == pageIdx);
                        tabBtns[j].states = [[~zoneMeta[j].title, Color.white, if(j == pageIdx, Color(0.35, 0.45, 0.6), Color(0.2, 0.22, 0.25))]];
                    };
                });

            zoneViews[pageIdx] = CompositeView(~mainWin, Rect(20, 55, 640, 340))
                .background_(Color(0.17, 0.18, 0.21))
                .visible_(pageIdx == 0);

            StaticText(zoneViews[pageIdx], Rect(15, 10, 400, 24))
                .string_(~zoneMeta[pageIdx].title)
                .stringColor_(Color(0.9, 0.85, 0.5))
                .font_(Font("Helvetica-Bold", 14));

            ~ui[(\vol ++ (pageIdx + 1)).asSymbol] = EZSlider(zoneViews[pageIdx], Rect(15, 45, 300, 22), "Vol (CC" ++ ~cc[(\vol ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(0, 1, \lin, 0.01), { |sl|
                var k = (\vol ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = sl.value; ~buses[k].set(sl.value);
            }, ~ccVals[(\vol ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\pan ++ (pageIdx + 1)).asSymbol] = EZSlider(zoneViews[pageIdx], Rect(15, 75, 300, 22), "Pan (CC" ++ ~cc[(\pan ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(-1, 1, \lin, 0.01), { |sl|
                var k = (\pan ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = sl.value; ~buses[k].set(sl.value);
            }, ~ccVals[(\pan ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\hpf ++ (pageIdx + 1)).asSymbol] = EZSlider(zoneViews[pageIdx], Rect(15, 105, 300, 22), "HPF (CC" ++ ~cc[(\hpf ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(20, 10000, \exp, 1), { |sl|
                var k = (\hpf ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = sl.value; ~buses[k].set(sl.value);
            }, ~ccVals[(\hpf ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\lpf ++ (pageIdx + 1)).asSymbol] = EZSlider(zoneViews[pageIdx], Rect(15, 135, 300, 22), "LPF (CC" ++ ~cc[(\lpf ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(40, 18000, \exp, 1), { |sl|
                var k = (\lpf ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = sl.value; ~buses[k].set(sl.value);
            }, ~ccVals[(\lpf ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\rq ++ (pageIdx + 1)).asSymbol] = EZKnob(zoneViews[pageIdx], Rect(330, 45, 80, 85), "Res/Q (CC" ++ ~cc[(\rq ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(0.05, 1.0, \exp, 0.01), { |kn|
                var k = (\rq ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = kn.value; ~buses[k].set(kn.value);
            }, ~ccVals[(\rq ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\atk ++ (pageIdx + 1)).asSymbol] = EZKnob(zoneViews[pageIdx], Rect(420, 45, 80, 85), "Atk (CC" ++ ~cc[(\atk ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(0.005, 3.0, \exp, 0.005), { |kn|
                var k = (\atk ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = kn.value; ~buses[k].set(kn.value);
            }, ~ccVals[(\atk ++ (pageIdx + 1)).asSymbol]);

            ~ui[(\rls ++ (pageIdx + 1)).asSymbol] = EZKnob(zoneViews[pageIdx], Rect(510, 45, 80, 85), "Rls (CC" ++ ~cc[(\rls ++ (pageIdx + 1)).asSymbol] ++ ")", ControlSpec(0.05, 5.0, \exp, 0.01), { |kn|
                var k = (\rls ++ (pageIdx + 1)).asSymbol;
                ~ccVals[k] = kn.value; ~buses[k].set(kn.value);
            }, ~ccVals[(\rls ++ (pageIdx + 1)).asSymbol]);

            ~ui[~zoneMeta[pageIdx].fxKey] = EZSlider(zoneViews[pageIdx], Rect(15, 175, 580, 26), ~zoneMeta[pageIdx].fxLabel, ControlSpec(0.0, 1.0, \lin, 0.01), { |sl|
                var k = ~zoneMeta[pageIdx].fxKey;
                ~ccVals[k] = sl.value; ~buses[k].set(sl.value);
            }, ~ccVals[~zoneMeta[pageIdx].fxKey]);

            ~ui[(\mute ++ (pageIdx + 1)).asSymbol] = Button(zoneViews[pageIdx], Rect(15, 215, 110, 30))
                .states_([["MUTE OFF", Color.white, Color(0.2, 0.4, 0.2)], ["MUTED", Color.white, Color(0.6, 0.1, 0.1)]])
                .value_(~ccVals[(\mute ++ (pageIdx + 1)).asSymbol])
                .action_({ |btn|
                    var k = (\mute ++ (pageIdx + 1)).asSymbol;
                    var v = btn.value.asFloat;
                    ~ccVals[k] = v; ~buses[k].set(v);
                });

            ~ui[(\range ++ (pageIdx + 1)).asSymbol] = EZRanger(zoneViews[pageIdx], Rect(140, 215, 455, 30), "MIDI Keys", ControlSpec(0, 127, \lin, 1), { |rng|
                var minK = (\min ++ (pageIdx + 1)).asSymbol;
                var maxK = (\max ++ (pageIdx + 1)).asSymbol;
                ~ccVals[minK] = rng.value[0];
                ~ccVals[maxK] = rng.value[1];
            }, [~ccVals[(\min ++ (pageIdx + 1)).asSymbol], ~ccVals[(\max ++ (pageIdx + 1)).asSymbol]]);
        };

        tabBtns[0].states = [[~zoneMeta[0].title, Color.white, Color(0.35, 0.45, 0.6)]];

        StaticText(~mainWin, Rect(20, 410, 200, 20))
            .string_("Global Delay & Reverb")
            .stringColor_(Color(0.85, 0.85, 0.85))
            .font_(Font("Helvetica-Bold", 12));

        ~ui[\delMix] = EZSlider(~mainWin, Rect(20, 435, 290, 22), "Delay Mix (CC28)", ControlSpec(0, 1, \lin, 0.01), { |sl|
            ~ccVals[\delMix] = sl.value; ~buses.delMix.set(sl.value);
        }, ~ccVals[\delMix]);

        ~ui[\delTime] = EZSlider(~mainWin, Rect(20, 465, 290, 22), "Delay Time (CC29)", ControlSpec(0.02, 1.0, \exp, 0.01), { |sl|
            ~ccVals[\delTime] = sl.value; ~buses.delTime.set(sl.value);
        }, ~ccVals[\delTime]);

        ~ui[\revMix] = EZSlider(~mainWin, Rect(330, 435, 290, 22), "Reverb Mix (CC30)", ControlSpec(0, 1, \lin, 0.01), { |sl|
            ~ccVals[\revMix] = sl.value; ~buses.revMix.set(sl.value);
        }, ~ccVals[\revMix]);

        ~ui[\revTime] = EZSlider(~mainWin, Rect(330, 465, 290, 22), "Reverb Time (CC31)", ControlSpec(0.2, 8.0, \exp, 0.1), { |sl|
            ~ccVals[\revTime] = sl.value; ~buses.revTime.set(sl.value);
        }, ~ccVals[\revTime]);

        Button(~mainWin, Rect(20, 505, 600, 34))
            .states_([["PANIC (ALL VOICES OFF) [CC32]", Color.white, Color(0.7, 0.15, 0.15)]])
            .action_({
                ~synthGroup.set(\gate, 0);
                128.do { |i|
                    ~zoneNotes1[i] = nil;
                    ~zoneNotes2[i] = nil;
                    ~zoneNotes3[i] = nil;
                };
            });

        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) {
                            ~ui[k].value = v;
                        };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };
});
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
// Congada: Terno de Congo e Moçambique — Ritmo Sagrado, Gungas e Louvor
TempoClock.default.tempo = 106 / 60;

// LAYER 1: Gungas de Lata (Ankle Shakers / Resonant Tin Cans with Internal Seeds)
Ndef(\gungas).fadeTime = 2;
Ndef(\gungas, { |t_trig=1, amp=0.22, pan=0.0, scrape=1.0, decay=0.18|
    var trigA, trigL, envSeed, envBody, seedNoise, metalRes, sig;
    trigA = K2A.ar(t_trig);
    trigL = Dust.ar(120 * scrape);
    envSeed = Decay2.ar(trigA, 0.002, decay * 0.5) + (Decay.ar(trigL, 0.015) * Decay.ar(trigA, decay));
    envBody = Decay2.ar(trigA, 0.001, decay);

    // Crack of metal strike & rattle of hard seeds inside stamped tin
    seedNoise = PinkNoise.ar * envSeed * 2.5;
    seedNoise = BPF.ar(seedNoise, [3100, 5200, 7800], 0.25).sum;

    // Resonant modes of recycled tin canister (Klank modal bank)
    metalRes = DynKlank.ar(
        `[ [1150, 1820, 2460, 3890], [0.8, 0.5, 0.4, 0.25], [0.09, 0.12, 0.08, 0.05] ],
        seedNoise + (trigA * 0.4),
        decayscale: decay * 1.5
    );

    sig = (seedNoise * 0.5) + (metalRes * 0.7);
    sig = HPF.ar(sig, 250);
    sig = (sig * 1.6).tanh;
    Pan2.ar(sig, pan, amp);
}).play;

// Gungas Stereo Delay / Room Reflex
Ndef(\gungas)[10] = \filter -> { |in|
    CombC.ar(in, 0.2, [0.083, 0.125], 1.2) * 0.4;
};
Ndef(\gungas).set(\wet10, 0.28);

// LAYER 2: Tambor de Congo & Caixa (Skin, Wood, and Deep Heartbeat of São Benedito)
Ndef(\tambores).fadeTime = 2;
Ndef(\tambores, { |t_trig=1, freq=65, amp=0.26, pan=0.0, snap=0.8, decay=0.38|
    var trigA, pitchEnv, subOsc, click, rim, snare, sig;
    trigA = K2A.ar(t_trig);
    pitchEnv = EnvGen.ar(Env([freq * 2.8, freq, freq * 0.85], [0.018, decay], \exp), trigA);

    // Warm resonant wood & hide membranophone
    subOsc = SinOsc.ar(pitchEnv) * EnvGen.ar(Env.perc(0.003, decay, 1, -4), trigA);
    subOsc = subOsc + (SinOsc.ar(pitchEnv * 1.5) * 0.3 * EnvGen.ar(Env.perc(0.002, decay * 0.6), trigA));

    // Stick attack & snares of the caixa
    click = BPF.ar(WhiteNoise.ar * Decay.ar(trigA, 0.005), 2400, 0.3) * snap * 1.8;
    rim = HPF.ar(Ringz.ar(trigA, [320, 580], 0.08).sum, 200) * 0.4;
    snare = HPF.ar(PinkNoise.ar * EnvGen.ar(Env.perc(0.005, 0.12), trigA), 1200) * snap * 0.5;

    sig = subOsc + click + rim + snare;
    sig = LeakDC.ar((sig * 1.4).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

// Tambores Plate Echo
Ndef(\tambores)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1, 0.6, 0.4);
};
Ndef(\tambores).set(\wet10, 0.18);

// LAYER 3: Canto do Terno (Modal Vocal Calls / Coronation Brass Fanfare Syncretism)
Ndef(\canto).fadeTime = 3;
Ndef(\canto, { |t_trig=1, freq=220, amp=0.20, pan=0.0, vowel=0.5, dur=0.6|
    var trigA, env, tone, formF, formants, brass, sig;
    trigA = K2A.ar(t_trig);
    env = EnvGen.ar(Env([0, 1, 0.7, 0], [0.04, dur * 0.5, (dur * 0.46).max(0.05)], \sin), trigA);

    // Vocal body: Warm sawtooth through vocal formant filters (/O/ to /A/ transition)
    tone = Saw.ar(freq * [0.997, 1.003]).sum;
    formF = SelectX.kr(vowel * 2, [
        [400, 800, 2400],   // /u/
        [500, 1000, 2800],  // /o/
        [800, 1200, 2600]   // /a/
    ]);
    formants = BPF.ar(tone, formF, 0.12).sum * 8.0;

    // Resonant brass horn syncretism (coronation fanfare)
    brass = MoogFF.ar(Saw.ar(freq), (freq * 3.5) + (env * 1200), 1.8) * 0.4;

    sig = (formants * 0.75) + (brass * 0.25);
    sig = sig * env;
    sig = LeakDC.ar(sig);
    Pan2.ar(sig, pan, amp);
}).play;

// Sacred Procession Cathedral Ambience for Canto
Ndef(\canto)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 110, 3.8, 0.5, 0.45, 15, 0, 0.8, 0.7);
};
Ndef(\canto).set(\wet10, 0.35);

// ================= PATTERN SEQUENCING =================

// 1. Gungas Cadence: Rhythmic counterpoint of syncopated footsteps & ankle shakes
Pbindef(\gungasSeq,
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf),
    \scrape, Pseq([1.4, 0.8, 1.2, 0.9, 1.5, 1.0], inf),
    \decay, Pseq([0.14, 0.08, 0.22, 0.10, 0.16, 0.26], inf),
    \pan, Pseq([-0.35, 0.35, -0.2, 0.2], inf),
    \amp, Pexprand(0.18, 0.26, inf),
    \t_trig, 1
);
Ndef(\gungas).quant = [1, 0];
Ndef(\gungas)[1] = \set -> Pbindef(\gungasSeq);

// 2. Tambores Pattern: Congada Marching Pulse (Syncopated Bass Drum & Slap Rim)
Pbindef(\tamboresSeq,
    \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf),
    \freq, Pseq([55, 110, 110, 48.999, 55], inf), // Fundamental G1/A1 low tuning
    \snap, Pseq([0.2, 0.9, 0.7, 0.3, 0.4], inf),
    \decay, Pseq([0.45, 0.15, 0.18, 0.55, 0.38], inf),
    \pan, Pseq([0.0, 0.25, -0.25, 0.0, 0.1], inf),
    \amp, Pseq([0.28, 0.22, 0.20, 0.30, 0.25], inf),
    \t_trig, 1
);
Ndef(\tambores).quant = [1, 0];
Ndef(\tambores)[1] = \set -> Pbindef(\tamboresSeq);

// 3. Canto Vocal Call Pattern: Modal Pentatonic Chants to São Benedito & Rosário
Pbindef(\cantoSeq,
    \dur, Pseq([0.75, 0.25, 0.5, 0.5, 1.0, 1.0], inf),
    \midinote, Pseq([
        60, 62, 65, 67, 69, 67,
        65, 67, 72, 69, 67, 65,
        62, 60, 62, 65, 60, 57
    ], inf),
    \vowel, Pseq([0.2, 0.5, 0.8, 0.4, 0.9, 0.3], inf),
    \durVal, Pkey(\dur) * 1.1,
    \pan, Pseq([0.0, -0.3, 0.3, 0.0], inf),
    \amp, Pexprand(0.16, 0.24, inf),
    \t_trig, 1
);
Ndef(\canto).quant = [1, 0];
Ndef(\canto)[1] = \set -> Pbindef(\cantoSeq);
)

// === LIVE-CODING PERFORMANCE CONTROLS ===
// Ndef(\gungas).xset(\scrape, 2.5); // Energize metal rattle | Revert: Ndef(\gungas).xset(\scrape, 1.0);
// Pbindef(\gungasSeq, \dur, 0.125); // Accelerate into double-time footwork | Revert: Pbindef(\gungasSeq, \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf));
// Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 3; Ndef(\gungas).clear(3); // Rollback Gungas
// Ndef(\tambores).xset(\freq, 40); // Drop drum tuning into deep sub | Revert: Ndef(\tambores).xset(\freq, 65);
// Pbindef(\tamboresSeq, \snap, 1.2); // Emphasize wooden snare strike | Revert: Pbindef(\tamboresSeq, \snap, Pseq([0.2, 0.9, 0.7, 0.3, 0.4], inf));
// Pbindef(\tamboresSeq).stop; Ndef(\tambores).fadeTime = 3; Ndef(\tambores).clear(3); // Rollback Tambores
// Ndef(\canto).xset(\amp, 0.32); // Raise vocal praise amplitude | Revert: Ndef(\canto).xset(\amp, 0.20);
// Pbindef(\cantoSeq, \midinote, Pseq([72, 74, 77, 79], inf)); // Soaring high register praise | Revert: Pbindef(\cantoSeq, \midinote, Pseq([60, 62, 65, 67, 69, 67], inf));
// Pbindef(\cantoSeq).stop; Ndef(\canto).fadeTime = 4; Ndef(\canto).clear(4); // Rollback Canto


// ============================================================
// ROUND 05 | MODE: APPEND | FRAG #120
// STATUS: PASS
// PROMPT: Era um sonho dantesco... o tombadilho que das luzernas avermelha o brilho, em sangue a se banhar. Ti...
// ============================================================
(
// TWEAK_EXISTING: Transform Congada procession into Castro Alves's "Navio Negreiro" (Dantean nightmare)
// Formal Strategy: Intrinsic Limit (b) -> Distortion, suffocating delay, agonizing vocal descent

// 1. Canto: Descending groans, cries of anguish, suffocated by blood & salt water
Pbindef(\cantoSeq,
    \dur, Pseq([1.5, 0.5, 1.0, 2.0, 0.75, 1.25], inf),
    \midinote, Pseq([53, 52, 50, 48, 46, 45, 41], inf), // Low minor/diminished despair
    \vowel, Pseq([0.05, 0.1, 0.3, 0.0, 0.2], inf),       // Dark /u/ and strangled phonemes
    \amp, Pexprand(0.24, 0.35, inf)
);
// Pbindef(\cantoSeq, \dur, Pseq([0.75, 0.25, 0.5, 0.5, 1.0, 1.0], inf)); // Revert sequence
// Pbindef(\cantoSeq, \midinote, Pseq([60, 62, 65, 67, 69, 67], inf)); // Revert sequence

// Add suffocating cavernous distortion to \canto (blood-red hold)
Ndef(\canto)[11] = \filter -> { |in|
    var blood;
    blood = LeakDC.ar((in * 3.5).tanh);
    blood = RLPF.ar(blood, LFNoise1.kr(0.4).exprange(400, 2200), 0.4);
    blood;
};
Ndef(\canto).set(\wet11, 0.65);
// Ndef(\canto).set(\wet11, 0); // Rollback: disable this effect

// 2. Tambores: Heavy, brutal pulse of the slave ship hold (fetid heat & whip-cracks)
Pbindef(\tamboresSeq,
    \dur, Pseq([0.5, 0.25, 0.75, 0.5], inf),
    \freq, Pseq([38, 44, 34, 40], inf), // Abyssal sub rumble
    \snap, Pseq([1.8, 0.4, 2.2, 0.6], inf), // Cracking impacts
    \decay, Pseq([0.7, 0.1, 0.85, 0.2], inf),
    \amp, Pseq([0.38, 0.24, 0.42, 0.28], inf)
);
// Pbindef(\tamboresSeq, \dur, Pseq([0.5, 0.25, 0.25, 0.5, 0.5], inf)); // Revert sequence
// Pbindef(\tamboresSeq, \freq, Pseq([55, 110, 110, 48.999, 55], inf)); // Revert sequence

// Heavy compression & dark ocean resonance on \tambores
Ndef(\tambores)[11] = \filter -> { |in|
    var crush;
    crush = (in * 2.2).softclip;
    LPF.ar(crush, 850);
};
Ndef(\tambores).set(\wet11, 0.55);
// Ndef(\tambores).set(\wet11, 0); // Rollback: disable this effect

// 3. Gungas: Turned into the screaming of iron chains, shackled feet, and abrasive metal
Pbindef(\gungasSeq,
    \dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.375], inf), // Frantic, trapped shuffling
    \scrape, Pseq([3.2, 2.8, 4.0, 1.5, 3.5], inf),       // Extreme rattling friction
    \decay, Pseq([0.3, 0.18, 0.45, 0.12, 0.35], inf),
    \amp, Pexprand(0.25, 0.38, inf)
);
// Pbindef(\gungasSeq, \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5], inf)); // Revert sequence
// Pbindef(\gungasSeq, \scrape, Pseq([1.4, 0.8, 1.2, 0.9, 1.5, 1.0], inf)); // Revert sequence

// Resonant metallic feedback ring on \gungas (tinir de ferros)
Ndef(\gungas)[11] = \filter -> { |in|
    var ironRing;
    ironRing = Ringz.ar(in, [1840, 2620, 4100], 0.09).sum * 0.25;
    ironRing = HPF.ar(ironRing, 800);
    ironRing.tanh;
};
Ndef(\gungas).set(\wet11, 0.7);
// Ndef(\gungas).set(\wet11, 0); // Rollback: disable this effect

// NEW INSTRUMENT: \chicotadas (The crack of the whip, saline spray, and iron clinking)
Ndef(\chicotadas).fadeTime = 1;
Ndef(\chicotadas, { |t_trig=1, amp=0.28, pan=0.0, crack=1.0, length=0.18|
    var trigA, whipEnv, whipNoise, whipBody, chainTrig, chains, sig;
    trigA = K2A.ar(t_trig);

    // Whip: Explosive white-noise burst and high-frequency friction
    whipEnv = EnvGen.ar(Env.perc(0.0005, length, 1, -8), trigA);
    whipNoise = WhiteNoise.ar * whipEnv;
    whipNoise = HPF.ar(whipNoise, 1800) * 2.8 * crack;
    whipBody = BPF.ar(GrayNoise.ar * Decay2.ar(trigA, 0.002, 0.06), 600, 0.4) * 3.0;

    // Echoing shackle rattle excited by the strike
    chainTrig = Dust.ar(140 * Decay.ar(trigA, 0.45));
    chains = Ringz.ar(chainTrig, [2200, 3450, 5120, 6800], [0.04, 0.03, 0.02, 0.015]).sum * 0.35;

    sig = whipNoise + whipBody + chains;
    sig = LeakDC.ar((sig * 1.5).tanh);
    Pan2.ar(sig, pan, amp);
}).play;

// Metallic echo chamber for the whip & chains
Ndef(\chicotadas)[10] = \filter -> { |in|
    CombL.ar(in, 0.3, [0.09, 0.13], 1.8) * 0.5;
};
Ndef(\chicotadas).set(\wet10, 0.35);

// Whip Sequence: Irregular, violent lashes cutting across the dantesque rhythm
Pbindef(\chicotadasSeq,
    \dur, Pseq([1.5, 0.75, 0.25, 1.5, 2.0, 1.0], inf),
    \crack, Pwhite(0.8, 1.6, inf),
    \length, Pwhite(0.08, 0.24, inf),
    \pan, Pwhite(-0.7, 0.7, inf),
    \amp, Pexprand(0.24, 0.38, inf),
    \t_trig, 1
);
Ndef(\chicotadas).quant = [1, 0];
Ndef(\chicotadas)[1] = \set -> Pbindef(\chicotadasSeq);
// Pbindef(\chicotadasSeq).stop; Ndef(\chicotadas).fadeTime = 2; Ndef(\chicotadas).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 06 | MODE: COMPOSE | FRAG #13
// STATUS: PASS
// PROMPT: A Gruta do Maquiné, localizada em Cordisburgo, Minas Gerais, e estudada no século XIX pelo naturalis...
// ============================================================
(
s.waitForBoot({
	var srate = s.sampleRate;
	~enableRecording = false;

	// Master Mix Bus
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// Safety Limiter
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;

	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// 1. Mineral Droplets striking limestone hollows (water drops with pitch-swept sinusoids and modal ring)
	SynthDef(\gotejamento, {
		|out=0, freq=1400, dropSweep=1.8, dripDecay=0.35, pan=0, amp=0.3|
		var env, pitchEnv, snd, click, body;
		env = EnvGen.ar(Env.perc(0.001, dripDecay, 1, -6), doneAction: 2);
		pitchEnv = EnvGen.ar(Env([freq * dropSweep, freq * 0.85, freq], [0.008, 0.04], \exp));
		click = BPF.ar(LPF.ar(WhiteNoise.ar, 6000) * EnvGen.ar(Env.perc(0.0005, 0.008)), freq * 2, 0.3) * 2.5;
		body = SinOsc.ar(pitchEnv) * env;
		snd = (body * 0.8) + (click * 0.35);
		snd = snd + Ringz.ar(snd * 0.4, freq * [1.61, 2.43], 0.15).sum;
		snd = LeakDC.ar(snd);
		Out.ar(out, Pan2.ar(snd, pan, amp));
	}).add;

	// 2. Chitinous / Calcite Fracture Percussion (Stalactite impact / geological friction)
	SynthDef(\estalactiteTap, {
		|out=0, freq=440, pan=0, amp=0.25, ring=0.8|
		var sig, exciter, modes;
		exciter = Impulse.ar(0) + (PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.015)));
		// Mineral crystalline modes
		modes = DynKlank.ar(
			`[
				[freq, freq * 1.58, freq * 2.24, freq * 3.12, freq * 4.67],
				[0.6, 0.4, 0.25, 0.15, 0.08],
				[ring, ring * 0.75, ring * 0.55, ring * 0.4, ring * 0.25]
			],
			exciter
		);
		sig = modes * EnvGen.ar(Env.perc(0.001, (ring * 1.2).max(0.05)), doneAction: 2);
		sig = LeakDC.ar(sig);
		Out.ar(out, Pan2.ar(sig, pan, amp));
	}).add;

	s.sync;

	// 3. Continuous Cavern Air & Subterranean Draft (Ndef \abobada)
	Ndef(\abobada).fadeTime = 3;
	Ndef(\abobada, { |amp=0, cutoff=350, res=0.2, drift=0.08|
		var wind, subCavern, sig;
		wind = BPF.ar(
			PinkNoise.ar(1.2),
			LFNoise1.kr([drift, drift * 1.3]).exprange( cutoff * 0.6, cutoff * 2.2 ),
			res
		);
		wind = wind + (LPF.ar(BrownNoise.ar(0.7), 80) * 1.4);
		// Resonant hollow cavities of the 7 subterranean vaults
		subCavern = DynKlank.ar(
			`[
				[55, 110, 164.8, 220, 329.6],
				[0.5, 0.3, 0.2, 0.15, 0.1],
				[2.5, 2.0, 1.8, 1.5, 1.2]
			],
			wind * 0.12
		);
		sig = (wind * 0.5) + (subCavern * 0.5);
		LeakDC.ar(sig) * amp;
	});

	// 4. Subterranean Calcite Drone / Peter Lund's Acoustic Lantern (Ndef \calcario)
	Ndef(\calcario).fadeTime = 4;
	Ndef(\calcario, { |amp=0, fund=65.41, drive=1.5| // C2
		var oscs, fold, sig;
		oscs = SinOsc.ar(fund * [1, 1.004, 1.498, 2.002, 2.996, 4.02]) * [0.5, 0.4, 0.25, 0.2, 0.1, 0.05];
		sig = Splay.ar(oscs);
		fold = Fold.ar(sig * drive, -0.6, 0.6);
		sig = MoogFF.ar(fold, LFNoise2.kr(0.15).exprange(300, 1800), 1.8);
		LeakDC.ar(sig) * amp;
	});

	// Master Mix Node
	Ndef(\masterMix).fadeTime = 2;
	Ndef(\masterMix, {
		var inSynth, inAbobada, inCalcario, mixed;
		inSynth = In.ar(~synthBus, 2);
		inAbobada = Ndef.ar(\abobada, 2);
		inCalcario = Ndef.ar(\calcario, 2);
		mixed = inSynth + inAbobada + inCalcario;
		mixed;
	});

	// Monumental Limestone Cavern Reverb (FreeVerb2 + CombL network)
	Ndef(\masterMix)[10] = \filter -> { |in|
		var rev, comb;
		comb = CombL.ar(in, 0.2, [0.083, 0.117], 3.5);
		rev = FreeVerb2.ar(comb[0], comb[1], 1.0, 0.95, 0.15);
		rev * 0.9;
	};
	Ndef(\masterMix).set(\wet10, 0.45);

	// Secondary Dark Ambient Diffuser
	Ndef(\masterMix)[11] = \filter -> { |in|
		AllpassC.ar(in, 0.1, [0.043, 0.051], 2.2);
	};
	Ndef(\masterMix).set(\wet11, 0.3);

	Ndef(\masterMix).play;
	s.sync;

	// Timeline Score
	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - Descent into Gruta do Maquiné: Abyssal draft and distant limestone drips".postln;

		// Awaken the ambient subterranean vault
		Ndef(\abobada).xset(\amp, 0.45, \cutoff, 240);
		Ndef(\masterMix).set(\wet10, 0.55);

		// Sparse, slow, mineral gotejamento sequence
		Pbindef(\gotas,
			\instrument, \gotejamento,
			\out, ~synthBus,
			\dur, Pseq([1.8, 2.4, 1.2, 3.1, 0.9, 2.7, 1.5], inf),
			\freq, Pseq([1120, 1540, 1310, 980, 1820, 1260, 1420], inf),
			\dropSweep, Pwhite(1.4, 2.2, inf),
			\dripDecay, Pwhite(0.25, 0.65, inf),
			\pan, Pwhite(-0.75, 0.75, inf),
			\amp, Pexprand(0.2, 0.38, inf)
		).play;

		// Evolving drift over 15 seconds
		5.do { |i|
			Ndef(\abobada).xset(\cutoff, 220 + (i * 45), \drift, 0.06 + (i * 0.03));
			3.wait;
		};

		"0:15 - Hall of the Stalactites: Resonances emerge from mineral columns".postln;
		Ndef(\calcario).xset(\amp, 0.3, \fund, 55, \drive, 1.2); // A1 fundamental

		// Crystalline taps on stalactite formations
		Pbindef(\chitinTaps,
			\instrument, \estalactiteTap,
			\out, ~synthBus,
			\dur, Pseq([0.75, 0.5, 0.75, 1.0, 0.5, 0.25, 0.25], inf),
			\freq, Pseq([440, 554.37, 659.25, 880, 739.99, 987.77, 659.25], inf),
			\ring, Pwhite(0.6, 1.4, inf),
			\pan, Pwhite(-0.8, 0.8, inf),
			\amp, Pexprand(0.18, 0.32, inf)
		).play;

		// Accelerate drip rate as we enter deeper chambers
		Pbindef(\gotas,
			\dur, Pseq([0.6, 0.8, 0.4, 1.1, 0.5, 0.9], inf),
			\freq, Pseq([1320, 1780, 1050, 2100, 1220, 1640], inf)
		);

		6.do { |i|
			Ndef(\calcario).xset(\drive, 1.2 + (i * 0.35));
			Ndef(\masterMix).set(\wet10, 0.55 + (i * 0.05));
			3.wait;
		};

		"0:33 - Peter Lund's Encounter: The Seventh Vault (Abyssal Echoes & Deep Sub-harmonics)".postln;
		// Drive resonance toward intrinsic physical boundary
		Ndef(\abobada).xset(\cutoff, 750, \res, 0.08, \amp, 0.65);
		Ndef(\calcario).xset(\fund, 48.999, \drive, 3.2, \amp, 0.45); // G1 drop

		Pbindef(\chitinTaps,
			\dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.75, 0.125, 0.125], inf),
			\freq, Pseq([293.66, 369.99, 440, 587.33, 880, 1174.66, 739.99], inf),
			\ring, Pseq([1.8, 1.2, 2.2, 0.9, 2.5, 0.8, 1.5], inf),
			\amp, Pexprand(0.25, 0.42, inf)
		);

		Pbindef(\gotas,
			\dur, Pseq([0.35, 0.25, 0.4, 0.3, 0.15, 0.6], inf),
			\freq, Pseq([1800, 2400, 1500, 3100, 1950, 2700], inf),
			\dropSweep, Pwhite(2.0, 3.5, inf),
			\amp, Pexprand(0.3, 0.5, inf)
		);

		4.do { |i|
			Ndef(\masterMix).set(\wet11, 0.3 + (i * 0.1));
			3.wait;
		};

		"0:45 - Intrinsic Limit reached: Abrupt settling to stark, solitary drip".postln;
		// Formal Archetype (b) -> (c): Intrinsic Limit snapped to Fragile Settling
		Pbindef(\chitinTaps).stop;
		Ndef(\calcario).fadeTime = 3;
		Ndef(\calcario).xset(\amp, 0);

		Ndef(\abobada).fadeTime = 5;
		Ndef(\abobada).xset(\cutoff, 180, \res, 0.35, \amp, 0.25);
		Ndef(\masterMix).set(\wet10, 0.85); // Huge cathedral decay

		// Return to sparse ancient dripping cadence (Formal Archetype a)
		Pbindef(\gotas,
			\dur, Pseq([2.8, 3.4, 2.1, 4.2], inf),
			\freq, Pseq([1120, 980, 1260, 840], inf),
			\dropSweep, 1.6,
			\dripDecay, 0.8,
			\pan, Pseq([-0.3, 0.4, -0.6, 0.2], inf),
			\amp, Pexprand(0.2, 0.3, inf)
		);

		4.do { |i|
			Ndef(\abobada).xset(\amp, 0.25 - (i * 0.05));
			3.wait;
		};

		"0:57 - Extrinsic Limit: Darkness seals the limestone gallery".postln;
		Pbindef(\gotas).stop;
		Pbindef(\gotas).clear;
		Pbindef(\chitinTaps).clear;

		Ndef(\abobada).fadeTime = 3;
		Ndef(\abobada).clear(3);
		Ndef(\calcario).clear(2);
		Ndef(\masterMix).fadeTime = 3;
		Ndef(\masterMix).clear(3);

		3.5.wait;
		"Score Complete: Gruta do Maquiné silent.".postln;
		Tdef(\masterScore).stop;
	});

	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 07 | MODE: DESIGN | FRAG #170
// STATUS: FALLBACK
// PROMPT: O rei acordou com uma ideia azul na cabeça. Não era um pássaro nem uma flor de lavanda: era um pensa...
// ============================================================
(
// [Pre-Design Cleanup: freeing previous Design synthesizer resources]
{
    if(~guiRoutine.notNil) { try { ~guiRoutine.stop } {}; ~guiRoutine = nil };
    [~mainWin, ~surWin, ~win, ~guiWin, ~synthWin].do { |w|
        if(w.notNil) { try { w.close } {} };
    };
    ~mainWin = nil; ~surWin = nil; ~win = nil; ~guiWin = nil; ~synthWin = nil;
    try { Window.closeAll } {};
    try { MIDIdef.freeAll } {};
    if(~notes.notNil) {
        try {
            ~notes.do { |item|
                if(item.notNil) {
                    if(item.isKindOf(Collection)) {
                        item.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                    } {
                        try { item.free } {};
                    };
                };
            };
        } {};
        ~notes = nil;
    };
    if(~zoneNotes.notNil) {
        try {
            ~zoneNotes.do { |zone|
                if(zone.notNil) {
                    zone.do { |sn| if(sn.notNil) { try { sn.free } {} } };
                };
            };
        } {};
        ~zoneNotes = nil;
    };
    ~activeCount = 0;
    [
        ~subSynth, ~monoSynth, ~leadSynth, ~droneSynth, ~synth,
        ~fxSynth, ~masterFx, ~celestialFx, ~ancientFx, ~reverbSynth, ~delaySynth,
        ~synthGroup, ~fxGroup, ~masterGroup, ~sourceGroup
    ].do { |node|
        if(node.notNil) { try { node.free } {} };
    };
    ~subSynth = nil; ~monoSynth = nil; ~leadSynth = nil; ~droneSynth = nil; ~synth = nil;
    ~fxSynth = nil; ~masterFx = nil; ~celestialFx = nil; ~ancientFx = nil; ~reverbSynth = nil; ~delaySynth = nil;
    ~synthGroup = nil; ~fxGroup = nil; ~masterGroup = nil; ~sourceGroup = nil;
    if(~buses.notNil) {
        try { ~buses.do { |b| if(b.notNil) { try { b.free } {} } } } {};
        ~buses = nil;
    };
    [~fxBus, ~celestialBus, ~ancientBus, ~reverbBus, ~delayBus].do { |b|
        if(b.notNil) { try { b.free } {} };
    };
    ~fxBus = nil; ~celestialBus = nil; ~ancientBus = nil; ~reverbBus = nil; ~delayBus = nil;
    try {
        if(Pbindef.all.notNil and: { Pbindef.all[\subtractiveDesignSeq].notNil }) {
            Pbindef(\subtractiveDesignSeq).stop;
            Pbindef(\subtractiveDesignSeq).clear;
        };
    } {};
    try {
        if(Ndef.dictFor(s).notNil and: { Ndef.dictFor(s)[\subtractiveDesign].notNil }) {
            Ndef(\subtractiveDesign).clear(0.1);
        };
    } {};
}.value;
{
// --- DESIGN FALLBACK: RANDOMIZED SUBTRACTIVE SYNTHESIZER ---
Ndef(\subtractiveDesign).fadeTime = 1.5;
Ndef(\subtractiveDesign, {
    |freq=82.41, detune=0.0307, sawMix=0.5, pulseMix=0.5,
     pw=0.56, pwmRate=2.75, pwmDepth=0.1,
     subAmp=0.26, noiseAmp=0.051,
     cutoff=1153.3, rq=0.31, hpf=131.7,
     filtEnvAmt=4249.5, lfoRate=2.62, lfoDepth=546.9,
     atk=0.019, dec=0.53, sus=0.44, rls=1.26,
     pan=(-0.17), amp=0.35, t_trig=1|
    var env, filtEnv, freqs, pwm, sawSig, pulseSig, subSig, noiseSig, sig, dynCutoff;

    env = EnvGen.ar(Env([0, 1, sus, 0], [atk, dec, rls], \sin), t_trig);
    filtEnv = EnvGen.ar(Env.perc(atk.max(0.005), (dec + rls).clip(0.1, 2.5)), t_trig);

    freqs = freq * [1 - detune, 1, 1 + detune];
    pwm = (pw + (SinOsc.kr(pwmRate) * pwmDepth)).clip(0.08, 0.92);

    sawSig = Splay.ar(Saw.ar(freqs));
    pulseSig = Splay.ar(Pulse.ar(freqs, pwm));
    subSig = SinOsc.ar(freq * 0.5) * subAmp;
    noiseSig = PinkNoise.ar * noiseAmp;

    sig = (sawSig * sawMix) + (pulseSig * pulseMix) + subSig + noiseSig;

    dynCutoff = (cutoff + (filtEnv * filtEnvAmt) + (SinOsc.kr(lfoRate) * lfoDepth)).clip(60, 18000);
    sig = RLPF.ar(sig, dynCutoff, rq.clip(0.08, 0.95));
    sig = HPF.ar(sig, hpf.clip(20, 2000));
    sig = (sig * 1.4).tanh;

    sig = Balance2.ar(sig[0], sig[1], pan) * env * amp;
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\subtractiveDesign)[10] = \filter -> { |in|
    CombL.ar(in, 0.5, 0.375, 1.6);
};
Ndef(\subtractiveDesign).set(\wet10, 0.33);

Ndef(\subtractiveDesign)[11] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.47, 0.35);
};
Ndef(\subtractiveDesign).set(\wet11, 0.21);

Pbindef(\subtractiveDesignSeq,
    \dur, Pwrand([0.125, 0.25, 0.5, 1.0], [0.2, 0.45, 0.25, 0.1], inf),
    \freq, (82.41 * (2 ** (Prand([0, 2, 4, 7, 9], inf) / 12))),
    \t_trig, 1
);
Ndef(\subtractiveDesign)[1] = \set -> Pbindef(\subtractiveDesignSeq);

// Live MIDI control (loopMIDI -> BeatStep Pro -> any external hardware MIDI)
if(MIDIClient.initialized.not) { MIDIClient.init };
~myInDevice = MIDIClient.sources.detect { |src|
    var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
    label.contains("loopmidi")
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("beatstep") and: { label.contains("midiin2").not } and: { label.contains("midiin 2").not }
    }
} ?? {
    MIDIClient.sources.detect { |src|
        var label = (src.device.asString ++ " " ++ src.name.asString).toLower;
        label.contains("bmt").not
            and: { label.contains("bome").not }
            and: { label.contains("midiin2").not }
            and: { label.contains("midiin 2").not }
            and: { label.contains("microsoft gs").not }
            and: { label.contains("wavetable").not }
            and: { label.contains("midi through").not }
            and: { label.contains("iac ").not }
    }
} ?? {
    MIDIClient.sources.first
};
if(~myInDevice.notNil) {
    MIDIIn.connect(0, ~myInDevice);
    ~myUid = ~myInDevice.uid;
    ("Design Fallback MIDI connected to: " ++ ~myInDevice.device ++ " (" ++ ~myInDevice.name ++ ")").postln;
} {
    ~myUid = nil;
};
MIDIdef.noteOn(\subtractiveDesignMidiOn, { |vel, noteNum|
    Pbindef(\subtractiveDesignSeq).stop;
    Ndef(\subtractiveDesign).set(\freq, noteNum.midicps, \amp, vel.linlin(1, 127, 0.12, 0.42), \t_trig, 1);
}, srcID: ~myUid);
MIDIdef.cc(\subtractiveDesignMidiCC, { |val, num|
    if((num == 1) or: { num == 74 }) {
        Ndef(\subtractiveDesign).set(\cutoff, val.linexp(0, 127, 120, 14000));
    };
}, srcID: ~myUid);
}.value;
)


// ============================================================
// ROUND 08 | MODE: GENERATE | FRAG #129
// STATUS: PASS
// PROMPT: O que não tem utilidade nenhuma é o que sustenta o mundo. Aprendi com os passarinhos a arte de desap...
// ============================================================
(
// Manoel de Barros: O desaprender das medidas, o rio sobre as pedras e a rã no lodo
Ndef(\rioLodo).clear; Ndef(\passarinhos).clear; Ndef(\coisasSemNome).clear;

// Layer 1: Rio e Lodo - Leito subaquático, pedras lisas e o baque viscoso no lodo
Ndef(\rioLodo, {
    |freq=52, lodoFilt=180, res=0.6, flowRate=0.18, amp=0.22, pan=0.0, t_trig=1|
    var trigSig, env, sub, waterNoise, stones, mudPlop, sig;
    trigSig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.02, 1.4, 1, -4), trigSig);
    // Leito grave e ressonante do rio
    sub = SinOsc.ar(freq * [1, 1.008] + (SinOsc.kr(0.08) * 1.5)) * 0.7;
    sub = sub + (SinOsc.ar(freq * 2.01) * 0.25);
    // Ruído de correnteza e água deslizando em seixos lisos
    waterNoise = BPF.ar(PinkNoise.ar, SinOsc.kr(flowRate).exprange(350, 1400), 0.45) * 0.35;
    stones = HPF.ar(BrownNoise.ar, 600) * LFNoise1.kr(0.8).range(0.02, 0.12);
    // Baque opaco da rã no lodo
    mudPlop = MoogFF.ar(Decay2.ar(trigSig, 0.015, 0.22) * WhiteNoise.ar(2.5), lodoFilt, res * 3.5);
    sig = sub + (waterNoise + stones * 0.6) + mudPlop;
    sig = if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], pan) } { Pan2.ar(sig, pan) } * amp;
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\rioLodo)[10] = \filter -> { |in|
    CombC.ar(in, 0.4, [0.18, 0.24], 2.2);
};
Ndef(\rioLodo).set(\wet10, 0.28);

Pbindef(\rioLodoSeq,
    \dur, Pwrand([0.75, 1.5, 2.25, 3.0], [0.4, 0.35, 0.15, 0.1], inf),
    \freq, Pseq([43.65, 46.25, 51.91, 58.27, 48.99], inf), // F, F#, G#, A#, G
    \lodoFilt, Pwhite(120, 310, inf),
    \flowRate, Pwhite(0.12, 0.35, inf),
    \pan, Pwhite(-0.4, 0.4, inf),
    \amp, Pwhite(0.18, 0.26, inf),
    \t_trig, 1
);
Ndef(\rioLodo)[1] = \set -> Pbindef(\rioLodoSeq);

// Layer 2: Passarinhos - Desaprendendo as medidas do mundo com trinados e micro-glissandi
Ndef(\passarinhos, {
    |trillRate=18, baseFreq=2400, chirpSweep=1200, amp=0.14, pan=0.0, t_trig=1|
    var trigSig, env, sweepEnv, fmAmt, mod, car, click, sig;
    trigSig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.008, 0.38, 1, -6), trigSig);
    sweepEnv = EnvGen.ar(Env([0, 1, 0.1, 0], [0.015, 0.09, 0.2], \exp), trigSig);
    // Micro-trinado modulado em frequência
    fmAmt = SinOsc.ar(trillRate) * sweepEnv * 340;
    mod = SinOsc.ar((baseFreq * 1.5) + fmAmt) * 0.4;
    car = SinOsc.ar(baseFreq + (sweepEnv * chirpSweep) + mod);
    // Ataque suave do bico abrindo no ar
    click = BPF.ar(WhiteNoise.ar, (baseFreq * 1.2).clip(800, 12000), 0.2) * Decay.ar(trigSig, 0.01) * 2.0;
    sig = (car * env) + click;
    sig = Pan2.ar(sig, pan, amp);
    Limiter.ar(LeakDC.ar(sig), 0.85);
}).play;

Ndef(\passarinhos)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.82, 0.65);
};
Ndef(\passarinhos).set(\wet10, 0.32);

Pbindef(\passarinhosSeq,
    \dur, Pwrand([0.25, 0.5, 0.75, 1.25, Rest(1.5)], [0.3, 0.35, 0.15, 0.1, 0.1], inf),
    \baseFreq, Pn(Pshuf([1850, 2120, 2480, 2850, 3200, 3950], 4), inf),
    \chirpSweep, Pwhite(600, 1800, inf),
    \trillRate, Pwhite(12, 28, inf),
    \pan, Pwhite(-0.75, 0.75, inf),
    \amp, Pwhite(0.10, 0.17, inf),
    \t_trig, 1
);
Ndef(\passarinhos)[1] = \set -> Pbindef(\passarinhosSeq);

// Layer 3: O Canto das Coisas Sem Nome - Ressonâncias na tarde silenciosa (Gota no universo)
Ndef(\coisasSemNome, {
    |freq=349.23, brightness=1800, decayTime=2.8, pan=0.0, amp=0.18, t_trig=1|
    var trigSig, env, body, ring, resFreqs, resAmps, resDurs, sig;
    trigSig = K2A.ar(t_trig);
    env = EnvGen.ar(Env.perc(0.04, decayTime.clip(0.4, 5.0), 1, -3), trigSig);
    // Pulso excitador orgânico (pequena gota/impacto velado)
    body = LPF.ar(PinkNoise.ar, brightness) * Decay2.ar(trigSig, 0.005, 0.05);
    body = body + (SinOsc.ar(freq * 0.5) * Decay.ar(trigSig, 0.08) * 0.4);
    // Estrutura inarmônica que vibra como pedra e vidro fino
    resFreqs = freq * [1, 1.414, 2.06, 2.78, 3.45];
    resAmps = [0.6, 0.4, 0.28, 0.18, 0.09];
    resDurs = [1.0, 0.8, 0.65, 0.5, 0.35] * decayTime;
    ring = DynKlank.ar(Ref([resFreqs, resAmps, resDurs]), body);
    ring = LeakDC.ar(ring) * 0.75;
    sig = Pan2.ar(ring * env, pan, amp);
    Limiter.ar(sig, 0.85);
}).play;

Ndef(\coisasSemNome)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 140, 5.2, 0.42, 0.5, 12, 0, 0.7, 0.65);
};
Ndef(\coisasSemNome).set(\wet10, 0.38);

Pbindef(\coisasSemNomeSeq,
    \dur, Pseq([2.0, 1.5, 2.5, 3.0, 1.0, 4.0], inf),
    // Escala modal sem nome (F - G - Ab - C - D)
    \freq, Pn(Pshuf([174.61, 220.0, 261.63, 329.63, 392.0, 440.0], 3), inf),
    \brightness, Pwhite(1200, 3600, inf),
    \decayTime, Pwhite(2.2, 4.5, inf),
    \pan, Pwhite(-0.6, 0.6, inf),
    \amp, Pwhite(0.12, 0.22, inf),
    \t_trig, 1
);
Ndef(\coisasSemNome)[1] = \set -> Pbindef(\coisasSemNomeSeq);
)

// Ndef(\rioLodo).xset(\lodoFilt, 450); // Lama mais clara | Revert: Ndef(\rioLodo).xset(\lodoFilt, 180);
// Pbindef(\passarinhosSeq, \dur, 0.125); // Bando em revoada rápida | Revert: Pbindef(\passarinhosSeq, \dur, Pwrand([0.25, 0.5, 0.75, 1.25, Rest(1.5)], [0.3, 0.35, 0.15, 0.1, 0.1], inf));
// Ndef(\coisasSemNome).xset(\decayTime, 6.5); // Ressonância infinita | Revert: Ndef(\coisasSemNome).xset(\decayTime, 2.8);
// Pbindef(\rioLodoSeq).stop; Ndef(\rioLodo).clear(4); // Rollback Layer 1
// Pbindef(\passarinhosSeq).stop; Ndef(\passarinhos).clear(4); // Rollback Layer 2
// Pbindef(\coisasSemNomeSeq).stop; Ndef(\coisasSemNome).clear(4); // Rollback Layer 3


// ============================================================
// ROUND 09 | MODE: COMPOSE | FRAG #55
// STATUS: PASS
// PROMPT: Passava da meia-noite quando as matracas de madeira começaram a bater compassadas no calçamento de p...
// ============================================================
(
s.waitForBoot({
    var sRate;
    ~enableRecording = false;
    if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

    // Safety Limiter
    SynthDef(\safetyLimiter, {
        var sig;
        sig = In.ar(0, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.85, 0.01);
        ReplaceOut.ar(0, sig);
    }).add;
    s.sync;

    ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
    if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

    // Discrete Synth: Matracas de madeira batendo no calçamento
    SynthDef(\matracaMadeira, {
        |out=0, freq=380, clickAmt=2.5, pan=0.0, amp=0.25, dur=0.35|
        var env, exciter, modes, sig;
        env = EnvGen.ar(Env.perc(0.001, (dur - 0.01).max(0.08), 1, -8), doneAction: 2);
        exciter = Impulse.ar(0) * clickAmt;
        exciter = exciter + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0005, 0.008)));
        modes = DynKlank.ar(
            Ref([
                freq * [1.0, 2.14, 3.86, 5.42, 7.1],
                [1.0, 0.7, 0.45, 0.25, 0.1],
                [0.18, 0.12, 0.07, 0.04, 0.02]
            ]),
            exciter,
            decayscale: 0.8
        );
        sig = (modes * 0.7) + (BPF.ar(exciter, freq * 1.8, 0.3) * 0.8);
        sig = (sig * 1.8).tanh * env;
        sig = Pan2.ar(sig, pan, amp);
        Out.ar(out, sig);
    }).add;

    // Discrete Synth: Dobre lento do sino da Sé de Mariana
    SynthDef(\sinoDaSe, {
        |out=0, fund=164.81, decay=7.5, pan=0.0, amp=0.28, strikeAmp=1.2|
        var strike, partials, sig, env;
        env = EnvGen.ar(Env.perc(0.003, decay, 1, -4), doneAction: 2);
        strike = (HPF.ar(WhiteNoise.ar, 1800) * Decay.ar(Impulse.ar(0), 0.012) * strikeAmp);
        strike = strike + (SinOsc.ar(fund * 0.5) * Decay.ar(Impulse.ar(0), 0.15) * 0.6);
        // Relações modais tradicionais de sino eclesiástico de bronze
        partials = DynKlank.ar(
            Ref([
                fund * [0.5, 1.0, 1.19, 1.56, 2.0, 2.74, 3.42, 4.18],
                [0.45, 1.0, 0.65, 0.55, 0.4, 0.28, 0.18, 0.1],
                [decay * 1.1, decay, decay * 0.85, decay * 0.7, decay * 0.55, decay * 0.4, decay * 0.3, decay * 0.2]
            ]),
            strike,
            decayscale: 1.0
        );
        sig = LeakDC.ar(partials) * env;
        sig = Pan2.ar(sig, pan, amp);
        Out.ar(out, sig);
    }).add;
    s.sync;

    // Continuous Texture 1: Vento frio da serra soprando nos beirais e calçamento
    Ndef(\ventoSerra, {
        |amp=0.0, gustRate=0.18, rumbleCut=160|
        var gust, noiseA, noiseB, whistle, sig;
        gust = LFNoise2.kr(gustRate).range(0.15, 1.0);
        noiseA = PinkNoise.ar;
        noiseB = LPF.ar(BrownNoise.ar, rumbleCut) * 2.2;
        whistle = BPF.ar(noiseA, SinOsc.kr(0.08).exprange(380, 1420), 0.08) * gust * 2.5;
        sig = (noiseB * (gust * 0.7 + 0.3)) + whistle;
        sig = [sig, DelayC.ar(sig, 0.03, SinOsc.kr(0.11).range(0.008, 0.025))];
        sig * amp;
    }).fadeTime_(3.5);

    // Continuous Texture 2: Estalar de cera e labareda das tochas penitenciais
    Ndef(\tochasCera, {
        |amp=0.0, crackleDensity=28, sizzleGain=1.5|
        var hiss, crack, pop, sig;
        hiss = BPF.ar(WhiteNoise.ar, 3200, 0.45) * LFNoise1.kr(3.5).range(0.2, 0.8);
        crack = Dust.ar(crackleDensity);
        pop = Decay2.ar(crack, 0.0005, 0.008) * (LFNoise0.ar(crackleDensity * 2).exprange(800, 4800) * crack);
        pop = BPF.ar(pop, 2600, 0.3) * sizzleGain;
        sig = (hiss * 0.15) + (pop * 0.02);
        sig = Splay.ar([sig, Delay1.ar(sig), Delay2.ar(sig)]);
        sig * amp;
    }).fadeTime_(2.5);

    // Master Mixer & Global Acoustics (Arquitetura colonial da praça da Sé)
    Ndef(\masterMix, {
        var dry;
        dry = In.ar(~synthBus, 2);
        dry = dry + Ndef.ar(\ventoSerra, 2) + Ndef.ar(\tochasCera, 2);
        dry;
    }).play;

    Ndef(\masterMix)[10] = \filter -> { |in|
        FreeVerb2.ar(in[0], in[1], 1.0, 0.88, 0.35);
    };
    Ndef(\masterMix)[11] = \filter -> { |in|
        GVerb.ar(in.sum, 120, 4.8, 0.45, 0.4, 25, 0, 0.7, 0.6);
    };
    Ndef(\masterMix).set(\wet10, 0.28, \wet11, 0.32);
    s.sync;

    // Pattern: O bater compassado das matracas de madeira no pé-de-moleque
    Pbindef(\matracasSeq,
        \instrument, \matracaMadeira,
        \out, ~synthBus,
        \dur, Pseq([0.33, 0.33, 0.67, 0.33, 0.34, 0.67], inf),
        \freq, Pseq([340, 360, 320, 390, 350, 310], inf) * Pwhite(0.97, 1.03, inf),
        \clickAmt, Pwhite(2.2, 3.8, inf),
        \durEnv, Pwhite(0.25, 0.42, inf),
        \pan, Pwhite(-0.55, 0.55, inf),
        \amp, Pseq([0.22, 0.17, 0.26, 0.18, 0.16, 0.28], inf)
    );

    // Pattern: Dobre fúnebre e lento do Sino da Sé
    Pbindef(\sinoSeSeq,
        \instrument, \sinoDaSe,
        \out, ~synthBus,
        \dur, Pseq([7.0, 8.5, 6.5, 9.0], inf),
        \fund, Pseq([146.83, 130.81, 146.83, 110.0], inf), // D3, C3, D3, A2
        \decay, Pwhite(6.5, 9.2, inf),
        \pan, Pseq([-0.3, 0.25, -0.15, 0.35], inf),
        \amp, 0.32
    );

    // Choreographed Master Timeline
    Tdef(\masterScore, {
        0.5.wait;
        "0:00 - [Meia-noite em Mariana: o vento frio da serra uiva entre os casarões coloniais]".postln;
        Ndef(\ventoSerra).xset(\amp, 0.24, \gustRate, 0.14);
        Ndef(\tochasCera).xset(\amp, 0.12, \crackleDensity, 18);
        6.wait;

        "0:06 - [As tochas de cera estalam acesas na bruma gélida]".postln;
        Ndef(\tochasCera).xset(\amp, 0.28, \crackleDensity, 38);
        3.do { |i|
            Ndef(\ventoSerra).xset(\rumbleCut, 120 + (i * 35));
            2.0.wait;
        };

        "0:12 - [As matracas de madeira quebram o silêncio, passos compassados no calçamento]".postln;
        Pbindef(\matracasSeq).play;
        4.do { |i|
            Ndef(\masterMix).set(\wet10, 0.28 + (i * 0.04));
            3.0.wait;
        };

        "0:24 - [O primeiro dobre fúnebre do Sino da Sé reverbera na noite escura]".postln;
        Pbindef(\sinoSeSeq).play;
        Ndef(\masterMix).set(\wet11, 0.42);
        8.wait;

        "0:32 - [Procissão dos Penitentes: eco colonial de madeira, bronze, cera e pedra]".postln;
        Ndef(\tochasCera).xset(\amp, 0.35, \crackleDensity, 52);
        Ndef(\ventoSerra).xset(\amp, 0.32, \gustRate, 0.28);
        Pbindef(\matracasSeq, \amp, Pseq([0.28, 0.22, 0.32, 0.24, 0.20, 0.35], inf));
        4.do { |i|
            Ndef(\tochasCera).xset(\sizzleGain, 1.4 + (i * 0.25));
            3.0.wait;
        };

        "0:44 - [A procissão dobra a esquina e se afasta; o dobre do sino domina o eco da praça]".postln;
        Pbindef(\matracasSeq, \amp, Pseq([0.14, 0.10, 0.18, 0.11, 0.09, 0.20], inf));
        Ndef(\tochasCera).xset(\amp, 0.14);
        6.wait;

        "0:50 - [As matracas cessam; restam apenas o eco do sino e o vento na serra deserta]".postln;
        Pbindef(\matracasSeq).stop;
        Pbindef(\matracasSeq).clear;
        Ndef(\masterMix).set(\wet11, 0.55);
        8.wait;

        "0:58 - [O último harmônico do bronze dissipa-se na madrugada]".postln;
        Pbindef(\sinoSeSeq).stop;
        Pbindef(\sinoSeSeq).clear;
        Ndef(\tochasCera).xset(\amp, 0.0);
        Ndef(\ventoSerra).xset(\amp, 0.08);
        6.wait;

        "1:04 - [Silêncio absoluto sobre os casarões fechados]".postln;
        Ndef(\ventoSerra).xset(\amp, 0.0);
        2.5.wait;

        // Scoped cleanup strictly of named resources from this block
        Ndef(\ventoSerra).clear(2);
        Ndef(\tochasCera).clear(2);
        Ndef(\masterMix).clear(2);

        "Score Complete.".postln;
        Tdef(\masterScore).stop;
    });

    Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 10 | MODE: APPEND | FRAG #155
// STATUS: PASS
// PROMPT: Eduardo subiu correndo os degraus de pedra da biblioteca pública de Belo Horizonte com o coração bat...
// ============================================================
(
// Formal Archetype: Settling/Flashback (c) + Addition of narrative layers
// Abruptly dissolve all active rustic/tribal processes into the quiet, resonant interior of the library
Pbindef(\cantoSeq).stop; Ndef(\canto).fadeTime = 3; Ndef(\canto).clear(3);
Pbindef(\chicotadasSeq).stop; Ndef(\chicotadas).fadeTime = 1.5; Ndef(\chicotadas).clear(1.5);
Pbindef(\coisasSemNomeSeq).stop; Ndef(\coisasSemNome).fadeTime = 3; Ndef(\coisasSemNome).clear(3);
Pbindef(\gungasSeq).stop; Ndef(\gungas).fadeTime = 2; Ndef(\gungas).clear(2);
Pbindef(\passarinhosSeq).stop; Ndef(\passarinhos).fadeTime = 2; Ndef(\passarinhos).clear(2);
Pbindef(\rioLodoSeq).stop; Ndef(\rioLodo).fadeTime = 3; Ndef(\rioLodo).clear(3);
Pbindef(\tamboresSeq).stop; Ndef(\tambores).fadeTime = 2; Ndef(\tambores).clear(2);

// ADD_INSTRUMENT: Coração pulsando acelerado na garganta (sub-grave e impacto suave)
Ndef(\coracao, { |t_trig=0, freq=58, amp=0.55, pan=0, rel=0.22|
    var trigSig, env, body, sub, click, sig;
    trigSig = K2A.ar(t_trig);
    env = Decay2.ar(trigSig, 0.008, rel);
    body = SinOsc.ar(XLine.ar(freq * 1.8, freq, 0.06)) * env;
    sub = SinOsc.ar(freq * 0.5) * Decay2.ar(trigSig, 0.015, rel * 1.2);
    click = BPF.ar(WhiteNoise.ar, 480, 0.3) * Decay2.ar(trigSig, 0.001, 0.012) * 0.3;
    sig = (body + sub + click).tanh;
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\coracaoSeq,
    \dur, Pseq([0.18, 0.42], inf), // Sístole-diástole em taquicardia
    \t_trig, 1,
    \freq, Pseq([62, 54], inf),
    \rel, Pseq([0.16, 0.22], inf),
    \amp, Pseq([0.48, 0.38], inf),
    \pan, 0
);
Ndef(\coracao)[1] = \set -> Pbindef(\coracaoSeq);

// ADD_INSTRUMENT: O tilintar metálico e delicado da sineta da pesada porta
Ndef(\sineta, { |t_trig=0, fund=2480, amp=0.28, pan=0.35, decay=2.4|
    var trigSig, exc, modes, sig;
    trigSig = K2A.ar(t_trig);
    exc = Decay.ar(trigSig, 0.002) * WhiteNoise.ar(0.12);
    exc = exc + (SinOsc.ar(fund * 2) * Decay.ar(trigSig, 0.004) * 0.2);
    modes = DynKlank.ar(
        Ref([
            fund * [1.0, 1.48, 2.05, 2.72, 3.48],
            [1.0, 0.6, 0.45, 0.25, 0.12],
            [decay, decay * 0.82, decay * 0.65, decay * 0.45, decay * 0.3]
        ]),
        exc,
        decayscale: 1.0
    );
    sig = LeakDC.ar(modes);
    Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\sinetaSeq,
    \dur, Pseq([1.2, 0.15, 6.0], inf), // Toque inicial e eco ao abrir da porta
    \t_trig, 1,
    \fund, Pseq([2480, 2520, 2480], inf),
    \decay, Pseq([2.8, 1.9, 3.2], inf),
    \amp, Pseq([0.22, 0.16, 0.18], inf),
    \pan, Pwhite(0.1, 0.45, inf)
);
Ndef(\sineta)[1] = \set -> Pbindef(\sinetaSeq);

// ADD_EFFECTS: Salão da biblioteca alta e silenciosa (reverberação arquitetônica)
Ndef(\sineta)[10] = \filter -> { |in|
    GVerb.ar(in.sum, 180, 6.2, 0.35, 0.5, 12, 0, 0.65, 0.6);
};
Ndef(\sineta).xset(\wet10, 0.55);

Ndef(\coracao)[10] = \filter -> { |in|
    FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.25);
};
Ndef(\coracao).xset(\wet10, 0.28);

// Rollback actions:
// Pbindef(\coracaoSeq).stop; Ndef(\coracao).fadeTime = 2; Ndef(\coracao).clear(2);
// Pbindef(\sinetaSeq).stop; Ndef(\sineta).fadeTime = 2; Ndef(\sineta).clear(2);
// Ndef(\sineta).set(\wet10, 0);
// Ndef(\coracao).set(\wet10, 0);
)

