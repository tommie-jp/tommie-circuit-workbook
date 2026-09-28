---
book: nanovna
chapter: 5
id: 5-9
title: コネクタの不連続 (TDR)
tier: 100
source: 自作
board: —
device: H4
---

# 5-9 コネクタの不連続 (TDR)

ケーブルの途中の継ぎ目 (変換アダプタ・中継コネクタ) は、完全な 50 Ω の
線路ではない。中心導体が細くなる所や、締め付けが甘い所は小さな
**直列インダクタンス**に見え、そこで少しだけ反射が起きる。1 m のケーブル
2 本を中継で継ぎ、先を 50 Ω で終端して、**継ぎ目だけ**が TDR に山として
出ることを確かめる。5-4 の断線・短絡より 1 桁小さい山を読む練習でもある。

## 回路図

```circuit
title: 図1 1 m + 継ぎ目 + 1 m、先は 50 Ω の Load (継ぎ目は等価回路)
parts:
  J1: sma b2 mirror CH0
  TL1: tline b3 b5 50 l=$\mathrm{TL}_1$
  L1: inductor b6 b8 5n
  TL2: tline b9 b11 50 l=$\mathrm{TL}_2$
  R1: resistor b12 d12 50
  G1: ground c2
  G2: ground d12
wires:
  - J1.1 -- b3
  - b5 -- b6
  - b8 -- b9
  - b11 -- b12
  - J1.2 -- c2
notes:
  - text b4h5 center: 1 m
  - text b10h5 center: 1 m
  - text b7h5 center: 継ぎ目
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/09-connector-discontinuity.svg)

- TL1・TL2 は 5-2 と同じ vf 0.66 のケーブル。R1 は校正キットの Load (50 Ω) を
  先に挿す
- L1 は継ぎ目の**等価回路**。ここでは SMA-BNC 変換 2 個で BNC の中継を挟んだ
  継ぎ目が 5 nH の直列インダクタンスに見える、と**仮定**する (実物の値は品物と
  締め方で変わる。測って読むのがこの題)。5 nH は安い変換を重ねた**悪いほうの目安**
  で、900 MHz の SWR は 1.75 になる。質のよい変換なら 900 MHz で SWR 1.2 (1.6 nH
  相当) ほどに収まり、山も 1/3 ほどになる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜900 MHz (5-1・5-4 と同じ) |
| 点数 | 401 (TDR には等間隔の掃引が要る) |
| 校正 | SOLT。TL1 の根元 (CH0 の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の TDR (速度係数 0.66) と Log Mag |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 1M-900M 401
title: 図2 継ぎ目だけが 1 m に小さな山。50 Ω で終えた先端 (2 m) は平ら
dut:
  - line 50 1m vf 0.66
  - series L 5n
  - line 50 1m vf 0.66
  - series R 50
  - short
traces:
  - S11 tdr vf 0.66
  - S11 logmag
markers:
  - 100M
  - 450M
  - 900M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/09-connector-discontinuity-1.svg)

比べるために、R1 を外して先端を**開放**にする (全反射の山を並べて、大きさの
物差しにする)。掃引は図2 と同じ。Log Mag は全反射で 0 dB に張り付くだけなので省いた。

```vna
device: h4
sweep: 1M-900M 401
title: 図3 先端を開放 — 2 m の全反射の山と比べると、継ぎ目の山は小さい
dut:
  - line 50 1m vf 0.66
  - series L 5n
  - line 50 1m vf 0.66
  - open
traces:
  - S11 tdr vf 0.66
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/09-connector-discontinuity-2.svg)

## 見るべき値

計算値。直列の L が 50 Ω の線路の途中にあると、反射係数は
**Γ = jωL / (100 + jωL)** (両側が 50 Ω)。周波数が高いほど ωL が大きくなり、
反射が増える。

| 項目 | 値 |
| --- | --- |
| 図2 の TDR の山 | **0.989 m** (継ぎ目の位置。高さ 0.14 ほど) |
| 図2 の 2 m (50 Ω の先端) | 山なし (反射が無い) |
| 図2 の S11 (100 MHz) | −30.06 dB (ωL = 3.1 Ω) |
| 図2 の S11 (450 MHz) | −17.08 dB (ωL = 14.1 Ω) |
| 図2 の S11 (900 MHz) | −11.31 dB (ωL = 28.3 Ω) |
| 図3 の一番高い山 | **2.020 m** (開放の先端。継ぎ目を通った先なので 2 m からわずかに遅れる) |
| 図3 の 1 m と 3 m の小山 | 継ぎ目の山 (図2 と同じ高さ) と、先端で返った波が継ぎ目でもう一度返って先端を往復した「こだま」 (1 m + 2 × 1 m = 3 m) |

分かること:

- **TDR は反射の場所ごとに山を分けて見せる**。S11 の Log Mag は「どこかで
  反射している」ことしか言わないが、TDR なら 1 m の継ぎ目が悪く、先端の
  終端はよいと分かる
- 継ぎ目の山は、開放の先端 (全反射) の**1/7 ほど**の高さ。見落とさないよう、
  先に図3 のように開放の山で目盛の大きさを覚えておくとよい
- 先端が大きく反射していると、**何も無い 3 m にも山 (こだま) が立つ**。
  ケーブルが 2 m しか無いのに山がある、と慌てない。先を終端すれば消える
- インダクタンスの反射は周波数とともに増える (900 MHz で −11 dB)。**H4 の
  上のほう (数百 MHz) で使うケーブルほど、継ぎ目の数を減らす**。変換アダプタを
  何段も重ねるのは、低い周波数では気にならなくても GHz では効く (5-19 で扱う)
- 山の位置 0.989 m は、5-1 と同じ 401 点の離散化で 1 m からわずかにずれた値

## 出典

自作。
