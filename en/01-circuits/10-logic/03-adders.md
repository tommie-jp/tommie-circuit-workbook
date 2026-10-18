---
book: circuits
chapter: 10
id: 10-3
title: Half Adder and Full Adder (XOR + AND)
tier: 50
source: 自作
board: BB
ja: b15efd0b8851423ffbea1aeb1660eabc75b835f7
---

# 10-3 Half Adder and Full Adder (XOR + AND)

Build binary addition from gates. The arithmetic inside a computer is a stack of circuits like this one.

First we build a half adder, which computes A + B for two single bits. As in 1 + 1 = 10 (binary),
adding one bit gives two outputs: the sum of that bit and a carry to the next bit up.
The sum is made with an XOR (exclusive OR: 1 only when the two inputs differ) and the carry with an AND (10-1).
Next we add a second XOR and AND plus an OR, which extends the circuit to a full adder that also adds the carry
from the bit below (Cin). Three CMOS ICs (XOR, AND, OR) are enough.

In the equations, ⊕ means XOR, · means AND and + means OR.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Extending a half adder to a full adder
parts:
  A: switch 3,4 3,6
  RpdA: resistor 3,6 1,6 10k
  GA: ground 1,6
  B: switch 6,3 6,5
  RpdB: resistor 6,5 4,5 10k
  GB: ground 4,5
  CIN: switch 9,2 9,4 l=$C_\mathrm{in}$
  RpdC: resistor 9,4 7,4 10k
  GC: ground 7,4
  VCC: vcc 3,4 5V
  VCC: vcc 6,3 5V
  VCC: vcc 9,2 5V
  U1A: xor 14,8 CD4070
  U2A: and 14,14 CD4081
  U1B: xor 24,8 CD4070
  U2B: and 24,12 CD4081
  U3A: or 30,13 CD4071
  RS1: resistor 17,8 17,10 1k l=$R_\mathrm{S1}$
  DS1: led 17,10 17,11 red l=$D_\mathrm{S1}$
  GS1: ground 17,11
  RC1: resistor 18,14 18,16 1k l=$R_\mathrm{C1}$
  DC1: led 18,16 18,17 red l=$D_\mathrm{C1}$
  GC1: ground 18,17
  RCO: resistor 34,13 34,15 1k l=$R_\mathrm{Cout}$
  DCO: led 34,15 34,16 red l=$D_\mathrm{Cout}$
  GCO: ground 34,16
  RS: resistor 37,8 37,10 1k
  DS: led 37,10 37,11 red
  GDS: ground 37,11
wires:
  - 3,6 -- 10,6 -- 12,6
  - 12,6 |- U1A.a
  - 10,6 |- U2A.a
  - 6,5 -- 9,5 -- 11,5
  - 11,5 |- U1A.b
  - 9,5 |- U2A.b
  - 9,4 -- 20,4 -- 21,4
  - 21,4 |- U1B.a
  - 20,4 |- U2B.a
  - U1A.out -- 17,8 -- 19,8
  - 19,8 |- U1B.b
  - 19,8 |- U2B.b
  - U2A.out -- 18,14 -- 28,14
  - 28,14 |- U3A.b
  - U2B.out -- 28,12
  - 28,12 |- U3A.a
  - U3A.out -- 34,13
  - U1B.out -- 37,8
notes:
  - text 16,7 blue: S1
  - text 21,13 blue: C1
  - text 26,11 blue: C2
  - text 32,12 blue: Cout
  - text 35,7 blue: S
  - text 1,18 small left: "Numbers are IC pin numbers"
  - text 1,19 small left: "VDD is pin 14 (+5V) on all three, VSS is pin 7 (GND)"
  - text 1,20 small left: "Unused inputs to GND (U1, U2: 8 9 12 13, U3: 5 6 8 9 12 13)"
style:
  grid: off
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/circuit/03-adders.svg)

- Half adder: U1A (XOR, pins 1, 2 → 3) gives the sum S1 = A⊕B, and U2A (AND, pins 1, 2 → 3) gives the carry C1 = A·B
- Extension to a full adder: U1B (XOR, pins 5, 6 → 4) gives the sum S = Cin⊕S1, U2B (AND, pins 5, 6 → 4)
  gives C2 = Cin·S1, and U3A (OR, pins 1, 2 → 3) gives the carry Cout = C2 + C1.
  C1 and C2 are never 1 at the same time, so combining them with an OR is fine
- Fig. 1 draws the gates as logic symbols and adds the IC pin numbers to the symbol inputs and outputs. U1A and U1B are two
  circuits of the same CD4070 (U1), and U2A and U2B are two circuits of the same CD4081 (U2)
- The power pins do not appear on the symbols, so they are written below the figure. On all three ICs, pin 14 is VDD (+5 V)
  and pin 7 is VSS (GND). If you forget to connect them, the IC does not work
- Connect unused inputs to GND (10-1). For U1 and U2 these are the inputs of the remaining two gates (pins 8, 9, 12, 13);
  for U3 they are the inputs of the remaining three gates (pins 5, 6, 8, 9, 12, 13). Leave the output pins (pins 10 and 11
  of U1 and U2; pins 4, 10 and 11 of U3) unconnected
- The series resistors for the LEDs (RS1, RC1, RS, RCO) are 1 kΩ. As in 10-1, the output of a 5 V CD4000-series gate can
  source only a few mA, so the LED current is kept to 1.5 to 2.2 mA (the rough guide worked out in 10-1).
  If the LEDs are too dim, use high-brightness LEDs or switch to the 74HC series (74HC86, 74HC08, 74HC32)
- S1 and C1 light an LED and also drive the input of the next gate. The current taken by the LED lowers the H voltage:
  by the rough guide in 10-1, about 4.0 V for a typical part and about 3.3 V for the minimum part. The minimum part is
  slightly below the input voltage that the datasheet guarantees to read as H (V<sub>IH</sub>, 3.5 V or more at 5 V), but a
  CMOS input actually switches between 0 and 1 around half the supply (about 2.5 V), so it works as the table says
  (rough guide). With 330 Ω left in place, H could drop below 3 V

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  A: switch d2 d4
  RpdA: resistor a4 -t4 10k
  B: switch d6 d8
  RpdB: resistor a8 -t8 10k
  CIN: switch d10 d12
  RpdC: resistor a12 -t12 10k
  U1: dip14 @ e14 CD4070
  RS1: resistor d21 d25 1k
  DS1: led e25(A) e26(K) red
  RS: resistor d28 d32 1k
  DS: led e32(A) e33(K) red
  U2: dip14 @ e37 CD4081
  RC1: resistor a45 a48 1k
  DC1: led b48(A) b49(K) red
  U3: dip14 @ e51 CD4071
  RCO: resistor a58 a61 1k
  DCO: led b61(A) b62(K) red
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
wires:
  # Power: top + rail, bottom - rail. One column joins the top and bottom - rails
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t2 -- a2 red
  - +t6 -- a6 red
  - +t10 -- a10 red
  - +t14 -- a14 red
  - +t37 -- a37 red
  - +t51 -- a51 red
  - j20 -- -b20 black
  - j43 -- -b43 black
  - j57 -- -b57 black
  # Inputs: bring the switch columns below the center gap to U1, and use the upper b and c rows to reach U2
  - e4 -- f4 yellow
  - e8 -- f8 green
  - e12 -- f12 blue
  - g4 -- g14 yellow
  - h8 -- h15 green
  - j12 -- j19 blue
  - b4 -- b35 yellow
  - c8 -- c34 green
  - e35 -- f35 yellow
  - e34 -- f34 green
  - i35 -- i37 yellow
  - h34 -- h38 green
  # U1: pin 3 → pin 5 (S1); S1 and S go to the LEDs; S1 and Cin go to U2
  - g16 -- g18 orange
  - i18 -- i21 orange
  - f21 -- e21 orange
  - j21 -- j41 orange
  - h17 -- h28
  - f28 -- e28
  - g19 -- g42 blue
  - a26 -- -t26 black
  - a33 -- -t33 black
  # U2: pin 3 (C1) goes to the LED and to pin 1 of U3; pin 4 (C2) goes to pin 2 of U3
  - h39 -- h45
  - f45 -- e45
  - a49 -- -t49 black
  - g45 -- g51
  - i40 -- i52
  # U3: pin 3 (Cout) goes to the LED
  - g53 -- g58
  - f58 -- e58
  - a62 -- -t62 black
  # Unused inputs to GND: upper pins from row a to the top - rail, lower pins from row j to the bottom - rail
  - a15 -- -t15 black
  - a16 -- -t16 black
  - a19 -- -t19 black
  - a20 -- -t20 black
  - a38 -- -t38 black
  - a39 -- -t39 black
  - a42 -- -t42 black
  - a43 -- -t43 black
  - a52 -- -t52 black
  - a53 -- -t53 black
  - a56 -- -t56 black
  - a57 -- -t57 black
  - j55 -- -b55 black
  - j56 -- -b56 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/breadboard/03-adders.svg)

- U1 (CD4070, XOR) occupies columns 14 to 20, U2 (CD4081, AND) columns 37 to 43, and U3 (CD4071, OR)
  columns 51 to 57. All have the notch on the left, with pin 1 at the lower left (row f) and pin 14 at the upper left (row e).
  From the left the order is inputs → U1 and U2 → U3 → output LEDs
- The power supply is Supplies on the Analog Discovery 3 (AD3, the USB instrument used in 0-3), with V+ set to 5 V.
  Connect V+ (red) of the AD3 at the upper left of the breadboard to column 1 of the top + rail, and GND (black) to column 2 of the top − rail
- Power: pin 14 of each IC (columns 14, 37 and 51) goes from row a to the top + rail (red), and pin 7 (columns 20, 43
  and 57) goes from row j to the bottom − rail (black). The LEDs and pull-down resistors go to the top − rail, so one column
  joins the top and bottom − rails
- Switches A, B and Cin (row d, columns 2 to 4, 6 to 8 and 10 to 12) are fed from the top + rail.
  The pull-down resistors are placed vertically between row a of the switch-side columns (4, 8 and 12) and the top − rail.
  Short e→f wires bring the switch-side columns below the center gap, and rows g, h and j carry them into pins 1, 2 and 6 of U1
  (columns 14, 15 and 19)
- A (yellow) and B (green) run along rows b and c of the upper block, over the top of U1, to columns 35 and 34,
  where they come down below the center gap and enter pins 1 and 2 of U2 (columns 37 and 38) on rows i and h. Cin (blue) goes straight
  from pin 6 of U1 (column 19) along row g to pin 6 of U2 (column 42)
- Pin 3 of U1 (S1, column 16) goes along row g to pin 5 (column 18). S1 (orange) is carried along row i to column 21,
  goes up to RS1 and DS1, and from the same column 21 goes along row j to pin 5 of U2 (column 41). Pin 4 of U1 (S, column 17) is carried
  along row h to column 28 and goes up to RS and DS. RS1 and RS sit in row d and DS1 and DS in row e, lined up under the
  A and B wires that run along rows b and c. The LED cathodes go from row a to the top − rail
- Pin 3 of U2 (C1, column 39) is carried along row h to column 45, goes up to RC1 and DC1, and along row g to pin 1 of U3
  (column 51). Pin 4 (C2, column 40) goes along row i to pin 2 of U3 (column 52). Pin 3 of U3 (Cout,
  column 53) is carried along row g to column 58 and goes up to RCO and DCO
- Unused inputs go to GND with short black wires. Pins 13, 12, 9 and 8 of U1, U2 and U3 (columns 15, 16, 19, 20;
  38, 39, 42, 43; 52, 53, 56, 57, upper side) go from row a to the top − rail, and pins 5 and 6 of U3
  (columns 55 and 56, lower side) go from row j to the bottom − rail
- No wires cross, and the only wires that cross the center gap are short ones running straight up and down a column

## Instrument settings

The only AD3 instrument used is Supplies (the power supply); the sum and carry are read from the LEDs.
This exercise has no oscilloscope figure. It looks only at DC 0 and 1 for inputs set by switches, and nothing changes with time.

The current through the breadboard is about 2.2 mA × 4 ≈ 9 mA with all four LEDs lit, plus 0.5 mA × 3 for the three pull-downs,
about 11 mA in total. This is within the breadboard limits (200 mA per hole, 500 mA for the whole breadboard) and within the
rough guide for V+ of the AD3 on USB power (50 mA at 5 V).

## Values to check

A closed switch is 1. A 1 in the table means the LED is lit (DS1 for S1, DC1 for C1, DS for S, DCO for Cout).

| A | B | Cin | S1 | C1 | S (total sum) | Cout | In decimal |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 | 0 | 1 | 0 | 1 |
| 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 0 | 0 | 1 | 2 |
| 1 | 0 | 0 | 1 | 0 | 1 | 0 | 1 |
| 1 | 0 | 1 | 1 | 0 | 0 | 1 | 2 |
| 1 | 1 | 0 | 0 | 1 | 0 | 1 | 2 |
| 1 | 1 | 1 | 0 | 1 | 1 | 1 | 3 |

Reading Cout as the twos place and S as the ones place gives the answer to A + B + Cin (last column).
Only in the last row (A=B=Cin=1) do S and Cout both light. This is the only combination that gives 1+1+1 = 3 (binary 11),
and only a full adder that can add Cin can represent it.

## Verification with LTspice

`sim/03-adders.cir` builds the full adder from ideal logic (XOR, AND, OR) in B sources, steps A, B and C<sub>in</sub> through 000 to 111, and reads S, C<sub>out</sub>, S1 and C1.

| A B C<sub>in</sub> | S1 (text / LTspice) | C1 (text / LTspice) | S (text / LTspice) | C<sub>out</sub> (text / LTspice) | Verdict |
| --- | --- | --- | --- | --- | --- |
| 0 0 0 | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 | agrees |
| 0 0 1 | 0 / 0 | 0 / 0 | 1 / 1 | 0 / 0 | agrees |
| 0 1 0 | 1 / 1 | 0 / 0 | 1 / 1 | 0 / 0 | agrees |
| 0 1 1 | 1 / 1 | 0 / 0 | 0 / 0 | 1 / 1 | agrees |
| 1 0 0 | 1 / 1 | 0 / 0 | 1 / 1 | 0 / 0 | agrees |
| 1 0 1 | 1 / 1 | 0 / 0 | 0 / 0 | 1 / 1 | agrees |
| 1 1 0 | 0 / 0 | 1 / 1 | 0 / 0 | 1 / 1 | agrees |
| 1 1 1 | 0 / 0 | 1 / 1 | 1 / 1 | 1 / 1 | agrees |

## Sources

Original work.
