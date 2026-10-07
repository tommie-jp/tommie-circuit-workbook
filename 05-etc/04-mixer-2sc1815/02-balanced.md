---
book: etc
chapter: 4
id: 4-2
title: 差動対のミキサー — 2SC1815 の差動対とカレントミラーで RF を打ち消す
tier: 200
source: 自作
board: BB
---

# 4-2 差動対のミキサー — 2SC1815 の差動対とカレントミラーで RF を打ち消す

4-1 の 1 石ミキサーは、コレクタに RF と LO が IF と一緒にそのまま出た。
この題は 2SC1815 を 3 本使い、**LO で差動対を切り替え、RF を下の電流源に入れる**。
2 本のコレクタの電流の**差**を取ると、**RF が打ち消されて消える** (LO は残る)。
差は **PNP のカレントミラー** (2SA1015 を 2 本) で 1 本の出力にまとめ、4-1 と同じ同調回路・セラミックフィルタ・50 Ω の IF OUT へ出す。**トランスは使わない**。
掛け算で和と差だけを作る [9-12](../../01-circuits/09-rf/12-balanced-mixer.md) の「バランスド」を、トランジスタで目に見える形にする。
ギルバートセル (SA612 などの中身) の半分にあたる。

> [!WARNING]
> 特性は**シミュレーションだけ**で、**実機では測っていない**。2SC1815 のモデルは 4-1 と同じ代用のモデル、2SA1015 も目安から作った代用のモデル。
> 打ち消しの深さは、モデルの左右が全く同じなので**実物より深く出る** (「注意」)。

## 仕様

| 項目 | 値 |
| --- | --- |
| RF | 0.53〜1.6 MHz (中波)。50 Ω。**電流源 (Q3) のベース**に入れる |
| LO | RF + 455 kHz (0.985〜2.055 MHz)。50 Ω。**0 dBm (0.32 V 波高値) が標準**。**Q1 のベース**に入れる。正弦波 |
| IF | 455 kHz。50 Ω。カレントミラーで差を 1 本にし、4-1 と同じ同調回路・セラミックフィルタ・L 型整合を通す |
| 電源 | 5 V (単電源)。電流は 約 1.45 mA (信号なし) |
| トランジスタ | 2SC1815 × 3 (Q1・Q2 は差動対、Q3 は電流源)、2SA1015 × 2 (Q4・Q5 はカレントミラー) |

## なぜ差を取ると RF が消えるのか

Q1・Q2 のエミッタは Q3 のコレクタにつながる。Q3 は RF に比例した電流 I<sub>T</sub> = I<sub>0</sub> + i<sub>rf</sub> を流す電流源として働く。
Q1・Q2 は LO の電圧で I<sub>T</sub> を左右に振り分け、**差の電流は** I<sub>T</sub> · tanh(v<sub>lo</sub> / 2V<sub>T</sub>) になる。
LO が大きいと tanh は ±1 の方形波に近づく (**LO で電流を切り替える**)。

- **i<sub>rf</sub> の項**: i<sub>rf</sub> × (±1 の方形波)。RF の符号が LO の周期で反転するので、**和と差の周波数** (f<sub>LO</sub> ± f<sub>RF</sub>) だけが出る。**RF そのものは出ない**。4-1 の 1 本では RF が出た
- **I<sub>0</sub> の項**: I<sub>0</sub> × (±1 の方形波)。**LO の奇数次の高調波がそのまま出る**。差を取っても LO は消えない

つまりシングルバランスは、**RF か LO のどちらか一方だけ**を消す。この回路は RF が消える側。両方を消すには、差動対を 2 組使う**ダブルバランス** (ギルバートセル。トランジスタ 6 本) にする。

### 差を 1 本にまとめる — カレントミラー

差の電流は 2 本のコレクタに分かれて出る。PNP のカレントミラー (Q4・Q5) を 2 本のコレクタの負荷にすると、
Q4 が Q1 の電流を受け、Q5 が同じ電流を Q2 のコレクタの側へ流し込む。Q2 のコレクタ (ミラーの出力) から外へ出る電流は
**Q1 の電流 − Q2 の電流**、つまり差そのものになる。片側だけ取り出すより IF が 2 倍 (+6 dB) になり、RF は打ち消されたまま出る。

## 取り出し方を比べて選んだ

トランスを使わない取り出し方を、代用モデルの上で同じ出力回路 (同調回路・R7・セラミックフィルタ・50 Ω) につないで比べた。
RF −30 dBm、LO 0 dBm、信号源 0 Ω。利得は IF OUT (50 Ω) の電力 ÷ RF の有能電力。
RF・LO はフィルタの前 (取り出した所) で IF と比べた値。再現は [sim/diff_output.py](sim/diff_output.py) (結果は [sim/diff_output.json](sim/diff_output.json))。

| 取り出し方 | 変換利得 | RF (IF との差) | LO (IF との差) | 電源の電流 |
| --- | --- | --- | --- | --- |
| 片側のコレクタに同調回路 (もう片側は 3.3 kΩ) | −20.7 dB | −4 dB (打ち消せない) | +26 dB | 1.33 mA |
| 片側のコレクタを 1.5 kΩ にしてフィルタへ直に | −21.8 dB | +9 dB | +43 dB | 1.33 mA |
| 2 本のコレクタ (3.3 kΩ ずつ) をもう 1 段の差動対で 1 本に | −41.9 dB | +8 dB | +67 dB | 2.99 mA |
| PNP のカレントミラー (同調回路なし) | −15.8 dB | −15 dB | +44 dB | 1.46 mA |
| **PNP のカレントミラー + 同調回路** | **−15.5 dB** | **−37 dB** | **+26 dB** | **1.45 mA** |
| 上に加えて **Q3 のエミッタの 470 Ω を 47 Ω + 430 Ω (1 µF でバイパス) に分ける** (この題の回路) | **+0.3 dB** | **−36 dB** | **+10 dB** | **1.45 mA** |

- **片側だけ**は差を使わないので RF が消えない。1.5 kΩ に直では、同調回路が無いぶん RF と LO がさらに大きく残る
- **もう 1 段の差動対**は、消えずに残る LO (2 本のコレクタの間で数 V) で 2 段目が振り切れ、IF がほとんど出ない
- **カレントミラー**は差を 1 本にまとめるので RF が消える。ただし同調回路が無いと LO がミラーの出力を 2.0〜4.6 V まで振り、Q2・Q5 が飽和しかけて打ち消しが −15 dB に浅くなる。**同調回路 (LT・CTK を CT で DC を切って GND へ) を足すと LO が 455 kHz 以外で落ち、打ち消しが −37 dB に戻る**
- 利得が −15 dB と小さいのは、RF を入れる Q3 のエミッタの 470 Ω が負帰還になり、RF の電圧を電流に変える割合 (約 2 mS) が小さいため。
  **470 Ω のうち 430 Ω を 1 µF でバイパス**し、47 Ω だけ残すと +16 dB 上がる (+0.3 dB)。直流の電流は変わらない (0.79 mA)。代わりに入力 1 dB 圧縮点は約 −13 dBm (470 Ω のままなら 0 dBm でも 0.1 dB しか落ちない)

**カレントミラー + 同調回路 + RE の分割を選んだ。** トランスが要らず、部品は 2SC1815・2SA1015 とリード線の付いた抵抗・コンデンサ・コイルだけで手に入りやすい。
LO の大きさ (−5〜+16 dBm) と LO の源のインピーダンス (0 Ω でも 50 Ω でも) で利得がほとんど変わらない (±0.2 dB)。

## 回路図

```circuit
title: 図01 2SC1815 差動対のミキサー (カレントミラーで差を 1 本に・IF 455 kHz・50 Ω 出力)
parts:
  VDD:  vcc 16,2 5V
  C6:   capacitor 4,3 4,5 100n
  C7:   ecap 6,3 6,5 10u
  RL1:  resistor 9,4 9,6 10k
  RL2:  resistor 9,13 9,15 10k
  LO:   port 2,12
  R3:   resistor 4,12 4,14 51
  C2:   capacitor 5,12 7,12 10n
  RM1:  resistor 13,4 13,6 220
  RM2:  resistor 19,4 19,6 220
  Q4:   pnp 13,8 mirror
  Q5:   pnp 19,8
  Q1:   npn 13,13
  Q2:   npn 19,13 mirror
  VDD:  vcc 26,18 5V
  RR1:  resistor 26,19 26,21 10k
  RR2:  resistor 26,23 26,25 10k
  C9:   capacitor 28,23 28,25 100n
  RBT:  resistor 22,4 22,6 15k
  RBB:  resistor 24,13 24,15 27k
  CT:   capacitor 31,11 31,13 100n
  LT:   inductor 31,15 31,17 220u
  CTK:  capacitor 34,15 34,17 560p
  C4:   capacitor 35,11 37,11 10n
  R7:   resistor 38,11 38,13 2k
  FL1:  ceramic-filter 41,11 455kHz
  C5:   capacitor 45,11 45,13 1.2n
  L2:   inductor 45,11 48,11 100u
  IF:   port 50,11
  Q3:   npn 16,19
  VDD:  vcc 11,16 5V
  RB1:  resistor 11,17 11,19 82k
  RB2:  resistor 11,21 11,23 22k
  RF:   port 2,20
  R1:   resistor 4,20 4,22 51
  C1:   capacitor 5,20 7,20 10n
  RE1:  resistor 16,21 16,22 47
  RE2:  resistor 16,23 16,25 430
  CE:   capacitor 18,23 18,25 1u
  G1:   ground 4,5
  G2:   ground 6,5
  G3:   ground 9,15
  G4:   ground 4,14
  G5:   ground 26,25
  G6:   ground 28,25
  G7:   ground 11,23
  G8:   ground 4,22
  G9:   ground 16,25
  G10:  ground 18,25
  G11:  ground 24,15
  G12:  ground 31,17
  G13:  ground 34,17
  G14:  ground 38,13
  G15:  ground 41,13
  G16:  ground 45,13
wires:
  - 4,3 -- 6,3 -- 9,3 -- 13,3 -- 16,3 -- 19,3 -- 22,3
  - 16,2 -- 16,3
  - 9,3 -- 9,4
  - 13,3 -- 13,4
  - 19,3 -- 19,4
  - 22,3 -- 22,4
  - 13,6 -- Q4.E
  - 19,6 -- Q5.E
  - Q4.B -- 16,8 -- Q5.B
  - Q4.C -- 13,10 -- Q1.C
  - 13,10 -- 16,10 -- 16,8
  - Q5.C -- 19,11 -- Q2.C
  - 9,6 -- 9,13
  - 2,12 -- 4,12 -- 5,12
  - 7,12 -- 9,13 -- Q1.B
  - 26,18 -- 26,19
  - 26,21 -- 26,22 -- 26,23
  - 26,22 -- 28,22 -- 28,23
  - Q2.B -- 21,13 -- 21,22 -- 26,22
  - 19,11 -- 22,11
  - 24,11 -- 31,11 -- 35,11
  - 22,6 -- 22,11
  - 22,11 -- 24,11 -- 24,13
  - 31,13 -- 31,15 -- 34,15
  - 37,11 -- 38,11 -- FL1.IN
  - FL1.GND -- 41,13
  - FL1.OUT -- 45,11
  - 48,11 -- 50,11
  - Q1.E -- 13,16
  - Q2.E -- 19,16
  - 13,16 -- 16,16 -- 19,16
  - 16,16 -- Q3.C
  - 11,16 -- 11,17
  - 11,19 -- 11,20 -- 11,21
  - 2,20 -- 4,20 -- 5,20
  - 7,20 -- 11,20
  - 11,20 -| Q3.B
  - Q3.E -- 16,21
  - 16,22 -- 16,23
  - 16,22 -- 18,22 -- 18,23
notes:
  - text 2,10 small left: "LO IN 50Ω"
  - text 2,11 small blue left: "0 dBm (0.32 Vp)"
  - text 2,18 small left: "RF IN 50Ω"
  - text 2,19 small blue left: "-30 dBm (10 mVp)"
  - text 50,9 small left: "IF OUT 50Ω"
  - text 50,10 small blue left: "RF -30 dBm で -29.7 dBm (10.4 mVp)"
  - text 25,9 small blue left: "DC 3.23 V (ミラーの出力)"
  - text 16,5 small blue center: "IC 0.39 mA ずつ"
  - text 17,17 small blue left: "尾 1.88 V"
  - text 3,24 small blue left: "Q3: B 1.00 V・E 0.37 V・IC 0.79 mA"
  - text 35,14 small left: "LT・CTK は約 454 kHz に同調"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/circuit/02-balanced.svg)

左下の RF は C1 で Q3 のベースへ。Q3 のエミッタは RE1 (47 Ω) と RE2 (430 Ω) の直列で、RE2 だけを CE (1 µF) でバイパスする。直流では 477 Ω で約 0.79 mA の電流源、
交流 (RF) では 47 Ω だけの負帰還になる。Q3 のコレクタ (尾) に Q1・Q2 のエミッタをつなぐ。Q1 のベースには LO を C2 で入れ、Q2 のベースは C9 で**交流的に GND** に落とす。
どちらのベースも 10 kΩ の 2 本で 2.5 V に置く (左右の分圧は同じ値)。
2 本のコレクタの負荷は PNP のカレントミラー (Q4・Q5、エミッタに 220 Ω ずつ)。Q4 はベースとコレクタをつないだ側で、Q1 の電流を受ける。
ミラーの出力 (Q2・Q5 のコレクタ) は RBT・RBB (15 kΩ・27 kΩ) で直流 3.2 V に置き、CT (100 nF) の先の LT・CTK (220 µH・560 pF、約 454 kHz) で 455 kHz 以外を GND へ逃がす。
C4 から先 (R7・FL1・C5・L2) は 4-1 と同じ。青い数字は解析で求めた動作点と信号の大きさ。

### 4 つの工夫

- **左右の部品の値を揃える。** Q1 と Q2 のベースの分圧 (10 kΩ ずつ)、ミラーのエミッタの 220 Ω (RM1・RM2) は、**同じ値の 2 本**にする。
  RM1・RM2 は 1 % の品にする: 片方が 4.5 % ずれる (220 Ω と 230 Ω) と、打ち消しが −36 dB から −32 dB に浅くなる (解析)
- **ミラーのエミッタに 220 Ω を入れる。** 2SA1015 の 2 本の V<sub>BE</sub> の違いを抑える。Q5 の大きさを 5 % 変えても、利得と打ち消しは変わらなかった (解析)
- **ミラーの出力は直流を抵抗の分圧で決める。** ミラーの出力は高インピーダンスなので、置き場所を決めないと Q2 か Q5 が飽和する。
  RBT・RBB の 3.2 V は、Q2 (尾が 1.9 V) と Q5 (エミッタが 4.9 V) のどちらにも 1 V 以上の余裕がある所
- **RE を分けて RF の利得を上げる。** 470 Ω のままだと変換利得が −15 dB しかない (上の比べ)。直流の電流を変えずに交流の負帰還だけを減らす

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| Q1, Q2, Q3 | 2SC1815 (GR か Y) | NPN。Q1・Q2 は **hFE ができるだけ近い 2 本** (同じ袋から選ぶ) |
| Q4, Q5 | 2SA1015 (GR か Y) | PNP。カレントミラー。同じ袋から選ぶ。ピンは 2SC1815 と同じく平らな面を手前にして左から E・C・B |
| R1 | 51 Ω | RF IN の 50 Ω 終端 (ポートに並列) |
| R3 | 51 Ω | LO IN の 50 Ω 終端 (ポートに並列) |
| RB1 | 82 kΩ | Q3 のベースの分圧 (上) |
| RB2 | 22 kΩ | Q3 のベースの分圧 (下) |
| RE1 | 47 Ω | Q3 のエミッタ (バイパスしない側)。RF の利得を決める |
| RE2 | 430 Ω | Q3 のエミッタ (CE でバイパスする側)。RE1 と合わせて電流を決める |
| CE | 1 µF | RE2 のバイパス (セラミック) |
| RL1, RL2 | 10 kΩ | Q1 のベースの分圧 (上・下)。2.5 V |
| RR1, RR2 | 10 kΩ | Q2 のベースの分圧 (上・下)。2.5 V |
| RM1, RM2 | 220 Ω | カレントミラーのエミッタ。**1 % の品で同じ値の 2 本** |
| RBT | 15 kΩ | ミラーの出力の直流の分圧 (上) |
| RBB | 27 kΩ | ミラーの出力の直流の分圧 (下)。3.2 V |
| CT | 100 nF | 同調回路の直流カット (セラミック) |
| LT | 220 µH | 455 kHz の同調 (CTK と並列。4-1 の L1 と同じ品) |
| CTK | 560 pF | 455 kHz の同調 (C0G / NP0) |
| R7 | 2 kΩ | セラミックフィルタ入力の終端 |
| R8 | 51 Ω | **計測用**。IF OUT の 50 Ω の負荷 (回路図の外。ブレッドボードの図にだけ付ける) |
| C1, C2 | 10 nF | RF と LO の DC カット (セラミック) |
| C4 | 10 nF | IF をフィルタへ (DC カット) |
| C5 | 1.2 nF | 出力整合 (シャント。C0G / NP0) |
| C9 | 100 nF | Q2 のベースを交流で GND に落とす (セラミック) |
| C6 | 100 nF | 電源のデカップリング (セラミック) |
| C7 | 10 µF 16 V | 電源のデカップリング (電解。+ を電源側に) |
| L2 | 100 µH | 出力整合 (直列) |
| FL1 | SFU455B (455 kHz セラミックフィルタ) | **入出力 1.5 kΩ の品** (3-1・4-1 と同じ) |
| 電源 | 5 V | 既定の電源 |

## 実体配線図

周波数は最大 2.055 MHz で、ブレッドボードの上限 (3 MHz) に収まる。電流は 1.5 mA ほど。
基板は `full` (63 列)。AD3 を下に置いて、電源・W1 (RF)・W2 (LO)・CH1 (IF OUT)・CH2 (ミラーの出力) をつなぐ。
トランジスタ 5 本は上半分 (c 行) に並べ、左から Q4 (PNP)・Q1・Q2・Q5 (PNP)・Q3。
**ミラーの 2 本 (Q4・Q5) のエミッタは上の + レールから 220 Ω で給電する** (上の + レールは 1 列の赤い線で下の + レールとつなぐ)。
Q2・Q5 は E・C・B を左右逆に挿し (平らな面を奥に)、左右対称にした。
455 kHz の同調回路 (CT・LT・CTK) は右上、フィルタから先 (C4・R7・FL1・C5・L2・R8) は右下に置く。

```breadboard
title: 図02 ブレッドボードに組む (AD3 の W1・W2・CH1・CH2 つき)
board: full
parts:
  Q4: transistor c4(E) c5(C) c6(B) 2SA1015
  Q1: transistor c9(B) c10(C) c11(E) 2SC1815
  Q2: transistor c15(E) c16(C) c17(B) 2SC1815
  Q5: transistor c20(B) c21(C) c22(E) 2SA1015
  Q3: transistor c29(B) c30(C) c31(E) 2SC1815
  RM1: resistor b2 b4 220
  RM2: resistor e22 e24 220
  R3: resistor h2 h4 51
  C2: capacitor/ceramic i2 i9 10n
  RL1: resistor g9 g6 10k
  RL2: resistor h9 h11 10k
  RR1: resistor g17 g15 10k
  RR2: resistor h17 h19 10k
  C9: capacitor/ceramic i17 i19 100n
  RBT: resistor g21 g23 15k
  RBB: resistor i21 i24 27k
  RB1: resistor g29 g26 82k
  RB2: resistor h29 h27 22k
  C1: capacitor/ceramic i29 i38 10n
  R1: resistor h38 h40 51
  RE1: resistor g31 g33 47
  RE2: resistor h33 h36 430
  CE: capacitor/ceramic f33 f36 1u
  C6: capacitor/ceramic g43 g46 100n
  C7: capacitor/electrolytic i43 i46 10u
  CT: capacitor/ceramic c47 c50 100n
  LT: inductor b50 b53 220u
  CTK: capacitor/ceramic d50 d53 560p
  C4: capacitor/ceramic i47 i51 10n
  R7: resistor g51 g49 2k
  FL1: sip3 @ f51 SFU455B
  C5: capacitor/ceramic i53 i55 1.2n
  L2: inductor h53 h58 100u
  R8: resistor g58 g60 51
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [W2, V+, GND, 2+, W1, 1+, 1-, 2-]
wires:
  - AD.V+ -- +b8 red
  - AD.GND -- -b10 black
  - +b1 -- +t1 red
  - +t2 -- a2 red
  - +t24 -- a24 red
  - -b4 -- j4 black
  - +b6 -- j6 red
  - -b11 -- j11 black
  - +b15 -- j15 red
  - -b19 -- j19 black
  - +b23 -- j23 red
  - -b24 -- j24 black
  - +b26 -- j26 red
  - -b27 -- j27 black
  - -b36 -- j36 black
  - -b40 -- j40 black
  - +b43 -- j43 red
  - -b46 -- j46 black
  - d5 -- d6 green
  - b6 -- b10 brown
  - a6 -- a20 green
  - d16 -- d21 brown
  - d11 -- d15 purple
  - b15 -- b30 purple
  - e9 -- f9 blue
  - e17 -- f17 blue
  - e21 -- f21 orange
  - e29 -- f29 blue
  - e31 -- f31 gray
  - a21 -- a47 orange
  - e47 -- f47 orange
  - -b63 -- -t63 black
  - -t53 -- a53 black
  - -b49 -- j49 black
  - -b52 -- j52 black
  - -b55 -- j55 black
  - -b60 -- j60 black
  - AD.W2 -- j2 green
  - AD.2+ -- j47 orange
  - AD.1+ -- j58 orange
  - AD.1- -- -b61 black
  - AD.2- -- -b62 black
  - AD.W1 -- j38 yellow
style:
  text-size: 10
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/breadboard/02-balanced.svg)

- 電源: AD3 の V+ (Supplies で 5 V) を赤で +b8 へ、GND を黒で -b10 へ。下の + レールは 1 列の赤い線で上の + レールへ、下の − レールは 63 列の黒い線で上の − レールへつなぐ
- 上の + レールから 2 列 (RM1) と 24 列 (RM2) へ赤で落とす。下の + レールは 6・15・23・26・43 列、− レールは 4・11・19・24・27・36・40・46・49・52・55・60 列から落とす
- Q4 (c4〜c6): C と B を緑の短い線 (d5〜d6) でつなぐ (ダイオードにする)。C は茶の線 (b6〜b10) で Q1 の C へ、B は緑の線 (a6〜a20) で Q5 の B へ
- Q1 (c9〜c11)・Q2 (c15〜c17): 2 つのエミッタは紫の線 (d11〜d15) でつなぎ、紫の線 (b15〜b30) で Q3 の C へ。Q1 の B (9 列) と Q2 の B (17 列) は青の線で下半分へ
- Q5 (c20〜c22): C (21 列) と Q2 の C (16 列) を茶の線 (d16〜d21) でつなぐ (**ミラーの出力**)。21 列は橙の線で下半分 (RBT・RBB) と、上の a 行を通って 47 列 (CT・C4) へ
- Q3 (c29〜c31): B は青の線で 29 列の下半分へ、E は灰色の線で 31 列の下半分へ。RE1 (31〜33 列)・RE2 (33〜36 列)・CE (f33〜f36)
- RF (黄): W1 を j38 へ。R1 (51 Ω) は 38 列から 40 列の GND へ。C1 は i 行の 38 列から 29 列 (Q3 のベース) へ
- LO (緑): W2 を j2 へ。R3 (51 Ω) は 2 列から 4 列の GND へ。C2 は i 行の 2 列から 9 列 (Q1 のベース) へ
- 出力 (橙): CH1 の 1+ を j58 (IF OUT、R8 の上) へ、CH2 の 2+ を j47 (ミラーの出力) へ。1− と 2− (黒) は -b61 と -b62 へ
- FL1 は f51 (IN)・f52 (GND)・f53 (OUT) に挿す。R8 (51 Ω) は IF OUT の 50 Ω の負荷 (AD3 の入力は 1 MΩ)。回路図の外の、計器の側の部品
- 配線図の抵抗の値は部品表と下の表で読む (図の字は重なりやすい)

部品の穴は次のとおり。

| 部品 | 穴 | 部品 | 穴 |
| --- | --- | --- | --- |
| Q4 | c4 (E) c5 (C) c6 (B) | RB1 82k | g26 / g29 |
| Q1 | c9 (B) c10 (C) c11 (E) | RB2 22k | h27 / h29 |
| Q2 | c15 (E) c16 (C) c17 (B) | C1 10n | i29 / i38 |
| Q5 | c20 (B) c21 (C) c22 (E) | R1 51 | h38 / h40 |
| Q3 | c29 (B) c30 (C) c31 (E) | RE1 47 | g31 / g33 |
| RM1 220 | b2 / b4 | RE2 430 | h33 / h36 |
| RM2 220 | e22 / e24 | CE 1u | f33 / f36 |
| R3 51 | h2 / h4 | C6 100n | g43 / g46 |
| C2 10n | i2 / i9 | C7 10u | i43 (+) / i46 (−) |
| RL1 10k | g6 / g9 | CT 100n | c47 / c50 |
| RL2 10k | h9 / h11 | LT 220u | b50 / b53 |
| RR1 10k | g15 / g17 | CTK 560p | d50 / d53 |
| RR2 10k | h17 / h19 | C4 10n | i47 / i51 |
| C9 100n | i17 / i19 | R7 2k | g49 / g51 |
| RBT 15k | g21 / g23 | FL1 | f51 (IN) f52 (GND) f53 (OUT) |
| RBB 27k | i21 / i24 | C5 1.2n | i53 / i55 |
| | | L2 100u | h53 / h58 |
| | | R8 51 | g58 / g60 |

## 計器の設定 (Analog Discovery 3)

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない)。電源を入れてから Wavegen を出す |
| Wavegen W1 (RF) | Sine、1.000 MHz、振幅 32 mV (−20 dBm)、オフセット 0 V。合ったら 10 mV (−30 dBm) にする |
| Wavegen W2 (LO) | Sine、1.455 MHz、振幅 0.32 V (0 dBm)、オフセット 0 V |
| Scope CH1 | 1+ = IF OUT (R8 の上)、1− = GND。IF を読む |
| Scope CH2 | 2+ = ミラーの出力 (Q2・Q5 のコレクタ)、2− = GND。**フィルタの前**で RF が消えているかを見る |
| Spectrum | 開始 0 Hz・終了 3 MHz、FFT 8192 点、窓は Flat Top、縦軸 dBV。CH2 (フィルタの前) と CH1 (IF OUT) を並べる |

- **CH2 を見るのが目的**。ミラーの出力で RF (1.000 MHz) が IF より 36 dB 低い。4-1 のコレクタでは RF が IF より 7 dB 高かった
- 標本化は 3 MHz × 2.56 = 7.7 MHz、分解能は 7.7 MHz ÷ 8192 ≈ 0.94 kHz。IF (455 kHz)・RF・LO・和 (2.455 MHz) は十分に分かれる
- Spectrum の縦軸 dBV は実効値。波高値 197 mV の IF は −17.1 dBV (実効値 139 mV)
- W1 と W2 は別々に周波数を決める。LO は RF + 455 kHz に**自分で合わせる**
- CH2 のプローブ (AD3 の入力 1 MΩ・約 24 pF) はミラーの出力に容量として掛かるが、同調回路の 560 pF に比べて小さい (未確認。外して比べるとよい)

## 想定する電圧

### 直流 (解析の動作点)

| 場所 | 電圧 | 備考 |
| --- | --- | --- |
| VDD | 5.00 V | |
| Q3 のベース / エミッタ | 1.00 V / 0.37 V | IC = 0.79 mA (RE1 と RE2 の間は 0.33 V) |
| 尾 (Q1・Q2 のエミッタ) | 1.88 V | |
| Q1・Q2 のベース | 2.49 V | 10 kΩ ずつの分圧 |
| Q1 のコレクタ (Q4 の C・B) | 4.30 V | Q4 の V<sub>EB</sub> と RM1 の降下で決まる |
| Q4・Q5 のエミッタ | 4.91 V | 0.39 mA × 220 Ω = 86 mV の降下 |
| ミラーの出力 (Q2・Q5 のコレクタ) | 3.23 V | RBT・RBB の分圧 (LO 0 dBm で 3.18 V) |
| 電源の電流 | 1.45 mA | 信号なし。分圧の 0.67 mA を含む |

### 交流 (RF −20 dBm・LO 0 dBm のとき)

| 成分 | ミラーの出力 (フィルタの前、CH2) | IF OUT (50 Ω、CH1) |
| --- | --- | --- |
| IF 455 kHz | 197 mV<sub>p</sub> (−17.1 dBV) | 32 mV<sub>p</sub> (−32.8 dBV)。−19.8 dBm |
| LO 1.455 MHz | 206 mV<sub>p</sub> (−16.7 dBV) | フィルタで落ちる (下の注) |
| 和 2.455 MHz | 28 mV<sub>p</sub> (−34.1 dBV) | 同上 |
| RF 1.000 MHz | 3.1 mV<sub>p</sub> (−53.2 dBV) | 同上 |

IF OUT の LO・RF・和は、モデルのフィルタ (理想の LC 梯子) では −120 dBm より低く出る。実物のセラミックフィルタの阻止域は数十 dB のはずで (未確認)、
4-1 と同じく 30 dB を仮定すると、LO は IF OUT で約 −80 dBV より低い。

## 調整

1. RF と LO を入れずに、**ミラーの出力が約 3.2 V** かを見る。2.5 V より低ければ Q5 の側、4.3 V より高ければ Q2 の側が強い。RM1・RM2 と Q4・Q5 の組を入れ替えて合わせる。Q3 の IC は RB2 で合わせる (0.79 mA の目安。エミッタ 0.37 V)
2. W2 (LO) だけを 0 dBm で入れ、CH2 (ミラーの出力) に 1.455 MHz の LO が −17 dBV 前後で出ることを見る
3. W1 (RF) を −20 dBm で足し、CH2 で IF (455 kHz) が LO と同じくらいの高さに立ち、**RF (1.000 MHz) が IF より 36 dB 低い**ことを見る
4. CH1 (IF OUT) で 455 kHz が −32.8 dBV (RF −20 dBm) かを見る。LO を −10 dBm から +7 dBm まで動かし、利得がほとんど変わらないことを確かめる

## 計器の画面

計算値。[sim/diff_output.py](sim/diff_output.py) の解析 (RF 1.000 MHz −20 dBm・LO 1.455 MHz 0 dBm) による。

```spectrum
title: 図03 ミラーの出力 (フィルタの前、CH2) のスペクトル (RF −20 dBm、LO 0 dBm)
device: ad3
sweep: 0-3MHz
samples: 8192
window: flattop
unit: dBV
ref: 0dBV
signal:
  - sine 455kHz 197mV
  - sine 1.455MHz 206mV
  - sine 2.455MHz 28mV
  - sine 1MHz 3.1mV
markers: [455k, 1M, 1.455M, 2.455M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/spectrum/02-balanced-1.svg)

- IF (455 kHz) と LO (1.455 MHz) が −17 dBV 前後で並ぶ。**RF (1.000 MHz) は −53.2 dBV** で、IF より 36 dB 低い (打ち消される)
- 和 (2.455 MHz) は −34.1 dBV。同調回路 (約 454 kHz) が 455 kHz 以外を GND へ逃がすので、IF より 17 dB 低い
- LO が消えないのはシングルバランスだから (上の説明)。フィルタの後ろでは IF だけが残る (図 04)

```spectrum
title: 図04 IF OUT (CH1、R8 51 Ω の上) のスペクトル (同じ条件)
device: ad3
sweep: 0-3MHz
samples: 8192
window: flattop
unit: dBV
ref: -20dBV
signal:
  - sine 455kHz 32mV
markers: [455k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/04-mixer-2sc1815/spectrum/02-balanced-2.svg)

- IF だけが −32.8 dBV で立つ。RF −20 dBm から見て **+0.2 dB の変換利得**
- LO・RF・和はフィルタの阻止域の深さで決まる。モデルでは見えない高さで、図には描いていない (実物では数十 dB 下に見えるはず。未確認)

## 見るべき値

RF −30 dBm・LO 0 dBm のとき、IF OUT は 10.4 mV<sub>p</sub> (−29.7 dBm、−42.7 dBV)。**変換利得 +0.3 dB** (50 Ω の負荷の電力 ÷ RF の有能電力)。
図 03・04 のとおりに AD3 で測る。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 | 455 kHz (LO − RF) |
| IF の大きさ (IF OUT、RF −30 dBm) | 10.4 mV<sub>p</sub> (−42.7 dBV)。利得 +0.3 dB |
| IF の大きさ (IF OUT、RF −20 dBm) | 32 mV<sub>p</sub> (−32.8 dBV)。利得 +0.2 dB |
| RF の漏れ (ミラーの出力) | IF より **36 dB** 低い (RF −40〜0 dBm で 33〜37 dB) |
| LO の漏れ (ミラーの出力) | **消えない**。RF −30 dBm で IF より 10 dB 高い |
| LO を −10 dBm | 利得 −0.8 dB (0 dBm より 1.1 dB 低い)。打ち消しは 35 dB |
| LO を +7 dBm・+16 dBm | 利得 +0.4・+0.5 dB。打ち消しは 36 dB のまま |
| LO の源を 50 Ω の発振器に | 利得は同じ (+0.3 dB)。LO は 10 kΩ の分圧のベースに入るので、源のインピーダンスに依らない |
| RF を 0.53〜1.6 MHz (LO は追従) | 利得 +0.3〜+0.4 dB (平ら) |
| RF を −15 dBm | 利得 −0.2 dB (圧縮が始まる)。−10 dBm で −1.4 dB |
| LO を止める | IF と和が消える (混ぜる相手が無い) |

## 注意

- 打ち消しの深さ (36 dB) は、**左右が全く同じ**モデルで解析した値で、実物より深い。実物は hFE・V<sub>BE</sub>・抵抗のばらつきで 20〜30 dB 止まりが普通 (見込み。未確認)。
  解析では RM2 を 4.5 % 大きくすると 32 dB に浅くなった。Q1・Q2、Q4・Q5 は同じ袋から選び、RM1・RM2 は 1 % の品にする
- **LO は消えない。** RF だけが消える側のシングルバランス。同調回路とフィルタで落とす
- 元の版 (2 本のコレクタに 3.3 kΩ ずつ、差を Scope の差動入力で見る) は、電圧の比で +12.1 dB と大きく見えたが、出力が 50 Ω でなく、同じ出力回路では −20 dB 台だった (4-3)。
  その解析は [sim/main.py](sim/main.py)・[sim/diff_resistive.cir](sim/diff_resistive.cir) に残した
- RE を分けたので、RF の入力 1 dB 圧縮点は約 −13 dBm に下がった (1 石の 4-1 と同じくらい)。強い放送局の近くでは RF の前に減衰器か同調回路を置く

## 出典

- [9-12 バランスドミキサー](../../01-circuits/09-rf/12-balanced-mixer.md) — 掛け算・スイッチ・ダブルバランスの説明 (この題はシングルバランス)
- [2-7 カレントミラー](../../01-circuits/02-transistors/07-current-mirror.md) — ミラーの働き (NPN の例)
- 2SC1815・2SA1015 の電気的特性は一般に知られた目安 (データシートの本文は直接読んでいない)
- 回路は 4-1 の 2SC1815 の 1 石ミキサーと、一般に知られた差動対ミキサー (ギルバートセルの半分) とカレントミラーの能動負荷を組み合わせて描き起こした
