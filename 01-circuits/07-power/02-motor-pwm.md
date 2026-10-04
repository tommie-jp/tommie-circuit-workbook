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
title: 図1 モータを MOSFET で PWM 駆動する (CH2 は Q1 のドレインの電圧)
parts:
  R3: resistor a11 c11 15
  B1: battery c11 e11 5
  M1: motor a5 c5
  D1: diode c7 a7 1N4001
  Q1: nmos-e c5i0b0 2N7000
  R1: resistor d1 d3 100
  R2: resistor d3 f3 10k
  PWM: square d1 f1 5 l=$\mathrm{PWM}$
  G1: ground f5
  G2: ground f3
  G3: ground f1
  G4: ground e11
  M2: voltmeter c9 e9 l=$\mathrm{CH2}$
  G5: ground e9
wires:
  - a5 -- a7 -- a11
  - c5 -- c7 -- c9
  - c5 -- Q1.D
  - Q1.S -- f5
  - d3 -| Q1.G
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/02-motor-pwm.svg)

- PWM (AD の W1 が出す信号。CH1 で見る) は方形波の電源 (0〜5 V、デューティ比を変えられる) を表す。実際はファンクションジェネレータ
  (0-6 参照) か、マイコン (Pico 2 など。11-4 で扱う) の PWM 出力を使う
- R1 (100 Ω) は、MOSFET のゲートに流れ込む充放電の電流を抑える。R2 (10 kΩ) は
  ゲートを GND に軽く引く (プルダウン)。PWM 側が外れたり、何もつながっていないのと同じ状態 (高インピーダンス) になったりしても、
  Q1 が中途半端に ON したままにならない
- D1 (1N4001) はモータと並列のフライバックダイオード。Q1 が OFF になった
  瞬間、モータのコイル成分 (巻線のインダクタンス) が逆起電力を出すので、
  6-2・7-1 と同じ理屈で MOSFET を守る
- Q1 (2N7000) は 5 V のゲート電圧で ON する小信号 MOSFET。データシート (Vishay 2N7000) の
  連続のドレイン電流は 0.2 A、ON 抵抗 r<sub>DS(on)</sub> は V<sub>GS</sub> = 4.5 V で 4.5 Ω (典型)・5.3 Ω (最大)
- **M1 は小さな電流のモータ、R3 (15 Ω) は電流を抑える抵抗。** モータは回り始める瞬間と、軸を止められたとき
  (停動) に、回っているときの何倍もの電流が流れる。巻線の抵抗だけで電流が決まるからだ。
  ふつうの 5 V の小型モータでは停動の電流が 0.5〜1 A を超えることがあり、2N7000 の 0.2 A と、
  ブレッドボードの 1 穴 200 mA (README の板の表) を超える。そこで、停動の電流が小さいモータを選び、
  R3 を直列に入れて、最悪でも 0.2 A に収める
- M1 には、マブチの RF-300CA-11440 (ソーラーモーターとして売られている品) を使う。データシートでは
  使える電圧 0.7〜5.0 V、2 V で無負荷電流 0.018 A・停動電流 0.17 A。巻線の抵抗は 2 V ÷ 0.17 A ≈ 11.8 Ω
- 停動の電流 (5 V、PWM 100 %) は、式 I = 5 V ÷ (巻線 + R3 + r<sub>DS(on)</sub>)、
  代入 5 ÷ (11.8 + 15 + 4.5)、結果 約 0.16 A。R3 が無いと 5 ÷ (11.8 + 4.5) ≈ 0.31 A になり、上限を超える。
  R3 の電力は停動で 0.16² × 15 ≈ 0.38 W なので、2 倍以上の 1 W 品にする。回っているときは
  電流が数十 mA なので、R3 で落ちる電圧は 0.4 V ほどで済む
- 別のモータを使うなら、巻線の抵抗をテスターで測り、5 V ÷ (巻線 + R3 + 4.5 Ω) が 0.2 A 以下になる R3 を選ぶ。
  もっと大きいモータは、ブレッドボードの外で、IRLZ44N のようなロジックレベルのパワー MOSFET と太い線で回す

## 実体配線図

```breadboard
title: 図2 モータと MOSFET を組む (W1 が PWM、1+ が PWM、2+ がドレイン)
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
    label: Analog Discovery (W1 と Scope)
    pins: [W1, 1+, 1-, 2+, 2-, GND]
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
  - AD.W1 -- c14 yellow
  - AD.1+ -- e14 blue
  - AD.2+ -- j8 green
  - AD.1- -- -b14 black
  - AD.2- -- -b16 black
  - AD.GND -- -b18 black
notes:
  - text: R1 の右端 (14 列) が PWM 信号の入り口。AD の W1 かマイコンをつなぐ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/02-motor-pwm.svg)

- モータは板に挿さず、線でつなぐ。+5V は 2 列から R3 (2→5 列) を通ってモータの + 側 (5 列、茶の線) へ行く。
  D1 のカソード (5 列) がモータの + 側、アノード (8 列) がモータの − 側で、D1 はモータに並列に入る。
  8 列はオレンジの線で下のブロックの Q1 のドレインへ渡す
- モータの電流 (最大で停動の約 0.16 A) が通る穴は、+ レール・2 列・5 列・8 列・Q1 の足・− レール。
  どれも README の板の表の 1 穴 200 mA の内側に入る
- 上のブロックの 9 列が、R1・R2・Q1 のゲートをつなぐ点になる。R2 (9→12 列) は 12 列から − レールへ、
  R1 (9→14 列) の右端 (14 列) が PWM 信号の入り口。9 列は緑の線で下のブロックの Q1 のゲートへ渡す
- Q1 (2N7000) は TO-92。平らな面を手前にして見ると、左から S・G・D (2SC1815 とは並びが違う)。
  ここでは平らな面を奥 (a 行側) に向けて挿すので、左から D・G・S になり、h 行の 8・9・10 列に入る。
  ソース (S、10 列) は下の − レールへつなぐ
- PWM 信号の GND は − レールにつなぐ
- 5 V の電源は別の電源 (5 V の AC アダプタや電源装置) を使う。回っているときの電流は数十 mA、軸を止めると約 0.16 A (上の計算) で、
  Analog Discovery の Supplies の各レール 50 mA (USB 給電で 250 mW) を超えるので、AD3 は PWM の信号 (W1) とオシロ (Scope) だけに使う
- PWM は AD の W1 (黄) を R1 の右端の 14 列 (`c14`) に入れる。1+ (青) は同じ 14 列 (`e14`) で PWM を、2+ (緑) は Q1 のドレインの 8 列 (`j8`) を見る。
  1−・2−・GND (黒) は下の − レールへ。W1 は 30 mA まで出せ、ゲートに要る電流 (R2 の 0.5 mA ほど) は十分に小さい

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | DC モータ (小電流の品) | マブチ RF-300CA-11440 (0.7〜5.0 V。2 V で無負荷 0.018 A・停動 0.17 A) |
| R3 | 抵抗 (モータの電流の制限、1 W) | 15 Ω |
| Q1 | N チャネル MOSFET | 2N7000 |
| D1 | 整流ダイオード (フライバック用) | 1N4001 |
| R1 | 抵抗 (ゲート直列) | 100 Ω |
| R2 | 抵抗 (ゲートプルダウン) | 10 kΩ |
| — | 電源 | 5 V の AC アダプタか電源装置 (停動で約 0.16 A となり AD3 の Supplies の 50 mA を超えるため) |
| — | 計器・PWM の信号源 | Analog Discovery 3 の W1 (PWM。0 V / 5 V の方形波、1 kHz) と Scope (1+ = PWM、2+ = Q1 のドレイン、1−・2− = GND) |

## 計器の設定

計器は Analog Discovery 3 の W1 (PWM の信号源) と Scope。PWM のパルスの幅と形は時間の波形で見るので、テスターでは足りない。
W1 は Simple の Square、Frequency 1 kHz、Amplitude 2.5 V、Offset 2.5 V、Symmetry (デューティ比) 50 %。
CH1 (PWM) と CH2 (Q1 のドレイン) を同じ 1 V/div で重ねる。

```scope
title: 図3 PWM (CH1) とドレイン (CH2) — デューティ比 50 %
time: 500us/div
trigger: ch1 rising 2.5V
ch1: {wave: pulse 1kHz 2.5V offset 2.5V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: "ch1 | invert | offset 5V | gain 0.96 | offset 200mV", range: 1V/div, position: -3div}
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/02-motor-pwm.svg)

図3 は理想の形。CH2 は PWM と逆向きに動く。Q1 が ON の間はドレインが 0 V 近くに落ち、OFF の間は 5 V に戻る。
ON の間の値 0.2 V は、回っているときのモータの電流を数十 mA (目安) として、2N7000 の ON 抵抗 4.5 Ω との積から見積もった値で、実測ではない
(停動の 0.16 A では約 0.7 V になる)。OFF になる瞬間は D1 がモータの逆起電力を逃がすので、ドレインは一瞬だけ 5 V より約 0.7 V 高くなる。
デューティ比を 25 %・75 % に変えると、CH1 の ON の幅と、下の表の平均電圧 (5 V × デューティ比) が比例して変わる。

## 見るべき値

表の値は計算値。PWM の平均の電圧は 5 V × デューティ比で、これがモータと R3 の組に掛かる。
モータの回転数はおおよそこの平均の電圧で決まる。
モータと R3 の組の両端の平均電圧は、テスターの DC 電圧レンジで測れる (テスターは速い変化をならして平均を出す)。
PWM の波形は Analog Discovery のオシロ (1+ を PWM、2+ を Q1 のドレイン、1−・2− を GND) で見る (図3)。

| デューティ比 | モータと R3 に掛かる平均電圧 | 回転の様子 |
| --- | --- | --- |
| 25% | 1.25 V | ゆっくり回る (RF-300CA は 0.7 V から回る) |
| 50% | 2.5 V | 半分ほどの速さ |
| 75% | 3.75 V | 速く回る |
| 100% (ON しっぱなし) | 5.0 V | 全速 (PWM でなく直結と同じ) |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 回っているときのモータの電流 (100 %。テスターの電流レンジを M+ の線に直列に入れる) | 数十 mA 以下 (目安) | データシートの無負荷電流は 2 V で 0.018 A。負荷が軽ければ小さい |
| 軸を指で軽く止めたときの電流 (100 %) | 約 0.16 A (計算値) | 5 V ÷ (11.8 + 15 + 4.5) Ω。2N7000 の 0.2 A と 1 穴 200 mA の内側。長く止めたままにしない |
| PWM 周波数を 1 kHz にしたとき | モータから「ジー」という音 | 巻線がスイッチングの周波数で振動する音。1 kHz は人の耳の可聴域 (約 20 Hz〜20 kHz) の中 |
| PWM 周波数を 15〜20 kHz 以上にしたとき | 音がほぼ消える | 可聴域の上の端に近づく。大人の多くは 15 kHz より上が聞こえにくい |
| D1 を外してデューティ比を急に 0 にしたとき | Q1 が発熱・破損することがある | フライバックダイオードが要る理由 (**この教科書では外して試さない**) |

## 出典

自作。
