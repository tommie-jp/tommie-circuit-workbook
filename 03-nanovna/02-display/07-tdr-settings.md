---
book: nanovna
chapter: 2
id: 2-7
title: TDR (時間領域) の設定
tier: 100
source: 自作 (メニューの名前は NanoVNA-D (DiSlord 版) のファームウェア)
board: —
device: H4
---

# 2-7 TDR (時間領域) の設定

NanoVNA は周波数を掃引して S11 を測る。その S11 を逆フーリエ変換すると、
**パルスを送って反射が戻るまでの時間**の図になる。これが **TDR** (Time Domain
Reflectometry)。時間に速度を掛ければ、ケーブルのどこで反射したか (距離) が読める。
TDR の図の良し悪しは**掃引の設定で決まる**。先を開放した 3 m のケーブルを、
設定を変えて 2 通りに見る。ケーブルの長さを測るのは 5-1、断線の位置は 5-4。

## 設定と式

| 決めるもの | 式 | 何で決まるか |
| --- | --- | --- |
| 周波数の間隔 Δf | (終了 − 開始) / (点数 − 1) | 範囲と点数 |
| 見える距離の上限 | VF × c / (2 × Δf) | **Δf が細かいほど遠くまで** (点数を増やす) |
| 距離の分解能 (目安) | VF × c / (2 × (終了 − 開始)) | **範囲が広いほど細かく** (終了を上げる) |
| 反射までの距離 | VF × c × t / 2 | 往復の時間 t の半分 |

c = 3.0 × 10⁸ m/s、VF は速度係数 (5-2)。2 で割るのは往復だから。分解能は窓を
掛けると (下の WINDOW) この目安より広がる。

## H4 の操作

| # | 操作 | 中身 |
| --- | --- | --- |
| 1 | 範囲と点数を決めて SOLT する | 校正はケーブルの手前 (測るケーブルを挿す所) で (1-5) |
| 2 | DISPLAY → FORMAT S11 (REFL) で LINEAR | TDR は S11 のトレースに掛かる。大きさで見るのが読みやすい |
| 3 | DISPLAY → TRANSFORM → TRANSFORM ON | 横軸が時間に変わる |
| 4 | 同じメニューで LOW PASS IMPULSE / LOW PASS STEP / BANDPASS を選ぶ | 下の表 |
| 5 | WINDOW を MINIMUM / NORMAL / MAXIMUM から選ぶ | MINIMUM は山が細いが裾に小さな山が出る。MAXIMUM は裾がきれいだが山が太い |
| 6 | VELOCITY F. にケーブルの VF を % で入れる (66 など) | マーカーの距離の表示がこの値で決まる |

| 変換 | 開始の周波数 | 分かること |
| --- | --- | --- |
| BANDPASS | 何でもよい | 反射の位置だけ (開放か短絡かは分からない) |
| LOW PASS IMPULSE | **低く取る**。取扱説明書は 50 kHz とする。さらに**終了 ÷ 点数**にそろえると、周波数が 開始 × 1, 2, 3 … の並びになる (目安) | 反射の位置と符号 (開放は上向き、短絡は下向き) |
| LOW PASS STEP | 同上 | 線路のインピーダンスの変化 (段差の上下) |

この教科書の `vna` の図は BANDPASS と同じ考え方で描く (山の位置が反射の場所。
開放と短絡は見分けない)。

## 回路図

```circuit
title: 図1 CH0 の先に 3 m の同軸 (先は開放)
parts:
  M1:
    type: device
    at: 2,2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  T1: tline 4,1.88 7,1.88 50
wires:
  - M1.CH0 -| 4,1.88
notes:
  - text 5.5,2.5 blue center: 3 m、VF 0.66
  - text 7.5,1.5 blue: 先は開放
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/07-tdr-settings.svg)

- T1 は 50 Ω の同軸 3 m (RG-58 などポリエチレンの誘電体のもの、VF 0.66)。先に何もつながないので、
  check は「T1.2 はどこにもつながっていない」と言う。**先を開放にするのが意図**

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 同軸ケーブルを測る設定の題で、組む回路が無い (ケーブルの先を開放にするだけ)。

| 項目 | 図 2 | 図 3 |
| --- | --- | --- |
| 範囲 | 1 MHz〜900 MHz | 1 MHz〜300 MHz |
| 点数 | 401 | 101 |
| Δf | 2.2475 MHz | 2.99 MHz |
| 見える距離の上限 | 44.0 m | 33.1 m |
| 分解能 (目安) | 0.11 m | 0.33 m |
| 校正 | それぞれの範囲で SOLT (1-4) | 同左 |
| 表示 | S11 の TDR、VF 0.66 | 同左 |

```vna
device: h4
sweep: 1M-900M 401
title: 図2 1〜900 MHz・401 点 — 3 m の開放の山は細い
dut:
  - line 50 3m vf 0.66
  - open
traces:
  - S11 tdr vf 0.66
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/07-tdr-settings-1.svg)

範囲を 300 MHz まで、点数を 101 に減らす。ケーブルは同じ。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 1〜300 MHz・101 点 — 同じ山が 3 倍太い
dut:
  - line 50 3m vf 0.66
  - open
traces:
  - S11 tdr vf 0.66
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/07-tdr-settings-2.svg)

- どちらも山は **3 m** の所 (往復 30.3 ns) に立つ。位置は設定によらない
- 図 3 は範囲が 1/3 なので、**山の幅が約 3 倍**。近い 2 つの反射 (コネクタとその
  すぐ先の不連続など) は、図 3 の設定では 1 つの山に融ける
- 見える距離の上限は、図 2 が 44.0 m、図 3 が 33.1 m。**上限より長いケーブルの
  反射は、手前に折り返して見える** (長いケーブルでは点数を増やすか、範囲を狭めて Δf を
  細かくする。ただし範囲を狭めると分解能が落ちる)
- VF を間違えて入れると、山の位置 (距離) がその比でずれる。VF の測り方は 5-2

## 見るべき値

| 見る所 | 図 2 | 図 3 | 式 |
| --- | --- | --- | --- |
| 山の位置 (check の読み) | 3.009 m (30.42 ns) | 3.005 m (30.37 ns) | 3 m (往復 2 × 3 / (0.66 × c) = 30.3 ns) |
| 見える距離の上限 | 44.0 m | 33.1 m | VF × c / (2Δf) |
| 分解能の目安 | 0.11 m | 0.33 m | VF × c / (2 × 範囲) |

(計算値。山の位置が 3 m からわずかにずれるのは、時間の点の刻みのため)

**遠くを見たいなら点数、細かく見たいなら範囲。** H4 の上限 (1.5 GHz、点数は版に
よって 101〜401) の中で、測るケーブルの長さに合わせて決める。

## 出典

自作。メニューの名前は
[NanoVNA-D (DiSlord 版)](https://github.com/DiSlord/NanoVNA-D) のファームウェアのもの。
ローパスの開始を 50 kHz にすることと、終了の周波数と点数が分解能と見える長さを決めることは
[NanoVNA ユーザーガイド (cho45)](https://cho45.github.io/NanoVNA-manual/) の時間領域の節。
