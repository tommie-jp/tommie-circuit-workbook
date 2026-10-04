---
book: circuits
chapter: 12
id: 12-1
title: おやすみタイマー — 555 単安定 + MOSFET
tier: 50
source: 自作
board: [BB, PF]
---

# 12-1 おやすみタイマー — 555 単安定 + MOSFET

555 の単安定 (3-3) と MOSFET スイッチ (2-5) を組み合わせた実用回路。ボタンを
押すと常夜灯の LED が点き、約 19 分後に自動で消える。寝る前に押しておけば、
読書灯として使って自然に消灯する「おやすみタイマー」になる。

## 回路図

```circuit
title: 図1 555単安定(CMOS版)でMOSFETを約19分だけON
parts:
  VCC: vcc b5
  U1: ic g8 TLC555
  Gu1: ground i8
  Rt: resistor b5 d5 4.7M
  Ct: capacitor g5 h5 220u
  Get: ground h5
  VCC: vcc g3
  Rtrig: resistor g3 i3 100k
  SWtrig: button i3 k3
  Gtrig: ground k3
  Rg: resistor g10 g12 220
  Q1: nmos-e f13i0i0
  Gq1: ground h13
  VCC: vcc b13
  RLED: resistor b13 d13 470
  DLED: led d13 e13 red
wires:
  - b5 -- b8 -- b8a5
  - U1.VDD |- b8
  - U1.RESET |- b8a5
  - d5 -- f5f0
  - U1.DISCH -| f5f0
  - U1.THRES -| g5
  - f5f0 -- g5
  - U1.TRIG -| g6f0
  - g6f0 -- i6 -- i3
  - U1.GND |- i8
  - U1.OUT -| g10
  - g12 |- Q1.G
  - e13 -- Q1.D
  - Q1.S -- h13
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/01-goodnight-timer.svg)

- U1.2 (TRIG) は Rtrig (100kΩ) で常時 H。SWtrig を押した瞬間だけ L になり、
  単安定が始まる
- U1.6・7 (THR・DISCH) と Rt (4.7MΩ)・Ct (220µF) が時定数を決める:
  T = 1.1×Rt×Ct **≈ 1137秒 (約19分、計算値)**
- **U1 は普通の (バイポーラ) NE555 ではなく CMOS 版 (TLC555) を使う。**
  Rt が大きいと、THR・TRIG 入力に流れ込むわずかな電流 (入力バイアス電流) も
  無視できなくなる。バイポーラの NE555 は数百 nA 流れることがあり、4.7MΩ
  では電圧の誤差になるが、CMOS 版は pA オーダーで無視できる
- **電解コンデンサ自身の漏れ電流にも注意。** Rt を流れる充電電流は
  5V/4.7MΩ ≈ 1.06µA しかない。コンデンサの漏れがこれに近づくと、C は 2/3 Vcc に
  なかなか届かず、時間が延びる。漏れがこれを超えると**タイマーが終わらない**。
  データシートの漏れの上限 0.01×C×V (V は定格電圧、電圧をかけて 2 分後) は
  220µF・25V 品で 55µA もあるが、これは定格の電圧をかけた直後の上限。
  定格に余裕のある品 (25V 以上) を 5V で使い、しばらく電圧をかけておくと、
  実際の漏れは 1µA を大きく下回るのがふつう (**目安**)。そこで
  **定格 25V 以上の電解コンデンサか、低漏れ (低リーク) 品を使い、組んだら数分
  電圧をかけてから使う**。容量を 10 倍にすると漏れもおよそ 10 倍になるので、
  時間は C より Rt で稼ぎ、C は 220µF に留める
- U1.3 (OUT) が単安定の間 H になり、Rg (220Ω) を通して Q1 (2N7000) のゲートを
  駆動する。Q1 が ON の間、DLED (常夜灯) が点く
- U1.4 (RESET) は U1.8 (VCC) にそのまま結んで無効化 (常に動作可能にする)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  U1: dip8 @ e10 TLC555
  Rtrig: resistor b2 b5 100k
  SWtrig: button @ e3
  Rt: resistor b15 b12 4.7M
  Ct: capacitor/electrolytic c11 c8 220u
  Rg: resistor g46 g41 220
  Q1: transistor b40(S) b41(G) b42(D) 2N7000
  RLED: resistor b52 b49 470
  DLED: led c49(A) c46(K) red
wires:
  - -t62 -- -b62 black
  - +t63 -- +b63 red
  - a10 -- +t10 red
  - j10 -- -b10 black
  - j13 -- +b13 red
  - a11 -- a12 orange
  - a15 -- +t15 red
  - a8 -- -t8 black
  - h11 -- h6 orange
  - g6 -- d6 orange
  - c6 -- c5 orange
  - a2 -- +t2 red
  - j3 -- -b3 black
  - i12 -- i46 blue
  - e41 -- f41 blue
  - e40 -- f40 black
  - j40 -- -b40 black
  - e42 -- e46 green
  - a52 -- +t52 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/breadboard/01-goodnight-timer.svg)

- 上下のレールは右端 (62・63 列) の線でつなぐ。U1 (e10) の PIN 8 (10 列の上) と
  PIN 4 (13 列の下) を + レール、PIN 1 (10 列の下) を下の − レール (GND) へ
- PIN 2 (TRIG、11 列の下) はオレンジの線で 6 列を通って上ブロックの 5 列へ上げる。
  そこで Rtrig が + レールへプルアップし、SWtrig (e3) を押すと下の − レールへ落ちる
- PIN 6・7 (THR・DISCH、12 列・11 列の上) は a 行で結ぶ。Rt (4.7MΩ) は 12 列から
  赤い + レールへ、Ct (220µF) は 11 列から 8 列の − レールへ。ここが時定数ノード
- PIN 3 (OUT、12 列の下) は青の線 (i 行) で 46 列へ運び、Rg を通して Q1 のゲート
  (41 列) へ。Q1 は上ブロック (40〜42 列の b 行) に挿し、足は e 行から溝をまたぐ
  短い線で下へ (S は 40 列から GND、G は 41 列で Rg)。D (42 列) は緑の線で 46 列へ
  渡し、DLED (常夜灯) のカソードへ (アノードは RLED を通して + レール)。
  2N7000 は**平らな面を見て左から S・G・D** (2-5 と同じ)
- 1 つの穴には足か線を 1 本だけ挿す (部品の足のある列へは、同じ列の空いた穴から線を出す)

## ユニバーサル基板に組む

作品として仕上げるので、perfboard にも同じ回路を組む。

```perfboard
board:
  size: 22x14
  slots: on
title: 図3 perfboardに組む (部品面から見た図)
points:
  VCC: a1
  GND: n1
parts:
  U1: dip8 e5 TLC555
  Rtrig: resistor a2 d2 100k
  SWtrig: button j2
  Rt: resistor a7 d7 4.7M
  Ct: capacitor/electrolytic d21 f21 220u
  Rg: resistor i12 i16 220
  Q1: transistor k15 k16 k17 2N7000
  RLED: resistor e18 g18 470
  DLED: led h18 j18 red
wires:
  # 電源 (上の a 行) と GND (下の n 行) の筋
  - VCC -- a2 red
  - a2 -- a5 red
  - a5 -- a7 red
  - a7 -- a10 red
  - GND -- n2 black
  - n2 -- n5 black
  - n5 -- n13 black
  - n13 -- n21 black
  # U1 の電源: PIN 8 (VDD) は上へ、PIN 1 (GND) は下へ
  - e5 -- a5 red
  - h5 -- n5 black
  # PIN 4 (RESET) は 10 列を上って VCC へ。途中の e10 から出力段へも配る
  - h8 -- h10 red
  - h10 -- e10 red
  - e10 -- a10 red
  - e10 -- e18 red
  # TRIG (PIN 2): Rtrig で VCC へ、SWtrig で GND へ
  - d2 -- j2 yellow
  - l2 -- n2 black
  - h6 -- j6 yellow
  - j6 -- j4 yellow
  # THRES・DISCH (PIN 6・7): Rt で VCC へ、Ct で GND へ
  - e6 -- d6 orange
  - d6 -- d7 orange
  - e7 -- d7 orange
  - d7 -- d21 orange
  - f21 -- n21 black
  # OUT (PIN 3) → Rg → Q1 のゲート。Q1 のドレイン → DLED → RLED → VCC
  - h7 -- i7
  - i7 -- i12
  - i16 -- k16
  - g18 -- h18
  - j18 -- k18
  - k18 -- k17
  - k15 -- k13 black
  - k13 -- n13 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/01-goodnight-timer.svg)

- 部品面から見た図。電源は上の a 行 (赤)、GND は下の n 行 (黒) に 1 本ずつ筋を通し、
  左端の a1・n1 に電源をつなぐ。部品はこの 2 本の筋から縦に配る
- U1 (e5、DIP8) は切り欠きを左にして挿す。上の列が左から PIN 8 (VDD)・7 (DISCH)・
  6 (THRES)・5 (CONT) で e5〜e8、下の列が左から PIN 1 (GND)・2 (TRIG)・3 (OUT)・
  4 (RESET) で h5〜h8。PIN 8 は 5 列を上って a 行へ、PIN 1 は 5 列を下って n 行へ
- PIN 4 (RESET) は h 行で 10 列へ出て、10 列を上って a 行 (VCC) へ。その途中の e10 から
  e 行を右へ出して、出力段の RLED へ VCC を配る。**PIN 5 (CONT) はどこにもつなげていない**
  — 単安定の動作には必須ではなく、浮かせたままでも動く (つなぐならここに 0.01µF を
  GND へ)
- PIN 2 (TRIG、黄) は h6 から j 行を左へ運んで SWtrig (j2) へ。SWtrig の下の足は l2 から
  n 行の GND へ、上の足 j2 は 2 列を上って Rtrig (a2〜d2) で a 行の VCC へプルアップする
- PIN 6・7 (THRES・DISCH、橙) はそれぞれ d 行へ上げて d6〜d7 で結び、Rt (a7〜d7) で VCC へ。
  同じ d7 から d 行を右へ運んで Ct (d21、+ が上) へ、Ct の − は 21 列を下って GND へ
- PIN 3 (OUT) は i 行で Rg (i12〜i16) へ、Rg から 16 列を下って Q1 のゲート (k16) へ。
  Q1 (2N7000) は平らな面を見て左から S・G・D なので、k15 がソース、k16 がゲート、
  k17 がドレイン。ソースは 13 列を下って GND へ、ドレインは k18 から 18 列を上って
  DLED のカソード (j18) へ。DLED のアノード (h18) は RLED (e18〜g18) を通して e 行の VCC へ
- **交差は 2 か所で、どちらも被覆線で跨ぐ**: 橙の d 行 (Ct へ) が 10 列の赤 (RESET) を、
  黄の j 行 (TRIG) が 5 列の黒 (U1 の GND) を跨ぐ。この回路は足の並びから交差を
  0 にはできない (PIN 4 の VCC と、PIN 6・7 から Ct への GND が U1 の右で必ず出会う)

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| SWtrig を押した直後の U1.3 (OUT) | H (約5V。TLC555 は CMOS 出力で、ゲートしか駆動しないので Vcc とほぼ同じ) に変わり、DLED が点く |
| 点灯している時間 | T = 1.1×4.7MΩ×220µF **≈ 1137秒 (約19分、計算値)** |
| DLED の電流 | 約6.4mA ((5V−2.0V)/470Ω、赤色 LED、計算値) |
| 19分後の U1.3 | L (0V) に戻り、DLED が消える |

Ct (220µF) を 100µF に替えると T ≈ 8.6分になる (計算値)。電解コンデンサの
容量誤差は ±20% ほどあり、漏れでも延びるので、実際の時間は目安。

**30 分たっても LED が消えないとき**は、漏れが充電電流に勝っている。Rt を
2.2MΩ に下げる (充電電流 約2.3µA、T ≈ 9分) と余裕ができる。40 分ほどの長い
時間が要るなら、単安定で粘らず、555 の発振を 4040 などのカウンタで数える形
(10-4) にするほうが確実。

## 出典

自作。
