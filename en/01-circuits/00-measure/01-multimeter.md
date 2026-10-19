---
book: circuits
chapter: 0
id: 0-1
title: Measuring Voltage, Current and Resistance with a Multimeter — Using a Voltage Divider
tier: 50
source: 自作
board: BB
ja: b548c2a67d3c9e5b9c0c0da1a31b6d173044a428
---

# 0-1 Measuring Voltage, Current and Resistance with a Multimeter — Using a Voltage Divider

A multimeter (digital multimeter) measures voltage, current and resistance. You choose the **range** (what to measure
and over what span) with the selector. Most experiments in this book check values with a multimeter, so start by
learning three ways to connect it. The connection differs by range. Voltage is measured by connecting the meter
**in parallel** across the part you want to measure. Current is measured by breaking the circuit and inserting
the meter **in series**. Resistance is measured with the power turned off.
You try each of the three in turn on a **voltage divider** (a circuit that splits a voltage in the ratio of two resistances)
made of two resistors in series.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Voltage divider and how to connect the meters
parts:
  V1: vsource 2,2 2,4 5
  A1: ammeter 2,2 4,2
  R1: resistor 4,2 6,2 10k
  R2: resistor 6,2 8,2 10k
  V2: voltmeter 6,3 8,3
  G1: ground 2,4
  G2: ground 8,4
wires:
  - 8,2 -- 8,3 -- 8,4
  - 6,2 -- 6,3
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/circuit/01-multimeter.svg)

In Fig. 1, the ammeter (`A1`) is inserted between the power supply and `R1` so that it is in series, and the voltmeter (`V2`)
is connected in parallel across `R2`. R1 = R2 = 10 kΩ and the supply is 5 V.
Because the resistors are in series, the current is the same everywhere, and the voltage splits in half between the two resistors.
Find the current with Ohm's law (I = V / R).

- Current: I = 5 V / (10k + 10k) = **0.25 mA**
- Voltage across R2: 5 V × 10k/(10k+10k) = **2.5 V**

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Measuring the voltage divider with a multimeter
# Top red rail = +5V, blue rail = GND
board: half
parts:
  R1: resistor b5 b10 10k
  R2: resistor c10 c15 10k
  MULT:
    type: device
    at: bottom
    label: Multimeter (DCV)
    pins: ["+", COM]
  PS:
    type: device
    at: top
    label: Analog Discovery (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a15 -- -t15 black
  - MULT.+ -- d10 orange
  - MULT.COM -- d15 gray
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/breadboard/01-multimeter.svg)

The 5 V supply is V+ of Supplies on the Analog Discovery 3 (AD below). Set V+ to 5 V in WaveForms and turn the output on.
It is the power supply box in Fig. 2: connect V+ to the top + rail and GND to the top − rail.
The current in this exercise is 0.25 mA, well within what the AD supply can deliver (up to about 50 mA per rail).

On a breadboard, the five holes in a vertical column (a to e of the same column) are connected inside the breadboard
(the next exercise, 0-2, covers how this works). The hole addresses in Fig. 2 are written as a row letter plus a column number.

- `b10` and `c10` are in the same column, 10 (upper block), so the lower end of `R1` and the upper end of `R2`
  are connected without a jumper wire. If you plug the multimeter leads into `d10` and `d15`
  in the same columns, you can connect them without competing with the pins of `R1` and `R2` for the same holes.
- Connect the red (+) lead of the multimeter to the same net as the upper end of `R2` (`d10`) and the black (COM) lead
  to GND at the lower end (`d15`), and read the voltage across `R2`.

To measure current, first pull out the red-rail wire (`a5`) that is connected to the upper end of `R1` (`b5`).
Touch the red lead, plugged into the multimeter's current (mA) jack, to the end of the pulled wire (the +5 V side) and the COM lead to `a5`,
so that the multimeter becomes part of the circuit. Move the red lead to the mA jack, which is a different jack from the one used for voltage.
To measure resistance, disconnect the power, pull `R1` and `R2` out of the breadboard,
and measure them one at a time on the multimeter's Ω range.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 10 kΩ |
| R2 | Resistor (1/4 W) | 10 kΩ |
| — | Power supply | V+ of the Analog Discovery 3 (5 V) |
| — | Multimeter | Digital multimeter (DC voltage, DC mA, Ω) |

## Instrument settings

| Measurement | Range | How to connect |
| --- | --- | --- |
| Voltage (across R2) | DC 20 V (automatic on an auto-ranging meter) | In parallel with R2 |
| Current (circuit current) | DC mA | Break the circuit and connect in series |
| Resistance (R1 alone, power disconnected) | 20 kΩ | Across the part |

There is no oscilloscope figure. This exercise looks only at DC voltage, current and resistance, so the multimeter readings are enough (the oscilloscope comes in 0-3).

## Values to check

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| Voltage across R2 | about 2.5 V | Matches the voltage divider calculation (half and half) |
| Circuit current | about 0.25 mA | Does not change when the voltmeter is connected (a voltmeter has a very high resistance) |
| Resistance of R1 alone (power disconnected) | about 10 kΩ | A measured resistance value. With R1 and R2 still in series, it reads about 20 kΩ |

## Verification with LTspice

`sim/01-multimeter.cir` solves the voltage divider in Fig. 1 (the ammeter is 0 Ω and the voltmeter is ideal).

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Circuit current | 0.25 mA | 0.250 mA | Match |
| Voltage across R2 | 2.5 V | 2.50 V | Match |

The effect of the internal resistance of a real multimeter is covered in 0-4.

## Sources

Original work.

See also: [Multimeter (Wikipedia)](https://ja.wikipedia.org/wiki/テスター), [Ohm's law (Wikipedia)](https://ja.wikipedia.org/wiki/オームの法則), [Lessons in Electric Circuits Vol. I, Chapter 8: DC metering circuits](https://www.ibiblio.org/kuphaldt/electricCircuits/DC/DC_8.html)
