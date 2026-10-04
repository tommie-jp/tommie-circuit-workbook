---
book: etc
chapter: 1
id: 1-1
title: 4 ビット CPU のようなもの — カウンタとメモリと命令
tier: 200
source: 自作
board: BB
---

# 1-1 4 ビット CPU のようなもの — カウンタとメモリと命令

4 ビットのカウンタ (74HC163) を**プログラムカウンタ (PC)** にして、その番地を
ダイオードで作った小さな ROM (74HC154 + 1N4148) に送る。ROM が返す 8 ビットの語の
**上位 4 ビットが命令、下位 4 ビットが operand (オペランド、飛び先の番地)** で、
命令は PC 自身の「数える・止まる・0 に戻る・operand の番地へ飛ぶ」を決める。
LED に出る番地が、プログラム `F F F F F B3` の
**0 1 2 3 4 5 の次に 3 へ飛び、3 4 5 3 4 5 … とぐるぐる回る**のを 1 Hz の
ゆっくりしたクロックで目で追う。

**「CPU もどき」と呼ぶのは、演算器 (ALU) もレジスタも無いからだ。**
動くのは番地だけで、CPU の「次にどの番地の命令を取り出すか」を決める部分 (取り出し = フェッチの周期)
だけを部品で組んである。加算器とレジスタを足した CPU は回路の本の 10-12、プログラムカウンタの
基本は同じく 10-14、フリップフロップで作るメモリは 10-13 で扱う。
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
   ダイオード ROM は差し替えが「足を 1 本抜き差しする」だけで済み、**プログラムを目で読める**。
   メモリを DIP スイッチや SRAM に替える作り方は、後の「メモリの作り方を替える」に並べた
3. **クロックは Analog Discovery 3 (AD3) の W1** で 0〜5 V・1 Hz の方形波を出す。部品が増えず、
   周波数を変えるのも W1 の設定だけだ。AD3 が無いときは [回路の本の 10-4](../../01-circuits/10-logic/04-binary-counter.md) の 555 (T ≈ 0.72 秒) の出力 (PIN 3) を
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
  U1: ic g14 74HC163
  P0: port e6f0
  P1: port f7
  P2: port f8f0
  GD: ground g10 r270
  VE: vcc g3f0 5V
  ENT: port h6
  W1: square h4f0 i4f0 l=W1
  GW: ground k4f0
  A0: port f20
  A1: port f21f0
  A2: port g20
  A3: port g21f0
  VCC: vcc c13f5 5V
  CLR: port b14
  LDn: port c15
  G1: ground k14
wires:
  - U1.A -| e6f0
  - U1.B -| f7
  - U1.C -| f8f0
  - U1.D -| g10
  - U1.ENP -| g3f0
  - U1.ENT -| h6
  - U1.CLK -| h4f0
  - i4f0 -- k4f0
  - U1.QA -| f20
  - U1.QB -| f21f0
  - U1.QC -| g20
  - U1.QD -| g21f0
  - U1.VCC |- c13f5
  - U1.CLR |- b14
  - U1.LOAD |- c15
  - U1.GND |- k14
notes:
  - text i18 small: "RCO (PIN 15) は開放"
  - text j4 small: "W1: AD3 の波形発生器"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-1.svg)

- U1 (74HC163) は**働きで足を並べた記号**で描いた。足の番号は名前の隣に添えてある
  (`03 A` は PIN 3 が A)。実物の DIP-16 の足の順とは違うので、組むときは PIN の番号で探す。
  左が入力: PIN 3〜6 が A〜D (P0〜P3、プリセットの入力)、PIN 7 が ENP、PIN 10 が ENT、PIN 2 が CLK。
  右が出力: PIN 14〜11 が QA〜QD (下の桁から A0〜A3)、PIN 15 が RCO (桁上げ)。
  上が電源と制御: PIN 16 が VCC、PIN 1 が /CLR (同期クリア)、PIN 9 が /LOAD。下が PIN 8 (GND)
- **PIN 7 (ENP) は +5V、PIN 6 (D = P3) は GND にする**。ENP を H にして数える許可を出し、
  P3 を 0 にして飛び先を 0〜7 に限る。PIN 15 (RCO、桁上げの出力) は使わないので開けておく
- W1 は AD3 の波形発生器の出力で、クロック (CLK、PIN 2) をつなぐ。立ち上がりで動く
- CLR・P0〜P2・ENT・LDn は ROM から来る命令の線で、図2 で作る。QA〜QD (= A0〜A3) は図2 (ROM の入力) と図3 (LED) へ行く。
  以下、番地の線は A0〜A3、カウンタの出力の足は QA〜QD と書く

```circuit
title: 図2 メモリ (74HC154 + ダイオード) と命令の線
parts:
  U2: ic h14 74HC154
  A0: port g6f0
  A1: port h7
  A2: port h6f0
  A3: port i7
  VCC: vcc b14f5 5V
  GU: ground n14
  D5: diode g24 e24
  D6: diode g28 e28
  VCC: vcc d22 5V
  R7: resistor e22 g22 10k
  LDn: port m22
  VCC: vcc d26 5V
  R10: resistor e26 g26 10k
  P2: port m26
  VCC: vcc d30 5V
  R5: resistor e30 g30 10k
  ENT: port m30
  VCC: vcc d32 5V
  R6: resistor e32 g32 10k
  CLR: port m32
  S1: button i33 k33
  GR: ground k33
  VCC: vcc d34 5V
  R8: resistor e34 g34 10k
  P0: port m34
  VCC: vcc d36 5V
  R9: resistor e36 g36 10k
  P1: port m36
wires:
  - U2.A0 -| g6f0
  - U2.A1 -| h7
  - U2.A2 -| h6f0
  - U2.A3 -| i7
  - U2.VCC |- b14f5
  - U2.GND |- n14
  - U2.E1 |- n14
  - U2.E2 |- n14
  - U2.Y5 -| g18
  - g18 -- b18 -- b28
  - b24 -- e24
  - b28 -- e28
  - g24 -- g22
  - g28 -- g26
  - d22 -- e22
  - g22 -- m22
  - d26 -- e26
  - g26 -- m26
  - d30 -- e30
  - g30 -- m30
  - d32 -- e32
  - g32 -- i32 -- m32
  - i32 -- i33
  - d34 -- e34
  - g34 -- m34
  - d36 -- e36
  - g36 -- m36
notes:
  - text a20 small: "Y5 (PIN 6) だけが、アドレス 5 のとき L になる"
  - text k24 small blue center: "D5: 命令 JUMP"
  - text k28 small blue center: "D6: P2 を 0 にする"
  - text n17 small: "E1・E2 (PIN 18・19) は GND につなぐと常に有効"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-2.svg)

- U2 (74HC154) も働きで足を並べた記号で描いた。左が入力の A0〜A3 (PIN 23〜20)、
  右が出力の Y0〜Y15 (PIN 1〜11 が Y0〜Y10、PIN 13〜17 が Y11〜Y15)、下が GND (PIN 12) と
  E1・E2 (PIN 18・19、イネーブル、**GND につなぐと常に有効**)、上が VCC (PIN 24)。
  選ばれた行だけが L になる
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-3.svg)

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
    pins: [V+, GND, W1, DIO0, DIO1, DIO2, DIO3, DIO4]
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
  U1: dip16 @ e10 74HC163
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
  - AD.DIO4 -- i11 orange
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/01-cpu-like-1.svg)

```breadboard
title: 図5 板 2 — メモリ (74HC154 とダイオード) と命令の線
board: full
parts:
  UP:
    type: device
    at: top
    label: 板 1 から
    pins: [A0, A1, A2, A3, P2, LDn, ENT, CLR, P1, P0, +5V, GND]
  U2: dip24 @ e3 74HC154
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/01-cpu-like-2.svg)

- 電源 (AD3 の V+ 5V) は左上の AD3 から板 1 の上の + レール (1 列) へ、GND は上の − レール (2 列) へ入れる。
  板 1 の + レールと − レールを右の端 (28〜29 列) から板 2 へ渡す。**赤は +5V の線だけ、黒は GND の線だけ**に使った。
  レールが中央で切れている板は、中央を + と − の 1 本ずつのジャンパで橋渡しする
- U1 (74HC163) は板 1 の 10〜17 列、切り欠きが左。PIN 16 (10 列の上) が左上、PIN 1 (10 列の下) が左下。
  PIN 16 を + レールへ、PIN 8 と PIN 6 を − レールへ、PIN 7 を + レールへ落とす (`j15`・`j16`・`j17`)
- AD3 の W1 (黄) は 9 列の上の穴に入れ、溝をまたぐ線 (9 列) と下の線 (h 行) で **PIN 2 (CLK、11 列の下)** へ渡す。
  DIO0〜DIO3 (橙) は A0〜A3 の列 (12〜15 列の上) に、**DIO4 (橙) は CLK の列 (11 列の下の `i11`) に当てる**
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
| A0 | U1 QA (PIN 14) → U2 A0 (PIN 23)、R1 | 12 列の上 (U1 PIN 14)、DIO0、R1 は 2 列 | 4 列の上 (U2 PIN 23) |
| A1 | U1 QB (PIN 13) → U2 A1 (PIN 22)、R2 | 13 列の上 (PIN 13)、DIO1、R2 は 6 列 | 5 列の上 (PIN 22) |
| A2 | U1 QC (PIN 12) → U2 A2 (PIN 21)、R3 | 14 列の上 (PIN 12)、DIO2、R3 は 21 列 | 6 列の上 (PIN 21) |
| A3 | U1 QD (PIN 11) → U2 A3 (PIN 20)、R4 | 15 列の上 (PIN 11)、DIO3、R4 は 25 列 | 7 列の上 (PIN 20) |
| CLK | W1 → U1 CLK (PIN 2) | 11 列の下 (PIN 2) | — |
| CLR | U1 CLR (PIN 1)、R6、S1 | 10 列の下 (PIN 1) | 31 列 (R6)、33 列 (S1) |
| P0 / P1 / P2 | U1 A / B / C (PIN 3 / 4 / 5)、R8 / R9 / R10 | 12 / 13 / 14 列の下 | 41 / 37 / 19 列 (P2 は D6 も) |
| ENT | U1 ENT (PIN 10)、R5 | 16 列の上 (PIN 10) | 28 列 (R5) |
| LDn | U1 LOAD (PIN 9)、R7、D5 | 17 列の上 (PIN 9) | 22 列 (R7、D5 のアノード) |
| Y5 | U2 Y5 (PIN 6)、D5・D6 のカソード | — | 8 列の下 (PIN 6) → 25 列 |

`breadboard-fence check` が出したネットリストは、この表のとおりだった (板 1 の A0 は
`AD.DIO0, UP.A0, U1.QA, R1.1`、板 2 の Y5 は `U2.Y5, D6.K, D5.K` など。足に名前を付けた型番で描いたので、
ネットリストも足の名前で出る)。回路図の図1〜3 の
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
74HC の 5V 出力をそのまま受けられる。AD3 の Scope は 2 ch (アナログ) で、番地の 4 本とクロックの合計 5 本は
見られないので、**Logic (ロジックアナライザ、DIO 16 本)** で見る。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V にして Master Enable を入れる (板 1・板 2 の + レール) |
| Wavegen | W1: **Square**、Frequency **1 Hz**、Amplitude **2.5 V**、Offset **2.5 V** (0〜5 V)、Symmetry 50 % |
| Logic | **DIO0〜DIO3 = A0〜A3、DIO4 = CLK** (図4 の配線)。DIO0〜DIO3 を束ねたバス「Address」を 16 進で表示すると 0 1 2 3 4 5 3 … と数で読める。Time base **1 s/div** (窓 10 s)、Mode は Screen か Record (遅い信号向け)、Sample rate 1 kHz 以上。Trigger は **DIO4 (CLK) の立ち上がり**。WaveForms の項目の名前は確認していない (機種の説明どおりに選ぶ) |
| 接続 | AD3 の GND を板 1 の − レールへ。DIO3 は 0 のままで動かない |

始め方: Supplies を入れる → S1 を押す → **W1 のクロックの立ち上がりを 1 回待つ**と LED が全部消える (番地 0)
→ S1 を離す。次の立ち上がりから LED が 0001 → 0010 → 0011 … と進む。
図6 の t = 0 は、S1 を押したまま番地が 0 になる立ち上がりに合わせてある。

## 計器の画面

Logic の画面は、DIO の 0 / 1 を横の線で並べる。図6 は**クロック (CLK) と番地の 4 本 (A0〜A3)、それを束ねたバス Address (16 進)**
の見えるはずの画面だ。t = 0 は S1 を押したまま番地が 0 になる立ち上がりで、CLK の立ち上がりごと (1 s ごと) に
番地が変わる。カーソルは変わり目を避けて **X1 = 5.25 s、X2 = 6.25 s** に置いた (どちらも CLK は H で、番地は変わり目の途中でない)。
A3 は 0 のままだ。

```logic
title: 図6 アドレスは 1 s ごとに 0 1 2 3 4 5 3 4 5 3 と進む
device: ad3
time: 1s/div
sample: 1kHz
signals:
  CLK: dio4 clock 1Hz
  A:   dio0..dio3 counter on CLK rising sequence 0 1 2 3 4 5 3 4 5 3
buses:
  Address: A3..A0 hex
cursors: [5.25s, 6.25s]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/logic/01-cpu-like.svg)

## 見るべき値

**クロック 1 Hz** で、番地は 1 秒ごとに次の順に動く。t = 0 は番地が 0 になる立ち上がり。LED は A3 A2 A1 A0 の順に並べた 2 進数だ。

| クロックの数 | 図6 の時刻 | 番地 | A2 A1 A0 (LED) | 読んだ語 | 次のクロックで |
| --- | --- | --- | --- | --- | --- |
| 0 | 0〜1 s | 0 | 0 0 0 | `FF` | +1 |
| 1 | 1〜2 s | 1 | 0 0 1 | `FF` | +1 |
| 2 | 2〜3 s | 2 | 0 1 0 | `FF` | +1 |
| 3 | 3〜4 s | 3 | 0 1 1 | `FF` | +1 |
| 4 | 4〜5 s | 4 | 1 0 0 | `FF` | +1 |
| 5 | 5〜6 s | 5 | 1 0 1 | `B3` (JUMP 3) | **3 を読み込む** |
| 6 | 6〜7 s | **3** | 0 1 1 | `FF` | +1 |
| 7 | 7〜8 s | 4 | 1 0 0 | `FF` | +1 |
| 8 | 8〜9 s | 5 | 1 0 1 | `B3` | 3 を読み込む |
| 9 | 9〜10 s | 3 | 0 1 1 | `FF` | +1 |

- 番地は **0 1 2 3 4 5 3 4 5 3 …**。ループ (3 → 4 → 5 → 3) は **3 クロック = 3 秒**で 1 周する
- 図6 の**カーソル**: X1 = 5.25 秒は Address = `0x5` (A2 = 1、A1 = 0、A0 = 1 の 101)、
  X2 = 6.25 秒は Address = `0x3` (A2 = 0、A1 = 1、A0 = 1 の 011)。ΔX = 1.000 秒 (1/ΔX = 1 Hz = クロックの周波数)。
  **JUMP で 5 の次が 6 でなく 3 になる**。どちらのカーソルも CLK は H (1) で、変わり目にかからない
- 図6 の Address の並びは `0x0@0 s 0x1@1 s 0x2@2 s 0x3@3 s 0x4@4 s 0x5@5 s 0x3@6 s 0x4@7 s 0x5@8 s 0x3@9 s`。
  A0・A1・A2 の変わり目は 7・5・4 回、A3 は 0 回 (`logic-fence check` の読み値)。実機では 74HC の H は約 4.9V、L は約 0V だが、
  Logic は 0 / 1 で読む
- 番地 5 (`B3`) の間は、/LD (U1 の PIN 9) が L になる。Logic の DIO をもう 1 本 (DIO5) U1 の PIN 9 に当てると、
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

## メモリの作り方を替える

ここまでのメモリはダイオードの ROM だった。番地 5 の語を変えるには、ダイオードの足を差し替える。
ここでは、同じ回路の**メモリの部分だけ**を 2 とおりに替える。カウンタ・LED・クロック (板 1、図1・図3・図4) は
どちらも図のままでよく、メモリから板 1 へ戻る線 (ENT・CLR・LDn・P0〜P2) と、板 1 から来る番地 (A0〜A3) の
名前も変わらない。

| | ダイオードの ROM (図2・図5) | DIP スイッチ (図7・図8) | SRAM (図9〜12) |
| --- | --- | --- | --- |
| 語の書き換え | ダイオードの足を差し替える | スイッチを倒す | スイッチで語を作り、ボタンで書き込む |
| 書き換えられる番地 | ダイオードを足せば全部 | **番地 5 だけ** (行を足せば増える) | 16 番地すべて |
| 電源を切ると | 残る | 残る (スイッチの位置) | **消える (書き直す)** |
| 板 | half + full | half + full | half + full + half |
| 主な部品 | 74HC154・1N4148 | 74HC154・4 連 DIP スイッチ 2 個 | AS6C62256・74HC245 |
| 電流 (最大の見積り) | 約 20 mA | 約 20 mA | 約 70 mA |
| クロックの上限 (計算値) | 約 2 MHz | 約 2 MHz | 約 2 MHz |

どれも 5V で、板 1 は図4 の half 1 枚だ。メモリの板は、ダイオードと DIP スイッチが full 1 枚 (板 2)、SRAM が full 1 枚 (板 2) と half 1 枚 (板 3) になる。電流は 1 穴 200 mA・板全体 500 mA の限度より十分小さい。
周波数は 1 Hz で使い、板の上に組む回路の 3 MHz の限度に収まる (上限の見積りは各節に書いた)。

### DIP スイッチのメモリ

ダイオード D5・D6 を、**4 連の DIP スイッチ**に替える。スイッチを倒すだけで、番地 5 の語を JUMP・HALT・CLR や
別の飛び先に書き換えられる。ハンダ付けも足の抜き差しも要らない。

```circuit
title: 図7 DIP スイッチのメモリ (アドレス 5 の語だけを書き換えられる)
parts:
  U2: ic l14 74HC154
  A0: port k6f0
  A1: port l7
  A2: port l6f0
  A3: port m7
  VCC: vcc f14f5 5V
  GU: ground r14
  VCC: vcc d22 5V
  R5: resistor e22 g22 10k
  SW1a: switch h22 j22
  ENT: port g24
  VCC: vcc d25 5V
  R6: resistor e25 g25 10k
  SW1c: switch h25 j25
  LDn: port g27
  VCC: vcc d28 5V
  R7: resistor e28 g28 10k
  SW1d: switch h28 j28
  P0: port g30
  VCC: vcc d31 5V
  R8: resistor e31 g31 10k
  SW2a: switch h31 j31
  P1: port g33
  VCC: vcc d34 5V
  R9: resistor e34 g34 10k
  SW2b: switch h34 j34
  P2: port g36
  VCC: vcc d37 5V
  R10: resistor e37 g37 10k
  SW1b: switch h37 j37
  CLR: port g43
  S1: button h39 j39
  GS: ground j39
wires:
  - U2.A0 -| k6f0
  - U2.A1 -| l7
  - U2.A2 -| l6f0
  - U2.A3 -| m7
  - U2.VCC |- f14f5
  - U2.GND |- r14
  - U2.E1 |- r14
  - U2.E2 |- r14
  - U2.Y5 -| k18
  - k18 -- k37
  - d22 -- e22
  - g22 -- h22
  - j22 -- k22
  - g22 -- g24
  - d25 -- e25
  - g25 -- h25
  - j25 -- k25
  - g25 -- g27
  - d28 -- e28
  - g28 -- h28
  - j28 -- k28
  - g28 -- g30
  - d31 -- e31
  - g31 -- h31
  - j31 -- k31
  - g31 -- g33
  - d34 -- e34
  - g34 -- h34
  - j34 -- k34
  - g34 -- g36
  - d37 -- e37
  - g37 -- h37
  - j37 -- k37
  - g37 -- g39 -- g43
  - g39 -- h39
notes:
  - text n22 small: "SW1 と SW2 は 4 連 DIP スイッチ。SW1 の 1 から 4 番と SW2 の 1 と 2 番を使う"
  - text o22 small: "スイッチを ON (閉) にした列は、アドレス 5 のとき L (0) になる"
  - text p22 small: "OFF (開) の列は R で H (1) のまま"
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-4.svg)

- 74HC154 の Y5 (PIN 6、アドレス 5 のとき L になる行) から、6 つのスイッチを通して 6 本の列につなぐ。
  列は図2 と同じ 10 kΩ のプルアップで H に引いてある。**スイッチを ON (閉) にした列だけが、アドレス 5 のとき L (0)** になる。
  OFF (開) の列は H (1) のままで、番地 5 の語は `FF` からスイッチの分だけ 0 になる
- スイッチは DIP スイッチ SW1 (4 連) と SW2 (4 連)。SW1 の 1〜4 番が ENT・CLR・LDn・P0、SW2 の 1・2 番が P1・P2 で、
  SW2 の 3・4 番は使わない (図の ID は `SW1a` = SW1 の 1 番、`SW1b` = 2 番、…)。1 つの語は上位の命令の 3 bit (ENT・CLR・LDn) と、
  下位の operand の 3 bit (P0〜P2) だ
- **ダイオードを使わない理由**: 行が Y5 の 1 本だけなら、Y5 が H (番地 5 でない) のとき、閉じたスイッチは
  H の Y5 を、H の列につなぐだけで何も起きない。Y5 が L のとき、閉じたスイッチが列を L にする。
  L の高さは Y5 の出力の L (74HC154 のデータシートで 4 mA を流して 0.26 V 以下) で、ダイオード ROM の約 0.65 V より低い。
  Y5 の出力が流す電流は、6 本の列がすべて L でも 0.5 mA × 6 = 3 mA で、保証の 4 mA に収まる
- **行を増やすとダイオードが要る理由**: 同じ列に 2 本の行のスイッチをつなぐと、選ばれた行 (L) と選ばれていない行 (H)
  が、閉じた 2 つのスイッチと列を通ってつながり、H の出力と L の出力が押し合う。データシートの出力の保証
  (H は 4 mA で 3.98 V 以上、L は 4 mA で 0.26 V 以下) から出力の抵抗をそれぞれ約 130 Ω・約 65 Ω と見積もると、
  4.5 V ÷ 195 Ω ≒ 23 mA (計算値) になる。実際の出力はもっと低抵抗なので、1 出力あたりの絶対最大 ±25 mA を
  超えうる。**行を増やすなら、スイッチごとに 1N4148 を直列に入れる** (カソードを行の側、アノードを列の側。
  ダイオード ROM と同じ向き)。H の行は列を持ち上げられなくなり、L の行だけが列を下げる。
  番地 1 つにつき、4 連スイッチ 2 個とダイオード 6 個が要る

書き換えの表 (ON にするスイッチだけを書く。ほかは OFF):

| 命令 | 語 | ON にするスイッチ | 番地の動き |
| --- | --- | --- | --- |
| NEXT | `FF` | (全部 OFF) | 番地 5 も +1 (0 1 2 3 4 5 6 7 … 15 0 … と進む) |
| **JUMP 3** (元) | `B3` | SW1 の 3 (LDn)、SW2 の 2 (P2) | 0 1 2 3 4 5 3 4 5 3 … |
| JUMP 7 | `B7` | SW1 の 3 (LDn) | 0 1 2 3 4 5 7 8 9 … 15 0 … (7 の次は 8 へ進み、15 の次は 0 に戻る) |
| JUMP 0 | `B0` | SW1 の 3 (LDn)、SW1 の 4 (P0)、SW2 の 1 (P1)、SW2 の 2 (P2) | 0 1 2 3 4 5 0 1 2 … (6 秒で 1 周) |
| HALT | `E3` | SW1 の 1 (ENT)、SW2 の 2 (P2) | 0 1 2 3 4 5 で止まる |
| CLR | `D3` | SW1 の 2 (CLR)、SW2 の 2 (P2) | 0 1 2 3 4 5 0 1 2 3 4 5 … |

- 飛び先は 0〜7 に限る (U1 の PIN 6 の D = P3 を GND につないだため)。ON にしたスイッチの bit が 0 になる。
  SW2 の 3・4 番は空きだ
- 番地 5 以外の語は `FF` (NEXT) のままだ。ほかの番地の語も書き換えたいときは、上の「行を増やす」の作りにする

**実体配線図 (図8)**: 板 1 は図4 のまま、板 2 の 74HC154・DIP スイッチ 2 個・集合抵抗を組む。板は half + full で、
ダイオード版と同じだ。4 連 DIP スイッチ (DIP-8) は、n 番のスイッチが PIN n と PIN 9−n をつなぐ。
この 2 本の足は溝をはさんで**同じ列**に来るので、スイッチ 1 個が「溝の上の 5 穴の組」と「溝の下の 5 穴の組」を
つなぐ。上の組を**列の線** (プルアップと UP からの線)、下の組を **Y5** にした。

```breadboard
title: 図8 板 2 — DIP スイッチのメモリ (74HC154 と 4 連 DIP スイッチ 2 個)
board: full
parts:
  UP:
    type: device
    at: top
    label: 板 1 から
    pins: [A0, A1, A2, A3, ENT, CLR, LDn, P0, P1, P2, +5V, GND]
  U2: dip24 @ e3 74HC154
  SW1: dip8 @ e21 l=DIP1
  SW2: dip8 @ e25 l=DIP2
  RN1: sip9 @ b20 l=10k-8
  S1: button @ e31
wires:
  - UP.+5V -- +t61 red
  - UP.GND -- -t60 black
  - -t1 -- -b1 black
  - a3 -- +t3 red
  - a8 -- -t8 black
  - a9 -- -t9 black
  - j14 -- -b14 black
  - UP.A0 -- a4 blue
  - UP.A1 -- a5 blue
  - UP.A2 -- a6 blue
  - UP.A3 -- a7 blue
  - UP.ENT -- a21 purple
  - UP.CLR -- a22 white
  - UP.LDn -- a23 purple
  - UP.P0 -- a24 white
  - UP.P1 -- a25 white
  - UP.P2 -- a26 white
  - a20 -- +t20 red
  - i8 -- i21 orange
  - g21 -- g22 orange
  - h22 -- h23 orange
  - g23 -- g24 orange
  - h24 -- h25 orange
  - g25 -- g26 orange
  - d22 -- d31 gray
  - j31 -- -b31 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/01-cpu-like-3.svg)

- U2 (74HC154) は図5 と同じ 3〜14 列 (幅 0.3 インチの品)。Y5 は PIN 6 (8 列の下) で、橙の線 (`i8` → `i21`) でスイッチの下の組へ渡す
- SW1 は 21〜24 列、SW2 は 25〜28 列 (切り欠きが左)。n 番のスイッチが n 番目の列の上下をつなぐ。
  下の組は、橙の短い線 5 本 (`g21`〜`g26` と `h22`〜`h25` の間) でつないで、6 列 (SW1 の 4 列と SW2 の 2 列) すべてに Y5 を届ける
- 10 kΩ は **集合抵抗 (SIL、9 ピン、共通の足が +5V)** を 1 個使う。共通の足 (1 番) を 20 列に、残りの 8 本を 21〜28 列の上の組 (b 行) に挿し、
  共通の足の列から赤線で + レールへ (`a20` → `+t20`)。1 つの穴に 1 本ずつ入る。個別の抵抗 6 本でも同じだが、
  スイッチと同じ列に抵抗を挿す穴が無く、集合抵抗のほうが配線が短い
- UP からの線は、ENT・CLR・LDn・P0・P1・P2 を 21〜26 列の上の穴 (`a21`〜`a26`) へ。S1 は図5 と同じ働きで、
  CLR の列 (22 列) の穴 `d22` から灰色の線で 31 列の S1 の上の足へ、下の足は − レールへ

`breadboard-fence check` が出したネットリストは、Y5 が `U2.Y5, SW1.1, SW1.2, SW1.3, SW1.4, SW2.1, SW2.2`、
CLR の列が `UP.CLR, SW1.7, RN1.3, S1.1a, S1.1b` などで、回路図の図7 と一致した。スイッチの 1〜4 番の足が Y5 の側 (下の組)、
5〜8 番の足が列の側 (上の組) になる。

**板の限度の確認 (DIP スイッチ版)**: 電圧は 5V。電流は LED 4 つが全部点いて 3.8 mA × 4 ≒ 15 mA、列 6 本が全部 L で 0.5 mA × 6 = 3 mA、
IC の静止電流は数 µA で、**合計は最大でも約 20 mA** (ダイオード版と同じ)。クロックの上限も同じで、列が H に戻る時間
(10 kΩ × 板の浮遊容量 30 pF ≒ 0.3 µs) で決まり、約 2 MHz の見積もりだ (データシートの最大値による計算で、実測していない)。
DIP スイッチの接点の抵抗と定格は品による。この回路は 0.5 mA・5V しか流さないので、一般の DIP スイッチの範囲に収まるはずだが、
選ぶ品の定格は確認していない。

### SRAM のメモリ

74HC154 とダイオードを、**SRAM (AS6C62256-55PCN、32K × 8 ビット)** に替える。カウンタの番地 A0〜A3 を SRAM の番地に入れ、
出てきた 8 ビットの語のうち 6 ビット (DQ0〜DQ5 = ENT・CLR・LDn・P0・P1・P2) を、ROM と同じように板 1 へ返す。
語は**手で書き込む**。番地の上位 (A4〜A14) は GND につなぎ、16 語だけを使う。

**動作は 2 つ。** S3 (スライドスイッチ) で切り替える。

| 動作 | S3 | SRAM | 74HC245 (U4) | できること |
| --- | --- | --- | --- | --- |
| RUN (走らせる) | RUN | 出力が有効 (OEn = L) | 止まっている (Yn = H) | 番地に対応する語が DQ に出て、カウンタを動かす |
| PROG (書き込む) | PROG | 出力が止まる (OEn = H) | 動く (Yn = L) | スイッチの 8 ビットが DQ に出る。WRITE (S2) を押すと、その番地に書き込まれる |

回路図は 4 枚に分ける。同じ名前の端子 (A0〜A3・ENT・LDn・P0〜P2・DQ1・DQ6・DQ7・SD0〜SD7・OEn・WEn・Yn・CLR) は、図をまたいで同じ線だ。

```circuit
title: 図9 SRAM (AS6C62256) とデータ線
parts:
  U3: ic j14 62256
  A0: port f6f0
  A1: port g7
  A2: port g8f0
  A3: port h9
  GA: ground o10
  VCC: vcc c20 5V
  R11: resistor e20 g20 10k
  ENT: port h22f0
  VCC: vcc c23 5V
  R12: resistor e23 g23 10k
  DQ1: port i25
  VCC: vcc c26 5V
  R13: resistor e26 g26 10k
  LDn: port i28f0
  VCC: vcc c29 5V
  R14: resistor e29 g29 10k
  P0: port j31
  VCC: vcc c32 5V
  R15: resistor e32 g32 10k
  P1: port j34f0
  VCC: vcc c35 5V
  R16: resistor e35 g35 10k
  P2: port k37
  VCC: vcc c38 5V
  R17: resistor e38 g38 10k
  DQ6: port k40f0
  VCC: vcc c41 5V
  R18: resistor e41 g41 10k
  DQ7: port l43
  VCC: vcc d14f5 5V
  GV: ground r14
  OEn: port s17
  WEn: port r18
wires:
  - U3.A0 -| f6f0
  - U3.A1 -| g7
  - U3.A2 -| g8f0
  - U3.A3 -| h9
  - U3.A4 -| o10
  - U3.A5 -| o10
  - U3.A6 -| o10
  - U3.A7 -| o10
  - U3.A8 -| o10
  - U3.A9 -| o10
  - U3.A10 -| o10
  - U3.A11 -| o10
  - U3.A12 -| o10
  - U3.A13 -| o10
  - U3.A14 -| o10
  - U3.DQ0 -| h20f0
  - c20 -- e20
  - g20 -- h20f0
  - h20f0 -- h22f0
  - U3.DQ1 -| i23
  - c23 -- e23
  - g23 -- i23
  - i23 -- i25
  - U3.DQ2 -| i26f0
  - c26 -- e26
  - g26 -- i26f0
  - i26f0 -- i28f0
  - U3.DQ3 -| j29
  - c29 -- e29
  - g29 -- j29
  - j29 -- j31
  - U3.DQ4 -| j32f0
  - c32 -- e32
  - g32 -- j32f0
  - j32f0 -- j34f0
  - U3.DQ5 -| k35
  - c35 -- e35
  - g35 -- k35
  - k35 -- k37
  - U3.DQ6 -| k38f0
  - c38 -- e38
  - g38 -- k38f0
  - k38f0 -- k40f0
  - U3.DQ7 -| l41
  - c41 -- e41
  - g41 -- l41
  - l41 -- l43
  - U3.VCC |- d14f5
  - U3.VSS |- r14
  - U3.CE |- r14
  - U3.OE |- s17
  - U3.WE |- r18
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-5.svg)

- **図9 は SRAM 本体**。U3 (AS6C62256) は 28 ピン。左が番地 (PIN 10〜7 が A0〜A3)、右がデータ (DQ0〜DQ7)、
  下が VSS (PIN 14)・CE (PIN 20)・OE (PIN 22)・WE (PIN 27)、上が VCC (PIN 28)。番地の A4〜A14 は GND に、CE も GND に固定した
  (常に選ばれた状態)。入力の足は開けない
- DQ の 8 本は、それぞれ 10 kΩ で H に引いた。SRAM の出力の H は 1 mA を流して 2.4 V 以上までしか保証されず、74HC163 の入力の H の
  しきい値 (3.15V 以上) に届かないことがある。プルアップが出力を 5V まで持ち上げる。SRAM の出力の L は 2 mA で 0.4 V 以下で、
  プルアップの 0.5 mA には十分だ
- OEn は SRAM の OE (PIN 22)、WEn は WE (PIN 27) につなぐ端子。動作で決まる (図12)

```circuit
title: 図10 データの書き込み側 (74HC245)
parts:
  U4: dip20 j16 74HC245
  SD0: port h7g0
  SD1: port i8
  SD2: port i9e0
  SD3: port i10i0
  SD4: port j11c0
  SD5: port j12g0
  SD6: port k13
  SD7: port k14e0
  VCC: vcc e13 5V
  VCC: vcc e17a5 5V
  GN: ground o15
  ENT: port i18
  DQ1: port i19e0
  LDn: port i20i0
  P0: port j21c0
  P1: port j22g0
  P2: port k23
  DQ6: port k24e0
  DQ7: port k25i0
  Yn: port h27g0
wires:
  - U4.A1 -| h7g0
  - U4.A2 -| i8
  - U4.A3 -| i9e0
  - U4.A4 -| i10i0
  - U4.A5 -| j11c0
  - U4.A6 -| j12g0
  - U4.A7 -| k13
  - U4.A8 -| k14e0
  - U4.DIR -| e13
  - U4.VCC -| e17a5
  - U4.GND -| o15
  - U4.B1 -| i18
  - U4.B2 -| i19e0
  - U4.B3 -| i20i0
  - U4.B4 -| j21c0
  - U4.B5 -| j22g0
  - U4.B6 -| k23
  - U4.B7 -| k24e0
  - U4.B8 -| k25i0
  - U4.OE -| h27g0
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-6.svg)

- **図10 は書き込みのバス**。U4 (74HC245、8 ビットのバストランシーバ) の A1〜A8 (PIN 2〜9) が、スイッチの SD0〜SD7 (図11)、
  B1〜B8 (PIN 18〜11) が DQ0〜DQ7 につながる。DIR (PIN 1) は +5V で、A から B へ向かう向きに固定した。
  OE (PIN 19) は Yn。**Yn が L のときだけ**、スイッチの値が DQ に出る。H のときは出力が浮き (ハイインピーダンス)、SRAM の出力と
  ぶつからない

```circuit
title: 図11 データのスイッチ (DIP スイッチ 2 個)
parts:
  VCC: vcc d4 5V
  R19: resistor e4 g4 10k
  SW1a: switch h4 j4
  SD0: port g6
  VCC: vcc d7 5V
  R20: resistor e7 g7 10k
  SW1b: switch h7 j7
  SD1: port g9
  VCC: vcc d10 5V
  R21: resistor e10 g10 10k
  SW1c: switch h10 j10
  SD2: port g12
  VCC: vcc d13 5V
  R22: resistor e13 g13 10k
  SW1d: switch h13 j13
  SD3: port g15
  VCC: vcc d16 5V
  R23: resistor e16 g16 10k
  SW2a: switch h16 j16
  SD4: port g18
  VCC: vcc d19 5V
  R24: resistor e19 g19 10k
  SW2b: switch h19 j19
  SD5: port g21
  VCC: vcc d22 5V
  R25: resistor e22 g22 10k
  SW2c: switch h22 j22
  SD6: port g24
  VCC: vcc d25 5V
  R26: resistor e25 g25 10k
  SW2d: switch h25 j25
  SD7: port g27
  GS: ground k25
wires:
  - d4 -- e4
  - g4 -- h4
  - j4 -- k4
  - g4 -- g6
  - d7 -- e7
  - g7 -- h7
  - j7 -- k7
  - g7 -- g9
  - d10 -- e10
  - g10 -- h10
  - j10 -- k10
  - g10 -- g12
  - d13 -- e13
  - g13 -- h13
  - j13 -- k13
  - g13 -- g15
  - d16 -- e16
  - g16 -- h16
  - j16 -- k16
  - g16 -- g18
  - d19 -- e19
  - g19 -- h19
  - j19 -- k19
  - g19 -- g21
  - d22 -- e22
  - g22 -- h22
  - j22 -- k22
  - g22 -- g24
  - d25 -- e25
  - g25 -- h25
  - j25 -- k25
  - g25 -- g27
  - k4 -- k25
notes:
  - text n4 small: "SW1 と SW2 は 4 連 DIP スイッチ。ON (閉) にした位置が 0、OFF (開) が 1"
  - text o4 small: "SD0 から SD7 の 8 ビット。カウンタへ戻るのは 6 ビット"
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-7.svg)

- **図11 は語を作るスイッチ**。SW1 (4 連) の 1〜4 番が SD0〜SD3、SW2 (4 連) の 1〜4 番が SD4〜SD7。
  SD0 = ENT、SD1 = CLR、SD2 = LDn、SD3 = P0、SD4 = P1、SD5 = P2 で、SD6・SD7 は使わない (DQ6・DQ7、書いても読んでも何も起きない)。
  **ON (閉) が 0、OFF (開) が 1**。全部 OFF が `FF` で、DIP スイッチのメモリと同じ並びだ (SW1 の 3 番と SW2 の 2 番を ON にすると `B3`)。
  SD0〜SD7 は 10 kΩ で H に引いてあり、U4 の入力を浮かせない

```circuit
title: 図12 動作の切り替え (RUN / PROG)・書き込みボタン・CLR
parts:
  VCC: vcc d6 5V
  R29: resistor e6 g6 10k
  WEn: port g4
  VCC: vcc d10 5V
  R28: resistor e10 g10 10k
  Yn: port g12
  VCC: vcc d14 5V
  R27: resistor e14 g14 10k
  OEn: port g16
  S2: button i6 i10
  S3: spdt n17 mirror
  GS: ground q19
  VCC: vcc d22 5V
  R30: resistor e22 g22 10k
  CLR: port g24
  S1: button h22 j22
  GC: ground k22
  D7: diode g22 g20
  DQ1: port g18
wires:
  - d6 -- e6
  - g6 -- i6
  - g6 -- g4
  - d10 -- e10
  - g10 -- i10 -- l10
  - g10 -- g12
  - d14 -- e14
  - g14 -- l14
  - g14 -- g16
  - S3.1 -| l14
  - S3.2 -| l10
  - S3.in -| q19
  - d22 -- e22
  - g22 -- h22
  - j22 -- k22
  - g22 -- g24
  - g20 -- g18
notes:
  - text a4 small: "S3 は RUN の位置で描いた (OEn が L、Yn は R28 で H)"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/01-cpu-like-8.svg)

- **図12 は動作の切り替えと CLR**。S3 は SPDT のスライドスイッチで、共通の足が GND。RUN の側は OEn (SRAM の OE) を L にし、
  PROG の側は Yn (U4 の OE) を L にする。**どちらの側にも倒していない間 (切り替えの途中) は、OEn も Yn も R27・R28 で H になり、
  SRAM も U4 も出力が止まる**。図は RUN の位置で描いた
- **WRITE (S2)** は、WEn と Yn の間のボタン。Yn が L の PROG のときだけ、押すと WEn が L になる。RUN のときは Yn が H なので、
  押しても何も起きない (RUN で押し間違えても書き込まない)
- **CLR は S1 とダイオードで作る**。SRAM の出力は H も L も強く出すので、ROM のように S1 で列を L に引くことができない。
  そこで CLR の線に 10 kΩ (R30) を付けて H に引き、S1 が GND へ落とし、DQ1 が L のときはダイオード D7 (1N4148、カソードが DQ1 側)
  が CLR を L にする。DQ1 が H のときは D7 が逆向きで、CLR を H のままにする。CLR (PIN 1) の L は約 0.65V (DQ1 の L + ダイオード)

### SRAM のメモリの板と書き込み

**板**: 板 1 (half) は図4 のまま。メモリは **板 2 (full)** と **板 3 (half)** の 2 枚に分ける。
板 2 に SRAM (U3)・データのスイッチ (SW1・SW2 と集合抵抗 RN1)・動作の切り替え (S3)・WRITE (S2)・CLR (S1) を、
板 3 に 74HC245 (U4)・DQ のプルアップ (RN2)・D7 を組む。板 1 と板 2 は 12 本、板 2 と板 3 は 20 本のジャンパ線でつなぐ (下の表)。

AS6C62256-55PCN は **600 mil (幅 0.6 インチ) の DIP** で、図13 はフェンスの幅広 DIP の置き方 (`dip28/wide`、足の行は d 行と h 行) で描いた。
足の行が溝をはさんで 6 穴離れ、胴の下の e・f・g 行には何も挿せない。配線に使えるのは、上の a〜c 行と下の i・j 行の 5 行だけだ。
この 5 行に、U3 の DQ 8 本を U4 へ、スイッチの SD 8 本を U4 へつなぐ線 16 本を並べると、線が重なって追えない。
そこで、板の順位 (half → full → full + half) の次の **full + half** に進め、板 1 と合わせて **half 2 枚と full 1 枚**にした。

板 2 は、板 1 から A0〜A3 (下の箱)・ENT・LDn (下の箱)・P0〜P2 (上の箱)・CLR と電源 (右上の箱) を受ける。
板 3 へは、DQ0〜DQ7・SD0〜SD7・Yn・CLR・電源を渡す。箱の足の名前が同じもの (図13 の「板 3 へ」と図14 の「板 2 から」) を 1 本ずつつなぐ。

```breadboard
title: 図13 板 2 — SRAM (AS6C62256-55PCN、幅広 DIP)・データのスイッチ・切り替え
board: full
parts:
  P1:
    type: device
    at: top
    label: 板 1 から (CLR・電源)
    pins: [CLR, GND, +5V]
  P3:
    type: device
    at: top
    label: 板 3 へ (電源・CLR)
    pins: [+5V, GND, CLR]
  T13:
    type: device
    at: top
    label: 板 1 から・板 3 へ (上)
    pins: [DQ7, DQ6, DQ5, P2, DQ4, P1, DQ3, P0]
  TSD:
    type: device
    at: top
    label: 板 3 へ (SD)
    pins: [SD0, SD1, SD2, SD3, SD4, SD5, SD6, SD7]
  B13:
    type: device
    at: bottom
    label: 板 1 から・板 3 へ (下)
    pins: [Yn, A3, A2, A1, A0, ENT, DQ0, DQ1, LDn, DQ2]
  U3: dip28/wide @ d15 AS6C62256-55PCN
  S3: slide-switch h6 h7 h8
  R27: resistor j6 +b6 10k
  S2: button @ e8
  R29: resistor a8 +t8 10k
  R28: resistor j10 +b10 10k
  SW1: dip8 @ e34 l=DIP1
  SW2: dip8 @ e38 l=DIP2
  RN1: sip9 @ b33 l=10k-8
  S1: button @ e54
  R30: resistor a56 +t56 10k
wires:
  - P1.+5V -- +t61 red
  - P1.GND -- -t60 black
  - P1.CLR -- c54 white
  - P3.CLR -- b54 white
  - P3.+5V -- +t49 red
  - P3.GND -- -t50 black
  - +t62 -- +b62 red
  - -t59 -- -b59 black
  - j54 -- -b54 black
  - j7 -- -b7 black
  - a15 -- +t15 red
  - a17 -- -t17 black
  - a18 -- -t18 black
  - a19 -- -t19 black
  - a20 -- -t20 black
  - a22 -- -t22 black
  - a23 -- -t23 black
  - b21 -- b6 green
  - c6 -- g6 green
  - c16 -- c10 green
  - T13.DQ7 -- c24 orange
  - T13.DQ6 -- c25 orange
  - T13.DQ5 -- c26 orange
  - T13.P2 -- a26 white
  - T13.DQ4 -- c27 orange
  - T13.P1 -- a27 white
  - T13.DQ3 -- c28 orange
  - T13.P0 -- a28 white
  - j15 -- -b15 black
  - j16 -- -b16 black
  - j17 -- -b17 black
  - j18 -- -b18 black
  - j19 -- -b19 black
  - j20 -- -b20 black
  - j28 -- -b28 black
  - B13.Yn -- i8 blue
  - B13.A3 -- j21 purple
  - B13.A2 -- j22 purple
  - B13.A1 -- j23 purple
  - B13.A0 -- j24 purple
  - B13.ENT -- j25 purple
  - B13.DQ0 -- i25 orange
  - B13.DQ1 -- j26 orange
  - B13.LDn -- j27 purple
  - B13.DQ2 -- i27 orange
  - a33 -- +t33 red
  - TSD.SD0 -- a34 yellow
  - TSD.SD1 -- a35 yellow
  - TSD.SD2 -- a36 yellow
  - TSD.SD3 -- a37 yellow
  - TSD.SD4 -- a38 yellow
  - TSD.SD5 -- a39 yellow
  - TSD.SD6 -- a40 yellow
  - TSD.SD7 -- a41 yellow
  - j34 -- -b34 black
  - j35 -- -b35 black
  - j36 -- -b36 black
  - j37 -- -b37 black
  - j38 -- -b38 black
  - j39 -- -b39 black
  - j40 -- -b40 black
  - j41 -- -b41 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/01-cpu-like-4.svg)

- **U3 (AS6C62256) は 15〜28 列** (`@ d15`)、切り欠きが左。上の行 (d 行) に 28 番 (VCC、15 列) から 15 番 (DQ3、28 列) まで、
  下の行 (h 行) に 1 番 (A14、15 列) から 14 番 (VSS、28 列) まで並ぶ。足の番号は胴の縁、名前はそのすぐ内側に出る
- **電源と GND は縦 1 本**: VCC は `a15` から + レールへ (赤)。GND は、上の行の A13・A8・A9・A11・A10・CE (`a17`〜`a20`・`a22`・`a23`) を上の − レールへ、
  下の行の A14〜A4 (`j15`〜`j20`) と VSS (`j28`) を下の − レールへ落とす (黒)。A4〜A14 と CE を GND に固定した回路図 (図9) のとおりだ
- **番地**: 板 1 の A0〜A3 を、下の箱から下の行の 24〜21 列 (`j24`〜`j21`、PIN 10〜7) へ入れる (紫)
- **DQ**: 下の行の DQ0〜DQ2 (25〜27 列) と、上の行の DQ3〜DQ7 (28〜24 列) を、板 3 の U4 の B 側へ渡す (橙)。
  下の行の穴は各列に `i` と `j` の 2 つだけなので、板 1 の線 (ENT は 25 列、LDn は 27 列、紫) と DQ の線 (橙) を 1 つずつ入れる。
  上の行の DQ3〜DQ5 (28・27・26 列) には、板 1 の P0・P1・P2 (白) を `a` 行に、DQ の線 (橙) を `c` 行に入れる。
  10 kΩ のプルアップ (図9 の R11〜R18) は、板 3 の U4 の B 側に付けた
- **OE と WE**: OE (PIN 22、21 列) の `b21` から緑の線を 6 列へ引き (`b6`)、`c6` から溝をまたぐ縦の線で 6 列の下 (`g6`) へ渡す。
  WE (PIN 27、16 列) の `c16` から緑の線を S2 の上の足の列 (10 列) へ引く
- **S3 (スライドスイッチ)** は 6〜8 列 (`h6`〜`h8`) で、1 番が RUN 側 (OEn)、2 番が共通 (GND、`j7` から下の − レールへ)、3 番が PROG 側 (Yn)。
  R27 (OEn を H に引く) は `j6` と + レールの間、R28 (Yn を H に引く) は `j10` と + レールの間に立てる
- **S2 (WRITE)** は 8〜10 列 (`e8`)。上の足の列 (8・10 列の上) が WEn で、R29 は `a8` と上の + レールの間。
  下の足の列 (8・10 列の下) が Yn で、S3 の 3 番 (8 列) と同じ組だ。板 3 へ渡す Yn の線は `i8`。
  Yn が L の PROG のときだけ、押すと WEn が L になる (回路図の図12 のとおり)
- **S1 (CLR)** は 54〜56 列 (`e54`)。上の足の列が CLR、下の足の列が GND (`j54` から下の − レールへ)。
  R30 は `a56` と上の + レールの間。CLR の線は、板 1 から `c54`、板 3 へ `b54` の 2 本を、同じ列の別の穴に入れる
- **データのスイッチ**: SW1 は 34〜37 列、SW2 は 38〜41 列 (切り欠きが左)。n 番のスイッチが n 番目の列の上の組と下の組をつなぐ。
  上の組を SD0〜SD7、下の組を GND にした (下の組は `j34`〜`j41` から − レールへ、黒の 8 本)。
  集合抵抗 RN1 (10 kΩ × 8、図11 の R19〜R26) は `b33` から 9 本の足を挿し、共通の足 (1 番、33 列) を `a33` から + レールへ、
  残りの 8 本を SD の列 (34〜41 列の上) に入れる。SD の線は `a34`〜`a41` から板 3 へ渡す
- **電源**: 板 1 の +5V と GND は、右上の箱から `+t61` と `-t60` へ入れる。板 3 への電源は `+t49` と `-t50` から出す。
  上下のレールは、+ が `+t62` と `+b62`、− が `-t59` と `-b59` の線でつなぐ。**赤は +5V の線だけ、黒は GND の線だけ**に使った

```breadboard
title: 図14 板 3 — 74HC245 (DQ のバス)・DQ のプルアップ・D7
board: half
parts:
  PW:
    type: device
    at: top
    label: 板 2 から (電源・CLR)
    pins: [+5V, GND, CLR]
  TA:
    type: device
    at: top
    label: 板 2 から (Yn・DQ0〜DQ3)
    pins: [Yn, DQ0, DQ1, DQ2, DQ3]
  TB:
    type: device
    at: top
    label: 板 2 から (DQ4〜DQ7)
    pins: [DQ4, DQ5, DQ6, DQ7]
  BB:
    type: device
    at: bottom
    label: 板 2 から (SD)
    pins: [SD0, SD1, SD2, SD3, SD4, SD5, SD6, SD7]
  U4: dip20 @ e8 74HC245
  RN2: sip9 @ b10 r180 l=10k-8
  D7: diode a3(K) a7(A)
wires:
  - PW.+5V -- +t1 red
  - PW.GND -- -t2 black
  - PW.CLR -- b7 white
  - +t30 -- +b30 red
  - -t30 -- -b30 black
  - a8 -- +t8 red
  - j8 -- +b8 red
  - j17 -- -b17 black
  - TA.Yn -- a9 blue
  - TA.DQ0 -- a10 orange
  - TA.DQ1 -- a11 orange
  - TA.DQ2 -- a12 orange
  - TA.DQ3 -- a13 orange
  - TB.DQ4 -- a14 orange
  - TB.DQ5 -- a15 orange
  - TB.DQ6 -- a16 orange
  - TB.DQ7 -- a17 orange
  - a18 -- +t18 red
  - d11 -- d3 orange
  - BB.SD0 -- j9 yellow
  - BB.SD1 -- j10 yellow
  - BB.SD2 -- j11 yellow
  - BB.SD3 -- j12 yellow
  - BB.SD4 -- j13 yellow
  - BB.SD5 -- j14 yellow
  - BB.SD6 -- j15 yellow
  - BB.SD7 -- j16 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/01-cpu-like-5.svg)

- **U4 (74HC245) は 8〜17 列** (`@ e8`)、切り欠きが左。上の行に 20 番 (VCC、8 列)、19 番 (OE = Yn、9 列)、18〜11 番 (B1〜B8、10〜17 列)、
  下の行に 1 番 (DIR、8 列)、2〜9 番 (A1〜A8、9〜16 列)、10 番 (GND、17 列) が並ぶ。VCC は `a8` から + レールへ、
  DIR は `j8` から下の + レールへ (A から B の向きに固定)、GND は `j17` から下の − レールへ、縦 1 本ずつ落とす
- **板 2 から入る線**: 上の 2 つの箱の Yn を `a9` (OE の列) へ、DQ0〜DQ7 を `a10`〜`a17` (B1〜B8 の列) へ、下の箱の SD0〜SD7 を `j9`〜`j16` (A1〜A8 の列) へ入れる
- **DQ のプルアップ RN2** (10 kΩ × 8、図9 の R11〜R18) は、B の列の上 (`b10`、向きを反転) に挿す。共通の足 (1 番) が右端の 18 列で、
  `a18` から + レールへ (赤)。残りの 8 本の足が 17〜10 列 (B8〜B1) に入る
- **D7 (1N4148)** は、カソード (線の入った側) を 3 列 (`a3`)、アノードを 7 列 (`a7`) に挿す。
  カソードの列 (3 列) を、橙の線 (`d3` と `d11`) で B2 = DQ1 の列 (11 列) につなぐ。アノードの列 (7 列) に、板 2 の CLR の線 (白) を `b7` へ入れる

### 板どうしの線と、回路図との対応

板 1 から板 2 へ (12 本。図4 の箱の足の名前のとおり):

| 板 1 の足 | 板 2 の箱 | 板 2 の穴 |
| --- | --- | --- |
| A0・A1・A2・A3 | 板 1 から・板 3 へ (下) | `j24`・`j23`・`j22`・`j21` (U3 の PIN 10・9・8・7) |
| ENT・LDn | 板 1 から・板 3 へ (下) | `j25`・`j27` (U3 の DQ0・DQ2 の列) |
| P0・P1・P2 | 板 1 から・板 3 へ (上) | `a28`・`a27`・`a26` (U3 の DQ3・DQ4・DQ5 の列) |
| CLR | 板 1 から (CLR・電源) | `c54` (S1 の上の足の列) |
| +5V・GND | 板 1 から (CLR・電源) | `+t61`・`-t60` |

板 2 から板 3 へ (20 本。同じ名前の足どうしを 1 本ずつ):

| 名前 | 板 2 の穴 | 板 3 の穴 |
| --- | --- | --- |
| DQ0・DQ1・DQ2 | `i25`・`j26`・`i27` (U3 の PIN 11・12・13 の列) | `a10`・`a11`・`a12` (U4 の B1・B2・B3) |
| DQ3〜DQ7 | `c28`・`c27`・`c26`・`c25`・`c24` (U3 の PIN 15〜19 の列) | `a13`〜`a17` (U4 の B4〜B8) |
| SD0〜SD7 | `a34`〜`a41` (SW の上の組、RN1) | `j9`〜`j16` (U4 の A1〜A8) |
| Yn | `i8` (S2 の下の足と S3 の 3 番の列) | `a9` (U4 の OE) |
| CLR | `b54` (S1 の上の足の列) | `b7` (D7 のアノードの列) |
| +5V・GND | `+t49`・`-t50` | `+t1`・`-t2` |

回路図の線と、板の穴の対応:

| 線の名前 | 回路図 | 板 2 | 板 3 |
| --- | --- | --- | --- |
| A0〜A3 | 図9 U3 PIN 10〜7 | 24〜21 列の下 (PIN 10〜7) | — |
| DQ0 (ENT) | 図9 U3 PIN 11、R11、図10 U4 B1 | 25 列の下 (PIN 11) | 10 列の上 (B1、RN2) |
| DQ1 | 図9 U3 PIN 12、R12、図10 U4 B2、図12 D7 | 26 列の下 (PIN 12) | 11 列の上 (B2、RN2、D7 のカソードへ) |
| DQ2 (LDn) | 図9 U3 PIN 13、R13、図10 U4 B3 | 27 列の下 (PIN 13) | 12 列の上 (B3、RN2) |
| DQ3〜DQ5 (P0〜P2) | 図9 U3 PIN 15〜17、R14〜R16、図10 U4 B4〜B6 | 28〜26 列の上 (PIN 15〜17) | 13〜15 列の上 (B4〜B6、RN2) |
| DQ6・DQ7 | 図9 U3 PIN 18・19、R17・R18、図10 U4 B7・B8 | 25・24 列の上 (PIN 18・19) | 16・17 列の上 (B7・B8、RN2) |
| OEn | 図9 U3 PIN 22、図12 R27・S3 | 21 列の上 (PIN 22)、6 列 (S3 の 1 番、R27) | — |
| WEn | 図9 U3 PIN 27、図12 R29・S2 | 16 列の上 (PIN 27)、8・10 列の上 (S2、R29) | — |
| Yn | 図10 U4 OE、図12 R28・S2・S3 | 8・10 列の下 (S2、R28)、8 列 (S3 の 3 番) | 9 列の上 (U4 の OE) |
| SD0〜SD7 | 図10 U4 A1〜A8、図11 R19〜R26・スイッチ | 34〜41 列の上 (RN1、スイッチ) | 9〜16 列の下 (A1〜A8) |
| CLR | 図12 R30・S1・D7 のアノード、U1 の CLR | 54・56 列の上 (S1、R30) | 7 列の上 (D7 のアノード) |

`breadboard-fence check` が出したネットリストは、この表のとおりだった。2 枚の図を合わせて (同じ名前の箱の足を 1 本の線として) 回路図の図9〜12 と一致した。
たとえば、板 2 の DQ0 の線は `B13.ENT, B13.DQ0, U3.DQ0`、OEn は `U3.OE, S3.1, R27.1`、Yn は `B13.Yn, S3.3, S2.2a, S2.2b, R28.1`、
板 3 の DQ1 の線は `TA.DQ1, U4.B2, RN2.8, D7.K` だった。板では、回路図の 1 つの線が「U3 の足・板 1 への線・板 3 への線」の複数の穴になり、
同じ列の別の穴にまとめてある。S3 は、回路図の 1 番 (RUN) と共通 (GND) を、板では 1 番・2 番に、PROG 側を 3 番に割り当てた。

**書き込みの手順** (サンプルのプログラム `FF FF FF FF FF B3 FF …` を書く)

まず AD3 の Wavegen の W1 を、**1 回押すごとにクロックが 1 周期だけ出る**設定にする (Square、Amplitude 2.5 V、Offset 2.5 V、
繰り返し 1 回 (Burst 1) で Run を押すたびに 1 周期。設定の名前は WaveForms で確認していない)。クロックを 1 つ出すと、PC の番地が 1 つ進む。

1. Supplies を 5 V にして入れる。**S3 を PROG に倒す**。スイッチ (SW1・SW2) は全部 OFF (= `FF`)。WRITE は押さない
2. **S1 を押しながら W1 を 1 回出す**。CLR が効き、番地が 0 になる (LED が全部消える)
3. WRITE (S2) を押して離す。**番地 0 に `FF` が書かれた**
4. W1 を 1 回出す。番地が 1 つ進む (LED で確かめる)。WRITE を押して離す。3 と 4 を繰り返して、**番地 0〜15 のすべてに `FF` を書く**
   (16 回書き、15 回進める。番地 15 の次は 0 に戻る)
5. S1 を押しながら W1 を 1 回出して番地を 0 に戻し、W1 を 5 回出して番地 5 (LED が 0101) にする
6. **SW1 の 3 番 (LDn) と SW2 の 2 番 (P2) を ON にする** (= `B3`)。WRITE を押して離す。番地 5 に `B3` が書かれた
7. 走らせる: **S3 を RUN に倒す**。S1 を押しながら W1 を 1 回出して番地を 0 に戻す。W1 を **1 Hz の連続** (図4 の設定) に戻して S1 を離す。
   LED が 0 1 2 3 4 5 3 4 5 3 … と進む (図6 と同じ)

書き込みのときに守ること:

- **W1 を出すとき (番地を進めるとき) は、SW1 の 1・2・3 番 (ENT・CLR・LDn) が OFF** であること。PROG の間、スイッチの値が DQ に出て、
  そのまま板 1 のカウンタの ENT・CLR・LDn・P0〜P2 に入るので、`B3` のように LDn が 0 の語をスイッチに作ったまま W1 を出すと、
  カウンタが番地を進めずに飛ぶ。番地 5 に `B3` を書くのを最後にしたのは、このためだ
- WRITE を押している間は、スイッチを動かさない。押して離してから動かす
- S3 を倒すときは WRITE を押さない
- 語を読み直すには、S3 を RUN にして、S1 を押しながら W1 を 1 回出し、W1 を 1 Hz にして LED を見る。番地を 1 つずつ見るなら、
  PROG に戻す前に W1 を止める

#### バスがぶつからない理由と、74HC245 を選んだ理由

- DQ の線を駆動できるのは SRAM (OE が L のとき) と U4 (Yn が L のとき) の 2 つだけで、**S3 が同時に両方を有効にしない**
  (RUN は SRAM だけ、PROG は U4 だけ、途中は両方止まる)。SRAM の OE が H になると、出力は tOHZ = 20 ns 以内に止まる。
  U4 の出力が出るのは OE が L になってから 46 ns 以内 (SN74HC245 の ten の最大、25 ℃)。スイッチを倒すのは人の手で数十 ms かかるので重ならない。
  S3 は**切り替えの途中で両方の側が触れない型** (ブレーク・ビフォア・メイク) を選ぶ。品による (確認していない)
- **WRITE で WE が L になると、SRAM の出力は OE に関係なく止まる** (データシートの動作表: 書き込みは CE = L・WE = L で、出力は入力側になる)。
  OE が H のときは、tWP > tWHZ + tDW の条件 (OE が L のときの注意書き) は関係しない
- **直列の抵抗 (1 kΩ など) でスイッチを DQ につなぐ案は取らなかった**。RUN のとき、閉じたスイッチが SRAM の出力を GND へ引く。
  SRAM の出力の H は 1 mA を流して 2.4 V 以上しか保証されず、1 kΩ で GND へ引くと 2.4 mA 流れて H が 74HC163 の入力のしきい値
  (3.15V 以上) より下がりうる。RUN でスイッチが効かないようにするには、ゲート (U4) が要る

**データシートの時間と、この回路の余裕** (AS6C62256-55、5V)

| 項目 | データシート | この回路 |
| --- | --- | --- |
| tAA 番地 → データ | 55 ns 以下 | RUN で番地が変わってから 55 ns でデータが決まる |
| tOHZ OE → 出力停止 | 20 ns 以下 | S3 を PROG に倒したあと 20 ns で SRAM の出力が止まる (人の手より十分速い) |
| tAW 番地 → 書き込みの終わり | 50 ns 以上 | 番地は W1 で決めてから WRITE を押す (数 ms 以上) |
| tWP 書き込みパルスの幅 | 45 ns 以上 | ボタンを押している時間 (数 ms 以上)。接点のはね返り (バウンス) で幅の短いパルスが出ても、データと番地は同じなので、最後の長いパルスで同じ語が書かれる |
| tDW データを保つ時間 | 25 ns 以上 | スイッチを動かさない (押す前に決めておく) |
| tDH / tWR / tAS | 0 ns 以上 | WRITE を離してからスイッチを動かす |

RUN の上限は、U1 の CLK → Q が 41 ns (74HC163 の最大、25 ℃) + SRAM の tAA が 55 ns + CLR の線が H に戻る時間 (R30 の 10 kΩ × 約 45 pF ≒ 0.45 µs で、
0.7V から 3.15V まで約 0.38 µs) + U1 の CLR の準備時間 32 ns ≒ 0.51 µs、つまり**約 2 MHz が上限の見積もり** (実測していない。
容量は入力容量・ダイオード・板の浮遊容量を合わせた仮定)。ENT と LDn は SRAM の出力から直接 U1 に入るので、これより速い。
R30 を 4.7 kΩ にすれば上限は上がるが、この題は 1 Hz で使うので 10 kΩ のままにした。

**電流**: SRAM の ICC が最大 45 mA (最短のサイクルのとき、データシート)。LED 4 つが 3.8 mA × 4 ≒ 15 mA。
10 kΩ のプルアップ 20 本 (DQ 8 本、SD0〜SD7 の 8 本、OEn・Yn・WEn・CLR の 4 本) が全部 L でも 0.5 mA × 20 = 10 mA。
74HC163 と 74HC245 の静止電流は数 µA〜数十 µA。**合計は最大でも約 70 mA** で、板全体の 500 mA、1 穴の 200 mA の限度より十分小さい
(最大の 1 本は SRAM の +5V の 45 mA)。

**電源を切ると SRAM の中身は消える**。SRAM は電源が 1.5 V (データシートの保持電圧の最小) 以上ないと語を覚えていられず、
この回路にはバッテリーが無い。**電源を入れるたびに、16 語 (最低でも番地 0〜5) を書き直す**。
ダイオードの ROM・DIP スイッチのメモリ・本物の ROM がある理由はここにある。6116 (2K × 8、24 ピン、幅 0.6 インチ) も同じ作りでよい
(番地 A4〜A10 を GND、データは IO0〜IO7)。この題では作らない (入手性は確認していない)。

## 部品

電源は AD3 の V+ (5 V)。

| 記号 | 部品 | 値・型番 | 数 |
| --- | --- | --- | --- |
| U1 | 4 ビット同期カウンタ (同期クリア、DIP-16) | 74HC163 | 1 |
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
- クロックを AD3 の代わりに 555 で作るときは [回路の本の 10-4](../../01-circuits/10-logic/04-binary-counter.md) の 555 (10 kΩ・47 kΩ・10 µF) を足す

**DIP スイッチのメモリ (図7・図8) にするとき** (D5・D6 の 2 個は要らない。板 1 の部品は上の表のまま)

| 記号 | 部品 | 値・型番 | 数 |
| --- | --- | --- | --- |
| U2 | 4 → 16 デコーダ (DIP-24、幅 0.3 インチ) | 74HC154 (上と同じ) | 1 |
| SW1、SW2 | 4 連 DIP スイッチ (DIP-8、幅 0.3 インチ) | ピッチ 2.54 mm。n 番が PIN n と PIN 9−n をつなぐ品 | 2 |
| RN1 | 集合抵抗 (SIL 9 ピン、共通付き) | 10 kΩ × 8 (図7 の R5〜R10 の 6 本ぶんを兼ねる。残りの 2 本は空き) | 1 |
| S1 | タクトスイッチ | 6 mm | 1 |
| — | ブレッドボード | half 1 枚 (板 1)、full 1 枚 (板 2) | 2 |

**SRAM のメモリ (図9〜12) にするとき** (U2・D5・D6・R5〜R10 は要らない。板 1 の部品は上の表のまま)

| 記号 | 部品 | 値・型番 | 数 |
| --- | --- | --- | --- |
| U3 | SRAM 32K × 8 (DIP-28、**幅 0.6 インチ**) | AS6C62256-55PCN (Alliance Memory) | 1 |
| U4 | 8 ビット バス トランシーバ (DIP-20) | 74HC245 (SN74HC245N など) | 1 |
| SW1、SW2 | 4 連 DIP スイッチ (DIP-8、幅 0.3 インチ) | 上と同じ | 2 |
| RN1、RN2 | 集合抵抗 (SIL 9 ピン、共通付き) | 10 kΩ × 8 (RN1 = 図11 の R19〜R26、RN2 = 図9 の R11〜R18) | 2 |
| R27〜R30 | 抵抗 (1/4 W) | 10 kΩ | 4 |
| D7 | 小信号ダイオード | 1N4148 | 1 |
| S1 | タクトスイッチ (CLR) | 6 mm | 1 |
| S2 | タクトスイッチ (WRITE) | 6 mm | 1 |
| S3 | スライドスイッチ (SPDT) | 切り替えの途中で両側が触れない型 (ブレーク・ビフォア・メイク) | 1 |
| — | ブレッドボード | half 2 枚 (板 1・板 3)、full 1 枚 (板 2) | 3 |

- AS6C62256-55PCN は 28 ピンの 600 mil PDIP で、図13 はフェンスの幅広 DIP の置き方で描いた。電源は 2.7〜5.5V。SOP (330 mil) 品はブレッドボードに載らない。入手性は確認していない

## 出典

自作。74HC163 の足の並びと同期クリア・ロードの動き・入力のしきい値・静止電流・出力の保証 (±4 mA)・
入力の準備時間 (34 ns、CLR は 32 ns)・伝搬遅延 (CLK → Q が最大 41 ns) は、TI の SN74HC163 データシート (SCLS298D) による。
74HC154 の足の並びと真理値表・伝搬遅延・出力の保証 (4 mA で VOH 3.98 V 以上・VOL 0.26 V 以下)・絶対最大 (出力 ±25 mA)・
幅 0.6 / 0.3 インチの品種は、TI の CD74HC154 データシート (SCHS152D) による。
AD3 の DIO の電圧 (3.3V、5V まで許容、H は 2.0V 以上) と波形発生器の出力範囲は、Digilent の
Analog Discovery 3 の仕様書による。

SRAM のメモリの節の数値:

- AS6C62256 (Alliance Memory、2016 年 3 月、rev 1.2):
  [https://www.alliancememory.com/wp-content/uploads/AS6C62256-23-March-2016-rev1.2.pdf](https://www.alliancememory.com/wp-content/uploads/AS6C62256-23-March-2016-rev1.2.pdf)。
  tAA 55 ns 以下、tOE 30 ns 以下、tOHZ 20 ns 以下、tAW 50 ns 以上、tWP 45 ns 以上、tDW 25 ns 以上、tDH・tWR・tAS 0 ns 以上、
  tWHZ 20 ns 以下、VIL 0.6 V 以下、VIH 2.4 V 以上、VOH 2.4 V 以上 (−1 mA)、VOL 0.4 V 以下 (2 mA)、ICC 最大 45 mA (最短サイクル)、
  電源 2.7〜5.5V、データ保持電圧 1.5 V 以上、28 ピン 600 mil PDIP (型番 AS6C62256-55PCN)、動作表 (書き込みは CE = L・WE = L)
- SN74HC245 (TI、SCLS131F):
  [https://www.ti.com/lit/ds/symlink/sn74hc245.pdf](https://www.ti.com/lit/ds/symlink/sn74hc245.pdf)。
  出力の保証 ±6 mA (VOH 3.84 V 以上、VOL 0.33 V 以下)、ten 最大 46 ns・tdis 最大 40 ns (25 ℃、4.5 V)、静止電流
- 集合抵抗・DIP スイッチ・スライドスイッチの型番や定格、Wavegen で 1 周期だけ出す設定、AS6C62256 の入手性は確認していない
- クロックの上限 (約 2 MHz) と、出力の押し合いの電流 (約 23 mA) は、上のデータシートの値から計算した見積もりで、実測していない
