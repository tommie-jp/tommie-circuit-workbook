---
book: circuits
chapter: 9
id: 9-27
title: Transistor and Board of the FM Transmitter — Why the 2SC3355 and a Copper-Clad Board, and an Estimate of Why the Oscillation Frequency Drops
tier: 100
source: 自作
board: CB
era: 古
ja: d64d8aeef9654ae48e0b8697c91aa110d1d2e802
---

# 9-27 Transistor and Board of the FM Transmitter — Why the 2SC3355 and a Copper-Clad Board, and an Estimate of Why the Oscillation Frequency Drops

**Read 9-4 (FM transmitter, 1 transistor) first.** For the transmitter of 9-4, this exercise gives the reasons for choosing the 2SC3355 for Q1
and for building on a copper-clad board, and estimates why the built oscillator runs below the calculated 80.6 MHz. The circuit, the layout of the islands and how to build it are as in 9-4.
The circuit works at 80 MHz (the FM broadcast band), above 3 MHz, but it is placed in Introductory because the subject is the FM broadcast band and it is built on the same copper-clad board as 9-4.

This exercise has no wiring diagram, Analog Discovery 3 or oscilloscope figure. It uses the same board as 9-4 as it is, and refers to Fig. 1 (schematic) and Fig. 2 (copper-clad board) of 9-4.

## Why the 2SC3355 was chosen for Q1

This circuit oscillates at around 80 MHz. Oscillation requires that the current gain |h<sub>fe</sub>| of the
transistor at that frequency be well above 1. |h<sub>fe</sub>| falls as the frequency rises, and the frequency at which it falls to 1 is called f<sub>T</sub> (the transition frequency). The ordinary small-signal
2SC1815 has a guaranteed f<sub>T</sub> of at least 80 MHz (V<sub>CE</sub> = 10 V, I<sub>C</sub> = 1 mA), so at 80 MHz
|h<sub>fe</sub>| can fall to 1 in the worst case, and **a margin for oscillation cannot be guaranteed**. So the 2SC1815 was not chosen.
The 2SC3355 (UTC, for high-frequency low-noise use) has an f<sub>T</sub> of 7 GHz (typ, V<sub>CE</sub> = 10 V, I<sub>C</sub> = 20 mA),
a margin of almost two orders of magnitude over 80 MHz, and its C<sub>re</sub> is small too, at most 1.0 pF
(the C<sub>ob</sub> of the 2SC1815 is about 3.5 pF).
The main ratings are V<sub>CEO</sub> 12 V, V<sub>CBO</sub> 20 V, V<sub>EBO</sub> 3 V, I<sub>C</sub> 100 mA,
P<sub>C</sub> 600 mW (TO-92) and h<sub>FE</sub> 50–300. The V<sub>CE</sub> ≈ 4.6 V and I<sub>C</sub> ≈ 0.75 mA of the circuit of 9-4 are well within
all of them. The noise figure of 1.1 dB (typ, 1 GHz) in the datasheet is not used in this circuit.

**Spread of h<sub>FE</sub> and the operating point**: The h<sub>FE</sub> of the 2SC3355 is wide, 50–300 (the guaranteed value at V<sub>CE</sub> = 10 V, I<sub>C</sub> = 20 mA
[[1]](#sources)), but R<sub>th</sub>/h<sub>FE</sub> in the operating-point formula of 9-4 is small compared with Re, and I<sub>C</sub> stays within
**0.72–0.77 mA**: about 0.72 mA at h<sub>FE</sub> = 50 and about 0.77 mA at h<sub>FE</sub> = 300.
The guaranteed value is for I<sub>C</sub> = 20 mA and is lower at 0.75 mA, but even with h<sub>FE</sub> = 30, for example, I<sub>C</sub> is
about 0.69 mA, so the operating point hardly depends on h<sub>FE</sub> (this is why Re is included and
the base is biased stiffly).

## Why a copper-clad board, and an estimate of why the oscillation frequency drops

This circuit oscillates at around 80 MHz. That is far above the guideline for a breadboard (3 MHz or less)
and for a perfboard (10 MHz or less). The tank is only 15 pF and 260 nH, and the capacitance between holes
and pins that get long to fit the hole pitch would shift the oscillation frequency and the oscillation condition. So 9-4 builds it on
a copper-clad board whose back is an unbroken GND plane, by the Manhattan method.
The estimates are as follows (all rough guides; none was measured).

- **Stray capacitance of the islands**: The largest island is the tank node COL (the island where the collector of Q1, L1, C1 and Cant meet,
  14×4 mm). Its capacitance to the GND plane on the back, from the parallel-plate formula C = ε<sub>0</sub>ε<sub>r</sub>A/h
  (ε<sub>r</sub> = 4.4, h = 1.6 mm, A = 56 mm²), is **about 1.4 pF**. Including fringing it is around 2 pF,
  **a little over 10%** of C<sub>s</sub> = 15 pF. This alone lowers the oscillation frequency by several MHz from 80.6 MHz. The EMI island
  (the same size) is in parallel with C2 (47 pF), so it matters about 3%, and the other islands are nodes where high frequency does not flow or
  are in parallel with large capacitors, so they hardly matter.
- **Feedback capacitance of Q1**: The C<sub>re</sub> (collector-base feedback capacitance) of the 2SC3355 is at most 1.0 pF
  (V<sub>CB</sub> = 10 V, f = 1 MHz [[1]](#sources)). The base is at GND for high frequency through C3, so this capacitance sits directly in parallel
  between the COL island and GND, and is **under 7%** of C<sub>s</sub> at most. The frequency drops by a little over 3%
  (about 2.5 MHz, an estimate).
- **Inductance of the pins**: For a pin of 0.5 mm diameter, L ≈ 2l[ln(4l/d) − 0.75] nH (l and d in cm), so
  a 10 mm pin is about 7 nH (**around 0.7 nH per 1 mm**). The pins of C1 and C2 in the tank loop add up to 20 mm, **about 14 nH**,
  which is 5% of L1 (260 nH). Adding both lowers the frequency from 80.6 MHz by around 7% to
  the **75 MHz range**, and including the C<sub>re</sub> above, it could drop to **around 73 MHz**. That is the low end of the Japanese FM
  broadcast band (76–95 MHz), or below it. **Spread the turns of the coil a little
  (as in "Spreading the turns of the coil a little" in 9-4) to tune to around 80 MHz**. The longer the pins, the lower the frequency, so
  cutting them short and closing up the gaps between islands is where this way of building pays off.
- **Why not a perfboard**: Parts are bridged to fit the hole pitch (2.54 mm), so the pins tend to be longer than in
  Fig. 2 of 9-4, which bridges island to island, and there is no continuous GND plane on the back. That is enough for circuits of 10 MHz or less,
  but it does not suit a circuit that must get a 15 pF, 260 nH tank right at 80 MHz.

**Checking the range**: The voltage of 5 V, current I<sub>C</sub> ≈ 0.75 mA (the value before oscillation; it can rise to the 3 mA range while oscillating, but the power is under 20 mW, within 100 mW), and frequency around 80 MHz are within
the range of the copper-clad board (above 10 MHz up to 1 GHz). The island width is at least 4 mm (3 mm or more). The gap between islands is
at least 1.5 mm (0.3 mm or more). No mains power is used.

## Values to check

Estimates. The frequency of the carrier is read with the tinySA of 9-28.

| What to check | Expected value |
| --- | --- |
| Carrier right after building | Between 73 and 80 MHz (an estimate from the pins and stray capacitance). Counting Cant, it can drop to 70–75 MHz (LTspice below) |
| Spread the coil turns a little | The carrier rises. Tune it to **80 MHz** |

## Verification with LTspice

**Comparison with LTspice**: In `sim/04-fm-transmitter.cir`, the circuit of Fig. 1 of 9-4 was run as a transient analysis from the supply turning on (50 ns), and the oscillation frequency and current were read.
Q1 is a substitute model for the 2SC3355 (the same IS, BF, VAF, IKF and RB as the 2SC1815 in `sim/agc.cir`, with TF = 23 ps to match an f<sub>T</sub> of 7 GHz,
CJE = 1 pF and CJC = 0.6 pF; an assumption made from typical values, not measured). The comparison of the operating point is in "Verification with LTspice" of 9-4.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Oscillation frequency (ideal: no stray capacitance, no capacitance of Q1, no Cant) | ≈ 80.6 MHz | 80.4 MHz | Agrees |
| Include the capacitances of Q1 (C<sub>be</sub>, C<sub>bc</sub>) | Not counted in the text | 79.3 MHz (about 1 MHz lower) | Smaller than the estimate of "a little over 3% from C<sub>re</sub>" in the text |
| Further connect Cant (2.2 pF) to a 50 Ω load | Not counted in the text | 74.1 MHz (about 5 MHz lower) | Added note (below) |
| Add 1.4 pF of island stray capacitance to COL | Several MHz lower | 71.3 MHz (2.7 MHz lower with Cant) | Agrees |
| Island 1.4 pF + 14 nH of pins of C1 and C2 | 73 to 75 MHz range | 74.3 MHz without Cant, 70.1 MHz with Cant | Agrees (the value without Cant is the same as the 73–75 MHz estimate in the text) |

The "73–80 MHz" in the text does not count the effect of Cant. Cant (2.2 pF) acts directly as a capacitance in parallel with COL, to the extent that the antenna wire beyond it looks like a load near GND
(the 50 Ω row above is the estimate on the side where it matters most). A 20 cm antenna wire has a capacitance of a few pF to GND, so the real drop is smaller than the 50 Ω row.
Either way, read it as the island, pins and Cant can lower it to 70–75 MHz, and **the procedure of spreading the coil turns to tune to 80 MHz does not change**.
**Current**: The 0.75 mA of 9-4 is the value without oscillation. While oscillating, the swings of C1 and C2 rectify the base and raise the average I<sub>C</sub>; in this model it reached the 3 mA range,
and the collector swing was 12–13 Vpp (up and down around the 5 V supply). This size is a rough guide that moves a lot with the model of Q1 and the coupling assumptions, and it is not measured
(it does not exceed V<sub>CBO</sub> of 20 V, but it is close to V<sub>CEO</sub> of 12 V. In the real circuit the swing should be smaller because of the losses of L1 and Q1). The supply current is expected from the 1 mA range to the 3 mA range,
and the power is under 20 mW, within the AD3 supply (about 50 mA) and the range of the copper-clad board (100 mW or less).

## Sources

Original work.

1. UNISONIC TECHNOLOGIES 2SC3355 datasheet
   ([https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf)).
   f<sub>T</sub>, C<sub>re</sub>, h<sub>FE</sub> and the ratings come from it.
   The f<sub>T</sub> and C<sub>ob</sub> of the 2SC1815 come from the Toshiba datasheet.
