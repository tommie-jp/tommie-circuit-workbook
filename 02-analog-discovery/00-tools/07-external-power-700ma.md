---
book: analog-discovery
chapter: 0
id: 0-7
title: 外部電源で電源ツールを 700 mA まで使う
tier: 200
source: 自作 (電源の上限は Digilent の Analog Discovery 3 の公式資料)
board: BB
---

# 0-7 外部電源で電源ツールを 700 mA まで使う

Analog Discovery 3 (AD3) の Supplies (電源) は、USB だけで給電すると AD3 全体で 5.5 W までしか使えない。
AD3 は計器を動かしていないときでも USB から最大 700 mA (約 3.5 W) を取るので、Supplies に回せるのは
残りの約 2 W が目安になる。背面の DC ジャックに 5 V の外部電源 (AC アダプタ) をつなぐと、
**1 系統あたり 800 mA か 2.4 W の、先に当たるほう**まで出せる。

この題では外部電源をつなぎ、V+ に 4.7 Ω (オーム) の負荷を付けて電圧を 3 段に上げ、約 700 mA まで流す。
700 mA は Analog Discovery 2 (AD2) の外部電源のときの上限でもあるので、どちらの機種でも同じ手順で試せる。
**電流は 2.4 W の上限でも決まる**ので、5 V では 480 mA しか出せないことも確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 V+ にシャント 0.1 Ω と負荷 4.7 Ω を直列につなぐ
parts:
  V1: vsource 1,2 1,4 3.3
  R1: resistor 2,2 4,2 0.1
  M2: voltmeter 2,1 4,1 l=$\mathrm{CH2}$
  R2: resistor 5,2 5,4 4.7
  M1: voltmeter 7,2 7,4 l=$\mathrm{CH1}$
  G1: ground 1,4
wires:
  - 1,2 -- 2,2
  - 2,1 -- 2,2
  - 4,1 -- 4,2
  - 4,2 -- 5,2 -- 7,2
  - 1,4 -- 5,4 -- 7,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/07-external-power-700ma.svg)

- V1 は AD3 の V+ (Supplies の Positive Supply)。図の 3.3 V は最後の段の値
- R1 (0.1 Ω) は電流を読むためのシャント。CH2 を差動 (2+ を V+ 側、2− を負荷側) にして、
  R1 の両端の電圧から電流を出す (I = V ÷ 0.1 Ω)。差動入力の使い方は 0-1
- R2 (4.7 Ω) が負荷。CH1 で負荷の両端の電圧を読む

AD3 の Supplies が読み返すのは**ホスト (USB か外部電源) から取る電圧と電流**と各系統の出力電圧で、
系統ごとの出力電流は出ない (Reference Manual の Power Supplies の節)。そこでシャントで測る。

## 実体配線図

この題は実体配線図を付けない — 700 mA はブレッドボードの範囲 (1 穴 200 mA・基板全体 500 mA) を超えるので、
基板に載せず、R1 と R2 を 2 極の端子台 2 個に締めて、AD3 の付属ワイヤを直に挿す (つなぎ方は図1 のとおり)。

- V+ (赤) → 端子台 A の 1 番 → R1 → 端子台 A の 2 番 → R2 → 端子台 B → GND (黒)
- CH2 の 2+ を端子台 A の 1 番、2− を 2 番に。CH1 の 1+ を端子台 A の 2 番、1− を GND に
- R2 は 5 W のセメント抵抗で、2.2 W を出すと表面は手で触れないほど熱くなる。机から浮かせ、測る間だけ電源を入れる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 外部電源 | 5 V、4 A 推奨 (最低 3.1 A)、プラグ 5.5 mm × 2.1 mm のセンタープラス。USB を挿す前につなぐ |
| Supplies | Max Power は Auto (外部電源を見つけると上限が上がる)。V+ を 1.0 V → 2.0 V → 3.3 V と上げる。V− は使わない。Master Enable は配線を済ませてから入れる |
| Scope (CH1・CH2) | DC。CH1 は Range 5 V 程度、CH2 は 200 mV 程度 (シャントの 69 mV を読むため)。Measurements に CH1・CH2 の Average |

この題はオシロの図を付けない — 見るのは直流の電圧だけで、時間で変わらないため、Average の読み値で足りる。

**4.7 Ω のまま 3.3 V より上に上げない。** 5 V にすると 1.04 A・5.2 W になり、2.4 W の上限を大きく超える。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| R1 | 抵抗 | 0.1 Ω、1/4 W | シャント。最大 0.69 A で 47 mW (定格の半分の 125 mW 以下) |
| R2 | セメント抵抗 | 4.7 Ω、5 W | 負荷。最大 2.22 W (定格の半分の 2.5 W 以下) |
| — | 端子台 | 2 極 × 2 | ブレッドボードの代わり (上の理由) |
| — | AC アダプタ | 5 V、4 A | AD3 の補助電源。プラグ 5.5 × 2.1 mm、センタープラス |

## 見るべき値

電流 I = V+ ÷ (0.1 Ω + 4.7 Ω) = V+ ÷ 4.8 Ω (計算値。配線と端子台の抵抗は無視する)。

| V+ の設定 | CH2 (シャント) | 電流 | CH1 (負荷) | V+ が出す電力 | 分かること |
| --- | --- | --- | --- | --- | --- |
| 1.0 V | 20.8 mV | 208 mA | 0.979 V | 0.21 W | USB だけでも出る |
| 2.0 V | 41.7 mV | 417 mA | 1.96 V | 0.83 W | USB だけでも出る範囲 (約 2 W の目安の内側) |
| 3.3 V | 68.8 mV | **688 mA** | 3.23 V | **2.27 W** | USB の目安 (約 2 W) を超えるので外部電源が要る。2.4 W の上限の 95 % |

- 3.3 V の段で、Supplies の画面のホストの電流が外部電源の側で増えるのを見る (読み値は電源の効率で変わるので数は決めない)
- 外部電源を外して USB だけで 3.3 V の段を試すと、Max Power の上限に当たって出力が落ちるか、電源が切れるはず
  (どちらになるかは実機で未確認。AD3 を壊さないよう、試すときは 1 回だけ短く)
- CH1 + CH2 の和が V+ の設定より少し低ければ、ワイヤと端子台の電圧降下 (数十 mΩ × 0.69 A で数十 mV)

1 系統が出せる電流の上限は、800 mA と 2.4 W ÷ V+ の小さいほう。2.4 W ÷ 800 mA = 3.0 V より上では電力の上限が先に当たり、
5 V では 480 mA になる。700 mA を出せるのは V+ が 2.4 W ÷ 0.7 A = 3.43 V 以下のとき。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図2 1 系統の電流の上限 (外部電源) — 3 V までは 800 mA、5 V では 480 mA
x: V+ の設定 V 0.5..5
y: 電流 mA 0..900
lines:
  外部電源の上限 mA: min(800, 2.4/x*1000)
  4.7 Ω + 0.1 Ω の負荷 mA: x/4.8*1000
notes:
  - mark 1
  - mark 2
  - mark 3.3
  - mark 5
  - level 700mA
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/graph/07-external-power-700ma.svg)

負荷の線 (V+ ÷ 4.8 Ω) は 3.3 V で 688 mA、上限の線の下にある。2 本が交わる 3.39 V (= √(2.4 W × 4.8 Ω)) より上では、
この負荷は上限を超える。

## LTspice での確かめ (対象外)

抵抗 2 本の直流の算術で確かめた。I = V+ / 4.8 Ω で 1.0・2.0・3.3 V は 208・417・688 mA。シャントの電圧は I × 0.1 Ω で
20.8・41.7・68.8 mV、負荷の電圧は I × 4.7 Ω で 0.979・1.96・3.23 V。V+ の電力は V+ × I で 0.21・0.83・2.27 W、
R2 の電力は I² × 4.7 Ω で 3.3 V のとき 2.22 W、R1 は 47 mW。上限は min(800 mA, 2.4 W / V+) で、3.0 V で 800 mA、
5 V で 480 mA、負荷の線と交わるのは √(2.4 × 4.8) = 3.39 V。本文の値と合う。

## 出典

自作。電源の数字 (USB で全体 5.5 W、待機で最大 700 mA・約 3.5 W、外部電源で 1 系統 800 mA・2.4 W、
補助電源 5 V・4 A 推奨・最低 3.1 A、5.5 mm × 2.1 mm のセンタープラス、読み返しはホストの電圧と電流) は Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Power Supplies の節) と
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Programmable Power Supply・Power Requirements の節) による。USB の残りの約 2 W は、この 2 つの数の差から出した目安。
AD2 の 700 mA は AD2 の公式の仕様の数で、ここでは確かめていない。
