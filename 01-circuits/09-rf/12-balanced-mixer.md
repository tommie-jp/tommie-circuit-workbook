---
book: circuits
chapter: 9
id: 9-12
title: バランスドミキサー
tier: 200
board: BB
source: 自作
---

# 9-12 バランスドミキサー

**ミキサー**は 2 つの信号を掛け合わせて、**和と差の周波数**を作る部品だ。
スーパーヘテロダイン (9-10) は、受けたい電波 (RF) と局部発振 (LO) を混ぜて、
差の中間周波数 (IF) を取り出す。掛け算は sin a × sin b = ½{cos(a−b) − cos(a+b)} なので、
理想の掛け算器の出力には **f<sub>RF</sub> − f<sub>LO</sub> と f<sub>RF</sub> + f<sub>LO</sub> だけ**が出て、元の LO と RF は出ない。
この題では、その理想に近い「バランスドミキサー」を IC 1 個で組み、Analog Discovery のスペクトルで和と差だけが立つことを確かめる。

ダイオード 1 本で混ぜる**単一ダイオードのミキサー**は、LO で開け閉めするスイッチと見なせる。
開いている間だけ (LO + RF) を通すので、スイッチの関数 s(t) = ½ + (2/π)cos ω<sub>LO</sub>t − … の ½ の項が
**LO と RF をそのまま半分の大きさで通してしまう**。欲しい IF (1/π) より、要らない LO のほうがずっと大きい。

**バランスドミキサー**は、LO の極性で RF の**符号を反転**させる (s(t) を 0/1 ではなく ±1 にする)。
±1 の方形波には直流の項 (½) が無いので、出力に **RF が出ない**。回路を左右対称に組んで、
LO が作る電流も 2 本の出力に同じだけ流す (差を取れば消える) ので、**LO も出ない**。LO と RF の両方を
消すものを**ダブルバランスドミキサー (DBM)** と呼ぶ。

- ダイオードで組む DBM は**ダイオードリング**: ショットキーのダイオード 4 本を輪にし、中点タップのある
  広帯域トランス 2 個で LO と RF を入れて、2 つの中点から IF を取る。受け身の部品だけなので**損をする**。
  理想のスイッチでも各側波は RF の 2/π 倍、**−3.9 dB** (変換損失)。実物はダイオードの抵抗や
  トランスの損で **6〜7 dB** ほど
- この題では、同じ働きをトランジスタで組んだ**ギルバートセル**の IC、**SA612 (NE612)** を使う。
  上の 4 石の対が LO で RF の電流の向きを切り替える (ダイオードリングのスイッチと同じ) うえ、
  電流を 1.5 kΩ の負荷で電圧に戻すので、損ではなく**利得** (変換利得 約 17 dB、データシートの代表値) が出る。
  トランスを巻かずに 5 V で組める
- 周波数は Analog Discovery (AD) で作れる **LO = 1 MHz (W1)、RF = 1.1 MHz (W2)** にする。
  IF は **1.1 − 1.0 = 0.1 MHz (100 kHz)** と **1.1 + 1.0 = 2.1 MHz**

## 回路図

```circuit
title: 図1 SA612 のバランスドミキサー (W2 が RF、W1 が LO)
parts:
  W2: sine e4 g4 l=$\mathrm{W2}$
  G1: ground g4
  C1: capacitor e5 e7 10n
  U1: dip8 f12
  C2: capacitor h9 j9 10n
  G2: ground j9
  G3: ground h10
  VCC: vcc c13 5V
  C6: capacitor c15 e15 100n
  G6: ground e15
  C3: capacitor g16 g18 10n
  W1: sine g19 i19 l=$\mathrm{W1}$
  G4: ground i19
  C5: capacitor k15 k17 100n
  C4: capacitor m15 m17 100n
  M1: voltmeter m19 k19 l=$\mathrm{CH1}$
  M2: voltmeter m21 o21 l=$\mathrm{CH2}$
  G5: ground o21
wires:
  - e4 -- e5
  - e7 -- e8
  - U1.1 -| e8
  - U1.2 -| h9
  - U1.3 -| h10
  - U1.8 -| c13
  - c13 -- c15
  - U1.6 -| g16
  - g18 -- g19
  - U1.5 -| k13
  - k13 -- k15
  - k17 -- k19
  - U1.4 -| m11
  - m11 -- m15
  - m17 -- m21
notes:
  - text g12h5 small right: SA612
  - text e10 small center: PIN 1 IN_A
  - text l11h5 small left: PIN 4 OUT_A
  - text j13h5 small left: PIN 5 OUT_B
  - text f14h5 small center: PIN 6 LO
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/12-balanced-mixer.svg)

図1 の `+5V` は AD の電源出力 V+ (Supplies で 5 V)。SA612 は 4.5〜8 V で動き、流す電流は 2.4 mA ほど (データシートの代表値)。

- **RF (W2)** は C1 を通して PIN 1 (IN_A) へ。PIN 2 (IN_B) は C2 で交流だけ GND に落とす (片側から入れる使い方)。
  入力の抵抗は約 1.5 kΩ。1.1 MHz での C1 (10 nF) は 14 Ω なので、W2 の電圧がほぼそのまま入る
- **LO (W1)** は C3 を通して PIN 6 (発振のトランジスタのベース) へ。内蔵の発振器を使わず、
  外から LO を注ぐ使い方で、データシートは **200 mV<sub>pp</sub> 以上**を求める。W1 は振幅 0.2 V (0.4 V<sub>pp</sub>)。PIN 7 は開けておく
- **出力**は PIN 4 (OUT_A) と PIN 5 (OUT_B) の 2 本。どちらも内部の 1.5 kΩ で VCC に吊られ、直流は 4 V ほど。
  C4・C5 で直流を切って AD のスコープへ渡す
- **CH1 は差動** (1+ を OUT_A 側、1− を OUT_B 側)。AD のスコープの入力はもともと差動なので、2 本の差 = 平衡の出力を直に見られる。
  **CH2 は OUT_A だけ** (2− は GND)。平衡を取らない片側の出力と比べる
- **片側の出力にも IF は出る**。OUT_A と OUT_B の電流は、LO が切り替えるたびに入れ替わる 2 本の道を通る。
  RF を掛けた IF の成分は、A が増えるとき B が減る**逆向き (逆相)** に動く。
  一方、LO の漏れ (1 MHz) や LO の 2 倍 (2 MHz) の揺れは、A と B が**同じ向き (同相)** に動く成分として乗りうる。
  どちらも片側だけを見ると混ざって見える
- **差を取ると**、逆相の成分 (IF) は A − B で足し算になって 2 倍 (+6 dB) になり、同相の成分は引き算で打ち消し合う。
  同相の不要な揺れを消して IF だけを残すのが、平衡 (バランス) の意味。CH1 (差動) と CH2 (OUT_A だけ) を並べて、この違いを見る
- 確かめたこと: 2N3904 相当のトランジスタで組んだ簡易のギルバートセル (LTspice、LO 1 MHz・RF 1.1 MHz) では、
  100 kHz と 2.1 MHz の IF は A と B で逆相に出て、A − B で 2 倍になった。
  2 MHz の揺れには A と B の同相の成分 (各側 約 2.4 mV) があり、IF (約 30 mV) の約 1/12 だった。
  SA612 の中身そのものではないので、実物の同相分の大きさは測って確かめる (数字は目安)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (AD の W1・W2 と CH1・CH2)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W2, W1, 1-, 1+, 2+, 2-]
  U1: dip8 @ e15
  C6: capacitor/ceramic c12 c15 100n
  C3: capacitor/ceramic a17 a21 10n
  C5: capacitor/ceramic d18 d24 100n
  C1: capacitor/ceramic i9 i15 10n
  C2: capacitor/ceramic g16 g14 10n
  C4: capacitor/ceramic h18 h25 100n
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t15 -- a15 red
  - a12 -- -t12 black
  - AD.W2 -- a9 yellow
  - e9 -- f9 yellow
  - AD.W1 -- b21 green
  - j17 -- -b17 black
  - j14 -- -b14 black
  - f25 -- e25 orange
  - d25 -- d27 orange
  - AD.1- -- a24 blue
  - AD.1+ -- a25 orange
  - AD.2+ -- a27 purple
  - AD.2- -- -t28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/12-balanced-mixer.svg)

- U1 (SA612) は 15〜18 列で溝をまたぐ (切り欠きを左、PIN 1 は左下の f15)。下の列が PIN 1〜4 (15〜18 列)、上の列が PIN 8〜5 (15〜18 列)
- **電源**: AD の V+ (赤) を上の + レールへ、GND (黒) を上の − レールへ。+ レールから a15 (PIN 8) へ赤い線。
  C6 は PIN 8 の列 (c15) と 12 列 (c12) の間に置き、12 列を黒い線で − レールへ落とす。上下の − レールは 30 列で渡す
- **RF (W2、黄)**: a9 に挿し、e9〜f9 の黄の線で下の段の 9 列へ。C1 (i9〜i15) で PIN 1 へ
- **PIN 2** は C2 (g16〜g14) で 14 列へ渡し、j14 の黒い線で下の − レールへ。**PIN 3** (GND) は j17 から黒い線で下の − レールへ
- **LO (W1、緑)**: b21 に挿す。C3 (a17〜a21) で PIN 6 (17 列の上) へ
- **OUT_B (PIN 5)**: C5 (d18〜d24) を通して 24 列へ。CH1 の 1− (青) を a24 に挿す
- **OUT_A (PIN 4)**: C4 (h18〜h25) を通して下の 25 列へ、f25〜e25 の橙の線で上の 25 列へ上げる。
  CH1 の 1+ (橙) を a25 に挿し、d25〜d27 の橙の線で分けた 27 列に CH2 の 2+ (紫) を挿す。2− (黒) は上の − レールへ
- CH1 (1+ と 1−) で差動の出力、CH2 (2+ と GND) で片側の出力を見る

## 計器の設定

Analog Discovery だけを使う。周波数が 2.5 MHz 以下なので、W1・W2 で LO と RF を作り、Spectrum (FFT) で和と差を見られる。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない) |
| Wavegen W1 (LO) | Sine、1 MHz、振幅 0.2 V、オフセット 0 V |
| Wavegen W2 (RF) | Sine、1.1 MHz、振幅 10 mV、オフセット 0 V |
| Scope | CH1 = 1+ を C4 の先、1− を C5 の先 (差動)。CH2 = 2+ を C4 の先、2− を GND。どちらも 500 mV/div 以下の細かい尺度 |
| Spectrum | 開始 0 Hz・終了 2.5 MHz、FFT 8192 点、窓は Flat Top、縦軸 dBV。チャンネルは CH1 (次に CH2) |

- RF を 10 mV と小さくするのは、SA612 の入力が数十 mV で飽和し始めるため (歪みで 3 次の積が増える)
- 標本化は 2.5 MHz × 2.56 = 6.4 MHz、分解能は 6.4 MHz ÷ 8192 ≈ 0.78 kHz。100 kHz と 1.0 / 1.1 MHz の線は十分分かれる

## 計器の画面

計算値。変換利得を 17 dB (7.08 倍、片側の出力・1 側波あたり) とする。
OUT_A の IF は 10 mV × 7.08 = 70.8 mV (peak)、差動 (CH1) はその 2 倍の **142 mV = −20.0 dBV** (rms で表す)。
LO と RF の漏れは作りや配線で変わるので、図には目安 (LO 2 mV、RF 1 mV) で描いた。

```spectrum
title: 図3 差動の出力 (CH1) — 和と差が立ち、LO と RF はほぼ消える
device: ad3
sweep: 0-2.5MHz
samples: 8192
window: flattop
unit: dBV
ref: 0dBV
signal:
  - sine 100kHz 141.6mV
  - sine 2.1MHz 141.6mV
  - sine 1.9MHz 47.2mV
  - sine 1MHz 2mV
  - sine 1.1MHz 1mV
markers: [100k, 1M, 1.1M, 2.1M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/12-balanced-mixer.svg)

- 図3 では、100 kHz (差、マーカー 1) と 2.1 MHz (和、マーカー 4) が同じ高さで立つ。これが掛け算の証拠
- 1.9 MHz は 3 × LO − RF (3 − 1.1 = 1.9 MHz)。LO で切り替えるスイッチは方形波に近く、
  その 3 次 (1/3) とも掛かる。約 −29.5 dBV (IF より 9.5 dB 下、目安)
- 1 MHz (LO、マーカー 2) と 1.1 MHz (RF、マーカー 3) は IF より **37〜43 dB 下** (目安)。平衡が取れているほど低い
- スーパーヘテロダインでは、この後ろに IF のフィルタ (セラミックフィルタや LC) を置き、100 kHz だけを通す

## 見るべき値

計算値 (漏れは目安)。

| 確かめること | 期待する値 |
| --- | --- |
| IF の周波数 | 差 100 kHz、和 2.1 MHz (W2 を 1.12 MHz にすると 120 kHz と 2.12 MHz に動く) |
| 差動 (CH1) の 100 kHz と 2.1 MHz | どちらも約 −20.0 dBV (142 mV peak。RF の 10 mV の 14 倍、+23 dB) |
| 差動 (CH1) の 1.9 MHz (3 × LO − RF) | 約 −29.5 dBV (IF の約 1/3) |
| 差動 (CH1) の LO (1 MHz) と RF (1.1 MHz) | 約 −57 dBV と −63 dBV (目安)。IF より 37〜43 dB 低い |
| 片側 (CH2、OUT_A) の 100 kHz | 約 −26.0 dBV (70.8 mV peak)。差動より 6 dB 低い |
| 片側 (CH2) の LO (1 MHz) とその 2 倍 (2 MHz) | 同相の揺れが片側には残るので、差動 (CH1) より大きく出るはず (大きさは実物で確かめる)。CH1 と比べて平衡の効き目を見る |
| W2 の振幅を 2 倍 (20 mV) にする | IF が 6 dB 上がる (RF に比例)。LO の漏れは変わらない |
| W1 を止める | IF が消える (掛ける相手が無い)。RF の漏れだけが残る |
| 比べ: ダイオードリング (受け身) | 各側波は RF の −3.9 dB (理想、2/π)、実物は −6〜−7 dB |
| 比べ: 単一ダイオード (理想のスイッチ) | LO と RF が ½ (−6 dB) で素通り、IF は 1/π (−10 dB)。LO が IF より大きい |

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | ダブルバランスドミキサー IC | SA612A (NE612A)、DIP8 (図2 では型番の無い dip8 で描いた) |
| C1・C2・C3 | セラミックコンデンサ (結合・パスコン) | 10 nF |
| C4・C5 | セラミックコンデンサ (出力の直流を切る) | 100 nF |
| C6 | セラミックコンデンサ (電源のパスコン) | 100 nF |
| — | 信号源・計器・電源 | Analog Discovery (W1・W2、Scope、Spectrum、V+ 5 V) |

## 出典

自作。SA612A の足の並び (PIN 1・2 = RF 入力、3 = GND、4・5 = 出力、6・7 = 発振、8 = VCC)、
電源電圧 4.5〜8 V、入力と出力の抵抗 1.5 kΩ、変換利得 (代表 17 dB)、外部 LO の 200 mV<sub>pp</sub> 以上は
NXP の SA612A データシートと応用ノート AN1983 による。ダイオードリングの変換損失 (理想 3.9 dB) は
スイッチの関数のフーリエ級数からの計算値。
