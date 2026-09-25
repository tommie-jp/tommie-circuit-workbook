---
book: analog-discovery
chapter: 4
id: 4-7
title: AM 波のスペクトル — 搬送波と側波帯
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-7 AM 波のスペクトル — 搬送波と側波帯

3-3 で時間軸のエンベロープとして見た AM 波を、今度は Spectrum で見る。
DSB (両側波帯) の AM は、搬送波 1 本と、その両脇に変調周波数ぶん離れた
**側波帯 2 本**になる。3-3 で計算した側波帯の高さ (−12.0 dB) が FFT にそのまま
現れることを確かめる。

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

板は使わない。3-3 と同じ AM 波を W1 から出し、CH1 で読む。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | Carrier: Sine **100 kHz**、Amplitude 1 V。AM: Modulation Sine **1 kHz**、Depth **50%** (3-3 と同じ) |
| Spectrum | Source: Channel 1。**Start 90 kHz、Stop 110 kHz**。サンプル周波数 250 kHz、FFT 点数 32768。Window: **Flat-top** (振幅を正しく読むため、4-1・4-3)。単位: dBV |

## 見るべき値

計算値。v(t) = A<sub>c</sub>[1 + m cos(2π f<sub>m</sub>t)] cos(2π f<sub>c</sub>t) を展開すると、
搬送波 A<sub>c</sub>、側波帯 A<sub>c</sub>m/2 (f<sub>c</sub> ± f<sub>m</sub>) になる
(A<sub>c</sub> = 1 V、m = 0.5、f<sub>c</sub> = 100 kHz、f<sub>m</sub> = 1 kHz)。

| 山 | 周波数 | 振幅 (0-peak) | dBV | 搬送波との差 |
| --- | --- | --- | --- | --- |
| 搬送波 | 100 kHz | 1.000 V | −3.01 dBV | 0 dB (基準) |
| 下側側波帯 | 99 kHz | 0.250 V | −15.05 dBV | −12.04 dB |
| 上側側波帯 | 101 kHz | 0.250 V | −15.05 dBV | −12.04 dB |

分かること:

- **側波帯の高さは搬送波から m/2 = 0.25 倍 (−12.04 dB)、これは 3-3 で時間軸から
  求めた値とぴったり一致する。** 時間軸 (エンベロープ) と周波数軸 (側波帯) は
  同じ変調を 2 つの見方で見ているだけ
- 側波帯は搬送波からちょうど f<sub>m</sub> (1 kHz) だけ離れる。**Depth を変えても
  側波帯の位置 (99 kHz・101 kHz) は動かず、高さだけが変わる** — 位置を決めるのは
  f<sub>m</sub>、高さを決めるのは m
- Window を Flat-top にしないと、3 本ある山のどれかがビンの真ん中からずれて
  高さが低く読めることがある (4-3)。3 本を同時に正しい比で読みたいときほど
  Flat-top が要る

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Spectrum の節)。AM の展開式は通信工学の教科書に載っている標準的な導出。
