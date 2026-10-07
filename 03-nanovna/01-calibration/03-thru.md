---
book: nanovna
chapter: 1
id: 1-3
title: Thru と S21 の 0 dB
tier: 50
source: 自作
board: —
device: H4
---

# 1-3 Thru と S21 の 0 dB

SOLT の最後の標準器が **Thru** — CH0 と CH1 を直結する。この 1 点で
S21 の基準 (0 dB、位相 0°) が決まる。Thru を挟み違えると、以後の S21 が
まるごとずれる。

## 回路図

```circuit
title: 図1 CH0 と CH1 を Thru でつなぐ
parts:
  M1:
    type: device
    at: 2,3.12
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  J1: sma 10,3
  G1: ground 10,4
  J2: sma 7,4
  G2: ground 7,5
wires:
  - M1.CH0 -- J1.1
  - J1.2 -- 10,4
  - M1.CH1 -| J2.1
  - J2.2 -- 7,5
notes:
  - text 10,2 blue center: CH0 側
  - text 8,4 blue left: CH1 側
  - text 9,6 blue center: この 2 つを Thru アダプタで直結する
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/03-thru.svg)

- 校正キットの Thru は多くの場合**メス–メスの短いアダプタ**。ケーブルの先
  どうしを直接ねじ込む
- Thru を挟んだ瞬間、CH0 と CH1 は電気的に**同じ 1 点**になる (減衰も
  位相のずれも無い、というのが Thru の定義)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 校正の手順の題で、Thru はアダプタ 1 個のため組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | Thru の手順のところ (1-1 の手順 6) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

Thru の理想値は、`series R 0` (0 Ω の抵抗 = ただの導線) と同じ模型で表せる。

```vna
device: h4
sweep: 1M-300M 101
title: 図2 Thru の理想は平ら (減衰も反射も無い基準)
dut: series R 0
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 300M
notes:
  - text 20M -40dB: 理想は平ら (S21 は 0 dB、S11 は −∞ で枠の下)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/03-thru.svg)

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Thru の S21 | 0 dB (計算値) | 減衰も利得も無い基準点 |
| Thru の S11 | 検出限界以下 (計算値) | 50 Ω からずれていない |
| 校正前 (Thru の手順を飛ばした) の S21 | ケーブル自身の損失ぶんだけ低い値 | Thru の基準が無いと、ケーブルの損失を DUT の損失と誤認する |

Thru を飛ばして校正すると、以後測る DUT すべてに**ケーブル 2 本ぶんの
損失が上乗せ**されたまま出る。減衰や利得を測る題 (第 6・8 章) では
特に効いてくる。

## 出典

自作。
