---
book: denken
chapter: 4
id: 4-4
title: 平衡負荷の中性線 — 平衡なら中性線の電流は 0
tier: 50
source: 自作
board: BB
---

# 4-4 平衡負荷の中性線 — 平衡なら中性線の電流は 0

4-2 の Y 結線に**中性線**を足す。中性点 N を電源の GND に抵抗 1 本 (シャント) で
つなぎ、その両端の電圧から中性線の電流を求める。3 本の負荷が等しい (平衡) なら、
中性線に電流はほとんど流れない。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_N = I_A + I_B + I_C | 中性線の電流は、3 本の相電流の和 (キルヒホッフの電流則) |
| I_A + I_B + I_C = 0 (平衡時) | 平衡三相は瞬時値の和が常に 0 なので、電流の和も 0 |
| I_N ≈ 0 | したがって、平衡負荷なら中性線の電流はほぼ 0 |

## 回路図

```circuit
title: 図1 Y 結線に中性線を足す
parts:
  V1: sine a1 c1 1 l=$\mathrm{W1}$
  G1: ground c1
  R1: resistor a1 a4 10k
  V2: sine e1 g1 1 l=$\mathrm{W2}$
  G2: ground g1
  R2: resistor e1 e5 10k
  U1: opamp c9 +up TL071
  G3: ground c6
  Rf: resistor d11 d14 10k
  OUT: port c16
  R3: resistor b20 b23 1k
  R4: resistor f20 f23 1k
  R5: resistor c20 c23 1k
  RN: resistor c23 c27 10
  G4: ground c27
wires:
  - a4 |- U1.-
  - e5 |- U1.-
  - c6 |- U1.+
  - d11 |- U1.-
  - U1.out -- c14 -- c16
  - d14 -- c14
  - a1 -- b20
  - e1 -- f20
  - c16 -- c20
  - b23 -- c23
  - f23 -- c23
notes:
  - text c16 blue: 3 相目
  - text d24 blue: N
style:
  standard: jis
  grid: on
  pitch: 1.4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/04-neutral-wire.svg)

- RN (10 Ω) が中性線のシャント。中性点 N と GND (G4) の間に入れ、両端の電圧を
  読めば中性線の電流が分かる (4-2 では N を浮かせたまま、ここでは GND に落とす
  のが違い)
- 平衡なら N はもともと GND とほぼ同じ電圧 (4-2 の見るべき値) なので、
  RN を足しても回路の動きはほとんど変わらない

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上のブロック: TL071 の入力側と R1・R2、右に Y 結線と中性線 RN。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  R3: resistor b35 b39 1k
  R4: resistor b42 b46 1k
  R5: resistor b49 b53 1k
  RN: resistor d53 d57 10
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 2-, V-, W1, 2+, W2, 1+]
wires:
  - AD.V+ -- +t6 red
  - AD.GND -- -t8 black
  - AD.1- -- -t10 black
  - AD.2- -- -t12 black
  - AD.V- -- a13 purple
  - AD.W1 -- c17 yellow [h-10]
  - AD.2+ -- a17 yellow
  - AD.W2 -- b25 orange [h-10]
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j42 orange
  - h14 -- h49 blue
  - f35 -- e35 yellow
  - f42 -- e42 orange
  - f49 -- e49 blue
  - a28 -- a39 -- a46 -- a53 green
  - AD.1+ -- b28 pink
  - c57 -- -t57 black
notes:
  - text small: R3・R4・R5 が Y 結線。列 53 が中性点 N。RN が N と GND (−t レール) の間
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/04-neutral-wire.svg)

- 中性点 N (列 53) から RN (10 Ω) を通って 57 列 (c57) へ、そこから GND レール (−t、AD.GND と同じ) へつなぐ。
  N を GND に直結せず、必ず RN を挟むことで電流を電圧として読める
- Scope の CH1 は 1+ を N (a 行の緑の線で 28 列まで延ばした b28)、1- を GND レール
  (RN の GND 側とつながる) に当てて RN の両端を差動で読む。CH2 (2+) は 1 相目 (W1、17 列) につなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = RN の両端 (差動)、CH2 = 1 相目 (AD.W1、GND 基準) |
| Measure | CH1 の Amplitude (RMS でも可) |

平衡のままなら CH1 は 0 V の平らな線のまま動かない。下の画面は R3 (1 相目) だけを
2 kΩ に替えたときのもので、RN の両端に 4.88 mV (計算値) が 1 相目と逆向きに立つ。
CH1 は 2 mV/div、CH2 は 500 mV/div と V/div を分けてある。

```scope
title: 図3 R3 を 2 kΩ にすると RN (CH1) に 1 相目と逆向きの電圧が立つ
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 4.88mV phase 180deg, range: 2mV/div}
ch2: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/04-neutral-wire.svg)

### オシロスコープと発振器

RN の下の端は GND のレールなので、AD の 1− は GND で、測り方は GND 基準のままでよい。
発振器・電源の読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| 1+ / 1− | CH1 の先端を N (28 列か 53 列)、グランドクリップを GND のレール |
| 2+ / 2− | CH2 の先端を 1 相目 (17 列)、グランドクリップを GND のレール |

- RN の両端は数 mV しか立たない。CH1 は **×1 のプローブ** (か ×1 に切り替えたもの) で
  最も細かいレンジ (1〜2 mV/div) にする。×10 では 10 倍粗くなる
- 発振器とオシロの GND はどちらも大地につながっていて、GND の線が輪になる。
  mV の読みには商用周波数 (50/60 Hz) のノイズが乗りやすい。トリガを CH2 (1 相目) に
  して Average を掛けると、1 kHz に同期しないノイズは平均で減る
- FG の 50 Ω が 1・2 相目に入っても、3 相目の OP アンプが同じだけ下がった電圧を作る
  (4-2 の「オシロスコープと発振器」)。負荷は平衡のままで、RN の両端は 0 V のまま (計算値)。
  残るのは FG の 2 つの ch の振幅の差 (機種の確度で 1 % 前後) と TL071 のオフセットの分

## 見るべき値

計算値。オペアンプは理想として計算している。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RN の両端の電圧 | 0 V (計算値) | I_N = 0 A なので RN があっても電圧は立たない |
| R3・R4・R5 を 1 本だけ 2 kΩ に変えたときの RN の両端 | 0 でない値が出る | 不平衡になると中性線に電流が流れる (4-6 で詳しく測る) |

分かること:

- **平衡なら中性線は無くても Y 結線の動きは変わらない。** 4-2 (中性線なし) と
  4-4 (中性線あり、電流 0) の結果が同じになることがその証拠
- 実際には TL071 のオフセット電圧 (データシートで数 mV) が乗るので、RN の両端は
  ぴったり 0 ではなく数 mV 前後になる。これは負荷の不平衡ではなく計器・部品の
  誤差

## 出典

自作。
