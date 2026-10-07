---
book: circuits
chapter: 8
id: 8-6
title: 人感 (PIR モジュール)
tier: 100
source: 自作
board: BB
era: 今
---

# 8-6 人感 (PIR モジュール)

人が近づくと LED が点く人感センサーを、市販のモジュールで作る。
PIR (焦電型赤外線) センサーは、人の体から出る赤外線 (熱) の変化を検知する。
自分で回路を組むと感度の調整が難しい部品だが、HC-SR501 のようなモジュールなら
VCC・GND・OUT の 3 本をつなぐだけで使える。8-5 の遮光検出と違い、
人や動物が動いたときの熱の変化だけに反応する (じっとしている人には反応しない)。

## 回路図

```circuit
title: 図1 PIR モジュールでインジケータを点ける
parts:
  M1:
    type: device
    at: 3,3
    label: HC-SR501
    pins: [VCC, OUT, GND]
    turn: mirror
  VCC: vcc 5,2 5V
  G1: ground 5,5
  R1: resistor 7,4 7,6 150
  D1: led 7,6 7,8 red
  G2: ground 7,8
wires:
  - 5,2 |- M1.VCC
  - M1.GND -| 5,5
  - M1.OUT -| 7,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/06-pir.svg)

- M1 (HC-SR501) の OUT は、電源電圧によらず H が 3.3 V で出るのが
  代表的な仕様 (データシート値)。5 V で電源を取っても、OUT は 3.3 V までしか
  上がらない。それでも赤い LED なら、直列抵抗 R1 を通してそのまま光らせられる
- OUT は、検知すると H、検知していないと L になる。基板上のジャンパで、
  「動きが続く間は H を延ばす (再トリガ)」か「1 回検知したら一定時間だけ H」かを選べる品が多い
- 基板上の半固定抵抗 (トリマ、5-6 で見た) 2 個で、感度と保持時間 (5 秒〜200 秒程度) を
  調整できる。モジュールの中で完結しているので、図1 には描いていない
- OUT はマイコンの GPIO にもそのままつなげる (11 章)。この図では LED の
  インジケータで代用する

## 実体配線図

```breadboard
title: 図2 PIR モジュールと LED を組む (1+ が OUT を見る)
board: half
parts:
  M1:
    type: device
    at: top
    label: HC-SR501 (PIR モジュール)
    pins: [VCC, OUT, GND]
  R1: resistor c10 c14 150
  D1: led e14(A) e18(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (Supplies と Scope)
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - +b30 -- +t30 red
  - -b29 -- -t29 black
  - M1.VCC -- +t5 red
  - M1.GND -- -t13 black
  - M1.OUT -- a10 yellow
  - AD.1+ -- d10 blue
  - AD.1- -- -b12 black
  - b18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/06-pir.svg)

- 5 V の電源は Analog Discovery 3 (AD3) の Supplies の V+ (WaveForms で 5 V にして出力を入れる)。V+ を下の + レール、GND を下の − レールへつなぎ、右端の 2 本で上のレールへ渡す。HC-SR501 はブレッドボードに挿さず、VCC を上の + レール、GND を上の − レールへ線でつなぐ
- OUT (黄) は 10 列へ。10 列の R1 (10→14 列) が D1 のアノード (14 列) に続き、D1 のカソード (18 列) を黒の線で − レールへ落とす。1+ (青) も同じ 10 列に挿して OUT を見る。1− は − レールへ
- 電流は、LED が点いているとき約 8.7 mA、モジュール自身は数十 µA (データシートの目安) で、合計しても AD3 の Supplies の 50 mA (USB 給電で 250 mW) と、ブレッドボードの 500 mA の内側に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 人感センサーモジュール (HC-SR501) | 検知距離 約 7 m、検知角 約 120°、OUT の H は 3.3 V |
| R1 | 抵抗 | 150 Ω |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+。モジュールと LED で約 9 mA) |
| — | 計器 | Analog Discovery 3 の Supplies (V+ = 5 V) と Scope (1+ = OUT、1− = GND) |

## 計器の設定

計器は Analog Discovery 3 の Supplies (V+ = 5 V) と Scope。OUT が H を保つ時間は秒単位の変化なので、テスターの読みだけでは測れず、時間軸のあるオシロで見る。
Scope は 1+ を OUT (10 列)、1− を GND に当て、Time base を 1 s/div、Range を 1 V/div、トリガは 1+ の立ち上がり 1.65 V (Single) にして、センサーの前で手を振る。基板の保持時間のトリマは、最短 (約 5 s) に回しておく。

```scope
title: 図3 検知してから OUT が H を保つ時間 (保持時間を最短にしたとき)
time: 1s/div
trigger: ch1 rising 1.65V at -2div
ch1: {wave: "= 3.3V * step(t) * step(5s - t)", range: 1V/div, position: -3div}
measure: [vmax, vmin]
notes:
  - band 0 5s: 保持時間 約 5 s
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/06-pir.svg)

図3 は理想の形で、保持時間を最短 (約 5 s、基板の調整範囲の下端。データシートの目安) にして 1 回だけ検知した場合を描いた。検知の瞬間 (t = 0) に 0 V から 3.3 V へ立ち上がり、5 s 後に 0 V へ戻る。
実機では、保持時間のトリマの位置と再トリガの設定で H の幅が変わり、立ち上がりの時刻も手を振った瞬間になる。塗った帯の幅 (0 から 5 s) が保持時間である。

## 見るべき値

表の値は計算値。OUT の電圧は、テスターの DC 電圧レンジで OUT と GND の間を測る。
センサーの前で手を振ると検知し、離れて動かずにいると、保持時間のあとで L に戻る。保持時間は Scope で読む (図3)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 検知していないときの OUT | 約 0 V | D1 消灯 |
| 検知したときの OUT | 約 3.3 V | R1 に (3.3 − 2.0) / 150 Ω ≈ 8.7 mA 流れ、D1 点灯 |
| 検知してから OUT が H を保つ時間 | 約 5〜200 秒 (基板の半固定抵抗次第) | 保持時間の調整範囲 |
| 電源を入れた直後 | 数十秒ほど OUT が不安定 (初期化時間) | センサーが周囲の熱に慣れるまでの立ち上がり時間。データシートに書かれている定番の注意点 |

## 出典

自作。
