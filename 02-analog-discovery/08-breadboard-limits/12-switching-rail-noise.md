---
book: analog-discovery
chapter: 8
id: 8-12
title: 電源レールのノイズ (スイッチング電源を載せる)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-12 電源レールのノイズ (スイッチング電源を載せる)

スイッチング電源 (DC-DC コンバータ) は、入力の電流を一定の周期で入れたり切ったりして電圧を変える。
同じ 5 V のレールにつないだほかの回路から見ると、その周期でレールが揺れる。ここでは MT3608 の
昇圧モジュール (1.2 MHz で切り替える。回路の教科書の 5-11 と同じ物) を 5 V のレールに載せ、
**レールの離れた所 (静かな回路の電源を取る所) にどれだけ揺れが届くか**を AD3 の Spectrum で見る。
対策として、静かな回路の電源の入口に L と C のフィルタ (10 µH (マイクロヘンリー) と 10 µF) を入れて比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 5 V のレールに MT3608 を載せ、静かな回路は LC のフィルタの先から電源を取る
parts:
  V1: vsource 1,4 1,8 5
  M2: voltmeter 4,4 4,8 l=$\mathrm{CH2}$
  U1:
    type: ic3
    at: 7,4
    label: MT3608
    pins: [IN, GND, OUT]
  RL: resistor 10,4 10,8 1k l=$\mathrm{R_L}$
  Lf: inductor 4,1 8,1 10u l=$\mathrm{L_f}$
  Cf: capacitor 12,1 12,8 10u l=$\mathrm{C_f}$
  RQ: resistor 14,1 14,8 20k l=$\mathrm{R_Q}$
  M1: voltmeter 17,1 17,8 l=$\mathrm{CH1}$
  G1: ground 7,8
wires:
  - 1,4 -- 4,4
  - 4,4 -- U1.IN
  - U1.OUT -- 10,4
  - U1.GND -- 7,8
  - 4,4 -- 4,1
  - 8,1 -- 12,1
  - 12,1 -- 14,1
  - 14,1 -- 17,1
  - 1,8 -- 4,8
  - 4,8 -- 7,8
  - 7,8 -- 10,8
  - 10,8 -- 12,8
  - 12,8 -- 14,8
  - 14,8 -- 17,8
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/12-switching-rail-noise.svg)

- V1 は AD3 の Supplies の V+ (5 V)。U1 は MT3608 の昇圧モジュール (出力を半固定抵抗で 9.0 V に合わせておく) で、R<sub>L</sub> 1 kΩ (キロオーム) が負荷
- R<sub>Q</sub> 20 kΩ は静かな回路 (オペアンプやセンサー) の代わり。L<sub>f</sub> と C<sub>f</sub> がその電源の入口のフィルタ
- **フィルタなし**で比べるときは、L<sub>f</sub> を線に替え、C<sub>f</sub> を抜く
- CH2 はモジュールの入口 (VIN+ を挿す所)、CH1 は静かな回路の電源。どちらも GND に対して読む

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 左に静かな回路 (5〜14 列)、右にモジュールの入口 (20 列)
board: half
parts:
  Lf: inductor c5 c9 10u
  RQ: resistor b9 b14 20k
  Cf: capacitor/ceramic d9 d12 10u
  RL: resistor c24 c28 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1+, 1-, 2-, 2+]
  M1:
    type: device
    at: top
    label: MT3608 昇圧モジュール (9.0 V)
    pins: [VIN+, VIN-, VOUT+, VOUT-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t5 -- a5 red
  - AD.1+ -- a9 yellow
  - a12 -- -t12 black
  - a14 -- -t14 black
  - AD.1- -- -t16 black
  - AD.2- -- -t17 black
  - AD.2+ -- +t19 white
  - M1.VIN- -- -t21 black
  - M1.VIN+ -- +t20 red
  - M1.VOUT- -- -t26 black
  - M1.VOUT+ -- a24 orange
  - a28 -- -t28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/12-switching-rail-noise.svg)

- 電源 (AD3 の V+) は左上の端 (+t の 1 列) から入れる。静かな回路への枝は 5 列、モジュールの VIN+ は 20 列で、どちらも同じ + レールから取る。
  CH2 (2+) はモジュールの入口のすぐ隣 (+t の 19 列)
- モジュールの出力 (9 V) の線は、5 V と取り違えないよう橙にした。R<sub>L</sub> は 24→28 列
- 9 列が静かな回路の電源 (CH1)。L<sub>f</sub> (5→9 列)・C<sub>f</sub> (9→12 列)・R<sub>Q</sub> (9→14 列) がここに集まる

## 計器の設定

計器は Analog Discovery 3 の Supplies (5 V)・Spectrum (揺れを周波数ごとの線に分けて読むため) と Scope。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。V− は使わない |
| Spectrum | 0〜8 MHz、CH1 と CH2、Window Flat Top、単位 dBm、Average 16 回 |
| Scope | CH1、Offset −5 V (直流の 5 V を引いて揺れだけを見る)、Range はいちばん細かい所 (図4 は 200 µV/div で描いた。選べる Range は未確認)、時間軸 200 ns/div、Average 16 回 |
| 手順 | フィルタなし (L<sub>f</sub> を線、C<sub>f</sub> なし) → フィルタあり、の 2 通り |

Supplies の電力は、モジュールの入力が 5 V × 19 mA ≒ 95 mW (変換の効率 85 % の仮定) で、USB 給電の 250 mW に収まる。
Scope の Offset と細かい Range の組み合わせが選べないときは、Spectrum だけで読む (Offset の範囲は未確認)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 フィルタなしの静かな回路の電源 — 1.2 MHz と、その整数倍に線が並ぶ
device: ad3
sweep: 0-8MHz
samples: 16384
window: flattop
unit: dBm
ref: -50dBm
signal:
  - sine 1.2MHz 0.278mV
  - sine 2.4MHz 0.141mV
  - sine 3.6MHz 0.0441mV
  - sine 4.8MHz 0.0661mV
  - sine 6MHz 0.0512mV
  - sine 7.2MHz 0.0418mV
markers: [1.2MHz, 2.4MHz, 4.8MHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/spectrum/12-switching-rail-noise.svg)

図4 は同じ揺れの時間波形 (4 次までの線の和で描いた。sin の中の 7.540 MHz は 2π × 1.2 MHz の角周波数。
実物は 5 次より上の線も乗るので、切り替えの瞬間がもっと尖り、1.09 mVpp になる)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 フィルタなしの静かな回路の電源の揺れ — 周期 833 ns (4 次までの和で 0.75 mVpp)
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: "= 0.278mV*sin(7.540MHz*t+3.410) + 0.141mV*sin(15.08MHz*t+2.117) + 0.0441mV*sin(22.62MHz*t+1.712) + 0.0661mV*sin(30.16MHz*t+4.609)", range: 200uV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/12-switching-rail-noise.svg)

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| U1 | MT3608 の昇圧モジュール | 1.2 MHz で切り替え (データシートの値)。出力は 9.0 V に合わせる。回路の教科書の 5-11 と同じ物 |
| R<sub>L</sub> | 1 kΩ、1/4 W | 負荷。9 V で 81 mW (1/4 W の半分以下) |
| L<sub>f</sub> | 10 µH、アキシャルのリード品 (DCR 0.1 Ω ほど) | 電流は 0.25 mA ほどなので小さい品でよい |
| C<sub>f</sub> | 10 µF、積層セラミック (X7R、リード付き) | 5 V では容量が表示より減る (6-9) |
| R<sub>Q</sub> | 20 kΩ、1/4 W | 静かな回路の代わり |
| 電源 | AD3 の Supplies 5 V | モジュールの入力の 95 mW を含めて 250 mW に収まる |

## 見るべき値

計算値。モジュールの中は**仮定**: 入力のコンデンサ 22 µF (ESR 10 mΩ・ESL 2 nH)、コイル 22 µH、効率 85 %。
このとき入力の電流は平均 19 mA で、1 周期 (833 ns) ごとに 0 → 56.5 mA → 0 と三角に流れる (電流が 0 に戻る不連続の動作。
249 ns で上がり 311 ns で下がる)。配線は、AD3 からレールまでの線 20 cm が 230 nH、レールの 1→5 列が 5.5 nH、5→20 列が 30.7 nH、
モジュールへの線 5 cm が 43 nH (8-3 の式、**仮定**)。

| 量 | フィルタなし | フィルタあり |
| --- | --- | --- |
| モジュールの入口 (CH2) の揺れ | 1.34 mVpp、1.2 MHz の線 −60.0 dBm | 1.47 mVpp (ほぼ同じ) |
| 静かな回路の電源 (CH1) の揺れ | **1.09 mVpp**、1.2 MHz の線 **−61.1 dBm** | 1 µV 以下、−139 dBm (理想の模型) |
| 2.4 / 4.8 MHz の線 (CH1) | −67.0 / −73.6 dBm | −153 / −170 dBm |

- 入力の電流の揺れ 56.5 mApp のうち、AD3 へ向かう線に流れるのは 0.35 mApp だけで、残りはモジュールの中のコンデンサが受け持つ。
  それでも線の 230 nH は 1.2 MHz で ωL ≒ 1.7 Ω (ω (オメガ) = 2πf、π はパイ) あるので、レールに 1 mV ほどの揺れが出る
- フィルタなしでは、静かな回路の電源 (9 列) もモジュールの入口の 9 割ほど揺れる (1.2 MHz で 0.278 mV と 0.315 mV)。
  揺れの電流が通る AD3 への線 (230 nH) のほうが、5→20 列のレール (30.7 nH) よりずっと大きいからだ
- L<sub>f</sub> と C<sub>f</sub> の折れ点は 1 / (2π√(10 µH × 10 µF)) = 15.9 kHz。1.2 MHz はその 75 倍で、理想なら 78 dB 下がる
  (計算値)。**実物ではこれほど下がらない** — C<sub>f</sub> のリードの ESL や、フィルタの前後の線どうしの結合が効くため。
  測った線がどこで止まるかが、この題の実測で確かめる所
- 揺れは 1 mV ほどで小さく見えるが、利得 100 倍のアンプの電源やセンサーの基準電圧に乗ると、出力では 100 mV になりうる

**スイッチング電源は、静かな回路と同じレールに直に載せない。** 載せるなら、モジュールの入口に大きめのコンデンサ
(電解の 100 µF など) を足して線に流れる揺れを減らし、静かな回路は LC のフィルタの先から電源を取る。
GND の戻りも分けると (8-10 の 1 点接地) さらに効く。

## LTspice での確かめ

`sim/12-switching-rail-noise.cir` で、モジュールを「入力のコンデンサ + 三角の入力電流」の模型 (本文の仮定) に置き、
配線の L と静かな回路 (R<sub>Q</sub>・L<sub>f</sub>・C<sub>f</sub>) をつないで過渡解析した。0.9〜1 ms の 30 周期を取り、
周期に合わせた FFT で線の大きさを出した (FFT は LTspice の波形を Python で処理)。

| 量 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 入力の電流 (平均・揺れ) | 19 mA・56.5 mApp | 18.98 mA・56.49 mApp | 合う |
| AD3 へ向かう線の電流の揺れ | 0.35 mApp | 0.35 mApp | 合う |
| CH1 の揺れ (フィルタなし) | 1.09 mVpp、−61.1 / −67.0 / −73.6 dBm | 1.090 mVpp、−61.1 / −67.0 / −73.6 dBm | 合う |
| CH2 の揺れ (フィルタなし / あり) | 1.34 / 1.47 mVpp | 1.341 / 1.472 mVpp | 合う |
| CH1 の 1.2 MHz (フィルタあり) | −139 dBm | −139.1 dBm | 合う |

図4 の時間波形は、この FFT の 4 次までの大きさと位相で描いた。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
MT3608 の切り替えの周波数は [MT3608 のデータシート (Olimex の資料)](https://www.olimex.com/Products/Breadboarding/BB-PWR-3608/resources/MT3608.pdf)。

参考: [DC-DC コンバータ (Wikipedia)](https://ja.wikipedia.org/wiki/DC-DCコンバータ)
