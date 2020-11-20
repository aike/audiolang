openFrameworks
===

# 概要

https://openframeworks.cc/

クリエイティブコーディングのためのオープンソースC++ツールキット。略称はoF。

初出は2005年、開発はZachary Lieberman、Theo Watson、Arturo Castro。

アプリケーションのひな形が用意されていて、Processingのようにsetup()、draw()関数の内容を実装するだけでグラフィックやサウンドを利用したネイティブアプリを作成できる。
アドオンによる機能拡張が特徴で、oFコミュニティにより多くのアドオンが開発されている。

# 実装例

## セットアップ

Windowsの場合、Visual Studio 2017がインストール済みであればあまり迷うことはありません。

ダウンロードして展開。  
https://openframeworks.cc/download/

projectGenerator-vsフォルダのprojectGenerator.exeを実行すると、apps\myAppsフォルダの下にプロジェクトが作成されIDEが起動する。



## サイン波生成

ofApp.h  
コメント行以降が追加した部分です。

```c++
#pragma once

#include "ofMain.h"

class ofApp : public ofBaseApp {

public:
	void setup();
	void update();
	void draw();

	void keyPressed(int key);
	void keyReleased(int key);
	void mouseMoved(int x, int y);
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void mouseEntered(int x, int y);
	void mouseExited(int x, int y);
	void windowResized(int w, int h);
	void dragEvent(ofDragInfo dragInfo);
	void gotMessage(ofMessage msg);

	//--------------------------------------------

	void audioOut(ofSoundBuffer & buffer);

	ofSoundStream soundStream;

	float volume;
	float frequency;
	float theta;
	float delta;
	float sampleRate = 44100.f;
};
```

ofApp.cpp  
audioOut()メソッドでbufferに波形を渡すと音が鳴ります。soundStreamの初期化を正しくおこなえば、あとはシンプルです。

キーボードのeを押すと音が止まり、sを押すと再開するようにしてみました。こういったコールバック処理も非常に短く書くことができます。

ウィンドウ関係は何も設定しなくても、デフォルトの大きさ、色でウィンドウが生成されます。

```c++
#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {

	frequency = 440.f;
	volume = 0.1f;

	theta = 0;
	delta = (frequency / sampleRate) * TWO_PI;

	ofSoundStreamSettings settings;
	settings.setOutListener(this);
	settings.sampleRate = sampleRate;
	settings.numOutputChannels = 2;
	settings.numInputChannels = 0;
	settings.bufferSize = 512;

	soundStream.setup(settings);
}

//--------------------------------------------------------------
void ofApp::update() {

}

//--------------------------------------------------------------
void ofApp::draw() {

}

//--------------------------------------------------------------
void ofApp::audioOut(ofSoundBuffer & buffer) {

	while (theta > TWO_PI) {
		theta -= TWO_PI;
	}

	for (size_t i = 0; i < buffer.getNumFrames(); i++) {
		theta += delta;
		float sample = sin(theta);
		int index = i * buffer.getNumChannels();
		buffer[index + 0] = sample * volume;
		buffer[index + 1] = sample * volume;
	}
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
	if (key == 's') {
		soundStream.start();
	}

	if (key == 'e') {
		soundStream.stop();
	}
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {

}

```




## Delayエフェクト

wavファイルを再生するには標準のofSoundPlayerがありますが、これはサンプルデータを加工するのは難しそうなので、Soundアドオンの中からofxATKを使って実装します。ofxATKはディレイエフェクトも用意されており今回の目的に合いそうです。

https://ofxaddons.com/categories/5-sound  
https://github.com/aaronaanderson/ofxATK

openFrameworksを展開したフォルダの下のaddonsフォルダにofxATKをコピーします。

```
> cd addons
> git clone https://github.com/aaronaanderson/ofxATK.git
```


ofApp.h  
コメント行以降が追加した部分です。

```c++
#pragma once

#include "ofMain.h"
#include "ofxATK.hpp"

class ofApp : public ofBaseApp {

public:
	void setup();
	void update();
	void draw();

	void keyPressed(int key);
	void keyReleased(int key);
	void mouseMoved(int x, int y);
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void mouseEntered(int x, int y);
	void mouseExited(int x, int y);
	void windowResized(int w, int h);
	void dragEvent(ofDragInfo dragInfo);
	void gotMessage(ofMessage msg);

	//--------------------------------------------

	void ofApp::audioOut(ofSoundBuffer & buffer);

	ofSoundStream soundStream;

	SoundFile* soundFile;
	SoundPlayer* player;
	TapIn* tapIn;
	TapOut* tapOut;

	float delayTime;
	float feedBack;
	float wetLevel;
	float volume;
	int sampleRate = 44100;
};
```

ofApp.cpp  
全体の構成はサイン波生成とほとんど同じです。
TapInでディレイバッファに格納、TapOutでディレイバッファから読み込みというのはMaxに似ています。
ディレイバッファをクリアしておかないとクリックノイズが出るようなので0で埋めています。

データファイルは bin\data\ フォルダに置いておくとofToDataPath()でアクセスできます。
SoundFileで読み込み、SoundPlayer::playで再生などシンプルでわかりやすいです。

キーボードのsを押すたびに再生するようにしてみました。

```c++
#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {

	delayTime = 400.f;
	feedBack = 0.5f;
	wetLevel = 0.5f;
	volume = 0.3f;

	float maxDelay = 1.0f; // sec
	tapIn = new TapIn(1000.f * maxDelay);
	tapOut = new TapOut(tapIn, delayTime);
	// clear delay buffer
	for (int i = 0; i < sampleRate * maxDelay; i++) {
		tapIn->feed(0.f);
	}

	soundFile = new SoundFile(ofToDataPath("voice.wav"));
	player = new SoundPlayer(soundFile, 0, true);

	ofSoundStreamSettings settings;
	settings.setOutListener(this);
	settings.sampleRate = sampleRate;
	settings.numOutputChannels = 2;
	settings.numInputChannels = 0;
	settings.bufferSize = 512;

	soundStream.setup(settings);

	player->loop(false);
	player->setLocation(0);
	player->play();
}

//--------------------------------------------------------------
void ofApp::update() {

}

//--------------------------------------------------------------
void ofApp::draw() {

}
//--------------------------------------------------------------
void ofApp::audioOut(ofSoundBuffer & buffer) {

	for (size_t i = 0; i < buffer.getNumFrames(); i++) {
		player->process();
		float dry = player->getSample();
		float wet = tapOut->getSample();
		float sample = dry + wet * wetLevel;
		tapIn->feed(dry + (wet * feedBack));

		int index = i * buffer.getNumChannels();
		buffer[index + 0] = sample * volume;
		buffer[index + 1] = sample * volume;
	}
}
//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
	if (key == 's') {
		player->setLocation(0);
		player->play();
	}
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {

}
```


# 感想

C++で書かれたネイティブアプリが生成できるので、openFrameworksは高速なグラフィックやオーディオ処理が必要な場面で特に優位性があります。
また、C++の良くも悪くも煩雑なところが隠蔽されて、本来のオーディオ処理に注力できるのは大きな魅力です。
とはいえProcessingなどと比べるとそこまで手軽とは言い難いので、高速性が必要な専門家の道具という印象です。

今回ほとんど初めてopenFrameworksを触ってみましたが、APIやライブラリは思ったほどProcessingに似ていないのが意外でした。
setup()、draw()の構造は共通ではあるものの、ライブラリは独自の進化をしているようです。

多くのアドオンが用意されているのが魅力の一方で、どれを使うべきか判断するのはなかなか難しい感じがしました。
OSに依存するアドオンもあるので、ofxAddons( https://ofxaddons.com/categories )についているスターの数を目安にいくつか試してみるのが良いようです。

