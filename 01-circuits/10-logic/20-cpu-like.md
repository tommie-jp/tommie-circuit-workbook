---
book: circuits
chapter: 10
id: 10-20
title: 4 ビット CPU のようなもの — カウンタとメモリと命令
tier: 200
source: 自作
board: BB
---

# 10-20 4 ビット CPU のようなもの — カウンタとメモリと命令

4 ビットのカウンタ (74HC163) を**プログラムカウンタ (PC)** にして、その番地を
ダイオードで作った小さな ROM (74HC154 + 1N4148) に送る。ROM が返す 8 ビットの語の
**上位 4 ビットが命令、下位 4 ビットが operand (オペランド、飛び先の番地)** で、
命令は PC 自身の「数える・止まる・0 に戻る・operand の番地へ飛ぶ」を決める。
LED に出る番地が、プログラム `F F F F F B3` の
**0 1 2 3 4 5 の次に 3 へ飛び、3 4 5 3 4 5 … とぐるぐる回る**のを 1 Hz の
ゆっくりしたクロックで目で追う。

**「CPU もどき」と呼ぶのは、演算器 (ALU) もレジスタも無いからだ。**
動くのは番地だけで、CPU の「次にどの番地の命令を取り出すか」を決める部分 (取り出し = フェッチの周期)
だけを部品で組んである。加算器とレジスタを足した CPU は 10-12、プログラムカウンタの
基本は 10-14、フリップフロップで作るメモリは 10-13 で扱う。
作者が Logisim-Evolution で作った同名の模型 (2023 年 3 月) の命令表と番地の動きを、
ブレッドボードで組める部品に置き換えたものだ。

## 全体の構成

```text
 W1 (1 Hz) --CLK--> [ U1  74HC163: PC ] --A0..A3--> [ U2  74HC154 + ダイオード: ROM ] --> 語
                      |    ^                    |                                        |
                      |    |                    +--> LED 4 つ (図3)                       |
                      |    +-- ENT・/CLR・/LD・P0〜P2 <--------------------------------+
                      +--> 番地 (A0〜A3)         (語の上位 = 命令、下位 = operand)
```

1. クロックの立ち上がりで U1 が番地 (A0..A3) を進める
2. U2 が番地に対応する行を L にする (アドレス 5 なら Y5)
3. ダイオードのある列は L、無い列は 10 kΩ のプルアップで H になり、これが**語**になる
4. 語の上位の 3 本 (ENT・/CLR・/LD) と下位の 3 本 (P0〜P2) が U1 に戻り、**次のクロックの立ち上がり**で効く

## 命令の表と解読表

命令の符号は**「1 本だけ 0 にする」形**になっている (`F` = 1111 はどれも 0 にしない)。
0 になっている bit がそのまま制御線になるので、**解読のためのゲート IC は要らない**。
ROM の列 (Op0 = ENT、Op1 = /CLR、Op2 = /LD) を U1 の足へつなぐだけで、
命令の解読が済んでいる。

| 命令 | 符号 (上位 4 bit) | ENT (Op0) | /CLR (Op1) | /LD (Op2) | 次のクロックで |
| --- | --- | --- | --- | --- | --- |
| NEXT | F = 1111 | 1 | 1 | 1 | 番地が 1 増える |
| HALT | E = 1110 | **0** | 1 | 1 | 番地が止まる |
| CLR | D = 1101 | 1 | **0** | 1 | 番地が 0 になる |
| JUMP | B = 1011 | 1 | 1 | **0** | 番地が operand になる |

命令の符号は 8 ビットの語の上位 4 ビットで、この回路はその最上位の 1 ビット (Op3) を使わない。
0 になる bit が 2 本以上の符号でも、U1 は 1 つの動きをする。下の表が解読表 (デコーダの真理値表) の
全部で、Op3 は 0 でも 1 でも同じだ。

| Op2 | Op1 | Op0 | /LD | /CLR | ENT | 次のクロックの動き |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 | 1 | 1 | 1 | 1 | 数える (NEXT、F) |
| 1 | 1 | 0 | 1 | 1 | 0 | 止まる (HALT、E) |
| 1 | 0 | 1 | 1 | 0 | 1 | 0 にする (CLR、D) |
| 1 | 0 | 0 | 1 | 0 | 0 | 0 にする (CLR が ENT に勝つ) |
| 0 | 1 | 1 | 0 | 1 | 1 | operand を読み込む (JUMP、B) |
| 0 | 1 | 0 | 0 | 1 | 0 | operand を読み込む (LD が ENT に勝つ) |
| 0 | 0 | 1 | 0 | 0 | 1 | 0 にする (CLR が LD に勝つ) |
| 0 | 0 | 0 | 0 | 0 | 0 | 0 にする |

優先順位は **/CLR > /LD > ENT > 数える**。74HC163 のデータシートには、クリアは「イネーブルの
レベルに関係なく」次の立ち上がりで 0 にする、ロードも「イネーブルに関係なく」
データを取り込む、と書いてあり、数えるのは ENP と ENT の**両方**が H のときだけだ。
ただし **/CLR と /LD を同時に L にしたときの優先 (CLR が勝つ)** はデータシートの文章に無く、
標準の 74HC163 の動きとして書いた仮定だ (表の最後の 2 行)。この題のプログラムでは使わない。

## プログラム (ROM の中身)

| アドレス | 語 | 命令 | operand | ダイオード (0 の所) |
| --- | --- | --- | --- | --- |
| 0〜4 | `FF` | NEXT | 使わない (F にした) | 無し |
| 5 | `B3` | JUMP 3 | 3 = 0011 | D5 (Op2 = 0)、D6 (operand の bit 2 = 0) |
| 6〜15 | `FF` | NEXT | (この番地には来ない) | 無し |

- **ダイオードのある所が 0、無い所が 1** になる (プルアップ抵抗で H に引かれ、ダイオードが行の L を
  列に伝えて 0 にする)。語は `FF` が「何も書いていない」状態で、これは NEXT だ
- `B3` = 1011 0011。0 の bit は Op2 と、operand の bit 2 と bit 3 だ。operand の bit 3 は
  U1 の PIN 6 (D) を GND につないで**いつも 0**にしたので、ダイオードは Op2 と bit 2 の**2 個で足りる**
- 元の模型の `F1 F2 F3 F4 F5` は、NEXT では使われない operand に 1〜5 が入っているだけだ。
  動きは同じなので、この題では F にした。1〜5 を入れると、ダイオードは全部で 10 個
  (operand の bit 3 も入れる 8 列なら 16 個) に増える
- 命令の bit 3 (Op3) は使わない。**本物の ROM (EEPROM など) に替えるなら、この 2 個のダイオードと
  74HC154 を、8 ビットの ROM 1 個にする**だけで、U1 の周りは同じでよい

## 設計の判断

1. **カウンタは 74HC163 (同期クリア)。** 74HC161 は、ロードは同期 (クロックの立ち上がりで効く) だが
   クリアが**非同期**で、CLR を L にした瞬間に 0 になる。ROM の語で CLR を掛けると、番地が
   変わった直後に自分でクリアされ、その番地が一瞬 (約 0.1 µs) しか出ない。163 なら CLR も JUMP と同じく
   「次の立ち上がり」で効き、**全部の命令が同じタイミング**になる。161 でも動くが、CLR の番地は LED に出ない
2. **メモリはダイオードの ROM。** 74HC154 (4 → 16 のデコーダ、出力が L のとき選ばれた行) の 16 本を
   16 語の行とし、ダイオードと 10 kΩ のプルアップで列を作る。本物の ROM は書き込み器が要る。
   ダイオード ROM は差し替えが「足を 1 本抜き差しする」だけで済み、**プログラムを目で読める**
3. **クロックは Analog Discovery 3 (AD3) の W1** で 0〜5 V・1 Hz の方形波を出す。部品が増えず、
   周波数を変えるのも W1 の設定だけだ。AD3 が無いときは 10-4 の 555 (T ≈ 0.72 秒) の出力 (PIN 3) を
   CLK (U1 の PIN 2) につないでよい
4. **命令の解読にゲートを使わない** (上の表)。符号が「1 本だけ 0」の形だから成り立つ。別の符号なら
   74HC00 や 74HC04 で解読する
5. **表示は A0〜A3 の LED 4 つ。** A3 (アドレス 8 以上) は、このプログラムでは 0 のままで LED は消えたままだ
6. **板は 2 枚に分ける** (実体配線図の節)

## 回路図

回路図は 3 枚に分ける。図1 が PC とクロック、図2 が ROM と命令の線、図3 が表示だ。
**同じ名前の端子 (CLR・P0・P1・P2・ENT・LDn・A0〜A3) は、図をまたいで同じ線**になる。
`n` は負論理 (L で有効) を表し、LDn は /LD のことだ。

```circuit
title: 図1 プログラムカウンタ 74HC163 とクロック
parts:
  U1: dip16 f14
  W1: square e4 g4 l=W1
  GW: ground i4
  CLR: port d10g0
  P0: port e9e0
  P1: port e8i0
  P2: port f7c0
  G6: ground f12g0 r270
  VCC: vcc g10 5V
  G8: ground g11e0 r270
  VCC: vcc c16 5V
  A0: port e18e0
  A1: port e19i0
  A2: port f20c0
  A3: port f21g0
  ENT: port g22
  LDn: port g23e0
wires:
  - U1.1 -| d10g0
  - U1.2 -| e4
  - g4 -- i4
  - U1.3 -| e9e0
  - U1.4 -| e8i0
  - U1.5 -| f7c0
  - U1.6 -| f12g0
  - U1.7 -| g10
  - U1.8 -| g11e0
  - U1.16 -| c16
  - U1.14 -| e18e0
  - U1.13 -| e19i0
  - U1.12 -| f20c0
  - U1.11 -| f21g0
  - U1.10 -| g22
  - U1.9 -| g23e0
notes:
  - text a1 small: "U1: 74HC163 (4 ビット同期カウンタ)"
  - text b1 small: "左の足: PIN 1 /CLR (同期クリア)、2 CLK、3 A (P0)"
  - text c1 small: "PIN 4 B (P1)、5 C (P2)、6 D (P3)、7 ENP、8 GND"
  - text a18 small: "右の足: PIN 14 QA (A0)、13 QB (A1)、12 QC (A2)"
  - text b18 small: "PIN 11 QD (A3)、10 ENT、9 /LOAD、16 VCC、15 RCO (開放)"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/20-cpu-like-1.svg)

- U1 (74HC163) は 16 ピン。左が入力の足 (PIN 1 /CLR、2 CLK、3〜6 が P0〜P3 = A・B・C・D、7 ENP、8 GND)、
  右が出力と制御の足 (PIN 14〜11 が QA〜QD = A0〜A3、10 ENT、9 /LOAD、16 VCC、15 RCO)
- **PIN 7 (ENP) は +5V、PIN 6 (D = P3) は GND にする**。ENP を H にして数える許可を出し、
  P3 を 0 にして飛び先を 0〜7 に限る。PIN 15 (RCO、桁上げの出力) は使わないので開けておく
- W1 は AD3 の波形発生器の出力で、クロック (CLK、PIN 2) をつなぐ。立ち上がりで動く
- CLR・P0〜P2・ENT・LDn は ROM から来る命令の線で、図2 で作る。A0〜A3 は図2 (ROM の入力) と図3 (LED) へ行く

```circuit
title: 図2 メモリ (74HC154 + ダイオード) と命令の線
parts:
  U2: dip24 h28c0
  A0: port f32e0
  A1: port f33i0
  A2: port g34c0
  A3: port g35g0
  VCC: vcc e29 5V
  GE: ground j30
  GU: ground k26
  D6: diode j23 h23
  D5: diode j19 h19
  VCC: vcc c21 5V
  R10: resistor d21 f21 10k
  P2: port m21
  VCC: vcc c17 5V
  R7: resistor d17 f17 10k
  LDn: port m17
  VCC: vcc c13 5V
  R6: resistor d13 f13 10k
  CLR: port m13
  S1: button k11 m11
  GR: ground m11
  VCC: vcc c8 5V
  R5: resistor d8 f8 10k
  ENT: port m8
  VCC: vcc c5 5V
  R9: resistor d5 f5 10k
  P1: port m5
  VCC: vcc c2 5V
  R8: resistor d2 f2 10k
  P0: port m2
wires:
  - U2.24 -| e29
  - U2.23 -| f32e0
  - U2.22 -| f33i0
  - U2.21 -| g34c0
  - U2.20 -| g35g0
  - U2.19 -| h30
  - U2.18 -| h30e0
  - h30 -- j30
  - U2.12 -| k26
  - U2.6 -| h23
  - h23 -- h19
  - j23 -- j21
  - j19 -- j17
  - c21 -- d21
  - f21 -- j21 -- m21
  - c17 -- d17
  - f17 -- j17 -- m17
  - c13 -- d13
  - f13 -- k13 -- m13
  - k13 -- k11
  - c8 -- d8
  - f8 -- m8
  - c5 -- d5
  - f5 -- m5
  - c2 -- d2
  - f2 -- m2
notes:
  - text l19 small blue center: "D5: 命令 JUMP"
  - text l23 small blue center: "D6: P2 を 0 にする"
  - text e33 small blue: "U2: 74HC154 (Y5 は PIN 6)"
  - text f33 small: "PIN 24 は VCC、PIN 12 は GND"
  - text a2 small: "アドレス 5 の行 (Y5) にだけダイオードが 2 つ (D5 と D6)"
  - text b2 small: "Y0 から Y4 と Y6 から Y15 は開放で、その番地はダイオード無しの FF (NEXT)"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/20-cpu-like-2.svg)

- U2 (74HC154) は 24 ピンで、右の PIN 23〜20 が A0〜A3 (入力)、PIN 19・18 が /E2・/E1
  (イネーブル、**GND につなぐと常に有効**)、左の PIN 1〜11 が Y0〜Y10、右の PIN 17〜13 が Y15〜Y11。
  選ばれた行だけが L になる。VCC は PIN 24、GND は PIN 12
- **アドレス 5 のとき L になるのは Y5 (PIN 6) だけ**。その行に D5 と D6 の 2 個を付ける。ダイオードの向きは、
  カソード (線の入った側) が Y5、アノードが列だ。Y5 が L のとき、D5 が /LD の列を、D6 が P2 の列を、
  約 0.6 V (ダイオードの順方向電圧) まで下げる。ほかの行は H なので、ダイオードは逆向きで何もしない
- 列は 6 本。6 本とも 10 kΩ で +5V へ引く。列が H のとき 5V、L のとき約 0.65V
  (Y5 の L 0.1V 以下 + ダイオード 0.55V ほど) で、74HC163 の入力のしきい値 (L は 1.35V 以下、
  H は 3.15V 以上、VCC = 4.5V のとき) から十分に離れている
- **S1 (押しボタン) は CLR の列を GND へ落とす**。CLR は同期クリアなので、S1 を押したまま
  **次のクロックの立ち上がり (最長 1 秒) を待つ**と、番地が 0 になる
- Y0〜Y4、Y6〜Y15 は何もつながずに開けておく (出力の足)。E1・E2 のような入力の足は必ず固定する

```circuit
title: 図3 アドレスの表示 (LED 4 つ)
parts:
  A0: port b2
  R1: resistor b3 b6 820
  D1: led b6 b9 red
  GD1: ground b9
  A1: port d2
  R2: resistor d3 d6 820
  D2: led d6 d9 red
  GD2: ground d9
  A2: port f2
  R3: resistor f3 f6 820
  D3: led f6 f9 red
  GD3: ground f9
  A3: port h2
  R4: resistor h3 h6 820
  D4: led h6 h9 red
  GD4: ground h9
wires:
  - b2 -- b3
  - d2 -- d3
  - f2 -- f3
  - h2 -- h3
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/20-cpu-like-3.svg)

- A0〜A3 (U1 の PIN 14〜11) に、820 Ω と赤の LED を 1 つずつつなぐ。**74HC の出力の保証は 4 mA まで**
  (データシートの ±4 mA)。(5 − 1.9 V) ÷ 820 Ω ≒ **3.8 mA** で、この範囲に収まる
  (LED の順方向電圧 1.9V は仮定)。明るさが足りなければ 680 Ω にしてもよい (約 4.6 mA、保証の外だが
  絶対最大の 25 mA には遠い)
- 1 が点灯、0 が消灯。A0 (LSB) が上、A3 (MSB) が下

## 実体配線図

板は 2 枚に分ける。**板 1 (half)** に U1・クロック・LED・AD3 を、**板 2 (full)** に U2・ダイオード・
プルアップ・S1 を組み、間を 12 本のジャンパ線 (信号 10 本 + 電源 2 本) でつなぐ。
full 1 枚の穴の数には入るが、A0〜A3 の 4 本、LED への 4 本、AD3 の探り 4 本、命令の 6 本が
同じ板の上で重なり、線が追えなくなる。板の順位は half → full → full + half だが、half には収まらず、full 1 枚では図が読めないので、
次の順位 (full を足す) に進めて **half + full** にした。

```breadboard
title: 図4 板 1 — カウンタ (74HC163)・クロック・アドレスの LED
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, DIO0, DIO1, DIO2, DIO3]
  UP:
    type: device
    at: top
    label: 板 2 へ (上)
    pins: [A0, A1, ENT, LDn, A2, A3, +5V, GND]
  DN:
    type: device
    at: bottom
    label: 板 2 へ (下)
    pins: [CLR, P0, P1, P2]
  U1: dip16 @ e10
  R1: resistor e2 g2 820
  D1: led h2(A) h3(K) red
  R2: resistor e6 g6 820
  D2: led h6(A) h7(K) red
  R3: resistor e21 g21 820
  D3: led h21(A) h22(K) red
  R4: resistor e25 g25 820
  D4: led h25(A) h26(K) red
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t30 -- +b30 red
  - UP.+5V -- +t29 red
  - UP.GND -- -t28 black
  - a10 -- +t10 red
  - j15 -- -b15 black
  - j16 -- +b16 red
  - j17 -- -b17 black
  - j3 -- -b3 black
  - j7 -- -b7 black
  - j22 -- -b22 black
  - j26 -- -b26 black
  - AD.W1 -- a9 yellow
  - b9 -- g9 yellow
  - h9 -- h11 yellow
  - c12 -- c2 green
  - d13 -- d6 green
  - a14 -- a21 green
  - b15 -- b25 green
  - AD.DIO0 -- b12 orange
  - AD.DIO1 -- b13 orange
  - AD.DIO2 -- b14 orange
  - AD.DIO3 -- c15 orange
  - UP.A0 -- a2 blue
  - UP.A1 -- a6 blue
  - UP.A2 -- b21 blue
  - UP.A3 -- c25 blue
  - UP.ENT -- c16 purple
  - UP.LDn -- c17 purple
  - DN.CLR -- i10 white
  - DN.P0 -- i12 white
  - DN.P1 -- i13 white
  - DN.P2 -- i14 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/20-cpu-like-1.svg)

```breadboard
title: 図5 板 2 — メモリ (74HC154 とダイオード) と命令の線
board: full
parts:
  UP:
    type: device
    at: top
    label: 板 1 から
    pins: [A0, A1, A2, A3, P2, LDn, ENT, CLR, P1, P0, +5V, GND]
  U2: dip24 @ e3
  D6: diode b19(A) b25(K)
  D5: diode d22(A) d25(K)
  R10: resistor e19 g19 10k
  R7: resistor e22 g22 10k
  R5: resistor e28 g28 10k
  R6: resistor e31 g31 10k
  S1: button @ e33
  R9: resistor e37 g37 10k
  R8: resistor e41 g41 10k
wires:
  - UP.+5V -- +t61 red
  - UP.GND -- -t60 black
  - +t62 -- +b62 red
  - -t1 -- -b1 black
  - a3 -- +t3 red
  - a8 -- -t8 black
  - a9 -- -t9 black
  - j14 -- -b14 black
  - UP.A0 -- a4 blue
  - UP.A1 -- a5 blue
  - UP.A2 -- a6 blue
  - UP.A3 -- a7 blue
  - UP.P2 -- a19 white
  - UP.LDn -- a22 purple
  - UP.ENT -- a28 purple
  - UP.CLR -- a31 white
  - UP.P1 -- a37 white
  - UP.P0 -- a41 white
  - i8 -- i25 orange
  - e25 -- g25 orange
  - j19 -- +b19 red
  - j22 -- +b22 red
  - j28 -- +b28 red
  - j31 -- +b31 red
  - j37 -- +b37 red
  - j41 -- +b41 red
  - j33 -- -b33 black
  - c31 -- c33 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/20-cpu-like-2.svg)

- 電源 (AD3 の V+ 5V) は左上の AD3 から板 1 の上の + レール (1 列) へ、GND は上の − レール (2 列) へ入れる。
  板 1 の + レールと − レールを右の端 (28〜29 列) から板 2 へ渡す。**赤は +5V の線だけ、黒は GND の線だけ**に使った。
  レールが中央で切れている板は、中央を + と − の 1 本ずつのジャンパで橋渡しする
- U1 (74HC163) は板 1 の 10〜17 列、切り欠きが左。PIN 16 (10 列の上) が左上、PIN 1 (10 列の下) が左下。
  PIN 16 を + レールへ、PIN 8 と PIN 6 を − レールへ、PIN 7 を + レールへ落とす (`j15`・`j16`・`j17`)
- AD3 の W1 (黄) は 9 列の上の穴に入れ、溝をまたぐ線 (9 列) と下の線 (h 行) で **PIN 2 (CLK、11 列の下)** へ渡す。
  DIO0〜DIO3 (橙) は A0〜A3 の列 (12〜15 列の上) に当てる
- A0〜A3 の LED は、A0・A1 が左の 2 列と 6 列、A2・A3 が右の 21 列と 25 列。緑の線が U1 の出力の列
  から LED の列へ渡し、抵抗 (820 Ω) は溝をまたいで下の LED (`h` 行) へつながる。LED の足は隣の列どうし、
  長い足 (アノード) が抵抗側で、短い足 (カソード) の列から黒線で下の − レールへ落とす
- **板 2 へ渡す線**: 板 1 の上の箱の A0〜A3・ENT・LDn・+5V・GND と、下の箱の CLR・P0〜P2 を、板 2 の「板 1 から」の
  同じ名前へ 1 本ずつつなぐ (青 = アドレス、紫 = ENT・LDn、白 = CLR・P0〜P2)
- 板 2 の U2 (74HC154、24 ピン) は 3〜14 列。**幅 0.3 インチの品を選ぶ** (下の部品の節)。PIN 24 (3 列の上) と
  PIN 12 (14 列の下) が電源、PIN 19・18 (8・9 列の上) は − レールへ。A0〜A3 は 4〜7 列の上に入る
- **Y5 は PIN 6 (8 列の下)**。橙の線 (i 行) で 25 列の下へ渡し、溝をまたぐ橙の短い線で 25 列の上へ上げる。
  25 列の上の穴が「行 Y5」で、D5・D6 のカソードがここに入る。D5 (アノードは 22 列の上) と
  D6 (アノードは 19 列の上) は、**カソード (線の入った側) を 25 列に向ける**
- 列の抵抗 (10 kΩ) は、上の穴から溝をまたいで下の穴へ挿し、下の穴から + レールへ赤線を立てる。19 列 = P2、
  22 列 = LDn、28 列 = ENT、31 列 = CLR、37 列 = P1、41 列 = P0。S1 は 33〜35 列で、CLR (31 列) の上と
  灰色の線でつなぎ、下の足を − レールへ落とす
- **1 つの穴には 1 本だけ**挿している。線が分かれる所は、同じ列の別の穴から出している

### 回路図との対応

| 線の名前 | 回路図 | 板 1 | 板 2 |
| --- | --- | --- | --- |
| A0 | U1 PIN 14 → U2 PIN 23、R1 | 12 列の上 (U1 PIN 14)、DIO0、R1 は 2 列 | 4 列の上 (U2 PIN 23) |
| A1 | U1 PIN 13 → U2 PIN 22、R2 | 13 列の上 (PIN 13)、DIO1、R2 は 6 列 | 5 列の上 (PIN 22) |
| A2 | U1 PIN 12 → U2 PIN 21、R3 | 14 列の上 (PIN 12)、DIO2、R3 は 21 列 | 6 列の上 (PIN 21) |
| A3 | U1 PIN 11 → U2 PIN 20、R4 | 15 列の上 (PIN 11)、DIO3、R4 は 25 列 | 7 列の上 (PIN 20) |
| CLK | W1 → U1 PIN 2 | 11 列の下 (PIN 2) | — |
| CLR | U1 PIN 1、R6、S1 | 10 列の下 (PIN 1) | 31 列 (R6)、33 列 (S1) |
| P0 / P1 / P2 | U1 PIN 3 / 4 / 5、R8 / R9 / R10 | 12 / 13 / 14 列の下 | 41 / 37 / 19 列 (P2 は D6 も) |
| ENT | U1 PIN 10、R5 | 16 列の上 (PIN 10) | 28 列 (R5) |
| LDn | U1 PIN 9、R7、D5 | 17 列の上 (PIN 9) | 22 列 (R7、D5 のアノード) |
| Y5 | U2 PIN 6、D5・D6 のカソード | — | 8 列の下 (PIN 6) → 25 列 |

`breadboard-fence check` が出したネットリストは、この表のとおりだった (板 1 の A0 は
`AD.DIO0, UP.A0, U1.14, R1.1`、板 2 の Y5 は `U2.6, D6.K, D5.K` など)。回路図の図1〜3 の
ネットリストとも一致する。板では、回路図の 1 つの線 (たとえば A0) が「U1 の出力の列・LED へ行く列・
AD3 の探り・板 2 への線」の複数の穴になり、同じ列 (5 穴の組) の別の穴にまとめてある。

### 板の限度の確認

板の限度の確認: 電圧は 5V (12V 以下)。電流は、LED 4 つが全部点いても 3.8 mA × 4 ≒ 15 mA、
列のプルアップが最大 6 本ぶんで 0.43 mA × 6 ≒ 3 mA、IC の静止電流は数 µA (74HC163 の最大 8 µA、25 ℃) で、
**合計は最大でも約 20 mA** (1 穴 200 mA、板全体 500 mA の限度より十分に小さい)。周波数は**1 Hz**で、
板の上に組む回路は 3 MHz 以下の限度に十分収まる。この回路の上限は、ROM の列が H に戻る時間
(10 kΩ のプルアップ × 板の浮遊容量 30 pF ≒ 0.3 µs) で決まり、
41 ns (U1 の CLK → Q) + 35 ns (U2 の A → Y) + 300 ns + 34 ns (U1 の入力の準備時間) ≒ 0.41 µs、
つまり**約 2 MHz が上限の見積もり** (実測していない。データシートの最大値による計算)。

## 計器の設定

**計器は Analog Discovery 3 (AD3) 1 台**で、電源 (Supplies)・クロック (Wavegen)・番地の観測 (Logic) の
3 役を兼ねる。AD3 の DIO は 3.3V の LVCMOS で **5V まで入れてよく** (入力 H は 2.0V 以上)、
74HC の 5V 出力をそのまま受けられる。AD3 の Scope は 2 ch (アナログ) なので、4 本の番地は Scope でなく
**Logic** で見る。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V にして Master Enable を入れる (板 1・板 2 の + レール) |
| Wavegen | W1: **Square**、Frequency **1 Hz**、Amplitude **2.5 V**、Offset **2.5 V** (0〜5 V)、Symmetry 50 % |
| Logic | DIO0〜DIO3 を A0〜A3 に (バス「Address」にまとめると 0 1 2 3 4 5 3 … と数で読める)。Time base **1 s/div** (10 s)、Mode は Screen か Record (遅い信号向け)、Sample rate 100 Hz。Trigger は DIO0 の立ち上がり |
| 接続 | AD3 の GND を板 1 の − レールへ。DIO3 は 0 のままで動かない |

始め方: Supplies を入れる → S1 を押す → **W1 のクロックの立ち上がりを 1 回待つ**と LED が全部消える (番地 0)
→ S1 を離す。次の立ち上がりから LED が 0001 → 0010 → 0011 … と進む。

## 計器の画面

Logic の画面は、DIO の 0 / 1 を横の線で並べる。図6 は**同じ 3 本 (A0・A1・A2) を Scope 風の画面で
描いた**もので、ch1 = A0、ch2 = A1、ch3 = A2 (0 と 5V の 2 値)。t = 0 は S1 を離したあとの**最初のカウント**
(番地が 1 になる立ち上がり) で、1 s/div の目盛の線がちょうどクロックの立ち上がりにあたる。
A3 (DIO3) は 0 のままなので描いていない。

```scope
title: 図6 アドレスは 0 1 2 3 4 5 3 4 5 3 と進む (A0 A1 A2)
time: 1s/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: "= 5V * (step(t) - step(t - 1s) + step(t - 2s) - step(t - 3s) + step(t - 4s) - step(t - 6s) + step(t - 7s) - step(t - 9s))", range: 2.5V/div, position: 1div}
ch2: {wave: "= 5V * (step(t - 1s) - step(t - 3s) + step(t - 5s) - step(t - 6s) + step(t - 8s) - step(t - 9s))", range: 2.5V/div, position: -1.4div}
ch3: {wave: "= 5V * (step(t - 3s) - step(t - 5s) + step(t - 6s) - step(t - 8s))", range: 2.5V/div, position: -3.9div}
cursors: [4.5s, 5.5s]
measure: [vpp]
notes:
  - text -500ms 5.8V: 0
  - text 500ms 5.8V: 1
  - text 1.5s 5.8V: 2
  - text 2.5s 5.8V: 3
  - text 3.5s 5.8V: 4
  - text 4.5s 5.8V: 5
  - text 5.5s 5.8V: 3
  - text 6.5s 5.8V: 4
  - text 7.5s 5.8V: 5
  - text 8.5s 5.8V: 3
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/20-cpu-like.svg)

## 見るべき値

**クロック 1 Hz** で、番地は 1 秒ごとに次の順に動く。LED は A3 A2 A1 A0 の順に並べた 2 進数だ。

| クロックの数 (S1 を離した後) | 図6 の時刻 | 番地 | A2 A1 A0 (LED) | 読んだ語 | 次のクロックで |
| --- | --- | --- | --- | --- | --- |
| 0 | −1〜0 s | 0 | 0 0 0 | `FF` | +1 |
| 1 | 0〜1 s | 1 | 0 0 1 | `FF` | +1 |
| 2 | 1〜2 s | 2 | 0 1 0 | `FF` | +1 |
| 3 | 2〜3 s | 3 | 0 1 1 | `FF` | +1 |
| 4 | 3〜4 s | 4 | 1 0 0 | `FF` | +1 |
| 5 | 4〜5 s | 5 | 1 0 1 | `B3` (JUMP 3) | **3 を読み込む** |
| 6 | 5〜6 s | **3** | 0 1 1 | `FF` | +1 |
| 7 | 6〜7 s | 4 | 1 0 0 | `FF` | +1 |
| 8 | 7〜8 s | 5 | 1 0 1 | `B3` | 3 を読み込む |
| 9 | 8〜9 s | 3 | 0 1 1 | `FF` | +1 |

- 番地は **0 1 2 3 4 5 3 4 5 3 …**。ループ (3 → 4 → 5 → 3) は **3 クロック = 3 秒**で 1 周する
- 図6 の**カーソル**: X1 = 4.5 秒 (番地 5) は A0 = 5.00 V、A1 = 0 V、A2 = 5.00 V (101)、
  X2 = 5.5 秒 (番地 3) は A0 = 5.00 V、A1 = 5.00 V、A2 = 0 V (011)。**JUMP で 5 の次が 6 でなく 3 になる**
- Measurements の Vpp は 3 本とも 5.00 V (計算値)。実機では 74HC の H は約 4.9V、L は約 0V
- 番地 5 (`B3`) の間は、/LD (U1 の PIN 9) が L になる。Logic の DIO をもう 1 本 (DIO4) U1 の PIN 9 に当てると、
  番地 5 の 1 秒間だけ L の線が見える
- S1 を押している間は、次のクロックの立ち上がりで番地が 0 になる (最長 1 秒待つ)

| 電圧・電流 (計算値) | 値 |
| --- | --- |
| 列の H / L (10 kΩ プルアップ) | 5V / 約 0.65V |
| LED 1 つの電流 | (5 − 1.9) ÷ 820 ≒ 3.8 mA (番地 5 なら 2 つで 7.6 mA) |
| 番地 5 の 2 つの列の電流 | (5 − 0.65) ÷ 10 kΩ ≒ 0.43 mA × 2 |
| 全体 | 最大でも約 20 mA |

### 命令を 1 つ書き換える

ダイオード 1 個の足を差し替えるだけで、番地 5 の語を書き換えられる。**ダイオードの P2 の足 (D6) はそのまま**にする。
書き換えたら S1 で 0 に戻して見る。

| 書き換え | D5 のアノード (板 2 の d 行) | 語 | 番地の動き |
| --- | --- | --- | --- |
| 元 (JUMP) | 22 列 (LDn) | `B3` | 0 1 2 3 4 5 3 4 5 3 … |
| **HALT** | 28 列 (ENT) に差し替え | `E3` (1110 0011) | 0 1 2 3 4 5 で**止まる** (LED は 0101 のまま。S1 で再開) |
| **CLR** | 31 列 (CLR) に差し替え | `D3` (1101 0011) | 0 1 2 3 4 5 0 1 2 3 4 5 … (6 秒で 1 周) |

- HALT では、番地 5 の語の ENT (Op0) が L になり、U1 の ENT が L で数えるのをやめる。番地 5 のまま
  同じ語を読み続けるので、動かない
- CLR では、番地 5 の語の /CLR (Op1) が L になり、U1 は次の立ち上がりで 0 になる (同期クリア)。
  番地 5 も LED に 1 秒間出る。**74HC161 に替える**と、クリアが非同期なので番地 5 は約 0.1 µs しか出ず、
  LED は 0 1 2 3 4 0 1 2 3 4 の 5 周期に見える
- JUMP の飛び先を変えるには、operand の bit を 0 にする (P0・P1 の列にダイオードを足す)。
  たとえば `B2` (飛び先 2 = 0010) は、P0 の列にダイオードを足して bit 0 を 0 にする

## 部品

電源は AD3 の V+ (5 V)。

| 記号 | 部品 | 値・型番 | 数 |
| --- | --- | --- | --- |
| U1 | 4 ビット同期カウンタ (DIP-16) | 74HC163 | 1 |
| U2 | 4 → 16 デコーダ (DIP-24、**幅 0.3 インチ**) | 74HC154 (CD74HC154EN など。`E` 品は幅 0.6 インチでブレッドボードに載らない) | 1 |
| D5、D6 | 小信号ダイオード | 1N4148 | 2 |
| D1〜D4 | LED 5 mm | 赤 | 4 |
| R1〜R4 | 抵抗 (1/4 W) | 820 Ω | 4 |
| R5〜R10 | 抵抗 (1/4 W) | 10 kΩ | 6 |
| S1 | タクトスイッチ | 6 mm | 1 |
| — | ブレッドボード | half 1 枚、full 1 枚 | 2 |
| — | ジャンパ線 | 赤・黒・各色 | 適宜 |

- 74HC163 と 74HC154 は、DIP の手に入る型番を確認して選ぶ (入手性は確認していない)。
  74HC154 は 24 ピンで、TI の CD74HC154 は `E` が幅 0.6 インチ、`EN` が幅 0.3 インチ
- クロックを AD3 の代わりに 555 で作るときは 10-4 の 555 (10 kΩ・47 kΩ・10 µF) を足す

## 出典

自作。74HC163 の足の並びと同期クリア・ロードの動き・入力のしきい値・静止電流・出力の保証 (±4 mA)・
入力の準備時間・伝搬遅延は、TI の SN74HC163 データシート (SCLS298D) による。74HC154 の足の並びと
真理値表・伝搬遅延・幅 0.6 / 0.3 インチの品種は、TI の CD74HC154 データシート (SCHS152D) による。
AD3 の DIO の電圧 (3.3V、5V まで許容、H は 2.0V 以上) と波形発生器の出力範囲は、Digilent の
Analog Discovery 3 の仕様書による。
