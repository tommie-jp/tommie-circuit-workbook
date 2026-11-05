---
book: analog-discovery
chapter: 2
id: 2-28
title: 30 MHz の正弦を BNC で見る (perfboard)
tier: 200
source: 自作
board: PF
---

# 2-28 30 MHz の正弦を BNC で見る (perfboard)

AD3 の Scope は、BNC アダプタを付けると帯域が 30 MHz 以上ある (付属ワイヤでは 9 MHz、0-5)。
この題では、その上限の 30 MHz の正弦を作って、**同軸ケーブルと BNC で CH1 に入れて見る**。
Wavegen は 12 MHz までなので、30 MHz は水晶発振器 (方形波) で作り、3 次の低域で高調波を落として正弦にする。

30 MHz はブレッドボードの範囲 (3 MHz 以下) の外なので、ユニバーサル基板にはんだ付けして組む
(この冊の PF の印は 10 MHz までの目安だが、この題は計画どおり 30 MHz を PF に組む。リード部品は 30 MHz までそのまま使える)。
測る経路も、付属ワイヤでなく 50 Ω (オーム) の同軸と終端にする。ここで見るのは次の 3 つ。

- 125 MS/s で 30 MHz を取ると、1 周期に標本は 4.17 点しか無い。それでも正弦に見えるか
- 帯域の端なので、振幅が少し下がって見える
- 方形波の高調波 (90 MHz・150 MHz) が残ると、ナイキスト周波数 62.5 MHz を超えて**折り返し** (エイリアス、2-16) になる。だから正弦にしてから入れる

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 30 MHz の水晶発振器の方形波を 3 次の低域で正弦にし、50 Ω で CH1 へ
parts:
  U1: dip8 4,5
  VCC: vcc 5,1.5 5V
  G1: ground 3,8
  C1: capacitor 1.5,2.5 1.5,4.5 100n
  G2: ground 1.5,4.5
  C2: capacitor 7,4 9,4 100n
  R1: resistor 9,4 12,4 470
  R2: resistor 12,4 12,7 56
  G3: ground 12,7
  C3: capacitor 13.5,4 13.5,7 82p
  G4: ground 13.5,7
  L1: inductor 13.5,4 16.5,4 390n
  C4: capacitor 16.5,4 16.5,7 82p
  G5: ground 16.5,7
  J1: sma 19,4
  G6: ground 19,5.5
  RT: resistor 21,4 21,7 50
  G7: ground 21,7
wires:
  - 5,1.5 -- 5,2.5
  - U1.8 -| 5,2.5
  - 1.5,2.5 -- 3,2.5 -- 5,2.5
  - U1.1 -| 3,2.5
  - U1.4 -| 3,8
  - U1.5 -| 7,4
  - 12,4 -- 13.5,4
  - 16.5,4 -- J1.1
  - J1.2 -- 19,5.5
  - J1.1 -- 21,4
notes:
  - text 4.6,6.6 center: 30 MHz 水晶発振器
  - text 21,7.8 center: BNC の 50 Ω 終端 (CH1 の入口)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/28-30mhz-sine-bnc.svg)

- U1 は 5 V で動く 30 MHz の水晶発振器 (8 ピン DIP の大きさの金属の箱)。この図は代表的なピンの並び (1 番 OE (出力の許可) か NC、4 番 GND、5 番 OUT、8 番 VCC) で描いた。
  **型番によって並びが違うので、手持ちのデータシートで確かめる** (OE は VCC へつなげば出力が出る)
- C2 (100 nF) で直流を切り、R1 (470 Ω) と R2 (56 Ω) で振幅を下げる。R1 と R2 の並列は 470 × 56 / 526 = 50.0 Ω で、低域から見た信号源が 50 Ω になる。
  発振器の出力電流は ±2.5 V / 約 500 Ω ≈ ±5 mA に収まる
- C3・L1・C4 は 50 Ω の 3 次 Butterworth の低域 (遮断 40 MHz)。C = 1/(2π × 40 MHz × 50 Ω) (π (パイ)) = 79.6 pF → 82 pF、L = 2 × 50 Ω / (2π × 40 MHz) = 398 nH → 390 nH (どちらも E12)
- J1 は基板の縁の SMA。SMA-BNC の同軸ケーブル (50 cm ほど) で BNC アダプタの CH1 へ。**CH1 の入口に BNC の 50 Ω 終端 (フィードスルー) を挿す** (図の RT)。
  Scope の入力は 1 MΩ なので、終端が無いと低域の負荷が 50 Ω にならず、同軸の先で反射する

## 実体配線図

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
unused: [U1.2, U1.3, U1.6, U1.7]
title: 図2 ユニバーサル基板 (部品面。黄色の丸は AD3 の V+ と GND を挟む所)
parts:
  U1: dip8 c13
  C1: capacitor a16 a13 100n
  C2: capacitor g13 j13 100n
  R1: resistor k13 n13 470
  R2: resistor o13 o9 56
  C3: capacitor p13 p11 82p
  L1: inductor q13 t13 390n
  C4: capacitor u13 u11 82p
  J1: sma/female-edge x13 y14
wires:
  - c13 -- c16 red
  - c10 -- b10 red
  - b10 -- b16 red
  - a16 -- b16 red
  - b16 -- c16 red
  - a13 -- a6 black
  - f10 -- f6 black
  - a6 -- b6 black
  - b6 -- f6 black
  - f6 -- o6 black
  - o6 -- p6 black
  - p6 -- u6 black
  - u6 -- x6 black
  - f13 -- g13 orange
  - j13 -- k13 orange
  - n13 -- o13 orange
  - o13 -- p13 orange
  - p13 -- q13 orange
  - t13 -- u13 orange
  - u13 -- x13 orange
  - o9 -- o6 black
  - p11 -- p6 black
  - u11 -- u6 black
  - y12 -- x12 black
  - x12 -- x6 black
notes:
  - mark b16 yellow
  - mark b6 yellow
  - text b17 red large bold center: AD3 V+
  - text b5 red large bold center: GND
  - parts
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/perfboard/28-30mhz-sine-bnc.svg)

5×7 cm の基板を横に使う (A〜X 列 × 1〜18 行、A1 が左下)。

- U1 は C〜F 列・10〜13 行 (1 番が C10)。8 番 (C13) を 16 行の + の線へ、1 番 (C10) も B 列を上って + へ、4 番 (F10) を 6 行の GND の線へ
- C1 (100 nF) は A16〜A13 で、VCC のすぐ脇のバイパス
- 信号は 13 行を左から右へ: 5 番 (F13) → C2 → R1 → (R2・C3 を下の GND へ) → L1 → (C4 を GND へ) → J1 (X13 の中心導体)
- J1 の外側の腕 (Y12) は X12 を通って GND の線へ
- AD3 の Supplies は、黄色の丸の B16 (V+、5 V) と B6 (GND) にミノムシで挟む。CH1 は J1 から同軸でつなぐので、基板には挟まない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable (発振器の電流は 10〜20 mA ほどが目安、USB 給電の 250 mW の内側) |
| 接続 | BNC アダプタを付け、J1 → SMA-BNC の同軸 → 50 Ω の終端 → CH1 |
| Scope (CH1) | DC、50 mV/div、Time 10 ns/div、Trigger CH1 の立ち上がり 0 V |
| サンプリング | 最速 (125 MS/s。システムクロックを 125 MHz にする、2-10) |
| Measurements | Vpp と Frequency |

見えるはずの画面 (理想の正弦、計算値) が図3。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH1 に見えるはずの 30 MHz (約 0.30 Vpp、周期 33.3 ns)
time: 10ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 30MHz 150mV, range: 50mV/div}
cursors: [0, 33.33ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/28-30mhz-sine-bnc.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 水晶発振器 (5 V、8 ピン DIP の大きさ) | 30 MHz (ピンの並びはデータシートで確かめる) |
| C1, C2 | セラミックコンデンサ | 100 nF (104) |
| R1 | 抵抗 (1/4 W) | 470 Ω |
| R2 | 抵抗 (1/4 W) | 56 Ω |
| C3, C4 | セラミックコンデンサ (C0G) | 82 pF (820) |
| L1 | インダクタ (アキシアル・リード) | 390 nH (自己共振が 100 MHz より十分上の物) |
| J1 | SMA コネクタ (メス、基板の縁に付ける形) | — |
| — | SMA-BNC の同軸ケーブル (50 Ω)・BNC の 50 Ω 終端 (フィードスルー) | 計器の側の付属品 |
| — | 電源 | Analog Discovery 3 の V+ (5 V) |

抵抗の電力は R1 で (2.5 V)² / 526 Ω × 470/526 ≈ 11 mW ほどで、1/4 W の半分よりずっと小さい。

## 見るべき値

計算値。発振器の 0〜5 V の方形波は C2 で ±2.5 V になり、R1・R2 で 56/526 = 0.106 倍、低域の通る帯で終端との分圧が 1/2。
方形波の基本波の振幅は 4/π × 2.5 V = 3.18 V なので、30 MHz の正弦の振幅は 3.18 V × 0.106 × 1/2 × (30 MHz での低域の落ち 0.89) ≈ **0.15 V (0.30 Vpp)**。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Frequency | 30.00 MHz (水晶なので ±50 ppm ほど、目安) | 周波数は帯域の端でも正しく読める |
| CH1 の Vpp | 0.30 Vpp。Scope の帯域の端なので 0.21〜0.30 Vpp に見えるはず (−3 dB の点が 30 MHz を少し超えた所にあるとして) | 帯域の端では振幅が当てにならない。周波数を下げて (例えば 10 MHz の発振器で) 比べると、どれだけ落ちたか分かる |
| 1 周期の標本の数 | 125 MS/s で 4.17 点 (8 ns ごと) | 標本の点だけを線で結ぶと角張った波に見える。WaveForms が標本の間を補う表示なら正弦に見える (目安) |
| 3 次高調波 (90 MHz) の残り | 基本波の 4 % ほど (−29 dB)。125 MS/s では 125 − 90 = **35 MHz** に折り返す | 正弦の形が少しゆがみ、周期ごとに形が揺れて見える。低域を外すと方形波の 1/3 (33 %) が折り返し、波形は崩れる |
| 5 次高調波 (150 MHz) の残り | 基本波の 0.4 % ほど。150 − 125 = 25 MHz に折り返す | 3 次より小さく、目ではほぼ見えない |
| 終端を外したとき | 振幅が 2 倍近くまで上がり、同軸の長さで形と大きさが変わる | 50 Ω の系は終端してはじめて設計どおりの振幅と形になる |

**30 MHz は AD3 で見られる上限で、振幅の数は目安にとどめる。** 周波数と波形の有無を確かめるのに使い、
振幅や高調波を正しく測るならスペクトラム (第 4 章) か、tinySA・NanoVNA (NanoVNA と tinySA の教科書) で測る。

## LTspice での確かめ

`sim/28-30mhz-lpf.cir` (過渡解析、0/5 V・30 MHz の方形波、立ち上がり 2 ns、出力抵抗 20 Ω と仮定) と
`sim/28-30mhz-lpf-ac.cir` (同じ回路の .ac) で、50 cm の同軸 (理想の 50 Ω 線路) と 50 Ω の終端、CH1 の 1 MΩ ∥ 24 pF までを解いた。
Scope 自身の帯域は入れていない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 低域の通る帯の利得 (1 MHz、R1・R2 と終端を含む) | 0.106 × 1/2 = 0.053 | 0.0532 | 合う |
| −3 dB の周波数 | 40 MHz (設計) | 37.7 MHz | 近い (82 pF・390 nH に丸めたのと、CH1 の 24 pF のぶん) |
| 30 MHz の利得 (1 MHz に対して) | 0.89 | 0.888 (0.0472 / 0.0532) | 合う |
| 90 MHz・150 MHz の落ち (1 MHz に対して) | 3 次の Butterworth で −21 dB・−34 dB | −19.7 dB・−39.4 dB | 近い (同軸と 24 pF のぶん) |
| 終端での Vpp | 0.30 Vpp | 0.287 Vpp | 合う (発振器の出力抵抗 20 Ω のぶん少し低い) |
| 歪み (2〜5 次の高調波の和) | 3 次で 4 % ほど | 3.7 % (−28.7 dB) | 合う |

折り返しの周波数 (35 MHz・25 MHz) は |n × 30 MHz − 125 MHz| の算術。

## 出典

自作。Scope の帯域 (BNC アダプタで 30 MHz 以上) と最大 125 MS/s は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf) による。

参考: [Butterworth filter (Wikipedia)](https://en.wikipedia.org/wiki/Butterworth_filter)、[エイリアシング (Wikipedia)](https://ja.wikipedia.org/wiki/エイリアシング)
