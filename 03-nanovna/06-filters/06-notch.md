---
book: nanovna
chapter: 6
id: 6-6
title: ノッチ
tier: 50
source: 自作
board: PF
device: H4
---

# 6-6 ノッチ

信号が通る道はそのままにして、**特定の 1 点だけ**を強く落とすのがノッチ (帯除去)。
直列共振の LC を**シャント**に 1 個入れるだけで作れる — 共振周波数でその枝の
インピーダンスがほぼ 0 になり、信号を地に逃がす。ここは FM 放送帯の代表として
98 MHz を狙う。

## この実験で確かめる式

直列 LC が共振する周波数は **f₀ = 1 / (2π√(LC))**。
L = 47 nH、C = 56 pF なら f₀ = 1 / (2π√(47n × 56p)) ≈ **98.1 MHz**
(どちらも E24 系列の実在の値)。

ノッチの深さはコイルの Q で決まる。Q = 50 のコイルの共振点での ESR は
**ESR = 2π f₀ L / Q ≈ 0.58 Ω**。

## 回路図

```circuit
title: 図1 直列共振をシャントに入れたノッチ
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 d4 47n
  C1: capacitor d4 f4 56p
  J2: sma b6 CH1
  G1: ground c2
  G2: ground f4
  G3: ground c6
wires:
  - J1.1 -- b4 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c6
```

- J1 と J2 の間は直結 (スルー)。L1・C1 の直列共振枝が b4 から地へ落ちているだけ

## 実体配線図

```perfboard
board:
  size: 16x12
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  L1: inductor e8 g8 47n
  C1: capacitor h8 j8 56p
  J2: sma/female-edge e16 f17
wires:
  - e1 -- e8
  - e8 -- e16
  - g8 -- h8
  - j8 -- l8
  - f0 -- f2 black
  - f2 -- l2 black
  - f17 -- f14 black
  - f14 -- l14 black
  - l2 -- l8 black
  - l8 -- l14 black
```

- L1・C1 は e (信号) 行から下へ 2 段ずつ (g・h・j 行) 伸ばし、l 行の GND バスへ落とす

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜200 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag |

コイルの Q = 50 (ESR 0.58 Ω) を入れた**見えるはずの画面**。

```vna
device: h4
sweep: 1M-200M 201
title: 図3 98 MHz ノッチの S21 (コイル Q 50)
dut:
  - shunt C 56p esl 47n esr 0.58
traces:
  - S21 logmag
markers:
  - 88M
  - 98.1M
  - 108M
```

- ノッチの底は約 **−32.9 dB** (98.1 MHz)。FM 放送帯 (88〜108 MHz) の端でも
  −12〜−13 dB 落ちる — 1 段だけなので裾は広い
- 144 MHz (2m バンド) では −3.5 dB まで戻る。狭いノッチにしたいなら共振器を
  増やす (6-9 のダイプレクサ、6-15 のバンドパスと同じ考え方)

## 見るべき値

計算値。

| 周波数 | S21 | 分かること |
| --- | --- | --- |
| 1 MHz | 約 0 dB | 通過帯域 (ノッチから遠い) |
| 88 MHz | −12.4 dB | FM 帯の下端 |
| 98.1 MHz | −32.9 dB | ノッチの底 (共振周波数) |
| 108 MHz | −13.4 dB | FM 帯の上端 |
| 144 MHz | −3.5 dB | 2m バンド。まだ 1 dB 以上落ちている (1 段の裾の広さ) |

コイルを無損失 (Q → ∞) にすると底は理論上 −∞ dB (完全に落とす) に近づくが、
実物には必ず ESR があるので、**底の深さは Q で頭打ちになる**。

## 出典

自作。
