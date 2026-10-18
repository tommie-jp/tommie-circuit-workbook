---
book: circuits
chapter: 5
id: 5-2
title: Series regulator with a zener diode and a transistor
tier: 50
source: 自作
board: BB
era: 古
ja: 108c1cc4b917a86dd5be08b1f162647aba960853
---

# 5-2 Series regulator with a zener diode and a transistor

From a 12 V supply, a zener diode and one transistor make a supply that holds about 4.3 V even when the load current changes.
A circuit that sets the input voltage to a constant output voltage is called a **regulator**. This circuit was the standard in the days before the
3-terminal regulator (IC) used in the next exercise, 5-3, and it lets you follow by eye, part by part, what happens inside such an IC.

A zener diode starts to conduct at a fixed voltage (the zener voltage) when a voltage is applied in the reverse direction (cathode on the + side).
Even if the current through it changes somewhat, the voltage across it stays nearly at the zener voltage. This property is used as a reference voltage.
A transistor in series with the load drops the voltage and keeps the output constant, so this type is called a **series regulator**.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Zener and transistor series regulator (CH1 on Vout)
parts:
  V1: vsource 1,1 1,6 12
  G1: ground 1,6
  Rz: resistor 3,1 3,3 1.2k
  DZ: zener 3,6 3,3 5V1
  Q1: npn 6,3 2SC1815
  RL: resistor 8,4 8,6 220
  M1: voltmeter 10,4 10,6 l=$\mathrm{CH1}$
wires:
  - vin -- 3,1 -- 6,1
  - 6,1 |- Q1.C
  - 3,3 -| Q1.B
  - Q1.E |- 8,4
  - gnd -- 3,6 -- 8,6 -- 10,6
  - 8,4 -- 10,4
points:
  vin: 1,1
  gnd: 1,6
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/circuit/02-zener-series-regulator.svg)

- Rz is the resistor that feeds current to DZ, and DZ (a 5.1 V part) is the reference. The base of Q1 is
  fixed at the voltage across DZ. In this circuit the current through DZ is about 5.8 mA, and the zener voltage at that current is
  about 4.9 V (see "Checking the zener voltage" below)
- Output voltage = zener voltage − V<sub>BE</sub> ≈ 4.9 − 0.6 = 4.3 V. V<sub>BE</sub> is the voltage between base and emitter;
  the emitter sits one diode drop (about 0.6 V) below the base (the same form as the emitter follower in 2-2)
- Q1 passes hFE times the base current (hFE is the DC current gain = collector current ÷ base current)
  from the collector (the V<sub>in</sub> side) to the load. DZ and Rz only have to supply the small base current
- The whole difference between the input (12 V) and the output (4.3 V) becomes heat in Q1. Q1 gets hot
  when the load current is large. This is the weakness of this type, and 3-terminal regulators share it

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Breadboard build (1+ to output column 7, 1− to GND)
board: half
parts:
  Rz: resistor b5 b9 1.2k
  DZ: zener/do35 d13(A) d9(K) 1N5231B
  Q1: transistor f7(E) f8(C) f9(B) 2SC1815
  RL: resistor h7 h13 220
  PSU:
    type: device
    at: top
    label: 12V supply (AC adapter)
    pins: ["+", "-"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Scope)
    pins: [1+, 1-]
wires:
  - PSU.+ -- +t2 red
  - PSU.- -- -t3 black
  - +t5 -- a5 red
  - a13 -- -t13 black
  - e9 -- g9 orange
  - j8 -- +b8 red
  - j13 -- -b13 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
  - AD.1+ -- i7 orange
  - AD.1- -- -b20 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/breadboard/02-zener-series-regulator.svg)

- Insert the zener (DZ) with the striped side (cathode) in column 9 and the anode in column 13.
  The anode goes from a13 to the − rail, and the cathode connects to Rz and the base
- Insert Q1 with E, C and B in columns 7, 8 and 9. The collector (column 8) goes directly from j8 to the bottom + rail (+12 V), and
  the base (column 9) connects to the junction of DZ and Rz with the wire from e9 to g9. The emitter (column 7) is the output, and
  RL (220 Ω, columns 7 to 13) is the load. Column 13 goes down to the − rail from j13
- The 12 V comes from an AC adapter (or a bench power supply). Supplies of the Analog Discovery gives +5 V with up to 50 mA per rail (250 mW on USB power),
  so it cannot give 12 V. The AD3 is used only as an instrument to watch the output (1+ on output column 7, `i7`, and 1− on the GND − rail, `-b20`)
- The upper and lower rails are joined at the right end (+ at column 29, − at column 30)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| Rz | Resistor (zener current) | 1.2 kΩ |
| DZ | Zener diode (0.5 W) | 5.1 V (such as 1N5231B; a part rated 5.1 V at 20 mA) |
| Q1 | NPN transistor | 2SC1815 |
| RL | Resistor (load, equivalent to an output current of 19.5 mA) | 220 Ω |
| — | Instruments | Scope of the Analog Discovery 3 (1+ = output, 1− = GND), used as a voltmeter that reads DC voltage |
| — | Input supply | 12 V (AC adapter; Supplies of the AD3 gives only up to 5 V, so it is not used). A regulator throws away the difference between input and output as heat in Q1, so the input must be higher than the output (about 4.3 V) |

## Instrument settings

The instrument is the Scope of the Analog Discovery 3 (1+ = output, 1− = GND) or a multimeter. This exercise looks only at DC voltage and current, so
no oscilloscope waveform figure is given (nothing changes with time, and the numeric readings are enough). Set the Scope to DC coupling and 1 V/div and read the output voltage.

## Values to check

The values in the table are calculated values. Take hFE ≈ 150 (a typical value for the 2SC1815). Measure voltages on the DC voltage range of a multimeter, with the − probe on GND (the − rail).
Get the output current by dividing the measured output voltage by 220 Ω.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Across DZ (base voltage) | about 4.9 V | The zener voltage at 5.8 mA (a rough guide; see the check below) |
| Output voltage (emitter, across RL) | about 4.3 V | 4.9 V − V<sub>BE</sub> (0.6 V) |
| Output current (RL = 220 Ω) | about 19.5 mA | 4.3 V ÷ 220 Ω |
| Zener current | about 5.8 mA | (current through Rz 5.9 mA, (12 − 4.9) / 1.2 kΩ) − (base current about 0.13 mA, 19.5 mA ÷ 150) |
| Dissipation of DZ | about 28 mW | 4.9 V × 5.8 mA. Less than 1/10 of the 0.5 W rating |
| Dissipation of Q1 | about 150 mW | (12 V − 4.3 V) × 19.5 mA. Within the 400 mW of the 2SC1815 |

**Checking the zener voltage**: the voltage in a zener diode's part number is the value measured at a fixed test current I<sub>ZT</sub>.
In the Vishay datasheet for the 1N5221 to 1N5267, the 1N5231B has V<sub>Z</sub> = 5.1 V at I<sub>ZT</sub> = 20 mA
(B means ±5 %, 4.85 to 5.36 V), and its dynamic resistance Z<sub>ZT</sub> there is at most 17 Ω. At a current below 20 mA
the voltage drops a little. Estimating the drop with Z<sub>ZT</sub>:

- Formula: V<sub>Z</sub>(5.8 mA) ≈ V<sub>Z</sub>(20 mA) − Z<sub>ZT</sub> × (20 mA − 5.8 mA)
- Substitution: 5.1 V − 17 Ω × 14.2 mA = 5.1 V − 0.24 V
- Result: about 4.86 V → about 4.9 V

The curve in the datasheet (Fig. 7) is not fine enough to read this difference, so this is a rough guide. It is about as large as the part-to-part spread of ±5 % (±0.26 V),
so after building the circuit, measure across DZ and recalculate the values in the table from that measurement.
A 1 W part (such as the 1N4733A) has a large I<sub>ZT</sub> of 49 mA, and at 5.8 mA its voltage drops even more, so use a 0.5 W part in this circuit.

Even if you vary the supply between 9 and 12 V, the output stays at about 4.3 V (as long as the zener holds the reference).
If V<sub>in</sub> falls to 6 V or less, the current through Rz, (V<sub>in</sub> − 4.9 V) / 1.2 kΩ, drops below 1 mA,
almost all of it is taken by the base current, and no current flows in the zener. The reference can then no longer be held and the output starts to fall.
When the output can no longer be held because the input has fallen, this is called **dropout**.

## Verification with LTspice

In LTspice (input 12 V, DZ a model matched to 5.1 V at 20 mA and 17 Ω dynamic resistance, Q1 an approximate model of the 2SC1815; not measured),
the voltage across DZ is 4.84 V and the DZ current is 5.9 mA, which agree with the calculation above (4.9 V, 5.8 mA). The output is 4.11 V and the output current 18.7 mA, a little lower than the 4.3 V and 19.5 mA in the table.
The table took V<sub>BE</sub> as 0.6 V, but at 19 mA the V<sub>BE</sub> of Q1 is 0.73 V in the model. A real output falls between 4.1 and 4.3 V.
With a 9 V input the output is 4.05 V, and even at 6 V it is 3.98 V, so lowering the input by 6 V moves the output by only 0.13 V.
The zener current falls to 1.0 mA at 6 V, which agrees with the estimate above (0.9 mA) (the deck is `sim/02-zener-series-regulator.cir`).

## Sources

Original work.
