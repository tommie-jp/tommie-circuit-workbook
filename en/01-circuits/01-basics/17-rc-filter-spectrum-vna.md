---
book: circuits
chapter: 1
id: 1-17
title: Viewing the RC Filter with the Spectrum and a VNA — Choosing an Instrument
tier: 100
source: 自作
board: BB
ja: c5bf888e79396161e0181921f0fbcbad4e960a65
---

# 1-17 Viewing the RC Filter with the Spectrum and a VNA — Choosing an Instrument

**Build 1-5 (RC low-pass and high-pass) first.** This exercise looks at the frequency response of the 1-5 filter with instruments other than the Network.
It first summarizes how to choose an instrument for each band containing f<sub>c</sub>, then looks at how the harmonics of a square wave are reduced with the Spectrum of the AD (Fig. 1 and Fig. 2),
and finally at the MHz band with a VNA (LiteVNA64) with the values changed (Fig. 3 and Fig. 4). The meaning of the Bode plot, the phase and −20 dB/decade is as in 1-5.

The Spectrum section uses the board of Fig. 6 of 1-5 as it is, and the VNA section only swaps the C on the same board and adds a way of measuring,
so the wiring diagram, the AD3 and the oscilloscope figures are not repeated (the VNA section looks at S-parameters, so the AD3 and oscilloscope figures do not apply either).

## Choosing an instrument: measure a filter around 1 kHz with the Network of the Analog Discovery

For a filter with f<sub>c</sub> around 1 kHz, the recommended order is as follows.

1. **The Network (network analyzer) of the Analog Discovery.** It sweeps 10 Hz to 100 kHz in about
   a minute and draws the gain and the phase on one graph. Its input is 1 MΩ, so it does not disturb a 1.5 kΩ circuit.
   It can measure this circuit as it is
2. **A signal generator and a 2-channel oscilloscope.** Change the frequency by hand and read the amplitude ratio of CH1 (input) and CH2 (output)
   at a few points. An oscilloscope with a function that draws a Bode plot (called Bode Plot, FRA and so on) gives the same graph as 1
3. **A phone tone generator and a multimeter.** This is enough if you only want to check the three points of "Values to check" in 1-5 roughly.
   The AC voltage range of a multimeter reads correctly only up to a few hundred Hz to a few kHz depending on the model
   (see "frequency range" in the manual). Beyond that, the fall-off looks larger than it is because of the multimeter

**A VNA and a tinySA cannot be used on this circuit.** It is outside their lower limits (50 kHz and 100 kHz), and
their input and output are 50 Ω, which crushes the output of a 1.5 kΩ circuit. A spectrum analyzer (Spectrum of the AD) can
also read the gain, but it is an instrument meant for looking at the **contents of a signal** (harmonics and noise),
and for the frequency response of a filter the Network is quicker.

Recommendation by frequency band:

| Band containing f<sub>c</sub> | Recommended | Next option | Not suitable |
| --- | --- | --- | --- |
| up to 100 kHz (audio band) | Network of the AD | Signal generator + 2-channel oscilloscope. Up to a few hundred Hz, a multimeter | VNA and tinySA (outside the lower limit) |
| 100 kHz to a few MHz | Network of the AD (at the top, around 9 MHz, the AD's own bandwidth takes effect; see 5-8 of the Analog Discovery book) | VNA. Rebuild the circuit with 50 Ω input and output (see "Viewing with a VNA" below) | Multimeter |
| a few MHz to 6.3 GHz | VNA (LiteVNA64) | tinySA and a signal source (such as CH0 of the VNA; Chapter 11 of the NanoVNA book). Above 800 MHz, the Ultra mode of the tinySA Ultra | AD (outside its bandwidth), breadboard (from several tens of MHz the parasitics of the breadboard take effect) |

How to look with the Network is in 1-5. Below, you actually look with the Spectrum and a VNA.

The values below were calculated with f<sub>c</sub> = 1 / (2π × 1.5 kΩ × 100 nF) = **1.06 kHz**
(the 1.1 kHz of 1-5 is this value rounded).

## Viewing the reduction of harmonics with a spectrum analyzer

A spectrum analyzer is an instrument that shows the size of each frequency contained in a signal.
A **square wave** contains sine waves (harmonics) at odd multiples (3 times, 5 times ...) of the fundamental frequency,
and their sizes line up as 1/n at n times the frequency (4-2 of the Analog Discovery book).
Passing it through a low-pass cuts the harmonics above f<sub>c</sub> more strongly. If you put the spectrum of the input (CH1) and
that of the output (CH2) side by side, **the difference at each harmonic is directly the gain of the filter**.

The connection is the same as in Fig. 5 and Fig. 6 of 1-5. Set W1 to a square wave and look at CH1 and CH2 with the **Spectrum** of the AD.

| Instrument | Settings |
| --- | --- |
| Wavegen | W1: Square, **500 Hz**, Amplitude 1 V, Offset 0 V, Duty 50 % |
| Spectrum | Show Channel 1 and Channel 2, **Start 0 Hz, Stop 10 kHz**, Window: Flat-top, unit: dBm |

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 1 Input (CH1), harmonics of a 500 Hz square wave
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 13dBm
signal: square 500Hz 1V
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/spectrum/17-rc-filter-spectrum-vna-1.svg)

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 2 Output (CH2), after the low-pass
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

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/spectrum/17-rc-filter-spectrum-vna-2.svg)

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

## Viewing with a VNA (change the values to the MHz band)

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
title: Fig. 3 Low-pass with the 50 Ω of the VNA as R (C1 10 nF)
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

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/17-rc-filter-spectrum-vna.svg)

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
title: Fig. 4 S21 of a one-capacitor low-pass (fc = 637 kHz)
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

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/vna/17-rc-filter-spectrum-vna.svg)

| Frequency | Low-pass S21 (calculated) | High-pass S21 (calculated) |
| --- | --- | --- |
| 50 kHz | −0.03 dB | −10.47 dB |
| 159 kHz (f<sub>c</sub> of the high-pass) | −0.26 dB | −3.01 dB |
| 637 kHz (f<sub>c</sub> of the low-pass) | −3.01 dB | −0.26 dB |
| 6.37 MHz | −20.05 dB | 0.00 dB |

Above **3 MHz**, which exceeds the rough limit for a circuit on a breadboard (3 MHz or less), the values
include the stray inductance and stray capacitance of the breadboard, and the calculated values above should be read as rough guides
(the 6.37 MHz row applies here. The effect of the parasitics grows further at several tens of MHz).

What it shows:

- f<sub>c</sub> and the −20 dB/decade slope are the same as for the circuit of Fig. 5 of 1-5; only R has been replaced by the 50 Ω of the instrument
- **When you connect an instrument, the instrument's resistance becomes part of the circuit.** This is why a 1.5 kΩ filter cannot be measured with a 50 Ω
  instrument. The CH1 and CH2 inputs of the AD are 1 MΩ, so they could be ignored in Fig. 5 of 1-5
- If you widen Stop to 30 MHz, the S21 of the low-pass bottoms out around ten-odd MHz and starts to come back.
  This is the series resonance of C1 with the inductance of the pins of C1 and the breadboard (about 10 nH),
  and beyond it the part no longer works as a capacitor (4-2 of the NanoVNA book)

## Verification with LTspice

`sim/05-rc-filter.cir` (the 1.5 kΩ + 100 nF of 1-5; Fig. 1 and Fig. 2) and `sim/17-rc-filter-vna.cir` (the 50 Ω + 10 nF of Fig. 3 and Fig. 4) were run as AC analyses.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Harmonic gain at 500 Hz, 1.5 kHz, 4.5 kHz and 9.5 kHz (difference of Fig. 1 and Fig. 2) | −0.87, −4.77, −12.78, −19.09 dB | −0.87, −4.77, −12.78, −19.09 dB | Match |
| VNA low-pass S21 at 50 kHz, 159 kHz, 637 kHz and 6.37 MHz | −0.03, −0.26, −3.01, −20.05 dB | −0.03, −0.26, −3.01, −20.05 dB | Match |
| VNA high-pass S21 at 50 kHz, 159 kHz, 637 kHz and 6.37 MHz | −10.47, −3.01, −0.26, 0.00 dB | −10.47, −3.01, −0.26, 0.00 dB | Match |

## Sources

Original work.

See also: [Low-pass filter (Wikipedia)](https://ja.wikipedia.org/wiki/ローパスフィルタ), [High-pass filter (Wikipedia)](https://ja.wikipedia.org/wiki/ハイパスフィルタ)
