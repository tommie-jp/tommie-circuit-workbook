---
book: circuits
chapter: 5
id: 5-3
title: Three-terminal regulator (7805)
tier: 50
source: 自作
board: [BB, PF]
ja: ddd18b5ee60b6cdaa8133b201f28507acaa06ea7
---

# 5-3 Three-terminal regulator (7805)

Make 5 V from a 9 V battery with a single IC, the 7805. The three-terminal regulator packs the Zener + transistor
regulator of 5-2 into one IC, including the mechanism that corrects the error. You only connect its three pins:
input (IN), GND and output (OUT). The output stays at 5 V even when the input wanders a little, so it is the standard
power source for circuits that run on 5 V. In this exercise the power comes from Supplies on the Analog Discovery 3
(AD3), and you use the oscilloscope (Scope) to check that **the output stays at 5 V while the supply voltage changes
from 7 V to 10 V**.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 5 V from a 7805 (V1 is the AD3 supply, 7 to 10 V)
parts:
  V1: vsource vin gnd 10
  G1: ground gnd
  U1: regulator 5,2 7805
  Cin: capacitor 3,2 3,4 0.33u
  Cout: capacitor 7,2 7,4 0.1u
  RL: resistor 9,2 9,4 1k
  Rled: resistor 11,2 11,3 680
  Dled: led 11,3 11,4 red
  M1: voltmeter 13,2 13,4 l=$\mathrm{CH1}$
points:
  vin: 1,2
  gnd: 1,4
wires:
  - vin -- 3,2 -- U1.in
  - U1.out -- 7,2 -- 9,2 -- 11,2 -- 13,2
  - U1.gnd -- 5,4
  - gnd -- 3,4 -- 5,4 -- 7,4 -- 9,4 -- 11,4 -- 13,4
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/circuit/03-three-terminal-regulator.svg)

- Cin (0.33 µF) is the input-side capacitor and Cout (0.1 µF) is the output-side capacitor. Both prevent oscillation
  and improve the response to sudden load changes. These are the standard values the datasheet specifies
- RL (1 kΩ) is the main load. Rled (680 Ω) and Dled form an indicator LED that shows the power is on.
  The load is kept light to stay within the limits of Supplies on the AD3 (50 mA per rail, and 250 mW in total on USB power).
  The total current is 5 + 4.4 mA plus a few mA drawn by the 7805 itself, about 14 mA, and about 140 mW at a 10 V input
- The input V1 is the voltage between V+ and V− of Supplies on the AD3. **Connect the GND pin of the 7805 to V−**. The input
  becomes V+ − V−, and the output is 5 V measured from the GND pin (V−). Set V+ and V− to the same magnitude
  (±3.5 V to ±5 V) and move the input from 7 V to 10 V
- While the input is above 7 V, the output stays at 5 V. The dropout of the 7805 (the input-output difference needed to
  hold the output, seen in 5-2) is about 2 V

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard (power from AD3 Supplies)
board: half
parts:
  U1: regulator/to220 e8(in) e9(gnd) e10(out) 7805
  Cin: capacitor f5 f8 0.33uF
  Cout: capacitor f10 f13 0.1uF
  RL: resistor f14 f18 1k
  Rled: resistor h14 h20 680
  Dled: led f20(A) f23(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Supplies and Scope)
    pins: [V+, V-, 1+, 2+, 1-, 2-]
wires:
  - AD.V+ -- +b2 red
  - AD.V- -- -b3 black
  - +b8 -- j8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - i10 -- i14 orange
  - j18 -- -b18 black
  - j23 -- -b23 black
  - AD.1+ -- j10 orange
  - AD.2+ -- +b12 yellow
  - AD.1- -- -b24 black
  - AD.2- -- -b25 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/breadboard/03-three-terminal-regulator.svg)

- Hold the 7805 (TO-220) with the marked face toward you and the pins down. From the left the pins are IN, GND, OUT,
  and the heat sink (the metal tab with a hole) is at the top. The 7805 in the figure is drawn in this orientation,
  with the part number printed on the body
- The pins of U1 (IN, GND, OUT = columns 8, 9, 10) are carried from row e of the upper block to the lower block by wires
- V+ of Supplies (red) goes to the lower + rail and V− (black) to the lower − rail. From the lower + rail go to column 8
  (IN) (`j8`). Always connect the GND pin (column 9) to the − rail (`j9`). If it floats, the output is not 5 V
- Cin (columns 5 and 8) goes between IN and GND, and Cout (columns 10 and 13) goes between OUT and GND. Keep the
  leads short and plug them in right next to the regulator
- The output is carried from column 10 of the lower block to column 14 (`i10` to `i14`) and distributed to RL and Rled.
  The GND sides of RL, Rled and Dled go to the − rail
- For Scope, connect 1+ (orange) to column 10 of OUT (`j10`), 2+ (yellow) to the lower + rail (IN), and 1− and 2− (black)
  to the lower − rail. 1− and 2− connect to V− (the same potential as the GND pin). V− is −3.5 to −5 V, which is within
  the input range of Scope (±25 V)

## Perfboard wiring diagram

```perf
# Perfboard wiring diagram (tommie-fence perf fence)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  slots: on
unused: [J2.D+, J2.D-]
title: Fig. 3 Building it on a perfboard (component side; yellow circles mark AD3 clip points)
parts:
  J1: sip2 b15
  J2: usb-c/female t5 u5 v5 w5
  U1: regulator/to220 f9 g9 h9 7805
  Cin: capacitor/ceramic e9 e6 0.33u
  Cout: capacitor/ceramic k9 k6 0.1u
  RL: resistor m9 m5 1k
  Rled: resistor p9 p6 680
  Dled: led p5 p3 red
wires:
  - b15 -- b17 red
  - b17 -- e17 red
  - e17 -- e9 red
  - f9 -- e9 red
  - c15 -- c3 black
  - c3 -- e3 black
  - e3 -- g3 black
  - g3 -- k3 black
  - k3 -- m3 black
  - m3 -- p3 black
  - p3 -- s3 black
  - s3 -- s5 black
  - s5 -- t5 black
  - e6 -- e3 black
  - g9 -- g3 black
  - k6 -- k3 black
  - m5 -- m3 black
  - h9 -- k9 orange
  - k9 -- m9 orange
  - m9 -- p9 orange
  - p9 -- w9 orange
  - w9 -- w5 orange
  - p6 -- p5 orange
notes:
  - mark b15 yellow
  - mark c15 yellow
  - mark n9 yellow
  - mark e13 yellow
  - mark j3 yellow
  - text b15 red large bold left: V+
  - text c15 red large bold right: V-
  - text n10 red large bold center: AD3 1+
  - text e13 red large bold right: AD3 2+
  - text j4 red large bold center: AD3 1-/2-
  - text w3 red large bold: OUT 5V
  - parts
style:
  back: on
  labels:
    sides: left bottom
```

![Perfboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/perfboard/03-three-terminal-regulator.svg)

- If you keep using the supply, solder it onto a perfboard, because breadboard connections are unreliable. The voltage is
  7 to 10 V (12 V or less), the current is about 14 mA (500 mA or less) and the frequency is DC, so it is within the
  range of a perfboard
- The perfboard is a 5×7 cm board with pads, used in landscape (24 columns × 18 rows, 1.6 mm FR-4). Addresses follow
  the board's printing: letters are columns (A to X from the left) and numbers are rows (1 to 18 from the bottom). The
  figure above is the view from the component side, and the figure below it is the solder side (columns reversed
  left to right)
- J1 (2-pin pin header, B15 and C15) is where you clip on Supplies of the AD3. B15 is V+ and C15 is V−. V+ goes along
  the strip on row 17 (red), down column E to E9 (IN). V− goes down column C to the GND strip on row 3 (black)
- The 7805 (TO-220, F9, G9, H9 = IN, GND, OUT) stands with its heat sink up. GND (G9) goes down column G to the GND
  strip. OUT (H9) is carried to the right along row 9 (orange) and distributed to Cout (K9, K6), RL (M9, M5), Rled (P9, P6)
  and the output USB-C (W9 to W5). After Rled comes Dled (P5, P3)
- **The output is a female USB-C (J2, T5 to W5 at the lower right end)**. It is a USB-C power breakout module, and
  its receptacle faces the lower edge and stays within the board. Connect the 5 V of OUT to VBUS (W5) and the GND strip
  (through S5 to row 3) to GND (T5). D+ and D− are not used (they are listed under `unused:`)
- J2 is not a USB-standard output. It is only a breakout that passes power, and with no source resistor (Rp) on CC, a
  USB-C device such as a smartphone does not recognize it as a power source. Do not connect a USB device, a PC or a
  charger to J2 (its 5 V would collide with yours and may destroy it). Use it as an outlet that passes power by cable to
  a 5 V experimental circuit. Write `OUT 5V` on the real board as well
- The GND sides of Cin (E9, E6), Cout (K9, K6), RL (M5) and the cathode of Dled (P3) all connect to the GND strip on row 3
- The yellow circles are **where you clip the AD3 only while measuring**, and they are never wired permanently. V+ and V−
  of the AD3 go to J1 (B15, C15), 1+ of Scope to OUT (N9), 2+ to the IN line (E13), and 1− and 2− to the GND strip (J3),
  clipped at the places with the large bold red names
- The wires are only vertical and horizontal, with no crossings

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Three-terminal regulator (TO-220) | 7805 |
| Cin | Ceramic capacitor (input side) | 0.33 µF |
| Cout | Ceramic capacitor (output side) | 0.1 µF |
| RL | Resistor (main load) | 1 kΩ |
| Rled | Resistor (indicator LED current limit) | 680 Ω |
| Dled | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| J1 | Pin header (2 pins; Fig. 3 only; Supplies is clipped on) | — |
| J2 | USB-C power breakout module (Fig. 3 only; outlet for the 5 V output) | Female, lower right end. Do not connect USB devices |
| — | Board (Fig. 3) | Perfboard 5×7 cm with pads (landscape, 1.6 mm FR-4) |
| — | Instruments and power | Supplies (V+ and V−) and Scope (1+ = OUT, 2+ = IN, 1− and 2− = V−) of the Analog Discovery 3 |

The power comes from Supplies on the AD3. A 5 V supply alone is not enough for the input of a 7805, so V+ and V−
together make 7 to 10 V. The 7805 needs an input-output difference (dropout) of about 2 V, so for a 5 V output the
input must be 7 V or more.

## Instrument settings

The instruments are Supplies and Scope of the Analog Discovery 3. Change the input voltage with Supplies, and use Scope to show the
input (CH2) and output (CH1) side by side on one screen.

1. Set V+ of Supplies to 3.5 V and V− to −3.5 V, and turn Master on (the input is the difference, 7 V)
2. Set Scope to DC coupling, the time base to 10 s/div and Mode to Screen (the display scrolls).
   Set CH1 to 500 mV/div with an offset of 5 V (the 5 V output is at the center of the screen) and CH2 to 500 mV/div
   with an offset of 8.5 V (so that the 7 to 10 V input fits)
3. Every 25 seconds, raise V+ by 0.5 V and V− by the same amount (±3.5 V → ±4 V → ±4.5 V → ±5 V). The input steps
   up as 7 V → 8 V → 9 V → 10 V

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 4 Input (CH2) rises 7 to 10 V, output (CH1) stays 5 V
time: 10s/div
trigger: ch2 rising 7.5V at -4div
ch1: {wave: dc 5V, range: 500mV/div, position: -10div}
ch2: {wave: "= 7V + 1V * step(t) + 1V * step(t - 25s) + 1V * step(t - 50s)", range: 500mV/div, position: -17div}
cursors: [12s, 62s]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/scope/03-three-terminal-regulator.svg)

- The figure shows the shape when the 7805 works ideally (if you overlay a measured CSV with `data:`, it appears as a
  solid line)
- CH2 (input) is a staircase in steps of 1 V, and CH1 (output) stays a flat line even when magnified to 500 mV/div.
  The output read at cursor X1 (when the input is 8 V) and at X2 (when it is 10 V) is almost the same

## Values to check

The values in the table are calculated values. In a measurement, read the voltages with the Scope readout (Measurements)
and the cursors. Find the currents by dividing the measured voltage by the resistance.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Output (CH1) | 5.00 V (±4 %, 4.8 to 5.2 V). It does not move when the input changes | Nearly constant when the input is 7 V or more. This is the typical value in the 7805 datasheet: when the input changes by 2 V, the output moves only a few mV (line regulation) |
| Input (CH2) | 7 V → 8 V → 9 V → 10 V | The difference between V+ and V− set in Supplies |
| Difference of the cursors (CH1 at X1 and X2) | a few mV or less | The output barely changes when the input changes by 2 V |
| Current in RL | 5 mA | 5 V ÷ 1 kΩ |
| Current in Dled | about 4.4 mA | (5 V − 2.0 V) ÷ 680 Ω |
| Dissipation in U1 (10 V input) | about 70 mW | (10 V − 5 V) × total current (about 14 mA). No problem at room temperature even without a heat sink |
| Input lowered to 6 V (±3 V) | The output starts to fall below 5 V | When the input-output difference drops below the dropout voltage (about 2 V), the output can no longer be held |

Increasing the load current (making RL smaller) increases the heating of U1. As it approaches 1 A, a heat sink is
needed (calculate it from the thermal resistance in the datasheet; covered in 7-12). Supplies on the AD3 supplies up to
50 mA per rail, so do not make the load heavier than in this exercise.

## Verification with LTspice (not applicable)

The 7805 is a part that holds its output through the inside of the IC, and it has no internal model that SPICE can verify
(the values are typical values from the datasheet). The numbers in the text were checked by arithmetic. The current in RL
is 5 V ÷ 1 kΩ = 5 mA, that in Dled is (5 V − 2.0 V) ÷ 680 Ω ≈ 4.4 mA, and the dissipation in U1 is
(10 V − 5 V) × about 14 mA = about 70 mW (the about 14 mA is the load's 9.4 mA plus a quiescent current of a few mA).

## Sources

Original work.
