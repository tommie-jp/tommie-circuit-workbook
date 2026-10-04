---
book: circuits
chapter: 11
id: 11-5
title: I2C センサー (温度)
tier: 100
source: 自作
era: 今
---

# 11-5 I2C センサー (温度)

8-10 の LM35/TMP36 はアナログ電圧で温度を返す。I2C 接続の温度センサー
(ここでは MCP9808) は、デジタルの通信で温度の数値をそのまま返す。I2C は、
データの線 SDA とクロックの線 SCL の 2 本でマイコンと部品が数値をやり取りする規格。
各部品はアドレス (番号) を持ち、マイコンは番号を指定して話しかけるので、
複数のセンサーを同じ 2 本にぶら下げられる。この題では Pico 2 で MCP9808 から温度を読み、
1 秒ごとに表示する。

MCP9808 のチップ単体は MSOP-8 / DFN-8 の表面実装品 (SMD) しかなく、
そのままではブレッドボードに挿せない。そこで、チップを小さな基板に載せて
SDA・SCL・VDD・GND をピンヘッダに出したブレイクアウトモジュールを使う。

## 回路図

```circuit
title: 図1 MCP9808をI2C0(GP0/GP1)で読む
parts:
  U1: pico2 k5 mirror
  P3V3: vcc h2 3.3V
  G1: ground i7a5
  U2:
    type: device
    at: g14e0
    label: MCP9808
    pins: [VDD, SDA, SCL, GND]
  P3V3: vcc e7 3.3V
  P3V3: vcc e9 3.3V
  Rsda: resistor e7 f7 4.7k l=$R_\mathrm{SDA}$
  Rscl: resistor e9 f9 4.7k l=$R_\mathrm{SCL}$
  P3V3: vcc e12 3.3V
  G2: ground i12
wires:
  - U1.3V3 -| h2
  - U1.GND3 -| i7a5
  - U1.GP0 -| g7c0
  - U2.SDA -| g7c0
  - f7 -- g7c0
  - U1.GP1 -| g9g0
  - U2.SCL -| g9g0
  - f9 -- g9g0
  - U2.VDD -| e12
  - U2.GND -| i12
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/05-i2c-temperature.svg)

- SDA (GP0、ピン 1) と SCL (GP1、ピン 2) が Pico 2 の I2C0。どちらもプルアップ抵抗
  (Rsda・Rscl、4.7kΩ) で 3.3V に持ち上げておく。I2C はオープンドレインの規格で、
  つながった機器は線を L に引き下げることしかできない。H は抵抗が作る (10-18 で詳しく扱う)
- 市販の MCP9808 モジュールは、基板上にプルアップを内蔵していることが
  多い。複数枚つなぐとプルアップが並列になり、抵抗が小さくなりすぎる
  (L に引く側の電流が増える。数枚なら実害は小さい)。1 枚だけなら外付けの
  4.7kΩ は無くても動くことがある
- MCP9808 の I2C アドレスは 0x18 (16 進数。10 進で 24。既定値で、アドレスの足 A0〜A2 が L のとき)。
  分解能 0.0625℃、精度は目安 ±0.25℃ (typ)、±0.5℃ (max、−20〜+100℃)

## プログラム

11-1 と同じく、C/C++ を第 1、MicroPython を第 2 に並べる。MCP9808 は温度を
レジスタ (センサーの中の番号付きの記憶場所) 0x05 に 2 バイトで置いている。
プログラムは「0x05 を読みたい」と 1 バイト書き、続けて 2 バイト読み、温度に直す。

### C/C++ (Pico SDK)

`main.c` (I2C0 を 100kHz で使い、Ambient Temperature レジスタ 0x05 を 1 秒ごとに読む)。

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

#define I2C_PORT i2c0
#define SDA_PIN 0
#define SCL_PIN 1
#define MCP9808_ADDR 0x18
#define REG_AMBIENT_TEMP 0x05

static bool read_temperature(float *celsius) {
    uint8_t reg = REG_AMBIENT_TEMP;
    uint8_t data[2];
    if (i2c_write_blocking(I2C_PORT, MCP9808_ADDR, &reg, 1, true) != 1) return false;
    if (i2c_read_blocking(I2C_PORT, MCP9808_ADDR, data, 2, false) != 2) return false;

    uint8_t upper = data[0] & 0x1F;       // 上位バイトからフラグを除く
    uint8_t lower = data[1];
    if (upper & 0x10) {                   // 符号ビット (負)
        upper &= 0x0F;
        *celsius = (upper * 16 + lower / 16.0f) - 256;
    } else {
        *celsius = upper * 16 + lower / 16.0f;
    }
    return true;
}

int main(void) {
    stdio_init_all();
    i2c_init(I2C_PORT, 100 * 1000);
    gpio_set_function(SDA_PIN, GPIO_FUNC_I2C);
    gpio_set_function(SCL_PIN, GPIO_FUNC_I2C);
    // プルアップは外付けの 4.7kΩ (図 1) が受け持つので、内蔵は使わない

    while (true) {
        float temp;
        if (read_temperature(&temp)) printf("%.4f C\n", temp);
        else printf("read failed\n");
        sleep_ms(1000);
    }
}
```

- `i2c_init(i2c0, 100 * 1000)` で I2C0 を 100kHz で動かし、`gpio_set_function(..., GPIO_FUNC_I2C)`
  で GP0・GP1 を I2C に切り替える
- `i2c_write_blocking()` でレジスタの番号 0x05 を送り、`i2c_read_blocking()` で 2 バイト読む。
  戻り値が送った・読んだバイト数でなければ失敗として `false` を返す
- 2 バイトは 13 bit の 2 の補数 (負の数も表せる 2 進数の形) で、1 が 0.0625℃。
  上位バイト `data[0]` の上 3 bit は温度の比較の印 (フラグ) なので `& 0x1F` で消し、
  上位バイト × 16 + 下位バイト ÷ 16 で ℃ にする。符号ビット (0x10) が 1 なら負なので 256 を引く

`CMakeLists.txt` は 11-2 と同じ形で、名前を `i2ctemp` にし、`target_link_libraries` を
`pico_stdlib hardware_i2c` にする。ビルドと書き込みは 11-1 と同じ
(`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、`.uf2` を BOOTSEL のドライブへ)。
`printf` の出力は USB シリアルのターミナルで見る。センサーが応答しないと
`read failed` が出る (MicroPython の `i2c.scan()` に当たる確認は、C/C++ では
アドレス 0x18 への読み出しが成功するかで代える)。

### MicroPython

`I2C(0, scl=Pin(1), sda=Pin(0), freq=100000)` で I2C0 を用意する。`i2c.scan()` は応答した
機器のアドレスの一覧を返すので、最初に表示して配線を確かめる。`readfrom_mem(ADDR, 0x05, 2)` が
レジスタ 0x05 から 2 バイト読む。温度への直し方は C/C++ と同じ。センサーが応答しないと
`OSError` で止まる。

```python
from machine import I2C, Pin
import time

i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=100000)
ADDR = 0x18
print(i2c.scan())   # [24] (0x18) と出れば MCP9808 が見えている

while True:
    data = i2c.readfrom_mem(ADDR, 0x05, 2)   # Ambient Temperature レジスタ
    upper = data[0] & 0x1F                    # 上位バイトからフラグを除く
    lower = data[1]
    if upper & 0x10:                          # 符号ビット (負)
        upper &= 0x0F
        temp = (upper * 16 + lower / 16) - 256
    else:
        temp = upper * 16 + lower / 16
    print(temp, "C")
    time.sleep(1)
```

レジスタの値と温度の例 (0x90 = 144、0x60 = 96):

| 温度 (例) | 上位バイト `data[0]` | 下位バイト `data[1]` | 計算した温度 |
| --- | --- | --- | --- |
| 25.0℃ | 0x01 | 0x90 | 1×16 + 144/16 = 25.0℃ |
| −10.0℃ (負の例) | 0x1F | 0x60 | 符号ビットが 1: (15×16 + 96/16) − 256 = −10.0℃ |

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
実機では動かしていない。MicroPython は実行していない (未確認)。

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| MicroPython の `i2c.scan()` の結果 | `[24]` (0x18 の 10 進) |
| 室温での `temp` | だいたい 20〜28℃ (季節・部屋による) |
| センサーを指で温める | 数℃上がる (分解能 0.0625℃ なのですぐ反応する) |

`i2c.scan()` (C/C++ では `read failed` の有無) は接続を確かめる第一歩。`[]` (空) なら、
SDA/SCL のプルアップ忘れか、SDA と SCL の取り違えを疑う。

## 出典

自作。MCP9808 のレジスタ読み出しは Microchip のデータシート
(Ambient Temperature Register, 05h) の手順による。I2C0 の GP0/GP1 と
`i2c_write_blocking` / `i2c_read_blocking` は Pico SDK (`hardware_i2c`) による。
