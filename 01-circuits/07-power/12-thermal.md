---
book: circuits
chapter: 7
id: 7-12
title: 熱設計 — 放熱と温度の実測
tier: 200
source: 自作
---

# 7-12 熱設計 — 放熱と温度の実測

7-11 の電子負荷は、100 mA を引くと Q1 (IRLZ44N) が約 0.4 W を熱にする。部品の中の温度 (接合部の温度 T<sub>j</sub>) が上がりすぎると、
部品は壊れるか寿命が縮む。熱設計は、**熱の流れを電気の回路と同じ形で考える**。

- 熱の流れ P [W] を電流、温度の差 ΔT [°C] を電圧とみると、**ΔT = P × θ** (θ は熱抵抗 [°C/W]、オームの法則と同じ形)
- 熱抵抗は直列に足せる。接合部 → ケース (θ<sub>JC</sub>) → 放熱器 (θ<sub>CS</sub>、間のグリス) → 周りの空気 (θ<sub>SA</sub>)
- 部品と放熱器には熱容量 (J/K) がある。電気のコンデンサと同じで、温度は時定数 τ = θ × 熱容量 で指数関数のように上がる

IRLZ44N のデータシートでは、放熱器なしの θ<sub>JA</sub> (接合部 → 周り) が 62 °C/W、θ<sub>JC</sub> が 1.4 °C/W、θ<sub>CS</sub> (グリスを塗った平らな面) が 0.5 °C/W。
この題では、7-11 の基板に温度センサー LM35 (10 mV/°C) を足して Q1 のタブ (ケース) の温度を測り、放熱器の有無で上がり方を比べる。
測った温度の上昇と電力から、熱抵抗を逆に求める。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 7-11 の電子負荷に温度センサー U2 (LM35) を足す
parts:
  U1: opamp 5,4 +up
  W1: square 1.2,3.6 1.2,5.4 l=$\mathrm{W1}$
  G1: ground 1.2,5.4
  C1: capacitor 3.6,6.4 6.6,6.4 10n
  R2: resistor 3.6,7.6 6,7.6 1k
  Rg: resistor 6.6,4 8.2,4 100
  Q1: nmos-e 9,3.81 IRLZ44N
  Rs: resistor 9,5.4 9,7 10
  G2: ground 9,7
  M2: voltmeter 11.2,5.4 11.2,7 l=$\mathrm{CH2}$
  G3: ground 11.2,7
  B1: battery 12.4,1 12.4,3 5 l=$\mathrm{DUT}$
  G4: ground 12.4,3
  U2:
    type: device
    at: 16,4.6
    label: LM35
    pins: [VS, VOUT, GND]
  VCC: vcc 14.4,3.6 5V
  M1: voltmeter 13.6,5.8 13.6,7.4 l=$\mathrm{CH1}$
  G5: ground 13.6,7.4
  G6: ground 15,7.4
wires:
  - 1.2,3.6 -| U1.+
  - U1.- -| 3.6,6.4
  - 3.6,6.4 -- 3.6,7.6
  - U1.out -- 6.6,4
  - 6.6,4 -- 6.6,6.4
  - 6,7.6 -- 7.8,7.6 -- 7.8,5.4 -- 9,5.4
  - 8.2,4 -| Q1.G
  - Q1.S -- 9,5.4
  - 9,5.4 -- 11.2,5.4
  - Q1.D |- 12.4,1
  - 14.4,3.6 |- U2.VS
  - U2.VOUT -| 13.6,5.8
  - U2.GND -| 15,7.4
notes:
  - text 15,8.4 center: U2 は Q1 のタブに貼る (熱でつながる)
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/12-thermal.svg)

- 電子負荷 (U1・Q1・Rs・R2・C1・Rg・DUT) は 7-11 の図1 と同じ。W1 は直流 1.0 V にして、100 mA を引き続ける
- U2 (LM35) の出力 V<sub>OUT</sub> は 10 mV/°C (25 °C で 250 mV)。電源 V<sub>S</sub> は AD3 の V+ (5 V)。LM35 は電気では Q1 とつながっておらず、
  **熱で**つながる (Q1 の金属のタブに LM35 の平らな面を当て、耐熱のテープで留める。間に放熱用のグリスを薄く塗る)
- IRLZ44N のタブはドレインにつながっている。LM35 の胴は樹脂なので触れてよいが、LM35 のピンや放熱器以外の金物をタブに触れさせない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 7-11 の基板に LM35 (U2) を足す (U2 は Q1 のタブに貼る)
board: half
parts:
  U1: dip8 @ e5 LM358
  C1: capacitor/ceramic c6 c7 10n cap=left
  Rg: resistor d6 d18 100
  R2: resistor b7 b16 1k
  Q1: transistor/to220 j16(S) j17(D) j18(G) IRLZ44N cap=left
  Rs: resistor c16 c21 10 cap=above
  U2: ic3 h21 h22 h23 LM35
  AD:
    type: device
    at: top
    label: AD3 (V+・W1・Scope)
    pins: [V+, GND, W1, 2-, 2+]
  ADB:
    type: device
    at: bottom
    label: AD3 (Scope 1)
    pins: [1+, 1-]
  DUT:
    type: device
    at: top
    label: DUT (5V の電源)
    pins: ["+", "-"]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - a5 -- +t5 red
  - AD.W1 -- a8 yellow
  - g5 -- g6 white
  - j7 -- -b7 black
  - j8 -- -b8 black
  - e18 -- f18 orange
  - e16 -- f16 green
  - a21 -- -t21 black
  - AD.2+ -- a16 green
  - AD.2- -- -t12 black
  - DUT.+ -- a17 purple
  - DUT.- -- -t26 black
  - e17 -- f17 purple
  - -t30 -- -b30 black
  - +t29 -- +b29 red
  - j21 -- +b21 red
  - j23 -- -b23 black
  - ADB.1+ -- j22 blue
  - ADB.1- -- -b25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/12-thermal.svg)

- 7-11 の図2 に U2 (LM35、下のブロックの 21・22・23 列。印字面を手前にして左から V<sub>S</sub>・V<sub>OUT</sub>・GND) を足した。
  U2 を Q1 の右に挿し、ピンを曲げて胴を Q1 のタブに当てる
- 下の + レールは 29 列で上の + レール (AD3 の V+) とつなぎ、U2 の V<sub>S</sub> (21 列) へ配る。GND (23 列) は下の − レールへ
- Scope の 1+ (青) は U2 の V<sub>OUT</sub> (`j22`)、2+ (緑) は Rs の上 (`a16`、7-11 と同じ)
- 放熱器を付けるときは、Q1 をいったん抜いてタブにねじで留め (グリスを塗る)、同じ穴に挿し直す。放熱器がブレッドボードや隣の部品に触れないように向きを決める

## 計器の設定

計器は Analog Discovery 3 の V+ (U1・U2 の電源)、W1 (設定の電圧) と Scope。温度は分の単位でゆっくり変わるので、Scope の時間軸を長くして見る。
W1 は Simple の DC、Offset 1.0 V (100 mA)。Scope は 1+ を LM35、2+ を Rs の上にして、1+ を 100 mV/div、2+ を 500 mV/div、時間軸 60 s/div (1 画面 10 分)。
遅い時間軸では、画面が埋まるまで 10 分かかる。W1 を出すと同時に記録を始める (t = 0 が画面の左端)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 放熱器なし — タブは 10 分で約 24 °C 上がる (CH1 の 240 mV)
time: 60s/div
trigger: ch2 rising 500mV at -5div
ch1: {wave: "= 250mV + step(t) * 239mV * (1 - exp(-t / 91s))", range: 100mV/div, position: -4div}
ch2: {wave: "= 1V * step(t)", range: 500mV/div, position: -4div}
cursors: [0, 600s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/12-thermal-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 放熱器あり (20 °C/W) — 上がりは約 8 °C で、ゆっくり
time: 60s/div
trigger: ch2 rising 500mV at -5div
ch1: {wave: "= 250mV + step(t) * 81mV * (1 - exp(-t / 227s))", range: 100mV/div, position: -4div}
ch2: {wave: "= 1V * step(t)", range: 500mV/div, position: -4div}
cursors: [0, 600s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/12-thermal-2.svg)

図3・図4 は熱の等価回路の LTspice の値 (下) から作った理想の形で、周りの温度を 25 °C とした。図4 の放熱器の 20 °C/W と、熱容量は仮定。
2 つは同じ尺度で、CH1 の 100 mV が 10 °C。

- **図3 (放熱器なし)**: タブの温度は時定数 約 1.5 分で上がり、10 分でほぼ止まる。上がり幅は 239 mV = 約 24 °C。ΔT ÷ P = 24 ÷ 0.395 ≈ 61 °C/W で、
  データシートの θ<sub>JA</sub> 62 °C/W から θ<sub>JC</sub> 1.4 °C/W を引いた値に近い
- **図4 (放熱器あり)**: 上がり幅は約 8 °C で、時定数は約 4 分 (放熱器の熱容量が大きい)。10 分ではまだ少し上がり続けている (X2 で 75 mV)。
  ΔT ÷ P ≈ 20.5 °C/W = θ<sub>CS</sub> + θ<sub>SA</sub>

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U2 | 温度センサー (TO-92) | LM35 (10 mV/°C、0 °C で 0 V) |
| — | 放熱器 (TO-220 用の小型品) | 熱抵抗 θ<sub>SA</sub> 20 °C/W 前後 (品の資料の値。計算はこの値で仮定) |
| — | 放熱用のグリスと耐熱テープ | LM35 と Q1 のタブの間、Q1 と放熱器の間 |
| U1・Q1・Rs・Rg・R2・C1 | 7-11 と同じ | LM358・IRLZ44N・10 Ω (1 W)・100 Ω・1 kΩ・10 nF (103) |
| — | 電源 | U1・U2 は Analog Discovery 3 の V+ (5 V)。DUT は 5 V の USB アダプタ (100 mA) |
| — | 計器・信号源 | Analog Discovery 3 の W1 (直流 1.0 V) と Scope (1+ = LM35、2+ = Rs の上、1−・2− = GND) |

## 見るべき値

表の値は計算値と LTspice の値で、実測ではない (周りの温度は 25 °C とした)。Q1 の電力は、テスターで DUT の電圧と Rs の電圧を測って
P = (V<sub>DUT</sub> − V<sub>Rs</sub>) × V<sub>Rs</sub> ÷ 10 Ω で出す (5 V・1 V なら 0.4 W)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 始める前の LM35 の出力 | 250 mV (25 °C のとき) | 周りの温度。以下はここからの上がり幅で見る |
| 放熱器なし、10 分後のタブの上がり | 約 24 °C (240 mV) | P × (θ<sub>JA</sub> − θ<sub>JC</sub>) = 0.395 × 60.6 |
| 放熱器なしの時定数 (63 % まで) | 約 1.5 分 | TO-220 の胴の熱容量 (1.5 J/K と仮定) × 60.6 °C/W |
| 放熱器あり、十分に待ったあとのタブの上がり | 約 8 °C (81 mV) | P × (θ<sub>CS</sub> + θ<sub>SA</sub>) = 0.395 × 20.5 |
| 放熱器ありの時定数 | 約 4 分 | 放熱器の熱容量 (10 J/K と仮定) が大きい |
| 接合部の温度 (計算) | タブ + 0.4 × 1.4 ≈ タブ + 0.6 °C | θ<sub>JC</sub> が小さいので、タブの温度で接合部をほぼ読める |
| 測った上がり幅から求めた熱抵抗 | ΔT ÷ P | 放熱器の資料の値と比べる。合わなければグリスや当て方を疑う |

**電流を増やすときの見積り**: IRLZ44N の接合部の最高温度は 175 °C (データシート)。周り 40 °C で T<sub>j</sub> を 100 °C までに抑えるなら、
放熱器なしで許せる電力は (100 − 40) ÷ 62 ≈ 1 W、20 °C/W の放熱器なら (100 − 40) ÷ (1.4 + 0.5 + 20) ≈ 2.7 W。
この題の回路はブレッドボードの 1 穴 200 mA の制限があるので、電流は 100 mA のままにする。

## LTspice での確かめ

`sim/12-thermal.cir` で、Q1 の熱を電気の等価回路 (電流 1 A = 1 W、電圧 1 V = 1 °C、抵抗 1 Ω = 1 °C/W、容量 1 F = 1 J/K) にして回した。
電力 0.395 W は 7-11 の LTspice の値。熱抵抗はデータシートの値、放熱器の θ<sub>SA</sub> 20 °C/W と熱容量 (胴 1.5 J/K・放熱器 10 J/K) は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| タブの上がり (放熱器なし、30 分) | 約 24 °C | 23.9 °C | 合う |
| 同じく 10 分 | ほぼ止まる | 23.9 °C | 合う |
| 時定数 (放熱器なし) | 約 1.5 分 | 92 s | 合う |
| タブの上がり (放熱器あり、30 分 / 10 分) | 約 8 °C / 7.5 °C (75 mV) | 8.1 °C / 7.5 °C | 合う |
| 時定数 (放熱器あり) | 約 4 分 | 227 s | 合う |
| 接合部とタブの差 | 約 0.6 °C | 0.55 °C | 合う |

## 出典

自作。

参考: [Infineon IRLZ44N のデータシート](https://www.infineon.com/dgdl/irlz44npbf.pdf?fileId=5546d462533600a40153567217c32725)、[TI LM35 のデータシート](https://www.ti.com/lit/ds/symlink/lm35.pdf)、[熱抵抗 (Wikipedia)](https://ja.wikipedia.org/wiki/熱抵抗)
