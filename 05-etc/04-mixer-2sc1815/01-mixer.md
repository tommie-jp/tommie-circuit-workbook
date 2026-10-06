---
book: etc
chapter: 4
id: 4-1
title: 1 石ミキサー — 2SC1815 で中波を 455 kHz の IF に変える
tier: 200
source: 自作
board: BB
---

# 4-1 1 石ミキサー — 2SC1815 で中波を 455 kHz の IF に変える

中波 (0.53〜1.6 MHz) の信号 (RF) に局部発振 (LO) を混ぜ、**455 kHz の中間周波 (IF)** に変える回路。
3-1 の 3SK291 を、手持ちの定番トランジスタ **2SC1815 1 本**に替えた。RF をベースに、LO をエミッタに入れ、
コレクタに出る差の周波数をセラミックフィルタで選ぶ。
RF・LO・IF の 3 つのポートは 3-1 と同じ **50 Ω**、電源は **5 V** の単電源で、3-1・4-2 と同じ表で比べられる (比べた結果は [4-3](03-compare.md))。

> [!WARNING]
> 特性は**シミュレーションだけ**で、**実機では測っていない**。2SC1815 の SPICE モデルは見つからなかったので、
> hFE 約 250・fT 約 80 MHz・Cob 約 2 pF という一般に知られた目安から作った**代用のモデル**を使った (4-3 の「解析の方法」)。
> 値は初期値として、組んだら測って合わせる (「調整」の節)。

## 仕様

| 項目 | 値 |
| --- | --- |
| RF | 0.53〜1.6 MHz (中波)。50 Ω |
| LO | RF + 455 kHz (0.985〜2.055 MHz)。50 Ω。**0 dBm (0.32 V 波高値) を標準**にする。**正弦波** |
| IF | 455 kHz。50 Ω |
| 電源 | 5 V (単電源)。電流は 約 0.8 mA (信号なし) |
| トランジスタ | 2SC1815 (NPN。hFE のランク GR か Y)。TO-92 の 3 ピン |

## なぜ 1 本で混ざるのか

トランジスタのコレクタ電流は、ベース・エミッタ間の電圧 v に対して指数で増える。
i<sub>C</sub> = I<sub>S</sub> exp(v / V<sub>T</sub>) (V<sub>T</sub> は約 26 mV)。
v に RF (v<sub>rf</sub>) と LO (v<sub>lo</sub>) が重なると、指数を展開した 2 乗の項に**積** v<sub>rf</sub> · v<sub>lo</sub> / V<sub>T</sub><sup>2</sup> が出る。
積は和 (f<sub>RF</sub> + f<sub>LO</sub>) と差 (f<sub>LO</sub> − f<sub>RF</sub>) の周波数を作るので、差の 455 kHz だけをコレクタの同調とフィルタで取り出す。
LO を大きくすると、トランジスタが LO に合わせて流れたり止まったりするスイッチのように働き、利得は LO の大きさでほぼ決まらなくなる
(4-3 の図 1。LO −5 dBm 以上で変換利得の伸びが鈍る)。

3SK291 は 2 つのゲートで RF と LO を**別の入口**から入れた。1 本のトランジスタは、**RF と LO が同じ接合に入る**。
そのぶん、LO が RF の入口へ、RF が LO の入口へ漏れやすい。コレクタにも RF と LO がそのまま出る (「見るべき値」)。

## 回路図

```circuit
title: 図01 2SC1815 の 1 石ミキサー (+5 V・50 Ω 入出力・IF 455 kHz)
parts:
  VDD:  vcc b10 5V
  C6:   capacitor c6 e6 100n
  C7:   ecap c8 e8 10u
  RB1:  resistor c10 e10 82k
  L1:   inductor c12 e12 220u
  C3:   capacitor c14 e14 560p
  RF:   port h2
  R1:   resistor h4 j4 51
  C1:   capacitor h5 h7 10n
  RB2:  resistor h10 j10 22k
  Q1:   npn h12
  LO:   port l2
  R3:   resistor l4 n4 51
  C2:   capacitor l5 l7 10n
  RE:   resistor l12 n12 470
  C4:   capacitor e16 e18 10n
  R7:   resistor e20 g20 2k
  FL1:  ceramic-filter e23 455kHz
  C5:   capacitor e27 g27 1.2n
  L2:   inductor e27 e30 100u
  IF:   port e32
  G1:   ground e6
  G2:   ground e8
  G3:   ground j4
  G4:   ground j10
  G5:   ground n4
  G6:   ground n12
  G7:   ground g20
  G8:   ground g23
  G9:   ground g27
wires:
  - b10 -- c10
  - c6 -- c8 -- c10 -- c12 -- c14
  - e10 -- h10
  - h2 -- h5
  - h4 -- h5
  - h7 -- h10
  - h10 -- Q1.B
  - l2 -- l5
  - l4 -- l5
  - l7 -- l12
  - Q1.E -- l12
  - Q1.C -- e12
  - e12 -- e14 -- e16
  - e18 -- e20 -- FL1.IN
  - FL1.GND -- g23
  - FL1.OUT -- e27
  - e30 -- e32
notes:
  - text f2 small left: "RF IN 50Ω"
  - text j2 small left: "LO IN 50Ω"
  - text f32 small left: "IF OUT 50Ω"
  - text g2 small blue left: "-30 dBm (10 mVp)"
  - text k2 small blue left: "0 dBm (0.32 Vp)"
  - text g32 small blue left: "RF -30 dBm で -20.7 dBm (29 mVp)"
  - text b14a5 small left: "L1・C3 は約 454 kHz に同調"
  - text j13 small blue left: "B 1.00 V・E 0.37 V・IC 0.79 mA"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/circuit/01-mixer.svg)

左から RF と LO を入れ、中央の Q1 で混ぜ、右のセラミックフィルタ (FL1) で 455 kHz を選んで IF OUT へ出す。
RF は C1 でベースへ、LO は C2 でエミッタへ入る。ベースは RB1・RB2 の分圧で約 1.0 V、エミッタは RE の電圧降下で約 0.37 V に置く。
フィルタ以降 (C4・R7・FL1・C5・L2) は 3-1 と同じ。青い数字は解析で求めた動作点と信号の大きさ。

### 3 つの工夫

- **ベースは 1.0 V 前後に置く。** 2SC1815 は VBE が約 0.65 V なので、エミッタが 0.37 V なら IC = 0.37 V ÷ 470 Ω ≒ 0.79 mA。
  82 kΩ と 22 kΩ の分圧は 5 V × 22 ÷ 104 ≒ 1.06 V で、ベース電流 (約 3 µA) の降下で 1.0 V になる。RE は LO の電流を逃がしすぎない 470 Ω にした
- **LO はエミッタに入れる。** エミッタは約 33 Ω (1/g<sub>m</sub> = 26 mV ÷ 0.79 mA) と低く、50 Ω の信号源がそのまま電流を流し込める。
  ベースに RF と LO を並べて入れるより、**2 つの入口が分かれて漏れが減る**。RE にパスコンは付けない (付けると LO がエミッタに乗らない)
- **コレクタは 220 µH と 560 pF の並列に給電する。** 3-1 と同じ約 454 kHz の同調で、RF と LO に低いインピーダンスを見せる。
  フィルタの入力には 2 kΩ (R7) を並列にして、フィルタの源のインピーダンスを決める

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| Q1 | 2SC1815 (GR か Y) | NPN。TO-92。ピンは平らな面を手前にして左から E・C・B。図 2 の Q1 には B・C・E の名前が出るので、それを見て挿す |
| R1 | 51 Ω | RF IN の 50 Ω 終端 (ポートに並列) |
| R3 | 51 Ω | LO IN の 50 Ω 終端 (ポートに並列) |
| RB1 | 82 kΩ | ベースの分圧 (上) |
| RB2 | 22 kΩ | ベースの分圧 (下) |
| RE | 470 Ω | エミッタの抵抗。IC を決める |
| R7 | 2 kΩ | セラミックフィルタ入力の終端 |
| R8 | 51 Ω | **計測用**。IF OUT の 50 Ω の負荷 (回路図の外。ブレッドボードの図にだけ付ける) |
| C1, C2 | 10 nF | RF と LO の DC カット (セラミック) |
| C3 | 560 pF | L1 と並列で約 454 kHz に同調 (C0G / NP0) |
| C4 | 10 nF | IF をフィルタへ (DC カット) |
| C5 | 1.2 nF | 出力整合 (シャント。C0G / NP0) |
| C6 | 100 nF | 電源のデカップリング (セラミック) |
| C7 | 10 µF 16 V | 電源のデカップリング (電解。+ を電源側に) |
| L1 | 220 µH | コレクタの DC 給電と IF の同調 (直流抵抗の小さいもの) |
| L2 | 100 µH | 出力整合 (直列) |
| FL1 | SFU455B (455 kHz セラミックフィルタ) | **入出力 1.5 kΩ の品** (3-1 と同じ) |
| 電源 | 5 V | 既定の電源 |

出力整合は 3-1 と同じ L 型 (C5 と L2)。フィルタの出力 (1.5 kΩ) を 50 Ω に合わせる。

## 実体配線図

周波数は最大 2.055 MHz で、ブレッドボードの上限 (3 MHz) に収まる。電流は 1 mA 足らず。
基板は `full` (63 列)。AD3 を下に置いて、電源・W1 (RF)・W2 (LO)・1+ (IF OUT)・2+ (LO の入口) をつなぐ。
Q1 は上半分 (a〜e 行) の c12〜c14 に挿し、**B・C・E の 3 本を短い線 (青・茶・紫) で下半分へ渡す**。
下半分は 5 穴 × 1 列に 1 つずつ使えるので、ベース (10 列)・エミッタ (15 列)・コレクタ (27 列) の 3 つの節に部品をまとめられる。

```breadboard
title: 図02 ブレッドボードに組む (AD3 の W1・W2・CH1・CH2 つき)
board: full
parts:
  Q1: transistor c12(B) c13(C) c14(E) 2SC1815
  R1: resistor i3 i6 51
  C1: capacitor/ceramic g3 g10 10n
  RB1: resistor h10 h8 82k
  RB2: resistor i10 i12 22k
  RE: resistor g15 g18 470
  C2: capacitor/ceramic h15 h21 10n
  R3: resistor i21 i24 51
  L1: inductor g27 g31 220u
  C3: capacitor/ceramic i27 i29 560p
  C4: capacitor/ceramic h27 h35 10n
  R7: resistor g35 g38 2k
  FL1: sip3 @ f35 SFU455B
  C5: capacitor/ceramic i37 i39 1.2n
  L2: inductor h37 h44 100u
  R8: resistor g44 g48 51
  C6: capacitor/ceramic g55 g58 100n
  C7: capacitor/electrolytic i55 i58 10u
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, W1, 1-, 2-, W2, 2+, 1+]
wires:
  - AD.V+ -- +b2 red
  - AD.GND -- -b4 black
  - +b8 -- j8 red
  - +b29 -- j29 red
  - +b31 -- j31 red
  - +b55 -- j55 red
  - -b6 -- j6 black
  - -b12 -- j12 black
  - -b18 -- j18 black
  - -b24 -- j24 black
  - -b36 -- j36 black
  - -b38 -- j38 black
  - -b39 -- j39 black
  - -b48 -- j48 black
  - -b58 -- j58 black
  - e12 -- f10 blue
  - e13 -- f27 brown
  - e14 -- f15 purple
  - AD.W1 -- j3 yellow
  - AD.W2 -- j21 green
  - AD.2+ -- j22 green
  - g21 -- g22 green
  - AD.1+ -- j44 orange
  - AD.1- -- -b26 black
  - AD.2- -- -b28 black
style:
  text-size: 10
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/breadboard/01-mixer.svg)

- 電源: AD3 の V+ (Supplies で 5 V) を赤で +b2 へ、GND を黒で -b4 へ。ベース分圧 (RB1) は 8 列、コレクタの L1・C3 は 29・31 列、デカップリング (C6・C7) は 55 列の +b に赤で落とす
- GND は下の青いレール (-b) に、6・12・18・24・36・38・39・48・58 列から黒で落とす
- Q1: B (c12) → 青で f10 (ベース)、C (c13) → 茶で f27 (コレクタ)、E (c14) → 紫で f15 (エミッタ)
- RF (黄): W1 を j3 へ。R1 (51 Ω) は 3 列から 6 列の GND へ。C1 は f 行の 3 列から 10 列のベースへ
- LO (緑): W2 を j21 へ、2+ を j22 へ (g21〜g22 の緑の線で 2 つの列をつなぐ)。R3 (51 Ω) は 21 列から 24 列の GND へ。C2 は h 行の 15 列 (エミッタ) から 21 列へ
- IF (橙): 1+ を j44 へ。1− と 2− (黒) は -b26 と -b28 へ
- R8 (51 Ω) は IF OUT の 50 Ω の負荷 (AD3 の入力は 1 MΩ)。回路図の外の、計器の側の部品
- FL1 は f35 (IN)・f36 (GND)・f37 (OUT) に挿す。丸い胴に `SFU` と刷ってある橙の部品

部品の穴は次のとおり。

| 部品 | 穴 | 部品 | 穴 |
| --- | --- | --- | --- |
| Q1 | c12 (B) c13 (C) c14 (E) | R7 2k | g35 / g38 |
| R1 51 | i3 / i6 | FL1 | f35 (IN) f36 (GND) f37 (OUT) |
| C1 10n | g3 / g10 | C5 1.2n | i37 / i39 |
| RB1 82k | h8 / h10 | L2 100u | h37 / h44 |
| RB2 22k | i10 / i12 | R8 51 | g44 / g48 |
| RE 470 | g15 / g18 | C6 100n | g55 / g58 |
| C2 10n | h15 / h21 | C7 10u | i55 (+) / i58 (−) |
| R3 51 | i21 / i24 | L1 220u | g27 / g31 |
| C3 560p | i27 / i29 | C4 10n | h27 / h35 |

## 計器の設定 (Analog Discovery 3)

計器は **Analog Discovery 3 (AD3)** にする。IF は 455 kHz、LO は最大 2.055 MHz で、どれも 10 MHz 以下なので、
電源・信号源・オシロ・スペクトラムを 1 台でまかなえる。
配線は実体配線図のとおり。AD3 の入力は 1 MΩ なので、**IF OUT には計器の側の 50 Ω の負荷 R8 (51 Ω) を付ける**。
R8 が無いと IF OUT の電圧が約 2 倍 (+6 dB) に出て、表の値と合わない。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない)。電源を入れてから Wavegen を出す |
| Wavegen W1 (RF) | Sine、1.000 MHz、振幅 32 mV (−20 dBm)、オフセット 0 V。**最初はこの大きさ**。合ったら振幅 10 mV (−30 dBm) にする |
| Wavegen W2 (LO) | Sine、1.455 MHz、振幅 0.32 V (0 dBm)、オフセット 0 V |
| Scope CH1 | 1+ = IF OUT (R8 の上)、1− = GND。50 mV/div、時間は 1 µs/div |
| Scope CH2 | 2+ = LO の入口 (C2 の前)、2− = GND。LO の振幅が 0.32 V かを見る。100 mV/div |
| Spectrum | チャンネルは CH1。開始 0 Hz・終了 2.5 MHz、FFT 8192 点、窓は Flat Top、縦軸 dBV |

- W1 の振幅は、51 Ω の終端 R1 に 0 Ω の信号源が直接かかるので、そのまま RF のポートの電圧になる (LO の W2 と R3 も同じ)。
  W2 は 0.32 V でも 51 Ω に約 6 mA で、Wavegen の上限 (30 mA) に収まる
- RF を最初に 32 mV にするのは、10 mV (−30 dBm) だと Wavegen の分解能に近く、信号源の雑音が見えるため。
  4-3 の図 3 のとおり、−20 dBm までは利得が一定なので、32 mV でも変換利得は同じに読める
- 標本化は 2.5 MHz × 2.56 = 6.4 MHz、分解能は 6.4 MHz ÷ 8192 ≈ 0.78 kHz。IF (455 kHz) と RF・LO は十分に分かれる
- Spectrum の縦軸 dBV は、50 Ω の dBm から 13.0 dB を引いた値 (dBV = dBm − 13.01)。IF の −20.7 dBm は **−33.7 dBV**
- W1 と W2 は別々に周波数を決める。LO は RF + 455 kHz に**自分で合わせる** (RF を変えたら LO も変える)

## 想定する電圧

### 直流 (解析の動作点)

| 場所 | 電圧 | 備考 |
| --- | --- | --- |
| VDD | 5.00 V | |
| コレクタ | 5.0 V | L1 の直流抵抗 (モデルで 5 Ω) による降下は 4 mV |
| ベース | 1.00 V | 82 kΩ と 22 kΩ の分圧 |
| エミッタ | 0.37 V | |
| IC | 0.79 mA | 電力 約 3.9 mW (絶対最大 400 mW) |
| 電源の電流 | 0.84 mA | 信号なし。ベースの分圧に 0.05 mA を含む。LO が入ると平均の IC が増える |

RF IN・LO IN・IF OUT は**どれも直流 0 V** (C1・C2・C4 とフィルタで切ってある)。外から直流を加えない。

### 交流 (ポートの両端)

| ポート | 条件 | 電力 | 実効値 | 波高値 | ピーク間 |
| --- | --- | --- | --- | --- | --- |
| RF IN | 標準 (解析条件) | −30 dBm | 7.1 mV | 10 mV | 20 mV |
| RF IN | 計器の最初の設定 | −20 dBm | 22 mV | 32 mV | 63 mV |
| RF IN | 利得が 1 dB 落ちる (モデル) | 約 −14 dBm | 約 45 mV | 約 63 mV | 約 0.13 V |
| LO IN | 標準 | 0 dBm | 0.22 V | 0.32 V | 0.63 V |
| LO IN | 下限の目安 (変換利得が 2 dB 落ちる) | −10 dBm | 71 mV | 0.10 V | 0.20 V |
| IF OUT | RF −30 dBm のとき | −20.7 dBm | 21 mV | 29 mV | 59 mV |
| IF OUT | RF −20 dBm のとき | −10.9 dBm | 64 mV | 91 mV | 0.18 V |

LO のポートの電圧はベース・エミッタ間にそのままかかるのではなく、**C2 を通って約 33 Ω のエミッタに入る**。
51 Ω の R3 に W2 の電圧がかかり、同時に C2 経由でエミッタに電流が流れる。

## 調整

1. RF と LO を入れずに、**IC が約 0.8 mA** (エミッタの電圧が約 0.37 V) になるかを見る。足りなければ RB2 を大きく (24 kΩ にすると IC が増える)。ベースの電圧は電源の線に入れた電流計か、RE の両端の電圧で見る
2. LO を 0 dBm、RF を −20 dBm (LO は RF + 455 kHz) で入れ、IF OUT の 455 kHz を見る。
   LO を −10〜+7 dBm で動かして、利得が LO の大きさでほぼ決まらないことを確かめる
3. RF を 1.000 MHz から 0.6 MHz・1.6 MHz に動かし (LO は RF + 455 kHz に追従)、利得が揃うことを見る。0.53 MHz の側で利得が約 2 dB 落ちる (4-3 の図 2)

## 計器の画面

計算値。IF OUT は 4-3 の解析 (RF −30 dBm・LO 0 dBm で IF OUT が **−20.7 dBm = 29 mV<sub>p</sub> = −33.7 dBV**) による。
LO と RF の漏れは、コレクタの値 (4-3) にフィルタの阻止域の深さの**仮定** (30 dB) と L2 での減衰を掛けた**目安**で、実物では変わる (下の表)。

```spectrum
title: 図03 IF OUT のスペクトル (RF 1.000 MHz −30 dBm、LO 1.455 MHz 0 dBm)
device: ad3
sweep: 0-2.5MHz
samples: 8192
window: flattop
unit: dBV
ref: -30dBV
signal:
  - sine 455kHz 29mV
  - sine 1.455MHz 0.88mV
  - sine 1MHz 0.19mV
markers: [455k, 1.455M, 1M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/spectrum/01-mixer.svg)

- 455 kHz の山が一番高く、−33.7 dBV で立つ。RF −30 dBm から見て **+9.3 dB の変換利得**
- 山のほかに見えるのは LO (1.455 MHz) と RF (1.000 MHz) の漏れ。**どちらも IF より十分低い**が、
  高さはセラミックフィルタの阻止域で決まる (下の表)。図の値は仮定の目安
- 影像側 (1.910 MHz) と和 (2.455 MHz) の成分は、フィルタと L2 で落ちて見えない

```scope
title: 図04 IF OUT の波形 (RF −20 dBm のとき、455 kHz の正弦波)
time: 1us/div
trigger: ch1 rising 0V
ch1: sine 455kHz 91mV
cursors: [0, 2.2us]
measure: [freq, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/scope/01-mixer.svg)

- RF を 32 mV (−20 dBm) にしたときの波形。IF OUT は 91 mV<sub>p</sub> (0.18 V<sub>pp</sub>) の 455 kHz の正弦波
- 1 周期は 2.2 µs。1 µs/div なら 10 目盛で 4.5 周期が見える。RF と LO の周波数の差で決まるので、
  LO を 1 kHz 動かすと 455 kHz も 1 kHz 動く
- RF −30 dBm では振幅が 29 mV<sub>p</sub> しかなく、Wavegen と入力の雑音で波形が荒れる。形を見るなら −20 dBm にする

### 漏れの目安の出し方

| 成分 | 見積もり | IF OUT での値 |
| --- | --- | --- |
| LO 1.455 MHz | コレクタの LO 0.50 V<sub>p</sub> (4-3) → フィルタの阻止域 30 dB (**仮定**) → L2 (914 Ω) と 50 Ω で 25 dB 下がる | 0.88 mV<sub>p</sub> (約 −65 dBV) |
| RF 1.000 MHz | コレクタの RF 77 mV<sub>p</sub> (4-3) → 阻止域 30 dB (**仮定**) → L2 (628 Ω) と 50 Ω で 22 dB 下がる | 0.19 mV<sub>p</sub> (約 −77 dBV) |

実物のセラミックフィルタの阻止域は未確認なので、**30 dB は仮定**。実際に測った漏れが大きければ、阻止域がもっと浅い。

## 見るべき値

IF OUT の 455 kHz は、RF −30 dBm・LO 0 dBm のとき **約 −20.7 dBm (波高値 29 mV、−33.7 dBV)**。
変換利得は +9 dB 前後で、**組んだ実機では大きく外れうる** (モデルは代用)。
上の図 03・04 のとおりに Analog Discovery 3 で測る。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 | 455 kHz (RF 1.000 MHz・LO 1.455 MHz のとき。LO − RF) |
| IF の大きさ (RF −30 dBm) | −33.7 dBV (29 mV<sub>p</sub>)。変換利得 +9.3 dB |
| IF の大きさ (RF −20 dBm) | −23.9 dBV (91 mV<sub>p</sub>)。利得は +9.1 dB でほぼ同じ |
| RF の振幅を半分に | IF も 6 dB 下がる (傾き 1。−20 dBm までは利得が一定) |
| RF を −10 dBm にする | 利得が +7.1 dB に落ちる (圧縮が始まる)。傾きが 1 より小さくなる |
| LO を −10 dBm (0.10 V<sub>p</sub>) | 利得 +7.3 dB (RF −30 dBm なら IF は約 −35.6 dBV) |
| LO を +7 dBm (0.71 V<sub>p</sub>) | 利得 +10.6 dB (0 dBm より 1.3 dB 上がるだけ) |
| LO を止める | IF が消える (混ぜる相手が無い) |
| RF だけ動かして LO を固定 | IF が 455 kHz から離れ、フィルタの帯域 (約 12 kHz) の外で急に落ちる |
| コレクタ (L1 の下) を見る | LO と RF が IF より高く出る (LO が +8.9 dB、RF が +7.3 dB)。IF OUT ではフィルタが落とす |
| LO と RF の漏れ | IF OUT では IF より十分低い。高さはフィルタ次第 (図 03 の値は目安) |

## 注意

- 中波の RF 入力に**前置の同調回路が無い**。影像 (LO + 455 kHz) も同じ利得で出るので、
  実際に使うときは RF の前にバリコンなどの同調回路を置く
- ミキサーの出力にはセラミックフィルタ 1 つ。RF・LO・和周波を落とす深さは、フィルタの型番で決まる
- 1 本のトランジスタは RF と LO が同じ接合に入るので、**LO を大きくしすぎても利得は伸びず、漏れだけが増える**。0 dBm から始める
- 2SC1815 は耐圧が高く壊れにくいが、ベースへ直流を加えない。外から RF・LO の入口へ直流を加えると、C1・C2 が切るので入口は守られる

## 出典

- 2SC1815 の電気的特性 (hFE・fT・Cob) は一般に知られた目安。データシートの本文は直接読んでいない
- [CFX455G (村田)](https://pdf.jiepei.com/cfx455g-28251406.html) — 入出力 1500 Ω の記載 (3-1 と同じフィルタ)
- 回路は 3-1 の 3SK291 を 2SC1815 に替えて描き起こした。9-10 の自励式コンバータとは違い、LO を外から入れる**他励式**
