---
book: circuits
chapter: 11
id: 11-10
title: Pico 2 W で しきい値を通知
tier: 200
source: 自作
era: 今
---

# 11-10 Pico 2 W で しきい値を通知

Pico 2 W は、Pico 2 に Wi-Fi (無線 LAN) の石 (Infineon CYW43439) を載せた基板で、ピンの並びは Pico 2 と同じ。
11-3 の CdS の分圧をそのまま Pico 2 W で読み、**暗くなったら、同じ LAN の PC へ 1 行の知らせを送る**。
送るのは UDP (相手の返事を待たずに 1 つのかたまりを送る、いちばん簡単な送り方)。

しきい値を 1 つにすると、電圧がしきい値の近くでふらつくたびに「暗い」「明るい」の知らせが続けて出る。
そこで **暗くなるしきい値 (0.5 V) と、明るさに戻るしきい値 (1.0 V) を分ける** (ヒステリシス。10-9 のシュミットトリガと同じ考え)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CdS の分圧を Pico 2 W の ADC0 (GP26) で読む (11-3 と同じ回路)
parts:
  U1: pico2-w 3,4
  P3V3: vcc 6,1.8 3.3V
  P3V3: vcc 5,1.8 3.3V
  CDS1: photoresistor 6,1.8 6,3.8 GL5528 l=$\mathrm{CDS1}$
  R1: resistor 6,3.8 6,5.8 10k
  G1: ground 6,5.8
wires:
  - U1.3V3 -| 5,1.8
  - U1.GP26 -| 6,3.8
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/circuit/10-pico2w-threshold-notify.svg)

- 回路は 11-3 と同じ。CdS (GL5528) を 3.3 V 側、R1 (10 kΩ (オーム)) を GND 側に置いた分圧を GP26 (ADC0) で読む。暗いほど電圧が下がる
- 11-3 の表の目安では、室内 (CdS 約 10 kΩ) で約 1.65 V、真っ暗 (約 200 kΩ) で約 0.16 V。しきい値の 0.5 V は CdS が約 56 kΩ、
  1.0 V は約 23 kΩ のとき (計算値。10 kΩ × (3.3 V − V) ÷ V)
- Pico 2 W では GP23〜GP25・GP29 が無線の石とのやり取りに使われている (Pico 2 W のデータシート)。GP26 はそのまま使える

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (11-3 の Pico 2 を Pico 2 W に替えるだけ)
board: full
parts:
  MCU: pico2-w @ h5
  CDS1: photoresistor b33 b30 GL5528 cap=right
  R1: resistor c30 c40 10k
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t33 -- a33 red
  - MCU.GP26 -- e30 yellow [v-48, h310, v92]
  - d40 -- -t40 black
  - SC.1+ -- a30 yellow [v10, h-80, v92]
  - SC.1- -- -t42 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/breadboard/10-pico2w-threshold-notify.svg)

- 配線は 11-3 の図2 と同じで、Pico 2 を Pico 2 W に挿し替えるだけ。Pico 2 W の電源も USB (PC か USB アダプタ)
- AD3 は Scope だけ。1+ を分圧の点 (30 列の `a30`)、1− を上の − レールへ
- ブレッドボードを流れる電流は、明るいとき (CdS 約 1 kΩ) でも 3.3 V ÷ 11 kΩ ≈ 0.3 mA

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | マイコン | Raspberry Pi Pico 2 W (USB で給電) |
| CDS1 | CdS (光で抵抗が変わる) | GL5528 |
| R1 | 抵抗 (分圧) | 10 kΩ |
| — | PC | 同じ Wi-Fi (LAN) につないだ PC。UDP の 5005 番で受ける |
| — | 計器 | Analog Discovery 3 の Scope (1+ = 分圧の点、1− = GND) |

## 計器の設定

計器は AD3 のオシロ (Scope)。CdS を手で覆って 1.2 秒後に離すまでの電圧を Single で捕まえ、**2 つのしきい値を横切る時刻**を見る。
プログラムは 0.1 秒ごとに読むので、知らせはしきい値を横切ってから 0.1 秒以内に出る。

| 項目 | 値 |
| --- | --- |
| 電源 | Pico 2 W の USB (AD3 の Supplies は使わない) |
| CH1 (1+) | 分圧の点 (GP26)。500 mV/div、0 V を下から 1 目盛 |
| 時間レンジ | 200 ms/div (1 画面 2 秒) |
| トリガ | CH1 の立ち下がり、0.5 V (暗くなるしきい値)、Single。トリガの点を左から 2 目盛に置く |
| カーソル | X1 を 0 (0.5 V を切る所 = トリガの点)、X2 を 1.0 V を越える所 (約 1.17 s) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 覆うと 0.5 V を切って「dark」、離すと 1.0 V を越えて「bright」を送る
time: 200ms/div
trigger: ch1 falling 0.5V at -3div
ch1: {wave: = 1.65V - 1.49V * step(t) + 1.49V * step(t - 1.2s) | rc 50ms, range: 500mV/div, position: -3div}
cursors: [0, 1.17s]
measure: [vmax, vmin]
notes:
  - text 0 0.5V: dark を送る (0.5 V を切った)
  - text 1.17s 1V: bright を送る (1.0 V を越えた)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/11-microcontrollers/scope/10-pico2w-threshold-notify.svg)

- 覆う前は約 1.65 V、覆っている間は約 0.16 V (11-3 と同じ)。手の動きと CdS の遅れを、時定数 50 ms のなめらかな変化で描いた (図は理想の形)
- 下がるときは 0.5 V を切った所 (X1)、上がるときは 1.0 V を越えた所 (X2) で知らせる。0.5〜1.0 V の間では状態を変えないので、ふらついても知らせは 1 回ずつ
- 覆っていた時間は 1.2 s。図の時定数で、覆ってから 0.5 V を切るまで 50 ms × ln(1.49 ÷ 0.34) ≈ 74 ms、離してから 1.0 V を越えるまで 50 ms × ln(1.49 ÷ 0.65) ≈ 41 ms なので、X2 は 1.2 s − 74 ms + 41 ms ≈ 1.17 s (計算値)

## プログラム

ネットワークの名前 (SSID) とパスワード、知らせる先の PC の IP アドレスは、手元のものに書き換える。
PC では `nc -ul 5005` (Linux・macOS) などで UDP の 5005 番を待ち受けると、届いた 1 行が出る。

### C/C++ (Pico SDK)

<!-- program: skip -->
```c
#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "pico/cyw43_arch.h"
#include "hardware/adc.h"
#include "lwip/udp.h"

#define WIFI_SSID     "your-ssid"
#define WIFI_PASSWORD "your-password"
#define PC_IP         "192.168.1.10"   // 知らせる先の PC (同じ LAN)
#define PC_PORT       5005
#define DARK_V        0.5f             // これより下がったら「暗い」
#define BRIGHT_V      1.0f             // これより上がったら「明るい」に戻す

static void notify(struct udp_pcb *pcb, const ip_addr_t *dst, const char *msg) {
    size_t len = strlen(msg);
    cyw43_arch_lwip_begin();                       // lwIP を触る間は鍵を掛ける
    struct pbuf *p = pbuf_alloc(PBUF_TRANSPORT, len, PBUF_RAM);
    if (p != NULL) {
        memcpy(p->payload, msg, len);
        udp_sendto(pcb, p, dst, PC_PORT);
        pbuf_free(p);
    }
    cyw43_arch_lwip_end();
    printf("%s\n", msg);
}

int main(void) {
    stdio_init_all();
    if (cyw43_arch_init()) {
        printf("cyw43 init failed\n");
        return 1;
    }
    cyw43_arch_enable_sta_mode();
    while (cyw43_arch_wifi_connect_timeout_ms(WIFI_SSID, WIFI_PASSWORD,
                                              CYW43_AUTH_WPA2_AES_PSK, 30000)) {
        printf("connect failed, retry\n");
    }
    adc_init();
    adc_gpio_init(26);
    adc_select_input(0);

    struct udp_pcb *pcb = udp_new();
    ip_addr_t dst;
    ipaddr_aton(PC_IP, &dst);
    bool dark = false;
    char msg[32];
    while (true) {
        float v = adc_read() * 3.3f / 4096.0f;
        if (!dark && v < DARK_V) {                 // 明るい → 暗い
            dark = true;
            snprintf(msg, sizeof msg, "dark %.2f V", (double)v);
            notify(pcb, &dst, msg);
        } else if (dark && v > BRIGHT_V) {         // 暗い → 明るい
            dark = false;
            snprintf(msg, sizeof msg, "bright %.2f V", (double)v);
            notify(pcb, &dst, msg);
        }
        sleep_ms(100);
    }
}
```

- `CMakeLists.txt` は 11-2 と同じ形で、`PICO_BOARD` を `pico2_w` にし、`target_link_libraries` を
  `pico_stdlib hardware_adc pico_cyw43_arch_lwip_threadsafe_background` にする。lwIP の設定 `lwipopts.h` が要るので、
  [pico-examples](https://github.com/raspberrypi/pico-examples) の `pico_w/wifi/lwipopts_examples_common.h` を写して使う
- `cyw43_arch_wifi_connect_timeout_ms()` が 0 を返すまで繋ぎ直す。`udp_sendto()` を呼ぶ前後は `cyw43_arch_lwip_begin()`・`end()` で囲む
  (無線の処理は裏で割り込みとして動いていて、同時に lwIP を触らないようにする)

### MicroPython

Pico 2 W 用の MicroPython (`RPI_PICO2_W` の版) を書き込んでおく。

```python
import network
import socket
import time
from machine import ADC, Pin

SSID = "your-ssid"
PASSWORD = "your-password"
PC = ("192.168.1.10", 5005)   # 知らせる先の PC (同じ LAN)
DARK_V = 0.5                  # これより下がったら「暗い」
BRIGHT_V = 1.0                # これより上がったら「明るい」に戻す

wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect(SSID, PASSWORD)
while not wlan.isconnected():
    time.sleep(0.5)
print("connected", wlan.ifconfig()[0])

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
adc = ADC(Pin(26))
dark = False
while True:
    v = adc.read_u16() * 3.3 / 65535
    if not dark and v < DARK_V:            # 明るい → 暗い
        dark = True
        msg = "dark %.2f V" % v
        sock.sendto(msg.encode(), PC)
        print(msg)
    elif dark and v > BRIGHT_V:            # 暗い → 明るい
        dark = False
        msg = "bright %.2f V" % v
        sock.sendto(msg.encode(), PC)
        print(msg)
    time.sleep(0.1)
```

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 起動して Wi-Fi に繋がったとき | `connected 192.168.…` (割り当てられたアドレス) |
| CdS を覆う | PC に `dark 0.16 V` ほどが 1 行届く (0.1 秒以内) |
| 手を離す | PC に `bright 1.65 V` ほどが 1 行届く |
| 覆ったまま・明るいままのとき | 何も届かない (状態が変わったときだけ送る) |

届かないときは、PC のファイアウォールが UDP の 5005 番を止めていないか、PC と Pico 2 W が同じネットワークにいるかを見る。
UDP は届いたかを確かめないので、確実に知らせたいときは、PC から返事を返させて、来なければ送り直す作りにする。

## LTspice での確かめ

`sim/10-pico2w-threshold-notify.cir` で、11-3 の分圧の CdS を 10 kΩ・200 kΩ・56 kΩ・23 kΩ の 4 通りにして電圧を読み、しきい値の 0.5 V と 1.0 V になる CdS の抵抗を確かめた。
CdS は抵抗で表した (11-3 と同じ目安の値)。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 室内 (CdS 10 kΩ) の電圧 | 約 1.65 V | 1.65 V | 合う |
| 真っ暗 (CdS 200 kΩ) の電圧 | 約 0.16 V | 0.157 V | 合う |
| CdS 56 kΩ の電圧 | 0.5 V (しきい値) | 0.500 V | 合う |
| CdS 23 kΩ の電圧 | 1.0 V (しきい値) | 1.000 V | 合う |

カーソルの時刻は算術で確かめた (図の時定数 50 ms で、0.5 V を切るのは覆ってから 73.9 ms、1.0 V を越えるのは離してから 41.5 ms。X2 = 1.2 s − 73.9 ms + 41.5 ms = 1.168 s)。

## プログラムでの確かめ

MicroPython 版を PC で動かした。ADC の読みを 1.0 s まで 1.65 V、2.0 s まで 0.16 V、そのあと 1.65 V にし、
`network` と `socket` は送った先と中身を残すだけの代わりの物にした (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| 送る中身と回数 | `dark 0.16 V` と `bright 1.65 V` の 2 回だけ。宛先は 192.168.1.10 の 5005 番 | MicroPython: `machine` のスタブ |
| 送る時刻 | 暗くなってから 0.1 s 以内、明るくなってから 0.1 s 以内 | MicroPython: `machine` のスタブ |

見ていない物: C/C++ 版 (Wi-Fi の石と lwIP のモックが無いので取り出していない。ビルドも確かめていない)・実際の Wi-Fi・UDP が届くか

## 出典

自作。GP23〜GP25・GP29 が無線の石に使われていることは [Pico 2 W のデータシート](https://datasheets.raspberrypi.com/picow/pico-2-w-datasheet.pdf) による。

参考: [pico-examples (pico_w/wifi)](https://github.com/raspberrypi/pico-examples)、[MicroPython の network.WLAN](https://docs.micropython.org/en/latest/library/network.WLAN.html)、[User Datagram Protocol (Wikipedia)](https://ja.wikipedia.org/wiki/User_Datagram_Protocol)
