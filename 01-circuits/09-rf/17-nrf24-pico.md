---
book: circuits
chapter: 9
id: 9-17
title: 2.4GHz モジュール (nRF24) と Pico 2
tier: 200
source: 自作
era: 今
board: BB
---

# 9-17 2.4GHz モジュール (nRF24) と Pico 2

9-4 の FM ワイヤレスマイクや 9-14 のトイラジコンは、発振・変調・検波を部品で組んだ。
今の定番は、それを 1 個のチップに収めた**無線モジュール**を**マイコンから SPI で操る**形だ。
ここでは Nordic の **nRF24L01+** を 2 枚の Raspberry Pi Pico 2 (RP2350) に 1 枚ずつ付け、
片方がボタンの状態と通し番号を送り、もう片方がそれを受けて LED を点ける。

この題の流れは次のとおり。

- 下の箇条で、2.4GHz 帯・技適・電源・パスコン・通信の仕組みを先に押さえる
- 回路図 (図1 送る側、図2 受ける側) と実体配線図 (図3・図4)。2 枚の違いは GP15 の先だけ
- 「プログラム」で C/C++ と MicroPython の送る側・受ける側を示す
- 「計器の設定」で、パケットを送り続けて tinySA の MAX HOLD で電波の周波数と強さを見る (図5)

- **2.4GHz 帯 (ISM バンド)**: 2400〜2483.5MHz は産業・科学・医療 (ISM) 用に世界共通で
  空けてある帯で、無線 LAN・Bluetooth・電子レンジが同居する。nRF24L01+ の周波数は
  **2400MHz + RF_CH (0〜125)** で、1MHz 刻み。日本で使えるのは帯の中の **RF_CH 0〜83** まで。
  ここでは **RF_CH = 76 → 2476MHz** を使う。無線 LAN でよく使う 1・6・11ch
  (11ch は 2451〜2473MHz) の外側で、混信しにくい
- **技適**: 2.4GHz 帯の小電力データ通信は免許が要らない代わりに、**技術基準適合証明
  (技適) を受けた無線機**でなければ電波を出してはいけない (電波法)。**技適マークと番号が
  付いたモジュールを買う**。通販の安い互換品には技適の無いものが多く、日本で電波を出すと
  電波法違反になる。番号は総務省の「技術基準適合証明等を受けた機器の検索」で確かめられる。
  9-4 のような**微弱無線局の範囲には入らない** (2.4GHz の出力 −18〜0dBm は微弱の上限より
  ずっと大きい)。アンテナの付け替えや、PA (送信の電力増幅器) 付き品への改造もしない
- **電源は 3.3V**: nRF24L01+ の電源電圧は 1.9〜3.6V で、**5V を入れると壊れる**
  (信号のピンは 5V に耐えるが、電源は耐えない)。Pico 2 の **3V3 (PIN 36)** からとる (3V3 ピンは外部の回路へ最大 300mA 未満の目安、Pico 2 データシート)
- **パスコン 10µF + 0.1µF をモジュールの VCC・GND のピンのすぐ横に**: 送信の瞬間に
  電流が 0 から十数 mA へ跳ぶ。Pico 2 の 3V3 から線が長いと電圧が一瞬へこみ、PLL (送信の周波数を作る回路) が外れて
  「たまにしか届かない」「全く届かない」になる。**nRF24 のつまずきの 1 番目がこれ**で、
  定番の対策が電解 10µF とセラミック 0.1µF をピンの根元に付けること
- **通信の仕組み**: 送る側は 1 パケットを出すと、受ける側から **ACK (受け取った印)** が
  返るのを待つ。来なければ自動で送り直す (ここでは最大 8 回)。だから送る側のプログラムは
  「届いたかどうか」を知っている

## 回路図

2 枚とも同じ配線で、違うのは GP15 の先 (ボタンか LED) だけ。

```circuit
title: 図1 送る側 (ボタンの状態を送る)
parts:
  U1: pico2 3,6.2 mirror
  U2:
    type: device
    at: 12,4.7
    label: nRF24L01+
    pins: [VCC, SCK, MOSI, MISO, CSN, CE, IRQ, GND]
  C1: ecap 14,1 14,3 10u
  C2: capacitor 16,1 16,3 100n
  G1: ground 14,3
  G2: ground 16,3
  G3: ground 10,7
  G4: ground 1,10
  V3V3: vcc 1,3 3.3V
  V3V3: vcc 10,1 3.3V
  SW1: button 6,11 6,13 l=$\mathrm{SW1}$
  G5: ground 6,13
wires:
  - U1.3V3 -| 1,3
  - 10,1 -- 14,1 -- 16,1
  - 10,1 |- U2.VCC
  - U1.GP2 -| 8,3.6 |- U2.SCK
  - U1.GP3 -| 7.5,4 |- U2.MOSI
  - U1.GP4 -| 7,4.4 |- U2.MISO
  - U1.GP5 -| 6.5,4.8 |- U2.CSN
  - U1.GP6 -| 6,5.6 |- U2.CE
  - U2.GND -| 10,7
  - U1.GND23 -| 1,10
  - U1.GP15 -| 6,11
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/17-nrf24-pico-1.svg)

```circuit
title: 図2 受ける側 (LED を点ける)
parts:
  U1: pico2 3,6.2 mirror
  U2:
    type: device
    at: 12,4.7
    label: nRF24L01+
    pins: [VCC, SCK, MOSI, MISO, CSN, CE, IRQ, GND]
  C1: ecap 14,1 14,3 10u
  C2: capacitor 16,1 16,3 100n
  G1: ground 14,3
  G2: ground 16,3
  G3: ground 10,7
  G4: ground 1,10
  V3V3: vcc 1,3 3.3V
  V3V3: vcc 10,1 3.3V
  R1: resistor 6,11 6,13 330
  D1: led 6,13 6,15 red
  G5: ground 6,15
wires:
  - U1.3V3 -| 1,3
  - 10,1 -- 14,1 -- 16,1
  - 10,1 |- U2.VCC
  - U1.GP2 -| 8,3.6 |- U2.SCK
  - U1.GP3 -| 7.5,4 |- U2.MOSI
  - U1.GP4 -| 7,4.4 |- U2.MISO
  - U1.GP5 -| 6.5,4.8 |- U2.CSN
  - U1.GP6 -| 6,5.6 |- U2.CE
  - U2.GND -| 10,7
  - U1.GND23 -| 1,10
  - U1.GP15 -| 6,11
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/17-nrf24-pico-2.svg)

- **SPI0 を使う** (SPI は 9-16 で見た、クロックに合わせて 1 ビットずつ送る通信。MOSI はマイコン → モジュール、MISO はモジュール → マイコンの向き):
  Pico 2 の **GP2 = SCK (PIN 4)**、**GP3 = MOSI (SPI0 TX、PIN 5)**、
  **GP4 = MISO (SPI0 RX、PIN 6)**。**GP5 (PIN 7) = CSN** (SPI の選択、L で有効)、
  **GP6 (PIN 9) = CE** (送受信の開始、H で有効)。MicroPython の nrf24l01 の試験プログラムが
  Pico に使うのと同じ割り当て (Pico 2 もピンの並びは同じ)
- **nRF24L01+ モジュールのピン** (2×4 のピンヘッダ、アンテナを上にして部品面から見る):
  PIN 1 GND、PIN 2 VCC、PIN 3 CE、PIN 4 CSN、PIN 5 SCK、PIN 6 MOSI、PIN 7 MISO、PIN 8 IRQ。
  図の箱は線を短くするため働きの順に並べた。IRQ (受信・送信完了で L) は使わない
  (プログラムが SPI で状態を読みに行く)
- **C1・C2** は図では右に寄せたが、実物では**モジュールの VCC・GND のピンの根元**に付ける
- **SW1**: GP15 と GND の間。Pico の内蔵プルアップ (GP15 を中の抵抗で 3.3V へ引き上げておく働き) を使うので、
  離すと H、押すと L になる (ボタンとプルアップは 11-2 でくわしく扱う)
- **R1・D1**: GP15 が H で点く。電流は (3.3V − 2.0V) ÷ 330Ω ≈ **3.9mA** (計算値)

## 実体配線図

nRF24L01+ の 2×4 のピンヘッダはブレッドボードに挿せない (2 列が 2.54mm で並び、溝をまたげない) ので、
モジュールはブレッドボードの外に置き、メスのジャンパ線でブレッドボードへつなぐ。2 枚とも同じ並びで、違うのは GP15 の先だけ。

```breadboard
title: 図3 送る側をブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  RF:
    type: device
    at: bottom
    label: nRF24L01+ (技適付き)
    pins: [SCK, MOSI, MISO, CSN, CE, VCC, GND, IRQ]
  C1: capacitor/electrolytic f40 f43 10u
  C2: capacitor/ceramic h40 h43 100n
  SW1: button @ e26
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t62 -- +b62 red
  - -t60 -- -b60 black
  - RF.SCK -- j8 yellow
  - RF.MOSI -- j9 green
  - RF.MISO -- j10 blue
  - RF.CSN -- j11 orange
  - RF.CE -- j13 white
  - +b40 -- j40 red
  - -b43 -- j43 black
  - RF.VCC -- g40 red
  - RF.GND -- g43 black
  - i24 -- i26 yellow
  - -t28 -- a28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/17-nrf24-pico-1.svg)

```breadboard
title: 図4 受ける側をブレッドボードに組む
board: full
parts:
  MCU: pico2 @ h5
  RF:
    type: device
    at: bottom
    label: nRF24L01+ (技適付き)
    pins: [SCK, MOSI, MISO, CSN, CE, VCC, GND, IRQ]
  C1: capacitor/electrolytic f40 f43 10u
  C2: capacitor/ceramic h40 h43 100n
  R1: resistor i24 i28 330
  D1: led g28 g31
wires:
  - MCU.3V3 -- +t9 red
  - MCU.GND38 -- -t7 black
  - +t62 -- +b62 red
  - -t60 -- -b60 black
  - RF.SCK -- j8 yellow
  - RF.MOSI -- j9 green
  - RF.MISO -- j10 blue
  - RF.CSN -- j11 orange
  - RF.CE -- j13 white
  - +b40 -- j40 red
  - -b43 -- j43 black
  - RF.VCC -- g40 red
  - RF.GND -- g43 black
  - -b31 -- j31 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/17-nrf24-pico-2.svg)

- Pico 2 は溝をまたいで 5〜24 列に挿す (USB を左)。**3V3 (PIN 36、9 列)** から赤で上の + レールへ、
  **GND38 (7 列)** から黒で上の − レールへ。60・62 列で上下のレールを渡す (赤は + だけ、黒は GND だけ)
- SPI の 5 本は Pico 2 の下側のピンの列の j 行からモジュールへ: **8 列 GP2 → SCK (黄)**、
  **9 列 GP3 → MOSI (緑)**、**10 列 GP4 → MISO (青)**、**11 列 GP5 → CSN (橙)**、**13 列 GP6 → CE (白)**
- **40 列が 3.3V、43 列が GND の小さな島**。下の + レール・− レールから j 行へ短い線を立て、
  C1 (10µF、+ のピンを 40 列) と C2 (0.1µF) をここに挿し、モジュールの VCC (赤)・GND (黒) もここへ
  つなぐ。パスコンからモジュールのピンまでは**ジャンパ線 1 本ぶん (10cm 以内)** にする。
  通信が不安定なら、C1・C2 をモジュールのピンヘッダの VCC・GND (PIN 2・PIN 1) に直接はんだ付けする
- 図3: SW1 は溝をまたいで 26・28 列。下側 (f 行側) の 26 列へ GP15 (24 列) から黄で渡し、上側の 28 列を
  黒で上の − レールへ。押すと上下がつながり GP15 が L になる
- 図4: GP15 (24 列) の i 行から R1 (330Ω) で 28 列へ、D1 は アノードを 28 列・カソードを 31 列に挿し、
  31 列を黒で下の − レールへ
- IRQ は使わないので挿さない
- 電源は Pico 2 の USB (5V)。モジュールには Pico 2 の 3V3 だけを入れる (VBUS・VSYS はつながない)

**ブレッドボードで組んでよい理由**: 2.4GHz の高周波は nRF24L01+ モジュールの中だけにあり、ブレッドボードを通るのは SPI (数 MHz 以下の遅い信号) と電源 (3.3V) とボタン・LED の直流だけ。ブレッドボードの上に高周波の回路は無い。電流は Pico 2 とモジュールで 50mA 前後 (送信の瞬間に十数 mA)、ブレッドボード全体で 500mA を大きく下回る。

## プログラム

プログラムは **C/C++ (Pico SDK) を第 1、MicroPython を第 2** として並べる。
C/C++ を先にするのは、この教科書の標準がそうだからで、レジスタの番地と命令のバイトが
コードにそのまま並び、データシートの表と 1 行ずつ突き合わせられるため。どちらも同じ動きをする。
2 枚が同じ RF_CH・同じ速さ・向かい合わせのアドレスにしないと、互いの電波が見えない。

### C/C++ (Pico SDK)

外部のライブラリは使わず、SPI0 で nRF24L01+ を操る最小のコードを `nrf24.h` にまとめた。
命令 (`R_REGISTER` = 0x00、`W_REGISTER` = 0x20、`W_TX_PAYLOAD` = 0xA0 など) とレジスタの番地・ビットは
nRF24L01+ データシートの表 20 (命令) と表 28 (レジスタ) と突き合わせてある。
手順は MicroPython の nrf24l01.py と同じ (SPI は 4MHz のモード 0、送る前に電源を入れて 1.5ms 待ち、
CE を 15µs だけ H にする)。

```c
// nrf24.h: nRF24L01+ を SPI0 で操る最小のコード (micropython-lib の nrf24l01.py と同じ手順)
#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"

#define PIN_SCK  2
#define PIN_MOSI 3
#define PIN_MISO 4
#define PIN_CSN  5
#define PIN_CE   6
#define PAYLOAD  8                       // 1 パケットのデータのバイト数

// SPI コマンド (データシート 表 20) とレジスタ (表 28)
#define R_REGISTER    0x00
#define W_REGISTER    0x20
#define R_RX_PAYLOAD  0x61
#define W_TX_PAYLOAD  0xA0
#define FLUSH_TX      0xE1
#define FLUSH_RX      0xE2
#define NOP           0xFF
#define REG_CONFIG      0x00
#define REG_EN_RXADDR   0x02
#define REG_SETUP_AW    0x03
#define REG_SETUP_RETR  0x04
#define REG_RF_CH       0x05
#define REG_RF_SETUP    0x06
#define REG_STATUS      0x07
#define REG_RX_ADDR_P0  0x0A
#define REG_RX_ADDR_P1  0x0B
#define REG_TX_ADDR     0x10
#define REG_RX_PW_P0    0x11
#define REG_RX_PW_P1    0x12
#define REG_FIFO_STATUS 0x17
#define REG_DYNPD       0x1C
#define EN_CRC   (1u << 3)               // CONFIG のビット
#define CRCO     (1u << 2)               // 1 = CRC 2 バイト
#define PWR_UP   (1u << 1)
#define PRIM_RX  (1u << 0)
#define RX_DR    (1u << 6)               // STATUS のビット (1 を書くと消える)
#define TX_DS    (1u << 5)
#define MAX_RT   (1u << 4)
#define RX_EMPTY (1u << 0)               // FIFO_STATUS のビット
#define RF_DR_250K  0x20                 // RF_SETUP: [RF_DR_LOW, RF_DR_HIGH] = 10
#define RF_PWR_M18  0x00                 // RF_SETUP: RF_PWR = 00 (-18dBm)

// CSN を L にして 1 命令ぶん送り、STATUS (最初に返る 1 バイト) を返す
static uint8_t nrf_cmd(uint8_t cmd, const uint8_t *tx, uint8_t *rx, size_t n) {
    uint8_t status;
    gpio_put(PIN_CSN, 0);
    spi_write_read_blocking(spi0, &cmd, &status, 1);
    if (n) {
        if (rx) spi_read_blocking(spi0, 0xFF, rx, n);
        else    spi_write_blocking(spi0, tx, n);
    }
    gpio_put(PIN_CSN, 1);
    return status;
}
static uint8_t reg_read(uint8_t reg) {
    uint8_t v;
    nrf_cmd(R_REGISTER | reg, NULL, &v, 1);
    return v;
}
static void reg_write(uint8_t reg, uint8_t v) { nrf_cmd(W_REGISTER | reg, &v, NULL, 1); }
static void reg_write5(uint8_t reg, const uint8_t addr[5]) { nrf_cmd(W_REGISTER | reg, addr, NULL, 5); }
static uint8_t nrf_status(void) { return nrf_cmd(NOP, NULL, NULL, 0); }

// SPI0 と CSN・CE を用意し、RF_CH・250kbps・-18dBm・CRC 2 バイトに設定する。応答が無ければ false
static bool nrf_init(uint8_t channel) {
    spi_init(spi0, 4 * 1000 * 1000);     // 既定はモード 0 (CPOL = 0, CPHA = 0)、8 ビット
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_init(PIN_CSN); gpio_set_dir(PIN_CSN, GPIO_OUT); gpio_put(PIN_CSN, 1);
    gpio_init(PIN_CE);  gpio_set_dir(PIN_CE, GPIO_OUT);  gpio_put(PIN_CE, 0);
    sleep_ms(5);
    reg_write(REG_SETUP_AW, 0x03);       // アドレスは 5 バイト
    if (reg_read(REG_SETUP_AW) != 0x03) return false;
    reg_write(REG_DYNPD, 0);             // データの長さは固定 (PAYLOAD バイト)
    reg_write(REG_SETUP_RETR, (6 << 4) | 8);   // 待ち 1750us、最大 8 回送り直す
    reg_write(REG_RF_SETUP, RF_DR_250K | RF_PWR_M18);
    reg_write(REG_CONFIG, EN_CRC | CRCO);
    reg_write(REG_STATUS, RX_DR | TX_DS | MAX_RT);
    reg_write(REG_RF_CH, channel);       // 周波数 = 2400MHz + RF_CH
    nrf_cmd(FLUSH_RX, NULL, NULL, 0);
    nrf_cmd(FLUSH_TX, NULL, NULL, 0);
    return true;
}

static void nrf_open_tx_pipe(const uint8_t addr[5]) {   // 送り先。ACK は同じアドレスの P0 で受ける
    reg_write5(REG_RX_ADDR_P0, addr);
    reg_write5(REG_TX_ADDR, addr);
    reg_write(REG_RX_PW_P0, PAYLOAD);
}
static void nrf_open_rx_pipe1(const uint8_t addr[5]) {  // 受ける宛先 (P1)
    reg_write5(REG_RX_ADDR_P1, addr);
    reg_write(REG_RX_PW_P1, PAYLOAD);
    reg_write(REG_EN_RXADDR, reg_read(REG_EN_RXADDR) | (1u << 1));
}

// 1 パケット送る。ACK が返れば true、8 回送り直しても返らなければ false
static bool nrf_send(const uint8_t buf[PAYLOAD]) {
    reg_write(REG_CONFIG, (reg_read(REG_CONFIG) | PWR_UP) & ~PRIM_RX);
    sleep_us(1500);                      // 電源を入れてから 1.5ms 待つ
    nrf_cmd(W_TX_PAYLOAD, buf, NULL, PAYLOAD);
    gpio_put(PIN_CE, 1);
    sleep_us(15);                        // CE を 10us 以上 H にする
    gpio_put(PIN_CE, 0);
    absolute_time_t limit = make_timeout_time_ms(500);
    uint8_t st;
    while (!((st = nrf_status()) & (TX_DS | MAX_RT))) {
        if (absolute_time_diff_us(get_absolute_time(), limit) < 0) {
            nrf_cmd(FLUSH_TX, NULL, NULL, 0);
            reg_write(REG_CONFIG, reg_read(REG_CONFIG) & ~PWR_UP);
            return false;
        }
    }
    reg_write(REG_STATUS, RX_DR | TX_DS | MAX_RT);
    reg_write(REG_CONFIG, reg_read(REG_CONFIG) & ~PWR_UP);
    return st & TX_DS;
}

static void nrf_start_listening(void) {
    reg_write(REG_CONFIG, reg_read(REG_CONFIG) | PWR_UP | PRIM_RX);
    reg_write(REG_STATUS, RX_DR | TX_DS | MAX_RT);
    nrf_cmd(FLUSH_RX, NULL, NULL, 0);
    nrf_cmd(FLUSH_TX, NULL, NULL, 0);
    gpio_put(PIN_CE, 1);
    sleep_us(130);
}
static bool nrf_any(void) { return !(reg_read(REG_FIFO_STATUS) & RX_EMPTY); }
static void nrf_recv(uint8_t buf[PAYLOAD]) {
    nrf_cmd(R_RX_PAYLOAD, NULL, buf, PAYLOAD);
    reg_write(REG_STATUS, RX_DR);
}
```

送る側 (図1) の `nrf_tx.c`。

```c
#include <stdio.h>
#include "nrf24.h"

int main(void) {
    stdio_init_all();
    if (!nrf_init(76)) {
        while (true) { printf("nRF24L01+ Hardware not responding\n"); sleep_ms(1000); }
    }
    nrf_open_tx_pipe((const uint8_t[]){0xE1, 0xF0, 0xF0, 0xF0, 0xF0});
    nrf_open_rx_pipe1((const uint8_t[]){0xD2, 0xF0, 0xF0, 0xF0, 0xF0});

    gpio_init(15);
    gpio_set_dir(15, GPIO_IN);
    gpio_pull_up(15);

    int32_t count = 0;
    while (true) {
        int32_t data[2] = {count, !gpio_get(15)};        // 通し番号と、押しているとき 1
        uint8_t buf[PAYLOAD];
        memcpy(buf, data, sizeof buf);                   // Pico はリトルエンディアン
        if (nrf_send(buf)) printf("sent %ld %ld\n", (long)data[0], (long)data[1]);
        else               printf("no ACK\n");           // 8 回送り直しても届かなかった
        count++;
        sleep_ms(200);
    }
}
```

受ける側 (図2) の `nrf_rx.c`。

```c
#include <stdio.h>
#include "nrf24.h"

int main(void) {
    stdio_init_all();
    if (!nrf_init(76)) {
        while (true) { printf("nRF24L01+ Hardware not responding\n"); sleep_ms(1000); }
    }
    nrf_open_tx_pipe((const uint8_t[]){0xD2, 0xF0, 0xF0, 0xF0, 0xF0});
    nrf_open_rx_pipe1((const uint8_t[]){0xE1, 0xF0, 0xF0, 0xF0, 0xF0});
    nrf_start_listening();

    gpio_init(15);
    gpio_set_dir(15, GPIO_OUT);
    gpio_put(15, 0);

    while (true) {
        if (nrf_any()) {
            uint8_t buf[PAYLOAD];
            int32_t data[2];
            nrf_recv(buf);
            memcpy(data, buf, sizeof data);
            gpio_put(15, data[1] != 0);
            printf("recv %ld %ld\n", (long)data[0], (long)data[1]);
        }
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と
`CMakeLists.txt` を置く。送る側の例を示す。受ける側は `nrf_tx` を `nrf_rx` に替える。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(nrf_tx C CXX ASM)
pico_sdk_init()
add_executable(nrf_tx nrf_tx.c)
target_link_libraries(nrf_tx pico_stdlib hardware_spi)
pico_enable_stdio_usb(nrf_tx 1)
pico_add_extra_outputs(nrf_tx)
```

環境変数 `PICO_SDK_PATH` に SDK のフォルダを指しておき、次でビルドする。

```sh
cmake -B build -DPICO_BOARD=pico2
cmake --build build
```

`build/nrf_tx.uf2` ができる。**BOOTSEL ボタンを押しながら USB をつなぐ**と Pico 2 が
USB ドライブ (ボリューム名は既定で `RP2350`) として見えるので、`.uf2` をそこへコピーする。
`PICO_BOARD=pico2` を付け忘れると Pico (RP2040) 用になり、Pico 2 では動かない。
`sent` や `recv` の表示は USB のシリアルに出るので、ターミナルソフトで見る。

### MicroPython

Pico 2 用の MicroPython (ダウンロードページ `RPI_PICO2`、Pico 用とは別のファイル) の
`.uf2` を BOOTSEL でつないだドライブへコピーする。さらに MicroPython の公式ライブラリ集
(micropython-lib) の **nrf24l01.py** を Pico 2 に置き、Thonny で「MicroPython (Raspberry Pi Pico)」を選んで実行する。

送る側 (図1):

```python
import struct, time
from machine import Pin, SPI
from nrf24l01 import NRF24L01, POWER_0, SPEED_250K

spi = SPI(0, sck=Pin(2), mosi=Pin(3), miso=Pin(4))
csn = Pin(5, Pin.OUT, value=1)
ce = Pin(6, Pin.OUT, value=0)
nrf = NRF24L01(spi, csn, ce, channel=76, payload_size=8)
nrf.set_power_speed(POWER_0, SPEED_250K)     # -18dBm, 250kbps
nrf.open_tx_pipe(b"\xe1\xf0\xf0\xf0\xf0")
nrf.open_rx_pipe(1, b"\xd2\xf0\xf0\xf0\xf0")
nrf.stop_listening()

btn = Pin(15, Pin.IN, Pin.PULL_UP)
count = 0
while True:
    pressed = 1 if btn.value() == 0 else 0
    try:
        nrf.send(struct.pack("ii", count, pressed))
        print("sent", count, pressed)
    except OSError:
        print("no ACK")                      # 8 回送り直しても届かなかった
    count += 1
    time.sleep_ms(200)
```

受ける側 (図2):

```python
import struct
from machine import Pin, SPI
from nrf24l01 import NRF24L01, POWER_0, SPEED_250K

spi = SPI(0, sck=Pin(2), mosi=Pin(3), miso=Pin(4))
csn = Pin(5, Pin.OUT, value=1)
ce = Pin(6, Pin.OUT, value=0)
nrf = NRF24L01(spi, csn, ce, channel=76, payload_size=8)
nrf.set_power_speed(POWER_0, SPEED_250K)
nrf.open_tx_pipe(b"\xd2\xf0\xf0\xf0\xf0")
nrf.open_rx_pipe(1, b"\xe1\xf0\xf0\xf0\xf0")
nrf.start_listening()

led = Pin(15, Pin.OUT, value=0)
while True:
    if nrf.any():
        count, pressed = struct.unpack("ii", nrf.recv())
        led.value(pressed)
        print("recv", count, pressed)
```

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが
通ることを確かめた (`nrf_tx`・`nrf_rx`・下の `nrf_burst`)。**実機では動かしていない**
(nRF24L01+ とつないだ動作は未確認)。MicroPython も実行していない (未確認)。

- 出力は一番小さい **POWER_0 (−18dBm = 約 16µW)** にした。机の上の 2 枚なら十分届き、
  周りの無線 LAN を乱しにくい。MicroPython のドライバの既定は 0dBm (1mW) で、C のコードは RF_SETUP に −18dBm を直接書く
- **速さは 250kbps**。遅いほど受信の感度が良い。1 パケットは プリアンブル 1 バイト (受ける側が同期を取る頭の印) +
  アドレス 5 バイト + 制御 9 ビット + データ 8 バイト + CRC 2 バイト (誤りを見つける検査の符号) = **137 ビット**
  (8 + 40 + 9 + 64 + 16) で、
  250kbps で **約 0.55ms** (計算値)。200ms ごとに送るので、電波が出ている時間は全体の 0.3% に満たない
- 初めに `nrf_init()` が false を返し `nRF24L01+ Hardware not responding` と表示したら
  (MicroPython では `NRF24L01(...)` が同じ文の `OSError` を出す)、
  SPI の配線 (MOSI と MISO の取り違えが多い) か 3.3V を疑う。通信だけ時々失敗するなら
  パスコンを疑う

## 計器の設定

tinySA Ultra (ULTRA モード、最大 6GHz。2476MHz は通常モードの上限 800MHz を超える) で電波を見る。ふつうのパケットは 0.55ms で終わり、1 回の掃引では
点のようにしか映らないので、**送る側でパケットを 5ms ごとに送り続け、tinySA の MAX HOLD
(山を保持する表示) で重ねて**、周波数と強さを確かめる。モジュールはふつうの使い方
(技適の範囲) のまま動かし、試験用の特別な送り方はしない。**5 秒で止める**。送る側の Pico で
これだけ走らせる (C/C++ は `nrf24.h` と同じフォルダに `nrf_burst.c` を置き、上の `CMakeLists.txt` の名前を替えてビルドする)。

### C/C++ (Pico SDK)

```c
#include "nrf24.h"

int main(void) {
    if (!nrf_init(76)) return 1;
    nrf_open_tx_pipe((const uint8_t[]){0xE1, 0xF0, 0xF0, 0xF0, 0xF0});

    absolute_time_t end = make_timeout_time_ms(5000);   // 5 秒で止める
    int32_t n = 0;
    while (absolute_time_diff_us(get_absolute_time(), end) > 0) {
        int32_t data[2] = {n++, 0};
        uint8_t buf[PAYLOAD];
        memcpy(buf, data, sizeof buf);
        nrf_send(buf);                                  // 受ける側が居なくても送り続ける
        sleep_ms(5);
    }
    while (true) tight_loop_contents();
}
```

### MicroPython

```python
import time, struct
from machine import Pin, SPI
from nrf24l01 import NRF24L01, POWER_0, SPEED_250K

spi = SPI(0, sck=Pin(2), mosi=Pin(3), miso=Pin(4))
nrf = NRF24L01(spi, Pin(5, Pin.OUT, value=1), Pin(6, Pin.OUT, value=0), channel=76, payload_size=8)
nrf.set_power_speed(POWER_0, SPEED_250K)   # -18dBm・250kbps
nrf.open_tx_pipe(b"\xe1\xf0\xf0\xf0\xf0")
t0 = time.ticks_ms()
n = 0
while time.ticks_diff(time.ticks_ms(), t0) < 5000:   # 5 秒で止める
    try:
        nrf.send(struct.pack("ii", n, 0))
    except OSError:
        pass                     # 受ける側が居なくても送り続ける
    n += 1
    time.sleep_ms(5)
```

受ける側が居ないと、1 回の送信は 8 回の送り直しが終わるまで続き、約 19ms かかる
(9 回 × 0.55ms + 8 回 × 待ち 1.75ms の計算値)。5ms ごとに送れるのは受ける側が ACK を返すときで、
居ないときは 1 周期が 25ms ほどに伸びる。電波は出ているので MAX HOLD の山は同じ場所に積み上がる。

| 項目 | 設定 |
| --- | --- |
| 中心 / 幅 | 2476MHz / 10MHz |
| RBW | 100kHz |
| 点数 | 450 |
| REF | −20dBm |
| アンテナ | tinySA Ultra 付属のアンテナ。モジュールから 30cm 離す |
| 表示 | MAX HOLD (5 秒送る間に山を積み上げる) |
| マーカー | peak |

```spectrum
title: 図5 RF_CH 76 のパケットを MAX HOLD で重ねる (30cm 先)
device: tinysa-ultra
center: 2476MHz
span: 10MHz
points: 450
rbw: 100kHz
ref: -20dBm
signal: sine 2476MHz -48dBm
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/17-nrf24-pico.svg)

- 山の位置は **2400 + 76 = 2476MHz**。RF_CH を 1 変えると 1MHz 動く
- 高さの目安は、出力 −18dBm から 30cm の自由空間の損失を引いたもの。波長は
  3×10⁸ ÷ 2476MHz = 12.1cm、損失は 20 log₁₀(4π × 0.3m ÷ 0.121m) ≈ **29.9dB**、
  両方のアンテナの利得を 0dBi と仮定して **−18 − 29.9 ≈ −48dBm** (目安)。
  実際はアンテナの向き・机や手の反射で ±10dB くらいは動く
- 実際の山は 250kbps の GFSK (周波数をずらして 0 と 1 を送る変調) で 1MHz 弱に広がるが、RBW 100kHz の画面では 1 本の山に見える。
  無線 LAN の広い山 (20MHz 幅) が並んで見えることもある

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 受ける側の LED | SW1 を押している間だけ点く |
| 送る側の表示 | `sent 0 0`、`sent 1 0` … と 200ms ごと。受ける側の電源を切ると `no ACK` |
| 受ける側の表示 | 送る側と同じ通し番号が抜けずに並ぶ |
| D1 の電流 | 約 3.9mA (計算値) |
| 1 パケットの長さ | 137 ビット、250kbps で約 0.55ms (計算値) |
| tinySA の山の周波数 | 2.476GHz (2400MHz + RF_CH 76) |
| tinySA の山の高さ | 約 −48dBm (−18dBm、30cm、目安) |
| パスコン C1・C2 を外す | 通信が途切れる・`no ACK` が増える (個体と配線の長さによる) |

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico 2 × 2 | C/C++ の `.uf2` か MicroPython を書き込む |
| U2 | nRF24L01+ モジュール × 2 | **技適マークと番号の付いたもの**。PCB アンテナの小型品 |
| C1 | 10µF 電解 × 2 | モジュールの VCC・GND のピンのすぐ横 |
| C2 | 0.1µF セラミック × 2 | 同上 |
| SW1 | タクトスイッチ | 送る側 |
| R1 | 330Ω | 受ける側 |
| D1 | 赤色 LED | 受ける側 |
| 電源 | USB 5V → Pico 2 の 3.3V | nRF24L01+ の電源が 1.9〜3.6V のため、Pico 2 の 3V3 からとる |
| 計器 | tinySA Ultra ZS405 | 図5 の確かめに |

## 出典

自作。nRF24L01+ の周波数・電源電圧・出力・レジスタの番地とビット・SPI の命令は Nordic Semiconductor「nRF24L01+ Single Chip 2.4GHz Transceiver
Product Specification v1.0」(表 20・表 28) による。C/C++ のコードは、その手順を
[micropython-lib の nrf24l01](https://github.com/micropython/micropython-lib/tree/master/micropython/drivers/radio/nrf24l01) と
突き合わせて書いた。MicroPython のドライバと Pico の SPI の割り当ては
micropython-lib の nrf24l01 (nrf24l01.py、nrf24l01test.py) による。Pico 2 のピンの並びと 3V3 ピンの電流は Raspberry Pi「Raspberry Pi Pico 2 Datasheet」による。
技適の番号の調べ方は総務省「技術基準適合証明等を受けた機器の検索」による。
