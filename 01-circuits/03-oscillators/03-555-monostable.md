---
book: circuits
chapter: 3
id: 3-3
title: 555 単安定 — タイマー
tier: 50
source: 自作
board: BB
---

# 3-3 555 単安定 — タイマー

NE555 を単安定 (monostable) 接続にする。ボタンを 1 回押すと、LED が
一定の時間だけ点いて自動で消える。「押したら一定時間だけ動く」の基本形。

## 回路図

```circuit
title: 図1 555 単安定
parts:
  V1: vsource vcc gnd 9
  G1: ground gnd
  U1: dip8 d3 NE555
  R1: resistor vcc c10 100k
  C1: ecap c10 gnd 10u
  R2: resistor vcc b3 10k
  SW1: button b3 gnd
  Cc: capacitor d12 gnd 10n
  R3: resistor d14 e14 330
  D1: led e14 gnd red
points:
  vcc: a6
  gnd: h6
wires:
  - b3 |- U1.2
  - c10 |- U1.7
  - c10 |- U1.6
  - vcc |- U1.8
  - vcc |- U1.4
  - gnd |- U1.1
  - d12 |- U1.5
  - d14 |- U1.3
style:
  grid: on
```

- **2 番 (TRIG) は常に R2 で Vcc に釣り上げてある。** SW1 を押した瞬間だけ GND に
  落ち、それが引き金になって 3 番 (OUT) が High になる
- **7 番・6 番は R1・C1 の 1 点。** OUT が High の間だけ C1 を R1 で充電し、
  2/3 Vcc に達したら 555 が自分で OUT を Low に戻す (SW1 を離しても止まらない)
- 4 番 (RESET) は Vcc に固定、5 番 (CTRL) は Cc (0.01 µF) で GND にノイズ対策

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +9V/GND、下のレールも +9V/GND (1 列目で上下を渡している)
board: half
parts:
  U1: dip8 @ e10 NE555
  R1: resistor b7 c11 100k
  C1: capacitor/electrolytic d11(+) d9(-) 10uF
  R2: resistor g11 g16 10k
  SW1: button @ f19
  Cc: capacitor d13 d20 10n
  R3: resistor g12 g23 330
  D1: led h23(A) h26(K) red
wires:
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - a11 -- a12
  - c9 -- -t9 black
  - c20 -- -t20 black
  - f16 -- +b16 red
  - h19 -- h11 orange
  - b19 -- -t19 black
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j26 -- -b26 black
```

- **R1 の右足 (11 列) が 7 番、6 番 (12 列) とは `a11--a12` の 1 本だけで結ぶ**
  (どちらも R1・C1 の同じ 1 点)
- SW1 (タクトスイッチ) は溝をまたぐ 4 本足で、`e19` `f19` `e21` `f21` を占める。
  **溝の手前 (f 行、下ブロック) を 2 番 (11 列) へ、溝の向こう (e 行、上ブロック) を
  GND へ**。同じ側 (同じブロック) の 2 本足は押していなくても中でつながっている
- 4 番 (RESET) は使わないので +9V に固定 (`i13 -- +b13`)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| R1 | 抵抗 (タイミング) | 100 kΩ |
| C1 | 電解コンデンサ (タイミング) | 10 µF |
| R2 | 抵抗 (TRIG のプルアップ) | 10 kΩ |
| SW1 | タクトスイッチ | — |
| Cc | セラミックコンデンサ (CTRL) | 0.01 µF |
| R3 | 抵抗 (LED 電流制限) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 9 V |

## 見るべき値

計算値。パルス幅 T = 1.1 × R1 × C1。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SW1 を押してから LED が消えるまでの時間 | 約 1.1 秒 | R1 × C1 × 1.1 (Vcc の値によらない) |
| パルス中の 3 番 (OUT) の電圧 | 約 8.5 V (Vcc 近く) | 555 の出力段が Vcc に近いところまで振れる |
| パルス中に SW1 を離した場合 | 変わらず約 1.1 秒で消える | 単安定は**一度始まると引き金を離しても止まらない** |
| パルスの途中でもう一度 SW1 を押した場合 | その瞬間から再び約 1.1 秒 | リトリガ可能 (2 番が Low になれば何度でも延長される) |

R1 を 1 MΩ にすると約 11 秒まで延ばせる (555 の DISCH 内部トランジスタの
リーク電流が無視できる範囲なら)。12-1 の「おやすみタイマー」はこの回路の応用。

## 出典

自作。
