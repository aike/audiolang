Scilab
===

# 概要

https://www.scilab.org/

数値解析、データ視覚化、アルゴリズム開発用プログラミング環境。GPLライセンスのオープンソース。MATLABに非常に近い構文を持つが完全な互換性はない。また、MATLABのSimulinkに似たビジュアルモデリングツールXcosも含まれる。ただし、Xcosはリアルタイム音声出力機能は持たない。サウンドファイルの入出力は可能。

1990年代にINRIA(フランス国立情報学自動制御研究所)とENPC(フランス国立土木学校)により開発。2010年Scilab Enterprises社設立、2017年Scilab Enterprises社はESI Groupに買収されたため、現在はESI Groupにより管理されている。

# 実装例

## サイン波生成

sound()の代わりにplaysnd()で音を鳴らす以外MATLABと同じです。

```Scilab
Fs = 44100;
duration = 1;
frequency = 440;
gain = 0.3;
phase = 0:1/Fs:duration;
arr = gain * sin(2 * %pi * frequency * phase);
playsnd(arr, Fs)
```

## Delayエフェクト

こちらもMATLABとほぼ同じです。相違は以下の3点です。

* ファイル読み込みはaudioread()ではなくwavread()
* 配列の結合をcat()でおこなう
* 音声出力はsound()ではなくplaysnd()


```Scilab
[y, Fs] = wavread('../voice.wav');

delayTime = 0.4;
feedback = 4;
wetLevel = 0.5;
attenuate = 0.5;

delaySample = round(delayTime * Fs); 
wet = attenuate * cat(2, zeros(1, delaySample), y);
for i = 2 : feedback
    currentWet = (attenuate^i) * cat(2, zeros(1, delaySample), wet);
    wet = cat(2, wet, zeros(1, delaySample));
    wet = wet + currentWet;
end
y = cat(2, y, zeros(1, delaySample * feedback));
y = y + wet * wetLevel;

playsnd(y,Fs);
```

# 感想

ScilabもGNU Octave同様オープンソースのMATLAB代替として十分な能力を持っている印象です。この分野の言語は計算結果をグラフ出力することが多いため、グラフィックキャンバスを持ったIDE上で実行することになります。ScilabのIDEも十分に洗練されていて使いやすいです。拡張用のToolboxもMATLABほどではありませんが用意されています。ここまで高機能なのでXcosでリアルタイム音声信号処理ができないのは少し残念に感じました。
