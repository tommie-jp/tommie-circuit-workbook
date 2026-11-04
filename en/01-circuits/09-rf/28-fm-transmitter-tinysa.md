---
book: circuits
chapter: 9
id: 9-28
title: Seeing the Carrier and Harmonics of the FM Transmitter with a tinySA
tier: 100
source: 自作
board: CB
era: 古
ja: d9164bacda2a614aec3a70497519af8157d92008
---

# 9-28 Seeing the Carrier and Harmonics of the FM Transmitter with a tinySA

**Build 9-4 (FM transmitter, 1 transistor) first.** This exercise picks up the waves of the transmitter of 9-4 with a tinySA Ultra and looks at
the frequency of the carrier and the heights of the 2nd and 3rd harmonics. The circuit, the layout of the islands on the copper-clad board and the Radio Act caution are as in 9-4.
The circuit works at 80 MHz (the FM broadcast band), above 3 MHz, but it is placed in Introductory because the subject is the FM broadcast band and it is built on the same copper-clad board as 9-4.

This exercise has no wiring diagram or Analog Discovery 3 figure. It uses the same board as 9-4 as it is and only adds a way of measuring (the figures are Fig. 1 and Fig. 2 of 9-4).

## Instrument settings

This exercise has no oscilloscope figure. The carrier is at 80 MHz, outside the range of Scope on the AD3 (10 MHz or less), so the waveform cannot be seen.
It is confirmed with the tinySA spectrum in Fig. 1. The power comes from the AD3 (Supplies), as in 9-4.

**Why a tinySA.** The carrier is around 80 MHz, outside the input range of the Analog Discovery (10 MHz or less).
What we want to see in this exercise is not the shape of the waveform but **the frequency of the carrier and the heights of the 2nd and 3rd harmonics**, that is, the spectrum,
so we use the **tinySA Ultra** (a palm-sized spectrum analyzer), which covers 0–5.3 GHz.
A spectrum analyzer plots frequency on the horizontal axis and signal strength on the vertical axis
to show how much signal there is at which frequency. Strength is read in **dBm** (the dB of power with 1 mW as 0 dBm;
−10 dBm is 0.1 mW and −50 dBm is 10 nW).

**How to pick it up.** Connect nothing to the transmitter, and pick up the waves over a short distance.

- Basically, plug the supplied antenna (or a wire of about 20 cm) into the input (SMA) of the tinySA Ultra and place it
  **several tens of centimeters** from the transmitter. Too close, and the input of the tinySA saturates and the tank of the transmitter is pulled, shifting the frequency.
- Only when the peak is too small to see, remove the antenna wire (the ANT island) and pick up with a short wire held close.
  **Connect directly with a coaxial cable only when the peak is too high (above −10 dBm), and
  only through** an SMA attenuator (such as 20 dB). Cant (2.2 pF) in this circuit has an impedance of about 900 Ω at 80 MHz, so connecting a 50 Ω input
  directly almost stops the oscillation.
- **Do not exceed the Radio Act limit.** A very-low-power station at 322 MHz or below is limited to 500 µV/m at a distance of 3 m. This way of picking up keeps the
  20 cm antenna and the 0.75 mA current, and you must not add an amplifier or an antenna here to raise the peak.
- **The input limit of the tinySA Ultra is an absolute maximum of +6 dBm (recommended +0 dBm or less, DC up to ±5 V).** The peak of this circuit picked up several tens of centimeters away is around −50 dBm (the rough guide below), far below the limit, so no attenuator is needed.

| Item | Setting | Reason |
| --- | --- | --- |
| Start / stop | 0 / 359.2 MHz | The carrier (80 MHz) and the 2nd (160 MHz) and 3rd (240 MHz) harmonics fit on one screen. With this span all three fall exactly on points |
| Points | 450 | 1 point = 0.8 MHz. The three lines are 80 MHz apart |
| RBW (resolution bandwidth. The width of frequency seen at one time; the narrower it is, the closer lines can be separated and the lower the noise floor) | 100 kHz | The floor is about −97 dBm (converted from −102 dBm @ 30 kHz). The FM swing (tens of kHz) fits in one line |
| Reference level (REF) | −30 dBm | The carrier (−50 dBm) is 2 divisions below the top. The harmonics (−70 and −80 dBm) also fit on the screen |
| Vertical scale | 10 dB/div | Default |
| Markers | 1 = 80 MHz, 2 = 160 MHz, 3 = 240 MHz | Take 1 with peak, and place 2 and 3 by frequency |

**When tuning the frequency.** Once you find the place of the carrier in the wide sweep above, narrow the center to that frequency, the span to about 2 MHz,
and the RBW to about 10 kHz to read it. Because of the stray capacitance of the islands and the inductance of the pins (estimated in 9-27), the carrier is expected to appear between **73 and 80 MHz**, and
you **spread the turns of the coil a little to tune to 80 MHz** (spreading raises it).

## Instrument screen

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 1 80MHz carrier and harmonics (estimate)
device: tinysa-ultra
sweep: 0-359.2M 450
rbw: 100kHz
ref: -30dBm
signal:
  - sine 80MHz -50dBm
  - sine 160MHz -70dBm
  - sine 240MHz -80dBm
markers: [80M, 160M, 240M]
```

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/spectrum/28-fm-transmitter-tinysa.svg)

- **All the heights in the figure are rough guides (estimates)**. There are three assumptions. (1) The carrier is picked up by the tinySA at several tens of centimeters from
  the 20 cm antenna and the 2.2 pF coupling at **−50 dBm** (it moves by ±15 dB with the direction of the antenna and reflections from the desk and your hand).
  (2) The 2nd harmonic is 20 dB below the carrier (**−70 dBm**) and the 3rd is 30 dB below (**−80 dBm**). In a one-transistor Colpitts the harmonics are reduced by the resonance of the tank,
  but the collector current is distorted, so that much is assumed to remain. (3) How easily each harmonic is picked up differs with frequency
  and the gain of the antenna also changes, so the real thing can be off by ±10 dB or more.
- The real carrier swings by tens of kHz around 80 MHz with the voice of the microphone. At RBW 100 kHz it looks like a single line
  (to see this swing, narrow the span to 10 kHz and the RBW to 200 Hz, as in 9-18).
- Lines from nearby FM broadcast stations (76–95 MHz) may appear separately on the screen. When one is confused with the carrier,
  turn off the power of the transmitter and take the one that disappears as the carrier.

## Values to check

Estimates.

| What to check | Expected value |
| --- | --- |
| Marker 1 (carrier) of the tinySA | Between 73 and 80 MHz (an estimate from the pins and stray capacitance, 9-27). Spread the coil to tune to **80 MHz** |
| Height of marker 1 of the tinySA | About −50 dBm (when picked up at several tens of centimeters, a rough guide. ±15 dB) |
| Marker 2 (160 MHz, 2nd harmonic) | About −70 dBm (20 dB below the carrier, assumption) |
| Marker 3 (240 MHz, 3rd harmonic) | About −80 dBm (30 dB below the carrier, assumption). Above the RBW 100 kHz floor (−97 dBm) |

## Verification with LTspice (not applicable)

The circuit is the same as Fig. 1 of 9-4, and the comparison of the operating point and oscillation frequency is in "Verification with LTspice" of 9-4 and 9-27.
The tinySA heights and the dBm of the harmonics are estimates based on assumptions about the antenna and coupling, and were not run here (out of scope).

## Sources

Original work. The technical standard for very-low-power radio stations in the Radio Act (322 MHz or below, 500 µV/m at a distance of 3 m) is from
Article 6 of the Enforcement Regulations for the Radio Act, Ministry of Internal Affairs and Communications.
