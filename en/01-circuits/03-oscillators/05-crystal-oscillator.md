---
book: circuits
chapter: 3
id: 3-5
title: Crystal oscillation — CMOS inverter plus crystal
tier: 50
source: 自作
board: BB
ja: 9db52f521cb2542a5be1493198bbaade489be5cf
---

# 3-5 Crystal oscillation — CMOS inverter plus crystal

An **inverter** is a logic gate that outputs Low when its input is High and High when its input is Low (NOT; Chapter 10).
The 74HC04 is an IC with six **CMOS** inverters. CMOS is a circuit style that pairs a P-channel and an N-channel MOSFET (seen in 2-5), and
almost no current flows except at the instant the output switches. Almost no current flows into the input either, so the operating point does not collapse even with a 1 MΩ resistor attached.
Run one of these inverters in its linear region (the range where the output changes in proportion to the input, so it works as an amplifier)
with a feedback resistor, and let a **crystal** (a part that vibrates strongly only at one fixed frequency) set the
oscillation frequency. This is the "Pierce oscillator". It is the basic form used for microcontroller clocks (the beat that times operation) and for the local oscillator of a radio,
and its frequency is orders of magnitude more accurate than the RC oscillators (3-1 to 3-3). A second inverter
buffers the signal before it goes out.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Crystal oscillator (Pierce)
parts:
  U1A: not 3,3 74HC04
  U1B: not 8,2 74HC04
  Rf: resistor 1,2 5,2 1M
  Rd: resistor 5,3 7,3 330
  X1: crystal 1,4 7,4 4M
  C1: capacitor 1,4 1,5 22p
  C2: capacitor 7,4 7,5 22p
  G1: ground gnd
  OUT: port 10,2
  U1C: not 9,4 74HC04
  GUx: ground 8,4 r90
points:
  gnd: 4,5
wires:
  - 1,2 -- 1,3 -- 1,4
  - 1,3 -- U1A.in
  - U1A.out -- 5,3
  - 5,2 -- 5,3
  - 7,3 -- 7,4
  - 1,5 -- gnd -- 7,5
  - 5,2 -- U1B.in
  - U1B.out -- 10,2
  - U1C.in -| 8,4
notes:
  - text 9,5 blue center: "Other 4 gates (inputs to GND)"
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/circuit/05-crystal-oscillator.svg)

- U1A, U1B and U1C in Fig. 1 are inverters inside the same 74HC04 (one U1). U1A (input pin 1, output pin 2) oscillates, U1B (input pin 3, output pin 4) is the buffer,
  and U1C (input pin 5, output pin 6) stands for the remaining 4 unused inverters drawn together (the inputs on pins 9, 11 and 13 and the outputs on pins 8, 10 and 12 are treated the same way)
- **Rf (1 MΩ) biases U1A into the linear region** (it sets the operating point). A CMOS inverter is by nature
  a 0-or-1 switch, but feeding its output back to its input through a resistor lets it work as an **amplifier**
- **Rd (330 Ω) is a damping resistor that lowers the drive level of the crystal.** Without it, too much current
  flows into the crystal, and the crystal degrades from overdrive
- C1 and C2 (22 pF) are the **load capacitance**. Match them to the crystal's specification (often 18–22 pF).
  If the value is off, the oscillation frequency is also slightly off
- U1B is a buffer. Connecting an oscilloscope or the next stage directly to the output of U1A can stop the oscillation,
  so one stage is inserted before the signal goes out

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Pin 1 (1A) is lifted to the upper block by the wire on column 6. The crystal, C1 and C2 go on top, and Rf and Rd on the bottom. Top red rail = +5V, blue rail = GND (the top and bottom blue rails are joined at column 1)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  U1: dip14 @ e8 74HC04
  Rf: resistor h8 h9 1M
  Rd: resistor h10 h16 330
  X1: crystal/hc49 b6 b16
  C1: capacitor c3 c6 22p
  C2: capacitor c16 c19 22p
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t4 black
  - +t8 -- a8 red
  - -t1 -- -b1 black
  - g8 -- g6 orange
  - f6 -- d6 orange
  - g9 -- g10 orange
  - d16 -- g16 orange
  - a3 -- -t3 black
  - a19 -- -t19 black
  - j14 -- -b14 black
  - j11 -- SC.1+ gray
  - SC.1- -- -b22 black
  - j12 -- -b12 black
  # Tie the inputs of the 4 unused gates (pins 5, 9, 11 and 13) to GND
  - a9 -- -t9 black
  - a11 -- -t11 black
  - a13 -- -t13 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/breadboard/05-crystal-oscillator.svg)

- **U1 in Fig. 2 is a 14-pin 74HC04. Only two gates are used: pins 1 and 2 (the oscillator, U1A of Fig. 1) and pins 3 and 4
  (the buffer, U1B of Fig. 1).** Pin 7 is GND and pin 14 is VCC
- The crystal (HC-49/U) has no polarity, so either direction works. **Keep the leads short.** Place it between column 6 (the wire
  lifted from pin 1) and column 16 (the node of Rd and C2, joined to Rd below by a wire across the gap)
- **Tie unused inputs to GND.** Connect the inputs of the remaining 4 gates (pins 5, 9, 11 and 13) to GND.
  A floating CMOS input swings on its own, raises the supply current, and can disturb the oscillation.
  Pin 5 (below column 12) goes from row j to the bottom blue rail, and pins 13, 11 and 9 (above columns 13, 11 and 9) go from
  row a to the top blue rail. The top and bottom blue rails are joined at column 1. Leave the outputs (pins 6, 8, 10 and 12)
  unconnected

**Why a breadboard is acceptable here (an exception to the 3 MHz rule).** 4 MHz is slightly above this textbook's
guideline for a breadboard (circuits on a breadboard are 3 MHz or lower). It is an exception on purpose.
The crystal sets the frequency, and a low-impedance CMOS inverter drives the crystal, so the stray capacitance of the breadboard only
pulls the frequency slightly, and the oscillation itself does not break down.
The leads are short, the supply is 5 V and the current is a few mA, well within the voltage and current range of a breadboard.
What this experiment is meant to show is how the oscillator works and its waveform, not the accuracy of the frequency
(a reading slightly off 4.000 MHz does not defeat the purpose of the experiment).

- The power comes from the AD3 Supplies (set V+ to 5 V). The 74HC04 draws a few mA at 4 MHz, within the 50 mA of V+ (250 mW on USB power).
  V+ goes to the top + rail and GND to the top − rail
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (gray) goes to the output of U1B (pin 4, column 11, `j11`), and 1− (black) goes to the bottom − rail (GND)

## Instrument settings

Use the AD3 Scope as the oscilloscope. 4 MHz is below 10 MHz, and the shape of the waveform is also of interest. Check the bandwidth and the sampling first, though.

- **Bandwidth**: when the AD3 is plugged directly into the breadboard with the supplied wires, its bandwidth is 9 MHz (−3 dB, the value measured in 0-5). A 4 MHz sine wave drops to about 91 % (−0.8 dB)
  (as a first-order lag, 1 ÷ √(1 + (4/9)²) ≈ 0.91). The flat part of a square wave reaches almost 5 V, because the half period of 125 ns is 7 times the time constant of 17.7 ns.
  The third harmonic (12 MHz) drops to about 60 % and the fifth (20 MHz) to about 41 %, so the corners look slightly rounded
- **Sampling**: the AD3 samples at up to 125 MS/s (Digilent's published value; a rough guide, not verified on the instrument at hand). About 31 points fall in one 4 MHz period (250 ns).
  To see the shape of a square wave, 10 or more points per period are enough. With Time at 50 ns/div, the screen (10 divisions = 500 ns) holds 2 periods
- The frequency can also be read from Frequency in the Scope's Measure. To check the accuracy, use a frequency counter (0-9)

| Setting | Value |
| --- | --- |
| Scope CH1 (output of U1B, pin 4) | DC, 1 V/div |
| Time | 50 ns/div (2 periods in 500 ns). Set Sample Rate to the maximum |
| Trigger | CH1, rising, 2.5 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Output of U1B (pin 4), a 4 MHz square wave (250 ns period)
time: 50ns/div
trigger: ch1 rising 2.5V
ch1: {wave: square 4MHz 2.5V offset 2.5V | rc 17.7ns, range: 1V/div}
cursors: [-62.5ns, 187.5ns]
measure: [vpp, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/scope/05-crystal-oscillator.svg)

Fig. 3 is an expected figure from calculation, not a measurement. A 5 V square wave is overlaid with the 9 MHz bandwidth of the AD3 as a first-order lag (time constant 17.7 ns = 1 ÷ (2π × 9 MHz)).
The 250 ns gap between the cursors is one period, which is 4 MHz. The rounded edges come almost entirely from the bandwidth of the instrument, not from the delay of the 74HC04 itself.

### Looking at the crystal alone with a VNA (supplement)

Before building the oscillator, you can check the resonance of the crystal itself with the S21 of a LiteVNA64 (the lower limit is 50 kHz, so 4 MHz is in range).
As with the series fixture of 3-1, insert the crystal in series between CH0 and CH1, calibrate, and then sweep the Log Mag of S21 over 3.99–4.02 MHz.
At the series resonance f<sub>s</sub> the signal passes well, and at the parallel resonance f<sub>p</sub> just above it the signal does not pass.
The frequency of the oscillator comes between these two (at the point set by the 22 pF load capacitance). For the measurement method and how to read the result, see
03-nanovna/04-components/06-crystal.md (4-6).

The screen you should see (an ideal model; a rough guide assuming typical values for a 4 MHz HC-49/U: C<sub>m</sub> = 31.66 fF, L<sub>m</sub> = 50 mH, R<sub>m</sub> = 50 Ω, C<sub>0</sub> = 5 pF. It is not a measurement).

```vna
# NanoVNA screen (tommie-fence vna fence)
device: litevna64
sweep: 3.99M-4.02M 401
title: Fig. 4 S21 of a 4 MHz crystal, fs (passes) and fp (blocks)
dut:
  - series C 31.66f esl 50m esr 50 cp 5p
traces:
  - S21 logmag
markers:
  - 4.0001M
  - 4.0127M
```

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/vna/05-crystal-oscillator.svg)

f<sub>p</sub> = f<sub>s</sub>·√(1 + C<sub>m</sub>/C<sub>0</sub>) ≈ 4.0127 MHz, which is about 13 kHz above f<sub>s</sub>.
The readings in the figure are −4.0 dB at f<sub>s</sub> (4.000 MHz) (it is not 0 dB because R<sub>m</sub> = 50 Ω is in series between two 50 Ω terminations) and
−76 dB at f<sub>p</sub> (4.013 MHz).
The marking on the crystal (4.000 MHz) is the frequency with the load capacitance attached (here about 11 pF, C1 and C2 in series),
so it is correct for it to fall between the f<sub>s</sub> and f<sub>p</sub> measured on the crystal alone.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 (U1A, U1B and U1C of Fig. 1) | CMOS hex inverter (only 2 gates used) | 74HC04 |
| Rf | Resistor (bias) | 1 MΩ |
| Rd | Resistor (damping) | 330 Ω |
| X1 | Crystal (HC-49/U) | 4.000 MHz |
| C1, C2 | Ceramic capacitor (load capacitance) | 22 pF |
| — | Power supply | 5 V (V+ of the AD3 Supplies) |
| — | Instrument | AD3 Scope 1+ (output of U1B) |

## Values to check

Calculated and measured values. The frequency is the one marked on the crystal and cannot be changed by resistors or capacitors.

| Where to measure | Expected value | What it tells you |
| --- | --- | --- |
| Frequency at the output of U1B (OUT) | 4.000 MHz ± 30 ppm (about ± 120 Hz) | The accuracy of the crystal itself. The accuracy of the resistors is irrelevant |
| Waveform | Close to a square wave (edges slightly rounded) | Buffered output of a CMOS inverter |
| DC voltage at the input of U1A (pin 1, column 8) | About Vcc/2 (2.5 V) | Rf's feedback biases the inverter near its threshold |
| With Rd removed | It still oscillates, but the crystal heats up more | Evidence that the damping works (do not leave it this way for long) |

With a frequency counter (0-9) you can count OUT directly. With only an oscilloscope (Fig. 3),
read the period and take the reciprocal (a reading near 0.25 µs is enough). A difference of ±30 ppm cannot be seen
in an oscilloscope reading, so use a frequency counter to check the accuracy. Measure the DC voltage at the input of U1 with the multimeter's
DC voltage range, between pin 1 (column 8) and GND.

## Verification with LTspice

This exercise is out of scope for LTspice. The oscillation frequency is the marking on the crystal (4.000 MHz) itself and is not set by the parts of the circuit.
The inside of the 74HC04 (the gain and phase of the inverter) and the values of the crystal's equivalent circuit would be assumptions, so a model would not replace a measurement.
Two things can be checked by arithmetic.

- Load capacitance: C1 and C2 (22 pF) in series make 11 pF. Adding the stray capacitance of the board and pins puts it within the crystal's specification (around 18–22 pF)
- DC at the input of U1A: the current through Rf (1 MΩ) is the input leakage current (a few nA or less), so the voltage at pin 1 settles at the point where the input and output of U1A are equal (about V<sub>CC</sub>/2)

## Sources

Original work.
