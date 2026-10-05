---
book: nanovna
chapter: 4
id: 4-6
title: 水晶 — fs / fp / Q / 等価回路
tier: 50
source: 自作
board: PF
device: H4
---

# 4-6 水晶 — fs / fp / Q / 等価回路

水晶振動子は、機械的な共振を電気の等価回路 (直列 C・L・R に、電極の容量 Cp が
並列に付いたもの) で表せる。直列共振 (fs) では信号がよく通り、そのすぐ上の
並列共振 (fp) では逆にほとんど通らない。3-1 の直列治具に 10 MHz の水晶を挿して、
この 2 つの周波数を読む。

## 回路図

```circuit
title: 図1 直列治具に水晶を挿す
parts:
  J1: sma b2 mirror CH0
  X1: crystal b4 b6 10M
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/06-crystal.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の直列治具に水晶 (HC-49)
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  X1: crystal/hc49 f10 i10 10M
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/06-crystal.svg)

10 MHz の HC-49 水晶の等価回路は代表的な値として、モーショナル容量
Cm ≈ 12 fF、モーショナル抵抗 Rm ≈ 25 Ω、電極の容量 Co ≈ 4 pF、
モーショナルインダクタンス Lm ≈ 21.1 mH とする。この組み合わせで
fs = 1 / (2π√(Lm·Cm)) を計算すると 10.002 MHz になる (「10 MHz 水晶」という
呼び名からのずれは、実物でも普通にある製造誤差の範囲)。
Q = (1/Rm)√(Lm/Cm) ≈ 5.3 万 — 水晶が Q の高さで知られるとおりの値。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 9.99 MHz〜10.03 MHz (fs のごく近く) |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と位相。CH1 まで通す (短絡しない) |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 9.99M-10.03M 401
title: 図3 10 MHz 水晶の S21 — fs (通る) と fp (通らない)
dut:
  - series C 12f esl 21.1m esr 25 cp 4p
traces:
  - S21 logmag
  - S21 phase
markers:
  - 10.00203M
  - 10.01702M
notes:
  - band 10.00203M 10.01702M: fs と fp の間 15 kHz
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/06-crystal.svg)

## 見るべき値

計算値。fp = fs·√(1 + Cm/Co)。

| 周波数 | S21 | 意味 |
| --- | --- | --- |
| fs ≈ 10.002 MHz | −1.9 dB | 直列共振。Z = Rm (25 Ω) まで下がり、信号がよく通る |
| fp ≈ 10.017 MHz | −76 dB 前後 | 並列共振。Z が非常に大きくなり、ほとんど通らない |

fs と fp の差は約 15 kHz (10 MHz の 0.15%)。この差は Cm/Co の比で決まり、
Co を大きくする (水晶に並列にコンデンサを足す) と fp は fs に近づく —
発振回路で周波数を微調整する「プルアビリティ」の原理。

分かること:

- **fs と fp の間はわずか 15 kHz しかない**。掃引の範囲を欲張って広く取ると、
  この 2 つの共振がつぶれて見える。水晶の実験は狭い掃引が要る。水晶だけの Q なら
  共振の幅は fs / Q ≈ 190 Hz だが、直列治具では両側の 50 Ω が Rm に加わって Q が約 1.1 万に
  下がり、fs の山の幅は約 940 Hz になる。それでも 15 kHz より 1 桁狭く、この図の掃引点数
  (401 点、約 100 Hz 間隔) でようやく山の形が見える細さ
- fs での Z (= Rm = 25 Ω) が水晶の等価直列抵抗。これが小さいほど発振回路が
  起動しやすい
- Q ≈ 5.3 万は、4-4 のコイル (Q 数十〜数百) とは桁違いに高い。**水晶が
  周波数の基準に使われる理由そのもの**

## 出典

自作。
