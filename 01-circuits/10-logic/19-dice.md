---
book: circuits
chapter: 10
id: 10-19
title: 電子サイコロ (4017 + 555)
tier: 200
source: 自作
era: 古
---

# 10-19 電子サイコロ (4017 + 555)

10-10 の 555 と 4017 の LED 順送りを、速く回して手で止めるとサイコロになる。ボタンを押している間だけ 555 が
約 690 Hz で発振し、4017 は 1 秒に 100 周以上回る。人の手で離す瞬間は選べないので、止まった所の目はでたらめになる。
昔からの電子工作の定番の作品。

サイコロにするには 4017 を 10 進ではなく 6 進にする。Q6 (7 つめの出力) を RESET (15 番) に戻すと、Q6 が H になった瞬間に
カウンタが 0 に戻り、Q0〜Q5 の 6 通りだけを回る。L1〜L6 の 6 個の LED のうち 1 個が点き、点いた番号が目になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 押している間 555 が発振し 4017 が Q0 から Q5 を回る (Q6 でリセット)
parts:
  U555: ic 6,5 NE555
  VCC: vcc 3,2 5V
  R1: resistor 3,2 3,4.5 1k
  R2: resistor 3,4.5 3,6 10k
  C1: capacitor 4,6 4,8 100n
  GC1: ground 4,8
  GU555: ground 6,8
  CLK: port 10,5 out
  SW: button 8,2 8,3 l=$\mathrm{SW}$
  RPD: resistor 8,3 8,5 10k l=$R_\mathrm{PD}$
  GRPD: ground 8,5
  U2: dip16 18,6 CD4017
  VCC: vcc 20.5,4 5V
  Q6: port 20.6,5.2 in
  GINH: ground 19.6,6 r270
  CLK: port 21.4,5.6 in
  Q4: port 23.8,7.2 out
  Q5: port 15.5,4.8 out
  Q1: port 14.8,5.2 out
  Q0: port 14.1,5.6 out
  Q2: port 13.4,6 out
  Q6: port 12.7,6.4 out
  Q3: port 11.3,7.2 out
  GVSS: ground 16,7.6 r90
  Q0: port 3,10 in
  L1: led 3,10 3,11.5 red
  RL1: resistor 3,11.5 3,13 1k
  GL1: ground 3,13
  Q1: port 5,10 in
  L2: led 5,10 5,11.5 red
  RL2: resistor 5,11.5 5,13 1k
  GL2: ground 5,13
  Q2: port 7,10 in
  L3: led 7,10 7,11.5 red
  RL3: resistor 7,11.5 7,13 1k
  GL3: ground 7,13
  Q3: port 9,10 in
  L4: led 9,10 9,11.5 red
  RL4: resistor 9,11.5 9,13 1k
  GL4: ground 9,13
  Q4: port 11,10 in
  L5: led 11,10 11,11.5 red
  RL5: resistor 11,11.5 11,13 1k
  GL5: ground 11,13
  Q5: port 13,10 in
  L6: led 13,10 13,11.5 red
  RL6: resistor 13,11.5 13,13 1k
  GL6: ground 13,13
wires:
  - U555.VCC |- 6,2
  - 3,2 -- 6,2
  - 6,2 -- 8,2
  - U555.RESET |- 8,3
  - U555.DISCH -| 3,4.5
  - U555.THRES -| 4,5
  - U555.TRIG -| 4,5.5
  - 4,5 -- 4,6
  - 3,6 -- 4,6
  - U555.GND |- 6,8
  - U555.OUT -| 10,5
  - U2.VDD -| 20.5,4.8
  - 20.5,4.8 -- 20.5,4
  - U2.RESET -| 20.6,5.2
  - U2.INH -| 19.6,6
  - U2.CLOCK -| 21.4,5.6
  - U2.Q4 -| 23.8,7.2
  - U2.Q5 -| 15.5,4.8
  - U2.Q1 -| 14.8,5.2
  - U2.Q0 -| 14.1,5.6
  - U2.Q2 -| 13.4,6
  - U2.Q6 -| 12.7,6.4
  - U2.Q3 -| 11.3,7.2
  - U2.VSS -| 16,7.6
notes:
  - text 1,15 small left: "同じ名前の端子はつながっている。L1 から L6 がサイコロの目 1 から 6"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/19-dice.svg)

- 555 (U555) は 3-2 の非安定で、R1 1 kΩ・R2 10 kΩ・C1 100 nF。f = 1 ÷ (0.693 × (R1 + 2 R2) × C1) = 687 Hz (計算値)。
  RESET (4 番) を R<sub>PD</sub> (10 kΩ) で GND に落としてあり、SW を押した間だけ RESET が H になって発振する。
  離すと 555 の出力は L で止まり、4017 はその時の目で止まる
- 4017 (U2) の CLOCK INHIBIT (13 番) は GND で、いつも数える。Q6 (5 番) を RESET (15 番) につなぐ。
  6 回目のクロックで Q6 が H になると、すぐにカウンタが 0 に戻って Q0 が H になる。Q6 が H なのは 0.1 µs ほどの一瞬で、LED には見えない
- Q0〜Q5 の LED (L1〜L6) が目の 1〜6。CO (12 番) は Q0〜Q4 の間 H、Q5 の間 L で、クロックの 1/6 の周波数になる (計器で見る)
- LED の直列抵抗は 1 kΩ (10-10 と同じ。CD4000 系の出力は数 mA まで)。一度に点くのは 1 個
- データシートの RESET のパルス幅の最小は 5 V で 260 ns (TI の CD4017B)。Q6 から RESET へ戻す形では、カウンタが 0 に戻った所で
  Q6 が L になってリセットが終わるので、パルス幅はカウンタ自身の遅れで決まる。動きが不安定な品では、Q6 と RESET の間に 4.7 kΩ、RESET と GND の間に 100 pF を入れて幅を伸ばす (目安)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (押している間だけ 555 が発振し 4017 が 1 から 6 を回る)
board: full
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies・Scope
    pins: [V+, GND, 1-, 2-, 1+, 2+]
  U555: dip8 @ e3 NE555
  R1: resistor b4 b1 1k
  R2: resistor c4 c8 10k
  C1: capacitor/ceramic i8 i10 100n cap=above
  SW: button @ e9
  RPD: resistor j11 -b11 10k
  U2: dip16 @ e22 CD4017
  L1: led f14(A) e14(K) red
  RL1: resistor a14 -t14 1k
  L2: led f17(A) e17(K) red
  RL2: resistor a17 -t17 1k
  L3: led f20(A) e20(K) red
  RL3: resistor a20 -t20 1k
  L4: led f32(A) e32(K) red
  RL4: resistor a32 -t32 1k
  L5: led e35(A) f35(K) red
  RL5: resistor j35 -b35 1k
  L6: led f38(A) e38(K) red
  RL6: resistor a38 -t38 1k
wires:
  - PS.V+ -- +t2 red
  - PS.GND -- -t4 black
  - +t63 -- +b63 red
  - -t62 -- -b62 black
  - a1 -- +t1 red
  - a3 -- +t3 red
  - j3 -- -b3 black
  - a5 -- a8 orange
  - d8 -- f8 orange
  - g4 -- g8 orange
  - j10 -- -b10 black
  - a9 -- +t9 red
  - j6 -- j9 green
  - h5 -- h12 blue
  - f12 -- e12 blue
  - d12 -- d24 blue
  - a22 -- +t22 red
  - a25 -- -t25 black
  - j29 -- -b29 black
  - h26 -- h30 purple
  - f30 -- e30 purple
  - b30 -- b23 purple
  - h24 -- h14 yellow
  - j23 -- j17 green
  - g25 -- g20 white
  - j28 -- j32 gray [v-10]
  - d28 -- d35 orange
  - i22 -- i38 brown
  - PS.1- -- -t5 black
  - PS.2- -- -t7 black
  - PS.1+ -- a24 blue
  - PS.2+ -- a26 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/19-dice.svg)

- 10-10 の配線を元に、LED を 6 個 (L1〜L3 は 14・17・20 列、L4〜L6 は 32・35・38 列) にし、Q6 を RESET へ戻した
- U555 は 3〜6 列、U2 (CD4017) は 22〜29 列。555 の C1 (104) は 8 列から 10 列、10 列を GND へ
- SW (タクトスイッチ) は 9〜11 列で溝をまたぐ。上の列 (9 列) を赤の線で +5 V、下の列が 555 の RESET (6 列の下) と緑の線でつながり、
  R<sub>PD</sub> (11 列の下から下の青レール) で GND に落ちている
- Q6 (26 列の下) は紫の線で h 行を 30 列へ運び、溝をまたいで b 行で RESET (23 列の上) へ。CLOCK INHIBIT (25 列の上) は青レールへ
- L5 だけアノードが上 (e 行)。Q4 のピンが U2 の上の列にあるため (10-10 と同じ)
- AD3 の 1+ を CLOCK (24 列)、2+ を CO (26 列の上) に挿す。1−・2− は上の青レールへ
- 電流は LED 1 個の約 2 mA と NE555 の約 3 mA、R1・R2 の 0.2 mA ほどで 6 mA ほど。ブレッドボードの範囲にも AD3 の Supplies にも収まる

## 計器の設定

計器は AD3 の Supplies・Scope。SW を押し続けたまま、クロックと CO を同じ時間軸で見て、6 進で回っていることを確かめる。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| CH1 (1+) | CLOCK (24 列)。2 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | CO (26 列)。CH1 と同じ尺度 |
| 時間 | 2 ms/div、トリガは CH2 の立ち上がり 2.5 V、トリガの点を左から 1 目盛 |
| Measurements | Frequency・Duty |
| カーソル | X1 = 0 (CO の立ち上がり)、X2 = 8.73 ms (次の CO の立ち上がり。クロック 6 周期) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 SW を押している間のクロック (CH1) 687 Hz と CO (CH2) 114.5 Hz — 6 分の 1 (計算)
time: 2ms/div
trigger: ch2 rising 2.5V at -4div
ch1: {wave: square 687Hz 1.7V offset 1.8V duty 52.4%, range: 2V/div, position: -3div}
ch2: {wave: pulse 114.5Hz 2.5V offset 2.5V duty 83.3%, range: 2V/div, position: -3div}
cursors: [0, 8.73ms]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/19-dice.svg)

- 図3 は計算で作った理想の波形。CH1 の H は約 3.5 V (NE555 の出力の目安、10-10)。CD4017 の入力のしきい値にぎりぎりなので、
  数え方が乱れるときは TLC555 に替える (10-10)
- CH2 (CO) はクロック 5 周期の間 H、1 周期の間 L で、デューティ 83.3 %、周波数はクロックの 1/6 の 114.5 Hz
- SW を離すとクロックが止まり、CO もその目の所で止まる (1〜5 なら H、6 なら L)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U555 | タイマー | NE555 (DIP-8) |
| U2 | 10 進カウンタ | CD4017B (DIP-16)。Q6 を RESET へ戻して 6 進で使う |
| R1・R2 | 抵抗 (1/4 W)、555 の時定数 | 1 kΩ・10 kΩ |
| C1 | 積層セラミックコンデンサ | 100 nF (104) |
| R<sub>PD</sub> | 抵抗 (1/4 W)、555 の RESET を L に | 10 kΩ |
| SW | タクトスイッチ | 1 個 |
| RL1〜RL6 | 抵抗 (1/4 W)、LED の電流制限 | 1 kΩ × 6 本 |
| L1〜L6 | LED (赤) | 5 mm × 6 個 |
| — | 電源・計器 | Analog Discovery 3 |

## 見るべき値

| 項目 | 計算 | 見る所 |
| --- | --- | --- |
| クロックの周波数 | 1 ÷ (0.693 × 21 kΩ × 100 nF) = 687 Hz | 図3 の CH1 |
| クロックの H・L | 0.762 ms・0.693 ms (デューティ 52.4 %) | 同上 |
| 6 つの目を 1 周する時間 | 6 ÷ 687 Hz = 8.73 ms | カーソル X1・X2 |
| CO の周波数とデューティ | 114.5 Hz・83.3 % | 図3 の CH2 |
| 押す間に回る回数 (0.5 秒押したとき) | 687 × 0.5 ÷ 6 ≈ 57 周 | — |
| 点く LED | いつも 1 個 (L1〜L6 のどれか) | LED |

本物のサイコロの目の並び (中央・対角・横の 7 個の LED) にするには、目ごとに点く LED の組を作る。
中央は 1・3・5、左上と右下は 2〜6、右上と左下は 4〜6、左右の真ん中は 6 のときに点く。1N4148 で Q の出力をまとめ (ダイオード OR)、
組ごとに 2SC1815 で LED を駆動する。この題では、6 進のカウンタの動きが見える 6 個の LED にとどめた。

| 目 | 4017 の出力 | 中央 | 左上・右下 | 右上・左下 | 左右の真ん中 |
| --- | --- | --- | --- | --- | --- |
| 1 | Q0 | 点 | | | |
| 2 | Q1 | | 点 | | |
| 3 | Q2 | 点 | 点 | | |
| 4 | Q3 | | 点 | 点 | |
| 5 | Q4 | 点 | 点 | 点 | |
| 6 | Q5 | | 点 | 点 | 点 |

## LTspice での確かめ

`sim/19-dice.cir` で、4017 の中の 5 段のジョンソンカウンタを LTspice の D-FF (DFLOP) 5 個と解読で表し、Q6 を全段の CLR (RESET) に戻した。
クロックは時間を縮めて 1 kHz にし、並びだけを見た。555 の周波数は算術を .meas に残した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| n 回目のクロックの後に H の出力 (n = 0〜5) | Q0〜Q5 | それぞれ 5 V | 合う |
| 6 回目・7 回目・12 回目のクロックの後 | Q0・Q1・Q0 (6 進) | Q0・Q1・Q0 が 5 V | 合う |
| Q6 が H の時間 | 0.1 µs ほどの一瞬 | 64 ns (DFLOP の遅れ 50 ns と配線の遅れによる。仮定) | 合う |
| Q0〜Q5 で同時に H の数 | いつも 1 本 (リセットの一瞬は 0 本) | 最大 1 本ぶん (5 V)、最小 0 (Q6 の 64 ns) | 合う |
| 555 の周波数 | 687 Hz | 687.0 Hz (算術) | 合う |
| 555 の H・L | 0.762 ms・0.693 ms | 0.762 ms・0.693 ms (算術) | 合う |
| CO の周波数 (クロックの 1/6) | 114.5 Hz | 114.5 Hz (算術) | 合う |

## 出典

自作。

参考: [CD4017B データシート](https://www.ti.com/lit/ds/symlink/cd4017b.pdf)、[NE555 データシート](https://www.ti.com/lit/ds/symlink/ne555.pdf)、[サイコロ (Wikipedia)](https://ja.wikipedia.org/wiki/サイコロ)
