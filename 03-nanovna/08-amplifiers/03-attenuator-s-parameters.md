---
book: nanovna
chapter: 8
id: 8-3
title: アッテネータの S パラメータ
tier: 50
source: 自作
board: PF
device: H4
---

# 8-3 アッテネータの S パラメータ

抵抗だけで作る π 型 10 dB アッテネータの S21 (減衰量) と S11 (整合) を測る。
アンプ (8-1・8-2) と違って**純粋な受動部品**なので、このフェンスの `dut:` で
そのまま正確に描ける。8-1 で出力の保護に使ったのと同じ設計。

## この実験で確かめる式

π 型アッテネータ (両端が同じ抵抗) の設計式。減衰量を電圧比 K = 10^(dB/20) とすると、

**R_shunt = 50 × (K+1)/(K−1)**、**R_series = 25 × (K²−1)/K**

10 dB (K = 3.162) での計算値: R_shunt = 96.2 Ω、R_series = 71.2 Ω。
E24 系列に丸めると **R_shunt = 100 Ω、R_series = 68 Ω**。

## 回路図

```circuit
title: 図1 パイ型 10 dB アッテネータ
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 d4 100
  R2: resistor b4 b6 68
  R3: resistor b6 d6 100
  J2: sma b8 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d6
  G4: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

- R1・R3 (100 Ω) が両端のシャント、R2 (68 Ω) が真ん中の直列。左右対称なので
  向きを問わず同じ減衰量になる

## 実体配線図

```perfboard
board:
  size: 16x8
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  R1: resistor e3 g3 100
  R2: resistor e5 e7 68
  R3: resistor e9 g9 100
  J2: sma/female-edge e16 f17
wires:
  - e1 -- e3
  - e3 -- e5
  - e7 -- e9
  - e9 -- e16
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- g3 black
  - h3 -- h9 black
  - h9 -- g9 black
  - h9 -- h15 black
  - f17 -- f15 black
  - f15 -- h15 black
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜1000 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag、S11 の Log Mag |

抵抗だけの回路なので周波数によらず一定になる**見えるはずの画面**。

```vna
device: h4
sweep: 1M-1000M 201
title: 図3 π 型 10 dB アッテネータの S21・S11 (E24 丸め後)
dut:
  - shunt R 100
  - series R 68
  - shunt R 100
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 500M
  - 1000M
```

- E24 丸め後の実際の減衰量は**9.63 dB** (設計 10 dB よりわずかに浅い)。
  S11 は −49.6 dB と非常によく整合している
- 抵抗だけの回路は理想的には周波数に依らず一定。実測ではリード線の
  インダクタンス (4-7 参照) の分だけ、GHz に近づくと減衰が増え整合が崩れる

## 見るべき値

計算値。左右どちらから測っても同じ値になる (対称回路なので S22 = S11、
S12 = S21。裏返して測り直す必要がない)。

| 周波数 | S21 | S11 |
| --- | --- | --- |
| 1 MHz | −9.63 dB | −49.6 dB |
| 500 MHz | −9.63 dB | −49.6 dB |
| 1000 MHz | −9.63 dB | −49.6 dB |

- 設計値 10 dB に対し実際は 9.63 dB。E24 系列 (100 Ω・68 Ω) に丸めた誤差
- 8-1 のアンプの出力に挟んだのはこのアッテネータと同じ設計。8-2 のように
  非対称な回路 (アンプ) だと S11 ≠ S22 になり、裏返して測り直す必要がある —
  この違いを比べておくと、次にどちらを測っているか迷わない

## 出典

自作。π 型アッテネータの設計式は標準的な RF 回路の教科書による。
