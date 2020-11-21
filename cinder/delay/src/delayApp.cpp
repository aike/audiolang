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
