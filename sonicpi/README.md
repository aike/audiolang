Sonic Pi
===

# 概要

https://sonic-pi.net/

Ruby言語をベースに音楽用機能と実行環境一体型IDEを含めたライブコーディング用言語環境。
サウンドエンジンはSuperColliderを使用する。
RaspberryPiでも動く。

ケンブリッジ大コンピュータ研究所のSam Aaron。

# 実装例

## サイン波生成

```Ruby
use_synth :sine
play 69, attack: 0, attack_level: 1, decay: 0, sustain_level: 1, sustain: 2, release: 0

```

## Delayエフェクト

カレントフォルダがSonic Piアプリフォルダになるので、ファイル操作は絶対パス指定が必要という点はちょっと注意が必要です。

Echoエフェクトのディレイタイム指定phaseは1拍の長さに対する割合で指定します。0.4とした場合、BPM60なら0.4秒ですがBPM120なら0.2秒になります。

```Ruby
datapath = "/tmp/"
file = datapath + "voice.wav"

use_bpm 60

with_fx :echo, phase: 0.4, mix: 0.5, decay: 5 do
  sample file
end
```


# 感想

言語仕様は、SuperColliderなどに比べると本業プログラマーではない音楽家にも理解しやすいわかりやすさがあります。

Ruby言語の利点である、シームレスに言語を拡張しやすい、一見わかりやすく高度なこともできる、といった特徴を生かしている印象です。
プログラミング言語の技術やパラダイムに詳しい技術者が、誰にでも扱いやすい平易な言語を設計することは意外と少なく、そういう点でSonic Piは独自の位置を築いているように思います。
Rubyのライブラリという形ではなく実行環境一体型にして、インストールや画面操作もシンプルで迷わないようにしているあたり思想が一貫しているように感じます。

ただし、Sonic Piの目的はあくまでライブコーディングであり、サンプルレベルの音声信号の生成や加工といった目的には向いていません。

