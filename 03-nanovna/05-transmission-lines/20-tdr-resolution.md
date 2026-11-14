---
book: nanovna
chapter: 5
id: 5-20
title: TDR の分解能と帯域 (H4 vs V2)
tier: 200
source: 自作
board: —
device: V2
---

# 5-20 TDR の分解能と帯域 (H4 vs V2)

2-7 で、TDR の山の細さ (距離の分解能) は**掃引の範囲の広さ**で決まると書いた。範囲の上の端は
機種で決まる: H4 は 1.5 GHz、V2 は 3 GHz、LiteVNA64 は 6.3 GHz。同じケーブルに、**7 cm だけ
離れた 2 つの反射**を作り、H4 の範囲 (1.5 GHz) では 1 つの山に融け、V2 の範囲 (3 GHz) では
2 つに分かれることを確かめる。

2 つの反射は、1 m の 50 Ω (オーム) のケーブルの先に、7 cm の **75 Ω** のケーブルを挟んで作る (5-6)。
75 Ω の入口で Γ (ガンマ) = (75 − 50) / (75 + 50) = **+0.2**、出口 (50 Ω の Load へ) で **−0.2**。

## この実験で確かめる式

| 決めるもの | 式 | H4 (1 MHz〜1.5 GHz) | V2 (1 MHz〜3 GHz) |
| --- | --- | --- | --- |
| 距離の分解能 (目安) | VF × c / (2 × 範囲) | 0.066 m | 0.033 m |
| 窓を掛けた山の幅 (目安) | 上の 2 倍ほど | 0.13 m | 0.066 m |
| 見える距離の上限 | VF × c / (2Δf) (401 点。Δ はデルタ) | 26.4 m | 13.2 m |

VF は速度係数 (0.66)、c は光の速さ、Δf は点の間隔。2 つの反射の間は 7 cm で、
**H4 の山の幅 (0.13 m) より狭く、V2 の山の幅 (0.066 m) より少し広い**。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 1 m (50 Ω) + 7 cm (75 Ω)、先は 50 Ω の Load
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 3,2 6,2 50 l=$\mathrm{TL}_1$
  TL2: tline 7,2 9,2 75 l=$\mathrm{TL}_2$
  R1: resistor 10,2 10,4 50
  G1: ground 2,3
  G2: ground 10,4
wires:
  - J1.1 -- 3,2
  - 6,2 -- 7,2
  - 9,2 -- 10,2
  - J1.2 -- 2,3
notes:
  - text 4.5,2.7 center: 1 m
  - text 8,2.7 center: 7 cm
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/20-tdr-resolution.svg)

- TL1 は 5-1 と同じ 1 m のケーブル (RG-58 相当、速度係数 0.66)
- TL2 は 75 Ω の同軸 (3C-2V など、速度係数 0.67 前後) を 7 cm に切り、両端に SMA を付けた物。
  コネクタの中の長さも含めて 7 cm にする。図は速度係数を 0.66 にそろえて描いた
- R1 は校正キットの Load (50 Ω)

## 掃引の設定

計器は VNA。この題は NanoVNA-H4 と V2 (どちらも歴史的な機種) の範囲を比べる。標準の LiteVNA64 なら範囲を 1.5 GHz と 3 GHz にして同じ比べができる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — ケーブルをつないで測る題で、組む回路が無い。

| 項目 | 図2 (H4 の範囲) | 図3 (V2 の範囲) |
| --- | --- | --- |
| 範囲 | 1 MHz〜1.5 GHz | 1 MHz〜3 GHz |
| 点数 | 401 | 401 |
| 校正 | SOLT。TL1 の根元 (CH0 の SMA) で、それぞれの範囲で | 同左 |
| 表示 | S11 の TDR (速度係数 0.66) と Log Mag | 同左 |

H4 の範囲 (見えるはずの画面、理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-1.5G 401
title: 図2 H4 (1.5 GHz まで) — 7 cm 離れた 2 つの反射が 1 つの山 (1.031 m)
dut:
  - line 50 1m vf 0.66
  - line 75 7cm vf 0.66
  - series R 50
  - short
traces:
  - S11 tdr vf 0.66
  - S11 logmag
markers:
  - 500M
  - 1G
  - 1.5G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/20-tdr-resolution-1.svg)

V2 の範囲。ケーブルとマーカーは図2 と同じで、範囲だけを 3 GHz に広げた。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 1M-3G 401
title: 図3 V2 (3 GHz まで) — 同じ 2 つの反射が 0.99 m と 1.07 m に分かれる
dut:
  - line 50 1m vf 0.66
  - line 75 7cm vf 0.66
  - series R 50
  - short
traces:
  - S11 tdr vf 0.66
  - S11 logmag
markers:
  - 500M
  - 1G
  - 1.5G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/20-tdr-resolution-2.svg)

## 見るべき値

計算値 (理想の模型)。

| 項目 | 図2 (H4) | 図3 (V2) |
| --- | --- | --- |
| TDR の山 | **1 つ** (1.031 m、高さ 0.32) | **2 つ** (0.992 m と、図から読んで 1.07 m ほど。高さ 0.19 ずつ、間の谷は 0.05) |
| S11 (500 MHz) | −9.12 dB | −9.12 dB |
| S11 (1 GHz) | −10.05 dB | −10.05 dB |
| S11 (1.5 GHz) | −21.99 dB | −21.99 dB |

- 周波数の Log Mag は、同じ周波数なら機種によらず同じ値 (同じケーブルだから)。違うのは **TDR だけ**
- 図2 の 1 つの山は、位置 (1.031 m) が 2 つの反射の間、高さ (0.32) は |Γ| = 0.2 のどちらとも違う。
  **融けた山を 1 つの反射として読むと、場所も大きさも読み違える**。山の幅が他の山 (5-1 の開放の先など) より
  太ければ、融けている疑いがある
- 図3 の 2 つの山の間隔は図から読んで 0.07〜0.08 m で、7 cm に合う (時間の点の刻みで少しずれる)。75 Ω の線の
  **長さ**が TDR から読める
- S11 は 1.41 GHz (75 Ω の 7 cm が λ (ラムダ)/2 になる所) で谷になる。λ/2 の線は両端の Z が同じに見えるから (5-16 と同じ)
- 分解能を上げる代わりに、見える距離の上限は 26.4 m から 13.2 m に縮む (点数が同じなら Δf が倍)。
  長いケーブルの遠くを見るなら点数を増やす (2-7)
- LiteVNA64 で 6.3 GHz まで掃くと、分解能の目安は 0.016 m (1.6 cm)。コネクタ 1 つの中の段差まで分かれて見えてくる

## LTspice での確かめ

`sim/20-tdr-resolution.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源、先は 50 Ω の Load、損失の無い T 素子)。理想の模型どうしの比べで、実測ではない。図2 と図3 は同じ `dut:` なので、1 つの回路で両方を確かめた。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図2・図3 | 500 MHz | S11 | −9.12 dB | −9.12 dB | 合う |
| 図2・図3 | 1 GHz | S11 | −10.05 dB | −10.05 dB | 合う |
| 図2・図3 | 1.5 GHz | S11 | −21.99 dB | −21.99 dB | 合う |

.meas は \|S11\| を線形で出すので (0.350・0.314・0.0795)、20 log₁₀ で dB に直した。

TDR の山は AC 解析では出ないので、算術で確かめた。2 つの反射の往復の時間の差は 2 × 0.07 / (0.66 × 2.998 × 10⁸) = 0.71 ns。
H4 の範囲 (1.499 GHz) の逆数 0.67 ns と同じくらいで、窓で広がった山 (その 2 倍ほど) の中に 2 つが入るので融ける。
V2 の範囲 (2.999 GHz) なら逆数 0.33 ns で、窓で広がっても 0.71 ns の間に谷ができる。分解能の表の値は VF × c / (2 × 範囲) の算術。

## 出典

自作。

参考: [Wikipedia "Time-domain reflectometer"](https://en.wikipedia.org/wiki/Time-domain_reflectometer)、[Wikipedia "Window function"](https://en.wikipedia.org/wiki/Window_function)
