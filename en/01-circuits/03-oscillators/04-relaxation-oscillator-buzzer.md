---
book: circuits
chapter: 3
id: 3-4
title: Relaxation oscillation — a buzzer with two transistors
tier: 50
source: 自作
board: BB
era: 古
ja: 74fc06ac005a9f6b7609e31d046c2f303fc36dfe
---

# 3-4 Relaxation oscillation — a buzzer with two transistors

Speed up the two-transistor (Tr) astable multivibrator of 3-1 until it is **fast enough to hear**, and drive a buzzer.
This exercise shows the link between the two: a blinking LED becomes a tone when the RC values change. **Relaxation oscillation** is the name for
an oscillation that repeats the following cycle: a capacitor charges (or discharges) slowly, and when it reaches a certain voltage
the circuit switches in an instant. The astable multivibrator is one example. The output is not a sine wave but close to a square wave or a sawtooth wave.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Relaxation oscillator with buzzer branch on the right
parts:
  VCC: vcc 1,1 5V
  R1: resistor 1,1 1,3 330
  D1: led 1,3 1,4 red
  Q1: npn 1,6 mirror 2SC1815
  G1: ground 1,7
  R4: resistor 4,1 4,3 10k
  R3: resistor 7,1 7,3 10k
  R2: resistor 10,1 10,3 330
  D2: led 10,3 10,4 red
  Q2: npn 10,6 2SC1815
  G2: ground 10,7
  C1: capacitor 2,4 3,4 100n
  C2: capacitor 9,4 8,4 100n
  R5: resistor 13,4 13,6 100
  BZ1: buzzer 13,6 13,8
  G3: ground 13,8
wires:
  - 1,1 -- 4,1 -- 7,1 -- 10,1
  - 1,4 |- Q1.C
  - 10,4 |- Q2.C
  - Q1.E |- 1,7
  - Q2.E |- 10,7
  - 1,4 -- 2,4
  - 10,4 -- 9,4
  - 10,4 -- 13,4
  - 3,4 -- 7,6
  - 8,4 -- 4,6
  - 4,3 -- 4,6
  - 7,3 -- 7,6
  - 4,6 -- Q1.B
  - 7,6 -- Q2.B
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/circuit/04-relaxation-oscillator-buzzer.svg)

- As in 3-1, Fig. 1 is drawn symmetrically (Q1 on the left, Q2 on the right; the X-shaped lines are C1 and C2, which do not connect). Only R3 and R4 changed (100 kΩ → 10 kΩ) and C1 and C2 changed (10 µF → 100 nF), so
  **the circuit itself is the same as in 3-1**. The period becomes 1/1000, which is a frequency the ear can hear
- **R5 (100 Ω) protects the buzzer.** A piezo buzzer behaves almost like a capacitor, so a large current (inrush current) flows into it
  at the instant the switch changes state (when Q2 suddenly turns on or off). R5 limits it
- The LEDs blink at about 940 Hz, so the eye cannot see the blinking. They look steadily but faintly lit
  (persistence of vision; the eye can follow a blink only up to about 30–60 Hz)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Built as in 3-1, plus the buzzer branch
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-, 2-, 2+]
  R1: resistor b2 b5 330
  D1: led c5(A) c7(K) red
  R4: resistor b8 b12 10k
  C1: capacitor/ceramic a7 a11 100nF
  R3: resistor b18 b22 10k
  C2: capacitor/ceramic a23 a19 100nF
  R2: resistor b25 b28 330
  D2: led c25(A) c23(K) red
  Q1: transistor h6(E) h7(C) h8(B) 2SC1815
  Q2: transistor h22(B) h23(C) h24(E) 2SC1815
  R5: resistor h26 h29 100 cap=above:0.6,0
  BZ1: buzzer j27 j29
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t3 black
  - +t2 -- a2 red
  - +t12 -- a12 red
  - +t18 -- a18 red
  - +t28 -- a28 red
  - a6 -- -t6 black
  - e6 -- f6 black
  - a24 -- -t24 black
  - e24 -- f24 black
  - e7 -- f7 orange
  - e8 -- f8 blue
  - e22 -- f22 blue
  - e23 -- f23 orange
  - d19 -- d8 green
  - e11 -- d22 yellow [v-10, h220, v-10]
  - g23 -- g26 purple
  - i27 -- -b27 black [h-10]
  - -t30 -- -b30 black
  - SC.1+ -- j7 orange
  - SC.2+ -- j23 green
  - SC.1- -- -b12 black
  - SC.2- -- -b13 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/breadboard/04-relaxation-oscillator-buzzer.svg)

- Fig. 2 has the same layout as Fig. 2 of 3-1 (the Q1 group on the left, the Q2 group on the right). Only the values differ: R3 and R4 are 10 kΩ and
  C1 and C2 are 100 nF. The collectors (columns 7 and 23) and the bases (columns 8 and 22) are lifted to the upper block by short wires across the gap,
  and the two cross-coupling wires (green and yellow) run in parallel on different rows
- In this figure the emitters (columns 6 and 24) are also lifted to the upper block by black wires across the gap and dropped to the top − rail.
  This leaves the lower right free for the buzzer branch
- **R5 and BZ1 branch off from the collector of Q2 (column 23) through the purple wire to column 26. The path is R5 (columns 26 to 29) → the BZ1 pin in column 29 → the BZ1 pin in column 27, which goes down to the bottom − rail.**
  Only one extra branch that makes the sound is added, in parallel with the LED (D2). The top and bottom − rails are joined at column 30 on the right edge
- Power comes from the AD3 Supplies (set V+ to 5 V). The current is about 8 mA for the LED plus the buzzer branch, within the 50 mA of V+ (250 mW on USB power).
  V+ goes to the top + rail and GND to the top − rail. The +5 V wires stand at columns 2, 12, 18 and 28, and the emitter GND wires at columns 6 and 24
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (orange) goes to `j7`, column 7, the collector of Q1, and 2+ (green) goes to `j23`, column 23, the collector of Q2.
  1− and 2− (black) go to the bottom − rail (GND)
- Q1 has its flat face toward the front (the j row side), with E, C, B from the left. Q2 has its flat face toward the back (the f row side), with B, C, E from the left
- A piezo buzzer has no polarity. Insert it either way around
- C1 and C2 change from the electrolytic capacitors of 3-1 to multilayer ceramic capacitors (no polarity). Insert them either way around

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise shows the shape of a square wave with a period of about 1 ms (about 940 Hz), far slower than 10 MHz.
Connect the collector of Q1 to CH1 and the collector of Q2 to CH2. As in 3-1, they go up and down alternately.

| Setting | Value |
| --- | --- |
| Scope CH1 (collector of Q1, column 7) | DC, 1 V/div |
| Scope CH2 (collector of Q2, column 23) | DC, 1 V/div |
| Time | 200 µs/div (about two periods in 2 ms) |
| Trigger | CH1, rising edge, 1.8 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Collectors of Q1 (CH1) and Q2 (CH2), period 1.06 ms
time: 200us/div
trigger: ch1 rising 1.8V
ch1: {wave: square 943Hz 1.55V offset 1.75V, range: 1V/div}
ch2: {wave: square 943Hz 1.55V offset 1.75V phase 180deg, range: 1V/div}
cursors: [-250us, 810us]
measure: [vmax, vmin, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/scope/04-relaxation-oscillator-buzzer.svg)

Fig. 3 is an expected waveform drawn from SPICE values (period about 1.06 ms, off side about 3.3 V, on side about 0.2 V). It is not a measurement. On the real circuit, the edges
are a little rounder than in the figure because of the capacitance of the buzzer and the charging of C1 and C2. The 1.06 ms gap between the cursors is one period, which is about 940 Hz.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| Q1, Q2 | NPN transistor | 2SC1815 |
| R1, R2 | Resistor (LED current limit) | 330 Ω |
| R3, R4 | Resistor (base) | 10 kΩ |
| R5 | Resistor (buzzer protection) | 100 Ω |
| C1, C2 | Multilayer ceramic capacitor | 100 nF (0.1 µF) |
| D1, D2 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| BZ1 | Piezo buzzer element (no amplifier) | — |
| — | Power supply | 5 V (V+ of the AD3 Supplies) |
| — | Instrument | AD3 Scope 1+/2+ (collectors of Q1 and Q2) |

## Values to check

The rough formula is T = 1.386 × R × C (the same formula as 3-1), which gives 1.39 ms (720 Hz). As in 3-1, the actual period is shorter because of the
LED (the collector on the off side stops at about 3.3 V). A SPICE check (LTspice, with models of the 2SC1815 and the red LED and
the buzzer assumed to be 20 nF) gives a period of **about 1.06 ms (about 940 Hz)**. The base current is large,
(5 − 0.7) V ÷ 10 kΩ ≈ 0.43 mA, so unlike 3-1 the result was the same for any hFE from 120 to 400.
Read the frequency from the period of the waveform at the collector of Q2 (column 23) on the oscilloscope (0-3), or measure it with a
multimeter that has a frequency range (Hz).

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Oscillation frequency | about 940 Hz (period about 1.06 ms, SPICE) | Higher than the formula's 1 / (1.386 × 10 kΩ × 100 nF) = 720 Hz because of the LED |
| Duty cycle | 50 % | Symmetric because R3 = R4 and C1 = C2 |
| Buzzer volume | louder when R5 is made smaller (the lower limit is a trade-off with inrush current) | R5 limits the current |
| Collector dissipation of Q1 and Q2 | a few mW | The 330 Ω side is the same calculation as 3-1 |

Compare this with the 555 of 3-2, where Ra, Rb and C alone set the frequency. In the two-transistor circuit the formula has the same form,
but the frequency drifts with the hFE of the transistor (0-5) and the LED voltage, so two builds are unlikely to match.
If the spread matters, the 555 is more practical. That is the contrast between these two exercises.

## Verification with LTspice

`sim/04-relaxation-oscillator-buzzer.cir` runs Fig. 1 as a transient analysis. Q1 and Q2 are the same 2SC1815 model as in 3-1 (BF of 120, 250 and 400),
the LED is a 2 V model (near 8 mA), and the buzzer is 20 nF beyond R5. **All of these are assumptions and not measured values.**

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Period | about 1.06 ms (about 940 Hz) | 1.045 ms (about 957 Hz) | Match |
| Period at hFE of 120, 250 and 400 | all the same | 1.043, 1.045 and 1.046 ms | Match |
| Fraction of the time the collector (Q2) is Low | about 50 % | 52 % | Match |
| Collector voltage on the off side | about 3.3 V | 3.31 V | Match |
| Period by the formula 1.386 RC | 1.39 ms (720 Hz) | (formula only; the model is shorter because of the LED) | As in the text |

## Sources

Original work.

See also: [Relaxation oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Relaxation_oscillator), [Multivibrator (Wikipedia)](https://ja.wikipedia.org/wiki/マルチバイブレータ)
