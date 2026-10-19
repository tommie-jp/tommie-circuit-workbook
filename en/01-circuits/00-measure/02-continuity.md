---
book: circuits
chapter: 0
id: 0-2
title: Breadboard Continuity and Reading a Schematic — Columns, Rails and Nets
tier: 50
source: 自作
board: BB
ja: 982fb1b4238162264d0184c20cfa36cae686b849
---

# 0-2 Breadboard Continuity and Reading a Schematic — Columns, Rails and Nets

On a breadboard, the five holes in a vertical column are joined by one metal strip inside the breadboard.
A place joined by a line in a schematic (one **net**: a set of points at the same voltage)
is represented on the breadboard either by "holes in the same column" or by a wire. Once you see this,
you can read a schematic and a wiring diagram (a drawing of which holes the parts are plugged into) as the same circuit.
You build a circuit with two LEDs and check the connections with the multimeter's continuity test.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Lighting two LEDs in parallel
parts:
  V1: vsource 2,1 2,5 5
  G1: ground 2,5
  R1: resistor 4,1 4,3 330
  D1: led 4,3 4,5
  R2: resistor 6,1 6,3 330
  D2: led 6,3 6,5
wires:
  - 2,1 -- 4,1 -- 6,1
  - 2,5 -- 4,5 -- 6,5
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/circuit/02-continuity.svg)

In Fig. 1, `R1` and `R2` both come from the same + terminal of the supply (in a schematic, points joined by a line are
the same net). Of an LED's pins, the one where current enters is called the **anode** (A) and the one where it leaves
is the **cathode** (K) (in the schematic symbol, current flows in the direction of the triangle, and the bar side is the cathode).
The cathodes of `D1` and `D2` meet at the same GND net. The relation between an LED and its resistor is covered in 1-1.

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 One column is one net
# Top red rail = +5V, blue rail = GND
board: half
parts:
  R1: resistor b8 b13 330
  D1: led d13(A) d14(K) red
  R2: resistor c8 c4 330
  D2: led e4(A) e3(K) green
  PS:
    type: device
    at: top
    label: Analog Discovery (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t8 -- a8 red
  - a14 -- -t14 black
  - b3 -- -t3 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/00-measure/breadboard/02-continuity.svg)

- The power comes from V+ of Supplies on the Analog Discovery 3 (AD) (set it to 5 V in WaveForms). Connect V+ to the top + rail and
  GND to the top − rail. Two LEDs draw about 18 mA, within what the AD supply can deliver (up to about 50 mA per rail).
- In Fig. 2, `R1` is plugged into `b8` in column 8, and `R2` into `c8`, also in column 8. They are different holes, but in the same column
  (upper block, a to e), so they are connected inside without a wire. Plug the supply wire into
  just one of them (in the figure, the free hole `a8`). `R1` extends to the right and
  `R2` to the left, so that the pins of the two branches do not land in the same row of holes.
- By the same logic, the other end of `R1` (`b13`) and the anode of `D1` (`d13`) are connected in column 13.
  The other end of `R2` (`c4`) and the anode of `D2` (`e4`) are connected in column 4.
  You can skip the jumper wire between part pins
  **only when they are plugged into the same column**.
- The long rows of holes along the top and bottom edges of the breadboard (the **rails**) are lines for distributing power and GND.
  The top red rail is one net running from end to end of the breadboard. The blue rail is the same.
  But the top and bottom rails are not connected inside the breadboard. To use the bottom rails too, join + to + and
  − to − with wires.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1, R2 | Resistor (1/4 W) | 330 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V (the voltage across it while lit; see 1-1) |
| D2 | LED (green, 5 mm) | V<sub>F</sub> ≈ 2.1 V |
| — | Power supply | V+ of the Analog Discovery 3 (5 V) |
| — | Multimeter | With a continuity test (buzzer) |

There is no oscilloscope figure. This exercise looks only at continuity and the DC current that lights the LEDs, so a multimeter is enough (the oscilloscope comes in 0-3).

## Values to check

Use the multimeter's continuity test (a range that sounds the buzzer when the resistance between two points is almost 0 Ω)
to check what is actually connected. Do the continuity test **with the power disconnected**.
Plug a short jumper wire into a free hole and touch the multimeter lead to its end.

| The two points to probe | Buzzer | Reason |
| --- | --- | --- |
| `a8` and `c8` | Sounds | Same column (upper block) |
| `a8` and `b8` | Sounds | Same column (upper block). The supply side of R1 and R2 |
| `a8` and `f8` | Does not sound | The column number is the same, but the upper and lower blocks are different nets |
| `+t8` and `+t20` | Sounds | The same rail is one net everywhere on the breadboard |
| `+t8` and `-t14` | Does not sound | The + rail and the − rail are different nets (there is a path through R and the LED, but it is not close to 0 Ω, so the buzzer stays silent) |

After checking, connect the power. The LEDs light with about 9.1 mA (red, (5 − 2.0) V ÷ 330 Ω) and
about 8.8 mA (green, (5 − 2.1) V ÷ 330 Ω) flowing. If you plug a part into the wrong column, it drops out of
that net and the LED does not light. Learning to find that cause with the continuity test is the main aim
of this exercise.

## Verification with LTspice

`sim/02-continuity.cir` solves the two parallel LEDs in Fig. 1. The LED model uses the same assumptions as 1-1 (red V<sub>F</sub> about 2.0 V @ 9 mA).
For green, V<sub>F</sub> is assumed to be about 0.1 V higher. This is not a measured value.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Current in D1 (red) | about 9.1 mA (V<sub>F</sub> 2.0 V) | 9.08 mA (V<sub>F</sub> = 2.00 V) | Match |
| Current in D2 (green) | about 8.8 mA (V<sub>F</sub> 2.1 V) | 8.84 mA (V<sub>F</sub> = 2.08 V) | Match |

The continuity table (which holes are connected) is about wiring, not circuit values, so it is out of scope for SPICE.

## Sources

Original work.

See also: [Breadboard (Wikipedia)](https://ja.wikipedia.org/wiki/ブレッドボード), [Continuity test (Wikipedia)](https://en.wikipedia.org/wiki/Continuity_test)
