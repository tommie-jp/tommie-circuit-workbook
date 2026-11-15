---
book: nanovna
chapter: 4
id: 4-26
title: トランス型バランの S21 と平衡度
tier: 200
source: 自作
board: PF
device: H4
---

# 4-26 トランス型バランの S21 と平衡度

**バラン** (balun = balanced–unbalanced) は、片側が GND の**不平衡** (同軸) と、GND に対して
対称な 2 本の**平衡** (ダイポールのアンテナ・平行 2 線) をつなぐ部品である。**トランス型**は 1 次と 2 次の
巻線が直流で切れている形で、4-10 の 1:1 トランスの 2 次の両端 (B1・B2) を GND から浮かせれば
そのままバランになる。

バランの良し悪しは**平衡度**で決まる。平衡の 2 本 (P と N) に出る信号は、理想なら**大きさが同じで、
位相がちょうど 180° 違う**。VNA の CH1 は片側が GND の 1 本しか受けられないので、P と N を
**1 本ずつ測って比べる**:

- 測り方 P: CH1 を P (B1) に繋ぎ、N (B2) は 50 Ω で GND へ落とす
- 測り方 N: CH1 を N (B2) に繋ぎ、P (B1) は 50 Ω で GND へ落とす

2 回とも平衡の側は CH1 の 50 Ω と抵抗の 50 Ω で、合わせて 100 Ω を負荷にしている (平衡の 100 Ω に
1:1 で繋いだ形)。そろえるのは 2 回の**負荷が同じ**ことで、50 Ω の整合ではない。

大きさの差 20 log(\|S21<sub>P</sub>\| / \|S21<sub>N</sub>\|) を**振幅の不平衡**、位相の差の 180° からの
ずれを**位相の不平衡**と呼ぶ。崩す原因は巻線どうしの容量で、2 本撚りの巻き始め (A1 と B1) と
巻き終わり (A2 と B2) が隣り合うので、CH0 の信号が容量を通って P の側にだけ多く漏れる。

この題で使う模型は 4-10 と同じ巻き方 (FT37-43 に 2 本撚り 8 回) で、次の値とする (目安)。

| 量 | 値 | 根拠 |
| --- | --- | --- |
| 励磁インダクタンス | 22.4 µH | A<sub>L</sub> 350 nH/回² × 8² (4-10) |
| 漏れインダクタンス | 50 nH ずつ (1 次と 2 次) | 4-10 の見積もり |
| 巻線の間の容量 | A1–B1 と A2–B2 に 5 pF ずつ | 撚り線 30 cm ほどの容量を両端に半分ずつ置いた見積もり |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 トランス型バランの平衡度を測る (測り方 P)
parts:
  J1: sma 2,2 mirror CH0
  T1: transformer 5,2
  J2: sma 9,2 CH1
  R1: resistor 7,3.5 7,5 50
  G1: ground 2,3
  G2: ground 4,3
  G3: ground 7,5
  G4: ground 9,3
wires:
  - J1.1 -| T1.A1
  - T1.A2 -| 4,3
  - T1.B1 |- J2.1
  - T1.B2 -| 7,3.5
  - J1.2 -- 2,3
  - J2.2 -- 9,3
notes:
  - text 6.5,1.3 center: P
  - text 6.5,2.9 center: N
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/26-transformer-balun.svg)

- T1 の 2 次 (B1・B2) は GND に繋がない。B1 が P、B2 が N
- 測り方 N では、J2 (CH1) と R1 を**入れ替える** (B2 を CH1 に、B1 を R1 に)
- R1 の 50 Ω は 100 Ω を 2 本並列にして作る (E24 に 50 Ω が無いため)

## 実体配線図

4-10 のユニバーサル基板の 2 次の GND を外し、B2 (k8) から R1・R2 (100 Ω の並列) を通して GND へ落とす。
GND の筋は 4 行目を回す。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 4-10 のトランスの 2 次を浮かせて平衡度を測る (測り方 P)
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  T1: transformer/toroid f10 f8 k10 k8 FT37-43 8t
  R1: resistor m8 m5 100
  R2: resistor o8 o5 100
wires:
  - a10 -- f10
  - k10 -- x10
  - k8 -- m8
  - m8 -- o8
  - f8 -- f4 black
  - m5 -- m4 black
  - o5 -- o4 black
  - 09 -- 04 black
  - 04 -- f4 black
  - f4 -- m4 black
  - m4 -- o4 black
  - o4 -- y4 black
  - y4 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/26-transformer-balun.svg)

- 巻き始め (A1・B1) が上の 10 行目、巻き終わり (A2・B2) が 8 行目 (4-10 と同じ)
- 測り方 N に替えるときは、k10–x10 と k8–m8 の 2 本を外し、k8–x10 と k10–m8 に付け替える。
  付け替えの線の長さが P と N でそろうように引く (長さの差がそのまま位相の差に出る)

## 部品

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| T1 | FT37-43 に 0.4 mm のポリウレタン線を 2 本撚りで 8 回 | 4-10 と同じ物。巻き始めの 2 本が A1・B1 |
| R1・R2 | 100 Ω (金属皮膜) を 2 本並列 = 50 Ω | 平衡の片側の終端。CH1 の 50 Ω とそろえる |
| J1・J2 | 端面の SMA (メス) | 3-1 と同じ |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜150 MHz |
| 点数 | 299 (0.5 MHz おき) |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag (1 dB/目盛) と位相 |
| 手順 | 測り方 P で掃引して Touchstone に保存 (2-5)、線を付け替えて測り方 N で同じく保存。2 つのファイルを並べて差を読む |

**測り方 P** の、巻線の容量の無い理想の画面。理想では測り方 N も大きさが同じで、位相が 180° ずれるだけ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-150M 299
title: 図3 測り方 P (容量なしの理想) — 帯域の中で S21 は −3.5 dB
dut:
  - series L 50n
  - shunt L 22.4u
  - series L 50n
  - series R 50
traces:
  - S21 logmag 1dB
  - S21 phase
markers:
  - 1M
  - 30M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/26-transformer-balun.svg)

−3.5 dB は損失ではない。平衡の 100 Ω のうち CH1 に掛かるのは半分 (P か N の片側) なので、
\|S21\| = 2 × (2/3) × (1/2) = 2/3 になる。1 MHz で少し下がるのは励磁インダクタンス、
100 MHz で下がるのは漏れインダクタンスのせい (4-10 と同じ)。

**平衡度** — 巻線の容量 (5 pF ずつ) を入れて、測り方 P と N の差を計算した値。VNA の画面ではなく、
2 つの Touchstone から読む量なのでグラフで示す。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 平衡度 — 30 MHz で 0.12 dB・5.4°、100 MHz で 1.40 dB・19.5°
x: 周波数 Hz log 1M..150M
y:
  - 振幅の不平衡 dB
  - 位相の不平衡 deg
lines:
  N と P の大きさの差 dB:
    - 1M 0.00
    - 3M 0.00
    - 10M 0.01
    - 30M 0.12
    - 50M 0.33
    - 70M 0.66
    - 100M 1.40
    - 150M 3.53
  180° からのずれ deg:
    - 1M 0.2
    - 3M 0.5
    - 10M 1.8
    - 30M 5.4
    - 50M 9.2
    - 70M 13.1
    - 100M 19.5
    - 150M 33.5
notes:
  - mark 30M
  - mark 100M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/graph/26-transformer-balun.svg)

## 見るべき値

計算値。図3 は理想の模型 (容量なし)、図4 は巻線の容量を入れた模型 (LTspice と同じ回路を数値で解いた値)。

| 周波数 | 図3 の S21 (理想) | 図3 の位相 | P の \|S21\| | N の \|S21\| | 振幅の不平衡 | 位相の不平衡 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 MHz | −3.77 dB | +13.1° | −3.77 dB | −3.77 dB | 0.00 dB | 0.2° |
| 30 MHz | −3.60 dB | −6.7° | −3.65 dB | −3.53 dB | 0.12 dB | 5.4° |
| 100 MHz | −4.23 dB | −22.6° | −4.99 dB | −3.59 dB | 1.40 dB | 19.5° |

分かること:

- **低い周波数ではほぼ完全に平衡** (10 MHz まで振幅 0.01 dB・位相 2° 以内)。
  トランス型は 2 次が直流でも RF でも GND から浮いているので、P と N を巻線が対称に作る
- **周波数が上がると P の側が小さくなり、位相もずれる。** 巻き始めの容量 (A1–B1) が CH0 の信号を
  P へ直に漏らし、これが巻線を通った信号と打ち消し合う。巻き終わりの側 (A2–B2) は A2 が GND なので
  N を GND へ少し落とすだけで、効き方が非対称になる
- 平衡度の目安は使い道で決まる。アンテナの給電なら、位相の不平衡が 10° を超えると同軸の外皮に
  電流が流れ始める (コモンモード。4-11 のチョークで止める)。この模型なら 50 MHz あたりまでが使える範囲
- 容量を減らすには、撚りを緩める・巻き数を減らす (低い側は下がる、4-10)・巻き方を対称にする
  (2 次を真ん中で分けて 1 次を挟む) などがある。どれも図4 の線がどれだけ下がるかで比べられる

## LTspice での確かめ

`sim/26-transformer-balun.cir` で、図3 の `dut:` の梯子と、結合コイル (K、k = 22.4 / 22.45) に巻線の容量を
足した測り方 P と N の回路を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図・表の値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1 MHz | S21 / 位相 | −3.77 dB / +13.1° | −3.77 dB / 13.1° | 合う |
| 図3 | 30 MHz | S21 / 位相 | −3.60 dB / −6.7° | −3.60 dB / 6.7° | 合う (大きさ) |
| 図3 | 100 MHz | S21 / 位相 | −4.23 dB / −22.6° | −4.23 dB / 22.6° | 合う (大きさ) |
| 図4 | 30 MHz | P / N の \|S21\| | −3.65 dB / −3.53 dB | −3.65 dB / −3.53 dB | 合う |
| 図4 | 100 MHz | P / N の \|S21\| | −4.99 dB / −3.59 dB | −4.99 dB / −3.59 dB | 合う |
| 図4 | 30 MHz | P / N の位相 | −4.9° / +169.6° | 4.9° / 169.6° | 合う (大きさ) |
| 図4 | 100 MHz | P / N の位相 | −17.5° / +143.0° | 17.5° / 143.0° | 合う (大きさ) |

大きさ (dB) は 7 行すべて合う。LTspice の .meas が返す位相は符号の無い値だったので、位相は大きさだけを比べ、
符号は同じ回路を節点方程式で解いた値 (表の左) から読んだ。図4 の不平衡はその値から
20 log(\|S21<sub>P</sub>\| / \|S21<sub>N</sub>\|) と ∠S21<sub>P</sub> − ∠S21<sub>N</sub> − 180° で計算した。

## 出典

自作。FT37-43 の A<sub>L</sub> は[フェライトコアのメーカー (Fair-Rite) の 43 材のデータシート](https://www.fair-rite.com/43-material-data-sheet/)の表の値 (4-10 と同じ)。

参考: [Wikipedia「バラン」](https://ja.wikipedia.org/wiki/バラン)、[Wikipedia "Balun"](https://en.wikipedia.org/wiki/Balun)
