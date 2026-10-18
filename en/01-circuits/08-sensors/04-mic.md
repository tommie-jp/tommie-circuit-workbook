---
book: circuits
chapter: 8
id: 8-4
title: Responding to Sound with a Microphone
tier: 50
source: 自作
board: BB
ja: ee8da19ac68c18d2e25d1283a5e54c583e6af174
---

# 8-4 Responding to Sound with a Microphone

This exercise builds a circuit in which the brightness of an LED wavers in response to sound.
An electret condenser microphone (ECM) turns the vibration of air caused by sound into a very small voltage change
(a few mV). That is too small to see as it is, so the signal goes through a one-transistor amplifier (the common
emitter from 2-3), and the sound becomes visible as wavering brightness of an LED.
In the second half, instead of the microphone, the signal generator of the Analog Discovery feeds in a signal of a
fixed size, and the oscilloscope checks the gain of the amplifier.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 The LED wavers with the sound of the mic
parts:
  VCC: vcc 2,2 5V
  R1: resistor 2,2 2,4 2.2k
  MK1: mic 2,4 2,6 l=$\mathrm{MK1}$
  G1: ground 2,6
  C1: capacitor 2,4 4,4 1u
  VCC: vcc 4,2 5V
  R2: resistor 4,2 4,4 100k
  Q1: npn 6,6 2SC1815
  VCC: vcc 6,2 5V
  R3: resistor 6,2 6,4 220
  D1: led 6,4 6,5
  G2: ground 6,7
wires:
  - 4,4 |- Q1.B
  - 6,5 -- Q1.C
  - Q1.E -- 6,7
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/04-mic-1.svg)

- An ECM contains a small amplifying element (a FET) and needs a DC current (bias current) to work. MK1 (the
  microphone) takes its bias current from the supply through R1 (2.2 kΩ). This is the most common way to use an ECM.
  The output of the microphone (a small AC voltage that follows the vibration of the sound) passes through C1 (1 µF,
  the coupling capacitor from 2-2) to the next stage, and the DC voltage is stopped by C1
- R2 (100 kΩ) is a fixed-bias resistor that gives the base of Q1 its DC operating point (the current and voltages when
  there is no sound; the simplest way of biasing, with a single resistor passing current from the supply to the
  base). Q1 is an amplifier with the LED (D1) placed directly in the collector. Even with no sound the LED stays
  faintly lit, and when sound arrives its brightness wavers with the vibration
- R3 (220 Ω) limits the current of the LED. How far the collector voltage can swing is also set by R3

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top red rail = +5V, blue rail = GND (carried to the lower rails at columns 29 and 30)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b3 b7 2.2k
  C1: capacitor c7 c12 1u
  R2: resistor b12 b16 100k
  MK1: mic h7 h10
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  D1: led f18(A) f13(K) red
  R3: resistor h18 h22 220
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - +t16 -- a16 red
  - e7 -- f7 yellow
  - j10 -- -b10 black
  - e12 -- f12 green
  - j14 -- -b14 black
  - j22 -- +b22 red
  - -t29 -- -b29 black
  - +t30 -- +b30 red
notes:
  - text: Blow on the microphone or clap your hands and the brightness of the LED wavers
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/04-mic-1.svg)

- Connect V+ (+5 V) and GND of the AD3 to the upper rails, and carry them to the lower rails at the right end
  (columns 29 and 30)
- In the upper block, place R1 (columns 3 to 7), C1 (columns 7 to 12) and R2 (columns 12 to 16). Column 7 is the node
  of the microphone and column 12 is the node of the base of Q1
- Plug the microphone (ECM) into columns 7 and 10 of the lower block, connect column 7 to column 7 of the upper block
  with a yellow wire, and column 10 to the lower − rail.
  Fig. 2 draws it as a two-pin part with no direction, but a real ECM has polarity.
  Check the marking on the terminals at the back, or find the pin joined to the case (the GND side), and plug the GND
  side into column 10
- Q1 (2SC1815) reads E, C, B from the left when you face the flat side. Here it is inserted with the flat side facing
  the back (the f-row side), and B, C, E go into columns 12, 13 and 14 of row h. The base (column 12) goes to column 12
  of the upper block by a green wire, and the emitter (column 14) goes to the lower − rail
- The cathode of D1 is on the collector (column 13), and from the anode of D1 (column 18) a path through R3 (columns 18
  to 22) leads to the lower + rail

## Trying it with the signal generator of the AD (1 kHz) instead of the microphone

Instead of sounding the microphone with your voice or a clap, the signal generator W1 of the Analog Discovery can feed
in a 1 kHz sine wave, so you can "play" a sound of the same size at any time.
You can check the amplification of the circuit and the wavering of the LED again and again with the same signal.

The output of an electret microphone is a few mV to a few tens of mV (RMS) for the loudness of speech.
The output of W1 is too large (a few tens of mV at the least, usually around 1 V), so a divider of 10 kΩ (R<sub>S</sub>)
and 100 Ω (R<sub>D</sub>) lowers it to about 1/100 and feeds it to the node where the microphone was (between R1 and
C1) (Fig. 3). Remove the microphone and leave everything from the coupling capacitor C1 onward as it was.

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 3 W1 replaces the mic (CH2 in, CH1 out)
parts:
  W1: sine 2,4 2,6 l=$\mathrm{W1}$
  G0: ground 2,6
  RS: resistor 2,4 5,4 10k
  VCC: vcc 5,2 5V
  R1: resistor 5,2 5,4 2.2k
  RD: resistor 5,4 5,6 100
  G1: ground 5,6
  M2: voltmeter 6,5 6,7 l=$\mathrm{CH2}$
  G2: ground 6,7
  C1: capacitor 6,4 8,4 1u
  VCC: vcc 8,2 5V
  R2: resistor 8,2 8,4 100k
  Q1: npn 10,6 2SC1815
  VCC: vcc 10,2 5V
  R3: resistor 10,2 10,4 220
  D1: led 10,4 10,5
  G3: ground 10,7
  M1: voltmeter 12,5 12,7 l=$\mathrm{CH1}$
  G4: ground 12,7
wires:
  - 5,4 -- 6,4
  - 6,4 -- 6,5
  - 8,4 |- Q1.B
  - 10,5 -- Q1.C
  - Q1.E -- 10,7
  - 10,5 -- 12,5
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/circuit/04-mic-2.svg)

- W1 is a sine wave of 1 kHz, amplitude 1 V (2 Vpp), offset 0 V. In Wavegen of WaveForms, set W1 to Sine
- The divider ratio is 100 Ω ÷ (10 kΩ + 100 Ω) ≈ 1/101. However, the supply at the other end of R1 (2.2 kΩ) is the
  same as GND as far as AC is concerned (the supply voltage does not waver), so R1 is in parallel with R<sub>D</sub> and
  makes 96 Ω (a ratio of about 1/106). In addition, the input resistance of Q1 beyond C1 (about 160 Ω at 1 kHz) is a
  load: about 0.6 kΩ (= h<sub>FE</sub> × 26 mV / 4.3 mA). Together these bring the AC at the node to about 1/119 of W1,
  16.8 mVpp (about 5.9 mV RMS), the same order as the microphone for speech
- The DC at the node is about 0.2 V, set by the divider of R1 and R<sub>D</sub>. C1 blocks it, so it does not affect the
  bias of Q1. About 2 mA flows from the supply through R<sub>D</sub>, but V+ has plenty of margin
- Put CH2 (2+) on the node and CH1 (1+) on the collector of Q1 (the cathode side of the LED), with 2− and 1− on GND.
  CH1 has the swing on top of 2.1 V DC. The input pins on the AD3 itself are DC-coupled only, so cancel the DC with
  **Offset** of the CH in WaveForms. With Offset at −2.1 V, the 2.1 V moves to the center of the screen, and only the
  swing is magnified on a fine scale.
  Procedure: in the CH1 settings of Scope, set Range to 200 mV/div and Offset to −2.1 V.
  The node of CH2 has 16.8 mVpp on top of about 0.2 V DC, so set Range to 5 mV/div and Offset to −0.2 V.
  The DC values differ a little between parts, so if the wave drifts from the center, set Offset again to the DC value
  you read with the multimeter
  (at 0.5 V/div and finer scales, Offset can move only within ±2.5 V; the DC in this exercise is inside that range)

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 4 Mic removed, W1 fed through a 10 kΩ and 100 Ω divider
# V+ (5 V) of the AD goes to the lower + rail and GND to the lower − rail, carried to the upper rails at columns 29 and 30
board: half
parts:
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, W1, 2+, 2-, 1+, 1-]
  R1: resistor b3 b7 2.2k
  C1: capacitor c7 c12 1u
  R2: resistor b12 b16 100k
  RS: resistor i3 i7 10k
  RD: resistor h7 h10 100
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  D1: led f18(A) f13(K) red
  R3: resistor h18 h22 220
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - AD.W1 -- j3 yellow
  - AD.2+ -- j7 blue
  - AD.2- -- -b8 black
  - AD.1+ -- j13 orange
  - AD.1- -- -b15 black
  - +t3 -- a3 red
  - +t16 -- a16 red
  - e7 -- f7 yellow
  - j10 -- -b10 black
  - e12 -- f12 green
  - j14 -- -b14 black
  - j22 -- +b22 red
  - -t29 -- -b29 black
  - +t30 -- +b30 red
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/breadboard/04-mic-2.svg)

Pull the microphone MK1 out of Fig. 2 and plug R<sub>D</sub> (100 Ω) into its columns 7 and 10. The black wire from column 10
to the lower − rail is used as it is. The other parts stay as in Fig. 2. For the supply, use V+ (5 V) of the Analog
Discovery instead of the supply of Fig. 2. Place the Analog Discovery below the breadboard, and plug its wires into the
lower rails and row j.

- W1 (yellow): to `j3`. It passes through R<sub>S</sub> (10 kΩ, `i3` to `i7`) and joins the input node (column 7 of the
  lower block)
- Column 7 holds the yellow wire to column 7 of the upper block (`f7`), R<sub>D</sub> (`h7`), the right lead of
  R<sub>S</sub> (`i7`) and 2+ of CH2 (blue, `j7`) (one pin per hole)
- 1+ of CH1 (orange): `j13`, on the collector of Q1 (column 13)
- V+ of the AD goes to the lower + rail (red), and GND, 2− and 1− go to the lower − rail (black). The upper and lower
  rails are joined at columns 29 and 30 at the right end

Set V+ to 5 V in Supplies of WaveForms, then turn W1 on.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 5 Input (CH2) and output (CH1), inverted
time: 200us/div
trigger: ch2 rising 0.2V
ch1: {wave: sine 1kHz 0.50Vpp phase 193deg offset 2.1V, range: 200mV/div, position: -10.5div}
ch2: {wave: sine 1kHz 16.8mVpp offset 0.2V, range: 5mV/div, position: -40div}
measure: [vpp, freq, avg]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/08-sensors/scope/04-mic.svg)

CH2 (the node) is a 1 kHz sine wave of about 16.8 mVpp and CH1 (the collector) one of about 0.50 Vpp. The gain (output
amplitude ÷ input amplitude) is about 30 (h<sub>FE</sub> = 100, collector current 4.3 mA; the LTspice value, which is
g<sub>m</sub> × 233 Ω ≈ 38 times the division 0.78 by the 160 Ω of C1 and r<sub>π</sub>, r<sub>bb′</sub>). The output is
nearly inverted: when CH1 is at a trough, CH2 is at a peak (they are about 13° off because of C1 and the input
resistance).
At 1 kHz the wavering of the LED is too fast to see, and it looks almost steadily lit.
The swing of the collector is about 0.25 V (amplitude), the same order as the estimate for a hand clap in the table
below (about 0.2 V).
If you lower the amplitude of W1, the output shrinks in proportion.
The center of the screen is the DC level cancelled by Offset, and Avg in Measurements shows the DC values, 2.10 V (CH1)
and 200 mV (CH2).

## Instrument settings

The instrument is the Analog Discovery 3 (AD3). One unit supplies the power (V+ of Supplies = 5 V), the signal source
(W1 of Wavegen) and the oscilloscope (1 and 2 of Scope), and the waveform is in the audio band, below 10 MHz, so Scope
can show it. The current drawn is about 7 mA in total: about 4.3 mA for the LED, about 2 mA in the divider and about
0.3 mA for the bias of the microphone. This is within the roughly 50 mA of one supply channel and within the 200 mA per
hole of the breadboard.

| Instrument | Setting |
| --- | --- |
| Supplies | V+ = 5 V, output ON |
| Wavegen W1 | Sine, 1 kHz, amplitude 1 V (2 Vpp), offset 0 V |
| Scope CH1 (1+ on the collector, 1− on GND) | 200 mV/div, Offset −2.1 V (cancels the DC), time base 200 µs/div |
| Scope CH2 (2+ on the node, 2− on GND) | 5 mV/div, Offset −0.2 V. Trigger on a rising edge of CH2 at 0.2 V (the middle of the wave) |

Fig. 5 is the waveform you see with these settings.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| MK1 | Electret condenser microphone | — |
| R1 | Resistor (bias of the microphone) | 2.2 kΩ |
| C1 | Electrolytic capacitor (coupling) | 1 µF |
| R2 | Resistor (base bias) | 100 kΩ |
| Q1 | NPN transistor | 2SC1815 |
| R3 | Resistor (LED current) | 220 Ω |
| RS | Resistor (divider for W1, for testing in place of the microphone) | 10 kΩ |
| RD | Resistor (divider for W1, for testing in place of the microphone) | 100 Ω |
| D1 | LED (red) | V<sub>F</sub> ≈ 2.0 V |
| — | Signal generator, power supply, oscilloscope | Analog Discovery 3 (W1, V+ = 5 V, 1 and 2 of Scope). V+ also supplies Fig. 2 |

## Values to check

The values in the table are calculated values. h<sub>FE</sub> = 100 is assumed (the h<sub>FE</sub> of a real 2SC1815 varies
widely, so if the LED stays much too bright, make R2 larger, and if it is too dim, make it smaller).
Measure DC voltages on the multimeter's DC voltage range, and view the AC on the oscilloscope as in Fig. 5 (Offset
cancels the DC).

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Base current of Q1 | about 43 µA (= (5 − 0.7) / 100 kΩ) | Set by R2 |
| Collector current of Q1 (no sound) | about 4.3 mA | The LED faintly lit is the operating point |
| Collector-emitter voltage of Q1 (no sound) | about 2.1 V (= 5 − 2.0 − 4.3 mA × 220 Ω) | There is room to swing up and down with the signal |
| Input node (CH2) with W1 at 1 kHz, 2 Vpp (in place of the microphone) | about 16.8 mVpp | About 1/119 because of the divider and the load of the input resistance of Q1 |
| Collector of Q1 (CH1) at the same time | about 0.50 Vpp, nearly inverted (gain about 30) | Calculated value for h<sub>FE</sub> = 100 |
| Voltage swing of the LED for a hand clap (approximate) | about 0.2 V (amplitude) | An estimate assuming a microphone sensitivity of −44 dBV/Pa (about 6.3 mV for a sound pressure of 1 Pa) |

The bias current of the microphone (R1 = 2.2 kΩ) assumes a typical ECM value (about 0.3 mA).
If you have the datasheet of the real part, choose R1 again from its value.

## Verification with LTspice

`sim/04-mic.cir` runs a transient analysis with W1 (1 kHz, 2 Vpp) fed in as in Fig. 3. Q1 is a substitute model fitted
to h<sub>FE</sub> = 100, and the LED is the same assumed model as in 1-1 (not measured).

| Item | Number in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Base current of Q1 | about 43 µA | 43.2 µA | agrees |
| Collector current of Q1 (no sound) | about 4.3 mA | 4.26 mA | agrees |
| Collector-emitter voltage of Q1 (no sound) | about 2.1 V | 2.10 V | agrees |
| Input node (CH2) | about 16.8 mVpp | 16.8 mVpp | agrees |
| Collector (CH1) | about 0.50 Vpp, gain about 30 | 0.50 Vpp (29.7 times), phase 193° | corrected (it first said 0.62 Vpp and 38 times) |

The first figure of 38 times was g<sub>m</sub> × (R3 + the operating resistance of the LED) = 0.164 S × 233 Ω, without the
division (about 0.78) by C1, which is 160 Ω at 1 kHz, and the input of Q1 (r<sub>π</sub> about 0.6 kΩ). The text, Fig. 5
and the table were corrected to this value.

## Sources

Original work.
