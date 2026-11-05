---
book: analog-discovery
chapter: 10
id: 10-6
title: スイッチングノイズ
tier: 200
source: 自作 (値の目安は TI LM2596 のデータシート、計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 10-6 スイッチングノイズ

回路の教科書の 5-6 で組んだ降圧 DC-DC モジュールの出力には、スイッチの入り切りに合わせた揺れが乗る。これがスイッチングノイズで、
リニアのレギュレータ (10-3) には無い。揺れはスイッチの周波数とその整数倍に線として並ぶので、時間波形 (**Scope**) で形を、
**Spectrum** (FFT) で周波数と高さを読む。秋月の MBC2596-01 は TI の LM2596 を載せたモジュールで、LM2596 の発振は **150 kHz 固定** (データシート。ばらつき ±15 %)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 降圧モジュール (LM2596) の出力の雑音を CH1 で見る
parts:
  V1: vsource vin gnd 12
  G1: ground gnd
  M1:
    type: device
    model: MBC2596-01
    at: 7,3
    label: Buck DC-DC
    pins: [IN+, IN-, OUT+, OUT-]
  R1: resistor 9,5 9,7 100
  M2: voltmeter 11,5 11,7 l=$\mathrm{CH1}$
  G2: ground 9,7
points:
  vin: 2,2
  gnd: 2,4
wires:
  - vin -- 4.5,2 |- M1.IN+
  - gnd -- 3.5,4 |- M1.IN-
  - M1.OUT+ -| 5,5
  - 5,5 -- 9,5 -- 11,5
  - 9,7 -- 11,7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/06-switching-noise.svg)

- V1 は 12 V の AC アダプタ (DC 出力)。M1 は 5 V に合わせたモジュール (合わせ方は 5-6)
- R1 (100 Ω (オーム)、1/2 W) が負荷で 50 mA。OUT− は描いていない。このモジュールは入力と出力の GND が基板の中でつながっている (5-6)
- CH1 は出力。AD3 の BNC アダプタの AC 結合で、5 V の直流を除いて揺れだけを見る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 モジュールの出力 5 V を上の赤レールへ。12 V はレールに入れない
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
    label: Buck DC-DC モジュール (5 V に調整済み)
    pins: [IN+, OUT+, OUT-, IN-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope・Spectrum + BNC アダプタ (CH1 は AC 結合)
    pins: [1+, 1-]
  R1: resistor/half c10 c14 100
wires:
  - ADP.12V -- M1.IN+ red
  - ADP.GND -- -t1 black
  - M1.IN- -- -t26 black
  - M1.OUT+ -- +t3 red [v36, h-272]
  - M1.OUT- -- -t4 black [v50, h-325]
  - +t10 -- a10 red
  - a14 -- -t14 black
  - SC.1+ -- +t8 orange
  - SC.1- -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/06-switching-noise.svg)

- 5-6 の図2 から表示の LED を外した配線。12 V はアダプタからモジュールの IN+ へ直に渡し、ブレッドボードのレールに入れない
- 上の赤レールが 5 V (OUT+)、青レールが GND。R1 は 10〜14 列。CH1 は BNC ケーブル (先がクリップのもの) の芯を赤レール、外皮を青レールに当てる

## 計器の設定

AD3 本体のピンは DC 結合だけで、5 V の直流を細かい目盛では打ち消せない (5-6 と 10-1)。そこで **BNC アダプタ** を付け、CH1 のジャンパを AC にする。

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 AC 結合、10 mV/div、2 µs/div (µs はマイクロ秒)、トリガ CH1 立ち上がり 0 V |
| Spectrum | CH1、0〜1.2 MHz、窓 Hann、平均 8 回 (目安)、単位 dBm |

LTspice の模型 (下の節) で出た波形を、方形のパルスを丸めた形で近づけて描いたのが図3 (計算)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 出力の揺れ (AC 結合) — 150 kHz ごとに 30 mVpp の山
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: pulse 150kHz 15.2mV duty 17% offset 10mV | rc 200ns, range: 10mV/div}
cursors: [0, 6.67us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/06-switching-noise.svg)

山はスイッチが入っている約 1.1 µs (1 周期 6.67 µs の 17 %) に立つ。コイルの電流が出力のコンデンサの ESR (等価直列抵抗) を流れ、電圧が跳ねる。
スイッチが切れた後、コイルの電流は 0 まで落ちて止まる (電流不連続。負荷が軽いため)。この間、実物ではスイッチの点の電圧が小さく振動する
(データシートの 8.4.1 節。「帰還の不安定ではなく正常」と書いてある)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 出力の FFT — 150 kHz とその整数倍に線が並ぶ (模型)
device: ad3
sweep: 0-1.2MHz
samples: 8192
window: hann
unit: dBm
ref: -20dBm
signal:
  - sine 150kHz -31.0dBm
  - sine 300kHz -34.8dBm
  - sine 450kHz -42.0dBm
  - sine 600kHz -52.7dBm
  - sine 750kHz -55.9dBm
  - sine 900kHz -60.0dBm
  - sine 1050kHz -56.5dBm
markers: [150k, 300k, 450k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/spectrum/06-switching-noise.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 降圧 DC-DC モジュール | MBC2596-01 (LM2596、5 V に調整済み) |
| R1 | 抵抗 (1/2 W) | 100 Ω (5² / 100 = 0.25 W。1/4 W では足りない) |
| — | 電源 | 12 V の AC アダプタ — 降圧は出力より高い入力が要る (5-6 と同じ) |
| — | 計器 | AD3 の Scope と Spectrum (CH1)、BNC アダプタ (AC 結合) と BNC ケーブル |

## 見るべき値

計算値。モジュールの中のコイル・コンデンサの値は公開されていないので、33 µH・220 µF (ESR 0.1 Ω) と仮定した模型の値 (下の節)。
実物の高さは部品で数倍変わる。周波数は LM2596 が決めるので変わらない。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 揺れの周波数 | **150 kHz** (127〜173 kHz、±15 %) | LM2596 の発振。負荷を変えても動かない |
| 揺れの大きさ | 約 30 mVpp (5 V の 0.6 %) | ESR × コイルの電流の山 (約 0.26 A) |
| FFT の線 | 150 kHz で −31 dBm、300 kHz で −35 dBm、450 kHz で −42 dBm | 山の形が尖っているので、2 倍・3 倍の線が高い |
| 出力の直流 | 5.0 V | トリマで合わせた値 |

- **商用電源の 50 / 60 Hz とは関係ない線** (10-1 のリップルの 100 / 120 Hz とは別の所に出る)。どちらの地域でも同じ図になる
- スイッチの入り切りの瞬間には、数十 MHz の細い振動 (髭) が乗ることがある。配線とダイオードのわずかなインダクタンス・容量によるもので、
  模型には入れていない。ブレッドボードと AD3 の Scope の帯域 (9 MHz) の外なので、形は正しく見えない (目安)
- 負荷を重くする (R1 を 2 本並列の 50 Ω、1 W) と、コイルの電流が連続になって山の形が三角に近づき、高い次数の線が下がる
- この雑音を後ろのリニアで落とせるか (落とせないか) は 10-7。10-3 の図4 のとおり、7805 の PSRR は 150 kHz で 43 dB ほどしかない

## LTspice での確かめ

`sim/06-switching-noise.cir` で図1 を 60 ms 動かし、最後の 0.1 ms を読んだ。モジュールの中身は仮定 (L 33 µH・巻き線 0.1 Ω、出力 220 µF・ESR 0.1 Ω・ESL 10 nH、
スイッチの ON 抵抗 0.2 Ω、汎用のショットキーの模型)。LM2596 の帰還は省き、出力が 5 V に近くなるデューティ (17.2 %) を固定で与えた。
FFT は LTspice の波形を 15 周期ぶん取り出して計算した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の直流 | 5.0 V | 4.96 V | 合う (デューティを合わせた) |
| 揺れ | 約 30 mVpp | 30.3 mVpp (図3 の読み 30.3 mVpp) | 合う |
| コイルの電流の山 | 約 0.26 A (不連続) | 0.257 A、最小 −0.012 A | 合う |
| FFT 150・300・450 kHz | −31・−35・−42 dBm | −31.0・−34.8・−42.0 dBm | 合う (図4 は LTspice の値で描いた) |
| 入力の電流 | — | 21.7 mA (効率 95 %。LM2596 自身の消費は入れていない) | 参考 |

## 出典

自作。発振の周波数と不連続のときの振動は [TI LM2596 のデータシート (SNVS124G)](https://www.ti.com/lit/ds/symlink/lm2596.pdf)。
計器の名前と操作は Digilent の [Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
