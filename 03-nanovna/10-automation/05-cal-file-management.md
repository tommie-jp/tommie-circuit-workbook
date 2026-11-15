---
book: nanovna
chapter: 10
id: 10-5
title: 校正データの管理 — キット・ケーブルごと
tier: 200
source: 自作 (ファイルの形は NanoVNA-Saver のソース)
board: —
device: H4
---

# 10-5 校正データの管理 — キット・ケーブルごと

校正 (SOLT) は**キット・ケーブル・範囲・点数の組**ごとに 1 つ要る。本体はスロット (1-6) に数個しか置けないが、
NanoVNA-Saver の校正 (2-9) は Save calibration でファイルに残せるので、組の数だけ持てる。数が増えると、
**どのファイルがどのケーブルの物か**が分からなくなり、違うケーブルの校正で測る間違いが起きる。この題では、

1. ファイル名と Notes の決まりで組を記録する
2. Python で校正ファイルの一覧を作り、**ファイルの中身からケーブルの長さを読み返す** (名前の書き間違いに気づける)
3. 校正を読み込んだら、**検証用の 100 Ω (オーム)** を 1 回測って、校正とケーブルが合っているかを確かめる

## ファイル名と Notes

| 何を | どこに | 例 |
| --- | --- | --- |
| キット・ケーブル・範囲 | ファイル名 | `cal_kitA_cab30cm_1M-300M.cal` |
| 点数・日付・室温・本体の版 | Saver の校正の窓の Notes (ファイルの `!` の行に入る) | `キット A (付属)、ケーブル 30 cm (RG174)、1-300 MHz 101 点` |
| どの測定でどの校正を使ったか | 測定のフォルダの `README.txt` | `10-3-*.s2p は cal_kitA_cab30cm_1M-300M.cal` |

- Saver の校正ファイルはテキストで、頭の `# Calibration data for NanoVNA-Saver` の次に Notes が `!` の行で並び、
  `# Hz ShortR ShortI OpenR OpenI LoadR LoadI` (2 ポートならさらに `ThroughR` … `IsolationI`) の見出しの後に、
  **1 行 1 周波数で Short・Open・Load (・Through …) を測った生の値**が実部・虚部で並ぶ (Saver のソースの `Calibration.py`)
- 生の値は、本体の校正 (スロット 0、2-9) で直した後の値で、**Saver の校正の面 (ケーブルの先) の Short・Open・Load をそのまま測った物**。
  Short の位相の回り方にはケーブルの長さが、Load の大きさにはケーブルと Load の不整合が入っている。中身から組を読み返せるのはこのため
- キットを替えた・ケーブルを替えた・コネクタを付け替えた・範囲か点数を変えた、のどれかで新しいファイルにする (1-4)。
  同じ組でも日が経ったら取り直す目安は 1-9

## 一覧を作るスクリプト

`python cal_list.py 'cal_*.cal'` と打つと、ファイルごとに Notes・範囲・点数・1 か 2 ポートか、
**Short の位相の傾きから出したケーブルの遅れと長さ**、Load の生の反射の最大を出す。Python 3.10 以上、標準のライブラリだけ。

```python
import cmath
import glob
import math
import statistics
import sys

C0 = 299_792_458.0   # 真空中の光速 [m/s]


def read_cal(path):
    """Saver の校正ファイル: '!' の行が Notes、'#' の行が見出し、残りが 1 行 1 周波数の値。"""
    notes, freqs, short, load = [], [], [], []
    two_port = False
    with open(path, encoding="utf-8") as fp:
        for line in fp:
            line = line.strip()
            if line.startswith("!"):
                notes.append(line[1:].strip())
            elif line.startswith("#"):
                two_port = two_port or "ThroughR" in line
            elif line:
                v = [float(x) for x in line.split()]
                freqs.append(v[0])
                short.append(complex(v[1], v[2]))
                load.append(complex(v[5], v[6]))
    return notes, freqs, short, load, two_port


def delay_from_short(freqs, short):
    """Short の位相の傾きから、校正の面までの片道の遅れ τ を出す: −Short = e^(−j2ωτ)。"""
    ph = [cmath.phase(-s) for s in short]
    un = [ph[0]]
    for p in ph[1:]:                      # 位相の折り返しを外す (unwrap)
        d = p - un[-1]
        un.append(un[-1] + d - 2 * math.pi * round(d / (2 * math.pi)))
    slope, _ = statistics.linear_regression(freqs, un)   # [rad/Hz]
    return -slope / (4 * math.pi)


def main():
    for path in sorted(glob.glob(sys.argv[1])):
        notes, freqs, short, load, two_port = read_cal(path)
        tau = delay_from_short(freqs, short)
        worst = max(20 * math.log10(abs(z)) for z in load)
        print(path)
        for n in notes:
            print(f"  メモ: {n}")
        print(f"  {freqs[0] / 1e6:g}〜{freqs[-1] / 1e6:g} MHz、{len(freqs)} 点、{'2 ポート (Thru あり)' if two_port else '1 ポート'}")
        print(f"  ケーブルの遅れ {tau * 1e9:.2f} ns (vf 0.66 なら {tau * C0 * 0.66 * 100:.0f} cm)、"
              f"Load の生の反射の最大 {worst:.1f} dB")


if __name__ == "__main__":
    main()
```

- 理想の Short は Γ (ガンマ) = −1。長さのあるケーブルの先では −e<sup>−j2ωτ</sup> (ω (オメガ) = 2πf、π (パイ) は円周率、τ (タウ) は片道の遅れ) になり、
  位相は周波数に比例して回る。その傾き −4πτ [rad/Hz] から τ を出す。長さは τ × 光速 × vf (速度係数、5-2)
- 隣の点の間で位相が π より大きく回ると、折り返しを外し損ねる。点の間隔は 1 / (4τ) より細かくする
  (1 m の vf 0.66 なら τ = 5.05 ns で 50 MHz。101 点の 1〜300 MHz の 2.99 MHz なら十分)
- **名前の「30 cm」と、中身から読んだ長さが合わなければ、取り違えたファイル**。Load の反射が前の一覧より大きく増えたら、
  Load かコネクタが傷んだ (1-7)

このスクリプトは Saver で保存した校正ファイルでは**まだ動かしていない** (実機は未確認)。PC で、Saver のソースの書き出しと同じ形で、
30 cm と 1 m (vf 0.66) のケーブルの先の Short・Open・Load (Load は −34 dB の反射) に標準偏差 0.001 の雑音を足した 101 点の
2 つの `.cal` を作って動かし、「1.52 ns (30 cm)」「5.05 ns (100 cm)」、Load の最大 −32.9 dB・−33.1 dB と出ることを確かめた。

## 回路図

検証用の 100 Ω は、3-4 の自作の Load の 100 Ω 2 本を 1 本にした物。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 検証用の 100 Ω (SMA 1 つと抵抗 1 本)
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 4,2 4,4 100
  G1: ground 4,4
wires:
  - J1.1 -- 4,2
  - J1.2 -- 2,4 -- 4,4
notes:
  - text 1,1.2 blue left: 30 cm のケーブルの先に挿す
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/circuit/05-cal-file-management.svg)

この題は実体配線図を付けない — 検証用の 100 Ω は 3-4 の Load の perfboard (3-4 の図4) と同じ作りで、抵抗を 1 本にするだけ。

## 掃引の設定

計器は VNA (NanoVNA-H4 と PC の NanoVNA-Saver。標準の LiteVNA64 も同じ)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | Saver の Load calibration で `cal_kitA_cab30cm_1M-300M.cal` を読み、Apply |
| 表示 | S11 の SWR と Smith |

正しい組の校正で 100 Ω を測ると、どの周波数でも SWR 2.00、Smith の実軸の r = 2 の 1 点に止まる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図2 正しい校正で 100 Ω — SWR 2.00・r = 2 の 1 点
dut:
  - series R 100
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 10M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/05-cal-file-management-1.svg)

1 m のケーブルに挿したのに 30 cm の校正を読むと、校正の面と 100 Ω の間に 70 cm のケーブルが残る。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図3 30 cm の校正を 1 m のケーブルで使うと Smith の上を回る
dut:
  - line 50 70cm vf 0.66
  - series R 100
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 10M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/05-cal-file-management-2.svg)

- 図3 でも **SWR は 2.00 のまま**。損失の無いケーブルは反射の大きさを変えず、位相だけを回すからで、SWR や LOGMAG の検証では
  取り違えに気づかない。**検証は Smith (か R と X) で見る**
- ケーブルが余計に 70 cm あると、片道 3.54 ns。100 Ω の反射 (Γ = 1/3) は 2ωτ だけ回り、10 MHz で −25.5°、100 MHz で −254.5° (= +105.5°)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 炭素皮膜抵抗 (1/4 W、リードを短く) | 100 Ω |
| J1 | 端面 SMA (メス) | 3-4 の Load と同じ作り |
| — | 計器 | NanoVNA-H4、PC (NanoVNA-Saver、Python 3.10 以上) |
| — | 電源 | 使わない |

## 見るべき値

計算値 (理想の 100 Ω。リードのインダクタンスは 3-4・1-7 の目安で、300 MHz に近いほど r = 2 から上へずれる)。

| 校正 | 周波数 | SWR | Smith の読み | 分かること |
| --- | --- | --- | --- | --- |
| 正しい組 (図2) | 10 MHz・100 MHz | 2.00 | 100.0 Ω + j0.0 Ω | 校正とケーブルが合っている |
| 30 cm の校正で 1 m のケーブル (図3) | 10 MHz | 2.00 | 87.3 Ω − j28.2 Ω | 低い所でも点が回り始める |
| 同 | 100 MHz | 2.00 | 34.5 Ω + j25.0 Ω | 大きく回る。SWR だけでは見えない |
| スクリプトの読み (30 cm のファイル) | — | — | 1.52 ns (30 cm) | 名前と中身が合う |

- 検証の 100 Ω は、校正の標準 (Short・Open・Load) と別の物にする。校正に使った Load を測っても、校正が「合っている」としか言わない
- 検証の結果 (10 MHz と 100 MHz の R + jX) を、校正のファイル名と一緒に `README.txt` に 1 行書いておくと、後で同じ組を読み込んだ日に比べられる

## LTspice での確かめ

`sim/05-cal-file-management.cir` で、100 Ω を 1 端子で解いたもの (図2) と、70 cm (vf 0.66、片道 3.537 ns の理想の T 素子) の先に 100 Ω を付けたもの (図3) を、
10 MHz と 100 MHz で解き、入口の Z を読んだ。理想の模型で、実測ではない。読み値の虚部は符号が落ちて返るので、大きさで比べた (符号は Γ の回る向きで、10 MHz は容量性の −、100 MHz は誘導性の +)。

| 図 | 周波数 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 図2 | 10・100 MHz | 100.0 Ω + j0.0 Ω (SWR 2.00) | 100.0 Ω + j0.0 Ω | 合う |
| 図3 | 10 MHz | 87.3 Ω − j28.2 Ω | 87.27 Ω、虚部の大きさ 28.15 Ω | 合う |
| 図3 | 100 MHz | 34.5 Ω + j25.0 Ω | 34.54 Ω、虚部の大きさ 24.99 Ω | 合う |

遅れは 0.30 m ÷ (0.66 × 299 792 458 m/s) = 1.516 ns、1 m で 5.054 ns、70 cm で 3.538 ns。回る角は −2 × 360° × 10 MHz × 3.538 ns = −25.5° (算術)。

## 出典

自作。校正ファイルの形 (見出しの行・`!` の Notes・列の並び) と Save calibration・Load calibration は
[NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) の README とソース (`Calibration.py`)。

参考: [Smith chart (Wikipedia)](https://en.wikipedia.org/wiki/Smith_chart)、[Velocity factor (Wikipedia)](https://en.wikipedia.org/wiki/Velocity_factor)
