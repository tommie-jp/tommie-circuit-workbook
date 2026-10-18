---
book: circuits
chapter: 10
id: 10-1
title: Basic Gates — AND / OR / NOT with Switches and LEDs
tier: 50
source: 自作
board: BB
ja: 629b5e7216c65024fc0236fed7d3b992ba3b10a6
---

# 10-1 Basic Gates — AND / OR / NOT with Switches and LEDs

A digital circuit treats a high or low voltage as 1 or 0. 1 is the H level (High,
almost the supply voltage) and 0 is the L level (Low, almost 0 V). A circuit that decides the 0 or 1 of its
output from the 0 or 1 of its inputs by a fixed rule is called a **gate**, and every digital circuit is
built from combinations of gates. In this exercise you check the three most basic gates with LEDs.

- AND: the output is 1 only when both inputs are 1
- OR: the output is 1 when either input is 1
- NOT (inverter): outputs the opposite of the input (1 if 0, 0 if 1)

The gate ICs are CD4000-series CMOS (logic ICs built from MOSFETs; almost no current flows into an input).
Place three ICs side by side, and feed the same two switch inputs (A and B) to both the AND and the OR
and compare the outputs. The other switch, C, goes into the NOT.
If the LED is lit the output is 1, and if it is dark the output is 0.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 AND, OR and NOT side by side for comparison
parts:
  A: switch 3,4 3,6
  RpdA: resistor 3,6 1,6 10k
  GA: ground 1,6
  B: switch 6,3 6,5
  RpdB: resistor 6,5 4,5 10k
  GB: ground 4,5
  C: switch 9,2 9,4
  RpdC: resistor 9,4 7,4 10k
  GC: ground 7,4
  VCC: vcc 3,4 5V
  VCC: vcc 6,3 5V
  VCC: vcc 9,2 5V
  U1: and 14,8 CD4081
  U2: or 20,8 CD4071
  U3: not 26,8 CD4069
  R1: resistor 16,8 16,10 1k
  D1: led 16,10 16,11 red
  GD1: ground 16,11
  R2: resistor 22,8 22,10 1k
  D2: led 22,10 22,11 red
  GD2: ground 22,11
  R3: resistor 28,8 28,10 1k
  D3: led 28,10 28,11 red
  GD3: ground 28,11
wires:
  - 3,6 -- 12,6 -- 18,6
  - 6,5 -- 11,5 -- 17,5
  - 9,4 -- 24,4
  - 12,6 |- U1.a
  - 11,5 |- U1.b
  - 18,6 |- U2.a
  - 17,5 |- U2.b
  - 24,4 |- U3.in
  - U1.out -- 16,8
  - U2.out -- 22,8
  - U3.out -- 28,8
notes:
  # PIN numbers of the IC (first gate)
  - text 12.8,7.6 small center: "1"
  - text 12.8,8.4 small center: "2"
  - text 14.2,7.7 small center: "3"
  - text 18.8,7.6 small center: "1"
  - text 18.8,8.4 small center: "2"
  - text 20.2,7.7 small center: "3"
  - text 25.4,7.7 small center: "1"
  - text 26.5,7.7 small center: "2"
  - text 1,10 small left: "Numbers are IC PIN numbers (the first gate is used)"
  - text 1,11 small left: "VDD: PIN 14 (+5V), VSS: PIN 7 (GND). Unused inputs: GND"
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/circuit/01-basic-gates.svg)

- U1 (CD4081, AND) and U2 (CD4071, OR) take the same A and B as inputs. Each contains four gates, and
  only gate 1 (PIN 1 and 2 → 3) is used.
- U3 (CD4069, hex inverter) uses gate 1 (PIN 1 → 2). C goes into the NOT.
- When a switch is open, the input is pulled down to 0 V (0) by a pull-down resistor (RpdA to RpdC, 10 kΩ; a resistor that pulls the input down to GND).
  When it is closed, the input becomes +5 V (1). The input of a CMOS gate is neither 0 nor 1 if it is left floating,
  so the pull-down fixes the potential even while the switch is open.
- Fig. 1 draws the gates with logic symbols and adds the PIN numbers of the IC to the pins of the symbols. The power pins do not
  appear on the symbols, so they are written under the figure. On all three ICs, PIN 14 is VDD (+5 V) and PIN 7 is VSS (GND).
- Connect unused inputs to GND. For U1 and U2 these are the inputs of the remaining 3 gates (PIN 5, 6, 8, 9, 12, 13),
  and for U3 the inputs of the remaining 5 inverters (PIN 3, 5, 9, 11, 13). A floating CMOS input
  wanders on its own and draws current. Leave the output pins (PIN 4, 10, 11 of U1 and U2; PIN 4, 6, 8, 10, 12 of U3)
  open with nothing connected.

### Why the LED resistor is 1 kΩ

The output of a CD4000-series gate drops in voltage the more current is drawn from it. The current an output that is
driving H can source is called I<sub>OH</sub>. In the TI datasheet (CD4081B, V<sub>DD</sub> = 5 V, 25 °C), it is
at least 0.51 mA (typically 1 mA) when the output is at 4.6 V, and even when the output has dropped to 2.5 V it is only
at least 1.6 mA (typically 3.2 mA). The datasheets of the CD4071B and CD4069UB give the same values.
The output of a CD4000-series gate running at 5 V is limited to a few mA, so if you designed it to pass
(5 V − 2.0 V) / 330 Ω ≈ 9.1 mA with 330 Ω, the output voltage would sag and not match the calculation.

So the series resistors R1 to R3 of the LEDs are set to 1 kΩ to hold the current to around 2 mA. With the output voltage
V<sub>OH</sub> and the forward voltage of the LED V<sub>F</sub> (about 1.8 V for a red LED at 2 mA, a rough guide),

I = (V<sub>OH</sub> − V<sub>F</sub>) / R

V<sub>OH</sub> is set by the current drawn. Representing the relation between the output voltage drop and the current by a curve through the two points above,
and solving for the point that satisfies this equation as well in python gives the following (rough guides).

- Typical part: V<sub>OH</sub> ≈ 4.0 V, I = (4.0 V − 1.8 V) / 1 kΩ ≈ 2.2 mA
- Minimum part: V<sub>OH</sub> ≈ 3.3 V, I = (3.3 V − 1.8 V) / 1 kΩ ≈ 1.5 mA

Even around 2 mA the LED visibly lights. If it is dim, use a high-brightness LED, or switch to
the 74HC series, which has stronger outputs (74HC08 for AND, 74HC32 for OR, 74HC04 for NOT).

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  A: switch b10 b12
  B: switch b3 b5
  C: switch b45 b47
  RpdA: resistor j24 -b24 10k
  RpdB: resistor j39 -b39 10k
  RpdC: resistor j52 -b52 10k
  U1: dip14 @ e24 CD4081
  U2: dip14 @ e38 CD4071
  U3: dip14 @ e52 CD4069
  R1: resistor g26 g33 1k
  D1: led h33(A) h35(K) red
  R2: resistor g40 g45 1k
  D2: led h45(A) h46(K) red
  R3: resistor g53 g60 1k
  D3: led h60(A) h62(K) red
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t3 -- a3 red
  - +t10 -- a10 red
  - +t45 -- a45 red
  - a12 -- a22 yellow
  - e22 -- f22 yellow
  - g22 -- g24 yellow
  - b22 -- b37 yellow
  - e37 -- f37 yellow
  - g37 -- g38 yellow
  - d5 -- d20 green
  - e20 -- f20 green
  - h20 -- h25 green
  - c20 -- c36 green
  - e36 -- f36 green
  - h36 -- h39 green
  - c47 -- g52 blue
  - a24 -- +t24 red
  - j30 -- -b30 black
  - a38 -- +t38 red
  - j44 -- -b44 black
  - a52 -- +t52 red
  - j58 -- -b58 black
  - j35 -- -b35 black
  - j46 -- -b46 black
  - j62 -- -b62 black
  # Unused inputs to GND (upper ones to the top blue rail, lower ones to the bottom blue rail)
  - a25 -- -t25 black
  - a26 -- -t26 black
  - a29 -- -t29 black
  - a30 -- -t30 black
  - j28 -- -b28 black
  - j29 -- -b29 black
  - a39 -- -t39 black
  - a40 -- -t40 black
  - a43 -- -t43 black
  - a44 -- -t44 black
  - j42 -- -b42 black
  - j43 -- -b43 black
  - a53 -- -t53 black
  - a55 -- -t55 black
  - a57 -- -t57 black
  - j54 -- -b54 black
  - j56 -- -b56 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/breadboard/01-basic-gates.svg)

- The power comes from Supplies of the Analog Discovery 3 (AD3, the USB instrument used in 0-3). In Supplies of WaveForms, set
  V+ to 5 V (three AA batteries or the 5 V of USB also work). Top red rail = +5 V, blue rail = GND.
  V+ (red) of the AD3 goes to column 1 of the top red rail, and GND (black) goes to column 2 of the top blue rail (place the AD3 at the upper left of the breadboard). The bottom blue rail is joined to the top blue rail
  at column 1.
- U1 (CD4081, AND) occupies columns 24–30, U2 (CD4071, OR) columns 38–44, and U3 (CD4069, NOT)
  columns 52–58. In all of them the notch is on the left, PIN 1 is at the lower left (row f), and PIN 14 is at the upper left (row e).
- Power: connect PIN 14 of each IC (above columns 24, 38 and 52) to the top red rail, and PIN 7 (VSS, below columns 30, 44 and 58)
  to the bottom blue rail.
- The switches are in the upper block (B at columns 3–5, A at columns 10–12, C at columns 45–47). Put only one
  wire in each hole. To split a connection, take it from another hole in the same column (the five vertical holes are connected inside).
  - A (yellow): `a12` → `a22`. At column 22 cross the gap (`e22` → `f22`), then `g22` → PIN 1 of U1 (`g24`).
    To U2: `b22` → `b37`, cross the gap at column 37 (`e37` → `f37`), then `g37` → PIN 1 of U2 (`g38`).
  - B (green): `d5` → `d20`. At column 20 cross the gap (`e20` → `f20`), then `h20` → PIN 2 of U1 (`h25`).
    To U2: `c20` → `c36`, cross the gap at column 36 (`e36` → `f36`), then `h36` → PIN 2 of U2 (`h39`).
  - C (blue): `c47` → PIN 1 of U3 (`g52`).
- Insert the pull-down resistors (RpdA, RpdB, RpdC) vertically from row j of the input column of each IC to the bottom blue rail
  (RpdA at column 24, RpdB at column 39, RpdC at column 52).
- The outputs (PIN 3 of U1 and U2 = columns 26 and 40, PIN 2 of U3 = column 53) go through the 1 kΩ in row g and the LED in row h
  to the bottom blue rail.
- Connect the unused inputs to GND with short black wires. The upper pins (PIN 8, 9, 12, 13 of U1 and U2; PIN
  9, 11, 13 of U3) go from row a to the top blue rail, and the lower pins (PIN 5, 6 of U1 and U2; PIN 3, 5 of U3)
  go from row j to the bottom blue rail.

## Instrument settings

The only instrument is Supplies (power supply) of the AD3, and the 0 or 1 of each output is read from the LEDs and a multimeter.
This exercise has no oscilloscope figure. It only looks at DC voltages (0 or 1) while the switches are held, and nothing changes with time.

The current through the breadboard is about 2.2 mA × 3 ≈ 7 mA even with all 3 LEDs lit, plus the pull-down of the closed switches,
5 V / 10 kΩ = 0.5 mA × 3, for a total under 10 mA. That fits within the limits of the breadboard (200 mA per hole, 500 mA for the whole breadboard) and
within the guide for using V+ of the AD3 on USB power (50 mA at 5 V).

## Values to check

| A | B | AND (D1) | OR (D2) |
| --- | --- | --- | --- |
| 0 | 0 | Dark | Dark |
| 1 | 0 | Dark | **Lit** |
| 0 | 1 | Dark | **Lit** |
| 1 | 1 | **Lit** | **Lit** |

| C | NOT (D3) |
| --- | --- |
| 0 | **Lit** |
| 1 | Dark |

A closed switch is 1 and an open switch is 0. AND lights only when A and B are both closed. OR lights when either
one is closed. NOT lights only while C is open (input 0 → output 1).

To check with the multimeter, measure between the output PIN of each IC (PIN 3 for U1 and U2, PIN 2 for U3) and
GND on the DC voltage range. It is about 3.3–4 V (1) when the LED is lit, and almost 0 V (0) when it is dark.

## Verification with LTspice

In `sim/01-basic-gates.cir`, the gates are ideal logic of B sources (threshold 2.5 V), and the output stage is a 5 V source with R<sub>on</sub> = 400 Ω / 800 Ω (an estimate from the output-current data of the CD4000 series datasheet; not measured), driving 1 kΩ + LED.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| AND (A, B = 00 / 01 / 10 / 11) | 0 / 0 / 0 / 1 | 0 / 0 / 0 / 5 V | Agrees |
| OR (A, B = 00 / 01 / 10 / 11) | 0 / 1 / 1 / 1 | 0 / 5 / 5 / 5 V | Agrees |
| Output voltage while the LED is lit (1) | About 3.3–4 V | 3.6 V (R<sub>on</sub> 800 Ω) to 4.1 V (400 Ω), current 1.7–2.2 mA | Agrees |
| Output while dark (0) | Almost 0 V | 0 V | Agrees |

## Sources

Original work.
