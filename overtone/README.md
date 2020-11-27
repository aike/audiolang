Overtone
===

# 概要

https://overtone.github.io/

新しい音楽のアイデアを探求するために設計されたオープンソースのオーディオプログラミング環境。
OvertoneはLisp系のClojure言語のライブラリとして実装されている。オーディオエンジンにSuperColliderを使用する。


開発はSonic Piと同じくケンブリッジ大コンピュータ研究所のSam Aaron。
Sonic Piが主に教育目的の言語であるのに対し、Overtoneはプロのアーティスト/プログラマーがアートのコンテキストで使用するように設計されている。(*1)

(*1) Samuel Aaron and Alan F. Blackwell. 2013. From sonic Pi to overtone: creative musical experiences with domain-specific and functional languages. In Proceedings of the first ACM SIGPLAN workshop on Functional art, music, modeling & design (FARM '13). Association for Computing Machinery, New York, NY, USA, 35–46.


# 実装例

## セットアップ

github.comのREADME.mdとgithub.ioのドキュメントで記述が多少異なりますが、ここではREADME.mdの手順を参考にしました。  
https://github.com/overtone/overtone  
https://overtone.github.io/docs.html  

Overtoneは、独立した言語ではなくClojure言語のライブラリとして提供されます。そのためまずはClojureをインストールします。ClojureのWindows版はまだアルファ版ということなのでmacOSにインストールしました( https://clojure.org/guides/getting_started )。  
※ClojureはJRE上で動くので環境をうまく作ることができればWindowsでも問題なく動くとは思います。

> $ brew install clojure/tools/clojure

ライブラリの依存関係を記述するdeps.ednファイルを作成してカレントディレクトリに置きます。

> $ echo '{:deps {overtone/overtone {:mvn/version "0.10.6"}}}' > deps.edn

## Overtoneの起動方法

ClojureのREPLを起動(clojureコマンドあるいは略称のcljコマンドのどちらを使っても可)。

> $ clj

Overtoneライブラリ読み込み。

> user=> (use 'overtone.live)

終了はCtrl+Dです。

Overtoneはライブコーディングもひとつの目的としており、エディターと接続するのが正しい使い方だとは思いますが、今回はClojureのREPLをそのまま使用して確認しました。またClojureの開発環境を調べると、プロジェクト管理ツールLeiningenを使う事例が多く出てきますが、Clojure 1.9以降は特に必須というわけでもなさそうです。

## サイン波生成

defsynthでシンセサイザーを定義します。sin-oscでサイン波を生成、ゲインを0.5倍し、pan2でステレオ2chにして出力しています。

```Clojure
(defsynth play-sine [] (out 0 (pan2 (* 0.5 (sin-osc 440)))))
```

インストゥルメンツという特殊なシンセサイザーを定義することもできます。
インストゥルメンツはチャンネル数に制限がある一方、出力が自動で設定されたり、エフェクトチェーンを設定しやすかったりと便利になっています。

```Clojure
(definst play-sine [] (* 0.5 (sin-osc 440)))
```

いずれも以下のようにして音を鳴らします。

```Clojure
(play-sine)
```

stopコマンドですべての音を止めます。

```Clojure
(stop)
```

個別に音を止めるときはkillを使います。

```Clojure
(kill play-sine)
```

音を鳴らして一定時間経ったら自動的に止めるにはThread/sleepを使用して時間待ちをします。次のようなプログラムにすると、

> $ clj filename.clj

のようにしてOSのコマンドラインからも実行できます。コマンドラインから実行した場合、終了はCtrl+Cです。

```Clojure
(use 'overtone.live)

(definst play-sine [] (* 0.5 (sin-osc 440)))

(defn play-1sec []
  (play-sine)
  (Thread/sleep 1000)
  (kill play-sine))

(play-1sec)
```

このような一定時間鳴らす処理は多用されるので、あらかじめdemo関数というものが用意されています。demo関数はシンセサイザー関数を定義しなくても引数で指定した処理をその場でシンセサイザーにして一定時間鳴らす関数です。時間を指定しない場合は\*demo-time\*定数で定義されている2000msecが使用されます。

```Clojure
(demo (pan2 (* 0.5 (sin-osc 440))))
```

demo関数の中を見てみると、以下のようにhold関数を使って時間待ち処理を記述しています。鳴らし終わると:done FREEですぐにシンセサイザーを解放しています。

```Clojure
((synth "audition-synth" 
    (out 0 (pan2
        (hold (* 0.5 (sin-osc 440)) 2.0 :done FREE)))))
```

## Delayエフェクト

wavファイルを扱う前にバッファの設定が必要になります。\~/.overtone/config.cljに以下の記述を追加します。

```
:sc-args {:max-buffers 1024}
```

overtoneのREPL上で以下のコマンドを実行すると上記の記述が\~/.overtone/config.cljに追加されるので、こちらの方が簡単かもしれません。

```Clojure
(swap! live-config assoc-in [:sc-args :max-buffers] 1024)
```

wavファイルはload-sample関数で読み込みます。
definstの中でlocal-inとlocal-outを使ってフィードバックループを実現しています。

```Clojure
(use 'overtone.live)

;; buffer player with delay fx
(definst play-with-delay [buf 0 delay-time 0.4 feedback 0.5 wet-level 0.5]
  (let [dry (play-buf 1 buf)
        fb-in (local-in 1)
        wet (delay-n fb-in 1.0 delay-time)
        fb-out (local-out (* feedback (+ dry wet)))
        mix (+ dry (* wet-level wet))]
    mix))

;; load audio file into buffer
(def voice-buf (load-sample "../voice.wav"))

;; play
(play-with-delay voice-buf)
```

インストゥルメンツのエフェクトチェーンを使ったバージョンは次のようになります。
バッファをそのまま再生するvoiceインストゥルメンツを作成し、それにinst-fx!でエフェクトを付加します。inst-fx!を複数回実行することで複数のエフェクトをかけることも可能です。エフェクトが付加されたら、(voice)とするだけでエフェクトのかかった音が再生されるようになります。


```Clojure
(use 'overtone.live)

;; delay fx for instruments
(defsynth fx-delay [bus 0 delay-time 0.4 feedback 0.5 wet-level 0.5]
  (let [dry (in bus)
        fb-in (local-in 1)
        wet (delay-n fb-in 1.0 delay-time)
        fb-out (local-out (* feedback (+ dry wet)))
        wet-out (* wet-level wet)]
    (out 0 (pan2 wet-out))))

;; load audio file into buffer
(def voice-buf (load-sample "../voice.wav"))

;; define buffer player instruments
(definst voice [] (play-buf 1 voice-buf))

;; add fx to buffer player
(inst-fx! voice fx-delay)

;; play
(voice)
```

付加したエフェクトをクリアするにはclear-fxを使います。

```Clojure
 (clear-fx voice)
```

# 感想

Sonic PiのSam Aaronが設計しただけあって、裏で動くSuperColliderをインストール時も実行時も意識せずにすむのは使いやすいです。

ただ、Clojure言語そのものやOvertoneはプロ向けという印象でSonic Piほどの敷居の低さはありません。
Lisp系言語の拡張性を存分に使って独自の音楽言語を構築しています。
ドキュメントがそれなりに整備されているのと、(odoc 関数名)で簡単なヘルプは出るようになっているので手がかりはありますが、それでもライブラリやサンプルのソースコードを読んで仕様を把握することは必須です。また、ある程度SuperColliderの知識があった方がdefsynthやugenの概念に迷わないと思います。

細かいことですが、Overtone(倍音)という名前が一般名詞であることも学習しづらい要因のひとつです。「overtone music」「overtone language」などと検索してもなかなか実装例を見つけることができません。「overtone audio programming」だと少し出てきます。言語やライブラリ設計の良さは十分感じますし、初登場から10年近く経っており蓄積も十分あるはずなので、もう少し学びやすければより多くの人に使われるのではないかと感じました。

今回はライブコーディング関係の機能はほとんど使うことがありませんでした。このあたりの機能も充実しているようなので今後また調べてみたいと思います。

