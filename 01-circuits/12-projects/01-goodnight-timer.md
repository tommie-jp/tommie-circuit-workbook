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

555 の単安定 (3-3。トリガが来ると決まった時間だけ出力を H にする使い方) と
MOSFET スイッチ (2-5) を組み合わせた実用回路。ボタンを押すと常夜灯の LED が点き、
約 19 分後に自動で消える。寝る前に押しておけば、読書灯として使って自然に消灯する
「おやすみタイマー」になる。第 12 章は、これまでの章の回路を組み合わせて作品にする章で、
ブレッドボードで確かめたあと、ユニバーサル基板に半田付けして残す。

## 回路図

```circuit
title: 図1 555単安定(CMOS版)でMOSFETを約19分だけON
parts:
  VCC: vcc b5 5V
  U1: ic g8 TLC555
  Gu1: ground i8
  Rt: resistor b5 d5 4.7M
  Ct: capacitor g5 h5 220u
  Get: ground h5
  VCC: vcc g3 5V
  Rtrig: resistor g3 i3 100k l=$R_\mathrm{trig}$
  SWtrig: button i3 k3 l=$\mathrm{SW_{trig}}$
  Gtrig: ground k3
  Rg: resistor g10 g12 220
  Q1: nmos-e f13i0i0
  Gq1: ground h13
  VCC: vcc b13 5V
  RLED: resistor b13 d13 470 l=$R_\mathrm{LED}$
  DLED: led d13 e13 red l=$D_\mathrm{LED}$
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

- U1 の PIN 2 (TRIG) は Rtrig (100kΩ) で普段は H。SWtrig を押した瞬間に L になり、
  単安定が始まる
- PIN 6・7 (THRES・DISCH) につながる Rt (4.7MΩ)・Ct (220µF) が時間を決める:
  T = 1.1 × Rt × Ct = 1.1 × 4.7MΩ × 220µF ≈ 1137 秒 (約 19 分、計算値)
- U1 は普通の (バイポーラ) NE555 ではなく、CMOS 版の TLC555 を使う。
  Rt が大きいと、THRES・TRIG の入力に流れ込むわずかな電流 (入力バイアス電流) も
  無視できなくなる。バイポーラの NE555 は数百 nA 流れることがあり、4.7MΩ
  では電圧の誤差になる。CMOS 版は pA (nA の 1/1000) の桁で無視できる
- 電解コンデンサ自身の漏れ電流 (直流を少しずつ通してしまう電流) にも注意する。
  Rt を流れる充電電流は 5V / 4.7MΩ ≈ 1.06µA しかない。漏れがこれに近づくと、
  Ct は電源電圧の 2/3 (555 が止まる電圧) になかなか届かず、時間が延びる。
  漏れがこれを超えるとタイマーが終わらない
- データシートの漏れの上限 0.01 × C × V (V は定格電圧、電圧をかけて 2 分後) は、
  220µF・25V 品で 0.01 × 220 × 25 = 55µA にもなる。ただしこれは定格の電圧をかけた
  ときの上限。定格に余裕のある品 (25V 以上) を 5V で使い、しばらく電圧をかけておくと、
  実際の漏れは 1µA を大きく下回るのがふつう (目安)。そこで、定格 25V 以上の
  電解コンデンサか低漏れ (低リーク) 品を使い、組んだら数分電圧をかけてから使う。
  容量を 10 倍にすると漏れもおよそ 10 倍になるので、時間は C より Rt で稼ぎ、
  C は 220µF に留める
- PIN 3 (OUT) は単安定の間 H になり、Rg (220Ω) を通して Q1 (2N7000) のゲートを
  駆動する。Q1 が ON の間、DLED (常夜灯) が点く
- PIN 4 (RESET) は PIN 8 (VDD) にそのまま結んで無効にする (いつでも動ける状態にする)

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
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V / Scope 1
    pins: [V+, GND, 1+, 1-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope 2
    pins: [2+, 2-]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t1 black
  - PS.1+ -- d11 yellow
  - SC.2+ -- j12 blue
  - PS.1- -- -t3 black
  - SC.2- -- -b21 black
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
- PIN 6・7 (THRES・DISCH、12 列・11 列の上) は a 行で結ぶ。Rt (4.7MΩ) は 12 列から
  赤い + レールへ、Ct (220µF) は 11 列から 8 列の − レールへ。ここが時定数ノード
- PIN 3 (OUT、12 列の下) は青の線 (i 行) で 46 列へ運び、Rg を通して Q1 のゲート
  (41 列) へ。Q1 は上ブロック (40〜42 列の b 行) に挿し、ピンは e 行から溝をまたぐ
  短い線で下へ (S は 40 列から GND、G は 41 列で Rg)。D (42 列) は緑の線で 46 列へ
  渡し、DLED (常夜灯) のカソードへ (アノードは RLED を通して + レール)。
  2N7000 は平らな面を見て左から S・G・D (2-5 と同じ)
  ※ **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- 1 つの穴にはピンか線を 1 本だけ挿す (部品のピンのある列へは、同じ列の空いた穴から線を出す)
- 電源は Analog Discovery 3 (AD3、0-3 で使った USB 計測器) の Supplies で、V+ を 5V にして上の赤レール (1 列)、
  GND を上の青レール (1 列の下) へ。AD3 のオシロ (Scope) は 2 つの点を見る。1+ を Ct と THRES・DISCH の列 (11 列、`d11`) に、
  2+ を OUT の列 (12 列の下、`j12`) に挿し、1− と 2− (黒) は − レール (GND) へ。図2 では同じ AD3 を 2 つの箱 (上と下) に描いた。
  ブレッドボードを流れる電流は DLED の約 6.4mA に TLC555 の数百 µA を足した 7mA ほどで、ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) にも、
  AD3 の V+ を USB 給電で使うときの目安 (5V で 50mA) にも収まる

## ユニバーサル基板に組む

作品として仕上げるので、perfboard にも同じ回路を組む。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図3 perfboardに組む (部品面から見た図)
unused: [U1.CONT]
points:
  VCC: a18
  GND: a5
parts:
  U1: dip8 e14 TLC555
  Rtrig: resistor b18 b15 100k
  SWtrig: button b9
  Rt: resistor g18 g15 4.7M
  Ct: capacitor/electrolytic u15 u13 220u
  Rg: resistor l10 p10 220
  Q1: transistor o8 p8 q8 2N7000
  RLED: resistor r14 r12 470
  DLED: led r11 r9 red
wires:
  # 電源 (上の 18 行) と GND (下の 5 行) の筋
  - VCC -- b18 red
  - b18 -- e18 red
  - e18 -- g18 red
  - g18 -- j18 red
  - GND -- b5 black
  - b5 -- e5 black
  - e5 -- m5 black
  - m5 -- u5 black
  # U1 の電源: PIN 8 (VDD) は上へ、PIN 1 (GND) は下へ
  - e14 -- e18 red
  - e11 -- e5 black
  # PIN 4 (RESET) は J 列を上って VCC へ。途中の j14 から出力段へも配る
  - h11 -- j11 red
  - j11 -- j14 red
  - j14 -- j18 red
  - j14 -- r14 red
  # TRIG (PIN 2): Rtrig で VCC へ、SWtrig で GND へ
  - b15 -- b9 yellow
  - b7 -- b5 black
  - f11 -- f9 yellow
  - f9 -- d9 yellow
  # THRES・DISCH (PIN 6・7): Rt で VCC へ、Ct で GND へ
  - f14 -- f15 orange
  - f15 -- g15 orange
  - g14 -- g15 orange
  - g15 -- u15 orange
  - u13 -- u5 black
  # OUT (PIN 3) → Rg → Q1 のゲート。Q1 のドレイン → DLED → RLED → VCC
  - g11 -- g10
  - g10 -- l10
  - p10 -- p8
  - r12 -- r11
  - r9 -- r8
  - r8 -- q8
  - o8 -- m8 black
  - m8 -- m5 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/01-goodnight-timer.svg)

- 部品面から見た図。電源は上の 18 行 (赤)、GND は下の 5 行 (黒) に 1 本ずつ筋を通し、
  左端の a18・a5 に電源をつなぐ。部品はこの 2 本の筋から縦に配る
- U1 (e14、DIP8) は切り欠きを左にして挿す。上の列が左から PIN 8 (VDD)・7 (DISCH)・
  6 (THRES)・5 (CONT) で e14〜h14、下の列が左から PIN 1 (GND)・2 (TRIG)・3 (OUT)・
  4 (RESET) で e11〜h11。PIN 8 は E 列を上って 18 行へ、PIN 1 は E 列を下って 5 行へ
- PIN 4 (RESET) は 11 行で J 列へ出て、J 列を上って 18 行 (VCC) へ。その途中の j14 から
  14 行を右へ出して、出力段の RLED へ VCC を配る。PIN 5 (CONT) はどこにもつないでいない (`unused:` に並べて、ERC の「つながっていない」から外した)。
  単安定の動作には必須ではなく、浮かせたままでも動く (つなぐならここから 0.01µF を
  GND へ)
- PIN 2 (TRIG、黄) は f11 から 9 行を左へ運んで SWtrig (b9) へ。SWtrig の下のピンは b7 から
  5 行の GND へ、上のピン b9 は B 列を上って Rtrig (b18〜b15) で 18 行の VCC へプルアップする
- PIN 6・7 (THRES・DISCH、橙) はそれぞれ 15 行へ上げて f15〜g15 で結び、Rt (g18〜g15) で VCC へ。
  同じ g15 から 15 行を右へ運んで Ct (u15、+ が上) へ、Ct の − は U 列を下って GND へ
- PIN 3 (OUT) は 10 行で Rg (l10〜p10) へ、Rg から P 列を下って Q1 のゲート (p8) へ。
  Q1 (2N7000) は平らな面を見て左から S・G・D なので、o8 がソース、p8 がゲート、
  q8 がドレイン。ソースは M 列を下って GND へ、ドレインは r8 から R 列を上って
  DLED のカソード (r9) へ。DLED のアノード (r11) は RLED (r14〜r12) を通して 14 行の VCC へ
- 交差は 2 か所で、どちらも被覆線で跨ぐ。橙の 15 行 (Ct へ) が J 列の赤 (RESET) を、
  黄の 9 行 (TRIG) が E 列の黒 (U1 の GND) を跨ぐ。この回路はピンの並びから交差を
  0 にはできない (PIN 4 の VCC と、PIN 6・7 から Ct への GND が U1 の右で必ず出会う)

## 計器の設定

計器は AD3 の Supplies (電源) とオシロ (Scope)。**SWtrig を押した瞬間から OUT が H になり、Ct の電圧が 5V に向かってゆっくり上がる**のを、
1 回の押下で見る。約 19 分の現象なので、Scope を Record モード (Analog Discovery の本の 2-11) にする。
図3 は押してから最初の 9 分 (時間レンジ 60s/div、図に描ける最長のレンジ) で、OUT が H のまま Ct が上がっていく様子。
Ct が電源電圧の 2/3 (約 3.33V) に届いて OUT が L に戻るのは約 1137 秒 (約 19 分) で図の外になる。実機では記録を 20 分以上に延ばして確かめる。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5V、V− は使わない |
| CH1 (1+) | Ct の電圧 (U1 の PIN 6・7)。1V/div、0V を下から 1 目盛 |
| CH2 (2+) | OUT (U1 の PIN 3)。CH1 と同じ 1V/div・同じ 0V の位置 |
| 1−・2− | GND |
| 時間レンジ | 60s/div (Record モード、図3 の最初の 9 分)。T まで見るなら記録を 20 分以上に延ばす |
| トリガ | CH2 の立ち上がり、2.5V。トリガの点を左から 1 目盛に置く (SWtrig を押した時刻が t = 0) |
| Measurements | Maximum |
| カーソル | X1 を 60 秒、X2 を 480 秒に置き、そのときの Ct を読む |

```scope
title: 図3 押してから最初の 9 分 — OUT は H のまま、Ct の電圧が上がっていく
time: 60s/div
trigger: ch2 rising 2.5V at -4div
ch1: {wave: = 5V * step(t) * (1 - exp(-t / 1034s)), range: 1V/div, position: -3div}
ch2: {wave: = 5V * step(t), range: 1V/div, position: -3div}
cursors: [60s, 480s]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/01-goodnight-timer.svg)

- 図3 の CH2 (OUT) は押した瞬間 (t = 0) に 0V から約 5V へ上がり、図の間ずっと H のまま。
  CH1 (Ct) は 0V から 5V に向かって曲線を描いて上がる。時定数 τ = Rt × Ct = 4.7MΩ × 220µF = 1034 秒 (計算値)
- カーソルの読みは、X1 (60 秒) で 5V × (1 − e<sup>−60/1034</sup>) ≈ 0.28V、X2 (480 秒) で 5V × (1 − e<sup>−480/1034</sup>) ≈ 1.86V (計算値)
- T = 1.1 × τ ≈ 1137 秒のとき Ct は 5V × (1 − e<sup>−1.1</sup>) ≈ 3.33V (電源の 2/3) になり、555 が止まって OUT が L に戻る。
  DISCH が Ct を放電して 0V に戻す。この変化は図3 の外 (原点から約 19 目盛) で、実機の記録で確かめる
- 実物の T は、電解コンデンサの容量誤差 (±20% ほど) と漏れで変わる (下の「見るべき値」の注)。図は計算値

## 見るべき値

計算値。電圧はテスターの直流電圧レンジで GND との間を測る。時間は時計で測る。

| 測る所 | 期待する値 |
| --- | --- |
| SWtrig を押した直後の U1 の PIN 3 (OUT) | H に変わり、DLED が点く。約 5V (TLC555 は CMOS 出力で、ゲートしか駆動しないので +5V とほぼ同じ) |
| 点灯している時間 | T = 1.1 × 4.7MΩ × 220µF ≈ 1137 秒 (約 19 分、計算値) |
| DLED の電流 | 約 6.4mA ((5V − 2.0V) / 470Ω、赤色 LED、計算値)。RLED の両端の電圧 (約 3.0V) を 470Ω で割って確かめる |
| 19 分後の PIN 3 | L (0V) に戻り、DLED が消える |

Ct (220µF) を 100µF に替えると T ≈ 8.6分になる (計算値)。電解コンデンサの
容量誤差は ±20% ほどあり、漏れでも延びるので、実際の時間は目安。

30 分たっても LED が消えないときは、漏れが充電電流に勝っている。Rt を
2.2MΩ に下げる (充電電流 約2.3µA、T ≈ 9分) と余裕ができる。40 分ほどの長い
時間が要るなら、単安定で粘らず、555 の発振を 4040 などのカウンタで数える形
(10-4) にするほうが確実。

## 出典

自作。
