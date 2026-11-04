---
book: nanovna
chapter: 8
id: 8-19
title: 広帯域帰還アンプ — 帰還抵抗とエミッタ抵抗で入出力を 50 Ω にそろえる (2N5109・4:1 トランス)
tier: 200
source: 自作
board: PF
device: LV64
---

# 8-19 広帯域帰還アンプ — 帰還抵抗とエミッタ抵抗で入出力を 50 Ω にそろえる (2N5109・4:1 トランス)

> **どれもシミュレーション (LTspice) で出した値で、実機では測っていない。** 2N5109 のモデルは hFE 80・f<sub>T</sub> 1.2 GHz・C<sub>ob</sub> 3 pF
> の目安から作った仮定。トランスの結合係数 (0.995) も仮定で、巻き方で変わる。

無線機の自作でいちばんよく使う増幅段が、この**広帯域帰還アンプ** (feedback amplifier)。1 石のエミッタ接地に、
**コレクタからベースへ戻す帰還抵抗 R<sub>F</sub>** (並列帰還) と、**バイパスしないエミッタ抵抗 R<sub>E1</sub>** (直列帰還) の
2 つの負帰還をかける。すると利得が R<sub>F</sub> と R<sub>E1</sub> で決まるだけでなく、**入力も出力も 50 Ω 近くに**なり、
同調回路なしで 1〜30 MHz が平らになる。受信機のポストミキサーアンプ、VFO のバッファ、送信機のドライバに、
同じ形が値を変えて現れる。この題では 2N5109 (TO-39 の金属缶、無線の自作で定番) で組み、
**S21 が平らなこと、S11 と S22 が 50 Ω に合っていること**を VNA で見る。

## この実験で確かめる式

トランジスタを理想 (g<sub>m</sub> が大きく、β が大きい) とみなすと、ベースから見た入力抵抗と、コレクタから見た出力抵抗は
どちらも R<sub>F</sub> と R<sub>E</sub> の組み合わせで決まる:

- **入力抵抗** R<sub>in</sub> = R<sub>E</sub> (R<sub>F</sub> + R<sub>L</sub>′) / (R<sub>E</sub> + R<sub>L</sub>′)
- **出力抵抗** R<sub>out</sub> = R<sub>E</sub> (R<sub>F</sub> + R<sub>S</sub>) / (R<sub>E</sub> + R<sub>S</sub>)
- **利得** (ベース → コレクタ) A<sub>v</sub> = −(1 / R<sub>E</sub> − 1 / R<sub>F</sub>) / (1 / R<sub>F</sub> + 1 / R<sub>L</sub>′)

R<sub>E</sub> は R<sub>E1</sub> にトランジスタの内部の r<sub>e</sub> (26 mV / I<sub>E</sub>) を足した値、R<sub>S</sub> は信号源 (50 Ω)、
R<sub>L</sub>′ はコレクタが見る負荷。**トランスを使わず 50 Ω をコレクタに直結するなら** R<sub>S</sub> = R<sub>L</sub>′ = 50 Ω で、
入出力を 50 Ω にそろえる条件は **R<sub>F</sub> × R<sub>E</sub> = 50² = 2500 Ω²** というきれいな形になり、利得は約 R<sub>F</sub> / 50 倍
(R<sub>F</sub> 500 Ω なら 20 dB)。

ここでは出力に **4:1 のトランス** (巻数比 2:1。コレクタが見る負荷は 4 × 50 = 200 Ω) を入れる。コレクタの電流の振れが 4 分の 1 で済み、
同じ電源で大きな出力を歪まずに出せるからで、無線機の段間ではこの形が多い。R<sub>L</sub>′ = 200 Ω として数を入れる:

- I<sub>E</sub> ≈ 20 mA にする (R<sub>E2</sub> 47 Ω に約 0.94 V、R<sub>E1</sub> 10 Ω に 0.2 V)。r<sub>e</sub> = 26 mV / 20 mA ≈ 1.3 Ω、R<sub>E</sub> = 11.3 Ω
- R<sub>F</sub> = 750 Ω: R<sub>in</sub> = 11.3 × (750 + 200) / (11.3 + 200) ≈ **51 Ω**。ベースの R<sub>2</sub> (470 Ω) が並列に入って **約 46 Ω**
- R<sub>out</sub> (コレクタ) = 11.3 × (750 + 46) / (11.3 + 46) ≈ 157 Ω。トランスで 4 分の 1 になり **約 39 Ω** (S22 ≈ −19 dB)
- A<sub>v</sub> = −(1 / 11.3 − 1 / 750) / (1 / 750 + 1 / 200) ≈ **−13.8 倍**。トランスで電圧は半分 (6.9 倍)、入力が 46 Ω なので
  ベースには CH0 の波の 0.48 倍 (= 46 / 96) がかかる。**S21 ≈ 2 × 6.9 × 0.48 ≈ 6.6 倍 ≈ 16.4 dB** (計算。LTspice では 15.9 dB)

R<sub>F</sub> はバイアスも兼ねる。トランスの直流抵抗はほぼ 0 なのでコレクタは 5 V で、R<sub>F</sub> と R<sub>2</sub> の分圧がベースを
約 1.86 V に置く (R<sub>F</sub> に 4.2 mA、R<sub>2</sub> に 4.0 mA、ベース電流 0.25 mA)。エミッタは 1.14 V、I<sub>E</sub> ≈ 20 mA。
コレクタの損失は 20 mA × 3.9 V ≈ 77 mW で、TO-39 なら放熱器なしでよい。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2N5109 の広帯域帰還アンプ (RF 750 Ω・RE1 10 Ω、出力は 4:1 の単巻きトランス)
parts:
  J1: sma 2,5 mirror CH0
  GJ1: ground 2,6
  C1: capacitor 3,5 5,5 0.1u
  RF: resistor 5,2 5,5 750
  R2: resistor 6,5 6,8 470
  G2: ground 6,8
  Q1: npn 8,5 2N5109
  RE1: resistor 8,7 8,9 10
  RE2: resistor 8,9 8,11 47
  G3: ground 8,11
  CE: capacitor 10,9 10,11 1u
  T1: transformer 11,4 FT37-43
  VCC: vcc 12,2 5V
  CV: capacitor 13,2 13,4 0.1u
  GV: ground 13,4
  COUT: capacitor 12,6 14,6 0.1u
  J2: sma 15,6 CH1
  GJ2: ground 15,7
wires:
  - J1.1 -- 3,5
  - J1.2 -- 2,6
  - 5,5 -- 6,5
  - 5,2 -- 8,2
  - 8,2 -- 8,4
  - 6,5 -- Q1.B
  - 8,4 -- Q1.C
  - 8,4 -| T1.A1
  - T1.B1 |- 12,2
  - 12,2 -- 13,2
  - T1.A2 -| 11,6
  - T1.B2 -| 11,6
  - 11,6 -- 12,6
  - 14,6 -- J2.1
  - J2.2 -- 15,7
  - Q1.E -- 8,7
  - 8,9 -- 10,9
  - 8,11 -- 10,11
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/19-feedback-amplifier.svg)

- **R<sub>F</sub> (750 Ω) がコレクタからベースへの帰還、R<sub>E1</sub> (10 Ω) がエミッタの帰還**。R<sub>E2</sub> (47 Ω) は直流の動作点を決めるだけで、
  C<sub>E</sub> (1 µF) でバイパスする (2-21 のエミッタ抵抗の分け方と同じ)
- **T1 は 4:1 の単巻き (オート) トランス**。FT37-43 に 2 本の線をそろえて (バイファイラで) 10 回巻き、1 本目の終わりと 2 本目の始まりを
  つないで 20 回の巻線に中点を作る。図では 2 つのコイル (A と B) の下側をつないだ形で描いた。**コレクタが巻線の端 (20 回)、
  +5 V が反対の端、中点 (10 回) から出力**を取る。巻数比 2:1 でインピーダンス比 4:1
- C<sub>V</sub> (0.1 µF) は +5 V の端を高周波で GND に落とす。トランスの +5 V 側が交流の GND になるので、ここが浮くと利得も整合も崩れる
- C<sub>OUT</sub> は中点の直流 (5 V) を切る

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 5x7cm
  h: 1.6mm
  material: FR-4
  slots: on
title: 図2 ユニバーサル基板に組む (部品面。端面 SMA 2 つ)
parts:
  J1: sma/female-edge f1 g0
  C1: capacitor f2 f4 100n
  RF: resistor d4 d7 750
  R2: resistor f5 i5 470
  Q1: transistor g8 f7 e8 2N5109
  RE1: resistor h8 j8 10
  RE2: resistor k9 n9 47
  CE: capacitor k11 m11 1u
  T1: transformer/toroid d12 f12 f14 d14 FT37-43 10t:10t
  CV: capacitor c16 e16 100n
  COUT: capacitor g15 g17 100n
  J2: sma/female-edge g18 h19
  PSU:
    type: device
    at: -c17
    label: 電源 5V (USB)
    pins: + -
wires:
  - f1 -- f2
  - f4 -- f5
  - f5 -- f7
  - d4 -- f4
  - d7 -- d8
  - e8 -- d8
  - d8 -- d10
  - d10 -- c10
  - c10 -- c12
  - c12 -- d12
  - f12 -- g12
  - g12 -- g14
  - g14 -- f14
  - g14 -- g15
  - g17 -- g18
  - d14 -- c14 red
  - c14 -- b14 red
  - b14 -- b16 red
  - b16 -- b17 red
  - b16 -- c16 red
  - PSU.+ -- a17 red
  - a17 -- b17 red
  - PSU.- -- a18 black
  - a18 -- d18 black
  - d18 -- e18 black
  - e16 -- e18 black
  - e18 -- f18 black
  - f18 -- f19 black
  - g8 -- h8
  - j8 -- j9
  - j9 -- k9
  - j9 -- j11
  - j11 -- k11
  - n9 -- o9 black
  - m11 -- o11 black
  - i5 -- o5 black
  - g0 -- g1 black
  - g1 -- o1 black
  - o1 -- o5 black
  - o5 -- o9 black
  - o9 -- o11 black
  - o11 -- o18 black
  - h19 -- h18 black
  - h18 -- o18 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/19-feedback-amplifier.svg)

- 信号は左の SMA (CH0) から右の SMA (CH1) へ。**端面 SMA の 2 本の腕 (`g0`・`f19`・`h19` など) は GND** で、基板の縁の銅箔に半田付けする
- **TO-39 の 2N5109 は E と C が向かい合い (0.2 インチ)、B がその間から直角に出る**。Q1 は `g8` (E)・`f7` (B)・`e8` (C) の
  L の字に挿す (型番を書くと E・B・C の順に穴を当てる)。出っ張り (タブ) の隣が E。**缶がどのピンとつながっているかは資料に
  書かれていないので、組む前にテスタで確かめ**、缶が触れそうな所に線を通さない
- **T1 はトロイダルを立てて 4 本のリードを 2 × 2 の穴に挿す**。`d12`・`f12` が 1 本目の線 (A)、`f14`・`d14` が 2 本目 (B)。
  バイファイラで巻いたら、1 本目の終わり (`f12`) と 2 本目の始まり (`f14`) を行 G の線でつなぐ — これが中点で、ここから `COUT` へ。
  コレクタは `d12` (巻線の端)、+5 V は `d14` (反対の端)
- +5 V の筋は上 (行 B)、GND の筋は下 (行 O)。C<sub>V</sub> は +5 V の筋の右端から SMA の腕 (GND) へ最短で落とす
- 10 MHz を超えて測るので**ユニバーサル基板**に組む (ブレッドボードの範囲 3 MHz を超える)。30 MHz までなら、リード部品と短い線で
  ユニバーサル基板の範囲 (10 MHz までが目安) をやや超えるが、GND の筋を太く短く取れば傾向は見える。
  50 MHz より上を本気で測るなら銅張り基板 (9-3)

## 掃引の設定

計器は VNA (LiteVNA64)。S パラメータを見る題なので AD3 とオシロは使わない。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz (平らな所から、落ち始めまで) |
| 点数 | 201 |
| 校正 | SOLT。**CH0 に 20 dB の SMA アッテネータを付けたまま**校正する (THRU も) |
| 表示 | S21 の LOGMAG と S11 の LOGMAG。S22 は基板を裏返して S11 として測る (8-2 と同じ) |

**CH0 にアッテネータを付ける理由**: VNA の出力 (0 dBm より小さい。0-3) をそのまま入れると、利得 16 dB でアンプの出力が
+9 dBm ほどになり、コレクタの振れの上限 (約 +15 dBm) に近い。20 dB 落として −27 dBm で入れれば出力は −11 dBm で、
アンプは小信号のまま、CH1 の上限 (0-3) にも遠い。アッテネータは校正に含めるので S21 の読みは変わらない。

図3 は入力側 (S11) を等価回路で計算した画面。帰還で決まる約 51 Ω と R<sub>2</sub> (470 Ω) の並列に、
ベースの入力容量 (C<sub>ob</sub> のミラー効果で約 40 pF) を並列に置いた。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: litevna64
sweep: 1M-100M 201
title: 図3 入力の S11 (等価回路で計算) — 30 MHz までは −12 dB より下、Smith の中心の近く
dut:
  - shunt C 40p
  - shunt R 470
  - shunt R 51
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1M
  - 7M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/19-feedback-amplifier.svg)

- 1〜10 MHz では S11 が −20 dB より下 (反射 1 % 以下)、Smith の点は中心 (50 Ω) のすぐ近く。**帰還が入力を 50 Ω に合わせている**
- 30 MHz では入力容量 (40 pF で 130 Ω) が効いて −13 dB ほどに上がる。LTspice の S11 (下の表) と同じ傾向
- S21 は利得があるので `dut:` では描けない。下の図4 に LTspice で計算した線を置く

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 S21・S11・S22 (LTspice で計算)
x: 周波数 Hz log 1M..100M
y:
  - dB
lines:
  S21 dB:
    - 1M 15.88
    - 1.5M 15.90
    - 2M 15.91
    - 3M 15.92
    - 3.5M 15.92
    - 5M 15.92
    - 7M 15.91
    - 10M 15.90
    - 14M 15.87
    - 21M 15.82
    - 30M 15.70
    - 50M 15.31
    - 70M 14.70
    - 100M 13.42
  S11 dB:
    - 1M -19.96
    - 1.5M -21.7
    - 2M -22.5
    - 3M -23.0
    - 3.5M -23.0
    - 5M -22.6
    - 7M -21.7
    - 10M -20.1
    - 14M -18.2
    - 21M -15.3
    - 30M -12.6
    - 50M -8.7
    - 70M -6.3
    - 100M -4.3
  S22 dB:
    - 1M -17.7
    - 1.5M -19.2
    - 2M -19.9
    - 3M -20.4
    - 3.5M -20.5
    - 5M -20.5
    - 7M -20.4
    - 10M -20.0
    - 14M -19.3
    - 21M -17.8
    - 30M -15.9
    - 50M -12.2
    - 70M -9.3
    - 100M -6.2
notes:
  - level 15.9dB
  - level -15dB
  - mark 3.5M
  - mark 30M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/graph/19-feedback-amplifier.svg)

- **S21 は 1〜30 MHz で 15.7〜15.9 dB** (0.2 dB の中)。−3 dB は 110 MHz (計算)。2N5109 の f<sub>T</sub> (1.2 GHz) が高いので、
  落ち始めはトランスの漏れインダクタンスと C<sub>ob</sub> のミラー効果で決まる
- **S11 は 1〜14 MHz で −18 dB より下、S22 は 1〜30 MHz で −16 dB より下**。入力は R<sub>2</sub> とミラー容量、出力はトランスの
  漏れで、上に行くほど合わなくなる
- 1 MHz で S11 が少し上がる (−20 dB) のは、トランスの励磁インダクタンス (10 回 + 10 回で 140 µH、1 MHz で 880 Ω) が負荷 200 Ω に
  並列に入って R<sub>L</sub>′ が変わるため。巻数を増やせば下がる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN 高周波トランジスタ (TO-39) | 2N5109 (缶がどのピンとつながるかは資料に無い。テスタで確かめる) |
| RF | 抵抗 (1/4 W) | 750 Ω (帰還抵抗。バイアスも兼ねる) |
| R2 | 抵抗 (1/4 W) | 470 Ω |
| RE1 | 抵抗 (1/4 W) | 10 Ω (バイパスしないエミッタ抵抗) |
| RE2 | 抵抗 (1/4 W) | 47 Ω (CE でバイパス。直流の動作点を決める) |
| C1, COUT, CV | 積層セラミックコンデンサ | 0.1 µF |
| CE | 積層セラミックコンデンサ | 1 µF |
| T1 | トロイダルコア FT37-43 | バイファイラ 10 回 (#28 のポリウレタン線 2 本を並べて巻く)。1 本目の終わりと 2 本目の始まりをつなぐ |
| J1, J2 | SMA コネクタ (端面実装) | — |
| — | 電源 | 5 V (USB アダプタ。約 25 mA) |

2N5109 のデータシートは `datasheets.md`。手に入らなければ 2N3866 (同じ TO-39、同じピンの並び) でも組める。

## 見るべき値

直流はテスターで。S パラメータは VNA で。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.86 V | RF と R2 の分圧 |
| エミッタ電圧 (RE1 の上) | 約 1.14 V | IE ≈ 1.14 V / 57 Ω ≈ 20 mA |
| コレクタ電圧 | 約 5.0 V | トランスの直流抵抗はほぼ 0 |
| S21 (1〜30 MHz) | 約 +16 dB、平ら | 利得は RF と RE1 で決まる (同調回路なし) |
| S11 (1〜14 MHz) | −18 dB より下 | 入力が 50 Ω に合っている |
| S22 (1〜30 MHz、裏返して測る) | −16 dB より下 | 出力も 50 Ω に合っている |

計算値 (LTspice):

| 周波数 | S21 | S11 | S22 |
| --- | --- | --- | --- |
| 1 MHz | +15.9 dB | −20.0 dB | −17.7 dB |
| 3.5 MHz | +15.9 dB | −23.0 dB | −20.5 dB |
| 7 MHz | +15.9 dB | −21.7 dB | −20.4 dB |
| 14 MHz | +15.9 dB | −18.2 dB | −19.3 dB |
| 30 MHz | +15.7 dB | −12.6 dB | −15.9 dB |

**何を変えると何が動くか**: R<sub>F</sub> を上げると利得が上がり、入力抵抗も上がる (R<sub>F</sub> × R<sub>E</sub> の積で整合が決まる)。
R<sub>E1</sub> を上げると利得が下がり、入力抵抗は上がる。利得を変えたいときは、積を保ったまま 2 本を一緒に動かす。
トランスを 1:1 (50 Ω 直結) にすると、R<sub>F</sub> 500 Ω・R<sub>E</sub> 5 Ω が 50 Ω の整合点で、利得は 20 dB。

## LTspice での確かめ

`sim/19-feedback-amplifier.cir` で図1 を `.ac` にかけ、S21 (= V(out)、信号源を 2 V にして入射波を 1 にした) と S11 (= V(in) − 1) を
読んだ。S22 は `sim/19-feedback-amplifier-s22.cir` (信号源を出力側に置いて同じ計算)、動作点は `sim/19-feedback-amplifier-op.cir`。
2N5109 のモデルは hFE 80・f<sub>T</sub> 約 1.2 GHz・C<sub>ob</sub> 3 pF の目安から作った仮定、T1 は 35 µH + 35 µH・結合 0.995 の仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ベース電圧 | 約 1.86 V | 1.856 V | 合う |
| エミッタ電圧 | 約 1.14 V | 1.138 V | 合う |
| エミッタ電流 | 約 20 mA | 19.96 mA | 合う |
| R<sub>F</sub> の電流 | 約 4.2 mA | 4.19 mA | 合う |
| 入力抵抗 (1 MHz) | 約 46 Ω | 45.9 Ω | 合う |
| 出力抵抗 (1 MHz、トランスの後) | 約 39 Ω | 41.0 Ω | 合う |
| S21 (1 MHz) | 約 16.4 dB (計算) | 15.9 dB | 近い (理想のトランジスタの式。β 80 と r<sub>bb′</sub> で 0.5 dB 下がる) |
| S21 の −3 dB | — | 110 MHz | 図4 のとおり |
| S11 (3.5 MHz) | −20 dB より下 | −23.0 dB | 合う |
| S22 (3.5 MHz) | −19 dB (計算) | −20.5 dB | 合う |

図3 の等価回路 (40 pF ∥ 470 Ω ∥ 51 Ω) は 1 MHz で −27 dB になり、LTspice の −20 dB より良く出る。1 MHz の違いはトランスの励磁インダクタンス
(等価回路に入れていない) のぶんで、3.5〜30 MHz では両者が 1 dB の中で合う。

## 出典

自作。帰還アンプの式は、並列帰還と直列帰還を掛け合わせた 1 段増幅の標準的な解析 (理想のトランジスタで y パラメータを解いたもの)。
この形の増幅段は、アマチュア無線の設計書で "feedback amplifier" と呼ばれ、R<sub>F</sub> × R<sub>E</sub> = Z<sub>0</sub>² の整合条件で知られる。

参考: [Negative-feedback amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Negative-feedback_amplifier)、[2N5109 のデータシート (Advanced Power Technology)](https://www.electrokit.com/upload/product/40325/40325109/2N5109_REV.pdf)
