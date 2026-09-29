---
book: circuits
chapter: 9
id: 9-16
title: DDS モジュール — Pico で 7MHz を出して tinySA で見る
tier: 200
source: 自作
board: BB
era: 今
---

# 9-16 DDS モジュール — Pico で 7MHz を出して tinySA で見る

**DDS (Direct Digital Synthesis、直接デジタル合成)** は、クロックごとに位相を足し込み、
その位相で正弦の表を引いて DAC から出す発振器だ。9-4 や 9-6 の LC 発振器は
コイルとコンデンサで周波数が決まり、温度や手の近さでずれたが、DDS は
**マイコンから数値を書くだけで周波数が決まり、水晶の精度で止まる**。
ここでは定番の **AD9833 モジュール** (25MHz の水晶発振器と AD9833 を載せた小基板) を
Raspberry Pi Pico から SPI で 7.000MHz に設定し、その出力を
**tinySA Ultra** (手のひらのスペクトラムアナライザ、通常モードで 100kHz〜800MHz、入力は SMA) で見る。
送る側は「モジュール + マイコン」、見る側は市販の計器、という今のラジオ工作の形だ。

**なぜ tinySA か。** 見たいのは 7MHz の線だけでなく、その上に出る像 (18・32・43MHz、下の節)。
Analog Discovery 2 のスペクトラム表示は帯域が 30MHz までなので 32MHz と 43MHz の像が見えない
(7MHz の線だけを見るなら使える)。RTL-SDR は 1 画面が 2.4MS/s で ±1.2MHz 幅しかなく、
7MHz は V4 でなければダイレクトサンプリングの設定も要る。tinySA Ultra なら 0〜50MHz を
1 画面で掃引でき、4 本の線が同じ画面に並ぶ。

> [!WARNING]
> この題は**電波を出さない**。DDS の出力は**同軸ケーブルで直接** tinySA に入れる。
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
**計器で見る前に像があることを知っておく**のがこの題の要点の 1 つ。
波形をきれいにしたいなら、出力に 10MHz 程度の LC 低域フィルタ を入れる。

## 回路図

```circuit
title: 図1 PicoでAD9833を7MHzに設定しtinySAで見る
parts:
  U1: pico k3 mirror
  U2:
    type: device
    at: i11
    label: AD9833
    pins: [VCC, SCLK, SDATA, FSYNC, DGND, AGND, OUT]
  G1: ground l8a5
  U3:
    type: device
    at: m19c0
    label: tinySA Ultra
    pins: [RF, GND]
  GU3: ground o17
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
  - U2.OUT |- U3.RF
  - U3.GND -| o17
notes:
  - text k17f0 blue: 板の外 (SMAケーブルでtinySAへ)
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
  直流分 (中心 約 0.34V) は、tinySA Ultra の入力の許す直流 (±5V まで) に収まる
- **減衰器は入れない。** 源は 200Ω の出力抵抗を持つが、tinySA の入力は 50Ω なので、
  0.3V peak の源を 200Ω と 50Ω で分けて 0.060V peak = **−14.4dBm** (計算値。
  P = 0.060² ÷ (2 × 50Ω) = 36µW)。7MHz は sinc で −1.2dB 下がって **−15.6dBm**。
  tinySA Ultra の入力の上限の目安は +0dBm 程度 (絶対最大 +20dBm) なので、この値は
  **上限より 15dB 以上低く、フロア (RBW 100kHz で約 −97dBm) より 80dB 以上高い**。
  読みやすいレベルなので、40dB の減衰器は要らない。U2 の OUT から U3 の SMA へは
  短い SMA 変換ケーブルで直接つなぐ。GND は同軸の外皮
- 像の 43MHz でも −31.4dBm あり、フロアから 65dB 上に見える。減衰器を入れると
  この余裕が減るだけなので入れない (源を替えて出力が 0dBm に近づくなら、
  そのときは 10〜20dB の SMA 減衰器を先に挟む)

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
  U3:
    type: device
    at: bottom
    label: tinySA Ultra (SMA入力)
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
  - U2.OUT -- U3.RF orange
  - U3.GND -- -b20 black
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
- U2 の OUT は板に挿さず、**板の外で** SMA ケーブルにより U3 (tinySA Ultra) の SMA へ
  つなぐ (図では橙の線)。板の上には 7MHz の線も部品もない。U3 の GND は同軸の外皮で、便宜上、
  下の − レール (20 列) にも寄せてある (回路図の GND と同じ節)

**ブレッドボードで組んでよい理由。** 7MHz は AD9833 モジュールの**中**で作られ、
板の外の SMA ケーブルを通って tinySA に入る。板を通るのは Pico とモジュールの間の
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

**tinySA Ultra の設定**。通常モード (100kHz〜800MHz) の入力 (LOW) に SMA ケーブルでつなぐ。

| 項目 | 設定 | 理由 |
| --- | --- | --- |
| 開始 / 終了 | 100kHz / 50MHz | 7MHz と、43MHz までの像が 1 画面に入る (43MHz が右端から 1 目盛以内) |
| 点数 | 450 | 1 点 = 約 111kHz。像は 11MHz 以上離れているので分かれる |
| RBW | 100kHz | 隣の線との間隔より十分狭い。フロアは約 −97dBm (−102dBm @ 30kHz から換算) |
| 基準レベル (REF) | 0dBm | 一番高い 7MHz の線 (−15.6dBm) が上端から 1.6 目盛下。像 (−31.4dBm) も画面に入る |
| 縦の目盛 | 10dB/div | 既定 |
| 減衰 (ATT) | 自動 | 入力は −15.6dBm と上限より小さい |
| マーカー | 1 = 7MHz、2 = 18MHz、3 = 32MHz、4 = 43MHz | 本文の順。peak で 1 を取り、周波数で 2〜4 を置く |

7MHz の線だけを **Analog Discovery 2 のスペクトラム表示** (帯域 30MHz まで) で見ることもできる
(32・43MHz の像は帯域の外)。

**周波数のずれを読むとき。** 50MHz の掃引では 1 点が約 111kHz なので、7.000MHz の
±350Hz は読めない。中心を 7MHz、幅を 20kHz 程度に狭め RBW を 300Hz くらいにして読む。
ただし tinySA 自身の基準の誤差も同じ桁にあるので、絶対値の確かめには周波数カウンタが要る (この題は像の確認が主)。
`set_freq()` を 1 秒ごとに 7.000MHz → 7.001MHz と書き換えると、線が 1kHz ずつ
右へ動く (幅 20kHz の掃引で見える)。これが「周波数を数値で書く」DDS の効き目だ。

```spectrum
title: 図3 7MHzの正弦と、MCLK 25MHzの周りの像
device: tinysa-ultra
sweep: 100k-50M 450
rbw: 100kHz
ref: 0dBm
signal:
  - sine 7MHz -15.6dBm
  - sine 18MHz -23.8dBm
  - sine 32MHz -28.8dBm
  - sine 43MHz -31.4dBm
markers: [7M, 18M, 32M, 43M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/16-dds-sdr-module.svg)

- 図の値は理想 (計算)。低い周波数の出力 −14.4dBm (50Ω に入れたとき) に sinc の係数を掛けた
- 実物はこのほかに、位相を 12 bit に切り詰めて正弦の表を引くことによる小さなスプリアスや、
  MCLK (25MHz) そのものの漏れが出る (大きさはモジュールの作りで変わる)

## 見るべき値

計算値。MCLK = 25MHz、FREQREG = 75161928、減衰器なし (50Ω に直接)。

| 測る所 | 期待する値 |
| --- | --- |
| `set_freq(7_000_000)` の表示 | 7000000.03 (Hz) |
| 周波数の分解能 | 0.093Hz (25MHz ÷ 2<sup>28</sup>) |
| tinySA のマーカー 1 (7MHz) | −15.6dBm |
| マーカー 2 (18MHz、1 つ目の像) | −23.8dBm (7MHz の 8.2dB 下) |
| マーカー 3 (32MHz) | −28.8dBm (7MHz の 13.2dB 下) |
| マーカー 4 (43MHz) | −31.4dBm (7MHz の 15.8dB 下) |
| 18MHz の像 | 7MHz を 7.001MHz にすると 17.999MHz へ**逆向きに**動く |
| 線の数 | 25MHz の漏れ (MCLK 自体) を除き、7・18・32・43MHz の 4 本 |

- 図の読みは理想で、実機は ±2dB ほど動くことがある (モジュールの出力・ケーブルの損失。目安)
- **周波数のずれの大半は DDS 側の水晶**から来る (7MHz の読みのずれ ≒ モジュールの 25MHz の誤差 × 0.28)
- 像が 25 − f で**逆向きに動く**ことで、どの線が本物でどれが像かを見分けられる

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | Raspberry Pi Pico | MicroPython を書き込む。USB から給電 |
| U2 | AD9833 モジュール | 25MHz 水晶発振器つき。VCC・DGND・SDATA・SCLK・FSYNC・AGND・OUT のピンヘッダ |
| U3 | tinySA Ultra | SMA 入力。通常モード 100kHz〜800MHz。板の外 |
| SMA ケーブル | 50Ω | U2 の OUT から U3 へ (SMA 変換ケーブル)。減衰器は入れない |

- 電源は既定の 5V ではなく 3.3V (Pico の 3V3 OUT)。Pico の GPIO と電圧を合わせるため
- 同じ使い方で **Si5351 モジュール** (I2C、アドレス 0x60、8kHz〜160MHz 程度の方形波を 3 本) も
  動く。方形波なので奇数次の高調波が強く、tinySA の 800MHz までの範囲で高調波を並べて見られるのが利点 (強さは +10dBm 未満に抑える)

## 出典

自作。AD9833 の周波数レジスタ・制御語・SPI の読み取りの向き・出力電圧は
[Analog Devices AD9833 データシート](https://www.analog.com/media/en/technical-documentation/data-sheets/ad9833.pdf)、
DDS の像と sinc の減衰は [Analog Devices の DDS 解説 (MT-085)](https://www.analog.com/media/en/training-seminars/tutorials/MT-085.pdf)、
Pico の SPI0 のピンは [Raspberry Pi Pico のピン配置 (データシート)](https://datasheets.raspberrypi.com/pico/pico-datasheet.pdf)、
tinySA Ultra の範囲・入力の上限・フロアは [tinySA wiki の仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification) による。
微弱無線局の範囲は電波法施行規則第 6 条。
