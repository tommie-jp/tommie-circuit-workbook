---
book: nanovna
chapter: 1
id: 1-7
title: 校正キットの質 — 付属 / 自作 / 市販
tier: 100
source: 自作
board: —
device: H4
---

# 1-7 校正キットの質 — 付属 / 自作 / 市販

SOLT (1-1) は、**Open・Short・Load が理想どおりだと信じて**補正係数を計算する。
標準器が理想からずれていれば、そのずれは補正の中に入り込み、以後のすべての
測定に乗る。とくに Load は効き方が分かりやすい — **Load の反射がそのまま
「校正した後に読める反射の下限」になる**。キットの質を、Load の等価回路で比べる。

## キットの 3 通り

| キット | 中身 | 良い所 | 弱い所 |
| --- | --- | --- | --- |
| 付属 | SMA オスの Open・Short・Load と Thru (メス–メス) | 手元にすぐある。形が揃っている | 値の保証が無い。寄生分の定義 (係数) が付かない |
| 自作 (3-4) | perfboard に端面 SMA と 100 Ω 2 本 | 安い。壊しても作り直せる。治具と同じ面で校正できる | 足とパターンのインダクタンスが大きい。300 MHz あたりから離れる |
| 市販 | 周波数と反射の上限が書かれた SMA の標準器 | 仕様がある。Open の容量・Short のインダクタンスの係数が付くものもある | 高い。締めすぎると傷む (0-2) |

どれを使っても 9 手順は同じ。違うのは、**どの周波数まで理想と見なしてよいか**。

## Load の等価回路

Load の中の抵抗は、足やチップの電極のぶん**直列にインダクタンス L** を持つ。
50 Ω と L の直列の反射は

Γ = jωL / (100 + jωL)、|Γ| ≈ ωL / 100 (ωL が 100 Ω より十分小さいとき)

なので、**周波数に比例して反射が増える** (Log Mag では 10 倍で +20 dB)。

| キット | 直列の L (例) | 根拠 |
| --- | --- | --- |
| 市販 | 0.2 nH | 仕様の反射の上限から逆算する大きさ (例) |
| 付属 | 0.5 nH | SMA の中のチップ抵抗 (例。個体差がある) |
| 自作 (3-4) | 2 nH | 100 Ω 2 本の足 3 mm ずつ。7 nH/cm (4-7) × 0.3 cm ÷ 2 本 ≈ 1 nH に、パターンのぶんを足した見積もり |

L の値は**比べるための例**で、実物の値ではない。実物は、市販の Load を基準にして
測れば読める (下の「確かめ方」)。

## 回路図

```circuit
title: 図1 Load の等価回路 (50 Ω と直列の L)
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  L1: inductor a4i0i0 a6i0i0 2n
  R1: resistor a7i0i0 c7i0i0 50
  G1: ground c7i0i0
wires:
  - M1.CH0 -| a4i0i0
  - a6i0i0 -- a7i0i0
notes:
  - text c7f5 blue: 等価回路 (自作の例)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/07-cal-kit-quality.svg)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 校正キットの質を調べる題で、図の回路は Load の等価回路 (寄生のインダクタンス)。組む物が無い (自作の Load は 3-4 で組む)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜1.5 GHz |
| 点数 | 150 |
| 校正 | 市販の Load で SOLT (比べる基準)。その後に付属・自作の Load を DUT として測る |
| 表示 | S11 の Log Mag、S11 の X (リアクタンス) |

付属の Load の例 (0.5 nH)。

```vna
device: h4
sweep: 10M-1.5G 150
title: 図2 付属の Load の例 (0.5 nH) — 1.5 GHz で −26.54 dB
dut:
  - series L 0.5n
  - series R 50
  - short
traces:
  - S11 logmag
  - S11 x
markers:
  - 100M
  - 500M
  - 1G
  - 1.5G
notes:
  - text 600M -60dB: 周波数が 10 倍で反射は +20 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/07-cal-kit-quality-1.svg)

自作の Load の例 (2 nH)。設定は図 2 と同じ。

```vna
device: h4
sweep: 10M-1.5G 150
title: 図3 自作の Load の例 (2 nH) — 1.5 GHz で −14.65 dB
dut:
  - series L 2n
  - series R 50
  - short
traces:
  - S11 logmag
  - S11 x
markers:
  - 100M
  - 500M
  - 1G
  - 1.5G
notes:
  - text 600M -60dB: 同じ周波数で図 2 より 12 dB 高い
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/07-cal-kit-quality-2.svg)

- L が 4 倍なら反射は 4 倍 (+12 dB)。**図 2 と図 3 は同じ形で、12 dB ずれているだけ**
- X は ωL で周波数に比例する (誘導性、+jX)。1.5 GHz で付属は +4.7 Ω、自作は +18.8 Ω
  (X の枠の目盛は図ごとに違う。高さではなく読み値で比べる)。
  Smith なら真ん中から上へ伸びる短い線で、自作のほうが長い

## この反射が校正に入ると

自作の Load で校正すると、NanoVNA は「この Load が Γ = 0」と覚える。その後に
**本物の 50 Ω を測ると、自作の Load のずれを裏返した値** (大きさがほぼ同じ反射) が出る。
つまり、

- 自作キットで校正した後は、1 GHz で **−18 dB より小さい反射は読めない**
  (アンテナの SWR なら 1.29 より良い値は信じられない)
- 付属キットなら同じ 1 GHz で −30 dB (SWR 1.07) まで読める

**測りたい反射より 10 dB 以上低い Load で校正する**のが目安 (この教科書の決め)。

## 確かめ方

1. 市販の Load (無ければ、手持ちでいちばん良い Load) で SOLT する
2. 付属・自作の Load をそれぞれ DUT として CH0 につなぎ、S11 の Log Mag を読む
3. 読んだ値が、その Load で校正したときの「読める下限」になる
4. Open・Short も同じように測ると、Smith の右端・左端からどれだけ回るかが見える
   (Open の容量・Short の誘導の定義は 1-12)

## 見るべき値

S11 Log Mag (計算値)。

| 周波数 | 市販 (0.2 nH の例) | 付属 (0.5 nH の例) | 自作 (2 nH の例) |
| --- | --- | --- | --- |
| 100 MHz | −58.02 dB | −50.06 dB | −38.02 dB |
| 500 MHz | −44.04 dB | −36.08 dB | −24.05 dB |
| 1 GHz | −38.02 dB | −30.06 dB | −18.08 dB |
| 1.5 GHz | −34.50 dB | −26.54 dB | −14.65 dB |

**どのキットも低い周波数では十分に良い。** 差が出るのは数百 MHz より上。
300 MHz までの測定 (この教科書の必須の題の多く) なら、自作でも −28 dB より良い。
1 GHz を超えて測るなら、付属か市販のキットを使う。

## 出典

自作。
