---
book: circuits
chapter: 9
id: 9-20
title: イメージ除去 — 位相法 (Hartley)
tier: 200
board: BB
source: 自作
era: 古
---

# 9-20 イメージ除去 — 位相法 (Hartley)

9-10 のスーパーヘテロダインは、受けた電波 (RF) と局部発振 (LO) を混ぜて、差の中間周波数 (IF) を取り出していた。
LO が 498 kHz、IF が 49.8 kHz なら、**LO の上の 547.8 kHz も、LO の下の 448.2 kHz も、同じ 49.8 kHz になる**。
片方が受けたい局で、もう片方は**イメージ** (影の局) と呼ぶ。ミキサーが 1 つだと、出てきた 49.8 kHz がどちらから来たかは区別できない (9-12)。
9-10 は、ミキサーの前の同調回路で片方を落としていた。

9-19 では、LO を 90° ずらしたミキサーをもう 1 つ足した (I/Q ミキサー)。すると 2 つの IF の**位相の先後**で、RF が LO の上か下かが分かった。
**上か下かが分かれば、片方だけを消せる**。I と Q の IF をもう一度 90° ずらしてから足すと、片方の側は同じ向きで足し合わさり、
反対側は逆向きで打ち消し合う。これが**位相法**のイメージ除去で、Hartley が 1920 年代に考えた形だ。
同調回路を使わず、位相だけでイメージを消す。この題では、LO の下 (448.2 kHz) を残し、上 (547.8 kHz) を消す。

- **前半は 9-19 と同じ**。W1 (LO、498 kHz) を 9-18 の RC-CR 網 (680 Ω・470 pF、fc = 497.9 kHz) で 2 つに分ける。
  高域側 (+45°) で U1 を動かした出力が **I**、低域側 (−45°) で U2 を動かした出力が **Q**。RF (W2) は U1 と U2 の両方に入れる
- 9-19 と違うのは、出力を**片側 (PIN 4) だけ**取ること。PIN 4 には 470 pF を GND へ付けて、1 MHz 付近の和の成分を減らす
  (内部の 1.5 kΩ と組んで fc ≈ 226 kHz。49.8 kHz では 0.98 倍で、I と Q で同じなので位相の差は変わらない)
- I と Q は MCP6002 のボルテージフォロア (U3) で受ける。次の網の負荷で SA612 の出力が変わらないようにするためだ。
  MCP6002 の GBW は約 1 MHz なので、498 kHz の LO を通す所には使わない。ここを通るのは主に 49.8 kHz の IF だ
- 1 µF で直流を切ってから、**IF の 90° 網** (R 6.8 kΩ・C 470 pF、fc = 1/(2π·6.8 kΩ·470 pF) = 49.80 kHz) に通す。
  **I は低域側** (6.8 kΩ が直列、470 pF が下) で −45°、**Q は高域側** (470 pF が直列、6.8 kΩ が下) で +45°。
  9-18 と同じく、2 本の位相差はどの周波数でも 90° で、振幅がそろうのは fc の 49.8 kHz だけ
- 最後に U4B の反転加算で足す (R7・R8 + VR1・R9 がどれも約 100 kΩ で、出力 = −(I 側 + Q 側))。
  U4A は 10 kΩ・10 kΩ の分圧をバッファした **VREF = 2.5 V** を作る。5 V の単電源で交流を扱うための仮の GND で (4-11 の形)、
  加算の + 入力と、Q 側の網の 6.8 kΩ の下の端をここに返す

## 下だけが残るわけ

I の LO を高域側 (+45°)、Q の LO を低域側 (−45°) にしたので、I の LO は Q の LO より 90° 進んでいる。
掛け算の差の成分は、RF が LO の上なら RF − LO の向き、下なら LO − RF の向きで回るので、9-19 で見たとおり
**RF が上 (547.8 kHz) なら Q が I より 90° 進み、下 (448.2 kHz) なら Q が 90° 遅れる**。

- 下 (448.2 kHz): Q = I を 90° 遅らせた波。I は低域側で −45°、Q は高域側で +45° 進むので、Q は −90° + 45° = **−45°**。
  I 側も −45° なので、2 本は**同じ位相**で足し合わさる (振幅は 0.707 + 0.707 = 1.41 倍)
- 上 (547.8 kHz): Q = I を 90° 進めた波。Q は +90° + 45° = **+135°**、I 側は −45°。差は **180°** で、振幅が同じなら**打ち消し合う**
- I と Q を入れ替える (網の低域側と高域側を入れ替える) と、残る側も入れ替わり、上 (547.8 kHz) が残る

## 消え方は部品のそろい方で決まる

打ち消しの深さは、2 本の振幅と位相がどれだけそろうかで決まる。理想の部品なら LTspice の模型で 59 dB 下がった。実物は次の 3 つでずれる。

- **2 つの SA612 の変換利得の差**。振幅が 5 % 違うだけで、消え残りは 32 dB 下までにとどまる (20 log(2/0.05))。
  Q 側の入力抵抗を **91 kΩ + 半固定 20 kΩ (VR1)** にして、Q 側の利得を約 ±10 % の範囲で合わせる
- **2 つの 90° 網 (LO の 680 Ω・470 pF と IF の 6.8 kΩ・470 pF) の部品のばらつき**。位相が 3° ずれるだけで 32 dB にとどまる
- 網の R と C を一様にばらつかせた計算 (2 万回) では、±1 % の部品で中央値 46 dB (悪いほうから 1 割の所で 41 dB)、
  **±5 % で中央値 32 dB (27 dB)**、±10 % で 26 dB (21 dB)。セラミックコンデンサは ±5 % が多いので、**25〜35 dB ほど**を見込む
- VR1 が直せるのは振幅だけで、位相のずれは残る。±5 % の網で振幅だけを合わせきると、中央値 37 dB (悪いほうから 1 割で 30 dB) になる
  (計算値)。さらに深く消したいなら、±1 % の部品を選ぶか、IF の網の 6.8 kΩ の片方を 6.2 kΩ + 1 kΩ の半固定にして位相も合わせる

## 回路図

```circuit
title: 図1 位相法のイメージ除去 (W1 が LO、W2 が RF)
parts:
  U3A: opamp j25e0 +up
  U3B: opamp t25e0 +up
  C13: capacitor j28e0 j30e0 1u
  R3: resistor j31e0 j34e0 6.8k
  C14: capacitor j35e0 l35d0 470p
  G17: ground l35d0
  M1: voltmeter k31d0 m31d0 l=$\mathrm{CH1}$
  VREF: port m31d0
  C15: capacitor t28e0 t30e0 1u
  C16: capacitor t31e0 t34e0 470p
  R4: resistor t35e0 v35d0 6.8k
  VREF: port v35d0
  R7: resistor j36e0 j39e0 100k
  R8: resistor t36e0 t38e0 91k
  VR1: resistor-var t38e0 t40e0 20k l=$\mathrm{VR1}$
  R9: resistor j42e0 j45e0 100k
  U4B: opamp o44d0 +down
  VREF: port s43
  M2: voltmeter p49d0 r49d0 l=$\mathrm{CH2}$
  VREF: port r49d0
  VCC: vcc w32 5V
  R5: resistor w32 y32 10k
  R6: resistor y32 aa32 10k
  G11: ground aa32
  U4A: opamp y39d0 +up
  VREF: port y43d0
  VCC: vcc ab4 5V
  C9: capacitor ab4 ad4 100n
  C10: capacitor ab7 ad7 100n
  C18: capacitor ab10 ad10 100n
  C19: capacitor ab13 ad13 100n
  G13: ground ad4
  G14: ground ad7
  G15: ground ad10
  G16: ground ad13
  W2: sine h1 j1 l=$\mathrm{W2}$
  G4: ground j1
  C5: capacitor h5 h6 10n
  C6: capacitor r5 r6 10n
  U1: ic j16 SA612
  VCC: vcc g16 5V
  G6: ground m16
  C7: capacitor k11 l11 10n
  G5: ground l11
  C11: capacitor j19 l19 470p
  G7: ground l19
  U2: ic t16 SA612
  VCC: vcc q16 5V
  G9: ground w16
  C8: capacitor u11 v11 10n
  G8: ground v11
  C12: capacitor t19 v19 470p
  G10: ground v19
  W1: sine n5 p5 l=$\mathrm{W1}$
  G1: ground p5
  C2: capacitor n8 n9 470p
  R2: resistor n10 o10 680
  G2: ground o10
  C3: capacitor n12 n13 10n
  R1: resistor n7 p7 680
  C1: capacitor p7 q7 470p
  G3: ground q7
  C4: capacitor s9 t9 10n
wires:
  - U3A.out -- j27e0 -- j28e0
  - j27e0 -- l27 -- l24
  - l24 |- U3A.-
  - U3B.out -- t27e0 -- t28e0
  - t27e0 -- v27 -- v24
  - v24 |- U3B.-
  - j30e0 -- j31e0
  - j31e0 -- k31d0
  - j34e0 -- j35e0 -- j36e0
  - t30e0 -- t31e0
  - t34e0 -- t35e0 -- t36e0
  - j39e0 -- j40e0 -- j42e0
  - j40e0 -- o40 -- t40e0
  - o40 -| U4B.-
  - U4B.+ -| s43
  - j45e0 -- j47e0 -- o47d0
  - U4B.out -- o47d0 -- o49d0 -- p49d0
  - y32 -- y35
  - y35 -| U4A.+
  - U4A.out -- y41d0 -- y43d0
  - y41d0 -- aa41 -- aa38
  - aa38 |- U4A.-
  - ab4 -- ab13
  - h1 -- h3
  - h3 -- h5
  - h3 -- r3
  - r3 -- r5
  - h6 -- h13
  - U1.IN_A -| h13
  - r6 -- r13
  - U2.IN_A -| r13
  - U1.IN_B -| k11
  - U2.IN_B -| u11
  - U1.GND |- m16
  - U2.GND |- w16
  - U1.VCC |- g16
  - U2.VCC |- q16
  - n5 -- n7
  - n7 -- n8
  - n9 -- n10
  - n10 -- n12
  - U1.OSC_B -| n13
  - p7 -- p9
  - p9 -- s9
  - t9 -- x9
  - x9 -- x13
  - U2.OSC_B -| x13
  - U1.OUT_A -| j19
  - j19 -| U3A.+
  - U2.OUT_A -| t19
  - t19 -| U3B.+
notes:
  - text j27 small center: I
  - text t27 small center: Q
  - text h32f5 small center: I は低域側 (-45°)
  - text r32f5 small center: Q は高域側 (+45°)
  - text m45 small left: 反転加算
  - text w41 small center: VREF 2.5 V
  - text aa8f5 small center: パスコン (U1 から U4 の電源ピン)
  - text ab24 small center: U3、U4 は MCP6002 (PIN 8 は +5V、PIN 4 は GND)
  - text m10 small center: LO_I (+45°)
  - text o8f5 small center: LO_Q (-45°)
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/20-image-reject-hartley.svg)

図1 の `+5V` は AD3 の Supplies の V+ (5 V)。W1 と W2 も AD3 の Wavegen。

- **左の中ほどが LO の 90° 網** (9-18 と同じ)。W1 から C2 (470 pF) → R2 (680 Ω) が高域側で LO_I (+45°)、R1 (680 Ω) → C1 (470 pF) が低域側で LO_Q (−45°)。
  それぞれ C3・C4 (10 nF) を通して U1・U2 の PIN 6 (発振のトランジスタのベース) へ。W1 は 0.5 V<sub>pp</sub> (振幅 0.25 V) で、
  網の出口は 0.354 V<sub>pp</sub>。SA612 が外からの LO に求める 200 mV<sub>pp</sub> 以上に足りる
- **RF (W2)** は C5・C6 (10 nF) を通して U1・U2 の PIN 1 へ。PIN 2 は C7・C8 (10 nF) で交流だけ GND に落とす (9-12 と同じ片側入力)
- 9-19 と同じく、RF は各 IC の上から、LO は IC の下から回して入れる。U2 へ行く LO_Q の線は、U2 へ行く RF の線と 1 か所で交わる
  (黒丸の無い交差で、つながっていない)
- **出力は PIN 4 だけ**。PIN 5 は使わない (開けておく)。PIN 7 も開けておく。PIN 4 の直流は 4 V ほどで、MCP6002 はレール to レールの入力なのでそのまま受けられる
- U3A・U3B (MCP6002 の 2 回路) はフォロア。C13・C15 (1 µF) で直流を切り、IF の網へ
- **I 側の網**: R3 (6.8 kΩ) が直列、C14 (470 pF) が GND へ。**Q 側の網**: C16 (470 pF) が直列、R4 (6.8 kΩ) が VREF へ。
  C14 はコンデンサで直流を通さないので、下の端は GND でよい (交流では、バッファした VREF も GND も同じ 0 V に見える)。
  R4 は直流を通すので、加算の − 入力 (直流は VREF) と同じ VREF に返す。GND に返すと、R4 → R8 に直流が流れて出力の中心が 2.5 V からずれる
- **加算 (U4B)**: R7 (100 kΩ)、R8 (91 kΩ) + VR1 (20 kΩ の半固定。可変の抵抗として使う)、R9 (100 kΩ)。VR1 を 9 kΩ にすると Q 側も 100 kΩ で、利得は I・Q とも 1 倍。
  出力の直流は VREF の 2.5 V
- **測る所**: CH1 は C13 の先の I (1+)、CH2 は加算の出力 (2+)。どちらも 1− と 2− を VREF につなぎ、**VREF との差**を見る。
  AD3 のスコープの入力は差動なので (9-12)、2.5 V の直流を引いた交流だけが画面に出る
- 回路図の CH1・CH2 は AD3 の Scope の入力。AD3 の Scope の入力は約 1 MΩ で、網の負荷にはほぼならない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (full。U1・U2 が SA612、U3・U4 が MCP6002)
board: full
parts:
  AD:
    type: device
    at: top
    label: AD3 (Supplies 5V・W1・W2)
    pins: [V+, GND, W2, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-, 2+, 2-]
  U1: dip8 @ e13 SA612
  U2: dip8 @ e27 SA612
  U3: dip8 @ e38 MCP6002
  U4: dip8 @ e52 MCP6002
  C9: capacitor/ceramic +t12 -t12 100n
  C10: capacitor/ceramic +t31 -t31 100n
  C18: capacitor/ceramic +t37 -t37 100n
  C19: capacitor/ceramic +t51 -t51 100n
  C5: capacitor/ceramic i11 i13 10n
  C7: capacitor/ceramic h14 h15 10n
  C11: capacitor/ceramic j16 -b16 470p
  C3: capacitor/ceramic b15 b18 10n
  R2: resistor a18 -t18 680
  C2: capacitor/ceramic c18 c22 470p
  R1: resistor b22 b25 680
  C1: capacitor/ceramic a25 -t25 470p
  C4: capacitor/ceramic c25 c29 10n
  C6: capacitor/ceramic i23 i27 10n
  C8: capacitor/ceramic h28 h29 10n
  C12: capacitor/ceramic j30 -b30 470p
  C13: capacitor/ceramic h38 h42 1u
  R3: resistor f42 f45 6.8k
  C14: capacitor/ceramic j45 -b45 470p
  R7: resistor g45 g50 100k
  R9: resistor g53 g57 100k
  C15: capacitor/ceramic a39 a43 1u
  C16: capacitor/ceramic d43 d46 470p
  R4: resistor a46 a48 6.8k
  R8: resistor c46 c49 91k
  VR1: potentiometer/trimmer b49 b50 b51 20k
  R6: resistor a55 -t55 10k
  R5: resistor c55 c58 10k
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t63 -- -b63 black
  - +t13 -- a13 red
  - +t27 -- a27 red
  - +t38 -- a38 red
  - +t52 -- a52 red
  - +t58 -- a58 red
  - j15 -- -b15 black
  - j29 -- -b29 black
  - j41 -- -b41 black
  - j55 -- -b55 black
  - AD.W2 -- a11 yellow
  - e11 -- f11 yellow
  - d11 -- d17 yellow
  - e17 -- f17 yellow
  - h17 -- h23 yellow
  - AD.W1 -- a22 green
  - g16 -- g40 orange
  - i30 -- i32 blue
  - f32 -- e32 blue
  - c32 -- c41 blue
  - i38 -- i39 gray
  - b39 -- b40 gray
  - SC.1+ -- j42 orange
  - SC.1- -- i48 white
  - f48 -- e48 white
  - j48 -- j54 white
  - d48 -- d53 white
  - b53 -- b54 gray
  - f50 -- e50 purple
  - h50 -- h53 purple
  - i52 -- i57 brown
  - SC.2+ -- j57 brown
  - SC.2- -- h54 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/20-image-reject-hartley.svg)

- ブレッドボードは full (63 列)。IC が 4 個あるので half には収まらない。上の 2 本のレールが +5 V (外側の赤) と GND (内側の青)。
  下の青い GND レールは 63 列の黒い線で上の GND とつなぐ。下の赤いレールは使わない。full のレールが途中で切れている製品なら、切れ目を線で渡す
- **IC の向き**: 4 個とも切り欠きを左に、PIN 1 は左下 (f 行)。下の列が PIN 1〜4、上の列が PIN 8〜5。
  胴にはピンの番号と名前が出る

- **電源**: 各 IC の PIN 8 を赤い線で + レールへ、SA612 の PIN 3 と MCP6002 の PIN 4 を黒い線で下の GND レールへ。
  パスコン C9・C10・C18・C19 (100 nF) は + レールと GND レールの間に直に挿す
- **LO (W1、緑)**: a22 に入れる。22 列から C2 (c18〜c22) が高域側で 18 列 (LO_I)、R2 (680 Ω) が 18 列から GND レールへ。
  C3 (b15〜b18) で U1 の PIN 6 (15 列の上) へ。R1 (b22〜b25) が低域側で 25 列 (LO_Q)、C1 (470 pF) が 25 列から GND レールへ。
  C4 (c25〜c29) で U2 の PIN 6 (29 列の上) へ
- **RF (W2、黄)**: a11 に入れ、e11〜f11 で下の段へ。C5 (i11〜i13) で U1 の PIN 1 へ。U2 へは d11〜d17 → e17〜f17 → h17〜h23 の黄の線で回し、C6 (i23〜i27) で U2 の PIN 1 へ
- **U1 の下の列**: C7 (h14〜h15) で PIN 2 を PIN 3 (GND) の列へ。C11 (470 pF) は PIN 4 の列 (16 列) から下の GND レールへ。
  **I** は g16〜g40 の橙の線で U3 の PIN 3 (VINA+) へ
- **U2 の下の列**: C8 (h28〜h29)、C12 (470 pF) は U1 と同じ。**Q** は i30〜i32 → f32〜e32 → c32〜c41 の青い線で U3 の PIN 5 (VINB+、41 列の上) へ
- **U3**: 灰の短い線がフォロアの帰還 (下は i38〜i39 で PIN 1・2、上は b39〜b40 で PIN 7・6)。
  I は C13 (h38〜h42) → 42 列 (CH1 の 1+) → R3 (f42〜f45) → 45 列 (I 側の網の節) → C14 (470 pF) で GND レールへ。
  Q は C15 (a39〜a43) → 43 列 → C16 (d43〜d46) → 46 列 (Q 側の網の節) → R4 (a46〜a48) で 48 列 (VREF) へ
- **VREF (白)**: U4 の PIN 7 (53 列の上) が VREF。d48〜d53 の白い線で 48 列の上へ、e48〜f48 で下の段へ、j48〜j54 で U4 の PIN 3 (加算の +) へ。
  分圧は R5 (c55〜c58、58 列は赤い線で +5 V) と R6 (55 列から GND レール) で、55 列が U4 の PIN 5
- **加算 (紫)**: R7 (g45〜g50) で I 側の節から 50 列へ。50 列は h50〜h53 で U4 の PIN 2 (加算の −)、e50〜f50 で上の段へ。
  Q 側は R8 (c46〜c49) → VR1 の 1 番ピン (49 列)。VR1 の真ん中のピン (50 列) が加算の − で、3 番ピン (51 列) は使わない。
  R9 (g53〜g57) が帰還で、出力 (U4 の PIN 1、52 列) は i52〜i57 の茶の線で 57 列へ
- **AD3**: 上の箱が Supplies と Wavegen、下の箱が Scope。1+ は 42 列 (I)、2+ は 57 列 (出力)、1− は i48、2− は h54 (どちらも VREF)
- 周波数は高いもので 547.8 kHz の RF と、SA612 の中の和の約 1 MHz。ブレッドボードで扱える 3 MHz 以下に収まる。
  電流は SA612 が 2 個で約 5 mA、MCP6002 が 2 個で 1 mA 以下、分圧が 0.25 mA。AD3 の V+ で足りる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1・U2 | ダブルバランスドミキサー IC | SA612A (NE612A)、DIP8 |
| U3・U4 | オペアンプ (2 回路、レール to レール) | MCP6002、DIP8 |
| R1・R2 | 抵抗 (LO の 90° 網) | 680 Ω |
| C1・C2 | セラミックコンデンサ (LO の 90° 網、C0G) | 470 pF (471) |
| C3・C4・C5・C6 | セラミックコンデンサ (LO と RF の結合) | 10 nF (103) |
| C7・C8 | セラミックコンデンサ (PIN 2 を交流で GND へ) | 10 nF (103) |
| C11・C12 | セラミックコンデンサ (PIN 4 の高域を落とす) | 470 pF (471) |
| C13・C15 | セラミックコンデンサ (直流を切る) | 1 µF (105) |
| R3・R4 | 抵抗 (IF の 90° 網) | 6.8 kΩ |
| C14・C16 | セラミックコンデンサ (IF の 90° 網、C0G) | 470 pF (471) |
| R5・R6 | 抵抗 (VREF の分圧) | 10 kΩ |
| R7・R9 | 抵抗 (加算) | 100 kΩ |
| R8 | 抵抗 (加算の Q 側) | 91 kΩ |
| VR1 | 半固定抵抗 (Q 側の利得合わせ) | 20 kΩ |
| C9・C10・C18・C19 | セラミックコンデンサ (電源のパスコン) | 100 nF (104) |
| — | 信号源・計器・電源 | Analog Discovery 3 (W1・W2、Scope、Spectrum、V+ 5 V) |

- 90° 網の R と C は、そろうほど深く消える。抵抗は ±1 % の金属皮膜、コンデンサは温度で値が動きにくい C0G (NP0) がよい
- 網の抵抗とコンデンサは、同じ袋の中から値の近いものを選ぶ (テスターや AD3 の Impedance で測る) と、±5 % の部品でも消え方が深くなる

## 計器の設定

Analog Discovery 3 だけを使う。LO と RF は 1 MHz より低いので W1・W2 で作れ、IF の 49.8 kHz は Scope と Spectrum で見られる。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない) |
| Wavegen W1 (LO) | Sine、498 kHz、振幅 0.25 V (0.5 V<sub>pp</sub>)、オフセット 0 V |
| Wavegen W2 (RF) | Sine、448.2 kHz (LO の下) と 547.8 kHz (LO の上) を切り替える。振幅 10 mV (9-12 と同じ)、オフセット 0 V |
| Scope | CH1 = I (C13 の先)、CH2 = 出力。1− と 2− は VREF。どちらも 20 mV/div、5 µs/div (49.8 kHz の 2.5 周期)、トリガは CH1 の立ち上がり 0 V |
| Spectrum | CH2。開始 0 Hz・終了 1.25 MHz、FFT 16384 点、窓は Flat Top、縦軸 dBV、Top −10 dBV、10 dB/div |

- Spectrum の分解能は 1.25 MHz × 2.56 ÷ 16384 = 195 Hz。49.8 kHz と、和の 946.2 kHz・1045.8 kHz、LO の漏れの 498 kHz が全部入る
- **VR1 の合わせ方**: W2 を 547.8 kHz (消したい側) にして、Spectrum のマーカー 1 (49.8 kHz) が一番低くなるように VR1 を回す。
  それから W2 を 448.2 kHz に戻し、49.8 kHz が立つのを確かめる
- W1 と W2 の周波数は 0.1 kHz の桁まで合わせる。49.8 kHz からずれると IF の網の振幅がそろわず、消え方が浅くなる
  (網の位相差は 90° のままだが、振幅は 1 kHz ずれると約 2 % 違う)

## 計器の画面

数は計算値 (目安)。PIN 4 の IF は、9-12 の変換利得 17 dB (7.08 倍、片側の出力・1 側波あたり、データシートの代表値) と、
LO の網で LO が 0.707 倍になる分から、10 mV × 7.08 × 0.707 = **50.1 mV** (peak) と見込む (9-19 と同じ見積もり)。
PIN 4 の 470 pF で 0.98 倍になり、**I (CH1) は 48.9 mV** (peak)。下 (448.2 kHz) のときの出力は、I 側と Q 側がそれぞれ 0.683 倍
(網の 0.707 倍が加算の 100 kΩ の負荷でわずかに下がる) で同じ向きに足し合わさり、**48.9 mV × 1.37 = 66.9 mV** (peak)。
上 (547.8 kHz) のときは ±5 % の部品で 30 dB 下がったとして **2.1 mV** で描いた。

```scope
title: 図3 W2 = 448.2 kHz (LO の下) — 出力 (CH2) に 49.8 kHz が残る
time: 5us/div
trigger: ch1 rising 0V
ch1: {wave: sine 49.8kHz 48.9mV, range: 20mV/div}
ch2: {wave: sine 49.8kHz 66.9mV phase 136.9deg, range: 20mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/20-image-reject-hartley-1.svg)

```scope
title: 図4 W2 = 547.8 kHz (LO の上) — 出力 (CH2) はほぼ平ら
time: 5us/div
trigger: ch1 rising 0V
ch1: {wave: sine 49.8kHz 48.9mV, range: 20mV/div}
ch2: {wave: sine 49.8kHz 2.1mV, range: 20mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/20-image-reject-hartley-2.svg)

- 図3 と図4 は同じ尺度 (どちらも 20 mV/div・5 µs/div)。CH1 の I は W2 を切り替えても同じ 97.8 mV<sub>pp</sub> で、出力 (CH2) だけが 134 mV<sub>pp</sub> から 4.2 mV<sub>pp</sub> に下がる
- 図3 の出力は I より 136.9° 進んで見える。I 側の網の −43.1° と、反転加算の 180° を足した値 (計算値)
- 図4 の消え残りの位相は、部品のずれ方で決まるので、図では 0° で描いた。大きさも部品しだいで、VR1 を合わせると小さくなる
- 時間の波形だけでは、どちらの周波数から来た 49.8 kHz かは分からない。分かるのは、W2 を切り替えると出力の大きさが変わることだ

```spectrum
title: 図5 W2 = 448.2 kHz — 49.8 kHz の線が立つ
device: ad3
sweep: 0-1.25MHz
samples: 16384
window: flattop
unit: dBV
ref: -10dBV
signal:
  - sine 49.8kHz 66.9mV
  - sine 498kHz 2mV
  - sine 946.2kHz 3.8mV
markers: [49.8k, 498k, 946.2k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/20-image-reject-hartley-1.svg)

```spectrum
title: 図6 W2 = 547.8 kHz — 49.8 kHz の線は約 30 dB 下がる
device: ad3
sweep: 0-1.25MHz
samples: 16384
window: flattop
unit: dBV
ref: -10dBV
signal:
  - sine 49.8kHz 2.1mV
  - sine 498kHz 2mV
  - sine 1045.8kHz 3.8mV
markers: [49.8k, 498k, 1045.8k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/20-image-reject-hartley-2.svg)

- 図5 と図6 は同じ尺度 (Top −10 dBV、10 dB/div) で並べた。図6 は一番高い線が上端から 4 目盛下になる (フェンスがそう言う) が、
  図5 と高さを見比べるために、あえて同じ尺度にした
- マーカー 1 (49.8 kHz) が **−26.5 dBV から −56.6 dBV へ、約 30 dB** 下がる。これがイメージ除去の比 (±5 % の部品の目安。理想の部品なら 59 dB)
- マーカー 2 (498 kHz) は LO の漏れ、マーカー 3 は和 (448.2 + 498 = 946.2 kHz、547.8 + 498 = 1045.8 kHz)。
  片側 (PIN 4) の出力なので LO の漏れは打ち消されずに残る (9-12 の CH2 と同じ)。PIN 4 の 470 pF と U4B の帯域 (約 1 MHz の GBW を 3 倍の雑音利得で割って約 330 kHz) で下がった分を見込んだ**目安**で、
  大きさは実物で確かめる。どちらも W2 を切り替えても大きさはほぼ変わらない
- 9-10 のスーパーヘテロダインなら、ここで 49.8 kHz の IF フィルタを置けば、マーカー 2・3 は落ちる。消えないのはマーカー 1 のイメージだけで、それを位相で消すのがこの題

## 見るべき値

計算値。IF の大きさは 9-12 の変換利得からの**目安**、抑圧の dB は LTspice の模型と、網の部品をばらつかせた計算による。

| 確かめること | 期待する値 |
| --- | --- |
| I (CH1) の大きさ | 97.8 mV<sub>pp</sub> (48.9 mV peak、目安)。W2 を 448.2 kHz と 547.8 kHz で切り替えても同じ |
| W2 = 448.2 kHz (LO の下) の出力 (CH2) | 49.8 kHz・134 mV<sub>pp</sub> (66.9 mV peak、−26.5 dBV、目安)。I の 1.37 倍 |
| W2 = 547.8 kHz (LO の上) の出力 (CH2) | 49.8 kHz・約 4 mV<sub>pp</sub> (−56.6 dBV)。448.2 kHz のときより **25〜35 dB** 低い (±5 % の部品の目安) |
| VR1 で Q 側の振幅を合わせた後 | 中央値で約 37 dB 低い (±5 % の網。位相のずれが残る)。±1 % の部品なら 46 dB 前後 |
| 理想の部品 (LTspice) | 59 dB 低い |
| 2 つの SA612 の利得が 5 % 違うだけのとき | 32 dB にとどまる |
| 網の位相が 3° ずれるだけのとき | 32 dB にとどまる |
| U3 の 2 本の出力 (I と Q) を入れ替える | 残る側が入れ替わる。547.8 kHz で 49.8 kHz が立ち、448.2 kHz で消える |
| W1 を止める | 49.8 kHz が消える (掛ける相手が無い) |
| 出力の直流 | VREF と同じ 2.5 V (CH2 は VREF との差なので 0 V) |

## 出典

自作。位相法のイメージ除去 (I と Q を 90° ずらして足す) は R. V. L. Hartley の米国特許 US 1,666,206 (1928 年) の考え方による。
SA612A のピンの並び、変換利得 (代表 17 dB)、外部 LO の 200 mV<sub>pp</sub> 以上、出力の 1.5 kΩ は NXP の SA612A データシート、
MCP6002 のピンの並びとレール to レールの入出力、GBW 1 MHz は Microchip の MCP6001/2/4 データシートによる。
抑圧の dB は網の R・C をばらつかせた計算と、掛け算を式で置いた LTspice の模型による計算値。
