---
book: analog-discovery
chapter: 8
id: 8-13
title: perfboard の GND 面 (銅テープ) の効果
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: PF
---

# 8-13 perfboard の GND 面 (銅テープ) の効果

8-3 ではジャンパ 1 本のインダクタンスを測った。実際の回路で効くのは、信号の線と、その電流が戻ってくる
GND の線が作る**輪 (ループ) のインダクタンス**だ。輪の面積が大きいほどインダクタンスが大きい。
ユニバーサル基板の半田面に銅テープを貼って GND の面にすると、戻りの電流は信号の線の真下のテープを流れ、
輪の面積は基板の厚さ (1.6 mm) ぶんまで小さくなる。

ここでは同じ 46 mm の信号の線について、(A) 戻りの線を 10 mm 離して引いたときと、(B) 戻りを銅テープの面に任せたときで、
輪のインダクタンスを 8-3 と同じ基準抵抗の方法で比べる。周波数が 10 MHz なので、ブレッドボードではなく
ユニバーサル基板に組む (ブレッドボードの列の容量とレールが、測りたい輪より大きく効くため)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗 Rref と、信号の線と戻りが作る輪 Lloop (等価回路)
parts:
  W1: sine 2,3 2,7 l=$\mathrm{W1}$
  M1: voltmeter 4,1.5 7,1.5 l=$\mathrm{CH1}$
  Rref: resistor 4,3 7,3 2.7 l=$\mathrm{R_{ref}}$
  Lloop: inductor 9,3 9,7 63.2n l=$\mathrm{L_{loop}}$
  M2: voltmeter 11,3 11,7 l=$\mathrm{CH2}$
  G1: ground 9,7
wires:
  - 2,3 -- 4,3
  - 4,3 -- 4,1.5
  - 7,1.5 -- 7,3
  - 7,3 -- 9,3
  - 9,3 -- 11,3
  - 2,7 -- 9,7
  - 9,7 -- 11,7
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/13-copper-tape-plane.svg)

- L<sub>loop</sub> は部品ではなく、信号の線と戻りの道が作る輪のインダクタンス (等価回路)。図の値は戻りの線 (A) のときの見積り
- CH1 は R<sub>ref</sub> の両端 (電流)、CH2 は輪の両端。8-3 と同じく、CH2 / CH1 の比と R<sub>ref</sub> から L を出す

## 実体配線図

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図2 白が信号の線、黒が A の戻りの線、青の枠が B の銅テープ (部品面)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  IN: c10
  GND: f6
parts:
  Rref: resistor c10 f10 2.7
wires:
  - f10 -- x10 white
  - x10 -- x6 black
  - x6 -- f6 black
notes:
  - box f4 x12 blue
  - text m13 blue bold: B の銅テープ (半田面に貼る)
  - mark c10 yellow
  - mark f10 yellow
  - mark f6 yellow
  - text b10 red large bold left: W1 1+
  - text f12 red large bold center: 1- 2+
  - text f5 red large bold center: 2- GND
  - parts
style:
  back: on
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/perfboard/13-copper-tape-plane.svg)

- 白の信号の線は f10 から x10 まで 18 穴 (45.7 mm)。A では黒の戻りの線で x10 → x6 → f6 と戻す (信号の線から 4 行、10.16 mm 離れる)
- B では黒の線を外し、半田面の f4〜x12 (青の枠。字は m13) に銅テープを貼る。x10 と f6 の穴のランドをテープに半田付けし、戻りの電流をテープに流す。
  テープはほかのランドに触れないよう、穴の周りを小さく切り抜く (目安 1.5 mm)
- 黄色の丸は AD3 を挟む所。W1 と 1+ は c10、1− と 2+ は f10、2− と GND は f6

## 計器の設定

計器は Analog Discovery 3 の Wavegen と Scope (8-3 と同じ。BNC アダプタ付き)。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 MHz**、**Amplitude 30 mV** (電流を 10 mA 以下にする) |
| Scope | CH1 = R<sub>ref</sub> の両端、CH2 = 輪の両端。Range は両方 10 mV/div、Average 16 回 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |
| 手順 | A (戻りの線) を測る → 黒の線を外して銅テープを貼り、B を測る |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB) を超えるので、BNC アダプタ (Scope 30+ MHz、Wavegen 12 MHz @ −3 dB) を付ける。
CH1 と CH2 の比で読むので、帯域の影響は小さい (目安)。読んだ値から L = (V<sub>CH2</sub> / V<sub>CH1</sub>) × R<sub>ref</sub> / (2πf) (π (パイ))。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 A (戻りの線) の 10 MHz — 輪の電圧 (CH2) が電流 (CH1) より大きく、90° 進む
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 10MHz 16.9mV, range: 10mV/div}
ch2: {wave: sine 10MHz 24.8mV phase 90deg, range: 10mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/13-copper-tape-plane.svg)

B (銅テープ) では CH1 が 26.5 mV に増え、CH2 が 14.0 mV に減る。2 つの大小が入れ替わるのが目印。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| R<sub>ref</sub> | 2.7 Ω (オーム)、1/4 W | 基準抵抗。輪のリアクタンス (1.4〜4 Ω) と桁を合わせた。電流 9.8 mA (振幅) で 0.13 mW |
| 信号の線・戻りの線 | 0.64 mm の単線 (スズめっき線) | 基板に沿わせて張る |
| 銅テープ | 導電性の粘着の銅箔テープ、幅 25 mm 程度を 2 枚 | B のときだけ。f4〜x12 の範囲に貼る |
| ユニバーサル基板 | 5×7 cm を横に使う (7x5cm)、1.6 mm の FR-4 | 標準の板 |
| 電源 | 使わない | W1 から流す |

## 見るべき値

計算値。線の半径 r = 0.32 mm、長さ l = 45.7 mm。A は 2 本の平行線 (間隔 d = 10.16 mm) とみて
L ≒ 0.4 × l × ln(d / r) nH (l は mm) = 63.2 nH、B は面の上の線 (面までの高さ h = 1.6 + 0.32 = 1.92 mm) とみて
L ≒ 0.2 × l × ln(2h / r) nH = 22.7 nH (どちらも**仮定**の近似。輪の端の短い辺と、テープの切り抜きは無視した)。

| 条件 | L<sub>loop</sub> | X<sub>L</sub> (10 MHz) | 電流 | CH1 (R<sub>ref</sub>) | CH2 (輪) |
| --- | --- | --- | --- | --- | --- |
| A 戻りの線 (10 mm 離す) | 63.2 nH | 3.97 Ω | 6.25 mA | 16.9 mV | **24.8 mV** |
| B 銅テープの面 | 22.7 nH | 1.43 Ω | 9.82 mA | 26.5 mV | **14.0 mV** |

- **GND の面で輪のインダクタンスが約 1/2.8 になる** (63.2 → 22.7 nH)。面の上では戻りの電流が信号の線の真下に集まり、
  輪の面積が線と面の間の 1.9 mm 幅ぶんになるため
- 面にしても 0 にはならない。L は高さ h の対数で効くので、h を半分にしても L は 2 割ほどしか減らない。
  効くのは「戻りの道を信号の線に寄せる」ことで、戻りの線を信号の線に沿わせて 2 本並べるだけでも (d を小さくする) 同じ向きに効く
- 8-10 のループ、8-11 のアンテナ、8-12 のレールの揺れは、どれも輪の面積と線のインダクタンスが入口だった。
  GND の面はそれをまとめて小さくする

## LTspice での確かめ

`sim/13-copper-tape-plane.cir` で、W1 30 mV → R<sub>ref</sub> 2.7 Ω → L<sub>loop</sub> (63.2 nH / 22.7 nH、本文の仮定) を 10 MHz で交流解析した。

| 条件 | 本文の数字 (電流・CH1・CH2) | LTspice | 判定 |
| --- | --- | --- | --- |
| A 戻りの線 | 6.25 mA・16.9 mV・24.8 mV、+90° | 6.247 mA・16.87 mV・24.81 mV、+90.0° | 合う |
| B 銅テープ | 9.82 mA・26.5 mV・14.0 mV、+90° | 9.822 mA・26.52 mV・14.01 mV、+90.0° | 合う |

L の近似式 (平行線と面の上の線) の値そのものは、式の算術で出した (LTspice は L を与えて解いただけ)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
平行線と面の上の線のインダクタンスは、電線のインダクタンスに関する一般的な近似式による。

参考: [インダクタンス (Wikipedia)](https://ja.wikipedia.org/wiki/インダクタンス)
