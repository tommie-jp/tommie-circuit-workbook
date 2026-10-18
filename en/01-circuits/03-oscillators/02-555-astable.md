---
book: circuits
chapter: 3
id: 3-2
title: 555 Astable, Blinking an LED
tier: 50
source: 自作
board: BB
ja: 952e08121fa259cf7a3893597afad7330fd7208a
---

# 3-2 555 Astable, Blinking an LED

Connect the classic timer IC **NE555** (the IC that made the square wave in 0-3) as an astable circuit and
blink an LED. It is the same "astable" as the two-transistor circuit of 3-1, but the period is set by just two resistors and
one capacitor, so it tends to behave as calculated. The 555 contains two comparators (circuits that compare voltages),
a circuit that remembers whether the output is High or Low (a flip-flop, Chapter 10), and a discharge transistor.
When the voltage of C1 rises to 2/3 of the supply (2/3 of Vcc), the output goes Low and C1 discharges, and
when it falls to 1/3, the output returns to High and C1 charges. This repeats the charging and discharging.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 555 astable
parts:
  V1: vsource 4,3 4,9 5
  VCC: vcc 4,3 5V
  G1: ground 4,9
  U1: ic 10,5 NE555
  VCC: vcc 7,2 5V
  Ra: resistor 7,2 7,4.5 10k
  Rb: resistor 7,4.5 7,6.5 47k
  C1: ecap 8,6.5 8,9 10u
  G3: ground 8,9
  VCC: vcc 10,2 5V
  G2: ground 10,9
  Cc: capacitor 12,7 12,9 10n
  G5: ground 12,9
  R1: resistor 13,5 15,5 220
  D1: led 15,5 15,7 red
  G4: ground 15,9
wires:
  - U1.8 |- 10,2
  - U1.4 |- 10.5,2
  - 10,2 -- 10.5,2
  - U1.7 -| 7,4.5
  - U1.6 -| 8,5
  - U1.2 -| 8,5.5
  - 8,5 -- 8,6.5
  - 7,6.5 -- 8,6.5
  - U1.1 |- 10,9
  - U1.5 |- 10.5,7
  - 10.5,7 -- 12,7
  - U1.3 -| 13,5
  - 15,7 -- 15,9
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/circuit/02-555-astable.svg)

- **Connecting pin 2 (TRIG) directly to pin 6 (THRES)** in Fig. 1 is the mark of the astable connection. The voltage at this one point
  keeps moving up and down between 1/3 Vcc and 2/3 Vcc, and pin 3 (OUT) flips in step with it
- **Pin 7 (DISCH) is the midpoint of Ra and Rb.** C1 charges through Ra + Rb, and
  when it discharges, the internal transistor pulls pin 7 to GND and the current goes through Rb only.
  Discharging is faster than charging, so the 555 astable **always has a longer High time**
- Cc (0.01 µF = 10 nF) suppresses noise on pin 5 (CONT). The circuit oscillates without it,
  but it is standard practice to add it

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top rails are +5V/GND, and the bottom rails are also +5V/GND (joined top to bottom in column 1)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 10k
  Rb: resistor a11 a15 47k
  C1: capacitor/electrolytic i9(+) i5(-) 10uF
  Cc: capacitor d13 d20 10n
  R1: resistor g12 g16 220
  D1: led h16(A) h19(K) red
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - c15 -- c12 orange
  - d12 -- d9 orange
  - e9 -- f9 orange
  - g9 -- g11 orange
  - c20 -- -t20 black
  - j5 -- -b5 black
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j19 -- -b19 black
  - SC.1+ -- j12 yellow
  - SC.1- -- -b14 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/breadboard/02-555-astable.svg)

- In Fig. 2, the **DIP8 (8-pin IC) is plugged in across the trench** (rows e and f). Pin 1 (GND) is f10 at the lower left and pin 8 (VCC) is
  e10 at the upper left. Point the notch to the left
- Pin 2 (TRIG, f11) is in the lower block, so it is carried to pin 6 (THRES, e12) in the upper part of the breadboard by
  the orange wires going around the left of the IC (`d12 -- d9`, `e9 -- f9`, `g9 -- g11`). The + of C1 goes into this column 9
- Rb (47 kΩ) spans 4 holes to the right from the right end of Ra (column 11, pin 7) and goes into column 15, and a short orange wire returns from column 15 to column 12 (pin 6)
- Pin 4 (RESET) is not used, so it is fixed to +5 V (`i13 -- +b13`). Left floating, it
  can cause malfunctions

- Power comes from the Supplies tool of the AD3 (set V+ to 5 V). The circuit draws about 6.8 mA for the LED and a few mA for the 555, within the 50 mA of V+ (250 mW on USB power).
  V+ goes to the top + rail and GND to the top − rail, and the wires in column 1 carry them to the bottom rails
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. Plug 1+ (yellow) into `j12` of pin 3 (OUT, column 12), and plug 1− (black) into the bottom − rail (GND)

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise looks at the shape and timing of a slow square wave of about 1 Hz, far slower than 10 MHz.
Connect pin 3 (OUT) to CH1 and read the High time and the period.

| Setting | Value |
| --- | --- |
| Scope CH1 (pin 3 OUT, column 12) | DC, 1 V/div |
| Time | 200 ms/div (about 2.8 periods fit in 2 s) |
| Trigger | CH1, rising edge, 1.8 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 555 output (pin 3), High about 0.40 s, period 0.72 s
time: 200ms/div
trigger: ch1 rising 1.8V
ch1: {wave: pulse 1.386Hz 1.75V offset 1.75V duty 55%, range: 1V/div}
cursors: [1ms, 396ms]
measure: [vmax, freq]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/scope/02-555-astable.svg)

Fig. 3 is an expected waveform from calculated values (High about 3.5 V, Low taken as 0 V), not a measurement. The cursor spacing of 395 ms is the High time (while the LED is on).
Subtracting it from one period (about 0.72 s) leaves the Low time of about 0.33 s. High is slightly longer, so the duty cycle is about 55 %.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Timer IC | NE555 |
| Ra | Resistor | 10 kΩ |
| Rb | Resistor | 47 kΩ |
| C1 | Electrolytic capacitor (timing) | 10 µF |
| Cc | Ceramic capacitor (noise suppression for CONT) | 0.01 µF |
| R1 | Resistor (LED current limit) | 220 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of the AD3 Supplies) |
| — | Instrument | AD3 Scope 1+ (pin 3 OUT) |

## Values to check

Time the on and off intervals with a stopwatch over 10 cycles and divide by 10, or look at the waveform of pin 3 on the oscilloscope (0-3) (Fig. 3).

Calculated values. f = 1.44 / {(Ra + 2Rb) × C}, the High time is (Ra + Rb) × C × 0.693, and
the Low time is Rb × C × 0.693.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Frequency of pin 3 (OUT) | about 1.39 Hz (period about 0.72 s) | Set by Ra, Rb and C1 alone |
| Low time (LED off) | about 0.33 s | Rb × C1 × 0.693 |
| High time (LED on) | about 0.40 s | (Ra + Rb) × C1 × 0.693 |
| Duty cycle (fraction of High) | about 55 % | (Ra+Rb) / (Ra+2Rb). **The 555 astable never gives exactly 50 %** |
| LED current (while on) | about 6.8 mA | (5 V − output High saturation (about Vcc − 1.5 V for a bipolar 555) − 2.0 V) ÷ 220 Ω |

As Ra approaches 0 the duty cycle approaches 50 %, but if Ra is too small,
a large current flows from Vcc through Ra into pin 7 during discharge and damages the IC (the lower limit is about 1 kΩ).
To set the duty cycle freely, see the PWM circuit with a diode in 3-6.

## Verification with LTspice

`sim/02-555-astable.cir` runs a transient analysis of Fig. 1 and reads the frequency, the High and Low times, the output level and the LED current.
The NE555 is a behavioral model (a divider of 5 kΩ × 3, two comparators and an SR latch, an output of V<sub>CC</sub> − 1.5 V for High and 0.1 V for Low, and a discharge of 10 Ω) set
from datasheet values, so it is an **assumption and not a measurement**. The LED is a model that gives 2 V (near 8 mA).

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Frequency (period) | about 1.39 Hz (0.72 s) | 1.41 Hz (0.709 s) | Match (about 1.5 % shorter from the discharge 10 Ω and the difference in the comparator thresholds) |
| High time | about 0.40 s | 0.388 s | Match |
| Low time | about 0.33 s | 0.321 s | Match |
| Duty cycle (fraction of High) | about 55 % | 54.7 % | Match |
| Output High | about 3.5 V (V<sub>CC</sub> − 1.5 V) | 3.5 V (assumed) | As set in the model |
| LED current (while on) | about 6.8 mA | 6.8 mA | Match |

## Sources

Original work.
