Bidule
===

# 概要

https://www.plogue.com/products/bidule.html  
https://www.plogue.com/bidule/help/index.html

インタラクティブなコンピューター音楽とマルチメディアを作成するための商用ソフトウェアアプリケーション。MaxやPure Dataのようにノードを接続してプログラミングするビジュアル言語。MIDI、OSCによる通信、ReWireデバイスとしてDAWとの連携、VST2、VST3、AUプラグインのホストといった機能を持っている。また、VSTプラグインとして機能するプラグインバージョンも用意されている。

開発はPlogue Arts and Technology社(カナダ)

# 実装例

## サイン波生成

OscillatorノードにConstantノードでパラメータを与えてOutputに接続すると音が鳴ります。

![sine](sine.png)

## Delayエフェクト

Audio File Playerノードでwavファイルを再生することができます。Stereo DelayノードはWet GainがないのでDry GainをゼロにしてミキサーでDry/Wetのバランスを調整できるようにしました。

![delay](delay.png)


# 感想

商用製品だけあって、ReWire、VST、AUなどのサポートが充実しています。現在も頻繁にバージョンアップされており、最新のOSにも対応しています。2001年頃から継続的に開発されてきたソフトウェアであるためユーザー数は比較的多く、ユーザーフォーラムのコミュニケーションも盛んにおこなわれています。

シンプルでわかりやすい反面、ノード型ビジュアル言語としてはさほど独自性はなく、Max、REAKTORなどに対する優位性はさほど感じられませんでした。現在の状況ではあまり実感できませんが、開発当初Biduleのオーディオエンジンは高く評価されており、Garritan、Sibeliusといったメジャーな商用音源デベロッパーにライセンス供与されました。そしてそれがPlogue Arts and TechnologyとGarritanによるARIAエンジン開発につながります。

販売価格は日本円で1万円程度。バージョンアップ時に試用版も一定期間公開されます。期間限定のため時期によっては試用版をダウンロードできないことがあります。

