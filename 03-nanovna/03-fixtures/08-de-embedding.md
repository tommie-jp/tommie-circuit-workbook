---
book: nanovna
chapter: 3
id: 3-8
title: De-embedding — 治具の S2P を引く
tier: 100
source: 自作
board: PF
device: H4
---

# 3-8 De-embedding — 治具の S2P を引く

ポート延長 (3-7) は治具の線の**遅延だけ**を消す。線のインダクタンスや SMA の根元の
容量は残る。**De-embedding** は、治具そのものの S パラメータ (`.s2p`) を測っておき、
部品を挿して測った値から**行列の計算で治具のぶんを引く**方法。3-1 の直列治具で
10 Ω を測り、治具の線のせいで乗った X を計算で取り除く。

## 考え方

3-1 の治具に部品を挿すと、CH0 から見て「治具の左半分 A → 部品 → 治具の右半分 B」の
縦続になる。A と B の S パラメータが分かれば、測った値から A と B を外せる。

A と B は単独では測れない (片側が板の上で終わっている)。そこで**左半分と右半分を
部品なしで直につないだ板 (2x-Thru)** を作って測り、それを真ん中で 2 つに割って
A と B とする。割る計算は IEEE 370 に決まった手順があり、scikit-rf に入っている。

## 回路図

治具に 10 Ω を挿したときの等価回路。C は SMA の根元の容量、L は SMA から部品までの
線のインダクタンス (値は見積もり)。

```circuit
title: 図1 治具ごと測った 10 Ω の等価回路
parts:
  J1: sma b1 mirror CH0
  C1: capacitor b3 d3 1p
  L1: inductor b4 b5 10n
  R1: resistor b7 b8 10
  L2: inductor b10 b11 10n
  C2: capacitor b12 d12 1p
  J2: sma b14 CH1
  G1: ground c1
  G2: ground d3
  G3: ground d12
  G4: ground c14
wires:
  - J1.1 -- b3 -- b4
  - b5 -- b7
  - b8 -- b10
  - b11 -- b12 -- J2.1
  - J1.2 -- c1
  - J2.2 -- c14
notes:
  - box a2f0 d5h5 blue
  - box a9f5 d13h0 blue
  - text a4 blue center: 治具 A
  - text a11 blue center: 治具 B
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/08-de-embedding.svg)

- 青い枠 A・B が引きたい治具。真ん中の R1 だけが部品
- 小さい抵抗ほど治具の L が効く (10 Ω に対して、300 MHz の 20 nH は +j37.7 Ω)。
  3-1 の 100 Ω より治具の影響がはっきり見えるので、ここでは 10 Ω を測る
- 模型の値 (C 1 pF・L 10 nH) は、SMA の根元とリード 1.3 cm ぶんを見積もった仮定。
  実物の値は分からなくてよい — De-embedding は**測った 2x-Thru そのもの**を使う

## 実体配線図

2x-Thru は、3-1 の治具から部品と部品の足の間を詰めた板。**左右の線の長さを 3-1 と
同じにする** (e1〜e6 の 5 穴と e11〜e16 の 5 穴を足して、e1〜e11 の 10 穴)。

```perfboard
board:
  size: 11x8
  slots: on
title: 図2 2x-Thru の板
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e11 f12
wires:
  - e1 -- e11
  - f0 -- f2 black
  - f2 -- GND black
  - f12 -- f10 black
  - f10 -- h10 black
  - h10 -- GND black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/08-de-embedding.svg)

- 線の太さ・GND の回し方も 3-1 とそろえる。**2x-Thru と治具が違う作りだと、
  違ったぶんが部品の値に残る**
- 部品を挿す治具は 3-1 の図2 をそのまま使う

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 3 MHz〜300 MHz |
| 点数 | 100 (間隔 3 MHz。開始を間隔と同じにしておくと、IEEE 370 の計算が 0 Hz へ素直に伸ばせる。DiSlord 版は SWEEP POINTS → SET POINTS で 100 を入れる) |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S11 の Smith チャートと X (CH1 は NanoVNA の 50 Ω で終わる) |
| 保存 | 2x-Thru と、10 Ω を挿した治具を、同じ掃引で `.s2p` に保存する (2-4・2-5) |

**1. 2x-Thru** — 見えるはずの画面。線のインダクタンスで Smith の点が中心から上へずれる。

```vna
device: h4
sweep: 3M-300M 100
title: 図3 2x-Thru — 治具だけで 300 MHz に +j29.7 Ω
dut:
  - shunt C 1p
  - series L 20n
  - shunt C 1p
traces:
  - S11 smith
  - S11 x
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/08-de-embedding-1.svg)

**2. 3-1 の治具に 10 Ω** — 治具ごと測った値。

```vna
device: h4
sweep: 3M-300M 100
title: 図4 治具ごと測った 10 Ω — 300 MHz で 66.8 Ω + j27.2 Ω
dut:
  - shunt C 1p
  - series L 10n
  - series R 10
  - series L 10n
  - shunt C 1p
traces:
  - S11 smith
  - S11 x
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/08-de-embedding-2.svg)

**3. De-embedding の後** — 治具を引くと、部品だけ (50 Ω + 10 Ω = 60 Ω の 1 点) が残る。

```vna
device: h4
sweep: 3M-300M 100
title: 図5 治具を引いた後は 60 Ω の 1 点 (X は 0)
dut: series R 10
traces:
  - S11 smith
  - S11 x
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/08-de-embedding-3.svg)

## 計算 (scikit-rf)

Python の scikit-rf で、保存した 2 つのファイルから治具を引く (Python で Touchstone を
読むところは 2-13)。

```python
import skrf as rf
from skrf.calibration import IEEEP370_SE_NZC_2xThru

thru = rf.Network("2xthru.s2p")          # 図2 の板
meas = rf.Network("fixture-10ohm.s2p")   # 3-1 の治具に 10 Ω

dm = IEEEP370_SE_NZC_2xThru(dummy_2xthru=thru, name="2xthru")
dut = dm.deembed(meas)                   # A の逆 × 測った値 × B の逆
dut.write_touchstone("dut-10ohm")        # dut-10ohm.s2p ができる
```

- 書き出した `dut-10ohm.s2p` をこのファイルの隣に置き、図5 に `data: dut-10ohm.s2p` を
  書き足すと、引いた後の実測が実線で重なる
- 2x-Thru を割るとき、**左右の半分が同じ作り** (対称) だと仮定している。3-1 の治具の
  左右の線の長さをそろえるのはこのため

## 見るべき値

計算値 (模型から)。CH1 側は NanoVNA の 50 Ω で終わるので、S11 の Smith は
「部品 + 50 Ω」を読む (10 Ω なら 60 Ω)。

| 周波数 | 2x-Thru (図3) | 治具ごとの 10 Ω (図4) | 引いた後 (図5) |
| --- | --- | --- | --- |
| 100 MHz | 50.6 Ω + j9.5 Ω | 60.7 Ω + j8.8 Ω | 60.0 Ω + j0.0 Ω |
| 300 MHz | 55.8 Ω + j29.7 Ω | 66.8 Ω + j27.2 Ω | 60.0 Ω + j0.0 Ω |

- **R は数 Ω しか動かないが、X は 300 MHz で +27.2 Ω も乗る。** 部品の値 (10 Ω) より
  大きな X が、治具のせいで乗っている (S21 で見ると −0.83 dB が −1.12 dB になるだけで、
  ほとんど見分けられない)
- 引いた後は 300 MHz まで 60 Ω の 1 点に戻る。実測では、2x-Thru と治具の作りの差、
  ケーブルの揺れ (3-9) のぶんが残り、1 点のまわりに小さく散る
- ポート延長 (3-7) との違い: **遅延だけでなく、L と C の効き (大きさのずれ) も引ける**。
  その代わり 2x-Thru の板を 1 枚余分に作り、PC で計算する手間がかかる

## 出典

自作。De-embedding の手順は IEEE Std 370-2020 (電気的な治具の S パラメータの規格)、
計算は scikit-rf (`skrf.calibration.IEEEP370_SE_NZC_2xThru`) の実装による。
