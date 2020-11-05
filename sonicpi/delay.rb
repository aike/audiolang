datapath = "/tmp/"
file = datapath + "voice.wav"

with_fx :echo, delaytime: 0.4, decay: 5 do
  sample file
end
