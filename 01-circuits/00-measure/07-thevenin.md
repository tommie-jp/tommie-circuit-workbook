---
book: circuits
chapter: 0
id: 0-7
title: テブナン等価を測って確かめる
tier: 200
source: 自作
board: BB
---

# 0-7 テブナン等価を測って確かめる

抵抗と電源がいくつ組み合わさった回路でも、2 つの端子から外を見る限りは、
**電圧源 1 つ (V<sub>th</sub>) と抵抗 1 本 (R<sub>th</sub>) の直列**と区別がつかない。
これが**テブナンの定理**で、V<sub>th</sub> を**テブナン電圧**、R<sub>th</sub> を**テブナン抵抗**という。
負荷をいろいろに替えたときの電圧を、いちいち回路全体で解かなくても、2 つの数だけで計算できる。

この題では、分圧回路に抵抗を 1 本足した回路の V<sub>th</sub> と R<sub>th</sub> を**測って**求め、
その値で組んだ等価回路と元の回路に同じ負荷をつないで、端子の電圧が同じになることを確かめる。
測り方は 3 つある。

1. **開放電圧**: 端子に何もつながないときの電圧が V<sub>th</sub>
2. **短絡電流**: 端子を電流計で短絡したときの電流 I<sub>sc</sub> から R<sub>th</sub> = V<sub>th</sub> / I<sub>sc</sub>
3. **半分の電圧**: 負荷 R<sub>L</sub> をつないで電圧が V<sub>th</sub> の半分になったとき R<sub>L</sub> = R<sub>th</sub>

電池の内部抵抗 (1-14 のレモン電池など)、センサーの出力、増幅器の出力抵抗も、同じ考え方で 2 つの数にまとめて扱う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 元の回路 (左) とテブナン等価 (右)。同じ負荷 RL で CH1 と CH2 が同じになる
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,3 2.2k
  R2: resistor 2,3 2,5 3.3k
  G1: ground 2,5
  R3: resistor 2,3 4,3 1k
  RL1: resistor 5,3 5,5 2.2k
  M1: voltmeter 7,3 7,5 l=$\mathrm{CH1}$
  G2: ground 5,5
  G3: ground 7,5
  W1: vsource 10,3 10,5 3
  R4: resistor 10,3 12,3 2.2k
  R5: resistor 12,3 14,3 120
  RL2: resistor 15,3 15,5 2.2k
  M2: voltmeter 17,3 17,5 l=$\mathrm{CH2}$
  G4: ground 10,5
  G5: ground 15,5
  G6: ground 17,5
wires:
  - 4,3 -- 5,3
  - 5,3 -- 7,3
  - 14,3 -- 15,3
  - 15,3 -- 17,3
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/circuit/07-thevenin.svg)

左が元の回路で、電源は Analog Discovery 3 (AD3) の Supplies の V+ (5 V)。端子は `R3` の右の端と GND。
右がテブナン等価で、電圧源は AD3 の Wavegen の W1 を直流 (DC) 3.0 V にして使い、`R4` と `R5` の直列で R<sub>th</sub> を作る。

- **V<sub>th</sub>** (端子を開いたときの電圧): `R3` には電流が流れないので、`R1`・`R2` の分圧そのまま。
  5 V × 3.3 k / (2.2 k + 3.3 k) = **3.00 V**
- **R<sub>th</sub>** (電源を短絡して端子から見た抵抗): V+ を GND とつないだと考えると、`R1` と `R2` は並列になり、
  2.2 k × 3.3 k / 5.5 k = 1.32 kΩ。それに `R3` の 1 kΩ が直列で **2.32 kΩ**
- **I<sub>sc</sub>** (端子を短絡したときの電流): 3.00 V / 2.32 kΩ = **1.29 mA**
- 負荷 R<sub>L</sub> をつないだときの端子の電圧は、等価回路の分圧で V = V<sub>th</sub> × R<sub>L</sub> / (R<sub>th</sub> + R<sub>L</sub>)。
  R<sub>L</sub> = 2.2 kΩ なら 3.00 × 2.2 / 4.52 = **1.46 V**

2.32 kΩ は E24 に無いので、等価回路の R<sub>th</sub> は 2.2 kΩ と 120 Ω の直列で作る (部品表)。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上のブロックに元の回路、下のブロックにテブナン等価
board: half
parts:
  R1: resistor b3 b7 2.2k
  R2: resistor a7 -t7 3.3k
  R3: resistor d7 d13 1k
  RL1: resistor b13 b17 2.2k
  R4: resistor i3 i9 2.2k
  R5: resistor g9 g13 120
  RL2: resistor i13 i17 2.2k
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (電源・CH1)
    pins: [V+, GND, 1+, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (W1・CH2)
    pins: [W1, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t3 -- a3 red
  - AD.1+ -- a13 orange
  - AD.1- -- -t15 black
  - a17 -- -t17 black
  - AD1.W1 -- j3 yellow
  - AD1.2+ -- j13 blue
  - AD1.2- -- -b15 black
  - j17 -- -b17 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/breadboard/07-thevenin.svg)

上のブロック (a〜e 行) が図1 の左、下のブロック (f〜j 行) が右。

- **元の回路**: V+ (5 V) を上の + レールへ入れ、列 3 から `R1` で列 7 (分圧の点) へ。`R2` は列 7 から上の − レールへ縦に挿す。
  `R3` で列 13 (端子) へ出し、負荷 `RL1` は列 13 から列 17 へ、列 17 を − レールへ。CH1 の 1+ は列 13
- **等価回路**: W1 を列 3 に入れ、`R4` (2.2 kΩ) と `R5` (120 Ω) で列 13 (端子) へ。負荷 `RL2` は列 13 から列 17、列 17 を下の − レールへ。CH2 の 2+ は列 13
- 上下の − レールは列 29 の黒線でつなぐ。W1 と Scope の GND は AD3 の中で Supplies の GND と同じ
- 流れる電流は 1.3 mA 以下で、AD3 の V+ と W1 (約 10 mA まで) の範囲に十分収まる

**負荷を替えるとき**は `RL1` と `RL2` を同じ値の抵抗に差し替える。**開放電圧**は両方を抜いて読む。
**短絡電流**は、負荷を抜いた列 13 (上か下) と GND の間にテスターの電流端子 (mA レンジ) を当てて読む。

## 計器の設定

計器は AD3 (Supplies・Wavegen・Scope) とテスター。見るのは時間で変わらない直流の電圧・電流・抵抗だけなので、オシロの図は付けない。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5.0 V、V− は使わない |
| Wavegen W1 | 波形を DC、オフセット 3.00 V (テスターで W1 の出力を 3.00 V に合わせてからつなぐ) |
| Scope | CH1・CH2 とも DC、500 mV/div。WaveForms の Measurements で 2 つの ch の平均 (Average) を読む |
| テスター | 短絡電流は直流電流 (mA)、R<sub>th</sub> は抵抗のレンジ |

AD3 の Scope の入力は約 1 MΩ で、2.32 kΩ の回路には 0.2 % しか負荷にならない (開放電圧の読みが 2.99 V になる程度)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R4 | 抵抗 (1/4 W) | 2.2 kΩ |
| R2 | 抵抗 (1/4 W) | 3.3 kΩ |
| R3 | 抵抗 (1/4 W) | 1 kΩ |
| R5 | 抵抗 (1/4 W) | 120 Ω (R4 と直列で R<sub>th</sub> 2.32 kΩ。E24 に無い値を 2 本で作る) |
| RL1, RL2 | 抵抗 (1/4 W) | 2.2 kΩ を 2 本。ほかに 1 kΩ・10 kΩ を 2 本ずつ (負荷を替える) |
| — | 電源 | AD3 の V+ (5 V) と W1 (DC 3.0 V) |

## 見るべき値

順に、負荷を抜いて開放電圧 → 負荷を 3 種類 → 短絡電流 → R<sub>th</sub> を測る。

| 測る所 | 期待する値 (計算値) | 測った値 (元 / 等価) | 分かること |
| --- | --- | --- | --- |
| 開放電圧 (負荷なし) | 3.00 V | | V<sub>th</sub> |
| R<sub>L</sub> = 10 kΩ | 2.44 V | | 負荷が R<sub>th</sub> より大きいと、電圧はあまり下がらない |
| R<sub>L</sub> = 2.2 kΩ | 1.46 V | | R<sub>L</sub> ≈ R<sub>th</sub> でほぼ半分 (半分の電圧の測り方) |
| R<sub>L</sub> = 1 kΩ | 0.90 V | | 負荷が R<sub>th</sub> より小さいと大きく下がる |
| 短絡電流 (テスター) | 1.29 mA | | R<sub>th</sub> = 3.00 V / 1.29 mA = 2.32 kΩ |
| 端子から見た抵抗 (V+ を外して列 3 を GND へ、負荷なし) | 2.32 kΩ | | 電源を短絡して見た抵抗が R<sub>th</sub> |

**元と等価で、どの負荷でも同じ電圧**になれば成功。ずれるなら、まず抵抗の誤差 (±5 %) と W1 の 3.00 V の合わせを疑う。

元の回路の端子の電圧と電流を、負荷ごとの点で並べると 1 本の直線になる (図3)。
この直線が縦軸と交わる所が V<sub>th</sub>、横軸と交わる所が I<sub>sc</sub>、傾きの大きさが R<sub>th</sub> になる。
電流は電圧 ÷ R<sub>L</sub> で求める (2.2 kΩ なら 1.46 V / 2.2 kΩ = 0.66 mA)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 端子の電圧と電流は直線に乗る — 切片が Vth と Isc、傾きが Rth
x: 負荷の電流 mA 0..1.3
y: 端子の電圧 V 0..3.2
lines:
  テブナン等価 V: 3 - 2.32*x
notes:
  - mark 0.244
  - mark 0.664
  - mark 0.904
  - mark 1.2931
  - text 0.36 2.75V: RL 10kΩ
  - text 0.72 1.60V: RL 2.2kΩ
  - text 0.96 1.05V: RL 1kΩ
  - text 0.98 0.10V: 短絡 (Isc) →
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/graph/07-thevenin.svg)

## LTspice での確かめ

`sim/07-thevenin.cir` で、図1 の元の回路と等価回路に同じ負荷 (開放 1 GΩ・10 kΩ・2.2 kΩ・1 kΩ・短絡 1 mΩ) を `.step` でつなぎ、`.op` で端子の電圧と電流を読んだ。

| 項目 | 本文の数字 | LTspice (元 / 等価) | 判定 |
| --- | --- | --- | --- |
| 開放電圧 | 3.00 V | 3.000 V / 3.000 V | 合う |
| R<sub>L</sub> = 10 kΩ | 2.44 V | 2.435 V / 2.435 V | 合う |
| R<sub>L</sub> = 2.2 kΩ | 1.46 V | 1.460 V / 1.460 V | 合う |
| R<sub>L</sub> = 1 kΩ | 0.90 V | 0.904 V / 0.904 V | 合う |
| 短絡電流 | 1.29 mA | 1.293 mA / 1.293 mA | 合う |

元と等価は、どの負荷でも 4 桁まで同じ値になった (抵抗が理想の値なので、テブナンの定理のとおり完全に一致する)。

## 出典

自作。

参考: [テブナンの定理 (Wikipedia)](https://ja.wikipedia.org/wiki/テブナンの定理)、[Thévenin's theorem (Wikipedia)](https://en.wikipedia.org/wiki/Th%C3%A9venin%27s_theorem)
