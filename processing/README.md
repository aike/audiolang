Processing
===

# 概要

https://processing.org/

アート、デザイン、研究、教育など、クリエイティブコーディングを目的とした言語。基本はグラフィックプログラミング用であるが、追加ライブラリによりオーディオプログラミングも可能。

MITメディアラボのJohn Maedaグループに在籍していたBen FryとCasey Reasが2001年に開発。2012年からはProcessing Foundationによって管理されている。当初、processing.orgのドメインが使えずproce55ing.orgを使用していた。そのためProce55ingと呼ばれることもあったが正式な名称ではなく、現在ではほとんど使われることはない。（p5.jsなどに名残がある）

# 実装例

Processingのオーディオライブラリとしては、Minim( http://code.compartmental.net/minim/index.html )またはSound( https://processing.org/reference/libraries/sound/index.html )を使用することが多いようです。Processing 2ではMinimが標準バンドルされていました。SoundはProcessing 3用にProcessing Foundationが開発した公式ライブラリです。どちらもスケッチメニューから追加インストールすることで使えるようになります。

## サイン波生成

### Minimライブラリの場合

```Processing
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
```

### Soundライブラリの場合

Soundライブラリでのオシレーターは非常にシンプルに書くことができます。初期化と同時に音を出すとノイズが乗るようなので500msec待ってからplay()を呼ぶようにしました。

```Processing
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
```

## Delayエフェクト

### Minimライブラリの場合

Minimライブラリは、さらにMinim Core系列とUGen系列とがあります。単純なwavファイル再生の場合、Minim CoreのAudioPlayerを使用することもできるますが、UGenの方がエフェクトも充実し、オーディオグラフのルーティングも柔軟におこなえるため、以下の例ではUGenを使用しています。

```Processing
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
Sampler voice;
Delay delay;
Gain wet;
AudioOutput out;

void setup(){
  float delayTime = 0.4;
  float feedback = 0.5;
  float wetLevel = -6; // dB

  minim = new Minim(this);
  voice = new Sampler("../../voice.wav", 1, minim);
  delay = new Delay(delayTime, feedback, true, false);
  wet = new Gain(wetLevel);
  out = minim.getLineOut();

  // routing
  voice.patch(out);  // dry
  voice.patch(delay).patch(wet).patch(out); // wet

  // play 
  voice.trigger();
}

void draw(){
}
```

### Soundライブラリの場合

Soundライブラリはシンプルで扱いやすい一方で、あまり複雑なことはできず、ディレイもDryとWet個別に調整することはできないようです。

```Processing
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
```

# 感想

Processingはクリエイティブコーディングという概念を一般に広めた言語だと思います。構文のわかりやすさ、IDEの使いやすさなど、気軽に使うことができるのが特徴です。また、setup→drawのプログラム構造は、openFrameworksやCinderなどにも引き継がれており、クリエイティブコーディングを学ぶ最初の言語として最適だと思います。

オーディオプログラミングに関しては、Processing 3になって公式ライブラリとしてSoundが提供されるようになり、それまで多用されてきたMimimと混乱の原因になっているようにも思います。今回両方使ってみた印象では、シンプルなオーディオ処理であればわかりやすいSound、少し凝ったエフェクト処理をおこなう場合は機能が豊富なMimimのUGenを選択するのが良さそうでした。

