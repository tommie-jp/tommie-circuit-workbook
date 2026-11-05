---
book: analog-discovery
chapter: 2
id: 2-17
title: シュミットトリガのヒステリシスを XY で
tier: 200
source: 自作
board: BB
---

# 2-17 シュミットトリガのヒステリシスを XY で

シュミットトリガは、入力が上がるときと下がるときで切り替わる電圧 (しきい値) が違う。
時間の画面では 2 つのしきい値を 2 本のカーソルで別々に読むことになるが、
2-5・2-13 の XY 表示 (横 = 入力、縦 = 出力) にすると、**入出力の関係そのもの**が 1 枚の四角いループになって見える。
ループの左右の縦の辺が 2 つのしきい値で、横の幅がヒステリシス幅になる。
回路の教科書の 4-8 では CdS を手で覆って 1 回ずつ確かめたが、ここでは Wavegen の三角波で入力を何度も往復させ、
同じループを重ね描きして形が崩れないことも見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 非反転のシュミットトリガ (LM358、電源は正負 5 V)
parts:
  W1: triangle 1,3 1,6 1.5
  M1: voltmeter 3,3 3,6 l=$\mathrm{CH1}$
  R1: resistor 3,3 6,3 10k
  R2: resistor 6,1.5 10,1.5 47k
  U1: opamp 8,3.5 +up
  M2: voltmeter 12,3.5 12,6 l=$\mathrm{CH2}$
  G1: ground 1,6
wires:
  - 1,3 -- 3,3
  - 6,1.5 -- 6,3
  - 6,3 |- U1.+
  - U1.out -- 10,3.5 -- 12,3.5
  - 10,1.5 -- 10,3.5
  - U1.- -| 6,6
  - 1,6 -- 3,6 -- 6,6 -- 12,6
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/17-schmitt-xy.svg)

- W1 (三角波、振幅 1.5 V、100 Hz) → R1 (10 kΩ (キロオーム)) → + 入力。出力から + 入力へ R2 (47 kΩ) で正帰還を掛ける。− 入力は GND
- 非反転入力 (+ 入力) の電圧は、入力 V<sub>in</sub> と出力 V<sub>out</sub> を R1 と R2 で分けた値
  (V<sub>in</sub>·R2 + V<sub>out</sub>·R1) / (R1 + R2)。これが 0 V を横切った所で出力が反転する。
  横切る入力は **V<sub>in</sub> = −V<sub>out</sub>·R1 / R2** で、出力が Low か High かで違う値になる
- 出力が Low (−4.98 V) の間は、入力が +4.98 × 10 / 47 = **+1.06 V** まで上がってやっと High に跳ぶ。
  High (+3.5 V) の間は、−3.5 × 10 / 47 = **−0.74 V** まで下がってやっと Low に戻る
- 2 つのしきい値が 0 V に対して左右で違うのは、LM358 の出力が上に 3.5 V しか振れず、下は −5 V 近くまで振れるため。
  ループの左右の偏りが、出力段の非対称をそのまま見せる
- 電源は AD3 の Supplies の ±5 V (V+・V−)。図1 ではオペアンプの電源のピンを描いていない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (LM358 の 2 回路目を使う)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V-, V+, GND, 1-, 2-, 2+, W1, 1+]
  U1: dip8 @ e12 LM358
  R2: resistor b13 b15 47k
  R1: resistor d15 d20 10k
wires:
  - AD.V- -- -b3 blue
  - AD.V+ -- +t6 red
  - AD.GND -- -t8 black
  - AD.1- -- -t10 black
  - AD.2- -- -t11 black
  - +t12 -- a12 red
  - a14 -- -t14 black
  - j15 -- -b15 blue
  - AD.2+ -- a13 blue
  - AD.W1 -- a20 yellow
  - e20 -- e23 yellow
  - AD.1+ -- a23 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/17-schmitt-xy.svg)

- 上の赤レールが +5 V (V+)、上の青レールが GND、**下の青レールが −5 V (V−)**。V− の青い線は基板の左端を下ろす
- LM358 は 2 回路目 (ピン 5・6・7) を使う。電源のピン 8 (V+) と同じ上の列に並ぶので、
  − 入力 (ピン 6、14 列) は `a14` から上の GND レールへ 1 本で落とせる。ピン 4 (V−、15 列) は `j15` から下の青レールへ
- R2 (47 kΩ) は出力 (ピン 7、13 列) と + 入力 (ピン 5、15 列) の間。R1 (10 kΩ) は + 入力の 15 列から 20 列へ。
  W1 (黄) は 20 列に入れ、黄の線で 23 列へ渡して 1+ (橙) を挿す (1 つの列に 2 本の線を上から下ろさないため)
- 2+ (青) は出力の 13 列 (`a13`)。1−・2− は上の GND レールへ
- 使わない 1 回路目 (ピン 1・2・3) は空けたまま。電流は数 mA で、Supplies の各レールの目安 (約 50 mA、USB 給電で 250 mW) に十分収まる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = +5 V、V− = −5 V、Master Enable |
| Wavegen (W1) | Triangle、100 Hz、Amplitude 1.5 V、Offset 0 V |
| Scope (CH1・CH2) | DC。CH1 = 500 mV/div、CH2 = 2 V/div。Time 1 ms/div |
| Trigger | CH2、Rising、0 V (出力が Low から High に跳ぶ所) |
| 表示 | 先に時間の画面 (図3) で 2 つのしきい値をカーソルで読み、次に **XY** (X = CH1、Y = CH2) に切り替える (図4) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 時間の画面 — 上りは +1.06 V、下りは −0.74 V で切り替わる
time: 1ms/div
trigger: ch2 rising 0V
ch1: {wave: triangle 100Hz 1.5V phase 153.6deg, range: 500mV/div}
ch2: {wave: pulse 100Hz 4.24V offset -0.74V duty 44.75%, range: 2V/div}
cursors: [0, 4.475ms]
measure: [vmax, vmin, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/17-schmitt-xy-1.svg)

図3 は理想の形 (出力は瞬時に跳ぶとした)。X1 (トリガ点) は出力が High に跳ぶ瞬間で、そのときの CH1 が上りのしきい値 +1.06 V。
X2 は出力が Low に戻る瞬間で、CH1 は下りのしきい値 −0.74 V。CH2 の読みはカーソルが跳びの上に乗るので途中の値になる。CH1 の読みを見る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 XY の画面 — 横 CH1 (入力)・縦 CH2 (出力) の四角いループ
view: xy
ch1: {wave: triangle 100Hz 1.5V, range: 500mV/div}
ch2: {wave: pulse 100Hz 4.24V offset -0.74V duty 44.75% | delay 4.266ms, range: 2V/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/17-schmitt-xy-2.svg)

図4 は図3 と同じ 2 本を XY にしたもの。点は入力が上がるあいだ下の辺 (−4.98 V) を右へ進み、+1.06 V で上の辺 (+3.5 V) へ跳ぶ。
下がるあいだは上の辺を左へ戻り、−0.74 V で下の辺へ落ちる。**右の縦の辺と左の縦の辺の間 (1.80 V) がヒステリシス幅。**
実物では跳ぶ間にも入力がわずかに進むので、縦の辺がほんの少し傾く (LM358 のスルーレート 0.3 V/µs (マイクロ秒) で約 28 µs、
そのあいだに入力は 0.017 V 進む)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの 2 回路目) | LM358 |
| R1 | 抵抗 (入力) | 10 kΩ |
| R2 | 抵抗 (正帰還。しきい値を決める) | 47 kΩ |
| — | 電源 | ±5 V (AD3 の Supplies) |
| — | 計器 | AD3 の Wavegen (W1)・Scope (1+ = 入力、2+ = 出力) |

## 見るべき値

表の値は計算値。出力は High = V+ − 1.5 V = +3.5 V、Low = V− + 0.02 V = −4.98 V
(LM358 のデータシートの出力の振れ。正の側は V+ から 1.5 V、負の側は V− から最大 20 mV で、**仮定**) とした。
Low の間、出力は R2 を通して 60〜90 µA を吸い込む。データシートでは V− から 0.2 V の所で吸い込める電流が最小 12 µA なので、
実物の Low は −4.98 V より浅く (−4.5 V 前後まで) 出ることがある (目安)。そのときは図4 の下の辺 (CH2 の Vmin) を読み、
上りのしきい値を −V<sub>min</sub> × 10 / 47 で計算し直して、右の縦の辺の位置と比べる。

| 項目 | 期待する値 | 計算・読み方 |
| --- | --- | --- |
| 上りのしきい値 (出力 Low → High) | +1.06 V | 4.98 × 10 / 47。図3 の X1 の CH1、図4 の右の縦の辺 |
| 下りのしきい値 (出力 High → Low) | −0.74 V | −3.5 × 10 / 47。図3 の X2 の CH1、図4 の左の縦の辺 |
| ヒステリシス幅 | 1.80 V | 1.06 − (−0.74) = (3.5 + 4.98) × 10 / 47 |
| 出力の High / Low | +3.5 V / −4.98 V | 図4 の上の辺と下の辺 (CH2 の Vmax / Vmin) |
| 出力が High の時間 | 4.48 ms (Duty 44.8 %) | 三角波は 0.6 V/ms で動く。上りの +1.06 V から山の 1.5 V まで (0.44 / 0.6 = 0.73 ms) と、山から下りの −0.74 V まで (2.24 / 0.6 = 3.74 ms) の和。図3 のカーソルの ΔX |
| + 入力の振れ | −2.11〜+1.85 V | (V<sub>in</sub>·47 + V<sub>out</sub>·10) / 57 の最小と最大。LM358 の入力の範囲 (V− 〜 V+ − 1.5 V) に収まる |

確かめ方の手順:

1. 時間の画面で、W1 の振幅を 1.0 V まで下げる。上りのしきい値 (+1.06 V) に届かないので、出力は Low のまま動かない。
   **振幅がしきい値を越えない入力では、シュミットトリガは反応しない**ことが分かる
2. 振幅を 1.5 V に戻し、XY に切り替える。ループが四角く、2 周目以降も同じ所に重なることを見る
3. R2 を 100 kΩ に替えると、しきい値は +0.50 V / −0.35 V (幅 0.85 V) に縮む。R2 が大きいほど正帰還が弱く、
   ループは細くなって、帰還の無い比較器 (幅 0) に近づく

ループが四角でなく斜めの平行四辺形になるときは、三角波が速すぎて出力の跳びが入力の変化に追いついていない。
周波数を 10 Hz に下げると縦の辺が立つ。

## LTspice での確かめ

`sim/17-schmitt-xy.cir` で図1 を過渡解析で走らせた。オペアンプは回路の教科書 4-8 と同じ 1 極の汎用模型で、
出力の振れ (+3.5 V / −4.98 V) とスルーレート 0.3 V/µs を LM358 に合わせた**仮定**の模型 (実測ではない)。
しきい値は、出力が 0 V を横切る瞬間の入力の電圧で読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 上りのしきい値 | +1.06 V | +1.071 V | 合う (跳びの途中の 0 V で読むので、入力が 0.011 V 先へ進んだ分だけ大きい) |
| 下りのしきい値 | −0.74 V | −0.753 V | 合う (同じ理由) |
| 出力の High / Low | +3.5 V / −4.98 V | +3.50 V / −4.98 V | 合う (模型にそう与えた値) |
| 出力が High の時間 | 4.48 ms | 4.47 ms (18.756 − 14.285 ms) | 合う |
| 出力の跳び (−3 V → +2.5 V) | 約 28 µs で 8.5 V (スルーレート) | 18.3 µs で 5.5 V | 合う (0.30 V/µs) |

## 出典

自作。回路は回路の教科書 4-8 のシュミットトリガを、入力を三角波にした非反転の形に組み直したもの。
LM358 の出力の振れとスルーレートは [TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) による。

参考: [シュミットトリガ (Wikipedia)](https://ja.wikipedia.org/wiki/シュミットトリガ)
