---
book: nanovna
chapter: 10
id: 10-3
title: 部品 10 個のバッチ測定
tier: 200
source: 自作 (関数は scikit-rf のドキュメント)
board: PF
device: H4
---

# 10-3 部品 10 個のバッチ測定

同じ題名の Analog Discovery の教科書の 11-3 が本体で、そちらは 1 kΩ (キロオーム) の抵抗 10 本を分圧で測り、CSV に書いて
平均・ばらつき・公差の外を数える。この題は**同じバッチを VNA で行うときに変わる所**だけを書く。

| | Analog Discovery の 11-3 | この題 (VNA) |
| --- | --- | --- |
| 測る物 | 1 kΩ の抵抗 10 本 (±5 %) | **100 pF のセラミックコンデンサ 10 個 (CH 特性、±5 %)** |
| 測り方 | 基準の抵抗との分圧を SDK で読む | 3-1 の直列治具の S21 から Z を出す |
| 1 個ごとの記録 | Enter を押すと SDK が測って CSV に 1 行 | Saver で 1 個ずつ `.s2p` に保存 (名前に題の番号と部品の番号を付ける) |
| 計算 | 1 点の DFT → 分圧の式を逆に解く | scikit-rf で `.s2p` を読む → Z → C |
| 基準 | R1 (±1 %) が平均を決める | **校正 (SOLT) と、治具の線の引き算**が平均を決める |

周波数は 10 MHz にする。100 pF のリアクタンスは −j159 Ω で 50 Ω の系と同じ桁になり、S21 が 0 dB にも
−∞ にも寄らないので、Z の読みが一番安定する所に近い (11-3 で R1 と R<sub>x</sub> を同じくらいにしたのと同じ考え)。

## 直列治具で Z を出す式と、治具の線

直列治具の S21 は、CH0 と CH1 の間の Z だけで決まる: S21 = 2Z<sub>0</sub> / (2Z<sub>0</sub> + Z)。逆に解くと
**Z = 2Z<sub>0</sub> (1 − S21) / S21** (Z<sub>0</sub> = 50 Ω)。容量は C = −1 / (2πf × Im Z) (π (パイ) は円周率)。

ただし、校正の面は治具の SMA の面なので、Z には**治具の上の線のインダクタンス**が乗る。3-1 の見積りでは線全体で
約 52 nH、部品の 3 穴を除くと約 45 nH (目安) で、10 MHz で +j2.83 Ω。そのまま 100 pF を読むと
1 / (1 − ω²LC) = 1.018 倍 (ω (オメガ) = 2πf)、**+1.8 %** 大きく出る。公差 ±5 % のばらつきを見る題では無視できない。
そこで、**部品の代わりに太い銅線を挿した掃引を 1 回保存し、その Z を全部の部品の Z から引く** (3-8 の
De-embedding のいちばん簡単な形。直列の Z を引くだけ)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 直列治具に 100 pF を挿す (挿し替えて 10 回)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 6,2 100p
  J2: sma 8,2 CH1
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 5,3.2 blue center: C1 の代わりに銅線も 1 回測る
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/circuit/03-batch-measurement.svg)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 3-1 の直列治具の f10〜i10 に 100 pF を挿し替える
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  C1: capacitor/ceramic f10 i10 100p
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/perfboard/03-batch-measurement.svg)

- 3-1 の治具の部品の穴 (f10・i10) に、IC ソケットのばらしたピン 2 本を半田付けしておくと、半田ごてを当てずに 10 個を挿し替えられる。
  ピンの分の線も「治具の線」に入り、銅線の掃引で一緒に引かれる
- コンデンサのリードは毎回同じ長さ (根元から 3 mm) で切る。リードの長さの違いは引かれずに残る
- 銅線は部品と同じ穴に、同じ長さで挿す (引く Z の基準なので)

## 掃引の設定

計器は VNA (NanoVNA-H4。標準の LiteVNA64 でも同じ)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜21 MHz (点の間隔 0.2 MHz。10 MHz がちょうど点の上に来る) |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) |
| 保存 | 銅線を `10-3-wire.s2p`、部品を `10-3-c01.s2p`〜`10-3-c10.s2p` |
| 表示 | S21 の Log Mag と位相 |

治具の線 45 nH と 100 pF (ESL 5 nH、目安) を挿したときに見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-21M 101
title: 図3 治具の線 45 nH と 100 pF — 10 MHz で −5.36 dB・+57.3°
dut:
  - series L 45n
  - series C 100p esl 5n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/03-batch-measurement.svg)

S21 の位相が正 (進み) なのは容量性だから。銅線だけなら 10 MHz で −0.00 dB・−1.6° (誘導性で遅れ) になる。

## 計算するスクリプト

`pip install scikit-rf` (10-2)。`python batch_c.py 10-3-wire.s2p '10-3-c*.s2p'` と打つと、`batch_c.csv` を書き、
平均・標準偏差・最小・最大・公差の外のファイル名を出す。

```python
import csv
import glob
import math
import statistics
import sys

import skrf as rf

F = 10e6          # 容量を読む周波数 [Hz] (掃引の点の上)
NOMINAL = 100e-12  # 公称 100 pF
TOL = 0.05        # 公差 ±5 % (J)
Z0 = 50.0


def z_series(path):
    """直列治具の S21 から、CH0 と CH1 の間の Z を出す: Z = 2·Z0·(1 − S21) / S21。"""
    ntw = rf.Network(path).interpolate(rf.Frequency.from_f([F], unit="Hz"))
    s21 = ntw.s[0, 1, 0]
    return 2 * Z0 * (1 - s21) / s21


def main():
    z_wire = z_series(sys.argv[1])            # 部品の代わりに太い銅線を挿して保存したもの
    print(f"治具の線: {z_wire.real:.2f} Ω + j{z_wire.imag:.2f} Ω "
          f"(L = {z_wire.imag / (2 * math.pi * F) * 1e9:.1f} nH)")
    rows = []
    for path in sorted(glob.glob(sys.argv[2])):
        z = z_series(path) - z_wire               # 治具の線の分を引く
        c = -1 / (2 * math.pi * F * z.imag)        # X = −1 / (ωC)
        rows.append((path, c))
    with open("batch_c.csv", "w", newline="", encoding="utf-8") as fp:
        w = csv.writer(fp)
        w.writerow(["ファイル", "容量 (pF)", "ずれ (%)"])
        for path, c in rows:
            w.writerow([path, f"{c * 1e12:.2f}", f"{(c / NOMINAL - 1) * 100:+.2f}"])
    cs = [c * 1e12 for _, c in rows]
    bad = [p for p, c in rows if abs(c / NOMINAL - 1) > TOL]
    print(f"{len(cs)} 個  平均 {statistics.mean(cs):.2f} pF  標準偏差 {statistics.stdev(cs):.2f} pF")
    print(f"最小 {min(cs):.2f} pF  最大 {max(cs):.2f} pF  公差の外 {bad or 'なし'}")


if __name__ == "__main__":
    main()
```

- 11-3 の `report()` と同じ形の CSV を書くので、Analog Discovery の教科書の 11-4 の matplotlib の図がそのまま使える
  (列の名前の「抵抗 (Ω)」を「容量 (pF)」に読み替える)
- 引くのは Z (複素数) で、S21 や dB ではない。直列の Z は足し算なので、引き算で除ける
- ESL (部品のリードの 5 nH、目安) は引かれずに残り、10 MHz では 1 / (1 − ω²LC) = **+0.2 %** 大きく読む。
  10 個に同じように効くので、ばらつき (標準偏差) には効かない

このスクリプトは NanoVNA で保存したファイルでは**まだ動かしていない** (実機は未確認)。PC で、治具の線 45 nH・ESL 5 nH と、
96.5〜107.0 pF の 10 個 (1 個だけ 107 pF にして公差の外を作った) の S パラメータを計算し、実部・虚部に標準偏差 0.0005 の雑音を
足した 11 個の `.s2p` を Saver と同じ形で作って動かした (scikit-rf 2.2.0)。治具の線は「44.7 nH」と読み、各部品の容量は
本当の値の 1.002 倍 (ESL の分) から ±0.15 pF 以内、`公差の外` には `10-3-c07.s2p` だけが出た。銅線を引かないと、
全部が約 1.8 % 大きく出ることも同じ合成のファイルで確かめた。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| C1 | セラミックコンデンサ (リード付き、CH 特性、±5 %、50 V) を 10 個 | 100 pF |
| — | 銅線 (すずめっき線 0.6 mm) | C1 と同じ穴・同じ長さ |
| J1・J2 | 端面 SMA (メス) | 3-1 の直列治具 |
| — | 計器 | NanoVNA-H4、PC (NanoVNA-Saver、Python 3、scikit-rf) |
| — | 電源 | 使わない |

## 見るべき値

計算値 (治具の線 45 nH・ESL 5 nH は目安)。

| 項目 | 値 | 分かること |
| --- | --- | --- |
| 銅線の S21 (10 MHz) | −0.00 dB・−1.6°。スクリプトの読みは L ≈ 45 nH | 治具の線の大きさ。3-1 の見積りと比べる |
| 100 pF の S21 (10 MHz、図3) | −5.36 dB・+57.3° | 読みが Z の計算に向く所にある |
| 引かないで読んだ 100 pF | 102.0 pF (+2.0 %) | 治具の線の誤差が公差の半分近くになる |
| 引いて読んだ 100 pF | 100.2 pF (+0.2 %、ESL の分) | 残るのは部品そのもののリード |
| 10 個の平均・標準偏差 | 測って書く | CH 特性 ±5 % の中に並ぶか。並び方の読み方は 4-28 |

- 1 個の読みに乗る雑音は、上の合成の試験で ±0.15 pF ほど。**IF の帯域を狭くする (2-9) か、Saver の平均 (Averaged sweep) で減る**
- 校正をやり直したら、銅線の掃引も取り直す (引く基準は校正と組で使う。10-5)

## LTspice での確かめ

`sim/03-batch-c.cir` で、治具の線 45 nH だけの回路と、45 nH + 95・100・105 pF (ESL 5 nH) の回路を 10 MHz で解き、
S21 の実部・虚部から Z と C を出した (スクリプトと同じ式)。理想の模型で、実測ではない。読み値の虚部は符号が落ちて返るので、
符号は位相から付けた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 銅線の Z | +j2.83 Ω (45 nH) | +j2.827 Ω (45.0 nH) | 合う |
| 100 pF の S21 (図3) | −5.36 dB・+57.3° | −5.36 dB・+57.3° | 合う |
| 100 pF、引かない | 102.0 pF | 102.01 pF | 合う |
| 95・100・105 pF、引いた後 | 95.2・100.2・105.2 pF (+0.2 %) | 95.18・100.20・105.22 pF | 合う |

1 / (1 − (2π × 10 MHz)² × 45 nH × 100 pF) = 1.018、同じく 5 nH なら 1.002 (算術)。

## 出典

自作。関数 (`Network`・`interpolate`) は [scikit-rf Documentation](https://scikit-rf.readthedocs.io/en/latest/)。
CSV の形と統計の出し方は Analog Discovery の教科書の 11-3。

参考: [Network analyzer (electrical) (Wikipedia)](https://en.wikipedia.org/wiki/Network_analyzer_(electrical))
