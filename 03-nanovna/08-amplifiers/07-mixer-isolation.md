---
book: nanovna
chapter: 8
id: 8-7
title: ミキサのポート間アイソレーション
tier: 100
source: 自作。SBL-1+ のピンと特性は Mini-Circuits のデータシート
board: PF
device: H4
---

# 8-7 ミキサのポート間アイソレーション

ダイオードを 4 本輪にしたダブルバランスドミキサ (DBM) は、LO (局部発振) を入れる
ポートから RF と IF のポートへ **LO が漏れない**ように、トランスとダイオードの
釣り合いで打ち消している。この打ち消しの深さが**アイソレーション**。LO を CH0、
RF (か IF) を CH1 につないで S21 を測れば、**漏れの量がそのまま S21 (負の dB) で読める**。

例は Mini-Circuits の **SBL-1+** (LO / RF 1〜500 MHz、IF DC〜500 MHz、ピンの付いた金属缶)。
DBM の中身と周波数変換の働きは回路の教科書の 9-12 で扱う。ここでは漏れだけを見る。

## この実験で確かめる式

アイソレーション [dB] = −S21 [dB] (LO → RF、LO → IF)。

データシートの代表値 (LO +7 dBm で測った表):

| 周波数 | L-R (LO → RF) | L-I (LO → IF) |
| --- | --- | --- |
| 10 MHz | 64.2 dB | 64.8 dB |
| 100 MHz | 49.4 dB | 46.9 dB |
| 297 MHz | 36.9 dB | 34.0 dB |

周波数を上げるとアイソレーションは下がる (漏れが増える)。トランスの巻線の間や
ダイオードの容量の釣り合いが、高い周波数ほど崩れるからだ。ここでは漏れを
**容量 1 つ**で表した**等価回路**で画面を描く。50 Ω の間に直列の小さな容量 C があると、
|S21| ≈ 2π f C × 100 Ω (**1 けたで 20 dB 変わる**)。100 MHz のデータシートの値に合わせると、
L-R は C = 54 fF、L-I は C = 72 fF。

**LO の強さが違う**: データシートの値は LO +7 dBm で、ダイオードが LO で開いたり
閉じたりしている状態の値。NanoVNA の CH0 は 0 dBm より小さい (0-3) ので、ダイオードは
ほとんど動かない。**同じ数になるとは限らない**。見るのは「周波数でどう下がるか」と
「L-R と L-I のどちらが漏れやすいか」の傾き。

**定格**: SBL-1+ の RF の最大電力は 50 mW (+17 dBm)。NanoVNA の出力では届かない。

## 回路図

```circuit
title: 図1 LO を CH0、RF を CH1 へ。IF は 50 Ω で終端
parts:
  J1: sma c2 mirror CH0
  U1:
    type: ic3
    at: c6
    label: SBL-1+
    pins: [LO, IF, RF]
  J2: sma c10 CH1
  RL: resistor d6 f6 50 l=$\mathrm{Load}$
  GJ1: ground d2
  GRL: ground f6
  GJ2: ground d10
wires:
  - J1.1 -| U1.LO
  - J1.2 -- d2
  - U1.IF -- d6
  - U1.RF |- J2.1
  - J2.2 -- d10
notes:
  - text e7 left: J3 に挿した 50 Ω の Load (校正キット)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/07-mixer-isolation.svg)

- U1 のピンは LO = 8 番、RF = 1 番、IF = 3・4 番 (**2 本を外でつなぐ**、データシートの指示)、
  GND = 2・5・6・7 番。図は 3 つの信号のピンだけを描いた
- **L-I を測るとき**は、CH1 のケーブルを J3 (IF) へ移し、Load を J2 (RF) へ移す。
  使わないポートは必ず 50 Ω で終端する。開けたままだと、そこで跳ね返った漏れが
  もう一度混ざって値が変わる

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 SBL-1+ と端面 SMA 3 つ (部品面。ピンは 2 穴おき)
points:
  P8LO: i9
  P6G: i11
  P4IF: i13
  P2G: i15
  P7G: g9
  P5G: g11
  P3IF: g13
  P1RF: g15
parts:
  J1: sma/female-edge i1 j0
  J2: sma/female-edge g24 h25
  J3: sma/female-edge k24 l25
wires:
  - i1 -- P8LO
  - P1RF -- g24
  - P3IF -- P4IF
  - P4IF -- k13
  - k13 -- k24
  - d11 -- d9 black
  - d9 -- d1 black
  - d1 -- h1 black
  - h1 -- h0 black
  - P7G -- d9 black
  - P5G -- d11 black
  - j0 -- j2 black
  - j2 -- l2 black
  - l2 -- l10 black
  - l10 -- l25 black
  - P6G -- i10 black
  - i10 -- l10 black
  - P2G -- i17 black
  - i17 -- h17 black
  - h17 -- h25 black
notes:
  - box f8 j16 blue
  - text g9 mirror: 7
  - text g11 mirror: 5
  - text g13: 3
  - text g15: 1
  - text i9 mirror: 8
  - text i11 mirror: 6
  - text i14 mirror: 4
  - text i15: 2
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/07-mixer-isolation.svg)

- 青い枠が SBL-1+ の缶、枠の中の数字が PIN 番号。**ピンは 5.08 mm (2 穴) おきの 2 列 × 4 本**なので、穴を 1 つずつ
  飛ばして挿す。部品面 (上) から見て、上の列が左から 7・5・3・1、下の列が 8・6・4・2
  (データシートの外形図は裏から見た図で、左右が逆)
- 入力の J1 (LO) は左の縁、出力の J2 (RF) と J3 (IF) は右の縁に上下に並べた。
  2 つの真ん中がユニバーサル基板の高さの中ほど (i 行) に来る
- 3・4 番 (IF) はユニバーサル基板の上でつなぎ、k 行を通って右下の J3 へ。GND の 7・5 番は上の線 (d 行)、
  6 番は下の線 (l 行) で J3 の外皮 (l25) へ、2 番は h 行で J2 の外皮 (h25) へ。
  上と下の GND は J1 の外皮 (h0 と j0 は同じ金物) でつながる
- 缶の裏の金属とピンの間を短く。缶をじかにユニバーサル基板に付けて半田付けする

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 3 MHz〜300 MHz (上は perfboard の治具の目安、3-6。下は漏れが −80 dB を割って床に埋もれるので切った) |
| 点数 | 100 |
| 校正 | SOLT (CH0・CH1 のケーブルの先で) |
| 表示 | S21 の Log Mag |
| 平均 | −60 dB より下を読むので、掃引を何回か重ねて平均すると読みが落ち着く |

**LO → RF** (図1 のつなぎ方) の見えるはずの画面 (漏れを 54 fF にした等価回路)。

```vna
device: h4
sweep: 3M-300M 100
title: 図3 L-R アイソレーション — 1 けたで 20 dB 漏れが増える (54 fF の等価回路)
dut:
  - series C 54f
traces:
  - S21 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/07-mixer-isolation-1.svg)

**LO → IF** (CH1 を J3 へ、Load を J2 へ移す) の見えるはずの画面。設定は図3 と同じ。

```vna
device: h4
sweep: 3M-300M 100
title: 図4 L-I アイソレーション — L-R より 2.5 dB 漏れやすい (72 fF の等価回路)
dut:
  - series C 72f
traces:
  - S21 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/07-mixer-isolation-2.svg)

- どちらも右上がりの線 (周波数とともに漏れが増える)。等価回路は 1 けたで 20 dB だが、
  データシートの値は 10〜300 MHz で約 27 dB 変わり、1 けたあたり 18 dB ほど。
  **傾きが合うか**を実測で見る
- 10 MHz あたりの −65 dB 前後は、NanoVNA-H4 の S21 のダイナミックレンジ
  (300 MHz まで約 70 dB、9-4) の近く。ここは床 (雑音) に近いので、平均しても
  ばらつく。**−60 dB より下の読みは、両方のポートに Load を付けたときの床と比べてから信じる**

## 見るべき値

| 周波数 | L-R 等価回路 (計算値) | L-R データシート | L-I 等価回路 (計算値) | L-I データシート |
| --- | --- | --- | --- | --- |
| 10 MHz | −69.4 dB | −64.2 dB | −66.9 dB | −64.8 dB |
| 100 MHz | −49.4 dB | −49.4 dB | −46.9 dB | −46.9 dB |
| 300 MHz | −39.9 dB | −36.9 dB (297 MHz) | −37.4 dB | −34.0 dB (297 MHz) |

- 等価回路は 100 MHz で合わせたので、10 MHz と 300 MHz ではデータシートと 3〜5 dB ずれる
- データシートでは 100 MHz より上で **L-I のほうが漏れやすい** (アイソレーションが
  2〜3 dB 小さい)。LO が小さい NanoVNA の測定でも同じ順になるかを見る
- LO を +7 dBm で入れたときの値は、別の信号源で LO を入れ、NanoVNA を RF 側だけで使う
  などの工夫が要る。この題の範囲の外

## 出典

- Mini-Circuits, SBL-1+ データシート (Rev. B): ピンの割り当て、外形図、アイソレーションの代表値、最大定格
- DBM の働きは標準的な RF 回路の教科書による
