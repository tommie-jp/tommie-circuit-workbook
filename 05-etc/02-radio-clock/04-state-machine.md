---
book: etc
chapter: 2
id: 2-4
title: 時報の状態遷移 — 440 Hz を 3 回数えて 880 Hz で正時パルス
tier: 200
source: 自作
board: [BB, PF]
---

# 2-4 時報の状態遷移 — 440 Hz を 3 回数えて 880 Hz で正時パルス

> [!WARNING]
> **この題の実体配線図 (ブレッドボードとユニバーサル基板) は、まだ実際の回路で検証していない。** 配線は回路図のつながりを写し、check のネットリストで突き合わせたもので、組んで確かめてはいない。数値 (タイミング) も計算とシミュレーションで作ったもので、正しく動くかどうかは確実ではない。

全体の中の位置は [01-block.md](01-block.md) の ③ 状態遷移。T440 が 1 秒おきに 3 回来たあとに
T880 が来たら、正時パルスを 1 つ出す。

## ブロック図

```plantuml
@startuml
top to bottom direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}

rectangle "T440 / T880\n(03 から、非同期の H / L)" as IN #FDECEA
rectangle "同期とエッジ検出\n8 Hz で標本化し、立ち上がりを\n1 クロックのパルス E440 / E880 にする" as SYNC #E6F4EA
rectangle "間隔タイマ\n8 Hz を数える 4 ビット\nE440 のたびに数え直す\n窓 W (次の音を待つ時間) と\n時間切れ TO を作る" as TMR #E6F4EA
rectangle "状態レジスタ ST\n0 〜 3 の 2 ビット\nE440 / E880 / W / TO で動く" as FSM #E6F4EA
rectangle "出力\nS3 のあいだの E880 かつ W" as OUT #E6F4EA
rectangle "正時パルス\n(H 1 パルス)" as PULSE #FFF8E1
rectangle "8 Hz クロック\n(05 の分周器)" as CLK #F3E5F5

IN --> SYNC
CLK --> SYNC
CLK --> TMR
CLK --> FSM
SYNC --> TMR : E440
SYNC --> FSM : E440 / E880
TMR --> FSM : W (窓) / TO (時間切れ)
FSM --> OUT : ST
SYNC --> OUT : E880
TMR --> OUT : W (窓)
OUT --> PULSE
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/plantuml/04-state-machine-1.svg)

入力は [03-detect.md](03-detect.md) の T440 と T880。出力は [05-clock.md](05-clock.md) の正時パルス。

図の信号の意味は、次のとおり。

| 信号 | 意味 |
| --- | --- |
| E440 | 440 Hz の音が**始まった**ことを知らせる、1 クロック (0.125 秒) のパルス |
| E880 | 880 Hz の音が**始まった**ことを知らせる、1 クロックのパルス |
| **W (窓)** | **「次の音が来てよい時間」のあいだだけ H になる信号。** 時報の予報音は 1 秒おきなので、前の E440 から約 1 秒 (0.875〜1.125 秒) のあいだだけ H になる。この時間の外に来た音は、時報の順番ではないとみなす |
| TO (時間切れ) | 前の E440 から 1.25 秒ほど待っても次の音が来なかったときに H になる。状態を待機 (S0) に戻す |
| ST (状態) | 0〜3 の数。予報音をここまで何回聞いたか (S0〜S3) を覚えている |

W は、「雑音や別の音を、時報と取り違えない」ための仕組みで、**1 秒の間隔を測る物差し**にあたる。W を H にするのは間隔タイマで、E440 が来るたびに数え直し、数が一定の範囲のときだけ H にする。

## 設計の方針

この回路は、**時間を状態と数に置き換える**。1 秒を測るのに、1 秒の単安定回路を使わず、一定の周期のクロックを数える。

- **クロックは 8 Hz**。05 の時計の分周器 (32.768 kHz ÷ 4096) の途中から取る (CD4040 の Q12)。1 クロックは 0.125 秒
- **T440 と T880 は、クロックと関係なく変わる**。D フリップフロップで 8 Hz に合わせて標本化し、もう 1 段遅らせて、立ち上がりだけを 1 クロックのパルス (E440、E880) にする
- **間隔タイマ**は、8 Hz を数える 4 ビットのカウンタ。E440 が来るたびに**値 2 を読み込む**。次の E440 までの数 (0.125 秒の何個ぶんか) を見る
- **窓 W**: 時報の予報音の間隔は 1 秒 (8 クロック)。標本化で ±1 クロックずれるので、間隔が 7〜9 クロック (0.875〜1.125 秒) のときだけ、順番どおりと認める。タイマの値で言えば 8、9、10 のとき (2 から数え始めるので、判定のゲートが少なくて済む)
- **時間切れ TO**: 数が 11 に達したら (間隔が 10 クロック以上)、順番が崩れたとして、状態を S0 に戻す
- **状態 ST**は、0〜3 の 2 ビット (S0〜S3)

## 状態の動き

| 状態 | 意味 |
| --- | --- |
| S0 | 待機 |
| S1 | 予報音 (440 Hz) を 1 回聞いた |
| S2 | 2 回聞いた |
| S3 | 3 回聞いた。880 Hz を待つ |

| イベント | 条件 | 動作 |
| --- | --- | --- |
| E440 | 状態が S1 か S2 で、**W が H** (窓のうち) | 状態を 1 つ進める。タイマを 2 から数え直す |
| E440 | 状態が S3 | **状態を S0 に戻す** (4 回目の 440 Hz は、時報の順番ではない) |
| E440 | 上以外。つまり、状態が S0、または S1 か S2 で **W が L** (窓の外) | 状態を S1 にする (数え直す)。タイマを 2 から数え直す |
| E880 | 状態が S3 で、**W が H** (窓のうち) | **正時パルスを出す。状態を S0 に戻す** |
| E880 | 上以外。つまり、状態が S3 でない、または **W が L** (窓の外) | 状態を S0 に戻す |
| 時間切れ TO | タイマの数が 11 | 状態を S0 に戻す |
| 電源投入 | — | 状態を S0 にする |

**「窓の外」とは、「W でない」(W の否定、W が L のとき) のことだ。** 状態遷移図では「W でない」と書き、日本語では「窓の外」と呼ぶ。W が H のあいだが「窓のうち」で、それ以外が「窓の外」になる。

| 言い方 | 意味 | W の値 |
| --- | --- | --- |
| 窓のうち (W) | 前の音から約 1 秒 (0.875〜1.125 秒) 後 | H |
| 窓の外 (W でない) | 早すぎる (0.875 秒より前) か、遅すぎる (1.125 秒より後) | L |

窓の外の E440 は、S0 ではなく **S1 (数え直し)** にする。雑音の音が先に来たあとに、本物の時報が続いても拾えるようにするためだ。ただし、S3 に来た E440 は、順番にない音なので S0 に戻す。

```plantuml
@startuml
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
hide empty description
[*] --> S0
S0 --> S1 : E440
S1 --> S2 : E440 かつ W
S2 --> S3 : E440 かつ W
S3 --> S0 : E880 かつ W\n(正時パルス)
S1 --> S1 : E440 かつ W でない\n(窓の外)
S2 --> S1 : E440 かつ W でない\n(窓の外)
S1 --> S0 : TO、または E880
S2 --> S0 : TO、または E880
S3 --> S0 : TO、E440、または\nE880 かつ W でない (窓の外)
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/plantuml/04-state-machine-2.svg)

## タイミング (設計の計算値)

ふつうの時報を入れたときの様子を、設計から**計算で出した**。440 Hz が 0.04 秒、1.04 秒、2.04 秒に立ち上がり、880 Hz が 3.04 秒に立ち上がる。実機の波形ではない。TM は間隔タイマの数、ST は状態。

```logic
title: 図1 440 Hz を 3 回数えて 880 Hz で正時パルスが出る (計算)
device: ad3
window: 4s
sample: 1kHz
signals:
  CLK: dio0 clock 8Hz
  T440: dio1 edges 0s=0 40ms=1 240ms=0 1.04s=1 1.24s=0 2.04s=1 2.24s=0
  T880: dio2 edges 0s=0 3.04s=1
  TM: dio3..dio6 counter on CLK rising sequence 1 2 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0
  ST: dio7..dio8 counter on CLK rising sequence 0 0 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 0 0 0 0 0 0 0
  OUT: dio9 edges 0s=0 3.125s=1 3.25s=0
buses:
  Timer: TM3..TM0 dec
  State: ST1..ST0 dec
cursors: [1.09375s, 3.21875s]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/logic/04-state-machine-1.svg)

- 1 回目の E440 (0.125〜0.25 秒) で ST が 1 になり、タイマが 2 から数え始める。2 回目、3 回目も同じ間隔 (タイマは 9 まで数えて次の E440) で進み、**ST が 3 になる (2.25 秒)**
- カーソル X1 (1.094 秒) は、1 回目と 2 回目の E440 のあいだ (Timer 8、State 1)。X2 (3.219 秒) は、E880 のあいだ (Timer 9、State 3、OUT が H)
- 880 Hz の E880 (3.125〜3.25 秒) が、ST = 3 のあいだ、窓の中 (タイマ 9) で来るので、**OUT に 1 クロック (0.125 秒) のパルスが出て、ST が 0 に戻る (3.25 秒)**

### 順番が崩れたときの動き

正しい時報のほかに、**パルスを出してはいけない場合**の動きも見る。いずれも計算で、実機の波形ではない。

```logic
title: 図2 440 Hz が 4 回続くと、4 回目で待機に戻り、正時パルスは出ない (計算)
device: ad3
window: 5s
sample: 1kHz
signals:
  CLK: dio0 clock 8Hz
  T440: dio1 edges 0s=0 40ms=1 240ms=0 1.04s=1 1.24s=0 2.04s=1 2.24s=0 3.04s=1 3.24s=0
  T880: dio2 edges 0s=0 4.04s=1
  TM: dio3..dio6 counter on CLK rising sequence 1 2 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0
  ST: dio7..dio8 counter on CLK rising sequence 0 0 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  OUT: dio9 low
buses:
  Timer: TM3..TM0 dec
  State: ST1..ST0 dec
cursors: [3.1875s, 4.1875s]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/logic/04-state-machine-2.svg)

| 見る所 | 読み値 | 意味 |
| --- | --- | --- |
| カーソル X1 (3.1875 秒) | Timer 9、State 3、T440 が H | 4 回目の 440 Hz が来ている。まだ S3 のまま |
| State の変わり目 | 0 → 1 (0.25 秒)、2 (1.25 秒)、3 (2.25 秒)、0 (3.25 秒) | 4 回目の E440 の次のクロックで S0 に戻る |
| カーソル X2 (4.1875 秒) | Timer 9、State 0、T880 が H、OUT 0 | 880 Hz が来たときは S0 なので、パルスは出ない |
| OUT の変わり目 | 0 | 正時パルスは出ない |

```logic
title: 図3 2 回目の音が 1.5 秒後に遅れると、時間切れで戻り、数え直しになる (計算)
device: ad3
window: 4.5s
sample: 1kHz
signals:
  CLK: dio0 clock 8Hz
  T440: dio1 edges 0s=0 40ms=1 240ms=0 1.54s=1 1.74s=0 2.54s=1 2.74s=0
  T880: dio2 edges 0s=0 3.54s=1 3.74s=0
  TM: dio3..dio6 counter on CLK rising sequence 1 2 2 3 4 5 6 7 8 9 10 11 12 13 2 3 4 5 6 7 8 9 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0
  ST: dio7..dio8 counter on CLK rising sequence 0 0 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 0 0 0 0 0 0 0
  OUT: dio9 low
buses:
  Timer: TM3..TM0 dec
  State: ST1..ST0 dec
cursors: [1.4375s, 3.6875s]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/logic/04-state-machine-3.svg)

| 見る所 | 読み値 | 意味 |
| --- | --- | --- |
| カーソル X1 (1.4375 秒) | Timer 11、State 1 | 1 回目の音から 11 クロック待った。時間切れ (TO) の瞬間 |
| State の変わり目 | 1 (0.25 秒)、0 (1.5 秒)、1 (1.75 秒)、2 (2.75 秒)、0 (3.75 秒) | 時間切れで S0 に戻り、遅れた音から S1 で数え直す |
| カーソル X2 (3.6875 秒) | Timer 9、State 2、T880 が H、OUT 0 | 数え直しの途中 (S2) で 880 Hz が来たので、パルスは出ない |
| OUT の変わり目 | 0 | 正時パルスは出ない |

この 2 つの動きは、次の「数値シミュレーション」の 4 回の 440 Hz と間隔の長い音の行に対応する。

**注意:** この計算は、T440 が約 0.2 秒 H になると置いている。[03-detect.md](03-detect.md) の計算では、
約 0.1 秒の音で T440 が H になるのは約 0.11 秒で、8 Hz の標本化の周期 (0.125 秒) より短い。
標本化の瞬間が H の外に当たると、音を取りこぼす。03 の R<sub>p</sub> や TH を見直して、H を 0.125 秒より十分長くしてから使う。

## 数値シミュレーション

この設計を、プログラム (Python) で、フリップフロップとカウンタの動きとして模して確かめた。**回路を作って測ったものではない。**

| 確かめたこと | 結果 |
| --- | --- |
| 時報が入る位相をずらして 25 通り (0〜0.125 秒) | すべて、正時パルスが 1 つだけ出る |
| 4 つの立ち上がりが、1 秒の位置から ±30 ms ずれる (4000 回) | 失敗 0 回 |
| 同じ、±100 ms ずれる (4000 回) | 失敗 270 回 (約 6.8 %) |
| 間隔が 0.5、0.6、0.7、1.3、1.5、2 秒の 440 Hz が 3 回、そのあと 880 Hz (各 500 回) | 正時パルスを出さなかった (500 回すべて) |
| 440 Hz が 1 秒おきに **4 回**、そのあと 880 Hz (500 回) | 正時パルスを出さなかった (500 回すべて) |

- 窓は ±1 クロック (±125 ms) までしか許さないので、立ち上がりが ±100 ms 以上ずれると、標本化のずれと合わさって外れることがある
- 放送の時報の間隔は正確に 1 秒なので、通常は受信側の検出の遅れのばらつき (数十 ms) が問題になる

## 回路図

回路は **4 つのユニット**に分ける。1 つのユニットは IC が 4 個以内で、フルサイズのブレッドボード 1 枚に載る大きさにした (ユニバーサル基板の大きさは「実体配線図」に書く)。ユニットの間は、同じ名前の端子どうしを線でつなぐ。

| ユニット | 役目 | IC | 入力 | 出力 |
| --- | --- | --- | --- | --- |
| 1 同期とエッジ検出 | T440・T880 を 8 Hz で標本化し、立ち上がりを 1 クロックのパルスにする | U5・U6 (74HC74)、U7 (74HC04)、U8 (74HC08) | T440、T880、CLK | E440、NE440 (E440 の反転)、E880 |
| 2 間隔タイマと窓 | E440 から次の E440 までを 8 Hz で数え、窓 W と時間切れ TO を作る | U9 (74HC163)、U10 (74HC08)、U11 (74HC02) | NE440、CLK | W、TO |
| 3 状態を動かす条件 | イベントと窓から、状態レジスタへの命令を作る | U12 (74HC86)、U13 (74HC08)、U14 (74HC32)、U15 (74HC02) | QA、QB、S3、W、TO、NE440、E440、E880、PON | LOADN、EN、CLRN |
| 4 状態レジスタと出力 | 状態 ST (QA・QB) を持ち、正時パルス OUT を出す | U16 (74HC163)、U17 (74HC08) | LOADN、EN、CLRN、CLK、E880、W | QA、QB、S3、OUT |

- CLK は 8 Hz のクロック、PON は電源投入のとき H になる信号 ([05-clock.md](05-clock.md) の電源投入のリセット)
- NE440 と LOADN、CLRN は、**L のとき働く**信号 (N は反転の印)
- すべての IC の電源は 5 V。IC の電源のピン (74HC74、74HC08 などの PIN 14、74HC163 の PIN 16) は +5V、GND のピン (PIN 7、74HC163 の PIN 8) は GND
- ゲートのピンの番号は、74HC74、74HC04、74HC08、74HC86、74HC32、74HC02 の使うゲートの番号を図に書いた (使わないゲートの入力は GND につなぐ)

### ユニット 1: 同期とエッジ検出

```circuit
title: 図4 同期とエッジ検出 (ユニット 1)
parts:
  T440: port d2
  T880: port j2
  CLK: port f2
  U5A:
    type: ic3
    at: d7
    label: 74HC74
    pins: [D, CLK, Q]
  U5B:
    type: ic3
    at: d15
    label: 74HC74
    pins: [D, CLK, Q]
  U6A:
    type: ic3
    at: j7
    label: 74HC74
    pins: [D, CLK, Q]
  U6B:
    type: ic3
    at: j15
    label: 74HC74
    pins: [D, CLK, Q]
  U7A: not d20
  U8A: and d25
  U7C: not d30
  U7B: not j20
  U8B: and j25
  E440: port b33
  NE440: port d37
  E880: port j33
wires:
  - d2 -- U5A.D
  - U5A.Q -- d11 -- U5B.D
  - d11 -- b11 -- b23
  - b23 |- U8A.a
  - U5B.Q -- U7A.in
  - U7A.out -| U8A.b
  - U8A.out -- d28 -- U7C.in
  - d28 -- b28 -- b33
  - U7C.out -- d37
  - j2 -- U6A.D
  - U6A.Q -- j11 -- U6B.D
  - j11 -- h11 -- h23
  - h23 |- U8B.a
  - U6B.Q -- U7B.in
  - U7B.out -| U8B.b
  - U8B.out -- j33
  - f2 -- f4 -- f7 -- f15
  - U5A.CLK -- f7
  - U5B.CLK -- f15
  - f4 -- l4 -- l7 -- l15
  - U6A.CLK -- l7
  - U6B.CLK -- l15
notes:
  - text c19g4 tiny center: "1"
  - text c20g6 tiny center: "2"
  - text c24f1 tiny center: "1"
  - text d24g1 tiny center: "2"
  - text c25g7 tiny center: "3"
  - text c29g4 tiny center: "5"
  - text c30g6 tiny center: "6"
  - text i19g4 tiny center: "3"
  - text i20g6 tiny center: "4"
  - text i24e1 tiny center: "4"
  - text j24g1 tiny center: "5"
  - text i25g7 tiny center: "6"
  - text c5g7 tiny center: "2"
  - text c8g3 tiny center: "5"
  - text d7j3 tiny center: "3"
  - text c13g7 tiny center: "12"
  - text c16g3 tiny center: "9"
  - text d15j3 tiny center: "11"
  - text i5g7 tiny center: "2"
  - text i8g3 tiny center: "5"
  - text j7j3 tiny center: "3"
  - text i13g7 tiny center: "12"
  - text i16g3 tiny center: "9"
  - text j15j3 tiny center: "11"
  - text a2 small left: 74HC74 は 2 個。PIN 14 は +5V、PIN 7 は GND、PIN 1・4・10・13 は +5V
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/04-state-machine-1.svg)

- T440 と T880 は、クロックと関係なく変わる。D フリップフロップ 2 段 (U5A→U5B、U6A→U6B) で 8 Hz に合わせ、1 段目の出力 (T4s) と 2 段目の出力 (T4d) の**差**で立ち上がりを見つける
- E440 は T4s かつ「T4d の反転」で、1 クロックの H パルス。NE440 はその反転で、ユニット 2 とユニット 3 が使う

### ユニット 2: 間隔タイマと窓

```circuit
title: 図5 間隔タイマと窓 (ユニット 2)
parts:
  NE440: port a3
  CLK: port f3f0
  U9: ic e10 74HC163
  VCC1: vcc b10 5V
  GND1: ground h10
  U10A: and d20
  U11A: nor e26
  U10C: and c32
  U10B: and g32
  W: port g38
  TO: port c38
wires:
  - a3 -| U9.LOAD
  - f3f0 |- U9.CLK
  - U9.VCC |- b10
  - U9.CLR |- b10
  - U9.GND |- h10
  - U9.A |- c5f0
  - U9.B |- d5
  - U9.C |- d5f0
  - U9.D |- e5
  - U9.ENP |- e5f0
  - U9.ENT |- f5
  - U9.QA |- U10A.a
  - U9.QB -| U10A.b
  - U10A.out -- d23
  - d23 -| U11A.a
  - U9.QC |- e24 -| U11A.b
  - d23 -- d28 -- c28
  - c28 |- U10C.a
  - U9.QD |- e30f0
  - e30f0 |- U10C.b
  - e30f0 |- U10B.a
  - U11A.out -- e28 |- U10B.b
  - U10C.out -- c38
  - U10B.out -- g38
notes:
  - text c4f0 tiny right: GND
  - text d4 tiny right: +5V
  - text d4f0 tiny right: GND
  - text e4 tiny right: GND
  - text e4f0 tiny right: +5V
  - text f4 tiny right: +5V
  - text i3 small left: B だけ +5V で、E440 のたびに値 2 を読み込む
  - text c18f9 tiny center: "1"
  - text d18g9 tiny center: "2"
  - text c20g7 tiny center: "3"
  - text b30e9 tiny center: "9"
  - text c30g9 tiny center: "10"
  - text b32g7 tiny center: "8"
  - text f30f9 tiny center: "4"
  - text g30g9 tiny center: "5"
  - text f32g7 tiny center: "6"
  - text d24f9 tiny center: "2"
  - text e24g9 tiny center: "3"
  - text d26g7 tiny center: "1"
style:
  grid: on
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/04-state-machine-2.svg)

- 74HC163 (U9) は 4 ビットのカウンタ。LOAD は L のとき働く (NE440 を入れる)。**E440 のクロックの立ち上がりで、データ入力 (B = 1、A・C・D = 0、つまり値 2) を読み込む**。ほかのときは 8 Hz を数える
- m = QA かつ QB (U10A)。k = QC も m も 0 (U11A)。**W = QD かつ k** (U10B)。数が 8、9、10 のとき W が H になる
- **TO = m かつ QD** (U10C)。数が 11 になると H になる

### ユニット 3: 状態を動かす条件

```circuit
title: 図6 状態を動かす条件 (ユニット 3)
parts:
  W: port a2
  QA: port b2
  QB: port d2
  NE440: port e2
  E440: port g2
  E880: port j2
  TO: port l2
  S3: port n2
  PON: port q2
  U12A: xor c9
  U13A: and c18
  U14A: or f26
  U13B: and h26
  U14B: or k9
  U13C: and o14
  U14C: or m21
  U15A: nor q27
  LOADN: port f31
  EN: port h31
  CLRN: port q31
wires:
  - b2 |- U12A.a
  - d2 |- U12A.b
  - U12A.out -- c12 -| U13A.b
  - a2 -- a15 |- U13A.a
  - U13A.out -- c21
  - c21 |- U14A.b
  - c21 |- U13B.b
  - e2 |- U14A.a
  - g2 -- g6
  - g6 |- U13B.a
  - g6 |- U13C.b
  - j2 |- U14B.a
  - l2 |- U14B.b
  - U14B.out -| U14C.a
  - n2 |- U13C.a
  - U13C.out -- o18 |- U14C.b
  - U14C.out -| U15A.a
  - q2 |- U15A.b
  - U14A.out -- f31
  - U13B.out -- h31
  - U15A.out -- q31
notes:
  - text b7e8 tiny center: "1"
  - text c7g8 tiny center: "2"
  - text b9g7 tiny center: "3"
  - text b16e9 tiny center: "1"
  - text c16g9 tiny center: "2"
  - text b18g7 tiny center: "3"
  - text e24f9 tiny center: "1"
  - text f24g9 tiny center: "2"
  - text e26g7 tiny center: "3"
  - text g24f9 tiny center: "4"
  - text h24g9 tiny center: "5"
  - text g26g7 tiny center: "6"
  - text j7e8 tiny center: "4"
  - text k7g8 tiny center: "5"
  - text j9g7 tiny center: "6"
  - text n12e8 tiny center: "9"
  - text o12g8 tiny center: "10"
  - text n14g7 tiny center: "8"
  - text l19e9 tiny center: "9"
  - text m19g9 tiny center: "10"
  - text l21g7 tiny center: "8"
  - text p25e9 tiny center: "2"
  - text q25g9 tiny center: "3"
  - text p27g7 tiny center: "1"
  - text s9 small left: 74HC86、74HC08、74HC32、74HC02 は PIN 14 が +5V、PIN 7 が GND
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/04-state-machine-3.svg)

- x = QA と QB が違う (U12A) は、状態が S1 か S2 であること。ADV = W かつ x (U13A) は、「窓のうちで、状態を 1 つ進めてよい」
- LOADN = NE440 または ADV (U14A)。L のとき、状態レジスタに値 1 (S1) を読み込む。E440 で、ADV でないときだけ L になる
- EN = E440 かつ ADV (U13B)。H のとき、状態レジスタを 1 つ進める
- CLRN = NOT (E880 または TO または (S3 かつ E440) または PON)。U14B (E880 または TO)、U13C (S3 かつ E440)、U14C (OR)、U15A (NOR) で作る。L のとき、状態を 0 に戻す。**S3 かつ E440** は、状態が S3 のあいだに来た E440 (4 回目の 440 Hz) で、順番にない音として S0 に戻す

### ユニット 4: 状態レジスタと出力

```circuit
title: 図7 状態レジスタと出力 (ユニット 4)
parts:
  LOADN: port a3
  CLRN: port b3
  EN: port e3f0
  CLK: port f3f0
  U16: ic e12 74HC163
  GND1: ground h12
  U17A: and d22
  U17B: and g22
  U17C: and e32
  E880: port g18
  W: port h18
  OUT: port e38
  QA: port b38
  QB: port i38f0
  S3: port c38
wires:
  - a3 -| U16.LOAD
  - b3 -| U16.CLR
  - U16.VCC |- c5
  - U16.GND |- h12
  - f3f0 -| U16.CLK
  - e3f0 -- e7f0
  - e7f0 |- U16.ENP
  - e7f0 |- U16.ENT
  - U16.A |- c5f0
  - U16.B |- d5
  - U16.C |- d5f0
  - U16.D |- e5
  - U16.QA |- d16
  - d16 |- U17A.a
  - d16 -- b16 -- b38
  - U16.QB |- d16f0
  - d16f0 -| U17A.b
  - d16f0 -- i16f0 -- i38f0
  - g18 |- U17B.a
  - h18 |- U17B.b
  - U17A.out -- d24
  - d24 -- d28 |- U17C.a
  - d24 -- c24 -- c38
  - U17B.out -- g28 |- U17C.b
  - U17C.out -- e38
notes:
  - text c4f0 tiny right: +5V
  - text d4 tiny right: GND
  - text d4f0 tiny right: GND
  - text e4 tiny right: GND
  - text c4 tiny right: +5V
  - text k3 small left: 74HC163 は E440 のたびに値 1 (A だけ +5V) を読み込む
  - text c20f9 tiny center: "1"
  - text d20g9 tiny center: "2"
  - text c22g7 tiny center: "3"
  - text f20f9 tiny center: "4"
  - text g20g9 tiny center: "5"
  - text f22g7 tiny center: "6"
  - text d30f9 tiny center: "9"
  - text e30g9 tiny center: "10"
  - text d32g7 tiny center: "8"
  - text j9 small left: 74HC08 は PIN 14 が +5V、PIN 7 が GND
style:
  grid: on
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/04-state-machine-4.svg)

- 74HC163 (U16) は状態 ST の 2 ビット (QA、QB)。CLRN (L で 0 に戻す)、LOADN (L で値 1 を読み込む)、EN (H で 1 つ進める) の順に優先される
- n1 = QA かつ QB (U17A) は「状態が S3」で、S3 としてユニット 3 にも出す。n2 = E880 かつ W (U17B)。**OUT = n1 かつ n2 (U17C)** が、正時パルス (1 クロックの H)
- QA と QB も、ユニット 3 に戻す

## 部品表

| 部品 | 個数 | 備考 |
| --- | --- | --- |
| 74HC74 | 2 | U5、U6 (D フリップフロップ 2 回路入り) |
| 74HC04 | 1 | U7 (インバータ 6 回路入りのうち 3 つを使う) |
| 74HC08 | 4 | U8、U10、U13、U17 (2 入力 AND、4 回路入り) |
| 74HC163 | 2 | U9 (間隔タイマ)、U16 (状態) |
| 74HC02 | 2 | U11、U15 (2 入力 NOR、4 回路入り) |
| 74HC86 | 1 | U12 (2 入力 XOR) |
| 74HC32 | 1 | U14 (2 入力 OR) |
| 0.1 µF のセラミックコンデンサ | 13 | IC ごとの電源のそば |
| 10 kΩ の抵抗 (1/4 W)・押しボタン (a 接点) | 各 1 | 試験用 (図12)。T880 のプルダウンと、T880 を H にするボタン |

IC は全部で 13 個。ユニットごとに 4 個以内なので、フルサイズのブレッドボード 1 枚に 1 ユニットを載せる。ユニバーサル基板には、ユニットごとに基板の大きさを変えて載せる (「実体配線図」)。

## 実体配線図

4 つのユニットを、フルサイズ (63 列) のブレッドボード 4 枚に 1 つずつ組む。**配線は、回路図 (図 4〜7) のピンのつながりをそのまま基板に写したもの**で、check のネットリストを回路図と突き合わせて確かめた。
基板の間は、同じ名前の端子どうしを線でつなぐ。電源 (5 V) と GND は 4 枚で共通にする。

- 線の色は、赤が + だけ、黒が GND だけ、黄が CLK、橙が基板の外とやりとりする信号、緑が基板の中の信号。
- 各 IC のそばに 0.1 µF を 1 個ずつ、上の + レールと − レールのあいだに入れる。
- 使わないゲートの入力は、GND に落とす。74HC74 の使わない PRE と CLR (PIN 1、4、10、13) は +5V に上げる。どちらも、レールからの線で描いてある。
- フルサイズの基板は、レールが中央で切れていることがある。図の中央にあるレールの渡しの線 (赤と黒) は、そのためだ。
- 74HC74、74HC86、74HC02 は、図の道具がピンの名前の表を持たないので、ピンは番号だけで出る。ピンの名前は、各ユニットの回路図の PIN の番号と合わせて読む。
- 配線は多い。読めない所は、check のネットリスト (`breadboard-fence check`) で、ピンごとのつながりを確かめる。

基板の外とやりとりする端子は、次のとおり。上下の箱は、線の出る側を表す。

| ユニット | 基板 | 入力 | 出力 |
| --- | --- | --- | --- |
| 1 | 図 8、8b | T440、T880、CLK | E440、NE440、E880 |
| 2 | 図 9、9b | NE440、CLK | W、TO |
| 3 | 図 10、10b | W、QA、QB、NE440、E440、E880、TO、S3、PON | LOADN、EN、CLRN |
| 4 | 図 11、11b | LOADN、CLRN、EN、CLK、E880、W | QA、QB、S3、OUT |

同じ 4 つのユニットを、ユニバーサル基板にも組めるようにした。ブレッドボードの図 (図 8〜11) のすぐあとに、同じ回路の図 8b〜11b を置いた。

### ユニバーサル基板の図 (図 8b〜11b) の見方

- 図は部品面から見たもの。配線は半田面で行う。厚みと基材は書いていないので 1.6 mm の FR-4
- 基板は在庫の順 (5×7 → 7×9 → 9×15 cm) に、配置と配線が収まる最初の基板を選んだ。ユニット 4 は 5×7 cm (横置きの `7x5cm`)、ユニット 2 は 7×9 cm、ユニット 1 と 3 は 9×15 cm (横置きの `15x9cm`)。ユニット 2 は 5×7 cm に IC が載るが、電源とほかの線を通すと詰まって配線が収まらなかった。ユニット 1 と 3 は IC が 4 個で、7×9 cm でも線が絡み合って追えなくなったので、9×15 cm にした。無理に詰めず基板を大きくした
- 線の色は、赤が + だけ、黒が GND だけ、黄が CLK。ほかの信号線は、たどりやすいように色を変えただけで、色に意味はない
- 線どうしが交わる所は、図の半円のところで被覆線を渡す。裸の線を重ねない。交わる所は多いので、半田付けの前に、1 本ずつ check のネットリストと照らして進める
- 各 IC のそばに 0.1 µF を 1 個ずつ、電源 (+) と GND の線のあいだに入れる。使わないゲートの入力は GND、74HC74 の使わない PRE と CLR は +5V につなぐ (ブレッドボードと同じ)
- 基板の外の電源 5V と、ほかのユニットとやりとりする信号は、箱のピンから基板の穴まで線を引いた。ここに半田付けのリード線をつなぐ
- 使わない出力 (74HC74 の /Q、74HC163 の QC・QD・RCO、74HC04 と 74HC08 の使わないゲートの出力) と、同じ IC の中だけで閉じる接続 (74HC08 の 2Y と 3B) は、ERC が「つながっていない」と言う。承知のうえなので、`points:` で `NC_` から始まる名前を付けた (この名前は図には出ない)
- 範囲の確認: 電圧は 5 V、クロックは 8 Hz、音の信号は 440 Hz と 880 Hz で、ユニバーサル基板の範囲 (12 V 以下、10 MHz 以下) に収まる
- ブレッドボードでなくユニバーサル基板にも組む理由は、時計として長く通電する作品なので、接触の揺れのない半田付けにも組めるようにするため

### 図 8・8b: ユニット 1 (同期とエッジ検出)

```bread
title: 図8 同期とエッジ検出のブレッドボード (ユニット 1)
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
    pins: [CLK, T440, E440, NE440, E880]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [CLK, T880]
  U6: dip14 @ e3 l=74HC74
  U7: dip14 @ e13 r180 74HC04
  U8: dip14 @ e23 r180 74HC08
  U5: dip14 @ e33 r180 l=74HC74
  C1: capacitor/ceramic +t10 -t10 100n
  C2: capacitor/ceramic +t20 -t20 100n
  C3: capacitor/ceramic +t30 -t30 100n
  C4: capacitor/ceramic +t40 -t40 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t44 -- +b44 red
  - -t44 -- -b44 black
  - +t31 -- +t33 red
  - -t31 -- -t34 black
  - +b31 -- +b33 red
  - -b31 -- -b33 black
  - d32 -- g32 green
  - d22 -- g22 green
  - d12 -- g12 orange
  - d30 -- g30 orange
  - d11 -- g11 green
  - d10 -- g10 green
  - d31 -- g31 green
  - a29 -- a32 green
  - c32 -- c35 green
  - i32 -- i37 green
  - b19 -- b22 green
  - h22 -- h34 green
  - a18 -- a28 green
  - a12 -- a15 orange
  - j12 -- j30 orange
  - b27 -- b30 orange
  - c5 -- c11 green
  - a10 -- a11 green
  - i10 -- i31 green
  - c26 -- c31 green
  - j7 -- j11 green
  - b8 -- b17 green
  - c16 -- c25 green
  - +t3 -- a3 red
  - -b9 -- i9 black
  - +b3 -- j3 red
  - +b6 -- j6 red
  - +t7 -- a7 red
  - +t4 -- a4 red
  - +b19 -- h19 red
  - -t13 -- c13 black
  - -b14 -- h14 black
  - -b16 -- h16 black
  - -b18 -- h18 black
  - +b29 -- g29 red
  - -t23 -- b23 black
  - -b24 -- g24 black
  - -b25 -- g25 black
  - -b27 -- g27 black
  - -b28 -- g28 black
  - +b39 -- j39 red
  - -t33 -- a33 black
  - +t39 -- a39 red
  - +t36 -- a36 red
  - +b35 -- j35 red
  - +b38 -- j38 red
  - d41 -- g41 green
  - d21 -- g21 green
  - d20 -- g20 green
  - d40 -- g40 green
  - LINKT.CLK -- a37 yellow
  - LINKB.CLK -- j36 yellow
  - LINKB.CLK -- j5 yellow
  - LINKT.CLK -- a6 yellow
  - LINKT.T440 -- a38 orange
  - LINKB.T880 -- j4 orange
  - LINKT.E440 -- c15 orange
  - LINKT.NE440 -- c14 orange
  - LINKT.E880 -- b24 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/04-state-machine-1.svg)

```perf
title: 図8b 同期とエッジ検出のユニバーサル基板 (ユニット 1)
board:
  size: 15x9cm
  silk: board
points:
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
    pins: [NE440, E440, E880, CLK, T440]
  LINKB:
    type: device
    at: ae-1
    label: 他ユニット
    pins: [CLK, T880]
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
  - LINKT.T440 -- ab33 blue
  - LINKB.CLK -- ae1 yellow
  - LINKB.T880 -- af1 green
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
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/04-state-machine-1.svg)

- 図 8b: 9×15 cm のユニバーサル基板を横に置く (54 列 × 33 行)。IC は U8 が `t27`、U5 が `ak24`、U7 が `x10`、U6 が `ai10` (U5・U7・U6 は 180 度回した)。交差は 42 か所と多い。check のネットリストは図 8 と同じ

- IC は 74HC74 が 2 個 (U5、U6)、74HC04 (U7)、74HC08 (U8)。CLK は 4 つのフリップフロップの CLK ピン (PIN 3、11) へ、箱の CLK から 1 本ずつ引く。

### 図 9・9b: ユニット 2 (間隔タイマと窓)

```bread
title: 図9 間隔タイマと窓のブレッドボード (ユニット 2)
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
    pins: [NE440, W]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [CLK, TO]
  U11: dip14 @ e3 l=74HC02
  U10: dip14 @ e16 r180 74HC08
  U9: dip16 @ e29 74HC163
  C1: capacitor/ceramic +t10 -t10 100n
  C2: capacitor/ceramic +t23 -t23 100n
  C3: capacitor/ceramic +t37 -t37 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t44 -- +b44 red
  - -t44 -- -b44 black
  - +t31 -- +t33 red
  - -t31 -- -t33 black
  - +b31 -- +b33 red
  - -b30 -- -b35 black
  - d23 -- g23 green
  - d28 -- g28 green
  - d15 -- g15 green
  - d14 -- g14 green
  - d13 -- g13 green
  - d37 -- g37 green
  - d25 -- g25 green
  - d12 -- g12 green
  - c22 -- c31 green
  - a21 -- a23 green
  - i23 -- i28 green
  - b28 -- b32 green
  - a15 -- a20 green
  - j4 -- j15 green
  - i15 -- i17 green
  - b13 -- b14 green
  - h13 -- h37 green
  - c33 -- c37 green
  - i5 -- i14 green
  - b19 -- b25 green
  - a25 -- a34 green
  - j18 -- j25 green
  - c12 -- c18 green
  - h3 -- h12 green
  - +t3 -- a3 red
  - -b9 -- g9 black
  - -b7 -- g7 black
  - -b8 -- g8 black
  - -t9 -- a9 black
  - -t8 -- a8 black
  - -t6 -- a6 black
  - -t5 -- a5 black
  - +b22 -- i22 red
  - -t16 -- b16 black
  - -b20 -- i20 black
  - -b21 -- i21 black
  - +t29 -- d29 red
  - -b36 -- j36 black
  - +b29 -- j29 red
  - -b31 -- j31 black
  - +b32 -- j32 red
  - -b33 -- j33 black
  - -b34 -- j34 black
  - +b35 -- j35 red
  - +t35 -- a35 red
  - d11 -- g11 green
  - d24 -- g24 green
  - d10 -- g10 green
  - d27 -- g27 green
  - d26 -- g26 green
  - d39 -- g39 green
  - d38 -- g38 green
  - d40 -- g40 green
  - LINKB.CLK -- j30 yellow
  - LINKT.NE440 -- a36 orange
  - LINKB.TO -- j16 orange
  - LINKT.W -- b17 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/04-state-machine-2.svg)

```perf
title: 図9b 間隔タイマと窓のユニバーサル基板 (ユニット 2)
board: 7x9cm
points:
  NC_U11_4: i9
  NC_U11_10: f10
  NC_U11_13: f7
  NC_U10_11: r13
  NC_U9_15: h23
parts:
  PS:
    type: device
    at: -b17
    label: 電源 5V
    pins: [GND, +5V]
  LINKT:
    type: device
    at: -b5
    label: 他ユニット
    pins: [W, NE440]
  LINKB:
    type: device
    at: -b25
    label: 他ユニット
    pins: [CLK, TO]
  U11: dip14 f6 74HC02
  U9: dip16 h24 r180 74HC163
  U10: dip14 r16 r180 74HC08
  C1: capacitor/ceramic g15 g13 100n
  C2: capacitor/ceramic t18 t16 100n
  C3: capacitor/ceramic e15 e13 100n
wires:
  - PS.GND -- a17 black
  - PS.+5V -- a18 red
  - LINKT.W -- a5 purple
  - LINKT.NE440 -- a6 orange
  - LINKB.CLK -- a25 yellow
  - LINKB.TO -- a26 brown
  - m6 -- m12 pink
  - m6 -- i6 pink
  - o12 -- m12 pink
  - i7 -- l7 orange
  - l9 -- l7 orange
  - l9 -- l14 orange
  - l9 -- s9 orange
  - r11 -- s11 orange
  - s11 -- s9 orange
  - l14 -- o14 orange
  - h20 -- j20 blue
  - j20 -- j8 blue
  - j8 -- i8 blue
  - f11 -- e11 black
  - f11 -- f12 black
  - e13 -- d13 black
  - e13 -- e11 black
  - e13 -- g13 black
  - t16 -- t14 black
  - o8 -- o4 black
  - o8 -- o10 black
  - o8 -- t8 black
  - g13 -- i13 black
  - d19 -- d22 black
  - d19 -- e19 black
  - d19 -- d17 black
  - e19 -- e20 black
  - t8 -- t14 black
  - i10 -- i11 black
  - i11 -- i12 black
  - o4 -- e4 black
  - t14 -- r14 black
  - e9 -- e11 black
  - e9 -- e4 black
  - e9 -- f9 black
  - i12 -- i13 black
  - f8 -- f9 black
  - r14 -- r15 black
  - d17 -- e17 black
  - d17 -- a17 black
  - d17 -- d13 black
  - d22 -- e22 black
  - g15 -- e15 red
  - g15 -- i15 red
  - c21 -- c24 red
  - c21 -- e21 red
  - c21 -- c18 red
  - t18 -- t24 red
  - t18 -- r18 red
  - e18 -- c18 red
  - i15 -- i18 red
  - e25 -- e24 red
  - e25 -- h25 red
  - f6 -- c6 red
  - h18 -- i18 red
  - c15 -- c18 red
  - c15 -- e15 red
  - c15 -- c6 red
  - h25 -- h24 red
  - r16 -- r18 red
  - h24 -- t24 red
  - c18 -- a18 red
  - c24 -- e24 red
  - e23 -- a23 yellow
  - a25 -- a23 yellow
  - h16 -- h17 orange
  - h16 -- a16 orange
  - a6 -- a16 orange
  - k19 -- k17 green
  - k19 -- h19 green
  - k13 -- o13 green
  - k13 -- k17 green
  - k17 -- s17 green
  - r12 -- s12 green
  - s12 -- s17 green
  - o15 -- m15 white
  - m15 -- m21 white
  - h21 -- m21 white
  - o16 -- o22 blue
  - o22 -- h22 blue
  - n11 -- n5 purple
  - n11 -- o11 purple
  - a5 -- n5 purple
  - v26 -- a26 brown
  - v26 -- v10 brown
  - v10 -- r10 brown
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/04-state-machine-2.svg)

- 図 9b: 7×9 cm のユニバーサル基板 (26 列 × 31 行)。IC は U11 が `f6`、U9 が `h24`、U10 が `r16` (U9・U10 は 180 度回した)。交差は 20 か所。check のネットリストは図 9 と同じ

- 74HC163 (U9) のデータ入力は、B (PIN 4) だけ +5V、A・C・D (PIN 3、5、6) は GND で、値 2 を読み込む。CLR (PIN 1)、ENP (PIN 7)、ENT (PIN 10) は +5V。

### 図 10・10b: ユニット 3 (状態を動かす条件)

```bread
title: 図10 状態を動かす条件のブレッドボード (ユニット 3)
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
    pins: [W, QA, QB, NE440, E440, E880, TO, PON, LOADN, EN, CLRN]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [S3]
  U15: dip14 @ e3 r180 l=74HC02
  U14: dip14 @ e13 r180 74HC32
  U12: dip14 @ e23 r180 l=74HC86
  U13: dip14 @ e33 r180 74HC08
  C1: capacitor/ceramic +t10 -t10 100n
  C2: capacitor/ceramic +t20 -t20 100n
  C3: capacitor/ceramic +t30 -t30 100n
  C4: capacitor/ceramic +t40 -t40 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t44 -- +b44 red
  - -t44 -- -b44 black
  - +t31 -- +t33 red
  - -t31 -- -t34 black
  - +b31 -- +b33 red
  - -b31 -- -b33 black
  - d40 -- g40 orange
  - d12 -- g12 green
  - d10 -- g10 green
  - b36 -- b40 orange
  - j35 -- j40 orange
  - a27 -- a38 green
  - c18 -- c35 green
  - d35 -- d37 green
  - b12 -- b14 green
  - h12 -- h14 green
  - j15 -- j33 green
  - a8 -- a10 green
  - i10 -- i13 green
  - +b9 -- j9 red
  - -t3 -- a3 black
  - -t5 -- a5 black
  - -t4 -- a4 black
  - -b3 -- j3 black
  - -b4 -- j4 black
  - -b6 -- j6 black
  - -b7 -- j7 black
  - +b19 -- i19 red
  - -t13 -- a13 black
  - -b17 -- i17 black
  - -b18 -- i18 black
  - +b29 -- i29 red
  - -t23 -- a23 black
  - -t26 -- a26 black
  - -t25 -- a25 black
  - -b24 -- i24 black
  - -b25 -- i25 black
  - -b27 -- i27 black
  - -b28 -- i28 black
  - +b39 -- i39 red
  - -t33 -- b33 black
  - -b37 -- i37 black
  - -b38 -- i38 black
  - d30 -- g30 orange
  - d11 -- g11 green
  - d20 -- g20 green
  - LINKT.W -- a39 orange
  - LINKT.QA -- b29 orange
  - LINKT.QB -- b28 orange
  - LINKT.NE440 -- a19 orange
  - LINKT.E440 -- c36 orange
  - LINKT.E880 -- a16 orange
  - LINKT.TO -- a15 orange
  - LINKB.S3 -- j34 orange
  - LINKT.PON -- a7 orange
  - LINKT.LOADN -- a17 orange
  - LINKT.EN -- b34 orange
  - LINKT.CLRN -- b9 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/04-state-machine-3.svg)

```perf
title: 図10b 状態を動かす条件のユニバーサル基板 (ユニット 3)
board:
  size: 15x9cm
  silk: board
points:
  NC_U15_10: m20
  NC_U15_13: j20
  NC_U15_4: l17
  U14_9_6: w20
  NC_U14_11: u20
  NC_U12_8: ag20
  NC_U12_11: ad20
  NC_U12_6: af17
  NC_U13_11: am20
parts:
  PS:
    type: device
    at: w36
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: t-1
    label: 他ユニット
    pins: [CLRN, PON, NE440, LOADN, E880, TO, QA, QB, W, E440, EN]
  LINKB:
    type: device
    at: ak36
    label: 他ユニット
    pins: [S3]
  U15: dip14 i20 74HC02
  U14: dip14 r20 74HC32
  U12: dip14 aa20 74HC86
  U13: dip14 aj20 74HC08
  C1: capacitor/ceramic i23 i25 100n
  C2: capacitor/ceramic v22 x22 100n
  C3: capacitor/ceramic ag25 ae25 100n
  C4: capacitor/ceramic ao25 am25 100n
wires:
  - PS.+5V -- w33 red
  - PS.GND -- x33 black
  - LINKT.CLRN -- t1 blue
  - LINKT.PON -- u1 orange
  - LINKT.NE440 -- v1 blue
  - LINKT.LOADN -- w1 purple
  - LINKT.E880 -- x1 brown
  - LINKT.TO -- y1 white
  - LINKT.QA -- z1 pink
  - LINKT.QB -- aa1 green
  - LINKT.W -- ab1 pink
  - LINKT.E440 -- ac1 blue
  - LINKT.EN -- ad1 green
  - LINKB.S3 -- ak33 orange
  - t1 -- i1 blue
  - i17 -- i1 blue
  - x20 -- z20 green
  - j17 -- j15 green
  - z15 -- z20 green
  - z15 -- j15 green
  - u2 -- u1 orange
  - u2 -- k2 orange
  - k17 -- k2 orange
  - ak21 -- ak20 black
  - ak21 -- ah21 black
  - ak20 -- al20 black
  - ah21 -- ah17 black
  - ah21 -- ae21 black
  - ad17 -- ae17 black
  - ad17 -- ad14 black
  - ab20 -- ab21 black
  - ab20 -- ac20 black
  - s20 -- t20 black
  - s20 -- s26 black
  - p20 -- o20 black
  - p20 -- p17 black
  - ae17 -- ae16 black
  - ae16 -- ag16 black
  - ab25 -- ab22 black
  - ab25 -- x25 black
  - ab25 -- ae25 black
  - n20 -- o20 black
  - n20 -- n21 black
  - x17 -- x14 black
  - o17 -- n17 black
  - o17 -- p17 black
  - x14 -- ad14 black
  - l26 -- i26 black
  - l26 -- s26 black
  - l26 -- l21 black
  - ae25 -- ae26 black
  - i26 -- i25 black
  - ab21 -- ae21 black
  - ab21 -- ab22 black
  - x25 -- x26 black
  - s26 -- x26 black
  - ab22 -- x22 black
  - l21 -- n21 black
  - l21 -- l20 black
  - n17 -- m17 black
  - ae21 -- ae20 black
  - ae20 -- af20 black
  - l20 -- k20 black
  - ah17 -- ag17 black
  - ag16 -- ag17 black
  - aq26 -- aq17 black
  - aq26 -- am26 black
  - x26 -- x33 black
  - ap17 -- aq17 black
  - am26 -- ae26 black
  - am26 -- am25 black
  - r22 -- v22 red
  - r22 -- r20 red
  - ao27 -- ao25 red
  - ao27 -- ag27 red
  - ag25 -- ag27 red
  - ag25 -- ai25 red
  - ag27 -- aa27 red
  - v24 -- aa24 red
  - v24 -- v33 red
  - v24 -- v22 red
  - i23 -- i20 red
  - i23 -- h23 red
  - aa24 -- aa20 red
  - aa24 -- aa27 red
  - ai25 -- ai20 red
  - h33 -- h23 red
  - h33 -- v33 red
  - v33 -- w33 red
  - ai20 -- aj20 red
  - v1 -- v4 blue
  - v4 -- r4 blue
  - r4 -- r17 blue
  - al15 -- an15 orange
  - al15 -- al13 orange
  - al15 -- al17 orange
  - an17 -- an15 orange
  - s17 -- s13 orange
  - s13 -- al13 orange
  - w3 -- w1 purple
  - w3 -- t3 purple
  - t3 -- t17 purple
  - x1 -- x6 brown
  - u6 -- x6 brown
  - u6 -- u17 brown
  - y7 -- v7 white
  - y7 -- y1 white
  - v17 -- v7 white
  - w17 -- w16 purple
  - w16 -- y16 purple
  - y21 -- w21 purple
  - y21 -- y16 purple
  - w21 -- w20 purple
  - q21 -- v21 brown
  - q21 -- q23 brown
  - aj22 -- ap22 brown
  - aj22 -- aj23 brown
  - v21 -- v20 brown
  - q23 -- aj23 brown
  - ap22 -- ap20 brown
  - aa5 -- aa17 pink
  - aa5 -- z5 pink
  - z5 -- z1 pink
  - ab17 -- ab4 green
  - aa4 -- ab4 green
  - aa4 -- aa1 green
  - ac15 -- ac17 white
  - ac15 -- ak15 white
  - ak15 -- ak17 white
  - ab1 -- ab3 pink
  - ab3 -- aj3 pink
  - aj3 -- aj17 pink
  - am14 -- am17 blue
  - am14 -- ar14 blue
  - am14 -- am2 blue
  - an24 -- an20 blue
  - an24 -- ar24 blue
  - ar14 -- ar24 blue
  - ac2 -- am2 blue
  - ac2 -- ac1 blue
  - ao1 -- ao17 green
  - ao1 -- ad1 green
  - ao23 -- ao20 orange
  - ao23 -- ak23 orange
  - ak23 -- ak33 orange
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/04-state-machine-3.svg)

- 図 10b: 9×15 cm のユニバーサル基板を横に置く (54 列 × 33 行)。IC は U15 が `i20`、U14 が `r20`、U12 が `aa20`、U13 が `aj20` で、横一列に並べた。交差は 43 か所と多い。check のネットリストは図 10 と同じ

- IC は 74HC86 (U12)、74HC08 (U13)、74HC32 (U14)、74HC02 (U15)。入力が 9 本と出力が 3 本ある。入力は上の箱、S3 だけ下の箱から入れる。

### 図 11・11b: ユニット 4 (状態レジスタと出力)

```bread
title: 図11 状態レジスタと出力のブレッドボード (ユニット 4)
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
    pins: [CLK, CLRN, EN, S3, OUT]
  LINKB:
    type: device
    at: bottom
    label: 他のユニットへ (下)
    pins: [LOADN, E880, W, QA, QB]
  U16: dip16 @ e3 r180 74HC163
  U17: dip14 @ e15 74HC08
  C1: capacitor/ceramic +t11 -t11 100n
  C2: capacitor/ceramic +t22 -t22 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t27 -- +b27 red
  - -t27 -- -b27 black
  - +t30 -- +t32 red
  - -t30 -- -t32 black
  - +b30 -- +b32 red
  - -b30 -- -b32 black
  - d11 -- g11 orange
  - d14 -- g14 orange
  - d22 -- g22 green
  - a4 -- a11 orange
  - i4 -- i11 orange
  - j8 -- j15 orange
  - h7 -- h16 orange
  - a14 -- a20 orange
  - i14 -- i17 orange
  - c19 -- c22 green
  - i20 -- i22 green
  - +b10 -- g10 red
  - -t3 -- a3 black
  - +t8 -- b8 red
  - -t7 -- b7 black
  - -t6 -- b6 black
  - -t5 -- b5 black
  - +t15 -- b15 red
  - -b21 -- j21 black
  - -t17 -- b17 black
  - -t16 -- b16 black
  - d12 -- g12 orange
  - d23 -- g23 orange
  - d13 -- g13 green
  - LINKT.CLK -- b9 yellow
  - LINKB.LOADN -- j3 orange
  - LINKT.CLRN -- b10 orange
  - LINKT.EN -- b4 orange
  - LINKB.E880 -- j18 orange
  - LINKB.W -- j19 orange
  - LINKB.QA -- g8 orange
  - LINKB.QB -- j16 orange
  - LINKT.S3 -- b20 orange
  - LINKT.OUT -- a21 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/04-state-machine-4.svg)

```perf
title: 図11b 状態レジスタと出力のユニバーサル基板 (ユニット 4)
board:
  size: 7x5cm
  silk: board
points:
  NC_U16_11: q10
  NC_U16_12: p10
  NC_U16_15: m10
  U17_6_10: f13
  NC_U17_11: h10
parts:
  PS:
    type: device
    at: s-1
    label: 電源 5V
    pins: [+5V, GND]
  LINKT:
    type: device
    at: j-1
    label: 他ユニット
    pins: [OUT, S3, CLRN, CLK, EN]
  LINKB:
    type: device
    at: h21
    label: 他ユニット
    pins: [W, E880, QB, QA, LOADN]
  U17: dip14 k10 r180 74HC08
  U16: dip16 l10 74HC163
  C1: capacitor/ceramic j6 j8 100n
  C2: capacitor/ceramic k5 i5 100n
wires:
  - PS.+5V -- s1 red
  - PS.GND -- t1 black
  - LINKT.OUT -- j1 blue
  - LINKT.S3 -- k1 orange
  - LINKT.CLRN -- l1 blue
  - LINKT.CLK -- m1 yellow
  - LINKT.EN -- n1 purple
  - LINKB.W -- h18 pink
  - LINKB.E880 -- i18 brown
  - LINKB.QB -- j18 white
  - LINKB.QA -- k18 orange
  - LINKB.LOADN -- l18 green
  - k18 -- k13 orange
  - k13 -- n13 orange
  - n13 -- n10 orange
  - j15 -- j13 white
  - j15 -- j18 white
  - j15 -- o15 white
  - o15 -- o10 white
  - f2 -- f8 orange
  - f2 -- k2 orange
  - f10 -- f8 orange
  - i15 -- c15 orange
  - i15 -- i13 orange
  - c15 -- c8 orange
  - k2 -- k1 orange
  - c8 -- f8 orange
  - h16 -- h13 brown
  - h16 -- i16 brown
  - i18 -- i16 brown
  - g18 -- h18 pink
  - g18 -- g13 pink
  - f14 -- b14 green
  - f14 -- f13 green
  - g7 -- g10 green
  - g7 -- b7 green
  - b7 -- b14 green
  - p7 -- o7 black
  - p7 -- q7 black
  - i5 -- i8 black
  - i5 -- g5 black
  - g5 -- g3 black
  - g5 -- d5 black
  - o3 -- o7 black
  - o3 -- g3 black
  - o3 -- s3 black
  - i8 -- j8 black
  - i8 -- i10 black
  - i10 -- j10 black
  - d13 -- e13 black
  - d13 -- d5 black
  - t3 -- t1 black
  - t3 -- s3 black
  - s3 -- s7 black
  - j1 -- e1 blue
  - e10 -- e1 blue
  - s2 -- s1 red
  - s2 -- q2 red
  - q2 -- q5 red
  - k6 -- k5 red
  - k6 -- k10 red
  - k6 -- j6 red
  - k10 -- l10 red
  - q5 -- n5 red
  - k5 -- n5 red
  - n5 -- n7 red
  - l7 -- l1 blue
  - m1 -- m7 yellow
  - r5 -- r7 purple
  - r5 -- r1 purple
  - r5 -- u5 purple
  - r11 -- u11 purple
  - r11 -- r10 purple
  - u11 -- u5 purple
  - r1 -- n1 purple
  - s18 -- s10 green
  - s18 -- l18 green
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/04-state-machine-4.svg)

- 図 11b: 5×7 cm のユニバーサル基板を横に置く (24 列 × 18 行)。IC は U16 が `l10`、U17 が `k10` (U17 は 180 度回した)。交差は 21 か所。check のネットリストは図 11 と同じ

- 74HC163 (U16) のデータ入力は、A (PIN 3) だけ +5V、B〜D は GND で、値 1 を読み込む。ENP (PIN 7) と ENT (PIN 10) は、EN を 1 本の線で受ける。

## Analog Discovery 3 で試験する

**計器は Analog Discovery 3 (AD3) 1 台。** 電源は Supplies の V+ (5 V)、クロックは Wavegen W1、T440 は Wavegen W2、見るのは Scope の 2 ch (T440 と OUT)。
ブロック全体の 74HC は 13 個で、8 Hz の遅い動作なので、電流は目安で 1 mA に満たず、V+ の 50 mA (USB 給電で 250 mW) に収まる。
T880 は 3 回目の T440 のあと、+5 V の線を押しボタンで触れて H にする。AD3 の DIO は 3.3 V の出力で、74HC (5 V) の H の下限 3.5 V に届かないので使わない。
本物の T440・T880 は検出の回路 ([03-detect.md](03-detect.md)) が作る。ここでは、それが無くても状態遷移だけを試験できるようにする。

```breadboard
title: 図12 AD3 と基板 1〜4 の端子 (試験用のつなぎ)
board: half
parts:
  S1: switch d8 d12
  R1: resistor b8 b10 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, W2, "1+", "1-", "2+", "2-"]
  LINK:
    type: device
    at: bottom
    label: 基板 1〜4 の端子
    pins: [CLK, T440, T880, OUT, +5V, GND]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t2 black
  - LINK.+5V -- +t25 red
  - LINK.GND -- -t25 black
  - AD.W1 -- a4 yellow
  - LINK.CLK -- e4 yellow
  - AD.W2 -- a6 orange
  - AD.1+ -- b6 orange
  - LINK.T440 -- e6 orange
  - LINK.T880 -- e8 green
  - a10 -- -t10 black
  - a12 -- +t12 red
  - AD.2+ -- a14 blue
  - LINK.OUT -- e14 blue
  - AD.1- -- -t16 black
  - AD.2- -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/04-state-machine-5.svg)

- 基板 1〜4 の電源 (5 V と GND) と、4 枚のブレッドボードの間の信号は、これまでの図のとおり。AD3 とつなぐのは、基板 1 の CLK・T440・T880 の入力と、基板 4 の OUT の出力
- 押しボタン S1 (12 列) は +5 V につなぎ、T880 (8 列) へ渡す。R1 (10 kΩ) は、押さないとき T880 を L に保つプルダウン

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Square、8 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)。W2: Pulse、1 Hz、Amplitude 2.5 V、Offset 2.5 V、Duty 20 % (幅 0.2 s)、Burst の回数 3 (1 秒おきに 3 回だけ出る) |
| Scope | CH1 = T440、CH2 = OUT。500 ms/div、Trigger は CH1 の立ち上がり、Mode は Normal (単発で測る)。1 回目の T440 が t = 0 |

図13 は、T440 の 3 回のあと T880 を触れたときの見えるはずの画面で、図1 (計算) と同じ時刻を CH1・CH2 で見たもの。
**OUT は T880 のあとの 3.125〜3.25 秒に 1 クロック (0.125 秒) だけ H になる。** 4 回目の T440 を出したり、間隔を 1.5 秒にしたりすると、OUT は出ない (図2・図3)。

```scope
title: 図13 T440 (CH1) が 3 回来たあと、OUT (CH2) に 0.125 s のパルスが 1 つ
time: 500ms/div
trigger: ch1 rising 2.5V at -5div
ch1: {wave: "= 5V * (step(t - 40ms) - step(t - 240ms) + step(t - 1.04s) - step(t - 1.24s) + step(t - 2.04s) - step(t - 2.24s))", range: 2V/div, position: 1div}
ch2: {wave: "= 5V * (step(t - 3.125s) - step(t - 3.25s))", range: 2V/div, position: -3div}
cursors: [1.5s, 3.2s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/04-state-machine.svg)
