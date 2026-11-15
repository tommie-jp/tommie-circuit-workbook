---
book: nanovna
chapter: 8
id: 8-13
title: ダイオード検波器の S11
tier: 200
source: 自作。1N5711 の値は STMicroelectronics のデータシート
board: PF
device: H4
---

# 8-13 ダイオード検波器の S11

> **値は LTspice と式で出したもので、実機では測っていない。** ダイオードの模型 (直列抵抗 25 Ω (オーム) など) と、リードと基板の
> インダクタンス 6 nH は仮定。

高周波の電力を直流の電圧に変える一番簡単な回路が**ダイオード検波器** (ショットキーダイオード 1 本とコンデンサ)。RF の電力計、
AGC、SWR 計の読み出しに使う。ダイオードは小さな信号ではほとんど電流を流さないので、**そのままでは入力がほぼ開放 (S11 ≈ 0 dB)** で、
来た電力のほとんどを跳ね返す。そこで入力に **51 Ω を並列**に置いて、50 Ω の系に合わせる。
この題では、その 51 Ω の有る無しで S11 がどう変わるかを NanoVNA で測り、**検波器が 50 Ω の負荷として働く周波数の上限**を読む。

## この実験で確かめる式

ダイオードは 1N5711 (ショットキー、DO-35)。0 V での接合容量は**最大 2 pF** (1 MHz、データシート)。

- **ダイオードの小信号の抵抗** R<sub>j</sub> = n V<sub>T</sub> / I<sub>S</sub>。バイアスをかけない検波器では I<sub>S</sub> が小さいので R<sub>j</sub> は MΩ 以上で、
  入力から見えるのは**接合容量 C<sub>j</sub> (2 pF) とリードのインダクタンスと直列抵抗**だけ。C1 (1 nF) は出力を交流的に GND に落とすので、
  C<sub>j</sub> の先は GND とみてよい
- **51 Ω が無いとき**: 入力は 2 pF の容量 (1 MHz で 80 kΩ、300 MHz で 265 Ω)。S11 は 0 dB に近く、Smith の右端 (開放) から
  下 (容量性) へ少しずつ回る
- **51 Ω があるとき**: 低い所では 51 Ω の並列そのもので **S11 = (51 − 50) / (51 + 50) → −40 dB**。周波数を上げると C<sub>j</sub> が 51 Ω に
  並列に効いて S11 が上がる。−20 dB (SWR 1.22) を超えるのが**この検波器の上限の目安**で、約 300 MHz

**入れる電力で変わる**: 上の値は小信号 (0 V のまわり) のもの。CH0 の出力 (0 dBm より小さい。0-3) を入れると、ダイオードが少し整流して
C1 が充電され、平均の電流が流れて R<sub>j</sub> が下がる。51 Ω が無いときは、この変化が S11 の読みに出る (51 Ω があれば隠れる)。
VNA の出力を下げられる機種なら、下げて測る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ショットキーダイオードの検波器 (入力に 51 Ω の終端)
parts:
  J1: sma 2,3 mirror CH0
  R1: resistor 4,3 4,5 51
  D1: schottky 5,3 7,3 1N5711
  C1: capacitor 8,3 8,5 1n
  RL: resistor 10,3 10,5 10k
  OUT: port 12,3 out
  G1: ground 2,4
  G2: ground 4,5
  G3: ground 8,5
  G4: ground 10,5
wires:
  - J1.1 -- 4,3 -- 5,3
  - 7,3 -- 8,3 -- 10,3 -- 12,3
  - J1.2 -- 2,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/13-diode-detector-s11.svg)

- R1 (51 Ω) が入力の終端。**これを外すと検波器は 50 Ω の系から見てほぼ開放**になる (下の図4)
- D1 のアノードが入力、カソードが出力。正の半周期で C1 が充電され、OUT に正の直流が出る
- C1 (1 nF) と RL (10 kΩ) が出力のフィルタと放電の道。時定数は 10 µs
- OUT の直流はテスターで読む (この題では S11 だけを見る)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  silk: board
  slots: on
title: 図2 ユニバーサル基板に組む (部品面。端面 SMA 1 つ)
parts:
  J1: sma/female-edge a10 09
  R1: resistor c10 c7 51
  D1: diode e10 h10 1N5711
  C1: capacitor j10 j7 1n
  RL: resistor l10 l7 10k
wires:
  - a10 -- c10
  - c10 -- e10
  - h10 -- j10
  - j10 -- l10
  - l10 -- n10
  - 09 -- b9 black
  - b9 -- b5 black
  - b5 -- c5 black
  - c5 -- j5 black
  - j5 -- l5 black
  - l5 -- n5 black
  - c7 -- c5 black
  - j7 -- j5 black
  - l7 -- l5 black
notes:
  - mark n10 yellow
  - text n11 red large bold center: OUT
  - mark n5 yellow
  - text n4 red large bold center: GND
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/13-diode-detector-s11.svg)

- **R1 は SMA の中心ピンのすぐ隣 (c 列) に、リードを短く**。ここから SMA までの線が長いと、その線が 51 Ω の手前の線路になり、上の周波数で S11 が崩れる
- D1 のカソード (帯のある側) は h10。ダイオードのリードも短く切る (リード 1 cm でおよそ 6〜8 nH の目安)
- GND の筋は 5 行目。SMA の腕 (`09`) から最短で下ろす
- 黄色の丸は、テスターを当てる所 (OUT と GND)。常には配線しない

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1 | ショットキーダイオード (DO-35) | 1N5711 (70 V、接合容量 2 pF 以下) |
| R1 | 抵抗 (1/4 W) | 51 Ω |
| C1 | 積層セラミックコンデンサ | 1 nF (102) |
| RL | 抵抗 (1/4 W) | 10 kΩ |
| J1 | SMA コネクタ (端面実装) | — |

## 掃引の設定

計器は VNA (NanoVNA-H4。LiteVNA64 でも同じ)。1 ポート (S11) だけを使い、CH1 は使わない。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (perfboard の治具の上限の目安まで。3-6) |
| 点数 | 201 |
| 校正 | SOL (Open・Short・Load) を CH0 のケーブルの先で |
| 表示 | S11 の Log Mag と Smith |
| 順番 | R1 を付けて測り (図3)、R1 を外して測る (図4) |

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 201
title: 図3 R1 (51 Ω) あり — 100 MHz で −30 dB、300 MHz で −20 dB
dut:
  - shunt R 51
  - shunt C 2p esr 25 esl 6n
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/13-diode-detector-s11-1.svg)

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 201
title: 図4 R1 なし — ほぼ開放 (300 MHz で −0.3 dB)
dut:
  - shunt C 2p esr 25 esl 6n
  - open
traces:
  - S11 logmag 0.1dB
  - S11 smith
markers:
  - 1M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/13-diode-detector-s11-2.svg)

- 図3 の Smith の点は中心のすぐ近くから、周波数とともに下 (容量性) へ動く。図4 は右端 (開放) から外周に沿って下へ回る
- 図4 の S11 が 0 dB に届かず 300 MHz で −0.3 dB なのは、ダイオードの直列抵抗 (25 Ω の仮定) で電力が少し吸われるため

## 見るべき値

計算値 (LTspice と図の読み値。どちらも同じ模型)。

| 周波数 | S11 (R1 あり) | S11 (R1 なし) |
| --- | --- | --- |
| 1 MHz | −40.1 dB | −0.00 dB |
| 100 MHz | −29.6 dB | −0.03 dB |
| 300 MHz | −20.3 dB (48.3 − j9.4 Ω) | −0.32 dB (25 − j254 Ω) |

- **R1 ありで −20 dB を切るのが 300 MHz**。これより上で使うなら、ダイオードを C<sub>j</sub> の小さな品に替えるか、銅張り基板でリードを無くす
- 図4 で、CH0 の出力を上げると S11 が少し下がる (整流で R<sub>j</sub> が下がる) なら、ダイオードが働いている証拠。図3 では変わらない
- 300 MHz での R1 なしの −j254 Ω から容量を逆算すると 2.1 pF (C<sub>j</sub> 2 pF とリードのぶん)。測った値が大きければ基板の浮遊容量 (4-16) を足す

## LTspice での確かめ

`sim/13-diode-detector-s11.cir` で図1 を `.ac` にかけた (信号源 2 V・50 Ω で入射波を 1 にし、S11 = V(in) − 1)。R1 は 51 Ω と、
外したのと同じ 1 GΩ の 2 通り。1N5711 の模型 (I<sub>S</sub> 0.2 nA・直列抵抗 25 Ω・C<sub>JO</sub> 2 pF) とリードの 6 nH は仮定。実測ではない。

| 項目 | 図の読み値 (check) | LTspice | 判定 |
| --- | --- | --- | --- |
| S11、R1 あり、1 MHz | −40.08 dB (図3) | −40.08 dB | 合う |
| S11、R1 あり、100 MHz | −29.63 dB (図3) | −29.64 dB | 合う |
| S11、R1 あり、300 MHz | −20.26 dB、48.2 − j9.4 Ω (図3) | −20.28 dB、48.3 − j9.4 Ω | 合う |
| S11、R1 なし、300 MHz | −0.32 dB、25.0 − j253.9 Ω (図4) | −0.32 dB、25.0 − j254 Ω | 合う |

## 出典

- [STMicroelectronics, 1N5711 データシート (2001)](https://web.archive.org/web/20201019161825/https://www.st.com/resource/en/datasheet/1n5711.pdf) (Internet Archive の写し):
  逆耐圧 70 V、V<sub>F</sub> 0.41 V 以下 (1 mA)、接合容量 2 pF 以下 (0 V・1 MHz)

参考: [Detector (radio) (Wikipedia)](https://en.wikipedia.org/wiki/Detector_(radio))
