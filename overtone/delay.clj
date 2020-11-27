(use 'overtone.live)

;; buffer player with delay fx
(definst play-with-delay [buf 0 delay-time 0.4 feedback 0.5 wet-level 0.5]
  (let [dry (play-buf 1 buf)
        fb-in (local-in 1)
        wet (delay-n fb-in 1.0 delay-time)
        fb-out (local-out (* feedback (+ dry wet)))
        mix (+ dry (* wet-level wet))]
    mix))

;; load audio file into buffer
(def voice-buf (load-sample "../voice.wav"))

;; play
(play-with-delay voice-buf)
