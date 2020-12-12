Extempore
===

# 概要

https://extemporelang.github.io/

サイバーフィジカルプログラミング用言語。作者のAndrew Sorensenは、サイバーフィジカルフィードバックシステムという、プログラマーがエージェントとして実行中の計算プロセスに関与して物理的なフィードバックを得るコンピュータと人との協調システムを提唱している(*1)。平たく言うとライブコーディングだが、ライブコーディングを含むもっと広い概念。

Andrew Sorensenは、2005年にSchemeベースのMac用プログラミング言語Impromptuを開発。2011年に再設計した言語Extemporeをマルチプラットフォーム用オープンソースソフトウェアとしてリリースした。

(*1) Andrew Sorensen and Henry Gardner. 2010. Programming with time: cyber-physical programming with impromptu. SIGPLAN Not. 45, 10 (October 2010), 822–834.

# 実装例

## セットアップ

Extemporeはそれなりにドキュメントが整っているわりに、細部が十分説明されていない印象があるので、VSCode用のセットアップ手順について説明しておきます。

まず、Extempore実行ファイルをダウンロードしてインストールします（例：C:\bin\extempore\）。PATHを通す必要はありません。  
https://github.com/digego/extempore/releases

Extemporeはローカルサーバとして起動し、エディタと通信してコンパイル、実行します。そのためエディタも設定する必要があります。

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

Extemporeは、Lisp系のSchemeをベースとした言語です。Scheme処理系としてみてもかなりしっかり作られている印象です。さらにxtlangという高速で低レベル処理に適した言語内DSLがあり、オーディオプログラミングは主にxtlangでおこないます。

どちらもS式で書かれているのでSchemeとxtlangは一見して同じように見えます。defineで定義する関数や定数はSchemeで、bind-funcやbind-valで定義している関数や定数はxtlangです。xtlangは型を明記するのがルールで、暗黙の型変換をおこないません。

bind-valで定義したxtlangの定数は、xtlangつまりbind-funcの内部でしか参照できない、という点に注意してください。  
以下の例では、Schemeとxtlangでそれぞれaという同名の定数を定義しています。bind-valで定義したaはxtlangなのでトップレベルのprintlnでは参照できず、defineで定義したSchemeのaが参照されています。一方で、bind-funcの内部でprintfした場合はbind-valで定義したxtlangのaが参照されています。

```Scheme
(bind-val a i8* "hello xtlang")

(println a) ;=> unbound variable: a

(define a "hello scheme")

(println a) ;=> "hello scheme"

(bind-func print-a
  (lambda ()
    (printf "%s\n" a)))

(print-a) ;=> "hello xtlang
```

オーディオ関係の関数や定数はbind-func、bind-valで定義されているxtlangであることに留意してプログラミングする必要があります。

## サイン波生成

bind-funcでDSPという入出力仕様を持つ関数dspを定義しています。この関数をdsp:set!することで音が鳴ります。

ここで注意すべきなのは、dsp:set!は再代入が禁止されているということです。つまり、sin440、sin880などの関数を定義しておいて、(dsp:set! sine440)とした後に(dp:set! sine880)のように差し替えることはできません。音を差し替えたい場合はdsp:set!してある関数の中身をbind-funcで再定義します。そのためdsp:set!する関数名はsine440などではなく、今回のようにdspのような汎用的な名前にしておくのが良さそうです。

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

ディレイエフェクトはaudio_dsp.xtmで定義されているdelay_cがそのまま使えます。ただし、ディレイタイムをサンプル数で指定する必要があります。ステレオ2chの場合はさらに2倍の値になります。(* (/ (* SR delaytime) 1000) 2)で、ミリ秒から2ch分のサンプル数に変換しています。

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

Schemeの安定感やxtlangの高速性、また多くの機能がxtlangで実装されていることからもわかる表現力など、高度な設計スキル、実装スキルにもとづいて作られた言語であることは間違いように思います。今回は目的にあわず説明できませんでしたが、メロディーやループパターンを表現するためのPattern Languageも用意されていて、それもまたひとつのDSLとして興味深いものがあります。

一方でドキュメントが不足している印象は否めません。コンセプトの説明や簡単なチュートリアルは充実しているものの、xtlangの基本的な仕様や構文についての体系的な説明はほとんどないですし、ライブラリの網羅的なドキュメントもありません。Extemporeを使いこなすには、標準ライブラリやサンプルプログラムのソースコードを大量に読んで仕様を把握する必要があります。

サイバーフィジカルプログラミング構想のような大局的な視点は他の言語にはないもので、ライブコーディングの先にある動的なプログラミングの可能性に期待が持てそうな印象はあります。

