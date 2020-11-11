import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
Oscil osc;
AudioOutput out;

void setup(){
  float frequency = 440;
  float gain = 0.5;

  minim = new Minim(this);
  osc = new Oscil(frequency, gain);
  out = minim.getLineOut();

  // routing and play
  osc.patch(out);
}

void draw(){
}
