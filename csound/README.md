Csound
===

# 概要

https://csound.com/

サウンドおよび音楽コンピューティングシステム。ライセンスはLGPL。
宣言的。

1985年、MITメディアラボの創設メンバーでもあるBarry VercoeがMUSIC-NシリーズのMUSIC 11をベースに開発。

MUSIC-Nとは、1957年ベル研究所でMax Mathewsにより開発されたMUSICおよびその後継バージョン(MUSIC II、MUSIC III、……）。MUSIC-Nのオーディオレートと制御レートの考え方や、単機能のユニットジェネレーター(UGen)を組み合わせるプログラミングは、その後のオーディオプログラミング言語の多くに影響を与えている。

# セットアップ

Csoundは、古い言語ながら現代的なOSやモバイルやウェブにも対応しています。Windowsの場合、公式サイトからインストーラをダウンロードして実行するだけでパス設定も含めてセットアップが完了します。他の開発者による統合環境もいくつかありますが、今回は公式のコマンドラインコンパイラだけを使用しました。

> > csound foo.csd

で実行します。Csoundコンパイラには多くのオプションが用意されており適切に指定する必要がありますが、ソースコードのCsOptionsセクションにオプションを記述することで、コマンドラインでは何も指定しないようにすることが多いようです。


# 解説

Csoundの構文は単一ではなく、複数の構文がXMLのようなタグでセクション分けされて混在しているのが特徴です。かつてはそれぞれ別のソースファイルとしていたものを、現在では利便性を考慮してひとつのソースにまとめるようになった経緯があるようです。

## CsOptionsセクション
Csoundコンパイラのコマンドラインオプションを指定します。よく使用するオプションとしては以下のようなものがあります。

* -odac DACへ出力、つまりスピーカー出力です
* -o foo.wav ファイルへ出力します
* -iadc ADCから入力、つまりマイク入力です

## CsInstrumentsセクション

CsInstrumentsセクションの前半ではサンプルレートやチャンネル数を指定します。

後半はインストゥルメンツの定義をします。instr～endinで囲まれたブロック内では、ユーザー定義変数や四則演算など一般的なプログラミングが可能で、オーディオ処理はここに記述します。

変数名にはルールがあります。aから始まる変数はサンプルレートで変化するオーディオ変数、kから始まる変数はコントロールレートで変化するコントロール変数、iから始まる変数は初期化時以降変化しない初期化変数です。

また、p1～pnはCsScoreセクションでインストゥルメントを使用するときの引数です。1～3はp1:インストゥルメント番号、p2:開始時刻、p3:終了時刻と決められています。p4以降は自由に使用できますが、p4:周波数、p5:音量、とすることが慣習的に多いようです。

CsInstrumentsセクションのことをオーケストラと呼ぶこともあります。

## CsScoreセクション

CsInstrumentsセクションで定義したインストゥルメンツを指定したタイミングで鳴らすための定義です。


# 実装例

## サイン波生成

CsInstrumentsセクションのsrはサンプルレートです。コントロールレートを表すkr指定は省略しています。公式ドキュメントでもksmpsからksを自動計算させる書き方が推奨されています。nchnlsでチャンネル数を指定します。今回のように1chと指定してステレオ環境で実行した場合、音は片チャンネルではなくセンターから聞こえるように再生されます。

instr 1で楽器１をプログラミングします。  
1行目では、p4、p5の引数で渡された周波数と音量パラメータをoscilに与えてサイン波を生成し、aSigに出力しています。  
2行目では、aSigの内容をoutsに渡して最終出力としています。  
oscilやoutsは単機能の信号処理をおこなうユニットジェネレーター(UGen)で、Csoundではオペコード(Opecode)と呼ばれています。オペコードは大量の種類が用意されているほか( https://csound.com/docs/manual/PartReference.html )、自分であらたに定義することもできます。

CsScoreセクションはシーケンサーです。  
「i 1」とすると楽器１の指定です。続く引数は開始時刻と終了時刻、ここでは0秒から10秒の間鳴らすようにしています。440と0.3は楽器１に渡すパラメータで、今回は周波数と音量を渡すようにしています。

CsScoreセクションでは、「t 0 120」のようにしてBPMを指定することもできます。その場合開始時刻と終了時刻はビート単位になります。

最終行のeはスコアの終了を意味します。

```Csound
<CsoundSynthesizer>

<CsOptions>            ; set play options
  -odac                ; output sound to DAC
</CsOptions>

<CsInstruments>        ; set sound parameters
sr     = 44100         ; sample rate
ksmps  = 32            ; samples per control period (ksmps = sr / kr)
nchnls = 1             ; number of channels
0dbfs  = 1             ; 0 dBfs

; define instrument 1
instr 1
 aSig oscil p5, p4     ; use oscillator with p5(amplitude) and p4(frequency)
 outs aSig             ; output to device
endin
</CsInstruments>

<CsScore>              ; set play event parameters
; inst_number start_time(sec) end_time(sec) p4=frequency p5=amplitude
i 1 0 10 440 0.3
e
</CsScore>

</CsoundSynthesizer>
```

## Delayエフェクト

前半はサイン波生成と同じです。オーディオファイルを読むのにdiskin2を使っています。delayr、delaywでディレイバッファへの読み書きをおこないます。信号の合成は+、音量調整は*でシンプルに書くことができます。

今回はCsScoreセクションから渡される引数はありません。

```Csound
<CsoundSynthesizer>

<CsOptions>            ; set play options
  -odac                ; output sound to DAC
</CsOptions>

<CsInstruments>        ; set sound parameters
sr     = 44100         ; sample rate
ksmps  = 32            ; samples per control period (ksmps = sr / kr)
nchnls = 1             ; number of channels
0dbfs  = 1             ; 0 dBfs

; define instrument 1
instr 1
iDelayTime = 0.4
iFeedback  = 0.5
iWetLevel  = 0.5

aSig    diskin2 "../voice.wav"        ; load wav file
aBufOut delayr  iDelayTime            ; read from delay buffer
delayw  aSig + (aBufOut * iFeedback)  ; write to delay buffer
out     aSig + (aBufOut * iWetLevel)  ; output signal
endin
</CsInstruments>

<CsScore>              ; set play event parameters
; inst_number start_time(sec) end_time(sec) 
i 1 0 10
e
</CsScore>

</CsoundSynthesizer>
```


# 感想

古さは否めない。言語と定義ファイルの中間的なソースコードになります。
そのわりにinstrブロックの内容は洗練されていて書きやすい。
オペコードの蓄積も膨大で、何かひとつの機能でも似たようなオペコードがいくつも存在し、戸惑うことも多いです。
ドキュメントは、リファレンスも実装例も充実しているため、調べれば必要な情報は出てきます。

