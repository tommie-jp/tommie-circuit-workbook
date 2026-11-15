---
book: nanovna
chapter: 4
id: 4-23
title: 巻線抵抗のインダクタンス
tier: 200
source: 自作
board: PF
device: H4
---

# 4-23 巻線抵抗のインダクタンス

電力用の低い抵抗 (セメント抵抗・ホーロー抵抗) の多くは、中身が**巻線**である。
磁器の芯に抵抗線を何十回も巻いてあるので、抵抗であると同時に**コイル**でもある。
4-1 の金属皮膜抵抗の ESL (イー・エス・エル、直列のインダクタンス) は 15 nH だったが、巻線抵抗では
µ (マイクロ) H の桁になる。同じ 10 Ω (オーム) の巻線抵抗と金属皮膜抵抗を 4-1 と同じ直列治具に挿し、
**X (リアクタンス) が R に追いつく周波数**と、巻線の容量で起きる**自己共振**を読む。

この題で使う模型 (等価回路) は次のとおり。値は代表的な見積もりで、品と巻き方で大きく変わる (目安)。

| 抵抗 | 等価回路 | X = R になる周波数 f<sub>c</sub> = R / (2πL) | 自己共振 1 / (2π√(LC<sub>p</sub>)) |
| --- | --- | --- | --- |
| 巻線 (セメント 5 W) 10 Ω | R 10 Ω + L 1 µH、全体に C<sub>p</sub> 5 pF が並列 | 1.59 MHz | 71.2 MHz |
| 金属皮膜 (1/4 W) 10 Ω | R 10 Ω + L 15 nH (4-1 と同じ ESL) | 106 MHz | (掃引の外) |

f<sub>c</sub> より上では、巻線抵抗は「抵抗の付いたコイル」として振る舞う。
電流を測る抵抗・ダミーロード・高い周波数のアンプのエミッタ抵抗に巻線抵抗を使ってはいけない理由がこれである。

## 回路図

4-1 の直列治具に、測る抵抗 R1 を挿す。CH1 側の SMA には校正キットの Short を挿し、
CH0 から見た R1 だけのインピーダンスを S11 から読む (4-1 と同じ 1 端子の測り方)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 直列治具に巻線抵抗を挿し、先を短絡する
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 4,2 6,2 10
  J2: sma 8,2 Short
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/23-wirewound-resistor.svg)

## 実体配線図

3-1 の直列治具と同じ基板。巻線抵抗は胴が長い (5 W のセメント抵抗で 22 mm ほど) ので、
SMA の間の 3 cm に寝かせ、ピンを切って穴まで短く曲げる。図の胴は 1/2 W の大きさで描いてある
(5 W の胴の形はフェンスに無い。f10–s10 の間に実物の胴が収まる)。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 直列治具に 5 W のセメント抵抗 (巻線) を寝かせる
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  R1: resistor/half f10 s10 10
wires:
  - a10 -- f10
  - s10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/23-wirewound-resistor.svg)

R1 を巻線 10 Ω と金属皮膜 10 Ω で挿し替えて、2 回測る。金属皮膜は 4 穴ぶん (f10–i10) で足りるが、
同じ穴に挿すとピンの長さが同じになり、比べやすい。

## 部品

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| R1 (巻線) | 10 Ω 5 W のセメント抵抗 | 中身が巻線の品 (データシートの構造の図で確かめる。値の大きい品は金属酸化物皮膜のことがある)。L 1 µH・C<sub>p</sub> 5 pF は目安 |
| R1 (比べる物) | 10 Ω 1/4 W の金属皮膜抵抗 | 4-1 と同じ形の抵抗 |
| J1・J2 | 端面の SMA (メス) | 3-1 と同じ |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜20 MHz (f<sub>c</sub> を読む)、1 MHz〜150 MHz (自己共振を見る) |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru。範囲を変えたら校正し直す (1-4) |
| 表示 | S11 の R と X (Ω)。自己共振は \|Z\| |

**巻線 10 Ω** — 見えるはずの画面。1.59 MHz で X が R に追いつき、その上では X が R の何倍にもなる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50k-20M 301
title: 図3 巻線 10 Ω — 1.59 MHz で X = R、10 MHz で X は R の 6 倍
dut:
  - series R 10 esl 1u cp 5p
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 1.59M
  - 10M
expect:
  - match: しか動きません
    why: R がほぼ 10 Ω のまま動かないことを見せる図
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/23-wirewound-resistor-1.svg)

**金属皮膜 10 Ω** — 同じ掃引。X は 20 MHz でも 2 Ω に届かない。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50k-20M 301
title: 図4 金属皮膜 10 Ω — X は 10 MHz で 0.9 Ω (縦は図3 の 1/10)
dut:
  - series R 10 esl 15n
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 1.59M
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/23-wirewound-resistor-2.svg)

**巻線 10 Ω の自己共振** — 巻線どうしの容量 C<sub>p</sub> と L が並列に共振し、\|Z\| が山になる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-150M 301
title: 図5 巻線 10 Ω の自己共振 — 71.2 MHz で |Z| が山
dut:
  - series R 10 esl 1u cp 5p
  - short
traces:
  - S11 z
markers:
  - 10M
  - 71.2M
  - 140M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/23-wirewound-resistor-3.svg)

## 見るべき値

計算値 (上の模型から)。L は f<sub>c</sub> の周波数で L = X / (2πf) と読む。

| 周波数 | 巻線 10 Ω の R / X | 金属皮膜 10 Ω の R / X | 読み方 |
| --- | --- | --- | --- |
| 1.59 MHz | 10.0 Ω / 10.0 Ω | 10.0 Ω / 0.15 Ω | 巻線は X = R (位相 45°)。L = 10.0 / (2π × 1.59 MHz) = 1.0 µH |
| 10 MHz | 10.4 Ω / 64.1 Ω | 10.0 Ω / 0.94 Ω | 巻線の \|Z\| は 64.9 Ω で、公称の 6.5 倍 |

| 周波数 | 巻線 10 Ω の \|Z\| | 読み方 |
| --- | --- | --- |
| 10 MHz | 64.9 Ω | まだコイルの側 (X が +) |
| 71.2 MHz | 約 20 kΩ | 自己共振。\|Z\| ≈ (2πf L)² / R = 20 kΩ |
| 140 MHz | 307 Ω | C<sub>p</sub> の側 (X が −)。巻線抵抗はここではコンデンサ |

分かること:

- **巻線抵抗は 1.6 MHz より上では抵抗として使えない。** 10 MHz で \|Z\| は 65 Ω になり、
  電流を測る抵抗なら読みが 6.5 倍に化ける。金属皮膜は 10 MHz でも 0.4% しかずれない
- 低い値ほど f<sub>c</sub> = R / (2πL) が下がる。同じ巻線でも 1 Ω なら 160 kHz、0.1 Ω なら 16 kHz
  から X が勝つ。スイッチング電源の電流検出に巻線抵抗を使うと、波形に棘が出るのはこのため
- 「無誘導巻」(往復に巻いて磁束を打ち消す巻き方) の巻線抵抗は L が 1 桁以上小さい。
  品の名前に「無誘導」「non-inductive」とある物を同じ治具で測ると差が見える
- 自己共振の山 (約 20 kΩ) は S11 が 1 に近すぎて、NanoVNA の反射の測り方では正確に読めない。
  読むのは山の**周波数**で、高さは目安にとどめる (3-6 の「どこまで信じるか」)

## LTspice での確かめ

`sim/23-wirewound-resistor.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源で CH0 を駆動し、先を短絡。
CH0 から見た Z = 50·V(n0) / (Vs − V(n0)))。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1.59 MHz | R / X | 10.0 Ω / 10.0 Ω | 10.01 Ω / 9.99 Ω | 合う |
| 図3 | 10 MHz | R / X | 10.4 Ω / 64.1 Ω | 10.41 Ω / 64.06 Ω | 合う |
| 図4 | 1.59 MHz | R / X | 10.0 Ω / 0.1 Ω | 10.00 Ω / 0.15 Ω | 合う |
| 図4 | 10 MHz | R / X | 10.0 Ω / 0.9 Ω | 10.00 Ω / 0.94 Ω | 合う |
| 図5 | 10 MHz | \|Z\| | 64.9 Ω | 64.9 Ω (10.41 + j64.06) | 合う |
| 図5 | 71.2 MHz | \|Z\| | 20.00 kΩ | 20.00 kΩ (R 19.97 kΩ・\|X\| 1.04 kΩ) | 合う |
| 図5 | 140 MHz | \|Z\| | 306.6 Ω | 306.6 Ω (R 1.21 Ω・\|X\| 306.6 Ω) | 合う |

7 点すべて図の読み値と合う。図5 の 140 MHz の X の符号 (− = 容量性) は模型の式から読む (LTspice の .meas の出力では符号を確かめていない)。

## 出典

自作。

参考: [Wikipedia「抵抗器」](https://ja.wikipedia.org/wiki/抵抗器)、[Wikipedia "Resistor" (Wire-wound)](https://en.wikipedia.org/wiki/Resistor#Wire_wound)
