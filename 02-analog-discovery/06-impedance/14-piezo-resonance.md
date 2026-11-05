---
book: analog-discovery
chapter: 6
id: 6-14
title: 圧電ブザーの共振
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-14 圧電ブザーの共振

圧電ブザー (圧電サウンダー) の円板は、電気的には 6-11 の水晶と同じ形の等価回路を持つ。電極の容量 C<sub>0</sub> に、
円板の機械の振動を表す L<sub>m</sub>・C<sub>m</sub>・R<sub>m</sub> の直列の枝が並列に付く。**共振 f<sub>r</sub> で \|Z\| が谷、
反共振 f<sub>a</sub> で山**になる。水晶と違うのは、C<sub>m</sub> が C<sub>0</sub> の 1/10 と大きく、R<sub>m</sub> も大きいので、
f<sub>r</sub> と f<sub>a</sub> が 5 % 離れ、山と谷がなだらかなこと。共振の周波数で鳴らすと一番大きな音が出る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗と圧電ブザー (発振回路の入っていない物)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 1k
  BZ1: buzzer 9,3 12,3 l=$\mathrm{BZ_{DUT}}$
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/14-piezo-resonance.svg)

- BZ<sub>DUT</sub> は**発振回路の入っていない**圧電ブザー (圧電サウンダー。リード 2 本、ケース入り)。直流をかけるだけで鳴る
  「自励式」は中に回路があるので、この測り方では測れない
- Rref (基準抵抗) は 1 kΩ (オーム)。f<sub>r</sub> の 200 Ω から f<sub>a</sub> の 15 kΩ まで \|Z\| が動く範囲の真ん中あたり

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (6-2 と同じ配置)
board: half
parts:
  Rref: resistor c5 c10 1k
  BZ1: buzzer d10 d14
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/14-piezo-resonance.svg)

- 配線は 6-2 と同じで、10 列が Rref とブザーの中点。圧電サウンダーは極性が無い (印があれば + を 10 列に)
- ピンの間隔が 4 列に合わない品は、短い線で 10 列と 14 列へ渡す

## 計器の設定

計器は Analog Discovery 3 の Impedance (掃引) と、1 点を見る Scope。AD2 でも同じ設定で測れる。

| 計器 | 設定 |
| --- | --- |
| Impedance | Start 1 kHz、Stop 10 kHz、点数 401 (対数)、Amplitude 1 V、Reference: 抵抗 1 kΩ |
| 2 回目 | 3.8〜4.4 kHz を 601 点 (1 Hz 刻み) で詰める |
| Scope | 4.0 kHz (f<sub>r</sub>) で止めて見る。CH1 = Rref の両端、CH2 = ブザーの両端 |

掃引すると、f<sub>r</sub> の近くでブザーが小さく鳴る (1 V なら耳を近づけて聞こえる程度)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 f_r (4.0 kHz) ではブザーの電圧が 0.17 V に落ちる — 位相もほぼ 0° (抵抗)
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 4kHz 0.835V, range: 250mV/div}
ch2: {wave: sine 4kHz 0.166V phase -6.3deg, range: 50mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/14-piezo-resonance.svg)

CH1 は 250 mV/div、CH2 は 50 mV/div と尺度を分けてある。共振から外れた 3 kHz では、CH2 が 0.89 V で −89.8°
(ただのコンデンサ) になる。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 1 kΩ、1/4 W | |
| BZ<sub>DUT</sub> | 圧電サウンダー (発振回路なし)、共振 4 kHz 前後 | 共振の周波数はデータシートの「定格周波数」 |

## 見るべき値

計算値。**等価回路の値は仮定** (共振 4 kHz の圧電サウンダーの目安): C<sub>0</sub> = 22 nF (ナノファラド)、C<sub>m</sub> = 2.2 nF、
R<sub>m</sub> = 200 Ω、L<sub>m</sub> = 1 / ((2π (パイ) × 4 kHz)² × C<sub>m</sub>) = 0.72 H。

| 量 | 値 | 式・分かること |
| --- | --- | --- |
| f<sub>r</sub> (共振) | 4.00 kHz、\|Z\| = 199 Ω、位相 −6.3° | 1 / (2π√(L<sub>m</sub>C<sub>m</sub>))。\|Z\| の谷は 3.998 kHz で 197.6 Ω |
| f<sub>a</sub> (反共振) | 4.20 kHz、\|Z\| ≈ 15.0 kΩ | f<sub>r</sub> × √(1 + C<sub>m</sub> / C<sub>0</sub>) = 4.195 kHz。山の頂は 4.198 kHz |
| 機械の Q (Q<sub>m</sub>) | 90 | 2πf<sub>r</sub>L<sub>m</sub> / R<sub>m</sub>。水晶 (6-11) の 66,000 よりずっと低い |
| 電気機械結合 | k<sub>eff</sub>² = 1 − (f<sub>r</sub> / f<sub>a</sub>)² = 0.091 | 電気と機械の間でどれだけエネルギーが行き来するか |
| 1 kHz・10 kHz | 6.54 kΩ・738 Ω、−90° | 共振から離れればコンデンサ (C<sub>0</sub> + C<sub>m</sub> と C<sub>0</sub>) |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 4.0 kHz (f_r) で谷、4.2 kHz (f_a) で山。その間だけ位相が + (コイル)
x: 周波数 Hz log 1k..10k
y:
  - インピーダンス Ω log
  - 位相 deg -100..100
lines:
  "圧電ブザー Ω": sqrt(40000+(4.5214472*x-72.343156M/x)^2)/sqrt((11-0.625µ*x^2)^2+(27.646µ*x)^2)
  "圧電ブザーの位相 deg": deg(atan2(4.5214472*x-72.343156M/x, 200))-deg(atan2(27.646µ*x, 11-0.625µ*x^2))
notes:
  - mark 3k
  - mark 4k
  - mark 4.198k
  - level 0deg
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/14-piezo-resonance.svg)

分かること:

- **一番よく鳴るのは f<sub>r</sub> の近く** (\|Z\| が低く、電流が多く流れて円板が大きく振れる)。マイコンの PWM で鳴らすなら、
  データシートの定格周波数 (この題では 4 kHz) に合わせる
- f<sub>r</sub> と f<sub>a</sub> の間だけ位相が + になる (コイルの区間)。水晶 (6-11) と同じ形だが、C<sub>m</sub> / C<sub>0</sub> が 1/10 と大きいので
  区間が 200 Hz と広い
- 測った f<sub>r</sub>・f<sub>a</sub>・\|Z\| の谷 から、等価回路の 4 つの値を逆算できる:
  C<sub>m</sub> = C<sub>0</sub>((f<sub>a</sub>/f<sub>r</sub>)² − 1)、L<sub>m</sub> = 1/((2πf<sub>r</sub>)²C<sub>m</sub>)、R<sub>m</sub> ≈ 谷の \|Z\|
  (C<sub>0</sub> は 1 kHz の \|Z\| から)

## LTspice での確かめ

`sim/14-piezo-resonance.cir` で図1 (Rref 1 kΩ、ブザーは L<sub>m</sub> 0.72 H・C<sub>m</sub> 2.2 nF・R<sub>m</sub> 200 Ω の直列に C<sub>0</sub> 22 nF を並列、
W1 の振幅 1 V) を 1〜10 kHz で 0.1 Hz 刻みに交流解析した。等価回路の値は本文の仮定で、**実測ではない**。谷と山の周波数は `.meas` で取らず、表の周波数は本文の式で出した値。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| \|Z\| の谷 | 3.998 kHz、197.6 Ω | 197.6 Ω (3.5〜4.1 kHz の最小) | 合う |
| \|Z\| の山 | 4.198 kHz、15.0 kΩ | 15.05 kΩ (4.1〜4.5 kHz の最大) | 合う |
| CH1・CH2 (4.0 kHz) | 0.835 V・0.166 V | 0.8349 V・0.1660 V | 合う |
| \|Z\| (1 kHz・10 kHz) | 6.54 kΩ・738 Ω | 6.537 kΩ・737.5 Ω | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
参考: [圧電素子 — Wikipedia](https://ja.wikipedia.org/wiki/%E5%9C%A7%E9%9B%BB%E7%B4%A0%E5%AD%90)
