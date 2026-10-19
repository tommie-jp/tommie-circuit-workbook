---
book: circuits
chapter: 8
id: 8-2
title: A temperature alarm with a thermistor
tier: 50
source: 自作
board: BB
ja: b36782d2cbf840aca2e0f3cae62743e96c621b4b
---

# 8-2 A temperature alarm with a thermistor

This exercise builds a temperature alarm that sounds a buzzer when the temperature rises above about 40 °C.
An NTC thermistor is an element whose resistance falls as the temperature rises. The same voltage-divider idea as for
the CdS cell (8-1) turns temperature into a voltage, but with one transistor stage as in 8-1 the change-over is too
gradual. So the circuit uses two transistor stages (a Darlington connection, seen in 2-4) to raise the gain, and
the buzzer sounds clearly once the set temperature is exceeded.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 The buzzer sounds when the thermistor warms up
parts:
  VCC: vcc 2,2 5V
  TH1: thermistor-ntc 2,2 2,4 10k l=$\mathrm{TH1}$
  R1: resistor 2,4 2,6 2.2k
  G1: ground 2,6
  Q1: npn 4,4 2SC1815
  R2: resistor 4,6 4,8 100k
  G2: ground 4,8
  Q2: npn 6,6 2SC1815
  BZ1: buzzer 6,2 6,4 l=$\mathrm{BZ1}$
  G3: ground 6,8
wires:
  - 2,2 -- 4,2 -- 6,2
  - 4,2 -- Q1.C
  - 2,4 -- Q1.B
  - Q1.E -- 4,6 -- Q2.B
  - 6,4 -- Q2.C
  - Q2.E -- 6,8
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/02-thermistor-alarm.svg)

- The midpoint of the divider of TH1 (NTC, top) and R1 (fixed, 2.2 kΩ, bottom) connects to the base of Q1.
  When the temperature rises, the resistance of TH1 falls and the midpoint voltage rises
  (the same idea as the CdS cell in 8-1, only with top and bottom swapped)
- Q1 and Q2 are in a Darlington connection (the emitter of Q1 is the base of Q2). R2 (100 kΩ) is a bleeder resistor
  (a resistor that drains the leakage current of Q1 to GND): it pulls the base of Q2 lightly to GND so that Q2 is
  reliably OFF when Q1 is OFF
- The combined gain of the two stages is h<sub>FE1</sub> × h<sub>FE2</sub>, which is very large. So when the midpoint of
  the divider exceeds two base-emitter voltages (about 1.4 V) by only a little, Q2 saturates at once and the buzzer
  switches clearly ON and OFF

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5V, blue rail = GND (carried to the lower rails at columns 40 and 41)
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  TH1: thermistor-ntc b3 b6 10k
  R1: resistor b10 b13 2.2k
  Q1: transistor c17(B) c18(C) c19(E) 2SC1815
  R2: resistor b23 b26 100k
  Q2: transistor c30(B) c31(C) c32(E) 2SC1815
  BZ1: buzzer h34(+) h31
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - +t18 -- a18 red
  - -t13 -- a13 black
  - -t26 -- a26 black
  - -t32 -- a32 black
  - a6 -- a10 green
  - d10 -- d17 green
  - a19 -- a23 yellow
  - e23 -- e30 yellow
  - e31 -- f31 orange
  - j34 -- +b34 red
  - +t40 -- +b40 red
  - -t41 -- -b41 black
notes:
  - text: Warm TH1 with fingers or a hair dryer and the buzzer sounds
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/02-thermistor-alarm.svg)

- Connect V+ (+5 V) and GND of the AD3 to the upper rails. Only the buzzer sits in the lower block, so the rails are
  carried to the lower rails at columns 40 and 41
- The divider of TH1 (NTC thermistor, columns 3 to 6) and R1 (columns 10 to 13) is joined by a green wire (a6 to a10).
  From the midpoint (column 10) a green wire (d10 to d17) goes to the base of Q1.
  TH1 is a disc-shaped part with the same shape as a PTC thermistor, so tell them apart by the marking and by the
  label on the parts bag
- Q1 and Q2 (2SC1815) read E, C, B from the left when you face the flat side. Here they are inserted with the flat
  side facing the back (the a-row side), and B, C, E go into row c in that order.
  The collector of Q1 (column 18) goes to the + rail and the emitter of Q2 (column 32) goes to the − rail
- From the emitter of Q1 (column 19), a yellow wire goes to R2 (columns 23 to 26) and to the base of Q2 (column 30).
  This is the Darlington connection
- The collector of Q2 (column 31) goes by an orange wire to the lower block and to the − pin of the buzzer.
  The buzzer (active type) has polarity, and its + pin (column 34, the longer pin) goes to the lower + rail

## Instrument settings

The instruments are Supplies (the power supply) of the Analog Discovery 3 and a multimeter. Set V+ of the AD3 to 5 V
and turn the output on. The current drawn is from a few mA up to around 30 mA for the buzzer (it depends on the part;
check the rating of the real part), and under 1 mA for the divider and the base of Q1, within the roughly 50 mA of one
supply channel of the AD3. The current through one hole of the breadboard is also 200 mA or less, within the range of
the breadboard.

This exercise has no oscilloscope figure. What you look at is a DC voltage that changes slowly with temperature, not
a waveform that changes with time. The multimeter readings are enough.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| TH1 | NTC thermistor | 10 kΩ at 25 °C, B constant 3950 |
| R1 | Resistor | 2.2 kΩ |
| Q1, Q2 | NPN transistor | 2SC1815 |
| R2 | Resistor (bleeder) | 100 kΩ |
| BZ1 | Buzzer (active type, meaning it has a built-in oscillator circuit and sounds just by applying a voltage; 5 V) | — |
| — | Power supply | 5 V (V+ of Supplies on the AD3) |

## Values to check

The values in the table are calculated values. The resistance of TH1 comes from R(T) = 10 kΩ × exp{3950 × (1/T − 1/298.15)}
(T is the absolute temperature in K = °C + 273.15; 3950 is the B constant in the parts list), and the midpoint of the
divider comes from 5 V × 2.2 kΩ / (2.2 kΩ + R(T)).
The Darlington is taken to be ON when the midpoint of the divider exceeds about 1.4 V (two V<sub>BE</sub>). In practice,
V<sub>BE</sub> is only about 0.6 V while the current is small, so the buzzer starts to sound from about 1.2 V (32–35 °C)
(see the LTspice section below).

Example: at 40 °C (313.15 K), R = 10 kΩ × exp{3950 × (1/313.15 − 1/298.15)} ≈ 5.3 kΩ, and the midpoint is
5 × 2.2 / (2.2 + 5.3) ≈ 1.47 V.
Measure the midpoint voltage between column 10 and GND on the multimeter's DC voltage range.

| Temperature | Resistance of TH1 (calculated) | Midpoint of the divider | Buzzer |
| --- | --- | --- | --- |
| 25 °C (room temperature) | 10.0 kΩ | 0.90 V | OFF |
| 35 °C | 6.5 kΩ | 1.26 V | Starts to sound (about 9 mA in the model of Q1 and Q2; the threshold moves a few °C between parts) |
| 38 °C | 5.7 kΩ | 1.38 V | ON (about 40 mA) |
| 40 °C | 5.3 kΩ | 1.47 V | ON |
| 50 °C | 3.6 kΩ | 1.90 V | ON (firmly) |

The temperature of a pinching finger (about 32–35 °C at the surface) is a little below the switching point in the
calculation. Even so, V<sub>BE</sub> is lower than 0.7 V when the current is small, so the buzzer may start to sound. If it
does not, warm the part with warm air from a hair dryer.
To raise the temperature at which it sounds, make R1 smaller; to lower it, make R1 larger.

## Verification with LTspice

`sim/02-thermistor-alarm.cir` puts the B-constant formula into the resistance of TH1, sweeps the temperature, and
solves Fig. 1 in DC. Q1 and Q2 are substitute models for the 2SC1815 (h<sub>FE</sub> 250), and the buzzer is assumed to
be a 100 Ω resistor (this is not the current of a real buzzer).

| Temperature | TH1 (text) | TH1 (LTspice) | Midpoint (text, value without Q) | Midpoint (LTspice, with Q1) | Buzzer current (LTspice) | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 25 °C | 10.0 kΩ | 10.0 kΩ | 0.90 V | 0.90 V | 0.15 µA | agrees |
| 35 °C | 6.5 kΩ | 6.5 kΩ | 1.26 V | 1.26 V | 9.5 mA | agrees (the text was corrected to "starts to sound") |
| 38 °C | 5.7 kΩ | 5.7 kΩ | 1.38 V | 1.38 V | 40 mA | agrees (ON) |
| 40 °C | 5.3 kΩ | 5.3 kΩ | 1.47 V | 1.46 V | 46 mA | agrees |
| 50 °C | 3.6 kΩ | 3.6 kΩ | 1.90 V | 1.84 V (the base of Q1 loads the divider) | 47 mA | agrees |

The Darlington starts to conduct from about 1.2 V, lower than the "midpoint 1.4 V" in the text (0.8 mA at 30 °C, 2 mA
at 33 °C, 9.5 mA at 35 °C), and is fully ON at 38 °C. Changing h<sub>FE</sub> to 100 moves this by only about 1 °C.

## Sources

Original work.

See also: [Thermistor (Wikipedia, Japanese)](https://ja.wikipedia.org/wiki/サーミスタ), [Thermistor (Wikipedia)](https://en.wikipedia.org/wiki/Thermistor)
