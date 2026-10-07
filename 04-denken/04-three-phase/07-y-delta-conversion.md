---
book: denken
chapter: 4
id: 4-7
title: 負荷の Y-Δ 変換 — 同じ線電流になる抵抗
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-7 負荷の Y-Δ 変換 — 同じ線電流になる抵抗

Δ 結線の負荷は、端子から見て同じ働きをする Y 結線に置き換えられる (Y-Δ 変換)。平衡なら
**Δ の 1 辺の抵抗 = Y の 1 本の 3 倍**。1-10 の直流の Y-Δ 変換の交流・三相版だ。
4-1 の三相電源に線のシャントを入れ、Y (1 kΩ × 3) と Δ (3 kΩ × 3) を付け替えて、
線電流が大きさも位相も同じになることを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R_Δ = 3 R_Y (平衡) | Δ の 1 辺は Y の 1 本の 3 倍 |
| R_a = R_ab R_ca / (R_ab + R_bc + R_ca) | Δ → Y (一般形)。平衡なら R_Δ / 3 |
| I = V_p / (R_L + R_Y) | Y に置き換えれば、1 相ぶんの直列回路で線電流が出る |
| I_Δ = I / √3 | Δ の 1 辺の電流 (相電流) は線電流の 1/√3 (4-3) |

## 回路図

```circuit
title: 図1 線のシャントと Y 負荷 (1 kΩ)
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
  RLa: resistor 13,3 15,3 330 l=$\mathrm{R_{La}}$
  M1: voltmeter 13,1 15,1 l=$\mathrm{CH1}$
  M2: voltmeter 17,3 17,5 l=$\mathrm{CH2}$
  G4: ground 17,5
  YA: resistor 19,3 21,3 1k l=$\mathrm{R_{Ya}}$
  RLc: resistor 13,6 15,6 330 l=$\mathrm{R_{Lc}}$
  YC: resistor 19,6 21,6 1k l=$\mathrm{R_{Yc}}$
  RLb: resistor 13,9 15,9 330 l=$\mathrm{R_{Lb}}$
  YB: resistor 19,9 21,9 1k l=$\mathrm{R_{Yb}}$
wires:
  - 1,3 -- 3,3 -- 13,3
  - 1,9 -- 4,9 -- 13,9
  - 3,5 -- 4,5 -- 7,5
  - 4,5 -- 4,7
  - 7,4 -- 7,5
  - 7,5 |- U1.-
  - 6,7 |- U1.+
  - 10,4 -- 10,6
  - U1.out -- 10,6 -- 13,6
  - 13,1 -- 13,3
  - 15,1 -- 15,3
  - 15,3 -- 17,3 -- 19,3
  - 15,6 -- 19,6
  - 15,9 -- 19,9
  - 21,3 -- 23,3 -- 23,6 -- 23,9
  - 21,6 -- 23,6
  - 21,9 -- 23,9
notes:
  - text 9,2: 1 相目
  - text 11,7: 3 相目
  - text 9,8: 2 相目
  - text 23.3,4: N
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/07-y-delta-conversion-1.svg)

```circuit
title: 図2 デルタ結線の負荷 (図1 の Y と入れ替える)
style:
  standard: jis
  pitch: 1.2
parts:
  PA: port 1,3
  PC: port 1,6
  PB: port 1,9
  RLa: resistor 3,3 5,3 330 l=$\mathrm{R_{La}}$
  RLc: resistor 3,6 5,6 330 l=$\mathrm{R_{Lc}}$
  RLb: resistor 3,9 5,9 330 l=$\mathrm{R_{Lb}}$
  DCA: resistor 9,3 9,6 3k l=$\mathrm{R_{ca}}$
  DBC: resistor 9,6 9,9 3k l=$\mathrm{R_{bc}}$
  DAB: resistor 12,3 12,9 3k l=$\mathrm{R_{ab}}$
wires:
  - 1,3 -- 3,3
  - 1,6 -- 3,6
  - 1,9 -- 3,9
  - 5,3 -- 9,3 -- 12,3
  - 5,6 -- 9,6
  - 5,9 -- 9,9 -- 12,9
notes:
  - text 1,2: 1 相目
  - text 1,5: 3 相目
  - text 1,8: 2 相目
  - text 9,2: a
  - text 9.3,6: c
  - text 9,10: b
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/07-y-delta-conversion-2.svg)

- 図1 の左は 4-1 の三相電源 (図2 の PA・PB・PC は図1 の 1・2・3 相目の線)。R_La・R_Lb・R_Lc (各 330 Ω) は線のシャントで、送電線の抵抗の役もする
- 図1 は Y (各 1 kΩ)。N はどこにもつながない。図2 は同じ 3 つの端子 a・b・c に Δ (各 3.0 kΩ) をつなぐ
- CH1 は R_La の両端 (差動、÷ 330 Ω が線電流)。CH2 は端子 a の電圧 (GND 基準)

## 実体配線図

```breadboard
title: 図3 ブレッドボードと Analog Discovery (Y 負荷)
# 上のブロック: TL071 の入力側と R1・R2、右に線のシャントと Y 負荷。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  RLa: resistor d35 d38 330
  YA: resistor b38 b41 1k
  RLb: resistor d42 d45 330
  YB: resistor b45 b48 1k
  RLc: resistor d49 d52 330
  YC: resistor b52 b55 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, W1, V+, GND, W2, 2-, 1+, 2+, 1-]
wires:
  - AD.V+ -- +t19 red
  - AD.GND -- -t21 black
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
  - a41 -- a48 green
  - c48 -- c55 green [v-15, h140]
  - c37 -- c38 green
  - AD.2+ -- a37 pink
  - AD.1- -- a38 green
notes:
  - text small: 38・45・52 列が負荷の端子 a・b・c。41・48・55 列を束ねた緑の線が N (浮かせたまま)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/07-y-delta-conversion.svg)

- 三相電源の部分は 4-5 と同じ。35・42・49 列から d 行のシャント (330 Ω) を通って、38・45・52 列が負荷の端子 a・b・c
- Y: b 行の 1 kΩ の右の端 (41・48・55 列) を a 行と c 行の緑の線で束ねて N にする。N は GND につながない
- **Δ に替える**: 1 kΩ の 3 本と N の緑の線を外し、3.0 kΩ を b38–b45 (R_ab) と c45–c52 (R_bc) に挿す。
  R_ca (a と c の間) は e38–f38・e52–f52 の短い線で溝を渡して、下の段の i38–i52 に挿す
- CH1 は 1+ を 35 列、1− を 38 列 (R_La の両端)。**1− を GND につながない**。CH2 は 2+ を 37 列 (c37–c38 の線で 38 列とつながる)、
  2− を GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = R_La の両端 (差動)、CH2 = 端子 a (GND 基準)。どちらも 200 mV/div、Average を 16 回 |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

Y と Δ で同じ画面になる。線電流は 0.75 mA で、W1・W2 と TL071 の出力に十分小さい。

```scope
title: 図4 Y でも Δ でも同じ — R_La (CH1) 0.248 V、端子 a (CH2) 0.752 V、同相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.248V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.752V, range: 200mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/07-y-delta-conversion.svg)

### オシロスコープと発振器

発振器・電源の読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。AD の CH1 は R_La の両端を差動で挟む
(1− が 38 列)。汎用オシロのグランドクリップは大地につながっているので、38 列には当てられない。
R_La の両端 (0.248 V) は 1 相目の振れ (1 V) の 25 % あり 8 bit でも読めるので、
**回路はそのままで CH1 の先端を 35 列、CH2 の先端を 38 列に当て、Math の CH1 − CH2 で R_La の電圧を引く**。
シャントを GND 側へ移すことはできない (線電流 a は b・c の線を通って戻り、a だけが流れる GND の線が無い)。

- グランドクリップは 2 本とも GND のレール。CH2 はそのまま端子 a の電圧
- 測る前に 2 本の先端を同じ点に当て、Math が 0 V 近くになるかを見る (ch どうしの利得の差が誤差になる)
- FG の出力の 50 Ω で、どの電圧も 4 % 下がる (Y でも Δ でも同じ割合。計算値)。3 相目は下がった 1・2 相目から
  作られるので平衡のまま。Y と Δ の比べ方は変わらない。表と同じ値にするなら、35 列の振幅が 1.00 V になるまで
  FG の振幅を上げる

## 見るべき値

計算値 (相電圧の振幅 1 V、R_L = 330 Ω、オペアンプは理想)。

| 負荷 | 線電流の振幅 (CH1 ÷ 330 Ω) | CH1 | CH2 (端子 a) | CH1 に対する CH2 の位相 |
| --- | --- | --- | --- | --- |
| Y (各 1 kΩ) | 0.752 mA | 0.248 V | 0.752 V | 0° |
| Δ (各 3.0 kΩ) | 0.752 mA | 0.248 V | 0.752 V | 0° |
| Δ (各 1 kΩ、変換しないで替えた) | 1.51 mA | 0.498 V | 0.502 V | 0° |

Δ (3.0 kΩ) のとき、1 辺 R_ab の両端は線間の 1.30 V (振幅)、その電流は 0.434 mA = 0.752 mA ÷ √3。

分かること:

- **Δ の 3 kΩ と Y の 1 kΩ は、電源から見て区別がつかない。** 線電流も端子の電圧も同じ
- **Δ の抵抗をそのまま Y の値にすると、線電流は 2 倍になる** (1 kΩ の Δ は 333 Ω の Y と同じ)。
  三相の計算は「Δ は Y に直して 1 相ぶんで解く」が定石
- 線に抵抗 (シャント) があっても変換は成り立つ。変換は負荷の端子から内側だけの話だから

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
