---
book: circuits
chapter: 1
id: 1-1
title: Lighting an LED — a resistor sets the current
tier: 50
source: 自作
board: BB
ja: 33b0210c8b95a1efd660af7d64f1a32a0c97d199
---

# 1-1 Lighting an LED — a resistor sets the current

An LED's brightness is set by the **current** through it. Connected straight to a supply, too much current flows and
the LED is destroyed. A series resistor sets the current. This exercise applies the method of this book to the
smallest possible circuit: calculate the resistor, build the circuit, and check it with a multimeter.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 An LED and its current-setting resistor
parts:
  V1: vsource 1,1 1,3 5
  R1: resistor 1,1 3,1 330 i=I
  D1: led 3,1 3,3 v=VF
  G1: ground 1,3
wires:
  - 1,3 -- 3,3
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/01-led.svg)

While an LED is lit, a nearly constant voltage stays across it. This is the **forward voltage** V<sub>F</sub>, about
2.0 V for a red LED. The rest of the supply voltage (V − V<sub>F</sub>) falls across the resistor, so choose the resistor by **R = (V − V<sub>F</sub>) / I**.

- With a 5 V supply, V<sub>F</sub> ≈ 2.0 V and a desired current of 10 mA, R = (5 − 2.0) / 10 mA = 300 Ω
- Here we use 330 Ω, an easy-to-buy value (E12 series; see 0-4). The current is (5 − 2.0) / 330 ≈ **9.1 mA**

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5 V, blue rail = GND
board: half
parts:
  R1: resistor b5 b10 330
  D1: led c10(A) c11(K) red
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a11 -- -t11 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/01-led.svg)

The 5 V supply is V+ of Supplies on the Analog Discovery 3 (AD3). In WaveForms, set V+ to 5 V and turn the output on. The power supply box in Fig. 2 is the AD3. Connect V+ to the top + rail and GND to the top − rail. The total current is about 9 mA, within the limits of the breadboard and of the AD3 supply (up to about 50 mA per rail).

- Holes a–e in the same column are connected inside (0-2). The right pin of the resistor (column 10) and the
  anode of the LED are joined in column 10
- The **longer pin of an LED is the anode (A)** and the shorter one is the cathode (K). Put the anode on the resistor
  side. Reversed, it does not light (at 5 V it is not damaged; see 1-4)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 330 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | V+ of the Analog Discovery 3 (5 V). Three AA batteries (4.5 V) also work; the current is then about 7.6 mA |

No oscilloscope figure is given. This exercise looks only at DC voltage and current, so the multimeter readings are
enough (the oscilloscope appears in 0-3).

## Values to check

Set the multimeter to a DC voltage range and measure across the resistor and across the LED (0-1). Divide the
voltage across the resistor by 330 Ω to get the current.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Voltage across the resistor | about 3.0 V | ÷ 330 Ω gives the current (about 9.1 mA) |
| Voltage across the LED | about 2.0 V | Barely changes when the current changes (a property of diodes) |
| Voltage across the resistor when it is replaced by 1 kΩ | about 3.0 V | The current drops to about 3 mA and the LED is dimmer |

## Verification with LTspice

`sim/01-led.cir` solves Fig. 1. The LED uses the same assumed model as 02-transistors (V<sub>F</sub> about 2.0 V at 9 mA; not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Across the resistor (330 Ω) | about 3.0 V | 3.00 V | agrees |
| Across the LED | about 2.0 V | 2.00 V | agrees |
| Current (330 Ω) | about 9.1 mA | 9.08 mA | agrees |
| Across the resistor and current with 1 kΩ | about 3.0 V, about 3 mA | 3.06 V, 3.06 mA (V<sub>F</sub> falls to 1.94 V) | agrees |

## Sources

Original work.
