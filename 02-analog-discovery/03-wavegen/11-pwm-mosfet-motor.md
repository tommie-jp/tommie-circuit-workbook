---
book: analog-discovery
chapter: 3
id: 3-11
title: PWM 波形で MOSFET 経由のモータ
tier: 200
source: 自作 (回路は回路の教科書の 7-2。計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-11 PWM 波形で MOSFET 経由のモータ

Wavegen の W1 を PWM (パルス幅変調) の信号源にして、MOSFET (2N7000) で小さな DC モータを回す。
回路は回路の教科書の 7-2 と同じで、ここでは**信号源の側の設定**を詰める。
0 V / 5 V の方形波を Amplitude と Offset で作ること、デューティ比を Symmetry で変えること、
周波数でモータの音が変わること、そして **Wavegen を止めたときの出力の電圧**でゲートが中途半端に開く落とし穴を確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の PWM で MOSFET を開閉する (CH2 は Q1 のドレイン)
parts:
  R3: resistor 11,1 11,3 15
  B1: battery 11,3 11,5 5
  M1: motor 5,1 5,3
  D1: diode 7,3 7,1 1N4001
  Q1: nmos-e 5,3.81 2N7000
  R1: resistor 1,4 3,4 100
  R2: resistor 3,4 3,6 10k
  PWM: square 1,4 1,6 5 l=$\mathrm{W1}$
  G1: ground 5,6
  G2: ground 3,6
  G3: ground 1,6
  G4: ground 11,5
  M2: voltmeter 9,3 9,5 l=$\mathrm{CH2}$
  G5: ground 9,5
wires:
  - 5,1 -- 7,1 -- 11,1
  - 5,3 -- 7,3 -- 9,3
  - 5,3 -- Q1.D
  - Q1.S -- 5,6
  - 3,4 -| Q1.G
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/11-pwm-mosfet-motor.svg)

- W1 が 0 V / 5 V の方形波を出し、R1 (100 Ω) を通して Q1 のゲートを開閉する。R2 (10 kΩ) はゲートを GND へ引くプルダウン
- B1 は外の 5 V の電源 (AC アダプタか電源装置)。モータの電流は停動 (軸を止めた状態) で約 0.16 A になり、
  AD3 の Supplies (USB 給電で 250 mW、5 V で 50 mA) を超えるので、AD3 は W1 と Scope だけに使う
- R3 (15 Ω、1 W) は停動の電流を 2N7000 の連続 0.2 A の内側に抑える。D1 (1N4001) は OFF の瞬間の逆起電力を逃がす。
  値の決め方は回路の教科書の 7-2

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 モータと MOSFET を組む (W1 と 1+ が PWM、2+ がドレイン)
board: half
parts:
  R3: resistor/half d2 d5 15
  D1: diode b5(K) b8(A) 1N4001
  R2: resistor b9 b12 10k
  R1: resistor d9 d14 100
  Q1: transistor h8(D) h9(G) h10(S) 2N7000
  PSU:
    type: device
    at: top
    label: 電源 5V (AC アダプタ等)
    pins: ["+", "-"]
  MTR:
    type: device
    at: top
    label: DC モータ RF-300CA
    pins: [M+, M-]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [2+, W1, 1+, 1-, 2-, GND]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t3 black
  - +t2 -- a2 red
  - MTR.M+ -- a5 brown
  - MTR.M- -- a8 orange
  - a12 -- -t12 black
  - e8 -- f8 orange
  - e9 -- f9 green
  - j10 -- -b10 black
  - -t27 -- -b27 black
  - AD.W1 -- e14 yellow
  - AD.1+ -- c14 blue
  - AD.2+ -- j8 green
  - AD.1- -- -b17 black
  - AD.2- -- -b19 black
  - AD.GND -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/11-pwm-mosfet-motor.svg)

- 並びは回路の教科書の 7-2 の図2 と同じ。W1 (黄) と 1+ (青) は R1 の右端の 14 列、2+ (緑) は Q1 のドレインの 8 列
- Q1 (2N7000) は平らな面を奥 (a 行側) に向けて挿し、h 行の 8・9・10 列が D・G・S。
  **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- 外の電源の − と AD3 の GND は、上と下の − レールを 27 列でつないで共通にする

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | DC モータ (小電流の品) | マブチ RF-300CA-11440 (0.7〜5.0 V。2 V で無負荷 0.018 A・停動 0.17 A) |
| R3 | 抵抗 (モータの電流の制限、1 W) | 15 Ω |
| Q1 | N チャネル MOSFET | 2N7000 |
| D1 | 整流ダイオード (フライバック用) | 1N4001 |
| R1 | 抵抗 (ゲート直列) | 100 Ω |
| R2 | 抵抗 (ゲートのプルダウン) | 10 kΩ |
| B1 | 電源 | 5 V の AC アダプタか電源装置 (停動で約 0.16 A となり AD3 の Supplies の 50 mA を超えるため) |
| — | 計器・PWM の信号源 | Analog Discovery 3 の W1 と Scope (1+ = PWM、2+ = Q1 のドレイン) |

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、Frequency 1 kHz、**Amplitude 2.5 V、Offset 2.5 V** (0 V〜5 V を振れる)、**Symmetry 25 %** (デューティ比。50・75 % に変える) |
| Scope | CH1・CH2 とも DC 結合、Range 1 V/div、位置 −3 div (0〜5 V が 5 目盛)、Time 500 µs/div。トリガ CH1 立ち上がり 2.5 V。Measure に Duty・Frequency (CH1)、Average (CH2) |

Amplitude は Offset から上下に振る幅 (3-1) なので、2.5 V ± 2.5 V で 0 V〜5 V になる。
5 V は Wavegen の出力の範囲 ±5 V の内側。振幅が ±1.25 V を超えるので、W1 は 10 Vpp のレンジ (分解能 665 µV) で出す (仕様)。
ゲートに流れる電流は R2 の 5 V ÷ 10 kΩ = 0.5 mA と、ゲートの容量の充放電だけで、W1 の上限 30 mA (3-5) よりずっと小さい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 デューティ比 25 % — CH1 が 5 V の間だけ CH2 (ドレイン) が 0.2 V に落ちる
time: 500us/div
trigger: ch1 rising 2.5V
ch1: {wave: pulse 1kHz 2.5V offset 2.5V duty 25%, range: 1V/div, position: -3div}
ch2: {wave: "ch1 | invert | offset 5V | gain 0.96 | offset 200mV", range: 1V/div, position: -3div}
measure: [duty, freq, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/11-pwm-mosfet-motor.svg)

CH2 の ON の間の 0.2 V は、回っているときの電流を数十 mA (目安) として 2N7000 の ON 抵抗 4.5 Ω から見積もった値で、実測ではない。
OFF になる瞬間は D1 が逆起電力を逃がすので、ドレインは一瞬だけ 5 V より約 0.8 V 高くなる (図3 には描いていない)。

## 見るべき値

計算値。モータと R3 の組に掛かる平均の電圧は、CH2 の Average から 5 V − (CH2 の平均) で読める。

| Symmetry | CH1 の Duty | CH2 の Average (目安) | モータと R3 の平均 | 回転 |
| --- | --- | --- | --- | --- |
| 25 % | 25 % | 3.80 V (= 0.75 × 5 + 0.25 × 0.2) | 1.20 V | ゆっくり |
| 50 % | 50 % | 2.60 V | 2.40 V | 半分ほど |
| 75 % | 75 % | 1.40 V | 3.60 V | 速い |

| 試すこと | 期待すること | 分かること |
| --- | --- | --- |
| Frequency を 1 kHz → 20 kHz | 「ジー」という音がほぼ消え、回転はほぼ同じ | 回転はおおよそ平均の電圧で決まる。20 kHz は可聴域 (約 20 Hz〜20 kHz) の端。OFF の間も電流が D1 とモータを回り続けるので、モータの電流は途切れずに平らになり、電源から引く電流は減る (下の LTspice) |
| Frequency を 20 Hz に下げる | 回転がガタつく | 1 周期 50 ms がモータの機械の時定数に近づき、回転がならされなくなる |
| Run 中に **Stop** を押す | W1 は止める前の設定の電圧に留まることがある (Idle の設定による。**未確認**) | Offset 2.5 V に留まると、ゲートが 2.5 V になる |
| ゲートが 2.5 V のまま (停動のとき) | 2N7000 が半分だけ開き、最悪で約 0.23 W 熱になる | V<sub>GS(th)</sub> は 0.8〜3 V とばらつくので、2.5 V は「開くかもしれない」電圧。下の LTspice の表 |

Stop のあとの電圧は Wavegen の Idle の選び方で決まる (3-6)。PWM の源にするときは、Stop で 0 V になる設定を選び、
**Stop を押したら CH1 で 0 V に戻ったことを確かめる**。R2 のプルダウンは W1 のワイヤが抜けたときの守りで、
W1 が 2.5 V を出し続けるときは役に立たない (W1 の出力インピーダンスはほぼ 0 Ω)。

## LTspice での確かめ

`sim/11-pwm-mosfet-motor.cir` と `sim/11-pwm-mosfet-motor-idle.cir` は回路の教科書の 7-2 のデッキと同じ模型 (停動 = 逆起電力 0、巻線 11.8 Ω・1 mH は仮定、
2N7000 は V<sub>GS</sub> = 4.5 V で 4.5 Ω になる近似) に、ゲートを 2.5 V の直流にした場合を足した。D1 は図1 のとおりモータだけに並列に置いた。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 停動の電流の最大 (100 %) | 約 0.16 A | 0.161 A | 合う |
| OFF の瞬間のドレインの山 | 5 V + 約 0.8 V | 5.83 V | 合う |
| 停動のモータの平均電流 (1 kHz、25 / 50 / 75 %) | 0.25・0.5・0.75 × 0.16 A = 40・80・120 mA | 42・82・122 mA | 合う (デューティ比に比例。OFF の初めに D1 を回るぶん少し多い) |
| 20 kHz のモータの平均電流 (25 / 50 / 75 %) | ほぼ同じ | 38・91・128 mA | 合う (1 kHz との差は 1 割以内)。電源の平均電流は 12・53・106 mA に減る (1 kHz は 35・75・116 mA)。軸を止めた模型での値で、回っているときは**未確認** |
| ゲート 2.5 V の Q1 (V<sub>GS(th)</sub> = 2.1 / 1.2 / 0.8 V) | 最大で約 0.23 W | 6.8 mA・0.03 W / 77 mA・0.23 W / 130 mA・0.20 W | 合う。2N7000 の許容損失 0.4 W の内側だが、温まり続ける |

## 出典

自作。回路は回路の教科書の 7-2 (DC モータの PWM)。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)、出力の範囲・レンジ・電流は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
2N7000 の V<sub>GS(th)</sub> (0.8〜3 V) と ON 抵抗は [Vishay 2N7000 のデータシート](https://www.vishay.com/docs/70226/70226.pdf)。
