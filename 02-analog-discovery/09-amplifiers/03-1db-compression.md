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
測る。小信号利得からの下がり方が滑らかにいくらになるかは理論式だけでは
決まらない (回路の出力段の非線形さで決まる) ので、**実測で 1 dB 下がる点を
探す**のがこの実験の主眼。理論からは「これ以上は絶対に無理」という上限
(出力の振れ幅の限界) だけを先に計算しておく。

## 回路図

```circuit
title: 図1 LM358 非反転増幅 (9-2 と同じ、利得 11 倍)
parts:
  AD:
    type: device
    at: f2
    label: Analog Discovery
    pins: [2+, V+, W1, 1+, 1-, 2-, GND]
    turn: mirror
  R1: resistor c11 e11 100k
  R2: resistor e11 g11 100k
  Cin: capacitor e6 e8 1u
  U1: opamp e14d0f0 +up LM358
  Rf: resistor g17 g13 10k
  Rg: resistor g13 i13 1k
  Cg: capacitor i13 k13 10u
  G1: ground k13
  G2: ground g11
  G3: ground h5
wires:
  - AD.V+ -| c5
  - c5 -- c11
  - AD.W1 -| e6
  - e8 -- e9 -- e11
  - AD.1+ -| e9
  - e11 -| U1.+
  - U1.- -| g13
  - U1.out -| g17
  - AD.2+ -| b4
  - b4 -- b18 -- g18
  - g17 -- g18
  - AD.GND -| h4
  - AD.2- -| h5
  - AD.1- -| h6
  - h4 -- h5 -- h6
style:
  pitch: 1.2
```

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
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t4 black
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

9-2 と同じ配置。9-2 の板をそのまま使い、振幅だけを Wavegen 側で変えていく。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、**1 kHz** (スルーレートの影響を避けるため低め)、振幅を 10・20・40・60・80・90・100 mV と段階的に上げる |
| Scope | CH1 = 入力 (バイアス点)、CH2 = 出力。それぞれ Amplitude を測定し、その都度利得 (dB) を計算する |

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

## 出典

自作。計器の名前と操作は Digilent の
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)
と
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
LM358 の出力振れ幅の代表値はメーカーのデータシートによる。
