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
  VCC: vcc a1
  GND: ground a30
  SER: switch a5 c5
  RpdS: resistor c6 e6 10k
  GS: ground e6
  SRCLK: button a10 c10
  RpdCLK: resistor c11 e11 10k
  GCLK: ground e11
  RCLK: button a15 c15
  RpdRCLK: resistor c16 e16 10k
  GRCLK: ground e16
  U1: dip16 h6 74HC595
  GU1: ground i2
  RA: resistor k4 m4 330
  DA: led m4 o4 red
  GA: ground o4
  RB: resistor k8 m8 330
  DB: led m8 o8 red
  GB: ground o8
  RC: resistor k12 m12 330
  DC: led m12 o12 red
  GC: ground o12
  RD: resistor k16 m16 330
  DD: led m16 o16 red
  GD: ground o16
wires:
  - a1 -- a5
  - a5 -- a10
  - a10 -- a15
  - a15 -- a20
  - a1 |- U1.16
  - a20 |- U1.10
  - a30 |- U1.13
  - c5 -- c6
  - c5 -- f5
  - f5 -| U1.14
  - c10 -- c11
  - c10 -- g10
  - g10 -| U1.11
  - c15 -- c16
  - c15 -- h15
  - h15 -| U1.12
  - U1.15 |- k4
  - U1.1 -| k8
  - U1.2 -| k12
  - U1.3 -| k16
  - U1.8 |- i2
notes:
  - text f4 blue: "SER (足14)"
  - text f9 blue: "SRCLK (足11、シフトクロック)"
  - text f19 blue: "RCLK (足12、ラッチクロック)"
  - text j4 blue: "QA (足15)"
  - text j8 blue: "QB (足1)"
  - text j12 blue: "QC (足2)"
  - text j16 blue: "QD (足3)"
style:
  grid: on
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
