---
book: circuits
chapter: 9
id: 9-2
title: Germanium Radio
tier: 50
source: 自作
board: BB
era: 古
ja: ce16c3495602916ca8870c5a05f1005c1307e20f
---

# 9-2 Germanium Radio

A radio that makes sound from the energy of the radio waves alone, with no battery. The waves picked up by the antenna are
selected by LC tuning (the resonance of 9-1), detected by a germanium diode, and heard through a crystal earphone.
The three functions a radio needs (tuning, detection, making sound) can be seen with the fewest parts.

Medium-wave radio broadcasting is AM (amplitude modulation). The sound is carried as changes in the amplitude of a high-frequency
wave (the **carrier**, several hundred kHz to 1.6 MHz). **Detection** takes the sound back out of those amplitude changes (the envelope).
There is no amplifying transistor (a "1-transistor radio" has one transistor), so
**a long antenna and a real earth ground** are essential.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Germanium radio
parts:
  ANT: antenna 1,1
  L1: inductor 3,1 3,3 250u
  GL: ground 3,3
  VC1: capacitor-var 5,1 5,3 l=$\mathrm{VC}_1$
  GVC: ground 5,3
  D1: diode 8,1 10,1 1N60
  C2: capacitor 11,1 11,3 1n
  GC2: ground 11,3
  R1: resistor 13,1 13,3 100k
  GR1: ground 13,3
  EAR: earphone 16,1 16,3 l=$\mathrm{EAR}$
  GEAR: ground 16,3
wires:
  - 1,1 -- 8,1
  - 10,1 -- 16,1
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/02-crystal-radio.svg)

- L1 and VC1 form a parallel tuned circuit. VC1 is a polyvaricon (a variable capacitor with a thin polyethylene film between the plates;
  turning the shaft changes the capacitance). A tuned circuit with L and C in parallel is also called a **tank** (tank circuit).
  Placed between the antenna and ground, this tank picks out the frequency of one station from the received waves.
- Unlike the series circuit of 9-1, a parallel tank has its maximum impedance at f<sub>0</sub>.
  Only waves at f<sub>0</sub> build a large voltage across the tank, and the other frequencies pass through L1 or VC1
  to ground. The formula for f<sub>0</sub> is the same as for the series circuit (see "Tuning frequency" below).
- D1 (germanium diode) is the detector. It passes only the positive side of the tuned-circuit voltage.
  The heights of the peaks that get through trace the envelope, so smoothing out the high frequency with C2 leaves the audio component.
- C2 is a bypass that sends the remaining high-frequency part to ground. Without it, a hissing
  high-frequency sound is mixed into the earphone.
- R1 (100 kΩ) is the load of the detector and a path that lets the DC out of the detector output. The earphone does not pass DC
  (see the next item), so without R1 the charge from detection cannot drain, and the sound becomes quiet and distorted.
- **Impedance of the earphone**: EAR is assumed to be a ceramic (piezoelectric) crystal earphone of the kind sold today
  (capacitance about 15 nF, 20 MΩ or more at DC). Electrically it is a
  capacitor, so its impedance changes with frequency: **about 10 kΩ at 1 kHz**
  (1/(2π×1 kHz×15 nF) ≈ 10.6 kΩ) and about 100 kΩ at 100 Hz. A dynamic earphone of 8 Ω or 32 Ω
  cannot be driven by the small power taken from the radio waves.
- The capacitance of the earphone (15 nF) is 15 times that of C2 (1 nF), and at medium wave it is only 10–20 Ω
  (about 10.6 Ω at 1 MHz). So the earphone itself does most of the job of sending the high frequency to ground.
- With only the DC resistance of the earphone (20 MΩ or more), the time constant with the 16 nF (C2 and EAR) would be about 0.3 s,
  and the detected charge could not drain. Adding R1 in parallel shortens the time constant to about 1.6 ms (100 kΩ×16 nF).
  R3 in the next exercise, 9-3, does the same job.

**Tuning frequency**: f<sub>0</sub> = 1 / (2π√(LC)). With L1 = 250 µH and VC1 = 20–260 pF (the variable range
of the polyvaricon):

| VC1 | f<sub>0</sub> |
| --- | --- |
| 20 pF (fully closed) | about 2.25 MHz |
| 260 pF (fully open) | about 624 kHz |

This covers most of the medium-wave broadcast band (531–1602 kHz). The lower end, 531–624 kHz, is not reached. Stray capacitance of the wiring
adds to the capacitance, so the actual range shifts a little lower.

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
  EAR:
    type: device
    at: top
    label: Crystal earphone
    pins: [A, B]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (test)
    pins: [W1, 2+, 1+, 1-, 2-, GND]
  L1: inductor/axial b5 b9 250u
  D1: diode d5(A) d12(K) 1N60
  C2: capacitor/ceramic b12 b14 1n
  R1: resistor h12 h17 100k
  RS: resistor e3 i3 1k
wires:
  - ANT.1 -- a3 yellow
  - c3 -- c5 yellow
  - VC1.A -- a5 yellow
  - VC1.E -- -t7 black
  - a9 -- -t9 black
  - EAR.A -- a12 green
  - EAR.B -- -t16 black
  - a14 -- -t14 black
  - e5 -- f5 yellow
  - e12 -- f12 green
  - AD.W1 -- j3 orange
  - AD.2+ -- j5 blue
  - AD.1+ -- j12 blue
  - AD.1- -- -b14 black
  - AD.2- -- -b15 black
  - AD.GND -- -b16 black
  - j17 -- -b17 black
  - -t30 -- -b30 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/breadboard/02-crystal-radio.svg)

- **The antenna wire is 5–10 m** of insulated wire, strung outdoors or by a window. The longer it is, the more stations you can receive.
- Connect the top −t rail (blue) to a **real earth ground**. Run a wire to a water pipe or a ground rod
  (this is not only the common line of the circuit; it is a path that really sends current into the earth).
- Columns 3 and 5 are the antenna net (ANT, A of VC1, the left pin of L1, the anode of D1, the upper pin of RS).
  Columns 3 and 5 are joined by a short yellow wire in row c. The right pin of L1 (column 9) goes to the − rail.
- Column 12 is the detector-output net (the cathode of D1, the left pin of C2, A of EAR). The right pin of C2 (column 14) and B of EAR go to the top − rail.
  Column 12 is carried to column 12 of the lower half by a short green wire across the center gap, and R1 (100 kΩ) sits in row h of the lower half. The right pin of R1 (column 17) goes to the bottom − rail.
- The top and bottom − rails are joined by the black wire at column 30.
- The AD3 was added for **testing**, for when the broadcast waves are weak and the waveform is hard to see. The AM signal of W1 (Wavegen) goes into the tuned circuit
  through RS (1 kΩ). RS is inserted vertically across the gap at column 3 (`e3` and `i3`), and W1 goes into column 3 of the lower half (`j3`).
  W1 takes the place of the antenna, so you may disconnect the ANT wire during the test.
  Column 5 is carried to column 5 of the lower half by a short yellow wire across the gap, and 2+ (CH2) of the AD3 touches the tuned circuit (`j5`).
  1+ (CH1) touches the detector output (column 12 of the lower half, `j12`). 1−, 2− and GND go to the bottom − rail. There is no battery, so Supplies is not used.
- Put only one pin or wire in each hole.

## Instrument settings

The instrument is the Analog Discovery 3 (AD3). In place of the broadcast waves, W1 outputs an AM signal, and Scope shows the tuned circuit and the detector output.
The signal has a 1 MHz carrier, which is within the range of Scope (10 MHz or less). Turn VC1 to about 100 pF
(f<sub>0</sub> = 1 / (2π√(250 µH × 100 pF)) ≈ 1.007 MHz).

| Item | Value |
| --- | --- |
| Wavegen W1 | Carrier Sine 1 MHz, amplitude 1 V<sub>p</sub>, Modulation: AM, modulating wave Sine 1 kHz, modulation depth 50 % |
| Scope CH1 (1+ = detector output) | Coupling DC, 100 mV/div, Offset around 1 V |
| Scope CH2 (2+ = tuned circuit) | Coupling DC, 1 V/div |
| Scope time base and trigger | 200 µs/div, rising edge of CH1 |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 AM test, CH2 swells and shrinks, CH1 is 1kHz
time: 200us/div
trigger: ch1 rising 0.99V
ch1: {wave: = 0.99V + 0.197V * sin(2 * pi * 1kHz * t), range: 100mV/div, position: -10div}
ch2: {wave: = 0.93V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 1V/div, position: 2.5div}
measure: [vpp, avg, freq]
cursors: [250us, 750us]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/02-crystal-radio.svg)

- Fig. 3 is a screen based on an LTspice calculation (a rough guide, with the 1N60 assumed to have IS = 0.2 µA and RS = 25 Ω). It is not a measurement.
- CH1 averages about 1.0 V, and the 1 kHz swing is about 0.39 Vpp (0.80–1.19 V). This is much smaller than the swing of the envelope (CH2), about 1.4 Vpp.
  The time constant of R1 (100 kΩ) with C2 and EAR (16 nF in total) is about 1.6 ms, longer than the 1 kHz period (1 ms), so the detector output is smoothed.
- At 200 µs/div the 1 MHz carrier of CH2 looks like a filled band. The outline of the band swelling and shrinking at 1 kHz is the AM.
  The maximum amplitude of the band is about 1.4 V<sub>p</sub>.

### Looking at the tuned circuit alone with the VNA (supplement)

If you use the LiteVNA64 in place of W1 and Scope, you can measure the resonant frequency and sharpness of the tuned circuit (L1 and VC1 in parallel)
without broadcast waves (medium wave is within the range starting at 50 kHz). Remove the parallel L1 and VC1 from the circuit and insert them
**in series** between CH0 and CH1, like the series fixture in 03-nanovna/03-fixtures/01-series-fixture.md (3-1), and sweep the Log Mag of S21 over 0.8–1.3 MHz.
At parallel resonance the impedance of L1 and VC1 in parallel becomes very large and the signal does not pass, so S21 has a deep dip at f<sub>0</sub> only.
The position of the dip is the tuning frequency, and it moves when you turn VC1.

The screen you should see (an ideal model: VC1 = 100 pF, with the loss of L1 taken as 158 kΩ in parallel (Q = 100). A rough guide, not a measurement).

```vna
# NanoVNA screen (tommie-fence vna fence)
device: litevna64
sweep: 0.8M-1.3M 401
title: Fig. 4 S21 of the tuned circuit, deep dip at f0
dut:
  - series L 250u cp 100p rp 158k
traces:
  - S21 logmag
markers:
  - 1.007M
```

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/vna/02-crystal-radio.svg)

- The position of the dip is f<sub>0</sub> = 1 / (2π√(250 µH × 100 pF)) ≈ 1.007 MHz. The figure reads about −64 dB at 1.007 MHz.
- The narrower the dip, the smaller the loss of L1 (the higher the Q). A real circuit does not get as deep as −64 dB; the Q of the coil and leakage in the fixture make it shallower.
- Turning VC1 over 20–260 pF moves the dip from about 2.2 MHz down to 0.62 MHz (calculated values; stray capacitance of the wiring lowers it somewhat).

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| L1 | Inductor (axial) | 250 µH |
| VC1 | Polyvaricon | 20–260 pF |
| D1 | Germanium diode | 1N60 |
| C2 | Ceramic capacitor | 1 nF |
| R1 | Resistor | 100 kΩ |
| EAR | Crystal earphone | Capacitance about 15 nF |
| RS | Resistor (for testing; feeds W1 into the tuned circuit) | 1 kΩ |
| — | Signal source and oscilloscope for testing | Analog Discovery 3 (W1, Scope 1 and 2). No battery or Supplies |

## Values to check

Rough guides (confirm by experiment). A germanium diode (1N60) starts conducting at 0.2–0.3 V, lower than silicon,
so it can detect even a weak signal with no battery.

| What to check | Result |
| --- | --- |
| Turn VC1 | The stations you receive change (you can tell the tuning moves) |
| Replace D1 with a 1N4148 (silicon) | Almost inaudible (the turn-on voltage is too high) |
| Disconnect the ground wire | The sound gets quieter or disappears (the return path of the current becomes thin) |
| Remove R1 | The sound gets quieter and distorted (the detected charge cannot drain; see the R1 item above) |
| Feed the AM signal of W1 (1 MHz, 1 V<sub>p</sub>, 1 kHz, 50 %) and turn VC1 to about 100 pF (for testing) | As in Fig. 3, CH1 averages about 1.0 V with a 1 kHz swing of about 0.39 Vpp (a rough guide from the LTspice calculation) |

## Verification with LTspice

**Comparison with LTspice**: In `sim/02-crystal-radio.cir`, the AM signal of W1 (1 MHz, 1 V<sub>p</sub>, 1 kHz, 50 %) is fed through RS (1 kΩ) into
L1 (250 µH) and VC1 (100 pF) in parallel, and the circuit through D1, C2, R1 and EAR (15 nF) was run as a transient analysis (the last 4 ms are read).
The 1N60 is assumed to have IS = 0.2 µA and RS = 25 Ω, with a capacitance of 1 pF (rough guides, not measured values).
The detector output (CH1) averages 1.01 V and swings 0.81–1.21 V (0.40 Vpp), and the maximum carrier of the tuned circuit (CH2) is 1.39 V<sub>p</sub>,
which agrees with the about 1.0 V, 0.39 Vpp and about 1.4 V in the text. Verdict: agrees (the text is not changed).
f<sub>0</sub> and the time constant are calculated from formulas, and the VNA dip in Fig. 4 (−64 dB) is a rough guide from an ideal model; they were not run here.
The strength of real broadcast waves received by an antenna is outside the scope of the simulation.

## Sources

Original work.
The capacitance and impedance of the crystal earphone come from the specifications of a commercial ceramic earphone
([Kyoritsu Electronics Industry CH905](https://eleshop.jp/shop/g/gE7P361/), capacitance 15000 pF, impedance 20 MΩ or more, frequency range 200–8000 Hz) and
an example of measurement ([Characteristics of ceramic earphones](https://www.crystal-set.com/report/s100.htm), 80–90 kΩ at 100 Hz).
