SinOsc sine => Gain g => dac;

440 => sine.freq;
0.5 => g.gain;

1::second => now;
