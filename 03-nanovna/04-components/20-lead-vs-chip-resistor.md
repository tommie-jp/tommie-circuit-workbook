---
book: nanovna
chapter: 4
id: 4-20
title: 抵抗のリード品とチップ品 (GHz)
tier: 200
source: 自作
board: CB
device: V2
---

# 4-20 抵抗のリード品とチップ品 (GHz)

4-1 では抵抗の \|Z\| を 300 MHz まで測り、リードのインダクタンスで上がり始める所を見た。
ここでは同じ 51 Ω (オーム) を **50 Ω の終端**として使い、リード付きの 1/4 W の炭素皮膜抵抗と 1608 (0603) のチップ抵抗を、
銅張り基板の線路の先に付けて V2 で 3 GHz まで比べる。終端として使えるかどうかは反射 (リターンロス・SWR) で決まるので、
S11 を見る。校正の Load (1-2) や自作の校正キット (3-4) を GHz で作るときの部品選びに直結する題になる。

## この実験で確かめる式

抵抗の模型は、R と寄生の L の直列に、両端の間の容量 Cp を並列にした形 (4-1 と同じ)。

- Z = (R + jωL) ∥ (1 / (jωCp))。ω (オメガ) は 2πf
- 反射係数 Γ (ガンマ) = (Z − 50) / (Z + 50)、リターンロス = 20·log₁₀\|Γ\| (S11 の Log Mag)、SWR = (1 + \|Γ\|) / (1 − \|Γ\|)

| 抵抗 (模型。目安) | R | L | Cp |
| --- | --- | --- | --- |
| リード品 (1/4 W、リードを 2 mm ずつに切る) | 51 Ω | 6 nH | 0.3 pF |
| チップ品 (1608) | 51 Ω | 0.9 nH (部品 0.4 nH + via 2 本 0.5 nH) | 0.05 pF |

L と Cp はメーカーの値ではなく、リードの長さ (1 mm あたり約 1 nH) と胴の大きさから見積もった目安。
チップの via の値は 4-17 と同じ。

## 回路図

2 つの治具の等価回路。どちらも CH0 だけにつなぐ 1 端子の測定で、1 つずつ測る。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 リード品 (左) とチップ品 (右) の終端 (等価回路)
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 4,2 4,3.25 51
  L1: inductor 4,3.25 4,4.5 6n
  C1: capacitor 5.5,2.5 5.5,4 0.3p
  G1: ground 2,3
  G2: ground 4,5
  J2: sma 9,2 mirror CH0
  R2: resistor 11,2 11,3.25 51
  L2: inductor 11,3.25 11,4.5 0.9n
  C2: capacitor 12.5,2.5 12.5,4 0.05p
  G3: ground 9,3
  G4: ground 11,5
wires:
  - J1.1 -- 4,2
  - 4,2 -- 5.5,2
  - 5.5,2 -- 5.5,2.5
  - 5.5,4 -- 5.5,4.5
  - 5.5,4.5 -- 4,4.5
  - 4,4.5 -- 4,5
  - J1.2 -- 2,3
  - J2.1 -- 11,2
  - 11,2 -- 12.5,2
  - 12.5,2 -- 12.5,2.5
  - 12.5,4 -- 12.5,4.5
  - 12.5,4.5 -- 11,4.5
  - 11,4.5 -- 11,5
  - J2.2 -- 9,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/20-lead-vs-chip-resistor.svg)

- L1・C1 (L2・C2) は寄生分で、部品としては無い。R1 (R2) の 1 本がこの 3 つに見える
- 治具の線路 (17 mm・20 mm) は図に描かない。ポート延長 (1-10・3-7) で基準面を抵抗の根元まで動かして測る

## 実体配線図

5×7 cm の両面の銅張り基板から 30 mm × 20 mm を 2 枚切り出す。どちらも左の縁の SMA から 50 Ω の線を引き、
先に抵抗を付けて裏の GND へ落とす。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
title: 図2 線路の先に 51 Ω を付けて GND へ落とす
f: 3G
board:
  size: 30x20mm
  ground: back
sheets:
  - name: リード品
    copper:
      L1: line 0,10 17,10 3.06mm
      P1: pad 27,10 4x4mm
      V1: via 27,10 1.2mm
    parts:
      J1: sma left 10 CH0
      R1: resistor 16,10 P1 51
    notes:
      - text 4,16: R1 のリードを V1 に通して裏の GND へ
  - name: チップ品
    copper:
      L2: line 0,10 20,10 3.06mm
      P2: pad 22.5,10 3x4mm
      V2: via 23,9
      V3: via 23,11
    parts:
      J2: sma left 10 CH0
      R2: resistor/1608 20.4,10 51
    notes:
      - text 4,16: P2 は via 2 本で裏の GND へ
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/copper/20-lead-vs-chip-resistor.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、30 mm × 20 mm を 2 枚。裏は全面の銅 (GND) |
| 線 L1・L2 | 幅 3.06 mm (計算値 50 Ω)。長さは L1 が 17 mm、L2 が 20 mm。まわりの表の銅は剥がす |
| リード品 R1 | 寝かせて、片方のリードを線の先に、もう片方を P1 の穴 (直径 1.2 mm) に通して裏の GND に半田付けする。リードは胴から 2 mm で切る |
| チップ品 R2 | 線の先と P2 を跨いで載せる。P2 は 3 mm × 4 mm で、直径 0.8 mm の via を 2 本 |
| 端面 SMA (J1・J2) | 左の縁。中心ピンを線の端へ、外皮の脚は裏のベタへ |

- 銅張り基板にするのは、3 GHz まで 50 Ω の線路と面の GND が要るから (perfboard は 300 MHz くらいまで、3-6)
- リード品は線の先から P1 の穴まで約 10 mm (胴 6 mm とリード 2 mm ずつ)。この長さと、穴を抜けて裏の GND へ戻る道がそのまま L になる

## 部品

| 部品 | 値 | 備考 |
| --- | --- | --- |
| R1 | 51 Ω、1/4 W の炭素皮膜 (リード品) | E24。リードを 2 mm に切る |
| R2 | 51 Ω、1608 のチップ抵抗 | E24 |
| J1・J2 | 端面 SMA (メス) | 1 枚に 1 個 |
| 基板 | 両面 FR4 1.6 mm | 30 mm × 20 mm を 2 枚 |

50 Ω の校正の Load と比べたいので、E24 で 50 Ω に一番近い 51 Ω を使う。51 Ω の Γ は 1/101 で、
リターンロスの上限は −40.1 dB (寄生分が無いとき)。

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種、3 GHz まで) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。
AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先で。そのあとポート延長で線路 (チップ品の 20 mm は VF 0.55 として片道 121 ps、リード品の 17 mm は 103 ps。目安) を除く |
| 表示 | S11 の Log Mag と Smith チャート |

リード品の見えるはずの画面 (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図3 リード品の 51 Ω — 1 GHz で −10 dB、3 GHz で −2.9 dB
dut:
  - series R 51 esl 6n cp 0.3p
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/20-lead-vs-chip-resistor-1.svg)

チップ品の見えるはずの画面。設定は図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図4 チップ品の 51 Ω — 3 GHz でも −16.9 dB
dut:
  - series R 51 esl 0.9n cp 0.05p
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/20-lead-vs-chip-resistor-2.svg)

- Smith チャートでは、どちらも 100 MHz で中心 (50 Ω) の近くにいて、周波数とともに上半分 (誘導性) へ回る。
  リード品は 3 GHz で右の端 (大きい R) の近くまで出ていく。これは L と Cp の並列共振へ向かう形
- Log Mag の枠は 10 dB/目盛。チップ品の −30 dB 前後の差を読むには、マーカーの値で読む

## 見るべき値

計算値 (模型は上の表)。

| 抵抗 | 周波数 | Z | リターンロス | SWR |
| --- | --- | --- | --- | --- |
| リード品 | 100 MHz | 51.1 + j3.3 Ω | −29.34 dB | 1.07 |
| リード品 | 1 GHz | 58.5 + j34.5 Ω | −10.11 dB | 1.91 |
| リード品 | 2.4 GHz | 126.8 + j103.6 Ω | −4.02 dB | 4.40 |
| リード品 | 3 GHz | 239.3 + j122.3 Ω | −2.88 dB | 6.08 |
| チップ品 | 100 MHz | 51.0 + j0.5 Ω | −39.16 dB | 1.02 |
| チップ品 | 1 GHz | 51.2 + j4.8 Ω | −26.16 dB | 1.10 |
| チップ品 | 2.4 GHz | 52.0 + j11.7 Ω | −18.75 dB | 1.26 |
| チップ品 | 3 GHz | 52.5 + j14.7 Ω | −16.85 dB | 1.34 |

分かること:

- **リード品は 623 MHz で SWR 1.5 を超える** (計算値)。終端・アッテネータ・校正の Load に使えるのは数百 MHz まで
- **チップ品は 3 GHz でも SWR 1.34。** 寄生の L が 1/7 になるので、同じ周波数での X も 1/7 になる。
  それでも 0.9 nH のうち半分は via なので、GHz の Load を作るときは via を増やすか、2 個の 100 Ω を並列にして L を減らす
- 51 Ω と 50 Ω の違い (−40 dB) は 100 MHz でもう寄生分に埋もれる。終端の良し悪しは、GHz では値の精度より形 (L) で決まる
- 実物のリード品は、皮膜の溝 (抵抗値を合わせるらせん) もインダクタンスになり、模型より早く悪くなることがある

## LTspice での確かめ

`sim/20-lead-vs-chip-resistor.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけ、CH0 から見た Z を求めた
(50 Ω の電源、1 端子の `dut:` は最後を短絡。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (リード品) | 1 GHz | Z | 58.5 + j34.5 Ω | 58.47 + j34.53 Ω | 合う |
| 図3 (リード品) | 3 GHz | Z | 239.3 + j122.3 Ω | 239.33 + j122.28 Ω | 合う |
| 図4 (チップ品) | 1 GHz | Z | 51.2 + j4.8 Ω | 51.17 + j4.84 Ω | 合う |
| 図4 (チップ品) | 3 GHz | Z | 52.5 + j14.7 Ω | 52.55 + j14.67 Ω | 合う |

4 点すべて合う。リターンロスと SWR は、この Z から上の式で算術で求めた。

## 出典

自作。

参考: [Wikipedia "Resistor"](https://en.wikipedia.org/wiki/Resistor)、[Wikipedia "Surface-mount technology"](https://en.wikipedia.org/wiki/Surface-mount_technology)、[Wikipedia "Standing wave ratio"](https://en.wikipedia.org/wiki/Standing_wave_ratio)
