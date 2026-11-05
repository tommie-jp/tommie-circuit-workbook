---
book: analog-discovery
chapter: 11
id: 11-4
title: CSV をグラフにする (matplotlib)
tier: 200
source: 自作 (グラフは matplotlib)
board: —
---

# 11-4 CSV をグラフにする (matplotlib)

11-1 の Script が出した掃引の表と、11-3 の SDK が書いた `batch.csv` を、Python の **matplotlib** でグラフにする。
WaveForms の画面を写真に撮るより、表から描き直すほうが、軸・単位・理論の線を自分で決められ、報告にそのまま貼れる。
描き方は、測った値を**点** (線で結ばない)、理論を**線**にして同じ図に重ねる。測った点が理論の線に乗るかを目で見る。

この題は基板を使わない。**11-1・11-3 の基板と測った表をそのまま使い、プログラムだけを足す題**なので、回路図・実体配線図・AD3・オシロの図は
11-1 の図1〜図3 と 11-3 の図1〜図3 を指して再掲しない。

## 計器の設定

計器は使わない。読む表は次の 2 つ。

| ファイル | 作り方 | 中身 |
| --- | --- | --- |
| `sweep.tsv` | 11-1 の Script の出力 (Output の欄) を全部選んで写し、テキストで保存する | タブ区切り。`f[Hz]` `Vin[V]` `Vout[V]` `Gain[dB]` の 4 列。最後の行は `-- done --` |
| `batch.csv` | 11-3 の `batch.py` が書く | カンマ区切り。`番号` `抵抗 (Ω)` `ずれ (%)` |

`python plot_csv.py sweep.tsv batch.csv` と打つと、`sweep.png` と `batch.png` ができる。

```python
import csv
import math
import sys

import matplotlib.pyplot as plt

R1, C1 = 1e3, 100e-9                 # 11-1 の RC ローパス
FC = 1 / (2 * math.pi * R1 * C1)     # 1.59 kHz


def read_sweep(path):
    """11-1 の Script が出した表 (タブ区切り、1 行めは見出し) を読む。"""
    f_hz, gain_db = [], []
    with open(path, encoding="utf-8") as fp:
        for row in csv.reader(fp, delimiter="\t"):
            if not row or not row[0][0].isdigit():
                continue                 # 見出しと "-- done --" を飛ばす
            f_hz.append(float(row[0]))
            gain_db.append(float(row[3]))
    return f_hz, gain_db


def read_batch(path):
    """11-3 の batch.csv (番号, 抵抗, ずれ) を読む。"""
    with open(path, encoding="utf-8") as fp:
        rows = list(csv.DictReader(fp))
    return [int(r["番号"]) for r in rows], [float(r["抵抗 (Ω)"]) for r in rows]


def plot_sweep(f_hz, gain_db, out):
    fig, ax = plt.subplots(figsize=(6, 4))
    fs = [100 * 10 ** (k / 50) for k in range(0, 176)]          # 100 Hz〜300 kHz
    ax.semilogx(fs, [-10 * math.log10(1 + (f / FC) ** 2) for f in fs], label="理論")
    ax.semilogx(f_hz, gain_db, "o", label="測った値")              # 測った値は点で、線で結ばない
    ax.axhline(-3, ls="--", lw=0.8)
    ax.set_xlabel("周波数 / Hz (対数)")
    ax.set_ylabel("利得 / dB")
    ax.grid(True, which="both", lw=0.3)
    ax.legend()
    fig.savefig(out, dpi=150, bbox_inches="tight")


def plot_batch(no, ohm, out, nominal=1000.0, tol=0.05):
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.axhspan(nominal * (1 - tol), nominal * (1 + tol), alpha=0.15, label="公差 ±5 %")
    ax.plot(no, ohm, "o", label="測った値")
    ax.set_ylim(0, nominal * 1.2)                                   # 大きさの軸は 0 から
    ax.set_xlabel("番号")
    ax.set_ylabel("抵抗 / Ω")
    ax.legend()
    fig.savefig(out, dpi=150, bbox_inches="tight")


if __name__ == "__main__":
    plt.rcParams["font.family"] = "IPAexGothic"   # 日本語のフォント (無ければ入っている物の名前に替える)
    plot_sweep(*read_sweep(sys.argv[1]), "sweep.png")
    plot_batch(*read_batch(sys.argv[2]), "batch.png")
```

- `read_sweep()` は 1 列めが数字で始まらない行 (見出し・`-- done --`) を飛ばす。Script の出力を写すときに見出しごと写してよい
- `plot_sweep()` は横軸を対数 (`semilogx`)、縦軸を dB にし、−3 dB に破線を引く。理論の線は 11-1 の式 −10 log₁₀(1 + (f / f<sub>c</sub>)²)
- `plot_batch()` は公差の帯 (±5 %) を塗り、縦軸を 0 から始める (大きさの量の軸を途中から始めると、ばらつきが大きく見える)
- matplotlib は既定の字に日本語が無い。`IPAexGothic` が無い PC では、入っている日本語のフォントの名前に替える (Windows なら `Yu Gothic`、Mac なら `Hiragino Sans` など)

`sweep.png` に出るはずの図は図1 (理論の線と、11-1 の表の 8 点の位置の目印)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図1 sweep.png に出るはずの図 — 8 点が理論の線に乗る (計算)
x: 周波数 Hz log 100..300k
y: 利得 dB -50..0
lines:
  理論 dB: -10*log10(1+(x/1.5915k)^2)
notes:
  - level -3dB
  - mark 1k
  - mark 3k
  - mark 10k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/graph/04-csv-matplotlib.svg)

この節のコードは、11-1 の見るべき値の表 (理論の 8 点) を `sweep.tsv` に、作った 3 行を `batch.csv` にして、PC の Python 3 (matplotlib 3.6) で動かして
2 枚の PNG ができることを確かめた。AD3 で測った表ではまだ動かしていない (実機は未確認)。

## 見るべき値

計算値。11-1 の表と同じ。

| f | 理論の利得 | グラフで見ること |
| --- | --- | --- |
| 1 kHz | −1.45 dB | −3 dB の破線より上 |
| 1.59 kHz | −3.01 dB | 破線と理論の線が交わる所 (f<sub>c</sub>) |
| 3 kHz | −6.58 dB | 点が線に乗る |
| 10 kHz から上 | 10 倍ごとに −20 dB | 対数の横軸で点がまっすぐ並ぶ |

- 点が全部 1 dB ほど同じ向きにずれていれば、C1 の容量が公称値とずれている。ずれが高い周波数だけなら、ブレッドボードの浮遊容量 (第 8 章)
- `batch.png` では、帯の外の点が 11-3 の「公差の外」の番号と一致するはず
- 同じ書き方で、WaveForms の Network や Scope の書き出し (Export) の CSV も描ける。書き出しの先頭の `#` の行と列の並びは版で違うことがあるので (目安)、
  ファイルを開いて列の番号を `read_sweep()` に合わせる

## LTspice での確かめ (対象外)

回路を足さないプログラムの題なので SPICE の対象外。図1 の線は 11-1 の式そのもので、11-1 の LTspice の表 (8 点とも合う) を指す。
`f_c` = 1 / (2π × 1 kΩ × 100 nF) = 1.5915 kHz、1 kHz で −10 log₁₀(1 + 0.395) = −1.45 dB と、算術で確かめた。

## 出典

自作。
参考: [matplotlib の semilogx](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.semilogx.html)、[matplotlib の axhspan](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.axhspan.html)
