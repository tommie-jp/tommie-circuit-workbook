---
book: circuits
chapter: 2
id: 2-5
title: MOSFET Switch (2N7000, Logic Level)
tier: 50
source: 自作
era: 今
board: BB
ja: 51e7779fe4cd827733476dabe1c2ad4e8f3cf261
---

# 2-5 MOSFET Switch (2N7000, Logic Level)

A MOSFET is a switch that turns on and off just by applying a voltage to the gate. It has three pins, called the gate (G),
drain (D) and source (S). They correspond to the base, collector and emitter of the BJT (the bipolar transistor used in 2-1 to 2-4).
When a voltage is applied between gate and source, current flows from drain to source, and almost no current
flows into the gate (no base current as in a BJT is needed).

The 2N7000 is a **logic-level** MOSFET: one that can be turned on fully just by applying the logic circuit voltage (5 V)
to the gate. The advantage is that it can be driven directly from a microcontroller output. With a 3.3 V
microcontroller, however, some units turn on only weakly (because the maximum threshold is 3 V; see the calculation below).
In this exercise you switch the gate between 0 V and 5 V with a switch to light an LED, and compare with the BJT switch of 2-1.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Switching with a 2N7000 (CH2 gate, CH1 drain)
parts:
  VCC: vcc 4,2 5V
  R1: resistor 7,2 7,4 330
  D1: led 7,4 7,5
  Q1: nmos-e 7,5.8
  SW: switch 4,2 4,4
  RG: resistor 4,4 4,6 220
  RPD: resistor 4,6 4,8 100k
  G2: ground 4,8
  G3: ground 7,7
  M2: voltmeter 2,6 2,8 l=$\mathrm{CH2}$
  G4: ground 2,8
  M1: voltmeter 10,5 10,7 l=$\mathrm{CH1}$
  G5: ground 10,7
wires:
  - 4,2 -- 7,2
  - 2,6 -- 4,6
  - 7,5 -- 10,5
  - 7,5 -- Q1.D
  - 4,6 |- Q1.G
  - Q1.S -- 7,7
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/05-mosfet-switch.svg)

The +5 V in Fig. 1 is the supply output V+ of the Analog Discovery (set it to 5 V in Supplies in WaveForms).
The only current drawn is the LED's roughly 9 mA, so V+ is enough. CH2 measures the gate voltage and CH1 the drain voltage, both from GND.

When `SW` is closed, 5 V is applied to the gate, the MOSFET turns on and the LED lights.
`RPD` (100 kΩ, pull-down) pulls the gate firmly down to 0 V when `SW` is open.
`RG` (220 Ω) is a protection resistor that limits the current at the moment the gate charges.

- The threshold voltage V<sub>GS(th)</sub> of the 2N7000 (the gate-source voltage at which drain current starts to flow) is
  0.8 V minimum, 2.1 V typical and 3 V maximum (under the condition V<sub>DS</sub> = V<sub>GS</sub>, I<sub>D</sub> = 1 mA; the specification of onsemi NDS7002A/D Rev.11). With 5 V applied it is more than 2 V above the maximum of 3 V, so it turns on reliably
- The on-resistance R<sub>DS(on)</sub> is a few ohms at V<sub>GS</sub> = 5 V (small enough)
- LED current: I = (5 − V<sub>F</sub>) / R1 ≈ (5 − 2.0) / 330 ≈ **9.1 mA**
  (the voltage drop of a few tens of mV across R<sub>DS(on)</sub> is small enough to ignore)
- The current into the gate is **almost 0** (a MOSFET is voltage-driven). Even with `RG`
  there is almost no voltage drop in the steady state

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Switching with a 2N7000
# 5V goes from V+ of the AD to the top + rail; GND to the top − rail (the bottom rails are not used)
board: half
parts:
  R1: resistor b5 b8 330
  D1: led c8(A) c9(K) red
  Q1: transistor e13(D) e14(G) e15(S) 2N7000
  RG: resistor b21 b14 220
  RPD: resistor a14 -t14 100k
  SW: button @ e17
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a9 orange
  - AD.1- -- -t10 black
  - AD.2- -- -t19 black
  - AD.2+ -- a16 blue
  - d16 -- d14 blue
  - +t5 -- a5 red
  - b9 -- b13 orange
  - +t17 -- a17 red
  - g19 -- c21 orange
  - a15 -- -t15 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/05-mosfet-switch.svg)

As in Fig. 2, the 5 V goes from V+ (red) of the Analog Discovery to `+t1` of the top + rail, and GND (black) to `-t2`.

- **Q1 goes into row e of the upper block, rotated 180 degrees** (`e13` D, `e14` G, `e15` S).
  The 2N7000, **viewed from the flat face, is S, G, D from the left** (the order differs from the 2SC1815, so be careful), so
  after rotating it is D, G, S from the left and the wires do not overlap
  Note: **verify on the real part. The 2007 edition of the onsemi drawing says S G D and the 2022 edition of the table says D G S, which disagree; this text follows the 2007 edition (S G D). Check the real part with a multimeter**
- **Drain (column 13)**: an orange wire `b9`–`b13` from the LED cathode (column 9). Plug 1+ of CH1 (orange) into `a9`
- **Gate (column 14)**: the left end of `RG` (`b14`) and `RPD`, inserted vertically to the − rail (`a14`), are in the same column.
  Plug 2+ of CH2 (blue) into `a16` and carry it over to the gate column with the blue wire `d16`–`d14`
- **Source (column 15)**: from `a15` to the top − rail (black)
- **Switch**: the upper pin (column 17) goes to +5 V with a red wire, and the lower pin (`g19`) goes to the right end of `RG` (`c21`) with an orange wire
- 1− and 2− (black) go to the top − rail (`-t10`, `-t19`). The bottom rails are not used

## Viewing on the oscilloscope

Trigger on the rising edge of CH2 (gate) at 2.5 V (Normal) and press SW. This freezes a single event at
the moment of the press on the screen. The gate rises in about 10 ns through RG (220 Ω) and the input capacitance of the 2N7000 (a few tens of pF),
and the drain falls where V<sub>GS</sub> passes the threshold (Fig. 3).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 SW pressed, gate (CH2) rises, drain (CH1) falls
time: 20ns/div
trigger: ch2 rising 2.5V
ch1: {wave: "= 3.5V - 3.47V * step(t + 3ns) * (1 - exp(-(t + 3ns) / 8ns))", range: 1V/div, position: -3div}
ch2: {wave: "= 5V * step(t + 10ns) * (1 - exp(-(t + 10ns) / 15ns))", range: 1V/div, position: -3div}
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/05-mosfet-switch.svg)

- CH2 rises from 0 V to about 5 V (the voltage drop across RG is almost 0)
- CH1 is about 3.5 V before the press. Through the off MOSFET and the input resistance of CH1 (1 MΩ), only about a µA
  flows in the LED, and about 1.5 V remains across the LED, so CH1 does not reach 5 V. When pressed it drops to about 0.03 V (a few tens of mV)
- A tactile switch opens and closes several times from chattering (contact bounce), but the trigger
  stops at the first rising edge, so the screen shows that single event. Widen the time base to about 1 ms/div to see the bounce

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 330 Ω |
| RG | Resistor (1/4 W) | 220 Ω |
| RPD | Resistor (1/4 W) | 100 kΩ |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | Logic-level N-MOSFET | 2N7000 |
| SW | Tactile switch | — |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Gate voltage (CH2) with SW not pressed | 0 V | RPD pulls the gate to GND |
| Drain voltage (CH1) with SW not pressed | about 3.5 V | Only µA flows in the LED, and V<sub>F</sub> of about 1.5 V remains |
| Gate voltage (CH2) with SW pressed | about 5 V | The voltage drop across RG is almost 0 (there is no gate current) |
| LED current with SW pressed | about 9.1 mA | As calculated. Almost the same current as the BJT switch (2-1) |
| D-S voltage of Q1 (CH1) with SW pressed | a few tens of mV (about 0.03 V) | R<sub>DS(on)</sub> is small, so this is even smaller than the BJT saturation voltage (0.2 V) |

## Verification with LTspice

`sim/05-mosfet-switch.cir` runs a transient analysis of Fig. 1, sweeping the gate voltage (0 V / 3.3 V / 5 V) and the threshold V<sub>GS(th)</sub> (1 V / 2.1 V / 3 V).
The 2N7000 is a substitute model using SPICE's standard level 1 (an assumption that sets the on-resistance to about 3.4 Ω at V<sub>GS</sub> = 5 V and a threshold of 2.1 V; not a measurement).
The LED is an assumed model whose V<sub>F</sub> is about 1.5 V (1 µA) and about 2.0 V (8.5 mA), and CH1 is placed as a 1 MΩ load.
The gate rise time (a few tens of ns) is a value based on an assumed input capacitance and was not run here (not applicable).

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| LED current with SW pressed (V<sub>GS</sub> = 5 V, threshold 2.1 V) | about 9.1 mA | 9.0 mA | Match |
| D-S voltage with SW pressed | about 0.03 V | 0.031 V | Match (a value from the assumed on-resistance) |
| Drain (CH1) with SW open | about 3.5 V | 3.43 V | Match |
| LED current with 5 V applied to a unit with the maximum threshold of 3 V | Turns on reliably | 8.9 mA (D-S 0.045 V) | Match |
| LED current with 3.3 V applied to a unit with a threshold of 3 V | Turns on only weakly | 4.4 mA (D-S 1.6 V) | Match (the LED lights at only about half brightness) |
| LED current with 3.3 V applied to a unit with a threshold of 2.1 V | — | 8.8 mA (D-S 0.08 V) | A typical unit lights even at 3.3 V |

## Sources

Original work.

See also: [MOSFET (Wikipedia)](https://ja.wikipedia.org/wiki/MOSFET), [2N7000 / BS170 datasheet (Vishay, 70226)](https://www.vishay.com/docs/70226/70226.pdf)
