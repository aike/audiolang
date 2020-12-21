Sonic Pi
===

# 概要

https://sonic-pi.net/

Ruby言語をベースに音楽用機能と実行環境一体型IDEを含めたライブコーディング用言語環境。サウンドエンジンはSuperColliderを使用する。Raspberry Piでも動く。

開発はOvertoneと同じくケンブリッジ大コンピュータ研究所のSam Aaron。初出は2012年。音楽がプログラミング教育に適したテーマであると考えたRaspberry Pi Foundationからの依頼により、プログラミングやその他コンピュータ技術の経験がない12歳の学生にも使えるように設計された。(*1)

(*1) Samuel Aaron and Alan F. Blackwell. 2013. From sonic Pi to overtone: creative musical experiences with domain-specific and functional languages. In Proceedings of the first ACM SIGPLAN workshop on Functional art, music, modeling & design (FARM '13). Association for Computing Machinery, New York, NY, USA, 35–46.

# 実装例

## サイン波生成

Sonic PiはRubyの言語内DSLなので構文的にはRubyのものがすべて使えます。Sonic Pi 3.2.2では最新に近いRuby2.7.1がベースとなっており、Rubyのバージョンアップにもこまめに追従しているようです。とはいえSonic Piによる音楽生成には複雑なロジックや最新機能が必要になることはあまりないと思います。  
音程は周波数による指定ではなくMIDIノートナンバーで69(=A440)と指定します。デフォルトでは減衰音のエンベロープになっているので持続音的な音にしてみました。

```Ruby
use_synth :sine
play 69, amp: 0.5, attack: 0, attack_level: 1, decay: 0, sustain_level: 1, sustain: 2, release: 0
```

## Delayエフェクト

Sonic Piは、Dir.pwdなどのカレントフォルダ取得関数がシステムフォルダを返しソースコードのフォルダを取得する方法がなさそうなので、ファイル操作は絶対パス指定でおこなう必要があります。

with_fxブロックで囲むとその内側で鳴らす音すべてにエフェクトがかかる、という独特の文法です。Echoエフェクトのディレイタイム指定phaseは1拍の長さに対する割合で指定します。0.4とした場合、BPM60なら0.4秒ですがBPM120なら0.2秒になります。bt()関数で1拍の秒数を取得できるので下の例ではミリ秒から変換して使用しています。

```Ruby
datapath = "/tmp/"
file = datapath + "voice.wav"

delayTime = 400 # msec
feedback = 0.5
wetLevel = 0.5

use_bpm 120
delayPerBeat = delayTime / 1000.0 / bt(1)

with_fx :echo, phase: delayPerBeat, mix: wetLevel, decay: feedback * 10 do
  sample file
end
```


# 感想

言語仕様は、SuperColliderなどに比べると本業プログラマーではないアーティストにも理解しやすいわかりやすさがあります。Ruby言語の利点である、シームレスに言語を拡張しやすい、一見わかりやすく高度なこともできる、といった特徴を生かしている印象です。誰にでも扱いやすい平易な言語で本格的な使用にも耐えるものを作ることはなかなか難しく、そういう点でSonic Piは独自の地位を築いているように思います。

Rubyのライブラリという形ではなく実行環境一体型にして簡単インストール、実行画面もシンプル、チュートリアルや言語マニュアルなども実行画面を切り替えずにすべて見られるなど、言語仕様だけでなく全体にわたって注意深く使いやすさが設計されています。Raspberry Piとの関わりからもわかるように、プログラミング教育をひとつの目的としており、ハードルを下げるための思想が一貫しているように感じます。

ただし、Sonic Piの目的はあくまでライブコーディングであり、サンプルレベルの音声信号の生成や加工といった目的には向いていません。用意されている音源をlive_loopを使ってループ再生しながら、パラメータやプログラムを次々と書き換えて音楽を変化させていくのが本来の使い方だと思います。

