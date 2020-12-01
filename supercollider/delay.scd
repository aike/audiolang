(
{
	var delayTime = 0.4;
	var feedback = 0.5;
	var wetLevel = 0.5;

	var voice = PlayBuf.ar(1,
		Buffer.read(s, Document.current.dir ++ "/../voice.wav"));

	var delay = CombN.ar(voice, delayTime, delayTime, feedback * delayTime * 10, wetLevel);

	Pan2.ar(voice + delay);
}.play
)