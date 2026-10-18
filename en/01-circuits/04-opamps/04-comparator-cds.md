---
book: circuits
chapter: 4
id: 4-4
title: Comparator — a CdS cell sets the threshold
tier: 50
source: 自作
board: BB
ja: cbb3c84493bfd39d4782bad3bf57f3e96d2e156a
---

# 4-4 Comparator — a CdS cell sets the threshold

An op amp used without feedback is a **comparator**. An op amp amplifies the difference between its inputs by tens of
thousands of times or more, so its output snaps to the positive or the negative supply depending only on which input,
+ or −, is higher. This is the fourth basic op amp circuit. In this exercise a CdS cell (cadmium sulfide cell, whose
resistance changes with light) measures brightness, and an LED lights when it gets dark.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Comparator (CdS)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground mid
  CDS1: photoresistor 4,1 4,3 l=$\mathrm{CDS1}$
  RFIX: resistor 4,4 4,6 10k
  VR1: potentiometer 6,1 6,3 10k l=$\mathrm{VR1}$
  U1: opamp 9,3 +up
  R1: resistor 10.5,3 12.5,3 220
  D1: led 12.5,3 12.5,5 red
  DP: diode 15.5,5 15.5,3 1N4148
  GD1: ground 12.5,5
points:
  vp: 2,1
  vm: 2,6
  mid: 2,3
wires:
  - vp -- 4,1 -- 6,1
  - vm -- 4,6 -- 6,6
  - 4,3 -- 4,4
  - 6,3 -- 6,6
  - VR1.w |- U1.+
  - 4,4 -- 7.5,4 |- U1.-
  - U1.out -| 10.5,3
  - 12.5,3 -- 15.5,3
  - 12.5,5 -- 15.5,5
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/circuit/04-comparator-cds.svg)

- VP and VN on the left are the ±5 V supply. They are made with V+ and V− of the AD3 Supplies, as in 4-1. In Fig. 1 they also power CDS1, RFIX and VR1
- **The divider point of CDS1 and RFIX is the − input.** In the light CDS1 has a low resistance (about 1 kΩ) and in the
  dark a high resistance (about 200 kΩ), so the voltage at the divider point moves over a wide range
- **The midpoint (wiper) of VR1 (threshold adjustment) is the + input.** There is no feedback, so when the +
  input is higher than the − input the output sticks near +V, and when it is lower the output sticks near −V
- R1 and D1 are an LED branch that lights only when the output is high. **A comparator with no feedback has no
  hysteresis** (a mechanism that shifts the switching point depending on whether the input is rising or falling), so the
  LED may flicker right at the threshold (to fix this, use the Schmitt trigger of 4-8)
- **When the output sticks to the −V side (about −4.5 V), a reverse voltage of about 4.5 V is applied to D1,
  opposite to its forward direction.** The reverse breakdown voltage of an LED is a rough 5 V, so this is dangerously close.
  **Put a protection diode DP (1N4148) in parallel with D1, in the opposite direction.** While D1 is forward
  biased, DP is reverse biased and has no effect. When the output sticks to −V, DP conducts in its forward direction
  and holds the voltage across D1 down to the forward drop of DP (about 0.7 V). The reverse voltage on D1 then stays far
  below the rough 5 V reverse breakdown voltage

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top rails: +5V (red) and GND (blue). Bottom red rail: +5V (carried over at column 1). Bottom blue rail: −5V (V−)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies ±5V
    pins: [V+, GND, V-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e12 LM358
  CDS1: photoresistor i16 i13
  RFIX: resistor h13 h9 10k
  VR1: potentiometer b26(1) b27(W) b28(3) 10k
  R1: resistor c11 c9 220
  D1: led b9(A) b6(K) red
  DP: diode d6(A) d9(K) 1N4148
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.V- -- -b4 blue
  - +t1 -- +b1 red
  - +t12 -- a12 red
  - +t26 -- a26 red
  - e28 -- g28 blue
  - j28 -- -b28 blue
  - e27 -- f27 orange
  - g27 -- g14 orange
  - j15 -- -b15 blue
  - j9 -- -b9 blue
  - j16 -- +b16 red
  - g12 -- g11 orange
  - f11 -- e11 orange
  - a6 -- -t6 black
  - SC.1+ -- j13 orange
  - SC.2+ -- j12 green
  - SC.1- -- -t29 black
  - SC.2- -- -t30 black
notes:
  - text below: Top red +5V, blue GND; bottom red +5V, blue −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/04-comparator-cds.svg)

- The AD3 Supplies at the upper left of Fig. 2 correspond to VP and VN (the ±5 V supply) in Fig. 1. V+ goes to the top red rail and GND to the top blue rail.
  V− is brought down along the left edge of the breadboard into the bottom blue rail. The bottom red rail gets +5 V from the top red rail through the red wire at column 1
- **V− is the bottom blue rail.** Do not confuse it with GND (the top blue rail). Pin 4 (column 15), RFIX and terminal 3
  of VR1 connect to it. Pin 8 (column 12) goes to +5 V through `+t12--a12`
- **The divider point of the CdS (column 13) and RFIX (column 13) is IN− (pin 2).** The other end of the CdS (column 16) goes to the bottom red rail (+5 V).
  The wiper of VR1 (column 27, at the right end of the upper block) goes to IN+ (pin 3, column 14) through the orange wire across the gap and `g27--g14`
- The output (pin 1, column 12) is raised to column 11 of the upper block by `g12--g11` and a wire across the gap. From there it passes
  through R1 (220 Ω) and D1 (LED) to GND (column 6, the top blue rail). **DP (1N4148) is connected in anti-parallel with D1.** DP uses the same columns as D1, 6 and 9,
  so it needs no wiring (column 9 is automatically the same net as the anode side of D1 and column 6 the same net as the cathode side).
  It clamps the reverse voltage, when the output sticks to −V, to the forward drop of DP (about 0.7 V). Turn VR1 to change the brightness at the threshold
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (orange) goes to column 13 (`j13`), the − input,
  and 2+ (green) goes to column 12 (`j12`), the output. 1− and 2− (black) go around the right edge of the breadboard and return to columns 29 and 30 of the top blue rail (GND)
- The current from the AD3 Supplies peaks as follows. On the +5 V side it is about 7 mA for the LED plus a few mA for the CdS, VR1 and the op amp. On the −5 V side
  it is about 17 mA, sunk through R1 and DP in the light. Both are within the rough USB-power limit of 50 mA (250 mW)

## Instrument settings

Instead of a multimeter, use the AD3 Scope to watch how the − input (CH1) and the output (CH2) change at the moment you cover the CdS with your hand.
The voltage changes greatly only once, far more slowly than 10 MHz (the observation lasts a few seconds). Set VR1 to its midpoint (threshold 0 V).

| Setting | Value |
| --- | --- |
| Scope CH1 (− input, column 13) | DC, 2 V/div |
| Scope CH2 (output, column 12) | DC, 2 V/div |
| Time | 100 ms/div. Set Mode to Single or Screen, not Repeated, and cover the CdS by hand |
| Trigger | CH1, falling edge, 0 V (the moment the − input falls below the 0 V of the + input) |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 CdS covered, CH1 falls past 0 V, CH2 goes High
time: 100ms/div
trigger: ch1 falling 0V
ch1: {wave: = 4.1V - 8.6V * step(t), range: 2V/div}
ch2: {wave: = -4.5V + 8V * step(t), range: 2V/div}
cursors: [-300ms, 300ms]
measure: [vmax, vmin]
notes:
  - text ch2 0 3.5V: Output goes to +3.5 V (LED on)
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/scope/04-comparator-cds.svg)

The waveforms in Fig. 3 are an illustration: the calculated values in the table drawn as steps. A real CdS cell changes more gradually, over several tens of ms. CH1 moves from +4.1 V (light) to
−4.5 V (dark), and where it crosses 0 V, CH2 jumps from −4.5 V to +3.5 V. CH2 flips every time CH1 crosses 0 V,
so this screen also shows the flicker right at the threshold (the lack of hysteresis).

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Op amp (one of two in the package, used as a comparator) | LM358 |
| CDS1 | Cadmium sulfide cell (CdS) | Light: about 1 kΩ / dark: about 200 kΩ (typical values) |
| RFIX | Resistor | 10 kΩ |
| VR1 | Trimmer potentiometer (threshold adjustment) | 10 kΩ |
| R1 | Resistor (LED current limit) | 220 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| DP | Protection diode (anti-parallel with D1) | 1N4148 |
| — | Power supply | ±5 V (AD3 Supplies; V+ = +5 V, V− = −5 V) |
| — | Instrument | AD3 Scope 1+/2+ (− input and output), multimeter |

## Values to check

While covering the CdS with your hand and shining a light on it, measure the − input (column 13) and the output (column 12) against GND with the multimeter on a DC voltage range or with the AD3 Scope (Fig. 3), and watch the LED. The values in the table are calculated. Voltage at the divider point = V− + (V+ − V−) × RFIX / (CDS1 + RFIX), with VR1 at its midpoint
(threshold 0 V). With almost no load, the LM358 output swings **to about 1.5 V below the supply on the +V side (≈ +3.5 V) and almost to V− on the −V side (≈ −4.5 V)** (typical values).

| Measure | Expected value | What it shows |
| --- | --- | --- |
| − input in the light (CDS1 ≈ 1 kΩ) | about +4.1 V | RFIX dominates, so it is near +V |
| − input in the dark (CDS1 ≈ 200 kΩ) | about −4.5 V | CDS1 dominates, so it is near −V |
| Output and LED in the light | output about −4.5 V, LED off | − input (+4.1 V) > + input (0 V), so the output is Low. The reverse voltage on D1 is clamped by DP to about −0.7 V (calculated value, below the rough 5 V reverse breakdown voltage) |
| Output and LED in the dark | output about +3.5 V, LED on | − input (−4.5 V) < + input (0 V), so the output is High. LED current ≈ (3.5 − 2.0) / 220 ≈ **6.8 mA** (calculated value) |
| Value of CDS1 at which it switches | 10 kΩ (with VR1 at its midpoint) | The point where − input = + input (0 V). VR1 changes this value (it does not depend on the supply voltage) |
| Current through R1 in the light (via DP) | about 17 mA (calculated value) | (4.5 − 0.7) / 220 ≈ 17.3 mA. Within the current the LM358 can sink (typically around 20 mA). Power in R1 ≈ 0.066 W |

The resistance of a CdS cell varies a lot from part to part (and differs from the typical values in the datasheet).
Measure CDS1 with the multimeter in the light and in the dark before adjusting VR1.

## Verification with LTspice

`sim/04-comparator-cds.cir` solves the DC operating point of Fig. 1 (CDS1 swept over 1 kΩ, 10 kΩ and 200 kΩ; VR1 at its midpoint, so the + input is 0 V).
The op amp is a simple one-pole model. The output High is V+ − 1.5 V = 3.5 V, and Low is V− + 0.5 V = −4.5 V because the op amp sinks 17 mA; both are **assumptions**
(assumed voltage drops of the LM358 when sinking, not measurements). The LED is a model with 2 V (near 8 mA) and DP is the standard 1N4148 model.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| − input in the light (1 kΩ) | about +4.1 V | +4.09 V | Match |
| − input in the dark (200 kΩ) | about −4.5 V | −4.52 V | Match |
| Output in the light and reverse voltage on D1 | −4.5 V, about −0.7 V | −4.5 V (assumed), −0.72 V | Match |
| Output in the dark and LED current | +3.5 V, about 6.8 mA | +3.5 V (assumed), 6.83 mA | Match |
| Threshold (CDS1 = 10 kΩ) | − input = 0 V | 0 V, output 0 V (the switching point) | Match |
| Current through R1 in the light (via DP) | about 17 mA | 17.2 mA | Match |

## Sources

Original work.
