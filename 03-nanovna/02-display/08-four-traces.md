---
book: nanovna
chapter: 2
id: 2-8
title: 4 トレースの割り当て (S11 / S21 × 形式)
tier: 100
source: 自作 (既定の割り当てとメニューの名前は NanoVNA-D (DiSlord 版) のファームウェア)
board: —
device: H4
---

# 2-8 4 トレースの割り当て (S11 / S21 × 形式)

NanoVNA の画面には**トレースが 4 本**ある。1 本ごとに「どちらの測定 (S11 か S21) を、
どの形式で描くか」を決める。測る物に合わせて割り当てを変え、使わないトレースは
消すと、画面が読みやすくなる。フィルタ (2 ポート) とアンテナ (1 ポート) で
割り当てを変えてみる。

## トレースと CHANNEL

| 画面の言葉 | 意味 |
| --- | --- |
| S11 (REFL) | CH0 から出て CH0 に戻った反射 |
| S21 (THRU) | CH0 から出て DUT を通り CH1 に届いた分 |
| FORMAT | 形式 (LOGMAG・PHASE・SMITH・SWR・R・X・POLAR・LINEAR など、2-1・2-6) |

既定の割り当て (設定を初期化したとき)。

| トレース | 色 | CHANNEL | FORMAT |
| --- | --- | --- | --- |
| 1 | 黄 | S11 (REFL) | LOGMAG |
| 2 | 水色 | S21 (THRU) | LOGMAG |
| 3 | 緑 | S11 (REFL) | SMITH |
| 4 | 紫 | S21 (THRU) | PHASE |

## 変え方

| # | 操作 | 中身 |
| --- | --- | --- |
| 1 | DISPLAY → TRACE でトレースを選ぶ | 選んだトレースが以下の操作の対象になる。もう一度押すと消える (表示の入り切り) |
| 2 | DISPLAY → FORMAT S11 (REFL) か FORMAT S21 (THRU) で形式を選ぶ | 選んだ側の CHANNEL と形式が一緒に決まる |
| 3 | DISPLAY → CHANNEL で S11 (REFL) / S21 (THRU) を切り替える | 形式はそのままで S11 と S21 を入れ替える (両方にある形式のときだけ) |
| 4 | DISPLAY → SCALE で目盛と基準の位置を合わせる | 見たい変化が格子の半分以上を占めるように |
| 5 | CONFIG → SAVE CONFIG か、校正と一緒にスロットへ保存 (1-6) | 電源を切っても割り当てが残る |

**形式によって、描ける S が決まっている。** SWR・R (RESISTANCE)・X (REACTANCE)・|Z| は
反射 (S11) だけの形式で、FORMAT S21 (THRU) のメニューには無い。SMITH は S21 にも出せるが、
S21 の Smith は通過の係数を描いたもので読み方が違うので、この教科書では S11 にだけ使う。

## 回路図

フィルタの例は 2-2 と同じ 3 次 LC ローパス (68 pF・180 nH・68 pF)。

```circuit
title: 図1 CH0 と CH1 の間に 3 次 LC ローパス
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 68p
  L1: inductor b5 b7 180n
  C2: capacitor b8 d8 68p
  J2: sma b10 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d8
  G4: ground c10
wires:
  - J1.1 -- b4 -- b5
  - b7 -- b8 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/08-four-traces.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の 3 次 LC ローパス (端面 SMA 2 つ)
points:
  GND: l2
parts:
  J1: sma/female-edge i1 h0 j0
  C1: capacitor i3 l3 68p
  L1: inductor i5 i9 180n
  C2: capacitor i13 l13 68p
  J2: sma/female-edge i24 j25
wires:
  - i1 -- i3
  - i3 -- i5
  - i9 -- i13
  - i13 -- i24
  - l3 -- GND black
  - l3 -- l13 black
  - l13 -- l15 black
  - l15 -- j15 black
  - j15 -- j25 black
  - j0 -- j2 black
  - j2 -- GND black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/perfboard/08-four-traces.svg)

J1 に CH0、J2 に CH1 のケーブルをつなぐ。C1・C2 (68 pF) は中心導体から GND へ立てる。L1 (180 nH) は C1 と C2 の間に横にはさむ。
ユニバーサル基板に流れる電流は、NanoVNA の出力が 0 dBm 以下なので数 mA 以下で、ユニバーサル基板の範囲 (1 穴 200 mA) に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 図 3 (フィルタ) | 図 4 (アンテナ) |
| --- | --- | --- |
| 範囲 | 1 MHz〜200 MHz | 100 MHz〜180 MHz |
| 点数 | 201 | 161 |
| 校正 | SOLT (S11 と S21 の両方) | SOL (S11 だけ使うので Thru は無くてもよい) |
| トレース | 既定の 4 本のまま | 1 = S11 SWR、2 = S11 X、3・4 は消す |

**フィルタ (2 ポート) は既定の 4 本がそのまま役に立つ。** 通過 (S21 LOGMAG)、
反射 (S11 LOGMAG)、整合 (S11 SMITH)、位相 (S21 PHASE) が 1 画面に揃う。
この図は 4 本の割り当てそのものを見せるため、4 本を 1 枚に描いた。

```vna
device: h4
sweep: 1M-200M 201
title: 図3 既定の 4 トレースで LC ローパスを見る
dut:
  - shunt C 68p
  - series L 180n
  - shunt C 68p
traces:
  - S11 logmag
  - S21 logmag
  - S11 smith
  - S21 phase
markers:
  - 30M
  - 69M
  - 150M
notes:
  - text 72M -40dB: 印 2 (69 MHz) で S21 も S11 も約 −3 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/08-four-traces-1.svg)

- 同じ単位のトレース (1 本目の S11 LOGMAG と 2 本目の S21 LOGMAG) は 1 つの枠に重なる。
  実機は 4 本を 1 つの格子に重ねて描き、目盛はトレースごとに SCALE で決める
- 色は書いた順 (黄・水色・緑・紫) で、実機の 1〜4 本目と同じ

**アンテナ (1 ポート) では S21 のトレースは意味が無い** (CH1 に何もつながない)。
2 本を S11 の SWR と X に割り当て、残りの 2 本は消す。アンテナは 2-1 と同じ直列共振の
等価回路 (R 35 Ω・L 220 nH・C 6.2 pF、先を短絡)。

```vna
device: h4
sweep: 100M-180M 161
title: 図4 アンテナは S11 の SWR と X の 2 本に絞る
dut:
  - series R 35
  - series L 220n
  - series C 6.2p
  - short
traces:
  - S11 swr
  - S11 x
markers:
  - 136M
notes:
  - text 124M 6: SWR の谷と X = 0 が同じ周波数
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/08-four-traces-2.svg)

- SWR の谷 (1.43) と X の 0 の交わり (−0.8 Ω) が同じ 136 MHz に来る。**共振の周波数は X、
  整合の良さは SWR** で読む (7-1)
- S21 のトレースを残したままにすると、CH1 の雑音だけが画面の中を動き、読む物が増える

## 用途ごとの割り当ての例

| 測る物 | トレース 1 | トレース 2 | トレース 3 | トレース 4 |
| --- | --- | --- | --- | --- |
| フィルタ・アッテネータ (第 6 章) | S11 LOGMAG | S21 LOGMAG | S11 SMITH | S21 PHASE (既定のまま) |
| アンテナ (第 7 章) | S11 SWR | S11 X | S11 SMITH | 消す |
| 部品の値 (第 4 章) | S11 R | S11 X | S11 SMITH | 消す |
| ケーブル (第 5 章) | S11 LINEAR に TDR (2-7) | S21 LOGMAG | 消す | 消す |

## 見るべき値

図 3 (LC ローパス、計算値)。S21 と S11 の LOGMAG は 2-2 の表と同じ値になる。

| 印 | 周波数 | S11 LOGMAG | S21 LOGMAG | S11 (Smith) | S21 PHASE |
| --- | --- | --- | --- | --- | --- |
| 1 | 30 MHz | −15.91 dB | −0.11 dB | 37.7 Ω − j6.9 Ω | −56.10° |
| 2 | 69 MHz | −3.00 dB | −3.02 dB | 26.5 Ω − j69.0 Ω | −156.75° |
| 3 | 150 MHz | −0.02 dB | −24.05 dB | 0.1 Ω − j17.3 Ω | 128.26° |

図 4 (アンテナの等価回路、計算値)。

| 印 | 周波数 | SWR | X |
| --- | --- | --- | --- |
| 1 | 136 MHz | 1.43 | −0.8 Ω |

## 出典

自作。既定の割り当てとメニューの名前は
[NanoVNA-D (DiSlord 版)](https://github.com/DiSlord/NanoVNA-D) のファームウェアのもの。
