---
book: analog-discovery
chapter: 9
id: 9-12
title: PSRR
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-12 PSRR

オペアンプの電源が揺れると、その一部が入力の誤差電圧に化けて出力に出る。どれだけ揺れを退けるかを
**PSRR** (電源電圧変動除去比) と呼び、入力に換算した誤差 ΔV<sub>os</sub> と電源の揺れ ΔV<sub>S</sub> の比で表す。

PSRR = 20 log<sub>10</sub>(ΔV<sub>S</sub> / ΔV<sub>os</sub>) [dB]

ΔV<sub>os</sub> は増幅回路の雑音利得 (非反転なら 1 + Rf / Rg) 倍されて出力に出る。PSRR が 80 dB なら電源の揺れの 1/10,000 が
入力に化けるだけだが、利得 101 倍の回路では出力に 1/100 が出る。

測り方: **オペアンプの V+ ピンを AD3 の W1 から給電し、W1 に直流 4.4 V と小さな正弦波を重ねる**。LM358 の消費電流は
2 回路で 0.7 mA (資料の代表値、最大 1.2 mA) と小さく、W1 で賄える。電源の揺れ (CH1) と出力の揺れ (CH2) の比を
Network で読めば、PSRR が周波数ごとに出る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 LM358 の V+ を W1 で揺らし、出力に漏れる分を測る
parts:
  AD:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery
    pins: [W1, 1+, 2+, V+, 1-, 2-, GND]
  U1: dip8 12,7 LM358
  R1: resistor 6,5 6,7.4 33k
  R2: resistor 6,7.4 6,9.5 22k
  Cb: capacitor 7.75,7.4 7.75,9.5 10u
  Rf: resistor 9.6,4.5 9.6,7 100k
  Rg: resistor 9.6,8 9.6,9.5 1k
  Cg: capacitor 9.6,9.5 9.6,11 10u
wires:
  - AD.W1 -| 14.5,6.6
  - 14.5,6.6 -- 14,6.6
  - AD.1+ -| 14,6.6
  - 14,6.6 -- U1.V+
  - AD.2+ -| 9.6,4.5
  - U1.OUT1 -| 10.8,4.5
  - 10.8,4.5 -- 9.6,4.5
  - 9.6,7 -- U1.IN1-
  - 9.6,7 -- 9.6,8
  - AD.1- -| 5,5
  - AD.V+ -| 6,5
  - 5,5 -- 6,5
  - 6,7.4 -- 7.75,7.4
  - 7.75,7.4 -- U1.IN1+
  - U1.OUT2 -- U1.IN2-
  - U1.IN2+ -| 14,11
  - U1.V- -| 10.85,11
  - AD.2- -| 3,11
  - AD.GND -| 3,11
  - 6,9.5 -- 6,11
  - 7.75,9.5 -- 7.75,11
  - 3,11 -- 6,11
  - 6,11 -- 7.75,11
  - 7.75,11 -- 9.6,11
  - 9.6,11 -- 10.85,11
  - 10.85,11 -- 14,11
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/12-psrr.svg)

- U1 (LM358) の 8=V+ は W1 だけにつなぐ。**ふだん V+ に付けるパスコンは付けない** (W1 の揺れを吸ってしまい、
  10 kHz で 0.1 µF (マイクロファラド) なら 160 Ω (オーム) と W1 に重い)
- 非反転入力 (+) は AD3 の V+ (Supplies の 5 V) から R1・R2 (33 kΩ・22 kΩ) で 2.0 V。Cb (10 µF) で揺れを落とす。
  バイアスを W1 から取ると、揺れが + 入力から直に入り、PSRR ではなく分圧の比を測ってしまう
- 交流の利得 1 + Rf / Rg = 101 倍、直流は Cg で 1 倍 (出力の直流 2.0 V)
- CH1 は 1+ を 8=V+、1− を AD3 の V+ (5 V) に当てた差動。直流は −0.6 V になり、揺れだけを細かい目盛で見られる。
  CH2 は出力 (1=OUT1) と GND
- 使わない 2 回路目は 9-2 と同じくフォロワにして 5=IN2+ を GND へ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (下の + レールが W1 の電源)
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  R1: resistor c3 c8 33k
  R2: resistor d8 d12 22k
  Cb: capacitor/electrolytic a8(+) -t8(-) 10uF v=16V
  Rf: resistor h17 h20 100k
  Rg: resistor i20 i24 1k
  Cg: capacitor/electrolytic g24(+) g27(-) 10uF v=16V
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 2+, 2-, 1+, W1]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t4 black
  - AD.1- -- +t10 white
  - AD.2- -- -t19 black
  - AD.2+ -- a17 gray
  - AD.W1 -- +b29 yellow
  - AD.1+ -- +b28 orange
  - j15 -- +b15 red
  - a3 -- +t3 red
  - b8 -- b13 green
  - a12 -- -t12 black
  - b15 -- b17 gray
  - c14 -- c20 blue
  - e17 -- f17 gray
  - e20 -- f20 blue
  - j12 -- -b12 black
  - g13 -- g14 blue
  - j27 -- -b27 black
  - -t1 -- -b1 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/12-psrr.svg)

- U1 の置き方と帰還 (Rf・Rg・Cg) は 9-2 と同じ。8=V+ (f15) は `j15 -- +b15` で**下の + レール**へ。
  下の + レールは W1 (黄) だけが給電し、AD3 の V+ にはつながない (上下の + レールを渡さない)
- 1+ (橙) も下の + レールへ挿す。1− (白) は上の + レール (AD3 の V+)
- 非反転入力のバイアス: R1 (c3〜c8)・R2 (d8〜d12)・Cb (a8 から上の − レール) を左の上ブロックに置き、8 列を緑の線 (`b8 -- b13`) で 3=IN1+ へ
- 上下の − レールは 1 列で渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (バイアスだけに使う)、Master Enable を入れる |
| Wavegen (W1 が U1 の電源) | Sine、1 kHz、Offset 4.4 V、Amplitude 0.4 V (4.0〜4.8 V)。**先に W1 を出してから**Supplies を入れる (+ 入力が電源より高い時間を作らない) |
| Scope | CH1 200 mV/div、CH2 2 mV/div・Offset −2.0 V (出力の直流 2.0 V を消す)、200 µs/div、平均 16 回 (目安) |
| Network | 掃引 100 Hz〜100 kHz、振幅 0.4 V、Offset 4.4 V、Reference = CH1、DUT = CH2、平均を多めに (出力の揺れは数 mV) |

Network の W1 にも Offset を入れる (Network の Wavegen の欄の Offset。入れないと U1 の電源が 0 V を中心に振れる)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 電源の揺れ 0.8 Vpp (CH1) が出力に 8 mVpp (CH2) 漏れる (80 dB の計算)
time: 200us/div
trigger: ch1 rising -0.6V
ch1: {wave: sine 1kHz 0.4V offset -0.6V, range: 200mV/div, position: 4.5div}
ch2: {wave: sine 1kHz 4.04mV, range: 2mV/div, position: -1.5div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/12-psrr.svg)

図3 は PSRR を 80 dB と置いた計算値 (1 kHz)。出力の揺れ = 0.4 V × 101 / 10,000 = 4.04 mV。CH1 と CH2 は
尺度が 100 倍違う (揺れの大きさが 100 倍違うため)。高さの比ではなく Vpp の比で読む。位相は描いていない (実物で測る)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ | LM358 (2 回路目はフォロワ) |
| R1, R2 | 抵抗 (1/4 W) | 33 kΩ, 22 kΩ (+ 入力を 2.0 V に) |
| Cb | 電解コンデンサ | 10 µF (+ 入力の揺れを落とす) |
| Rf, Rg | 抵抗 (1/4 W) | 100 kΩ, 1 kΩ (交流の利得 101 倍) |
| Cg | 電解コンデンサ | 10 µF (直流の利得を 1 倍に) |
| — | 電源 | U1 は W1 (4.4 V ± 0.4 V。U1 の最低動作電圧 3 V より上)、バイアスは AD3 の V+ (5 V) |

## 見るべき値

LM358 の資料の PSRR は直流で代表 100 dB・最小 65 dB (V<sub>S</sub> = 5〜30 V)。周波数ごとの図は同じ資料の LM358B にだけあり、
正の電源の側 (PSRR+) は 10 kHz まで約 80 dB で平ら (V<sub>S</sub> = 36 V の図からの読み、目安)。ここでは 80 dB と 100 dB の 2 つで計算する。

| 項目 | PSRR 80 dB | PSRR 100 dB | 分かること |
| --- | --- | --- | --- |
| 1 kHz の出力の揺れ (振幅) | 4.04 mV | 0.40 mV | 利得 101 倍をかけてやっと mV になる |
| Network の読み (CH2 / CH1、1 kHz) | −40.0 dB | −60.0 dB | 読み + 20 log<sub>10</sub>101 (= 40.1 dB) を逆にすると PSRR |
| 10 kHz の読み | −42.9 dB | −62.9 dB | 下がるのは PSRR ではなく雑音利得 (GBW 1 MHz で 9.9 kHz から落ちる) |

**PSRR = 20 log<sub>10</sub>(雑音利得) − 読み**。雑音利得は周波数で下がる (101 / √(1 + (f / 9.9 kHz)<sup>2</sup>)) ので、
高い周波数ではそれも計算に入れる。100 dB の個体では 1 kHz の出力の揺れが 0.4 mV で、LM358 の雑音
(40 nV/√Hz × 101 倍、10 kHz の幅で約 0.5 mV<sub>rms</sub>) と同じくらいになる。Network の平均を増やして読む。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 Network の読み (CH2/CH1)。平らな所の値から PSRR を出す (計算)
x: 周波数 Hz log 100..100k
y: 読み dB -90..-30
lines:
  PSRR 80 dB dB: 20*log10(101/sqrt(1+(x/9.9k)^2)) - 80
  PSRR 100 dB dB: 20*log10(101/sqrt(1+(x/9.9k)^2)) - 100
notes:
  - mark 1k
  - mark 9.9k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/12-psrr.svg)

- 平らな所 (1 kHz 付近) の読みから PSRR を出す。−40 dB なら 80 dB、−60 dB なら 100 dB
- 10 kHz から上で下がるのは雑音利得の帯域のため。この回路で高い周波数の PSRR を測るなら、利得を下げて帯域を広げる
- 電源の揺れが出力に 1/100 出る、という感覚は、ふだん V+ のパスコンを付ける理由そのもの

## LTspice での確かめ

`sim/12-psrr.cir` で図1 を交流で解いた。オペアンプは 9-2 と同じ 1 極の汎用模型で、PSRR は「+ 入力に
1e-4 × V<sub>S</sub> (80 dB) の誤差電圧を足す」形で入れた。**PSRR の値は仮定 (資料の図の目安) で、LTspice は計算の筋道
(雑音利得をかけて出力に出ること) を確かめただけ**。実測の値ではない。

| 項目 | 本文の数字 (80 dB) | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の揺れ 100 Hz・1 kHz | 4.04 mV | 3.99・4.02 mV | 合う (100 Hz は Cg の分わずかに低い) |
| 出力の揺れ 10 kHz | 2.87 mV (−42.9 dB) | 2.84 mV | 合う |
| 出力の揺れ 100 kHz | 0.40 mV | 0.40 mV | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
PSRR・消費電流・雑音の値は TI の [LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) (LM358 の電気的特性の表と、LM358B の CMRR and PSRR vs Frequency の図)。
参考: [Power supply rejection ratio (英語版 Wikipedia)](https://en.wikipedia.org/wiki/Power_supply_rejection_ratio)
