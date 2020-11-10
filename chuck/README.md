ChucK
===

# 概要

https://chuck.cs.princeton.edu/

マルチメディア用のオープンソースのビジュアルプログラミング言語。
並行処理や処理実行中の変更（オンザフライ）が特徴。
作曲、研究、教育、ライブコーディングなどに使用される。
IDEとしてminiAudicleが用意されている。
ライセンスはGPL。

プリンストン大のGe Wang（現在はスタンフォード大、Smule社）が開発。


# 実装例

## サイン波生成

ChucKの最大の特徴は多目的に使用されるChucK演算子=>です。
この例でもオーディオグラフの連結、値の変数への代入、時間制御にChucK演算子を使っています。

```ChucK
SinOsc sine => Gain g => dac;

440 => sine.freq;
0.5 => g.gain;

1::second => now;
```

## Delayエフェクト

ループ構造もChucK演算子を使って簡潔に表現できます。

```ChucK
// read wav file
me.dir() + "/../voice.wav" => string filename;
SndBuf buf;
filename => buf.read;

// setup audio graph
buf => Gain delayLoop => dac;
delayLoop => Gain feedback => Delay delay => delayLoop;

// setup parameters
400::ms => delay.max => delay.delay;
0.5 => feedback.gain;
0.5 => delay.gain;

// play sound
buf.length() * 2 => now;
```


# 感想

ChucK演算子など、あまり他の言語に似ていない独自性の高い仕様ですが、言語設計として非常に洗練されており、素直にシンプルに書くことができます。
ライブコーディングパフォーマンス用言語としては、予想外の音というより想定通りの音を出しやすい印象です。
統合環境miniAudicleの完成度も高く、軽快に動作するので全体として非常に使いやすいです。

モバイル対応ChiP(ChucK for iPhone)やUnity用アセットもあり、応用先は広いように思います。
（これらはGPLではありません）

