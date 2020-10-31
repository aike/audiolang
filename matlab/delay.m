[y, Fs] = audioread('../voice.wav');

delayTime = 0.4;
feedback = 4;
wetLevel = 0.5;
attenuate = 0.5;

delaySample = round(delayTime * Fs); 
wet = attenuate * [zeros(delaySample, 1); y];
for i = 2 : feedback
    currentWet = power(attenuate, i) * [zeros(delaySample, 1); wet];
    wet = [wet; zeros(delaySample, 1)];
    wet = wet + currentWet;
end
y = [y; zeros(delaySample * feedback, 1)];
y = y + wet * wetLevel;

sound(y,Fs);