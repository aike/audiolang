[y, Fs] = wavread('../voice.wav');

delayTime = 0.4;
feedback = 4;
wetLevel = 0.5;
attenuate = 0.5;

delaySample = round(delayTime * Fs); 
wet = attenuate * cat(2, zeros(1, delaySample), y);
for i = 2 : feedback
    currentWet = (attenuate^i) * cat(2, zeros(1, delaySample), wet);
    wet = cat(2, wet, zeros(1, delaySample));
    wet = wet + currentWet;
end
y = cat(2, y, zeros(1, delaySample * feedback));
y = y + wet * wetLevel;

playsnd(y,Fs);
