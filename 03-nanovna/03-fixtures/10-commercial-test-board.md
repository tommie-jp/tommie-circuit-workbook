---
book: nanovna
chapter: 3
id: 3-10
title: 市販のテストボードと自作の比較
tier: 100
source: 自作
board: PF
device: H4
---

# 3-10 市販のテストボードと自作の比較

NanoVNA の周りには「RF Demo Kit」「テストボード」などの名で、1 枚の基板にスルー・
Open / Short / Load・アッテネータ・フィルタを並べた練習用の基板が売られている。
自作の perfboard の治具 (3-1〜3-6) と比べて、**どこが違い、どこまで同じに使えるか**を
スルーで確かめる。載っている物は製品ごとに違うので、手元の基板の印刷と説明書を見る。

## 何が違うか

| | 自作 (perfboard、3-6 の短いスルー) | 市販のテストボード |
| --- | --- | --- |
| 線 | 穴の上に張った 1 本の線。GND は隣の行の 1 本の線だけ | 裏が全面 GND の基板に、幅を決めた**マイクロストリップ** (50 Ω を狙った線) |
| SMA | 端面 SMA を縁に半田付け | 基板用の端面 SMA、足の周りの GND が近い |
| 高い周波数での振る舞い | 線が**インダクタンス**に見える (3-6 の 5 nH) | 線が**線路**に見える (遅延はあるが反射は小さい) |
| 作り直し | すぐできる。測る部品を自由に挿せる | できない。載っている物しか測れない |

**線路に見える**とは、線の特性インピーダンスが 50 Ω に近く、長さが遅延 (位相の回り) に
なるだけで反射がほとんど出ないこと。遅延はポート延長 (3-7) で消せるが、インダクタンスの
反射は消せない (3-8 の De-embedding が要る)。

## 回路図

2 つのスルーを模型で描き比べる (等価回路)。

```circuit
title: 図1 スルーの等価回路 (上が自作、下が市販)
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 b6 5n
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
  J3: sma e2 mirror CH0
  T1: tline e4 e6 50
  J4: sma e8 CH1
  G3: ground f2
  G4: ground f8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
  - J3.1 -- e4
  - e6 -- J4.1
  - J3.2 -- f2
  - J4.2 -- f8
notes:
  - text a5 center: "自作 (3-6)、線がインダクタンス"
  - text d5 center: "市販、50 Ω のマイクロストリップ"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/10-commercial-test-board.svg)

- L1 (5 nH) は 3-6 で見積もった自作のスルーの寄生インダクタンス
- T1 は市販の基板のスルーの線。長さ 3 cm、FR-4 のマイクロストリップ (VF 0.55、1-10 の表)
  と仮定する。SMA の足と線の継ぎ目に 0.5 nH ずつ残るとする (見積もり)

## 実体配線図

自作の側は 3-6 の短いスルー治具 (中心導体の間 3 穴) をそのまま使う。市販の基板は
perfboard ではないので描かない (基板の印刷でスルーの区画を探す)。

```perfboard
board:
  size: 4x8
  slots: on
title: 図2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e4 f5
wires:
  - e1 -- e4
  - f0 -- f5 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/10-commercial-test-board.svg)

図 2 は自作のスルー治具 (部品面から見た図、3-6 の図 2 と同じ)。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先で (市販の基板の Open / Short / Load では校正しない。比べる物で校正すると比べられない) |
| 表示 | S11 の Log Mag と S21 の位相 |

**1. 自作のスルー** — 見えるはずの画面 (3-6 と同じ模型)。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 自作のスルー — 300 MHz で S11 は −20.6 dB
dut:
  - series R 0 esl 5n
traces:
  - S11 logmag
  - S21 phase
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/10-commercial-test-board-1.svg)

**2. 市販のテストボードのスルー** — 同じ設定で。

```vna
device: h4
sweep: 1M-300M 101
title: 図4 市販のスルー — S11 は低いまま、位相は遅延で回る
dut:
  - series L 0.5n
  - line 50 3cm vf 0.55
  - series L 0.5n
traces:
  - S11 logmag
  - S21 phase
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/10-commercial-test-board-2.svg)

## 見るべき値

計算値 (模型から)。

| 周波数 | 自作の S11 (図3) | 市販の S11 (図4) | 自作の S21 の位相 | 市販の S21 の位相 |
| --- | --- | --- | --- | --- |
| 100 MHz | −30.1 dB | −44.1 dB | −1.8° | −6.9° |
| 300 MHz | −20.6 dB | −35.1 dB | −5.4° | −20.7° |

- **反射 (S11) は市販のほうが約 14 dB 低い。** 自作は線のインダクタンスがそのまま反射に
  なり、市販は継ぎ目の小さなインダクタンスしか残らない
- **位相は市販のほうが大きく回る。** 線が長い (3 cm の遅延 0.18 ns) からで、欠点ではない。
  ポート延長 (3-7) で消せる
- 自作の治具で 300 MHz まで測るなら、S11 の −20 dB が目安の縁 (3-6)。市販の基板は
  その縁が高い周波数へ伸びる。**部品を自由に挿せる自作と、線のきれいな市販**を、
  測る物で使い分ける
- 市販の基板の Load や Open / Short も、自作の 3-4 と同じ手順 (Smith で中心・右端・左端に
  どれだけ近いか) で比べられる

## 出典

自作。市販のテストボードの中身は製品ごとに違うので、特定の製品の値ではなく、
マイクロストリップの線と perfboard の線の違いを模型で比べた。
