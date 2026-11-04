---
book: circuits
chapter: 6
id: 6-9
title: 電流トランス
tier: 200
source: 自作
---

# 6-9 電流トランス

電流を測るには、ふつうは線を切って電流計か小さな抵抗 (分流器、シャント) を入れる (0-1・0-4)。**電流トランス** (CT、current transformer) は、
線を切らずに、**線をコアに通すだけで**交流の電流を測る部品。電力量計・ブレーカー・クランプメーターの中にある。

- コアに通した線 (1 次、巻数 N1) の電流 I1 が磁束を作り、コアに巻いた 2 次 (巻数 N2) に電流 I2 を流す。2 次に小さな抵抗 R<sub>B</sub> (負荷抵抗、バーデン) をつなぐと、
  **I2 = I1 × N1 / N2** になる (6-3 の電圧の比の逆。2 次の巻数を多くするほど電流は小さくなる)
- R<sub>B</sub> の両端の電圧 V2 = I1 × (N1 / N2) × R<sub>B</sub> を読めば、1 次の電流が分かる。1 次と 2 次は絶縁されているので、測る側の回路と計器の GND が分かれていてよい
- **直流は測れない**。直流では磁束が変わらず、2 次に電圧が出ない。周波数が低いほど 2 次の自己インダクタンス L2 で電流が漏れて (分流して)、読みが小さくなる。
  使える下限の目安は f<sub>c</sub> = R<sub>B</sub> / (2π L2) (π はパイ) で、その数倍より上の周波数で測る

この題では、FT37-43 に 2 次を 100 回巻いた電流トランスを作り、W1 の回路の電流を、分流器 RS (10 Ω。Ω はオーム) の読みと比べる。
1 次は電流の線をコアに 5 回くぐらせる (1 回より読みが 5 倍大きく、W1 の 10 mA ほどの電流でも読める)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 電流トランスで 1 次の電流を測る (1 次 5 回、2 次 100 回、RB 100 Ω)
parts:
  W1: sine 2,2 2,4.5 l=$\mathrm{W1}$
  G1: ground 2,4.5
  R1: resistor 2,2 4,2 220
  RS: resistor 4,2 6,2 10
  M1: voltmeter 4,1 6,1 l=$\mathrm{CH1}$
  T1: transformer 7.5,3 5t-100t
  G2: ground 6.5,4.5
  RB: resistor 9.5,2 9.5,4 100
  G3: ground 9.5,4.5
  M2: voltmeter 12,2 12,4 l=$\mathrm{CH2}$
wires:
  - 4,1 -- 4,2
  - 6,1 -- 6,2
  - 6,2 -- 6.5,2
  - 6.5,2 |- T1.A1
  - T1.A2 -| 6.5,4.5
  - T1.B1 -| 8.5,2
  - 8.5,2 -- 9.5,2
  - 9.5,2 -- 12,2
  - T1.B2 -| 8.5,4.5
  - 8.5,4.5 -- 9.5,4.5
  - 9.5,4 -- 9.5,4.5
  - 9.5,4.5 -- 12,4.5
  - 12,4 -- 12,4.5
style:
  grid: on
  pitch: 1.6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/circuit/09-current-transformer.svg)

- 図1 の左が測られる側の回路: W1 (20 kHz、振幅 2 V) → R1 (220 Ω、負荷の代わり) → RS (10 Ω、比べるための分流器) → T1 の 1 次 → GND。電流の山は約 8.7 mA で、W1 の範囲 (10 mA ほど) に収まる
- T1 は 1 次 5 回 (コアに線を 5 回くぐらせる)・2 次 100 回。2 次に R<sub>B</sub> (100 Ω)
- CH1 は RS の両端を差動で (1 mV が 0.1 mA)、CH2 は R<sub>B</sub> の両端

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (T1 は 1 次 5 回・2 次 100 回)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 (W1 と Scope)
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c8 220
  RS: resistor d8 d11 10
  T1: transformer/toroid b11(A1) b14(A2) b20(B1) b23(B2) FT37-43 5t:100t
  RB: resistor c20 c23 100
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - a14 -- -t14 black
  - a23 -- -t23 black
  - AD.1+ -- a8 orange
  - AD.1- -- a11 blue
  - AD.2+ -- a20 green
  - AD.2- -- -t21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/breadboard/09-current-transformer.svg)

図2 は R1・RS を左に、T1 を真ん中、R<sub>B</sub> を右に置いた。T1 のピン 4 本は、1 次の線の両端 (`b11` A1・`b14` A2) と 2 次の両端 (`b20` B1・`b23` B2)。

- 1 次は、ふつうのジャンパ線 (被覆線) をコアの穴に 5 回くぐらせ、両端をブレッドボードに挿す。2 次は 0.2〜0.3 mm のエナメル線を 100 回、コアにすき間なく巻く (2 層ほど)
- W1 (黄) は `a3`、R1 (`c3`–`c8`)、RS (`d8`–`d11`) を通して 11 列 (A1) へ。A2 (14 列) は − レール (GND) へ
- R<sub>B</sub> (`c20`–`c23`) は 2 次の両端の間。B2 (23 列) を − レールへ
- Scope の 1+ (橙) と 1− (青) は RS の両端 (`a8`・`a11`) で差動に。2+ (緑) は B1 (`a20`)、2− は − レール。AD3 の GND も − レールへ
- **2 次を開いたまま 1 次に電流を流さない**。電流トランスは 2 次を R<sub>B</sub> でふさいで使う物で、開くと 2 次に高い電圧が出る (この題の 10 mA では小さいが、大きな電流の CT では危ない)

## 計器の設定

オシロには AD3 の Scope を使う。20 kHz の 2 つの波の振幅の比と位相を比べる題で、10 MHz よりずっと低いから。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、20 kHz、振幅 2 V、オフセット 0 V (測り方では 1 kHz・5 kHz・100 kHz も) |
| Scope CH1 (RS の両端、差動) | DC、50 mV/div |
| Scope CH2 (R<sub>B</sub> の両端) | DC、50 mV/div |
| Time | 20 µs/div (µ はマイクロ。200 µs に 4 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 分流器 (CH1) と電流トランス (CH2) — 20 kHz では比 0.48 で、13° 進む
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 20kHz 174mVpp, range: 50mV/div}
ch2: {wave: sine 20kHz 83mVpp phase 13deg, range: 50mV/div}
cursors: [12.5us, 62.5us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/scope/09-current-transformer.svg)

図3 は LTspice の値で描いた想定の波形で、実測ではない。CH1 は 8.7 mA の山 × 10 Ω で 174 mVpp、CH2 は 83 mVpp。2 つの比は理想 (N1 / N2 × R<sub>B</sub> / RS = 0.05 × 100 / 10 = 0.5) の 96 %。
CH2 が少し早く山になる (13° 進む) のは、2 次の L2 に流れる分 (磁化電流) が R<sub>B</sub> の電流から引かれるため。同じ尺度で重ねたので、高さの比がそのまま読める。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | 自作の電流トランス (FT37-43) | 1 次 5 回 (被覆線をくぐらせる)・2 次 100 回 (エナメル線。約 3.5 mH、A<sub>L</sub> の目安) |
| R1 | 抵抗 (測られる回路の負荷) | 220 Ω |
| RS | 抵抗 (比べるための分流器) | 10 Ω |
| R<sub>B</sub> | 抵抗 (電流トランスの負荷) | 100 Ω |
| — | 信号源・計器 | AD3 の Wavegen W1、Scope 1+/1− (差動)・2+ |

## 見るべき値

2 次の L2 = 350 nH × 100² ≈ 3.5 mH、R<sub>B</sub> + 巻線 ≈ 101 Ω なので、下限の目安 f<sub>c</sub> ≈ 101 / (2π × 3.5 mH) ≈ 4.6 kHz。
周波数 f での比は 0.5 / √(1 + (f<sub>c</sub>/f)²)、進みは arctan(f<sub>c</sub>/f)。

| W1 の周波数 | 比 CH2 / CH1 (計算) | 比 (LTspice) | 進み (計算) | 進み (LTspice) |
| --- | --- | --- | --- | --- |
| 1 kHz | 0.106 | 0.104 | 78° | 78° |
| 5 kHz | 0.368 | 0.361 | 43° | 43° |
| 20 kHz | 0.487 | 0.478 | 13° | 13° |
| 100 kHz | 0.500 | 0.489 | 3° | 3° |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 20 kHz での CH2 / CH1 | 約 0.48 | 巻数の比と R<sub>B</sub> で決まる 0.5 の近く。CH2 ÷ 0.5 V/A で 1 次の電流が読める |
| 1 kHz での比 | 約 0.10 (理想の 2 割) | 低い周波数では L2 が R<sub>B</sub> を短絡するように働き、読みが小さい |
| 1 次を 1 回 (くぐらせるだけ) にしたとき | 20 kHz で約 17 mVpp (5 回の 5 分の 1) | 2 次の電流は 1 次の巻数に比例 |
| 1 次の線を逆向きに通したとき | CH2 の向きが逆 (180° ずれる) | 6-8 の極性と同じ |

R<sub>B</sub> を 10 Ω にすると、f<sub>c</sub> は 10 分の 1 (0.46 kHz) に下がって低い周波数まで使えるが、読みも 10 分の 1 になる。
本物の CT は 2 次を数千回巻いて L2 を大きくし、50 Hz・60 Hz (日本の商用電源の周波数。東と西で違う) でも使えるようにしてある。

## LTspice での確かめ

`sim/09-current-transformer.cir` で W1 の周波数を 1・5・20・100 kHz に振って過渡解析を走らせ、RS と R<sub>B</sub> の両端の振れと、0 を横切る時刻の差を読んだ。
L は A<sub>L</sub> の目安、結合係数 0.98・巻線の抵抗は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RS の両端 (20 kHz) | 約 174 mVpp | 173.7 mVpp | 合う |
| R<sub>B</sub> の両端 (20 kHz) | 約 83 mVpp | 83.0 mVpp | 合う |
| 比 (1 / 5 / 20 / 100 kHz) | 0.106 / 0.368 / 0.487 / 0.500 (計算) | 0.104 / 0.361 / 0.478 / 0.489 | 合う (結合係数 0.98 の分だけ 2 % 低い) |
| 進み (1 / 5 / 20 / 100 kHz) | 78 / 43 / 13 / 3° (計算) | 77.7 / 42.6 / 13.0 / 2.6° | 合う |

## 出典

自作。

参考: [変流器 (Wikipedia)](https://ja.wikipedia.org/wiki/変流器)、[Current transformer (Wikipedia)](https://en.wikipedia.org/wiki/Current_transformer)
