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
  size: 40x18
  slots: on
title: 図2 perfboardに組む
points:
  PWR: a1
  GND: r1
parts:
  Rz: resistor a3 c3 330
  Dz: zener e5 c5 3V3
  CDS1: resistor d6 d8 10k
  R1: resistor d9 d11 10k
  U1: dip14 c12 CD40106
  U2: dip14 c24 CD4081
  PIR:
    type: device
    at: -c20
    label: PIR
    pins: [VCC, OUT, GND]
  Rg: resistor h32 j32 220
  Rgpd: resistor j34 l34 100k
  Q1: transistor n32 n33 n34 2N7000
  RLED: resistor a36 c36 330
  DLED: led a38 c38 red
wires:
  - PWR -- a3
  - c3 -- c5
  - e5 -- GND
  - c3 -- d6
  - d8 -- d9
  - d11 -- GND
  - c3 -- c12
  - c3 -- c24
  - d9 -- f9
  - f9 -- f12
  - f13 -- f25
  - PIR.OUT -- f24
  - f18 -- GND
  - f30 -- GND
  - f26 -- h32
  - j32 -- j34
  - l34 -- GND
  - j32 -- n33
  - n32 -- GND
  - PWR -- a36
  - c36 -- a38
  - c38 -- n34
  - PWR -- PIR.VCC
  - PIR.GND -- GND
  # 使わない入力を GND へ。U1 (40106) の足3・5 は g 行、足13・11・9 は b 行でまとめて足7 へ
  - f14 -- g14
  - g14 -- g16
  - f16 -- g16
  - g16 -- g18
  - g18 -- f18
  - c13 -- b13
  - b13 -- b15
  - c15 -- b15
  - b15 -- b17
  - c17 -- b17
  - b17 -- b19
  - b19 -- g19
  - g19 -- g18
  # U2 (4081) の足5・6 は足7 と並べてつなぎ、足13・12・9・8 は b 行と 31 列で足7 へ
  - f28 -- f29
  - f29 -- f30
  - c25 -- b25
  - b25 -- b26
  - c26 -- b26
  - b26 -- b29
  - c29 -- b29
  - b29 -- b30
  - c30 -- b30
  - b30 -- b31
  - b31 -- f31
  - f31 -- f30
```

- Rz・Dz が VL (3.3V) を作り、b3 (Rz の下端) から U1・U2 の足14 (c12・c24) と
  CDS1・R1 の分圧へ配る
- DIP14 は「アンカーの行に足14〜8、その 3 行下に足1〜7」の並び (perfboard の
  DIP の決め方)。U1 (c12 アンカー) は足1=f12、足2=f13、足7=f18、足14=c12。
  U2 (c24 アンカー) は足1=f24、足2=f25、足3=f26、足7=f30、足14=c24
  (**CDS1 は perfboard に photoresistor が無いので抵抗の記号で代用し、
  値の欄に実際の CdS の型番を書く運用にする**。実配線では CdS そのものを挿す)
- U1 の足2 (出力、f13) を U2 の足2 (f25) へ直結、PIR の OUT を U2 の足1
  (f24) へ。U2 の足3 (出力、f26) が Rg (220Ω) を経てゲートへ
- PIR は板の外 (上、`-c20`) に置き、3 本の足を PWR・GND・U2 の足1へ配線する
- 使わない入力は GND へ。U1 の足3・5 (f14・f16) は g 行で、足13・11・9 (c13・c15・
  c17) は b 行でまとめ、19 列を下りて足7 (f18、GND) へ。U2 の足5・6 (f28・f29) は
  隣の足7 (f30) へ並べてつなぎ、足13・12・9・8 (c25・c26・c29・c30) は b 行で
  まとめて 31 列を下り、足7 へ。出力の足 (U1 の足4・6・8・10・12、U2 の足4・10・11)
  には何もつながない
- Q1 (2N7000) は n 行に S・G・D の順 (実物の足の並び) で横並びに置く。ゲートに Rg・Rgpd、ドレインに
  RLED・DLED (電源側)、ソースは GND

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
