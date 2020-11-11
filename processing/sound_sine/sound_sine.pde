import processing.sound.*;
SinOsc osc;

void setup() {
  osc = new SinOsc(this);
  osc.freq(440);
  osc.amp(0.5);
  delay(500);
  osc.play();
}

void draw() {
}
