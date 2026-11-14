---
book: nanovna
chapter: 4
id: 4-21
title: コンデンサの Q と誘電体 (C0G vs X7R)
tier: 200
source: 自作
board: PF
device: H4
---

# 4-21 コンデンサの Q と誘電体 (C0G vs X7R)

同じ 1000 pF (102) の積層セラミックでも、誘電体が **C0G** (温度補償用、NP0 とも) か **X7R** (高誘電率系) かで、
損失がまるで違う。損失の大きさは誘電正接 (DF、tan δ (デルタ)) で書かれ、コンデンサの Q はその逆数 1 / DF になる。
データシートの典型的な値で、C0G は DF 0.1 % 以下 (Q 1000 以上)、X7R は DF 2.5 % 以下 (Q 40 以上)。

1000 pF の X (リアクタンス) は 5 MHz で 31.6 Ω (オーム)。損失分 (ESR) は C0G で 0.03 Ω、X7R で 0.8 Ω ほどになり、
S11 の R の目盛ではどちらも 0 に重なって区別できない。そこで 4-19 と同じく**共振で R を浮かび上がらせる**。
1 µH (マイクロヘンリー) のコイルと直列にして perfboard の並列治具 (3-2) から GND へ落とし、5 MHz の谷の深さを比べる。

## この実験で確かめる式

- 共振 f0 = 1 / (2π√(L·C)) = 1 / (2π√(1 µH·1000 pF)) = 5.033 MHz
- 共振で枝の Z = R (コイルの R とコンデンサの ESR の和)。S21 = R / (R + 25)、逆に R = 25·\|S21\| / (1 − \|S21\|)
- コンデンサの ESR = DF / (2πf0·C) = DF × 31.6 Ω。Q = 1 / DF

**差で読む**: コイルの R (約 0.63 Ω) は 2 つのコンデンサより大きく、しかも正確には分からない。
同じコイルで C0G と X7R を付け替えて測り、R の**差**を X7R と C0G の ESR の差とする。C0G の ESR は小さいので、差はほぼ X7R の ESR になる。

| 部品 (模型。目安) | 値 | 損失 | 5.033 MHz での R |
| --- | --- | --- | --- |
| L1 コイル | 1 µH | Q 50 (仮定) | 0.632 Ω |
| C1 (C0G) | 1000 pF | DF 0.1 % (Q 1000) | 0.032 Ω |
| C1 (X7R) | 1000 pF | DF 2.5 % (Q 40) | 0.791 Ω |

DF は 1 kHz で決められた仕様の上限を 5 MHz に当てはめた目安で、実物の DF は周波数・電圧・温度で変わる。
コイルの Q 50 もアキシアルの小型コイルの目安 (4-4 で測れる)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 並列治具からコイルとコンデンサの直列を GND へ
parts:
  J1: sma 2,2 mirror CH0
  J2: sma 8,2 CH1
  L1: inductor 5,2.75 5,3.75 1u
  C1: capacitor 5,3.75 5,4.75 1000p
  G1: ground 2,3
  G2: ground 8,3
  G3: ground 5,5.25
wires:
  - J1.1 -- 5,2 -- J2.1
  - 5,2 -- 5,2.75
  - 5,4.75 -- 5,5.25
  - J1.2 -- 2,3
  - J2.2 -- 8,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/21-c0g-vs-x7r-q.svg)

- C1 は C0G と X7R を付け替える。L1 は付けたままにする (差で読むため)
- 図に描かない分: L1 の R と C1 の ESR。画面の模型では ESR の欄にまとめて書く

## 実体配線図

3-2 の並列治具の、R1 の代わりに L1 と C1 を直列に入れる。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の並列治具に L1 と C1 の直列
points:
  GND: b4
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  L1: inductor/axial h10 h7 1u
  C1: capacitor/ceramic k7 k4 1000p
wires:
  - a10 -- h10
  - h10 -- x10
  - h7 -- k7 yellow
  - 09 -- b9 black
  - b9 -- GND black
  - GND -- k4 black
  - k4 -- o4 black
  - o4 -- o9 black
  - o9 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/21-c0g-vs-x7r-q.svg)

- 10 行を J1 (CH0) から J2 (CH1) まで一直線に通し、h10 から L1 を下ろす。L1 と C1 の間は黄の線 1 本
- C1 は差し替えるので、リードは 5 mm ほど残して半田付けし、外しやすくする。2 つのリードの長さはそろえる
  (5 MHz ではリードの数 nH は 1 µH に比べて無視できる)

## 部品

| 部品 | 値 | 備考 |
| --- | --- | --- |
| L1 | 1 µH、アキシアルの小型コイル | E12 |
| C1 (1 つめ) | 1000 pF (102)、C0G、リード付き積層セラミック | E12 |
| C1 (2 つめ) | 1000 pF (102)、X7R、リード付き積層セラミック | E12。容量の許容差は ±10 % が多い |
| J1・J2 | 端面 SMA (メス) | 2 個 |
| 基板 | 5×7 cm のユニバーサル基板 | 3-2 の治具 |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 2 MHz〜8 MHz |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で |
| 表示 | S21 の Log Mag |

- 谷の底の 1 点で読むので、谷の前後 ±0.5 MHz を 101 点で掃引し直し、一番低い点を読む
- 低い周波数のシャントの測定では、ケーブルの外皮を通って CH0 と CH1 の GND の間に回る電流が、谷を浅く見せることがある。
  CH1 側のケーブルにフェライトコアを通して比べ、谷の深さが変わらないことを確かめる (目安)

C0G のときの見えるはずの画面 (理想の模型。R = 0.664 Ω)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 2M-8M 401
title: 図3 C0G — 5.033 MHz で −31.7 dB (R = 0.66 Ω)
dut:
  - shunt C 1000p esr 0.664 esl 1u
traces:
  - S21 logmag
markers:
  - 5.033M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/21-c0g-vs-x7r-q-1.svg)

X7R に付け替えたときの画面 (R = 1.423 Ω)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 2M-8M 401
title: 図4 X7R — 谷は −25.4 dB まで浅くなる (R = 1.42 Ω)
dut:
  - shunt C 1000p esr 1.423 esl 1u
traces:
  - S21 logmag
markers:
  - 5.033M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/21-c0g-vs-x7r-q-2.svg)

## 見るべき値

計算値 (模型は上の表)。

| C1 | S21 の谷 (5.033 MHz) | R (谷から) | C1 の ESR (差から) | C1 の Q |
| --- | --- | --- | --- | --- |
| C0G | −31.74 dB | 0.664 Ω | (基準。0.032 Ω と仮定) | 1000 |
| X7R | −25.38 dB | 1.423 Ω | 1.423 − 0.664 + 0.032 = 0.791 Ω | 40 |

分かること:

- **谷の深さが 6.4 dB 違う。** X7R の ESR はコイルの R より大きく、谷を浅くする。測った谷から R を出し、差を取れば X7R の ESR が出る
- C0G の ESR (0.03 Ω) はこの方法では読めない (コイルの 0.63 Ω に埋もれる)。C0G の Q を測るなら、Q の高いコイル (空芯・
  トロイダルの T 材。4-14) を使い、コイルの R を先に別のコンデンサで見積もる
- **X7R を共振回路に使うと Q が 40 で頭打ちになる。** フィルタ・発振回路・同調回路のコンデンサに C0G を使う理由。
  X7R はデカップリング (4-8) のように、損失がむしろ役に立つ所や、容量の精度が要らない所に使う
- X7R の容量は ±10 % のばらつきに加え、直流の電圧と温度で大きく動く。測った f0 が 5.033 MHz からずれたら、
  C = 1 / ((2πf0)²·L) で容量を逆算する (L は C0G のときの f0 から先に求めておく)
- 1 kHz の LCR メーターで測る DF と、5 MHz の VNA で測る DF は同じとは限らない。この題の 0.791 Ω は仕様の上限を当てはめた見積りで、
  実物の値を測って比べるのが題の目的

## LTspice での確かめ

`sim/21-c0g-vs-x7r-q.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。
LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (C0G) | 5.033 MHz | S21 | −31.74 dB | −31.74 dB | 合う |
| 図4 (X7R) | 5.033 MHz | S21 | −25.38 dB | −25.38 dB | 合う |

2 点とも合う。f0・ESR = DF × 31.6 Ω・谷から R を逆算する式は算術で確かめた。

## 出典

自作。DF の値は積層セラミックの一般的な仕様 (C0G は 0.1 % 以下、X7R は 2.5 % 以下) を目安に使った。

参考: [Wikipedia "Ceramic capacitor"](https://en.wikipedia.org/wiki/Ceramic_capacitor)、[Wikipedia "Dissipation factor"](https://en.wikipedia.org/wiki/Dissipation_factor)、[Wikipedia「Q 値」](https://ja.wikipedia.org/wiki/Q値)
