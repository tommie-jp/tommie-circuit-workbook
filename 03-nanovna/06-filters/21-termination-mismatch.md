---
book: nanovna
chapter: 6
id: 6-21
title: 入出力の整合 (50 Ω 以外) がフィルタをどう歪めるか
tier: 200
source: 自作
board: PF
device: H4
---

# 6-21 入出力の整合 (50 Ω 以外) がフィルタをどう歪めるか

LC フィルタの値は、**入口と出口に決まった抵抗 (ここでは 50 Ω) がつながる**ことを前提に
計算してある。前の段の出力インピーダンスや次の段の入力インピーダンスが 50 Ω でなければ、
同じ部品のフィルタでも形が変わる。6-5 のチェビシェフ (0.5 dB) の 5 次ローパスの両端に
抵抗を足し、フィルタから見た相手を **101 Ω** と **25.2 Ω** にして、S21 の形を比べる。

6-12 のセラミックフィルタは、50 Ω の VNA に 330 Ω の部品をつなぐために抵抗を足した。
この題はその逆で、**50 Ω で設計したフィルタを 50 Ω 以外で使うと何が起きるか**を見る。

## この実験で確かめる式

VNA のポートは 50 Ω。その手前に抵抗を足すと、フィルタから見た相手のインピーダンスが変わる。

| 組 | 足す抵抗 | フィルタから見た相手 | 直流の S21 (抵抗で決まる) |
| --- | --- | --- | --- |
| A | なし (R1・R2 は 0 Ω) | 50 Ω | 0 dB |
| B | 直列に 51 Ω (R1・R2) | 50 + 51 = **101 Ω** | 20 log(100 / 202) = −6.11 dB |
| C | 並列に 51 Ω (R3・R4) | 50 ∥ 51 = **25.2 Ω** | −5.94 dB |

抵抗の損失は周波数によらない。だから B と C は、**直流の値からの差**を読めば、
101 Ω と 25.2 Ω で終端したフィルタそのものの形になる。

相手が 50 Ω からずれた量は反射係数 Γ (ガンマ) で表す: 101 Ω なら
Γ = (101 − 50) / (101 + 50) = 0.34、25.2 Ω なら −0.33。0.5 dB のチェビシェフは
通過帯域でもともと |Γ| が 0.33 ほど (S11 が −9.8 dB) 反射しているので、相手の反射と
往復して強め合ったり弱め合ったりし、**通過帯域の波 (リップル) が大きくなる**。
大きさの目安は 1 つの端あたり 20 log((1 + 0.34 × 0.33) / (1 − 0.34 × 0.33)) ≈ ±1 dB、
両端で山と谷の差が 2〜4 dB。

## 部品

6-5・6-11 のフィルタの両端に、抵抗の場所を 4 つ足す。

| 部品 | 値 | 備考 |
| --- | --- | --- |
| C1・C3 | 180 pF | 6-5 と同じ (CH 特性) |
| C2 | 270 pF | 同上 |
| L1・L2 | 330 nH | 同上 (アキシアル) |
| R1・R2 | 51 Ω (組 B) / 0 Ω (組 A・C) | 1/4 W の金属皮膜。0 Ω は錫めっき線で代える |
| R3・R4 | 51 Ω (組 C だけ挿す) | 同上。A・B では挿さない |
| J1・J2 | 端面 SMA | 6-11 と同じ |

E24 の 51 Ω を使う。50 Ω ちょうどでなくても、直流の S21 から差を読むので影響しない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 5 次チェビシェフの両端に終端を変える抵抗 (R1・R2 は直列、R3・R4 は並列)
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 3,2 5,2 51
  R3: resistor 6,2 6,4 51
  C1: capacitor 8,2 8,4 180p
  L1: inductor 9,2 11,2 330n
  C2: capacitor 12,2 12,4 270p
  L2: inductor 13,2 15,2 330n
  C3: capacitor 16,2 16,4 180p
  R4: resistor 18,2 18,4 51
  R2: resistor 19,2 21,2 51
  J2: sma 23,2 CH1
  G1: ground 2,3
  G2: ground 6,4
  G3: ground 8,4
  G4: ground 12,4
  G5: ground 16,4
  G6: ground 18,4
  G7: ground 23,3
wires:
  - J1.1 -- 3,2
  - 5,2 -- 6,2 -- 8,2 -- 9,2
  - 11,2 -- 12,2 -- 13,2
  - 15,2 -- 16,2 -- 18,2 -- 19,2
  - 21,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 23,3
notes:
  - text 12,5.5 center: 組 B は R1・R2 が 51 Ω、組 C は R3・R4 が 51 Ω (ほかは 0 Ω か外す)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/21-termination-mismatch.svg)

- 図は全部の場所を描いた。組ごとに挿す物は「部品」の表のとおり
- R3・R4 は SMA に近い側に置く。フィルタから見た相手が「50 Ω の VNA と 51 Ω の並列」になる

## 実体配線図

6-11 の基板を横に 7 列延ばし、両端に R1・R3 と R4・R2 の場所を足した。部品面から見た図。
R1・R2 は挿し替えるので、リードを長めに残す。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 33x10
  slots: on
title: 図2 perfboard に組む (R1〜R4 の場所つき)
parts:
  J1: sma/female-edge e1 f0
  R1: resistor e2 e5 51
  R3: resistor e7 h7 51
  C1: capacitor f9 g9 180p
  L1: inductor e11 e15 330n
  C2: capacitor f17 g17 270p
  L2: inductor e19 e23 330n
  C3: capacitor f25 g25 180p
  R4: resistor e27 h27 51
  R2: resistor e29 e32 51
  J2: sma/female-edge e33 f34
wires:
  - e1 -- e2
  - e5 -- e7
  - e7 -- e9
  - e9 -- f9
  - e9 -- e11
  - e15 -- e17
  - e17 -- f17
  - e17 -- e19
  - e23 -- e25
  - e25 -- f25
  - e25 -- e27
  - e27 -- e29
  - e32 -- e33
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h7 black
  - h7 -- h9 black
  - h9 -- g9 black
  - h9 -- h17 black
  - h17 -- g17 black
  - h17 -- h25 black
  - h25 -- g25 black
  - h25 -- h27 black
  - h27 -- h32 black
  - f34 -- f32 black
  - f32 -- h32 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/21-termination-mismatch.svg)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜50 MHz (6-5・6-11 と同じ) |
| 点数 | 301 |
| 校正 | SOLT。CH0・CH1 のケーブルの先 (基板の SMA の手前)。抵抗は校正に含めない |
| 表示 | S21 と S11 の Log Mag |

3 枚とも掃引とマーカー (1・10.4・28・35 MHz) をそろえる。1 MHz は直流の代わりの基準、
10.4 MHz は組 B の谷、28 MHz は組 C の谷。組 A (6-11 の図3 と同じ形)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-50M 301
title: 図3 組 A (50 Ω で終端) — 通過帯域の波は 0.48 dB
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
  - 1M
  - 10.4M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/21-termination-mismatch-1.svg)

組 B (101 Ω で終端)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-50M 301
title: 図4 組 B (101 Ω で終端) — 直流から 3.9 dB 落ちる谷が出る
dut:
  - series R 51
  - shunt C 180p
  - series L 330n
  - shunt C 270p
  - series L 330n
  - shunt C 180p
  - series R 51
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 10.4M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/21-termination-mismatch-2.svg)

組 C (25.2 Ω で終端)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-50M 301
title: 図5 組 C (25.2 Ω で終端) — 肩が下がり、−3 dB が 29.2 MHz へ
dut:
  - shunt R 51
  - shunt C 180p
  - series L 330n
  - shunt C 270p
  - series L 330n
  - shunt C 180p
  - shunt R 51
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 10.4M
  - 28M
  - 35M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/21-termination-mismatch-3.svg)

## 見るべき値

計算値 (無損失の LC と理想の抵抗)。マーカーの読み値 (S21 / S11)。

| マーカー | 組 A (図3) | 組 B (図4) | 組 C (図5) |
| --- | --- | --- | --- |
| 1 (1 MHz) | −0.01 / −24.86 dB | −6.24 / −6.13 dB | −5.94 / −6.14 dB |
| 2 (10.4 MHz) | −0.46 / −9.95 dB | **−10.02** / −17.30 dB | −6.43 / −9.50 dB |
| 3 (28 MHz) | −0.01 / −25.56 dB | −8.16 / −12.72 dB | **−7.36** / −11.87 dB |
| 4 (35 MHz) | −10.45 / −0.41 dB | −18.12 / −6.62 dB | −18.39 / −7.23 dB |

直流の値からの差に直した形 (計算値):

| 項目 | 組 A (50 Ω) | 組 B (101 Ω) | 組 C (25.2 Ω) |
| --- | --- | --- | --- |
| 直流の S21 | 0 dB | −6.11 dB | −5.94 dB |
| 通過帯域の谷 (直流からの差) | −0.48 dB (9.2 MHz) | **−3.92 dB** (10.45 MHz) | **−1.42 dB** (28 MHz) |
| 最後に −3 dB を切る周波数 | 31.6 MHz | 32.3 MHz | 29.2 MHz |
| 35 MHz (直流からの差) | −10.45 dB | −12.01 dB | −12.46 dB |

- **相手が 2 倍 (101 Ω) になると、0.5 dB のリップルが 3.9 dB に**広がる。
  「0.5 dB のチェビシェフ」は 50 Ω で終端したときだけの名前
- **相手が半分 (25.2 Ω) だと、谷は帯域の肩 (28 MHz) に寄り**、カットオフが 31.6 → 29.2 MHz に下がる。
  同じ倍率のずれでも、高いか低いかで崩れ方が違う
- 阻止帯域 (35 MHz) の減衰は 1.5〜2 dB 深くなるだけで、形が崩れるのは**通過帯域**のほう
- S11 は組 B・C では抵抗の分だけ悪く見え (1 MHz で −6 dB)、フィルタの整合の良し悪しは
  この画面からは読めない。読むのは S21 の直流からの差

分かること:

- 前の段が 50 Ω でない回路 (トランジスタのコレクタ、ミキサの出力、アンテナ) にフィルタを
  付けるときは、**その抵抗に合わせて設計し直す**か、間に整合回路 (7-4 の L 型) やトランスを入れる
- 50 Ω 以外で設計したフィルタを VNA で測るには、6-12 のように抵抗で合わせるか、測った
  S パラメータを計算で別の基準インピーダンスに直す (第 10 章の scikit-rf にある)。
  直列の抵抗で合わせる組 B は、損失 6 dB と引き換えに 101 Ω の系での形をそのまま見せる

## LTspice での確かめ

`sim/21-termination-mismatch.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1 MHz | S21 / S11 | −0.01 dB / −24.86 dB | −0.01 dB / −24.86 dB | 合う |
| 図3 | 10.4 MHz | S21 / S11 | −0.46 dB / −9.95 dB | −0.46 dB / −9.95 dB | 合う |
| 図3 | 28 MHz | S21 / S11 | −0.01 dB / −25.56 dB | −0.01 dB / −25.56 dB | 合う |
| 図3 | 35 MHz | S21 / S11 | −10.45 dB / −0.41 dB | −10.45 dB / −0.41 dB | 合う |
| 図4 | 1 MHz | S21 / S11 | −6.24 dB / −6.13 dB | −6.24 dB / −6.13 dB | 合う |
| 図4 | 10.4 MHz | S21 / S11 | −10.02 dB / −17.30 dB | −10.02 dB / −17.30 dB | 合う |
| 図4 | 28 MHz | S21 / S11 | −8.16 dB / −12.72 dB | −8.16 dB / −12.72 dB | 合う |
| 図4 | 35 MHz | S21 / S11 | −18.12 dB / −6.62 dB | −18.12 dB / −6.62 dB | 合う |
| 図5 | 1 MHz | S21 / S11 | −5.94 dB / −6.14 dB | −5.94 dB / −6.14 dB | 合う |
| 図5 | 10.4 MHz | S21 / S11 | −6.43 dB / −9.50 dB | −6.43 dB / −9.50 dB | 合う |
| 図5 | 28 MHz | S21 / S11 | −7.36 dB / −11.87 dB | −7.36 dB / −11.87 dB | 合う |
| 図5 | 35 MHz | S21 / S11 | −18.39 dB / −7.23 dB | −18.39 dB / −7.23 dB | 合う |

12 点すべて図の読み値と合う。
直流からの差の表 (谷・−3 dB・35 MHz) は、同じ模型を 1 kHz おきに計算して読んだ (算術)。

## 出典

自作。5 次チェビシェフ (0.5 dB) の値は 6-5 による。両端を同じ抵抗で終端する設計の前提は
[標準的なフィルタ設計表](https://en.wikipedia.org/wiki/Prototype_filter)による。
