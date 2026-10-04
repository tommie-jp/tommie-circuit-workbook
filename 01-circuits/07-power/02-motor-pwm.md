---
book: circuits
chapter: 7
id: 7-2
title: DC モータの PWM (MOSFET)
tier: 50
source: 自作
board: BB
era: 今
---

# 7-2 DC モータの PWM (MOSFET)

5 V の DC モータの速さを、MOSFET 1 個で変える。モータの回転数は、掛ける電圧の平均値でおおよそ決まる。
電圧を下げるのに抵抗を挟むと、熱になって無駄が多い。そこで MOSFET (2-5 で見たスイッチ) を高速に ON/OFF して、
平均の電圧をデューティ比 (1 周期のうち ON の時間の割合。3-6 で見た) で変える。
この方法を **PWM** (Pulse Width Modulation、パルス幅変調) といい、今のモータ制御の定番だ。

## 回路図

```circuit
title: 図1 モータを MOSFET で PWM 駆動する
parts:
  B1: battery a9 c9 5
  M1: motor a5 c5
  D1: diode c7 a7 1N4001
  Q1: nmos-e c5i0b0 2N7000
  R1: resistor d1 d3 100
  R2: resistor d3 f3 10k
  PWM: square d1 f1 5 l=$\mathrm{PWM}$
  G1: ground f5
  G2: ground f3
  G3: ground f1
  G4: ground c9
wires:
  - a5 -- a7 -- a9
  - c5 -- c7
  - c5 -- Q1.D
  - Q1.S -- f5
  - d3 -| Q1.G
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/02-motor-pwm.svg)

- PWM は方形波の電源 (0〜5 V、デューティ比を変えられる) を表す。実際はファンクションジェネレータ
  (0-6 参照) か、マイコン (Pico 2 など。11-4 で扱う) の PWM 出力を使う
- R1 (100 Ω) は、MOSFET のゲートに流れ込む充放電の電流を抑える。R2 (10 kΩ) は
  ゲートを GND に軽く引く (プルダウン)。PWM 側が外れたり、何もつながっていないのと同じ状態 (高インピーダンス) になったりしても、
  Q1 が中途半端に ON したままにならない
- D1 (1N4001) はモータと並列のフライバックダイオード。Q1 が OFF になった
  瞬間、モータのコイル成分 (巻線のインダクタンス) が逆起電力を出すので、
  6-2・7-1 と同じ理屈で MOSFET を守る
- Q1 (2N7000) は 5 V のゲート電圧で十分 ON する小信号 MOSFET。もっと大きい
  モータを回すなら IRLZ44N のようなロジックレベルのパワー MOSFET に替える

## 実体配線図

```breadboard
title: 図2 ブレッドボードにモータと MOSFET を組む
board: half
parts:
  D1: diode b3(K) b6(A) 1N4001
  R2: resistor b7 b10 10k
  R1: resistor d7 d12 100
  Q1: transistor h6(D) h7(G) h8(S) 2N7000
  PSU:
    type: device
    at: top
    label: 電源 5V
    pins: ["+", "-"]
  MTR:
    type: device
    at: top
    label: DC モータ
    pins: [M+, M-]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - MTR.M+ -- +t4 red
  - +t3 -- a3 red
  - MTR.M- -- a6 orange
  - a10 -- -t10 black
  - e6 -- f6 orange
  - e7 -- f7 green
  - j8 -- -b8 black
  - -t27 -- -b27 black
notes:
  - text: R1 の右端 (12 列) が PWM 信号の入り口。ファンクションジェネレータかマイコンをつなぐ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/02-motor-pwm.svg)

- モータは板に挿さず、線でつなぐ。D1 のカソード (3 列) がモータの + 側、
  アノード (6 列) がモータの − 側で、6 列はオレンジの線で下のブロックの Q1 のドレインへ渡す
- 上のブロックの 7 列が、R1・R2・Q1 のゲートをつなぐ点になる。R2 (7→10 列) は 10 列から − レールへ、
  R1 (7→12 列) の右端 (12 列) が PWM 信号の入り口。7 列は緑の線で下のブロックの Q1 のゲートへ渡す
- Q1 (2N7000) は TO-92。平らな面を手前にして見ると、左から S・G・D (2SC1815 とは並びが違う)。
  ここでは平らな面を奥 (a 行側) に向けて挿すので、左から D・G・S になり、h 行の 6・7・8 列に入る。
  ソース (S、8 列) は下の − レールへつなぐ
- PWM 信号の GND は − レールにつなぐ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | DC モータ (小型、5 V 定格) | 無負荷電流 約 150 mA (5 V 時) |
| Q1 | N チャネル MOSFET | 2N7000 |
| D1 | 整流ダイオード (フライバック用) | 1N4001 |
| R1 | 抵抗 (ゲート直列) | 100 Ω |
| R2 | 抵抗 (ゲートプルダウン) | 10 kΩ |

## 見るべき値

表の値は計算値。モータを平均的な抵抗 R<sub>eq</sub> = 5 V / 150 mA ≈ 33.3 Ω とみなした近似で、
平均電圧 = 5 V × デューティ比、平均電流 = 平均電圧 ÷ R<sub>eq</sub> とした
(実際は回転数に応じた逆起電力があるので、電流は表より小さくなる)。
モータの両端の平均電圧は、テスターの DC 電圧レンジで測れる (テスターは速い変化をならして平均を出す)。
PWM の波形は Analog Discovery のオシロ (1+ を Q1 のドレイン、1− を GND) で見る。

| デューティ比 | モータに掛かる平均電圧 | 平均電流 (計算値) | 回転の様子 |
| --- | --- | --- | --- |
| 25% | 1.25 V | 37.5 mA | ゆっくり回る、止まりかけ |
| 50% | 2.5 V | 75 mA | 半分ほどの速さ |
| 75% | 3.75 V | 112.5 mA | 速く回る |
| 100% (ON しっぱなし) | 5.0 V | 150 mA | 全速 (PWM でなく直結と同じ) |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| PWM 周波数を 1 kHz にしたとき | モータから「ジー」という音 | 巻線がスイッチングの周波数で振動する音。1 kHz は人の耳の可聴域 (約 20 Hz〜20 kHz) の中 |
| PWM 周波数を 15〜20 kHz 以上にしたとき | 音がほぼ消える | 可聴域の上の端に近づく。大人の多くは 15 kHz より上が聞こえにくい |
| D1 を外してデューティ比を急に 0 にしたとき | Q1 が発熱・破損することがある | フライバックダイオードが要る理由 (**この教科書では外して試さない**) |

## 出典

自作。
