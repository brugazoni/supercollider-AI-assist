ScPerfMixer {
	classvar <server;
	classvar <enabled = true;
	classvar <>forceTestMode = false;
	classvar <meterPort = 0;
	classvar meterAddr;
	classvar meterOscFunc;
	classvar reconcileTask;
	classvar tracks;          // IdentityDictionary: idSymbol -> IdentityDictionary
	classvar controllers;     // IdentityDictionary: idSymbol -> SimpleController / Function
	classvar pbindOrigState;  // IdentityDictionary: key -> (out: ..., group: ..., bus: ...)
	classvar freedDesignIds;  // IdentitySet of nodeIDs already freed via /n_end
	classvar pbindSourceGroup;
	classvar pbindReturnGroup;
	classvar nextMeterId = 1;
	classvar lastSyncSignature = "";
	classvar synthDefsLoaded = false;
	classvar initialized = false;

	*initClass {
		Class.initClassTree(Server);
		Class.initClassTree(NodeWatcher);
		Class.initClassTree(Pdef);
		tracks = IdentityDictionary.new;
		controllers = IdentityDictionary.new;
		pbindOrigState = IdentityDictionary.new;
		freedDesignIds = IdentitySet.new;
	}

	*isIDEProcess {
		^forceTestMode or: { (Platform.ideName.asSymbol == \scqt) and: { ScIDE.connected } }
	}

	*initForIDE { |argServer|
		if(this.isIDEProcess.not) { ^this };
		server = argServer ?? { Server.default };
		if(server.isNil) { ^this };

		// Ensure enough RT memory for multiple concurrent track Reverbs/Companders
		// if the server hasn't booted yet.
		if(server.serverRunning.not and: { server.options.memSize < 65536 }) {
			server.options.memSize = 65536;
		};

		if(initialized.not) {
			initialized = true;
			ServerBoot.add({ this.onServerBoot }, server);
			ServerTree.add({ this.onServerTree }, server);
			ServerQuit.add({ this.onServerQuit }, server);
			CmdPeriod.add({ this.onCmdPeriod });
			this.startReconcileLoop;
		};

		if(server.serverRunning) {
			this.onServerBoot;
			this.onServerTree;
		};
	}

	*setMeterPort { |port|
		meterPort = port.asInteger;
		if(meterPort > 0) {
			meterAddr = NetAddr("127.0.0.1", meterPort);
			if(meterOscFunc.isNil and: { server.notNil }) {
				this.setupMeterForwarder;
			};
		} {
			meterAddr = nil;
		};
	}

	*setEnabled { |flag|
		enabled = flag.asBoolean;
		if(enabled.not) {
			this.teardownAllTracks(restoreRouting: true);
			this.pushSync(force: true);
		} {
			if(server.notNil and: { server.serverRunning }) {
				this.ensureSynthDefs;
				this.ensureGroups;
				this.reconcile;
			};
		};
	}

	*onServerBoot {
		if(this.isIDEProcess.not) { ^this };
		synthDefsLoaded = false;
		this.ensureSynthDefs;
		this.setupMeterForwarder;
	}

	*onServerTree {
		if(this.isIDEProcess.not) { ^this };
		if(enabled.not) { ^this };
		defer({
			if(server.notNil and: { server.serverRunning }) {
				this.ensureGroups;
				this.reconcile;
			};
		}, 0.05);
	}

	*onServerQuit {
		this.teardownAllTracks(restoreRouting: false);
		pbindSourceGroup = nil;
		pbindReturnGroup = nil;
		synthDefsLoaded = false;
		this.pushSync(force: true);
	}

	*onCmdPeriod {
		// Reconcile shortly after CmdPeriod so persistent ServerTree/Ndefs settle
		defer({
			this.teardownAllTracks(restoreRouting: false);
			if(server.notNil and: { server.serverRunning } and: { enabled }) {
				this.ensureGroups;
				this.reconcile;
			} {
				this.pushSync(force: true);
			};
		}, 0.12);
	}

	*setupMeterForwarder {
		if(meterOscFunc.notNil) { meterOscFunc.free };
		meterOscFunc = OSCFunc({ |msg|
			if(meterAddr.notNil and: { msg.size >= 7 }) {
				// msg: ['/perfMixerMeter', nodeID, replyID, peakL, rmsL, peakR, rmsR]
				meterAddr.sendMsg('/pm/m',
					msg[2].asInteger,
					msg[3].asFloat,
					msg[4].asFloat,
					msg[5].asFloat,
					msg[6].asFloat
				);
			} {
				if(meterAddr.notNil and: { msg.size >= 5 }) {
					meterAddr.sendMsg('/pm/m',
						msg[2].asInteger,
						msg[3].asFloat,
						msg[4].asFloat,
						msg[3].asFloat,
						msg[4].asFloat
					);
				};
			};
		}, '/perfMixerMeter', server.addr).permanent_(true);
	}

	*ensureGroups {
		if(server.isNil or: { server.serverRunning.not }) { ^this };
		if(pbindSourceGroup.isNil or: { pbindSourceGroup.isPlaying.not }) {
			pbindSourceGroup = Group.head(server.defaultGroup);
			NodeWatcher.register(pbindSourceGroup);
		};
		if(pbindReturnGroup.isNil or: { pbindReturnGroup.isPlaying.not }) {
			pbindReturnGroup = Group.after(pbindSourceGroup);
			NodeWatcher.register(pbindReturnGroup);
		};
	}

	*ensureSynthDefs {
		if(server.isNil or: { server.serverRunning.not }) { ^this };
		if(synthDefsLoaded) { ^this };
		synthDefsLoaded = true;

		// Core Stereo In-Place Strip
		SynthDef(\scPerfMixerCore2, {
			|bus=0, amp=1.0, pan=0.0, mute=0.0, soloDim=1.0, meterId=0|
			var sig = In.ar(bus, 2);
			var gain = Lag.kr(amp.clip(0.0, 4.0) * (1.0 - mute.clip(0.0, 1.0)) * soloDim.clip(0.0, 1.0), 0.015);
			sig = Balance2.ar(sig[0], sig[1], Lag.kr(pan.clip(-1.0, 1.0), 0.02), gain);
			SendPeakRMS.kr(sig, 15, 3, '/perfMixerMeter', meterId);
			ReplaceOut.ar(bus, sig);
		}).send(server);

		// Core Stereo Bus-Out Strip (for Pbindef / Design)
		SynthDef(\scPerfMixerCoreOut2, {
			|bus=0, outBus=0, amp=1.0, pan=0.0, mute=0.0, soloDim=1.0, meterId=0|
			var sig = In.ar(bus, 2);
			var gain = Lag.kr(amp.clip(0.0, 4.0) * (1.0 - mute.clip(0.0, 1.0)) * soloDim.clip(0.0, 1.0), 0.015);
			sig = Balance2.ar(sig[0], sig[1], Lag.kr(pan.clip(-1.0, 1.0), 0.02), gain);
			SendPeakRMS.kr(sig, 15, 3, '/perfMixerMeter', meterId);
			Out.ar(outBus, sig);
		}).send(server);

		// Core Mono In-Place Strip (safe for 1-ch Ndefs)
		SynthDef(\scPerfMixerCore1, {
			|bus=0, amp=1.0, pan=0.0, mute=0.0, soloDim=1.0, meterId=0|
			var sig = In.ar(bus, 1);
			var gain = Lag.kr(amp.clip(0.0, 4.0) * (1.0 - mute.clip(0.0, 1.0)) * soloDim.clip(0.0, 1.0), 0.015);
			sig = sig * gain;
			SendPeakRMS.kr([sig, sig], 15, 3, '/perfMixerMeter', meterId);
			ReplaceOut.ar(bus, sig);
		}).send(server);

		// FX 1: Distortion (Stereo)
		SynthDef(\scPerfFxDist2, {
			|bus=0, gate=1, mode=0, drive=3.0, tone=6000, mix=0.5, outGain=1.0|
			var dry = In.ar(bus, 2);
			var env = Linen.kr(gate, 0.015, 1.0, 0.015, doneAction: 2);
			var drv = Lag.kr(drive.clip(1.0, 25.0), 0.02);
			var tube = LeakDC.ar((dry * drv + 0.1).tanh);
			var hard = (dry * drv).clip2(0.95);
			var fold = (dry * drv).fold2(0.85);
			var crush = Latch.ar(dry, Impulse.ar((18000 - (drv * 600)).clip(800, 22050))).round(0.5 ** (12 - (drv * 0.35)).clip(2, 12));
			var dist = Select.ar(mode.clip(0, 3), [tube, hard, fold, crush]);
			var compGain = drv.max(1.0).sqrt.reciprocal * Lag.kr(outGain.clip(0.05, 4.0), 0.02);
			var wet = LPF.ar(dist, Lag.kr(tone.clip(300, 18000), 0.02)) * compGain;
			var outSig = XFade2.ar(dry, wet, (Lag.kr(mix.clip(0.0, 1.0), 0.02) * 2.0) - 1.0);
			XOut.ar(bus, env, outSig);
		}).send(server);

		// FX 1b: Filter (Stereo — LPF / HPF / BPF / Notch)
		SynthDef(\scPerfFxFilter2, {
			|bus=0, gate=1, mode=0, freq=2400, res=0.25, drive=1.0, mix=1.0|
			var dry = In.ar(bus, 2);
			var env = Linen.kr(gate, 0.015, 1.0, 0.015, doneAction: 2);
			var f = Lag.kr(freq.clip(20, 18000), 0.02);
			var rq = Lag.kr((1.0 - res.clip(0.0, 0.94)).clip(0.06, 1.0), 0.02);
			var drv = Lag.kr(drive.clip(1.0, 4.0), 0.02);
			var pre = (dry * drv).tanh * drv.sqrt.reciprocal;
			var lp = RLPF.ar(pre, f, rq);
			var hp = RHPF.ar(pre, f, rq);
			var bp = BPF.ar(pre, f, rq) * (1.0 / rq.sqrt).clip(1.0, 3.0);
			var br = BRF.ar(pre, f, rq);
			var wet = LeakDC.ar(Select.ar(mode.clip(0, 3), [lp, hp, bp, br]));
			var outSig = XFade2.ar(dry, wet, (Lag.kr(mix.clip(0.0, 1.0), 0.02) * 2.0) - 1.0);
			XOut.ar(bus, env, outSig);
		}).send(server);

		// FX 2: Compressor (Stereo)
		SynthDef(\scPerfFxComp2, {
			|bus=0, gate=1, thresh=(-18), ratio=4.0, attack=0.01, release=0.15, makeup=1.0, mix=1.0|
			var dry = In.ar(bus, 2);
			var env = Linen.kr(gate, 0.015, 1.0, 0.015, doneAction: 2);
			var wet = Compander.ar(
				dry, dry,
				thresh.clip(-50, 0).dbamp,
				1.0,
				ratio.clip(1.0, 20.0).reciprocal,
				attack.clip(0.001, 0.25),
				release.clip(0.01, 1.5)
			) * Lag.kr(makeup.clip(0.25, 16.0), 0.02);
			var outSig = XFade2.ar(dry, wet, (Lag.kr(mix.clip(0.0, 1.0), 0.02) * 2.0) - 1.0);
			XOut.ar(bus, env, outSig);
		}).send(server);

		// FX 3: Delay (Stereo, Non-RT Buffers for 0 KB memSize usage)
		SynthDef(\scPerfFxDelay2, {
			|bus=0, gate=1, bufL=0, bufR=0, time=0.35, feedback=0.4, damp=4500, spread=0.35, mix=0.3|
			var dry = In.ar(bus, 2);
			var env = Linen.kr(gate, 0.015, 1.0, 0.015, doneAction: 2);
			var fbIn = LocalIn.ar(2);
			var fbFilt = LPF.ar(LeakDC.ar(fbIn), Lag.kr(damp.clip(300, 18000), 0.03));
			var fbScaled = (fbFilt * Lag.kr(feedback.clip(0.0, 0.92), 0.02)).tanh;
			var spr = Lag.kr(spread.clip(0.0, 1.0), 0.03);
			var fbPing = [
				(fbScaled[0] * (1.0 - spr)) + (fbScaled[1] * spr),
				(fbScaled[1] * (1.0 - spr)) + (fbScaled[0] * spr)
			];
			var dTime = Lag.kr(time.clip(0.01, 1.95), 0.08);
			var delL = BufDelayC.ar(bufL, dry[0] + fbPing[0], dTime);
			var delR = BufDelayC.ar(bufR, dry[1] + fbPing[1], dTime);
			var del = [delL, delR];
			var outSig = XFade2.ar(dry, del, (Lag.kr(mix.clip(0.0, 1.0), 0.02) * 2.0) - 1.0);
			LocalOut.ar(del);
			XOut.ar(bus, env, outSig);
		}).send(server);

		// FX 4: Reverb (Stereo)
		SynthDef(\scPerfFxReverb2, {
			|bus=0, gate=1, room=0.65, damp=0.4, preDelay=0.015, lowCut=120, mix=0.3|
			var dry = In.ar(bus, 2);
			var env = Linen.kr(gate, 0.015, 1.0, 0.015, doneAction: 2);
			var pre = DelayN.ar(dry, 0.2, preDelay.clip(0.0, 0.18));
			var verb = FreeVerb2.ar(pre[0], pre[1], 1.0, room.clip(0.0, 1.0), damp.clip(0.0, 1.0));
			var wet = HPF.ar(verb, Lag.kr(lowCut.clip(20, 1000), 0.03));
			var outSig = XFade2.ar(dry, wet, (Lag.kr(mix.clip(0.0, 1.0), 0.02) * 2.0) - 1.0);
			XOut.ar(bus, env, outSig);
		}).send(server);
	}

	*startReconcileLoop {
		if(reconcileTask.notNil) { reconcileTask.stop };
		reconcileTask = Routine({
			loop {
				if(this.isIDEProcess and: { enabled } and: { server.notNil } and: { server.serverRunning }) {
					try { this.reconcile } { |err| };
				};
				0.25.wait;
			};
		}).play(AppClock);
	}

	*reconcile {
		var desired = IdentityDictionary.new;
		var boundPbindefs = IdentitySet.new;
		var ndefDict, designInfo;
		var changed = false;

		if(server.isNil or: { server.serverRunning.not } or: { enabled.not }) { ^this };
		this.ensureSynthDefs;
		this.ensureGroups;

		// 1. Scan active Ndefs (Append, Generate, Compose continuous & masterMix)
		ndefDict = Ndef.dictFor(server);
		if(ndefDict.notNil) {
			ndefDict.keysValuesDo { |key, proxy|
				if(proxy.isKindOf(NodeProxy)
					and: { proxy.isPlaying }
					and: { proxy.bus.notNil }
					and: { proxy.bus.rate == \audio }
					and: { proxy.objects.notEmpty }
					and: { proxy.group.notNil }
					and: { proxy.group.isPlaying }
				) {
					var id = ("ndef:" ++ key).asSymbol;
					var keyLower = key.asString.toLower;
					var kind = if(keyLower.contains("mastermix")) { "submix" } { "ndef" };

					// Collect any Pbindef bound to this Ndef via \set -> Pbindef(...)
					proxy.objects.do { |ctrl|
						var src = ctrl.tryPerform(\source);
						if(src.isKindOf(Pbindef)) {
							boundPbindefs.add(src.key);
						};
					};

					desired[id] = (
						id: id,
						label: key.asString,
						kind: kind,
						proxy: proxy,
						numChannels: proxy.numChannels.clip(1, 2),
						busIndex: proxy.bus.index
					);
				};
			};
		};

		// 2. Scan standalone playing Pbindefs (Compose discrete SynthDef patterns)
		if(Pdef.all.notNil) {
			Pdef.all.keysValuesDo { |key, pdef|
				if(pdef.isKindOf(Pbindef)
					and: { pdef.isPlaying }
					and: { boundPbindefs.includes(key).not }
				) {
					var src = pdef.source;
					var hasInstr = false;
					if(src.isKindOf(PbindProxy)) {
						hasInstr = src.at(\instrument).notNil;
					};
					if(hasInstr) {
						var id = ("pbindef:" ++ key).asSymbol;
						desired[id] = (
							id: id,
							label: key.asString,
							kind: "pbindef",
							pdef: pdef,
							pkey: key,
							numChannels: 2
						);
					};
				};
			};
		};

		// 3. Scan active Design synthesizer in currentEnvironment
		designInfo = this.detectActiveDesign;
		if(designInfo.notNil) {
			desired[designInfo[\id]] = designInfo;
		};

		// 4. Remove stale tracks
		tracks.keys.copy.do { |id|
			var tr = tracks[id];
			var stale = desired[id].isNil;
			if(stale.not) {
				// Also rebuild if busIndex or channel count changed on an Ndef
				var d = desired[id];
				if(tr[\kind] == "ndef" or: { tr[\kind] == "submix" }) {
					if(tr[\busIndex] != d[\busIndex] or: { tr[\numChannels] != d[\numChannels] }) {
						stale = true;
					};
				};
				if(tr[\stripGroup].isNil or: { tr[\stripGroup].isPlaying.not }) {
					stale = true;
				};
			};
			if(stale) {
				this.removeTrack(id, restoreRouting: true);
				changed = true;
			};
		};

		// 5. Attach new tracks
		desired.keysValuesDo { |id, spec|
			if(tracks[id].isNil) {
				if(this.attachTrack(spec)) {
					changed = true;
				};
			};
		};

		if(changed) {
			this.pushSync(force: false);
		} {
			this.pushSync(force: false);
		};
	}

	*detectActiveDesign {
		var env = currentEnvironment;
		var termSynth, termGroup, busCandidate;
		var synthDesc, hasOut = false;

		if(env.isNil) { ^nil };

		// Check terminal FX synth in Design scripts (~masterFx, ~fxSynth)
		[\masterFx, \fxSynth].do { |sym|
			var candidate = env[sym];
			if(termSynth.isNil
				and: { candidate.isKindOf(Synth) }
				and: { candidate.server === server }
				and: { freedDesignIds.includes(candidate.nodeID).not }
			) {
				if(candidate.isPlaying.not) {
					NodeWatcher.register(candidate, true);
					candidate.onFree({ freedDesignIds.add(candidate.nodeID) });
				};
				termSynth = candidate;
			};
		};

		if(termSynth.notNil) {
			synthDesc = SynthDescLib.global[termSynth.defName.asSymbol];
			if(synthDesc.notNil) {
				hasOut = synthDesc.controls.any { |c| c.name == \out };
			};
			if(hasOut) {
				^(
					id: ("design:" ++ termSynth.defName).asSymbol,
					label: termSynth.defName.asString,
					kind: "design",
					mode: "outSynth",
					synth: termSynth,
					numChannels: 2
				)
			};
		};

		// Fallback: Design script with ~synthGroup + an explicit audio bus
		termGroup = env[\synthGroup];
		if(termGroup.isKindOf(Group)
			and: { termGroup.server === server }
			and: { freedDesignIds.includes(termGroup.nodeID).not }
		) {
			if(termGroup.isPlaying.not) {
				NodeWatcher.register(termGroup, true);
				termGroup.onFree({ freedDesignIds.add(termGroup.nodeID) });
			};
			[\masterBus, \fxBus, \cavernaBus, \celestialBus, \ancientBus].do { |bsym|
				var b = env[bsym];
				if(busCandidate.isNil and: { b.isKindOf(Bus) } and: { b.rate == \audio } and: { b.index.notNil }) {
					busCandidate = b;
				};
			};
			if(busCandidate.notNil) {
				^(
					id: \design_instrument,
					label: "Design Synth",
					kind: "design",
					mode: "inPlaceBus",
					group: termGroup,
					bus: busCandidate,
					numChannels: busCandidate.numChannels.clip(1, 2)
				)
			};
		};

		^nil
	}

	*attachTrack { |spec|
		var id = spec[\id];
		var kind = spec[\kind];
		var stripGroup, coreSynth, meterId;
		var trackBus, origOut = 0, origGroup;
		var coreDefName, targetGroup;

		meterId = nextMeterId;
		nextMeterId = nextMeterId + 1;

		if(kind == "ndef" or: { kind == "submix" }) {
			var proxy = spec[\proxy];
			if(proxy.group.isNil or: { proxy.group.isPlaying.not } or: { proxy.bus.isNil }) { ^false };
			stripGroup = Group.after(proxy.group);
			NodeWatcher.register(stripGroup);
			coreDefName = if(spec[\numChannels] == 1) { \scPerfMixerCore1 } { \scPerfMixerCore2 };
			coreSynth = Synth.tail(stripGroup, coreDefName, [
				\bus, spec[\busIndex],
				\amp, 1.0,
				\pan, 0.0,
				\mute, 0.0,
				\soloDim, 1.0,
				\meterId, meterId
			]);
			NodeWatcher.register(coreSynth);

			tracks[id] = (
				id: id,
				label: spec[\label],
				kind: kind,
				proxy: proxy,
				busIndex: spec[\busIndex],
				numChannels: spec[\numChannels],
				stripGroup: stripGroup,
				coreSynth: coreSynth,
				meterId: meterId,
				fxSynths: IdentityDictionary.new,
				fxBuffers: IdentityDictionary.new
			);
			this.attachProxyController(id, proxy);
			^true;
		};

		if(kind == "pbindef") {
			var pdef = spec[\pdef];
			var pkey = spec[\pkey];
			var src = pdef.source;
			var curOut, curGroup;

			this.ensureGroups;
			trackBus = Bus.audio(server, 2);
			if(trackBus.isNil) { ^false };

			curOut = src.at(\out);
			curGroup = src.at(\group);
			if(pbindOrigState[pkey].isNil) {
				origOut = curOut ?? { 0 };
				origGroup = curGroup;
				pbindOrigState[pkey] = (out: origOut, group: origGroup, trackBus: trackBus);
			} {
				origOut = pbindOrigState[pkey][\out] ?? { 0 };
				pbindOrigState[pkey][\trackBus] = trackBus;
			};

			// Redirect pattern events onto private trackBus inside pbindSourceGroup
			pdef.set(\out, trackBus.index, \group, pbindSourceGroup.nodeID);

			stripGroup = Group.tail(pbindReturnGroup);
			NodeWatcher.register(stripGroup);
			coreSynth = Synth.tail(stripGroup, \scPerfMixerCoreOut2, [
				\bus, trackBus.index,
				\outBus, origOut.asControlInput,
				\amp, 1.0,
				\pan, 0.0,
				\mute, 0.0,
				\soloDim, 1.0,
				\meterId, meterId
			]);
			NodeWatcher.register(coreSynth);

			tracks[id] = (
				id: id,
				label: spec[\label],
				kind: kind,
				pdef: pdef,
				pkey: pkey,
				trackBus: trackBus,
				origOut: origOut,
				busIndex: trackBus.index,
				numChannels: 2,
				stripGroup: stripGroup,
				coreSynth: coreSynth,
				meterId: meterId,
				fxSynths: IdentityDictionary.new,
				fxBuffers: IdentityDictionary.new
			);
			^true;
		};

		if(kind == "design") {
			if(spec[\mode] == "outSynth") {
				var synth = spec[\synth];
				var env = currentEnvironment;
				var outTarget = env[\masterGroup] ?? { env[\fxGroup] } ?? { synth.group };
				trackBus = Bus.audio(server, 2);
				if(trackBus.isNil) { ^false };
				synth.set(\out, trackBus.index);
				stripGroup = Group.after(outTarget);
				NodeWatcher.register(stripGroup);
				coreSynth = Synth.tail(stripGroup, \scPerfMixerCoreOut2, [
					\bus, trackBus.index,
					\outBus, 0,
					\amp, 1.0,
					\pan, 0.0,
					\mute, 0.0,
					\soloDim, 1.0,
					\meterId, meterId
				]);
				NodeWatcher.register(coreSynth);

				tracks[id] = (
					id: id,
					label: spec[\label],
					kind: kind,
					designMode: "outSynth",
					designSynth: synth,
					trackBus: trackBus,
					busIndex: trackBus.index,
					numChannels: 2,
					stripGroup: stripGroup,
					coreSynth: coreSynth,
					meterId: meterId,
					fxSynths: IdentityDictionary.new,
					fxBuffers: IdentityDictionary.new
				);
				^true;
			} {
				var grp = spec[\group];
				var bus = spec[\bus];
				stripGroup = Group.after(grp);
				NodeWatcher.register(stripGroup);
				coreDefName = if(spec[\numChannels] == 1) { \scPerfMixerCore1 } { \scPerfMixerCore2 };
				coreSynth = Synth.tail(stripGroup, coreDefName, [
					\bus, bus.index,
					\amp, 1.0,
					\pan, 0.0,
					\mute, 0.0,
					\soloDim, 1.0,
					\meterId, meterId
				]);
				NodeWatcher.register(coreSynth);

				tracks[id] = (
					id: id,
					label: spec[\label],
					kind: kind,
					designMode: "inPlaceBus",
					busIndex: bus.index,
					numChannels: spec[\numChannels],
					stripGroup: stripGroup,
					coreSynth: coreSynth,
					meterId: meterId,
					fxSynths: IdentityDictionary.new,
					fxBuffers: IdentityDictionary.new
				);
				^true;
			};
		};

		^false
	}

	*attachProxyController { |id, proxy|
		var ctrl;
		if(controllers[id].notNil) { controllers[id].remove };
		ctrl = SimpleController(proxy)
			.put(\clear, { defer { this.removeTrack(id, restoreRouting: false); this.pushSync(force: false); } })
			.put(\stop, { defer { this.removeTrack(id, restoreRouting: false); this.pushSync(force: false); } })
			.put(\end, { defer { this.removeTrack(id, restoreRouting: false); this.pushSync(force: false); } });
		controllers[id] = ctrl;
	}

	*removeTrack { |id, restoreRouting = true|
		var tr = tracks.removeAt(id);
		if(tr.isNil) { ^this };

		if(controllers[id].notNil) {
			controllers[id].remove;
			controllers.removeAt(id);
		};

		if(restoreRouting and: { tr[\kind] == "pbindef" }) {
			var pkey = tr[\pkey];
			var orig = pbindOrigState.removeAt(pkey);
			var pdef = Pdef.all !? { Pdef.all[pkey] };
			if(pdef.notNil and: { orig.notNil }) {
				try {
					pdef.set(\out, orig[\out], \group, orig[\group]);
				} {};
			};
		};

		if(restoreRouting and: { tr[\kind] == "design" } and: { tr[\designMode] == "outSynth" }) {
			var syn = tr[\designSynth];
			if(syn.notNil and: { syn.isPlaying }) {
				try { syn.set(\out, 0) } {};
			};
		};

		if(tr[\stripGroup].notNil and: { tr[\stripGroup].isPlaying }) {
			try { tr[\stripGroup].free } {};
		};

		if(tr[\fxBuffers].notNil) {
			var bufs = tr[\fxBuffers].values.copy;
			defer({
				bufs.do { |b| if(b.notNil) { try { b.free } {} } };
			}, 0.2);
		};

		if(tr[\trackBus].notNil) {
			var tb = tr[\trackBus];
			defer({
				if(tb.notNil) { try { tb.free } {} };
			}, 0.4);
		};
	}

	*teardownAllTracks { |restoreRouting = true|
		tracks.keys.copy.do { |id|
			this.removeTrack(id, restoreRouting: restoreRouting);
		};
	}

	*setFxEnabled { |idStr, fxSlotStr, enableFlag|
		var id = idStr.asSymbol;
		var slot = fxSlotStr.asSymbol; // \dist, \comp, \delay, \reverb
		var tr = tracks[id];
		var enable = enableFlag.asBoolean;
		var fxOrder = #[\dist, \filter, \comp, \delay, \reverb];
		var defMap = (
			dist: \scPerfFxDist2,
			filter: \scPerfFxFilter2,
			comp: \scPerfFxComp2,
			delay: \scPerfFxDelay2,
			reverb: \scPerfFxReverb2
		);
		var existing;

		if(tr.isNil or: { tr[\stripGroup].isNil } or: { tr[\stripGroup].isPlaying.not }) { ^this };
		if(tr[\numChannels] == 1) { ^this }; // stereo FX only on stereo tracks

		existing = tr[\fxSynths][slot];

		if(enable.not) {
			if(existing.notNil) {
				try { existing.set(\gate, 0) } {};
				tr[\fxSynths].removeAt(slot);
				if(slot == \delay) {
					var bL = tr[\fxBuffers].removeAt(\delayL);
					var bR = tr[\fxBuffers].removeAt(\delayR);
					defer({
						if(bL.notNil) { try { bL.free } {} };
						if(bR.notNil) { try { bR.free } {} };
					}, 0.15);
				};
				this.pushSync(force: true);
			};
			^this;
		};

		if(existing.notNil and: { existing.isPlaying }) {
			^this;
		};

		// Determine insertion target to preserve strict DAW chain order:
		// dist -> comp -> delay -> reverb -> coreSynth
		{
			var targetNode = tr[\coreSynth];
			var addAct = \addBefore;
			var idx = fxOrder.indexOf(slot);
			var args = [\bus, tr[\busIndex], \gate, 1];
			var newSynth;

			if(idx.notNil) {
				(idx + 1 .. fxOrder.size - 1).do { |laterIdx|
					var laterSyn = tr[\fxSynths][fxOrder[laterIdx]];
					if(targetNode === tr[\coreSynth] and: { laterSyn.notNil } and: { laterSyn.isPlaying }) {
						targetNode = laterSyn;
					};
				};
			};

			if(slot == \delay) {
				var sr = server.sampleRate ? 48000;
				var bufFrames = (sr * 2.0).asInteger;
				var bL = Buffer.alloc(server, bufFrames, 1);
				var bR = Buffer.alloc(server, bufFrames, 1);
				tr[\fxBuffers][\delayL] = bL;
				tr[\fxBuffers][\delayR] = bR;
				args = args ++ [\bufL, bL.bufnum, \bufR, bR.bufnum];
			};

			newSynth = Synth(defMap[slot], args, targetNode, addAct);
			NodeWatcher.register(newSynth);
			tr[\fxSynths][slot] = newSynth;
			this.pushSync(force: true);
		}.value;
	}

	*stopTrack { |idStr|
		var id = idStr.asSymbol;
		var tr = tracks[id];
		var sName = idStr.asString;

		if(tr.notNil) {
			var kind = tr[\kind];
			if(kind == "ndef" or: { kind == "submix" }) {
				var proxy = tr[\proxy];
				if(proxy.notNil) {
					proxy.objects.do { |ctrl|
						var src = ctrl.tryPerform(\source);
						if(src.isKindOf(Pbindef)) {
							try { src.stop } {};
						};
					};
					try {
						proxy.fadeTime = 1.5;
						proxy.clear(1.5);
					} {};
				};
			} {
				if(kind == "pbindef") {
					if(tr[\pdef].notNil) {
						try { tr[\pdef].stop } {};
					};
				} {
					if(kind == "design") {
						var env = currentEnvironment;
						try { MIDIdef.freeAll } {};
						if(env[\releaseAll].notNil) { try { env[\releaseAll].value } {} };
						if(env[\notes].notNil) {
							try {
								env[\notes].do { |item|
									if(item.notNil) {
										if(item.isKindOf(Collection)) {
											item.do { |sn| if(sn.notNil) { try { sn.free } {} } };
										} {
											try { item.free } {};
										};
									};
								};
							} {};
						};
						[\subSynth, \monoSynth, \leadSynth, \droneSynth, \synth,
						 \fxSynth, \masterFx, \celestialFx, \ancientFx, \reverbSynth, \delaySynth,
						 \synthGroup, \fxGroup, \masterGroup, \sourceGroup].do { |sym|
							if(env[sym].notNil) { try { env[sym].free } {}; env[sym] = nil };
						};
						[\mainWin, \surWin, \win, \guiWin, \synthWin].do { |wSym|
							if(env[wSym].notNil) { try { env[wSym].close } {}; env[wSym] = nil };
						};
					};
				};
			};
			this.removeTrack(id, restoreRouting: (kind == "pbindef"));
			this.pushSync(force: true);
			^this;
		};

		// Fallback by prefix if track already vanished
		if(sName.beginsWith("ndef:")) {
			var key = sName.copyToEnd(5).asSymbol;
			try { Ndef(key).fadeTime = 1.5; Ndef(key).clear(1.5); } {};
		};
		if(sName.beginsWith("pbindef:")) {
			var key = sName.copyToEnd(8).asSymbol;
			try { Pbindef(key).stop; } {};
		};
	}

	*pushSync { |force = false|
		var list, sig;
		if(this.isIDEProcess.not) { ^this };

		list = tracks.values.asArray.sort { |a, b| a[\meterId] < b[\meterId] }.collect { |tr|
			var fx = tr[\fxSynths];
			[
				tr[\id].asString,
				tr[\label].asString,
				tr[\kind].asString,
				tr[\meterId].asInteger,
				tr[\numChannels].asInteger,
				tr[\busIndex].asInteger,
				tr[\coreSynth].tryPerform(\nodeID) ? -1,
				fx[\dist].tryPerform(\nodeID) ? -1,
				fx[\comp].tryPerform(\nodeID) ? -1,
				fx[\delay].tryPerform(\nodeID) ? -1,
				fx[\reverb].tryPerform(\nodeID) ? -1,
				fx[\filter].tryPerform(\nodeID) ? -1
			]
		};

		sig = list.asString;
		if(force or: { sig != lastSyncSignature }) {
			lastSyncSignature = sig;
			if(ScIDE.connected) {
				ScIDE.send(\perfMixerSync, list);
			};
		};
	}

	*debugTracks { ^tracks }

	// ScIDE.request entry points
	*requestInit { |id, data|
		this.initForIDE(Server.default);
		if(data.notNil and: { data.size > 0 }) {
			this.setMeterPort(data.asInteger);
		};
		this.pushSync(force: true);
	}

	*requestSyncNow { |id, data|
		this.reconcile;
		this.pushSync(force: true);
	}

	*requestSetMeterPort { |id, data|
		this.setMeterPort(data.asInteger);
	}

	*requestSetEnabled { |id, data|
		this.setEnabled(data == "1" or: { data == "true" });
	}

	*requestSetFxEnabled { |id, data|
		var parts = data.asString.split($|);
		if(parts.size >= 3) {
			this.setFxEnabled(parts[0], parts[1], parts[2] == "1");
		};
	}

	*requestStopTrack { |id, data|
		this.stopTrack(data.asString);
	}
}
