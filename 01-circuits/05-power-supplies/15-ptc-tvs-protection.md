---
book: circuits
chapter: 5
id: 5-15
title: 電源の保護 — ヒューズ・PTC・TVS
tier: 200
source: 自作
---

# 5-15 電源の保護 — ヒューズ・PTC・TVS

5 V で動く回路に、まちがえて 9 V の AC アダプタをつないだらどうなるか。何もしなければ回路の IC は壊れる。
電源の入口に入れる保護は、2 つの役を組にして働く。

- **電圧を止める部品** — TVS (過渡電圧サプレッサ、Transient Voltage Suppressor)。ツェナーダイオードの仲間で、決まった電圧 (この題の P6KE6.8A は 6.45〜7.14 V) を超えると
  大きな電流を流して、それ以上電圧が上がらないように押さえる。ただし押さえている間は TVS が熱を出す
- **電流を止める部品** — ヒューズか PTC (ポリスイッチ)。電流が大きすぎると切れる。ヒューズは一度切れたら交換するが、
  PTC は電流で温まると抵抗が急に上がって電流を絞り、冷えると元に戻る (リセッタブルヒューズ)

TVS が電圧を押さえて回路を守り、その大きな電流で PTC が温まって電流を絞り、TVS が焼けるのを防ぐ。この題では電源装置 (第 13 章) の電圧を
5 V から 9 V に上げて、この順番を電圧と電流の波形で見る。部品を 1 つずつ見るのは 1-12、電池の逆接続は 5-9 で扱う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 PTC と TVS で 5 V の回路を守る (電源は電流制限つきの電源装置)
parts:
  U1:
    type: device
    at: 2,2
    label: PSU
    pins: ["+", "GND", "-"]
    turn: mirror
  PTC1: thermistor-ptc 4,2 7,2 l=$\mathrm{PTC1}$
  D1: zener 8,6 8,2 l=$\mathrm{TVS1}$
  R1: resistor 11,2 11,4 330
  D2: led 11,4 11,6 red
  RS: resistor 8,6 8,8 1
  M1: voltmeter 14,2 14,8 l=$\mathrm{CH1}$
  M2: voltmeter 6,6 6,8 l=$\mathrm{CH2}$
  G1: ground 8,8
  G2: ground 3,3
wires:
  - U1.+ -| 4,2
  - U1.- -| 3,3
  - 7,2 -- 8,2 -- 11,2 -- 14,2
  - 11,6 -- 8,6
  - 8,6 -- 6,6
  - 6,8 -- 8,8 -- 14,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/15-ptc-tvs-protection.svg)

- PSU は電流制限つきの電源装置。普段は 5.0 V、電流制限 200 mA。「まちがえて 9 V」の代わりに、電圧のつまみを 9.0 V に上げる
- PTC1 は MF-R005 (保持電流 50 mA・切れ始めの電流 100 mA、冷えた抵抗 7.3〜11.1 Ω (オーム)、データシートの値)
- TVS1 は P6KE6.8A (降伏電圧 6.45〜7.14 V、ふだん掛けてよい電圧 5.8 V、データシートの値)。カソード (帯) を + 側にして並列に入れる
- R1 (330 Ω) と赤い LED が守られる 5 V の回路の代わり (5 V で約 9 mA)
- RS (1 Ω) は回路全体の電流を見るシャント。CH2 が RS の両端 (1 mA で 1 mV)、CH1 が回路の電圧 VL

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (PTC1 から先が守られる 5 V の回路)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (5 V → 9 V、電流制限 200 mA)
    pins: ["-", "+"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (Scope)
    pins: [1-, 1+, 2+, 2-]
  PTC1: thermistor-ptc b3 b7 MF-R005
  TVS1: zener c7(K) c11(A) P6KE6.8A
  R1: resistor a7 a14 330 cap=above
  D2: led c14(A) c17(K) red
  RS: resistor h11 -b11 1 cap=left
wires:
  - PSU.- -- -t2 black
  - PSU.+ -- a3 red
  - b17 -- b11 orange
  - e7 -- f7 yellow
  - e11 -- f11 green
  - -t30 -- -b30 black
  - AD.1+ -- j7 yellow
  - AD.1- -- -b5 black
  - AD.2+ -- g11 green
  - AD.2- -- -b13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/15-ptc-tvs-protection.svg)

- 電源装置の + (赤) は 3 列、− (黒) は上の青いレールへ。PTC1 (`b3`–`b7`) を通った 7 列が VL
- TVS1 は帯 (カソード) を 7 列 (`c7`)、アノードを 11 列 (`c11`) に挿す。R1 (`a7`–`a14`) と LED (`c14`–`c17`) の先も 11 列へ (橙の線 `b17`–`b11`)
- 11 列から短い緑の線で下のブロックへ渡し、RS (`h11`) を下の青いレールへ。下と上の青いレールは 30 列でつなぐ
- CH1 (1+) は 7 列を下へ渡した `j7`、CH2 (2+) は RS の上 (`g11`)。1−・2− は下の青いレール
- 故障の間は 200 mA が PTC1・TVS1・RS と、それをつなぐ穴を流れる。ブレッドボードの 1 穴の上限 (定常 200 mA) ちょうどなので、電源装置の電流制限を 200 mA より上げない

## 計器の設定

電源は電源装置 (電圧と電流制限を決めて故障を作るため。AD3 の Supplies は 250 mW までで、200 mA は流せない)。AD3 は Scope だけを使う。

1. 電源装置を出力オフのまま 5.0 V・電流制限 200 mA にし、回路をつないで出力を入れる。LED が点く
2. Scope は DC 結合、CH1 1 V/div、CH2 50 mV/div、どちらも 0 V を下から 1 目盛 (−4 div)、時間軸 5 s/div。トリガは単発で CH1 の立ち上がり 6 V
3. 電源装置の電圧のつまみを 9.0 V まで素早く回す (t = 0)。40 秒ほど待つ
4. 電圧を 5.0 V に戻し、1 分ほど待って PTC1 が冷えると、元の電流 (約 9 mA) に戻る

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 電源を 5 V から 9 V に上げる — TVS が 7 V に止め、PTC が電流を絞る
time: 5s/div
trigger: ch1 rising 6V at -4div
ch1: {wave: "= 4.92V * (1 - step(t)) + step(t) * (6.85V + 0.24V / (1 + exp((t - 11.7s) / 1.16s)))", range: 1V/div, position: -4div}
ch2: {wave: "= 8.8mV * (1 - step(t)) + step(t) * (32.7mV + 167.3mV / (1 + exp((t - 11.7s) / 1.16s)))", range: 50mV/div, position: -4div}
cursors: [3s, 38s]
measure: [vmax, vmin]
notes:
  - text ch2 3s 200mV: 電源の電流制限 200 mA
  - text ch2 25s 33mV: PTC が温まって 33 mA に絞る
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/15-ptc-tvs-protection.svg)

図3 は理想 (計算) の画面で、下の LTspice の結果 (PTC は仮定の熱の模型) をなめらかな式で近似して描いた。読み方は次のとおり。

- t < 0: 5 V。VL は 4.92 V (PTC1 の 9 Ω と RS で 0.08 V 下がる)、電流 8.8 mA
- t = 0 で TVS1 が働き、VL は 7.09 V で止まる (TVS1 の 6.89 V + RS の 0.2 V)。電流は電源装置の制限の 200 mA に張りつく (X1)。電源装置は CC に入る
- 10 秒ほど 200 mA が流れて PTC1 が温まり、抵抗が上がって電流が下がる (100 mA を割るのは 12 s 後)
- 20 秒後からは、PTC1 が約 33 mA に絞った所で釣り合う (X2)。VL は 6.85 V で、TVS1 はまだ少し電流を流して電圧を押さえている

**大事な点**: PTC1 が絞った後も、VL は 5 V に戻らず 6.85 V のままになる。TVS1 と PTC1 の組が守るのは「回路の電圧を TVS1 の電圧より上げない」ことと
「TVS1 を焼かない」ことで、5 V にすることではない。だから TVS は**守る回路が耐えられる電圧** (74HC なら絶対最大定格 7 V など) で選ぶ。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| PTC1 | ポリスイッチ (リセッタブルヒューズ、リード品) | MF-R005 (保持 50 mA・切れ始め 100 mA、60 V) |
| TVS1 | TVS ダイオード (片方向) | P6KE6.8A (降伏 6.45〜7.14 V、ピーク 600 W) |
| R1 | 抵抗 (1/4 W) | 330 Ω (6.85 V のとき損失 約 70 mW) |
| D2 | LED (赤、5 mm) | — |
| RS | 抵抗 (1/4 W) | 1 Ω (200 mA のとき損失 40 mW) |
| — | 電源 | 電源装置 (CV/CC、5.0 V → 9.0 V、電流制限 200 mA)。9 V は「まちがえた電源」を作るため |
| — | 計器 | AD3 の Scope (1+ = VL、2+ = RS の上) |

PTC1 の代わりにヒューズ (たとえば 100 mA の速断) を入れると、t = 0 の直後に切れて電流は 0 になり、VL も 0 V になる。確実だが、切れたら交換が要る。
ブレッドボードではヒューズは試さず、PTC1 で動きを見る。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ふだん (5 V) の VL・電流 | 4.92 V・8.8 mA | PTC1 は冷えていれば 9 Ω ほどの抵抗 |
| 9 V にした直後の VL (CH1) | 約 7.1 V | TVS1 が降伏電圧で押さえる (6.45〜7.14 V の範囲。RS の 0.2 V を含む) |
| 9 V にした直後の電流 (CH2) | 200 mA (電源装置の制限) | TVS1 が大きな電流を流す。TVS1 の損失は 1.4 W ほど |
| 電流が 100 mA を割るまで | 約 12 s (仮定の模型) | PTC1 が温まるまでの時間。データシートは 0.5 A で 5 s 以内 |
| 落ち着いた後の電流・VL | 約 33 mA・6.85 V | PTC1 は全部は切れず、自分が温まり続ける電流で釣り合う |
| 落ち着いた後の PTC1 の温度 | 60〜70 °C (模型で 65 °C) | 指で触らない。TVS1 も温かい |
| 5 V に戻して 1 分後 | 8.8 mA | PTC1 が冷えて戻る (リセッタブル) |

PTC1 の切れ始めの時間と落ち着く電流は、PTC1 の個体・周りの温度・リード線の長さで大きく変わる。表の 12 s と 33 mA は模型の目安なので、実測で読み替える。

## LTspice での確かめ

`sim/15-ptc-tvs-protection.cir` で図1 を 50 秒動かした。電源装置は 200 mA の電流源と設定電圧へ逃がす理想ダイオードで作った CV/CC の模型。
PTC1 は仮定の熱の模型 (冷えた抵抗 9.2 Ω、熱抵抗 600 K/W、熱容量 0.1 J/K、80 °C を超えると抵抗が急に上がる)。保持 50 mA で 11 K しか温まらず、
100 mA でほぼ 80 °C に届くように、データシートの保持・切れ始めの電流に合わせた。TVS1 は降伏 6.8 V・動作抵抗 0.065 Ω の仮定。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ふだんの VL・電流 | 4.92 V・8.8 mA | 4.919 V・8.81 mA | 合う |
| 9 V にした直後の VL・電流 | 7.09 V・200 mA | 7.088 V・200.1 mA | 合う |
| 電源装置の出力 (直後) | CC に入る | 8.93 V (9 V より下) | 合う |
| TVS1 の電流 (直後) | 約 185 mA | 185 mA | 合う |
| 100 mA を割るまで | 約 12 s | 12.1 s | 本文の値は LTspice の読み (仮定の模型) |
| 落ち着いた後の電流・VL | 33 mA・6.85 V | 32.7 mA・6.849 V | 合う |
| 落ち着いた後の PTC1 の温度・損失 | 65 °C・70 mW | 65.2 °C・70.4 mW | 本文の値は LTspice の読み (仮定の模型) |

切れるまでの時間と釣り合いの電流は PTC の熱の仮定で決まる。ここで確かめたのは、TVS が押さえ PTC が絞る順番と、そのときの電圧・電流の釣り合いの算術。

## 出典

自作。

参考: [Bourns MF-R シリーズ (PTC) のデータシート](https://www.bourns.com/docs/Product-Datasheets/mfr.pdf)、[Vishay P6KE シリーズ (TVS) のデータシート](https://www.vishay.com/docs/88369/p6ke.pdf)、[ヒューズ (Wikipedia)](https://ja.wikipedia.org/wiki/ヒューズ)、[Resettable fuse (Wikipedia)](https://en.wikipedia.org/wiki/Resettable_fuse)、[Transient-voltage-suppression diode (Wikipedia)](https://en.wikipedia.org/wiki/Transient-voltage-suppression_diode)
