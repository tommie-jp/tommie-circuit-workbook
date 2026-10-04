---
book: circuits
chapter: 4
id: 4-7
title: 差動増幅
tier: 100
source: 自作
---

# 4-7 差動増幅

反転増幅 (4-3) と非反転増幅 (4-2) を 1 個の OP アンプに重ねると、
**2 つの入力の差だけを増幅する**差動増幅になる。センサーの信号からノイズや
基準電圧のずれを引き算する、計測の基本形。この題では 2 つの直流電圧を入れ、
出力が差の 10 倍になること、2 つを同じだけ動かしても出力が変わらないことをテスターで確かめる。

## 回路図

```circuit
title: 図1 差動増幅
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground c2
  V1: vsource b3 d3 0.5
  G2: ground d3
  V2: vsource d4 f4 0.8
  G3: ground f4
  R1: resistor b3 b6 10k
  Rf: resistor a6 a9 100k
  R3: resistor d4 d6 10k
  R4: resistor d6 f6 100k
  G4: ground f6
  U1: opamp c8 +down
  OUT: port c10
points:
  vp: a1
  vm: e1
  mid: c1
wires:
  - mid -- c2
  - b6 |- U1.-
  - b6 -- a6
  - d6 -- d7 |- U1.+
  - a9 -- c9
  - U1.out -- c9 -- c10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/07-differential-amp.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- V1 (0.5 V) は R1 (10 kΩ) を通って − 入力へ、V2 (0.8 V) は R3 (10 kΩ) を通って + 入力へ入る。
  **R1=R3、Rf=R4 とペアの抵抗を揃える**のが差動増幅の条件
- 非反転側 (+ 入力) は R3・R4 (100 kΩ) の分圧で V2 を弱めてから入れ、
  反転側 (− 入力) は Rf (100 kΩ) の帰還で同じだけ強める。
  **両方が同じ比率 (Rf/R1 = R4/R3 = 10) なら、Vout = 10 × (V2 − V1) ときれいに差だけが残る**
- 抵抗が 1 組でもずれると、V1・V2 に共通の成分 (同相成分。2 つの入力が同じだけ動く分) が漏れて出力に残る。
  同相成分をどれだけ消せるかの比を**同相除去比**と呼び、実測では抵抗の誤差 (E24 系列の 1% 品でも) がその限界になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下の青レールは −5V (V−)。下の赤レールは使わない
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1・W2)
    pins: [V+, GND, V-, W1, W2]
  SC:
    type: device
    at: bottom
    label: AD3 Scope (DC 電圧計)
    pins: [1-, 1+]
  U1: dip8 @ e10 LM358
  R1: resistor j11 j7 10k
  Rf: resistor j15 j18 100k
  R3: resistor j22 j26 10k
  R4: resistor h22 h25 100k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- g7 yellow
  - AD3.W2 -- g26 yellow
  - SC.1+ -- j10 green
  - SC.1- -- j25 black
  - h11 -- h15 orange
  - i10 -- i18 green
  - g12 -- g22 orange
  - +t10 -- a10 red
  - j13 -- -b13 blue
  - f25 -- -t25 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/07-differential-amp.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、Wavegen の W1・W2 が V1・V2 に当たる。
  W1 と W2 は振幅 0 V のまま直流のオフセットだけを出す (W1 = 0.5 V、W2 = 0.8 V)。電源のレールの分け方は 4-2 と同じ
  (下の青レールは −5V で、GND ではない)。電流は OP アンプと抵抗で数 mA、各レール約 50 mA の範囲に収まる
- IC の足の隣には部品を挿せないので、3 つの足を線で右へ広げる。IN− (PIN 2、11 列) は `h11 → h15`、
  出力 (PIN 1、10 列) は `i10 → i18`、IN+ (PIN 3、12 列) は `g12 → g22`
- R1 (10 kΩ) は W1 の 7 列 (`g7`) から IN− の 11 列へ。Rf (100 kΩ) は 15 列 (IN−) と 18 列 (出力) の間
- R3 (10 kΩ) は W2 の 26 列 (`g26`) から IN+ の 22 列へ。R4 (100 kΩ) は 22 列から 25 列へ渡し、黒の線 `f25 → -t25` で GND へ落とす
- Scope の 1+ (緑) は出力の 10 列 (`j10`)、1− (黒) は GND の 25 列 (`j25`)。PIN 8 (10 列) は `+t10 → a10` で +5V へ、PIN 4 (13 列) は `j13 → -b13` で −5V へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使い、1+ / 1− を直流の電圧計として出力に当てる (テスターの DCV でもよい)。
この題は時間で変わらない直流の電圧だけを見るので、オシロの波形の図は付けない。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | DC (Offset)、0.5 V |
| Wavegen W2 | DC (Offset)、0.8 V |
| Scope CH1 (出力、10 列) | DC、1 V/div。Measurements の平均値 (DC) を読む |

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方) | LM358 |
| R1, R3 | 抵抗 (入力、2 本を揃える) | 各 10 kΩ |
| Rf, R4 | 抵抗 (帰還・+入力の分圧、2 本を揃える) | 各 100 kΩ |
| — | 信号源 | V1 = 0.5 V (直流)、V2 = 0.8 V (直流)。AD3 の W1・W2 の DC オフセット |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の Scope 1+ / 1− (出力の直流電圧を読む) |

## 見るべき値

AD3 の Scope (または テスターの直流電圧レンジ) で、GND を基準に V1・V2・出力 (OUT) を測る。V1・V2 は W1・W2 の設定値そのもの。表の値は計算値。Vout = (Rf/R1) × (V2 − V1) (R1=R3、Rf=R4 のとき)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力電圧 (V1=0.5V, V2=0.8V) | 3.0 V | 10 × (0.8 − 0.5) |
| V1・V2 を両方 1 V ずつ上げたとき (V1=1.5V, V2=1.8V) | 3.0 V (変わらない) | 差 (0.3V) が同じなら、2 つの絶対値が動いても出力は変わらない (同相除去) |
| V1=V2=2V のとき | 約 0 V (計算上) | 差がゼロなら出力もゼロ。実際は抵抗の誤差ぶんだけ残る |
| 利得 | 10 倍 (Rf/R1) | 4-3 の反転増幅と同じ式が使える |

差動増幅は、2 つの入力の差だけでなく、電圧そのもの (**絶対値**) にも上限がある。LM358 の入力が
正しく働くのは、−5 V から、+5 V より約 1.5 V 低い 3.5 V まで。+ 入力には V2 の 100/110 ≈ 0.91 倍が
かかるので、V2 がおよそ 3.8 V を超えると入力の範囲を外れる。出力も同じく 3.5 V ほどで頭打ちになる。もっと高精度に差を取りたいときは
4-13 (中級) の計装アンプ (OP アンプ 3 つ) を使う。

## 出典

自作。
