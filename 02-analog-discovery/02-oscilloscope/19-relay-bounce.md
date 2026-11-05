---
book: analog-discovery
chapter: 2
id: 2-19
title: リレーの接点バウンス
tier: 200
source: 自作
board: BB
---

# 2-19 リレーの接点バウンス

リレーやスイッチの金属の接点は、閉じた瞬間にばねのように何度か跳ね返り、開いたり閉じたりを繰り返してから落ち着く。
これを**接点バウンス** (チャタリング) という。人の目にも耳にも「カチッ」の 1 回だが、1 回の跳ねは数十 µs (マイクロ秒) で、
マイコンの入力につなぐと 1 回の操作を何回にも数えてしまう。回路の教科書 7-1 のリレー駆動の回路をそのまま使い、
接点の側に抵抗を 1 本足して、**コイルに電流を流してから接点が閉じるまでの時間 (動作時間) と、閉じたあとのはね**を Single トリガで捕まえる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 リレーの接点 (NO1) を 1 kΩ で GND へ引き、接点の電圧を CH1 で見る
parts:
  VCC: vcc 5,2 5V
  D1:  diode 3,6 3,3 1N4148
  K1:  relay 5.88,5 r180 mirror G5V-2
  Q1:  npn 5,8
  R1:  resistor 2,8 4,8 1k
  IN:  port 2,8
  G1:  ground 5,9
  R2:  resistor 9,7 9,10 1k
  M1:  voltmeter 11,7 11,10 l=$\mathrm{CH1}$
  G2:  ground 9,10
  M2:  voltmeter 1,6 1,9 l=$\mathrm{CH2}$
  G4:  ground 1,9
wires:
  - 5,2 -- 5,3 -- 3,3
  - K1.A2 |- 5,3
  - K1.A1 |- 5,6
  - 3,6 -- 5,6 -- Q1.C
  - 4,8 -- Q1.B
  - Q1.E -- 5,9
  - K1.COM1 |- 5,3
  - K1.NO1 |- 9,7
  - 9,7 -- 11,7
  - 9,10 -- 11,10
  - 3,6 -- 1,6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/19-relay-bounce.svg)

- 駆動の側は 7-1 と同じ。IN (AD3 の W1、0 V / 5 V) が H になると Q1 (2SC1815) が飽和し、コイル (K1 の A1-A2) に約 94 mA が流れる。D1 はフライバックダイオード
- 接点の側は COM1 を 5 V、NO1 を R2 (1 kΩ (キロオーム)) で GND へ引く。接点が開いていれば NO1 は 0 V、閉じれば 5 V。CH1 は NO1 を見る
- CH2 は Q1 のコレクタ。Q1 が入った瞬間に 5 V から 0.29 V へ落ちるので、**コイルに電圧が掛かった時刻**の目印になる。ここをトリガにする
- 接点に流れるのは 5 V / 1 kΩ = 5 mA。G5V-2 の接点の定格 (DC 30 V で 2 A) よりずっと小さい

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 リレーを動かし、接点を 1+、コレクタを 2+ で見る (W1 が IN)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源 5V (AC アダプタ等)
    pins: ["+", "-"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (W1 と Scope)
    pins: [W1, 2+, 1-, 2-, GND, 1+]
  K1: relay @ f10
  Q1: transistor i4(E) i5(C) i6(B) 2SC1815
  R1: resistor f1 f6 1k
  D1: diode i10(A) i13(K) 1N4148
  R2: resistor g17 g21 1k
wires:
  - PSU.+ -- +t2 red
  - PSU.- -- -t3 black
  - +t10 -- a10 red
  - g5 -- g10 yellow
  - j4 -- -b4 black
  - AD.W1 -- j1 orange
  - AD.2+ -- j5 blue
  - AD.1- -- -b7 black
  - AD.2- -- -b9 black
  - AD.GND -- -b11 black
  - AD.1+ -- j17 green
  - g13 -- +b13 red
  - j21 -- -b21 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/19-relay-bounce.svg)

- 7-1 の図2 から LED と 330 Ω を外し、NO1 (17 列) と 21 列の間に R2 (1 kΩ) を入れ、21 列を下の − レール (GND) へ落とした
- 1+ (緑) は NO1 の 17 列 (`j17`)、2+ (青) は Q1 のコレクタの 5 列 (`j5`)。W1 (橙) は IN の 1 列。1−・2−・GND は下の − レールへ
- コイルの電源は 5 V の AC アダプタか電源装置 (7-1 と同じ)。コイルの約 94 mA は、AD3 の Supplies の各レールの目安 (約 50 mA、USB 給電で 250 mW) を超える。
  AD3 の GND と外の電源の − は、下の − レールで必ずつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Square、5 Hz、Amplitude 2.5 V、Offset 2.5 V (0 V / 5 V。100 ms ごとにリレーが入り切りする) |
| Scope (CH1・CH2) | DC、どちらも 1 V/div、0 V を下から 1 目盛に置く |
| Time | 図3 は 1 ms/div、図4 は 50 µs/div。どちらもトリガの位置を左から 1 目盛 |
| Trigger (図3) | Normal、CH2、Falling、2.5 V (コレクタが落ちる = コイルに電圧が掛かる) |
| Trigger (図4) | Normal、CH1、Rising、2.5 V (接点が最初に閉じた瞬間) |
| 取り込み | **Single**。1 回ずつ取り込んで、はねの回数と長さが毎回違うことを見る |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 コレクタ (CH2) が落ちてから 3.5 ms 後に接点 (CH1) が閉じる
time: 1ms/div
trigger: ch2 falling 2.5V at -4div
ch1: {wave: "= 5V * (step(t - 3.5ms) - step(t - 3.56ms) + step(t - 3.61ms) - step(t - 3.67ms) + step(t - 3.71ms) - step(t - 3.75ms) + step(t - 3.8ms))", range: 1V/div, position: -3div}
ch2: {wave: = 5V - 4.71V * step(t), range: 1V/div, position: -3div}
cursors: [0, 3.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/19-relay-bounce-1.svg)

図3 は想定図。X1 (コレクタが落ちた瞬間) から X2 (接点が最初に閉じた瞬間) までが**動作時間**で、ここでは 3.5 ms と置いた。
閉じた直後に CH1 が何度か 0 V へ戻るのが、はね。1 ms/div では細い縦の線の束にしか見えないので、図4 で拡大する。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 接点の閉じ始めを拡大 — 0.3 ms のあいだに 3 回はねる
time: 50us/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: "= 5V * (step(t) - step(t - 60us) + step(t - 110us) - step(t - 170us) + step(t - 210us) - step(t - 250us) + step(t - 300us))", range: 1V/div, position: -3div}
ch2: {wave: dc 0.29V, range: 1V/div, position: -3div}
cursors: [0, 300us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/19-relay-bounce-2.svg)

図4 も想定図で、はねの回数と間隔は 1 回ごとに変わる。最初に閉じた X1 から、最後に閉じてそのまま落ち着く X2 までが**はねの時間** (バウンス時間) で、ここでは 0.3 ms。
CH1 が 5 V と 0 V のあいだを途中の値なしに行き来するのは、R2 が接点の開いた瞬間に NO1 を 0 V へ引くから。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| K1 | リレー (Omron G5V-2、5 V) | コイル抵抗 50 Ω (オーム)、定格コイル電流 100 mA |
| Q1 | NPN トランジスタ | 2SC1815 |
| R1 | 抵抗 (ベース) | 1 kΩ |
| D1 | 小信号ダイオード (フライバック用) | 1N4148 |
| R2 | 抵抗 (接点の引き下げ) | 1 kΩ |
| — | 電源 | 5 V の AC アダプタか電源装置 (コイルの約 94 mA が AD3 の Supplies の目安 50 mA を超えるため) |
| — | 計器 | AD3 の W1 (IN) と Scope (1+ = NO1、2+ = コレクタ) |

## 見るべき値

時間の値は G5V-2 のデータシート ([Omron G5V-2](https://omronfs.omron.com/en_US/ecb/products/pdf/en-g5v_2.pdf)) の値と、
その特性のグラフ (12 V 品・50 個の分布) から読んだ**目安**。5 V 品の分布は載っていない。

| 項目 | 期待する値 | 読み方・出所 |
| --- | --- | --- |
| 動作時間 (コイルに電圧 → 接点が閉じる) | 7 ms 以下。分布の山は 3〜4 ms | データシートの Operate time (最大 7 ms) と分布のグラフ。図3 の X1→X2 |
| 動作のはねの時間 | 0.15〜0.6 ms (多くは 0.2〜0.5 ms) | 分布のグラフの Operating bounce time。図4 の X1→X2 |
| 復帰時間 (コイルを切る → 接点が開く) | 3 ms 以下 (D1 を入れると長くなる) | Release time (最大 3 ms)。D1 がコイルの電流をゆっくり減らすので、データシートの値より遅れる |
| 復帰のはねの時間 | 1.2〜4 ms | 分布のグラフの Release bounce time。開くときは NO1 が 0 V に落ちたあと何度か 5 V へ戻る |
| コイルの電流 | 約 94 mA | (5 − 0.29) V / 50 Ω。7-1 と同じ |
| 接点が閉じたときの NO1 | 5.0 V | COM1 の 5 V がそのまま出る (接点の抵抗は 50 mΩ 以下で、5 mA では 0.25 mV しか落ちない) |

確かめ方の手順:

1. 図3 の設定で Single を 10 回ほど繰り返し、動作時間とはねの回数をそれぞれ書き留める。動作時間はほぼ同じで、はねの回数と長さが毎回違う
2. トリガを CH2 の Rising (コイルを切った瞬間) に替え、復帰を見る。コレクタは 7-1 で見たとおり一瞬 5.8 V まで上がり、
   それから何 ms か遅れて NO1 が落ちる。開くときのはねは、閉じるときより長いことが多い
3. はねを消すなら、NO1 に RC (例: 10 kΩ と 100 nF、τ (タウ) = 1 ms) を入れて 2-17 のシュミットトリガで受ける。RC がはねの短い 0 V を均し、
   シュミットトリガがしきい値の近くで出力が揺れるのを止める。マイコンならソフトで数 ms 待つ

**Single で 1 回ずつ取るのが要点。** Run のままだと 100 ms ごとに上書きされ、はねの形は毎回違うので、画面にはにじんだ縦線しか残らない。
2-7 の Persistence にすれば、何回ぶんかを重ねて「はねの続く範囲」を帯として見ることもできる。

## LTspice での確かめ

接点のはねは機械の動きなので SPICE では描けない。`sim/19-relay-bounce.cir` で駆動の側 (7-1 と同じ模型。コイルのインダクタンスは 100 mH と**仮定**、実測ではない) だけを確かめた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| コイルの電流 | 約 94 mA | 94.1 mA | 合う |
| Q1 のコレクタ (飽和) | 0.29 V | 0.293 V | 合う |
| ベース電流 | 約 4 mA | 4.01 mA | 合う |
| コイルを切った瞬間のコレクタの山 | 5.8 V | 5.84 V | 合う |
| コイルの電流が 75 mA (定格の 75 %) に届くまで | — (動作時間 3〜4 ms の一部) | 3.03 ms | 目安。L を 100 mH と置いた値で、接点が動く時間は含まない |
| 切ってからコイルの電流が 10 mA に減るまで (D1 あり) | 復帰が遅れる | 2.95 ms | 目安。D1 の無いデータシートの測り方より復帰が遅れる向きと合う |

## 出典

自作。駆動の回路は回路の教科書 7-1。動作時間・復帰時間・はねの時間の分布は
[Omron G5V-2 のデータシート](https://omronfs.omron.com/en_US/ecb/products/pdf/en-g5v_2.pdf) による。

参考: [チャタリング (Wikipedia)](https://ja.wikipedia.org/wiki/チャタリング)、[リレー (Wikipedia)](https://ja.wikipedia.org/wiki/リレー)
