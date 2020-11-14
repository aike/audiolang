
window.addEventListener("load", ()=>{
  const ctx = new AudioContext();

  const button = document.querySelector('button');
  button.onclick = ()=>{
    if (ctx.state=="suspended")
      ctx.resume();

    // setup nodes
    const osc = new OscillatorNode(ctx);
    osc.type = 'sine';
    osc.frequency.value = 440;

    const amp = new GainNode(ctx);
    amp.gain.value = 0.5;

    // setup audio graph
    osc.connect(amp).connect(ctx.destination);

    // play
    osc.start(0);
    // after 1 second, stop the sound
    osc.stop(1);
  };

});
