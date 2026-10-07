---
book: denken
chapter: 4
id: 4-6
title: 不平衡負荷 — 中性線の電流
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-6 不平衡負荷 — 中性線の電流

4-4 では、平衡な Y 負荷の中性線に電流が流れないことを見た。この題では 3 本の負荷を
わざと不ぞろいにして、中性線の電流 I_N を**大きさと位相まで**測り、3 つの相電流の
ベクトルの和と比べる。2 相目の負荷を 1 kΩ → 2 kΩ → 外す、と変えていく。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| İ_N = İ_a + İ_b + İ_c | 中性線の電流は 3 つの相電流のベクトルの和 (キルヒホッフの電流則) |
| İ_k ≈ V̇_k / R_k | 中性線があれば、各相の負荷には電源の相電圧がほぼそのままかかる |
| İ_N = V/R_a + a² V/R_b + a V/R_c (R_N → 0) | a = 1∠120°。平衡 (R が同じ) なら 1 + a² + a = 0 で İ_N = 0 |
| R_b だけ大きくすると İ_N は 2 相目と逆向き | 足りなくなった 2 相目の電流の分だけ、逆向き (−120° + 180° = +60°) に流れる |

## 回路図

```circuit
title: 図1 三相電源と Y 負荷、中性線に RN
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine 1,3 1,5 l=$\mathrm{W1}$
  G1: ground 1,5
  V2: sine 1,9 1,11 l=$\mathrm{W2}$
  G2: ground 1,11
  R1: resistor 3,3 3,5 10k
  R2: resistor 4,9 4,7 10k
  U1: opamp 8,6 +down TL071
  G3: ground 6,7
  Rf: resistor 7,4 10,4 10k
  M1: voltmeter 12,3 12,5 l=$\mathrm{CH1}$
  G4: ground 12,5
  R3: resistor 16,3 18,3 1k
  R5: resistor 16,6 18,6 1k
  R4: resistor 16,9 18,9 2k
  RN: resistor 20,9 20,11 10 i=IN
  M2: voltmeter 22,9 22,11 l=$\mathrm{CH2}$
  G5: ground 20,11
wires:
  - 1,3 -- 3,3 -- 12,3 -- 16,3
  - 1,9 -- 4,9 -- 14,9
  - 3,5 -- 4,5 -- 7,5
  - 4,5 -- 4,7
  - 7,4 -- 7,5
  - 7,5 |- U1.-
  - 6,7 |- U1.+
  - 10,4 -- 10,6
  - U1.out -- 10,6 -- 14,6
  - 18,3 -- 20,3 -- 20,6 -- 20,9 -- 22,9
  - 14,6 -- 16,6
  - 14,9 -- 16,9
  - 18,6 -- 20,6
  - 18,9 -- 20,9
  - 20,11 -- 22,11
notes:
  - text 9,2: 1 相目
  - text 11,7: 3 相目
  - text 9,8: 2 相目
  - text 20.3,4: N
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/06-unbalanced-load.svg)

- 左が 4-1 の三相電源。R3・R4・R5 が Y 結線の負荷で、2 相目の R4 を 1 kΩ・2 kΩ・外す、と替える
- RN (10 Ω) が中性線のシャント。中性点 N と GND の間に入れ、**CH2 ÷ 10 Ω が I_N**。
  RN の下の端が GND なので、CH2 は GND 基準で読める
- CH1 は 1 相目の相電圧 (GND 基準)。位相の基準にする

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (R4 = 2 kΩ)
# 上のブロック: TL071 の入力側と R1・R2、右に Y 結線と中性線 RN。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  R3: resistor b35 b39 1k
  R4: resistor b42 b46 2k
  R5: resistor b49 b53 1k
  RN: resistor c53 c57 10
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, W1, V+, GND, W2, 1-, 2-, 1+, 2+]
wires:
  - AD.V+ -- +t19 red
  - AD.GND -- -t21 black
  - AD.1- -- -t27 black
  - AD.2- -- -t29 black
  - AD.V- -- a13 purple
  - AD.W1 -- a17 yellow
  - AD.1+ -- a35 yellow
  - AD.W2 -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j42 orange
  - h14 -- h49 blue
  - f35 -- e35 yellow
  - f42 -- e42 orange
  - f49 -- e49 blue
  - d39 -- d46 green
  - a46 -- a53 green
  - a57 -- -t57 black
  - AD.2+ -- a39 pink
notes:
  - text small: 35・42・49 列が 1・2・3 相目。53 列が N で、RN を通って GND のレールへ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/06-unbalanced-load.svg)

- 三相電源の部分は 4-5 と同じ。R3・R4・R5 の右の端 (39・46・53 列) を d 行と a 行の緑の線で束ねて N (53 列) にし、
  RN (c53–c57) と 57 列の黒い線で GND のレールへ
- 1+ は 35 列 (1 相目)、2+ は 39 列 (N。緑の線で 53 列とつながる)。1− と 2− は GND のレール
- 相電流も見るときは、1+ を相の列 (35・42・49)、1− を N (39 列の空いた穴) に挿し替え、
  R の両端を差動で読む (÷ R が相電流)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = 1 相目 (500 mV/div)、CH2 = RN の電圧 (2 mV/div、R4 を外すときは 5 mV/div)。Trigger は CH1、Average を 32 回 |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

CH2 は数 mV と小さいので、CH1 と V/div を分けてある。電流はどの相も 1 mA ほどで、
W1・W2 と TL071 の出力に十分小さい。

```scope
title: 図3 R4 = 2 kΩ — RN (CH2、2 mV/div) に 4.88 mV、1 相目より 60° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 4.88mV phase 60deg, range: 2mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/06-unbalanced-load.svg)

### オシロスコープと発振器

RN の下の端は GND なので、1− と 2− は GND のレールで、測り方は GND 基準のままでよい。
発振器・電源の読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| 1+ / 1− | CH1 の先端を 35 列 (1 相目)、グランドクリップを GND のレール |
| 2+ / 2− | CH2 の先端を 39 列 (N)、グランドクリップを GND のレール |

- RN の両端は 5〜10 mV。CH2 は **×1 のプローブ** で 2 mV/div にし、トリガを CH1 にして Average を掛ける
  (4-4 と同じ。商用周波数のノイズが平均で減る)
- 相電流を差動で読む所 (R の両端) は、汎用オシロでは 2 本の先端を相の列と N に当てて Math の CH1 − CH2 で引く。
  差は 1 V 近くあり、8 bit でも埋もれない
- FG の出力の 50 Ω が 1・2 相目に入るので、相電圧は 5 % 下がり (CH1 は 0.948 V)、R4 = 2 kΩ の RN は
  4.74 mV、R4 を外すと 9.76 mV になる (計算値)。**CH1 ÷ 1 V の割合で比べれば表と同じ**。位相の +60° は変わらない

## 見るべき値

計算値 (相電圧の振幅 1 V、R3 = R5 = 1 kΩ、RN = 10 Ω。オペアンプは理想)。位相は 1 相目 (CH1) に対する値。

| R4 (2 相目) | RN の電圧 (CH2) | I_N = CH2 ÷ 10 Ω | I_N の位相 | RN = 0 のときの I_N |
| --- | --- | --- | --- | --- |
| 1 kΩ (平衡) | 0 V | 0 mA | — | 0 mA |
| 2 kΩ | 4.88 mV | 0.488 mA | +60° | 0.500 mA |
| 外す | 9.80 mV | 0.980 mA | +60° | 1.000 mA |

R4 = 2 kΩ のときの相電流 (R の両端 ÷ R):

| 相 | 振幅 | 位相 |
| --- | --- | --- |
| 1 相目 (R3) | 0.998 mA | −0.2° |
| 2 相目 (R4) | 0.502 mA | −120° |
| 3 相目 (R5) | 0.998 mA | +120.2° |
| ベクトルの和 | 0.488 mA | +60° (I_N と同じ) |

分かること:

- **不平衡になると、中性線に「足りない分」の電流が流れる。** 2 相目の電流が 1 mA → 0.5 mA に減ると、
  平衡からの差 0.5 mA が 2 相目と逆向き (+60°) に中性線を流れる。2 相目を外すと 1 mA
- 相電流の大きさを足すと 2.5 mA だが、中性線の電流は 0.49 mA。**電流の和はベクトルの和**
- RN (10 Ω) があるぶん N が 5〜10 mV 浮き、I_N は RN = 0 のときより 2 % 小さい。中性線の抵抗が
  大きいほど N が動き、中性線を外すと大きく動く (4-14)
- 家庭の単相 3 線式や、電灯と動力を混ぜた配電で中性線を細くできないのはこのため

## AD3 を 2 台使う — 3 つの相電流と中性線の電流を同時に

AD3 を 2 台使うと、オシロの入力が 4 ch になる。2 台の配線・GND の共通化・T2 での同期は
[4-1 の「AD3 を 2 台使う」](01-three-phase-source.md) と同じ。W1・W2 と Supplies は AD-A だけが出し、
AD-B は測るだけ (Wavegen も Supplies も使わない)。
不平衡の題の要点は「3 つの相電流のベクトルの和が中性線の電流」なので、4 つを 1 回で見られる。

| 台 | CH1 | CH2 |
| --- | --- | --- |
| AD-A | R3 の両端 (差動、1 相目の電流) | RN の両端 (差動、中性線の電流) |
| AD-B | R4 の両端 (差動、2 相目の電流) | R5 の両端 (差動、3 相目の電流) |

計算値 (R4 = 2 kΩ、R3 = R5 = 1 kΩ、RN = 10 Ω)。

| 測る所 | 期待する値 |
| --- | --- |
| R3 の両端の振幅 (相電流 0.998 mA) | 0.998 V |
| R4 の両端の振幅 (相電流 0.502 mA) | 1.004 V |
| R5 の両端の振幅 (相電流 0.998 mA) | 0.998 V |
| RN の両端の振幅 (中性線 0.488 mA) | 4.88 mV |
| AD-A の CH1 に対する CH2 (RN) の位相 | +60° |

- R3・R4・R5 の両端の電圧の**大きさ**は、電流の 1 kΩ / 2 kΩ 倍なので、ほぼ同じ 1 V に見える。
  電流に直すときは、それぞれの抵抗で割る
- 2 台の画面の値をそろえるには、4-1 の T2 の同期を使う (AD-A と AD-B の位相を比べるときだけ必要)
- 実機では確かめていない (計算値)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
