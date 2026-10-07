---
book: analog-discovery
chapter: 9
id: 9-3
title: 1 dB 圧縮点
tier: 100
source: 自作 (計器の操作は Digilent の Using the Waveform Generator と Using the Oscilloscope)
board: BB
---

# 9-3 1 dB 圧縮点

9-2 と同じ LM358 非反転増幅 (利得 11 倍) を、今度は**振幅を段階的に上げながら**
測る。利得がどう下がっていくかは理論式だけでは決まらない
(出力段の非線形さで決まる) ので、**実測で 1 dB 下がる点を
探す**のがこの実験の主眼。理論からは「これ以上は絶対に無理」という上限
(出力の振れ幅の限界) だけを先に計算しておく。

## 回路図

```circuit
title: 図1 LM358 非反転増幅 (9-2 と同じ、利得 11 倍)
parts:
  AD:
    type: device
    at: 2,6
    label: Analog Discovery
    pins: [2+, V+, W1, 1+, 1-, 2-, GND]
    turn: mirror
  R1: resistor 11,3 11,5 100k
  R2: resistor 11,5 11,7 100k
  Cin: capacitor 6,5 8,5 1u
  U1: opamp 14,5.35 +up LM358
  Rf: resistor 17,7 13,7 10k
  Rg: resistor 13,7 13,9 1k
  Cg: capacitor 13,9 13,11 10u
  G1: ground 13,11
  G2: ground 11,7
  G3: ground 5,8
wires:
  - AD.V+ -| 5,3
  - 5,3 -- 11,3
  - AD.W1 -| 6,5
  - 8,5 -- 9,5 -- 11,5
  - AD.1+ -| 9,5
  - 11,5 -| U1.+
  - U1.- -| 13,7
  - U1.out -| 17,7
  - AD.2+ -| 4,2
  - 4,2 -- 18,2 -- 18,7
  - 17,7 -- 18,7
  - AD.GND -| 4,8
  - AD.2- -| 5,8
  - AD.1- -| 6,8
  - 4,8 -- 5,8 -- 6,8
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/03-1db-compression.svg)

9-2 と全く同じ回路 (交流利得 = 1 + Rf/Rg = 11 倍)。振幅だけを変えて何度も測る。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (9-2 と同じ配置)
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  Cin: capacitor/ceramic a5 a8 1u
  R1: resistor c3 c8 100k
  R2: resistor d8 d12 100k
  Rf: resistor h17 h20 10k
  Rg: resistor i20 i24 1k
  Cg: capacitor/electrolytic g24(+) g27(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, V+, GND, 1-, 1+, 2+, 2-]
wires:
  - AD.V+ -- +t7 red
  - AD.GND -- -t9 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a13 orange
  - AD.1- -- -t10 black
  - AD.2+ -- a17 gray
  - AD.2- -- -t19 black
  - a3 -- +t3 red
  - b8 -- b13 orange
  - a12 -- -t12 black
  - b15 -- b17 gray
  - c14 -- c20 green
  - e17 -- f17 gray
  - e20 -- f20 green
  - j12 -- -b12 black
  - g13 -- g14 green
  - j15 -- +b15 red
  - j27 -- -b27 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/03-1db-compression.svg)

9-2 と同じ配置。9-2 のブレッドボードをそのまま使い、振幅だけを Wavegen 側で変えていく。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、**1 kHz** (スルーレートの影響を避けるため低め)、振幅を 10・20・40・60・80・90・100 mV と段階的に上げる |
| Scope | CH1 = 入力 (バイアス点)、CH2 = 出力。それぞれ Amplitude を測定し、その都度利得 (dB) を計算する |

計器は Analog Discovery 3 の Supplies (+5 V、LM358 の消費電流は数 mA で各レール 50 mA に収まる)、Wavegen、Scope。

振幅を上限の 90.9 mV より大きい 100 mV にしたときの画面を図3 に示す。
CH1 (入力) は 2.5 V のバイアスに 100 mV が乗る。出力の交流分は 100 mV × 11 = 1.1 V だが、上側は 3.5 V (2.5 V + 1.0 V) で頭打ちになる。
図は頭打ちを理想の直線で切って描いたもので、**実機は丸まりながら頭打ちになる** (3.5 V は代表値)。下側は 2.5 − 1.1 = 1.4 V まで振れて切れない。

```scope
title: 図3 入力 100 mV は出力の上側が 3.5 V で頭打ち
time: 500us/div
trigger: ch1 rising 2.5V
ch1: {wave: sine 1kHz 0.1V offset 2.5V, range: 50mV/div, position: -50div}
ch2: {wave: ch1 | offset -2.5V | gain 11 | offset 2.5V | clip 0V 3.5V, range: 1V/div, position: -2.5div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/03-1db-compression.svg)

図3 の CH2 は Vmax 3.50 V、Vmin 1.40 V。CH1 と CH2 は縦の尺度が違う (50 mV/div と 1 V/div) ので、高さを直接比べない。

## 見るべき値

小信号利得は 9-2 で確かめた 11 倍 (20.83 dB)。1 dB 下がった利得は
9.80 倍 (19.83 dB) — **この利得になった入力振幅が 1 dB 圧縮点**。

LM358 は単電源 (Vcc = 5 V、バイアス 2.5 V) で、データシートの代表値では
出力の上側は Vcc − 1.5 V 程度までしか振れない (**代表値**。下側は GND 近くまで
振れる、単電源オペアンプによくある非対称な制約)。上側の余裕は
3.5 − 2.5 = 1.0 V しかないので、**小信号利得のまま外挿した限界入力振幅**は
1.0 V / 11 ≒ **90.9 mV**。

| 入力振幅 | 小信号モデルの利得 (参考) | 実際の利得 |
| --- | --- | --- |
| 10〜40 mV | 20.83 dB (一定のはず) | ほぼ 20.83 dB (線形領域) |
| 60〜80 mV | 20.83 dB (一定のはず) | 90.9 mV の上限に近づくにつれ下がり始めるはず |
| 90 mV 付近 | 20.83 dB (計算上の値) | **実際は出力が上側の限界 (3.5 V) に迫り、これより低い** |

**90.9 mV は「これを超えたら小信号モデルでは説明できない」という上限であって、
1 dB 圧縮点そのものではない。** 実際の圧縮は出力段が非線形に丸まりながら
起きるので、90.9 mV よりいくらか小さい振幅で先に 1 dB 下がる。段階的に
振幅を上げながら利得を計算し、19.8 dB を最初に下回った振幅が測定による
1 dB 圧縮点になる。

先に計算できる 2 本 (図4) (小信号利得のまま伸ばした出力と、上側の限界 1.0 V) を描く。
実測の点はこの 2 本の交点より手前で、上の線から丸まって離れていく。

```graph
title: 図4 小信号の直線が上限 1.0 V に当たるのが入力 90.9 mV (計算)
x: 入力振幅 mV 0..120
y: 出力の上側の振れ V 0..1.4
lines:
  小信号 11 倍 V: 11*x/1000
  上側の限界 V: 1.0 + 0*x
notes:
  - mark 90.9
  - band 60 90.9: 下がり始めるはずの所
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/03-1db-compression.svg)

分かること:

- 入力 90.9 mV で、11 倍の直線が上側の限界 (3.5 − 2.5 = 1.0 V) に届く
- 1 dB 圧縮点はこの交点より左にある (上の表では 60〜80 mV で下がり始めるはず)。どこかは実測で決まる

## 出典

自作。計器の名前と操作は Digilent の
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)
と
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
LM358 の出力振れ幅の代表値はメーカーのデータシートによる。
