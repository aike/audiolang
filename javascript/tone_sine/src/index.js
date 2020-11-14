import * as Tone from 'tone';

window.addEventListener("load", ()=>{

  // setup nodes and audio graph
  const amp = new Tone.Gain(0.5).toDestination();
  const osc = new Tone.Oscillator(440, "sine").connect(amp);

  const button = document.querySelector('button');
  button.onclick = async ()=>{
    await Tone.start();

    // play
    osc.start(0);
    // after 1 second, stop the sound
    osc.stop("+1.0");
  };

});
