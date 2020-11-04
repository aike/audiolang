vvvv
===

# 概要

https://vvvv.org/

プロトタイピングと開発のためのビジュアル・テキストハイブリッド言語。
VJパフォーマンスなどにも使われる。
Windows専用。商用利用は有償。

開発はvvvv group。


# 実装例

vvvvでオーディオプログラミングするには、いろいろと注意点があります。
オーディオライブラリにはDShow9/Bass/VAudioなどの系列があり、お互いに混ぜて使用することはできません。
https://betadocs.vvvv.org/topics/audio/index.html

## DShow9ライブラリの場合

デフォルトでインストールされています。32bit/64bitどちらでも使えます。提供されているノードが非常に少ないです。

音声信号のエフェクトは基本的にできないので、複数のFileStreamに時間をずらしてbangを送ることでディレイ効果を実現してみました。

![delay](images/dshow9_delay.png)


## Bassライブラリの場合

addonpack( https://vvvv.org/downloads#addonpack )をインストールすることで使えるようになります。
64bit版ライブラリが提供されておらず、32bit版vvvvでのみ使えます。( https://vvvv.org/documentation/missing-in-64bit-builds )
各種エフェクトなどのノードが豊富です。
32bit VST2プラグインが使えますが、ロードできなかったり正常に音が出ない相性の悪いプラグインも多いです。

echoノードを使用した例。
フィードバックは1回のみ。Wetのみ取り出すことは不可。
また、vvvvのオーディオグラフはループ構造を許可していないらしく、接続を工夫してフィードバックを作り出すことはできないようです。
ディレイタイムの単位も不明です。20000にすると400msecくらいになります。上限値下限値も説明がありませんが、調べたところ1200～30000のようです。
AudioOutはDShow9と同名ですが、BassライブラリのAudioOutは接続するinletの場所が異なることに注意してください。

![bass_delay](images/bass_delay.png)

BassライブラリはVST2プラグインが使えるのでエフェクトは外部プラグインにまかせる方法もあります。
（vvvvインストールフォルダ）\lib\nodes\vst\ にVST2 32bitプラグインファイルを置いておくと、プラグインの名前のノードが作成できるようになります。
今回使用したディレイプラグインもDAWで使用したときと音が異なったり、パラメータ設定が音にうまく反映されなかったり相性の悪い部分がありました。

![bass_delay_vst](images/bass_delay_vst.png)

インスペクターの赤丸の位置をチェックするとinletが追加されてパラメータを数値ノードから設定できるようになります。

![bass_delay_vst](images/bass_delay_vst.png)


## VAudioライブラリの場合

VVVV.Audio pack( https://vvvv.org/contribution/vvvv.audio-pack-alpha )をインストールすることで使えるようになります。
32bit/64bitどちらでも使えます。
ASIO専用なのでオーディオインタフェースハードウェアを使っていない場合、ASIO4ALLのインストールが別途必要になります。
ノードは少ないですが、32bit/64bitVST2プラグインが安定して使用できます。

VAudioライブラリの場合、ファイル名で指定するのでプラグインはどこに置いてあってもかまいません。vvvvが64bitの場合プラグインも64bit VST2を指定します。

![bass_vst_inlet](images/bass_vst_inlet.png)


# 感想

メニューの出し方やマウスクリックの挙動が一般のアプリと異なっているため、最初は戸惑いますがすぐに慣れます。
MaxやPureDataのような編集モード／実行モードの切り替えがなく、マウスの左右ボタンそれらを表しているのは高速にプログラミングできて快適です。

また、bangボタンやtoggleボタンのようなMaxやPureDataでおなじみのボタンも、微妙に挙動が異なるので注意が必要です。
toggleの下にbangを接続するとbangはtoggleのように1を送り続け、bangの下にtoggleを接続するとtoggleはbangのように一瞬だけ1を送るようになります。

公式ドキュメントに、「ぶっちゃけvvvvはオーディオ処理にフォーカスしていないよ」とあるとおり( https://betadocs.vvvv.org/topics/audio/index.html )、オーディオ関係の機能はいろいろと穴があり、複雑なオーディオプログラミングには向いていない印象です。

一方で映像＋音のパフォーマンス用に使う場合は、VAudio+VSTプラグインが安定していて利用しやすいと思います。

