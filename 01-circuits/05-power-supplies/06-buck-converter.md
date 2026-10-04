---
book: circuits
chapter: 5
id: 5-6
title: 降圧スイッチング (MC34063 かモジュール)
tier: 100
board: BB
source: 自作
era: 今
---

# 5-6 降圧スイッチング (MC34063 かモジュール)

12 V から 5 V を、熱をあまり出さずに作る。5-3・5-4 の 3 端子レギュレータ・LDO は、
入力と出力の電圧差ぶんを熱として捨てて電圧を落とす (リニア方式)。電流が大きいと発熱も大きくなる。
**スイッチング方式**は、トランジスタで電流を高速に入り切りし、コイルにエネルギーを少しずつ出し入れして電圧を作る
(5-5 の Joule thief と同じ考え方)。熱にする分が少なく、効率 (出力の電力 ÷ 入力の電力) が良い。
直流の電圧を別の直流の電圧に変える回路を DC-DC コンバータといい、電圧を下げるものを降圧 (buck) 型という。
既製の DC-DC モジュール (MC34063 や専用 IC を基板に載せたもの) を使うのが、実用上いちばん手軽だ。

## 回路図

```circuit
title: 図1 降圧 DC-DC モジュール
parts:
  V1: vsource vin gnd 12
  G1: ground gnd
  M1:
    type: device
    at: c7
    label: Buck DC-DC
    pins: [IN+, IN-, OUT+, OUT-]
  Rload: resistor e7 g7 100
  Rled: resistor e9 g9 330
  Dled: led g9 i9 red
  GD: ground i9
  G2: ground g7
points:
  vin: b2
  gnd: d2
wires:
  - vin -- b4a5 |- M1.IN+
  - gnd -- d3a5 |- M1.IN-
  - M1.OUT+ -| e5
  - e5 -- e7
  - e7 -- e9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/06-buck-converter.svg)

- M1 は市販の降圧 DC-DC モジュール基板 (MC34063 と周辺のコイル・
  ダイオード・コンデンサを基板 1 枚にまとめたもの)。外に出ている端子は
  IN+・IN-・OUT+・OUT- の 4 本だけ。出力電圧は、基板上のトリマ抵抗 (ドライバーで回して値を合わせる半固定抵抗) で、
  負荷をつなぐ前に 5 V に合わせておく (テスターで OUT+ と OUT- の間を見ながら回す)
- 図1 では OUT- を配線していない。非絶縁型 (入力と出力がトランスで分けられていない型) のモジュールは、
  基板の中で OUT- と IN- が同じ GND につながっている。負荷の帰りは共通の GND につなげば足りる
- Rload (100 Ω) は 5 V で動く回路を模した負荷で、Rled・Dled は
  出力が出ているかを目で見る LED。Rload の消費電力は 5² / 100 = 0.25 W で、1/4 W 抵抗の
  定格ぎりぎりになるので、1/2 W 以上の抵抗を使う
- リニア方式 (5-3・5-4) と違って、入力と出力の電圧差が大きいほど有利
  になる。12 V → 5 V のように差が大きい変換で、効率の差がはっきり出る
- 図1 では、モジュールのピンがすべて箱の左に並ぶ描き方のため、出力 (OUT+) も左から出て右の負荷へ回っている

## 実体配線図

```breadboard
title: 図2 モジュールの出力 5 V にブレッドボードの負荷をつなぐ
# 上の赤レール = +5V (モジュールの出力)、青レール = GND。12 V はレールに入れず、アダプタからモジュールへ直接つなぐ
board: half
parts:
  ADP:
    type: device
    at: top
    label: 12 V AC アダプタ (DC 出力)
    pins: [GND, 12V]
  M1:
    type: device
    at: top
    label: Buck DC-DC モジュール (5 V に調整済み)
    pins: [IN+, IN-, OUT+, OUT-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope (AC 結合)
    pins: [1+, 1-]
  Rload: resistor/half c10 c14 100
  Rled: resistor c18 c21 330
  Dled: led b21(A) b24(K) red
wires:
  - ADP.12V -- M1.IN+ red
  - ADP.GND -- -t1 black
  - M1.IN- -- -t2 black
  - M1.OUT+ -- +t3 red
  - M1.OUT- -- -t4 black
  - +t10 -- a10 red
  - a14 -- -t14 black
  - +t18 -- a18 red
  - a24 -- -t24 black
  - SC.1+ -- +t12 orange
  - SC.1- -- -t13 black
notes:
  - text below: 上の赤レール = +5V (OUT+)、青レール = GND。12 V は赤レールに入れない
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/06-buck-converter.svg)

- 図2 の M1 は市販のモジュール (ブレッドボードの外)。12 V の AC アダプタ (ADP) の 12V を M1 の IN+ へ直接つなぎ、アダプタの GND と M1 の IN- は青レール (GND) へ入れる。**12 V はブレッドボードのレールに入れず、赤レールは出力の 5 V だけにする** (取り違えると 5 V の回路に 12 V がかかる)。IN- は GND の青レールへもつなぐ
- AD3 の Supplies は 12 V を出せない (約 5 V まで、各レール約 50 mA)。**12 V のこの題は AC アダプタを電源にし、AD3 は出力のリップルを見る Scope だけに使う。** 12 V はブレッドボードの範囲 (定常 12 V 以下) の上限
- モジュールの OUT+ (5 V) は上の赤レールへ、OUT- は上の青レールへ。ブレッドボードを通る電流は出力側が約 59 mA (Rload 50 mA + LED 約 9 mA)、入力側が約 33 mA で、1 穴 200 mA・ブレッドボード全体 500 mA の範囲に収まる
- Rload (100 Ω) は 10 列〜14 列、Rled (330 Ω) は 18 列〜21 列。Rload の消費電力は 0.25 W なので、ブレッドボードの図でも 1/2 W 以上の抵抗を使う。LED (Dled) はアノードを 21 列、カソードを 24 列に挿す
- Scope の 1+ (橙) を上の赤レール (出力の 5 V)、1− (黒) を上の青レール (GND) へつなぐ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。出力のリップルの形と大きさを見る題で、数十 kHz のスイッチング周波数は 10 MHz よりずっと低いから。
直流の 5 V は乗せずに、リップルだけを大きく見るので、Scope は AC 結合にする。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (出力の 5 V、上の赤レール) | AC 結合、20 mV/div |
| Time | 10 µs/div (数周期が見える) |
| Trigger | CH1、立ち上がり、0 V |

```scope
title: 図3 出力のリップル (AC 結合) — 50 kHz・約 50 mVpp と仮定した目安
time: 10us/div
trigger: ch1 rising 0V
ch1: {wave: triangle 50kHz 0.05Vpp, range: 20mV/div}
cursors: [-5us, 5us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/06-buck-converter.svg)

図3 は MC34063 系のモジュールを想定した**目安の図**で、リップルの大きさと周波数はモジュールの種類と負荷で変わる (この図は 50 kHz・50 mVpp と仮定した)。
カーソルは谷 (X1、−5 µs で −25 mV) と山 (X2、+5 µs で +25 mV) に置いてあり、差の 50 mV がリップルの大きさ (Pk-Pk)、X1 と X2 の間の 10 µs が半周期 (50 kHz の周期 20 µs の半分) に当たる。
実機の読みは、図の Measurements の Pk-Pk と Frequency に出る。リニア方式 (5-3 の 7805) の出力にはこの周期的な揺れがほとんど無く、スイッチング方式の特徴が見える。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 降圧 DC-DC コンバータモジュール (MC34063 系、出力 5V 固定に調整済み) | — |
| Rload | 抵抗 (負荷、1/2W 品を使う) | 100 Ω |
| Rled | 抵抗 (LED 電流制限) | 330 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 計器 | AD3 の Scope 1+ / 1− (出力のリップルを AC 結合で見る)。テスター (電圧・電流) |
| — | 電源 | 12 V (AC アダプタ) — 降圧 (buck) は出力より高い入力が要る。出力 5V との差が大きいほど、リニア方式との効率差もはっきり出る |

## 見るべき値

表の値は計算値。軽負荷のときの効率を 75 % と仮定した (実際はモジュール・負荷電流で変わる)。
電圧はテスターの DC 電圧レンジで測る。入力電流は、テスターの電流 (mA) レンジを電源の + と IN+ の間に直列に入れて測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| OUT+ の電圧 | 5.0 V | モジュールのトリマで調整済みの固定出力 |
| Rload の電流 | 50 mA | 5.0 V ÷ 100 Ω |
| Dled の電流 | 約 9.1 mA | (5.0 − 2.0) ÷ 330 Ω |
| 出力の合計電流 | 約 59 mA | Rload + Dled |
| 入力電流 (効率 75% と仮定) | 約 33 mA | (5.0V×0.059A ÷ 0.75) ÷ 12V |
| リニア方式 (5-3 の 7805 など) で 12 V から同じ負荷を作った場合の入力電流 | 59 mA (I<sub>in</sub> ≈ I<sub>out</sub> のまま) | リニア方式は電流を変換しない (電圧だけ落として熱にする)。入力の電力は 12 V × 59 mA ≈ 0.71 W で、スイッチング (12 V × 33 mA ≈ 0.39 W) の約 1.8 倍 |

MC34063 単体を自分で組む場合は、発振周波数を決める外付けコンデンサ (C<sub>T</sub>)、
インダクタ、整流ダイオード (ショットキー推奨)、出力コンデンサをデータシートの
式で計算する。モジュールはこれらを基板上で済ませてあるので、
値の計算は要らない代わりに、中身を自由に変えられない。

## 出典

自作。
