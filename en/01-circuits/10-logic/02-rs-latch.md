---
book: circuits
chapter: 10
id: 10-2
title: RS Latch (NAND)
tier: 50
source: 自作
board: BB
ja: 0dbb0d3e59e151a5e27f2f8171b2b1d924ec796f
---

# 10-2 RS Latch (NAND)

In the gates of 10-1, the output changed right away when the input changed. In this exercise, the outputs of two gates are fed
back to each other's inputs to make a circuit (a **latch**) that keeps its state after you release the button.
It is the starting point of circuits that "remember", such as counters and memories.

It uses NANDs (a gate that inverts the output of an AND; it outputs 0 only when both inputs are 1).
Only two of the gates in a CD4011 (four 2-input NANDs in one package) are used. The inputs S̄ and R̄ are
active low (they act when 0): each is 0 only while its button is pressed, and returns to 1 when released through a pull-up
(RS and RR, 10 kΩ resistors that pull the input up to +5 V). The outputs are Q and Q̄ (Q-bar, the opposite value of Q).

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 RS latch of two cross-coupled NANDs
parts:
  VCC: vcc 5,2 5V
  RS: resistor 5,2 5,5 10k
  SWS: button 5,5 5,7 l=$\mathrm{SW}_\mathrm{S}$
  GSWS: ground 5,7
  VCC: vcc 3,10 5V
  RR: resistor 3,10 3,14 10k
  SWR: button 3,14 3,16 l=$\mathrm{SW}_\mathrm{R}$
  GSWR: ground 3,16
  U1A: nand 14,8 CD4011
  U1B: nand 14,13 CD4011
  RQ: resistor 20,8 23,8 1k
  DQ: led 23,8 23,10 red
  GDQ: ground 23,10
  RQb: resistor 20,13 23,13 1k
  DQb: led 23,13 23,15 red
  GDQb: ground 23,15
wires:
  - 5,5 -- 11,5
  - 11,5 |- U1A.a
  - U1A.out -- 17,8 -- 20,8
  - 17,8 -- 17,10 -- 11,10
  - 11,10 |- U1B.a
  - 3,14 -- 11,14
  - 11,14 |- U1B.b
  - U1B.out -- 18,13 -- 20,13
  - 18,13 -- 18,11 -- 9,11
  - 9,11 |- U1A.b
notes:
  - text 8,4 blue: "S (active low)"
  - text 7,13 blue: "R (active low)"
  - text 18,7 blue: "Q"
  - text 20,12 blue: "Q-bar"
  - text 1,18 small left: "Numbers are IC PIN numbers (U1A and U1B are the same CD4011)"
  - text 1,19 small left: "VDD is PIN 14 (+5V), VSS is PIN 7 (GND). Unused inputs: GND"
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/circuit/02-rs-latch.svg)

- U1A (gate 1 of the CD4011, PIN 1 and 2 → 3) is the NAND that produces Q, and U1B (gate 2,
  PIN 5 and 6 → 4) is the NAND that produces Q̄. Feeding each output back to the other's input (PIN 4 → PIN 2,
  PIN 3 → PIN 5) is the trick of the latch. In the middle of Fig. 1 the two return wires cross once
  (there is no black dot, so they are not connected).
- Pressing SWS (Set) makes PIN 1 0, and Q (PIN 3) becomes 1. Pressing SWR (Reset) makes
  PIN 6 0, and Q̄ (PIN 4) becomes 1 (= Q is 0).
- While both are released, the Q and Q̄ decided just before are held as they are
  (hence the name "latch", a catch that holds).
- The gates are drawn with logic symbols, and the PIN numbers of the IC are added to the pins of the symbols. The power pins do not
  appear on the symbols, so they are written under the figure. Connect PIN 14 (VDD) to +5 V and PIN 7 (VSS) to GND.
- Connect the inputs of the unused gates 3 and 4 (PIN 8, 9, 12, 13) to GND (not drawn in Fig. 1, but
  written under the figure). A floating CMOS input wanders on its own and draws current (10-1).
  Leave the output PIN 10 and 11 open with nothing connected.
- The series resistors RQ and RQb of the LEDs are 1 kΩ. As in 10-1, the output of a 5 V CD4000-series gate can source only a few mA
  (in the TI datasheet of the CD4011B, I<sub>OH</sub> is at least 1.6 mA at an output of 2.5 V).
  With 1 kΩ the LED current is 1.5–2.2 mA (the rough guide found in 10-1). If it is dim, use a high-brightness LED, or switch to
  the 74HC00 (the NAND of the 74HC series).

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  SWS: button @ e5
  RS: resistor b3 b5 10k
  SWR: button @ e32
  RR: resistor b36 b34 10k
  U1: dip14 @ e20 CD4011
  RQ: resistor h16 h11 1k
  DQ: led g11(A) g8(K) red
  RQb: resistor h30 h35 1k
  DQb: led i35(A) i39(K) red
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
  - +t36 -- a36 red
  - a20 -- +t20 red
  # S: column 7 → PIN 1 (column 20)
  - d7 -- d18 yellow
  - e18 -- f18 yellow
  - g18 -- g20 yellow
  # R: column 32 → PIN 6 (column 25)
  - d32 -- d28 green
  - e28 -- f28 green
  - g28 -- g25 green
  # Cross-coupling: PIN 4 → PIN 2, PIN 3 → PIN 5
  - g23 -- g21 orange
  - h22 -- h24 orange
  # Q (PIN 3) → RQ, Q-bar (PIN 4) → RQb
  - i22 -- i16 blue
  - i23 -- i30 orange
  - j7 -- -b7 black
  - j32 -- -b32 black
  - j26 -- -b26 black
  - j8 -- -b8 black
  - j39 -- -b39 black
  # Unused inputs (PIN 8, 9, 12, 13) to the top blue rail (GND)
  - a21 -- -t21 black
  - a22 -- -t22 black
  - a25 -- -t25 black
  - a26 -- -t26 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/breadboard/02-rs-latch.svg)

- The power comes from Supplies of the Analog Discovery 3 (AD3, the USB instrument used in 0-3), with V+ set to 5 V.
  V+ of the AD3 at the upper left goes to the top red rail (+t1) with a red wire, and GND goes to the top blue rail (-t2) with a black wire.
  The bottom blue rail is joined to the top blue rail at column 1.
- SWS (e5) and SWR (e32) are tactile switches. On the 4 pins that straddle the gap, connect the pull-up node to the near side
  (1a and 1b, e5/e7 or e32/e34) and GND to the far side (2a and 2b, f5/f7 or
  f32/f34). Pressing connects the near and far sides, and the input PIN is 0 only while it is pressed.
- U1 (CD4011) occupies columns 20–26. The notch is on the left, PIN 1 is at the lower left (row f), and PIN 14 is at the upper left
  (row e). Connect PIN 14 (above column 20) from a20 to the red rail, and PIN 7 (below column 26) from j26 to
  the bottom blue rail.
- S (yellow) crosses the gap with d7→d18 and e18→f18, then g18→g20 to PIN 1. R (green) goes
  d32→d28, crosses the gap with e28→f28, then g28→g25 to PIN 6. Put only one wire or pin in each hole.
- The cross-coupling is in the lower block: PIN 4→PIN 2 (g23→g21, orange) and PIN 3→PIN 5
  (h22→h24, orange).
- PIN 3 (Q, column 22) goes to RQ and DQ by the blue wire in row i (i22→i16). PIN 4 (Q̄,
  column 23) goes to RQb and DQb by the orange wire in row i (i23→i30).
- The inputs of the unused gates 3 and 4 (PIN 13, 12, 9, 8 = above columns 21, 22, 25, 26) go from row a by
  short black wires to the top blue rail (GND). PIN 11 and 10 (above columns 23 and 24) are outputs, so leave them open.

## Instrument settings

The only instrument is Supplies (power supply) of the AD3, and Q and Q̄ are read from the LEDs.
This exercise has no oscilloscope figure. It shows the DC 0 and 1 (the held state) that change each time a button is pressed or released,
and there is no waveform over time to keep on a screen.

The current through the breadboard is a few mA, adding one LED (about 2 mA with 1 kΩ) and the pull-up of the pressed button (5 V / 10 kΩ = 0.5 mA).
That fits within the limits of the breadboard (200 mA per hole, 500 mA for the whole breadboard) and within the guide for using V+ of the AD3 on USB power (50 mA at 5 V).

## Values to check

| Operation | Q (DQ) | Q̄ (DQb) |
| --- | --- | --- |
| Press SWS | Lit (1) | Dark (0) |
| Release both (just after) | Held as before | Held as before |
| Press SWR | Dark (0) | Lit (1) |
| Press SWS and SWR together | Lit (1, forbidden input) | Lit (1, forbidden input) |

The last row is the forbidden input of the NAND latch. When both are 0, Q and Q̄ both become 1 and
the promise that they are "opposite values" breaks. If you then release both at the same time, which way it settles is decided by the slight difference between the two
gates and the timing of the release, and may change each time you try (undefined).

## Verification with LTspice

In `sim/02-rs-latch.cir`, S and R were applied in turn to two cross-coupled NANDs (ideal NANDs of B sources + a delay of 100 ns).

| Operation | Q (text) | Q (LTspice) | Q-bar (text) | Q-bar (LTspice) | Verdict |
| --- | --- | --- | --- | --- | --- |
| Press SWS | 1 | 5 V | 0 | 0 V | Agrees |
| Release both (just after) | Held | 5 V | Held | 0 V | Agrees |
| Press SWR | 0 | 0 V | 1 | 5 V | Agrees |
| Press both | 1 (forbidden input) | 5 V | 1 (forbidden input) | 5 V | Agrees |

After releasing both at the same time, ideal NANDs do not decide where it settles and the calculation does not converge. This is the same as the "undefined" in the text.

## Sources

Original work.
