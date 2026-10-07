---
book: analog-discovery
chapter: 9
id: 9-5
title: THD vs 出力
tier: 100
source: 自作 (計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 9-5 THD vs 出力

4-4 では波形発生器自身の歪みを THD で測った。ここでは同じ考え方を 9-2・9-3 の
LM358 増幅回路に当て、**出力振幅を上げていくと THD がどう増えるか**を追う。
9-3 で確かめた出力の振れ幅の限界 (Vcc − 1.5 V 付近) に近づくほど歪みが増える
はずで、9-3 の 1 dB 圧縮点と表裏の関係にある実験。

## 回路図

```circuit
title: 図1 LM358 非反転増幅 (9-2・9-3 と同じ、利得 11 倍)
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/05-thd-vs-output.svg)

9-2・9-3 と全く同じ回路。振幅だけを変えて測る。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (9-2・9-3 と同じ配置)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/05-thd-vs-output.svg)

9-2・9-3 と同じ配置。振幅だけを Wavegen 側で変えていく。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、**1 kHz**、振幅を 10・50・80・95 mV と段階的に上げる |
| Spectrum | Range 0〜10 kHz、窓 Flat-top、CH2 (出力) の THD を測定 (Measurements の THD 表示、4-4 と同じ) |

Spectrum の画面の前に、Scope で出力の形を見ておくとよい。入力 50 mV と 95 mV の
ときの出力を、上側だけ 3.5 V で硬く切る模型で重ねた (同じ 500 mV/div)。

```scope
title: 図3 入力 95 mV (CH2) では上の頭が 3.5 V で切れ、50 mV (CH1) は切れない (模型)
time: 200us/div
trigger: ch1 rising 2.5V
ch1: {wave: sine 1kHz 550mV offset 2.5V, range: 500mV/div, position: -5div}
ch2: {wave: sine 1kHz 1.045V offset 2.5V | clip 0V 3.5V, range: 500mV/div, position: -5div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/05-thd-vs-output.svg)

## 見るべき値

小信号領域と、完全にクリップした極限の 2 つは計算で押さえられる。真ん中は
測って確かめる。

- **小信号領域 (Vin = 10 mV 付近)**: LM358 のデータシートに THD の記載は
  無いが、一般的な汎用オペアンプの開ループの歪みの目安として 0.1% 程度と
  見積もる (**仮定・目安**)。まだ 9-3 の限界 (90.9 mV) よりずっと小さいので、
  この程度で収まるはず
- **完全にクリップした極限 (正弦波が方形波に近づく)**: これは理論値が
  厳密に出せる。正弦波の頭を完全に切って方形波にすると、奇数次高調波だけが
  4V<sub>m</sub>/(nπ) で残り、THD = √(Σ 1/n² , n=3,5,7…) = √(π²/8 − 1) ≒
  **48.3%**。実際にはここまで極端にクリップさせないので、測定値はこれより
  低いはず

| Vin | 見積もり・限界 | 分かること |
| --- | --- | --- |
| 10 mV | 約 0.1% (仮定・目安) | 線形領域、歪みはほとんど無い |
| 50 mV | 小信号の値よりやや大きいはず | 9-3 の限界 (90.9 mV) の半分強、まだ大きくクリップしないはず |
| 80 mV | さらに大きいはず | 90.9 mV に近づき、出力の丸まりが見え始める領域 |
| 95 mV | 大きく増えるはず (絶対値は要測定) | 9-3 の限界を超え、出力が明らかに頭打ちになる |
| (参考) 完全な方形波 | **48.3%** | クリップが振り切れたときの理論上の上限 |

**THD vs 出力のグラフは、低い所でほぼ平ら (歪みが小さいまま) で、ある出力
(9-3 の 1 dB 圧縮点のあたり) から急に立ち上がる**、という形になるはずである。
9-3 で振幅を上げながら利得の下がり方を見たのと、9-5 で THD の増え方を見るのは
**同じ現象 (出力段の非線形化) を 2 つの指標 (利得の圧縮と歪みの増加) で
見ている**という関係にある。

同じ模型 (上側を 3.5 V で硬く切る。切れない所は仮定の 0.1 %) で THD を計算すると
次の形になる。実際の出力段は切れ目が丸いので、立ち上がりはこれより手前から
なだらかに始まる。

```graph
title: 図4 THD は 90.9 mV までほぼ平らで、そこから急に立ち上がる (模型の計算)
x: 入力振幅 mV 0..200
y: THD % log 0.01..100
lines:
  上側を硬く切る模型 %:
    - 10 0.1
    - 30 0.1
    - 50 0.1
    - 70 0.1
    - 80 0.1
    - 90 0.1
    - 91 0.101
    - 92 0.273
    - 93 0.56
    - 95 1.2
    - 97 1.87
    - 100 2.88
    - 105 4.5
    - 110 6.02
    - 120 8.75
    - 140 13.2
    - 160 16.6
    - 180 19.2
    - 200 21.4
notes:
  - mark 50
  - mark 95
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/05-thd-vs-output.svg)

分かること:

- 90.9 mV を越えたとたん THD が急に増える (95 mV で約 1.2 %、110 mV で約 6 %)
- 片側だけ切れる形なので、200 mV でも 48.3 % (両側を切った方形波の上限) には届かない

## 出典

自作。計器の名前と操作は Digilent の
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
完全にクリップした場合の THD は方形波のフーリエ級数から導く一般的な結果。
