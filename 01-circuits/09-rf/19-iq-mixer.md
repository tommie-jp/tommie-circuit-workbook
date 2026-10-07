---
book: circuits
chapter: 9
id: 9-19
title: I/Q ミキサー — RF が LO の上か下かを知る
tier: 200
source: 自作
board: BB
---

# 9-19 I/Q ミキサー — RF が LO の上か下かを知る

9-12 のバランスドミキサーは、RF と LO を掛けて**差の周波数 (IF)** を取り出した。
ところが掛け算 1 つでは、**RF が LO の上にあるか下にあるかが分からない**。
LO = 498 kHz に対して、RF = 547.8 kHz でも 448.2 kHz でも、IF は同じ **49.8 kHz** になる。
cos は偶関数なので cos(+Δωt) と cos(−Δωt) が同じ波になり、差の符号が消えるからだ。

この題では、ミキサーを 2 つ並べて符号を取り戻す。

- 1 つ目のミキサー (U1) には LO をそのまま、2 つ目 (U2) には LO を **90° ずらして**入れる。
  出力の 2 本を **I** (In-phase、同相) と **Q** (Quadrature、直交) と呼ぶ
- 2 本はどちらも 49.8 kHz だが、**RF が LO の上なら Q が I より 90° 先、下なら Q が I より 90° 後**になる。
  49.8 kHz の 1/4 周期は **5.02 µs** で、オシロの 2 本の波のずれで上下が読める
- I と Q の組は、横を I、縦を Q とした平面の上を回る 1 つの点と見なせる。点は 49.8 kHz で回り、
  **回る向きが周波数の符号**を持つ (この題の名前の付け方では、RF が上なら右回り、下なら左回り)。
  これがイメージ除去 (9-20)、SSB (9-21)、ソフトウェアラジオ (9-22〜9-24) の土台になる

**90° の作り方は 9-18 の RC-CR 網**を使う。R 680 Ω・C 470 pF の網は、高域側 (C が直列、R が GND へ) で
+45°、低域側 (R が直列、C が GND へ) で −45° ずらし、2 本の差は**どの周波数でも 90°** になる。
振幅がそろうのは f<sub>c</sub> = 1/(2πRC) = **497.9 kHz** だけだ。そこで 90° ずらすのは、
周波数が変わる RF ではなく、**固定の LO** の側にする。LO を f<sub>c</sub> に合わせた 498 kHz に置けば、
2 本の LO は同じ振幅 (W1 の 0.707 倍) で、ちょうど 90° 離れる。

**I と Q の名前の決め方。** この題では、LO の**高域側 (+45°) で混ぜたほうを I**、**低域側 (−45°) で混ぜたほうを Q** と呼ぶ。
LO<sub>I</sub> = cos(ω<sub>LO</sub>t + 45°)、LO<sub>Q</sub> = cos(ω<sub>LO</sub>t − 45°) なので、Q 側の LO は I 側より 90° 遅れている。
RF = cos(ω<sub>RF</sub>t) と掛けた差の成分は、Δω = ω<sub>RF</sub> − ω<sub>LO</sub> として

- I = ½ cos(Δωt − 45°)、Q = ½ cos(Δωt + 45°)
- **RF が上 (Δω > 0)**: Q の位相は I より 90° 進む。**Q が I より 5.02 µs 先**に山を迎える
- **RF が下 (Δω < 0)**: cos(−x) = cos(x) で書き直すと I = ½ cos(|Δω|t + 45°)、Q = ½ cos(|Δω|t − 45°)。
  **Q が I より 5.02 µs 後**になる

名前を逆に付ければ先と後も逆になる。決めごとなので、どちらでもよいが、1 度決めたら回路と計算をそろえる。
**オシロの 2 つのチャンネルは同じ向きに挿す** (1+ を PIN 4、1− を PIN 5、2+ と 2− も同じ)。
片方だけ逆に挿すとその波が 180° 返り、先と後が入れ替わって見える。

**スペクトルでは分からない。** CH1 だけ (あるいは CH2 だけ) を Spectrum で見ると、
RF が上でも下でも 49.8 kHz に同じ高さの線が 1 本立つだけだ。上下の違いは I と Q の**位相の関係**にしか無い。

## 回路図

```circuit
title: 図1 SA612 を 2 個並べた I/Q ミキサー (W2 が RF、W1 が LO)
parts:
  W2: sine 1,5 1,7 l=$\mathrm{W2}$
  G1: ground 1,7
  C5: capacitor 5,5 6,5 10n
  C6: capacitor 5,17 6,17 10n
  U1: ic 16,7.5 SA612
  U2: ic 16,19.5 SA612
  C7: capacitor 11,9 11,10 10n
  G2: ground 11,10
  G3: ground 16,10
  C8: capacitor 11,21 11,22 10n
  G4: ground 11,22
  G5: ground 16,22
  VCC: vcc 16,3 5V
  C9: capacitor 14,3 14,4 100n
  G6: ground 14,4
  VCC: vcc 16,15 5V
  C10: capacitor 14,15 14,16 100n
  G7: ground 14,16
  C11: capacitor 22,6 22,10 470p
  M1: voltmeter 25,6 25,10 l=$\mathrm{CH1}$
  C12: capacitor 22,18 22,22 470p
  M2: voltmeter 25,18 25,22 l=$\mathrm{CH2}$
  C3: capacitor 13,12 12,12 10n
  C1: capacitor 9,12 8,12 470p
  R2: resistor 10,12 10,13 680
  G8: ground 10,13
  R1: resistor 7,15 7,14 680
  C2: capacitor 7,15 7,16 470p
  G9: ground 7,16
  C4: capacitor 9,19 9,18 10n
  W1: sine 5,12 5,14 l=$\mathrm{W1}$
  G10: ground 5,14
wires:
  - 1,5 -- 3,5
  - 3,5 -- 5,5
  - 3,5 -- 3,17
  - 3,17 -- 5,17
  - 6,5 -- 13,5
  - U1.IN_A -| 13,5
  - 6,17 -- 13,17
  - U2.IN_A -| 13,17
  - U1.IN_B -| 11,9
  - U2.IN_B -| 11,21
  - U1.GND |- 16,10
  - U2.GND |- 16,22
  - U1.VCC |- 16,3
  - 16,3 -- 14,3
  - U2.VCC |- 16,15
  - 16,15 -- 14,15
  - U1.OUT_A -| 19,6
  - 19,6 -- 22,6
  - 22,6 -- 25,6
  - U1.OUT_B -| 20,10
  - 20,10 -- 22,10
  - 22,10 -- 25,10
  - U2.OUT_A -| 19,18
  - 19,18 -- 22,18
  - 22,18 -- 25,18
  - U2.OUT_B -| 20,22
  - 20,22 -- 22,22
  - 22,22 -- 25,22
  - U1.OSC_B -| 13,12
  - 12,12 -- 10,12
  - 10,12 -- 9,12
  - 7,12 -- 8,12
  - 5,12 -- 7,12
  - 7,12 -- 7,14
  - 7,15 -- 9,15
  - 9,15 -- 9,18
  - 9,19 -- 9,23
  - 9,23 -- 13,23
  - U2.OSC_B -| 13,23
notes:
  - text 10,11 small center: LO_I +45°
  - text 9.5,14.5 small center: LO_Q -45°
  - text 26,8 small center: I
  - text 26,20 small center: Q
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/19-iq-mixer.svg)

図1 の `+5V` は AD3 の電源出力 V+ (Supplies で 5 V)。SA612 は 4.5〜8 V で動き、1 個 2.4 mA ほど (データシートの代表値)。
2 個で 5 mA ほどなので、AD3 の Supplies で足りる。

- **RF (W2、左上)** は 1 本の線を 2 つに分け、C5 と C6 (10 nF) を通して U1 と U2 の PIN 1 (IN_A) へ入れる。
  PIN 2 (IN_B) は C7・C8 で交流だけ GND に落とす。ここまでは 9-12 と同じ使い方を 2 組並べただけだ。
  PIN 1 を 1 本の C でまとめないのは、2 個の IC の入力の直流の偏りどうしをつながないため
- **LO (W1、左)** は 9-18 の RC-CR 網で 2 本に分ける。高域側は C1 (470 pF) が直列で R2 (680 Ω) が GND へ — ここが **LO<sub>I</sub> (+45°)**。
  低域側は R1 (680 Ω) が直列で C2 (470 pF) が GND へ — ここが **LO<sub>Q</sub> (−45°)**。
  それぞれ C3・C4 (10 nF) を通して U1・U2 の PIN 6 へ入れる。498 kHz での 10 nF は 32 Ω で、網にはほとんど効かない
- 図は RF と LO が左から入り、出力は各 IC の右に出る。SA612 は IN_A・IN_B・OSC_B が左の辺に上から並ぶので、
  RF は IC の上から、LO は IC の下から回して入れた。U2 へ行く LO<sub>Q</sub> の線は、U2 へ行く RF の線と 1 か所で交わる
  (黒丸の無い交差で、つながっていない)
- W1 は振幅 0.25 V (0.5 V<sub>pp</sub>)。網の出口は 0.707 倍の **0.354 V<sub>pp</sub>** で、データシートが外部 LO に求める
  **200 mV<sub>pp</sub> 以上**を満たす。網の出口に PIN 6 がつながると振幅は少し下がるが、2 本は同じだけ下がる
  (10 kΩ で受けたときの計算で、どちらも 0.707 → 0.683)。位相差は 90° のまま
- AD3 の Wavegen の出力抵抗はほぼ 0 Ω なので、網は W1 の電圧で直に駆動される。網の位相差が 90° になる条件はこれだけ
  (信号源に抵抗があると、2 本の枝がその抵抗を分け合って位相が崩れる)
- **出力**は各 IC の PIN 4 (OUT_A) と PIN 5 (OUT_B)。内部の 1.5 kΩ で VCC に吊られていて、2 本の間には 3 kΩ の源が見える。
  その間に **C11・C12 (470 pF)** を渡すと、低域の角は 1/(2π × 3 kΩ × 470 pF) ≈ **113 kHz** になる。
  49.8 kHz の IF は 0.915 倍 (−0.8 dB) しか下がらず、和の成分 (1045.8 kHz や 946.2 kHz) は約 0.11 倍 (−19 dB) に下がる。
  **2 個のミキサーに同じ値を付ける**ので、位相のずれ (49.8 kHz で −24°) も 2 本で同じになり、I と Q の 90° は崩れない
- **CH1 は U1 の PIN 4 − PIN 5 (I)、CH2 は U2 の PIN 4 − PIN 5 (Q)**。AD3 の Scope の入力はもともと差動なので、
  平衡の出力をそのまま測れる。9-12 と違って直流を切る C を入れていない。PIN 4 と PIN 5 はどちらも約 4 V で、
  差動で見れば直流はほぼ消えるからだ (残るのは 2 本の作りの差だけ)。AD3 の入力は ±25 V まで受けられる
- PIN 7 (発振のエミッタ) は開けておく。外から LO を注ぐ使い方なので使わない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (左が U1 = I、右が U2 = Q)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W2, V+, GND, 1-, 1+, W1, 2-, 2+]
  U1: dip8 @ e4 SA612
  U2: dip8 @ e22 SA612
  C9: capacitor/ceramic +t3 -t3 100n
  C10: capacitor/ceramic +t28 -t28 100n
  C3: capacitor/ceramic c9 c12 10n
  R2: resistor b12 -t12 680
  C1: capacitor/ceramic d12 d15 470p
  R1: resistor c15 c19 680
  C2: capacitor/ceramic b19 -t19 470p
  C4: capacitor/ceramic d19 d21 10n
  C11: capacitor/ceramic b7 b8 470p
  C12: capacitor/ceramic b25 b26 470p
  C5: capacitor/ceramic g1 g4 10n
  C6: capacitor/ceramic g19 g22 10n
  C7: capacitor/ceramic j5 -b5 10n
  C8: capacitor/ceramic j23 -b23 10n
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t2 black
  - -t30 -- -b30 black
  - +t4 -- a4 red
  - +t22 -- a22 red
  - j6 -- -b6 black
  - j24 -- -b24 black
  - AD.W2 -- f1 yellow
  - i1 -- i19 yellow
  - AD.W1 -- a15 green
  - d6 -- d9 green
  - c21 -- c24 green
  - h7 -- h8 orange
  - f8 -- e8 orange
  - h25 -- h26 purple
  - f26 -- e26 purple
  - AD.1- -- a7 blue
  - AD.1+ -- a8 orange
  - AD.2- -- a25 blue
  - AD.2+ -- a26 purple
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/19-iq-mixer.svg)

- U1 は 4〜7 列、U2 は 22〜25 列で溝をまたぐ (切り欠きを左、PIN 1 は左下)。どちらも下の列が PIN 1〜4、上の列が PIN 8〜5。
  胴にはピンの番号と名前が出る
- **電源**: AD3 の V+ (赤) を上の + レールの 2 列、GND (黒) を上の − レールの 2 列へ。
  PIN 8 (VCC) は 4 列・22 列から赤い線で + レールへ。パスコン C9・C10 (100 nF) は IC のすぐ脇で、上の + と − のレールに直に挿す。
  PIN 3 (GND) は 6 列・24 列から黒い線で下の − レールへ。上下の − レールは 30 列の黒い線で渡す
- **LO (緑)**: AD3 の W1 を 15 列に挿す。15 列が網の入口。C1 (12〜15 列) を通った 12 列が **LO<sub>I</sub>**
  で、R2 (680 Ω) が 12 列から上の − レールへ立つ。R1 (15〜19 列) を通った 19 列が **LO<sub>Q</sub>** で、C2 (470 pF) が 19 列から − レールへ立つ。
  LO<sub>I</sub> は C3 (9〜12 列) と緑の線 (9 列 → 6 列) で U1 の PIN 6 へ、LO<sub>Q</sub> は C4 (19〜21 列) と緑の線 (21 列 → 24 列) で U2 の PIN 6 へ
- **RF (黄)**: AD3 の W2 を 1 列の下の段 (f1) に挿す。C5 (1〜4 列) で U1 の PIN 1 へ。黄の線 (i1〜i19) で 19 列へ渡し、C6 (19〜22 列) で U2 の PIN 1 へ。
  PIN 2 は C7・C8 (10 nF) で下の − レールへ落とす
- **出力 (I)**: U1 の PIN 4 (下の 7 列) を橙の線で 8 列へ移し、溝をまたぐ橙の線 (f8〜e8) で上の 8 列へ上げる。
  上の 7 列が PIN 5、8 列が PIN 4 になり、その間に C11 (470 pF) を渡す。CH1 の 1− (青) を 7 列、1+ (橙) を 8 列に挿す
- **出力 (Q)**: U2 も同じ形で、PIN 4 を紫の線で 26 列へ上げる。C12 を 25〜26 列に渡し、CH2 の 2− (青) を 25 列、2+ (紫) を 26 列に挿す
- 周波数はいちばん高い所でも LO と RF の和の約 1 MHz で、ブレッドボードの 3 MHz の範囲に収まる。
  網の 470 pF に比べて列どうしの浮遊容量は数 pF なので、網の部品は寄せて短く挿す

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1・U2 | ダブルバランスドミキサー IC | SA612A (NE612A)、DIP8 ×2。U1 が I、U2 が Q |
| R1・R2 | 抵抗 (RC-CR 網) | 680 Ω。± 1 % の金属皮膜だと 2 本の振幅と 90° がよくそろう |
| C1・C2 | セラミックコンデンサ (RC-CR 網、NP0/C0G) | 470 pF (471) |
| C3・C4 | セラミックコンデンサ (LO の結合) | 10 nF (103) |
| C5・C6 | セラミックコンデンサ (RF の結合) | 10 nF (103) |
| C7・C8 | セラミックコンデンサ (PIN 2 を交流で GND へ) | 10 nF (103) |
| C9・C10 | セラミックコンデンサ (電源のパスコン) | 100 nF (104) |
| C11・C12 | セラミックコンデンサ (和の成分を落とす、NP0/C0G) | 470 pF (471)。2 本は同じ種類・同じ誤差のものにする |
| — | 信号源・計器・電源 | Analog Discovery 3 (W1・W2、Scope の 2 チャンネル、V+ 5 V) |

## 計器の設定

Analog Discovery 3 だけを使う。LO と RF は 1 MHz 以下なので Wavegen の 2 チャンネルで作れ、
出力の 49.8 kHz は Scope の 2 チャンネル (差動) で見る。W1 と W2 は同じクロックから作られるので、
差の 49.8 kHz はふらつかず、オシロの絵が止まる。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない) |
| Wavegen W1 (LO) | Sine、498 kHz、振幅 0.25 V (0.5 V<sub>pp</sub>)、オフセット 0 V |
| Wavegen W2 (RF) | Sine、**547.8 kHz** (LO の上) と **448.2 kHz** (LO の下) を切り替える。振幅 10 mV、オフセット 0 V |
| Scope | CH1 = 1+ を U1 の PIN 4、1− を U1 の PIN 5。CH2 = 2+ を U2 の PIN 4、2− を U2 の PIN 5。どちらも 50 mV/div、5 µs/div。トリガは CH1 の立ち上がり 0 V |
| Scope (XY) | View を XY にし、横を CH1、縦を CH2 |

- W2 の振幅 10 mV は 9-12 と同じ。SA612 の入力は数十 mV で飽和し始める
- 2 本の比べは**同じ尺度** (50 mV/div) で見る。振幅の差も I/Q のずれのうちだからだ
- 50 mV/div で 183 mV<sub>pp</sub> は約 3.7 目盛。20 mV/div では画面からはみ出す

## 計器の画面

計算値 (振幅は目安)。9-12 の変換利得 17 dB (7.08 倍、片側の出力・1 側波あたり) から、
差動の IF は 10 mV × 7.08 × 2 = 142 mV (peak) と見積もる。この題では LO が網で 0.707 倍になる分、
SA612 の切り替えが浅くなって利得も同じだけ下がると見て ×0.707、さらに C11・C12 の低域で ×0.915:

142 mV × 0.707 × 0.915 ≈ **91.6 mV (peak)、183 mV<sub>pp</sub>** (目安)

LO が十分に大きく切り替えが深いままなら、×0.707 は掛からず 130 mV (peak) ほどになる。
SA612 の利得は個体差もあるので、**大きさは目安、位相の関係が本題**だ。

```scope
title: 図3 W2 = 547.8 kHz (LO の上) — Q が I より 1/4 周期先
time: 5us/div
trigger: ch1 rising 0V
ch1: {wave: sine 49.8kHz 91.6mV, range: 50mV/div}
ch2: {wave: sine 49.8kHz 91.6mV phase 90deg, range: 50mV/div}
cursors: [-5.02us, 0]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/19-iq-mixer-1.svg)

```scope
title: 図4 W2 = 448.2 kHz (LO の下) — Q が I より 1/4 周期後
time: 5us/div
trigger: ch1 rising 0V
ch1: {wave: sine 49.8kHz 91.6mV, range: 50mV/div}
ch2: {wave: sine 49.8kHz 91.6mV phase -90deg, range: 50mV/div}
cursors: [0, 5.02us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/19-iq-mixer-2.svg)

- 図3 と図4 は同じ尺度 (50 mV/div・5 µs/div・CH1 の立ち上がりでトリガ) で、W2 だけを替えた
- **図3 (上)**: CH2 (Q) は CH1 (I) より 5.02 µs 早く 0 V を上へ横切る。カーソル X1 を Q の、X2 を I の立ち上がりの 0 V に置くと
  ΔX = **5.02 µs**。Measurements の Phase は CH2 が **+90°** (CH1 より進み)
- **図4 (下)**: Q は I より 5.02 µs 遅れて横切る。Phase は **−90°**
- 周波数 (49.8 kHz) と振幅 (183 mV<sub>pp</sub>) は図3 と図4 で同じ。**1 本だけを見ては区別できない**
- 実物では、49.8 kHz の上に和の成分 (約 1 MHz) の細かい揺れが 11〜12 mV (peak) ほど残る (C11・C12 で −19 dB、目安)。
  ずれを読む 0 V の横切りでは小さいので、位相の読みには効かない

```scope
title: 図5 XY — I と Q は円になる (上でも下でも同じ円)
view: xy
ch1: {wave: sine 49.8kHz 91.6mV, range: 50mV/div}
ch2: {wave: sine 49.8kHz 91.6mV phase 90deg, range: 50mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/19-iq-mixer-3.svg)

- 横 I、縦 Q で描くと、振幅がそろって 90° 離れた 2 本は**円**になる (02-analog-discovery/02-oscilloscope/05-xy-lissajous.md の図3 と同じ)。
  網の振幅がずれると楕円に、90° からずれると斜めの楕円になるので、I/Q がそろっているかの点検に使える
- 点は RF が上なら右回り (I = cos、Q = −sin)、下なら左回りに円を回る。**止まった絵では回る向きが見えない**ので、
  図5 は上でも下でも同じ円になる。符号は図3・図4 の時間の波で読む
- 回る向きを目で見たいときは、W2 を LO にごく近い **498.0005 kHz** (IF 0.5 Hz) にする。点が 2 秒に 1 周、ゆっくり回る
  (W2 を 497.9995 kHz にすると逆回り)。差動の入力は直流から測れるので、0.5 Hz でも見える

## 見るべき値

計算値 (振幅は目安)。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 (CH1・CH2) | 49.8 kHz。W2 が 547.8 kHz でも 448.2 kHz でも同じ |
| IF の振幅 (差動) | 約 183 mV<sub>pp</sub> (目安。LO が浅い見積もりで 91.6 mV peak、深ければ 130 mV peak ほど)。CH1 と CH2 でほぼ同じ |
| W2 = 547.8 kHz (上) の Q と I のずれ | Q が **5.02 µs 先** (Phase +90°、図3) |
| W2 = 448.2 kHz (下) の Q と I のずれ | Q が **5.02 µs 後** (Phase −90°、図4) |
| XY (図5) | 円。振幅比 1:1 (網の振幅が 498 kHz でそろうため) |
| 網の出口の LO (各 PIN 6 の手前) | 0.354 V<sub>pp</sub>、2 本の差は 90.0° (9-18 と同じ網) |
| C11・C12 の低域の角 | 1/(2π × 3 kΩ × 470 pF) ≈ 113 kHz。IF は ×0.915、和の成分は ×0.11 |
| 2 つのチャンネルのどちらか片方を逆に挿す | 波が 180° 返り、先と後が入れ替わって見える (上と下を取り違える) |
| W1 を 300 kHz、W2 を 349.8 kHz にする (LO を網の f<sub>c</sub> から外す) | 網の振幅が 0.856 : 0.516 になり、XY は円から軸のそろった楕円になる。位相差は 90° のまま (9-18) |
| 片方のミキサーだけ (9-12) の Spectrum | 上でも下でも 49.8 kHz の線が同じ高さで 1 本。上下は分からない |

## 出典

自作。SA612A のピンの並び (PIN 1・2 = RF 入力、3 = GND、4・5 = 出力、6・7 = 発振、8 = VCC)、
電源電圧 4.5〜8 V、出力の内部抵抗 1.5 kΩ、変換利得 (代表 17 dB)、外部 LO の 200 mV<sub>pp</sub> 以上は
NXP の SA612A データシートと応用ノート AN1983 による。RC-CR 網の位相差と振幅、I と Q の先後は、
網の式と掛け算の三角関数からの計算値 (LTspice で 300 k・498 k・800 kHz の 90.0° を確かめた)。
IF の大きさは 9-12 の見積もりからの目安で、実測していない。
