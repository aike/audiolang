(use 'overtone.live)

((synth "audition-synth" 
    (out 0 (pan2
        (hold (* 0.5 (sin-osc 440)) 2.0 :done FREE)))))
