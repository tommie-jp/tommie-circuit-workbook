---
book: circuits
chapter: 4
id: 4-5
title: Summing amplifier (mixer)
tier: 50
source: 自作
board: BB
ja: c7e19a74385f2f34bec9585fcb2e53c4fca18619
---

# 4-5 Summing amplifier (mixer)

Give the inverting amplifier of 4-3 several input resistors and it becomes a mixer that **adds the signals together
and inverts the sum**. This is the basic form of an audio mixer, and the fifth basic op amp circuit. In this exercise you mix
1 kHz and 3 kHz sine waves and check that the output is the inverted sum of the two.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Summing amplifier
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 2,3
  V1: sine 3,2 3,4 0.2
  G2: ground 3,4
  V2: sine 4,4 4,6 0.1
  G3: ground 4,6
  R1: resistor 3,2 6,2 10k
  R2: resistor 4,4 6,4 10k
  Rf: resistor 6,1 9,1 10k
  U1: opamp 8,3.21 +down
  G4: ground 7,4
  OUT: port 10,3.21
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
wires:
  - mid -- 2,3
  - 6,1 -- 6,2 -- 6,3 -- 6,4
  - 6,3 -| U1.-
  - 7,4 |- U1.+
  - 9,1 -- 9,3.21
  - U1.out -- 9,3.21 -- 10,3.21
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/circuit/05-summing-amp.svg)

- VP and VN on the left are the ±5 V supply for the op amp. They are made with V+ and V− of the AD3 Supplies, as in 4-1
- V1 (1 kHz, amplitude 0.2 V) and V2 (3 kHz, amplitude 0.1 V) **join through R1 and R2 at one point, the same − input
  (virtual ground)**. The − input is held at 0 V by the virtual ground (seen in 4-3), so
  V1 and V2 do not push back against each other, and each current is added in Rf
- **With R1 = R2 = Rf = 10 kΩ, Vout = −(V1 + V2).** Changing the resistors changes the
  volume of each channel (Rf/R1 and Rf/R2 are the gains)
- The non-inverting input is tied directly to GND, as in the inverting amplifier of 4-3

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top rails: +5V (red) and GND (blue). Bottom blue rail: −5V (V−). The bottom red rail is not used
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V, W1, W2)
    pins: [V+, GND, V-, W1, W2]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e10 LM358
  R1: resistor b4 b9 10k
  R2: resistor d6 d9 10k
  Rf: resistor g10 g11 10k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a4 yellow
  - AD3.W2 -- a6 green
  - SC.2+ -- c4 orange
  - SC.1+ -- j10 green
  - SC.1- -- i15 black
  - SC.2- -- j15 black
  - +t10 -- a10 red
  - e9 -- f9 orange
  - i9 -- i11 orange
  - j13 -- -b13 blue
  - h12 -- h15 black
  - f15 -- e15 black
  - a15 -- -t15 black
notes:
  - text below: Top red +5V, top blue GND, bottom blue −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/05-summing-amp.svg)

- In Fig. 2, the AD3 Supplies (V+, V−) correspond to VP and VN in Fig. 1, W1 to V1 and W2 to V2.
  The rails are split as in 4-1 (the bottom blue rail is −5 V, not GND)
- **R1 (from W1, columns 4 to 9 of the upper block) and R2 (from W2, columns 6 to 9) join at one point, column 9.**
  From there a wire across the trench and `i9--i11` take it to IN− (pin 2, column 11).
  Rf (columns 11 to 10) feeds back to the output (pin 1, column 10)
- IN+ (pin 3, column 12) is tied directly to GND by three black wires: `h12--h15`, a wire across the trench, and `a15--(-t15)`
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 2+ (orange) goes to column 4 (`c4`), which receives V1,
  and 1+ (green) goes to column 10 (`j10`), the output. 1− and 2− (black) go to column 15 (`i15`, `j15`), which is connected to GND

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise looks at the shape of 1 kHz and 3 kHz waves, far lower than 10 MHz.
W1 is 1 kHz with amplitude 0.2 V and W2 is 3 kHz with amplitude 0.1 V (both with offset 0 V). The two waves output at the same time are phase-aligned by the synchronization of the AD3 Wavegen.
Put Scope CH1 on the output (column 10) and CH2 on V1 (column 4), and trigger on the rising edge of CH2 at 0 V.

| Setting | Value |
| --- | --- |
| Wavegen W1 | Sine, 1 kHz, amplitude 0.2 V, offset 0 V |
| Wavegen W2 | Sine, 3 kHz, amplitude 0.1 V, offset 0 V, phase 0° |
| Scope CH1 (output, column 10) | DC, 100 mV/div |
| Scope CH2 (V1, column 4) | DC, 100 mV/div |
| Time | 200 µs/div (two periods of 1 kHz) |
| Trigger | CH2, rising edge, 0 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 CH1 is the inverted sum of V1 (CH2) and V2
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: = -(0.2V * sin(2 * pi * 1kHz * t) + 0.1V * sin(2 * pi * 3kHz * t)), range: 100mV/div}
ch2: {wave: sine 1kHz 0.2V, range: 100mV/div}
measure: [vpp, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/scope/05-summing-amp.svg)

CH1 in Fig. 3 repeats at the period of 1 kHz, and falls while CH2 (V1) rises. The sum of the two sine waves
peaks at 0.215 V (calculated value), not 0.2 + 0.1 = 0.3 V, because the peaks of the 1 kHz and 3 kHz waves do not coincide.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Op amp (one of two in the package) | LM358 |
| R1, R2 | Resistors (input) | 10 kΩ |
| Rf | Resistor (feedback) | 10 kΩ |
| — | Signal source | 1 kHz 0.2 V (output 1), 3 kHz 0.1 V (output 2) |
| — | Power supply | ±5 V (AD3 Supplies; V+ = +5 V, V− = −5 V) |
| — | Instrument | AD3 W1 and W2 (signal sources) and Scope 1+/2+ (output and V1) |

## Values to check

The signal generators are W1 (1 kHz, amplitude 0.2 V) and W2 (3 kHz, amplitude 0.1 V) of the AD3. Put Scope CH1 on
the output (column 10) (Fig. 3) and compare the waveform with one source stopped and with both on. The values in the table are calculated. Vout = −(Rf/R1 × V1 + Rf/R2 × V2).

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Output amplitude with V1 only | 0.2 V (inverted) | −10k/10k × 0.2 V |
| Output amplitude with V2 only | 0.1 V (inverted) | −10k/10k × 0.1 V |
| Output peak with both | 0.3 V or less (depends on the phase relation of the two); about 0.215 V (calculated value) at the phase of Fig. 3 | The sum of two sine waves. 3 kHz is exactly 3 times 1 kHz, so the oscilloscope shows a wave that repeats at the period of 1 kHz |
| Frequency components of the output (if viewed on a spectrum analyzer) | two lines, 1 kHz and 3 kHz | Mixing keeps the frequencies (adding the inputs adds the outputs, a property of linear circuits) |

With R1 and R2 at other values you can set the volume balance of a mixer, for example "CH1 loud and CH2 quiet"
(the gains are set independently by Rf/R1 and Rf/R2).

## Verification with LTspice

`sim/05-summing-amp.cir` runs Fig. 1 as a transient analysis (V1 = 1 kHz, 0.2 V; V2 = 3 kHz, 0.1 V; phases aligned).
The op amp is a simple one-pole model (GBW 1 MHz, SR 0.3 V/µs). It is an **assumption** modeled on the LM358, not a measurement.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Output peak with both | about 0.215 V (at the phase of Fig. 3) | ±0.215 V | Match |
| With one source only | 0.2 V / 0.1 V (inverted) | (arithmetic: 10 kΩ ÷ 10 kΩ = 1) | As in the text |

## Sources

Original work.
