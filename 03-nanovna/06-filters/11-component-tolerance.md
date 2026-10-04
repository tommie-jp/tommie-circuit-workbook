---
book: nanovna
chapter: 6
id: 6-11
title: 部品の許容差の影響
tier: 100
source: 自作
board: PF
device: H4
---

# 6-11 部品の許容差の影響

部品の値には**許容差**がある。コンデンサの J は ±5 %、コイルの K は ±10 %。
設計どおりの値の部品は 1 つも無いと思ってよい。6-5 で作ったチェビシェフ
(0.5 dB) の 5 次ローパスを例に、部品が許容差の端までずれたとき S21 と
S11 がどれだけ変わるかを計算し、実物で確かめる。

## この実験で確かめる式

LC フィルタの周波数は **1/√(LC)** で決まる。全部の L と C が同じ向きに
ずれると、カットオフが**まるごと動く**: C が +5 %、L が +10 % なら
1/√(1.05 × 1.10) = 0.93 倍。一方、部品が**ばらばらの向き**にずれると、
カットオフはあまり動かず、**通過帯域のリップルと S11 (整合) が崩れる**。

部品 (6-5 と同じ。許容差は仮定):

| 部品 | 設計値 | 許容差 |
| --- | --- | --- |
| C1・C3 | 180 pF | ±5 % (J、セラミック CH 特性) |
| C2 | 270 pF | ±5 % (J) |
| L1・L2 | 330 nH | ±10 % (K、カラーコードの軸物) |

## 回路図

```circuit
title: 図1 5 次チェビシェフ 0.5 dB ローパス (6-5 と同じ)
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 180p
  L1: inductor b5 b7 330n
  C2: capacitor b8 d8 270p
  L2: inductor b9 b11 330n
  C3: capacitor b12 d12 180p
  J2: sma b14 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d8
  G4: ground d12
  G5: ground c14
wires:
  - J1.1 -- b4 -- b5
  - b7 -- b8 -- b9
  - b11 -- b12 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c14
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/11-component-tolerance.svg)

## 実体配線図

6-5 と同じ板。部品面から見た図。部品を挿し替えて比べるので、
**半田付けは C と L の足を長めに残し、挿し替えやすくしておく** (高い周波数ではないので
足の数 mm の違いは効かない)。

```perfboard
board:
  size: 26x10
  slots: on
title: 図2 perfboard に組む (6-5 と同じ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 f3 180p
  L1: inductor e5 e9 330n
  C2: capacitor e11 f11 270p
  L2: inductor e13 e17 330n
  C3: capacitor e19 f19 180p
  J2: sma/female-edge e26 f27
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e11
  - e11 -- e13
  - e17 -- e19
  - e19 -- e26
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- f3 black
  - h3 -- h11 black
  - h11 -- f11 black
  - h11 -- h19 black
  - h19 -- f19 black
  - h19 -- h25 black
  - f27 -- f25 black
  - f25 -- h25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/11-component-tolerance.svg)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜50 MHz (6-5 と同じ) |
| 点数 | 301 |
| 校正 | SOLT |
| 表示 | S21 と S11 の Log Mag |

3 枚とも掃引とマーカー (10・24.8・28・35 MHz) をそろえ、変えるのは
部品の値だけ。24.8 MHz は図5 の通過帯域がいちばん落ちる所。まず設計値 (6-5 の図4 に S11 を足したもの)。

```vna
device: h4
sweep: 1M-50M 301
title: 図3 設計値 — 35 MHz で −10.4 dB、S11 は通過帯域で −9.8 dB 以下
dut:
  - shunt C 180p
  - series L 330n
  - shunt C 270p
  - series L 330n
  - shunt C 180p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 24.8M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/11-component-tolerance-1.svg)

全部が大きいほうの端 (C は +5 %、L は +10 %) にずれたとき。

```vna
device: h4
sweep: 1M-50M 301
title: 図4 全部 + 側 (C +5 %、L +10 %) — 形はそのまま、カットオフが下がる
dut:
  - shunt C 189p
  - series L 363n
  - shunt C 283.5p
  - series L 363n
  - shunt C 189p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 24.8M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/11-component-tolerance-2.svg)

ばらばらの向きにずれたとき。32 通りの端の組み合わせのうち、通過帯域が
いちばん崩れる組 (C1・C3 +5 %、L1 +10 %、C2 −5 %、L2 −10 %)。

```vna
device: h4
sweep: 1M-50M 301
title: 図5 ばらばらにずれた最悪の組 — リップルが 1.1 dB、S11 が −6.5 dB まで悪化
dut:
  - shunt C 189p
  - series L 363n
  - shunt C 256.5p
  - series L 297n
  - shunt C 189p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 24.8M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/11-component-tolerance-3.svg)

## 見るべき値

計算値 (無損失として)。

マーカーの読み値 (S21 / S11)。

| マーカー | 設計値 (図3) | 全部 + 側 (図4) | ばらばら・最悪 (図5) |
| --- | --- | --- | --- |
| 1 (10 MHz) | −0.47 / −9.85 dB | −0.39 / −10.67 dB | −0.45 / −10.04 dB |
| 2 (24.8 MHz) | −0.45 / −10.07 dB | −0.19 / −13.79 dB | **−1.11 / −6.48 dB** |
| 3 (28 MHz) | −0.01 / −25.56 dB | **−0.84 / −7.53 dB** | −0.57 / −9.10 dB |
| 4 (35 MHz) | −10.45 / −0.41 dB | **−15.59** / −0.12 dB | −9.82 / −0.48 dB |

通過帯域 (1〜28 MHz) 全体で見た値と −3 dB の周波数 (計算値)。

| 項目 | 設計値 | 全部 + 側 | ばらばら・最悪 |
| --- | --- | --- | --- |
| −3 dB の周波数 | 31.6 MHz | 29.3 MHz | 32.0 MHz |
| 通過帯域の S21 の最小 | −0.48 dB (9.2 MHz) | −0.84 dB (28 MHz) | **−1.11 dB** (24.8 MHz) |
| 通過帯域の S11 の最大 | −9.8 dB | −7.5 dB | **−6.5 dB** |

部品を許容差の中で一様にばらつかせて 1000 回計算すると (計算値):

| 項目 | 5 % の組 | 中央 | 95 % の組 |
| --- | --- | --- | --- |
| −3 dB の周波数 | 30.3 MHz | 31.6 MHz | 32.9 MHz |
| 通過帯域の S21 の最小 | −0.74 dB | −0.55 dB | −0.43 dB |
| 通過帯域の S11 の最大 | −10.3 dB | −9.3 dB | −8.0 dB |
| 35 MHz の S21 | −13.1 dB | −10.3 dB | −7.4 dB |

分かること:

- **カットオフは ±4 % くらい動く** (1000 回の 9 割が 30.3〜32.9 MHz)。遮断が急な
  フィルタほど、同じずれで阻止帯域の減衰が大きく変わる (35 MHz で −7〜−13 dB)
- **向きがそろったずれは形を保ち、ばらばらのずれは形を崩す**。図4 は図3 を
  左へずらしただけだが、図5 はリップルと S11 が悪くなる
- 対策は、組む前に部品を 1 つずつ測って選ぶこと。コンデンサは 4-2、コイルは 4-4 の
  方法で値を読み、**同じ値の部品 (C1 と C3、L1 と L2) を近い物どうしで組にする**。
  対称の位置の部品がそろうだけで、図5 のような崩れ方は起きにくい
- 実測を重ねるときは、S21 だけでなく S11 も見る。通過帯域の S11 は部品のずれに
  いちばん敏感な物差し

## 出典

自作。5 次チェビシェフ (0.5 dB) の g 値は標準的なフィルタ設計表による。
