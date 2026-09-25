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

74HC595 は、**クロックを 1 回入れるたびに 1 ビットずつ取り込み**、別の
「ラッチクロック」を入れた瞬間にまとめて出力へ出す IC。マイコンのピン 3 本
(データ・シフトクロック・ラッチクロック) だけで何ビットも出力を増やせるので、
LED をたくさん光らせたいときや 7 セグを並べたいときによく使う。ここではボタンで
手動でクロックを送り、1 ビットずつ送り込まれる様子を見る。

## 回路図

```circuit
title: 図1 74HC595に手動でビットを送り込む
parts:
  VCC: vcc f15g0
  GND: ground g15i3 r270
  VCC: vcc e17e5
  SER: switch e17e5 g17e5
  RpdS: resistor g17e5 g19e5 10k
  GS: ground g19e5 r270
  VCC: vcc h26
  SRCLK: button h26 j26
  RpdCLK: resistor j26 j28 10k
  GCLK: ground j28 r270
  VCC: vcc f21c5
  RCLK: button f21c5 h21c5
  RpdRCLK: resistor h21c5 h23c5 10k
  GRCLK: ground h23c5 r270
  U1: dip16 h14 74HC595
  GU1: ground i13e0 r90
  VCC: vcc k14
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
  - U1.10 -| k15
  - k15 -- k14
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
  - text c16a5 blue: "SER (足14)"
  - text d19a8 blue: "RCLK (足12、ラッチクロック)"
  - text f24a3 blue: "SRCLK (足11、シフトクロック)"
  - text f1a3 blue: "QA (足15)"
  - text f3a8 blue: "QB (足1)"
  - text f6a3 blue: "QC (足2)"
  - text f8a8 blue: "QD (足3)"
style:
  grid: on
  pitch: 1.2
```

- **SER (足14)** がシリアル入力の 1 ビット。SW を閉じておくと 1、開けておくと
  (プルダウンで) 0 を送り込む
- **SRCLK (足11)** の**立ち上がり**のたびに、そのときの SER の値が内部の
  シフトレジスタに取り込まれ、既にあったビットは 1 つ後ろへずれる
- **RCLK (足12)** の立ち上がりで、シフトレジスタの中身がまとめて出力ラッチへ
  コピーされる。**RCLK を押すまでは、何回 SRCLK を送っても QA〜QH は変わらない**
  — シフトと出力が分かれているのが 74HC595 の値打ち
- **SRCLR̄ (足10)** は負論理のクリアなので Vcc に固定して無効化。**OĒ (足13)**
  も負論理の出力イネーブルなので GND に固定して常時出力を有効にする
- QA〜QD (足15・1・2・3) だけ LED を付けた。QE〜QH (足4〜7) も同じ考え方で
  続ければ 8 ビット全部を出せる (列が足りないのでここでは省略)

## 見るべき値

SER を 1 (スイッチを閉じる) にして SRCLK を 1 回押し、離してから RCLK を
1 回押す、を 4 回繰り返す例。SRCLK は毎回 1 のまま (SER を閉じたまま) と仮定。

| 操作 | シフトレジスタの中身 (新しい方が左) | RCLK 後の QA QB QC QD |
| --- | --- | --- |
| 開始 | 0000 | 0 0 0 0 |
| SRCLK 1 回目 → RCLK | 1000 | **1** 0 0 0 |
| SRCLK 2 回目 → RCLK | 1100 | **1 1** 0 0 |
| SRCLK 3 回目 → RCLK | 1110 | **1 1 1** 0 |
| SRCLK 4 回目 → RCLK | 1111 | **1 1 1 1** |

途中で SER を開けて (0) SRCLK を押すと、次にラッチしたときに先頭へ 0 が
入り、古いビットが 1 つ後ろへ押し出される。8 回押し続けると、最初に入れた
ビットは QH (足7) の先へ送り出され (足9、QH′ で次の 74HC595 へ渡せる)、
このレジスタからは消える。

## 出典

自作。
