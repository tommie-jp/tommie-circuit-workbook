---
book: analog-discovery
chapter: 4
id: 4-8
title: FM 波のスペクトル
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-8 FM 波のスペクトル

3-3 で瞬時周波数の変化として見た FM 波を Spectrum で見る。FM のスペクトルは
AM と違って**両脇に何本も**側波帯が並び、その高さは**ベッセル関数 J<sub>n</sub>(β)**
(β = 変調指数) で決まる。AM (4-7) が側波帯 2 本だけだったのと並べて見比べる。

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

板は使わない。3-3 と同じ FM 波を W1 から出し、CH1 で読む。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | Carrier: Sine **100 kHz**、Amplitude 1 V。FM: Modulation Sine **1 kHz**、Deviation **2 kHz** (3-3 と同じ、β = Δf/f<sub>m</sub> = 2) |
| Spectrum | Source: Channel 1。**Start 90 kHz、Stop 110 kHz**。サンプル周波数 250 kHz、FFT 点数 32768。Window: **Flat-top**。単位: dBV |

## 見るべき値

計算値。v(t) = A<sub>c</sub> cos(2π f<sub>c</sub>t + β sin(2π f<sub>m</sub>t)) を展開すると、
n 次側波帯 (f<sub>c</sub> + n f<sub>m</sub>) の振幅は A<sub>c</sub>×|J<sub>n</sub>(β)|。
A<sub>c</sub> = 1 V、β = 2 のときの J<sub>n</sub>(2) の値 (ベッセル関数、表引きで求まる):

| n (次数) | 周波数 | J<sub>n</sub>(2) | 振幅 (0-peak) | dBV | 搬送波との差 |
| --- | --- | --- | --- | --- | --- |
| 0 (搬送波) | 100 kHz | 0.2239 | 0.2239 V | −16.01 dBV | 0 dB (基準) |
| ±1 | 99 / 101 kHz | 0.5767 | 0.5767 V | −7.79 dBV | +8.22 dB |
| ±2 | 98 / 102 kHz | 0.3528 | 0.3528 V | −12.06 dBV | +3.95 dB |
| ±3 | 97 / 103 kHz | 0.1289 | 0.1289 V | −20.80 dBV | −4.79 dB |
| ±4 | 96 / 104 kHz | 0.0340 | 0.0340 V | −32.38 dBV | −16.4 dB |
| ±5 以上 | 95 kHz 以下・105 kHz 以上 | 0.0070 以下 | ほぼノイズフロアに埋もれる | — | — |

分かること:

- **AM (4-7) は側波帯が 2 本だけだったが、FM は理論上いくらでも並ぶ。**
  β = 2 だと ±4 次くらいまでが実用上見える範囲で、それより外は急に小さくなる
- **搬送波 (n = 0) が一番高いとは限らない。** β = 2 では ±1 次 (0.577) のほうが
  搬送波 (0.224) より大きい — AM の「搬送波が一番高い」という直感は FM では
  通用しない
- 実用上の目安として**カーソンの帯域幅 B ≈ 2(β + 1)f<sub>m</sub> = 6 kHz**
  (n = 0〜3 くらいまでで全体のエネルギーの大半をカバーする、という経験則)。
  今回の Start・Stop (90〜110 kHz) はこれより広く取ってあるので、有意な
  側波帯を取りこぼさない
- J<sub>n</sub>(β) は n について振動しながら小さくなる関数なので、次数が上がっても
  単調に減るとは限らない (3 次の 0.129 → 4 次の 0.034 は減っているが、
  β をもっと大きくすると逆転する n も出てくる) — 表を引いて確かめる必要がある

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Spectrum の節)。FM の展開とベッセル関数 J<sub>n</sub>(β) は通信工学の
教科書に載っている標準的な結果 (第 1 種ベッセル関数)。
