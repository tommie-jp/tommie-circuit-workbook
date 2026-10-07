---
book: nanovna
chapter: 5
id: 5-2
title: 速度係数
tier: 50
source: 自作
board: —
device: H4
---

# 5-2 速度係数

同軸ケーブルの中を伝わる電波は真空中より遅く、その比が**速度係数 (vf)**。
長さの分かっているケーブルを**先端開放のスタブ**として CH0-CH1 間の通り道から
分岐させ、信号を吸い込む (ノッチになる) 周波数から逆算して求める。

## 回路図

```circuit
title: 図1 先を開放した 1 m のスタブを T で分岐
parts:
  J1: sma 2,2 mirror CH0
  J2: sma 8,2 CH1
  TL1: tline 5,2 5,4 50 l=$\mathrm{TL}_1$
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 5,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 5,4.2 center: 開放
  - text 5.3,3.5 left: 1 m・vf 0.66
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/02-velocity-factor.svg)

CH0 と CH1 の間を SMA の T 型アダプタで直結し、T の 3 つ目の口に 1 m の
ケーブルを挿す (3-2 の並列治具と同じ考え方)。TL1 の先 (d5) は意図して
開放のままにする。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — ケーブルそのものを測る題で、基板に載せる回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 301 |
| 校正 | SOLT。CH0・CH1 の 2 本のケーブルの先で Open / Short / Load / Thru。T はそのあと挿す |
| 表示 | S21 の Log Mag |

見えるはずの画面 (理想の模型。長さ 1 m・速度係数 0.66 と仮定)。

```vna
device: h4
sweep: 1M-300M 301
title: 図2 1 m の開放スタブ (シャント) の S21 — ノッチが並ぶ
dut:
  - shunt line 50 1m vf 0.66 open
traces:
  - S21 logmag
markers:
  - 49.4658M
  - 148.3973M
  - 247.3288M
notes:
  - band 49.47M 148.40M
  - text 60M -60dB: 間隔 Δf = 98.93 MHz → vf 0.660
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/02-velocity-factor.svg)

## 見るべき値

計算値。開放スタブは長さの奇数倍の λ/4 でノッチになる: f₀ = vf·c / (4L)、
3f₀、5f₀、… と並ぶ。

| ノッチ | 周波数 | S21 |
| --- | --- | --- |
| 1 番目 (f₀) | 49.47 MHz | −111 dB (理想の損失無しの模型では非常に深い) |
| 2 番目 (3f₀) | 148.40 MHz | −114 dB |
| 3 番目 (5f₀) | 247.33 MHz | −117 dB |

速度係数の逆算: ノッチの間隔 Δf = 2f₀ = vf·c / (2L) なので、
**vf = 2L·Δf / c**。ここでは Δf = 148.40 − 49.47 = 98.93 MHz、L = 1 m として

vf = 2 × 1 × 98.93×10⁶ / (2.998×10⁸) ≈ 0.660

分かること:

- **1 つのノッチの周波数だけでも vf は求まる**が、間隔 (2 点以上) を使うほうが
  ケーブルの根元の余分な長さ (コネクタぶん) の誤差を打ち消せて確か
- 理想の模型 (損失無し) でもノッチの深さは掃引の周波数がぴったり合っているかに
  非常に敏感で、実物のケーブルには損失もあるので、深さそのものは有限で
  ばらつく (損失は 5-3 で扱う)。**vf を読むにはノッチの「周波数」を
  見ればよく、深さは気にしなくてよい**
- 発泡 PE の同軸 (比誘電率が低い) は vf が高く (0.80〜0.86)、
  普通の PE 詰め物のケーブル (今回の 0.66) より同じ長さでもノッチが高い
  周波数に出る

## 出典

自作。
