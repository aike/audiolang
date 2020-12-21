TidalCycles
===

# 概要

https://tidalcycles.org/
https://github.com/tidalcycles/Tidal/

ループパターンを生成するライブコーディング用言語。Haskellの言語内DSLとして実装されている。言語自体にはオーディオエンジンを持っておらず、SuperColliderおよびSuperDirtサンプラーを音源として使用する。

ロンドン大学ゴールドスミス・カレッジの大学院生Alex McLeanが2009年に開発。関数型言語による音楽パターン生成は博士論文としてまとめられている( https://slab.org/thesis/ )。

もともとTidalという名前であったが、2014年に同名の音楽ストリーミングサイトがサービスインしたためTidalCyclesに改名した。


# セットアップ

https://tidalcycles.org/index.php/Installation
TidalCyclesは、インストールに非常に手間がかかる状態が長く続いていました。現在はchocoインストーラを使うことで関連アプリケーション（Git、Haskell、Atom、SuperCollider、SuperDirt、DirtSamplesなど）をまとめてインストールできるようになっています。

Windowsの場合の手順は以下のようになります。

Windowsキー+Xでメニュー表示 → Windows Power Shell(管理者)を選択。以下のコマンドでchocoをインストールします。

```
> Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

続いてchocoを使用してTidalCyclesをインストール。

```
> choco install tidalcycles
```

Gitなどを既にインストール済みの環境も多いと思います。上記のchocoコマンドを実行すると、アプリケーションごとに以下のように問い合わせてきます。このとき、nを入力するとそのアプリケーションのインストールはスキップして次へ進みます。

```
git v2.29.2.3 [Approved]
git package files install completed. Performing other installation steps.
The package git.install wants to run 'chocolateyInstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[A]ll - yes to all/[N]o/[P]rint): N
```

スキップした場合、インストール処理の最後にFailuresとして表示されますが問題ありません。

このコマンドでインストールされる主なアプリを以下に示します。

| アプリ名 | 説明 |
----|---- 
|git|バージョン管理ツール|
|cabal|Haskellのパッケージマネージャ|
|ghc|Haskell言語|
|Atom|多機能テキストエディタ。TidalCyclesのユーザインタフェースとして使用する|
|SuperCollider|オーディオプログラミング言語およびオーディオエンジンサーバ|
|sc3plugins|SuperCollider用各種ユニットジェネレータプラグイン|
|SuperDirt|TidalCycles用サンプラー音源DirtのSuperCollider移植版。以前はDirtを使用していたが現在はSuperDirtが標準|
|DirtSamples|Dirt用のサンプリングファイル集|

# 起動

SuperColliderを起動します。

以下のコマンドを入力してCtrl+Enterを押します

```SuperCollider
SuperDirt.start
```

SuperColliderがインストール済みでchocoではスキップした場合、ここでエラーが出るかもしれません。SuperColliderやsc3pluginsを一旦削除してから再インストールするとバージョンの不整合が解消されます。

Atomエディタを起動し、以下の内容を入力、拡張子.tidalで保存します。この行にカーソルをあててCtrl+Enterを押すと、AtomのTidalCycles用拡張機能が自動的にHaskellプロセスを起動してSuperColliderと通信し、うまくいけばバスドラムの音が鳴ります。

```Haskell
d1 $ sound "bd bd bd bd"
```

しかしながら手元の環境ではSound.Tidal.Contextモジュールがないというエラーが出てうまく実行できませんでした。Cabal3.2の仕様変更により、必要なパッケージ情報を記述した環境ファイルが実行ディレクトリに必要になったようです。
https://stackoverflow.com/questions/61488500/cabal-install-tidal-ends-with-warning

本来であれば、~/.ghc/x86_64-mingw32-8.10.2/environments/default ファイルが参照されるべきなのですが、正常に参照できていないようにも見えます。

今回、HaskellはAtomエディタから実行するので、Atomのインストールディレクトリに環境ファイルを作って対処します。

```
> cd C:\Users\myname\AppData\Local\atom\

> cabal install --lib --package-env . tidal
```

上記コマンドを実行すると、以下のような名前で必要なHaskellパッケージを列挙した環境ファイルを作ります。

.ghc.environment.x86_64-mingw32-8.10.2

この状態であらためて実行するとエラーは出なくなります。


# 実装例

## サイン波生成

DirtSamplesにはsineというサンプリング音が用意されていますが、自由な音程を鳴らせるものではないのでSuperColliderでサイン波を鳴らすシンプルなシンセサイザーを用意します。SuperCollider上でSuperDirt.startコマンドを実行した後に、以下のコードを実行します。

```SuperCollider
(
SynthDef(\sinesynth, {|out, sustain=1.0, pan, freq|
    var sound = SinOsc.ar(freq);
    var env = EnvGen.ar(Env.linen(0.01, sustain, 0.01));
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
)
```

次に、以下のプログラムをAtomエディタで作成し、拡張子を.tidalとして一旦保存した後にCtrl+Enterで実行します。noteは音程を意味し、0とした場合Cの音、9とした場合はA(=440Hz)となります。gainは音量です。

```Haskell
d1 $ sound "sinesynth" # note 9 # gain 0.5
```

soundやnoteは1文字の略称を使うこともできます。

```Haskell
d1 $ s "sinesynth" # n 9 # gain 0.5
```


TidalCyclesはループパターンを演奏するための言語なので、上記の例もCtrl+.で終了するまで440Hzのサイン波を定期的に鳴らし続けます。本来は、以下のようにシーケンスやリズムパターンを複数のトラックを使って演奏するのがTidalCyclesのスタイルです。

```Haskell
d1 $ s "sinesynth*8" # n "[2 4 5 7 9 7 5 4]" # gain 0.5 # sustain 0.1

d2 $ s "sinesynth*2" # n "[-10 -3]" # gain 0.5 # sustain 0.5
```



## Delayエフェクト

wavファイルを鳴らすにはDirtSamplesのファイルとしてフォルダに追加するのが簡単です。Windowsにchocoでインストールした場合、以下にDirtSamplesのフォルダがあります。
C:\Users\myname\AppData\Local\SuperCollider\downloaded-quarks\Dirt-Samples

ここに任意の名前のサブフォルダ（例：voice）を作成してwavファイルを入れてからSuperDirt.startすると、追加したフォルダ名が楽器名となりwavファイルを再生することができるようになります。

```Haskell
d1 $ s "voice"
```

サブフォルダに複数のwavファイルを入れた場合はnで指定できます。ファイル名に連番をつけてソート順をわかりやすくするのがおすすめです。

```Haskell
d1 $ s "voice" # n 3
```

DirtSamplesフォルダ以外のサンプリング音を鳴らす場合、これもSuperColliderで設定する必要があります。SuperDirt.startを実行すると、グローバル変数~dirtでSuperDirtを参照できるようになります。loadSoundFilesでフォルダ名を指定することで、DirtSamplesだけでなく追加されたフォルダのwavファイルも再生できるようになります。

```SuperCollider
SuperDirt.start;

~dirt.loadSoundFiles("C:/tmp/voice/");
```

ディレイエフェクトははじめから用意されているので、それを使います。delaytime、delayfeedback、delayでディレイタイム、フィードバック量、ウェットレベルをそれぞれを設定します。また、今回はsetcpsでループの周期を長くしています。cpsはcycles per secondの意味で、0.3の場合1秒間に0.3周期、つまり約3.3秒で1周期となります。

```Haskell
setcps 0.3

d1 $ s "voice" # delaytime 0.4 # delayfeedback 0.5 # delay 0.5 
```


# 感想

TidalCyclesの弱点はなんといっても環境構築の煩雑さです。数年前に比べれば大分楽になりましたが、それでもまだ十分とは言えません。音がうまく鳴らないときに、それの原因がSuperColliderなのかAtomの拡張機能(JavaScript)なのかHaskellなのかcabalやchocoのインストールに原因があるのかを判断して適切に対応する必要があり、広範囲の知識が必要になります。

ループパターンを演奏する言語としての設計はユニークで魅力的です。コンピュータサイエンスを学んでプログラミング言語に精通している開発者が作った言語特有の、簡潔さと高い表現力が両立した美しさがあります。これは元の言語のHaskellにも通じる特徴です。

言語仕様の全貌を把握するのは大変ですが、シンプルなパターンからおぼえていけばそれほど難解な言語ではありません。他では実現が難しいような複雑なリズムパターンの生成が簡単にできるため人気も比較的高く、後続の言語にも影響を与えつつあるので現状知っておくべき重要な言語だと思います。

ただし、基本的にTidalCyclesの対象はSonic Piと同様にあらかじめ用意された音源を鳴らすライブコーディングであり、信号処理にフォーカスした言語ではありません。


