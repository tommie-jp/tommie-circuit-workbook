---
book: circuits
chapter: 8
id: 8-7
title: 超音波 (HC-SR04)
tier: 100
source: 自作
board: BB
era: 今
---

# 8-7 超音波 (HC-SR04)

超音波 (人の耳に聞こえない、20 kHz より高い音) のモジュール HC-SR04 で、物までの距離を測る。
超音波を発射して、跳ね返ってくるまでの時間から距離を求める。
TRIG に短いパルスを送ると超音波が出て、発射してから跳ね返りを受けるまでの間、ECHO が H になる。
H の時間の長さが距離に比例するので、時間を測れば距離が分かる。

## 回路図

```circuit
title: 図1 HC-SR04 の ECHO を 3.3V 系に合わせて落とす
parts:
  M1:
    type: device
    at: c3
    label: HC-SR04
    pins: [VCC, TRIG, ECHO, GND]
    turn: mirror
  VCC: vcc b4a5 5V
  TRIG: port b7
  G1: ground d4a5
  R1: resistor d5a5 f5a5 1k
  R2: resistor f5a5 h5a5 1.5k
  ECHO: port f7
  G2: ground h5a5
wires:
  - b4a5 |- M1.VCC
  - b7 |- M1.TRIG
  - M1.GND -| d4a5
  - M1.ECHO -| d5a5
  - f5a5 -- f7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/07-ultrasonic.svg)

- TRIG に 10 µs 以上の H のパルスを送ると、モジュールが自動で 40 kHz の
  超音波を 8 波出す
- ECHO は VCC と同じ 5 V で H になる。マイコンが 3.3 V 系 (Pico 2 など) だと、
  そのままでは入力の絶対最大定格 (超えると壊れる上限) を超えることがある。そこで R1・R2 の分圧 (1-2 で見た) で
  3.0 V に落としてから、GPIO (図1 の右の ECHO の端子) に入れる。R2 / (R1 + R2) ×
  5 V = 1.5 kΩ / 2.5 kΩ × 5 V = 3.0 V
- ECHO が H の時間 t から、距離 d は d [cm] ≈ t [µs] / 58 で求まる。
  音は往復するので、1 cm 進んで戻るのに 2 × 0.01 m ÷ 343 m/s ≈ 58 µs かかる (音速 約 343 m/s)

## 実体配線図

```breadboard
title: 図2 HC-SR04 と分圧を組む (W1 が TRIG、1+ が分圧後の ECHO)
board: half
parts:
  M1:
    type: device
    at: top
    label: HC-SR04 (超音波モジュール)
    pins: [VCC, TRIG, ECHO, GND]
  R1: resistor b10 b14 1k
  R2: resistor d14 d18 1.5k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (Supplies・W1・Scope)
    pins: [V+, GND, W1, 1+, 1-]
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - +b30 -- +t30 red
  - -b29 -- -t29 black
  - M1.VCC -- +t4 red
  - M1.GND -- -t22 black
  - M1.TRIG -- a6 green
  - M1.ECHO -- a10 yellow
  - AD.W1 -- c6 green
  - AD.1+ -- e14 blue
  - AD.1- -- -b17 black
  - b18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/07-ultrasonic.svg)

- 5 V の電源は Analog Discovery 3 (AD3) の Supplies の V+ (WaveForms で 5 V にして出力を入れる)。V+ を下の + レール、GND を下の − レールへつなぎ、右端の 2 本で上のレールへ渡す。HC-SR04 は板に挿さず、VCC を上の + レール、GND を上の − レールへ線でつなぐ
- TRIG (緑) は 6 列へ。AD3 の W1 (緑) も同じ 6 列に入れ、TRIG へパルスを送る。W1 は 30 mA まで出せ、TRIG の入力に要る電流はごく小さい
- ECHO (黄) は 10 列へ。R1 (10→14 列) と R2 (14→18 列) が分圧で、14 列が図1 の右の ECHO の端子に当たる。R2 の右端 (18 列) は黒の線で − レールへ。1+ (青) は 14 列に挿して、分圧後の ECHO を見る。1− は − レールへ
- 電流は、HC-SR04 が動作時に約 15 mA (データシートの目安) で、分圧に流れるのは 5 V ÷ 2.5 kΩ = 2 mA。合計しても AD3 の Supplies の 50 mA (USB 給電で 250 mW) と、板の 500 mA の内側に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 超音波距離センサー (HC-SR04) | 測定範囲 約 2〜400 cm、ECHO は VCC (5 V) レベル |
| R1 | 抵抗 | 1 kΩ |
| R2 | 抵抗 | 1.5 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+。モジュール約 15 mA と分圧 2 mA) |
| — | 計器・TRIG の信号源 | Analog Discovery 3 の W1 (TRIG)・Scope (1+ = 分圧後の ECHO、1− = GND) |

## 計器の設定

計器は Analog Discovery 3 の Supplies (V+ = 5 V)、W1 (TRIG のパルス)、Scope。ECHO の H の幅は数 ms で、時間の波形でしか読めないので、オシロで見る。
W1 は Simple の Pulse、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)、幅 10 µs 以上、周期 60 ms 以上。Scope は 1+ を分圧後の ECHO (14 列)、1− を GND に当て、Time base 1 ms/div、Range 1 V/div、トリガは 1+ の立ち上がり 1.5 V にする。

```scope
title: 図3 分圧後の ECHO の H の幅 (物までの距離が 100 cm のとき)
time: 1ms/div
trigger: ch1 rising 1.5V at -2div
ch1: {wave: "= 3.0V * step(t) * step(5.83ms - t)", range: 1V/div, position: -3div}
measure: [vmax, vmin]
notes:
  - band 0 5.83ms: H の幅 5.83 ms
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/07-ultrasonic.svg)

図3 は理想の形で、距離 100 cm の跳ね返りを 1 回だけ描いた。H の電圧は分圧後の 3.0 V、幅は t = 2 × 1 m ÷ 343 m/s ≈ 5.83 ms (下の表の 100 cm の行) である。
塗った帯の幅を読むと距離が分かる (5.83 ms ÷ 58 µs/cm ≈ 100 cm)。距離を変えると帯の幅が比例して変わる。

## 見るべき値

表の値は計算値。音速 343 m/s (気温 20 °C の目安) として t = 2d / 343 で計算し、
t / 58 の式と比べた。

測り方: TRIG には Analog Discovery の W1 (Pulse、5 V・幅 10 µs 以上・周期 60 ms 以上) かマイコンからパルスを送り、
分圧後の ECHO をオシロ (1+ を ECHO、1− を GND) で見て、H の時間を読む (図3)。

| 距離 | ECHO が H の時間 (計算値) | t / 58 の式との比較 |
| --- | --- | --- |
| 10 cm | 583 µs | 10 × 58 = 580 µs (ほぼ一致) |
| 50 cm | 2.92 ms | 50 × 58 = 2900 µs (ほぼ一致) |
| 100 cm | 5.83 ms | 100 × 58 = 5800 µs (ほぼ一致) |
| 400 cm (測定上限の目安) | 23.3 ms | この付近から反射が弱く測れないことがある |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 分圧後の ECHO 電圧 (H のとき) | 3.0 V (= 5 V × 1.5k / 2.5k) | 3.3 V 系ロジックの絶対最大定格内に収まる |
| TRIG のパルス幅を 5 µs にしたとき | 動かないことがある | データシート上の最小 10 µs を満たしていない |
| 何も無い方向へ向けたとき | ECHO はずっと H のままにはならず、一定時間 (品による。約 38 ms が目安) で L に戻る | モジュールの中に、待ちを打ち切る仕組み (タイムアウト) がある |

## 出典

自作。
