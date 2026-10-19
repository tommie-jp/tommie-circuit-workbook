---
book: circuits
chapter: 11
id: 11-1
title: Blinking an LED on the Pico 2
tier: 50
source: 自作
board: BB
era: 今
ja: bdca15c28401d05d20e236fc8a7447eb298af0e8
---

# 11-1 Blinking an LED on the Pico 2

A microcontroller is an IC that switches pin voltages between H and L, or reads pin voltages, as a program tells it to.
The zeros and ones that Chapter 10 set with switches and wiring can now be set by a program.

This exercise connects an LED to one GPIO (general-purpose input/output pin, usable as an input or an output) of a
Raspberry Pi Pico 2 (a small board carrying the RP2350 microcontroller; Pico 2 below) and blinks it using both
C/C++ (Pico SDK) and MicroPython. Blinking an LED is the standard first program for a microcontroller.
The LED is an external one, not the on-board one
(the on-board LED is fixed to GP25 inside the board, so it gives no practice in wiring).

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Blinking an LED with the Pico 2
parts:
  U1: pico2 3,5.2 mirror
  R1: resistor 6,9 8,9 330
  D1: led 8,9 8,11 red
  G1: ground 8,11
  G2: ground 5,8.2
wires:
  - U1.GP15 -| 6,9
  - U1.GND18 -| 5,8.2
style:
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/circuit/01-pico-blink.svg)

- GP15 (lower right of Fig. 1, pin 20) is set as an output, and the program switches it between H (3.3 V) and L (0 V).
  The H of a Pico 2 GPIO is 3.3 V, not 5 V
- To give the LED a return path, connect the GND of the Pico 2 (pin 18 here) to GND.
  Without it the current has no way back and the LED does not light
- R1 (330 Ω) sets the current. I = (3.3 V − V<sub>F</sub>) / R1 = (3.3 V − 2.0 V) / 330 Ω ≈ 3.9 mA
  (V<sub>F</sub> is the forward voltage of the LED, about 2.0 V for a red LED; calculated value). A GPIO of the Pico 2 (RP2350)
  can supply at most 12 mA per pin (the default setting is 4 mA) and 100 mA in total over all pins, so there is margin.
  3.9 mA also fits within the default 4 mA

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor j24 j28 330
  D1: led i28(A) i30(K) red
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-, 2-, 2+]
wires:
  - SC.1+ -- i24 yellow [h-10]
  - SC.2+ -- g28 blue
  - SC.1- -- -b26 black
  - SC.2- -- -b27 black
  - j30 -- -b30 black
  - j22 -- -b22 black
  - -t50 -- -b50 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/breadboard/01-pico-blink.svg)

- `pico2 @ h5` refers to the left end of the board (row h, pin 1 = GP0). The pin layout is that of the real
  board with the USB connector facing left
- GP15 (pin 20) is on the lower row of pins, so wire it from a free hole in row `j` (the lower block).
  With the board placed at `h5`, `j24` is the column of GP15 (`j23` is the neighboring GP14)
- The anode of the LED is in column 28 (i28), the same as the right pin of R1, and the cathode (column 30) goes from j30 to the
  bottom − rail (GND)
- Carry the GND of the Pico 2 (pin 18, column 22) from j22 to the bottom − rail. Without it the LED current
  cannot return to the Pico 2 and the LED does not light (all the GND pins of the Pico 2 are connected inside,
  so bringing out any one of them to the rail is enough). The top and bottom − rails are joined at column 50
- Power comes from the USB of the Pico 2 (the 5 V arriving at the VBUS pin 40 is turned into 3.3 V by the regulator on the board).
  The Analog Discovery 3 (AD3, the USB instrument used in 0-3) is not used for power; connect **only the oscilloscope (Scope)**.
  Plug 1+ (yellow) into the GP15 column (column 24, `i24`) and 2+ (blue) into the LED anode column (column 28, `g28`),
  and connect 1− and 2− (black) to the bottom − rail (GND). The only current through the breadboard is about 3.9 mA for the LED,
  within the breadboard limits (200 mA per hole, 500 mA for the whole breadboard)

## Instrument settings

The instrument is the AD3 oscilloscope (Scope). Watch **GP15 switch between H and L every 0.5 s, and the LED anode rise to about 2.0 V
(the forward voltage of the LED) only while GP15 is H**. The wave is slow, with a period of 1 s,
so set the time range to 200 ms/div (2 s per screen, 2 periods).

| Item | Value |
| --- | --- |
| Power | USB of the Pico 2 (Supplies on the AD3 is not used) |
| CH1 (1+) | GP15 (pin 20). 1 V/div, 0 V one division up from the bottom |
| CH2 (2+) | LED anode (between R1 and the LED). Same 1 V/div and same 0 V position as CH1 |
| 1−, 2− | GND |
| Time range | 200 ms/div |
| Trigger | Rising edge of CH1, 1.5 V. Place the trigger point one division from the left |
| Measurements | Frequency, Vmax |
| Cursors | Place X1 inside the lit time (250 ms) and X2 inside the off time (750 ms). ΔX is the half period, 500 ms |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 GP15 (CH1) and LED anode (CH2), every 0.5 s
time: 200ms/div
trigger: ch1 rising 1.5V at -4div
ch1: {wave: square 1Hz 1.65V offset 1.65V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: square 1Hz 1V offset 1V duty 50%, range: 1V/div, position: -3div}
cursors: [250ms, 750ms]
measure: [freq, vmax]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/scope/01-pico-blink.svg)

- CH1 (GP15) in Fig. 3 swings between 0 V and 3.3 V. High lasts 0.5 s and Low lasts 0.5 s, so the frequency is 1 Hz
  (two `sleep_ms(500)` calls in the program make one period)
- CH2 (the LED anode) is about 2.0 V while GP15 is High. The remaining 1.3 V or so falls across R1
  (3.3 V − 2.0 V, the same calculated value as in "Values to check" below). While GP15 is Low, CH2 is 0 V and the LED is off
- A 0.5 s blink is too fast to follow with a multimeter, but the oscilloscope shows both High and Low on one screen

## Values to check

Calculated values. Measure with the multimeter on a DC voltage range while the LED is lit. A 0.5 s blink is
hard to read, so lengthen `sleep_ms(500)` in the program (`sleep(0.5)` in MicroPython) to about 5 s
before measuring.

| Where to measure | Expected value |
| --- | --- |
| Between GP15 (pin 20) and GND (while H) | about 3.3 V |
| Across R1 while GP15 is H | about 1.3 V (3.3 − 2.0) |
| Current through R1 | about 3.9 mA (voltage across R1 ÷ 330 Ω) |
| Across the LED | about 2.0 V (forward voltage, red) |

## Program

The programs are listed with C/C++ (Pico SDK) first and MicroPython second. Both do the same thing.
C/C++ comes first as the standard of this book: the time one line takes to run is easy to read
(this matters for the PWM and I2C timing in this chapter) and it needs less RAM.
MicroPython has the advantage that you can write and try a program at once.

### C/C++ (Pico SDK)

`main.c` (sets GP15 as an output and switches H/L every 0.5 s).

```c
#include "pico/stdlib.h"

#define LED_PIN 15

int main(void) {
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true) {
        gpio_put(LED_PIN, 1);   // H (3.3V): LED on
        sleep_ms(500);
        gpio_put(LED_PIN, 0);   // L (0V): LED off
        sleep_ms(500);
    }
}
```

- `gpio_init(LED_PIN)` makes GP15 usable as a GPIO, and `gpio_set_dir(..., GPIO_OUT)` sets it as an output
- `gpio_put(LED_PIN, 1)` outputs H and `gpio_put(LED_PIN, 0)` outputs L
- `sleep_ms(500)` waits 500 ms (0.5 s). `while (true)` repeats lighting and turning off forever

In the same folder put `pico_sdk_import.cmake` (copy the one in the SDK's `external/` folder) and
`CMakeLists.txt` (the build settings).

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(blink C CXX ASM)
pico_sdk_init()
add_executable(blink main.c)
target_link_libraries(blink pico_stdlib)
pico_add_extra_outputs(blink)
```

Point the environment variable `PICO_SDK_PATH` at the SDK folder, then build with the commands below (this converts the program into a form
that runs on the Pico 2).

```sh
cmake -B build -DPICO_BOARD=pico2
cmake --build build
```

This produces `build/blink.uf2`. If you connect USB while holding down the BOOTSEL button on the board, the Pico 2 appears as a
USB drive (the volume name is `RP2350` by default), and copying the `.uf2` to it writes the program and runs it. If you forget `PICO_BOARD=pico2`, the program
is built for the Pico (RP2040) and does not run on the Pico 2.

### MicroPython

Copy the `.uf2` of MicroPython for the Pico 2 (download page `RPI_PICO2`, a different file from the one for the Pico) to the
drive that appears when you connect with BOOTSEL in the same way. Then in
Thonny (a Python development environment) choose "MicroPython (Raspberry Pi Pico)" and run the following.
`Pin(15, Pin.OUT)` sets GP15 as an output, and `led.value(1)` / `led.value(0)` output H / L.

```python
from machine import Pin
from time import sleep

led = Pin(15, Pin.OUT)

while True:
    led.value(1)   # H (3.3V): LED on
    sleep(0.5)
    led.value(0)   # L (0V): LED off
    sleep(0.5)
```

In this environment, the C/C++ program was confirmed to build as far as the `.uf2` with `PICO_BOARD=pico2`. It has
not yet been tested on hardware. The MicroPython program has not been run (not verified).

## Verification with LTspice

`sim/01-pico-blink.cir` solves Fig. 1 with GP15 at H (an ideal 3.3 V source). The LED uses the same assumed model as in 1-1
(V<sub>F</sub> about 2.0 V at 9 mA; not measured). The output resistance of the GPIO is not included.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| Across R1 | about 1.3 V | 1.34 V | Agrees |
| Across the LED | about 2.0 V | 1.96 V (V<sub>F</sub> is also lower because the current is below 9 mA) | Agrees |
| Current | about 3.9 mA | 4.06 mA | Agrees (4 % from the arithmetic that takes V<sub>F</sub> as 2.0 V) |

4.06 mA still nearly fits the rough guide of the default 4 mA setting. The H/L switching and the 1 Hz period come from
two `sleep_ms(500)` calls in the program, not from circuit values (outside what SPICE handles).

## Verification with the program

The program from the text was run on a PC, and the same quantities as in the text's table were compared (`npm run pico:test`, `npm run pico`). **It has not yet been tested on hardware.**

| What was checked | Result | Tool |
| --- | --- | --- |
| Interval between toggles of GP15 | 500 ms (period 1 s). H first | C: mock of the Pico SDK; MicroPython: stub of `machine`; picoemu (Cortex-M33) |

Not checked: LED brightness and current; the lighting on real hardware

## Sources

Original work. The specifications of the Pico 2 (RP2350A, 4 MB flash, up to 150 MHz, 520 kB SRAM) come from the
[Raspberry Pi Pico 2 datasheet](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf), and the GPIO current (up to 12 mA, 100 mA in total over all pins, 4 mA by default)
from the [RP2350 datasheet](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) (14.9 Electrical characteristics).
