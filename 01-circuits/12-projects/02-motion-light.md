---
book: circuits
chapter: 12
id: 12-2
title: 人感ライト — PIR + CdS + MOSFET
tier: 100
source: 自作
board: PF
era: 今
---

# 12-2 人感ライト — PIR + CdS + MOSFET

8-6 の PIR (人感) モジュールと、8-1 と同じ CdS の暗さ判定を **AND (10-1) で
組み合わせ**、「暗いときに人が動いたら点く」実用の人感ライトにする。
PIR モジュールの出力は 3.3V 系なので、ロジック IC 側も 1-13 と同じ
**ツェナーで 3.3V の基準を作って**電圧を合わせる。

## 回路図

```circuit
title: 図1 PIR+CdS(暗さ)をANDでMOSFETへ
parts:
  VCC5: vcc a1
  Rz: resistor a1 a3 330
  Dz: zener c3 a3 3V3
  GDz: ground c3
  CDS1: photoresistor a5 c5
  R1: resistor c5 e5 10k
  GR1: ground e5
  U1: dip14 f9 CD40106
  GU1: ground g8
  PIR:
    type: device
    at: d15
    label: PIR module
    pins: [VCC, OUT, GND]
  VCC5: vcc c14
  U2: dip14 f18 CD4081
  GU2: ground g17
  Rg: resistor i19 i21 220
  Rgpd: resistor i22 k22 100k
  GRgpd: ground k22
  Q1: nmos-e h24j0
  GQ1: ground j24
  VCC5: vcc c24
  RLED: resistor c24 e24 330
  DLED: led e24 g24 red
  GPIR: ground d14c0f0 r90
  GU1b: ground f9e8i0
  GU2b: ground f18h8c0
wires:
  - a3 -- a19
  - c5 -- c6
  - c6 |- U1.1
  - U1.14 -| a10
  - U1.7 -| f8h0c0
  - U1.2 -| h7
  - h7 -- h15
  - h15 |- U2.2
  - PIR.OUT -| e13
  - e13 |- U2.1
  - PIR.VCC -| c14
  - PIR.GND -| d14c0f0
  - U2.14 -| a19
  - U2.7 -| f17h0c0
  - U2.3 -| i16
  - i16 -- i19
  - i21 -- i22
  - Q1.G -| i22
  - Q1.S -- j24
  - g24 -- Q1.D
  # 使わない入力を GND へ (U1 は足3・5・9・11・13、U2 は足5・6・8・9・12・13)
  - U1.3 -| e8h0g0
  - U1.5 -| f8c0e0
  - e8h0g0 -- f8c0e0 -- f8h0c0 -- g8
  - U1.13 -| e9f8c0
  - U1.11 -| f9a8
  - U1.9 -| f9e8i0
  - e9f8c0 -- f9a8 -- f9e8i0
  - U2.5 -| f17c0e0
  - U2.6 -| f17e0i0
  - f17c0e0 -- f17e0i0 -- f17h0c0 -- g17
  - U2.13 -| e18f8c0
  - U2.12 -| e18h8g0
  - U2.9 -| f18e8i0
  - U2.8 -| f18h8c0
  - e18f8c0 -- e18h8g0 -- f18e8i0 -- f18h8c0
notes:
  - text b7 blue: "VL 3.3V (ツェナー基準)"
  - text d7 blue: "暗いとH"
  - text d11a5 blue: "動いたらH"
  - text j19 blue: "両方Hで点灯"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/02-motion-light.svg)

- **VL (3.3V) を作る**: Rz (330Ω) と Dz (3.3V ツェナー、1-13 と同じ考え方) の
  簡易シャント電源。ツェナー電流 = (5V−3.3V)/330Ω **≈ 5.2mA**。40106・4081
  は CMOS で消費電流が数µA と小さいので、この電流のほとんどはツェナーを
  流れて電圧を保つ
- **CD40106 (シュミット、3-8 で使った IC) を暗さ判定に使う**: CdS (VL 側) と
  R1 (10kΩ、GND 側) の分圧を 1 個のシュミットインバータに通す。暗い
  (CdS の抵抗が大きい) ほど分圧点の電圧は下がり、インバータの出力は
  **反転して H (暗い=H)** になる
- **CD4081 (AND、10-1 で使った IC) で 2 つの条件を掛け合わせる**: 40106 の
  出力 (暗い=H) と PIR モジュールの出力 (動いた=H) の両方が揃ったときだけ
  AND の出力が H になる
- **PIR モジュールは HC-SR501 相当**: 出力は電源電圧に関わらず**固定
  3.3V**。40106・4081 を VL (3.3V) で動かしているので、しきい値
  (V<sub>IH</sub>) がぴったり合う。**もし 40106・4081 を 5V (VCC5) で
  動かすと、PIR の 3.3V 出力が 5V 系の V<sub>IH</sub> (目安 3.5V) に届かず
  誤動作しうる** (3.3V で 5V の CMOS を叩くときの落とし穴)
- AND の出力 (H、電圧は VL = 3.3V) を Rg (220Ω) 経由で Q1 (2N7000) の
  ゲートへ。Rgpd (100kΩ) はゲートを浮かせないためのプルダウン。
  3.3V のゲート駆動では 2N7000 は完全飽和まで届かないが、常夜灯 LED
  程度の電流 (計算値 約9.1mA) なら Rds(on) が多少高くても実害はない
- **使わない入力は GND へ。** 40106 は 6 つのうち 1 つ、4081 は 4 つのうち 1 つ
  しか使わない。CMOS の入力は浮かせると勝手に振れて電流を食い、発振することも
  ある (10-1)。使わないゲートの入力 (40106 は足3・5・9・11・13、4081 は足5・6・8・
  9・12・13) はすべて GND へつなぐ (図1・図2 とも描いてある)。出力の足は開けたまま
  でよい
- PIR モジュール自体は基板上のポテンショメータで**感度**と**保持時間**を、
  ジャンパで**再トリガの可否**を調整できる (モジュールの仕様)

## ユニバーサル基板に組む

```perfboard
board:
  size: 37x16
  slots: on
title: 図2 perfboardに組む (部品面から見た図)
points:
  PWR: a1
  GND: p1
parts:
  PIR:
    type: device
    at: -d16
    label: PIR
    pins: GND VCC OUT
  Rz: resistor a2 d2 330
  Dz: zener f3 d3 3V3
  CDS1: photoresistor d5 f5
  R1: resistor i5 l5 10k
  U1: dip14 f8 CD40106
  U2: dip14 f20 CD4081
  Rg: resistor e34 h34 220
  Rgpd: resistor h33 h29 100k
  Q1: transistor j33 j34 j35 2N7000
  RLED: resistor a36 d36 330
  DLED: led e36 g36 red
wires:
  # 5V (a 行・赤)、VL 3.3V (c 行・橙)、GND (p 行・黒) の筋
  - PWR -- a2 red
  - a2 -- a17 red
  - a17 -- a36 red
  - d2 -- d3 orange
  - d3 -- d5 orange
  - d5 -- d8 orange
  - d8 -- d20 orange
  - GND -- p3 black
  - p3 -- p5 black
  - p5 -- p15 black
  - p15 -- p27 black
  - p27 -- p29 black
  # Dz のアノードと R1 の下端を GND へ
  - f3 -- p3 black
  - l5 -- p5 black
  # 暗さの分圧 (CDS1・R1) を U1 の足1 へ
  - f5 -- i5
  - i5 -- i8
  # U1・U2 の足14 (VDD) を VL へ
  - f8 -- d8 orange
  - f20 -- d20 orange
  # U1 (40106) の使わない入力: 足13・11・9 は e 行、足3・5 は j 行でまとめ、15 列で足7 と結んで GND へ
  - f9 -- e9 black
  - e9 -- e11 black
  - f11 -- e11 black
  - e11 -- e13 black
  - f13 -- e13 black
  - e13 -- e15 black
  - e15 -- j15 black
  - i10 -- j10 black
  - j10 -- j12 black
  - i12 -- j12 black
  - j12 -- j14 black
  - i14 -- j14 black
  - j14 -- j15 black
  - j15 -- p15 black
  # U2 (4081) の使わない入力: 足13・12・9・8 は e 行、足5・6 は j 行でまとめ、27 列で足7 と結んで GND へ
  - f21 -- e21 black
  - e21 -- e22 black
  - f22 -- e22 black
  - e22 -- e25 black
  - f25 -- e25 black
  - e25 -- e26 black
  - f26 -- e26 black
  - e26 -- e27 black
  - e27 -- j27 black
  - i24 -- j24 black
  - j24 -- j25 black
  - i25 -- j25 black
  - j25 -- j26 black
  - i26 -- j26 black
  - j26 -- j27 black
  - j27 -- p27 black
  # PIR: VCC は 5V の筋へ、GND は U1 の GND の角 (e15) へ、OUT は U2 の足1 へ
  - PIR.VCC -- a17 red
  - PIR.GND -- e16 black
  - e16 -- e15 black
  - PIR.OUT -- k18 green
  - k18 -- k20 green
  - k20 -- i20 green
  # U1 の足2 (暗いと H) → U2 の足2
  - i9 -- l9 blue
  - l9 -- l21 blue
  - l21 -- i21 blue
  # U2 の足3 (AND の出力) → Rg → Q1 のゲート
  - i22 -- k22 yellow
  - k22 -- k28 yellow
  - k28 -- e28 yellow
  - e28 -- e34 yellow
  - h33 -- h34
  - h34 -- j34
  - h29 -- j29 black
  # Q1: ソースは GND へ、ドレインは DLED のカソードへ
  - j33 -- j29 black
  - j29 -- p29 black
  - j35 -- j36
  - j36 -- g36
  - d36 -- e36
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/02-motion-light.svg)

- 部品面から見た図。5V (PWR) は上の a 行 (赤)、VL (3.3V) は d 行 (橙)、GND は下の
  p 行 (黒) に 1 本ずつ筋を通し、部品はそこから縦に配る。電源は左端の a1・p1 に入れる
- Rz (a2〜d2) が 5V の筋から VL の筋へ、Dz (d3〜f3、カソードが上) が VL から 3 列を
  下って GND へ。これで VL (3.3V) ができ、d 行で U1・U2 の足14 (f8・f20) と
  CDS1 (d5〜f5) へ配る。CDS1 の下端から 5 列を下り、i5 で R1 (i5〜l5、下は GND) と
  U1 の足1 (i8) へ分ける
- DIP14 は「アンカーの行に足14〜8、その 3 行下に足1〜7」の並び (perfboard の
  DIP の決め方)。U1 (f8 アンカー) は足14=f8、足8=f14、足1=i8、足7=i14。
  U2 (f20 アンカー) は足14=f20、足8=f26、足1=i20、足7=i26
- U1 の足2 (暗いと H、i9) は青の線で l 行を右へ運び、21 列を上って U2 の足2 (i21) へ。
  PIR の OUT (緑) は k18 に下ろし、k 行と 20 列で U2 の足1 (i20) へ
- PIR は板の外 (上、`-d16`) に置き、ケーブルの 3 本を真下の穴へ下ろす:
  GND は e16 (U1 の GND をまとめた角 e15 の隣)、VCC は a17 (5V の筋)、OUT は k18
- 使わない入力は黒の線で GND へ。U1 の足13・11・9 (f9・f11・f13) は e 行、足3・5
  (i10・i12) は j 行でまとめ、15 列で足7 (i14) と結んで p 行へ下ろす。U2 の足13・12・9・8
  (f21・f22・f25・f26) は e 行、足5・6 (i24・i25) は j 行でまとめ、27 列で足7 (i26) と
  結んで p 行へ下ろす。出力の足 (U1 の足4・6・8・10・12、U2 の足4・10・11) には
  何もつながない
- U2 の足3 (AND の出力、i22) は黄の線で k 行を右へ運び、28 列を上って e 行から
  Rg (e34〜h34) の上端へ。Rg の下端 (h34) から Q1 のゲート (j34) へ下ろし、隣の h33 から
  Rgpd (h33〜h29) を通して 29 列の GND へ
- Q1 (2N7000) は j 行に S・G・D の順 (平らな面を見て左から、実物の足の並び) で
  横並びに置く (j33・j34・j35)。ソースは j 行を左へ出して 29 列で GND へ、ドレインは
  j36 から 36 列を上って DLED のカソード (g36) へ。DLED のアノード (e36) は RLED
  (a36〜d36) を通して 5V の筋へ
- **交差は被覆線で跨ぐ**: 青 (U1 の足2) が 15 列の GND を、黄 (U2 の足3) が 27 列の
  GND を跨ぐ。どちらも U1・U2 の出力の足が GND にまとめた足の向こうにあるためで、
  足の並びからは避けられない。PIR のケーブルの GND と OUT は、板の上を 5V と VL の
  筋を越えて渡る

## 見るべき値

計算値。VCC5 = 5V (USB 電源)。

| 測る所 | 期待する値 |
| --- | --- |
| VL (ツェナー電圧) | 約3.3V (計算値) |
| ツェナー電流 | 約5.2mA ((5V−3.3V)/330Ω) |
| 明るい場所・人が動かない | LED 消灯 (40106 出力 L) |
| 暗い場所・人が動かない | LED 消灯 (4081 の PIR 側入力が L) |
| 暗い場所・人が動く | **LED 点灯** (両方 H) |
| DLED の電流 | 約9.1mA ((5V−2.0V)/330Ω、赤色 LED、計算値) |

## 出典

自作。
