---
book: nanovna
chapter: 3
id: 3-7
title: ポート延長で治具の電気長を除く
tier: 100
source: 自作
board: PF
device: H4
---

# 3-7 ポート延長で治具の電気長を除く

校正はケーブルの先 (治具の SMA に挿す手前) までの狂いを除く。治具の SMA から
部品までの**線の長さ**は校正の外に残り、Smith チャートの点を周波数とともに回す。
1-10 ではケーブルの先を開放してポート延長 (電気長) を合わせた。この題では同じ
手順を**治具**に使う。部品を外した治具 (開放) で遅延を合わせてから部品を挿すと、
治具の線が無いのと同じ値が読める。

## 回路図

部品を GND へ落とす 1 端子の治具。SMA から部品までの線 (T1) が、ポート延長で
除く電気長になる。

```circuit
title: 図1 1 端子の治具 (SMA から部品までの線が電気長)
parts:
  J1: sma b2 mirror CH0
  T1: tline b3 b5 50
  R1: resistor b6 d6 100
  G1: ground c2
  G2: ground d6
wires:
  - J1.1 -- b3
  - b5 -- b6
  - J1.2 -- c2
notes:
  - text a4 center: "治具の線 3 cm"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/07-port-extension-fixture.svg)

- R1 が測る部品 (DUT)。ここでは値の分かっている 100 Ω で手順を確かめる
- T1 は部品ではなく、**SMA の中の長さと、中心導体から R1 までの線**をまとめて
  線路として描いたもの (等価回路)。長さは SMA の中を約 1 cm、板の上の線を約 2 cm と
  見積もり、合わせて 3 cm とする

## 実体配線図

```perfboard
board:
  size: 12x8
  slots: on
title: 図2 1 端子の治具
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  R1: resistor e9 h9 100
wires:
  - e1 -- e9
  - f0 -- f2 black
  - f2 -- GND black
  - GND -- h9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/07-port-extension-fixture.svg)

- e1〜e9 の線 (8 穴ぶん、約 2 cm) が板の上の電気長。R1 の足を抜いた状態が
  「治具の開放」、R1 の代わりに太い線で e9 と h9 を結んだ状態が「治具の短絡」になる
- GND は h 行にまとめ、SMA の凹の腕 (f0) からつなぐ (3-1 と同じ)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOL (1 端子なので Thru は無し、Open / Short / Load)。ケーブルの先 (治具の SMA に挿す手前) で |
| 表示 | S11 の Smith チャートと群遅延 |
| 模型の仮定 | 治具の線を 50 Ω・3 cm・VF 0.7 の線路と見なす (往復の遅延 0.286 ns) |

**1. 部品を外した治具 (開放)** — ポート延長を入れる前に見えるはずの画面。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 部品を外した治具は開放なのに外周を回る
dut:
  - line 50 3cm vf 0.7
  - open
traces:
  - S11 smith
  - S11 delay
markers:
  - 100M
  - 300M
notes:
  - text 20M 0.4ns: 往復 0.286 ns を E-DELAY に
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/07-port-extension-fixture-1.svg)

**2. 100 Ω を挿した治具** — ポート延長を入れないまま読むと、治具の線のぶん値がずれる。

```vna
device: h4
sweep: 1M-300M 101
title: 図4 100 Ω を治具ごと読むと 300 MHz で 82.5 Ω − j31.7 Ω
dut:
  - line 50 3cm vf 0.7
  - series R 100
  - short
traces:
  - S11 smith
  - S11 delay
markers:
  - 100M
  - 300M
notes:
  - text 20M 0.4ns: 開放と同じ 0.286 ns
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/07-port-extension-fixture-2.svg)

**3. ポート延長を入れた後** — 治具の線が無いのと同じ、100 Ω の 1 点に戻る。

```vna
device: h4
sweep: 1M-300M 101
title: 図5 ポート延長の後は 100 Ω の 1 点 (遅延 0)
dut:
  - series R 100
  - short
traces:
  - S11 smith
  - S11 delay
markers:
  - 100M
  - 300M
notes:
  - text 20M 0.1ns: 治具の遅延が消えて 0
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/07-port-extension-fixture-3.svg)

## ポート延長を入れる手順

1-10 と同じ操作 (H4 は DISPLAY → SCALE → E-DELAY。元のファームウェアでは ELECTRICAL DELAY)
を、ケーブルではなく治具に使う。

1. 治具から R1 を外す (開放)。図3 のように、右端の開放が時計回りに回って見える
2. E-DELAY に往復の遅延を入れる。この模型なら **0.286 ns**。実物では S11 の
   群遅延を読んでその値から始める
3. Smith の点が**右端の 1 点に縮む**まで値を少しずつ変える。回りが速くなったら符号が逆
4. e9 と h9 を太い線で短絡し、左端の 1 点に縮むことを確かめる。短絡の線を外して R1 を挿す
5. 図5 のように 100 Ω の 1 点に戻れば、治具の電気長が除けている

ポート延長が消すのは**線の遅延 (位相の回り) だけ**。板の上の線は 50 Ω の線路では
ないので (GND の h 行から離れた 1 本の線)、そのずれと、線のインダクタンスが残す分は
消えない。これも除くなら、治具の S パラメータを測って引く De-embedding (3-8) を使う。

## 見るべき値

計算値。往復の遅延 2τ = 2 × 3 cm / (0.7 × c) = 0.286 ns。

| 周波数 | 開放 (図3) | 100 Ω を治具ごと (図4) | ポート延長の後 (図5) |
| --- | --- | --- | --- |
| 100 MHz | 0.0 Ω − j555.2 Ω (位相 −10.3°) | 97.6 Ω − j13.1 Ω | 100.0 Ω + j0.0 Ω |
| 300 MHz | 0.0 Ω − j181.0 Ω (位相 −30.9°) | 82.5 Ω − j31.7 Ω | 100.0 Ω + j0.0 Ω |
| 群遅延 | 0.286 ns | 0.286 ns | 0 ns |

- **開放なのに 300 MHz で 30.9° 回り、−j181 Ω の容量に見える。** これが治具の電気長。
  回る角は周波数に比例し、群遅延は周波数によらず一定の 0.286 ns
- 100 Ω を治具ごと読むと、300 MHz で 82.5 Ω − j31.7 Ω の容量性に見える。**部品の値では
  なく治具の線のせい**。位相の回りは開放と同じ角 (Γ の大きさは 1/3 のまま、向きだけ回る)
  なので、開放で合わせた遅延がそのまま部品にも効く
- 実物では、ポート延長の後も高い周波数で少しずれが残る。残りが治具の線の
  インダクタンスと 50 Ω からのずれで、3-6 で見た治具の限界と同じ物

## 出典

自作。
