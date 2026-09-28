---
book: nanovna
chapter: 2
id: 2-6
title: R + jX と極表示
tier: 100
source: 自作
board: —
device: H4
---

# 2-6 R + jX と極表示

NanoVNA が測っているのは反射係数 Γ (S11) という 1 つの複素数で、画面の形式は
その**見せ方の違い**にすぎない (2-1)。部品を調べるときによく使うのが、Γ を
インピーダンスに直した **R + jX** と、Γ をそのまま大きさと角度で描く**極表示**
(POLAR)。R・L・C を直列にした 1 端子の DUT で、同じ点を 2 通りに読む。

## 式

Z = R + jX = 50 × (1 + Γ) / (1 − Γ)、逆に Γ = (Z − 50) / (Z + 50)

| 読み方 | 何を表すか | 画面の形式 |
| --- | --- | --- |
| R | 抵抗の成分 (熱になる分) | S11 の R (RESISTANCE) |
| X | リアクタンス。**正なら誘導性 (L の側)、負なら容量性 (C の側)** | S11 の X (REACTANCE) |
| \|Γ\| ∠θ | 反射の大きさ (0〜1) と角度 | S11 の POLAR |
| Smith | Γ の平面に R と X の目盛を重ねたもの | S11 の SMITH |

X が分かれば、その周波数で**同じ X になる L か C** に直せる (等価の L・C)。

- X > 0 なら L = X / (2πf)
- X < 0 なら C = 1 / (2πf × |X|)

直列共振の回路では、この等価の値は周波数ごとに変わる (部品の値そのものではない)。

## 回路図

DUT は SMA の先に、22 Ω・100 nH・100 pF を直列につないで先を GND に落としたもの
(共振 50.33 MHz)。

```circuit
title: 図1 CH0 の先に R L C を直列 (1 端子)
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  R1: resistor a4i0i0 a5i0i0 22
  L1: inductor a6i0i0 a7i0i0 100n
  C1: capacitor a8i0i0 c8i0i0 100p
  G1: ground c8i0i0
wires:
  - M1.CH0 -| a4i0i0
  - a5i0i0 -- a6i0i0
  - a7i0i0 -- a8i0i0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/06-rx-polar.svg)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 25 MHz〜125 MHz |
| 点数 | 101 (1 MHz おき) |
| 校正 | CH0 のケーブルの先で Open / Short / Load (1-1) |
| 表示 | 図 2 は S11 の R と X、図 3 は S11 の極表示と Smith |

```vna
device: h4
sweep: 25M-125M 101
title: 図2 R は 22 Ω のまま、X は負から正へ (50.33 MHz で 0)
dut:
  - series R 22
  - series L 100n
  - series C 100p
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 30M
  - 50.33M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/06-rx-polar-1.svg)

同じ DUT、同じ掃引と印を、極表示と Smith で見る。

```vna
device: h4
sweep: 25M-125M 101
title: 図3 同じ点を極表示と Smith で — 共振で 0.389∠180°
dut:
  - series R 22
  - series L 100n
  - series C 100p
  - short
traces:
  - S11 polar
  - S11 smith
markers:
  - 30M
  - 50.33M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/06-rx-polar-2.svg)

- **R はどの周波数でも 22 Ω** (図 2 の R は平ら)。直列の L と C は R を変えない
- **X は 30 MHz で −34.2 Ω (容量性)、50.33 MHz で 0、100 MHz で +46.9 Ω (誘導性)**。
  X = 2πfL − 1 / (2πfC) の形そのまま
- 極表示では点が円の中を時計回りに回る。共振の点は大きさ 0.389、角度 180°
  (左の実軸の上)。Γ = (22 − 50) / (22 + 50) = −0.389 で、**実数の負の値は角度 180°**
- Smith は極表示と同じ点の並びに、R と X の目盛の円を重ねたもの。印 2 は R = 22 Ω の
  円と実軸の交わる所 (22.0 Ω + j0.0 Ω)

## 見るべき値

| 印 | 周波数 | R + jX | 極表示 \|Γ\| ∠θ | 等価の L・C |
| --- | --- | --- | --- | --- |
| 1 | 30 MHz | 22.0 Ω − j34.2 Ω | 0.555 ∠ −103.9° | C = 155.1 pF |
| 2 | 50.33 MHz | 22.0 Ω + j0.0 Ω | 0.389 ∠ 180° | (共振。L も C も打ち消し合う) |
| 3 | 100 MHz | 22.0 Ω + j46.9 Ω | 0.636 ∠ 87.7° | L = 74.7 nH |

(計算値。等価の L・C は X から上の式で計算した)

- 印 1 の等価 C (155.1 pF) は、C1 (100 pF) より大きい。L1 の +18.8 Ω がリアクタンスの
  一部を打ち消し、容量性の X が小さく (C が大きく) 見えるから
- 印 3 の等価 L (74.7 nH) は、L1 (100 nH) より小さい。今度は C1 の −15.9 Ω が打ち消す
- **部品 1 つの値を読むなら、ほかの部品の影響が小さい周波数で読む** (コイルの SRF と
  Q は 4-4、コンデンサは 4-2)

## 出典

自作。
