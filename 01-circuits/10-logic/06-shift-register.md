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
  U1: ic h14 74HC595
  VCC: vcc d14 5V
  GND: ground l14
  VCC: vcc c10 5V
  SER: switch c10 e10 l=$\mathrm{SER}$
  RpdS: resistor e10 e8 10k l=$R_\mathrm{pdS}$
  GS: ground e8
  VCC: vcc f4 5V
  SRCLK: button f4 h4 l=$\mathrm{SRCLK}$
  RpdCLK: resistor h4 j4 10k l=$R_\mathrm{pdCLK}$
  GCLK: ground j4
  VCC: vcc k6 5V
  RCLK: button k8 k6 l=$\mathrm{RCLK}$
  RpdRCLK: resistor k8 m8 10k l=$R_\mathrm{pdRCLK}$
  GRCLK: ground m8
  RD: resistor k17 l17 330
  DD: led l17 m17 red
  GD: ground m17
  RC: resistor k19a5 l19a5 330
  DC: led l19a5 m19a5 red
  GC: ground m19a5
  RB: resistor k22 l22 330
  DB: led l22 m22 red
  GB: ground m22
  RA: resistor k24a5 l24a5 330
  DA: led l24a5 m24a5 red
  GA: ground m24a5
wires:
  # 電源: VCC と SRCLR (クリアしない) を +5V、GND と OE (出力を常に出す) を GND へ
  - U1.VCC |- d14
  - U1.SRCLR |- d14a5
  - d14 -- d14a5
  - U1.GND |- k14
  - U1.OE |- k14a5
  - k14a5 -- k14 -- l14
  # 入力: SER は上、SRCLK は左、RCLK は下のスイッチから
  - U1.SER -| e10
  - U1.SRCLK -| h4
  - U1.RCLK -| k8
  # 出力: QA〜QD を LED へ (QA がいちばん右)
  - U1.QA -| k24a5
  - U1.QB -| k22
  - U1.QC -| k19a5
  - U1.QD -| k17
notes:
  - text n17 blue center: QD
  - text n19a5 blue center: QC
  - text n22 blue center: QB
  - text n24a5 blue center: QA
  - text p1 small left: "SRCLK はシフトクロック、RCLK はラッチクロック"
  - text q1 small left: "QE-QH と直列出力 (PIN 9) は開けておく"
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
- 図1 の 74HC595 は足を働きで並べた箱で描いた (左が入力、右が出力、上が電源、下が GND)。
  箱の中に PIN の番号を添えてある。出力の線が交わらないよう、LED は右から QA・QB・QC・QD の順に並ぶ
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
