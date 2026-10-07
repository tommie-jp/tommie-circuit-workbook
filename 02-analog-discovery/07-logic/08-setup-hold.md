---
book: analog-discovery
chapter: 7
id: 7-8
title: セットアップ・ホールド時間を測る
tier: 100
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-8 セットアップ・ホールド時間を測る

D フリップフロップは、Clock が立ち上がる**前** (セットアップ時間) と**後**
(ホールド時間) の間、D の値を確定させておかないと正しく取り込めない。CD4013B
(CMOS の D フリップフロップ) に Pattern で Clock と Data を作って入れ、D の
確定を Clock の立ち上がりからどれだけ先行させれば正しく捕まるかを、Logic で
実際に確かめる。

## 回路図

```circuit
title: 図1 CD4013B に Pattern で Clock と Data を入れる
parts:
  AD:
    type: device
    at: 3,3.05
    label: Analog Discovery
    pins: [V+, DIO2, DIO0, DIO1, GND]
    turn: mirror
  VCC: vcc 4,2 3.3V
  G1: ground 4,5
  U1: dip14 10,4 CD4013B
  G2: ground 9,4 r90
  G3: ground 9,4.48 r90
  VCC: vcc 11,3 3.3V
  G5: ground 12,5
wires:
  - AD.V+ -| 4,2
  - AD.GND -| 4,5
  - AD.DIO2 -| 7,2.8
  - 7,2.8 |- U1.1
  - AD.DIO0 -| 6,3.05
  - 6,3.05 |- U1.3
  - AD.DIO1 -| 5,3.3
  - 5,3.3 |- U1.5
  - U1.4 -| 9,4
  - U1.6 -| 9,4.48
  - U1.7 -| 9,4.48
  - U1.14 -| 11,3
  - U1.11 -| 12,5
  - U1.10 -| 12,5
  - U1.9 -| 12,5
  - U1.8 -| 12,5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/08-setup-hold.svg)

- CD4013B (`U1`) は 2 系統の D フリップフロップ入り。使うのは 1 系統目
  (3=CLOCK1・5=D1・1=Q1) だけ。**14=VDD は 3.3 V** (DIO の H レベルと合わせる。
  7-2 の CD4017 と同じ理由 — VDD を 5 V にすると VIH (目安 70% VDD ≈ 3.5 V)
  に 3.3 V の H が届かない)。7=VSS は GND
- 4=RESET1・6=SET1 (使う系統の非同期入力) と、8=SET2・9=D2・10=RESET2・
  11=CLOCK2 (使わない 2 系統目の入力) は全部 GND に固定し、CMOS の入力を
  浮かせない
- 3=CLOCK1 に Pattern のクロック (DIO0)、5=D1 にデータ (DIO1) を入れ、1=Q1 を
  Logic (DIO2) で見る。2=Q1バー・12=Q2バー・13=Q2 (すべて出力) は未接続でよい

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip14 @ e5 CD4013B
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [DIO2, DIO0, DIO1, V+, GND]
wires:
  - AD.V+ -- +b13 red
  - AD.GND -- -b16 black
  - AD.DIO0 -- j7 yellow
  - AD.DIO1 -- j9 white
  - AD.DIO2 -- j5 gray
  - j8 -- -b8 black
  - j10 -- -b10 black
  - j11 -- -b11 black
  - a5 -- +t5 red
  - a8 -- -t8 black
  - a9 -- -t9 black
  - a10 -- -t10 black
  - a11 -- -t11 black
  - +t20 -- +b20 red
  - -t21 -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/08-setup-hold.svg)

- `dip14 @ e5` は 1=Q1 (f5) 〜 7=VSS (f11) が下ブロックを左から右へ、8=SET2
  (e11) 〜 14=VDD (e5) が上ブロックを右から左へ戻る
- 3=CLOCK1 (f7) に Pattern の DIO0、5=D1 (f9) に DIO1、1=Q1 (f5) に DIO2 を
  それぞれ空いた j 行から接続
- 4=RESET1 (f8)・6=SET1 (f10)・7=VSS (f11) は下ブロックなので j 行から -b へ。
  8=SET2 (e11)・9=D2 (e10)・10=RESET2 (e9)・11=CLOCK2 (e8) は上ブロックなので
  a 行から -t へ逃がし、20・21 列で上下のレールを渡す
- 14=VDD (e5) は a5 から +t5 へ。AD の V+ は下のレール (+b13) に直接入れてあるので、
  上下のレールをつなぐ橋 (`+t20 -- +b20`) を忘れない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | DIO0 = Clock (CLOCK1 用、1 kHz)。DIO1 = Custom (D1 用。Clock の立ち上がりの前後で 1 回だけ H⇄L を切り替える波形を、サンプルレート 100 MHz (10 ns 刻み) で描く) |
| Logic | DIO0〜DIO2 を Enable。Rate は Pattern と同じ 100 MHz (10 ns 刻み) にしてカーソルで時間差を読む。100 MHz は AD3 のシステムクロックの既定値で、DIO の最大は 125 MS/s (50〜125 MHz で調整可) |

Pattern と Logic は同じマスタークロックを共有するので、Data の遷移を Clock の
立ち上がりから何サンプルずらすかで、setup の時間を 10 ns 刻みで自由に作れる。

Data を Clock の立ち上がりの 100 ns 前に切り替えた所を、理想の角で描くと次のようになる。

```scope
title: 図3 Data (CH2) が Clock (CH1) より 100 ns 先に変わる
time: 50ns/div
trigger: ch1 rising 1.65V
ch1: {wave: = 3.3V * step(t), range: 1V/div, position: 0.5div}
ch2: {wave: = 3.3V * step(t + 100ns), range: 1V/div, position: -3.5div}
cursors: [-100ns, 0]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/08-setup-hold.svg)

2 本を同じ 1 V/div で上下に分けて並べた。

## 見るべき値

CD4013B のデータシート (Recommended Operating Conditions) の最小セットアップ
時間は VDD = 5 V で 40 ns、VDD = 10 V で 20 ns、VDD = 15 V で 15 ns — 電圧が
低いほど長く必要になる。**3.3 V の行は無く、3.3 V では 5 V の 40 ns より長く
要る** (5 V → 10 V で半分になる傾きから見て、数十 ns〜100 ns ほどと見ておく。目安)。
最小ホールド時間は電圧によらず 2〜5 ns (Electrical Characteristics: Dynamic の値) と
とても短い。

| Data が Clock の立ち上がりより先行する時間 | Q1 の様子 | 分かること |
| --- | --- | --- |
| 1000 ns | 確実に新しい D の値を捕まえる | 3.3 V でも十分な余裕 |
| 100 ns | ほぼ捕まえる | 3.3 V での必要時間の目安の上の端。ここから危うくなり始める |
| 40 ns (5 V のデータシートの最小値) | 取りこぼすことがある | 5 V なら境目だが、3.3 V では足りない |
| 10 ns | 古い値のまま、あるいは不安定になる (予想。毎回同じとは限らない) | セットアップ違反 — D が確定する前に Clock が来て、正しく取り込めない |

Pattern の遅れを 10 ns 刻みで縮めていき、取りこぼし始める時間を測ると、この個体の
3.3 V でのセットアップ時間が分かる。

**ホールド側は最小 2〜5 ns しかいらないので、Pattern の 10 ns 刻みでは意図して
破るのが難しい。** 実務でホールド違反が問題になるのは、配線が長い・クロックの
遅延がばらつく高速な回路が中心で、この程度の低速な CMOS ロジックではめったに
起きない。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
セットアップ・ホールド時間の規格値は Texas Instruments の CD4013B データシート
(Recommended Operating Conditions / Electrical Characteristics: Dynamic) による。
