---
book: analog-discovery
chapter: 5
id: 5-16
title: 状態変数フィルタ
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-16 状態変数フィルタ

5-15 のサレンキーは 1 個のオペアンプで 2 次のローパスを作るが、f<sub>0</sub> と Q が R・C・K の組み合わせで決まり、
出口はローパスの 1 つだけだった。**状態変数フィルタ** (KHN 型) は、加算 1 個と積分 2 個のオペアンプで 2 次の微分方程式を
そのまま回路にしたもので、**ハイパス (HP)・バンドパス (BP)・ローパス (LP) の 3 つを同時に**出す。
f<sub>0</sub> は積分の R と C だけ、Q は R<sub>3</sub> と R<sub>4</sub> の分圧だけで決まり、互いに干渉しない。

Network の CH2 を HP・BP・LP の 3 か所へ順に挿し替えて 3 回掃引し、同じ f<sub>0</sub> (1.59 kHz) を中心に
3 つの形が並ぶことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 状態変数フィルタ (加算 1 個と積分 2 個。HP・BP・LP を同時に出す)
parts:
  V1: sine 1,3 1,5 l=$\mathrm{W1}$
  M1: voltmeter 3,3 3,5 l=$\mathrm{CH1}$
  G1: ground 1,5
  G2: ground 3,5
  R1: resistor 3,3 6,3 10k l=$\mathrm{R_1}$
  U1: opamp 8,5 +down
  R5: resistor 6,3 10,3 10k l=$\mathrm{R_5}$
  R2: resistor 9,1 13,1 10k l=$\mathrm{R_2}$
  R3: resistor 7,8 11,8 15k l=$\mathrm{R_3}$
  R4: resistor 7,8 7,10 1k l=$\mathrm{R_4}$
  G3: ground 7,10
  R6: resistor 10,5 13,5 10k l=$\mathrm{R_6}$
  U2: opamp 15,5 +down
  C1: capacitor 13,3 17,3 10n l=$\mathrm{C_1}$
  G4: ground 14,7
  R7: resistor 17,5 19,5 10k l=$\mathrm{R_7}$
  U3: opamp 21,5 +down
  C2: capacitor 19,3 23,3 10n l=$\mathrm{C_2}$
  G5: ground 20,7
  HP: port 10,6.5 out
  BP: port 18,6.5 out
  LP: port 25,5 out
wires:
  - 1,3 -- 3,3
  - 6,3 |- U1.-
  - U1.out -- 10,5
  - 10,5 -- 10,3
  - 6,3 -- 6,1 -- 9,1
  - 13,1 -- 23,1 -- 23,3
  - U1.+ -| 7,8
  - 11,8 -- 17,8 -- 17,5
  - 10,5 -- 10,6.5
  - 13,5 |- U2.-
  - 13,5 -- 13,3
  - U2.+ -| 14,7
  - U2.out -- 17,5
  - 17,5 -- 17,3
  - 17,6.5 -- 18,6.5
  - 19,5 |- U3.-
  - 19,5 -- 19,3
  - U3.+ -| 20,7
  - U3.out -- 23,5
  - 23,5 -- 23,3
  - 23,5 -- 25,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/16-state-variable-filter.svg)

- U1 は加算。HP = −(V<sub>in</sub> + LP) + 3 × (R<sub>4</sub>/(R<sub>3</sub> + R<sub>4</sub>)) × BP (R<sub>1</sub> = R<sub>2</sub> = R<sub>5</sub> = 10 kΩ のとき)
- U2・U3 は反転の積分 (R = 10 kΩ、C = 10 nF)。BP = −HP/(sRC)、LP = −BP/(sRC)。**f<sub>0</sub> = 1/(2πRC) = 1.59 kHz**
- 3 つを合わせると、LP/V<sub>in</sub> = −1/(s'² + s'/Q + 1) (s' = sRC) と 2 次のローパスになり、**Q = (R<sub>3</sub> + R<sub>4</sub>)/(3R<sub>4</sub>)**。
  R<sub>3</sub> = 15 kΩ・R<sub>4</sub> = 1 kΩ で Q = 5.33、R<sub>3</sub> を 2 kΩ に替えると Q = 1.00
- BP の分圧は U1 の + 入力へ入る。− 入力へ入れると符号が逆になり、制動が負になって発振する

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (R3 15 kΩ、CH2 は BP)
board: full
parts:
  UA: dip8 @ f8 r180 LM358
  UB: dip8 @ f20 r180 LM358
  R1: resistor h3 h9 10k
  R5: resistor g9 g10 10k cap=below
  R4: resistor g8 g6 1k cap=left
  R6: resistor h10 h21 10k
  C1: capacitor g21 g22 10n cap=right
  R3: resistor j22 j8 15k
  R7: resistor c25 c22 10k
  C2: capacitor b22 b23 10n cap=right
  R2: resistor a23 a14 10k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [1+, W1, V-, 2+, V+, GND, 1-, 2-]
wires:
  - -b1 -- -t1 black
  - a10 -- a11 green
  - a9 -- -t9 black
  - d8 -- d20 purple
  - i11 -- +b11 red
  - j6 -- -b6 black
  - i20 -- -b20 black
  - j23 -- +b23 red
  - b21 -- -t21 black
  - h22 -- h25 yellow
  - g25 -- d25 yellow
  - b14 -- b4 white
  - c4 -- g4 white
  - i4 -- i9 white
  - AD.1+ -- i3 orange
  - AD.W1 -- j3 yellow
  - AD.2+ -- i22 blue
  - AD.V+ -- +b28 red
  - AD.GND -- -b30 black
  - AD.1- -- -b31 black
  - AD.2- -- -b32 black
  - AD.V- -- c20 purple
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/16-state-variable-filter.svg)

- LM358 を 2 個、どちらも**向きを反転 (`r180`) して**挿す。こうすると下のブロックの 1 回路が「+ 入力・− 入力・出力・V+」の順に
  左から並び、信号が左から右へ流れる。UA の下 (8〜11 列) が U1 (加算)、UB の下 (20〜23 列) が U2 (1 段目の積分)、
  UB の上 (20〜23 列) が U3 (2 段目の積分)。UA の上の 1 回路は使わないのでフォロアにして + 入力を GND に落とす
- 下のブロック: 9 列が加算の点 (U1 の − 入力。R<sub>1</sub>・R<sub>5</sub>・R<sub>2</sub> の 3 本が集まる)、10 列が HP、8 列が U1 の + 入力
  (R<sub>3</sub>・R<sub>4</sub>)。21 列が U2 の − 入力、22 列が BP
- 上のブロック: 22 列が U3 の − 入力、23 列が LP。BP は黄の線で 22 列から 25 列へ出し、溝を渡って R<sub>7</sub> で 22 列 (上) に入る
- LP からの帰還は R<sub>2</sub> (a 行) から白の線で左の 4 列へ回り、溝を渡って i 行で 9 列 (加算の点) に入る。
  BP から U1 の + 入力へは R<sub>3</sub> (j 行の長い抵抗) で 8 列へ戻す。R<sub>4</sub> は 8 列から 6 列へ渡し、6 列の黒線で GND へ
- V+ は下の + レールから 11 列 (UA) と 23 列 (UB) へ。V− は AD3 から UB の上の 20 列へ入れ、紫の線 (d 行) で UA の上の 8 列へ配る
- **CH2 を挿す穴**: HP は `i10`、BP は `i22` (図)、LP は `d23`。挿し替えるたびに掃引する

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Amplitude 0.1 V、Offset 0 V (Q = 5.33 の山で 0.53 V<sub>p</sub>) |
| Network | Start 100 Hz、Stop 20 kHz、Log、Steps 201、Reference: Channel 1。CH2 を HP・BP・LP に挿し替えて 3 回 |
| 重ねて見る | 掃引の結果を Reference (参照の線) に残してから次を掃引すると、3 本を同じ画面に重ねられる (目安) |

f<sub>0</sub> での時間波形が図3 (計算値、Q = 5.33)。BP は入力と同じ位相で 5.33 倍になる。同じ周波数で LP は 90° 進み、HP は 90° 遅れる
(どちらも 5.33 倍)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 f0 1.59 kHz・Q 5.33 — BP (CH2) は入力と同相で 5.33 倍
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.5915kHz 0.1V, range: 50mV/div}
ch2: {wave: sine 1.5915kHz 0.533V, range: 200mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/16-state-variable-filter.svg)

CH1 は 50 mV/div、CH2 は 200 mV/div。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| UA, UB | オペアンプ (2 回路入り。3 回路を使い、1 回路はフォロアで止める) | LM358 × 2 |
| R<sub>1</sub>, R<sub>2</sub>, R<sub>5</sub> | 抵抗 (1/4 W、加算) | 各 10 kΩ |
| R<sub>6</sub>, R<sub>7</sub> | 抵抗 (1/4 W、積分) | 各 10 kΩ |
| C<sub>1</sub>, C<sub>2</sub> | フィルムコンデンサ (103、積分) | 各 10 nF |
| R<sub>3</sub> | 抵抗 (1/4 W、Q を決める) | 15 kΩ (Q = 5.33)・2 kΩ (Q = 1.00) を差し替える |
| R<sub>4</sub> | 抵抗 (1/4 W、Q を決める) | 1 kΩ |
| — | 電源 | ±5 V (AD3 の Supplies)。3 つの出口が 0 V を中心に振れるので両電源 |
| — | 計器 | AD3 の W1・Scope 1+ (入力)・2+ (HP・BP・LP に挿し替え) |

## 見るべき値

計算値 (理想のオペアンプ)。x = f/f<sub>0</sub>、D = √((1 − x²)² + (x/Q)²) と置くと
|LP| = 1/D、|BP| = x/D、|HP| = x²/D。

| 出口 | 低い周波数 | f<sub>0</sub> (1.59 kHz) | 高い周波数 | f<sub>0</sub> での位相 (入力に対し) |
| --- | --- | --- | --- | --- |
| LP | 1 倍 (0 dB) | Q 倍 (5.33 倍、14.5 dB) | −40 dB/dec | +90° |
| BP | +20 dB/dec | Q 倍 (5.33 倍、14.5 dB) が山 | −20 dB/dec | 0° |
| HP | +40 dB/dec | Q 倍 (5.33 倍、14.5 dB) | 1 倍 (0 dB) | −90° |
| BP (Q = 1.00) | +20 dB/dec | 1 倍 (0 dB) が山 | −20 dB/dec | 0° |

BP の −3 dB 幅は f<sub>0</sub>/Q = 298 Hz (Q = 5.33) と 1.59 kHz (Q = 1.00)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 Q 5.33 の HP・BP・LP は f0 で同じ高さ (14.5 dB)。Q 1 の BP は山が低く広い
x: 周波数 Hz log 100..20k
y: 利得 dB -40..20
lines:
  LP (Q 5.33) dB: 20*log10(1/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k/5.333)^2))
  BP (Q 5.33) dB: 20*log10((x/1.5915k)/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k/5.333)^2))
  HP (Q 5.33) dB: 20*log10((x/1.5915k)^2/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k/5.333)^2))
  BP (Q 1.00) dB: 20*log10((x/1.5915k)/sqrt((1-(x/1.5915k)^2)^2+(x/1.5915k)^2))
notes:
  - mark 1.5915k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/16-state-variable-filter.svg)

分かること:

- **3 つの出口は f<sub>0</sub> で同じ高さ (Q 倍)** になり、位相だけが 90° ずつずれる。LP と HP は f<sub>0</sub> の上と下で裏返しの形
- **Q を変えても f<sub>0</sub> は動かない。** R<sub>3</sub> を 15 kΩ から 2 kΩ に替えると、BP の山は 14.5 dB から 0 dB に下がり、
  幅は 298 Hz から 1.59 kHz に広がるが、山の位置は 1.59 kHz のまま。5-15 のサレンキーでは Q を上げると低い周波数の利得 K も
  変わったが、ここでは LP の低い周波数の利得は 1 倍のまま
- **BP の山の高さ (Q 倍) から Q を直接読める。** BP は f<sub>0</sub> で位相 0° になるので、Network の位相が 0° を横切る所が f<sub>0</sub>
- 動かないときは 1 段ずつ確かめる: U2・U3 は単独なら積分 (1.59 kHz で利得 1、位相 +90°)。帰還 (R<sub>2</sub>・R<sub>3</sub>) を外すと
  加算と積分を別々に Network で測れる
- f<sub>0</sub> を 10 倍の 15.9 kHz に上げると、オペアンプの有限の GBW で Q が持ち上がり、山が高く出る (Q 強調)。
  LM358 (GBW 約 1 MHz) では f<sub>0</sub> を 10 kHz より下に置くのが目安 (この題の 1.59 kHz でも、下の節のとおり 4 % ほど持ち上がる)

## LTspice での確かめ

`sim/16-state-variable-filter.cir` で図1 を AC 解析し、R<sub>3</sub> を 15 kΩ と 2 kΩ に振った。
オペアンプは 1 次の模型 (DC 利得 100 dB、GBW 1 MHz。LM358 の代表値からの仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| LP の低い周波数の利得 (100 Hz) | 1 倍 | 1.004 倍 (Q 5.33)・1.002 倍 (Q 1.00) | 合う |
| HP の高い周波数の利得 (100 kHz) | 1 倍 | 0.959 倍 (GBW の分だけ低い) | 合う (GBW の効き) |
| f<sub>0</sub> での BP・LP・HP (Q 5.33) | 各 5.33 倍 | 5.564・5.555・5.572 倍 | 合う (GBW で Q が 4 % 持ち上がる) |
| BP の山 (Q 5.33) | 5.33 倍 | 5.566 倍 | 合う (同上) |
| f<sub>0</sub> での BP (Q 1.00) | 1.00 倍 | 1.008 倍 | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
参考: [State variable filter (Wikipedia)](https://en.wikipedia.org/wiki/State_variable_filter)
