Ndef(\sig).fadeTime_(2).play; //starts the noise ndef
Ndef(\sig, {BrownNoise.ar(0.1) ! 2}).play; //starts the noise in the ndef

Ndef(\filter).fadeTime_(2).play //starts the filter ndef
Ndef(\filter, {LPF.ar(Ndef.ar(\sig), 1000)});
Ndef(\sig).stop(2);
//remember: \sig is the name of the cable, Ndef(\sig) is the actual signal

Ndef(\lfo, {LFTri.kr(1, mul: 600)}); //create the lfo ndef
(
Ndef(\filter, {
	var cutoff = 1000;
	LPF.ar(Ndef.ar(\sig), freq: (cutoff + Ndef.kr(\lfo)).clip(20, 20000));
});
)

Ndef(\lfo, {LFPar.kr(1, mul: 600)}); //change lfo shape
Ndef(\lfo, {LFPulse.kr(1, mul: 600)});