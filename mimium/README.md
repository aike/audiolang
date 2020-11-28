Mimium
===

# 概要

https://mimium.org/  
https://github.com/mimium-org/mimium

サウンドと音楽を記述/生成するためのドメイン固有言語。
ミュージシャンやプログラマー向けのツールだけでなく、ソースコードの形式で音楽を配信するためのインフラストラクチャとして作成されているとのこと。
九州大学の松浦知也さんが開発。2019年度未踏IT人材育成・発掘事業採択プロジェクト。


# 実装例

## セットアップ

Mimiumは現在も開発中ということもあり、セットアップ方法は今後変わることも考慮して詳細は割愛します。
手元のmacOS Catalinaの場合は、ビルド済みファイルを取得してlibの内容を/usr/local/libにコピー、実行ファイルやライブラリのセキュリティ警告に対応したら動きました。


## サイン波生成

関数定義やクロージャ、if式など構文はRustに似ているように思います。オーディオ処理についてはサンプルレベルの高精度処理や関数型言語的なアプローチはFaustやExtemporeなどからアイデアを取り込んでいるようです。
サンプル単位の低レベル処理はC++でのオーディオプログラミングにも通じるところがあります。

dsp関数がメインの処理で、ここに関数を書くと毎秒48000回呼ばれます。LLVMにコンパイルされるので高頻度で呼ばれる関数も十分高速に実行されます。

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

ビルトインのdelay関数はv0.1.5現在まだ実装中でv0.2.0から搭載予定ということがCHANGELOGに書いてあります。
そのためストリームにディレイをかけるにはv0.2.0を待つしかなさそうですが、wavファイルの再生時であればバッファ参照位置を工夫することでディレイを実現できます。

下記のseek関数はバッファのどこのデータを読むのか判断する関数です。
Mimiumの関数は前回の戻り値を覚えていてselfで参照できるので、seekのような関数でもポインタ的な変数を別途用意する必要がない点がユニークです。
フィルター処理など1サンプル前の値を参照することが多いオーディオプログラミング用言語ならではの機能です。

fb_delay関数がディレイ本体です。ディレイ用のバッファを持つのではなく、大元のバッファの読み出し位置をずらしながら加算しています。
ディレイエフェクトのフィードバックが再帰呼び出しに対応するのは再帰処理に強いMimiumならではと言えるかもしれません。
下の例では毎秒48000回×5階層の再帰呼び出しをおこなっていますが軽快に動作します。

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

あらたな音楽用言語を設計して高速なコードを生成するコンパイラを作るという野心的なプロジェクトなので以前から注目していました。
現状はまだ発展途上のところも多いですが、既存の言語を十分調査したうえで独自のアイデアを盛り込んでいるモダンな言語という印象です。

サンプル単位の処理をベースとしつつ、@による簡易タイマーや、selfによる過去への参照、再帰処理など、複数の時間軸が混在するオーディオプロセスにおいて、低レベル処理と抽象化をうまく共存させようとしているところにセンスを感じます。
これからどう進化するか期待しています。

