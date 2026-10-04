---
book: denken
chapter: 0
id: 0-6
title: ヒューズと電流制限 — シャントの発熱も測る
tier: 100
source: 自作 (ヒューズの定格は Littelfuse RXEF010 のデータシート)
board: BB
---

# 0-6 ヒューズと電流制限 — シャントの発熱も測る

回路のどこかが短絡すると、電源から大きな電流が流れ、線や部品が熱くなる。**ヒューズ**は決まった電流を
超えると回路を切り、電流を止める。この題では、何度でも使える**ポリスイッチ** (PTC 形の復帰ヒューズ) を
5 V の回路に入れ、わざと負荷を短絡に近づけて、電流が絞られる様子を AD のオシロで記録する。

ポリスイッチは、電流が大きいと自分の発熱で抵抗が数 Ω から数十 Ω に跳ね上がり、電流を絞る。ガラス管の
ヒューズと違って切れてしまわず、原因を取り除いて冷めれば元に戻る。電流は**シャント抵抗** (0-3) で電圧に
変えて読む。シャントは電流の 2 乗に比例して熱くなるので、その電力 (I² R) も Math で同時に見る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I = V_Rs / Rs | シャント抵抗の電圧から電流を求める (Rs = 1 Ω なら 1 mV = 1 mA) |
| P = I² R | 抵抗の発熱の電力。シャントは P の 2 倍以上の定格のものを選ぶ |
| I = E / (R_F1 + R_L + Rs) | ヒューズが働く前の電流は、回路の抵抗の和で決まる |
| P_F1 = I² R_F1 ≈ 一定 | 働いた後のポリスイッチは、自分を温めておくだけの電力 (RXEF010 で 0.38 W) で釣り合う |

## 回路図

```circuit
title: 図1 ポリスイッチとシャントの回路
style:
  standard: jis
  pitch: 1.2
parts:
  E1: vsource c1 i1 5
  F1: fuse c1 c3 l=$\mathrm{F_1}$
  RL: resistor c6 f6 220
  S1: switch c9 d9
  RF: resistor d9 f9 4.7
  M1: voltmeter f3 i3 l=$\mathrm{CH1}$
  Rs: resistor f4 i4 1 i=I
  M2: voltmeter c11 i11 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c3 -- c6 -- c9 -- c11
  - f3 -- f4 -- f6 -- f9
  - i1 -- i3 -- i4 -- i11
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/circuit/06-fuse-current-limit.svg)

- E1 は USB の 5 V (1 A 以上出せる USB アダプタと USB の端子の変換基板)。AD の Supplies は 50 mA ほどしか
  出せないので使わない
- F1 はポリスイッチ RXEF010 (保持電流 0.10 A・動作電流 0.20 A)。0.10 A までは働かず、0.20 A を超えると必ず働く
- RL = 220 Ω がふだんの負荷 (22 mA)。S1 を閉じると RF = 4.7 Ω が並列に入り、**短絡に近い故障**になる
- Rs = 1 Ω がシャント。GND 側に置いたので、CH1 は 1 本で電流を読める (1 mV = 1 mA)
- CH2 は F1 の後ろ (負荷の上) の電圧。F1 の両端の電圧はほぼ 5 V − CH2 (電源と線の抵抗の分だけ小さい)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| F1 | ポリスイッチ (リード付き) | RXEF010 (Littelfuse)。保持 0.10 A、動作 0.20 A、0.5 A で 4 秒以内に働く、25 °C の抵抗 2.5〜4.5 Ω (働いて冷めた 1 時間後は 7.5 Ω 以下)、働いたときの電力 0.38 W (代表値) |
| RL | 抵抗 (1/4 W) | 220 Ω (ふだん 0.11 W) |
| RF | セメント抵抗 5 W | 4.7 Ω (故障のとき 1.1 W) |
| Rs | 金属皮膜抵抗 1 W | 1 Ω (故障のとき 0.26 W) |
| S1 | スライドスイッチ | 1 A 以上。無ければ線を挿して閉じる |
| — | 電源 | 5 V (USB アダプタ、1 A 以上) — 故障の電流 0.5 A を流すため。AD の Supplies (USB 給電で 1 本 250 mW) では足りない |

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  F1: fuse c3 c7
  S1: switch a7 a10
  RF: resistor c10 c13 4.7
  RL: resistor e7 e13 220
  Rs: resistor b13 b18 1
  USB:
    type: device
    at: top
    label: 5V (USB)
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [2+, 1+, GND, 1-, 2-]
wires:
  - USB.+ -- +t2 red
  - USB.- -- -t4 black
  - +t3 -- a3 red
  - AD.2+ -- b7 green
  - AD.1+ -- a13 orange
  - AD.GND -- -t15 black
  - AD.1- -- -t20 black
  - AD.2- -- -t22 black
  - a18 -- -t18 black
notes:
  - text: "F1 = ポリスイッチ RXEF010、RF = 4.7 Ω (5 W)、Rs = 1 Ω (1 W)"
  - text: "S1 (7〜10 列) を閉じると RF が RL と並列に入る (故障)"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/breadboard/06-fuse-current-limit.svg)

- 上の + レールが 5 V、上の − レールが GND。AD の GND も同じ − レールにつなぐ (測る基準をそろえる)
- F1 は 3〜7 列。7 列が F1 の後ろで、CH2 (緑) はここを読む
- RL (e 行) と S1 + RF (a 行と c 行) は 7 列と 13 列の間に並列に入る。13 列が負荷の下
- Rs は 13〜18 列。18 列から − レールへ戻る。CH1 (橙) は 13 列で、Rs の上の端を読む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = Rs (100 mV/div)、CH2 = F1 の後ろ (1 V/div)。どちらも DC。Time base 1 s/div |
| Trigger | CH1 の立ち上がり 250 mV、Single。トリガの位置を左から 1 目盛にして、S1 を閉じる前も見る |
| Math | C1 × C1 (単位 W)。Rs = 1 Ω なので、そのままシャントの電力になる |

手順: 1) Single で待つ。2) S1 を閉じ、画面が止まるまで (8 秒ほど) そのまま。3) S1 を開き、1 分ほど待って
F1 を冷ます。ポリスイッチが働いてからの形は品と温度で変わるので、画面の後半は**目安**で描いた
(働くまで 2 秒、その後 0.3 秒ほどで絞られる)。

```scope
title: 図3 S1 を閉じると 0.5 A 流れ、2 秒ほどで 84 mA に絞られる (後半は目安)
time: 1s/div
trigger: ch1 rising 250mV at -4div
ch1: {wave: "= 22.2mV + step(t) * (62.2mV + 420.6mV * exp(-max(t - 2s, 0s) / 300ms))", range: 100mV/div, position: -3div}
ch2: {wave: "= 4.90V - step(t) * (4.43V - 2.36V * exp(-max(t - 2s, 0s) / 300ms))", range: 1V/div, position: -3div}
math: {expr: ch1 * ch1, unit: W, range: 50mW/div, position: -3div}
cursors: [1s, 6s]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/scope/06-fuse-current-limit.svg)

- X1 (1 秒) は故障の直後、F1 が働く前。X2 (6 秒) は F1 が働いた後
- CH1 の読みを mV から mA に読み替えると電流、Math の読みがシャントの電力

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。CH1・CH2 とも GND 基準なので、回路は
そのままでよい。発振器は使わない。

- CH1 の先端を 13 列、CH2 の先端を 7 列。グランドクリップは 2 本とも上の − レール
- 1 s/div のような遅い掃引は、ロール表示 (Roll) か Single で取る。Math の掛け算 (CH1 × CH1) が無い機種は、
  X1・X2 の CH1 の読みを 2 乗して電力にする
- **安定化電源で 5 V を作るなら、電流制限が先に効く。** 制限を 1 A にすれば図3 と同じ形になる。
  制限を 0.3 A にすると、故障の電流は 0.3 A で頭打ちになり (電源の電圧が約 2.9 V に下がる。計算値)、
  F1 は 0.3 A (動作電流の 1.5 倍) で働くので、働くまでの時間が図3 より延びる。電源の電流制限と
  ヒューズは、どちらも「電流の上限」を決めるが、**電源の制限は流し続け、ヒューズは絞るか切る**

## 見るべき値

計算値。F1 の抵抗は働く前 4 Ω、USB アダプタと線の抵抗を 0.3 Ω とした。働いた後は、F1 が 0.38 W
(データシートの代表値) で自分を温めて釣り合うとした。

| 状態 | CH1 (= 電流) | CH2 | F1 の両端 (5 V − CH2) | シャントの電力 (Math) |
| --- | --- | --- | --- | --- |
| ふだん (S1 開) | 22.2 mV (22.2 mA) | 4.90 V | 0.09 V | 0.49 mW |
| 故障の直後 (X1) | 505 mV (505 mA) | 2.83 V | 2.0 V (5 V − CH2 は 2.17 V。差の 0.15 V は電源と線の 0.3 Ω) | 255 mW |
| F1 が働いた後 (X2) | 84 mV (84 mA) | 0.47 V | 4.50 V (F1 は約 53 Ω) | 7.1 mW |
| S1 を開いた直後 | 18 mV (18 mA) | 3.97 V | 0.96 V | 0.33 mW |
| F1 が冷めた後 | 22.2 mV (22.2 mA) | 4.90 V | 0.09 V | 0.49 mW |

分かること:

- **故障の電流 (505 mA) は、ふだんの 23 倍。** 回路の抵抗が 225 Ω から 10 Ω に下がったため。
  ヒューズが無ければ、このまま RF で 1.1 W、線と電源にも同じ電流が流れ続ける
- **働いた後のポリスイッチは電流を 0 にはしない。** 84 mA 流れたまま、F1 が 4.50 V を受け持つ
  (4.50 V × 84 mA ≈ 0.38 W で自分を温め続ける)。電源が 5 V と低いので、残る電流は保持電流 (0.10 A)
  に近い。電圧の高い回路ほど、残る電流は小さくなる
- S1 を開いても、F1 はしばらく 53 Ω ほどのまま (18 mA)。熱が逃げると元の数 Ω に戻る
- **シャントは熱くなる。** 故障の間、Rs (1 Ω) は 255 mW を出す。1/4 W の抵抗では定格を超えるので、
  この題は 1 W の抵抗にした。**シャントの定格は、流れうる一番大きい電流で I² R の 2 倍以上**を選ぶ。
  Rs を小さくすれば発熱は減るが、読む電圧も小さくなる (1 Ω・505 mA で 505 mV、0.1 Ω なら 51 mV)
- ふだんのシャントの電力は 0.49 mW と小さい。シャントの発熱が問題になるのは大きな電流のときだけ

## 出典

自作。ポリスイッチの保持電流・動作電流・動作時間・抵抗は Littelfuse の
[RXEF シリーズの製品ページ](https://www.littelfuse.com/products/fuses-overcurrent-protection/polyswitch-resettable-pptc-devices/radial-leaded-polyswitch-resettable-pptc-devices/rxef/rxef010)
とデータシート。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Scope の節)。
