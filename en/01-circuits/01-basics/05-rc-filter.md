---
book: circuits
chapter: 1
id: 1-5
title: RC Low-Pass and High-Pass
tier: 50
source: 自作
board: BB
ja: 20f26be92666d7f3df3a26caba09cd21df5596f5
---

# 1-5 RC Low-Pass and High-Pass

One resistor and one capacitor decide whether the circuit **passes only low frequencies (low-pass)** or
**passes only high frequencies (high-pass)**. Just swapping the order reverses its action. Such a circuit is called a **filter**,
and it appears again and again in later chapters for removing noise, cutting the high end of a sound, and
blocking DC to pass only AC. Here you change the frequency of a sine wave and read how many times the input the output is.

The flow of this exercise:

- First half (Schematic to Values to check): build the low-pass and the high-pass, and read the output at three frequencies
  with the signal generator and oscilloscope of the AD3 and with a multimeter (Fig. 3 and Fig. 4). This covers the aim of the exercise
- Second half, "Viewing the frequency response with instruments": see the frequency response (the gain at each frequency) all at once
  as a Bode plot with the Network of the Analog Discovery (Fig. 5 to Fig. 7)

How to choose an instrument for each band, and how to look with a spectrum analyzer (the reduction of harmonics) and with a VNA (the MHz band with the values changed), are split off into 1-17.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 RC low-pass
parts:
  IN: port 1,1
  R1: resistor 1,1 2,1 1.5k
  C1: capacitor 2,1 2,2 100n
  OUT: port 3,1
  G1: ground 2,2
wires:
  - 2,1 -- 3,1
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/05-rc-filter-1.svg)

Taking the output **across the capacitor**, as in Fig. 1, gives a low-pass. A capacitor passes
current more easily the higher the frequency (it passes almost none at low frequencies). So high frequencies
escape to GND through the capacitor and are weakened, while low frequencies come out as they are.

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 2 RC high-pass
parts:
  IN: port 1,1
  C2: capacitor 1,1 2,1 100n
  R2: resistor 2,1 2,2 1.5k
  OUT: port 3,1
  G2: ground 2,2
wires:
  - 2,1 -- 3,1
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/05-rc-filter-2.svg)

**Swapping the order** of the capacitor and the resistor and taking the output **across the resistor**, as in Fig. 2, gives a high-pass.
Low frequencies are blocked by the capacitor and weakened, and high frequencies come out as they are.

- Cutoff frequency (the frequency that marks roughly where the filter starts to act): f<sub>c</sub> = 1 / (2π × R × C) = 1 / (2π × 1.5 kΩ × 100 nF)
  ≈ **1.1 kHz** (calculated value. The same formula for the low-pass and the high-pass)
- At f<sub>c</sub>, the output is 1/√2 ≈ **70.7%** of the input (−3 dB)
- The ratio output ÷ input is called the **gain**, and it is often expressed in **dB** (decibels). For a voltage ratio A it is
  20 × log<sub>10</sub>A [dB]: 1 times is 0 dB, 0.707 times is −3 dB, 0.1 times is −20 dB and 0.01 times is −40 dB

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 3 RC low-pass with the AD3 W1 and Scope connected
board: half
parts:
  R1: resistor c5 c10 1.5k
  C1: capacitor/ceramic d10 d13 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (W1, Scope)
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - a13 -- -t13 black
  - AD.W1 -- a5 yellow [h23, v106]
  - AD.GND -- -t3 black
  - AD.1+ -- b5 orange [h-7, v126]
  - AD.1- -- -t7 black
  - AD.2+ -- a10 green
  - AD.2- -- -t12 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/05-rc-filter-1.svg)

In Fig. 3, the right end of `R1` (`c10`) and the left end of `C1` (`d10`) are connected through the same column, 10. This column is the output.
Column 13, the right end of `C1`, is dropped to the top − rail (GND) with a black wire.
The instrument for this exercise is the Analog Discovery 3 (AD3). Connect the output of the waveform generator W1 to column 5, the left end of `R1`,
and the GND of the AD3 to the top − rail. Scope 1+ goes to column 5 (input) and 2+ to column 10 (output),
and 1− and 2− are dropped to the top − rail. The GND of the signal generator and that of the oscilloscope become one at the same − rail.
The output of W1 is 100 µA or less, well within what the breadboard can take.
When reading with a multimeter, touch the black lead to the − rail and the red lead
in turn to column 5 (input) and column 10 (output).

To make a high-pass, swap `R1` and `C1` (input → C → R → GND) and
take the output from the top end of R.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 (R2) | Resistor (1/4 W) | 1.5 kΩ |
| C1 (C2) | Ceramic capacitor | 100 nF (0.1 µF) |
| — | Signal generator and oscilloscope | Analog Discovery 3 (W1 and Scope) |

## Values to check

Feed in a sine wave of about 1 V amplitude from the signal generator (0-6; a tone-generator app on a phone also works), read the input (column 5) and the output (column 10)
with the multimeter's AC voltage range or with the Scope of the AD3 (the input is a sine wave without DC, so DC coupling can stay as it is), and calculate output ÷ input.
Read the input again at each frequency (depending on the signal generator, the amplitude changes a little with frequency). The table below is for the **low-pass**.

| Input frequency | Expected output (input = 1) | What it tells you |
| --- | --- | --- |
| 100 Hz (1/10 of f<sub>c</sub> or less) | about 1.0 times (passes almost straight through) | Low frequencies pass as they are |
| 1.1 kHz (f<sub>c</sub>) | about 0.71 times (−3 dB, calculated value) | This is the rough point where the filter "starts to act" |
| 11 kHz (10 times f<sub>c</sub>) | about 0.10 times (−20 dB, calculated value) | The higher the frequency, the more it is weakened |

The **high-pass** is the opposite (weak at 100 Hz, passes well at 11 kHz).

### Viewing the waveform at f<sub>c</sub> on the oscilloscope

Set W1 to a **1.06 kHz** sine wave of 1 V amplitude (the calculated f<sub>c</sub> is 1/(2π×1.5 kΩ×100 nF) = 1061 Hz), and overlay Scope 1+ (input) and 2+ (output) at the same 500 mV/div
and a time range of 200 µs/div. The low-pass output (CH2 in the figure) has an amplitude of 1/√2 = **0.707 times** the input (CH1) and a phase **delayed by 45 degrees** (1/8 of the 943 µs period = 118 µs).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 4 Low-pass at fc (1.06 kHz), CH2 is 0.707 of CH1
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.06kHz 1V, range: 500mV/div, position: 0div}
ch2: {wave: ch1 | rc 150us, range: 500mV/div, position: 0div}
measure: [vpp, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/scope/05-rc-filter.svg)

The readings are Vpp 2.00 V for CH1 and Vpp 1.41 V for CH2 (both at 1.06 kHz). The ratio is 0.707, which matches the f<sub>c</sub> row of the table in Values to check.

## Viewing the frequency response with instruments

The table above was read by changing the frequency one value at a time. If you let an instrument **sweep** the frequency (change it automatically in small steps),
you can see the gain and the phase as functions of frequency on one graph (a **Bode plot**). The **phase** is
the angle, with one period taken as 360°, by which the peaks of the output wave are shifted from the peaks of the input
(a delay is −, an advance is +). This section is for people who have an instrument such as the Analog Discovery.

For a filter with f<sub>c</sub> around 1 kHz, measuring with the Network of the Analog Discovery is best (choosing an instrument is in 1-17).
The values below were calculated with f<sub>c</sub> = 1 / (2π × 1.5 kΩ × 100 nF) = **1.06 kHz**
(the 1.1 kHz above is this value rounded).

### Viewing a Bode plot with the network analyzer

The **Network** of the Analog Discovery (AD) changes the frequency of the W1 sine wave automatically,
measures the gain and phase of CH2 (output) with respect to CH1 (input), and draws a graph.
For detailed operation, see 5-1 (low-pass) and 5-2 (high-pass) of the Analog Discovery book.

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 5 Sweeping with W1, comparing CH1 and CH2
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 4,1 6,1 1.5k
  C1: capacitor 6,1 6,3 100n
  M2: voltmeter 8,1 8,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 4,1
  - 1,3 -- 3,3 -- 6,3 -- 8,3
  - 6,1 -- 8,1
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/05-rc-filter-3.svg)

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 6 Connecting the Analog Discovery to the Fig. 3 circuit
board: half
parts:
  R1: resistor c5 c10 1.5k
  C1: capacitor/ceramic d10 d13 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, W1, 1-, 2+, 2-]
wires:
  - a13 -- -t13 black
  - AD.GND -- -t3 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a5 orange
  - AD.1- -- -t7 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/05-rc-filter-2.svg)

The parts are plugged in as in Fig. 3. Plug W1 (yellow) and 1+ (orange) of CH1 into column 5, the input, and 2+ (blue) of CH2 into
column 10, the output. Drop the GND of the AD and the − sides of CH1 and CH2 (1− and 2−) to the top − rail.
One AD takes the place of the signal generator and the oscilloscope.

| Instrument | Settings |
| --- | --- |
| Wavegen | W1: Amplitude 1 V, Offset 0 V (Network moves the frequency) |
| Network | Start 10 Hz, Stop 100 kHz, **Log**, Steps 101, Reference: Channel 1, display: gain (dB) and phase (deg) |

| Frequency | Low-pass gain and phase (calculated) | High-pass gain and phase (calculated) |
| --- | --- | --- |
| 100 Hz | −0.04 dB, −5.4° | −20.55 dB, +84.6° |
| 1.06 kHz (f<sub>c</sub>) | −3.01 dB, −45.0° | −3.01 dB, +45.0° |
| 10 kHz | −19.53 dB, −83.9° | −0.05 dB, +6.1° |
| 100 kHz | −39.49 dB, −89.4° | 0.00 dB, +0.6° |

What it shows:

- **Above f<sub>c</sub> the gain falls by about 20 dB for every factor of 10** (−20 dB/decade).
  Check with the cursors that the difference between 10 kHz and 100 kHz is about 20 dB
- **The frequency where the gain is −3 dB is the same as the frequency where the phase is ±45°.** Find the −3 dB point with the cursors
  and see that its frequency is near 1.06 kHz (±5 to 10 % because of part tolerances)
- With the high-pass (the arrangement of Fig. 2), the gain graph is flipped left to right and the sign of the phase becomes +

The Bode plot that Network should show (calculated values). The top is the gain and the bottom is the phase, with the same frequency (log) on the horizontal axis.

```graph
# Graph (tommie-fence graph fence)
title: Fig. 7 Bode plot from Network, −45° where the gain is −3 dB
x: Frequency Hz log 10..100k
y:
  - Gain dB
  - Phase deg
lines:
  Gain dB: 20*log10(1/sqrt(1+(x/1.06k)^2))
  Phase deg: -deg(atan(x/1.06k))
notes:
  - level -3dB
  - mark 100
  - mark 1.06k
  - mark 10k
  - mark 100k
```

![Graph](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/graph/05-rc-filter.svg)

Fig. 7 was written with the graph fence. The four frequencies of the marks are the same as the four rows of the table above,
and the readings under the figure are the same numbers as the table.

Some general-purpose oscilloscopes also have a function that draws a Bode plot in combination with a signal generator
(called Bode Plot, frequency response analysis, FRA and so on). The meaning of the settings is the same:
put the input on CH1 and the output on CH2.

## Verification with LTspice

`sim/05-rc-filter.cir` (the 1.5 kΩ + 100 nF of Fig. 1 to Fig. 7) was run as an AC analysis.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Low-pass gain at 10 kHz and 100 kHz | −19.53 dB, −39.49 dB | −19.53 dB, −39.49 dB | Match |
| High-pass gain at 100 Hz, 1.06 kHz and 10 kHz | −20.55 dB, −3.01 dB, −0.05 dB | −20.55 dB, −3.01 dB, −0.05 dB | Match |

## Sources

Original work.

See also: [Low-pass filter (Wikipedia)](https://ja.wikipedia.org/wiki/ローパスフィルタ), [High-pass filter (Wikipedia)](https://ja.wikipedia.org/wiki/ハイパスフィルタ)
