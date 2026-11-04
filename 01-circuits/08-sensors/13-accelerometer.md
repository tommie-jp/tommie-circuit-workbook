---
book: circuits
chapter: 8
id: 8-13
title: 加速度 (モジュール)
tier: 200
source: 自作
board: BB
era: 今
---

# 8-13 加速度 (モジュール)

加速度センサーは、チップの中の小さなおもりが、加速度で動いた分を容量の変化として読み、電圧にして出す部品である (MEMS)。
スマートフォンの画面の向きの切り替え、歩数計、ゲーム機のコントローラーに入っている。

加速度センサーは**重力も加速度として感じる**。机に置いたままでも、下向きに 1 g (9.8 m/s²) がかかっていると読む。
基板を傾けると、重力の向きと軸の向きの角度が変わり、各軸の出力は **1 g × sin(傾き)** で変わる。
この性質から、加速度センサーは**傾きのセンサー**として使え、重力そのものを校正の基準にできる (±1 g を必ず作れる)。

この題では、アナログ出力の 3 軸の加速度センサー ADXL335 を載せた基板 (Adafruit の ADXL335 ブレークアウト) を使う。
Analog Discovery 3 (AD3) のオシロで、基板を回したときの X 軸と Z 軸の出力を見て、1 g あたりの電圧 (感度) を測る。
続けて、X 軸が約 28° 傾いたら LED を点ける傾き警報を、比較器 LM393 で組む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ADXL335 の基板の X 出力を、3Vo を割ったしきい値と LM393 で比べる
parts:
  M1:
    type: device
    at: 2,6
    label: ADXL335
    pins: [Vin, 3Vo, Zout, Xout, GND]
    turn: mirror
  VCC: vcc 4,4 5V
  CH2: port 5,6
  G1: ground 3.5,8.5
  R1: resistor 9,1.5 9,3.5 9.1k
  R2: resistor 9,3.5 9,5.5 11k
  G2: ground 9,5.5
  M3: voltmeter 7,6.4 7,8.4 l=$\mathrm{CH1}$
  G3: ground 7,8.4
  U1A: opamp 12,6 +up
  VCC: vcc 15,2 5V
  R3: resistor 15,2 15,4 1k
  D1: led 15,4 15,6 red
wires:
  - M1.Vin -| 4,4
  - M1.3Vo -| 6,1.5
  - 6,1.5 -- 9,1.5
  - M1.Zout -- 5,6
  - M1.Xout -- 7,6.4 -- 10,6.4
  - 10,6.4 |- U1A.-
  - 9,3.5 -- 10.5,3.5
  - 10.5,3.5 |- U1A.+
  - M1.GND -| 3.5,8.5
  - U1A.out -| 15,6
notes:
  - text 11,9 blue left: "U1 は LM393 (8 番 +5V・4 番 GND)"
  - text 11,10 blue left: "C2 (0.1 µF) は 8 番と 4 番の間"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/13-accelerometer.svg)

- **ADXL335 の基板 (M1)**: Vin に 5 V を入れると、基板の上のレギュレータが 3.3 V を作り、3Vo のピンにも出す。X・Y・Z の出力は
  **電源に比例 (レシオメトリック)** で、0 g のとき 3.3 V の半分の約 1.65 V。Adafruit の説明では、測れる範囲は少なくとも ±3 g
- **感度**: 1 g あたりの電圧は約 0.33 V と**仮定**する (ADXL335 の感度は電源電圧に比例する。この値は品ごとにばらつくので、下の「計器の設定」で重力を使って測る)
- **帯域**: 基板には X・Y・Z の出力ごとに 0.1 µF のコンデンサが付いていて、帯域は約 50 Hz (Adafruit の説明)。手で動かす・傾ける動きは十分通り、
  モータの細かい振動は落ちる
- **傾き警報 (U1A・R1・R2)**: X の出力を LM393 の − 入力に、3Vo を R1 (9.1 kΩ)・R2 (11 kΩ) で割った 3.3 V × 11 ÷ 20.1 ≈ **1.81 V** を + 入力に入れる。
  X が 1.81 V を超えると (1.81 − 1.65) V ÷ 0.33 V/g ≈ 0.47 g、**傾き 28° を超えると**出力が L になり、D1 が点く
- しきい値を 5 V ではなく **3Vo から**作ったのが要点。出力は 3Vo に比例するので、3Vo が少しずれても、出力としきい値が同じ割合で動き、傾きの角度は変わらない
- LM393 の入力は 0〜3.5 V (5 V − 1.5 V) が同相範囲で、1.65〜2 V の X と 1.81 V はその中にある。D1 の電流は (5 − 2.0) V ÷ 1 kΩ ≈ 3 mA
- Z の出力 (CH2 の端子) は、傾きを見るためにオシロの CH2 につなぐだけ。Y は使わない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ADXL335 の基板 (上から線でつなぐ) と LM393 の傾き警報
board: half
parts:
  M1:
    type: device
    at: top
    label: ADXL335 の基板 (Adafruit 163)
    pins: [Vin, GND, 3Vo, Xout, Zout]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor g8 g12 9.1k cap=left
  R2: resistor j12 -b12 11k
  U1: dip8 @ e14 LM393
  C2: capacitor/ceramic c11 c14 100n
  D1: led g19(A) g14(K) red
  R3: resistor i19 i24 1k
  SC:
    type: device
    at: bottom
    label: Analog Discovery 3 (Scope)
    pins: [1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t27 red
  - AD.GND -- -t29 black
  - -t1 -- -b1 black
  - +t30 -- +b30 red
  - M1.Vin -- +t3 red
  - M1.GND -- -t5 black
  - M1.3Vo -- a8 orange
  - e8 -- f8 orange
  - M1.Xout -- a10 yellow
  - e10 -- f10 yellow
  - h10 -- h15 yellow
  - i12 -- i16 green
  - M1.Zout -- a20 blue
  - e20 -- f20 blue
  - +t14 -- a14 red
  - a11 -- -t11 black
  - a16 -- -t16 black
  - a17 -- -t17 black
  - j17 -- -b17 black
  - j24 -- +b24 red
  - SC.1+ -- j10 yellow
  - SC.1- -- -b9 black
  - SC.2+ -- j20 blue
  - SC.2- -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/13-accelerometer.svg)

- 5 V は AD3 の Supplies の V+ から上の + レールへ。右端の列 30 で下の + レールへ渡し、上下の − レールを左端でつなぐ
- **ADXL335 の基板**はブレッドボードに挿さず、ピンヘッダにメス-オスのジャンパ線をつなぐ (傾けたり回したりするため。線は 20 cm ほど)。
  Vin を + レール、GND を − レールへ。3Vo (橙) は列 8、Xout (黄) は列 10、Zout (青) は列 20 へ挿し、短い線で下のブロックへ渡す。
  ピンの並びは基板の印字で確かめる
- **しきい値**: R1 (列 8〜12、下) と R2 (列 12 と − レール)。列 12 が 1.81 V で、緑の線で LM393 の 3 番 (1IN+、列 16) へ
- **LM393** は溝をまたいで、切り欠きを左に。1 番 (1OUT) が左下の `f14`、8 番 (VCC) が左上の `e14`。X (列 10) は黄の線 `h10 -- h15` で 2 番 (1IN−) へ。
  4 番 (GND、列 17 下) は − レールへ。使わない 2 回路目の入力 (5・6 番 = 上の列 17・16) は − レールへ。C2 は上の列 11〜14
- **LED**: D1 のカソードを 1 番の列 14 (`g14`)、アノードを列 19 (`g19`)。R3 (列 19〜24) の右端を下の + レールへ
- オシロの CH1 (1+) は X (`j10`)、CH2 (2+) は Z (`j20`)
- 電流は ADXL335 の基板の 1 mA 以下 (レギュレータを含む目安)、しきい値の分圧の 0.16 mA、LM393 の 1 mA 以下、D1 の 3 mA で、合わせて 5 mA ほど。
  AD3 の Supplies とブレッドボードの範囲に収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V。Scope は CH1 を X、CH2 を Z にして、横 500 ms/div、縦はどちらも 200 mV/div で、
縦の位置を −8 目盛にして 1.65 V を画面の中ほどに置く (1.3〜2.0 V が画面に入る)。トリガは使わず (Scan の表示で流す)、基板を手に持ち、
**X 軸を水平に保ったまま、Y 軸の周りに 2 秒で 1 回転**させる (机の上で基板を立てて、ゆっくり転がすように回す)。

見えるはずの画面 (感度 0.33 V/g・0 g で 1.65 V と**仮定**し、一定の速さで回したときの計算値で、実測ではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Y 軸の周りに回すと、X (CH1) と Z (CH2) が 90° ずれて ±1 g 振れる
time: 500ms/div
trigger: ch1 rising 1.65V at -5div
ch1: {wave: sine 0.5Hz 0.33V offset 1.65V, range: 200mV/div, position: -8div}
ch2: {wave: sine 0.5Hz 0.33V offset 1.65V phase 90deg, range: 200mV/div, position: -8div}
measure: [vmax, vmin, freq, phase]
cursors: [500ms, 1500ms]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/13-accelerometer.svg)

- X と Z は、どちらも 1.32〜1.98 V の間を振れ、互いに 1/4 回転 (90°) ずれる。X が最大のとき Z は 1.65 V (0 g)
- **感度の測り方**: カーソルを X の山 (X1) と谷 (X2) に置き、差 (= 2 g ぶん) を 2 で割ると、1 g あたりの電圧。図3 では 0.66 V ÷ 2 = 0.33 V/g
- 基板を机に平らに置くと、X は 1.65 V (0 g)、Z は 1.98 V (+1 g)。裏返すと Z が 1.32 V (−1 g) になる
- **傾き警報**: 基板を平らにして、X 軸の先を持ち上げていく。約 28° (X が 1.81 V) を超えたところで D1 が点く。逆向きに傾けても点かない (X が下がるため)
- 手で軽く叩くと、50 Hz の帯域で丸まった数十 ms の山が乗る。帯域の外の振動は見えない

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 3 軸加速度センサーの基板 | Adafruit ADXL335 ブレークアウト (163。3.3 V のレギュレータ・0.1 µF のフィルタつき、Vin は 5 V まで) |
| U1 | コンパレータ | LM393 (2 回路のうち 1 回路を使う) |
| R1 | 抵抗 (1/4 W) | 9.1 kΩ |
| R2 | 抵抗 (1/4 W) | 11 kΩ |
| R3 | 抵抗 (1/4 W) | 1 kΩ |
| C2 | 積層セラミックコンデンサ | 0.1 µF (104) |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+。約 5 mA) |

## 見るべき値

感度と 0 g の電圧は仮定 (品ごとにばらつく)。測った値で置き換える。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 3Vo | 約 3.3 V | 基板のレギュレータの出力 |
| X・Z、0 g の向き | 約 1.65 V | 3Vo の半分 (レシオメトリック) |
| Z、平らに置いて表 / 裏 | 約 1.98 V / 約 1.32 V | +1 g / −1 g。重力が校正の基準になる |
| 1 g あたりの電圧 | 約 0.33 V/g | (+1 g の電圧 − −1 g の電圧) ÷ 2 |
| 回したときの X と Z のずれ | 90° | 各軸は 1 g × sin(角度)・1 g × cos(角度) |
| しきい値 (LM393 の 3 番) | 約 1.81 V | 3Vo × 11 ÷ 20.1。3Vo に比例して動く |
| D1 が点く傾き | 約 28° | sin⁻¹((1.81 − 1.65) ÷ 0.33) |
| D1 の電流 | 約 3 mA | (5 − 2.0) V ÷ 1 kΩ |

## LTspice での確かめ

`sim/13-accelerometer.cir` で傾き警報の側を解いた。ADXL335 の基板の X 出力は「1.65 V + 0.33 V × sin(傾き)」の電圧源で置き (仮定)、
傾きを 0° から 90° まで時間でゆっくり増やした。LM393 は開放コレクタの出力を電圧制御スイッチで置いた。加速度センサーの中 (MEMS) は SPICE の対象外。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| しきい値 | 約 1.81 V | 1.806 V | 合う |
| D1 が点く傾き | 約 28° | 28.2° | 合う |
| D1 の電流 | 約 3 mA | 3.25 mA | 合う |
| 分圧が 3Vo から引く電流 | 0.16 mA | 0.164 mA | 合う (基板のレギュレータに負担にならない) |

## 出典

自作。基板の仕様 (3.3 V のレギュレータ・Vin は 5 V まで・0 g で 1.65 V・0.1 µF で 50 Hz の帯域) は Adafruit の
[ADXL335 - 5V ready triple-axis accelerometer](https://www.adafruit.com/product/163) と
[Adafruit Analog Accelerometer Breakouts](https://cdn-learn.adafruit.com/downloads/pdf/adafruit-analog-accelerometer-breakouts.pdf) (重力を校正の基準に使う方法も)。
LM393 の同相範囲は Texas Instruments の [LM393 データシート](https://www.ti.com/lit/ds/symlink/lm393.pdf)。

参考: [加速度計 (Wikipedia)](https://ja.wikipedia.org/wiki/加速度計)
