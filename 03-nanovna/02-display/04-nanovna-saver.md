---
book: nanovna
chapter: 2
id: 2-4
title: NanoVNA-Saver に繋ぐ
tier: 50
source: 自作 (ソフトの操作は NanoVNA-Saver のドキュメント)
board: —
device: H4
---

# 2-4 NanoVNA-Saver に繋ぐ

**NanoVNA-Saver** は PC 用のフリーソフトで、NanoVNA を USB (仮想シリアル
ポート) で繋いで掃引・校正・保存を行える。本体の小さい画面より広い画面で
読め、**分割掃引で点数を増やせる**のが大きな利点。

## つなぎ方の流れ

| # | 操作 |
| --- | --- |
| 1 | USB ケーブルで PC と NanoVNA をつなぐ |
| 2 | NanoVNA-Saver を起動し、シリアルポートを選んで Connect |
| 3 | 開始・終了・点数 (Segments) を設定する |
| 4 | 校正 (1-1 と同じ手順を画面の指示で行う。2-9) |
| 5 | Sweep を押して掃引する |

本体の 1 回の掃引の点数には上限がある (**版による**。元のファームウェアは
101 点まで、DiSlord 版の H4 は 51・101・201・301・401 点から選ぶか、21〜401 点を
数で入れる。版の違いは 2-16)。Saver は範囲をいくつかの
セグメントに分けて掃引し、つなぎ合わせて上限より多い点数にできる。
点数は「1 セグメントの点数 × セグメントの数」で、たとえば 101 点の
4 セグメントなら 101 × 4 = **404 点**になる (セグメントの境目の点は重ならない)。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 画面と PC ソフトの操作の題で、組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 404 (101 点のセグメント 4 つ。Saver の分割掃引) |
| 校正 | Saver 上で SOLT (2-9) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

点数を増やすと、同じ理想の Thru でも**滑らかな線**になる (点が増える
ぶん、細かい特徴を見落としにくくなる)。

```vna
device: h4
sweep: 1M-300M 404
title: 図1 Saver の 404 点で見た Thru — 理想は平ら
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

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/04-nanovna-saver.svg)

## 見るべき値

| 点数 | 隣り合う点の間隔 (このスウィープ) | 分かること |
| --- | --- | --- |
| 101 (1 セグメント) | 約 3.0 MHz | 鋭い山谷を取りこぼす恐れがある |
| 404 (Saver、4 分割) | 約 0.74 MHz | 同じ範囲でも 4 倍細かく追える |

**点数を増やすほど掃引に時間がかかる。** 校正の点数を上げすぎるとどう
なるかは 1-13 で扱う。

## 出典

自作。ソフトの操作は
[NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) のドキュメント。
