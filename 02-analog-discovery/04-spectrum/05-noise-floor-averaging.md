---
book: analog-discovery
chapter: 4
id: 4-5
title: ノイズフロアと平均化
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-5 ノイズフロアと平均化

Scope の Average (取り込みを何回も繰り返して重ねる) を使うと、W1 と Scope が
同じクロックで同期しているので**周期的な信号成分はそのまま残り、ランダムな
雑音だけが小さくなる**。平均する回数を増やすほど、FFT に出るノイズフロアが
下がっていく様子を確かめる。

## 回路図

```circuit
title: 図1 ループバック (W1 を 1+ に直結)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1000 Hz、Amplitude 1 V |
| Scope | **Average: N 回** (下の表で N を変える)。Trigger を Wavegen に同期させ、毎回同じ位相で取り込む |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**。Window: Rectangular (ノイズフロアの比較は ENBW が一番狭い窓が見やすい、4-3)。単位: dBV |

## 見るべき値

計算値。基本波 (1000 Hz、−3.01 dBV) の高さは平均回数によらず一定。
ノイズフロアは**時間領域で N 回そろえて平均する**と振幅が 1/√N になるので、
電力 (dB) では **10 log₁₀(N) dB** だけ下がる。

| 平均回数 N | ノイズフロアの下がり幅 (N=1 を基準) | 1 回あたりの取り込み時間の合計 |
| --- | --- | --- |
| 1 (平均なし) | 0 dB | 1 倍 |
| 4 | −6.02 dB | 4 倍 |
| 16 | −12.04 dB | 16 倍 |
| 64 | −18.06 dB | 64 倍 |
| 256 | −24.08 dB | 256 倍 |

分かること:

- **基本波の高さは平均しても変わらない。** 毎回同じ位相・同じ振幅で出ている
  周期信号なので、そのまま重なる (足しても N 倍、平均すれば元と同じ)
- **雑音は毎回ランダムなので、平均すると振幅で 1/√N、電力で 1/N になる。**
  N を 4 倍にするたびにノイズフロアが 6 dB ずつ下がる、というのが目安になる
- N を増やすほど取り込みに時間がかかる (N 倍)。**小さい信号を探すときだけ
  N を上げ、普段は N = 1〜4 で十分**、というのが実用上の落とし所
- Trigger を Wavegen に同期させないと、取り込むたびに信号の位相がずれて
  平均で信号自体も減ってしまう (「見るべき値」の前提が崩れる)。同期を忘れずに

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Scope・Spectrum の節)。
