datapath = "/tmp/"
file = datapath + "voice.wav"

delayTime = 400 # msec
feedback = 0.5
wetLevel = 0.5

use_bpm 120
delayPerBeat = delayTime / 1000.0 / bt(1)

with_fx :echo, phase: delayPerBeat, mix: wetLevel, decay: feedback * 10 do
  sample file
end