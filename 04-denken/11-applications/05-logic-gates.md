---
book: denken
chapter: 11
id: 11-5
title: 論理回路 — AND・OR・NOT と真理値表
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 11-5 論理回路 — AND・OR・NOT と真理値表

電圧の高い・低いを 1 と 0 に読み替えると、スイッチの組み合わせで決まる出力を式で書ける。
その基本が AND (論理積)・OR (論理和)・NOT (否定) の 3 つ。2 つのスイッチ A・B を 3 つのゲートに
同時に入れ、LED の点き方で**真理値表**を 1 行ずつ埋める。出力の電圧は AD の Voltmeter で読み、
1 と 0 がそれぞれ何 V かも確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Y = A · B | AND。A と B の両方が 1 のときだけ 1 |
| Y = A + B | OR。A と B のどちらか (か両方) が 1 なら 1 |
| Y = Ā | NOT。A を反転する |
| 1 = 5 V 近く、0 = 0 V 近く | 74HC シリーズ (電源 5 V) の出力。入力は 3.5 V 以上を 1、1.5 V 以下を 0 と読む |

## 回路図

```circuit
title: 図1 AND・OR・NOT に同じ入力を入れる
style:
  standard: jis
  pitch: 1.4
parts:
  VCC: vcc a1
  SA: switch a1 c1
  RA: resistor c1 e1 10k
  GA: ground e1
  VCC: vcc g1
  SB: switch g1 j1
  RB: resistor j1 l1 10k
  GB: ground l1
  U3: not c7 74HC04
  U1: and f7 74HC08
  U2: or i7 74HC32
  R3: resistor c9 c11 1k
  D3: led c11 c13
  G3: ground c13
  R1: resistor f9 f11 1k
  D1: led f11 f13
  G1: ground f13
  R2: resistor i9 i11 1k
  D2: led i11 i13
  G2: ground i13
wires:
  - c1 -- c3 -- U3.in
  - U1.a -| c3
  - U2.a -| c3
  - j1 -- j5
  - U2.b -| j5
  - U1.b -| j5
  - U3.out -- c9
  - U1.out -- f9
  - U2.out -- i9
notes:
  - text b2 blue: A
  - text i2 blue: B
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/circuit/05-logic-gates.svg)

- SA・SB が入力のスイッチ。閉じると VCC (5 V) につながって 1、開くとプルダウン抵抗 RA・RB (10 kΩ) で
  0 V に落ちて 0。CMOS の入力は浮かせると 1 とも 0 ともつかず揺れるので、開いている間も抵抗で 0 に決めておく
- U1 (74HC08) が AND、U2 (74HC32) が OR、U3 (74HC04) が NOT。A は 3 つに、B は AND と OR に入れる
- 出力が 1 なら R (1 kΩ) を通って LED が点く。電流は (4.8 V − 1.9 V) ÷ 1 kΩ ≒ 3 mA (目安)。
  74HC の出力は 4 mA までなら電圧をほぼ保つ
- 論理記号の図では IC の電源の足 (14 番が VCC、7 番が GND) を省く。実体配線図には描いてある

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  SA: switch a3 a5
  RA: resistor c5 c8 10k
  SB: switch a10 a12
  RB: resistor c12 c15 10k
  U1: dip14 @ e18 74HC08
  U2: dip14 @ e33 74HC32
  U3: dip14 @ e48 74HC04
  R1: resistor j25 j29 1k
  D1: led f29(A) f31(K) red
  R2: resistor j40 j44 1k
  D2: led f44(A) f46(K) red
  R3: resistor j55 j59 1k
  D3: led f59(A) f61(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+]
wires:
  - AD.V+ -- +b4 red
  - AD.GND -- -b6 black
  - AD.1+ -- j20 white
  - AD.1- -- -b12 black
  - +b63 -- +t63 red
  - -b62 -- -t62 black
  - +t3 -- b3 red
  - a8 -- -t8 black
  - +t10 -- b10 red
  - a15 -- -t15 black
  - e5 -- f5 yellow
  - e12 -- f12 green
  - h5 -- h18 -- h33 -- h48 yellow
  - i12 -- i19 -- i34 green
  - a18 -- +t18 red
  - a33 -- +t33 red
  - a48 -- +t48 red
  - g20 -- g25 orange
  - g35 -- g40 orange
  - g49 -- g55 orange
  - j31 -- -b31 black
  - j46 -- -b46 black
  - j61 -- -b61 black
  # 使わない入力と GND の足 (上は上の青レール、下は下の青レール)
  - a19 -- -t19 black
  - a20 -- -t20 black
  - a22 -- -t22 black
  - a23 -- -t23 black
  - j21 -- -b21 black
  - j22 -- -b22 black
  - j24 -- -b24 black
  - a34 -- -t34 black
  - a35 -- -t35 black
  - a37 -- -t37 black
  - a38 -- -t38 black
  - j36 -- -b36 black
  - j37 -- -b37 black
  - j39 -- -b39 black
  - a49 -- -t49 black
  - a51 -- -t51 black
  - a53 -- -t53 black
  - j50 -- -b50 black
  - j52 -- -b52 black
  - j54 -- -b54 black
notes:
  - text small: 各 IC の 1 番のゲートを使う (74HC04 は 1 番が入力、2 番が出力)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/breadboard/05-logic-gates.svg)

- AD を下に置き、Supplies の V+ (5 V) を下の赤いレール、GND を下の青いレールに入れる。
  右端の 62・63 列の線で、上下の赤どうし・青どうしをつなぐ
- 左上が入力。SA (3〜5 列) と SB (10〜12 列) は赤いレールと入力の列の間。RA・RB が青いレールへ落とす
  プルダウン。A (5 列) は黄、B (12 列) は緑の線で溝を越え、h 行と i 行を右へ運ぶ
- IC は切り欠きを左にして溝をまたぐ。1 番の足が左下 (U1 なら f18)、14 番が左上 (e18)。
  使うのは各 IC の 1 番のゲートで、74HC08・74HC32 は 1・2 番が入力、3 番が出力、74HC04 は 1 番が入力、2 番が出力
- 14 番 (VCC) は赤い線で上の赤いレールへ、7 番 (GND) は黒い線で下の青いレールへ。**使わない入力は
  すべて GND へ** (上の段の足は上の青いレール、下の段の足は下の青いレール)。使わない出力は何もつながない
- 出力 (橙の線) の先に R (j 行) と LED (f 行)。LED の陰極 (K) は黒い線で下の青いレールへ
- 1+ (白) は AND の出力 (20 列) に挿してある。OR は 35 列、NOT は 49 列の空いた穴に挿し替えて読む。1− は GND

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。電流は LED 2 つとプルダウン 2 本で最大 7 mA ほど (35 mW) |
| Voltmeter | CH1 = DC。1+ を読みたい出力の列へ挿し替える |

AD の Patterns (DIO) で A・B を作り、Logic で出力を並べて見ることもできる。そのときは DIO の 3.3 V が
74HC の 1 の下限 (3.5 V) に届かないので、IC を入力の 1 の下限が 2.0 V の **74HCT08・74HCT32・74HCT04**
(足の並びは同じ) に替える。

### オシロスコープと発振器

この題に波形は無い。AD の Supplies (V+) は安定化電源の 5 V に替え、電流制限は 20 mA にする
([回路の本の 0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この回路は最大 7 mA ほどで、
20 mA に届くなら IC の向きか配線の誤り)。出力の電圧はテスターの DC で読む。オシロで読むなら、CH1 の
先端を出力の列、グランドクリップを GND のレールに当て、Measure の Mean で読む
([0-3](../../01-circuits/00-measure/03-oscilloscope.md))。GND 基準なので測り方は変わらない。

## 見るべき値

真理値表。出力の電圧は、74HC の出力に LED の電流 (約 3 mA) が流れたときの目安。

| A (SA) | B (SB) | AND (D1) | OR (D2) | NOT A (D3) |
| --- | --- | --- | --- | --- |
| 0 (開く) | 0 (開く) | 0 (消える、0 V) | 0 (消える、0 V) | 1 (点く、約 4.8 V) |
| 0 (開く) | 1 (閉じる) | 0 (消える、0 V) | 1 (点く、約 4.8 V) | 1 (点く、約 4.8 V) |
| 1 (閉じる) | 0 (開く) | 0 (消える、0 V) | 1 (点く、約 4.8 V) | 0 (消える、0 V) |
| 1 (閉じる) | 1 (閉じる) | 1 (点く、約 4.8 V) | 1 (点く、約 4.8 V) | 0 (消える、0 V) |

分かること:

- **AND は 4 行のうち 1 行だけ 1、OR は 1 行だけ 0。** 真理値表の形で見分けられる
- NOT は B に関係しない。A の列をそのまま反転した列になる
- 1 の電圧は 5 V ちょうどではなく、出力の電流の分だけ下がる (約 4.8 V)。それでも次のゲートの入力の
  1 の下限 (3.5 V) より十分高い。**0 と 1 の間に余裕を取ってあるので、少しの電圧の違いでは読み違えない**
- 3 つを組み合わせると、どんな真理値表も作れる。たとえば AND の出力を NOT に通すと NAND
  (A · B の否定)。ド・モルガンの定理 (A · B の否定 = Ā + B̄) は、この板に NOT をもう 1 つ足して確かめられる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Voltmeter の節)。
