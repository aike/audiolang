// compile: faust2sndfile delay.dsp
// run: ./delay ../voice.wav voice_with_fx.wav

import("stdfaust.lib");

maxDelayTime = 1.0;
delayTime    = 0.4;
feedback     = 0.5;

process = ef.echo(maxDelayTime, delayTime, feedback) <: _,_;

