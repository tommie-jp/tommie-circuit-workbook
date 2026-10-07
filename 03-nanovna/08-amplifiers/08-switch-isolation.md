---
book: nanovna
chapter: 8
id: 8-8
title: リレー / PIN スイッチのアイソレーション
tier: 100
source: 自作。G5V-2 のピンとコイルの定格は OMRON のデータシート
board: PF
device: H4
---

# 8-8 リレー / PIN スイッチのアイソレーション

信号を切り替えるスイッチは、**切った (開いた) ときにどれだけ漏れるか** (アイソレーション) と、
**入れたときにどれだけ損するか** (挿入損失) の 2 つで評価する。どちらも S21 で読める。
例は小型の信号用リレー OMRON **G5V-2** (2 回路の切り替え、DIP 型)。後半で、
半導体のスイッチ (PIN ダイオード) なら同じ数がどうなるかを計算で比べる。

開いた接点は、**2 枚の金属が向き合った小さなコンデンサ**になる。周波数を上げると
そのリアクタンスが下がり、漏れが増える。

## この実験で確かめる式

50 Ω の間に直列の容量 C があるときの漏れ: **|S21| ≈ 2π f C × 100 Ω** (1 けたで 20 dB 増える)。

開いた接点とピンどうしの容量を **C = 1 pF と仮定**すると、100 MHz で −24 dB。
信号用リレーは、この仮定のとおりなら 100 MHz でもう 1/16 の電圧が漏れる。

**2 回路目で出口を GND へ落とす**: G5V-2 は 2 回路あるので、2 回路目の
b 接点 (NC、コイルに電流が無いとき閉じている側) で**出口を GND へ短絡**させる。
漏れた信号は GND へ逃げ、CH1 に届く分は大きく減る。短絡の線に残るインダクタンスを
10 nH と仮定すると、100 MHz で 18 dB、10 MHz で 38 dB 良くなる (計算値)。
高い周波数ほど、この 10 nH のリアクタンスが増えて短絡の効きが落ちる。

**入れたとき**: 閉じた接点とピンの道のり (約 2 cm) のインダクタンスを 15 nH と仮定すると、
300 MHz で S21 は −0.34 dB、S11 は −11 dB。挿入損失は小さいが、**反射は 100 MHz あたりから
目立つ**。

**コイル**: G5V-2 の 5 V 品はコイル 100 mA (50 Ω、0.5 W)。高感度品 (G5V-2-H1) なら 30 mA。
USB の 5 V から SW1 で入れる。D1 (1N4148) はコイルを切ったときの逆起電力を逃がす。

## 回路図

```circuit
title: 図1 G5V-2 の 1 回路目で通し、2 回路目で出口を GND へ
parts:
  J1: sma 2,5 mirror CH0
  K1: relay 6,5 r90
  J2: sma 11,5 CH1
  D1: diode 4,1 7,1 1N4148
  SW1: switch 7,2 9,2 l=$\mathrm{SW1}$
  BAT: battery 11,2 11,4 5 l=$\mathrm{BAT}$
  GJ1: ground 2,6
  GA2: ground 4,3
  GCOM2: ground 5,6
  GBAT: ground 11,4
  GJ2: ground 11,6
wires:
  - J1.1 -| K1.COM1
  - J1.2 -- 2,6
  - K1.NO1 -| 9,5
  - 9,5 -- 11,5 -- J2.1
  - J2.2 -- 11,6
  - K1.NC2 -| 9,5
  - K1.COM2 -| 5,6
  - K1.A2 |- 4,2
  - 4,2 -- 4,3
  - 4,2 -- 4,1
  - K1.A1 |- 7,2
  - 7,2 -- 7,1
  - 9,2 -- 11,2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/08-switch-isolation.svg)

- 1 回路目: COM1 から a 接点 (NO1) を通って J2 へ。コイルに電流を流すと閉じる
- 2 回路目: b 接点 (NC2) を出口 (J2 の側) に、COM2 を GND に。コイルに電流が無い
  (1 回路目が開いている) ときだけ、出口を GND へ落とす
- 使わないピン NC1・NO2 はどこにもつなげない。実体配線図では `unused:` に並べて ERC の「つながっていない」から外した

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (G5V-2、端面 SMA 2 つ)
unused: [K1.NC1, K1.NO2]
parts:
  J1: sma/female-edge a10 09
  K1: relay d14
  D1: diode b14 b12 1N4148
  SW1: switch a17 c17
  BAT: battery d17 g17 5
  J2: sma/female-edge x10 y9
wires:
  - a10 -- g10
  - g10 -- g11
  - k11 -- k10
  - k10 -- m10
  - m10 -- x10
  - i14 -- i15
  - i15 -- m15
  - m15 -- m10
  - d11 -- b11 red
  - b11 -- a11 red
  - a11 -- a17 red
  - b12 -- b11 red
  - c17 -- d17 red
  - b14 -- b15 black
  - b15 -- d15 black
  - d14 -- d15 black
  - d15 -- g15 black
  - g14 -- g15 black
  - g15 -- g16 black
  - g17 -- g16 black
  - g16 -- y16 black
  - y16 -- y11 black
  - 09 -- b9 black
  - b9 -- b8 black
  - b8 -- r8 black
  - r8 -- r9 black
  - r9 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/08-switch-isolation.svg)

- K1 のピンは実物の G5V-2 (DIP16 の位置のうち 8 本)。1 番 (A1) が左下
- 信号の線 (i 行) は短く。J1 → COM1、NO1 → J2 の間は、ほかの線と並べて走らせない
  (並んだ線どうしの容量も漏れになる)
- **2 回路目を使わないとき**は、NC2 から出口への線 (d 行から i13 へ下りる線) を外す。
  図3 と図4 はこの線の有り無しの比較
- 5 V (赤) は SW1 から K1 の 1 番 (A1) へ。GND (黒) は上の c 行と下の k 行で、
  J1・J2 の外皮でつながる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (perfboard の治具の目安、3-6) |
| 点数 | 101 |
| 校正 | SOLT (ケーブルの先で) |
| 表示 | S21 の Log Mag (入れたときは S11 も) |
| 平均 | −60 dB より下を読むときは、掃引を何回か重ねて平均する |

**切ったとき、2 回路目を使わない** (NC2 の線を外した) 見えるはずの画面
(接点を 1 pF にした**等価回路**)。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 切ったとき (1 回路だけ) — 100 MHz で −24 dB しか切れない (1 pF の等価回路)
dut:
  - series C 1p
traces:
  - S21 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/08-switch-isolation-1.svg)

**切ったとき、2 回路目で出口を GND へ落とした** 見えるはずの画面。設定は図3 と同じ。

```vna
device: h4
sweep: 1M-300M 101
title: 図4 2 回路目で出口を GND へ — 100 MHz で −42 dB (1 pF + 10 nH の等価回路)
dut:
  - series C 1p
  - shunt R 0 esl 10n
traces:
  - S21 logmag
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/08-switch-isolation-2.svg)

- 図3 は右上がりの直線に近い形 (1 けたで 20 dB)。300 MHz では −15 dB で、切ったつもりでも
  信号の 1/5 が通る
- 図4 は 11 MHz より下で枠の下 (−80 dB) に出る (マーカー 1 は下の縁に張り付く)。H4 の S21 のダイナミックレンジは
  300 MHz まで約 70 dB (9-4) なので、**実際の読みは床の −70 dB 前後で止まる**。
  10 MHz の −82 dB (計算値) は読めない
- 入れたとき (SW1 を入れる) は S21 が 0 dB 近くで平らになる。この画面は図にせず、
  下の表に計算値を示す

## 見るべき値

計算値 (接点 1 pF・短絡の線 10 nH・閉じた接点 15 nH は仮定)。

| 周波数 | 切った (1 回路) | 切った (2 回路目で GND) | 入れた S21 | 入れた S11 |
| --- | --- | --- | --- | --- |
| 10 MHz | −44.0 dB | −82.1 dB (床より下) | 0.00 dB | −40.5 dB |
| 100 MHz | −24.1 dB | −42.1 dB | −0.04 dB | −20.6 dB |
| 300 MHz | −14.7 dB | −23.3 dB | −0.34 dB | −11.3 dB |

**PIN ダイオードのスイッチなら** (計算だけ): 逆バイアスで切った PIN ダイオードの容量を
0.2 pF と仮定すると (品によって違う。データシートで確かめる)、同じ式で

| 周波数 | 切った (PIN 1 本、0.2 pF) |
| --- | --- |
| 10 MHz | −58.0 dB |
| 100 MHz | −38.0 dB |
| 300 MHz | −28.5 dB |

- 開いた接点 (1 pF と仮定) より容量が小さいぶん、**同じ周波数で 14 dB よく切れる**。
  入れたときは順電流 (数 mA〜10 mA) を流して数 Ω の抵抗になり、直流を分けるバイアス T (8-4) が要る
- どちらも「1 本で切るより、出口を GND へ落とす 2 段目を足す」ほうが効く。
  測った図3・図4 の差がその効き目

## 出典

- OMRON, G5V-2 データシート: ピンの配置、コイルの定格 (5 V 品 100 mA・50 Ω、高感度品 30 mA)
- 接点の容量・線のインダクタンス・PIN ダイオードの容量は仮定の値。実測で置き換える
