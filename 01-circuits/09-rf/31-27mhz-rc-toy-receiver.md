---
book: circuits
chapter: 9
id: 9-31
title: 27 MHz の受信機 (トイラジコン) — 同調・検波・コンパレータで LED を点ける
tier: 200
source: 自作
era: 古
board: [CB, PF]
---

# 9-31 27 MHz の受信機 (トイラジコン) — 同調・検波・コンパレータで LED を点ける

9-14 の送信機 (27.145 MHz、W1 で断続する OOK) の電波を受ける受信機を組む。同じ周波数に合わせた同調回路で受け、
検波した包絡線を LM358 のコンパレータで判定して LED を点ける。送信機を W1 の方形波で断続させ、
受信機の LED が同じ調子で点滅するのを見る。
W1 を 50 Hz にすると LED は 1 秒に 50 回点滅するが、目には連続した光 (やや暗め) に見え、ちらつきはほぼ分からない。
点滅を目で見るときは W1 を 2 Hz に下げる。50 Hz のままの断続は、オシロの波形 (図4) で確かめる。
受信機の高周波部 (図2) は銅張り基板、低周波部 (図3) は perfboard に組む。

> [!WARNING]
> 送信機の扱いは 9-14 の警告のとおり (**微弱無線局**の範囲。増幅段を足したりアンテナを伸ばしたりしない)。
> 実験は机の上 (送受信のアンテナの間 10cm ほど) で行い、電波を出したまま放置しない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 受信機 (同調・検波・LM358 のコンパレータで LED)
parts:
  ANT: antenna 2,3
  Cc: capacitor 4,3 6,3 10p
  L2: inductor 8,3 8,6 1u
  GL2: ground 8,6
  CT2: capacitor-var 10,3 10,6 l=$\mathrm{C_{T2}}$
  GCT2: ground 10,6
  C3: capacitor 12,3 12,6 22p
  GC3: ground 12,6
  D1: diode 14,3 16,3 1SS108
  Cd: capacitor 17,3 17,6 1n
  GCd: ground 17,6
  Rd: resistor 19,3 19,6 100k
  GRd: ground 19,6
  M1: voltmeter 21,3 21,6 l=$\mathrm{CH1}$
  GM1: ground 21,6
  U1: opamp 25,4 +up
  VCC: vcc 20,7 5V
  Rt1: resistor 20,7 20,9 100k
  Rt2: resistor 22,9 22,11 1k
  GRt2: ground 22,11
  Rled: resistor 28,4 30,4 470
  LED: led 32,4 32,7 l=$\mathrm{LED}$
  GLED: ground 32,7
wires:
  - 2,3 -- 4,3
  - 6,3 -- 12,3
  - 12,3 -- 14,3
  - 16,3 -- 21,3
  - 21,3 -| U1.+
  - 20,9 -- 22,9
  - 22,9 -- 24,9
  - 24,9 -| U1.-
  - U1.out -- 28,4
  - 30,4 -- 32,4
notes:
  - text 26,2 blue: "LM358 PIN 5:+ PIN 6:- PIN 7:出力"
  - text 26,11 blue: "PIN 8:+5V PIN 4:GND"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/31-27mhz-rc-toy-receiver.svg)

- **同調**: L2 (1 µH) と C3 (22 pF)・CT2 (5〜30 pF) の並列で 27〜52 pF、
  **22.1〜30.6 MHz** (計算値) を回せる。27.145 MHz には CT2 ≈ 34.4 pF − 22 pF **≈ 12.4 pF**。
  共振のとき L2 のリアクタンスは 2π×27.145 MHz×1 µH **≈ 171 Ω**、Q が 50 なら
  タンクは約 8.5 kΩ の抵抗に見える。アンテナは Cc (10 pF) で弱く結合する
- **検波**: D1 (1SS108、ショットキー) で包絡線を取り出す。Cd (1 nF) と Rd (100 kΩ)
  の時定数は **100 µs** — 27 MHz の周期 (37 ns) よりずっと長く、断続の周期 (20 ms)
  よりずっと短いので、**電波がある間だけ直流が立ち、止まると 0.1 ms ほどで落ちる**
- **判定**: LM358 の 2 回路目をコンパレータに使う。PIN 6 (−) には 5 V を Rt1・Rt2
  (100 kΩ・1 kΩ) で分けた **49.5 mV** (計算値) を入れる。検波の電圧がこれを超えると
  PIN 7 が H (5 V 電源の LM358 で約 3.5 V) になり、LED が点く。LED の電流は
  (3.5−2.0)/470 **≈ 3.2 mA** (目安)
- LM358 は入力の同相範囲が GND を含むので、数十 mV の比較ができる (単電源の OP アンプを選ぶ理由)
- 図の `opamp` 記号は LM358 (DIP8) の 2 回路目 (PIN 5〜7)。電源は PIN 8 = +5 V、PIN 4 = GND。
  使わない 1 回路目は入力 PIN 2・PIN 3 を GND へつなぐ (図3)

## 実体配線図

**銅張り基板にした理由**は 9-14 と同じ (27.145 MHz はブレッドボードも perfboard の目安も超え、同調の容量が 5〜50 pF と小さい)。
組み方 (Manhattan、裏の銅は全面 GND、島と via、基板の大きさと導通の確かめ) も 9-14 のとおり。
受信機で一番大きい同調の島 TANK (22×4mm、88mm²) は、平行板の式 (9-14) で **約 2.1 pF**。合計 34.4 pF の約 6%、
共振は約 3% (0.8 MHz) 下がる。トリマ C<sub>T2</sub> の 5〜30 pF の範囲で追える (目安で、実測はしていない)。

**範囲の確認**: 電圧 5 V、受信機の高周波部の電流は 0 (電源が要らない)、周波数 27.145 MHz は、銅張り基板の範囲 (10 MHz 超〜1 GHz) に収まる。

**低周波の部分を perfboard に分けた理由**: 受信機のうち、LM358 のコンパレータと LED の部分
(図3) は、増幅段 (LM358) と電源の電流の道を持つ低周波の回路で、扱う信号は検波後の 50 Hz の
断続と DC だけ。10 MHz 以下の範囲なので perfboard で足りる。これを高周波の島と同じ銅張り基板に
載せると、切り出しと面積が高くつくうえ、LM358 の電源と LED の電流の道が同調の島の近くを通り、
同調が乱れる。そこで受信機を**図2 (高周波部、銅張り基板) と図3 (低周波部、perfboard) の
2 枚に分ける**。基板どうしのつなぎは 2 本 — 検波の出力 (DET) と GND。GND は図2 の裏の銅から
短い線で図3 の GND の筋 (w 行) の 1 か所へ渡す。送信機 (9-14 の図2) は発振だけの 1 枚なので分けない。
図2・図3 のどちらにも、基板の外の機器 (AD やアンテナの線、基板どうしのつなぎ) を箱で描き、ピンから島や穴へ線を引いてある。
図3 は AD の V+ と GND (Supplies の 5 V) から給電し、受信機の高周波部 (図2) は電源が要らない。
図3 の入口に電源のデカップリング (0.1 µF) は置かない。電流は LED の約 3 mA だけで、信号は 50 Hz の断続なので、電源の揺れが問題にならない (デカップリングは、電流が大きい・速い信号を扱う段で置く)。

### 受信機の高周波部 (銅張り基板)

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 70x50mm
  ground: back
title: 図2 受信機の高周波部 (銅張り基板、Manhattan)
f: 27.145M
copper:
  ANT: pad 8,20 4x4mm
  TANK: pad 27,20 22x4mm
  DET: pad 50,20 12x4mm
  GL2: pad 19,32 4x4mm
  VL2: via 19,32
  GCT: pad 27,32 4x4mm
  VCT: via 27,32
  GC3: pad 35,32 4x4mm
  VC3: via 35,32
  GCd: pad 46,32 4x4mm
  VCd: via 46,32
  GRd: pad 52,32 4x4mm
  VRd: via 52,32
  GAD: pad 60,10 4x4mm
  VAD: via 60,10
parts:
  Cc: capacitor 8,20 17,20 10p
  L2: inductor 19,20 19,32 1u
  CT2: capacitor 27,20 27,32 5-30p
  C3: capacitor 35,20 35,32 22p
  D1: schottky 37,20 45,20 1SS108
  Cd: capacitor 46,20 46,32 1n
  Rd: resistor 52,20 52,32 100k
  AD:
    type: device
    at: 52,-14
    label: Analog Discovery
    pins: 1+ 1- GND
    face: bottom
  WIRE:
    type: device
    at: -22,20
    label: アンテナ線 20cm
    pins: ANT
    face: right
  NEXT:
    type: device
    at: 92,26
    label: 図3 の基板へ
    pins: DET GND
    face: left
wires:
  - AD.1+ -- 50,18 green
  - AD.1- -- 59,9 black
  - AD.GND -- 61,9 black
  - WIRE.ANT -- ANT green
  - 55,20 -- NEXT.DET green
  - NEXT.GND -- GRd black
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/copper/31-27mhz-rc-toy-receiver.svg)

- 銅張り基板は送信機と同じ 5×7cm の横置き (70×50mm)。銅張り基板の外の箱は AD (上)・アンテナの線 (左)・図3 の基板 (右)。
  **図の島と回路図 (図1) の節点の対応**

  | 図の島 | 回路図の節点 (つながるピン) |
  | --- | --- |
  | ANT | Cc の左。**アンテナの線 (20cm、緑)** をここへ |
  | TANK | Cc の右・L2 の上・C<sub>T2</sub> の上・C3 の上・D1 のアノード |
  | DET | D1 のカソード・Cd の上・Rd の上。**検波の出力**。AD の CH1 の 1+ (緑) と、図3 の基板への線 (緑、図3 の PIN 5 へ) をここへ |
  | GND (via の島 5 つ) | L2・C<sub>T2</sub>・C3・Cd・Rd の下。すべて via で裏の GND の面。図3 の基板への GND の線 (黒) は右端の Rd の下の島から |
  | GAD (via の島、右上) | 裏の GND の面。AD の CH1 の 1− と GND (黒) の線をここへ |

- 同調の島 TANK に L2 (19mm)・C<sub>T2</sub> (27mm)・C3 (35mm) の上端を立て、下端は via の島へ落とす。
  D1 (1SS108) は TANK の右端から DET へ渡す。カソードは帯の側
- 右の箱「図3 の基板へ」の DET と GND のピンは、図3 の**下の枠「図2 の基板から」の DET・GND のピン**へ
  そのままつなぐ 2 本の線 (DET は島 DET から、GND は裏の GND の面から)
- 受信機の高周波部は電源が要らないので、AD の V+ はつながない。CH1 の 1+ を DET へ、1− を GND へ当てる
- C<sub>T2</sub> は 30 pF のセラミックトリマ (図の値は範囲の 5〜30 pF)

### 受信機の低周波部 (perfboard)

**perfboard に組む範囲**: 電圧 5 V、電流は LED の約 3.2 mA と数百 µA のしきい値の分圧だけ
(1 本の線あたり 500 mA 以下)、信号は 50 Hz の断続と DC (10 MHz 以下)。ユニバーサル基板は 5×7cm (18×24 穴、
1.6mm の FR-4・両面スルーホール) の 1 枚目で、部品と線の外周に 1 穴の余白を残して収まる。
図は部品面から見た図で、部品のピンはその穴を通して裏の半田面で半田付けする。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 5x7cm
  h: 1.6mm
  material: FR-4
  slots: on
title: 図3 受信機の低周波部 (perfboard 5×7cm、部品面)
points:
  NC_PIN1: i6
parts:
  PREV:
    type: device
    at: z2
    label: 図2 の基板から
    pins: DET GND
  AD:
    type: device
    at: -c4
    label: Analog Discovery
    pins: V+ GND
  SC:
    type: device
    at: z9
    label: AD CH1
    pins: 1+ 1-
  U1: dip8 i9 r90 LM358
  Rt1: resistor e12 i12 100k
  Rt2: resistor k12 q12 1k
  Rled: resistor d15 h15 470
  LED: led i15 m15 red i=3.2mA vf=2.0V
wires:
  - AD.V+ -- c4 red
  - c4 -- c9 red
  - c9 -- c12 red
  - c12 -- e12 red
  - c9 -- i9 red
  - AD.GND -- a5 black
  - a5 -- a18 black
  - a18 -- w18 black
  - w18 -- w15 black
  - w15 -- w12 black
  - w12 -- w10 black
  - w10 -- w6 black
  - w6 -- w5 black
  - w5 -- w3 black
  - PREV.GND -- w3 black
  - l6 -- w6 black
  - j6 -- k6 black
  - k6 -- l6 black
  - q12 -- w12 black
  - m15 -- w15 black
  - PREV.DET -- n2 green
  - n2 -- n4 green
  - n4 -- n9 green
  - SC.1+ -- n9 blue
  - SC.1- -- w10 black
  - n9 -- l9 green
  - i12 -- k12 orange
  - k9 -- k12 orange
  - j9 -- j10 white
  - j10 -- d10 white
  - d10 -- d15 white
  - h15 -- i15 white
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/31-27mhz-rc-toy-receiver.svg)

- 上の c 行の赤い筋が +5 V (AD の V+)、下の w 行の黒い筋が GND。AD の GND は上の a 行を右へ回して 18 列を降ろし、w18 へ。
  AD の箱は 2 つで、左上が電源 (V+・GND)、下の中ほどが CH1 の 1+・1− (AD CH1。1+ は 9 列で n9、1− は 10 列で w10 へ。
  1+ の線は w 行の GND の筋を 1 か所だけ渡る)。
  図2 の基板からの GND はユニバーサル基板の下から w3 へ (2 枚のユニバーサル基板の GND を 1 か所でつなぐ)
- U1 (LM358、DIP8) は 6 列と 9 列をまたいで立て、左の列が上から PIN 1・2・3・4、
  右の列が上から PIN 8・7・6・5 (ピンの名前は胴に刷ってある)。PIN 8 (i9) は c9 から降ろした +5 V へ。
  PIN 4 (l6) は 6 列を w6 へ降ろして GND の筋へ。使わない 1 回路目の入力 PIN 2・PIN 3 (j6・k6) も
  PIN 4 と線で結んで GND へ。PIN 1 (OUT1) は何もつながない
- **検波の出力 (緑)**: 図2 の基板から来る DET を n2 に受け、n 行を右へ走らせて n9、そこから l9
  (LM358 の **PIN 5**) へ上げる。途中で 6 列の GND の線を跨ぐ (図の半円)。
  CH1 の 1+ (青) は 9 列を上って n9 に当てる (図2 の DET の島と同じ電位)。1− (黒) は 10 列を上って w10 の GND の筋へ
- **PIN 6 (k9)** に Rt1 (12 列、上端は c12 から降ろした +5 V) と Rt2 (12 列、下端は w12 の GND の筋へ)。
  PIN 6 から橙の線を k12 へ、Rt1 の下端 i12 からも橙の線を k12 へ。
  ここが 49.5 mV のしきい値
- PIN 7 (j9) から白の線を j10 へ出し、10 列を d10 まで上って d 行を右へ d15 へ (Rt1 への +5 V の枝 (12 列) を跨ぐ)。
  15 列を下って Rled (d15〜h15) → LED (i15〜m15)。LED のカソード (m15) は 15 列を w15 まで下って GND の筋へ。
  白の線を j 行のまま右へ出すと、Rt1 と Rt2 をつなぐ橙の線 (12 列) と交わるので、上へ回した

`copper-fence check` と `perfboard-fence check` のネットリストを合わせると、回路図 (図1) と
同じつながりになる。図1 の D1・Cd・Rd の節点 (図2 の DET) と GND が、図2 の箱
「図3 の基板へ」・図3 の「図2 の基板から」の DET と GND を通ってつながる。図2 の AD は 1+ が DET、
1− と GND が GND、図3 の AD は V+ が +5 V、GND と CH1 の 1− が GND、1+ が DET (図1 の電圧計 CH1 の 1+・1− と同じ)。

## 計器の設定

50 Hz の断続のキーと検波の出力は、Analog Discovery のオシロで波形を見る。送信機は 9-14 の図2 の基板で、AD から給電して W1 で断続する。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (送信機と受信機の両方の +5 V) |
| Wavegen W1 | Square・50 Hz・Amplitude 2.5 V・Offset 2.5 V (0〜5 V) |
| Scope CH2 | W1 (送信機のキー)。2 V/div |
| Scope CH1 | 受信機の検波の出力 (図3 の PIN 5、Rd の上端と同じ電位)。100 mV/div |
| Scope 時間軸 | 5 ms/div、トリガ CH2 の立ち上がり 2.5 V |

送受信のアンテナ (どちらも 20cm の線) を平行に 10cm 離して置く。

## 計器の画面

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 キー (CH2) と受信機の検波出力 (CH1)
time: 5ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 50Hz 0.15V offset 0.15V | rc 0.1ms, range: 100mV/div, position: -3div}
ch2: {wave: square 50Hz 2.5V offset 2.5V, range: 2V/div, position: -2div}
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/31-27mhz-rc-toy-receiver.svg)

CH1 は CH2 と同じ 50 Hz・デューティ 50% で上がり下がりする。高さの 0.3 V は
アンテナの間 10cm での目安で、**距離を離すとすぐ小さくなる** (近くの電界は距離の
2〜3 乗で弱まる)。0.3 V は判定の 49.5 mV の約 6 倍あるので LED は確実に点く (W1 が 50 Hz のときは明るさで確かめ、点滅は W1 を 2 Hz にして見る)。

## 見るべき値

計算値 (「目安」と書いたものは距離や部品のばらつきで変わる)。

| 測る所 | 期待する値 |
| --- | --- |
| 検波の出力 CH1 | 50 Hz・デューティ 50%、最大 約0.3V (目安、10cm)・最小 0 V |
| LM358 PIN 6 の電圧 | 49.5 mV |
| LED | W1 が 50 Hz のとき、点きっぱなしの光に見える (平均の明るさは W1 が DC 5 V のときより暗い)。W1 を 2 Hz に下げると 1 秒に 2 回の点滅が目で分かり、W1 を止めて 0 V にすると消える |
| 受信機の CT2 を回す | 計算 12.4 pF (アンテナとダイオードの容量を入れると 9 pF 前後) で CH1 が最大 |
| アンテナの間を 1m にする | CH1 がほぼ 0 になり LED が点かない (微弱の範囲の目安) |

## LTspice での確かめ

デッキは `sim/14-27mhz-rc-toy-rx.cir` (受信機の同調)。1SS108 は I<sub>S</sub> = 20nA・n = 1.05・R<sub>S</sub> = 5 Ω・C<sub>J0</sub> = 1 pF、
アンテナの容量は 3 pF、L2 は 9-14 の L1 と同じ Q = 50 と置いた。どれも目安から作った仮定で、実測の値ではない。

| 項目 | 本文の計算値 | LTspice | 判定 |
| --- | --- | --- | --- |
| 受信機の同調、CT2 = 12.4 pF | 27.145 MHz | アンテナの容量とダイオードで 26.1 MHz。27.145 MHz には約 9 pF | 直した (注記を足した。トリマの範囲に収まる) |
| 計算だけで確かめた値 | 次の行 | 式による | 合う |

計算だけの値 (式を Python で解いた): 受信機の同調 30.6〜22.1 MHz・CT2 12.38 pF・ωL 170.6 Ω・Q = 50 で 8.5 kΩ、
Cd × Rd = 100 µs、コンパレータのしきい値 49.5 mV、LED の電流 3.19 mA (出力 3.5 V と置いた目安)。

検波の出力 0.3 V (アンテナの間 10cm)・LM358 の出力 3.5 V・LED の電流は、距離や素子で決まる目安で、シミュレーションの対象外。
電波の到達と、島の浮遊容量の実測も対象外 (見積りは本文のとおり)。

## 部品

送信機の部品は 9-14。

| 部品 | 値・型番 | メモ |
| --- | --- | --- |
| L2 | 1 µH (アキシャルのマイクロインダクタ) | |
| C<sub>T2</sub> | セラミックトリマ 5〜30 pF | |
| C3 / Cc | 22 pF / 10 pF | セラミック (C0G) |
| Cd | 1 nF | |
| D1 | 1SS108 (ショットキー) | 1N60 (ゲルマニウム) でも可 |
| Rd / Rt1 / Rt2 / Rled | 100 kΩ / 100 kΩ / 1 kΩ / 470 Ω | |
| U1 | LM358 | 2 回路目だけ使う。1 回路目の入力は GND へ |
| LED | 赤 LED (V<sub>F</sub> 約 2 V) | |
| アンテナ | 線 20cm | 伸ばさない |

## 出典

自作。微弱無線局の規定は 9-14 の出典のとおり
([総務省 電波利用ホームページ「微弱無線局の規定」](https://www.tele.soumu.go.jp/j/ref/material/rule/))。
LM358 のピンの並びは TI のデータシート (LM358、DIP8: PIN 1 = OUT1、PIN 2 = IN1−、
PIN 3 = IN1+、PIN 4 = GND、PIN 5 = IN2+、PIN 6 = IN2−、PIN 7 = OUT2、PIN 8 = V+) による。
