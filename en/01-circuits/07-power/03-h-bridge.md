---
book: circuits
chapter: 7
id: 7-3
title: H-bridge — forward and reverse
tier: 50
source: 自作
board: BB
ja: 7a789f382f9614b381d82a9f88130b665ea95708
---

# 7-3 H-bridge — forward and reverse

The same small motor as in 7-2 (Mabuchi RF-300CA-11440) turns forward and in reverse on 5 V. A DC motor turns the
other way when the polarity of the applied voltage is reversed. To change the direction, switch each end of the
motor to either the + or the − of the supply.
Two changeover switches (SPDT: a switch that connects a common pin to one of two other pins) are enough to make
three states: forward, reverse and brake.
The function of four switches is arranged in the shape of an H around the motor, which is why this is called an
**H-bridge**.
A practical H-bridge does the same thing faster with transistors or MOSFETs, and the gate driver IC in 7-8 is an IC
that drives them.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 An H-bridge made of two changeover switches
parts:
  B1: battery 1,1 1,3 5
  S1: spdt 3,2 mirror
  S2: spdt 11,2
  M1: motor 5,2 7,2
  R1: resistor 7,2 9,2 15
wires:
  - S1.in -| 5,2
  - S2.in -| 9,2
  - S1.1 -| 2,1
  - 1,1 -- 2,1 -- 12,1
  - S1.2 -| 2,3
  - 1,3 -- 2,3 -- 12,3
  - S2.1 -| 12,1
  - S2.2 -| 12,3
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/circuit/03-h-bridge.svg)

- M1 is the same RF-300CA-11440 as in 7-2 (stall 0.17 A at 2 V, winding resistance about 11.8 Ω). To limit the current
  when the shaft is stopped, a 15 Ω resistor R1 (1 W), the same as R3 in 7-2, is put in series.
  5 V ÷ (11.8 + 15) ≈ 0.19 A, within the 200 mA per hole of the breadboard (the board table in the README).
  Without R1 it would be 5 ÷ 11.8 ≈ 0.42 A
  (the power in R1 at stall is 0.187² × 15 ≈ 0.52 W, so use a 1 W part)
- CH1 of Scope is placed across M1 and R1 together (1+ on the S1 side, 1− on the S2 side; not drawn in Fig. 1)
- S1 handles the left end of M1 and S2 handles the right end (SW1 and SW2 in Fig. 2).
  Each can select side 1 (+5 V) or side 2 (GND). In Fig. 1, the upper contact is 1 and the lower contact is 2
- With S1 = 1 and S2 = 2, current flows left to right and the motor turns forward. With S1 = 2 and S2 = 1, current
  flows right to left and the motor turns in reverse (only the direction is opposite; the voltage across the M1 and R1
  pair is 5 V, the same as at full speed in 7-2)
- With S1 and S2 on the same side, both ends of the motor are at the same potential and no current flows. Both ends
  are then shorted through the supply or GND. If you turn the shaft by hand, the voltage the motor generates drives a
  current in the direction that opposes the rotation, and it feels heavy (brake)
- Switching is by hand, so the flyback diode of 7-1 and 7-2 is omitted. A small spark may appear at the moment of
  switching, but with slow manual switching it is not a practical problem. When the circuit is built with
  semiconductor switches such as transistors, the diodes are required

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Two switches, motor and R1 (Scope on c)
# Top red rail = +5V, blue rail = GND
board: half
parts:
  PSU:
    type: device
    at: top
    label: 5 V supply (AC adapter etc.)
    pins: ["+", "-"]
  SW1: slide-switch b5(1) b6(c) b7(2)
  SW2: slide-switch b12(1) b13(c) b14(2)
  R1: resistor/half c13 c16 15
  MTR:
    type: device
    at: top
    label: DC motor RF-300CA
    pins: [M+, M-]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Scope)
    pins: [1+, 1-]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - +t5 -- a5 red
  - -t7 -- a7 black
  - MTR.M+ -- a6 orange
  - +t12 -- a12 red
  - -t14 -- a14 black
  - MTR.M- -- a16 orange
  - AD.1+ -- e6 blue
  - AD.1- -- e13 green
notes:
  - text: On SW1 and SW2, 1 = +5V, 2 = GND, c to motor and R1
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/breadboard/03-h-bridge.svg)

- Insert both SW1 and SW2 in the upper block and use the +5 V and GND of the upper rails.
  Connect pin 1 (columns 5 and 12) to the + rail and pin 2 (columns 7 and 14) to the − rail
- Use a separate 5 V supply (a 5 V AC adapter or a bench power supply). With the shaft stopped the current is about
  0.19 A (the calculation above), which exceeds the 50 mA per rail of Supplies on the Analog Discovery (250 mW on USB
  power), so the AD3 is used only for the oscilloscope (Scope). W1 is not used either (the circuit is switched by
  hand and needs no signal source)
- 1+ (blue) of Scope is on column 6 (`e6`), the c of SW1, and 1− (green) is on column 13 (`e13`), the c of SW2.
  They read the voltage across the M1 and R1 pair (positive when the 1+ side is +).
  Do not connect 1+ and 1− to the GND of the supply (read the voltage across the motor differentially, with neither
  end referenced to GND. The Scope inputs of the AD3 are differential, and 1− and 2− are not tied together inside)
- The motor is not plugged into the breadboard; it is connected by wires. Connect the left lead to the common pin c of
  SW1 (column 6) and the right lead to the right end of R1 (column 16). R1 (15 Ω) goes from c of SW2 (column 13) to
  column 16, in row c. Plug each wire into the free row a in the same column as the part's pin

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| M1 | DC motor (the same low-current type as in 7-2) | Mabuchi RF-300CA-11440 (0.7–5.0 V; at 2 V, no load 0.018 A, stall 0.17 A) |
| R1 | Resistor (limits the motor current, 1 W) | 15 Ω |
| SW1, SW2 | Slide switch (SPDT, changeover) | — |
| — | Power supply | A 5 V AC adapter or bench power supply (the stall current of about 0.19 A exceeds the 50 mA of Supplies on the AD3) |
| — | Instruments | Scope of the Analog Discovery 3 (1+ = c of SW1, 1− = c of SW2; the voltage across the M1 and R1 pair) |

## Instrument settings

The instrument is Scope of the Analog Discovery 3 (1+ = left end of M1, 1− = right end of R1). Switching is by hand,
and the difference between direction and brake shows in the sign of the voltage, so the oscilloscope suits this better
than a multimeter. Set Scope in WaveForms to Single (one capture), time base 1 s/div, vertical 2 V/div, and trigger on
a falling edge of CH1 at 2.5 V. Wait for the trigger, then switch from forward.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Forward, brake, reverse (+5, 0, −5 V)
time: 1s/div
trigger: ch1 falling 2.5V
ch1: {wave: "= 5V * (1 - step(t)) - 5V * step(t - 2s)", range: 2V/div, position: 0div}
cursors: [-2s, 3s]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/scope/03-h-bridge.svg)

Fig. 3 shows the ideal shape, and the switching times are an example of operating by hand (brake at t = 0, reverse 2 s
later). In a real circuit the contacts bounce at the moment of switching and cause a short disturbance.
The cursor readings are +5.00 V at −2 s (forward) and −5.00 V at 3 s (reverse). They correspond to the SW1 and SW2
combinations in the table below (forward is SW1 = 1 and SW2 = 2, brake is both on the same side, reverse is SW1 = 2
and SW2 = 1). The motor can generate a voltage, so even in brake the reading may differ slightly from 0 V.

## Values to check

The values in the table are calculated values. The motor is the same RF-300CA-11440 as in 7-2, and R1 is 15 Ω.
The running current is, from the datasheet no-load current (0.018 A at 2 V), tens of mA or less with a light load
(a rough guide). The maximum is when a finger stops the shaft: 5 V ÷ (11.8 + 15) Ω ≈ 0.19 A. Do not leave it stopped
for long. Measure the current by putting the multimeter's current (mA) range in series between the + of the supply
and the + rail.

| SW1 | SW2 | State of the motor | Current (calculated) |
| --- | --- | --- | --- |
| 1 (V+) | 2 (GND) | Forward | Tens of mA or less while running, about 190 mA with the shaft stopped, left to right |
| 2 (GND) | 1 (V+) | Reverse (turns the opposite way to forward) | Tens of mA or less while running, about 190 mA with the shaft stopped, right to left |
| 1 (V+) | 1 (V+) | No current flows (both ends at +5 V) | 0 mA. Turning it by hand brakes it |
| 2 (GND) | 2 (GND) | No current flows (both ends at GND) | 0 mA. It brakes in the same way |

## Verification with LTspice (not applicable)

The H-bridge only changes direction by switching, and the only values to check are the stopped-shaft current set by
the winding resistance of the motor and R1. The numbers in the text were checked by arithmetic. The stopped-shaft
current is 5 V ÷ (11.8 + 15) Ω ≈ 0.19 A = about 190 mA.

## Sources

Original work.
