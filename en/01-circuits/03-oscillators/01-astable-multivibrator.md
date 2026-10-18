---
book: circuits
chapter: 3
id: 3-1
title: Astable Multivibrator, LEDs Blinking Alternately
tier: 50
source: 自作
board: BB
era: 古
ja: 380d6aa95eb7908c4b1b7392c9700a46915fbf2c
---

# 3-1 Astable Multivibrator, LEDs Blinking Alternately

This is the most classic oscillator circuit, made of just two transistors and two capacitors.
**Oscillation** means that a circuit repeats a change in voltage on its own, without a signal fed in from outside.
This circuit cannot rest in either of its two states, "Q1 on and Q2 off" and the reverse, and keeps going back and forth,
so it is called "astable". Two LEDs blink alternately. This is the opening exercise of Chapter 3: combining
the transistor switch (2-1) with the charging and discharging of a capacitor (1-3) gives an oscillator.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Astable multivibrator (C1 and C2 cross in the middle)
parts:
  VCC: vcc 1,1 5V
  R1: resistor 1,1 1,3 330
  D1: led 1,3 1,4 red
  Q1: npn 1,6 mirror 2SC1815
  G1: ground 1,7
  R4: resistor 4,1 4,3 100k
  R3: resistor 7,1 7,3 100k
  R2: resistor 10,1 10,3 330
  D2: led 10,3 10,4 red
  Q2: npn 10,6 2SC1815
  G2: ground 10,7
  C1: ecap 2,4 3,4 10u
  C2: ecap 9,4 8,4 10u
wires:
  - 1,1 -- 4,1 -- 7,1 -- 10,1
  - 1,4 |- Q1.C
  - 10,4 |- Q2.C
  - Q1.E |- 1,7
  - Q2.E |- 10,7
  - 1,4 -- 2,4
  - 10,4 -- 9,4
  - 3,4 -- 7,6
  - 8,4 -- 4,6
  - 4,3 -- 4,6
  - 7,3 -- 7,6
  - 4,6 -- Q1.B
  - 7,6 -- Q2.B
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/circuit/01-astable-multivibrator.svg)

- Fig. 1 is drawn left-right symmetric: Q1 on the left and Q2 on the right. The top line is +5 V, and above each collector
  a load resistor and an LED are lined up. **R1 and D1 are the load of Q1, and R2 and D2 are the load of Q2.** Each lights only while its transistor is on
- The inner R4 and R3 are base resistors that feed current to the bases of Q1 and Q2
- **C1 goes from the collector of Q1 to the base of Q2, and C2 from the collector of Q2 to the base of Q1**,
  crossing diagonally (the X in the middle). This is the feedback that makes the circuit "astable". Where the lines of the X
  meet the vertical lines of R3 and R4 there is no black dot, so they are not connected
- Point the + side of the electrolytic capacitors (`C1`, `C2`; the flat side of the schematic symbol, with the curved side being −)
  toward the collector. The base side briefly goes below GND at every discharge, so reversing them can damage the capacitors
- How it works: when Q1 turns on, the collector of Q1 drops to nearly 0 V and, through C1, pushes the base of Q2
  below GND, so Q2 turns off. The base of Q2 is charged little by little through R3, and
  when it reaches about 0.7 V, Q2 turns on. Now C2 pushes down the base of Q1. This repeats

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard (Q1 left, Q2 right)
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
  R4: resistor b8 b12 100k
  C1: capacitor/electrolytic a7(+) a11(-) 10uF
  R3: resistor b18 b22 100k
  C2: capacitor/electrolytic a23(+) a19(-) 10uF
  R2: resistor b25 b28 330
  D2: led c25(A) c23(K) red
  Q1: transistor h6(E) h7(C) h8(B) 2SC1815
  Q2: transistor h22(B) h23(C) h24(E) 2SC1815
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t3 black
  - +t2 -- a2 red
  - +t12 -- a12 red
  - +t18 -- a18 red
  - +t28 -- a28 red
  - -t29 -- -b29 black
  - j6 -- -b6 black
  - j24 -- -b24 black
  - e7 -- f7 orange
  - e8 -- f8 blue
  - e22 -- f22 blue
  - e23 -- f23 orange
  - d19 -- d8 green
  - e11 -- d22 yellow [v-10, h220, v-10]
  - SC.1+ -- j7 orange
  - SC.2+ -- j23 green
  - SC.1- -- -b10 black
  - SC.2- -- -b11 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/breadboard/01-astable-multivibrator.svg)

Fig. 2 has the same layout as the schematic: the Q1 group (R1, D1, C1, R4) on the left and the Q2 group (R3, C2, D2, R2) on the right,
as a mirror image. The upper half of the breadboard (rows a to e) corresponds to the upper half of the schematic (resistors, LEDs, capacitors), and the lower half (rows f to j)
to the transistors.

- Power comes from the Supplies tool of the AD3 (set V+ to 5 V). V+ goes to the top + rail and GND to the top − rail. The circuit draws only
  about 8.5 mA, one LED's worth, so it stays within the 50 mA of V+ (250 mW on USB power). To each resistor's supply-side pin,
  run one red wire straight down from the + rail (columns 2, 12, 18, 28). The emitters go to the bottom − rail with black wires (columns 6 and 24),
  and the top and bottom − rails are joined by the black wire in column 29 at the right end
- **The 2SC1815, viewed from the flat face, is E, C, B from the left.** Q1 has the flat face toward you (the row j side), with
  E, C, B from the left in columns 6, 7, 8 of row h. Q2 has the flat face toward the back (the row f side), the opposite of Q1, so
  columns 22, 23, 24 are B, C, E from the left
- The five holes in the same column are connected. The upper and lower blocks are separated by the trench, so the collector (columns 7 and 23) and
  the base (columns 8 and 22) are lifted to the upper block with short wires (orange, blue) across the trench
- In the upper block, column 7 (collector of Q1) takes the cathode of D1 and the + of C1, and column 8 (base of Q1) takes the
  pin of R4. D1 has its anode in column 5, the same column as R1, and the cathode pin skips one hole to reach column 7.
  The right side has the same form: column 23 is the collector of Q2 and column 22 is the base of Q2
- **The two cross-coupling wires run in different rows in parallel so that they do not cross.** Green (row d) goes from the − side of C2 (column 19) to
  the base of Q1 (column 8), and yellow (row e) goes from the − side of C1 (column 11) to the base of Q2 (column 22).
  These correspond to the X in the schematic, which is the feedback that makes the circuit "astable"
- Point the `+` of the electrolytic capacitors toward the collector (column 7 for C1, column 23 for C2); reversing them can damage the capacitors.
  Their pins are 4 holes apart, so spread them to about 10 mm and plug them into row a

- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. Plug 1+ (orange) into column 7 (`j7`), the collector of Q1, and 2+ (green) into column 23 (`j23`), the collector of Q2,
  and plug 1− and 2− (black) into the bottom − rail (GND)

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise looks at a slow square wave with a period of about 1 second, far slower than 10 MHz.
Connect the collector of Q1 to CH1 and the collector of Q2 to CH2, and view the two collectors moving up and down alternately, overlaid.

| Setting | Value |
| --- | --- |
| Scope CH1 (collector of Q1, column 7) | DC, 1 V/div |
| Scope CH2 (collector of Q2, column 23) | DC, 1 V/div |
| Time | 250 ms/div (about 2 periods fit in 2.5 s) |
| Trigger | CH1, rising edge, 1.8 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Collector of Q1 (CH1) and Q2 (CH2), opposite phase
time: 250ms/div
trigger: ch1 rising 1.8V
ch1: {wave: square 0.98Hz 1.65V offset 1.85V, range: 1V/div}
ch2: {wave: square 0.98Hz 1.65V offset 1.85V phase 180deg, range: 1V/div}
cursors: [-250ms, 770ms]
measure: [vmax, vmin, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/scope/01-astable-multivibrator.svg)

Fig. 3 is an expected waveform drawn with SPICE values (period about 1.02 s, collector on the off side about 3.5 V, on the on side about 0.1 V), not a measurement.
While CH1 is high (Q1 off), CH2 is low (Q2 on), and they swap every half period (about 0.5 s). The cursor spacing of 1.02 s is one period (both placed on the low side).
The LED on the side where CH2 is low lights, so D2 lights while CH1 is high.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| Q1, Q2 | NPN transistor | 2SC1815 (GR rank, hFE 200 to 400) |
| R1, R2 | Resistor (LED current limit) | 330 Ω |
| R3, R4 | Resistor (base) | 100 kΩ |
| C1, C2 | Electrolytic capacitor | 10 µF |
| D1, D2 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of the AD3 Supplies) |
| — | Instrument | AD3 Scope 1+/2+ (collectors of Q1 and Q2) |

## Values to check

The on-time is set by the time it takes the base of the side that turned off to charge to about 0.6 V through R and C.
The formula commonly given in textbooks is T = 0.693 × (R3 × C1 + R4 × C2) (0.693 × R × C per side), but this assumes that
the collector on the off side rises to nearly 5 V and the base is pushed down to about −4.3 V.
This circuit has an LED in series, so the collector on the off side stops at about 3.5 V (about 1.5 V remains across the LED).
The base is pushed down only to about −2.7 V, and it returns to 0.6 V sooner:

t ≈ R × C × ln((5 − (−2.7)) / (5 − 0.6)) = 100 kΩ × 10 µF × ln(7.7 / 4.4) ≈ **0.56 s**

Checked with SPICE (LTspice, models of the 2SC1815 and a red LED; see "Verification with LTspice" below), the on-time per side is **about 0.51 s**
and the period **about 1.02 s**, a little over 20 % shorter than the 0.693RC formula (0.69 s, 1.39 s).
With the LED removed from the same model (the collector rises to 5 V), it is 0.70 s, which agrees with the formula.

Another factor is hFE (the current gain seen in 2-1). The base current on the on side is (5 − 0.7) V ÷ 100 kΩ ≈ 43 µA, and
to saturate while carrying the LED's 8.5 mA, an hFE of about 200 is needed (the same calculation as in 2-1). Use a 2SC1815 of
**GR rank (hFE 200 to 400)**. In SPICE, with an hFE of 250 or more it gives the values above (0.52 s even at 400), at an hFE of 200 it is 0.49 s per side, and
at an hFE of 150 it shrinks to 0.39 s per side. In the model with an hFE of 120 (units of O and Y rank), it could not saturate while carrying the LED's 8.7 mA, and
fell into a different behavior with a period of about 4 ms (it does not blink).

Measure the LED on-time and the period by timing 10 cycles with a stopwatch and dividing by 10 (if you measure with the oscilloscope, use the cursors in Fig. 3). Voltages are measured with the multimeter's
DC voltage range, but they switch every 0.5 s, so the reading is only a rough guide, limited by how fast the display can follow.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Time one LED is on | about 0.51 s (SPICE; the formula's rough guide is 0.56 s) | Set by the resistor and capacitor. It is shorter than 0.693RC (0.69 s) because of the LED |
| Blink period (from D1 lighting to the next time D1 lights) | about 1.02 s (SPICE) | Twice the time of one side |
| LED current while lit (voltage across the resistor ÷ 330 Ω) | about 8.5 mA | (5 V − 0.2 V (saturation) − 2.0 V) ÷ 330 Ω |
| Collector voltage on the side that is off | about 3.5 V (3.47 V in SPICE) | The transistor on that side is off. It is pulled toward + through R and the LED, but about 1.5 V remains across the LED, so it does not rise to 5 V |

Making `R3` and `R4` larger (smaller) makes the blinking slower (faster). With `R3` and `R4` reduced to 10 kΩ and
`C1` and `C2` to 100 nF, the period becomes 1/1000 and turns into a tone (used in 3-4).

## Verification with LTspice

`sim/01-astable-multivibrator.cir` runs a transient analysis of Fig. 1 and reads the period, on-time, collector voltages and LED current.
Q1 and Q2 are the same 2SC1815 model as `09-rf/sim/agc.cir` (IS, VAF, IKF, RB and so on; BF is swept from 120 to 400), and the LED is an assumed red model that gives 2 V (near 8 mA). **These are not measured values**.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| On-time (per side, hFE 250) | about 0.56 s (formula), 0.69 s (0.693RC) | 0.51 s | Match (the formula's 0.56 s is 10 % high; the difference is in the estimate of −2.7 V for how far the base is pulled down) |
| Period (hFE 250) | about 1.02 s | 1.02 s | Match |
| Period at hFE 200 / 400 | 0.49 s / 0.52 s per side | 0.98 s / 1.04 s (0.49 / 0.52 s per side) | Match |
| Collector voltage on the off side | about 3.5 V | 3.47 V | Match |
| Collector voltage on the on side | about 0.2 V | 0.09 V | The text's estimate of the saturation voltage is 0.1 V higher (the model's RC is small; the LED current follows the formula) |
| LED current while lit | about 8.5 mA | 8.7 mA | Match (the model's LED V<sub>F</sub> is a little below 2.0 V) |

## Sources

Original work.
