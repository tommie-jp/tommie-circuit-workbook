---
book: nanovna
chapter: 6
id: 6-8
title: 群遅延
tier: 100
source: 自作
board: PF
device: H4
---

# 6-8 群遅延

フィルタは振幅だけでなく、信号が通り抜ける**時間**も周波数ごとに変える。
その時間が**群遅延** (group delay)。通過帯域の中で群遅延がそろっていないと、
いろいろな周波数を含む信号 (パルス・デジタルの波形) は、S21 が平らでも形が崩れる。
6-5 で作ったチェビシェフ (0.5 dB) の 5 次ローパスの群遅延を測り、
同じ次数のバターワースの計算と比べる。

## この実験で確かめる式

群遅延は S21 の位相 φ の周波数による傾き: **τ_g = −dφ / dω** (ω = 2πf)。
NanoVNA は隣り合う 2 点の位相の差から求める。点の間隔が広すぎると急な変化を
見落とし、狭すぎると位相の揺れが大きく出る (表示のしかたは 2-14)。

ここでは 1〜50 MHz を 301 点 (約 163 kHz おき) で測る。カットオフ付近の群遅延の
山の幅は数 MHz あるので、この間隔で形が見える。

## 回路図

**作るのはチェビシェフ** (6-5 と同じユニバーサル基板)。バターワース (6-5 の図2) は計算だけで比べる。

```circuit
title: 図1 5 次チェビシェフ 0.5 dB ローパス (6-5 と同じ)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 180p
  L1: inductor 5,2 7,2 330n
  C2: capacitor 8,2 8,4 270p
  L2: inductor 9,2 11,2 330n
  C3: capacitor 12,2 12,4 180p
  J2: sma 14,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 8,4
  G4: ground 12,4
  G5: ground 14,3
wires:
  - J1.1 -- 4,2 -- 5,2
  - 7,2 -- 8,2 -- 9,2
  - 11,2 -- 12,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/08-group-delay.svg)

## 実体配線図

6-5 の図3 と同じユニバーサル基板。部品面から見た図。

```perfboard
board:
  size: 26x10
  slots: on
title: 図2 perfboard に組む (6-5 と同じ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 f3 180p
  L1: inductor e5 e9 330n
  C2: capacitor e11 f11 270p
  L2: inductor e13 e17 330n
  C3: capacitor e19 f19 180p
  J2: sma/female-edge e26 f27
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e11
  - e11 -- e13
  - e17 -- e19
  - e19 -- e26
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- f3 black
  - h3 -- h11 black
  - h11 -- f11 black
  - h11 -- h19 black
  - h19 -- f19 black
  - h19 -- h25 black
  - f27 -- f25 black
  - f25 -- h25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/08-group-delay.svg)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜50 MHz (6-5 と同じ) |
| 点数 | 301 |
| 校正 | SOLT (Thru はケーブル 2 本を直結。Thru の群遅延が 0 ns になる) |
| 表示 | S21 の Log Mag と群遅延 (DELAY) |

2 枚とも掃引とマーカー (1・10・28・30 MHz) を同じにする。チェビシェフ
(作る方) の**見えるはずの画面**。

```vna
device: h4
sweep: 1M-50M 301
title: 図3 チェビシェフ — 群遅延は 20 ns から 30 MHz の 56 ns まで増える
dut:
  - shunt C 180p
  - series L 330n
  - shunt C 270p
  - series L 330n
  - shunt C 180p
traces:
  - S21 logmag
  - S21 delay
markers:
  - 1M
  - 10M
  - 28M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/08-group-delay-1.svg)

バターワース (6-5 の図2 の値、計算だけ)。群遅延の枠の目盛は図が値に合わせて決めるので、
図3 (10 ns/目盛) と図4 (2.5 ns/目盛) で違う。**高さは目盛ではなく読み値の表で比べる**。

```vna
device: h4
sweep: 1M-50M 301
title: 図4 バターワース (計算のみ) — 群遅延の山は 26 ns と低く、なだらか
dut:
  - shunt C 68p
  - series L 390n
  - shunt C 220p
  - series L 390n
  - shunt C 68p
traces:
  - S21 logmag
  - S21 delay
markers:
  - 1M
  - 10M
  - 28M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/08-group-delay-2.svg)

## 見るべき値

計算値 (無損失として)。

| 周波数 | チェビシェフの群遅延 | バターワースの群遅延 |
| --- | --- | --- |
| 1 MHz | 22.3 ns | 16.7 ns |
| 10 MHz | 20.3 ns | 17.4 ns |
| 28 MHz | 44.6 ns | 26.2 ns |
| 30 MHz | 56.1 ns (山は 30.06 MHz) | 26.4 ns (山は 29.3 MHz) |

- 通過帯域 (1〜28 MHz) の中の群遅延の**ばらつき**は、チェビシェフで
  20〜45 ns (**約 25 ns**)、バターワースで 17〜26 ns (約 9 ns)
- **遮断を急にしたぶん、カットオフ付近で信号が長く居座る**。チェビシェフは
  0.5 dB のリップルを許して遮断を急にした (6-5) 代わりに、群遅延が大きく
  暴れる

分かること:

- S21 の Log Mag が平らでも、群遅延がそろっていなければ波形は崩れる。
  例えば 28 MHz の成分は 10 MHz の成分より 24 ns 遅れて出てくる
- パルスやデジタル信号を通すフィルタでは、遮断の急さより**群遅延の平らさ**を
  選ぶことがある (群遅延を最も平らにする形はベッセル。バターワースは
  その中間)
- 実測の群遅延は、隣の点との位相差から求めるので揺れが大きい。値を読むときは
  NanoVNA-Saver で平均化 (2-9) してから読む

## 出典

自作。5 次バターワース・チェビシェフ (0.5 dB) の g 値は標準的なフィルタ設計表による。
