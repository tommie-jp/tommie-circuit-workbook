---
book: circuits
chapter: 3
id: 3-3
title: 555 monostable — a timer
tier: 50
source: 自作
board: BB
ja: 3557e26492fcd8f3b6dd311af195f1d03024cfe0
---

# 3-3 555 monostable — a timer

Wire the NE555 as a monostable. A **monostable** circuit normally rests in one state (output Low). Only when a trigger arrives does it
go to the other state (High) for a fixed time. Press the button once, and the LED lights for a set time and then turns
off by itself. This is the basic form of "press it and it runs for a fixed time", as in a stairwell light or a bedtime timer.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 555 monostable
parts:
  V1: vsource 1,3 1,5 5
  vcc: vcc 1,3 5V
  G1: ground 1,5
  U1: ic 10,7 NE555
  vcc: vcc 3,3 5V
  R2: resistor 3,3 3,5 10k
  SW1: button 3,10 3,12
  G3: ground 3,12
  R1: resistor 7,3 7,5 100k
  C1: ecap 7,7 7,9 10u
  G4: ground 7,9
  G2: ground 10,9
  Cc: capacitor 10.5,9 10.5,11 10n
  G5: ground 10.5,11
  R3: resistor 12,7 14,7 330
  D1: led 14,7 14,9 red
  G6: ground 14,9
wires:
  - 3,3 -- 10.5,3
  - U1.VCC |- 10,3
  - U1.RESET |- 10.5,3
  - 7,5 -- 7,6.5
  - U1.DISCH -| 7,6.5
  - U1.THRES -| 7,7
  - 7,6.5 -- 7,7
  - U1.TRIG -| 8.5,10
  - 3,5 -- 3,10
  - 3,10 -- 8.5,10
  - U1.GND |- 10,9
  - U1.CONT |- 10.5,9
  - U1.OUT -| 12,7
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/circuit/03-555-monostable.svg)

- In Fig. 1, **pin 2 (TRIG) is normally pulled up to Vcc through R2** (a pull-up). Pressing SW1 pulls it down to GND.
  That is the trigger, and pin 3 (OUT) goes High
- **Pins 7 and 6 are one node, shared by R1 and C1.** Only while OUT is High, R1 charges C1. When C1 reaches
  2/3 Vcc, the 555 returns OUT to Low by itself (releasing SW1 does not stop it)
- Pin 4 (RESET) is tied to Vcc. Pin 5 (CONT) is bypassed to GND with Cc (0.01 µF) to suppress noise

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# Top rails are +5V/GND, bottom rails are also +5V/GND (column 1 links the top and bottom rails)
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
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e10 NE555
  R1: resistor b7 b11 100k
  C1: capacitor/electrolytic b12(+) b15(-) 10uF
  Cc: capacitor d13 d20 10n
  SW1: button @ f4
  R2: resistor g11 g7 10k
  R3: resistor g12 g16 330
  D1: led h16(A) h19(K) red
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - a11 -- a12 orange
  - a15 -- -t15 black
  - c20 -- -t20 black
  - b4 -- -t4 black
  - i4 -- i11 orange
  - j7 -- +b7 red
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j19 -- -b19 black
  - SC.2+ -- j11 green
  - SC.1+ -- j12 yellow
  - SC.1- -- -b14 black
  - SC.2- -- -b15 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/breadboard/03-555-monostable.svg)

- In Fig. 2, **the right pin of R1 (column 11) is pin 7, and pin 6 (column 12) is joined to it by a single wire, `a11--a12`**
  (both are the same node of R1 and C1)
- SW1 (tactile switch) is a 4-pin part that straddles the gap and occupies `e4`, `f4`, `e6` and `f6`.
  **Connect the near side of the gap (row f, lower block) to pin 2 (column 11) and the far side (row e, upper block) to
  GND.** The two pins on the same side (the same block) are connected inside even when the switch is not pressed
- Pin 4 (RESET) is unused, so it is tied to +5 V (`i13 -- +b13`)

- Power comes from the AD3 Supplies (set V+ to 5 V). The circuit draws about 6 mA for the LED and a few mA for the 555, within the 50 mA of V+ (250 mW on USB power)
- The Scope is drawn as a separate box (AD3 Scope) below the breadboard. 2+ (green) goes to `j11`, pin 2 (TRIG, column 11), and 1+ (yellow) goes to `j12`, pin 3 (OUT, column 12).
  1− and 2− (black) go to the bottom − rail (GND)

## Instrument settings

Use the AD3 Scope as the oscilloscope. This exercise shows a single pulse about 1 s long, far slower than 10 MHz.
Connect CH2 to pin 2 (TRIG, the press signal) and CH1 to pin 3 (OUT, the pulse), so that one screen covers the time from the trigger to the end of the pulse.

| Setting | Value |
| --- | --- |
| Scope CH1 (pin 3 OUT, column 12) | DC, 1 V/div |
| Scope CH2 (pin 2 TRIG, column 11) | DC, 1 V/div |
| Time | 250 ms/div. Move the trigger position close to the left edge (1 division) so that the end of the pulse fits |
| Trigger | CH2, falling, 2.5 V. Set Mode to Normal or Single, then press SW1 |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 Press SW1 (CH2 Low) and OUT (CH1) goes High for 1.1 s
time: 250ms/div
trigger: ch2 falling 2.5V at -4div
ch1: {wave: = 3.5V * (step(t) - step(t - 1.1s)), range: 1V/div}
ch2: {wave: = 5V - 5V * (step(t) - step(t - 150ms)), range: 1V/div}
cursors: [10ms, 1.11s]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/03-oscillators/scope/03-555-monostable.svg)

Fig. 3 is an expected waveform from calculated values (the High level of OUT is 3.5 V, and the switch is assumed to be held for 150 ms). It is not a measurement. The moment pin 2 on CH2 falls Low, OUT on CH1 rises.
Even when the switch is released after 150 ms and pin 2 returns to 5 V, OUT does not change and returns to Low after about 1.1 s (1.1 × 100 kΩ × 10 µF).
The 1.10 s gap between the cursors is the pulse width.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Timer IC | NE555 |
| R1 | Resistor (timing) | 100 kΩ |
| C1 | Electrolytic capacitor (timing) | 10 µF |
| R2 | Resistor (TRIG pull-up) | 10 kΩ |
| SW1 | Tactile switch | — |
| Cc | Ceramic capacitor (CONT) | 0.01 µF |
| R3 | Resistor (LED current limit) | 330 Ω |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Power supply | 5 V (V+ of the AD3 Supplies) |
| — | Instrument | AD3 Scope 1+/2+ (OUT and TRIG) |

## Values to check

Calculated values. The pulse width (the time OUT is High) is T = 1.1 × R1 × C1. Measure the time with a stopwatch or with the oscilloscope of Fig. 3.
Measure the voltage at pin 3 with the multimeter's DC voltage range, between pin 3 and GND while the LED is lit.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Time from pressing SW1 until the LED goes off | about 1.1 s | R1 × C1 × 1.1 (independent of the Vcc value) |
| Voltage at pin 3 (OUT) during the pulse | about 3.5 V (equivalent to Vcc − 1.5 V) | The High output of a bipolar 555 does not swing up to Vcc. It tops out around Vcc − 1.5 V |
| SW1 released during the pulse | unchanged, goes off after about 1.1 s | Once a monostable has started, **releasing the trigger does not stop it** |
| SW1 pressed again in the middle of the pulse | not extended, goes off about 1.1 s after the first press | A 555 monostable cannot be retriggered. A trigger during the pulse is ignored (but if the button is held down until the time is up, OUT stays High until it is released) |

With R1 = 1 MΩ the pulse stretches to about 11 s (as long as the internal DISCH transistor of the 555 and the
leakage current of C1 are negligible compared with the current through R1). The "bedtime timer" in 12-1 is an application of this circuit.

## Verification with LTspice

`sim/03-555-monostable.cir` runs Fig. 1 as a transient analysis. SW1 is pressed for 50 ms at 1 s and again at 1.5 s.
The NE555 is a behavioral model (the same as `sim/02-555-astable.cir` in 3-2: comparators and an SR latch, High output of V<sub>CC</sub> − 1.5 V). It is an **assumption and not a measurement**.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Pulse width | about 1.1 s | 1.09 s (rises at 1.0005 s, falls at 2.091 s) | Match |
| Voltage at pin 3 during the pulse | about 3.5 V | 3.5 V (assumed) | As set in the model |
| Pressing again during the pulse (1.5 s) | not extended | goes off at 2.091 s (not extended) | Match |

## Sources

Original work.
