---
book: circuits
chapter: 2
id: 2-1
title: Transistor Switch (LED)
tier: 50
source: 自作
board: BB
ja: 1d77e2097df210f575b65473e376341c44231e76
---

# 2-1 Transistor Switch (LED)

A transistor is a part that **controls a large current with a small current**. It has three pins, called the base (B),
collector (C) and emitter (E). When a small current flows from the base to the emitter,
a large current flows from the collector to the emitter. The 2SC1815 in this exercise is an NPN type. Current starts to flow when the base is raised to about
0.7 V above the emitter (the base-emitter voltage V<sub>BE</sub>). A small voltage is enough to drive the base, such as three batteries (4.5 V) or
the 5 V of USB.

The ratio of the collector current I<sub>C</sub> to the base current I<sub>B</sub> is called the **DC current gain hFE** (= I<sub>C</sub> / I<sub>B</sub>).
With an hFE of 100, 1 mA into the base lets up to 100 mA flow in the collector. Even for the same part number, units vary widely, and the 2SC1815 ranges from 70 to 700 (0-5 showed how to measure it).

In this exercise you switch the voltage at the base between 0 V and 5 V to turn an LED on and off,
using the transistor as a switch. This is the most basic circuit for turning an LED or a relay on and off with a weak signal such as a microcontroller output.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 NPN transistor LED switch, driven by W1
parts:
  VCC: vcc 9,2 5V
  R1: resistor 9,2 9,4 330
  D1: led 9,4 9,6
  Q1: npn 9,7
  RB: resistor 6,7 8,7 10k
  W1: square 2,7 2,9 l=$\mathrm{W1}$
  G1: ground 2,9
  M2: voltmeter 4,7 4,9 l=$\mathrm{CH2}$
  G3: ground 4,9
  G2: ground 9,8
  M1: voltmeter 11,6 11,8 l=$\mathrm{CH1}$
  G4: ground 11,8
wires:
  - 2,7 -- 4,7 -- 6,7
  - 8,7 -- Q1.B
  - 9,6 -- Q1.C
  - Q1.E -- 9,8
  - 9,6 -- 11,6
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/01-transistor-switch.svg)

The +5 V comes from the supply output V+ of the Analog Discovery (set it to 5 V in the WaveForms Supplies).
In place of a switch, the input is the 0 V / 5 V square wave from W1 (the waveform generator of the Analog Discovery, used in 1-3).
While W1 is at 5 V, current flows into the base and the transistor **saturates**, so the LED lights. Saturation means that, with
enough base current, the collector-emitter voltage falls to about 0.2 V and the transistor acts like a closed switch.
When W1 goes to 0 V, the LED goes out. CH2 reads the input (the left end of `RB`) and CH1 reads the voltage at the collector (the LED cathode) (Fig. 1).

- Base current: I<sub>B</sub> = (5 − 0.7) / 10 kΩ ≈ **0.43 mA**
- Collector current (LED): I<sub>C</sub> = (5 − 0.2 − 2.0) / 330 Ω ≈ **8.5 mA**
  (calculated with the saturated C-E voltage V<sub>CE(sat)</sub> ≈ 0.2 V and the LED forward voltage V<sub>F</sub> ≈ 2.0 V (seen in 1-4))
- I<sub>C</sub> / I<sub>B</sub> ≈ 20. This is much smaller than the hFE of the 2SC1815 (70 to 700),
  so even a unit with a low hFE saturates reliably (the basic rule when using a transistor as a switch)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Transistor switch (W1 and CH2 in, CH1 on collector)
# Top + rail = +5V (V+ of the AD), top − rail = GND (the bottom rails are not used)
board: half
parts:
  R1: resistor b5 b11 330
  D1: led c11(A) c13(K) red
  Q1: transistor e12(B) e13(C) e14(E) 2SC1815
  RB: resistor b12 b17 10k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+, 2+, 2-, W1]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t11 black
  - AD.1+ -- a13 orange
  - AD.2+ -- a15 blue
  - e15 -- e17 blue
  - AD.2- -- -t16 black
  - AD.W1 -- a17 yellow
  - +t5 -- a5 red
  - a14 -- -t14 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/01-transistor-switch.svg)

As in Fig. 2, all the parts are plugged into the upper half, and every GND is taken from the top − rail (the bottom rails are not used).
The 5 V goes from V+ (red) of the Analog Discovery to the top + rail.

- **Collector (column 13)**: the cathode of `D1` and C of `Q1` are in the same column. Plug 1+ (orange) of CH1 into `a13`
- **Base (column 12)**: the left end of `RB` (`b12`) is in the same column as B of Q1. No wire is needed
- **Emitter (column 14)**: a black wire goes straight from `a14` to the − rail
- **Input (column 17)**: the right end of `RB` (`b17`). Plug W1 (yellow) into `a17`, and plug 2+ (blue) of CH2 into `a15` and carry it across with `e15`–`e17`
- Connect GND, 1− and 2− (black) of the AD to the top − rail

Looking at the flat face, `Q1` has E, C, B from the left (the real pin order of the 2SC1815). The figure plugs it in as B, C, E,
so insert it **with the flat face toward the back**.

## Viewing on the oscilloscope

Set W1 to a 100 Hz, 0 V / 5 V square wave (to the eye the LED stays lit at half brightness; to see it blink, lower the frequency to 1 Hz), and overlay CH2 (input) and CH1 (collector) at the same 1 V/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Input (CH2) and collector (CH1), 0.2 V while on
time: 2ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 100Hz 1.65V offset 1.85V phase 180deg, range: 1V/div, position: -3div}
ch2: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
measure: [vmax, vmin, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/01-transistor-switch.svg)

CH1 in Fig. 3 is CH2 turned upside down. A switch of this form, with the emitter grounded (common emitter), moves the output opposite to the input. While the input is 5 V, the collector
falls to V<sub>CE(sat)</sub> ≈ **0.2 V**, and (5 − 0.2 − 2.0) / 330 Ω ≈ 8.5 mA flows through the LED.
While the input is 0 V, almost no current flows through the LED, so the collector stays at **about 3.5 V**, which is 5 V minus
about 1.5 V, the drop just before the LED turns on (it does not rise to 5 V).
This 3.5 V is set by the roughly 1 µA that the oscilloscope input (about 1 MΩ) draws through the LED (in LTspice, 3.50 V with a 1 MΩ load).
With nothing connected, the current is even smaller and the LED voltage falls, so the collector rises to about 4.2 V.
Read the two end values with Max and Min in Measurements.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 330 Ω |
| RB | Resistor (1/4 W) | 10 kΩ |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | NPN transistor | 2SC1815 |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| LED current with W1 = 5 V (across R1 ÷ 330 Ω) | about 8.5 mA | If it matches the calculated value, the transistor is operating in saturation |
| C-E voltage of Q1 with W1 = 5 V | about 0.2 V (V<sub>CE(sat)</sub>) | In saturation only a small voltage is left across C-E |
| Collector (CH1) with W1 = 0 V | about 3.5 V | Almost no current flows in the LED, so the voltage drops only by the amount just below V<sub>F</sub> (about 1.5 V) |
| LED with W1 = 0 V | Off | With no base current, no collector current flows either |
| When the base resistor is changed to 100 kΩ | A unit with hFE above 200 (such as the GR rank) stays lit. An O-rank unit (70 to 140) drops out of saturation and goes dim | To pass 8.5 mA with I<sub>B</sub> ≈ 43 µA needs an hFE of 200 (calculated value) |

## Verification with LTspice

`sim/01-transistor-switch.cir` runs a transient analysis of Fig. 1, sweeping W1 = 5 V / 0 V and RB = 10 kΩ / 100 kΩ, and the values were read from it.
Q1 is a substitute model for the 2SC1815 (the same IS, BF, VAF and IKF as `09-rf/sim/agc.cir`; an assumption made from rough guides, not a measurement),
the LED is a model assumed to have V<sub>F</sub> of about 1.5 V (at 1 µA) and about 2.0 V (at 8.5 mA), and CH1 is placed as a 1 MΩ load.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| I<sub>B</sub> (W1 = 5 V, RB = 10 kΩ) | 0.43 mA | 0.428 mA | Match |
| I<sub>C</sub> (LED current) | about 8.5 mA | 8.67 mA | Match |
| V<sub>CE(sat)</sub> | about 0.2 V | 0.14 V | Match (a model value. The text uses the rough guide from the datasheet) |
| Collector with W1 = 0 V (1 MΩ on CH1) | about 3.5 V | 3.43 V | Match |
| RB = 100 kΩ (I<sub>B</sub> ≈ 43 µA, model with hFE = 250) | Stays lit if hFE is above 200 | Stays lit with I<sub>C</sub> 8.4 mA and V<sub>CE</sub> 0.23 V | Match |

With the model's hFE lowered to 100, RB = 100 kΩ cuts I<sub>C</sub> to the 4 mA range and the LED goes dim (the same direction as "an O-rank unit drops out of saturation" in the text).

## Sources

Original work.
