---
book: circuits
chapter: 3
id: 3-2
title: 555 非安定 — LED 点滅
tier: 50
source: 自作
board: BB
---

# 3-2 555 非安定 — LED 点滅

タイマー IC の定番 **NE555** を非安定 (astable) 接続にして LED を点滅させる。
3-1 のトランジスタ 2 石と同じ「非安定」だが、周期は 2 本の抵抗と
コンデンサ 1 個だけで決まり、計算どおりに動きやすい。

## 回路図

```circuit
title: 図1 555 非安定
parts:
  V1: vsource vcc gnd 9
  G1: ground gnd
  U1: dip8 d3 NE555
  Ra: resistor vcc b8 10k
  Rb: resistor b8 c10 47k
  C1: ecap c10 gnd 10u
  Cc: capacitor d12 gnd 10n
  R1: resistor d14 e14 330
  D1: led e14 gnd red
points:
  vcc: a6
  gnd: h6
wires:
  - b8 |- U1.7
  - c10 |- U1.6
  - c10 |- U1.2
  - vcc |- U1.8
  - vcc |- U1.4
  - gnd |- U1.1
  - d12 |- U1.5
  - d14 |- U1.3
style:
  grid: on
```

- **2 番 (TRIG) と 6 番 (THR) を直結**するのが非安定接続の印。この 1 点の電圧が
  1/3 Vcc〜2/3 Vcc の間を上下し続け、それに合わせて 3 番 (OUT) が反転する
- **7 番 (DISCH) は Ra・Rb の中点**。C1 を充電するときは Ra + Rb を通り、
  放電するときは内部トランジスタが 7 番を GND に落として Rb だけを通る。
  充電より放電が速いので、555 の非安定は**必ず High のほうが長い**
- Cc (0.01 µF) は 5 番 (CTRL) のノイズ対策。無くても発振はするが、
  付けておくのが定石

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +9V/GND、下のレールも +9V/GND (1 列目で上下を渡している)
board: half
parts:
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 10k
  Rb: resistor c11 c12 47k
  C1: capacitor/electrolytic d12(+) d9(-) 10uF
  Cc: capacitor d13 d20 10n
  R1: resistor g12 g16 330
  D1: led h16(A) h19(K) red
wires:
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - c9 -- -t9 black
  - c20 -- -t20 black
  - h11 -- c12 orange
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j19 -- -b19 black
```

- **DIP8 は溝をまたいで挿す** (e 行と f 行)。1 番 (GND) が左下の f10、8 番 (VCC) が
  左上の e10。切り欠きを左に向ける
- 2 番 (TRIG、f11) は下ブロックにあるので、板の上の 6 番 (THR、e12) へは
  `h11 -- c12` の 1 本で渡す
- 4 番 (RESET) は使わないので +9V に固定 (`i13 -- +b13`)。浮かせておくと
  誤動作することがある

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| Ra | 抵抗 | 10 kΩ |
| Rb | 抵抗 | 47 kΩ |
| C1 | 電解コンデンサ (タイミング) | 10 µF |
| Cc | セラミックコンデンサ (CTRL のノイズ対策) | 0.01 µF |
| R1 | 抵抗 (LED 電流制限) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 9 V |

## 見るべき値

計算値。f = 1.44 / {(Ra + 2Rb) × C}、High の時間は (Ra + Rb) × C × 0.693、
Low の時間は Rb × C × 0.693。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 3 番 (OUT) の周波数 | 約 1.39 Hz (周期 約 0.72 秒) | Ra・Rb・C1 だけで決まる |
| Low (LED 消灯) の時間 | 約 0.33 秒 | Rb × C1 × 0.693 |
| High (LED 点灯) の時間 | 約 0.40 秒 | (Ra + Rb) × C1 × 0.693 |
| デューティ比 (High の割合) | 約 55% | (Ra+Rb) / (Ra+2Rb)。**555 の非安定はきっちり 50% にならない** |
| LED の電流 (点灯中) | 約 9.1 mA | (9 V − 出力の飽和 (約 0.5 V) − 2.0 V) ÷ 330 Ω |

Ra を 0 に近づけると デューティ比は 50% に近づくが、Ra が小さすぎると
放電時に 7 番から Vcc へ大電流が流れて IC を痛める (下限は 1 kΩ 程度)。
デューティ比をきっちり変えたいなら 3-6 のダイオード付き PWM を見る。

## 出典

自作。
