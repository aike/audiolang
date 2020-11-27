(use 'overtone.live)

;; delay fx for instruments
(defsynth fx-delay [bus 0 delay-time 0.4 feedback 0.5 wet-level 0.5]
  (let [dry (in bus)
        fb-in (local-in 1)
        wet (delay-n fb-in 1.0 delay-time)
        fb-out (local-out (* feedback (+ dry wet)))
        wet-out (* wet-level wet)]
    (out 0 (pan2 wet-out))))

;; load audio file into buffer
(def voice-buf (load-sample "../voice.wav"))

;; define buffer player instruments
(definst voice [] (play-buf 1 voice-buf))

;; add fx to buffer player
(inst-fx! voice fx-delay)

;; play
(voice)
