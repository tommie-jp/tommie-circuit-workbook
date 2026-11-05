---
book: analog-discovery
chapter: 2
id: 2-18
title: 電源投入の突入電流 (Single トリガ)
tier: 200
source: 自作
board: BB
---

# 2-18 電源投入の突入電流 (Single トリガ)

電源の入口に大きなコンデンサがある機器は、スイッチを入れた瞬間、空のコンデンサを満たすために定常よりずっと大きな電流を吸い込む。
これを**突入電流**という。続くのは数十 ms で、二度と同じ形では来ない 1 回きりの現象なので、
繰り返しの波形を前提にした Run (連続) の画面では捕まえにくい。1-6 と 2-12 で使った **Single** (1 回だけ取り込んで止まる) と、
トリガの位置を画面の左寄りに置く設定で、押した瞬間の前後をまるごと 1 枚に残す。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 スイッチを入れた瞬間に 100 µF へ流れ込む電流を R1 の両端で読む
parts:
  V1: vsource 1,3 1,7 5
  SW1: button 1,3 4,3 l=$\mathrm{SW1}$
  M1: voltmeter 4,4 4,7 l=$\mathrm{CH1}$
  M2: voltmeter 4,1.5 7,1.5 l=$\mathrm{CH2}$
  R1: resistor 4,3 7,3 220
  C1: ecap 7,3 7,7 100u
  RL: resistor 9,3 9,7 1k
  G1: ground 1,7
wires:
  - 4,3 -- 4,4
  - 4,1.5 -- 4,3
  - 7,1.5 -- 7,3
  - 7,3 -- 9,3
  - 1,7 -- 4,7 -- 7,7 -- 9,7
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/18-inrush-single.svg)

- V1 は AD3 の Supplies の V+ (5 V)。SW1 (タクトスイッチ) を押すと、R1 (220 Ω (オーム)) を通して C1 (100 µF (マイクロファラド)、電解) と RL (1 kΩ、機器の負荷の代わり) に電源が入る
- C1 と RL が「入口にコンデンサのある機器」の模型。R1 は突入電流を抑える抵抗 (実際の機器では NTC サーミスタなど) で、
  **同時に電流の検出抵抗**にもする。CH2 を R1 の両端に差動でつなぎ (2-4 と同じ)、電圧 ÷ 220 Ω で電流を読む
- CH1 は SW1 の出口の電圧。押した瞬間に 0 → 5 V に跳ぶので、これをトリガにする
- R1 を入れるのは AD3 を守るためでもある。R1 が無いと、空の 100 µF は一瞬ほぼ短絡で、電流は Supplies が出せる量 (USB 給電で 1 系統 250 mW、5 V で約 50 mA が目安) で頭打ちになり、
  V+ が下がる。220 Ω なら最大でも 5 V / 220 Ω = 22.7 mA で、目安の半分に収まる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (SW1 を押すと 100 µF に電源が入る)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1-, 1+, 2+, 2-]
  SW1: button @ f10
  R1: resistor c12 c18 220
  C1: capacitor/electrolytic b18 b21 100u cap=below:2,0
  RL: resistor d18 d24 1k
wires:
  - AD.V+ -- +t4 red
  - +t1 -- +b1 red
  - j10 -- +b10 red
  - AD.GND -- -t7 black
  - AD.1- -- -t8 black
  - AD.1+ -- a10 orange
  - AD.2+ -- a12 blue
  - AD.2- -- a18 green
  - a21 -- -t21 black
  - a24 -- -t24 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/18-inrush-single.svg)

- V+ (赤) は上の + レールから左端の赤い線で下の + レールへ回し、`j10` から SW1 の下側のピンへ入れる。
  SW1 は溝をまたぎ、押すと下側 (10・12 列の f〜j) と上側 (10・12 列の a〜e) がつながる。上側の 10 列と 12 列は中でつながっている
- R1 (12 列〜18 列)、C1 (18 列が + 、21 列が −)、RL (18 列〜24 列) は上のブロック。C1 の − と RL の他端は上の − レール (GND) へ
- 1+ (橙) は SW1 の出口の 10 列、2+ (青) は同じ点の 12 列、2− (緑) は R1 の先の 18 列。CH2 は差動なので、2− を GND に落とさない
- C1 は耐圧 10 V 以上の電解。足の長い方 (+) を 18 列に挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable (SW1 を押すまで回路には届かない) |
| Scope (CH1) | DC、1 V/div、Offset で 0 V を下から 1 目盛に置く |
| Scope (CH2) | DC、1 V/div、CH1 と同じ位置 (電流 = CH2 ÷ 220 Ω。1 V が 4.55 mA) |
| Math | Simple の `−` で CH1 − CH2 (部品の C1 の両端の電圧) |
| Time | 10 ms/div。Position (トリガの位置) を左から 1 目盛 (押す前の 10 ms も残る) |
| Trigger | Mode は **Normal** (Auto だと待ちきれずに勝手に取り込む)、Source CH1、Edge、Rising、2.5 V |
| 取り込み | **Single** を押してから SW1 を押し、押したまま 100 ms 以上待つ。取り込むと止まる |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 押した瞬間に 22.7 mA (CH2 = 5 V) が流れ、τ = 18 ms で 4.1 mA へ落ちる
time: 10ms/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: = 5V * step(t), range: 1V/div, position: -3div}
ch2: {wave: "= step(t) * (0.902V + 4.098V * exp(-t / 18.03ms))", range: 1V/div, position: -3div}
math: {expr: ch1 - ch2, range: 1V/div, position: -3div}
cursors: [50us, 18.08ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/18-inrush-single.svg)

図3 は理想の形 (スイッチの接点のはねと Supplies の電圧の下がりは描いていない)。CH1 (橙) は押した瞬間に 5 V へ立ち、
CH2 (青、R1 の両端) は 5 V から始まって指数関数で 0.90 V へ下がる。Math (赤) が C1 の電圧で、0 から 4.10 V へ上がる。
X1 (押した直後) と X2 (X1 から 18.03 ms) の間で、CH2 は 4.99 V → 2.41 V。最初からの差 (5 V − 0.90 V) の 63 % を下りた所が τ (タウ) になる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| SW1 | タクトスイッチ (6 mm 角、4 ピン) | — |
| R1 | 抵抗 (突入電流の制限と電流の検出) | 220 Ω |
| C1 | 電解コンデンサ (耐圧 10 V 以上) | 100 µF |
| RL | 抵抗 (機器の負荷の代わり) | 1 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope (1+ = SW1 の出口、2+ / 2− = R1 の両端) |

## 見るべき値

表の値は計算値。Supplies の内部抵抗と C1 の ESR (内部の直列抵抗) は 0 と置いた。

| 項目 | 期待する値 | 計算 |
| --- | --- | --- |
| 突入電流のピーク (押した瞬間) | 22.7 mA (CH2 = 5.00 V) | 5 V / 220 Ω。空の C1 は短絡と同じ |
| 時定数 τ | 18.0 ms | (R1 ∥ RL) × C1 = 180.3 Ω × 100 µF。C1 から見た抵抗は R1 と RL の並列 |
| τ のときの電流 | 10.9 mA (CH2 = 2.41 V) | 4.10 + (22.7 − 4.10) × e<sup>−1</sup> mA。図3 の X2 |
| 定常の電流 | 4.10 mA (CH2 = 0.902 V) | 5 V / (220 + 1000) Ω。5 τ (90 ms) でほぼここ |
| 定常の C1 の電圧 | 4.10 V (Math) | 5 V × 1000 / 1220 |
| 突入電流 ÷ 定常の電流 | 5.5 倍 | 22.7 / 4.10。R1 が小さいほど大きくなる |

確かめ方の手順:

1. Single を押して待ち、SW1 を押す。取り込んで止まった画面で、CH2 の山の高さ (Vmax) と、山から 63 % 下りるまでの時間をカーソルで読む
2. SW1 を離して約 50 ms 後にもう一度押す (Single をやり直してから)。C1 は RL を通して τ = 100 ms で放電するので、
   50 ms 後はまだ 4.10 × e<sup>−0.5</sup> = 2.49 V 残っている。突入電流の山は (5 − 2.49) / 220 = 11.4 mA に下がる。
   **入れ直しのときは突入電流が小さい**ことが、押し直す間合いで変わる山の高さで見える
3. 押した瞬間の CH1 の立ち上がりを 100 µs/div で拡大すると、0 V と 5 V を何度か行き来する。タクトスイッチの接点のはね (2-19 のリレーと同じ現象) で、
   突入電流もそのたびに途切れる

Run (連続) のままでは、押す前の何も起きない画面が次々に上書きされ、押した瞬間の 1 枚が一瞬で流れて消える。
Normal の Single は**条件が来るまで待ち、来たら 1 枚だけ残して止まる**ので、1 回きりの現象を後からカーソルで読める。

## LTspice での確かめ

`sim/18-inrush-single.cir` で図1 を過渡解析で走らせた。SW1 は理想のスイッチ (はね無し)、Supplies の内部抵抗と C1 の ESR は 0 と**仮定**した (実測ではない)。
1 ms で押し、201 ms で離し、251 ms で押し直した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 突入電流のピーク | 22.7 mA | 22.73 mA | 合う |
| 時定数 τ (63 % 下りるまで) | 18.0 ms | 18.00 ms | 合う |
| τ のときの電流 | 10.9 mA | 10.95 mA | 合う |
| 定常の電流 | 4.10 mA | 4.099 mA | 合う |
| 定常の C1 の電圧 | 4.10 V | 4.098 V | 合う |
| 離して 50 ms 後の C1 の電圧 | 2.49 V | 2.486 V | 合う |
| 押し直したときの山 | 11.4 mA | 11.43 mA | 合う |

## 出典

自作。Single・Trigger の Normal / Auto の働きは WaveForms 付属のヘルプ (Oscilloscope の Control の節) による。

参考: [突入電流 (Wikipedia)](https://ja.wikipedia.org/wiki/突入電流)、[RC 回路 (Wikipedia)](https://ja.wikipedia.org/wiki/RC回路)
