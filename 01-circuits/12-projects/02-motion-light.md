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
  Rz: resistor a1 c1 330
  Dz: zener e1 c1 3V3
  GDz: ground e1
  CDS1: photoresistor c6 e6
  R1: resistor e6 g6 10k
  GR1: ground g6
  U1: dip14 j10 CD40106
  GU1: ground k17
  PIR:
    type: device
    at: d20
    label: PIR module
    pins: [VCC, OUT, GND]
  U2: dip14 j30 CD4081
  GU2: ground k37
  Rg: resistor m30 m33 220
  Rgpd: resistor m33 o33 100k
  GRgpd: ground o33
  Q1: nmos-e q36
  GQ1: ground q38
  RLED: resistor a45 c45 330
  DLED: led c45 e45 red
  GPIR: ground k20
wires:
  - a1 -- a20
  - c1 -- c40
  - e6 -| U1.1
  - c25 -| U1.14
  - U1.7 -| k17
  - a20 -| PIR.VCC
  - PIR.GND -| k20
  - U1.2 -- U2.2
  - PIR.OUT -| U2.1
  - c40 -| U2.14
  - U2.7 -| k37
  - U2.3 -| m30
  - m33 -- m36
  - m36 -| Q1.G
  - a45 -- a1
  - e45 -| Q1.D
  - Q1.S -| q38
notes:
  - text f1 blue: "VL 3.3V (ツェナー基準)"
  - text f10 blue: "暗いとH"
  - text f21 blue: "動いたらH"
  - text l30 blue: "両方Hで点灯"
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
- **使わないゲートの入力は GND に落とす。** 40106 は 6 つのうち 1 つ、4081 は
  4 つのうち 1 つしか使わない。CMOS の入力は浮かせると勝手に振れて電流を食い、
  発振することもある (10-1)。図では省いたが、基板では使わないゲートの入力を
  すべて GND へつなぐ (出力は開けたままでよい)
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
