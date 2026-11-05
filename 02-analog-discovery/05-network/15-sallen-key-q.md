---
book: analog-discovery
chapter: 5
id: 5-15
title: サレンキー LPF の Q
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-15 サレンキー LPF の Q

2 次のローパスは、遮断の付近の形を **Q** という 1 つの数で表す。Q が 0.5 なら RC を 2 段重ねたようになだらかに落ち、
0.71 (バターワース) なら平らなまま −3 dB で曲がり、1 を超えると f<sub>0</sub> の手前に山が立つ。
回路の教科書の 4-10 では、2 つのコンデンサの比で Q を決めた (利得 1 倍)。この題では R と C をすべて同じ値にし、
オペアンプの利得 K で Q を決める**等しい部品の形**を組む。理論は Q = 1/(3 − K) で、K を 1 → 2.5 と上げると Q は 0.5 → 2 に上がる。

Network で Q を読む手順は 1 つにまとまる。**位相が −90° になる周波数が f<sub>0</sub>**、そこでの利得を低い周波数の利得 K で割った値が Q だ。
2 次のローパスでは |H(f<sub>0</sub>)| = K · Q がちょうど成り立つ。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 サレンキー LPF (等しい R と C。利得 K は Rf と Rg で決める)
parts:
  V1: sine 1,3 1,5 l=$\mathrm{W1}$
  M1: voltmeter 3,3 3,5 l=$\mathrm{CH1}$
  G1: ground 1,5
  G2: ground 3,5
  R1: resistor 3,3 6,3 10k l=$\mathrm{R_1}$
  R2: resistor 6,3 9,3 10k l=$\mathrm{R_2}$
  C2: capacitor 9,3 9,5 10n l=$\mathrm{C_2}$
  G3: ground 9,5
  C1: capacitor 6,3 6,1 10n l=$\mathrm{C_1}$
  U1: opamp 12,3.25 +up
  Rf: resistor 14,3.25 14,6 10k l=$\mathrm{R_f}$
  Rg: resistor 14,6 14,8 10k l=$\mathrm{R_g}$
  G4: ground 14,8
  M2: voltmeter 16,3.25 16,5.25 l=$\mathrm{CH2}$
  G5: ground 16,5.25
wires:
  - 1,3 -- 3,3
  - 9,3 -| U1.+
  - 6,1 -- 15,1 -- 15,3.25
  - U1.out -- 14,3.25 -- 16,3.25
  - 14,6 -- 10,6
  - 10,6 |- U1.-
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/15-sallen-key-q.svg)

- R<sub>1</sub> = R<sub>2</sub> = 10 kΩ、C<sub>1</sub> = C<sub>2</sub> = 10 nF。f<sub>0</sub> = 1/(2πRC) = **1.59 kHz** で、K を変えても f<sub>0</sub> は動かない
- 利得 K = 1 + R<sub>f</sub>/R<sub>g</sub>。R<sub>g</sub> = 10 kΩ のまま、R<sub>f</sub> を 0 Ω (ジャンパ)・5.6 kΩ・10 kΩ・15 kΩ と差し替える (図は 10 kΩ)
- C<sub>1</sub> は出力から前段の節点へ戻す正帰還。K が大きいほど f<sub>0</sub> の付近で戻りが強くなり、Q が上がる。
  **K = 3 (R<sub>f</sub> = 20 kΩ) で Q は無限大になり、発振する。** R<sub>f</sub> に 20 kΩ 以上は挿さない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (Rf 10 kΩ)
board: half
parts:
  U1: dip8 @ f15 LM358
  R1: resistor i25 i21 10k
  R2: resistor h21 h17 10k
  C1: capacitor g15 g21 10n cap=right
  C2: capacitor j17 -b17 10n cap=left
  Rf: resistor h16 h15 10k cap=left
  Rg: resistor i16 i12 10k cap=below:-1,0
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [2+, V-, V+, W1, 1+, GND, 1-, 2-]
wires:
  - -b1 -- -t1 black
  - +t15 -- a15 red
  - a16 -- a17 green
  - a18 -- -t18 black
  - AD.2+ -- j15 blue
  - j12 -- -b12 black
  - AD.V- -- j18 purple
  - AD.V+ -- +b20 red
  - +b10 -- +t10 red
  - AD.W1 -- j25 yellow
  - AD.1+ -- h25 orange
  - AD.GND -- -b27 black
  - AD.1- -- -b28 black
  - AD.2- -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/15-sallen-key-q.svg)

- U1 (LM358) は 15〜18 列。1 番 OUT1 (15 列)・2 番 IN1− (16 列)・3 番 IN1+ (17 列)・4 番 V− (18 列)。
  使わない 2 回路目は 5-6 と同じくフォロアにして (6 番と 7 番を短絡、5 番を GND)、入力を固定する
- LM358 の + 入力 (17 列) は右側にあるので、信号は**右から左へ**流す: 25 列 (W1・CH1) → R<sub>1</sub> → 21 列 (前段の節点) →
  R<sub>2</sub> → 17 列 (+ 入力)。こうすると R<sub>2</sub> が出力 (15 列) と − 入力 (16 列) の上を跨がない。
  C<sub>2</sub> は 17 列から下の − レールへ、C<sub>1</sub> は 21 列から 15 列 (出力) へ g 行で戻す
- R<sub>f</sub> は 15 列 (出力) と 16 列 (− 入力) の間、R<sub>g</sub> は 16 列から 12 列へ渡し、12 列の黒線で下の − レールへ落とす。R<sub>f</sub> を替えるときは `h15`・`h16` に挿し直す。
  R<sub>f</sub> = 0 Ω はジャンパ線にする
- CH2 (2+) は 15 列 (`j15`)。V− は AD3 の V− から 4 番 (18 列) へ直に、V+ は 10 列の赤線で上の + レールへ渡して 8 番 (`a15`) に入れる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Amplitude 0.2 V、Offset 0 V |
| Network | Start 100 Hz、Stop 10 kHz、Log、Steps 201、Reference: Channel 1。位相の表示も出す |
| カーソル | 位相が −90° の点にカーソルを置き、その周波数 (f<sub>0</sub>) と利得を読む |

W1 を 0.2 V にしたのは、K = 2.5 の山 (5.19 倍) でも出力が 1.04 V<sub>p</sub> に収まり、LM358 の出力の範囲 (+5 V から 1.5 V ほど下まで) から遠いため。

K = 2.5 のとき f<sub>0</sub> の時間波形が図3 (計算値)。出力は入力の 5 倍 (K · Q = 2.5 × 2) で、ちょうど 90° 遅れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 K 2.5・1.59 kHz — 出力 (CH2) は入力の 5 倍で 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.5915kHz 0.2V, range: 100mV/div}
ch2: {wave: sine 1.5915kHz 1V phase -90deg, range: 500mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/15-sallen-key-q.svg)

CH1 は 100 mV/div、CH2 は 500 mV/div と尺度を 5 倍変えてある。波の高さは同じに見えるが、CH2 は CH1 の 5 倍。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入り。1 回路目を使う) | LM358 |
| R<sub>1</sub>, R<sub>2</sub> | 抵抗 (1/4 W) | 各 10 kΩ |
| C<sub>1</sub>, C<sub>2</sub> | フィルムコンデンサ (103)。セラミックなら C0G | 各 10 nF |
| R<sub>g</sub> | 抵抗 (1/4 W) | 10 kΩ |
| R<sub>f</sub> | 抵抗 (1/4 W、差し替える) | 0 Ω (ジャンパ線)・5.6 kΩ・10 kΩ・15 kΩ |
| — | 電源 | ±5 V (AD3 の Supplies)。入力 0 V の付近で動かすため両電源 |
| — | 計器 | AD3 の W1・Scope 1+ (入力)・2+ (出力) |

## 見るべき値

計算値 (理想のオペアンプ)。f<sub>0</sub> = 1.59 kHz、Q = 1/(3 − K)。

| R<sub>f</sub> | K (低い周波数の利得) | Q | f<sub>0</sub> (−90°) での利得 | 山 |
| --- | --- | --- | --- | --- |
| 0 Ω | 1 (0 dB) | 0.50 | 0.50 倍 (−6.02 dB) | なし |
| 5.6 kΩ | 1.56 (3.86 dB) | 0.69 | 1.08 倍 (0.70 dB) | なし (ほぼバターワース) |
| 10 kΩ | 2 (6.02 dB) | 1.00 | 2.00 倍 (6.02 dB) | 1.13 kHz で 2.31 倍 (7.27 dB) |
| 15 kΩ | 2.5 (7.96 dB) | 2.00 | 5.00 倍 (14.0 dB) | 1.49 kHz で 5.16 倍 (14.3 dB) |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 K を 1 から 2.5 へ上げると Q が 0.5 から 2 へ上がり、f0 の手前に山が立つ
x: 周波数 Hz log 100..10k
y: 利得 dB -30..16
lines:
  K 1 (Q 0.50) dB: 20*log10(1/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k/0.5)^2))
  K 1.56 (Q 0.69) dB: 20*log10(1.56/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k*1.44)^2))
  K 2 (Q 1.0) dB: 20*log10(2/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k)^2))
  K 2.5 (Q 2.0) dB: 20*log10(2.5/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k/2)^2))
notes:
  - mark 1.5915k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/15-sallen-key-q.svg)

分かること:

- **f<sub>0</sub> (1.59 kHz) はどの K でも動かない。** 位相が −90° になる所がいつも同じなので、f<sub>0</sub> は位相で読むのが確か
- **Q は f<sub>0</sub> での利得 ÷ 低い周波数の利得。** K = 2.5 なら 14.0 dB − 7.96 dB = 6.0 dB (2 倍) で Q = 2。dB なら引き算で済む
- **Q が高いほど部品のずれに敏感になる。** Q = 1/(3 − K) なので、K = 2.5 で R<sub>f</sub> が 5 % ずれると K は 2.43〜2.58、
  Q は 1.74〜2.35 と ±15 % ほど動く。山の高さが計算と合わなくても、まず R<sub>f</sub> と R<sub>g</sub> の実測値で K を計算し直す
- 等しい部品の形は f<sub>0</sub> と Q を別々に決められる (f<sub>0</sub> は R と C、Q は K)。代わりに、低い周波数の利得も K になる。
  利得 1 倍がほしいなら回路の教科書の 4-10 の形 (C の比で Q を決める) にする

## LTspice での確かめ

`sim/15-sallen-key-q.cir` で図1 を AC 解析し、R<sub>f</sub> を 0.001 Ω・5.6 kΩ・10 kΩ・15 kΩ に振った。
オペアンプは 5-6 と同じ 1 次の模型 (DC 利得 100 dB、GBW 1 MHz。LM358 の代表値からの仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 低い周波数の利得 (10 Hz) | 1・1.56・2・2.5 | 1.000・1.560・2.000・2.500 | 合う |
| −90° の周波数 (f<sub>0</sub>) | 1.59 kHz | 1588・1586・1584・1582 Hz | 合う (GBW の分 0.2〜0.6 % 低い) |
| f<sub>0</sub> での利得 ÷ K (= Q) | 0.50・0.69・1.00・2.00 | 0.500・0.694・1.000・1.999 | 合う |
| K = 2 の山 | 2.31 倍 | 2.314 倍 | 合う |
| K = 2.5 の山と周波数 | 5.16 倍・1.49 kHz | 5.187 倍・1.48 kHz | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
参考: [Sallen–Key topology (Wikipedia)](https://en.wikipedia.org/wiki/Sallen%E2%80%93Key_topology)
