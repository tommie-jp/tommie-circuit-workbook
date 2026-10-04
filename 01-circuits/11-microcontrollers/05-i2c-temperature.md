---
book: circuits
chapter: 11
id: 11-5
title: I2C センサー (温度)
tier: 100
board: BB
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
- MCP9808 の I2C アドレスは 0x18 (16 進数。10 進で 24。既定値で、アドレスのピン A0〜A2 が L のとき)。
  分解能 0.0625℃、精度は目安 ±0.25℃ (typ)、±0.5℃ (max、−20〜+100℃)

## 実体配線図

```breadboard
title: 図2 MCP9808 モジュールを I2C0 (GP0/GP1) につなぐ (Pico 2 は USB から給電、AD3 は Scope だけ)
board: full
parts:
  MCU: pico2 @ h5
  M1:
    type: sip4
    holes: [a34]
    pins: [VDD, SDA, SCL, GND]
    label: MCP9808
  Rsda: resistor c35 c39 4.7k
  Rscl: resistor e36 e41 4.7k
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-, 2+, 2-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - c34 -- +t34 red
  - d37 -- -t37 black
  - d39 -- +t39 red
  - d41 -- +t41 red
  - MCU.GP0 -- d35 yellow
  - MCU.GP1 -- d36 green
  - SC.1+ -- b36 green
  - SC.2+ -- e35 yellow
  - SC.1- -- -t46 black
  - SC.2- -- -t47 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/05-i2c-temperature.svg)

- 電源は Pico 2 の USB。`3V3` (ピン 36、9 列の上) を上の + レールへ、`GND` (ピン 38、7 列の上) を上の − レールへ出す (11-2 と同じ)
- モジュール (M1) は 34〜37 列の a 行に挿す。ピンの並びは図の `VDD` `SDA` `SCL` `GND` の順にしたが、**モジュールによって並びが違う**ので、
  手元の基板の印字を見て配線する。VDD (34 列) は + レールへ、GND (37 列) は − レールへ
- SDA (35 列) は GP0 (ピン 1) へ黄の線、SCL (36 列) は GP1 (ピン 2) へ緑の線。プルアップ Rsda (35〜39 列) と Rscl (36〜41 列) は、
  もう一方の端 (39 列・41 列) を + レールへ上げる。モジュールが内蔵のプルアップを持つなら、外付けは省いてよい
- AD3 は電源に使わず、**オシロ (Scope) だけ**をつなぐ。1+ (緑) を SCL の 36 列 (`b36`)、2+ (黄) を SDA の 35 列 (`e35`) に挿し、
  1− と 2− (黒) は − レールへ
- ブレッドボードを流れる電流は、モジュール (動作時 数百 µA、目安) と、プルアップが SDA・SCL を L に引かれたときの 3.3V ÷ 4.7kΩ ≈ 0.7mA が 2 本分だけで、
  ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| M1 | 温度センサーのモジュール | MCP9808 ブレイクアウト (I2C アドレス 0x18) |
| Rsda・Rscl | プルアップ抵抗 | 4.7kΩ |
| — | 計器 | Analog Discovery 3 の Scope (1+ = SCL、2+ = SDA、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。I2C のクロックは 100kHz で、1 ビットが 10µs。電圧の上下は 2 本の線を重ねて、
**クロック (SCL) が H の間、データ (SDA) が動かない**のを見る。ロジックアナライザ (Logic) でも見られるが、I2C の読み下しは付いていないので、ここは Scope にした。
ここで見るのは、Pico 2 が最初に送る「アドレス 0x18 に書く」の 1 バイト (0x30 = 0011 0000、下の説明) と、センサーの応答 (ACK)。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | SCL (GP1)。1V/div、0V を下から 3 目盛 |
| CH2 (2+) | SDA (GP0)。同じ 1V/div |
| 1−・2− | GND |
| 時間レンジ | 10µs/div (1 画面 100µs。1 バイトと ACK の 9 クロックが入る) |
| トリガ | CH2 (SDA) の立ち下がり、1.65V。START (SCL が H のまま SDA が H から L へ落ちる) を捕まえる。トリガの点を左端に置く |
| カーソル | X1 を 30µs (3 ビット目のクロックの H の間)、X2 を 80µs (8 ビット目のクロックの H の間) に置く |

```scope
title: 図3 アドレス 0x18 に書く 1 バイト (0x30) と ACK — SCL (CH1) と SDA (CH2)
time: 10us/div
trigger: ch2 falling 1.65V at -5div
ch1: {wave: square 100kHz 1.65V offset 1.65V phase 90deg, range: 1V/div, position: -3div}
ch2: {wave: = 3.3V - 3.3V * step(t) + 3.3V * (step(t - 25us) - step(t - 45us)), range: 1V/div, position: -3div}
cursors: [30us, 80us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/05-i2c-temperature.svg)

- 図3 の左端 (0µs) で SDA が H から L に落ちる (START)。そのあと SCL が 7.5µs・17.5µs… と立ち上がるたびに、SDA の値が 1 ビットずつ読まれる。
  読まれる値は上位ビットから 0・0・1・1・0・0・0・0。7 ビットのアドレス 0x18 (001 1000) と、書き込みを表す 0 の 8 ビットで、16 進で 0x30
- 9 つ目のクロック (87.5µs) で、センサーが SDA を L に引く (ACK。受け取った印)。ここが L なら、配線とアドレスが合っている。
  H のままなら応答が無く、プログラムは `read failed` や `OSError` になる
- X1 (30µs、SCL が H) の SDA は 3.3V (3 ビット目 = 1)、X2 (80µs) の SDA は 0V (8 ビット目 = 0)
- 図は理想の形。実機の SDA・SCL の立ち上がりは、プルアップの 4.7kΩ と配線の容量で数百 ns〜1µs ほどなまる (目安)

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
