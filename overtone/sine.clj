(use 'overtone.live)

(definst play-sine [] (* 0.5 (sin-osc 440)))

(defn play-1sec []
  (play-sine)
  (Thread/sleep 1000)
  (kill play-sine))

(play-1sec)
