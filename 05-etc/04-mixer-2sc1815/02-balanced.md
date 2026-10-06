---
book: etc
chapter: 4
id: 4-2
title: 差動対のミキサー — 2SC1815 を 3 本でシングルバランスに組む
tier: 200
source: 自作
board: BB
---

# 4-2 差動対のミキサー — 2SC1815 を 3 本でシングルバランスに組む

4-1 の 1 石ミキサーは、コレクタに RF と LO が IF と一緒にそのまま出た。
この題は 2SC1815 を **3 本**使い、**LO で差動対を切り替え、RF を下の電流源に入れる**。
2 本のコレクタの**差**を取ると、**RF が打ち消されて消える** (LO は残る)。
掛け算で和と差だけを作る [9-12](../../01-circuits/09-rf/12-balanced-mixer.md) の「バランスド」を、トランジスタ 3 本で目に見える形にする。
ギルバートセル (SA612 などの中身) の半分にあたる。

> [!WARNING]
> 特性は**シミュレーションだけ**で、**実機では測っていない**。2SC1815 のモデルは 4-1 と同じ代用のモデル。
> 打ち消しの深さは、モデルの 2 本が全く同じなので**実物より深く出る**。実物は hFE のばらつきで浅くなる (「注意」)。

## 仕様

| 項目 | 値 |
| --- | --- |
| RF | 0.53〜1.6 MHz (中波)。50 Ω。**電流源 (Q3) のベース**に入れる |
| LO | RF + 455 kHz (0.985〜2.055 MHz)。50 Ω。**0 dBm (0.32 V 波高値) が標準**。**Q1 のベース**に入れる。正弦波 |
| 出力 | OUT A と OUT B の**差**の 455 kHz。**フィルタも 50 Ω の出力も付けない** (3.3 kΩ ずつ) |
| 電源 | 5 V (単電源)。電流は 約 1.3 mA (信号なし) |
| トランジスタ | 2SC1815 × 3 (Q1・Q2 は差動対、Q3 は電流源) |

## なぜ差を取ると RF が消えるのか

Q1・Q2 のエミッタは Q3 のコレクタにつながる。Q3 は RF に比例した電流 I<sub>T</sub> = I<sub>0</sub> + i<sub>rf</sub> を流す電流源として働く。
Q1・Q2 は LO の電圧で I<sub>T</sub> を左右に振り分け、**差の電流は** I<sub>T</sub> · tanh(v<sub>lo</sub> / 2V<sub>T</sub>) になる。
LO が大きいと tanh は ±1 の方形波に近づく (**LO で電流を切り替える**)。

- **i<sub>rf</sub> の項**: i<sub>rf</sub> × (±1 の方形波)。RF の符号が LO の周期で反転するので、**和と差の周波数** (f<sub>LO</sub> ± f<sub>RF</sub>) だけが出る。**RF そのものは出ない**。4-1 の 1 本では RF が出た
- **I<sub>0</sub> の項**: I<sub>0</sub> × (±1 の方形波)。**LO の奇数次の高調波がそのまま出る**。差を取っても LO は消えない

つまりシングルバランスは、**RF か LO のどちらか一方だけ**を消す。この回路は RF が消える側。両方を消すには、差動対を 2 組使う**ダブルバランス** (ギルバートセル。トランジスタ 6 本) にする。

## 回路図

```circuit
title: 図01 2SC1815 差動対のミキサー (+5 V・LO で切り替え・出力は OUT A と OUT B の差)
parts:
  VDD:  vcc b13 5V
  C6:   capacitor c4 e4 100n
  C7:   ecap c6 e6 10u
  RL1:  resistor d10 f10 10k
  RL2:  resistor h10 j10 10k
  LO:   port h2
  R3:   resistor h4 j4 51
  C2:   capacitor h5 h7 10n
  Q1:   npn h13
  RC1:  resistor c13 e13 3.3k
  OUTA: port e15
  Q2:   npn h19 mirror
  RC2:  resistor c19 e19 3.3k
  OUTB: port e17
  RR1:  resistor d22 f22 10k
  RR2:  resistor h22 j22 10k
  C9:   capacitor h24 j24 100n
  Q3:   npn p16
  VDD:  vcc l10 5V
  RB1:  resistor m10 o10 82k
  RB2:  resistor p10 r10 22k
  RF:   port p2
  R1:   resistor p4 r4 51
  C1:   capacitor p5 p7 10n
  RE:   resistor r16 t16 470
  G1:   ground e4
  G2:   ground e6
  G3:   ground j10
  G4:   ground j4
  G5:   ground j22
  G6:   ground j24
  G7:   ground r10
  G8:   ground r4
  G9:   ground t16
wires:
  - c4 -- c6 -- c10 -- c13 -- c19 -- c22
  - b13 -- c13
  - c10 -- d10
  - c22 -- d22
  - f10 -- h10
  - h2 -- h4 -- h5
  - h7 -- h10 -- Q1.B
  - Q1.C -- e13
  - e13 -- e15
  - Q2.C -- e19
  - e19 -- e17
  - f22 -- h22 -- h24
  - Q2.B -- h22
  - Q1.E -- k13
  - Q2.E -- k19
  - k13 -- k16 -- k19
  - k16 -- Q3.C
  - l10 -- m10
  - o10 -- p10
  - p2 -- p4 -- p5
  - p7 -- p10 -- Q3.B
  - Q3.E -- r16
notes:
  - text f2 small left: "LO IN 50Ω"
  - text g2 small blue left: "0 dBm (0.32 Vp)"
  - text n2 small left: "RF IN 50Ω"
  - text o2 small blue left: "-30 dBm (10 mVp)"
  - text f15a5 small blue left: "DC 3.71 V (A・B とも)"
  - text g10a5 small blue left: "B 2.49 V"
  - text l17 small blue left: "尾 (Q1・Q2 のエミッタ) 1.88 V"
  - text p18 small blue left: "B 1.00 V・E 0.37 V"
  - text q18 small blue left: "IC 0.79 mA (Q1・Q2 は 0.40 mA ずつ)"
  - text e24 small left: "Scope の 1+ を OUT A へ"
  - text f24 small left: "Scope の 1- を OUT B へ"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/circuit/02-balanced.svg)

左下の RF は C1 で Q3 のベースへ。Q3 (RE が 470 Ω) は約 0.79 mA の電流源になる。
Q3 のコレクタ (尾) に Q1・Q2 のエミッタをつなぐ。Q1 のベースには LO を C2 で入れ、Q2 のベースは C9 で**交流的に GND** に落とす。
どちらのベースも 10 kΩ の 2 本で 2.5 V に置く (左右の分圧は同じ値)。出力は 2 本のコレクタ (3.3 kΩ で VDD へ) の OUT A と OUT B。
青い数字は解析で求めた動作点。

### 3 つの工夫

- **左右の部品の値を揃える。** Q1 と Q2 のベースの分圧 (10 kΩ ずつ) とコレクタの抵抗 (3.3 kΩ) は、**同じ値の 2 本**にする。
  DC が OUT A = OUT B (3.71 V) になり、差を取ったときの打ち消しが深くなる。**LO が入ると DC がずれる**ので、揃っているかは LO を止めて見る
- **Q2 のベースは交流で GND にする。** 片方に LO を入れるだけでも、差動対の差の電流は LO に比例して振り分けられる。トランスで逆相に分けなくてよい
- **出力は 50 Ω にしない。** 差を 50 Ω の 1 本にするには中間タップのトランスか、もう 1 段の差動増幅が要る。
  この題は「差を取ると RF が消える」を見るのが目的なので、AD3 の Scope の**差動入力** (1+ と 1−) で OUT A と OUT B の差を見る

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| Q1, Q2, Q3 | 2SC1815 (GR か Y) | NPN。Q1・Q2 は **hFE ができるだけ近い 2 本** (同じ袋から選ぶ) |
| R1 | 51 Ω | RF IN の 50 Ω 終端 (ポートに並列) |
| R3 | 51 Ω | LO IN の 50 Ω 終端 (ポートに並列) |
| RB1 | 82 kΩ | Q3 のベースの分圧 (上) |
| RB2 | 22 kΩ | Q3 のベースの分圧 (下) |
| RE | 470 Ω | Q3 のエミッタ。電流を決める |
| RL1, RL2 | 10 kΩ | Q1 のベースの分圧 (上・下)。2.5 V |
| RR1, RR2 | 10 kΩ | Q2 のベースの分圧 (上・下)。2.5 V |
| RC1, RC2 | 3.3 kΩ | Q1・Q2 のコレクタ負荷 (**同じ値**) |
| C1, C2 | 10 nF | RF と LO の DC カット (セラミック) |
| C9 | 100 nF | Q2 のベースを交流で GND に落とす (セラミック) |
| C6 | 100 nF | 電源のデカップリング (セラミック) |
| C7 | 10 µF 16 V | 電源のデカップリング (電解。+ を電源側に) |
| 電源 | 5 V | 既定の電源 |

## 実体配線図

周波数は最大 2.055 MHz で、ブレッドボードの上限 (3 MHz) に収まる。電流は 1.3 mA ほど。
基板は `full` (63 列)。AD3 を下に置いて、電源・W1 (RF)・W2 (LO)・CH1 (OUT A − OUT B)・CH2 (OUT A) をつなぐ。
トランジスタ 3 本は上半分 (a〜e 行) に挿し、**短い線で下半分へ渡す** (4-1 と同じ流儀)。
Q2 だけ E・C・B の順 (平らな面を手前にした実物の並び) に挿し、Q1 と左右対称にした。**2 つのエミッタ (13 列と 15 列) と Q3 のコレクタ (30 列) は、上半分の紫の線でつなぐ** (e13〜e15、a15〜a30)。

```breadboard
title: 図02 ブレッドボードに組む (AD3 の W1・W2・CH1・CH2 つき)
board: full
parts:
  Q1: transistor c11(B) c12(C) c13(E) 2SC1815
  Q2: transistor c15(E) c16(C) c17(B) 2SC1815
  Q3: transistor c29(B) c30(C) c31(E) 2SC1815
  R3: resistor g3 g6 51
  C2: capacitor/ceramic i3 i11 10n
  RL1: resistor g11 g8 10k
  RL2: resistor h11 h6 10k
  RC1: resistor g12 g14 3.3k
  RC2: resistor h16 h14 3.3k
  RR1: resistor g17 g20 10k
  RR2: resistor h17 h23 10k
  C9: capacitor/ceramic i17 i23 100n
  RB1: resistor g29 g26 82k
  RB2: resistor h29 h24 22k
  C1: capacitor/ceramic i29 i35 10n
  RE: resistor g31 g34 470
  R1: resistor g35 g38 51
  C6: capacitor/ceramic g45 g48 100n
  C7: capacitor/electrolytic i45 i48 10u
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, W2, GND, 2+, 1+, 1-, 2-, W1]
wires:
  - AD.V+ -- +b2 red
  - AD.GND -- -b4 black
  - +b8 -- j8 red
  - +b14 -- j14 red
  - +b20 -- j20 red
  - +b26 -- j26 red
  - +b45 -- j45 red
  - -b6 -- j6 black
  - -b23 -- j23 black
  - -b24 -- j24 black
  - -b34 -- j34 black
  - -b38 -- j38 black
  - -b48 -- j48 black
  - e13 -- e15 purple
  - a15 -- a30 purple
  - e11 -- f11 blue
  - e12 -- f12 brown
  - e16 -- f16 brown
  - e17 -- f17 blue
  - e29 -- f29 blue
  - e31 -- f31 gray
  - AD.W2 -- j3 green
  - AD.W1 -- j35 yellow
  - AD.1+ -- j12 orange
  - AD.1- -- j16 orange
  - AD.2+ -- h12 orange
  - AD.2- -- -b30 black
style:
  text-size: 10
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/breadboard/02-balanced.svg)

- 電源: AD3 の V+ (Supplies で 5 V) を赤で +b2 へ、GND を黒で -b4 へ。+b は 8・14・20・26・45 列から赤で、-b は 6・23・24・34・38・48 列から黒で落とす
- Q1: B (c11)・C (c12) を青と茶の線で f11・f12 へ。E (c13) は e13 の紫の線で Q2 の E (c15) へ。Q2: C (c16)・B (c17) を茶と青の線で f16・f17 へ
- Q3: B (c29) を青の線で f29 へ、E (c31) を灰色の線で f31 へ。C (c30) は a30 から紫の線で a15 (尾) へ
- RF (黄): W1 を j35 へ。R1 (51 Ω) は 35 列から 38 列の GND へ。C1 は i 行の 35 列から 29 列 (Q3 のベース) へ
- LO (緑): W2 を j3 へ。R3 (51 Ω) は 3 列から 6 列の GND へ。C2 は i 行の 3 列から 11 列 (Q1 のベース) へ
- 出力 (橙): CH1 の 1+ を j12 (OUT A) へ、1− を j16 (OUT B) へ。CH2 の 2+ は h12 (OUT A) へ。2− (黒) は -b30 へ
- 配線図の抵抗の値は部品表と下の表で読む (図の字は重なりやすい)

部品の穴は次のとおり。

| 部品 | 穴 | 部品 | 穴 |
| --- | --- | --- | --- |
| Q1 | c11 (B) c12 (C) c13 (E) | RR2 10k | h17 / h23 |
| Q2 | c15 (E) c16 (C) c17 (B) | C9 100n | i17 / i23 |
| Q3 | c29 (B) c30 (C) c31 (E) | RB1 82k | g26 / g29 |
| R3 51 | g3 / g6 | RB2 22k | h24 / h29 |
| C2 10n | i3 / i11 | C1 10n | i29 / i35 |
| RL1 10k | g8 / g11 | RE 470 | g31 / g34 |
| RL2 10k | h6 / h11 | R1 51 | g35 / g38 |
| RC1 3.3k | g12 / g14 | C6 100n | g45 / g48 |
| RC2 3.3k | h14 / h16 | C7 10u | i45 (+) / i48 (−) |
| RR1 10k | g17 / g20 | | |

## 計器の設定 (Analog Discovery 3)

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない)。電源を入れてから Wavegen を出す |
| Wavegen W1 (RF) | Sine、1.000 MHz、振幅 32 mV (−20 dBm)、オフセット 0 V。合ったら 10 mV (−30 dBm) にする |
| Wavegen W2 (LO) | Sine、1.455 MHz、振幅 0.32 V (0 dBm)、オフセット 0 V |
| Scope CH1 | 1+ = OUT A、1− = OUT B。**差動で読む**。入力レンジは大きいほう (LO が 3.3 V<sub>p</sub> で出る) |
| Scope CH2 | 2+ = OUT A、2− = GND。**片側だけ**を読む |
| Spectrum | 開始 0 Hz・終了 3 MHz、FFT 8192 点、窓は Flat Top、縦軸 dBV。CH1 (差) と CH2 (片側) を並べる |

- **2 つの画面を見比べるのが目的**。CH1 の差では RF (1.000 MHz) が低く、CH2 の片側では RF が高く立つ
- 標本化は 3 MHz × 2.56 = 7.7 MHz、分解能は 7.7 MHz ÷ 8192 ≈ 0.94 kHz。IF (455 kHz)・RF・LO・和 (2.455 MHz) は十分に分かれる
- Spectrum の縦軸 dBV は実効値。波高値 3.25 V の LO は +7.2 dBV (実効値 2.30 V)
- W1 と W2 は別々に周波数を決める。LO は RF + 455 kHz に**自分で合わせる**
- 時間波形 (`scope`) の図は付けない。LO が 3 V を超えて振れるので、IF (数十〜百 mV) が時間波形ではほとんど見えない。IF の波形は 4-1 の図 04

## 想定する電圧

### 直流 (解析の動作点)

| 場所 | 電圧 | 備考 |
| --- | --- | --- |
| VDD | 5.00 V | |
| Q3 のベース / エミッタ | 1.00 V / 0.37 V | IC = 0.79 mA |
| 尾 (Q1・Q2 のエミッタ) | 1.88 V | |
| Q1・Q2 のベース | 2.49 V | 10 kΩ ずつの分圧 |
| OUT A・OUT B | 3.71 V | 0.40 mA × 3.3 kΩ = 1.3 V の降下。**左右で同じ** |
| 電源の電流 | 1.33 mA | 信号なし。分圧の 0.5 mA を含む |

**LO が入ると OUT A と OUT B の DC がずれる** (LO 0 dBm で 3.79 V と 3.62 V)。Q1 のベースだけが LO で振れるため。

### 交流 (RF −20 dBm・LO 0 dBm のとき)

| 場所 | OUT A (片側) | OUT A − OUT B (差) |
| --- | --- | --- |
| IF 455 kHz | 60 mV<sub>p</sub> | 124 mV<sub>p</sub> |
| 和 2.455 MHz | 60 mV<sub>p</sub> | 124 mV<sub>p</sub> |
| LO 1.455 MHz | 1.62 V<sub>p</sub> | 3.25 V<sub>p</sub> |
| RF 1.000 MHz | 96 mV<sub>p</sub> | 7.7 mV<sub>p</sub> |

**フィルタが無いので和 (2.455 MHz) が IF と同じ高さで出る。** 差は片側のちょうど 2 倍 (6 dB 高い)。

## 調整

1. RF と LO を入れずに、OUT A と OUT B の DC が**同じ** (約 3.71 V) かを見る。ずれていれば、左右の分圧と RC1・RC2 の値を確かめる。Q3 の IC は RB2 で合わせる (0.79 mA の目安。足りなければ RB2 を 24 kΩ に)
2. W2 (LO) だけを 0 dBm で入れ、Spectrum で 1.455 MHz の LO が差でも片側でも**高く出る**ことを見る (差のほうが 6 dB 高い)
3. W1 (RF) を足して、CH1 (差) の RF (1.000 MHz) が CH2 (片側) より**下がる**ことを見る。IF (455 kHz) と和 (2.455 MHz) は差のほうが 6 dB 高い
4. LO を 0 dBm から +7 dBm に上げて、差の RF が**消えなくなる** (打ち消しが浅くなる) ことを確かめる (「見るべき値」)

## 計器の画面

計算値。4-3 の解析 (RF 1.000 MHz −20 dBm・LO 1.455 MHz 0 dBm) による。

```spectrum
title: 図03 OUT A − OUT B (差) のスペクトル (RF −20 dBm、LO 0 dBm)
device: ad3
sweep: 0-3MHz
samples: 8192
window: flattop
unit: dBV
ref: 10dBV
signal:
  - sine 1.455MHz 3.25V
  - sine 455kHz 124mV
  - sine 2.455MHz 124mV
  - sine 2.91MHz 64mV
  - sine 1MHz 7.7mV
markers: [455k, 1M, 1.455M, 2.455M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/spectrum/02-balanced-1.svg)

- **差**: LO (1.455 MHz) が +7.2 dBV で一番高い。IF (455 kHz) と和 (2.455 MHz) は −21.1 dBV で同じ高さ。**RF (1.000 MHz) は −45.3 dBV** で、片側のときより 22 dB 低い
- 2.910 MHz は LO の 2 次高調波 (2 × 1.455 MHz)。差でも出るのは、スイッチが完全な対称ではないため

```spectrum
title: 図04 OUT A (片側) のスペクトル (同じ条件)
device: ad3
sweep: 0-3MHz
samples: 8192
window: flattop
unit: dBV
ref: 10dBV
signal:
  - sine 1.455MHz 1.62V
  - sine 1MHz 96mV
  - sine 455kHz 60mV
  - sine 2.455MHz 60mV
  - sine 2.91MHz 49mV
markers: [455k, 1M, 1.455M, 2.455M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/spectrum/02-balanced-2.svg)

- **片側**: LO が +1.2 dBV、RF が −23.3 dBV、IF と和が −27.5 dBV。差の図 03 と見比べる。**IF は片側が 6 dB 低く、RF は 22 dB 高い**

## 見るべき値

RF −30 dBm・LO 0 dBm のとき、差の IF は 40 mV<sub>p</sub> (**変換利得 +12.1 dB**。RF の振幅 10 mV に対する電圧の比)。
図 03・04 のとおりに AD3 で測る。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 | 455 kHz (LO − RF) |
| IF の大きさ (差、RF −30 dBm) | 40 mV<sub>p</sub> (−31.0 dBV)。利得 +12.1 dB |
| IF の大きさ (差、RF −20 dBm) | 124 mV<sub>p</sub> (−21.1 dBV)。利得 +11.9 dB |
| IF の大きさ (片側) | 差の半分 (6 dB 低い) |
| 和 2.455 MHz | IF と同じ高さ (フィルタが無い) |
| RF の漏れ (差、RF −30 dBm) | 片側より **34 dB** 低い (RF −20 dBm では 22 dB)。RF が大きいほど打ち消しが浅くなる |
| LO の漏れ (差) | **消えない**。3.25 V<sub>p</sub> (+7.2 dBV) で IF より 38 dB 高い |
| LO を −10 dBm | 利得 +11.0 dB。RF は片側より 40 dB 低い (差) |
| LO を +4 dBm | 利得 +10.8 dB。**RF の打ち消しが 8.5 dB に浅くなる** (差) |
| LO を +7 dBm | 利得 +9.6 dB。**RF の打ち消しがほぼ 0 dB** |
| RF の振幅を半分に | IF も 6 dB 下がる (−20 dBm までは利得が一定) |
| RF を 0 dBm | 利得が +9.0 dB に落ちる (圧縮) |
| LO を止める | IF と和が消える (混ぜる相手が無い) |

## 注意

- 打ち消しの深さ (34 dB など) は、**Q1 と Q2 が全く同じ**モデルで解析した値で、実物より深い。実物は hFE・ベース抵抗のばらつきで、20〜30 dB 止まりが普通。Q1・Q2 は同じ袋から選ぶ
- **LO を大きくしすぎると RF が消えなくなる** (上の表)。LO が +4 dBm を超えると、Q1 のベースだけが大きく振れて差動対のつり合いが崩れるためと考えられる (解析で現象は確かめたが、原因の切り分けはしていない)。0 dBm から始める
- **LO は消えない。** RF だけが消える側のシングルバランス。LO が 3 V 以上で出るので、IF の後ろにフィルタを置かないと、後段が LO で飽和する
- フィルタを付けていないので、IF の 455 kHz のほかに和 (2.455 MHz) が同じ高さで出る。4-1 のように IF フィルタを付ければ落とせる

## 出典

- [9-12 バランスドミキサー](../../01-circuits/09-rf/12-balanced-mixer.md) — 掛け算・スイッチ・ダブルバランスの説明 (この題はシングルバランス)
- 2SC1815 の電気的特性は 4-1 と同じ目安 (データシートの本文は直接読んでいない)
- 回路は 4-1 の 2SC1815 の 1 石ミキサーと、一般に知られた差動対ミキサー (ギルバートセルの半分) を組み合わせて描き起こした
