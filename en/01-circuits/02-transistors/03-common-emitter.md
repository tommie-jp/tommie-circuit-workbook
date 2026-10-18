---
book: circuits
chapter: 2
id: 2-3
title: Common-Emitter Amplifier (Self-Bias)
tier: 50
source: 自作
board: BB
ja: 7c95b6b9b1074da7938e04ac38599bffacbc4dbd
---

# 2-3 Common-Emitter Amplifier (Self-Bias)

This is the basic one-stage amplifier that makes a small AC voltage larger with a common emitter (the form from 2-1,
with the emitter on the GND side). The collector resistor turns the change in collector current into a change in
voltage, and the output comes out large and **inverted**. In this exercise you feed in a 10 mVpp sine wave and
confirm on the oscilloscope that it comes out about 79 times larger and in the opposite direction.

To amplify, the transistor must carry a suitable DC current even when there is no signal. The pair of DC voltage and
current is called the **operating point**, and setting the operating point is called biasing. In this circuit the
`R1`/`R2` voltage divider sets the base voltage, and the resistor `RE` in the emitter keeps the operating point from
moving even when hFE varies from one transistor to another (self-bias). When the collector current tries to
increase, the voltage across `RE` rises, the base-emitter voltage falls, and the current is pulled back.
Because a voltage divider sets the base, 2-8 calls this form divider bias and compares it with other methods.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Self-bias common emitter (W1 in, compare CH2 and CH1)
parts:
  VCC: vcc 6,2 5V
  R1: resistor 6,2 6,5 20k
  R2: resistor 6,5 6,7 10k
  G2: ground 6,7
  RC: resistor 8,2 8,4 2.2k
  Q1: npn 8,5
  CIN: capacitor 6,5 4,5 1u
  W1: sine 2,5 2,7 l=$\mathrm{W1}$
  M2: voltmeter 4,5 4,7 l=$\mathrm{CH2}$
  G4: ground 4,7
  RE: resistor 8,7 8,9 1k
  G3: ground 8,9
  CE: capacitor 10,7 10,9 100u
  COUT: capacitor 9,4 11,4 1u
  OUT: port 11,4
  M1: voltmeter 12,4 12,6 l=$\mathrm{CH1}$
  G5: ground 12,6
wires:
  - 6,2 -- 8,2
  - 2,5 -- 4,5
  - 2,7 -- 4,7
  - 11,4 -- 12,4
  - 6,5 -- Q1.B
  - 8,4 -- Q1.C
  - 8,4 -- 9,4
  - Q1.E -- 8,7
  - 8,7 -- 10,7
  - 8,9 -- 10,9
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/03-common-emitter.svg)

The `+5V` in Fig. 1 is the supply output V+ of the Analog Discovery (set it to 5 V in Supplies in WaveForms).
The input goes from W1 to `CIN`, and CH2 reads the input while CH1 reads the output. `RE` (the emitter resistor)
stabilizes the operating point, and `CE` (the bypass capacitor) lets only the AC bypass `RE` so that the gain is at its
maximum. The `R1`/`R2` voltage divider sets the operating point.

With the values commonly used for a 9 V supply (R1 = 47 kΩ), a 5 V supply would pull Vb down by almost 0.9 V and leave
only about 0.2 V at Ve, so the operating point would swing widely with the spread in hFE.
Therefore **R1 was lowered to 20 kΩ** to restore the open-circuit voltage of the divider.

- Open-circuit voltage of the divider: 5 V × 10k/30k ≈ **1.67 V** (the divider current of 167 µA is much larger than
  the base current, so this approximation is fine)
- The base current (about 6 µA, assuming hFE = 150) flows through the equivalent internal resistance of the divider
  (20k ∥ 10k ≈ 6.7 kΩ) and lowers the voltage by that much, so the actual Vb ≈ **1.63 V**
- Ve = Vb − 0.7 ≈ **0.93 V**, Ie = Ve / RE ≈ **0.93 mA**
- Vc = 5 − Ic×RC ≈ 5 − 0.93m×2.2k ≈ **2.95 V**, Vce ≈ **2.0 V** (active region, seen in 2-2)
- Voltage gain (with CE as the bypass): Av = −gm×RC. gm is how much the collector current changes when the
  base-emitter voltage changes by 1 V (the transconductance): gm = Ic / 26 mV (26 mV is the thermal voltage seen in 2-2) ≈ 35.8 mA/V
  → Av ≈ −35.8m × 2.2k ≈ **−79 times** (it **inverts**. Input 10 mVpp → output
  about 790 mVpp, calculated value)
- With CE removed (`RE` now acts), Av ≈ −RC/RE = −2.2k/1k ≈ **−2.2 times**.
  This comparison shows the effect of the bypass clearly

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Self-bias common emitter (W1 and CH2 to the input, CH1 to the output)
# 5V goes from V+ of the AD to the top + rail; top − rail = GND (the bottom rails are not used)
board: half
parts:
  R1: resistor b3 b9 20k
  R2: resistor c9 c13 10k
  RC: resistor b15 b20 2.2k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815
  CIN: capacitor d5(-) d9(+) 1uF
  RE: resistor a21 -t21 1k
  CE: capacitor/electrolytic b21(+) b26(-) 100uF
  COUT: capacitor d20(+) d27(-) 1uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2+, W1, 2-, 1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.2- -- -t7 black
  - AD.1+ -- a27 orange
  - AD.1- -- -t28 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a26 -- -t26 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/03-common-emitter-1.svg)

As in Fig. 2, the 5 V goes from the supply output V+ (red) of the Analog Discovery to the top + rail
(set V+ to 5 V in Supplies in WaveForms). This circuit draws only about 1 mA, so V+ is enough.

- **Q1 is in the upper block** (`e19` B, `e20` C, `e21` E). No wire has to cross the center trench
- **Base (column 9)**: the bottom end of `R1`, the top end of `R2` and the + side of `CIN` are in the same column. One orange wire (`e9`–`d19`) goes to B of Q1
- **Collector (column 20)**: the bottom end of `RC` and the + side of `COUT` are in the same column as C of Q1
- **Emitter (column 21)**: `RE` is inserted vertically down to the − rail, and the + side of `CE` is in the same column
- **Input (column 5)**: the − side of `CIN`. Plug W1 (yellow) into `a5` and 2+ of CH2 (blue) into `a4`, and
  carry it across with `e4`–`e5`
- **Output (column 27)**: the − side of `COUT`. Plug 1+ of CH1 (orange) into `a27`
- GND, 2− and 1− of the AD (black) go to the top − rail

## Viewing on the oscilloscope

Set W1 to a 1 kHz, 10 mVpp sine wave. Put CH2 (input) at 2 mV/div and CH1 (output) at 200 mV/div
side by side (the scales differ by a factor of 100, so on the screen the input at 5 divisions and the output at
4 divisions look about the same height).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Input (CH2) and output (CH1), 79 times, opposite phase
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 790mVpp phase -180deg, range: 200mV/div}
ch2: {wave: sine 1kHz 10mVpp, range: 2mV/div}
measure: [vpp, freq, phase]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/03-common-emitter.svg)

In Fig. 3, CH1 is about 790 mVpp, about 79 times CH2 (10 mVpp). CH1 has a trough where CH2 has a peak (phase 180°)
— it is plain to see that this is an inverting amplifier. 10 mVpp is a small setting for W1 of the AD, so if the
waveform looks finely disturbed, use Average.

## Frequency response on the VNA

Instead of W1, CH1 and CH2 of the AD, connect a VNA (this book's standard is the LiteVNA64) (Fig. 4) and look at the
transmission (S21) from 50 kHz to 100 MHz (Fig. 5).
How to read S21, S11 and the Smith chart, and the THRU calibration, are the same as in 2-2.

- Connect CH0 (through an attenuator) to the − side of `CIN` (input, column 5) and
  CH1 to the − side of `COUT` (output, column 27) (Fig. 4). Use SMA-to-clip cables for the breadboard and plug **the center conductor and
  the shield as a pair**. Put the shield in the − rail right next to the signal hole and keep the wires as short as possible (a long GND
  return distorts the response from around 10 MHz)
- The VNA output is lower than 0 dBm (1 mW) but varies with model and frequency (0-3 of the NanoVNA book).
  Taking −7 dBm as a rough guide, that is 0.28 Vpp into 50 Ω, which is too large for this circuit. The input of an
  amplifier with a gain of 79 should stay within a few mV. **Stack two 20 dB SMA attenuators (40 dB in total) on CH0
  and calibrate THRU with them attached** (the attenuators drop out in the calibration). With 40 dB the amplitude at the base is
  about 6 mVpp (with one 20 dB attenuator it is about 55 mVpp, the collector current saturates and the waveform is crushed)
- The power supply is the V+ (5 V) of the AD as before

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 4 Connecting the VNA (center conductor and shield as a pair)
board: half
parts:
  R1: resistor b3 b9 20k
  R2: resistor c9 c13 10k
  RC: resistor b15 b20 2.2k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815
  CIN: capacitor d5(-) d9(+) 1uF
  RE: resistor a21 -t21 1k
  CE: capacitor/electrolytic b21(+) b26(-) 100uF
  COUT: capacitor d20(+) d27(-) 1uF
  AD:
    type: device
    at: top
    label: AD (supply)
    pins: [V+, GND]
  CH0:
    type: device
    at: top
    label: CH0 (via 20 dB ATT ×2)
    pins: [Shield, Center]
  CH1:
    type: device
    at: top
    label: CH1
    pins: [Center, Shield]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - CH0.Center -- a5 yellow
  - CH0.Shield -- -t4 black
  - CH1.Center -- a27 orange
  - CH1.Shield -- -t28 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a26 -- -t26 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/03-common-emitter-2.svg)

Fig. 5 is a graph of S21 **calculated** by replacing the transistor with a small-signal model (hybrid π)
(it is not a VNA screen). If you measure, a line of the same shape should appear on the VNA screen.

```graph
# Graph (tommie-fence graph fence)
title: Fig. 5 S21 of the common emitter (calculated), +10.6 dB and phase 180° at low frequency, −3 dB at 13 MHz
x: Frequency Hz log 50k..100M
y:
  - Magnitude dB
  - Phase deg
lines:
  S21 (calculated) dB:
    - 50k 10.60
    - 549.8k 10.60
    - 1.05M 10.58
    - 2.049M 10.50
    - 3.049M 10.37
    - 4.048M 10.20
    - 5.048M 9.99
    - 7.046M 9.48
    - 9.046M 8.89
    - 11.04M 8.24
    - 13.04M 7.58
    - 15.04M 6.92
    - 20.04M 5.35
    - 25.04M 3.94
    - 30.04M 2.69
    - 40.03M 0.63
    - 50.02M -1.01
    - 60.02M -2.32
    - 70.02M -3.39
    - 80.01M -4.28
    - 90M -5.04
    - 100M -5.71
  S21 phase (calculated) deg:
    - 50k 180.0
    - 549.8k 177.2
    - 1.05M 174.6
    - 2.049M 169.5
    - 3.049M 164.5
    - 4.048M 159.7
    - 5.048M 155.0
    - 7.046M 146.3
    - 9.046M 138.4
    - 11.04M 131.4
    - 13.04M 125.2
    - 15.04M 119.7
    - 20.04M 108.2
    - 25.04M 99.0
    - 30.04M 91.2
    - 40.03M 78.2
    - 50.02M 67.0
    - 60.02M 56.5
    - 70.02M 46.2
    - 80.01M 35.9
    - 90M 25.1
    - 100M 13.8
notes:
  - level 0dB
  - level 7.6dB
  - mark 1M
  - mark 13M
  - mark 50M
```

![Graph](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/graph/03-common-emitter.svg)

- The dashed 0 dB line is the through connection, with CH0 and CH1 joined directly. At low frequency S21 is **about +10.6 dB
  (|S21| ≈ 3.4) with phase 180°** (inverted). It is much smaller than the 79 times (+38 dB) seen on the oscilloscope because
  **the 50 Ω of CH1 loads the collector through `COUT`**. The gain falls to gm × (RC ‖ 50 Ω)
  = 35.8 mA/V × 48.9 Ω ≈ **1.75 times** (50 Ω is far smaller than RC = 2.2 kΩ)
- On the input side, the input impedance of the amplifier seen from the 50 Ω of CH0 is as high as R1 ‖ R2 ‖ β·re
  = 6.7 kΩ ‖ 4.2 kΩ ≈ **2.6 kΩ**. It hardly draws any current from the 50 Ω, so the base gets about twice the voltage it would get
  when connected directly to a 50 Ω line. S21 ≈ 2 × 1.75 ≈ 3.4 (+10.6 dB) is the product of these two.
  S11 (Fig. 6) sits near the right end of the Smith chart (open) for the same reason: the input has a high impedance
- **There is no corner on the low side.** `CIN` forms about 60 Hz with 50 Ω + 2.6 kΩ, `COUT` about 70 Hz with
  2.2 kΩ + 50 Ω, and `CE` about 56 Hz with the roughly 29 Ω seen from the emitter (re plus the source). All are far below the
  VNA's lower limit of 50 kHz, so the response is flat from 50 kHz. To see the low corner, use the network
  analyzer of the AD (from 1 Hz)
- **The high side is −3 dB at 13 MHz** (+7.6 dB) and about −1.0 dB at 50 MHz (below the through). The phase also
  lags behind 180°. The pole on the input side is what matters:
  - The f<sub>T</sub> of the 2SC1815 drops as the current and V<sub>CE</sub> get smaller. The datasheet's 80 MHz (minimum)
    is for V<sub>CE</sub> of 10 V and I<sub>C</sub> of 1 mA, so for this circuit (0.93 mA, about 2 V) around 45 MHz was assumed.
    Because gm is large, the base-emitter capacitance Cπ = gm / (2π fT) ≈ 127 pF is large
  - C<sub>ob</sub> (Cµ) is 4 pF at a VCB of about 1.3 V. With the Miller effect (the capacitance between base and collector looks larger by the
    gain) it appears as about 11 pF, (1 + gm × 48.9 Ω) ≈ 2.8 times larger. With the 50 Ω load the gain is small, so the Miller effect is much lighter than when the load is 2.2 kΩ (about 80 times)
  - The sum is charged through the base spreading resistance (rbb′ about 50 Ω) and the 50 Ω of the source, so
    1 / (2π × about 100 Ω × about 138 pF) ≈ 12 MHz gives a pole (the frequency where the gain starts to fall)
  - The lead of the SMA-to-clip cable (about 80 nH per 10 cm) and the stray capacitance of the breadboard holes (a few pF per spot)
- Values used for the calculation in Fig. 5: Ic 0.93 mA, hFE 150, fT 45 MHz, Cob 4 pF, rbb′ 50 Ω, plus 80 nH of clip lead (input and output)
  and 5 pF of stray capacitance at each node. The actual onset of the roll-off changes with the lead length and how it is wired

For the input side (S11), replace the circuit seen from the base with an equivalent circuit of only resistors,
capacitors and inductors, and it can be drawn directly on the VNA screen (Fig. 6). From CH0 in order: the clip lead (80 nH),
the stray capacitance at the base node (5 pF), the bias R1 ∥ R2 (6.7 kΩ), rbb′ (50 Ω), and finally the transistor input rπ (= β / gm ≈ 4.2 kΩ)
in parallel with the capacitance of Cπ plus the Miller part (127 pF + 11 pF ≈ 138 pF). The emitter is grounded for AC through `CE`.

```vna
# NanoVNA screen (tommie-fence vna fence)
device: litevna64
sweep: 50k-100M 201
title: Fig. 6 S11 at the input of the common emitter (equivalent circuit), right end of Smith at low frequency
dut:
  - series L 80n
  - shunt C 5p
  - shunt R 6k7
  - series R 50
  - shunt R 4k2
  - shunt C 138p
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1M
  - 13M
  - 50M
```

![NanoVNA screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/vna/03-common-emitter.svg)

- Fig. 5 and Fig. 6 are calculated, not measured. After measuring, put the VNA's Touchstone file (`.s2p`) next to the file of this exercise
  and write `data: <file name>.s2p` in the fence of Fig. 6, and the measured line is drawn over it as a solid line (the ideal turns into a dashed line)

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1 | Resistor (1/4 W) | 20 kΩ |
| R2 | Resistor (1/4 W) | 10 kΩ |
| RC | Resistor (1/4 W) | 2.2 kΩ |
| RE | Resistor (1/4 W) | 1 kΩ |
| CIN, COUT | Film capacitor | 1 µF |
| CE | Electrolytic capacitor | 100 µF |
| Q1 | NPN transistor | 2SC1815 |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

Measure the DC voltages (base, emitter, collector) with W1 off, using the multimeter's DC voltage range against GND.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Base voltage | about 1.6 to 1.7 V | As calculated for the divider |
| Emitter voltage | about 0.93 V | 0.6 to 0.7 V lower than the base |
| Collector voltage | about 3.0 V | The operating point is at a suitable position between VCC and GND |
| Output (CH1) for a 10 mVpp (1 kHz) input | about 790 mVpp, opposite phase to the input (phase 180°) | Inverting amplification, gain about 79 times (calculated value) |
| Output with CE removed | falls to about 22 mVpp | The gain drops to −RC/RE ≈ 2.2 times |

## Verification with LTspice

`sim/03-common-emitter.cir` reads the operating point and the AC gain of Fig. 1. Q1 is a substitute model for the 2SC1815 (the same IS, BF, VAF and IKF as `09-rf/sim/agc.cir`,
plus a capacitance and TF that put f<sub>T</sub> around 45 MHz (C<sub>π</sub> ≈ 130 pF). It is an assumption made from rough guides, not a measurement).
S21 uses the VNA arrangement with 50 Ω source and load (small signal, without the 20 dB ATT); the clip leads and stray capacitance are not included.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Base voltage | about 1.63 V | 1.64 V | Match |
| Emitter voltage | about 0.93 V | 1.00 V | Close (the model's V<sub>BE</sub> is 0.64 V; the text estimated with 0.7 V) |
| Collector voltage | about 2.95 V | 2.80 V | Close (I<sub>C</sub> is a little high at 1.0 mA) |
| Voltage gain (1 kHz, with CE) | about −79 times | 78.5 times (37.9 dB), inverted | Match |
| Gain with CE removed | about −2.2 times | 2.1 times (6.6 dB) | Match (about 21 mVpp for 10 mVpp) |
| S21 (1 MHz, 50 Ω load) | +10.6 dB | +10.9 dB | Match |
| S21 (13 MHz) | +7.6 dB (the −3 dB point) | +7.6 dB | Match |
| S21 (50 MHz) | about −1.0 dB | −1.7 dB | Match (Fig. 5 includes the 80 nH lead and 5 pF stray capacitance) |

The emitter and collector differ by 0.07 to 0.15 V because of the difference in the model's V<sub>BE</sub>, within 10 %. This stays within the "about" of the text.

## Sources

Original work.
