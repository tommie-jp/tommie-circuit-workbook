---
book: circuits
chapter: 4
id: 4-2
title: Non-inverting amplifier
tier: 50
source: 自作
board: BB
ja: 0b8732b205d865c216af5fc2cca972ca9f2cf63f
---

# 4-2 Non-inverting amplifier

Put the signal on the + input, divide the output with two resistors and return it to the − input (negative feedback; seen in 4-1), and the signal is
**amplified without inversion**. The gain is 1 + R3/R2, set by the two resistors alone. This is the second of the basic op amp circuits.
In this exercise you feed in a 1 kHz sine wave and check that the output is 11 times as large and in the same direction.

The op amp moves its output so that the + input equals the − input. The voltage at the − input is the output divided by R3 and R2,
so output × R2/(R2+R3) = input. Solving this gives output = input × (1 + R3/R2).

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Non-inverting amplifier
parts:
  VP: vsource 1,1 1,3 5
  VN: vsource 1,3 1,5 5
  G1: ground 2,3
  V1: sine 4,2 4,4 0.1
  G2: ground 4,4
  C1: capacitor 4,2 6,2 1u
  Rb: resistor 6,2 6,4 100k
  G3: ground 6,4
  U1: opamp 9,2 +up
  R2: resistor 8,4 8,6 1k
  G4: ground 8,6
  R3: resistor 9,4 11,4 10k
  OUT: port 13,2
wires:
  - mid -- 2,3
  - 6,2 |- U1.+
  - 8,4 |- U1.-
  - 8,4 -- 9,4
  - U1.out -- 12,2 -- 13,2
  - 11,4 -- 12,4 -- 12,2
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/circuit/02-non-inverting-amp.svg)

- VP and VN on the left are the ±5 V supply of the op amp. They are made with V+ and V− of the AD3 Supplies, as in 4-1
- V1 is a signal generator of 1 kHz and 0.1 V amplitude (the height from 0 V to the peak; 0.2 Vpp from peak to trough). C1 (1 µF) blocks DC (passes AC only), and Rb (100 kΩ) sets
  the DC potential of the non-inverting input to GND (the midpoint of VP and VN)
- **Gain = 1 + R3/R2 = 1 + 10k/1k = 11 times.** The output amplitude is 0.1 V × 11 = 1.1 V
- The larger Rb is, the higher the input impedance. But if it is too large, the input bias current of the op amp
  (the small DC current that flows into the input) causes an error (the LM358 draws tens of nA, so 100 kΩ is no problem)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# The top rails are +5V (red) and GND (blue). The bottom blue rail is −5V (V−). The bottom red rail is not used
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V, W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1-, 2-, 2+, 1+]
  U1: dip8 @ e10 LM358
  C1: capacitor c15 c19 1uF
  Rb: resistor a15 -t15 100k
  R3: resistor g10 g11 10k
  R2: resistor i11 i7 1k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a19 yellow
  - SC.1+ -- j12 orange
  - SC.2+ -- j10 green
  - SC.1- -- h7 black
  - SC.2- -- j7 black
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - e15 -- f15 orange
  - g15 -- g12 orange
  - f7 -- e7 black
  - a7 -- -t7 black
notes:
  - text below: Top red +5V, top blue GND, bottom blue −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/02-non-inverting-amp.svg)

- In Fig. 2, the AD3 Supplies (V+, V−) correspond to VP and VN of Fig. 1, and W1 corresponds to V1 (the signal generator).
  The rails are used as in 4-1 (the bottom blue rail is −5 V, not GND).
  The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (orange) goes to column 12, IN+ (`j12`), and 2+ (green) goes to column 10, the output (`j10`). 1− and 2− (black) go to column 7, the GND side of R2 (`h7` and `j7`; column 7 is connected to the top blue rail)
- **C1 receives the W1 signal (column 19). From column 15, a wire across the trench and `g15--g12` take it to IN+ (pin 3, column 12).**
  Rb is a bias resistor standing from hole a of column 15 up to the top blue rail (GND). It lets only DC escape to GND
- R3 (feedback) joins the output (pin 1, column 10) and IN− (pin 2, column 11). R2 goes from column 11 to column 7,
  and from column 7 a black wire across the trench and `a7--(-t7)` take it down to GND
- Pin 8 (column 10) goes to +5 V with `+t10--a10`, and pin 4 (column 13) goes to −5 V with `j13--(-b13)`

## Instrument settings

Use the Scope of the Analog Discovery 3 (AD3) as the oscilloscope. This exercise shows the shape, amplitude and direction of a 1 kHz sine wave, far lower than 10 MHz.
Set W1 to a 1 kHz sine wave of 0.1 V amplitude (offset 0 V). On the Scope, use CH1 for the input and CH2 for the output, and trigger on the rising edge of CH1 at 0 V.

| Setting | Value |
| --- | --- |
| Wavegen W1 | Sine, 1 kHz, amplitude 0.1 V, offset 0 V |
| Scope CH1 (input, column 12) | DC, 500 mV/div |
| Scope CH2 (output, column 10) | DC, 500 mV/div |
| Time | 200 µs/div (2 periods of 1 kHz) |
| Trigger | CH1, rising edge, 0 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 CH2 is 11 times CH1, in the same direction
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1.1V, range: 500mV/div}
measure: [vpp, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/scope/02-non-inverting-amp.svg)

In Fig. 3 both traces are at 500 mV/div. CH1 (input) is a small wave of 0.2 Vpp (0.4 division), and CH2 (output) is 2.2 Vpp (4.4 divisions), 11 times as tall.
The peaks and troughs come at the same times, so the direction is not inverted. If the input is too small to read, switch only CH1 to 50 mV/div to see its shape.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Op amp (one of two in the package) | LM358 |
| C1 | Ceramic capacitor (DC block) | 1 µF |
| Rb | Resistor (bias of the + input) | 100 kΩ |
| R2 | Resistor | 1 kΩ |
| R3 | Resistor (feedback) | 10 kΩ |
| — | Signal source | 1 kHz, amplitude 0.1 V |
| — | Power supply | ±5 V (AD3 Supplies; V+ = +5 V, V− = −5 V) |
| — | Instrument | AD3 W1 (signal source) and Scope 1+/2+ (input and output) |

## Values to check

The signal generator is W1 of the AD3 (a 1 kHz sine wave of 0.1 V amplitude). Connect CH1 of the oscilloscope to the input (column 12) and
CH2 to the output (column 10), and compare the amplitude and direction of the two overlaid traces (Fig. 3). The values in the table are calculated. The gain is A = 1 + R3/R2.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Input amplitude (+ input, column 12) | 0.1 V | The output of the signal generator as it is (C1 passes AC) |
| Output amplitude (column 10) | 1.1 V | 0.1 V × 11. The phase is the same as the input (not inverted) |
| Gain | 11 times (20.8 dB; dB is covered in 1-5) | 1 + 10k/1k |
| Gain with R3 changed to 20 kΩ | 21 times | 1 + 20k/1k. R3 alone changes the gain |

With a gain of 1 (R3 = 0, or R3 removed and replaced by a direct connection) the circuit becomes the follower of 4-1.
The non-inverting amplifier can be seen as the general form of the follower.

## Verification with LTspice

`sim/02-non-inverting-amp.cir` runs Fig. 1 as a transient analysis (1 kHz, 0.1 V). The op amp is a simple one-pole model
(GBW 1 MHz, SR 0.3 V/µs, the output tops out at V+ − 1.5 V and V− + 0.1 V). It is an **assumption** modeled on the LM358, not a measurement.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Input amplitude (+ input) | 0.1 V | 0.1 V (0.200 Vpp) | Match |
| Output amplitude (R3 = 10 kΩ) | 1.1 V | 1.100 V (2.20 Vpp) | Match |
| Output phase | same as the input | 0° (in phase at 1 kHz) | Match |
| With R3 changed to 20 kΩ | 21 times | 2.10 V (4.20 Vpp, 21 times) | Match |

## Sources

Original work.
