---
book: circuits
chapter: 5
id: 5-1
title: Half-wave, full-wave and bridge rectification with smoothing (low-voltage AC)
tier: 50
source: 自作
board: BB
ja: 627d9623816c4339fa08229bec0f885dd70c14cc
---

# 5-1 Half-wave, full-wave and bridge rectification with smoothing (low-voltage AC)

As a first step toward turning AC into DC, we build a **bridge rectifier** from four diodes and smooth it with an
electrolytic capacitor. The goal is to learn how a circuit's power supply is made from AC instead of a battery.
Rectification makes the current flow in one direction only. Smoothing fills the valleys with charge stored in the capacitor
and evens out the pulsating voltage.

Do not connect to the mains. Use a 9 V AC adapter (or the output of a signal generator) as the AC source.
9 V is an **RMS value**: the DC voltage that would produce the same heat in the same resistor. For a sine wave it is 1/√2 of the amplitude (peak).
With 9 V, the rectified voltage stays at or below 12 V and the peak at or below 20 V, which is within what a breadboard can handle.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Bridge rectifier and smoothing (CH1 across C1)
parts:
  D1: diode acL 3,2 1N4001
  D2: diode acR dcP 1N4001
  D3: diode 3,6 acL 1N4001
  D4: diode dcN acR 1N4001
  V1: sine 4,4 7,4 12.7
  C1: ecap 10,2 10,6 1000u
  RL: resistor 13,2 13,6 220
  M1: voltmeter 16,2 16,6 l=$\mathrm{CH1}$
points:
  acL: 3,4
  acR: 8,4
  dcP: 8,2
  dcN: 8,6
wires:
  - acL -- 4,4
  - 7,4 -- acR
  - 3,2 -- dcP -- 10,2 -- 13,2 -- 16,2
  - 3,6 -- dcN -- 10,6 -- 13,6 -- 16,6
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/circuit/01-rectifier-filter.svg)

- V1 is the output of a 9 V (RMS) AC adapter. Its amplitude (peak) is 9 × √2 ≈ 12.7 V
- In Fig. 1, D1 and D2 are on the upper side (toward +) and D3 and D4 on the lower side (toward GND). This is the bridge rectifier;
  it has the same connections as the familiar diamond-shaped drawing, with the diodes laid out vertically.
  In either half cycle of the AC, current flows into the + side of C1 (in one half cycle through D1 → RL → D4, in the other through D2 → RL → D3)
- C1 (1000 µF) is the smoothing capacitor. RL (220 Ω) stands in for a "load that uses the power"
- The current through RL is 10.9 V / 220 Ω ≈ 50 mA (10.9 V is the calculated value in "Values to check" below).
  The power is 10.9² / 220 ≈ 0.54 W, which exceeds the rating of a 1/4 W or 1/2 W resistor.
  Use a **1 W class** resistor for RL (metal oxide film, for example); then the load is about half the rating, which leaves some margin

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard (1+ to C1 +, 1− to GND)
board: half
parts:
  D3: diode b8(A) b5(K) 1N4001
  D4: diode d8(A) d11(K) 1N4001
  D1: diode g5(A) g8(K) 1N4001
  D2: diode i11(A) i8(K) 1N4001
  C1: capacitor/electrolytic g16(+) g20(-) 1000uF
  RL: resistor i16 i20 220
  GEN:
    type: device
    at: top
    label: 9V AC adapter
    pins: [AC1, AC2]
  AD:
    type: device
    at: top
    label: Analog Discovery (Scope)
    pins: [1+, 1-]
wires:
  - GEN.AC1 -- a5 yellow
  - e5 -- f5 yellow
  - GEN.AC2 -- a11 yellow
  - e11 -- f11 yellow
  - a8 -- -t8 black
  - j8 -- +b8 red
  - +b16 -- j16 red
  - -b20 -- j20 black
  - -t29 -- -b29 black
  - AD.1+ -- h16 orange
  - AD.1- -- -b22 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/breadboard/01-rectifier-filter.svg)

- The cathodes of D1 and D2 (column 8, lower block) form DC+, and the anodes of D3 and D4 (column 8, upper block) form DC−.
  DC+ goes out to the bottom + rail and DC− to the top − rail. C1 and RL are taken from the rails at columns 16 and 20.
  The upper and lower − rails are joined at column 29
- The AC enters at columns 5 and 11 and is passed from the upper block to the lower block with yellow wires
- 1+ (orange) of the Analog Discovery goes to the column on the + side of C1 (`h16`), and 1− (black) goes to the bottom − rail (`-b22`).
  The AC source is the AC adapter. The Wavegen of the AD3 is not used (its output is at most ±5 V, 30 mA, so it cannot serve as a 9 V AC source)
- Always check the direction of the rectifier diodes (the striped side is the cathode). If one is reversed,
  no current flows and the AC adapter and C1 are stressed

## Viewing on the oscilloscope

Fig. 4 shows how the rectified waveform changes with C1 attached and removed (a shape drawn from calculation, not a measurement).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 4 Rectified (CH1, C1 off), smoothed (CH2, C1 on)
time: 5ms/div
trigger: ch1 rising 5V
ch1: {wave: "sine 60Hz 12.7V | abs | offset -1.6V | clip 0V", range: 2V/div, position: -2div}
ch2: {wave: "ch1 | peak 220ms", range: 2V/div, position: -2div}
measure: [vmax, vmin, vpp, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/scope/01-rectifier-filter.svg)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| D1 to D4 | Rectifier diodes | 1N4001 |
| C1 | Electrolytic capacitor (smoothing) | 1000 µF (rated 25 V or more; about 11 V after rectification) |
| RL | Resistor (load, **1 W**, because it dissipates about 0.54 W) | 220 Ω |
| — | Instruments | Scope of the Analog Discovery 3 (1+ = + of C1, 1− = GND) |
| — | AC source | 9 V AC adapter (or a signal generator, 9 V RMS). Low-voltage AC input, as in the transformer experiment (Chapter 6) |

## Values to check

The values in the table are calculated values. Take the forward voltage of one diode (seen in 1-4) as 0.8 V. In the bridge, the current always passes through two diodes in series.
The remaining ripple after smoothing is called the **ripple**. The peak-to-peak ripple (from peak to valley) of full-wave rectification is estimated by the following formula.

- V<sub>ripple(pp)</sub> ≈ I<sub>dc</sub> / (f<sub>ripple</sub> × C)
- f<sub>ripple</sub> = 2 × the mains frequency (120 Hz for 60 Hz). The table is calculated for 60 Hz. In 50 Hz regions it is 100 Hz and the ripple is about 0.50 V

The instrument is the oscilloscope (Scope) of the Analog Discovery 3. It reads the difference between peak and valley from the time waveform, which suits it better than a multimeter
(the DC average can also be measured on the DC voltage range of a multimeter). Connect 1+ to the + of C1 and 1− to GND (Fig. 2),
and read the ripple as the difference between peak and valley. For the peak right after rectification, remove C1 and read the top of the waveform across RL.

Fig. 4 overlays the waveform without C1 (CH1) and with C1 (CH2). CH1 sticks at 0 V while the AC is near its zero crossing
and has not reached the voltage of two diodes (about 1.6 V), because no current flows. CH2 charges C1 at the top of each peak and falls as C1 discharges into RL in the valley.
The readings in Fig. 4 are a peak of 11.1 V, a valley of 10.7 V and a ripple of 0.38 V, at 120 Hz.
The 0.41 V from the formula is an estimate that uses the whole discharge time down to the valley. The figure excludes the charging time (around the peak), so its value is a little smaller
(both are calculated values, not measurements).

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Peak voltage right after rectification | about 11.1 V (12.7 V − 2 × 0.8 V) | The voltage drop of two diodes |
| DC voltage (average) after C1 and RL | about 10.9 V | Lower than the peak by half the ripple |
| Ripple voltage (peak-to-peak) | about 0.41 V (0.38 V in the calculation of Fig. 4) | I<sub>dc</sub> (≈ 50 mA) / (120 Hz × 1000 µF) |
| **Calculation (if it were half-wave)**: ripple with the same C and RL | about 0.83 V (double) | f<sub>ripple</sub> becomes 60 Hz and the ripple about doubles. This is the advantage of full-wave |

Half-wave rectification can be made by connecting one terminal of the AC source through a single diode to the + side of C1 and RL,
and the other terminal directly to the − side of C1 and RL. It has fewer parts than the bridge, but it uses only one half cycle of the
AC adapter, so the ripple is larger and the efficiency is worse.
If you remove D2 and D3 from the board of Fig. 2, the current takes only the path D1 → RL → D4, and you can check half-wave rectification
(it still passes two diodes, so the peak is about 11.1 V, the same as full-wave).

## Verification with LTspice

In LTspice (standard 1N4001 model, V1 = 12.7 V, 60 Hz), the peak after rectification is 11.15 V, the average after C1 and RL is 10.8 V and the ripple is 0.34 Vpp.
The average is about 0.1 V lower than in the table because the diode voltage drop while the charging current is large is greater than 0.8 V.
The ripple is smaller because the discharge time is shorter than the whole time down to the valley, by the time spent charging.

## Sources

Original work.
