---
book: circuits
chapter: 7
id: 7-2
title: PWM Control of a DC Motor (MOSFET)
tier: 50
source: 自作
board: BB
era: 今
ja: 69ba289b8c61580e8c7d82817b87bdd59a11bfb6
---

# 7-2 PWM Control of a DC Motor (MOSFET)

One MOSFET changes the speed of a 5 V DC motor. A motor's speed is set roughly by the average voltage across it.
Lowering the voltage with a resistor wastes power as heat. Instead, a MOSFET (the switch from 2-5) is turned ON and OFF
at high speed, and the average voltage is changed through the duty cycle (the fraction of one period that the switch
is ON, seen in 3-6). This method is called **PWM** (Pulse Width Modulation), and it is the standard way to control
motors today.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 PWM motor drive (CH2 is the drain of Q1)
parts:
  R3: resistor 11,1 11,3 15
  B1: battery 11,3 11,5 5
  M1: motor 5,1 5,3
  D1: diode 7,3 7,1 1N4001
  Q1: nmos-e 5,3.81 2N7000
  R1: resistor 1,4 3,4 100
  R2: resistor 3,4 3,6 10k
  PWM: square 1,4 1,6 5 l=$\mathrm{PWM}$
  G1: ground 5,6
  G2: ground 3,6
  G3: ground 1,6
  G4: ground 11,5
  M2: voltmeter 9,3 9,5 l=$\mathrm{CH2}$
  G5: ground 9,5
wires:
  - 5,1 -- 7,1 -- 11,1
  - 5,3 -- 7,3 -- 9,3
  - 5,3 -- Q1.D
  - Q1.S -- 5,6
  - 3,4 -| Q1.G
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/circuit/02-motor-pwm.svg)

- PWM (the signal from W1 of the AD, viewed on CH1) stands for a square-wave source (0–5 V, with an adjustable duty
  cycle). In practice, use a function generator (see 0-6) or the PWM output of a microcontroller (a Pico 2 and so on;
  see 11-4)
- R1 (100 Ω) limits the charge and discharge current into the gate of the MOSFET. R2 (10 kΩ) pulls the gate lightly to
  GND (a pull-down). Even if the PWM side comes off or is left in a state equivalent to nothing connected (high
  impedance), Q1 does not stay half ON
- D1 (1N4001) is a flyback diode in parallel with the motor. At the moment Q1 turns OFF, the coil component of the
  motor (the inductance of its windings) produces a back EMF, and D1 protects the MOSFET on the same principle as
  6-2 and 7-1
- Q1 (2N7000) is a small-signal MOSFET that turns ON with a 5 V gate voltage. According to the datasheet (Vishay
  2N7000), the continuous drain current is 0.2 A and the ON resistance r<sub>DS(on)</sub> is 4.5 Ω (typical) and
  5.3 Ω (maximum) at V<sub>GS</sub> = 4.5 V
- **M1 is a low-current motor, and R3 (15 Ω) is a resistor that limits the current.** At the moment a motor starts and
  when its shaft is stopped (stall), several times the running current flows, because only the winding resistance
  sets the current. A typical small 5 V motor can draw more than 0.5–1 A at stall, which exceeds the 0.2 A of the
  2N7000 and the 200 mA per hole of the breadboard (the board table in the README). So choose a motor with a small
  stall current and put R3 in series, to keep the current within 0.2 A even in the worst case
- M1 is the Mabuchi RF-300CA-11440 (sold as a solar motor). The datasheet gives a usable voltage of 0.7–5.0 V and, at
  2 V, a no-load current of 0.018 A and a stall current of 0.17 A. The winding resistance is 2 V ÷ 0.17 A ≈ 11.8 Ω
- The stall current (5 V, PWM 100 %) is I = 5 V ÷ (winding + R3 + r<sub>DS(on)</sub>). Substituting gives
  5 ÷ (11.8 + 15 + 4.5), which is about 0.16 A. Without R3 it would be 5 ÷ (11.8 + 4.5) ≈ 0.31 A, above the limit.
  The power in R3 at stall is 0.16² × 15 ≈ 0.38 W, so use a 1 W part, at least twice that. While the motor runs, the
  current is tens of mA, so R3 drops only about 0.4 V
- If you use another motor, measure its winding resistance with a multimeter and choose R3 so that
  5 V ÷ (winding + R3 + 4.5 Ω) is 0.2 A or less. For a larger motor, work off the breadboard, with a logic-level power
  MOSFET such as the IRLZ44N and thick wire

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Motor and MOSFET (W1 = PWM, 1+ = PWM, 2+ = drain)
board: half
parts:
  R3: resistor/half d2 d5 15
  D1: diode b5(K) b8(A) 1N4001
  R2: resistor b9 b12 10k
  R1: resistor d9 d14 100
  Q1: transistor h8(D) h9(G) h10(S) 2N7000
  PSU:
    type: device
    at: top
    label: 5 V supply (AC adapter etc.)
    pins: ["+", "-"]
  MTR:
    type: device
    at: top
    label: DC motor RF-300CA
    pins: [M+, M-]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (W1 and Scope)
    pins: [2+, W1, 1+, 1-, 2-, GND]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t3 black
  - +t2 -- a2 red
  - MTR.M+ -- a5 brown
  - MTR.M- -- a8 orange
  - a12 -- -t12 black
  - e8 -- f8 orange
  - e9 -- f9 green
  - j10 -- -b10 black
  - -t27 -- -b27 black
  - AD.W1 -- c14 yellow
  - AD.1+ -- e14 blue
  - AD.2+ -- j8 green
  - AD.1- -- -b17 black
  - AD.2- -- -b19 black
  - AD.GND -- -b21 black
notes:
  - text: The right end of R1 (column 14) is the PWM input. Connect W1 of the AD or a microcontroller
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/breadboard/02-motor-pwm.svg)

- The motor is not plugged into the breadboard; it is connected by wires. +5 V goes from column 2 through R3
  (columns 2 to 5) to the + side of the motor (column 5, brown wire).
  The cathode of D1 (column 5) is on the + side of the motor and its anode (column 8) is on the − side, so D1 is in
  parallel with the motor. An orange wire carries column 8 across to the drain of Q1 in the lower block
- The holes that carry the motor current (at most the stall current of about 0.16 A) are the + rail, column 2,
  column 5, column 8, the pins of Q1 and the − rail. All of them are within the 200 mA per hole in the board table of the README
- Column 9 of the upper block is the point that joins R1, R2 and the gate of Q1. R2 (columns 9 to 12) goes from
  column 12 to the − rail, and the right end of R1 (columns 9 to 14), column 14, is the PWM input. A green wire
  carries column 9 across to the gate of Q1 in the lower block
- Q1 (2N7000) is a TO-92. Seen from the flat side, the pins read S, G, D from the left (a different order from the
  2SC1815). Here it is inserted with the flat side facing the back (the a-row side), so it reads D, G, S from the
  left and goes into columns 8, 9 and 10 of row h. Connect the source (S, column 10) to the lower − rail
  Note: **check on the real part. The 2007 onsemi figure shows S G D, while the 2022 table shows D G S, and they
  disagree; the table follows the 2007 version (S G D). Check the real part with a multimeter**
- Connect the GND of the PWM signal to the − rail
- Use a separate 5 V supply (a 5 V AC adapter or a bench power supply). The running current is tens of mA, and with
  the shaft stopped it is about 0.16 A (the calculation above), which exceeds the 50 mA per rail of Supplies on the
  Analog Discovery (250 mW on USB power). So the AD3 is used only for the PWM signal (W1) and the oscilloscope (Scope)
- Feed the PWM from W1 of the AD (yellow) into column 14 (`c14`), the right end of R1. 1+ (blue) is in the same
  column 14 (`e14`) and reads PWM, and 2+ (green) is on column 8 (`j8`), the drain of Q1. 1−, 2− and GND (black) go to
  the lower − rail. W1 supplies up to 30 mA, and the current the gate needs (about 0.5 mA through R2) is far smaller

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| M1 | DC motor (low-current type) | Mabuchi RF-300CA-11440 (0.7–5.0 V; at 2 V, no load 0.018 A, stall 0.17 A) |
| R3 | Resistor (limits the motor current, 1 W) | 15 Ω |
| Q1 | N-channel MOSFET | 2N7000 |
| D1 | Rectifier diode (for flyback) | 1N4001 |
| R1 | Resistor (series gate) | 100 Ω |
| R2 | Resistor (gate pull-down) | 10 kΩ |
| — | Power supply | A 5 V AC adapter or bench power supply (the stall current of about 0.16 A exceeds the 50 mA of Supplies on the AD3) |
| — | Instruments and PWM source | W1 of the Analog Discovery 3 (PWM, a 0 V / 5 V square wave at 1 kHz) and Scope (1+ = PWM, 2+ = drain of Q1, 1− and 2− = GND) |

## Instrument settings

The instruments are W1 of the Analog Discovery 3 (the PWM source) and Scope. The width and shape of the PWM pulses
show only in the time waveform, so a multimeter is not enough. Set W1 to Simple, Square, Frequency 1 kHz,
Amplitude 2.5 V, Offset 2.5 V, Symmetry (duty cycle) 50 %. Overlay CH1 (PWM) and CH2 (drain of Q1) at the same 1 V/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 PWM (CH1) and drain (CH2), 50 % duty
time: 500us/div
trigger: ch1 rising 2.5V
ch1: {wave: pulse 1kHz 2.5V offset 2.5V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: "ch1 | invert | offset 5V | gain 0.96 | offset 200mV", range: 1V/div, position: -3div}
measure: [vmax, vmin, freq, duty]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/scope/02-motor-pwm.svg)

Fig. 3 shows the ideal shape. CH2 moves opposite to PWM. While Q1 is ON, the drain falls to near 0 V, and while it is
OFF, the drain returns to 5 V. The 0.2 V during ON is an estimate, the product of the 4.5 Ω ON resistance of the
2N7000 and a running motor current of tens of mA (a rough guide). It is not measured (at the stall current of 0.16 A
it would be about 0.7 V). At the moment of turn-off, D1 passes the back EMF of the motor, so the drain rises for an
instant to about 0.7 V above 5 V. When you change the duty cycle to 25 % or 75 %, the ON width of CH1 and the average
voltage in the table below (5 V × duty cycle) change in proportion.

## Values to check

The values in the table are calculated values. The average PWM voltage is 5 V × duty cycle, and it is applied to the
motor and R3 together. The speed of the motor is set roughly by this average voltage.
Measure the average voltage across the motor and R3 on the multimeter's DC voltage range (the multimeter smooths fast
changes and shows the average).
View the PWM waveform on the oscilloscope of the Analog Discovery (1+ on PWM, 2+ on the drain of Q1, 1− and 2− on GND) (Fig. 3).

| Duty cycle | Average voltage across the motor and R3 | How it turns |
| --- | --- | --- |
| 25% | 1.25 V | Turns slowly (the RF-300CA starts turning at 0.7 V) |
| 50% | 2.5 V | About half speed |
| 75% | 3.75 V | Turns fast |
| 100% (ON all the time) | 5.0 V | Full speed (the same as a direct connection, not PWM) |

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Motor current while running (100 %; put the multimeter's current range in series with the M+ wire) | Tens of mA or less (rough guide) | The datasheet no-load current is 0.018 A at 2 V. It is smaller with a light load |
| Current with the shaft lightly stopped by a finger (100 %) | About 0.16 A (calculated) | 5 V ÷ (11.8 + 15 + 4.5) Ω. Within the 0.2 A of the 2N7000 and the 200 mA per hole. Do not leave it stopped for long |
| PWM frequency of 1 kHz | The motor makes a whining sound | The windings vibrate at the switching frequency. 1 kHz is inside the range of human hearing (about 20 Hz–20 kHz) |
| PWM frequency of 15–20 kHz or higher | The sound almost disappears | This approaches the upper edge of the audible range. Most adults hear poorly above 15 kHz |
| D1 removed and the duty cycle suddenly set to 0 | Q1 may overheat or be destroyed | Why the flyback diode is needed (**this book does not remove it to try**) |

## Verification with LTspice

In LTspice (the stalled state with the shaft stopped; winding 11.8 Ω; the 2N7000 as an approximate model of 4.5 Ω at
V<sub>GS</sub> = 4.5 V; PWM at 1 kHz; not measured), the average current at duty cycles of 25, 50, 75 and 100 % is 39, 79,
119 and 160 mA, and the maximum is 0.16 A, which agrees with the stall current of about 0.16 A in the table.
The average voltage across the motor and R3 is 1.05, 2.12, 3.20 and 4.30 V, lower than 5 V × duty cycle in the table
(1.25–5.0 V) by the drop in Q1 (about 0.7 V at stall).
While the motor runs, the current is small and so is the drop in Q1, so the values approach those in the table.
The drain spike at turn-off is 5.8 V (5 V + the forward voltage of D1, about 0.8 V), close to the "about 0.7 V" in the
figure (the deck is `sim/02-motor-pwm.cir`).

## Sources

Original work.
