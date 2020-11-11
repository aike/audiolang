import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
Sampler voice;
Delay delay;
Gain wet;
AudioOutput out;

void setup(){
  float delayTime = 0.4;
  float feedback = 0.5;
  float wetLevel = -6; // dB

  minim = new Minim(this);
  voice = new Sampler("../../voice.wav", 1, minim);
  delay = new Delay(delayTime, feedback, true, false);
  wet = new Gain(wetLevel);
  out = minim.getLineOut();

  // routing
  voice.patch(out);  // dry
  voice.patch(delay).patch(wet).patch(out); // wet

  // play 
  voice.trigger();
}

void draw(){
}
