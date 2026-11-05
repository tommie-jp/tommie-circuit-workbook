---
book: analog-discovery
chapter: 10
id: 10-7
title: LDO vs スイッチング
tier: 200
source: 自作 (値の目安は TI LM340・LM2596 のデータシート、計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 10-7 LDO vs スイッチング

12 V から 5 V・50 mA を作る方法を 3 つ並べ、**効率** (出力の電力 ÷ 入力の電力) と**出力の雑音**を比べる。リニア (7805 や LDO) は静かだが、
電圧の差をそのまま熱にする。スイッチング (10-6) は熱が少ないが、150 kHz の雑音を出す。よく使う折衷が、スイッチングで少し高めの電圧まで落とし、
その後ろにリニアを置く組 (ポストレギュレータ) だ。7805 の PSRR (10-3) が雑音をどれだけ落とすかを、**Spectrum** で確かめる。

| 組 | つなぎ方 | 変えるところ |
| --- | --- | --- |
| A リニアだけ | 12 V → 7805 → 5 V | モジュールを外し、アダプタの 12 V を上の赤レールへ |
| B スイッチングだけ | 12 V → モジュール (5 V) → 負荷 | 10-6 と同じ |
| C スイッチング + リニア | 12 V → モジュール (7.5 V) → 7805 → 5 V | 図1・図2 |

7805 は LDO ではない (入力と出力の差が 2 V 要る)。LDO (回路の教科書の 5-4 の AMS1117 など) に替えると C の 7.5 V を 6 V 程度まで下げられ、
効率が少し上がる。雑音を落とす仕組みは同じなので、この題は手元の 7805 で比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 降圧モジュールを 7.5 V にして、後ろに 7805 を置く (C の組)
parts:
  V1: vsource vin gnd 12
  G1: ground gnd
  M1:
    type: device
    model: MBC2596-01
    at: 7,3
    label: Buck DC-DC
    pins: [IN+, IN-, OUT+, OUT-]
  M3: voltmeter 6.5,5 6.5,7 l=$\mathrm{CH2}$
  C1: capacitor 8.5,5 8.5,7 0.33u
  U1: regulator 11,5 7805
  C2: capacitor 13,5 13,7 0.1u
  R1: resistor 15,5 15,7 100
  M2: voltmeter 17,5 17,7 l=$\mathrm{CH1}$
  G2: ground 11,7
points:
  vin: 2,2
  gnd: 2,4
wires:
  - vin -- 4.5,2 |- M1.IN+
  - gnd -- 3.5,4 |- M1.IN-
  - M1.OUT+ -| 5,5
  - 5,5 -- 6.5,5 -- 8.5,5 -- U1.in
  - U1.out -- 13,5 -- 15,5 -- 17,5
  - U1.gnd -- 11,7
  - 6.5,7 -- 8.5,7 -- 11,7 -- 13,7 -- 15,7 -- 17,7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/07-ldo-vs-switching.svg)

- M1 は 10-6 のモジュールで、トリマで出力を 7.5 V に合わせ直す (7805 の入力と出力の差 2.5 V。ドロップアウトの 2 V に余裕を持たせる)
- C1・C2 は 7805 の入力と出力のコンデンサ (10-3 と同じ値)。R1 (100 Ω (オーム)、1/2 W) が 50 mA の負荷
- CH1 は 7805 の出力 (5 V)、CH2 はモジュールの出力 (7.5 V)。どちらも BNC アダプタの AC 結合で揺れだけを見る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上の赤レールがモジュールの 7.5 V、下の赤レールが 7805 の 5 V
board: half
parts:
  ADP:
    type: device
    at: top
    label: 12 V AC アダプタ (DC 出力)
    pins: [GND, 12V]
  M1:
    type: device
    model: MBC2596-01
    at: top
    label: Buck DC-DC モジュール (7.5 V に調整)
    pins: [IN+, OUT+, OUT-, IN-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope・Spectrum + BNC アダプタ (AC 結合)
    pins: [1+, 1-, 2+, 2-]
  U1: regulator/to220 f15 f16 f17 7805
  C1: capacitor g15 g16 0.33uF cap=left
  C2: capacitor h16 h17 0.1uF cap=right
  R1: resistor/half i17 i21 100
wires:
  - ADP.12V -- M1.IN+ red
  - ADP.GND -- -t1 black
  - M1.IN- -- -t26 black
  - M1.OUT+ -- +t3 red [v36, h-272]
  - M1.OUT- -- -t4 black [v50, h-325]
  - +t11 -- a11 orange
  - e11 -- f11 orange
  - h11 -- h15 orange
  - i16 -- -b16 black
  - j17 -- +b17 red
  - j21 -- -b21 black
  - -t30 -- -b30 black
  - SC.1+ -- +b24 yellow
  - SC.1- -- -b26 black
  - SC.2+ -- +t28 orange
  - SC.2- -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/07-ldo-vs-switching.svg)

- 上の赤レールがモジュールの 7.5 V。11 列で上のブロックに下ろし、溝を渡って下のブロックの 11 列から 7805 の IN (15 列) へ (橙)
- 7805 は f15〜f17 (IN・GND・OUT)。OUT の 17 列から下の赤レール (5 V) へ。GND の 16 列は下の青レール、上と下の青レールは 30 列でつなぐ
- 1+ (黄) は下の赤レール、2+ (橙) は上の赤レール。A の組ではモジュールを外して、アダプタの 12 V を上の赤レールへ挿す (7805 の入力が 12 V になる)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1・CH2 とも BNC アダプタで AC 結合。CH1 0.2 mV/div、CH2 10 mV/div、2 µs/div (µs はマイクロ秒)、トリガ CH2 立ち上がり 0 V |
| Spectrum | CH1 (C の組は CH2 も)、0〜1.2 MHz、窓 Hann、平均 8 回 (目安)、単位 dBm |
| 入力の電流 | テスターの mA レンジを、アダプタの + とモジュール (A の組は 7805) の間に入れる |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 C の組 — 7.5 V の揺れ (CH2) 32 mVpp が 5 V (CH1) では 0.7 mVpp
time: 2us/div
trigger: ch2 rising 0V
ch1: {wave: pulse 150kHz 0.345mV duty 17% offset 0.228mV | rc 200ns, range: 200uV/div}
ch2: {wave: pulse 150kHz 16.2mV duty 17% offset 10.7mV | rc 200ns, range: 10mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/07-ldo-vs-switching.svg)

図3 は LTspice の模型の山の高さを、10-6 と同じ丸めたパルスで描いた画面 (計算)。CH1 は CH2 の約 47 分の 1 (−33 dB) で、
1 目盛が 50 分の 1 の尺度で見て同じくらいの形になる。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 C の組の 5 V の FFT — 150 kHz の線は −74 dBm (B の組は −31 dBm)
device: ad3
sweep: 0-1.2MHz
samples: 8192
window: hann
unit: dBm
ref: -50dBm
signal:
  - sine 150kHz -73.8dBm
  - sine 300kHz -71.6dBm
  - sine 450kHz -75.6dBm
  - sine 600kHz -78.0dBm
  - sine 750kHz -79.8dBm
  - sine 900kHz -91.2dBm
  - sine 1050kHz -89.4dBm
markers: [150k, 300k, 450k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/spectrum/07-ldo-vs-switching.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 降圧 DC-DC モジュール | MBC2596-01 (C の組は 7.5 V、B の組は 5 V に調整) |
| U1 | 3 端子レギュレータ (TO-220) | 7805 |
| C1 | セラミックコンデンサ (334) | 0.33 µF |
| C2 | セラミックコンデンサ (104) | 0.1 µF |
| R1 | 抵抗 (1/2 W) | 100 Ω (0.25 W) |
| — | 電源 | 12 V の AC アダプタ — リニアとスイッチングの差は入力と出力の差が大きいほどはっきり出る (5-6 と同じ) |
| — | 計器 | AD3 の Scope と Spectrum、BNC アダプタ、テスター (入力の電流) |

## 見るべき値

計算値。出力 5 V・50 mA (0.25 W)。7805 の消費電流は 5 mA、LM2596 の消費電流は 5 mA (どちらもデータシートの代表値)。
モジュールの中身は 10-6 と同じ仮定の模型。

| 組 | 入力の電流 | 効率 | 熱になる電力 | 5 V の 150 kHz の線 | 分かること |
| --- | --- | --- | --- | --- | --- |
| A リニアだけ | 55 mA | 38 % | 0.41 W (7805) | 無い (データシートの雑音は 10 Hz〜100 kHz で 40 µV) | 静かだが、7 V × 50 mA が熱になる |
| B スイッチングだけ | 約 27 mA | 約 77 % | 約 0.07 W | −31 dBm (30 mVpp) | 効率は 2 倍だが、150 kHz の線が立つ |
| C スイッチング + リニア | 約 40 mA | 約 52 % | 0.23 W (うち 7805 が 0.16 W) | **−74 dBm** (0.7 mVpp) | 7805 が雑音を 43 dB 下げる。効率は A と B の間 |

- 7805 の熱: A の組の 0.41 W は、データシートの RθJA (TO-220、試験の基板で 23.9 °C/W) で 10 °C、ブレッドボードに立てただけなら その 2 倍ほど (目安) 上がる。
  手で触れる温度に収まるが、電流を 10 倍にすると放熱板が要る
- C の組の線が −74 dBm まで下がるのは、7805 の 150 kHz の PSRR (10-3 の図4、約 43 dB) のぶん。300 kHz の線は PSRR が浅いぶん (37 dB) 高く残り、−72 dBm で一番高い
- 線の高さの差 (B − C) が、10-3 で Network で測った PSRR と合えば、2 つの題の測り方が同じ物を見ていると分かる
- A の組の 7805 の雑音 40 µV は 10 Hz〜100 kHz の和で、FFT の 1 本の線では −80 dBm より下 (AD3 の FFT の床の近く。目安)

## LTspice での確かめ

`sim/07-ldo-vs-switching.cir` で C の組を 60 ms 動かし、最後の 0.1 ms を読んだ。降圧は 10-6 と同じ仮定の模型でデューティ 27 %、7805 は 10-3 と同じ仮定の模型。
B の組は `sim/06-switching-noise.cir`、A の組は算術 (入力の電流 = 50 mA + 5 mA)。FFT は LTspice の波形を 15 周期ぶん取り出して計算した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| モジュールの出力 (C) | 7.5 V・32 mVpp | 7.50 V・32.4 mVpp | 合う |
| 7805 の出力 (C) | 5.0 V・0.7 mVpp | 5.00 V・0.69 mVpp | 合う |
| 5 V の 150・300 kHz の線 (C) | −74・−72 dBm | −73.8・−71.6 dBm | 合う (図4 は LTspice の値) |
| 入力の電流 (C) | 約 40 mA | 35.2 mA + LM2596 の 5 mA (模型に入れていない分を足した) | 合う |
| 入力の電流 (B) | 約 27 mA | 21.7 mA + 5 mA | 合う |

## 出典

自作。消費電流と熱抵抗は [TI LM340 / LM7805 のデータシート (SNOSBT0L)](https://www.ti.com/lit/ds/symlink/lm340.pdf) と
[TI LM2596 のデータシート (SNVS124G)](https://www.ti.com/lit/ds/symlink/lm2596.pdf)。
計器の名前と操作は Digilent の [Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
