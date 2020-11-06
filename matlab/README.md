MATLAB
===

# 概要

https://jp.mathworks.com/products/matlab.html

データ解析、アルゴリズム開発、モデル作成用言語。
有償。毎年更新されるので実質サブスクリプション。
各種Toolboxアドオンが有償で用意されている。
Simulinkというグラフィカルモデリングツール（ビジュアル言語）もアドオンとして用意されている。

開発はMathWorks


GNU Octave( https://www.gnu.org/software/octave/index )は、MATLABの基本言語部分のフリーソフトウェア版クローン。Simulink、アドオンは含まれない。
Scilab( https://www.scilab.org/ )は、MATLABに似たシンタックスを持つ言語だが互換性はない。

# 実装例

## サイン波生成

MATLABの場合、一旦配列に信号を用意して音を鳴らします。

```matlab
Fs = 44100;
duration = 1;
frequency = 440;
gain = 0.3;
phase = 0:1/Fs:duration;
arr = gain * sin(2 * pi * frequency * phase);
sound(arr, Fs)
```
※GNU Octaveでもそのまま実行できます

## Delayエフェクト

ファイルから配列に信号を読み込んで、MATLABの得意な配列演算でエフェクトをかけた後に再生します。
audioread関数は、以前はwavreadという名前でした。古い情報にあたるときや古いバージョンのMATLAB/Octaveを使う場合は注意してください。

```matlab
[y, Fs] = audioread('../voice.wav');

delayTime = 0.4;
feedback = 4;
wetLevel = 0.5;
attenuate = 0.5;

delaySample = round(delayTime * Fs); 
wet = attenuate * [zeros(delaySample, 1); y];
for i = 2 : feedback
    currentWet = power(attenuate, i) * [zeros(delaySample, 1); wet];
    wet = [wet; zeros(delaySample, 1)];
    wet = wet + currentWet;
end
y = [y; zeros(delaySample * feedback, 1)];
y = y + wet * wetLevel;

sound(y,Fs);
```
※GNU Octaveでもそのまま実行できます  

# Simulinkによる実装


# 感想

MATLABは、歴史が長い分、最近のモダンな言語に慣れていると文法の古さや短い変数名を使用する文化に戸惑うこともあります。
それでも現在でも科学技術計算におけるデファクトスタンダードのひとつであり、使えるようになって損はありません。

最近では、毎年更新されるサブスクリプション的な購入コストの負担を嫌ってJuliaやPythonに移行する人も増えてきた印象があります。
ここで、MATLABの買い方についても少し触れておきます。

MATLABは、本体とアドオンという形式で販売され、それぞれ毎年更新されます。
個人向けや学生向けは比較的買いやすい値段です。
更新しなくても古いバージョンは使えるし、言語仕様自体が大きく変更されることはないと予想できるので、一度買ってそれを使い続けるという判断もできます。（この辺はWavesのプラグインと似てますね）

ただし、たとえば2019年版本体で2020年版アドオンを読み込むことはできません。
また、新版が出てから旧版対応のアドオンを購入することもできません。
そのため、まず本体を買って後で少しずつアドオンを買い足すようなことはお勧めしません。
ほしいものを一気に買って、必要であれば年次更新するのがおすすめです。

オーディオ処理でおすすめのアドオンは以下のとおりです。
・Simulink　（ビジュアルプログラミング・モデリング）
・Audio Toolbox　（VST、ASIO、MIDIデバイス、機械学習）
・Signal Processing Toolbox　（信号解析、フィルター設計）
・DSP System Toolbox　（フィルター設計、ストリーミング処理）

今回の .m ファイルを実行するくらいであればアドオンは不要です。
今回のSimulinkファイルを実行するには、SimulinkとSignal Processing Toolboxが必要です。

どういった処理にどのアドオンが必要かはわかりづらいですが、公式Webに多くの情報が公開されているので根気よく読んでいけば判断することは可能です。

