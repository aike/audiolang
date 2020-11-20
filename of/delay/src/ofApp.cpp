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
		tapIn->feed(dry + wet * feedBack);

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
