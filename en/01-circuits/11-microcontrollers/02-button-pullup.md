---
book: circuits
chapter: 11
id: 11-2
title: Button Input and a Pull-Up
tier: 50
source: 自作
board: BB
era: 今
ja: b4527fe0a33ddcfc1a04dc834b68b173f21690dc
---

# 11-2 Button Input and a Pull-Up

11-1 used a GPIO as an output. This exercise uses a GPIO as an input and
reads from the program whether a button is pressed.

If nothing is connected to a GPIO input, its potential is undefined and it wanders between 0 and 1 (the same as the CMOS
inputs in 10-1). So it is pulled up to 3.3 V through a resistor (a pull-up), which keeps the GPIO at a solid H (3.3 V)
while the button is not pressed. The Pico 2 also has built-in pull-ups (32 to 86 kΩ in the datasheet), but
here an external resistor is used so that you can follow by eye how the resistor sets the potential.

## Schematic

```circuit
# Schematic (tommie-fence circuit fence)
title: Fig. 1 Pull-up resistor and button
parts:
  U1: pico2 3,5.2
  R1: resistor 6,6 6,9 10k
  SW1: button 6,9 6,11 l=$\mathrm{SW1}$
  G1: ground 6,11
wires:
  - U1.3V3 -| 6,6
  - U1.GP16 -| 5,9 -- 6,9
style:
  pitch: 1.2
```

![Schematic](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/circuit/02-button-pullup.svg)

- R1 (10 kΩ) pulls GP16 up to 3V3 (the 3.3 V that the Pico 2 supplies). While the button is released,
  GP16 is at 3.3 V (H)
- Pressing SW1 connects GP16 directly to GND, so it goes to 0 V (L). Only
  3.3 V ÷ 10 kΩ ≈ 0.33 mA flows through R1, so neither the GPIO nor the button is damaged
- Pull up to 3V3 (pin 36, the 3.3 V that the Pico 2 itself supplies). Connecting to VBUS (pin 40, 5 V) exceeds
  the rating of the GPIO (3.3 V) and damages it

## Wiring diagram

```breadboard
# Breadboard wiring diagram (tommie-fence breadboard fence)
title: Fig. 2 Building it on the breadboard
board: full
parts:
  MCU: pico2 @ h5
  R1: resistor b36 b33 10k
  SW1: button @ e35
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - SC.1+ -- a35 yellow
  - SC.1- -- -t42 black
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t36 -- a36 red
  - a24 -- a33 yellow
  - d33 -- d35 yellow
  - g37 -- -b37 black
  - -t40 -- -b40 black
```

![Breadboard wiring diagram](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/breadboard/02-button-pullup.svg)

- Connect `3V3` of the Pico 2 (pin 36, upper side of column 9) to the top + rail and `GND` (pin 38, upper side of column 7) to the
  top − rail (just plugging in USB does not bring power out to the rails, so always wire these two)
- Carry GP16 (pin 21, upper side of column 24) from `a24` by a yellow wire to column 33 (`a33`), outside the body of the Pico 2,
  and connect it to R1 (`b33` to `b36`) and SW1 (avoid the columns directly above and below the body, which are easy to confuse with other pins)
- The right pin of R1 (column 36) goes from `a36` to the + rail. From column 33 a yellow wire on row d carries the signal to the near side of SW1 (e35),
  and the far side of SW1 (column 37) goes to the bottom − rail. The bottom − rail is joined to the top − rail
  (the GND of the Pico 2) by a wire at column 40 (without it GP16 does not go L when pressed)
- Power comes from the USB of the Pico 2. On the Analog Discovery 3 (AD3, the USB instrument used in 0-3), connect **only the oscilloscope (Scope)**:
  plug 1+ (yellow) into column 35 (`a35`, the same point as the wire that runs from column 33 to SW1), which is connected to GP16, and
  1− (black) into the top − rail (GND). The current through the breadboard is only about 0.33 mA in R1, within the breadboard limit (500 mA for the whole breadboard)

## Instrument settings

The instrument is the AD3 oscilloscope (Scope). Watch GP16 drop from 3.3 V to 0 V only while the button is pressed,
**catching the moment of the press**. The change happens once, so set the trigger to Single (catch it only once)
and fit the time from press to release (about 0.5 s) on one screen.

| Item | Value |
| --- | --- |
| Power | USB of the Pico 2 (Supplies on the AD3 is not used) |
| CH1 (1+) | GP16 (pin 21). 1 V/div, 0 V one division up from the bottom |
| 1− | GND |
| Time range | 100 ms/div |
| Trigger | Falling edge of CH1, 1.65 V (the middle of 3.3 V), Single. Place the trigger point three divisions from the left |
| Measurements | Maximum, Minimum |
| Cursors | Place X1 while released (−100 ms, before the press) and X2 while pressed (300 ms) |

```scope
# Oscilloscope screen (tommie-fence scope fence)
title: Fig. 3 GP16 is 0V only while pressed (about 0.5 s)
time: 100ms/div
trigger: ch1 falling 1.65V at -2div
ch1: {wave: = 3.3V - 3.3V * step(t) + 3.3V * step(t - 500ms), range: 1V/div, position: -3div}
cursors: [-100ms, 300ms]
measure: [vmax, vmin]
```

![Oscilloscope screen](https://tommie-jp.github.io/tommie-circuit-workbook/en/01-circuits/11-microcontrollers/scope/02-button-pullup.svg)

- GP16 in Fig. 3 is at 3.3 V before the press (R1 pulls it up). It drops to 0 V at the moment of the press (t = 0)
  and returns to 3.3 V at the moment of release (about 500 ms)
- The cursor readings are 3.3 V at X1 (before the press) and 0 V at X2 (while pressed), the same as the table in "Values to check" below.
  The figure shows an ideal waveform; a real button bounces for a few ms just after the press and just after the release
  (chattering, seen in 10-5).
  Reading every 0.2 s on the Pico 2 is unlikely to be affected by the bounce

## Values to check

Calculated values. Measure between GP16 (pin 21) and GND with the multimeter on a DC voltage range.

| State | GP16 voltage | Current in R1 |
| --- | --- | --- |
| Button released | about 3.3 V (H) | almost 0 (a GPIO input draws almost no current) |
| Button pressed | 0 V (L) | about 0.33 mA (3.3 V ÷ 10 kΩ) |

## Program

As in 11-1, C/C++ is listed first and MicroPython second. Both read GP16 every 0.2 s and
print 1 when released and 0 when pressed on the PC screen.

### C/C++ (Pico SDK)

`main.c` (reads GP16 every 0.2 s and sends it to the USB serial port).

```c
#include <stdio.h>
#include "pico/stdlib.h"

#define BUTTON_PIN 16

int main(void) {
    stdio_init_all();
    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);   // the external R1 does the pull-up

    while (true) {
        printf("%d\n", gpio_get(BUTTON_PIN));   // released: 1, pressed: 0
        sleep_ms(200);
    }
}
```

- `gpio_set_dir(BUTTON_PIN, GPIO_IN)` sets GP16 as an input
- `gpio_get(BUTTON_PIN)` returns the present value of GP16 (1 for H, 0 for L)
- `stdio_init_all()` and `printf` send the value to the USB serial port (character communication over the USB cable)

`CMakeLists.txt` has the same form as in 11-1, with the name changed to `button` and two lines added to use USB serial.
The build and the write are also the same as in 11-1 (`PICO_BOARD=pico2`, copy the `.uf2` to the BOOTSEL drive).

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(button C CXX ASM)
pico_sdk_init()
add_executable(button main.c)
target_link_libraries(button pico_stdlib)
pico_enable_stdio_usb(button 1)
pico_enable_stdio_uart(button 0)
pico_add_extra_outputs(button)
```

View the USB serial output in a serial terminal on the PC (software such as `screen` or TeraTerm that
displays the characters it receives).

To switch to the built-in pull-up, add `gpio_pull_up(BUTTON_PIN)` and remove R1.

### MicroPython

`Pin(16, Pin.IN)` sets GP16 as an input, and `button.value()` reads its present value. The output of `print` appears in the
Thonny window (the shell).

```python
from machine import Pin
from time import sleep

button = Pin(16, Pin.IN)   # the external R1 does the pull-up

while True:
    print(button.value())   # released: 1, pressed: 0
    sleep(0.2)
```

To switch to the built-in pull-up, use `Pin(16, Pin.IN, Pin.PULL_UP)`.

The C/C++ program was confirmed to build as far as the `.uf2` with `PICO_BOARD=pico2`.
It has not yet been tested on hardware. The MicroPython program has not been run (not verified).

## Verification with LTspice

`sim/02-button-pullup.cir` solves Fig. 1. The button is represented as a 0.1 Ω contact and the GPIO input as an ideal with zero current.

| Item | Value in the text | LTspice | Verdict |
| --- | --- | --- | --- |
| GP16 while released | about 3.3 V (H) | 3.30 V | Agrees |
| GP16 while pressed | 0 V (L) | 0.03 mV | Agrees |
| Current in R1 while pressed | about 0.33 mA | 0.330 mA | Agrees |

## Verification with the program

The program from the text was run on a PC, and the same quantities as in the text's table were compared (`npm run pico:test`, `npm run pico`). **It has not yet been tested on hardware.**

| What was checked | Result | Tool |
| --- | --- | --- |
| Setting of GP16 | Input, built-in pull-up not used (external R1) | C: mock of the Pico SDK; MicroPython: stub of `machine` |
| Reading | Prints 1 every 200 ms while released | C: mock of the Pico SDK; MicroPython: stub of `machine` |

Not checked: the actual voltage when the button is pressed; chattering

## Sources

Original work. The pull-up resistance of the GPIO (32 to 86 kΩ, IOVDD=3.3 V) comes from the [RP2350 datasheet](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)
(14.9 Electrical characteristics, Digital IO).
