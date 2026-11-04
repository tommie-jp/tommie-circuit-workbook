---
book: circuits
chapter: 7
id: 7-9
title: ブラシレスの原理 (3 相、簡略)
tier: 200
source: 自作
era: 今
---

# 7-9 ブラシレスの原理 (3 相、簡略)

7-2 の DC モータは、回る側 (回転子) の巻線への電流の向きを、ブラシと整流子が機械的に切り替える。
**ブラシレスモータ (BLDC)** は逆で、巻線を外側 (固定子) に置き、回転子を永久磁石にする。巻線の電流を切り替えるのは電子回路だ。
ブラシが擦り減らず火花も出ないので、PC のファン・HDD・ドローン・電動工具など、今の小型モータの多くがこの形になっている。

固定子には U・V・W の 3 相の巻線があり、中点 (COM) で星形につながっている。3 相に、周期の 1/3 (120°) ずつずらした順で電流を流すと、
巻線の作る磁界の向きが一回りし、磁石の回転子がそれを追って回る。この題では、
**3 相の電流を 120° ずつずらして順に流す**ところだけを、7-4 と同じ ULN2003A で組んで確かめる。

**簡略にした所**: 本物の駆動回路 (ESC など) は、各相を電源と GND の両方へつなぐハーフブリッジ (7-3 の H ブリッジの片側) を 3 組並べ、
電流を両方向に流す。さらにホール素子か逆起電力で回転子の位置を読み、切り替えの時刻を合わせる。
ここでは中点を 5 V に固定し、各相を GND へ引くだけ (片方向) にして、位置も読まずに一定の速さで送る。
回せるのはゆっくり (1 秒に十数ステップ) で、トルクも小さい。7-4 のステッピングモータの送り方に近い。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 3 相の巻線を ULN2003A で 120° ずつずらして引く (CH1 は U・CH2 は V の出力)
points:
  in1x: 2,4.25
  in2x: 2,4.5
  in3x: 2,4.75
parts:
  U1: dip16 5,5 ULN2003A
  DIO0: port in1x
  DIO1: port in2x
  DIO2: port in3x
  G1: ground 4,6.75
  Lu: inductor 8,2 8,2.75 l=$\mathrm{U}$
  Lv: inductor 10,2 10,2.75 l=$\mathrm{V}$
  Lw: inductor 12,2 12,2.75 l=$\mathrm{W}$
  R1: resistor 8,3 8,4 47
  R2: resistor 10,3 10,4 47
  R3: resistor 12,3 12,4 47
  VCC: vcc 13.5,2 5V
wires:
  - in1x -- U1.1
  - in2x -- U1.2
  - in3x -- U1.3
  - U1.8 -| 4,6.75
  - 8,2 -- 10,2 -- 12,2 -- 13.5,2
  - 8,2.75 -- 8,3
  - 10,2.75 -- 10,3
  - 12,2.75 -- 12,3
  - 8,4 |- U1.16
  - 10,4 |- U1.15
  - 12,4 |- U1.14
  - U1.9 -| 13.5,2
notes:
  - box 7.5,1.75 12.6,2.88
  - text 10,1.5 center: M1 (モータの巻線。中点が COM)
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/09-bldc-3phase.svg)

- U1 (ULN2003A) は 7-4 と同じダーリントンのシンクドライバ。1〜3 番の入力 (1B〜3B) に AD3 の DIO0〜DIO2 (3.3 V) を入れ、
  16・15・14 番の出力 (1C〜3C) が U・V・W 相の巻線を GND へ引く。入力には 2.7 kΩ が内蔵されている
- 巻線の中点 (COM) は +5 V。ULN2003A の 9 番 (COM) も +5 V につなぐ。9 番は内蔵のフライバックダイオードの共通端子で、
  相を切った瞬間の巻線の逆起電力を 5 V へ逃がす (7-1・7-4 と同じ)
- R1〜R3 (47 Ω、1 W) は各相の電流を抑える。小型のブラシレスモータの巻線は 1 相あたり数 Ω しかなく、5 V をじかに掛けると
  1 A を超える。巻線を 2 Ω (仮定) とすると、1 相の電流は (5 V − 0.9 V) ÷ (47 + 2) Ω ≈ 84 mA になる (0.9 V は ULN2003A の出力の飽和電圧、
  データシートの典型値 @ 100 mA)
- 使うモータは、中点の線が出ている 4 本線の 3 相モータ (HDD や CD-ROM のスピンドルモータなど)。
  巻線の抵抗を、中点と U・V・W の間でテスターで測っておく。3 本の線しかない品 (中点が出ていない) はこの回路では回せない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ULN2003A で 3 相モータを引く (DIO0〜2 が U・V・W)
board: half
parts:
  U1: dip16 @ e14 ULN2003A
  R1: resistor b14 b10 47 cap=above
  R2: resistor c15 c7 47 cap=left
  R3: resistor d16 d4 47
  PSU:
    type: device
    at: top
    label: 電源 5V (別電源)
    pins: ["+", "-"]
  MTR:
    type: device
    at: top
    label: 3 相モータ (中点あり)
    pins: [W, V, U, COM]
  ADS:
    type: device
    at: top
    label: AD3 (Scope)
    pins: [1+, 2+, 1-, 2-]
  ADP:
    type: device
    at: bottom
    label: AD3 (Patterns)
    pins: [GND, DIO0, DIO1, DIO2]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - MTR.W -- a4 purple
  - MTR.V -- a7 brown
  - MTR.U -- a10 orange
  - MTR.COM -- +t12 red
  - a21 -- +t21 red
  - j21 -- -b21 black
  - -t29 -- -b29 black
  - ADS.1+ -- a14 blue
  - ADS.2+ -- a15 green
  - ADS.1- -- -t24 black
  - ADS.2- -- -t26 black
  - ADP.DIO0 -- j14 yellow
  - ADP.DIO1 -- j15 yellow
  - ADP.DIO2 -- j16 yellow
  - ADP.GND -- -b11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/09-bldc-3phase.svg)

- U1 は 14〜21 列に挿す。下の段の f14〜f16 が入力の 1〜3 番、f21 が 8 番 (GND)。上の段は右から 9 番 (e21、COM)・…・14 番 (e16)・15 番 (e15)・16 番 (e14)
- R1〜R3 は出力の 14・15・16 列から左の 10・7・4 列へ渡す (b・c・d 行で段をずらして重ならないようにした)。モータの U・V・W の線は 10・7・4 列 (`a10`・`a7`・`a4`) に挿す。
  モータはブレッドボードに挿さず、線でつなぐ
- モータの COM (赤) と U1 の 9 番 (21 列、`a21`) を上の + レールへ。8 番 (`j21`) を下の − レールへ。上下の − レールは 29 列でつなぐ
- AD3 の Patterns の DIO0〜DIO2 (黄) を入力の 14〜16 列 (`j14`〜`j16`) へ、GND を下の − レールへ。Scope の 1+ (青) は U 相の出力 (14 列、`a14`)、2+ (緑) は V 相 (15 列、`a15`)
- 電源は別の 5 V (USB アダプタなど)。同時に ON になるのは 2 相までで、5 V の線 (+ レールと COM の線) を通る電流は最大 約 170 mA。
  AD3 の Supplies の 50 mA を超えるので使わない。1 穴 200 mA・ブレッドボード全体 500 mA の内側

## 計器の設定

計器は Analog Discovery 3 の Patterns (3 相の信号) と Scope (U・V 相の出力の電圧)。120° のずれは時間の波形で見る。
Patterns は DIO0〜DIO2 を Clock にし、3 本とも Frequency 2 Hz・Duty 50 %、Phase を 0°・120°・240° にする。
Scope は 1+ を U 相、2+ を V 相にして、2 ch とも 1 V/div、50 ms/div。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 U 相 (CH1) の 1/3 周期 (120°) 後に V 相 (CH2) が ON になる
time: 50ms/div
trigger: ch1 falling 3V at -4div
ch1: {wave: pulse 2Hz 2.05V offset 2.95V duty 50% phase 180deg, range: 1V/div, position: -3div}
ch2: {wave: "ch1 | delay 166.7ms", range: 1V/div, position: -3div}
cursors: [1ms, 167.7ms]
measure: [vmax, vmin, freq, duty, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/09-bldc-3phase.svg)

図3 は理想の形。出力が 0.9 V に下がっている間が、その相の巻線に電流が流れている間 (ON)。OFF の間は巻線を通って 5 V に戻る。
カーソルの X1 は U 相が ON になった直後 (V 相はまだ OFF の 5 V)、X2 は V 相が ON になった直後 (2 相とも 0.9 V) で、ΔX = 166.7 ms は周期 500 ms の 1/3 (120°)。
W 相 (図には無い) はさらに 166.7 ms 遅れる。切った瞬間には出力に 5 V より 0.8 V ほど高い山が出る (内蔵のダイオードの順方向電圧ぶん)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | ダーリントンのシンクドライバ (7 回路、DIP-16) | ULN2003A (3 回路だけ使う) |
| R1〜R3 | 抵抗 (相の電流の制限、1 W) | 47 Ω (ON で 0.34 W、平均 0.17 W) |
| M1 | 3 相のブラシレスモータ (中点の線が出ている 4 本線の品) | 巻線 1 相 数 Ω (計算では 2 Ω と仮定。テスターで測る) |
| — | 電源 | 5 V の USB アダプタなど (2 相 ON で約 170 mA。AD3 の Supplies の 50 mA を超えるため別電源) |
| — | 信号源・計器 | Analog Discovery 3 の Patterns (DIO0〜DIO2、3.3 V、2 Hz、120° ずつ) と Scope (1+ = U 相、2+ = V 相、1−・2− = GND) |

## 見るべき値

表の値は計算値と LTspice の値で、実測ではない。電流は、テスターの電流レンジを U 相の線に直列に入れ、
Patterns を止めて DIO0 だけを H にして測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 相の電流 | 約 84 mA | (5 − 0.9) V ÷ 49 Ω。R1〜R3 で抑えている |
| ON の相の出力電圧 | 約 0.9 V | ULN2003A の飽和電圧 (ダーリントンなので 0 V まで落ちない) |
| ON の相の数 | 1 相と 2 相が 1/6 周期ごとに入れ替わる | デューティ比 50 % の 3 本を 120° ずらすと、6 つの段 (6 ステップ) ができる |
| 5 V の線の電流の最大 | 約 170 mA | 2 相 ON のとき。1 穴 200 mA の内側 |
| U 相と V 相の ON の時刻の差 | 周期の 1/3 (2 Hz なら 166.7 ms) | 120° のずれ。これで磁界が一回りする |
| Patterns の DIO1 と DIO2 を入れ替えたとき | 回る向きが逆になる | 3 相のうち 2 相を入れ替えると、磁界の回る向きが逆になる |
| 周波数を 2 Hz → 5 Hz に上げたとき | 速く回る。上げすぎると回転子が付いてこられず止まる | 位置を読まない (開ループの) 送り方の限界。本物のブラシレスは位置を読んで切り替える |

回転子の回る速さは、電気の 1 周期 (6 ステップ) で磁石の極 1 組ぶん進むので、1 秒の回転数 = 周波数 ÷ 極対数 (磁石の N と S の組の数)。
極対数は品によって違う (4 組の品なら、2 Hz で 0.5 回転/秒)。

## LTspice での確かめ

`sim/09-bldc-3phase.cir` で図1 を回した。巻線は 1 相 2 Ω・1 mH (仮定)、回転による逆起電力は入れていない (止めた状態)。
ULN2003A の 1 回路は 2.7 kΩ とダーリントン、COM へのダイオードの模型 (仮定) で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 相の電流 | 約 84 mA | 85 mA | 合う |
| ON の相の出力電圧 | 約 0.9 V | 0.83 V | 合う (データシートは典型 0.9 V @ 100 mA) |
| 5 V の線の電流の最大 / 平均 | 約 170 mA / — | 170 mA / 128 mA | 合う |
| 切った瞬間の出力の山 | 5 V + 約 0.8 V | 5.83 V | 合う |
| U と V の ON の時刻の差 | 166.7 ms | 166.7 ms | 合う |
| R1 の平均の電力 | 0.17 W | 0.17 W | 合う (1 W 品の半分の内側) |
| 入力 (DIO0) の電流 | — | 0.68 mA | AD3 の DIO で出せる |

## 出典

自作。

参考: [ブラシレスモーター (Wikipedia)](https://ja.wikipedia.org/wiki/ブラシレスモーター)、[Brushless DC electric motor (Wikipedia)](https://en.wikipedia.org/wiki/Brushless_DC_electric_motor)、[TI ULN2003A のデータシート](https://www.ti.com/lit/ds/symlink/uln2003a.pdf)
