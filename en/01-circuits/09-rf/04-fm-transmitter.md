---
book: circuits
chapter: 9
id: 9-4
title: FM Transmitter (1 Transistor)
tier: 100
source: 自作
board: CB
era: 古
ja: d30bcc75de07b2422af343d36b25d0fafb2b3067
---

# 9-4 FM Transmitter (1 Transistor)

Build a one-transistor **Colpitts oscillator** in the FM broadcast band (around 80 MHz; Japanese
FM broadcasting uses 76–95 MHz), and let the voice from a microphone shift the oscillation frequency slightly.
FM (frequency modulation) sends sound by changing the **frequency** of the carrier (the AM of 9-2 changes the amplitude).
Because the voice moves the frequency of the oscillator directly, this is called direct FM.
With a little over 10 parts you can go through a complete transmitting circuit.

> [!WARNING]
> Under the Japanese Radio Act, a very-low-power radio station at 322 MHz or below needs no license if its **field strength
> at a distance of 3 m is 500 µV/m or less** (Article 6 of the Enforcement Regulations for the Radio Act). The constants of this exercise
> (short antenna, small coupling capacitor, weak bias current) are a design to stay within that limit, and
> **extending the antenna or adding a transistor to amplify is illegal without a license**.
> Run the experiment indoors for a short time, and do not leave it transmitting.

The reasons for choosing the 2SC3355 for Q1 and building on a copper-clad board, and the estimate of why the oscillation frequency drops below the calculation, are in 9-27;
the procedure for seeing the carrier and harmonics with the tinySA is in 9-28; and the procedure for modulating with the AD signal generator (1 kHz) in place of the microphone and looking at the sidebands is split out into 9-18.

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

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/circuit/04-fm-transmitter.svg)

- **Tank**: L1 (a 260 nH hand-wound coil) and C1 and C2 (the Colpitts
  divider) form a parallel resonant circuit. A Colpitts oscillator sets its frequency by the resonance of one coil and two capacitors,
  and keeps oscillating by feeding part of the output back to the input through the voltage division of the two capacitors.
  The collector connects to Vcc through L1, so L1 serves both as "part of the tank" and as "the collector load"
  (normally this is where an RFC, a radio-frequency choke, a coil that blocks only high frequency, would go).
- **Feedback**: The junction of C1 and C2 is the emitter. The oscillation frequency is set by the series combination C<sub>s</sub> of C1 and C2 and L1
  (calculation below).
- **Common base**: C3 (0.001 µF) drops the base to GND at high frequency (about 2 Ω at 80 MHz).
  Feeding in at the emitter and taking out at the collector in this way is called common-base operation, and the feedback returned to the emitter through the C1 and C2 divider
  takes effect. C3 has almost no effect at audio frequencies (about 160 kΩ at 1 kHz), so the audio of the microphone
  stays on the base. Cb (0.1 µF) is the supply bypass capacitor and drops the supply side of L1 to GND at high frequency.
- **Direct FM**: The audio of MIC (electret microphone) is coupled to the base through Cmic.
  When the DC potential of the base wobbles slightly, the base-emitter capacitance (C<sub>be</sub>) of Q1 also
  changes slightly, and together with C2 it makes the capacitance of the tank wobble, which moves the frequency.
- **Antenna**: The signal is taken from the collector through the small coupling of Cant (2.2 pF). The weaker the coupling,
  the lighter the load on the oscillator and the weaker the radiation (which is exactly the condition for very-low-power radio).

**Calculated oscillation frequency**: C<sub>s</sub> = C1·C2/(C1+C2) = 22p·47p/69p ≈ 15 pF.

f<sub>0</sub> = 1 / (2π√(L1·C<sub>s</sub>)) = 1 / (2π√(260 nH × 15 pF)) **≈ 80.6 MHz**. The resonant frequency
is set only by L1, C1 and C2 and does not depend on the supply voltage, so even if you reselect Rb1 and Rb2 to
suit the supply voltage, the frequency stays the same.

**Calculated operating point** (V<sub>CC</sub> = 5 V, design value h<sub>FE</sub> = 100, V<sub>BE</sub> = 0.6 V,
Rb1 = 10 kΩ, Rb2 = 2.4 kΩ, Re = 470 Ω): reducing the base divider to the equivalent of a supply and a resistor
(V<sub>th</sub> = 5 V × 2.4k/12.4k ≈ 0.97 V, R<sub>th</sub> = Rb1∥Rb2 ≈ 1.9 kΩ) gives
I<sub>C</sub> = (V<sub>th</sub> − V<sub>BE</sub>) / (Re + R<sub>th</sub>/h<sub>FE</sub>) ≈ 0.37 V / 489 Ω
**≈ 0.75 mA** and V<sub>CE</sub> ≈ 4.6 V.
That the operating point hardly depends on the spread of h<sub>FE</sub> (50–300) is shown in 9-27. With Rb2 at 4.7 kΩ,
I<sub>C</sub> rises to about 2.0 mA. Oscillation holds even with more current, but here it is held down to 0.75 mA.

Spreading the turns of the coil a little (which lowers the effective inductance) raises the frequency, and
squeezing them together lowers it. In practice, adjusting by one turn of the coil moves it by several MHz, so
**tune to the quietest frequency (with no broadcast station) on a nearby FM radio**.

## Wiring diagram

**Building on a copper-clad board**: Because the circuit oscillates at 80 MHz, the parts are built on a copper-clad board whose back is an unbroken GND plane, by the Manhattan method,
which bridges parts from island to island with short pins (the reasons are in 9-27).
There is one island per node of the schematic, and the GND nodes are not islands: they go straight down to the GND plane on the back through a via (a hole drilled
through the copper-clad board, with a wire through it soldered to both the island on the front and the copper on the back).

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

![Copper-clad board dimension drawing](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/09-rf/copper/04-fm-transmitter.svg)

- The copper-clad board is 70×50 mm, a 5×7 cm board (the first of the standard ones) laid sideways. It is FR-4, 1.6 mm, double-sided 1 oz.
  Strip the copper on the front so that only the islands in the figure remain (or glue small pieces of copper sheet on as islands), and **make the copper on the back
  all GND**. The lower row of the figure is the view from the back. The round marks are vias (holes that drop to the GND on the back, and their islands). The islands are kept
  at least 5 mm from the edge of the copper-clad board.
- **Correspondence between the islands in the figure and the nodes of the schematic** (the netlist of `copper-fence check` agrees with the connections of the schematic)

  | Island in the figure | Node of the schematic (connected pins) |
  | --- | --- |
  | VCC (including the extensions VA and VB) | +5 V (top of Cb, top of L1, top of Rb1, top of Rmic) and the + of the supply (PWR.V+). The upper strip |
  | MIC | Bottom of Rmic, left of Cmic and the + of the microphone (MK.+) |
  | BASE | Base of Q1, right of Cmic, bottom of Rb1, top of Rb2, top of C3 |
  | COL | Collector of Q1, bottom of L1, top of C1, left of Cant |
  | EMI | Emitter of Q1, bottom of C1, top of C2, top of Re |
  | ANT | Right of Cant and the antenna wire (WIRE.A) |
  | GND (via islands) | Bottoms of Cb, Rb2, C3, C2 and Re, and the − of the supply (PWR.GND) and the − of the microphone (MK.-). **All go through vias to the GND plane on the back** |

- The body of Q1 (2SC3355L-T92) is the black half circle in the figure;
  spread B to the left island (BASE), C to the upper right island (COL) and E to the lower right island (EMI) and solder them. Seen with the flat face toward you, the 2SC3355L-T92 has
  B, E, C from the left (the terminal table of the datasheet says 1 = B, 2 = E, 3 = C [[1]](#sources)), which
  is a different order from the E, C, B of the commonly used 2SC1815. While looking at the flat face, bend the pins and bridge them to these 3 islands.
  The order can differ between manufacturers, so before building, insert the part into the hFE terminal of the multimeter
  (the terminal for checking the pin order of a transistor) and confirm the B, E, C direction on the real part.
- There are 3 instruments outside the copper-clad board (the black boxes in the figure). The wires make no copper and are soldered on top of the islands.
  **Supplies (V+ = 5 V) of the AD3**: the + (red) goes to the left end of the upper VCC strip, and the − (black) goes to the lower left GND island (the via of GMIC).
  The **microphone** (electret) sits below the copper-clad board, with + to the MIC island and − to the GND island (GMIC).
  The **antenna wire** sits to the right of the copper-clad board and is soldered to the ANT island.
- **Keep the antenna wire to about 20 cm** (extending it easily exceeds the Radio Act limit.
  Keep the coupling capacitor Cant (2.2 pF) at the specified small value too).
- Keep the high-frequency wiring (L1, C1, C2, Q1) as short as possible. In particular keep the pins of C1 and C2 to around 10 mm.
- Bend both ends of L1 (the hand-wound coil in the parts table) to match the islands.
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
| Power supply | 5 V (V+ of Supplies on the AD3) | Consumption is about 1–3 mA (it rises while oscillating, as in "Verification with LTspice" of 9-27), within about 50 mA for one supply channel of the AD3. The current in the copper-clad board is also within the range of the copper-clad board (500 mA) |
| Instrument | tinySA Ultra | For confirming 9-28. It picks up with its supplied antenna (not connected directly to the copper-clad board) |

## Instrument settings

This exercise has no oscilloscope figure. The carrier is at 80 MHz, outside the range of Scope on the AD3 (10 MHz or less), so the waveform cannot be seen.
The power comes from the AD3 (Supplies), and the transmitter is confirmed by receiving it on a nearby FM radio. The procedure for seeing the carrier and harmonics with the tinySA (how to pick it up, the input limit) and the screen are split out into 9-28.

## Values to check

A mix of calculated and measured values.

| What to check | Expected value |
| --- | --- |
| Reception on a nearby FM radio | Noise changes at a **quiet frequency** near 80 MHz (calculated value) |
| Speak into the microphone | Your voice is heard from the radio (quietly and with some distortion) |
| Spread the coil turns a little | The received frequency moves upward |
| Remove the antenna | It is received only within several tens of centimeters (a guide that it is within the Radio Act limit) |

## Verification with LTspice

**Comparison with LTspice**: In `sim/04-fm-transmitter.cir`, the circuit of Fig. 1 was run as a transient analysis from the supply turning on (50 ns), and the oscillation frequency and operating point were read.
Q1 is a substitute model for the 2SC3355 (the same IS, BF, VAF, IKF and RB as the 2SC1815 in `sim/agc.cir`, with TF = 23 ps to match an f<sub>T</sub> of 7 GHz,
CJE = 1 pF and CJC = 0.6 pF; an assumption made from typical values, not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Operating point (DC without oscillation) | I<sub>C</sub> ≈ 0.75 mA, V<sub>CE</sub> ≈ 4.6 V | 0.69 mA, 4.67 V (V<sub>BE</sub> = 0.63 V) | Agrees (the text assumes V<sub>BE</sub> = 0.6 V. With 0.63 V the current is about 10% less) |
| Oscillation frequency (ideal: no stray capacitance, no capacitance of Q1, no Cant) | ≈ 80.6 MHz | 80.4 MHz | Agrees |

The oscillation frequency with the capacitances of Q1, Cant, the stray capacitance of the islands and the inductance of the pins included (it drops to 70–75 MHz), and the current while oscillating, are in "Verification with LTspice" of 9-27.
The tinySA heights and the dBm of the harmonics are estimates and were not run here (out of scope, 9-28). The estimate of the modulation depth (β ≈ 1.6) is in 9-18.

## Sources

Original work. The technical standard for very-low-power radio stations in the Radio Act (322 MHz or below, 500 µV/m at a distance of 3 m) is from
Article 6 of the Enforcement Regulations for the Radio Act, Ministry of Internal Affairs and Communications.

1. UNISONIC TECHNOLOGIES 2SC3355 datasheet
   ([https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf)).
   f<sub>T</sub>, C<sub>re</sub>, h<sub>FE</sub>, the ratings and the pin order (B, E, C for TO-92) come from it.
