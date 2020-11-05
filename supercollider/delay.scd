//s = Server.local.boot;
//b = Buffer.read(s, "sounds/a11wlk01.wav");
b = Buffer.read(s,
	thisProcess.nowExecutingPath.dirname ++ "/../voice.wav");

// simple feedback delay
(
SynthDef('help-switchdelay-1', { arg out=0, bufnum;
    Out.ar(out,
        Pan2.ar(
            SwitchDelay.ar(
                PlayBuf.ar(numChannels: 1, bufnum: bufnum, loop: 0) * 0.5,
                delaytime: 0.4,
                delayfactor: 0.6,
                wetlevel: 0.7
            )
        )
    );
}).send(s);
)

x = Synth('help-switchdelay-1', [\bufnum, b]);
x.free;



SynthDef("WavPlayer", {|buf|
	var playLR = [
		PlayBuf.ar(1, buf, BufRateScale.kr(buf)),
		PlayBuf.ar(1, buf, BufRateScale.kr(buf))
	];
	Out.ar(0, playLR);
}).add;

SynthDef("Dly", {|delaytime = 0.1|
	var input, effect;
	input=In.ar(0,2); //get two channels of input starting (and ending) on bus 0
	effect= DelayN.ar(input, 1,delaytime); //max delay of one second
	Out.ar(0,effect); //adds to bus 0
}).add;

a = Group.basicNew(s,1);

w = Buffer.read(s,
	thisProcess.nowExecutingPath.dirname ++ "/../voice.wav");

h.free;
t.free;
h = Synth.head(a, "WavPlayer", ["buf", w]);
t = Synth.tail(a, "Dly")



//w.free;
