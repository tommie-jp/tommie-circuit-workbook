---
book: analog-discovery
chapter: 0
id: 0-10
title: デバイスの校正 (WaveForms の Calibration)
tier: 200
source: 自作 (手順の流れは Rensselaer 工科大学の実験の手引き、許容差は Digilent の Analog Discovery 3 の公式仕様)
board: —
---

# 0-10 デバイスの校正 (WaveForms の Calibration)

Analog Discovery 3 (AD3) は工場で校正してあり、WaveForms はその値で電圧を直して読む
(Specifications の脚注: 実際の範囲は部品のばらつきで少しずれ、工場の校正で補ってある)。
それでも、使ううちに読み値がテスター (ディジタルマルチメータ、DMM) とずれてきたら、
WaveForms の **Calibration (校正)** で自分で校正し直せる。基準になるのは手元の DMM で、
**校正の確かさは DMM の確かさで決まる**。

この題では、まず直流のループバックで「校正が要るか」を仕様の許容差と比べて判断し、
要るときだけ校正の手順を通す。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の直流を DMM と CH1 で同時に読む
parts:
  W1: vsource 1,2 1,4 l=$\mathrm{W1}$
  M1: voltmeter 3,2 3,4 l=$\mathrm{DMM}$
  M2: voltmeter 5,2 5,4 l=$\mathrm{CH1}$
  G1: ground 1,4
wires:
  - 1,2 -- 3,2 -- 5,2
  - 1,4 -- 3,4 -- 5,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/10-calibration.svg)

- W1 (Wavegen の DC) を、DMM と CH1 (1+、1− は GND) に同時に当てる。DMM の − は AD3 の GND
- DMM は直流電圧のレンジ。入力抵抗は 10 MΩ (メガオーム) 級なので、W1 の電流はほぼ流れない

この題は実体配線図とオシロの図を付けない — 基板を使わず、付属ワイヤの先に DMM の測定棒を当てるだけで、
見るのは直流の電圧 (時間で変わらない) だけだから。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 準備 | AD3 を USB でつなぎ、WaveForms で選んだまま数分〜15 分おいて温める (目安。中の温度が落ち着いてから測る) |
| Wavegen (W1) | Mode を DC にし、0 V → +1 V → +2 V → −1 V → −2 V と変える |
| Voltmeter (CH1) | DC。Scope の Range は ±2.5 V 側 (0.5 V/div 以下の低いレンジ) |
| DMM | 直流電圧。桁の多い物ほどよい |

## 見るべき値 (校正が要るか)

仕様の確かさ (AD3 の Specifications、BNC アダプタ無し):

- Scope: 低いレンジ (0.5 V/div 以下) で ±(10 mV + 読み値の 0.5 %)、高いレンジで ±(100 mV + 0.5 %)
- Wavegen: |V| ≤ 1.25 V で ±(10 mV + 0.5 %)、それより上で ±(25 mV + 0.5 %)

| W1 の設定 | DMM と W1 の設定の差の許容 (Wavegen) | CH1 と DMM の差の許容 (Scope、低いレンジ) |
| --- | --- | --- |
| 0 V | ±10 mV | ±10 mV |
| ±1 V | ±15 mV | ±15 mV |
| ±2 V | ±35 mV | ±20 mV |

- **DMM の値 − W1 の設定** が左の列を超えたら Wavegen の校正、**CH1 − DMM** が右の列を超えたら Scope の校正が要る
- 許容の内側なら校正しない。工場の値を、手元の DMM の誤差で上書きすることになる

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図2 仕様の許容差 — 2 V で Wavegen は ±35 mV、Scope は ±20 mV
x: 電圧の大きさ V 0..2.5
y: 許容差 mV 0..40
lines:
  Wavegen mV: 10+5*x+15*min(1,max(0,ceil(x-1.25)))
  Scope (低いレンジ) mV: 10+5*x
notes:
  - mark 1
  - mark 2
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/graph/10-calibration.svg)

Wavegen の許容は 1.25 V を超えると 15 mV 跳ねる (仕様の表が 1.25 V で分かれている)。2 V で測ると、Wavegen の 35 mV は
Scope の 20 mV よりゆるい。

## 校正の手順 (要るときだけ)

WaveForms の版で画面の名前は少し変わる。流れは次のとおり (目安)。

1. Device Manager (設定のメニュー) を開き、AD3 を選んで **Calibrate** を押す
2. Wizard を選ぶ。最初の画面に要る物 (DMM・ワイヤ) が出る
3. **Wavegen を先に校正する**。W1・W2 の出力を DMM で読み、言われた値 (0 V 付近など) の読みを入力する。
   各 ch を低い利得と高い利得の 2 回ずつ行う
4. 次に **Scope を校正する**。校正した Wavegen の出力を CH1・CH2 につなぎ替えて、言われたとおりに進める
5. 最後まで進めて、校正の値を**デバイスに書き込む (Apply)**。校正の値はファイルにも保存しておく
6. 上の「見るべき値」の表を、もう一度通す

元に戻したくなったら、校正の窓のメニューで工場の値に戻せる (目安。実機の画面で確かめる)。

## LTspice での確かめ (対象外)

校正の手順の題で、回路は直流の配線だけ。許容差は算術で確かめた。Wavegen は 10 + 0.005 × 1000 mV = 15 mV (1 V)、
25 + 0.005 × 2000 = 35 mV (2 V)。Scope は 10 + 5 = 15 mV (1 V)、10 + 10 = 20 mV (2 V)。図2 の式は 1.25 V で
min(1, max(0, ceil(x − 1.25))) が 0 から 1 に変わり、15 mV 跳ねる。本文の表と合う。

## 出典

自作。確かさと工場の校正は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Analog Input Channels・Arbitrary Waveform Generator の Accuracy と脚注)。手順の流れ (Device Manager → Calibrate → Wizard、
Wavegen を低い利得と高い利得の 2 回ずつ、その後に Scope、Apply と保存) は
[Calibration (Rensselaer Polytechnic Institute、ENGR-2300 の手引き)](https://sites.ecse.rpi.edu/courses/S23/ENGR-2300/Calibration.pdf)
による。この手引きは前の世代の Analog Discovery 向けで、AD3 の画面とは違うことがある。
