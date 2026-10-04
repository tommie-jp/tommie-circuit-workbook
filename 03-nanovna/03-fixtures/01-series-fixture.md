---
book: nanovna
chapter: 3
id: 3-1
title: 直列治具 — 部品を CH0 と CH1 の間に入れる
tier: 50
source: 自作
board: PF
device: H4
---

# 3-1 直列治具 — 部品を CH0 と CH1 の間に入れる

部品 1 つを **CH0 と CH1 の間に直列**に入れて、通り抜ける量 (S21) と跳ね返る量
(S11) を測るための治具。端面の SMA を 2 つ、perfboard の両端に載せる。
部品の章 (第 4 章) とフィルタの章 (第 6 章) で使い回す。

## 回路図

```circuit
title: 図1 直列治具
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 b6 100
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/01-series-fixture.svg)

- R1 が測る部品 (DUT)。ここでは 100 Ω の抵抗を入れて、治具が正しく作れたかを確かめる
- 2 つの SMA の外皮 (GND) は治具の上でつなぐ。つながないと、GND の戻り道が
  ケーブルの外側を回って値が狂う

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard に端面 SMA を 2 つ
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  R1: resistor i6 i11 100
wires:
  - i1 -- i6
  - i11 -- i24
  - j0 -- j25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/01-series-fixture.svg)

- 端面 SMA の凹の腕 (GND) を板の縁の銅箔に半田付けし、中心導体を板の穴に通す
- **中心導体から部品までの線はできるだけ短く**。長い線はそのぶんインダクタンスに
  なり、高い周波数で値がずれる (どこまで信じられるかは 3-6 で測る)
- GND は信号の線のすぐ隣の j 行を 1 本の線で通し、両方の SMA の凹の腕 (j0〜j25) をつなぐ。
  帰り道を信号の線と同じ長さに抑えるため
- 5×7 cm の板の両端に SMA を置くので、線は左が i1〜i6 の 5 穴 (1.27 cm)、右が
  i11〜i24 の 13 穴 (3.30 cm) で、左右が対称でない。8-3 の経験式で見積もると、
  足を含めて一直線に並んだ 23 穴の線全体で約 52 nH。長さで割り振ると左が約 11 nH、
  右が約 29 nH で、300 MHz で合わせて約 +j77 Ω になる。値の引き方と、
  対称でないことの扱いは 3-8 で計算する

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag と Smith チャート |

100 Ω を入れたときに**見えるはずの画面** (理想の模型から計算した破線)。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 100 Ω を直列に入れた治具の理想 (平らに −6.02 dB)
dut: series R 100
traces:
  - S21 logmag
  - S11 logmag
  - S11 smith
markers:
  - 10M
  - 300M
notes:
  - text 20M -20dB: S21 も S11 も −6.02 dB で重なる
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/01-series-fixture.svg)

- S21 と S11 はどちらも −6.02 dB で重なる。Smith では実軸の r = 3 (150 Ω) の 1 点
- 測ったら NanoVNA-Saver で Touchstone (`.s2p`) に保存してこのファイルの隣に置き、
  フェンスに `data: <ファイル名>.s2p` を書き足すと**実測が実線で重なる**
  (読み値の表も実測の値になる)。300 MHz へ向かって破線から離れた所が治具の限界

## 見るべき値

50 Ω 系に直列に Z を入れると、S21 = 2·50 / (2·50 + Z)、S11 = Z / (2·50 + Z)。

| 入れる物 | S21 | S11 | 分かること |
| --- | --- | --- | --- |
| 100 Ω の抵抗 | −6.0 dB | −6.0 dB | 治具が正しく作れている (低い周波数で合えばよい) |
| 太い銅線 (0 Ω) | 0 dB | 小さいほど良い | 治具だけの損失と反射。3-3 のスルー治具と同じ |
| 何も入れない (開放) | 小さいほど良い | 0 dB | SMA どうしの漏れ (容量で高い周波数ほど増える) |

周波数を上げていくと 100 Ω の値が −6.0 dB から離れていく。そこが治具と
部品のリードの限界で、3-6 でその周波数を測って決める。

## 出典

自作。
