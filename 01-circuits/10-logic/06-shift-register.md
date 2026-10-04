---
book: circuits
chapter: 10
id: 10-6
title: シフトレジスタ (74HC595)
tier: 100
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
  VCC: vcc f15g0 5V
  GND: ground g15i3 r270
  VCC: vcc e17e5 5V
  SER: switch e17e5 g17e5
  RpdS: resistor g17e5 g19e5 10k
  GS: ground g19e5
  VCC: vcc h26 5V
  SRCLK: button h26 j26
  RpdCLK: resistor j26 j28 10k
  GCLK: ground j28
  VCC: vcc f21c5 5V
  RCLK: button f21c5 h21c5
  RpdRCLK: resistor h21c5 h23c5 10k
  GRCLK: ground h23c5
  U1: dip16 h14 74HC595
  GU1: ground i13e0
  VCC: vcc k14 5V
  RA: resistor c2 d2 330
  DA: led d2 e2 red
  GA: ground e2
  RB: resistor c4a5 d4a5 330
  DB: led d4a5 e4a5 red
  GB: ground e4a5
  RC: resistor c7 d7 330
  DC: led d7 e7 red
  GC: ground e7
  RD: resistor c9a5 d9a5 330
  DD: led d9a5 e9a5 red
  GD: ground e9a5
wires:
  - U1.16 -| f15g0
  - U1.13 -| g15i3
  - U1.10 -| k15a5
  - k15a5 -- k14
  - U1.14 -| g17e5
  - U1.12 -| h21c5
  - U1.11 -| j16a5
  - j16a5 -- j26
  - U1.15 -| a15f8
  - a15f8 -- a2f0 -- c2
  - U1.1 -| b13
  - b13 -- b4a5 -- c4a5
  - U1.2 -| b12f6
  - b12f6 -- b7f0 -- c7
  - U1.3 -| c12a2
  - c12a2 -- c9a5
  - U1.8 -| i13e0
notes:
  - text c16a5 blue: "SER (PIN 14)"
  - text d19a8 blue: "RCLK (PIN 12、ラッチクロック)"
  - text f24a3 blue: "SRCLK (PIN 11、シフトクロック)"
  - text f1a3 blue: "QA (PIN 15)"
  - text f3a8 blue: "QB (PIN 1)"
  - text f6a3 blue: "QC (PIN 2)"
  - text f8a8 blue: "QD (PIN 3)"
  - text l1 small left: "U1 の VCC は PIN 16 (+5V)、GND は PIN 8"
  - text m1 small left: "QE-QH (PIN 4-7) と直列出力 (PIN 9) は開けておく"
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
- 74HC595 は速い IC なので、ボタンのチャタリング (10-5) も 1 回のクロックとして数える。
  1 回押しただけで 2 ビット以上進むことがある。表どおりにならないときはこれを疑う。
  確実にするには 10-9 のチャタリング除去を SRCLK と RCLK に足す

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
