---
book: circuits
chapter: 9
id: 9-17
title: 2.4GHz モジュール (nRF24) と Pico
tier: 200
source: 自作
era: 今
board: BB
---

# 9-17 2.4GHz モジュール (nRF24) と Pico

9-4 の FM ワイヤレスマイクや 9-14 のトイラジコンは、発振・変調・検波を部品で組んだ。
今の定番は、それを 1 個のチップに収めた**無線モジュール**を**マイコンから SPI で操る**形だ。
ここでは Nordic の **nRF24L01+** を 2 枚の Raspberry Pi Pico に 1 枚ずつ付け、
片方がボタンの状態と通し番号を送り、もう片方がそれを受けて LED を点ける。

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
  ずっと大きい)。アンテナの付け替えや PA 付き品への改造もしない
- **電源は 3.3V**: nRF24L01+ の電源電圧は 1.9〜3.6V で、**5V を入れると壊れる**
  (信号の足は 5V に耐えるが、電源は耐えない)。Pico の **3V3 (PIN 36)** からとる
- **パスコン 10µF + 0.1µF をモジュールの VCC・GND の足のすぐ横に**: 送信の瞬間に
  電流が 0 から十数 mA へ跳ぶ。Pico の 3V3 から線が長いと電圧が一瞬へこみ、PLL が外れて
  「たまにしか届かない」「全く届かない」になる。**nRF24 のつまずきの 1 番目がこれ**で、
  定番の対策が電解 10µF とセラミック 0.1µF を足の根元に付けること
- **通信の仕組み**: 送る側は 1 パケットを出すと、受ける側から **ACK (受け取った印)** が
  返るのを待つ。来なければ自動で送り直す (ここでは最大 8 回)。だから送る側のプログラムは
  「届いたかどうか」を知っている

## 回路図

2 枚とも同じ配線で、違うのは GP15 の先 (ボタンか LED) だけ。

```circuit
title: 図1 送る側 (ボタンの状態を送る)
parts:
  U1: pico f3c0 mirror
  U2:
    type: device
    at: d12h0
    label: nRF24L01+
    pins: [VCC, SCK, MOSI, MISO, CSN, CE, IRQ, GND]
  C1: ecap a14 c14 10u
  C2: capacitor a16 c16 100n
  G1: ground c14
  G2: ground c16
  G3: ground g10
  G4: ground j1
  SW1: button k6 m6 l=$\mathrm{SW1}$
  G5: ground m6
wires:
  - U1.3V3 -| a1
  - a1 -- a10 -- a14 -- a16
  - a10 |- U2.VCC
  - U1.GP2 -| c8g0 |- U2.SCK
  - U1.GP3 -| d7a5 |- U2.MOSI
  - U1.GP4 -| d7e0 |- U2.MISO
  - U1.GP5 -| d6i5 |- U2.CSN
  - U1.GP6 -| e6g0 |- U2.CE
  - U2.GND -| g10
  - U1.GND23 -| j1
  - U1.GP15 -| k6
notes:
  - text b6 blue: "3.3V"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/17-nrf24-pico-1.svg)

```circuit
title: 図2 受ける側 (LED を点ける)
parts:
  U1: pico f3c0 mirror
  U2:
    type: device
    at: d12h0
    label: nRF24L01+
    pins: [VCC, SCK, MOSI, MISO, CSN, CE, IRQ, GND]
  C1: ecap a14 c14 10u
  C2: capacitor a16 c16 100n
  G1: ground c14
  G2: ground c16
  G3: ground g10
  G4: ground j1
  R1: resistor k6 m6 330
  D1: led m6 o6 red
  G5: ground o6
wires:
  - U1.3V3 -| a1
  - a1 -- a10 -- a14 -- a16
  - a10 |- U2.VCC
  - U1.GP2 -| c8g0 |- U2.SCK
  - U1.GP3 -| d7a5 |- U2.MOSI
  - U1.GP4 -| d7e0 |- U2.MISO
  - U1.GP5 -| d6i5 |- U2.CSN
  - U1.GP6 -| e6g0 |- U2.CE
  - U2.GND -| g10
  - U1.GND23 -| j1
  - U1.GP15 -| k6
notes:
  - text b6 blue: "3.3V"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/17-nrf24-pico-2.svg)

- **SPI0 を使う**: Pico の **GP2 = SCK (PIN 4)**、**GP3 = MOSI (SPI0 TX、PIN 5)**、
  **GP4 = MISO (SPI0 RX、PIN 6)**。**GP5 (PIN 7) = CSN** (SPI の選択、L で有効)、
  **GP6 (PIN 9) = CE** (送受信の開始、H で有効)。MicroPython の nrf24l01 の試験プログラムが
  Pico に使うのと同じ割り当て
- **nRF24L01+ モジュールの足** (2×4 のピンヘッダ、アンテナを上にして部品面から見る):
  PIN 1 GND、PIN 2 VCC、PIN 3 CE、PIN 4 CSN、PIN 5 SCK、PIN 6 MOSI、PIN 7 MISO、PIN 8 IRQ。
  図の箱は線を短くするため働きの順に並べた。IRQ (受信・送信完了で L) は使わない
  (ドライバが SPI で状態を読みに行く)
- **C1・C2** は図では右に寄せたが、実物では**モジュールの VCC・GND の足の根元**に付ける
- **SW1**: GP15 と GND の間。Pico の内蔵プルアップを使うので、押すと L (11-2 と同じ)
- **R1・D1**: GP15 が H で点く。電流は (3.3V − 2.0V) ÷ 330Ω ≈ **3.9mA** (計算値)

## 実体配線図

nRF24L01+ の 2×4 のピンヘッダはブレッドボードに挿せない (2 列が 2.54mm で並び、溝をまたげない) ので、
モジュールは板の外に置き、メスのジャンパ線で板へつなぐ。2 枚とも同じ並びで、違うのは GP15 の先だけ。

```breadboard
title: 図3 送る側をブレッドボードに組む
board: full
parts:
  MCU: pico @ h5
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
  MCU: pico @ h5
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

- Pico は溝をまたいで 5〜24 列に挿す (USB を左)。**3V3 (PIN 36、9 列)** から赤で上の + レールへ、
  **GND38 (7 列)** から黒で上の − レールへ。60・62 列で上下のレールを渡す (赤は + だけ、黒は GND だけ)
- SPI の 5 本は Pico の下側の足の列の j 行からモジュールへ: **8 列 GP2 → SCK (黄)**、
  **9 列 GP3 → MOSI (緑)**、**10 列 GP4 → MISO (青)**、**11 列 GP5 → CSN (橙)**、**13 列 GP6 → CE (白)**
- **40 列が 3.3V、43 列が GND の小さな島**。下の + レール・− レールから j 行へ短い線を立て、
  C1 (10µF、+ の足を 40 列) と C2 (0.1µF) をここに挿し、モジュールの VCC (赤)・GND (黒) もここへ
  つなぐ。パスコンからモジュールの足までは**ジャンパ線 1 本ぶん (10cm 以内)** にする。
  通信が不安定なら、C1・C2 をモジュールのピンヘッダの VCC・GND (PIN 2・PIN 1) に直接はんだ付けする
- 図3: SW1 は溝をまたいで 26・28 列。下側 (f 行側) の 26 列へ GP15 (24 列) から黄で渡し、上側の 28 列を
  黒で上の − レールへ。押すと上下がつながり GP15 が L になる
- 図4: GP15 (24 列) の i 行から R1 (330Ω) で 28 列へ、D1 は アノードを 28 列・カソードを 31 列に挿し、
  31 列を黒で下の − レールへ
- IRQ は使わないので挿さない
- 電源は Pico の USB (5V)。モジュールには Pico の 3V3 だけを入れる (VBUS・VSYS はつながない)

**ブレッドボードで組んでよい理由**: 2.4GHz の高周波は nRF24L01+ モジュールの中だけにあり、板を通るのは SPI (数 MHz 以下の遅い信号) と電源 (3.3V) とボタン・LED の直流だけ。板の上に高周波の回路は無い。電流は Pico とモジュールで 50mA 前後 (送信の瞬間に十数 mA)、板全体で 500mA を大きく下回る。

## プログラム

MicroPython の公式ライブラリ集 (micropython-lib) の **nrf24l01.py** を Pico に置いて使う。
2 枚が同じ RF_CH・同じ速さ・向かい合わせのアドレスにしないと、互いの電波が見えない。

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

- 出力は一番小さい **POWER_0 (−18dBm = 約 16µW)** にした。机の上の 2 枚なら十分届き、
  周りの無線 LAN を乱しにくい。ドライバの既定は 0dBm (1mW)
- **速さは 250kbps**。遅いほど受信の感度が良い。1 パケットは プリアンブル 1 バイト +
  アドレス 5 バイト + 制御 9 ビット + データ 8 バイト + CRC 2 バイト = **137 ビット**で、
  250kbps で **約 0.55ms** (計算値)。200ms ごとに送るので、電波が出ている時間は全体の 0.3% に満たない
- 初めに `NRF24L01(...)` が `OSError: nRF24L01+ Hardware not responding` を出したら、
  SPI の配線 (MOSI と MISO の取り違えが多い) か 3.3V を疑う。通信だけ時々失敗するなら
  パスコンを疑う

## 計器の設定

tinySA Ultra (0〜5.3GHz) で電波を見る。ふつうのパケットは 0.55ms で終わり、1 回の掃引では
点のようにしか映らないので、**送る側でパケットを 5ms ごとに送り続け、tinySA の MAX HOLD
(山を保持する表示) で重ねて**、周波数と強さを確かめる。モジュールはふつうの使い方
(技適の範囲) のまま動かし、試験用の特別な送り方はしない。**5 秒で止める**。送る側の Pico で
これだけ走らせる:

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
- 実際の山は 250kbps の GFSK で 1MHz 弱に広がるが、RBW 100kHz の画面では 1 本の山に見える。
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
| U1 | Raspberry Pi Pico × 2 | MicroPython を入れておく |
| U2 | nRF24L01+ モジュール × 2 | **技適マークと番号の付いたもの**。PCB アンテナの小型品 |
| C1 | 10µF 電解 × 2 | モジュールの VCC・GND の足のすぐ横 |
| C2 | 0.1µF セラミック × 2 | 同上 |
| SW1 | タクトスイッチ | 送る側 |
| R1 | 330Ω | 受ける側 |
| D1 | 赤色 LED | 受ける側 |
| 電源 | USB 5V → Pico の 3.3V | nRF24L01+ の電源が 1.9〜3.6V のため、Pico の 3V3 からとる |
| 計器 | tinySA Ultra | 図5 の確かめに |

## 出典

自作。nRF24L01+ の周波数・電源電圧・出力・レジスタは Nordic Semiconductor「nRF24L01+ Single Chip 2.4GHz Transceiver
Product Specification v1.0」による。ドライバと Pico の SPI の割り当ては
[micropython-lib の nrf24l01](https://github.com/micropython/micropython-lib/tree/master/micropython/drivers/radio/nrf24l01)
(nrf24l01.py、nrf24l01test.py) による。Pico の足の並びは Raspberry Pi「Raspberry Pi Pico Datasheet」による。
技適の番号の調べ方は総務省「技術基準適合証明等を受けた機器の検索」による。
