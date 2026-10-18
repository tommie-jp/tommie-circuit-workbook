---
book: circuits
chapter: 8
id: 8-3
title: Touch switch (human body)
tier: 50
source: 自作
board: BB
era: 古
ja: 516f1333849312872d49f9687bcc503cce8f6e8d
---

# 8-3 Touch switch (human body)

This exercise builds a circuit in which an LED lights just by touching two terminals with a finger. Human skin has a
large resistance of several hundred kΩ, and the current through a finger is only a few µA. Two transistor stages (a
Darlington connection, seen in 2-4) raise the gain to the square of h<sub>FE</sub>, so even that tiny current works as
a switch. It is a classic circuit from the days when semiconductors were expensive and precious.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 The LED lights when a finger touches
parts:
  VCC: vcc 2,2 5V
  TPA: port 2,4
  TPB: port 3,4
  R1: resistor 4,4 4,6 1M
  G1: ground 4,6
  Q1: npn 6,4 2SC1815
  R3: resistor 6,7 6,9 100k
  G2: ground 6,9
  R4: resistor 8,2 8,4 330
  D1: led 8,4 8,6
  Q2: npn 8,7 2SC1815
  G4: ground 8,8
wires:
  - 2,2 -- 2,4
  - 2,2 -- 6,2 -- 8,2
  - 3,4 -- 4,4 -- Q1.B
  - 6,2 -- Q1.C
  - Q1.E -- 6,7 -- Q2.B
  - 8,6 -- Q2.C
  - Q2.E -- 8,8
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/03-touch-switch.svg)

- When a finger is placed between TPA (the terminal on the supply side) and TPB (the terminal on the base side of Q1),
  a small current flows in through the resistance of the skin (several hundred kΩ). R1 (1 MΩ) is a pull-down that
  pulls the base lightly to GND, and when the current from the finger wins over it, the base voltage of Q1 rises
- Connecting the emitter of Q1 directly to the base of Q2 is the Darlington connection. R3 (100 kΩ) is a bleeder
  resistor (seen in 8-2) that pulls the base of Q2 lightly to GND, so that Q2 is reliably OFF when Q1 is OFF
- D1 (the LED) is in series with R4 on the collector of Q2 (+5 V → R4 → D1 → Q2 → GND). With no touch, Q2 is OFF, the
  path through D1 is cut, and the LED is dark. When touched, Q2 turns ON, the path forms, and D1 lights
- The gain of the two stages is h<sub>FE1</sub> × h<sub>FE2</sub> (about 10,000 for two 2SC1815). Amplifying the base
  current this much easily exceeds the current the LED needs. As long as the skin resistance is up to about 1.6 MΩ
  (calculated value; see "Values to check" below), a touch lights the LED fully, up to the current set by R4

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5V, blue rail = GND (carried to the lower rails at columns 29 and 30)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  Q1: transistor c8(B) c9(C) c10(E) 2SC1815
  R3: resistor b15 b18 100k
  Q2: transistor c20(B) c21(C) c22(E) 2SC1815
  R1: resistor g4 g8 1M
  D1: led h25(A) h21(K) red
  R4: resistor f25 f28 330
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t9 -- a9 red
  - a10 -- a15 yellow
  - -t18 -- a18 black
  - d15 -- d20 yellow
  - -t22 -- a22 black
  - e8 -- f8 green
  - j4 -- -b4 black
  - h8 -- h11 green
  - j13 -- +b13 red
  - e21 -- f21 orange
  - j28 -- +b28 red
  - -t29 -- -b29 black
  - +t30 -- +b30 red
notes:
  - text: Touch columns 11 (base side) and 13 (+5V side)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/03-touch-switch.svg)

- Connect V+ (+5 V) and GND of the AD3 to the upper rails, and carry them to the lower rails at the right end
  (columns 29 and 30)
- The two points to touch are column 11 of the lower block (joined by a green wire to column 8, the base of Q1) and
  column 13 (joined to the lower + rail). Plug bare wires or alligator clips into i11 and i13 and leave them sticking
  out, then press the pad of a finger on both at the same time. The LED lights the moment you touch them
- Q1 and Q2 (2SC1815) read E, C, B from the left when you face the flat side. Here they are inserted with the flat
  side facing the back (the a-row side), and B, C, E go into row c in that order. The base of Q1 (column 8) is carried
  to the lower block by a green wire, and goes through R1 (columns 4 to 8) to the lower − rail
- From the emitter of Q1 (column 10), a yellow wire goes to R3 (columns 15 to 18) and to the base of Q2 (column 20)
- The collector of Q2 (column 21) goes by an orange wire to the lower block and to the cathode of the LED (column 21).
  From the anode of the LED (column 25), a path through R4 (columns 25 to 28) leads to the lower + rail. The cathode of
  the LED is connected to the collector of Q2, not to GND

## Instrument settings

The instruments are Supplies (the power supply) of the Analog Discovery 3 and a multimeter. Set V+ of the AD3 to 5 V
and turn the output on. The circuit draws about 8.5 mA for the LED, plus a few µA through the finger and R1, within the
roughly 50 mA of one supply channel of the AD3. The current through one hole of the breadboard is also 200 mA or less,
within the range of the breadboard.

This exercise has no oscilloscope figure. What you look at is the DC voltage and the lit LED when a finger touches the
terminals, not a waveform that changes with time. The multimeter readings are enough.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (base pull-down) | 1 MΩ |
| Q1, Q2 | NPN transistor | 2SC1815 |
| R3 | Resistor (bleeder) | 100 kΩ |
| R4 | Resistor | 330 Ω |
| D1 | LED (red) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of Supplies on the AD3) |

## Values to check

The values in the table are calculated values. The resistance of a finger varies greatly between people and with
moisture, so 470 kΩ is used here as a rough guide. The base of the Darlington is taken to be at about 1.4 V, two
V<sub>BE</sub>.

| State | Base current (Ib1, calculated) | Collector current of Q2 (calculated) | LED |
| --- | --- | --- | --- |
| Not touched | 0 (R1 pulls it fully down) | 0 | Dark |
| Touched by a finger (skin resistance about 470 kΩ) | about 6.3 µA | about 8.5 mA (= (5 − 2.0 − 0.2) / 330 Ω, capped by R4) | Lit |

The current that enters the base node through the finger resistance (470 kΩ) is (5 V − 1.4 V) / 470 kΩ ≈ 7.7 µA.
Of that, R1 (1 MΩ) takes 1.4 V / 1 MΩ ≈ 1.4 µA to GND, so the current that actually enters the base of Q1 is the
difference, about 6.3 µA (calculated value).

Assuming h<sub>FE</sub> = 100, the combined gain of the Darlington is 10,000.
Multiplying 6.3 µA by 10,000 gives as much as 63 mA, far more than the 8.5 mA the LED needs.
So even with a much larger finger resistance (a dry finger), the LED usually lights without fail.
The base current needed to light the LED fully is 8.5 mA / 10000 = 0.85 µA, and the upper limit of the finger
resistance that can supply it is 3.6 V / (0.85 + 1.4) µA ≈ 1.6 MΩ.

Check the LED by eye. If you measure the collector voltage of Q2 (between column 21 and GND) on the multimeter's DC
voltage range, it falls to about 0.2 V when you touch the terminals.

## Verification with LTspice

`sim/03-touch-switch.cir` solves Fig. 1 in DC while sweeping the finger resistance over 470 kΩ, 1.6 MΩ and 3 MΩ.
Q1 and Q2 are substitute models fitted to h<sub>FE</sub> = 100 (not measured).

| Item | Number in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Current through a 470 kΩ finger (into the base node of Q1) | about 7.7 µA | 7.76 µA | agrees |
| Current entering the base of Q1 (after subtracting R1) | about 6.3 µA | 6.4 µA (7.76 − 1.35) | agrees |
| Voltage of the node | about 1.4 V | 1.35 V | agrees |
| LED current | about 8.5 mA | 8.7 mA | agrees |
| Collector voltage of Q2 | about 0.2 V | 0.13 V | agrees |
| With a 1.6 MΩ finger | the limit for full brightness | LED 8.4 mA (lit) | agrees |
| With a 3 MΩ finger | — | LED 0.73 mA (faint) | beyond the limit |

## Sources

Original work.
