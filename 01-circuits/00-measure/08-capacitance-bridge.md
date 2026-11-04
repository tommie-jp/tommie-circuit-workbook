---
book: circuits
chapter: 0
id: 0-8
title: コンデンサ容量計 — ブリッジで測る
tier: 200
source: 自作
board: BB
era: 古
---

# 0-8 コンデンサ容量計 — ブリッジで測る

1-7 のホイートストンブリッジは、直流で 4 本の抵抗の釣り合いを取って、知らない抵抗を測った。
同じ形の 4 辺のうち 2 辺をコンデンサにし、交流で釣り合いを取れば、**知らないコンデンサの容量**が測れる。
この形をド・ソーティのブリッジ (De Sauty bridge) という。容量計がテスターに入る前は、
発振器とヘッドホン (釣り合うと音が消える) でこうして容量を測った。

釣り合いの条件は、左右の辺が同じ分圧比になること。基準のコンデンサ C<sub>s</sub> と抵抗 R<sub>1</sub>、
測るコンデンサ C<sub>x</sub> と抵抗 R<sub>2</sub> が、同じ時定数を持てばよい。

**C<sub>s</sub> × R<sub>1</sub> = C<sub>x</sub> × R<sub>2</sub>、つまり C<sub>x</sub> = C<sub>s</sub> × R<sub>1</sub> / R<sub>2</sub>**

周波数にも信号の大きさにもよらない (どちらの辺も同じ CR の分圧なので、周波数が変わっても比はそろって動く)。
R<sub>1</sub> と R<sub>2</sub> の比は可変抵抗 1 本のつまみで動かすので、つまみの位置がそのまま容量の目盛りになる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ド・ソーティのブリッジ。P と Q の差 (CH1) が 0 になるまで P1 を回す
parts:
  W1: sine 2,3 2,5 l=$\mathrm{W1}$
  G1: ground 2,5
  M2: voltmeter 4,3 4,5 l=$\mathrm{CH2}$
  G2: ground 4,5
  CS: capacitor 6,2 6,4 100n
  CX: capacitor 10,2 10,4 47n
  R1: resistor 6,4 6,6 1k
  R2: resistor 10,4 10,6 1k
  M1: voltmeter 7,4 9,4 l=$\mathrm{CH1}$
  P1: potentiometer 10,8 6,8 10k
  G3: ground 8,9
wires:
  - 2,3 -- 2,2
  - 2,2 -- 4,2
  - 4,2 -- 4,3
  - 4,2 -- 6,2
  - 6,2 -- 10,2
  - 6,4 -- 7,4
  - 9,4 -- 10,4
  - 6,6 -- 6,8
  - 10,6 -- 10,8
  - P1.w -- 8,9
notes:
  - text 5.6,4: P
  - text 10.4,4: Q
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/circuit/08-capacitance-bridge.svg)

Wavegen の W1 から 1 kHz・2 Vpp の正弦波を上の点 (A) に入れる。左の辺は `CS` と `R1` + `P1` の左側、
右の辺は `CX` と `R2` + `P1` の右側で、`P1` のワイパーが GND。CH1 を P (+) と Q (−) の間に差動でつなぎ、2 点の差を見る。

- `P1` のワイパーから左のピンまでを R<sub>a</sub>、右のピンまでを R<sub>b</sub> (R<sub>a</sub> + R<sub>b</sub> = 10 kΩ) とすると、
  R<sub>1</sub> = 1 kΩ + R<sub>a</sub>、R<sub>2</sub> = 1 kΩ + R<sub>b</sub>
- 比 R<sub>1</sub> / R<sub>2</sub> は 1 k / 11 k から 11 k / 1 k まで動くので、C<sub>s</sub> = 0.1 µF (マイクロファラド) で
  **C<sub>x</sub> = 9.1 nF〜1.1 µF** が測れる。`R1`・`R2` の 1 kΩ は、つまみの端で比が 0 や無限大にならないための抵抗
- 例: C<sub>x</sub> = 47 nF なら R<sub>1</sub> / R<sub>2</sub> = 0.47 で釣り合う。R<sub>1</sub> + R<sub>2</sub> = 12 kΩ から
  R<sub>1</sub> = **3.84 kΩ**、R<sub>2</sub> = **8.16 kΩ** (R<sub>a</sub> = 2.84 kΩ、R<sub>b</sub> = 7.16 kΩ)
- つまみが真ん中 (R<sub>1</sub> = R<sub>2</sub> = 6 kΩ) だと、P は W1 の 0.967 倍、Q は 0.871 倍で、
  差は **0.50 Vpp** (計算値) 残る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上のブロックにコンデンサ 2 本、下のブロックに抵抗と P1
board: half
parts:
  CS: capacitor/film b3 b8 100n
  CX: capacitor/ceramic b12 b18 47n
  R1: resistor g8 g12 1k
  R2: resistor g14 g18 1k
  P1: potentiometer i12(1) i13(W) i14(3) 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 2-, 1+, 2+, 1-]
wires:
  - AD.GND -- -t1 black
  - AD.W1 -- a3 yellow
  - AD.2- -- -t5 black
  - AD.1+ -- a8 orange
  - AD.2+ -- a12 blue
  - AD.1- -- a18 green
  - d3 -- d12 yellow
  - e8 -- f8 orange
  - e18 -- f18 green
  - j13 -- -b13 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/breadboard/08-capacitance-bridge.svg)

上のブロックの列 3 と列 12 が図1 の A (W1 の入る点。黄の線でつなぐ)、列 8 が P、列 18 が Q。

- **上のブロック**: `CS` (フィルム 0.1 µF) を列 3 から列 8 へ、測る `CX` を列 12 から列 18 へ。CH2 の 2+ は列 12 (A)
- **P と Q を下へ渡す**: 列 8 (P) は橙、列 18 (Q) は緑の線で下のブロックへ。CH1 の 1+ が P、**1− が Q** (差動で測るので、1− は GND に落とさない。色も黒にしない)
- **下のブロック**: `R1` は列 8 から列 12、`R2` は列 18 から列 14。`P1` (半固定抵抗) の 3 本のピンを列 12・13・14 に挿し、ワイパー (列 13) を下の − レールへ
- 上下の − レールは列 29 でつなぐ。直流の電源は使わない (Supplies は切ったまま)

測るコンデンサを替えるときは `CX` (列 12〜18) だけを差し替える。電解コンデンサを測るなら + を列 12 (A の側) にする
(この回路では両端に直流がかからないので、向きは目印だけ)。

## 計器の設定

計器は AD3 の Wavegen と Scope。1 kHz の正弦の振幅の差を見るので、時間の波形が読める Scope を使う
(1 kHz は耳でも聞こえる。昔のヘッドホンの代わりに、CH1 の振幅で釣り合いを読む)。

| 項目 | 値 |
| --- | --- |
| Wavegen W1 | 正弦波、1 kHz、振幅 1 V (2 Vpp)、オフセット 0 V |
| Scope CH1 | 1+ を P、1− を Q (差動)。100 mV/div から始め、釣り合いに近づいたら 10 mV/div へ下げる |
| Scope CH2 | 2+ を A、2− を GND。500 mV/div |
| 時間 | 200 µs/div (1 kHz の 2 周期) |
| トリガ | CH2 の立ち上がり、0 V |

W1 から流れる電流は 0.2 mA ほどで、W1 の約 10 mA に収まる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 つまみが真ん中 — P と Q の差 (CH1) が 0.50 Vpp 残る
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 504mVpp phase -45.7deg, range: 100mV/div}
ch2: {wave: sine 1kHz 2Vpp, range: 500mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/scope/08-capacitance-bridge.svg)

図3 はつまみが真ん中 (R<sub>1</sub> = R<sub>2</sub> = 6 kΩ) で、`CX` が 47 nF のとき (CH1 は CH2 の 5 倍の尺度で拡大してある)。`P1` を回して CH1 の振幅が一番小さい所を探す。
釣り合いでは CH1 がほぼ平らになる (理想のコンデンサなら 0 V)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| CS | フィルムコンデンサ (基準) | 0.1 µF (104)。誤差 ±5 % 以内の品。容量の読みの誤差はほぼこれで決まる |
| CX | 測るコンデンサ | 例: 積層セラミック 47 nF (473)。9.1 nF〜1.1 µF のもの |
| R1, R2 | 抵抗 (1/4 W) | 1 kΩ |
| P1 | 半固定抵抗 (B カーブ) | 10 kΩ (B10K) |
| — | 信号 | AD3 の W1 (1 kHz、2 Vpp) |

## 見るべき値

釣り合ったら W1 を止め、`P1` を抜いてテスターで R<sub>a</sub> (列 12〜13 のピンの間) と R<sub>b</sub> (列 13〜14) を測る。
C<sub>x</sub> = 0.1 µF × (1 kΩ + R<sub>a</sub>) / (1 kΩ + R<sub>b</sub>) で容量を出す。

| 測る所 | 期待する値 (CX = 47 nF の計算値) | 分かること |
| --- | --- | --- |
| つまみが真ん中のときの CH1 | 0.50 Vpp、W1 より 46° 遅れ | 釣り合っていないと差が残る |
| 釣り合ったときの CH1 | ほぼ 0 (10 mV/div で平ら) | ここで C<sub>s</sub>R<sub>1</sub> = C<sub>x</sub>R<sub>2</sub> |
| 釣り合いから R<sub>a</sub> を 100 Ω ずらしたときの CH1 | 約 27 mVpp | 100 Ω (容量で約 1.2 %) のずれが読める。釣り合いの鋭さ |
| R<sub>a</sub>・R<sub>b</sub> (テスター) | 2.84 kΩ・7.16 kΩ | |
| C<sub>x</sub> の計算 | 0.1 µF × 3.84 k / 8.16 k = 47 nF | 表示の値と、部品の誤差 (セラミックの X7R は ±10 %) の内か |

**周波数を 500 Hz や 2 kHz に変えても、釣り合いの位置は変わらない** (釣り合いの条件に周波数が入っていないため)。
変わるなら、`CX` に損失 (誘電体の損や漏れ電流) があって、純粋なコンデンサと見なせない。
そのときは CH1 が 0 まで下がらず、小さな谷で止まる。電解コンデンサはこの谷が深くならないことが多い。

## LTspice での確かめ

`sim/08-capacitance-bridge.cir` で、図1 の C<sub>x</sub> = 47 nF に対し、R<sub>a</sub> を真ん中 (5 kΩ)・釣り合い (2.837 kΩ)・
釣り合い + 100 Ω (2.937 kΩ) の 3 通りにして、1 kHz の .ac で P − Q の大きさと位相を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 真ん中の P − Q | 0.50 Vpp、−46° | 0.504 Vpp。P は +14.9°・Q は +29.4° 進み、差は −45.7° | 合う |
| 釣り合いの P − Q | ほぼ 0 | 0.07 mVpp (R<sub>a</sub> を 3 桁に丸めた残り) | 合う |
| 釣り合い + 100 Ω | 約 27 mVpp | 26.9 mVpp | 合う |
| 釣り合いの周波数依存 (500 Hz・2 kHz) | 変わらない | 0.10 mVpp・0.04 mVpp (どちらも釣り合ったまま) | 合う |

差の位相は、P と Q の位相と大きさ (0.967・0.871) から組み立てた値。真ん中の P − Q の大きさは 500 Hz で 0.70 Vpp、2 kHz で 0.29 Vpp と
周波数で変わるが、釣り合いの位置は変わらない。

## 出典

自作。

参考: [ブリッジ回路 (Wikipedia)](https://ja.wikipedia.org/wiki/ブリッジ回路)、[Lessons in Electric Circuits Vol. II 第 12 章 AC bridge circuits](https://www.ibiblio.org/kuphaldt/electricCircuits/AC/AC_12.html)
