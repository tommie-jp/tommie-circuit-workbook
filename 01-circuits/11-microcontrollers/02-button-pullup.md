---
book: circuits
chapter: 11
id: 11-2
title: ボタン入力とプルアップ
tier: 50
source: 自作
board: BB
era: 今
---

# 11-2 ボタン入力とプルアップ

Pico の GPIO でボタンを読む。**外付けの抵抗でプルアップ**し、押していない間は
GPIO が確実に H (3.3V) になるようにする。Pico は内蔵プルアップも使えるが、
ここでは抵抗が電位を決める働きを目で追えるように外付けにする。

## 回路図

```circuit
title: 図1 プルアップ抵抗とボタン
parts:
  U1: pico e3c0
  R1: resistor f6 i6 10k
  SW1: button i6 k6
  G1: ground k6
wires:
  - U1.3V3 -| f6
  - U1.GP16 -| i5 -- i6
style:
  pitch: 1.2
```

- R1 (10kΩ) が GP16 を 3V3 (Pico が出す 3.3V) へ引き上げる。ボタンを離している間、
  GP16 は 3.3V (H)
- SW1 を押すと GP16 が直接 GND につながり、0V (L) になる。R1 には
  3.3V ÷ 10kΩ ≈ 0.33mA しか流れないので、GPIO やボタンを壊さない
- **3V3 (Pico 自身が出す 3.3V) を使う**。VBUS (5V) をここにつなぐと GPIO の
  定格 (3.3V) を超えて壊れる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  MCU: pico @ h5
  R1: resistor a30 a33 10k
  SW1: button @ e35
wires:
  - MCU.3V3 -- +t9
  - MCU.GND3 -- -t7
  - +t9 -- b30
  - MCU.GP16 -- b33
  - b33 -- b35
  - g37 -- -b37
```

- Pico の `3V3` (36番) を + レールへ、`GND` (3番) を − レールへ (USB を挿した
  だけではレールに出ないので、この 2 本は必ず配線する)
- GP16 は Pico の胴の外、30 列あたりの空いた穴まで配線してから R1・SW1 へ
  つなぐ (胴の真上・真下の列は他のピンと紛れやすいので避ける)
- R1 の左足を + レールへ、SW1 の奥側を − レールへ

## 見るべき値

計算値。

| 状態 | GP16 の電圧 | R1 の電流 |
| --- | --- | --- |
| ボタンを離している | 約3.3V (H) | ほぼ0 (GPIO 入力はほぼ電流を引かない) |
| ボタンを押している | 0V (L) | 約0.33mA (3.3V ÷ 10kΩ) |

MicroPython で `Pin(16, Pin.IN)` を作り `value()` を読むと、離しているとき
`1`、押しているとき `0` になる。

## 出典

自作。
