---
book: nanovna
chapter: 4
id: 4-19
title: 空芯コイルの Q を 1 GHz 手前まで
tier: 200
source: 自作
board: CB
device: H4
---

# 4-19 空芯コイルの Q を 1 GHz 手前まで

4-4 ではコイルの Q を \|Z\| と R・X の比 (Q = X / R) で読んだ。この方法は Q が数十までなら使えるが、
空芯コイルの Q は数百になる。X が 100 Ω (オーム) のとき R は 0.3 Ω ほどで、S11 の R の目盛ではほとんど 0 に重なって読めない。

ここでは**共振で R を浮かび上がらせる**。コイルに C0G のチップのコンデンサを直列にして、銅張り基板の
マイクロストリップから GND へシャントに落とす。共振ではコイルの X とコンデンサの X が打ち消し合い、
枝に残るのは R だけになる。その R が S21 の谷の深さになって見える (4-17 と同じシャントの治具)。
コンデンサを 3 つ替えて共振を 285 MHz・543 MHz・806 MHz に置き、H4 で Q の周波数の変わり方を見る。

## この実験で確かめる式

枝 (コイル L・コンデンサ C・全体の損失 R の直列) を 50 Ω の線路から GND へ落とすと

- 共振 f0 = 1 / (2π√(L·C)) で枝の Z = R。S21 = R / (R + 25) (シャントの式 2Z / (2Z + 50) に Z = R を入れた)
- 谷の深さ \|S21\| から R を逆算する: **R = 25·\|S21\| / (1 − \|S21\|)**
- コイルの R = R − (コンデンサの ESR)。コイルの Q = 2πf0·L / (コイルの R)

谷の**幅**は使わない。線路の 50 Ω と 50 Ω が並列に 25 Ω で枝に掛かり、谷の Q は 2πf0·L / 25 ≈ 2〜5 しかない。
幅から読めるのは 25 Ω を含めた Q で、コイルの Q ではない。

## 回路図

治具の等価回路 (12 pF のとき)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 空芯コイルとチップのコンデンサを直列にシャントへ (等価回路)
parts:
  J1: sma 2,2 mirror CH0
  T1: tline 3,2 6,2 50 l=$\mathrm{20mm}$
  T2: tline 6,2 9,2 50 l=$\mathrm{20mm}$
  J2: sma 10,2 CH1
  L1: inductor 6,2.75 6,3.75 25n
  C1: capacitor 6,3.75 6,4.75 12p
  G1: ground 2,3
  G2: ground 10,3
  G3: ground 6,5.25
wires:
  - J1.1 -- 3,2
  - 9,2 -- J2.1
  - 6,2 -- 6,2.75
  - 6,4.75 -- 6,5.25
  - J1.2 -- 2,3
  - J2.2 -- 10,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/19-air-coil-q.svg)

- L1 は手巻きの空芯コイル。C1 は 12 pF・3.3 pF・1.5 pF を付け替える
- 図に描かない分: C1 の ESL とパッド・via のインダクタンス (合わせて約 1 nH。4-17 の目安) と、
  損失 R (コイルの R と C1 の ESR)。画面の模型では、1 nH を L1 に足して 26 nH とし、R を ESR の欄に書く

## 実体配線図

4-17 と同じく 5×7 cm の両面の銅張り基板から 40 mm × 20 mm を切り出す。線路の下に 2 つの島を残し、
コイル → 島 P1 → コンデンサ → 島 P2 → via → 裏の GND とつなぐ。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 40x20mm
  ground: back
title: 図2 空芯コイル LC と C1 を直列にシャントへ落とす
f: 806M
copper:
  L1: line 0,8 40,8 3.06mm
  P1: pad 20,14 3x3mm
  P2: pad 20,17.5 7x3mm
  V1: via 17.5,18
  V2: via 22.5,18
parts:
  J1: sma left 8 CH0
  J2: sma right 8 CH1
  LC: inductor 20,9 P1 25n
  C1: capacitor/1608 20,16 r90 12p
notes:
  - dim 0,4 20,4
  - text 23,13: LC は空芯 3 回巻き
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/copper/19-air-coil-q.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、40 mm × 20 mm。裏は全面の銅 (GND) |
| 線 L1 | 表の中央に幅 3.06 mm・長さ 40 mm (計算値 50 Ω) |
| 島 P1・P2 | P1 は 3 mm × 3 mm、P2 は 7 mm × 3 mm。0.5 mm の溝で分ける。P2 だけ両端に直径 0.8 mm の via を 2 本 |
| LC (空芯コイル) | 線の下の縁 (左端から 20 mm) から P1 へ、基板から 3 mm ほど浮かせて半田付けする。コイルの軸は線と平行にする |
| C1 | P1 と P2 を跨いで載せる。12 pF → 3.3 pF → 1.5 pF の順に付け替える |
| 端面 SMA (J1・J2) | 左右の縁。中心ピンを線の端へ、外皮の脚は裏のベタへ |

- 銅張り基板にするのは、800 MHz で 50 Ω の線路と面の GND が要るから (perfboard は 300 MHz くらいまで、3-6)
- コイルを基板に寝かせると、裏の GND の面に渦電流が流れて L も Q も下がる。浮かせる高さを決めて、3 つの測定で変えない

## 部品

| 部品 | 値 | 備考 |
| --- | --- | --- |
| LC | 空芯コイル 約 25 nH | 直径 0.6 mm のエナメル線 (またはスズめっき線) を 3 回巻き。内径 3 mm (3 mm のドリルの刃に巻く)、長さ 3 mm、リードは 3 mm ずつ。L は Wheeler の式の計算値 (目安) |
| C1 | 12 pF・3.3 pF・1.5 pF の C0G、1608 | 3 つを付け替える。ESR は 0.1 Ω と仮定する |
| J1・J2 | 端面 SMA (メス) | 2 個 |
| 基板 | 両面 FR4 1.6 mm | 40 mm × 20 mm |

コイルの R の見積り (目安): 線の長さ約 40 mm、表皮の深さ δ (デルタ) は 300 MHz で 3.8 µm (マイクロメートル)。表皮効果だけなら
300 MHz で 0.096 Ω、隣の巻線に電流が寄る近接効果で約 3 倍になるとして 0.29 Ω。R は √f に比例して増える。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜1 GHz で谷を探し、図3 は 100〜450 MHz、図4 は 600 MHz〜1 GHz に絞る |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で |
| 表示 | S21 の Log Mag |

- H4 のダイナミックレンジは 900 MHz まで 60 dB (第 9 章の 9-4 で測る)。谷は −33〜−37 dB なので、どれも読める
- 谷の底を正しく読むため、谷の前後 ±20 MHz を 101 点で掃引し直し、一番低い点を読む

12 pF のときの見えるはずの画面 (理想の模型。R = 0.380 Ω)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 100M-450M 401
title: 図3 C1 = 12 pF — 284.9 MHz で −36.5 dB (R = 0.38 Ω)
dut:
  - shunt C 12p esr 0.380 esl 26n
traces:
  - S21 logmag
markers:
  - 284.9M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/19-air-coil-q-1.svg)

1.5 pF に付け替えたときの画面 (R = 0.571 Ω)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 600M-1G 401
title: 図4 C1 = 1.5 pF — 805.9 MHz で −33.0 dB (R = 0.57 Ω)
dut:
  - shunt C 1.5p esr 0.571 esl 26n
traces:
  - S21 logmag
markers:
  - 805.9M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/19-air-coil-q-2.svg)

## 見るべき値

計算値 (模型: L = 26 nH、コイルの R は √f に比例、C1 の ESR は 0.1 Ω と仮定)。

| C1 | f0 | S21 の谷 | R (谷から) | コイルの R | 2πf0·L (25 nH) | コイルの Q |
| --- | --- | --- | --- | --- | --- | --- |
| 12 pF | 284.9 MHz | −36.49 dB | 0.380 Ω | 0.280 Ω | 44.8 Ω | 160 |
| 3.3 pF | 543.4 MHz | −34.38 dB | 0.487 Ω | 0.387 Ω | 85.4 Ω | 221 |
| 1.5 pF | 805.9 MHz | −33.02 dB | 0.571 Ω | 0.471 Ω | 126.6 Ω | 269 |

分かること:

- **Q は周波数とともに上がる。** X は f に比例し、R は表皮効果で √f にしか比例しないので、Q は √f で増える
  (285 → 806 MHz で √2.83 = 1.68 倍、160 → 269)。実物では、さらに上でコイルの巻線の容量と放射が効いて Q は頭打ちになる
- **コンデンサの ESR の仮定がそのまま Q の誤差になる。** ESR を 0.1 Ω でなく 0.2 Ω とすると、12 pF の Q は
  160 から 249 になる。メーカーの ESR-f のグラフを見て差し引く。迷うなら同じ C1 を 2 個並列に載せ、
  谷の深さの変わり方から ESR を見積もる
- f0 から L を逆算する: L = 1 / ((2πf0)²·C)。3 つの f0 で求めた L が合わなければ、C1 の誤差 (1.5 pF で ±0.1 pF) と
  パッドの浮遊容量 (約 0.1〜0.2 pF。目安) が効いている。1 pF にすれば 1 GHz の手前に届くが、この浮遊容量が C1 の 1〜2 割になる
- 谷の深さは −33〜−37 dB。深さが 1 dB 違うと R は約 12 % 違う。谷の底を細かい掃引で読むのはこのため

## LTspice での確かめ

`sim/19-air-coil-q.cir` で、3 つの共振の枝を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。
LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (12 pF) | 284.9 MHz | S21 | −36.49 dB | −36.49 dB | 合う |
| 図なし (3.3 pF) | 543.4 MHz | S21 | −34.38 dB | −34.36 dB | 合う |
| 図4 (1.5 pF) | 805.9 MHz | S21 | −33.02 dB | −33.01 dB | 合う |

3 点すべて合う。コイルの L (Wheeler の式)・表皮の深さ・R の見積り・谷から R を逆算する式は算術で確かめた (LTspice では見ていない)。

## 出典

自作。空芯コイルの L は Wheeler の近似式による。

参考: [Wikipedia「Q 値」](https://ja.wikipedia.org/wiki/Q値)、[Wikipedia「表皮効果」](https://ja.wikipedia.org/wiki/表皮効果)、[Wikipedia "Inductor"](https://en.wikipedia.org/wiki/Inductor)
