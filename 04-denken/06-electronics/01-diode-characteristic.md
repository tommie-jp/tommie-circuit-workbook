---
book: denken
chapter: 6
id: 6-1
title: ダイオードの電圧電流特性
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-1 ダイオードの電圧電流特性

ダイオードは電流を一方向にしか通さない部品で、順方向の電圧と電流の関係は
直線ではなく**指数関数**に近い。AD の波形発生器でゆっくりした三角波を加え、
ダイオードの両端の電圧と、直列に入れた抵抗の両端の電圧 (電流の代わり) を
同時に見る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I = I_S (e^(V/(nV_T)) − 1) | ダイオードの電圧電流特性 (V_T ≈ 25.9 mV は熱電圧) |
| I = V_R1 / R1 | 直列抵抗の両端の電圧から電流を求める |
| V = V_src − I × R1 | ダイオードの両端の電圧 (電源電圧から抵抗の分を引く) |

## 回路図

```circuit
title: 図1 ダイオードの電圧電流特性
parts:
  V1: triangle a1 c1 1.5 l=$\mathrm{W1}$
  R1: resistor a1 a5 1k i=I
  D1: diode a5 c5 1N4148
  G1: ground c1
wires:
  - c1 -- c5
style:
  standard: jis
  grid: on
```

- V1 は AD の Wavegen (三角波)。Offset 0.5 V、Amplitude 1.5 V なので、
  −1 V から +2 V までゆっくり動く
- R1 (1 kΩ) は電流を電圧に変えるシャントであり、ダイオードを守る電流制限
  抵抗でもある
- D1 は 1N4148 (小信号シリコンダイオード)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  D1: diode/do35 c15(A) c17(K)
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2+, 2-, 1+, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 yellow [h10]
  - AD.2- -- a10 green
  - b10 -- b15 green
  - AD.1+ -- a15 green
  - a17 -- -t17 black
  - AD.1- -- -t19 black
```

- CH1 (1+/1−) はダイオードの両端 (a15 と GND)。CH2 は R1 の両端の差動
  (2+ が b5、2− が a10) で、電流の代わりになる
- ダイオードは**足の長いほうがアノード (A)**。抵抗の側 (15 列) に挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Triangle、100 Hz、Amplitude 1.5 V、Offset 0.5 V |
| Scope | CH1 = ダイオードの両端、CH2 = R1 の両端 (差動)。XY 表示で CH1 を X、CH2 (÷ 1 kΩ で電流) を Y にすると特性曲線が見える |

XY 表示に出る曲線は、下の表の 5 点を通る (図3)。理想の曲線はダイオードの式を CH2 の行に書き、
1 kΩ × I_S = 4.4 µV、nV_T = 1.9 × 25.9 mV = 49.21 mV とした。XY には時間軸が無いので、CH1 は
ダイオードの両端が動く範囲 (−1.00〜0.62 V) を三角波で往復させている。

```scope
title: 図3 ダイオードの V–I — 0.5 V を越えると電流 (CH2) が急に立ち上がる
view: xy
ch1: {wave: triangle 100Hz 0.8114V offset -0.1886V, range: 250mV/div, position: 0div}
ch2: {wave: = 4.4uV * (exp(ch1 / 49.21mV) - 1), range: 200mV/div, position: -4div}
xy: ch1 ch2
```

CH1 の Vmin (−1.00 V) が逆方向の端、Vmax (0.62 V) が順方向の端。そのときの CH2 の Vmax は
1.38 V で、÷ 1 kΩ で 1.38 mA になる。

### オシロスコープと発振器

AD 版は CH2 を R1 の両端に差動で当てる (2− は 10 列)。10 列はダイオードの
アノードで、GND ではない。汎用オシロのグランドクリップをそこへ当てると、
アノードが GND に落ち、ダイオードが短絡される ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) の落とし穴)。

**回路はそのまま、FG の出力とアノードを GND 基準で測り、Math の CH2 − CH1 で
R1 の両端 (電流) を読む** (図4)。ダイオードの両端 (CH1) は 1 本の先端で直に読める。
この題で大事なのは、電流が変わってもほとんど動かないダイオードの電圧のほうなので、
そちらを引き算にしない。

```circuit
title: 図4 汎用オシロでの測り方
parts:
  V1: triangle a1 d1 1.5 l=$\mathrm{FG}$
  M2: voltmeter a4 d4 l=$\mathrm{CH2}$
  R1: resistor a6 a9 1k i=I
  M1: voltmeter a11 d11 l=$\mathrm{CH1}$
  D1: diode a14 d14 1N4148
  G1: ground d8
wires:
  - a1 -- a4 -- a6
  - a9 -- a11 -- a14
  - d1 -- d4 -- d8 -- d11 -- d14
style:
  standard: jis
  pitch: 1.2
```

- FG は Triangle、100 Hz、**3 Vpp、Offset 0.5 V** (AD の Amplitude 1.5 V は山の高さ)、
  出力は High-Z ([0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))
- CH1 の先端を 15 列 (アノード)、CH2 の先端を 5 列 (FG の出力) に当てる。
  グランドクリップは 2 本とも GND のレール。ブレッドボードの部品は動かさない
- **XY 表示の軸に Math を選べない機種が多い。** 選べる機種なら X = CH1、Y = Math で
  特性曲線が出る。選べなければ、時間軸の表示で CH1 と Math をカーソルで読んで表の
  5 点を拾うか、波形を CSV で保存して表計算で散布図にする
- 立ち上がりの手前 (0.04 mA = Math で 40 mV) は Math の読みが粗い。
  Average を掛け、2 本の先端を同じ点に当てて Math が 0 V 近くになるかを先に見る

**FG の 50 Ω で値が変わる** (計算値)。表の「Wavegen の電圧」を CH2 (FG の端子の電圧)
と読めば、表の行はそのまま使える。ただし FG の端子は電流の分だけ下がり、山は 2.0 V
ではなく 1.93 V、そのときの電流は 1.31 mA (ダイオードの両端 0.62 V) で止まる。

## 見るべき値

計算値 (1N4148 の代表的なモデル、I_S ≈ 4.4 nA、n ≈ 1.9 で計算)。

| Wavegen の電圧 | ダイオードの両端 (CH1) | 電流 (CH2 ÷ 1 kΩ) |
| --- | --- | --- |
| −1.0 V (逆方向) | −1.00 V | ほぼ 0 mA |
| 0.5 V | 0.46 V | 0.04 mA |
| 1.0 V | 0.57 V | 0.43 mA |
| 1.5 V | 0.60 V | 0.90 mA |
| 2.0 V | 0.62 V | 1.38 mA |

分かること:

- **逆方向はほとんど電流が流れない。** −1 V をかけてもダイオードの両端はほぼ
  −1 V のまま (電流が流れないので R1 に電圧降下が無い)
- **順方向は 0.5〜0.6 V あたりから急に電流が増える** (立ち上がり電圧)。
  電流が 1 桁変わってもダイオードの両端の電圧は 0.1 V も変わらない —
  この性質を利用したのがツェナーダイオードの定電圧 (6-6) やトランジスタの
  V_BE (6-2)
- 電流を対数の軸で見ると、立ち上がり以降はほぼ直線になる (指数関数の性質)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
