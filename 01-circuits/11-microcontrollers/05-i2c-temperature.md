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

8-10 の LM35/TMP36 はアナログ電圧で温度を返すが、**I2C** 接続の温度センサ
(ここでは MCP9808) はデジタルの通信で温度の数値をそのまま返す。配線は
SDA・SCL の 2 本だけで、複数のセンサを同じ 2 本にぶら下げられるのが I2C の
値打ち。MCP9808 の**チップ単体は MSOP-8 / DFN-8 の SMD 品しかなく、
そのままではブレッドボードに挿せない**ので、ピッチ変換した**ブレイクアウト
モジュール** (基板に実装済みで、SDA・SCL・VDD・GND がピンヘッダで出ている
もの) を使う。

## 回路図

```circuit
title: 図1 MCP9808をI2C0(GP0/GP1)で読む
parts:
  U1: pico2 k3 mirror
  SENS:
    type: device
    at: g12
    label: MCP9808
    pins: [VDD, GND, SDA, SCL]
  Rsda: resistor e5 g5c0 4.7k
  Rscl: resistor e7 g7g0 4.7k
  G1: ground h6 r270
  G2: ground f10i0 r90
wires:
  - U1.3V3 -| e1
  - e1 -- e5 -- e7 -- e9
  - e9 |- SENS.VDD
  - U1.GP0 -| g5c0
  - g5c0 |- SENS.SDA
  - U1.GP1 -| g7g0
  - g7g0 |- SENS.SCL
  - U1.GND3 -| h6
  - f10i0 |- SENS.GND
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/05-i2c-temperature.svg)

- **SDA (GP0) と SCL (GP1)** が I2C0。どちらも**プルアップ抵抗 (4.7kΩ)** で
  3.3V に持ち上げておく — I2C はオープンドレインの規格で、H は抵抗が
  作り、L はどちらかの機器が引き下げる (10-18 で詳しく扱う)
- 市販の MCP9808 モジュールは基板上に**プルアップを内蔵**していることが
  多い。複数枚つなぐとプルアップが並列になり、抵抗が小さくなりすぎる
  (L に引く側の電流が増える。数枚なら実害は小さい)。1 枚だけなら外付けの
  4.7kΩ は無くても動くことがある
- MCP9808 は I2C アドレス **0x18** (デフォルト、A0〜A2 未接続時)。
  分解能 0.0625℃、精度は目安 ±0.25℃ (typ)、±0.5℃ (max、−20〜+100℃)

## プログラム

C/C++ を第 1、MicroPython を第 2 に並べる。この教科書の標準で、実行時間が読みやすい
C/C++ を先にし、手軽に試せる MicroPython を添える。

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

`CMakeLists.txt` は 11-2 と同じ形で、名前を `i2ctemp` にし、`target_link_libraries` を
`pico_stdlib hardware_i2c` にする。ビルドと書き込みは 11-1 と同じ
(`cmake -B build -DPICO_BOARD=pico2 && cmake --build build`、`.uf2` を BOOTSEL のドライブへ)。
`printf` の出力は USB シリアルのターミナルで見る。センサが応答しないと
`read failed` が出る (下の `i2c.scan()` に当たる確認は、C/C++ では
アドレス 0x18 への読み出しが成功するかで代える)。

### MicroPython

```python
from machine import I2C, Pin
import time

i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=100000)
ADDR = 0x18

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

| レジスタの生値 (例) | 上位バイト | 下位バイト | 計算した温度 |
| --- | --- | --- | --- |
| 25.0℃ | 0x01 | 0x90 | 1×16 + 0x90/16 = **25.0℃** |
| 負の例 (−10.0℃) | 0x1F | 0x60 | 符号あり: (15×16 + 0x60/16) − 256 = **−10.0℃** |

C/C++ は `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
**実機では動かしていない。** MicroPython は実行していない (未確認)。

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| MicroPython の `i2c.scan()` の結果 | `[24]` (0x18 の 10進、計算値) |
| 室温での `temp` | だいたい 20〜28℃ (季節・部屋による) |
| センサを指で温める | 数℃上がる (分解能 0.0625℃ なのですぐ反応する) |

`i2c.scan()` (C/C++ では `read failed` の有無) は接続を確かめる第一歩。何も出なければ、SDA/SCL の
プルアップ忘れか、配線の左右 (SDA と SCL) の取り違えを疑う。

## 出典

自作。MCP9808 のレジスタ読み出しは Microchip のデータシート
(Ambient Temperature Register, 05h) の手順による。I2C0 の GP0/GP1 と
`i2c_write_blocking` / `i2c_read_blocking` は Pico SDK (`hardware_i2c`) による。
