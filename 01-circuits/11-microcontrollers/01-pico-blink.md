---
book: circuits
chapter: 11
id: 11-1
title: Pico の L チカ
tier: 50
source: 自作
board: BB
era: 今
---

# 11-1 Pico の L チカ

Raspberry Pi Pico の GPIO ピン 1 本に LED をつなぎ、MicroPython で点滅させる。
マイコンで最初に書くプログラムの定番「L チカ」を、外付けの LED で行う
(基板上の LED は GP25 に固定されていて配線の練習にならない)。

## 回路図

```circuit
title: 図1 PicoでLEDを点滅させる
parts:
  U1: pico e3c0 mirror
  R1: resistor i6 i8 330
  D1: led i8 k8 red
  G1: ground k8
wires:
  - U1.GP15 -| i6
style:
  pitch: 1.2
```

- GP15 (汎用入出力) を出力に設定し、program で H (3.3V) / L (0V) を切り替える
- R1 (330Ω) が電流を決める。3.3V − V<sub>F</sub> (赤色 LED 約2.0V) を 330Ω で割ると
  約 3.9mA。Pico の GPIO は 1 本あたり最大 12mA (合計 50mA) までなので余裕がある

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico @ h5
  R1: resistor j24 j28 330
  D1: led j32(A) j34(K) red
wires:
  - j28 -- j32
  - j34 -- -b34
  - -t50 -- -b50
```

- `pico @ h5` は基板の左端 (h 行、ピン 1 = GP0) を指す。USB を左に向けた
  ときの実物のピン配置のまま
- GP15 (ピン20) は下側のピン列にあるので `j` 行 (下ブロック) の空いた穴から
  配線する。`h5` に置いたとき `j24` が GP15 の列 (`j23` は隣の GP14)
- LED のカソード側は下の − レール (GND) へ。上下の − レールは 50 列で渡して
  おく (Pico の GND はどのピンも同じネットなので、上のレールを使わなくてもよい)

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| GP15 が H のときの R1 の両端 | 約1.3V (3.3 − 2.0) |
| R1 に流れる電流 | 約3.9mA |
| LED の両端 | 約2.0V (順方向電圧、赤色) |

MicroPython で `Pin(15, Pin.OUT)` を作り、`value(1)` / `value(0)` を
`sleep(0.5)` を挟んで繰り返すと点滅する。

## 出典

自作。
