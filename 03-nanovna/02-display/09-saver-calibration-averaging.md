---
book: nanovna
chapter: 2
id: 2-9
title: NanoVNA-Saver の校正と平均化
tier: 100
source: 自作 (ソフトの操作は NanoVNA-Saver の README とソース)
board: —
device: H4
---

# 2-9 NanoVNA-Saver の校正と平均化

NanoVNA-Saver (2-4) は、本体の校正とは別に **PC の上で校正**でき、同じ点を何回も
測って**平均**できる。Saver の校正は Saver の掃引 (セグメントを並べた多い点数) に
合わせて行うので、本体の 101〜401 点より細かい点で補正が効く。平均化は、測る値が
小さくて雑音に埋もれかけているときに効く。40 dB のアッテネータで確かめる。

## Saver の校正の手順

Saver の README は、**本体もそれなりに校正された状態にしておく**よう求めている
(本体を掃引の全体で校正してスロット 0 に保存しておけば足りる)。まったく校正して
いない本体の値は、Saver が受け付ける範囲を外れることがある。

| # | 操作 (Saver の画面の名前) | 中身 |
| --- | --- | --- |
| 1 | 本体で SOLT してスロット 0 に保存 (1-1・1-6) | Saver の範囲を含む広い範囲で |
| 2 | Saver で Start・Stop・Segments を決める | 校正と測定で同じにする (1-4 と同じ理由) |
| 3 | Calibration ... → Calibration assistant | 画面の指示どおりに Short・Open・Load・Through をつないで掃引する |
| 4 | Notes に条件を書く | キット・ケーブル・温度など (2-10) |
| 5 | Apply | その場で最新の掃引に補正が掛かる |
| 6 | Save calibration | ファイルに保存。次は Load calibration で読み込む |

- **Calibration standards** の欄で、標準器を理想 (Use ideal values) とするか、係数
  (Use coefficients) で与えるかを選べる。係数には Load の Resistance (Ω) もある。
  **1-8 でテスターで読んだ Load の値**をここに入れれば、Load のずれを校正で
  補える (Load の容量は README で未対応とされている)
- Offset delay は標準器の先の電気長。ポート延長 (1-10) と同じ考え方
- Saver の校正の窓の上には、今どちらの校正が効いているか (本体か Saver か) が出る

## 平均化

Sweep settings ... の窓で **Averaged sweep** を選び、次の 2 つを入れる。

| 項目 | 意味 |
| --- | --- |
| Number of measurements to average | 1 点を何回測るか (N) |
| Number to discard | 外れた値を何個捨てるか (D) |

Saver の窓には「よく使う値は 3/0、5/2、9/4、25/6」と書いてある。雑音が
ばらばら (互いに関係しない) なら、残った N − D 回の平均で雑音の揺れは
1 / √(N − D) に減る (目安)。

| N / D | 平均に残る回数 | 揺れ (標準偏差) | dB にすると | 掃引の時間 |
| --- | --- | --- | --- | --- |
| 1 / 0 (平均しない) | 1 | 1 | 0 dB | 1 倍 |
| 3 / 0 | 3 | 0.58 | −4.8 dB | 3 倍 |
| 5 / 2 | 3 | 0.58 | −4.8 dB | 5 倍 |
| 9 / 4 | 5 | 0.45 | −7.0 dB | 9 倍 |
| 25 / 6 | 19 | 0.23 | −12.8 dB | 25 倍 |

(計算値。捨てるのは外れた値なので、実際はこれより少しよく効く。**時間は N に比例**する)

- 本体の側にも似た働きの IF BANDWIDTH (DISPLAY → IF BANDWIDTH) がある。狭くすると
  1 点の測定に時間を掛けて雑音を減らす
- 平均化は**雑音**を減らす。校正のずれ、ケーブルの揺れ、温度の変化 (1-9) は減らない

## 回路図

DUT は 0-3 の 20 dB パッド (43 Ω・11 Ω・43 Ω、E24) を 2 段つないだ 40 dB の
アッテネータ。

```circuit
title: 図1 20 dB パッドを 2 段 (約 40 dB)
parts:
  J1: sma b2 mirror CH0
  R1: resistor b3 b4 43
  R2: resistor b5 d5 11
  R3: resistor b6 b7 43
  R4: resistor b8 b9 43
  R5: resistor b10 d10 11
  R6: resistor b11 b12 43
  J2: sma b13 CH1
  G1: ground c2
  G2: ground d5
  G3: ground d10
  G4: ground c13
wires:
  - J1.1 -- b3
  - b4 -- b5 -- b6
  - b7 -- b8
  - b9 -- b10 -- b11
  - b12 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/09-saver-calibration-averaging.svg)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 404 (Saver で 101 点を 4 セグメント、2-4) |
| 校正 | 本体はスロット 0。Saver で同じ範囲・点数を Calibration assistant で |
| 平均化 | Averaged sweep、9 / 4 |
| 表示 | S21 の Log Mag、S11 の Log Mag |

```vna
device: h4
sweep: 1M-300M 404
title: 図2 40 dB のパッドは S21 が −39.50 dB で平ら
dut:
  - series R 43
  - shunt R 11
  - series R 43
  - series R 43
  - shunt R 11
  - series R 43
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 100M
notes:
  - text 110M -60dB: 実測は S21 の線の上下に雑音で揺れる
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/09-saver-calibration-averaging.svg)

- 理想は S21 = −39.50 dB で平ら。実測では、この線を中心に雑音で細かく揺れる。
  平均化 (9 / 4) の前と後で、100 MHz の読みが何回の掃引でどれだけ動くかを比べる
- S11 は −31.10 dB (E24 に丸めた誤差の分。0-3 の 1 段だけのパッドの −31.19 dB とほぼ同じ)
- 平均化は S21 が小さい所ほど効き目が見える。0 dB 近くの Thru では差がほとんど出ない

## 見るべき値

| 見る所 | 値 | 分かること |
| --- | --- | --- |
| 100 MHz の S21 (理想) | −39.50 dB (計算値) | 2 段のパッドの減衰 |
| 100 MHz の S11 (理想) | −31.10 dB (計算値) | パッドの入口の整合 |
| 平均しないときの S21 の揺れ | 自分で測る (5 回掃引して最大 − 最小) | 雑音の大きさ |
| 9 / 4 のときの S21 の揺れ | 上の約 0.45 倍 (目安) | 平均化の効き目 |
| 9 / 4 の掃引の時間 | 平均しないときの約 9 倍 | 平均化の代償 |

## 出典

自作。Saver の画面の名前と平均化の値の例は
[NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) の README とソース
(校正と掃引の設定の窓)。
