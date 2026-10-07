---
book: nanovna
chapter: 6
id: 6-10
title: π 型と T 型
tier: 100
source: 自作
board: PF
device: H4
---

# 6-10 π 型と T 型

3 素子のローパスは、両端をコンデンサにする **π 型** (C-L-C) と、両端をコイルに
する **T 型** (L-C-L) の 2 通りに組める。同じバターワースの式から作れば、
S21 (通り方) はほとんど同じになる。違いが出るのは**阻止帯域で入口から見た
インピーダンス** — π 型は低く (コンデンサで地に落ちる)、T 型は高く (コイルで
ふさがる) 見える。カットオフ 30 MHz の 3 次で両方を作り、S21 と Smith チャートで比べる。

## この実験で確かめる式

3 次バターワースの g 値は g1 = g3 = 1、g2 = 2 (6-2 と同じ)。f_c = 30 MHz、R = 50 Ω で、
**C = g / (2π f_c R)**、**L = g R / (2π f_c)** (6-1 と同じ式)。

| 型 | 両端の素子 (g = 1) | 真ん中の素子 (g = 2) |
| --- | --- | --- |
| π 型 (C-L-C) | C = 106.1 pF → **100 pF** (E12) | L = 530.5 nH → **560 nH** (E12) |
| T 型 (L-C-L) | L = 265.3 nH → **270 nH** (E12) | C = 212.2 pF → **220 pF** (E12) |

丸めた値での −3 dB は、π 型が 29.4 MHz、T 型が 29.1 MHz (計算値)。

## 回路図

```circuit
title: 図1 パイ型 (C-L-C)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 100p
  L1: inductor 5,2 7,2 560n
  C2: capacitor 8,2 8,4 100p
  J2: sma 10,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 8,4
  G4: ground 10,3
wires:
  - J1.1 -- 4,2 -- 5,2
  - 7,2 -- 8,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 10,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/10-pi-and-t-1.svg)

```circuit
title: 図2 T 型 (L-C-L)
parts:
  J1: sma 2,2 mirror CH0
  L1: inductor 3,2 5,2 270n
  C1: capacitor 6,2 6,4 220p
  L2: inductor 7,2 9,2 270n
  J2: sma 10,2 CH1
  G1: ground 2,3
  G2: ground 6,4
  G3: ground 10,3
wires:
  - J1.1 -- 3,2
  - 5,2 -- 6,2 -- 7,2
  - 9,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 10,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/10-pi-and-t-2.svg)

- π 型はコイル 1 個・コンデンサ 2 個、T 型はコイル 2 個・コンデンサ 1 個。
  コイルのほうが高く損失も大きいので、**同じ特性なら π 型が選ばれることが多い**

## 実体配線図

2 枚とも同じ大きさのユニバーサル基板に、端面 SMA 2 つ (6-1 と同じ作り)。部品面から見た図。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図3 π 型を perfboard に組む
parts:
  J1: sma/female-edge a10 09
  C1: capacitor c10 c9 100p
  L1: inductor e10 i10 560n
  C2: capacitor k10 k9 100p
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - c10 -- e10
  - i10 -- k10
  - k10 -- x10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- c7 black
  - c7 -- c9 black
  - c7 -- k7 black
  - k7 -- k9 black
  - k7 -- m7 black
  - y9 -- m9 black
  - m9 -- m7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/10-pi-and-t-1.svg)

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図4 T 型を perfboard に組む
parts:
  J1: sma/female-edge a10 09
  L1: inductor b10 f10 270n
  C1: capacitor g10 g8 220p
  L2: inductor h10 l10 270n
  J2: sma/female-edge x10 y9
wires:
  - a10 -- b10
  - f10 -- g10
  - g10 -- h10
  - l10 -- x10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- g7 black
  - g7 -- g8 black
  - g7 -- m7 black
  - y9 -- m9 black
  - m9 -- m7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/10-pi-and-t-2.svg)

- i 行が信号の通り道、l 行が GND の筋。どちらもコンデンサの下のピンを l 行へ落とす
- コイルは軸物 (カラーコード付き)。560 nH・270 nH とも E12 の値で買える

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz |
| 点数 | 199 (0.5 MHz おき) |
| 校正 | SOLT (Thru はケーブル 2 本を直結) |
| 表示 | S21 の Log Mag と S11 の Smith |

2 枚とも掃引とマーカーを同じにする。マーカーは通過帯域 (10 MHz)・
カットオフ (30 MHz)・阻止帯域 (60 MHz・100 MHz)。π 型の**見えるはずの画面**。

```vna
device: h4
sweep: 1M-100M 199
title: 図5 π 型 — 阻止帯域の Smith は左下 (容量性で低い Z)
dut:
  - shunt C 100p
  - series L 560n
  - shunt C 100p
traces:
  - S21 logmag
  - S11 smith
markers:
  - 10M
  - 30M
  - 60M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/10-pi-and-t-1.svg)

T 型。

```vna
device: h4
sweep: 1M-100M 199
title: 図6 T 型 — S21 は π 型とほぼ同じ。Smith は右上 (誘導性で高い Z)
dut:
  - series L 270n
  - shunt C 220p
  - series L 270n
traces:
  - S21 logmag
  - S11 smith
markers:
  - 10M
  - 30M
  - 60M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/10-pi-and-t-2.svg)

## 見るべき値

計算値 (無損失として)。

| 周波数 | π 型の S21 | T 型の S21 | π 型の入口の Z | T 型の入口の Z |
| --- | --- | --- | --- | --- |
| 10 MHz | −0.02 dB | −0.01 dB | 54.4 + j6.1 Ω | 47.0 − j3.3 Ω |
| 30 MHz | −3.23 dB | −3.41 dB | 51.0 − j106.2 Ω | 9.0 + j21.9 Ω |
| 60 MHz | −17.83 dB | −18.78 dB | 0.3 − j30.8 Ω | 0.7 + j88.5 Ω |
| 100 MHz | −30.91 dB | −32.01 dB | 0.0 − j16.7 Ω | 0.1 + j162.1 Ω |

- **S21 は 1 dB と違わない**。通過帯域でもカットオフより上でも、同じ設計の
  π と T は信号の通り方がほぼ同じ
- 入口の Z は阻止帯域で正反対。π 型は周波数が上がるほど 0 Ω に近づき
  (Smith の左端へ)、T 型は大きくなる (右端へ)。どちらも反射して返すが、
  **返し方 (短絡に近いか開放に近いか) が違う**

分かること:

- **阻止帯域で前段にどう見えるか**で型を選ぶ。たとえば送信機の出力の
  高調波フィルタ (6-17) では、トランジスタの出力に高調波を短絡に近い
  低い Z で返す π 型がよく使われる。逆に、高調波をふさいで流さない T 型を
  選ぶ回路もある
- 反射で返すフィルタ (LC のはしご) は、どの型でも**阻止帯域の電力を
  入口へ返す**。前段が反射を嫌うなら、吸収型のフィルタや
  アッテネータ (3-5) を挟む
- 部品の数と値は、π なら C が 2 つ、T なら L が 2 つ。手持ちの部品で組みやすい
  ほうを選んでよい

## 出典

自作。3 次バターワースの g 値は標準的なフィルタ設計表による。
