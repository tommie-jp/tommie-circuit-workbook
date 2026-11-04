---
book: circuits
chapter: 2
id: 2-20
title: サイリスタ・トライアックの点弧 (低圧 AC)
tier: 200
source: 自作
era: 古
---

# 2-20 サイリスタ・トライアックの点弧 (低圧 AC)

**サイリスタ** (SCR) は、ゲートに電流を少し流すとアノードからカソードへ導通し、その後はゲートを止めても導通し続ける (**自己保持**) スイッチ。
切れるのは、主電流が**保持電流** I<sub>H</sub> より小さくなったときだけである。交流なら半周期ごとに電流が 0 を通るので自然に切れ、
直流では一度点けたら主電流を断たないと消えない。ゲートで「点ける」ことを**点弧**と呼ぶ。

**トライアック**は、サイリスタを 2 つ逆向きに並べて 1 つのゲートで点ける素子で、交流の両方の半周期を通す。端子は MT1・MT2・ゲート (G)。
ゲートの電流の向き (+ / −) と MT2 の電圧の向き (+ / −) の組で 4 つの**象限**があり、点きやすさが違う。

この題では、12 V の交流アダプタ (50 / 60 Hz) を電源にして、

- サイリスタは、ゲートを押し続けても正の半周期しか通さない (半波)。押すのをやめると、次に電流が 0 になった所で切れる
- 直流では、一度押せば離しても点いたまま
- トライアックは、ゲートを押し続けると両方の半周期を通す。ゲートは**負の電流**で点けると両方の半周期で確実に点く

ことを確かめる。位相を変えて明るさを制御するのは 7-13 (トライアックの位相制御) と電験三種の教科書の 10-5 で扱う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 サイリスタ (左) とトライアック (右) の点弧。電源は 12 V の交流アダプタ
parts:
  VAC: sine 1,4 1,9 l=$\mathrm{AC12V}$
  G1: ground 1,9
  M1: voltmeter 3,4 3,9 l=$\mathrm{CH1}$
  RL1: resistor 6,4 6,6 680
  Q1: thyristor 6,6 6,11 2N5064
  G2: ground 6,11
  M2: voltmeter 4.5,6 4.5,11 l=$\mathrm{CH2}$
  RG1: resistor 10,9 8,9 1k
  RGK: resistor 8,9 8,11 1k
  G3: ground 8,11
  VCC: vcc 10,6 5V
  SW1: switch 10,6 10,9
  RL2: resistor 13,4 13,6 680
  T1: triac 13,6 13,11 Z0103MA
  G4: ground 13,11
  RG2: resistor 15,9 17,9 1k
  SW2: switch 17,9 17,12
  VEE: vee 17,12 5V
wires:
  - 1,4 -- 3,4
  - 1,9 -- 3,9
  - 3,4 -- 6,4
  - 6,4 -- 13,4
  - 6,6 -- 4.5,6
  - 4.5,11 -- 6,11
  - Q1.g -| 8,9
  - T1.g -| 15,9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/20-thyristor-triac-trigger.svg)

図1 の左がサイリスタ、右がトライアック。交流は 12 V の AC アダプタ (片方の端子 AC2 を GND にする)。ゲートの電源は AD3 の Supplies で、
サイリスタは `SW1` で +5 V から、トライアックは `SW2` で −5 V (VEE) から点ける。CH1 で交流、CH2 でサイリスタのアノード (トライアックを見るときは MT2) を見る。

- **交流**: 12 V (実効値) で振幅は約 17 V (50 Hz の地域なら周期 20 ms、60 Hz なら 16.7 ms)。商用電源には直に繋がない
- **主電流**: 導通の間は (17 − 0.9) V / 680 Ω ≈ **24 mA** (山)。2N5064 の I<sub>H</sub> (最大 5 mA)、Z0103MA の I<sub>H</sub> (最大 10 mA) を十分越える
- **サイリスタのゲート**: `RG1` (1 kΩ) で約 4.3 mA を送り、`RGK` (1 kΩ) が 0.7 mA を GND へ逃がして、ゲートへは約 3.6 mA。
  2N5064 の点弧に要るのは 200 µA 以下。`RGK` は、ゲートの感度が高すぎて雑音で点いてしまうのを防ぐ
- **半波**: サイリスタは逆向き (負の半周期) を通さない。押し続けると、負荷には正の半周期だけが掛かり、負荷の電圧の平均は約 Vm / π ≈ **5 V**
- **トライアックのゲート**: −5 V から `RG2` (1 kΩ) で約 4 mA を引き出す (目安)。Z0103MA の点弧の電流 I<sub>GT</sub> は、
  MT2 が + でゲートが + (第 1 象限)・MT2 が + でゲートが − (第 2)・MT2 が − でゲートが − (第 3) で最大 3 mA、MT2 が − でゲートが + (第 4) だけ最大 5 mA。
  **負のゲートなら第 2・第 3 象限**で、両方の半周期とも 3 mA で足りる。+5 V から点けると、負の半周期が第 4 象限になり、4 mA では点かない個体がある
- **損失**: 導通の電圧は約 0.9〜1 V (目安)。24 mA の山で 20 mW ほどで、どちらも熱くならない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 サイリスタ (上のブロック) とトライアック (下のブロック)
# 上の + レール = +5 V (V+)。− レールは上下とも GND (列 30 でつなぐ)。−5 V (V−) はレールに出さず、SW2 へ直に
board: half
parts:
  RL1: resistor b2 b10 680
  Q1: thyristor e8(K) e9(G) e10(A) 2N5064 cap=right
  RGK: resistor a9 -t9 1k
  RG1: resistor c9 c14 1k
  SW1: switch b14 b17
  T1: triac f8(MT1) f9(G) f10(MT2) Z0103MA cap=right
  RL2: resistor i2 i10 680
  RG2: resistor j9 j14 1k cap=above:2,0
  SW2: switch g14 g17
  AC:
    type: device
    at: top
    label: AC アダプタ (12 V 交流)
    pins: [AC1, AC2]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (V+・CH1・CH2)
    pins: [1-, 1+, 2+, 2-, V+]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (V−)
    pins: [V-]
wires:
  - AC.AC1 -- a2 yellow
  - AC.AC2 -- -t3 black
  - AD.1- -- -t5 black
  - AD.1+ -- a6 blue
  - d6 -- d2 blue
  - a8 -- -t8 black
  - AD.2+ -- a10 green
  - AD.2- -- -t12 black
  - a17 -- +t17 red
  - AD.V+ -- +t20 red
  - e2 -- f2 yellow
  - j8 -- -b8 black
  - AD1.V- -- j17 purple
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/20-thyristor-triac-trigger.svg)

図2 は、上のブロックにサイリスタ、下のブロックにトライアックを置いた。上の + レールは +5 V、− レールは上下とも GND (列 30 でつなぐ)。
−5 V はレールに出さず、AD3 の V− (紫) を `SW2` の端 (`j17`) へ直につなぐ。

- **交流 (列 2)**: AC アダプタの AC1 (黄) を `a2`、AC2 (黒) を GND のレールへ。列 2 から `RL1` (`b2`–`b10`) がサイリスタへ、黄の線 `e2`–`f2` で下の列 2 へ渡し、`RL2` (`i2`–`i10`) がトライアックへ。
  CH1 の 1+ (青) は `a6` から `d6`–`d2` で列 2 へ
- **サイリスタ (2N5064)**: 平らな面を手前に、左から K・G・A (列 8〜10)。K は GND へ、G (列 9) に `RGK` と `RG1`、`RG1` の先に `SW1`、`SW1` の先を +5 V へ。CH2 の 2+ (緑) は A (`a10`)
- **トライアック (Z0103MA)**: 平らな面を手前に、左から MT1・G・MT2 (列 8〜10。onsemi の資料の 1・2・3 番)。**作り手で並びが違うので、買った品の資料で確かめる**。
  MT1 は下の GND のレールへ、G (列 9) から `RG2`・`SW2` を通して −5 V へ。トライアックを見るときは 2+ を `a10` から MT2 の列 (`g10`) へ挿し替える
- `SW1`・`SW2` は押している間だけ閉じるスイッチ (タクトスイッチでもよい。そのときは足の組を確かめる)
- AC アダプタは**交流の出力** (AC 12 V) の品を使う。無負荷で 14 V ほど出る品があり、山は 20 V 近い。ブレッドボードの目安 (山 20 V) を越えるなら 9 V の品にする

## 計器の設定

計器は AD3 のオシロ (交流の波形と素子の電圧を並べて見るため)。CH1・CH2 とも 5 V/div、時間軸 5 ms/div、CH1 の立ち上がり 0 V でトリガ。
Supplies で V+ を +5 V、V− を −5 V にする。CH1 の 1− と CH2 の 2− は GND。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 SW1 を押し続ける — サイリスタ (CH2) は正の半周期だけ 0.9 V に落ちる
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 50Hz 17V, range: 5V/div, position: 0div}
ch2: {wave: ch1 | clip -20V 0.92V, range: 5V/div, position: 0div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/20-thyristor-triac-trigger-1.svg)

図3 は `SW1` を押し続けたとき。CH2 (アノード) は正の半周期で約 0.9 V に張り付き (導通)、負の半周期は CH1 と同じ −17 V まで下がる (逆向きを止める)。
`SW1` を離すと、その半周期の終わり (電流が 0 に近づく所) で切れ、次の正の半周期から CH2 は CH1 と同じ波になる。

2+ を MT2 (`g10`) に挿し替え、`SW2` を押し続けると図4 になる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 SW2 を押し続ける — トライアック (CH2) は両方の半周期で約 ±1 V
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 50Hz 17V, range: 5V/div, position: 0div}
ch2: {wave: ch1 | clip -1V 1V, range: 5V/div, position: 0div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/20-thyristor-triac-trigger-2.svg)

図4 の CH2 (MT2) は両方の半周期で ±1 V ほどに張り付き、負荷に交流の全部が掛かる。電流が 0 をまたぐ所だけ、点き直すまでの短い間 CH1 に沿う
(資料の最悪値の 15 mA の点弧保持電流 I<sub>L</sub> の個体では、点き直すのが半周期の 2 割ほど (約 40°) 遅れる)。図は導通の電圧を 1 V と置いた目安の形。

**直流で自己保持を見る**: AC アダプタの AC1 を `a2` から抜き、代わりに列 2 を赤い線で +5 V のレールへつなぐ。`SW1` を一度押して離す。
CH2 は 0.9 V のまま戻らない (主電流は約 6 mA で、2N5064 の I<sub>H</sub> (最大 5 mA) をわずかに越える)。列 2 の線を一度抜くと切れる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | サイリスタ (TO-92) | 2N5064 (I<sub>GT</sub> 200 µA 以下、I<sub>H</sub> 5 mA 以下) |
| T1 | トライアック (TO-92) | Z0103MA (I<sub>GT</sub> 3 mA (第 1〜3 象限)・5 mA (第 4)、I<sub>H</sub> 10 mA 以下) |
| RL1, RL2 | 抵抗 (1 W) | 680 Ω (トライアックの全波で約 0.21 W。1/4 W では足りない) |
| RG1, RG2, RGK | 抵抗 (1/4 W) | 1 kΩ |
| SW1, SW2 | 押しボタンスイッチ | 押している間だけ閉じる |
| — | 交流電源 | AC アダプタ 12 V (交流出力) — 素子の保持電流を越える電流を流すため。AD3 の W1 (10 mA ほど) では足りない |
| — | ゲートの電源 | AD3 の V+ (+5 V) と V− (−5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| `SW1` を押す前の CH2 | CH1 と同じ (±17 V) | サイリスタは切れている |
| `SW1` を押し続けたときの CH2 (正 / 負の半周期) | 約 0.9 V / −17 V | 正の半周期だけ通る (半波) |
| `SW1` を離したあと | 次の電流 0 の所で切れる | 交流では自然に切れる |
| 直流 5 V で `SW1` を押して離したあと | CH2 は約 0.9 V のまま | 自己保持 |
| `SW2` を押し続けたときの CH2 (MT2) | 両方の半周期で約 ±1 V | トライアックは両方向を通す |
| ゲートを +5 V から入れたときのトライアック | 負の半周期で点かない個体がある | 第 4 象限は点きにくい |

## LTspice での確かめ

`sim/20-thyristor-trigger.cir` でサイリスタの側を過渡解析した。mode 1 は交流でゲートを押し続け、mode 2 は交流で 21〜22 ms だけ押し、
mode 3 は直流 5 V で 21〜22 ms だけ押す。サイリスタは電験三種の教科書の 10-5 と同じ NPN + PNP の 2 トランジスタ模型 (2N5064 の代用、仮定)、
交流アダプタは理想の 12 V (振幅 17 V) とした。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| `RG1` を流れる電流 (押している間) | 約 4.3 mA | 4.32 mA | 合う |
| 導通の電圧 (アノード) | 約 0.9 V | 0.92 V | 合う |
| 主電流の山 | 約 24 mA | 23.6 mA | 合う |
| 負の半周期のアノード | −17 V | −16.99 V | 合う |
| 押し続けたときの負荷の電圧の平均 | 約 5 V (Vm / π = 5.4 V から導通の電圧の分を引く) | 4.96 V | 合う |
| 21〜22 ms だけ押したとき (交流) | その半周期だけ導通し、次は消える | 21.5 ms で 10 mA、25 ms で 23.6 mA、29.7 ms で切れ、45 ms は 0 mA | 合う |
| 21〜22 ms だけ押したとき (直流 5 V) | 離しても点いたまま | 45 ms でも 6.06 mA、導通の電圧 0.88 V | 合う |

トライアックは LTspice に部品が無く、4 つの象限の違いを持つ模型も用意していないので、回していない (対象外)。
トライアックの数は資料の値からの算術で、主電流の山 (17 − 1) V / 680 Ω ≈ 23.5 mA と、ゲートの電流 (5 − 0.8) V / 1 kΩ ≈ 4.2 mA (目安) を、I<sub>H</sub>・I<sub>GT</sub> と比べた。

## 出典

自作。2N5064 の値とピンの並びは onsemi の 2N5060 系のデータシート (型番で検索)、Z0103MA の象限ごとの I<sub>GT</sub>・I<sub>L</sub>・I<sub>H</sub> とピンの並びは onsemi の Z0103MA のデータシート (型番で検索)。

参考: [サイリスタ (Wikipedia)](https://ja.wikipedia.org/wiki/サイリスタ)、[TRIAC (Wikipedia)](https://en.wikipedia.org/wiki/TRIAC)
