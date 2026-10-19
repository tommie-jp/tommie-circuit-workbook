---
book: etc
chapter: 5
id: 5-2
title: 送信 — Raspberry Pi Pico 2 の PIO と抵抗だけでリンクパルスとフレームを送り、ルータにリンクさせる
tier: 200
source: 回路と PIO の方式は kingyoPiyo の Pico-10BASE-T (MIT)。プログラムは書き直した
board: PF
---

# 5-2 送信 — Raspberry Pi Pico 2 の PIO と抵抗だけでリンクパルスとフレームを送り、ルータにリンクさせる

> [!WARNING]
> **この工作 (5 章 ethernet-10base-t) は、まだ実機で測っていない。** 回路と数値は計算で、プログラムは PC の模型 (`npm run pico:test`) で動きを確かめただけ。ルータがリンクするか、PC に UDP が届くかは、組んで確かめてほしい。

ブレッドボードでなくユニバーサル基板に組むのは、線の上の信号が 10 MHz (マンチェスターの変わり目は 50 ns) で、
ブレッドボードの範囲 (3 MHz) を超えるため。ユニバーサル基板の範囲 (10 MHz 以下、短い配線) には収まる。
電源は Pico 2 の USB (5 V) から取り、回路は 3.3 V で動く。

## ねらい

5-1 でルータが出していた信号を、今度は自分で出す。Pico 2 の PIO (プログラムできる I/O) を 20 MHz で回し、
GPIO 2 本を抵抗 2 本で RJ45 につなぐだけで、10BASE-T の**リンクパルスと UDP のフレーム**を送る。
ルータの LAN ポートの LED が点き (リンク)、同じ LAN の PC で UDP が受かれば成功だ。
受信回路は無いので、ルータから来る物は読まない (5-3・5-4)。

マンチェスター符号は「1 ビット = 2 シンボル (50 ns)」なので、**送る物は 20 M シンボル/秒の 2 値の列**に
なる。PIO に 1 命令 (`out pins, 2`) を 20 MHz で回させ、CPU は 1 バイトを 4 バイトのシンボル列に
直して FIFO に積むだけでよい。パルストランスは入れない (理由と省けるわけは 5-6)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の PIO と抵抗 2 本で 10BASE-T を送る
parts:
  MCU: pico2 2,4
  R2: resistor 4,6.25 6,6.25 47
  R1: resistor 4,7.5 6,7.5 47
  J1:
    type: device
    at: 9,6
    label: RJ45 (105404)
    pins: [P1, P2, P3, P6]
  SC:
    type: device
    at: 8,9.5
    label: AD3 Scope
    pins: [1+, 1-]
  LA:
    type: device
    at: 2,9.5
    label: AD3 Logic
    pins: [DIO1, DIO0, GND]
    turn: mirror
wires:
  - MCU.GP17 -- 3,6.25 -- 4,6.25
  - MCU.GP16 -| 3.25,7.5 -- 4,7.5
  - 6,6.25 -- 7,6.25 -| J1.P1
  - 6,7.5 -- 7,7.5 -| J1.P2
  - SC.1+ |- 7,6.25
  - SC.1- |- 7,7.5
  - LA.DIO1 |- 3,6.25
  - LA.DIO0 |- 3.25,7.5
  - MCU.GND23 -- 2.75,6
  - LA.GND |- 2.75,6
notes:
  - text 3,5.5 small left: GP17 が TX+ (ピン 1)、GP16 が TX- (ピン 2)。線は 100 Ω の対
  - text 4,11.25 small left: 差動の振幅は 3.3 V の 100 / 194 で 1.70 V (計算)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/circuit/02-tx-link-pulse.svg)

| 部品 | 値 | 備考 |
| --- | --- | --- |
| MCU | Raspberry Pi Pico 2 | GP17 = TX+、GP16 = TX−。GPIO は 12 mA 設定・高速スルーレート |
| R1・R2 | 47 Ω (オーム) | 直列抵抗。GPIO の電流を抑え、線路 (100 Ω) との分圧で振幅 1.7 V にする |
| J1 | 秋月 LAN コネクターDIP化キット ([105404](https://akizukidenshi.com/catalog/g/g105404/)) | ヘッダのピン 1 = TX+、2 = TX−。3・6 (受信) は 5-3 で使う。5-1 に仕様と導通の確かめ方 |
| 電源 | USB 5 V → Pico 2 の 3.3 V | 回路は Pico 2 の 3.3 V で動くので、別の電源は要らない |

- 相手 (ルータの LAN ポート) の受信側にはパルストランスと 100 Ω の終端がある。GPIO の 3.3 V を
  47 Ω × 2 と 100 Ω で分圧すると、線の差動電圧は **1.70 V** (GPIO の内部抵抗を 0 とした計算)。
  規格の 2.2〜2.8 V より低いが、受信側は 585 mV 以上あれば受ける (IEEE 802.3 14.3.1.3.1)
- GPIO 1 本の電流は 3.3 / 194 = 17 mA。RP2350 の 12 mA 設定の上限を超えるので、実際の出力は
  少し下がり、振幅は 1.7 V より小さくなる (1.3〜1.5 V 程度と見積もる。測って書く)。
  電流を減らしたければ R1・R2 を 100 Ω にする (振幅 1.1 V、11 mA)
- アイドル (何も送らない) のときは GP16・GP17 とも L で、差動 0 V。リンクパルスは GP17 だけを
  100 ns だけ H にする。マンチェスターの HIGH は GP17 = H・GP16 = L、LOW はその逆
- **PoE (電源を重畳するスイッチ) にはつながない。** トランスが無いので、48 V が GPIO に入る (出典の注意)

## 実体配線図

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図2 送信回路のユニバーサル基板 (9×7 cm 横置き、部品面)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
style:
  check: off
parts:
  MCU: pico2 c9
  J1: sip8 a26 r90 RJ45
  R2: resistor m26 q26 47
  R1: resistor m25 q25 47
wires:
  - a26 -- m26 white
  - q26 -- t26 white
  - t26 -- u26 white
  - u26 -- u9 white
  - a25 -- m25 green
  - q25 -- t25 green
  - t25 -- v25 green
  - v25 -- v9 green
notes:
  - mark t26 orange
  - mark t25 blue
  - text l-1 black: 橙の丸 (T26) はオシロの 1+ (TX+)、青の丸 (T25) は 1- (TX-)
unused: [J1.3, J1.4, J1.5, J1.6, J1.7, J1.8]
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/perfboard/02-tx-link-pulse.svg)

- 基板は **7×9 cm を横に置いた 9×7 cm** (31 列 × 26 行、英字が列・数字は下から)。この章の 5-6 までを 1 枚の基板に組むので、
  5-3 の受信回路が入る大きさにした (5×7 cm では受信回路と 74HC14 の配線が収まらない)。Pico 2 は C〜V 列の 2〜9 行に載り、
  USB が左。上の列のピン (21〜40 番) が 9 行に出る
- **RJ45 は 5-1 で紹介した秋月の LAN コネクターDIP化キット (105404)** を使う。ヘッダの 8 本を左の縁の A 列、26〜19 行に挿す
  (上からピン 1〜8)。ジャックの口は基板の外 (左) を向き、本体 (15 mm) は基板の縁から張り出す。
  この題で使うのはピン 1 (TX+) と 2 (TX−) だけ。ピン 3・6 は 5-3 の受信回路で使う
- ピン 1 (A26) の白い線は 26 行を M 列まで走り、R2 (M〜Q 列) を通って U 列を下り、GP17 (22 番、`u9`) へ。
  ピン 2 (A25) の緑の線は 25 行を M 列まで走り、R1 (M〜Q 列) を通って V 列を下り、GP16 (21 番、`v9`)。
  **U 列の白い線が 25 行の緑の線を 1 か所跨ぐ**ので、被覆線にする (図では半円の跨ぎ)。
  GP17 が GP16 より左にあるのに、ピン 1 がピン 2 より上にあるため、避けられない
- 橙と青の丸 (`t26`・`t25`) が、オシロの 1+ と 1− を当てる所 (抵抗の先 = 線路の側)。ロジアナの DIO1・DIO0 は
  Pico 2 の GP17・GP16 のピンに直接当て、GND はピン 23 (T 列 9 行)
- Pico 2 の使わないピンは ERC が言い続けるので `style: check: off` で検査を外した。
  つなぐ 2 本は check のネットリストで確かめた。周波数は 10 MHz 以下、電圧は 3.3 V なのでユニバーサル基板の範囲
- 配線は短く。R1・R2 から RJ45 までの 2 本は、できれば撚る (差動の対にする)

## 計器の設定

計器は Analog Discovery 3。線路の差動波形は Scope (BNC アダプタ基板、1 MΩ、差動入力)、
GPIO の H/L は Logic (3.3 V LVCMOS、125 MS/s)。10 MHz までなので両方とも範囲に入る。

| 項目 | 設定 |
| --- | --- |
| Scope ch1 | 1+ を R2 の先 (TX+)、1− を R1 の先 (TX−)。GND はつながない。500 mV/div、0 V を下から 1 目盛 |
| Scope のトリガ | Normal、ch1 立ち上がり 0.8 V (リンクパルスにもプリアンブルにも掛かる) |
| Scope の時間軸 | リンクパルス 100 ns/div (図5)、プリアンブル 100 ns/div (図6)、1 フレーム 10 µs/div |
| Logic | DIO1 = GP17 (TX+)、DIO0 = GP16 (TX−)、GND = ピン 23。125 MS/s (8 ns) |
| Logic のトリガ | DIO1 立ち上がり。リンクパルスは 16 ms ごと、フレームは 1 s ごとに来る |

### ロジアナで見る GPIO の H/L

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 リンクパルス — GP17 (TX+) だけが 100 ns H
device: ad3
time: 100ns/div
sample: 125MHz
signals:
  TXP: dio1 pulse 300ns 100ns
  TXM: dio0 low
cursors: [350ns, 450ns]
trigger: TXP rising at 300ns
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/logic/02-tx-link-pulse-1.svg)

図3 の X1 (350 ns) はパルスの中、X2 (450 ns) はパルスが終わった後で、ΔX = 100 ns がパルスの幅と同じ。
125 MS/s なら 100 ns は 12 標本で、幅は 8 ns 刻みで読める。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 プリアンブルの先頭 — 1 ビット 100 ns、シンボル 50 ns
device: ad3
time: 100ns/div
sample: 125MHz
signals:
  TXP: dio1 pattern 01100110 bit 50ns repeat
  TXM: dio0 pattern 10011001 bit 50ns repeat
cursors: [125ns, 225ns]
trigger: TXP rising at 50ns
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/logic/02-tx-link-pulse-2.svg)

図4 はプリアンブル (`0x55` = LSB から 1,0,1,0,…) の先頭。ビット 1 は LOW→HIGH (TXM が H → TXP が H)、
ビット 0 は HIGH→LOW。TXP と TXM は常に反対で、両方 L なのはアイドルのときだけ。
X1・X2 は 100 ns 離した 2 点で、1 ビットの長さ。

### オシロで見る線路の差動波形

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 線路のリンクパルス — 幅 100 ns、振幅 1.7 V (計算)
time: 100ns/div
trigger: ch1 rising 0.85V at -3div
ch1: pulse 62.5Hz 0.85V offset 0.85V duty 0.000625%
cursors: [0, 100ns]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/02-tx-link-pulse-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図6 線路のプリアンブル — ±1.7 V の 5 MHz
time: 100ns/div
trigger: ch1 rising 0V
ch1: square 5MHz 1.7V
cursors: [0, 200ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/02-tx-link-pulse-2.svg)

実物は角が丸く、立ち上がりに GPIO と線の容量によるなまりが出る。相手のトランスを通ったあとの
波形 (5-1 の図4 のような、負に振れてから戻る形) はルータ側でしか見えない。

## 見るべき値

| 何を | 値 | 根拠 |
| --- | --- | --- |
| リンクパルスの幅 (図3・図5) | 100 ns (2 シンボル) | プログラムの `NLP` の語 `0x0000000A` |
| リンクパルスの間隔 | 16 ms (8〜24 ms) | プログラムの `NLP_INTERVAL_US` |
| 線路の差動の振幅 (図5 の Vmax、図6 の Vpp/2) | 1.70 V (計算)。実物は 1.3〜1.5 V 程度 | 3.3 × 100 / 194 |
| プリアンブルの周波数 (図6 の Freq) | 5 MHz | `0x55` のマンチェスター |
| 1 フレームの長さ (10 µs/div で) | 57.6 µs (プリアンブル 8 + 64 バイト = 576 ビット) + TP_IDL 0.3 µs | プログラムの語数 73 × 0.8 µs = 58.4 µs |
| フレームの間隔 | 1 s | `FRAME_INTERVAL_US` |
| ルータの LED | 点く (10 Mb/s でリンク) | 並列検出。リンクパルスを 2〜10 発受けてから |
| PC で受かる UDP | 送り元 192.168.1.250:1234 → 255.255.255.255:1234、18 バイト `P2 10BASE-T 00001` … | プログラムの定数 |

PC で受けるには、同じ LAN の PC で次を動かす (Linux)。Wireshark でも見える (`udp.port == 1234`)。

```bash
nc -ul 1234            # Pico 2 のフレームが 1 秒ごとに表示される
```

Pico 2 の IP アドレス (192.168.1.250) はルータの LAN の範囲に合わせて書き換える (ルータが 192.168.0.1 なら
192.168.0.250)。ブロードキャスト (255.255.255.255) 宛てなので、ARP は要らない (5-5 まで Pico 2 は ARP に答えられない)。

## プログラム

プログラムは C/C++ (Pico SDK) を第 1、MicroPython を第 2 として並べる。どちらも同じ動きをする。

### C/C++ (Pico SDK)

`main.c`。PIO の命令は `out pins, 2` 1 つ (0x6002) で、OSR から 2 ビットずつ GP16・GP17 に出す。
32 ビットの語 1 つが 16 シンボル = 8 ビット = 1 バイトになる。

```c
#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/clocks.h"
#include "hardware/pio.h"

#define PIN_TX_MINUS 16          /* GP16 = TX-  (R1 47 Ω → RJ45 のピン 2) */
#define PIN_TX_PLUS  17          /* GP17 = TX+  (R2 47 Ω → RJ45 のピン 1)。GP16 の次でないといけない */
#define SYMBOL_HZ    20000000u   /* 1 シンボル 50 ns */
#define NLP_INTERVAL_US   16000  /* リンクパルスの間隔 (規格は 8〜24 ms) */
#define FRAME_INTERVAL_US 1000000
#define NLP    0x0000000Au       /* HIGH を 2 シンボル = 100 ns、あとはアイドル */
#define TP_IDL 0x00000AAAu       /* フレームの終わり: HIGH を 6 シンボル = 300 ns */
#define PAYLOAD_LEN 18           /* Ethernet 14 + IP 20 + UDP 8 + 18 = 60 バイト (最小フレーム) */

static const uint8_t  SRC_MAC[6] = {0x02, 0x00, 0x00, 0x00, 0x00, 0x01};   /* ローカル管理のアドレス */
static const uint8_t  SRC_IP[4]  = {192, 168, 1, 250};                     /* ルータの LAN に合わせる */
static const uint16_t UDP_PORT   = 1234;

/* PIO: out pins, 2 を 1 命令で回す。OSR の下 2 ビットが (GP17, GP16) に出る
   00 = アイドル、01 = LOW (GP16 = H)、10 = HIGH (GP17 = H) */
static const uint16_t ser_insn[] = { 0x6002 };
static const pio_program_t ser_prog = { ser_insn, 1, -1 };
static PIO pio = pio0;
static uint sm = 0;

static void ser_init(void) {
    uint offset = pio_add_program(pio, &ser_prog);
    pio_gpio_init(pio, PIN_TX_MINUS);
    pio_gpio_init(pio, PIN_TX_PLUS);
    gpio_set_drive_strength(PIN_TX_MINUS, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_drive_strength(PIN_TX_PLUS, GPIO_DRIVE_STRENGTH_12MA);
    gpio_set_slew_rate(PIN_TX_MINUS, GPIO_SLEW_RATE_FAST);
    gpio_set_slew_rate(PIN_TX_PLUS, GPIO_SLEW_RATE_FAST);
    pio_sm_set_consecutive_pindirs(pio, sm, PIN_TX_MINUS, 2, true);
    pio_sm_config c = pio_get_default_sm_config();
    sm_config_set_wrap(&c, offset, offset);
    sm_config_set_out_pins(&c, PIN_TX_MINUS, 2);
    sm_config_set_out_shift(&c, true, true, 32);          /* 右シフト、32 ビットごとに autopull */
    sm_config_set_fifo_join(&c, PIO_FIFO_JOIN_TX);        /* TX FIFO を 8 語に */
    sm_config_set_clkdiv(&c, (float)clock_get_hz(clk_sys) / SYMBOL_HZ);   /* 120 MHz / 20 MHz = 6 */
    pio_sm_init(pio, sm, offset, &c);
    pio_sm_set_enabled(pio, sm, true);
}

/* 1 バイト → 16 シンボル。ビット b は 1 なら LOW,HIGH (0x9)、0 なら HIGH,LOW (0x6)。LSB が先 */
static uint32_t manchester(uint8_t b) {
    uint32_t w = 0;
    for (int i = 0; i < 8; i++) w |= ((b >> i) & 1 ? 0x9u : 0x6u) << (4 * i);
    return w;
}

static uint32_t crc32_ieee(const uint8_t *p, size_t n) {       /* FCS: CRC-32、反転・反射 */
    uint32_t crc = 0xFFFFFFFFu;
    for (size_t i = 0; i < n; i++) {
        crc ^= p[i];
        for (int k = 0; k < 8; k++) crc = (crc >> 1) ^ (0xEDB88320u & (0u - (crc & 1u)));
    }
    return ~crc;
}

static uint16_t ip_checksum(const uint8_t *p, size_t n) {       /* 1 の補数の和の補数 */
    uint32_t s = 0;
    for (size_t i = 0; i + 1 < n; i += 2) s += (uint32_t)p[i] << 8 | p[i + 1];
    while (s >> 16) s = (s & 0xFFFF) + (s >> 16);
    return (uint16_t)~s;
}

/* プリアンブル 8 + Ethernet 60 + FCS 4 = 72 バイト。戻り値はバイト数 */
static size_t build_frame(uint8_t *f, uint32_t seq) {
    size_t i = 0;
    memset(f, 0x55, 7); i = 7;                              /* プリアンブル 10101010 × 7 */
    f[i++] = 0xD5;                                          /* SFD 10101011 */
    memset(&f[i], 0xFF, 6); i += 6;                         /* 宛先 MAC: ブロードキャスト */
    memcpy(&f[i], SRC_MAC, 6); i += 6;
    f[i++] = 0x08; f[i++] = 0x00;                           /* EtherType IPv4 */
    uint8_t *ip = &f[i];
    uint16_t ip_len = 20 + 8 + PAYLOAD_LEN;
    ip[0] = 0x45; ip[1] = 0; ip[2] = ip_len >> 8; ip[3] = ip_len & 0xFF;
    ip[4] = seq >> 8; ip[5] = seq & 0xFF; ip[6] = 0; ip[7] = 0;   /* 識別子、分割なし */
    ip[8] = 64; ip[9] = 17; ip[10] = 0; ip[11] = 0;              /* TTL、UDP、検査和はあとで */
    memcpy(&ip[12], SRC_IP, 4); memset(&ip[16], 0xFF, 4);        /* 宛先 255.255.255.255 */
    uint16_t cs = ip_checksum(ip, 20); ip[10] = cs >> 8; ip[11] = cs & 0xFF;
    i += 20;
    uint8_t *udp = &f[i];
    udp[0] = UDP_PORT >> 8; udp[1] = UDP_PORT & 0xFF; udp[2] = UDP_PORT >> 8; udp[3] = UDP_PORT & 0xFF;
    uint16_t udp_len = 8 + PAYLOAD_LEN; udp[4] = udp_len >> 8; udp[5] = udp_len & 0xFF;
    udp[6] = 0; udp[7] = 0;                                      /* UDP の検査和は省略 (0) */
    i += 8;
    memset(&f[i], 0, PAYLOAD_LEN);
    snprintf((char *)&f[i], PAYLOAD_LEN, "P2 10BASE-T %05lu", (unsigned long)seq);
    i += PAYLOAD_LEN;
    uint32_t fcs = crc32_ieee(&f[8], i - 8);                     /* 宛先 MAC から payload まで */
    f[i++] = fcs & 0xFF; f[i++] = (fcs >> 8) & 0xFF; f[i++] = (fcs >> 16) & 0xFF; f[i++] = fcs >> 24;
    return i;                                                    /* 72 */
}

static void send_frame(uint32_t seq) {
    static uint8_t f[80];
    size_t n = build_frame(f, seq);
    for (size_t i = 0; i < n; i++) pio_sm_put_blocking(pio, sm, manchester(f[i]));
    pio_sm_put_blocking(pio, sm, TP_IDL);
}

int main(void) {
    set_sys_clock_khz(120000, true);        /* 20 MHz の整数倍にして PIO の分周を 6 にする (ジッタを無くす) */
    stdio_init_all();
    ser_init();
    uint32_t seq = 0;
    uint32_t next_nlp = time_us_32() + NLP_INTERVAL_US;
    uint32_t next_frame = time_us_32() + FRAME_INTERVAL_US;
    while (true) {
        uint32_t now = time_us_32();
        if ((int32_t)(now - next_frame) >= 0) {
            send_frame(++seq);
            printf("frame %lu\n", (unsigned long)seq);
            next_frame += FRAME_INTERVAL_US;
            next_nlp = now + NLP_INTERVAL_US;        /* 送った直後はリンクパルスを数え直す */
        } else if ((int32_t)(now - next_nlp) >= 0) {
            pio_sm_put_blocking(pio, sm, NLP);
            next_nlp += NLP_INTERVAL_US;
        }
        sleep_us(100);
    }
}
```

- `set_sys_clock_khz(120000)` でシステムクロックを 120 MHz にし、PIO の分周を整数 (6) にする。
  150 MHz のままだと 7.5 になり、シンボルの長さが 46.7 ns と 53.3 ns で交互に揺れる (ジッタ)
- `manchester()` が 1 バイトを 16 シンボル (32 ビット) に直す。`out pins, 2` が LSB から 2 ビットずつ
  GP16 (下位)・GP17 (上位) に出すので、`01` = GP16 だけ H (LOW)、`10` = GP17 だけ H (HIGH)
- `build_frame()` はプリアンブルと SFD も含めて 72 バイトを作る。FCS (CRC-32) は宛先 MAC から
  payload までの 60 バイトで計算し、LSB から送る。IP ヘッダの検査和も計算する。UDP の検査和は
  IPv4 では省略できる (0)
- フレームの最後に `TP_IDL` (HIGH を 300 ns) を送る。FIFO が空になると `out` が止まり、ピンは
  最後の値 (`00` = アイドル) のまま
- 主ループは 100 µs ごとに時刻を見て、16 ms ごとにリンクパルス、1 s ごとにフレームを送る

`CMakeLists.txt` (`pico_sdk_import.cmake` は 11-1 と同じ)。PIO は `hardware_pio` を足す。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(tx10 C CXX ASM)
pico_sdk_init()
add_executable(tx10 main.c)
target_link_libraries(tx10 pico_stdlib hardware_pio)
pico_enable_stdio_usb(tx10 1)
pico_add_extra_outputs(tx10)
```

### MicroPython

同じ事を MicroPython で書く。`rp2.asm_pio` の 1 命令 `out(pins, 2)` と `sm.put()` で、C 版と同じ語を
同じ順に積む。`machine.freq(120_000_000)` も同じ理由。

```python
from machine import Pin, freq
from rp2 import PIO, StateMachine, asm_pio
from time import ticks_us, ticks_diff, ticks_add, sleep_us
import struct

PIN_TX_MINUS = 16            # GP16 = TX-、GP17 = TX+ (GP16 の次)
NLP_INTERVAL_US = 16_000
FRAME_INTERVAL_US = 1_000_000
NLP = 0x0000000A             # HIGH を 2 シンボル = 100 ns
TP_IDL = 0x00000AAA          # HIGH を 6 シンボル = 300 ns
PAYLOAD_LEN = 18
SRC_MAC = b'\x02\x00\x00\x00\x00\x01'
SRC_IP = bytes((192, 168, 1, 250))
UDP_PORT = 1234

freq(120_000_000)            # 20 MHz × 6


@asm_pio(out_init=(PIO.OUT_LOW, PIO.OUT_LOW), out_shiftdir=PIO.SHIFT_RIGHT,
         autopull=True, pull_thresh=32, fifo_join=PIO.JOIN_TX)
def ser_10base_t():
    wrap_target()
    out(pins, 2)             # 下 2 ビットを (GP17, GP16) へ。00 アイドル / 01 LOW / 10 HIGH
    wrap()


sm = StateMachine(0, ser_10base_t, freq=20_000_000, out_base=Pin(PIN_TX_MINUS))
sm.active(1)

MANCHESTER = []              # 1 バイト → 16 シンボル (ビット 1 = 0x9、0 = 0x6、LSB が先)
for b in range(256):
    w = 0
    for i in range(8):
        w |= (0x9 if (b >> i) & 1 else 0x6) << (4 * i)
    MANCHESTER.append(w)


def crc32_ieee(data):
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0xEDB88320 if crc & 1 else 0)
    return crc ^ 0xFFFFFFFF


def ip_checksum(data):
    s = 0
    for i in range(0, len(data) - 1, 2):
        s += (data[i] << 8) | data[i + 1]
    while s >> 16:
        s = (s & 0xFFFF) + (s >> 16)
    return (~s) & 0xFFFF


def build_frame(seq):
    payload = ('P2 10BASE-T %05d' % seq).encode()[:PAYLOAD_LEN - 1]
    payload = payload + bytes(PAYLOAD_LEN - len(payload))
    udp = struct.pack('>HHHH', UDP_PORT, UDP_PORT, 8 + PAYLOAD_LEN, 0) + payload
    ip = bytearray(struct.pack('>BBHHHBBH4s4s', 0x45, 0, 20 + len(udp), seq & 0xFFFF, 0, 64, 17, 0,
                               SRC_IP, b'\xff\xff\xff\xff'))
    struct.pack_into('>H', ip, 10, ip_checksum(ip))
    eth = b'\xff' * 6 + SRC_MAC + b'\x08\x00' + bytes(ip) + udp
    fcs = crc32_ieee(eth)
    return b'\x55' * 7 + b'\xd5' + eth + struct.pack('<I', fcs)


def send_frame(seq):
    for byte in build_frame(seq):
        sm.put(MANCHESTER[byte])
    sm.put(TP_IDL)


seq = 0
next_nlp = ticks_add(ticks_us(), NLP_INTERVAL_US)
next_frame = ticks_add(ticks_us(), FRAME_INTERVAL_US)
while True:
    now = ticks_us()
    if ticks_diff(now, next_frame) >= 0:
        seq += 1
        send_frame(seq)
        print('frame', seq)
        next_frame = ticks_add(next_frame, FRAME_INTERVAL_US)
        next_nlp = ticks_add(now, NLP_INTERVAL_US)
    elif ticks_diff(now, next_nlp) >= 0:
        sm.put(NLP)
        next_nlp = ticks_add(next_nlp, NLP_INTERVAL_US)
    sleep_us(100)
```

MicroPython は 1 語ずつ `put` するので、72 語を積む間に FIFO (8 語、6.4 µs) が空く恐れがある
(インタプリタの 1 行が数 µs)。空くとアイドル (00) が挟まってフレームが壊れる。壊れるなら
`array('I', words)` を作ってから `sm.put(words)` で一気に渡すか、C 版を使う。

## LTspice での確かめ

`sim/02-tx-link-pulse.cir` で、GP17 = 3.3 V・GP16 = 0 V (HIGH のシンボル) のときの線路の差動電圧を解いた。
GPIO は理想の電圧源 (内部抵抗 0)、相手は 100 Ω の終端 (トランスは理想)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 線路の差動電圧 | 1.70 V | 1.701 V | 合う |
| GPIO 1 本の電流 | 17 mA | 17.0 mA | 合う (12 mA 設定の上限を超えるので、実物は下がる) |
| R1・R2 を 100 Ω にしたとき | 1.10 V・11 mA | 1.100 V・11.0 mA | 合う |

リンクパルスの幅・間隔・フレームの長さはプログラムが決める数で、SPICE の対象外。

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| システムクロックと PIO の分周 | 120 MHz、分周 6 (20 MHz) | C: SDK のモック・MicroPython: `machine` のスタブ |
| PIO の命令と出力ピン | `out pins, 2` (0x6002)、GP16 から 2 本、右シフト・autopull 32 | 同上 |
| リンクパルスの語と間隔 | `0x0000000A`、16.0 ms ごと | 同上 (FIFO に積んだ語と時刻) |
| フレーム | 73 語 (72 バイト + TP_IDL)、1 s ごと。復号すると プリアンブル 7 + SFD、宛先 ff:…:ff、EtherType 0x0800、IP の検査和が合い、FCS が CRC-32 と一致 | 同上 (試験が語を逆変換して検める) |

見ていない物: 線路の電圧、ルータがリンクするか、PC に届くか。MicroPython の `put` の速さ。

## 出典

- [kingyoPiyo/Pico-10BASE-T](https://github.com/kingyoPiyo/Pico-10BASE-T) (MIT License) — Raspberry Pi Pico の PIO と抵抗 (47 Ω × 2) で 10BASE-T を送る実装。GP16 = TX−・GP17 = TX+、`0x0000000A` のリンクパルス、`0x00000AAA` の TP_IDL、120 MHz にする理由はここから。PIO の命令とフレームの組み立ては書き直した
- IEEE 802.3-2022 Clause 14 — 14.3.1.3.1 受信の振幅 (585 mV 以上を受ける)、14.2.1.1 リンクパルス、14.3.1.2.1 TP_IDL
- [RP2350 Datasheet](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) — GPIO の駆動電流の設定 (2/4/8/12 mA) と PIO (11 章)
