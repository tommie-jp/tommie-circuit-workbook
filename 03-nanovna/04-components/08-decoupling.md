---
book: nanovna
chapter: 4
id: 4-8
title: デカップリングの並列 (0.1 µF + 10 µF)
tier: 50
source: 自作
board: PF
device: H4
---

# 4-8 デカップリングの並列 (0.1 µF + 10 µF)

電源のデカップリングは「大きい容量 (蓄える) + 小さい容量 (高い周波数まで効く)」の
組み合わせで作る。ここでは大きい 10 µF と小さい 0.1 µF を GND へ落とす**並列
(シャント) 治具**を使い、電源ラインから見た合成インピーダンスを測る。
3-1 の直列治具とは違い、CH0 と CH1 の間は素通しのまま、部品は GND へ落とす —
3-2 の並列治具と同じ考え方のユニバーサル基板。

## 回路図

```circuit
title: 図1 並列治具に 2 つのコンデンサ
parts:
  J1: sma b2 mirror CH0
  C1: ecap b4 d4 10u
  C2: capacitor b6 d6 100n
  J2: sma b8 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d6
  G4: ground c8
wires:
  - J1.1 -- b4 -- b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/08-decoupling.svg)

CH0-CH1 の線は途切れず、C1 (10 µF) と C2 (0.1 µF) がそれぞれ GND へ落ちる。
S21 (通り抜け) から、GND へ落ちている部品の合成インピーダンスが分かる
(**シャントスルー法**。抵抗 1 個を直列に挿すより、こちらのほうがずっと
小さいインピーダンスまで測れる)。

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の並列治具に電解 + セラミック
points:
  GND: l2
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  C1: capacitor/electrolytic i6 l6 10u
  C2: capacitor/ceramic i11 l11 100n
wires:
  - i1 -- i6
  - i6 -- i11
  - i11 -- i24
  - j0 -- j2 black
  - j2 -- GND black
  - GND -- l6 black
  - l6 -- l11 black
  - l11 -- l15 black
  - l15 -- j15 black
  - j15 -- j25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/08-decoupling.svg)

i 行が CH0-CH1 の素通し線、l 行が GND のバス。C1・C2 とも i 行から l 行へ
垂直に落とす。電解コンデンサ C1 は極性がある (i6 側が +)。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜100 MHz |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag。CH1 まで通す (シャントスルー法) |

見えるはずの画面 (理想の模型)。低い ESR のコンデンサ 2 つを並列にすると、
それぞれの SRF の間に**反共振**の山ができる。

```vna
device: h4
sweep: 100k-100M 401
title: 図3 10 µF + 0.1 µF のシャントスルー — 谷 2 つと山は 20 MHz より下
dut:
  - shunt C 10u esr 0.01 esl 3n
  - shunt C 100n esr 0.02 esl 1n
traces:
  - S21 logmag
markers:
  - 919k
  - 8M
  - 15.9M
notes:
  - band 100k 20M: 図4 で広げる
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/08-decoupling-1.svg)

2 つの SRF と反共振の山がある 100 kHz〜20 MHz を広げる。

```vna
device: h4
sweep: 100k-20M 401
title: 図4 100 kHz〜20 MHz に広げる — 2 つの SRF の間に反共振の山
dut:
  - shunt C 10u esr 0.01 esl 3n
  - shunt C 100n esr 0.02 esl 1n
traces:
  - S21 logmag
markers:
  - 919k
  - 8M
  - 15.9M
notes:
  - text 1M -15dB: 反共振 (8 MHz) の |Z| は 10 µF の SRF の 75 倍
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/08-decoupling-2.svg)

## 見るべき値

計算値。並列合成 Z = Z₁∥Z₂ (Z₁ = 10 µF 側、Z₂ = 0.1 µF 側)。

| 周波数 | 合成 \|Z\| | S21 | 支配する部品 |
| --- | --- | --- | --- |
| 919 kHz (10 µF の SRF) | 0.010 Ω | −68.0 dB | 10 µF がよく効いている |
| 8.0 MHz (反共振の山) | 0.746 Ω | −30.8 dB | どちらも半端に効く分、悪化 |
| 15.9 MHz (0.1 µF の SRF) | 0.020 Ω | −62.0 dB | 0.1 µF がよく効いている |

分かること:

- **2 つの SRF の間 (ここでは 8 MHz あたり) に、単体よりも悪い「反共振」の山が
  できる。** 8 MHz での |Z| (0.746 Ω) は、10 µF 単体の SRF での |Z| (0.010 Ω)
  よりも 75 倍も大きい — 並列にしたのに、この周波数だけは損をしている
- 原因は、8 MHz 付近で 10 µF 側が**誘導性** (X > 0)、0.1 µF 側が**容量性**
  (X < 0) になり、1/Z の虚部 (サセプタンス) がほぼ打ち消し合うため。残る 1/Z の実部 (コンダクタンス) は
  ESR が低いほど小さく、そのぶん合成の |Z| が大きくなる。ESR が低い部品どうしの
  組み合わせほど、この山は深く鋭くなる
- 対策は、山の周波数を使わない範囲に追い出すか、山をわざと鈍らせる
  (どちらかに ESR を持たせる、値を離しすぎない) こと。回路の教科書と
  合わせて設計するときに効いてくる注意点

## 出典

自作。
