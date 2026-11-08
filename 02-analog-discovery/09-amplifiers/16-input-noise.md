---
book: analog-discovery
chapter: 9
id: 9-16
title: 入力換算雑音
tier: 200
source: 自作 (計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 9-16 入力換算雑音

入力を何もつながず (交流で GND に落として) も、増幅回路の出力には雑音が出る。出所はオペアンプの中の雑音と抵抗の熱雑音で、
出力の雑音を回路の利得で割り、**入力に換算した雑音密度** (nV/√Hz) で表すと、利得の違う回路どうしやデータシートの値と比べられる。

e<sub>n,in</sub> = e<sub>n,out</sub> / (雑音利得)

9-12 と同じ LM358 の利得 101 倍の回路を、電源を AD3 の V+ に戻して使う。出力の雑音を **Spectrum** で読み、
1 bin あたりの電力から密度に直し、101 で割る。LM358 の資料の代表値は 1 kHz で 40 nV/√Hz なので、出力では 4 µV/√Hz (µV はマイクロボルト) になる。
AD3 の入力の雑音より大きくなるように、利得を 101 倍に上げてある。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 利得 101 倍の LM358。入力を交流で GND に落とし、出力の雑音を測る
parts:
  AD:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery
    pins: [V+, 2+, 2-, GND]
  U1: dip8 12,7 LM358
  R1: resistor 6,5 6,7.4 33k
  R2: resistor 6,7.4 6,9.5 22k
  Cb: capacitor 7.75,7.4 7.75,9.5 10u
  Rf: resistor 9.6,4.5 9.6,7 100k
  Rg: resistor 9.6,8 9.6,9.5 1k
  Cg: capacitor 9.6,9.5 9.6,11 10u
wires:
  - AD.V+ -| 14,3.5
  - 14,3.5 -- 14,6.6
  - 14,6.6 -- U1.V+
  - 14,3.5 -- 6,3.5
  - AD.2+ -| 9.6,4.5
  - U1.OUT1 -| 10.8,4.5
  - 10.8,4.5 -- 9.6,4.5
  - 9.6,7 -- U1.IN1-
  - 9.6,7 -- 9.6,8
  - 6,3.5 -- 6,5
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/16-input-noise.svg)

- 非反転入力 (+) は R1・R2 で 2.0 V に置き、Cb (10 µF) で交流を GND に落とす。分圧の 13.2 kΩ (オーム) の熱雑音 (15 nV/√Hz) も
  Cb で 2 Hz より上は消える
- 雑音利得 1 + Rf / Rg = 101 倍。Rg (1 kΩ) の熱雑音 4.07 nV/√Hz は入力に直に足され、Rf (100 kΩ) の 40.7 nV/√Hz は出力に足される
  (入力に換算すると 0.40 nV/√Hz)
- CH2 は出力 (1=OUT1) と GND。CH1 は使わない (計器の雑音を測るときに、1+ と 1− を GND に当てて比べる)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (9-12 の配置で、8=V+ を V+ へ)
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  R1: resistor c3 c8 33k
  R2: resistor d8 d12 22k
  Cb: capacitor/electrolytic a8(+) -t8(-) 10uF
  Rf: resistor h17 h20 100k
  Rg: resistor i20 i24 1k
  Cg: capacitor/electrolytic g24(+) g27(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t4 black
  - AD.2- -- -t19 black
  - AD.2+ -- a17 gray
  - +t29 -- +b29 red
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/16-input-noise.svg)

- 9-12 の配置から W1 と CH1 を外し、8=V+ を下の + レール経由で AD3 の V+ へ (`j15 -- +b15`、上下の + レールは 29 列で渡す)
- 計器の線は短く。CH2 の線 (灰) が長いと、商用電源の 50/60 Hz を拾ってスペクトルに線が立つ

オシロの図は入れない: この題が読む量は雑音の周波数ごとの密度で、時間の波形からは全体の大きさ (実効値) しか読めないため。
実効値は下の「見るべき値」に数で置く。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Spectrum | CH2、Range 0〜5 kHz、点数 8192 (1 bin 1.5625 Hz)、窓 Hann、単位 dBm、平均 32 回 (目安)。CH2 の Offset で直流 2.0 V を消し、Range を細かく |
| Spectrum (計器のフロア) | 同じ設定で 2+ を GND に当てて 1 回。回路の読みがこれより 10 dB 以上上なら、計器の雑音は無視できる |

WaveForms の Spectrum には雑音を V/√Hz で出す単位がある版もある (目安。版で違う)。無ければ下の式で dBm から直す。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 出力の雑音のフロアは −91 dBm (1 bin 2.34 Hz あたり。4.06 µV/√Hz の計算)
device: ad3
sweep: 0-5kHz
samples: 8192
window: hann
unit: dBm
ref: -70dBm
floor: -91dBm
markers: [1kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/spectrum/16-input-noise.svg)

図3 は出力の雑音密度を 4.06 µV/√Hz の白色雑音と置いた計算値。Hann の窓の等価雑音帯域は 1.5 bin = 2.34 Hz なので、
1 bin に入る雑音は 4.06 µV/√Hz × √2.34 Hz = 6.22 µV<sub>rms</sub>、50 Ω の電力で −91.1 dBm。実物では 50/60 Hz とその倍の線が乗る。

**dBm から密度に直す式**: e<sub>n,out</sub> = √(50 Ω × 1 mW × 10<sup>(読み/10)</sup> / ENBW)。ENBW = 1.5 × bin の幅 (Hann)。
窓や点数を変えると読みの dBm は変わるが、この式で直した密度は変わらない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ | LM358 (2 回路目はフォロワ) |
| R1, R2 | 抵抗 (1/4 W) | 33 kΩ, 22 kΩ |
| Cb | 電解コンデンサ | 10 µF |
| Rf, Rg | 抵抗 (1/4 W) | 100 kΩ, 1 kΩ (金属皮膜。炭素皮膜は電流による余分な雑音が出やすい) |
| Cg | 電解コンデンサ | 10 µF |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

計算値。LM358 の電圧雑音 40 nV/√Hz (資料の代表値、1 kHz)、室温 27 °C (4kT = 1.66 × 10<sup>−20</sup> J)。
電流雑音は資料に無いので入れていない (目安)。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| 入力換算の雑音密度 (1 kHz) | √(40<sup>2</sup> + 4.07<sup>2</sup> + 0.40<sup>2</sup>) = 40.2 nV/√Hz | オペアンプが大半。Rg は 1 % ほどしか足さない |
| 出力の雑音密度 (1 kHz) | 4.06 µV/√Hz | 101 倍 |
| Spectrum の 1 bin の読み | −91.1 dBm | 図3 |
| 出力の実効値 (10 Hz〜10 kHz) | 0.36 mV<sub>rms</sub> | 9.9 kHz で雑音利得が下がる分も入れた。Scope の AC RMS で比べられる |
| 10 Hz の入力換算 | 約 55 nV/√Hz (目安) | 1/f 雑音。資料の LM358B の図では 10 Hz で約 55、100 Hz より上で約 40 |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 入力換算雑音。1 kHz で 40 nV/√Hz、低い周波数で 1/f 雑音が増える (資料の図からの目安)
x: 周波数 Hz log 10..10k
y: 雑音密度 nV/√Hz 0..100
lines:
  入力換算 nV/√Hz: sqrt(40^2*(1+8.9/x) + 4.07^2)
  出力 ÷ 101 nV/√Hz: sqrt(40^2*(1+8.9/x) + 4.07^2)/sqrt(1+(x/9.9k)^2)
notes:
  - mark 10
  - mark 1k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/16-input-noise.svg)

- 低い周波数で増えるのが 1/f 雑音。図は資料の LM358B の雑音の図 (V<sub>S</sub> = 36 V) を「角の周波数 9 Hz」の式に置いた目安で、
  手元の LM358 では違ってよい
- 出力を 101 で割った線が 9.9 kHz の手前で下がるのは、回路の帯域 (GBW 1 MHz ÷ 101) のため。入力換算するのは帯域の中だけ
- Rg を 10 Ω、Rf を 1 kΩ にすると、利得は同じで抵抗の雑音は 1/10 になる。ただしオペアンプの出力に重い (9-3 の出力の限界)

## LTspice での確かめ

`sim/16-input-noise.cir` で図1 の雑音解析 (.noise) をした。オペアンプは 9-2 と同じ汎用模型で雑音を持たないので、
**40 nV/√Hz を非反転入力に直列の 96.6 kΩ の熱雑音で置いた** (電流の流れない抵抗)。1/f 雑音と電流雑音は入っていない。仮定で、実測の値ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の雑音密度 100 Hz・1 kHz | 4.06 µV/√Hz | 4.01・4.04 µV/√Hz | 合う |
| 出力の雑音密度 9.9 kHz | 2.87 µV/√Hz (−3 dB) | 2.87 µV/√Hz | 合う |
| 出力の実効値 (10 Hz〜10 kHz) | 0.36 mV<sub>rms</sub> | 0.359 mV<sub>rms</sub> | 合う |

1 bin の −91.1 dBm と dBm から密度に直す式は、Python で計算して確かめた (LTspice の対象外)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
LM358 の雑音 (1 kHz の代表値と、LM358B の Input Voltage Noise Spectral Density vs Frequency の図) は TI の [LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)。
参考: [熱雑音](https://ja.wikipedia.org/wiki/熱雑音)
