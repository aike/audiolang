<CsoundSynthesizer>

<CsOptions>            ; set play options
  -odac                ; output sound to DAC
</CsOptions>

<CsInstruments>        ; set sound parameters
sr     = 44100         ; sample rate
ksmps  = 32            ; samples per control period (ksmps = sr / kr)
nchnls = 1             ; number of channels
0dbfs  = 1             ; 0 dBfs

; define instrument 1
instr 1
 aSig oscil p5, p4     ; use oscillator with p5(amplitude) and p4(frequency)
 outs aSig             ; connect to channel 0 and channel 1 
endin
</CsInstruments>

<CsScore>              ; set play event parameters
; inst_number start_time(sec) end_time(sec) p4=frequency p5=amplitude
i 1 0 10 440 0.3
e
</CsScore>

</CsoundSynthesizer>