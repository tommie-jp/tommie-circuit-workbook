---
book: analog-discovery
chapter: 1
id: 1-11
title: Supplies のトラッキング (± 対称)
tier: 200
source: 自作 (トラッキングは Digilent の Analog Discovery 3 の公式資料)
board: BB
device: AD3
---

# 1-11 Supplies のトラッキング (± 対称)

オペアンプの両電源のように、+V と −V を**同じ大きさ**で出したい回路は多い。Analog Discovery 3 (AD3) の
Supplies には **Tracking** があり、入れると V− が V+ と同じ大きさ・逆の符号に付いてくる
(V+ を 3 V にすれば V− は −3 V)。2 つの値を別々に打つと、片方だけ変え忘れて対称が崩れる。

この題では V+ と V− の間に同じ値の抵抗を 2 本つなぎ、**真ん中の点が 0 V にとどまるか**で対称を確かめる。
真ん中の電圧は (V+ + V−) ÷ 2 なので、対称が崩れた分の半分がそのまま出る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 V+ と V- の間に 1 kΩ を 2 本。真ん中を CH2 で読む
parts:
  VP: vcc 3,1 5V
  R1: resistor 3,1 3,3 1k
  R2: resistor 3,3 3,5 1k
  VN: vee 3,5 5V
  M1: voltmeter 1,1 1,3 l=$\mathrm{CH1}$
  G1: ground 1,3
  M2: voltmeter 5,3 5,5 l=$\mathrm{CH2}$
  G2: ground 5,5
wires:
  - 1,1 -- 3,1
  - 3,3 -- 5,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/11-supplies-tracking.svg)

- VP は AD3 の V+ (図は +5 V の段)、VN は V− (−5 V)。Tracking を入れると VN は VP に付いてくる
- CH1 で V+ を、CH2 で R1 と R2 の真ん中を読む。R1 = R2 なら真ん中は (V+ + V−) ÷ 2

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 V+ は赤いレール、V- は 16 列へ青い線で直に
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1+, 1-, 2-, 2+, V-]
  R1: resistor c8 c12 1k
  R2: resistor d12 d16 1k
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - a8 -- +t8 red
  - AD.1+ -- +t5 yellow
  - AD.1- -- -t6 black
  - AD.2- -- -t10 black
  - AD.2+ -- a12 green
  - AD.V- -- a16 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/11-supplies-tracking.svg)

- −5 V は赤いレールに出さない (1-1 と同じ)。V− の青い線を 16 列に直に挿す
- CH1 の 1+ は + レール (V+) に、CH2 の 2+ は真ん中の 12 列に。1− と 2− は GND のレールへ
- 抵抗に流れる電流は ±5 V で 10 V ÷ 2 kΩ (キロオーム) = 5 mA、1 本あたり 25 mW

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | **Tracking を入れる**。V+ を 1 V → 2 V → 3 V → 4 V → 5 V と上げる (V− は −1〜−5 V に付いてくる)。Master Enable |
| Voltmeter | CH1・CH2 とも DC |
| 比べる | Tracking を外し、V− を −5 V に固定したまま、V+ だけ同じ順に上げる |

この題はオシロの図を付けない — 見るのは直流の電圧だけで、時間で変わらないため、電圧計の読み値で足りる。

AD2 の Supplies にこの機能が無い版では、V+ と V− を同じ大きさに 1 回ずつ打ち込む。打ち込んだ後に CH2 が 0 V 付近かを見る手順は同じ。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| R1・R2 | 金属皮膜抵抗 | 1 kΩ、±1 %、1/4 W | 誤差の小さい物を使う (下の「抵抗の差」)。25 mW は定格の半分の 125 mW 以下 |

## 見るべき値

| V+ の設定 | Tracking あり: V− | Tracking あり: CH2 | Tracking なし (V− = −5 V 固定): CH2 |
| --- | --- | --- | --- |
| 1 V | −1 V | 0 V | −2.0 V |
| 2 V | −2 V | 0 V | −1.5 V |
| 3 V | −3 V | 0 V | −1.0 V |
| 4 V | −4 V | 0 V | −0.5 V |
| 5 V | −5 V | 0 V | 0 V |

- Tracking ありなら、V+ をどこに動かしても CH2 は 0 V 付近にとどまる。Tracking なしでは (V+ − 5 V) ÷ 2 で動く
- CH2 が 0 V から離れた分の 2 倍が、V+ と V− の大きさの差。Supplies の読み返しの分解能は 8 mV なので、
  数 mV の差は読み返しでは見分けにくい (CH2 なら低いレンジで 0.336 mV 刻み)
- **抵抗の差**: R1 と R2 が ±1 % ずれると、真ん中は最大で (V+ − V−) × 2 % ÷ 4 = ±50 mV (±5 V のとき) 動く。
  CH2 が数十 mV ずれたら、R1 と R2 を入れ替えて測り直す。符号が逆になれば抵抗の差、変わらなければ電源の差

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 真ん中の電圧 — Tracking ありは 0 V のまま、V− 固定では −2.0 V から 0 V へ
x: V+ の設定 V 1..5
y: CH2 の電圧 V -2.5..0.5
lines:
  Tracking あり V: 0*x
  V− を −5 V に固定 V: (x-5)/2
notes:
  - mark 1
  - mark 3
  - mark 5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/graph/11-supplies-tracking.svg)

## LTspice での確かめ (対象外)

抵抗 2 本の分圧で、算術で確かめた。真ん中は V− + (V+ − V−) × R2 / (R1 + R2) = (V+ + V−) / 2 (R1 = R2)。
Tracking ありは V− = −V+ で 0 V。V− = −5 V 固定では (1 − 5) / 2 = −2.0 V、(3 − 5) / 2 = −1.0 V、5 V で 0 V。
電流は 10 V / 2 kΩ = 5 mA、1 本の電力は 5 V × 5 mA = 25 mW。R1 = 1.01 kΩ・R2 = 0.99 kΩ のとき真ん中は
−5 + 10 × 0.99 / 2.00 = −0.05 V で、本文の ±50 mV と合う。

## 出典

自作。Tracking (2 つの電源を対で動かす機能) と Supplies の電圧範囲、読み返しの分解能 8 mV は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Programmable Power Supply の節と脚注) と
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Power Supplies の節) による。AD2 で Tracking が使えるかは WaveForms の版によるので確かめていない。
