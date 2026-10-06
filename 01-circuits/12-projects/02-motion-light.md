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
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  slots: on
title: 図2 perfboardに組む (部品面から見た図)
unused: [U1.H, U1.I, U1.J, U1.K, U1.L, U2.K, U2.L, U2.M]
points:
  PWR: a18
  GND: a1
parts:
  PIR:
    type: device
    at: l23
    label: PIR
    pins: GND VCC OUT
  Rz: resistor a18 a15 330
  Dz: zener b13 b15 3V3
  CDS1: photoresistor d15 d13
  R1: resistor d10 d7 10k
  U1: dip14 f13 CD40106
  U2: dip14 o13 CD4081
  Rg: resistor q9 q6 220
  Rgpd: resistor o6 o3 100k
  Q1: transistor s4 s5 s6 2N7000
  RLED: resistor w18 w15 330
  DLED: led w14 w12 red
wires:
  # 5V (18 行・赤)、VL 3.3V (15 行・橙)、GND (1 行・黒) の筋
  - PWR -- m18 red
  - m18 -- w18 red
  - a15 -- b15 orange
  - b15 -- d15 orange
  - d15 -- f15 orange
  - f15 -- o15 orange
  - GND -- b1 black
  - b1 -- d1 black
  - d1 -- m1 black
  - m1 -- o1 black
  - o1 -- u1 black
  - u1 -- v1 black
  # Dz のアノードと R1 の下端を GND へ
  - b13 -- b1 black
  - d7 -- d1 black
  # 暗さの分圧 (CDS1・R1) を U1 の PIN 1 へ
  - d13 -- d10
  - d10 -- f10
  # U1・U2 の PIN 14 (VDD) を VL へ
  - f15 -- f13 orange
  - o15 -- o13 orange
  # U1 (40106) の使わない入力: 上の列の PIN 13・11・9 は 14 行、下の列の PIN 3・5 は 9 行でまとめ、PIN 7 と結んで m 列から GND へ
  - g13 -- g14 black
  - i13 -- i14 black
  - k13 -- k14 black
  - g14 -- i14 black
  - i14 -- k14 black
  - k14 -- l14 black
  - l14 -- m14 black
  - m14 -- m9 black
  - h10 -- h9 black
  - j10 -- j9 black
  - l10 -- l9 black
  - h9 -- j9 black
  - j9 -- l9 black
  - l9 -- m9 black
  - m9 -- m1 black
  # U2 (4081) の使わない入力: 上の列の PIN 13・12・9・8 は 14 行、下の列の PIN 5・6 は 9 行でまとめ、PIN 7 と結んで v 列から GND へ
  - p13 -- p14 black
  - q13 -- q14 black
  - t13 -- t14 black
  - u13 -- u14 black
  - p14 -- q14 black
  - q14 -- t14 black
  - t14 -- u14 black
  - u14 -- v14 black
  - v14 -- v9 black
  - s10 -- s9 black
  - t10 -- t9 black
  - u10 -- u9 black
  - s9 -- t9 black
  - t9 -- u9 black
  - u9 -- v9 black
  - v9 -- v1 black
  # PIR: VCC は 5V の筋へ、GND は U1 の GND の筋 (l14) へ、OUT は U2 の PIN 1 へ
  - PIR.VCC -- m18 red
  - PIR.GND -- l14 black
  - PIR.OUT -- n10 green
  - n10 -- o10 green
  # U1 の PIN 2 (暗いと H) → U2 の PIN 2
  - g10 -- g8 blue
  - g8 -- p8 blue
  - p8 -- p10 blue
  # U2 の PIN 3 (AND の出力) → Rg → Q1 のゲート。Rgpd でゲートを GND へ
  - q10 -- q9 yellow
  - q6 -- q5
  - q5 -- s5
  - q6 -- o6
  - o3 -- o1 black
  # Q1: ソースは GND へ、ドレインは DLED のカソードへ
  - s4 -- u4 black
  - u4 -- u1 black
  - s6 -- w6
  - w6 -- w12
  - w15 -- w14
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/02-motion-light.svg)

- ユニバーサル基板は 5×7cm のユニバーサル基板を横に置いた 24 列 × 18 行 (縁のパッド付き、厚み 1.6mm の
  FR-4)。番地は基板の刷りどおりで、英字が列 (左から A〜X)、数字が行 (下から 1〜18)。DIP14 を縦に
  並べずに 2 個とも横のまま並べ、使わない入力をまとめる線を DIP の上 (14 行) と下 (9 行) に置いて、
  GND へ下りる線を U1 と U2 の右隣の 1 列ずつ (M 列・V 列) に絞ったので、5×7cm に収まった。
  出力の段 (Rg・Rgpd・Q1) は U2 の下に置いた
- 部品面から見た図。5V (PWR) は上の 18 行 (赤)、VL (3.3V) は 15 行 (橙)、GND は下の
  1 行 (黒) に 1 本ずつ筋を通し、部品はそこから縦に配る。電源は左端の a18・a1 に入れる
- Rz (a18〜a15) が 5V の筋から VL の筋へ、Dz (b13〜b15、カソードが上) が VL から B 列を
  下って GND へ。これで VL (3.3V) ができ、15 行で U1・U2 の PIN 14 (f13・o13) と
  CDS1 (d15〜d13) へ配る。CDS1 の下端 d13 から D 列を下り、d10 で R1 (d10〜d7、下は GND) と
  U1 の PIN 1 (f10) へ分ける
- DIP14 は「アンカーの行に PIN 14〜8、その 3 行下に PIN 1〜7」の並び (perfboard の
  DIP の決め方)。U1 (f13 アンカー) は PIN 14=f13、PIN 8=l13、PIN 1=f10、PIN 7=l10。
  U2 (o13 アンカー) は PIN 14=o13、PIN 8=u13、PIN 1=o10、PIN 7=u10
- U1 の PIN 2 (暗いと H、g10) は青の線で 8 行を右へ運び、P 列を上って U2 の PIN 2 (p10) へ。
  PIR の OUT (緑) は n10 に下ろし、隣の o10 で U2 の PIN 1 へ
- PIR はユニバーサル基板の外 (上、`l23`) に置き、ケーブルの 3 本を真下の穴へ下ろす:
  GND は l14 (U1 の使わない入力をまとめた 14 行の筋)、VCC は m18 (5V の筋)、OUT は n10
- 使わない入力は黒の線で GND へ。U1 の PIN 13・11・9 (g13・i13・k13) は 14 行、PIN 3・5
  (h10・j10) と PIN 7 (l10) は 9 行でまとめ、14 行の右端 (m14) と 9 行の右端 (m9) を M 列で
  つないで 1 行へ下ろす。U2 の PIN 13・12・9・8 (p13・q13・t13・u13) は 14 行、PIN 5・6
  (s10・t10) と PIN 7 (u10) は 9 行でまとめ、V 列で 1 行へ下ろす。出力のピン (U1 の PIN 4・6・8・
  10・12、U2 の PIN 4・10・11) には何もつながない (意図して使わないピンなので `unused:` に並べた)
- U2 の PIN 3 (AND の出力、q10) は黄の線で Rg (q9〜q6) の上端へ。Rg の下端 (q6) から
  Q1 のゲート (s5) へ 5 行を右へ運び、同じ q6 から 6 行を左へ出して Rgpd (o6〜o3) を通して
  1 行の GND へ
- Q1 (2N7000) は S・G・D を縦に並べて置く (s4・s5・s6、下から S・G・D)。ソースは 4 行を右へ出し、
  U 列を下って GND へ、ドレインは 6 行を右へ運び、W 列を上って DLED のカソード (w12) へ。DLED の
  アノード (w14) は RLED (w18〜w15) を通して 5V の筋へ
  ※ **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- 交差は被覆線で跨ぐ。6 か所。(1) 青 (U1 の PIN 2) が M 列の GND を跨ぐ。(2) Q1 のドレインの線が
  V 列の GND を跨ぐ。(3) (4) PIR の GND (黒) が 18 行の 5V と 15 行の VL の筋を跨ぐ。(5) (6) PIR の
  OUT (緑) も同じ 2 本の筋を跨ぐ。(1)(2) は U1・U2 の使わない入力を GND へ集める線が出力の
  ピンの向こう側にあるため、(3)〜(6) は PIR のケーブルが上から基板の中ほどへ下りるため
  で、ピンの並びと PIR の置き場からは避けられない

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
