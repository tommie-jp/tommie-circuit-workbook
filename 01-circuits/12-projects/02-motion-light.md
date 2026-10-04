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

8-6 の PIR (人感) モジュールと、8-1 と同じ CdS の暗さ判定を AND (10-1) で
組み合わせ、「暗いときに人が動いたら点く」実用の人感ライトにする。センサー・ロジック・
MOSFET スイッチと、ここまでの章で学んだ部品を 1 枚の基板にまとめる。
PIR モジュールの出力は 3.3V なので、ロジック IC 側もツェナーダイオード (5-2) で
3.3V の電源 (以下 VL) を作り、電圧を合わせる。

## 回路図

```circuit
title: 図1 PIR+CdS(暗さ)をANDでMOSFETへ
parts:
  VCC5: vcc b2 5V
  Rz: resistor b2 d2 330
  Dz: zener f2 d2 3V3
  GDz: ground f2
  VL: vcc c5 3.3V
  VL: vcc d3a5 3.3V
  CDS1: photoresistor c5 e5 l=$\mathrm{CdS}$
  R1: resistor e5 g5 10k
  GR1: ground g5
  U1A: not e9 CD40106
  U3:
    type: device
    at: j8
    label: PIR module
    pins: [VCC, OUT, GND]
    turn: mirror
  VCC5: vcc i11 5V
  GPIR: ground k11
  U2A: and g14 CD4081
  Rg: resistor g16 g18 220
  Rgpd: resistor g18 i18 100k
  GRgpd: ground i18
  Q1: nmos-e f20j0
  GQ1: ground h20
  VCC5: vcc b20 5V
  RLED: resistor b20 d20 330 l=$R_\mathrm{LED}$
  DLED: led d20 e20 red l=$D_\mathrm{LED}$
wires:
  - d2 -- d3a5
  - e5 -- e7
  - e7 |- U1A.in
  - U1A.out -- e12
  - e12 |- U2A.a
  - U3.OUT -| j12
  - j12 |- U2A.b
  - U3.VCC -| i11
  - U3.GND -| k11
  - U2A.out -- g16
  - g18 -| Q1.G
  - Q1.S -- h20
  - e20 -- Q1.D
notes:
  - text c4 blue: "VL"
  - text d7 blue: "暗いとH"
  - text i12a5 blue: "動いたらH"
  - text f15 blue: "両方Hで点灯"
  - text m1 small left: "U1A・U2A の VDD (PIN 14) は VL (+3.3V)、VSS (PIN 7) は GND"
  - text n1 small left: "使わない入力は GND へ (U1: PIN 3・5・9・11・13、U2: PIN 5・6・8・9・12・13)"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/02-motion-light.svg)

- 図1 はゲートを論理記号で描いた。U1A は CD40106 の 1 回路目 (PIN 1→2)、U2A は CD4081 の
  1 回路目 (PIN 1・2→3) で、記号のピンの数字が PIN 番号。VL は電源の記号 (+3.3V) で表し、
  同じ記号どうしがつながっている
- VL (3.3V) を作る: Rz (330Ω) と Dz (3.3V のツェナー) の簡易シャント電源
  (ツェナーを負荷と並列に置いて電圧を保つ方式)。ツェナー電流 = (5V − 3.3V) / 330Ω
  ≈ 5.2mA。40106・4081 は CMOS で消費電流が数µA と小さいので、この電流のほとんどは
  ツェナーを流れて電圧を保つ
- CD40106 (シュミットインバータ、3-8 で使った IC) で暗さを判定する。CdS (VL 側) と
  R1 (10kΩ、GND 側) の分圧を 1 個のシュミットインバータに通す。暗い
  (CdS の抵抗が大きい) ほど分圧点の電圧は下がり、インバータの出力は
  反転して H になる (暗い = H)
- CD4081 (AND、10-1 で使った IC) で 2 つの条件を掛け合わせる。40106 の
  出力 (暗い = H) と PIR モジュールの出力 (動いた = H) の両方が揃ったときだけ
  AND の出力が H になる
- PIR モジュールは HC-SR501 相当。出力は電源電圧に関わらず 3.3V に決まっている。
  40106・4081 を VL (3.3V) で動かしているので、しきい値
  (V<sub>IH</sub>、H と認める最低の入力電圧) と合う。もし 40106・4081 を 5V (VCC5) で
  動かすと、PIR の 3.3V 出力が 5V で動く CMOS の V<sub>IH</sub> (目安 3.5V) に届かず、
  誤動作しうる (3.3V の出力で 5V の CMOS を動かすときの落とし穴)
- AND の出力 (H、電圧は VL = 3.3V) を Rg (220Ω) 経由で Q1 (2N7000) の
  ゲートへ。Rgpd (100kΩ) はゲートを浮かせないためのプルダウン。
  ゲートが 3.3V では、2N7000 は完全には ON になりきらない (5V で駆動したときより
  R<sub>DS(on)</sub> = ON のときのドレイン-ソース間の抵抗が高い)。それでも常夜灯の LED
  程度の電流 (計算値 約 9.1mA) なら実害はない。ただし 2N7000 のしきい値 (ON になり始める
  ゲート電圧) は 0.8〜3V とばらつくので、上限に近い個体では LED が暗い (目安)
- 使わない入力は GND へつなぐ。40106 は 6 つのうち 1 つ、4081 は 4 つのうち 1 つ
  しか使わない。CMOS の入力は浮かせると勝手に振れて電流を食い、発振することも
  ある (10-1)。使わないゲートの入力 (40106 は PIN 3・5・9・11・13、4081 は PIN 5・6・8・
  9・12・13) はすべて GND へつなぐ (図1 は図の下に書き、図2 は線で描いてある)。出力のピンは開けたまま
  でよい
- PIR モジュール自体は、基板上のポテンショメータで感度と保持時間 (動きを検知してから
  出力を H に保つ時間) を、ジャンパで再トリガ (H の間にまた動いたら時間を延ばすか) を
  調整できる (モジュールの仕様)

## ユニバーサル基板に組む

作品として残すので、ブレッドボードではなくユニバーサル基板 (perfboard) に組む。

```perfboard
board:
  size: 9x7cm
  slots: on
title: 図2 perfboardに組む (部品面から見た図)
points:
  PWR: a1
  GND: y1
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
  Rg: resistor n22 q22 220
  Rgpd: resistor q20 u20 100k
  Q1: transistor s21 s22 s23 2N7000
  RLED: resistor a29 d29 330
  DLED: led e29 g29 red
wires:
  # 5V (a 行・赤)、VL 3.3V (d 行・橙)、GND (y 行・黒) の筋
  - PWR -- a2 red
  - a2 -- a17 red
  - a17 -- a29 red
  - d2 -- d3 orange
  - d3 -- d5 orange
  - d5 -- d8 orange
  - d8 -- d20 orange
  - GND -- y3 black
  - y3 -- y5 black
  - y5 -- y15 black
  - y15 -- y20 black
  - y20 -- y21 black
  - y21 -- y27 black
  # Dz のアノードと R1 の下端を GND へ
  - f3 -- y3 black
  - l5 -- y5 black
  # 暗さの分圧 (CDS1・R1) を U1 の PIN 1 へ
  - f5 -- i5
  - i5 -- i8
  # U1・U2 の PIN 14 (VDD) を VL へ
  - f8 -- d8 orange
  - f20 -- d20 orange
  # U1 (40106) の使わない入力: PIN 13・11・9 は e 行、PIN 3・5 は j 行でまとめ、15 列で PIN 7 と結んで GND へ
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
  - j15 -- y15 black
  # U2 (4081) の使わない入力: PIN 13・12・9・8 は e 行、PIN 5・6 は j 行でまとめ、27 列で PIN 7 と結んで GND へ
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
  - j27 -- y27 black
  # PIR: VCC は 5V の筋へ、GND は U1 の GND の角 (e15) へ、OUT は U2 の PIN 1 へ
  - PIR.VCC -- a17 red
  - PIR.GND -- e16 black
  - e16 -- e15 black
  - PIR.OUT -- k18 green
  - k18 -- k20 green
  - k20 -- i20 green
  # U1 の PIN 2 (暗いと H) → U2 の PIN 2
  - i9 -- l9 blue
  - l9 -- l21 blue
  - l21 -- i21 blue
  # U2 の PIN 3 (AND の出力) → Rg → Q1 のゲート。Rgpd でゲートを GND へ
  - i22 -- n22 yellow
  - q22 -- s22
  - q22 -- q20
  - u20 -- y20 black
  # Q1: ソースは GND へ、ドレインは DLED のカソードへ
  - s21 -- y21 black
  - s23 -- s29
  - s29 -- g29
  - d29 -- e29
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/02-motion-light.svg)

- ユニバーサル基板は 7×9cm のユニバーサル基板を横に置いた 31 列 × 26 行 (厚み 1.6mm の FR-4)。5×7cm のユニバーサル基板 (24 列 × 18 行) には
  DIP14 2 個と出力の段が横に並びきらないので、次の順位の 7×9cm にした。出力の段 (Rg・Rgpd・Q1) は
  U2 の下に置いて、ユニバーサル基板の幅に収めた
- 部品面から見た図。5V (PWR) は上の a 行 (赤)、VL (3.3V) は d 行 (橙)、GND は下の
  y 行 (黒) に 1 本ずつ筋を通し、部品はそこから縦に配る。電源は左端の a1・y1 に入れる
- Rz (a2〜d2) が 5V の筋から VL の筋へ、Dz (d3〜f3、カソードが上) が VL から 3 列を
  下って GND へ。これで VL (3.3V) ができ、d 行で U1・U2 の PIN 14 (f8・f20) と
  CDS1 (d5〜f5) へ配る。CDS1 の下端から 5 列を下り、i5 で R1 (i5〜l5、下は GND) と
  U1 の PIN 1 (i8) へ分ける
- DIP14 は「アンカーの行に PIN 14〜8、その 3 行下に PIN 1〜7」の並び (perfboard の
  DIP の決め方)。U1 (f8 アンカー) は PIN 14=f8、PIN 8=f14、PIN 1=i8、PIN 7=i14。
  U2 (f20 アンカー) は PIN 14=f20、PIN 8=f26、PIN 1=i20、PIN 7=i26
- U1 の PIN 2 (暗いと H、i9) は青の線で l 行を右へ運び、21 列を上って U2 の PIN 2 (i21) へ。
  PIR の OUT (緑) は k18 に下ろし、k 行と 20 列で U2 の PIN 1 (i20) へ
- PIR はユニバーサル基板の外 (上、`-d16`) に置き、ケーブルの 3 本を真下の穴へ下ろす:
  GND は e16 (U1 の GND をまとめた角 e15 の隣)、VCC は a17 (5V の筋)、OUT は k18
- 使わない入力は黒の線で GND へ。U1 の PIN 13・11・9 (f9・f11・f13) は e 行、PIN 3・5
  (i10・i12) は j 行でまとめ、15 列で PIN 7 (i14) と結んで y 行へ下ろす。U2 の PIN 13・12・9・8
  (f21・f22・f25・f26) は e 行、PIN 5・6 (i24・i25) は j 行でまとめ、27 列で PIN 7 (i26) と
  結んで y 行へ下ろす。出力のピン (U1 の PIN 4・6・8・10・12、U2 の PIN 4・10・11) には
  何もつながない
- U2 の PIN 3 (AND の出力、i22) は黄の線で 22 列をまっすぐ下り、Rg (n22〜q22) の上端へ。
  Rg の下端 (q22) から Q1 のゲート (s22) へ下ろし、同じ q22 から q 行を左へ出して
  Rgpd (q20〜u20) を通して y 行の GND へ
- Q1 (2N7000) は s 行に S・G・D の順 (平らな面を見て左から、実物のピンの並び) で
  横並びに置く (s21・s22・s23)。ソースは 21 列を下って GND へ、ドレインは s 行を右へ運び、
  29 列を上って DLED のカソード (g29) へ。DLED のアノード (e29) は RLED (a29〜d29) を
  通して 5V の筋へ
- 交差は被覆線で跨ぐ。青 (U1 の PIN 2) が 15 列の GND を、Q1 のドレインの線が 27 列の
  GND を跨ぐ。どちらも U1・U2 の出力のピンが GND にまとめたピンの向こうにあるためで、
  ピンの並びからは避けられない。PIR のケーブルの GND と OUT は、ユニバーサル基板の上を 5V と VL の
  筋を越えて渡る

## 見るべき値

計算値。VCC5 = 5V (USB 電源)。電圧はテスターの直流電圧レンジで GND との間を測る。
暗い場所は CdS を手で覆って作る。

| 測る所 | 期待する値 |
| --- | --- |
| VL (ツェナー電圧) | 約3.3V (計算値) |
| ツェナー電流 | 約5.2mA ((5V−3.3V)/330Ω) |
| 明るい場所・人が動かない | LED 消灯 (40106 出力 L) |
| 暗い場所・人が動かない | LED 消灯 (4081 の PIR 側入力が L) |
| 暗い場所・人が動く | LED 点灯 (両方 H) |
| DLED の電流 | 約9.1mA ((5V−2.0V)/330Ω、赤色 LED、計算値) |

## 出典

自作。
