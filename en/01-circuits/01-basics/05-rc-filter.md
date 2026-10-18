---
book: circuits
chapter: 1
id: 1-5
title: RC Low-Pass and High-Pass
tier: 50
source: 自作
board: BB
ja: 4a52650e42e147b433ceff32935a1901d6369eeb
---

# 1-5 RC Low-Pass and High-Pass

One resistor and one capacitor decide whether the circuit **passes only low frequencies (low-pass)** or
**passes only high frequencies (high-pass)**. Just swapping the order reverses its action. Such a circuit is called a **filter**,
and it appears again and again in later chapters for removing noise, cutting the high end of a sound, and
blocking DC to pass only AC. Here you change the frequency of a sine wave and read how many times the input the output is.

The flow of this exercise:

- First half (Schematic to Values to check): build the low-pass and the high-pass, and read the output at three frequencies
  with the oscillator and oscilloscope of the AD3 and with a multimeter (Fig. 3 and Fig. 4). This covers the aim of the exercise
- Second half, "Viewing the frequency response with instruments": ways to see the frequency response (the gain at each frequency) all at once.
  After a conclusion on choosing an instrument, it shows a Bode plot with the Network of the Analog Discovery (Fig. 5 to Fig. 7),
  how the harmonics of a square wave are reduced with a spectrum analyzer (Fig. 8 and Fig. 9), and the MHz band with a VNA (LiteVNA64) with the values changed
  (Fig. 10 and Fig. 11)

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
  - AD.W1 -- a5 yellow
  - AD.GND -- -t3 black
  - AD.1+ -- e5 orange
  - AD.1- -- -t7 black
  - AD.2+ -- e10 green
  - AD.2- -- -t12 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/05-rc-filter-1.svg)

In Fig. 3, the right end of `R1` (`c10`) and the left end of `C1` (`d10`) are connected through the same column, 10. This column is the output.
Column 13, the right end of `C1`, is dropped to the top − rail (GND) with a black wire.
The instrument for this exercise is the Analog Discovery 3 (AD3). Connect the output of the waveform generator W1 to column 5, the left end of `R1`,
and the GND of the AD3 to the top − rail. Scope 1+ goes to column 5 (input) and 2+ to column 10 (output),
and 1− and 2− are dropped to the top − rail. The GND of the oscillator and that of the oscilloscope become one at the same − rail.
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
| — | Oscillator and oscilloscope | Analog Discovery 3 (W1 and Scope) |

## Values to check

Feed in a sine wave of about 1 V amplitude from the oscillator (0-6; a tone-generator app on a phone also works), read the input (column 5) and the output (column 10)
with the multimeter's AC voltage range or with the Scope of the AD3 (the input is a sine wave without DC, so DC coupling can stay as it is), and calculate output ÷ input.
Read the input again at each frequency (depending on the oscillator, the amplitude changes a little with frequency). The table below is for the **low-pass**.

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

### Conclusion: measure a filter around 1 kHz with the Network of the Analog Discovery

For a filter with f<sub>c</sub> around 1 kHz, the recommended order is as follows.

1. **The Network (network analyzer) of the Analog Discovery.** It sweeps 10 Hz to 100 kHz in about
   a minute and draws the gain and the phase on one graph. Its input is 1 MΩ, so it does not disturb a 1.5 kΩ circuit.
   It can measure this circuit as it is
2. **An oscillator and a 2-channel oscilloscope.** Change the frequency by hand and read the amplitude ratio of CH1 (input) and CH2 (output)
   at a few points. An oscilloscope with a function that draws a Bode plot (called Bode Plot, FRA and so on) gives the same graph as 1
3. **A phone tone generator and a multimeter.** This is enough if you only want to check the three points of "Values to check" above roughly.
   The AC voltage range of a multimeter reads correctly only up to a few hundred Hz to a few kHz depending on the model
   (see "frequency range" in the manual). Beyond that, the fall-off looks larger than it is because of the multimeter

**A VNA and a tinySA cannot be used on this circuit.** It is outside their lower limits (50 kHz and 100 kHz), and
their input and output are 50 Ω, which crushes the output of a 1.5 kΩ circuit. A spectrum analyzer (Spectrum of the AD) can
also read the gain, but it is an instrument meant for looking at the **contents of a signal** (harmonics and noise),
and for the frequency response of a filter the Network is quicker.

Recommendation by frequency band:

| Band containing f<sub>c</sub> | Recommended | Next option | Not suitable |
| --- | --- | --- | --- |
| up to 100 kHz (audio band) | Network of the AD | Oscillator + 2-channel oscilloscope. Up to a few hundred Hz, a multimeter | VNA and tinySA (outside the lower limit) |
| 100 kHz to a few MHz | Network of the AD (at the top, around 9 MHz, the AD's own bandwidth takes effect; see 5-8 of the Analog Discovery book) | VNA. Rebuild the circuit with 50 Ω input and output (see "Viewing with a VNA" below) | Multimeter |
| a few MHz to 6.3 GHz | VNA (LiteVNA64) | tinySA and a signal source (such as CH0 of the VNA; Chapter 11 of the NanoVNA book). Above 800 MHz, the Ultra mode of the tinySA Ultra | AD (outside its bandwidth), breadboard (from several tens of MHz the parasitics of the breadboard take effect) |

Below, you actually look with the three instruments above (Network, Spectrum and VNA).

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
One AD takes the place of the oscillator and the oscilloscope.

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

Some general-purpose oscilloscopes also have a function that draws a Bode plot in combination with an oscillator
(called Bode Plot, frequency response analysis, FRA and so on). The meaning of the settings is the same:
put the input on CH1 and the output on CH2.

### Viewing the reduction of harmonics with a spectrum analyzer

A spectrum analyzer is an instrument that shows the size of each frequency contained in a signal.
A **square wave** contains sine waves (harmonics) at odd multiples (3 times, 5 times ...) of the fundamental frequency,
and their sizes line up as 1/n at n times the frequency (4-2 of the Analog Discovery book).
Passing it through a low-pass cuts the harmonics above f<sub>c</sub> more strongly. If you put the spectrum of the input (CH1) and
that of the output (CH2) side by side, **the difference at each harmonic is directly the gain of the filter**.

The connection is the same as in Fig. 5 and Fig. 6. Set W1 to a square wave and look at CH1 and CH2 with the **Spectrum** of the AD.

| Instrument | Settings |
| --- | --- |
| Wavegen | W1: Square, **500 Hz**, Amplitude 1 V, Offset 0 V, Duty 50 % |
| Spectrum | Show Channel 1 and Channel 2, **Start 0 Hz, Stop 10 kHz**, Window: Flat-top, unit: dBm |

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 8 Input (CH1), harmonics of a 500 Hz square wave
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 13dBm
signal: square 500Hz 1V
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/spectrum/05-rc-filter-1.svg)

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 9 Output (CH2), after the low-pass
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 13dBm
signal:
  - sine 500Hz 1151.76mV
  - sine 1.5kHz 245.09mV
  - sine 2.5kHz 99.49mV
  - sine 3.5kHz 52.77mV
  - sine 4.5kHz 32.47mV
  - sine 5.5kHz 21.93mV
  - sine 6.5kHz 15.78mV
  - sine 7.5kHz 11.89mV
  - sine 8.5kHz 9.28mV
  - sine 9.5kHz 7.44mV
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/spectrum/05-rc-filter-2.svg)

| Harmonic | Frequency | CH1 (calculated) | CH2 (calculated) | Difference = filter gain |
| --- | --- | --- | --- | --- |
| 1 (fundamental) | 500 Hz | +12.10 dBm | +11.23 dBm | −0.87 dB |
| 3 | 1.5 kHz | +2.56 dBm | −2.21 dBm | −4.77 dB |
| 9 | 4.5 kHz | −6.99 dBm | −19.77 dBm | −12.78 dB |
| 19 | 9.5 kHz | −13.48 dBm | −32.57 dBm | −19.09 dB |

What it shows:

- The difference column has the same values as the low-pass gain curve seen with the network analyzer.
  With a spectrum analyzer too, **the frequency response can be read by taking the difference between input and output**
- The input harmonics line up as 1/n (−20 dB for every factor of 10), but the output has a further
  −20 dB/decade applied above f<sub>c</sub>, so it falls off close to 1/n². In the time waveform,
  this appears as a square wave with rounded corners (the charge and discharge curve of 1-3)
- If you set W1 to **Noise** (white noise, containing about the same amount at every frequency), the spectrum of CH2 becomes
  the shape of the low-pass curve as it is. Noise varies from one capture to the next, so average
  several tens of captures in Spectrum

A sweep-type spectrum analyzer such as the tinySA has a lower limit of 100 kHz, so it cannot be used on this circuit.
With the values for the VNA below (MHz band), you can look in the same way by combining it with a signal source
(Chapter 11 of the NanoVNA book).

### Viewing with a VNA (change the values to the MHz band)

A VNA (vector network analyzer) sends a signal out of CH0 and measures the size and phase (S21) of what reaches CH1.
This book's standard model is the LiteVNA64 (50 kHz to 6.3 GHz). The historical NanoVNA-H4 can measure it by the same procedure.
There are two reasons the circuit cannot be used as it is:

- The lower limit of the sweep is **50 kHz** (LiteVNA64). f<sub>c</sub> = 1.06 kHz is outside the range
- The output of CH0 and the input of CH1 are both **50 Ω**. If the 50 Ω of CH1 is connected after the 1.5 kΩ R1,
  the output drops to almost 0

So **remove R1 and let the 50 Ω of the VNA play the part of R**. Placing a single C makes it an RC filter.

- Low-pass: place C between the signal line and GND (in parallel). The R seen from C is the 50 Ω of CH0 in parallel with the 50 Ω of
  CH1, **25 Ω**. f<sub>c</sub> = 1 / (2π × 25 Ω × 10 nF) = **637 kHz**
- High-pass: place C in series with the signal line. R is 50 Ω + 50 Ω = **100 Ω**.
  f<sub>c</sub> = 1 / (2π × 100 Ω × 10 nF) = **159 kHz**

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 10 Low-pass with the 50 Ω of the VNA as R (C1 10 nF)
parts:
  J1: sma 2,1 mirror CH0
  C1: capacitor 4,1 4,2 10n
  J2: sma 6,1 CH1
  G1: ground 2,2
  G2: ground 4,2
  G3: ground 6,2
wires:
  - J1.1 -- 4,1 -- J2.1
  - J1.2 -- 2,2
  - J2.2 -- 6,2
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/05-rc-filter-4.svg)

C1 is a 10 nF (103) ceramic capacitor. Connect it to the breadboard with two SMA-to-clip (or pin) cables,
and gather the two GNDs in the same column on the GND side of C1. For the high-pass, put C1 in series between CH0 and CH1,
and just join the GNDs of the two cables.

| Item | Value |
| --- | --- |
| Model | LiteVNA64 (the NanoVNA-H4 works the same) |
| Range | 50 kHz to 10 MHz |
| Points | 201 |
| Calibration | Take THRU at the ends of the cables (the clips). SOLT if possible (1-1 of the NanoVNA book) |
| Display | Log Mag and Phase of S21 |

```vna
# NanoVNA screen (tommie-fence vna fence)
device: litevna64
sweep: 50k-10M 201
title: Fig. 11 S21 of a one-capacitor low-pass (fc = 637 kHz)
dut:
  - shunt C 10n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 50k
  - 637k
  - 6.37M
```

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/vna/05-rc-filter.svg)

| Frequency | Low-pass S21 (calculated) | High-pass S21 (calculated) |
| --- | --- | --- |
| 50 kHz | −0.03 dB | −10.47 dB |
| 159 kHz (f<sub>c</sub> of the high-pass) | −0.26 dB | −3.01 dB |
| 637 kHz (f<sub>c</sub> of the low-pass) | −3.01 dB | −0.26 dB |
| 6.37 MHz | −20.05 dB | 0.00 dB |

Above **3 MHz**, which exceeds the rough limit for a circuit on a breadboard (3 MHz or less), the values
include the stray inductance and stray capacitance of the breadboard, and the calculated values above should be read as rough guides
(the 6.37 MHz row falls here. The effect of the parasitics grows further at several tens of MHz).

What it shows:

- f<sub>c</sub> and the −20 dB/decade slope are the same as for the circuit of Fig. 5; only R has been replaced by the 50 Ω of the instrument
- **When you connect an instrument, the instrument's resistance becomes part of the circuit.** This is why a 1.5 kΩ filter cannot be measured with a 50 Ω
  instrument. The CH1 and CH2 inputs of the AD are 1 MΩ, so they could be ignored in Fig. 5
- If you widen Stop to 30 MHz, the S21 of the low-pass bottoms out around ten-odd MHz and starts to come back.
  This is the series resonance of C1 with the inductance of the pins of C1 and the breadboard (about 10 nH),
  and beyond it the part no longer works as a capacitor (4-2 of the NanoVNA book)

## Verification with LTspice

`sim/05-rc-filter.cir` (the 1.5 kΩ + 100 nF of Fig. 1 to Fig. 9) and `sim/05b-rc-vna.cir` (the 50 Ω + 10 nF of Fig. 10 and Fig. 11) were run as AC analyses.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Low-pass gain at 10 kHz and 100 kHz | −19.53 dB, −39.49 dB | −19.53 dB, −39.49 dB | Match |
| High-pass gain at 100 Hz, 1.06 kHz and 10 kHz | −20.55 dB, −3.01 dB, −0.05 dB | −20.55 dB, −3.01 dB, −0.05 dB | Match |
| Harmonic gain at 500 Hz, 1.5 kHz, 4.5 kHz and 9.5 kHz (difference of Fig. 8 and Fig. 9) | −0.87, −4.77, −12.78, −19.09 dB | −0.87, −4.77, −12.78, −19.09 dB | Match |
| VNA low-pass S21 at 50 kHz, 159 kHz, 637 kHz and 6.37 MHz | −0.03, −0.26, −3.01, −20.05 dB | −0.03, −0.26, −3.01, −20.05 dB | Match |
| VNA high-pass S21 at 50 kHz, 159 kHz, 637 kHz and 6.37 MHz | −10.47, −3.01, −0.26, 0.00 dB | −10.47, −3.01, −0.26, 0.00 dB | Match |

## Sources

Original work.
