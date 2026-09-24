---
book: analog-discovery
chapter: 3
id: 3-5
title: 出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-5 出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス

ベンチ (据え置き) の関数発生器の多くは**出力インピーダンス 50 Ω** を持つ。
50 Ω の負荷をつなぐと分圧で電圧がちょうど半分 (−6.02 dB) になるのは、
その手の発生器の常識になっている。

Wavegen の W1 (付属のワイヤで使う場合) はこれと**違う**。出力段はレール to
レールのオペアンプ (AD8067) で、直列に入っているのは短絡保護用の PTC
(自己復帰型ヒューズ、R145) だけ。**出力インピーダンスはほぼ 0 Ω** のまま。
50 Ω をつないでも電圧はほとんど落ちない — その代わり、**電流**に無理をさせると
波形の頭が潰れる。この実験では両方を実際に測る。

## 回路図

```circuit
title: 図1 出力インピーダンスを測る
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  S1: switch a5 a7
  RL: resistor a7 a9 50
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c9
  - a9 -- c9
```

- S1 を開けたままだと CH1 は開放電圧をそのまま読む (CH1 自身の入力抵抗は
  1 MΩ 以上あり、無視できる)
- S1 を閉じると R<sub>L</sub> = 50 Ω が W1 の出力と GND の間に入る。ベンチの
  発生器なら電圧が半分になる負荷だが、W1 でどうなるかを測るのがこの実験

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  S1: switch c5 c8
  RL: resistor c10 c15 50
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - c8 -- c10 green
  - a15 -- -t15 black
```

S1 を抜いたまま (開放) 測ってから、挿して (短絡) もう一度測る。実際にスイッチを
用意できないときはジャンパ線の抜き差しでよい。R<sub>L</sub> は 50 Ω に固定し、
振幅だけを変えて確かめる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Offset 0 V。**Amplitude を 0.5 V → 1 V → 2 V の順に上げる** |
| Scope | CH1: DC 結合、Range は振幅に合わせて調整 (0.5 V/div など)。Measure の Amplitude (0-peak) だけでなく、**波形の頭の形も目で見る** |

## 見るべき値

### 1. 出力インピーダンス R<sub>o</sub> を測る (Amplitude 0.5 V)

計算値と、読み方の例。**V<sub>L</sub> = V<sub>open</sub> × R<sub>L</sub> / (R<sub>L</sub> + R<sub>o</sub>)** を
R<sub>o</sub> について解くと、**R<sub>o</sub> = R<sub>L</sub> × (V<sub>open</sub> / V<sub>L</sub> − 1)**。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 開放時 CH1 (S1 off) | ほぼ 0.500 V (振幅どおり) | 出力段はほぼ理想電圧源 |
| 50 Ω 負荷時 CH1 (S1 on) | 0.500 V よりわずかに低いだけ (数 % 以内が目安) | R<sub>o</sub> が数 Ω しかない証拠。ベンチの発生器の −6.02 dB とは大きく違う |

**読み方の例** (実際の値は個体・配線で変わるので、あくまで計算のやり方の例):
V<sub>open</sub> = 0.500 V、V<sub>L</sub> = 0.485 V と読めたなら、
R<sub>o</sub> = 50 × (0.500 / 0.485 − 1) ≈ **1.5 Ω**。ここで測る R<sub>o</sub> は
**目安であって、データシートの規格値ではない** (PTC の抵抗と配線の抵抗の
合計で、個体差がある)。

### 2. 電流のほうが本当の制約 (R<sub>L</sub> = 50 Ω 固定、振幅を上げる)

計算値。負荷電流 (0-peak) ≈ Amplitude ÷ 50 Ω (R<sub>o</sub> が小さいので分母は
ほぼ R<sub>L</sub> のまま)。

| Amplitude | 負荷電流 (0-peak) の計算値 | 見えるはずの波形 |
| --- | --- | --- |
| 0.5 V | 10.0 mA (Digilent が保証する最小駆動電流ちょうど) | ほとんどの個体できれいな正弦波 |
| 1.0 V | 20.0 mA (保証値の 2 倍。代表値の範囲内) | 個体によっては頭がわずかに丸まり始める |
| 2.0 V | 40.0 mA (代表的な最大値 (約 50 mA) に接近) | 多くの個体で頭が潰れて見える (電流制限) |

分かること:

- **落ち込みの正体は R<sub>o</sub> ではなく電流。** W1 は「50 Ω 負荷に耐える
  電圧源」ではなく、「保証は少なくとも 10 mA、代表的な個体では 50 mA 程度まで
  出せる電流源としての限界を持つ、ほぼ理想の電圧源」というのが実像
- **頭が潰れ始めたら、それは分圧ではなく電流制限。** オペアンプの出力段が
  必要な電流を出しきれなくなり、ピークだけ平らになる (クリップ)
- 直列の PTC (R145) は短絡保護用。電流を絞り込むと自分の抵抗が増えて熱で
  守る仕組みなので、**頭が潰れたまま長時間動かし続けない** (PTC が温まると
  R<sub>o</sub> の値そのものも動く)
- **Discovery BNC アダプタ**を使うと、AWG 出力に **50 Ω / 0 Ω を選べる
  ジャンパ**がある。ここで 50 Ω 側を選べば、今度は本物の 50 Ω 抵抗が直列に
  入るので、ベンチの発生器と同じ「50 Ω 負荷で電圧が半分」という挙動になる
  (この実験は付属のワイヤ・0 Ω 側の話)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。W1 の出力段 (AD8067、短絡保護用 PTC R145) と駆動電流
(保証値・代表値) は Digilent の
[Analog Discovery 2 リファレンスマニュアル](https://digilent.com/reference/test-and-measurement/analog-discovery-2/reference-manual)
§3.4 (AWG Out)。50 Ω / 0 Ω の出力ジャンパは
[Discovery BNC Adapter リファレンスマニュアル](https://digilent.com/reference/add-ons/discovery-bnc-adapter/reference-manual)
による。
