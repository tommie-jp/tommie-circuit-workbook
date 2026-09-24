---
book: analog-discovery
chapter: 8
id: 8-2
title: 隣の列との容量 (数 pF) を測る
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-2 隣の列との容量 (数 pF) を測る

8-1 でジャンパ 1 本は問題ないと分かった。次はブレッドボードの**構造そのもの**が
持つ寄生を測る。**何もつながず、ただ隣り合っているだけの 2 つの列**の間には、
金属レールが近接することで数 pF の容量ができる。6-1〜6-4 と同じ基準抵抗の
仕組みで、この小さな容量を測る。

## 回路図

```circuit
title: 図1 基準抵抗と列間の寄生容量
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 6.8k
  Cstray: capacitor c9 c12 2.5p l=$\mathrm{C_{stray}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- c14
  - AD.GND -| c14
```

- C<sub>stray</sub> は**部品ではない**。実装した部品ではなく、板の 2 つの列が
  近いことで生じる寄生容量を表す (実体配線図には現れない)
- Rref (6.8 kΩ) は 10 MHz での予想インピーダンス (約 6.4 kΩ) に合わせた値

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 6.8k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- -t3 black
  - AD.1+ -- b5 orange [h5]
  - AD.1- -- -t8 black
  - AD.2+ -- b10 purple [h5]
  - AD.2- -- -t13 black
  - h11 -- -t11 black
```

- Rref の先 (10 列) には**わざと何もつながない**。10 列と、GND に落とした
  隣の 11 列だけが、板の中で近接している
- 2+ (10 列) は Rref の先にしかつながっていない。ERC は「他につながっていない」
  と言うが、**これは承知のうえ** — 測りたいのはこの列が何にもつながっていない
  ときの、隣との寄生容量そのもの

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 MHz**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = 10 列 (浮いた側) の対 GND 電圧 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

低い周波数では Xc が大きすぎて CH2 がほぼ読めない (ノイズに埋もれる)。
**10 MHz まで上げてやっと測れる**のがこの寄生の小ささを物語る。

## 見るべき値

計算値。列間容量は 2.5 pF と仮定 (機種・列の間隔で変わるので実測で確かめる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Xc = 1/(2πfC) (10 MHz) | 6.37 kΩ | 予想リアクタンス |
| CH1 (Rref の両端) | 0.730 V | I ≈ 0.107 mA |
| CH2 (10 列の対 GND) | 0.683 V、位相 −90° 付近 | \|Z\| ≈ 6.4 kΩ → C ≈ 2.5 pF |
| 1 MHz に落としたときの CH2 | 大きく減る (読み取り困難) | Xc が 10 倍 (約 64 kΩ) になり、Rref との比が悪くなる |

**電流がとても小さい (0.1 mA 程度)。** Average の回数を増やす (16〜64 回) と
読みが安定する。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
