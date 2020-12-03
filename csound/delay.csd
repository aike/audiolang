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
iDelayTime = 0.4
iFeedback  = 0.5
iWetLevel  = 0.5

aSig    diskin2 "../voice.wav"        ; load wav file
aBufOut delayr  iDelayTime            ; read from delay buffer
delayw  aSig + (aBufOut * iFeedback)  ; write to delay buffer
out     aSig + (aBufOut * iWetLevel)  ; output signal
endin
</CsInstruments>

<CsScore>              ; set play event parameters
; inst_number start_time(sec) end_time(sec) 
i 1 0 10
e
</CsScore>

</CsoundSynthesizer>