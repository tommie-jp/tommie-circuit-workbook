---
book: circuits
chapter: 4
id: 4-1
title: Voltage follower
tier: 50
source: 自作
board: BB
ja: 23dbc57c2b9160cca4e2d3987709cd0c9cc54ec6
---

# 4-1 Voltage follower

An op amp (operational amplifier) is an IC that amplifies the difference between the voltages of its two inputs, the + input (non-inverting input) and the − input (inverting input),
by tens of thousands of times or more. Its input stage is the differential pair of 2-6. Used as it is, the output soon
sticks at one of the supply rails, so normally part of the output is fed back to the − input (negative feedback; seen in 2-8).
An op amp with negative feedback **moves its output so that the + input and the − input are at the same voltage**.
Also, almost no current flows into the inputs. The circuits in this chapter can be read with these two rules.

This exercise feeds the output of the op amp straight back to the − input. It simply **passes the voltage on with a gain (output ÷ input) of 1**.
Amplification is not the purpose. The job is to **lower the output impedance** (the same bridging role as the emitter follower of 2-2). In this exercise,
you connect a 1 kΩ load to a weak voltage made by a resistor divider, and check with a multimeter that the voltage does not drop when it goes through
the follower.

This chapter starts with the five basic op amp circuits: voltage follower (4-1), non-inverting amplifier (4-2), inverting amplifier (4-3),
comparator (4-4) and summing amplifier (4-5). This exercise is the first of them. The op amp is the LM358, an IC with two
op amps in one package.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Voltage follower
parts:
  VP: vsource 1,1 1,3 5
  VN: vsource 1,3 1,5 5
  G1: ground 2,3
  R1: resistor 3,1 3,3 100k
  R2: resistor 3,3 3,5 47k
  U1: opamp 6,3 +up
  RL: resistor 9,3 9,5 1k
  G2: ground 9,5
wires:
  - mid -- 2,3
  - vp -- 3,1
  - vm -- 3,5
  - 3,3 |- U1.+
  - U1.out -- 8,3 -- 9,3
  - 8,3 -- 8,4 -- 5,4
  - 5,4 |- U1.-
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
style:
  grid: on
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/circuit/01-voltage-follower.svg)

- VP and VN in Fig. 1 are two 5 V supplies in series. With the midpoint as GND, the top is +5 V and the bottom is −5 V,
  a dual supply. In this chapter it is made with the Supplies tool of the Analog Discovery 3 (AD3). Set V+ to +5 V and V− to −5 V,
  and VP corresponds to V+, VN to V−, and the midpoint to the GND of the AD3 (the same as 2-10). The power pins of the op amp are omitted from the figure
- When powered by USB only, the AD3 Supplies have a rough upper limit of 250 mW per rail (50 mA at 5 V).
  The current in this exercise is the supply current of the op amp (around 1 mA), 1.8 mA in RL and 0.07 mA in R1 and R2,
  a few mA per rail. If you build it with batteries, you can make ±5 V from two 006P (9 V) batteries with a 7805 and a 7905
- R1 and R2 divide ±5 V to make Vin with a high impedance (R1∥R2 ≈ 32 kΩ).
  It is a deliberately weak divider
- **The − input connected directly to the output** is the mark of a follower. The op amp moves its output so that the + input equals the − input,
  so the output settles at the same value as Vin (the triangle in Fig. 1 is the op amp; the + and − on the left are the inputs, and the apex on the right is the output)
- RL (1 kΩ) is a resistor that stands in for "a load that would be too heavy without the follower"

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
# The top rails are +5V (red) and GND (blue). The bottom blue rail is −5V (V−). The bottom red rail is not used
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies ±5V
    pins: [V+, GND, V-]
  U1: dip8 @ e10 LM358
  R1: resistor c15 c19 100k
  R2: resistor i15 i19 47k
  RL: resistor c4 c8 1k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - +t10 -- a10 red
  - +t19 -- a19 red
  - a4 -- -t4 black
  - j13 -- -b13 blue
  - j19 -- -b19 blue
  - g10 -- g11 orange
  - e15 -- f15 orange
  - h15 -- h12 orange
  - e8 -- f8 orange
  - h8 -- h10 orange
notes:
  - text below: Top red +5V, top blue GND, bottom blue −5V (V−)
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/04-opamps/breadboard/01-voltage-follower.svg)

- The box at the top left of Fig. 2 is the AD3 Supplies. **Connect V+ (+5 V) to the top red rail, GND to the top blue rail, and
  V− (−5 V) to the bottom blue rail.** The bottom blue rail is not GND, so do not mix them up
- U1 uses only one of the two op amps in the LM358 (pin 1 OUT, pin 2 IN−, pin 3 IN+, pin 4 V−,
  pin 8 V+). The other one (pins 5 to 7) is left floating. Pin 8 (column 10) goes to +5 V with `+t10--a10`,
  and pin 4 (column 13) goes to −5 V with `j13--(-b13)`
- R1 (100 kΩ) comes down from +5 V in columns 15 to 19 of the upper block, and R2 (47 kΩ) goes to
  −5 V in columns 15 to 19 of the lower block. The two divider nodes (column 15) are joined across the gap by a wire, and `h15--h12` takes them to IN+ (pin 3, column 12)
- **The follower just returns the output (pin 1, column 10) to IN− (pin 2, column 11)** (`g10--g11`)
- RL (1 kΩ) is in columns 4 to 8 of the upper block. The output (column 10) is lifted to column 8 with `h8--h10` and a wire across the gap,
  and column 4 goes down to GND (the top blue rail)

## Instrument settings

This exercise has no oscilloscope figure. All you look at is a DC voltage that does not change with time, so the multimeter reading is enough.
The instruments are the multimeter and the AD3 Supplies used as the power supply. Experiments that feed in a signal and watch the waveform start at 4-2.

## Parts

| Symbol | Part | Value |
| --- | --- | --- |
| U1 | Op amp (one of two in the package) | LM358 |
| R1 | Resistor | 100 kΩ |
| R2 | Resistor | 47 kΩ |
| RL | Resistor (load) | 1 kΩ |
| — | Power supply | ±5 V (AD3 Supplies; V+ = +5 V, V− = −5 V) |

## Values to check

With the multimeter's DC voltage range, measure Vin (column 12) and the output (column 10) against GND (the top blue rail).
The values in the table are calculated. The divider node voltage is Vin = V− + (V+ − V−) × R2/(R1+R2) = −5 + 10 × 47/147.

| Measure | Expected value | What it shows |
| --- | --- | --- |
| Vin (divider node of R1 and R2, no load) | about −1.80 V | Divider of 100 kΩ and 47 kΩ |
| Output (with RL) | about −1.80 V | Almost the same as Vin. The follower is working |
| **Calculation (think it through without building it)**: RL connected directly to the divider node | sinks to about −0.05 V | The equivalent resistance of the divider (32 kΩ) and RL (1 kΩ) divide the voltage. Without the follower, the load crushes the voltage |
| Output current of the op amp (the part that flows through RL) | about 1.80 mA | The output stage of the op amp supplies this current, and none of it flows on the divider side |

**This is what the follower is good for**: the divider node alone has a high output impedance of 32 kΩ,
but through the follower the output impedance becomes much lower. That is why the voltage does not sink when RL is connected.

The reason it becomes lower is negative feedback. The output resistance R<sub>O</sub> of an op amp alone (without feedback) is given in the
datasheet of the TI LM358 family (SLOS068) as a typical 300 Ω for the LM358B (measured at 1 MHz).
With negative feedback, the op amp cancels the drop in the output with its open-loop gain A times,
so the output impedance shrinks to R<sub>O</sub> ÷ (1 + A) (a follower feeds back the whole output, so the feedback fraction is 1).

- DC: A ≈ 100 000 (datasheet typical, 100 V/mV) → 300 Ω ÷ 100 001 ≈ 3 mΩ
- 1 kHz: A ≈ GBW ÷ f ≈ 1 MHz ÷ 1 kHz = 1000 → 300 Ω ÷ 1001 ≈ 0.3 Ω

Both are rough guides from typical values. As the frequency rises and A falls, the output impedance rises.

## Verification with LTspice

`sim/01-voltage-follower.cir` solves the DC operating point of Fig. 1 (supply ±5 V). The op amp is a simple one-pole model (GBW 1 MHz, SR 0.3 V/µs,
the output tops out at V+ − 1.5 V and V− + 0.1 V). It is an **assumption** modeled on the LM358, not a measurement. The model has no output resistance,
so LTspice does not check the output impedance in the text (300 Ω ÷ (1 + A)); it is arithmetic only.

| Item | Value in the text | LTspice | Result |
| --- | --- | --- | --- |
| V<sub>in</sub> (divider node, no load) | about −1.80 V | −1.803 V | Match |
| Output (with RL) | about −1.80 V | −1.803 V | Match |
| Current through RL | about 1.80 mA | 1.803 mA | Match |
| (Reference) RL connected directly to the divider node | about −0.05 V | −0.055 V (−1.803 V × 1 kΩ ÷ 33 kΩ) | Match (arithmetic) |

## Sources

Original work.
