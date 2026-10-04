---
book: circuits
chapter: 5
id: 5-4
title: LDO — USB 5V → 3.3V
tier: 50
source: 自作
board: BB
era: 今
---

# 5-4 LDO — USB 5V → 3.3V

USB の 5V から、今どきの定番 3.3V を作る。LDO (Low Drop Out) は入力と出力の
差が小さくても動く三端子レギュレータの仲間で、USB 給電の基板でいちばん
よく見る電源回路。

## 回路図

```circuit
title: 図1 USB 5V から 3.3V の LDO
parts:
  J1: usb-c b2g0d0
  U1: regulator b6 AMS1117-3.3
  Cin: capacitor b4 d4 10u
  Cout: capacitor b8 d8 22u
  Rled: resistor b10 c10 150
  Dled: led c10 d10 red
  G1: ground gnd
points:
  gnd: d3
wires:
  - J1.VBUS -| b4
  - J1.GND -| gnd
  - b4 -- U1.in
  - U1.out -- b8 -- b10
  - U1.gnd -- d6
  - gnd -- d4 -- d6 -- d8 -- d10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/04-ldo-usb.svg)

- J1 は USB Type-C。**使うのは VBUS・GND だけ**。CC1・CC2 (電源交渉用) は
  つながず、相手 (PC や充電器) の初期設定 5V/デフォルト電流に任せる
  (本格的に電流を引きたいなら CC に 5.1 kΩ でプルダウンする)
- Cin (10 µF)・Cout (22 µF) は AMS1117 のデータシートが指定する定石の値。
  LDO は Cout の ESR (等価直列抵抗) が低すぎても発振することがあるので、
  データシートの指定値を守る
- Rled・Dled は 3.3V が出ているかを示す表示 LED

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  U1: regulator/to220 c8(in) c9(gnd) c10(out)
  Cin: capacitor g5 g8 10uF
  Cout: capacitor g10 g13 22uF
  Rled: resistor b14 b20 150
  Dled: led d20(A) d23(K) red
  USB:
    type: device
    at: top
    label: USB-C (電源のみ)
    pins: [VBUS, GND]
wires:
  - USB.VBUS -- +t2 red
  - USB.GND -- -t3 black
  - +t8 -- a8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - a10 -- a14 orange
  - a23 -- -t23 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/04-ldo-usb.svg)

- USB-C の VBUS・GND だけを引き出す (D+/D−/CC は使わない)。実物では
  USB コネクタのモジュール基板を使うとよい
- U1 の足 (IN・GND・OUT = 8・9・10 列) は、上のブロックの e 行から線で下のブロックへ渡す。
  Cin (5・8 列) と Cout (10・13 列) は下のブロックに挿し、出力は a10 から 14 列の Rled へ渡す。
  上下の − レールは 29 列でつなぐ
- **AMS1117 は実物では SOT-223 (面実装) のみで、DIP のように直接
  ブレッドボードへは挿せない。** 3 本足の THT 部品として描いているのは、
  ピン間隔を持たせて市販の「AMS1117 3.3V 固定出力モジュール」基板
  (SOT-223 を変換して 3 本のピンヘッダに出したもの) を挿す想定。
  IN/GND/OUT の並びはモジュールの基板印刷で確認する (品種・基板によって
  順が違う)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | LDO レギュレータ (SOT-223 → ピンヘッダ変換モジュール) | AMS1117-3.3 |
| Cin | セラミックコンデンサ (入力側) | 10 µF |
| Cout | セラミックコンデンサ (出力側) | 22 µF |
| Rled | 抵抗 (表示 LED 電流制限) | 150 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | USB 5V |

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| OUT の電圧 | 3.30 V | AMS1117-3.3 の固定出力 |
| Dled の電流 | 約 8.7 mA | (3.3 V − 2.0 V) ÷ 150 Ω |
| ドロップアウト電圧 | 約 1.1 V (@1A、代表値) | Vin − Vout が 1.1 V を割ると規制できなくなる。5V 入力なら十分な余裕 |
| U1 の損失 (Dled だけの軽負荷) | 約 14.7 mW | (5 V − 3.3 V) × 8.7 mA |
| USB の電流上限との比較 | 8.7 mA ≪ 500 mA (USB 2.0 の規定) | この程度の負荷なら USB 給電で全く問題ない |

負荷電流が数百 mA に増えると (5 − 3.3) V × I の損失が無視できなくなり、
AMS1117 は放熱の無い SOT-223 パッケージだと熱で規制がかかることがある。
大電流が要るなら降圧スイッチング (5-6) を使う。

## 出典

自作。
