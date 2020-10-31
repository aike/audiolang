Fs = 44100;
duration = 1;
frequency = 440;
gain = 0.3;
phase = 0:1/Fs:duration;
arr = gain * sin(2 * %pi * frequency * phase);
playsnd(arr, Fs)
