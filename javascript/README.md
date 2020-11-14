JavaScript
===

# 概要

https://www.w3.org/TR/webaudio/

Web Audio APIはWebブラウザのJavaScriptで使用できるオーディオAPI。W3Cが仕様を策定して各ブラウザのデベロッパーが実装している。

# 実装例

JavaScriptでオーディオプログラミングをするにはWeb Audio APIを直接使用することもありますが、最近はTone.jsを使うことが多いようです。また、Processing言語のJavaScript版であるp5.jsのオーディオ機能も利用しやすいのでこちらの実装例も紹介します。
Tone.jsもp5.jsもWeb Audio APIをラップして使っています。

## Web Audio API

特に追加のライブラリはありませんが、現実的なプロジェクトを想定してnpmとwebpackを使うようにしてみました。

package.jsonの内容は以下のようになります。

```json
{
  "name": "example",
  "version": "1.0.0",
  "description": "web audio example",
  "main": "index.js",
  "scripts": {
    "build": "webpack",
    "serve": "webpack serve"
  },
  "author": "aike",
  "license": "MIT",
  "devDependencies": {
    "webpack": "^5.4.0",
    "webpack-cli": "^4.2.0",
    "webpack-dev-server": "^3.11.0"
  }
}
```

index.htmlは以下の内容です。

```html
<!DOCTYPE html>
<html>
<head></head>
<body>
  <script src="dist/main.js"></script>
  <button>click</button>
</body>
</html>
```

### サイン波生成

Web Audio APIでは、単機能のノードを生成して、connect()でつなげていくことでオーディオ処理を記述します。最終的にAudioContextオブジェクトのdestinationにconnect()すると音が出力されます。

重要な注意点としてAutoplay Policyがあります。これは、Webではユーザのアクションなしに音声の自動再生を禁止するというものです( https://developers.google.com/web/updates/2018/11/web-audio-autoplay )。
そのため、onclickなどのユーザーアクションのコールバックとして音声処理を実装する必要があります。
コールバックの先頭ではオーディオコンテキストをチェックして休止していたらresumeする処理を入れておきます。

また、オシレータなどの発音ノードは一度start()してstop()したら再利用はできない点も注意が必要です。再び音を鳴らす場合はまた新しくOscillatorNodeを作る必要があります。これはかなり直感に反するので最初は戸惑うかもしれません。  
以下の例ではオシレータだけでなくゲインノードもクリックするたびに毎回生成しています。

```JavaScript
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
```

### Delayエフェクト

Webブラウザは原則としてローカルファイルを読めないので、wavファイルは非同期でサーバから取得する必要があります。
以下の例では非同期処理をシンプルに書くためにasync/awaitやPromiseを使っています。

wavファイルを再生するためのAudioBufferSourceNodeも一回鳴らしたら再利用はできません。毎回サーバへファイルを要求しないように一度取得したデータはbufferに格納しておいて、生成したAudioBufferSourceNodeに渡すようにしています。

以前はcontext.createDelay()のようなAPIで各ノードを生成していましたが、最近はnew DelayNode(context)のようにしても生成できるようになりました。newを使う方がより自然に見えるので以下の例ではnewで生成しています。

```JavaScript
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
```

## Tone.js

https://tonejs.github.io/

Tone.jsは、前項で書いたようなWeb Audio APIの直感に反する点や頻出する定型的な記述を軽減します。

Tone.jsは、npm install tone --save としてインストールします。これによりpackage.jsonのdependenciesにtoneが追加されます。

```json
{
  "name": "example",
  "version": "1.0.0",
  "description": "Tone.js example",
  "main": "index.js",
  "scripts": {
    "build": "webpack",
    "serve": "webpack serve"
  },
  "author": "aike",
  "license": "MIT",
  "dependencies": {
    "tone": "^14.7.58"
  },
  "devDependencies": {
    "webpack": "^5.4.0",
    "webpack-cli": "^4.2.0",
    "webpack-dev-server": "^3.11.0"
  }
}
```

index.htmlはWeb Audio APIのものと同じです。

```html
<!DOCTYPE html>
<html>
<head></head>
<body>
  <script src="dist/main.js"></script>
  <button>click</button>
</body>
</html>
```


### サイン波生成

Web Audio APIの例と比べるとかなりシンプルになっているのがわかるかと思います。
ノード生成とパラメータ設定と接続先設定を一行で書いています。
また、発音ノードを毎回生成するように書く必要はありません。

```JavaScript
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
```


### Delayエフェクト

Delayエフェクトもシンプルです。Tone.jsではフィードバックディレイが最初から用意されているため複雑なルーティングは必要ありません。

```JavaScript
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
```


## p5.js

https://p5js.org/

p5.jsはProcessing言語同等のものをJavaScriptで実装したライブラリです。構文はあくまでもJavaScriptなのでProcessingとソースコードレベルの互換性はありませんが、わずかな違いなのでProcessing経験者であればすぐに使えるようになります。JavaScript側からの観点でも、Processingの直感的なわかりやすさは大きなメリットです。

p5.jsのオーディオ機能は、以前はMinim風のライブラリもありましたが、現状はProcessingのオーディオAPIとの互換性をあまり意識していないp5.soundが標準的に使われています（ https://p5js.org/reference/#/libraries/p5.sound ）。
比較的変わりやすいWeb Audio APIの最近の仕様にも追従していて使いやすいライブラリになっています。

p5.jsの場合、npmやwebpackを使わない方がシンプルでProcessingらしい書き方になるので、それらを使わずに以下のindex.htmlのようにheadの中でp5.jsとp5.sound.jsを取得して利用するようにしました。

```html
<!DOCTYPE html>
<html>
  <head>
    <script src="https://cdn.jsdelivr.net/npm/p5@1.1.9/lib/p5.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.1.9/addons/p5.sound.js"></script>
    <script src="sketch.js"></script>
  </head>
  <body>
    <main>
    </main>
  </body>
</html>
```

### サイン波生成

p5.jsもシンプルに直感的に書くことができます。発音ノードのライフサイクルを気にする必要はありません。p5.jsではキャンバスのクリックに反応するプログラムも慣習的に多いのでAutoplay Policyもあまり気にならないように思います。

```JavaScript
let osc;

function setup() {
  let canvas = createCanvas(100, 100);
  background('#ed225d');

  osc = new p5.Oscillator('sine');
  osc.amp(0.5);
  osc.freq(440);
  canvas.mousePressed(play);
}

function draw() {
}

function play() {
  osc.start();
  osc.stop(1);
}
```

このプログラムはp5.js Editor( https://editor.p5js.org/ )でも実行することができます。


### Delayエフェクト

p5.soundにはフィードバックディレイが最初から用意されているのでこちらもシンプルです。
ただしディレイ成分にはかならずローパスフィルターがかかるようになっているため、他の実装例と近い音になるようフィルターのカットオフ周波数を全開（＝ナイキスト周波数）にしてフィルター効果を無効にしています。

```JavaScript
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
```

このプログラムはp5.js Editorでは実行できません。サウンドファイルがサーバに存在しないためLoading...の状態で止まります。実行確認はローカルサーバなどでおこなってください。

# 感想

Web Audio APIが最初に登場したときは、本格的なオーディオプログラミングが可能で、それをそのまますぐにWebで公開できるということがとても画期的と感じました。
その後、Web Audio APIも、JavaScriptをとりまく環境も進化していった結果、使いやすくなった点も多いもののシンプルさが失われていった部分もあります。また発音ノードのライフサイクルなどあまり直感的ではない仕様もやはり気になります。

Tone.jsはそういった理不尽さをほとんど感じることがないように、利用しやすさを重視したライブラリになっているので、現状では最初からTone.js前提で考えても良いように思います。

p5.jsのオーディオ機能は、以前使用したときはまだ実装が十分追いついていなかったイメージがありましたが、現在は機能も豊富で実行も安定しているのでProcessingのような使い方をする場合はこちらも良い選択肢です。

p5.jsやFaustなど、プログラミング言語をローカルにインストールせずにWeb上のプレイグラウンドでオーディオ処理を試すことができる環境が増えてきたのもWeb Audio APIの重要な功績です。

一方で、実装がブラウザのデベロッパー依存であるため、細かい部分ではブラウザによって挙動が異なることもある点は注意が必要です。今回のプログラムはすべてWindows PCのGoogle Chromeで確認しました。

なお、Web Audio APIはあくまでブラウザのAPIという位置づけのようで、Node.jsにオーディオ機能が搭載されることはなさそうです。
Node.js上にWeb Audio API相当のものを実現するライブラリはいくつか開発されましたが、いずれもNode.js公式のものではなく、今回調べたところ数年前から開発が止まっていて最新のWeb Audio APIに追従したものはないようでした。

