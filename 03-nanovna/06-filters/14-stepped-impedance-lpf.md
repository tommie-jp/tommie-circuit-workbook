---
book: nanovna
chapter: 6
id: 6-14
title: マイクロストリップ LPF (ステップインピーダンス、1 GHz)
tier: 200
source: 自作
board: CB
device: H4
---

# 6-14 マイクロストリップ LPF (ステップインピーダンス、1 GHz)

カットオフ 1 GHz の LC ローパスは、部品の値が 2 pF・13 nH ほどになる。この大きさでは
チップ部品の寄生分と配線の長さが値そのものと同じくらい効き、設計どおりに組めない。
そこで**部品を使わず、線路の太さだけでフィルタを作る**。細い線 (高い Z0) の短い区間は直列の L、
太い線 (低い Z0) の短い区間は GND への C として働く。これが**ステップインピーダンス**のローパス。
銅張り基板に彫り、H4 で 1.5 GHz まで測る。線路のフィルタには LC に無い**通り抜け**があることも、計算で見る。

## この実験で確かめる式

もとにするのは 5 次バターワース (6-1 と同じ最平坦) の LC で、g 値は g1 = g5 = 0.618、g2 = g4 = 1.618、g3 = 2.000。
カットオフ 1 GHz・Z0 = 50 Ω (オーム) なら C1 = C5 = 1.97 pF、L2 = L4 = 12.9 nH、C3 = 6.37 pF (C = g / (2π (パイ) f<sub>c</sub> Z0)、L = g Z0 / (2π f<sub>c</sub>))。

線路の区間の電気長 βl (β (ベータ) は位相定数、l は長さ) は、区間が短い (βl < 45° くらい) ときの近似で

- L の区間 (Z<sub>h</sub> = 100 Ω): **βl = g × Z0 / Z<sub>h</sub>**
- C の区間 (Z<sub>l</sub> = 20 Ω): **βl = g × Z<sub>l</sub> / Z0**

長さは l = βl / (2π) × λ<sub>g</sub> (λ (ラムダ)<sub>g</sub> は線路の上の波長)、λ<sub>g</sub> = v<sub>f</sub> × c / f (v<sub>f</sub> は 1/√ε<sub>eff</sub>。ε (イプシロン)<sub>eff</sub> は実効比誘電率)。厚さ 1.6 mm・比誘電率 4.4 の FR4 で
(Z0 と ε<sub>eff</sub> は Hammerstad の式。計算値):

| 区間 | 働き | Z0 | 幅 | v<sub>f</sub> | 1 GHz の電気長 | 長さ |
| --- | --- | --- | --- | --- | --- | --- |
| C1・C5 | 1.97 pF | 20 Ω | 11.11 mm | 0.517 | 13.9° | 6.0 mm |
| L2・L4 | 12.9 nH | 99.7 Ω | 0.71 mm | 0.574 | 45.6° | 21.8 mm |
| C3 | 6.37 pF | 20 Ω | 11.11 mm | 0.517 | 45.1° | 19.4 mm |
| T1・T2 (つなぎ) | — | 49.9 Ω | 3.07 mm | 0.548 | 17.5° | 8.0 mm |

近似のずれを、長さを 1.7 % 縮めて合わせた (線路の模型で −3 dB が 1.00 GHz に来る長さ)。

## 回路図

もとの LC。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 もとの LC (5 次バターワース、1 GHz)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 1.97p
  L2: inductor 5,2 7,2 12.9n
  C3: capacitor 8,2 8,4 6.37p
  L4: inductor 9,2 11,2 12.9n
  C5: capacitor 12,2 12,4 1.97p
  J2: sma 14,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 8,4
  G4: ground 12,4
  G5: ground 14,3
wires:
  - J1.1 -- 4,2 -- 5,2
  - 7,2 -- 8,2 -- 9,2
  - 11,2 -- 12,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/14-stepped-impedance-lpf-1.svg)

基板に彫る物は、Z0 の違う線路 7 本をつないだだけ。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 ステップインピーダンスのローパス (線路 7 本の縦続)
parts:
  J1: sma 2,2 mirror CH0
  TA: tline 3,2 5,2 49.9 l=$\mathrm{T1}$
  TB: tline 5,2 7,2 20 l=$\mathrm{C1}$
  TC: tline 7,2 9,2 99.7 l=$\mathrm{L2}$
  TD: tline 9,2 11,2 20 l=$\mathrm{C3}$
  TE: tline 11,2 13,2 99.7 l=$\mathrm{L4}$
  TF: tline 13,2 15,2 20 l=$\mathrm{C5}$
  TG: tline 15,2 17,2 49.9 l=$\mathrm{T2}$
  J2: sma 18,2 CH1
  G1: ground 2,3
  G2: ground 18,3
wires:
  - J1.1 -- 3,2
  - 17,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 18,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/14-stepped-impedance-lpf-2.svg)

- 線路の名前は図3 の銅の名前と同じ。図1 の C1 は図2 の C1 の区間になる

## 実体配線図

1 GHz は perfboard の目安 (300 MHz) を超え、Z0 の決まった線路が要るので、銅張り基板に彫る。
両面の FR4 (1.6 mm、比誘電率 4.4) で、裏は全面の銅 (GND)。長さが 91 mm あるので、7×10 cm の基板から 91 mm × 30 mm を切り出す。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 91x30mm
  ground: back
title: 図3 ステップインピーダンスのローパス (マイクロストリップ)
copper:
  T1: line 0,15 8,15 3.07mm
  C1: line 8,15 14,15 11.11mm
  L2: line 14,15 35.8,15 0.71mm
  C3: line 35.8,15 55.2,15 11.11mm
  L4: line 55.2,15 77,15 0.71mm
  C5: line 77,15 83,15 11.11mm
  T2: line 83,15 91,15 3.07mm
parts:
  J1: sma left 15 CH0
  J2: sma right 15 CH1
notes:
  - dim 8,33 14,33
  - dim 14,33 35.8,33
  - dim 35.8,33 55.2,33
  - dim 55.2,33 77,33
  - dim 77,33 83,33
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/copper/14-stepped-impedance-lpf.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 表の銅 | 線路だけを残して剥がす。線路の幅は図のラベル、長さは図の下の寸法線 |
| L2・L4 の線 | 幅 0.71 mm (100 Ω)。3 mm より細いのは、高い Z0 が L の働きを作るため。カッターで 2 本切って残す |
| C1・C3・C5 | 幅 11.11 mm (20 Ω) の四角。線路の中心に揃える |
| 端面 SMA | 左右の縁に 1 つずつ。外皮の脚は縁で裏のベタへ |

- 長さの誤差がそのままカットオフのずれになる。L2・L4 が 1 mm ずつ長いと −3 dB は 2.7 % 下がる (計算値)
- 太さが変わる所 (段差) には、表の模型に入っていない小さな容量が付く。実物のカットオフは
  図より数 % 低く出ることがある (目安)。合わせるなら C3 の四角の両端を少しずつ削る
- 流れるのは NanoVNA の出力 (0 dBm 以下) だけ

## 掃引の設定

計器は VNA。この題の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜1.5 GHz (H4 の上限まで) |
| 点数 | 299 (5 MHz おき) |
| 校正 | SOLT。ケーブルの先で |
| 表示 | S21 と S11 の Log Mag |

模型は図2 と同じ損失の無い線路 7 本 (段差の容量は入れていない)。**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10M-1.5G 299
title: 図4 線路のローパス — 1 GHz で −3 dB、1.5 GHz でも −14 dB
dut:
  - line 49.9 8mm vf 0.548
  - line 20 6mm vf 0.517
  - line 99.7 21.8mm vf 0.574
  - line 20 19.4mm vf 0.517
  - line 99.7 21.8mm vf 0.574
  - line 20 6mm vf 0.517
  - line 49.9 8mm vf 0.548
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 500M
  - 1G
  - 1.2G
  - 1.5G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/14-stepped-impedance-lpf-1.svg)

同じ模型を、LiteVNA64 の範囲で 4 GHz まで見る (H4 では見えない所)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: litevna64
sweep: 10M-4G 400
title: 図5 同じ模型を 4 GHz まで — 3.3 GHz で通り抜ける
dut:
  - line 49.9 8mm vf 0.548
  - line 20 6mm vf 0.517
  - line 99.7 21.8mm vf 0.574
  - line 20 19.4mm vf 0.517
  - line 99.7 21.8mm vf 0.574
  - line 20 6mm vf 0.517
  - line 49.9 8mm vf 0.548
traces:
  - S21 logmag
markers:
  - 1G
  - 2.32G
  - 3.34G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/14-stepped-impedance-lpf-2.svg)

## 見るべき値

計算値 (損失の無い線路の模型)。

| 図 | マーカー | 周波数 | S21 | S11 | 意味 |
| --- | --- | --- | --- | --- | --- |
| 図4 | 1 | 500 MHz | −0.02 dB | −22.49 dB | 通過帯域 |
| 図4 | 2 | 1 GHz | **−2.96 dB** | −3.06 dB | カットオフ |
| 図4 | 3 | 1.2 GHz | −7.47 dB | −0.86 dB | 落ち始め |
| 図4 | 4 | 1.5 GHz | −14.12 dB | −0.17 dB | H4 の上限 |
| 図5 | 2 | 2.32 GHz | −21.83 dB | — | 一番深い所 |
| 図5 | 3 | 3.34 GHz | **−0.01 dB** | — | 通り抜け (阻止帯域が切れる) |

図1 の LC (理想の部品) なら、1.5 GHz で −17.7 dB 落ちる。線路の版は −14.1 dB で、3.6 dB 浅い。

分かること:

- **線路で作ったフィルタは、周波数が上がると別物になる**。区間の電気長は周波数に比例して伸び、
  C の区間 C3 は 3.3 GHz で 150° ほどになって、もう C として働かない。阻止帯域は 2.3 GHz の −22 dB が底で、
  3.3 GHz では 0 dB で通り抜ける。LC の 5 次 (6-1) のように遠くほど深く落ちる形ではない
- 1 GHz の送信機の高調波を落とすなら、2 倍 (2 GHz) は −20.7 dB 落ちるが、3 倍 (3 GHz) は −14.3 dB しか落ちない
  (図5 の線。計算値)。高調波が通り抜けに当たらないかは、**H4 の 1.5 GHz では確かめられない**。V2 か LiteVNA64 で見る
- 実測の S21 は、FR4 の損失で 1 GHz の手前から少し下に出る。カットオフの周波数で比べる

## LTspice での確かめ

`sim/14-stepped-impedance-lpf.cir` で、図の `dut:` の模型 (損失の無い T 素子 7 本) と図1 の LC を LTspice の AC 解析にかけた
(50 Ω の電源と 50 Ω の終端)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図4 | 500 MHz | S21 / S11 | −0.02 dB / −22.49 dB | −0.02 dB / −22.49 dB | 合う |
| 図4 | 1 GHz | 同 | −2.96 dB / −3.06 dB | −2.96 dB / −3.06 dB | 合う |
| 図4 | 1.2 GHz | 同 | −7.47 dB / −0.86 dB | −7.47 dB / −0.86 dB | 合う |
| 図4 | 1.5 GHz | 同 | −14.12 dB / −0.17 dB | −14.12 dB / −0.17 dB | 合う |
| 図5 | 2.32 GHz | S21 | −21.83 dB | −21.83 dB | 合う |
| 図5 | 3.34 GHz | S21 | −0.01 dB | −0.01 dB | 合う |
| 図1 (LC) | 1 GHz / 1.5 GHz | S21 | −3 dB / −17.7 dB | −3.04 dB / −17.74 dB | 合う |

区間の幅と Z0 は、図3 のラベル (copper フェンスの計算) と Hammerstad の式で合った。電気長は 360° × 長さ / (v<sub>f</sub> × c / 1 GHz) の算術。

## 出典

自作。ステップインピーダンスの近似 (βl = gZ0/Z<sub>h</sub>、βl = gZ<sub>l</sub>/Z0) は分布定数フィルタの標準的な設計法による。
[マイクロストリップ](https://en.wikipedia.org/wiki/Microstrip)の Z0 と実効比誘電率は Hammerstad の近似式で計算した。

参考: [Wikipedia "Distributed-element filter"](https://en.wikipedia.org/wiki/Distributed-element_filter)、[Wikipedia「バターワースフィルタ」](https://ja.wikipedia.org/wiki/%E3%83%90%E3%82%BF%E3%83%BC%E3%83%AF%E3%83%BC%E3%82%B9%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF)
