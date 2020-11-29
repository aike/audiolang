Bidule
===

# 概要

https://www.plogue.com/products/bidule.html

インタラクティブなコンピューター音楽とマルチメディアを作成するための商用ソフトウェアアプリケーション。MaxやPure Dataのようにノードを接続してプログラミングするビジュアル言語。MIDI、OSCによる通信、ReWireデバイスとしてDAWとの連携、VST2、VST3、AUプラグインのホストといった機能を持っている。また、VSTプラグインとして機能するプラグインバージョンも用意されている。

開発はPlogue Arts and Technology(カナダ)

# 実装例

## サイン波生成

OscillatorノードにConstantノードでパラメータを与えてOutputに接続すると音が鳴ります。

[sine](sine.png)

## Delayエフェクト

Audio File Playerノードでwavファイルを再生することができます。Stereo DelayはWet GainがないのでDry GainをゼロにしてミキサーでDry/Wetのバランスを調整しやすいようにしました。

[delay](delay.png)


# 感想

商用製品だけあって、ReWire、VST、AUなどのサポートが充実しています。現在も頻繁にバージョンアップされており、最新のOSにも対応しています。2012年頃からあるソフトウェアのためユーザーは比較的多いようで、ユーザーフォーラムのコミュニケーションも盛んにおこなわれています。

ノード型ビジュアル言語としてはさほど独自性はなく、Max、REAKTOR、Pure Dataに対する優位性があまり感じられませんでした。

販売価格は日本円で1万円程度。バージョンアップ時に期間限定で試用版も公開されます。そのため時期によっては試用できないことがあります。

