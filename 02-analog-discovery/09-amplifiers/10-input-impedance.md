---
book: analog-discovery
chapter: 9
id: 9-10
title: 入力インピーダンス (直列抵抗法)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-10 入力インピーダンス (直列抵抗法)

増幅回路の入力インピーダンス Z<sub>in</sub> は、前の段 (信号源) をどれだけ重くするかを決める。
測り方は簡単で、信号源と回路の間に既知の抵抗 Rs を 1 本入れ、その両端の電圧 V<sub>1</sub> (信号源の側) と
V<sub>2</sub> (回路の側) を 2 ch で同時に読む。Rs と Z<sub>in</sub> の分圧なので

Z<sub>in</sub> = Rs × V<sub>2</sub> / (V<sub>1</sub> − V<sub>2</sub>)

**Rs を Z<sub>in</sub> と同じくらいに選ぶ**と V<sub>2</sub> ≈ V<sub>1</sub> / 2 になり、読み値の誤差が Z<sub>in</sub> に一番響きにくい。
題材は 9-1 のエミッタ接地 (計算の入力インピーダンス 7.66 kΩ (オーム)) で、Rs は E24 の 7.5 kΩ。
Network を使えば V<sub>2</sub> / V<sub>1</sub> が周波数ごとに出て、Z<sub>in</sub> の周波数特性まで分かる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 9-1 のエミッタ接地の手前に Rs を入れ、両端の電圧を測る
parts:
  AD:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery
    pins: [V+, 2+, 1+, W1, 1-, 2-, GND]
  Rs: resistor 6,6 9,6 7.5k
  Cin: capacitor 10,6 12,6 1u
  R1: resistor 12,3 12,6 39k
  R2: resistor 13,6 13,9 12k
  Q1: npn 15,6 2SC1815
  Rc: resistor 17,3 17,5 1k
  Re: resistor 17,7 17,9 220
wires:
  - AD.V+ -| 12,3
  - 12,3 -- 17,3
  - AD.W1 -| 5,6
  - 5,6 -- 6,6
  - AD.1+ -| 6,6
  - 9,6 -- 9.5,6
  - AD.2+ -| 9.5,6
  - 9.5,6 -- 10,6
  - 12,6 -- 13,6
  - 13,6 -- Q1.B
  - Q1.C -| 17,5
  - Q1.E -| 17,7
  - AD.1- -| 4,9
  - AD.2- -| 4,9
  - AD.GND -| 4,9
  - 4,9 -- 13,9
  - 13,9 -- 17,9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/10-input-impedance.svg)

- 9-1 の回路 (R1 39 kΩ・R2 12 kΩ・Rc 1 kΩ・Re 220 Ω・Cin 1 µF) の手前に Rs (7.5 kΩ) を入れた (µ はマイクロ)
- CH1 (1+) は W1 の側 (V<sub>1</sub>)、CH2 (2+) は Rs と Cin の間 (V<sub>2</sub>)。1−・2− は GND
- 測る Z<sub>in</sub> は Cin を含む (Cin の手前で測る)。Cin の 1 µF は 1 kHz で 159 Ω で、中域ではほとんど効かない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (9-1 の配置に Rs を足す)
board: half
parts:
  Rs: resistor d10 d16 7.5k
  Cin: capacitor/ceramic c16 c20 1u
  R1: resistor b24 b20 39k
  Rc: resistor d26 d21 1k
  Q1: transistor g20(B) g21(C) g22(E) 2SC1815
  R2: resistor h20 h15 12k
  Re: resistor h22 h27 220
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t5 red
  - AD.GND -- -t6 black
  - AD.W1 -- a10 yellow [h-10]
  - AD.1+ -- b10 orange [h10]
  - AD.1- -- -t13 black
  - AD.2+ -- a16 purple
  - AD.2- -- -t18 black
  - a24 -- +t24 red
  - a26 -- +t26 red
  - e20 -- f20 orange
  - e21 -- f21 gray
  - j15 -- -b15 black
  - j27 -- -b27 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/10-input-impedance.svg)

- 9-1 の配置の Cin の左 (16 列) に Rs (d10〜d16) を足し、W1 (黄) と 1+ (橙) を 10 列へ、2+ (紫) を 16 列へ挿す。
  9-1 でコレクタに当てていた 2+ は外す
- Q1 の向き (平らな面を奥) と、ほかの部品は 9-1 と同じ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、1 kHz、Amplitude 100 mV (V<sub>2</sub> がベースへ 50 mV ほど入る。9-1 と同じ大きさ) |
| Scope | CH1・CH2 とも 50 mV/div、200 µs/div。Measurements に Vpp と Phase |
| Network (周波数特性) | 掃引 10 Hz〜1 MHz、点数 101、振幅 100 mV、Reference = CH1、DUT = CH2 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 kHz で V2 (CH2) は V1 (CH1) のほぼ半分。Zin は Rs とほぼ等しい (計算)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 100mV, range: 50mV/div}
ch2: {wave: sine 1kHz 50.3mV phase -0.6deg, range: 50mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/10-input-impedance.svg)

図3 は Z<sub>in</sub> = 7.60 kΩ − j159 Ω と置いた計算値。V<sub>2</sub> / V<sub>1</sub> = 0.503、位相は 0.6° 遅れ。
Vpp の比から Z<sub>in</sub> = 7.5 kΩ × 0.503 / (1 − 0.503) = 7.6 kΩ。2 本を同じ 50 mV/div にしたのは、高さの比がそのまま V<sub>2</sub> / V<sub>1</sub> になるようにするため。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Rs | 抵抗 (1/4 W) | 7.5 kΩ (Z<sub>in</sub> と同じくらい。E24) |
| R1, R2 | 抵抗 (1/4 W) | 39 kΩ, 12 kΩ |
| Rc, Re | 抵抗 (1/4 W) | 1 kΩ, 220 Ω |
| Cin | 積層セラミックコンデンサ | 1 µF (105) |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

計算値。hFE = 200、I<sub>e</sub> = 2.17 mA (r<sub>e</sub>′ = 11.5 Ω) と仮定 (9-1 と同じ)。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| ベースから見た抵抗 hFE (Re + r<sub>e</sub>′) | 46.3 kΩ | エミッタの抵抗が hFE 倍に見える |
| Z<sub>in</sub> = R1 ∥ R2 ∥ hFE (Re + r<sub>e</sub>′) | 7.66 kΩ | 分圧の 9.18 kΩ が大半を決める |
| CH2 の入力抵抗 1 MΩ を並べた値 | 7.60 kΩ | 計器の負荷で 0.8 % 小さく見える |
| 1 kHz の V<sub>2</sub> / V<sub>1</sub> | 0.503 | Rs と Z<sub>in</sub> がほぼ等しい |
| 20 Hz の \|Z<sub>in</sub>\| | 11.0 kΩ | Cin の 7.96 kΩ が直列に足される |
| hFE 120・400 のときの Z<sub>in</sub> | 6.85・8.28 kΩ | hFE の影響は R1 ∥ R2 に薄められる |

Network の結果 (V<sub>2</sub> / V<sub>1</sub> の複素数) を上の式で Z<sub>in</sub> に直して描くと、次の形になる。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 |Zin| は中域で 7.6 kΩ。低域は Cin、高域は容量で変わる (計算と LTspice)
x: 周波数 Hz log 10..1M
y: 入力インピーダンス kΩ 0..20
lines:
  計算 kΩ: sqrt(7.60^2 + (1/(2*pi*x*1u)/1000)^2)
  LTspice kΩ:
    - 10 17.52
    - 20 10.95
    - 50 8.22
    - 100 7.75
    - 1k 7.59
    - 10k 7.59
    - 100k 7.45
    - 300k 6.56
    - 1M 3.49
notes:
  - level 7.5kΩ
  - mark 20
  - mark 1k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/10-input-impedance.svg)

- 100 Hz〜100 kHz で 7.5〜7.8 kΩ の平らな所。ここが「入力インピーダンス」として表に書く値
- 100 Hz より下は Cin のリアクタンスで上がる。300 kHz より上は CH2 の 24 pF とトランジスタの容量 (ベース・コレクタ間の
  容量が利得の分だけ大きく見えるミラー効果) で下がる
- 誤差の見積り: V<sub>2</sub> / V<sub>1</sub> の読みが 1 % ずれると Z<sub>in</sub> は約 2 % ずれる (Rs = Z<sub>in</sub> のとき)。Rs を Z<sub>in</sub> の 1/10 にすると、
  同じ 1 % が約 11 % になる

## LTspice での確かめ

`sim/10-input-impedance.cir` で図1 を交流で解いた。節点 V<sub>2</sub> に CH2 の入力 (1 MΩ ∥ 24 pF) を付け、Z<sub>in</sub> = Rs × V<sub>2</sub> / (V<sub>1</sub> − V<sub>2</sub>) を読んだ。
Q1 は 9-1 と同じ 2SC1815 の模型 (BF を 120・200・400 に替えた)。**仮定で、実測の値ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 kHz の V<sub>2</sub> / V<sub>1</sub> | 0.503 | 0.503 | 合う |
| 1 kHz の \|Z<sub>in</sub>\| (hFE 200) | 7.60 kΩ | 7.59 kΩ | 合う |
| hFE 120・400 | 6.85・8.28 kΩ | 6.86・8.26 kΩ | 合う |
| 20 Hz の \|Z<sub>in</sub>\| | 11.0 kΩ | 10.95 kΩ | 合う |
| 10 Hz の \|Z<sub>in</sub>\| | 17.6 kΩ | 17.5 kΩ | 合う |
| 100 kHz・1 MHz の \|Z<sub>in</sub>\| | 平らな所から下がり始める | 7.45・3.49 kΩ | 計算 (Cin だけ) には入っていない容量の効果 |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
参考: [入力インピーダンス](https://ja.wikipedia.org/wiki/入力インピーダンス)
