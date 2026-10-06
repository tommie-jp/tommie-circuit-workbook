---
book: nanovna
chapter: 12
id: 12-3
title: Γ の円と SWR — 負荷の SWR は中心からの距離、線路を足すと円を回る
tier: 100
source: 自作
board: BB
device: LV64
---

# 12-3 Γ の円と SWR — 負荷の SWR は中心からの距離、線路を足すと円を回る

Smith チャートの**中心からの距離は |Γ| (ガンマ)** で、SWR = (1 + |Γ|) / (1 − |Γ|) に 1 対 1 で対応する。つまり**中心を中心とした円の上の点は、どこでも SWR が同じ**。
この題では、負荷の手前に 50 Ω (オーム) の線路を足して、**線路を長くしても SWR はほぼ変わらず、点が円の上を回るだけ**になることを見る。
アンテナの SWR をケーブルの先 (計器の側) で測っても、アンテナの根元で測っても、損失が小さければ同じになる理由だ。

線路は同軸ケーブルではなく、**コイルとコンデンサをはしごに並べた擬似線路** (人工線路) で作る。
3 MHz で半波長になる同軸 (短縮率 0.66) は約 33 m もあって手元で扱えないが、擬似線路ならブレッドボードに収まる。
コイル 2.2 µH (マイクロヘンリー) とコンデンサ 820 pF の 1 段は、**特性インピーダンス √(L / C) ≈ 51.8 Ω、遅れ √(LC) ≈ 42.5 ns** の短い線路と同じに働く。
4 段で 170 ns の遅れになり、**約 34 m の同軸と同じ長さ**になる。

> **この章の図は理想の模型から計算した画面で、実機では測っていない。** 擬似線路は部品の損失を入れていないので、実物では円が少しずつ中心へ巻き込む。

## 円と SWR の関係

| \|Γ\| | SWR | 反射電力 |
| --- | --- | --- |
| 0 | 1.00 | 0 % |
| 0.1 | 1.22 | 1 % |
| 0.333 | 2.00 | 11 % |
| 0.5 | 3.00 | 25 % |
| 0.6 | 4.00 | 36 % |
| 1 | ∞ | 100 % |

- 外周は SWR = ∞。中心へ近づくほど SWR は小さく、**中心は 1**
- 例えば 100 Ω の負荷 (z = 2) は、中心から右へ 1/3 の所。SWR = 2。同じ距離で反対側の 25 Ω (z = 0.5) も SWR = 2
- **SWR の円が実軸の右半分と交わる所の r の値が、SWR そのもの**になる (SWR = 2 の円は r = 2 を通り、反対側で r = 0.5 を通る)

## 擬似線路の回路図

```circuit
title: 図1 4 段の擬似線路と 100 Ω
parts:
  J1: sma c2 mirror
  G0: ground d2
  C1: capacitor c5 e5 390p
  L1: inductor c5 c9 2.2u
  C2: capacitor c9 e9 820p
  L2: inductor c9 c13 2.2u
  C3: capacitor c13 e13 820p
  L3: inductor c13 c17 2.2u
  C4: capacitor c17 e17 820p
  L4: inductor c17 c21 2.2u
  C5: capacitor c21 e21 390p
  R1: resistor c25 e25 100
  G1: ground e13
wires:
  - J1.1 -- c5
  - J1.2 -- d2
  - e5 -- e9
  - e9 -- e13
  - e13 -- e17
  - e17 -- e21
  - c21 -- c25
  - e21 -- e25
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/03-swr-circle-1.svg)

- 1 段は **直列のコイル L (2.2 µH) と、GND へのコンデンサ C (820 pF)**。両端の C1 と C5 は半分の値 (390 pF、E12) にする (π (パイ) 形の段を 4 つつないだ形で、両端の段の C が隣と共有されない)
- 部品の値は E12。√(2.2 µH / 820 pF) = 51.8 Ω で、50 Ω の線路の代わりになる
- 擬似線路は **約 7.5 MHz より上の周波数を通さない** (カットオフ 1 / (π√(LC)))。3 MHz までなら線路として働くが、周波数が上がるほど特性インピーダンスがずれ、SWR が少し動く (下の表)

## 実体配線図

```breadboard
title: 図2 4 段の擬似線路と 100 Ω をブレッドボードで組む (図3・図8)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  C1: capacitor/ceramic a6 -t6 390p
  L1: inductor c6 c11 2.2u
  C2: capacitor/ceramic a11 -t11 820p
  L2: inductor d11 d16 2.2u
  C3: capacitor/ceramic a16 -t16 820p
  L3: inductor c16 c21 2.2u
  C4: capacitor/ceramic a21 -t21 820p
  L4: inductor d21 d26 2.2u
  C5: capacitor/ceramic a26 -t26 390p
  R1: resistor b26 b29 100
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e6 orange
  - -t29 -- a29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/03-swr-circle-1.svg)

- 6 列目が入口。**コイル L1〜L4 が 6 → 11 → 16 → 21 → 26 列目と横に渡り、各列のコンデンサ C1〜C5 が上の − レール (GND) へ**下りる。コイルは 1 つおきに c と d の行に挿す (同じ穴に 2 本挿さないため)
- 負荷の R1 (100 Ω) は 26 列目から 29 列目へ渡し、29 列目から黒い線で GND へ。**図 8 (先が開放) は R1 を抜くだけ**
- 上の − レールが GND で、黒い線で VNA の GND へつなぐ。オレンジの線が VNA の RF で、6 列目の e の行へ
- コイルは軸付きの小さなインダクタ (2.2 µH)、コンデンサはセラミック (820 pF・390 pF、C0G がよい)。段の値がそろっているほど、円がきれいに回る
- 周波数は 3 MHz まで。ブレッドボードの浮遊容量 (約 2.5 pF) は 820 pF に比べて小さく、線路の値をほとんど変えない

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜3 MHz |
| 点数 | 201 (円が滑らかになる点数) |
| 校正 | SOLT (1-1)。**校正の基準面は SMA ケーブルの先**。そこから先の擬似線路と負荷が測る物 |
| 表示 | S11 の Smith チャートと SWR |

## 100 Ω の手前の線路で円を回る

4 段の擬似線路の先に 100 Ω を付けた負荷。**半波長 (約 2.92 MHz) で 1 周**する。SWR の線は、どの周波数でも 2.0 の近く (1.8〜2.0) にとどまる。

```vna
sweep: 50k-3M 201
title: 図3 4 段の擬似線路と 100 Ω — 円を 1 周、SWR はほぼ 2 のまま
dut:
  - shunt C 390p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 390p
  - series R 100
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 780k
  - 1.47M
  - 2.92M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/03-swr-circle-1.svg)

- **λ (ラムダ)/4 の 1.47 MHz では、点は中心の反対側** (100 Ω → 27.9 Ω)。λ/4 の線は z を **1/z** に変える。z = 2 が z ≈ 0.5 へ
  (理想の線路なら 25 Ω。擬似線路はこの周波数で特性インピーダンスが 52.8 Ω に上がるので、52.8² / 100 = 27.9 Ω になる)
- λ/2 の 2.92 MHz で元の位置 (100 Ω) へ戻る。**λ/2 の線は、負荷をそのまま見せる**
- 円の半径 (SWR) はほとんど変わらない。**SWR は負荷で決まり、線路の長さでは変わらない** (損失の無い理想の線路なら完全に一定。擬似線路は 1.79〜2.00 の間で少し動く)

## 線路を 2 倍の長さにする

同じ負荷で擬似線路を 8 段にすると、**同じ円を 2 周**する (半波長が約 1.47 MHz に縮むため)。

```circuit
title: 図4 8 段の擬似線路と 100 Ω
parts:
  J1: sma c2 mirror
  G0: ground d2
  C1: capacitor c5 e5 390p
  L1: inductor c5 c9 2.2u
  C2: capacitor c9 e9 820p
  L2: inductor c9 c13 2.2u
  C3: capacitor c13 e13 820p
  L3: inductor c13 c17 2.2u
  C4: capacitor c17 e17 820p
  L4: inductor c17 c21 2.2u
  C5: capacitor c21 e21 820p
  L5: inductor c21 c25 2.2u
  C6: capacitor c25 e25 820p
  L6: inductor c25 c29 2.2u
  C7: capacitor c29 e29 820p
  L7: inductor c29 c33 2.2u
  C8: capacitor c33 e33 820p
  L8: inductor c33 c37 2.2u
  C9: capacitor c37 e37 390p
  R1: resistor c41 e41 100
  G1: ground e13
wires:
  - J1.1 -- c5
  - J1.2 -- d2
  - e5 -- e9
  - e9 -- e13
  - e13 -- e17
  - e17 -- e21
  - e21 -- e25
  - e25 -- e29
  - e29 -- e33
  - e33 -- e37
  - c37 -- c41
  - e37 -- e41
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/03-swr-circle-2.svg)

```breadboard
title: 図5 8 段の擬似線路と 100 Ω (full のブレッドボード)
board: full
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  C1: capacitor/ceramic a6 -t6 390p
  L1: inductor c6 c11 2.2u
  C2: capacitor/ceramic a11 -t11 820p
  L2: inductor d11 d16 2.2u
  C3: capacitor/ceramic a16 -t16 820p
  L3: inductor c16 c21 2.2u
  C4: capacitor/ceramic a21 -t21 820p
  L4: inductor d21 d26 2.2u
  C5: capacitor/ceramic a26 -t26 820p
  L5: inductor c26 c31 2.2u
  C6: capacitor/ceramic a31 -t31 820p
  L6: inductor d31 d36 2.2u
  C7: capacitor/ceramic a36 -t36 820p
  L7: inductor c36 c41 2.2u
  C8: capacitor/ceramic a41 -t41 820p
  L8: inductor d41 d46 2.2u
  C9: capacitor/ceramic a46 -t46 390p
  R1: resistor b46 b49 100
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e6 orange
  - -t49 -- a49 black
  - -t32 -- -t35 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/03-swr-circle-2.svg)

- 8 段は half (30 列) に収まらないので、**full (63 列) のブレッドボード**に組む。並べ方は図 2 と同じで、コイルが 6 → 11 → … → 46 列目と渡り、R1 (100 Ω) は 46 列目から 49 列目へ
- 段のつなぎ目の C は 820 pF、両端 (6 列目と 46 列目) だけ 390 pF
- full のブレッドボードは、レールが中央で左右に切れている物がある。この図は上の − レールの 1〜49 列目を使うので、**中央 (32 列目と 35 列目の間) を黒い線でまたいでおく** (切れていない物なら無くてもよい)

```vna
sweep: 50k-3M 201
title: 図6 8 段の擬似線路と 100 Ω — 同じ円を 2 周
dut:
  - shunt C 390p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 390p
  - series R 100
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 740k
  - 1.47M
  - 2.18M
  - 2.89M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/03-swr-circle-2.svg)

## 先が開放の線路

4 段の擬似線路の先を開放する (図 2 の R1 を抜く)。|Γ| = 1 なので、**外周そのものを回る** (SWR ∞)。λ/4 (1.47 MHz) で左端 (短絡と同じ) になる。

```circuit
title: 図7 4 段の擬似線路の先を開放
parts:
  J1: sma c2 mirror
  G0: ground d2
  C1: capacitor c5 e5 390p
  L1: inductor c5 c9 2.2u
  C2: capacitor c9 e9 820p
  L2: inductor c9 c13 2.2u
  C3: capacitor c13 e13 820p
  L3: inductor c13 c17 2.2u
  C4: capacitor c17 e17 820p
  L4: inductor c17 c21 2.2u
  C5: capacitor c21 e21 390p
  G1: ground e13
wires:
  - J1.1 -- c5
  - J1.2 -- d2
  - e5 -- e9
  - e9 -- e13
  - e13 -- e17
  - e17 -- e21
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/03-swr-circle-3.svg)

```vna
sweep: 50k-3M 201
title: 図8 4 段の擬似線路の先を開放 — 外周を 1 周
dut:
  - shunt C 390p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 820p
  - series L 2.2u
  - shunt C 390p
  - open
traces:
  - S11 smith
markers:
  - 780k
  - 1.47M
  - 2.92M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/03-swr-circle-3.svg)

- 先が開放の線路が、λ/4 で**短絡に見える** (Smith の右端が左端に移る) のは、線路の電気的な長さを測る手がかりになる (第 5 章)
- 先を短絡した場合は逆で、λ/4 で開放 (右端) に見える

## 見るべき値

計算値 (4 段の擬似線路、2.2 µH・820 pF、両端 390 pF、負荷 100 Ω)。

| 周波数 | 位置 | Zin | SWR |
| --- | --- | --- | --- |
| 780 kHz (λ/8) | 下の弧 | 41.0 − j28.3 Ω | 1.91 |
| 1.47 MHz (λ/4) | 中心の左 | 27.9 Ω | 1.79 |
| 2.92 MHz (λ/2) | 中心の右 | 100 Ω | 2.00 |

- 先を開放した線路は、780 kHz で −j47.9 Ω (外周の下、コンデンサに見える)、1.47 MHz で 0 Ω (左端)、2.92 MHz で −j3.0 kΩ (右端のすぐ手前) になる
- 8 段 (図 6) は 740 kHz で 27.1 Ω (λ/4)、1.47 MHz で 100 Ω (λ/2)。**段を 2 倍にすると、同じ点に来る周波数が半分**になる

## 出典

自作。λ/4 の線による変換 (Zin = Z0² / ZL) と、LC のはしごによる擬似線路 (定 K 形の π 形の段) は、伝送線路とフィルタの教科書に共通する内容による。
