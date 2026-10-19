---
book: circuits
chapter: 5
id: 5-4
title: LDO — USB 5 V → 3.3 V
tier: 50
source: 自作
board: [BB, PF]
era: 今
ja: 6c32b3bf8cbb897c4e308b3ff0d6c62e662cfefa
---

# 5-4 LDO — USB 5 V → 3.3 V

Make 3.3 V, the standard voltage for today's microcontrollers (such as the Pico 2 in Chapter 11) and sensors, from the
5 V of USB. The 7805 of 5-3 needs an input-output difference of about 2 V, so it cannot make 3.3 V from 5 V (a difference
of 1.7 V). An LDO (Low Drop Out) is a member of the three-terminal regulator family with a small dropout (seen in 5-2),
so it works even when the input-output difference is small. It is the power circuit you see most often on USB-powered boards.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 3.3 V LDO from USB 5 V (CH1 is the output voltage)
parts:
  J1: usb-c 2,2.63
  U1: regulator 6,2 AMS1117-3.3
  Cin: capacitor 4,2 4,4 10u
  Cout: ecap 8,2 8,4 22u
  Rled: resistor 10,2 10,3 150
  Dled: led 10,3 10,4 red
  M1: voltmeter 12,2 12,4 l=$\mathrm{CH1}$
  G1: ground gnd
points:
  gnd: 3,4
wires:
  - J1.VBUS -| 4,2
  - J1.GND -| gnd
  - 4,2 -- U1.in
  - U1.out -- 8,2 -- 10,2 -- 12,2
  - U1.gnd -- 6,4
  - gnd -- 4,4 -- 6,4 -- 8,4 -- 10,4 -- 12,4
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/circuit/04-ldo-usb.svg)

- J1 is a USB Type-C connector. Only VBUS (+5 V) and GND are used as power.
  CC1 and CC2 are pins that tell the other side (a PC or a charger) whether the connected device is the one that
  receives power. The receiving side connects each of them to GND through 5.1 kΩ (pull-down). Without this, a partner
  connected by a C-to-C cable does not put 5 V on VBUS (with an A-to-C cable it does). Fig. 1 omits CC. For the real
  thing, use a power breakout module that carries the 5.1 kΩ resistors (see the note under the wiring diagram below)
- Cout (22 µF) is part of how the AMS1117 works. The datasheet of the AMS1117 (Advanced Monolithic Systems) says that the
  output capacitor is used for frequency compensation (a mechanism that keeps the feedback loop from oscillating) and
  gives only one figure: "a 22 µF solid tantalum is stable under all conditions". It does not state a range for the ESR
  (equivalent series resistance, the small resistance inside a capacitor)
- The datasheet of the similar LM1117 (TI) (SNOS412) fixes the output capacitor in numbers: 10 µF or more, with an
  ESR of 0.3 to 22 Ω. This book applies the same range to the AMS1117 as a rough guide
- The ESR of a general-purpose aluminum electrolytic capacitor (16 V, 22 µF) follows from the loss tangent tan δ (often
  around 0.16 at 120 Hz; check the datasheet of the series):
  ESR = tan δ ÷ (2π f C) = 0.16 ÷ (2π × 120 Hz × 22 µF) ≈ 9.6 Ω. It falls as the frequency rises, to about 1 Ω at
  100 kHz, and both values are inside 0.3 to 22 Ω (a rough guide). So Cout is not a tantalum capacitor but the standard
  aluminum electrolytic capacitor of this book (22 µF, 16 V). It is polarized, and the + side goes to OUT
- The ESR of a multilayer ceramic capacitor is a few mΩ, far below 0.3 Ω. A Cout made only of multilayer ceramic
  capacitors may oscillate, so do not use one. In the cold the ESR of an aluminum electrolytic capacitor rises, so use
  it at room temperature to keep it from exceeding 22 Ω
- Cin (10 µF) reduces the influence of the input wiring. Its ESR does not matter, so a multilayer ceramic capacitor is fine
- Rled and Dled are an indicator LED that shows whether 3.3 V is present

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Breadboard build (5 V from AD V+, 1+ to OUT)
board: half
parts:
  U1: regulator/to220 c8(in) c9(gnd) c10(out) AMS1117-3.3
  Cin: capacitor g5 g8 10uF
  Cout: capacitor/electrolytic g10 g13 22uF
  Rled: resistor b14 b20 150
  Dled: led d20(A) d23(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Supplies V+ and Scope)
    pins: [GND, V+, 1+, 1-]
wires:
  - AD.V+ -- i8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - a10 -- a14 orange
  - a23 -- -t23 black
  - -t29 -- -b29 black
  - AD.GND -- -b4 black
  - AD.1+ -- i10 orange
  - AD.1- -- -b11 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/breadboard/04-ldo-usb.svg)

- The 5 V input comes from V+ of Supplies on the Analog Discovery (set to 5 V in WaveForms) and goes to column 8 (IN)
  (`i8`). The load is about 9 mA, within the 50 mA per rail of Supplies (250 mW on USB power). GND goes to the lower
  − rail (`-b4`). To use real USB power, plug in the VBUS of a USB-C power breakout module board in place of V+, and its
  GND in place of GND. Choose one with 5.1 kΩ pull-downs on CC (check the product description to see whether they are
  fitted). The USB D+ and D− are not used
- The 1+ (orange) of the Analog Discovery goes to column 10 of OUT (`i10`) and 1− (black) goes to the lower − rail (`-b11`)
- The pins of U1 (IN, GND, OUT = columns 8, 9, 10) are carried from row e of the upper block to the lower block by wires.
  Cin (columns 5 and 8) and Cout (columns 10 and 13) are plugged into the lower block, and the output is carried from
  a10 to Rled in column 14. The upper and lower − rails are joined at column 29
- The real AMS1117 comes only in SOT-223 (surface mount) and cannot be plugged straight into a breadboard.
  Fig. 2 draws it as a 3-pin part because the plan is to plug in a commercial "AMS1117 3.3 V fixed-output module" board
  (SOT-223 brought out to three pin headers). The order of IN, GND and OUT differs between types and boards, so check
  it against the printing on the module board

If you keep using it as a USB 5 V supply, solder it onto a perfboard, because breadboard connections are unreliable.
The voltage is 5 V, the current is about 9 mA and the frequency is DC, so it is within the range of a perfboard
(12 V or less continuous, 500 mA or less).

```perf
# Perfboard wiring diagram (tommie-fence perf fence)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
unused: [J1.D+, J1.D-, J2.D+, J2.D-]
title: Fig. 3 Perfboard build (yellow circles = AD3 clips)
parts:
  J1: usb-c/female e5 d5 c5 b5
  J2: usb-c/female t5 u5 v5 w5
  U1: regulator i14 j14 k14
  Cin: capacitor g14 g11 10u
  Cout: capacitor/electrolytic n17 n13 22u
  Rled: resistor q17 q14 150
  Dled: led q12 q9 red
wires:
  - e5 -- e6 black
  - e6 -- g6 black
  - g11 -- g6 black
  - g6 -- j6 black
  - j14 -- j6 black
  - j6 -- n6 black
  - n13 -- n6 black
  - n6 -- q6 black
  - q9 -- q6 black
  - q6 -- t6 black
  - t5 -- t6 black
  - b5 -- b17 red
  - b17 -- g17 red
  - g17 -- i17 red
  - g17 -- g14 red
  - i17 -- i14 red
  - k14 -- k17 orange
  - k17 -- n17 orange
  - n17 -- q17 orange
  - q17 -- w17 orange
  - w5 -- w17 orange
  - q14 -- q12 orange
notes:
  - mark w6 yellow
  - mark t6 yellow
  - text w6 red large bold right: AD3 1+
  - text t7 red large bold center: AD3 1-
  - text b3 red large bold: IN 5V
  - text w3 red large bold: OUT 3.3V
  - parts
style:
  back: on
  labels:
    sides: left bottom
```

![Perfboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/perfboard/04-ldo-usb.svg)

- The perfboard is a 5×7 cm board with pads (double-sided through-hole, with long narrow copper pads along the left and
  right edges), used in landscape (24 columns × 18 rows, 1.6 mm FR-4). Addresses follow the board's printing: letters
  are columns (A to X from the left) and numbers are rows (1 to 18 from the bottom). The edge pads are columns 0 and Y
  in the figure, and this exercise does not use them. The figure above is the view from the component side. Row 17 is
  the + strip (5 V in red and 3.3 V in orange) and row 6 is the GND strip (black). The figure below is the solder side
  (the board turned over), where the columns are reversed left to right. Soldering is done on the solder side
- The input J1 goes at the lower left end (B5 to E5) and the output J2 at the lower right end (T5 to W5). Both are USB-C
  power breakout modules, and both receptacles face the lower edge and stay within the board (both cables leave from
  below).
  J1 is a module whose pads run VBUS, D−, D+, GND from the left (VBUS at the left end, B5; GND at the right end, E5), and
  J2 is a module whose pads run GND, D+, D−, VBUS from the left (GND at T5, VBUS at W5).
  In both, the GND pad lies on the inner side of the board, so it enters the GND strip on row 6 with a short wire, and the
  VBUS wire runs up along the outer edge. If your module has a different pad order, read the wires again against the
  printing on its pads
- VBUS of J1 (B5) goes up column B to the + strip (5 V) on row 17, and GND (E5) goes through E6 to the GND strip on row 6.
  To reach VBUS of J2 (W5), the OUT (3.3 V) of U1 is carried to the right along row 17 and brought down column W, and GND
  (T5) joins the GND strip on row 6 at T6. Wires leave the pads vertically so as not to hide the printing beside the
  pads (V, D−, D+, GND). D+ and D− are not used (they are listed under `unused:` to remove them from the ERC
  "not connected" check)
- Choose a J1 module with 5.1 kΩ on CC (the same note as for Fig. 2; it is the side that takes 5 V from a charger)
- Two receptacles of the same shape sit side by side on the lower edge, so the figure labels them `IN 5V` and `OUT 3.3V`
  in large bold red. Write the same text on the real board. If you plug a charger into J2, 5 V enters the output of
  the AMS1117 from the wrong side and may damage it
- **J2 is not a USB-standard output.** VBUS carries 3.3 V, so do not connect a USB device such as a smartphone, a PC or a
  charger to J2 (its VBUS would collide with the 3.3 V and may damage that device). Use J2 as an outlet that passes power by
  cable to a 3.3 V experimental circuit (such as 3V3 of the Pico 2 in Chapter 11), and make the other end a power
  breakout module too
- U1 is an AMS1117 3.3 V module (IN, GND, OUT = I14, J14, K14). IN comes from the + strip on row 17, GND goes down to row 6,
  and OUT goes out to the right half of row 17. Check the pin order of the module against its printing (same as Fig. 2)
- Cin (10 µF, G14 and G11) goes between the 5 V strip and the GND strip, and Cout (22 µF, N17 and N13) goes between the
  3.3 V strip and the GND strip. Cout is polarized, and the + side connects to row 17 (OUT). Rled (Q17, Q14) and
  Dled (Q12, Q9) are the 3.3 V indicator
- The AD3 is not soldered. Only while measuring, clip it onto the pads of J2. 1+ goes to W6 (3.3 V), connected to VBUS,
  and 1− to T6 on the GND strip. Both are circled in yellow. `AD3 1+` is written in large bold red to the right of the
  circle at W6, and `AD3 1-` one row above the circle at T6 (centered right above T7; row 6 is avoided because the GND
  strip runs there). Measuring at the output connector shows whether the 3.3 V output is actually present. The AD only
  measures and supplies no power to this board
- The wires are only vertical and horizontal, and no wires cross. The red wire from VBUS of J1 runs up the left edge
  (column B), so it does not cross the GND strip (row 6)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | LDO regulator (SOT-223 to pin header adapter module) | AMS1117-3.3 |
| Cin | Ceramic capacitor (input side) | 10 µF |
| Cout | Aluminum electrolytic capacitor (output side, polarized) | 22 µF, 16 V |
| Rled | Resistor (indicator LED current limit) | 150 Ω |
| Dled | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Board (Fig. 3) | Perfboard 5×7 cm with pads (landscape, 1.6 mm FR-4) |
| J1 | USB-C power breakout module (input; 5.1 kΩ on CC) | Lower left end of Fig. 3 |
| J2 | USB-C power breakout module (output; outlet for 3.3 V) | Lower right end of Fig. 3. Do not connect USB devices |
| — | Power and instruments | V+ = 5 V of Supplies on the Analog Discovery 3 (in place of USB 5 V; current about 9 mA) and Scope (1+ = OUT, 1− = GND). USB-C power works the same |

## Instrument settings

The instrument is Scope on the Analog Discovery 3 (1+ = OUT, 1− = GND) or a multimeter. This exercise looks only at DC
voltage and current, so no oscilloscope waveform figure is given (nothing changes with time, and the readings are
enough). Set Scope to DC coupling and 1 V/div and read the voltage of OUT.

## Values to check

The values in the table are calculated values. Measure voltages with the multimeter's DC voltage range, with the − probe on GND (the − rail).

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Voltage at OUT | 3.30 V | The fixed output of the AMS1117-3.3 |
| Current in Dled | about 8.7 mA | (3.3 V − 2.0 V) ÷ 150 Ω |
| Dropout voltage | about 1.1 V (@1A, typical) | The output can no longer be held once V<sub>in</sub> − V<sub>out</sub> falls below 1.1 V. With a 5 V input the difference is 1.7 V, so there is margin |
| Dissipation in U1 (light load of Dled only) | about 14.7 mW | (5 V − 3.3 V) × 8.7 mA |
| Comparison with the USB current limit | 8.7 mA ≪ 500 mA (USB 2.0 specification) | A load this small is no problem at all on USB power |

When the load current I rises to several hundred mA, the dissipation (5 − 3.3) V × I can no longer be ignored (about
0.5 W at 300 mA). A SOT-223 with no heat sinking gets hot, and the overtemperature protection of the AMS1117 may act and
throttle the output. If you need a large current, use a step-down switching regulator (5-6).

The 5 V of USB can be taken from a smartphone charger or a mobile battery, but inside both are switching power supplies,
and their output carries noise from tens of kHz to several MHz. For driving LEDs or a microcontroller, you can use it as
it is. In a circuit that amplifies the small signal of a microphone or a sensor, use dry batteries or pass the supply
through an LC filter. How much noise is present is measured in 10-3 of the Analog Discovery book (looking at the noise of
a USB charger).

## Verification with LTspice (not applicable)

The AMS1117-3.3 is a part that holds its output through the inside of the IC, and it has no internal model that SPICE can verify
(the values are typical values from the datasheet). The numbers in the text were checked by arithmetic. The current in Dled is
(3.3 V − 2.0 V) ÷ 150 Ω ≈ 8.7 mA, the dissipation in U1 is (5 V − 3.3 V) × 8.7 mA ≈ 14.7 mW, and at 300 mA it is
1.7 V × 0.3 A ≈ 0.5 W.

## Sources

Original work.

See also: [TI LM1117 datasheet](https://www.ti.com/lit/ds/symlink/lm1117.pdf), [AMS1117 datasheet](http://www.advanced-monolithic.com/pdf/ds1117.pdf), [Low-dropout regulator (Wikipedia)](https://en.wikipedia.org/wiki/Low-dropout_regulator)
