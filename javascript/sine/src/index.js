
window.addEventListener("load", ()=>{
  const sleep = msec => new Promise(resolve => setTimeout(resolve, msec));

  const ctx = new AudioContext();

  const button = document.querySelector('button');
  button.onclick = async ()=>{
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
    await sleep(1000);
    osc.stop();
  };

});
