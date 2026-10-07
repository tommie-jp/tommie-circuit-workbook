---
book: circuits
chapter: 10
id: 10-6
title: シフトレジスタ (74HC595)
tier: 100
board: BB
source: 自作
era: 今
---

# 10-6 シフトレジスタ (74HC595)

シフトレジスタは、10-5 のフリップフロップを数珠つなぎにして、クロックのたびに
中身を 1 段ずつ隣へ送る回路。74HC595 は、シフトクロックを 1 回入れるたびに 1 ビットずつ
取り込み、別の「ラッチクロック」を入れた瞬間にまとめて出力へ出す IC。マイコンのピン 3 本
(データ・シフトクロック・ラッチクロック) だけで何ビットも出力を増やせるので、
LED をたくさん光らせたいときや 7 セグメント表示器 (10-7) を並べたいときによく使う。
ここではボタンで手動でクロックを送り、1 ビットずつ送り込まれる様子を見る。

## 回路図

```circuit
title: 図1 74HC595に手動でビットを送り込む
parts:
  U1: ic 14,8 74HC595
  VCC: vcc 14,4 5V
  GND: ground 14,12
  VCC: vcc 10,3 5V
  SER: switch 10,3 10,5 l=$\mathrm{SER}$
  RpdS: resistor 10,5 8,5 10k l=$R_\mathrm{pdS}$
  GS: ground 8,5
  VCC: vcc 4,6 5V
  SRCLK: button 4,6 4,8 l=$\mathrm{SRCLK}$
  RpdCLK: resistor 4,8 4,10 10k l=$R_\mathrm{pdCLK}$
  GCLK: ground 4,10
  VCC: vcc 6,11 5V
  RCLK: button 8,11 6,11 l=$\mathrm{RCLK}$
  RpdRCLK: resistor 8,11 8,13 10k l=$R_\mathrm{pdRCLK}$
  GRCLK: ground 8,13
  RD: resistor 17,11 17,12 330
  DD: led 17,12 17,13 red
  GD: ground 17,13
  RC: resistor 19.5,11 19.5,12 330
  DC: led 19.5,12 19.5,13 red
  GC: ground 19.5,13
  RB: resistor 22,11 22,12 330
  DB: led 22,12 22,13 red
  GB: ground 22,13
  RA: resistor 24.5,11 24.5,12 330
  DA: led 24.5,12 24.5,13 red
  GA: ground 24.5,13
wires:
  # 電源: VCC と SRCLR (クリアしない) を +5V、GND と OE (出力を常に出す) を GND へ
  - U1.VCC |- 14,4
  - U1.SRCLR |- 14.5,4
  - 14,4 -- 14.5,4
  - U1.GND |- 14,11
  - U1.OE |- 14.5,11
  - 14.5,11 -- 14,11 -- 14,12
  # 入力: SER は上、SRCLK は左、RCLK は下のスイッチから
  - U1.SER -| 10,5
  - U1.SRCLK -| 4,8
  - U1.RCLK -| 8,11
  # 出力: QA〜QD を LED へ (QA がいちばん右)
  - U1.QA -| 24.5,11
  - U1.QB -| 22,11
  - U1.QC -| 19.5,11
  - U1.QD -| 17,11
notes:
  - text 17,14 blue center: QD
  - text 19.5,14 blue center: QC
  - text 22,14 blue center: QB
  - text 24.5,14 blue center: QA
  - text 1,16 small left: "SRCLK はシフトクロック、RCLK はラッチクロック"
  - text 1,17 small left: "QE-QH と直列出力 (PIN 9) は開けておく"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/06-shift-register.svg)

- SER (PIN 14) がシリアル入力 (1 本の線で 1 ビットずつ送る入力)。スイッチ SER を
  閉じておくと 1、開けておくと (プルダウン RpdS で) 0 を送り込む
- SRCLK (PIN 11) の立ち上がりのたびに、そのときの SER の値が内部の
  シフトレジスタの先頭 (QA の段) に取り込まれ、既にあったビットは 1 つ後ろへずれる
- RCLK (PIN 12) の立ち上がりで、シフトレジスタの中身がまとめて出力ラッチへ
  写される。RCLK を押すまでは、何回 SRCLK を送っても QA〜QH は変わらない。
  送っている途中の中途半端な値が LED に出ないのが、シフトと出力を分けた 74HC595 の値打ち
- SRCLR̄ (PIN 10) はシフトレジスタを全部 0 にするクリアの入力で、負論理 (10-2) なので
  +5V に固定して無効にする。OĒ (PIN 13) は出力を出すかどうかを決める入力で、これも
  負論理なので GND に固定して出力を常に有効にする
- QA〜QD (PIN 15・1・2・3) だけ LED を付けた。QE〜QH (PIN 4〜7) も同じ考え方で
  続ければ 8 ビット全部を出せる (図1 の場所が足りないので省略)
- 図1 の 74HC595 はピンを働きで並べた箱で描いた (左が入力、右が出力、上が電源、下が GND)。
  箱の中に PIN の番号を添えてある。出力の線が交わらないよう、LED は右から QA・QB・QC・QD の順に並ぶ
- 74HC595 は速い IC なので、ボタンのチャタリング (10-5) も 1 回のクロックとして数える。
  1 回押しただけで 2 ビット以上進むことがある。表どおりにならないときはこれを疑う。
  確実にするには 10-9 のチャタリング除去を SRCLK と RCLK に足す

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (U1 は 74HC595。AD3 の DIO0〜2 が入力、DIO3〜6 が QA〜QD)
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, DIO6, DIO5, DIO4, DIO3, DIO0, DIO1, DIO2]
  U1: dip16 @ e34 74HC595
  RA: resistor c35 c32 330
  DA: led b32(A) b29(K) red
  RB: resistor c27 c24 330
  DB: led b24(A) b21(K) red
  RC: resistor c19 c16 330
  DC: led b16(A) b13(K) red
  RD: resistor c11 c8 330
  DD: led b8(A) b5(K) red
  SER: switch h44 h47
  RpdS: resistor i44 i41 10k
  SRCLK: button @ e50
  RpdCLK: resistor b50 b53 10k
  RCLK: button @ e56
  RpdRCLK: resistor b56 b59 10k
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t3 -- +b3 red
  - a34 -- +t34 red
  - a40 -- +t40 red
  - a37 -- -t37 black
  - j41 -- -b41 black
  - g34 -- g27 orange
  - g27 -- e27 orange
  - h35 -- h19 orange
  - h19 -- e19 orange
  - i36 -- i11 orange
  - i11 -- e11 orange
  - a29 -- -t29 black
  - a21 -- -t21 black
  - a13 -- -t13 black
  - a5 -- -t5 black
  - b36 -- b44 yellow
  - b44 -- g44 yellow
  - c39 -- c50 yellow
  - d38 -- d56 yellow
  - j47 -- +b47 red
  - j50 -- +b50 red
  - j56 -- +b56 red
  - a53 -- -t53 black
  - a59 -- -t59 black
  - AD.DIO6 -- a11 green
  - AD.DIO5 -- a19 green
  - AD.DIO4 -- a27 green
  - AD.DIO3 -- a35 green
  - AD.DIO0 -- a44 blue
  - AD.DIO1 -- a50 blue
  - AD.DIO2 -- a56 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/06-shift-register.svg)

- ブレッドボードは full。ブレッドボードの 1 穴 200 mA・ブレッドボード全体 500 mA の範囲に、電流は十分収まる (下の部品の節)
- U1 (74HC595) は 34〜41 列。左下が PIN 1 (QB)、左上が PIN 16 (VCC)。VCC・SRCLR は +5V へ、GND・OE は GND へ。
  出力は下の列の QB・QC・QD (PIN 1〜3) をオレンジの線で左へ引き、上の LED の列へ渡す。QA (PIN 15) は上の列から直接 LED へ
- 入力は黄の線で右へ。SER (PIN 14) は 44 列のスイッチ SER へ、SRCLK (PIN 11) は 50 列のボタンへ、RCLK (PIN 12) は 56 列のボタンへ。
  ボタンの下のピンを +5V、上のピンを信号と 10kΩ のプルダウンにして、押すと 1 になる
- AD3 は上に置く。V+ (赤) を +5V、GND (黒) を GND へ。DIO0〜2 (青) が SER・SRCLK・RCLK、DIO3〜6 (緑) が QA〜QD の列
- AD3 の DIO0〜2 から入れる間は、ボタンもスイッチも触らない (押すと DIO が +5V に直結する)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 8 ビット シフトレジスタ | 74HC595 (DIP-16) |
| DA〜DD | LED (赤) | 5 mm、V<sub>F</sub> 約 2.0V |
| RA〜RD | 抵抗 (1/4 W)、LED の電流制限 | 330Ω × 4 本 |
| RpdS・RpdCLK・RpdRCLK | 抵抗 (1/4 W)、プルダウン | 10kΩ × 3 本 |
| SER | スライドスイッチ | 1 個 |
| SRCLK・RCLK | タクトスイッチ | 2 個 |
| — | 電源・信号源・計器 | Analog Discovery 3 (下の計器の設定) |

電流の見積もり。LED 1 本は (5V − 2.0V) ÷ 330Ω ≈ 9.1mA (74HC の出力が落ちないと仮定した上限の計算値)。
4 本で 36mA、プルダウンは 1 本 0.5mA で 3 本 1.5mA、IC 自身は数 µA で、合計は 40mA に届かない。
AD3 の Supplies の各レール 50mA (USB 給電で 250mW) に収まり、ブレッドボードの範囲にも収まる。

## 計器の設定

計器は AD3 の Supplies (+5V)・Patterns (SER・SRCLK・RCLK の信号源)・Logic (QA〜QD の観測)。手でボタンを押すと間隔がばらつき、
ビットが 1 つずつ進む順序を止めて見られない。そこで Patterns でクロックを出し、Logic で 7 本を同時に見る。
時間で動く回路で、レベルが 0 か 1 かだけが大事なので、オシロでなくロジックの画面にする。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5V、Master Enable を入れる |
| Patterns | DIO0 (SER) = 常に 1、DIO1 (SRCLK) = Clock 500Hz・Duty 25%、DIO2 (RCLK) = SRCLK の 1ms 後に 0.5ms だけ 1 を出すパルス (周期 2ms) |
| Logic | DIO0〜6 を表示。DIO3〜6 を 1 つのバス (QD QC QB QA、2 進) にまとめる。標本化 100kHz、時間 0.8ms/div (全体で 8ms) |
| トリガ | DIO1 (SRCLK) の立ち上がり、時間 0 |
| カーソル | X1 = 2.75ms (2 回目の SRCLK のあと、RCLK の前)、X2 = 7.75ms (4 回目の RCLK のあと) |

```logic
title: 図3 SRCLK を 4 回送り、そのたびに RCLK を送ると、QA から順に 1 が増える (計算)
device: ad3
time: 800us/div
sample: 100kHz
signals:
  SER:   dio0 high
  SRCLK: dio1 clock 500Hz duty 25%
  RCLK:  dio2 edges 0s=0 1ms=1 1.5ms=0 3ms=1 3.5ms=0 5ms=1 5.5ms=0 7ms=1 7.5ms=0
  QA:    dio3 edges 0s=0 1ms=1
  QB:    dio4 edges 0s=0 3ms=1
  QC:    dio5 edges 0s=0 5ms=1
  QD:    dio6 edges 0s=0 7ms=1
buses:
  Q: QD QC QB QA bin
cursors: [2.75ms, 7.75ms]
trigger: SRCLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/06-shift-register.svg)

- 図3 は計算で作った理想の波形で、実測ではない (出力の遅れは数 10 ns で、この時間軸では見えない)。SRCLK は 0・2・4・6ms で立ち上がり、
  RCLK はその 1ms 後の 1・3・5・7ms で立ち上がる
- カーソル X1 (2.75ms) では、SRCLK を 2 回送ったのに RCLK は 1 回しか送っていないので、Q は 0001 のまま。ラッチしたものだけが LED に出る
- カーソル X2 (7.75ms) では、4 回目のラッチのあとで Q = 1111。QA が 1ms、QB が 3ms、QC が 5ms、QD が 7ms で 1 になる階段の形が、下の「見るべき値」の表の 4 行に当たる

## 見るべき値

SER を 1 (スイッチを閉じる) にして SRCLK を 1 回押し、離してから RCLK を
1 回押す、を 4 回繰り返す例。SER は毎回 1 のまま (スイッチを閉じたまま) と仮定。

| 操作 | シフトレジスタの中身 (新しい方が左) | RCLK 後の QA QB QC QD |
| --- | --- | --- |
| 開始 | 0000 | 0 0 0 0 |
| SRCLK 1 回目 → RCLK | 1000 | **1** 0 0 0 |
| SRCLK 2 回目 → RCLK | 1100 | **1 1** 0 0 |
| SRCLK 3 回目 → RCLK | 1110 | **1 1 1** 0 |
| SRCLK 4 回目 → RCLK | 1111 | **1 1 1 1** |

途中で SER を開けて (0) SRCLK を押すと、シフトレジスタの先頭に 0 が入り、
古いビットは 1 つ後ろへずれる。RCLK を押すと、その並びが LED に出る。
SRCLK を 8 回送ると、最初に入れたビットは最後の段 (QH、PIN 7) に着く。同じ値は
QH' (PIN 9、次の IC へ渡す直列出力) にも出ている。ここを次の 74HC595 の SER に
つなげば、16 ビット、24 ビットと続けて送れる。9 回目の SRCLK で、そのビットはこのレジスタから押し出されて消える。

## 出典

自作。
