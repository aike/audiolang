datapath = "/tmp/"

file = datapath + "voice.wav"
sampleTime = sample_duration(file)
delayTime = 0.4
attenuate = 0.5
sample file
(sampleTime/delayTime).times do
  sleep delayTime
  sample file, amp: attenuate
  attenuate *= attenuate
end
