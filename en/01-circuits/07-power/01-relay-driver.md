---
book: circuits
chapter: 7
id: 7-1
title: Relay Driver — Transistor and Flyback Diode
tier: 50
source: 自作
board: BB
ja: c880e2446a5474a7d63322c5a067105bfeeed1f0
---

# 7-1 Relay Driver — Transistor and Flyback Diode

A relay is a part in which current through a coil makes an electromagnet pull a contact, switching a separate circuit
on and off. A small signal can then drive a motor or a high-current appliance.
A relay coil draws too much current for a microcontroller GPIO (a pin used for signals, which can supply only a few mA)
to drive it directly. So a transistor (the switch from 2-1) drives the coil, and a **flyback diode** placed in parallel
with the coil protects the transistor from the back EMF (seen in 6-2) at the moment the coil is switched off.
In 6-2 the back EMF lit an LED; here a diode absorbs it and cancels it.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Relay driver (CH1 is IN, CH2 is collector)
parts:
  VCC: vcc 5,2 5V
  D1:  diode 3,6 3,3 1N4148
  K1:  relay 5.88,5 r180 mirror G5V-2
  Q1:  npn 5,8
  R1:  resistor 2,8 4,8 1k
  IN:  port 2,8
  G1:  ground 5,9
  R2:  resistor 7,7 9,7 330
  D2:  led 9,7 11,7
  G2:  ground 11,8
  M1:  voltmeter 2,9 2,11 l=$\mathrm{CH1}$
  G3:  ground 2,11
  M2:  voltmeter 1,6 1,9 l=$\mathrm{CH2}$
  G4:  ground 1,9
wires:
  - 5,2 -- 5,3 -- 3,3
  - K1.A2 |- 5,3
  - K1.A1 |- 5,6
  - 3,6 -- 5,6 -- Q1.C
  - 4,8 -- Q1.B
  - Q1.E -- 5,9
  - K1.COM1 |- 5,3
  - K1.NO1 |- 7,7
  - 11,7 -- 11,8
  - 2,8 -- 2,9
  - 3,6 -- 1,6
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/circuit/01-relay-driver.svg)

- When IN (a GPIO, for example) goes High (5 V here), base current flows through R1 (1 kΩ).
  Q1 saturates (fully ON, as in 2-1), current flows in the coil (A1–A2 of K1), and the relay pulls its contact
- D1 sits in parallel with the coil, with its cathode on the supply side. While current flows in the coil, D1 sees only
  a reverse voltage and carries no current. Only at the moment Q1 turns off, D1 absorbs the back EMF of the coil and
  keeps a high voltage from appearing on the collector of Q1 (the same principle as 6-2)
- The contact (COM1, NO1) is a circuit separate from the coil. COM is the common terminal. NO (Normally Open) is
  open normally and connects to COM when the relay pulls. Here COM1 is tied to the same 5 V, and NO1 lights an LED (D2)
  through R2.
  In practice a relay is used to switch a load with a higher voltage or current on the contact side (a motor, a
  100 V AC appliance, and so on). This book does not connect 100 V AC

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Driving the relay (W1 = IN, 1+ = IN, 2+ = collector)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 5 V supply (AC adapter etc.)
    pins: ["+", "-"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (W1 and Scope)
    pins: [W1, 1+, 1-, 2+, 2-, GND]
  K1: relay @ f10
  Q1: transistor i4(E) i5(C) i6(B) 2SC1815
  R1: resistor f1 f6 1k
  D1: diode i10(A) i13(K) 1N4148
  R2: resistor g17 g21 330
  D2: led h21(A) h22(K) red
wires:
  - PSU.+ -- +t2 red
  - PSU.- -- -t3 black
  - +t10 -- a10 red
  - g5 -- g10 yellow
  - j4 -- -b4 black
  - AD.W1 -- j1 orange
  - AD.1+ -- i1 blue
  - AD.2+ -- j5 green
  - AD.1- -- -b7 black
  - AD.2- -- -b9 black
  - AD.GND -- -b11 black
  - g13 -- +b13 red
  - j22 -- -b22 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
notes:
  - text: The orange wire (column 1) is IN. When W1 is at 5 V, Q1 turns on, the relay pulls, and the LED lights
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/breadboard/01-relay-driver.svg)

- Place the relay with the left edge of its body at column 10, straddling the center gap. The pins are numbered as seen
  from above with the relay's notch on the left (pin 1, `A1`, is at the lower left, f10)
- Q1 (2SC1815) reads E, C, B from the left when you face the flat side. Insert it in columns 4, 5 and 6 of row i with
  the flat side toward you (the j-row side). A yellow wire joins the collector (column 5) from g5 to column 10 (`A1` of the coil)
- D1 (the flyback diode) has its anode in column 10, the same column as `A1` of the coil (the collector side of Q1),
  and its cathode in column 13 (the same column as `COM1`, which g13 connects to the + rail).
  That puts it in parallel with the coil and in the reverse direction (`A2` of the coil goes from the upper block of
  column 10 to the + rail)
- Use a separate 5 V supply (a 5 V AC adapter or a bench power supply). The coil draws about 100 mA and the LED about 9 mA,
  which exceeds the 50 mA per rail of Supplies on the Analog Discovery (250 mW on USB power), so the AD3 is used only for
  the signal (W1) and the oscilloscope (Scope)
- Feed IN (column 1) from W1 of the AD (orange). 1+ (blue) is in the same column 1 (`i1`) and reads IN, and 2+ (green)
  is on column 5 (`j5`), the collector of Q1. 1−, 2− and GND (black) go to the lower − rail. W1 outputs up to about 0 Ω
  and 30 mA, so the base current of about 4.3 mA is well within its reach
- Leave the unused second circuit (`COM2`, `NC2`, `NO2`) empty

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| K1 | Relay (Omron G5V-2, 5 V) | Coil resistance 50 Ω, rated coil current 100 mA |
| Q1 | NPN transistor | 2SC1815 |
| R1 | Resistor | 1 kΩ |
| D1 | Small-signal diode (for flyback) | 1N4148 |
| R2 | Resistor | 330 Ω |
| D2 | LED (red) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | A 5 V AC adapter or bench power supply (the load of about 110 mA exceeds the 50 mA of Supplies on the AD3) |
| — | Instruments and input | W1 of the Analog Discovery 3 (IN, a 0 V / 5 V square wave) and Scope (1+ = IN, 2+ = collector, 1− and 2− = GND) |

## Instrument settings

The instruments are W1 of the Analog Discovery 3 (the 0 V / 5 V square wave fed to IN) and Scope. The relay switching
shows at the transitions of the waveform, so set W1 to 10 Hz and overlay CH1 (IN) and CH2 (collector) at the same
1 V/div. In WaveForms, set W1 to Simple, Square, Amplitude 2.5 V, Offset 2.5 V.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 IN (CH1) vs. collector (CH2), inverted
time: 20ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 10Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: square 10Hz 2.35V offset 2.65V phase 180deg, range: 1V/div, position: -3div}
measure: [vmax, vmin, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/07-power/scope/01-relay-driver.svg)

Fig. 3 shows the ideal shape. CH2 moves opposite to CH1, between 5 V (Q1 off, so the coil end sits at 5 V) and 0.3 V
(saturated; the SPICE value below). In a real circuit, at the moment Q1 turns off, the back EMF of the coil turns D1
on and the collector rises briefly to about 5.8 V (= 5 V + the forward voltage of D1, about 0.8 V; SPICE).
Without D1 this spike could reach tens of volts (this book does not remove it to try). The width of the spike is set by
the inductance of the coil. The value for this relay has not been checked, so Fig. 3 does not draw it. The click of
the LED and the relay lasts only while CH1 is at 5 V.

## Values to check

The values in the table are calculated values. They assume h<sub>FE</sub> ≥ 70 for the 2SC1815 (the lower limit of
rank O) and, for the 5 V version of the G5V-2, a coil resistance of 50 Ω and a rated coil current of 100 mA
(values from the Omron datasheet).
Measure voltages on the multimeter's DC voltage range with the − probe on GND. Measure the coil current by putting
the multimeter's current (mA) range in series between the + rail and `A2` of the coil.
When the relay pulls, it clicks and the LED (D2) lights.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Base current (IN = 5 V) | about 4.3 mA (= (5 − 0.7) / 1 kΩ) | Set by R1 |
| Minimum base current needed to saturate | about 1.4 mA (= 100 mA / 70) | 4.3 mA is well above this, so Q1 saturates for certain |
| Coil current (relay pulled) | about 100 mA (= 5 V / 50 Ω) | As rated in the datasheet |
| Collector-emitter voltage of Q1 (saturated) | 0.3 V or less (SPICE value; the datasheet gives a maximum V<sub>CE(sat)</sub> of 0.25 V at I<sub>B</sub> = 10 mA) | Almost the full supply voltage falls across the coil |
| The moment current flows in D1 | Only just after Q1 turns OFF | Otherwise D1 sees only a reverse voltage and carries no current |
| With D1 removed | A brief high voltage appears across the collector and emitter of Q1 (it may be destroyed) | Why the flyback diode is needed. **This book does not remove it to try** |

## Verification with LTspice

In LTspice, Q1 is an approximate 2SC1815 model with R<sub>C</sub> set to 1 Ω so that the saturation voltage falls in the
0.1–0.25 V range, and the coil is assumed to be 50 Ω and 100 mH (not measured). While IN = 5 V, the base current is
4.0 mA, the collector-emitter voltage of Q1 is 0.29 V, and the coil current is 94 mA (= (5 − 0.29) V / 50 Ω).
The base current is lower than the 4.3 mA in the table because, at saturation, V<sub>BE</sub> is about 1.0 V rather than
0.7 V (it includes the base and emitter resistance).
The collector spike at turn-off is 5.84 V (about 90 mA flows in D1, and its forward voltage is 0.84 V).
The deck is `sim/01-relay-driver.cir`.

## Sources

Original work.
