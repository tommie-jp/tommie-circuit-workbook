---
book: nanovna
chapter: 6
id: 6-5
title: 設計と実測 — バターワース vs チェビシェフ
tier: 50
source: 自作
board: PF
device: H4
---

# 6-5 設計と実測 — バターワース vs チェビシェフ

同じ 5 次・同じカットオフ 30 MHz でも、フィルタの**種類**で通過帯域と遮断の形が
変わる。バターワース (最平坦) は通過帯域が平らな代わりに遮断が緩やか、
チェビシェフ (等リップル) は通過帯域に**わずかな波打ち**を許す代わりに遮断が急。
ここではチェビシェフ (リップル 0.5 dB) を実際に作り、バターワースは計算だけで比べる。

## この実験で確かめる式

5 次チェビシェフ (リップル 0.5 dB) の正規化定数は
g1 = g5 = 1.7058、g2 = g4 = 1.2296、g3 = 2.5409。
バターワース (6-1・6-4 と同じ考え方) は g1 = g5 = 0.618、g2 = g4 = 1.618、g3 = 2.000。

C・L の式は 6-1 と同じ (**C = g/(2π f_c R)**、**L = g R/(2π f_c)**)。
f_c = 30 MHz、R = 50 Ω での計算値と、E12/E24 系列に丸めた値:

| 種類 | C1 = C5 | L2 = L4 | C3 |
| --- | --- | --- | --- |
| バターワース (計算値→丸め) | 65.6 pF → 68 pF | 429.2 nH → 430 nH | 212.2 pF → 220 pF |
| チェビシェフ 0.5 dB (計算値→丸め) | 181.0 pF → 180 pF | 326.2 nH → 330 nH | 269.6 pF → 270 pF |

## 回路図

**作るのはチェビシェフ**。バターワースは比べるための参考 (計算だけ)。

```circuit
title: 図1 5 次チェビシェフ 0.5 dB ローパス (作る方)
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

```circuit
title: 図2 5 次バターワース ローパス (計算だけの参考)
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 68p
  L1: inductor b5 b7 430n
  C2: capacitor b8 d8 220p
  L2: inductor b9 b11 430n
  C3: capacitor b12 d12 68p
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

- 回路の形 (5 次 π 型) は同じ。**値の比だけが違う**。チェビシェフは両端の C が
  大きく真ん中の C との差が小さい (だから通過帯域で反射が波打つ)

## 実体配線図

```perfboard
board:
  size: 26x10
title: 図3 perfboard に組む (チェビシェフ)
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
  - h25 -- f27 black
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜50 MHz |
| 点数 | 301 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag |

チェビシェフ (作る方) の**見えるはずの画面**。

```vna
device: h4
sweep: 1M-50M 301
title: 図4 チェビシェフ 0.5 dB の S21 (E12/E24 丸め後)
dut:
  - shunt C 180p
  - series L 330n
  - shunt C 270p
  - series L 330n
  - shunt C 180p
traces:
  - S21 logmag
markers:
  - 10M
  - 28M
  - 35M
```

バターワース (参考) の**計算だけの画面**。

```vna
device: h4
sweep: 1M-50M 301
title: 図5 バターワースの S21 (計算のみ、比べる用)
dut:
  - shunt C 68p
  - series L 430n
  - shunt C 220p
  - series L 430n
  - shunt C 68p
traces:
  - S21 logmag
markers:
  - 10M
  - 28M
  - 35M
```

- チェビシェフは通過帯域 (1〜28 MHz あたり) に**0.5 dB 弱の波打ち**が見える
  (マーカー 1 と 2 で −0.47 dB と −0.01 dB。丸めのせいでリップルの谷が少しずれる)
- 35 MHz でチェビシェフは −10.5 dB、バターワースは −8.1 dB。**同じ 5 次でも
  チェビシェフの方が遮断が急**

## 見るべき値

計算値。

| 周波数 | バターワース S21 | チェビシェフ S21 |
| --- | --- | --- |
| 10 MHz | −0.00 dB | −0.47 dB (リップルの谷) |
| 20 MHz | −0.11 dB | −0.13 dB |
| 28 MHz | −2.01 dB | −0.01 dB (リップルの山) |
| 30 MHz (設計カットオフ) | −3.36 dB | −0.68 dB |
| 35 MHz | −8.09 dB | −10.45 dB |
| 40 MHz | −13.39 dB | −19.72 dB |
| 50 MHz | −22.97 dB | −32.76 dB |

- チェビシェフは通過帯域の途中 (28 MHz) で **−0.01 dB まで戻る** — これがリップルの山
- 30 MHz から上ではチェビシェフの方が速く落ちる。**リップルを許した分だけ
  遮断が急になる**のがチェビシェフの設計思想
- 同じ次数・同じカットオフでも部品の値の比が違うだけで特性が変わることが、
  実測 (チェビシェフ) と計算 (バターワース) の比較から分かる

## 出典

自作。5 次バターワース・チェビシェフ (0.5 dB) の g 値は標準的なフィルタ設計表による。
