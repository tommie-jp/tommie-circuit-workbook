---
book: circuits
chapter: 6
id: 6-1
title: Transformer basics — step-up, step-down and isolation with low-voltage AC
tier: 50
source: 自作
board: BB
ja: 75d7c5c45c2302071d4faa6df3ecf10900145e75
---

# 6-1 Transformer basics — step-up, step-down and isolation with low-voltage AC

Check that a transformer raises 6 V AC to 12 V, and that connected the other way round it lowers 12 V to 6 V.
A transformer is a part in which two windings are linked by an iron core. The side connected to the supply is called the
**primary** and the side that delivers the voltage is called the **secondary**. It raises or lowers the voltage in
proportion to the **turns ratio** (the ratio of the number of turns of the primary and secondary windings), while
electrically separating (isolating) the primary side from the secondary side. It is also inside the AC adapter of 5-1,
and it is a basic part of power supplies.

A transformer works only on AC, so instead of the default 5 V DC of this book, the output of a 6 V AC adapter is used as
the primary supply (never connect it directly to the mains). 6 V was chosen so that the secondary side also stays within
12 V, a range you can handle on a breadboard.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Step-up transformer (CH1 primary, CH2 secondary)
parts:
  V1: sine 2,2 2,4 8.5
  M1: voltmeter 5,2 5,4 l=$\mathrm{CH1}$
  T1: transformer 8,3 6V/12V
  R1: resistor 12,2 12,4 1k
  M2: voltmeter 15,2 15,4 l=$\mathrm{CH2}$
  G1: ground 2,4
wires:
  - 2,2 -- 5,2
  - 5,2 -| T1.A1
  - 2,4 -- 5,4
  - 5,4 -| T1.A2
  - 12,2 |- T1.B1
  - 12,4 |- T1.B2
  - 12,2 -- 15,2
  - 12,4 -- 15,4
style:
  grid: on
  pitch: 0.9
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/circuit/01-transformer-basics.svg)

- V1 is the output of the AC adapter (6 V RMS, 50/60 Hz). The 8.5 V in Fig. 1 is written as the amplitude (V<sub>p</sub> = 6 × √2).
  T1 is a small transformer with a 6 V primary and a 12 V secondary (for example, a board-mount transformer with
  6 V + 6 V windings, with the secondary windings connected in series to make 12 V)
- Driving the primary at 6 V gives, from the turns ratio of 1:2, 12 V on the secondary (V<sub>p</sub> about 17 V)
- R1 (1 kΩ) is the load on the secondary side. If you only use a voltmeter (multimeter) you can leave it out, but R1 lets
  you check that the voltage still follows the turns ratio under load

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Transformer and adapter (CH1 in, CH2 out)
# The four pins of the transformer plug straight into breadboard holes. The rails are not used
board: half
parts:
  ADP:
    type: device
    at: top
    label: AC adapter 6V
    pins: [OUT1, OUT2]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Scope)
    pins: [1+, 1-, GND, 2+, 2-]
  T1: transformer a5(A1) a8(A2) a13(B1) a16(B2)
  R1: resistor c13 c16 1k
wires:
  - ADP.OUT1 -- b5 yellow
  - ADP.OUT2 -- b8 orange
  - AD.1+ -- d5 blue
  - AD.1- -- e8 black [h1]
  - AD.2+ -- d13 green
  - AD.2- -- d16 black
  - AD.GND -- d8 black [h-30]
notes:
  - text: Primary to adapter (columns 5–8), R1 on secondary (13–16)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/breadboard/01-transformer-basics.svg)

- The four pins of the transformer are the ends of the real windings, so the hole you plug into is the pin itself
  (the figure adds the names to the holes: `a5` is `A1`, `a8` is `A2`, and so on). R1 is placed in columns 13 and 16 and
  connects to the secondary winding through the continuity of the same columns
- Drive it from the adapter (the 6 V AC adapter). The Wavegen of the AD3 is limited to ±5 V (3.5 V RMS) and 30 mA, so it
  cannot produce 6 V AC (V<sub>p</sub> = 8.5 V). If you drive with Wavegen, keep the primary at 3.5 V or less, and the secondary
  falls in proportion to 7 V or less
- The 1+ (blue) of the Analog Discovery goes to the column of the primary A1 (`d5`) and 1− (black) to the column of A2
  (`e8`). 2+ (green) goes to the column of the secondary B1 (`d13`) and 2− (black) to the column of B2 (`d16`). With no
  wire between the primary and the secondary, the two channels each see their own voltage
- The GND (black) of the AD goes to the column of the primary A2 (`d8`). It is the same point as the ground symbol G1 in
  Fig. 1, and puts the reference of Scope (the common ground) at a single place on the primary side
- The Scope inputs of the AD3 are differential, and 1− and 2− are not tied together inside. Each pin is pulled down to
  the GND of the AD through about 1 MΩ (details in "Instrument settings" below). So even if you measure the primary and the
  secondary at separate points, the isolation of the transformer is not shorted inside the AD3. If you also connected
  GND to the secondary side, the GND of the AD would touch both windings and break the isolation, so connect it at one
  place on the primary side only
- There is no wiring anywhere between the primary (columns 5 and 8) and the secondary (columns 13 and 16). This is what
  isolation looks like

## Instrument settings

The instrument is Scope of the Analog Discovery 3 (1+/1− = primary, 2+/2− = secondary). It suits this better than a
multimeter because you compare the size and shape of the AC waveforms of the primary and secondary side by side. Set both
the primary and the secondary to 5 V/div and 5 ms/div. The pin inputs on the AD3 body are DC coupled only, but the wave in
this exercise is AC with no DC component, so it is centered on 0 V as it is.

The reason you can measure the primary and secondary at separate points lies in how the inputs of the AD are built.
In the input circuit of the AD2 reference manual (Figure 3 in §2.1), each of the four pins 1+, 1−, 2+ and 2− is pulled
down to the GND of the AD through its own divider of resistors and a capacitor (820 kΩ + 200 kΩ + 20 kΩ, about
1 MΩ ‖ 24 pF in total). The datasheet of the AD3 (Analog Discovery 3 Datasheet) also gives the inputs as differential,
the input range as ±25 V with respect to GND, and the input impedance as 1 MΩ ‖ 24 pF. So 1− and 2− are not tied directly
(they are about 2 MΩ apart through GND), but they are not floating from GND either.

With the connection of this exercise, B1 and B2 of the secondary connect to the GND of the AD through about 1 MΩ each
(through 2+ and 2−). The two 1 MΩ are in parallel as seen from GND, so the secondary side connects to GND through about
0.5 MΩ. This does not short the isolation of the transformer, but the secondary side is not completely floating either.
The potentials of the two ends of the secondary settle, where the two 1 MΩ balance, at about ±8.5 V with respect to GND
(each is half of V<sub>p</sub> = 17 V). Even if one end is pulled toward GND, the other is at most ±17 V, and both stay inside the
input range of ±25 V.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Secondary (CH2) is 2x primary (CH1)
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 60Hz 8.49V, range: 5V/div}
ch2: {wave: sine 60Hz 17V, range: 5V/div}
measure: [vpp, rms, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/scope/01-transformer-basics.svg)

Fig. 3 uses the ideal turns ratio of 1:2 and a 60 Hz supply (50 Hz in 50 Hz regions; with the time base left at 5 ms/div
that shows 2.5 cycles). The readings are 17.0 Vpp and 6.00 V for CH1 and 34.0 Vpp and 12.0 V for CH2, which agree with the
6 V and 12 V in the table below.

## Values to check

The values in the table are calculated values. The turns ratio is primary:secondary = 1:2 (a 6 V winding and a 12 V winding).
Measure the voltages with the AC voltage (ACV) range of the multimeter. The multimeter shows the RMS value.
Measure the continuity between the primary and the secondary after you disconnect the adapter.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Voltage of the primary (A1-A2) | 6 V (the adapter output as it is; about 17 Vpp on Scope) | The primary is the same as the adapter |
| Voltage of the secondary (B1-B2) | 12 V (about 34 Vpp on Scope) | Stepped up 2x, following the turns ratio |
| Current of the secondary (R1 = 1 kΩ) | 12 mA (= 12 V / 1 kΩ) | The voltage is nearly kept even under load (with a light load, even on a small core) |
| Current of the primary (calculated) | about 24 mA | In a lossless ideal transformer the primary and secondary powers are equal, so the currents are in inverse proportion to the turns ratio (half the turns means twice the current). A real transformer adds the current that magnetizes the core, so it can be larger |
| Resistance between the primary and the secondary (multimeter continuity range) | ∞ (no continuity) | The windings are linked only magnetically through the core and are not connected electrically (isolation) |

### Trying step-down

Reconnect a 12 V (RMS, V<sub>p</sub> about 17 V) AC source (a 12 V AC adapter or a signal generator) to the 12 V winding (B1-B2),
and use the 6 V winding (A1-A2) as the output. For a 12 V input the output is 6 V (turns ratio 2:1). With the same 1 kΩ
connected the current is 6 mA, and the current on the adapter side is about 3 mA by calculation. One and the same
transformer lets you try both step-up and step-down. What is fixed is the turns ratio, and which winding serves as the
primary depends on how you connect it.

## Verification with LTspice (not applicable)

The transformer in this exercise is treated as a lossless ideal transformer, and only the values set by the turns ratio
are looked at. An ideal transformer has nothing for SPICE to verify. The numbers in the text were checked by arithmetic.
Step-up is 6 V × 2 = 12 V, the amplitudes are 6 V × 2√2 ≈ 17 Vpp and 12 V × 2√2 ≈ 34 Vpp, the secondary current is
12 V ÷ 1 kΩ = 12 mA, and the primary current is 24 mA because the powers are equal. For step-down it is 6 V ÷ 1 kΩ = 6 mA,
and 3 mA on the adapter side.

## Sources

Original work.

See also: [Transformer (Wikipedia)](https://ja.wikipedia.org/wiki/変圧器), [Lessons In Electric Circuits Vol. II, Chapter 9 (Transformers)](https://www.ibiblio.org/kuphaldt/electricCircuits/AC/AC_9.html)
