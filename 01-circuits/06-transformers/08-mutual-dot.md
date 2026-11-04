---
book: circuits
chapter: 6
id: 6-8
title: 相互誘導と極性 (ドット)
tier: 200
source: 自作
---

# 6-8 相互誘導と極性 (ドット)

同じコアに巻いた 2 つの巻線は、片方の電流が作る磁束がもう片方も貫くので、片方の電流を変えるともう片方に電圧が出る (**相互誘導**)。
その強さを表すのが**相互インダクタンス M** で、2 つの自己インダクタンス L1・L2 と結合係数 k (0〜1) で M = k√(L1 L2)。

もう 1 つ大事なのが**向き**。2 次に出る電圧が 1 次と同じ向きか逆向きかは、巻線の巻き始めがどちらか (巻く向き) で決まる。
回路図では巻き始めに点 (ドット、●) を打つ約束があり、**点のある端どうしは同じ向きに電圧が出る**。6-6 のフライバックや 6-4 のセンタータップ、
6-9 の電流トランスは、どれもこの向きを取り違えると動きが変わる。この題では、自分で巻いた 2 つの巻線で、

1. 点 (巻き始め) をそろえて測ると 2 つの電圧が**同じ向き**、片方を逆に当てると**逆向き** (180°) になること
2. 2 つを直列につなぐと、向きをそろえたとき (和動) は L1 + L2 + 2M、逆にしたとき (差動) は L1 + L2 − 2M になり、**同じ部品で 36 倍も違う**こと

を確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2 つの巻線の極性を見る (A1・B1 が巻き始め、B は開放)
parts:
  W1: sine 2,2 2,4 l=$\mathrm{W1}$
  G1: ground 2,4
  RA: resistor 2,2 4,2 220
  T1: transformer 6,3 20t-20t
  G2: ground 4.5,4.5
  G3: ground 7.5,4.5
  M1: voltmeter 4,2.5 4,4.5 l=$\mathrm{CH1}$
  G4: ground 4,4.5
  M2: voltmeter 9,2.5 9,4.5 l=$\mathrm{CH2}$
  G5: ground 9,4.5
wires:
  - 4,2 -- 4,2.5
  - 4,2 -- 5,2
  - 5,2 |- T1.A1
  - T1.A2 -| 4.5,4.5
  - T1.B1 -| 7.5,2
  - 7.5,2 -- 9,2
  - 9,2 -- 9,2.5
  - T1.B2 -| 7.5,4.5
notes:
  - text 5.75,2.75 small red right: 巻き始め (A1)
  - text 7.6,2.75 small red center: 巻き始め (B1)
style:
  grid: on
  pitch: 1.6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/circuit/08-mutual-dot.svg)

- 図1 の T1 は FT37-43 に A と B の 2 つの巻線を 20 回ずつ、**同じ向きに**巻いたもの。巻き始めを A1・B1 とする (図の「巻き始め」の印がドットの位置)。
  回路図の記号には点が描けないので、字で示した
- W1 (20 kHz、振幅 1 V) を RA (220 Ω。Ω はオーム) を通して A に入れる。RA は W1 の電流を 5 mA 以下に抑える (AD3 の Wavegen は 10 mA ほどまで)
- CH1 は A の両端 (A1 側が +)、CH2 は B の両端 (B1 側が +)。B には何もつながない (開放)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (T1 は FT37-43 に 20 回ずつ 2 つの巻線)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 (W1 と Scope)
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  RA: resistor c5 c10 220
  T1: transformer/toroid b10(A1) b13(A2) b18(B1) b21(B2) FT37-43 20t:20t
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- -t7 black
  - a13 -- -t13 black
  - a21 -- -t21 black
  - AD.1+ -- a10 orange
  - AD.1- -- -t11 black
  - AD.2+ -- a18 green
  - AD.2- -- -t19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/breadboard/08-mutual-dot.svg)

図2 は T1 の 4 本のピン (手巻きの線の端) を `b10` (A1)・`b13` (A2)・`b18` (B1)・`b21` (B2) に挿した。

- **巻き始めに印を付けておく** (被覆の端に油性ペンで色を付ける、など)。巻き終わってからは、どちらが巻き始めか見分けられない
- W1 (黄) は `a5`、RA (`c5`–`c10`) で A1 の列 (10 列) へ。A2 (13 列) と B2 (21 列) は上の − レール (GND) へ
- Scope の 1+ (橙) は A1 の列 (`a10`)、2+ (緑) は B1 の列 (`a18`)。1− と 2− は − レールへ。AD3 の GND も − レールへ (電源の Supplies は使わない)
- **和動・差動の直列にするとき**: B2 を GND から外し、A2 と B1 を線でつなぎ (和動)、B2 を GND に。差動は A2 と B2 をつなぎ、B1 を GND に。
  CH1 は A1 の列のまま (直列の 2 つの巻線の両端を見る)

## 計器の設定

オシロには AD3 の Scope を使う。20 kHz の正弦波の振幅と、2 つの波の向き (位相) を比べる題で、10 MHz よりずっと低いから。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、20 kHz、振幅 1 V、オフセット 0 V |
| Scope CH1 (A1、10 列) | DC、50 mV/div、0 V を中央から 2 目盛上に |
| Scope CH2 (B1、18 列) | DC、50 mV/div、0 V を中央から 2 目盛下に |
| Time | 20 µs/div (µ はマイクロ。200 µs に 4 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 A (CH1) と B (CH2) — 巻き始めをそろえると同じ向き、B の振幅は 0.95 倍
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 20kHz 159mVpp, range: 50mV/div, position: 2div}
ch2: {wave: sine 20kHz 151mVpp, range: 50mV/div, position: -2div}
cursors: [12.5us, 62.5us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/scope/08-mutual-dot.svg)

図3 は LTspice の値で描いた想定の波形で、実測ではない。CH1 と CH2 は同じ尺度で、重ならないよう 0 V の位置だけを上下にずらした。2 つは同じ時刻に山になる (位相 0°)。CH2 の 2+ と 2− を入れ替える (B2 側を + にする) と、
CH2 は上下が逆になり、位相が 180° になる。B の振幅が A の 0.95 倍なのは、20 回ずつなので巻数比は 1 で、結合係数 k (0.95 と仮定) の分だけ小さいから。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | 自作トランス (FT37-43 に手巻き) | A・B とも 20 回 (それぞれ約 140 µH。A<sub>L</sub> 350 nH/回² の目安)。同じ向きに巻き、巻き始めに印 |
| RA | 抵抗 | 220 Ω |
| — | 信号源・計器 | AD3 の Wavegen W1、Scope 1+/2+ |

## 見るべき値

20 kHz で 140 µH のリアクタンスは 2π × 20 kHz × 140 µH ≈ 17.6 Ω (π はパイ)。RA (220 Ω) とで分圧するので、A の両端は 1 V の 8 % ほどになる。

| 測る所 | 期待する値 (LTspice) | 分かること |
| --- | --- | --- |
| A の両端 (CH1) | 約 159 mVpp | RA と A のリアクタンスの分圧 |
| B の両端 (CH2、巻き始めをそろえて) | 約 151 mVpp、CH1 と同じ向き (0°) | 相互誘導。比 0.95 が結合係数 |
| B を逆に当てたとき (2+ と 2− を入れ替え) | 約 151 mVpp、CH1 と逆向き (180°) | 点の約束: 点のある端どうしが同じ向き |
| 和動の直列 (A2–B1) の両端 (CH1) | 約 595 mVpp | L = L1 + L2 + 2M ≈ 546 µH (1 つの約 3.9 倍) |
| 差動の直列 (A2–B2) の両端 (CH1) | 約 16 mVpp | L = L1 + L2 − 2M ≈ 14 µH。磁束が打ち消し合う |
| 和動と差動の比 | 約 36 倍 | 同じ 2 つの巻線で、向きだけで変わる |

和動と差動の両端の電圧から 2 つの L (L<sub>和</sub>・L<sub>差</sub>) を出すと、M = (L<sub>和</sub> − L<sub>差</sub>) / 4 で相互インダクタンスが分かる (この題では約 133 µH、k = 133 / 140 = 0.95)。
L は、両端の電圧 V と RA の両端の電圧から、電流 I = V<sub>RA</sub> / 220 Ω、L = V / (2π f I) で出す。
k は手巻きのしかたで変わり、2 つの巻線を重ねて (同じ所に) 巻くほど 1 に近づく。

## LTspice での確かめ

`sim/08-mutual-dot.cir` で、B 開放・和動・差動の 3 つの接続を同じデッキに並べて過渡解析を走らせ、両端の電圧と向きを読んだ。
L は A<sub>L</sub> の目安から、結合係数 0.95・巻線の抵抗 0.2 Ω は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| A の両端 | 約 159 mVpp (計算 159 mVpp) | 159.3 mVpp | 合う |
| B の両端 (開放) | 約 151 mVpp (A の 0.95 倍) | 151.3 mVpp | 合う |
| A と B の向き | 同じ (0°) | 0 を横切る時刻の差 0.09 µs (0.6°) | 合う |
| 和動の両端 | 約 595 mVpp (計算 594.5 mVpp) | 594.5 mVpp | 合う |
| 差動の両端 | 約 16 mVpp (計算 16.4 mVpp) | 16.4 mVpp | 合う |
| W1 の電流の山 (和動 / 差動) | 5 mA 以下 | 4.3 / 4.5 mA (8.7 / 9.1 mApp) | 合う |

## 出典

自作。

参考: [相互誘導 (Wikipedia)](https://ja.wikipedia.org/wiki/相互誘導)、[Inductance (Wikipedia)](https://en.wikipedia.org/wiki/Inductance) (Mutual inductance の節)
