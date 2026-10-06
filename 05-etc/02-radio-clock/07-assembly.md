---
book: etc
chapter: 2
id: 2-7
title: 組み立て — 受信・検波・状態遷移のユニバーサル基板をつなぐ
tier: 200
source: 自作
board: PF
---

# 2-7 組み立て — 受信・検波・状態遷移のユニバーサル基板をつなぐ

> [!WARNING]
> **この工作 (2 章 radio-clock) は、まだ実際の回路で検証していない。** 回路図・実体配線図・数値 (動作点、フィルタの値、波形、スペクトルなど) は、計算と見積りで作ったもので、正しく動くかどうかは確実ではない。組むときは、自分で確かめながら進めてほしい。

この題は回路図・Analog Discovery 3・オシロの図を付けない — 回路は 2-2〜2-4 の題のままで、この題が扱うのは基板の間の配線だけだから (各基板の回路図・測り方・見えるはずの波形は元の題にある)。

## 基板を分けて組む意味

[01-block.md](01-block.md) の ① 受信、② 時報音の検出、③ 状態遷移を、それぞれの題でユニバーサル基板に組んだ。
受信は [02-radio.md](02-radio.md) の図2b の 1 枚、検出は [03-detect.md](03-detect.md) の図4b〜6b の 3 枚、
状態遷移は [04-state-machine.md](04-state-machine.md) の図8b〜11b の 4 枚で、合わせて **8 枚**になる。
この題では、題をまたいでつなぐ所 (受信 → 検出、検出 → 状態遷移) を図にし、8 枚の間の線を 1 つの表にまとめる。

基板を分けて組むのは、次の理由による。

- **1 枚ずつ動かして確かめられる。** 受信の基板だけで検波出力に音声が出るか、検出の基板だけで 440 Hz を入れて T440 が H になるか、と区切って確かめられる。全部を 1 枚に組むと、動かないときにどこが悪いのかを絞れない
- **アナログとロジックを離せる。** 受信の基板は 594 kHz の高周波を増幅する。74HC のロジックの速い縁の雑音を、受信の基板に乗せにくくなる
- **作り直しが 1 枚で済む。** 例えばマイコン版 ([06-mcu.md](06-mcu.md)) に替えるときは、受信の基板をそのまま使い、後ろの基板だけを差し替えればよい

時計 ([05-clock.md](05-clock.md)) はユニバーサル基板の図が無い (ブレッドボードで組む) ので、この題の図には入れない。
時計とやりとりする線 (CLK・PON・OUT) は、表にだけ書く。

## 題をまたぐ配線の図

図は 2 つに分けた。1 つの図に並べる基板は 3 枚までにする決まりがあり、題をまたぐ所が 2 か所 (受信 → 検出、検出 → 状態遷移) あるから。
どちらの図も、上の基板が線を出す側、下の基板が受ける側。基板の外の線は図の右の通り道を通り、基板を出た所の札 (`→ 入力増幅.AF` など) が行き先を表す。
線の色は、赤が + (5 V)、黒が GND、黄が検波出力 (AF)、青が T440、緑が T880。

### 図1: 受信 → 入力増幅

受信の基板 (2-2 の図2b) の検波出力を、検出の 1 枚め (2-3 の図4b、入力増幅・基準電圧・しきい値) の入力へつなぐ。
5 V の電源は受信の基板の「電源 5V」の箱から入れ、入力増幅の基板へは受信の基板から 5 V と GND を渡す。

```perf
title: 図1 受信と入力増幅の基板をつなぐ
sheets:
  - name: 受信
    board:
      size: 7x5cm
      silk: board
      h: 1.6mm
      material: FR-4
      slots: on
    points:
      AF: w9
      GND: w2
      VCC: x17
    parts:
      BAR:
        type: device
        at: a0
        label: フェライトバー
        pins: TAP GND TOP
      VC1:
        type: device
        at: f0
        label: バリコン 365pF
        pins: A B
      PS:
        type: device
        at: w0
        label: 電源 5V
        pins: GND +5V
      C1: capacitor/ceramic a11 d11 0.01u
      R1: resistor e17 e12 82k
      R2: resistor e11 e2 22k
      Q1: transistor g10 g11 g12 2SC1815
      Rc1: resistor g17 g13 2.2k
      RE1: resistor g9 g2 470
      CE1: capacitor/electrolytic i9 i2 100u
      C2: capacitor/ceramic i12 l12 0.01u
      R3: resistor m17 m13 82k
      R4: resistor m12 m2 22k
      Q2: transistor o11 o12 o13 2SC1815
      Rc2: resistor o17 o14 2.2k
      RE2: resistor o10 o2 470
      CE2: capacitor/electrolytic q10 q2 100u
      D1: diode s13 s9 1N60
      C4: capacitor/ceramic u9 u2 0.01u
      R5: resistor w9 w2 100k
    wires:
      - BAR.TAP -- a11
      - BAR.GND -- b2
      - VC1.B -- g2
      - PS.+5V -- x17 red
      - x17 -- o17 red
      - PS.GND -- w2 black
      - BAR.TOP -- VC1.A
      - d11 -- e11
      - e12 -- e11
      - e11 -- g11
      - g13 -- g12
      - g10 -- g9
      - g9 -- i9
      - g12 -- i12
      - e17 -- g17 red
      - g17 -- m17 red
      - m17 -- o17 red
      - b2 -- e2 black
      - e2 -- g2 black
      - g2 -- i2 black
      - i2 -- k2 black
      - k2 -- m2 black
      - m2 -- o2 black
      - o2 -- q2 black
      - q2 -- s2 black
      - s2 -- u2 black
      - u2 -- w2 black
      - l12 -- m12
      - m13 -- m12
      - m12 -- o12
      - o14 -- o13
      - o11 -- o10
      - o10 -- q10
      - o13 -- s13
      - s9 -- t9
      - t9 -- u9
      - u9 -- w9
    notes:
      - mark t9 orange
      - text v8 orange: CH1
      - mark g12 green
      - text i13 green: CH2
      - mark k2 black
  - name: 入力増幅
    board:
      size: 7x5cm
      silk: board
      h: 1.6mm
      material: FR-4
      slots: on
    points:
      AF: x2
      GND: w4
      VCC: v17
    parts:
      LINK:
        type: device
        at: g22
        label: 2-3 図5b の基板へ
        pins: GND AF VB TH
      U1: dip8 k14 LM358
      Cin: capacitor/ceramic j6 m6 1u
      Rin: resistor n9 n6 10k
      Rf: resistor h8 l8 100k
      Ra: resistor p17 p15 10k
      Rb: resistor p13 p4 10k
      Cb: capacitor/electrolytic r13 r4 10u
      R6: resistor s17 s14 6.2k
      VR1: potentiometer/trimmer s12 t12 u12 2k
      R7: resistor u10 u4 5.6k
    wires:
      - v17 -- s17 red
      - s17 -- p17 red
      - p17 -- k17 red
      - k14 -- k17 red
      - w4 -- u4 black
      - u4 -- r4 black
      - r4 -- p4 black
      - p4 -- o4 black
      - o4 -- d4 black
      - d18 -- d4 black
      - c6 -- c2 yellow
      - c2 -- x2 yellow
      - LINK.GND -- g18 black
      - g18 -- d18 black
      - LINK.VB -- i18 green
      - i18 -- i15 green
      - i15 -- l15 green
      - l15 -- l14 green
      - l14 -- m14 green
      - m14 -- m11 green
      - LINK.AF -- h18 white
      - h18 -- h10 white
      - h10 -- k10 white
      - k10 -- k11 white
      - h10 -- h8 white
      - l11 -- l9 orange
      - l9 -- l8 orange
      - l9 -- n9 orange
      - n11 -- o11 black
      - o11 -- o4 black
      - c6 -- j6 yellow
      - m6 -- n6 orange
      - n14 -- p14 orange
      - p15 -- p14 orange
      - p14 -- p13 orange
      - p13 -- r13 orange
      - s14 -- s12 orange
      - u12 -- u10 orange
      - LINK.TH -- j18 purple
      - j18 -- t18 purple
      - t18 -- t12 purple
    style:
      back: on
links:
  - 受信.AF 入力増幅.AF yellow
  - 受信.VCC 入力増幅.VCC
  - 受信.GND 入力増幅.GND
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/07-assembly-1.svg)

### 図2: 比較器 → ユニット 1

検出の 3 枚め (2-3 の図6b、整流と平滑・比較器) の T440 と T880 を、状態遷移のユニット 1 (2-4 の図8b、同期とエッジ検出) へつなぐ。
5 V と GND は、どちらの基板も元の題と同じく共通の電源から入れる (比較器の基板は縁の `j18` と `k1`、ユニット 1 の基板は「電源 5V」の箱)。この図では線を描いていない。

```perf
title: 図2 比較器とユニット 1 の基板をつなぐ
sheets:
  - name: 比較器
    board:
      size: 7x5cm
      silk: board
      h: 1.6mm
      material: FR-4
      slots: on
    points:
      P_440: b18
      T_440: x2
      V_5V: j18
      TH: l18
      T_880: s13
      P_880: v18
      GND: k1
    parts:
      U4: dip8 m14 r90 LM393
      D1L: diode b12 e12
      RsL: resistor f12 i12 47k
      RhL: resistor d13 g13 2.2M
      CpL: capacitor/ceramic e11 e7 1u
      RpL: resistor g11 g7 100k
      RpuL: resistor i17 i14 10k
      D1H: diode v11 r11
      RsH: resistor n11 q11 47k
      RhH: resistor s12 p12 2.2M
      CpH: capacitor/ceramic r10 r6 1u
      RpH: resistor p10 p6 100k
      RpuH: resistor n17 n13 10k
    wires:
      - V_5V -- j17 red
      - i17 -- j17 red
      - j17 -- m17 red
      - m17 -- n17 red
      - m14 -- m17 red
      - GND -- k7 black
      - e7 -- g7 black
      - g7 -- k7 black
      - k7 -- k6 black
      - k6 -- p6 black
      - p6 -- r6 black
      - j11 -- k11 black
      - k11 -- k7 black
      - j14 -- i14 orange
      - i14 -- h14 orange
      - h14 -- d14 orange
      - d14 -- a14 orange
      - a14 -- a2 orange
      - a2 -- x2 orange
      - d14 -- d13 orange
      - P_440 -- b12 white
      - j12 -- i12 white
      - i12 -- i13 white
      - i13 -- g13 white
      - e12 -- f12 white
      - e12 -- e11 white
      - e11 -- g11 white
      - j13 -- l13 purple
      - l13 -- l12 purple
      - l12 -- m12 purple
      - TH -- l13 purple
      - m13 -- n13 orange
      - n13 -- o13 orange
      - o13 -- s13 orange
      - s13 -- s12 orange
      - m11 -- n11 white
      - n11 -- n12 white
      - n12 -- p12 white
      - r11 -- q11 white
      - r11 -- r10 white
      - r10 -- p10 white
      - P_880 -- v11 white
    notes:
      - text c17: P440
      - text k17: 5V
      - text m17: TH
      - text w17: P880
      - text l0: GND
    style:
      back: on
  - name: ユニット1
    board:
      size: 15x9cm
      silk: board
      h: 1.6mm
      material: FR-4
      slots: on
    points:
      T_440: aj33
      T_880: ar1
      NC_U6_6: ad13
      NC_U6_8: ac10
      NC_U7_8: r10
      NC_U7_10: t10
      NC_U7_12: v10
      NC_U8_8: z27
      NC_U8_11: w27
      NC_U5_8: ae24
      NC_U5_6: af27
    parts:
      PS:
        type: device
        at: v-1
        label: 電源 5V
        pins: [GND, +5V]
      LINKT:
        type: device
        at: x36
        label: 他ユニット
        pins: [NE440, E440, E880, CLK]
      LINKB:
        type: device
        at: ae-1
        label: 他ユニット
        pins: [CLK]
      U8: dip14 t27 74HC08
      U5: dip14 ak24 r180 74HC74
      U7: dip14 x10 r180 74HC04
      U6: dip14 ai10 r180 74HC74
      C1: capacitor/ceramic an8 an10 100n
      C2: capacitor/ceramic ad4 ad6 100n
      C3: capacitor/ceramic s27 s25 100n
      C4: capacitor/ceramic ai21 ai19 100n
    wires:
      - PS.GND -- v1 black
      - PS.+5V -- w1 red
      - LINKT.NE440 -- x33 purple
      - LINKT.E440 -- y33 blue
      - LINKT.E880 -- z33 brown
      - LINKT.CLK -- aa33 yellow
      - LINKB.CLK -- ae1 yellow
      - al23 -- al29 green
      - al23 -- ai23 green
      - ag27 -- ag29 green
      - ag29 -- al29 green
      - ag29 -- r29 green
      - ai24 -- ai23 green
      - r24 -- t24 green
      - r24 -- r29 green
      - u16 -- u24 purple
      - u16 -- w16 purple
      - w13 -- w16 purple
      - q17 -- q31 blue
      - q17 -- t17 blue
      - y31 -- y33 blue
      - y31 -- q31 blue
      - v17 -- v24 blue
      - v17 -- t17 blue
      - t13 -- t17 blue
      - ae15 -- ae13 orange
      - ae15 -- ae17 orange
      - ae15 -- aj15 orange
      - w24 -- w17 orange
      - aj15 -- aj9 orange
      - w17 -- ae17 orange
      - aj9 -- ag9 orange
      - ag10 -- ag9 orange
      - u13 -- u15 white
      - x24 -- x15 white
      - u15 -- x15 white
      - ab23 -- ab31 brown
      - ab23 -- y23 brown
      - y23 -- y24 brown
      - z33 -- z31 brown
      - ab31 -- z31 brown
      - ab6 -- ab7 black
      - ab6 -- ad6 black
      - am7 -- ab7 black
      - am7 -- am10 black
      - ac27 -- ae27 black
      - ac27 -- ac19 black
      - ac27 -- aa27 black
      - w7 -- w9 black
      - w7 -- v7 black
      - w7 -- ab7 black
      - aa28 -- y28 black
      - aa28 -- aa27 black
      - s10 -- s9 black
      - s9 -- u9 black
      - s9 -- q9 black
      - r13 -- q13 black
      - r13 -- r23 black
      - r23 -- s23 black
      - s23 -- s25 black
      - y28 -- y27 black
      - y28 -- v28 black
      - v1 -- v7 black
      - q13 -- q9 black
      - ac19 -- ai19 black
      - ac19 -- ac13 black
      - x27 -- y27 black
      - am10 -- an10 black
      - ac13 -- ab13 black
      - ab7 -- ab13 black
      - aa24 -- aa27 black
      - aa24 -- z24 black
      - u9 -- w9 black
      - u9 -- u10 black
      - v28 -- v27 black
      - v27 -- u27 black
      - w9 -- w10 black
      - w3 -- w1 red
      - w3 -- x3 red
      - am30 -- am22 red
      - am30 -- ak30 red
      - aj22 -- al22 red
      - aj22 -- aj24 red
      - aj22 -- ai22 red
      - aj24 -- ak24 red
      - ai22 -- ai21 red
      - ai22 -- ag22 red
      - al22 -- am22 red
      - al22 -- al16 red
      - t27 -- s27 red
      - t27 -- t30 red
      - ak30 -- ah30 red
      - ak30 -- ak27 red
      - ad3 -- an3 red
      - ad3 -- ad4 red
      - ad3 -- x3 red
      - ah30 -- ah27 red
      - ah30 -- t30 red
      - ag24 -- ag22 red
      - ae8 -- ae10 red
      - ae8 -- ak8 red
      - al13 -- al16 red
      - al13 -- ak13 red
      - an8 -- an3 red
      - an8 -- ak8 red
      - ak8 -- ak10 red
      - al16 -- af16 red
      - ak10 -- ak13 red
      - ak10 -- ai10 red
      - af16 -- af13 red
      - ah10 -- ai10 red
      - ai13 -- ak13 red
      - x3 -- x10 red
      - ab33 -- aj33 blue
      - aj33 -- aj27 blue
      - ai27 -- ai31 yellow
      - ai32 -- ai31 yellow
      - ai32 -- aa32 yellow
      - ai31 -- aq31 yellow
      - aq6 -- aq31 yellow
      - aq6 -- af6 yellow
      - af10 -- af6 yellow
      - aa33 -- aa32 yellow
      - af20 -- y20 pink
      - af20 -- af24 pink
      - y20 -- y13 pink
      - x13 -- y13 pink
      - as17 -- ah17 yellow
      - as17 -- as2 yellow
      - ag13 -- ag17 yellow
      - ah24 -- ah17 yellow
      - ag17 -- ah17 yellow
      - as2 -- ae2 yellow
      - ae2 -- ae1 yellow
      - aa8 -- aa14 orange
      - aa8 -- ad8 orange
      - ad8 -- ad10 orange
      - aa14 -- v14 orange
      - v14 -- v13 orange
      - p16 -- s16 purple
      - p16 -- p33 purple
      - s16 -- s13 purple
      - p33 -- x33 purple
      - ar1 -- af1 green
      - ar1 -- ar14 green
      - ar14 -- ah14 green
      - ah14 -- ah13 green
links:
  - 比較器.T_440 ユニット1.T_440 blue
  - 比較器.T_880 ユニット1.T_880 green
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/07-assembly-2.svg)

### 図の基板と元の題の違い

部品・番地は元の題の図のまま写した。部品の名前は 4 枚で重ならなかったので、付け替えていない。
変えたのは、基板の外への線の出し方だけだ。

| 基板 | 元の題の図 | 変えた所 | 理由 |
| --- | --- | --- | --- |
| 受信 | 2-2 図2b | 「検波出力 OUT」の箱と、そこへの 2 本 (`t9`・`s2`) を外した。AF は `w9` (同じネット、R5 の上の穴)、GND は `w2` から出す | 基板の外の線を、右の縁へ部品の上を通らずに出すため |
| 入力増幅 | 2-3 図4b | 「電源 5V」と「検波出力」の箱を外した。入力 (`c6`) から黄の線 `c6`〜`c2`〜`x2` を足し、AF は右下の `x2` で受ける。5 V は `v17`、GND は `w4` で受ける。「図5 の基板へ」の箱の名前を「2-3 図5b の基板へ」にした | 元の入力の穴 `c6` は左の縁にあり、受信の基板の AF (右の縁) と反対の側になる。そのままでは線が基板の上を横切るので、空いている下の 2 行目を通して右の縁へ出した |
| 比較器 | 2-3 図6b | T440 を出す穴を `h18` から `x2` に移し、橙の線 `d14`〜`a14`〜`a2`〜`x2` を足した (`b14` と `k2` で被覆線で渡る)。T880 を出す穴を `o18` から `s13` に移し、`o18`〜`o13` の線を外した。縁の字 T440・T880 も外した | ユニット 1 の T440 と T880 の穴は右の縁から出す。比較器の側も右の縁から出さないと、線が基板を横切る |
| ユニット 1 | 2-4 図8b | 上の「他ユニット」の箱から T440 のピンを、下の箱から T880 のピンを外した (線も)。T440 は `aj33`、T880 は `ar1` から出す (どちらも元の線の端) | 元の穴 `ab33`・`af1` から横へ出すと、ほかの線の上を通る |

ネットリストで確かめた結果 (`npm run check -- --verbose`):

| 図 | 併せたネット | つながる端子 |
| --- | --- | --- |
| 図1 | AF | 受信の D1 (カソード)・C4・R5 と、入力増幅の Cin |
| 図1 | VCC | 受信の R1・Rc1・R3・Rc2・電源 5V と、入力増幅の U1 (V+)・Ra・R6 |
| 図1 | GND | 受信の R2・RE1・CE1・R4・RE2・CE2・C4・R5・フェライトバー・バリコン・電源 5V と、入力増幅の U1 (V−)・Rb・Cb・R7・「2-3 図5b の基板へ」の GND |
| 図2 | T_440 | 比較器の U4 (1OUT)・RpuL・RhL と、ユニット 1 の U5 の 1D |
| 図2 | T_880 | 比較器の U4 (2OUT)・RpuH・RhH と、ユニット 1 の U6 の 1D |

## 8 枚の基板の間の配線

題の中の基板どうしの線 (2-3 の 3 枚の間、2-4 の 4 枚の間) も含めて、全部を 1 つの表にした。
「どの穴」は各題の図の番地で、箱で描いた基板は箱のピンの名前を書いた。
5 V と GND は 8 枚と時計で共通にし、電源から各基板へ赤と黒の線を 1 本ずつ引く (下の表では略す)。

| 信号 | 出す基板 (穴) | 受ける基板 (穴) | 線の色 | 図 |
| --- | --- | --- | --- | --- |
| AF (検波出力) | 受信 (`w9`) | 入力増幅 (`x2`) | 黄 | この題の図1 |
| AF (増幅した音声) | 入力増幅 (箱の AF) | 帯域通過フィルタ (`c1` の AF440 と `t1` の AF880 の 2 か所) | 白 | 2-3 の図4b・5b |
| VB (基準電圧) | 入力増幅 (箱の VB) | 帯域通過フィルタ (`h1`) | 緑 | 2-3 の図4b・5b |
| TH (しきい値) | 入力増幅 (箱の TH) | 比較器 (`l18`) | 紫 | 2-3 の図4b・6b |
| P440 | 帯域通過フィルタ (`i18`) | 比較器 (`b18`) | 橙 | 2-3 の図5b・6b |
| P880 | 帯域通過フィルタ (`p18`) | 比較器 (`v18`) | 橙 | 2-3 の図5b・6b |
| T440 | 比較器 (`x2`) | ユニット 1 (`aj33`) | 青 | この題の図2 |
| T880 | 比較器 (`s13`) | ユニット 1 (`ar1`) | 緑 | この題の図2 |
| E440・NE440・E880 | ユニット 1 | ユニット 2 (NE440)・3 (3 つとも)・4 (E880) | 好きな色 | 2-4 の図8b〜11b |
| W・TO | ユニット 2 | ユニット 3 (W・TO)・4 (W) | 好きな色 | 2-4 の図9b〜11b |
| LOADN・EN・CLRN | ユニット 3 | ユニット 4 | 好きな色 | 2-4 の図10b・11b |
| QA・QB・S3 | ユニット 4 | ユニット 3 | 好きな色 | 2-4 の図10b・11b |
| CLK (8 Hz) | 時計 (CD4040B の Q12) | ユニット 1・2・4 | 黄 | 2-4 の図8b・9b・11b、[05-clock.md](05-clock.md) |
| PON (電源投入) | 時計 | ユニット 3 | 好きな色 | 2-4 の図10b、[05-clock.md](05-clock.md) |
| OUT (正時パルス) | ユニット 4 | 時計 | 好きな色 | 2-4 の図11b、[05-clock.md](05-clock.md) |

線の色は 2-4 の流儀に合わせた — 赤は + だけ、黒は GND だけ、黄は CLK。ほかの信号は、たどりやすいように色を変えるだけで、色に意味はない。
基板の間の線は被覆線にし、両端に信号の名前を書いた札 (マスキングテープでよい) を付ける。8 枚の間の線は 20 本を超えるので、札が無いと取り違える。

## 組む順と確かめ方

1 枚ずつ動かしてからつなぐ。動かない基板を 1 枚でもつなぐと、どこが悪いのかを絞れなくなる。

1. **受信の基板を単独で動かす。** [02-radio.md](02-radio.md) の手順で、検波出力 (`w9`) に音声が出ることを AD3 のオシロで確かめる
2. **検出の 3 枚を単独で動かす。** 受信の基板はつながず、[03-detect.md](03-detect.md) の手順で、AD3 の Wavegen から入力増幅の入力 (`c6`) へ 440 Hz と 880 Hz を入れ、T440 と T880 が H になることを確かめる。しきい値 (VR1) はここで合わせる
3. **状態遷移の 4 枚を単独で動かす。** [04-state-machine.md](04-state-machine.md) の「Analog Discovery 3 で試験する」の手順で、AD3 から T440・T880・CLK を入れ、正時パルス OUT が出ることを確かめる
4. **図1 の線をつなぐ。** 電源を切ってから、GND → 5 V → AF の順につなぐ。電源を入れる前に、テスターで 5 V と GND の間が短絡していないことを確かめる。電源を入れたら、ラジオ第 1 放送の音声で T440・T880 がときどき H になることをオシロで見る (音声の中の 440 Hz 付近の成分でも反応する。時報のときだけ並びが揃う)
5. **図2 の線をつなぐ。** 電源を切ってから T440・T880 をつなぐ。CLK と PON は時計の基板からつなぐか、時計ができるまでは AD3 の Wavegen とロジックで代わりに入れる (CLK は 8 Hz の矩形波)
6. **時計とつなぐ。** CLK・PON・OUT を時計 ([05-clock.md](05-clock.md)) とつなぎ、正時の時報で時計の秒が 0 に合うことを確かめる

## 出典

- 自作。回路と各基板の図は [02-radio.md](02-radio.md)・[03-detect.md](03-detect.md)・[04-state-machine.md](04-state-machine.md) から写した
