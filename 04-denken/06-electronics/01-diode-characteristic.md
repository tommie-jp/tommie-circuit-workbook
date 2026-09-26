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
