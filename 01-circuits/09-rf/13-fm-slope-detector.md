---
book: circuits
chapter: 9
id: 9-13
title: FM 復調 — スロープ検波
tier: 200
source: 自作
board: BB
era: 古
---

# 9-13 FM 復調 — スロープ検波

FM (周波数変調) の電波は、音の大きさを**周波数のずれ**で運ぶ。振幅は一定なので、
9-2 のゲルマラジオのダイオード検波にそのまま入れても音は出ない。**スロープ検波**は、
同調回路の共振の山を**少しずらして**、搬送波が山の**斜面 (スロープ)** に乗るように
する方式。周波数が上がれば山を登って振幅が増え、下がれば減る。つまり
**周波数の変化が振幅の変化 (FM → AM) に変わり**、あとは 9-2 と同じダイオードの
包絡線検波で音が取り出せる。

FM 放送が始まったころ、AM ラジオの同調をわずかにずらして FM を聞いた、古い時代の
間に合わせの知恵。歪みが大きく、振幅の雑音もそのまま拾うので、のちにフォスター・
シーレー検波や PLL 検波に替わった。ここでは Analog Discovery (AD) の W1 で
FM の信号を作り、本物の電波は使わずに原理だけを確かめる (送信はしないので電波法の
心配はない)。

## 回路図

```circuit
title: 図1 スロープ検波 (W1 の FM を L1・C1 の斜面で AM に変え、D1 で検波)
parts:
  W1: sine 1,1 1,3 l=$\mathrm{W1}$
  GW: ground 1,3
  R1: resistor 3,1 5,1 10k
  L1: inductor 7,1 7,3 100u
  GL: ground 7,3
  C1: capacitor 9,1 9,3 1000p
  GC1: ground 9,3
  M2: voltmeter 12,1 12,3 l=$\mathrm{CH2}$
  GM2: ground 12,3
  D1: diode 14,1 16,1 l=$\mathrm{D1}$
  C2: capacitor 18,1 18,3 2200p
  GC2: ground 18,3
  R2: resistor 20,1 20,3 22k
  GR2: ground 20,3
  M1: voltmeter 23,1 23,3 l=$\mathrm{CH1}$
  GM1: ground 23,3
wires:
  - 1,1 -- 3,1
  - 5,1 -- 7,1
  - 7,1 -- 9,1
  - 9,1 -- 12,1
  - 12,1 -- 14,1
  - 16,1 -- 18,1
  - 18,1 -- 20,1
  - 20,1 -- 23,1
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/13-fm-slope-detector.svg)

図1 では、W1 から R1 を通して、L1・C1 の並列同調回路 (タンク) に FM の信号を入れる。CH2 でタンクの
電圧 (FM → AM に変わった搬送波) を、CH1 で D1・C2・R2 の包絡線検波の出力 (音) を見る。
回路は受け身の部品だけなので電源は要らない。

- **共振周波数**: f<sub>0</sub> = 1/(2π√(100µH × 1000pF)) **≈ 503.3 kHz**
- **Q を決める抵抗**: L1 の損失は、Q<sub>L</sub> を 60 とすると並列の抵抗 Q<sub>L</sub> × ωL = 60 × 316 Ω ≈ 19 kΩ
  (ωL = 2π × 503.3 kHz × 100 µH ≈ 316 Ω)。検波の回路はタンクから見て約 R2/2 = 11 kΩ の負荷になる。
  この 2 つの並列でタンクの抵抗 R<sub>t</sub> ≈ 7.0 kΩ。さらに R1 との並列 4.1 kΩ を
  ωL で割って **Q ≈ 13**、帯域幅 (−3 dB) は f<sub>0</sub>/Q **≈ 38.8 kHz**
- **搬送波は 490 kHz**、共振より **13.3 kHz 下**に置く。単同調の山は、振幅が頂点の
  1/√1.5 ≈ 0.816 倍の所で傾きがいちばん急になり、そのまわりがいちばんまっすぐ
  (歪みが少ない)。490 kHz での比は 1.348/1.642 = 0.82 で、ほぼその点
- **傾き**: W1 が 4 V (peak) のとき、タンクの振幅は 490 kHz で **1.348 V**、1 kHz 上がる
  ごとに **約 33.4 mV** 増える (**33.4 mV/kHz**、計算値)
- **偏移 ±5 kHz** なら、タンクの振幅は 485 kHz で 1.184 V、495 kHz で 1.508 V の間を
  1 kHz で行き来する。差は **0.324 V** — これが検波後の音の振幅 (peak-peak)
- **検波**: D1 (ゲルマニウム 1N60) は順方向電圧が約 0.2 V と小さいので、1 V あまりの搬送波でも
  検波できる。出力の直流は 1.348 − 0.2 ≈ **1.15 V**、その上に **約 0.32 Vpp** の 1 kHz が乗る。
  C2・R2 の時定数は 22 kΩ × 2200 pF ≈ 48 µs で、搬送波の周期 (2 µs) よりずっと長く、
  音の周期 (1 ms) よりずっと短い

共振より**上**の斜面 (約 517 kHz) に置いても復調できるが、そのときは周波数が上がると
振幅が**減る**ので、出てくる音は逆位相になる。

## 実体配線図

```breadboard
title: 図2 スロープ検波 (W1 を R1 へ、CH2 をタンク、CH1 を検波の出力へ)
# 電源は要らない。上の − レール = GND
board: half
parts:
  R1: resistor c5 c10 10k
  L1: inductor b10 b13 100u
  C1: capacitor e7 e10 1000p
  D1: diode d10(A) d16(K) 1N60
  C2: capacitor b16 b19 2200p
  R2: resistor e16 e20 22k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2-, 2+, 1-, 1+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.1- -- -t14 black
  - AD.1+ -- a16 orange
  - a7 -- -t7 black
  - a13 -- -t13 black
  - a19 -- -t19 black
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/13-fm-slope-detector.svg)

電源は使わない。上の − レールを GND にし、AD の GND・2−・1− (黒) をそこへ挿す。

- **入力 (列 5)**: W1 (黄) を `a5` に。R1 は `c5`–`c10`
- **タンク (列 10)**: R1 の右端・L1 (`b10`–`b13`)・C1 (`e7`–`e10`)・D1 のアノード (`d10`) が
  同じ列。CH2 の 2+ (青) は `a10` に挿す。L1 の反対側 (列 13) と C1 の反対側 (列 7) は、
  黒の線で − レールへ
- **検波の出力 (列 16)**: D1 のカソード・C2 (`b16`–`b19`)・R2 (`e16`–`e20`) が同じ列。
  CH1 の 1+ (橙) は `a16` に挿す。C2 (列 19) と R2 (列 20) の反対側は黒の線で − レールへ
- L1 はアキシャルのマイクロインダクタ。500 kHz ならブレッドボードの浮遊容量 (数 pF) は
  C1 の 1000 pF に比べて小さく、f<sub>0</sub> はほとんど動かない

## 同調回路の山と動作点

```graph
title: 図3 タンクの振幅 (W1 4 V) — 490 kHz は斜面の中ほど、±5 kHz で振幅が上下する
x: 周波数 Hz 440k..570k
y: 振幅 V
lines:
  タンク V: 4/sqrt((1+10k/6963)^2+(10k*(2*pi*x*1n-1/(2*pi*x*100u)))^2)
notes:
  - band 485k 495k
  - text 509k 0.12V: 青い帯が ±5 kHz
  - mark 490k
  - peak
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/graph/13-fm-slope-detector.svg)

図3 のとおり、山の頂点 (503.3 kHz、1.642 V) ではなく、左の斜面の 490 kHz に搬送波を置く。帯の幅
(±5 kHz) の中で線はほぼまっすぐなので、周波数の変化がそのまま振幅の変化になる。
頂点に置くと、周波数がどちらにずれても振幅が減るので、音は 2 倍の周波数に歪む。

## 計器の設定

Analog Discovery だけを使う。搬送波 490 kHz と音 1 kHz は、どちらもオシロ (10 MHz 以下) で波形が見え、W1 の FM 変調で試験信号も作れるため。

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Modulation: 搬送波 Sine 490 kHz・振幅 4 V、FM、変調波 Sine 1 kHz、偏移 ±5 kHz (Index の単位は WaveForms の画面で確かめる。搬送波に対する % なら約 1.02 %) |
| Scope CH1 | 検波出力、100 mV/div、オフセット −1.15 V (直流の上の 1 kHz を拡大) |
| Scope CH2 | タンク (L1・C1 の上)、1 V/div、画面の上半分 |
| Scope 時間軸 | 200 µs/div、トリガは CH1 の立ち上がり 1.15 V |

W1 の出力の振幅は一定のまま (CH2 を W1 に付け替えると帯は平ら)。**振幅が 1 kHz で揺れるのは
タンクを通った後だけ**、というのが要点。

## 計器の画面

```scope
title: 図4 タンク (CH2) は搬送波が 1 kHz で太り細り、検波 (CH1) は 1 kHz の音
time: 200us/div
trigger: ch1 rising 1.15V
ch1: {wave: = 1.15V + 0.162V * sin(2 * pi * 1kHz * t), range: 100mV/div, position: -13.5div}
ch2: {wave: = (1.348V + 0.162V * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 490kHz * t), range: 1V/div, position: 2div}
measure: [vpp, avg, freq]
cursors: [250us, 750us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/13-fm-slope-detector.svg)

- 図4 の CH1 は 1 kHz の正弦で **約 0.32 Vpp**、平均 **約 1.15 V**。カーソル X1 (250 µs) が山、
  X2 (750 µs) が谷で、差が 0.32 V
- CH2 は 490 kHz の搬送波で、画面では塗りつぶされた帯に見える。帯の外形 (包絡線) が
  1.18〜1.51 V の間を 1 kHz で揺れる (Vpp は最大の所で 3.02 V)。**これが FM → AM**
- 実際の CH1 には 490 kHz のリップルが数十 mV 乗る (C2 が 2200 pF と小さいため)。
  気になるときは、後ろに 9-2 と同じくクリスタルイヤホンか 1 kΩ・0.1 µF の RC を足す

## 見るべき値

タンクの振幅は peak の値 (CH2 の Measurements の Vpp の半分)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| W1 を無変調で 440〜570 kHz に振ったときのタンクの振幅 (CH2) | 503.3 kHz で最大 1.64 V、490 kHz で 1.35 V (計算値) | 共振の山と、搬送波が斜面の中ほどにいること |
| 無変調で 485 / 495 kHz のタンクの振幅 | 1.18 V / 1.51 V | 傾き 約 33.4 mV/kHz |
| FM (±5 kHz、1 kHz) のときの CH2 の包絡線 | 1.18〜1.51 V で 1 kHz の揺れ | FM が AM に変わる |
| FM のときの CH1 | 1 kHz、約 0.32 Vpp、平均 約 1.15 V | スロープ検波で音が戻る |
| 偏移を ±2.5 kHz にしたときの CH1 | 約 0.16 Vpp | 出力は偏移に比例する |
| 搬送波を 503 kHz (頂点) にしたときの CH1 | 1 kHz がほぼ消え、2 kHz の歪んだ波 | 斜面に置く意味 |

L1 の Q とコンデンサの誤差で f<sub>0</sub> は数 % ずれる。まず無変調で周波数を振って山の頂点を
探し、そこから約 13 kHz 下に搬送波を置き直す。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 10 kΩ |
| L1 | マイクロインダクタ (アキシャル、Q 50 以上) | 100 µH |
| C1 | セラミックコンデンサ (C0G) | 1000 pF |
| D1 | ゲルマニウムダイオード | 1N60 |
| C2 | セラミックコンデンサ | 2200 pF |
| R2 | 抵抗 (1/4 W) | 22 kΩ |
| — | 信号源・計器 | Analog Discovery (W1、CH1、CH2) |

## 出典

自作。
