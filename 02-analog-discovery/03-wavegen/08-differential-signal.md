---
book: analog-discovery
chapter: 3
id: 3-8
title: 2 ch で差動信号
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-8 2 ch で差動信号

Wavegen の W1・W2 は独立にも、**同期して逆位相**にもできる。W2 を W1 の
180° 反転にして、Scope の差動入力 (2-4) で 2 本の差を直接読むと、片側だけを
読むより振幅が 2 倍になる — RS-485 や平衡オーディオが差動を使う理由の入口。

## 回路図

```circuit
title: 図1 W1・W2 を差動と片側で読む
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  V2: sine a5 c5 l=$\mathrm{W2}$
  M2: voltmeter a3 c3 l=$\mathrm{CH2}$
  M1: voltmeter e4 e6 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a4 -- e4
  - a5 -- a6 -- e6
  - c1 -- c3 -- c5
```

- V1 (W1)・V2 (W2) は同じ GND を共有する 2 つの単独出力。CH2 (M2) は W1 を
  GND 基準で読む (ふつうの片側読み)
- CH1 (M1) は **`1+` を W1 に、`1-` を W2 に**つないだ差動読み。W2 が W1 の
  反転 (逆位相) なら、CH1 = W1 − W2 = W1 − (−W1) = 2×W1 になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードで W1・W2 を差動と片側で読む
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, W1, 2+, 1-, W2, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a7 yellow
  - AD.W2 -- a15 green
  - AD.1+ -- b7 orange
  - AD.1- -- b15 purple
  - AD.2+ -- c7 blue
  - AD.2- -- -t18 black
```

W1 (7 列)・W2 (15 列) をそれぞれ引き出し、`1+`/`1-` をこの 2 本に差動でつなぐ。
`2+` は W1 と同じ 7 列 (別の穴) から取り、片側読みの比較用にする。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Offset 0 V、Phase 0°。W2: Sine、1 kHz、Amplitude 1 V、Offset 0 V、**W1 に同期させ Phase 180°** |
| Scope | CH1 (差動): DC 結合、Range 1 V/div。CH2 (片側): DC 結合、Range 500 mV/div |

## 見るべき値

計算値。W2(t) = 1 V×sin(ωt + 180°) = −1 V×sin(ωt) = −W1(t)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH2 (W1 単独、片側読み) | 振幅 1.00 V、Vpp 2.00 V | W1 の Amplitude そのまま |
| CH1 (差動、W1 − W2) | 振幅 2.00 V、Vpp 4.00 V | W2 が W1 の反転なので 2 倍になる |
| CH1 ÷ CH2 の比 | 2.00 倍 (+6.02 dB) | 差動合成の効果。単独の振幅設定は変えていない |

分かること:

- **差動入力は「2 本の電圧差」をそのまま読む** (2-4 で 1 Ω の両端を読んだのと
  同じ仕組み)。今回は 2 本とも Wavegen の出力なので、位相をそろえるだけで
  振幅を作れる
- もし 2 本の配線が同じノイズを同じだけ拾ったなら (同相ノイズ)、差を取る
  ことでそのノイズは打ち消し合う — これがこの先の CMRR (第 9 章) の考え方の元
- Math チャネルの「差」(2-6) でも同じ CH1 − CH2 の波形は作れるが、それは
  **計算後**の差。今回のように `1+`/`1-` を直接つなぐ差動入力は、AD 自身が
  ハードウェアで差を取ってから記録するので、Math より先に効く

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
