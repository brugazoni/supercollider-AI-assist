(
{
    // 1. Variable Structure
    var a, b, c, d, e, f, n, out;
    var trigB, trigC, trigD, envD, sweepD;

    // 2. Layer A (Clock): Raw Impulse at 8Hz
    a = Impulse.ar(8);

    // 3. Layer B (Noise Percussion):
    // FIXED: Use Impulse to trigger the envelope gate. Removed doneAction:2.
    trigB = Impulse.ar(1);
    b = WhiteNoise.ar(0.3) * EnvGen.ar(Env.perc(0.001, 0.05), gate: trigB);
    b = FreeVerb.ar(b, 0.1, 0.8, 0.9); // Mix 0.1, Room 0.8

    var lalalala;

    // 4. Layer C (Bass Pulse):
    // FIXED: TDuty generates triggers for the envelope.
    trigC = TDuty.ar(Dseq([1/4, 1/2, 1/8, 1/8], inf));
    c = SinOsc.ar(40);
    // Apply Envelope
    c = c * EnvGen.ar(Env.perc(0.01, 0.3), gate: trigC);
    // Crucial: 5.do loop for distortion (harmonic saturation)
    5.do { c = c.distort };

    // 5. Layer D (Impact Drone):
    // FIXED: Use Impulse.kr to re-trigger the envelope and filter sweep.
    trigD = Impulse.kr(1/16);
    envD = EnvGen.ar(Env([0, 1, 1, 0], [0.1, 8, 4], -4), gate: trigD);
    // Replaced XLine with EnvGen so it can re-trigger every 16s
    sweepD = EnvGen.ar(Env([4000, 4000, 200], [0, 15], \exp), gate: trigD);

    d = Saw.ar([20, 47]).sum;
    d = LPF.ar(d, sweepD);
    d = (GVerb.ar(d, 100, 3) * envD).clip(-0.8, 0.8);

    // 6. Layer E (Harmonic Swarm):
    n = 12;
    e = Mix.fill(n, { |i|
        var freq = 40 * (i + 1);
        var detune = LFNoise1.kr(0.1 + (i*0.05)).range(-0.5, 0.5);
        Saw.ar(freq + detune)
    });
    e = CombC.ar(e * 0.05, 0.2, 1/40, 0.1).tanh;

    // 7. Layer F (Glitch):
    // Envelope waits 8 seconds (0) then moves to 1.
    f = Blip.ar(LFNoise1.kr(4).exprange(200,800), 50) * Blip.ar(50, 20);
    f = f * EnvGen.ar(Env([0, 0, 1], [8, 0.5]));

    // 8. Output
    out = (a * 0.1) + b + c + d + e + f;
    out = out ! 2; // Stereo expand
    out * 0.2 // Final Amplitude scaling

}.play;
)
