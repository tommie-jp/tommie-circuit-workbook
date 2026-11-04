---
book: circuits
chapter: 8
id: 8-20
title: LED を受光素子に
tier: 200
source: Lessons in Electric Circuits Vol. VI ch.5 (Pulsed-light sensor)
board: BB
era: 古
---

# 8-20 LED を受光素子に

LED (発光ダイオード) は、電流を流すと光る PN 接合である。逆に、**光を当てると小さな電流を出す** (8-19 のフォトダイオードと同じ働き)。
この性質は昔から知られ、Forrest M. Mims III は LED を「特定の色だけに感じる受光素子」として、太陽光の測定器に使った。

LED を受光素子にすると、フォトダイオードと違う点が 2 つある。

1. **色を選ぶ**: LED は、自分が出す色と同じか、それより波長の短い (青に近い) 光にだけ感じる。赤い LED は赤い光と緑・青の光に感じるが、
   緑の LED は赤い光にはほとんど感じない。色のフィルタを付けなくても、色を分けて受けられる
2. **電流が小さい**: 受光の面積が小さく、光電流は 1 µA (マイクロアンペア) 以下のことが多い。そのままでは使いにくいので、トランジスタで増やす

この題では、Lessons in Electric Circuits の「Pulsed-light sensor」の形 (LED をトランジスタのベースとエミッタの間につなぐ) を、
5 V・2SC1815 と Analog Discovery 3 (AD3) に合わせて描き直す。W1 で点滅させた赤い LED の光を、受光の赤い LED で受け、
2SC1815 の電流増幅率 (h<sub>FE</sub>) 倍に増えた電流をコレクタの電圧の変化としてオシロで見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 受光の LED (D1) の光電流を 2SC1815 のベースに入れる
parts:
  W1: square 2,5 2,7 l=$\mathrm{W1}$
  G0: ground 2,7
  M2: voltmeter 3,3 3,5 l=$\mathrm{CH2}$
  G5: ground 3,5
  R2: resistor 4,3 6,3 330
  D2: led 6,3 6,5 red
  G6: ground 6,5
  D1: led 9,6 9,8 red
  G1: ground 9,8
  Q1: npn 11,6
  G2: ground 11,8
  VCC: vcc 11,2 5V
  RC: resistor 11,2 11,4 10k
  M1: voltmeter 13,4 13,6 l=$\mathrm{CH1}$
  G3: ground 13,6
wires:
  - 2,5 -- 2,3 -- 3,3 -- 4,3
  - 9,6 -- Q1.B
  - Q1.E -- 11,8
  - 11,4 -- Q1.C
  - 11,4 -- 13,4
notes:
  - text 2,9.5 blue left: "D2 (光源) の光を D1 (受光) に当てる。D1 は光らせない向きでベースへ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/20-led-light-sensor.svg)

- **D1 (受光)** はアノードを Q1 のベース、カソードを GND (エミッタと同じ) につなぐ。光が当たると、D1 は電池としてアノードが + になる向きに
  光電流 I<sub>ph</sub> を出し、それがそのままベース電流になる。電源から D1 に電流は流さない (光らせない)
- **Q1** はベース電流を h<sub>FE</sub> 倍にしてコレクタに流す。I<sub>ph</sub> が 0.5 µA なら、h<sub>FE</sub> 250 で I<sub>C</sub> ≈ 125 µA、
  RC (10 kΩ) の電圧降下は 1.25 V で、コレクタ (CH1) は 5 V から約 3.75 V に下がる (光電流の 0.5 µA は**仮定**)
- 暗いときはベース電流が 0 で、Q1 は止まり、コレクタは 5 V。8-5 のフォトトランジスタは、この「受光のダイオード + トランジスタ」を 1 つのチップに作り込んだもの
- **欠点**: 出力が h<sub>FE</sub> (2SC1815 の GR は 200〜400) と温度で大きく変わる。光の強さを数で読むなら 8-19 の電流電圧変換、
  光が来たかどうかを知るだけならこの形でよい。応答も遅い (ベースの小さな電流で、D1 と Q1 の容量を充電するため。立ち上がりと立ち下がりは数十 µs)
- **D2 (光源)**: 8-19 と同じく、W1 の 0〜4 V の方形波で R2 (330 Ω) を通して点滅させる (点いているときは約 6.4 mA)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 受光の LED (D1) と 2SC1815 を組む (D2 は D1 に向けて曲げる)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・W1・CH2)
    pins: [V+, GND, 2+, W1, 2-]
  Q1: transistor f15 f16 f17 2SC1815
  D1: led i17(A) i20(K) red
  RC: resistor h16 h23 10k cap=above
  R2: resistor c22 c26 330
  D2: led b26(A) b28(K) red
  SC:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH1)
    pins: [1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t30 -- +b30 red
  - j20 -- -b20 black
  - j15 -- -b15 black
  - j23 -- +b23 red
  - AD.W1 -- a22 yellow
  - b22 -- b20 yellow
  - AD.2+ -- a20 blue
  - AD.2- -- -t24 black
  - a28 -- -t28 black
  - SC.1+ -- j16 orange
  - SC.1- -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/20-led-light-sensor.svg)

- 5 V は AD3 の Supplies の V+ から上の + レールへ。右端の列 30 で下の + レールへ渡し、上下の − レールは左端でつなぐ
- **Q1 (2SC1815)** は印字の面を手前にして、列 15〜17 に E・C・B の順で挿す。E (列 15) は − レールへ
- **D1 (受光)** はアノード (長い足) を B の列 17 (`i17`)、カソードを列 20 (`i20`、列 20 は − レールへ) に挿す。光らせる向きと同じ挿し方だが、電源にはつながない
- **RC** は C の列 16 (`h16`) から列 23 へ、列 23 を赤の線で下の + レールへ。CH1 (1+、橙) は C の列 16 (`j16`)
- **光源**: W1 (黄) を `a22`、R2 (列 22〜26) を通して D2 (アノード `b26`・カソード `b28`、列 28 は − レールへ)。CH2 (2+) は列 22 から黄の線で延ばした `a20`。
  D2 は足を長く残して曲げ、D1 の頭 (レンズ) と向かい合わせて 5 mm ほどに近づける。2 つの LED の頭を短い黒い筒 (ストローや熱収縮チューブ) に入れると、部屋の光が入りにくい
- 電流は D2 の 6.4 mA (W1 から) と、Q1 の 1 mA 以下 (5 V ÷ 10 kΩ = 0.5 mA が最大)。AD3 とブレッドボードの範囲に十分収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V。W1 を方形波・1 kHz・振幅 2 V・オフセット 2 V (0〜4 V)。
Scope は CH1 を Q1 のコレクタ (列 16)、CH2 を W1 (列 20) にして、横 200 µs/div、CH1 は 500 mV/div、CH2 は 2 V/div。トリガは CH2 の立ち上がり 2 V。
CH1 は 5 V の近くで振れるので、CH1 の位置を下げて (−8 目盛ぶん) 5 V の付近を画面に入れる。

見えるはずの画面 (D1 の光電流を 0.5 µA、Q1 の h<sub>FE</sub> を 250 と**仮定**した計算値で、実測ではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 D2 が点く (CH2 が H) とコレクタ (CH1) が約 1.3 V 下がる
time: 200us/div
trigger: ch2 rising 2V at -4div
ch1: {wave: square 1kHz 0.635V offset 4.345V phase 180deg | rc 15us, range: 500mV/div, position: -8div}
ch2: {wave: square 1kHz 2V offset 2V, range: 2V/div, position: -3div}
measure: [vmax, vmin, freq]
cursors: [300us, 800us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/20-led-light-sensor.svg)

- CH2 が H (D2 が点灯) の間、CH1 は 4.98 V から約 3.7 V に下がる。CH1 は CH2 と逆向きの方形波になる
- 変わり目は 8-19 (2 µs ほど) よりずっとなまり、数十 µs かかる。横を 20 µs/div にすると、指数の曲線で落ちるのが見える
- **色を変える**: D1 を緑の LED に替えると、赤い D2 の光ではほとんど振れなくなる (緑の LED は、自分の色より波長の長い赤には感じない)。
  反対に、D2 を緑か青の LED にすると、受光の赤い D1 は振れる
- 部屋の明かりの下では、蛍光灯や LED 照明の 100 Hz (東日本) か 120 Hz (西日本) のちらつきが CH1 に乗ることがある

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1 | LED (赤、受光に使う) | 透明のレンズの 5 mm 品。色付きの拡散レンズの品は感度が下がる |
| D2 | LED (赤、光源) | 高輝度の 5 mm 品 |
| Q1 | NPN トランジスタ | 2SC1815 (GR。h<sub>FE</sub> 200〜400) |
| RC | 抵抗 (1/4 W) | 10 kΩ |
| R2 | 抵抗 (1/4 W) | 330 Ω |
| — | 電源・信号 | AD3 の Supplies の V+ (5 V)、W1 (0〜4 V・1 kHz の方形波) |
| — | 比べる LED | 緑の LED (受光と光源を入れ替えて、色の違いを見る) |

## 見るべき値

光電流と h<sub>FE</sub> は仮定。受光の LED の光電流は、LED の種類と、光源との距離・向きで 1 桁以上変わる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| コレクタ (CH1)、D2 が消えている | 約 5 V | ベース電流が 0 で Q1 が止まる |
| コレクタ (CH1)、D2 が点いている | 約 3.7 V (光電流 0.5 µA) | I<sub>C</sub> = h<sub>FE</sub> × I<sub>ph</sub> ≈ 125 µA が RC を流れる |
| 逆算した光電流 | (5 V − CH1) ÷ 10 kΩ ÷ h<sub>FE</sub> | テスターで測った h<sub>FE</sub> を使う |
| ベース (列 17) の電圧、点灯中 | 約 0.6 V | D1 の起電力が Q1 のベース-エミッタ間で押さえられる |
| 変わり目の時間 (10〜90 %) | 数十 µs | ベースの小さな電流で D1 と Q1 の容量を充電する。8-19 より 1 桁遅い |
| D1 を緑の LED に替えたとき | ほとんど振れない | 緑の LED は赤い光に感じない (色を選ぶ) |

## LTspice での確かめ

`sim/20-led-light-sensor.cir` で図1 の受光の側を解いた。D1 は「光電流 + LED のダイオード + 接合容量 30 pF」、Q1 は 2-21 と同じ 2SC1815 の代用の模型
(h<sub>FE</sub> 250)。光電流は 1 kHz の方形で 0.5 µA と 1.5 µA の 2 通りを**仮定**した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| コレクタ、暗い | 約 5 V | 4.98 V | 合う |
| コレクタ、光電流 0.5 µA | 約 3.75 V | 3.71 V | 合う (I<sub>C</sub> 129 µA) |
| コレクタ、光電流 1.5 µA | 約 1.25 V (5 − 3 × 1.25) | 1.24 V | 合う (I<sub>C</sub> 376 µA) |
| ベース、点灯中 | 約 0.6 V | 0.58〜0.61 V | 合う |
| 立ち下がり・立ち上がり (10〜90 %) | 数十 µs | 18〜26 µs・26〜42 µs | 合う (光電流が小さいほど遅い) |

色を選ぶ性質 (緑の LED が赤い光に感じないこと) は、LED の材料の性質で、SPICE では確かめられない。

## 出典

回路の形は [Lessons in Electric Circuits Vol. VI (Experiments) ch.5 の「Pulsed-light sensor」](https://www.ibiblio.org/kuphaldt/electricCircuits/Exper/EXP_5.html)
(Tony R. Kuphaldt。LED を NPN のベースとエミッタの間に入れ、コレクタにヘッドホンをつなぐ)。この題では電源を 5 V、トランジスタを 2SC1815、
負荷を 10 kΩ に替え、光源を AD3 の W1 で点滅させる LED にして、図と文を描き直した。

参考: [LEDs as light sensors (Wikipedia)](https://en.wikipedia.org/wiki/LEDs_as_light_sensors)、[発光ダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/発光ダイオード)
