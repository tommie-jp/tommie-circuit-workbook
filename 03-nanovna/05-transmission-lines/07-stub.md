---
book: nanovna
chapter: 5
id: 5-7
title: スタブ (開放・短絡)
tier: 100
source: 自作
board: —
device: H4
---

# 5-7 スタブ (開放・短絡)

信号の通り道から枝分かれさせた、先の閉じた短いケーブルが**スタブ**。
5-2 では先端開放のスタブのノッチから速度係数を求めた。ここでは**同じ長さの
ケーブルの先を開放と短絡で入れ替え**、ノッチの並びがちょうど互い違いになる
ことを確かめる。長さ 1 m・速度係数 0.66 のケーブル (5-2 と同じ物) を使う。

## 回路図

CH0 と CH1 の間を SMA の T 型アダプタで直結し、T の 3 つ目の口に 1 m の
ケーブルを挿す (3-2 の並列治具と同じ考え方)。先は開放 (図1) と短絡 (図2)。

```circuit
title: 図1 先端開放のスタブ (1 m) を T で分岐
parts:
  J1: sma b2 mirror CH0
  J2: sma b8 CH1
  TL1: tline b5 d5 50 l=$\mathrm{TL}_1$
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b5 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text d5c0 center: 開放
  - text c5f3 left: 1 m・vf 0.66
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/07-stub-1.svg)

```circuit
title: 図2 先端短絡のスタブ (1 m) を T で分岐
parts:
  J1: sma b2 mirror CH0
  J2: sma b8 CH1
  TL1: tline b5 d5 50 l=$\mathrm{TL}_1$
  G1: ground c2
  G2: ground c8
  G3: ground d5
wires:
  - J1.1 -- b5 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text c5f3 left: 1 m・vf 0.66
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/07-stub-2.svg)

- TL1 の外皮は T の外側 (GND) につながる。図では線路の記号 1 つで表した
- 短絡は SMA の短絡プラグ (校正キットの Short) を先に挿せばよい。開放は
  何も挿さない。図1 の TL1 の先 (d5) は意図して開放のままにしてある
  (check が「どこにもつながっていない」と言うのはこのため)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 同軸ケーブルの先を開放・短絡にして T 型アダプタで分岐する題で、組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (5-2 と同じ) |
| 点数 | 301 |
| 校正 | SOLT。2 本のケーブルの先で Open / Short / Load / Thru。T はそのあと挿す |
| 表示 | S21 の Log Mag |

マーカーは 2 つの図で同じ 4 点 (開放のノッチ 2 つと短絡のノッチ 2 つ) に置く。
見えるはずの画面 (理想の模型)。先端開放。

```vna
device: h4
sweep: 1M-300M 301
title: 図3 開放スタブ — λ/4 の奇数倍 (マーカー 1・3) で落ちる
dut:
  - shunt line 50 1m vf 0.66 open
traces:
  - S21 logmag
markers:
  - 49.4658M
  - 98.9316M
  - 148.3973M
  - 197.8631M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/07-stub-1.svg)

先端短絡。掃引もマーカーも図3 と同じ。

```vna
device: h4
sweep: 1M-300M 301
title: 図4 短絡スタブ — λ/2 の倍数 (マーカー 2・4) と低い所で落ちる
dut:
  - shunt line 50 1m vf 0.66 short
traces:
  - S21 logmag
markers:
  - 49.4658M
  - 98.9316M
  - 148.3973M
  - 197.8631M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/07-stub-2.svg)

## 見るべき値

計算値。f₀ = vf·c / (4L) = 0.66 × 2.998×10⁸ / 4 ≈ 49.47 MHz (長さがちょうど λ/4 になる周波数)。
スタブの入口の Z は、開放なら **−jZ₀ cot βl**、短絡なら **+jZ₀ tan βl** (βl = 2πl/λ)。
Z が 0 になる所で信号は地へ逃げ、S21 が落ちる。

| マーカー | 周波数 | 長さ | 開放スタブの S21 | 短絡スタブの S21 |
| --- | --- | --- | --- | --- |
| 1 | 49.47 MHz (f₀) | λ/4 | −111 dB (ノッチ) | 0 dB (通る) |
| 2 | 98.93 MHz (2f₀) | λ/2 | 0 dB (通る) | −105 dB (ノッチ) |
| 3 | 148.40 MHz (3f₀) | 3λ/4 | −114 dB (ノッチ) | 0 dB (通る) |
| 4 | 197.86 MHz (4f₀) | λ | 0 dB (通る) | −106 dB (ノッチ) |

- ノッチの深さは理想の模型を**その周波数ちょうどで**計算した値。図の線は
  301 点の間隔 (約 1 MHz) でノッチの底を跨ぐので、−30〜−40 dB までしか下がって
  見えない。実物も損失があるので、深さは有限でばらつく (5-2 と同じ)。**読むのは
  ノッチの周波数**
- 短絡スタブは**低い周波数 (1 MHz 付近) でも落ちる**。長さが λ に比べて短いと、
  短絡スタブはただの短い線 (小さなインダクタンス) で、信号を地へ逃がすから

分かること:

- **開放と短絡を入れ替えると、ノッチと通る所がちょうど入れ替わる** — λ/4 の
  線路は先端の「開放」を入口の「短絡」に、「短絡」を「開放」に裏返す。
  λ/2 では先端の状態がそのまま入口に出る
- 短絡スタブは、ノッチの間 (f₀・3f₀) で開放に見えて**線路に何もつながって
  いない**のと同じになる。この性質を使うと、DC を通す (短絡している) のに、
  狙った周波数では邪魔をしない支え (λ/4 の短絡スタブ) が作れる。アンテナの
  給電部の静電気逃がしに使われる
- 1 m のケーブル 1 本で、スタブは f₀ おきに開放・短絡を繰り返すので、狙った
  1 点だけを落とすには**一番低いノッチを使う**のが素直。同軸スタブの
  ノッチの実用は 6-18 で扱う

## 出典

自作。
