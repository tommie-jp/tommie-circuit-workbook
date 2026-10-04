---
book: denken
chapter: 2
id: 2-7
title: 相互インダクタンスと結合係数 — 2 つのコイルの距離
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 2-7 相互インダクタンスと結合係数 — 2 つのコイルの距離

コイル 1 に交流を流すと、その磁束の一部がそばのコイル 2 を貫き、コイル 2 にも起電力が出る (相互誘導)。
その大きさを決めるのが**相互インダクタンス M**。2-6 の 100 回のコイルを 2 つ作り、筒を一直線に並べて
間の距離を変え、M と**結合係数 k** がどう変わるかを測る。最後に、同じ筒に重ねて巻いた 2 つの巻線で
k が 1 に近づくのを見る。変圧器 (第 8 章) は k を 1 に近づけたもの。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| e2 = M di1/dt、正弦波なら V2 = ω M I1 | コイル 2 の起電力。コイル 1 の電流の変化の速さに比例する |
| M = V2 / (ω I1) | 測った V2 と I1 から M を求める |
| k = M / √(L1 L2) | 結合係数。0 (結合なし) 〜 1 (磁束を全部共有)。L1 = L2 なら k = M / L1 |

## 回路図

```circuit
title: 図1 コイル 1 に流し、コイル 2 の電圧を読む
style:
  standard: jis
  pitch: 1.2
parts:
  W1: sine c1 h1 l=$\mathrm{W1}$
  L1: inductor c4 e4 l=$\mathrm{L_1}$
  Rr: resistor e4 h4 150 l=$\mathrm{R_{ref}}$
  M2: voltmeter e7 h7 l=$\mathrm{CH1}$
  L2: inductor c9 e9 l=$\mathrm{L_2}$
  M1: voltmeter c11 e11 l=$\mathrm{CH2}$
  G1: ground h1
  G2: ground e11
wires:
  - c1 -- c4
  - e4 -- e7
  - h1 -- h4 -- h7
  - c9 -- c11
  - e9 -- e11
notes:
  - text d5 left blue: L1 と L2 の距離 d
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/07-mutual-inductance.svg)

- W1 は AD の波形発生器。100 kHz、振幅 1 V。L1 と R<sub>ref</sub> (150 Ω) を直列に流れる電流は 6.13 mA (2-6 と同じ)
- CH1 は R<sub>ref</sub> の両端で、I1 = CH1 / 150 Ω
- L2 はどこにもつながない。片方の端を GND、もう片方を CH2 (2+) にして、開放の電圧 V2 を読む。
  CH2 の入力 (1 MΩ) には電流がほとんど流れないので、V2 = ω M I1 がそのまま出る
- L1 と L2 の筒は、軸を一直線にそろえて机に置き、巻線の端どうしの距離 d を変える

## 実体配線図

L<sub>1</sub>・L<sub>2</sub> は筒をブレッドボードの外の机に置き、両端のリードをブレッドボードの穴に挿す (リードが届かなければ、つなぎ線で延ばす)。

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  L1: inductor/axial c5 c10
  Rr: resistor d10 d15 150
  L2: inductor/axial c20 c25
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a10 blue
  - AD.1- -- -t12 black
  - AD.2+ -- b25 white [h-10]
  - AD.2- -- -t27 black
  - a15 -- -t15 black
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/07-mutual-inductance.svg)

- W1 → L<sub>1</sub> (5〜10 列) → R<sub>ref</sub> (10〜15 列) → GND レール (15 列)。1+ は R<sub>ref</sub> の上 (10 列)、1− は GND
- L<sub>2</sub> (20〜25 列) は L<sub>1</sub> とつながない。20 列を GND レールへ、25 列に 2+ を当てる
- ブレッドボードに流れる電流は 6.13 mA (計算値) で、ブレッドボードの 1 穴 200 mA に十分収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1・L2 | 手巻きのコイル | 2-6 の 100 回のコイルを 2 つ (直径 20 mm の紙筒、φ0.3 mm を 33 mm に 1 層 100 回、95.9 µH) |
| Rref | 抵抗 (1/4 W) | 150 Ω |
| — | 重ね巻きのコイル | 1 本の紙筒に 100 回を巻き、その上に 2 本目の 100 回を同じ向きに重ねて巻いたもの (2-6 の 200 回のコイルの真ん中に口出しを付けても同じ) |

## 手順

1. 2 つの筒を離して (d = 5 cm 以上) 置き、V2 がほぼ 0 になるのを確かめる (つなぎ間違いが無いか)
2. d = 20 mm・10 mm・5 mm・2 mm・0 (筒の端を突き合わせる) の順に近づけ、CH1 と CH2 の振幅を読む
3. d = 0 で L2 の筒を裏返す (向きを逆に) と、V2 の位相が 180° 変わるのを見る
4. 重ね巻きのコイルで、内側の巻線を L1、外側を L2 として同じく読む

## 計器の設定

計器は Analog Discovery 3 (AD3)。Wavegen W1 が 100 kHz の正弦波を出し、Scope の 1 ch で I1、2 ch で V2 を同時に読めるため。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、100 kHz、Amplitude 1 V |
| Scope | CH1 = Rref (I1)、CH2 = L2 (V2)。Time base 2 µs/div。CH1 は 500 mV/div、CH2 は 20 mV/div (遠い d では 5 mV/div、重ね巻きでは 200 mV/div) |
| Measure | CH1・CH2 の Amplitude と、CH2 の CH1 に対する Phase。V2 が 10 mV を切ったら Average を 16 回 |

d = 0 の画面。V2 は I1 より 90° 進む (L2 の向きを逆にすると 90° 遅れる)。

```scope
title: 図3 d = 0 — V2 (CH2) は I1 の分 (CH1) より 90° 進む
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 100kHz 920mV, range: 500mV/div}
ch2: {wave: sine 100kHz 46.2mV phase 90deg, range: 20mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/scope/07-mutual-inductance.svg)

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この題は CH1・CH2 とも GND 基準
(L2 の片方の端と R<sub>ref</sub> の下が GND) なので、回路はそのままでよい。

- W1 は FG の OUT (High-Z、Sine、100 kHz、振幅 1 V)。負荷は約 163 Ω なので、FG の 50 Ω で I1 は
  4.8 mA ほどに下がる (計算値)。V2 も同じ割合で下がり、M = V2 / (ω I1) は変わらない
- CH1 の先端を R<sub>ref</sub> の上、CH2 の先端を L2 の上。グランドクリップは 2 本とも GND (L2 の下と R<sub>ref</sub> の下)
- V2 は数 mV〜数十 mV と小さい。×1 のプローブにして 5 mV/div 以下に下げ、Average を掛ける。
  プローブのグランドリードの輪が FG の線の磁束を拾うので、リードは短く、L1 から離す

## 見るべき値

計算値 (コイルを細い輪の並びとした計算。L1 = L2 = 95.9 µH、I1 = 6.13 mA、100 kHz)。

| 距離 d | M | 結合係数 k | V2 (CH2 の振幅) |
| --- | --- | --- | --- |
| 20 mm | 1.89 µH | 0.020 | 7.3 mV |
| 10 mm | 4.08 µH | 0.043 | 15.7 mV |
| 5 mm | 6.61 µH | 0.069 | 25.5 mV |
| 2 mm | 9.26 µH | 0.097 | 35.7 mV |
| 0 (突き合わせ) | 12.0 µH | 0.125 | 46.2 mV |
| 重ね巻き | 95.7 µH | 約 0.97 | 369 mV |

分かること:

- **距離が近いほど M と k は大きい。** 2 cm 離すと k は 0.02 まで落ちる。コイル 1 の磁束は筒の端から
  広がって戻るので、一直線に並べても、突き合わせた所で k = 0.125 にしかならない
- **重ね巻きでは k がほぼ 1。** 2 つの巻線が同じ磁束をほとんど共有する。重ね巻きの k は 1 に近いが、
  巻線の間の隙間の磁束 (漏れ磁束) の分だけ 1 に届かない
- V2 は I1 より 90° 進む。e2 = M di1/dt で、正弦波を微分すると 90° 進むため。L2 の向きを逆にすると符号が
  変わる (和動と差動、2-8)
- 変圧器の鉄心は、磁束を鉄の中に閉じ込めて k を 0.99 以上にする。巻数比で電圧が決まる (8-1) のは k ≈ 1 のとき

## 出典

自作。M の計算は、2 つのコイルを 100 個ずつの円の輪とみて、輪どうしの相互インダクタンス
(ノイマンの式を楕円積分で表したもの) を足し合わせた。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
