---
book: circuits
chapter: 9
id: 9-4
title: FM Transmitter (1 Transistor)
tier: 50
source: 自作
board: CB
era: 古
ja: 5293be87de0d0baaa9e960da16773840d2c45f14
---

# 9-4 FM Transmitter (1 Transistor)

Build a one-transistor **Colpitts oscillator** in the FM broadcast band (around 80 MHz; Japanese
FM broadcasting uses 76–95 MHz), and let the voice from a microphone shift the oscillation frequency slightly.
FM (frequency modulation) sends sound by changing the **frequency** of the carrier (the AM of 9-2 changes the amplitude).
Because the voice moves the frequency of the oscillator directly, this is called direct FM.
With a little over 10 parts you can go through a complete transmitting circuit.

The waves reach an FM radio nearby, but **to stay within the limits of a very-low-power radio station under the Radio Act, keep the antenna short,
the coupling weak, and add no amplifier stage**.

> [!WARNING]
> Under the Japanese Radio Act, a very-low-power radio station at 322 MHz or below needs no license if its **field strength
> at a distance of 3 m is 500 µV/m or less** (Article 6 of the Enforcement Regulations for the Radio Act). The constants of this exercise
> (short antenna, small coupling capacitor, weak bias current) are a design to stay within that limit, and
> **extending the antenna or adding a transistor to amplify is illegal without a license**.
> Run the experiment indoors for a short time, and do not leave it transmitting.

The flow of this exercise:

1. Schematic (Fig. 1): how the Colpitts oscillator and direct FM work, and the calculation of the oscillation frequency and operating point
2. Wiring diagram (Fig. 2): why 80 MHz calls for a copper-clad board, and the layout of the islands
3. Parts: why the 2SC3355 was chosen for Q1
4. Instrument settings and instrument screen (Fig. 3): seeing the carrier and harmonics with the tinySA
5. Trying it with W1 of the AD in place of the microphone (Figs. 4–6): modulate at 1 kHz and look at the sidebands
6. Values to check: a list of what to confirm

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Colpitts oscillator with direct FM from a mic
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
  MIC: mic 2,5 2,7 l=$\mathrm{MIC}$
  GMIC: ground 2,7
  Rmic: resistor 2,1 2,3 2.2k
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
  - 2,3 -- 2,5
  - 2,5 -- 3,5
  - 5,5 -- 7,5
  - 7,5 -- 8,5
  - 8,5 -- Q1.B
  - 8,3 -- 8,5
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/04-fm-transmitter-1.svg)

- **Tank**: L1 (260 nH, which shifts when measured; a hand-wound coil) and C1 and C2 (the Colpitts
  divider) form a parallel resonant circuit. A Colpitts oscillator sets its frequency by the resonance of one coil and two capacitors,
  and keeps oscillating by feeding part of the output back to the input through the voltage division of the two capacitors.
  The collector connects to Vcc through L1, so L1 serves both as "part of the tank" and as "the collector load"
  (normally this is where an RFC, a radio-frequency choke, a coil that blocks only high frequency, would go).
- **Feedback**: The junction of C1 and C2 is the emitter. The series combination C<sub>s</sub> of C1 and C2 and L1
  set the oscillation frequency: f<sub>0</sub> = 1 / (2π√(L1·C<sub>s</sub>)).
- **Common base**: C3 (0.001 µF) drops the base to GND at high frequency (about 2 Ω at 80 MHz).
  Fixing the base to GND at high frequency, feeding in at the emitter and taking out at the collector is called common-base operation.
  This makes a common-base Colpitts, and the feedback returned to the emitter through the C1 and C2 divider
  takes effect. C3 has almost no effect at audio frequencies (about 160 kΩ at 1 kHz), so the audio of the microphone
  stays on the base. Cb (0.1 µF) is the supply bypass capacitor and drops the supply side of L1 to GND at high frequency.
- **Direct FM**: The audio of MIC (electret microphone) is coupled to the base through Cmic.
  When the DC potential of the base wobbles slightly, the base-emitter capacitance (C<sub>be</sub>) of Q1 also
  changes slightly, and together with C2 it makes the capacitance of the tank wobble, which moves the frequency.
- **Antenna**: The signal is taken from the collector through the small coupling of Cant (2.2 pF). The weaker the coupling,
  the lighter the load on the oscillator and the weaker the radiation (which is exactly the condition for very-low-power radio).

**Calculated oscillation frequency**: C<sub>s</sub> = C1·C2/(C1+C2) = 22p·47p/69p ≈ 15 pF.

f<sub>0</sub> = 1 / (2π√(260 nH × 15 pF)) **≈ 80.6 MHz (about 80 MHz)**. The resonant frequency
is set only by L1, C1 and C2 and does not depend on the supply voltage, so even if you reselect Rb1 and Rb2 to
suit the supply voltage, the frequency stays the same.

**Calculated operating point** (V<sub>CC</sub> = 5 V, design value h<sub>FE</sub> = 100, V<sub>BE</sub> = 0.6 V,
Rb1 = 10 kΩ, Rb2 = 2.4 kΩ, Re = 470 Ω): reducing the base divider to the equivalent of a supply and a resistor
(V<sub>th</sub> = 5 V × 2.4k/12.4k ≈ 0.97 V, R<sub>th</sub> = Rb1∥Rb2 ≈ 1.9 kΩ) gives
I<sub>C</sub> = (V<sub>th</sub> − V<sub>BE</sub>) / (Re + R<sub>th</sub>/h<sub>FE</sub>) ≈ 0.37 V / 489 Ω
**≈ 0.75 mA** and V<sub>CE</sub> ≈ 4.6 V.
The h<sub>FE</sub> of the 2SC3355 is wide, 50–300 (the guaranteed value at V<sub>CE</sub> = 10 V, I<sub>C</sub> = 20 mA
[[1]](#sources)), but R<sub>th</sub>/h<sub>FE</sub> is small compared with Re, and I<sub>C</sub> stays within
**0.72–0.77 mA**: about 0.72 mA at h<sub>FE</sub> = 50 and about 0.77 mA at h<sub>FE</sub> = 300.
The guaranteed value is for I<sub>C</sub> = 20 mA and is lower at 0.75 mA, but even with h<sub>FE</sub> = 30, for example, I<sub>C</sub> is
about 0.69 mA, so the operating point hardly depends on h<sub>FE</sub> (this is why Re is included and
the base is biased stiffly). With Rb2 at 4.7 kΩ,
I<sub>C</sub> rises to about 2.0 mA. Oscillation holds even with more current, but
this exercise uses 2.4 kΩ for Rb2 to hold I<sub>C</sub> down to 0.75 mA.

Spreading the turns of the coil a little (which lowers the effective inductance) raises the frequency, and
squeezing them together lowers it. In practice, adjusting by one turn of the coil moves it by several MHz, so
**tune to the quietest frequency (with no broadcast station) on a nearby FM radio**.

## Wiring diagram

**Why a copper-clad board**: This circuit oscillates at around 80 MHz. That is far above the guideline for a breadboard (3 MHz or less)
and for a perfboard (10 MHz or less). The tank is only 15 pF and 260 nH, and the capacitance between holes
and pins that get long to fit the hole pitch would shift the oscillation frequency and the oscillation condition. So the parts are built on
a copper-clad board whose back is an unbroken GND plane, by the Manhattan method, which bridges parts from island to island with short pins.
There is one island per node of the schematic, and the GND nodes are not islands: they go straight down to the GND plane on the back through a via (a hole drilled
through the copper-clad board, with a wire through it soldered to both the island on the front and the copper on the back).
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
  (as in "Spreading the turns of the coil a little" above) to tune to around 80 MHz**. The longer the pins, the lower the frequency, so
  cutting them short and closing up the gaps between islands is where this way of building pays off.
- **Why not a perfboard**: Parts are bridged to fit the hole pitch (2.54 mm), so the pins tend to be longer than in
  the present figure, which bridges island to island, and there is no continuous GND plane on the back. That is enough for circuits of 10 MHz or less,
  but it does not suit a circuit that must get a 15 pF, 260 nH tank right at 80 MHz.

**Checking the range**: The voltage of 5 V, current I<sub>C</sub> ≈ 0.75 mA (the value before oscillation; it can rise to the 3 mA range while oscillating, but the power is under 20 mW, within 100 mW), and frequency around 80 MHz are within
the range of the copper-clad board (above 10 MHz up to 1 GHz). The island width is at least 4 mm (3 mm or more). The gap between islands is
at least 1.5 mm (0.3 mm or more). No mains power is used.

```copper
# Copper-clad board dimension drawing (tommie-fence copper fence)
board:
  size: 70x50mm
  ground: back
title: Fig. 2 Building it on a copper-clad board (Manhattan)
f: 80M
copper:
  VCC: pad 31,7 46x4mm
  VA: pad 10,11 4x6mm
  VB: pad 25,11 4x6mm
  MIC: pad 13,24 8x4mm
  BASE: pad 29.5,24 15x4mm
  COL: pad 48,18 14x4mm
  EMI: pad 48,30 14x4mm
  ANT: pad 61,18 4x4mm
  GCb: pad 17,16 4x4mm
  VCb: via 17,16
  GMIC: pad 13,34 4x4mm
  VMIC: via 13,34
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
  Rmic: resistor 10,13 10,23 2.2k
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
  PWR:
    type: device
    at: -14,8
    label: AD3 Supplies 5V
    pins: V+ GND
    face: right
  MK:
    type: device
    at: 14,60
    label: Microphone
    pins: "- +"
    face: top
  WIRE:
    type: device
    at: 80,12
    label: Antenna wire 20cm
    pins: A
    face: left
wires:
  - PWR.V+ -- 8.5,6 red
  - PWR.GND -- 11,34 black
  - MK.+ -- 16,25.5
  - MK.- -- 13,36 black
  - WIRE.A -- ANT
```

![Copper-clad board dimension drawing](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/copper/04-fm-transmitter-1.svg)

- The copper-clad board is 70×50 mm, a 5×7 cm board (the first of the standard copper-clad boards, and the layout fits) laid sideways. It is FR-4, 1.6 mm, double-sided 1 oz.
  Strip the copper on the front so that only the islands in the figure remain (or glue small pieces of copper sheet on as islands), and **make the copper on the back
  all GND**. The lower row of the figure is the view from the back. The round marks are vias (holes that drop to the GND on the back, and their islands). The islands are kept
  at least 5 mm from the edge of the copper-clad board. A 1 cm margin could not be taken.
- **Correspondence between the islands in the figure and the nodes of the schematic** (the netlist of `copper-fence check` agrees with the connections of the schematic)

  | Island in the figure | Node of the schematic (connected pins) |
  | --- | --- |
  | VCC (including the extensions VA and VB) | +5 V (top of Cb, top of L1, top of Rb1, top of Rmic) and the + of the supply (PWR.V+). The upper strip |
  | MIC | Bottom of Rmic, left of Cmic and the + of the microphone (MK.+) |
  | BASE | Base of Q1, right of Cmic, bottom of Rb1, top of Rb2, top of C3 |
  | COL | Collector of Q1, bottom of L1, top of C1, left of Cant |
  | EMI | Emitter of Q1, bottom of C1, top of C2, top of Re |
  | ANT | Right of Cant and the antenna wire (WIRE.A). Solder the antenna wire here |
  | GND (via islands) | Bottoms of Cb, Rb2, C3, C2 and Re, and the − of the supply (PWR.GND) and the − of the microphone (MK.-). **All go through vias to the GND plane on the back** |

- Spread the 3 pins of Q1 (2SC3355L-T92) onto 3 islands (BASE, COL, EMI) and solder them. The black half circle in the figure is the body of Q1,
  and B goes to the left island (BASE), C to the upper right island (COL) and E to the lower right island (EMI). Seen with the flat face toward you, the 2SC3355L-T92 has
  B, E, C from the left (the terminal table of the datasheet says 1 = B, 2 = E, 3 = C [[1]](#sources)), which
  is a different order from the E, C, B of the commonly used 2SC1815. While looking at the flat face, bend the pins and bridge them to these 3 islands
  (the arrangement of the islands in the figure is not changed; the way the pins are bent makes it fit).
  The order can differ between manufacturers, so before building, insert the part into the hFE terminal of the multimeter
  (the terminal for checking the pin order of a transistor) and confirm the B, E, C direction on the real part.
- There are 3 instruments outside the copper-clad board (the black boxes in the figure). The wires make no copper and are soldered on top of the islands.
  **Supplies (V+ = 5 V) of the AD3**: the + (red) goes to the left end of the upper VCC strip, and the − (black) goes to the lower left GND island (the via of GMIC).
  The **microphone** (electret) sits below the copper-clad board, with + to the MIC island and − to the GND island (GMIC).
  The **antenna wire** sits to the right of the copper-clad board and is soldered to the ANT island. The wires are routed so that none passes over a part or text.
- **Keep the antenna wire to about 20 cm** (soldered to the ANT island in the figure; extending it easily exceeds the Radio Act limit.
  Keep the coupling capacitor Cant (2.2 pF) at the specified small value too).
- Keep the high-frequency wiring (L1, C1, C2, Q1) as short as possible. In particular keep the pins of C1 and C2 to around 10 mm.
- L1 is enameled wire of 0.6 mm diameter wound 8 turns on a 8 mm round rod, with both ends bent to
  match the islands (the inductance is a rough guide and shifts when measured). How far you spread the turns tunes the frequency.
- Rb1 (from +5 V, above), Cmic (left), and Rb2 and C3 (below, to GND) meet at the base (BASE).
  The audio of the microphone enters the base from the MIC island through Cmic.
- Decide the layout on paper before building, and after cutting out the islands, check the continuity between islands and the GND plane with a multimeter
  (to see that no leftover copper shorts them).

## Parts

| Symbol | Value / part number | Notes |
| --- | --- | --- |
| Q1 | 2SC3355L-T92 (UTC, TO-92) | 20 yen each at Akizuki. f<sub>T</sub> 7 GHz (typ), C<sub>re</sub> ≤ 1.0 pF |
| L1 | 260 nH | Wind enameled wire of 0.6 mm diameter 8 turns on a round rod of 8 mm diameter. Shifts when measured |
| C1 | 22 pF | Ceramic |
| C2 | 47 pF | Ceramic |
| C3 | 0.001 µF | Ceramic |
| Cant | 2.2 pF | Ceramic |
| Cb, Cmic | 0.1 µF | Ceramic |
| Rb1 | 10 kΩ | |
| Rb2 | 2.4 kΩ | |
| Re | 470 Ω | |
| Rmic | 2.2 kΩ | For biasing the microphone |
| MIC | Electret microphone | When trying it with your voice |
| Rin, Rd | 10 kΩ, 100 Ω | When trying it with W1 of the AD in place of the microphone (remove Rmic) |
| Signal source | W1 of the Analog Discovery 3 | 1 kHz, 1 Vpp sine wave |
| Power supply | 5 V (V+ of Supplies on the AD3) | Consumption is about 1–3 mA (it rises while oscillating, as in "Comparison with LTspice" below), within about 50 mA for one supply channel of the AD3. The current in the copper-clad board is also within the range of the copper-clad board (500 mA) |
| Instrument | tinySA Ultra | For confirming Fig. 3. It picks up with its supplied antenna (not connected directly to the copper-clad board) |

**Why the 2SC3355 was chosen for Q1**: This circuit oscillates at around 80 MHz. Oscillation requires that the current gain |h<sub>fe</sub>| of the
transistor at that frequency be well above 1. |h<sub>fe</sub>| falls as the frequency rises, and the frequency at which it falls to 1 is called f<sub>T</sub> (the transition frequency). The ordinary small-signal
2SC1815 has a guaranteed f<sub>T</sub> of at least 80 MHz (V<sub>CE</sub> = 10 V, I<sub>C</sub> = 1 mA), so at 80 MHz
|h<sub>fe</sub>| can fall to 1 in the worst case, and **a margin for oscillation cannot be guaranteed**. So the 2SC1815 was not chosen.
The 2SC3355 (UTC, for high-frequency low-noise use) has an f<sub>T</sub> of 7 GHz (typ, V<sub>CE</sub> = 10 V, I<sub>C</sub> = 20 mA),
a margin of almost two orders of magnitude over 80 MHz, and its C<sub>re</sub> is small too, at most 1.0 pF
(the C<sub>ob</sub> of the 2SC1815 is about 3.5 pF).
The main ratings are V<sub>CEO</sub> 12 V, V<sub>CBO</sub> 20 V, V<sub>EBO</sub> 3 V, I<sub>C</sub> 100 mA,
P<sub>C</sub> 600 mW (TO-92) and h<sub>FE</sub> 50–300. The V<sub>CE</sub> ≈ 4.6 V and I<sub>C</sub> ≈ 0.75 mA of this circuit are well within
all of them. The noise figure of 1.1 dB (typ, 1 GHz) in the datasheet is not used in this circuit.

## Instrument settings

This exercise has no oscilloscope figure. The carrier is at 80 MHz, outside the range of Scope on the AD3 (10 MHz or less), so the waveform cannot be seen.
It is confirmed with the tinySA spectrum in Fig. 3. The power and the modulation signal come from the AD3 (Supplies, W1).

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
and the RBW to about 10 kHz to read it. Because of the stray capacitance of the islands and the inductance of the pins, the carrier is expected to appear between **73 and 80 MHz**, and
you **spread the turns of the coil a little to tune to 80 MHz** (spreading raises it).

## Instrument screen

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 3 80MHz carrier and harmonics (estimate)
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

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/spectrum/04-fm-transmitter-1.svg)

- **All the heights in the figure are rough guides (estimates)**. There are three assumptions. (1) The carrier is picked up by the tinySA at several tens of centimeters from
  the 20 cm antenna and the 2.2 pF coupling at **−50 dBm** (it moves by ±15 dB with the direction of the antenna and reflections from the desk and your hand).
  (2) The 2nd harmonic is 20 dB below the carrier (**−70 dBm**) and the 3rd is 30 dB below (**−80 dBm**). In a one-transistor Colpitts the harmonics are reduced by the resonance of the tank,
  but the collector current is distorted, so that much is assumed to remain. (3) How easily each harmonic is picked up differs with frequency
  and the gain of the antenna also changes, so the real thing can be off by ±10 dB or more.
- The real carrier swings by tens of kHz around 80 MHz with the voice of the microphone. At RBW 100 kHz it looks like a single line
  (to see this swing, narrow the span to 10 kHz and the RBW to 200 Hz, as in "Trying it with the AD signal generator (1 kHz) in place of the microphone" below).
- Lines from nearby FM broadcast stations (76–95 MHz) may appear separately on the screen. When one is confused with the carrier,
  turn off the power of the transmitter and take the one that disappears as the carrier.

## Trying it with the AD signal generator (1 kHz) in place of the microphone

A voice is different every time, so to check how the modulation looks it is more repeatable to put in **a 1 kHz sine wave from signal generator W1 of the Analog Discovery 3 (AD3)** in place of
the microphone. The output of an electret microphone is only a few mV to a few tens of mV (rms)
at a normal speaking volume. W1 is unstable at small amplitudes, so **output 1 Vpp, divide it down to 1/100 with resistors**, and
feed it to the base through the same Cmic.

**Settings of W1**: Set W1 of Wavegen to Simple, waveform Sine, frequency 1 kHz, amplitude 500 mV (peak, 1 Vpp), offset 0 V.
The divider is two E24 resistors, Rin (10 kΩ) and Rd (100 Ω), and **the MIC node is 1 Vpp × 100 Ω / (10 kΩ + 100 Ω) ≈ 9.9 mVpp**
(about 3.5 mVrms; 9–10 mVpp counting the base side as the load). It is matched to the lower end of the typical range of a voice (a few mV to a dozen or so mV rms).
1 kHz is the middle of the voice band, and above the corner of the high-pass formed by Cmic (0.1 µF) and the resistance seen from the base (a few kΩ)
(a few hundred Hz). Always connect the GND of W1 to the − of the supply (the GND of the circuit).

The Rmic (2.2 kΩ) for biasing the microphone is not needed here, so remove it (W1 passes no DC, and if Rmic stays it would sit in parallel
with the lower side of the divider and shift the 100 Ω value).

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 4 AD W1 (1kHz) divided down in place of the mic
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

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/04-fm-transmitter-2.svg)

**Build the copper-clad board as in Fig. 2, but drop the microphone box and Rmic and change it as follows.**
The instruments outside the copper-clad board are the AD3 (V+ of Supplies, W1, GND) and the antenna wire. W1 of the AD3 goes to the island below Rin (VIN), and
GND goes to the same GND island (on the back plane) as the − of the supply. V+ goes to the VCC strip as in Fig. 2. Rin (10 kΩ) goes from VIN to the MIC island, and Rd (100 Ω) goes from
the MIC island to a GND island (via). The upper VA island in Fig. 2 is not used, so do not cut it out.
The netlist of `copper-fence check` agrees with the schematic of Fig. 4 (VIN = the node of W1 and Rin, MIC = the node of Rin, Rd and Cmic).

```copper
# Copper-clad board dimension drawing (tommie-fence copper fence)
board:
  size: 70x50mm
  ground: back
title: Fig. 5 Mic removed, W1 divided down to MIC island
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

![Copper-clad board dimension drawing](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/copper/04-fm-transmitter-2.svg)

**What to see on the tinySA Ultra.** When modulated with a 1 kHz sine wave, lines stand on both sides of the carrier at ±1 kHz, ±2 kHz, and so on.
These lines on both sides of the carrier are called **sidebands**.
However, **in a wide sweep it stays a single line**: at RBW 100 kHz (Fig. 3) the swing is a few kHz, so it fits within the line of the carrier and
**the frequency swing cannot be seen** (even with a span of 200 kHz and RBW 3 kHz, ±1 kHz is narrower than the RBW and the line only gets a little thicker without separating).
To see the ±1 kHz sidebands separately, **center on the carrier and narrow to a span of 10 kHz and RBW 200 Hz** (the narrowest RBW of the tinySA Ultra).
With RBW 200 Hz, ±1 kHz is 5 times the RBW away and appears as separate peaks. The sweep is slow (tens of seconds), so
do not let your hand or the desk touch the copper-clad board, so the carrier does not move, and let it warm up for about 5 minutes before you look. Even so, a free-running LC oscillator can drift
by a few kHz, and when a peak leaves the screen, center it again.

**Assumptions for the calculated values** (the modulation depth is an estimate and the real one can be off by a factor of a few in either direction).

1. The total carrier power is −50 dBm, the same as Fig. 3 (picked up at several tens of centimeters)
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
J<sub>3</sub> = 0.073), and subtracting 20 log<sub>10</sub>|J<sub>n</sub>| from the total of −50 dBm gives the following (Fig. 6).

| Line | Frequency | Estimate |
| --- | --- | --- |
| Carrier | 80 MHz | −56.8 dBm |
| ±1 kHz sidebands | 80 MHz ± 1 kHz | −54.9 dBm (about 2 dB higher than the carrier) |
| ±2 kHz | 80 MHz ± 2 kHz | −61.8 dBm |
| ±3 kHz | 80 MHz ± 3 kHz | −72.8 dBm |

```spectrum
# Spectrum analyzer screen (tommie-fence spectrum fence)
title: Fig. 6 1kHz sidebands of the carrier (estimate)
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

![Spectrum analyzer screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/spectrum/04-fm-transmitter-2.svg)

- The real carrier appears somewhere between 73 and 80 MHz, so the 80 MHz in the figure is how it looks after "spreading the coil to tune to 80 MHz"
  (the same assumption as Fig. 3). Center on the carrier of the real circuit.
- When you speak into the microphone, the deviation becomes several times the estimate above, depending on a voice of a few mV to a few tens of mV.
  With the 1 kHz of W1, 5 to 7 peaks standing in a row are **a sign that modulation is really applied**. If you stop W1, it returns to a single carrier line (−50 dBm).
  When no sidebands appear (or too many), the deviation changes in proportion to the amplitude of W1 (for small β, J<sub>1</sub> is proportional to β).
- Received on a nearby FM radio, you hear the 1 kHz tone (a beep) of W1. It is easier to tell apart than a voice, and the pitch stays at 1 kHz
  even when you change the coil turns, the antenna or the receiving position.
- **Safety**: The output of W1 is small, 1 Vpp, and only 5 V DC is applied to the circuit. The radio waves follow the same rules as with a voice:
  keep the antenna wire at 20 cm, keep Cant at 2.2 pF, run the experiment indoors for a short time, and do not leave it transmitting
  (as in the warning above, a very-low-power station is limited to 500 µV/m at a distance of 3 m). Do not raise the signal of W1 to gain deviation
  (the occupied frequency width would widen).

## Values to check

A mix of calculated and measured values.

| What to check | Expected value |
| --- | --- |
| Reception on a nearby FM radio | Noise changes at a **quiet frequency** near 80 MHz (calculated value) |
| Speak into the microphone | Your voice is heard from the radio (quietly and with some distortion) |
| Spread the coil turns a little | The received frequency moves upward |
| Remove the antenna | It is received only within several tens of centimeters (a guide that it is within the Radio Act limit) |
| Marker 1 (carrier) of the tinySA | Between 73 and 80 MHz (an estimate from the pins and stray capacitance). Spread the coil to tune to **80 MHz** |
| Height of marker 1 of the tinySA | About −50 dBm (when picked up at several tens of centimeters, a rough guide. ±15 dB) |
| Marker 2 (160 MHz, 2nd harmonic) | About −70 dBm (20 dB below the carrier, assumption) |
| Marker 3 (240 MHz, 3rd harmonic) | About −80 dBm (30 dB below the carrier, assumption). Above the RBW 100 kHz floor (−97 dBm) |
| Feeding W1 (1 kHz, 1 Vpp) through the divider: the MIC node | About 9.9 mVpp (divider of Rin 10 kΩ and Rd 100 Ω, calculated value) |
| Span 10 kHz, RBW 200 Hz, marker 1 (carrier) | The center line. About −56.8 dBm (assuming modulation index β ≈ 1.6, a rough guide) |
| Markers 2 and 3 (80 MHz ± 1 kHz, sidebands) | About −54.9 dBm. About 2 dB higher than the carrier. ±2 kHz is about −61.8 dBm and ±3 kHz is about −72.8 dBm (estimates; the real ones can be off by a factor of a few in either direction) |
| Stop W1 | The sidebands vanish and it returns to a single carrier line (about −50 dBm). The 1 kHz tone on the radio also stops |

## Verification with LTspice

**Comparison with LTspice**: In `sim/04-fm-transmitter.cir`, the circuit of Fig. 1 was run as a transient analysis from the supply turning on (50 ns), and the oscillation frequency and operating point were read.
Q1 is a substitute model for the 2SC3355 (the same IS, BF, VAF, IKF and RB as the 2SC1815 in `sim/agc.cir`, with TF = 23 ps to match an f<sub>T</sub> of 7 GHz,
CJE = 1 pF and CJC = 0.6 pF; an assumption made from typical values, not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Operating point (DC without oscillation) | I<sub>C</sub> ≈ 0.75 mA, V<sub>CE</sub> ≈ 4.6 V | 0.69 mA, 4.67 V (V<sub>BE</sub> = 0.63 V) | Agrees (the text assumes V<sub>BE</sub> = 0.6 V. With 0.63 V the current is about 10% less) |
| Oscillation frequency (ideal: no stray capacitance, no capacitance of Q1, no Cant) | ≈ 80.6 MHz | 80.4 MHz | Agrees |
| Include the capacitances of Q1 (C<sub>be</sub>, C<sub>bc</sub>) | Not counted in the text | 79.3 MHz (about 1 MHz lower) | Smaller than the estimate of "a little over 3% from C<sub>re</sub>" in the text |
| Further connect Cant (2.2 pF) to a 50 Ω load | Not counted in the text | 74.1 MHz (about 5 MHz lower) | Added note (below) |
| Add 1.4 pF of island stray capacitance to COL | Several MHz lower | 71.3 MHz (2.7 MHz lower with Cant) | Agrees |
| Island 1.4 pF + 14 nH of pins of C1 and C2 | 73 to 75 MHz range | 74.3 MHz without Cant, 70.1 MHz with Cant | Agrees (the value without Cant is the same as the 73–75 MHz estimate in the text) |

The "73–80 MHz" in the text does not count the effect of Cant. Cant (2.2 pF) acts directly as a capacitance in parallel with COL, to the extent that the antenna wire beyond it looks like a load near GND
(the 50 Ω row above is the estimate on the side where it matters most). A 20 cm antenna wire has a capacitance of a few pF to GND, so the real drop is smaller than the 50 Ω row.
Either way, read it as the island, pins and Cant can lower it to 70–75 MHz, and **the procedure of spreading the coil turns to tune to 80 MHz does not change**.
**Current**: The 0.75 mA above is the value without oscillation. While oscillating, the swings of C1 and C2 rectify the base and raise the average I<sub>C</sub>; in this model it reached the 3 mA range,
and the collector swing was 12–13 Vpp (up and down around the 5 V supply). This size is a rough guide that moves a lot with the model of Q1 and the coupling assumptions, and it is not measured
(it does not exceed V<sub>CBO</sub> of 20 V, but it is close to V<sub>CEO</sub> of 12 V. In the real circuit the swing should be smaller because of the losses of L1 and Q1). The supply current is expected from the 1 mA range to the 3 mA range,
and the power is under 20 mW, within the AD3 supply (about 50 mA) and the range of the copper-clad board (100 mW or less).
The modulation depth (β ≈ 1.6), the tinySA heights and the dBm of the harmonics are estimates based on assumptions about the antenna and coupling, and were not run here (out of scope).

## Sources

Original work. The technical standard for very-low-power radio stations in the Radio Act (322 MHz or below, 500 µV/m at a distance of 3 m) is from
Article 6 of the Enforcement Regulations for the Radio Act, Ministry of Internal Affairs and Communications.

1. UNISONIC TECHNOLOGIES 2SC3355 datasheet
   ([https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf)).
   f<sub>T</sub>, C<sub>re</sub>, h<sub>FE</sub>, the ratings and the pin order (B, E, C for TO-92) come from it.
   The f<sub>T</sub> and C<sub>ob</sub> of the 2SC1815 come from the Toshiba datasheet.
