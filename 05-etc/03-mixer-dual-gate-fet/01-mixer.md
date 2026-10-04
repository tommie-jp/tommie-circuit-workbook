---
book: etc
chapter: 3
id: 3-1
title: デュアルゲート FET ミキサー — 3SK291 で中波を 455 kHz の IF に変える
tier: 200
source: 自作
board: —
---

# 3-1 デュアルゲート FET ミキサー — 3SK291 で中波を 455 kHz の IF に変える

中波 (0.53〜1.6 MHz) の信号 (RF) に局部発振 (LO) を混ぜ、**455 kHz の中間周波 (IF)** に変える回路。
デュアルゲート FET の 3SK291 の G1 に RF、G2 に LO を入れ、ドレインに出る差の周波数をセラミックフィルタで選ぶ。
RF・LO・IF の 3 つのポートはどれも **50 Ω**、電源は **5 V** の単電源。
特性をシミュレーションで見た結果は [3-2](02-simulation.md)。

> [!WARNING]
> 3SK291 の SPICE モデルが無かったので、特性は**代用のモデル**で解析した。**実機では測っていない**。
> データシートの本文も直接は読めていない (検索結果の要約で読んだ)。
> 値は初期値として、組んだら測って合わせる (「調整」の節)。

## 仕様

| 項目 | 値 |
| --- | --- |
| RF | 0.53〜1.6 MHz (中波)。50 Ω |
| LO | RF + 455 kHz (0.985〜2.055 MHz)。50 Ω。+7 dBm (0.71 V 波高値) を標準にする |
| LO の波形 | **正弦波** (標準)。G2 の直流 1.41 V の上で ±0.71 V (1.42 V<sub>pp</sub>) を振る。方形波は下の「LO の波形」 |
| IF | 455 kHz。50 Ω |
| 電源 | 5 V (単電源) |
| FET | 3SK291 (東芝、デュアルゲート N チャネル MOSFET、**エンハンスメント型**、SMD 4 ピン) |

## LO の波形

標準は**正弦波**。[3-2](02-simulation.md) の解析も正弦波の LO で行った。
Analog Discovery 3 (AD3) の Wavegen W2 を Sine、振幅 0.71 V、オフセット 0 V にする。
C2 が直流を切るので、G2 の直流 (1.41 V) は R4・R5 の分圧のまま変わらない。
Wavegen の出力は 0 Ω で、51 Ω の終端 R3 に 0.71 V を加えると約 14 mA 流れる (Wavegen の上限 30 mA の内)。

LO を方形波にしても、G2 で開け閉めするスイッチとして混合は起きる。それでも標準にしないのは次の理由による。

- **奇数次の高調波が混ざる。** 方形波は 3 次が基本波の 1/3 (−9.5 dB)、5 次が 1/5 …と続く。
  3 次の高調波と混ざる**擬似応答**が、RF = 3 × LO ± 455 kHz の所にできる。LO が 1.455 MHz なら
  3 × LO は 4.365 MHz で、3.910 MHz と 4.820 MHz の信号が 455 kHz に出る (中波の外の短波の局)。
  前置の同調回路が無いので、これを落とせない。正弦波ならこの経路はほぼ無い
- **基本波が大きくなる。** 同じ波高値なら方形波の基本波は正弦波の 4/π 倍 (+2.1 dB)。
  基本波を正弦波の +7 dBm に揃えるなら、方形波の振幅は 0.71 V × π/4 ≒ 0.56 V (G2 は 0.85〜1.97 V を跳ぶ)
- **G2 の上側の跳びに余裕が無い。** 代用モデルでは G2 が約 2.2 V を超えると変換が落ちる (3-2 の図 4)。
  方形波の高い側はこれに近づくので、振幅を決め直す必要がある

> [!WARNING]
> **方形波での解析と実測はしていない。** 上は高調波の計算と 3-2 の図からの見積もりで、
> 変換利得が何 dB になるかは分からない。試すときは 0.56 V から始めて、IF OUT の 455 kHz を見ながら動かす。

## 回路図

```circuit
title: 図01 3SK291 デュアルゲート FET ミキサー (+5 V・50 Ω 入出力・IF 455 kHz)
parts:
  VDD:  vcc a8 5V
  C6:   capacitor b3 d3 100n
  C7:   ecap b6 d6 10u
  R4:   resistor c8 e8 33k
  R5:   resistor f8 h8 13k
  LO:   port f2
  R3:   resistor f4 h4 51
  C2:   capacitor f5 f7 10n
  RF:   port n2
  R1:   resistor n4 p4 51
  C1:   capacitor n5 n7 10n
  VDD:  vcc j8 5V
  R2:   resistor k8 m8 1M
  R6:   resistor n8 p8 150k
  VR1:  resistor-var p8 r8 200k
  U1:   nmos-dg f11 3SK291
  L1:   inductor b13 d13 220u
  C3:   capacitor b15 d15 560p
  C4:   capacitor d16 d18 10n
  R7:   resistor d19 f19 2k
  FL1: ceramic-filter d21 455kHz
  C5:   capacitor d23 f23 1.2n
  L2:   inductor d23 d25 100u
  IF:   port d27
  G1:   ground d3
  G2:   ground d6
  G3:   ground h4
  G4:   ground h8
  G5:   ground p4
  G6:   ground r8
  G7:   ground h11
  G8:   ground e21
  G9:   ground f23
  G10:  ground f19
wires:
  - b3 -- b15
  - a8 -- b8
  - b8 -- c8
  - b6 -- b8
  - e8 -- f8
  - f2 -- f5
  - f7 -- f8 |- U1.G2
  - n2 -- n5
  - n7 -- n8
  - j8 -- k8
  - m8 -- n8
  - n8 -- n10 |- U1.G1
  - U1.D |- d11
  - d11 -- d13
  - d13 -- d15 -- d16
  - d18 -- d19 -- FL1.IN
  - FL1.OUT -- d23
  - d25 -- d27
  - FL1.GND -- e21
  - U1.S |- h11
notes:
  - text i1 small left: "LO IN 50Ω (0.985-2.055 MHz)"
  - text j1 small blue left: "+7 dBm (0.71 Vp / 1.4 Vpp)"
  - text l1 small left: "RF IN 50Ω (0.53-1.6 MHz)"
  - text m1 small blue left: "-30 dBm (10 mVp / 20 mVpp)"
  - text f26 small left: "IF OUT 50Ω (455 kHz)"
  - text g26 small blue left: "RF -30 dBm で -28.6 dBm (11.7 mVp)"
  - text e8a5 small blue left: "G2 1.41 V"
  - text l10a5 small blue left: "G1 1.24 V (VR1 約 180 kΩ)"
  - text a14 small left: "L1・C3 は約 454 kHz に同調"
  - text g22 small left: "FL1 は入出力 1.5 kΩ 品"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/circuit/01-mixer.svg)

左から RF と LO を入れ、中央の 3SK291 (U1) で混ぜ、右のセラミックフィルタ (FL1) で 455 kHz を選んで IF OUT へ出す。
電源の記号 (+5V) は、G1 の分圧を遠くの電源の線まで引き回さないよう 2 か所に置いた (同じ名前なので同じ電源)。
3SK291 はデュアルゲートの記号 (`nmos-dg`) で描いた。左の 2 本がゲートで、上が G2 (LO)、下が G1 (RF)。上がドレイン、下がソース。
青い数字は解析で求めた動作点と信号の大きさ。

### 3 つの工夫

- **G1 は 1 V 前後の正の電圧が要る。** 3SK291 はエンハンスメント型で、G1 を 0 V にすると ID がほぼ流れない
  (IDSS は最大 0.1 mA)。VDD から 1 MΩ で引き上げ、150 kΩ と可変抵抗 VR1 (200 kΩ) で分けて、
  VR1 で ID を 10 mA 前後に合わせる。ソースは直接 GND
- **G2 は低い電圧 (約 1.4 V) に置く。** データシートの測定条件の VG2S = 4.5 V は増幅器の条件で、
  LO で G2 を振るミキサーでは変換が起きない (3-2 の図 3)。33 kΩ と 13 kΩ の分圧で 1.41 V にした
- **ドレインは 220 µH と 560 pF の並列に給電する。** 約 454 kHz に同調し、RF と LO に低いインピーダンスを
  見せる。1 mH と 120 pF では RF の周波数で利得が約 5 dB 揺れた。フィルタの入力には 2 kΩ (R7) を並列にして、
  フィルタの源のインピーダンスを決める。R7 が無いと IF OUT が 50 Ω にならない

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| U1 | 3SK291 | デュアルゲート N チャネル MOSFET。**SMD (SMQ 4 ピン)** なので変換基板が要る |
| R1 | 51 Ω | RF IN の 50 Ω 終端 (ポートに並列) |
| R2 | 1 MΩ | VDD から G1 へのバイアス |
| R3 | 51 Ω | LO IN の 50 Ω 終端 (ポートに並列) |
| R4 | 33 kΩ | G2 の分圧 (上) |
| R5 | 13 kΩ | G2 の分圧 (下)。G2 = 5 V × 13 / 46 ≒ 1.41 V |
| R6 | 150 kΩ | G1 の分圧 (下の固定分) |
| VR1 | 200 kΩ (B カーブ) | G1 の分圧 (下の可変分)。ID を合わせる |
| R7 | 2 kΩ | セラミックフィルタ入力の終端 |
| R8 | 51 Ω | **計測用**。IF OUT の 50 Ω の負荷 (回路図の外。ブレッドボードの図にだけ付ける) |
| J1〜J3 | SMA コネクタ (メス、**端面実装**) | RF 入力・LO 入力・IF 出力。**ユニバーサル基板の図にだけ付ける** |
| J4 | USB-C 電源取り出し基板 | 5 V の電源。CC に 5.1 kΩ を内蔵した品 (ユニバーサル基板の図にだけ付ける) |
| C1, C2 | 10 nF | RF と LO の DC カット (セラミック) |
| C3 | 560 pF | L1 と並列で約 454 kHz に同調 (C0G / NP0) |
| C4 | 10 nF | IF をフィルタへ (DC カット) |
| C5 | 1.2 nF | 出力整合 (シャント。C0G / NP0) |
| C6 | 100 nF | 電源のデカップリング (セラミック) |
| C7 | 10 µF 16 V | 電源のデカップリング (電解。+ を電源側に) |
| L1 | 220 µH | ドレインの DC 給電と IF の同調 (直流抵抗の小さいもの) |
| L2 | 100 µH | 出力整合 (直列) |
| FL1 | 455 kHz セラミックフィルタ | **入出力 1.5 kΩ の品**。型番ごとにインピーダンスが違うので、データシートで確かめる |
| 電源 | 5 V | 既定の電源 |

出力整合は、フィルタの出力 (1.5 kΩ) に C5 を並列に、50 Ω 側へ L2 を直列に入れた L 型。
455 kHz で C5 の抵抗分を考えると 1.5 kΩ が約 54 Ω に下がり、L2 の 286 Ω のリアクタンスがその C5 の残りを打ち消す。
フィルタが 1.5 kΩ でなければ、C5 と L2 を計算し直す。

## 実体配線図

3SK291 は SMD の 4 ピン (SMQ) で、板に直には挿せない。**変換基板に載せた形**で描いた
(1 番 G1・2 番 G2・3 番 D・4 番 S。SMQ の番号のまま。**手持ちの基板の足の並びが違うときは、図の足の位置を読み替える**)。
図の U1 は `dip4` の部品で、足の名前の表がまだ固定版のフェンスに無く、足は番号 (1〜4) で出る。
2 列の基板なので溝をまたぐ。1 列 (`sip4`) の基板なら 1 列に G1 G2 D S の順に挿す。

### ブレッドボード

LO の最大は 2.055 MHz で、ブレッドボードの上限 (3 MHz) に収まる。電流は 10 mA ほど。
板は `full` (63 列)。G1・G2・D の 3 つの列に 3 部品ずつ集まり、`half` (30 列) には収まらなかった。
AD3 を下に置いて、電源・W1 (RF)・W2 (LO)・1+ (IF OUT)・2+ (LO の入口) をつなぐ。

```breadboard
title: 図02 ブレッドボードに組む (AD3 の W1・W2・CH1・CH2 つき)
board: full
parts:
  U1: dip4 @ e30 3SK291
  R2: resistor g30 g27 1M
  R6: resistor i30 i25 150k
  VR1: potentiometer/trimmer f23 f24 f25 200k
  C1: capacitor/ceramic b19 b29 10n
  R1: resistor d19 d15 51
  C3: capacitor/ceramic d36 d32 560p
  L1: inductor b36 b40 220u
  C4: capacitor/ceramic e36 e46 10n
  R7: resistor b46 b43 2k
  FL1: sip3 @ d46 SFU455B
  C5: capacitor/ceramic e50 e54 1.2n
  L2: inductor b50 b56 100u
  R8: resistor d56 d60 51
  R4: resistor f37 f33 33k
  R5: resistor i33 i36 13k
  C2: capacitor/ceramic h47 h33 10n
  R3: resistor i47 i51 51
  C6: capacitor/ceramic f10 f6 100n
  C7: capacitor/electrolytic h10 h6 10u
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, W1, 1-, 2-, W2, 2+, 1+]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -b4 black
  - +t62 -- +b62 red
  - -t61 -- -b61 black
  - f27 -- e27 red
  - +t27 -- a27 red
  - +b10 -- j10 red
  - +b37 -- j37 red
  - +t32 -- a32 red
  - +t40 -- a40 red
  - -b6 -- j6 black
  - -b24 -- j24 black
  - -b23 -- j23 black
  - -b36 -- j36 black
  - -b51 -- j51 black
  - -t30 -- a30 black
  - -t15 -- a15 black
  - -t43 -- a43 black
  - -t47 -- a47 black
  - -t54 -- a54 black
  - -t60 -- a60 black
  - AD.W1 -- e19 yellow
  - AD.W2 -- j47 green
  - AD.2+ -- j48 green
  - g47 -- g48 green
  - AD.1+ -- e56 orange
  - AD.1- -- -b33 black
  - AD.2- -- -b35 black
  - j30 -- j29 purple
  - f29 -- e29 purple
  - j31 -- j33 purple
  - c31 -- c36 brown
  - c48 -- c50 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/breadboard/01-mixer.svg)

- 電源: AD3 の V+ (Supplies で 5 V) を赤で +t2 へ、GND を黒で -b4 へ。上下のレールは右端で渡す (赤 +t62〜+b62、黒 -t61〜-b61)
- 上のブロック (a〜e 行): 左から C1・R1 (RF の入口)、U1 の D (31 列) から右へ C3 と L1 の並列タンク、C4、R7、FL1、C5、L2、R8 (IF の出口)
- 下のブロック (f〜j 行): 左端に C6・C7 の電源のパスコン。U1 の左に G1 の分圧 (R2・R6・VR1)、右に G2 の分圧 (R4・R5・C2)
- U1 は e30 から。1 番 G1 が f30、2 番 G2 が f31、3 番 D が e31、4 番 S が e30。S は a30 から黒で -t30 へ
- VR1 は**可変抵抗として使う**。1 番 (A) が R6 の側、W と B は別の列でそれぞれ GND へ
- G1 と G2 と D の分かれ目は、同じ列の別の穴から出し直した (紫と茶の短い線)。1 つの穴に 2 本は挿さらないため
- RF (黄): W1 を e19 へ。LO (緑): W2 を j47、2+ を j48 へ (g47〜g48 の緑の線で 2 つの列をつなぐ)。IF (橙): 1+ を e56 へ。1− と 2− (黒) は -b33 と -b35 へ
- R8 (51 Ω) は IF OUT の 50 Ω の負荷 (AD3 の入力は 1 MΩ)。回路図の外の、計器の側の部品

部品の穴は次のとおり。

| 部品 | 穴 | 部品 | 穴 |
| --- | --- | --- | --- |
| U1 | e30 (1=f30 2=f31 3=e31 4=e30) | C5 1.2n | e50 / e54 |
| R1 51 | d15 / d19 | L2 100u | b50 / b56 |
| C1 10n | b19 / b29 | R8 51 | d56 / d60 |
| R2 1M | g27 / g30 | R4 33k | f33 / f37 |
| R6 150k | i25 / i30 | R5 13k | i33 / i36 |
| VR1 200k | f23 (B) f24 (W) f25 (A) | C2 10n | h33 / h47 |
| C3 560p | d32 / d36 | R3 51 | i47 / i51 |
| L1 220u | b36 / b40 | C6 100n | f6 / f10 |
| C4 10n | e36 / e46 | C7 10u | h10 (+) / h6 (−) |
| R7 2k | b43 / b46 | FL1 | d46 (IN) d47 (GND) d48 (OUT) |

### ユニバーサル基板

調整が済んだ回路を残す形。**ブレッドボードでも組める**が、G1 の 1 MΩ の節と 455 kHz の同調 (L1・C3) が
列どうしの浮遊容量に影響されやすいので、調整後は半田付けで固める。周波数は最大 2.055 MHz、電流は 10 mA ほどで、
ユニバーサル基板の範囲 (10 MHz 以下) に収まる。
板は **5×7 cm を横置き** (24 列 × 18 行、両端に縁の銅箔、1.6 mm の FR-4)。入口は端面実装の SMA コネクタ 3 つ (J1 RF 入力・J2 LO 入力・J3 IF 出力)、
電源は USB-C (J4) を左下に付けた。基板は幅 9.2 mm (約 3.6 穴) で、後ろの縁に並ぶ 4 つの四角いパッドを n 行 (n2〜n5) の穴に合わせて付ける。基板は n 行から下へ伸び、板の下端の近くまで覆う (実物は長さ 14.5 mm だが、図は 5 穴に詰める)。基板の下には線を通さないので、GND の筋はパッドのすぐ上の m 行に通した。パッドは 2〜5 列目に GND・D+・D-・VBUS の順で (基板の刷り字は `V`)、**線はこのパッドへつなぐ**。差し込み口を下に向けて、GND が左端、VBUS が右端。D+ と D- は使わない (ERC が未接続と言う)。USB-C の 5.1 kΩ の CC プルダウンは、**内蔵の電源取り出し用の変換基板を使う前提**で図には描かない
(内蔵でない基板なら CC1・CC2 に 5.1 kΩ を GND へ足す)。
図は部品面から見たもの。下に半田面 (左右が逆) の図を付けた。

```perfboard
title: 図03 ユニバーサル基板に組む (部品面から見た図。下は半田面)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  slots: on
parts:
  U1: dip4 f14 3SK291
  R1: resistor c3 c6 51
  R2: resistor g11 d11 1M
  R3: resistor f4 i4 51
  R4: resistor i16 f16 33k
  R5: resistor n16 q16 13k
  R6: resistor g8 j8 150k
  R7: resistor b21 b24 2k
  VR1: potentiometer/trimmer k9 k10 k11 200k
  C1: capacitor/ceramic e3 e6 10n
  C2: capacitor/ceramic n7 n10 10n
  C3: capacitor/ceramic b15 e15 560p
  C4: capacitor/ceramic b17 b20 10n
  C5: capacitor/ceramic h20 h23 1.2n
  C6: capacitor/ceramic j2 m2 100n
  C7: capacitor/electrolytic j4 m4 10u
  L1: inductor b13 e13 220u
  L2: inductor i20 i23 100u
  FL1: sip3 d20 r90 SFU455B
  J1: sma/female-edge c1 b0 d0
  J2: sma/female-edge i1 h0 j0
  J3: sma/female-edge i24 h25 j25
  J4: usb-c/female n2 n3 n4 n5
wires:
  - n5 -- j5 red
  - j5 -- j4 red
  - j2 -- b2 red
  - b2 -- b3 red
  - b3 -- b10 red
  - b10 -- b11 red
  - b11 -- b13 red
  - b13 -- b15 red
  - b15 -- b16 red
  - j3 -- j4 red
  - j2 -- j3 red
  - d0 -- d1 black
  - d1 -- f1 black
  - f1 -- h1 black
  - h0 -- h1 black
  - j0 -- j1 black
  - j1 -- m1 black
  - m1 -- m2 black
  - n2 -- m2 black
  - m2 -- m4 black
  - m4 -- m6 black
  - m6 -- q6 black
  - f1 -- f4 black
  - q6 -- q12 black
  - q12 -- q16 black
  - q16 -- q21 black
  - q21 -- q24 black
  - j25 -- j24 black
  - j24 -- q24 black
  - c6 -- c12 black
  - c12 -- e12 black
  - f14 -- f12 black
  - e12 -- f12 black
  - f12 -- k12 black
  - k12 -- q12 black
  - k12 -- k11 black
  - k11 -- k10 black
  - e20 -- e24 black
  - b24 -- e24 black
  - e24 -- h24 black
  - h23 -- h24 black
  - h24 -- h25 black
  - c1 -- c3 white
  - c3 -- e3 white
  - g11 -- i11 white
  - g8 -- g11 white
  - e6 -- e8 blue
  - e8 -- g8 blue
  - b11 -- d11 red
  - j8 -- k8 white
  - k8 -- k9 white
  - i14 -- i11 yellow
  - i15 -- i16 white
  - n16 -- n10 yellow
  - i16 -- n16 white
  - b16 -- f16 yellow
  - i1 -- i4 white
  - i4 -- i7 white
  - i7 -- k7 white
  - k7 -- n7 white
  - f15 -- e15 white
  - e13 -- e15 white
  - e15 -- e17 white
  - e17 -- b17 white
  - b20 -- b21 white
  - b20 -- d20 white
  - f20 -- h20 white
  - i20 -- h20 white
  - i23 -- i24 white
notes:
  - parts
style:
  back: on
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/perfboard/01-mixer.svg)

5×7 cm に収めるために、次のようにした。

- 端面実装の SMA は胴が板の外へ出るので、板の中の穴は中心導体の 1 穴 (J1 は c1、J2 は i1、J3 は i24) だけ。先端は縁の銅箔 (0 列と 25 列) に半田付けする
- 抵抗・コンデンサ・インダクタは足を 3 穴間隔 (差が 3) にした (L2・C5 は J3 の手前に横。C4・R7 は右上の b 行に横。FL1 は 20 列に縦 (`sip3 d20 r90`)。R3 は 4 列に縦に置く (f4-i4)。C6・C7 は USB-C の基板のすぐ上に縦に置き、3 穴間隔で j 行 (VDD) と m 行 (GND) にまたがる)
- USB-C (J4) の変換基板は 14.5 x 9.2 x 3.2 mm の品を想定する。図の胴は幅 9.2 mm (約 3.6 穴) で 2〜5 列に、長さは 5 穴に詰めて n 行から下に描かれる。**足は基板の後ろの縁の四角いパッド 4 つ (n2〜n5) で、線はパッドへつなぐ。図ではパッドの真ん中から線が出るのが部品面からも見える。胴の上には部品も線も置かない** (m 行の GND の筋は胴のすぐ上を通る)。足の書き順は変換基板のパッドの並び GND D+ D- VBUS で、4 本とも書くので `J4: usb-c/female n2 n3 n4 n5` と書く。左端が GND (n2)、右端が VBUS (n5)、間の D+ (n3)・D- (n4) は使わない。基板の刷り字は VBUS を `V` と縮めてあり、パッドの下に出る
- GND の筋は Q 行の q6〜q24。左の GND は m 行 (m1〜m6) から 6 列を下って q6 へ、右は J3 の下の先端 (j25) から j24 へ出て 24 列を q24 まで下る。FL1 の GND (e20) は e 行を右へ通って 24 列の GND の線 (e24) へ
- 跨ぎは数えていない。VBUS の線 (2 列と 5 列) を RF・LO の線と f 行・m 行の GND の線が渡る
- U1 は dip4 のまま (向きを変えていない)

- USB-C (J4) は左下の隅。VBUS のパッド (n5) から 5 列を j 行まで上って C7 の + (j4)・C6 (j2) へ渡り、2 列を b 行の電源 + の筋へ。GND のパッド (n2) から m2 へ上がって m 行の GND の筋へ。D+ (n3)・D- (n4) はどこにもつながない。CC1・CC2 の 5.1 kΩ は、変換基板に内蔵のもの (電源取り出し用の基板) を使う前提で、図には描かない。変換基板は 14.5 x 9.2 x 3.2 mm の品を想定 (図は縦 5 穴に詰める)
- J1 (RF 入力) は左上の b〜d 行 (先端 b0・d0、中心 c1)。J2 (LO 入力) は左の中央 (先端 h0・j0、中心 i1)。LO は i 行を右へ通る。J3 (IF 出力) は右の中央 (先端 h25・j25、中心 i24)。入口の 51 Ω (R1・R3) は SMA の中心から。IF は L2 の IF 側 (i23) から隣の J3 の中心 (i24) へ。計器側が 50 Ω の負荷
- 左端の縁の銅箔の GND は 1 列に出し (d1〜h1、j1〜m1)、m 行へ通した。上下は縁の銅箔でつながる。R3 の GND の足 (f4) は f1 から
- C5 の GND の足 (h23) は h 行を右へ通って J3 の上の先端 (h25) へ。R7 の GND の足 (b24) は 24 列を下って h24 で合流する
- 半田付けの順は、電源と GND の筋 → 抵抗・インダクタ・コンデンサ → VR1 → FL1 → C6・C7 → U1 の変換基板 → J1〜J4
- FL1 の足: 1 = IN (d20)、2 = GND (e20)、3 = OUT (f20)。IN は C4 の FIN の足 (b20) から 20 列を下って、OUT は 20 列を下って C5 (h20)・L2 (i20) へ。C4 の D 側 (b17) は e17 から 17 列を上る。VR1: 1 = A (k9、中点)、2 = W (k10)、3 = B (k11)。B は 12 列の GND の線へ (k11〜k12)、W は B と線でつなぐ (k10〜k11)
- 周波数は最大 2.055 MHz、電流は 10 mA ほどで perfboard の範囲に収まる

| 部品 | 値 | 穴 |
| --- | --- | --- |
| U1 | 3SK291 (dip4) | アンカー f14: S f14、D f15、G1 i14、G2 i15 |
| R1 | 51 | c3 (RF) / c6 (GND) |
| R2 | 1M | g11 (G1) / d11 (VDD) |
| R3 | 51 | i4 (LO) / f4 (GND) |
| R4 | 33k | i16 (G2) / f16 (VDD) |
| R5 | 13k | n16 (G2) / q16 (GND) |
| R6 | 150k | g8 (G1) / j8 (中点) |
| R7 | 2k | b21 (FIN) / b24 (GND) |
| VR1 | 200k 半固定 | k9 (A) k10 (W) k11 (B) |
| C1 | 10n | e3 (RF) / e6 (G1) |
| C2 | 10n | n7 (LO) / n10 (G2) |
| C3 | 560p | b15 (VDD) / e15 (D) |
| C4 | 10n | b17 (D) / b20 (FIN) |
| C5 | 1.2n | h20 (FO) / h23 (GND) |
| C6 | 100n | j2 (VDD) / m2 (GND) |
| C7 | 10u 16 V | j4 (+、VDD) / m4 (-、GND) |
| L1 | 220u | b13 (VDD) / e13 (D) |
| L2 | 100u | i20 (FO) / i23 (IF) |
| FL1 | 455 kHz | d20 (IN) e20 (GND) f20 (OUT)。縦置き |
| J1 | SMA 端面 (RF 入力) | 中心 c1 / 先端 b0・d0 (縁の銅箔) |
| J2 | SMA 端面 (LO 入力) | 中心 i1 / 先端 h0・j0 (縁の銅箔) |
| J3 | SMA 端面 (IF 出力) | 中心 i24 / 先端 h25・j25 (縁の銅箔) |
| J4 | USB-C (電源) | n2 (GND、左端) / n5 (VBUS、右端)。n3 (D+)・n4 (D-) は使わない |

## 計器の設定 (Analog Discovery 3)

計器は **Analog Discovery 3 (AD3)** にする。IF は 455 kHz、LO は最大 2.055 MHz で、どれも 10 MHz 以下なので、
電源・信号源・オシロ・スペクトラムを 1 台でまかなえる (tinySA は要らない)。
配線は実体配線図のとおり。AD3 の入力は 1 MΩ なので、**IF OUT には計器の側の 50 Ω の負荷 R8 (51 Ω) を付ける**。
R8 が無いと、出力が 50 Ω の IF OUT は負荷が軽くなり、電圧が約 2 倍 (+6 dB) に出て、表の値と合わない。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない)。電源を入れてから Wavegen を出す |
| Wavegen W1 (RF) | Sine、1.000 MHz、振幅 0.1 V (−10 dBm)、オフセット 0 V。**最初はこの大きさ**。合ったら振幅 10 mV (−30 dBm) にする |
| Wavegen W2 (LO) | Sine、1.455 MHz、振幅 0.71 V (+7 dBm)、オフセット 0 V |
| Scope CH1 | 1+ = IF OUT (R8 の上)、1− = GND。50 mV/div、時間は 1 µs/div |
| Scope CH2 | 2+ = LO の入口 (C2 の前)、2− = GND。LO の振幅が 0.71 V かを見る。500 mV/div |
| Spectrum | チャンネルは CH1。開始 0 Hz・終了 2.5 MHz、FFT 8192 点、窓は Flat Top、縦軸 dBV |

- RF を最初に 0.1 V にするのは、10 mV (−30 dBm) だと Wavegen の分解能に近く、信号源の雑音が見えるため。
  3-2 の図 6 のとおり、−10 dBm までは利得が一定なので、0.1 V でも変換利得は同じに読める
- 標本化は 2.5 MHz × 2.56 = 6.4 MHz、分解能は 6.4 MHz ÷ 8192 ≈ 0.78 kHz。IF (455 kHz) と RF・LO は十分に分かれる
- Spectrum の縦軸 dBV は、50 Ω の dBm から 13.0 dB を引いた値 (dBV = dBm − 13.01)。IF の −28.6 dBm は **−41.6 dBV**
- W1 と W2 は別々に周波数を決める。LO は RF + 455 kHz に**自分で合わせる** (RF を変えたら LO も変える)

## 想定する電圧

### 直流 (解析の動作点)

| 場所 | 電圧 | 備考 |
| --- | --- | --- |
| VDD | 5.00 V | |
| ドレイン | 4.95 V | L1 の直流抵抗 (モデルで 5 Ω) による降下 |
| G1 | 1.24 V | VR1 が約 180 kΩ のとき。**VR1 で ID を合わせる** |
| G2 | 1.41 V | 33 kΩ と 13 kΩ の分圧 |
| ソース | 0 V | 直接 GND |
| ID | 9.8 mA | 電力 約 49 mW (絶対最大 150 mW) |

RF IN・LO IN・IF OUT は**どれも直流 0 V** (C1・C2・C4 とフィルタで切ってある)。外から直流を加えない。

### 交流 (ポートの 50 Ω の両端)

| ポート | 条件 | 電力 | 実効値 | 波高値 | ピーク間 |
| --- | --- | --- | --- | --- | --- |
| RF IN | 標準 (解析条件) | −30 dBm | 7.1 mV | 10 mV | 20 mV |
| RF IN | 利得が一定の上限の目安 | −10 dBm | 70.7 mV | 100 mV | 0.2 V |
| RF IN | 利得が約 1.5 dB 落ちる (モデル) | 0 dBm | 224 mV | 0.32 V | 0.63 V |
| LO IN | 標準 | +7 dBm | 0.50 V | 0.71 V | 1.42 V |
| LO IN | 下限 (変換利得 −4 dB) | 0 dBm | 0.22 V | 0.32 V | 0.63 V |
| LO IN | 上限の目安 (+2 dB 以上) | +10 dBm | 0.71 V | 1.0 V | 2.0 V |
| IF OUT | RF −30 dBm のとき | −28.6 dBm | 8.2 mV | 11.7 mV | 23 mV |
| IF OUT | RF −10 dBm のとき | −8.7 dBm | 82 mV | 0.12 V | 0.23 V |

LO は G2 の直流 (1.41 V) の周りを ±0.7 V (+7 dBm のとき) 振る。G1・G2 の絶対最大は ±8 V なので余裕がある。

## 調整

1. RF と LO を入れずに VR1 を回し、**ID が約 10 mA** になる所に合わせる。ID は VDD の線に入れた電流計か、L1 の両端の電圧で見る
2. LO を +7 dBm、RF を −30 dBm (LO は RF + 455 kHz) で入れ、IF OUT の 455 kHz を見ながら R5 を替えて、
   G2 を 1.2〜1.6 V の間で探す。G2 を上げすぎると変換が急に落ちる
3. LO を 0〜+10 dBm で動かして、利得の傾きを確かめる

## 計器の画面

計算値。IF OUT は 3-2 の解析 (RF −30 dBm・LO +7 dBm のとき −28.6 dBm = 11.7 mV<sub>p</sub> = **−41.6 dBV**) による。
LO と RF の漏れは、フィルタの阻止域の深さを仮定した**目安**で、実物では変わる (下の表)。

```spectrum
title: 図04 IF OUT のスペクトル (RF 1.000 MHz −30 dBm、LO 1.455 MHz +7 dBm)
device: ad3
sweep: 0-2.5MHz
samples: 8192
window: flattop
unit: dBV
ref: -30dBV
signal:
  - sine 455kHz 11.7mV
  - sine 1.455MHz 2.0mV
  - sine 1MHz 0.13mV
markers: [455k, 1.455M, 1M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/spectrum/01-mixer.svg)

- 455 kHz の山が一番高く、−41.6 dBV で立つ。RF −30 dBm から見て **+1.4 dB の変換利得**
- 山のほかに見えるのは LO (1.455 MHz) と RF (1.000 MHz) の漏れ。**どちらも IF より十分低い**が、
  高さはセラミックフィルタの阻止域で決まる (下の表)。図の値は仮定の目安
- 影像側 (1.910 MHz) と和 (2.455 MHz) の成分は、フィルタと L2 で落ちて見えない

```scope
title: 図05 IF OUT の波形 (RF −10 dBm のとき、455 kHz の正弦波)
time: 1us/div
trigger: ch1 rising 0V
ch1: sine 455kHz 120mV
cursors: [0, 2.2us]
measure: [freq, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/scope/01-mixer.svg)

- RF を 0.1 V (−10 dBm) にしたときの波形。IF OUT は 0.12 V<sub>p</sub> (0.23 V<sub>pp</sub>) の 455 kHz の正弦波
- 1 周期は 2.2 µs。1 µs/div なら 10 目盛で 4.5 周期が見える。RF と LO の周波数の差で決まるので、
  LO を 1 kHz 動かすと 455 kHz も 1 kHz 動く
- RF −30 dBm では振幅が 11.7 mV<sub>p</sub> しかなく、Wavegen と入力の雑音で波形が荒れる。形を見るなら −10 dBm にする

### 漏れの目安の出し方

| 成分 | 見積もり | IF OUT での値 |
| --- | --- | --- |
| LO 1.455 MHz | ドレインの LO 1.17 V<sub>p</sub> (3-2) = −1.7 dBV → フィルタの阻止域 30 dB (**仮定**) → L2 (914 Ω) と 50 Ω で 25 dB 下がる | 約 −57 dBV |
| RF 1.000 MHz | ドレインの RF 52 mV<sub>p</sub> = −28.7 dBV → 阻止域 30 dB (**仮定**) → L2 (628 Ω) と 50 Ω で 22 dB 下がる | 約 −81 dBV |

3-2 の FFT は、モデルのフィルタが理想的で阻止域が深すぎる (−120 dBm 以下)。実物のセラミックフィルタの
阻止域は未確認なので、**30 dB は仮定**。実際に測った漏れが大きければ、阻止域がもっと浅い。

## 見るべき値

IF OUT の 455 kHz は、RF −30 dBm・LO +7 dBm のとき **約 −28.6 dBm (波高値 11.7 mV、−41.6 dBV)**。
変換利得は +1 dB 前後で、**組んだ実機では大きく外れうる** (3-2 の「確かめていないこと」)。
上の図 04・05 のとおりに Analog Discovery 3 で測る。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 | 455 kHz (RF 1.000 MHz・LO 1.455 MHz のとき。LO − RF) |
| IF の大きさ (RF −30 dBm) | −41.6 dBV (11.7 mV<sub>p</sub>)。変換利得 +1.4 dB |
| IF の大きさ (RF −10 dBm) | −21.7 dBV (0.12 V<sub>p</sub>、82 mV 実効)。利得は同じ |
| RF の振幅を半分に | IF も 6 dB 下がる (傾き 1。−10 dBm までは利得が一定) |
| LO を 0 dBm (0.32 V<sub>p</sub>) | 利得 −4.1 dB (RF −30 dBm なら約 −47 dBV) |
| LO を +10 dBm (1.0 V<sub>p</sub>) | 利得 +2.2 dB (RF −30 dBm なら約 −41 dBV) |
| LO を止める | IF が消える (混ぜる相手が無い) |
| RF を影像の 1.910 MHz にする (LO 1.455 MHz) | 同じ高さの IF が出る (影像抑圧 0 dB) |
| RF だけ動かして LO を固定 | IF が 455 kHz から離れ、フィルタの帯域 (約 12 kHz) の外で急に落ちる |
| LO と RF の漏れ | IF より十分低い。高さはフィルタ次第 (図 04 の値は目安) |

## 注意

- 中波の RF 入力に**前置の同調回路が無い**。影像 (LO + 455 kHz) も同じ利得で出るので、
  実際に使うときは RF の前にバリコンなどの同調回路を置く
- ミキサーの出力にはセラミックフィルタ 1 つ。RF・LO・和周波を落とす深さは、フィルタの型番で決まる
- 3SK291 はゲートが静電気に弱い。取り扱いに注意する

## 出典

- [3SK291 (RS)](https://au.rs-online.com/web/p/mosfets/7560385) — VDS 最大 12.5 V・ID 最大 30 mA
- [3SK291 データシート (electronicsdatasheets)](https://www.electronicsdatasheets.com/download/101912.pdf?format=pdf) —
  VDS = 6 V・VG2S = 4.5 V・ID = 10 mA の測定条件 (検索結果の要約で読んだもの)
- [3SK291 データシート (秋月電子)](https://akizukidenshi.com/goodsaffix/3SK291_datasheet_ja_20140301.pdf) —
  |Yfs| 26 mS・Ciss 2.0 pF・Crss 0.016 pF・IDSS 最大 0.1 mA (検索結果の要約で読んだもの)
- [CFX455G (村田)](https://pdf.jiepei.com/cfx455g-28251406.html) — 入出力 1500 Ω の記載
- 元の回路は AI が描いた図で、動かない所を直して描き直した (図と文は写していない)
