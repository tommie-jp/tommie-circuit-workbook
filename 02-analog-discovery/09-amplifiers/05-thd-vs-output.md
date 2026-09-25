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

9-2・9-3 と全く同じ回路。振幅だけを変えて測る。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (9-2・9-3 と同じ配置)
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

9-2・9-3 と同じ配置。振幅だけを Wavegen 側で変えていく。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen | W1: Sine、**1 kHz**、振幅を 10・50・80・95 mV と段階的に上げる |
| Spectrum | Range 0〜10 kHz、窓 Flat-top、CH2 (出力) の THD を測定 (Measurements の THD 表示、4-4 と同じ) |

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

## 出典

自作。計器の名前と操作は Digilent の
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
完全にクリップした場合の THD は方形波のフーリエ級数から導く一般的な結果。
