---
book: analog-discovery
chapter: 9
id: 9-11
title: 出力インピーダンス (負荷法)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 9-11 出力インピーダンス (負荷法)

増幅回路の出力は「理想の電圧源 V<sub>o</sub> と、直列の出力インピーダンス Z<sub>out</sub>」と見なせる (テブナンの等価回路)。
負荷 RL を付けると Z<sub>out</sub> と RL の分圧で出力が下がるので、**負荷を外したときの出力 V<sub>o</sub>** と
**付けたときの出力 V<sub>L</sub>** を比べれば Z<sub>out</sub> が出る。

Z<sub>out</sub> = RL × (V<sub>o</sub> / V<sub>L</sub> − 1)

題材は回路の教科書の 2-2 のエミッタフォロア。出力インピーダンスが数十 Ω (オーム) と低いのがこの回路の取り柄で、
それを数で確かめる。RL は Z<sub>out</sub> と同じくらいの 47 Ω にする (9-10 の Rs と同じで、読みの誤差が一番響きにくい)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 エミッタフォロアの出力に RL を付け外しして、出力の下がり方を測る
parts:
  AD:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery
    pins: [2+, V+, W1, 1+, 1-, 2-, GND]
  Cin: ecap 7,6 5,6 10u
  R1: resistor 8,3 8,6 22k
  R2: resistor 9,6 9,9.5 10k
  Q1: npn 11,6 2SC1815
  RE: resistor 12,7.5 12,9.5 1k
  Cout: ecap 12,7.5 15,7.5 100u
  RL: resistor 15,7.5 15,9.5 47
wires:
  - AD.2+ -| 16,7.5
  - 16,7.5 -- 15,7.5
  - AD.V+ -| 8,3
  - 8,3 -- 12,3
  - Q1.C -| 12,3
  - AD.W1 -| 5,6
  - AD.1+ -| 4,6
  - 4,6 -- 5,6
  - 7,6 -- 8,6
  - 8,6 -- 9,6
  - 9,6 -- Q1.B
  - Q1.E -| 12,7.5
  - AD.1- -| 3,9.5
  - AD.2- -| 3,9.5
  - AD.GND -| 3,9.5
  - 3,9.5 -- 9,9.5
  - 9,9.5 -- 12,9.5
  - 12,9.5 -- 15,9.5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/11-output-impedance.svg)

- R1 (22 kΩ)・R2 (10 kΩ)・RE (1 kΩ)・Cin (10 µF。µ はマイクロ) は 2-2 と同じ。I<sub>e</sub> ≈ 0.83 mA
- Cout は 2-2 の 10 µF を **100 µF** に替えた。47 Ω と組むと 10 µF では 339 Hz から下が落ちるが、100 µF なら 34 Hz で、
  10 kHz では 0.16 Ω と RL に比べて無視できる
- CH1 (1+) は W1 (入力)、CH2 (2+) は Cout の後ろ (出力)。どちらも直流が乗らないので、細かい目盛で見られる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (RL は抜き差しする)
board: half
parts:
  Cin: capacitor/electrolytic c20(+) c16(-) 10uF v=16V
  R1: resistor b24 b20 22k
  Cout: capacitor/electrolytic d22(+) d27(-) 100uF v=16V
  RL: resistor a27 -t27 47
  Q1: transistor g20(B) g21(C) g22(E) 2SC1815
  R2: resistor h20 h15 10k
  RE: resistor h22 h27 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t8 red
  - AD.GND -- -t9 black
  - AD.W1 -- a16 yellow [h-10]
  - AD.1+ -- b16 orange [h10]
  - AD.1- -- -t18 black
  - AD.2- -- -t23 black
  - AD.2+ -- b27 purple
  - a24 -- +t24 red
  - a21 -- +t21 red
  - e20 -- f20 orange
  - e21 -- f21 red
  - e22 -- f22 gray
  - j15 -- -b15 black
  - j27 -- -b27 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/11-output-impedance.svg)

- Q1 の向きは 9-1 と同じ (平らな面を奥)。ベース (20 列)・コレクタ (21 列)・エミッタ (22 列) を溝越しの短い線で上ブロックへ渡す。
  コレクタは `a21 -- +t21` で + レールへ
- Cin は 16 列 (W1) から 20 列 (ベース) へ、+ をベースの側にする (ベースは直流 1.5 V、W1 は 0 V)。
  Cout は 22 列 (エミッタ、直流 0.83 V) が +、27 列 (出力) が −
- RL (47 Ω) は 27 列の a から上の − レールへ直に挿す。**V<sub>o</sub> を測るときは RL を抜く**。抜き差しするのはこの 1 本だけ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、10 kHz、Amplitude 20 mV |
| Scope | CH1・CH2 とも 5 mV/div、50 µs/div、平均 16 回 (目安)。Measurements に Vpp。RL を抜いて 1 回、挿して 1 回読む |

振幅を 20 mV に抑えるのは、A 級のエミッタフォロアが負の側に振れる量に上限があるため。
負の半周期にトランジスタが流す電流が 0 になる所は I<sub>e</sub> × (RE ∥ RL) = 0.83 mA × 44.9 Ω = 37 mV で、
入力 20 mV (出力 12 mV) ならその 1/3 に収まる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 RL 47 Ω を付けると出力 (CH2) は入力 (CH1) の 0.59 倍に下がる (計算)
time: 50us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 20mV, range: 5mV/div}
ch2: {wave: sine 10kHz 11.8mV, range: 5mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/11-output-impedance.svg)

図3 は RL を挿したときの計算値。RL を抜くと CH2 は 19.4 mV (38.8 mVpp) に戻る。
CH1 と CH2 は同じ 5 mV/div にしてあり、高さの比がそのまま利得になる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W) | 22 kΩ, 10 kΩ |
| RE | 抵抗 (1/4 W) | 1 kΩ |
| RL | 抵抗 (1/4 W) | 47 Ω (抜き差しする負荷。12 mV では 1.5 µW) |
| Cin | 電解コンデンサ | 10 µF |
| Cout | 電解コンデンサ | 100 µF (2-2 の 10 µF から替えた。47 Ω の負荷で 10 kHz を落とさないため) |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

計算値。hFE = 150、I<sub>e</sub> = 0.83 mA (2-2 と同じ仮定)、W1 の出力抵抗は 0 と仮定。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| r<sub>e</sub>′ = 26 mV / I<sub>e</sub> | 31.3 Ω | エミッタの中の抵抗 |
| Z<sub>out</sub> = RE ∥ (r<sub>e</sub>′ + (信号源の抵抗 ∥ R1 ∥ R2 + r<sub>bb′</sub>) / hFE) | 30.5 Ω | r<sub>bb′</sub> = 30 Ω と置いた。信号源の側は 1/hFE に縮む |
| RL を抜いたときの出力 V<sub>o</sub> | 19.4 mV (利得 0.969) | CH2 の 1 MΩ だけが負荷 |
| RL 47 Ω を付けたときの出力 V<sub>L</sub> | 11.8 mV (利得 0.59) | 47 / (47 + 30.5) のほぼ比で下がる |
| 2 つから出した Z<sub>out</sub> = 47 Ω × (19.4 / 11.8 − 1) | 30.3 Ω | 上の計算と合う |

- **信号源に抵抗があると Z<sub>out</sub> は増える**。W1 と Cin の間に 10 kΩ を入れると、(10 kΩ ∥ 6.9 kΩ) / 150 = 27 Ω が足されて
  Z<sub>out</sub> は約 57 Ω になる。エミッタフォロアは信号源の抵抗を hFE で割って見せる回路だと分かる
- 誤差: V<sub>o</sub> と V<sub>L</sub> の比が 1 % ずれると、Z<sub>out</sub> は約 2.5 % ずれる (RL = 47 Ω のとき)。RL を 1 kΩ にすると比は 0.97 で、
  同じ 1 % が約 33 % になる。**RL は測りたい Z<sub>out</sub> に近く**選ぶ
- RL を挿したとき、出力の上下の山がわずかに違う (LTspice で +12.2 mV と −11.5 mV)。I<sub>e</sub> が信号で動き r<sub>e</sub>′ が変わるためで、
  振幅をもっと上げるとはっきりする。読むのは Vpp の半分にする

## LTspice での確かめ

`sim/11-output-impedance.cir` (交流) と `sim/11-output-impedance-tran.cir` (過渡、入力 20 mV) で図1 を解き、RL を 1 MΩ (抜いた) と 47 Ω に替えて走らせた。
Q1 は 9-1 と同じ 2SC1815 の模型 (BF を 2-2 の仮定に合わせて 150)。**仮定で、実測の値ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| I<sub>e</sub> | 0.83 mA | 0.889 mA | 模型の V<sub>BE</sub> が 0.7 V より小さい分だけ多い |
| 10 kHz の利得 (RL なし・47 Ω) | 0.969・0.59 | 0.970・0.596 | 合う |
| Z<sub>out</sub> = 47 Ω × (V<sub>o</sub> / V<sub>L</sub> − 1) (10 kHz) | 30.3 Ω | 29.6 Ω | 合う (I<sub>e</sub> が多い分 r<sub>e</sub>′ が小さい) |
| 同じ式で 100 Hz | — | 31.4 Ω | 100 µF のリアクタンス (16 Ω) が少し混ざる。測るのは 10 kHz にする |
| 出力の振幅 (RL なし・47 Ω、過渡) | 19.4・11.8 mV | 19.4・+12.2 / −11.5 mV | 合う。付けたときの上下の差は本文の注記どおり |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
参考: [エミッタフォロワ](https://ja.wikipedia.org/wiki/エミッタフォロワ)
