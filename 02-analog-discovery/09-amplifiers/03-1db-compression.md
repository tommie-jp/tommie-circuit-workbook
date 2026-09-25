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
    at: a1
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 100k
  R2: resistor c6 c9 100k
  Cin: capacitor f3 f6 1u
  U1: opamp i6 LM358
  Rf: resistor c14 f14 10k
  Rg: resistor f14 f17 1k
  Cg: capacitor f17 i17 10u
  G1: ground i17
wires:
  - AD.V+ -| c3
  - AD.W1 |- f3
  - f6 -- c6
  - AD.1+ -| c6
  - U1.+ |- c6
  - U1.- |- f14
  - U1.out |- c14
  - AD.2+ -| c14
  - AD.1- -| c9
  - AD.2- -| c9
  - AD.GND -| c9
```

9-2 と全く同じ回路 (交流利得 = 1 + Rf/Rg = 11 倍)。振幅だけを変えて何度も測る。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (9-2 と同じ配置)
board: full
parts:
  U1: dip8 @ e5 LM358
  R1: resistor d30 d35 100k
  R2: resistor e25 e30 100k
  Cin: capacitor/ceramic b27 b30 1u
  Rf: resistor j5 j6 10k
  Rg: resistor i6 i9 1k
  Cg: capacitor/electrolytic h9(+) h12(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - a5 -- +t5 red
  - j8 -- -b8 black
  - c35 -- +t35 red
  - c25 -- -t25 black
  - c30 -- g7 orange
  - AD.W1 -- a27 yellow
  - AD.1+ -- a30 orange
  - AD.2+ -- i5 gray
  - AD.1- -- -t8 black
  - AD.2- -- -t9 black
  - i12 -- -b12 black
  - +t50 -- +b50 red
  - -t50 -- -b50 black
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
