---
book: denken
chapter: 8
id: 8-6
title: 極性試験 — 減極性と加極性
tier: 100
source: 自作
board: BB
---

# 8-6 極性試験 — 減極性と加極性

変圧器の 1 次と 2 次の端子には「同じ瞬間に同じ向きの電圧が出る組」があり、それを**極性**という。
1 次の端子 U と 2 次の端子 u を 1 本の線でつなぎ、残りの V と v の間の電圧を測ると、
V1 − V2 になるか V1 + V2 になるかで極性が分かる。前者が**減極性**、後者が**加極性**。
8-1〜8-5 と同じ小型トランス (10 kΩ:8 Ω) で、2 次の線を入れ替えて両方を作る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V = V1 − V2 | 減極性。U と u が同じ極性の端子 (同じ瞬間に同じ向き) |
| V = V1 + V2 | 加極性。U と u が逆の極性の端子 |
| V2 = V1 / n | 2 次の電圧 (8-1)。n ≒ 35.4 |

V1 = 2 V (振幅) なら V2 = 2 V ÷ 35.4 = 56.6 mV (2 次は開放なので巻線の降下は無い)。減極性で V = 1.943 V、加極性で V = 2.057 V。
差は 2 × V2 = 113 mV しかないので、AD の Math で V − V1 を作って 2 次の分だけを拡大して見る。
**日本の規格 (JIS・JEC) では、単相変圧器は減極性を標準とする。**

## 回路図

```circuit
title: 図1 U と u をつないで V と v の間を測る
style:
  standard: jis
  pitch: 1.8
parts:
  W1: sine 1,3 1,5 l=$\mathrm{W1}$
  M1: voltmeter 3,3 3,5 l=$\mathrm{CH1}$
  T1: transformer 5,4 10kto8
  M2: voltmeter 8,4.5 8,6 l=$\mathrm{CH2}$
  G1: ground 1,5
  G2: ground 8,6
wires:
  - 1,3 -- 3,3 -- 4,3 -- 4,3.5
  - 4,3.5 -| T1.A1
  - T1.A2 -| 4,4.5
  - 4,4.5 -- 4,5
  - 1,5 -- 3,5 -- 4,5
  - 4,3 -- 4,2 -- 7,2 -- 7,3.5
  - T1.B1 -| 7,3.5
  - T1.B2 -| 7,4.5
  - 7,4.5 -- 8,4.5
notes:
  - text 4.3,3.4 small: U
  - text 4.3,4.6 small: V
  - text 5.8,3.4 small: u
  - text 5.8,4.6 small: v
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/06-polarity-test.svg)

- W1 は AD の波形発生器 (Wavegen)。1 kHz、振幅 2 V。1 次の U に入れ、V を GND にする
- U と u を線でつなぐ。2 次のもう一方の端子 v と V (GND) の間の電圧が、試験の電圧計の読み V
- M1 (CH1) は V1 (U と V の間)、M2 (CH2) は V (v と V の間)。どちらも GND 基準
- どちらの線を u にするかで結果が変わる。まず 2 次の線を 1 通りにつないで測り、次に 2 次の 2 本を入れ替えて測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (U と u を緑の線でつなぐ)
# 上のブロックの 15 列 = U、18 列 = V。下のブロックの 15 列 = u、18 列 = v
board: half
parts:
  T1: transformer c15 c18 f15 f18 10kto8
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1-, W1, 1+, 2+, 2-]
wires:
  - AD.W1 -- a15 yellow
  - AD.GND -- -t5 black
  - a18 -- -t18 black
  - AD.1+ -- b15 orange
  - AD.1- -- -t9 black
  - d15 -- d12 green
  - e12 -- f12 green
  - i12 -- i15 green
  - AD.2+ -- a21 blue
  - e21 -- f21 blue
  - i21 -- i18 blue
  - AD.2- -- -t23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/breadboard/06-polarity-test.svg)

- T1 は 8-1 と同じ挿し方。1 次 (10 kΩ 側) の 2 本を上のブロックの 15 列 (U)・18 列 (V)、2 次 (8 Ω 側) の 2 本を下のブロックの 15 列 (u)・18 列 (v)
- U と u は緑の線 3 本 (15 列 → 12 列 → 溝を渡る → 15 列) でつなぐ。トランスの胴をよけるため 12 列を回る
- CH1 (1+) は U (b15)、CH2 (2+) は 21 列を回って v (i18) へ。1−・2− は青レール (V = GND)
- 2 回目は、下のブロックの 15 列と 18 列に挿した 2 次の 2 本を入れ替える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 2 V |
| Scope | CH1 = V1 (U)。CH2 = V (v)。どちらも 1 V/div |
| Math | M = CH2 − CH1 (2 次の電圧だけが残る)。20 mV/div |
| Measure | CH1・CH2 の Amplitude、Math の Amplitude と CH1 に対する Phase |

CH1 と CH2 は 1 V/div では重なって見分けられない。Math の CH2 − CH1 が、V1 と比べて逆相 (180°) なら減極性、同相 (0°) なら加極性。

```scope
title: 図3 減極性 — V (CH2) は 1.943 V、CH2 − CH1 は V1 と逆相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div, position: 1div}
ch2: {wave: sine 1kHz 1.9434V, range: 1V/div, position: 1div}
math: {expr: ch2 - ch1, unit: V, range: 20mV/div, position: -1div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/06-polarity-test-1.svg)

```scope
title: 図4 加極性 (2 次の線を入れ替えた) — V (CH2) は 2.057 V、CH2 − CH1 は V1 と同相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div, position: 1div}
ch2: {wave: sine 1kHz 2.0566V, range: 1V/div, position: 1div}
math: {expr: ch2 - ch1, unit: V, range: 20mV/div, position: -1div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/06-polarity-test-2.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

GND 基準の題で、測る所は図1 のまま。W1 → FG の OUT (High-Z、Sine、1 kHz、振幅 2 V。Vpp で入れる機種なら 4 Vpp)、
CH1 の先端を U (b15)、CH2 の先端を v (i18)、グランドクリップは 2 本とも青レール (V)。
2 次は U–u の線で 1 次につながっているので、クリップを 2 次に当てる必要は無い (当てると 2 次の巻線を短絡することがある)。

- FG から見た負荷は 2 次が開放の 1 次だけ (約 200 kΩ、8-2) なので、50 Ω は効かない
- 差 (56.6 mV) は 1 V/div の CH1・CH2 では 8 bit の 1 段 (約 40 mV) ほどしか無く、2 本の振幅を読み比べても分からない。
  **Math の CH2 − CH1 を 20 mV/div に上げて見る**。Math の縦の尺度を変えられない機種は、CH1 と CH2 を同じ 500 mV/div・同じ位置にして
  Math を作る (Math は 8 bit の 2 本の差なので粗いが、逆相か同相かは分かる)
- テスターの交流電圧で V を測ってもよい (試験の極性試験はこの形)。V1 の読みより 113 mV (振幅) = 80 mV (実効値) 低ければ減極性、高ければ加極性

## 見るべき値

計算値 (2 次は開放、巻線抵抗の降下は無い)。

| 測る所 | 減極性 | 加極性 | 分かること |
| --- | --- | --- | --- |
| CH1 (V1、振幅) | 2.00 V | 2.00 V | Wavegen の設定どおり |
| CH2 (V、振幅) | 1.94 V (1.943 V) | 2.06 V (2.057 V) | V = V1 − V2 か V1 + V2 か |
| Math CH2 − CH1 (振幅) | 56.6 mV | 56.6 mV | 2 次の電圧 V2 そのもの (2 次開放の値。8-5 の無負荷と同じ) |
| Math の CH1 に対する位相 | 180° | 0° | 逆相なら減極性、同相なら加極性 |

**どちらも V2 の大きさは同じで、向き (位相) だけが違う。** 極性は巻線の巻き方と引き出し方で決まり、
1 台の変圧器では決まった性質。2 台を並べて使う (並行運転、8-8) ときや、三相に組む (8-9) ときに、
極性を取り違えると 2 次どうしが打ち消し合ったり、大きな循環電流が流れたりする。

## 出典

自作。
