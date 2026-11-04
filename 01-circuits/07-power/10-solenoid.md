---
book: circuits
chapter: 7
id: 7-10
title: ソレノイド
tier: 200
source: 自作
---

# 7-10 ソレノイド

ソレノイドは、巻線に電流を流すと鉄の棒 (プランジャ) を引き込む部品だ。電気錠・自動販売機の払い出し・プリンタの印字ハンマーなど、
「一瞬だけ押す・引く」動きに使う。駆動は 7-1 のリレーや 7-2 のモータと同じで、MOSFET で巻線の GND 側を開閉し、フライバックダイオードで切ったときの逆起電力を逃がす。

この題で新しく見るのは、**ダイオードの付け方で、切ってからプランジャが戻るまでの時間が変わる**ことだ。
7-1 のようにダイオード 1 本で巻線を短絡すると、巻線の電流はダイオードを回り続け、時定数 L/R でゆっくり減る。
電流が残っている間は磁力が残るので、プランジャはすぐには戻らない。ダイオードに**ツェナーダイオードを直列に**足すと、
巻線の両端に逆向きに 12 V ほどの電圧が掛かり、電流は数倍の速さで 0 になる。代わりに、MOSFET のドレインは 5 V より 13 V ほど高くなる。

電流の立ち上がりも見る。巻線の電流は、ON にした瞬間から時定数 L/R で増えていく (6-2 で見た RL の過渡)。
プランジャが動き出すと巻線のインダクタンスが変わるので、電流の曲線に小さなくぼみが出る。くぼみの時刻が、プランジャが引き込まれた時刻の目安になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ソレノイドを MOSFET で駆動する (S1 を開くと DZ が入る)
parts:
  VCC: vcc 6,1 5V
  Rs: resistor 6,1 6,2.5 1
  M2: voltmeter 4.6,1 4.6,2.5 l=$\mathrm{CH2}$
  L1: inductor 6,2.5 6,4 l=$\mathrm{L1}$
  D1: diode 8,4 8,2.6 1N4007
  DZ: zener 8,1 8,2.6 12V
  S1: switch 9.6,1 9.6,2.6
  Q1: nmos-e 6,5.31 2N7000
  M1: voltmeter 11,4 11,5.8 l=$\mathrm{CH1}$
  G1: ground 11,5.8
  W1: square 1.6,5.5 1.6,7 l=$\mathrm{W1}$
  G2: ground 1.6,7
  Rg: resistor 3,5.5 4.4,5.5 100
  Rpd: resistor 4.4,5.5 4.4,7 10k
  G3: ground 4.4,7
  G4: ground 6,7
wires:
  - 6,1 -- 8,1 -- 9.6,1
  - 8,2.6 -- 9.6,2.6
  - 4.6,1 -- 6,1
  - 4.6,2.5 -- 6,2.5
  - 6,4 -- 8,4 -- 11,4
  - 6,4 -- Q1.D
  - Q1.S -- 6,7
  - 1.6,5.5 -- 3,5.5
  - 4.4,5.5 -| Q1.G
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/10-solenoid.svg)

- L1 がソレノイドの巻線。巻線そのものの抵抗 (この題では 33 Ω の品を例にする) を含む。
  5 V で流れる電流は 5 V ÷ (33 + 1 + 4.5) Ω ≈ 130 mA (1 Ω は Rs、4.5 Ω は 2N7000 の ON 抵抗の典型)。2N7000 の 0.2 A とブレッドボードの 1 穴 200 mA の内側に収まる
- Rs (1 Ω) は電流を読む抵抗。巻線と同じ枝 (5 V と巻線の間) に入れたので、ON の間も、切ったあとにダイオードを回る電流も読める。
  AD3 の Scope の 2+ を 5 V 側、2− を巻線側に当てて差動で読む (1 mV が 1 mA)
- D1 (1N4007) がフライバックダイオード。S1 を閉じていれば D1 だけ、開くと D1 に DZ (12 V のツェナーダイオード) が直列に入る。
  DZ の向きは、巻線の逆起電力が DZ を逆方向に押す向き (カソードが D1 のカソード側)。ON の間は D1 が逆向きなので、どちらも電流を通さない
- Rg (100 Ω)・Rpd (10 kΩ) は 7-2 と同じゲートの直列抵抗とプルダウン
- 2N7000 の V<sub>DS</sub> の最大は 60 V。DZ を入れたときのドレインの山 (約 18 V) はその内側

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ソレノイドの駆動 (S1 は DZ を短絡するスイッチ)
board: half
parts:
  Rs: resistor c5 c9 1
  D1: diode b12 b16 1N4007
  S1: switch c16 c20
  DZ: zener e20 e16 12V
  Q1: transistor h12(D) h13(G) h14(S) 2N7000
  Rg: resistor g13 g18 100
  Rpd: resistor i18 i21 10k
  PSU:
    type: device
    at: top
    label: 電源 5V (別電源)
    pins: ["+", "-"]
  SOL:
    type: device
    at: top
    label: ソレノイド L1
    pins: [S+, S-]
  ADS:
    type: device
    at: top
    label: AD3 (Scope 2)
    pins: [2+, 2-]
  ADW:
    type: device
    at: bottom
    label: AD3 (Scope 1・W1)
    pins: [1-, 1+, W1, GND]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - +t5 -- a5 red
  - +t20 -- a20 red
  - SOL.S+ -- a9 orange
  - SOL.S- -- a12 brown
  - e12 -- f12 brown
  - j14 -- -b14 black
  - j21 -- -b21 black
  - -t28 -- -b28 black
  - ADS.2+ -- +t3 blue
  - ADS.2- -- b9 white
  - ADW.1+ -- j12 green
  - ADW.1- -- -b10 black
  - ADW.W1 -- j18 yellow
  - ADW.GND -- -b24 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/10-solenoid.svg)

- 5 V の電源は上の + レールへ。5 列と 20 列の上の段が 5 V (`a5`・`a20` から + レールへ)。上下の − レールは 28 列でつなぐ
- Rs (5→9 列) の 9 列からソレノイドの S+ の線 (橙) へ。S− の線 (茶) は 12 列に挿し、12 列を茶の線で下のブロックへ渡す。12 列がドレインの点
- D1 はアノードが 12 列、カソード (帯) が 16 列。16 列と 20 列 (5 V) の間に S1 と DZ を並べて挿す。DZ のカソード (帯) が 16 列。
  S1 を閉じると DZ が短絡され、D1 だけになる
- Q1 (2N7000) は、ドレインを 12 列に合わせるため、印字面を奥に向けて挿す (左から D・G・S。7-2 と同じ向き)。S (14 列) は下の − レールへ。
  **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- Rg は G (13 列) から 18 列へ。18 列に W1 (黄) と Rpd (18→21 列、21 列は − レール)
- Scope の 2+ (青) は Rs の 5 V 側 (+ レール、`+t3`)、2− (白) は巻線側 (`b9`) に当て、差動で電流を読む。1+ (緑) はドレイン (`j12`)
- 5 V の電源は別の電源 (USB アダプタなど)。巻線の 130 mA は AD3 の Supplies の 50 mA を超える。ブレッドボードの 1 穴 200 mA の内側

## 計器の設定

計器は Analog Discovery 3 の W1 (ゲートの信号) と Scope。電流の立ち上がりと、切ったあとの減り方は時間の波形で見る。
W1 は Simple の Square、Frequency 10 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)、Symmetry 50 % (50 ms ON・50 ms OFF)。
Scope は 1+ をドレイン (5 V/div)、2+・2− を Rs の両端 (50 mV/div、1 mV = 1 mA) にし、トリガを CH1 の立ち上がり (切った瞬間) にする。
図3 と図4 は同じ尺度で、S1 を閉じたとき (D1 だけ) と開いたとき (D1 + DZ) を比べる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 D1 だけ — 電流 (CH2) は 1.7 ms かけて 0 になる
time: 200us/div
trigger: ch1 rising 3V at -4div
ch1: {wave: "= 0.55V * (1 - step(t)) + step(t) * (5V + 0.8V * step(1.67ms - t))", range: 5V/div, position: -3div}
ch2: {wave: "= 131mV * (1 - step(t)) + step(t) * max(154.3mV * exp(-t / 0.882ms) - 23.3mV, 0V)", range: 50mV/div, position: -3div}
cursors: [10us, 1.7ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/10-solenoid-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 D1 + DZ — 電流 (CH2) は 0.26 ms で 0 になり、ドレインは 18 V
time: 200us/div
trigger: ch1 rising 3V at -4div
ch1: {wave: "= 0.55V * (1 - step(t)) + step(t) * (5V + 13.2V * step(258us - t))", range: 5V/div, position: -3div}
ch2: {wave: "= 131mV * (1 - step(t)) + step(t) * max(516.6mV * exp(-t / 0.882ms) - 385.6mV, 0V)", range: 50mV/div, position: -3div}
cursors: [10us, 260us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/10-solenoid-2.svg)

図3・図4 は LTspice の波形から作った理想の形 (下の「LTspice での確かめ」)。t = 0 が Q1 を切った瞬間。
切る前は CH2 が 131 mV (130 mA)、ドレイン (CH1) が 0.55 V。

- **図3 (D1 だけ)**: 切ると、巻線の電流は D1 と Rs を回って流れ続ける。ドレインは 5 V より D1 の順方向電圧ぶん高い約 5.8 V に留まり、
  電流は巻線の抵抗で時定数 L/R ≈ 0.88 ms で減って、約 1.7 ms で 0 になる (X2)
- **図4 (D1 + DZ)**: 巻線の両端に 5 V + 12 V + 0.8 V − 5 V ≈ 13 V が逆向きに掛かる。電流はほぼまっすぐ減り、約 0.26 ms で 0 になる (X2)。
  その間、ドレインは約 18 V まで上がる

電流が速く 0 になるほど、磁力も速く消え、プランジャが速く戻る。ツェナーの電圧を上げるほど速いが、そのぶんドレインの電圧も上がるので、
MOSFET の V<sub>DS</sub> の最大 (2N7000 は 60 V) の内側で選ぶ。

**ON の側を見る**: トリガを CH1 の立ち下がりに替え、時間軸を 1 ms/div にすると、電流が時定数約 0.77 ms で 130 mA へ上がる曲線が見える。
プランジャが動けば、曲線の途中に小さなくぼみが出る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | 5 V 用の小型ソレノイド (プッシュ型・プル型のどちらでも) | 巻線 33 Ω・L 30 mH の品を例にした (L は仮定。品で 10〜100 mH)。巻線が 30 Ω より小さい品は 5 V で 150 mA を超えるので使わない |
| Q1 | N チャネル MOSFET | 2N7000 (0.2 A・60 V) |
| D1 | 整流ダイオード | 1N4007 |
| DZ | ツェナーダイオード (0.5 W) | 12 V |
| S1 | スライドスイッチか、DZ をまたぐジャンパ線 | — |
| Rs | 抵抗 (電流を読む) | 1 Ω |
| Rg | 抵抗 (ゲート直列) | 100 Ω |
| Rpd | 抵抗 (ゲートのプルダウン) | 10 kΩ |
| — | 電源 | 5 V の USB アダプタなど (130 mA。AD3 の Supplies の 50 mA を超えるため別電源) |
| — | 計器・信号源 | Analog Discovery 3 の W1 (0〜5 V、10 Hz) と Scope (1+ = ドレイン、2+・2− = Rs の両端) |

## 見るべき値

表の値は LTspice と計算の値で、実測ではない (L1 は 33 Ω・30 mH と仮定。プランジャの動きは入れていない)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ON の間の電流 (CH2) | 約 130 mA (131 mV) | 5 V ÷ (33 + 1 + 4.5) Ω |
| ON の間のドレイン電圧 | 約 0.55 V | 130 mA × 2N7000 の ON 抵抗 |
| ON にしてから 63 % (82 mA) まで | 約 0.77 ms | 時定数 L/R = 30 mH ÷ 38.5 Ω |
| 切ってから電流が 0 になるまで (D1 だけ) | 約 1.7 ms | 巻線の抵抗だけで電流を減らすので遅い |
| 切ってから電流が 0 になるまで (D1 + DZ) | 約 0.26 ms | 逆向きの 13 V で電流を減らすので 6 倍ほど速い |
| 切った瞬間のドレインの山 (D1 だけ / D1 + DZ) | 約 5.8 V / 約 18 V | 速く切るほど高い電圧を MOSFET が受ける |
| ON の間の電流の曲線のくぼみ | プランジャが動いた所に出る | インダクタンスが変わり、巻線に逆起電力が出る (形と時刻は品と負荷で違う) |

巻線に溜まるエネルギー ½ L I² = ½ × 30 mH × (0.13 A)² ≈ 0.25 mJ は、D1 だけなら巻線の抵抗で、DZ を入れれば主に DZ で熱になる。
10 Hz なら DZ の平均の電力は 2.5 mW ほどで、0.5 W 品で足りる。

## LTspice での確かめ

`sim/10-solenoid.cir` で図1 を回した。L1 は 33 Ω・30 mH の仮定、2N7000 と 1N4007 は 7-2 と同じ模型、DZ は 12 V の仮定のツェナーの模型。
プランジャの動き (インダクタンスの変化) は入れていない。実測ではない。図3・図4 の式は、この結果に合わせて作った。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ON の電流 | 約 130 mA | 131 mA | 合う |
| ON のドレイン電圧 | 約 0.55 V | 0.55 V | 本文の値は LTspice の読み |
| 63 % までの時間 | 約 0.77 ms | 0.77 ms | 合う (L/R = 0.78 ms) |
| 電流が 0 になるまで (D1 だけ) | 約 1.7 ms | 1.70 ms (10 % まで 1.29 ms) | 合う |
| 電流が 0 になるまで (D1 + DZ) | 約 0.26 ms | 0.26 ms (10 % まで 0.23 ms) | 合う |
| ドレインの山 (D1 だけ / D1 + DZ) | 約 5.8 V / 約 18 V | 5.83 V / 18.15 V | 合う |
| 切って 0.5 ms・1 ms の電流 (D1 だけ) | 図3 の式で 64 mA・26 mA | 64.2 mA・26.7 mA | 合う |

## 出典

自作。

参考: [ソレノイド (Wikipedia)](https://ja.wikipedia.org/wiki/ソレノイド)、[Flyback diode (Wikipedia)](https://en.wikipedia.org/wiki/Flyback_diode)、[Vishay 2N7000 のデータシート](https://www.vishay.com/docs/70226/70226.pdf)
