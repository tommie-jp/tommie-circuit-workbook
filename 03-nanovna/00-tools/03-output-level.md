---
book: nanovna
chapter: 0
id: 0-3
title: 出力レベルと CH1 の最大入力 — アンプの出力にはアッテネータ
tier: 50
source: 自作
board: —
device: H4
---

# 0-3 出力レベルと CH1 の最大入力 — アンプの出力にはアッテネータ

NanoVNA の CH0 (ポート 1) が出す信号は数 mW 以下の小さなものだが、
**CH1 (ポート 2) の入力には壊れない上限がある**。アンプの出力や送信機の
出力を直接 CH1 に入れると、この上限を超えて壊す恐れがある。

## 大まかな目安

| | 目安 |
| --- | --- |
| CH0 の出力 | 0 dBm (1 mW) より小さい。機種・周波数で変わる |
| CH1 の最大入力 | 機種によって定格が違う。**0 dBm を大きく超える信号を入れない**のが安全 |

**正確な定格は手元の機種の説明書で確かめる。** ここでは「アンプの出力は
CH0 よりずっと大きいことがある」という前提で、**測る前にどれだけ落とせば
安全かを計算する**手順を扱う。

## 必要な減衰量の決め方

必要な減衰量 [dB] = アンプの出力レベル [dBm] − CH1 に入れてよい上限 [dBm]

たとえば、アンプの出力がおよそ +20 dBm (100 mW) で、CH1 の上限を
0 dBm 程度に見ておきたいなら、**20 dB 以上のアッテネータ**を挟む。
足りないと感じたら、次に大きい値 (30 dB など) を選び直せばよい —
**削りすぎて信号が小さすぎる分には、averaging (平均化) で補える**が、
入れすぎて壊れたら測れない。

## 回路図

```circuit
title: 図1 アンプの出力にアッテネータを挟んで CH1 へ
parts:
  A1:
    type: device
    at: 2,2
    label: DUT
    pins: [IN, OUT]
    turn: mirror
  R1: resistor 5,3 7,3 43
  R2: resistor 7,3 7,5 11
  R3: resistor 7,3 9,3 43
  G1: ground 7,5
  M1:
    type: device
    at: 11,2
    label: NanoVNA
    pins: [CH0, CH1]
wires:
  - A1.OUT -| 5,3
  - 9,3 |- M1.CH1
notes:
  - text 5,4 blue center: 20 dB パッド
  - text 2,3 blue center: 測るアンプ (DUT)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/circuit/03-output-level.svg)

- R1・R3 (43 Ω) と R2 (11 Ω) は 50 Ω 系の**20 dB T 型アッテネータ**。
  理屈どおりの値 (40.9 Ω・10.1 Ω) を E24 に丸めた (10 dB 版の丸め方は 3-5)
- CH0 はアンプの入力へ (今回の図には描いていない)。**CH1 の手前だけに
  パッドを入れれば足りる** — 反射で戻る分もこのパッドで一緒に減衰する

## 実体配線図

3-5 の perfboard のアッテネータを、20 dB の値 (43・11・43 Ω) に替えた。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の 20 dB アッテネータ (CH1 の手前に挟む)
points:
  GND: b7
parts:
  J1: sma/female-edge a10 011 09
  R1: resistor c10 f10 43
  R2: resistor h10 h8 11
  R3: resistor j10 m10 43
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - f10 -- h10
  - h10 -- j10
  - m10 -- x10
  - h8 -- h7 black
  - h7 -- GND black
  - 09 -- b9 black
  - b9 -- GND black
  - y9 -- o9 black
  - o9 -- o7 black
  - o7 -- h7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/perfboard/03-output-level.svg)

J1 にアンプの出力のケーブルを、J2 に NanoVNA の CH1 のケーブルを付ける。
抵抗は 0.25 W 品を使う。+20 dBm (100 mW) を入れたときの電流は I = √(0.1 W ÷ 50 Ω) ≈ 45 mA で、
R1 の発熱は 45 mA の 2 乗 × 43 Ω ≈ 0.09 W (R2 は約 0.01 W) と、0.25 W 品に収まる。
ユニバーサル基板を通る電流は約 45 mA で、1 穴 200 mA の範囲に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜1.5 GHz |
| 点数 | 101 |
| 校正 | パッドを含めて測るなら、パッドの先で校正し直す (1-4) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

43 Ω・11 Ω・43 Ω のパッドだけを理想の模型で見ると、平らに約 20 dB 落ちる。

```vna
device: h4
sweep: 1M-1.5G 101
title: 図3 E24 (43・11・43 Ω) の 20 dB パッドは全域で平ら
dut:
  - series R 43
  - shunt R 11
  - series R 43
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 100M
notes:
  - text 100M -50dB: S21 は −19.76 dB で平ら、S11 は E24 の丸めで −31.19 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/vna/03-output-level.svg)

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| パッドの S21 | −19.76 dB (計算値) | 100 mW → 約 1 mW に落ちる (E24 に丸めた誤差で 20 dB よりわずかに少ない) |
| パッドの S11 | −31.19 dB (計算値) | 50 Ω から少しだけずれる (入力側から見て 52.8 Ω)。理屈どおりの 40.9 Ω・10.1 Ω なら −80 dB まで下がる |
| CH1 に届く電力 | アンプの出力 − 20 dB | この値が CH1 の上限を超えないことを確かめる |

## 出典

自作。
