---
book: circuits
chapter: 2
id: 2-2
title: Emitter Follower
tier: 50
source: 自作
board: BB
ja: 84d04ae089681a3129605e16a44b692124a047f7
---

# 2-2 Emitter Follower

This circuit connects the collector directly to the supply and takes the output from the emitter. **It leaves the voltage almost
unchanged, at about 1 times, and increases only the current it can deliver.** In this exercise you feed in a 1 kHz sine wave from W1
and use the oscilloscope to confirm that a wave of almost the same size appears at the output.

It is used when a signal source that cannot supply much current has to drive a load with a low resistance.
The quantity that acts like a resistance to AC is called impedance (unit Ω). In these terms, the circuit works as a "bridge"
between a high-impedance signal source and a low-impedance load.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Emitter follower, driven by W1, compare CH2 and CH1
parts:
  VCC: vcc 8,2 5V
  R1: resistor 6,2 6,4 22k
  R2: resistor 6,4 6,6 10k
  G2: ground 6,6
  Q1: npn 8,4
  CIN: ecap 5,4 4,4 10u
  W1: sine 2,4 2,6 l=$\mathrm{W1}$
  M2: voltmeter 4,4 4,6 l=$\mathrm{CH2}$
  G5: ground 4,6
  RE: resistor 8,6 8,8 1k
  G3: ground 8,8
  COUT: ecap 8,6 11,6 10u
  RL: resistor 11,6 11,8 1k
  G4: ground 11,8
  OUT: port 11,6
  M1: voltmeter 13,6 13,8 l=$\mathrm{CH1}$
wires:
  - 6,2 -- 8,2
  - 8,2 -- Q1.C
  - 5,4 -- 6,4 -- Q1.B
  - Q1.E -- 8,6
  - 2,4 -- 4,4
  - 2,6 -- 4,6
  - 11,6 -- 13,6
  - 11,8 -- 13,8
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/02-emitter-follower.svg)

The `+5V` in Fig. 1 is the supply output V+ of the Analog Discovery. `R1` (22 kΩ) and `R2` (10 kΩ) divide the voltage to bias the base, and `RE` (1 kΩ) sets the emitter potential.
`CIN` and `COUT` are coupling capacitors that block DC and pass only the signal.

- Open-circuit voltage of the divider (the voltage at the divider point with the base disconnected): 5 V × 10k/(22k+10k) ≈ **1.56 V**.
  The resistance when the divider is replaced by one source and one resistor (the equivalent internal resistance) is 22 kΩ in parallel with 10 kΩ, ≈ 6.9 kΩ
- The base current (about 5.5 µA, assuming hFE = 150) flowing through 6.9 kΩ lowers the voltage, so the actual Vb ≈ **1.52 V**
- Emitter voltage: Ve = Vb − 0.7 ≈ **0.83 V**, Ie = Ve / RE ≈ **0.83 mA**
- Vce = 5 − 0.83 = **about 4.2 V**. The transistor is not saturated; it is in the range where the collector current follows the base current in proportion (the active region).
  The collector is tied directly to the supply, so the dissipation in the transistor is Vce×Ic ≈ 3.4 mW
- Voltage gain: Av = (RE ∥ RL) / (RE ∥ RL + re). re is a value that corresponds to a small resistance inside the emitter,
  estimated as re = 26 mV / Ie (26 mV is the thermal voltage V<sub>T</sub> at room temperature). re ≈ 26 mV / 0.83 mA ≈ 31.5 Ω.
  For AC, `RL` is also connected to the emitter through `COUT`, so RE ∥ RL = 1 kΩ ∥ 1 kΩ = 500 Ω.
  Av ≈ 500 / 531.5 ≈ **0.94 times** (only slightly below 1, and not inverted)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Emitter follower (W1 and CH2 on input, CH1 on output)
# 5V goes from V+ of the AD to the top + rail (the bottom rails are not used)
board: half
parts:
  R1: resistor b5 b10 22k
  R2: resistor a10 -t10 10k
  CIN: capacitor/electrolytic d4(-) d10(+) 10uF
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RE: resistor a14 -t14 1k
  COUT: capacitor/electrolytic b14(+) b18(-) 10uF
  RL: resistor a18 -t18 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 2-, W1, 2+, 1+, 1-, V+]
wires:
  - AD.V+ -- +t24 red
  - AD.GND -- -t1 black
  - AD.2- -- -t2 black
  - AD.2+ -- b4 blue
  - AD.W1 -- a4 yellow
  - AD.1+ -- c18 orange
  - AD.1- -- -t21 black
  - +t5 -- a5 red
  - +t12 -- a12 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/02-emitter-follower-1.svg)

As in Fig. 2, all the parts are plugged into the upper half. The 5 V goes from the supply output V+ (red) of the Analog Discovery to the top + rail
(set V+ to 5 V in the WaveForms Supplies and turn the output on). This circuit draws only about 1 mA, so V+ is enough.

- **Base (column 10)**: the right end of `R1`, the top end of `R2`, the + side of `CIN` and B of `Q1` are all in the same column,
  so no wire is needed. The left end of `R1` (column 5) goes to +5 V with a red wire
- **Collector (column 12)**: a red wire goes straight to the +5 V rail
- **Emitter (column 14)**: `RE` and the + side of `COUT` are in the same column. `R2`, `RE` and `RL` are plugged
  vertically down to the − rail
- **Input (column 4)**: the − side of `CIN`. Plug W1 (yellow) of the Analog Discovery into `a4`, and
  2+ (blue) of CH2 into `b4` just below it
- **Output (column 18)**: the − side of `COUT` and `RL`. Plug 1+ (orange) of CH1 into the
  free hole `c18`
- Connect GND, 2− and 1− (black) of the AD to the top − rail

## Viewing on the oscilloscope

Set W1 to a 1 kHz, 1 Vpp sine wave, and overlay CH2 (input) and CH1 (output) at the same 200 mV/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Input (CH2) and output (CH1), in phase
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 0.94Vpp, range: 200mV/div}
ch2: {wave: sine 1kHz 1Vpp, range: 200mV/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/02-emitter-follower.svg)

CH1 in Fig. 3 is about 0.94 times CH2 (0.94 Vpp), and the peaks and troughs of the two traces almost coincide. You can see at a glance that the signal is not inverted
and that the voltage comes out at almost 1 times. The cutoff frequency of the coupling capacitor (10 µF) and 1 kΩ
is about 16 Hz, so at 1 kHz the phase shift is only about 1°, which cannot be seen on the screen.

## Viewing the frequency response with a VNA

In place of W1, CH1 and CH2 of the AD, connect a VNA (vector network analyzer; this book's standard is the LiteVNA64) (Fig. 4)
and look at how the circuit passes signals (S21) from 50 kHz to 100 MHz (Fig. 5). The historical NanoVNA-H4 can measure it by the same procedure.
The VNA sends a signal out of CH0 and receives it at CH1. S21 is the fraction of the signal fed in at CH0 that reaches CH1,
expressed in dB (seen in 1-5; 0 dB is 1 times). S11 is the fraction that is reflected back at the input.

- Connect CH0 (through an attenuator) to the − side of `CIN` (column 4, the input) and
  CH1 to the − side of `COUT` (column 18, the output) (Fig. 4). **Remove RL** — the 50 Ω of CH1 becomes the load as it is. Plug the SMA-to-clip cables into the breadboard **with the core and the shield as a pair**. Put the shield on
  the − rail right next to the signal hole, with the wire as short as possible (if the GND return is long, the response breaks up from around 10 MHz)
- The VNA output is too large for this circuit (if the output drives 50 Ω, the emitter's
  0.83 mA cuts off the lower half of the wave). **Attach a 20 dB SMA attenuator to CH0 and
  calibrate with THRU with it attached** (CH0 and CH1 connected directly are remembered as 0 dB, so the attenuator's share is removed by the calibration)
- The power comes from V+ (5 V) of the AD, as before

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 4 VNA connection (core and shield in pairs, RL removed)
board: half
parts:
  R1: resistor b5 b10 22k
  R2: resistor a10 -t10 10k
  CIN: capacitor/electrolytic d4(-) d10(+) 10uF
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RE: resistor a14 -t14 1k
  COUT: capacitor/electrolytic b14(+) b18(-) 10uF
  CH0:
    type: device
    at: top
    label: CH0 (via 20 dB attenuator)
    pins: [Shield, Core]
  CH1:
    type: device
    at: top
    label: CH1
    pins: [Core, Shield]
  AD:
    type: device
    at: top
    label: AD (power)
    pins: [GND, V+]
wires:
  - CH0.Core -- a4 yellow
  - CH0.Shield -- -t3 black
  - CH1.Core -- a18 orange
  - CH1.Shield -- -t19 black
  - AD.GND -- -t24 black
  - AD.V+ -- +t25 red
  - +t5 -- a5 red
  - +t12 -- a12 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/02-emitter-follower-2.svg)

Fig. 5 is a graph of S21 **calculated** by replacing the transistor with a small-signal model (hybrid-π)
(it is not a VNA screen). When you measure, a line of the same shape should appear on the VNA screen.

```graph
# Graph (tommie-fence graph fence)
title: Fig. 5 Emitter follower S21 (calculated), +1.5 dB at low end, falls from a few MHz
x: Frequency Hz log 50k..100M
y:
  - Magnitude dB
  - Phase deg
lines:
  S21 (calculated) dB:
    - 50k 1.52
    - 549.8k 1.52
    - 1.05M 1.51
    - 2.049M 1.49
    - 3.049M 1.46
    - 4.048M 1.41
    - 5.048M 1.36
    - 7.046M 1.22
    - 9.046M 1.04
    - 11.04M 0.84
    - 13.04M 0.63
    - 15.04M 0.40
    - 20.04M -0.17
    - 25.04M -0.70
    - 30.04M -1.16
    - 40.03M -1.85
    - 50.02M -2.29
    - 60.02M -2.55
    - 70.02M -2.68
    - 80.01M -2.71
    - 90M -2.68
    - 100M -2.59
  S21 phase (calculated) deg:
    - 50k 0.1
    - 549.8k -1.0
    - 1.05M -2.0
    - 2.049M -3.9
    - 3.049M -5.8
    - 4.048M -7.6
    - 5.048M -9.4
    - 7.046M -12.9
    - 9.046M -16.2
    - 11.04M -19.3
    - 13.04M -22.1
    - 15.04M -24.7
    - 20.04M -30.2
    - 25.04M -34.6
    - 30.04M -38.3
    - 40.03M -44.6
    - 50.02M -50.3
    - 60.02M -56.0
    - 70.02M -62.0
    - 80.01M -68.5
    - 90M -75.5
    - 100M -83.2
notes:
  - level 0dB
  - mark 1M
  - mark 20M
  - mark 50M
```

![Graph](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/graph/02-emitter-follower.svg)

- The 0 dB dashed line is the through connection, with CH0 and CH1 joined directly. S21 sits above it, at
  **about +1.5 dB at low frequencies (|S21| ≈ 1.19)**. The voltage gain is below 1 times, yet S21 exceeds 1, because
  the input has a high impedance (about 4.4 kΩ at low frequencies) and hardly loads the 50 Ω of CH0, while the output has a low
  impedance (about 32 Ω) and can drive the 50 Ω of CH1. The circuit receives twice the voltage it would get when
  connected directly to a 50 Ω line, and hands 0.6 times of that to the 50 Ω — this is impedance conversion
- **It falls from a few MHz.** It is +1.5 dB at 1 MHz, about 0 dB at 20 MHz (the same as the through) and about −2.3 dB at 50 MHz.
  Three reasons add up:
  - The fT of the 2SC1815 falls as the current and V<sub>CE</sub> get smaller. The datasheet's 80 MHz (minimum) is the value at
    V<sub>CE</sub> 10 V and I<sub>C</sub> 1 mA, and for this circuit (0.83 mA, about 4.2 V) it was assumed to be around 40 MHz
    (fT is the frequency at which the current gain falls to 1). As the frequency rises, the AC current gain β falls and the output impedance rises
  - The base spreading resistance (rbb′ about 50 Ω) and C<sub>ob</sub> (3 pF at VCB about 4 V) also create a pole on the input side
  - The lead of the SMA-to-clip cable (about 80 nH for 10 cm) and the stray capacitance of the breadboard holes (a few pF per place)
- The values used in the calculation for Fig. 5: Ie 0.83 mA, hFE 150, fT 40 MHz, Cob 3 pF and rbb′ 50 Ω, with the 80 nH of the clip leads (input and output)
  and 5 pF of stray capacitance at each node added. Where it actually starts to fall depends on the lead length and how it is assembled —
  the shorter the leads, the higher the frequency to which the response stays flat

For the input side (S11), if you replace the circuit seen from the base with an equivalent circuit made only of resistors, capacitors and coils,
you can draw it directly on the VNA screen (Fig. 6). From CH0 in order, place the clip lead (80 nH), the stray capacitance at the base node (5 pF),
the bias R1 ∥ R2 (6.9 kΩ), C<sub>ob</sub> (3 pF), rbb′ plus the emitter-side resistance (50 Ω + RE ∥ 50 Ω ≈ 98 Ω),
and finally the transistor input (rπ ∥ Cπ). The emitter moves together with the signal, so rπ (4.7 kΩ) looks
1 + gm × 47.6 Ω ≈ 2.5 times larger, 11.8 kΩ, and Cπ (127 pF) looks 1/2.5 as large, 50 pF
(gm = Ie / 26 mV ≈ 31.9 mA/V, Cπ = gm / (2π × fT)).

```vna
# NanoVNA screen (tommie-fence vna fence)
device: litevna64
sweep: 50k-100M 201
title: Fig. 6 Emitter follower input S11 (from the equivalent circuit), right edge of Smith chart at low end
dut:
  - series L 80n
  - shunt C 5p
  - shunt R 6k9
  - shunt C 3p
  - series R 98
  - shunt R 11k8
  - shunt C 50p
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1M
  - 20M
  - 50M
```

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/vna/02-emitter-follower.svg)

- At low frequencies S11 (Fig. 6) is near the right edge of the Smith chart (open). The Smith chart turns S11 into a map of impedance:
  the right edge is open (infinite impedance), the center is 50 Ω and the left edge is a short. As the frequency rises, the transistor's capacitance
  makes it swing round toward the bottom (capacitive)
- Fig. 5 and Fig. 6 are calculated, not measured. When you measure, put the VNA's Touchstone file (`.s2p`) next to this exercise's file
  and write `data: <file name>.s2p` in the fence of Fig. 6; the measured line is then overlaid as a solid line (the ideal one changes to a dashed line)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 22 kΩ |
| R2 | Resistor (1/4 W) | 10 kΩ |
| RE, RL | Resistor (1/4 W) | 1 kΩ |
| CIN, COUT | Electrolytic capacitor | 10 µF |
| Q1 | NPN transistor | 2SC1815 |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

Measure the DC voltages (base, emitter, collector) with the multimeter's DC voltage range, referenced to GND, with W1 stopped.

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| Base voltage (the R1/R2 divider point) | about 1.5 to 1.6 V | Matches the divider calculation |
| Emitter voltage | about 0.83 V | One diode drop (0.6 to 0.7 V) below the base |
| C-E voltage of Q1 | about 4.2 V | Operating stably in the active region |
| Output (across RL) with a 1 Vpp AC input | about 0.94 Vpp, in phase | The voltage passes almost unchanged and is not inverted |

## Verification with LTspice

`sim/02-emitter-follower.cir` gave the operating point and the AC gain of Fig. 1. Q1 is a substitute model for the 2SC1815 (the same IS, BF, VAF and IKF as `09-rf/sim/agc.cir`,
with a capacitance and TF added to put f<sub>T</sub> around 40 MHz (C<sub>π</sub> ≈ 125 pF). It was made from rough guides, so it is an assumption, not a measurement). S21 uses the VNA arrangement
with the source and load at 50 Ω and R<sub>L</sub> removed; the clip leads and stray capacitance are not included.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Base voltage | about 1.52 V | 1.54 V | Match |
| Emitter voltage and I<sub>E</sub> | 0.83 V, 0.83 mA | 0.90 V, 0.90 mA | Close (the model's V<sub>BE</sub> is 0.64 V; the text estimated with 0.7 V) |
| Voltage gain (1 kHz, R<sub>L</sub> = 1 kΩ) | 0.94 times | 0.94 times (−0.51 dB) | Match |
| S21 (1 MHz) | +1.5 dB | +1.7 dB | Match |
| S21 (20 MHz) | about −0.2 dB | +0.1 dB | Match |
| S21 (50 MHz) | about −2.3 dB | −2.3 dB | Match |
| S21 (100 MHz) | about −2.6 dB | −3.5 dB | The trend matches (Fig. 5 is calculated with the 80 nH lead and 5 pF stray capacitance, and differs by 1 dB) |

The emitter voltage is 0.07 V higher because of the difference in the model's V<sub>BE</sub>, which is within 10 %. On a real 2SC1815 too, V<sub>BE</sub> moves between 0.6 and 0.7 V depending on the unit and the temperature,
so read it as "about 0.8 to 0.9 V".

## Sources

Original work.
