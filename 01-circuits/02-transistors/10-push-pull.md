---
book: circuits
chapter: 2
id: 2-10
title: プッシュプル (B 級) とクロスオーバー歪
tier: 100
board: BB
source: 自作
---

# 2-10 プッシュプル (B 級) とクロスオーバー歪

PNP 形のトランジスタは、NPN 形 (2-1) と電圧・電流の向きが逆のもので、ベースをエミッタより
約 0.7V **低く**すると導通する。NPN と PNP を上下に積み、ベースを共通の入力に、エミッタを
共通の出力につなぐと、**入力が + のときは NPN が、− のときは PNP が**交代で電流を流す。
2 つが押したり (push) 引いたり (pull) するのでプッシュプルと呼び、それぞれが半周期だけ働く
使い方を B 級と呼ぶ。スピーカーなどの重い負荷を、両方向に電流を流して動かす出力段の基本形。

ベースに直流の電圧 (バイアス) を足さない素の B 級では、入力が 0V を横切る (ゼロクロスの)
付近の ±0.7V で、どちらのトランジスタも導通しない**すき間**ができる。そこで出力の波が
平らに欠ける。これが**クロスオーバー歪** (歪は、出力の波の形が入力と変わること)。
この題では正弦波を入れて、オシロで欠けを見る。

## 回路図

```circuit
title: 図1 B 級プッシュプル (W1 で入れ、CH2 で入力・CH1 で出力を見る)
parts:
  VCC: vcc b6 5V
  VEE: vee h6 5V
  W1: sine e2 g2 l=$\mathrm{W1}$
  G0: ground g2
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  G2: ground g4
  Q1: npn d6
  Q2: pnp f6
  RL: resistor e8 g8 100
  G1: ground g8
  M1: voltmeter e10 g10 l=$\mathrm{CH1}$
  G3: ground g10
wires:
  - b6 -- Q1.C
  - h6 -- Q2.C
  - e2 -- e4 -- e5
  - e5 |- Q1.B
  - e5 |- Q2.B
  - Q1.E -- e6 -- Q2.E
  - e6 -- e8 -- e10
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/10-push-pull.svg)

図1 の +5V と −5V は Analog Discovery の V+ と V− (WaveForms の Supplies で ±5 V にする)。
`Q1` のコレクタを +5V、`Q2` のコレクタを −5V につなぐ。
`Q1`・`Q2` のベースは共通の入力 (W1 と CH2)、エミッタは共通の出力 (`RL` の上端、CH1)。

- 入力が **+3V** のとき: `Q1` (NPN) が導通し、出力 = 3 − 0.7 = **+2.3 V**
  (`RL` = 100Ω の電流 = 23mA)
- 入力が **−3V** のとき: `Q2` (PNP) が導通し、出力 = −3 + 0.7 = **−2.3 V**
  (電流の向きが逆)
- 入力が **−0.7V 〜 +0.7V** の間: `Q1` も `Q2` も導通せず (どちらも
  |V<sub>BE</sub>| が 0.7V に届かない)、出力は **0V に張り付く**
  (計算値) — 入力の波形が正弦波なら、ゼロクロス付近だけ出力が平らに
  なる**クロスオーバー歪**

入力の振幅を大きくしても、ゼロクロス付近の「幅 約1.4V (±0.7V)」の
すき間は変わらないので、**振幅が小さい信号ほど歪の割合が目立つ**。

## 実体配線図

```breadboard
title: 図2 B 級プッシュプル (W1 と CH2 を入力へ、CH1 を出力へ)
# +5V は上の + レール、GND は上の − レール、−5V は下の − レール
board: half
parts:
  Q1: transistor c10(B) c11(C) c12(E) 2SC1815
  Q2: transistor h10(B) h11(C) h12(E) 2SA1015
  RL: resistor a12 -t12 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, V+, GND, 2-, 2+, W1, 1+, 1-]
wires:
  - AD.V- -- -b1 purple
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - AD.2- -- -t5 black
  - AD.2+ -- a7 blue
  - AD.W1 -- a8 yellow
  - AD.1+ -- a15 orange
  - AD.1- -- -t16 black
  - e7 -- e8 blue
  - b8 -- b10 yellow
  - +t11 -- a11 red
  - e10 -- f10 yellow
  - e12 -- f12 orange
  - b12 -- b15 orange
  - j11 -- -b11 purple
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/10-push-pull.svg)

図2 では、`Q1` (NPN) は上半分、`Q2` (PNP) は下半分に挿し、ベースどうし (列 10) と
エミッタどうし (列 12) を溝をまたぐ短い線でつなぐ。2SC1815 も 2SA1015 も平らな面を見て
左から E・C・B なので、2 本とも平らな面を奥に向けて (180 度回して) 挿し、左から B・C・E にする。

- **電源**: AD の V+ (赤) を上の + レール (+5V)、GND (黒) を上の − レール、
  V− (紫) を下の − レール (−5V) へ。下のレールは −5V 専用で GND ではない
- **Q1 のコレクタ (上の列 11)**: 赤線で +5V レールへ
- **Q2 のコレクタ (下の列 11)**: 紫線で下の −5V レールへ
- **入力 (列 10)**: W1 (黄) を `a8` に挿し `b8`–`b10` でベースへ。CH2 の 2+ (青) は
  `a7` に挿して `e7`–`e8` で渡す
- **出力 (列 12)**: `RL` は上の − レール (GND) へ縦に挿す。CH1 の 1+ (橙) は
  `a15` に挿して `b12`–`b15` で渡す
- AD の 2−・1− (黒) は上の − レール (GND) へ

## オシロで見る

W1 を 100 Hz・6 Vpp (±3V) の正弦波にし、CH2 (入力) と CH1 (出力) を同じ 1 V/div で重ねる。

```scope
title: 図3 入力 (CH2) と出力 (CH1) — ゼロクロス付近で出力が 0V に張り付く
time: 2ms/div
trigger: ch2 rising 0V
ch2: {wave: sine 100Hz 6Vpp, range: 1V/div}
ch1: {wave: "= 3V * sin(2 * pi * 100Hz * t) - clip(3V * sin(2 * pi * 100Hz * t), -0.7V, 0.7V)", range: 1V/div}
measure: [vpp, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/10-push-pull-1.svg)

図3 の CH1 の山は +2.3 V、谷は −2.3 V (4.6 Vpp) で、入力 (6 Vpp) より上下とも 0.7 V ずつ低い。
入力が ±0.7V の間にいる間は CH1 が 0V で平らになる — これがクロスオーバー歪。

W1 を 2 Vpp (±1V) に下げると、すき間の幅は変わらないので歪の割合が大きくなる (図4)。

```scope
title: 図4 振幅を 2 Vpp に下げる — 出力は ±0.3 V の山だけが残る
time: 2ms/div
trigger: ch2 rising 0V
ch2: {wave: sine 100Hz 2Vpp, range: 500mV/div}
ch1: {wave: "= 1V * sin(2 * pi * 100Hz * t) - clip(1V * sin(2 * pi * 100Hz * t), -0.7V, 0.7V)", range: 500mV/div}
measure: [vpp, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/10-push-pull-2.svg)

CH1 は 0.6 Vpp (山 +0.3 V・谷 −0.3 V) しか出ず、1 周期の半分近くが 0V に張り付く。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 |
| Q2 | PNP トランジスタ | 2SA1015 |
| RL | 抵抗 (1/4 W、スピーカーの代わり) | 100 Ω |
| — | 電源 | Analog Discovery の V+ (+5 V) と V− (−5 V) |

## 見るべき値

W1 で正弦波 (6 Vpp = ±3V、100Hz) を入れ、CH2 (入力) と CH1 (出力) を重ねて見る (図3)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 入力 +3V のときの出力 (CH1 の山) | 約 +2.3 V | Q1 が導通。出力は入力より 0.7V 低い |
| 入力 −3V のときの出力 (CH1 の谷) | 約 −2.3 V | Q2 が導通。出力は入力より 0.7V 高い (絶対値は同じだけ低い) |
| CH1 の振幅 (入力 6 Vpp) | 約 4.6 Vpp | 上下とも 0.7V ずつ削られる |
| 入力が −0.7〜+0.7V の間の出力 | 0 V に張り付く | クロスオーバー歪そのもの |
| 出力波形をオシロで見た形 | ゼロクロス付近が平らな正弦波 | 歪が目で見える。RL を流れる電流も同じ形に歪む |
| 入力 2 Vpp のときの CH1 (図4) | 約 0.6 Vpp (±0.3 V) | 振幅が小さいほど歪の割合が大きい |

## 出典

自作。
