---
book: circuits
chapter: 6
id: 6-2
title: Back EMF of a coil — an LED lights the moment you switch off, the flyback diode
tier: 50
source: 自作
board: BB
ja: ccef818cfbb3cdd0146f6de1f5471f8a5e778e3b
---

# 6-2 Back EMF of a coil — an LED lights the moment you switch off, the flyback diode

A coil is a part that tries to keep the current flowing through it. When you cut the current suddenly, that tendency
appears as a voltage. This is called the **back EMF** (also called the flyback voltage). You light an LED only for the
instant the switch is opened, so that you can see this voltage with your eyes. Relays and motors are coils too, so when you
switch them on and off with a transistor you have to protect it from this voltage. Putting a diode in place of the LED to
let the back EMF escape is the **flyback diode** used in the relay drive of 7-1.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 LED lights when the coil is cut (CH1 at L1 top)
parts:
  V1: battery 2,2 2,4 5
  S1: switch 2,2 4,2
  R1: resistor 4,2 7,2 180 i=I
  L1: inductor 7,2 7,4 100m
  D1: led 9,4 9,2
  M1: voltmeter 11,2 11,4 l=$\mathrm{CH1}$
  G1: ground 2,4
wires:
  - 7,2 -- 9,2 -- 11,2
  - 2,4 -- 7,4 -- 9,4 -- 11,4
style:
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/circuit/02-back-emf.svg)

- D1 goes in parallel with L1, with the anode toward GND and the cathode toward the top of L1. It points opposite to the
  direction in which current normally flows
- When S1 is closed, a constant current I flows along the path supply (5 V) → R1 (180 Ω, sets the current) → L1 (100 mH) →
  GND. During this time the LED (D1) only has a reverse voltage across it, and does not light
- When S1 is opened, L1 tries to keep the current that was flowing and pulls the voltage at the top of L1 down at once
  (below GND). This makes D1 forward-biased, the current left in L1 flows through D1 for an instant, and the LED flashes
- Keep the supply at 5 V or less. At the moment S1 closes, no current flows in L1 yet, so the full 5 V of the supply is
  applied in the reverse direction across L1 (= across D1). The voltage an LED withstands in reverse (reverse breakdown
  voltage) is usually only about 5 V, so a higher supply may destroy it

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard (5 V from AD V+, 1+ to the top of L1)
# Top red rail = +5V, blue rail = GND
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery (Supplies V+ and Scope)
    pins: [V+, GND, 1-, 1+]
  S1: switch b3 b5
  R1: resistor b8 b12 180 cap=above:1,0
  L1: inductor/axial b15 b20 100m
  D1: led d20(A) d15(K)
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a15 orange
  - AD.1- -- -t10 black
  - +t3 -- a3 red
  - a5 -- a8 orange
  - c12 -- c15 yellow
  - a20 -- -t20 black
notes:
  - text: D1 goes in columns 15 and 20 (another row), the same as L1, in parallel with the coil
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/breadboard/02-back-emf.svg)

- The 5 V comes from V+ of Supplies on the Analog Discovery (set to 5 V in WaveForms) to the upper + rail, and GND goes to
  the − rail. The circuit current is about 24 mA, within the 50 mA per rail of Supplies (250 mW on USB power).
  Connect 1+ (orange) of Scope to column 15, the top of L1 (`a15`), and 1− (black) to the − rail (`-t10`)
- The supply + goes from column 3 through S1 (columns 3 and 5) → R1 (columns 8 and 12) → L1 (columns 15 and 20) by wires,
  and column 20 is dropped to the − rail
- D1 (LED) only needs to be placed in columns 15 and 20, the same as L1, in another row (row d), and the continuity of the
  same columns connects it in parallel with the coil
- The cathode of D1 is on the top side of L1 (column 15) and the anode on the GND side (column 20). It points the same way
  as in Fig. 1, and it lights only the moment the switch is opened

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| S1 | Switch (such as a push button) | 1 circuit |
| R1 | Resistor (1/4 W) | 180 Ω |
| L1 | Inductor (axial lead) | 100 mH (winding resistance about 25 Ω) |
| D1 | LED (5 mm) | Red, V<sub>F</sub> ≈ 2 V |
| — | Power and instruments | V+ = 5 V of Supplies on the Analog Discovery 3 (current about 24 mA) and Scope (1+ = top of L1, 1− = GND) |

## Instrument settings

The instrument is Scope of the Analog Discovery 3 (1+ = top of L1, 1− = GND). The LED lights for only about 1 ms, so
you cannot see the voltage without a waveform. Set the trigger to the falling edge of CH1 (0 V), set WaveForms to Single
(capture only once), wait, and open S1. Set the time base to 500 µs/div and the vertical scale to 1 V/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 L1 top voltage as S1 opens (approximation)
time: 500us/div
trigger: ch1 falling 0V
ch1: {wave: "= 0.61V * (1 - step(t)) - 2V * step(t) * (1 - step(t - 1.06ms))", range: 1V/div, position: 0div}
cursors: [-500us, 500us]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/06-transformers/scope/02-back-emf.svg)

Fig. 3 is an approximation that uses the calculated values under "Values to check" below. It is not a measurement. Before
S1 opens, the top of L1 shows the voltage across the winding resistance (24.4 mA × 25 Ω ≈ 0.61 V). The instant S1 opens,
the top drops to the reverse of the forward voltage of the LED, V<sub>F</sub> = 2 V (−2 V), and stays there for about
1.06 ms, until the current of L1 runs out. The current of L1 decreases with time, so the real voltage looks like it slowly
returns from −2 V to 0 V. The cursors are placed before S1 opens (−0.5 ms, 0.61 V) and after it opens (+0.5 ms, −2.00 V).
The about 1.06 ms for which −2 V lasts is the time the LED is lit, and it agrees with the "about 1 ms" in the table below
(1.06 ms is the value of L/R<sub>L</sub> × ln(1 + I R<sub>L</sub> / V<sub>F</sub>) = 0.1 H / 25 Ω × ln(1 + 0.61 / 2)).
If the contact of S1 bounces (chattering), the waveform may appear several times.

## Values to check

The values in the table are calculated values. The winding resistance of the coil (100 mH) is taken as 25 Ω (it is good to
replace it with a value measured on the multimeter's resistance range and calculate again). The forward voltage V<sub>F</sub>
of the LED is taken as 2 V. Measure the current and voltage with a multimeter while S1 stays closed. The LED lights only
for an instant, so it is easy to miss in a bright place. Darken the room and watch the LED at the moment S1 opens.

| Measure | Expected value | What it tells you |
| --- | --- | --- |
| Steady current while S1 is closed | 24.4 mA (= 5 V / (180 + 25) Ω) | Ordinary Ohm's law, set by R1 and the resistance of the coil |
| Voltage of D1 while S1 is closed | about −0.6 V (= −24.4 mA × 25 Ω. Not lit) | When the current is constant, only the voltage across the winding resistance remains across L1. It is a reverse voltage for D1, so almost no current flows |
| Energy stored in L1 at the moment S1 opens | about 30 µJ (= 0.5 × 0.1 H × 0.0244² A²) | This energy is spent in D1 as light and heat |
| Time the LED is lit (rough guide) | about 1 ms (= L × I / V<sub>F</sub> = 0.1 × 0.0244 / 2 = 1.22 ms. Including the winding resistance, 1.06 ms as in Fig. 3) | To the human eye it looks like a very short blink. A larger coil or a larger current lights it longer |

## Verification with LTspice

In LTspice (the red LED is a diode model that reaches about 1.9 V at 10 mA, and L1 is 100 mH with a winding resistance of
25 Ω; not measured), the current while closed is 24.4 mA, the top of L1 is 0.61 V, and just after S1 opens it is −1.99 V,
which agree with the calculated values. The time the top stays below −0.3 V is about 1.1 ms. Because the LED voltage
falls a little as the current falls, this is slightly longer than the 1.06 ms estimated with a constant V<sub>F</sub> = 2 V
(the deck is `sim/02-back-emf.cir`).

## Sources

Original work.
