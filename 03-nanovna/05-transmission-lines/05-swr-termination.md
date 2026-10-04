---
book: nanovna
chapter: 5
id: 5-5
title: SWR と反射 — 終端を変えて
tier: 50
source: 自作
board: —
device: H4
---

# 5-5 SWR と反射 — 終端を変えて

CH0 の先につなぐ終端 (負荷) を変えて、SWR (定在波比) がどう変わるかを見る。
50 Ω にぴったり合わせれば SWR = 1、大きくずれるほど SWR は大きくなる —
アンテナや給電線の「合っている・合っていない」を 1 つの数字で表す指標。

## 回路図

```circuit
title: 図1 CH0 の先に 50 Ω の終端 (100 Ω 2 本並列)
parts:
  J1: sma b2 mirror
  R1: resistor b4 d4 100
  R2: resistor b6 d6 100
  G1: ground c2
  G2: ground d6
wires:
  - J1.1 -- b4 -- b6
  - J1.2 -- c2
  - d4 -- d6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/05-swr-termination.svg)

図は 50 Ω の終端。50 Ω は E24 に無いので **100 Ω を 2 本並列**にする (R1 ∥ R2)。
ほかの終端は R1・R2 の所を挿し替えて測る。

| 終端 | 作り方 |
| --- | --- |
| 25 Ω | 12 Ω と 13 Ω を直列 (E24 の 2 本) |
| 50 Ω | 100 Ω を 2 本並列 (図1) |
| 75 Ω・100 Ω・150 Ω | 1 本 (E24 にある) |
| 短絡・開放 | R1・R2 の代わりに直結・開放 |

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の終端 (100 Ω 2 本並列で 50 Ω)
points:
  GND: m2
parts:
  J1: sma/female-edge i1 h0 j0
  R1: resistor i4 i7 100
  R2: resistor l4 l7 100
wires:
  - i1 -- i4
  - i4 -- l4
  - i7 -- l7 black
  - l7 -- m7 black
  - m7 -- GND black
  - j0 -- j2 black
  - j2 -- GND black
```

R1 と R2 の所を挿し替えて、表のほかの終端を測る。板に流れる電流は、NanoVNA の出力が 0 dBm 以下なので
数 mA 以下で、板の範囲に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの根元 (CH0 の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の SWR |

見えるはずの画面 (理想の模型)。50 Ω ぴったり — SWR = 1 で図の下端に張り付く。

```vna
device: h4
sweep: 10M-300M 101
title: 図3 終端 50 Ω (整合) — SWR = 1 で下端に乗る。Smith は中心
dut:
  - series R 50
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 155M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/05-swr-termination-1.svg)

終端 100 Ω — SWR = 2。

```vna
device: h4
sweep: 10M-300M 101
title: 図4 終端 100 Ω — SWR = 2 で平ら (枠の上端)。Smith は 2 の点
dut:
  - series R 100
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 155M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/05-swr-termination-2.svg)

終端を短絡 (0 Ω) — SWR は測れる上限までずっと大きい。

```vna
device: h4
sweep: 10M-300M 101
title: 図5 終端を短絡 — SWR は上限に張り付く。Smith は左端の 1 点
dut:
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 155M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/05-swr-termination-3.svg)

## 見るべき値

計算値。Γ = (Z_L − 50) / (Z_L + 50)、SWR = (1 + |Γ|) / (1 − |Γ|)。

| 終端 | Γ | SWR |
| --- | --- | --- |
| 開放 | 1 | ∞ |
| 短絡 | −1 | ∞ |
| 25 Ω | −0.333 | 2.0 |
| 50 Ω (整合) | 0 | **1.0** |
| 75 Ω | 0.2 | 1.5 |
| 100 Ω | 0.333 | 2.0 |
| 150 Ω | 0.5 | 3.0 |

分かること:

- **SWR は周波数によらず一定** — ここでの終端はどれも周波数に依らない抵抗
  なので、SWR も掃引全体でまっすぐな線になる (アンテナのように周波数で
  Z が変わる負荷では、SWR も周波数で変わる。7-1 で扱う)
- **開放と短絡はどちらも SWR = ∞ で区別が付かない。** SWR (大きさ) だけでは
  「反射がある」ことは分かっても「なぜか」は分からない。原因を知るには
  Smith チャートや位相を見る必要がある
- **25 Ω も 100 Ω も同じ SWR = 2 になる** — 50 Ω を基準にして大きすぎても
  小さすぎても、比が同じなら SWR は同じ。SWR だけでは Z_L が 50 Ω より
  大きいか小さいかも分からない

## 出典

自作。
