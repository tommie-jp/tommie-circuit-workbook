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

**本体は 1 回の掃引が 101 点まで**だが、Saver は範囲をいくつかの
セグメントに分けて掃引し、つなぎ合わせて多い点数にできる。
たとえば 4 セグメントなら 101 × 4 − 3 = 401 点相当になる
(セグメントの境目の点が重なるため)。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 401 (本体の 101 点の 4 倍相当。Saver の分割掃引) |
| 校正 | Saver 上で SOLT (2-9) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

点数を増やすと、同じ理想の Thru でも**滑らかな線**になる (点が増える
ぶん、細かい特徴を見落としにくくなる)。

```vna
device: h4
sweep: 1M-300M 401
title: 図1 401 点 (Saver の分割掃引) で見た Thru
dut: series R 0
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 300M
```

## 見るべき値

| 点数 | 隣り合う点の間隔 (このスウィープ) | 分かること |
| --- | --- | --- |
| 101 (本体のみ) | 約 3.0 MHz | 鋭い山谷を取りこぼす恐れがある |
| 401 (Saver、4 分割) | 約 0.75 MHz | 同じ範囲でも 4 倍細かく追える |

**点数を増やすほど掃引に時間がかかる。** 校正の点数を上げすぎるとどう
なるかは 1-13 で扱う。

## 出典

自作。ソフトの操作は
[NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) のドキュメント。
