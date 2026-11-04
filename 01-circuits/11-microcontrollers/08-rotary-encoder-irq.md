---
book: circuits
chapter: 11
id: 11-8
title: 割り込みとロータリーエンコーダ
tier: 200
source: 自作
era: 今
---

# 11-8 割り込みとロータリーエンコーダ

11-2 ではボタンを 0.2 秒ごとに読んだ (ポーリング)。回したつまみの向きと回数を数えるロータリーエンコーダは、
1 クリックの変化が数 ms で終わるので、ときどき読むやり方では取りこぼす。そこで **割り込み** を使う。
GPIO の電圧が変わった瞬間に、Pico 2 は今の仕事を止めて、決めておいた関数 (割り込みの処理) を呼ぶ。

ロータリーエンコーダのモジュール KY-040 は、回すと 2 本の線 CLK (A 相) と DT (B 相) が、4 分の 1 周期ずれて H と L を繰り返す。
**CLK が落ちた瞬間に DT を読む**と、DT が H なら一方の向き、L なら逆の向きに回っている。つまみの押しボタン (SW) も付いている。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 KY-040 の CLK・DT・SW を Pico 2 の GPIO の割り込みで読む
parts:
  U1: pico2 3,5 mirror
  M1:
    type: device
    model: KY-040
    at: 12,7.25
    pins: [VCC, SW, CLK, DT, GND]
  P3V3: vcc 10.5,5.5 3.3V
  C1: capacitor 8,7.25 8,8.25 10n
  C2: capacitor 9.5,7.5 9.5,8.25 10n
  G1: ground 8,8.25
  G2: ground 9.5,8.25
  G3: ground 10.5,8.25
  P3V3: vcc 1,2.25 3.3V
  G4: ground 1.75,3.25 r90
wires:
  - U1.GP13 -- 7,6.75 -- 7,7 -- M1.SW
  - U1.GP14 -- 8,7.25 -- M1.CLK
  - U1.GP15 -- 9.5,7.5 -- M1.DT
  - U1.3V3 -| 1,2.25
  - U1.GND38 -- 1.75,3.25
  - M1.VCC -| 10.5,5.5
  - M1.GND -| 10.5,8.25
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/08-rotary-encoder-irq.svg)

- CLK を GP14、DT を GP15、SW を GP13 へ。モジュールの VCC は Pico 2 の 3V3 (3.3 V) につなぐ。5 V にすると CLK・DT が 5 V まで上がる
  (RP2350 は 3.3 V で動いているときは 5.5 V まで耐えるが、電源を入れる順で外れることがあるので、3.3 V にそろえる)
- KY-040 の基板には、CLK と DT のプルアップ抵抗 (10 kΩ (オーム) が多い。品で違う) が載っている。SW のプルアップは無い品が多いので、
  Pico 2 の内蔵プルアップを使う
- C1・C2 (10 nF) はチャタリング (接点のはね、10-9) を和らげる。プルアップの 10 kΩ と合わせた時定数 τ (タウ) = 10 kΩ × 10 nF = 0.1 ms。
  接点が開いても、電圧が H のしきい値まで上がるのに 0.1 ms 以上かかるので、数十 µs (マイクロ秒) のはねは H と読まれない
- C1 の上の線は DT の線と交わっているが、つながっていない (点の無い交差)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 KY-040 を GP13〜GP15 につなぐ (AD3 は Scope だけ)
board: full
parts:
  MCU: pico2 @ h5
  M1: sip5 @ a40 KY-040
  C1: capacitor d40 d44 10n cap=left
  C2: capacitor c41 c44 10n cap=left
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - b43 -- +t43 red
  - b44 -- -t44 black
  - MCU.GP14 -- e40 yellow
  - MCU.GP15 -- e41 green
  - MCU.GP13 -- e42 blue
  - SC.1+ -- b40 yellow
  - SC.2+ -- b41 green
  - SC.1- -- -t48 black
  - SC.2- -- -t49 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/08-rotary-encoder-irq.svg)

- Pico 2 の `3V3` (9 列の上) を上の + レールへ、`GND` (7 列の上) を上の − レールへ
- KY-040 (M1) は a40〜a44 に挿す。並びは左から CLK・DT・SW・VCC・GND (基板の印字 `+` が VCC)。**品によって並びが違う**ので、手元の基板の印字で確かめる。
  VCC (43 列) は `b43` から + レールへ、GND (44 列) は `b44` から − レールへ
- C1 (CLK の 40 列〜GND の 44 列、d 行)・C2 (DT の 41 列〜44 列、c 行) を GND の列へ渡す
- GP14 (23 列の下) を黄、GP15 (24 列の下) を緑、GP13 (21 列の下) を青の線で 40・41・42 列の e 行へ
- AD3 は Scope だけ。1+ を CLK (`b40`)、2+ を DT (`b41`) へ、1−・2− を上の − レールへ
- ブレッドボードを流れる電流は、プルアップ 2 本ぶんの 3.3 V ÷ 10 kΩ × 2 ≈ 0.7 mA 以下で、範囲に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 (USB で給電) |
| M1 | ロータリーエンコーダのモジュール | KY-040 (20 クリック/回転が多い。CLK・DT のプルアップ 10 kΩ つき) |
| C1・C2 | セラミックコンデンサ | 10 nF (103) |
| — | 計器 | Analog Discovery 3 の Scope (1+ = CLK、2+ = DT、1−・2− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。つまみを一定の速さで回したときの CLK と DT を重ねて、**4 分の 1 周期のずれ**を見る。
1 回転 (20 クリック) を 0.5 秒で回すと、CLK は 1 クリックで 1 周期なので 40 Hz (周期 25 ms) になる (目安)。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | CLK (GP14)。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | DT (GP15)。1 V/div、0 V を下から半目盛 |
| 時間レンジ | 5 ms/div |
| トリガ | CH1 の立ち下がり、1.65 V、Normal。トリガの点を左から 3 目盛に置く |
| Measurements | Frequency・Phase |
| カーソル | X1 を 1 ms (CLK が落ちた直後)、X2 を 13.5 ms (CLK が上がった直後) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 時計回りに回したときの CLK (CH1) と DT (CH2) — DT が 4 分の 1 周期遅れる
time: 5ms/div
trigger: ch1 falling 1.65V at -2div
ch1: {wave: square 40Hz 1.65V offset 1.65V phase 180deg, range: 1V/div, position: 0.5div}
ch2: {wave: ch1 | delay 6.25ms, range: 1V/div, position: -3.5div}
cursors: [1ms, 13.5ms]
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/08-rotary-encoder-irq.svg)

- 時計回りでは CLK が先に変わり、DT が 6.25 ms (周期の 4 分の 1、位相で −90°) 遅れて続く。X1 (CLK が落ちた直後) の DT は 3.3 V (H) で、これが「時計回り」の印
- 反時計回りでは DT が先に変わるので、CLK が落ちた瞬間の DT は L。図の CH2 を CH1 より先に動かした形になる
- 時計回りでどちらが先かは品で逆のことがある。数が逆に進んだら、プログラムの `+1` と `-1` を入れ替えるか、CLK と DT の線を入れ替える
- 図は理想の形。実物は回す速さが一定でなく、縁には C1・C2 による 0.1 ms ほどのなまり (立ち上がり) が付く

## プログラム

### C/C++ (Pico SDK)

```c
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"

#define PIN_SW  13
#define PIN_CLK 14
#define PIN_DT  15

static volatile int count = 0;
static volatile bool pressed = false;

// 割り込みの処理。短く済ませ、表示は main に任せる
static void on_edge(uint gpio, uint32_t events) {
    if (gpio == PIN_CLK && (events & GPIO_IRQ_EDGE_FALL)) {
        count += gpio_get(PIN_DT) ? 1 : -1;   // CLK が落ちた瞬間の DT で向きを決める
    } else if (gpio == PIN_SW && (events & GPIO_IRQ_EDGE_FALL)) {
        pressed = true;
    }
}

int main(void) {
    stdio_init_all();
    gpio_init(PIN_CLK);
    gpio_set_dir(PIN_CLK, GPIO_IN);           // プルアップはモジュールの基板の上
    gpio_init(PIN_DT);
    gpio_set_dir(PIN_DT, GPIO_IN);
    gpio_init(PIN_SW);
    gpio_set_dir(PIN_SW, GPIO_IN);
    gpio_pull_up(PIN_SW);                     // SW は内蔵プルアップ
    gpio_set_irq_enabled_with_callback(PIN_CLK, GPIO_IRQ_EDGE_FALL, true, &on_edge);
    gpio_set_irq_enabled(PIN_SW, GPIO_IRQ_EDGE_FALL, true);

    int shown = 0;
    while (true) {
        if (pressed) {                        // つまみを押したら 0 に戻す
            pressed = false;
            count = 0;
        }
        if (count != shown) {
            shown = count;
            printf("%d\n", shown);
        }
        tight_loop_contents();
    }
}
```

- `gpio_set_irq_enabled_with_callback()` で、GP14 の立ち下がりで `on_edge()` が呼ばれるようにする。Pico SDK の GPIO の割り込みは、
  どのピンでも同じ 1 つの関数が呼ばれ、`gpio` 引数でピンを見分ける。GP13 は `gpio_set_irq_enabled()` で足すだけ
- 割り込みの中で書き換える変数には `volatile` を付ける (main の側で、最新の値を毎回読み直させる)
- `CMakeLists.txt` は 11-2 と同じ形で、名前を `encoder` にする (`pico_stdlib` に GPIO の割り込みも入っている)

### MicroPython

```python
from machine import Pin
import time

clk = Pin(14, Pin.IN)
dt = Pin(15, Pin.IN)
sw = Pin(13, Pin.IN, Pin.PULL_UP)
count = 0
pressed = False

def on_clk(pin):
    global count
    count += 1 if dt.value() else -1     # CLK が落ちた瞬間の DT で向きを決める

def on_sw(pin):
    global pressed
    pressed = True

clk.irq(trigger=Pin.IRQ_FALLING, handler=on_clk)
sw.irq(trigger=Pin.IRQ_FALLING, handler=on_sw)

shown = 0
while True:
    if pressed:
        pressed = False
        count = 0
    if count != shown:
        shown = count
        print(shown)
    time.sleep_ms(1)
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 時計回りに 1 クリック | 表示が 1 増える (品によっては 1 クリックで 2) |
| 反時計回りに 1 クリック | 表示が 1 減る |
| つまみを押す | 0 に戻る |
| CLK と DT の位相 | DT が CLK より 90° 遅れる (時計回り) |
| 接点が開いたときの立ち上がり (10 %→90 %) | 約 0.22 ms (2.2 τ、計算値) |

1 回で数が 2 つ以上跳ぶなら、チャタリングが残っている。C1・C2 を付け忘れていないかを見る。

## LTspice での確かめ

`sim/08-rotary-encoder-irq.cir` で、CLK の 1 本 (プルアップ 10 kΩ、C1 10 nF、接点) に、閉じた直後に 20 µs 開くはねを 2 回、
開いた直後に 20 µs 閉じるはねを 1 回入れた (はねの形は仮定)。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 閉じた直後のはね (20 µs 開く) の山 | H と読まれない | 0.60 V | 合う (RP2350 の入力の L の上限 0.8 V (3.3 V のとき) より低い) |
| 開いたときの立ち上がり (10 %→90 %) | 約 0.22 ms | 0.220 ms | 合う |
| 開いた 30 µs 後のはね (閉じる) の前の電圧 | H と読まれない | 0.86 V (算術: 3.3 V × (1 − e<sup>−0.3</sup>)) | 合う (H の下限 2.0 V に届く前に戻る) |

位相のずれ (4 分の 1 周期 = 6.25 ms @ 40 Hz) は算術で確かめた。

## プログラムでの確かめ

本文のプログラムを PC で動かし、CLK の立ち下がりの割り込みを、DT を H にして 3 回・L にして 1 回起こし、続けて SW の割り込みを起こした (`npm run pico:test`)。
**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| 割り込みの設定 | GP14 と GP13 の立ち下がり。SW は内蔵プルアップ | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 数え方 | 1・2・3 (時計回り 3 回)、2 (反時計回り 1 回)、0 (押した) と出る | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: 実際の接点のはね・割り込みの遅れ・取りこぼし

## 出典

自作。

参考: [ロータリエンコーダ (Wikipedia)](https://ja.wikipedia.org/wiki/ロータリエンコーダ)、[Pico SDK (hardware_gpio)](https://github.com/raspberrypi/pico-sdk)、[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)
