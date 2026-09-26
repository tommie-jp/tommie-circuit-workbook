---
book: analog-discovery
chapter: 7
id: 7-5
title: SPI
tier: 100
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-5 SPI

**Protocol** の SPI モードで、AD がマスタになって A/D コンバータ MCP3008
(SPI・10 bit・8 ch) を読む。7-4 の I2C と違い、SPI は CLK・MOSI (DIN)・
MISO (DOUT)・CS の 4 本で、クロックも AD 自身が出す。分圧で作った既知の
電圧を読み、Protocol の解読結果と自分の計算を突き合わせる。

## 回路図

```circuit
title: 図1 MCP3008 を SPI で読む
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1, DIO2, DIO3]
  U1: dip16 h3 MCP3008
  R1: resistor n3 n5 10k
  R2: resistor n5 n7 10k
wires:
  - AD.V+ -| U1.16
  - AD.V+ -| U1.15
  - AD.V+ -| n3
  - AD.GND -| U1.9
  - AD.GND -| U1.14
  - AD.GND -| n7
  - n5 |- U1.1
  - AD.DIO0 -| U1.10
  - AD.DIO1 -| U1.11
  - AD.DIO2 -| U1.12
  - AD.DIO3 -| U1.13
```

- MCP3008 (`U1`): **16=VDD・15=VREF を共に 3.3 V** (DIO の H レベルと合わせる。
  MCP3008 は 2.7〜5.5 V で動くので 3.3 V でも問題ない)、9=DGND・14=AGND は GND。
  10=CS̄・11=DIN・12=DOUT・13=CLK を AD の DIO0〜DIO3 へ
- R1・R2 (各 10 kΩ) は 3.3 V を 2 分圧し、中点 (1.65 V) を **1=CH0** に入れる
- CH0 は 3.3 V の半分 (1.65 V) という既知の電圧。読めた値と計算値を比べれば
  配線とコマンドが合っているか分かる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip16 @ f12 r180 MCP3008
  R1: resistor b23 b20 10k
  R2: resistor d20 d24 10k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1, DIO2, DIO3]
wires:
  - AD.V+ -- +b9 red
  - AD.GND -- -b10 black
  - j12 -- -b12 black
  - AD.DIO0 -- j13 yellow
  - AD.DIO1 -- j14 white
  - AD.DIO2 -- j15 gray
  - AD.DIO3 -- j16 purple
  - j17 -- -b17 black
  - j18 -- +b18 red
  - j19 -- +b19 red
  - a19 -- a20 orange
  - a23 -- +t23 red
  - a24 -- -t24 black
  - +t27 -- +b27 red
  - -t28 -- -b28 black
```

- U1 (MCP3008) は `r180` で置き、下ブロックに 9=DGND (f12) 〜 16=VDD (f19)、
  上ブロックに 1=CH0 (e19) 〜 8=CH7 (e12) が並ぶ (列が逆向き)。こうすると
  デジタル側の足がすべて下ブロックに揃い、板の下に置いた AD から短い線で届く。
  **16=VDD (j19)・15=VREF (j18) を +b で 3.3 V へ**、14=AGND (j17)・9=DGND (j12)
  を -b で GND へ。10=CS̄ (j13)〜13=CLK (j16) を AD の DIO0〜DIO3 へ
- R1 (b20〜b23)・R2 (d20〜d24) で 3.3 V を分圧。中点 (20 列) を `a19 -- a20` で
  1=CH0 (e19 の列) へ渡す。上下のレールは 27・28 列で渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Protocol | SPI、CS = DIO0、MOSI (DIN) = DIO1、MISO (DOUT) = DIO2、CLK = DIO3。Mode 0 (CPOL=0, CPHA=0)、Rate = **100 kHz** (MCP3008 の上限より十分低い)。送信バイト列 `0x01 0x80 0x00` を CS を下げた状態で送る |

## 見るべき値

計算値。CH0 = 1.65 V (3.3 V の半分)、VREF = 3.3 V、10 bit (0〜1023) として
コード = round(1023 × 1.65 / 3.3) = 512。

| 送るバイト | 受け取るバイト (期待値) | 分かること |
| --- | --- | --- |
| 0x01 (スタートビット) | (最初のバイトは don't care) | MCP3008 がスタートビットを認識 |
| 0x80 (SGL/DIFF=1, D2D1D0=000 → CH0) | 下位 2 bit が結果の上位 2 bit (0b10) | コード 512 = 0b10_0000_0000 の上位側 |
| 0x00 (ダミー、残りのクロックを送る) | 0x00 (結果の下位 8 bit) | コード 512 の下位側 (0b0000_0000) |
| 組み立てたコード | (0b10 << 8) \| 0x00 = **512** | 電圧に戻すと 512 × (3.3 V / 1024) ≈ **1.65 V** — 分圧の計算値と一致 |

**Protocol の解読結果 (MOSI・MISO の両方のバイト列) が上の表と合えば、
配線とコマンドの組み立てが合っている。** 1 LSB = 3.3 V / 1024 ≈ 3.22 mV
なので、512 ぴったりでなく 511 や 513 が出ても誤差の範囲 (ちょうど中間の
電圧はコードの境目に当たるため)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(SPI の節)。MCP3008 のピン配置・コマンド形式 (スタートビット・SGL/DIFF・
チャネル選択・12 クロックで 10 bit を読む) はメーカーのデータシートに基づく。
