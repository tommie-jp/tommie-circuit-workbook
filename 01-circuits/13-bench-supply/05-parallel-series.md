---
book: circuits
chapter: 13
id: 13-5
title: 並列と直列で電流・電圧を足す
tier: 200
source: 自作
---

# 13-5 並列と直列で電流・電圧を足す

1 つの出力では足りないとき、電源装置の 2 つの出力をつないで足す。

- **直列** (A の − と B の + をつなぐ) — **電圧**が足し算になる。13-4 と同じつなぎ方で、つなぎ目を GND にせず、A の + と B の − の間を使う。
  A 6.0 V + B 6.0 V = 12.0 V。電流は 2 つに同じだけ流れ、上限は電流制限の小さいほう
- **並列** (+ どうし、− どうしをつなぐ) — **電流**が足し算になる。ただし 2 つの出力の電圧はぴったり同じにはならない。
  電圧の高いほうが先に電流を出し、自分の電流制限に当たって CC (定電流) に入ると、残りを低いほうが CV (定電圧) で出す

並列は落とし穴がある。電源装置は電流を吸い込めないので、負荷が軽いと高いほうの出力だけが働き、低いほうは何も出さない (逆に流れ込みはしない)。
2 つの電流制限の和までしか出せず、片方は CC に入ったまま働く。この題では並列の分かれ方を、2 本の 1 Ω (オーム) のシャントの電圧で見る。
直列は 13-4 で組んだので、ここでは表で確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 出力 A と B を並列にして 1 つの負荷に電流を足す
parts:
  UA:
    type: device
    at: 2,3
    label: A
    pins: ["+", "-"]
    turn: mirror
  UB:
    type: device
    at: 2,7
    label: B
    pins: ["+", "-"]
    turn: mirror
  RSA: resistor 5,3 8,3 1
  RSB: resistor 5,7 8,7 1
  M1: voltmeter 5,1.8 8,1.8 l=$\mathrm{CH1}$
  M2: voltmeter 5,5.8 8,5.8 l=$\mathrm{CH2}$
  SW1: switch 10,5 12,5
  RL: resistor 12,5 12,9 100
  G1: ground 12,9
  G2: ground 4,8.5
  G3: ground 4,4.5
wires:
  - UA.+ -- 5,3
  - UB.+ -- 5,7
  - 5,3 -- 5,1.8
  - 8,1.8 -- 8,3
  - 5,7 -- 5,5.8
  - 8,5.8 -- 8,7
  - 8,3 -- 9,3 -- 9,5 -- 9,7 -- 8,7
  - 9,5 -- 10,5
  - UA.- -| 4,4.5
  - UB.- -| 4,8.5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/05-parallel-series.svg)

- A は 5.05 V、B は 5.00 V に合わせ (わざと 50 mV ずらす。実物でも 2 つの表示が同じでも数十 mV はずれている)、どちらも電流制限 30 mA
- RSA・RSB (1 Ω (オーム)) はそれぞれの出力の電流を見るシャント。CH1 が A の電流 (1 mA で 1 mV)、CH2 が B の電流
- RL (100 Ω) は 50 mA を取る負荷。1 つの出力の電流制限 30 mA では足りない。SW1 で入れる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 A と B の電流は RSA・RSB を通って 8・9 列で合流
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (A 5.05 V・B 5.00 V、どちらも電流制限 30 mA)
    pins: [A-, A+, B-, B+]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (Scope)
    pins: [1+, 1-, 2-, 2+, GND]
  RSA: resistor g3 g8 1
  RSB: resistor g13 g9 1
  SW1: switch i9 i12
  RL: resistor/half j12 -b11 100
wires:
  - PSU.A- -- -t2 black
  - PSU.A+ -- a3 red
  - e3 -- f3 red
  - PSU.B- -- -t11 black
  - PSU.B+ -- a13 red
  - e13 -- f13 red
  - h8 -- h9 blue
  - AD.1+ -- j3 yellow
  - AD.1- -- j8 blue
  - AD.2- -- j9 blue
  - AD.2+ -- j13 green
  - AD.GND -- -b20 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/05-parallel-series.svg)

- A+ (赤) は 3 列、B+ (赤) は 13 列へ下ろし、短い赤の線で下のブロックへ渡す。A− と B− (黒) は上の青いレール (GND)
- RSA (`g3`–`g8`) と RSB (`g13`–`g9`) を、8・9 列で合流させる (青の短い線 `h8`–`h9`)。ここが 2 つの出力を並べた点
- SW1 (`i9`–`i12`) の先に RL (`j12` から下の青いレールへ)。上下の青いレールは 30 列でつなぐ
- CH1 は差動で 1+ を `j3`、1− を `j8`、CH2 は 2+ を `i13`、2− を `j9` に当てる。AD3 の GND は下の青いレール
- RL は 50 mA × 5 V = 0.25 W を出すので **1 W の抵抗**を使う (図は 1/2 W の大きさで描いた)。ブレッドボードを流れる電流は 50 mA で範囲 (1 穴 200 mA) の内側

## 計器の設定

電源は電源装置の 2 つの出力 (この題の主役)。AD3 は Scope だけを使う。

1. SW1 を切ったまま、A を 5.05 V・30 mA、B を 5.00 V・30 mA にして出力を入れる。電源装置の電流の表示は A・B とも 0 mA
2. Scope は CH1・CH2 とも 10 mV/div、0 V を下から 1 目盛 (−4 div)、時間軸 1 ms/div。トリガは単発で CH1 の立ち上がり 15 mV
3. SW1 を入れる (t = 0)。電源装置の表示で A が CC に、B が CV のままであることも見る

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 SW1 を入れると A は電流制限の 30 mA (CH1)、残りの 20 mA を B (CH2) が出す
time: 1ms/div
trigger: ch1 rising 15mV at -4div
ch1: {wave: "= 30mV * step(t)", range: 10mV/div, position: -4div}
ch2: {wave: "= 19.8mV * step(t)", range: 10mV/div, position: -4div}
cursors: [3ms]
measure: [vmax]
notes:
  - text ch1 1ms 30mV: A (CC)
  - text ch2 1ms 19.8mV: B (CV)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/05-parallel-series.svg)

図3 は理想 (計算) の画面。SW1 で CH1 (A) が 30.0 mV (= 30 mA) に、CH2 (B) が 19.8 mV (= 19.8 mA) に上がる。足すと 49.8 mA で、RL が取る電流。
実物では切り替わりの瞬間に電源装置の応答の山が出ることがあるが、落ち着いた値で読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RSA, RSB | 抵抗 (1/4 W) | 1 Ω (30 mA で 0.9 mW) |
| RL | 抵抗 (**1 W**) | 100 Ω (0.25 W。1/4 W や 1/2 W では定格の半分を超える) |
| SW1 | スライドスイッチ | — |
| — | 電源 | 電源装置の 2 出力 (A 5.05 V・B 5.00 V、どちらも電流制限 30 mA)。この章の題なので電源装置を使う |
| — | 計器 | AD3 の Scope (CH1 = RSA の両端、CH2 = RSB の両端) |

## 見るべき値

**並列** (表の値は計算値で、LTspice と同じ)

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SW1 を入れる前の A・B の電流 | 0 mA・0 mA | 負荷が無ければどちらも出さない。A から B へ流れ込みもしない |
| A の電流 (CH1) | 30.0 mA、電源装置は CC | 電圧の高い A が先に出し、自分の電流制限に当たる |
| B の電流 (CH2) | 19.8 mA、電源装置は CV | 残りを B が 5.00 V の CV で出す |
| RL の電圧 | 4.98 V | B の 5.00 V から RSB の 19.8 mV を引いた値 |
| A の出力の電圧 | 5.01 V (5.05 V の設定より下) | A は CC なので、設定より低い電圧で釣り合う |

RL を 220 Ω (22.8 mA) にすると、A だけで足りるので A が CV の 5.05 V で全部を出し、B は 0 mA になる (計算値)。並列で電流を半分ずつにしたいなら、
2 つの出力に同じ値のシャント (バラスト抵抗) を大きめ (たとえば 2 Ω) に入れ、電圧の差をその電圧降下で吸わせる。

**直列** (13-4 の配線で、A の + と B の − の間に 2.4 kΩ をつないだとき。計算値)

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A+ と B− の間 | 12.0 V (A 6.0 V + B 6.0 V) | 電圧が足し算になる |
| 電流 (A・B の表示) | どちらも 5.0 mA | 直列なので同じ電流 |

## LTspice での確かめ

`sim/05-parallel-series.cir` で図1 と直列の回路を解いた。電源装置の出力は CV/CC の模型 (電流制限の電流源と、設定電圧へ逃がす理想ダイオード) で、
電流を吸い込めないよう出力に逆流止めの理想ダイオードを入れた。出力の抵抗と応答の遅れは入れていない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| SW1 の前の A・B の電流 | 0 mA | 0.00005 mA・0 mA | 合う |
| A・B の電流 (SW1 の後) | 30.0 mA・19.8 mA | 30.0 mA・19.80 mA | 合う |
| RL の電圧 | 4.98 V | 4.980 V | 合う |
| A・B の出力の電圧 | 5.01 V・5.00 V | 5.010 V・5.000 V | 合う |
| 直列の電圧・電流 | 12.0 V・5.0 mA | 12.0 V・5.00 mA | 合う |

模型の出力は理想なので、実物の電源装置どうしの応答の差 (切り替わりで A と B が引っ張り合う揺れ) は確かめていない。

## 出典

自作。

参考: [安定化電源 (Wikipedia)](https://ja.wikipedia.org/wiki/安定化電源)、[定電流源 (Wikipedia)](https://ja.wikipedia.org/wiki/定電流源)
