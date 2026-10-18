---
book: circuits
chapter: 8
id: 8-1
title: A CdS Cell Lights an LED When It Gets Dark
tier: 50
source: 自作
board: BB
ja: 1c9133c8e04968eedf48f130392f0595914ca375
---

# 8-1 A CdS Cell Lights an LED When It Gets Dark

A CdS cell (a light sensor made of cadmium sulfide) has a higher resistance the weaker the light that falls on it.
Combined with a fixed resistor in a voltage divider, it turns brightness into a voltage.
If that voltage turns a transistor ON and OFF, the result is a circuit in which an LED lights automatically when it
gets dark.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 The transistor turns ON when the CdS is dark
parts:
  VCC: vcc 2,5 5V
  R1: resistor 2,5 2,7 10k
  CDS1: photoresistor 2,7 2,9 GL5528 l=$\mathrm{CDS1}$
  G1: ground 2,9
  Q1: npn 5,7 2SC1815
  VCC: vcc 5,2 5V
  R2: resistor 5,2 5,4 330
  D1: led 5,4 5,6
  G2: ground 5,9
wires:
  - 2,7 -- Q1.B
  - 5,6 -- Q1.C
  - Q1.E -- 5,9
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/01-cds.svg)

- R1 (fixed, 10 kΩ, top) and CDS1 (the CdS cell, bottom) form a voltage divider (seen in 1-2), and its midpoint goes
  straight to the base of Q1. The darker it is and the higher the resistance of the CdS, the closer the midpoint
  voltage gets to +5 V. R1 on top is fixed and only the resistance of CDS1 on the bottom rises, so most of the
  voltage falls across CDS1
- When the midpoint voltage reaches the V<sub>BE</sub> of Q1 (about 0.7 V), Q1 turns ON and D1 (the LED) lights
  through R2 (330 Ω)
- Because the midpoint of the divider is connected directly to the base in this simple design, the change-over is
  gradual and does not give a clean ON/OFF. R1 changes the sensitivity. A larger R1 means the LED lights only when it
  is darker

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5V, blue rail = GND (carried between top and bottom at the right end)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b3 b7 10k
  CDS1: photoresistor d7 d12 GL5528
  Q1: transistor h7(B) h8(C) h9(E) 2SC1815
  D1: led f13(A) f8(K) red
  R2: resistor h13 h17 330
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - a12 -- -t12 black
  - e7 -- f7 green
  - j9 -- -b9 black
  - j17 -- +b17 red
  - +t30 -- +b30 red
  - -t29 -- -b29 black
notes:
  - text: Column 7 (between R1 and CDS1) is the midpoint of the divider. A green wire carries it to the base of Q1
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/01-cds.svg)

- Connect V+ (+5 V) and GND of the AD3 to the upper rails, and carry them to the lower rails at the right end
  (columns 29 and 30)
- The divider (R1, CDS1) goes in the upper block. Connect column 3 of R1 (columns 3 to 7) to the + rail and column 12
  of CDS1 (columns 7 to 12) to the − rail. CDS1 can be recognized by the serpentine track on its light-receiving
  face. It has no direction
- Column 7 is the midpoint of the divider. A green wire carries it to column 7 of the lower block (the base of Q1)
- Q1 (2SC1815) reads E, C, B from the left when you face the flat side. Here it is inserted with the flat side facing
  the back (the f-row side), and B, C, E go into columns 7, 8 and 9 of row h.
  The emitter (column 9) goes to the lower − rail. The cathode of D1 is on the collector (column 8), and from the
  anode of D1 (column 13) a path through R2 (columns 13 to 17) leads to the lower + rail

## Instrument settings

The instruments are Supplies (the power supply) of the Analog Discovery 3 and a multimeter. Set V+ of the AD3 to 5 V
and turn the output on. The circuit draws about 9 mA for the LED and a few hundred µA for the divider, within the
roughly 50 mA of one supply channel of the AD3. The current through one hole of the breadboard is also 200 mA or less,
within the range of the breadboard.

This exercise has no oscilloscope figure. What you look at is a DC voltage that changes slowly with brightness, not a
waveform that changes with time. The multimeter readings are enough.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor | 10 kΩ |
| CDS1 | CdS cell | GL5528 (8–20 kΩ at 10 lux) |
| Q1 | NPN transistor | 2SC1815 |
| R2 | Resistor | 330 Ω |
| D1 | LED (red) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of Supplies on the AD3) |

## Values to check

The values in the table are calculated values. The CdS resistance is a rough guide estimated from a typical
characteristic, in which the resistance is inversely proportional to about the 0.7th power of the illuminance
(brightness, in lux). It assumes 10 kΩ at 10 lux. Real parts vary from one to the next, so measure to check.
The midpoint voltage is 5 V × R<sub>CdS</sub> / (10 kΩ + R<sub>CdS</sub>), the value with Q1 not connected.
Once Q1 turns ON, the midpoint is held down near V<sub>BE</sub> (about 0.7 V).
Q1 begins to switch ON around R<sub>CdS</sub> ≈ 1.5 kΩ (about 150 lux), where the midpoint is about 0.65 V.

How to measure: take the CdS out of the circuit and measure its resistance on the multimeter's resistance range.
For the midpoint voltage, pull out the green wire to the base of Q1 and measure between column 7 and GND on the
multimeter's DC voltage range.

| Brightness | CdS resistance (rough guide) | Midpoint voltage of the divider | Q1 and the LED |
| --- | --- | --- | --- |
| Bright room (500 lux) | about 650 Ω | about 0.3 V | OFF (unlit) |
| Dim room (100 lux) | about 2 kΩ | about 0.8 V | ON (the LED lights; the switch-over is between 1.4 and 1.8 kΩ, where the current jumps from 0.4 mA to 8 mA) |
| About dusk (10 lux) | about 10 kΩ | about 2.5 V | ON (lit) |
| Covered by a hand (almost 0 lux) | about 500 kΩ | about 4.9 V | ON (firmly lit) |

## Verification with LTspice

`sim/01-cds.cir` solves Fig. 1 in DC while sweeping the CdS resistance over 650 Ω, 2 kΩ, 10 kΩ and 500 kΩ. Q1 is a
substitute model for the 2SC1815, and the LED is the same assumed model as in 1-1 (not measured).

| CdS resistance | Midpoint in the text (value without Q1) | Midpoint in LTspice (with Q1) | LED current (LTspice) | Verdict |
| --- | --- | --- | --- | --- |
| 650 Ω | about 0.3 V | 0.31 V | 0 (unlit) | agrees |
| 2 kΩ | about 0.8 V | 0.71 V (Q1 clamps it at V<sub>BE</sub>) | 8.5 mA | agrees (ON; see the note below for the switch-over) |
| 10 kΩ | about 2.5 V | 0.72 V | 8.7 mA | agrees |
| 500 kΩ | about 4.9 V | 0.72 V | 8.7 mA | agrees |

The "value without Q1" for the midpoint is the arithmetic 5 V × R / (10 kΩ + R). With Q1 attached it levels off near
0.7 V. The LED starts to light at a CdS resistance around 1.4 kΩ (0.4 mA), 1.6 kΩ (3.3 mA) and 1.8 kΩ (8.3 mA), which
agrees with the 1.5 kΩ (about 0.65 V) in the text.

## Sources

Original work.
