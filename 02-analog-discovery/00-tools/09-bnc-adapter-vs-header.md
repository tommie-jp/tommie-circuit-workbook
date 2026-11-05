---
book: analog-discovery
chapter: 0
id: 0-9
title: AD3 の BNC アダプタ有りと無し (ヘッダ直結) を比べる (帯域・バッファ長)
tier: 200
source: 自作 (数値は Digilent の Analog Discovery 3 の公式仕様と TI の SN74HC14 のデータシート)
board: BB
---

# 0-9 AD3 の BNC アダプタ有りと無し (ヘッダ直結) を比べる (帯域・バッファ長)

0-5 では仕様の数で、0-6 と 2-10 では Wavegen の方形波で、BNC アダプタの有無による帯域の差を見た。
ただしループバックでは Wavegen とオシロの 2 段の帯域が重なり、オシロ 1 段の差が分からない。
この題では Wavegen の方形波を 74HC14 (シュミットトリガのインバータ) に通して、**Wavegen より速いエッジ**を作り、
同じ点をヘッダ直結 (付属ワイヤ) と BNC アダプタ + 10:1 プローブで測る。あわせて、アダプタで変わるもの
(入力の形・結合) と変わらないもの (バッファ長) を表にする。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の方形波を 74HC14 に通して速いエッジを作る
parts:
  W1: square 1,2 1,4 l=$\mathrm{W1}$
  U1F: not 4,2 74HC14
  M1: voltmeter 7,2 7,4 l=$\mathrm{CH1}$
  G1: ground 1,4
  G2: ground 7,4
  VCC: vcc 9,1 5V
  C1: capacitor 9,1 9,3 100n
  G3: ground 9,3
wires:
  - 1,2 -- U1F.in
  - U1F.out -- 7,2
notes:
  - text 1,5.5 small left: "U1 は 74HC14。PIN 14 を +5V、PIN 7 を GND"
  - text 1,6 small left: "使わない入力 PIN 1・3・5 は GND、PIN 9・11 は +5V"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/09-bnc-adapter-vs-header.svg)

- W1 は 0〜5 V の方形波 (振幅 2.5 V・オフセット 2.5 V)、100 kHz。W1 のエッジの立ち上がり (付属ワイヤで約 39 ns) は、
  74HC14 のしきい値を通り過ぎる時刻を決めるだけで、出力のエッジの速さは 74HC14 が決める
- U1F は 74HC14 の 6 番目のインバータ (PIN 13 → 12)。出力 6Y を CH1 で読む
- 電源は V+ の 5 V。C1 (0.1 µF (マイクロファラド)) は IC のすぐそばのデカップリング

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 74HC14 の 6Y (12 列) を CH1 で読む
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1-, W1, 1+]
  U1: dip14 @ e10 74HC14
  C1: capacitor/ceramic b6 b8 100n
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - -t1 -- -b1 black
  - a6 -- +t6 red
  - a8 -- -t8 black
  - a10 -- +t10 red
  - AD.1- -- -t5 black
  - AD.W1 -- a11 yellow
  - AD.1+ -- a12 orange
  - a13 -- +t13 red
  - a15 -- +t15 red
  - j10 -- -b10 black
  - j12 -- -b12 black
  - j14 -- -b14 black
  - j16 -- -b16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/09-bnc-adapter-vs-header.svg)

- 74HC14 の 1 番は左下 (f10)。上の段の右から PIN 14 (VCC, e10)・13 (6A, e11)・12 (6Y, e12)
- 使わない入力は、上の段の 4A (e15)・5A (e13) を +5 V のレールへ、下の段の 1A (f10)・2A (f12)・3A (f14) を下の GND のレールへ
- 下の − レールは左の端 (1 列) の黒い線で上の − レールとつなぐ。C1 は 6・8 列で上の 2 本のレールの間に挿す
- BNC アダプタで測るときは、1+ の付属ワイヤの代わりに 10:1 プローブの先を 12 列の空いた穴に、グラウンドのクリップを 16 列 (GND) に当てる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Wavegen (W1) | 方形波、100 kHz、振幅 2.5 V、オフセット 2.5 V |
| Device Manager | Scope のバッファが最大の構成 (32,768 点。1-10) |
| Scope (CH1) | Range 2 V/div 程度、トリガは CH1 の立ち上がり 2.5 V、20 ns/div。Measurements に Rise Time。BNC アダプタのときはプローブの倍率を 10× に合わせ、補正を済ませておく (2-9) |
| Device Options | system frequency を最大の 125 MHz にする (標本の間隔が 8 ns になる) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 同じ 6Y のエッジ — ヘッダ直結は約 40 ns、BNC アダプタは約 14 ns で立ち上がる
time: 20ns/div
trigger: ch1 rising 2.5V
ch1: {wave: square 100kHz 2.5V offset 2.5V | rc 18ns, range: 1V/div, position: -2.5div}
ch2: {wave: square 100kHz 2.5V offset 2.5V | rc 6.5ns, range: 1V/div, position: -2.5div}
measure: [rise, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/09-bnc-adapter-vs-header.svg)

図3 の ch1 はヘッダ直結 (付属ワイヤ)、ch2 は BNC アダプタ + 10:1 プローブで同じ点を測ったときの見込み。
2 回に分けて測った波を、同じ尺度で重ねて描いてある。どちらも 1 次の RC (τ (タウ) = t<sub>r</sub> ÷ 2.2) で近似した理想の形
(ch1 は τ = 18 ns で t<sub>r</sub> 39.2 ns、ch2 は τ = 6.5 ns で 14.3 ns) で、実機の波には少し行き過ぎや段がつく。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| U1 | シュミットトリガのインバータ | 74HC14 | 5 V。出力の遷移時間は典型 8 ns (V<sub>CC</sub> 4.5 V・負荷 50 pF) |
| C1 | 積層セラミック | 0.1 µF | デカップリング |
| — | BNC アダプタと 10:1 プローブ | Digilent の BNC Adapter Board | 比べる側。プローブの帯域はオシロより十分広い物 (100 MHz 級) を使う |

## 見るべき値

立ち上がり時間は、つながった各段の t<sub>r</sub> の二乗和の平方根で見積もる (目安)。オシロの段は t<sub>r</sub> ≈ 0.35 ÷ 帯域 (2-10)。

| | ヘッダ直結 (付属ワイヤ) | BNC アダプタ + 10:1 プローブ |
| --- | --- | --- |
| オシロの帯域 (−3 dB) | 9 MHz | 30 MHz 以上 |
| オシロの段の t<sub>r</sub> | 0.35 ÷ 9 MHz = 38.9 ns | 0.35 ÷ 30 MHz = 11.7 ns 以下 |
| 74HC14 の出力 (8 ns) と合わせた t<sub>r</sub> | √(38.9² + 8²) = **39.7 ns** | √(11.7² + 8²) = **14.2 ns** 以下 |
| 入力の形 | 差動 (1+ と 1−) | シングルエンド (BNC の外皮が GND) |
| 入力の結合 | DC だけ | DC か AC (AC の −3 dB は 1.6 Hz) |
| バッファ長 | 最大 32,768 点 / ch (Device Manager の構成で決まる) | **同じ** (アダプタは信号をつなぎ替えるだけ) |
| 入力インピーダンス | 1 MΩ ‖ 24 pF | 同じ (10:1 プローブを付けると 10 MΩ 級) |

- ヘッダ直結の 39.7 ns は、ほとんどオシロ自身の帯域で決まる。74HC14 の 8 ns は見えない
- BNC アダプタの 14 ns は標本の間隔 (8 ns) の 2 倍にも満たない。WaveForms は標本の間を補間して描くので
  読み値は出るが、ここが AD3 で測れる速さの下限の近くになる (目安)
- バッファ長は同じなので、同じ 20 ns/div の画面で記録できる時間の長さは変わらない。アダプタで変わるのは
  帯域と入力の形・結合だけ

## LTspice での確かめ

`sim/09-bnc-adapter-vs-header.cir` で、74HC14 の出力を 10〜90 % が 8 ns の台形の段 (仮定) とし、
オシロの段をそれぞれ f<sub>−3dB</sub> = 9 MHz と 30 MHz の 1 次ローパス (仮定) に通して 10〜90 % の時間を読んだ。

| 項目 | 本文 | LTspice | 判定 |
| --- | --- | --- | --- |
| ヘッダ直結 (9 MHz) の t<sub>r</sub> | 39.7 ns | 39.65 ns (入力の段は 8.00 ns) | 合う |
| BNC アダプタ (30 MHz) の t<sub>r</sub> | 14.2 ns | 14.36 ns | 合う (0.2 ns 長い) |

二乗和の平方根は、段の応答がガウス形のときの式で、1 次ローパスと台形の組では少しずれるが、ずれは 0.2 ns 以下だった。図3 の τ (18 ns・6.5 ns) は、この 2 つの値に合わせて選んだ。

## 出典

自作。オシロの帯域 (ヘッダ 9 MHz・BNC 30 MHz 以上)、入力の形と結合、AC 結合の 1.6 Hz、入力インピーダンス、
バッファ長、system frequency の範囲は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Analog Input Channels の節)。74HC14 の遷移時間とピン配置は TI の
[SN74HC14 のデータシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)。
