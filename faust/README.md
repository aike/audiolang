Faust
===

# 概要

https://faust.grame.fr/

サウンド合成、オーディオ処理用関数型プログラミング言語(Functional-AUdio-STream)。コマンドラインコンパイラだけでなく、Web IDEやマルチプラットフォームで動くFaustLive統合環境なども用意されている。また、C++、C、Java、JavaScript、LLVM、WebAssemblyなど、多くの他言語やバイナリにトランスパイルできるのが特徴。

開発はGRAME(フランス国立音楽創造センター)。ブロックダイアグラムを代数的に表現するというアイデアは2002年(\*1)、それを関数型言語のアプローチによって実装したFaust言語が2004年に紹介された(\*2)。

(\*1) Yann Orlarey, Dominique Fober, and Stephane Letz. An algebra for block diagram languages. In ICMA, editor, Proceedings of International Computer Music Conference, pages 542–547, 2002.
(\*2) Yann Orlarey, Dominique Fober, and Stephane Letz. Syntactical and Semantical Aspects of Faust. Soft Computing, 8(9):623–632, 2004.

# 実装例

## サイン波生成

Faustのライブラリはオシレーターならos、エフェクトならefといった名前でグループ化されています。元がモノラルなので<: \_,\_をつけて2chのステレオ音声にして出力しています。この例ではわかりにくいですが、Faustが扱うデータはサンプル単位です（つまりMaxでいうところのGen）。  
Web IDE( https://faustide.grame.fr/ )やFaustLive( https://faust.grame.fr/downloads/#faustlive )で実行できます。

#### sine.dsp

```faust
import("stdfaust.lib");

freq = 440;
gain = 0.5;

process = os.osc(freq) * gain <: _,_;
```

## Delayエフェクト

Faustにはwavファイルを読み込んで再生する機能はありません。代わりに今回はディレイフィルターをソースコードdelay.dspに記述して、それを以下のようにfaust2sndfileでコンパイルすることでwavファイル加工ツール「delay」を生成します。

```
> faust2sndfile delay.dsp
```

生成されたdelayの第一引数に入力wavファイルを指定して実行すると、第二引数で指定したwavファイルにディレイ効果をかけた音声を出力します。 

```
> ./delay ../voice.wav voice_with_fx.wav
```

faust2sndfileを使わずに、このdelay.dspをWeb IDEやFaustLiveでそのまま実行すると、マイク入力した音声ストリームにディレイをかけてスピーカーで鳴らします。

#### delay.dsp

```faust
// compile: faust2sndfile delay.dsp
// run: ./delay ../voice.wav voice_with_fx.wav

import("stdfaust.lib");

maxDelayTime = 1.0;
delayTime    = 0.4;
feedback     = 0.5;

process = ef.echo(maxDelayTime, delayTime, feedback) <: _,_;
```


# 感想

関数型言語の特徴として「構造を宣言的に記述しやすい」という点があります。Faustも主眼はオーディオエンジンそのものではなくオーディオグラフ構造の記述性のようです。

オーディオプログラミングは逐次的処理のように思えるかもしれませんが、ほとんどの場合構造を定義する静的な部分と、構造に実際に信号を流し込む実行処理に分けることができます。Faustの場合、Maxのようなオーディオグラフの構造を代数的にテキスト言語で表現するという発想があり、それには関数型言語の文法が適していたということのようです。

テキスト言語で構造を記述することで、他の形式へ変換するトランスパイラが作りやすいという点は特徴的です。他にも、ビジュアル言語よりも最適化しやすく、ライブラリの再利用性も高いなどオーディオプログラミングがこれまで以上に進化する鍵になりそうな気もします。  
たとえ初見では黒魔術に見えたとしても。

触った印象としては、Web IDEやFaustLiveも安定しているしfaust2sndfileも一発で実行ファイルを生成できて、完成度としては高く感じました。ドキュメントも充実しているので、他にない特徴を持つ言語として今から学ぶには良いと思います。

ドキュメントに明記されていませんが、リポジトリにGPLとあるのでその点は少し注意が必要です。  
https://github.com/grame-cncm/faust/blob/master-dev/COPYING.txt

ライブラリはSTKライセンス。  
https://github.com/grame-cncm/faustlibraries/blob/master/licenses/stk-4.3.0.md

他の形式にトランスパイルするときの雛型となるアーキテクチャファイルはソースコードのコメントにGPLとあります。通常、コンパイラのライセンスとそれを使ってコンパイルした自作プログラムのライセンスは別ですが、リンクされるライブラリや雛型のライセンスは、ビルドしたプログラムを利用する際に考慮する必要があります。

Faustの場合、生成されたコードのライセンスはコンパイル対象のソースコードに従うという情報もあります。( http://olilarkin.co.uk/misc/JUCE_Summit.pdf )
