// --- GLOBAL TEMPO & QUANTIZATION SETUP ---
(
t = TempoClock.default;
t.tempo = 60 / 60; // Master Tempo: currently 60 BPM
Pdef.defaultQuant = 1;
)

// --- SCORPION INSTRUMENTS ---
(
Ndef(\scorpionScrape).clear;
Ndef(\scorpionScrape, {
	|rate=40, freq=7000, rq=0.15, amp=1.5, t_trig=1|
	var noise, scrapeMod, shrill, env;

	noise = WhiteNoise.ar(0.8) + Crackle.ar(1.9, 0.8);
	scrapeMod = LFSaw.ar(rate).range(0.3, 1.0);
	shrill = BPF.ar(noise * scrapeMod, freq, rq, 8);
	env = EnvGen.kr(Env.perc(0.005, 0.15), t_trig);

	Pan2.ar(shrill * env * amp, 0);
}).play;

Ndef(\scorpionSnap).clear;
Ndef(\scorpionSnap, {
	|baseFreq=1500, amp=1, t_trig=1|
	var exciter, shell, thud, masterEnv;

	masterEnv = EnvGen.ar(Env.perc(0.001, 0.08), t_trig);
	exciter = PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.005), t_trig);
	shell = DynKlank.ar(
		`[[1, 1.34, 1.78, 2.45, 3.1] * baseFreq, [1, 0.7, 0.5, 0.2, 0.1], [0.03, 0.02, 0.015, 0.008, 0.005]],
		exciter
	);

	thud = LPF.ar(BrownNoise.ar, 400) * EnvGen.ar(Env.perc(0.002, 0.04), t_trig);

	Pan2.ar((shell + (thud * 0.4)) * masterEnv * amp, Rand(-0.7, 0.7));
}).play;
)

// --- SCORPION EFFECTS ---
(
// reverb (Index 10)
Ndef(\scorpionScrape)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.8, 0.2) };
Ndef(\scorpionSnap)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.4) };
Ndef(\scorpionScrape).set(\wet10, 0); Ndef(\scorpionSnap).set(\wet10, 0);

// delay (Index 11)
Ndef(\scorpionScrape)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.05, 0.6) };
Ndef(\scorpionSnap)[11] = \filter -> { |in| CombL.ar(in, 0.5, 0.12, 1.5) };
Ndef(\scorpionScrape).set(\wet11, 0); Ndef(\scorpionSnap).set(\wet11, 0);

// distortion (Index 12)
Ndef(\scorpionScrape)[12] = \filter -> { |in| (in * 5).tanh / 2 };
Ndef(\scorpionSnap)[12] = \filter -> { |in| (in * 8).fold2(0.5) };
Ndef(\scorpionScrape).set(\wet12, 0); Ndef(\scorpionSnap).set(\wet12, 0);
)

// --- SCORPION SEQUENCES ---
(
Pbindef(\snapSeq, \dur, 0.2, \baseFreq, Pwhite(1000, 3000), \t_trig, 1);
Pbindef(\scrapeSeq, \dur, Pwhite(0.05, 0.2), \rate, Pwhite(30, 80), \t_trig, 1);

// Setting quant here ensures the sequence aligns with the global clock when it first starts
Ndef(\scorpionSnap).quant = 1;
Ndef(\scorpionScrape).quant = 1;

Ndef(\scorpionSnap)[1] = \set -> Pbindef(\snapSeq);
Ndef(\scorpionScrape)[1] = \set -> Pbindef(\scrapeSeq);
)

// --- SCORPION LIVE CODING TWEAKS ---

//instrument tweaks
Ndef(\scorpionScrape).set(\freq, 2000, \rq, 0.05); // Deeper, more resonant hollow scrape
Ndef(\scorpionScrape).set(\freq, 9000, \rq, 0.2); // Back to high, sandy scrape

//sequence tweaks
Pbindef(\scrapeSeq, \dur, 1.5, \rate, 40); // Sparse scrapes
Pbindef(\snapSeq, \baseFreq, 100); // Giant mutant scorpion (huge thud)
Pbindef(\snapSeq, \baseFreq, 4500); // Tiny glass scorpion (high transient)

Pbindef(\snapSeq, \dur, Pseq([0.1, 0.1, 0.2, 0.1, 0.3], inf)); // Nervous, uneven snapping rhythm
Pbindef(\snapSeq, \dur, Pn(Pgeom(0.6, 0.85, 20), inf)); // Accelerating attack run
Pbindef(\scrapeSeq, \dur, 0.02, \rate, Pwhite(100, 200)); // Angry, continuous granular swarm
Pbindef(\scrapeSeq, \dur, Pwrand([0.5, 1.0, 0.1], [0.7, 0.2, 0.1], inf)); // Sparse, lurking movements

//effect tweaks
Ndef(\scorpionScrape).set(\wet11, 0.7); // Add tight, metallic delay to scrape
Ndef(\scorpionSnap).set(\wet10, 0.8, \wet12, 1.0); // Massive distorted reverb tail for the snap
Ndef(\scorpionSnap).set(\wet10, 0, \wet12, 0); // Dry snap

//scorpion fade out and ending
(
Pbindef(\snapSeq).stop;
Pbindef(\scrapeSeq).stop;
Ndef(\scorpionSnap).fadeTime = 4; Ndef(\scorpionSnap).clear(4);
Ndef(\scorpionScrape).fadeTime = 4; Ndef(\scorpionScrape).clear(4);
)

////////////////////
// --- JAGUAR INSTRUMENT ---
(
Ndef(\jaguar).clear;
Ndef(\jaguar, {
	|freq=100, dur=1.8, amp=0.8, t_trig=1|
	var ampEnv, pitchEnv, filterEnv, jitter, vocalFolds, breath, roar, formants, bodyRes, snd;

	ampEnv = EnvGen.ar(Env([0, 1, 0.7, 0], [0.05, 0.3, 0.65] * dur, [-4, -2, -4]), t_trig);
	pitchEnv = EnvGen.ar(Env([150, 50, 25], [0.2, 0.8] * dur, \exp), t_trig) * (freq/100);
	filterEnv = EnvGen.ar(Env([1500, 700, 200], [0.3, 0.7] * dur, \exp), t_trig);

	jitter = LFNoise1.kr(20).range(0.9, 1.1);
	vocalFolds = SyncSaw.ar(pitchEnv * jitter, pitchEnv * jitter * 2.5);
	breath = BrownNoise.ar() * EnvGen.ar(Env.perc(0.05, dur * 0.8), t_trig) * 0.5;

	roar = (vocalFolds + breath) * 3;
	roar = roar.fold2(0.8).cubed;

	formants = BPF.ar(roar, [filterEnv, filterEnv * 2.2, filterEnv * 3.5], [0.3, 0.4, 0.5]).sum;
	bodyRes = RLPF.ar(roar, pitchEnv * 4, 0.6) * 0.5;

	snd = (formants + bodyRes) * ampEnv;
	snd = FreeVerb2.ar(snd, snd, 0.15, 0.6, 0.2);
	snd * amp;
}).play;
)

// --- JAGUAR SEQUENCES ---
(
Pbindef(\jagSeq, \dur, 3, \dur_attr, 2.2, \t_trig, 1);
Ndef(\jaguar).quant = 1;
Ndef(\jaguar)[1] = \set -> Pbindef(\jagSeq);
)

// --- JAGUAR EFFECTS ---
(
Ndef(\jaguar)[10] = \filter -> { |in| GVerb.ar(in.sum, 150, 6) };
Ndef(\jaguar).set(\wet10, 0);
Ndef(\jaguar)[11] = \filter -> { |in| AllpassC.ar(in, 1, 0.4, 4) };
Ndef(\jaguar).set(\wet11, 0);
Ndef(\jaguar)[12] = \filter -> { |in| (in * 6).wrap2(0.8) };
Ndef(\jaguar).set(\wet12, 0);
)

// --- JAGUAR LIVE CODING TWEAKS ---
//instrument tweaks
Ndef(\jaguar).set(\freq, 40); // Deep, guttural resting purr
Ndef(\jaguar).set(\freq, 220); // High-pitched, strained cub call
Ndef(\jaguar).set(\freq, 80, \amp, 1.2); // Full power warning roar
Ndef(\jaguar).set(\amp, 0.3); // Pushed into the background/distance

//sequence tweaks
Pbindef(\jagSeq, \dur, 0.5, \dur_attr, 0.2, \amp, 0.4); // fast territorial barks
Pbindef(\jagSeq, \dur, Pwhite(4.0, 8.0), \dur_attr, 2.5); // Slow, lurking steps with long random pauses
Pbindef(\jagSeq, \dur, Pseq([0.2, 0.2, 0.1, 2.5], inf), \dur_attr, Pkey(\dur) * 0.8); // Sudden, aggressive pounce

//effect tweaks
Ndef(\jaguar).set(\wet10, 0.6); // Drown the roar in a massive canyon reverb
Ndef(\jaguar).set(\wet11, 0.7, \wet12, 0.5); // Gritty, repeating ghost echoes
Ndef(\jaguar).set(\wet10, 0, \wet11, 0, \wet12, 0); // Dry

//jaguar fade out and ending
(
Pbindef(\jagSeq).stop;
Ndef(\jaguar).fadeTime = 5;
Ndef(\jaguar).clear(5);
)

////////////////////
// --- GUARIBA INSTRUMENT ---
(
Ndef(\guariba).clear;
Ndef(\guariba, {
	|freq=90, amp=0.1, t_trig=1, growl=12, rq=0.15|
	var ampEnv, filterEnv, mod, car, noise, out;
	ampEnv = EnvGen.kr(Env([0, 1, 0.7, 0], [0.4, 0.5, 1.5], \sine), t_trig);
	filterEnv = EnvGen.kr(Env([150, 900, 150], [0.5, 1.2], \exp), t_trig);
	mod = SinOsc.ar(freq * 0.25) * (freq * growl);
	car = SinOsc.ar(freq + mod);
	noise = BrownNoise.ar() * 0.15;
	out = RLPF.ar(car + noise, filterEnv, rq);
	Pan2.ar(out, LinLin.kr(freq, 70, 150, -0.3, 0.3)) * ampEnv * amp;
}).play;
)

// --- GUARIBA SEQUENCES ---
(
Pbindef(\guaribaSeq, \dur, 4, \freq, 80, \growl, 15, \t_trig, 1);
Ndef(\guariba).quant = 1;
Ndef(\guariba)[1] = \set -> Pbindef(\guaribaSeq);
)

// --- GUARIBA EFFECTS ---
(
Ndef(\guariba)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.9, 0.1) };
Ndef(\guariba).set(\wet10, 0);
Ndef(\guariba)[11] = \filter -> { |in| CombL.ar(in, 1, 0.35, 3.5) };
Ndef(\guariba).set(\wet11, 0);
Ndef(\guariba)[12] = \filter -> { |in| (in * 4).softclip };
Ndef(\guariba).set(\wet12, 0);
)

// --- GUARIBA LIVE CODING TWEAKS ---
//instrument tweaks
Ndef(\guariba).set(\growl, 30); // Intense throat saturation/distortion
Ndef(\guariba).set(\growl, 2, \rq, 0.8); // Clearer, hollow hooting sound
Ndef(\guariba).set(\freq, 50, \growl, 18); // Massive chest resonance
Ndef(\guariba).set(\freq, 160, \rq, 0.05, \growl, 25); // Aggressive, tight screaming

//sequence tweaks
Pbindef(\guaribaSeq, \dur, Pseq([0.5, 0.25, 0.25, 1], inf), \freq, Pseq([80, 100, 90, 80], inf)); // Syncopated troop communication
Pbindef(\guaribaSeq, \dur, 0.2, \freq, 110, \growl, 8); // Fast, rhythmic panting/chatter
Pbindef(\guaribaSeq, \dur, 5, \freq, Pseg([60, 130, 60], [10, 10], \exp, inf)); // Slowly evolving canopy call
Pbindef(\guaribaSeq, \dur, Pwhite(0.3, 1.5), \freq, Pwhite(70, 130), \growl, Pwhite(10, 25)); // Randomized chaotic troop response

//effect tweaks
Ndef(\guariba).set(\wet10, 0.7); // Distant canopy wash
Ndef(\guariba).set(\wet11, 0.9, \wet12, 1.0); // Extreme screaming troop reflection
Ndef(\guariba).set(\wet10, 0, \wet11, 0, \wet12, 0); // Dry

//guariba fade out and ending
(
Pbindef(\guaribaSeq).stop;
Ndef(\guariba).fadeTime = 6;
Ndef(\guariba).clear(6);
)

////////////////////
// --- ARARA INSTRUMENT ---
(
Ndef(\arara).clear;
Ndef(\arara, {
	|freq=800, modFreq=200, modIndex=5, amp=0.8, t_trig=1|
	var env, mod, car, filterEnv, snd;

	env = EnvGen.ar(Env.perc(0.01, 0.35, 1, -4), t_trig);
	filterEnv = EnvGen.ar(Env([1000, 3500, 800], [0.05, 0.25], \exp), t_trig);
	mod = SinOsc.ar(modFreq) * modIndex * modFreq;
	car = Saw.ar(freq + mod);
	snd = BPF.ar(car, filterEnv, 0.4);
	snd = snd.tanh;
	Pan2.ar(snd * env * amp, LFNoise1.kr(1).range(-0.6, 0.6));
}).play;
)

// --- ARARA SEQUENCES ---
(
Pbindef(\araraSeq,
	\dur, Pseq([0.15, 0.2, 0.4, 0.1], inf),
	\freq, Pwhite(700, 1100),
	\modFreq, Pwhite(150, 300),
	\t_trig, 1
);
Ndef(\arara).quant = 1;
Ndef(\arara)[1] = \set -> Pbindef(\araraSeq);
)

// --- ARARA EFFECTS ---
(
Ndef(\arara)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.6, 0.5) };
Ndef(\arara).set(\wet10, 0);
Ndef(\arara)[11] = \filter -> { |in| AllpassC.ar(in, 1, 0.15, 2) };
Ndef(\arara).set(\wet11, 0);
Ndef(\arara)[12] = \filter -> { |in| (in * 5).clip2(0.5) };
Ndef(\arara).set(\wet12, 0);
)

// --- ARARA LIVE CODING TWEAKS ---
//instrument tweaks
Ndef(\arara).set(\modFreq, 50, \modIndex, 10, \freq, 300); // Guttural, low croak
Ndef(\arara).set(\freq, 1600, \modFreq, 400, \modIndex, 2); // Piercing, high-altitude alarm call
Ndef(\arara).set(\freq, 900, \modFreq, 950, \modIndex, 8); // Ringing, metallic chatter
Ndef(\arara).set(\amp, 0.2, \freq, 500, \modIndex, 3); // Soft, distant murmurs

//sequence tweaks
Pbindef(\araraSeq, \dur, Pwhite(0.05, 0.1), \freq, Pwhite(800, 1200)); // Flurry of frantic wings and squawks
Pbindef(\araraSeq, \dur, Pseq([0.2, 0.2, 2.0], inf), \freq, Pseq([800, 1200, 900], inf)); // Call and response phrasing
Pbindef(\araraSeq, \dur, 0.4, \freq, Pseg([600, 1400, 600], [4, 4], \linear, inf)); // Sweeping tonal conversation
Pbindef(\araraSeq, \dur, Pwrand([0.2, 1.5, 3.0], [0.5, 0.3, 0.2], inf)); // Irregular, isolated morning calls

//effect tweaks
Ndef(\arara).set(\wet11, 0.8); // Fluttering fast delay
Ndef(\arara).set(\wet10, 0.9, \wet12, 0.6); // Harsh saturated distance
Ndef(\arara).set(\wet10, 0, \wet11, 0, \wet12, 0); // Dry

//arara fade out and ending
(
Pbindef(\araraSeq).stop;
Ndef(\arara).fadeTime = 3;
Ndef(\arara).clear(3);
)

////////////////////
// --- TOAD INSTRUMENT ---
(
Ndef(\toad).clear;
Ndef(\toad, {
	|freq=150, modFreq=50, res=0.1, amp=0.8, t_trig=1|
	var env, mod, sig;
	env = EnvGen.ar(Env.perc(0.01, 0.2), t_trig);
	mod = SinOsc.ar(modFreq) * freq;
	sig = Saw.ar(freq + mod);
	sig = RLPF.ar(sig, freq * 2, res);
	Pan2.ar(sig * env * amp, 0);
}).play;
)

// --- TOAD EFFECTS ---
(
// reverb (Index 10)
Ndef(\toad)[10] = \filter -> { |in| FreeVerb.ar(in, 1, 0.7, 0.2) };
Ndef(\toad).set(\wet10, 0);

// delay (Index 11)
Ndef(\toad)[11] = \filter -> { |in| CombL.ar(in, 0.2, 0.1, 1.5) };
Ndef(\toad).set(\wet11, 0);

// distortion (Index 12)
Ndef(\toad)[12] = \filter -> { |in| (in * 5).fold2(0.8) };
Ndef(\toad).set(\wet12, 0);
)

// --- TOAD SEQUENCES ---
(
Pbindef(\toadSeq, \dur, 0.5, \freq, Pwhite(100, 200), \t_trig, 1);
Ndef(\toad).quant = 1;
Ndef(\toad)[1] = \set -> Pbindef(\toadSeq);
)

// --- TOAD LIVE CODING TWEAKS ---

//instrument tweaks
Ndef(\toad).set(\res, 0.5); // Thin, watery resonance
Ndef(\toad).set(\res, 0.05, \modFreq, 200); // Aggressive FM croak

//sequence tweaks
Pbindef(\toadSeq, \dur, 0.125, \freq, 300); // Fast, high-pitched defensive chatter
Pbindef(\toadSeq, \dur, Pwrand([0.25, 0.5, 1], [0.6, 0.3, 0.1], inf)); // Uneven, hesitant hopping rhythm
Pbindef(\toadSeq, \freq, Pn(Pgeom(100, 1.1, 8), inf)); // Repeating upward pitch sweep

//effect tweaks
Ndef(\toad).set(\wet11, 0.6); // Add rhythmic slapback delay
Ndef(\toad).set(\wet10, 0.8, \wet12, 1.0); // Massive distorted cave echo
Ndef(\toad).set(\wet10, 0, \wet11, 0, \wet12, 0); // Return to dry signal

//TOAD fade out and ending
(
Pbindef(\toadSeq).stop;
Ndef(\toad).fadeTime = 4;
Ndef(\toad).clear(4);
)