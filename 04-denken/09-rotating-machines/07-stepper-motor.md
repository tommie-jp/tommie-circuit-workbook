---
book: denken
chapter: 9
id: 9-7
title: ステッピングモータ — パルスの数と回転角
tier: 100
source: 自作
board: BB
---

# 9-7 ステッピングモータ — パルスの数と回転角

ステッピングモータは、巻線に流す電流をパルスで 1 段ずつ切り替え、**1 パルスごとに決まった角度だけ回る**。
回した角度はパルスの数、速さはパルスの周波数で決まり、回転子の位置を測らなくてよい (開ループ)。
定番の 28BYJ-48 (5 V、ユニポーラ、減速ギア付き) を ULN2003 の基板で駆動し、AD の Patterns で数を決めたパルスを送って確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| θ = n × θs | 回転角はパルス (ステップ) の数 n に比例する。θs はステップ角 |
| θs = 360° / (32 × 64) = 0.176° | 28BYJ-48 の 2 相励磁: モータ 1 回転 32 ステップ、ギアで 1/64 |
| N = 60 × fs / 2048 [rpm] | 回転数はステップの周波数 fs に比例する |

2 相励磁は、4 つの巻線 (A・B・C・D) のうち隣り合う 2 つを AB → BC → CD → DA の順に流す。
各巻線は 4 ステップのうち 2 ステップだけ流れるので、各入力は fs / 4 の方形波 (デューティ比 50 %) を 90° ずつずらしたものになる。

## 回路図

```circuit
title: 図1 4 本のパルスを ULN2003 の基板に入れてステッピングモータを回す
style:
  standard: jis
  pitch: 1.2
parts:
  A1:
    type: device
    at: b1c0c0
    label: AD Patterns
    pins: [DIO0, DIO1, DIO2, DIO3, GND]
    turn: mirror
  U1:
    type: device
    at: b8
    label: ULN2003 + 28BYJ-48
    pins: [V+, IN1, IN2, IN3, IN4, GND]
  P1: vcc a6
  G1: ground d3
wires:
  - A1.DIO0 -- U1.IN1
  - A1.DIO1 -- U1.IN2
  - A1.DIO2 -- U1.IN3
  - A1.DIO3 -- U1.IN4
  - A1.GND -- U1.GND
  - A1.GND -| d3
  - U1.V+ -| a6
notes:
  - text a4 small: 5 V (USB)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/07-stepper-motor.svg)

- A1 は AD の Patterns (3.3 V)。DIO0〜DIO3 を ULN2003 の基板の IN1〜IN4 へ
- U1 は ULN2003 (7 回路のダーリントン、TI) を載せた基板に 28BYJ-48 を挿したもの。モータの 5 本の線は基板のコネクタに挿すので、
  図では 1 つの箱にした。入力が H の回路は、その巻線の一端を GND に引く (巻線のもう一端は赤い線で V+ に共通)。
  入力は 2.7 kΩ を通してダーリントンのベースへ入るので、AD の 3.3 V で足りる
- V+ は USB の 5 V。巻線は 1 相 約 50 Ω (5 V の型、データシートの値) で、2 相を同時に流すと 0.16 A ほど。AD の Supplies では足りない
- 計器は図に描かない。CH1 を IN1、CH2 を IN2 (どちらも GND 基準) に当てる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (板は配線の中継)
# 上の赤レール = 5 V (USB)、青レール = GND
board: half
parts:
  USB:
    type: device
    at: top
    label: USB 5V
    pins: ["+5V", GND]
  ULN:
    type: device
    at: top
    label: ULN2003 基板
    pins: [IN1, IN2, IN3, IN4, "-", "+"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [DIO0, 1+, DIO1, 2+, DIO2, DIO3, GND, 1-, 2-]
wires:
  - USB.+5V -- +t2 red
  - USB.GND -- -t3 black
  - ULN.IN1 -- a10 yellow
  - ULN.IN2 -- a12 green
  - ULN.IN3 -- a14 blue
  - ULN.IN4 -- a16 purple
  - ULN.- -- -t20 black
  - ULN.+ -- +t22 red
  - e10 -- f10 yellow
  - e12 -- f12 green
  - e14 -- f14 blue
  - e16 -- f16 purple
  - AD.DIO0 -- j10 yellow
  - AD.DIO1 -- j12 green
  - AD.DIO2 -- j14 blue
  - AD.DIO3 -- j16 purple
  - -t29 -- -b29 black
  - AD.GND -- -b18 black
  - AD.1+ -- i10 orange
  - AD.1- -- -b20 black
  - AD.2+ -- i12 white
  - AD.2- -- -b22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/07-stepper-motor.svg)

- 板には部品を挿さず、線の中継と電源の分配に使う。10・12・14・16 列が IN1〜IN4 (上のブロックで基板へ、溝を渡って下のブロックで AD へ)
- 基板の + を赤レール (5 V)、− を青レール。上下の青レールは 29 列でつなぎ、AD の GND も同じ GND にする
- CH1 (1+) は i10 (IN1)、CH2 (2+) は i12 (IN2)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Patterns | DIO0〜DIO3: Clock、Frequency 50 Hz (fs = 200 ステップ/s)、Duty 50 %、Phase 0°・90°・180°・270° |
| Patterns の Run | 10.24 s (= 2048 ステップ ÷ 200 Hz) で 1 回転。2.56 s (512 ステップ) なら 90°。Repeat 1 |
| Scope | CH1 = IN1、CH2 = IN2。1 V/div、Time base 5 ms/div |
| Measure | CH1 の Frequency、CH1 に対する CH2 の Phase |

軸に紙の針を付け、Run の時間だけ回して止まった角度を分度器で読む。Phase の向きで回る向きが逆になるが、角度は変わらない。

```scope
title: 図3 fs 200 Hz — 各入力は 50 Hz、IN2 (CH2) は IN1 (CH1) より 90° 遅れる
time: 5ms/div
trigger: ch1 rising 1.65V
ch1: {wave: square 50Hz 1.65V offset 1.65V, range: 1V/div, position: 0.3div}
ch2: {wave: square 50Hz 1.65V offset 1.65V phase -90deg, range: 1V/div, position: -3.8div}
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/scope/07-stepper-motor.svg)

### オシロスコープと発振器

GND 基準の題で、測る所は図1 のまま ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 の先端を i10、CH2 の先端を i12、グランドクリップは青レール。

- 要るのは **90° ずつずれた 4 本の方形波** と、決まった数だけ出して止める働き。2 ch の発振器では作れない。
  マイコン (回路の本の 7-4・11 章の Raspberry Pi Pico) で 4 本を出すのが簡単。発振器の Burst (N サイクル) の機能で
  fs のパルスを数だけ出し、74HC194 などで 4 相に分ける方法もある
- 電源は安定化電源の 5 V、電流制限 0.3 A

## 見るべき値

計算値 (2 相励磁、ギア 1/64 とした)。

| パルス (ステップ) の数 | Run (fs = 200 Hz) | 回転角 |
| --- | --- | --- |
| 512 | 2.56 s | 90° |
| 1024 | 5.12 s | 180° |
| 2048 | 10.24 s | 360° |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Frequency | 50.00 Hz | fs / 4 |
| CH2 の Phase | −90° | 1 ステップ分のずれ |
| 回転数 (fs = 200 Hz) | 5.86 rpm (1 回転 10.24 s) | fs に比例。fs を 2 倍にすると 2 倍 |

- **角度はパルスの数だけで決まり、周波数を変えても同じ数なら同じ角度で止まる**
- 28BYJ-48 のギアは正しくは 1/63.68 なので、2048 ステップで 361.8° と、1 回転で約 1.8° 進みすぎる。何回も回すと積もる
- fs を上げすぎる (目安 500 Hz 以上) と、回転子が付いて行けずに脱調し、パルスの数と角度が合わなくなる (9-6 の同期はずれと同じ)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Patterns・Scope の節)。
