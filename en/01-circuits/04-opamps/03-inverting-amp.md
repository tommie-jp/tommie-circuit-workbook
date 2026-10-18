---
book: circuits
chapter: 4
id: 4-3
title: Inverting amplifier
tier: 50
source: 自作
board: BB
ja: 1435a81c82cca105eec2330558aa7bab879365cc
---

# 4-3 Inverting amplifier

The signal enters the − input through a resistor (Rin), and a second resistor (Rf) feeds the output back to the same
− input. The non-inverting input (+ input) is tied directly to GND. The gain is −Rf/Rin, so the **sign is inverted**.
This is the third basic op amp configuration. Here we apply a 1 kHz sine wave and check that the output is 10 times
larger and upside down.

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

- VP and VN on the left are the ±5 V supply for the op amp. They come from V+ and V− of Supplies on the AD3 (same as in 4-1)
- **Tying the + input directly to GND** is what marks an inverting amplifier. The op amp moves its output until the
  + input and the − input are at the same voltage, so the − input stays at 0 V even though it is not connected to GND.
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
    pins: [1+, 2+, 1-, 2-]
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
  - text below: Top red rail = +5V, top blue rail = GND, bottom blue rail = −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/03-inverting-amp.svg)

- In Fig. 2, Supplies (V+, V−) on the AD3 correspond to VP and VN in Fig. 1, and W1 corresponds to V1 (the signal generator).
  The rails are split as in 4-1 (the bottom blue rail is −5 V, not GND)
- **IN+ (PIN 3, column 12) is tied directly to GND.** Three black wires, `h12--h15`, the wire across the center gap, and
  `a15--(-t15)`, take it to the top blue rail. No voltage divider is needed
- **Both Rin and Rf meet at IN− (PIN 2, column 11).** The W1 signal crosses the center gap at column 6 to the lower block
  and enters through Rin (columns 6 to 11). Rf goes from here back to the output (PIN 1, column 10)
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 1+ (orange) goes to column 6 (`j6`), the input,
  and 2+ (green) goes to column 10 (`j10`), the output. 1− and 2− (black) go to column 15 (`j15`, `i15`), which is connected to GND
- There is no capacitor (DC block). The signal generator swings around 0 V, so a direct connection is fine

## Instrument settings

Use the Scope of the AD3 as the oscilloscope. This exercise looks at the amplitude and the direction (inversion) of a 1 kHz sine wave, far below 10 MHz.
W1 is the same as in 4-2: 1 kHz, amplitude 0.1 V, offset 0 V. Scope CH1 reads the input (column 6) and CH2 reads the output (column 10).

| Setting | Value |
| --- | --- |
| Wavegen W1 | Sine, 1 kHz, amplitude 0.1 V, offset 0 V |
| Scope CH1 (input, column 6) | DC, 500 mV/div |
| Scope CH2 (output, column 10) | DC, 500 mV/div |
| Time | 200 µs/div |
| Trigger | CH1, rising, 0 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 In (CH1) and out (CH2), x10 inverted
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
| U1 | Op amp (one half of a dual) | LM358 |
| Rin | Resistor (input) | 10 kΩ |
| Rf | Resistor (feedback) | 100 kΩ |
| — | Signal source | 1 kHz, amplitude 0.1 V |
| — | Power supply | ±5 V (Supplies on the AD3; V+ = +5 V, V− = −5 V) |
| — | Instruments | W1 of the AD3 (signal source), Scope 1+/2+ (input and output) |

## Values to check

Measure as in 4-2 (signal generator is W1 of the AD3, Scope CH1 on the input at column 6, CH2 on the output at column 10; Fig. 3). The values in the table are calculated values. Gain A = −Rf/Rin.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Output amplitude | 1.0 V | 0.1 V × 10 |
| Phase | 180° from the input (inverted) | The origin of the name "inverting amplifier" |
| Gain | −10 (20 dB) | −Rf/Rin = −100k/10k |
| Input impedance | 10 kΩ (Rin itself) | Lower than 4-2 (non-inverting, Rb = 100 kΩ) |

**The input impedance is fixed by Rin.** This is the weakness of the inverting amplifier.
For a signal source that needs a high impedance, use the non-inverting amplifier of 4-2.

## Verification with LTspice

`sim/03-inverting-amp.cir` runs Fig. 1 as a transient analysis (1 kHz, 0.1 V). The op amp is a simple one-pole model
(GBW 1 MHz, SR 0.3 V/µs, output clipped at V+ − 1.5 V and V− + 0.1 V). This is an **assumption** equivalent to an LM358, not a measurement.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Output amplitude | 1.0 V | 1.000 V (2.00 Vpp) | agrees |
| Phase | 180° | Inverted (the output zero crossing is only 1.7 µs late, a phase lag of 0.6° at 1 kHz) | agrees |
| − input (virtual ground) | Held at 0 V | ±1.0 mV | agrees |
| Input impedance | 10 kΩ | (Rin itself; arithmetic) | as in the text |

## Sources

Original work.
