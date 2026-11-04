---
book: circuits
chapter: 8
id: 8-19
title: フォトダイオードの短絡電流
tier: 200
source: 自作
board: BB
---

# 8-19 フォトダイオードの短絡電流

フォトダイオードは、PN 接合に光が当たると、光の強さに比例した電流 (光電流) を出すダイオードである。
8-1 の CdS や 8-5 のフォトトランジスタより速く (BPW34 の立ち上がりは 100 ns)、光の強さと電流の比例が広い範囲で保たれる。
照度計、光通信の受信、リモコンの受光の基本の部品である。

ただし、比例するのは**両端の電圧を 0 V に保ったときの電流 (短絡電流)** だけである。抵抗を 1 本つないで電圧を取り出すと、
電圧が上がるにつれて、光電流の一部がダイオード自身の順方向に流れて戻ってしまい、0.3〜0.4 V で頭打ちになる
(開放電圧。光の強さの対数でしか増えない)。

そこで、OP アンプで**電流電圧変換 (トランスインピーダンス増幅)** を組む。OP アンプは − 入力を + 入力 (GND) と同じ 0 V に保つ (仮想接地、4-3 で見た) ので、
フォトダイオードは短絡されたのと同じになる。光電流は全部 Rf を通って出力へ回り、出力の電圧は **V = I × Rf** になる。

この題では、BPW34 と MCP6002 で電流電圧変換を組み、Analog Discovery 3 (AD3) の W1 で点滅させた赤い LED の光を受けて、
出力の方形波をオシロで見る (電流電圧変換の回路そのものは 4-14 でも扱う)。続けて、OP アンプを抜いて 47 kΩ だけで受けたときと比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォトダイオード BPW34 の短絡電流を MCP6002 で電圧に変える
parts:
  W1: square 2,5 2,7 l=$\mathrm{W1}$
  G0: ground 2,7
  M2: voltmeter 3,3 3,5 l=$\mathrm{CH2}$
  G5: ground 3,5
  R2: resistor 4,3 6,3 330
  D2: led 6,3 6,5 red
  G6: ground 6,5
  PD1: photodiode 8,8 8,5 l=$\mathrm{PD1}$
  G1: ground 8,8
  U1A: opamp 11,6 +down
  G2: ground 9.5,8
  Rf: resistor 10,3.2 12,3.2 47k
  Cf: capacitor 10,1.4 12,1.4 22p
  M1: voltmeter 14,6 14,8 l=$\mathrm{CH1}$
  G3: ground 14,8
  C1: capacitor 16,2 16,4 100n
  VCC: vcc 16,2 5V
  G4: ground 16,4
wires:
  - 2,5 -- 2,3 -- 3,3 -- 4,3
  - 8,5 -- 9,5
  - 9,5 |- U1A.-
  - 9,1.4 -- 9,3.2 -- 9,5
  - 9,1.4 -- 10,1.4
  - 9,3.2 -- 10,3.2
  - 12,1.4 -- 13,1.4 -- 13,3.2
  - 12,3.2 -- 13,3.2
  - 13,3.2 -- 13,6
  - U1A.out -- 13,6 -- 14,6
  - U1A.+ -| 9.5,8
notes:
  - text 2,9.5 blue left: "D2 の光を PD1 に当てる (1 cm ほど離して向ける)"
  - text 2,10.5 blue left: "U1 は MCP6002 (8 番 +5V・4 番 GND)。C1 は 8 番と 4 番の間"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/19-photodiode.svg)

- **PD1 (BPW34)** はアノードを GND、カソードを U1A の − 入力につなぐ。光が当たると、外の回路ではカソードから電流が流れ込む向き
  (電池として見るとアノードが + になる向き) に光電流 I が流れる
- **U1A** は − 入力を 0 V (+ 入力と同じ) に保つ。PD1 の両端は 0 V のままで、I は全部 Rf を通る。出力は **+I × Rf** になる
  (47 kΩ なら 1 µA で 47 mV、20 µA で 0.94 V)。MCP6002 は入力も出力もほぼ電源の端まで振れる (レール to レール) ので、5 V の単電源で 0 V の近くから扱える
- **Rf の決め方**: BPW34 の短絡電流は、白熱電球の光 (A 光源) の 1,000 lx (ルクス) で典型 70 µA (Vishay のデータシート)。70 µA で 3.3 V になるよう 47 kΩ にした。
  明るい窓際では 5 V で頭打ちになるので、そのときは Rf を 10 kΩ に下げる
- **Cf (22 pF)**: PD1 の接合容量 (0 V で 70 pF) が − 入力に付くと、OP アンプの帰還が遅れて発振しやすくなる。Rf に Cf を並べて高い周波数の利得を下げ、止める。
  帯域は 1 / (2π × 47 kΩ × 22 pF) ≈ **154 kHz**、方形波の立ち上がりは 2.2 × 47 kΩ × 22 pF ≈ **2.3 µs**
- **光源**: W1 の 0〜4 V の方形波で、R2 (330 Ω) を通して赤い LED D2 を点滅させる。点いているときの電流は (4 − 1.9) V ÷ 330 Ω ≈ 6.4 mA で、
  W1 が出せる電流 (10 mA ほど) の内側。CH2 で W1 を見る
- U1 の 2 回路目 (U1B) は使わない。+ 入力を GND、− 入力を出力につないでおく (浮かせない)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 BPW34 と MCP6002 の電流電圧変換 (D2 は PD1 に向けて曲げる)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・W1・CH2)
    pins: [V+, GND, 2+, W1, 2-]
  U1: dip8 @ e12 MCP6002
  C1: capacitor/ceramic c9 c12 100n
  Rf: resistor h8 h13 47k cap=left
  Cf: capacitor/ceramic i8 i13 22p
  PD1: photodiode h20 h17
  R2: resistor c22 c26 330
  D2: led b26(A) b28(K) red
  SC:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH1)
    pins: [1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t12 -- a12 red
  - a9 -- -t9 black
  - b13 -- b14 white
  - a15 -- -t15 black
  - j15 -- -b15 black
  - j14 -- -b14 black
  - g12 -- g8 orange
  - g13 -- g17 green
  - j20 -- -b20 black
  - AD.W1 -- a22 yellow
  - b22 -- b20 yellow
  - AD.2+ -- a20 blue
  - AD.2- -- -t24 black
  - a28 -- -t28 black
  - SC.1+ -- j12 orange
  - SC.1- -- -b11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/19-photodiode.svg)

- 5 V は AD3 の Supplies の V+ から上の + レールへ。上下の − レールを左端でつなぐ
- **MCP6002** は溝をまたいで、切り欠きを左に。1 番 (VOUTA) が左下の `f12`、8 番 (VDD) が左上の `e12`。2 番 (VINA−) は下の列 13、3 番 (VINA+) は列 14 で − レールへ、
  4 番 (VSS) は列 15 で − レールへ。8 番を + レールへつなぎ、C1 を 9〜12 列 (上) に入れる
- **U1B (使わない)**: 7 番 (VOUTB、上の列 13) と 6 番 (VINB−、列 14) を白の短い線でつなぎ、5 番 (VINB+、列 15) を − レールへ
- **Rf と Cf**: 出力の 1 番 (列 12) を橙の線で列 8 へ延ばし、Rf (列 8〜13) と Cf (列 8〜13) を並べて 2 番の列 13 へ戻す
- **PD1**: 2 番の列 13 を緑の線で列 17 へ延ばし、BPW34 のカソードを `h17`、アノードを `h20` (列 20 は − レールへ) に挿す。
  BPW34 は平たい箱で、受光面を上に向ける。カソードは足の根元の印 (データシートの外形図) で見分ける
- **光源**: W1 (黄) を `a22` へ。R2 (列 22〜26) を通して D2 のアノード (`b26`)、カソード (`b28`、列 28 は − レールへ)。
  D2 は足を長いまま曲げ、PD1 の受光面の上 1 cm ほどから光を当てる。CH2 (2+、青) は、列 22 から黄の短い線で延ばした列 20 の `a20`
- オシロの CH1 (1+、橙) は出力の列 12 (`j12`)
- 電流は D2 の点いている間の 6.4 mA (W1 から)、MCP6002 の 0.2 mA ほど、出力から Rf へ流れる光電流 (100 µA 以下)。AD3 の範囲とブレッドボードの範囲に十分収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V。W1 を方形波・1 kHz・振幅 2 V・オフセット 2 V (0〜4 V) にする。
Scope は CH1 を出力 (列 12)、CH2 を W1 (列 20) にして、横 200 µs/div、CH1 は 200 mV/div、CH2 は 2 V/div。トリガは CH2 の立ち上がり 2 V。
部屋の明かりも PD1 に入るので、最初は手で PD1 と D2 を覆い、D2 の光だけにする。

見えるはずの画面 (D2 の光で光電流が 20 µA になると**仮定**した計算値で、実測ではない。光電流は D2 と PD1 の距離と向きで大きく変わる)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 (CH2) で LED を点滅させ、光電流 × Rf の方形波 (CH1) が出る
time: 200us/div
trigger: ch2 rising 2V at -4div
ch1: {wave: square 1kHz 0.47V offset 0.47V, range: 200mV/div, position: -3div}
ch2: {wave: square 1kHz 2V offset 2V, range: 2V/div, position: 0div}
measure: [vmax, vmin, freq]
cursors: [100us, 600us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/19-photodiode.svg)

- CH1 は CH2 と同じ 1 kHz の方形波で、高さは 0.94 V (= 20 µA × 47 kΩ)。読んだ高さを 47 kΩ で割ると光電流が出る
- 手を離して部屋の明かりを入れると、CH1 全体が持ち上がる (500 lx で 35 µA なら 1.65 V ほど、仮定)。LED 照明や蛍光灯の部屋では、
  電源の 2 倍の周波数 (東日本の 50 Hz なら 100 Hz、西日本の 60 Hz なら 120 Hz) のちらつきが乗る。人の目には見えないちらつきが、フォトダイオードでは見える
- 横を 2 µs/div にすると、立ち上がりが約 2.3 µs かけて上がるのが見える (Rf × Cf の時定数と OP アンプの速さで決まる)
- **47 kΩ だけで受けて比べる**: U1 を抜き、列 13 と − レールの間に 47 kΩ を 1 本挿して、CH1 を列 13 に当てる。PD1 は抵抗で受けると
  カソードが負になり、同じ光でも約 −0.32 V にしかならない。光を 3.5 倍 (20 → 70 µA) にしても −0.36 V にしか動かない (対数)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| PD1 | PIN フォトダイオード | BPW34 (Vishay。1,000 lx で短絡電流 典型 70 µA、接合容量 0 V で 70 pF) |
| U1 | レール to レール OP アンプ | MCP6002 (2 回路のうち 1 回路を使う) |
| Rf | 抵抗 (1/4 W) | 47 kΩ |
| Cf | セラミックコンデンサ (CH 特性か C0G) | 22 pF (220) |
| C1 | 積層セラミックコンデンサ | 0.1 µF (104) |
| R2 | 抵抗 (1/4 W) | 330 Ω |
| D2 | LED (赤、光源) | V<sub>F</sub> ≈ 1.9 V。透明の高輝度の品が当てやすい |
| — | 電源・信号 | AD3 の Supplies の V+ (5 V)、W1 (0〜4 V・1 kHz の方形波) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力 (CH1)、真っ暗 | 0 V から数 mV | 光電流が 0。MCP6002 のオフセット (最大 ±4.5 mV) だけが残る |
| 出力 (CH1)、D2 が点いている | 約 0.94 V (光電流 20 µA と仮定) | V = I × Rf。I は光の強さに比例する |
| 2 番 (− 入力) の電圧 | ほぼ 0 V (数十 µV) | 仮想接地。PD1 の両端は短絡と同じ |
| 出力の立ち上がり (10〜90 %) | 数 µs (計算 2.3 µs) | 2.2 × Rf × Cf |
| 部屋の明かりのちらつき | 100 Hz か 120 Hz | 電源の周波数 (50 / 60 Hz) の 2 倍 |
| 47 kΩ だけで受けたときの列 13 | 約 −0.32 V (20 µA)、約 −0.36 V (70 µA) | 抵抗で受けると開放電圧に近づき、光に比例しない |

## LTspice での確かめ

`sim/19-photodiode.cir` で図1 を解いた。BPW34 は「光電流 + ダイオード + 接合容量 70 pF」で置き、ダイオードは Vishay の値
(1 mW/cm² で短絡電流 47 µA・開放電圧 350 mV) に合うよう決めた (仮定)。MCP6002 は GBW 1 MHz・スルーレート 0.6 V/µs・出力 5 mV〜4.975 V の模型
(データシートの典型値から作った仮定)。光電流 20 µA と 70 µA、増幅器ありと 47 kΩ だけを `.step` で振った。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力 (光電流 20 µA) | 0.94 V | 0.940 V | 合う |
| 出力 (光電流 70 µA) | 3.29 V | 3.29 V | 合う |
| − 入力の電圧 (20 µA) | ほぼ 0 V | −9 µV | 合う |
| 出力の立ち上がり (10〜90 %) | 数 µs (計算 2.3 µs) | 1.6〜3.9 µs | 合う (光電流が大きいほどスルーレートで遅い) |
| 47 kΩ だけで受けたとき (20 µA) | 約 −0.32 V | −0.317 V | 合う |
| 47 kΩ だけで受けたとき (70 µA) | 約 −0.36 V | −0.358 V | 合う (比例すれば −3.3 V。対数で頭打ち) |

D2 の光で何 µA 出るかは計算していない (距離・向き・LED の明るさで 1 桁以上変わる)。測った出力の高さを 47 kΩ で割って、本文の 20 µA を置き換える。

## 出典

自作。BPW34 の値は Vishay の [BPW34 データシート](https://www.vishay.com/docs/81521/bpw34.pdf) (Basic Characteristics: 短絡電流・開放電圧・接合容量)、
MCP6002 の値は Microchip の [MCP6001/1R/1U/2/4 データシート](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP6001-1R-1U-2-4-1-MHz-Low-Power-Op-Amp-DS20001733L.pdf) (GBWP・スルーレート・出力の振れ)。

参考: [フォトダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/フォトダイオード)、[Transimpedance amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Transimpedance_amplifier)
