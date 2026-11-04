---
book: circuits
chapter: 9
id: 9-18
title: Modulating the FM Transmitter with the AD Signal Generator — 1 kHz in Place of the Microphone
tier: 100
source: 自作
board: CB
era: 古
ja: c1699102ca71e0e20afb3d9818165494eb35fd8a
---

# 9-18 Modulating the FM Transmitter with the AD Signal Generator — 1 kHz in Place of the Microphone

**Build 9-4 (FM transmitter, 1 transistor) first.** This exercise checks the modulation of the 9-4 transmitter with signal generator W1
of the AD3 in place of the microphone. How the circuit works, the layout of the islands on the copper-clad board and the Radio Act cautions stay as in 9-4, and how the tinySA picks up the signal stays as in 9-28.
The circuit works at 80 MHz (the FM broadcast band), above 3 MHz, but the subject is the FM broadcast band and it is built on the same copper-clad board as 9-4, so it is placed at the Introductory tier.

A voice is different every time, so to check how the modulation looks it is more repeatable to put in **a 1 kHz sine wave from signal generator W1 of the Analog Discovery 3 (AD3)** in place of
the microphone. The output of an electret microphone is only a few mV to a few tens of mV (rms)
at a normal speaking volume. W1 is unstable at small amplitudes, so **output 1 Vpp, divide it down to 1/100 with resistors**, and
feed it to the base through the same Cmic.

## Schematic

**Settings of W1**: Set W1 of Wavegen to Simple, waveform Sine, frequency 1 kHz, amplitude 500 mV (peak, 1 Vpp), offset 0 V.
The divider is two E24 resistors, Rin (10 kΩ) and Rd (100 Ω), and **the MIC node is 1 Vpp × 100 Ω / (10 kΩ + 100 Ω) ≈ 9.9 mVpp**
(about 3.5 mVrms; 9–10 mVpp counting the base side as the load). It is matched to the lower end of the typical range of a voice (a few mV to a dozen or so mV rms).
1 kHz is the middle of the voice band, and above the corner of the high-pass formed by Cmic (0.1 µF) and the resistance seen from the base (a few kΩ)
(a few hundred Hz). Always connect the GND of W1 to the − of the supply (the GND of the circuit).

The Rmic (2.2 kΩ) for biasing the microphone is not needed here, so remove it (W1 passes no DC, and if Rmic stays it would sit in parallel
with the lower side of the divider and shift the 100 Ω value).

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 AD W1 (1kHz) divided down in place of the mic
parts:
  VCC: vcc 2,1 5V
  L1: inductor 10,3 10,1 260n
  Cb: capacitor 4,1 4,3 0.1u
  GCb: ground 4,3
  Cant: capacitor 13,3 15,3 2.2p
  ANT: antenna 16,3
  Q1: npn 10,5
  C1: capacitor 12,4 12,6 22p
  C2: capacitor 12,7 12,9 47p
  GC2: ground 12,9
  Re: resistor 10,7 10,9 470
  GRe: ground 10,9
  Rb1: resistor 8,1 8,3 10k
  Rb2: resistor 7,7 7,5 2.4k
  GRb2: ground 7,7
  C3: capacitor 8,5 8,7 0.001u
  GC3: ground 8,7
  W1: sine 1,5 1,7 l=$\mathrm{W1}$
  GW1: ground 1,7
  Rin: resistor 1,5 3,5 10k
  Rd: resistor 3,5 3,7 100
  GRd: ground 3,7
  Cmic: capacitor 3,5 5,5 0.1u
wires:
  - 2,1 -- 10,1
  - 10,3 -- Q1.C
  - 10,3 -- 12,3
  - 12,3 -- 13,3
  - 12,3 -- 12,4
  - 15,3 -- 16,3
  - 12,6 -- 12,7
  - Q1.E -- 10,7
  - 10,7 -- 12,7
  - 5,5 -- 7,5
  - 7,5 -- 8,5
  - 8,5 -- Q1.B
  - 8,3 -- 8,5
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/18-fm-transmitter-wavegen.svg)

## Wiring diagram

**Build the copper-clad board as in Fig. 2 of 9-4, but drop the microphone box and Rmic and change it as follows.**
The instruments outside the copper-clad board are the AD3 (V+ of Supplies, W1, GND) and the antenna wire. W1 of the AD3 goes to the island below Rin (VIN), and
GND goes to the same GND island (on the back plane) as the − of the supply. V+ goes to the VCC strip as in Fig. 2 of 9-4. Rin (10 kΩ) goes from VIN to the MIC island, and Rd (100 Ω) goes from
the MIC island to a GND island (via). The upper VA island in Fig. 2 of 9-4 is not used, so do not cut it out.
The netlist of `copper-fence check` agrees with the schematic of Fig. 1 (VIN = the node of W1 and Rin, MIC = the node of Rin, Rd and Cmic).

```copper
# Copper-clad board dimension drawing (tommie-fence copper fence)
board:
  size: 70x50mm
  ground: back
title: Fig. 2 Mic removed, W1 divided down to MIC island
f: 80M
copper:
  VCC: pad 31,7 46x4mm
  VIN: pad 9,34 4x4mm
  VB: pad 25,11 4x6mm
  MIC: pad 13,24 8x4mm
  BASE: pad 29.5,24 15x4mm
  COL: pad 48,18 14x4mm
  EMI: pad 48,30 14x4mm
  ANT: pad 61,18 4x4mm
  GCb: pad 17,16 4x4mm
  VCb: via 17,16
  GMIC: pad 15,34 4x4mm
  VMIC: via 15,34
  GC3: pad 28,36 4x4mm
  VC3: via 28,36
  GB2: pad 33.5,36 4x4mm
  VB2: via 33.5,36
  GC2: pad 47,41 4x4mm
  VC2: via 47,41
  GRe: pad 53,41 4x4mm
  VRe: via 53,41
parts:
  Cb: capacitor 17,8 17,16 0.1u
  Rin: resistor 10,25 10,34 10k
  Rd: resistor 14,25 14,34 100
  Cmic: capacitor 16,24 23,24 0.1u
  Rb1: resistor 25,13 25,23 10k
  Rb2: resistor 33.5,25 33.5,36 2.4k
  C3: capacitor 28,25 28,36 0.001u
  Q1: transistor/to92 36,24 43,18 43,30 2SC3355L
  L1: inductor 46.5,8 46.5,17 260n
  C1: capacitor 50,19 50,29 22p
  C2: capacitor 47,31 47,41 47p
  Re: resistor 53,31 53,41 470
  Cant: capacitor 54,18 60,18 2.2p
  AD:
    type: device
    at: -26,16
    label: Analog Discovery 3 (Supplies, W1)
    pins: V+ GND W1
    face: right
  WIRE:
    type: device
    at: 80,12
    label: Antenna wire 20cm
    pins: A
    face: left
wires:
  - AD.V+ -- 8.5,6 red
  - AD.GND -- 15.5,16 black
  - AD.W1 -- VIN
  - AD.GND -- 15,35.5 black
  - WIRE.A -- ANT
```

![Copper-clad board dimension drawing](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/copper/18-fm-transmitter-wavegen.svg)

## Parts

The parts list of 9-4 stays as it is; remove the microphone and Rmic and add the following.

| Symbol | Value / part number | Notes |
| --- | --- | --- |
| Rin, Rd | 10 kΩ, 100 Ω | When trying it with W1 of the AD in place of the microphone (remove Rmic) |
| Signal source | W1 of the Analog Discovery 3 | 1 kHz, 1 Vpp sine wave |

## Instrument settings

This exercise has no oscilloscope figure. The carrier is at 80 MHz, outside the range of Scope on the AD3 (10 MHz or less), so the waveform cannot be seen.
It is confirmed with the tinySA spectrum in Fig. 3. The power and the modulation signal come from the AD3 (Supplies, W1).

**What to see on the tinySA Ultra.** When modulated with a 1 kHz sine wave, lines stand on both sides of the carrier at ±1 kHz, ±2 kHz, and so on.
These lines on both sides of the carrier are called **sidebands**.
However, **in a wide sweep it stays a single line**: at RBW 100 kHz (Fig. 3 of 9-4) the swing is a few kHz, so it fits within the line of the carrier and
**the frequency swing cannot be seen** (even with a span of 200 kHz and RBW 3 kHz, ±1 kHz is narrower than the RBW and the line only gets a little thicker without separating).
To see the ±1 kHz sidebands separately, **center on the carrier and narrow to a span of 10 kHz and RBW 200 Hz** (the narrowest RBW of the tinySA Ultra).
With RBW 200 Hz, ±1 kHz is 5 times the RBW away and appears as separate peaks. The sweep is slow (tens of seconds), so
do not let your hand or the desk touch the copper-clad board, so the carrier does not move, and let it warm up for about 5 minutes before you look. Even so, a free-running LC oscillator can drift
by a few kHz, and when a peak leaves the screen, center it again.

## Instrument screen

**Assumptions for the calculated values** (the modulation depth is an estimate and the real one can be off by a factor of a few in either direction).

1. The total carrier power is −50 dBm, the same as Fig. 3 of 9-4 (picked up at several tens of centimeters)
2. The signal at the base is about 70% of that at the MIC node (the divider of Cmic and the base resistance), a peak of about 3.3 mV
3. Re (470 Ω) gives AC negative feedback, and the change of V<sub>BE</sub> is a little under 10% (r<sub>e</sub> ≈ 26 mV / 0.75 mA ≈ 35 Ω,
   35 Ω / (470 Ω + 35 Ω) ≈ 0.07), so ΔV<sub>BE</sub> ≈ 0.23 mV
4. That change alters the collector current by 0.9% (ΔV<sub>BE</sub> / 26 mV), and the diffusion capacitance (the capacitance that appears between base and emitter in
   proportion to the current; gm·τ<sub>F</sub> ≈ 29 mS × 23 ps ≈ 0.66 pF, with τ<sub>F</sub> ≈ 1/(2πf<sub>T</sub>) from
   f<sub>T</sub> = 7 GHz) moves by about 6 fF. Through the divider of C1 and C2, only (C1/(C1 + C2))² ≈ 0.1 of it, about 0.6 fF, reaches C<sub>s</sub>,
   giving Δf/f = ΔC<sub>s</sub> / 2C<sub>s</sub> ≈ 2×10<sup>−5</sup>.
   The change of the junction capacitance is not included.

This gives a **maximum frequency deviation (the maximum width by which the carrier frequency swings from its center) of about 1.6 kHz (2×10<sup>−5</sup> of 80 MHz)**, and a modulation index β = deviation / modulating frequency = 1.6 kHz / 1 kHz ≈ 1.6.
The powers of the carrier and sidebands use the Bessel functions (the functions that give the size of the n-th sideband of FM from β; values come from a table or from
python's scipy) J<sub>n</sub>(1.6) (J<sub>0</sub> = 0.455, J<sub>1</sub> = 0.570, J<sub>2</sub> = 0.257,
J<sub>3</sub> = 0.073), and subtracting 20 log<sub>10</sub>|J<sub>n</sub>| from the total of −50 dBm gives the following (Fig. 3).

| Line | Frequency | Estimate |
| --- | --- | --- |
| Carrier | 80 MHz | −56.8 dBm |
| ±1 kHz sidebands | 80 MHz ± 1 kHz | −54.9 dBm (about 2 dB higher than the carrier) |
| ±2 kHz | 80 MHz ± 2 kHz | −61.8 dBm |
| ±3 kHz | 80 MHz ± 3 kHz | −72.8 dBm |

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 3 1kHz sidebands of the carrier (estimate)
device: tinysa-ultra
center: 80MHz
span: 10kHz
points: 450
rbw: 200Hz
ref: -50dBm
signal:
  - sine 80MHz -56.8dBm
  - sine 80.001MHz -54.9dBm
  - sine 79.999MHz -54.9dBm
  - sine 80.002MHz -61.8dBm
  - sine 79.998MHz -61.8dBm
  - sine 80.003MHz -72.8dBm
  - sine 79.997MHz -72.8dBm
markers: [80M, 80.001M, 79.999M]
```

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/spectrum/18-fm-transmitter-wavegen.svg)

- The real carrier appears somewhere between 73 and 80 MHz, so the 80 MHz in the figure is how it looks after "spreading the coil to tune to 80 MHz"
  (the same assumption as Fig. 3 of 9-4). Center on the carrier of the real circuit.
- When you speak into the microphone, the deviation becomes several times the estimate above, depending on a voice of a few mV to a few tens of mV.
  With the 1 kHz of W1, 5 to 7 peaks standing in a row are **a sign that modulation is really applied**. If you stop W1, it returns to a single carrier line (−50 dBm).
  When no sidebands appear (or too many), the deviation changes in proportion to the amplitude of W1 (for small β, J<sub>1</sub> is proportional to β).
- Received on a nearby FM radio, you hear the 1 kHz tone (a beep) of W1. It is easier to tell apart than a voice, and the pitch stays at 1 kHz
  even when you change the coil turns, the antenna or the receiving position.
- **Safety**: The output of W1 is small, 1 Vpp, and only 5 V DC is applied to the circuit. The radio waves follow the same rules as with a voice:
  keep the antenna wire at 20 cm, keep Cant at 2.2 pF, run the experiment indoors for a short time, and do not leave it transmitting
  (as in the warning of 9-4, a very-low-power station is limited to 500 µV/m at a distance of 3 m). Do not raise the signal of W1 to gain deviation
  (the occupied frequency width would widen).

## Values to check

A mix of calculated and measured values.

| What to check | Expected value |
| --- | --- |
| Feeding W1 (1 kHz, 1 Vpp) through the divider: the MIC node | About 9.9 mVpp (divider of Rin 10 kΩ and Rd 100 Ω, calculated value) |
| Span 10 kHz, RBW 200 Hz, marker 1 (carrier) | The center line. About −56.8 dBm (assuming modulation index β ≈ 1.6, a rough guide) |
| Markers 2 and 3 (80 MHz ± 1 kHz, sidebands) | About −54.9 dBm. About 2 dB higher than the carrier. ±2 kHz is about −61.8 dBm and ±3 kHz is about −72.8 dBm (estimates; the real ones can be off by a factor of a few in either direction) |
| Stop W1 | The sidebands vanish and it returns to a single carrier line (about −50 dBm). The 1 kHz tone on the radio also stops |

## Verification with LTspice (not applicable)

Apart from how the microphone signal is fed in, the circuit is the same as Fig. 1 of 9-4, and the comparison of the operating point and oscillation frequency is in "Verification with LTspice" of 9-4.
The modulation depth (β ≈ 1.6) and the dBm of the sidebands are estimates based on assumptions about the antenna and coupling, and were not run here (out of scope).

## Sources

Original work. The technical standard for very-low-power radio stations in the Radio Act (322 MHz or below, 500 µV/m at a distance of 3 m) is from
Article 6 of the Enforcement Regulations for the Radio Act, Ministry of Internal Affairs and Communications.

1. UNISONIC TECHNOLOGIES 2SC3355 datasheet
   ([https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf)).
   f<sub>T</sub>, C<sub>re</sub>, h<sub>FE</sub>, the ratings and the pin order (B, E, C for TO-92) come from it.
