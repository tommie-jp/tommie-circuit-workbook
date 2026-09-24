---
book: analog-discovery
chapter: 7
id: 7-3
title: UART を見る (Pico)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Protocol Analyzer)
board: BB
---

# 7-3 UART を見る (Pico)

**Protocol** (プロトコルアナライザ) の UART モードで、Raspberry Pi Pico が
UART0 (GP0) から送る文字を受けて解読する。Pico には 1 秒ごとに `'U'` (0x55、
2 進で 01010101 — スタート・ストップビットを含めた波形が見やすい定番の
テスト文字) を送る簡単なプログラムを書き込んでおく。

## 回路図

```circuit
title: 図1 Pico の UART0 を AD で受ける
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [GND, DIO0]
  MCU: pico2 c5
wires:
  - AD.DIO0 -| MCU.GP0
  - AD.GND -| MCU.GND3
```

- Pico の **GP0 (UART0 TX)** を AD の DIO0 (Protocol の RX) につなぐだけ。
  受けるだけなので AD からは何も送らない
- Pico は USB で給電する (この図には描かない)。**GND は USB 経由でも AD と
  共通になる**が、ノイズを避けるため直接線でも渡す

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  MCU: pico2 @ h5
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, DIO0]
wires:
  - AD.DIO0 -- j5 yellow
  - AD.GND -- j7 black
```

- `pico2 @ h5` は USB を左に向けた向き。**下の行 (h) の左端がピン 1 = GP0**
  (h5)、3 番目が GND (h7)
- 配線は基板自身が使っている h 行の穴を避け、**同じ列の空いた j 行**から取る
  (j5 = GP0 の列、j7 = GND の列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Protocol | UART、RX = DIO0、Baud = 115200、8N1 (8 データビット・パリティ無し・ストップビット 1 ビット) |

Pico 側 (MicroPython) も同じ 115200 bps で `uart.write(b'U')` のようなコードを
1 秒ごとに実行させておく。

## 見るべき値

計算値。115200 bps では 1 ビット = 1/115200 s。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 ビットの時間 | 8.68 µs | ボーレートの逆数 |
| 1 フレームの時間 (start + 8 data + stop) | 86.8 µs (10 ビット) | 'U' 1 文字ぶん |
| Protocol の解読結果 | `0x55` (`'U'`) | 送った文字と一致すれば配線とボーレートが合っている |
| 送信の間隔 | 1 s ごと | プログラムどおり |

**ボーレートが合っていないと文字化けする。** わざと Baud を 9600 にしてみると、
スタートビットの途中で次のビットを読んでしまい、`0x55` 以外の値になる —
115200 と 9600 の比が約 12 倍で、1 ビットぶんの時間がずれるため。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)
(UART の節)。
