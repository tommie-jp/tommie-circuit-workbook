---
book: circuits
chapter: 4
id: 4-20
title: 帰還の安定性 — 容量負荷と位相補償
tier: 200
source: 自作
---

# 4-20 帰還の安定性 — 容量負荷と位相補償

4-1 のボルテージフォロアは、どんな負荷でも入力と同じ電圧を出す万能の回路に見える。ところが出力に**コンデンサ** (長いケーブル、
ほかの IC の入力、ノイズ取りのコンデンサ) をつなぐと、方形波の角で出力が跳ねて揺れ、ひどいときは発振する。原因は帰還の**遅れ**にある。

OP アンプは、出力を − 入力に戻して入力との差を打ち消す。打ち消しの信号が戻るのが遅れると、直そうとした向きが行き過ぎ、
さらに反対へ直す、を繰り返す (4-8 のシュミットの正帰還とは違い、負帰還でも遅れが大きいと揺れる)。
OP アンプの出力には内部の抵抗 (開ループの出力抵抗、R<sub>O</sub>。LM358B で約 300 Ω @ 1 MHz、データシートの代表値) があり、
これと負荷の容量 C<sub>L</sub> が RC のローパスを作って、帰還の信号をさらに遅らせる。
**遅れの余裕 (位相余裕)** が減るほど行き過ぎが大きくなる。TI の LM358B のデータシートの図では、利得 1 倍で負荷が 0 pF のとき位相余裕 約 58°、
行き過ぎ 約 8 %、330 pF で位相余裕 約 33°、行き過ぎ 約 40 %。

直し方の定番は、出力と容量の間に**抵抗 R<sub>iso</sub> を 1 本入れて切り離す**こと (位相補償の一つ)。帰還は R<sub>iso</sub> の手前 (OP アンプの出力) から取るので、
容量は帰還の輪の外に出て、遅れを作らない。この題では LM358 の 2 回路で同じフォロアを 2 つ組み、片方は 470 pF を直に、
もう片方は 1 kΩ を挟んで 470 pF を駆動して、方形波の角を並べて比べる。中級の章の最後の題で、ここまでの回路が「なぜ揺れずに動くのか」を確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 容量負荷のフォロア 2 つ (U1 は CL を直に、U2 は Riso を挟む)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 17,2.5
  W1: square 2,5 2,7 0.1 l=$\mathrm{W1}$
  GW: ground 2,7
  U1: opamp 7,3.38 +up
  CL1: capacitor 11,3.38 11,5.4 470p
  GC1: ground 11,5.4
  U2: opamp 7,8.38 +up
  Riso: resistor 9,8.38 12,8.38 1k
  CL2: capacitor 12,8.38 12,10.4 470p
  GC2: ground 12,10.4
  A: port 13,3.38 out
  C: port 14,8.38 out
points:
  vp: 16,1
  mid: 16,2.5
  vm: 16,4
wires:
  - mid -- 17,2.5
  - 2,5 -- 4,5
  - 4,5 -- 4,3
  - 4,3 -| U1.+
  - 4,5 -- 4,8
  - 4,8 -| U2.+
  - U1.out -- 9,3.38 -- 11,3.38 -- 13,3.38
  - 9,3.38 -- 9,4.6 -- 6,4.6
  - 6,4.6 |- U1.-
  - U2.out -- 9,8.38
  - 9,8.38 -- 9,9.6 -- 6,9.6
  - 6,9.6 |- U2.-
  - 12,8.38 -- 14,8.38
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/20-capacitive-load.svg)

- 右上の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **U1** は 4-1 のフォロアの出力に C<sub>L1</sub> (470 pF) を直につないだもの。R<sub>O</sub> と C<sub>L1</sub> のローパスが帰還の輪の中に入る
- **U2** は出力と C<sub>L2</sub> (470 pF) の間に R<sub>iso</sub> (1 kΩ) を入れ、帰還は R<sub>iso</sub> の手前から取る。
  OP アンプから見ると負荷は「1 kΩ + 470 pF」で、高い周波数では 1 kΩ の抵抗に見えるので、遅れがほとんど増えない。
  C (C<sub>L2</sub> の上) は R<sub>iso</sub> と C<sub>L2</sub> の 1 次のローパス (τ = 0.47 µs) を通った波になり、跳ねずに上がる
- R<sub>iso</sub> の代わりに払うもの: 負荷に電流が流れると R<sub>iso</sub> で電圧が落ちる (直流で 1 mA 流すと 1 V)。容量のほかに重い負荷があるときは、
  帰還を C から取り、OP アンプの出力から − 入力へ小さなコンデンサを足す形 (帰還の中の補償) にする
- W1 は ±0.1 V (0.2 Vpp) の小さな方形波。大きくするとスルーレート (LM358 で約 0.3 V/µs) で角が丸まり、跳ねの大きさが読めなくなる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (下が CL 直、上が Riso を挟む)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies +5V・W1・Scope 2)
    pins: [V+, GND, W1, 2+, 2-]
  SC:
    type: device
    at: bottom
    label: AD3 (Supplies −5V・Scope 1)
    pins: [1+, V-, 1-]
  U1: dip8 @ e14 LM358
  CL1: capacitor j14 -b14 470p
  Riso: resistor b15 b20 1k
  CL2: capacitor a20 -t20 470p
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.W1 -- a17 yellow
  - AD3.2+ -- a21 green
  - AD3.2- -- -t28 black
  - SC.1+ -- i14 orange
  - SC.V- -- j17 blue
  - SC.1- -- -b28 black
  - -t1 -- -b1 black
  - a14 -- +t14 red
  - g14 -- g15 white
  - c15 -- c16 white
  - d17 -- d22 yellow
  - e22 -- f22 yellow
  - g22 -- g16 yellow
  - c20 -- c21 green
notes:
  - text below: 赤レール = +5V、青レール = GND (上下とも)。−5V は V− から PIN 4 へ直に
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/20-capacitive-load.svg)

- 上下の青レールはどちらも GND (1 列の黒で渡す)。**−5 V はレールに置かず、AD3 の V− から PIN 4 (17 列) へ直に入れる** (4-16 と同じ)。
  C<sub>L1</sub> と C<sub>L2</sub> を、どちらも最短で GND に落とすため。電流は数 mA
- LM358 は 14 列〜17 列。**下ブロック側の回路 (PIN 1〜3) が U1 (C<sub>L</sub> を直に)、上ブロック側 (PIN 5〜7) が U2 (R<sub>iso</sub> を挟む)**。PIN 8 (14 列) は `a14 → +t14` で +5 V
- **W1 (黄) は 17 列** (U2 の + 入力、PIN 5)。黄 `d17 → d22`・`e22 → f22`・`g22 → g16` で下ブロックの 16 列 (U1 の + 入力、PIN 3) へも配る
- **U1 (下)**: 出力 (PIN 1、14 列) を白 `g14 → g15` で − 入力 (PIN 2) に戻す。C<sub>L1</sub> は 14 列から下の青レールへ、足を短く切って挿す。Scope の 1+ (橙) は 14 列 (`i14`)
- **U2 (上)**: 出力 (PIN 7、15 列) を白 `c15 → c16` で − 入力 (PIN 6) に戻し、R<sub>iso</sub> (b 段) で 20 列へ。C<sub>L2</sub> は 20 列から上の青レールへ。
  20 列は緑 `c20 → c21` で 21 列へ出し、Scope の 2+ を挿す
- Scope のプローブの線も数十 pF の容量を持つ。1+ を 14 列につなぐと C<sub>L1</sub> に足されるので、線は短くする

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 µs ほどの揺れの形を読む題で、揺れの周波数 (約 0.6 MHz) は 10 MHz よりずっと低いから。
W1 は 10 kHz・±0.1 V の方形波。CH1 で U1 の出力、CH2 で C<sub>L2</sub> の上 (C) を見る。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Square、10 kHz、振幅 0.1 V、オフセット 0 V |
| Scope CH1 (U1 の出力、14 列) | DC、50 mV/div |
| Scope CH2 (C、21 列) | DC、50 mV/div |
| Time | 1 µs/div。トリガの点を左から 1 目盛に置く |
| Trigger | CH2、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CL を直に (CH1) は 43 % 跳ねて揺れ、Riso を挟む (CH2) は跳ねない
time: 1us/div
trigger: ch2 rising 0V at -4div
ch1: {wave: square 10kHz 0.1V | lc 640kHz 1.9, range: 50mV/div}
ch2: {wave: square 10kHz 0.1V | rc 0.4us, range: 50mV/div}
cursors: [0.9us, 2.6us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/20-capacitive-load.svg)

図3 は LTspice の波形に合わせた想定図 (CH1 は 2 次のローパス、CH2 は 1 次のローパスで近似した)。CH1 は −0.1 V から +0.1 V へ上がるとき、
最初の山で約 0.186 V まで行き過ぎ (段の 0.2 V の 43 %)、周期 約 1.6 µs で揺れながら 10 µs ほどかけて収まる。CH2 は行き過ぎずに 0.1 V へ近づく。
カーソル X1・X2 は CH1 の 1 つ目の山と 2 つ目の山の近く。間が揺れの周期で、周波数は約 0.6 MHz (OP アンプの帯域の 1 MHz の少し下)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2 | オペアンプ (1 個の LM358 の 2 回路) | LM358 (データシートの容量負荷の図は LM358B のもの) |
| C<sub>L1</sub>, C<sub>L2</sub> | セラミックコンデンサ (容量負荷。ケーブル数 m ぶんの容量) | 各 470 pF (C0G) |
| R<sub>iso</sub> | 抵抗 (容量の切り離し) | 1 kΩ |
| — | 信号源 | 10 kHz・±0.1 V の方形波 |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (U1 の出力と C) |

## 見るべき値

表の値は LTspice の読み (容量負荷の効き方を TI の LM358B の図に合わせた模型。下の節)。実物の LM358 は型番の末尾 (無印・B) と製造元で帯域が違うので、
行き過ぎの大きさは表と 2 倍ほど違ってもよい。**C<sub>L</sub> を増やすと行き過ぎが増え、R<sub>iso</sub> で消える**、という向きを確かめる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| U1 の出力の行き過ぎ (C<sub>L1</sub> 470 pF) | 約 43 % (山 約 0.19 V) | 位相余裕が減って揺れる |
| U1 の揺れの周波数 | 約 0.6 MHz | 帰還の輪が 1 周で 360° 遅れかける周波数の近く |
| C<sub>L1</sub> を外したとき | 約 8 % | OP アンプ自身の位相余裕 (約 58°) の分 |
| C<sub>L1</sub> を 1 nF に増やしたとき | 約 54 % | 容量が大きいほど遅れる |
| C (C<sub>L2</sub> の上、R<sub>iso</sub> 1 kΩ) | 行き過ぎ 0 %、立ち上がり 約 0.9 µs (10 %→90 %) | 容量が輪の外に出た。代わりに R<sub>iso</sub> × C<sub>L2</sub> の分だけ遅い |
| R<sub>iso</sub> を 100 Ω・470 Ω にしたとき | 行き過ぎ 約 35 %・14 % | 小さすぎると切り離しが足りない。R<sub>O</sub> (数百 Ω) より大きくする |

## LTspice での確かめ

`sim/20-capacitive-load.cir` で図1 を過渡解析で走らせ、C<sub>L1</sub> を 1 pF〜1 nF、R<sub>iso</sub> を 100 Ω〜2.2 kΩ に振った。
オペアンプは 2 極と開ループの出力抵抗を持つ模型 (GBW 1.2 MHz、第 2 の極 1.33 MHz、R<sub>O</sub> 800 Ω。**仮定**で、実測ではない)。
R<sub>O</sub> と第 2 の極は、TI の LM358B のデータシートの図 (利得 1 倍の小信号の行き過ぎと容量の関係) に合うように選んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 行き過ぎ (C<sub>L</sub> 0 pF・160 pF・330 pF) | データシートの図 約 8 %・28 %・40 % | 8.3 %・26.6 %・37.4 % | 合う (模型をこの図に合わせた) |
| 行き過ぎ (C<sub>L1</sub> 470 pF) | 約 43 % | 42.9 % (山 0.186 V、段から 1.2 µs) | 合う |
| 行き過ぎ (C<sub>L1</sub> 1 nF) | 約 54 % | 54.3 % | 合う |
| 揺れの周期 | 約 1.6 µs | 1.6 µs (山 11.2 µs と 12.9 µs) | 合う |
| C の行き過ぎ (R<sub>iso</sub> 1 kΩ) | 0 % | 0 %、2 % に収まるまで 1.7 µs | 合う |
| C の立ち上がり (R<sub>iso</sub> 1 kΩ) | 約 0.9 µs | 0.90 µs | 合う |
| R<sub>iso</sub> 100 Ω・470 Ω・2.2 kΩ の行き過ぎ | 約 35 %・14 %・0 % | 35.5 %・14.3 %・0 % (2.2 kΩ は立ち上がり 2.2 µs) | 合う |

## 出典

自作。
参考: [TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) (Figure 5-25 と 5-27、LM358B の容量負荷の行き過ぎと位相余裕)、[Phase margin (Wikipedia)](https://en.wikipedia.org/wiki/Phase_margin)
