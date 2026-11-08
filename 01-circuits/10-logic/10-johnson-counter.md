---
book: circuits
chapter: 10
id: 10-10
title: ジョンソンカウンタ (4017) — LED 順送り
tier: 200
source: 自作
---

# 10-10 ジョンソンカウンタ (4017) — LED 順送り

CD4017 は、クロックが来るたびに 10 本の出力 Q0〜Q9 のうち H になる 1 本を隣へ送る IC。
10 個の LED を Q の順に並べれば、光が 1 つずつ流れる (LED 順送り)。3-2 の 555 の非安定でクロックを作り、
10-4 の 4040 (2 進で数える) と見比べる。

中は 5 段の**ジョンソンカウンタ**である。10-6 のシフトレジスタのように D-FF (10-5) を 5 段つなぎ、
最後の段の Q̄ (反転) を先頭の D へ戻す。5 段の中身は 00000 → 10000 → 11000 → 11100 → 11110 → 11111 →
01111 → 00111 → 00011 → 00001 → 00000 と 10 通りを回る。1 回のクロックで変わるのは 1 段だけなので、
隣り合う 2 段を 2 入力のゲートで見るだけで、いまどの状態かが分かる (下の表)。2 進カウンタを解読するには
4 入力のゲートが要るのと比べて、簡単で、切り替わりのひげ (一瞬だけ別の出力が H になる) も出ない。

| 状態 | 5 段 (D1〜D5) | H になる出力 | 解読のしかた |
| --- | --- | --- | --- |
| 0 | 00000 | Q0 | D1 = 0 かつ D5 = 0 |
| 1〜4 | 10000〜11110 | Q1〜Q4 | Dk = 1 かつ Dk+1 = 0 |
| 5 | 11111 | Q5 | D1 = 1 かつ D5 = 1 |
| 6〜9 | 01111〜00001 | Q6〜Q9 | Dk−5 = 0 かつ Dk−4 = 1 |

桁上げ CO (12 番) は D5 の反転で、状態 0〜4 の間 H、5〜9 の間 L。クロックの 1/10 の周波数で、デューティは 50 % になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 555 のクロックで 4017 の Q0 から Q9 を順に点ける
parts:
  U555: ic 6,5 NE555
  VCC: vcc 3,2 5V
  R1: resistor 3,2 3,4.5 10k
  R2: resistor 3,4.5 3,6 68k
  C1: ecap 4,6 4,8 2.2u
  GC1: ground 4,8
  GU555: ground 6,8
  CLK: port 10,5 out
  U2: dip16 18,6 CD4017
  VCC: vcc 20.5,4 5V
  GRST: ground 19.6,5.2 r270
  GINH: ground 19.6,6 r270
  CLK: port 21.4,5.6 in
  CO: port 22.2,6.4 out
  Q9: port 23,6.8 out
  Q4: port 23.8,7.2 out
  Q8: port 24.6,7.6 out
  Q5: port 15.5,4.8 out
  Q1: port 14.8,5.2 out
  Q0: port 14.1,5.6 out
  Q2: port 13.4,6 out
  Q6: port 12.7,6.4 out
  Q7: port 12,6.8 out
  Q3: port 11.3,7.2 out
  GVSS: ground 16,7.6 r90
  Q0: port 3,10 in
  L0: led 3,10 3,11.5 red
  RL0: resistor 3,11.5 3,13 1k
  GL0: ground 3,13
  Q1: port 5,10 in
  L1: led 5,10 5,11.5 red
  RL1: resistor 5,11.5 5,13 1k
  GL1: ground 5,13
  Q2: port 7,10 in
  L2: led 7,10 7,11.5 red
  RL2: resistor 7,11.5 7,13 1k
  GL2: ground 7,13
  Q3: port 9,10 in
  L3: led 9,10 9,11.5 red
  RL3: resistor 9,11.5 9,13 1k
  GL3: ground 9,13
  Q4: port 11,10 in
  L4: led 11,10 11,11.5 red
  RL4: resistor 11,11.5 11,13 1k
  GL4: ground 11,13
  Q5: port 13,10 in
  L5: led 13,10 13,11.5 red
  RL5: resistor 13,11.5 13,13 1k
  GL5: ground 13,13
  Q6: port 15,10 in
  L6: led 15,10 15,11.5 red
  RL6: resistor 15,11.5 15,13 1k
  GL6: ground 15,13
  Q7: port 17,10 in
  L7: led 17,10 17,11.5 red
  RL7: resistor 17,11.5 17,13 1k
  GL7: ground 17,13
  Q8: port 19,10 in
  L8: led 19,10 19,11.5 red
  RL8: resistor 19,11.5 19,13 1k
  GL8: ground 19,13
  Q9: port 21,10 in
  L9: led 21,10 21,11.5 red
  RL9: resistor 21,11.5 21,13 1k
  GL9: ground 21,13
wires:
  - U555.VCC |- 6,2
  - U555.RESET |- 6.5,2
  - 3,2 -- 6,2 -- 6.5,2
  - U555.DISCH -| 3,4.5
  - U555.THRES -| 4,5
  - U555.TRIG -| 4,5.5
  - 4,5 -- 4,6
  - 3,6 -- 4,6
  - U555.GND |- 6,8
  - U555.OUT -| 10,5
  - U2.VDD -| 20.5,4.8
  - 20.5,4.8 -- 20.5,4
  - U2.RESET -| 19.6,5.2
  - U2.INH -| 19.6,6
  - U2.CLOCK -| 21.4,5.6
  - U2.CO -| 22.2,6.4
  - U2.Q9 -| 23,6.8
  - U2.Q4 -| 23.8,7.2
  - U2.Q8 -| 24.6,7.6
  - U2.Q5 -| 15.5,4.8
  - U2.Q1 -| 14.8,5.2
  - U2.Q0 -| 14.1,5.6
  - U2.Q2 -| 13.4,6
  - U2.Q6 -| 12.7,6.4
  - U2.Q7 -| 12,6.8
  - U2.Q3 -| 11.3,7.2
  - U2.VSS -| 16,7.6
notes:
  - text 1,15 small left: "同じ名前の端子 (Q0 から Q9・CLK) はつながっている。LED は Q の順に並べた"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/10-johnson-counter.svg)

- 555 (U555) は 3-2 と同じ非安定。R1 10 kΩ、R2 68 kΩ、C1 2.2 µF で
  T = 0.693 × (R1 + 2 R2) × C1 = 0.223 秒、f = 4.49 Hz (計算値)。光は 0.22 秒ごとに隣へ動き、10 個を 2.23 秒で 1 周する
- 555 の OUT (3 番) が 4017 の CLOCK (14 番)。4017 はクロックの立ち上がりで 1 つ進む。CLOCK の入力はシュミットトリガで、
  立ち上がりの遅いクロックでも数え間違えない (TI の CD4017B のデータシート)
- RESET (15 番) と CLOCK INHIBIT (13 番、H の間クロックを止める) はどちらも GND に固定する。
  電源を入れた直後の中身がどの組でも、10 通りの輪に戻る仕組み (データシートの anti-lock gating) が中にある
- 10 本の Q は、ピンの並びが Q5・Q1・Q0・Q2… と飛んでいる。図1 は同じ名前の端子でつないで、LED を Q の順に並べた
- LED の直列抵抗は 1 kΩ (LED のカソード側)。10-4 と同じく CD4000 系の出力は数 mA しか出せず、LED の電流は 1.5〜2.2 mA (10-1 の目安)。
  一度に点くのは 1 個なので、電流は LED 1 個ぶんしか流れない
- CO (12 番) は、次の 4017 の CLOCK につなげば 100 進に伸ばせる出力。この題では計器で見るだけ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (555 と 4017、LED は右へ Q の順)
board: full
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies・Scope
    pins: [V+, GND, 1-, 2-, 1+, 2+]
  U555: dip8 @ e3 NE555
  R1: resistor b4 b1 10k
  R2: resistor c4 c8 68k
  C1: capacitor/electrolytic i8 i11 2.2u
  U2: dip16 @ e22 CD4017
  L0: led f14(A) e14(K) red
  RL0: resistor a14 -t14 1k
  L1: led f17(A) e17(K) red
  RL1: resistor a17 -t17 1k
  L2: led f20(A) e20(K) red
  RL2: resistor a20 -t20 1k
  L3: led f32(A) e32(K) red
  RL3: resistor a32 -t32 1k
  L4: led e35(A) f35(K) red
  RL4: resistor j35 -b35 1k
  L5: led f38(A) e38(K) red
  RL5: resistor a38 -t38 1k
  L6: led f41(A) e41(K) red
  RL6: resistor a41 -t41 1k
  L7: led f44(A) e44(K) red
  RL7: resistor a44 -t44 1k
  L8: led e47(A) f47(K) red
  RL8: resistor j47 -b47 1k
  L9: led e50(A) f50(K) red
  RL9: resistor j50 -b50 1k
wires:
  - PS.V+ -- +t2 red
  - PS.GND -- -t4 black
  - +t63 -- +b63 red
  - -t62 -- -b62 black
  - a1 -- +t1 red
  - a3 -- +t3 red
  - j3 -- -b3 black
  - j6 -- +b6 red
  - a5 -- a8 orange
  - d8 -- f8 orange
  - g4 -- g8 orange
  - j11 -- -b11 black
  - h5 -- h12 blue
  - f12 -- e12 blue
  - d12 -- d24 blue
  - a22 -- +t22 red
  - a23 -- -t23 black
  - a25 -- -t25 black
  - j29 -- -b29 black
  - h24 -- h14 yellow
  - j23 -- j17 green
  - g25 -- g20 white
  - j28 -- j32 purple [v-10]
  - d28 -- d35 orange
  - i22 -- i38 gray
  - h26 -- h41 brown
  - g27 -- g44 pink
  - c29 -- c47 yellow
  - b27 -- b50 green
  - PS.1+ -- a24 blue
  - PS.1- -- -t5 black
  - PS.2+ -- a26 white
  - PS.2- -- -t7 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/10-johnson-counter.svg)

- 電源は AD3 の Supplies の V+ (5 V)。上の赤レールと青レールに入れ、下のレールとは右端 (62・63 列) でつなぐ
- U555 (NE555) は 3〜6 列、U2 (CD4017) は 22〜29 列。どちらも切り欠きが左で、1 番が左下 (f 行)
- 555 は 10-4 と同じ配線を左へ寄せた。R1 は 1 列 (+5 V) から 4 列 (DISCH)、R2 は 4 列から 8 列。8 列は THRES (5 列の上) と
  オレンジの線でつながり、溝をまたいで TRIG (4 列の下) へ。C1 は 8 列から 11 列 (GND) へ (+ が 8 列)。
  RESET (6 列の下) は下の赤レールへ。OUT (5 列の下) は青の線で h 行を 12 列へ運び、溝をまたいで d 行で CLOCK (24 列の上) へ
- U2: VDD (22 列の上) を +5 V、RESET (23 列の上)・INH (25 列の上)・VSS (29 列の下) を GND へ
- LED は 14・17・20 列 (L0〜L2) と 32〜50 列の 3 列おき (L3〜L9) に、Q の順に並べた。どの LED も溝をまたいで挿し、
  1 kΩ を列とレールの間に挿す。L4・L8・L9 だけは、アノードが上 (e 行) でカソードと抵抗が下。出力のピンが U2 の上の列にあるため
- 出力の線は、行ごとに重ならないよう、下の列のピン (Q0〜Q3・Q5〜Q7) は g〜j 行、上の列のピン (Q4・Q8・Q9) は b〜d 行を通す。
  Q3 の紫の線だけは j 行の 29 列 (VSS) を避けて、i 行と j 行の間を渡る
- AD3 の 1+ を CLOCK (24 列)、2+ を CO (26 列) に挿す。1−・2− は上の青レールへ。Logic (図4) で見るときは、
  DIO0 を 24 列、DIO1〜DIO10 を L0〜L9 のアノードの列、DIO11 を 26 列に挿す (図2 では省いた)
- 電流は、点いている LED 1 個の約 2 mA と NE555 自身の約 3 mA (データシートの典型値)、R1 の数百 µA で 6 mA ほど。
  ブレッドボードの範囲にも AD3 の Supplies にも収まる

## 計器の設定

計器は AD3 の Supplies・Scope・Logic。Scope でクロックと CO の周波数の比が 10 であることを、
Logic で 1 本ずつ順に H が移ることを見る。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| CH1 (1+) | CLOCK (24 列)。2 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | CO (26 列)。CH1 と同じ尺度 |
| 時間 | 500 ms/div、トリガは CH2 の立ち上がり 2.5 V、トリガの点を左から 1 目盛 |
| Measurements | Frequency・Duty |
| カーソル | X1 = 0 (CO の立ち上がり)、X2 = 2.226 s (次の CO の立ち上がり。クロック 10 周期) |
| Logic | DIO0 (CLOCK)・DIO1〜DIO10 (Q0〜Q9)・DIO11 (CO)。標本化 1 kHz、250 ms/div、トリガは DIO11 の立ち上がり |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 クロック (CH1) 4.49 Hz と CO (CH2) 0.449 Hz — 10 分の 1 でデューティ 50 %
time: 500ms/div
trigger: ch2 rising 2.5V at -4div
ch1: {wave: square 4.49Hz 1.7V offset 1.8V duty 53.4%, range: 2V/div, position: -3div}
ch2: {wave: square 0.449Hz 2.5V offset 2.5V duty 50%, range: 2V/div, position: -3div}
cursors: [0, 2.226s]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/10-johnson-counter.svg)

- 図3 は計算で作った理想の波形。CH1 の H は約 3.5 V、L は約 0.1 V (10-4 と同じ NE555 の出力の目安)。
  CD4017 の CLOCK は 5 V で H と読むのに 3.5 V が要る (CD4000 系の入力の保証値) ので、NE555 の H はぎりぎり。
  数えないときや数が飛ぶときは、出力が電源いっぱいまで振れる TLC555 (ピンの並びは同じ) に替える
- CO は 0 V と 5 V を行き来し、周期はクロック 10 周期の 2.226 s (0.449 Hz)。デューティはクロックのデューティに依らず 50 %

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 H が Q0 から Q9 へ 1 本ずつ移り、CO は Q0〜Q4 の間だけ H (計算)
device: ad3
time: 250ms/div
sample: 1kHz
signals:
  CLK:  dio0 clock 4.49Hz duty 53.4%
  Q0:   dio1 edges 0s=1 222.6ms=0 2226.4ms=1 2449.0ms=0
  Q1:   dio2 edges 0s=0 222.6ms=1 445.3ms=0 2449.0ms=1
  Q2:   dio3 edges 0s=0 445.3ms=1 667.9ms=0
  Q3:   dio4 edges 0s=0 667.9ms=1 890.6ms=0
  Q4:   dio5 edges 0s=0 890.6ms=1 1113.2ms=0
  Q5:   dio6 edges 0s=0 1113.2ms=1 1335.8ms=0
  Q6:   dio7 edges 0s=0 1335.8ms=1 1558.5ms=0
  Q7:   dio8 edges 0s=0 1558.5ms=1 1781.1ms=0
  Q8:   dio9 edges 0s=0 1781.1ms=1 2003.7ms=0
  Q9:   dio10 edges 0s=0 2003.7ms=1 2226.4ms=0
  CO:   dio11 edges 0s=1 1113.2ms=0 2226.4ms=1
cursors: [0s, 2226.4ms]
trigger: CO rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/10-johnson-counter.svg)

- どの時刻でも、Q0〜Q9 のうち H は 1 本だけ。クロックの立ち上がりのたびに隣へ移る
- カーソルの ΔX = 2.226 s がクロック 10 周期。X2 で Q0 に戻る

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U555 | タイマー | NE555 (DIP-8) |
| U2 | 10 進カウンタ (ジョンソンカウンタ + 解読) | CD4017B (DIP-16) |
| R1・R2 | 抵抗 (1/4 W)、555 の時定数 | 10 kΩ・68 kΩ |
| C1 | アルミ電解コンデンサ | 2.2 µF、16 V 以上 |
| RL0〜RL9 | 抵抗 (1/4 W)、LED の電流制限 | 1 kΩ × 10 本 |
| L0〜L9 | LED (赤) | 5 mm × 10 個 |
| — | 電源・計器 | Analog Discovery 3 |

## 見るべき値

| 項目 | 計算 | 見る所 |
| --- | --- | --- |
| クロックの周期 | 0.693 × (10 kΩ + 2 × 68 kΩ) × 2.2 µF = 0.223 s (4.49 Hz) | 図3 の CH1 |
| クロックの H・L の時間 | 0.119 s・0.104 s (デューティ 53.4 %) | 同上 |
| LED が 1 周する時間 | 10 × 0.223 s = 2.23 s | LED・図4 |
| CO の周波数とデューティ | 4.49 Hz ÷ 10 = 0.449 Hz、50 % | 図3 の CH2 |
| 同時に点く LED | いつも 1 個 | LED・図4 |

10-4 の 4040 では 16 クロックで 1 周し、LED は 2 進数の形で点いた。4017 は 10 クロックで 1 周し、
1 個ずつ点く。1 本の出力が「いまの数」を表すので、LED の順送りやサイコロ (10-19) のように、
数ごとに別のことをさせたいときに向く。

## LTspice での確かめ

`sim/10-johnson-counter.cir` で、4017 の中を 10-5 と同じ NAND 6 個の D-FF 5 段 (最後の段の Q̄ を先頭へ戻す) と
2 入力の解読 10 本で表し、時間を縮めた 1 kHz のクロックを入れた。555 の周期は 10-4 と同じく算術を .meas に残した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| n 回目のクロックの後に H の出力 (n = 0〜9) | Qn | Q0〜Q9 がそれぞれ 5 V | 合う |
| 10 回目のクロックの後 | Q0 に戻る | Q0 = 5 V | 合う |
| 同時に H の出力の数 | いつも 1 本 | 10 本の和が最小・最大とも 5 V (1 本ぶん) | 合う |
| CO の周期 | クロック 10 周期 | 10.0 ms (クロック 1 ms の 10 倍) | 合う |
| CO が L になる所 | 5 回目のクロック | 4.50 ms (5 回目の立ち上がり) | 合う |
| 555 の周期・周波数 | 0.223 s・4.49 Hz | 0.2226 s・4.492 Hz (算術) | 合う |
| 555 の H・L | 0.119 s・0.104 s | 0.1189 s・0.1037 s (算術) | 合う |

## 出典

自作。

参考: [CD4017B データシート](https://www.ti.com/lit/ds/symlink/cd4017b.pdf)、[NE555 データシート](https://www.ti.com/lit/ds/symlink/ne555.pdf)、[Ring counter (英語版 Wikipedia。ジョンソンカウンタの節がある)](https://en.wikipedia.org/wiki/Ring_counter)
