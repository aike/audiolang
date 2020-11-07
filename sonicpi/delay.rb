datapath = "/tmp/"
file = datapath + "voice.wav"

use_bpm 60

with_fx :echo, phase: 0.4, mix: 0.5, decay: 5 do
  sample file
end
