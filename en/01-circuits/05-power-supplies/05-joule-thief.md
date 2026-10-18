---
book: circuits
chapter: 5
id: 5-5
title: Boost converter — Joule thief
tier: 50
source: 自作
board: BB
era: 古
ja: 43bc70a0a16544531aaa9ef2f0beec5973500867
---

# 5-5 Boost converter — Joule thief

Light a white LED, whose forward voltage (seen in 1-4) is around 3 V, from a single AA battery (1.5 V).
At 1.5 V a white LED does not light, so you need a **boost** circuit that makes a voltage higher than the supply.
The Joule thief uses just one transistor and a hand-wound transformer (two windings on one magnetic core), and it
switches ON and OFF by itself with no signal from outside (self-excited).
It is famous as a circuit that wrings a little more energy out of a "used-up battery", and it shows the basic action of a
switching power supply: store energy in a coil and release it at a high voltage.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Joule thief (CH1 is the Q1 collector voltage)
parts:
  B1: battery 2,2.25 2,4 1.5
  G1: ground 2,4
  VBAT: vcc 2,2.25 1.5V
  T1: transformer 5,3
  D1: led 5,5 5,7 white
  G3: ground 5,7
  Q1: npn 7,7 mirror 2SC1815
  G2: ground 7,8
  Rb: resistor 8,3 8,5 2.2k
  VBAT: vcc 6,4 1.5V
  M1: voltmeter 3,5 3,7 l=$\mathrm{CH1}$
  G4: ground 3,7
wires:
  - 2,2.25 |- T1.A1
  - T1.A2 |- 5,5
  - 5,5 -- 7,5 -- Q1.C
  - 5,5 -- 3,5
  - T1.B2 -| 6,4
  - T1.B1 -| 8,3
  - 8,5 |- Q1.B
  - Q1.E -- 7,8
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/circuit/05-joule-thief.svg)

- T1 is a transformer with two wires twisted together and wound on the same magnetic core (bifilar winding).
  Tie the start of winding A (A1) and the end of winding B (B2) to the battery +.
  Then, when the collector current of Q1 increases, the voltage at the base side of winding B (B1) is lifted and helps
  Q1 turn ON. This form, in which a change in the output pushes the input in the same direction, is called positive
  feedback. If both winding starts are tied to +, the direction reverses (negative feedback) and it does not oscillate
- The LED (D1) goes in parallel with the collector-emitter of Q1. While Q1 is ON, almost no voltage is applied to the
  LED, current flows in winding A, and energy is stored in the core. If the LED were in series with the collector, 1.5 V
  could not exceed the V<sub>F</sub> of the LED (about 3 V), no current would start to flow, and oscillation would not begin
- A coil that has its flowing current suddenly stopped produces a high voltage in an effort to keep the current flowing
  (flyback voltage; seen in detail in 6-2). Each time Q1 changes from ON to OFF, this voltage appears at the A2 side
  (the collector). A voltage higher than the battery voltage (1.5 V) is applied to the LED, and the LED lights
- Rb (2.2 kΩ) is a resistor that limits the current from winding B into the base. The peak of the collector current of Q1
  is roughly set by the base current × the current gain. With Rb = 1 kΩ the peak base current is about 2.2 mA and the
  peak collector current is about 130 mA (a rough guide from the SPICE run below), which approaches the 150 mA maximum
  rating of the 2SC1815 (a unit with high hFE exceeds it). With 2.2 kΩ they stay at about 1.0 mA and about 90 mA

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Breadboard build (1+ to Q1 collector, 1− to GND)
board: half
parts:
  T1: transformer c5(A1) c7(A2) c9(B1) c11(B2)
  Rb: resistor b9 b18 2.2k
  D1: led g7(A) g3(K) white
  Q1: transistor g16(E) g17(C) g18(B) 2SC1815
  BAT:
    type: device
    at: top
    label: Battery 1.5V (AA)
    pins: ["+", "-"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Scope)
    pins: [1+, 1-]
wires:
  - BAT.+ -- +t2 red
  - BAT.- -- -t3 black
  - +t5 -- a5 red
  - +t11 -- a11 red
  - e7 -- f7 orange
  - i7 -- i17 orange
  - e18 -- f18 green
  - j3 -- -b3 black
  - j16 -- -b16 black
  - -t29 -- -b29 black
  - AD.1+ -- h17 orange
  - AD.1- -- -b20 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/breadboard/05-joule-thief.svg)

- T1 is a homemade transformer: two enameled wires wound together (bifilar) 10 turns each on the same core. A ferrite
  toroidal core (donut-shaped) such as the FT37-43 is the standard. Strip the coating from the wire ends with sandpaper
  and plug them into row c of the upper block
- A1 (column 5) and B2 (column 11) are connected to the battery + with red wires from the upper + rail
- A2 (column 7) is carried by an orange wire to column 7 of the lower block, and a wire from i7 connects it to the Q1
  collector (column 17)
- B1 (column 9) goes through Rb (columns 9 to 18) and a green wire connects it to the base (column 18) in the lower
  block. The emitter (column 16) goes to the lower − rail
- The 1+ (orange) of the Analog Discovery goes to column 17 of the Q1 collector (`h17`) and 1− (black) goes to the lower
  − rail (`-b20`). The power is one battery. The average battery current is about 50 mA (SPICE; the peak is about 90 mA),
  which leaves no margin against the 50 mA per rail of Supplies (250 mW on USB power), so the Supplies of the AD3 is not used
  and only the Scope is used
- Q1 (2SC1815) has pins E, C, B from the left when you look at it with the flat face toward you (the row j side). Plug
  it as it is into columns 16, 17, 18 of row g
- Plug the LED with the anode in column 7 (connected to the same node as the collector) and the cathode in column 3, and
  connect column 3 to the lower − rail. This puts the LED in parallel across C-E (the emitter is also at GND). The upper
  and lower − rails are joined at column 29

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| T1 | Transformer (two wires wound bifilar, 10 turns each, on a ferrite toroidal core) | 1:1 |
| Q1 | NPN transistor | 2SC1815 |
| Rb | Resistor (base current limit) | 2.2 kΩ |
| D1 | White LED (5 mm) | V<sub>F</sub> ≈ 3.0 to 3.2 V |
| — | Instrument | Scope of the Analog Discovery 3 (1+ = Q1 collector, 1− = GND) |
| — | Power | One AA battery, 1.5 V. A partly used battery is fine. The point is to "light an LED from a single dry cell", so the default 5 V is not used |

## Values to check

The oscillation of a Joule thief depends on the properties of the core (how much magnetism it can store), so the
frequency and current cannot be fixed by calculation alone, and measuring is the basic way to find them. The table gives
rough guides to typical values.

How to measure: view the waveform on the oscilloscope of the Analog Discovery, with 1+ on the collector of Q1 (column 17
in Fig. 2; column 7, the LED anode, gives the same signal) and 1− on GND. The frequency is about 200 kHz, which is within
the range of the AD3 oscilloscope (10 MHz or less). Measure the battery current by putting the multimeter's current (mA)
range in series between the battery + and the + rail.

Fig. 3 shows the collector waveform. While Q1 is ON it falls to near 0 V, and at the moment of turning OFF it jumps up to
the flyback voltage that lights the LED. Fig. 3 is approximated by a square wave, matched to the readings of SPICE (same
conditions as above, Rb = 2.2 kΩ): a period of about 5.0 µs (about 200 kHz), about 1/3 of the time above 2 V (when the
LED is on), and a peak of about 3.5 V. In the real circuit the valley rises along a slope from 0 V to 0.8 V and the peak
sags toward the LED voltage, so the average (about 1.49 V in SPICE; the DC voltage across the coil is 0, so it equals
the battery's 1.5 V) is higher than the 1.15 V of the square wave. The real frequency changes with the core and the number
of turns, so adjust the time base (5 µs/div) to the measured period.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Q1 collector (approximation based on SPICE)
time: 5us/div
trigger: ch1 rising 1.8V
ch1: {wave: pulse 199kHz 1.73V offset 1.73V duty 33%, range: 1V/div, position: -2div}
measure: [vmax, vmin, freq, duty]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/05-power-supplies/scope/05-joule-thief.svg)

| Measure | Rough value | What it tells you |
| --- | --- | --- |
| Oscillation frequency | about 200 kHz (SPICE). The real circuit is tens to hundreds of kHz (depends on the core and turns) | How many times per second Q1 repeats ON → OFF → ON |
| Average battery current | about 47 mA (SPICE, 1.5 V) | Of the battery power 1.5 V × 47 mA = 71 mW, about 45 mW (average LED current about 14 mA, voltage about 3.3 V) reaches the LED. The rest becomes heat in Q1 and the windings |
| Peak collector current of Q1 | about 90 mA (SPICE) | Inside the 150 mA maximum rating of the 2SC1815. The average dissipation of Q1 is about 24 mW, far from 400 mW |
| Voltage across the LED (peak of the collector waveform) | about 3.5 V (SPICE) | Evidence that flyback lifts it above the battery voltage. Far from the V<sub>CEO</sub> of 50 V of the 2SC1815 |
| Battery voltage lowered to 0.8 V | Oscillation continues and the average LED current is about 2.6 mA (SPICE; the frequency rises to about 340 kHz) | The reason for the claim of wringing power out of a "used-up battery" |

Why the 2SC1815 is enough: the frequency is several hundred kHz, far below 1/3 of the f<sub>T</sub> of the 2SC1815
(80 MHz minimum), which is 27 MHz (the upper limit for switching in this book). The current peak (about 90 mA), the
voltage peak (about 3.5 V) and the dissipation (about 24 mW) are also inside the maximum ratings (150 mA, 50 V, 400 mW).

### Why does it oscillate?

While Q1 is ON, the current in winding A keeps increasing and stores energy in the core. When the rise of the current
levels off, the feedback voltage on winding B disappears and Q1 switches OFF. It levels off either when the core
saturates or when the collector current reaches the base current × the current gain and Q1 cannot pass any more; in the
SPICE run above (no saturation) the switch happens by the latter. At the moment of turning OFF, winding A tries to keep
the current flowing and its voltage jumps up (flyback), and that high voltage lights the LED. When the energy of the core
is used up during OFF, base current flows again through Rb and Q1 returns to ON.

## Verification with LTspice

The numbers in the "Rough value" column of the table are values checked with LTspice. The winding is 10 turns on an
FT37-43 (A<sub>L</sub> = 350 nH/turn²), so L = 350 nH × 10² = 35 µH, with a coupling coefficient of 0.98. The 2SC1815 is an
approximate model with a current gain of 250 (small current) and about 130 (around 100 mA) (the same as `sim/agc.cir` in
Chapter 9), and the white LED is a diode model that reaches about 3 V at 10 mA. Core saturation is not included, so the
result can differ from the real circuit by tens of percent (the deck is `sim/05-joule-thief.cir`; if you change the
assumption for the current gain, the frequency moves within 200 to 250 kHz and the battery current within 37 to 47 mA).

## Sources

Original work. Composed with reference to the Joule thief family of circuits from Talking Electronics (a bifilar
transformer + one transistor).
