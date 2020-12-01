SuperCollider
===

# 概要

https://supercollider.github.io/

SuperColliderは、サウンドを扱うミュージシャン、アーティスト、研究者のための、オーディオ合成とアルゴリズム作曲用プラットフォーム。ライセンスはGPLv3。

1996年James McCartneyにより開発。James McCartneyは2002年アップル社に入りCoreAudio開発の初期メンバーとなる。
その年にSuperColliderはGPLでオープンソースとして公開され、現在はコミュニティにより管理されている。

# 実装例

## 文法解説

SuperColliderはあまり他の言語に似ていないので少し解説します。SuperColliderの関数やメッセージの概念はSmalltalkに近く、文法はLisp的な部分とC言語的な部分が混在しています。

関数定義は中括弧です。

```SuperCollider
{ 2 + 2 } // => a Function

基本は無名関数で、f = { 2 + 2 }のように変数に割り当てることで名前のついた関数になります。

関数にvalueメッセージを与えると評価して値を返します。

```SuperCollider
{ 2 + 2 }.value // => 4
```

C++のようなオブジェクト指向言語でいうと、関数はオブジェクト、メッセージはメソッドに相当します。

```SuperCollider
{ 2 + 2 }.postln // 画面に4を出力し、戻り値として4を返す
```

引数を定義するにはargを使います。

```SuperCollider
{ arg x; x + 2 }.value(2) // => 4
```

メッセージをチェーンすることもできます。

```SuperCollider
{ arg x; x + 2 }.value(2).postln // 画面に4を出力し、戻り値として4を返す
```

SuperColliderでもオブジェクトという用語を使います。関数だけでなく数値や文字列もオブジェクトです。

```SuperCollider
"Hello".postln // 画面にHelloと出力し、戻り値として"Hello"を返す

4.value // => 4

4.dup // => [ 4, 4 ]
```

このあたりはSmalltalk的であり、Rubyなどとも共通する設計です。


## サイン波生成

SuperColliderでのオーディオ処理は、UGens（ユニットジェネレーター）と呼ばれるオーディオユニットを使用します。UGenは、ar、krといったメッセージを受け取ると信号を出力し続けます。

arはAudio Rate、krはControl Rateを意味し、サンプルレート精度の信号と制御用の粗いレートの信号の違いがあります。

SinOSCでサイン波生成です。第2引数は位相、第3引数は音量です。SinOscの出力は1chのためPan2を使ってステレオ2chにして鳴らしています。

実行は対称の行にカーソルをあててCtrl+Enter、終了はCtrl+.です。

```SuperCollider
{ Pan2.ar(SinOsc.ar(440, 0, 0.3), 0) }.play;
```

## Delayエフェクト

SuperColliderのローカル変数はvarで定義します。  
変数に関してはいくつか特殊なルールがあります。グローバル変数は名前が\~からはじまります。1文字の変数は宣言なしに使えます。1文字変数のうちsはサーバを意味する値が設定されているため、それ以外の目的では使用できません。

UGenにはDelayNというのもありますが、フィードバックディレイはCombNを使います。DelayやCombにはNの他にDelayL、DelayCなどもあります。フランジャーのようにディレイタイムをモジュレーションする場合の補間アルゴリズムの違いなので、モジュレーションしない場合はシンプルなNを使います。CombNの第4引数は時間に対するフィードバックの減衰率を指定するので、delayTimeを掛けた方が一般的なフィードバック回数に対応したパラメータに近い意味になります。

関数の最終行でPan2を使ってステレオ2chにしています。

関数の外側の小括弧はコードブロックを意味します。Ctrl+Enterを押したときにカーソル位置が含まれるコードブロックが実行対象となります。

```SuperCollider
(
{
	var delayTime = 0.4;
	var feedback = 0.5;
	var wetLevel = 0.5;

	var voice = PlayBuf.ar(1,
		Buffer.read(s, Document.current.dir ++ "/../voice.wav"));

	var delay = CombN.ar(voice, delayTime, delayTime, feedback * delayTime * 10, wetLevel);

	Pan2.ar(voice + delay);
}.play
)
```


# 感想

SuperColliderは、90年代中旬に公開されたオーディオプログラミング言語としては設計思想や完成度の高さが驚異的に高く、後続の言語に多くの影響を与えています。言語(sclang)とオーディオエンジン(scserver)が疎結合で、それらの通信にOSCを使っていることでオーディオエンジンの再利用性が高いのも大きな特徴です。そのためscserverは、Sonic PI、Overtone、TidalCylesなどからも利用されています。

UGenはもともとMUSIC-N(直系はCsound)由来のものですが、これを採用したことでオーディオ処理の自由度の高さを実現したのも良いデザインです。

一方で言語自体があまりにもユニークであるため、敷居の高さは否めません。言語の設計思想としてはとても美しい簡潔さと整合性があり、SuperColliderの責任とは言い切れないですが、他の言語の知識が生かせないため、普及しているオーディオプログラミング言語としては学習コストの高さはトップクラスだと思います。音を鳴らしたいだけならSonic Piなどのインタフェース経由でSuperColliderエンジンを使う方が手軽です。

とはいえ、歴史の長い言語だけあって良質のドキュメントが大量にあるのは良い点です。統合環境も非常に安定していて使いやすいので、時間をかけて学習するだけの価値はあると思います。
