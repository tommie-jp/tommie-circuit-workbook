---
book: denken
chapter: 13
id: 13-2
title: 漏電遮断器の原理 — 往きと帰りの電流の差
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 13-2 漏電遮断器の原理 — 往きと帰りの電流の差

**これは抵抗だけで作った模型で、考え方を確かめるためのもの。** 実際の漏電は商用電源 (100 V 以上) で
起きる危険な現象で、ここでは AD の波形発生器の振幅 1 V だけを使う。

漏電遮断器は、負荷へ往く電線と帰る電線の電流を比べる。漏電が無ければ、往った電流はそのまま帰ってくるので
差は 0。どこかで電流が大地へ漏れると、その分だけ帰りの電流が減り、**差 (零相電流) が漏れた電流**になる。
負荷が大きくても小さくても差は 0 なので、負荷の電流では働かず、漏れにだけ働く。実物は 2 本の電線を
1 つの鉄心 (零相変流器、ZCT) に通して差を磁気で取り出すが、ここでは往きと帰りに 1 本ずつシャント抵抗を入れ、
2 ch の差 (Math) で同じ量を読む。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_go = I_ret + I_leak | 往きの電流は、帰りの電流と大地へ漏れた電流の和 (キルヒホッフの電流則) |
| I_go − I_ret = I_leak | 往きと帰りの差が漏れた電流。漏れが無ければ 0 |
| (V_CH1 − V_CH2) ÷ 10 Ω = I_leak | 2 本のシャント (10 Ω) の電圧の差から漏れた電流を読む |

## 回路図

```circuit
title: 図1 往きと帰りにシャントを入れた漏電の模型
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{W1}$
  Rgo: resistor c1 c4 10 i=Igo
  M1: voltmeter a1 a4 l=$\mathrm{CH1}$
  Rload: resistor c7 f7 220
  Rret: resistor f7 i7 10 i=Iret
  M2: voltmeter f9 i9 l=$\mathrm{CH2}$
  S1: switch c12 e12
  Rleak: resistor e12 g12 1k i=Ileak
  Rg: resistor g12 i12 100
  G1: ground i1
  G2: ground i12
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c7 -- c12
  - f7 -- f9
  - i1 -- i7 -- i9
notes:
  - text b8 blue: 往き
  - text j4 blue: 帰り
  - text j12 blue: 大地
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/13-regulations/circuit/02-earth-leakage-breaker-1.svg)

- W1 は AD の波形発生器。1 kHz、振幅 1 V。Rload (220 Ω) が負荷
- Rgo (10 Ω) が往きの電線、Rret (10 Ω) が帰りの電線に入れたシャント。CH1 は Rgo の両端 (差動入力)、
  CH2 は Rret の両端 (下の端は GND)。読みの 1/10 がそれぞれの電流 (1 mV = 0.1 mA)
- 電源の下の端 (G1) は接地してある (試験の図の B 種接地にあたる)。S1 を閉じると、負荷の往きの側から
  Rleak (1 kΩ、絶縁の悪くなった所) と Rg (100 Ω、大地の抵抗) を通って、**帰りの電線を通らずに**電源の接地へ
  電流が戻る。これが漏電
- G1 と G2 は同じ GND (AD の GND) だが、Rret を通らない道であることが分かるように分けて描いた

## 計器の設定

板は無い。部品はワニ口のケーブルか小さなブレッドボードで図1 のとおりにつなぐ。AD の 1+ と 1− は Rgo の
両端、2+ は Rret の上の端、2− は GND。**1− を GND につながない** (Rgo の下の端が GND に落ちる)。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Offset 0 V。線電流は最大 5.0 mA |
| Scope | CH1 = Rgo の両端 (I_go × 10 Ω)、CH2 = Rret の両端 (I_ret × 10 Ω)。どちらも 20 mV/div (同じ尺度で高さを比べる)。Average を 16 回 |
| Math | M1 = C1 − C2 (= I_leak × 10 Ω)、5 mV/div |
| Measure | CH1・CH2・M1 の Maximum (振幅) |

```scope
title: 図2 S1 を開く (漏電なし) — CH1 と CH2 が重なり、差 (Math) は 0
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 41.67mV, range: 20mV/div}
ch2: {wave: sine 1kHz 41.67mV, range: 20mV/div}
math: {expr: ch1 - ch2, unit: V, range: 5mV/div, position: -2div}
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/13-regulations/scope/02-earth-leakage-breaker-1.svg)

```scope
title: 図3 S1 を閉じる (漏電あり) — CH1 が CH2 より高く、差は 8.64 mV (0.864 mA)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 49.944mV, range: 20mV/div}
ch2: {wave: sine 1kHz 41.307mV, range: 20mV/div}
math: {expr: ch1 - ch2, unit: V, range: 5mV/div, position: -2div}
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/13-regulations/scope/02-earth-leakage-breaker-2.svg)

### オシロスコープと発振器

この題は差動の題で、AD の 1− は往きの電線の途中 (Rgo の負荷側) に当たっている
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。汎用オシロのグランドクリップは大地に
つながっていて、FG の GND も同じ大地につながる。そこにクリップを当てると、**クリップそのものが漏電の道**になり、
往きの電流の大部分が大地へ流れる。この題が測りたいものを、計器が作ってしまう。

Rgo の両端を 2 本の先端で挟んで CH1 − CH2 を取る手もあるが、差は 50 mV で、振れ (1 V) の 5 % しかなく
8 bit の分解能に埋もれる。そこで**往きの電流は測らず、大地へ漏れた電流を Rg で直に測る** (図4)。
Rg の下の端は GND なので、先端 1 本で GND 基準に読める。往きの電流は KCL (I_go = I_ret + I_leak) で出す。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{FG}$
  Rgo: resistor c1 c4 10
  Rload: resistor c7 f7 220
  Rret: resistor f7 i7 10 i=Iret
  M2: voltmeter f9 i9 l=$\mathrm{CH2}$
  S1: switch c12 e12
  Rleak: resistor e12 g12 1k
  Rg: resistor g12 i12 100 i=Ileak
  M1: voltmeter g15 i15 l=$\mathrm{CH1}$
  G1: ground i1
  G2: ground i12
wires:
  - c4 -- c7 -- c12
  - f7 -- f9
  - i1 -- i7 -- i9
  - g12 -- g15
  - i12 -- i15
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/13-regulations/circuit/02-earth-leakage-breaker-2.svg)

- W1 は FG の OUT (Sine、1 kHz、High-Z)。CH2 の先端は Rret の上の端、CH1 の先端は Rg の上の端
  (Rleak と Rg の間)。グランドクリップは 2 本とも GND (電源の接地の側) に当てる。回路の部品は図1 のまま
- I_leak = CH1 ÷ 100 Ω、I_ret = CH2 ÷ 10 Ω、I_go = I_ret + I_leak。Rg の電圧は 86.4 mV (計算値) で、
  図3 の差 (8.64 mV) の 10 倍あり、読みやすい
- 実物の漏電遮断器は大地を通る電流ではなく、ZCT で往きと帰りの差を取る。ここは計器の都合で測る所を
  変えたと心得る
- FG の 50 Ω で FG の出力の電圧が下がる。**FG の出力端 (Rgo の左) の振幅が 1.00 V になるよう FG の振幅を
  上げる**: 先に CH1 の先端を FG の出力端に当てて合わせ、Rg の上へ戻す。設定は S1 を開いて約 1.21 V、閉じて
  約 1.25 V (Vpp の機種なら 2.42 / 2.50 Vpp。計算値)。S1 を切り替えるたびに合わせ直せば、見るべき値の表が
  そのまま使える

## 見るべき値

計算値。W1 の振幅 1 V、Rgo = Rret = 10 Ω、Rload = 220 Ω、Rleak = 1 kΩ、Rg = 100 Ω。電流は振幅。

| 状態 (S1) | I_go (CH1 ÷ 10 Ω) | I_ret (CH2 ÷ 10 Ω) | 差 I_leak (Math ÷ 10 Ω) | Rg の電圧 | 分かること |
| --- | --- | --- | --- | --- | --- |
| 開く (漏電なし) | 4.17 mA | 4.17 mA | 0 | 0 | 往った電流は全部帰ってくる |
| 閉じる (漏電あり) | 4.99 mA | 4.13 mA | 0.864 mA | 86.4 mV | 差が漏れた電流に等しい |

分かること:

- **往きと帰りの差だけが、漏れた電流を表す。** 往きの電流 (4.99 mA) の大きさそのものは、負荷の電流と
  区別が付かない。負荷を増やすと往きも帰りも同じだけ増え、差は 0 のまま
- 漏電すると往きの電流も少し増え (4.17 → 4.99 mA)、帰りは少し減る (4.17 → 4.13 mA)。差の 0.864 mA は
  漏れの道 (Rleak + Rg = 1.1 kΩ) に掛かる電圧 ÷ 1.1 kΩ に等しい
- 実物の漏電遮断器は、この差が定格感度電流 (住宅用なら 30 mA が多い) を超えると回路を切る。
  差は負荷の数十 A に比べてわずかなので、ZCT は往きと帰りを同じ鉄心に通して、打ち消し合った残りだけを取り出す
- 接地 (13-1) は、漏れた電流を人体でなく接地の道へ流す。漏電遮断器は、その漏れを見つけて切る。
  2 つを組み合わせて感電を防ぐ

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
