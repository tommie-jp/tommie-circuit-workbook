---
book: circuits
chapter: 1
id: 1-4
title: Diode Direction and Forward Voltage — Comparing LED Colors
tier: 50
source: 自作
board: BB
ja: adf8805ec76bc6a6d9026ec0bd92b6110dd45a3e
---

# 1-4 Diode Direction and Forward Voltage — Comparing LED Colors

A diode is a component that **passes current in one direction only (anode → cathode)**.
An LED (light-emitting diode) is one kind of diode. The direction in which current flows is the **forward direction**,
and the direction in which it does not is the **reverse direction**.
An LED also has a **forward voltage (V<sub>F</sub>, see 1-1)** that depends on its color. Light a red LED and a blue LED
through the same resistor and compare them. Then insert one more LED backwards and confirm that it does not light.
Diode direction is the basis of the later rectifier circuits (Chapter 5) and protection circuits.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 LEDs of different colors and a reversed LED
parts:
  V1: vsource 2,1 2,5 5
  G1: ground 2,5
  R1: resistor 4,1 4,3 330
  D1: led 4,3 4,5
  R2: resistor 6,1 6,3 330
  D2: led 6,3 6,5
  R3: resistor 8,1 8,3 330
  D3: led 8,5 8,3
wires:
  - 2,1 -- 4,1
  - 4,1 -- 6,1
  - 6,1 -- 8,1
  - 2,5 -- 4,5
  - 4,5 -- 6,5
  - 6,5 -- 8,5
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/04-diode-direction.svg)

In Fig. 1, D1 (red) and D2 (blue) face the same way. Only D3 (red) is **deliberately reversed**.
The supply is the same 5 V for all of them, and every resistor is 330 Ω.

- D1 (red, V<sub>F</sub> ≈ 2.0 V): I = (5 − 2.0) / 330 ≈ **9.1 mA**
- D2 (blue, V<sub>F</sub> ≈ 3.2 V): I = (5 − 3.2) / 330 ≈ **5.5 mA** (with the same resistor, a color with a higher
  V<sub>F</sub> carries less current and looks dimmer)
- D3 (red, reversed): the current is almost 0. R3 has almost 0 V across it, and D3 has almost 5 V across it.
  Most LEDs withstand only about 5 V in reverse (the reverse breakdown voltage). Even if D3 exceeds that,
  the resistor limits the current to 5 V/330 Ω ≈ 15 mA or less, so the LED is not damaged

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 LEDs of different colors and a reversed LED
# top + rail = +5V, top − rail = GND (the bottom rails are not used)
board: half
parts:
  R1: resistor b5 b8 330
  D1: led c8(A) c9(K) red
  R2: resistor b12 b15 330
  D2: led c15(A) c16(K) blue
  R3: resistor b19 b22 330
  D3: led c23(A) c22(K) red
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a9 -- -t9 black
  - +t12 -- a12 red
  - a16 -- -t16 black
  - +t19 -- a19 red
  - a23 -- -t23 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/04-diode-direction.svg)

The 5 V supply comes from V+ of Supplies on the Analog Discovery 3 (AD3). In WaveForms, set V+ to 5 V and turn the output on.
The "Analog Discovery 3 (Supplies)" box in Fig. 2 is this supply. Connect V+ to the top + rail and GND to the top − rail. The total current is about 15 mA,
which is within the limits of the breadboard and of the AD3 supply (up to about 50 mA per rail).

In Fig. 2, note that only D3 has **K (cathode) on the resistor side (column 22) and A (anode) on the GND side (column 23)**.
(D1 and D2 have A on the resistor side and K on the GND side.)
Compare it with the other two to see which one is reversed.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1, R2, R3 | Resistor (1/4 W) | 330 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| D2 | LED (blue, 5 mm) | V<sub>F</sub> ≈ 3.2 V |
| D3 | LED (red, 5 mm, mounted reversed) | — |
| — | Power supply | V+ of the Analog Discovery 3 (5 V) |

No oscilloscope figure is given. This exercise looks only at DC voltage and current, so the readings of a multimeter are enough (the oscilloscope is covered in 0-3).

## Values to check

Use the DC voltage range of a multimeter to measure across each LED and each resistor. Get the current by dividing the voltage across the resistor by 330 Ω.

| Where to measure | Expected value | What it shows |
| --- | --- | --- |
| Across D1 (red) | about 2.0 V | V<sub>F</sub> is fixed for each color |
| Across D2 (blue) | about 3.2 V | V<sub>F</sub> is higher than red (blue and white are usually high, red and yellow low) |
| Current of D2 (voltage across R2 ÷ 330 Ω) | about 5.5 mA | Less than the 9.1 mA of D1, so D2 looks dimmer |
| Across D3 | about 5 V (almost the supply voltage) | Shows that no current flows. R3 has almost 0 V across it |

## Verification with LTspice

`sim/04-diode-direction.cir` solves Fig. 1 at DC. The LED models are assumptions (red is the same as in 1-1; for blue, IS is tuned so that V<sub>F</sub> is 3.2 V at 5.5 mA. They are not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Voltage and current of D1 (red) | about 2.0 V, about 9.1 mA | 2.00 V, 9.08 mA | Agrees |
| Voltage and current of D2 (blue) | about 3.2 V, about 5.5 mA | 3.20 V, 5.44 mA | Agrees |
| Voltage and current of D3 (reversed) | about 5 V, almost 0 | 5.00 V, 0.1 nA | Agrees |

## Sources

Original work (自作).
