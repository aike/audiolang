  
import processing.sound.*;
SoundFile voice;
Delay delay;

void setup() {
  voice = new SoundFile(this, "../../voice.wav");
  delay = new Delay(this);
  
  delay.process(voice, 1.0);
  delay.time(0.4);
  delay.feedback(0.5);

  voice.play();
}      

void draw() {
}
