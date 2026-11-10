---
book: circuits
chapter: 12
id: 12-6
title: インターホン (LM386)
tier: 200
source: 自作
board: PF
---

# 12-6 インターホン (LM386)

親機と子機を 2 本の線でつなぎ、ボタンを切り替えて話す・聞くを入れ替える、昔ながらの有線のインターホン。
要の考えは **スピーカーはマイクにもなる** こと。スピーカーのコーンを声で揺らすと、コイルが磁石の中で動いて数 mV ほどの電圧が出る (ダイナミックマイクと同じ仕組み。目安)。
そこで、話す側のスピーカーをマイクにして LM386 で 200 倍 (46 dB) に増幅し、聞く側のスピーカーを鳴らす。
スピーカーを 2 つしか使わないので、子機にはスピーカーと線だけを置き、電源も増幅も親機の基板に置く。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 S1 (2 回路の切り替え) で、話す側のスピーカーをマイクにして LM386 で相手のスピーカーを鳴らす
parts:
  SP2: speaker 1.5,4 1.5,5 l=$\mathrm{SP2}$
  GS2: ground 1.5,5
  S1A: spdt 6,6 mirror
  U1: ic 11,6 LM386
  VCC: vcc 10.5,3.5 5V
  C3: ecap 8.5,4 8.5,5 100u
  G3: ground 8.5,5
  C4: capacitor 6.5,4 6.5,5 0.1u
  G4: ground 6.5,5
  C1: ecap 13,3.5 13,4.5 10u
  GIN: ground 9,7
  C2: ecap 11.5,7.5 11.5,8.5 10u
  G2: ground 11.5,8.5
  GU: ground 11,8.5
  R2: resistor 13.5,6 13.5,7 10
  C5: capacitor 13.5,7 13.5,8 47n
  G5: ground 13.5,8
  C6: ecap 14.5,6 16.5,6 220u
  S1B: spdt 17.5,6 r180 mirror
  SP1: speaker 20,7 20,8 l=$\mathrm{SP1}$
  GS1: ground 20,8
  R1: resistor 19,9 21,9 10k
  W1: port 21,9
wires:
  - 1.5,4 -- 1.5,1.5 -- 5,1.5 -- 18.5,1.5
  - S1A.1 -| 5,1.5
  - S1A.2 -| 4,9.5
  - 4,9.5 -- 19,9.5
  - S1A.in -- U1.+INPUT
  - 10.5,3.5 -- 10.5,4
  - U1.VS |- 10.5,4
  - 10.5,4 -- 8.5,4 -- 6.5,4
  - U1.GAIN1 |- 13,3.5
  - U1.GAIN8 |- 13,4.5
  - U1.-INPUT -| 9,7
  - U1.BYPASS |- 11.5,7.5
  - U1.GND |- 11,8.5
  - U1.VOUT -| 13.5,6
  - 13.5,6 -- 14.5,6
  - 16.5,6 -- S1B.in
  - S1B.2 -| 18.5,1.5
  - S1B.1 -| 19,7
  - 19,7 -- 19,9 -- 19,9.5
  - 19,7 -- 20,7
notes:
  - text 5.6,5.5 small blue right: 1 聞く
  - text 5.6,6.5 small blue right: 2 話す
  - text 18.4,5.5 small blue right: 2 話す
  - text 18,6.5 small blue left: 1 聞く
  - text 2.3,4.5 small blue left: 子機 (別の部屋)
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/06-intercom-lm386.svg)

- S1 は 2 回路 2 接点のトグルスイッチ (ON-ON) で、S1A と S1B は同じレバーで一緒に動く。親機のケースに付け、ふだんは「1 聞く」、押して (倒して) いる間だけ「2 話す」にする
- **1 聞く**: S1A が子機の SP2 を LM386 の + 入力へ、S1B が出力を親機の SP1 へつなぐ。子機の声が親機で鳴る
- **2 話す**: S1A が SP1 を入力へ、S1B が出力を SP2 へつなぐ。親機の声が子機で鳴る。どちらの向きでも、マイクになるスピーカーと鳴るスピーカーは別の部屋にあるので、音が回り込んでハウリングしにくい
- LM386 の利得: 1 番と 8 番の間に C1 (10 µF (マイクロファラド)) を入れると 200 倍 (データシートの 46 dB)。入れなければ 20 倍
- 3 番の + 入力は、直流で 0 V のスピーカーにじかにつなぐ (LM386 の入力は中で 50 kΩ (オーム) で GND に落ちている)。使わない − 入力 (2 番) は GND へ (データシートの、利得を上げたときは使わない入力を GND かコンデンサで落とす、に従う)
- 出力 (5 番) は電源の半分の 2.5 V を中心に振れるので、C6 (220 µF) で直流を止めてスピーカーへ。8 Ω と C6 の低域の端は 1 ÷ (2π × 8 Ω × 220 µF) ≈ 90 Hz で、声 (300 Hz〜3 kHz) は通る
- R2 (10 Ω) と C5 (47 nF) は出力の発振止め (データシートの例は 0.05 µF。E12 の 47 nF にした)。C2 (10 µF) は 7 番 (BYPASS) の雑音よけ、C3 (100 µF) と C4 (0.1 µF) は電源の雑音よけ
- R1 (10 kΩ) と W1 は、確かめるときに AD3 の信号発生器から SP1 へ声の代わりを入れる口。ふだんは何もつながず、SP1 の 8 Ω に比べて 1000 倍以上大きいので働きに効かない

## ユニバーサル基板に組む

親機のケースに入れる作品なので、perfboard に組む。スピーカー 2 つと S1 は基板の外に置き、ピンヘッダ (SP1・SP2・J1) に線でつなぐ。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
title: 図2 perfboard に組む (部品面から見た図。黄色の丸は AD3 を挟む所)
points:
  PWR: a17
  GND: a5
  TP_W1: p11
parts:
  U1: dip8 h12 LM386
  C1: capacitor/electrolytic g9 g12 10u v=16V
  C2: capacitor/electrolytic i14 e14 10u v=16V
  C3: capacitor/electrolytic c16 c13 100u v=16V
  C4: capacitor b16 b13 0.1u
  C6: capacitor/electrolytic o11 o8 220u v=16V
  R2: resistor w12 w9 10
  C5: capacitor w8 w6 47n
  R1: resistor p8 p11 10k
  J1: sip4 m7
  SP2: sip2 k6
  SP1: sip2 r7
wires:
  - PWR -- b17 red
  - b17 -- c17 red
  - c17 -- j17 red
  - j17 -- x17 red
  - GND -- b5 black
  - b5 -- c5 black
  - c5 -- e5 black
  - e5 -- i5 black
  - i5 -- l5 black
  - l5 -- s5 black
  - s5 -- w5 black
  - w5 -- x5 black
  - j12 -- j17 red
  - b16 -- b17 red
  - c16 -- c17 red
  - b13 -- b5 black
  - c13 -- c5 black
  - h9 -- g9
  - h12 -- g12
  - i12 -- i14
  - e14 -- e5 black
  - i9 -- i5 black
  - k9 -- k10 black
  - k10 -- i10 black
  - i10 -- i9 black
  - j9 -- j8 yellow
  - j8 -- n8 yellow
  - n8 -- n7 yellow
  - m7 -- l7 blue
  - l7 -- k7 blue
  - k7 -- k6 blue
  - l6 -- l5 black
  - k12 -- o12 orange
  - o12 -- w12 orange
  - o12 -- o11 orange
  - o8 -- o7 orange
  - p7 -- q7 white
  - q7 -- r7 white
  - p7 -- p8 white
  - s7 -- s5 black
  - w9 -- w8
  - w6 -- w5 black
notes:
  - mark a17 yellow
  - mark a5 yellow
  - mark p11 yellow
  - mark k7 yellow
  - text a17 red large bold right: V+
  - text b4 red large bold center: GND
  - text p13 red large bold center: W1・1+
  - text k4 red large bold center: 2+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/06-intercom-lm386.svg)

- 部品面から見た図。上の 17 行が 5 V、下の 5 行が GND。左端の a17・a5 に電源をつなぐ
- U1 (LM386) は切り欠きを左にして h12〜k12・h9〜k9 に挿す。上の段が左から 8 番 (GAIN)・7 番 (BYPASS)・6 番 (VS、j12)・5 番 (VOUT、k12)、下の段が 1 番 (GAIN)・2 番 (−INPUT)・3 番 (+INPUT、j9)・4 番 (GND、k9)
- C1 (g9〜g12) は + を 1 番の側 (g9) にする。2 番 (i9) は I 列を下りて GND へ。4 番 (k9) は IC の下の 10 行を通して 2 番につなぎ、同じ線で GND へ落とす
- 出力 (k12) は橙の線で 12 行を右へ。C6 (o11〜o8、+ が上) から J1 の 3 番 (o7) へ。右端の R2 (w12〜w9) と C5 (w8〜w6) が発振止め
- J1 (m7〜p7) は S1 へ行く 4 本: **1 番 = SP2、2 番 = + 入力、3 番 = 出力、4 番 = SP1**。S1 の端子では、2 番を S1A の共通、3 番を S1B の共通、1 番を S1A の「1」と S1B の「2」、4 番を S1A の「2」と S1B の「1」に渡り線でつなぐ
- SP2 (k6・l6) は子機へ行く 2 芯の線、SP1 (r7・s7) は親機のスピーカー。どちらも 1 番が +、2 番が GND
- **AD3 は確かめるときだけ挟む一時的な接続**。V+ (5 V) を a17、GND を a5、W1 と Scope の 1+ を R1 の上の端 (p11)、2+ を SP2 の + (k7) に挟む。1−・2− は GND
- ふだん使うときの電源は USB の 5 V のアダプタにする。大きな声で鳴らすと LM386 が 100 mA を超えて引くことがあり、AD3 の Supplies では足りない。下の確かめ方の小さな音なら 16 mA ほどで、AD3 で足りる

## 計器の設定

計器は AD3。S1 を「2 話す」にして、声の代わりに W1 から 1 kHz を R1 経由で SP1 に入れ、子機の SP2 に出る波を見る。
SP1 の上の電圧は W1 × 8 Ω ÷ (10 kΩ + 8 Ω) で 1/1250 になり、振幅 2 V の W1 なら 1.6 mV。これを LM386 が 200 倍して、SP2 に振幅 0.31 V が出る。
1.6 mV は小さくて Scope では読みにくいので、W1 と出力を比べ、全体で 0.16 倍 (200 ÷ 1250) になっていることを確かめる。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| W1 | 正弦波 1 kHz、振幅 2 V (4 Vpp)、オフセット 0 V |
| S1 | 「2 話す」 |
| CH1 (1+) | W1 (R1 の上の端)。1 V/div |
| CH2 (2+) | SP2 の + (子機のスピーカー)。100 mV/div |
| 時間レンジ | 200 µs/div |
| トリガ | CH1 の立ち上がり、0 V |
| Measurements | Peak2Peak・Frequency |
| カーソル | X1 を 250 µs (山)、X2 を 750 µs (谷) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 S1 を「話す」にして W1 を SP1 に入れると SP2 に 0.62 Vpp が出る
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div}
ch2: {wave: sine 1kHz 0.31V, range: 100mV/div}
cursors: [250us, 750us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/06-intercom-lm386.svg)

- CH1 は 4 Vpp、CH2 は 0.62 Vpp。X1 で CH1 = 2.00 V・CH2 = 0.31 V、X2 で −2.00 V・−0.31 V。LM386 は + 入力から入れると反転しないので、2 本は同じ向きに振れる
- SP2 には (0.31 V)² ÷ 2 ÷ 8 Ω ≈ 6 mW が入り、子機から 1 kHz の音が小さく聞こえる
- W1 を 90 Hz に下げると CH2 が 0.71 倍 (−3 dB) ほどに減る。C6 と 8 Ω の低域の端
- 確かめたら W1 を外し、S1 を「1 聞く」に戻して子機のスピーカーに話しかけ、親機で声が聞こえるのを確かめる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オーディオ用パワーアンプ IC | LM386N-1 (動作電圧 4〜12 V) |
| SP1・SP2 | スピーカー (2 ピンのヘッダにつなぐ) | 8 Ω、0.5 W 程度の小型品。SP2 は子機で、2 芯の線 (数 m) で親機とつなぐ |
| S1 | トグルスイッチ (J1 につなぐ) | 2 回路 2 接点 (ON-ON)。押している間だけ「話す」になるモーメンタリ型 (ON-(ON)) でもよい |
| J1 | ピンヘッダ | 4 ピン |
| C1 | 電解コンデンサ (利得) | 10 µF・16 V |
| C2 | 電解コンデンサ (BYPASS) | 10 µF・16 V |
| C3 | 電解コンデンサ (電源) | 100 µF・16 V |
| C4 | セラミックコンデンサ (電源) | 0.1 µF (104) |
| C5 | セラミックコンデンサ (発振止め) | 47 nF (473) |
| C6 | 電解コンデンサ (出力) | 220 µF・16 V |
| R1 | 抵抗 (確かめの入口) | 10 kΩ |
| R2 | 抵抗 (発振止め) | 10 Ω |
| — | 電源 | 5 V (ふだんは USB の 5 V のアダプタ。確かめるときは AD3 の V+) |
| — | 計器 | Analog Discovery 3 の W1 と Scope (1+ = W1、2+ = SP2 の +、1−・2− = GND) |

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| LM386 の 5 番 (出力) の直流 | 約 2.5 V (電源の半分。テスター) |
| W1 4 Vpp・1 kHz のときの SP2 | 0.62 Vpp (W1 の 0.16 倍、計算値) |
| W1 を 90 Hz に下げたときの SP2 | 1 kHz の約 0.71 倍 |
| 確かめるときの電源の電流 | 約 16 mA (静止電流 4 mA と、出力の電流) |
| S1 を「1 聞く」にして子機に話す | 親機の SP1 から声が出る |

## LTspice での確かめ

`sim/06-intercom-lm386.cir` で、S1 を「話す」にした状態 (W1 → R1 → SP1 → LM386 → C6 → SP2) を 1 kHz と 90 Hz で過渡解析した。
LM386 は SPICE の模型がデータシートに無いので、データシートの値 (入力抵抗 50 kΩ、利得 200、静止電流 4 mA) で作った振る舞いの模型で表した (仮定)。
スピーカーは 8 Ω の抵抗。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| SP1 の上 (LM386 の入力) | 3.2 mVpp (振幅 1.6 mV) | 3.20 mVpp | 合う |
| 入力から出力 (5 番) までの利得 | 200 倍 | 197 倍 | 合う (模型の出力抵抗のぶん少ない) |
| 1 kHz の SP2 | 0.62 Vpp | 0.621 Vpp | 合う |
| SP2 に入る電力 | 約 6 mW | 6.0 mW | 合う |
| 90 Hz の SP2 (1 kHz との比) | 約 0.71 倍 | 0.445 Vpp (0.72 倍) | 合う |
| 電源の電流 (1 kHz) | 約 16 mA | 16.3 mA | 合う (出力の電流の半波を電源が出す近似) |

S1 の切り替え (「聞く」で SP2 → 入力・出力 → SP1) は、図1 のネットリストで確かめた: S1A の 1 と S1B の 2 が SP2、S1A の 2 と S1B の 1 が SP1 につながる。

## 出典

自作。LM386 の利得の決め方・使わない入力の扱い・発振止め・静止電流・動作電圧は [LM386 のデータシート (TI)](https://www.ti.com/lit/ds/symlink/lm386.pdf) による。

参考: [インターホン (Wikipedia)](https://ja.wikipedia.org/wiki/インターホン)、[マイクロホン (Wikipedia)](https://ja.wikipedia.org/wiki/マイクロホン)
