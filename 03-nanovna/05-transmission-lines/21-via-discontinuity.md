---
book: nanovna
chapter: 5
id: 5-21
title: スルーホール (via) の不連続
tier: 200
source: 自作
board: CB
device: V2
---

# 5-21 スルーホール (via) の不連続

両面の銅張り基板で、表の銅を裏の GND へ落とすには穴を開けて線を通し、表と裏を半田付けする。
この **via** (スルーホール) は、基板の厚さ 1.6 mm ぶんの短い線で、GHz では無視できない
**インダクタンス**を持つ。バイパスのコンデンサやアンテナの GND を via で落とすと、
「GND につないだつもり」が数 Ω (オーム) から十数 Ω のリアクタンスになる。

マイクロストリップ (5-15) の先を via 1 本で GND に落とし、ポート延長で線を外して、
**via そのものの X** を V2 で 3 GHz まで読む。via を 2 本にするとどれだけ減るかも見る。
銅張り基板にするのは、裏の GND の面と via の寸法で決まる量を測る題だから。

## この実験で確かめる式

via を、長さ h (基板の厚さ)・直径 d の線とみなすと、インダクタンスは (h と d は mm、答えは nH)

- **L ≈ 0.2 h (ln(4h / d) + 1)**。h = 1.6 mm、d = 0.8 mm で **0.99 nH** (丸めて 1 nH)
- 2 本を間隔 s で並べると、互いの磁束 (相互インダクタンス M ≈ 0.2 h (ln(2h / s) − 1 + s / h)) のぶん
  半分にはならない: **(L + M) / 2**。s = 1.6 mm で M = 0.22 nH、2 本で **0.60 nH**

周波数 f でのリアクタンスは X = 2π (パイ) f L。どれも見積り (目安) で、穴に通す線の太さ・半田の盛り方で変わる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CH0 に 30 mm のマイクロストリップ、先を via で GND へ (via は等価回路)
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 4,2 7,2 50 l=$\mathrm{TL}_1$
  L1: inductor 8,2 8,4 1n
  G1: ground 2,3
  G2: ground 8,4
wires:
  - J1.1 -- 4,2
  - 7,2 -- 8,2
  - J1.2 -- 2,3
notes:
  - text 5.5,2.7 center: 30 mm
  - text 8.6,3 left: via
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/21-via-discontinuity.svg)

- L1 は via の**等価回路** (1 本で 1 nH、近い 2 本で 0.6 nH の見積り)
- TL1 は図2 の線 (幅 3.06 mm、50 Ω、速度係数 0.548)

## 実体配線図

5×7 cm の両面基板から 40 mm × 20 mm を 2 枚切り出す。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
title: 図2 線の先を via で裏の GND へ落とす
f: 2.4G
board:
  size: 40x20mm
  ground: back
sheets:
  - name: via1本
    copper:
      L1: line 0,10 30,10 3.06mm
      V1: via 29,10
    parts:
      J1: sma left 10 CH0
  - name: via2本
    copper:
      L2: line 0,10 30,10 3.06mm
      V2: via 29,9.2
      V3: via 29,10.8
    parts:
      J2: sma left 10 CH0
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/copper/21-via-discontinuity.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、40 mm × 20 mm を 2 枚。裏は全面の銅 (GND) |
| 線 | 表に幅 3.06 mm、左の縁から 30 mm。表の銅は線のほかは全部剥がす |
| via | 線の先の 1 mm 手前に 0.8 mm の穴。すずめっき線を通し、表の線と裏のベタに半田付けして余りを切る。2 枚めは 1.6 mm 離して 2 本 |
| 端面 SMA | 左の縁。中心ピンを線の端へ、外皮の脚は裏のベタへ |

- check のネットリストで J1 の中心 (1 番) と外皮 (2 番) が同じ GND に入るのは、via で先を短絡したから。
  **短絡が意図**
- 穴に通す線は穴いっぱいの太さにし、表と裏の半田は小さく盛る (盛りすぎると線が太く短くなり、L が減って比べにならない)

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる (3 GHz は H4 の範囲の外)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOL (1 ポート)。CH0 のケーブルの先、基板の SMA を挿す所で |
| ポート延長 | 線の遅れ 0.183 ns (30 mm ÷ (0.548 × c)) を入れる (1-10・3-7) |
| 表示 | S11 のリアクタンス X |

ポート延長の**前** (線の 30 mm が入ったまま)。見えるはずの画面 (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図3 ポート延長の前 — 線の 30 mm が X を回し、via が読めない
dut:
  - line 50 30mm vf 0.548
  - series L 1n
  - short
traces:
  - S11 x
markers:
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/21-via-discontinuity-1.svg)

ポート延長の**後** (via 1 本だけが残る)。掃引とマーカーは図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図4 ポート延長の後 — via 1 本は 2.4 GHz で X = 15.1 Ω (1 nH)
dut:
  - series L 1n
  - short
traces:
  - S11 x
markers:
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/21-via-discontinuity-2.svg)

## 見るべき値

計算値 (via を直列の L とみなした見積りによる)。

| 周波数 | 図3 の X (延長の前) | 図4 の X (via 1 本、1 nH) | via 2 本 (0.6 nH) |
| --- | --- | --- | --- |
| 1 GHz | 162.5 Ω | **6.3 Ω** | 3.8 Ω |
| 2.4 GHz | −4.8 Ω | **15.1 Ω** | 9.0 Ω |
| 3 GHz | 38.9 Ω | **18.8 Ω** | 11.3 Ω |

- 図3 の X は、30 mm の線 (2.4 GHz で 158°、図2 の線の札) が via の小さな X を大きく回したもの。
  **基準面が via から離れていると、via は読めない**。ポート延長で基準面を via の根元まで送る
- 図4 は X が周波数に比例する直線。**傾きから L = X / (2π f)** が出る (2.4 GHz で 15.1 Ω なら 1.0 nH)
- 2.4 GHz の 15 Ω は 50 Ω に比べて小さくない。**バイパスのコンデンサを via 1 本で GND に落とすと、
  コンデンサの ESL (4-8) に via の 1 nH が足され**、自己共振の周波数が下がる
- via を 2 本にしても 0.6 nH で、半分 (0.5 nH) にはならない。近い 2 本は互いの磁束を打ち消せないから。
  **via は離して何本も打つ**ほうが効く (コプレーナ線路の via の列、5-16)
- 実物の X が見積りより大きく出たら、ポート延長の値か線の速度係数を疑う (5-15 で測った値を使う)

## LTspice での確かめ

`sim/21-via-discontinuity.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源、先は短絡。LTspice のコイルに付く既定の直列抵抗は 1 µΩ (マイクロオーム) に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (線 + 1 nH) | 1 GHz | X | 162.5 Ω | 162.54 Ω | 合う |
| 図3 | 2.4 GHz | X | −4.8 Ω | 4.76 Ω (大きさ) | 合う |
| 図3 | 3 GHz | X | 38.9 Ω | 38.89 Ω | 合う |
| 図4 (1 nH) | 1 GHz / 2.4 GHz / 3 GHz | X | 6.3 / 15.1 / 18.8 Ω | 6.28 / 15.08 / 18.85 Ω | 合う |
| via 2 本 (0.6 nH) | 1 GHz / 2.4 GHz / 3 GHz | X | 3.8 / 9.0 / 11.3 Ω | 3.77 / 9.05 / 11.31 Ω | 合う |

.meas の im() は符号を落として返すので、大きさで比べた (図3 の 2.4 GHz の符号は check の読み値から負)。
L と M の見積り (0.99 nH・0.22 nH・0.60 nH) は上の式の算術。

## 出典

自作。via のインダクタンスは丸い線の自己インダクタンスの近似式 (H. W. Johnson と M. Graham, *High-Speed Digital Design*, Prentice Hall, 1993 の via の式と同じ形) による見積り。

参考: [Wikipedia "Via (electronics)"](https://en.wikipedia.org/wiki/Via_(electronics))
