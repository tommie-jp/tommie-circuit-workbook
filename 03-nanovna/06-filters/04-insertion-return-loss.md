---
book: nanovna
chapter: 6
id: 6-4
title: 挿入損失と反射損失 (S21 と S11)
tier: 50
source: 自作
board: PF
device: H4
---

# 6-4 挿入損失と反射損失 (S21 と S11)

フィルタの通過帯域は「S21 が 0 dB」ではなく、実際は必ず少し落ちる。落ちる理由が
**反射** (入口で跳ね返って入らない分、S11) なのか、**損失** (部品の中で熱になる分)
なのかを、6-1 と同じ 7 次ローパスで、コイルの Q を入れて見分ける。

## この実験で確かめる式

入った電力を 1 とすると、**|S21|² + |S11|² + (損失で消える分) = 1**。
コイルが無損失なら |S21|² + |S11|² = 1 (反射と透過だけで電力保存)。
コイルに直列抵抗 (ESR = ωL / Q) を入れると、その差が熱になって消える分になる。

Q = 60 のコイル (330 nH・560 nH) の ESR は、周波数ごとに **ESR = 2π f L / 60**
で計算する (10 MHz で 330 nH なら ESR ≈ 0.35 Ω)。

## 回路図

6-1 と同じ 7 次ローパス (C1=C4=47 pF、L2=L6=330 nH、C3=C5=200 pF、L4=560 nH)。
コイルに Q = 60 の損失があるとみなす (回路図では理想の記号のまま、値だけ同じ)。

```circuit
title: 図1 7 次 LC ローパス (コイルに Q 60 を仮定)
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 47p
  L1: inductor b5 b7 330n
  C2: capacitor b8 d8 200p
  L2: inductor b9 b11 560n
  C3: capacitor b12 d12 200p
  L3: inductor b13 b15 330n
  C4: capacitor b16 d16 47p
  J2: sma b18 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d8
  G4: ground d12
  G5: ground d16
  G6: ground c18
wires:
  - J1.1 -- b4 -- b5
  - b7 -- b8 -- b9
  - b11 -- b12 -- b13
  - b15 -- b16 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c18
```

## 実体配線図

6-1 と同じ治具 (端面 SMA 2 つの perfboard)。

```perfboard
board:
  size: 34x10
title: 図2 perfboard に組む (6-1 と同じ治具)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 f3 47p
  L1: inductor e5 e9 330n
  C2: capacitor e11 f11 200p
  L2: inductor e13 e18 560n
  C3: capacitor e20 f20 200p
  L3: inductor e22 e26 330n
  C4: capacitor e28 f28 47p
  J2: sma/female-edge e34 f35
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e11
  - e11 -- e13
  - e18 -- e20
  - e20 -- e22
  - e26 -- e28
  - e28 -- e34
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- f3 black
  - h3 -- h11 black
  - h11 -- f11 black
  - h11 -- h20 black
  - h20 -- f20 black
  - h20 -- h28 black
  - h28 -- f28 black
  - h28 -- h33 black
  - f35 -- f33 black
  - f33 -- h33 black
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz (通過帯域とその端に絞る) |
| 点数 | 151 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag、S11 の Log Mag |

コイルに ESR (Q = 60) を入れた**見えるはずの画面**。

```vna
device: h4
sweep: 1M-30M 151
title: 図2 通過帯域の S21・S11 (コイル Q 60)
dut:
  - shunt C 47p
  - series L 330n esr 0.35
  - shunt C 200p
  - series L 560n esr 0.59
  - shunt C 200p
  - series L 330n esr 0.35
  - shunt C 47p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 10M
  - 25M
```

- ESR は 10 MHz での値 (2π × 10 MHz × L / 60) を代表値として一定に置いた
  簡略化。実際は周波数に比例して増える (見るべき値の表は周波数ごとに計算し直した値)
- 通過帯域でも S21 は 0 dB に届かない。届かない分は S11 (反射) と、コイルで
  熱になる分の合計

## 見るべき値

計算値。ESR は各周波数で ωL/60 として計算し直している (フェンスの図は
10 MHz の代表値で簡略化しているので、この表の数値の方が正確)。

| 周波数 | S21 | S11 | \|S21\|² + \|S11\|² | 熱になる分 |
| --- | --- | --- | --- | --- |
| 1 MHz | −0.01 dB | −56.0 dB | 0.9974 | 0.26 % |
| 10 MHz | −0.12 dB | −41.4 dB | 0.9736 | 2.64 % |
| 20 MHz | −0.34 dB | −19.0 dB | 0.9375 | 6.25 % |
| 25 MHz | −1.23 dB | −8.2 dB | 0.9036 | 9.64 % |
| 30 MHz | −5.32 dB | −2.3 dB | 0.8787 | 12.13 % |

- 通過帯域の低い所 (1 MHz) では反射も損失もごくわずかで、ほぼ全部が通る
- カットオフに近づくほど**反射も損失も両方増える** — 反射が増えるのは
  素子のリアクタンスが 50 Ω からずれ始めるため、損失が増えるのはコイルを流れる
  電流 (と ESR で消える電力) が増えるため
- 挿入損失 (measured S21 の dB) だけを見ても、原因が反射か損失かは分からない。
  S11 も同時に見て、\|S21\|² + \|S11\|² が 1 よりどれだけ小さいかで損失分を見積もる

## 出典

自作。
