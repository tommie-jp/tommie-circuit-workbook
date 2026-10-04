---
book: nanovna
chapter: 9
id: 9-3
title: GND を面で取る — perfboard と銅張りの差を S21 で
tier: 100
source: 自作
board: CB
device: V2
---

# 9-3 GND を面で取る — perfboard と銅張りの差を S21 で

同じ「ただのスルー」(中心導体を 1 本の線でつなぐだけ) を、**perfboard** (3-6 の表の、
SMA を寄せた 3 穴・7.6 mm の短いスルー) と**両面銅張り基板のマイクロストリップ** (裏が全面 GND) で作り、
V2 で 3 GHz まで比べる。

perfboard では、信号の線と GND の戻りの線が離れて走り、その間の輪 (ループ) が
**インダクタンス**になる。3-6 の表ではこれを約 3.7 nH と見積もった (以下は丸めて 5 nH で計算する。目安)。周波数を上げると
このリアクタンスが 50 Ω に近づき、通り抜けが落ちて反射が増える。
銅張り基板では、信号の線のすぐ下 (1.6 mm) に GND の面があり、戻りの電流は線の真下の
面を流れる。線と面が**決まった Z0 の伝送線路**になるので、長さがあっても反射しない。

## この実験で確かめる式

**perfboard** (等価回路): 直列の L = 5 nH (3-6 の見積り)。
S21 = 100 / (100 + j 2π f L)、S11 = j 2π f L / (100 + j 2π f L)。
2π f L が 100 Ω になる周波数 (f = 3.2 GHz) で S21 は −3 dB。

**銅張り**: 幅 w = 3.0 mm、厚さ h = 1.6 mm、比誘電率 4.4 (FR4 と仮定) のマイクロストリップは
Z0 = 50.8 Ω、実効比誘電率 3.3 (速度係数 0.55)。Z0 が 50 Ω にほぼ等しいので、長さによらず
S11 は小さく (−36 dB 前後)、S21 は 0 dB (損失は見ない)。

## 回路図

perfboard のスルーの**等価回路**。3-6 で見積もった 5 nH を、中心の線 (L1) と
GND の戻り (L2) に半分ずつ分けて描いた。

```circuit
title: 図1 perfboard のスルーの等価回路
parts:
  J1: sma c2 mirror CH0
  L1: inductor c4 c7 2.5n
  J2: sma c9 CH1
  L2: inductor e4 e7 2.5n
  G1: ground f2
wires:
  - J1.1 -- c4
  - c7 -- J2.1
  - J1.2 -- e2
  - e2 -- e4
  - e2 -- f2
  - e7 -| J2.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/circuit/03-ground-plane.svg)

- CH1 の外皮 (J2 の GND) は、L2 を通ってしか CH0 の外皮 (J1 の GND) へ戻れない。
  **戻り道のインダクタンスも、信号の線のインダクタンスと同じく効く** (S21 で見えるのは L1 + L2)
- 銅張り基板では L1・L2 の代わりに 50 Ω の伝送線路 (40 mm) が入る

## 実体配線図

perfboard の側は、3-6 の図2 の基板の SMA を寄せて中心導体の間を 3 穴 (7.6 mm) にしたスルーを使うので、ここでは描かない。3-6 の図2 そのもの (幅いっぱいの 23 穴、約 52 nH) は使わない。
銅張りの側は、5×7 cm の両面基板から 40 mm × 20 mm を切り出して組む。

```copper
board:
  size: 40x20mm
  ground: back
title: 図2 銅張りのスルー (マイクロストリップ 40 mm)
f: 3G
copper:
  L1: line 0,10 40,10 3.06mm
parts:
  J1: sma left 10 CH0
  J2: sma right 10 CH1
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/copper/03-ground-plane.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、40 mm × 20 mm。裏は全面の銅 (GND) |
| 線 | 表の中央に**幅 3.06 mm・長さ 40 mm** (計算値 50.0 Ω)。まわりの表の銅は剥がす (線から 3 mm 以上離す) |
| 端面 SMA (J1・J2) | 左右の縁に 1 つずつ。中心ピンを線の端へ、外皮の脚は、基板の縁で裏のベタへ半田付け |

- 線の長さ 40 mm は、perfboard のスルー (7.6 mm) の 5 倍ある。**それでも反射しない**のが、
  GND を面で取った伝送線路の強み。perfboard で 3-3 の長い銅張り基板 (3.8 cm、約 27 nH、3-6) を
  使うと、590 MHz で S21 が −3 dB まで落ちる (計算値)
- 部品は無く、流れる電流は NanoVNA の出力 (0 dBm 以下) だけで、線に対して十分小さい
- 線の幅は 3.06 mm で 50 Ω (図の線路のラベルの値、Z0 の近似式による。本文の S21・S11 の値は 3.0 mm・50.8 Ω で計算してある)。
  基板の比誘電率が違えば幅も変わる (9-7 で測る)

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜3 GHz (V2。50 kHz から始めると S11 が低い所で急に上がる形が左端に潰れる) |
| 点数 | 301 |
| 校正 | SOLT (ケーブルの先で。9-2 の付属キットの限界は承知の上で) |
| 表示 | S21 と S11 の Log Mag (1 つの枠に重ねる) |

**perfboard のスルー** (5 nH の等価回路) の見えるはずの画面。

```vna
device: v2
sweep: 100M-3G 301
title: 図3 perfboard のスルー — 3 GHz で S21 −2.8 dB・S11 −3.3 dB (等価回路)
dut:
  - series R 0 esl 5n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 500M
  - 1G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/03-ground-plane-1.svg)

**銅張りのマイクロストリップ** (50.8 Ω・40 mm) の見えるはずの画面。設定は図3 と同じ。

```vna
device: v2
sweep: 100M-3G 301
title: 図4 銅張りのマイクロストリップ — S21 は 0 dB (上端)、S11 は −36 dB 前後
dut:
  - line 50.8 40mm vf 0.55
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 500M
  - 1G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/03-ground-plane-2.svg)

- 図3 は、S21 が周波数とともに下がり、S11 が上がって 3 GHz 近くで**ほぼ交わる**
  (通る量と跳ね返る量が同じくらい)。S21 の落ち方は 3 GHz でも 2.8 dB で、10 dB/目盛の
  枠では上端の近くに留まる。**反射の差のほうがずっと大きく出る**のがこの図の中身
- 図4 は S21 が 0 dB の上端に乗ったまま。S11 は 50.8 Ω と 50 Ω のわずかな違いのぶんだけで、
  線の長さで波打つ (線が半波長になる 2.06 GHz で谷)。実物では FR4 の損失で、3 GHz で S21 が 0.5 dB ほど落ちる (目安)
- 差が出始めるのは 300 MHz あたり (3-6 の「perfboard は 300 MHz くらいまで」と同じ所)

## 見るべき値

計算値 (perfboard は 5 nH の等価回路、銅張りは損失の無い 50.8 Ω の線)。

| 周波数 | perfboard の S21 | perfboard の S11 | 銅張りの S21 | 銅張りの S11 |
| --- | --- | --- | --- | --- |
| 500 MHz | −0.11 dB | −16.2 dB | 0.00 dB | −39.2 dB |
| 1 GHz | −0.41 dB | −10.5 dB | 0.00 dB | −36.0 dB |
| 3 GHz | −2.76 dB | −3.28 dB | 0.00 dB | −36.1 dB |

- **GHz で S11 が 30 dB 以上違う**。治具の反射がこれだけあると、治具に載せた部品の反射は
  埋もれて読めない。GHz の治具を銅張りで作るのはこのため (3-13・8-6)
- perfboard でも、GND の線を太く短くし、信号の線に沿わせると 5 nH は減る。ただし面の
  GND (線の真下を戻る) にはかなわない

## 出典

自作。マイクロストリップの Z0 と実効比誘電率は Hammerstad の近似式で計算した。
