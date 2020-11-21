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
	void mouseDown(MouseEvent event) override;
	void update() override;
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

void CinderProjectApp::mouseDown(MouseEvent event)
{
}

void CinderProjectApp::update()
{
}

void CinderProjectApp::draw()
{
	gl::clear(Color(0, 0, 0));
}

CINDER_APP(CinderProjectApp, RendererGl)
