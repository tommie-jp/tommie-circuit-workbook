---
book: circuits
chapter: 10
id: 10-5
title: D フリップフロップ (4013) と T フリップフロップ
tier: 100
source: 自作
---

# 10-5 D フリップフロップ (4013) と T フリップフロップ

10-2 の RS ラッチは NAND 2 個の手作りだったが、ここでは D フリップフロップの
IC (CD4013、2 回路入り) を使う。1 回路はそのまま **D-FF** (クロックの
立ち上がりで D をそのまま Q に写す) として、もう 1 回路は Q̄ を D に戻す配線で
**T-FF** (クロックが来るたびに Q が反転する) に仕立てる。

## 回路図

```circuit
title: 図1 D-FFとQバー帰還のT-FF (CD4013)
parts:
  VCC: vcc e4e0
  SWD: switch e4e0 g4e0
  RpdD: resistor g4e0 i4e0 10k
  GD: ground i4e0
  VCC: vcc d7g5
  SWC1: button d7g5 f7g5
  RpdC1: resistor f7g5 f5g5 10k
  GC1: ground f5g5 r90
  U1: dip14 g12 CD4013
  VCC: vcc e13i0
  GU1: ground i11
  RQ1: resistor c9a5 d9a5 330
  DQ1: led d9a5 e9a5 red
  GQ1: ground e9a5
  VCC: vcc e15a5
  SWC2: button e15a5 g15a5
  RpdC2: resistor g15a5 i15a5 10k
  GC2: ground i15a5
  RQ2: resistor c17a5 d17a5 330
  DQ2: led d17a5 e17a5 red
  GQ2: ground e17a5
  GR1: ground g11 r90
  GR2: ground g13e3 r270
  GS2: ground i13
wires:
  - U1.14 -| e13i0
  - U1.5 -| g4e0
  - U1.3 -| f7g5
  - U1.4 -| g11
  - U1.6 -| h11c0
  - U1.7 -| h11c0
  - h11c0 -- i11
  - U1.1 -| c11
  - c11 -- c9a5
  - U1.11 -| g15a5
  - U1.10 -| g13e3
  - U1.8 -| i13
  - U1.13 -| c13a8
  - c13a8 -- c17a5
  - U1.12 -| g14i2
  - g14i2 |- U1.9
notes:
  - text c2 blue: "D1 (足5)"
  - text b5 blue: "CLK1 (足3、立ち上がりでDをQへ)"
  - text b14 blue: "CLK2 (足11、押すたびにQが反転)"
style:
  grid: on
  pitch: 1.2
```

- **FF1 (D-FF)**: SWD が D1 (足5)。SWC1 (CLK1、足3) を押すと GND から
  Vcc へ立ち上がり、その瞬間の D1 の状態を Q1 (足1) にコピーする。押している
  間や離したあとは D1 を変えても Q1 は動かない (次の立ち上がりまで保持)
- **FF2 (T-FF)**: Q2̄ (足12) を D2 (足9) へ配線で戻してあるので、CLK2 (足11)
  の**立ち上がりのたびに Q2 (足13) が反転**する。SWC2 を 1 回押すごとに
  Q2 の LED が点滅を繰り返す — これは 10-4 の 4040 が内部でやっている
  「1 段で 1/2 分周する」仕組みそのもの
- RESET (足4・10)・SET (足6・8) は CD4013 では**Hレベルで効く**ので、
  使わないここでは両方 GND に落として無効化する
- CLK 入力はボタンの手で押すチャタリングがそのまま Q に伝わることがある
  (Q が 1 回の押下で 2 回以上反転して見える)。きれいな 1 パルスにするには
  10-9 のチャタリング除去を足すとよい

## 見るべき値

| 操作 | Q1 (LED1) | Q2 (LED2) |
| --- | --- | --- |
| D1 を閉じて (1) SWC1 を押す | **点灯 (1) に変わる** | — |
| D1 を開けて (0) SWC1 を押す | **消灯 (0) に変わる** | — |
| D1 を変えずに SWC1 をもう一度押す | 変わらない (直前の値を保持) | — |
| SWC2 を 1 回押す | — | **反転** (消灯→点灯 か 点灯→消灯) |
| SWC2 をもう 1 回押す | — | **また反転** (元に戻る) |

T-FF の Q2 は、CLK2 を 2 回押してようやく 1 周する。CLK2 に一定間隔のパルス
(例えば 555 の出力) を入れれば、Q2 はその**半分の周波数**で振れる。

## 出典

自作。
