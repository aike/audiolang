SuperDirt.start;

(
SynthDef(\sinesynth, {|out, sustain=1.0, pan, freq|
	var sound = SinOsc.ar(freq);
	var env = EnvGen.ar(Env.linen(0.01, sustain, 0.01));
	OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
)
