---
book: circuits
chapter: 9
id: 9-16
title: DDS / SDR モジュール
tier: 200
source: 自作
board: BB
era: 今
---

# 9-16 DDS / SDR モジュール

**DDS (Direct Digital Synthesis、直接デジタル合成)** は、クロックごとに位相を足し込み、
その位相で正弦の表を引いて DAC から出す発振器だ。9-4 や 9-6 の LC 発振器は
コイルとコンデンサで周波数が決まり、温度や手の近さでずれたが、DDS は
**マイコンから数値を書くだけで周波数が決まり、水晶の精度で止まる**。
ここでは定番の **AD9833 モジュール** (25MHz の水晶発振器と AD9833 を載せた小基板) を
Raspberry Pi Pico から SPI で 7.000MHz に設定し、その出力を
**RTL-SDR** (テレビ用チューナー IC を使った USB の受信機、SDR = ソフトウェア無線) で
PC の画面に出す。送る側も受ける側も「モジュール + ソフト」で組む、今のラジオ工作の形だ。

> [!WARNING]
> この題は**電波を出さない**。DDS の出力は減衰器を通して**同軸ケーブルで直接** SDR に入れる。
> 7MHz はアマチュア無線の帯で、アンテナをつないで出すのは免許が要る。
> 日本の電波法で免許の要らない微弱無線局は、322MHz 以下なら**距離 3m で 500µV/m 以下**
> (電波法施行規則第 6 条)。ケーブルでつなぐかぎり、この範囲の心配はいらない。

**DDS の周波数の決まり方。**

AD9833 の中には 28 bit の**位相アキュムレータ**がある。MCLK (ここでは 25MHz) の
1 クロックごとに周波数レジスタの値 FREQREG を足し、あふれたら 1 周期。だから

f<sub>out</sub> = FREQREG × f<sub>MCLK</sub> ÷ 2<sup>28</sup>

- **分解能** = 25MHz ÷ 2<sup>28</sup> **≈ 0.093Hz** (計算値)。この細かさで周波数を選べる
- 7.000MHz なら FREQREG = 7MHz × 2<sup>28</sup> ÷ 25MHz = 75161927.68 → 整数に丸めて
  **75161928 (0x47AE148)**。実際に出るのは **7,000,000.03Hz** (計算値)
- 28 bit は SPI の 16 bit の語 2 つに 14 bit ずつ分けて書く。
  下位 = 0x2148、上位 = 0x11EB で、どちらにも FREQ0 を指す印 0x4000 を足して
  **0x6148 と 0x51EB** を送る

**DDS の出力に出る「像」。**

DAC は 1 クロックの間、同じ値を保つ (ゼロ次ホールド)。このため出力には f<sub>out</sub> の
ほかに、クロックの周りに**像 (イメージ)** f<sub>MCLK</sub> ± f<sub>out</sub>、2f<sub>MCLK</sub> ± f<sub>out</sub> … が出る。
大きさは sinc 関数 |sin(πf/f<sub>MCLK</sub>) ÷ (πf/f<sub>MCLK</sub>)| で決まる (計算値、低い周波数の振幅を 0dB として)。

| 周波数 | 何か | sinc による大きさ |
| --- | --- | --- |
| 7MHz | 目的の正弦 | −1.2dB |
| 18MHz (25 − 7) | 1 つ目の像 | −9.4dB |
| 32MHz (25 + 7) | 2 つ目の像 | −14.4dB |
| 43MHz (50 − 7) | 3 つ目の像 | −16.9dB |

f<sub>out</sub> が MCLK の半分 (12.5MHz) に近づくほど、像が目的の周波数に寄ってきて
区別しにくくなる。**実用になるのは MCLK の 1/3〜1/4 くらいまで** (目安)。
7MHz は MCLK の 0.28 倍で、1 つ目の像は目的の波のわずか 8.2dB 下にある。
安い AD9833 モジュールの多くは出力に LC の低域フィルタを持たないので、
**受信機に入れる前に像があることを知っておく**のがこの題の要点の 1 つ。
波形をきれいにしたいなら、出力に 10MHz 程度の LC 低域フィルタ を入れる。

## 回路図

```circuit
title: 図1 PicoでAD9833を7MHzに設定しRTL-SDRで受ける
parts:
  U1: pico k3 mirror
  U2:
    type: device
    at: i11
    label: AD9833
    pins: [VCC, SCLK, SDATA, FSYNC, DGND, AGND, OUT]
  G1: ground l8a5
  AT:
    type: ic3
    at: m14
    label: SMA 40dB
    pins: [IN, GND, OUT]
  GAT: ground o14
  U3:
    type: device
    at: m24c0
    label: RTL-SDR
    pins: [RF, GND]
  GU3: ground o23
wires:
  - U1.3V3 -| f1
  - f1 -- f7
  - f7 |- U2.VCC
  - U1.GP2 -| h7d5 |- U2.SCLK
  - U1.GP3 -| h6h5 |- U2.SDATA
  - U1.GP5 -| i5d5 |- U2.FSYNC
  - U1.GND8 -| j8a5
  - U2.DGND -| j8a5
  - U2.AGND -| j8a5
  - j8a5 -- l8a5
  - U2.OUT |- AT.IN
  - AT.OUT -- U3.RF
  - AT.GND -- o14
  - U3.GND -| o23
notes:
  - text k17f0 blue: 板の外 (SMAの減衰器 40dB)
  - text e4f0 blue: 3.3V (Picoの3V3 OUT)
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/16-dds-sdr-module.svg)

- **U2 (AD9833 モジュール)** は 2.3〜5.5V で動く。ここでは Pico の **3V3 OUT (PIN 36)** から
  3.3V を取る。Pico の GPIO も 3.3V なので、信号の電圧がそのまま合う。
  Pico 本体は PC の USB から給電する (5V を使わない理由はこれ)
- **SPI0** を使う: **SCLK = GP2 (PIN 4)**、**SDATA = GP3 (PIN 5、SPI0 TX)**、
  **FSYNC = GP5 (PIN 7)**。FSYNC は AD9833 のチップセレクトにあたり、L の間だけ 16 bit の語を受け取る。
  GND は Pico の **GND (PIN 8)** からモジュールの DGND・AGND へ
- AD9833 は SCLK の**立ち下がり**でデータを読み、SCLK は H で待つ (SPI のモード 2、
  CPOL = 1・CPHA = 0)。MicroPython では `polarity=1, phase=0` と書く
- **出力 OUT** は 0.038V〜0.65V を振れる正弦 (約 0.6Vpp、中心 約 0.34V。データシートの値)。
  チップの中の 200Ω を通して出てくるので、**開放 0.6Vpp・出力抵抗 200Ω の源**とみなす。
  直流分 (中心 約 0.34V) は、減衰器と SDR の入力を通しても支障がない
- **AT は市販の SMA 型 40dB 減衰器** (板の外の部品。20dB のものを 2 個つないでもよい)。
  RTL-SDR の入力は強い信号で飽和するので (目安 −30dBm 以上)、DDS の出力をそのまま入れない。
  U2 の OUT から AT へは短い SMA 変換ケーブルで、AT の出口は U3 の SMA へ直接つなぐ。
  GND は同軸の外皮
- **レベルの計算** (計算値): 減衰器 (AT) の入力は約 50Ω なので、0.3V peak の源を 200Ω と 50Ω で分けて
  0.060V peak = **−14.4dBm**。7MHz は sinc で −1.2dB 下がって −15.6dBm。
  減衰器を通って U3 の入力で **−55.2dBm**
  (公称 40dB ちょうどなら −55.6dBm。市販品の誤差は ±1dB ほどあるので、図と表は −55.2dBm のまま、
  読みが 1dB ほどずれても像の比は変わらない)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  U1: pico @ h2
  U2:
    type: device
    at: bottom
    label: AD9833モジュール
    pins: [SCLK, SDATA, FSYNC, DGND, AGND, VCC, OUT]
  AT:
    type: device
    at: bottom
    label: SMA 40dB減衰器 (板の外)
    pins: [IN, GND, OUT]
  U3:
    type: device
    at: bottom
    label: RTL-SDR (SMA入力)
    pins: [RF, GND]
wires:
  - a6 -- +t6 red
  - a4 -- -t4 black
  - j9 -- -b9 black
  - +t23 -- +b23 red
  - -t27 -- -b27 black
  - U2.SCLK -- j5 yellow
  - U2.SDATA -- j6 green
  - U2.FSYNC -- j8 blue
  - U2.DGND -- -b10 black
  - U2.AGND -- -b11 black
  - U2.VCC -- +b12 red
  - U2.OUT -- AT.IN orange
  - AT.OUT -- U3.RF orange
  - AT.GND -- -b20 black
  - U3.GND -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/16-dds-sdr-module.svg)

- ブレッドボードは **half (30 列)**。Pico と数本の線だけなので、収まる最小の板にした
- U1 (Pico) は h2 に挿す。上の列 (c 行) が PIN 40〜21、下の列 (h 行) が PIN 1〜20
- **上の赤レール = 3.3V**。Pico の **3V3 (PIN 36、6 列)** から a6 → 上の + レールへ赤線を引き、
  23 列で下の + レールへ渡す。**AD9833 モジュールはこの 3.3V で動く** (5V は使わない)
- 青レール = GND。GND38 (4 列) を上の − レールへ、GND8 (9 列) を下の − レールへ。27 列で上下の − レールを渡している
- U2 (AD9833 モジュール) は板の外に置き、ジャンパ線で SCLK → j5 (GP2)、SDATA → j6 (GP3)、
  FSYNC → j8 (GP5)、VCC → 下の + レール (12 列)、DGND・AGND → 下の − レール (10・11 列)。
  図の足の並びは線が交わらない順にした。実物のピンヘッダの並びは基板の印字で確かめる
- U2 の OUT は板に挿さず、**板の外で** SMA の 40dB 減衰器 (AT) の IN へ、AT の OUT は U3 (RTL-SDR) の
  SMA へつなぐ (図では橙の線)。板の上には 7MHz の線も部品もない。AT と U3 の GND は同軸の外皮で、便宜上、
  下の − レール (20・28 列) にも寄せてある (回路図の GND と同じ節)

**ブレッドボードで組んでよい理由。** 7MHz は AD9833 モジュールの**中**で作られ、
板の外の SMA 減衰器を通って SDR に入る。板を通るのは Pico とモジュールの間の
SPI (1MHz) と 3.3V の電源だけで、板の上の回路は 3MHz 以下に収まる。電流もモジュールと
Pico を合わせて数十 mA で、板全体の 500mA にも遠く及ばない。

## 計器の設定

**プログラム (MicroPython)**。Pico に書き、実行すると 7.000MHz を出し続ける。

```python
from machine import Pin, SPI

MCLK = 25_000_000                 # モジュールの水晶発振器
spi = SPI(0, baudrate=1_000_000, polarity=1, phase=0,
          sck=Pin(2), mosi=Pin(3))
fsync = Pin(5, Pin.OUT, value=1)

def write16(word):
    fsync.value(0)
    spi.write(bytes([word >> 8, word & 0xFF]))
    fsync.value(1)

def set_freq(f):
    freqreg = round(f * 2**28 / MCLK)  # 7MHz なら 75161928
    write16(0x2100)                    # B28 = 1 (28 bit を 2 語で書く)、RESET = 1
    write16(0x4000 | (freqreg & 0x3FFF))          # FREQ0 下位 14 bit
    write16(0x4000 | ((freqreg >> 14) & 0x3FFF))  # FREQ0 上位 14 bit
    write16(0xC000)                    # PHASE0 = 0
    write16(0x2000)                    # RESET を解いて正弦を出す
    return freqreg * MCLK / 2**28

print(set_freq(7_000_000))             # 7000000.03 と出る
```

**RTL-SDR と PC のソフト**。受信機は RTL-SDR Blog V4 (HF の 0.5〜28.8MHz を内蔵の
アップコンバータで受けられる版) を使う。古い V3 は 24MHz より下を「ダイレクト
サンプリング」の設定に切り替えて受ける。PC のソフトは **SDR++** (Windows・Mac・Linux)
か **SDR#** (Windows)。

| 設定 | 値 | 理由 |
| --- | --- | --- |
| 中心周波数 | 7.000MHz | DDS の周波数 |
| サンプルレート | 2.4MS/s | 画面の幅 = ±1.2MHz。RTL-SDR が安定して出せる上限の目安 |
| 復調 | CW か USB | 無変調の搬送波が「ピー」という音で聞こえる |
| RF ゲイン | 0〜20dB くらいから | 入力は −55dBm と強い。ゲインを上げすぎると偽の線が増える |
| FFT の幅を狭める (ズーム) | 画面の幅 数 kHz | 数十〜数百 Hz のずれを読む |

**ウォーターフォール**は、横が周波数、縦が時間 (上が今)、明るさが強さの画面だ。
**無変調の搬送波は、上から下へまっすぐ落ちる 1 本の明るい縦線**になる。
`set_freq()` を 1 秒ごとに 7.000MHz → 7.001MHz と書き換えると、線が 1kHz ずつ
右へ段を刻んでジグザグに見える。これが「周波数を数値で書く」DDS の効き目だ。

**tinySA でスペクトルを見る**。U3 の代わりに tinySA を同じケーブルでつなぐと、
像まで含めた出力が見える (図3)。入力は −55dBm と小さいので、tinySA の上限 (+10dBm 未満) の心配はない。

```spectrum
title: 図3 7MHzの正弦と、MCLK 25MHzの周りの像
device: tinysa
sweep: 0-50M 290
rbw: 100kHz
ref: -40dBm
signal:
  - sine 7MHz -55.2dBm
  - sine 18MHz -63.4dBm
  - sine 32MHz -68.4dBm
  - sine 43MHz -71.0dBm
markers: [7M, 18M, 32M, 43M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/16-dds-sdr-module.svg)

- 図の値は理想 (計算)。低い周波数の出力 −54.1dBm (減衰器の後) に sinc の係数を掛けた
- 実物はこのほかに、位相を 12 bit に切り詰めて正弦の表を引くことによる小さなスプリアスや、
  MCLK (25MHz) そのものの漏れが出る (大きさはモジュールの作りで変わる)

## 見るべき値

計算値。MCLK = 25MHz、FREQREG = 75161928、減衰器 (AT) 40dB。

| 測る所 | 期待する値 |
| --- | --- |
| `set_freq(7_000_000)` の表示 | 7000000.03 (Hz) |
| 周波数の分解能 | 0.093Hz (25MHz ÷ 2<sup>28</sup>) |
| tinySA のマーカー 1 (7MHz) | −55.2dBm |
| マーカー 2 (18MHz、1 つ目の像) | −63.4dBm (7MHz の 8.2dB 下) |
| マーカー 3 (32MHz) | −68.4dBm |
| マーカー 4 (43MHz) | −71.0dBm |
| SDR++ のウォーターフォール | 7.000MHz に縦線 1 本。ずれは ±350Hz 以内 (モジュールの水晶 ±50ppm と仮定) |
| SDR を 18.000MHz に合わせる | 像が同じく縦線で見える。7MHz を 7.001MHz にすると 17.999MHz へ**逆向きに**動く |

- **周波数のずれの大半は DDS 側の水晶**から来る。RTL-SDR Blog V4 の基準は 1ppm の TCXO
  (7MHz で ±7Hz) なので、SDR で読んだずれは、ほぼモジュールの 25MHz の誤差 × 0.28 と読める
- 像が 25 − f で**逆向きに動く**ことで、どの線が本物でどれが像かを見分けられる

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico | MicroPython を書き込む。USB から給電 |
| U2 | AD9833 モジュール | 25MHz 水晶発振器つき。VCC・DGND・SDATA・SCLK・FSYNC・AGND・OUT のピンヘッダ |
| U3 | RTL-SDR Blog V4 | SMA 入力。0.5MHz〜1.7GHz |
| AT | SMA 40dB 減衰器 (50Ω) | 市販品。板の外。20dB を 2 個でもよい |
| SMA ケーブル | 50Ω | U2 の OUT から AT へ (SMA 変換ケーブル) |

- 電源は既定の 5V ではなく 3.3V (Pico の 3V3 OUT)。Pico の GPIO と電圧を合わせるため
- 同じ使い方で **Si5351 モジュール** (I2C、アドレス 0x60、8kHz〜160MHz 程度の方形波を 3 本) も
  動く。方形波なので奇数次の高調波が強く、RTL-SDR の VHF 帯でそのまま受けられるのが利点

## 出典

自作。AD9833 の周波数レジスタ・制御語・SPI の読み取りの向き・出力電圧は
[Analog Devices AD9833 データシート](https://www.analog.com/media/en/technical-documentation/data-sheets/ad9833.pdf)、
DDS の像と sinc の減衰は [Analog Devices の DDS 解説 (MT-085)](https://www.analog.com/media/en/training-seminars/tutorials/MT-085.pdf)、
Pico の SPI0 のピンは [Raspberry Pi Pico のピン配置 (データシート)](https://datasheets.raspberrypi.com/pico/pico-datasheet.pdf)、
RTL-SDR Blog V4 の HF 受信と TCXO は [RTL-SDR Blog V4 の説明](https://www.rtl-sdr.com/V4/) による。
微弱無線局の範囲は電波法施行規則第 6 条。
