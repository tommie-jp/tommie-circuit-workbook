---
book: nanovna
chapter: 1
id: 1-2
title: 校正の 3 点を Smith チャートで確かめる (Open / Short / Load)
tier: 50
source: 自作
board: —
device: H4
---

# 1-2 校正の 3 点を Smith チャートで確かめる (Open / Short / Load)

SOLT (1-1) で使う 3 つの標準器は、Smith チャートの上でそれぞれ決まった
1 点に来る。校正を始める前に、この 3 点がどこに来るはずかを覚えておくと、
校正キットの良し悪しや、自作の標準器 (3-4) の出来を目で確かめられる。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | まだ不要 (校正前の標準器そのものを見る) |
| 表示 | S11 の Smith チャート |

**Open** — 何もつながず、先が開放。理想は Γ = 1∠0° で、Smith の**右端**。

```vna
device: h4
sweep: 1M-300M 101
title: 図1 Open — Smith の右端
dut: open
traces:
  - S11 smith
markers:
  - 100M
```

**Short** — 中心導体を GND に直結。理想は Γ = 1∠180° で、Smith の**左端**。

```vna
device: h4
sweep: 1M-300M 101
title: 図2 Short — Smith の左端
dut: short
traces:
  - S11 smith
markers:
  - 100M
```

**Load** — 50 Ω の抵抗で終端。理想は Γ = 0 で、Smith の**真ん中**。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 Load (50 Ω) — Smith の真ん中
dut:
  - series R 50
  - short
traces:
  - S11 smith
markers:
  - 100M
```

- Open と Short は**周波数によらず同じ点**に留まるのが理想。実物の標準器には
  わずかな容量 (Open) やインダクタンス (Short) があり、周波数を上げると
  少しだけ点がずれていく (この寄生分の話は 1-12)
- Load は**周波数によらず真ん中**が理想。実物の 50 Ω は DC でも測って
  確かめられる (1-8)

## 見るべき値

| 標準器 | 理想の Γ | Smith 上の位置 | 実物のずれ方 |
| --- | --- | --- | --- |
| Open | 1∠0° | 右端 (∞ Ω) | 高い周波数ほど中心寄りに (容量の分) |
| Short | 1∠180° | 左端 (0 Ω) | 高い周波数ほどわずかに回る (誘導の分) |
| Load (50 Ω) | 0 | 真ん中 | ほぼ動かない (良い抵抗なら) |

3 点がこの位置からずれているなら、校正キットが傷んでいるか、
つなぎ方 (締め方、0-2) を疑う。

## 出典

自作。
