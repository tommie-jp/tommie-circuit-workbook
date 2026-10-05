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
  silk: board
  slots: on
title: 図2 perfboardに組む (部品面から見た図)
points:
  PWR: a26
  GND: a2
parts:
  PIR:
    type: device
    at: p31
    label: PIR
    pins: GND VCC OUT
  Rz: resistor b26 b23 330
  Dz: zener c21 c23 3V3
  CDS1: photoresistor e23 e21
  R1: resistor e18 e15 10k
  U1: dip14 h21 CD40106
  U2: dip14 t21 CD4081
  Rg: resistor v13 v10 220
  Rgpd: resistor t10 t6 100k
  Q1: transistor u8 v8 w8 2N7000
  RLED: resistor ac26 ac23 330
  DLED: led ac22 ac20 red
wires:
  # 5V (26 行・赤)、VL 3.3V (23 行・橙)、GND (2 行・黒) の筋
  - PWR -- b26 red
  - b26 -- q26 red
  - q26 -- ac26 red
  - b23 -- c23 orange
  - c23 -- e23 orange
  - e23 -- h23 orange
  - h23 -- t23 orange
  - GND -- c2 black
  - c2 -- e2 black
  - e2 -- o2 black
  - o2 -- t2 black
  - t2 -- u2 black
  - u2 -- aa2 black
  # Dz のアノードと R1 の下端を GND へ
  - c21 -- c2 black
  - e15 -- e2 black
  # 暗さの分圧 (CDS1・R1) を U1 の PIN 1 へ
  - e21 -- e18
  - e18 -- h18
  # U1・U2 の PIN 14 (VDD) を VL へ
  - h21 -- h23 orange
  - t21 -- t23 orange
  # U1 (40106) の使わない入力: PIN 13・11・9 は 22 行、PIN 3・5 は 17 行でまとめ、O 列で PIN 7 と結んで GND へ
  - i21 -- i22 black
  - i22 -- k22 black
  - k21 -- k22 black
  - k22 -- m22 black
  - m21 -- m22 black
  - m22 -- o22 black
  - o22 -- o17 black
  - j18 -- j17 black
  - j17 -- l17 black
  - l18 -- l17 black
  - l17 -- n17 black
  - n18 -- n17 black
  - n17 -- o17 black
  - o17 -- o2 black
  # U2 (4081) の使わない入力: PIN 13・12・9・8 は 22 行、PIN 5・6 は 17 行でまとめ、AA 列で PIN 7 と結んで GND へ
  - u21 -- u22 black
  - u22 -- v22 black
  - v21 -- v22 black
  - v22 -- y22 black
  - y21 -- y22 black
  - y22 -- z22 black
  - z21 -- z22 black
  - z22 -- aa22 black
  - aa22 -- aa17 black
  - x18 -- x17 black
  - x17 -- y17 black
  - y18 -- y17 black
  - y17 -- z17 black
  - z18 -- z17 black
  - z17 -- aa17 black
  - aa17 -- aa2 black
  # PIR: VCC は 5V の筋へ、GND は U1 の GND の角 (e15) へ、OUT は U2 の PIN 1 へ
  - PIR.VCC -- q26 red
  - PIR.GND -- p22 black
  - p22 -- o22 black
  - PIR.OUT -- r16 green
  - r16 -- t16 green
  - t16 -- t18 green
  # U1 の PIN 2 (暗いと H) → U2 の PIN 2
  - i18 -- i15 blue
  - i15 -- u15 blue
  - u15 -- u18 blue
  # U2 の PIN 3 (AND の出力) → Rg → Q1 のゲート。Rgpd でゲートを GND へ
  - v18 -- v13 yellow
  - v10 -- v8
  - v10 -- t10
  - t6 -- t2 black
  # Q1: ソースは GND へ、ドレインは DLED のカソードへ
  - u8 -- u2 black
  - w8 -- ac8
  - ac8 -- ac20
  - ac23 -- ac22
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/02-motion-light.svg)

- ユニバーサル基板は 7×9cm のユニバーサル基板を横に置いた 31 列 × 26 行 (厚み 1.6mm の FR-4)。5×7cm のユニバーサル基板 (24 列 × 18 行) には
  DIP14 2 個と出力の段が横に並びきらないので、次の順位の 7×9cm にした。出力の段 (Rg・Rgpd・Q1) は
  U2 の下に置いて、ユニバーサル基板の幅に収めた
- 部品面から見た図。5V (PWR) は上の 26 行 (赤)、VL (3.3V) は 23 行 (橙)、GND は下の
  2 行 (黒) に 1 本ずつ筋を通し、部品はそこから縦に配る。電源は左端の a26・a2 に入れる
- Rz (b26〜b23) が 5V の筋から VL の筋へ、Dz (c23〜c21、カソードが上) が VL から C 列を
  下って GND へ。これで VL (3.3V) ができ、23 行で U1・U2 の PIN 14 (h21・t21) と
  CDS1 (e23〜e21) へ配る。CDS1 の下端から E 列を下り、e18 で R1 (e18〜e15、下は GND) と
  U1 の PIN 1 (h18) へ分ける
- DIP14 は「アンカーの行に PIN 14〜8、その 3 行下に PIN 1〜7」の並び (perfboard の
  DIP の決め方)。U1 (h21 アンカー) は PIN 14=h21、PIN 8=n21、PIN 1=h18、PIN 7=n18。
  U2 (t21 アンカー) は PIN 14=t21、PIN 8=z21、PIN 1=t18、PIN 7=z18
- U1 の PIN 2 (暗いと H、i18) は青の線で 15 行を右へ運び、U 列を上って U2 の PIN 2 (u18) へ。
  PIR の OUT (緑) は r16 に下ろし、16 行と T 列で U2 の PIN 1 (t18) へ
- PIR はユニバーサル基板の外 (上、`-p23`) に置き、ケーブルの 3 本を真下の穴へ下ろす:
  GND は p22 (U1 の GND をまとめた角 o22 の隣)、VCC は q26 (5V の筋)、OUT は r16
- 使わない入力は黒の線で GND へ。U1 の PIN 13・11・9 (i21・k21・m21) は 22 行、PIN 3・5
  (j18・l18) は 17 行でまとめ、O 列で PIN 7 (n18) と結んで 2 行へ下ろす。U2 の PIN 13・12・9・8
  (u21・v21・y21・z21) は 22 行、PIN 5・6 (x18・y18) は 17 行でまとめ、AA 列で PIN 7 (z18) と
  結んで 2 行へ下ろす。出力のピン (U1 の PIN 4・6・8・10・12、U2 の PIN 4・10・11) には
  何もつながない
- U2 の PIN 3 (AND の出力、v18) は黄の線で V 列をまっすぐ下り、Rg (v13〜v10) の上端へ。
  Rg の下端 (v10) から Q1 のゲート (v8) へ下ろし、同じ v10 から 10 行を左へ出して
  Rgpd (t10〜t6) を通して 2 行の GND へ
- Q1 (2N7000) は 8 行に S・G・D の順 (平らな面を見て左から、実物のピンの並び) で
  横並びに置く (u8・v8・w8)。ソースは U 列を下って GND へ、ドレインは 8 行を右へ運び、
  AC 列を上って DLED のカソード (ac20) へ。DLED のアノード (ac22) は RLED (ac26〜ac23) を
  通して 5V の筋へ
- 交差は被覆線で跨ぐ。青 (U1 の PIN 2) が O 列の GND を、Q1 のドレインの線が AA 列の
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
