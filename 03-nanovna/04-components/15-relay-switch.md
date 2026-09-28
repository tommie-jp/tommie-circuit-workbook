---
book: nanovna
chapter: 4
id: 4-15
title: リレー・スイッチの S21
tier: 100
source: 自作
board: PF
device: H4
---

# 4-15 リレー・スイッチの S21

リレーやスイッチは「つながる / 切れる」の 2 つの状態しか持たないように見えるが、
高い周波数では**閉じた接点がインダクタンス**に、**開いた接点がコンデンサ**に見える。
閉じていても通り切らず、開いていても漏れる。信号用のリレー G5V-2 の接点を 3-1 の
直列治具に入れ、閉じた接点の損失と、開いた接点の漏れ (アイソレーション) を S21 で測る。

コイルに電気を流さなくても両方の状態が測れる。G5V-2 は電気を流さないとき
**COM–NC が閉じ、COM–NO が開いている**ので、NC と NO のどちらを CH1 へ出すかで
つなぎ替える。

## 回路図

```circuit
title: 図1 リレーの接点 (コイルは使わない)
parts:
  J1: sma e2 mirror CH0
  K1: relay d6 G5V-2
  J2: sma c10 CH1
  G1: ground f2
  G2: ground d10
wires:
  - J1.1 -| K1.COM1
  - K1.NC1 |- J2.1
  - J1.2 -- f2
  - J2.2 -- d10
notes:
  - text f7 center: "閉じた接点 (COM1 と NC1) を測るつなぎ方"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/15-relay-switch.svg)

- 図は電気を流さないときの接点。COM1–NC1 が閉じている
- 開いた接点を測るときは、CH1 へ出す足を NC1 から **NO1** に替える
- コイル (A1・A2) と 2 つ目の接点 (COM2・NC2・NO2) はどこにもつながない

## 実体配線図

G5V-2 は実物を上から見て、切り欠きを左に置いた並びで描く。足の名前は胴の外に出る。

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 閉じた接点 (COM1–NC1)
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  K1: relay b5
wires:
  - e1 -- e3
  - e3 -- f3
  - f3 -- f8
  - f8 -- e8
  - e10 -- f10
  - f10 -- f14
  - f14 -- e14
  - e14 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - GND -- h15 black
  - f17 -- f15 black
  - f15 -- h15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/15-relay-switch-1.svg)

```perfboard
board:
  size: 16x8
  slots: on
title: 図3 開いた接点 (COM1–NO1)
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  K1: relay b5
wires:
  - e1 -- e3
  - e3 -- f3
  - f3 -- f8
  - f8 -- e8
  - e12 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - GND -- h15 black
  - f17 -- f15 black
  - f15 -- h15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/15-relay-switch-2.svg)

- 入る線は A1 (e5) の足を避けて f 行を回り、下から COM1 (e8) に入る
- 図2 は NC1 (e10) から、NO1 (e12) の足を避けて f 行を回って J2 へ。図3 は NO1 (e12) から
  e 行をまっすぐ J2 へ
- 使わない足 (コイルと 2 つ目の接点) は穴に挿すだけ。検査 (ERC) が「つながっていない足」と
  言うが、意図どおり
- 線を回したぶん、治具の線は 3-1 より長い。この長さも閉じた接点のインダクタンスに入って見える

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 201 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 と S11 の Log Mag (開いた接点は S21 だけ) |
| 模型の仮定 | 閉じた接点 = 15 nH (リレーの中の線と治具の線)、開いた接点 = 1 pF (接点の隙間と足の間の容量)。どちらも見積もり |

**1. 閉じた接点** — 見えるはずの画面。

```vna
device: h4
sweep: 1M-300M 201
title: 図4 閉じた接点 (15 nH) — 300 MHz で S11 が −11.3 dB まで上がる
dut:
  - series R 0 esl 15n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/15-relay-switch-1.svg)

**2. 開いた接点** — 同じ掃引で。S11 は 300 MHz でも −0.15 dB (ほぼ全部が返る) で
0 dB の線から離れないので、漏れの S21 だけを出す。

```vna
device: h4
sweep: 1M-300M 201
title: 図5 開いた接点 (1 pF) — 周波数が上がるほど漏れる
dut:
  - series C 1p
traces:
  - S21 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/15-relay-switch-2.svg)

## 見るべき値

計算値 (模型から)。

| 周波数 | 閉じた接点の S21 | 閉じた接点の S11 | 開いた接点の S21 (アイソレーション) |
| --- | --- | --- | --- |
| 10 MHz | 0.00 dB | −40.5 dB | −44.0 dB |
| 100 MHz | −0.04 dB | −20.6 dB | −24.1 dB |
| 300 MHz | −0.33 dB | −11.3 dB | −14.7 dB |

分かること:

- **閉じた接点の損失 (S21) は小さいが、反射 (S11) は周波数とともに増える。** 信号用の
  リレーでも、100 MHz を超えると 50 Ω の線の一部としては扱えなくなる。図4 の S21 が
  300 MHz まで 0 dB の線からほとんど離れない (0.33 dB) のは意図どおりで、動かないことを見る線
- **開いた接点の漏れは、10 倍の周波数でおよそ 20 dB 増える** (容量の X が 1/10 になる)。
  「切ったつもりでも漏れる」量が周波数で決まる
- 押しボタン・スライドスイッチも同じ治具で測れる。接点の間が広く、足の短い物ほど
  アイソレーションがよい。高い周波数を切り替えるなら、専用の RF スイッチや同軸リレーを使う

## 出典

自作。G5V-2 の足の並びと接点の構成はオムロンのデータシートによる。
