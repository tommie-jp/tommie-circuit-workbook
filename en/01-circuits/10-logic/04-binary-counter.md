---
book: circuits
chapter: 10
id: 10-4
title: Binary Counter (4 bits, 4040)
tier: 50
source: 自作
board: BB
ja: 44c336489ea081d7d0ce0b8228379927c336b647
---

# 10-4 Binary Counter (4 bits, 4040)

Watch a counter that counts pulses in binary on LEDs. In clocks, timers and microcontrollers,
this circuit does the counting.

The slow square wave made by the 555 astable in 3-2 goes into the clock input of a CD4040
(a 12-stage binary counter); the clock is the pulse that tells the counter to count. Watch the lower 4 bits (Q1 to Q4) on LEDs
to check that the count runs from 0000 to 1111 in binary. Q1 is the lowest digit (LSB)
and Q4 is the highest (MSB).

## Equations checked in this experiment

The clock period of the 555 astable is T = 0.69 × (R1 + 2·R2) × C1 (the same equation as in 3-2).
The 4040 counts one on each falling edge of the clock (the moment it changes from H to L).
Inside, 12 T flip-flops (seen in 10-5) are chained so that the output of one stage becomes the
clock of the next (a ripple counter, so called because the count travels from stage to stage like a ripple).

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 555 clock + 4040 binary counter
parts:
  U555: ic 6,5 NE555
  VCC: vcc 3,2 5V
  R1: resistor 3,2 3,4.5 10k
  R2: resistor 3,4.5 3,6 47k
  C1: capacitor 4,6 4,8 10u
  GC1: ground 4,8
  GU555: ground 6,8
  U40: ic 15,5 CD4040B
  VCC: vcc 15,1 5V
  GU40: ground 15,10
  VCC: vcc 10,7 5V
  SWRST: button 10,7 12,7 l=$\mathrm{SW_{RST}}$
  RRST: resistor 12,7 12,9 10k l=$R_\mathrm{RST}$
  GRRST: ground 12,9
  RQ1: resistor 27,5 27,6 1k l=$R_\mathrm{Q1}$
  DQ1: led 27,6 27,7 red l=$D_\mathrm{Q1}$
  GQ1: ground 27,7
  RQ2: resistor 24,5 24,6 1k l=$R_\mathrm{Q2}$
  DQ2: led 24,6 24,7 red l=$D_\mathrm{Q2}$
  GQ2: ground 24,7
  RQ3: resistor 21,5 21,6 1k l=$R_\mathrm{Q3}$
  DQ3: led 21,6 21,7 red l=$D_\mathrm{Q3}$
  GQ3: ground 21,7
  RQ4: resistor 18,5 18,6 1k l=$R_\mathrm{Q4}$
  DQ4: led 18,6 18,7 red l=$D_\mathrm{Q4}$
  GQ4: ground 18,7
wires:
  # 555 astable
  - U555.VCC |- 6,2
  - U555.RESET |- 6.5,2
  - 3,2 -- 6,2 -- 6.5,2
  - U555.DISCH -| 3,4.5
  - U555.THRES -| 4,5
  - U555.TRIG -| 4,5.5
  - 4,5 -- 4,6
  - 3,6 -- 4,6
  - U555.GND |- 6,8
  # Clock: 555 OUT to 4040 CLOCK
  - U555.OUT -| 10,5
  - U40.CLOCK -| 10,5
  # Reset: SWRST pulls to +5V; when released, RRST pulls to GND
  - U40.R -| 12,7
  # 4040 power
  - 15,1 |- U40.VDD
  - U40.VSS |- 15,10
  # Outputs: Q1 outermost, run to the right so the wires do not cross
  - U40.Q1 -| 27,5
  - U40.Q2 -| 24,5
  - U40.Q3 -| 21,5
  - U40.Q4 -| 18,5
notes:
  - text 27,9 blue center: Q1 (LSB)
  - text 24,9 blue center: Q2
  - text 21,9 blue center: Q3
  - text 18,9 blue center: Q4 (MSB)
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/circuit/04-binary-counter.svg)

- The 555 is a standard astable (R1 10 kΩ, R2 47 kΩ, C1 10 µF).
  T ≈ 0.69 × (10 kΩ + 2 × 47 kΩ) × 10 µF ≈ 0.72 s, f = 1/T ≈ 1.4 Hz (calculated value)
- The 555 output (PIN 3) is the clock of the 4040 (PIN 10). The count advances by one on each falling edge
- Pressing SWRST brings PIN 11 (RESET) to +5 V (H) and the counter returns to 0000.
  When released, RRST (10 kΩ) pulls PIN 11 down to GND (L)
- Q1 (PIN 9), Q2 (PIN 7), Q3 (PIN 6) and Q4 (PIN 5) are the lower 4 bits. The 5th bit and above
  are not used in this exercise
- The CD4040 has only two inputs, CLK (PIN 10) and RESET (PIN 11), and both are connected
  (RESET goes to GND through RRST). A CMOS input must not be left floating, but this IC has
  no unused inputs. The unused Q5 to Q12 are outputs, so leave them unconnected
- Power pins: on the 4040, VDD is PIN 16 and VSS is PIN 8; on the 555, VCC is PIN 8 and GND is PIN 1
- The 4040 (U40) and the 555 (U555) in Fig. 1 are drawn as boxes with the pins arranged by function.
  The top is power (VDD, VCC), the left is inputs (CLOCK, R), the right is outputs (Q1 to Q4), and the bottom is GND (VSS, GND).
  The PIN numbers are written inside the box. The unused Q5 to Q12 have no wires and are left open.
  The LEDs are arranged with Q1 on the far right and Q4 on the far left so that the output wires do not cross
- The series resistors RQ1 to RQ4 for the LEDs are 1 kΩ. As in 10-1, the output of a 5 V CD4000-series gate can source
  only a few mA (the CD4040B is also a standard CD4000B-series output, with a minimum I<sub>OH</sub> of 1.6 mA at an
  output of 2.5 V), so the LED current is kept to 1.5 to 2.2 mA (the rough guide worked out in 10-1).
  If the LEDs are too dim, use high-brightness LEDs or switch to the 74HC4040, which has the same pin arrangement

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  U555: dip8 @ e5 NE555
  R1: resistor b6 b3 10k
  R2: resistor c6 c9 47k
  C1: capacitor/electrolytic i9 i12 10u
  RRST: resistor c17 c14 10k
  SWRST: button @ e17
  U40: dip16 @ e22 CD4040
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1-, 1+, 2+, 2-]
  RQ1: resistor a32 a34 1k
  DQ1: led c34(A) c36(K) red
  RQ2: resistor a38 a40 1k
  DQ2: led c40(A) c42(K) red
  RQ3: resistor a44 a46 1k
  DQ3: led c46(A) c48(K) red
  RQ4: resistor a50 a52 1k
  DQ4: led c52(A) c54(K) red
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t62 -- +b62 red
  - a5 -- +t5 red
  - a3 -- +t3 red
  - j5 -- -b5 black
  - j8 -- +b8 red
  - b7 -- b9 orange
  - d9 -- f9 orange
  - g9 -- g6 orange
  - j12 -- -b12 black
  - h7 -- h21 blue
  - g21 -- e21 blue
  - d21 -- d28 blue
  - c27 -- c19 green
  - a14 -- -t14 black
  - j17 -- +b17 red
  - a22 -- +t22 red
  - j29 -- -b29 black
  - d29 -- d32 yellow
  - g28 -- g38 yellow
  - f38 -- e38 yellow
  - h27 -- h44 yellow
  - f44 -- e44 yellow
  - i26 -- i50 yellow
  - f50 -- e50 yellow
  - a36 -- -t36 black
  - a42 -- -t42 black
  - a48 -- -t48 black
  - a54 -- -t54 black
  - SC.1+ -- a21 yellow
  - SC.1- -- -t19 black
  - SC.2+ -- b29 blue
  - SC.2- -- -t31 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/breadboard/04-binary-counter.svg)

- The power supply is Supplies on the Analog Discovery 3 (AD3, the USB instrument used in 0-3), with V+ set to 5 V.
  Connect V+ of the AD3 at the upper left to the top red rail (column 1) and GND to the top blue rail (column 2).
  The bottom rails are joined to the top rails by blue at column 1 and by red at column 62 (the right end)
- U555 (NE555) occupies columns 5 to 8 and U40 (CD4040) columns 22 to 29. Both have the notch on the left, with PIN 1 at the lower left (row f). On U555, PIN 8 (upper side of column 5) is at the upper left; on U40, PIN 16 (upper side of column 22) is at the upper left
- U555: PIN 8 (upper side of column 5) and PIN 4 (RESET, lower side of column 8) go to +5 V, and PIN 1 (lower side of column 5) goes to GND.
  R1 runs from PIN 7 (upper side of column 6) to +5 V at column 3, and R2 runs from PIN 7 to column 9. Column 9 is
  joined on row b to PIN 6 (upper side of column 7) and is also carried across the center gap by an orange wire to PIN 2 (lower side of column 6).
  C1 (+ at the lower side of column 9) goes to GND. PIN 5 (CONT) is not used
- U40: PIN 16 (upper side of column 22) goes to +5 V and PIN 8 (lower side of column 29) to GND. PIN 10 (CLK, upper side of column 28)
  is fed from PIN 3 of the 555 (lower side of column 7) by a blue wire (row h → crosses the center gap at column 21 → row d).
  PIN 11 (RESET, upper side of column 27) is carried by a green wire on row c to column 19, goes to GND through RRST (10 kΩ),
  and goes to +5 V when SWRST (e17) is pressed
- Q1 (PIN 9, upper side of column 29), Q2 (PIN 7, lower side of column 28), Q3 (PIN 6, lower side of column 27) and Q4 (PIN 5,
  lower side of column 26) are carried by yellow wires to columns 32, 38, 44 and 50 (the lower three run along rows g, h and i
  and cross the center gap), and go to GND through a 1 kΩ resistor and an LED
- The AD3 oscilloscope: plug 1+ (yellow) into the clock column 21 (`a21`, partway along the blue wire from PIN 3 of the 555 to PIN 10 of U40),
  and 2+ (blue) into the Q1 column 29 (`b29`). 1− and 2− (black) go to the top blue rail (GND)
- The current through the breadboard is about 2.2 mA × 4 ≈ 9 mA with all four LEDs lit, plus about 3 mA for the NE555 itself (datasheet typical value)
  and a few hundred µA in R1, about 13 mA in total. This is within the breadboard limits (200 mA per hole, 500 mA for the whole breadboard) and within the rough guide for
  V+ of the AD3 on USB power (50 mA at 5 V)

## Instrument settings

The instruments are Supplies on the AD3 (the power supply) and the oscilloscope (Scope). Display the clock and Q1 on the same time axis and check that
**Q1 toggles on the falling edge of the clock and its period is twice the clock period** (divide by 2).
The clock is slow, about 1.4 Hz, so either set the WaveForms Scope to Scan (rolling display)
or set the time range to 500 ms/div to fit about 7 periods on one screen.

| Item | Value |
| --- | --- |
| Power | V+ of Supplies at 5 V; V− is not used |
| CH1 (1+) | Clock (555 PIN 3 = 4040 PIN 10). 1 V/div, 0 V one division up from the bottom |
| CH2 (2+) | Q1 (4040 PIN 9). Same 1 V/div and same 0 V position as CH1 |
| 1−, 2− | GND |
| Time range | 500 ms/div |
| Trigger | Rising edge of CH1, 1.8 V. Place the trigger point one division from the left |
| Measurements | Frequency, Duty |
| Cursors | Place X1 and X2 just after two successive falling edges of the clock. ΔX is one clock period = half a period of Q1 |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Clock (CH1) and Q1 (CH2), Q1 halves the frequency
time: 500ms/div
trigger: ch1 rising 1.8V at -4div
ch1: {wave: square 1.394Hz 1.7V offset 1.8V duty 54.8%, range: 1V/div, position: -3div}
ch2: {wave: square 0.697Hz 2V offset 2V | delay 393ms, range: 1V/div, position: -3div}
cursors: [400ms, 1.117s]
measure: [freq, duty, vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/10-logic/scope/04-binary-counter.svg)

- CH1 (the clock) in Fig. 3 swings between about 0.1 V and about 3.5 V. High lasts about 0.39 s and Low about 0.32 s
  (from the equations in 3-2, tH = 0.69 × (R1 + R2) × C1 and tL = 0.69 × R2 × C1; calculated values)
- CH2 (Q1) swaps between 0 and 1 each time the clock falls (at the cursors X1 and X2).
  The frequency of Q1 is half the clock, about 0.70 Hz, with a duty cycle of 50%. The High level of Q1 is about 4 V while
  sourcing about 2 mA into the LED (the rough guide in 10-1, for a typical part)
- If you move 2+ to Q2, Q3 and Q4, the frequency halves each time (about 0.35 Hz, 0.17 Hz and 0.087 Hz)

## Values to check

Calculated values. With T ≈ 0.72 s, one full cycle of 16 clocks (0000→1111→0000) takes
about 11.5 s (16 × 0.72 s). The Q1 LED swaps between lit and off every 0.72 s.
Q2 swaps at twice that interval, Q3 at 4 times and Q4 at 8 times.

| Clock count | Q4 Q3 Q2 Q1 | Decimal |
| --- | --- | --- |
| 0 | 0000 | 0 |
| 5 | 0101 | 5 |
| 10 | 1010 | 10 |
| 15 | 1111 | 15 |
| 16 | 0000 | 0 (overflow) |

Reading a lit LED as 1 and an unlit LED as 0, from the left as Q4 Q3 Q2 Q1, gives the clock count
as a binary number. Pressing SWRST returns the count to 0000 at any time.

## Verification with LTspice

The insides of the 555 and the 4040 are outside what SPICE handles (LTspice has no standard 555 model), so the astable equation T = ln 2 × (R1 + 2 R2) × C1 was checked with arithmetic computed by .meas in `sim/04-binary-counter.cir`.

| Item | Value in the text | Arithmetic | Verdict |
| --- | --- | --- | --- |
| Period T | about 0.72 s | 0.721 s (1.387 Hz) | Agrees |
| Duty cycle | about 54.8 % (Fig. 3) | 54.8 % | Agrees |
| One cycle of 16 clocks | about 11.5 s | 11.5 s | Agrees |
| Frequency of Q1 (half the clock) | about 0.69 Hz (0.697 Hz in Fig. 3) | 0.694 Hz | Agrees (Fig. 3 uses ln 2 rounded to 0.69) |

The count sequence (0000 → 0101 → 1010 → 1111 → 0000) is ordinary binary counting, not something to check with SPICE.

## Sources

Original work.

See also: [CD4040B datasheet](https://www.ti.com/lit/ds/symlink/cd4040b.pdf), [NE555 datasheet](https://www.ti.com/lit/ds/symlink/ne555.pdf), [Counter (Wikipedia, Japanese)](https://ja.wikipedia.org/wiki/カウンタ)
