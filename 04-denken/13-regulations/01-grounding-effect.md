---
book: denken
chapter: 13
id: 13-1
title: 接地の効果 — 漏電した機器に触れたときの電圧 (抵抗の模型、5 V)
tier: 50
source: 自作
board: BB
---

# 13-1 接地の効果 — 漏電した機器に触れたときの電圧 (抵抗の模型、5 V)

**これは抵抗だけで作った模型で、考え方を確かめるためのもの。** 実際の漏電は
商用電源 (100 V 以上) で起きる危険な現象で、この実験のように手で触れられる
ものではない。ここでは安全な 5 V のもとで、絶縁不良の抵抗・人体の抵抗・接地の
抵抗を模した 3 つの抵抗だけを使い、「接地があると触れたときの電圧が下がる」
という関係だけを数字で確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vbody = V × Rbody / (Rleak + Rbody) | 接地が無いとき、人体に掛かる電圧 (単純な分圧) |
| Rpar = Rbody・Rground / (Rbody + Rground) | 接地があるとき、人体と接地抵抗の並列合成 |
| Vbody' = V × Rpar / (Rleak + Rpar) | 接地があるときの人体電圧。Rpar は Rbody よりずっと小さいので Vbody' は小さくなる |

## 回路図

```circuit
title: 図1 漏電の模型 (S1 で接地の有無を切り替える)
style:
  standard: jis
parts:
  V1: vsource c1 g1 5
  Rleak: resistor c1 c3 1k i=Ileak
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  Rbody: resistor c3 g3 1k
  S1: switch c5 e5
  Rground: resistor e5 g5 100
  M1: voltmeter a7 a9 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- c5
  - g3 -- g5
  - g1 -- g3
  - a7 |- c3
  - a9 |- g3
```

- Rleak (1 kΩ) が絶縁不良を模した「漏れ」の抵抗。Rbody (1 kΩ) が人体の抵抗
  (電気設備の安全計算でよく使う目安値)。Rground (100 Ω) が接地極の抵抗
  (D 種接地工事の上限 100 Ω を模した値)
- S1 を開くと「接地していない機器」、閉じると「接地した機器」になる
- CH1 (M1) が人体に掛かる電圧 (Rbody の両端)、CH2 (M2) が Rleak の両端

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rleak: resistor e3 e7 1000
  Rbody: resistor c15 c19 1000
  S1: switch e15 e20
  Rground: resistor b20 b24 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- a3 red
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 red
  - b7 -- b15 orange
  - a19 -- -t19 black
  - a24 -- -t24 black
```

- Rleak (3〜7 列)、Rbody (15〜19 列) が直列。7 列 (人体側の節点) は橙の線で
  15 列へ、3 列 (V+) は赤の線で 11 列へ延ばし、AD の足の並びどおりに左から挿す
- S1 + Rground (15〜24 列) は 15 列 (人体側の節点) から分かれて 24 列から
  GND (青レール) へ戻る、Rbody と並列の枝。S1 を挿すと接地ありになる
- CH1 (1+/1−) が Rbody の両端 (人体電圧)、CH2 (2+/2−) が Rleak の両端

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | AD の Supplies (V+) を 5 V に設定 |
| Scope | CH1 = Rbody の両端 (Vbody)。CH2 = Rleak の両端 (Ileak = 読み ÷ 1 kΩ) |

### オシロスコープと発振器

AD の Supplies (V+) は安定化電源の 5 V に替え、電流制限は 10 mA にする (この回路は最大 4.6 mA)
([回路の本の 0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 は GND 基準で、
先端を 7 列 (人体側の節点)、グランドクリップを青レールに当てる。

この題はそれ自体が接地の実験なので、**汎用オシロのグランドクリップも「接地線」になる**ことに気を付ける
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。クリップは大地につながっていて、
当てた点をそのまま大地に落とす。

- 青レール (電源の −) に当てるのは差し支えない。模型の「大地」は回路の GND で、Rground もそこへ戻る。
  クリップはその GND を本物の大地に結ぶだけで、回路は変わらない
- AD の 2− を当てていた 15 列 (人体側の節点) に当てると、クリップが**接地抵抗 0 Ω の接地線**になる。
  Rbody と Rground の両方が短絡され、S1 を開いても閉じても Vbody = 0 V。電源から Rleak に 5 mA が
  流れ続け、接地の効果を測るつもりが、オシロの接地を測ることになる
- プローブの先端の入力抵抗 (×1 で 1 MΩ、×10 で 10 MΩ) も Rbody に並列の「接地」だが、1 kΩ の
  1000 倍以上で、効きは 0.1 % 以下

そこで CH2 は Rleak の両端でなく、**電源の + (11 列) に先端を当て、Rleak の電圧を CH2 − CH1 で引く**
(図3)。Rleak の電圧 (2.50 V / 4.58 V) は 5 V の半分以上あり、8 bit でも埋もれない。

```circuit
title: 図3 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: vsource c1 g1 5
  M2: voltmeter c4 g4 l=$\mathrm{CH2}$
  Rleak: resistor c4 c7 1k i=Ileak
  Rbody: resistor c7 g7 1k
  M1: voltmeter c9 g9 l=$\mathrm{CH1}$
  S1: switch c11 e11
  Rground: resistor e11 g11 100
  G1: ground g1
wires:
  - c1 -- c4
  - c7 -- c9 -- c11
  - g1 -- g4 -- g7 -- g9 -- g11
```

- CH1 の先端は 7 列、CH2 の先端は 11 列 (電源の +)、グランドクリップは 2 本とも青レール。
  ブレッドボードの部品は図2 のまま動かさない
- Ileak は Math の (CH2 − CH1) ÷ 1 kΩ。直流なので Measure の Mean で読み、Math に Measure を当てられない
  機種は CH2 と CH1 の Mean の差でよい。接地ありの Vbody (0.417 V) は CH1 を 0.1 V/div に絞り、
  Offset で 0 V を下へ寄せて読む

## 見るべき値

計算値。Rleak = Rbody = 1 kΩ、Rground = 100 Ω とした。

| 状態 (S1) | Vbody | 人体を流れる電流 (Vbody÷1kΩ) | 分かること |
| --- | --- | --- | --- |
| 開く (接地なし) | 2.50 V | 2.50 mA | 漏電電圧の半分が丸ごと人体に掛かる |
| 閉じる (接地あり) | 0.417 V | 0.417 mA | 電圧も電流も 1/6 に下がる |

**接地があると、漏れた電流のほとんどが接地極 (低い抵抗) を通って逃げ、
人体を通る分はわずかになる。** この模型では Rground が Rbody よりずっと
小さい (100 Ω に対して 1 kΩ) ため、並列合成 Rpar ≒ 90.9 Ω となり、
人体電圧が大きく下がる。実際の 100 V 以上の回路でも同じ比の関係が働き、
これが接地工事 (D 種など) が感電を防ぐしくみである。

## 出典

自作。
