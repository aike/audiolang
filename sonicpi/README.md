Sonic Pi
===

# 概要

https://sonic-pi.net/

Ruby言語をベースに音楽用機能と実行環境一体型IDEを含めたライブコーディング用言語環境。
サウンドエンジンはSuperColliderを使用する。
RaspberryPiでも動く。

ケンブリッジ大コンピュータ研究所のSam Aaron。

# 特徴

# 感想

SuperColliderやTidalCyclesに比べると、言語使用が音楽家にも理解しやすい。
実行環境が良くできている。
本来の言語仕様にシームレスに機能を追加しやすい、
一見わかりやすく高度なこともできる、といったRuby言語の利点を生かしている。


# 実装

```sine.rb
use_synth :sine
play 69, attack: 0, attack_level: 1, decay: 0, sustain_level: 1, sustain: 2, release: 0

```


カレントフォルダがSonic Pi実行ファイルの場所になるので、ファイル操作は絶対パス指定が必要という点はちょっと注意が必要。

```
datapath = "/tmp/"

file = datapath + "voice.wav"
sampleTime = sample_duration(file)
delayTime = 0.4
attenuate = 0.5
sample file
(sampleTime/delayTime).times do
  sleep delayTime
  sample file, amp: attenuate
  attenuate *= attenuate
end

```



