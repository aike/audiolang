SOUL
===

# 概要

https://soul.dev/
https://github.com/soul-lang/SOUL

既存環境の課題である、性能、移植性、開発容易性の改善を目的として開発されたオーディオ記述言語。Webプレイグラウンドも用意されている( https://soul.dev/lab/ )。

開発はJUCEで有名なROLI社。ROLIに買収される以前からほぼひとりでJUCEを開発していたJules Storerがメインコントリビューター。初出はADC2018カンファレンスのJules Storer自身による基調講演( https://www.youtube.com/watch?t=910&v=-GhleKNaPdk )。

ISCベースの独自ライセンス。大規模な商用利用は別途ライセンス契約が必要になる場合がある。
https://github.com/soul-lang/SOUL/blob/master/LICENSE.md

# 実装例

## サイン波生成

SOULのプログラムはprocessor宣言の中に書きます。void run()がメイン処理です。

位相が2πを超えないようにするaddModulo2Pi()関数など、オーディオ処理の頻出処理用関数が用意されています。

```C++
processor SineWave
{
    output stream float out;

	float gain = 0.3f;
    float theta = 0.f;
    float delta = float (440 * twoPi * processor.period);

    void run()
    {
        loop
        {
            out << sin(theta) * gain;
            theta = addModulo2Pi(theta, delta);
            advance();
        }
    }
}
```

SOULはソースコードである.soulファイルの他に、マニフェストファイル.soulpatchが必要です。JSON形式のテキストファイルにアプリケーション情報を記述して拡張子.soulpatchで保存します。

```JavaScript
{
    "soulPatchV1":
    {
        "ID":               "net.aikelab.sine",
        "version":          "1.0",
        "name":             "SineWave",
        "description":      "sine wave example",
        "category":         "synth",
        "manufacturer":     "aikelab.net",
        "isInstrument":     false,

        "source":           "sine.soul"
    }
}
```

コマンドラインから実行します。第2引数で指定するのは.soulpatchのファイル名です。

```
> soul play sine
```

しかしながら、手元のWindows環境ではパスの\文字をうまく解釈できないようで実行に失敗します。
配布ファイルに含まれているSOUL_Pluginツールを使うとWindowsでも実行可能です。

SOULではGUIを追加するのも簡単です。ソースコードにeventとして入力範囲指定とコールバックを追加するだけでGUIの定義になります。

```C++

processor SineWave
{
    output stream float out;

	input event
	{
		float Gain [[ min:0, max:1,init:0.3, step: 0.01 ]];
	}

	event Gain(float f) { gain = f; }

	float gain;
    float theta = 0;
    float delta = float (440 * twoPi * processor.period);

    void run()
    {
        loop
        {
            out << sin(theta) * gain;
            theta = addModulo2Pi(theta, delta);
            advance();
        }
    }
}
```

SOUL_Pluginツールを使ってsoulpatchファイルを読み込むと、下の画面が表示されGUIから音を操作できるようになります。

[sine.png](sine.png)


サイン波のオシレータやゲイン処理はライブラリとしても用意されています。それらを使ったプログラムは以下のようになります。graph宣言は、複数のprocessorを部品として扱ってオーディオグラフを構築します。

```C++
graph SineWave
{
	output stream float out;

	let osc = soul::oscillators::Sine(float, 440);
	let gain = soul::gain::FixedGain(float, 0.3f);

	connection
	{
		osc -> gain -> out;
	}
}
```


## Delayエフェクト

SOULはリングバッファ用の機能がいくつか用意されています。たとえばwrap<bufferSize>とした場合、bufferSizeを超えてアクセスしようとすると実際には0～bufferSizeの範囲にしてアクセスされます。

wavファイルのファイル名は.soulpatchの方に書いて、ソースコードではリソース名（今回はvoice）を指定します。

readLinearInterpolatedは、サンプリングデータの再生速度を調整するための補間関数です。
今回はアプリとwavファイルのサンプルレートが異なるときの調整に使っています。

```C++
processor Delay
{
    output stream float out;

    input event
    {
        float DelayTime [[ min:0, max:1000, init: 400, step: 1 ]];
        float Feedback  [[ min:0, max:1, init:0.5, step: 0.01 ]];
        float WetLevel  [[ min:0, max:1, init:0.5, step: 0.01 ]];
    }

    event DelayTime(float delayMs)
    {
        let delaySamples = max(1, int(processor.frequency * (delayMs / 1000.0f)));
        readPos = wrap<bufferSize>(writePos - delaySamples);
    }

    event Feedback(float f) { feedback = f; }
    event WetLevel(float f) { wetLevel = f; }

    float feedback;
    float wetLevel;

    let bufferSize = 100000;
    float[bufferSize] buffer;
    wrap<bufferSize> readPos, writePos;

	external soul::audio_samples::Mono voice;

    void run()
    {
		float64 playPos;
		float64 addPos = voice.sampleRate / processor.frequency;

        loop
        {
			let dry = voice.frames.readLinearInterpolated(playPos);
            playPos += addPos;

			if (playPos >= voice.frames.size)
				addPos = 0;

			buffer[writePos] = dry + buffer[readPos] * feedback;
            out << dry + buffer[readPos] * wetLevel;

			++readPos;
			++writePos;

            advance();
        }
    }
}
```

```JavaScript
{
    "soulPatchV1":
    {
        "ID":               "net.aikelab.delay",
        "version":          "1.0",
        "name":             "Delay",
        "description":      "sample playback and delay fx",
        "category":         "Fx",
        "manufacturer":     "aikelab.net",
        "isInstrument":     false,

        "source":           "delay.soul",
		"externals":		{ "Delay::voice": "../voice.wav" }
    }
}
```

SOUL_PluginツールのGUIは以下のようになります。

[delay.png](delay.png)

# 感想

Jules Storerが設計しただけあって、モダンでセンスの良い言語という印象です。音の抽象化に独自性があるというより徹底的に現実指向で、現時点におけるオーディオ処理の要件や課題がよく理解していることが伝わってきます。信号処理に便利な構文や機能が多数用意されていて、サンプル単位の処理も比較的シンプルに書くことができます。オーディオエンジンやプラグインの組み込みスクリプトとしても使いやすそうです。

このところ勢いのあるROLIということもあり、今後は最重要のオーディオプログラミング言語になると思います。

