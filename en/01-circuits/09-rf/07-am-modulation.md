---
book: circuits
chapter: 9
id: 9-7
title: AM Modulation — Swinging a 555 Carrier with Audio
tier: 50
source: 自作
board: BB
ja: 5c7066d2224976a6451c7e2febb1ad0100b9e06e
---

# 9-7 AM Modulation — Swinging a 555 Carrier with Audio

**AM (amplitude modulation)** moves **only the amplitude** of a carrier of fixed frequency up and down with the loudness of the audio.
The H level of the 555 output is the supply voltage itself, so **mixing audio into the supply of the 555** makes the amplitude of the output swing with the audio. This gives an AM modulator whose working is easy to see.
You make the AM waves that the radios of 9-2 to 9-5 received, listen to them on a radio and look at the waveforms on the oscilloscope.
The voltage divider in the audio path and the sidebands seen on a spectrum analyzer are split off into 9-29.

> [!WARNING]
> Keep the experiment to passing the output to a nearby AM radio through a very small coupling capacitor (Cant) and a
> short wire loop. As in 9-4, stay within the **feeble radio station** limits of the Japanese Radio Act (322 MHz
> or less, field strength 500 µV/m or less at a distance of 3 m, Article 6 of the Ordinance for Enforcement of the Radio Act):
> **do not lengthen the wire loop and do not add an amplifier after it**.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 AM modulation by mixing audio into the 555 supply
parts:
  V1: sine 2,3 2,5 0.5
  GV1: ground 2,5
  Cmod: capacitor 2,3 4,3 1u
  VCC: vcc 8,1 5V
  Rmod: resistor 8,1 8,3 220
  U555: ic 10,7 TLC555
  GU555: ground 10,10.5
  R1: resistor 6,3 6,5 1k
  R2: resistor 6,6.5 6,8.5 10k
  C1: capacitor 8,8.5 8,10.5 100p
  GC1: ground 8,10.5
  Cant: capacitor 14,7 16,7 100p
  ANT: port 17,7
wires:
  - 4,3 -- 10.5,3
  - U555.VDD |- 10,3
  - U555.RESET |- 10.5,3
  - 6,5 -- 6,6.5
  - U555.DISCH -| 6,6.5
  - U555.THRES -| 8,7
  - U555.TRIG -| 8,7.5
  - 8,7 -- 8,8.5
  - 6,8.5 -- 8,8.5
  - U555.GND |- 10,10.5
  - U555.OUT -| 14,7
  - 16,7 -- 17,7
notes:
  # Measuring points. Oscilloscope in orange, spectrum analyzer in green (same names as the instrument settings table)
  - arrow 1,2 2,3 orange
  - text 1,1.7 small orange left: audio
  - arrow 9.5,2.5 9.5,3 orange
  - text 9.5,2.2 small orange center: PIN 8
  - arrow 12,5.5 12,7 orange
  - text 12,5.2 small orange center: PIN 3
  - arrow 17,8.5 17,7 orange
  - text 17,8.7 small orange right: ANT
  - arrow 12,9 10,9 orange
  - text 12,9 small orange left: scope GND
  - arrow 13.5,5.5 13.5,7 green
  - text 13.5,5.2 small green center: analyzer in
  - arrow 12,9.7 10,9.7 green
  - text 12,9.7 small green left: analyzer GND
style:
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/07-am-modulation.svg)

- **Carrier**: a 555 astable with R1 (1 kΩ), R2 (10 kΩ) and C1 (100 pF).
  f = 1.44/((R1+2R2)C) = 1.44/((1k+20k)×100p) **≈ 686 kHz**, inside the
  Japanese AM broadcast band (531 kHz to 1602 kHz)
- **Modulation**: V1 (a signal generator, 1 kHz sine wave) is mixed into the supply pin of the 555 (PIN 8) through Rmod (220 Ω) and Cmod (1 µF).
  The output H is "the supply voltage at that moment", so the amplitude swings with the audio
- **Why the CMOS version (TLC555)**: the NE555 (bipolar) works down to about 4.5 V, the TLC555 down to 2 V.
  When the modulation is deep and the supply voltage drops for a moment, the oscillation is less likely to stop
- Rmod feeds the DC. Cmod is a coupling capacitor that passes only the AC part of the audio to PIN 8. The **modulation depth** is set by the amplitude of the audio ÷ the DC voltage
  at PIN 8 (about 4.4 V, item below). Too deep and the waveform is squashed and distorted
- **Assumed audio source (V1)**: the function generator of 0-6 (50 Ω output) set to a **1 kHz sine wave,
  amplitude 0.5 V** (the value the generator displays). 1 kHz is inside the audio bandwidth an AM radio passes (up to a few kHz). The swing that reaches PIN 8 is **0.70 times** V1 (0.5 V → about 0.35 V). The calculation of the divider made by the generator's 50 Ω, Cmod and Rmod, and the conditions for using
  a smartphone or a microphone amplifier as the audio source, are in 9-29
- **DC drop across Rmod** (estimate of the DC at PIN 8): three currents flow into PIN 8.
  (1) While PIN 7 is L (about 48 % of the period), current flows through R1 to GND.
  The L voltage of PIN 7 is small, 0.06 V at 10 mA (typ, 5 V), so
  (4.5 V − 0.05 V)/1 kΩ ≈ **4.4 mA** flows for 48 % of the time (2.1 mA on average).
  (2) While PIN 7 is open, current charges C1 through R1 and R2, about 0.1 mA on average.
  (3) The supply current of the IC itself, typ 180 µA at 5 V (max 350 µA).
  The total is **about 2.4 mA** on average (about 4.7 mA at the peaks of the pulses). Rmod (220 Ω) drops 0.53 V, so
  **the DC at PIN 8 is about 4.5 V** (a rough guide solved in python3 with the 555 as ideal comparators. The shoot-through current and spread of a real part change it).
  The figures and tables are drawn with **4.4 V** for margin. This is the height of the carrier's H and the denominator of the modulation depth. Once it is built, measure PIN 8 with a multimeter on DC
- **ANT is a wire loop** (weak coupling through Cant). The carrier is a square wave, so the sound heard on the radio is distorted

### Verification with LTspice

The audio path (V1 → Cmod → PIN 8) was checked with an AC analysis of `sim/07-am-modulation.cir`. The table is in 9-29.
The swing at PIN 8 is 0.351 V (0.335 V with the current drawn by the 555 included), which agrees with the 0.35 V in the text.

For the carrier 555, the ideal TLC555 model of LTspice (thresholds at 1/3 and 2/3 of the supply) asked for very fine time steps and did not finish,
so the same equations were solved in python (L of PIN 7 = 6 Ω, R1, R2 and C1 as in the text). t<sub>H</sub> = 0.76 µs, t<sub>L</sub> = 0.70 µs (the text has the ideal 0.69 µs),
frequency 682.5 kHz (the formula in the text gives 686 kHz), duty 52.0 %. **Changing the supply voltage (4.05 to 5 V) leaves the frequency and duty the same**. Only the amplitude (height of H) is proportional to the supply, which agrees with how AM works in the text.
The swing at ANT is 0.87 times (+1.84 / −1.99 V), which agrees with the text. Verdict: agrees (the text is not changed).
The DC at PIN 8 (about 4.4 to 4.5 V) depends on the shoot-through current and other properties of the real part, so it is out of scope. Reception on a radio is also out of scope.

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on a breadboard
board: half
parts:
  GEN:
    type: device
    at: top
    label: Signal generator 1kHz 0.5V
    pins: [GND, OUT]
  ANT:
    type: device
    at: bottom
    label: Wire loop
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - ANT.1 -- j27 yellow
  - -t30 -- -b30 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/breadboard/07-am-modulation-1.svg)

- The top red rail is +5 V (USB or a battery) and the blue rail is GND. Column 30 links the top and bottom − rails
- U555 sits across the gap in columns 20 to 23 (pin 1 is f20, at the lower left). Column 16 is the net of the 555 supply (a wire in row a from PIN 8, a wire in row g from PIN 4). It is fed from +5 V through Rmod,
  and from the generator (GEN) through Cmod
- R1 is between PIN 7 (column 21) and column 16, R2 between PIN 7 and column 25. PIN 6 (the wire in row c) and PIN 2
  (the wire in row h) are joined at column 25, and C1 goes from there to GND
- The wire loop leaves PIN 3 (column 22) through Cant at column 27 (bottom, j27)
- PIN 1 (column 20) goes out to column 13 with a wire in row h and then to the bottom − rail (row j is kept free for the instruments)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U555 | CMOS timer IC | TLC555 (the bipolar NE555 works only down to 4.5 V, so it cannot be used) |
| R1 | resistor | 1 kΩ |
| R2 | resistor | 10 kΩ |
| C1 | ceramic capacitor (time constant) | 100 pF |
| Rmod | resistor (feeds the 555 supply) | 220 Ω |
| Cmod | ceramic capacitor (audio coupling) | 1 µF |
| Cant | ceramic capacitor (antenna coupling) | 100 pF |
| — | wire loop | a short wire (do not lengthen it) |
| — | signal source (V1) | signal generator (the function generator of 0-6). 1 kHz sine wave, amplitude 0.5 V (displayed value), 50 Ω output |
| — | power supply | 5 V (USB or a battery) |

## Instrument settings

Use an oscilloscope (2 channels), with ground on the − rail. The spectrum analyzer is in 9-29.

| Item | Setting |
| --- | --- |
| Probes | both 10:1. The three points to measure are below. Move the probes for each figure |
| PIN 3 (carrier) | free hole in column 22 (j22). DC coupling |
| ANT (far side of Cant) | free hole in column 27 (j27. Move the wire loop to j28 with a wire from g27 to g28). DC coupling |
| PIN 8 (555 supply) | free hole in column 16 (j16). AC coupling, to see only the swing from the audio |
| Viewing the carrier (Fig. 4) | CH1 PIN 3 (2 V/div), CH2 ANT (1 V/div). 0.5 µs/div, trigger on the rising edge of CH1 |
| Comparing the peak and trough of the envelope (Fig. 5) | PIN 3 at 1 V/div, position −2.5 div (0 V at 1.5 div from the bottom), 0.5 µs/div. Keep the wave at the peak as a Reference and overlay the wave at the trough |
| Viewing the modulation envelope | CH1 PIN 3 (1 V/div), CH2 PIN 8. 200 µs/div, trigger on the rising edge of CH2 (audio) |

- Do not put a probe on PIN 2 or PIN 6 (column 25). The capacitance of the probe (10 to 15 pF) adds
  to C1 (100 pF) and lowers the carrier frequency by about 10 %

### Connecting the oscilloscope

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 3 Connecting the oscilloscope (PIN 3 and ANT)
board: half
parts:
  GEN:
    type: device
    at: top
    label: Signal generator 1kHz 0.5V
    pins: [GND, OUT]
  SCOPE:
    type: device
    at: bottom
    label: Oscilloscope
    pins: [GND, CH1, CH2]
  ANT:
    type: device
    at: bottom
    label: Wire loop
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - g27 -- g28 yellow
  - ANT.1 -- j28 yellow
  - -t30 -- -b30 black
  - SCOPE.CH1 -- j22 purple
  - SCOPE.CH2 -- j27 pink
  - SCOPE.GND -- -b17 black
notes:
  - circle j22
  - circle j27
  - circle -b17
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/breadboard/07-am-modulation-2.svg)

- The red circles mark the probes and the GND clip (bottom − rail). The figure shows PIN 3 (CH1) and ANT (CH2) being viewed (Fig. 4)
- Move the wire loop to j28 and put CH2 on the freed j27 (so that the probe wire and the wire loop do not touch)
- To view the modulation envelope, move CH2 to j16 (PIN 8)

## Values to check

Calculated values. VCC = 5 V (USB or a battery), and V1 is a generator with a 50 Ω output. The DC at PIN 8 is about 4.4 V because of the drop across Rmod (item under the schematic).

| What to check | Expected value |
| --- | --- |
| Carrier frequency (unmodulated) | f ≈ 686 kHz (calculated value) |
| Set V1 to a 1 kHz sine wave, amplitude 0.5 V | a 1 kHz tone is heard from a nearby AM radio (tuned near 686 kHz) |
| Set the amplitude of V1 to 2 V | modulation depth about 32% (swing at PIN 8 about 1.4 V ÷ 4.4 V, calculated value). The sound is 4 times that at 0.5 V (+12 dB), and the distortion is not yet noticeable |
| Raise the amplitude of V1 above 3.4 V | the trough at PIN 8 (4.4 V − 2.4 V) falls below the lowest operating voltage of the TLC555 (2 V), the oscillation breaks off at every trough and the sound is badly distorted (a rough guide to too deep a modulation: modulation depth about 55% or more, calculated value). With a 0 Ω generator it starts at 3.0 V (V1 then supplies about 11 mA. The Wavegen of the Analog Discovery 3 can supply up to 30 mA) |
| Remove V1 | only the unmodulated carrier remains, and the radio gives a flat hiss (mixed with the harmonics of the square wave) |

### Viewing on the oscilloscope

Calculated values. t<sub>H</sub> = 0.693(R1+R2)C ≈ 0.76 µs, t<sub>L</sub> = 0.693·R2·C ≈ 0.69 µs.
The dashed figures are the calculated "expected screens". First remove V1 and look at the carrier and ANT.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 4 Unmodulated carrier, PIN 3 (CH1) and ANT (CH2)
time: 0.5us/div
trigger: ch1 rising 2.2V
ch1: {wave: square 686kHz 2.2V offset 2.2V duty 52%, range: 2V/div, position: 0.5div}
ch2: {wave: ch1 | gain 0.87 | offset -1.99V, range: 1V/div, position: -2div}
measure: [vpp, vmax, vmin, freq, duty]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/07-am-modulation-1.svg)

- PIN 3 (CH1) is a 0 to 4.4 V square wave. The height of H is the voltage at PIN 8 itself
- ANT (CH2) has its DC cut by Cant and **swings about 0 V** (+1.84 to −1.99 V). The average becomes 0 V,
  so with a duty of 52 % the H side is the lower one. The amplitude is 0.87 times that of PIN 3 (4.4 → 3.83 Vpp),
  from the divider of Cant (100 pF) and the capacitance of the probe (about 15 pF): 100/(100+15) ≈ 0.87

Next set V1 to 1 kHz, 0.5 V and look at the modulated PIN 3. At 200 µs/div one period of the carrier (1.46 µs) is too fine
to see one by one, and **the envelope formed by the tops of H** looks like a band swinging at the same 1 kHz as PIN 8
(this screen cannot be drawn with the scope figure, so check it with the values in the table below).
Spread the peak and trough of the envelope to 0.5 µs/div and compare them.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 5 PIN 3 at envelope peak (CH1) and trough (CH2)
time: 0.5us/div
trigger: ch1 rising 2V
ch1: {wave: square 686kHz 2.375V offset 2.375V duty 52%, range: 1V/div, position: -2.5div}
ch2: {wave: square 686kHz 2.025V offset 2.025V duty 52%, range: 1V/div, position: -2.5div}
measure: [vmax, freq, period]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/scope/07-am-modulation-2.svg)

- CH2 in the figure is the second capture (the trough), taken after the wave at the peak was kept as a Reference. One probe, on PIN 3
- **Only the heights (4.75 V and 4.05 V) differ. The period is the same 1.458 µs**. When the supply swings,
  the frequency does not move and only the amplitude does. This is AM

| What to check | Expected value |
| --- | --- |
| Unmodulated PIN 3 (CH1, 0.5 µs/div) | square wave. Period ≈ 1.46 µs (686 kHz), H ≈ 4.4 V (the voltage at PIN 8. Lower than 5 V by the drop across Rmod), duty ≈ 52 % |
| Unmodulated ANT (CH2) | square wave centered on 0 V, +1.84 to −1.99 V (3.83 Vpp, Fig. 4) |
| PIN 8 (CH2) with V1 at 1 kHz, 0.5 V | 1 kHz sine wave, amplitude about 0.35 V (0.5 V × 0.70). A fine 686 kHz ripple of about 0.2 V rides on it (9-29) |
| PIN 3 at that time (CH1, 200 µs/div) | the tops of H of the square wave swing between about 4.05 and 4.75 V at 1 kHz (the envelope). L stays at 0 V. Modulation depth m = (4.75 − 4.05)/(4.75 + 4.05) ≈ 8 % |
| Measure the carrier period with cursors at the peak and at the trough of the envelope | both ≈ 1.46 µs (the thresholds are proportional to the supply voltage, so the frequency does not move) |

## Sources

Original work. The technical standard for feeble radio stations under the Radio Act is from Article 6 of the Ordinance for Enforcement of the Radio Act (Ministry of Internal Affairs and Communications, Japan).
The supply voltage range of the TLC555 (2 to 15 V), the supply current at 5 V (typ 180 µA) and the L voltage of PIN 7 (0.06 V at 10 mA) are from
[the Texas Instruments TLC555 datasheet (SLFS043K)](https://www.ti.com/lit/ds/symlink/tlc555.pdf).
The 50 Ω output resistance of the function generator is the same assumption as in 9-1, and the output current of the Wavegen of the
Analog Discovery 3 (30 mA) is from the Digilent specifications.
