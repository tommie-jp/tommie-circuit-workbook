---
book: circuits
chapter: 2
id: 2-6
title: Differential Amplifier
tier: 50
source: 自作
board: BB
ja: b3977ba33001bd6ddc047703ac347753ecd0c422
---

# 2-6 Differential Amplifier

If you join the emitters of two transistors and take them to GND through a single resistor (the tail resistor, so called
because it extends down like a tail), the circuit responds to the **difference between the two base voltages**. This pair
is called a differential pair. Set one base to a reference voltage and make the other variable, and watch with LEDs and
the oscilloscope which collector the current flows through. The input stage of an op amp (Chapter 4) is this differential pair.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Differential pair steering current (CH1, CH2)
parts:
  VCC: vcc 4,2 5V
  R1: resistor 4,2 4,5 10k
  R2: resistor 4,7 4,9 10k
  G2: ground 4,9
  VR1: potentiometer 14,2 14,6 10k
  G3: ground 14,6
  RC1: resistor 7,2 7,4 220
  D1: led 7,4 7,6
  Q1: npn 7,7
  RC2: resistor 11,2 11,4 220
  D2: led 11,4 11,6
  Q2: npn 11,7 mirror
  RE: resistor 9,9 9,11 220
  G4: ground 9,11
  M1: voltmeter 8,6 8,8 l=$\mathrm{CH1}$
  G5: ground 8,8
  M2: voltmeter 10,6 10,8 l=$\mathrm{CH2}$
  G6: ground 10,8
wires:
  - 7,6 -- 8,6
  - 11,6 -- 10,6
  - 4,2 -- 7,2 -- 11,2 -- 14,2
  - 4,5 -- 4,7 -- Q1.B
  - VR1.w |- Q2.B
  - 7,6 -- Q1.C
  - 11,6 -- Q2.C
  - Q1.E -- 7,9
  - Q2.E -- 11,9
  - 7,9 -- 9,9 -- 11,9
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/circuit/06-differential-amp.svg)

`VCC` (+5 V) in Fig. 1 is the supply output V+ of the Analog Discovery (AD) (set it to 5 V in the Supplies tool of WaveForms).
CH1 reads the collector voltage of `Q1` and CH2 that of `Q2`, both against GND.

The base of `Q1` is fixed (the reference) by the divider `R1`/`R2` (both 10 kΩ). The base of `Q2` can be moved from 0 to 5 V with the knob of
`VR1` (the potentiometer used in 1-6). `RE` (the tail resistor) keeps the sum of the
two emitter currents nearly constant.

- Reference voltage: 5 V × 10k/20k = **2.5 V**
- **When both are at the same voltage (2.5 V)**: the emitter current splits almost in half.
  Ve ≈ 2.5 − 0.7 = 1.8 V, I<sub>tail</sub> = 1.8 V / 220 Ω ≈ 8.2 mA,
  each collector current ≈ **4.1 mA** (both LEDs have the same brightness. With `RE` of
  1 kΩ, only 1.8 mA of Itail would flow at 5 V and the LEDs would be too dim, so
  220 Ω is used)
- **Raise VR1 slightly (by about 0.1 V) above the reference**: when the input difference of a bipolar differential pair
  exceeds ±4 V<sub>T</sub> (V<sub>T</sub> is the thermal voltage of 26 mV seen in 2-2; about ±100 mV at room temperature), the current
  goes almost entirely to one side. **Lowering VR1 switches it completely**: the LED on the Q1 side lights brightly at about 6 mA and the Q2 side almost goes out.
  **Raising VR1 does not switch it completely**: Q2 saturates and is capped at about 5 mA, and 2.5 to 3 mA remains on the Q1 side too
  (see "Viewing on the oscilloscope" below; confirmed with LTspice). The job of this circuit is that **a small voltage difference moves the current split a lot**

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Differential pair, CH1 and CH2 on the collectors
# Top + rail = +5V (V+ of the AD), top − rail = GND. Q2 is inserted mirrored so that the wires do not cross
board: full
parts:
  R1: resistor b2 b6 10k
  R2: resistor c6 c10 10k
  RC1: resistor b13 b16 220
  D1: led c16(A) c17(K) red cap=below:-1,0
  RE: resistor b20 b23 220
  RC2: resistor b25 b28 220
  D2: led c28(A) c29(K) red cap=below:-1,0
  VR1: potentiometer b32(1) b33(w) b34(3) 10k
  Q1: transistor g25(B) g26(C) g27(E) 2SC1815
  Q2: transistor g31(B) g30(C) g29(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t3 black
  - AD.1- -- -t15 black
  - AD.1+ -- a17 orange
  - AD.2- -- -t27 black
  - AD.2+ -- a29 blue
  - +t2 -- a2 red
  - +t13 -- a13 red
  - +t25 -- a25 red
  - +t32 -- a32 red
  - a10 -- -t10 black
  - a23 -- -t23 black
  - a34 -- -t34 black
  - d6 -- g25 orange [v48]
  - d17 -- g26 yellow [v38]
  - d20 -- g27 green [v28]
  - c20 -- g29 green [v30, h170]
  - d29 -- g30 yellow [h10]
  - c33 -- g31 blue
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/breadboard/06-differential-amp.svg)

In Fig. 2, the divider of `R1`/`R2` (column 6) is the base of `Q1` (the reference) and the knob of `VR1` (column 33) is the base of `Q2`.
`Q1` and `Q2` go into the block below the gap and are connected to the parts in the upper block with 6 wires (orange, yellow, green, green, yellow, blue).
**Insert `Q2` mirrored (in the order E, C, B from the left)**. The order of the upper parts and the order of the lower pins then match, and the 6 wires do not cross.

- Power: V+ (red) of the AD to `+t1` and GND (black) to `-t3`. The top + rail is +5 V and the − rail is GND
  (the bottom rails are not used). The two LEDs take a little under 10 mA, so V+ is enough
- Reference: `d6` (the midpoint of R1 and R2) → `g25` (base of `Q1`, orange). Knob: `c33` → `g31` (base of `Q2`, blue)
- Collectors: `d17` (cathode of D1) → `g26` (C of `Q1`), `d29` (cathode of D2) → `g30` (C of `Q2`) (yellow)
- Emitters: from the top end of `RE` (column 20) to `g27` (E of `Q1`) and `g29` (E of `Q2`) (2 green wires). The bottom end of `RE` goes from `a23` to the − rail
- CH1: 1+ (orange) into `a17` (cathode of D1 = the column of the collector of `Q1`), 1− (black) to `-t15`
- CH2: 2+ (blue) into `a29` (cathode of D2 = the column of the collector of `Q2`), 2− (black) to `-t27`

## Viewing on the oscilloscope

In the Scope tool of WaveForms, set CH1 and CH2 to 100 mV/div with DC coupling (center at 2.1 V, matched with Offset), set `VR1` to the reference (2.5 V), and then
raise it by about 0.1 V. If you trigger on the rising edge of CH1, the moments before and after the change fit in one screen
(DC does not move with time, so capture the moment of the change and compare the heights before and after. Fig. 3).

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 VR1 raised 0.1 V, CH1 up a little, CH2 down
time: 1ms/div
trigger: ch1 rising 2.25V
ch1: {wave: = 2.1V + 0.3V * step(t), range: 100mV/div, position: -21div}
ch2: {wave: = 2.1V - 0.3V * step(t), range: 100mV/div, position: -21div}
cursors: [-2ms, 2ms]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/02-transistors/scope/06-differential-amp.svg)

- Balanced (cursor X1, before raising): collector voltage = 5 − 220 Ω × 4.1 mA − 2.0 (LED) ≈ **2.1 V**, and the two traces overlap
- After raising VR1 (cursor X2): the `Q2` side, which collects the current, drops to **about 1.8 V**. The collector of `Q2` cannot go below
  the emitter (about 1.7 V) (saturation), so it stops there and the current of D2 is capped at about 5 mA. In the saturated `Q2` the base-collector junction
  is forward biased, and the base voltage is held at about 2.4 V. Because the emitter does not rise above 1.7 V, `Q1` (base about 2.4 V) does not cut off, and
  **about 2.5 to 3 mA remains**, so CH1 only rises to about **2.4 V**. The two traces move in **opposite** directions, but the movement is small
  (LTspice. The 2SC1815 was set to IS = 1e-14 and BF = 150, and the LED to 2.0 V at 4 mA)
- Conversely, if you **lower** `VR1` by 0.1 V or more below the reference, `Q1` takes about 6 mA and `Q2` almost cuts off, D2 goes out, and CH2 goes to about 3.3 V
  (only the tiny current into the oscilloscope input flows in D2, so for the same reason as in 2-1 it does not reach 5 V), and CH1 goes to about 1.5 V.
  In this direction it switches completely
- In practice you turn the knob by hand, so the step is smooth and shakes a little with your hand

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| R1, R2 | Resistor (1/4 W) | 10 kΩ |
| RC1, RC2 | Resistor (1/4 W) | 220 Ω |
| RE | Resistor (1/4 W) | 220 Ω |
| VR1 | Potentiometer | 10 kΩ |
| D1, D2 | LED (red, 5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1, Q2 | NPN transistor (two units with matched characteristics are preferable) | 2SC1815 |
| — | Power supply | V+ of the Analog Discovery (5 V) |

## Values to check

| Measure | Expected value | What it shows |
| --- | --- | --- |
| D1 and D2 with the knob of VR1 set to the same voltage as the reference | Both the same brightness (about 4.1 mA each, calculated value) | The current splits evenly between the two transistors |
| VR1 raised slightly (about 0.1 V) | D2 lights brightly (capped at about 5 mA) and D1 dims, but 2.5 to 3 mA still flows (LTspice) | On the raising side Q2 saturates and holds the base, so it does not switch completely |
| VR1 lowered slightly (about 0.1 V) in the other direction | D1 lights brightly (about 6 mA) and D2 almost goes out (LTspice) | The **sign** of the input difference decides where the current goes. On the lowering side it switches completely |
| The two collectors (CH1, CH2) when balanced | Both about 2.1 V | The two currents are equal |
| CH1 and CH2 with VR1 raised 0.1 V | CH1 about 2.4 V, CH2 about 1.8 V (LTspice) | The two collectors move in opposite directions, but Q2 saturates and stops. When lowered, CH1 is about 1.5 V and CH2 about 3.3 V |
| Tail current (voltage across RE ÷ 220 Ω) | about 8.2 mA near balance | The sum is nearly constant and only the split changes. If you swing far and one side saturates, its base current increases and the sum is no longer constant |

## Verification with LTspice (addendum)

The LTspice numbers in the text were recalculated with `sim/06-differential-amp.cir` (Q1 and Q2 are substitute models with IS = 1e-14 and BF = 150, and the LED is assumed to be 2.0 V at 4 mA; not a measurement).
VR1 is placed as a 10 kΩ potentiometer, and the open-circuit voltage 5 V × x was swept with the knob position x.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| Current in each LED when balanced (both bases at the same voltage, x ≈ 0.484, base 2.36 V) | about 4.1 mA | 3.5 to 4.0 mA | Close (the base current drops 0.14 V across the divider, so the base is lower than the 2.5 V in the text) |
| CH1 and CH2 when balanced | about 2.1 V | 2.1 to 2.2 V | Match |
| D2 and D1 with VR1 raised (x = 0.50, open-circuit voltage 2.5 V) | about 5 mA and 2.5 to 3 mA | 4.7 mA and 3.0 mA | Match |
| CH1 and CH2 in the same case | about 2.4 V and 1.8 V | 2.36 V and 1.94 V | Match (CH2 shifts by 0.1 V depending on the LED model) |
| D1 and D2 with the difference of the two bases at −0.1 V (an ideal voltage source) | about 6 mA and almost out | 6.2 mA and 0.19 mA | Match |
| CH1 and CH2 in the same case | about 1.5 V and about 3.3 V | 1.6 V and 3.1 V | Match |
| Tail current | about 8.2 mA | 6.5 to 7.1 mA | Close (V<sub>E</sub> is 1.6 to 1.7 V. The model's V<sub>BE</sub> is 0.65 V and the base also drops to 2.36 V) |

**A note on the lowering direction**: VR1 is a voltage source with an output impedance of about 2.5 kΩ, and the base current flows into it.
Even if you lower the open-circuit voltage of VR1 by 0.1 V from the balance point (x = 0.46), the difference between the two bases is only about −0.07 V, and with D1 at 5.3 mA and D2 at 1.9 mA
D2 does not go out completely (5.7 mA and 1.1 mA with 0.2 V lowered, at x = 0.44). The "about 6 mA, D2 almost out" in the text is the value when the **difference** of the bases is 0.1 V.
When you set it with the knob, turn it until the LED goes out.

## Sources

Original work.

See also: [Differential amplifier (Wikipedia)](https://ja.wikipedia.org/wiki/差動増幅回路), [Amplifier (Wikipedia)](https://ja.wikipedia.org/wiki/増幅回路)
