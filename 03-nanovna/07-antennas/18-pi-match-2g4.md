---
book: nanovna
chapter: 7
id: 7-18
title: 2.4 GHz の整合 (π ネットワーク、チップ部品)
tier: 200
source: 自作
board: CB
device: V2
---

# 7-18 2.4 GHz の整合 (π ネットワーク、チップ部品)

2.4 GHz の無線の基板では、チップアンテナの手前に**部品の足場が 3 つ** (並列・直列・並列。π (パイ) の形) 並んでいることが多い。
基板を作った時点では、直列の足場に 0 Ω、並列の 2 つは空き (DNP = 載せない) にしておき、
組み上がった基板で VNA を当てて、アンテナの Z を見てから部品の値を決める。アンテナの Z は
基板の形・ケース・電池の位置で変わり、作る前には決まらないからである。

この題では、7-4 の L 型整合の考え方を 2.4 GHz のチップ部品 (1608 サイズ) でやる。式で出した値を載せても
合わず、**C1 と L2 の間の 2 mm の線路**まで効くことを画面で確かめ、測りながら値を詰める。

## 手順の考え方

1. 直列の足場 (L2) に 0 Ω を載せ、並列 (C1・C3) は空きのまま、アンテナの Z を測る
2. 基準面を C1 の位置へ動かす (ポート延長、1-10)。SMA から C1 までの 50 Ω の線路の分だけ、
   Smith チャートの点を戻す
3. Z を見て、L 型 (並列 1 つ・直列 1 つ) を決める。R が 50 Ω より低いので、7-4 と同じく
   **直列をアンテナ側、並列を 50 Ω 側** (C1) に置く。C3 は使わない (π の 3 つ目は、別の Z のときのための予備)
4. 式の値を最寄りの部品に丸めて載せ、測り、ずれた分を 1 段ずつ値を替えて詰める

## この実験で確かめる式

アンテナの Z = R<sub>L</sub> + jX<sub>L</sub> (R<sub>L</sub> < 50 Ω)、ω = 2π × 2.44 GHz。

| 式 | 値 (R<sub>L</sub> = 15 Ω、X<sub>L</sub> = −10 Ω) |
| --- | --- |
| 直列を足した後のリアクタンス **X = √(R<sub>L</sub> × 50 − R<sub>L</sub>²)** | 22.9 Ω |
| 直列の L **L2 = (X − X<sub>L</sub>) / ω** | 2.15 nH → 2.2 nH |
| 並列の C **C1 = X / (R<sub>L</sub>² + X²) / ω** | 1.99 pF → 2.0 pF (E24) |
| 2 mm の線路の電気長 **βl = 2π f l / (v<sub>f</sub> c)** | 10.7° (v<sub>f</sub> = 0.55、マイクロストリップ) |

線路の 10.7° は小さく見えるが、R<sub>L</sub> = 15 Ω のように 50 Ω から遠い Z は、Smith チャートの上で回る量が大きく、
整合がずれる。部品は**できるだけ詰めて置き**、それでも残る分は測って詰める。

## 回路図

アンテナは、基準面 (C1 の位置) から 2 mm 先の L2 の右で見た Z を、直列 RLC の**等価回路**で表す
(アンテナまでの 17.5 mm の線路も含めた値)。C1 と L2 の間の 2 mm を線路 T1 で描いた。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 パイ形の足場 (C1・L2・C3) とチップアンテナ (等価回路)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 l=$C_1$
  T1: tline 5,2 7,2 50 l=$\mathrm{2mm}$
  L2: inductor 8,2 10,2 l=$L_2$
  C3: capacitor 11,2 11,4 DNP
  R1: resistor 12,2 14,2 15
  L3: inductor 14,2 16,2 3n
  C4: capacitor 16,2 18,2 1.165p
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 11,4
  G4: ground 18,3
wires:
  - J1.1 -- 4,2
  - 4,2 -- 5,2
  - 7,2 -- 8,2
  - 10,2 -- 11,2
  - 11,2 -- 12,2
  - 18,2 -- 18,3
  - J1.2 -- 2,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/circuit/18-pi-match-2g4.svg)

| 状態 | C1 | L2 | C3 |
| --- | --- | --- | --- |
| 整合なし (作ったまま) | 空き | 0 Ω | 空き |
| 式どおり | 2.0 pF | 2.2 nH | 空き |
| 測って詰めた後 | 1.8 pF | 1.5 nH | 空き |

R1・L3・C4 は**等価回路**の値 (目安): 2440 MHz で 15 − j10.0 Ω (チップアンテナの共振は 2.69 GHz、高めに出た例)。
チップの L・C の寄生分 (1608 の L の自己共振は数 GHz、C の ESL は約 0.5 nH、目安) は模型に入れていない。
これも測って詰める理由の 1 つ。

## 実体配線図

5×7 cm の両面の FR4 (厚さ 1.6 mm) から 50 mm × 30 mm を切り出し、表を剥がして線と島を残す。
右の 12 mm (チップアンテナの下と先) は**裏の地も剥がす** (破線の枠)。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 50x30mm
  ground: back
title: 図2 π の足場とチップアンテナ (2.44 GHz、詰めた後の値)
f: 2.44G
copper:
  L1: line 0,15 38.5,15 3.06mm
  GA: pad 19,11.5 1.6x1.6mm
  VA: via 19,11.4 0.6mm
  GB: pad 27,18.5 1.6x1.6mm
  VB: via 27,18.6 0.6mm
  PA: pad 45,15 2x2mm
  X1: slot 44,15 12x30mm
parts:
  J1: sma left 15 CH0
  C1: capacitor/1608 19,12.9 r90 1.8p
  L2: inductor/1608 21,15 1.5n
  C3: capacitor/1608 27,17.1 r90 DNP
  ANT: box 41.5,15 6x2mm 2 2.4G
notes:
  - dim 19,7 21,7
  - dim 21,24 38.5,24
  - text 39,4: 裏の地を剥がす
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/copper/18-pi-match-2g4.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 線 (L1) | 幅 3.06 mm (50 Ω の計算値)。左の SMA から 38.5 mm |
| C1 (並列) | 1608。SMA から 19 mm の所で、線の上の縁と GND の島 (GA、1.6 mm 角、0.6 mm の穴で裏へ) を跨ぐ |
| L2 (直列) | 1608。C1 から 2 mm 右。線を 0.8 mm 切って跨ぐ (最初は 0 Ω を載せる) |
| C3 (並列、空き) | 1608 の足場。L2 から 6 mm 右で、線の下の縁と GND の島 (GB) の間。この題では載せない |
| チップアンテナ (ANT) | 2.4 GHz 用の 2 端子のチップ (6 mm × 2 mm の例)。左の端子を線の先へ、右の端子を固定用の島 (PA) へ。向きと島はデータシートに従う |

- GND の島 (1.6 mm) と穴 (0.6 mm) は 3 mm より小さい。1608 の部品の大きさに合わせたため。カッターで切れる大きさの下限に近いので、
  切ったら島と線が短絡していないかテスターで確かめる
- FR4 は 1 GHz を超えると損失が効く。整合の位置と値は、この基板で測って決めるので FR4 のまま使う
- C1・L2 を半田付けしたら、毎回測る。半田の量でも 0.1 pF ほど変わる (目安)

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 2.0 GHz〜3.0 GHz |
| 点数 | 201 (5 MHz おき) |
| 校正 | SOLT (ケーブルの先の SMA で)。そのあと**ポート延長で基準面を C1 の位置へ** (SMA から 19 mm、速度係数 0.55 で約 115 ps。1-10) |
| 表示 | S11 の SWR、Smith チャート |

- 基板とアンテナを手で持たない。ケーブルの根元を机の端から出して浮かせる (7-11・9-5)
- **電波が出る**: 掃引は測る間だけにする (7-12・7-13 と同じ)

**整合なし** (L2 = 0 Ω) の**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 2G-3G 201
title: 図3 整合なし — 2.44 GHz で 14.4 Ω、SWR 3.48
dut:
  - line 50 2mm vf 0.55
  - series R 15
  - series L 3n
  - series C 1.165p
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 2402M
  - 2440M
  - 2480M
notes:
  - band 2400M 2483.5M: 2.4 GHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/18-pi-match-2g4-1.svg)

**式どおりの値** (C1 = 2.0 pF、L2 = 2.2 nH) を載せたときの**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 2G-3G 201
title: 図4 式どおり — 谷が 2.28 GHz、2.44 GHz で SWR 2.13
dut:
  - shunt C 2.0p
  - line 50 2mm vf 0.55
  - series L 2.2n
  - series R 15
  - series L 3n
  - series C 1.165p
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 2402M
  - 2440M
  - 2480M
notes:
  - band 2400M 2483.5M: 2.4 GHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/18-pi-match-2g4-2.svg)

**測って詰めた値** (C1 = 1.8 pF、L2 = 1.5 nH) の**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 2G-3G 201
title: 図5 詰めた後 (1.8 pF・1.5 nH) — 帯域で SWR 1.25 以下
dut:
  - shunt C 1.8p
  - line 50 2mm vf 0.55
  - series L 1.5n
  - series R 15
  - series L 3n
  - series C 1.165p
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 2402M
  - 2440M
  - 2480M
notes:
  - band 2400M 2483.5M: 2.4 GHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/18-pi-match-2g4-3.svg)

- 図3 は帯域の中で SWR 3.4〜3.5 とほぼ平ら。Smith チャートの点は左寄り (R が低い) で、実軸の近く
- 図4 は谷が帯域の左の外 (2275 MHz) に出て、2.44 GHz で SWR 2.13。2 mm の線路と L2 が同じ向き (誘導性) に回すので、
  式の L2 では**回しすぎ**になる。Smith チャートの点が中心を越えて下側 (容量性の側) に出ているのがその印
- 図5 は L2 を 2.2 → 1.8 → 1.5 nH と 1 段ずつ下げ、C1 も 1 段下げた結果。谷は 2458 MHz に来て、点は中心のすぐ近くを通る

## 見るべき値

計算値 (等価回路。チップの寄生分は入れていない)。

| 状態 | 2402 MHz | 2440 MHz | 2480 MHz | SWR 2 以下の幅 |
| --- | --- | --- | --- | --- |
| 整合なし (図3) | 14.2 − j3.0 Ω、SWR 3.53 | 14.4 − j1.4 Ω、SWR 3.48 | 14.6 + j0.4 Ω、SWR 3.43 | 無し |
| 式どおり (図4) | 60.0 − j30.9 Ω、SWR 1.79 | 55.9 − j40.5 Ω、SWR 2.13 | 48.9 − j47.8 Ω、SWR 2.54 | 2118〜2426 MHz |
| 詰めた後 (図5) | 40.8 + j3.5 Ω、SWR 1.24 | 46.8 + j1.2 Ω、SWR 1.07 | 53.2 − j3.3 Ω、SWR 1.09 | 2275〜2633 MHz (358 MHz) |

- SWR 3.48 では反射で 31 % (1.6 dB) を失う。詰めた後は 0.2 % (0.01 dB)。**送る電力も受ける感度も 1.6 dB 戻る** (計算値)
- 式どおりの値が合わないのは、式が**部品どうしの間を 0 mm** として出しているから。2.4 GHz では 2 mm で 10.7° 回る。
  線路の長さまで入れて計算し直すこともできるが、寄生分と半田の分は測るまで分からないので、**最後は VNA を見ながら 1 段ずつ**替える
- どちらの値をどちら向きに替えるかは、Smith チャートの点の動きで決める。直列は R の円、並列は G の円の上を動く (12-5)。
  L 形を Smith チャートの上で作る手順は 12-6

## LTspice での確かめ

`sim/18-pi-match-2g4.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源。2 mm の線路は損失の無い T 素子で
Td = 0.002 / (0.55 × 299792458) = 12.13 ps。コイルの直列抵抗は 1 µΩ に固定)。CH0 の電圧から |Γ| = |2·V − 1| と
R = Re(50·V / (1 − V)) を `.meas` で読んだ。理想の模型どうしの比べで、実測ではない。式の値 (2.15 nH・1.99 pF・10.7°) は算術による。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 2402 MHz | SWR | 3.53 | 3.529 | 合う |
| 図3 | 2440 MHz | SWR / R | 3.48 / 14.4 Ω | 3.479 / 14.38 Ω | 合う |
| 図3 | 2480 MHz | SWR | 3.43 | 3.435 | 合う |
| 図4 | 2402 MHz | SWR | 1.79 | 1.793 | 合う |
| 図4 | 2440 MHz | SWR / R | 2.13 / 55.9 Ω | 2.128 / 55.92 Ω | 合う |
| 図4 | 2480 MHz | SWR | 2.54 | 2.539 | 合う |
| 図5 | 2402 MHz | SWR | 1.24 | 1.244 | 合う |
| 図5 | 2440 MHz | SWR / R | 1.07 / 46.8 Ω | 1.074 / 46.78 Ω | 合う |
| 図5 | 2480 MHz | SWR | 1.09 | 1.093 | 合う |

## 出典

自作。L 型整合の式は 7-4 と同じ (標準的なインピーダンス整合の式)。π の足場を置いて基板ができてから値を決めるやり方は、
2.4 GHz のモジュールやチップアンテナの応用資料で広く使われている手順を、自分の言葉でまとめた。

参考: [インピーダンス整合 (Wikipedia)](https://ja.wikipedia.org/wiki/%E3%82%A4%E3%83%B3%E3%83%94%E3%83%BC%E3%83%80%E3%83%B3%E3%82%B9%E6%95%B4%E5%90%88)、[Pi network (Wikipedia)](https://en.wikipedia.org/wiki/Pi_network)、[TI Application Note AN043 Small Size 2.4 GHz PCB antenna](https://www.ti.com/lit/an/swra117d/swra117d.pdf)
