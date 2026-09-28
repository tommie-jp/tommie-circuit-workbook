---
book: denken
chapter: 8
id: 8-3
title: 短絡試験 — 銅損とインピーダンス電圧
tier: 50
source: 自作
board: BB
---

# 8-3 短絡試験 — 銅損とインピーダンス電圧

2 次を短絡してから 1 次に少しずつ電圧をかけると、鉄心はほとんど磁化されず、
巻線の抵抗と漏れリアクタンスだけに電流が流れる。定格に近い電流を流すのに要る
1 次電圧を**インピーダンス電圧**、そのときの入力電力を**銅損**と呼ぶ。
8-1・8-2 と同じ小型トランス (10 kΩ:8 Ω) で確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Zeq = R1 + n²R2 + j(X1 + n²X2) | 2 次を 1 次に換算した等価インピーダンス |
| Vsc = I1 × \|Zeq\| | インピーダンス電圧。定格電流 I1 を流すのに要る 1 次電圧 |
| Pcu = I1² × Req | 銅損。巻線抵抗による損失 (Req = R1 + n²R2) |

無負荷試験 (8-2) と違い、短絡試験の電流はほぼ Req と Xeq だけで決まり、
鉄心の励磁は無視できるほど小さい。

## 回路図

```circuit
title: 図1 短絡試験の回路 (2 次を短絡)
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  Rs1: resistor c1 c3 100 i=I1
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  T1: transformer e5 10kto8
  M1: voltmeter a5 a8 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 |- T1.A1
  - a5 |- T1.A1
  - a8 |- T1.A2
  - T1.A2 -| g1
  - T1.B1 -- T1.B2
```

- T1.B1 と T1.B2 を直接つないで 2 次を短絡する
- Rs1 (100 Ω) は 1 次電流 I1 を読むシャント。短絡時のインピーダンス (約 970 Ω) に
  対して 1 割ほどなので、V1 は Rs1 の分を引いて読む
- M1 (CH1) は 1 次巻線の両端 (V1 = インピーダンス電圧)、M2 (CH2) は Rs1 の両端 (I1)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (2 次を短絡)
board: half
parts:
  Rs1: resistor e3 e7 100
  T1: transformer c15 c18 f15 f18 10kto8
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 yellow
  - b7 -- b15 orange
  - a18 -- -t18 black
  - i15 -- i18 green
```

- T1 の 2 次リード (下ブロックの 15 列・18 列) と同じ列の空いた穴 (i15・i18) を
  緑の線 1 本でつなぎ、2 次を短絡する (足の穴そのものには線を挿せないため)
- それ以外の配線は 8-1・8-2 と同じ。Rs1 は 8-3 用に 100 Ω に戻す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 3.2 V (少しずつ上げて I1 が 3 mA 程度になる所まで) |
| Scope | CH1 = 1 次巻線の両端 (Vsc)。CH2 = Rs1 の両端 (差動、I1 = 読み ÷ 100 Ω) |
| Math | M1 = CH1 × (CH2 ÷ 100 Ω) の平均が銅損 Pcu |

**電流の目安**: この実験の Req ≒ 925 Ω、Xeq ≒ 300 Ω (漏れリアクタンス、実測して使う)
なので、I1 を 3 mA (振幅) にすると Vsc は Wavegen 側で約 3.2 V になる。
上げすぎない (AD の Wavegen は 10 mA まで)。

CH2 は CH1 の約 1/10 なので、CH2 だけ 100 mV/div に上げてある。Wavegen の 3.2 V のうち Rs1 に
取られた残りが CH1 に出る。

```scope
title: 図3 I1 の分 (CH2、100 mV/div) は Vsc (CH1、1 V/div) より 18° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2.91V, range: 1V/div}
ch2: {wave: sine 1kHz 300mV phase -18deg, range: 100mV/div}
measure: [vmax, freq, phase]
```

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH2 は Rs1 の両端を差動で挟んでいる。Rs1 の電圧 (300 mV) は FG の出力 (3.2 V) の 1 割に
満たないので、2 本の先端で引くと分解能に埋もれやすい。8-1 と同じく **Rs1 を 1 次巻線の GND 側へ
移し**、CH2 の 1 本で直に読む (図4)。短絡した 2 次にはクリップを当てない
(当てても 1 点だけなら害は無いが、測る物が無い)。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
parts:
  FG: sine c1 g1 l=$\mathrm{FG}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  T1: transformer d7 10kto8
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  Rs1: resistor e6 g6 100 i=I1
  G1: ground g1
wires:
  - c1 -- c3 -- c6 |- T1.A1
  - e6 |- T1.A2
  - e4 -- e6
  - g1 -- g3 -- g4 -- g6
  - T1.B1 -- T1.B2
```

- ブレッドボードは 8-1 と同じ組み替え: Rs1 (e3–e7) を抜いて 3 列と 7 列を線でつなぎ、
  18 列から − レールへの黒い線を Rs1 (100 Ω) に替える。2 次の短絡 (i15–i18) はそのまま
- CH1 の先端を 3 列 (FG の出力)、CH2 の先端を 18 列。グランドクリップはどちらも − レール
- Vsc は Math の **CH1 − CH2** で読む (Rs1 の分が 1 割あるので、CH1 のままでは大きく出る)

**FG の振幅。** 回路全体 (Rs1 + Zeq) は約 1.07 kΩ で、FG の 50 Ω が効き始める。FG は High-Z、Sine、1 kHz。
表示が 3.2 V (Vpp の機種なら 6.4 Vpp) のままだと I1 は 2.87 mA (計算値) に下がる。I1 を 3.00 mA に
するには表示で約 3.35 V (6.7 Vpp、計算値) まで上げる。AD の 10 mA の上限は無いが、CH2 を見ながら少しずつ上げるのは同じ。

**銅損。** CH1 − CH2 と CH2 の掛け算 (Math の入れ子) ができる機種は少ない。代わりに入力全体の
電力から Rs1 の損失を引く。

| 手順 | 計算値 |
| --- | --- |
| Math で CH1 × CH2、Measure の Mean ÷ 100 Ω = 入力の電力 (Rs1 + 変圧器) | 4.61 mW |
| CH2 の RMS ÷ 100 Ω = I1 の実効値、その 2 乗 × 100 Ω = Rs1 の損失 | 0.45 mW |
| 差 = 銅損 Pcu | 4.16 mW (≒ 4.2 mW) |

掛け算の無い機種は、CH1 と CH2 の RMS と、CH1 に対する CH2 の位相 (約 16°、計算値) から
入力の電力を V I cos θ で出す。Vsc と I1 の位相差 (約 18°) は、Math の CH1 − CH2 に対する
CH2 の位相で読む。

## 見るべき値

計算値。R1 ≒ 300 Ω・R2 ≒ 0.5 Ω (巻線抵抗、実測して使う) として計算した。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH2 (Rs1 の両端、振幅) | 300 mV | I1 = 300 mV ÷ 100 Ω = 3.00 mA |
| CH1 (Vsc、振幅) | 約 2.92 V | インピーダンス電圧。定格電圧よりずっと低い |
| Zeq (= Vsc / I1) | 約 972 Ω | Req ≒ 925 Ω、Xeq ≒ 300 Ω の合成 |
| Pcu (= I1,rms² × Req) | 約 4.2 mW | 銅損。8-2 の鉄損 (約 1 µW) よりずっと大きい |
| Vsc と I1 の位相差 | 約 18° | 漏れリアクタンスの分だけ電流が電圧より遅れる |

**短絡試験の電圧は無負荷試験よりずっと低いのに、電流ははるかに大きい流れ方をする。**
これは短絡状態では鉄心の励磁インピーダンス (8-2 で見た数百 kΩ) がほぼ効かず、
巻線の抵抗とリアクタンスだけで電流が決まるため。銅損 (数 mW) が鉄損 (数 µW) より
何桁も大きいのは、通常の運転でも銅損が負荷の 2 乗で増えるのに対し鉄損が
ほぼ一定という、8-4 (効率) の伏線でもある。

## 出典

自作。
