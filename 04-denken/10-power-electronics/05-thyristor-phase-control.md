---
book: denken
chapter: 10
id: 10-5
title: サイリスタの位相制御 — 点弧角で平均電圧 (低圧 AC)
tier: 100
source: 自作
board: BB
---

# 10-5 サイリスタの位相制御 — 点弧角で平均電圧 (低圧 AC)

サイリスタはゲートに電流を入れた瞬間にオンになり、その後はゲートを止めても、主電流が 0 になるまでオンのまま (自己保持)。
交流の正の半周期のどこでゲートを入れるか (**点弧角 α**) で、負荷に掛かる時間が変わり、平均電圧が変わる。
AD の波形発生器の 2 ch を同期させ、W1 を低い電圧の交流 (50 Hz)、W2 をゲートのパルスにして、α と平均電圧の関係を確かめる。
商用電源には繋がない。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vavg = (Vm / 2π) × (1 + cos α) | 単相半波の位相制御 (抵抗負荷) の平均電圧。Vm は交流の振幅 |
| α = 0° で Vm / π | 半波整流 (10-1) と同じ |
| α = 180° で 0 | ゲートを入れる前に半周期が終わる |

Vm = 5 V なら、α = 90° で Vavg = 5 / (2π) = 0.796 V。

## 回路図

```circuit
title: 図1 サイリスタの半波の位相制御
style:
  standard: jis
  pitch: 1.2
parts:
  W1: sine c1 i1 l=$\mathrm{W1}$
  M1: voltmeter c3 i3 l=$\mathrm{CH1}$
  RL: resistor c5 c8 470
  M2: voltmeter a5 a8 l=$\mathrm{CH2}$
  Q1: thyristor c10 i10 2N5064
  RG: resistor g13 g11 1k
  W2: square g14 i14 l=$\mathrm{W2}$
  G1: ground i1
wires:
  - c1 -- c3 -- c5
  - a5 -- c5
  - a8 -- c8
  - c8 -- c10
  - Q1.g -| g11
  - g13 -- g14
  - i1 -- i3 -- i10 -- i14
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/circuit/05-thyristor-phase-control.svg)

- W1 は AD の Wavegen の 1 ch 目 (Sine、50 Hz、振幅 5 V)。商用の周波数に見立てた低い電圧の交流
- W2 は 2 ch 目のパルス (0〜5 V、50 Hz、幅 1 ms)。W1 に同期させ、位相を α だけずらす。RG (1 kΩ) でゲートの電流を約 4.4 mA にする
  (2N5064 の点弧に要るゲート電流は 200 µA 以下)
- Q1 は 2N5064 (TO-92 の小さなサイリスタ、感度の高いゲート)。カソードを GND に置くので、ゲートの駆動も GND 基準で済む。
  2N5064 が手に入らないときは、同じ TO-92 で感度の高いゲート (200 µA) の MCR100-6 などで置き換えられる。
  ただし MCR100-6 は作るメーカーで足の並びが違う (onsemi は K・G・A、ほかに G・A・K の品がある) ので、買った品のデータシートで確かめる
- RL (470 Ω) は負荷。電流の山は約 9 mA で、AD の波形発生器の目安 (10 mA、0-1) に収まる
- M1 (CH1) は W1 (電源の電圧)、M2 (CH2) は RL の両端 (差動、負荷の電圧)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の青レール = GND
board: half
parts:
  Q1: thyristor c14(K) c15(G) c16(A) 2N5064
  RL: resistor h8 h16 470
  RG: resistor b15 b20 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 2+, 1-, 2-, W2]
wires:
  - AD.W1 -- a8 yellow
  - AD.1+ -- b8 orange
  - AD.2+ -- c8 blue
  - e8 -- f8 yellow
  - e16 -- f16 white
  - AD.2- -- a16 white
  - a14 -- -t14 black
  - AD.W2 -- a20 green
  - AD.GND -- -t5 black
  - AD.1- -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/breadboard/05-thyristor-phase-control.svg)

- Q1 (2N5064) は平らな面を手前にして左から K・G・A (14・15・16 列)。K を青レール (GND) へ
- 8 列が W1。溝を渡って下の 8 列から RL (h8→h16) が 16 列 (A) へ。16 列は溝を渡る白い線で上の A とつなぐ
- RG (b15→b20) がゲート (15 列) と W2 (20 列) の間
- CH1 (1+) は b8 (W1)、1− は青レール。CH2 は RL の両端で、2+ を c8、2− を a16 (A)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | Channels を Synchronized に。W1: Sine、50 Hz、Amplitude 5 V。W2: Pulse (または Square)、50 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)、Symmetry 5 % (幅 1 ms)、Phase を α に |
| Scope | CH1 = W1。CH2 = RL の両端 (差動)。2 V/div、Time base 5 ms/div |
| Measure | CH2 の Average (Vavg) |

W2 の Phase の向き (進みか遅れか) は画面で確かめる。W2 の立ち上がりが W1 の 0 V の上りから α だけ後に来ればよい
(逆なら 360° − α を入れる)。α は 30°〜120° で変える。150° 以上では点弧の瞬間の電流が小さく (2 mA 台)、
保持電流を下回ってすぐ切れることがある。パルスは正の半周期の中で終わるように (α + 18° < 180°) 置く。

α = 90° の画面。CH2 は W1 の山の頂点 (90°) から後だけが出る。

```scope
title: 図3 α 90° — 負荷の電圧 (CH2) は 90° から 180° だけ、平均 0.796 V
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 50Hz 5V, range: 2V/div}
ch2: {wave: = 5V * sin(2 * pi * 50Hz * t) * step(sin(2 * pi * 50Hz * t)) * step(-cos(2 * pi * 50Hz * t)), range: 2V/div}
measure: [avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/scope/05-thyristor-phase-control.svg)

図はサイリスタの電圧降下を 0 とした理想。実物ではオンの間 Q1 に約 0.8 V (目安) が残り、CH2 の山がその分低い。

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH2 は RL の両端 (8 列と 16 列) を差動で挟んでいる。16 列 (アノード) は GND ではないので、グランドクリップを当てると
Q1 が短絡され、位相制御にならない (RL に交流がそのまま掛かる)。負荷の電圧は振れの大部分を占めるので、
**回路はそのままで、CH1 の先端を 8 列 (W1)、CH2 の先端を 16 列 (アノード) に当て、CH1 − CH2 で負荷の電圧を作る**。
グランドクリップは 2 本とも青レール。

- 要るのは **位相をずらせる同期した 2 ch の発振器**。1 ch 目を Sine 50 Hz 振幅 5 V、2 ch 目を Pulse 50 Hz・幅 1 ms・0〜5 V にし、
  2 ch 目の位相を α に合わせる (機種の「位相の同期」の機能)。1 ch の発振器しかなければ、この題はできない
  (ゲートのパルスを交流に同期させる回路が別に要る)
- FG の 50 Ω: 負荷は 470 Ω なので、Q1 がオンの間は振幅が 5 × 470 / 520 = 4.52 V に下がる (計算値)。
  そのとき α = 90° の平均は 0.72 V (計算値)。表示の振幅を 5.5 V に上げれば 5 V に戻る
- Vavg は Math の CH1 − CH2 の Mean。Math に Measure を当てられない機種は CH1 と CH2 の Mean の差 (CH1 の Mean は 0)

## 見るべき値

計算値 (Vm = 5 V、サイリスタの電圧降下は 0 とした理想)。

| α | Vavg = (Vm / 2π)(1 + cos α) | 分かること |
| --- | --- | --- |
| 30° | 1.48 V | ほぼ半波整流 (1.59 V) |
| 60° | 1.19 V | |
| 90° | **0.796 V** | 半波整流の半分 |
| 120° | 0.398 V | |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH2 の Average (α = 90°) | 0.796 V | 位相で平均電圧が決まる |

- **ゲートは点弧の瞬間だけ働き、切るのは電流が 0 になる時 (電源の負の半周期)。** 交流の電源なら自然に切れる (自然転流)。
  直流の電源ではゲートで切れないので、10-3 のチョッパは MOSFET を使う
- 実物では Q1 の電圧降下 (約 0.8 V) の分、各行が 0.1 V ほど低く出る
- 両方の半周期を制御するのが全波の位相制御 (Vavg = (Vm / π)(1 + cos α)) で、2 つのサイリスタかトライアック (10-9) で組む

## 出典

自作。2N5064 の足の並びとゲートの電流は onsemi の 2N5060 系のデータシート。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
