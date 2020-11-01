import("stdfaust.lib");

freq = 440;
gain = 0.5;

process = os.osc(freq) * gain <: _,_;

