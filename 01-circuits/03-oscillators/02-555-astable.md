---
book: circuits
chapter: 3
id: 3-2
title: 555 非安定 — LED 点滅
tier: 50
source: 自作
board: BB
---

# 3-2 555 非安定 — LED 点滅

タイマー IC の定番 **NE555** (0-3 で方形波を作った IC) を非安定 (astable) 接続にして
LED を点滅させる。3-1 のトランジスタ 2 石と同じ「非安定」だが、周期は 2 本の抵抗と
コンデンサ 1 個だけで決まり、計算どおりに動きやすい。555 は中にコンパレータ (電圧を比べる回路)
2 つと、High と Low のどちらかを覚えておく回路 (フリップフロップ、第 10 章)、放電用のトランジスタを持つ。
C1 の電圧が電源の 2/3 (Vcc の 2/3) まで上がると出力を Low にして C1 を放電し、
1/3 まで下がると出力を High に戻して充電する。これで充放電が繰り返される。

## 回路図

```circuit
title: 図1 555 非安定
parts:
  V1: vsource 4,3 4,9 5
  VCC: vcc 4,3 5V
  G1: ground 4,9
  U1: ic 10,5 NE555
  VCC: vcc 7,2 5V
  Ra: resistor 7,2 7,4.5 10k
  Rb: resistor 7,4.5 7,6.5 47k
  C1: ecap 8,6.5 8,9 10u
  G3: ground 8,9
  VCC: vcc 10,2 5V
  G2: ground 10,9
  Cc: capacitor 12,7 12,9 10n
  G5: ground 12,9
  R1: resistor 13,5 15,5 220
  D1: led 15,5 15,7 red
  G4: ground 15,9
wires:
  - U1.8 |- 10,2
  - U1.4 |- 10.5,2
  - 10,2 -- 10.5,2
  - U1.7 -| 7,4.5
  - U1.6 -| 8,5
  - U1.2 -| 8,5.5
  - 8,5 -- 8,6.5
  - 7,6.5 -- 8,6.5
  - U1.1 |- 10,9
  - U1.5 |- 10.5,7
  - 10.5,7 -- 12,7
  - U1.3 -| 13,5
  - 15,7 -- 15,9
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/02-555-astable.svg)

- 図1 の **2 番 (TRIG) と 6 番 (THRES) を直結**するのが非安定接続の印。この 1 点の電圧が
  1/3 Vcc〜2/3 Vcc の間を上下し続け、それに合わせて 3 番 (OUT) が反転する
- **7 番 (DISCH) は Ra・Rb の中点**。C1 を充電するときは Ra + Rb を通り、
  放電するときは内部トランジスタが 7 番を GND に落として Rb だけを通る。
  充電より放電が速いので、555 の非安定は**必ず High のほうが長い**
- Cc (0.01 µF = 10 nF) は 5 番 (CONT) のノイズ対策。無くても発振はするが、
  付けておくのが定石

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V/GND、下のレールも +5V/GND (1 列目で上下を渡している)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 10k
  Rb: resistor a11 a15 47k
  C1: capacitor/electrolytic i9(+) i5(-) 10uF
  Cc: capacitor d13 d20 10n
  R1: resistor g12 g16 220
  D1: led h16(A) h19(K) red
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - c15 -- c12 orange
  - d12 -- d9 orange
  - e9 -- f9 orange
  - g9 -- g11 orange
  - c20 -- -t20 black
  - j5 -- -b5 black
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j19 -- -b19 black
  - SC.1+ -- j12 yellow
  - SC.1- -- -b14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/02-555-astable.svg)

- 図2 の **DIP8 (8 ピンの IC) は溝をまたいで挿す** (e 行と f 行)。1 番 (GND) が左下の f10、8 番 (VCC) が
  左上の e10。切り欠きを左に向ける
- 2 番 (TRIG、f11) は下ブロックにあるので、ブレッドボードの上の 6 番 (THRES、e12) へは
  IC の左を回るオレンジの線 (`d12 -- d9`、`e9 -- f9`、`g9 -- g11`) で渡す。C1 の + はこの 9 列に挿す
- Rb (47 kΩ) は Ra の右端 (11 列、7 番) から右へ 4 穴渡して 15 列に挿し、15 列から 12 列 (6 番) へ短い橙の線で戻す
- 4 番 (RESET) は使わないので +5V に固定 (`i13 -- +b13`)。浮かせておくと
  誤動作することがある

- 電源は AD3 の Supplies (V+ を 5 V にする)。回路が流すのは LED の約 6.8 mA と 555 の数 mA で、V+ の 50 mA (USB 給電で 250 mW) に収まる。
  V+ は上の + レール、GND は上の − レールへ入れ、1 列目の線で下のレールへ渡す
- Scope はブレッドボードの下に別の箱 (AD3 Scope) で描いた。1+ (黄) は 3 番 (OUT、12 列) の `j12` に挿し、1− (黒) は下の − レール (GND) へ挿す

## 計器の設定

オシロには AD3 の Scope を使う。1 Hz ほどの遅い方形波の形と時間を見る題で、10 MHz よりずっと遅いから。
3 番 (OUT) を CH1 に当て、High の時間と周期を読む。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (3 番 OUT、12 列) | DC、1 V/div |
| Time | 200 ms/div (2 秒で周期が約 2.8 個見える) |
| Trigger | CH1、立ち上がり、1.8 V |

```scope
title: 図3 555 の出力 (3 番) — High が約 0.40 秒、周期が約 0.72 秒
time: 200ms/div
trigger: ch1 rising 1.8V
ch1: {wave: pulse 1.386Hz 1.75V offset 1.75V duty 55%, range: 1V/div}
cursors: [1ms, 396ms]
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/02-555-astable.svg)

図3 は計算値 (High 約 3.5 V、Low は 0 V と置いた) の想定の波形で、実測ではない。カーソルの間隔 395 ms が High の時間 (LED が点いている間)。
1 周期 (約 0.72 秒) から引いた残りが Low の約 0.33 秒。High がわずかに長いので、デューティ比は 55 % ほどになる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| Ra | 抵抗 | 10 kΩ |
| Rb | 抵抗 | 47 kΩ |
| C1 | 電解コンデンサ (タイミング) | 10 µF |
| Cc | セラミックコンデンサ (CONT のノイズ対策) | 0.01 µF |
| R1 | 抵抗 (LED 電流制限) | 220 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+ (3 番 OUT) |

## 見るべき値

点灯・消灯の時間はストップウォッチで 10 回分を測って 10 で割るか、オシロ (0-3) で 3 番の波形を見る (図3)。

計算値。f = 1.44 / {(Ra + 2Rb) × C}、High の時間は (Ra + Rb) × C × 0.693、
Low の時間は Rb × C × 0.693。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 3 番 (OUT) の周波数 | 約 1.39 Hz (周期 約 0.72 秒) | Ra・Rb・C1 だけで決まる |
| Low (LED 消灯) の時間 | 約 0.33 秒 | Rb × C1 × 0.693 |
| High (LED 点灯) の時間 | 約 0.40 秒 | (Ra + Rb) × C1 × 0.693 |
| デューティ比 (High の割合) | 約 55% | (Ra+Rb) / (Ra+2Rb)。**555 の非安定はきっちり 50% にならない** |
| LED の電流 (点灯中) | 約 6.8 mA | (5 V − 出力 High の飽和 (バイポーラ 555 は Vcc−1.5 V 程度) − 2.0 V) ÷ 220 Ω |

Ra を 0 に近づけるとデューティ比は 50% に近づくが、Ra が小さすぎると
放電の間に Vcc から Ra を通って 7 番へ大電流が流れ込み、IC を痛める (下限は 1 kΩ 程度)。
デューティ比をきっちり変えたいなら 3-6 のダイオード付き PWM を見る。

## 出典

自作。
