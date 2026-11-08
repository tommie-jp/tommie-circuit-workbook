---
book: circuits
chapter: 8
id: 8-11
title: リードスイッチ
tier: 200
source: 自作
board: BB
---

# 8-11 リードスイッチ

リードスイッチは、ガラス管の中に 2 枚の磁性体の薄い板 (リード) を封じたスイッチである。磁石を近づけると
2 枚のリードが磁化されて引き合い、接点が閉じる。磁石を離すとばねの力で開く。ドアや窓の開閉の検出、
水位計の浮き、自転車の速度計 (車輪に付けた磁石を数える) に使われる。

8-8 のホールスイッチ IC も磁石で切り替わるが、中身はトランジスタで、出力は 1 回だけきれいに切り替わる。
リードスイッチは**機械の接点**なので、閉じた瞬間にリードが跳ね返り、数十〜数百 µs (マイクロ秒) の間に開閉を何回か繰り返す。
これを**チャタリング** (接点の跳ね) という。LED を点けるだけなら目に見えないが、数を数える回路
(10 章のカウンタやマイコン) につなぐと、1 回の通過を 3〜4 回と数えてしまう。

この題では、リードスイッチを 10 kΩ (キロオーム) で 5 V へプルアップし、接点の電圧の跳ねを Analog Discovery 3 (AD3) のオシロで見る。
その跳ねを、R2 と C1 の RC (1-3 の充電) となまらせ、74HC14 (シュミットトリガのインバータ) で 1 回の切り替えに直す。
シュミットトリガは上りと下りでしきい値が違う (ヒステリシス、4-8 で見た) ので、なまった電圧がしきい値の近くでふらついても、出力は 1 回しか変わらない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 リードスイッチの跳ねを RC と 74HC14 で消す
parts:
  VCC: vcc 4,1 5V
  R1: resistor 4,1 4,3 10k
  S1: reed 4,3 4,5
  G1: ground 4,5
  M1: voltmeter 6,3 6,5 l=$\mathrm{CH1}$
  G4: ground 6,5
  R2: resistor 7,3 9,3 10k
  C1: capacitor 9,3 9,5 100n
  G2: ground 9,5
  U1A: not 11,3 74HC14
  M2: voltmeter 13,3 13,5 l=$\mathrm{CH2}$
  G5: ground 13,5
  R3: resistor 14,3 16,3 1k
  D1: led 16,3 16,5 red
  G3: ground 16,5
  C2: capacitor 18,1 18,3 100n
  GC2: ground 18,3
wires:
  - 4,1 -- 18,1
  - 4,3 -- 6,3 -- 7,3
  - 9,3 -- U1A.in
  - U1A.out -- 13,3 -- 14,3
notes:
  - text 14,6 blue left: "C2 は U1 の 14 番 (VCC) と 7 番 (GND) の間"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/11-reed-switch.svg)

- **S1 が開いている** (磁石が無い) とき、接点の電圧 (CH1) は R1 で 5 V に引き上げられる。C1 も R1 + R2 を通して 5 V。
  74HC14 の入力が H なので出力 (CH2) は L で、D1 は消えている
- **S1 が閉じる** と、接点は 0 V に落ちる。C1 は R2 を通して放電し、時定数は τ (タウ) = R2 × C1 = 10 kΩ × 100 nF = **1 ms**。
  C1 の電圧が 74HC14 の下のしきい値 V<sub>T−</sub> (5 V で約 1.7 V) まで下がると出力が H になり、D1 が点く。
  かかる時間は 1 ms × ln(5 ÷ 1.73) ≈ **1.06 ms** (跳ねの分だけ少し延びる)
- **跳ね**の間、接点は数十 µs ずつ開くが、そのたびに C1 が充電されるのは R1 + R2 (20 kΩ) を通した 30〜50 µs だけで、
  電圧は 5 V の近くからほとんど動かない。C1 の電圧が V<sub>T−</sub> まで下りるのは跳ねが終わってからなので、出力は 1 回だけ変わる
- **S1 が開く** と、C1 は R1 + R2 を通して充電される (τ = 2 ms)。上のしきい値 V<sub>T+</sub> (約 2.8 V) を超えると出力が L に戻る。
  かかる時間は 2 ms × ln(5 ÷ (5 − 2.77)) ≈ **1.6 ms**
- しきい値は TI の SN74HC14 の典型値 (4.5 V で V<sub>T+</sub> 2.5 V・V<sub>T−</sub> 1.6 V、6 V で 3.3 V・2 V) を 5 V に内挿した目安。
  ばらつきは大きく、4.5 V で V<sub>T+</sub> は 1.55〜3.13 V。遅れの時間も 2 倍ほどの幅で動く
- D1 の電流は (4.8 − 2.0) V ÷ 1 kΩ ≈ 2.8 mA。74HC14 の出力は 4 mA で 4.5 V 電源でも 3.84 V 以上を保証するので、この程度なら出力は 5 V に近い
- C2 (0.1 µF) は U1 の電源のデカップリング (3-8 と同じ)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 リードスイッチと 74HC14 を組む (CH1 は接点、CH2 は出力)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b2 b6 10k
  S1: reed c6 c12
  R2: resistor g6 g12 10k
  C1: capacitor/ceramic i12 -b12 100n cap=right
  U1: dip14 @ e16 74HC14
  C2: capacitor/ceramic c13 c16 100n
  R3: resistor i17 i24 1k cap=above
  D1: led h24(A) h27(K) red i=2.8mA
  SC:
    type: device
    at: bottom
    label: Analog Discovery 3 (Scope)
    pins: [1+, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t3 black
  - -t1 -- -b1 black
  - +t2 -- a2 red
  - a12 -- -t12 black
  - e6 -- f6 orange
  - h12 -- h16 yellow
  - +t16 -- a16 red
  - a13 -- -t13 black
  - j22 -- -b22 black
  - a17 -- -t17 black
  - a19 -- -t19 black
  - a21 -- -t21 black
  - j18 -- -b18 black
  - j20 -- -b20 black
  - j27 -- -b27 black
  - SC.1+ -- j6 blue
  - SC.1- -- -b8 black
  - SC.2+ -- j17 green
  - SC.2- -- -b14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/11-reed-switch.svg)

- 5 V は AD3 の Supplies の V+ (WaveForms で 5 V にして出力を入れる) から上の + レールへ。GND は上の − レールへつなぎ、
  上下の − レールを左端の列 1 でつなぐ。下の + レールは使わない
- **接点の列は 6**: R1 (2→6 列) の左端を赤の線で + レールへ。S1 (6→12 列) の右端 (12 列) は黒の線で − レールへ。
  6 列は橙の線で溝を渡り、下のブロックの R2 (6→12 列) へ続く
- **C1 の列は 12 (下)**: C1 を `i12` と下の − レールの間に挿す。黄の線 `h12 -- h16` で 74HC14 の 1 番 (入力 1A) へ
- **74HC14** は溝をまたいで挿し、切り欠きを左に向ける。1 番 (1A) が左下の `f16`、14 番 (VCC) が左上の `e16`。
  14 番を赤の線で + レールへ、7 番 (GND、下の 22 列) を黒の線で − レールへ。C2 は 13〜16 列 (上) で 14 番の隣に入れる
- **使わない入力** (3・5 番 = 下の 18・20 列、9・11・13 番 = 上の 21・19・17 列) は GND へ落とす (CMOS の入力を浮かせると、
  中間の電圧で電流が流れたり発振したりする)。使わない出力 (4・6・8・10・12 番) は何もつながない
- **出力**: 2 番 (1Y、下の 17 列) から R3 (17→24 列) と D1 (アノード 24 列・カソード 27 列) を通して − レールへ
- オシロは 1+ (青) を接点の列 6 (`j6`) に、2+ (緑) を出力の列 17 (`j17`) に挿す。1−・2− は下の − レールへ
- リードスイッチのリードはガラスの根元で曲げると管が割れる。根元から 3 mm 以上離した所をラジオペンチで挟んで曲げる
- 電流は D1 の約 2.8 mA と、接点が閉じたときの R1 の 0.5 mA で、合わせて 4 mA ほど。AD3 の Supplies (USB 給電で 5 V・50 mA が目安) とブレッドボードの範囲 (500 mA) に収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V、Scope の CH1 を接点 (列 6)、CH2 を 74HC14 の出力 (列 17) にする。
磁石を手で動かすので、跳ねは毎回違う形になる。Scope は **Single** (1 回だけ取り込む) にして、CH1 の立ち下がり 2.5 V で
トリガを掛け、トリガの位置を左から 1 目盛にする。横は 200 µs/div、縦はどちらも 2 V/div (CH1 を上、CH2 を下に分けて置く)。磁石を S1 のガラス管の横から
近づけると、1 回ぶんが画面に残る。

見えるはずの画面 (跳ねは閉じた直後に 3 回開き、230 µs で落ち着くと**仮定**した計算値で、実測ではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 接点 (CH1) は 3 回跳ね、74HC14 の出力 (CH2) は 1 回だけ切り替わる
time: 200us/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: = 5V * (1 - step(t) + step(t - 60us) - step(t - 100us) + step(t - 140us) - step(t - 170us) + step(t - 200us) - step(t - 230us)), range: 2V/div, position: 1div}
ch2: {wave: = 4.8V * step(t - 1.17ms), range: 2V/div, position: -3div}
cursors: [0, 1.17ms]
measure: [vmax, vmin]
notes:
  - band 0 230us
  - text 350us 4V: 跳ね (約 230 µs)
  - text ch2 1.17ms 2.4V: 約 1.17 ms で H
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/11-reed-switch.svg)

- CH1 は、閉じた直後に 0 V と 5 V の間を何回か行き来する。回数と長さは、磁石の強さと近づける速さで変わる
- CH2 は、跳ねが終わってから約 1.2 ms 遅れて 1 回だけ H になる。カーソル X1 (閉じた瞬間) と X2 (出力が H) の差が遅れ
- **C1 を抜いて比べる**: C1 を外すと、74HC14 の入力は接点と同じ電圧になり、CH2 も跳ねの回数だけ H と L を繰り返す
  (シュミットトリガだけでは跳ねは消えない。跳ねは 0 V と 5 V の往復で、しきい値の幅より大きいため)
- 磁石を離すときの開く側も、Single を CH1 の立ち上がりに替えて見る。開くときの跳ねは閉じるときより少ないことが多い

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| S1 | リードスイッチ (常時開、ガラス管入り) | 長さ 15〜20 mm 程度の品。磁石はネオジム磁石 (φ10 mm 程度) |
| R1, R2 | 抵抗 (1/4 W) | 10 kΩ |
| R3 | 抵抗 (1/4 W) | 1 kΩ |
| C1, C2 | 積層セラミックコンデンサ | 0.1 µF (104) |
| U1 | シュミットトリガのインバータ | 74HC14 (6 回路のうち 1 回路を使う) |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+。合わせて約 4 mA) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 接点の電圧 (CH1)、磁石なし / あり | 5 V / 0 V | プルアップの R1 で開いた接点を H にする |
| 閉じた直後の CH1 | 0 V と 5 V の往復が数回、数百 µs 以内 | 機械の接点の跳ね (チャタリング) |
| 閉じてから出力が H になるまで (CH2) | 約 1.2 ms (跳ね込み。しきい値のばらつきで 0.6〜2 ms ほど) | τ = R2 × C1 = 1 ms の放電が V<sub>T−</sub> まで下りる時間 |
| 開いてから出力が L になるまで | 約 1.6 ms | τ = (R1 + R2) × C1 = 2 ms の充電が V<sub>T+</sub> まで上がる時間 |
| C1 を外したときの CH2 | 跳ねの回数だけ H と L を繰り返す | RC が無いと跳ねはそのまま出力に出る |
| D1 の電流 (点灯中) | 約 2.8 mA | (4.8 − 2.0) V ÷ 1 kΩ |

## LTspice での確かめ

`sim/11-reed-switch.cir` で図1 を解いた。接点は抵抗の切り替わるスイッチ (閉 0.1 Ω・開 100 MΩ) で、閉じた直後に 30〜60 µs の
開きを 3 回入れて跳ねを**仮定**した (図3 と同じ並び)。74HC14 は LTspice の SCHMITT (V<sub>T+</sub> 2.77 V・V<sub>T−</sub> 1.73 V、
出力の H は 4.8 V) で置いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 閉じてから出力が H になるまで | 約 1.17 ms | 1.17 ms | 合う |
| 跳ねの間の C1 の電圧 (最も低い所) | 5 V の近く (しきい値に届かない) | 4.12 V | 合う (V<sub>T−</sub> 1.73 V より十分高い) |
| 出力の切り替わり (閉じたとき) | 1 回 | 1 回 (立ち上がりは 1 つ) | 合う |
| 開いてから出力が L になるまで | 約 1.6 ms | 1.60 ms | 合う |
| D1 の電流 | 約 2.8 mA | 2.86 mA | 合う |

跳ねの形 (回数と長さ) は仮定で、実物ではリードの長さと磁石の動かし方で変わる。跳ねが 1 ms 近く続く品では、
C1 を 0.47 µF に増やして τ を 4.7 ms にする。

## 出典

自作。しきい値と出力電圧は Texas Instruments の [SN74HC14 データシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)
(Electrical Characteristics: V<sub>T+</sub>・V<sub>T−</sub>・V<sub>OH</sub>)。

参考: [Reed switch (Wikipedia)](https://en.wikipedia.org/wiki/Reed_switch)、[チャタリング (Wikipedia)](https://ja.wikipedia.org/wiki/チャタリング)
