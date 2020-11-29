Gibber
===

# 概要

https://gibber.cc/  
https://github.com/gibber-cc/gibber  
https://bigbadotis.gitbooks.io/gibber-user-manual/content/

Webブラウザで高レベルのオーディオ合成とシーケンスを実行するための言語とライブパフォーマンス環境。JavaScriptのAudio機能を、より簡潔な記述で扱えるように設計されている。2D/3Dグラフィックや複数人によるコラボレーション機能もサポートしている。

カリフォルニア大学のCharles Robertsにより開発。初出は2012年(*1)

(*1) C.Roberts and J.Kuchera-Morin,"Gibber: Live Coding Audio In The Browser," in Proceedings of the International Computer Music Conference, 2012, pp. 64–69.

# 実装例

## サイン波生成

Sine関数で簡単に音を鳴らすことができます。引数は値でもJSONでも与えることができます。  
実行はソースの対象部分を選択してCtrl+Enter、終了はCtrl+.です。

```JavaScript
Sine(440, 0.5)

Sine({ frequency:440, amp:0.5 })
```

## Delayエフェクト

GibberはWebアプリということもあり、任意のwavファイルを鳴らすことはできません。それでもいくつか近い機能は用意されています。

* Sampler()を使ってマイク入力などを録音して鳴らす
* Soundfont()を使ってあらかじめ用意されているサンプリング音を鳴らす
* Freesound()を使って https://freesound.org/ にアップロードされている音を鳴らす

今回はFreesound()を使いました。

また、Gibberのディレイも独特な仕様になっています。

* ディレイタイムは1/4（四分音符）、1/8（八分音符）などと音符の長さで指定する。つまりBPMの影響を受ける
* フィードバックを0にするとシングルディレイ
* 初回のディレイ音はドライ音と同じ音量
* ドライとウェットの音量調節や個別出力は不可

そのため、今回他の言語のサンプルプログラムと同等の音にするのはできませんでした。ディレイタイムについてはms()関数を使うことでミリ秒指定できるようです。

```JavaScript

voice = Freesound(213284);
// sampling audio is licensed under Creative Commons BY Attribution 3.0 AderuMoro.
// https://freesound.org/s/213284/
// https://www.youtube.com/user/AderuMoro

Clock.bpm = 120
delayTime = ms(400)
feedbackLength = 0.5

delay = Delay({ time:delayTime, feedback:feedbackLength })
voice.fx.add(delay)

voice.note(1)
```

# 感想

インストール不要でWebブラウザがあれば音と映像のライブコーディングができる環境は手軽でとても便利です。ユーザインタフェースも洗練されていてわかりやすいです。言語自体はシンプルなのですぐに覚えられると思います。今回は触れられませんでしたが、TidalCyclesのようなループシーケンサーも簡単に書くことができます。

freesound.orgの音を簡単に鳴らせるのは表現の幅が大きく広がるので楽しいです。ちなみにfreesound.orgの音を鳴らす機能はOvertone言語にも用意されています。TidalCyclesのDirt Samplesなどと並んで、ライブコーディングに使うサンプリング素材のスタンダードと言えるかもしれません。

一方でバグのような挙動やドキュメントの不備があり、使っていて戸惑うことが多かったです。変数の内容を表示するような機能もないため、原因を追うのも時間がかかります。

* プレイグラウンドのhelpからリファレンスマニュアルを見ようとするとリンク切れになっている
* おそらくClock.bpmにバグがあり、120以外のときは正しいテンポにならない。たとえばClock.bpm=155とすると実際にはBPM200くらいになる
* ディレイタイムなどもテンポに依存するのでBPM120以外のときは正しい長さを指定するのが困難
* Freesoundで同じサンプルを再度取得しようとすると失敗する

Version2のプレイグラウンド( https://gibber.cc/alpha/playground/ )もあり、テキストエディタ内に変動データのアニメーションが表示されるなどとても魅力的なのですが、これはこれでアルファ版でVersion1とはまた違ったバグが出たのであまり触っていません。

このあたりの使いづらさが解消されたら、手軽なライブコーディング環境として選択肢のひとつになるように思います。

