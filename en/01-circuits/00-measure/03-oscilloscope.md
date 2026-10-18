---
book: circuits
chapter: 0
id: 0-3
title: Viewing Waveforms on an Oscilloscope — The 555 Output on a PC Oscilloscope or the AD3
tier: 50
source: 自作
board: BB
era: 今
ja: 321b48f6ebfc6188f1832b50f28d4afbd78584ae
---

# 0-3 Viewing Waveforms on an Oscilloscope — The 555 Output on a PC Oscilloscope or the AD3

A multimeter shows only the **size** of a voltage, but an oscilloscope shows **how the voltage changes
over time**. A voltage that changes quickly (oscillation or an audio signal) cannot be understood without an oscilloscope.
Here you use the 555 timer, an IC (integrated circuit: many transistors and other elements packed into one part),
to make a **square wave** that alternates between High (a high voltage) and Low (a low voltage).
A connection that moves between High and Low by itself as soon as the power is on is called **astable**
(how the 555 works is covered in 3-2). You view that waveform with the Scope function of a USB-connected PC oscilloscope or of the
Analog Discovery 3 (AD3, a USB instrument that combines an oscilloscope, a waveform generator and a power supply in one unit).

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Square wave from a 555 astable
parts:
  V1: vsource 2,3 2,6 5
  VCC: vcc 2,3 5V
  G1: ground 2,6
  U1: ic 10,7 NE555
  VCC: vcc 10,3 5V
  R1: resistor 6,3 6,5 10k
  VCC: vcc 6,3 5V
  R2: resistor 6,6.5 6,8.5 10k
  C1: capacitor 8,8.5 8,10.5 10n
  G2: ground 8,10.5
  G3: ground 10,10.5
  OUT: port 13,7
wires:
  - U1.VCC |- 10,3
  - U1.RESET |- 10.5,3
  - 10,3 -- 10.5,3
  - 6,5 -- 6,6.5
  - U1.DISCH -| 6,6.5
  - U1.THRES -| 8,7
  - U1.TRIG -| 8,7.5
  - 8,7 -- 8,8.5
  - 6,8.5 -- 8,8.5
  - U1.GND |- 10,10.5
  - U1.OUT -| 13,7
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/circuit/03-oscilloscope.svg)

As in Fig. 1, connecting pin 2 (TRIG) and pin 6 (THRES) of the 555 makes it astable. Pin 8 (VCC) and
pin 4 (RESET) go to the +5 V supply, and pin 1 (GND) goes to ground. Pin 5 (CONT) is not used this time and is
left floating (as the datasheet allows; if it bothers you, connect 0.01 µF to GND).

With R1 = R2 = 10 kΩ and C1 = 10 nF, the frequency and the duty ratio (the fraction of one period that the output is High) are
set by the following formulas.

- Frequency: f = 1.44 / ((R1 + 2R2) × C) = 1.44 / (30 kΩ × 10 nF) ≈ **4.8 kHz**
  (period T ≈ 208 µs, calculated value)
- High time: 0.693 × (R1 + R2) × C ≈ 139 µs
- Low time: 0.693 × R2 × C ≈ 69 µs
- Duty ratio: 139 / 208 ≈ **67 %** (calculated value. When R1 and R2 are equal, it exceeds 50 %)

With a 5 V supply, the output (pin 3) is a square wave of **about 0.2 V to about 3.5 V**.
The output stage of the 555 (NE555) drops about 1.5 V, so even High does not swing all the way up to VCC.

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building the 555 astable on a breadboard
# Top and bottom red rails = +5V, blue rails = GND (the top and bottom rails are joined at columns 28 and 29)
board: half
parts:
  U1: dip8 @ e10 NE555
  R1: resistor b6 b11 10k
  R2: resistor c11 c15 10k
  C1: capacitor/ceramic h15 h18 10n
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- +b3 red
  - AD.GND -- -b4 black
  - +t6 -- a6 red
  - +t10 -- a10 red
  - a12 -- a15 green
  - d15 -- f15 green
  - g11 -- g15 green
  - j10 -- -b10 black
  - j13 -- +b13 red
  - j18 -- -b18 black
  - j12 -- AD.1+ gray
  - AD.1- -- -b22 black
  - -t28 -- -b28 black
  - +t29 -- +b29 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/breadboard/03-oscilloscope.svg)

In Fig. 2, the 555 straddles the center gap of the breadboard. Its pins are connected through the holes of the columns they are plugged into.
Columns 10 to 13 in the upper block are pins 8 to 5, and columns 10 to 13 in the lower block are pins 1 to 4 (pin 1 is at the lower left).

- Pin 8 (column 10) gets +5 V from `+t10`, and the top end of R1 (column 6) from `+t6`, both with red wires.
  The bottom end of R1 is plugged into column 11, pin 7
- R2 runs from column 11 (pin 7) to column 15. Three green wires join pin 6 (column 12) to column 15,
  column 15 to column 15 of the lower block across the gap, and from there to pin 2 (column 11)
  (pin 6, pin 2 and the junction of R2 and C1 form one net)
- C1 runs from column 15 of the lower block to column 18. Column 18 goes to the lower blue rail (GND) with a black wire
- Pin 1 (column 10) goes to the lower blue rail with a black wire, and pin 4 (column 13) to the lower red rail with a red wire
- The power comes from Supplies on the Analog Discovery 3 (AD3). Connect V+ (red) to the lower + rail and GND (black) to the lower − rail.
  Set V+ to 5 V in the WaveForms Supplies and turn the output on. The current of the 555 is a few mA, within what the AD3 supply can deliver (up to about 50 mA per rail)
- Connect 1+ (gray) of Scope to pin 3 (column 12) and 1− (black) to the lower blue rail (GND)
- The top and bottom rails are joined by the black wire in column 28 and the red wire in column 29 at the right end, so that
  it makes no difference which rail you feed the power into

## Instrument settings

The oscilloscope screen is divided into grid squares (div) in both directions. You decide how many volts one vertical division is (the voltage range)
and how many seconds one horizontal division is (the time range), and read the screen with them.

| Item | Value |
| --- | --- |
| Coupling | DC (shows the DC component as it is) |
| Voltage range | 1 V/div (0 to about 3.5 V fits on the screen) |
| Time range | 50 µs/div (the 208 µs period is about 4 divisions) |
| Trigger | Rising edge, level about 1.5 V. The trigger takes the point where the waveform crosses this voltage from below as the reference of the screen, and holds the waveform still |

The instrument for this exercise is the Scope of the AD3 (the standard instrument for time waveforms up to 10 MHz). A 4.8 kHz waveform is within its range.
With a PC oscilloscope, set up the Scope screen of its software in the same way.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 555 pin 3, cursors read High 139 µs
time: 50us/div
trigger: ch1 rising 1.5V
ch1: {wave: pulse 4.8kHz 1.65V offset 1.85V duty 67%, range: 1V/div, position: -3div}
cursors: [0, 139us]
measure: [vpp, vmax, vmin, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/scope/03-oscilloscope.svg)

### Reading AD terminals on a general-purpose oscilloscope

This section is a correspondence table for people who use an oscilloscope other than the AD to refer back to in later chapters.
You do not need it for this experiment.
This book and the Denken Level 3 book have exercises whose wiring is written with the terminal names of the Analog Discovery (AD).
When you build them with a bench oscilloscope and a function generator (an oscillator that outputs a wave of a fixed shape),
read the terminals as follows. For the power supply and the generator, see 0-6.

| AD terminal | General-purpose instrument | Points to watch |
| --- | --- | --- |
| 1+ / 2+ | Probe tip (CH1 / CH2) | With a ×10 probe, set the oscilloscope's scale to ×10 as well |
| 1− / 2− | The probe's **ground clip** | See "The ground clip trap" below. 1− / 2− on the AD are the − inputs of a differential pair and are not necessarily GND |
| GND | Ground clip, or the outer conductor of the generator output (the BNC shell) | The GND of every general-purpose instrument is the earth terminal of the power cord and is **connected to earth** |
| Math (CH1 − CH2, C1 × C2) | The oscilloscope's Math | On models with no multiplication or averaging, calculate from the RMS and phase difference in Measure |

**The ground clip trap.** The AD inputs are differential, so you can put 1+ and 1− across a resistor
and read only that resistor's voltage (the shunt used for measuring current, common in the Denken Level 3 book).
The ground clip of a general-purpose oscilloscope is connected to earth, and the GND of the generator is connected to the same earth.
**If you clip the ground clip onto a point in the middle of a circuit, that point is shorted to the generator's GND.**
Besides changing the circuit, too much current can flow and damage parts.

- Clip the ground clip **only to the circuit's GND (the same point as the − of the generator or power supply)**
- To see the difference between two points in the middle of a circuit, put the two tips across the part and subtract with Math **CH1 − CH2**.
  If the difference is less than 20 % of the swing, it is buried in the resolution of an 8-bit oscilloscope
- To see a small difference (several tens of mV across a current-sensing shunt), **move the shunt to the GND side of the circuit**
  and measure its upper end with a single tip. The corresponding exercises in the Denken Level 3 book come with a figure
  of the circuit rebuilt that way, as "How to measure with a general-purpose oscilloscope"

## Values to check

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| Period of the waveform | about 208 µs (≈ 4.8 kHz) | If it matches the calculated value, the R and C values are correct |
| High time / Low time | about 139 µs / about 69 µs | Duty ratio about 67 % (information a multimeter cannot show) |
| Amplitude (High − Low) | about 3.3 V (0.2 V to 3.5 V) | A different value from the average (about 2.4 V) that a multimeter DC range reads |

Fig. 3 is a screen drawn from calculation: the interval between cursors X1 and X2 is the High time of 139 µs, and Measurements shows Vpp 3.30 V and Freq 4.800 kHz. A real screen looks close to this.

Read the period and the times by counting how many divisions they span on the screen and multiplying by the time range
(if the instrument has Measure or cursors, it gives the numbers directly). If you measure the same point with a multimeter, you get only
one number, close to the average of the square wave (with Low 0.2 V, High 3.5 V and a duty ratio of 67 %,
0.2 + 3.3 × 0.67 ≈ 2.4 V, calculated value). The strength of the oscilloscope is that you can see the **shape** of the waveform.

## Verification with LTspice

`sim/03-oscilloscope.cir` runs a transient analysis with the 555 of Fig. 1 replaced by an ideal behavioral model
(the thresholds of 1/3 and 2/3 V<sub>CC</sub> are represented by switches with hysteresis. The voltage drop of the output stage is not included. This is not a measurement).

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Period | about 208 µs (4.8 kHz) | 207.8 µs | Match |
| High time | about 139 µs | about 133 µs (measured from 1.7 V to 3.3 V) | Match (a difference in where the thresholds are measured. With the ideal 1.67 V to 3.33 V it is 139 µs) |
| Low time | about 69 µs | about 67 µs (same as above) | Match |
| Duty ratio | about 67 % | about 67 % | Match |
| Swing of C1 | 1/3 to 2/3 V<sub>CC</sub> | 1.67 to 3.33 V | Match |

The output High of about 3.5 V and Low of about 0.2 V are the datasheet values of the NE555 output stage and are not in the behavioral model (out of scope).

## Sources

Original work.
