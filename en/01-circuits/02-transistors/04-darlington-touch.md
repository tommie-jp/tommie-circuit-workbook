---
book: circuits
chapter: 2
id: 2-4
title: Darlington Pair, Lit by a Finger Touch
tier: 50
source: 自作
board: BB
ja: 42aaeafd86693b6e7f99dca618611bd55f901ff1
---

# 2-4 Darlington Pair, Lit by a Finger Touch

Connect two transistors **from the emitter of Q1 to the base of Q2**, and join the two collectors, and the current gain
of the whole is the product of the two hFE values (a Darlington connection). Even the tiny current that passes through
the skin of a finger (several hundred kΩ) can be amplified to a current large enough to light an LED.

In this exercise you build a switch that lights an LED when a finger touches two metal plates, and you look at the base
and collector voltages at the moment of touch on the oscilloscope.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Darlington touch switch (CH2 base, CH1 collector)
parts:
  VCC: vcc 2,2 5V
  TP1: port 4,2
  TP2: port 3,7
  RB: resistor 4,7 4,9 1M
  G2: ground 4,9
  Q1: npn 7,7
  Q2: npn 9,8
  RC: resistor 9,2 9,4 470
  D1: led 9,4 9,6
  G3: ground 9,9
  M2: voltmeter 3,7 3,9 l=$\mathrm{CH2}$
  G5: ground 3,9
  M1: voltmeter 11,6 11,9 l=$\mathrm{CH1}$
  G4: ground 11,9
wires:
  - 2,2 -- 4,2 -- 9,2
  - 3,7 -- 4,7 -- Q1.B
  - Q1.E |- Q2.B
  - 9,6 -| Q1.C
  - 9,6 -- Q2.C
  - Q2.E -- 9,9
  - 9,6 -- 11,6
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/04-darlington-touch.svg)

`TP1` and `TP2` in Fig. 1 are the two metal plates touched by the finger (aluminum foil or screw heads). When a finger
touches both plates, current flows from +5 V through the finger to the base.
When nothing touches them, `RB` (1 MΩ) pulls the base of Q1 toward GND and keeps it OFF.

- The current that flows through the resistance of the finger (assume 500 kΩ; in practice it varies widely, from about
  100 kΩ to 1 MΩ) into the base node: I ≈ (5 V − 1.4 V) / 500 kΩ ≈ **7.2 µA**
  (1.4 V is the base-emitter drop of the two Darlington stages). `RB` (1 MΩ) takes
  1.4 V / 1 MΩ ≈ **1.4 µA** from the same node to GND, so the current that actually
  enters the base of Q1 is 7.2 − 1.4 ≈ **5.8 µA** (calculated value)
- If the hFE of the 2SC1815 is assumed to be 200, the current gain of the whole Darlington pair is
  200 × 200 = **40000** (theoretical value; in practice it often falls to a few thousand because of leakage current and so on)
- The LED current is **capped by RC**, not by the gain (because the transistors saturate fully):
  I<sub>C</sub> = (5 − V<sub>CE(sat)</sub> − V<sub>F</sub>) / RC ≈ (5 − 0.8 − 2.0) / 470
  ≈ **4.7 mA** (calculated value; the V<sub>CE(sat)</sub> of a Darlington pair is about 0.8 V)
- The minimum base current needed for saturation is 4.7 mA / 40000 ≈ 0.12 µA. The finger current (about 5.8 µA)
  is more than enough even at the real gain (lower than the ideal). This is why
  "a light touch is enough to turn it on"

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Darlington touch switch
# 5V goes from V+ of the AD to the top + rail; GND to the top − rail (the bottom rails are not used)
board: half
parts:
  RB: resistor b7 b12 1M
  Q1: transistor e12(B) e13(C) e14(E) 2SC1815
  Q2: transistor e17(B) e18(C) e19(E) 2SC1815
  RC: resistor b25 b20 470
  D1: led c20(A) c18(K) red
  TP1:
    type: device
    at: top
    label: Touch plate 1 (+)
    pins: [A]
  TP2:
    type: device
    at: top
    label: Touch plate 2
    pins: [B]
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [2-, 2+, 1+, 1-, V+, GND]
wires:
  - AD.V+ -- +t29 red
  - AD.GND -- -t30 black
  - a7 -- -t7 black
  - AD.2- -- -t9 black
  - AD.2+ -- a12 blue
  - d4 -- d12 blue
  - TP2.B -- a4 gray
  - b13 -- b18 orange
  - c14 -- c17 blue
  - a19 -- -t19 black
  - +t25 -- a25 red
  - AD.1+ -- a18 orange
  - AD.1- -- -t27 black
  - TP1.A -- +t3 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/04-darlington-touch.svg)

As in Fig. 2, all the parts go in the upper block. The 5 V goes from the supply output V+ of the Analog Discovery 3 (red, `+t29` at the right end) to
the top + rail (set V+ to 5 V in Supplies in WaveForms).
The only current drawn is the LED's about 4.7 mA, so V+ is enough. Only the top − rail is used for GND.

- `Q1` and `Q2` are in row e of the upper block (`e12` to `e14` and `e17` to `e19`). Rows a to d above the pins serve as paths for the wires
- **Base (column 12)**: the right end of `RB` (`b12`) is in the same column as B of `Q1`. The left end of `RB` goes from `a7` to the − rail.
  `TP2` (touch plate 2) is plugged into `a4` and carried over to column 12 by the blue wire `d4`–`d12`
- **E of Q1 to B of Q2**: the blue wire `c14`–`c17`. **C of Q1 to C of Q2**: the orange wire `b13`–`b18`
- **Collector (column 18)**: the LED cathode (`c18`) is in the same column as C of `Q2`. The LED anode (`c20`) is in the same column as
  the left end of `RC` (`b20`), and the right end of `RC` goes from `a25` to the + rail
- The emitter of `Q2` goes from `a19` to the − rail. `TP1` (touch plate 1) goes to the + rail (`+t3`)
- **CH1 (1+, orange)** goes to column 18 of the collector (`a18`) and **CH2 (2+, blue)** to column 12 of the base (`a12`).
  GND, 1− and 2− of the AD (black) go to the top − rail

## Viewing on the oscilloscope

Set CH1 to 1 V/div, CH2 to 500 mV/div and the time base to 20 ms/div. Trigger on the rising edge of CH2
(0.7 V) in Single, which freezes the screen once, and then touch both plates with a finger (Fig. 3).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Touch, base (CH2) rises, collector (CH1) drops
time: 20ms/div
trigger: ch2 rising 0.7V
ch1: {wave: = 3.5V - 2.7V * step(t) | rc 200us, range: 1V/div, position: -3div}
ch2: {wave: = 1.4V * step(t) | rc 200us, range: 500mV/div, position: -3div}
cursors: [-50ms, 50ms]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/04-darlington-touch.svg)

- Before the touch (X1): CH2 is 0 V because of `RB`, and CH1 is about 3.5 V. Only the tiny current that flows into the
  oscilloscope input (1 MΩ) passes through the LED, so it does not light (this value is a rough guide that varies with the LED and the oscilloscope)
- After the touch (X2): CH2 is capped at the V<sub>BE</sub> of the two stages (about 1.4 V), and
  CH1 drops to about 0.8 V (V<sub>BE</sub> of Q2 plus the saturation voltage of Q1). The LED lights
- If the finger is dry and the current is too small, CH1 does not drop all the way to 0.8 V and wobbles with 50/60 Hz
  hum (mains picked up by the finger). In that case moisten the finger or make `RB` larger

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| RC | Resistor (1/4 W) | 470 Ω |
| RB | Resistor (1/4 W) | 1 MΩ |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1, Q2 | NPN transistor | 2SC1815 |
| TP1, TP2 | Metal plates to touch (aluminum foil, screw heads, etc.) | — |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

| Measure | Expected value | What it shows |
| --- | --- | --- |
| LED when not touched | Off | RB pulls the base of Q1 to GND |
| LED when both plates are touched with a finger | On (about 4.7 mA, calculated value) | Even a tiny finger current saturates the transistors fully |
| CH1 (collector) / CH2 (base) before the touch | about 3.5 V (rough guide) / 0 V | The transistors are OFF and the base is at GND through RB |
| CH2 (base of Q1) at the touch | about 1.4 V | Capped at the V<sub>BE</sub> of two stages |
| CH1 (C-E voltage of Q2) at the touch | about 0.8 V | A Darlington pair keeps a larger saturation voltage than a single transistor (about 0.1 to 0.2 V) |
| With RB replaced by 100 kΩ | May not light, depending on how dry the finger is | If RB is too small, most of the finger current escapes through RB |

## Verification with LTspice

`sim/04-darlington-touch.cir` runs a transient analysis of Fig. 1 and reads the values with the finger resistance swept over 100 kΩ / 500 kΩ / 2 MΩ / no touch (1 GΩ).
Q1 and Q2 are substitute models for the 2SC1815 (the same IS, BF, VAF and IKF as `09-rf/sim/agc.cir`; an assumption made from rough guides, not a measurement),
the LED is an assumed model whose V<sub>F</sub> is about 1.5 V (1 µA) and about 2.0 V (8.5 mA), and CH1 is placed as a 1 MΩ load.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Current through Rf with a 500 kΩ finger | about 7.2 µA | 7.5 µA | Match |
| LED current with a 500 kΩ finger | about 4.7 mA | 4.9 mA | Match |
| CH1 (collector) with a 500 kΩ finger | about 0.8 V | 0.72 V | Match (V<sub>BE</sub> 0.68 V plus the saturation voltage of Q1) |
| CH2 (base of Q1) with a 500 kΩ finger | about 1.4 V | 1.23 V | Close (the model's V<sub>BE</sub> is 0.68 V at 5 mA, a little over 1.2 V for two stages) |
| CH1 and CH2 with no touch (1 MΩ on CH1) | about 3.5 V and 0 V | 3.43 V and 0.005 V | Match |
| LED current with a 100 kΩ and a 2 MΩ finger | On (fully saturated) | 5.0 mA and 4.8 mA | Match |

The CH2 probe (1 MΩ) is in parallel with R<sub>B</sub>, so with a 2 MΩ finger the current is taken by R<sub>B</sub> ∥ 1 MΩ and the LED dims to about 0.08 mA
(4.8 mA without the probe). When the finger is dry, disconnect CH2 to watch.

## Sources

Original work.
