---
book: etc
chapter: 2
id: 2-11
title: 時計をユニバーサル基板に組む — 窓判定と同期・設定の 3 枚
tier: 300
scale: large
source: 自作
board: PF
---

# 2-11 時計をユニバーサル基板に組む — 窓判定と同期・設定の 3 枚

> [!WARNING]
> **この題は、まだ実際の回路で検証していない。** 実体配線図は設計から作ったもので、組んで測ったものではない。組むときは、基板ごとに確かめながら進めてほしい。

[2-7](07-clock.md) の時計をブレッドボードで動かしたあと、半田付けで残すための題。2-7 の窓判定 (ユニット 6、ブレッドボード 2 枚) と
同期と設定 (ユニット 7、1 枚) を、同じ回路のユニバーサル基板 3 枚 (図1〜図3) にする。

この題は回路図・Analog Discovery 3・オシロの図を付けない — 回路と測り方は 2-7 のままで、この題は同じ回路を基板に移すだけだから (回路図は 2-7 の図4・図5、正時のリセットの見え方は 2-7 の図11)。
発展 (大規模) なのは 2-7 と同じ理由で、IC は 3 枚で 9 個になる。

## 基板の分け方

基板は永続的な工作なので、組み上げるなら全体を次のように分けて何枚かの基板にする。
窓判定の 2 枚と同期と設定はこの分け方のまま 1 枚ずつ基板になり、発振と分周は 2-5 の図2b の基板になる。
カウンタ (U21〜U26)・ゲート (U33〜U35・U42)・表示 (U27〜U32) は図に描かない (配線は 2-7 の配線表)。基板に載せるなら、秒・分・時のカウンタとゲートを 1 ユニットずつ 1 枚、表示を 6 桁で 1 枚にし、基板どうしは信号の名前でつなぐ。
+1 ボタン (2-7 の図10) は部品が少ないので、図10 の並びのまま 5×7 cm に移せる (図は描いていない)。

ユニバーサル基板は在庫の順 (5×7 → 7×9 → 9×15 cm) に、配置が収まる最初のものを選んだ。厚みと基材は書いていないので 1.6 mm の FR-4 である。
半田面から見た図ではなく、部品面から見た配置と配線の図で、線は半田面に通す。
使わない出力のピンがつながっていないという検査の知らせは、組み立てとして正しいので止めてある (`style: check: off`)。

## 実体配線図

### 窓判定 1/2

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図1 窓判定のユニバーサル基板 1/2 (ユニット 6)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  MT_0: x16
  MT_1: y16
  ST_0: aa16
  ST_1: ab16
  XA: ac16
  ENHT: o16
  O_8: p16
  CMB: r16
  SETN: d16
  SYD_1: e16
  SYD: f16
  H_23: w13
  ENH: x13
  WH: y13
  MT_5: z13
  MU_9: aa13
  NSY: m13
  O_2: n13
  MT_2: p13
  X: d13
  W_59: e13
  ACC: h13
  VCC: a21
  GND: a8
parts:
  U37: dip14 c16 74HC08
  U40: dip14 m16 74HC32
  U36: dip14 w16 74HC08
wires:
  - i13 -- i8 black
  - s13 -- s8 black
  - ac13 -- ac8 black
  - GND -- i8 black
  - i8 -- s8 black
  - s8 -- ac8 black
  - ac8 -- ad8 black
  - VCC -- c21 red
  - c21 -- c16 red
  - c21 -- m21 red
  - m21 -- w21 red
  - m21 -- m16 red
  - w21 -- w16 red
  - w21 -- ad21 red
  - s16 -- u16 blue
  - u16 -- u12 blue
  - ENH -- x12 blue
  - u12 -- x12 blue
  - l17 -- l10 orange
  - l17 -- n17 orange
  - n17 -- n16 orange
  - WH -- y10 orange
  - l10 -- y10 orange
  - c13 -- c9 green
  - ab13 -- ab9 green
  - c9 -- ab9 green
  - v17 -- z17 purple
  - v17 -- v11 purple
  - z17 -- z16 purple
  - q13 -- q11 purple
  - q11 -- v11 purple
  - g13 -- g12 yellow
  - o13 -- o12 yellow
  - g12 -- o12 yellow
  - h16 -- ACC pink
  - g19 -- t19 brown
  - g19 -- g16 brown
  - t19 -- t12 brown
  - r13 -- r12 brown
  - r12 -- t12 brown
  - i18 -- q18 white
  - i18 -- i16 white
  - q18 -- q16 white
style:
  check: off
notes:
  - mark x16 yellow
  - mark y16 yellow
  - mark aa16 yellow
  - mark ab16 yellow
  - mark ac16 yellow
  - mark o16 yellow
  - mark p16 yellow
  - mark r16 yellow
  - mark d16 yellow
  - mark e16 yellow
  - mark f16 yellow
  - mark w13 yellow
  - mark x13 yellow
  - mark y13 yellow
  - mark z13 yellow
  - mark aa13 yellow
  - mark m13 yellow
  - mark n13 yellow
  - mark p13 yellow
  - mark d13 yellow
  - mark e13 yellow
  - mark h13 yellow
  - parts
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/11-clock-perfboard-1.svg)

図1 は、[2-7](07-clock.md) の図7 (ブレッドボード) と同じ回路をユニバーサル基板に組む図だ。U36・U40・U37 の 3 個を、9×7 cm (31 列 × 26 行) のユニバーサル基板に 1 列に並べた。5×7 cm (24 × 18) には 3 個の IC が横に入らない。7×9 cm の横置きで、上下の電源筋と信号の道が通った。

- 電源 (赤) は上の筋 (21 行)、GND (黒) は下の筋 (8 行) に通し、各 IC の 14 番 (VCC) から上へ、7 番 (GND) から下へ、IC の真横の 1 列で枝を出した。
- IC は左から U37・U40・U36 の順に置いた。U37 の 2Y (6 番) と 3A (9 番) は、半田面で胴の下を通る短い線で結ぶ (同じ IC のピンどうし)。外側で結ぶと、間の 3Y (8 番) の線が必ず跨ぐため。
- 信号どうしの交差が少し残る。この 3 個のピンの並びでは、IC をどう並べ替えても、信号どうしが交わらずには引けない (並べ方を何通りも試して、いちばん少ないものにした)。+ と GND の交差は無い。交差は、半円で跨いだ側を被覆線にする。
- 黄色の丸は、ユニバーサル基板の外へ出る信号のピンだ。そのピンへ直接半田付けして線を出す。信号の名前は次の表のとおり (図の中には名前を書いていない)。ブレッドボードの図の上と下の箱 (他の基板へ) と同じ信号である。
- 使わない出力のピンは、どこにもつながない。

| 信号 | 印を付けたピン |
| --- | --- |
| MT0 | U36 の 13 番 4B |
| MT1 | U36 の 12 番 4A |
| ST0 | U36 の 10 番 3B |
| ST1 | U36 の 9 番 3A |
| XA | U36 の 8 番 3Y |
| ENHT | U40 の 12 番 4A |
| O8 | U40 の 11 番 4Y |
| CMB | U40 の 9 番 3A |
| SETN | U37 の 13 番 4B |
| SYD1 | U37 の 12 番 4A |
| SYD | U37 の 11 番 4Y |
| H23 | U36 の 1 番 1A |
| ENH | U36 の 2 番 1B |
| WH | U36 の 3 番 1Y |
| MT5 | U36 の 4 番 2A |
| MU9 | U36 の 5 番 2B |
| NSY | U40 の 1 番 1A |
| O2 | U40 の 2 番 1B |
| MT2 | U40 の 4 番 2A |
| X | U37 の 2 番 1B |
| W59 | U37 の 3 番 1Y |
| ACC | U37 の 6 番 2Y |

### 窓判定 2/2

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図2 窓判定のユニバーサル基板 2/2 (ユニット 6)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  MU_1: g16
  MU_2: h16
  W_59: o16
  O_2: p16
  XA: q16
  ST_2: r16
  X: s16
  MT_2: c13
  MT_1: d13
  MT_0: f13
  MU_3: g13
  MU_0: n13
  LDHU: w13
  SET: x13
  O_8: y13
  LDHT: z13
  WH: ab13
  VCC: a21
  GND: a8
parts:
  U38: dip14 c16 74HC32
  U39: dip14 m16 74HC32
  U43: dip14 w16 74HC02
wires:
  - ab16 -- ac16 black
  - ac16 -- ad16 black
  - ad16 -- ad13 black
  - i13 -- i8 black
  - s13 -- s8 black
  - ac13 -- ad13 black
  - ac13 -- ac8 black
  - GND -- i8 black
  - i8 -- s8 black
  - s8 -- ac8 black
  - ac8 -- ad8 black
  - VCC -- c21 red
  - c21 -- c16 red
  - c21 -- m21 red
  - m21 -- w21 red
  - m21 -- m16 red
  - w21 -- w16 red
  - w21 -- ad21 red
  - b17 -- b12 blue
  - b17 -- e17 blue
  - e17 -- e16 blue
  - e13 -- e12 blue
  - b12 -- e12 blue
  - d16 -- d14 orange
  - d14 -- h14 orange
  - h14 -- h13 orange
  - i16 -- k16 green
  - k16 -- k13 green
  - k13 -- m13 green
  - a18 -- a11 purple
  - a18 -- f18 purple
  - f18 -- f16 purple
  - p13 -- p11 purple
  - a11 -- p11 purple
  - o14 -- o13 yellow
  - o14 -- q14 yellow
  - q14 -- q13 yellow
  - z17 -- z16 pink
  - z17 -- ae17 pink
  - ae17 -- ae11 pink
  - r13 -- r11 pink
  - r11 -- ae11 pink
  - s17 -- X brown
  - s17 -- y17 brown
  - y17 -- y16 brown
  - n18 -- n16 white
  - n18 -- x18 white
  - x18 -- x16 white
  - SET -- x12 gray
  - aa13 -- aa12 gray
  - x12 -- aa12 gray
style:
  check: off
notes:
  - mark g16 yellow
  - mark h16 yellow
  - mark o16 yellow
  - mark p16 yellow
  - mark q16 yellow
  - mark r16 yellow
  - mark s16 yellow
  - mark c13 yellow
  - mark d13 yellow
  - mark f13 yellow
  - mark g13 yellow
  - mark n13 yellow
  - mark w13 yellow
  - mark x13 yellow
  - mark y13 yellow
  - mark z13 yellow
  - mark ab13 yellow
  - parts
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/11-clock-perfboard-2.svg)

図2 は、[2-7](07-clock.md) の図8 (ブレッドボード) と同じ回路をユニバーサル基板に組む図だ。U38・U39・U43 の 3 個を、9×7 cm (31 列 × 26 行) のユニバーサル基板に 1 列に並べた。5×7 cm (24 × 18) には 3 個の IC が横に入らない。7×9 cm の横置きで、上下の電源筋と信号の道が通った。

- 電源 (赤) は上の筋 (21 行)、GND (黒) は下の筋 (8 行) に通し、各 IC の 14 番 (VCC) から上へ、7 番 (GND) から下へ、IC の真横の 1 列で枝を出した。
- IC は左から U38・U39・U43 の順に置いた。U38 の 2Y (6 番) と 4B (13 番)、U39 の 1Y (3 番) と 2B (5 番) は、半田面で胴の下を通る短い線で結ぶ (同じ IC のピンどうし)。外側で結ぶと、間のピンの線が必ず跨ぐため。
- U39 と U43 を結ぶ 3 本の線 (2Y と 4A、3Y と 4B、4B と 4Y) は、ピンの並びの順が合わず、交わらずには引けない。信号どうしの交差はそこだけで、ほかに残るのは信号が電源の枝を跨ぐところだ。+ と GND の交差は無い。交差は、半円で跨いだ側を被覆線にする。
- 黄色の丸は、ユニバーサル基板の外へ出る信号のピンだ。そのピンへ直接半田付けして線を出す。信号の名前は次の表のとおり (図の中には名前を書いていない)。ブレッドボードの図の上と下の箱 (他の基板へ) と同じ信号である。
- 使わない出力のピンは、どこにもつながない。

| 信号 | 印を付けたピン |
| --- | --- |
| MU1 | U38 の 10 番 3B |
| MU2 | U38 の 9 番 3A |
| W59 | U39 の 12 番 4A |
| O2 | U39 の 11 番 4Y |
| XA | U39 の 10 番 3B |
| ST2 | U39 の 9 番 3A |
| X | U39 の 8 番 3Y |
| MT2 | U38 の 1 番 1A |
| MT1 | U38 の 2 番 1B |
| MT0 | U38 の 4 番 2A |
| MU3 | U38 の 5 番 2B |
| MU0 | U39 の 2 番 1B |
| LDHU | U43 の 1 |
| SET | U43 の 2 |
| O8 | U43 の 3 |
| LDHT | U43 の 4 |
| WH | U43 の 6 |

### 同期と設定

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図3 同期済みと設定のユニバーサル基板 (ユニット 7)
board:
  size: 15x9cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  NSY: z21
  SET: x18
  SETN: y18
  ACC: ao18
  SYD_1: ap18
  RS: as18
  SYD: ae18
  CLK: af18
  VCC: a25
  GND: a11
parts:
  R15: resistor c17 c21 100k
  C15: capacitor/electrolytic e17 e14 10u v=16V
  R14: resistor i17 i21 10k
  S14: switch k17 k14
  C14: capacitor/ceramic m17 m15 1u
  U45: dip14 t21 CD40106B
  U44: dip14 ad21 74HC74
  U41: dip14 an21 74HC32
wires:
  - ap23 -- aw23 black
  - ap23 -- ap21 black
  - aw23 -- aw11 black
  - u22 -- u21 black
  - u22 -- w22 black
  - w22 -- w21 black
  - w22 -- aa22 black
  - aa22 -- aa18 black
  - af21 -- ag21 black
  - ag21 -- ag20 black
  - ao21 -- ap21 black
  - ag20 -- aj20 black
  - aj20 -- aj18 black
  - z18 -- z11 black
  - z18 -- aa18 black
  - aj18 -- aj11 black
  - at18 -- at11 black
  - m15 -- m14 black
  - e14 -- e11 black
  - k14 -- k11 black
  - k14 -- m14 black
  - GND -- e11 black
  - e11 -- k11 black
  - k11 -- z11 black
  - z11 -- aj11 black
  - aj11 -- at11 black
  - at11 -- aw11 black
  - aw11 -- bb11 black
  - VCC -- c25 red
  - c25 -- c21 red
  - c25 -- i25 red
  - i25 -- i21 red
  - i25 -- t25 red
  - t25 -- t21 red
  - t25 -- ae25 red
  - ae25 -- bb25 red
  - ae25 -- ae22 red
  - ae22 -- ae21 red
  - ae22 -- ah22 red
  - ah22 -- an22 red
  - ah22 -- ah21 red
  - an22 -- an21 red
  - ad21 -- ad18 red
  - ad21 -- ae21 red
  - ae21 -- ae19 red
  - ae19 -- ag19 red
  - ag19 -- ag18 red
  - t18 -- t17 blue
  - i17 -- k17 blue
  - k17 -- m17 blue
  - m17 -- t17 blue
  - v18 -- v12 orange
  - c17 -- e17 orange
  - e17 -- g17 orange
  - g17 -- g12 orange
  - g12 -- v12 orange
  - y23 -- y21 green
  - y23 -- ab23 green
  - ab23 -- ab17 green
  - ah18 -- ah17 green
  - an18 -- an17 green
  - ab17 -- ah17 green
  - ah17 -- an17 green
  - ACC -- ao17 purple
  - aq18 -- aq17 purple
  - ao17 -- aq17 purple
  - at21 -- au21 yellow
  - au21 -- au17 yellow
  - SET -- x16 yellow
  - ar18 -- ar17 yellow
  - ar17 -- ar16 yellow
  - ar17 -- au17 yellow
  - x16 -- ar16 yellow
  - h24 -- as24 pink
  - h24 -- h13 pink
  - as24 -- as21 pink
  - u18 -- u13 pink
  - h13 -- u13 pink
  - ar22 -- av22 brown
  - ar22 -- ar21 brown
  - av22 -- av15 brown
  - w18 -- w15 brown
  - w15 -- av15 brown
style:
  check: off
notes:
  - mark z21 yellow
  - mark x18 yellow
  - mark y18 yellow
  - mark ao18 yellow
  - mark ap18 yellow
  - mark as18 yellow
  - mark ae18 yellow
  - mark af18 yellow
  - parts
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/11-clock-perfboard-3.svg)

図3 は、[2-7](07-clock.md) の図9 (ブレッドボード) と同じ回路をユニバーサル基板に組む図だ。設定ボタンとパワーオンの RC (R14・S14・C14・R15・C15) を左に、U45・U44・U41 を右に、15×9 cm (54 列 × 33 行) のユニバーサル基板に並べた。5×7 cm と 7×9 cm は、部品と IC 3 個で 40 穴ほど要るので収まらない。

- 電源 (赤) は上の縁の筋 (25 行)、GND (黒) は下の縁の筋 (11 行) に通した。各 IC の 14 番 (VCC) から上へ、7 番 (GND) から下へ、IC の真横の 1 列で枝を出す。R14・R15 は上の筋から、S14・C14・C15 は下の筋へ、縦に挿した。
- U44 (74HC74) は、+5 V につなぐピン (1・4・10・13・14 番) と GND につなぐピン (7・11・12 番) が交互に並ぶ。外側で結ぶと + と GND の線が交わるので、1CLR (1 番) と VCC (14 番)、1PRE (4 番) と 2CLR (13 番)、2CLK (11 番) と GND (7 番) は、半田面で胴の下を通る短い線で結んだ (同じ IC のピンどうし)。2D (12 番) と 2CLK は隣のピンどうしを短い線で結ぶ。
- 信号どうしの交差が少し残る (並べ方を何通りも試して、いちばん少ないものにした)。+ と GND の交差は無い。交差は、半円で跨いだ側を被覆線にする。
- 黄色の丸は、ユニバーサル基板の外へ出る信号のピンだ。そのピンへ直接半田付けして線を出す。信号の名前は次の表のとおり (図の中には名前を書いていない)。ブレッドボードの図の上と下の箱 (他の基板へ) と同じ信号である。
- 使わない出力のピンは、どこにもつながない。

| 信号 | 印を付けたピン |
| --- | --- |
| NSY | U45 の 8 番 J |
| SET | U45 の 5 番 C |
| SETN | U45 の 6 番 I |
| ACC | U41 の 2 番 1B |
| SYD1 | U41 の 3 番 1Y |
| RS | U41 の 6 番 2Y |
| SYD | U44 の 2 |
| CLK | U44 の 3 |

- 設定ボタンとパワーオンの RC を左に、IC を右に置いた。PON と BTN はユニバーサル基板の中で U41 に入る。
- 外へ出る信号は、SET (設定中)、SETN、RS、SYD1 (図1 の U37D へ)、NSY (未同期の LED へ)。入るのは ACC、SYD、CLK。

## 見るべき値

3 枚とも、ネットが 2-7 のブレッドボードの図 (図7〜図9) と同じであることを `check` のネットリストで突き合わせた (実機では組んでいない)。
組んだら、2-7 の「見るべき値」(図11 の正時のリセット) を同じ手順で当てる。半田付けの前に、テスターで + と GND の間が短絡していないかを見る。

## 出典

自作。回路と部品の出典は [2-7](07-clock.md) の出典のとおり。
参考: [TI の SN74HC74 データシート (SCLS094F)](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf)、[TI の CD40106B データシート](https://www.ti.com/lit/ds/symlink/cd40106b.pdf)。
