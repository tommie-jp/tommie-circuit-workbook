---
book: nanovna
chapter: 2
id: 2-1
title: トレースの形式 — Log Mag / 位相 / Smith / SWR
tier: 50
source: 自作
board: —
device: H4
---

# 2-1 トレースの形式 — Log Mag / 位相 / Smith / SWR

NanoVNA は同じ測定値 (S パラメータ) を**何通りもの見せ方**で表示できる。
どの形式が何を見るためのものかを、共振する DUT (アンテナを想定した
直列 RLC) を例に確かめる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 画面と PC ソフトの操作の題で、組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜180 MHz |
| 点数 | 161 |
| 校正 | この題は理想値の確認なので不要 |
| 表示 | S11 の Log Mag・位相・Smith・SWR (4 トレース) |

DUT は R 35 Ω・L 220 nH・C 6.2 pF の直列共振回路 (先を短絡してアンテナの
給電点に見立てる)。共振はおよそ 136 MHz。

```vna
device: h4
sweep: 100M-180M 161
title: 図1 Log Mag と位相 — 136 MHz の共振で谷と位相の変わり目
dut:
  - series R 35
  - series L 220n
  - series C 6.2p
  - short
traces:
  - S11 logmag
  - S11 phase
markers:
  - 136M
notes:
  - text 140M -30dB: 共振 136 MHz の谷 (−15.06 dB)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/01-trace-formats-1.svg)

同じ DUT を、残りの 2 つの形式 (Smith・SWR) で見る。

```vna
device: h4
sweep: 100M-180M 161
title: 図2 Smith と SWR — 共振しても SWR は 1.43 まで
dut:
  - series R 35
  - series L 220n
  - series C 6.2p
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 136M
notes:
  - text 124M 6: 共振でも 1.43 (R が 35 Ω)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/01-trace-formats-2.svg)

- **Log Mag** — 反射の大きさを dB で見る。共振点で谷になる (S11 が小さい
  ほど反射が少ない)
- **位相** — 共振点の前後で位相が大きく変わる。周波数に対する傾きが
  群遅延 (2-14)
- **Smith チャート** — 反射係数を複素数のまま円グラフに置く。共振点は
  実軸に近づく (R = 35 Ω、X ≈ 0)
- **SWR** — 定在波比。共振点でも 1.43 までしか下がらない。**R (35 Ω) が
  50 Ω からずれているから** — 共振していても整合していないと SWR は
  下がりきらない (7-1 で詳しく扱う)

## 見るべき値

| 136 MHz での値 | 数値 (計算値) |
| --- | --- |
| S11 Log Mag | −15.06 dB |
| S11 位相 | −176.60° |
| S11 (R + jX) | 35.0 Ω − j0.8 Ω |
| SWR | 1.43 |

**共振 (X ≈ 0) と整合 (R = 50 Ω) は別のこと。** この DUT は共振しているが
R が小さいので、SWR は 1 まで下がらない。同じ 1 つの測定を 4 通りの
形式で見比べると、この違いがよく分かる。

## 出典

自作。
