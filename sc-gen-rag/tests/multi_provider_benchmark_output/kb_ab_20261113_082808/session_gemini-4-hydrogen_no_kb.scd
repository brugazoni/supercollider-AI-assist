// ============================================================
// MULTI-PROVIDER BENCHMARK: Gemini 4 Hydrogen
// Model ID: openrouter:google/gemini-4-hydrogen
// Date: 2026-11-13T11:31:57.145317+00:00
// ============================================================


// ============================================================
// ROUND 01 | MODE: APPEND | FRAG #149
// STATUS: PASS
// PROMPT: O casal estava casado havia vinte e sete anos sem nunca ter tido uma discussão pública relevante, at...
// ============================================================
(
Ndef(\antarcticSilence, { |freq=55, amp=0.25, pan=0, cutoff=400, rq=0.2, windAmp=0.15, t_trig=0|
	var env = EnvGen.ar(Env.perc(0.8, 3.5, 1, -4), t_trig);
	var sub = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
	var coldWind = BPF.ar(PinkNoise.ar, cutoff + (env * 600), rq) * 8.0 * windAmp;
	var glass = SinOsc.ar(freq * 7.03, 0, env * 0.15) * SinOsc.kr(0.15).range(0.3, 1.0);
	var sig = (sub * 0.4) + coldWind + glass;
	sig = LPF.ar(sig, 1800);
	Pan2.ar(sig * amp, pan);
}).play;

Pbindef(\silenceSeq,
	\dur, Pwhite(2.5, 5.5, inf),
	\degree, Pseq([0, 1, 0, -1], inf),
	\octave, 2,
	\t_trig, 1,
	\cutoff, Pwhite(250, 550, inf),
	\pan, Pwhite(-0.4, 0.4, inf),
	\amp, Pwhite(0.2, 0.3, inf)
);

Ndef(\antarcticSilence)[1] = \set -> Pbindef(\silenceSeq);
// Pbindef(\silenceSeq).stop; Ndef(\antarcticSilence).fadeTime = 2; Ndef(\antarcticSilence).clear(2); // Rollback: remove this instrument
)


// ============================================================
// ROUND 02 | MODE: COMPOSE | FRAG #50
// STATUS: FIXED
// PROMPT: Na oficina estreita da Ladeira de Santa Efigênia, duzentos relógios de pêndulo, carrilhões franceses...
// ============================================================
(
s.waitForBoot({
	~enableRecording = false;
	if (~synthBus.isNil) { ~synthBus = Bus.audio(s, 2); };

	// --- 1. Safety Limiter ---
	SynthDef(\safetyLimiter, {
		var sig = In.ar(0, 2);
		sig = LeakDC.ar(sig);
		sig = Limiter.ar(sig, 0.85, 0.01);
		ReplaceOut.ar(0, sig);
	}).add;
	s.sync;

	ServerTree.add({ Synth.tail(RootNode(s), \safetyLimiter) });
	if (s.serverRunning) { Synth.tail(RootNode(s), \safetyLimiter); };

	// --- 2. Discrete SynthDefs (Clockwork, Brass Escapements, Chimes) ---
	// Crisp brass escapement tick/tock
	SynthDef(\brassTick, { |out=0, freq=1800, amp=0.25, pan=0, decay=0.045, bright=1.0|
		var env = EnvGen.ar(Env.perc(0.001, decay, 1, -6), doneAction: 2);
		var click = Impulse.ar(0) + (HPF.ar(WhiteNoise.ar, 2200) * EnvGen.ar(Env.perc(0.0005, 0.008)));
		var body = DynKlank.ar(
			Ref([
				[freq, freq * 1.52, freq * 2.71, freq * 4.13],
				[0.6, 0.4, 0.25, 0.15] * bright,
				[decay, decay * 0.7, decay * 0.4, decay * 0.25]
			]),
			click
		);
		var sig = (body * 0.7 + (click * 0.3)) * env;
		sig = HPF.ar(sig, 220);
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	// Pocket chronometer high-speed balance wheel tick
	SynthDef(\chronoTick, { |out=0, freq=4200, amp=0.18, pan=0, decay=0.025|
		var env = EnvGen.ar(Env.perc(0.0005, decay, 1, -8), doneAction: 2);
		var exc = BPF.ar(WhiteNoise.ar, freq, 0.15) * 4.0;
		var ring = Ringz.ar(Impulse.ar(0), freq, decay) * 0.5;
		var sig = (exc + ring) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	// French carillon / pendulum chime (parallel FM bell)
	SynthDef(\carillonChime, { |out=0, freq=440, amp=0.2, pan=0, dur=2.5, index=2.2|
		var env = EnvGen.ar(Env.perc(0.004, dur.max(0.2), 1, -4), doneAction: 2);
		var modEnv = EnvGen.ar(Env.perc(0.001, (dur * 0.35).max(0.05), 1, -6));
		var mod1 = SinOsc.ar(freq * 2.003) * (freq * index * modEnv);
		var mod2 = SinOsc.ar(freq * 3.51) * (freq * index * 0.6 * modEnv);
		var car = SinOsc.ar(freq + mod1 + mod2) + (SinOsc.ar(freq * 0.5) * 0.25);
		var sig = LPF.ar(car, 5500) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;

	// Heavy pendulum thud (low wooden/brass weight)
	SynthDef(\pendulumWeight, { |out=0, freq=78, amp=0.3, pan=0, dur=0.6|
		var env = EnvGen.ar(Env.perc(0.008, dur.max(0.1), 1, -5), doneAction: 2);
		var pEnv = EnvGen.ar(Env.perc(0.001, 0.04, 1, -4));
		var body = SinOsc.ar(freq + (pEnv * freq * 1.5)) + (SinOsc.ar(freq * 2.0) * 0.35);
		var wood = BPF.ar(PinkNoise.ar, freq * 3.2, 0.2) * 3.0 * EnvGen.ar(Env.perc(0.002, 0.08));
		var sig = (body + wood) * env;
		Out.ar(out, Pan2.ar(sig * amp, pan));
	}).add;
	s.sync;

	// --- 3. Continuous Ndefs (Micro-phase swarm & "Breathing of Time") ---
	Ndef(\gearSwarm, { |amp=0, density=28, baseFreq=2400, spread=0.8|
		var trig = Dust.ar(density);
		var pan = TRand.ar(spread.neg, spread, trig);
		var f = TExpRand.ar(baseFreq * 0.5, baseFreq * 2.2, trig);
		var ping = Ringz.ar(trig, f, 0.03) * 0.25;
		var scrape = BPF.ar(WhiteNoise.ar, f * 1.3, 0.08) * Decay.ar(trig, 0.025) * 3.0;
		var sig = Pan2.ar((ping + scrape) * 0.5, pan);
		sig * amp;
	});

	Ndef(\timeBreath, { |amp=0, freq=110, breathRate=0.22, cutoff=600, res=0.35|
		var breath = SinOsc.kr(breathRate).range(0.25, 1.0);
		var detune = [0.996, 1.0, 1.004, 1.498];
		var osc = Splay.ar(Saw.ar(freq * detune) * 0.25);
		var filt = RLPF.ar(osc, (cutoff * breath).clip(80, 4500), res);
		var air = BPF.ar(PinkNoise.ar, (cutoff * 1.5 * breath).clip(150, 5000), 0.25) * 2.5 * breath;
		var sig = LeakDC.ar((filt + air) * 0.6);
		if(sig.isKindOf(Collection)) { Balance2.ar(sig[0], sig[1], SinOsc.kr(0.09), amp) } { Pan2.ar(sig, SinOsc.kr(0.09), amp) } * 0.35;
	});

	// --- 4. Master Mixer & FX ---
	Ndef(\masterMix, {
		var synthIn = In.ar(~synthBus, 2);
		var swarmIn = Ndef.ar(\gearSwarm, 2);
		var breathIn = Ndef.ar(\timeBreath, 2);
		LeakDC.ar(synthIn + swarmIn + breathIn);
	});

	Ndef(\masterMix)[10] = \filter -> { |in|
		FreeVerb2.ar(in[0], in[1], 1.0, 0.72, 0.35);
	};
	Ndef(\masterMix)[11] = \filter -> { |in|
		var dlyL = CombC.ar(in[0], 0.4, 0.23, 1.8);
		var dlyR = CombC.ar(in[1], 0.4, 0.31, 1.8);
		[dlyL, dlyR] * 0.5;
	};
	Ndef(\masterMix).set(\wet10, 0.22, \wet11, 0.12);
	Ndef(\masterMix).play;
	s.sync;

	// --- 5. Chronological Master Score (~95s) ---
	Tdef(\masterScore, {
		0.5.wait;
		"0:00 - [Cue 1: Ladeira de Santa Efigenia - First Pendulums]".postln;
		Pbindef(\pendulumSeq,
			\instrument, \pendulumWeight,
			\out, ~synthBus,
			\dur, Pseq([0.75, 0.75, 0.75, 0.76], inf),
			\freq, Pseq([78, 74], inf),
			\amp, 0.28,
			\pan, Pseq([-0.35, 0.35], inf)
		).play;

		Pbindef(\brassSeqA,
			\instrument, \brassTick,
			\out, ~synthBus,
			\dur, Pseq([0.25, 0.25, 0.25, 0.255], inf),
			\freq, Pwhite(1400, 1950, inf),
			\decay, 0.045,
			\amp, Pwhite(0.14, 0.22, inf),
			\pan, Pwhite(-0.6, 0.6, inf)
		).play;
		6.wait;

		"0:06 - [Cue 2: Pocket Chronometers & Phase Drift]".postln;
		Pbindef(\chronoSeq,
			\instrument, \chronoTick,
			\out, ~synthBus,
			\dur, Pseq([0.125, 0.125, 0.127, 0.125], inf),
			\freq, Pwhite(3600, 5200, inf),
			\amp, Pwhite(0.08, 0.16, inf),
			\pan, Pwhite(-0.85, 0.85, inf)
		).play;

		Ndef(\gearSwarm).fadeTime = 4.0;
		Ndef(\gearSwarm).xset(\amp, 0.16, \density, 18, \baseFreq, 2200);
		8.wait;

		"0:14 - [Cue 3: French Carillons Enter]".postln;
		Pbindef(\carillonSeq,
			\instrument, \carillonChime,
			\out, ~synthBus,
			\dur, Pwhite(1.8, 3.4, inf),
			\midinote, Prand([64, 67, 71, 74, 76, 79, 83], inf),
			\dur, Pwhite(1.6, 3.2, inf),
			\index, Pwhite(1.5, 2.8, inf),
			\amp, Pwhite(0.1, 0.17, inf),
			\pan, Pwhite(-0.75, 0.75, inf)
		).play;
		Ndef(\masterMix).set(\wet10, 0.32, \wet11, 0.2);

		3.do { |i|
			Ndef(\gearSwarm).xset(\density, 25 + (i * 15), \baseFreq, 2400 + (i * 400));
			4.wait;
		};

		"0:26 - [Cue 4: Intrinsic Limit - The 200-Clock Swarm]".postln;
		Ndef(\gearSwarm).fadeTime = 3.0;
		Ndef(\gearSwarm).xset(\amp, 0.3, \density, 85, \baseFreq, 3400);
		Pbindef(\brassSeqA, \dur, Pseq([0.16, 0.165, 0.16, 0.17], inf), \amp, Pwhite(0.18, 0.26, inf));
		Pbindef(\chronoSeq, \dur, Pseq([0.08, 0.082, 0.08, 0.083], inf), \amp, Pwhite(0.12, 0.2, inf));
		7.wait;

		"0:33 - [Cue 5: Settling - Watchmaker Closes His Eyes (Breathing of Time)]".postln;
		Pbindef(\brassSeqA).stop;
		Pbindef(\chronoSeq).stop;
		Ndef(\gearSwarm).fadeTime = 2.5;
		Ndef(\gearSwarm).xset(\amp, 0.06, \density, 12, \baseFreq, 1600);

		Ndef(\timeBreath).fadeTime = 4.0;
		Ndef(\timeBreath).xset(\amp, 0.32, \freq, 110, \breathRate, 0.2, \cutoff, 750);
		Ndef(\masterMix).set(\wet10, 0.45, \wet11, 0.28);

		4.do { |i|
			Ndef(\timeBreath).xset(\cutoff, [650, 900, 580, 1050].at(i), \breathRate, 0.18 + (i * 0.03));
			4.wait;
		};

		"0:49 - [Cue 6: Resolution - Return of Brass & Carillon]".postln;
		Pbindef(\brassSeqA, \dur, Pseq([0.25, 0.25, 0.255, 0.25], inf), \amp, Pwhite(0.12, 0.18, inf)).play;
		Pbindef(\carillonSeq, \dur, Pwhite(2.2, 4.0, inf), \amp, Pwhite(0.12, 0.19, inf));
		Ndef(\timeBreath).fadeTime = 5.0;
		Ndef(\timeBreath).xset(\amp, 0.22, \cutoff, 520);
		Ndef(\gearSwarm).xset(\amp, 0.12, \density, 22);
		8.wait;

		"0:57 - [Cue 7: Extrinsic Limit - Final Winding Down]".postln;
		Pbindef(\pendulumSeq).stop;
		Pbindef(\carillonSeq).stop;
		Ndef(\gearSwarm).fadeTime = 4.0;
		Ndef(\gearSwarm).xset(\amp, 0.0, \density, 6);
		Ndef(\timeBreath).fadeTime = 5.0;
		Ndef(\timeBreath).xset(\amp, 0.0);
		5.wait;

		Pbindef(\brassSeqA).stop;
		3.wait;

		// --- 6. Scoped Termination (Shared Server Safe) ---
		Pbindef(\pendulumSeq).stop; Pbindef(\pendulumSeq).clear;
		Pbindef(\brassSeqA).stop; Pbindef(\brassSeqA).clear;
		Pbindef(\chronoSeq).stop; Pbindef(\chronoSeq).clear;
		Pbindef(\carillonSeq).stop; Pbindef(\carillonSeq).clear;
		Ndef(\gearSwarm).clear(2);
		Ndef(\timeBreath).clear(2);
		Ndef(\masterMix).clear(2);
		"Score Complete.".postln;
		Tdef(\masterScore).stop;
	});
	Tdef(\masterScore).play;
});
)


// ============================================================
// ROUND 03 | MODE: DESIGN | FRAG #74
// STATUS: FIXED
// PROMPT: Close-up fotográfico de um gabinete de sintetizador modular em um estúdio penumbroso, repleto de pot...
// ============================================================
(
// --- 0. CC Map ---
~cc = (
    vol1: 7, pan1: 10, mute1: 11, min1: 12, max1: 13, hpf1: 14, lpf1: 15, rq1: 16, atk1: 17, dec1: 18, sus1: 19, rls1: 20, fx1: 21,
    vol2: 22, pan2: 23, mute2: 24, min2: 25, max2: 26, hpf2: 27, lpf2: 28, rq2: 29, atk2: 30, dec2: 31, sus2: 32, rls2: 33, fx2: 34,
    vol3: 35, pan3: 36, mute3: 37, min3: 38, max3: 39, hpf3: 40, lpf3: 41, rq3: 42, atk3: 43, dec3: 44, sus3: 45, rls3: 46, fx3: 47,
    delMix: 91, delTime: 92, verbMix: 93, revTime: 94, panic: 123
);

// --- 1 & 2. MIDI Auto-Detection with Hardware Fallback ---
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

// --- 3. Server Boot, Buses, SynthDefs, MIDIdefs & GUI ---
s.waitForBoot({
    var screen, winW, winH, navY, pageY, botY;

    ~ccVals = (
        vol1: 0.25, pan1: 0.0, mute1: 0.0, min1: 0, max1: 60, hpf1: 28, lpf1: 240, rq1: 0.45, atk1: 0.015, dec1: 0.25, sus1: 0.7, rls1: 0.35, fx1: 0.0,
        vol2: 0.22, pan2: -0.35, mute2: 0.0, min2: 36, max2: 108, hpf2: 260, lpf2: 6800, rq2: 0.35, atk2: 0.008, dec2: 0.35, sus2: 0.45, rls2: 0.65, fx2: 0.0,
        vol3: 0.20, pan3: 0.35, mute3: 0.0, min3: 30, max3: 127, hpf3: 180, lpf3: 3600, rq3: 0.4, atk3: 0.35, dec3: 0.6, sus3: 0.75, rls3: 1.4, fx3: 0.0,
        delMix: 0.0, delTime: 0.32, verbMix: 0.0, revTime: 2.2
    );

    ~buses = ();
    ~ccVals.keysValuesDo { |k, v| ~buses[k] = Bus.control(s, 1).set(v) };

    ~fxBus = Bus.audio(s, 2);
    ~masterBus = Bus.audio(s, 2);

    ~synthGroup = Group.new(s);
    ~fxGroup = Group.after(~synthGroup);
    ~masterGroup = Group.after(~fxGroup);

    ~subSynth = nil;
    ~subNote = nil;
    ~zone2Notes = Array.newClear(128);
    ~zone3Notes = Array.newClear(128);

    // Zone 1: Analog Core (Monophonic Portamento Sub + Wavefolder + MoogFF)
    SynthDef(\modularSub, {
        |out=0, freq=55, amp=0.5, gate=1, vol=0.25, pan=0.0, mute=0.0,
        hpf=28, lpf=240, rq=0.45, atk=0.015, dec=0.25, sus=0.7, rls=0.35, fx=0.0|
        var f, env, osc, folded, filt, sig;
        f = Lag.kr(freq, 0.12);
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        osc = (Saw.ar(f) * 0.6) + (SinOsc.ar(f * 0.5) * 0.5);
        folded = Fold.ar(osc * (1.0 + (fx * 4.5)), -0.85, 0.85);
        filt = (MoogFF.ar(folded, lpf.clip(20, 18000), (1.0 - rq).linlin(0, 1, 0.5, 3.6)) * 2.2).tanh;
        filt = HPF.ar(filt, hpf.clip(20, 18000));
        sig = filt * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 2: Pin Matrix FM (Lissajous Harmonics)
    SynthDef(\lissajousFM, {
        |out=0, freq=220, amp=0.5, gate=1, vol=0.22, pan=(-0.35), mute=0.0,
        hpf=260, lpf=6800, rq=0.35, atk=0.008, dec=0.35, sus=0.45, rls=0.65, fx=0.0|
        var env, mod, car, filt, sig;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        mod = SinOsc.ar(freq * 2.71) * (freq * (0.4 + (fx * 3.5)));
        car = SinOscFB.ar(freq + mod, fx * 0.85);
        filt = RLPF.ar(car, lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        filt = HPF.ar(filt, hpf.clip(20, 18000));
        sig = filt * env * amp * vol * (1.0 - mute);
        Out.ar(out, Pan2.ar(sig, pan));
    }).add;

    // Zone 3: Phosphor Pad (CRT Drift SuperSaw + Pulse)
    SynthDef(\phosphorPad, {
        |out=0, freq=220, amp=0.5, gate=1, vol=0.20, pan=0.35, mute=0.0,
        hpf=180, lpf=3600, rq=0.4, atk=0.35, dec=0.6, sus=0.75, rls=1.4, fx=0.0|
        var env, detune, saws, pls, mix, filt;
        env = EnvGen.kr(Env.adsr(atk, dec, sus, rls), gate, doneAction: 2);
        detune = 0.006 + (fx * 0.025);
        saws = Splay.ar(Saw.ar(freq * [1.0 - (detune * 2), 1.0 - detune, 1.0, 1.0 + detune, 1.0 + (detune * 2)]));
        pls = Pulse.ar(freq * 0.501, 0.38, 0.35);
        mix = (saws * 0.7) + [pls, pls];
        filt = RLPF.ar(mix, lpf.clip(20, 18000), rq.clip(0.05, 1.0));
        filt = HPF.ar(filt, hpf.clip(20, 18000));
        Out.ar(out, if(filt.isKindOf(Collection)) { Balance2.ar(filt[0], filt[1], pan, env * amp * vol * (1.0 - mute)) } { Pan2.ar(filt, pan, env * amp * vol * (1.0 - mute)) });
    }).add;

    // Group FX: Stereo Delay & Phosphor Reverb
    SynthDef(\groupFX, {
        |in=0, out=0, delMix=0.0, delTime=0.32, verbMix=0.0, revTime=2.2|
        var dry, delL, delR, del, verb, wet;
        dry = In.ar(in, 2);
        delL = CombL.ar(dry[0], 1.2, delTime.clip(0.02, 1.0), 2.5);
        delR = CombL.ar(dry[1], 1.2, (delTime * 1.18).clip(0.02, 1.0), 2.5);
        del = [delL, delR] * delMix;
        verb = FreeVerb2.ar(dry[0] + del[0], dry[1] + del[1], 1.0, revTime.linlin(0.2, 8.0, 0.2, 0.92), 0.35);
        wet = dry + del + (verb * verbMix);
        Out.ar(out, wet);
    }).add;

    // Master Safety Limiter
    SynthDef(\safetyLimiter, {
        |in=0, out=0|
        var sig = In.ar(in, 2);
        sig = LeakDC.ar(sig);
        sig = Limiter.ar(sig, 0.92, 0.01);
        Out.ar(out, sig);
    }).add;

    s.sync;

    ~fxSynth = Synth.tail(~fxGroup, \groupFX, [
        \in, ~fxBus, \out, ~masterBus,
        \delMix, ~buses[\delMix].asMap, \delTime, ~buses[\delTime].asMap,
        \verbMix, ~buses[\verbMix].asMap, \revTime, ~buses[\revTime].asMap
    ]);
    ~masterSynth = Synth.tail(~masterGroup, \safetyLimiter, [\in, ~masterBus, \out, 0]);

    // --- 4. MIDI Responders ---
    MIDIdef.noteOn(\synthNoteOn, { |vel, noteNum|
        var amp = (vel / 127.0).linlin(0, 1, 0.15, 1.0);
        var freq = noteNum.midicps;

        if((noteNum >= ~ccVals[\min1]) and: { noteNum <= ~ccVals[\max1] }) {
            ~subNote = noteNum;
            if(~subSynth.isNil) {
                ~subSynth = Synth.head(~synthGroup, \modularSub, [
                    \out, ~fxBus, \freq, freq, \amp, amp, \gate, 1,
                    \vol, ~buses[\vol1].asMap, \pan, ~buses[\pan1].asMap, \mute, ~buses[\mute1].asMap,
                    \hpf, ~buses[\hpf1].asMap, \lpf, ~buses[\lpf1].asMap, \rq, ~buses[\rq1].asMap,
                    \atk, ~buses[\atk1].asMap, \dec, ~buses[\dec1].asMap, \sus, ~buses[\sus1].asMap,
                    \rls, ~buses[\rls1].asMap, \fx, ~buses[\fx1].asMap
                ]);
                ~subSynth.onFree({ ~subSynth = nil });
            } {
                ~subSynth.set(\freq, freq, \amp, amp, \gate, 1);
            };
        };

        if((noteNum >= ~ccVals[\min2]) and: { noteNum <= ~ccVals[\max2] }) {
            ~zone2Notes[noteNum] = ~zone2Notes[noteNum].add(
                Synth.head(~synthGroup, \lissajousFM, [
                    \out, ~fxBus, \freq, freq, \amp, amp, \gate, 1,
                    \vol, ~buses[\vol2].asMap, \pan, ~buses[\pan2].asMap, \mute, ~buses[\mute2].asMap,
                    \hpf, ~buses[\hpf2].asMap, \lpf, ~buses[\lpf2].asMap, \rq, ~buses[\rq2].asMap,
                    \atk, ~buses[\atk2].asMap, \dec, ~buses[\dec2].asMap, \sus, ~buses[\sus2].asMap,
                    \rls, ~buses[\rls2].asMap, \fx, ~buses[\fx2].asMap
                ])
            );
        };

        if((noteNum >= ~ccVals[\min3]) and: { noteNum <= ~ccVals[\max3] }) {
            ~zone3Notes[noteNum] = ~zone3Notes[noteNum].add(
                Synth.head(~synthGroup, \phosphorPad, [
                    \out, ~fxBus, \freq, freq, \amp, amp, \gate, 1,
                    \vol, ~buses[\vol3].asMap, \pan, ~buses[\pan3].asMap, \mute, ~buses[\mute3].asMap,
                    \hpf, ~buses[\hpf3].asMap, \lpf, ~buses[\lpf3].asMap, \rq, ~buses[\rq3].asMap,
                    \atk, ~buses[\atk3].asMap, \dec, ~buses[\dec3].asMap, \sus, ~buses[\sus3].asMap,
                    \rls, ~buses[\rls3].asMap, \fx, ~buses[\fx3].asMap
                ])
            );
        };
    }, srcID: ~myUid);

    MIDIdef.noteOff(\synthNoteOff, { |vel, noteNum|
        if(noteNum == ~subNote and: { ~subSynth.notNil }) {
            ~subSynth.set(\gate, 0);
            ~subNote = nil;
        };
        if(~zone2Notes[noteNum].notNil) {
            ~zone2Notes[noteNum].do(_.set(\gate, 0));
            ~zone2Notes[noteNum] = nil;
        };
        if(~zone3Notes[noteNum].notNil) {
            ~zone3Notes[noteNum].do(_.set(\gate, 0));
            ~zone3Notes[noteNum] = nil;
        };
    }, srcID: ~myUid);

    MIDIdef.cc(\synthCC, { |val, num|
        var norm = val / 127.0;
        ~cc.keysValuesDo { |key, ccNum|
            if(num == ccNum) {
                var ks = key.asString;
                var v = case
                    { ks.matchRegexp("lpf|hpf") } { norm.linexp(0, 1, 20, 18000) }
                    { ks.contains("rq") } { norm.linexp(0, 1, 1.0, 0.05) }
                    { ks.contains("pan") } { norm.linlin(0, 1, -1.0, 1.0) }
                    { ks.matchRegexp("atk|dec|sus|rls") } { norm.linexp(0, 1, 0.005, 5.0) }
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

    MIDIdef.cc(\panicCC, { |val|
        if(val > 0) {
            ~synthGroup.set(\gate, 0);
            ~subSynth = nil;
            ~zone2Notes = Array.newClear(128);
            ~zone3Notes = Array.newClear(128);
        };
    }, ccNum: ~cc[\panic], srcID: ~myUid);

    // --- 5. Paginated GUI ---
    defer {
        var zoneMeta, tabBtns, pages, activePage = 0, switchPage;

        if(~mainWin.notNil and: { ~mainWin.isClosed.not }) { ~mainWin.close };
        screen = Window.availableBounds;
        winW = min(840, screen.width - 40);
        winH = min(680, screen.height - 60);

        ~mainWin = Window("MODULAR MATRIX & PHOSPHOR OSCILLOSCOPE", Rect(
            (screen.width - winW) * 0.5, (screen.height - winH) * 0.5, winW, winH
        ), scroll: true).background_(Color.gray(0.11));

        ~ui = ();
        zoneMeta = [
            (title: "Z1: ANALOG CORE (SUB)", fxKey: \fx1, fxLabel: "Wavefold"),
            (title: "Z2: PIN MATRIX FM", fxKey: \fx2, fxLabel: "Lissajous FB"),
            (title: "Z3: PHOSPHOR PAD", fxKey: \fx3, fxLabel: "CRT Drift")
        ];

        navY = 12; pageY = 52; botY = winH - 110;
        tabBtns = Array.newClear(zoneMeta.size);
        pages = Array.newClear(zoneMeta.size);

        switchPage = { |idx|
            activePage = idx;
            pages.do { |pg, j| pg.visible = (j == idx) };
            tabBtns.do { |bt, j|
                bt.states = [[zoneMeta[j].title, Color.white, if(j == idx, Color(0.15, 0.55, 0.35), Color.gray(0.22))]];
            };
        };

        zoneMeta.do { |zm, idx|
            var zNum = idx + 1;
            var pg, kVol, kPan, kHpf, kLpf, kRq, kAtk, kDec, kSus, kRls, kFx, rKey, bMute;
            var setVal = { |k, v| ~ccVals[k] = v; if(~buses[k].notNil) { ~buses[k].set(v) } };

            tabBtns[idx] = Button(~mainWin, Rect(12 + (idx * 210), navY, 200, 30))
                .action_({ switchPage.value(idx) });

            pg = CompositeView(~mainWin, Rect(12, pageY, winW - 24, botY - pageY - 10))
                .background_(Color.gray(0.15));
            pages[idx] = pg;

            StaticText(pg, Rect(12, 8, 400, 22)).string_(zm.title)
                .stringColor_(Color(0.4, 0.95, 0.6)).font_(Font("Helvetica", 14, true));

            bMute = Button(pg, Rect(pg.bounds.width - 110, 8, 95, 24))
                .states_([["ACTIVE", Color.black, Color(0.35, 0.85, 0.5)], ["MUTED", Color.white, Color(0.75, 0.2, 0.2)]])
                .action_({ |b| setVal.value(("mute" ++ zNum).asSymbol, b.value.asFloat) });
            ~ui[("mute" ++ zNum).asSymbol] = bMute;

            rKey = EZRanger(pg, Rect(12, 38, pg.bounds.width - 24, 26), "Key Range", ControlSpec(0, 127, \lin, 1),
                { |ez|
                    setVal.value(("min" ++ zNum).asSymbol, ez.lo);
                    setVal.value(("max" ++ zNum).asSymbol, ez.hi);
                }, [~ccVals[("min" ++ zNum).asSymbol], ~ccVals[("max" ++ zNum).asSymbol]], labelWidth: 85);
            rKey.setColors(Color.gray(0.2), Color.white, Color.gray(0.25), Color(0.3, 0.85, 0.5));

            kVol = EZKnob(pg, Rect(16, 80, 80, 95), "Vol CC" ++ ~cc[("vol" ++ zNum).asSymbol], ControlSpec(0, 1, \lin),
                { |ez| setVal.value(("vol" ++ zNum).asSymbol, ez.value) }, ~ccVals[("vol" ++ zNum).asSymbol]);
            kPan = EZKnob(pg, Rect(106, 80, 80, 95), "Pan CC" ++ ~cc[("pan" ++ zNum).asSymbol], ControlSpec(-1, 1, \lin),
                { |ez| setVal.value(("pan" ++ zNum).asSymbol, ez.value) }, ~ccVals[("pan" ++ zNum).asSymbol]);
            kHpf = EZKnob(pg, Rect(196, 80, 80, 95), "HPF CC" ++ ~cc[("hpf" ++ zNum).asSymbol], ControlSpec(20, 18000, \exp),
                { |ez| setVal.value(("hpf" ++ zNum).asSymbol, ez.value) }, ~ccVals[("hpf" ++ zNum).asSymbol]);
            kLpf = EZKnob(pg, Rect(286, 80, 80, 95), "LPF CC" ++ ~cc[("lpf" ++ zNum).asSymbol], ControlSpec(20, 18000, \exp),
                { |ez| setVal.value(("lpf" ++ zNum).asSymbol, ez.value) }, ~ccVals[("lpf" ++ zNum).asSymbol]);
            kRq = EZKnob(pg, Rect(376, 80, 80, 95), "Res CC" ++ ~cc[("rq" ++ zNum).asSymbol], ControlSpec(1.0, 0.05, \exp),
                { |ez| setVal.value(("rq" ++ zNum).asSymbol, ez.value) }, ~ccVals[("rq" ++ zNum).asSymbol]);

            kAtk = EZKnob(pg, Rect(16, 195, 80, 95), "Atk CC" ++ ~cc[("atk" ++ zNum).asSymbol], ControlSpec(0.005, 5.0, \exp),
                { |ez| setVal.value(("atk" ++ zNum).asSymbol, ez.value) }, ~ccVals[("atk" ++ zNum).asSymbol]);
            kDec = EZKnob(pg, Rect(106, 195, 80, 95), "Dec CC" ++ ~cc[("dec" ++ zNum).asSymbol], ControlSpec(0.005, 5.0, \exp),
                { |ez| setVal.value(("dec" ++ zNum).asSymbol, ez.value) }, ~ccVals[("dec" ++ zNum).asSymbol]);
            kSus = EZKnob(pg, Rect(196, 195, 80, 95), "Sus CC" ++ ~cc[("sus" ++ zNum).asSymbol], ControlSpec(0.005, 1.0, \lin),
                { |ez| setVal.value(("sus" ++ zNum).asSymbol, ez.value) }, ~ccVals[("sus" ++ zNum).asSymbol]);
            kRls = EZKnob(pg, Rect(286, 195, 80, 95), "Rls CC" ++ ~cc[("rls" ++ zNum).asSymbol], ControlSpec(0.005, 5.0, \exp),
                { |ez| setVal.value(("rls" ++ zNum).asSymbol, ez.value) }, ~ccVals[("rls" ++ zNum).asSymbol]);
            kFx = EZKnob(pg, Rect(376, 195, 80, 95), zm.fxLabel ++ " CC" ++ ~cc[zm.fxKey], ControlSpec(0, 1, \lin),
                { |ez| setVal.value(zm.fxKey, ez.value) }, ~ccVals[zm.fxKey]);

            [kVol, kPan, kHpf, kLpf, kRq, kAtk, kDec, kSus, kRls, kFx].do { |k|
                k.setColors(Color.gray(0.15), Color.white, Color.gray(0.25), Color(0.35, 0.9, 0.55));
            };

            ~ui[("vol" ++ zNum).asSymbol] = kVol; ~ui[("pan" ++ zNum).asSymbol] = kPan;
            ~ui[("hpf" ++ zNum).asSymbol] = kHpf; ~ui[("lpf" ++ zNum).asSymbol] = kLpf;
            ~ui[("rq" ++ zNum).asSymbol] = kRq; ~ui[("atk" ++ zNum).asSymbol] = kAtk;
            ~ui[("dec" ++ zNum).asSymbol] = kDec; ~ui[("sus" ++ zNum).asSymbol] = kSus;
            ~ui[("rls" ++ zNum).asSymbol] = kRls; ~ui[zm.fxKey] = kFx;
        };

        switchPage.value(0);

        // Static Bottom Bar
        ~ui[\delMix] = EZSlider(~mainWin, Rect(12, botY, 260, 24), "Delay Mix CC91", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\delMix] = ez.value; ~buses[\delMix].set(ez.value) }, ~ccVals[\delMix], labelWidth: 105);
        ~ui[\delTime] = EZSlider(~mainWin, Rect(12, botY + 30, 260, 24), "Delay Time CC92", ControlSpec(0.02, 1.0, \exp),
            { |ez| ~ccVals[\delTime] = ez.value; ~buses[\delTime].set(ez.value) }, ~ccVals[\delTime], labelWidth: 105);
        ~ui[\verbMix] = EZSlider(~mainWin, Rect(290, botY, 260, 24), "Verb Mix CC93", ControlSpec(0, 1, \lin),
            { |ez| ~ccVals[\verbMix] = ez.value; ~buses[\verbMix].set(ez.value) }, ~ccVals[\verbMix], labelWidth: 105);
        ~ui[\revTime] = EZSlider(~mainWin, Rect(290, botY + 30, 260, 24), "Verb Time CC94", ControlSpec(0.2, 8.0, \exp),
            { |ez| ~ccVals[\revTime] = ez.value; ~buses[\revTime].set(ez.value) }, ~ccVals[\revTime], labelWidth: 105);

        [~ui[\delMix], ~ui[\delTime], ~ui[\verbMix], ~ui[\revTime]].do { |sl|
            sl.setColors(Color.gray(0.15), Color.white, Color.gray(0.25), Color(0.35, 0.9, 0.55));
        };

        Button(~mainWin, Rect(winW - 160, botY + 6, 145, 44))
            .states_([["PANIC (ALL OFF)", Color.white, Color(0.75, 0.15, 0.15)]])
            .action_({
                ~synthGroup.set(\gate, 0);
                ~subSynth = nil;
                ~zone2Notes = Array.newClear(128);
                ~zone3Notes = Array.newClear(128);
            });

        ~mainWin.front;

        Routine({
            while { ~mainWin.notNil and: { ~mainWin.isClosed.not } } {
                if(~ui.notNil) {
                    ~ccVals.keysValuesDo { |k, v|
                        if(~ui[k].notNil and: { v.notNil }) { ~ui[k].value = v };
                    };
                };
                0.05.wait;
            };
        }).play(AppClock);
    };

// (~mainWin.notNil and: { ~mainWin.isClosed.not }).if({ ~mainWin.close }); ~synthGroup.free; ~fxGroup.free; ~masterGroup.free;
});
)


// ============================================================
// ROUND 04 | MODE: GENERATE | FRAG #92
// STATUS: PASS
// PROMPT: A Congada é uma manifestação folclórica e religiosa sincrética brasileira que celebra a coroação de ...
// ============================================================
(
Ndef(\congadaCaixa).clear;
Ndef(\congadaCaixa).fadeTime = 2;
Ndef(\congadaCaixa, { |freq=95, amp=0.24, pan=0.0, snare=0.35, t_trig=1|
	var trigA, pEnv, body, rattle, sig;
	trigA = K2A.ar(t_trig);
	pEnv = EnvGen.ar(Env.perc(0.002, 0.09, 1, -6), t_trig);
	body = SinOsc.ar(freq * (1 + (pEnv * 1.8))) * EnvGen.ar(Env.perc(0.003, 0.24, 1, -4), t_trig);
	rattle = BPF.ar(PinkNoise.ar, 1850, 0.5) * Decay2.ar(trigA, 0.002, 0.14) * snare * 4.0;
	sig = (body + rattle).tanh;
	Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaCaixa)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.55, 0.4);
};
Ndef(\congadaCaixa).set(\wet10, 0.22);

Pbindef(\caixaSeq,
	\dur, Pwrand([0.25, 0.5, 0.125], [0.55, 0.3, 0.15], inf),
	\freq, Pseq([92, 92, 118, 92, 105, 92, 128, 96], inf),
	\snare, Pseq([0.25, 0.45, 0.15, 0.5, 0.3, 0.4, 0.2, 0.55], inf),
	\amp, Pseq([0.26, 0.16, 0.22, 0.18, 0.24, 0.15, 0.2, 0.22], inf),
	\t_trig, 1
);
Ndef(\congadaCaixa).quant = 1;
Ndef(\congadaCaixa)[1] = \set -> Pbindef(\caixaSeq);

Ndef(\congadaGungas).clear;
Ndef(\congadaGungas).fadeTime = 2;
Ndef(\congadaGungas, { |freq=1420, amp=0.14, pan=0.0, decay=0.11, t_trig=1|
	var trigA, exc, modes, sig;
	trigA = K2A.ar(t_trig);
	exc = HPF.ar(WhiteNoise.ar, 900) * Decay2.ar(trigA, 0.001, 0.035);
	modes = DynKlank.ar(
		Ref([
			[1.0, 1.53, 2.31, 3.17, 4.42] * freq,
			[0.9, 0.7, 0.5, 0.35, 0.2],
			[0.8, 0.6, 0.45, 0.3, 0.2]
		]),
		exc,
		decayscale: decay
	);
	sig = (modes * 0.45).tanh;
	Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaGungas)[10] = \filter -> { |in|
	CombL.ar(in, 0.5, 0.1875, 1.4);
};
Ndef(\congadaGungas).set(\wet10, 0.25);

Pbindef(\gungasSeq,
	\dur, Pseq([0.125, 0.125, 0.25, 0.125, 0.125, 0.125, 0.125], inf),
	\freq, Pwrand([1380, 1540, 1720, 1260], [0.4, 0.3, 0.2, 0.1], inf),
	\decay, Pwhite(0.08, 0.16, inf),
	\pan, Pwhite(-0.65, 0.65, inf),
	\amp, Pseq([0.16, 0.09, 0.14, 0.1, 0.15, 0.08, 0.13], inf),
	\t_trig, 1
);
Ndef(\congadaGungas).quant = 1;
Ndef(\congadaGungas)[1] = \set -> Pbindef(\gungasSeq);

Ndef(\congadaCanto).clear;
Ndef(\congadaCanto).fadeTime = 3;
Ndef(\congadaCanto, { |freq=220, amp=0.13, pan=(-0.15), vowel=0.5, t_trig=1|
	var vib, env, osc, f1, f2, f3, formants, sig;
	vib = LFNoise1.kr(4.5).range(0.992, 1.008);
	env = EnvGen.ar(Env.perc(0.18, 1.35, 1, -3), t_trig);
	osc = (Saw.ar(freq * vib) * 0.6) + (Pulse.ar(freq * 0.5 * vib, 0.45) * 0.4);
	f1 = LinSelectX.kr(vowel * 2, [700, 450, 320]);
	f2 = LinSelectX.kr(vowel * 2, [1200, 800, 750]);
	f3 = LinSelectX.kr(vowel * 2, [2500, 2300, 2150]);
	formants = BPF.ar(osc, [f1, f2, f3], 0.14).sum * 5.5;
	sig = (formants * env).tanh;
	Pan2.ar(sig, pan, amp);
}).play;

Ndef(\congadaCanto)[10] = \filter -> { |in|
	FreeVerb2.ar(in[0], in[1], 1.0, 0.78, 0.35);
};
Ndef(\congadaCanto).set(\wet10, 0.42);

Pbindef(\cantoSeq,
	\dur, Pseq([1.5, 1.5, 1.0, 2.0, 1.0, 1.0], inf),
	\degree, Pseq([0, 2, 3, 4, 2, 0], inf),
	\scale, Scale.mixolydian,
	\octave, 4,
	\vowel, Pwhite(0.0, 1.0, inf),
	\pan, Pwhite(-0.35, 0.35, inf),
	\t_trig, 1
);
Ndef(\congadaCanto).quant = 1;
Ndef(\congadaCanto)[1] = \set -> Pbindef(\cantoSeq);
)

// Ndef(\congadaGungas).xset(\decay, 0.25); // Longer metallic ring | Revert: Ndef(\congadaGungas).xset(\decay, 0.11);
// Pbindef(\caixaSeq, \dur, 0.125); // Double-time march | Revert: Pbindef(\caixaSeq, \dur, Pwrand([0.25, 0.5, 0.125], [0.55, 0.3, 0.15], inf));
// Pbindef(\caixaSeq).stop; Ndef(\congadaCaixa).fadeTime = 4; Ndef(\congadaCaixa).clear(4); // Rollback Caixa
// Pbindef(\gungasSeq).stop; Ndef(\congadaGungas).fadeTime = 4; Ndef(\congadaGungas).clear(4); // Rollback Gungas
// Pbindef(\cantoSeq).stop; Ndef(\congadaCanto).fadeTime = 4; Ndef(\congadaCanto).clear(4); // Rollback Canto

