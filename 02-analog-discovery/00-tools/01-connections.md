---
book: analog-discovery
chapter: 0
id: 0-1
title: 接続と極性 — ワイヤの色、1+ / 1- の差動入力、GND を共通に
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 0-1 接続と極性 — ワイヤの色、1+ / 1- の差動入力、GND を共通に

Analog Discovery 3 (AD3) のオシロスコープ入力 (2×15 ヘッダの 1+ / 1- など) は**差動入力**で、
2 本の間の電圧差を読む。GND を基準にしたいときは、片方 (多くは `-` 側) を
GND につなぐ。ここでは同じ 2 点を、リード線の順を変えて読み、符号が
入れ替わることを確かめる。BNC アダプタを付けたときの入力は差動ではなく
シングルエンド (BNC の外側が GND) になる (Digilent の AD3 Specifications、Input Type の項)。

## 回路図

```circuit
title: 図1 同じ 2 点を極性を変えて読む
parts:
  V1: vsource a1 c1 5
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  M2: voltmeter c5 a5 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/01-connections.svg)

- V1 は電源ツールの V+ (GND に対して +5 V)
- M1 (CH1) は `1+` を V+、`1-` を GND につないだ**普通の向き**。+5.00 V を読む
- M2 (CH2) は `2+` を GND、`2-` を V+ につないだ**逆向き**。同じ 2 点なのに
  −5.00 V になる。差動入力は「どちらが + でどちらが − か」で符号が決まる

## 実体配線図

```breadboard
title: 図2 ワイヤの色と、極性を変えた 2 系統
# 赤 = V+ のレール、青 = GND のレール。ワイヤの色は挿さった先のレールに合わせる
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t5 red
  - AD.GND -- -t5 black
  - AD.1+ -- +t10 red
  - AD.1- -- -t10 black
  - AD.2+ -- -t15 black
  - AD.2- -- +t15 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/01-connections.svg)

- CH1 は色の約束どおり (`1+` が赤レール、`1-` が黒 = GND レール)
- CH2 は**色は約束どおりに挿してあるのに、+ / − の割り当てが逆** —
  `2+` は GND レール (黒)、`2-` は V+ レール (赤) に挿す。ワイヤの色は
  「どのレールに挿したか」を示すだけで、+ / − の意味を保証しない
- 両方とも GND (黒レール) につながっている。GND を共通にしないと、
  電圧の基準が定まらず値が暴れる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V にして Enable、Master Enable を入れる |
| Voltmeter | CH1・CH2 とも DC |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 | +5.00 V 前後 | GND 基準の普通の読み方 |
| CH2 | −5.00 V 前後 | 同じ 2 点でも `+` / `-` を入れ替えると符号が反転する |
| CH1 と CH2 の絶対値 | 同じ (5.00 V) | 差動入力は「差」を読むので、大きさは変わらず符号だけ変わる |

V+ の設定を 0〜5 V で動かしたときの 2 つの読みを並べると、2 本は 0 V を軸に
鏡映しになる。

```graph
title: 図3 CH2 の読みはいつも CH1 の符号を反転した値 — 5 V で +5.00 V と −5.00 V
x: V+ の設定 V 0..5
y: 読み値 V -6..6
lines:
  CH1 (普通の向き) V: x
  CH2 (逆向き) V: -x
notes:
  - mark 5
  - level 0V
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/graph/01-connections.svg)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Voltmeter の節)。
