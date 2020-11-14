import * as Tone from 'tone';

window.addEventListener("load", ()=>{

  // setup nodes and audio graph
  const voice = new Tone.Player("voice.wav");
  const delay = new Tone.FeedbackDelay().toDestination();
  delay.delayTime.value = 0.4;
  delay.feedback.value = 0.5;
  delay.wet.value = 0.33; // dry:wet = 0.66:0.33 = 2:1
  voice.connect(delay);

  const button = document.querySelector('button');
  button.onclick = async ()=>{
    await Tone.start(0);
    // play
    voice.start(0);
  };

});
