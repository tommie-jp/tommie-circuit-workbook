---
book: analog-discovery
chapter: 2
id: 2-22
title: ロックインアンプ ch で埋もれた信号を取り出す
tier: 200
source: 自作
board: BB
device: AD3
---

# 2-22 ロックインアンプ ch で埋もれた信号を取り出す

周波数の分かっている小さな信号は、同じ周波数の正弦 (参照) を掛けて平均すると、ほかの周波数の成分が 0 に均され、
その信号の大きさだけが直流として残る。これが**ロックインアンプ**で、AD3 の Scope には Math の 1 つとして LockIn のチャネルがある
(参照の正弦を作り、入力に同相と 90° ずれの 2 つを掛け、低域通過のフィルタを通す。WaveForms 付属のヘルプ)。
1 kHz・約 1 mV の信号に、その 10 倍の妨害 (3.7 kHz) を重ね、画面では妨害しか見えない状態から 1 mV を読み出す。

**AD2 での代わり**: LockIn のチャネルは AD3 から。AD2 では Math の Simple の `×` で CH1 × CH2 を作り、Measurements の Average を
10 ms の整数倍の窓 (下の手順の 5) で読めば、同じ原理の値 (同相の成分だけ) が出る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 1 kHz の 1 mV (W1 を 1/1000 に分けた) に 10 mV の妨害 (W2) を重ねる
parts:
  M1: voltmeter 1,2 1,6 l=$\mathrm{CH1}$
  W1: sine 3,2 3,6 1
  R1: resistor 3,2 6,2 100k
  R3: resistor 6,3 6,6 100
  M2: voltmeter 8,3 8,6 l=$\mathrm{CH2}$
  R2: resistor 12,2 9,2 10k
  W2: sine 12,2 12,6 1
  G1: ground 3,6
wires:
  - 1,2 -- 3,2
  - 6,2 -- 6,3
  - 6,2 -- 8,2 -- 9,2
  - 8,2 -- 8,3
  - 1,6 -- 3,6 -- 6,6 -- 8,6 -- 12,6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/22-lockin.svg)

- W1 (1 kHz、振幅 1 V) を R1 (100 kΩ (キロオーム)) と R3 (100 Ω (オーム)) で約 1/1000 に分けて、約 1 mV の「測りたい信号」にする
- W2 (3.7 kHz、振幅 1 V) を R2 (10 kΩ) から同じ点へ入れる。R3 で約 1/100 になり、約 10 mV の妨害になる
- 混ぜた点 (CH2) から見ると、1 kHz が 0.989 mV、3.7 kHz が 9.89 mV (振幅)。妨害が 10 倍 (20 dB) 大きい
- CH1 は W1 そのもの。ロックインの参照に使う (Reference を Source にすると、CH1 から周波数と位相を拾う)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (100 kΩ と 100 Ω で 1/1000 に分ける)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, W2, GND, 1-, 2-]
  R1: resistor c5 c10 100k
  R2: resistor d17 d10 10k
  R3: resistor b10 b13 100
wires:
  - AD.1+ -- a3 orange
  - b3 -- b5 yellow
  - AD.W1 -- a5 yellow
  - AD.2+ -- a10 blue
  - a13 -- -t13 black
  - AD.W2 -- a17 green
  - AD.GND -- -t20 black
  - AD.1- -- -t22 black
  - AD.2- -- -t24 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/22-lockin.svg)

- R1 (100 kΩ) は W1 の 5 列から混ぜる点の 10 列へ、R2 (10 kΩ) は W2 の 17 列から 10 列へ、R3 (100 Ω) は 10 列から 13 列へ渡し、13 列を上の − レール (GND) へ落とす
- 2+ (青) は 10 列。1+ (橙) は 3 列に挿し、黄の線で W1 の 5 列とつなぐ
- 1 mV を見るので、CH2 の線 (2+ と 2−) は短くして寄り添わせ、W2 の線から離す。W2 の線と並べると、線どうしの容量で妨害が増える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Sine、1 kHz、Amplitude 1 V |
| Wavegen (W2) | Sine、3.7 kHz、Amplitude 1 V |
| Scope (CH1) | DC、500 mV/div。Trigger は CH1、Rising、0 V |
| Scope (CH2) | DC、5 mV/div |
| Time | 図3 は 500 µs/div (µs はマイクロ秒)。ロックインの値を読むときは 20 ms/div (下の理由) |
| Math (LockIn) | Input: CH2、Reference: Source (CH1)、Filter: Butterworth の低域通過 (Cutoff 約 16 Hz、2 次)、Gain ×1、Output: Amplitude (R) |

LockIn の Output の Amplitude (R) は、入力のうち参照と同じ周波数の成分の**実効値**を出す (ヘルプ)。ほかに Real (X、同相)・Imag (Y、90° ずれ)・
Phase (Θ (シータ)) を選べる。フィルタが落ち着くまで (2 次で 16 Hz なら約 40 ms) は値が動くので、取り込みの時間を 200 ms (20 ms/div) にして右半分を読む (目安)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH2 は妨害 (3.7 kHz) ばかり、ロックイン (赤) は 0.699 mV を出す
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: = 0.989mV * sin(2 * pi * 1kHz * t) + 9.89mV * sin(2 * pi * 3.7kHz * t), range: 5mV/div}
math: {expr: 0.699mV + 0 * ch1, range: 200uV/div, position: -3div}
measure: [vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/22-lockin.svg)

図3 は理想の形。CH2 は 3.7 kHz の妨害がほとんどで、1 kHz の 1 mV は形の小さなゆがみにしか見えない (CH2 の Vpp 21.8 mV)。
赤い線 (フェンスでは Math の位置) がロックインの出力で、落ち着いたあとの理想の値 0.699 mV (= 0.989 mV / √2) を一定の線で描いた。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (信号を分ける上側) | 100 kΩ |
| R3 | 抵抗 (分ける下側) | 100 Ω |
| R2 | 抵抗 (妨害を入れる) | 10 kΩ |
| — | 計器 | AD3 の Wavegen (W1・W2) と Scope (1+ = W1、2+ = 混ぜた点)、Math の LockIn |

## 見るべき値

表の値は計算値。Scope の入力抵抗 1 MΩ を負荷に入れた。

| 項目 | 期待する値 | 計算・読み方 |
| --- | --- | --- |
| CH2 の 1 kHz の成分 (振幅) | 0.989 mV | 1 V × (R3 ∥ R2 ∥ 1 MΩ) / (R1 + R3 ∥ R2 ∥ 1 MΩ) |
| CH2 の 3.7 kHz の成分 (振幅) | 9.89 mV | 1 V × (R3 ∥ R1 ∥ 1 MΩ) / (R2 + R3 ∥ R1 ∥ 1 MΩ) |
| CH2 の Vpp | 21.8 mV | ほぼ妨害の 2 × (9.89 + 0.99) mV |
| ロックインの R (実効値) | 0.699 mV | 0.989 mV / √2 |
| R から戻した振幅 | 0.989 mV | R × √2。上の 1 行めと合えば、妨害を通り抜けて読めている |
| 掛けたあとの妨害の周波数 | 2.7 kHz と 4.7 kHz | 3.7 kHz ∓ 1 kHz。16 Hz の 2 次の低域で −84 dB 以下 (RC 2 段で計算) |
| 1 kHz の成分は ADC の何段か | 約 3 段 | 0.989 mV / 0.336 mV (5 mV/div の帯の 14 bit の 1 段、2-14)。妨害と雑音で段がばらけるので、平均すれば 1 段より細かく読める |

確かめ方の手順:

1. CH2 を見て、1 kHz の信号が目では分からないことを確かめる。Measurements の Vpp は 21.8 mV で、ほぼ妨害の大きさ
2. LockIn の R を読む (0.699 mV)。W1 の振幅を 0.5 V に下げると R も半分 (0.350 mV) になる。**R は信号の大きさに比例する**
3. W2 の振幅を 2 V に上げても R はほとんど変わらない。ロックインは周波数の違う妨害を通さない
4. W2 を 1.005 kHz にする。掛けたあとの差は 5 Hz で、16 Hz の低域を通り抜け、R が 5 Hz でうねる。
   **ロックインが分けられるのは、フィルタの帯域より離れた周波数だけ**。Cutoff を 1 Hz に下げればうねりは消えるが、落ち着くまでの時間が長くなる
5. AD2 の代わりのやり方: Math で CH1 × CH2、Measurements の Average を Time 10 ms/div (100 ms の窓) で読む。
   1 kHz と 3.7 kHz の周期はどちらも 10 ms に整数回入るので、妨害の掛け算は平均で 0 になり、平均は 1 V × 0.989 mV / 2 = 0.494 mV·V。
   1 V / 2 で割って振幅 0.989 mV に戻す

## LTspice での確かめ

`sim/22-lockin.cir` で、図1 の回路に、ロックインの計算を振る舞いの電源で真似たもの (√2 sin と √2 cos を掛け、RC 2 段 (各 τ (タウ、時定数) 10 ms、約 16 Hz) で均し、R = √(X² + Y²)) をつないで過渡解析した。
参照は W1 と同相の理想の正弦、Scope の入力は 1 MΩ と**仮定**した。WaveForms の LockIn のフィルタの形 (Butterworth) とは同じではない (実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| CH2 の Vpp | 21.8 mV | 21.76 mV | 合う |
| ロックインの R (0.8〜1 s の平均) | 0.699 mV | 0.6993 mV | 合う |
| 同相の X | R と同じ (参照が同相) | 0.6993 mV | 合う |
| R に残る妨害のうねり | 十分小さい | 0.64 µVpp (R の 0.1 %) | 合う |

落ち着くまでの時間 (2 段で 90 % に届くまで、3.89 τ = 39 ms) は算術で確かめた。

## 出典

自作。LockIn のチャネルの働き (同相と 90° の掛け算、Reference の Internal / Source、Output の R・X・Y・Θ) は WaveForms 付属のヘルプ (Oscilloscope の LockIn Math Channel の節) による。

参考: [ロックインアンプ (Wikipedia)](https://ja.wikipedia.org/wiki/ロックインアンプ)、[Lock-in amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Lock-in_amplifier)
