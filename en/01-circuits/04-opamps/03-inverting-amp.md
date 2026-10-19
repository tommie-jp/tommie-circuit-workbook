---
book: circuits
chapter: 4
id: 4-3
title: Inverting amplifier
tier: 50
source: 自作
board: BB
ja: 87eaa497fa7d828364d7f93e447645e721df19d6
---

# 4-3 Inverting amplifier

The signal enters the − input through a resistor (Rin), and a second resistor (Rf) feeds the output back to the same
− input. The non-inverting input (+ input) is tied directly to GND. The gain is −Rf/Rin, so the **sign is inverted**.
This is the third basic op amp circuit. In this exercise you feed in a 1 kHz sine wave and check that the output is 10 times
as large and in the opposite direction.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Inverting amplifier
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 2,3
  V1: sine 3,2 3,4 0.1
  G2: ground 3,4
  Rin: resistor 3,2 6,2 10k
  Rf: resistor 6,1 9,1 100k
  U1: opamp 8,3 +down
  G3: ground 7,4
  OUT: port 10,3
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
wires:
  - mid -- 2,3
  - 6,2 |- U1.-
  - 7,4 |- U1.+
  - 6,2 -- 6,1
  - 9,1 -- 9,3
  - U1.out -- 9,3 -- 10,3
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/circuit/03-inverting-amp.svg)

- VP and VN on the left are the ±5 V supply for the op amp. They are made with V+ and V− of the AD3 Supplies, as in 4-1
- **Tying the + input directly to GND** is the mark of an inverting amplifier. The op amp moves its output until the
  two inputs (+ and −) are at the same voltage, so the − input stays at 0 V even though it is not connected to GND.
  This is called a **virtual ground**
- Rin (10 kΩ) sets the input impedance and Rf (100 kΩ) is the feedback.
  **Gain = −Rf/Rin = −10**
- The − input is at 0 V, so the current through Rin is the input voltage ÷ Rin. No current flows into the op amp
  input, so this same current goes through Rf to the output. The voltage across Rf is current × Rf, so
  output = −input × Rf/Rin

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top rails: +5V (red) and GND (blue). Bottom blue rail: −5V (V−). The bottom red rail is not used
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V, W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 2-, 1-]
  U1: dip8 @ e10 LM358
  Rin: resistor g6 g11 10k
  Rf: resistor i10 i11 100k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a6 yellow
  - SC.1+ -- j6 orange
  - SC.2+ -- j10 green
  - SC.1- -- j15 black
  - SC.2- -- i15 black
  - e6 -- f6 yellow
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - h12 -- h15 black
  - f15 -- e15 black
  - a15 -- -t15 black
notes:
  - text below: Top red +5V, top blue GND, bottom blue −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/03-inverting-amp.svg)

- In Fig. 2, the AD3 Supplies (V+, V−) correspond to VP and VN in Fig. 1, and W1 corresponds to V1 (the signal generator).
  The rails are split as in 4-1 (the bottom blue rail is −5 V, not GND)
- **IN+ (pin 3, column 12) is tied directly to GND.** Three black wires, `h12--h15`, the wire across the gap, and
  `a15--(-t15)`, take it to the top blue rail. No voltage divider is needed
- **Both Rin and Rf meet at IN− (pin 2, column 11).** The W1 signal crosses the gap at column 6 to the lower block
  and enters through Rin (columns 6 to 11). Rf goes from here back to the output (pin 1, column 10)
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (orange) goes to column 6 (`j6`), the input,
  and 2+ (green) goes to column 10 (`j10`), the output. 1− and 2− (black) go to column 15 (`j15`, `i15`), which is connected to GND
- There is no capacitor (DC block). The signal generator swings around 0 V, so a direct connection is fine

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise looks at the amplitude and the direction (inversion) of a 1 kHz sine wave, far lower than 10 MHz.
W1 is the same as in 4-2: 1 kHz, amplitude 0.1 V, offset 0 V. Scope CH1 reads the input (column 6) and CH2 reads the output (column 10).

| Setting | Value |
| --- | --- |
| Wavegen W1 | Sine, 1 kHz, amplitude 0.1 V, offset 0 V |
| Scope CH1 (input, column 6) | DC, 500 mV/div |
| Scope CH2 (output, column 10) | DC, 500 mV/div |
| Time | 200 µs/div |
| Trigger | CH1, rising edge, 0 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 CH2 is 10 times CH1, inverted
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase 180deg, range: 500mV/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/scope/03-inverting-amp.svg)

Both traces in Fig. 3 are at 500 mV/div. CH1 (input) is 0.2 Vpp and CH2 (output) is 2.0 Vpp, ten times as tall.
When the input rises, the output falls, so peaks and troughs are swapped (phase 180°).

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Op amp (one of two in the package) | LM358 |
| Rin | Resistor (input) | 10 kΩ |
| Rf | Resistor (feedback) | 100 kΩ |
| — | Signal source | 1 kHz, amplitude 0.1 V |
| — | Power supply | ±5 V (AD3 Supplies; V+ = +5 V, V− = −5 V) |
| — | Instrument | AD3 W1 (signal source) and Scope 1+/2+ (input and output) |

## Values to check

Measure as in 4-2 (the signal generator is the AD3 W1, Scope CH1 on the input at column 6, CH2 on the output at column 10; Fig. 3). The values in the table are calculated. Gain A = −Rf/Rin.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Output amplitude | 1.0 V | 0.1 V × 10 |
| Phase | 180° from the input (inverted) | Where the name "inverting amplifier" comes from |
| Gain | −10 (20 dB) | −Rf/Rin = −100k/10k |
| Input impedance | 10 kΩ (Rin itself) | Lower than in 4-2 (non-inverting, Rb = 100 kΩ) |

**The input impedance is fixed by Rin.** This is the weak point of the inverting amplifier.
For a signal source that needs a high impedance, use the non-inverting amplifier of 4-2.

## Verification with LTspice

`sim/03-inverting-amp.cir` runs Fig. 1 as a transient analysis (1 kHz, 0.1 V). The op amp is a simple one-pole model
(GBW 1 MHz, SR 0.3 V/µs, the output tops out at V+ − 1.5 V and V− + 0.1 V). It is an **assumption** modeled on the LM358, not a measurement.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Output amplitude | 1.0 V | 1.000 V (2.00 Vpp) | Match |
| Phase | 180° | inverted (the output zero crossing is only 1.7 µs late, a phase lag of 0.6° at 1 kHz) | Match |
| − input (virtual ground) | held at 0 V | ±1.0 mV | Match |
| Input impedance | 10 kΩ | (Rin itself; arithmetic) | As in the text |

## Sources

Original work.

See also: [TI LM358 datasheet](https://www.ti.com/lit/ds/symlink/lm358.pdf), [Inverting amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Inverting_amplifier), [Lessons In Electric Circuits Vol. III, Chapter 8 (Operational amplifiers)](https://www.ibiblio.org/kuphaldt/electricCircuits/Semi/SEMI_8.html)
