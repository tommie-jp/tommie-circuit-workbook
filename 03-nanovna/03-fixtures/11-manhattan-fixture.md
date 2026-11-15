---
book: nanovna
chapter: 3
id: 3-11
title: 銅張り基板に直付け (Manhattan 式) の治具
tier: 200
source: 自作
board: CB
device: H4
---

# 3-11 銅張り基板に直付け (Manhattan 式) の治具

3-2 の並列治具は、部品の GND 側を線で SMA の外皮まで戻していた。その線が数 cm あり、
インダクタンスになって 100 MHz を超えると部品の値を狂わせる (3-6)。
**Manhattan 式**は、片面の銅張り基板の銅を全部 GND の面として残し、信号の通る所だけを
小さな島として切り離す組み方。部品の GND 側は**島のすぐ隣の面へ直に半田付け**するので、
戻り道がほぼ無くなる。同じ 51 Ω (オーム) を並列に入れて、3-2 の形の perfboard の治具と比べる。

perfboard ではなく銅張り基板を選ぶのは、300 MHz で戻り道の数 nH が効くから
(perfboard の治具は 300 MHz くらいまでが目安、3-6)。周波数は NanoVNA-H4 の範囲の 500 MHz まで、
NanoVNA の出力 (0 dBm 以下) だけを通すので、銅張り基板の使える範囲 (1 GHz・100 mW 以下) に収まる。

## 回路図

Manhattan の治具に 51 Ω を並列に入れたときの等価回路。L1・L2 は SMA の島から真ん中の島へ渡す
線 (5 mm)、Le は 1608 のチップ抵抗と半田のインダクタンス。値は見積もり (目安)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Manhattan の並列治具 (等価回路)
parts:
  J1: sma 1,2 mirror CH0
  L1: inductor 3,2 5,2 3n
  R1: resistor 6,3 6,4 51
  Le: inductor 6,4 6,5 1n
  L2: inductor 7,2 9,2 3n
  J2: sma 11,2 CH1
  G1: ground 1,3
  G2: ground 6,6
  G3: ground 11,3
wires:
  - J1.1 -- 3,2
  - 5,2 -- 6,2 -- 7,2
  - 6,2 -- 6,3
  - 6,5 -- 6,6
  - 9,2 -- J2.1
  - J1.2 -- 1,3
  - J2.2 -- 11,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/11-manhattan-fixture.svg)

- R1 が測る部品 (DUT)。GND への道は Le の 1 nH だけで、ほかの線を通らない
- 3-2 の perfboard の治具に同じ 51 Ω (リード品) を入れると、L1・L2 は 26 nH ずつ
  (3-6 の幅いっぱいの線 52 nH を半分に)、Le は 15 nH (h7 から GND の線を回って SMA の外皮まで
  約 2.3 cm、8-3 の経験式で 16 nH。目安) になる。図4 はこの値で描く

## 部品

| 部品 | 値・型 | 注意 |
| --- | --- | --- |
| 銅張り基板 | 片面 FR4、厚さ 1.6 mm。5×7 cm から 40 mm × 30 mm を切り出す | 表の銅は全部 GND の面として残す |
| J1・J2 | 端面 SMA (メス) | 中心ピンを島 S1・S2 に、外皮の腕を表の GND の面へ |
| R1 | 51 Ω、1608 のチップ抵抗 | 島 P1 の下の縁と GND の面を跨いで載せる |
| ジャンパ | すずめっき線 0.5 mm、5 mm ほど | S1–P1、P1–S2 を渡す |

## 銅張り基板の寸法図

表が GND の面 (`ground: front`)。島のまわりの溝は 0.5 mm。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 40x30mm
  ground: front
  cut: 0.5mm
title: 図2 Manhattan の並列治具 (40 mm × 30 mm)
copper:
  S1: pad 3,15 6x3mm
  P1: pad 20,15 4x4mm
  S2: pad 37,15 6x3mm
parts:
  J1: sma left 15 CH0
  J2: sma right 15 CH1
  R1: resistor/1608 20,17.25 r90 51
wires:
  - S1 -- P1
  - P1 -- S2
notes:
  - dim 0,26 20,26
  - text 14,21: R1 は P1 から GND の面へ
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/copper/11-manhattan-fixture.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 島 S1・S2 | 6 mm × 3 mm。左右の縁に接して、SMA の中心ピンを載せる |
| 島 P1 | 4 mm × 4 mm。中心は左の縁から 20 mm (寸法線)、上の縁から 15 mm (S1・S2 と同じ高さ) |
| 溝 | 島のまわり 0.5 mm。カッターで 2 本筋を入れて間の銅を剥がす |
| R1 | P1 の下の溝を跨いで、片側を P1、片側を GND の面に半田付け |

- 島は回路図の節点の数だけ要る (CH0 の入口・真ん中・CH1 の出口の 3 つ)。GND の節点は島にしない
- 島を作ったら、テスターで島と GND の面が導通していないことを確かめる。削り残しの銅が短絡を作る
- 島の間はジャンパで渡す。線の長さが L1・L2 になるので、島どうしを寄せて短く渡す
- 図の島は 3 mm 以上の幅で、手で切り出せる。電流は NanoVNA の出力だけで、幅に対して十分小さい

## 掃引の設定

計器は VNA。この題の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜500 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 と S11 の Log Mag |

**Manhattan の治具に 51 Ω** の見えるはずの画面 (図1 の等価回路)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-500M 101
title: 図3 Manhattan の治具 — 300 MHz でも S21 −3.53 dB・S11 −9.33 dB
dut:
  - series L 3n
  - shunt R 51 esl 1n
  - series L 3n
traces:
  - S21 logmag 2dB
  - S11 logmag 2dB
markers:
  - 30M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/11-manhattan-fixture-1.svg)

**3-2 の形の perfboard の治具に 51 Ω** の見えるはずの画面 (同じ設定)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-500M 101
title: 図4 perfboard の治具 — 300 MHz で S21 −6.93 dB・S11 −3.01 dB
dut:
  - series L 26n
  - shunt R 51 esl 15n
  - series L 26n
traces:
  - S21 logmag 2dB
  - S11 logmag 2dB
markers:
  - 30M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/11-manhattan-fixture-2.svg)

- 51 Ω を並列に入れた理想は S21 −3.47 dB・S11 −9.66 dB で平ら (CH0 から見て 51 Ω ∥ 50 Ω = 25.2 Ω)
- 図3 は 300 MHz でも S21 が理想から 0.1 dB も離れず、S11 も 0.3 dB しか動かない。図4 は 100 MHz で離れ始め、300 MHz で S21 が
  3.5 dB 落ち、S11 が 6.6 dB 上がる。違いのほとんどは通り道の 52 nH と戻り道の 15 nH から来る

## 見るべき値

計算値 (図1 と図4 の等価回路、CH1 は 50 Ω で終端)。理想は 51 Ω だけの値。

| 周波数 | 理想 S21 / S11 | Manhattan S21 / S11 | perfboard S21 / S11 |
| --- | --- | --- | --- |
| 30 MHz | −3.47 dB / −9.66 dB | −3.47 dB / −9.65 dB | −3.51 dB / −9.38 dB |
| 100 MHz | 同 | −3.47 dB / −9.62 dB | −3.99 dB / −7.41 dB |
| 300 MHz | 同 | −3.53 dB / −9.33 dB | −6.93 dB / −3.01 dB |

- **S11 の差が大きい**。perfboard の治具は 300 MHz で、反射の 6.6 dB 分が治具のせい。部品の
  値を読む S11 (Smith) がこれだけずれると、51 Ω が 26.0 Ω + j67.9 Ω (並列の 50 Ω を含む) に見える
- Manhattan の治具は 300 MHz で 25.3 Ω + j7.6 Ω。残る +j7.6 Ω は 1 nH と 3 nH の
  ぶんで、ポート延長 (3-7) か De-embedding (3-8) で引ける大きさ
- 島どうしのジャンパを 5 mm から 10 mm に延ばすと、L1・L2 は約 7 nH (経験式) に増える。
  ジャンパは短く、島は寄せて置く

## LTspice での確かめ

`sim/11-manhattan-fixture.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ (マイクロオーム) に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (Manhattan) | 30 MHz | S21 / S11 | −3.47 dB / −9.65 dB | −3.47 dB / −9.65 dB | 合う |
| 図3 | 300 MHz | S21 / S11 | −3.53 dB / −9.33 dB | −3.53 dB / −9.33 dB | 合う |
| 図4 (perfboard) | 100 MHz | S21 / S11 | −3.99 dB / −7.41 dB | −3.99 dB / −7.41 dB | 合う |
| 図4 | 300 MHz | S21 / S11 | −6.93 dB / −3.01 dB | −6.93 dB / −3.01 dB | 合う |
| 図3 / 図4 | 300 MHz | R + jX | 25.3 Ω + j7.6 Ω / 26.0 Ω + j67.9 Ω | 25.28 Ω + j7.56 Ω / 25.97 Ω + j67.88 Ω | 合う |

ジャンパの見積もりは算術で確かめた。直線の導線の経験式 L (nH) ≈ 0.2 l {ln(2l/d) − 0.75} に
l = 5 mm・d = 0.5 mm を入れると 2.9 nH、l = 10 mm で 6.9 nH。perfboard の戻り道 23 mm・d = 0.64 mm は 16.1 nH。

## 出典

自作。島の作り方と考え方は Chuck Adams (K7QO) の [Manhattan Building Techniques](https://www.qrpme.com/docs/K7QO%20Manhattan.pdf) による。
