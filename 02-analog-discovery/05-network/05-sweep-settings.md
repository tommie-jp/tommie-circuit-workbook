---
book: analog-discovery
chapter: 5
id: 5-5
title: 掃引の設定 — 開始・終了・ステップ・振幅・平均
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 5-5 掃引の設定 — 開始・終了・ステップ・振幅・平均

Network の掃引パラメータ (Start・Stop・Steps・Type・Amplitude・Average) が
測定にどう効くかを、DUT を挟まない**スルー (基準) 測定**で確かめる。W1 を
CH1 と CH2 の両方に直結すれば、理想的には**どの周波数でも 0 dB・0°** になる
はずで、ここからのずれが掃引設定の効果として見える。

## 回路図

```circuit
title: 図1 スルー (基準) の結線
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  M2: voltmeter a5 c5 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

板は使わない。W1 を CH1・CH2 の両方に直結する (5-8 で使うスルー基準と同じ考え方)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude を変えて比較 (下表) |
| Network | Start・Stop・Steps・Type (Linear/Log)・Average を下表のとおり変える |

## 見るべき値

計算値。**Steps と Type**: Start 100 Hz、Stop 1 MHz、Steps 201 のとき、

| 掃引の種類 | 1 ステップあたりの周波数の増え方 |
| --- | --- |
| Linear | 一定間隔 Δf = (1 MHz − 100 Hz) / 200 ≈ **4999.5 Hz** ずつ |
| Log | 一定比率 ×(1 MHz / 100 Hz)^(1/200) ≈ **×1.0471** (1 ステップで約 4.7% ずつ) |

分かること:

- **Linear は低い周波数の刻みが粗すぎる。** 100 Hz 付近では次の点が 5 kHz 先
  ("50 倍" 先) に飛ぶので、低域のカーブの形がほとんど分からない。**Bode 線図の
  ように何桁もの範囲を見るときは Log を選ぶ**のが基本 (5-1〜5-4 はすべて Log)
- **Steps を増やすと分解能は上がるが、掃引にかかる時間も増える。** 特に低い
  周波数の点は 1 周期が長いぶん 1 点の測定に時間がかかるので、Start を低く
  取るほど掃引全体の時間は伸びる
- **Average を増やすと、1 点ごとの読みのばらつきが減る** (4-5 と同じ
  10 log₁₀(N) dB の考え方が、Network の 1 周波数点ぶんの読み値にも当てはまる)。
  ただし Steps × Average の分だけ掃引時間が伸びるので、まず Average 1 で
  全体の形を見てから、気になる周波数だけ Average を上げて確かめるとよい
- **Amplitude を上げると SNR は良くなるが、DUT を壊したり非線形にしたりする
  リスクが増える。** オペアンプやトランジスタを挟む測定 (第 9 章) では、
  出力が飽和しない小さな振幅 (数十 mV) を選ぶ

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
