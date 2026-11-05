---
book: analog-discovery
chapter: 8
id: 8-10
title: GND の取り回し — 1 点接地とループ
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-10 GND の取り回し — 1 点接地とループ

8-6 で、電流の流れる GND のレールには電位差が出ることを見た。では、電流の大きい回路 (負荷) と
小さな信号を扱う回路 (静かな回路) が同じ GND を使うとき、GND の線をどう引けば
静かな回路の「0 V」が揺れないか。ここではジャンパの引き方を 3 通りに変えて比べる。

- **直列 (A)**: 負荷の GND を静かな回路の GND へつなぎ、そこから 1 本で AD の GND (基準の点 S) へ戻す。
  負荷の戻りの電流が、静かな回路の GND の線を通る
- **1 点接地 (B)**: 負荷の GND と静かな回路の GND を、それぞれ別のジャンパで S へ戻す。
  負荷の電流は自分の線だけを通る
- **ループ (C)**: B に、負荷の GND と静かな回路の GND をつなぐジャンパを足す (「念のため」に GND どうしをつなぐとこうなる)。
  GND の線が輪 (ループ) になり、負荷の電流の一部が静かな回路の線へ回り込む

負荷は W1 で 100 Ω (オーム) を駆動し、10 mA の交流を流す。静かな回路は 1 kΩ の抵抗 1 本で代表させ、
その上の端を CH2 で S に対して読む。抵抗に電流は流れないので、CH2 は静かな回路の GND の点の電位そのものになる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 負荷と静かな回路の GND をジャンパ 3 本 (LA・LB・LC) で S へ戻す (等価回路)
parts:
  W1: sine 2,3 2,9 l=$\mathrm{W1}$
  M1: voltmeter 4,3 4,9 l=$\mathrm{CH1}$
  RL: resistor 7,3 7,6 100 l=$\mathrm{R_L}$
  LA: inductor 7,6 7,9 43.9n l=$\mathrm{L_A}$
  LC: inductor 7,6 11,6 23.2n l=$\mathrm{L_C}$
  RQ: resistor 11,3 11,6 1k l=$\mathrm{R_Q}$
  LB: inductor 11,6 11,9 13.8n l=$\mathrm{L_B}$
  M2: voltmeter 14,3 14,9 l=$\mathrm{CH2}$
  G1: ground 9,9
wires:
  - 2,3 -- 4,3
  - 4,3 -- 7,3
  - 11,3 -- 14,3
  - 2,9 -- 4,9
  - 4,9 -- 7,9
  - 7,9 -- 9,9
  - 9,9 -- 11,9
  - 11,9 -- 14,9
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/10-ground-loop.svg)

- 下の横線 (GND の記号) が基準の点 S。AD の GND・1−・2− をここに挿す
- R<sub>L</sub> の下の節点が負荷の GND の点、R<sub>Q</sub> の下の節点が静かな回路の GND の点
- L<sub>A</sub>・L<sub>B</sub>・L<sub>C</sub> は部品ではなく、ジャンパ線のインダクタンス (等価回路)。
  値は 8-3 の経験式で、穴の数から長さを出して見積もった (仮定。下の「見るべき値」)
- 直列 (A) は L<sub>A</sub> を抜き、1 点接地 (B) は L<sub>C</sub> を抜き、ループ (C) は 3 本とも挿す

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ループ (C) の配線。A は 8→28 列、B は 8→20 列のジャンパを抜く
board: half
parts:
  RL: resistor c3 c8 100
  RQ: resistor c15 c20 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, 1+, 2+, GND, 1-, 2-]
wires:
  - AD.1+ -- b3 orange [h-10]
  - AD.W1 -- a3 yellow [h-30]
  - AD.2+ -- a15 white
  - AD.GND -- c28 black
  - AD.1- -- b28 black
  - AD.2- -- a28 black
  - b8 -- b20 blue
  - e8 -- e28 black
  - d20 -- d28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/10-ground-loop.svg)

- 28 列が基準の点 S、18 列が静かな回路の GND の点、8 列が負荷の GND の点
- 黒いジャンパ 2 本が S へ戻す線 (18→28 列が L<sub>B</sub>、8→28 列が L<sub>A</sub>)。
  青いジャンパ (8→18 列) が L<sub>C</sub> で、GND どうしをつなぐ線。色を変えたのは、抜き差しする線を見分けるため
- 3 通りの差し方:

| 配線 | 挿すジャンパ | 負荷の電流の通り道 |
| --- | --- | --- |
| 直列 (A) | 18→28 (黒)・8→18 (青) | 8 → 18 → 28 列。静かな回路の線 L<sub>B</sub> を全部通る |
| 1 点接地 (B) | 18→28 (黒)・8→28 (黒) | 8 → 28 列だけ。L<sub>B</sub> には流れない |
| ループ (C) | 3 本とも | 8 → 28 列と 8 → 18 → 28 列に分かれる |

## 計器の設定

計器は Analog Discovery 3 の Wavegen と Scope。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、振幅 1 V。1 MHz と 10 MHz の 2 点 |
| Scope | CH1 = W1 (負荷の入口)、CH2 = 静かな回路 (R<sub>Q</sub> の上の端)。CH2 の Range は 5 mV/div、Average 16 回 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB) を超えるので、**BNC アダプタ**を付ける (8-6 と同じ)。
負荷の電流は 1 V / 100 Ω = 10 mA で、W1 の出せる範囲に収まる。

図3 は直列 (A) の 10 MHz。CH2 は CH1 の 1/115 ほどしか振れないので、V/div を別にした。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 直列 (A) の 10 MHz — 静かな回路の GND に 8.7 mV、CH1 より 90° 進む
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 10MHz 1V, range: 500mV/div}
ch2: {wave: sine 10MHz 8.68mV phase 88deg, range: 5mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/10-ground-loop.svg)

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| R<sub>L</sub> | 100 Ω、1/4 W | 負荷。電流 10 mA (振幅)、電力 5 mW |
| R<sub>Q</sub> | 1 kΩ、1/4 W | 静かな回路の代わり。電流はほぼ 0 |
| ジャンパ | 黒 2 本 (8 列ぶんと 20 列ぶん)・青 1 本 (12 列ぶん) | 0.64 mm (AWG22 相当) の単線。基板に沿わせて最短に曲げる |
| 電源 | 使わない | 電流は W1 から流す |

## 見るべき値

計算値。ジャンパの長さは列の数 × 2.54 mm で、8-3 の式 L (nH) = 0.2 × l × (ln(2l / 0.64) − 0.75) (l は mm) から
20 列ぶん (50.8 mm) が L<sub>A</sub> = 43.9 nH、12 列ぶん (30.5 mm) が L<sub>C</sub> = 23.2 nH、8 列ぶん (20.3 mm) が L<sub>B</sub> = 13.8 nH (**仮定**。
線どうしの相互インダクタンスと、レールや接点の抵抗は無視した)。負荷の電流 I = 10 mA (振幅)、ω (オメガ) = 2πf (π はパイ)。

| 配線 | 静かな回路の GND の電位 (式) | 1 MHz | 10 MHz |
| --- | --- | --- | --- |
| 直列 (A) | I × ωL<sub>B</sub> | 0.87 mV | **8.7 mV** |
| 1 点接地 (B) | 0 (L<sub>B</sub> に電流が流れない) | ≒ 0 | ≒ 0 |
| ループ (C) | I × L<sub>A</sub> / (L<sub>A</sub> + L<sub>B</sub> + L<sub>C</sub>) × ωL<sub>B</sub> | 0.47 mV | **4.7 mV** |

- どれも電位は電流より 90° 進む (コイルの電圧)
- ループ (C) では、負荷の電流が L<sub>A</sub> (43.9 nH) と L<sub>C</sub> + L<sub>B</sub> (37.0 nH) に、インダクタンスの逆の比で分かれる。
  回り込むのは 43.9 / 80.9 = 54 % で、静かな回路の GND は直列 (A) の半分ほど揺れる
- **GND どうしを「念のため」につなぐと、1 点接地の効果がほとんど消える。** 1 点接地は「戻りの電流の道を分ける」ことで効くので、
  道を 1 本でもつなぎ直すと電流は両方へ流れる

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 静かな回路の GND の揺れ — 直列 (A) は周波数に比例して増え、ループ (C) は A の 54 %
x: 周波数 Hz log 100k..10M
y: 電位 mV log 0.1..10
lines:
  直列 (A) mV: 10m*2*pi*x*13.8n*1000
  ループ (C) mV: 10m*0.542*2*pi*x*13.8n*1000
notes:
  - mark 1M
  - mark 5M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/10-ground-loop.svg)

1 点接地 (B) は ≒ 0 なので対数の図には描けない (図4 の下の外)。

ループにはもう 1 つ困ることがある。3 本のジャンパが作る三角の輪は、外の磁界 (近くのスイッチング電源の
コイルや、長い線を流れる電流) を拾う 1 巻きのコイルになる。8-11 (放送波) や 8-12 (スイッチング電源) の雑音が
GND に乗る入口になるので、**GND の線は輪を作らず、木の枝の形 (1 点から放射状) に引く**。

## LTspice での確かめ

`sim/10-ground-loop.cir` で、W1 → R<sub>L</sub> 100 Ω → 負荷の GND の点から、ジャンパの L (本文の仮定の値、各 10 mΩ を直列) で
S へ戻す 3 通りを交流解析した。静かな回路は R<sub>Q</sub> 1 kΩ と Scope の入力 1 MΩ。

| 配線 | 本文の数字 (1 MHz / 10 MHz) | LTspice | 判定 |
| --- | --- | --- | --- |
| 直列 (A) | 0.87 mV / 8.7 mV、+90° | 0.873 mV / 8.66 mV、+87.9° | 合う (位相の 2° は直列の 10 mΩ) |
| 1 点接地 (B) | ≒ 0 | 2 × 10⁻¹³ V / 2 × 10⁻¹¹ V | 合う |
| ループ (C) | 0.47 mV / 4.7 mV | 0.473 mV / 4.70 mV、+88.7° | 合う |
| 負荷の電流 (10 MHz) | 10 mA | 9.995 mA | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
ジャンパ線のインダクタンスの経験式は 8-3 と同じもの。

参考: [接地 (Wikipedia)](https://ja.wikipedia.org/wiki/接地)、[Ground loop (electricity) (Wikipedia)](https://en.wikipedia.org/wiki/Ground_loop_(electricity))
