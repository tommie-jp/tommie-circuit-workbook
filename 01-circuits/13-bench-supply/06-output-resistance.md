---
book: circuits
chapter: 13
id: 13-6
title: 出力の内部抵抗と負荷変動
tier: 200
source: 自作
---

# 13-6 出力の内部抵抗と負荷変動

電源装置の表示が 5.00 V でも、ブレッドボードの上の回路に 5.00 V が来ているとは限らない。電源は、理想の電圧源に小さな抵抗が直列に入ったものとして考える
(テブナンの等価回路、0-7)。負荷の電流 I が増えると、その抵抗 R で I × R だけ電圧が下がる。これが**負荷変動** (ロードレギュレーション) で、
下がり方 ΔV ÷ ΔI が**出力の内部抵抗**。

安定化電源の中の回路は、出力の端子の電圧を見て保つので、端子から見た内部抵抗は数 mΩ (ミリオーム) と小さい。ところが端子から回路までの
**線・クリップ・ブレッドボードの接触**は帰還の外にある。ここが 0.1 Ω ずつあると、100 mA で + と − の線で 10 mV ずつ、合わせて 20 mV 落ちる。
回路から見ると、こちらの方がずっと大きい「内部抵抗」になる。

この題では、負荷を 2N7000 で 100 Hz で開け閉めし (84 mA ↔ 0 mA)、+ の線と − の線の両端の電圧を AD3 の Scope で別々に読んで、線の抵抗を求める。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 線の抵抗 (等価回路の RWP・RWN) の電圧を CH1 と CH2 で読む
parts:
  U1:
    type: device
    at: 2,3
    label: PSU
    pins: ["+", "-"]
    turn: mirror
  RWP: resistor 5,3 8,3 0.1
  RWN: resistor 8,8 5,8 0.1
  M1: voltmeter 5,1.5 8,1.5 l=$\mathrm{CH1}$
  M2: voltmeter 5,9.5 8,9.5 l=$\mathrm{CH2}$
  RL: resistor 9,3 9,5.5 56
  Q1: nmos 9,6.4 mirror 2N7000
  RG: resistor 11,7 11,8 100k
  W1: square 13,7 13,8 l=$\mathrm{W1}$
wires:
  - U1.+ -- 5,3
  - 5,3 -- 5,1.5
  - 8,1.5 -- 8,3
  - 8,3 -- 9,3
  - 9,5.5 -- Q1.D
  - Q1.S -- 9,8
  - U1.- -| 4,8
  - 4,8 -- 5,8
  - 5,8 -- 5,9.5
  - 8,9.5 -- 8,8
  - 8,8 -- 9,8 -- 11,8 -- 13,8
  - Q1.G -| 11,7
  - 11,7 -- 13,7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/06-output-resistance.svg)

- RWP・RWN は線とクリップとブレッドボードの接触を 1 本の抵抗に置き換えた等価回路で、部品ではない。値の 0.1 Ω (オーム) は仮定の目安
- RL (56 Ω、1 W) が負荷。Q1 (2N7000) が W1 の方形波 (100 Hz・0〜5 V) で RL を開け閉めする。RG (100 kΩ) はゲートを 0 V に落とす抵抗
- CH1 は + の線の両端 (電源装置の + の端子とブレッドボードの + のレール)、CH2 は − の線の両端 (ブレッドボードの − のレールと電源装置の − の端子)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 CH1 は + の線、CH2 は - の線の両端 (端子とブレッドボードの間)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (5.00 V、電流制限 200 mA)
    pins: ["-", "+"]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (W1 と Scope)
    pins: [1+, 2-, 1-, GND, W1, 2+]
  RL: resistor/half d10 d16 56 cap=left
  Q1: transistor e14 e15 e16 2N7000
  RG: resistor c15 c12 100k cap=above
wires:
  - PSU.+ -- +t6 red
  - PSU.- -- -t2 black
  - +t10 -- a10 red
  - a14 -- -t14 black
  - a12 -- -t12 black
  - AD.1+ -- PSU.+ yellow
  - AD.1- -- +t8 orange
  - AD.W1 -- b15 green
  - AD.GND -- -t18 black
  - AD.2+ -- -t20 white
  - AD.2- -- PSU.- blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/06-output-resistance.svg)

- 電源装置の + (赤) を上の赤いレール (6 列)、− (黒) を上の青いレール (2 列) へ。この 2 本の線が RWP・RWN
- CH1 は 1+ を**電源装置の + の端子**に直接クリップで挟み (黄)、1− をブレッドボードの赤いレール (8 列) に挿す (橙)。CH2 は 2+ をブレッドボードの青いレール (20 列)、
  2− を**電源装置の − の端子**に挟む (青)。プローブの線には電流が流れないので、プローブの線の抵抗は読みに入らない (4 端子法の考え方)
- RL (`d10`–`d16`) は赤いレールから 10 列を経て Q1 の D (16 列) へ。Q1 (2N7000、平らな面を手前に左から S・G・D = 14・15・16 列) の S は青いレールへ
- G (15 列) に W1 (緑)、RG (`c15`–`c12`) で青いレールへ。AD3 の GND も青いレールへ
- 負荷の電流は 84 mA で、ブレッドボードの範囲 (1 穴 200 mA) の内側

## 計器の設定

電源は電源装置 (この題の主役。AD3 の Supplies は 84 mA を出せない)。5.00 V・電流制限 200 mA にする。AD3 は Wavegen と Scope だけを使う。

1. W1 を方形波・100 Hz・振幅 2.5 V・オフセット 2.5 V (0〜5 V) にする
2. Scope は CH1・CH2 とも 2 mV/div、時間軸 2 ms/div、トリガは CH1 の立ち上がり 4 mV。数 mV しか無いので、Average (平均) を 16 回ほど掛けると読みやすい
3. CH1・CH2 の Vmax − Vmin を読み、84 mA で割って線の抵抗を求める

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 負荷 (84 mA) が入るたびに、+ の線 (CH1) と - の線 (CH2) で 8.4 mV ずつ落ちる
time: 2ms/div
trigger: ch1 rising 4mV
ch1: {wave: square 100Hz 8.36mVpp offset 4.18mV, range: 2mV/div, position: -0.5div}
ch2: {wave: square 100Hz 8.36mVpp offset 4.18mV, range: 2mV/div, position: -4div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/06-output-resistance.svg)

図3 は理想 (計算) の画面で、線をそれぞれ 0.1 Ω と仮定した。負荷が入っている 5 ms の間だけ、CH1・CH2 が 8.36 mV になる。
実物の線では値が違ってよく、読んだ値 ÷ 84 mA がその線の抵抗。切り替わりの瞬間の小さな跳ねは、線のインダクタンスと電源装置の応答による。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RL | 抵抗 (**1 W**) | 56 Ω (入っている間 0.39 W。図は 1/2 W の大きさで描いた) |
| Q1 | N チャネル MOSFET | 2N7000 (84 mA、損失 25 mW) |
| RG | 抵抗 (1/4 W) | 100 kΩ |
| — | 電源 | 電源装置 (5.00 V、電流制限 200 mA)。この章の題なので電源装置を使う |
| — | 計器 | AD3 の Wavegen (W1 = ゲート) と Scope (CH1 = + の線、CH2 = − の線) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 負荷の電流 (入っているとき) | 84 mA (5 V ÷ (56 Ω + Q1 の約 3.6 Ω + 線)) | 電源装置の電流の表示は平均の 42 mA ほどになる |
| CH1 (+ の線の電圧) | 8.4 mV (線 0.1 Ω の仮定) | 線の抵抗 = 読み ÷ 84 mA |
| CH2 (− の線の電圧) | 8.4 mV (同上) | − の線も同じだけ落ちる。往復で 2 倍 |
| 電源装置の端子の電圧の動き | 約 0.4 mV (内部抵抗 5 mΩ の仮定) | 電源装置そのものの内部抵抗は小さい。テスターでは見えない |
| ブレッドボードの上の電圧の動き | 約 17 mV (5.000 V → 4.983 V) | 回路から見える負荷変動のほとんどは線 |

- 線を太く短くするか、線を 2 本並べると CH1・CH2 は小さくなる。クリップの挟み方を変えると数 mV 動くこともある (接触の抵抗)
- 電源装置に**リモートセンス** (センス端子) があれば、センスの線を負荷の所につなぐと、電源装置が負荷の所の電圧を見て保つので、線の電圧降下ぶんを上げて補う
- 5-14 の 2.2 Ω はこの線の抵抗を大げさにしたもの。そちらではコンデンサで揺れを均す話をした

## LTspice での確かめ

`sim/06-output-resistance.cir` で図1 を 30 ms 動かした。電源装置は 5.00 V の理想の電源 + 内部抵抗 5 mΩ (仮定)、線は 0.1 Ω ずつ (仮定)、
2N7000 は 02-transistors の題と同じ仮定の模型。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 負荷の電流 (入っているとき・切れているとき) | 84 mA・0 mA | 83.6 mA・0.003 mA | 合う |
| + の線・− の線の電圧 | 8.4 mV・8.4 mV | 8.36 mV・8.36 mV | 合う |
| 端子の電圧の動き | 約 0.4 mV | 5.000 → 4.9996 V (0.42 mV) | 合う |
| ブレッドボードの上の電圧 (切れている・入っている) | 5.000 V・4.983 V | 5.000 V・4.983 V | 合う |
| Q1 のドレイン-ソースの電圧 | 約 0.3 V | 0.30 V | 合う (模型の値) |

模型の線と内部抵抗は仮定の値なので、ここで確かめたのは「電圧降下 = 電流 × 抵抗」の算術。線の実際の抵抗は測って求める (この題の目的)。

## 出典

自作。

参考: [安定化電源 (Wikipedia)](https://ja.wikipedia.org/wiki/安定化電源)、[テブナンの定理 (Wikipedia)](https://ja.wikipedia.org/wiki/テブナンの定理)、[Four-terminal sensing (Wikipedia)](https://en.wikipedia.org/wiki/Four-terminal_sensing)
