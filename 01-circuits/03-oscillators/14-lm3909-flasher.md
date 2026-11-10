---
book: circuits
chapter: 3
id: 3-14
title: LM3909 (古典) と自動点滅 LED (現代) を並べる
tier: 200
source: National Semiconductor LM3909 データシート (1995) の 1.5V Flasher
era: 古/今
---

# 3-14 LM3909 (古典) と自動点滅 LED (現代) を並べる

**LM3909** は、乾電池 1 本 (1.5 V) で赤い LED を点滅させるための IC (National Semiconductor、1970 年代の古典)。
赤い LED は 1.6〜2 V ないと光らないので、1.5 V の電池をそのままつないでも点かない。LM3909 は**コンデンサを電池に直列に積み上げて、
LED に一瞬だけ約 2 V を掛ける** (昇圧)。外付けは電解コンデンサ 1 個だけで、単 1 電池で 1 年以上点滅を続けられる、とデータシートは言う。
今は製造が終わり、手に入るのは在庫品だけである。

今の同じ役目の部品は**自動点滅 LED** (点滅回路の IC を LED の中に入れた物。例: Kingbright の L-56BID)。3.5〜14 V をつなぐだけで
1.5〜3 Hz で点滅する。外付けの部品は要らないが、1.5 V では動かない。この題では 2 つを同じブレッドボードに並べ、
点滅のしかた (周期・光る時間・要る電圧と電流) を比べる。

**LM3909 のしくみ** (データシートの内部回路図から):

- 光っていない間 (約 1 秒): CT (330 µF。µ はマイクロ) は、+ 側 (2 番 OUT) が中の 400 Ω (Ω はオーム) ×2 で電池の + へ、
  − 側 (8 番) が中の 3 kΩ と LED を通して GND へ引かれ、電池の電圧近くまでゆっくり充電される
- 8 番の電圧が下がり切ると中のトランジスタ (Q1→Q2→Q3) が次々にオンになり、**2 番を GND に落とす**。CT の + 側が GND になるので、
  − 側 (8 番) は GND より約 0.8 V 下へ押し下げられる。6 番 (LED のアノード、中の 12 Ω を通して電池の +) と 8 番の間に
  1.5 V + 0.8 V の約 2 V が掛かり、LED が数 ms だけ光る
- CT の電荷を使い切ると Q3 が切れ、また充電に戻る。平均の電流は 1 mA 足らず

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 LM3909 の 1.5 V 点滅 (左) と自動点滅 LED (右)
parts:
  U1:
    type: device
    at: 3,3
    label: LM3909
    pins: [5_V+, 6_RL, 2_OUT, 8_SLOW, 1_FAST, 4_V-]
    turn: mirror
  VCC: vcc 9,1 1.5V
  D1: led 8,2.75 8,5 red
  CT: ecap 6,3 6,5 330u
  G1: ground 4.5,3.75
  M1: voltmeter 10,5 10,6.5 l=$\mathrm{CH1}$
  G2: ground 10,6.5
  G3: ground 13,2 r180
  D2: led 13,2 13,3.5 L-56BID
  RS: resistor 13,3.5 13,5 10
  VEE: vee 13,5 5V
  M2: voltmeter 14.5,3.5 14.5,5 l=$\mathrm{CH2}$
wires:
  - U1.5_V+ -| 9,1
  - U1.6_RL -- 8,2.75
  - U1.2_OUT -- 6,3
  - U1.8_SLOW -- 4.75,3.25
  - U1.1_FAST -- 4.75,3.5
  - 4.75,3.25 -- 4.75,3.5
  - 4.75,3.5 -- 4.75,5
  - 4.75,5 -- 6,5
  - 6,5 -- 8,5
  - 8,5 -- 10,5
  - U1.4_V- -- 4.5,3.75
  - 13,3.5 -- 14.5,3.5
  - 13,5 -- 14.5,5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/14-lm3909-flasher.svg)

- 図1 の左がデータシートの「1.5V Flasher」の接続。LED は 6 番 (RL) から 8 番 (SLOW RC) へ、CT は 2 番 (OUT、+) と 8 番 (−) の間、
  **8 番と 1 番 (FAST RC) はつなぐ**。電源は 5 番 (V+) に +1.5 V、4 番 (V−) に GND。箱のピンの名前の数字は DIP の番号 (3・7 番は使わない)
- 右が自動点滅 LED。アノードを GND、カソードを 10 Ω を通して −5 V につなぐ (LED から見れば 5 V)。RS の両端を CH2 で差動に測り、LED の電流を見る
- CH1 は 8 番 (LED のカソードと CT の − 側) の電圧

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (左が LM3909、右が自動点滅 LED)
# 上の + レールは 1.5 V (AD3 の V+)、上と下の − レールは GND。−5 V (AD3 の V−) はレールに入れず 27 列だけに。下の + レールは使わない
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 (V+ 1.5V・GND・CH1)
    pins: [V+, GND, 1-, 1+]
  AD1:
    type: device
    at: bottom
    label: AD3 (V− −5V・CH2)
    pins: [2+, V-, 2-]
  U1: dip8 @ e10 LM3909
  D1: led b12(A) b10(K) red i=45mA vf=2.1V
  CT: capacitor/electrolytic i11(+) i8(-) 330uF v=6.3V
  D2: led b20(A) b22(K) red i=11mA
  RS: resistor g22 g27 10
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - +t13 -- a13 red
  - d10 -- d8 orange
  - e8 -- f8 orange
  - g8 -- g10 orange
  - -t1 -- -b1 black
  - j13 -- -b13 black
  - -t20 -- a20 black
  - e22 -- f22 white
  - AD.1+ -- a8 yellow
  - AD.1- -- -t5 black
  - AD1.V- -- j27 blue
  - AD1.2+ -- j22 green
  - AD1.2- -- i27 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/14-lm3909-flasher.svg)

図2 は左に LM3909 の回路、右に自動点滅 LED の回路を置いた。2 つは電源が違う (LM3909 は 1.5 V、自動点滅 LED は −5 V) が、GND は共通。

- 電源は AD3 の Supplies。**V+ を 1.5 V にして** 上の + レールへ (5 V のままにしないこと。1.5V Flasher の接続は 1.5 V 用で、LED の電流を止める物が無い)。
  **V− を −5 V にして**、レールに入れず 27 列へ直接挿す (青)。上と下の − レールは GND で、1 列の黒い線でつなぐ
- LM3909 は 10〜13 列に溝をまたいで挿す (切り欠きを左、1 番が左下の `f10`)。表に無い型番なので、図の胴にはピンの番号だけが出る
- 8 番 (`e10`) と 1 番 (`f10`) は、IC の左を回る橙の線 (`d10`–`d8`、`e8`–`f8`、`g8`–`g10`) でつなぐ。D1 は 12 列 (6 番) から 10 列 (8 番) へ、
  CT は + を 11 列 (2 番)、− を 8 列 (8 番と 1 番の節点) に挿す
- 5 番 (`e13`) は上の + レール (1.5 V) へ、4 番 (`f13`) は下の − レール (GND) へ
- 自動点滅 LED (D2) はアノードを 20 列 (上の − レールから GND)、カソードを 22 列に挿す。22 列から白の線で下のブロックへ渡し、RS (`g22`–`g27`) を通して 27 列 (−5 V) へ
- Scope の 1+ (黄) は 8 番の節点 (`a8`)、1− は GND。2+ (緑) は RS の上 (`j22`)、2− (青) は RS の下 (`i27`)。CH2 は差動で RS の両端を測る

## 計器の設定

オシロには AD3 の Scope を使う。1 Hz 前後の点滅の周期と、数 ms の LED のパルスを時間の波形で見る題で、10 MHz よりずっと遅いから。

| 設定 | 値 |
| --- | --- |
| Supplies | V+ 1.5 V、V− −5 V |
| Scope CH1 (LM3909 の 8 番) | DC、500 mV/div |
| Scope CH2 (RS の両端、差動) | DC、50 mV/div |
| Time | 200 ms/div (2 秒に LM3909 の点滅が約 2 回) |
| Trigger | CH1、立ち下がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 LM3909 (CH1) は約 1 秒ごと、自動点滅 LED (CH2) は約 2 Hz
time: 200ms/div
trigger: ch1 falling 0V
ch1: {wave: "= 0.6V - 1.37V * step(sin(2 * pi * 1.072Hz * t) - 0.99991)", range: 500mV/div, position: 0div}
ch2: {wave: "= 10mV + 110mV * step(sin(2 * pi * 2Hz * t))", range: 50mV/div, position: -3div}
cursors: [-100ms, 832.8ms]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/14-lm3909-flasher.svg)

図3 は想定の波形で、実測ではない。CH1 は LTspice の値 (周期 0.933 秒、一番低い所 −0.77 V) で、点滅の間の 8 番は 1.0 V から 0.4 V へゆっくり下がるが、
ここでは 0.6 V の一定で描いた。LED が光るのは CH1 が下へ落ちた細いパルス (幅 約 4 ms) の間だけ。カーソルの間隔 0.933 秒が LM3909 の 1 周期。
CH2 の周期 (2 Hz) と電流 (11 mA ほど) は**目安**で、データシートの範囲 (1.5〜3 Hz、3.5 V で 8 mA・14 V で 44 mA) から置いた。測って書き直す。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | LED フラッシャー IC (製造終了。在庫品) | LM3909 (DIP-8) |
| CT | 電解コンデンサ | 330 µF・6.3 V 以上 (データシートの 300 µF に近い E6 の値) |
| D1 | LED (赤、5 mm) | 1 mA で V<sub>F</sub> 2.1 V 以下の物 (データシートの条件) |
| D2 | 自動点滅 LED (赤、5 mm、点滅の IC 入り) | Kingbright L-56BID (3.5〜14 V) |
| RS | 抵抗 (D2 の電流を測る) | 10 Ω |
| — | 電源 | AD3 の Supplies: V+ 1.5 V (乾電池 1 本の代わり。LM3909 の題材そのもの)、V− −5 V (D2 用) |
| — | 計器 | AD3 の Scope 1+/1−・2+/2− |

D2 は逆向きの電圧に弱い (逆電圧の最大 0.5 V。データシート)。挿す向きを間違えて −5 V を逆に掛けないよう、アノード (長いピン) を GND の側にする。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| LM3909 の点滅の周期 (CH1) | 約 0.9〜1 秒 (データシート: 300 µF で 0.65〜1.3 Hz、典型 1 Hz) | CT の値で決まる。CT を半分にすると約 2 倍の速さ |
| 光る時間 (CH1 が下へ落ちている幅) | 数 ms (データシート: 350 µF で 6 ms、LTspice で約 4 ms) | 光るのは一瞬。目には残像で 1 回の光に見える |
| 8 番の一番低い所 (CH1) | 約 −0.8 V | CT が GND より下へ押し下げた分。LED に掛かる電圧は 1.5 V + この分 |
| LM3909 の平均の電流 (Supplies の V+ の表示) | 1 mA 足らず (データシート: 1.4 V で典型 0.55 mA) | 電池が長くもつ理由 |
| V+ を 1.2 V に下げたとき | まだ点滅する (データシート: 1.15 V から) | 古くなった電池でも光る |
| 自動点滅 LED の周期 (CH2) | 0.33〜0.67 秒 (1.5〜3 Hz。データシート) | 電圧で少し変わる |
| 自動点滅 LED の電流 (CH2 ÷ 10 Ω) | 十数 mA (目安。3.5 V で 8 mA) | LM3909 の平均の 10 倍以上。光る時間が長く明るい代わりに電流が多い |

まとめると、LM3909 は「1.5 V・平均 1 mA 足らず・一瞬だけ光る」、自動点滅 LED は「3.5 V 以上・十数 mA・半分の時間光る」。
電池 1 本で長くもたせるなら LM3909 の考え方 (コンデンサで昇圧して一瞬だけ光らせる) が今も役に立つ。5-5 の Joule thief もコイルで同じことをする。

## LTspice での確かめ

`sim/14-lm3909.cir` で LM3909 の 1.5V Flasher を 12 秒の過渡解析で走らせた。LM3909 の中は、データシートの内部回路図の抵抗値とつながりのとおりに組み、
トランジスタとツェナーは汎用の模型を当てた (仮定。2 つのコレクタの横型 PNP は PNP 2 個で表した)。LED は 3-1 と同じ赤の模型。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 点滅の周期 (330 µF) | 約 0.9〜1 秒 (データシート 0.77〜1.5 秒) | 0.933 秒 (1.07 Hz) | 合う (データシートの範囲の中) |
| 8 番の一番低い所 | 約 −0.8 V | −0.77 V | 合う |
| LED に掛かる電圧の山 | 約 2 V | 2.08 V | 合う |
| 光る時間 (山の半分の幅) | 数 ms (データシート 6 ms) | 4.1 ms | 近い (模型のトランジスタの強さで短い) |
| LED の電流の山 | データシート 45 mA (350 µF) | 15.8 mA | 合わない (模型の Q3 が弱い。電流の山は実測で書き直す) |
| 平均の電流 | 1 mA 足らず (データシート 0.55 mA 典型・0.75 mA 最大) | 0.88 mA | 近い (データシートの最大より 2 割多い) |

自動点滅 LED の中の IC は回路が公開されていないので模型を作れず、LTspice では確かめていない (対象外。周期と電流はデータシートの範囲だけを書いた)。

## 出典

[LM3909 LED Flasher/Oscillator データシート (National Semiconductor, TL/H/7969, 1995)](https://www.komponenten.es.aau.dk/fileadmin/komponenten/Data_Sheet/Linear/LM3909.pdf) の
「1.5V Flasher」の接続と内部回路図 (図は描き直した)。

[L-56BID 5 mm 点滅 LED データシート (Kingbright。共立電子の掲載)](https://kyohritsu.com/eclib/OTHER/DATASHEET/LED/l56bid.pdf) の動作電圧・点滅の周波数・電流。

参考: [Reverse-engineering a low-power LED flasher chip (Ken Shirriff, 2021)](https://www.righto.com/2021/01/reverse-engineering-low-power-led.html)
