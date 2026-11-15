---
book: nanovna
chapter: 10
id: 10-7
title: AD 本の測定と突き合わせる (1〜10 MHz)
tier: 200
source: 自作 (関数は scikit-rf のドキュメント)
board: PF
device: H4
tools: [AD, VNA]
---

# 10-7 AD 本の測定と突き合わせる (1〜10 MHz)

1〜10 MHz は、Analog Discovery 3 (AD3) の Network と VNA の両方で測れる帯である (AD の教科書の 8-8 はスルーで
両方を比べた)。この題は、同じ 3 次 LC ローパスを 2 つの計器で測り、**2 つの数が同じ物を言っているか**を Python で突き合わせる。

そのままでは数が合わない。2 つの計器は**違う量**を測っているからである。

| | VNA の S21 | AD3 の Network の読み (CH2/CH1) |
| --- | --- | --- |
| 入口の側 | 50 Ω (オーム) の信号源。フィルタの入口の電圧は、入口の Z で変わる | CH1 が**フィルタの入口の電圧そのもの**を測り、それで割る |
| 出口の側 | 50 Ω の終端 | 出口に 3-4 の Load (50 Ω) を付け、CH2 (1 MΩ ∥ 24 pF) で測る |
| 測る量 | S21 = 2V<sub>出口</sub> / E<sub>信号源</sub> | H = V<sub>出口</sub> / V<sub>入口</sub> |

入口の電圧は V<sub>入口</sub> = E (1 + S11) / 2 なので、**H = S21 / (1 + S11)** (出口が 50 Ω のとき)。VNA は S11 も測るので、
VNA の `.s2p` から「AD3 が読むはずの値」を計算できる。これと AD3 の読みが合えば、2 つの計器は同じフィルタを同じに見ている。

## 回路図

部品は 3 次バターワースを E12 に丸めた値 (C 637 pF → 680 pF、L 3.18 µH (マイクロヘンリー) → 3.3 µH。−3 dB は設計の 5 MHz より低い 4.77 MHz)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 3 次ローパスを AD3 で測るつなぎ (VNA は J1 に CH0・J2 に CH1)
parts:
  M1:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery 3
    pins: [2+, W1, 1+, GND]
  J1: sma 5,4 mirror
  C1: capacitor 7,4 7,6 680p
  L1: inductor 8,4 10,4 3.3u
  C2: capacitor 11,4 11,6 680p
  RL1: resistor 13,4 13,6 100
  RL2: resistor 15,4 15,6 100
  J2: sma 17,4
  G1: ground 5,6
  G2: ground 7,6
  G3: ground 11,6
  G4: ground 13,6
  G5: ground 15,6
  G6: ground 17,6
  G7: ground 3,4
wires:
  - J1.1 -- 6,4 -- 7,4 -- 8,4
  - 10,4 -- 11,4 -- 13,4 -- 15,4 -- 16,4 -- J2.1
  - M1.W1 -| 6,4
  - M1.1+ -| 6,4
  - M1.2+ -| 16,4
  - M1.GND -| 3,4
  - J1.2 -- 5,6
  - J2.2 -- 17,6
notes:
  - text 5,3 blue center: IN
  - text 16.6,3 blue center: OUT
  - text 14,7.2 blue center: 3-4 の Load (100 Ω を 2 本並列)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/circuit/07-ad-vs-vna.svg)

- AD3 は BNC アダプタの W1・CH1・CH2 から SMA の T 形アダプタ (オス 1・メス 2) を通してつなぐ。J1 の T に W1 と CH1、
  J2 の T に CH2 と 3-4 の Load (RL1 ∥ RL2 = 50 Ω) を挿す。RL1・RL2 は基板の外 (Load の中) にある
- VNA で測るときは T を外し、J1 に CH0、J2 に CH1 を直に挿す (VNA の CH1 が 50 Ω の終端を兼ねる)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 3 次ローパス (C1・L1・C2) を端面 SMA の間に
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  C1: capacitor/ceramic f10 f7 680p
  L1: inductor h10 k10 3.3u
  C2: capacitor/ceramic m10 m7 680p
wires:
  - a10 -- f10
  - f10 -- h10
  - k10 -- m10
  - m10 -- x10
  - 09 -- 07 black
  - 07 -- f7 black
  - f7 -- m7 black
  - m7 -- y7 black
  - y7 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/perfboard/07-ad-vs-vna.svg)

- 3-1 の直列治具と同じ板の作り。信号は 10 行、GND は 7 行の線で、両端を縁の穴で 9 行の SMA の凹の腕へ上げる。
  C1・C2 は 10 行と 7 行にまたがって立て、GND の線は C1・C2 のピンの穴で区切る (つなぐのは線の端の穴だけなので)
- 10 MHz 以下なので、部品はリード付き (セラミック・アキシアルのインダクタ) でよい (README の「部品の形」)。リードは短く切る

## 計器の設定

計器は VNA (NanoVNA-H4。標準の LiteVNA64 でも同じ) と AD3 の Network。オシロの図は付けない (AD3 は Network の利得を、VNA は S パラメータを見る題)。

| 計器 | 設定 |
| --- | --- |
| VNA | 1 MHz〜10 MHz、91 点 (0.1 MHz おき)。SOLT はケーブルの先 (J1・J2 に挿す手前)。保存は `10-7-lpf.s2p` |
| AD3 Network | BNC アダプタ。Start 1 MHz、Stop 10 MHz、101 点 (対数)、W1 の振幅 0.2 V、Reference = CH1、DUT = CH2。書き出しは `10-7-ad.csv` |
| AD3 の補正 | 先に J1・J2 の T どうしをスルーでつないで掃引し、Network の補正 (AD の教科書の 5-8) を取る。10 MHz の近くの AD3 自身の落ち込みを除くため |

- W1 の振幅を 0.2 V にするのは、10 MHz で入口の Z が下がる (C1 の 680 pF は 10 MHz で −j23 Ω) ときの電流を 10 mA ほどに抑えるため (目安)
- AD3 の CH1・CH2 の比なので、W1 の出力の Z と振幅の誤差は消える

VNA で見えるはずの画面。マーカーは突き合わせの表の周波数。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-10M 91
title: 図3 3 次ローパスの S21 と S11 — 5 MHz で S21 −3.67 dB
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
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/07-ad-vs-vna.svg)

## 突き合わせるスクリプト

`pip install scikit-rf` (10-2)。`python compare_ad.py 10-7-lpf.s2p 10-7-ad.csv` と打つと、表の 5 つの周波数で、AD3 の読み・
VNA から予想した AD3 の読み・その差・VNA の S21 を並べる。

```python
import csv
import sys

import numpy as np
import skrf as rf

READ_AT = [1e6, 3e6, 5e6, 7e6, 10e6]   # 本文の表の周波数 [Hz]


def read_ad(path):
    """WaveForms の Network の書き出し (CSV) から、周波数と CH2/CH1 の dB の 2 列を読む。数で始まらない行は飛ばす。"""
    f, db = [], []
    with open(path, encoding="utf-8") as fp:
        for row in csv.reader(fp):
            try:
                f.append(float(row[0]))
                db.append(float(row[1]))
            except (ValueError, IndexError):
                continue                    # 見出しと '#' の行
    return np.array(f), np.array(db)


def main():
    vna = rf.Network(sys.argv[1])           # VNA で測った .s2p (CH0 = J1、CH1 = J2)
    f_ad, db_ad = read_ad(sys.argv[2])      # AD3 の Network の CSV (CH1 = J1、CH2 = J2 と 50 Ω)
    s11, s21 = vna.s[:, 0, 0], vna.s[:, 1, 0]
    h = s21 / (1 + s11)                     # 入口の電圧に対する出口の電圧 (AD3 が測る量)
    pred = 20 * np.log10(np.abs(h))
    s21_db = 20 * np.log10(np.abs(s21))
    print(" 周波数    AD3 の読み  VNA から予想  差      VNA の S21")
    for f in READ_AT:
        a = np.interp(f, f_ad, db_ad)        # どちらも点の間は線形に補って、同じ周波数で比べる
        p = np.interp(f, vna.f, pred)
        s = np.interp(f, vna.f, s21_db)
        print(f"{f / 1e6:6.2f} MHz  {a:7.2f} dB  {p:7.2f} dB  {a - p:+5.2f} dB  {s:7.2f} dB")


if __name__ == "__main__":
    main()
```

- WaveForms の Network の書き出しは、頭に `#` の行と見出しの行があり、1 列めが周波数 (Hz)、2 列めが CH2 の大きさ (dB) の並び
  (目安。版で違うことがあるので、書き出した CSV の頭を開いて列を確かめる。AD の教科書の 11-4 と同じ注意)
- `S21 / (1 + S11)` は、出口が 50 Ω で終わっているときの式。AD3 の側で Load を付け忘れると合わない (出口が 1 MΩ になる)

このスクリプトは、どちらの計器で測ったファイルでも**まだ動かしていない** (実機は未確認)。PC で、理想の部品の S パラメータに標準偏差 0.0005 の
雑音を足した 91 点の `.s2p` と、出口に CH2 の入力 (1 MΩ ∥ 24 pF) を付けた H を 101 点 (対数) で書いた CSV (頭に `#` の 2 行と見出しの 1 行)
を作って動かした (scikit-rf 2.2.0)。差は 1 MHz と 3 MHz で +0.02・+0.04 dB、5・7・10 MHz で −0.14・−0.23・−0.26 dB と出た。
この差は CSV にわざと入れた CH2 の 24 pF の分で、下の表の「24 pF の分」の列と合う。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| C1・C2 | セラミックコンデンサ (リード付き、CH 特性) | 680 pF |
| L1 | アキシアルのインダクタ (カラーコード付き) | 3.3 µH |
| RL1・RL2 | 3-4 の Load の 100 Ω 2 本 (並列で 50 Ω) | 100 Ω |
| J1・J2 | 端面 SMA (メス) | 3-1 と同じ作り |
| — | SMA の T 形アダプタ 2 個、BNC-SMA の変換ケーブル 3 本 | AD3 のときだけ |
| — | 計器 | NanoVNA-H4、AD3 (BNC アダプタ)、PC (NanoVNA-Saver、WaveForms、Python 3、scikit-rf) |
| — | 電源 | 使わない (W1 と VNA の出力だけ) |

## 見るべき値

計算値 (理想の部品)。AD3 の列は CH2 の入力 (1 MΩ ∥ 24 pF) を入れた値。

| 周波数 | VNA の S21 | VNA から予想した AD3 (S21/(1+S11)) | AD3 の読み (24 pF 込み) | 24 pF の分 |
| --- | --- | --- | --- | --- |
| 1 MHz | −0.00 dB | −0.01 dB | +0.01 dB | +0.02 dB |
| 3 MHz | −0.24 dB | −2.01 dB | −1.98 dB | +0.03 dB |
| 5 MHz | −3.67 dB | −7.62 dB | −7.76 dB | −0.14 dB |
| 7 MHz | −10.51 dB | −12.92 dB | −13.15 dB | −0.23 dB |
| 10 MHz | −19.51 dB | −18.97 dB | −19.24 dB | −0.27 dB |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 同じローパスでも VNA の S21 と AD3 の読みは 4 dB 違う (5 MHz)
x: 周波数 Hz 1M..10M
y: 利得 dB -25..5
lines:
  VNA の S21 dB:
    - 1M -0.00
    - 2M -0.02
    - 3M -0.24
    - 4M -1.26
    - 5M -3.67
    - 6M -7.01
    - 7M -10.51
    - 8M -13.80
    - 9M -16.80
    - 10M -19.51
  AD3 の読み dB:
    - 1M 0.01
    - 2M -0.37
    - 3M -1.98
    - 4M -4.73
    - 5M -7.76
    - 6M -10.60
    - 7M -13.15
    - 8M -15.41
    - 9M -17.42
    - 10M -19.24
notes:
  - mark 5M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/graph/07-ad-vs-vna.svg)

- **2 本の線の差 (5 MHz で約 4 dB) は計器の誤差ではなく、測る量の違い**。S21/(1+S11) で直すと、差は CH2 の入力容量の分 (0.3 dB 以下) まで縮む
- 直した後の差が 1 dB を超えるなら、AD3 の補正 (スルー) を取り忘れたか、Load を付け忘れたか、VNA の校正の面が J1・J2 からずれている
- 10 MHz より上は AD3 の範囲の外。そこから先は VNA だけで追う (3-6・6-1)。逆に 1 MHz より下は AD3 の方が確かに測れる帯で、AD の教科書に任せる

## LTspice での確かめ

`sim/07-ad-vs-vna.cir` で、同じローパスを 3 つの条件で解いた: 50 Ω の信号源と終端 (VNA の S21)、入口を電圧源で決めて出口を 50 Ω (AD3 の H)、
それに CH2 の 1 MΩ ∥ 24 pF を足したもの。理想の模型で、実測ではない。

| 周波数 | 本文 (S21 / H / 24 pF 込み) | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 MHz | −0.00 / −0.01 / +0.01 dB | −0.00 / −0.01 / +0.01 dB | 合う |
| 3 MHz | −0.24 / −2.01 / −1.98 dB | −0.24 / −2.01 / −1.98 dB | 合う |
| 5 MHz | −3.67 / −7.62 / −7.76 dB | −3.67 / −7.62 / −7.76 dB | 合う |
| 7 MHz | −10.51 / −12.92 / −13.15 dB | −10.51 / −12.92 / −13.15 dB | 合う |
| 10 MHz | −19.51 / −18.97 / −19.24 dB | −19.51 / −18.97 / −19.24 dB | 合う |

H の列は Python で S21/(1+S11) から出した値 (−0.01・−2.01・−7.62・−12.92・−18.97 dB) とも同じ。設計の値は C = 1 / (2π × 5 MHz × 50 Ω) = 637 pF、
L = 2 × 50 Ω / (2π × 5 MHz) = 3.18 µH (π (パイ) は円周率。算術)。

## 出典

自作。関数 (`Network`) は [scikit-rf Documentation](https://scikit-rf.readthedocs.io/en/latest/)。AD3 の Network の操作は
Digilent の Using the Network Analyzer (WaveForms のガイド。機械の取得を断るので URL は付けない)。

参考: [Butterworth filter (Wikipedia)](https://en.wikipedia.org/wiki/Butterworth_filter)、[Scattering parameters (Wikipedia)](https://en.wikipedia.org/wiki/Scattering_parameters)
