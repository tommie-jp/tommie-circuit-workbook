---
book: circuits
chapter: 9
id: 9-32
title: Current Waveform of LC Resonance — Phase on Either Side of Resonance, Output Resistance of the Generator, and Why the LED Stays out of the Loop
tier: 100
source: 自作
board: BB
ja: 2958c85b90f13d94c8d0267fe948d1b5ae8c86a3
---

# 9-32 Current Waveform of LC Resonance — Phase on Either Side of Resonance, Output Resistance of the Generator, and Why the LED Stays out of the Loop

**Build 9-1 (LC tuning) first.** With the loop of 9-1, this exercise looks at how the phase of the generator voltage (CH1) and the loop current (CH2)
shifts on either side of resonance, and at the effect of the output resistance of the generator. It also shows with LTspice values why 9-1 keeps the LED outside the loop. The circuit, parts and instrument settings are as in 9-1.

**Why 9-1 keeps the LED out of the loop.** The LED passes no current until about 1.8 V is exceeded, so in the loop it
chops the current into narrow peaks, one per half cycle, and disturbs the resonance. LTspice shows that with two LEDs in opposite directions in the loop,
the current at f<sub>0</sub> falls from 17.6 mA to 4.5 mA and the resonance curve is no longer symmetric (2.3 mA at 8 kHz, 1.2 mA at 32 kHz).
Even with one LED, C1 is charged to one side and within a few cycles holds the LED off, and it goes out.

This exercise has no wiring diagram or Analog Discovery 3 figure. It uses the same board as 9-1 as it is and only adds a way of measuring (the figures are Fig. 1 and Fig. 2 of 9-1).

## Instrument settings

Keep the instrument settings of 9-1 and use a generator with a 50 Ω output. CH1 is the generator output, and CH2 is the voltage across R1 (loop current × 100 Ω).
At 12 kHz, lower CH2 to 200 mV/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 1 Below resonance (12kHz), CH2 smaller, leads CH1
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 12kHz 5.88Vpp, range: 2V/div}
ch2: {wave: sine 12kHz 1.01Vpp phase 78deg, range: 200mV/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/32-lc-resonance-phase.svg)

## Values to check

- **At the resonance point (15.9 kHz) CH1 and CH2 are in phase** (Fig. 4 of 9-1)
- **Below resonance CH2 leads CH1 (Fig. 1, about 78°).** The reactance of C1 wins, and the loop behaves like a capacitor.
  Above resonance the coil wins instead and CH2 lags (about 75° of lag at 20 kHz).
  Read the phase from Phase in Measurements, or as the time difference between the peaks of the two waves ÷ the period × 360°.
- With a generator of 50 Ω output, the amplitude of CH1 drops at the resonance point (6.0 → about 4.2 Vpp, Fig. 4 of 9-1).
  The current drops voltage across the 50 Ω inside the generator. With a generator of ≈ 0 Ω output it does not drop.
- In Fig. 1, CH2 is lowered to 200 mV/div. Compare sizes by the Vpp readings, not by the divisions.
- The 50 Ω output and ≈ 0 Ω output curves in Fig. 3 of 9-1 have almost the same skirts (below 12 kHz and above 20 kHz), and only the top differs, 17.6 mA against 24.9 mA.
  The 50 Ω of the generator also counts as resistance in the loop, so Q falls and the peak is lower and flatter. The relation of loop resistance to Q and the sharpness of the peak is also covered in
  02-analog-discovery/05-network/03-rl-lc-resonance.md (5-3 of the AD book).

## Verification with LTspice

The circuit is the same as Fig. 1 of 9-1, and the comparison of the Vpp of CH2 is in "Verification with LTspice" of 9-1.
The phases (about 78° and about 75°), the about 4.2 Vpp of CH1 and the values with the LEDs in the loop were not run again here.

## Sources

Original work.

See also: [LC circuit (Wikipedia, Japanese)](https://ja.wikipedia.org/wiki/LC回路), [Tuned circuit (Wikipedia, Japanese)](https://ja.wikipedia.org/wiki/同調回路)
