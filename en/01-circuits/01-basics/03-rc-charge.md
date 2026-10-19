---
book: circuits
chapter: 1
id: 1-3
title: Charging and Discharging a Capacitor — Seeing the RC Time Constant with an LED
tier: 50
source: 自作
board: BB
ja: b41e38ec3c015537877f48394b4eb779ab579ca3
---

# 1-3 Charging and Discharging a Capacitor — Seeing the RC Time Constant with an LED

A capacitor stores charge. The larger its capacitance C (unit F, farad), the more charge it holds.
Applying a voltage does not fill it at once. It charges and discharges **gradually** through a resistor.
The rough measure of that speed is the **time constant τ (tau) = R × C** (in seconds when R is in Ω and C is in F).
Timers and oscillators (Chapter 3) use this delay as a measure of time. A changeover switch
alternates between charging and discharging, and the LED lights during discharge so that you can see the time constant.
The second half, "Viewing the time constant on the oscilloscope (no LED)", shows how to read the time constant
from the charging curve itself, without an LED.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Switching between charge and discharge
parts:
  V1: vsource 1,1 1,4 5
  G1: ground 1,4
  S1: slide-switch 5,2 mirror
  R1: resistor 1,1 4,1 1k
  C1: ecap 7,2 7,4 1000u
  G2: ground 7,4
  R2: resistor 3,3 3,4 1k
  D1: led 3,4 3,5
  G3: ground 3,5
wires:
  - 4,1 |- S1.1
  - S1.in -- 7,2
  - S1.2 -| 3,3
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/03-rc-charge-1.svg)

With the switch at position **1 (R1)**, only the path battery → R1 → C1 is connected,
and C1 charges through R1. At position **2 (R2)**, C1 is cut off from the battery,
and the charge stored in C1 discharges through R2 and the LED.

- Time constant: τ = R × C = 1 kΩ × 1000 µF = **1.0 s** (the same value for charging and discharging)
- Charging: at 1τ (1 s) the capacitor is at 63 % of full charge, at 3τ (3 s) about 95 %, and at 5τ (5 s) almost full
- LED current at the start of discharge (assuming C1 is charged to 5 V):
  I = (5 V − V<sub>F</sub>) / R2 = (5 − 2) / 1k = **3 mA** (a modest brightness for an LED,
  but enough to see, since the goal is to follow the time constant by eye)
- The discharge current is (C1 voltage − V<sub>F</sub>) / R2, and it falls as the C1 voltage
  approaches V<sub>F</sub> (about 2 V). Treating V<sub>F</sub> as constant, the current drops to 37 % every 1τ (1 s):
  3 mA → about 1.1 mA after 1 s → about 0.41 mA after 2 s → about 0.15 mA after 3 s (calculated values).
  The LED visibly dims in about 1 s and looks off after 2 to 3 s
  (how it looks depends on the LED and the room light, so this is a rough guide)

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Switching between charge and discharge with a switch
# 5 V goes to the top +/− rails. Connect the bottom − rail to the top − rail at column 28
board: half
parts:
  R1: resistor b10 b15 1k
  S1: slide-switch e15(1) e16(C) e17(2)
  C1: capacitor/electrolytic h16(+) h19(-) 1000uF
  R2: resistor a19 a24 1k
  D1: led b24(A) b25(K) red
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t10 -- a10 red
  - d16 -- g16 orange
  - j19 -- -b19 black
  - c17 -- c19 orange
  - a25 -- -t25 black
  - -t28 -- -b28 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/03-rc-charge-1.svg)

The 5 V supply is V+ of Supplies on the Analog Discovery 3 (AD3). Set it to 5 V in WaveForms and turn the output on. It is the power supply box in Fig. 2.
The current is at most 5 mA at the start of charging and about 3 mA while the LED is lit,
within what the AD3 supply can deliver (up to about 50 mA per rail).

In Fig. 2, the lower end of `R1` (`b15`) and pin `1` of the switch (`e15`) are connected through the same column, 15.
The switch's `C` (common) goes to the + side of the capacitor, and pin `2` is wired to `R2` on the discharge side.
The capacitor is electrolytic, so insert it with the **striped side (−) toward GND**. A black wire in
column 28 joins the top and bottom − rails so that the − of C1 (bottom − rail) and
the cathode of the LED (top − rail) are the same GND.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1, R2 | Resistor (1/4 W) | 1 kΩ |
| C1 | Electrolytic capacitor | 1000 µF (16 V or higher) |
| D1 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| S1 | Slide switch | 1 pole, 2 throw (SPDT) |
| — | Power supply | V+ of the Analog Discovery 3 (5 V) |

## Values to check

Set the multimeter to a DC voltage range, keep it across C1, and flip the switch to see how the reading changes.
Readings in seconds are only a rough guide because the multimeter display lags. For an accurate reading, use the oscilloscope in the second half.

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| C1 voltage 1 s after charging starts | about 3.16 V (5 V × 0.632) | At 1τ the capacitor is charged to 63 % (calculated value) |
| C1 voltage 5 s after charging starts | about 4.97 V (almost fully charged) | At 5τ it has almost settled |
| LED current at the moment of switching to discharge | about 3 mA (calculated value) | Replacing the resistor with 470 Ω raises the current to about 6.4 mA and the LED gets brighter, but the time constant τ = 0.47 s becomes shorter |
| How the LED dims | The current falls to about 37 % (about 1.1 mA, calculated value) in 1 s, and the LED looks off after 2 to 3 s (rough guide) | Time how long it takes to look off with a stopwatch or frame-by-frame video, and compare |

## Viewing the time constant on the oscilloscope (no LED)

Instead of following how the LED lights by eye, watch the curve of the capacitor voltage rising on the oscilloscope
and **read the time constant from the time scale**. No LED is used. The basic use of the oscilloscope is in 0-3.

With τ = 1 s, you would wait several seconds to see one charge. Keep R and change C from
**1000 µF to 1 µF**, so that τ = 1 kΩ × 1 µF = **1 ms**. In place of the switch, feed in the
**square wave (0 V and 5 V repeating at 100 Hz)** of the signal generator (0-6). It charges
during the 5 V half (5 ms = 5τ) and discharges during the 0 V half, 100 times per second,
so the waveform appears stationary.

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 3 Square-wave RC charge and discharge, CH1 and CH2
parts:
  V1: square 1,2 1,5 5
  M1: voltmeter 3,2 3,5 l=$\mathrm{CH1}$
  R1: resistor 4,2 6,2 1k
  C1: capacitor 7,2 7,5 1u
  M2: voltmeter 9,2 9,5 l=$\mathrm{CH2}$
  G1: ground 1,5
wires:
  - 1,2 -- 3,2 -- 4,2
  - 6,2 -- 7,2 -- 9,2
  - 1,5 -- 3,5 -- 7,5 -- 9,5
style:
  grid: on
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/circuit/03-rc-charge-2.svg)

In Fig. 3, CH1 shows the input (square wave) and CH2 shows the voltage across C1. Connect the GND of both probes
to the GND at the bottom of the figure (the same point as the GND of the signal generator).

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 4 One R and one C, wired to the generator and scope
board: half
parts:
  R1: resistor a10 a15 1k
  C1: capacitor/film b15 b18 1u
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1+, W1, 1-, 2+, 2-]
wires:
  - AD.W1 -- c10 yellow
  - AD.GND -- -t5 black
  - a18 -- -t18 black
  - AD.1+ -- e10 orange
  - AD.1- -- -t11 black
  - AD.2+ -- e15 green
  - AD.2- -- -t16 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/breadboard/03-rc-charge-2.svg)

In Fig. 4, the right end of `R1` (`a15`) and the left end of `C1` (`b15`) are connected through the same column, 15. The output of the signal generator
goes to column 10, the left end of `R1`, and the right end of `C1`, column 18, goes to the top − rail (GND).
Connect W1 of the AD3 to column 10, Scope 1+ also to column 10, and 2+ to column 15. Connect GND and 1− and 2− to the top − rail
so that the signal generator and the oscilloscope share the same GND.

- Use a **film capacitor** (no polarity) for C1. Many multilayer ceramic 1 µF parts
  (high-permittivity types) lose a lot of capacitance under a DC voltage, which makes τ come out shorter
- A general-purpose signal generator has a 50 Ω output resistance, so τ = (1 kΩ + 50 Ω) × 1 µF ≈ **1.05 ms**
  (5 % longer). Set the generator's load setting to **High-Z** (with 50 Ω, the output voltage is
  twice the displayed value). The AD's W1 has almost 0 Ω output resistance, so τ stays at 1.00 ms
- The 5 V power supply and the slide switch are not used. The square wave from the signal generator takes the place of the switch

### Instrument settings

| Item | Value |
| --- | --- |
| Signal generator (W1 on the AD) | Square wave, 100 Hz, **0 V to 5 V** (amplitude 2.5 V + offset 2.5 V. On models that take the amplitude in Vpp, enter 5 Vpp) |
| Coupling | DC on both CH1 and CH2 |
| Voltage range | 1 V/div on both CH1 and CH2, with the 0 V reference aligned one division from the bottom |
| Time range | 1 ms/div (one division is 1τ) |
| Trigger | Rising edge of CH1, level 2.5 V |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 5 CH1 input, CH2 C1 voltage, 1τ cursors
time: 1ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
cursors: [0, 1ms]
measure: [vpp, vmax, rise]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/scope/03-rc-charge-1.svg)

### Reading τ with the cursors

1. Place the vertical cursor X1 on the rising edge of CH1 (the trigger point, t = 0)
2. Move X2 and stop where CH2 reaches **3.16 V (63 % of 5 V)**
3. The time ΔX from X1 to X2 is τ. By calculation it is **1.00 ms** (1.05 ms with a 50 Ω signal generator)

You can also place X2 at 1 ms and read the CH2 voltage (about 3.16 V means τ = 1 ms).
If Measurements has Rise (the 10 % to 90 % time), it equals **2.2τ**
(τ × ln 9 ≈ 2.2 ms).

### Discharge, and the screen at a higher frequency

If you change the trigger to the **falling edge** of CH1, the discharge curve starts at the middle of the screen.
With X1 on the falling edge and X2 at 1 ms, CH2 falls from 4.97 V to **1.83 V (37 %)**.
The time constant τ is the same as for charging, and the remainder drops to 37 % every 1τ.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 6 Discharge, 37 % after 1τ
time: 1ms/div
trigger: ch1 falling 2.5V
ch1: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
cursors: [0, 1ms]
measure: [vpp, vmin, period]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/scope/03-rc-charge-2.svg)

If you raise the signal generator frequency to **1 kHz**, the half period is only 0.5 ms (0.5τ). C1 switches to
discharge before it reaches full charge, and CH2 becomes a triangle wave with rounded corners that swings between 1.89 V and 3.11 V.
The average is still 2.50 V in both cases. Set the time range to 200 µs/div.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 7 1 kHz, half period 0.5τ, no full charge
time: 200us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 1kHz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
measure: [vpp, vmax, vmin, avg]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/scope/03-rc-charge-3.svg)

### Values to check

| What to measure | Expected value | What it tells you |
| --- | --- | --- |
| CH2 1 ms after the rising edge | about 3.16 V (5 V × 0.632, calculated value) | At 1τ the capacitor is charged to 63 % |
| CH2 1 ms after the falling edge | about 1.83 V (4.97 V × 0.368, calculated value) | Discharge has the same τ, and falls to 37 % in 1τ |
| CH2 Rise (10 to 90 %) | about 2.2 ms (calculated value) | 2.2τ. One number in Measurements confirms τ |
| CH2 at the end of the half period (5 ms) | about 4.97 V (calculated value) | At 5τ it is almost fully charged |
| CH2 when raised to 1 kHz (Fig. 7) | about 1.89 V to 3.11 V (Vpp about 1.22 V, calculated value) | When the half period is shorter than τ, the capacitor does not reach full charge and the waveform approaches a triangle wave |
| When C1 is replaced with 0.47 µF | about 0.47 ms until CH2 reaches 3.16 V | τ is proportional to C |

You can also look at the circuit of Fig. 1 (1000 µF, τ = 1 s) as it is. Remove the LED, connect the lower end of R2
directly to GND, put CH1 on the + of C1, and set the time range to 1 s/div in **roll mode**
(a display in which the waveform scrolls from right to left. In WaveForms on the AD, set Mode to Shift).
Each time you flip the switch, a curve is drawn that rises to 63 % (falls to 37 %) in one division.

Fig. 8 shows the moment of switching to the charge side after 5 s on the discharge side. Roll mode does not
stop at the trigger, so when the charging curve is on the screen, stop it with **Stop**, place X1 at the start of charging (where the curve
begins to rise from 0 V), and X2 one second after it. The C1 voltage (CH1) is about 3.18 V (63 %).
To put the start of charging in the middle, the figure is drawn as if triggered on a rising edge of 50 mV.

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 8 Circuit of Fig. 1, switched every 5 s
time: 1s/div
trigger: ch1 rising 50mV
ch1: {wave: square 0.1Hz 2.5V offset 2.5V | rc 1s, range: 1V/div, position: -3div}
cursors: [0, 1s]
measure: [vmax, vmin, rise]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/01-basics/scope/03-rc-charge-4.svg)

## Verification with LTspice

`sim/03-rc-charge.cir` (Fig. 1: charging and discharging 1000 µF, switching to discharge at 5 s) and `sim/03b-rc-scope.cir` (Fig. 3: 1 µF, square wave 0 to 5 V) were run as transient analyses. The LED uses the same assumed model as in 1-1 (not measured).

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| C1 1 s after charging starts | about 3.16 V | 3.161 V | Agrees |
| C1 5 s after charging starts | about 4.97 V | 4.966 V | Agrees |
| LED current at the moment of switching to discharge | about 3 mA | 2.99 mA | Agrees |
| Current 1 / 2 / 3 s into discharge | about 1.1 / 0.41 / 0.15 mA (calculated with constant V<sub>F</sub>) | 1.15 / 0.45 / 0.20 mA | Agrees (the LED's V<sub>F</sub> drops as the current falls, so 10 to 30 % more current keeps flowing than the text's calculated values. "Looks off after 2 to 3 s" still holds) |
| Fig. 3 (100 Hz) 1 ms after the rising edge | about 3.16 V | 3.17 V (includes 0.03 V left over from the previous period) | Agrees |
| Fig. 3, 1 ms after the falling edge | about 1.83 V | 1.83 V | Agrees |
| Fig. 3, end of the half period | about 4.97 V | 4.97 V | Agrees |
| Fig. 3 Rise (10 to 90 %) | about 2.2 ms | 2.19 ms | Agrees |
| Fig. 7 (1 kHz) swing | about 1.89 V to 3.11 V | 1.89 V to 3.11 V | Agrees |

## Sources

Original work.

See also: [Time constant (Wikipedia)](https://ja.wikipedia.org/wiki/時定数), [RC circuit (Wikipedia)](https://ja.wikipedia.org/wiki/RC回路), [Lessons in Electric Circuits Vol. I, Chapter 16: RC and L/R time constants](https://www.ibiblio.org/kuphaldt/electricCircuits/DC/DC_16.html)
