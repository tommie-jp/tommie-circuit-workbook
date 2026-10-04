---
book: nanovna
chapter: 2
id: 2-10
title: スクリーンショットと記録
tier: 100
source: 自作 (操作は NanoVNA-D (DiSlord 版) のファームウェアと NanoVNA-Saver のソース)
board: —
device: H4
---

# 2-10 スクリーンショットと記録

測った画面は、そのときの設定と一緒に残さないと後で役に立たない。「どの校正で、
どの範囲を、何点で測ったか」が分からない画面は、比べることも測り直すこともできない。
**画面 (画像) と数 (Touchstone) と設定 (メモ) の 3 つを 1 組で残す。** 2-6 の直列 RLC を
例に、残し方を決める。

## 残し方の 3 通り

| 残し方 | 操作 | できるもの |
| --- | --- | --- |
| 本体の SD カード | SD CARD → SCREENSHOT | 画面の画像 (BMP。設定で TIFF も) |
| | SD CARD → SAVE S1P / SAVE S2P | Touchstone (2-5) |
| | SD CARD → SAVE CALIBRATION | 校正のファイル |
| | SD CARD → AUTO NAME | 名前を付けずに日時などで保存する |
| NanoVNA-Saver | グラフを右クリック → Save image | そのグラフの PNG |
| | Manage (シリアルの欄) → Screenshot | 本体の画面をそのまま写した画像 |
| | Files ... | Touchstone の書き出し (2-5) |
| USB のシリアル | `capture` コマンド | 本体の画面の画素 (Saver の Screenshot もこれを使う) |

- SD カードの差し込み口が無い機体では、Saver か USB で残す
- **画像だけでは数に戻せない。** 必ず Touchstone も一緒に保存する。Touchstone なら
  後から別の形式 (Smith・R + jX など) で描き直せるし、この教科書の `vna` の図に
  `data:` で重ねられる (2-5)

## 記録に書くこと

| 項目 | 例 | どこで分かるか |
| --- | --- | --- |
| 日時 | 2026-09-28 14:30 | 時計 |
| 機体とファームウェアの版 | NanoVNA-H4、DiSlord 版 (版の番号) | CONFIG → VERSION (0-5) |
| 校正 | スロット 1、25〜125 MHz・101 点、付属キット、CH0 のケーブルの先 | 1-1・1-5・1-6 |
| 掃引 | 25〜125 MHz、101 点、IF BANDWIDTH、平均化 (Saver なら N / D) | 画面の下の欄、2-9 |
| DUT | 22 Ω・100 nH・100 pF の直列、SMA の先 | 自分で書く |
| 温度 | 室温 24 °C | 温度計 (1-9) |
| マーカーの読み | 50.33 MHz で 22.0 Ω + j0.0 Ω | 画面のマーカーの表 |
| ファイル | `2-6-rlc-20260928.s1p`、`2-6-rlc-20260928.bmp` | 保存した名前 |

ファイル名は **題の番号・DUT・日付** をつなげておくと、どの題の測定か分かる。
画像・Touchstone・記録の 3 つは同じフォルダに置き、ばらばらにしない。

## 回路図

2-6 と同じ DUT。

```circuit
title: 図1 記録する測定 (CH0 の先に R L C を直列)
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  R1: resistor a4i0i0 a5i0i0 22
  L1: inductor a6i0i0 a7i0i0 100n
  C1: capacitor a8i0i0 c8i0i0 100p
  G1: ground c8i0i0
wires:
  - M1.CH0 -| a4i0i0
  - a5i0i0 -- a6i0i0
  - a7i0i0 -- a8i0i0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/10-screenshot-records.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の直列 RLC (2-6 と同じ)
points:
  GND: l2
parts:
  J1: sma/female-edge i1 h0 j0
  R1: resistor i3 i6 22
  L1: inductor i8 i12 100n
  C1: capacitor i14 l14 100p
wires:
  - i1 -- i3
  - i6 -- i8
  - i12 -- i14
  - l14 -- GND black
  - j0 -- j2 black
  - j2 -- GND black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/perfboard/10-screenshot-records.svg)

2-6 の基板をそのまま使う。J1 に NanoVNA の CH0 のケーブルをつなぐ。板に流れる電流は、NanoVNA の出力が 0 dBm 以下なので数 mA 以下で、板の範囲 (1 穴 200 mA) に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 25 MHz〜125 MHz (2-6 と同じ) |
| 点数 | 101 |
| 校正 | CH0 のケーブルの先で SOL (1-1) |
| 表示 | S11 の SWR、S11 の Smith チャート |

この教科書の `vna` の図は、`notes:` に `source` を書くと、**図の下に設定そのもの**
(範囲・点数・DUT・トレース・マーカー) を刷る。本体のスクリーンショットには校正や
DUT の中身は写らないので、記録の表で補う。

```vna
device: h4
sweep: 25M-125M 101
title: 図3 記録する画面 — 共振 50.33 MHz で SWR 2.27
dut:
  - series R 22
  - series L 100n
  - series C 100p
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 50.33M
notes:
  - source
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/10-screenshot-records.svg)

- 読み値は 50.33 MHz で SWR 2.27、22.0 Ω + j0.0 Ω。2-6 の表と同じ点を、形式を変えて
  見ている
- 同じ DUT を後日測り直したら、Touchstone を `data:` に書いてこの図に重ねる。理想と
  実測、前と今のずれが 1 枚で見える

## 見るべき値

| 見る所 | 値 | 分かること |
| --- | --- | --- |
| 50.33 MHz の SWR | 2.27 (計算値) | 共振で反射がいちばん小さい (Γ = 0.389、2-6) |
| 50.33 MHz の Z | 22.0 Ω + j0.0 Ω (計算値) | 共振では R だけが残る (2-6) |
| 保存したファイル | `.s1p` と画像と記録の 3 つ | 後から比べられる |
| 記録の表の欄 | 全部埋まっている | 同じ条件で測り直せる |

## 出典

自作。メニューの名前は [NanoVNA-D (DiSlord 版)](https://github.com/DiSlord/NanoVNA-D)、
Saver の操作は [NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) のソース。
