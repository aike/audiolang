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

