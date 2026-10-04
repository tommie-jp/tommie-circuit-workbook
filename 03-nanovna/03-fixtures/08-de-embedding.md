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

A と B は単独では測れない (片側が板の上で終わっている)。そこで**部品の代わりに
線を通した板 (2x-Thru)** を作って測り、それを真ん中で 2 つに割って A と B とする。
割る計算は IEEE 370 に決まった手順があり、scikit-rf に入っている。

3-1 の治具は左右が対称でない。SMA から部品までの線が、左は 5 穴、右は 15 穴ある。
真ん中で割ると、A と B の取り方は実物とずれる。それでもこの章の直列の測り方なら
答えは狂わない。理由は「見るべき値」の後で計算して示す。

## 回路図

治具に 10 Ω を挿したときの等価回路。C は SMA の根元の容量、L は SMA から部品までの
線のインダクタンス (値は見積もり)。L3 は部品の足 (i6〜i9 の 3 穴ぶん)。

```circuit
title: 図1 治具ごと測った 10 Ω の等価回路
parts:
  J1: sma b1 mirror CH0
  C1: capacitor b3 d3 1p
  L1: inductor b4 b5 11.3n
  R1: resistor b7 b8 10
  L3: inductor b9 b10 6.8n
  L2: inductor b12 b13 34.0n
  C2: capacitor b14 d14 1p
  J2: sma b16 CH1
  G1: ground c1
  G2: ground d3
  G3: ground d14
  G4: ground c16
wires:
  - J1.1 -- b3 -- b4
  - b5 -- b7
  - b8 -- b9
  - b10 -- b12
  - b13 -- b14 -- J2.1
  - J1.2 -- c1
  - J2.2 -- c16
notes:
  - box a2f0 d5h5 blue
  - box a11f5 d15h0 blue
  - text a4 blue center: 治具 A
  - text a13 blue center: 治具 B
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/08-de-embedding.svg)

- 青い枠 A・B が引きたい治具。真ん中の R1 だけが部品
- 小さい抵抗ほど治具の L が効く (10 Ω に対して、300 MHz の 52 nH は +j98 Ω)。
  3-1 の 100 Ω より治具の影響がはっきり見えるので、ここでは 10 Ω を測る
- 模型の L は、8-3 の直線の導線の経験式 L (nH) ≈ 0.2 l {ln(2l/d) − 0.75}
  (l は mm、d = 0.64 mm) による見積もり。穴の間隔は 2.54 mm。L1・L3・L2 は一直線に
  並んだ 23 穴 (5.84 cm) の線で、全体は 52.1 nH。経験式は長さに比例しないので、
  区間ごとに当てて足すと 7.4 + 3.7 + 30.7 = 41.8 nH と小さく出る (同じ向きに電流が
  流れる区間どうしの相互インダクタンスのぶん)。そこで全体の 52.1 nH を長さで割り振り、
  左の L1 は 5 穴 (1.27 cm) で 11.3 nH、右の L2 は 15 穴 (3.81 cm) で 34.0 nH、
  足の L3 は 3 穴 (7.62 mm) で 6.8 nH とした。C は SMA の根元の 1 pF で、線の長さによらず左右同じとした。
  実物の値は分からなくてよい — De-embedding は**測った 2x-Thru そのもの**を使う

## 実体配線図

2x-Thru は、3-1 と同じ 5×7 cm の板に、部品の代わりに線を i1〜i24 の 23 穴通した板。
板は切らない。部品の足が通る i6〜i9 の 3 穴も線にする。こうすると、引いた後に
残るのは「部品」と「同じ長さの線」の差になり、足の L3 は線のぶんで消える。

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 2x-Thru の板
points:
  GND: j0
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
wires:
  - i1 -- i24
  - j0 -- j25 black
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
title: 図3 2x-Thru — 治具だけで 300 MHz に +j105.4 Ω
dut:
  - shunt C 1p
  - series L 52.1n
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
title: 図4 治具ごと測った 10 Ω — 300 MHz で 86.2 Ω + j101.8 Ω
dut:
  - shunt C 1p
  - series L 11.3n
  - series R 10
  - series L 6.8n
  - series L 34.0n
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
- 2x-Thru を割るとき、**左右の半分が同じ作り** (対称) だと仮定している。3-1 の治具は
  対称でないが、直列の部品ならこの仮定で困らない (次の節)

## 見るべき値

計算値 (模型から)。CH1 側は NanoVNA の 50 Ω で終わるので、S11 の Smith は
「部品 + 50 Ω」を読む (10 Ω なら 60 Ω)。

| 周波数 | 2x-Thru (図3) | 治具ごとの 10 Ω (図4) | 引いた後 (図5) |
| --- | --- | --- | --- |
| 100 MHz | 51.9 Ω + j30.1 Ω | 62.3 Ω + j29.4 Ω | 60.0 Ω + j0.0 Ω |
| 300 MHz | 72.1 Ω + j105.4 Ω | 86.2 Ω + j101.8 Ω | 60.0 Ω + j0.0 Ω |

- **X は 300 MHz で +101.8 Ω も乗る。** 部品の値 (10 Ω) の 10 倍を超える X が、治具の
  せいで乗っている。R も C と L のせいで 26.2 Ω ずれる (S21 で見ると −0.83 dB が
  −3.04 dB になる)
- 引いた後は 300 MHz まで 60 Ω の 1 点に戻る。実測では、2x-Thru と治具の作りの差、
  ケーブルの揺れ (3-9) のぶんが残り、1 点のまわりに小さく散る
- ポート延長 (3-7) との違い: **遅延だけでなく、L と C の効き (大きさのずれ) も引ける**。
  その代わり 2x-Thru の板を 1 枚余分に作り、PC で計算する手間がかかる

## 左右が対称でない治具を割る

2x-Thru は C 1 pF・L 52.1 nH・C 1 pF。真ん中で割ると、A は「C 1 pF + L 26.05 nH」、
B は「L 26.05 nH + C 1 pF」になる。実物の A は L1 の 11.3 nH、B は L3 と L2 の
40.8 nH だから、A は 14.75 nH 多く、B は 14.75 nH 少なく取られる。

それでも、引いた後の答えは 10 Ω にぴったり戻る。A と B の間にあるのが**直列の部品
だけ**なので、直列の L は左右どちらに置いても足し算で同じになる。
引く量の合計は 26.05 + 26.05 = 52.1 nH で、L1 + L3 + L2 = 52.1 nH と等しい。
ABCD 行列で計算すると、300 MHz で引いた後の直列のインピーダンスは 10.0 Ω + j0.0 Ω。

ずれが残るのは次の 2 つ。

- **2x-Thru の線の長さが治具と違うとき。** 板を切って足のぶん (3 穴) を詰め、
  20 穴 (経験式で 43.9 nH) の 2x-Thru にすると、治具の 52.1 nH との差の 8.2 nH が
  引かれずに残る。足の 3 穴を単独で数えた 3.7 nH より大きい。300 MHz で
  60.0 Ω + j15.5 Ω になり、X が +16 Ω ずれる。2x-Thru を治具と同じ 23 穴で作るのはこのため
- **A と B の間に、直列でない部品があるとき** (並列の C、π 形のフィルタなど)。
  L を左右で取り違えたぶんが、そのまま値のずれになる。そのときは治具を左右対称に
  作り直すか、左の腕と右の腕を別々の 2x-Thru (5 穴 + 5 穴、15 穴 + 15 穴) で測る。
  15 穴 + 15 穴は 30 穴あり、5×7 cm の板 (端から端まで 23 穴) には載らない

この章では、板を切らずに作れて、直列の部品なら誤差が出ない 23 穴の 2x-Thru を選ぶ。

## 出典

自作。De-embedding の手順は IEEE Std 370-2020 (電気的な治具の S パラメータの規格)、
計算は scikit-rf (`skrf.calibration.IEEEP370_SE_NZC_2xThru`) の実装による。
