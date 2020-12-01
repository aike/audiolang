Cinder
===

# 概要

https://libcinder.org/

プロフェッショナル品質のクリエイティブコーディングのためのオープンソースC++ライブラリ。二条項BSDライセンス。

初出は2010年、広告代理店The Barbarian Group(米国)のAndrew Bellが中心となり開発。

もともと商用メディア制作用途の内製ライブラリとして作られており、高速なグラフィックスやモダンで抽象化された記法が特徴。アプリケーションのひな形が用意されていて、Processingのようにsetup()、draw()関数の内容を実装するだけでグラフィックやサウンドを利用したネイティブアプリを作成できる。openFrameworksと同様にプロジェクトジェネレータや拡張ライブラリが用意されている。

# 実装例

## セットアップ

Windowsの場合、Cinderの最新版はVisual C++ 2015用になっているので、Visual C++ 2017でビルドするときは少し注意が必要です。

ダウンロードして展開します。  
https://libcinder.org/download

インストールフォルダの下のtools\TinderBox-Win\にあるTinderBox.exeを実行すると、指定フォルダの下にプロジェクトが作成されます。Visual Studioで開いて、ビルド、実行するだけでも何もしないウィンドウが表示されます。

VC++2017の場合はリンクエラーが出てそのままではビルドできません。インストールフォルダの下の以下のライブラリフォルダ名をv140からv141にリネームするとビルドできるようになります。

- lib\msw\x64\Debug\v140\
- lib\msw\x64\Release\v140\
- lib\msw\x86\Debug\v140\
- lib\msw\x86\Release\v140\


## サイン波生成

メイン処理のソースは、宣言と実装をひとつのファイルに書くのがCinderのスタイルのようです。たしかにクリエイティブコーディングの多くのプログラム本体はヘッダを別にする必要はなく、読みやすさ管理しやすさを考えると合理的です。

オーディオ処理は、ノードを生成して、>>演算子で接続するようにプログラミングします。

```c++
#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"

#include "cinder/audio/Context.h"
#include "cinder/audio/GenNode.h"
#include "cinder/audio/GainNode.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class CinderProjectApp : public App {
public:
	void setup() override;
	void draw() override;

	audio::GenNodeRef	mOscillator;
	audio::GainNodeRef	mGain;
};

void CinderProjectApp::setup()
{
	auto ctx = audio::master();

	// setup nodes
	mOscillator = ctx->makeNode(new audio::GenSineNode);
	mOscillator->setFreq(440);

	mGain = ctx->makeNode(new audio::GainNode);
	mGain->setValue(0.5f);

	// setup audio graph
	mOscillator >> mGain >> ctx->getOutput();

	// play
	mOscillator->enable();
	ctx->enable();
}

void CinderProjectApp::draw()
{
	gl::clear(Color(0, 0, 0));
}

CINDER_APP(CinderProjectApp, RendererGl)
```


## Delayエフェクト

ディレイノードは音を遅らせるだけなので、ドライ／ウェットの分岐やフィードバックループをノードの組み合わせで実現します。>>演算子を使って柔軟にノード同士を接続できるためシンプルに書くことができます。

マウスクリックすると再生するようにしてみました。これもあらかじめ用意されているmouseDown()メソッドに1行追加するだけで実現できます。

```c++
#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"

#include "cinder/audio/Context.h"
#include "cinder/audio/SamplePlayerNode.h"
#include "cinder/audio/NodeEffects.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class delayApp : public App {
  public:
	void setup() override;
	void mouseDown( MouseEvent event ) override;
	void draw() override;

	audio::FilePlayerNodeRef mVoice;
	audio::DelayNodeRef mDelay;
	audio::GainNodeRef mWet;
	audio::GainNodeRef mFeedback;
};

void delayApp::setup()
{
	auto ctx = audio::master();

	// setup nodes
	audio::SourceFileRef audiofile = audio::load(loadAsset("voice.wav"));
	mVoice = ctx->makeNode(new audio::FilePlayerNode(audiofile));

	mDelay = ctx->makeNode(new audio::DelayNode);
	mDelay->setDelaySeconds(0.4f);

	mWet = ctx->makeNode(new audio::GainNode);
	mWet->setValue(0.5f);

	mFeedback = ctx->makeNode(new audio::GainNode);
	mFeedback->setValue(0.5f);

	// setup audio graph
	mVoice >> ctx->getOutput();
	mVoice >> mDelay >> mFeedback >> mDelay >> mWet >> ctx->getOutput();

	// play
	ctx->enable();
	mVoice->start();
}

void delayApp::mouseDown( MouseEvent event )
{
	mVoice->start();
}

void delayApp::draw()
{
	gl::clear( Color( 0, 0, 0 ) );
}

CINDER_APP( delayApp, RendererGl )
```


# 感想

openFrameworksよりも後発で、商用作品制作用内製ライブラリという出自が設計にも表れています。openFrameworks同様高速なグラフィックやオーディオ処理に向いていますが、アーティスト向けというより、C++に慣れたプログラマーが使うことで高いパフォーマンスが得られる設計になっている印象です。ソースコードが一見DSLのような記法ではなく、モダンなC++として自然な記述になるのもC++プログラマー向きです。

とはいえ、メモリ管理やハンドル管理の煩雑な処理を書く必要がないのは、openFrameworks同様C++プログラミングの敷居を大幅に下げており、様々な人が扱いやすいライブラリではあると思います。

オーディオ処理については、最初から必要な機能が充実していて使いやすいです。ノードを接続していくスタイルは、JavaScript(Web Audio API)、Processing(Minim UGen)、ChucKなどと同様、柔軟性とわかりやすさの両面で優れていると思います。

