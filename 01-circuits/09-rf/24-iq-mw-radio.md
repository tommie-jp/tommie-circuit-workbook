---
book: circuits
chapter: 9
id: 9-24
title: IQ 中波ラジオ — バーアンテナと 74HC4052 と Pico 2 で NHK を聞く
tier: 200
source: 自作
board: BB
era: 今
---

# 9-24 IQ 中波ラジオ — バーアンテナと 74HC4052 と Pico 2 で NHK を聞く

第 9 章の IQ の題の仕上げ。9-22 の Tayloe 検波器と 9-23 の Pico 2 の計算をつなぎ、バーアンテナを付けて
**中波の放送 (531〜1602 kHz、9 kHz おき) を聞く**。IQ の題の中で、本物の電波を受けるのはこの題だけだ。
受けるだけで、電波は出さない。

信号の道は次のとおり。

- **バーアンテナ + ポリバリコン** (9-10 の T1 と 9-2〜9-5 のポリバリコン) で局のあたりに同調し、リンク巻線から取り出す
- **74HC4052 の Tayloe 検波器** (9-22 と同じ形) で、LO と同じ周波数まで一気に下ろす。出てくる I と Q は音声帯の信号
- **MCP6002 の増幅** (I と Q のそれぞれ 10 倍 × 10 倍) で、Pico 2 の ADC が読める大きさにする
- **Pico 2** が LO を作り (PIO)、I と Q を読み (ADC)、計算で AM を復調し、PWM で音にする
- **LM386** (5 V) でスピーカーを鳴らす

この題の流れは次のとおり。

- 説明: LO を Pico 2 の PIO で直に出す理由、LO を局に寄せる方法 (sys クロックの選び直し)、題の芯の実験 (I だけと √(I² + Q²))
- 回路図 3 枚 (図1 アンテナと Tayloe、図2 I と Q の増幅、図3 Pico 2 と音声) と、同じ 3 つに分けた実体配線図 (図4〜図6)
- プログラム (C/C++ が本体、MicroPython は選局と I・Q の大きさの表示だけ) と AD3 の設定
- 計器の画面: Logic で LO (図7)、Scope で I と Q の時間波形 (図8) と XY (図9・図10)、Spectrum で I の中身 (図11)

**LO は Pico 2 の PIO が 2 本で直に出す。**

Tayloe 検波器は、74HC4052 の 4 つの出口 A0〜A3 を LO の 1 周期に 1 回ずつ順に開く。選ぶのは S1・S0 の 2 本で、
**(S1, S0) を 00 → 01 → 11 → 10 (Gray の順) で回すと、出口は A0 → A1 → A3 → A2 の順に開く** (チャネル = 2·S1 + S0)。
A0・A1・A3・A2 が 0°・90°・180°・270° なので、**I = A0 − A3、Q = A1 − A2** になる。番号の順 (A0 → A1 → A2 → A3) で組むと I と Q にならない。9-22 と同じ組だ。

9-22 は 4 倍のクロックを 74HC74 で 1/4 にして S0・S1 を作った。中波の上の端 1602 kHz でそれをすると、
クロックは 1602 × 4 = **6.4 MHz** になり、ブレッドボードの 3 MHz を超える。
そこでこの題は、**Pico 2 の PIO (プログラムで動く入出力の小さな回路) が S0 (GP2) と S1 (GP3) を LO の周波数で直に出す**。
プログラムは `set pins, 0` → `set pins, 1` → `set pins, 3` → `set pins, 2` の 4 命令の繰り返しだけで、1 命令が 1 状態。
ブレッドボードの上を通る一番高い周波数は、LO の 1.6 MHz 以下になる。74HC74 は要らない。

PIO の 1 命令は、sys クロック (CPU とたいていの周辺の回路を動かすクロック) を整数 M で割った時間で進む。4 命令で 1 周期なので

f<sub>LO</sub> = f<sub>sys</sub> ÷ (4 × M)

PIO の分周には小数部もあるが、**小数部は使わない**。小数で割ると、命令の長さが周期ごとに 1 クロックずつ揺れ (ジッタ)、
その揺れが LO の両脇に像 (スプリアス) を作る。像に別の局が乗ると混信になる。

**LO を局に寄せる — sys クロックを局ごとに選び直す。**

sys を 150 MHz に固定して整数 M だけで割ると、LO は 150 MHz ÷ 4M の飛び飛びの値しか取れない。
1602 kHz の近くでは M = 23 で 1630.4 kHz、M = 24 で 1562.5 kHz で、間が 68 kHz も空き、局から 30 kHz 近くずれる。

そこで**局ごとに sys クロックそのものを選び直す**。RP2350 の sys の PLL は

f<sub>sys</sub> = 12 MHz × FBDIV ÷ PD1 ÷ PD2 (VCO = 12 MHz × FBDIV は 750〜1600 MHz、PD1・PD2 は 1〜7)

で、sys を 100〜150 MHz に収める組 (FBDIV・PD1・PD2) は 157 通りある。そのどれかと整数 M の組で、LO を局の近くに置ける。
プログラムは、選局のたびにこの組を全部試し、**局から 1 kHz 以上離れた中で一番近い LO** を選ぶ (1 kHz 以上離す理由は次の節)。
531〜1602 kHz の 120 局のすべてで、残るずれ Δf は **1.0〜2.9 kHz** に収まる (計算値。一番ずれるのは 1503 kHz の 2.88 kHz)。

| 局 | sys | PLL (VCO ÷ PD1 ÷ PD2) | M | LO | Δf = 局 − LO |
| --- | --- | --- | --- | --- | --- |
| 531 kHz | 127.200 MHz | 1272 MHz ÷ 5 ÷ 2 | 60 | 530.000 kHz | +1.000 kHz |
| **594 kHz** | **142.800 MHz** | **1428 MHz ÷ 5 ÷ 2** | **60** | **595.000 kHz** | **−1.000 kHz** |
| 693 kHz | 102.400 MHz | 1536 MHz ÷ 5 ÷ 3 | 37 | 691.892 kHz | +1.108 kHz |
| 954 kHz | 129.600 MHz | 1296 MHz ÷ 5 ÷ 2 | 34 | 952.941 kHz | +1.059 kHz |
| 1134 kHz | 126.857 MHz | 888 MHz ÷ 7 ÷ 1 | 28 | 1132.653 kHz | +1.347 kHz |
| 1503 kHz | 102.400 MHz | 1536 MHz ÷ 5 ÷ 3 | 17 | 1505.882 kHz | −2.882 kHz |
| 1602 kHz | 108.857 MHz | 1524 MHz ÷ 7 ÷ 2 | 17 | 1600.840 kHz | +1.160 kHz |

- 表は計算値。この題の図と数は **594 kHz** (表の太字) で書く
- **ADC は sys を変えても狂わない**。ADC のクロックは USB 用の PLL (48 MHz) から来るので、sys の選び直しの影響を受けない。
  USB のシリアルも同じ 48 MHz で動くので、選局しても切れない
- **PWM は sys で動く**ので、選び直すたびに分周 (wrap の値) を計算し直す。プログラムの `tune()` がする
- 残った Δf は計算で消す。I + jQ を複素数と見て、1 標本ごとに e<sup>+j2πΔf t</sup> を掛けて回し戻すと、局がちょうど 0 Hz に来る (数値の発振器)

**I と Q の回る向き。** この題の並び ((S1, S0) が 00 → 01 → 11 → 10、I = A0 − A3、Q = A1 − A2) では、局が LO より上にある (Δf > 0) と
**Q が I より 90° 進み**、I + jQ = e<sup>−j2πΔf t</sup> と時計回りに回る。だから回し戻すには e<sup>**+**j2πΔf t</sup> を掛ける。
atan2(Q, I) から周波数を出すときは符号が逆になる (9-23 の式と同じ向きで読むなら − を付ける)。
**I と Q を入れ替えるか、S0 と S1 を入れ替えると、この向きは逆になる**。図2 の 2 段目は I も Q も反転するが、
両方が同じだけ反転する (180° 回るだけ) なので、回る向きは変わらない。√(I² + Q²) はどの向きでも変わらない。

**LO を局から 1 kHz 以上離す理由。**

ずれ Δf が 0 なら一番よさそうに見えるが、わざと 1 kHz 以上離す。
I と Q には、増幅のオフセット (MCP6002 で最大 ±4.5 mV、2 段目で 11 倍) と、74HC4052 の電荷の注入による**直流**が乗る。
プログラムは最初に直流を引く (3.9 Hz の高域通過) が、局の搬送波が 0 Hz にいると、**搬送波まで直流と一緒に消える**。
AM の包絡線は搬送波が基準なので、消えると音が歪む。局を 1 kHz 以上離しておけば、直流を引いたあとで回し戻せる。

**前置の同調 (ポリバリコン) と選局 (計算) は役目が違う。**

バーアンテナの同調 (ポリバリコン) は、**局を選ぶのではなく、近くを通すだけ**の前置の同調だ。Q を 50 (目安) とすると、
594 kHz の幅は 594 ÷ 50 ≈ 12 kHz で、9 kHz 隣の局は 5 dB ほどしか落ちない。それでも要るのは、
Tayloe 検波器が方形波で切り替えるので、**LO の 3 倍 (1785 kHz) や 5 倍の局も 1/3・1/5 の大きさで下りてくる**からだ。
同調でそれを落とす。局を選ぶのは IQ と計算で、隣の局 (±9 kHz) は計算の低域通過 (±4 kHz) で落とす。

- ポリバリコンは耳で合わせる。Pico 2 で局を変えたら、音が一番大きくなる所まで回す
- 9-10 のスーパーヘテロダインは、2 連バリコンで局発と同調を一緒に動かした。この題は局発 (LO) を数値で作るので、
  2 連は要らない (トラッキングの苦労が無い)

**題の芯の実験 — I だけで聞くと、なぜ足りないか。**

プログラムには切り替えを 1 つ置く (USB のシリアルに `i` か `e` を送る)。

- **`i` = I だけ** (掛け算 1 つの直接変換と同じ): 回し戻したあとの I = m(t) · cos(2πδ t + φ)。δ は計算で消しきれない残りのずれで、
  Pico 2 と放送局の水晶の差から来る (数十 ppm の目安で、600 kHz なら数 Hz〜数十 Hz)。
  **音が δ の速さで大きくなったり消えたりする**。`o` で回し戻しを切ると δ は Δf (1〜2.9 kHz) になり、音声に唸りが重なって聞き取れない
- **`e` = √(I² + Q²)** (この題の既定): cos と sin の 2 乗の和は 1 なので、δ も φ も消え、AM の包絡線 m(t) がそのまま出る。
  回し戻しを切っても包絡線は変わらない (隣の局が低域通過を抜けてくるだけ)

9-12 と 9-19 で見た「掛け算 1 つでは足りない」が、ここで耳で分かる。

**受けるだけ — 送信の免許は要らない。**

この題は電波を出さない (9-16 の注意の逆)。LO は PIO が出す 3.3 V の方形波で、アンテナとの間には 74HC4052 と
100 Ω がある。リンク巻線に LO の漏れが少し乗るが、バーアンテナは送信には向かないので、出る量はごく小さい (目安。実測していない)。
AD3 の W1・W2 で試験の電波を作るときも、10 pF を通してタンクに入れるだけで、アンテナから出すわけではない。

## 回路図

1 枚では詰まるので、3 枚に分けた。同じ名前の端子 (AN、A0〜A3、VREF、S0、S1、I、Q) はつながっている。
図1 と図2 は 3.3 V (Pico 2 の 3V3 OUT)、図3 の LM386 だけ 5 V (Pico 2 の VBUS = USB の 5 V)。

```circuit
title: 図1 バーアンテナと Tayloe 検波器 (74HC4052、3.3V)
parts:
  W1: sine c1 e1 l=$\mathrm{W1}$
  GW1: ground e1
  Cw1: capacitor c1 c3 10p
  W2: sine i1 k1 l=$\mathrm{W2}$
  GW2: ground k1
  Cw2: capacitor i1 i3 10p
  VC1: capacitor-var g5b0 i5 260p l=$\mathrm{VC}_1$
  GVC: ground i5
  T1: transformer h8
  R1: resistor g10b0 g13b0 100
  AN: port g13b0
  VCC: vcc j12 3.3V
  R2: resistor j12 l12 10k
  R3: resistor l12 n12 10k
  GR3: ground n12
  C1: capacitor l15 n15 1u
  GC1: ground n15
  VREF: port l17
  U1: ic j26 74HC4052
  VCC: vcc f26 3.3V
  GU1: ground m25
  GBN: ground l29a5
  A0: port h22f0
  A1: port i22
  A2: port i22f0
  A3: port j22
  AN: port j30
  S1: port n30
  S0: port o30
  A0: port q21
  CA0: capacitor q21 s21 22n
  GA0: ground s21
  A1: port q24
  CA1: capacitor q24 s24 22n
  GA1: ground s24
  A2: port q27
  CA2: capacitor q27 s27 22n
  GA2: ground s27
  A3: port q30
  CA3: capacitor q30 s30 22n
  GA3: ground s30
  VCC: vcc q33 3.3V
  C3: capacitor q33 s33 100n
  GC3: ground s33
wires:
  - c3 -- g3b0
  - i3 -- g3b0
  - g3b0 -- g5b0
  - T1.A1 -| g5b0
  - T1.A2 -| i5
  - T1.B1 -| g10b0
  - T1.B2 -| l10
  - l10 -- l12
  - l12 -- l15
  - l15 -- l17
  - U1.VCC |- f26
  - h22f0 -| U1.A0
  - i22 -| U1.A1
  - i22f0 -| U1.A2
  - j22 -| U1.A3
  - U1.AN -| j30
  - U1.BN -| l29a5
  - m25 |- U1.GND
  - U1.VEE |- m25a5
  - U1.E |- m26
  - m25 -- m26
  - U1.S1 |- n30
  - U1.S0 |- o30
notes:
  - text f8 small center: バーアンテナ
  - text t25h5 small center: A0 から A3 の 22nF (図5 の基板の入口に挿す)
  - text t33 small center: U1 のそば
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/24-iq-mw-radio-1.svg)

- **T1 (バーアンテナ)** は 9-10 の T1 と同じ中波用 (主巻線 約 330 µH + 結合巻線 (リンク巻線))。
  主巻線と VC1 (ポリバリコン 20〜260 pF) で 531〜1602 kHz に同調する。531 kHz で VC1 + 浮遊容量 ≈ 272 pF (計算値)
- **W1 と W2 (AD3)** は試験の電波。10 pF (Cw1・Cw2) を通してタンクに入れる。放送を聞くときは Cw1・Cw2 ごと外す
- **リンク巻線**の上 (B1) から **R1 (100 Ω)** を通して 74HC4052 の共通端 **AN (PIN 13)** へ。
  下 (B2) は **VREF (1.65 V)** につなぐ。リンク巻線は直流を通すので、AN と 4 つのコンデンサは 1.65 V に偏る (3.3 V の真ん中)。
  VREF は R2・R3 (10 kΩ ずつ) で 3.3 V を半分にし、C1 (1 µF) で交流の GND にする。600 kHz で C1 は 0.27 Ω
- **U1 (74HC4052)** は 3.3 V で動かす。5 V で動かすと H のしきい値が 3.5 V になり、Pico 2 の 3.3 V では切り替わらない。
  E (PIN 6、L で働く)・VEE (PIN 7)・GND (PIN 8) は GND。**B の側は使わない**: 共通端 BN (PIN 3) を GND に落とし、
  B0〜B3 (PIN 1・2・4・5) は開けておく (選ばれた 1 本が GND につながり、残りは浮くだけ)
- U1 はピンを働きで並べた箱で描いた (左にチャネル A0〜A3・B0〜B3、右に共通の AN・BN、下に GND・VEE・E・S0・S1)。
  共通の AN が右にあるので、R1 からの RF は端子 AN を通って箱の右から入り、左のチャネルへ流れる
- **CA0〜CA3 (22 nF)** は A0〜A3 のホールドのコンデンサ。LO の 1/4 周期ずつ、R1 と 74HC4052 のスイッチ (オン抵抗 約 100 Ω) を通して充電される。
  低域通過の角は 1/(2π · 4(R1 + R<sub>on</sub>) · C) = 1/(2π × 800 Ω × 22 nF) ≈ **9.0 kHz** (計算値)。
  AM の片側の帯域 4.5 kHz と、残りのずれ Δf (最大 2.9 kHz) の和 7.4 kHz を通す
- 図1 では Tayloe 検波器の一部として U1 の隣に描いたが、実体配線図では図5 の基板の入口に挿す (理由は「実体配線図」)
- **C3 (100 nF)** は U1 の PIN 16 と PIN 8 のそばに挿すパスコン
- Tayloe 検波器の利得は、I = A0 − A3 の差で取ると入力 (リンク巻線の peak) の約 **1.75 倍** (LTspice、3.3 V・R<sub>on</sub> 100 Ω・R1 100 Ω・47 nF で 1.75 倍。
  22 nF では角が上がるだけで、1 kHz の利得は同じ)

```circuit
title: 図2 I と Q の増幅 (MCP6002、差動で 10 倍と反転で 10 倍)
parts:
  A3: port d1
  R10: resistor d2 d5 100k
  A0: port f1e0c0
  R11: resistor f2e0c0 f5e0c0 100k
  R12: resistor f8e0c0 h8 1M
  R13: resistor b9 b14 1M
  U2B: opamp f12 +down MCP6002
  C10: capacitor f15 f17 1u
  R14: resistor f17 f19 10k
  R15: resistor c19 c24 100k
  U2A: opamp f22e0c0 +down MCP6002
  VREF: port h6
  I: port f27e0c0
  A2: port m1
  R20: resistor m2 m5 100k
  A1: port o1e0c0
  R21: resistor o2e0c0 o5e0c0 100k
  R22: resistor o8e0c0 q8 1M
  R23: resistor k9 k14 1M
  U3B: opamp o12 +down MCP6002
  C20: capacitor o15 o17 1u
  R24: resistor o17 o19 10k
  R25: resistor l19 l24 100k
  U3A: opamp o22e0c0 +down MCP6002
  VREF: port q6
  Q: port o27e0c0
  VCC: vcc c30 3.3V
  C4: capacitor c30 e30 100n
  GC4: ground e30
  VCC: vcc c33 3.3V
  C5: capacitor c33 e33 100n
  GC5: ground e33
wires:
  - d1 -- d2
  - f1e0c0 -- f2e0c0
  - m1 -- m2
  - o1e0c0 -- o2e0c0
  - d5 -- d9
  - d9 -- e9f0i0
  - U2B.- |- e9f0i0
  - d9 -- b9
  - b14 -- f14
  - U2B.out -| f14
  - f14 -- f15
  - f5e0c0 -- f8e0c0
  - U2B.+ |- f8e0c0
  - h6 -- h8
  - h8 -- h20
  - U2A.+ -| h20
  - U2A.- |- f19
  - f19 -- c19
  - c24 -- f24e0c0
  - U2A.out -| f24e0c0
  - f24e0c0 -- f27e0c0
  - m5 -- m9
  - m9 -- n9f0i0
  - U3B.- |- n9f0i0
  - m9 -- k9
  - k14 -- o14
  - U3B.out -| o14
  - o14 -- o15
  - o5e0c0 -- o8e0c0
  - U3B.+ |- o8e0c0
  - q6 -- q8
  - q8 -- q20
  - U3A.+ -| q20
  - U3A.- |- o19
  - o19 -- l19
  - l24 -- o24e0c0
  - U3A.out -| o24e0c0
  - o24e0c0 -- o27e0c0
notes:
  - text e10d5 small center: "6"
  - text f10h5 small center: "5"
  - text e13h5 small center: "7"
  - text e20h5 small center: "2"
  - text g20b5 small center: "3"
  - text f23b6 small center: "1"
  - text n10d5 small center: "6"
  - text o10h5 small center: "5"
  - text n13h5 small center: "7"
  - text n20h5 small center: "2"
  - text p20b5 small center: "3"
  - text o23b6 small center: "1"
  - text g31h5 small center: U2・U3 の PIN 8 と PIN 4 のそば
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/24-iq-mw-radio-2.svg)

- I は U2、Q は U3 (どちらも MCP6002、レール to レールの 2 回路入り)。3.3 V で 0〜3.3 V を振れるので、Pico 2 の ADC の範囲を使い切れる。
  LM358 は出力が電源より 1.5 V 低い所までしか上がらず、TL072 は ± の電源が要るので使わない
- **1 段目は差動増幅 (10 倍)**: I = 10 × (A0 − A3) + VREF。R10・R11 が 100 kΩ、R12・R13 が 1 MΩ。
  入力の抵抗を 100 kΩ と大きくしたのは、22 nF のホールドを重くしないため (Tayloe 側の抵抗 800 Ω の 125 倍)
- **2 段目は反転増幅 (−10 倍)**: C10 (1 µF) と R14 (10 kΩ) で直流を切ってから増やす (角 16 Hz)。
  1 段目のオフセットを 10 倍したものが 2 段目でさらに 10 倍されると、最大 0.45 V も片寄るので、間で切る
- 2 段で **100 倍 (40 dB)**。MCP6002 の GBW は約 1 MHz なので、10 倍の段の帯域は約 90 kHz で、7.4 kHz には十分
- Tayloe と合わせると、リンク巻線から ADC までで **175 倍** (1.75 × 100、+45 dB)。リンク巻線に 1 mV (peak) あれば ADC に 175 mV が来る
- **バーアンテナの出力は測っていない**。近くの局で数百 µV〜数 mV と見込んだ (目安)。足りなければ 9-9 の高周波増幅 1 段を
  リンク巻線と R1 の間に足す。強すぎて ADC が振り切れる (I・Q が 0 V や 3.3 V に張り付く) なら、R15・R25 を 22 kΩ に下げる
- 図の小さな数字は MCP6002 のピンの番号。1 段目は B の回路 (PIN 5・6・7)、2 段目は A の回路 (PIN 1・2・3)。
  電源は PIN 8 (+3.3 V) と PIN 4 (GND) で、C4・C5 (100 nF) をそのそばに挿す

```circuit
title: 図3 Pico 2 (LO の出力・ADC・PWM) と LM386 の音声
parts:
  U1: pico2 k14 mirror
  Q: port j9c0i0
  I: port j9h0g0
  VCC: vcc d9 3.3V
  V5: vcc d11 5V
  GU1: ground p11
  S0: port g18i0i0
  S1: port h18d0g0
  X1:
    type: device
    at: m22b0i0
    label: EC11
    pins: [A, B, C]
  GX1: ground n20a5
  R30: resistor o17f0g0 o19f0g0 10k
  C30: capacitor o20f0g0 q20 2.2n
  GC30: ground q20
  R31: resistor o22f0g0 o24f0g0 10k
  C31: capacitor o26f0g0 q26 2.2n
  GC31: ground q26
  C32: capacitor o27f0g0 o29f0g0 1u
  VR1: potentiometer o30f0g0 q30 l=$\mathrm{VR}_1$
  GVR: ground q30
  U4: ic p37 LM386
  GU4: ground s37
  GIN: ground q32a5
  V5: vcc m36a5 5V
  C33: ecap p41 p43 220u
  SP1: speaker p45 r45 l=$\mathrm{SP}$
  GSP: ground r45
  R32: resistor p40 r40 10
  C34: capacitor r40 t40 47n
  GC34: ground t40
  V5: vcc j46 5V
  C35: ecap j46 l46 100u
  GC35: ground l46
wires:
  - U1.GP27 |- j9c0i0
  - U1.GP26 |- j9h0g0
  - U1.3V3 |- h9d0g0
  - h9d0g0 -- d9
  - U1.VBUS |- f11e0e0
  - f11e0e0 -- d11
  - U1.GND23 |- n11g0
  - n11g0 -- p11
  - U1.GP2 |- g18i0i0
  - U1.GP3 |- h18d0g0
  - U1.GP10 |- l20g0i0
  - X1.A |- l20g0i0
  - U1.GP11 |- m20b0g0
  - X1.B |- m20b0g0
  - X1.C -| n20a5
  - U1.GP15 |- o17f0g0
  - o19f0g0 -- o22f0g0
  - o24f0g0 -- o27f0g0
  - o29f0g0 -- o30f0g0
  - VR1.w -| r31a5
  - r31a5 -- r33a5
  - r33a5 |- U4.-INPUT
  - q32a5 |- U4.+INPUT
  - s37 |- U4.GND
  - m36a5 |- U4.VS
  - U4.VOUT -| p40
  - p40 -- p41
  - p43 -- p45
notes:
  - text q29a5 small right: 10 kΩ
  - text m46 small center: U4 のそば
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/24-iq-mw-radio-3.svg)

- **U1 (Pico 2)** は PC の USB から給電する。**3V3 (PIN 36)** から図1・図2 の 3.3 V を、**VBUS (PIN 40)** から LM386 の 5 V を取る
- **GP2 (PIN 4) = S0、GP3 (PIN 5) = S1**。PIO が LO の 4 状態を出す
- **GP26 (PIN 31) = ADC0 = I、GP27 (PIN 32) = ADC1 = Q**。ADC は 0〜3.3 V を 12 bit で読む (1 LSB = 0.8 mV)
- **GP15 (PIN 20) = PWM**。100 kHz の PWM で音声を出し、R30・C30・R31・C31 (10 kΩ・2.2 nF の 2 段、各段の角 7.2 kHz) で搬送波を落とす。
  100 kHz では 1 段で約 1/14、2 段で約 1/190 になる (計算値)
- C32 (1 µF) で直流を切り、VR1 (10 kΩ、音量) を通して **U4 (LM386)** の -INPUT (PIN 2) へ。+INPUT (PIN 3) は GND。
  LM386 はどちらの入力から入れてもよく、-INPUT から入れると出力の極性が逆になるだけ (音は同じ)。
  LM386 は PIN 1・8 を開けた 20 倍で使う。出力 (PIN 5) は C33 (220 µF) を通してスピーカー (8 Ω) へ。
  R32 (10 Ω) と C34 (47 nF) は発振止め (データシートの標準回路)。C35 (100 µF) は PIN 6 (+5 V) のそばのパスコン
- **X1 (ロータリーエンコーダ EC11)** は A を GP10、B を GP11、C を GND へ。Pico 2 の内蔵のプルアップを使う。1 クリックで 9 kHz 動く (11-8 と同じ読み方)
- LM386 は 4 V 以上で動くので 3.3 V では使えない。5 V にする (README の「電源は 5 V が既定」のとおり)。
  USB の 5 V は PC から 500 mA まで取れ、LM386 の最大 100 mA ほどと Pico 2 の数十 mA で足りる

## 実体配線図

3 枚のブレッドボードに分ける。図4 が図1、図5 が図2、図6 が図3 にあたる。ブレッドボードどうしは、
箱「図5 の基板へ」などと同じ名前のピンを線でつなぐ。赤は + (図4・図5 は 3.3 V、図6 の上のレールは 5 V)、黒は GND、
白は VREF、緑と青は A0〜A3、黄と紫は I と Q、橙はブレッドボードの中のつなぎ。

**ブレッドボードで組んでよい理由。** ブレッドボードの上を通る一番高い周波数は、アンテナからの中波 (1.6 MHz 以下) と、
PIO が出す S0・S1 (LO、1.6 MHz 以下) で、どちらもこの本の決めの 3 MHz に収まる。9-22 のように 4 倍のクロック (6.4 MHz) を通さないのは、このためだ。
電流は Pico 2 と LM386 を合わせて 150 mA ほど (目安) で、ブレッドボード全体の 500 mA にも収まる。

```bread
title: 図4 バーアンテナと Tayloe 検波器のブレッドボード (U1 が 74HC4052)
board: full
parts:
  NEXT:
    type: device
    at: top
    label: 図5 の基板へ
    pins: [VREF, A2, A1, A0, A3]
  PICO:
    type: device
    at: top
    label: 図6 の基板から
    pins: [S0, S1, 3V3, GND]
  AD:
    type: device
    at: bottom
    label: AD3
    pins: [W1, GND, W2]
  VC1:
    type: device
    at: bottom
    label: ポリバリコン
    pins: [A, E]
  T1:
    type: device
    at: bottom
    label: バーアンテナ
    pins: [A1, A2, B2, B1]
  Cw1: capacitor/ceramic h2 h9 10p
  Cw2: capacitor/ceramic f6 f9 10p
  R2: resistor h17 h15 10k
  C1: capacitor/ceramic g17 g21 1u
  R3: resistor c17 c21 10k
  R1: resistor h23 h27 100
  U1: dip16 @ e30 74HC4052
  C3: capacitor/ceramic +t29 -t29 100n
wires:
  - AD.W1 -- j2 yellow
  - AD.GND -- -b4 black
  - AD.W2 -- j6 green
  - VC1.A -- j9 orange
  - VC1.E -- -b11 black
  - T1.A1 -- j13 orange
  - i13 -- i9 orange
  - T1.A2 -- -b14 black
  - T1.B2 -- j17 white
  - T1.B1 -- j23 orange
  - j15 -- +b15 red
  - j21 -- -b21 black
  - a21 -- -t21 black
  - f17 -- e17 white
  - f27 -- e27 orange
  - c27 -- c33 orange
  - a30 -- +t30 red
  - j32 -- -b32 black
  - j35 -- -b35 black
  - j36 -- -b36 black
  - j37 -- -b37 black
  - NEXT.VREF -- a17 white
  - NEXT.A2 -- b31 green
  - NEXT.A1 -- b32 green
  - NEXT.A0 -- b34 blue
  - NEXT.A3 -- b35 blue
  - PICO.S0 -- b36 purple
  - PICO.S1 -- b37 brown
  - PICO.3V3 -- +t45 red
  - PICO.GND -- -t46 black
  - +t63 -- +b63 red
  - -t62 -- -b62 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/24-iq-mw-radio-1.svg)

- U1 (74HC4052) は 30〜37 列で溝をまたぐ (切り欠きを左、PIN 1 は左下の f30)。下の列が PIN 1〜8、上の列が PIN 16〜9
- **アンテナの側は下の段**: AD3 の W1 (黄、j2) は Cw1 (h2〜h9) で、W2 (緑、j6) は Cw2 (f6〜f9) で 9 列のタンクへ入る。
  ポリバリコンの A (j9) とバーアンテナの A1 (j13) を i9〜i13 の橙の線でつなぐ。ポリバリコンの E・バーアンテナの A2・AD3 の GND は下の − レールへ
- **VREF は 17 列**: バーアンテナの B2 (白、j17)、R2 (h17〜h15、15 列から下の + レールへ)、C1 (g17〜g21、21 列は下の − レールへ)。
  e17〜f17 の白い線で上の 17 列へ渡し、R3 (c17〜c21、21 列は上の − レールへ) と、図5 へ行く VREF (白、a17) をつなぐ
- **バーアンテナの B1** (橙、j23) は R1 (h23〜h27) を通り、f27〜e27 で上へ渡して、c27〜c33 の橙の線で AN (PIN 13、33 列) へ
- **U1 の上の列**: VCC (PIN 16、30 列) は a30 から上の + レールへ。C3 は上の + と − のレールの間 (29 列) に挿す。
  A2・A1・A0・A3 (31・32・34・35 列) は図5 の基板へ (緑・緑・青・青)、S0・S1 (36・37 列) は図6 の基板の GP2・GP3 から (紫・茶)
- **U1 の下の列**: BN (32 列)・E (35 列)・VEE (36 列)・GND (37 列) を、それぞれの列から下の − レールへ。B0・B2・B3・B1 は何も挿さない
- 3.3 V と GND は図6 の基板の Pico 2 から来る (上のレールの 45・46 列)。上下の + と − のレールは右端で渡す

```bread
title: 図5 I と Q の増幅のブレッドボード (左の U2 が I、右の U3 が Q)
board: full
parts:
  IN:
    type: device
    at: top
    label: 図4 の基板から
    pins: [3V3, GND, A3, VREF, A0, A2, A1]
  OUT:
    type: device
    at: bottom
    label: 図6 の基板へ
    pins: [I, Q]
  C4: capacitor/ceramic +t18 -t18 100n
  CA3: capacitor/ceramic d6 d3 22n
  CA0: capacitor/ceramic d29 d32 22n
  CA2: capacitor/ceramic d36 d33 22n
  CA1: capacitor/ceramic d59 d62 22n
  C5: capacitor/ceramic +t48 -t48 100n
  U2: dip8 @ e20 MCP6002
  R10: resistor c6 c22 100k
  R11: resistor c29 c23 100k
  R13: resistor a21 a22 1M
  R12: resistor a23 a27 1M
  C10: capacitor/ceramic e16 f16 1u
  R14: resistor g16 g21 10k
  R15: resistor i20 i21 100k
  U3: dip8 @ e50 MCP6002
  R20: resistor c36 c52 100k
  R21: resistor c59 c53 100k
  R23: resistor a51 a52 1M
  R22: resistor a53 a57 1M
  C20: capacitor/ceramic e46 f46 1u
  R24: resistor g46 g51 10k
  R25: resistor i50 i51 100k
wires:
  - IN.3V3 -- +t1 red
  - IN.GND -- -t2 black
  - IN.VREF -- b27 white
  - c27 -- c57 white
  - +t20 -- a20 red
  - IN.A3 -- a6 blue
  - IN.A0 -- a29 blue
  - d21 -- d16 orange
  - e27 -- f27 white
  - g22 -- g27 white
  - j23 -- -b23 black
  - OUT.I -- h20 yellow
  - +t50 -- a50 red
  - IN.A2 -- a36 green
  - IN.A1 -- a59 green
  - d51 -- d46 orange
  - e57 -- f57 white
  - g52 -- g57 white
  - j53 -- -b53 black
  - OUT.Q -- h50 purple
  - -t63 -- -b63 black
  - a3 -- -t3 black
  - a32 -- -t32 black
  - a33 -- -t33 black
  - a62 -- -t62 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/24-iq-mw-radio-2.svg)

- U2 (I) は 20〜23 列、U3 (Q) は 50〜53 列で溝をまたぐ。同じ並びを 30 列ずらしただけ
- **入口**: 図4 の基板の A3 (青、a6) と A0 (青、a29) から、R10 (c6〜c22) と R11 (c29〜c23) で 1 段目の − (PIN 6、22 列) と + (PIN 5、23 列) へ。
  **22 nF のホールド** CA3 (d6〜d3) と CA0 (d29〜d32) は入口の列に挿し、反対の端の列 (3・32 列) を上の − レールへ落とす。
  Q も同じで、A2 (緑、a36) と A1 (緑、a59)、CA2 (d36〜d33) と CA1 (d59〜d62)
- **ホールドのコンデンサを図5 に置いた理由**: 図4 の U1 の出口 (31・32・34・35 列) は隣り合っていて、コンデンサを挿すと図5 へ行く線と重なる。
  A0〜A3 の線を流れるのは 22 nF の充電の電流で、線が 10〜20 cm 延びても、線のインダクタンス (100〜200 nH の目安) は 1 MHz で 1 Ω ほどと、
  R1 + R<sub>on</sub> (200 Ω) に比べて小さい。I と Q の 4 本を同じ長さにそろえる
- **1 段目**: R13 (a21〜a22、1 MΩ) が出力 (PIN 7、21 列) と − の間の帰還。R12 (a23〜a27、1 MΩ) が + を VREF (27 列) へ。
  VREF は図4 から白い線で b27 に来て、c27〜c57 の白い線で U3 の側 (57 列) へも渡す
- **2 段目**: 1 段目の出力 (21 列) から d21〜d16 の橙の線で 16 列へ、C10 (1 µF) は溝をまたいで e16〜f16 に挿す。
  R14 (g16〜g21) で 2 段目の − (PIN 2、21 列の下) へ。R15 (i20〜i21) が出力 (PIN 1、20 列の下) との帰還。
  非反転の入力 (PIN 3、22 列の下) は g22〜g27 の白い線で VREF へ (e27〜f27 の白い線が上と下の 27 列を渡す)
- 出力 I (h20、黄) と Q (h50、紫) を図6 の基板へ。電源は PIN 8 (20・50 列の上) を上の + レールへ、PIN 4 (23・53 列の下) を下の − レールへ。
  C4・C5 は上のレールの間に挿す

```bread
title: 図6 Pico 2 と LM386 のブレッドボード (上の + レールは 5V)
board: full
parts:
  PWR:
    type: device
    at: top
    label: 図4 の基板へ (電源)
    pins: [3V3, GND]
  IQ:
    type: device
    at: top
    label: 図5 の基板から
    pins: [Q, I]
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
  SP:
    type: device
    at: top
    label: スピーカー 8Ω
    pins: ["1", "2"]
  LO:
    type: device
    at: bottom
    label: 図4 の基板へ (LO)
    pins: [S0, S1]
  LA:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO0, DIO1, GND]
  X1:
    type: device
    at: bottom
    label: エンコーダ EC11
    pins: [A, B, C]
  U1: pico2 @ h3
  R30: resistor i22 i26 10k
  C30: capacitor/ceramic j26 -b26 2.2n
  R31: resistor g26 g30 10k
  C31: capacitor/ceramic j30 -b30 2.2n
  C32: capacitor/ceramic h30 h33 1u
  VR1: potentiometer f33(1) f34(W) f35(3) 10k
  U4: dip8 @ e38 LM386
  C35: capacitor/electrolytic +t37 -t37 100u
  C33: capacitor/electrolytic d41 d46 220u
  R32: resistor b41 b44 10
  C34: capacitor/ceramic a44 -t44 47n
wires:
  - a3 -- +t3 red
  - a5 -- -t5 black
  - PWR.3V3 -- a7 red
  - PWR.GND -- -t8 black
  - IQ.Q -- a11 green
  - IQ.I -- a12 yellow
  - SC.2+ -- b11 pink
  - SC.1+ -- b12 orange
  - SC.1- -- -t13 black
  - SC.2- -- -t14 black
  - LO.S0 -- i6 purple
  - LO.S1 -- i7 brown
  - LA.DIO0 -- j6 purple
  - LA.DIO1 -- j7 brown
  - LA.GND -- -b9 black
  - X1.A -- i16 blue
  - X1.B -- i17 blue
  - X1.C -- -b18 black
  - j20 -- -b20 black
  - j35 -- -b35 black
  - i34 -- i40 orange
  - j39 -- -b39 black
  - j41 -- -b41 black
  - a40 -- +t40 red
  - SP.1 -- a46 orange
  - SP.2 -- -t47 black
  - -t63 -- -b63 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/24-iq-mw-radio-3.svg)

- U1 (Pico 2) は 3〜22 列 (下の h 行が PIN 1〜20、上の c 行が PIN 40〜21)。上の + レールは **5 V** (VBUS、3 列から赤い線)
- 3V3 (PIN 36、7 列) は a7 から図4 の基板へ (赤)。GND は GND38 (5 列) から上の − レールへ
- **I と Q**: 図5 の基板から I (黄) を a12 (GP26)、Q (緑) を a11 (GP27) へ。AD3 の Scope の 1+ を b12、2+ を b11 に挿す (1−・2− は GND)
- **S0 と S1**: GP2 (6 列)・GP3 (7 列) の i 行から図4 の基板へ (紫・茶)。AD3 の Logic の DIO0・DIO1 を j6・j7 に挿す
- **エンコーダ**: A を i16 (GP10)、B を i17 (GP11)、C を下の − レールへ
- **音声**: GP15 (22 列) から R30 (i22〜i26)・C30 (26 列から − レール)・R31 (g26〜g30)・C31 (30 列から − レール)・C32 (h30〜h33)。
  VR1 は f33〜f35 (33 列が上、35 列が GND、34 列がワイパー)。ワイパーから i34〜i39 の橙の線で LM386 の -INPUT (PIN 2、39 列の下) へ
- U4 (LM386) は 38〜41 列。+INPUT (PIN 3、40 列)・GND (PIN 4、41 列) を下の − レールへ、VS (PIN 6、40 列の上) を上の + レール (5 V) へ。
  出力 (PIN 5、41 列の上) から C33 (d41〜d46、+ が左) を通してスピーカーへ。R32 (b41〜b44) と C34 (44 列から上の − レール) が発振止め

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | バーアンテナ (中波用、主巻線 約 330 µH + リンク巻線) | 9-10 の T1 と同じもの |
| VC1 | ポリバリコン | 20〜260 pF (1 連。2 連の片方だけ使ってもよい) |
| U1 | 4 回路 2 組のアナログマルチプレクサ | 74HC4052 (DIP-16) |
| U2・U3 | オペアンプ (レール to レール、2 回路) | MCP6002 (DIP-8) |
| U4 | 音声用パワーアンプ | LM386 (DIP-8) |
| U1 (図3) | マイコンボード | Raspberry Pi Pico 2 |
| X1 | ロータリーエンコーダ | EC11 (クリック付き) |
| SP | スピーカー | 8 Ω、0.5 W |
| R1 | 抵抗 | 100 Ω |
| R2・R3・R14・R24・R30・R31 | 抵抗 | 10 kΩ |
| R10・R11・R15・R20・R21・R25 | 抵抗 | 100 kΩ |
| R12・R13・R22・R23 | 抵抗 | 1 MΩ |
| R32 | 抵抗 | 10 Ω |
| CA0〜CA3 | セラミックコンデンサ (ホールド。NP0/C0G がよい) | 22 nF (223) |
| C1・C10・C20・C32 | セラミックコンデンサ | 1 µF (105) |
| C3・C4・C5 | セラミックコンデンサ (パスコン) | 100 nF (104) |
| C30・C31 | セラミックコンデンサ | 2.2 nF (222) |
| C34 | セラミックコンデンサ | 47 nF (473) |
| C33 | 電解コンデンサ (16 V) | 220 µF |
| C35 | 電解コンデンサ (16 V) | 100 µF |
| VR1 | 可変抵抗 (音量) | 10 kΩ |
| Cw1・Cw2 | セラミックコンデンサ (試験の電波を入れる。放送を聞くときは外す) | 10 pF (100) |
| — | 計器・試験の電波 | Analog Discovery 3 (W1・W2、Scope、Logic、Spectrum) |

- 電源は既定の 5 V ではなく、図1・図2 が 3.3 V (Pico 2 の 3V3 OUT)。Pico 2 の GPIO と ADC が 3.3 V なので、74HC4052 と MCP6002 もそろえた。LM386 だけ 5 V
- LM386 は本の標準の部品の表に無い。スピーカーを鳴らせる 8 ピンのアンプで、外付けが少ないので使う (12-6 と同じ)

## 計器の設定

計器は Analog Discovery 3 (AD3) だけを使う。見る周波数は 600 kHz 以下 (W1・W2 と Logic) と 10 kHz 以下 (I・Q) で、AD3 の範囲に収まる。
Logic で LO (S0・S1) を、Scope で I と Q を、Spectrum で I の中身を見る。

### プログラム

プログラムは **C/C++ (Pico SDK) が本体**、MicroPython は選局と I・Q の大きさの表示だけにした。
**MicroPython では音声の計算が間に合わない**: 25 kS/s × 2 本の標本ごとに、回し戻し (sin・cos)・4 次の低域通過 2 本・平方根をするのは、
MicroPython の 1 行に数 µs〜十数 µs かかる速さでは 40 µs に収まらない。ADC を 500 kS/s で DMA に読ませる設定も、MicroPython の標準の `machine.ADC` からはできない。

**C/C++ (Pico SDK)**。`iqradio.c`。

```c
// iqradio.c — IQ 中波ラジオ (Pico 2)
#include <stdio.h>
#include <math.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/clocks.h"
#include "hardware/dma.h"
#include "hardware/pio.h"
#include "hardware/pwm.h"

#define PIN_S0     2              // GP2 = S0、GP3 = S1
#define PIN_ENC_A  10
#define PIN_ENC_B  11
#define PIN_PWM    15
#define FS         25000.0f       // I・Q それぞれの標本化 (Hz)
#define AVG        10             // 1 本あたり 10 個を平均 (250 kS/s → 25 kS/s)
#define OUT_N      50             // 1 ブロックで出す標本 (2 ms)
#define BLOCK      (2 * AVG * OUT_N)  // ADC の生の標本 (I と Q が交互)
#define PWM_HZ     100000.0       // PWM の搬送波
#define MIN_OFS    1000.0         // LO を局から 1 kHz 以上離す
#define F_FIRST    531000
#define F_STEP     9000
#define N_CH       120            // 531〜1602 kHz

// set pins, 0 → 1 → 3 → 2 (S1 S0 = 00 → 01 → 11 → 10)。.pio で書いた 4 行を手で組んだもの
static const uint16_t lo_insn[] = {0xe000, 0xe001, 0xe003, 0xe002};
static const pio_program_t lo_prog = {.instructions = lo_insn, .length = 4, .origin = -1};

typedef struct { uint32_t vco; uint pd1, pd2, m; double sys, lo; } tune_t;
typedef struct { float b0, b1, b2, a1, a2, z1, z2; } biquad_t;

static uint16_t buf[2][BLOCK];
static uint dma_ch[2], sm, slice;
static volatile uint pwm_wrap = 1000;
static volatile float ring[256];
static volatile uint8_t wr, rd;   // 8 bit の添字なので 256 で一周する
static float dphi;                // 回し戻しの 1 標本あたりの角
static int mode = 'e';            // 'e' = √(I² + Q²)、'i' = I だけ
static bool fix_ofs = true;       // 'o' で Δf の回し戻しを切る

// 局 f に一番近い LO (1 kHz 以上離す) を作る PLL と M を探す
static tune_t find_tune(double f) {
    tune_t best = {0};
    double best_e = 1e9;
    for (uint fb = 63; fb <= 133; fb++) {                // VCO = 12 MHz × fb = 756〜1596 MHz
        for (uint p1 = 1; p1 <= 7; p1++) {
            for (uint p2 = 1; p2 <= p1; p2++) {
                double sys = 12e6 * fb / (p1 * p2);
                if (sys < 100e6 || sys > 150e6) continue;
                uint m0 = (uint)(sys / (4.0 * f));
                for (uint m = m0 - 1; m <= m0 + 2; m++) {
                    double lo = sys / (4.0 * m), e = fabs(lo - f);
                    if (e < MIN_OFS) continue;           // 局を 0 Hz に置かない
                    if (e < best_e - 1e-6 || (e < best_e + 1e-6 && sys > best.sys)) {
                        best = (tune_t){12000000u * fb, p1, p2, m, sys, lo};
                        best_e = e;
                    }
                }
            }
        }
    }
    return best;
}

static void tune(double f) {
    tune_t t = find_tune(f);
    set_sys_clock_pll(t.vco, t.pd1, t.pd2);              // ADC と USB は 48 MHz の PLL なので変わらない
    pio_sm_set_clkdiv(pio0, sm, (float)t.m);             // 整数で割る (小数部 0)
    pio_sm_clkdiv_restart(pio0, sm);
    pwm_wrap = (uint)(t.sys / PWM_HZ) - 1;               // PWM は sys で動くので直す
    pwm_set_wrap(slice, pwm_wrap);
    double df = f - t.lo;                                // Δf = 局 − LO
    dphi = (float)(2.0 * M_PI * df / FS);
    printf("%.0f kHz  sys %.3f MHz  LO %.3f kHz  M %u  df %+.0f Hz\n",
           f / 1e3, t.sys / 1e6, t.lo / 1e3, t.m, df);
}

static biquad_t lowpass(float fc, float q) {             // 2 次の低域通過 (双一次変換)
    float w = 2.0f * (float)M_PI * fc / FS, al = sinf(w) / (2.0f * q), c = cosf(w), a0 = 1.0f + al;
    return (biquad_t){(1 - c) / 2 / a0, (1 - c) / a0, (1 - c) / 2 / a0, -2 * c / a0, (1 - al) / a0, 0, 0};
}

static float run(biquad_t *b, float x) {
    float y = b->b0 * x + b->z1;
    b->z1 = b->b1 * x - b->a1 * y + b->z2;
    b->z2 = b->b2 * x - b->a2 * y;
    return y;
}

static bool pwm_tick(repeating_timer_t *t) {             // 25 kHz で 1 標本ずつ PWM へ
    float a = (rd != wr) ? ring[rd++] : 0.0f;
    float lv = 0.5f * (1.0f + 0.8f * a);
    lv = lv < 0.0f ? 0.0f : (lv > 1.0f ? 1.0f : lv);
    pwm_set_gpio_level(PIN_PWM, (uint16_t)(lv * pwm_wrap));
    return true;
}

static void setup(void) {
    uint off = pio_add_program(pio0, &lo_prog);          // LO: PIO の 4 状態
    sm = pio_claim_unused_sm(pio0, true);
    pio_sm_config c = pio_get_default_sm_config();
    sm_config_set_wrap(&c, off, off + 3);
    sm_config_set_set_pins(&c, PIN_S0, 2);
    pio_gpio_init(pio0, PIN_S0);
    pio_gpio_init(pio0, PIN_S0 + 1);
    pio_sm_set_consecutive_pindirs(pio0, sm, PIN_S0, 2, true);
    pio_sm_init(pio0, sm, off, &c);
    pio_sm_set_enabled(pio0, sm, true);

    gpio_set_function(PIN_PWM, GPIO_FUNC_PWM);           // 音声の PWM
    slice = pwm_gpio_to_slice_num(PIN_PWM);
    pwm_set_enabled(slice, true);

    gpio_init(PIN_ENC_A);                                // エンコーダ (内蔵のプルアップ)
    gpio_pull_up(PIN_ENC_A);
    gpio_init(PIN_ENC_B);
    gpio_pull_up(PIN_ENC_B);

    adc_init();                                          // ADC0 = I、ADC1 = Q を交互に 500 kS/s
    adc_gpio_init(26);
    adc_gpio_init(27);
    adc_set_round_robin(0x3);
    adc_select_input(0);
    adc_fifo_setup(true, true, 1, false, false);
    adc_set_clkdiv(0);                                   // 48 MHz ÷ 96 = 500 kS/s
    dma_ch[0] = dma_claim_unused_channel(true);
    dma_ch[1] = dma_claim_unused_channel(true);
    for (int k = 0; k < 2; k++) {                        // 2 本の DMA が交互に buf[0]・buf[1] を埋める
        dma_channel_config d = dma_channel_get_default_config(dma_ch[k]);
        channel_config_set_transfer_data_size(&d, DMA_SIZE_16);
        channel_config_set_read_increment(&d, false);
        channel_config_set_write_increment(&d, true);
        channel_config_set_dreq(&d, DREQ_ADC);
        channel_config_set_chain_to(&d, dma_ch[k ^ 1]);
        dma_channel_configure(dma_ch[k], &d, buf[k], &adc_hw->fifo, BLOCK, false);
    }
}

int main(void) {
    stdio_init_all();
    setup();
    int ch = (594000 - F_FIRST) / F_STEP;                // 最初は 594 kHz
    tune(F_FIRST + ch * F_STEP);
    static repeating_timer_t timer;
    add_repeating_timer_us(-40, pwm_tick, NULL, &timer); // 25 kHz
    dma_channel_start(dma_ch[0]);
    adc_run(true);

    biquad_t lp[4] = {lowpass(4000, 0.5412f), lowpass(4000, 1.3066f),   // 4 次のバターワース
                      lowpass(4000, 0.5412f), lowpass(4000, 1.3066f)};
    float dci = 2048, dcq = 2048, qprev = 2048, ph = 0, car = 1;
    int k = 0, last_a = 1;
    while (true) {
        dma_channel_wait_for_finish_blocking(dma_ch[k]);
        const uint16_t *b = buf[k];
        for (int n = 0; n < OUT_N; n++) {
            float si = 0, sq = 0;
            for (int j = 0; j < AVG; j++) {
                si += b[2 * (n * AVG + j)];              // 偶数が ADC0 (I)
                sq += b[2 * (n * AVG + j) + 1];          // 奇数が ADC1 (Q)。I より 2 µs 遅い
            }
            si /= AVG;
            sq /= AVG;
            float qa = sq - 0.05f * (sq - qprev);        // Q を 2 µs (40 µs の 1/20) 戻す
            qprev = sq;
            dci += (si - dci) * (1.0f / 1024);           // 直流 (1.65 V とオフセット) を引く。角 3.9 Hz
            dcq += (qa - dcq) * (1.0f / 1024);
            float i = si - dci, q = qa - dcq;
            if (fix_ofs) {                               // I + jQ に e^(+j2πΔf t) を掛け、局を 0 Hz へ
                float c = cosf(ph), s = sinf(ph), i2 = i * c - q * s;
                q = i * s + q * c;
                i = i2;
                ph += dphi;
                if (ph > (float)M_PI) ph -= 2.0f * (float)M_PI;
                if (ph < -(float)M_PI) ph += 2.0f * (float)M_PI;
            }
            i = run(&lp[1], run(&lp[0], i));             // ±4 kHz だけ通す (隣の局 ±9 kHz を落とす)
            q = run(&lp[3], run(&lp[2], q));
            float env = sqrtf(i * i + q * q);
            car += (env - car) * (1.0f / 2048);          // 搬送波の大きさ (82 ms の平均)。これで割るのが AGC
            float a = (mode == 'e') ? (env - car) / car : i / car;
            ring[wr++] = a;
        }
        dma_channel_set_write_addr(dma_ch[k], buf[k], false);  // 次の番の書き先を戻す
        k ^= 1;

        int a = gpio_get(PIN_ENC_A);                     // A の立ち下がりで B を見る
        if (last_a && !a) {
            ch += gpio_get(PIN_ENC_B) ? 1 : -1;
            ch = ch < 0 ? 0 : (ch >= N_CH ? N_CH - 1 : ch);
            tune(F_FIRST + ch * F_STEP);
        }
        last_a = a;
        int key = getchar_timeout_us(0);                 // USB のシリアルから i / e / o
        if (key == 'i' || key == 'e') printf("mode %c\n", mode = key);
        if (key == 'o') printf("offset fix %s\n", (fix_ofs = !fix_ofs) ? "on" : "off");
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるもの) と `CMakeLists.txt` を置く。ビルドと書き込みは 9-16 と同じ
(`cmake -B build -DPICO_BOARD=pico2`、`cmake --build build`、BOOTSEL を押しながら USB をつなぎ `build/iqradio.uf2` をコピー)。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(iqradio C CXX ASM)
pico_sdk_init()
add_executable(iqradio iqradio.c)
target_link_libraries(iqradio pico_stdlib hardware_adc hardware_clocks hardware_dma hardware_pio hardware_pwm)
pico_enable_stdio_usb(iqradio 1)
pico_add_extra_outputs(iqradio)
```

- **ADC の交互読みと 2 µs のずれ**: ADC は 1 つしかなく、ADC0 と ADC1 を 1 回ずつ交互に読む。500 kS/s なら I と Q は **2 µs** ずれて取られる。
  音声の帯の端 7.4 kHz (4.5 + 2.9 kHz) で 360° × 7.4 kHz × 2 µs ≈ **5.3°** の位相の誤差になる (計算値)。
  ずれの時間は 2 µs で一定なので、プログラムは Q を 1 標本 (40 µs) の 1/20 だけ前の値の側へ寄せて戻す (`qa` の行)。
  遅い速さ (たとえば 1 本 48 kS/s ずつ) で交互に読むと、ずれは 10 µs、7.4 kHz で約 27° になる。速く回して平均するのはこのため
- **10 個の平均**は、25 kS/s に落とす前の簡単な低域通過も兼ねる (25 kHz の倍数に零点)。前の Tayloe の 9 kHz の角と合わせて、折り返しを抑える
- この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通る (警告なし) ことを確かめた。**実機では動かしていない** (未確認)。
  確かめた数は PLL と M の表 (Python で 120 局を計算) まで

**MicroPython** (選局と I・Q の大きさの表示だけ)。Pico 2 用の MicroPython (`RPI_PICO2`) を入れ、Thonny で実行する。

```python
import machine, rp2, time
from machine import Pin, ADC

@rp2.asm_pio(set_init=(rp2.PIO.OUT_LOW, rp2.PIO.OUT_LOW))
def lo():                     # S1 S0 = 00 → 01 → 11 → 10
    set(pins, 0)
    set(pins, 1)
    set(pins, 3)
    set(pins, 2)

MIN_OFS = 1000                # LO を局から 1 kHz 以上離す
SM0_CLKDIV = 0x50200000 + 0x0C8   # PIO0 の SM0 の分周のレジスタ

def find_tune(f):
    best = None
    for fb in range(63, 134):                    # VCO = 12 MHz × fb
        for p1 in range(1, 8):
            for p2 in range(1, p1 + 1):
                if (12_000_000 * fb) % (p1 * p2 * 1000):
                    continue                     # machine.freq() は kHz の整数だけ
                sys_hz = 12_000_000 * fb // (p1 * p2)
                if not 100_000_000 <= sys_hz <= 150_000_000:
                    continue
                m0 = sys_hz // (4 * f)
                for m in range(m0 - 1, m0 + 3):
                    lo_hz = sys_hz / (4 * m)
                    e = abs(lo_hz - f)
                    if e >= MIN_OFS and (best is None or e < best[0]):
                        best = (e, sys_hz, m, lo_hz)
    return best

def tune(f):
    e, sys_hz, m, lo_hz = find_tune(f)
    machine.freq(sys_hz)
    sm = rp2.StateMachine(0, lo, freq=sys_hz // m, set_base=Pin(2))
    machine.mem32[SM0_CLKDIV] = m << 16          # 分周を整数 M にそろえる (小数部 0)
    sm.active(1)
    print("%d kHz  sys %.3f MHz  LO %.3f kHz  df %+d Hz" % (f // 1000, sys_hz / 1e6, lo_hz / 1e3, f - lo_hz))

adc_i, adc_q = ADC(26), ADC(27)
def levels(n=2000):                              # I と Q の交流分の rms (V)
    xi, xq = [], []
    for _ in range(n):
        xi.append(adc_i.read_u16())
        xq.append(adc_q.read_u16())              # I の 10〜20 µs 後 (目安)
    def rms(x):
        m = sum(x) / len(x)
        return (sum((v - m) ** 2 for v in x) / len(x)) ** 0.5 * 3.3 / 65535
    return rms(xi), rms(xq)

ch = (594_000 - 531_000) // 9_000
tune(531_000 + ch * 9_000)
while True:
    i, q = levels()
    print("I %.3f V  Q %.3f V" % (i, q))
    time.sleep(0.5)
```

- `machine.freq()` は sys を kHz の整数でしか受けないので、使える PLL の組が 157 通りから 100 通りに減る。
  そのぶん LO のずれは大きくなり、120 局で最大 **5.4 kHz** になる (計算値)。音を出さないので、ずれは表示に出るだけ
- `rp2.StateMachine` の `freq=` は分周を小数で決めることがあるので、作ったあとに分周のレジスタ (SM0_CLKDIV、上位 16 bit が整数部) へ M を直に書く
- I と Q を Python の行で 1 回ずつ読むので、2 本の間は 10〜20 µs ずれる (目安。測っていない)。大きさ (rms) を見るだけなら影響しない。
  位相を見るなら C/C++ の 2 µs が要る。**MicroPython は実行していない** (未確認)

**PC のサウンドカードで聞く手もある。** ステレオのライン入力がある PC なら、図5 の I と Q (直流を 1 µF で切って) を左と右に入れ、
SDR のソフト (HDSDR など) で聞ける。昔の SoftRock の形だ。今の PC はマイク (モノラル) の入力しか無いことが多いので、この題は Pico 2 で閉じた。
RTL-SDR などの SDR の受信機が PC に送ってくるのも、この I と Q の標本の列だ (9-23)。

### AD3 の設定

| 項目 | 設定 |
| --- | --- |
| 電源 | Pico 2 を PC の USB へ。AD3 の Supplies は使わない (3.3 V は Pico 2 の 3V3 OUT) |
| Wavegen W1 (試験の局) | Sine、594 kHz、振幅は I の円の半径が 0.2 V になるまで (数十 mV の目安)。図10 だけ Modulation を AM (Sine 400 Hz、30 %) |
| Wavegen W2 (隣の局) | Sine、603 kHz、振幅は W1 と同じ (図11 だけ。ほかの図では止める) |
| ポリバリコン | I の円が一番大きくなる所 (594 kHz に同調) |
| Logic (図7) | DIO0 = S0 (GP2)、DIO1 = S1 (GP3)。標本化 100 MHz、500 ns/div、トリガ DIO0 の立ち上がり。バスは S1 S0 (10 進) |
| Scope (図8) | CH1 = I (GP26)、CH2 = Q (GP27)、1−・2− は GND。どちらも 100 mV/div、Offset −1.65 V。200 µs/div、トリガ CH1 の立ち上がり 1.65 V |
| Scope の XY (図9・図10) | X = CH1 (I)、Y = CH2 (Q)。どちらも 100 mV/div、Offset −1.65 V |
| Spectrum (図11) | CH1 (I)、0〜10 kHz、8192 点 (分解能 3.1 Hz)、窓 Flat Top、縦軸 dBV、Top 10 dBV |

- 試験の電波の大きさは、タンクの Q とリンク巻線の巻数で変わるので、数で決めずに **I の振幅 (0.2 V) で合わせる**。
  リンク巻線の出力に直すと 0.2 V ÷ 175 ≈ **1.1 mV** (peak、計算値)
- AD3 の Scope の入力は約 1 MΩ で、I・Q (MCP6002 の出力) にはほとんど負荷にならない

## 計器の画面

図はどれも計算値 (理想)。594 kHz の局を W1 で作り、LO は 595.000 kHz (Δf = −1.000 kHz)。I と Q の大きさは 0.2 V (peak) に合わせたとした。

```logic
title: 図7 PIO が出す S0 と S1 (594 kHz を受けるとき、LO 595.000 kHz)
device: ad3
time: 500ns/div
start: -500ns
sample: 100MHz
signals:
  S0: dio0 pattern 0110 bit 420.168ns repeat
  S1: dio1 pattern 0011 bit 420.168ns repeat
buses:
  Ch: S1 S0 dec
cursors: [630.252ns, 2310.924ns]
trigger: S0 rising at 420.168ns
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/logic/24-iq-mw-radio.svg)

- S0 は LO の周波数の方形波 (デューティ 50 %)、S1 は S0 より **1/4 周期 (420 ns) 遅れた**同じ方形波
- 下のバス (S1 S0 の 10 進) が **0 → 1 → 3 → 2** と回る。これが 74HC4052 の開く出口 A0 → A1 → A3 → A2 の順
- カーソル X1・X2 は、S0 が H・S1 が L の状態の真ん中 (変わり目から離した所) に 1 周期あけて置いた。
  **ΔX = 1.681 µs、1/ΔX = 595.0 kHz** が LO の周波数 (sys 142.8 MHz ÷ (4 × 60))
- 局を変えて (エンコーダを 1 クリック回して) 周期が表のとおりに変わるのを確かめる。AD3 の Logic は 1 本 32,768 標本まで撮れるので、100 MHz なら 327 µs ぶん

```scope
title: 図8 I と Q (594 kHz の局、LO 595 kHz) — Q が I より 250 µs 遅れる
time: 200us/div
trigger: ch1 rising 1.65V
ch1: {wave: sine 1kHz 200mV offset 1.65V, range: 100mV/div, position: -16.5div}
ch2: {wave: sine 1kHz 200mV offset 1.65V phase -90deg, range: 100mV/div, position: -16.5div}
cursors: [0, 250us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/24-iq-mw-radio-1.svg)

- I も Q も 1.000 kHz の正弦。局 (594 kHz) と LO (595 kHz) の差 |Δf| が、そのまま音の周波数になって出てくる (直接変換)
- **Q が I より 90° (250 µs) 遅れる**。局が LO より**下**にあるとき Q が遅れ、上にあると進む (説明の「I と Q の回る向き」)。
  カーソル X1 は I が 1.65 V を上へ切る所、X2 は Q が同じく上へ切る所で、**ΔX = 250.0 µs**
- エンコーダを回して 603 kHz にすると、LO は別の値になり (表を作ったときと同じ探し方で決まる)、Δf も変わる。
  シリアルに出る `df` と、Scope の周波数と、Q の先・後が合うかを見る

```scope
title: 図9 XY で見る I と Q (変調なし) — 半径 0.2 V の円が 1 秒に 1000 回まわる
view: xy
ch1: {wave: sine 1kHz 200mV offset 1.65V, range: 100mV/div, position: -16.5div}
ch2: {wave: sine 1kHz 200mV offset 1.65V phase -90deg, range: 100mV/div, position: -16.5div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/24-iq-mw-radio-2.svg)

```scope
title: 図10 AM 30 % (400 Hz) をかけると半径が 0.14 V と 0.26 V の間で伸び縮みする
view: xy
ch1: {wave: = 1.65V + 0.2V * (1 + 0.3 * sin(2 * pi * 400Hz * t)) * cos(2 * pi * 1kHz * t), range: 100mV/div, position: -16.5div}
ch2: {wave: = 1.65V + 0.2V * (1 + 0.3 * sin(2 * pi * 400Hz * t)) * sin(2 * pi * 1kHz * t), range: 100mV/div, position: -16.5div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/24-iq-mw-radio-3.svg)

- 図9: 変調の無い局は**半径 0.2 V の円**になり、Δf = 1 kHz の速さ (1 秒に 1000 回) で回る。静止した絵では向きは見えないので、向きは図8 の先後で見る
- 図10: W1 に AM (400 Hz、30 %) を掛けると、**半径が 0.2 × (1 ± 0.3) = 0.14〜0.26 V の間で伸び縮み**する。
  円の回り (位相) は Δf と残りのずれで決まり、半径 (大きさ) が音声。√(I² + Q²) が半径を取り出すので、回り方に関係なく音声だけが残る。
  I だけを見るのは、この絵を横から見て影を取るのと同じで、円が回ると影の長さが勝手に変わる。これが「I だけでは足りない」の絵だ
- 放送を受けると、半径が話し声で不規則に伸び縮みする円になる

```spectrum
title: 図11 I のスペクトル — 局は 1 kHz、隣 (603 kHz) は 8 kHz に下りる
device: ad3
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBV
ref: 10dBV
signal:
  - dc 1.65V
  - sine 1kHz 200mV
  - sine 600Hz 30mV
  - sine 1.4kHz 30mV
  - sine 8kHz 83mV
markers: [1kHz, 600Hz, 1.4kHz, 8kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/24-iq-mw-radio.svg)

- 図11 は I だけのスペクトル。1 kHz (マーカー 1) が局の搬送波で、600 Hz と 1.4 kHz (マーカー 2・3) が 400 Hz の AM の側波
- 8 kHz (マーカー 4) が隣の局 (W2 の 603 kHz)。LO から +8 kHz で、タンク (−5.1 dB、Q 50 の目安) と Tayloe の 9 kHz の角 (−2.5 dB) で少し落ちた。
  **I だけでは、587 kHz (LO の 8 kHz 下) の局も同じ 8 kHz に出て区別できない**。I と Q の両方を使う計算 (回し戻しと複素の低域通過) なら、
  上と下を分けて、594 kHz の局だけを残せる
- 0 Hz の線は I の直流 (1.65 V)。プログラムが最初に引く
- 放送を受けたときの画面は、局の数と強さで変わる (未実測)

## 見るべき値

計算値。I と Q の大きさは W1 で合わせた値で、アンテナの出力に依る値は目安。

| 確かめること | 期待する値 |
| --- | --- |
| 594 kHz を選んだときのシリアルの表示 | `594 kHz  sys 142.800 MHz  LO 595.000 kHz  M 60  df -1000 Hz` |
| LO の周波数 (Logic のカーソル、図7) | ΔX 1.681 µs、1/ΔX 595.0 kHz |
| S1 S0 の並び (Logic のバス、図7) | 0 → 1 → 3 → 2 (A0 → A1 → A3 → A2) |
| 120 局の LO のずれ Δf | 1.0〜2.9 kHz (C/C++。最大は 1503 kHz の 2.88 kHz)。MicroPython は最大 5.4 kHz |
| I と Q の周波数 (Scope、図8) | 1.000 kHz (= \|Δf\|) |
| Q の遅れ (Scope のカーソル、図8) | 250.0 µs (90°)。局が LO より下なので Q が遅れる |
| I と Q の振幅 (図8・図9) | どちらも 400 mV<sub>pp</sub> (0.2 V に合わせた)。2 本の差は 1 割以内が目安 (差が大きいと隣の局の打ち消しが浅くなる) |
| XY の半径 (図10、AM 30 %) | 0.14〜0.26 V の間で 400 Hz で伸び縮み |
| I のスペクトル (図11) | 1 kHz −17.0 dBV、600 Hz と 1.4 kHz −33.5 dBV、隣の局 (8 kHz) −24.6 dBV |
| Tayloe の利得 | リンク巻線の peak の約 1.75 倍 (LTspice) |
| Tayloe の低域の角 | 約 9.0 kHz (22 nF、計算値。47 nF なら 4.2 kHz で、AM の帯を削る) |
| リンク巻線から ADC までの利得 | 約 175 倍 (+45 dB) |
| I と Q の 2 µs のずれ | 7.4 kHz で 5.3°。プログラムで戻す |
| `i` (I だけ) で聞く | 音が数 Hz〜数十 Hz で大きくなったり消えたりする (残りのずれ δ。目安) |
| `e` (√(I² + Q²)) で聞く | 音が途切れない |
| `o` で回し戻しを切って `i` で聞く | Δf (1〜2.9 kHz) の唸りが重なる |
| バーアンテナの出力 (近くの局) | 数百 µV〜数 mV (目安。未実測)。足りなければ 9-9 の高周波増幅を足す |

**比べ: 9-10 のスーパーヘテロダインと 05-etc の時報の受信機。** 9-10 は 455 kHz の IF に下ろして IFT で局を選んだ。
この題は 0 Hz の近くまで下ろし、局を選ぶのは計算の低域通過だ。05-etc/02-radio-clock/02-radio.md (2SC1815 の中波ラジオで NHK の時報を拾う) と同じ局を
この題で受けると、選択度 (隣の局の混ざり方) と、強い局と弱い局の音の大きさの差 (AGC の効き) を聞き比べられる。

## 出典

自作。74HC4052 のピンの並びとチャネルの選び方は TI の CD74HC4052 データシート、MCP6002 のピンと GBW は Microchip のデータシート、
LM386 の標準回路 (20 倍・発振止めの 10 Ω と 47 nF) は TI の LM386 データシート、
Pico 2 のピンと 3V3 OUT・VBUS は [Raspberry Pi Pico 2 データシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf)、
RP2350 の PLL の式と範囲 (VCO 750〜1600 MHz、PD1・PD2 1〜7)・PIO の命令と分周・ADC の 500 kS/s と交互読みは
[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) による。
SDK の関数は [Raspberry Pi Pico SDK のドキュメント](https://www.raspberrypi.com/documentation/pico-sdk/)、MicroPython の `rp2.StateMachine` と
`machine.freq()` は MicroPython の rp2 のドキュメントによる。Tayloe 検波器は D. Tayloe の発表 (2001 年) の形。
PLL と M の表、利得と角の数は計算値で、Tayloe の利得は LTspice のスイッチの模型による。
