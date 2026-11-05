---
book: analog-discovery
chapter: 9
id: 9-7
title: hFE の実測
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 9-7 hFE の実測

トランジスタの直流電流増幅率 hFE = I<sub>c</sub> / I<sub>b</sub> を、AD3 の **Scope の差動入力**で測る。
ベース抵抗 Rb とコレクタ抵抗 Rc の両端の電圧を 2 ch で同時に読み、Ohm (オーム) の法則で電流に直す。
W1 を三角波でゆっくり振れば、I<sub>b</sub> を 3〜43 µA (マイクロアンペア) まで動かしたときの hFE が 1 回で取れる。
9-6 の Ic–Vce 曲線が「平らな所の高さ」で hFE を見せたのに対し、ここでは比そのものを Math で画面に出す。

もう 1 つの狙いは、**計器の入力抵抗が測る電流に混ざる**ことを数で確かめること。
AD3 の Scope の入力は各ピンが GND に対して約 1 MΩ で、ベースに当てた 1− から約 0.65 µA が逃げる。
I<sub>b</sub> が数 µA の所では、これが 2 割近い誤差になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Rb と Rc の電圧から Ib と Ic を測る
parts:
  AD:
    type: device
    at: 1,2
    label: Analog Discovery
    pins: [2+, V+, 2-, 1-, 1+, W1, GND]
  Rc: resistor 15,3.25 15,4.5 220
  Rb: resistor 7,5.5 10,5.5 100k
  Q1: npn 13,5.5 2SC1815
  G1: ground 14,7
  G2: ground 4,7
wires:
  - AD.2+ -| 16,3.25
  - 16,3.25 -- 15,3.25
  - AD.V+ -| 15,3.25
  - AD.2- -| 14,4.5
  - 14,4.5 -- 15,4.5
  - Q1.C -| 15,4.5
  - AD.1- -| 11,5.5
  - 10,5.5 -- 11,5.5
  - 11,5.5 -- Q1.B
  - AD.1+ -| 7,5.5
  - AD.W1 -| 6,5.5
  - 6,5.5 -- 7,5.5
  - Q1.E -| 14,7
  - AD.GND -| 4,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/07-hfe.svg)

- W1 → Rb (100 kΩ) → ベース。CH1 (1+・1−) は Rb の両端に差動で当て、V<sub>Rb</sub> = I<sub>b</sub> × 100 kΩ を読む
- V+ (5 V) → Rc (220 Ω) → コレクタ。CH2 (2+・2−) は Rc の両端で、V<sub>Rc</sub> = I<sub>c</sub> × 220 Ω
- エミッタは GND。hFE = (V<sub>Rc</sub> / 220 Ω) / (V<sub>Rb</sub> / 100 kΩ) = 454.5 × V<sub>Rc</sub> / V<sub>Rb</sub>

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rb: resistor c14 c20 100k
  Rc: resistor d26 d21 220
  Q1: transistor g20(B) g21(C) g22(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t8 red
  - AD.GND -- -t9 black
  - AD.W1 -- a14 yellow [h-10]
  - AD.1+ -- b14 orange [h10]
  - AD.1- -- a20 white
  - AD.2- -- a21 purple
  - AD.2+ -- +t24 gray
  - a26 -- +t26 red
  - e20 -- f20 orange
  - e21 -- f21 purple
  - j22 -- -b22 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/07-hfe.svg)

- Q1 の実際のピンの並びは平らな面を見て E・C・B。図のとおり左から B・C・E (g20〜g22) に挿すには平らな面を奥 (a〜e 側) に向ける (9-1 と同じ)
- Rb (c14〜c20) と Rc (d21〜d26) は上ブロックに置き、ベース (20 列)・コレクタ (21 列) を溝越しの短い線で Q1 へ渡す
- CH1 は W1 と同じ 14 列 (1+) と、ベースの 20 列 (1−、白) に挿す。CH2 の 2+ (灰) は + レール、2− (紫) はコレクタの 21 列
- 上下の − レールは 28 列で渡す。エミッタは `j22 -- -b22` で下の − レールへ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Triangle、10 Hz、Offset 3 V、Amplitude 2 V (1〜5 V を往復) |
| Scope | CH1・CH2 とも 1 MΩ の入力のまま。CH1 1 V/div、CH2 500 mV/div、20 ms/div。Trigger は CH1 の立ち上がり |
| Scope の Math | `C2 / C1 * 454.5` (見かけの hFE)。Math の式の書き方は WaveForms の版で違うので、式の欄の例に合わせる (目安) |

W1 を 1 V から始めるのは、V<sub>Rb</sub> が 0 V に近いと Math の割り算が暴れるため (0 で割る)。
10 Hz はトランジスタの温度がほぼ変わらない速さで、ベースの電流 3〜43 µA を 1 画面で掃く。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH2 は CH1 にほぼ比例する。Math (見かけの hFE) は Ib の小さい所で下がる (計算)
time: 20ms/div
trigger: ch1 rising 2.35V
ch1: {wave: triangle 10Hz 2V offset 2.35V, range: 1V/div, position: -2.35div}
ch2: {wave: ch1 | gain 0.44 | offset -28.6mV, range: 500mV/div, position: -2div}
math: {expr: ch2 / ch1 * 454.5, unit: 1, range: 10/div, position: -18div}
measure: [vmax, vmin, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/07-hfe.svg)

図3 は、V<sub>BE</sub> を 0.65 V で一定、真の hFE を 200 と置いた計算値。CH1 は 0.35〜4.35 V の三角波、
CH2 は 0.13〜1.89 V。Math は真の 200 ではなく 163〜197 に出る。差は、ベースから 1− の 1 MΩ へ逃げる
0.65 µA が、Rb を流れる電流には含まれるがベースには入らないために生まれる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Rb | 抵抗 (1/4 W) | 100 kΩ (I<sub>b</sub> を決め、電流を電圧に直す) |
| Rc | 抵抗 (1/4 W) | 220 Ω (I<sub>c</sub> を電圧に直す。最大 8.6 mA で 16 mW) |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V)。最大 8.6 mA で 43 mW |

## 見るべき値

計算値。V<sub>BE</sub> = 0.65 V、真の hFE = 200、Scope の入力抵抗 1 MΩ と仮定。

| W1 | V<sub>Rb</sub> (CH1) | 見かけの I<sub>b</sub> = V<sub>Rb</sub> / Rb | 真の I<sub>b</sub> (0.65 µA を引く) | I<sub>c</sub> | V<sub>Rc</sub> (CH2) | 見かけの hFE (Math) |
| --- | --- | --- | --- | --- | --- | --- |
| 1 V | 0.35 V | 3.50 µA | 2.85 µA | 0.57 mA | 0.13 V | 163 |
| 3 V | 2.35 V | 23.5 µA | 22.9 µA | 4.57 mA | 1.01 V | 194 |
| 5 V | 4.35 V | 43.5 µA | 42.9 µA | 8.57 mA | 1.89 V | 197 |

- **真の hFE を出すには、1− の漏れを足し戻す**: I<sub>b</sub> = V<sub>Rb</sub> / Rb − V<sub>B</sub> / 1 MΩ。V<sub>B</sub> (ベースの電圧) は
  W1 の電圧から CH1 を引けば分かる。Math を `C2 / (C1 - 0.065) * 454.5` にすると (0.065 V = 0.65 µA × 100 kΩ)、
  画面の線はほぼ 200 で平らになる
- 2− (コレクタ) からも V<sub>c</sub> / 1 MΩ ≈ 3 µA が逃げるが、I<sub>c</sub> の 0.6〜9 mA に比べて 0.5 % 以下で効かない
- 2SC1815 は hFE で O (70〜140)・Y (120〜240)・GR (200〜400)・BL (350〜700) に分けて売られる (目安。メーカーの資料の分類)。
  買った袋のランクと測った値を比べる。GR でも 400 の個体なら V<sub>Rc</sub> は 3.8 V まで上がり、V<sub>ce</sub> は 1.2 V で
  まだ飽和しない (Rc を 220 Ω にした理由)
- 実物では、I<sub>c</sub> が 0.1 mA より小さい所と 50 mA を超える所で hFE が下がる。この題の範囲 (0.6〜9 mA) は平らな所に当たる

## LTspice での確かめ

`sim/07-hfe.cir` で図1 を直流で解いた (W1 を 1〜5 V に掃引、ベースに 1− の 1 MΩ を付けた)。
Q1 は 9-6 と同じ 2SC1815 の模型 (BF 200、VAF 100 V、IKF 0.15 A)。**仮定で、実測の値ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| V<sub>Rb</sub> (W1 = 1・3 V 付近・5 V) | 0.35・2.35・4.35 V | 0.374 V (1 V)・1.34 V (2 V)・4.30 V (5 V) | 合う (模型の V<sub>BE</sub> は 0.63〜0.70 V) |
| I<sub>c</sub> (W1 = 1・5 V) | 0.57・8.57 mA | 0.647・8.22 mA | 合う |
| 見かけの hFE (W1 = 1 V) | 163 | 173 | 1 MΩ の漏れで真の値より低く出るのは同じ |
| 見かけの hFE (W1 = 5 V) | 197 | 191 | 合う |
| 真の hFE (I<sub>c</sub>/I<sub>b</sub>、1 V・2 V・5 V) | 200 | 207・204・194 | 合う (低い所はアーリー効果で上、8 mA では IKF で下がる) |
| W1 = 5 V の V<sub>ce</sub> | 3.1 V (5 V − 1.89 V) | 3.19 V | 合う。飽和していない |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
参考: [バイポーラトランジスタ](https://ja.wikipedia.org/wiki/バイポーラトランジスタ)
