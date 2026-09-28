---
book: denken
chapter: 3
id: 3-10
title: 記号法を測って確かめる — RL と C の並列の合成インピーダンス
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-10 記号法を測って確かめる — RL と C の並列の合成インピーダンス

交流の回路を複素数 (記号法) で解くと、直列は足し算、並列は「積 ÷ 和」と、直流と同じ手順で
合成インピーダンスが出る。ただし答えは**大きさと角度を持つ複素数**になる。R と L の直列に
C を並列にした回路で、記号法の答えを先に出し、AD で大きさ (電圧 ÷ 電流) と角度 (電圧と電流の
位相差) を測って合わせる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Ż1 = R + jωL | R と L の直列。実部が抵抗、虚部がリアクタンス |
| Ż2 = −j / (ωC) = 1 / (jωC) | C のインピーダンス。虚部が負 |
| Ż = Ż1 Ż2 / (Ż1 + Ż2) | 並列の合成は「積 ÷ 和」(直流の並列と同じ形) |
| Ẏ = 1/Ż1 + 1/Ż2 | アドミタンスで解くなら並列は足し算。Ż = 1/Ẏ |
| \|Z\| = V / I、θ = ∠V − ∠I | 測った電圧と電流の振幅の比が大きさ、位相差が角度 |

## 回路図

```circuit
title: 図1 R1 + L1 と C1 の並列 (電流は Rs で読む)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  M1: voltmeter a3 a11 l=$\mathrm{CH1}$
  R1: resistor c4 c6 100 i=I1
  L1: inductor c7 c9 10m
  C1: capacitor e5 e8 1u i=I2
  Rs: resistor e11 g11 100 i=I
  M2: voltmeter e13 g13 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c4
  - a3 -- c3 -- e3 -- e5
  - c6 -- c7
  - c9 -- c11
  - a11 -- c11 -- e11
  - e8 -- e11 -- e13
  - g1 -- g11 -- g13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/10-symbolic-impedance.svg)

- 3 列から 11 列までが測る回路 Ż (R1 + L1 の枝と C1 の枝)。CH1 はその両端 (差動) で V
- Rs (100 Ω) は電流 I を測るシャント。CH2 は Rs の上 (GND 基準) で、CH2 ÷ 100 Ω が I。
  I は V と同じ時刻の波として測れるので、位相差がそのまま Ż の角度になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の段: R1 と L1 の直列。下の段: C1 と Rs (溝を渡る緑の線で 5 列と 14 列へ)
board: half
parts:
  R1: resistor c5 c9 100
  L1: inductor/axial d9 d14 10m
  C1: capacitor/film g5 g14 1u
  Rs: resistor i14 i19 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, "2-", W1, "1+", "1-", "2+"]
wires:
  - AD.GND -- -t2 black
  - AD.2- -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- b14 green [h10]
  - AD.2+ -- a14 blue
  - e5 -- f5 yellow
  - e14 -- f14 green
  - j19 -- -b19 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/10-symbolic-impedance.svg)

- 5 列が W1 (Ż の電源側)、9 列が R1 と L1 のつなぎ目、14 列が Ż の GND 側 (Rs の上)。
  C1 は下の段の g 行で、溝を渡る線 (e5–f5・e14–f14) で 5 列と 14 列につなぐ
- Rs は下の段の 14〜19 列。19 列から下の GND のレールへ黒い線を渡し、28 列の黒い線で上下の
  GND のレールをつなぐ
- CH1 は 1+ を 5 列、1− を 14 列に挿して Ż の両端を差動で読む。**1− を GND につながない**。
  CH2 は 2+ を 14 列、2− を GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V、Offset 0 V |
| Scope | CH1 = Ż の電圧 V (差動)、CH2 = Rs の電圧 (GND 基準)。どちらも 100 mV/div、Average を 16 回 |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

**|Z| = CH1 の振幅 ÷ (CH2 の振幅 ÷ 100 Ω)、θ = −(CH1 に対する CH2 の Phase)。**
電流 I が V より進んで見えれば (Phase が正)、Ż の角度は負で容量性。電流は 2.1 mA で、
この本の目安 10 mA (0-1) に収まる。

```scope
title: 図3 電流 (CH2) は V (CH1) より 13.9° 進む — Ż は容量性
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.290V, range: 100mV/div}
ch2: {wave: sine 1kHz 0.214V phase 13.9deg, range: 100mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/10-symbolic-impedance.svg)

### オシロスコープと発振器

AD の CH1 は Ż の両端を差動で挟む (1− が 14 列)。汎用オシロのグランドクリップは大地につながって
いるので、14 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。Ż の電圧 (0.29 V) は振れ (0.5 V) の
6 割あり 8 bit でも埋もれないので、**回路はそのままで 2 本の先端を当て、V を Math の CH1 − CH2 で引く**。

- W1 は FG の OUT (High-Z)。振幅 0.5 V は、Vpp で入れる機種なら 1 Vpp
- CH1 の先端は 5 列 (FG の出力)、CH2 の先端は 14 列 (Rs の上)。グランドクリップは 2 本とも
  GND のレール。ブレッドボードの部品は図2 のまま動かさない
- |Z| は Math (CH1 − CH2) の振幅 ÷ (CH2 ÷ 100 Ω)
- 角度は、Math と CH2 のゼロ交差の時間差 Δt をカーソルで読み、θ = 360° × 1 kHz × Δt で出す
  (13.9° は 38.6 µs。Math のほうが遅れる)。Math を位相の Measure に使えない機種が多いため
- FG の出力の 50 Ω で電流は 1.77 mA に下がるが (計算値)、|Z| と θ は V と I の比なので変わらない

## 見るべき値

計算値 (R1 = 100 Ω、L1 = 10 mH、C1 = 1 µF、f = 1 kHz、Rs = 100 Ω、W1 の振幅 0.5 V)。

記号法で先に解く:

| 量 | 計算 | 値 |
| --- | --- | --- |
| Ż1 | 100 + j2π × 1000 × 0.01 | 100 + j62.8 Ω |
| Ż2 | −j / (2π × 1000 × 1×10⁻⁶) | −j159 Ω |
| Ż1 Ż2 | (100 + j62.8)(−j159) | 10000 − j15915 Ω² |
| Ż1 + Ż2 | 100 + j(62.8 − 159) | 100 − j96.3 Ω |
| **Ż** | 積 ÷ 和 | **131 − j32.6 Ω = 135 Ω ∠−13.9°** |
| Ẏ (検算) | (100 − j62.8)/13947 + j/159 | 7.17 − j4.50 + j6.28 = 7.17 + j1.78 mS |

測る値:

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (V の振幅) | 0.290 V | |
| CH2 (Rs の電圧の振幅) | 0.214 V | 電流 I = 2.14 mA |
| \|Z\| = CH1 ÷ I | 135 Ω | 記号法の \|Ż\| と同じ |
| CH1 に対する CH2 の Phase | +13.9° | 電流が進む。Ż の角度は −13.9° (容量性) |
| R1 + L1 の枝の電流 I1 (計算だけ) | 2.45 mA、I より 46° 遅れ | |
| C1 の枝の電流 I2 (計算だけ) | 1.82 mA、I より 76° 進み | I1 + I2 = 4.27 mA ではなく、ベクトルの和で 2.14 mA |

分かること:

- **並列の合成を「積 ÷ 和」で出すと、測った大きさと角度が両方とも合う。** 大きさだけの計算
  (√(100² + 62.8²) = 118 Ω と 159 Ω の「並列」= 67.8 Ω) では合わない
- **R1 + L1 は遅れ (誘導性)、C1 は進み (容量性)。並列にすると C1 が勝って、全体は少し容量性になる。**
  C1 を 470 nF にすると Ż = 133 + j28.8 Ω で誘導性に変わる (電流が 12° 遅れる。計算値)
- 枝の電流の大きさを足すと 4.27 mA、実際の電流は 2.14 mA。**交流の電流の和はベクトルの和**で、
  I1 と I2 は向きが逆に近いので打ち消し合う
- 10 mH のコイルの巻線抵抗 r (数 Ω〜数十 Ω) は R1 に足される。テスターで測り、R1 + r で計算し直す

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
