---
book: circuits
chapter: 1
id: 1-2
title: Series, Parallel and Voltage Dividers
tier: 50
source: 自作
board: BB
ja: caf8ec2f43152e1776ddeee5f7d497a4e6e28114
---

# 1-2 Series, Parallel and Voltage Dividers

The value of several resistors treated as one is called the **combined resistance**. Resistors in **series**
(connected in a single line) add. Resistors in **parallel** (connected with both ends joined) combine by adding
reciprocals (1/R = 1/R2 + 1/R3), and the parallel combination is always smaller than any single resistor.
A circuit with one series resistor and two in parallel lets you compare calculated values with measurements.
It also shows that the **voltage divider** (0-1), where the voltage splits in the ratio of the resistances, still
holds in a circuit that contains a parallel part.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 One series resistor and two in parallel
parts:
  V1: vsource 1,1 1,3 5
  R1: resistor 1,1 3,1 1k
  R2: resistor 3,1 3,3 2k
  R3: resistor 5,1 5,3 2k
  G1: ground 1,3
wires:
  - 3,1 -- 5,1
  - 1,3 -- 3,3
  - 3,3 -- 5,3
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/02-series-parallel.svg)

In Fig. 1, R2 and R3 (2 kΩ each) in parallel make 1 kΩ, which is in series with R1 (1 kΩ) for a total of 2 kΩ.
The 5 V splits in half between R1 and the parallel part (1 kΩ each).

- Combined resistance: R2∥R3 = (2k×2k)/(2k+2k) = **1 kΩ**, total = R1 + 1k = **2 kΩ**
- Total current: I = 5 V / 2 kΩ = **2.5 mA**
- Across R1: 2.5 mA × 1k = **2.5 V**
- Across the parallel part: 2.5 mA × 1k = **2.5 V** (the same value as across R1 by coincidence)
- Current in each of R2 and R3: 2.5 V / 2k = **1.25 mA** each (2.5 mA in total)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 One series resistor and two in parallel
# Top rail = +5V, bottom rail = GND
board: half
parts:
  R1: resistor b5 b10 1k
  R2: resistor c10 c15 2k
  R3: resistor e10 e15 2k
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a15 -- -t15 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/02-series-parallel.svg)

The 5 V comes from V+ of the Supplies on the Analog Discovery 3 (AD3). In WaveForms, set V+ to 5 V and turn the output on.
That is the "Analog Discovery 3 (Supplies)" box in Fig. 2: connect V+ to the top + rail and GND to the top − rail.
The total current is about 2.5 mA, within the limits of the breadboard and of the AD3 supply (up to about 50 mA per rail).

The top ends of `R2` and `R3` in Fig. 2 are both in column 10 (upper block), so they connect to the bottom end of
`R1` without a jumper wire. Their bottom ends are also joined in column 15, so one wire from there to the GND
rail is enough.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 1 kΩ |
| R2, R3 | Resistor (1/4 W) | 2 kΩ |
| — | Power supply | V+ of the Analog Discovery 3 (5 V) |

There is no oscilloscope figure. This exercise looks only at DC voltage and current, so a multimeter reading is enough (the oscilloscope comes in 0-3).

## Values to check

Measure voltages with the multimeter's DC voltage range across each part. For a current, pull one pin of the part
out and reinsert it in an empty column, then connect the multimeter's current range (mA) between that column and
the original one, so the meter is in series with the circuit (0-1).

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Across R1 | about 2.5 V | Matches the calculated value |
| Across the parallel part (R2∥R3) | about 2.5 V | Nearly the same as across R1 (for this combination of values) |
| Current through R2 alone and R3 alone | about 1.25 mA each | The current splits in a parallel circuit |
| Total current from the supply | about 2.5 mA | Equals 1.25 mA × 2 |

## Verification with LTspice

`sim/02-series-parallel.cir` solves Fig. 1 at DC.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Across R1 | 2.5 V | 2.500 V | Match |
| Across the parallel part | 2.5 V | 2.500 V | Match |
| Current in each of R2 and R3 | 1.25 mA | 1.250 mA | Match |
| Total current from the supply | 2.5 mA | 2.500 mA | Match |

## Sources

Original work.

See also: [Voltage divider (Wikipedia)](https://ja.wikipedia.org/wiki/分圧器), [Lessons in Electric Circuits Vol. I, Chapter 5: Series-parallel combination circuits](https://www.ibiblio.org/kuphaldt/electricCircuits/DC/DC_5.html)
