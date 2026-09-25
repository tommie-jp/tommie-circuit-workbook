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
  U1: pico b2
  SENS:
    type: device
    at: h2
    label: MCP9808
    pins: [VDD, GND, SDA, SCL]
  Rsda: resistor e12 g12 4.7k
  Rscl: resistor e15 g15 4.7k
wires:
  - U1.3V3 -| e10
  - e10 -- e12
  - e10 -- e15
  - e10 -| SENS.VDD
  - g12 |- SENS.SDA
  - g15 |- SENS.SCL
  - U1.GP0 -| SENS.SDA
  - U1.GP1 -| SENS.SCL
  - U1.GND3 |- SENS.GND
```

- **SDA (GP0) と SCL (GP1)** が I2C0。どちらも**プルアップ抵抗 (4.7kΩ)** で
  3.3V に持ち上げておく — I2C はオープンドレインの規格で、H は抵抗が
  作り、L はどちらかの機器が引き下げる (10-18 で詳しく扱う)
- 市販の MCP9808 モジュールは基板上に**プルアップを内蔵**していることが
  多い。複数枚つなぐと並列になって効きすぎる (プルアップが強すぎて
  波形がなまらなくなる方向なので実害は小さいが)、1 枚だけなら外付けの
  4.7kΩ は無くても動くことがある
- MCP9808 は I2C アドレス **0x18** (デフォルト、A0〜A2 未接続時)。
  分解能 0.0625℃、精度は目安 ±0.25℃ (typ)、±0.5℃ (max、−40〜+125℃)

## 見るべき値

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
| negative の例 (−10.0℃) | 0x1F | 0x60 | 符号あり: (15×16 + 0x60/16) − 256 = **−10.0℃** |

| 測る所 | 期待する値 |
| --- | --- |
| `i2c.scan()` の結果 | `[24]` (0x18 の 10進、計算値) |
| 室温での `temp` | だいたい 20〜28℃ (季節・部屋による) |
| センサを指で温める | 数℃上がる (分解能 0.0625℃ なのですぐ反応する) |

`i2c.scan()` は接続を確かめる第一歩。何も出なければ、SDA/SCL の
プルアップ忘れか、配線の左右 (SDA と SCL) の取り違えを疑う。

## 出典

自作。MCP9808 のレジスタ読み出しは Microchip のデータシート
(Ambient Temperature Register, 05h) の手順による。
