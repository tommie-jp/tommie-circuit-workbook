---
book: denken
chapter: 9
id: 9-6
title: 同期速度 — BLDC を三相で回して N = 120 f / p
tier: 100
source: 自作
board: BB
---

# 9-6 同期速度 — BLDC を三相で回して N = 120 f / p

三相の電流を巻線に流すと、磁界が周波数 f で回る (回転磁界、4-1)。磁石の回転子はこの磁界にぴったり付いて回り、
その速さ**同期速度** N = 120 f / p は周波数 f と極数 p だけで決まる。電圧や負荷を少し変えても速さは変わらない。
ここでは、磁石の回転子を持つブラシレスモータ (BLDC) を、AD のディジタル出力で作った三相の方形波で回して確かめる。
回転子の位置を見ずに決まった周波数で回すので、同期モータ (同期電動機) と同じ動き方になる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| N = 120 f / p [rpm] | 同期速度。f は電源の周波数、p は極数 |
| 1 周期で 2 / p 回転 | 磁界が 1 周期で 1 回りするのは 2 極のとき。p 極なら 2 / p 回転 |
| 3 相は 120° ずつずれる | U・V・W の順が回る向きを決める。2 つを入れ替えると逆に回る |

この題のモータはジンバル用の小型 BLDC (2804 サイズ、**14 極**、相間の抵抗 約 10 Ω)。
f = 7 Hz なら N = 120 × 7 / 14 = 60 rpm (1 秒に 1 回転) で、目で数えられる速さになる。

## 回路図

```circuit
title: 図1 3 本の方形波を L293D で強めて BLDC を回す
style:
  standard: jis
  pitch: 1.2
parts:
  A1:
    type: device
    at: b1
    label: AD Patterns
    pins: [DIO0, DIO1, DIO2, GND]
    turn: mirror
  U1A: buffer c7
  U1B: buffer e7
  U1C: buffer g7
  M1:
    type: device
    at: b13
    label: BLDC 14P
    pins: [U, V, W]
  G1: ground c2f5
wires:
  - A1.DIO0 -| c5
  - c5 -- U1A.in
  - A1.DIO1 -| e4
  - e4 -- U1B.in
  - A1.DIO2 -| g3
  - g3 -- U1C.in
  - A1.GND -| c2f5
  - U1A.out -- c9
  - c9 |- M1.U
  - U1B.out -- e10
  - e10 |- M1.V
  - U1C.out -- g11
  - g11 |- M1.W
notes:
  - text c6h5 small: L293D 2 番から 3 番
  - text e6h5 small: L293D 7 番から 6 番
  - text g6h5 small: L293D 10 番から 11 番
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/06-synchronous-speed.svg)

- A1 は AD の Patterns (ディジタル出力、3.3 V)。DIO0・DIO1・DIO2 に、周波数 f・デューティ比 50 % の方形波を 120° ずつずらして出す
- U1A〜U1C は L293D (4 回路入りのハーフブリッジ、TI) の 3 回路。入力が H なら出力を電源 (5 V) へ、L なら GND へつなぐ。
  AD の 3.3 V は L293D の入力の H (2.3 V 以上) に足りる。出力の保護ダイオードは中に入っている
- L293D の電源と許可の足は図に描かない: 16 番 (VCC1、論理) と 8 番 (VCC2、モータ) を 5 V、1 番 (1,2EN) と 9 番 (3,4EN) を 5 V、
  4・5・12・13 番を GND。電源は USB の 5 V (1 A 以上のもの)。モータの電流は 0.4 A ほどになり、AD の Supplies では足りない
- M1 は BLDC の 3 本の線 (U・V・W)。中の 3 つの巻線は星形 (Y) につながっている
- 各相の電圧は方形波 (0 V と 5 V) で、2 相が 5 V・1 相が 0 V か、その逆のどちらか。1 周期に 6 回切り替わる (6 ステップ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上下の赤レール = 5 V (USB)、青レール = GND。上下は 29・30 列でつなぐ
board: half
parts:
  U1: dip16 @ e10 L293D
  USB:
    type: device
    at: top
    label: USB 5V
    pins: ["+5V", GND]
  MOT:
    type: device
    at: top
    label: BLDC 14P
    pins: [U, V, W]
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [GND, 1-, 2-, DIO0, DIO1, DIO2, 1+, 2+]
wires:
  - USB.+5V -- +t2 red
  - USB.GND -- -t3 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
  - a10 -- +t10 red
  - a17 -- +t17 red
  - a13 -- -t13 black
  - a14 -- -t14 black
  - j10 -- +b10 red
  - j17 -- +b17 red
  - j13 -- -b13 black
  - j14 -- -b14 black
  - AD.DIO0 -- j11 yellow
  - AD.DIO1 -- j16 green
  - c16 -- c18 blue
  - e18 -- f18 blue
  - AD.DIO2 -- j18 blue
  - i12 -- i20 orange
  - e20 -- f20 orange
  - MOT.U -- a20 orange
  - h15 -- h24 purple
  - e24 -- f24 purple
  - MOT.V -- a24 purple
  - b15 -- b26 white
  - MOT.W -- a26 white
  - AD.GND -- -b5 black
  - AD.1+ -- j20 orange
  - AD.1- -- -b7 black
  - AD.2+ -- j24 purple
  - AD.2- -- -b9 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/06-synchronous-speed.svg)

- L293D は切り欠きを左にして 10〜17 列に挿す。下の列が 1〜8 番 (f10〜f17)、上の列が右から 9〜16 番 (e17〜e10)
- 電源: 16 番 (e10)・9 番 (e17) を上の赤レール、1 番 (f10)・8 番 (f17) を下の赤レール。
  GND の 4・5 番 (f13・f14)、12・13 番 (e14・e13) を青レールへ。使わない 4 回路目 (14・15 番) には何もつながない
- 入力: DIO0 → 2 番 (1A、f11)、DIO1 → 7 番 (2A、f16)、DIO2 → 10 番 (3A、e16)。DIO2 は上の 16 列から c 行で 18 列へ出し、溝を渡って下へ
- 出力: 3 番 (1Y、12 列) を i 行で 20 列へ、6 番 (2Y、15 列の下) を h 行で 24 列へ、11 番 (3Y、15 列の上) を b 行で 26 列へ延ばし、
  20・24・26 列の上にモータの U・V・W を挿す
- CH1 (1+) は U (j20)、CH2 (2+) は V (j24)。1−・2−・GND は下の青レール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Patterns | DIO0・DIO1・DIO2: Clock、Frequency 7 Hz、Duty 50 %、Phase 0°・120°・240° |
| Scope | CH1 = U (1Y)、CH2 = V (2Y)。2 V/div、Time base 50 ms/div |
| Measure | CH1 の Frequency、CH1 に対する CH2 の Phase |
| 回転数 | 軸にテープの小旗を付け、30 秒に何回回るかを数える |

Patterns の Phase の向き (進みか遅れか) で、U → V → W の順が逆になることがある。そのときはモータが逆に回るだけで、
速さは変わらない。画面で V が U より 120° 遅れていれば図1 の順。
f を 3.5 Hz・7 Hz・14 Hz と変えて回転数を数える。f を上げていくと、ある所で回転子が磁界に付いて行けなくなり
(**脱調**)、震えて止まる。その周波数はモータと電圧で違う。

f = 7 Hz の画面。図は理想 (0 V と 5 V) で描いた。実物の L293D は出力の段で電圧が下がり、H は約 3.8 V、L は約 1 V になる。

```scope
title: 図3 f 7 Hz — V (CH2) は U (CH1) より 120° 遅れる
time: 50ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 7Hz 2.5V offset 2.5V, range: 2V/div, position: 0.5div}
ch2: {wave: square 7Hz 2.5V offset 2.5V phase -120deg, range: 2V/div, position: -3.5div}
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/scope/06-synchronous-speed.svg)

### オシロスコープと発振器

GND 基準の題で、測る所は図1 のまま ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 の先端を U (j20)、CH2 の先端を V (j24)、
グランドクリップは 2 本とも青レール。L293D の GND はオシロの大地につながるが、モータの 3 本の線はどれも GND ではないので
クリップを当てない。

- AD の Patterns の代わりに要るのは、**120° ずつずれた 3 本の方形波**。2 ch の発振器では 3 本目が作れない。
  マイコン (回路の本の 11 章の Raspberry Pi Pico 2) で 3 本を出すか、3 ch 以上のパターン発生器を使う。
  Pico 2 のプログラムは下の「Pico 2 で 3 本の方形波を出す」に置いた
  発振器 1 台なら、7 Hz × 6 = 42 Hz の方形波を 4017 のような 10 進カウンタで分けて 6 ステップを作る方法もある (配線は増える)
- 電源は安定化電源の 5 V、電流制限 0.8 A (6 ステップのどの状態でも 0.4 A ほど、計算値)
- 周波数は Measure の Frequency、相の遅れは 2 ch の Phase で読む

## Pico 2 で 3 本の方形波を出す

AD の Patterns が無いときは、Raspberry Pi Pico 2 (RP2350) の GPIO 3 本を図 1 の DIO0〜DIO2 の代わりにする。
GP2 (ピン 4)・GP3 (ピン 5)・GP4 (ピン 6) を L293D の 2・7・10 番へ、Pico 2 の GND (ピン 3 など) を GND のレールへつなぐ。
出力は 3.3 V の方形波で、AD の DIO と同じ (L293D の入力の H に足りる)。
1 周期を 6 ステップに分け、V は U より 2 ステップ (120°)、W は 4 ステップ遅らせる。f = 7 Hz なら 1 ステップは 1 / (7 × 6) ≒ 23.8 ms。
プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** とする (書き込み方は回路の本の 11-1)。

`main.c`

```c
#include "pico/stdlib.h"

#define PIN_U 2                       // GP2 -> L293D の 2 番
#define PIN_V 3                       // GP3 -> L293D の 7 番
#define PIN_W 4                       // GP4 -> L293D の 10 番
#define FREQ_HZ 7                     // 電源の周波数 f
#define STEP_US (1000000 / (FREQ_HZ * 6))   // 1 周期を 6 ステップに分ける

int main(void) {
    const uint pins[3] = {PIN_U, PIN_V, PIN_W};
    for (int i = 0; i < 3; i++) {
        gpio_init(pins[i]);
        gpio_set_dir(pins[i], GPIO_OUT);
    }

    absolute_time_t next = get_absolute_time();
    for (int step = 0; ; step = (step + 1) % 6) {
        // 相 k は 3 ステップ H、3 ステップ L。V は U より 2 ステップ (120°) 遅れる
        for (int k = 0; k < 3; k++) {
            gpio_put(pins[k], ((step + 6 - 2 * k) % 6) < 3);
        }
        next = delayed_by_us(next, STEP_US);
        sleep_until(next);
    }
}
```

`CMakeLists.txt` は回路の本の 11-1 と同じ形で、名前だけ `sync` に替える
(`pico_sdk_import.cmake` も同じようにコピーする)。`cmake -B build -DPICO_BOARD=pico2` のあと
`cmake --build build` で `build/sync.uf2` ができる。

MicroPython (Pico 2 用の `RPI_PICO2`) では、同じ動きを次のように書く。

```python
from machine import Pin
from time import sleep_us

FREQ_HZ = 7
STEP_US = 1000000 // (FREQ_HZ * 6)   # 1 周期を 6 ステップに分ける
pins = [Pin(n, Pin.OUT) for n in (2, 3, 4)]   # U, V, W

step = 0
while True:
    for k in range(3):
        pins[k].value(1 if (step + 6 - 2 * k) % 6 < 3 else 0)
    step = (step + 1) % 6
    sleep_us(STEP_US)
```

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。
**実機では動かしていない。** MicroPython は実行していない (未確認)。
MicroPython の `sleep_us` は待つたびに処理の時間が足されるので、周期が C/C++ よりわずかに長くなる。
本文の見るべき値 (7 Hz で 60 rpm) は周波数を Measure で読んで合わせる。

## 見るべき値

計算値 (p = 14)。

| f | N = 120 f / p | 1 回転の時間 | 30 秒の回転数 |
| --- | --- | --- | --- |
| 3.5 Hz | 30 rpm | 2.0 s | 15 回 |
| 7 Hz | 60 rpm | 1.0 s | 30 回 |
| 14 Hz | 120 rpm | 0.5 s | 60 回 |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Frequency | 7.000 Hz | 電源の周波数 f |
| CH2 の Phase (CH1 に対して) | −120° | 三相の 1 相分のずれ |
| 1 ステップの回転角 | 360° / (6 × 7) = 8.6° | 6 ステップで 2 / 14 回転。低い f では軸が小刻みに動くのが見える |

- **回転数は周波数に比例し、電源の電圧には依らない。** 5 V を 4.5 V (電池 3 本) に下げても、脱調しない限り同じ速さで回る。
  これが誘導モータ (9-3 のアラゴの円板、回転磁界より遅れて回る) との違い
- 指で軸を軽く押さえても速さは変わらない。強く押さえると脱調して止まる (同期はずれ)。同期電動機は負荷で速さが変わらない代わりに、
  限界を超えると止まる
- 2 本の線 (たとえば V と W) を入れ替えると逆に回る。三相の相順が回転磁界の向きを決める
- L293D は 0.4 A で約 2 V 下がるので、0.8 W ほど熱を出して温かくなる。1 回路 600 mA の定格には収まり、DIP16 の熱抵抗 (TI の値で約 36 °C/W) から
  温度の上がりは 30 °C ほど (計算値)。回転子が止まっても電流は同じなので、熱くて触れないほどなら測るとき以外は Patterns を止める

## 出典

自作。L293D の足の並びと入力の電圧は TI の L293D のデータシート。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Patterns・Scope の節)。
