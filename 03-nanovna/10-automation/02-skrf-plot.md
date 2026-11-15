---
book: nanovna
chapter: 10
id: 10-2
title: Touchstone を scikit-rf で図にする
tier: 200
source: 自作 (関数は scikit-rf のドキュメント)
board: —
device: H4
---

# 10-2 Touchstone を scikit-rf で図にする

保存した Touchstone (2-5) を、Python の **scikit-rf** (`import skrf`) で読んで図にする。2-13 で読み方
(`rf.Network` で開いて S パラメータの配列を取り出す) を覚えたので、ここでは**報告に貼る図**を作る。
Saver の画面の写し (2-10) と違い、軸・尺度・重ねる線を自分で決められ、理想の線を同じ図に重ねられる。

例は 6-1 の 7 次 LC ローパス。測った `6-1-lpf.s2p` を読み、6-1 の部品の値から scikit-rf で組んだ**理想**を
同じ周波数で計算し、実測を実線・理想を破線で重ねる。6-1 の「見るべき値」の 3 つの周波数の S21 を、
実測と理想で並べて表にも出す。

この題は回路図と実体配線図を付けない — 6-1 で測った Touchstone を読むだけで、新しく組む物が無い
(回路は 6-1 の図1、基板は 6-1 の図2)。

## 掃引の設定

計器は VNA (NanoVNA-H4 か標準の LiteVNA64 で 6-1 を測り、Saver で保存する)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz (6-1 と同じ) |
| 点数 | 201 |
| 校正 | SOLT。治具の SMA の面で (6-1) |
| 保存 | Files ... → Save 2-Port file (S2P)、名前は `6-1-lpf.s2p` (10-1 の決まり) |

Python で描く図と見比べる、VNA の理想の画面。マーカーは表の 3 つの周波数。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-100M 201
title: 図1 6-1 の 7 次ローパスの理想 — Python の破線と同じ線
dut:
  - shunt C 47p
  - series L 330n
  - shunt C 200p
  - series L 560n
  - shunt C 200p
  - series L 330n
  - shunt C 47p
traces:
  - S21 logmag
  - S11 smith
markers:
  - 20M
  - 28.4M
  - 40M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/02-skrf-plot.svg)

## 描くスクリプト

scikit-rf と matplotlib を入れる (`pip install scikit-rf matplotlib`)。次を `plot_lpf.py` として保存し、
`python plot_lpf.py 6-1-lpf.s2p` と打つと、同じ場所に `6-1-lpf.png` ができ、表の 3 行が出る。

```python
import sys

import matplotlib
matplotlib.use("Agg")                      # 窓を出さずに PNG だけ書く
import matplotlib.pyplot as plt
import skrf as rf

READ_AT = [20e6, 28.4e6, 40e6]   # 本文の表の周波数 [Hz] (6-1 の見るべき値)


def ideal(freq):
    """6-1 の 7 次ローパス (丸めた値) を、理想の部品を縦続して作る。"""
    m = rf.media.DefinedGammaZ0(frequency=freq, z0_port=50)
    return (m.shunt_capacitor(47e-12) ** m.inductor(330e-9) ** m.shunt_capacitor(200e-12)
            ** m.inductor(560e-9) ** m.shunt_capacitor(200e-12) ** m.inductor(330e-9)
            ** m.shunt_capacitor(47e-12))


def main():
    meas = rf.Network(sys.argv[1])         # 測った .s2p
    meas.frequency.unit = "mhz"            # 横軸を MHz で
    meas.name = "measured"              # 凡例の字 (matplotlib の既定の字体に日本語が無いので英字)
    model = ideal(meas.frequency)          # 測った点と同じ周波数で理想を作る
    model.name = "ideal"

    fig, (ax_db, ax_sm) = plt.subplots(1, 2, figsize=(11, 4.5))
    meas.plot_s_db(m=1, n=0, ax=ax_db)                     # S21 (実測、実線)
    model.plot_s_db(m=1, n=0, ax=ax_db, linestyle="--")    # S21 (理想、破線)
    meas.plot_s_db(m=0, n=0, ax=ax_db)                     # S11 (実測)
    model.plot_s_db(m=0, n=0, ax=ax_db, linestyle="--")    # S11 (理想)
    ax_db.set_ylim(-80, 5)
    ax_db.set_title("S21 / S11 (dB)")
    meas.plot_s_smith(m=0, n=0, ax=ax_sm, draw_labels=True)
    ax_sm.set_title("S11 (Smith)")
    fig.tight_layout()
    fig.savefig("6-1-lpf.png", dpi=150)

    at = rf.Frequency.from_f(READ_AT, unit="Hz")
    a, b = meas.interpolate(at), ideal(at)  # 実測は隣の点から線形に補間、理想はその周波数で計算
    for k, f in enumerate(READ_AT):
        print(f"{f/1e6:5.1f} MHz  S21 実測 {a.s_db[k, 1, 0]:7.2f} dB  理想 {b.s_db[k, 1, 0]:7.2f} dB"
              f"  差 {a.s_db[k, 1, 0] - b.s_db[k, 1, 0]:+.2f} dB")


if __name__ == "__main__":
    main()
```

- `rf.Network()` は拡張子で 1 ポートか 2 ポートかを決め、`# HZ S RI R 50` の行から形式と基準のインピーダンスを読む。
  `RI` `MA` `DB` のどれでも同じに読む (10-1 の手書きの読み込みとの違い)
- `s_db[周波数, 出る側, 入る側]` で、`[k, 1, 0]` が S21、`[k, 0, 0]` が S11。`plot_s_db(m=1, n=0)` も同じ並び
- 理想は `DefinedGammaZ0` (50 Ω (オーム) の理想の線路の媒体) の `shunt_capacitor` と `inductor` を `**` (縦続) でつなぐ。
  `dut:` の行の並び (図1) と 1 対 1 で、CH0 側から書く
- 表の周波数は測った点の上に無い (201 点の点の間隔は 0.495 MHz)。`interpolate()` で隣の 2 点から線形に補間する。
  急な所 (28.4 MHz の近くは 1 MHz で約 1 dB 動く) では補間の誤差が 0.03 dB ほど出る。点数を上げれば減る
- 凡例を英字にしたのは、matplotlib の既定の字体に日本語の字が無く、豆腐 (□) になるため。
  日本語にするなら日本語の字体を入れて `plt.rcParams["font.family"]` に名前を書く

このスクリプトは NanoVNA で保存したファイルでは**まだ動かしていない** (実機は未確認)。PC で、6-1 の値の部品に
「28.4 MHz で Q 約 50 のコイル」(330 nH に 1.18 Ω、560 nH に 2.0 Ω の直列抵抗。仮定) を入れて計算した S パラメータに、
実部・虚部で標準偏差 0.0005 の雑音を足した 201 点の `6-1-lpf.s2p` を Saver と同じ形で作り、
scikit-rf 2.2.0・matplotlib 3.11.2 で動かした。PNG には実測の実線と理想の破線が重なり、
雑音の分だけ −50 dB より下で実線がばらつく。表は次のとおり出た。

| 周波数 | 実測 (合成の `.s2p`、補間) | 理想 | 差 |
| --- | --- | --- | --- |
| 20 MHz | −0.55 dB | −0.06 dB | −0.49 dB |
| 28.4 MHz | −3.67 dB | −2.98 dB | −0.68 dB |
| 40 MHz | −19.84 dB | −19.55 dB | −0.29 dB |

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| — | 測る物 | 6-1 の 7 次 LC ローパス (perfboard) |
| — | 計器 | NanoVNA-H4 (または LiteVNA64)、PC (NanoVNA-Saver、Python 3、scikit-rf、matplotlib) |
| — | 電源 | 使わない |

## 見るべき値

理想の列は計算値。実測の列は 6-1 を測って書き込む。

| 周波数 | S21 の理想 | 図1 の読み値 | 実測 (書き込む) | 分かること |
| --- | --- | --- | --- | --- |
| 20 MHz | −0.06 dB | −0.06 dB | | 通過域の損失。コイルの Q で 0.5 dB ほど下がる (6-1) |
| 28.4 MHz | −2.98 dB | −2.98 dB | | カットオフの所。ずれると −3 dB の周波数が動く |
| 40 MHz | −19.55 dB | −19.55 dB | | 遮断の傾き。部品の誤差 (6-11) が効く |

- **理想の列が図1 (VNA の画面) と Python の両方で同じ数になること**が、スクリプトの理想の組み方が `dut:` と同じだという確かめになる
- 実測と理想の差が、通過域で 1 dB を超えるなら、校正の面 (治具の SMA) を疑う。差がどの周波数でも同じ符号で
  周波数とともに増えるなら、コイルの損失 (Q) の形
- 図にする前に、10-1 のスクリプトでファイルの組を確かめておく

## LTspice での確かめ

`sim/02-skrf-plot.cir` で、6-1 の 7 次ローパスを AC 解析にかけた。回路 a は理想 (図1・スクリプトの理想)、
回路 b は試験に使った合成の「実測」(コイルに直列の 1.18 Ω と 2.0 Ω。仮定) で、どちらも実測ではない。

| 周波数 | 本文の理想 | LTspice (a) | 合成の実測の補間 | LTspice (b) | 判定 |
| --- | --- | --- | --- | --- | --- |
| 20 MHz | −0.06 dB | −0.06 dB | −0.55 dB | −0.54 dB | 合う |
| 28.4 MHz | −2.98 dB | −2.98 dB | −3.67 dB | −3.64 dB | 合う (差 0.03 dB は線形補間の誤差) |
| 40 MHz | −19.55 dB | −19.55 dB | −19.84 dB | −19.85 dB | 合う |

理想の 3 つは 6-1 の LTspice の表 (−0.06・−2.98・−19.55 dB) とも同じ。Q 約 50 は 2π (π (パイ) は円周率) × 28.4 MHz × 330 nH ÷ 1.18 Ω = 49.9 (算術)。

## 出典

自作。関数 (`Network`・`DefinedGammaZ0`・`interpolate`・`plot_s_db`・`plot_s_smith`) は
[scikit-rf Documentation](https://scikit-rf.readthedocs.io/en/latest/)。

参考: [Touchstone file (Wikipedia)](https://en.wikipedia.org/wiki/Touchstone_file)、[Matplotlib](https://matplotlib.org/)
