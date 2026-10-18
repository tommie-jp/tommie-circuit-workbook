---
book: circuits
chapter: 12
id: 12-1
title: Goodnight Timer — 555 Monostable + MOSFET
tier: 50
source: 自作
board: [BB, PF]
ja: 8e07ab3d28f7dc0490001f35cd3f53b88d81e012
---

# 12-1 Goodnight Timer — 555 Monostable + MOSFET

A practical circuit that combines the 555 monostable (3-3; a mode in which a trigger holds the output at H for a fixed time) with
a MOSFET switch (2-5). Press the button and a night-light LED comes on, then turns itself off
after about 19 minutes. Press it before going to sleep and you have a "goodnight timer" that works as a reading light and then switches itself off.
Chapter 12 turns circuits from the earlier chapters into finished projects: we check them on a
breadboard, then solder them onto a perfboard to keep them.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 555 monostable (CMOS) turns on a MOSFET for 19 min
parts:
  VCC: vcc 5,2 5V
  U1: ic 8,7 TLC555
  Gu1: ground 8,9
  Rt: resistor 5,2 5,4 4.7M
  Ct: capacitor 5,7 5,8 220u
  Get: ground 5,8
  VCC: vcc 3,7 5V
  Rtrig: resistor 3,7 3,9 100k l=$R_\mathrm{trig}$
  SWtrig: button 3,9 3,11 l=$\mathrm{SW_{trig}}$
  Gtrig: ground 3,11
  Rg: resistor 10,7 12,7 220
  Q1: nmos-e 13,6.88
  Gq1: ground 13,8
  VCC: vcc 13,2 5V
  RLED: resistor 13,2 13,4 470 l=$R_\mathrm{LED}$
  DLED: led 13,4 13,5 red l=$D_\mathrm{LED}$
wires:
  - 5,2 -- 8,2 -- 8.5,2
  - U1.VDD |- 8,2
  - U1.RESET |- 8.5,2
  - 5,4 -- 5,6.5
  - U1.DISCH -| 5,6.5
  - U1.THRES -| 5,7
  - 5,6.5 -- 5,7
  - U1.TRIG -| 6,7.5
  - 6,7.5 -- 6,9 -- 3,9
  - U1.GND |- 8,9
  - U1.OUT -| 10,7
  - 12,7 |- Q1.G
  - 13,5 -- Q1.D
  - Q1.S -- 13,8
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/12-projects/circuit/01-goodnight-timer.svg)

- Pin 2 (TRIG) of U1 is normally H through Rtrig (100 kΩ). The moment SWtrig is pressed it goes L
  and the monostable starts
- Rt (4.7 MΩ) and Ct (220 µF), connected to pins 6 and 7 (THRES and DISCH), set the time:
  T = 1.1 × Rt × Ct = 1.1 × 4.7 MΩ × 220 µF ≈ 1137 s (about 19 minutes, calculated value)
- U1 is the CMOS TLC555, not an ordinary (bipolar) NE555.
  When Rt is large, even the small current that flows into the THRES and TRIG inputs (the input bias current) can no
  longer be ignored. A bipolar NE555 can draw several hundred nA, which causes a voltage error
  with 4.7 MΩ. The CMOS version draws on the order of pA (1/1000 of a nA) and can be ignored
- Also watch the leakage current of the electrolytic capacitor itself (the current that lets a little DC through).
  The charging current through Rt is only 5 V / 4.7 MΩ ≈ 1.06 µA. If the leakage gets close to this,
  Ct has trouble reaching 2/3 of the supply voltage (the voltage at which the 555 stops) and the time gets longer.
  If the leakage exceeds it, the timer never ends
- The datasheet upper limit for leakage, 0.01 × C × V (V is the rated voltage, 2 minutes after applying the voltage), comes to
  0.01 × 220 × 25 = 55 µA for a 220 µF, 25 V part. But this is the upper limit with the rated voltage applied.
  Use a part with margin in its rating (25 V or more) at 5 V and leave the voltage applied for a while, and the
  actual leakage is normally far below 1 µA (rough guide). So use an
  electrolytic capacitor rated 25 V or more, or a low-leakage part, and apply voltage for a few minutes after assembly before use.
  Raising the capacitance 10 times raises the leakage about 10 times, so get the time from Rt rather than from C
  and keep C at 220 µF
- Pin 3 (OUT) is H during the monostable period and drives the gate of Q1 (2N7000) through Rg (220 Ω).
  While Q1 is on, DLED (the night light) is lit
- Pin 4 (RESET) is tied directly to pin 8 (VDD) to disable it (so the timer can always run)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  U1: dip8 @ e10 TLC555
  Rtrig: resistor b2 b5 100k
  SWtrig: button @ e3
  Rt: resistor b15 b12 4.7M
  Ct: capacitor/electrolytic c11 c8 220u
  Rg: resistor g46 g41 220
  Q1: transistor b40(S) b41(G) b42(D) 2N7000
  RLED: resistor b52 b49 470
  DLED: led c49(A) c46(K) red
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V / Scope 1
    pins: [V+, GND, 1-, 1+]
  SC:
    type: device
    at: bottom
    label: AD3 Scope 2
    pins: [2+, 2-]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t1 black
  - PS.1+ -- a11 yellow
  - SC.2+ -- j12 blue
  - PS.1- -- -t3 black
  - SC.2- -- -b21 black
  - -t62 -- -b62 black
  - +t63 -- +b63 red
  - a10 -- +t10 red
  - j10 -- -b10 black
  - j13 -- +b13 red
  - d11 -- d12 orange
  - a15 -- +t15 red
  - a8 -- -t8 black
  - h11 -- h6 orange
  - g6 -- d6 orange
  - c6 -- c5 orange
  - a2 -- +t2 red
  - j3 -- -b3 black
  - i12 -- i46 blue
  - e41 -- f41 blue
  - e40 -- f40 black
  - j40 -- -b40 black
  - e42 -- e46 green
  - a52 -- +t52 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/12-projects/breadboard/01-goodnight-timer.svg)

- The top and bottom rails are joined by wires at the right end (columns 62 and 63). Connect pin 8 of U1 (upper side of column 10) and
  pin 4 (lower side of column 13) to the + rail, and pin 1 (lower side of column 10) to the bottom − rail (GND)
- Pin 2 (TRIG, lower side of column 11) goes up to column 5 of the upper block through column 6 by an orange wire.
  There Rtrig pulls up to the + rail, and pressing SWtrig (e3) pulls it down to the bottom − rail
- Pins 6 and 7 (THRES and DISCH, upper side of columns 12 and 11) are joined on row d. Rt (4.7 MΩ) goes from column 12 to
  the red + rail, and Ct (220 µF) goes from column 11 to the − rail at column 8. This is the time-constant node
- Pin 3 (OUT, lower side of column 12) is carried by a blue wire (row i) to column 46 and goes through Rg to the gate of Q1
  (column 41). Q1 is plugged into the upper block (row b, columns 40 to 42), and its pins go down across the center gap by
  short wires from row e (S from column 40 to GND, G at column 41 to Rg). D (column 42) is carried by a green wire to column 46
  and on to the cathode of DLED (the night light); the anode goes through RLED to the + rail.
  Looking at the flat face of the 2N7000, the pins are S, G, D from the left (the same as in 2-5)
  Note: **verify on the real part: onsemi's 2007 figure shows S G D but its 2022 table shows D G S, and they disagree; this book follows the 2007 version (S G D). Check the real part with a multimeter**
- Plug only one pin or wire into a hole (to take a wire from a column that already holds a part's pin, use a free hole in the same column)
- The power supply is Supplies on the Analog Discovery 3 (AD3, the USB instrument used in 0-3), with V+ set to 5 V going to the top red rail (column 1) and
  GND going to the top blue rail (below column 1). The AD3 oscilloscope (Scope) watches two points: plug 1+ into the column of Ct and THRES/DISCH (column 11, `a11`) and
  2+ into the OUT column (lower side of column 12, `j12`), and connect 1− and 2− (black) to the − rail (GND). Fig. 2 draws the same AD3 as two boxes (top and bottom).
  The current through the breadboard is about 6.4 mA in DLED plus a few hundred µA in the TLC555, about 7 mA, within the breadboard limits (200 mA per hole, 500 mA for the whole breadboard) and within
  the rough guide for V+ of the AD3 on USB power (50 mA at 5 V)

## Building it on a perfboard

Since this is a finished project, we also build the same circuit on a perfboard.

```perfboard
# Perfboard wiring diagram (tommie-fence perfboard fence)
board:
  size: 7x5cm
  silk: board
  slots: on
title: Fig. 3 Building it on a perfboard (seen from the component side)
unused: [U1.CONT]
points:
  VCC: a18
  GND: a5
parts:
  U1: dip8 e14 TLC555
  Rtrig: resistor b18 b15 100k
  SWtrig: button b9
  Rt: resistor g18 g15 4.7M
  Ct: capacitor/electrolytic u15 u13 220u
  Rg: resistor l10 p10 220
  Q1: transistor o8 p8 q8 2N7000
  RLED: resistor r14 r12 470
  DLED: led r11 r9 red
wires:
  # Power rail (row 18, top) and GND rail (row 5, bottom)
  - VCC -- b18 red
  - b18 -- e18 red
  - e18 -- g18 red
  - g18 -- j18 red
  - GND -- b5 black
  - b5 -- e5 black
  - e5 -- m5 black
  - m5 -- u5 black
  # Power for U1: pin 8 (VDD) goes up, pin 1 (GND) goes down
  - e14 -- e18 red
  - e11 -- e5 black
  # Pin 4 (RESET) goes up column J to VCC. From j14 on the way, VCC is also distributed to the output stage
  - h11 -- j11 red
  - j11 -- j14 red
  - j14 -- j18 red
  - j14 -- r14 red
  # TRIG (pin 2): to VCC through Rtrig, to GND through SWtrig
  - b15 -- b9 yellow
  - b7 -- b5 black
  - f11 -- f9 yellow
  - f9 -- d9 yellow
  # THRES and DISCH (pins 6 and 7): to VCC through Rt, to GND through Ct
  - f14 -- f15 orange
  - f15 -- g15 orange
  - g14 -- g15 orange
  - g15 -- u15 orange
  - u13 -- u5 black
  # OUT (pin 3) → Rg → gate of Q1. Drain of Q1 → DLED → RLED → VCC
  - g11 -- g10
  - g10 -- l10
  - p10 -- p8
  - r12 -- r11
  - r9 -- r8
  - r8 -- q8
  - o8 -- m8 black
  - m8 -- m5 black
```

![Perfboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/12-projects/perfboard/01-goodnight-timer.svg)

- Seen from the component side. Run one rail each for power along row 18 (top, red) and GND along row 5 (bottom, black),
  and connect the supply at a18 and a5 at the left end. The parts are distributed vertically from these two rails
- Insert U1 (e14, DIP8) with the notch on the left. The upper row, from the left, is pin 8 (VDD), 7 (DISCH),
  6 (THRES) and 5 (CONT) at e14 to h14, and the lower row, from the left, is pin 1 (GND), 2 (TRIG), 3 (OUT) and
  4 (RESET) at e11 to h11. Pin 8 goes up column E to row 18, and pin 1 goes down column E to row 5
- Pin 4 (RESET) exits to column J on row 11 and goes up column J to row 18 (VCC). From j14 on the way,
  row 14 runs out to the right to carry VCC to RLED in the output stage. Pin 5 (CONT) is not connected anywhere (it is listed in `unused:` to exclude it from the ERC "not connected" warning).
  It is not required for the monostable to work and it works even if left floating (to connect it, add 0.01 µF
  from here to GND)
- Pin 2 (TRIG, yellow) is carried from f11 to the left along row 9 to SWtrig (b9). The lower pin of SWtrig goes from b7 to
  GND on row 5, and the upper pin b9 goes up column B and is pulled up through Rtrig (b18 to b15) to VCC on row 18
- Pins 6 and 7 (THRES and DISCH, orange) each go up to row 15 and are joined at f15 to g15, and go to VCC through Rt (g18 to g15).
  From the same g15, row 15 runs to the right to Ct (u15, + at the top), and the − of Ct goes down column U to GND
- Pin 3 (OUT) goes along row 10 to Rg (l10 to p10), and from Rg down column P to the gate of Q1 (p8).
  Looking at the flat face of Q1 (2N7000), the pins are S, G, D from the left, so o8 is the source, p8 is the gate and
  q8 is the drain. The source goes down column M to GND, and the drain goes from r8 up column R to
  the cathode of DLED (r9). The anode of DLED (r11) goes through RLED (r14 to r12) to VCC on row 14
- There are 2 crossings, and both are bridged with insulated wire. The orange row 15 (to Ct) crosses the red column J (RESET), and
  the yellow row 9 (TRIG) crosses the black column E (GND of U1). With this pin arrangement the circuit cannot be built with
  0 crossings (the VCC of pin 4 and the GND from pins 6 and 7 to Ct must meet at the right of U1)

## Instrument settings

The instruments are Supplies on the AD3 (the power supply) and the oscilloscope (Scope). In one press, watch **OUT go H from the moment SWtrig is pressed while the voltage of Ct slowly rises toward 5 V**.
The phenomenon takes about 19 minutes, so put the Scope in Record mode (2-11 in the Analog Discovery book).
Fig. 3 shows the first 9 minutes after the press (time range 60 s/div, the longest range that can be drawn in a figure), with OUT staying H while Ct rises.
Ct reaches 2/3 of the supply voltage (about 3.33 V) and OUT returns to L at about 1137 s (about 19 minutes), which is outside the figure. On real hardware, lengthen the record to 20 minutes or more to check.

| Item | Value |
| --- | --- |
| Power | V+ of Supplies at 5 V; V− is not used |
| CH1 (1+) | Voltage of Ct (pins 6 and 7 of U1). 1 V/div, 0 V one division up from the bottom |
| CH2 (2+) | OUT (pin 3 of U1). Same 1 V/div and same 0 V position as CH1 |
| 1−, 2− | GND |
| Time range | 60 s/div (Record mode, first 9 minutes in Fig. 3). To see T, lengthen the record to 20 minutes or more |
| Trigger | Rising edge of CH2, 2.5 V. Place the trigger point one division from the left (the time SWtrig is pressed is t = 0) |
| Measurements | Maximum |
| Cursors | Place X1 at 60 s and X2 at 480 s and read Ct at those times |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 First 9 min after the press, OUT stays H as Ct rises
time: 60s/div
trigger: ch2 rising 2.5V at -4div
ch1: {wave: = 5V * step(t) * (1 - exp(-t / 1034s)), range: 1V/div, position: -3div}
ch2: {wave: = 5V * step(t), range: 1V/div, position: -3div}
cursors: [60s, 480s]
measure: [vmax]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/12-projects/scope/01-goodnight-timer.svg)

- CH2 (OUT) in Fig. 3 rises from 0 V to about 5 V at the moment of the press (t = 0) and stays H throughout the figure.
  CH1 (Ct) rises in a curve from 0 V toward 5 V. The time constant is τ = Rt × Ct = 4.7 MΩ × 220 µF = 1034 s (calculated value)
- The cursor readings are, at X1 (60 s), 5 V × (1 − e<sup>−60/1034</sup>) ≈ 0.28 V and, at X2 (480 s), 5 V × (1 − e<sup>−480/1034</sup>) ≈ 1.86 V (calculated values)
- At T = 1.1 × τ ≈ 1137 s, Ct reaches 5 V × (1 − e<sup>−1.1</sup>) ≈ 3.33 V (2/3 of the supply), the 555 stops and OUT returns to L.
  DISCH then discharges Ct back to 0 V. This change is outside Fig. 3 (about 19 divisions from the origin) and is to be checked by a record on real hardware
- The real T varies with the capacitance tolerance of the electrolytic capacitor (about ±20%) and with leakage (see the note under "Values to check" below). The figure shows the calculated values

## Values to check

Calculated values. Measure voltages against GND with the multimeter on a DC voltage range. Measure time with a clock.

| Where to measure | Expected value |
| --- | --- |
| Pin 3 (OUT) of U1 just after SWtrig is pressed | Goes H and DLED lights. About 5 V (the TLC555 has a CMOS output and drives only a gate, so it is almost the same as +5 V) |
| Time lit | T = 1.1 × 4.7 MΩ × 220 µF ≈ 1137 s (about 19 minutes, calculated value) |
| Current in DLED | About 6.4 mA ((5 V − 2.0 V) / 470 Ω, red LED, calculated value). Check by dividing the voltage across RLED (about 3.0 V) by 470 Ω |
| Pin 3 after 19 minutes | Returns to L (0 V) and DLED goes out |

Replacing Ct (220 µF) with 100 µF gives T ≈ 8.6 minutes (calculated value). The capacitance tolerance of an electrolytic
capacitor is about ±20% and leakage also lengthens the time, so the actual time is a rough guide.

If the LED does not go out after 30 minutes, the leakage is beating the charging current. Lowering Rt to
2.2 MΩ (charging current about 2.3 µA, T ≈ 9 minutes) gives some margin. If you need a long time, such as 40 minutes,
do not push the monostable; it is more reliable to count the oscillation of a 555 with a counter such as the 4040
(10-4).

## Verification with LTspice

`sim/01-goodnight-timer.cir` runs a transient analysis of the time-constant part of Fig. 1 (R<sub>t</sub> = 4.7 MΩ, C<sub>t</sub> = 220 µF, 5 V) and reads the time T
for C<sub>t</sub> to reach 2/3 V<sub>CC</sub>. The 555 is ideal (no input bias current, being the CMOS version), Q1 uses a substitute model for the 2N7000
(the same as in 02-transistors/sim, threshold 2.1 V), and the LED uses the same assumed model as in 1-1. These are not measurements.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| T (no leakage) | about 1137 s (about 19 minutes) | 1136 s | agrees |
| C<sub>t</sub> at 60 s | about 0.28 V | 0.28 V | agrees |
| C<sub>t</sub> at 480 s | about 1.86 V | 1.86 V | agrees |
| Current in DLED (OUT = 5 V) | about 6.4 mA | 6.37 mA (0.02 V across D-S of Q1) | agrees |
| T when the leakage of the electrolytic capacitor is represented by a 20 MΩ parallel resistor (about 0.25 µA at 5 V) | "gets longer" (no number) | 1451 s (about 24 minutes) | addendum (below) |

Even a leakage of about 0.25 µA lengthens T by about 30 %, from 19 to 24 minutes. This is an example of the text's statement that "if the leakage gets close to the charging current (1.06 µA), the time gets longer".
For Rt = 2.2 MΩ, T = 1.1 × 2.2 MΩ × 220 µF ≈ 532 s (about 9 minutes) and the charging current is 5 V / 2.2 MΩ ≈ 2.3 µA;
for C<sub>t</sub> = 100 µF, 1.1 × 4.7 MΩ × 100 µF ≈ 517 s (about 8.6 minutes). Both agree with the numbers in the text (arithmetic).

## Sources

Original work.
