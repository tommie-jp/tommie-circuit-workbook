---
book: circuits
chapter: 5
id: 5-7
title: チャージポンプ — 555 で負電圧
tier: 100
source: 自作
---

# 5-7 チャージポンプ — 555 で負電圧

コイルを使わず、コンデンサとダイオードだけで電圧を作り替えるのが
**チャージポンプ**。555 の方形波でコンデンサを行き来させ、
電源には無い**負電圧** (−側) を作る。OP アンプの負電源や、
基準電圧を少しだけマイナス側にずらしたいときに使う軽い負荷向けの回路。

## 回路図

```circuit
title: 図1 555 チャージポンプ (負電圧)
parts:
  V1: vsource b3 gnd 9
  vcc: vcc b3
  G1: ground gnd
  U1: ic g10 NE555
  vcc: vcc c6
  Ra: resistor c6 e6 1k
  Rb: resistor f6f0 h6f0 4k7
  C1: capacitor h8f0 j8f0 10n
  GC1: ground j8f0
  vcc: vcc c10
  GU1: ground j10f0
  Cc: capacitor i11 j11f0 10n
  GCc: ground j11f0
  Cp: capacitor g12 g14 1u
  D1: diode g14 j14f0 1N4148
  GD1: ground j14f0
  D2: diode g16 g14 1N4148
  Co: ecap j16f0 g16 10u
  GCo: ground j16f0
  RL: resistor g18 j18f0 1k
  GRL: ground j18f0
points:
  gnd: e3
wires:
  - U1.VCC |- c10
  - c10 -- c10a5
  - U1.RESET |- c10a5
  - e6 -- f6f0
  - U1.DISCH -| f6f0
  - U1.THRES -| g8
  - U1.TRIG -| g8f0
  - g8 -- h8f0
  - h6f0 -- h8f0
  - U1.GND |- j10f0
  - U1.CONT |- i10a5
  - i10a5 -- i11
  - U1.OUT -| g12
  - g16 -- g18
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/07-charge-pump-negative.svg)

- 555 は 3-2 と同じ非安定接続。**3 番 (OUT) の方形波 (0〜9V) が
  Cp (1 µF、ポンプ用コンデンサ) を駆動する**
- OUT が High から Low に落ちるたびに、Cp の右側 (D1・D2 の中点) が
  電源電圧ぶん引きずり下ろされる。**D1 が中点を −0.6V あたりで留め、
  そのたびに D2 が Co (出力の蓄電コンデンサ) から電荷を吸い出す** ──
  これを繰り返すたびに Co の電圧がだんだん負に育っていく
- 無負荷の出力電圧は理論上 **−(Vcc − 2×ダイオードの順方向降下) ≈ −7.8V**。
  ダイオード 2 個ぶん (約 1.2V) だけ Vcc より浅くなるのがこの方式の宿命
- RL (負荷) を繋ぐと、Cp が 1 周期に運べる電荷には限りがあるので出力が
  Vcc に対してさらに浅くなる (5-5 の Joule thief と同じく**軽い負荷向け**)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| Ra | 抵抗 | 1 kΩ |
| Rb | 抵抗 | 4.7 kΩ |
| C1 | セラミックコンデンサ (タイミング) | 10 nF |
| Cc | セラミックコンデンサ (CTRL のノイズ対策) | 0.01 µF |
| Cp | セラミックコンデンサ (ポンプ用) | 1 µF |
| D1, D2 | ダイオード | 1N4148 |
| Co | 電解コンデンサ (出力の平滑) | 10 µF |
| RL | 抵抗 (負荷) | 1 kΩ |
| — | 電源 | 9 V — チャージポンプはダイオード 2 個ぶん (約 1.2V) 出力が浅くなるので、5V では負電圧が浅すぎて OP アンプの負電源に使いにくい。9V にして実用的な深さの負電圧を取り出す |

## 見るべき値

計算値。f = 1.44/((Ra+2Rb)×C1)。出力インピーダンスの目安 R<sub>out</sub> ≈ 1/(f×Cp)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 3 番 (OUT) の周波数 | 約 13.8 kHz | 1.44 / ((1k+9.4k) × 10nF) |
| 出力電圧 (無負荷) | 約 −7.8 V (計算値) | −(9V − 2×0.6V)。実測はダイオードの特性でもう少し浅くなることがある |
| 出力電圧 (RL=1kΩ) | 約 −7.3 V (計算値) | 出力インピーダンス (約 72 Ω) と RL の分圧ぶん浅くなる |
| RL を流れる電流 | 約 7.3 mA | 7.3V ÷ 1kΩ |
| 出力のリップル | 約 53 mV (計算値) | RL の電流 × 周期 ÷ Co |

Cp や周波数を大きくするほど取り出せる電流は増えるが、555 自体の出力電流
(最大 200 mA 程度) と発熱が上限になる。数十 mA を超える負電圧が要るなら
専用 IC (ICL7660、5-16 中級) を使うほうが安定する。

## 出典

自作。
