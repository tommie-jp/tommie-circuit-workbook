---
book: analog-discovery
chapter: 9
id: 9-13
title: CMRR (差動)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-13 CMRR (差動)

差動増幅回路は 2 つの入力の**差** V<sub>2</sub> − V<sub>1</sub> だけを増やし、両方に同じだけ乗った**同相**の電圧は消すのが役目。
どれだけ消せるかが **CMRR** (同相信号除去比) で、差動の利得 A<sub>dm</sub> と同相の利得 A<sub>cm</sub> の比で表す。

CMRR = 20 log<sub>10</sub>(A<sub>dm</sub> / A<sub>cm</sub>) [dB]

回路の教科書の 4-7 の差動増幅 (オペアンプ 1 個と抵抗 4 本) を利得 10 倍で組み、AD3 の **2 ch の Wavegen** で 2 つの試験をする。
差動の試験は V<sub>2</sub> に W1 の正弦波、V<sub>1</sub> に W2 の直流 2.5 V。同相の試験は V<sub>1</sub> も W1 につなぎ替え、
両方の入力を同じ波で揺らす。オペアンプそのものの CMRR (LM358 で代表 80 dB) より、**4 本の抵抗の比の合い方**のほうが
効くことを数で確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 差動増幅 (利得 10 倍)。V2 に W1、V1 に W2 (2.5 V)
parts:
  AD:
    type: device
    at: 1,1
    turn: mirror
    label: Analog Discovery
    pins: [2+, V+, 1+, W1, 2-, 1-, W2, GND]
  R3: resistor 7,5 8.5,5 10k
  R4a: resistor 9.5,2.5 9.5,5 200k
  R4b: resistor 9.5,5 9.5,6.5 200k
  G1: ground 9.5,6.5
  R1: resistor 7,8 9,8 10k
  R2: resistor 11,8 14,8 100k
  U1A: opamp 12,5.35 +up LM358
  G2: ground 4,10
wires:
  - AD.2+ -| 16,8
  - AD.V+ -| 9.5,2.5
  - AD.1+ -| 6.5,5
  - AD.W1 -| 6,5
  - 6,5 -- 6.5,5
  - 6.5,5 -- 7,5
  - AD.2- -| 5.5,8
  - AD.1- -| 5,8
  - AD.W2 -| 4.5,8
  - 4.5,8 -- 5,8
  - 5,8 -- 5.5,8
  - 5.5,8 -- 7,8
  - 8.5,5 -- 9.5,5
  - 9.5,5 -| U1A.+
  - 9,8 -- 11,8
  - U1A.- -| 11,8
  - U1A.out -| 15,8
  - 15,8 -- 14,8
  - 16,8 -- 15,8
  - AD.GND -| 4,10
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/13-cmrr.svg)

- R1 = R3 = 10 kΩ (オーム)、R2 = 100 kΩ、R4 = R4a ∥ R4b = 200 kΩ ∥ 200 kΩ = 100 kΩ。利得 A<sub>dm</sub> = R2 / R1 = 10 倍
- R4 を 2 本に分け、V+ (5 V) と GND の間に入れたのは、単電源で出力の中心を 2.5 V にするため。テブナンの等価回路で見ると
  「2.5 V の電源に 100 kΩ」で、R2 の相手 (R2 = R4) の条件を崩さない。2.5 V を別の分圧から 1 本の抵抗で入れると、分圧の抵抗が R4 に足されて比が狂う
- 図は差動の試験の配線。V<sub>2</sub> (R3 の左) に W1 と 1+、V<sub>1</sub> (R1 の左) に W2 と 1−・2−。CH1 = W1 − W2、CH2 = 出力 − W2 で、
  どちらも 2.5 V の直流が引かれて揺れだけが残る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (差動の試験の配線)
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  R3: resistor c5 c11 10k
  R4a: resistor a11 +t11 200k
  R4b: resistor d11 g11 200k cap=left
  R2: resistor h17 h20 100k
  R1: resistor i20 i23 10k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [1+, W1, 2+, W2, 1-, 2-, V+, GND]
wires:
  - AD.V+ -- +t27 red
  - AD.GND -- -t28 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.2+ -- a17 gray
  - AD.W2 -- f24 blue
  - AD.1- -- g24 white
  - AD.2- -- h24 purple
  - b11 -- b13 green
  - j11 -- -b11 black
  - a12 -- -t12 black
  - b15 -- b17 gray
  - c14 -- c20 brown
  - e17 -- f17 gray
  - e20 -- f20 brown
  - j12 -- -b12 black
  - g13 -- g14 green
  - j15 -- +b15 red
  - +t29 -- +b29 red
  - -t30 -- -b30 black
  - j23 -- j24 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/13-cmrr.svg)

- U1 の置き方と 2 回路目の始末は 9-2 と同じ。8=V+ は下の + レール (29 列で上と渡す)
- 非反転入力 (+) の節点は 11 列: R3 (c5〜c11)・R4a (a11 から上の + レール)・R4b (d11〜g11、下の 11 列は − レールへ) が集まり、
  緑の線 (`b11 -- b13`) で 3=IN1+ へ
- R2 (h17〜h20) と R1 (i20〜i23) は 9-2 の Rf・Rg と同じ並び。2=IN1− は茶の線 (`c14 -- c20`・`e20 -- f20`) で 20 列へ
- **V<sub>1</sub> の端は 23 列**。差動の試験は緑の短い線 (`j23 -- j24`) で W2 の 24 列へつなぐ。**同相の試験はこの線を外し、23 列と 5 列 (W1) を線で結ぶ**。
  W2・1−・2− は 24 列に残す (CH1・CH2 の基準の 2.5 V)
- 抵抗 4 本 (R1・R2・R3・R4a・R4b) は金属皮膜の ±1 % にする。炭素皮膜の ±5 % では、最悪で 35 dB しか取れない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen (差動の試験) | W1: Sine、1 kHz、Offset 2.5 V、Amplitude 50 mV。W2: DC 2.5 V |
| Wavegen (同相の試験) | W1: Sine、1 kHz、Offset 2.5 V、Amplitude 0.8 V。W2: DC 2.5 V |
| Scope | 差動は CH1・CH2 とも 200 mV/div。同相は CH1 200 mV/div、CH2 2 mV/div、平均 16 回 (目安) |
| Network | 掃引 100 Hz〜100 kHz、Offset 2.5 V、Reference = CH1、DUT = CH2。差動は振幅 50 mV、同相は 0.8 V で 1 回ずつ |

同相の振幅を 0.8 V にしたのは、非反転入力が 2.5 V ± 0.73 V (1.8〜3.2 V) となり、LM358 の同相入力範囲 (V+ − 1.5 V = 3.5 V まで) に収まるため。
差動の試験の出力は 2.5 V ± 0.5 V で、出力の上限 (3.5 V) の内側。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 同相の試験。0.8 V の同相 (CH1) が出力に 7.3 mV (CH2) 漏れる (R2 が 1 % 低い計算)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.8V, range: 200mV/div}
ch2: {wave: sine 1kHz 7.27mV, range: 2mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/13-cmrr.svg)

図3 は R2 だけが 1 % 低い (99 kΩ) と置いた同相の試験の計算値。A<sub>cm</sub> = (100 / 110) × (1 + 9.9) − 9.9 = 0.00909 で、
0.8 V の同相から 7.27 mV が出る。差動の試験では同じ回路の A<sub>dm</sub> が 9.91 倍なので、CMRR = 20 log<sub>10</sub>(9.91 / 0.00909) = 60.7 dB。
CH1 と CH2 の尺度は 100 倍違う (Vpp で読む)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ | LM358 (2 回路目はフォロワ) |
| R1, R3 | 金属皮膜抵抗 (±1 %) | 10 kΩ |
| R2 | 金属皮膜抵抗 (±1 %) | 100 kΩ |
| R4a, R4b | 金属皮膜抵抗 (±1 %) | 200 kΩ (並べて R4 = 100 kΩ、2.5 V のバイアスも兼ねる) |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

計算値。オペアンプの CMRR は LM358 の資料の代表 80 dB (最小 65 dB)。周波数の図 (CMRR vs Frequency) では
約 5 kHz まで 90 dB ほどで、そこから 20 dB/dec で下がる (目安)。

| 抵抗の合い方 | A<sub>cm</sub> | 抵抗だけの CMRR | 分かること |
| --- | --- | --- | --- |
| R2 だけ 1 % 低い (99 kΩ) | 0.00909 | 60.7 dB | 1 本の 1 % で 60 dB 台 |
| 4 本とも ±1 % で最悪の向き | 0.0357 | 48.8 dB | 目安の式 (1 + G) / (4ε) = 11 / 0.04 と同じ (ε (イプシロン) は許容差 0.01) |
| 4 本とも ±5 % で最悪の向き | 0.166 | 34.8 dB | 炭素皮膜のままでは差動増幅にならない |
| 4 本とも ±0.1 % で最悪の向き | 0.00363 | 68.8 dB | ここまで揃えてもオペアンプの 80〜90 dB にはまだ届かない |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 CMRR は合わせの悪い抵抗で決まり、高い周波数ではオペアンプで下がる (計算・目安)
x: 周波数 Hz log 100..100k
y: CMRR dB 30..100
lines:
  オペアンプだけ dB: 90 - 10*log10(1+(x/3k)^2)
  R2 が 1 % 低い dB: -20*log10(10^(-60.7/20) + 10^(-(90 - 10*log10(1+(x/3k)^2))/20))
  4 本とも 1 % の最悪 dB: -20*log10(10^(-48.8/20) + 10^(-(90 - 10*log10(1+(x/3k)^2))/20))
notes:
  - mark 1k
  - mark 30k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/13-cmrr.svg)

- 1 kHz では抵抗の合い方が CMRR を決める。オペアンプだけの線 (90 dB) は、抵抗を完全に揃えたときの上限
- 30 kHz より上ではオペアンプの CMRR が下がり、合わせた抵抗の効き目も薄れる。差動の利得も GBW で下がる
  (雑音利得 11 倍で 90.9 kHz から) ので、高い周波数では A<sub>dm</sub> も測り直して割る
- Network の読みは同相の試験で A<sub>cm</sub> (dB)、差動の試験で A<sub>dm</sub> (dB)。**CMRR = A<sub>dm</sub> の読み − A<sub>cm</sub> の読み**。
  R2 を 100 kΩ と 1 kΩ の直列などにして比を詰めると CMRR が上がるのを、同じ 2 回の測りで確かめられる

## LTspice での確かめ

`sim/13-cmrr.cir` で図1 を交流で解き、R2 を 100 kΩ と 99 kΩ、V<sub>1</sub> を 2.5 V (差動の試験) と W1 (同相の試験) に替えて 4 回走らせた。
オペアンプは 9-2 と同じ汎用模型で、**この模型のオペアンプの CMRR は無限大** (抵抗の分だけを確かめた)。実測の値ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 差動の利得 (R2 100 kΩ・99 kΩ) | 10.0・9.91 倍 | 10.00・9.91 倍 | 合う |
| 同相の利得 (R2 100 kΩ) | 0 (抵抗が揃えば) | 0 | 合う |
| 同相の利得 (R2 99 kΩ) | 0.00909 | 0.00909 | 合う |
| CMRR (R2 99 kΩ) | 60.7 dB | 60.7 dB | 合う |

4 本の最悪の組と ±5 %・±0.1 % の行は、同じ式を Python で計算して確かめた (LTspice は回していない)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
LM358 の CMRR (表の代表値と、CMRR vs Frequency の図) は TI の [LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)。
参考: [同相信号除去比](https://ja.wikipedia.org/wiki/同相信号除去比)
