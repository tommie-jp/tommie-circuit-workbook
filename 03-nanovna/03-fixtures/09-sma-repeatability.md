---
book: nanovna
chapter: 3
id: 3-9
title: SMA オス / メスとケーブルの再現性
tier: 100
source: 自作
board: PF
device: H4
---

# 3-9 SMA オス / メスとケーブルの再現性

同じ物を測り直しても、読み値は少しずつ違う。違いの多くは**SMA の付け外し**と
**ケーブルの曲げ**から来る。この題では 3-4 の自作 Load と 3-6 のスルー治具 (図 2) を
10 回ずつ付け外しし、読み値がどれだけ揺れるかを自分の道具で測る。その揺れより
小さい差は、測っても意味が無い。

## オスとメス

| | オス (プラグ、SMA-P) | メス (ジャック、SMA-J) |
| --- | --- | --- |
| 中心 | ピン | ピンを受ける割りのある穴 |
| ねじ | 回るナット (内ねじ) | 本体の外ねじ |
| この本の例 | ケーブルの両端 | NanoVNA の CH0 / CH1、治具の端面 SMA (3-1〜3-6) |

- オスとメスの組でしか繋がらない。メスどうし (治具と治具) を繋ぐときは
  **オス-オスの中継 (SMA-P-P)** を挟む。中継はそのぶん長さと付け外しの揺れを足す
  ので、校正の後に中継を足したらポート延長 (3-7) を入れ直す
- メスの割りのある穴は、斜めに挿したり締めすぎたりすると広がって戻らない。
  付け外しの寿命は 500 回くらいが目安 (製品のデータシートで確かめる)。**校正キットと
  よく使う治具には中継を付けっぱなしにし**、傷むのを安い中継の側にする
- 締め方は 0-2 のとおり (手で回し、最後だけトルクレンチ)

## 回路図

1 つ目の測る物は 3-4 の自作 Load。

```circuit
title: 図1 自作 Load (100 Ω を 2 本並列) を CH0 に
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 d4 100
  R2: resistor b6 d6 100
  G1: ground c2
  G2: ground e5
wires:
  - J1.1 -- b4 -- b6
  - d4 -- d6
  - d5 -- e5
  - J1.2 -- c2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/09-sma-repeatability.svg)

2 つ目の測る物は 3-6 のスルー治具 (図は 3-6 の図 2。5×7 cm のユニバーサル基板の幅いっぱい)。

## 実体配線図

3-4 の Load のユニバーサル基板をそのまま使う。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 自作 Load (3-4 と同じ)
points:
  GND: c7
parts:
  J1: sma/female-edge a10 011 09
  R1: resistor c10 c7 100
  R2: resistor e10 e7 100
wires:
  - a10 -- c10
  - c10 -- e10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- c7 black
  - c7 -- e7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/09-sma-repeatability.svg)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先で。**校正の後はケーブルを動かさない** (手順 3 だけわざと曲げる) |
| 表示 | Load は S11 の Log Mag と Smith、スルーは S21 の位相と S11 の Log Mag |

**1. 自作 Load** — 見えるはずの画面。R1・R2 のピンとパターンで 2 nH が残る模型
(1-7 の自作の Load の例と同じ値)。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 自作 Load — 300 MHz で S11 は −28.5 dB
dut:
  - series R 50 esl 2n
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 300M
notes:
  - text 20M -15dB: 付け外しの揺れはこの線の上下に出る
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/09-sma-repeatability-1.svg)

**2. スルー治具** — 3-6 のスルーと同じ 52 nH の模型 (23 穴の線を 8-3 の経験式で見積もった値)。曲げの揺れは S21 の位相に出る。

```vna
device: h4
sweep: 1M-300M 101
title: 図4 スルー治具 — 300 MHz で S21 の位相は −44.5°
dut:
  - series R 0 esl 52.1n
traces:
  - S21 phase
  - S11 logmag
markers:
  - 100M
  - 300M
notes:
  - text 20M -45deg: 曲げの揺れはこの線の上下に出る
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/09-sma-repeatability-2.svg)

## 手順

1. **付け外し (Load)**: Load を CH0 のケーブルに締める → 100 MHz と 300 MHz の S11 を
   書き取る → 外す。これを 10 回。毎回同じ締め方にする
2. **付け外し (スルー)**: スルー治具を両方のケーブルに締め、300 MHz の S21 の位相と
   S11 を書き取る → 片側だけ外して締め直す。これを 10 回
3. **曲げ**: スルー治具を付けたまま、CH1 側のケーブルを 90° 曲げて、300 MHz の
   S21 の位相を書き取る。まっすぐに戻して、もう一度書き取る
4. それぞれ、10 回の最大と最小の差 (幅) を出す

## 見るべき値

理想 (計算値) と、書き込む表。

| 測る物 | 見る値 | 理想 (計算値) | 10 回の幅 (書き込む) |
| --- | --- | --- | --- |
| Load | 100 MHz の S11 | −38.0 dB | |
| Load | 300 MHz の S11 | −28.5 dB | |
| スルー | 300 MHz の S21 の位相 | −44.5° | |
| スルー | 300 MHz の S11 | −3.1 dB | |
| スルー (曲げ) | 300 MHz の S21 の位相の変化 | 0° | |

- **S11 の幅は、低い値ほど大きく見える。** −38 dB の反射は 0.013 (1.3 %) しかなく、
  付け外しで乗る小さな反射と同じくらいの大きさ。−38 dB と −42 dB の差は
  付け外しの揺れに埋もれることが多い
- 図4 の S21 の位相は 300 MHz で −44.5° で、45°/目盛の枠ではほぼ 1 目盛。
  付け外しの揺れは 1° 前後なので線の形では見えない。**揺れは線の形ではなく、マーカーの
  読み値 (小数 2 桁) で比べる**
- 300 MHz のスルーの S11 (−3.1 dB) は、3-6 の限界 (約 31 MHz) をはるかに超えた所の値。
  治具としては信じられない周波数だが、付け外しの揺れを見るには、読み値が大きく
  動きやすいこの所が向く
- **位相の揺れは周波数に比例して増える。** 300 MHz で 1° 揺れるなら、900 MHz では
  およそ 3°。GHz で位相を読む題 (第 9 章) ほど、ケーブルを固定する意味が大きい
- 出した幅が、**この道具で見分けられる差の下限**になる。3-7・3-8 で治具を引いた後に
  残る揺れも、この幅より小さければ気にしなくてよい

## 出典

自作。
