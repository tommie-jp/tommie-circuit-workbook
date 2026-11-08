---
book: analog-discovery
chapter: 9
id: 9-9
title: 位相余裕 (ループを切る)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-9 位相余裕 (ループを切る)

帰還増幅回路が発振しにくいかどうかは、**ループ利得** T = Aβ (β はベータ。オペアンプの開ループ利得 A と帰還率 β の積) で決まる。
|T| が 1 (0 dB) になる周波数 f<sub>c</sub> で、T の位相が −180° からどれだけ離れているか — これが**位相余裕** (PM) で、
小さいほど段の応答が行き過ぎ (オーバーシュート) て鳴り、0 で発振する。

T を測るには帰還の輪を 1 か所で切り、片側から入れて反対側で受ける。ここでは輪を**オペアンプの入力で切ったものとみなす**。
オペアンプは入力の差 V<sub>e</sub> = V<sub>+</sub> − V<sub>−</sub> を A 倍して出し、それが β 倍されて V<sub>−</sub> (帰還 V<sub>fb</sub>) に戻る。
だから **V<sub>fb</sub> / V<sub>e</sub> = Aβ = T**。AD3 の Scope は差動入力なので、CH1 を + 入力と − 入力の間に当てれば
V<sub>e</sub> がそのまま読める。回路は閉じたまま (直流の動作点もそのまま) で T が測れる。

題材は 9-2 の LM358 非反転増幅 (利得 11 倍)。帰還点 fb に Cp を足すと β に 2 つ目の極ができ、位相余裕が減る。
回路の教科書の 4-20 (容量負荷と位相補償) の「なぜ鳴るか」を、Network で数にする題。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 帰還点 fb に Cp を足す。CH1 は誤差 Ve、CH2 は帰還 Vfb
parts:
  AD:
    type: device
    at: 1,2
    turn: mirror
    label: Analog Discovery
    pins: [2+, 1-, 1+, V+, W1, 2-, GND]
  Cin: capacitor 6,6 8,6 1u
  R1: resistor 8,4 8,6 100k
  R2: resistor 9,6 9,8 100k
  U1: opamp 13,6.35 +up LM358
  Rf: resistor 18,8 16,8 10k
  Rg: resistor 12,8 12,10 1k
  Cg: capacitor 12,10 12,12 10u
  Cp: capacitor 14.5,8 14.5,10 2.2n
  G1: ground 9,8
  G2: ground 12,12
  G3: ground 14.5,10
  G4: ground 4,12
wires:
  - AD.V+ -| 8,4
  - AD.W1 -| 6,6
  - 8,6 -- 9,6
  - 9,6 -- 10,6
  - AD.1+ -| 10,6
  - 10,6 -| U1.+
  - U1.- -| 12,8
  - 12,8 -- 14.5,8
  - 14.5,8 -- 16,8
  - U1.out -| 18,8
  - AD.1- -| 16.5,3
  - 16.5,3 -- 16.5,7
  - 16.5,7 -- 16,7
  - 16,7 -- 16,8
  - AD.2+ -| 17,3.5
  - 17,3.5 -- 17,7
  - 17,7 -- 16.5,7
  - AD.2- -| 4,12
  - AD.GND -| 4,12
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/09-phase-margin.svg)

- R1・R2・Cin・Rf・Rg・Cg は 9-2 と同じ (交流の利得 1 + Rf / Rg = 11 倍、直流は 1 倍)
- Cp (2.2 nF) は fb から GND へ。fb から見た抵抗 Rf ∥ Rg = 909 Ω (オーム) と組んで、β に 1 / (2π (パイ) × 909 Ω × 2.2 nF) = 79.6 kHz の極を作る
- CH1 は 1+ を + 入力、1− を fb (− 入力) に当てた差動で、V<sub>e</sub> を読む。CH2 は 2+ を fb、2− を GND に当てて V<sub>fb</sub> を読む

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (9-2 の配置に Cp を足す)
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  Cin: capacitor/ceramic a5 a8 1u
  R1: resistor c3 c8 100k
  R2: resistor d8 d12 100k
  Rf: resistor h17 h20 10k
  Rg: resistor i20 i24 1k
  Cg: capacitor/electrolytic g24(+) g27(-) 10uF
  Cp: capacitor/ceramic j20 -b20 2.2n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t7 red
  - AD.GND -- -t9 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a13 orange
  - AD.1- -- a14 white
  - AD.2+ -- a20 purple
  - AD.2- -- -t22 black
  - a3 -- +t3 red
  - b8 -- b13 orange
  - a12 -- -t12 black
  - b15 -- b17 gray
  - c14 -- c20 green
  - e17 -- f17 gray
  - e20 -- f20 green
  - j12 -- -b12 black
  - g13 -- g14 green
  - j15 -- +b15 red
  - j27 -- -b27 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/09-phase-margin.svg)

- 9-2 の配置から、計器の線を 3 本替えて Cp を 1 本足した。1+ (橙) は 3=IN1+ の 13 列、1− (白) は 2=IN1− の 14 列、
  2+ (紫) は fb の上ブロックの 20 列 (`c14 -- c20` で 2=IN1− とつながる)
- Cp は下ブロックの fb の 20 列 (j20) から下の − レールへ直に挿す。Rf・Rg と同じ 20 列なので、fb の線を延ばさずに済む
- 使わない 2 回路目のフォロワ・電源・レールの渡りは 9-2 と同じ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Network | 掃引 10 kHz〜1 MHz、点数 101、振幅 20 mV、Reference = CH1 (V<sub>e</sub>)、DUT = CH2 (V<sub>fb</sub>)、平均 4 回 (目安) |
| Wavegen と Scope (段の応答) | W1: Square、2 kHz、Amplitude 5 mV。Scope は CH2 を BNC アダプタで AC 結合にし (9-1 と同じ)、CH1 の 1+ を W1、1− を GND に付け替える |

Network が描く Gain が |T|、Phase が T の位相。**Gain が 0 dB を切る周波数の Phase に 180° を足すと位相余裕**になる。
10 kHz より下を掃かないのは、|T| が大きいほど V<sub>e</sub> が小さく (W1 の 1 / |1 + T|) なり、10 kHz の 2 mV を切ると読みにくくなるため。
振幅を 20 mV にすると、Cp 10 nF の山 (閉じたループで 2.3 倍) でも出力は 2.5 V ± 0.5 V に収まる。

閉じたループの段の応答も見ておく。位相余裕が小さいほど行き過ぎが大きい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 段の応答 (Cp 2.2 nF)。帰還は 19 % 行き過ぎてから落ち着く (計算)
time: 5us/div
trigger: ch1 rising 0V at -4div
ch1: {wave: square 2kHz 5mV, range: 2mV/div}
ch2: {wave: ch1 | lc 85.06kHz 1.069, range: 2mV/div}
cursors: [0, 6.65us]
measure: [vpp, vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/09-phase-margin.svg)

図3 は Cp 2.2 nF の計算値。T の 2 つの極から閉じたループは 2 次の低域 (f<sub>0</sub> = √(90.9 kHz × 79.6 kHz) = 85.1 kHz、
Q = √(90.9 / 79.6) = 1.07) になり、段の 10 mV に対して 1.9 mV (19 %) 行き過ぎる。山はカーソル X2 の 6.65 µs (マイクロ秒)。
CH2 は AC 結合で fb の交流分だけを見たもので、利得 11 倍の出力ではなく帰還点 (1 倍) の波。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ | LM358 (2 回路目はフォロワにして入力を固定) |
| R1, R2 | 抵抗 (1/4 W) | 100 kΩ (+ 入力のバイアス 2.5 V) |
| Cin | 積層セラミックコンデンサ | 1 µF (105) |
| Rf | 抵抗 (1/4 W) | 10 kΩ |
| Rg | 抵抗 (1/4 W) | 1 kΩ |
| Cg | 電解コンデンサ | 10 µF (直流の利得を 1 倍にする) |
| Cp | 積層セラミックコンデンサ | 2.2 nF (222)。比べるときは 10 nF (103) に差し替える |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

計算値。LM358 を GBW 1 MHz の 1 極と仮定 (9-2 と同じ)。T = (90.9 kHz / jf) × 1 / (1 + jf / f<sub>p</sub>)、f<sub>p</sub> = 1 / (2π × 909 Ω × Cp)。

| Cp | f<sub>p</sub> | f<sub>c</sub> (\|T\| = 0 dB) | f<sub>c</sub> での位相 | 位相余裕 | 段の行き過ぎ |
| --- | --- | --- | --- | --- | --- |
| なし | — | 90.9 kHz | −90.0° | 90.0° | 0 % |
| 2.2 nF | 79.6 kHz | 68.8 kHz | −130.8° | 49.2° | 19 % |
| 10 nF | 17.5 kHz | 38.0 kHz | −155.3° | 24.7° | 49 % |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 ループ利得 T (CH2/CH1)。0 dB を切る所の位相と −180° の差が位相余裕 (計算)
x: 周波数 Hz log 10k..1M
y:
  - 利得 dB -40..30
  - 位相 deg -180..-90
lines:
  Cp なし dB: 20*log10(90909/x)
  Cp 2.2 nF dB: 20*log10(90909/x) - 10*log10(1+(x/79577)^2)
  Cp 10 nF dB: 20*log10(90909/x) - 10*log10(1+(x/17507)^2)
  位相 Cp なし deg: -90 + 0*x
  位相 Cp 2.2 nF deg: -90 - atan(x/79577)*180/pi
  位相 Cp 10 nF deg: -90 - atan(x/17507)*180/pi
notes:
  - level 0dB
  - mark 38.0k
  - mark 68.8k
  - mark 90.9k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/graph/09-phase-margin.svg)

- Cp を大きくするほど f<sub>c</sub> が下がり、そこでの位相が −180° に近づく。位相余裕 45° が設計の目安としてよく使われ、
  2.2 nF はそのすぐ上、10 nF は大きく下回る
- 実物の LM358 には 1 MHz より上にも極があり、f<sub>c</sub> = 90.9 kHz でも数度の遅れが足される (目安)。測った位相余裕が
  表より数度小さいのはそのため
- CH1・CH2 の入力容量 (各 24 pF) も fb に付き、Cp に 48 pF ほど足される。2.2 nF に対して 2 % で、f<sub>p</sub> が 2 % 下がる

## LTspice での確かめ

`sim/09-phase-margin.cir` (交流) と `sim/09-phase-margin-step.cir` (段の応答、段 10 mV) で図1 を解き、Cp を 1 pF (無し相当)・2.2 nF・10 nF に替えて走らせた。
オペアンプは 9-2 と同じ 1 極の汎用模型 (GBW 1 MHz、SR 0.3 V/µs)。**仮定で、実測の値ではない**。
T は V(fb) / (V(+ 入力) − V(fb)) を複素数で読み、位相余裕は f<sub>c</sub> での T の実部と虚部の角度から求めた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| f<sub>c</sub> (なし・2.2 nF・10 nF) | 90.9・68.8・38.0 kHz | 90.9・68.8・38.0 kHz | 合う |
| 位相余裕 (なし・2.2 nF・10 nF) | 90.0・49.2・24.7° | 90.0・49.2・24.7° | 合う |
| 20 kHz の \|T\| (2.2 nF) | 4.4 倍 (12.9 dB) | 4.41 倍 | 合う |
| 閉じたループの山 (2.2 nF・10 nF) | 1.20 倍・2.3 倍 | 1.21・2.33 倍 | 合う |
| 段の行き過ぎ (なし・2.2 nF・10 nF) | 0・19・49 % | 0.5・19.5・50.0 % | 合う |

段を 40 mV にすると、10 nF の行き過ぎは 43 % に減った (誤差の電圧が大きく、模型のスルーレートで頭打ちになるため)。
図3 の段を 10 mV にしたのはこのため。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
LM358 の GBW はメーカーの [データシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) の代表値。
参考: [負帰還](https://ja.wikipedia.org/wiki/負帰還)
