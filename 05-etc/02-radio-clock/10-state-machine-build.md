---
book: etc
chapter: 2
id: 2-10
title: 時報の状態遷移を基板に組む — 4 ユニットの実体配線図と AD3 での試験
tier: 300
source: 自作
board: [BB, PF]
---

# 2-10 時報の状態遷移を基板に組む — 4 ユニットの実体配線図と AD3 での試験

> [!WARNING]
> **この題の実体配線図 (ブレッドボードとユニバーサル基板) は、まだ実際の回路で検証していない。** 配線は回路図のつながりを写し、check のネットリストで突き合わせたもので、組んで確かめてはいない。数値 (タイミング) も計算とシミュレーションで作ったもので、正しく動くかどうかは確実ではない。

[04-state-machine.md](04-state-machine.md) (2-4) で設計した状態遷移の回路を、4 つのユニットに分けて基板に組み、
Analog Discovery 3 で状態遷移だけを試験する。回路図 (2-4 の図4〜7)・部品・タイミングの計算 (2-4 の図1〜3) は 2-4 にあり、
ここには載せない。この題に回路図は置かない — 2-4 の回路図の再掲になるため。

## 実体配線図

4 つのユニットを、フルサイズ (63 列) のブレッドボード 4 枚に 1 つずつ組む。**配線は、回路図 (2-4 の図4〜7) のピンのつながりをそのまま基板に写したもの**で、check のネットリストを回路図と突き合わせて確かめた。
基板の間は、同じ名前の端子どうしを線でつなぐ。電源 (5 V) と GND は 4 枚で共通にする。

- 線の色は、赤が + だけ、黒が GND だけ、黄が CLK、橙が基板の外とやりとりする信号、緑が基板の中の信号。
- 各 IC のそばに 0.1 µF を 1 個ずつ、上の + レールと − レールのあいだに入れる。
- 使わないゲートの入力は、GND に落とす。74HC74 の使わない PRE と CLR (PIN 1、4、10、13) は +5 V に上げる。どちらも、レールからの線で描いてある。
- フルサイズの基板は、レールが中央で切れていることがある。図の中央にあるレールの渡しの線 (赤と黒) は、そのためだ。
- 74HC74、74HC86、74HC02 は、図の道具がピンの名前の表を持たないので、ピンは番号だけで出る。ピンの名前は、各ユニットの回路図 (2-4 の図4〜7) の PIN の番号と合わせて読む。
- 配線は多い。読めない所は、check のネットリスト (`breadboard-fence check`) で、ピンごとのつながりを確かめる。

基板の外とやりとりする端子は、次のとおり。上下の箱は、線の出る側を表す。

| ユニット | 基板 | 入力 | 出力 |
| --- | --- | --- | --- |
| 1 | 図 1、1b | T440、T880、CLK | E440、NE440、E880 |
| 2 | 図 2、2b | NE440、CLK | W、TO |
| 3 | 図 3、3b | W、QA、QB、NE440、E440、E880、TO、S3、PON | LOADN、EN、CLRN |
| 4 | 図 4、4b | LOADN、CLRN、EN、CLK、E880、W | QA、QB、S3、OUT |

同じ 4 つのユニットを、ユニバーサル基板にも組めるようにした。ブレッドボードの図 (図 1〜4) のすぐあとに、同じ回路の図 1b〜4b を置いた。

### ユニバーサル基板の図 (図 1b〜4b) の見方

- 図は部品面から見たもの。配線は半田面で行う。厚みと基材は書いていないので 1.6 mm の FR-4
- 基板は在庫の順 (5×7 → 7×9 → 9×15 cm) に、配置と配線が収まる最初の基板を選んだ。ユニット 4 は 5×7 cm (横置きの `7x5cm`)、ユニット 2 は 7×9 cm、ユニット 1 と 3 は 9×15 cm (横置きの `15x9cm`)。ユニット 2 は 5×7 cm に IC が載るが、電源とほかの線を通すと詰まって配線が収まらなかった。ユニット 1 と 3 は IC が 4 個で、7×9 cm でも線が絡み合って追えなくなったので、9×15 cm にした。無理に詰めず基板を大きくした
- 線の色は、赤が + だけ、黒が GND だけ、黄が CLK。ほかの信号線は、たどりやすいように色を変えただけで、色に意味はない
- 線どうしが交わる所は、図の半円のところで被覆線を渡す。裸の線を重ねない。交わる所は多いので、半田付けの前に、1 本ずつ check のネットリストと照らして進める
- 各 IC のそばに 0.1 µF を 1 個ずつ、電源 (+) と GND の線のあいだに入れる。使わないゲートの入力は GND、74HC74 の使わない PRE と CLR は +5 V につなぐ (ブレッドボードと同じ)
- 基板の外の電源 5 V と、ほかのユニットとやりとりする信号は、箱のピンから基板の穴まで線を引いた。ここに半田付けのリード線をつなぐ
- 使わない出力 (74HC74 の /Q、74HC163 の QC・QD・RCO、74HC04 と 74HC08 の使わないゲートの出力) と、同じ IC の中だけで閉じる接続 (74HC08 の 2Y と 3B) は、ERC が「つながっていない」と言う。承知のうえなので、`points:` で `NC_` から始まる名前を付けた (この名前は図には出ない)
- 範囲の確認: 電圧は 5 V、クロックは 8 Hz、音の信号は 440 Hz と 880 Hz で、ユニバーサル基板の範囲 (12 V 以下、10 MHz 以下) に収まる
- ブレッドボードでなくユニバーサル基板にも組む理由は、時計として長く通電する作品なので、接触の揺れのない半田付けにも組めるようにするため

### 図 1・1b: ユニット 1 (同期とエッジ検出)

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図1 同期とエッジ検出のブレッドボード (ユニット 1)
board: full
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: top
    label: 他のユニットへ (上)
    pins: [CLK, E880, E440, NE440]
  LINKR:
    type: device
    at: top
    label: 他のユニットへ (上・右)
    pins: [CLK, T440]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [T880, CLK]
  U6: dip14 @ e5 l=74HC74
  U8: dip14 @ e18 r180 74HC08
  U7: dip14 @ e35 r180 74HC04
  U5: dip14 @ e46 r180 l=74HC74
  C1: capacitor/ceramic +t13 -t13 100n
  C2: capacitor/ceramic +t26 -t26 100n
  C3: capacitor/ceramic +t39 -t39 100n
  C4: capacitor/ceramic +t55 -t55 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t31 -- +t33 red
  - -t31 -- -t34 black
  - +b31 -- +b33 red
  - -b31 -- -b33 black
  - +t60 -- +b60 red
  - -t60 -- -b60 black
  - +t5 -- a5 red
  - +t6 -- a6 red
  - +t9 -- a9 red
  - +b5 -- j5 red
  - +b8 -- j8 red
  - -b11 -- j11 black
  - -t18 -- a18 black
  - -b19 -- j19 black
  - -b20 -- j20 black
  - -b22 -- j22 black
  - -b23 -- j23 black
  - +b24 -- j24 red
  - -t35 -- a35 black
  - -b36 -- j36 black
  - -b38 -- j38 black
  - -b40 -- j40 black
  - +b41 -- j41 red
  - -t46 -- a46 black
  - +t49 -- a49 red
  - +t52 -- a52 red
  - +b48 -- j48 red
  - +b51 -- j51 red
  - +b52 -- j52 red
  - LINKT.CLK -- a8 yellow
  - LINKT.E880 -- a19 orange
  - LINKT.E440 -- a29 orange
  - LINKT.NE440 -- a36 orange
  - LINKR.CLK -- a50 yellow
  - LINKR.T440 -- a51 orange
  - LINKB.T880 -- j6 orange
  - LINKB.CLK -- j7 yellow
  - LINKB.CLK -- j49 yellow [h10, v-27]
  - h9 -- h3 green
  - e3 -- f3 green
  - c3 -- c7 green
  - b7 -- b21 green
  - c10 -- c14 blue
  - e14 -- f14 blue
  - i14 -- i26 blue
  - g26 -- g33 blue
  - e33 -- f33 blue
  - b33 -- b39 blue
  - c38 -- c32 purple
  - e32 -- f32 purple
  - j32 -- j25 purple
  - h25 -- h16 purple
  - e16 -- f16 purple
  - c16 -- c20 purple
  - c22 -- c29 orange
  - d29 -- d37 orange
  - b40 -- b43 brown
  - e43 -- f43 brown
  - h43 -- h28 brown
  - e28 -- f28 brown
  - b28 -- b23 brown
  - j47 -- j44 gray
  - e44 -- f44 gray
  - c44 -- c41 gray
  - b48 -- b54 pink
  - e54 -- f54 pink
  - h54 -- h50 pink
  - i50 -- i27 pink
  - e27 -- f27 pink
  - a27 -- a24 pink
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/10-state-machine-build-1.svg)

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図1b 同期とエッジ検出のユニバーサル基板 (ユニット 1)
board:
  size: 15x9cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  NC_U6_6: j12
  NC_U6_8: k15
  NC_U7_8: am15
  NC_U7_10: ak15
  NC_U7_12: ai15
  NC_U8_8: ax15
  NC_U8_11: au15
  NC_U5_8: ab15
  NC_U5_6: aa12
parts:
  PS:
    type: device
    at: az-1
    label: 電源 5V
    pins: [GND, +5V]
  LINKT:
    type: device
    at: aa36
    label: 他ユニット
    pins: [CLK, T440, NE440, E440, E880]
  LINKB:
    type: device
    at: p-1
    label: 他ユニット
    pins: [T880, CLK]
  U8: dip14 ar15 74HC08
  U5: dip14 v15 74HC74
  U7: dip14 ag15 74HC04
  U6: dip14 e15 74HC74
  C1: capacitor/ceramic l16 l14 100n
  C2: capacitor/ceramic ac16 ac14 100n
  C3: capacitor/ceramic ag17 ai17 100n
  C4: capacitor/ceramic ar17 at17 100n
wires:
  - PS.GND -- az1 black
  - PS.+5V -- ba1 red
  - LINKT.CLK -- aa33 yellow
  - LINKT.T440 -- ab33 blue
  - LINKT.NE440 -- ac33 purple
  - LINKT.E440 -- ad33 blue
  - LINKT.E880 -- ae33 brown
  - LINKB.T880 -- p1 green
  - LINKB.CLK -- q1 yellow
  - e15 -- e30 red
  - e15 -- f15 red
  - e15 -- d15 red
  - d15 -- d12 red
  - d12 -- e12 red
  - i15 -- i16 red
  - i16 -- i30 red
  - h12 -- h13 red
  - h13 -- e13 red
  - e13 -- e12 red
  - l16 -- i16 red
  - v15 -- v30 red
  - v15 -- w15 red
  - v15 -- u15 red
  - u15 -- u12 red
  - u12 -- v12 red
  - z15 -- z16 red
  - z16 -- z30 red
  - y12 -- y13 red
  - y13 -- v13 red
  - v13 -- v12 red
  - ac16 -- z16 red
  - ag15 -- ag17 red
  - ag17 -- ag30 red
  - ar15 -- ar17 red
  - ar17 -- ar30 red
  - ba1 -- ba30 red
  - e30 -- i30 red
  - i30 -- v30 red
  - v30 -- z30 red
  - z30 -- ag30 red
  - ag30 -- ar30 red
  - ar30 -- ba30 red
  - k12 -- l12 black
  - l12 -- l4 black
  - l14 -- l12 black
  - ab12 -- ac12 black
  - ac12 -- ac4 black
  - ac14 -- ac12 black
  - ah16 -- ai16 black
  - ai16 -- aj16 black
  - aj16 -- al16 black
  - al16 -- an16 black
  - ah15 -- ah16 black
  - aj15 -- aj16 black
  - al15 -- al16 black
  - an16 -- an12 black
  - am12 -- an12 black
  - an12 -- an4 black
  - ai17 -- ai16 black
  - as16 -- at16 black
  - at16 -- av16 black
  - av16 -- aw16 black
  - aw16 -- ay16 black
  - as15 -- as16 black
  - at15 -- at16 black
  - av15 -- av16 black
  - aw15 -- aw16 black
  - ay16 -- ay12 black
  - ax12 -- ay12 black
  - ay12 -- ay4 black
  - at17 -- at16 black
  - az1 -- az4 black
  - l4 -- ac4 black
  - ac4 -- an4 black
  - an4 -- ay4 black
  - ay4 -- az4 black
  - f12 -- f1 green
  - f1 -- p1 green
  - n33 -- aa33 yellow
  - n33 -- n18 yellow
  - h18 -- h15 yellow
  - h18 -- n18 yellow
  - n18 -- n10 yellow
  - x12 -- x10 yellow
  - n10 -- x10 yellow
  - ab33 -- ab32 blue
  - t32 -- t11 blue
  - t32 -- ab32 blue
  - w12 -- w11 blue
  - t11 -- w11 blue
  - g15 -- g14 orange
  - g14 -- i14 orange
  - i14 -- i12 orange
  - i12 -- i3 orange
  - au12 -- au3 orange
  - i3 -- au3 orange
  - aa15 -- aa13 pink
  - aa13 -- ae13 pink
  - ae13 -- ae12 pink
  - ae12 -- ag12 pink
  - af18 -- ao18 purple
  - af18 -- af13 purple
  - ao18 -- ao11 purple
  - af13 -- ah13 purple
  - ah13 -- ah12 purple
  - as12 -- as11 purple
  - ao11 -- as11 purple
  - x19 -- x15 green
  - x19 -- ap19 green
  - ap19 -- ap12 green
  - x15 -- x14 green
  - x14 -- z14 green
  - z14 -- z12 green
  - ap12 -- ar12 green
  - ad33 -- ad32 blue
  - ad32 -- aq32 blue
  - aq32 -- aq13 blue
  - aq13 -- at13 blue
  - at13 -- at12 blue
  - ak12 -- ak10 blue
  - at12 -- at10 blue
  - ak10 -- at10 blue
  - j17 -- m17 orange
  - j17 -- j15 orange
  - m17 -- m9 orange
  - ai12 -- ai9 orange
  - m9 -- ai9 orange
  - ae33 -- az33 brown
  - az33 -- az11 brown
  - aw12 -- aw11 brown
  - aw11 -- az11 brown
  - aj12 -- aj9 white
  - av12 -- av9 white
  - aj9 -- av9 white
  - y17 -- ad17 yellow
  - y17 -- y15 yellow
  - ad17 -- ad1 yellow
  - g12 -- g2 yellow
  - g2 -- q2 yellow
  - q2 -- q1 yellow
  - q1 -- ad1 yellow
  - ac33 -- ac31 purple
  - ac31 -- ae31 purple
  - ae31 -- ae14 purple
  - ae14 -- al14 purple
  - al14 -- al12 purple
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/10-state-machine-build-1.svg)

- 図 1b: 9×15 cm のユニバーサル基板を横に置く (54 列 × 33 行)。+ の筋を上 (30 行)、GND の筋を下 (4 行) に通し、IC は左から U6 が `e15`、U5 が `v15`、U7 が `ag15`、U8 が `ar15` に向きをそろえて 1 列に並べた (回していない)。74HC74 の 1Q→2D と 1PRE→1CLR は胴の下 (半田面) で結ぶ。IC のあいだの列が縦の線で埋まるので、隣の IC へ渡る 4 本 (A5 の `aa13`〜`ae13`、B1 の `af13`〜`ah13`、NE440 の `ae14`〜`al14`、E440 の `aq13`〜`at13`) も半田面で胴の下を通す。信号線の道筋と他ユニットの箱のピンの並びは、交差が少なくなるように選んだ (+ と GND の筋と各 IC への電源の線が基板を区切るので、いくつかは跨ぐ)。check のネットリストは図 1 と同じ

- IC は 74HC74 が 2 個 (U5、U6)、74HC04 (U7)、74HC08 (U8)。CLK は 4 つのフリップフロップの CLK ピン (PIN 3、11) へ、箱の CLK から 1 本ずつ引く。

### 図 2・2b: ユニット 2 (間隔タイマと窓)

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 間隔タイマと窓のブレッドボード (ユニット 2)
board: full
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: top
    label: 他のユニットへ (上)
    pins: [W, NE440]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [TO, CLK]
  U11: dip14 @ e5 r180 l=74HC02
  U10: dip14 @ e13 r180 74HC08
  U9: dip16 @ e23 74HC163
  C1: capacitor/ceramic +t10 -t10 100n
  C2: capacitor/ceramic +t18 -t18 100n
  C3: capacitor/ceramic +t26 -t26 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t2 -- +b2 red
  - -t3 -- -b3 black
  - +t31 -- +t33 red
  - -t31 -- -t33 black
  - +b31 -- +b33 red
  - -b31 -- -b33 black
  - -t5 -- a5 black
  - -t6 -- a6 black
  - -t7 -- a7 black
  - -b5 -- j5 black
  - -b6 -- j6 black
  - -b8 -- j8 black
  - -b9 -- j9 black
  - +b11 -- j11 red
  - -t13 -- a13 black
  - -b17 -- j17 black
  - -b18 -- j18 black
  - +b19 -- j19 red
  - +t23 -- a23 red
  - +t29 -- a29 red
  - +b23 -- j23 red
  - -b25 -- j25 black
  - +b26 -- j26 red
  - -b27 -- j27 black
  - -b28 -- j28 black
  - +b29 -- j29 red
  - -b30 -- j30 black
  - LINKT.W -- a14 orange
  - LINKT.NE440 -- a30 orange
  - LINKB.TO -- j13 orange
  - LINKB.CLK -- j24 yellow
  - b25 -- b19 green
  - c26 -- c18 green
  - b11 -- b15 green
  - c10 -- c17 green
  - a10 -- a12 green
  - d12 -- g12 green
  - i12 -- i14 green
  - b27 -- b31 green
  - d31 -- g31 green
  - i31 -- i22 green
  - j22 -- j20 green
  - h20 -- h4 green
  - d4 -- g4 green
  - b4 -- b9 green
  - c28 -- c32 green
  - d32 -- g32 green
  - h32 -- h21 green
  - d21 -- g21 green
  - a21 -- a16 green
  - i21 -- i15 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/10-state-machine-build-2.svg)

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図2b 間隔タイマと窓のユニバーサル基板 (ユニット 2)
board:
  size: 7x9cm
  h: 1.6mm
  material: FR-4
  slots: on
points:
  NC_U11_4: i9
  NC_U11_10: f10
  NC_U11_13: f7
  NC_U10_11: r13
  NC_U9_15: h23
parts:
  PS:
    type: device
    at: -c17
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: -c5
    label: 他ユニット
    pins: [W, NE440]
  LINKB:
    type: device
    at: -c25
    label: 他ユニット
    pins: [CLK, TO]
  U11: dip14 f6 74HC02
  U9: dip16 h24 r180 74HC163
  U10: dip14 r16 r180 74HC08
  C1: capacitor/ceramic g15 g13 100n
  C2: capacitor/ceramic t18 t16 100n
  C3: capacitor/ceramic e15 e13 100n
wires:
  - PS.+5V -- a17 red
  - PS.GND -- a18 black
  - LINKT.W -- a5 purple
  - LINKT.NE440 -- a6 orange
  - LINKB.CLK -- a25 yellow
  - LINKB.TO -- a26 brown
  - a17 -- c17 red
  - c17 -- c15 red
  - a18 -- d18 black
  - d18 -- d17 black
  - d19 -- d18 black
  - e18 -- g18 red
  - e21 -- g21 red
  - e24 -- g24 red
  - g18 -- g21 red
  - g21 -- g24 red
  - g24 -- h24 red
  - h18 -- g18 red
  - f8 -- g8 black
  - f9 -- g9 black
  - f11 -- g11 black
  - f12 -- g12 black
  - g8 -- g9 black
  - g9 -- g11 black
  - g11 -- g12 black
  - g12 -- h12 black
  - h12 -- i12 black
  - i11 -- h11 black
  - i10 -- h10 black
  - h10 -- h11 black
  - h11 -- h12 black
  - i10 -- o10 black
  - t14 -- v14 black
  - v14 -- v25 black
  - v25 -- d25 black
  - d25 -- d22 black
  - e13 -- g13 black
  - t16 -- t14 black
  - o8 -- o10 black
  - o8 -- t8 black
  - g13 -- i13 black
  - d19 -- d22 black
  - d19 -- e19 black
  - e19 -- e20 black
  - t8 -- t14 black
  - t14 -- r14 black
  - i12 -- i13 black
  - r14 -- r15 black
  - d17 -- e17 black
  - d22 -- e22 black
  - g15 -- e15 red
  - g15 -- i15 red
  - t18 -- t24 red
  - t18 -- r18 red
  - i15 -- i18 red
  - f6 -- c6 red
  - h18 -- i18 red
  - c15 -- e15 red
  - c15 -- c6 red
  - r16 -- r18 red
  - h24 -- t24 red
  - h22 -- o22 blue
  - o16 -- o22 blue
  - a23 -- a25 yellow
  - a23 -- e23 yellow
  - a5 -- n5 purple
  - n5 -- n11 purple
  - n11 -- o11 purple
  - h21 -- n21 white
  - n15 -- n21 white
  - n15 -- o15 white
  - i6 -- m6 pink
  - m6 -- m12 pink
  - m12 -- o12 pink
  - a6 -- a16 orange
  - a16 -- h16 orange
  - h16 -- h17 orange
  - h20 -- j20 blue
  - i8 -- j8 blue
  - j8 -- j20 blue
  - a26 -- u26 brown
  - r10 -- u10 brown
  - u10 -- u26 brown
  - i7 -- l7 orange
  - l7 -- l14 orange
  - l14 -- o14 orange
  - o14 -- q14 orange
  - q11 -- r11 orange
  - q11 -- q14 orange
  - h19 -- m19 green
  - m13 -- m19 green
  - m13 -- o13 green
  - o13 -- p13 green
  - p9 -- s9 green
  - p9 -- p13 green
  - r12 -- s12 green
  - s9 -- s12 green
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/10-state-machine-build-2.svg)

- 図 2b: 7×9 cm のユニバーサル基板 (26 列 × 31 行)。IC は U11 が `f6`、U9 が `h24`、U10 が `r16` (U9・U10 は 180 度回した)。+5 V は上の `c` 行から U11 の VCC と U9 の ENT へ配り、U9 の中を通って VCC (`h24`) から U10 へ回す。GND は U9 の上の `d` 行の筋から右の縁の 25 列を下りて U10 へ、U10 から 10 列を上がって U11 へ回す。+ と GND の線は交わらない。半田面で胴の下を通す線は、どれも同じ IC の中の結線: U9 の CLR・B・ENP・ENT を VCC へ、U11 の使わないゲートの入力を GND へ、U10 の 1Y→3A と 2A→3B。U10 の 2A→3B (QD) の線は、ピンの並びの都合で QC・1Y・TO の線と交わる。ほかの交差は、信号が電源の枝を跨ぐ所。check のネットリストは図 2 と同じ

- 74HC163 (U9) のデータ入力は、B (PIN 4) だけ +5 V、A・C・D (PIN 3、5、6) は GND で、値 2 を読み込む。CLR (PIN 1)、ENP (PIN 7)、ENT (PIN 10) は +5 V。

### 図 3・3b: ユニット 3 (状態を動かす条件)

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図3 状態を動かす条件のブレッドボード (ユニット 3)
board: full
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: top
    label: 他のユニットへ (上)
    pins: [PON, CLRN, TO, E880, LOADN, NE440, EN, E440, W, QB, QA]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [S3]
  U15: dip14 @ e3 r180 l=74HC02
  U14: dip14 @ e12 r180 74HC32
  U13: dip14 @ e21 r180 74HC08
  U12: dip14 @ e34 r180 l=74HC86
  C1: capacitor/ceramic +b10 -b10 100n
  C2: capacitor/ceramic +b19 -b19 100n
  C3: capacitor/ceramic +b28 -b28 100n
  C4: capacitor/ceramic +b41 -b41 100n
wires:
  # 電源とレール
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t30 -- +t32 red
  - -t30 -- -t32 black
  - +b30 -- +b32 red
  - -b30 -- -b32 black
  - +t44 -- +b44 red
  - -t44 -- -b44 black
  # U15 74HC02 の電源と使わない入力
  - -t3 -- a3 black
  - -t4 -- a4 black
  - -t5 -- a5 black
  - -b3 -- j3 black
  - -b4 -- j4 black
  - -b6 -- j6 black
  - -b7 -- j7 black
  - +b9 -- j9 red
  # U14 74HC32
  - -t12 -- a12 black
  - -b16 -- j16 black
  - -b17 -- j17 black
  - +b18 -- j18 red
  # U13 74HC08
  - -t21 -- a21 black
  - -b25 -- j25 black
  - -b26 -- j26 black
  - +b27 -- j27 red
  # U12 74HC86
  - -t34 -- a34 black
  - -t36 -- a36 black
  - -t37 -- a37 black
  - -b35 -- j35 black
  - -b36 -- j36 black
  - -b38 -- j38 black
  - -b39 -- j39 black
  - +b40 -- j40 red
  # 他のユニットとの線
  - LINKT.PON -- a7 orange
  - LINKT.CLRN -- a9 orange
  - LINKT.TO -- a14 orange
  - LINKT.E880 -- a15 orange
  - LINKT.LOADN -- a16 orange
  - LINKT.NE440 -- a18 orange
  - LINKT.EN -- a22 orange
  - LINKT.E440 -- a24 orange
  - LINKT.W -- a27 orange
  - LINKT.QB -- a39 orange
  - LINKT.QA -- a40 orange
  - LINKB.S3 -- j22 orange
  # E440 を U13 の 10 番へ (28 列で下へ渡る)
  - c24 -- c28 orange
  - d28 -- g28 orange
  - h28 -- h23 orange
  # U14 3Y (8 番) → U15 1A (2 番) (10 列で上へ渡る)
  - i12 -- i10 green
  - g10 -- d10 green
  - c10 -- c8 green
  # U14 2Y (6 番) → U14 3A (9 番) (11 列で下へ渡る)
  - c13 -- c11 green
  - d11 -- g11 green
  - h11 -- h13 green
  # U13 3Y (8 番) → U14 3B (10 番)
  - i21 -- i14 green
  # U13 1Y (3 番) → U14 1B (2 番)・U13 2B (5 番)
  - c17 -- c23 green
  - b23 -- b25 green
  # U12 1Y (3 番) → U13 1B (2 番)
  - b26 -- b38 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/10-state-machine-build-3.svg)

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図3b 状態を動かす条件のユニバーサル基板 (ユニット 3)
board:
  size: 15x9cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  NC_U15_10: aw20
  NC_U15_13: at20
  NC_U15_4: av17
  U14_9_6: aj20
  NC_U14_11: ah20
  NC_U12_8: i20
  NC_U12_11: f20
  NC_U12_6: h17
  NC_U13_11: t20
parts:
  PS:
    type: device
    at: az36
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: r-1
    label: 他ユニット
    pins: [E440, QA, QB, W, EN, NE440, LOADN, E880, TO, CLRN, PON]
  LINKB:
    type: device
    at: v36
    label: 他ユニット
    pins: [S3]
  U12: dip14 c20 74HC86
  U13: dip14 q20 74HC08
  U14: dip14 ae20 74HC32
  U15: dip14 as20 74HC02
  C1: capacitor/ceramic c22 d22 100n
  C2: capacitor/ceramic q22 r22 100n
  C3: capacitor/ceramic ae22 af22 100n
  C4: capacitor/ceramic as22 au22 100n
wires:
  - PS.+5V -- az33 red
  - PS.GND -- ba33 black
  - LINKT.E440 -- r1 blue
  - LINKT.QA -- s1 pink
  - LINKT.QB -- t1 green
  - LINKT.W -- u1 pink
  - LINKT.EN -- v1 green
  - LINKT.NE440 -- w1 blue
  - LINKT.LOADN -- x1 purple
  - LINKT.E880 -- y1 brown
  - LINKT.TO -- z1 white
  - LINKT.CLRN -- aa1 blue
  - LINKT.PON -- ab1 orange
  - LINKB.S3 -- v33 orange
  - az33 -- az30 red
  - az30 -- as30 red
  - as30 -- ae30 red
  - ae30 -- q30 red
  - q30 -- c30 red
  - c30 -- c22 red
  - c22 -- c20 red
  - q30 -- q22 red
  - q22 -- q20 red
  - ae30 -- ae22 red
  - ae22 -- ae20 red
  - as30 -- as22 red
  - as22 -- as20 red
  - d22 -- d20 black
  - r22 -- r20 black
  - af22 -- af20 black
  - au22 -- au20 black
  - ba33 -- ba9 black
  - ba9 -- ay9 black
  - ay9 -- ak9 black
  - ak9 -- w9 black
  - w9 -- i9 black
  - i9 -- i17 black
  - w9 -- w17 black
  - ak9 -- ak17 black
  - ay9 -- ay17 black
  - d20 -- d19 black
  - e20 -- e19 black
  - g20 -- g19 black
  - h20 -- h19 black
  - d19 -- e19 black
  - e19 -- g19 black
  - g19 -- h19 black
  - h19 -- i19 black
  - i19 -- i18 black
  - i18 -- i17 black
  - f17 -- f18 black
  - g17 -- g18 black
  - f18 -- g18 black
  - g18 -- i18 black
  - r20 -- r19 black
  - s20 -- s19 black
  - r19 -- s19 black
  - s19 -- w19 black
  - w19 -- w17 black
  - af20 -- af19 black
  - ag20 -- ag19 black
  - af19 -- ag19 black
  - ag19 -- ak19 black
  - ak19 -- ak17 black
  - au20 -- au19 black
  - av20 -- av19 black
  - ax20 -- ax19 black
  - au19 -- av19 black
  - av19 -- ax19 black
  - ax19 -- ay19 black
  - ay20 -- ay19 black
  - ay19 -- ay18 black
  - ay18 -- ay17 black
  - aw17 -- aw18 black
  - ax17 -- ax18 black
  - aw18 -- ax18 black
  - ax18 -- ay18 black
  - t17 -- t18 blue
  - t18 -- u18 blue
  - u18 -- u20 blue
  - aj17 -- aj20 purple
  - r1 -- r2 blue
  - r2 -- b2 blue
  - b2 -- b24 blue
  - b24 -- u24 blue
  - u24 -- u20 blue
  - s1 -- s3 pink
  - s3 -- c3 pink
  - c3 -- c17 pink
  - t1 -- t4 green
  - t4 -- d4 green
  - d4 -- d17 green
  - u1 -- u5 pink
  - u5 -- q5 pink
  - q5 -- q17 pink
  - v1 -- v17 green
  - e17 -- e16 white
  - e16 -- r16 white
  - r16 -- r17 white
  - s17 -- s15 brown
  - s15 -- u15 brown
  - u15 -- u17 brown
  - u15 -- af15 brown
  - af15 -- af17 brown
  - w1 -- w8 blue
  - w8 -- ae8 blue
  - ae8 -- ae17 blue
  - x1 -- x7 purple
  - x7 -- ag7 purple
  - ag7 -- ag17 purple
  - y1 -- y6 brown
  - y6 -- ah6 brown
  - ah6 -- ah17 brown
  - z1 -- z5 white
  - z5 -- ai5 white
  - ai5 -- ai17 white
  - aa1 -- aa4 blue
  - aa4 -- as4 blue
  - as4 -- as17 blue
  - ab1 -- ab3 orange
  - ab3 -- au3 orange
  - au3 -- au17 orange
  - v33 -- v20 orange
  - w20 -- w24 yellow
  - w24 -- ai24 yellow
  - ai24 -- ai20 yellow
  - ak20 -- ak21 green
  - ak21 -- al21 green
  - al21 -- al16 green
  - al16 -- at16 green
  - at16 -- at17 green
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/10-state-machine-build-3.svg)

- 図 3b: 9×15 cm のユニバーサル基板を横に置く (54 列 × 33 行)。IC は U12 が `c20`、U13 が `q20`、U14 が `ae20`、U15 が `as20` で、信号の流れの順に横一列に向きをそろえて並べた (回していない)。+ の筋を上 (30 行)、GND の筋を下 (9 行) に通し、各 IC の VCC (左上) は上の筋へ、GND (右下) は下の筋へ短い枝で結ぶ。S3 の箱は上、ほかの箱は下に置いた。半田面で胴の下を通す線は、どれも同じ IC の中の結線: 4 個とも使わないゲートの入力を GND へ、U13 の 2A→3B (E440)、U14 の 2Y→3A。信号どうしが交わるのは、同じ箱へ行く 2 本のピンに挟まれたピン (U13 と U14 の 1B、U15 の 1A) へ、別の IC から線が来る所。ほかの交差は、信号が電源の枝を跨ぐ所。check のネットリストは図 3 と同じ

- IC は 74HC86 (U12)、74HC08 (U13)、74HC32 (U14)、74HC02 (U15)。入力が 9 本と出力が 3 本ある。図 3 では入力を上の箱、S3 だけ下の箱から入れる。図 3b は逆で、S3 を上の箱、ほかを下の箱から入れる。

### 図 4・4b: ユニット 4 (状態レジスタと出力)

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図4 状態レジスタと出力のブレッドボード (ユニット 4)
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: top
    label: 他のユニットへ (上)
    pins: [EN, CLK, CLRN, S3, OUT]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [LOADN, QB, QA, E880, W]
  U16: dip16 @ e5 r180 74HC163
  U17: dip14 @ e16 74HC08
  C1: capacitor/ceramic +b14 -b14 100n
  C2: capacitor/ceramic +t14 -t14 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - -t25 -- -b25 black
  - +t26 -- +b26 red
  - -t5 -- a5 black
  - -t7 -- a7 black
  - -t8 -- a8 black
  - -t9 -- a9 black
  - +t10 -- a10 red
  - j12 -- +b12 red
  - +t16 -- a16 red
  - -t17 -- a17 black
  - -t18 -- a18 black
  - j22 -- -b22 black
  - LINKT.EN -- a3 orange
  - c3 -- c6 orange
  - d3 -- g3 orange
  - h3 -- h6 orange
  - LINKT.CLK -- a11 yellow
  - LINKT.CLRN -- a12 orange
  - LINKB.LOADN -- j5 orange
  - LINKB.QB -- j9 orange
  - LINKB.QA -- j10 orange
  - h10 -- h16 orange
  - i9 -- i17 orange
  - j18 -- j15 orange
  - g15 -- d15 orange
  - c15 -- c21 orange
  - LINKT.S3 -- a21 orange
  - LINKT.OUT -- a22 orange
  - LINKB.E880 -- j19 orange
  - LINKB.W -- j20 orange
  - h21 -- h23 green
  - g23 -- d23 green
  - b23 -- b20 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/10-state-machine-build-4.svg)

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図4b 状態レジスタと出力のユニバーサル基板 (ユニット 4)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  NC_U16_11: f8
  NC_U16_12: g8
  NC_U16_15: j8
  U17_6_10: s8
  NC_U17_11: q11
parts:
  PS:
    type: device
    at: v21
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: m21
    label: 他ユニット
    pins: [EN, CLK, CLRN, S3, OUT]
  LINKB:
    type: device
    at: j-1
    label: 他ユニット
    pins: [LOADN, QB, QA, E880, W]
  U16: dip16 k8 r180 74HC163
  U17: dip14 n11 74HC08
  C1: capacitor/ceramic i12 h12 100n
  C2: capacitor/ceramic n12 o12 100n
wires:
  - PS.+5V -- v18 red
  - v18 -- v14 red
  - v14 -- n14 red
  - n14 -- l14 red
  - l14 -- i14 red
  - n14 -- n12 red
  - n12 -- n11 red
  - i14 -- i12 red
  - i12 -- i11 red
  - l14 -- l8 red
  - l8 -- k8 red
  - PS.GND -- w18 black
  - w18 -- w3 black
  - w3 -- t3 black
  - t3 -- c3 black
  - t3 -- t8 black
  - c3 -- c11 black
  - c11 -- d11 black
  - f11 -- f12 black
  - g11 -- g12 black
  - h11 -- h12 black
  - f12 -- g12 black
  - g12 -- h12 black
  - f12 -- d12 black
  - d12 -- d11 black
  - o11 -- o12 black
  - p11 -- p12 black
  - o12 -- p12 black
  - p12 -- u12 black
  - u12 -- u8 black
  - u8 -- t8 black
  - e11 -- e8 purple
  - p8 -- p9 green
  - p9 -- s9 green
  - s9 -- s11 green
  - s8 -- s7 gray
  - s7 -- v7 gray
  - v7 -- v13 gray
  - v13 -- r13 gray
  - r13 -- r11 gray
  - LINKT.EN -- m18 purple
  - m18 -- m17 purple
  - m17 -- e17 purple
  - e17 -- e11 purple
  - LINKT.CLK -- n18 yellow
  - n18 -- n16 yellow
  - n16 -- j16 yellow
  - j16 -- j11 yellow
  - LINKT.CLRN -- o18 blue
  - o18 -- o15 blue
  - o15 -- k15 blue
  - k15 -- k11 blue
  - LINKT.S3 -- p18 green
  - p18 -- p16 green
  - p16 -- s16 green
  - s16 -- s11 green
  - LINKT.OUT -- q18 orange
  - q18 -- q17 orange
  - q17 -- t17 orange
  - t17 -- t11 orange
  - LINKB.LOADN -- j1 green
  - j1 -- j5 green
  - j5 -- d5 green
  - d5 -- d8 green
  - LINKB.QB -- k1 white
  - k1 -- k6 white
  - h8 -- h6 white
  - h6 -- k6 white
  - k6 -- o6 white
  - o6 -- o8 white
  - LINKB.QA -- l1 orange
  - l1 -- l7 orange
  - i8 -- i7 orange
  - i7 -- l7 orange
  - l7 -- n7 orange
  - n7 -- n8 orange
  - LINKB.E880 -- m1 brown
  - m1 -- m5 brown
  - m5 -- q5 brown
  - q5 -- q8 brown
  - LINKB.W -- n1 pink
  - n1 -- n4 pink
  - n4 -- r4 pink
  - r4 -- r8 pink
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/10-state-machine-build-4.svg)

- 図 4b: 5×7 cm のユニバーサル基板を横に置く (24 列 × 18 行)。IC は U16 が `k8` (180 度回した)、U17 が `n11` (回していない)。+ の筋を上 (14 行)、GND の筋を下 (3 行) に通し、U16 の VCC (右下) は 12 列を上がって + の筋へ、U17 の VCC (左上) は上の筋へ結ぶ。半田面で胴の下を通す線は、どれも同じ IC の中の結線: U16 の ENP→ENT (EN) と、U17 の 1Y→3A (S3)。信号どうしが交わるのは、QA と QB が U16 と U17 で同じ向きに並ぶ所と、U17 の 2Y→3B が胴の外を回るので OUT と 3A がそれを跨ぐ所。ほかの交差は、信号が電源の枝を跨ぐ所。check のネットリストは図 4 と同じ

- 74HC163 (U16) のデータ入力は、A (PIN 3) だけ +5 V、B〜D は GND で、値 1 を読み込む。ENP (PIN 7) と ENT (PIN 10) は、EN を 1 本の線で受ける。

## Analog Discovery 3 で試験する

**計器は Analog Discovery 3 (AD3) 1 台。** 電源は Supplies の V+ (5 V)、クロックは Wavegen W1、T440 は Wavegen W2、見るのは Scope の 2 ch (T440 と OUT)。
ブロック全体の 74HC は 13 個で、8 Hz の遅い動作なので、電流は目安で 1 mA に満たず、V+ の 50 mA (USB 給電で 250 mW) に収まる。
T880 は 3 回目の T440 のあと、+5 V の線を押しボタンで触れて H にする。AD3 の DIO は 3.3 V の出力で、74HC (5 V) の H の下限 3.5 V に届かないので使わない。
本物の T440・T880 は検出の回路 ([03-detect.md](03-detect.md)) が作る。ここでは、それが無くても状態遷移だけを試験できるようにする。

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図5 AD3 と基板 1〜4 の端子 (試験用のつなぎ)
board: half
parts:
  S1: switch d8 d12
  R1: resistor b8 b10 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, W2, "1+", "2+", "1-", "2-"]
  LINK:
    type: device
    at: bottom
    label: 基板 1〜4 の端子
    pins: [CLK, T440, T880, OUT, GND, +5V]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - LINK.+5V -- +t26 red
  - LINK.GND -- -t25 black
  - AD.W1 -- a4 yellow
  - LINK.CLK -- e4 yellow
  - AD.W2 -- a6 orange
  - AD.1+ -- a7 orange
  - c6 -- c7 orange
  - LINK.T440 -- e6 orange
  - LINK.T880 -- e8 green
  - a10 -- -t10 black
  - a12 -- +t12 red
  - AD.2+ -- a14 blue
  - LINK.OUT -- e14 blue
  - AD.1- -- -t16 black
  - AD.2- -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/10-state-machine-build-5.svg)

- 基板 1〜4 の電源 (5 V と GND) と、4 枚のブレッドボードの間の信号は、これまでの図のとおり。AD3 とつなぐのは、基板 1 の CLK・T440・T880 の入力と、基板 4 の OUT の出力
- 押しボタン S1 (12 列) は +5 V につなぎ、T880 (8 列) へ渡す。R1 (10 kΩ) は、押さないとき T880 を L に保つプルダウン

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Square、8 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)。W2: Pulse、1 Hz、Amplitude 2.5 V、Offset 2.5 V、Duty 20 % (幅 0.2 s)、Burst の回数 3 (1 秒おきに 3 回だけ出る) |
| Scope | CH1 = T440、CH2 = OUT。500 ms/div、Trigger は CH1 の立ち上がり、Mode は Normal (単発で測る)。1 回目の T440 が t = 0 |

図6 は、T440 の 3 回のあと T880 を触れたときの見えるはずの画面で、2-4 の図1 (計算) と同じ時刻を CH1・CH2 で見たもの。
**OUT は T880 のあとの 3.125〜3.25 秒に 1 クロック (0.125 秒) だけ H になる。** 4 回目の T440 を出したり、間隔を 1.5 秒にしたりすると、OUT は出ない (2-4 の図2・図3)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図6 T440 (CH1) が 3 回来たあと、OUT (CH2) に 0.125 s のパルスが 1 つ
time: 500ms/div
trigger: ch1 rising 2.5V at -5div
ch1: {wave: "= 5V * (step(t - 40ms) - step(t - 240ms) + step(t - 1.04s) - step(t - 1.24s) + step(t - 2.04s) - step(t - 2.24s))", range: 2V/div, position: 1div}
ch2: {wave: "= 5V * (step(t - 3.125s) - step(t - 3.25s))", range: 2V/div, position: -3div}
cursors: [1.5s, 3.2s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/10-state-machine-build.svg)

## 見るべき値

図6 (見えるはずの画面) の読み値と、2-4 のタイミングの計算値。どれも計算で、実測ではない。

| 項目 | 見るべき値 | 根拠 |
| --- | --- | --- |
| T440 (CH1) | 0〜5 V、幅 0.2 秒の H が 1 秒おきに 3 回 | Wavegen W2 (Pulse 1 Hz、Duty 20 %、Burst 3) |
| OUT (CH2) の位置 | 3.125〜3.25 秒 (1 回目の T440 が t = 0) | 図6、2-4 の図1 |
| OUT の幅 | 0.125 秒 (8 Hz の 1 クロック) | 図6。カーソル X2 (3.2 秒) で CH2 5.00 V、X1 (1.5 秒) で 0 V |
| OUT の高さ | 0〜5 V | 図6 の Vmax・Vmin |
| 4 回目の T440 を出したとき | OUT は出ない | 2-4 の図2 |
| 2 回目の間隔を 1.5 秒にしたとき | OUT は出ない | 2-4 の図3 |
| 電源の電流 (13 個の 74HC) | 1 mA に満たない (目安) | 8 Hz の遅い動作。V+ の 50 mA に収まる |

- OUT が出ないときは、ユニットを 1 枚ずつ切り分ける。ユニット 1 の E440・E880 が 1 クロックのパルスになっているか、ユニット 2 の W が前の E440 から 0.875〜1.125 秒のあいだだけ H か (2-4 の「設計の方針」)、の順に見る

## 出典

自作。参考: [TI の SN74HC74 データシート (SCLS094F)](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf)、
[TI の SN74HC04 データシート (SCLS078H)](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)、
[TI の SN74HC08 データシート (SCLS081J)](https://www.ti.com/lit/ds/symlink/sn74hc08.pdf)、
[TI の SN74HC163 データシート (SCLS298D)](https://www.ti.com/lit/ds/symlink/sn74hc163.pdf)、
[TI の SN74HC02 データシート (SCLS076G)](https://www.ti.com/lit/ds/symlink/sn74hc02.pdf)、
[TI の SN74HC86 データシート (SCLS100F)](https://www.ti.com/lit/ds/symlink/sn74hc86.pdf)、
[TI の SN74HC32 データシート (SCLS200F)](https://www.ti.com/lit/ds/symlink/sn74hc32.pdf)。
