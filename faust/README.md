Faust
===

# 概要

https://faust.grame.fr/

サウンド合成、オーディオ処理用関数型プログラミング言語。
オンラインコンパイラやマルチプラットフォームで動くFaustLive開発実行環境など。
実行だけでなく、C++、C、Java、JavaScriptその他の言語やバイナリにコンパイルできるのが特徴

開発はGrame Research Lab(フランス)


# 実装例

## サイン波生成

オンラインコンパイラ( https://faustide.grame.fr/ )やFaustLive( https://faust.grame.fr/downloads/#faustlive )で実行できます。Faustのライブラリはオシレーターならos、エフェクトならefといった名前でグループ化されています。

```faust
import("stdfaust.lib");

freq = 440;
gain = 0.5;

process = os.osc(freq) * gain <: _,_;
```

## Delayエフェクト

Faustにはwavファイルを読み込んで再生する機能はありません。
今回は、ディレイフィルターを記述して、それをfaust2sndfileでコンパイルすることでwavファイル加工ツール「delay」を生成しています。
delayに入力wavファイルを指定すると、それにディレイ効果をかけたwavファイルを出力します。
下のディレイフィルタープログラムをオンラインコンパイラで実行すると、マイク入力した音にディレイをかけてスピーカーで鳴らします。

```faust
// compile: faust2sndfile delay.dsp -double
// run: ./delay ../voice.wav voice_processed.wav

import("stdfaust.lib");

maxDelayTime = 1.0;
delayTime    = 0.4;
feedback     = 0.5;

process = ef.echo(maxDelayTime, delayTime, feedback) <: _,_;
```


# 感想

関数型言語の特徴として「構造を宣言的に記述する」というのがあります。
Faustも主眼を置いているのは実行そのものではなくオーディオグラフ構造の記述性のように感じます。
オーディオエンジンを作りたいというより、Maxのようなオーディオグラフの構造をテキスト言語で記述するという発想があり、それに関数型言語の文法が適していたという印象です。

テキスト言語で構造を記述するメリットのうち、様々な形式へ変換するコンパイラが作りやすいという特徴は特にわかりやすい成果を上げています。
また、gitなどのバージョン管理が容易になり、ライブラリの再利用性も向上するため、オーディオプログラミングがこれまで以上に進化する鍵になりそうな気もします。
たとえ初見では黒魔術に見えたとしても。

触った印象としては、オンラインコンパイラやFaustLiveも安定しているしfaust2sndfileも一発で実行ファイルを生成できて、完成度としては高く感じました。ドキュメントも充実しているので、今から学ぶには良い言語だと思います。

