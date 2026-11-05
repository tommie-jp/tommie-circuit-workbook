---
book: analog-discovery
chapter: 9
id: 9-8
title: MOSFET の Id–Vgs
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 9-8 MOSFET の Id–Vgs

N ch MOSFET (2N7000) のゲート電圧 V<sub>gs</sub> を W1 で 0〜3 V に振り、ドレイン電流 I<sub>d</sub> を
ドレイン抵抗 Rd の電圧で読む。Scope の XY 表示 (X = V<sub>gs</sub>、Y = Rd の電圧) にすると、
伝達特性 (Id–Vgs 曲線) が 1 本の線で出る。9-7 のバイポーラトランジスタが電流で電流を動かすのに対し、
MOSFET は**電圧で電流を動かす**。ゲートには直流の電流がほとんど流れないので、9-7 のような入力の漏れの補正は要らない。

飽和領域では I<sub>d</sub> = K (V<sub>gs</sub> − V<sub>th</sub>)<sup>2</sup> と近似でき、√I<sub>d</sub> が V<sub>gs</sub> の 1 次式になる。
測った点を √I<sub>d</sub> で描き直し、直線の傾きから K、横軸との交点からしきい値電圧 V<sub>th</sub> を読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Vgs を W1 で振り、Rd の電圧から Id を測る
parts:
  AD:
    type: device
    at: 1,2
    label: Analog Discovery
    pins: [2+, V+, 2-, 1+, W1, 1-, GND]
  Rd: resistor 15,3.25 15,4.5 330
  Rg: resistor 7,5.5 10,5.5 100
  Q1: nmos 13,5.5 2N7000
  G1: ground 14,7
  G2: ground 4,7
wires:
  - AD.2+ -| 16,3.25
  - 16,3.25 -- 15,3.25
  - AD.V+ -| 15,3.25
  - AD.2- -| 14,4.5
  - 14,4.5 -- 15,4.5
  - Q1.D -| 15,4.5
  - AD.1+ -| 11,5.5
  - 10,5.5 -- 11,5.5
  - 11,5.5 -- Q1.G
  - AD.W1 -| 7,5.5
  - Q1.S -| 14,7
  - AD.1- -| 5,7
  - 5,7 -- 4,7
  - AD.GND -| 4,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/08-mosfet-id-vgs.svg)

- W1 → Rg (100 Ω) → ゲート。Rg はゲートと配線の容量で発振しないように入れる止め抵抗で、直流の電圧は落ちない
- CH1 (1+) はゲート、1− は GND。ソースが GND なので CH1 がそのまま V<sub>gs</sub>
- V+ (5 V) → Rd (330 Ω) → ドレイン。CH2 (2+・2−) は Rd の両端で、V<sub>Rd</sub> = I<sub>d</sub> × 330 Ω。
  Rd は I<sub>d</sub> を最大 5 V / 330 Ω = 15 mA に抑える役も持つ (しきい値の低い個体で W1 を上げすぎても壊さない)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rg: resistor c14 c21 100
  Rd: resistor d27 d22 330
  Q1: transistor g20 g21 g22 2N7000
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, W1, 1+, 2-, 2+]
wires:
  - AD.V+ -- +t8 red
  - AD.GND -- -t9 black
  - AD.1- -- -t11 black
  - AD.W1 -- a14 yellow
  - AD.1+ -- a21 orange
  - AD.2- -- a22 purple
  - AD.2+ -- +t25 gray
  - a27 -- +t27 red
  - e21 -- f21 orange
  - e22 -- f22 purple
  - j20 -- -b20 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/08-mosfet-id-vgs.svg)

- Q1 (2N7000) は表のとおり左から S・G・D (g20〜g22) で描いた。**2N7000 のピンの並びは資料で食い違う**
  (S G D と D G S の両方がある) ので、挿す前にテスターで確かめ、違えば G を真ん中に保ったまま S と D の穴を入れ替える
- Rg (c14〜c21) と Rd (d22〜d27) は上ブロックに置き、ゲート (21 列)・ドレイン (22 列) を溝越しの短い線で Q1 へ渡す
- ソース (20 列) は `j20 -- -b20` で下の − レールへ。上下の − レールは 29 列で渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Triangle、10 Hz、Offset 1.5 V、Amplitude 1.5 V (0〜3 V を往復) |
| Scope | XY 表示 (X = CH1、Y = CH2)。CH1 500 mV/div、CH2 1 V/div |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Vgs (X) と Id × 330 Ω (Y)。2.1 V を越えると 2 乗で立ち上がる (計算)
view: xy
ch1: {wave: triangle 10Hz 1.5V offset 1.5V, range: 500mV/div, position: -3div}
ch2: {wave: "= min(16.5 / 1V * max(ch1 - 2.1V, 0V)^2, 4.82V)", range: 1V/div, position: -3div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/08-mosfet-id-vgs.svg)

図3 は 2N7000 を V<sub>th</sub> = 2.1 V、K = 50 mA/V<sup>2</sup> と置いた飽和の式の計算値 (Y = 330 Ω × 50 mA/V<sup>2</sup> × (V<sub>gs</sub> − 2.1 V)<sup>2</sup>)。
V<sub>gs</sub> が 2.62 V を越えると V<sub>ds</sub> が V<sub>gs</sub> − V<sub>th</sub> より小さくなって線形領域に入り、I<sub>d</sub> は Rd で決まる
約 14.6 mA (Y = 4.82 V) で頭打ちになる。図3 は折れ目を角で描いたが、実物と LTspice の模型では丸い。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Rg | 抵抗 (1/4 W) | 100 Ω (ゲートの止め抵抗) |
| Rd | 抵抗 (1/4 W) | 330 Ω (I<sub>d</sub> を電圧に直し、15 mA までに抑える。最大 72 mW) |
| Q1 | N ch MOSFET | 2N7000 |
| — | 電源 | Analog Discovery の V+ (5 V)。最大 15 mA で 75 mW |

## 見るべき値

計算値。V<sub>th</sub> = 2.1 V、K = 50 mA/V<sup>2</sup> と仮定 (模型の値。2N7000 の V<sub>GS(th)</sub> は資料で 0.8〜3 V の幅がある)。

| V<sub>gs</sub> | I<sub>d</sub> (飽和の式) | V<sub>Rd</sub> (CH2) | V<sub>ds</sub> | √I<sub>d</sub> |
| --- | --- | --- | --- | --- |
| 2.1 V 以下 | 0 | 0 | 5 V | 0 |
| 2.2 V | 0.50 mA | 0.17 V | 4.83 V | 0.71 √mA |
| 2.4 V | 4.50 mA | 1.49 V | 3.52 V | 2.12 √mA |
| 2.5 V | 8.00 mA | 2.64 V | 2.36 V | 2.83 √mA |
| 2.6 V | 12.5 mA | 4.13 V | 0.88 V | 3.54 √mA |

√I<sub>d</sub> を V<sub>gs</sub> に対して描くと直線になる。傾きが √K (= 7.07 √mA/V)、横軸との交点が V<sub>th</sub>。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 √Id は Vgs に比例する。直線を延ばして横軸と交わる所が Vth (計算)
x: ゲート電圧 Vgs V 1.8..2.6
y: 電流の平方根 √mA 0..4
lines:
  飽和の式 √mA: sqrt(50)*max(x-2.1, 0)
  LTspice √mA:
    - 2.2 0.724
    - 2.4 2.158
    - 2.5 2.861
    - 2.6 3.550
notes:
  - mark 2.1
  - mark 2.5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/08-mosfet-id-vgs.svg)

- 直線に乗るのは 2.2〜2.6 V の飽和領域だけ。2.62 V より上は線形領域で、点は直線の下へ曲がる
- 資料の V<sub>GS(th)</sub> は「I<sub>d</sub> = 1 mA になる V<sub>gs</sub>」で定めた値で、√I<sub>d</sub> の直線の交点とは定義が違う。
  この模型では 1 mA で 2.24 V、交点で 2.10 V と 0.14 V ずれる。比べるときは同じ定義で読む
- V<sub>th</sub> は温度で下がる (目安 −数 mV/°C)。指で Q1 を温めると、図3 の立ち上がりが左へ動く

## LTspice での確かめ

`sim/08-mosfet-id-vgs.cir` で図1 を直流で解いた (W1 を 0〜3 V に掃引)。2N7000 は他の題と同じ LEVEL 1 の模型
(V<sub>TO</sub> 2.1 V、K<sub>P</sub> 0.1 A/V<sup>2</sup> = K の 2 倍、λ 0.01)。**仮定で、実測の値ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| I<sub>d</sub> (V<sub>gs</sub> = 2.2・2.4・2.5・2.6 V) | 0.50・4.50・8.00・12.5 mA | 0.52・4.66・8.18・12.6 mA | 合う (λ で 2〜4 % 多い) |
| V<sub>ds</sub> (V<sub>gs</sub> = 2.6 V) | 0.88 V | 0.84 V | 合う。まだ飽和領域 (V<sub>gs</sub> − V<sub>th</sub> = 0.5 V より大きい) |
| 頭打ちの I<sub>d</sub> (V<sub>gs</sub> = 2.8・3.0 V) | 約 14.6 mA | 14.4・14.6 mA | 合う |
| I<sub>d</sub> = 1 mA の V<sub>gs</sub> | 2.24 V | 2.24 V | 合う |
| I<sub>d</sub> = 10 mA の V<sub>gs</sub> | 2.55 V | 2.54 V | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
V<sub>GS(th)</sub> の範囲 (0.8〜3 V、I<sub>d</sub> = 1 mA) は [Vishay 2N7000 / BS170 のデータシート](https://www.vishay.com/docs/70226/70226.pdf)。
参考: [MOSFET](https://ja.wikipedia.org/wiki/MOSFET)
