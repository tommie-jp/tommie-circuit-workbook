---
book: circuits
chapter: 9
id: 9-1
title: LC Tuning — Seeing Resonance with an LED
tier: 50
source: 自作
board: BB
ja: ced01a37263203586fe72a73df0e05594e6316bd
---

# 9-1 LC Tuning — Seeing Resonance with an LED

When a coil and a capacitor are connected in series, the impedance (how hard the circuit makes it for AC to flow;
the resistance and the reactance explained below taken together) becomes smallest at one frequency only.
This is **series resonance**, and its frequency f<sub>0</sub> is given by 1 / (2π√(LC)). Sweep the frequency of the
function generator and watch the LED light only near the resonance point. This is the same principle as the tuning circuit of a radio.
You also read the current in the loop with the oscilloscope and draw a **graph of current against frequency (the resonance curve)**.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 R1 voltage turns on a transistor to light the LED
parts:
  V1: sine 1,6 1,8 3
  M1: voltmeter 3,6 3,8 l=$\mathrm{CH1}$
  L1: inductor 4,6 5,6 10m
  C1: capacitor 5,6 6,6 10n
  R1: resistor 7,6 7,8 100 i=I
  M2: voltmeter 9,6 9,8 l=$\mathrm{CH2}$
  R2: resistor 10,6 11,6 10k
  VCC: vcc 12,3 5V
  R3: resistor 12,3 12,4 330
  D1: led 12,4 12,5 red
  Q1: npn 12,6 2SC1815
  G1: ground 1,8
wires:
  - 1,6 -- 3,6 -- 4,6
  - 6,6 -- 7,6 -- 9,6 -- 10,6
  - 11,6 -- Q1.B
  - 12,5 -- Q1.C
  - Q1.E -- 12,8
  - 1,8 -- 3,8 -- 7,8 -- 9,8 -- 12,8
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/01-lc-resonance.svg)

L1, C1 and R1 form one series loop. The LED is outside this loop and is lit from a separate 5 V.

- Resonant frequency f<sub>0</sub> = 1 / (2π√(10 mH × 10 nF)) **≈ 15.9 kHz**
- How much a coil or a capacitor opposes AC is called its **reactance**. A coil has
  X<sub>L</sub> = 2πfL, which grows with frequency. A capacitor has X<sub>C</sub> = 1/(2πfC), which grows as
  the frequency falls. In series the two act in opposite directions and partly cancel.
- At f<sub>0</sub>, X<sub>L</sub> and X<sub>C</sub> are equal (both about 1 kΩ) and
  cancel exactly. All that remains in the loop is R1 and the winding resistance of the coil (about 20 Ω as measured
  for a small 10 mH coil).
- Away from resonance they no longer cancel, the impedance jumps by the amount of the reactance,
  and the current falls.

**The voltage across R1 lights the LED.** The loop current I produces a voltage of I × 100 Ω across R1.

- In the positive half cycle, when this exceeds about 0.6 V, current flows into the base of Q1 and Q1 turns on
  (passes collector current). Current then flows through the LED along the path VCC (5 V) → R3 → D1 → Q1.
- The base current is limited by R2 (10 kΩ) to about 0.2 mA at most. That is under 1% of the loop current
  (17.6–24.9 mA at resonance), so the loop current hardly changes. In LTspice (a free simulator that calculates
  the voltages and currents of a circuit on a PC), the difference from the case with Q1 removed is under 0.5%.
- The LED current is set by R3. While Q1 is on it is (5 V − 1.8 V − 0.2 V) ÷ 330 Ω ≈ 9 mA
  (1.8 V is the forward voltage of the LED, and 0.2 V is the voltage left across Q1 when on).
  Q1 turns on only near the top of the positive half cycle, so the average is about 3 mA.
- In the negative half cycle the voltage across R1 pushes the base of Q1 in the reverse direction. It is at most 2.5 V
  (with a generator of ≈ 0 Ω output), which is below the 5 V emitter-base breakdown voltage of the 2SC1815.
- A MOSFET (such as the 2N7000) draws no gate current, so its effect on the loop would be even smaller.
  However, the gate threshold voltage varies from 0.8 to 3 V, and the voltage across R1 is only about 1.8 V even at resonance
  (with a 50 Ω output), so some individual parts would not turn on. Every bipolar transistor
  turns on at about 0.6 V, so this circuit uses one.

**The LED is not put inside the loop.** An LED in series with the loop still lights, but it disturbs the resonance.
The LED passes no current until about 1.8 V is exceeded, so it chops the loop current into narrow peaks, one per half cycle.
LTspice shows that with two LEDs in opposite directions in the loop, the current at f<sub>0</sub> falls
from 17.6 mA to 4.5 mA and the resonance curve is no longer symmetric (2.3 mA at 8 kHz, 1.2 mA at 32 kHz).
With just one LED, C1 is charged to one side by the current the LED passes, and within a few cycles it
holds the LED in reverse and the LED goes out. To separate the job of lighting from the job of resonating, the LED stays outside the loop.

**R1 goes on the GND side.** The GND clip of an oscilloscope probe can only be attached to GND.
With the lower end of R1 at GND, measuring the voltage at the upper end of R1 with CH2 is enough to find
the loop current as I = V<sub>R1</sub> / 100 Ω. CH1 watches the generator output.

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Lighting the LED with a transistor
board: half
parts:
  L1: inductor/axial d3 d8 10m
  C1: capacitor/ceramic b8 b10 10n
  R1: resistor d10 d14 100
  R2: resistor i10 i15 10k
  Q1: transistor g15(B) g16(C) g17(E) 2SC1815
  D1: led c17(A) c16(K) red
  R3: resistor b17 b21 330
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, GND, 1-, 2-, V+]
wires:
  - AD.W1 -- b3 yellow
  - AD.1+ -- a3 orange
  - AD.2+ -- a10 blue [h13]
  - AD.1- -- -t12 black
  - AD.2- -- -t13 black
  - AD.GND -- -t11 black
  - a14 -- -t14 black
  - e10 -- f10 blue
  - f16 -- e16 green
  - a21 -- +t21 red
  - j17 -- -b17 black
  - AD.V+ -- +t17 red
  - -t29 -- -b29 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/breadboard/01-lc-resonance.svg)

- W1 (Wavegen) of the AD3 is V1 in Fig. 1. It outputs a sine wave, and you move the frequency between 2 kHz and 32 kHz (details in the parts list). The oscilloscope uses 1 (CH1) and 2 (CH2) of Scope.
- The upper half is the resonant loop. Column 3 collects W1 (b3), 1+ of CH1 (a3) and the left pin of L1.
  Column 10 collects C1, R1 and CH2 (a10). The right end of R1 (column 14) goes to the top − rail.
- The loop voltage at column 10 is carried to the lower half by the blue wire and goes through R2 to the base of Q1 (column 15).
  Seen with its flat face toward you, the 2SC1815 has E, C, B from the left. To insert it as in the figure, with B, C, E from the left,
  turn the flat face toward the back (the f-row side).
- The collector (column 16) returns to the upper half through the green wire and connects to the cathode of D1.
  From the anode of D1 (column 17), go through R3 to the top + rail (5 V).
- The emitter (column 17 of the lower half) goes to the bottom − rail. The top − rail (GND, 1− and 2− of the AD3) and
  the bottom − rail are joined by the black wire at column 29. Only V+ (5 V) of the AD3 goes to the top + rail.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| V1 | Signal generator (Wavegen W1 of the AD3; output about 0 Ω) | Sine wave, 6 Vpp (the 3 V in Fig. 1 is the peak), 2 kHz to 32 kHz, output resistance of W1 on the AD3 ≈ 0 Ω (a generator with a 50 Ω output also works; values for both are the 2 columns in the "Values to check" table) |
| L1 | Inductor (axial) | 10 mH |
| C1 | Ceramic capacitor | 10 nF (103), 50 V rating |
| R1 | Resistor (1/4 W) | 100 Ω |
| R2 | Resistor (1/4 W) | 10 kΩ |
| R3 | Resistor (1/4 W) | 330 Ω |
| D1 | Red LED | 1 piece |
| Q1 | NPN transistor | 2SC1815 |
| VCC | Power supply | 5 V (V+ of the Supplies on the AD3). GND is shared with W1 and the Scope GND |

## Instrument settings

The instrument is the Analog Discovery 3 (AD3). One unit provides the signal source (Wavegen), the oscilloscope (Scope) and 5 V (Supplies), and the waveforms at 2–32 kHz are within the range of the Scope.

Generator:

| Item | Value |
| --- | --- |
| Waveform | Sine wave |
| Amplitude | 3 V<sub>peak</sub> (6 Vpp), offset 0 V |
| Frequency | 2 kHz to 32 kHz (set to each frequency in the table below in turn) |

Oscilloscope:

| Item | Value |
| --- | --- |
| Coupling | DC on both CH1 and CH2 |
| Voltage range | CH1 2 V/div, CH2 1 V/div (3.5–5.0 Vpp at the resonance point fills 3.5–5 divisions) |
| Time range | 20 µs/div (one period of 15.9 kHz, 63 µs, is about 3 divisions). When you change the frequency, adjust it again so that 2–3 periods are visible |
| Trigger | CH1, rising edge, level 0 V |
| Measurement | Vpp of CH2 (use the automatic measurement if available) |

On the AD3, set these with Wavegen (W1), Scope and Supplies (V+ = 5 V) in WaveForms. A PC oscilloscope works with the same settings. The 5 V current that lights the LED (about 3–9 mA) fits within about 50 mA for one supply rail of the AD3.
Away from resonance CH2 shrinks to about 0.1 Vpp, so lower the CH2 range if it is hard to read.

## Values to check

Read the Vpp of CH2 at each frequency and convert it to the peak current.

I<sub>peak</sub> = (Vpp of CH2 ÷ 2) ÷ 100 Ω (example: 3.52 Vpp → 17.6 mA)

These are LTspice simulation values. The LED is red (forward voltage about 1.8 V), and the winding resistance of the coil is 20 Ω.
Many function generators have a 50 Ω resistor at the output, and it adds in series with the loop.
The values for a generator with an output resistance of nearly 0 Ω (such as W1 on the AD3) are also listed. The LED current is the average with a 50 Ω output.

| Frequency | CH2 (50 Ω output) | I<sub>peak</sub> (50 Ω output) | Average LED current | CH2 (≈ 0 Ω output) | I<sub>peak</sub> (≈ 0 Ω output) | Measured CH2 | Measured I<sub>peak</sub> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2 kHz | 0.08 Vpp | 0.38 mA | 0 | 0.08 Vpp | 0.38 mA | | |
| 5 kHz | 0.21 Vpp | 1.0 mA | 0 | 0.21 Vpp | 1.0 mA | | |
| 8 kHz | 0.40 Vpp | 2.0 mA | 0 | 0.40 Vpp | 2.0 mA | | |
| 10 kHz | 0.61 Vpp | 3.1 mA | 0 | 0.62 Vpp | 3.1 mA | | |
| 12 kHz | 1.01 Vpp | 5.0 mA | 0 | 1.03 Vpp | 5.1 mA | | |
| 13 kHz | 1.36 Vpp | 6.8 mA | 0.03 mA | 1.41 Vpp | 7.1 mA | | |
| 14 kHz | 1.95 Vpp | 9.7 mA | 1.1 mA | 2.11 Vpp | 10.6 mA | | |
| 15 kHz | 2.89 Vpp | 14.4 mA | 2.7 mA | 3.55 Vpp | 17.7 mA | | |
| **15.9 kHz (f<sub>0</sub>)** | **3.52 Vpp** | **17.6 mA** | **3.1 mA** | **4.99 Vpp** | **24.9 mA** | | |
| 17 kHz | 2.78 Vpp | 13.9 mA | 2.6 mA | 3.36 Vpp | 16.7 mA | | |
| 18 kHz | 2.00 Vpp | 10.0 mA | 1.2 mA | 2.18 Vpp | 10.9 mA | | |
| 20 kHz | 1.22 Vpp | 6.1 mA | 0 | 1.26 Vpp | 6.3 mA | | |
| 25 kHz | 0.63 Vpp | 3.2 mA | 0 | 0.64 Vpp | 3.2 mA | | |
| 32 kHz | 0.39 Vpp | 2.0 mA | 0 | 0.40 Vpp | 2.0 mA | | |

- **The current is largest at f<sub>0</sub>.** The only resistance left in the loop is R1, the winding, and the 50 Ω output of the generator, 170 Ω in total.
  The sharpness of the peak is expressed by a number Q. For series resonance Q = (1/R) × √(L/C), where R is the total resistance in the loop.
  Q = (1/170 Ω) × √(10 mH / 10 nF) = 1000 Ω / 170 Ω ≈ 5.9 (with ≈ 0 Ω output the total is 120 Ω and Q ≈ 8.3)
- **The LED lights only between 14 and 18 kHz.** Q1 does not turn on until the voltage across R1 exceeds about 0.6 V,
  so the LED shows only a slice near the top of the peak. The brightness does not tell you how sharp the peak is,
  so read the shape of the peak from CH2.
- **At resonance, about Q times the generator voltage appears across C1.** The reactance of C1 at 15.9 kHz is
  about 1 kΩ, so 17.6 mA × 1 kΩ ≈ 17.6 V<sub>peak</sub> (about 25 V<sub>peak</sub> with ≈ 0 Ω output).
  This is far larger than the 3 V<sub>peak</sub> of the generator. Use a ceramic capacitor rated 50 V for C1.

### Drawing the graph

Plot the measured I<sub>peak</sub> with frequency on the horizontal axis and current on the vertical axis
(the frequency spans a 16-fold range from 2 kHz to 32 kHz, so semi-log paper with a logarithmic horizontal axis is easier to read).
You should get a peak (the resonance curve) with its top at f<sub>0</sub> = 15.9 kHz.

The resonance curve you should see (the simulation values in the table above). The horizontal axis is frequency (logarithmic).

```graph
# Graph (tommie-fence graph fence)
title: Fig. 3 Resonance curve, peak at 15.9kHz, higher for a lower output resistance
x: Frequency Hz log 2k..32k
y: Current mA
lines:
  50Ω output mA:
    - 2k 0.38
    - 5k 1.0
    - 8k 2.0
    - 10k 3.1
    - 12k 5.0
    - 13k 6.8
    - 14k 9.7
    - 15k 14.4
    - 15.9k 17.6
    - 17k 13.9
    - 18k 10.0
    - 20k 6.1
    - 25k 3.2
    - 32k 2.0
  ≈0Ω output mA:
    - 2k 0.38
    - 5k 1.0
    - 8k 2.0
    - 10k 3.1
    - 12k 5.1
    - 13k 7.1
    - 14k 10.6
    - 15k 17.7
    - 15.9k 24.9
    - 17k 16.7
    - 18k 10.9
    - 20k 6.3
    - 25k 3.2
    - 32k 2.0
notes:
  - band 14k 18k: LED lit
  - mark 8k
  - mark 15.9k
  - mark 32k
```

![Graph](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/graph/01-lc-resonance.svg)

Plot the measured I<sub>peak</sub> as points on graph paper with the same axes and compare with these 2 curves.

- If the frequency of the peak is off from the calculated 15.9 kHz, the actual values of L1 and C1 are off
  (f<sub>0</sub> is inversely proportional to √(LC), so if L and C are both 10% larger, f<sub>0</sub> becomes 1/1.1 times, about 9% lower).
- With a logarithmic horizontal axis the peak is symmetric. At f<sub>0</sub>/2 = 8 kHz and 2f<sub>0</sub> = 32 kHz the current is 2.0 mA in both cases.
- Overlaying the 50 Ω output and ≈ 0 Ω output columns of the table (Fig. 3) shows the difference in Q.
  The skirts (below 12 kHz and above 20 kHz) are almost the same, and only the top differs, 17.6 mA against 24.9 mA.
  The 50 Ω of the generator also counts as resistance in the loop, so the peak is lower and flatter by that amount.
- The sharpness of the peak (the height of Q) increases as the loop resistance decreases. If you replace R1 with 47 Ω,
  the current at f<sub>0</sub> rises from 17.6 mA to 25.6 mA, but it hardly changes at 12 kHz (5.0 → 5.1 mA) and 20 kHz (6.1 → 6.3 mA)
  (simulation values with a 50 Ω output. Read the current as Vpp of CH2 ÷ 2 ÷ 47 Ω, and
  set CH2 to 0.5 V/div). The voltage across R1 is about 1.2 V<sub>peak</sub> at resonance, so Q1 turns on and the LED lights.
- Use 47 Ω for R1 only with a generator of 50 Ω output. With a generator of ≈ 0 Ω output,
  the current at f<sub>0</sub> would be about 45 mA, above the 30 mA that the Wavegen of the Analog Discovery 3 can output without distortion.
  The voltage across C1 would also be about 45 V<sub>peak</sub>, close to the 50 V rating.

### Looking at the waveform shape too

The screen seen with a generator of 50 Ω output. CH1 is the generator output, and CH2 is the voltage across R1 (loop current × 100 Ω).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 4 Resonance (15.9kHz), CH2 peaks and is in phase with CH1
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 15.9kHz 4.23Vpp, range: 2V/div}
ch2: {wave: sine 15.9kHz 3.52Vpp, range: 1V/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/01-lc-resonance-1.svg)

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 5 Below resonance (12kHz), CH2 drops to 1.01Vpp, leads CH1
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 12kHz 5.88Vpp, range: 2V/div}
ch2: {wave: sine 12kHz 1.01Vpp phase 78deg, range: 200mV/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/01-lc-resonance-2.svg)

- **CH2 is a clean sine wave at every frequency.** The loop contains only L1, C1 and R1,
  so the current has the same shape as the generator voltage.
- **At the resonance point CH1 and CH2 are in phase (Fig. 4).** The reactances of L1 and C1 cancel,
  and the loop looks like a resistor alone.
- **Below resonance CH2 leads CH1 (Fig. 5, about 78°).** The reactance of C1 wins, and the loop behaves like a capacitor.
  Above resonance the coil wins instead and CH2 lags (about 75° of lag at 20 kHz).
  Read the phase from Phase in Measurements, or as the time difference between the peaks of the two waves ÷ the period × 360°.
- With a generator of 50 Ω output, the amplitude of CH1 drops at the resonance point (6.0 → about 4.2 Vpp, Fig. 4).
  The larger current drops voltage across the 50 Ω inside the generator. With a generator of ≈ 0 Ω output it does not drop.
- In Fig. 5, CH2 is lowered to 200 mV/div, so it looks larger than CH1 on the screen. At 1 V/div it would be
  only about one division. Compare sizes by the Vpp readings, not by the divisions.

## Verification with LTspice

**Checking the calculation (LTspice)**: The values in the table above were checked by running `sim/01-lc-resonance.cir` again as a transient analysis (30 periods; the Vpp of CH2 and the average current in R3 are read over the last 2 periods).
It includes everything in Fig. 1: L1 (10 mH, winding 20 Ω), C1, R1, R2, R3, D1 and Q1. Q1 is a substitute model for the 2SC1815
(the same as in `sim/agc.cir`; an assumption made from typical values, not measured), and the red LED is a provisional diode that gives about 1.8 V at 3 mA.
The Vpp of CH2 agreed with the table within 0.03 V at all 14 frequencies × 2 output resistances (example: at 15.9 kHz, 3.52 Vpp with a 50 Ω output and 4.99 Vpp with ≈ 0 Ω; 0.077 Vpp at 2 kHz and 0.39 Vpp at 32 kHz).
The average LED current (50 Ω output) also flows only between 14 and 18 kHz: 1.2 mA at 14 kHz, 2.6 mA at 15 kHz, 3.0 mA at 15.9 kHz, 2.5 mA at 17 kHz and 1.3 mA at 18 kHz,
which agrees with the table (1.1, 2.7, 3.1, 2.6 and 1.2 mA) to about 0.1 mA. 13 kHz (0.11 mA; the table has 0.03 mA) and 20 kHz (0.02 mA; the table has 0)
are at the border between turning on and not, where the result is sensitive to the provisional LED model, so look only at the order of magnitude.
Verdict: agrees (the text is not changed).
The Q values 5.9 and 8.3 and the 17.6 V across C1 are calculated from the formulas; the simulation was not run for them.

## Sources

Original work.
