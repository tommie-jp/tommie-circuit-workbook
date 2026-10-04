---
book: circuits
chapter: 3
id: 3-3
title: 555 単安定 — タイマー
tier: 50
source: 自作
board: BB
---

# 3-3 555 単安定 — タイマー

NE555 を単安定 (monostable) 接続にする。**単安定**は、ふだんは 1 つの状態 (出力 Low) に
落ち着いていて、合図 (トリガ) が来たときだけ決まった時間もう一方の状態 (High) になる接続。
ボタンを 1 回押すと、LED が一定の時間だけ点いて自動で消える。
階段の照明やおやすみタイマーのような「押したら一定時間だけ動く」の基本形。

## 回路図

```circuit
title: 図1 555 単安定
parts:
  V1: vsource c1 e1 5
  vcc: vcc c1 5V
  G1: ground e1
  U1: ic g10 NE555
  vcc: vcc c3 5V
  R2: resistor c3 e3 10k
  SW1: button j3 l3
  G3: ground l3
  R1: resistor c7 e7 100k
  C1: ecap g7 i7 10u
  G4: ground i7
  G2: ground i10
  Cc: capacitor i10a5 k10a5 10n
  G5: ground k10a5
  R3: resistor g12 g14 330
  D1: led g14 i14 red
  G6: ground i14
wires:
  - c3 -- c10a5
  - U1.VCC |- c10
  - U1.RESET |- c10a5
  - e7 -- f7f0
  - U1.DISCH -| f7f0
  - U1.THRES -| g7
  - f7f0 -- g7
  - U1.TRIG -| j8a5
  - e3 -- j3
  - j3 -- j8a5
  - U1.GND |- i10
  - U1.CONT |- i10a5
  - U1.OUT -| g12
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/03-555-monostable.svg)

- 図1 の **2 番 (TRIG) は、ふだんは R2 で Vcc 側へ引き上げてある** (プルアップ)。SW1 を押すと GND に
  落ち、それが引き金になって 3 番 (OUT) が High になる
- **7 番・6 番は R1・C1 の 1 点。** OUT が High の間だけ C1 を R1 で充電し、
  2/3 Vcc に達したら 555 が自分で OUT を Low に戻す (SW1 を離しても止まらない)
- 4 番 (RESET) は Vcc に固定、5 番 (CONT) は Cc (0.01 µF) で GND にノイズ対策

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
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e10 NE555
  R1: resistor b7 b11 100k
  C1: capacitor/electrolytic b12(+) b15(-) 10uF
  Cc: capacitor d13 d20 10n
  SW1: button @ f4
  R2: resistor g11 g7 10k
  R3: resistor g12 g16 330
  D1: led h16(A) h19(K) red
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - a11 -- a12 orange
  - a15 -- -t15 black
  - c20 -- -t20 black
  - b4 -- -t4 black
  - i4 -- i11 orange
  - j7 -- +b7 red
  - j10 -- -b10 black
  - i13 -- +b13 red
  - j19 -- -b19 black
  - SC.2+ -- j11 green
  - SC.1+ -- j12 yellow
  - SC.1- -- -b14 black
  - SC.2- -- -b15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/03-555-monostable.svg)

- 図2 の **R1 の右リード (11 列) が 7 番、6 番 (12 列) とは `a11--a12` の 1 本だけで結ぶ**
  (どちらも R1・C1 の同じ 1 点)
- SW1 (タクトスイッチ) は溝をまたぐ 4 ピンで、`e4` `f4` `e6` `f6` を占める。
  **溝の手前 (f 行、下ブロック) を 2 番 (11 列) へ、溝の向こう (e 行、上ブロック) を
  GND へ**。同じ側 (同じブロック) の 2 ピンは押していなくても中でつながっている
- 4 番 (RESET) は使わないので +5V に固定 (`i13 -- +b13`)

- 電源は AD3 の Supplies (V+ を 5 V にする)。回路が流すのは LED の約 6 mA と 555 の数 mA で、V+ の 50 mA (USB 給電で 250 mW) に収まる
- Scope はブレッドボードの下に別の箱 (AD3 Scope) で描いた。2+ (緑) は 2 番 (TRIG、11 列) の `j11`、1+ (黄) は 3 番 (OUT、12 列) の `j12` に挿し、
  1− と 2− (黒) は下の − レール (GND) へ挿す

## 計器の設定

オシロには AD3 の Scope を使う。1 秒ほどの 1 回きりのパルスを見る題で、10 MHz よりずっと遅いから。
CH2 を 2 番 (TRIG、押したときの合図)、CH1 を 3 番 (OUT、パルス) にして、合図からパルスの終わりまでを 1 画面に収める。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (3 番 OUT、12 列) | DC、1 V/div |
| Scope CH2 (2 番 TRIG、11 列) | DC、1 V/div |
| Time | 250 ms/div。トリガの位置を左端の近く (1 目盛) に動かすと、パルスの終わりまで入る |
| Trigger | CH2、立ち下がり、2.5 V。Mode は Normal か Single にして、SW1 を押す |

```scope
title: 図3 SW1 を押すと (CH2 が Low)、OUT (CH1) が約 1.1 秒だけ High になる
time: 250ms/div
trigger: ch2 falling 2.5V at -4div
ch1: {wave: = 3.5V * (step(t) - step(t - 1.1s)), range: 1V/div}
ch2: {wave: = 5V - 5V * (step(t) - step(t - 150ms)), range: 1V/div}
cursors: [10ms, 1.11s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/03-555-monostable.svg)

図3 は計算値 (OUT の High は 3.5 V、スイッチを 150 ms 押したと置いた) の想定の波形で、実測ではない。CH2 の 2 番が Low に落ちた瞬間に CH1 の OUT が立ち上がる。
150 ms 後にスイッチを離して 2 番が 5 V に戻っても、OUT は変わらず約 1.1 秒 (1.1 × 100 kΩ × 10 µF) で Low に戻る。
カーソルの間隔 1.10 秒がパルスの幅。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| R1 | 抵抗 (タイミング) | 100 kΩ |
| C1 | 電解コンデンサ (タイミング) | 10 µF |
| R2 | 抵抗 (TRIG のプルアップ) | 10 kΩ |
| SW1 | タクトスイッチ | — |
| Cc | セラミックコンデンサ (CONT) | 0.01 µF |
| R3 | 抵抗 (LED 電流制限) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+/2+ (OUT と TRIG) |

## 見るべき値

計算値。パルス幅 (OUT が High の時間) T = 1.1 × R1 × C1。時間はストップウォッチか図3 のオシロで測り、
3 番の電圧はテスターの直流電圧レンジで、LED が点いている間に 3 番と GND の間を測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SW1 を押してから LED が消えるまでの時間 | 約 1.1 秒 | R1 × C1 × 1.1 (Vcc の値によらない) |
| パルス中の 3 番 (OUT) の電圧 | 約 3.5 V (Vcc−1.5 V 相当) | バイポーラ 555 の出力 High は Vcc まで振れず、Vcc−1.5 V 程度で頭打ちになる |
| パルス中に SW1 を離した場合 | 変わらず約 1.1 秒で消える | 単安定は**一度始まると引き金を離しても止まらない** |
| パルスの途中でもう一度 SW1 を押した場合 | 延びない。最初に押してから約 1.1 秒で消える | 555 の単安定はリトリガできない。パルス中の引き金は無視される (ただし押し続けたまま時間が来ると、OUT は離すまで High のまま) |

R1 を 1 MΩ にすると約 11 秒まで延ばせる (555 の DISCH の内部トランジスタや C1 の
もれ電流 (リーク電流) が、R1 を流れる電流に比べて無視できる範囲なら)。12-1 の「おやすみタイマー」はこの回路の応用。

## 出典

自作。
