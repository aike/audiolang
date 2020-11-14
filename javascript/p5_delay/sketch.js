let voice;

function preload() {
  voice = loadSound('voice.wav');

  let delay = new p5.Delay();
  delay.process(voice);
  delay.delayTime(0.4);
  delay.feedback(0.5);
  delay.amp(0.5);
  delay.filter(sampleRate() / 2); // set nyquist frequency to disable LPF
}

function setup() {
  let canvas = createCanvas(100, 100);
  background('#ed225d');
  canvas.mousePressed(play);
}

function draw() {
}

function play() {
  voice.play();
}
