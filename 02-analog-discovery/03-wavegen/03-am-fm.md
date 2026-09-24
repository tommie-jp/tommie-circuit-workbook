---
book: analog-discovery
chapter: 3
id: 3-3
title: AM / FM 変調
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-3 AM / FM 変調

Wavegen の W1 は単純な波形だけでなく、**AM (振幅変調)** と **FM (周波数変調)** も
1 台で作れる。搬送波 (Carrier) に低い周波数の信号 (Modulation) を乗せ、Scope の
時間軸でエンベロープ (AM) や周期の変化 (FM) を読む。第 4 章の FFT で側波帯を
見る実験 (4-7・4-8) の元になる。

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

板は使わない。W1 の出力をそのまま 1+ で読む。

## 計器の設定

| 計器 | 設定 (AM) | 設定 (FM) |
| --- | --- | --- |
| Wavegen | Carrier: Sine 100 kHz、Amplitude 1 V。AM: Modulation Sine 1 kHz、Depth 50% | Carrier: Sine 100 kHz、Amplitude 1 V。FM: Modulation Sine 1 kHz、Deviation 2 kHz |
| Scope | CH1: 20 µs/div、Range 2 V/div (搬送波が 10 周期ほど見える) | CH1: 20 µs/div、Range 2 V/div (同じ設定でよい) |

## 見るべき値

計算値。AM は Depth (変調度) m = 0.5、搬送波の振幅 A<sub>c</sub> = 1 V。

| 測る所 (AM) | 期待する値 | 分かること |
| --- | --- | --- |
| エンベロープの山 (最大振幅) | A<sub>c</sub>(1+m) = 1.5 V | 変調信号の山で搬送波が最も大きくなる |
| エンベロープの谷 (最小振幅) | A<sub>c</sub>(1−m) = 0.5 V | 変調信号の谷で最も小さくなる |
| 側波帯 1 本の振幅 (搬送波比) | m/2 = 0.25 倍 = −12.0 dB | 4-7 で FFT を撮ると 99 kHz・101 kHz にこの高さで立つ |

FM は変調指数 β = Δf / f<sub>m</sub> = 2 kHz / 1 kHz = 2。瞬時周波数はカーソルで
周期を読んで確かめる。

| 測る所 (FM) | 期待する値 | 分かること |
| --- | --- | --- |
| 変調信号が山のときの周期 | 1 / 102 kHz ≈ 9.804 µs | 瞬時周波数は f<sub>c</sub> + Δf = 102 kHz |
| 変調信号が 0 のときの周期 | 1 / 100 kHz = 10.000 µs | 瞬時周波数は f<sub>c</sub> のまま |
| 変調信号が谷のときの周期 | 1 / 98 kHz ≈ 10.204 µs | 瞬時周波数は f<sub>c</sub> − Δf = 98 kHz |

AM は**振幅**が変調信号の形をなぞり、FM は**周期 (瞬時周波数)** が変調信号の形を
なぞる。Scope のカーソルで山・谷・ゼロ点の位置の周期を読めば、この 3 点は
計算どおりに並ぶ。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
