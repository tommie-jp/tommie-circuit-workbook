---
book: analog-discovery
chapter: 6
id: 6-15
title: 電池の内部抵抗 (AC)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 6-15 電池の内部抵抗 (AC)

電池の残りを調べるのに、電圧だけでは足りない。使い込んだ電池は、無負荷の電圧はまだ高くても、
**内部抵抗**が増えて電流を取ると電圧が落ちる。電池の検査器が使う「1 kHz の AC 内部抵抗」は、
電池に小さな交流の電流を流し、両端に出る交流の電圧との比で内部抵抗を読む。放電させずに測れるのが利点だ。
基準抵抗で電流を、差動の CH2 で電池の両端を測る 6-1 の仕組みを、**直流の電圧を持つ DUT** に使う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗・直流を止めるコンデンサ・電池 (W1 のオフセットを電池の電圧に合わせる)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 150
  Cb: ecap 10,3 8,3 470u
  B1: battery 12,3 15,3 3V
  G1: ground 17,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 8,3
  - 10,3 -- 12,3
  - AD.2+ -| 12,3
  - AD.2- -| 15,3
  - 15,3 -- 17,3
  - AD.GND -| 17,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/15-battery-ac-resistance.svg)

- B1 は測る電池。図はリチウムのコイン電池 CR2032 (3 V)。アルカリの単 3 (1.5 V) も同じ回路で測る
- Rref (基準抵抗) は 150 Ω (オーム)。W1 の振幅 1 V で交流の電流が 6.7 mA 以下になり、Wavegen が流せる目安 (10 mA) に収まる
- Cb (470 µF (マイクロファラド)、電解) は**直流を止める**。電池の直流が Rref を通って W1 へ流れ込まないようにする。
  1 kHz での Cb のリアクタンスは 0.34 Ω で、Rref の 150 Ω に比べて無視できる
- **W1 の Offset は電池の電圧より 0.1 V 低くする** (CR2032 なら 2.9 V、単 3 なら 1.4 V)。Cb の両端の直流は 0.1 V だけで、
  電池の側 (+) が高い向きになる。つなぐ瞬間に Cb を充電する電流も 0.1 V / 150 Ω = 0.7 mA で済む
- この題は実体配線図を付けない — 電池ホルダーのリード・Cb・Rref の 3 つをワニ口クリップで直列にするだけで、基板を使わない
  (基板に挿す部品が 2 つで、節点が 3 つしかない)

## 計器の設定

計器は Analog Discovery 3 の Impedance (掃引) と Scope (1 kHz の 1 点)。AD2 でも同じ設定で測れる。

| 計器 | 設定 |
| --- | --- |
| Impedance | Start 10 Hz、Stop 10 kHz、点数 61 (対数)、Amplitude 1 V、**Offset = 電池の電圧 − 0.1 V**、Reference: 抵抗 150 Ω、平均を多めに |
| Scope | 1 kHz で見る。CH1 = Rref の両端、CH2 = 電池の両端 (差動)。CH2 は Offset で電池の直流を引いて中央に |

Impedance は CH1 と CH2 の交流の成分の比で \|Z\| を出すので、電池の直流 (3 V) は答えに入らない (目安)。

**単 3 は信号がとても小さい。** 内部抵抗 0.12 Ω に 6.7 mA を流しても、両端は 0.8 mV しか振れない。
AD3 の Scope の 14 bit の 1 目盛の分解能に近いので、平均を 100 回以上にして読む (目安)。CR2032 なら 89 mV あり、楽に読める。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 CR2032 の 1 kHz — CH2 (電池) は 88.8 mV で CH1 (電流) より 28° 遅れる
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.921V, range: 500mV/div}
ch2: {wave: sine 1kHz 88.8mV offset 3V phase -28.4deg, range: 50mV/div, position: -60div}
measure: [vpp, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/15-battery-ac-resistance.svg)

CH2 の Avg 3.00 V は電池の直流。CH2 だけ 50 mV/div に拡大し、直流の分を引いて中央に置いた。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 150 Ω、1/4 W | |
| Cb | 470 µF・16 V、アルミ電解 | + を電池の側に。直流は 0.1 V しかかからない |
| B1 | CR2032 (3 V) と単 3 アルカリ (1.5 V) | 新品と使いかけを比べる。電池ホルダーに入れ、リードをワニ口でつなぐ |
| 電源 | 電池そのもの (3 V / 1.5 V) | 測る物が電池なので、5 V の電源は使わない |

## 見るべき値

計算値。電池の**等価回路は仮定**: 直列の抵抗 R<sub>0</sub> (電解液と電極) に、反応の抵抗 R<sub>ct</sub> と電気二重層の容量 C<sub>dl</sub> の並列が直列につながる。
新品の CR2032 を R<sub>0</sub> = 10 Ω・R<sub>ct</sub> = 20 Ω・C<sub>dl</sub> = 20 µF、新品の単 3 を R<sub>0</sub> = 0.12 Ω・R<sub>ct</sub> = 0.1 Ω・C<sub>dl</sub> = 0.5 F とした。

| 電池 | 周波数 | \|Z\| | 位相 | CH2 (振幅) | 分かること |
| --- | --- | --- | --- | --- | --- |
| CR2032 | 10 Hz | 30.0 Ω | −1.0° | 164 mV | R<sub>0</sub> + R<sub>ct</sub> (ほぼ直流の内部抵抗) |
| CR2032 | **1 kHz** | **14.5 Ω** | −28.4° | 88.8 mV | 検査器の値。C<sub>dl</sub> が R<sub>ct</sub> を半分ほど短絡 |
| CR2032 | 10 kHz | 10.1 Ω | −4.5° | 62.9 mV | R<sub>0</sub> だけが残る |
| 単 3 | 1 kHz | 0.12 Ω | −0.2° | 0.80 mV | 1 kHz では R<sub>0</sub> だけ |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 CR2032 の |Z| は 30 Ω (10 Hz) から 10 Ω (10 kHz) へ下がる
x: 周波数 Hz log 10..10k
y: インピーダンス Ω log 0.05..50
lines:
  "CR2032 Ω": sqrt((10+20/(1+(0.0025133*x)^2))^2+(20*0.0025133*x/(1+(0.0025133*x)^2))^2)
  "単 3 アルカリ Ω": sqrt((0.12+0.1/(1+(0.31416*x)^2))^2+(0.1*0.31416*x/(1+(0.31416*x)^2))^2)
notes:
  - mark 10
  - mark 1k
  - mark 10k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/15-battery-ac-resistance.svg)

分かること:

- **「内部抵抗」は周波数で値が違う。** 1 kHz の値は検査器の約束で、直流で大きな電流を取ったときの電圧の落ち方
  (R<sub>0</sub> + R<sub>ct</sub> に近い) とは同じでない。比べるときは同じ周波数どうしで比べる
- 使い込んだ電池ほど R<sub>0</sub> と R<sub>ct</sub> が増える。新品と使いかけの CR2032 を同じ設定で測り、1 kHz の \|Z\| が増えているかを見る
- コイン電池は内部抵抗が大きく、数十 mA を取ると電圧が大きく落ちる。無線モジュールのように瞬間の電流が大きい回路は、
  電池に大きなコンデンサを並べて電流の山を肩代わりさせる

## LTspice での確かめ

`sim/15-battery-ac-resistance.cir` で図1 (Rref 150 Ω、Cb 470 µF、電池は R<sub>0</sub> に R<sub>ct</sub> と C<sub>dl</sub> の並列を直列にした等価回路、
W1 の振幅 1 V) を 10 Hz〜10 kHz で交流解析した。電池の直流と W1 のオフセットは打ち消し合うので、交流解析には入れていない。
等価回路の値は本文の仮定で、**実測ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| CR2032 の \|Z\| (10 Hz・1 kHz・10 kHz) | 30.0 Ω・14.5 Ω・10.1 Ω | 29.99 Ω・14.47 Ω・10.06 Ω | 合う |
| CR2032 の CH1・CH2 (1 kHz) | 0.921 V・88.8 mV | 0.9208 V・88.82 mV | 合う |
| 単 3 の \|Z\| と CH2 (1 kHz) | 0.12 Ω・0.80 mV | 0.1200 Ω・0.799 mV | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
参考: [Internal resistance — Wikipedia (英語)](https://en.wikipedia.org/wiki/Internal_resistance)
