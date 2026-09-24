---
book: nanovna
chapter: 1
id: 1-1
title: SOLT の 9 手順と保存
tier: 50
source: 自作 (校正の手順は NanoVNA V2 系ユーザーマニュアルを参考にした)
board: —
device: H4
---

# 1-1 SOLT の 9 手順と保存

NanoVNA は**校正しないと数値が信じられない**。校正の基本は SOLT
(Short・Open・Load・Thru) で、CH0 に 3 つの標準器をつなぎ、CH0–CH1 間を
Thru でつなぐ。9 つの手順で行い、最後にスロットへ保存する。

## 9 つの手順

| # | 手順 | 操作 |
| --- | --- | --- |
| 1 | 範囲を決める | 測りたい周波数の開始・終了・点数を先に入力する |
| 2 | CH0 に Open | 校正キットの Open をつなぎ、OPEN を押す |
| 3 | CH0 に Short | Short に挿し替え、SHORT を押す |
| 4 | CH0 に Load (50 Ω) | Load に挿し替え、LOAD を押す |
| 5 | 両ポートに Load | CH0・CH1 双方に Load をつなぎ、ISOLN を押す (省略できることが多い) |
| 6 | CH0–CH1 を Thru | 校正キットの Thru でつなぎ、THRU を押す |
| 7 | 計算させる | DONE を押して補正係数を計算する |
| 8 | スロットを選ぶ | 保存先の番号を選ぶ (6 に触れる) |
| 9 | 保存する | SAVE を押して書き込む |

**手順 5 (ISOLN) は無くても校正はできる。** アイソレーションの補正が
入らないぶん、S21 が非常に小さい (−60 dB を超えるような) 測定の精度が
落ちる程度で、この教科書の必須の題では気にしなくてよい。

## 回路図

```circuit
title: 図1 CH0 に Short をつなぐ (手順 3)
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  J1: sma f2 mirror
  G1: ground g2
wires:
  - M1.CH0 -| J1.1
  - J1.2 -- g2
notes:
  - text f2f0 blue center: Short
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | 上の 9 手順どおり (Open / Short / Load / Thru、ISOLN は任意) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

校正が終わったら、**もう一度 Thru をつないで検算する**。理想は
S21 = 0 dB、S11 は検出限界以下。

```vna
device: h4
sweep: 1M-300M 101
title: 図2 校正後に Thru を測り直した理想値
dut: series R 0
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 300M
```

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 校正後の Thru の S21 | 0 dB (計算値) | 校正が正しくできている |
| 校正後の Thru の S11 | 検出限界以下 (計算値) | 反射の補正も効いている |
| スロットから呼び出した直後 | 上と同じ値 | 保存・呼び出しが正しくできている (1-6) |

## 出典

自作。SOLT の手順は NanoVNA V2 系ユーザーマニュアルの校正の節を参考にした。
