---
book: denken
chapter: 10
id: 10-2
title: 平滑コンデンサとリップル
tier: 50
source: 自作
board: BB
---

# 10-2 平滑コンデンサとリップル

10-1 の全波整流の出力に大きなコンデンサを並列に入れると、山と山の間を
コンデンサが電気を出して埋め、電圧の落ち込み (リップル) が小さくなる。
リップルの大きさと、負荷電流・容量・周波数の関係を確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vpp ≒ Iload / (f_ripple × C) | リップルの peak-to-peak。負荷電流が大きい・容量が小さいほど増える |
| f_ripple = 2f (全波) | 全波整流のリップル周波数は電源周波数の 2 倍 |
| Vdc ≒ Vpeak − Vpp / 2 | 平均の直流電圧は、山の電圧からリップルの半分を引いた値に近い |

## 回路図

```circuit
title: 図1 全波整流にコンデンサを足す
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  D2: diode e10 c13 1N4148
  D3: diode e16 c13 1N4148
  D4: diode g13 e10 1N4148
  D5: diode g13 e16 1N4148
  C1: ecap c15 g15 100u
  M1: voltmeter c17 g17 l=$\mathrm{CH1}$
  RL: resistor c19 g19 1.5k
  G1: ground g1
wires:
  - c1 -- a1 -- a10 -- e10
  - g1 -- i1 -- i16 -- e16
  - c13 -- c15 -- c17 -- c19
  - g13 -- g15 -- g17 -- g19
```

- 10-1 の全波整流ブリッジ (D2〜D5) と同じ形。出力に C1 (100 µF) を並列に足す
- RL (1.5 kΩ) が負荷。CH1 (M1) は C1・RL の両端を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (コンデンサ入り)
board: half
parts:
  D2: diode c4(A) c12(K) 1N4148
  D3: diode -t12(A) a12(K) 1N4148
  D4: diode g18(A) g4(K) 1N4148
  D5: diode a18(A) -t18(K) 1N4148
  C1: capacitor/electrolytic d12(+) d18(-) 100u
  RL: resistor i12 i18 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a4 yellow
  - AD.GND -- -t8 black
  - AD.1+ -- b12 orange
  - AD.1- -- b18 blue
  - e4 -- f4 yellow
  - e12 -- f12 orange
  - e18 -- f18 blue
```

- 10-1 の図3 と同じブリッジ (D2〜D5)。12 列 (+) と 18 列 (−) の間に電解
  コンデンサ C1 を足し、負荷 RL は下のブロックの 12・18 列に挿す
  (12 列・18 列は溝をまたぐ短い線で上下つないである)
- CH1 (1+/1−) は 12 列・18 列 (C1 と RL の両端) にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、50 Hz、Amplitude 5 V |
| Scope | CH1 = C1・RL の両端。Time/div は 5 ms 程度でリップルの山谷が見える範囲に |
| Measure | CH1 の Average (Vdc) と Peak-Peak (リップル Vpp) |

リップルは Vdc に比べて小さいので拡大して見る。100 µF では CH1 の Offset を −3.7 V (画面の中央が 3.7 V)、
Range を 50 mV/div にする。10 µF では Offset −3 V・500 mV/div (0 V はどちらも画面の外)。コンデンサは
山の近くで一気に充電され、谷までは τ = RL·C (100 µF で 150 ms、10 µF で 15 ms) で放電する。

```scope
title: 図3 100 µF — 約 3.7 V の上に 0.22 Vpp のリップル (50 mV/div)
time: 5ms/div
trigger: ch1 rising 3.7V
ch1: {wave: = 5V * abs(sin(2 * pi * 50Hz * t)) - 1.2V | clip 0V | peak 150ms, range: 50mV/div, position: -74div}
measure: [vmax, avg, vpp, freq]
```

```scope
title: 図4 10 µF — リップルは 1.46 Vpp に増える (500 mV/div)
time: 5ms/div
trigger: ch1 rising 3V
ch1: {wave: = 5V * abs(sin(2 * pi * 50Hz * t)) - 1.2V | clip 0V | peak 15ms, range: 500mV/div, position: -6div}
measure: [vmax, avg, vpp, freq]
```

どちらも山 (Vmax) は 3.80 V で同じ。容量を 1/10 にすると谷が深くなり、Vdc (Avg) は 3.69 V から
3.11 V に下がる。リップルの周波数 (Freq) は電源の 2 倍の 100 Hz。

### オシロスコープと発振器

W1 は FG の OUT (High-Z、50 Hz、振幅 5 V。Vpp で入れる機種なら 10 Vpp) に読み替える
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。
**ブリッジの − (18 列) は FG の GND ではない。** AD の 1− を当てていた 18 列にグランドクリップを当てると、
18 列が大地を通って FG の GND (青レール) とつながり、負の半周期に D4 が FG の出力を GND へじかに
短絡する (10-1 と同じ)。そこで**回路はそのままで、2 本の先端を 12 列と 18 列に当て、CH1 − CH2 で引く**
(図5)。出力 (約 3.3 V) は各点の振れ (約 4.5 V) の 7 割あり、Vdc は 8 bit でも埋もれない。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  D2: diode e4 c7 1N4148
  D3: diode e10 c7 1N4148
  D4: diode g7 e4 1N4148
  D5: diode g7 e10 1N4148
  C1: ecap c13 i13 100u
  RL: resistor c16 i16 1.5k
  M2: voltmeter i11 k11 l=$\mathrm{CH2}$
  M1: voltmeter c19 k19 l=$\mathrm{CH1}$
  G1: ground g1
  G2: ground g10
  G3: ground k15
wires:
  - c1 -- a1 -- a4 -- e4
  - e10 -- g10
  - c7 -- c13 -- c16 -- c19
  - g7 -- i7 -- i11 -- i13 -- i16
  - k11 -- k15 -- k19
```

- CH1 の先端は 12 列 (+)、CH2 の先端は 18 列 (−)、グランドクリップは 2 本とも青レール。
  ブレッドボードの部品は図2 のまま動かさない
- Vdc は Math (CH1 − CH2) の Mean か、CH1 と CH2 の Mean の差。Vpp は Math の Peak-Peak
- FG の 50 Ω が充電の電流を絞るので、山がつぶれる。振幅 5 V のままだと Vpeak ≒ 3.3 V、
  Vdc ≒ 3.25 V、Vpp ≒ 0.16 V (計算値。Vf = 0.6 V 一定のダイオードで波形を時間で刻んで解いた)。
  FG の振幅を 5.5 V (11 Vpp) に上げると、FG の出力端の山が 5 V に戻り、Vdc ≒ 3.7 V、Vpp ≒ 0.18 V
- 100 µF のリップル (0.2 V 弱) は CH1 − CH2 では読みにくい。12 列はおよそ −0.6〜+3.9 V、18 列は
  −3.9〜+0.6 V を 50 Hz で行き来する (計算値) ので、各 ch は 1 V/div より絞れない (縦 8 div に収まらない)。
  1 段が約 30 mV で、リップルは 5 段ほど。2 本のプローブの倍率の差 (1 % で約 45 mV) も Math に残る。
  形と周波数 (100 Hz) は見えるが、Peak-Peak は数割狂いうる。10 µF に替えたリップル (1 V を超える) なら
  はっきり読める
- 100 µF のリップルを細かく読みたいときは、ブリッジを大地から浮いた電源で駆動する。この本で使える
  のは AC 出力の AC アダプタ (二次側 12 V 以下、0-5)。FG を外してアダプタに替え、0-1 のとおり
  ヒューズか電流制限の抵抗を入れる。それなら 18 列にグランドクリップを当ててよく、CH1 を AC 結合にして
  リップルを直に読める。12 V のアダプタならリップルは約 1 V (計算値) なので 200 mV/div ほど。
  電圧が変わるので見るべき値の表は使えず、C1 は耐圧 25 V 以上のものに替える

## 見るべき値

計算値。AD の W1 は出力 0 Ω、ダイオードは順電圧 0.6 V 一定 (2 個分 1.2 V) として、
波形を時間で刻んで解いた。式の値も添える。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 山の電圧 (Vpeak ≒ 5 − 1.2) | 約 3.8 V | コンデンサが充電される最大値 |
| リップル Vpp (Iload ≒ 2.5 mA、f_ripple = 100 Hz) | 約 0.22 V (計算値) | 式では 2.5 mA ÷ (100 Hz × 100 µF) = 0.25 V。山の近くで充電し直す間は放電しないので、式より少し小さい |
| Vdc (≒ Vpeak − Vpp/2) | 約 3.69 V (計算値) | 式でも 3.8 − 0.11 = 3.69 V。C1 が無いとき (10-1) の 2.08 V よりずっと平らで高い |
| C1 を 10 µF に替えたとき | Vpp 約 1.46 V、Vdc 約 3.1 V (計算値) | 式は 2.5 V と言うが当てにならない。リップルが山の 4 割にもなると「放電の間の電流は一定」という式の前提が崩れ、谷に向かって電流が減るぶん落ち込みも鈍る。容量 1/10 でリップルは約 6.5 倍 |

コンデンサが無い 10-1 では出力が 0 まで落ち込んでいたが、C1 を入れると谷が
浅くなり、平均値 (Vdc) も持ち上がる。100 µF を 10 µF に替えると、リップルが
目に見えて大きくなることも確かめておく。Vpp ≒ Iload / (f × C) の式は
**リップルが山に比べて小さいとき**の近似で、10 µF のように大きくなると外れる。

## 出典

自作。
