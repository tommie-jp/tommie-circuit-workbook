---
book: nanovna
chapter: 5
id: 5-10
title: 特性インピーダンスの測定 (Zoc と Zsc から)
tier: 100
source: 自作
board: —
device: H4
---

# 5-10 特性インピーダンスの測定 (Zoc と Zsc から)

印字の消えた同軸が 50 Ω か 75 Ω か分からないとき、その場で確かめたい。
同じケーブルの先を**開放にして測った Z (Zoc)** と**短絡にして測った Z (Zsc)**
を掛けて平方根をとると、長さも周波数も消えて**特性インピーダンス Z₀**だけが
残る。長さ 1 m の、中身の分からないケーブル (実は 75 Ω) で確かめる。

## この実験で確かめる式

長さ l の線路の入口の Z は、先が開放なら **Zoc = −jZ₀ cot βl**、
短絡なら **Zsc = +jZ₀ tan βl** (5-7 の式)。掛けると cot と tan が打ち消し合い、
**Z₀ = √(Zoc · Zsc)** が残る (どちらも純虚数で、符号が逆なので積は正の実数になる)。長さが λ/4 の倍数に
近い周波数 (Zoc か Zsc が 0 か ∞) だけは読み値の誤差が大きくなるので避ける。
いちばん読みやすいのは長さが **λ/8** になる周波数で、そこでは
Zoc = −jZ₀、Zsc = +jZ₀ と、**リアクタンスの大きさがそのまま Z₀** になる。
1 m・vf 0.66 なら λ/8 は vf·c / (8 × 1 m) ≈ 24.73 MHz。

## 回路図

```circuit
title: 図1 中身の分からない 1 m のケーブルの先を開放・短絡
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 3,2 6,2 75 l=$\mathrm{TL}_1$
  S1: switch 7,2 7,4
  G1: ground 2,3
  G2: ground 7,4
wires:
  - J1.1 -- 3,2
  - 6,2 -- 7,2
  - J1.2 -- 2,3
notes:
  - text 4.5,2.7 center: 1 m・Z0 は未知
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/10-z0-from-zoc-zsc.svg)

- S1 は「先端を開放 (開) か短絡 (閉) にする」ことを表す。実物にスイッチは
  入れず、先端の SMA に何も挿さない (開放) / 短絡プラグを挿す (短絡)
- 図の 75 Ω は答え。測る側はこれを知らない

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 同軸ケーブルの先を開放・短絡にして測る題で、組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜60 MHz (λ/8 の 24.73 MHz を中ほどに) |
| 点数 | 119 (0.5 MHz おき) |
| 校正 | SOLT。CH0 のケーブルの先 (TL1 を挿す手前) で Open / Short / Load |
| 表示 | S11 のリアクタンス (X) と Smith |

見えるはずの画面 (理想の模型)。まず先端開放。

```vna
device: h4
sweep: 1M-60M 119
title: 図2 先端開放 (Zoc) — 24.73 MHz で X = −75 Ω
dut:
  - line 75 1m vf 0.66
  - open
traces:
  - S11 x
  - S11 smith
markers:
  - 10M
  - 24.73M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/10-z0-from-zoc-zsc-1.svg)

先端短絡。掃引とマーカーは図2 と同じ。

```vna
device: h4
sweep: 1M-60M 119
title: 図3 先端短絡 (Zsc) — 24.73 MHz で X = +75 Ω
dut:
  - line 75 1m vf 0.66
  - short
traces:
  - S11 x
  - S11 smith
markers:
  - 10M
  - 24.73M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/10-z0-from-zoc-zsc-2.svg)

## 見るべき値

計算値 (損失の無い理想の線路。R は 0 Ω)。

| マーカー | 周波数 | Zoc (開放) | Zsc (短絡) | √(Zoc·Zsc) |
| --- | --- | --- | --- | --- |
| 1 | 10 MHz | −j228.2 Ω | +j24.7 Ω | √(228.2 × 24.7) ≈ **75 Ω** (読み値の丸めで 75.1) |
| 2 | 24.73 MHz (λ/8) | −j75.0 Ω | +j75.0 Ω | **75.0 Ω** |

- 10 MHz でも 24.73 MHz でも、**2 つの X は大きく違うのに積の平方根は同じ
  75 Ω**。長さも周波数も知らなくてよい
- 実物のケーブルには損失があるので R が 0 にならず、Zoc と Zsc は複素数になる。
  そのときは複素数のまま掛けて平方根をとり、実部を読む (虚部は小さい)

分かること:

- **印字が無くても、先を開放・短絡して 2 回測るだけで Z₀ が分かる**。
  50 Ω か 75 Ω かの見分けなら 1 点で足りる
- 読むのは λ/4 の倍数から離れた周波数。開放で X が 0 を通る所
  (λ/4 = 49.47 MHz) の近くでは Zoc が小さく、わずかな読み違いが大きく効く
- この方法は平行 2 線 (5-12) のように Z₀ が数百 Ω の線路にも使える

## 出典

自作。
