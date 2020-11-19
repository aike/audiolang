Extempore
===

# 概要

https://extemporelang.github.io/

サイバーフィジカルプログラミング用言語。
作者のAndrew Sorensenは、サイバーフィジカルフィードバックシステムという、プログラマーがエージェントとして実行中の計算プロセスを調整し物理的なフィードバックを得る人とコンピュータとの協調システムを提唱している(*1)。
平たく言うとライブコーディングだが、ライブコーディングを含むもっと広い概念。

Andrew Sorensenは、2005年にSchemeベースのMac用言語ソフトウェアImpromptuを開発。
2011年に再設計した言語Extemporeをマルチプラットフォーム用オープンソースソフトウェアとしてリリースした。

(*1) Andrew Sorensen and Henry Gardner. 2010. Programming with time: cyber-physical programming with impromptu. SIGPLAN Not. 45, 10 (October 2010), 822–834.

# 実装例

## セットアップ

Extemporeはそれなりにドキュメントが整っているわりに、細部が十分説明されていない印象があるので、VSCode用のセットアップ手順について説明しておきます。

まず、Extempore実行ファイルをダウンロードしてインストールします（例：C:\bin\extempore\）。PATHを通す必要はありません。  
https://github.com/digego/extempore/releases

Extemporeはローカルサーバとして起動し、エディタと通信してコンパイル、実行します。
そのためエディタも設定する必要があります。

VSCodeの Viewメニュー→Extensions からExtempore用の拡張機能をインストールします。

拡張機能にExtemporeサーバの場所を指定します。  
　Fileメニュ→Preferences→Settings  
　　Extensions→Extempore  
　　　Extempore: Sharedir という項目があるので、インストールディレクトリ（例：C:\bin\extempore\）を設定する

## 実行

Viewメニュー→Command Palette→Extempore:Startでサーバ起動

Viewメニュー→Command Palette→Extempore:Connectでサーバに接続

その後はCtrl+Enterを入力するたびにカーソル位置のソースがサーバに送信されコンパイル、実行されます。

何かおかしくなった場合は、Extempore:Startでサーバを再起動すると大抵直ります。


## Schemeとxtlang

Extemporeは、Lisp系のSchemeをベースとした言語です。Scheme言語としてかなりしっかり作られている印象です。
さらにxtlangという言語内DSLがあり、オーディオプログラミングは主にxtlangでおこないます。

どちらもS式で書かれているのでSchemeとxtlangは一見して同じように見えます。
defineで定義する関数や定数はSchemeで、bind-funcやbind-valで定義している関数や定数はxtlangです。
xtlangは型を明記するのがルールで、暗黙の型変換をおこないません。

bind-valで定義したxtlangの定数は、xtlangつまりbind-funcの内部でしか参照できない、という点に注意してください。
以下の例では、bind-valで定義したaはxtlangなのでトップレベルのprintlnでは参照できず、defineで定義したaが参照されています。
一方で、bind-funcの内部でprintfした場合はbind-valで定義した方のaが参照されています。

オーディオ関係の関数や定数はbind-func、bind-valで定義されているxtlangであることに留意してプログラミングする必要があります。

```Scheme
(bind-val a i8* "hello xtlang")

(println a) ;=> unbound variable

(define a "hello scheme")

(println a) ;=> "hello scheme"

(bind-func print-a
  (lambda ()
    (printf "%s\n" a)))

(print-a) ;=> "hello xtlang
```

## サイン波生成

bind-funcでDSPという入出力仕様を持つ関数dspを定義しています。
この関数をdsp:set!することで音が鳴ります。

ここで注意すべきなのは、dsp:set!は再代入が禁止されているということです。
つまり、sin440、sin880などの関数を定義しておいて、(dsp:set! sine440)とした後に(dp:set! sine880)のように差し替えることはできません。
音を差し替えたい場合は、(bind-func sine440 ～)で名前を変えずに関数の中身を差し替えます。
それを考えるとdsp:set!する関数名はsine440などではなく、今回のようにdspなどと汎用的な名前にしておくのが良いとわかります。

```Scheme
;; Sine function
;;   predefined global constants:
;;     TWOPIf: 2 * PI as float (6.28318530...)
;;     SR: sample rate as i64 (44100)
;;     SRf: sample rate as float (44100.0)
(bind-func dsp:DSP
  (lambda (in time chan data)
    (let ((freq 440.0) (gain 0.1))
      (* gain (sin (/ (* TWOPIf freq (i64tof (% time SR)))
                      SRf))))))

(dsp:set! dsp)

;; stop sound function
 (bind-func dsp:DSP 
   (lambda (in time chan data) 0.0))
```

## Delayエフェクト

ディレイエフェクトはaudio_dsp.xtmで定義されているdelay_cがそのまま使えます。
ただし、ディレイタイムをサンプル数で指定する必要があります。ステレオ2chの場合はさらに2倍の値になります。
(* (/ (* SR delaytime) 1000) 2)で、ミリ秒から2ch分のサンプル数に変換しています。

wavファイルは相対パスで指定するとExtemporeサーバからの相対パスになってしまうので、絶対パスで指定する方が良いです。

```Scheme
(sys:load "libs/core/audio_dsp.xtm")

(bind-func dsp:DSP
  (let ((ab (AudioBuffer "/tmp/voice.wav"))
        (delaytime 400)
        (delay (delay_c (* (/ (* SR delaytime) 1000) 2)))
        (wet 0.5)
        (feedback 0.5))
    (lambda (in time chan dat)
      (delay (AudioBuffer_read ab chan) wet feedback))))

(dsp:set! dsp)
```

# 感想

良い言語であることは間違いないですが、網羅的なドキュメントが不足している印象です。
exampleや標準ライブラリのソースコードを大量に読んで仕様を把握する必要があります。

サイバーフィジカルプログラミングの構想はまだよく理解できていません。
可能性は感じます。

