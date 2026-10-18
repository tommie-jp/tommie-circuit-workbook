---
book: circuits
chapter: 8
id: 8-5
title: Infrared LED and Phototransistor — Detecting Interrupted Light
tier: 50
source: 自作
board: BB
ja: 7aa9e6e23d163d8e40ef49a95d2a2124464e4445
---

# 8-5 Infrared LED and Phototransistor — Detecting Interrupted Light

An infrared (IR) LED stays lit, and a phototransistor facing it (a transistor that passes collector current when light falls on it)
keeps receiving that light. When an object comes between them and blocks the light, the phototransistor stops receiving it.
The circuit detects this and turns on an indicator LED.
Interrupted-light detection is common in the field, for example to sense the passage of a sheet of copier paper or the opening and closing of a door.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Blocking the light turns on the indicator
parts:
  VCC: vcc 2,2 5V
  R1: resistor 2,2 2,4 220
  D1: led 2,4 2,6
  G1: ground 2,6
  VCC: vcc 4,2 5V
  R2: resistor 4,2 4,4 10k
  Q1: phototransistor 4,5 PT204-6C
  G2: ground 4,6
  R3: resistor 4,4 6,4 10k
  VCC: vcc 7,2 5V
  R4: resistor 7,2 7,4 330
  D2: led 7,4 7,6
  Q2: npn 7,7 2SC1815
  G3: ground 7,8
wires:
  - 4,4 -- Q1.C
  - Q1.E -- 4,6
  - 6,4 |- Q2.B
  - 7,6 -- Q2.C
  - Q2.E -- 7,8
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/05-photointerrupter.svg)

- D1 (IR LED) stays lit at the current set by R1 (220 Ω). Infrared light is invisible to the human eye
  (seen through a smartphone camera, it may look purplish).
- When Q1 (phototransistor) receives the light from D1, it conducts, and the voltage at the junction of R2 (10 kΩ pull-up) and Q1 drops.
  Below, this point is called the "divider point". When the light is blocked, Q1 stops conducting and the divider point is
  pulled up through R2 (about 2.9 V, because current flows into the base of Q2).
- The divider-point voltage goes through R3 (10 kΩ) to the base of Q2. Q2 turns ON only when the light is blocked and the divider point is high.
  D2 (the indicator LED) is in series with R4 and the collector of Q2
  (+5 V → R4 → D2 → Q2 → GND). Current flows, and D2 lights, only while Q2 is ON,
  so the circuit shows "the light is blocked", not "the light is arriving".
- While the light is not blocked, the divider point is only 0.2–0.4 V, and the base of Q2 does not reach 0.6 V.
  Q2 is OFF, the current path of D2 is cut, and D2 is dark.

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5V, blue rail = GND (carried over to the bottom − rail at column 30)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b3 b6 220
  D1: led d6(A) d9(K)
  R2: resistor b12 b16 10k
  Q1: phototransistor d16(C) d19(E)
  D2: led d26(A) d22(K) red
  R4: resistor b26 b29 330
  R3: resistor g16 g20 10k
  Q2: transistor h21(B) h22(C) h23(E) 2SC1815
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - a9 -- -t9 black
  - +t12 -- a12 red
  - a19 -- -t19 black
  - +t29 -- a29 red
  - e16 -- f16 yellow
  - f20 -- f21 green
  - e22 -- f22 orange
  - j23 -- -b23 black
  - -t30 -- -b30 black
notes:
  - text: Aim D1 (IR LED) at Q1, pass paper between them
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/05-photointerrupter.svg)

- Connect V+ (+5 V) and GND of the AD3 to the top rails, and carry them over to the bottom − rail at the right end (column 30).
- Insert D1 (IR LED, columns 6→9) and Q1 (phototransistor, columns 16→19) in the upper block,
  and bend their pins so that the emitting face and the receiving face point at each other. Fig. 2 draws D1 in the shape of a red LED, but the real part usually has a clear or pale blue body.
  How to tell C from E on Q1 (pin length, flat side) differs from part to part, so check the datasheet.
- Carry the divider point (column 16) to the lower block with the yellow wire, and connect it through R3 (columns 16→20) and the green wire to the base of Q2 (column 21).
- Seen with its flat face toward you, Q2 (2SC1815) has E, C, B from the left. Here it is inserted with the flat face toward the back (the f-row side),
  and B, C, E go into columns 21, 22, 23 of row h. The emitter (column 23) goes to the bottom − rail.
- Carry the collector (column 22) to the upper block with the orange wire and connect it to the cathode of D2 (column 22).
  From the anode of D2 (column 26), go through R4 (columns 26→29) to the + rail.

## Instrument settings

The instruments are the Supplies (power supply) of the Analog Discovery 3 and a multimeter. Set V+ of the AD3 to 5 V and turn the output ON.
The supply current is about 17.3 mA for D1, about 8.5 mA for D2 while the light is blocked, and under 1 mA for everything else, about 26 mA in total.
This fits within about 50 mA of one supply channel of the AD3, and within the 200 mA per hole of the breadboard.

This exercise has no oscilloscope figure. What you read is a DC voltage that depends on whether the light is blocked, not a waveform that changes with time.
Multimeter readings are enough.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| D1 | IR LED (peak emission around 940 nm) | V<sub>F</sub> ≈ 1.2 V |
| R1 | Resistor | 220 Ω |
| Q1 | Phototransistor | PT204-6C (Everlight, 3 mm, clear resin. Spectral sensitivity is 400–1100 nm with the peak at 940 nm in the infrared; check the datasheet. Do not use the NJL7502L, which is for visible light) |
| R2, R3 | Resistor | 10 kΩ |
| Q2 | NPN transistor | 2SC1815 |
| R4 | Resistor | 330 Ω |
| D2 | LED (red, indicator) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of the Supplies on the AD3) |

## Values to check

The values in the table are calculated values. Measure voltages with the DC voltage range of the multimeter, with the − probe on GND. The divider point is column 16 of the upper block.

| Where to measure | Expected value | What it tells you |
| --- | --- | --- |
| Current of D1 (IR LED) | About 17.3 mA (= (5 − 1.2) / 220 Ω) | Set by R1 |
| Divider-point voltage (light passing) | About 0.2–0.4 V (Q1 saturated) | Q1 receives the light and conducts. Saturation needs at least about 0.5 mA (= 4.8 V / 10 kΩ) in R2. The PT204-6C passes 0.7–2.0 mA at 1 mW/cm² (V<sub>CE</sub> = 5 V, datasheet), so D1 a few millimeters away and facing it is enough |
| Divider-point voltage (light blocked) | About 2.9 V (= 0.7 + 4.3 V × 10 kΩ / 20 kΩ) | Q1 stops conducting, and current flows through R2 → R3 into the base of Q2. The base of Q2 holds it near 0.7 V, so it does not rise to 5 V |
| Base current of Q2 (light blocked) | About 215 µA (= (5 − 0.7) / (R2 + R3) = 4.3 V / 20 kΩ) | Even with an h<sub>FE</sub> of 70 it can pass 15 mA, enough to saturate Q2 for the D2 current (about 8.5 mA) |
| Current of D2 (light blocked) | About 8.5 mA (= (5 − 2.0 − 0.2) / 330 Ω, where 0.2 V is V<sub>CE(sat)</sub> of Q2) | Set by R4 |
| D2 (indicator) | Lit only while the light is blocked | Behaves as the name "interrupted-light detection" says |

## Verification with LTspice

`sim/05-photointerrupter.cir` solves Fig. 1 at DC, representing the presence or absence of light by the base current of Q1 (20 µA / 0). The phototransistor and the IR LED are assumed models (V<sub>F</sub> 1.2 V @ 17 mA, h<sub>FE</sub> 100; not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Current of D1 (IR LED) | About 17.3 mA | 17.3 mA | Agrees |
| Divider point (light passing) | About 0.2–0.4 V | 0.09 V | Agrees (the saturation voltage of the model is ideal. The real PT204-6C gives 0.2–0.4 V) |
| Divider point (light blocked) | About 2.9 V | 2.85 V | Agrees |
| Base current of Q2 (light blocked) | About 215 µA | 214 µA | Agrees |
| Current of D2 (light blocked) | About 8.5 mA | 8.6 mA | Agrees |
| Current of D2 (light passing) | 0 (dark) | 0 | Agrees |

## Sources

Original work.
