---
book: circuits
chapter: 9
id: 9-25
title: AGC — 強い局で音量が跳ねないように利得を自動で下げる
tier: 200
source: 自作
board: BB
---

# 9-25 AGC — 強い局で音量が跳ねないように利得を自動で下げる

> **どれもシミュレーション (LTspice) で出した値で、実機では測っていない。** 2SC1815 は 05-etc 第 4 章と同じ代用のモデル
> (hFE 約 250・fT 約 80 MHz の目安から作った仮定) を使った。実物の hFE のばらつきで、効き始める入力は変わる。

ラジオは、近くの強い局と遠くの弱い局で、アンテナに入る電波の強さが 1,000 倍以上も違う。増幅の利得が一定だと、
強い局で増幅段が振り切れて音が割れ、弱い局に合わせて音量を決めると強い局がうるさい。
そこで、**出力の大きさを測って、その大きさに応じて増幅段の利得を自動で下げる**。これが **AGC** (Automatic Gain Control、
自動利得制御。AVC とも) だ。この題では、2SC1815 の 1 段増幅に AGC を足し、入力を 1 mV から 300 mV まで 50 dB 振って、出力がどこまで
一定に保たれるかと、利得が下がる速さを Analog Discovery 3 (AD3) で測る。

結論を先に書く。**入力を 300 倍 (49.5 dB) にしても、出力は 44 倍 (32.9 dB) で済み、16.6 dB ぶん押さえられる。AGC を外すと出力は
4.4 Vpp で頭打ちになる。利得は 20 ms ほどで下がり、40 ms ほどで戻る。**

- **AGC の仕組み**: 増幅段の出力を、コンデンサ C<sub>C</sub> を通して**倍電圧の検波**に入れる。D1 が山を約 0.5 V にそろえ、D2 が谷を
  C<sub>G</sub> に溜めて、出力が大きいほど G の電圧が**下がる**。G は R2 を通して**ベースの電位を決めている**ので、G が下がるとベースが下がり、
  コレクタ電流が減って、利得 (g<sub>m</sub>) が下がる。出力が大きいほど利得が下がる、という負帰還になる
- **弱い信号では何も起きない (遅延 AGC)**: D1・D2 は順方向電圧 (約 0.5 V ずつ) を超えないと導通しないので、出力が約 0.6 Vpp
  を超えるまで G は動かない。G は R<sub>B</sub> で 0.25 V に待機している。弱い局の利得を落とさずに、強い局だけを押さえる、ラジオの AGC に
  必要な性質だ
- **時定数は音より長く**: G の電圧を C<sub>G</sub> が平らにしていて、**戻る時間 (ほぼ R<sub>B</sub> ∥ (R2 + R1) × C<sub>G</sub> ≈ 4.4 kΩ × 10 µF ≈ 44 ms)** は音の周期 (1 kHz なら
  1 ms) よりずっと長い。音の波形まで追うと、音が潰れてしまうから。下がる時間は D2 が C<sub>G</sub> を急いで充電するので短い (約 21 ms)
- **100 kHz で組む理由**: ラジオの AGC は IF (455 kHz) や中波 (0.5〜1.6 MHz) で働くが、原理は搬送波の周波数に依らない。**ブレッドボードの
  範囲 (3 MHz 以下) の中で、AD3 のオシロにそのまま入る 100 kHz** にした (9-11 と同じ)

**計算の方法**: 下の値は、LTspice の過渡解析 (最大刻み 250 ns) で、入力ごとに 0.3 s 走らせ、最後の 10 ms の出力の Vpp を読んだ。
時定数は階段状の入力 (10 mV → 100 mV → 10 mV、各 250 ms) の G の電圧から読んだ。AGC なしは C<sub>C</sub> を 1 pF にして検波を外した値。
モデルは 05-etc 第 4 章と同じ 2SC1815 の代用 (IS = 2 × 10<sup>−14</sup>・BF = 250・VAF = 100・RB = 30 Ω・CJE = 8 pF・CJC = 2 pF・TF = 2 ns) と、
1N4148 (IS = 2.52 nA・N = 1.752・RS = 0.568 Ω)。デッキは `sim/agc.cir` `sim/agc-step.cir` `sim/agc-am.cir`。

## 回路図

```circuit
title: 図1 AGC 付きの 1 段増幅 (出力の大きさで G を引き下げる)
parts:
  VCC: vcc a5 5V
  R1: resistor a5 d5 68k
  R2: resistor d5 g5 15k
  RC: resistor a7 c7 2.2k
  Q1: npn d7
  CIN: capacitor d3 d5 100n
  W1: sine d1 f1 l=$\mathrm{W1}$
  M2: voltmeter d3 f3 l=$\mathrm{CH2}$
  G1: ground f3
  RE1: resistor f7 h7 100
  RE2: resistor h7 k7 390
  CE: ecap h10 k10 10u
  G2: ground k7
  G3: ground k10
  COUT: capacitor c13 c16 100n
  M1: voltmeter c18 e18 l=$\mathrm{CH1}$
  G4: ground e18
  CC: capacitor f13 j13 10n
  D1: diode j13 j16 1N4148
  G5: ground j16
  D2: diode n13 j13 1N4148
  RB: resistor n5 q5 4.7k
  G6: ground q5
  CG: ecap n8 q8 10u
  G7: ground q8
wires:
  - a5 -- a7
  - d1 -- d3
  - f1 -- f3
  - d5 -- Q1.B
  - c7 -- Q1.C
  - c7 -- c13
  - Q1.E -- f7
  - h7 -- h10
  - c13 -- f13
  - c16 -- c18
  - g5 -- n5
  - n5 -- n8
  - n8 -- n13
notes:
  - text d7h5 small left: 2SC1815
  - text m4a5 small left: G
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/25-agc.svg)

- **動作点** (計算): R1・R2・R<sub>B</sub> の分圧で V<sub>B</sub> = **1.07 V**、V<sub>E</sub> = 0.435 V、I<sub>C</sub> = (5 V − 3.05 V) / 2.2 kΩ ≈ **0.89 mA**、
  V<sub>C</sub> = **3.05 V**。待機の G は **0.255 V** (R2 を流れる約 54 µA が R<sub>B</sub> を通るため)
- **利得** (計算): 弱い入力では、R<sub>C</sub> / (r<sub>e</sub> + R<sub>E1</sub>) = 2.2 kΩ / (29 Ω + 100 Ω) ≈ **17 倍** (r<sub>e</sub> = 26 mV / 0.89 mA)。
  R<sub>E2</sub> は C<sub>E</sub> (10 µF) で交流的に短絡される。**R<sub>E1</sub> の 100 Ω は電流帰還 (エミッタの負帰還) で、ベース・エミッタ間にかかる信号を小さくする**。
  これを 0 Ω (R<sub>E</sub> 470 Ω を C<sub>E</sub> で丸ごと短絡) にすると、10 mV の入力で音の変調度が 0.5 から約 0.23 に落ちた (R<sub>E1</sub> 100 Ω なら 0.48。後の表)
- **R2 の下端を GND でなく G につなぐ**のが、この AGC の要。G が 0.255 V から −0.27 V まで動くと、V<sub>B</sub> は 1.07 V から 0.66 V まで下がる
  (dV<sub>B</sub> / dG ≈ R1 / (R1 + R2) = 0.82)
- **検波**: C<sub>C</sub> (10 nF) は出力の交流だけを通す。D1 は C<sub>C</sub> の右 (A) の山を約 0.5 V にそろえ、D2 は谷の電位より 1 つぶん上 (D2 の順方向電圧) を G に溜める。
  G ≈ 2V<sub>F</sub> − 2V<sub>pk</sub> (V<sub>pk</sub> は出力の波高値、V<sub>F</sub> は順方向電圧) で、G が待機の 0.255 V を下回る V<sub>pk</sub> ≈ 0.3 V (0.6 Vpp) から AGC が効き始める
- **出力**: C<sub>OUT</sub> (100 nF) で直流を除く。AD3 の CH1 の入力 (約 1 MΩ) と合わせて 1.6 Hz の高域通過で、100 kHz は素通し

## 実体配線図

```breadboard
title: 図2 AGC 付きの 1 段増幅を組む (W1 と CH2 を 5 列、CH1 を 29 列へ)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, 2+, 2-, 1+, 1-]
  R1: resistor b3 b9 68k
  CIN: capacitor/ceramic d5 d9 100n
  R2: resistor c9 c13 15k
  RC: resistor b15 b20 2.2k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815
  RE1: resistor b21 b25 100
  RE2: resistor a25 -t25 390
  CE: capacitor/electrolytic c25(+) c28(-) 10uF
  D2: diode h13(A) h17(K) 1N4148
  CC: capacitor/ceramic i17 i20 10n
  D1: diode j17(A) j14(K) 1N4148
  COUT: capacitor/ceramic g20 g24 100n
  RB: resistor i9 i13 4.7k
  CG: capacitor/electrolytic g13(+) g8(-) 10uF
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t30 -- -b30 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue
  - AD.2- -- -t7 black
  - AD.1+ -- g29 orange
  - f24 -- f29 green
  - AD.1- -- -t18 black
  - +t3 -- a3 red
  - +t15 -- a15 red
  - e9 -- d19 orange [v10]
  - e13 -- f13 green
  - d20 -- f20 green
  - a28 -- -t28 black
  - j8 -- -b8 black
  - j9 -- -b9 black
  - i14 -- -b14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/25-agc.svg)

- **増幅段 (上のブロック)**: 9-11 の図 4 と同じ並び。5V は AD の V+ (赤) から上の + レールへ。**Q1 は `e19` (B)・`e20` (C)・`e21` (E)**
  (2SC1815 は平らな面を手前に、左から E・C・B。穴に挿す向きに注意)
- **ベース (9 列)**: R1 の下端・R2 の左・C<sub>IN</sub> の右が同じ列。橙の線 1 本で Q1 の B (19 列) へ。**R2 の右 (13 列) が G** で、
  緑の線で下のブロックの 13 列へ渡す
- **AGC (下のブロック)**: 13 列が G (D2 のアノード・R<sub>B</sub>・C<sub>G</sub> の + 側)、17 列が A (D2 のカソード・C<sub>C</sub>・D1 のアノード)。
  コレクタは緑の線で 20 列へ渡し、C<sub>OUT</sub> (20 列 → 24 列) と C<sub>C</sub> (17 列 → 20 列) をつなぐ。C<sub>G</sub> と D1 のカソード・R<sub>B</sub> は、
  下のレール (−) へ黒い線で落とす。**D1 と D2 は向き (帯がカソード) を合わせる**
- **CH1 は 29 列** (緑の線で 24 列から渡す)。出力を見るときはここ。**G を見るときは、橙の線を `a13` へ移す** (図 5)
- 上下のレールの − は、30 列の黒い線でつなぐ。AD の GND・2−・1− も −
- 周波数が 100 kHz なので、線は短くなくてもよい。9-11 と同じく、**10 µF の電解コンデンサは + の向き**に気を付ける

## 計器の設定

AD3 だけを使う。100 kHz の信号がオシロ (10 MHz 以下) で波形として見え、W1 の AM 変調で階段状の入力も作れるため。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V |
| Wavegen (W1) | 図 3・図 4: Sine 100 kHz・Offset 0 V、Amplitude 5 mV (図 3)・100 mV (図 4)。図 5: Modulation。Carrier Sine 100 kHz・55 mV、AM は **Square 2 Hz・Index 82 %** (振幅が 10 mV と 100 mV を 250 ms ずつ行き来する)。音の深さ: AM Sine 1 kHz・Index 50 %・Carrier 100 kHz |
| Scope | 図 3・図 4: CH2 = 入力 (W1)、CH1 = 出力 (29 列)。DC 結合、時間 20 µs/div、トリガは CH2 の立ち上がり。図 5: CH1 = G (13 列)、DC 結合、時間 100 ms/div、レンジ 100 mV/div、トリガは CH1 の立ち下がり 0.2 V |
| 弱い入力のとき | Average を 16 回ほど。5 mV の入力でも出力は 160 mVpp あり、雑音には埋もれない |

W1 の Amplitude は波高値 (片側)。図 3・4 の CH2 は 2 つの図で同じ 20 µs/div にそろえた (入力と出力の位相が逆なのも見える)。

## 計器の画面

CH2 (入力) は W1 の式、CH1 (出力) は計算した振幅の正弦波 (位相は反転)。図 5 は G の電圧を、階段状の入力に対する 2 つの時定数
(下がる 21 ms・戻る 41 ms) の指数で描いた。

```scope
title: 図3 弱い入力 (5 mV) — AGC は動かず、約 32 倍で出る
time: 20us/div
trigger: ch2 rising
ch2: {wave: sine 100kHz 5mV, range: 2mV/div, position: 1.45div}
ch1: {wave: sine 100kHz 80.8mV phase 180deg, range: 50mV/div, position: -2.35div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/25-agc-1.svg)

```scope
title: 図4 強い入力 (100 mV) — 出力は 1.13 Vpp で止まる (AGC なしは 3 Vpp 超)
time: 20us/div
trigger: ch2 rising
ch2: {wave: sine 100kHz 100mV, range: 50mV/div, position: 2div}
ch1: {wave: sine 100kHz 565mV phase 180deg, range: 500mV/div, position: -2.3div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/25-agc-2.svg)

```scope
title: 図5 G の電圧 — 入力が 10 倍になると 21 ms で下がり、戻りは 41 ms
time: 100ms/div
trigger: ch1 falling 0.2V
ch1: {wave: "= -0.054V + 0.308V * step(t + 254ms) * (1 - exp(-(t + 254ms) / 41ms)) - 0.308V * step(t + 4ms) * (1 - exp(-(t + 4ms) / 21ms)) + 0.308V * step(t - 246ms) * (1 - exp(-(t - 246ms) / 41ms))", range: 100mV/div, position: -1div}
cursors: [17ms, 287ms]
measure: [vmax, vmin, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/25-agc-3.svg)

## 見るべき値

計算値。入力は W1 の正弦 (波高値)、出力は C<sub>OUT</sub> の右で見る Vpp。

| 入力 (波高値) | AGC あり | AGC なし | 待機に対する G (AGC あり) |
| --- | --- | --- | --- |
| 1 mV | 0.032 Vpp | 0.033 Vpp | 0.255 V |
| 5 mV (図 3) | 0.16 Vpp | 0.16 Vpp | 0.255 V |
| 10 mV | 0.32 Vpp | 0.33 Vpp | 0.254 V |
| 20 mV | 0.57 Vpp | 0.65 Vpp | 0.240 V |
| 50 mV | 0.89 Vpp | 1.61 Vpp | 0.113 V |
| 100 mV (図 4) | 1.13 Vpp | 3.09 Vpp | −0.054 V |
| 200 mV | 1.30 Vpp | 4.33 Vpp | −0.181 V |
| 300 mV | 1.43 Vpp | 4.39 Vpp | −0.270 V |

```graph
title: 図6 入力と出力 — AGC を掛けると 50 dB の入力が 33 dB に縮む
x: 入力の波高値 mV log 1..300
y: 出力 Vpp 0..5
lines:
  AGC あり Vpp:
    - 1 0.0324
    - 2 0.0648
    - 5 0.1616
    - 10 0.3191
    - 20 0.5673
    - 50 0.8858
    - 100 1.130
    - 200 1.3047
    - 300 1.4265
  AGC なし Vpp:
    - 1 0.0325
    - 2 0.0651
    - 5 0.1627
    - 10 0.3252
    - 20 0.6496
    - 50 1.6083
    - 100 3.086
    - 200 4.3306
    - 300 4.3923
notes:
  - mark 20
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/graph/25-agc.svg)

- **AGC は 20 mV あたりから効き始める** (図 6 の破線)。ここまでは 2 本の線が重なり、20 mV で AGC あり 0.57 Vpp・なし 0.65 Vpp と離れ始める。
  出力の波高値が約 0.3 V (0.6 Vpp) を超える所が、2 つのダイオードが導通を始める所に当たる
- **効き方は 50 倍の入力を 33 倍に縮める程度**: 入力 1 mV → 300 mV (49.5 dB) で、AGC ありの出力は 0.0324 → 1.43 Vpp (32.9 dB)、
  AGC なしは 4.39 Vpp で頭打ち。AGC の効きが完全ではない (出力が少しずつ増える) のは、G を動かすには出力が増えるしかない、という**比例制御**の性質。
  ラジオでは、AGC の前に増幅段を何段も置いて、効きを深くする
- **時定数**: 入力が 10 mV から 100 mV へ 10 倍になると、G は 0.254 V から −0.054 V へ。63 % (0.060 V) に達するのは約 **21 ms**。
  100 mV から 10 mV へ戻すと、63 % (0.140 V) に達するのは約 **41 ms**。階段の直後、出力は 1.1 Vpp 前後から約 1.0 Vpp までいったん下がり、1.13 Vpp へ戻る (AGC なしなら 3 Vpp を超える)。戻した直後は出力が 0.29 Vpp まで落ち、利得が戻るまでの数十 ms は弱くなる (その後 0.32 Vpp)
- **音の深さ**: AM (搬送波 100 kHz・音 1 kHz・変調度 50 %) を入れ、出力の変調度 (最大と最小から読んだ値) を比べた。弱い入力は変わらず、**強い入力では
  AGC が音の深さを削る**:

  | 入力の搬送波 | 5 mV | 10 mV | 20 mV | 50 mV |
  | --- | --- | --- | --- | --- |
  | AGC あり | 0.50 | 0.48 | 0.37 | 0.17 |
  | AGC なし | 0.50 | 0.50 | 0.50 | 0.49 |

  G の時定数 (約 41 ms) は音の周期 (1 ms) よりずっと長く、AGC が音の形を追っているのではない。それでも削れるのは、搬送波が大きいとベースの整流で平均電流が
  ずれる効果が重なるためと思われるが、**この原因は切り分けていない**。実機で確かめるときは、20 mV 以下の入力で音の深さが保たれることを見る

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 68 kΩ |
| R2 | 抵抗 (1/4 W) | 15 kΩ |
| R<sub>B</sub> | 抵抗 (1/4 W) | 4.7 kΩ |
| R<sub>C</sub> | 抵抗 (1/4 W) | 2.2 kΩ |
| R<sub>E1</sub> | 抵抗 (1/4 W) | 100 Ω |
| R<sub>E2</sub> | 抵抗 (1/4 W) | 390 Ω |
| C<sub>IN</sub>・C<sub>OUT</sub> | セラミックコンデンサ | 100 nF |
| C<sub>C</sub> | セラミックコンデンサ | 10 nF |
| C<sub>E</sub>・C<sub>G</sub> | 電解コンデンサ | 10 µF |
| D1・D2 | スイッチングダイオード | 1N4148 |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 信号源・オシロ・電源 | Analog Discovery 3 (W1、CH1・CH2、V+ 5 V) |

## 出典

自作。AGC の考え方と遅延 AGC は、受信機の教科書的な内容による
(例: [Automatic gain control — Wikipedia](https://en.wikipedia.org/wiki/Automatic_gain_control))。
