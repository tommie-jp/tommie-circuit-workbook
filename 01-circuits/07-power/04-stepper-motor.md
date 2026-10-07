---
book: circuits
chapter: 7
id: 7-4
title: ステッピングモータ (ULN2003)
tier: 100
board: BB
source: 自作
---

# 7-4 ステッピングモータ (ULN2003)

7-2 の DC モータは電圧をかけっぱなしで回るが、ステッピングモータは、中の複数のコイルに
順番に電流を流すことで、決まった角度ずつ回る。角度をパルスの数で決められるので、
向きも角度もマイコンからそのまま制御できる。プリンタやカメラの雲台など、決まった位置に止めたい所で使う。
定番の 28BYJ-48 (5 V) を、専用の ULN2003 ドライバ基板で駆動する。

## 回路図

```circuit
title: 図1 ULN2003 ボードでステッピングモータを駆動する
points:
  in1x: 2,3.16
  in2x: 2,3.4
  in3x: 2,3.64
  in4x: 2,3.88
  com9: 7,4.84
parts:
  U1: dip16 5,4 ULN2003A
  IN1: port in1x
  IN2: port in2x
  IN3: port in3x
  IN4: port in4x
  M1:
    type: device
    at: 9,3.4
    label: 28BYJ-48
    pins: [D, C, B, A, COM]
  G1: ground 4,6
  VCC: vcc com9 5V
  VCC: vcc 8,2 5V
wires:
  - in1x -- U1.1
  - in2x -- U1.2
  - in3x -- U1.3
  - in4x -- U1.4
  - U1.16 -- M1.A
  - U1.15 -- M1.B
  - U1.14 -- M1.C
  - U1.13 -- M1.D
  - U1.8 -| 4,6
  - U1.9 -- com9
  - 8,2 |- M1.COM
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/04-stepper-motor.svg)

- ULN2003 は、ダーリントン接続 (2-4 で見た、トランジスタ 2 個の組) のスイッチを 7 回路入れた IC で、
  そのうち 4 回路をこのモジュールが使う。各入力には直列抵抗 (約 2.7 kΩ) が内蔵されているので、
  外付けの抵抗なしで、マイコンの GPIO (3.3 V でも 5 V でも) に直結できる
- 図1 はボードの中身を、ULN2003A のピンの番号で描いた。左の 1〜4 番が入力 IN1〜IN4、右の 16〜13 番が出力
  OUT1〜OUT4 (16 番が OUT1)、8 番が GND、9 番が COM。5〜7 番と 10〜12 番は、このボードでは使わない 3 回路
- 各コイルは、一端を +5 V に、もう一端を OUT1〜OUT4 につなぐ。M1 の COM がコイルの共通の端だ。
  ULN2003 の COM (9 番) は内蔵のフライバックダイオードの共通端子で、ボードの中で +5 V (V+) に配線済み。
  コイルを OFF にした瞬間の逆起電力 (6-2・7-1 と同じ理屈) を、外付けの部品なしで吸収してくれる
- IN1〜IN4 を 1 回に 1 本だけ H にして、A→B→C→D→A… の順で送ると、
  モータは一定の角度ずつ回る (下の表)。逆順に送れば逆回転する

## 実体配線図

28BYJ-48 に付いてくる ULN2003 ドライバボードの代わりに、ULN2003A の IC そのもの (DIP-16) をブレッドボードに挿して、同じ回路を組む。
モータはブレッドボードに挿さず、線 (COM と A〜D の 5 本) でつなぐ。

```breadboard
title: 図2 ULN2003A とステッピングモータを組む
board: half
parts:
  U1: dip16 @ e5 ULN2003A
  PSU:
    type: device
    at: top
    label: 電源 5V (別電源)
    pins: ["+", "-"]
  MTR:
    type: device
    at: top
    label: ステッピングモータ 28BYJ-48
    pins: [COM, A, B, C, D]
  ADP:
    type: device
    at: bottom
    label: AD3 (Patterns)
    pins: [DIO0, DIO1, DIO2, DIO3, GND]
  ADS:
    type: device
    at: bottom
    label: AD3 (Scope)
    pins: [1+, 2+, 1-, 2-, GND]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - +t3 -- +b3 red
  - -t20 -- -b20 black
  - MTR.COM -- +t14 red
  - MTR.A -- a5 orange
  - MTR.B -- a6 orange
  - MTR.C -- a7 orange
  - MTR.D -- a8 orange
  - a12 -- +t12 red
  - j12 -- -b12 black
  - ADP.DIO0 -- j5 yellow
  - ADP.DIO1 -- j6 yellow
  - ADP.DIO2 -- j7 yellow
  - ADP.DIO3 -- j8 yellow
  - ADP.GND -- -b13 black
  - ADS.1+ -- h5 blue
  - ADS.2+ -- h6 green
  - ADS.1- -- -b16 black
  - ADS.2- -- -b17 black
  - ADS.GND -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/04-stepper-motor.svg)

- 上のレールの左上に別電源の 5 V (赤が +、黒が −) を入れる。U1 の 9 番 (COM、12 列の上段) と、モータの COM (赤線、14 列の + レール) を + に、
  8 番 (GND、12 列の下段) を下の − レールへつなぐ。上下の + レール (3 列) と − レール (20 列) は、それぞれ線でつなぐ (レールは上下でつながっていない)
- モータはブレッドボードに挿さず、A・B・C・D の 4 本 (橙) を U1 の出力 (16〜13 番 = 5〜8 列の上段) へ、COM を + レールへ線でつなぐ
- U1 の入力 (1〜4 番 = 5〜8 列の下段、`j` 行) へ、AD3 の Patterns の DIO0〜DIO3 (黄) を入れる。AD3 の DIO は 3.3 V のロジック出力で、U1 の入力は 2.7 kΩ が内蔵されているので、抵抗なしで直結できる
  (入力に流れる電流は 1 mA 以下の目安。実測ではない)。GND (黒) は下の − レールへ
- Scope の 1+ (青) は 5 列の IN1、2+ (緑) は 6 列の IN2 を見る (`h5`・`h6`)。1−・2−・GND (黒) は下の − レールへ。AD3 の GND は 5 V の電源の − と、ブレッドボードの − レールで共通になる
- 電源は別の 5 V (USB アダプタなど) にする。1 相 ON で約 80 mA、2 相励磁で約 160 mA が流れ、AD3 の Supplies の各 50 mA (USB 給電で 250 mW) を超えるため。
  ブレッドボードの中は、COM の線と U1 の 9 番・8 番の穴を通る電流が最大約 160 mA (2 相励磁) で、1 穴 200 mA・ブレッドボード全体 500 mA の内側

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | ステッピングモータ (28BYJ-48、5 V ユニポーラ。コイルの共通の端を電源につなぎ、電流を一方向にだけ流す型) | 1 相 (コイル 1 組) あたり巻線抵抗 約 50 Ω (5 V 版。12 V 版は約 200 Ω) |
| U1 | ULN2003 ドライバボード | 4 回路ともダーリントン、フライバックダイオード内蔵 |
| — | 電源 | 5 V (USB アダプタなど。1 相で約 80 mA、2 相励磁で約 160 mA。AD3 の Supplies の 50 mA を超えるので別電源) |
| — | 信号源・計器 | Analog Discovery 3 の Patterns (DIO0〜DIO3 = IN1〜IN4、3.3 V) と Scope (1+ = IN1、2+ = IN2、1−・2− = GND) |
| U1 (ブレッドボードに組むとき) | ULN2003A (DIP-16、ボードの代わり) | 1 回路あたり 500 mA |
| IN1〜IN4 | マイコンの GPIO (11 章参照) | 3.3 V/5 V ロジック |

## 計器の設定

計器は Analog Discovery 3 の Patterns (IN1〜IN4 に送るパルス) と Scope (IN1・IN2 の波形)。順に H にする様子は時間の波形で見る。
Patterns は DIO0〜DIO3 を Custom の 4 本のパルス (1 本ずつ順に H) にして、ステップの間隔を 10 ms (100 Hz) にする。
Scope は 1+ を IN1、2+ を IN2 にして、2 ch とも 500 mV/div、10 ms/div。

```scope
title: 図3 IN1 の次に IN2 が H になる — 1 ステップ 10 ms (100 Hz)
time: 10ms/div
trigger: ch1 rising 1.65V
ch1: {wave: pulse 25Hz 1.65V offset 1.65V duty 25%, range: 500mV/div, position: -3div}
ch2: {wave: "ch1 | delay 10ms", range: 500mV/div, position: -3div}
cursors: [5ms, 15ms]
measure: [vmax, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/04-stepper-motor.svg)

図3 は理想の形。IN1 は 40 ms の周期で 10 ms だけ H (3.3 V) になり、IN2 はそれより 10 ms 遅れて 10 ms だけ H になる。
カーソルの 5 ms は IN1 だけが H の真ん中、15 ms は IN2 だけが H の真ん中で、2 つの間 ΔX = 10 ms が 1 ステップの時間 (1/ΔX = 100 Hz)。
H の間はその相の ULN2003 が ON になり、出力 (OUT1・OUT2) が約 0.9 V に下がってコイルに電流が流れる。IN3・IN4 も同じ形で 10 ms ずつ遅れる。

## 見るべき値

表の値は計算値。28BYJ-48 は、内部のモータが 1 回転 32 ステップ (フルステップ) で、減速比 1/64 の
ギアを介して出力軸に伝わる (データシートの代表値。品によりわずかに違う)。
電流は、テスターの電流 (mA) レンジを 5 V の電源とモジュールの V+ の間に直列に入れて測る。
ステップを止めて 1 相だけ ON にしておくと読みやすい。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 相あたりの電流 | 約 80 mA (= (5 V − 0.9 V) ÷ 50 Ω。0.9 V は ON のときの ULN2003 の電圧降下) | ULN2003 の 1 回路あたりの定格 (500 mA) に対して十分小さい。コイル 1 相で約 0.34 W (= 0.082² × 50) を消費し、触ると温かくなる |
| 出力軸 1 回転に要るステップ数 (フルステップ、1 相ずつ) | 2048 ステップ (= 32 × 64) | 内部の 1 ステップ 11.25° (= 360° / 32) が、ギアで 1/64 になる |
| 1 ステップの角度 (出力軸) | 約 0.176° (= 360° / 2048) | かなり細かい角度まで止められる |
| ステップ周波数 100 Hz のときの回転速度 | 約 2.93 rpm (= 100 / 2048 × 60) | 遅いがトルクは大きい (ギアで減速しているため) |

駆動順 (1 相励磁、ウェーブ駆動) は次のとおり。1 回に 1 本だけ H にする。

| ステップ | IN1 (A) | IN2 (B) | IN3 (C) | IN4 (D) |
| --- | --- | --- | --- | --- |
| 1 | H | L | L | L |
| 2 | L | H | L | L |
| 3 | L | L | H | L |
| 4 | L | L | L | H |

2 相励磁 (2 本を同時に H) にすると、トルク (回す力) は増えるが、電流も 2 相ぶんになる
(2 × 約 80 mA = 約 160 mA。ULN2003 の定格には余裕があるが、USB の 500 mA の枠の 3 分の 1 を使う)。

## 出典

自作。
