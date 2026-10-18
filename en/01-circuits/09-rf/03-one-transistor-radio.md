---
book: circuits
chapter: 9
id: 9-3
title: One-Transistor Radio — RF Amplification and Diode Detection
tier: 50
source: 自作
board: BB
era: 古
ja: 7d42c2d620fb7ef87fb3e1933bbd862522ff6844
---

# 9-3 One-Transistor Radio — RF Amplification and Diode Detection

Keep the tuning tank of the germanium radio (9-2) as it is, and **amplify the high frequency with one transistor
before detection**. The diode D1 does the detection, and a DC bias current is passed through D1 in advance.
With these two changes, even weak waves give a louder sound. In exchange for needing a battery, you can hear stations even with a short antenna.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 One-transistor radio
parts:
  ANT: antenna 1,5
  L1: inductor 2,5 2,7 250u
  GL: ground 2,7
  VC1: capacitor-var 4,5 4,7 l=$\mathrm{VC}_1$
  GVC: ground 4,7
  C1: capacitor 6,5 7,5 0.01u
  Q1: npn 10,5
  VCC: vcc 10,1 5V
  Rc: resistor 10,3 10,1 1.5k
  Rb: resistor 8,3 10,3 220k
  GE: ground 10,6
  D1: diode 11,3 13,3 1N60
  C3: capacitor 14,3 14,5 0.001u
  GC3: ground 14,5
  R3: resistor 16,3 16,5 100k
  GR3: ground 16,5
  EAR: earphone 19,3 19,5 l=$\mathrm{EAR}$
  GEAR: ground 19,5
wires:
  - 1,5 -- 6,5
  - 7,5 -- 8,5
  - 8,5 -- Q1.B
  - 8,3 -- 8,5
  - 10,3 -- Q1.C
  - Q1.E -- 10,6
  - 10,3 -- 11,3
  - 13,3 -- 17,3
  - 17,3 -- 19,3
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/03-one-transistor-radio.svg)

- **Tank → C1 → base**: The waves selected by the parallel tank of L1 and VC1 are passed to the base of Q1
  through the coupling capacitor C1.
- **Collector feedback bias**: Rb (220 kΩ) returns from the collector to the base. The operating point stays stable
  even when h<sub>FE</sub> varies from 100 to 300 (the same idea as in 2-8).
- **Detection**: D1 is connected directly to the collector of Q1. Current always flows along the path Rc → collector → D1 → R3 → GND,
  so the diode is already sitting at the turn-on knee of germanium.
  Detection begins even with weak waves.
- C3 drops the remaining high frequency to GND, and R3 is the load of the detector. EAR (crystal earphone)
  is connected in parallel with R3 (terminal A to the detector output, terminal B to GND) to make the sound.
- **Impedance of the earphone**: EAR is assumed to be a ceramic (piezoelectric) crystal earphone of the kind sold today
  (capacitance about 15 nF, 20 MΩ or more at DC). Electrically it is a
  capacitor, so its impedance changes with frequency: **about 10 kΩ at 1 kHz**
  (1/(2π×1 kHz×15 nF) ≈ 10.6 kΩ) and about 100 kΩ at 100 Hz. A dynamic earphone of 8 Ω or 32 Ω
  cannot be driven by this small current.
- At 1 kHz the earphone (about 10 kΩ) is much lower than R3 (100 kΩ), so the audio load is almost entirely the earphone.
  The earphone does not pass DC, so R3 provides the DC path that carries the bias current through D1.
  The capacitance of the earphone (15 nF) is in parallel with C3 (1 nF) and also helps bypass the high frequency.

**Calculated operating point** (assuming V<sub>CC</sub> = 5 V, h<sub>FE</sub> = 200, V<sub>BE</sub> = 0.6 V):

- I<sub>C</sub> = (V<sub>CC</sub> − V<sub>BE</sub>) / (R<sub>b</sub>/h<sub>FE</sub> + R<sub>c</sub>)
  = (5 V − 0.6 V) / (220 kΩ/200 + 1.5 kΩ) = 4.4 V / 2.6 kΩ ≈ 1.7 mA
- V<sub>C</sub> = V<sub>CC</sub> − I<sub>C</sub> × R<sub>c</sub> = 5 V − 1.7 mA × 1.5 kΩ ≈ 2.5 V.
  This is about half the supply, so there is room for the signal to swing both up and down.
- Voltage gain = g<sub>m</sub> × R<sub>c</sub>. g<sub>m</sub> = I<sub>C</sub> / 26 mV (seen in 2-3), so
  1.7 mA / 26 mV × 1.5 kΩ ≈ 98 times (20 log 98 ≈ 40 dB)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: half
parts:
  ANT:
    type: device
    at: top
    label: Antenna
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: Polyvaricon 260pF
    pins: [A, E]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [W1, V+, GND, 2+, 1+, 1-, 2-]
  EAR:
    type: device
    at: bottom
    label: Crystal earphone
    pins: [A, B]
  L1: inductor/axial b12 b16 250u
  C1: capacitor/ceramic d12 d18 0.01u
  RS: resistor e12 i12 1k
  Rb: resistor b18 b22 220k
  Rc: resistor c22 c26 1.5k
  Q1: transistor h18(B) h19(C) h20(E) 2SC1815
  D1: diode e22(A) f22(K) 1N60
  C3: capacitor/ceramic g22 g26 0.001u
  R3: resistor i22 i26 100k
wires:
  - ANT.1 -- c12 yellow
  - VC1.A -- a12 yellow
  - VC1.E -- -t14 black
  - AD.W1 -- j12 orange
  - AD.2+ -- j19 blue
  - AD.1+ -- h22 blue
  - AD.V+ -- +b17 red
  - AD.GND -- -b19 black
  - AD.1- -- -b22 black
  - AD.2- -- -b23 black
  - +t30 -- +b30 red
  - a16 -- -t16 black
  - e18 -- f18 orange
  - f19 -- e19 blue
  - a19 -- a22 blue
  - +t26 -- a26 red
  - j20 -- -b21 black
  - j26 -- -b25 black
  - EAR.A -- j24 green
  - j24 -- j22 green
  - EAR.B -- -b28 black
  - -t30 -- -b30 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/breadboard/03-one-transistor-radio.svg)

- **Place the AD3 at the bottom** (columns 22 and 19, where you measure the detector output and the collector, are in the lower block, so the wires do not run a long way across the board).
  Put V+ (5 V of Supplies) in the bottom red rail (column 17) and GND in the bottom blue rail (column 19). Red rail = +5 V, blue rail = GND.
  At column 30 the top and bottom + rails are joined, and so are the − rails (from the top + rail to Rc, and from the top − rail to L1 and VC1).
- In the front stage, column 12 collects the antenna, VC1, L1 and C1. The right lead of L1 (column 16) goes to the top − rail.
- Q1 goes in row h of the lower block, in three adjacent columns (column 18 B, column 19 C, column 20 E). This spacing lets you insert it without
  bending the pins much. Seen with its flat face toward you, the 2SC1815 has E, C, B from the left, so
  with the flat face toward the upper block it reads B, C, E from the left. The emitter (column 20) goes to the bottom − rail.
- The base (column 18) comes out to column 18 of the upper block with a short e–f wire, and the left leads of C1 and Rb go there.
  The collector (column 19) also comes out to column 19 of the upper block with an e–f wire, and goes to column 22 with a blue wire in row a.
  Column 22 collects the right lead of Rb, Rc and D1. Because B and C are adjacent, Rb is not run across directly; column 22 is used instead.
- The right lead of Rc (column 26) goes to the top + rail. D1 crosses the gap at column 22, with the anode on top (collector) and
  the cathode below (detector output). In the lower column 22 the left leads of C3 and R3 line up, and terminal A of EAR goes through column 24 (`j24`) to column 22 (`j22`) (to reduce crossings with the wires of 1− and 2− of the AD3).
  The right leads of C3 and R3 (column 26) and terminal B of EAR go to the bottom − rail.
- W1 of the AD3 (Analog Discovery 3) goes through RS (1 kΩ) to column 12 of the tuned circuit. This is for testing in place of broadcast waves,
  and you may disconnect the ANT wire when you use it. RS is inserted vertically across the gap (`e12` and `i12`), and W1 goes into column 12 of the lower half (`j12`). 1+ is the detector output (lower column 22, `h22`), 2+ is the collector of Q1 (lower column 19, `j19`), and 1−, 2− and GND go to the bottom − rail (columns 22, 23 and 19).
- Put only one pin or wire in each hole.

## Instrument settings

The instrument is the Analog Discovery 3. One unit provides the power supply (V+ = 5 V of Supplies), the signal source (W1 of Wavegen) and the oscilloscope (Scope),
and the 1 MHz carrier is within the range of Scope (10 MHz or less). The supply current is about I<sub>C</sub> ≈ 1.7 mA, within about 50 mA for one supply rail,
and within the 200 mA per hole of the breadboard. Turn VC1 to about 100 pF (f<sub>0</sub> ≈ 1.007 MHz).

| Item | Value |
| --- | --- |
| Supplies | V+ = 5 V, output ON |
| Wavegen W1 | Carrier Sine 1 MHz, amplitude 20 mV<sub>p</sub>, Modulation: AM, modulating wave Sine 1 kHz, modulation depth 50 % |
| Scope CH1 (1+ = detector output) | Coupling DC, 200 mV/div |
| Scope CH2 (2+ = collector) | Coupling DC, 1 V/div |
| Scope time base and trigger | 200 µs/div, rising edge of CH1 |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 AM test, collector (CH2) amplified, detector (CH1) 1 kHz
time: 200us/div
trigger: ch1 rising 2.98V
ch1: {wave: = 2.98V + 0.31V * sin(2 * pi * 1kHz * t), range: 200mV/div, position: -14.9div}
ch2: {wave: = 2.45V + 0.78V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 1V/div, position: -2.45div}
measure: [vpp, avg, freq]
cursors: [250us, 750us]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/03-one-transistor-radio.svg)

- Fig. 3 is a screen based on an LTspice calculation (the 2SC1815 as a general-purpose model with BF = 200, and the 1N60 assumed to have IS = 0.2 µA and RS = 25 Ω). It is not a measurement.
- CH2 (collector) shows a DC level of about 2.45 V (nearly the same as the 2.5 V operating point above) with the 1 MHz carrier on top. The amplitude swells and shrinks at 1 kHz,
  with a maximum of about 1.2 V<sub>p</sub>. The amplitude of the input tuned circuit is at most about 19 mV<sub>p</sub>, so the effective gain is about 60 times.
  It is smaller than the 98 times above because the load of D1, R3 and the earphone is added to the tank and Rc.
- CH1 averages about 3.0 V, and the 1 kHz swing is about 0.6 Vpp (2.66–3.28 V). D1 picks up the peaks at the collector, and C3, R3 and the earphone smooth the output.

### Looking at the tuned circuit alone with the VNA (supplement)

The tuned circuit of L1 and VC1 is the same as in 9-2, and with VC1 turned to about 100 pF, f<sub>0</sub> is about 1.007 MHz.
Even without broadcast waves or the signal of W1, you can measure f<sub>0</sub> and the sharpness of the dip as a dip in S21 by removing only the parallel L1 and VC1 from the circuit
and inserting them in series between CH0 and CH1 of the LiteVNA64. How to connect, the screen you should see (figure) and how to read it are
the same as in "Looking at the tuned circuit alone with the VNA" in 01-circuits/09-rf/02-crystal-radio.md (9-2). The dip moves when you turn VC1.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| L1 | Inductor (axial) | 250 µH |
| VC1 | Polyvaricon | 20–260 pF |
| C1 | Ceramic capacitor | 0.01 µF |
| Rb | Resistor | 220 kΩ |
| Rc | Resistor | 1.5 kΩ |
| Q1 | NPN transistor | 2SC1815 |
| D1 | Germanium diode | 1N60 |
| C3 | Ceramic capacitor | 1 nF |
| R3 | Resistor | 100 kΩ |
| EAR | Crystal earphone | Capacitance about 15 nF |
| RS | Resistor (for testing; feeds W1 into the tuned circuit) | 1 kΩ |
| — | Power supply, test signal source and oscilloscope | Analog Discovery 3 (V+ = 5 V, W1, Scope 1 and 2) |

## Values to check

Calculated values.

| Where to measure | Expected value |
| --- | --- |
| Collector voltage of Q1 (multimeter DC voltage, referenced to GND) | About 2.5 V (half the supply) |
| Collector current of Q1 (measure the voltage across Rc with the multimeter and divide by 1.5 kΩ) | About 1.7 mA (about 2.5 V across Rc) |
| Voltage gain (g<sub>m</sub>·R<sub>c</sub>) | About 98 times (40 dB). This is an upper limit that does not count the load of R3 and the earphone. With D1 and C3 counted as the load, the effective gain in LTspice is 40–68 times (smaller for weaker signals) |

- Weaker stations can be heard than with the tank-only germanium radio (9-2).
  Because the high frequency is amplified before detection, it is easier to build the amplitude that detection needs.
- If you move the collector-side pin of Rb to +5 V, it becomes a fixed bias. The base current is set to
  (5 V − 0.6 V) ÷ 220 kΩ ≈ 20 µA, and I<sub>C</sub> = h<sub>FE</sub> × 20 µA follows the spread of h<sub>FE</sub> directly.
  With h<sub>FE</sub> 100 it is 2 mA and V<sub>C</sub> ≈ 2 V. With h<sub>FE</sub> 200 it should be 4 mA, but Rc cannot drop 6 V,
  so Q1 saturates and V<sub>C</sub> sticks near 0 V. This lets you confirm the effect of collector feedback.

## Verification with LTspice

**Comparison with LTspice**: `sim/03-one-transistor-radio.cir` ran the whole circuit of Fig. 1 (an AM signal of 1 MHz, 20 mV<sub>p</sub>,
1 kHz, 50 % through RS 1 kΩ, L1 250 µH ∥ VC1 100 pF, C1, Rb, Rc, Q1, D1, C3, R3 and EAR 15 nF) as a transient analysis, and the last 4 ms were read.
Q1 is a substitute model for the 2SC1815 (the same as in `sim/agc.cir`, with only BF set to 200; an assumption made from typical values, not measured), and the 1N60 is assumed to have IS = 0.2 µA and RS = 25 Ω.

| Item | Value in the text | LTspice (BF = 200) | Verdict |
| --- | --- | --- | --- |
| Collector DC | About 2.5 V (calculated 2.5 V, Fig. 3 2.45 V) | 2.46 V | Agrees |
| Collector current | About 1.7 mA | 1.7 mA | Agrees |
| Amplitude of the tuned circuit (peak) | At most about 19 mV | About 15 mV (+13 / −16 mV) | About 30% smaller (the difference in the estimate of the losses of RS and the circuit; includes the small offset of 1 MHz from the f<sub>0</sub> of 1.007 MHz) |
| Carrier amplitude at the collector (maximum) | About 1.2 V<sub>p</sub> | About 0.97 V<sub>p</sub> | About 20% smaller |
| Effective gain | About 60 times | About 65 times (0.97 V ÷ 15 mV) | Agrees |
| Effective gain (unmodulated, varying the tuned-circuit amplitude) | 98 times is an upper limit, effective about 60 times | 39 times at 0.5 mV of the tuned circuit, 50 times at 1.5 mV, 65 times at 4.7 mV, 66–68 times at 9 mV and above | Agrees. For weak stations D1 is not deeply biased and the load is heavy, so the gain falls to about 40 times |
| Average and swing of the detector output (CH1) | About 3.0 V, 0.6 Vpp | 2.88 V, 0.54 Vpp (2.59–3.14 V) | Agrees to within about 10% |

With BF = 250 (agc.cir as it is), the collector is 2.24 V and I<sub>C</sub> is 1.8 mA; the direction that a larger h<sub>FE</sub> raises the current and lowers the collector is as calculated.
The operating point and the size of the gain agree, so the numbers in the text are not changed (the gain of 98 times was already written as "an upper limit that does not count the load of R3 and the earphone", and the effective value with D1 and C3 counted as the load is 40–68 times, as in the table above). The amplitudes in Fig. 3 (1.2 V, 0.6 Vpp) are, as above, 10–20% larger than the recalculation,
and are within a range that moves with the assumed transistor and coil losses, so read them as "rough guides". The VNA figure and reception of real broadcasts are outside the scope.

## Sources

Original work.
The capacitance and impedance of the crystal earphone come from the specifications of a commercial ceramic earphone
([Kyoritsu Electronics Industry CH905](https://eleshop.jp/shop/g/gE7P361/), capacitance 15000 pF, impedance 20 MΩ or more, frequency range 200–8000 Hz) and
an example of measurement ([Characteristics of ceramic earphones](https://www.crystal-set.com/report/s100.htm), 80–90 kΩ at 100 Hz).
