window.addEventListener("load", async ()=>{
  const ctx = new AudioContext();

  const buffer = await LoadSample(ctx, "voice.wav");

  const button = document.querySelector('button');
  button.onclick = ()=>{
    if (ctx.state=="suspended")
      ctx.resume();

    // setup nodes
    const voice = new AudioBufferSourceNode(ctx);
    voice.buffer = buffer;

    const delay = new DelayNode(ctx);
    delay.delayTime.value = 0.4; // second
    const wetLevel = new GainNode(ctx);
    wetLevel.gain.value = 0.5;
    const feedback = new GainNode(ctx);
    feedback.gain.value = 0.5;

    // setup audio graph
    voice.connect(ctx.destination); // dry
    voice.connect(delay).connect(wetLevel).connect(ctx.destination);
    delay.connect(feedback).connect(delay);

    // play
    voice.start(0);
  }
});

function LoadSample(ctx, url) {
  return new Promise((resolv)=>{
    fetch(url).then((response)=>{
      return response.arrayBuffer();
    }).then((ary)=>{
      return ctx.decodeAudioData(ary);
    }).then((buf)=>{
      resolv(buf);
    })
  });
}
