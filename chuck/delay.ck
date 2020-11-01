// read wav file
me.dir() + "/../voice.wav" => string filename;
SndBuf buf;
filename => buf.read;

// setup audio graph
buf => Gain delayLoop => dac;
delayLoop => Gain feedback => Delay delay => delayLoop;

// setup parameters
400::ms => delay.max => delay.delay;
0.5 => feedback.gain;
0.5 => delay.gain;

// play sound
buf.length() * 2 => now;
