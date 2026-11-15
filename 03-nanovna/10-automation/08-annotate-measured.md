---
book: nanovna
chapter: 10
id: 10-8
title: 測った値を tommie-fence の図に注釈で載せる
tier: 200
source: 自作 (図は tommie-fence の vna フェンス)
board: —
device: H4
---

# 10-8 測った値を tommie-fence の図に注釈で載せる

同じ題名の Analog Discovery の教科書の 11-8 が本体で、そちらは CSV を graph・scope フェンスに重ねる。この題は、
**VNA の Touchstone (`.s2p`) を vna フェンスに重ねるときに変わる所**だけを書く。例は 10-7 の 3 次ローパス。

| | Analog Discovery の 11-8 | この題 (VNA) |
| --- | --- | --- |
| 重ねるファイル | CSV (1 列めが x、見出しの括弧が単位) | Touchstone (`.s1p` / `.s2p`)。Saver が書いたまま、直さずに読む |
| 重ね方 | `data:` の 1 行。graph は ○、scope は実線 | `data:` の 1 行。実測が実線、理想 (`dut:`) が破線になる |
| 本文の数を図に出す | `notes:` の `mark` `text`、scope は `cursors:` と `measure:` | **`markers:` が読み値の表を作る** (実測があれば実測を読む)。`notes:` の `text` は「周波数 値」の番地 |
| マーカーの読み | — | 実測では**一番近い点に吸い付く**。理想 (`dut:`) では書いた周波数で計算する |

手順は 11-8 と同じ:

1. 測った `.s2p` を、題の `.md` と同じ場所に置く (`data:` は同じ場所のファイルだけを読む。`/` や `..` は書けない)
2. vna フェンスに `data: <ファイル名>.s2p` を足す。読み値の表の見出しが「読み値 — 実測 (ファイル名)」に変わる
3. マーカーの読み値を本文の「見るべき値」の表に写し、`notes:` の `text` で要る数を図にも書く
4. 理想の数と比べ、合わなければ本文を実測に合わせて、差の理由を 1 行書く
5. front matter に `measured: <測った日>` を書く (README の「書き方」)。`.s2p` はコミットする

この題は回路図と実体配線図を付けない — 図の書き方の題で、測る物は 10-7 の図1・図2 のローパス。

## 掃引の設定

計器は VNA (NanoVNA-H4。標準の LiteVNA64 でも同じ)。AD3 とオシロは使わない (S パラメータを見る題)。設定は 10-7 と同じ。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜10 MHz |
| 点数 | 91 (0.1 MHz おき。マーカーの 3・5・7・10 MHz がちょうど点の上に来る) |
| 校正 | SOLT。ケーブルの先 |
| 保存 | `10-7-lpf.s2p` (10-1 の決まり) |

**マーカーは掃引の点の上に置く。** 実測の読みは一番近い点に吸い付くので、点の間のマーカーは別の周波数の値を読む。
理想の読みは書いた周波数で計算するので、点の外に置くと理想と実測が違う周波数を言う。範囲と点数は、
(終了 − 開始) ÷ (点数 − 1) が切りのいい数になるように選ぶ (ここでは 9 MHz ÷ 90 = 0.1 MHz)。

測る前の図。注釈の字には理想の数を書いておき、測ったら実測の数に書き換える。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-10M 91
title: 図1 10-7 のローパス — 測る前は理想の数を注釈に
dut:
  - shunt C 680p
  - series L 3.3u
  - shunt C 680p
traces:
  - S21 logmag
  - S11 smith
markers:
  - 3M
  - 5M
  - 7M
  - 10M
notes:
  - text 1.5M -40dB: 3 MHz で −0.24 dB (理想)
  - text 1.5M -48dB: 5 MHz で −3.67 dB (理想)
  - text 1.5M -56dB: 7 MHz で −10.51 dB (理想)
  - text 1.5M -64dB: 10 MHz で −19.51 dB (理想)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/08-annotate-measured.svg)

測ったら、図1 のフェンスに次の 1 行を足し、注釈を実測の数に替える (`dut:` は残す。理想が破線で残り、実測と比べられる)。

```yaml
data: 10-7-lpf.s2p
notes:
  - text 1.5M -40dB: 3 MHz で −0.41 dB (実測)
  - text 1.5M -48dB: 5 MHz で −3.79 dB (実測)
  - text 1.5M -56dB: 7 MHz で −10.53 dB (実測)
  - text 1.5M -64dB: 10 MHz で −19.59 dB (実測)
```

(上の数は、下の試験で使った合成のファイルの値。実測ではない)

- 計算で作った `.s2p` (シミュレータ・scikit-rf・メーカーの S パラメータ) を重ねるときは、ファイル名の後ろに名前を書く
  (`data: 10-7-sim.s2p 計算`)。凡例と読み値の見出しが「計算 (…)」になり、実測と取り違えない
- 注釈の字に `,` は書けない。数を並べるときは `・` で区切る (11-8 と同じ)
- `.s2p` の S12・S22 の列は描かない (VNA は S11 と S21 だけを測る)。10-6 のスクリプトのように 0 を書いたファイルでも読める

## 表と注釈の行を作るスクリプト

マーカーの読み値は、フェンスの `check` が出す表と同じ数を、本文の表と注釈に写す。手で写すと桁を間違えるので、
`.s2p` から**フェンスと同じ選び方 (一番近い点)** で読み、本文の表の行と `notes:` の行をそのまま貼れる形で出す。
`python marker_notes.py 10-7-lpf.s2p` (scikit-rf、10-2)。

```python
import math
import sys

import skrf as rf

MARKERS = [3e6, 5e6, 7e6, 10e6]   # 図のマーカーと同じ周波数 [Hz]
TEXT_AT = "1.5M"                  # 注釈の字を置く周波数 (図の左の空いた所)


def minus(x, fmt):
    """負の数の頭を、本文と同じマイナス (U+2212) にする。"""
    return format(x, fmt).replace("-", "−")


def main():
    ntw = rf.Network(sys.argv[1])
    print("| 周波数 | S21 (実測) |")
    print("| --- | --- |")
    rows = []
    for f in MARKERS:
        i = min(range(len(ntw.f)), key=lambda k: abs(ntw.f[k] - f))   # vna フェンスと同じく一番近い点に吸い付く
        db = 20 * math.log10(abs(ntw.s[i, 1, 0]))
        rows.append((ntw.f[i], db))
        print(f"| {ntw.f[i] / 1e6:g} MHz | {minus(db, '.2f')} dB |")
    print("notes:")
    for k, (f, db) in enumerate(rows):
        y = -40 - 8 * k                                   # 字を縦に 8 dB ずつずらして重ねない
        print(f"  - text {TEXT_AT} {y}dB: {f / 1e6:g} MHz で {minus(db, '.2f')} dB (実測)")


if __name__ == "__main__":
    main()
```

このスクリプトは NanoVNA で保存したファイルでは**まだ動かしていない** (実機は未確認)。PC で、10-7 のローパスのコイルに 1.5 Ω (オーム) の直列抵抗を
足した (仮定) S パラメータに標準偏差 0.0005 の雑音を足した 91 点の `10-7-lpf.s2p` を作って動かし (scikit-rf 2.2.0)、上の `notes:` の 4 行を得た。
同じファイルを `data: 10-7-lpf.s2p 合成` として図1 のフェンスに重ねた試しの図を作業用の場所で描くと、vna フェンス (0.10.0) の
`check` の読み値は「読み値 — 合成 (10-7-lpf.s2p)」の見出しで 3・5・7・10 MHz が −0.41・−3.79・−10.53・−19.59 dB と出て、
スクリプトの 4 つと桁まで同じだった。実測が破線の理想の上に実線で重なることも PNG で見た。

## 見るべき値

計算値。図1 の読み値 (`check`) と本文の数の突き合わせ。

| マーカー | `check` の読み値 (理想) | 本文の数 (10-7 の表) | 測ったら |
| --- | --- | --- | --- |
| 3 MHz | −0.24 dB | −0.24 dB | 実測の読み値を表と注釈に写す |
| 5 MHz | −3.67 dB | −3.67 dB | 同上 |
| 7 MHz | −10.51 dB | −10.51 dB | 同上 |
| 10 MHz | −19.51 dB | −19.51 dB | 同上 |

- 理想と実測の差がどの周波数でも同じ向き (下) で、通過域ほど小さく見えるなら、コイルの損失 (上の試験では 1.5 Ω で 3 MHz が 0.17 dB 下がった)
- `data:` を足しても読み値の見出しが「理想」のままなら、ファイルが同じ場所に無いか、名前が違う (お知らせが図の下の帯に出る)
- 測った `.s2p` は消さずにコミットする (図の元になる)。図の SVG・PNG はコミットしない

## LTspice での確かめ (対象外)

回路を足さない、図の書き方の題なので SPICE の対象外。図1 の理想の数は 10-7 の LTspice の表 (`sim/07-ad-vs-vna.cir`、
−0.24・−3.67・−10.51・−19.51 dB) と同じ。点の間隔は (10 − 1) MHz ÷ (91 − 1) = 0.1 MHz で、3・5・7・10 MHz はちょうど点の上に来る (算術)。

## 出典

自作。図のフェンスの書き方 (`data:`・`markers:`・`notes:`、読み値の選び方) は [tommie-fence](https://github.com/tommie-jp/tommie-fence) の
vna フェンスの文法。関数 (`Network`) は [scikit-rf Documentation](https://scikit-rf.readthedocs.io/en/latest/)。
