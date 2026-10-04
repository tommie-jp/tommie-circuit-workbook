---
book: circuits
chapter: 7
id: 7-5
title: サーボ — パルス幅で角度
tier: 100
source: 自作
era: 今
---

# 7-5 サーボ — パルス幅で角度

サーボモータは、軸の角度そのものをパルスの幅で指示する部品。中に DC モータ・減速ギア・角度を測るセンサー・
制御回路が入っていて、指示された角度まで自分で回って止まる。ラジコンの舵やロボットの関節に使われる。
周期 20 ms ごとに 1 本のパルスを送り、その H の時間 (パルス幅) が短ければ 0° 側、長ければ 180° 側に軸が回る。
7-4 のステッピングモータでは、送ったステップの数から角度を数えておく必要があった。サーボでは
その必要が無く、同じパルス幅を送り続けるだけで、その角度を保ち続ける。

## 回路図

```circuit
title: 図1 サーボにパルス幅で角度を指示する
parts:
  M1:
    type: device
    at: c5
    label: SG90
    pins: [VCC, SIG, GND]
  VCC: vcc b4 5V
  G1: ground d4
  PWM: square d2 f2 5 l=$\mathrm{PWM}$
  G2: ground f2
wires:
  - b4 |- M1.VCC
  - M1.GND -| d4
  - d2 |- M1.SIG
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/05-servo-pulse-angle.svg)

- M1 (SG90 マイクロサーボ) は VCC・SIG・GND の 3 本の線を持つ。VCC は 5 V (USB や
  電池)、SIG (信号) は 3.3 V・5 V どちらのロジックのパルスでもよい
- PWM は、周期 20 ms (50 Hz) の方形波を表す。パルス幅が 1.0 ms で 0°、
  1.5 ms で 90° (中央)、2.0 ms で 180° というのが、広く使われている目安の対応
  (品によって 0.5〜2.5 ms まで対応するものもある)
- SG90 のような小型サーボでも、マイコンの GPIO から電源の電流は取れない
  (無負荷でも 100 mA 級、動き出しは 600 mA を超えることがある)。SIG だけを
  GPIO につなぎ、VCC は別の 5 V 電源からとる。GND はマイコンと共通にする。
  共通の GND が無いと、パルスの電圧の基準がサーボ側とずれて、パルスが正しく届かない

## 実体配線図

この題の板に載る部品は無い。SG90 は 3 本の線 (茶 = GND、赤 = VCC、橙 = SIG) の付いたモジュールで、組むのは配線だけだ。
ただしサーボの電流は無負荷で約 100 mA、動き出しは 600 mA を超えることがあり、ブレッドボードの 1 穴 200 mA・板全体 500 mA の上限を超える。
そこで、**サーボの電源 (赤と茶) は板を通さず、別の 5 V 電源から直接つなぐ**。板を通るのは信号 (SIG) と、基準の GND だけにする。

```breadboard
title: 図2 サーボの電源は板を通さず、信号と GND だけを板でつなぐ
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源 5V (1A 以上)
    pins: ["-", "+"]
  MTR:
    type: device
    at: top
    label: サーボ SG90
    pins: [GND, VCC, SIG]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Wavegen と Scope)
    pins: [W1, 1+, 1-, GND]
wires:
  - PSU.+ -- MTR.VCC red
  - PSU.- -- MTR.GND black
  - PSU.- -- -t2 black
  - AD.W1 -- a8 yellow
  - MTR.SIG -- b8 orange
  - AD.1+ -- c8 blue
  - AD.1- -- -t10 black
  - AD.GND -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/05-servo-pulse-angle.svg)

- 5 V の電源は別の電源 (USB アダプタなど。1 A 以上流せるもの)。サーボの赤 (VCC) を + へ、茶 (GND) を − へ、板を通さずに直接つなぐ
- 板に入る線は、AD3 の W1 (黄、PWM の信号源) を 8 列の `a8` へ、サーボの橙 (SIG) を同じ 8 列の `b8` へ、Scope の 1+ (青) を `c8` へ。この 3 本が同じ 5 穴の組なので、W1 の信号がそのままサーボと Scope に届く
- 電源の − と AD3 の GND (1−・GND を含む) は、上の − レールで共通にする。これが「GND はマイコンと共通にする」の実物。板を通る電流は SIG の数 mA だけで、板の上限の内側
- AD3 の Supplies は各 50 mA までなので、サーボには使えない。W1 は 3.3 V のパルス (Amplitude 1.65 V、Offset 1.65 V) を出し、SG90 の SIG (3.3 V でも 5 V でもよい) に直結する

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | マイクロサーボ (SG90、180° 級) | 動作電圧 4.8〜6 V、無負荷電流 約 100 mA、動作時 最大 600 mA 級 |
| — | 電源 | 5 V (USB や電池、GPIO とは別に取る) |
| PWM | パルス発生器 (マイコンの GPIO でも可) | 周期 20 ms、パルス幅 1.0〜2.0 ms。AD3 の W1 (Square、50 Hz、振幅 0〜3.3 V、Symmetry 7.5 % で 1.5 ms) |
| — | 計器 | Analog Discovery 3 の Scope (1+ = SIG、1−・GND = GND)。電源は AD3 の Supplies でなく別の 5 V (サーボは動き出しに 600 mA) |

## 計器の設定

計器は Analog Discovery 3 の W1 (PWM の信号源) と Scope。パルスの幅は時間の波形で見るので、テスターでは足りない。
W1 は Simple の Square、Frequency 50 Hz (周期 20 ms)、Amplitude 1.65 V、Offset 1.65 V (0〜3.3 V)、Symmetry 7.5 % (パルス幅 1.5 ms)。
Scope は 1+ を SIG、1 ch を 500 mV/div、500 µs/div にして、1 回のパルスの幅を見る。

```scope
title: 図3 パルス幅 1.5 ms (90°、中央) をカーソルで読む
time: 500us/div
trigger: ch1 rising 1.65V
ch1: {wave: pulse 50Hz 1.65V offset 1.65V duty 7.5%, range: 500mV/div, position: -3div}
cursors: [0, 1.5ms]
measure: [vmax, vmin, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/05-servo-pulse-angle.svg)

図3 は理想の形。SIG は 3.3 V のパルスで、立ち上がり (0) から立ち下がり (1.5 ms) までがパルス幅。カーソルは立ち上がり (X1 = 0) と立ち下がり (X2 = 1.5 ms) の縁に置いたので、縁の途中の電圧は読まず、ΔX = 1.500 ms だけを読む。ΔX が 1.5 ms なら、サーボは 90° (中央) を指す。
Symmetry を 5 % にすると幅は 1.0 ms (0°)、10 % にすると 2.0 ms (180°)。窓 (5 ms) は周期 20 ms より短いので、次のパルスは見えない。

## 見るべき値

表の値は計算値か、データシートの代表値。パルス幅 t [ms] と角度 θ [°] の関係は、
1.0 ms を 0°、2.0 ms を 180° とする直線の近似で θ ≈ (t − 1.0) × 180 とした。
デューティ比 (7-2 で見た) は、パルス幅 ÷ 周期 20 ms。
送っているパルス幅は、Analog Discovery のオシロ (1+ を SIG、1− を GND) で確かめる。

| パルス幅 | 角度 (計算値) | デューティ比 (周期 20 ms) |
| --- | --- | --- |
| 1.0 ms | 0° | 5.0% |
| 1.5 ms | 90° (中央) | 7.5% |
| 2.0 ms | 180° | 10.0% |
| 周期を 20 ms からずらしたとき | 角度は変わらない (目安) | サーボはパルス幅だけを見るので、周期が多少ずれても大きな影響は無い |
| パルスを止めたとき | 軸が抜けて自由に回るようになる (品による) | 一定間隔でパルスを送り続けないと角度を保持しない |

## 出典

自作。
