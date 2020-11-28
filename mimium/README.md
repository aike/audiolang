Mimium
===

# 概要

https://mimium.org/
https://github.com/mimium-org/mimium

サウンドと音楽を記述/生成するためのドメイン固有言語。
ミュージシャンやプログラマー向けのツールだけでなく、ソースコードの形式で音楽を配信するためのインフラストラクチャとして作成されているとのこと。
九州大学の松浦知也さんが2019年度未踏IT人材育成・発掘事業で開発。


# 実装例

## セットアップ

Mimiumはまだ開発中ということもあり、セットアップ方法は今後変わることもあると思うので、詳細は割愛します。
手元のmacOS Catalinaの場合は、ビルド済みファイルを取得してlibの内容を/usr/local/libにコピーして、実行ファイルやライブラリのセキュリティ警告に対応したら動きました。


## サイン波生成

関数定義やクロージャ、if式など構文はRustに似ています。オーディオ処理についてはサンプルレベルの高精度処理や関数型言語的なアプローチがFaustやExtemporeなどのアイデアを
サンプル単位の処理はC++のプログラミングにも共通します。

dsp関数がメインの処理で、ここに関数を書くと毎秒48000回呼ばれます。

```Rust
SampleRate = 48000
PI = 3.1415956

theta = 0
delta = 0

fn sin_osc(freq:float) {
    delta = 2 * PI * freq / SampleRate
    theta = theta + delta
    return sin(theta)
}

gain = 0.5

fn dsp(time:float)->float {
    return sin_osc(440) * gain
}
```


## Delayエフェクト

ビルトインのdelay関数はv0.1.5現在まだ実装中で、v0.2.0から搭載予定てCHANGELOGに書いてあります。
ストリーミングにディレイをかけるにはv0.2.0を待つしかなさそうですが、wavファイルの再生時であればバッファ読み込みを工夫することでディレイを実現できます。
ディレイエフェクトのフィードバックが再帰呼び出しに対応するのはMimiumらしいプログラムと言えるかもしれません。

seek関数はバッファのどのデータを読むのか判断する関数です。
関数は前回の戻り値を覚えていてselfで参照できるので、ポインタのような変数を用意する必要がないのがユニークです。


```Rust

voice = "../voice.wav"
bufsize = loadwavsize(voice)
voicebuf = loadwav(voice)

delay_time = 0.4
feedback = 0.5
num_feedback = 5

fn seek(speed, size) {
    return if(self < size * 2) self + speed else self
}

fn fb_delay(buf, size, delay, pos, fb) {
    return if ((fb < 0) || (pos < 0)) 0 else buf[min(pos, size - 1)] + fb_delay(buf, size, delay, pos - delay * 48000, fb - 1) * feedback
}

fn dsp(time)->float {
    pos = seek(44100 / 48000, bufsize)
    return fb_delay(voicebuf, bufsize, delay_time, pos, num_feedback)
}
```

# 感想

Schemeの安定感やxtlangの高速性、また多くの機能がxtlangで実装されていることからもわかる表現力など、高度な設計スキル、実装スキルにもとづいて作られた言語であることは間違いように思います。
今回は目的にあわず説明できませんでしたが、メロディーやループパターンを表現するためのPattern Languageも用意されていて、それもまたひとつのDSLとして興味深いものがあります。

一方でドキュメントが不足している印象は否めません。
コンセプトの説明や簡単なチュートリアルは充実しているものの、xtlangの基本的な仕様や構文についての体系的な説明はほとんどないですし、ライブラリの網羅的なドキュメントもありません。
Extemporeを使いこなすには、標準ライブラリやサンプルプログラムのソースコードを大量に読んで仕様を把握する必要があります。

サイバーフィジカルプログラミング構想のような大局的な視点は他の言語にはないもので、ライブコーディングの先にある動的なプログラミングの可能性に期待が持てそうな印象はあります。

