---
book: analog-discovery
chapter: 8
id: 8-14
title: 10 MHz の方形波が届くジャンパの長さ
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-14 10 MHz の方形波が届くジャンパの長さ

ロジックの出力をジャンパで別の IC の入力へ送るとき、ジャンパが長いと、受け側の波形の角で
**行き過ぎ (オーバーシュート) と揺れ (リンギング)** が出る。ジャンパのインダクタンス (8-3) と、
受け側の入力の容量が直列の共振回路を作るからだ。ここでは 74HC14 の出力から 10 MHz の方形波を、
長さ 5・10・20・30 cm のジャンパで隣のゲートの入力へ送り、**どの長さまでなら方形波として届くか**を見る。
最後に、出力の側に直列の抵抗 100 Ω (オーム) を入れて揺れを抑える。

「届く」の目安は 2 つ置く。(1) 受け側の電圧が電源 (5 V) を 0.5 V より超えない (入力の保護ダイオードに電流を流さない)、
(2) 次の角 (50 ns 後) までに 5 V ± 0.25 V に落ち着く。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 74HC14 の出力 (U1A) からジャンパ Lj を通して U1B の入力へ
parts:
  W1: sine 2,4 2,7 l=$\mathrm{W1}$
  U1A: not 5,4 74HC14
  M1: voltmeter 8,4 8,7 l=$\mathrm{CH1}$
  Lj: inductor 9,4 12,4 227n l=$\mathrm{L_j}$
  M2: voltmeter 13,4 13,7 l=$\mathrm{CH2}$
  U1B: not 16,4 74HC14
  Y2: port 19,4 out
  G1: ground 8,7
wires:
  - 2,4 -- U1A.in
  - U1A.out -- 8,4
  - 8,4 -- 9,4
  - 12,4 -- 13,4
  - 13,4 -- U1B.in
  - U1B.out -- 19,4
  - 2,7 -- 8,7
  - 8,7 -- 13,7
notes:
  - text 1,9 small left: "U1 は 74HC14。PIN 14 VCC を +5V、PIN 7 を GND"
  - text 1,10 small left: "PIN 14 と 7 の間に 100 nF。U1A は PIN 1 から 2、U1B は PIN 3 から 4"
  - text 1,11 small left: "使わない入力 PIN 5・9・11・13 は GND"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/14-jumper-length.svg)

- W1 は AD3 の Wavegen。10 MHz の正弦波 (0.5〜4.5 V) を U1A のシュミットトリガで方形波にする
- L<sub>j</sub> は部品ではなく、試すジャンパの等価インダクタンス (等価回路。図は 20 cm の 227 nH)。8-3 の式で長さから見積もる
- CH1 は U1A の出力 (送り側)、CH2 は U1B の入力 (受け側)。**CH2 の入力容量 24 pF も受け側の負荷になる** (U1B の入力 3 pF より大きい)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 11 列 (1Y) と 12 列 (2A) を試すジャンパでつなぐ
board: half
parts:
  U1: dip14 @ e10 74HC14
  C1: capacitor/ceramic c8 c10 100n
  JMP:
    type: device
    at: bottom
    label: 試すジャンパ (5・10・20・30 cm)
    pins: [A, B]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, 1-, 2-, W1, 1+, 2+]
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - +b30 -- +t30 red
  - -b29 -- -t29 black
  - a10 -- +t10 red
  - a8 -- -t8 black
  - j16 -- -b16 black
  - j14 -- -b14 black
  - a15 -- -t15 black
  - a13 -- -t13 black
  - a11 -- -t11 black
  - AD.W1 -- j10 yellow
  - AD.1+ -- h11 orange
  - JMP.A -- j11 green
  - JMP.B -- j12 green
  - AD.2+ -- h12 white
  - AD.1- -- -b4 black
  - AD.2- -- -b6 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/14-jumper-length.svg)

- U1 の PIN 1 (1A) が f10、PIN 2 (1Y) が f11、PIN 3 (2A) が f12。PIN 14 (VCC) は e10 で、a10 から + レールへ。C1 100 nF を VCC (10 列) と GND (8 列) の間に挿す
- 使わない入力 (PIN 5・9・11・13) は黒の短い線で GND のレールへ落とす (CMOS の入力を浮かせない)
- 緑の 2 本が試すジャンパの両端。実物は 1 本のジャンパを 11 列と 12 列に挿し、その長さを 5・10・20・30 cm と替える。
  輪の形にせず、机の上に U の字に伸ばす
- AD3 は下に置き、電源は下のレール (+b・−b) から入れて、右の端で上のレールへ渡す

## 計器の設定

計器は Analog Discovery 3 の Supplies・Wavegen と Scope (BNC アダプタ付き)。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen | W1: Sine、10 MHz、Amplitude 2 V、Offset 2.5 V (0.5〜4.5 V) |
| Scope | CH1 = U1A の出力 (11 列)、CH2 = U1B の入力 (12 列)。Range は両方 1 V/div、時間軸 20 ns/div |
| Measure | CH2 の Maximum・Minimum・Rise |
| 手順 | ジャンパ 5 → 10 → 20 → 30 cm。20 cm で、U1A の出力とジャンパの間に R<sub>s</sub> 100 Ω を足す |

**AD3 の Scope の帯域 (BNC アダプタで 30 MHz 以上、目安) は、揺れの周波数 (50〜150 MHz) より低い。**
画面の揺れは実際より小さく丸まって見える (30 cm の 51 MHz はまだ見え、5 cm の 148 MHz はほとんど見えない)。
図3 は受け側の実際の電圧の計算 (20 cm)。測った波形の揺れが図より小さくても、それは計器の帯域のせいである。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 20 cm のジャンパでは、受け側 (CH2) が 6.7 V まで行き過ぎ、64 MHz で揺れる (計算)
time: 20ns/div
trigger: ch1 rising 2.5V
ch1: {wave: square 10MHz 2.5V offset 2.5V | rc 1.5ns, range: 2V/div, position: -2div}
ch2: {wave: ch1 | lc 64.3MHz 1.83, range: 2V/div, position: -2div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/14-jumper-length.svg)

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| U1 | 74HC14 (シュミットトリガのインバータ 6 回路) | 入力の容量 3 pF (typ)、入力クランプ電流 ±20 mA (絶対最大、データシートの値) |
| C1 | 100 nF (104)、積層セラミック | U1 の電源ピンのすぐ近くに (8-9) |
| ジャンパ | 0.64 mm の単線、5・10・20・30 cm | 1 本ずつ替えて試す |
| R<sub>s</sub> | 100 Ω、1/4 W | 20 cm のときに足す直列の抵抗。電力は 1 mW 以下 |
| 電源 | AD3 の Supplies 5 V | 74HC14 の電流は数 mA |

## 見るべき値

計算値。U1A の出力は 0→5 V を 5 ns で上がる台形と、出力の抵抗 50 Ω (どちらも**仮定**。データシートの
出力の変化時間は 50 pF の負荷で 8 ns typ)。受け側の容量 C = 3 pF + 24 pF = 27 pF。ジャンパの L は 8-3 の式 (**仮定**。線の容量は無視)。
共振 f<sub>0</sub> = 1 / (2π√(LC)) (π (パイ))、Q = √(L/C) / R。

| ジャンパ | L | f<sub>0</sub> | Q | 受け側の最大 | 落ち着く (± 0.25 V) | 届くか |
| --- | --- | --- | --- | --- | --- | --- |
| 5 cm | 43 nH | 148 MHz | 0.80 | 5.19 V | 6 ns | **届く** |
| 10 cm | 100 nH | 96.9 MHz | 1.22 | 5.82 V | 11 ns | (1) を超える |
| 20 cm | 227 nH | 64.3 MHz | 1.83 | **6.72 V** | 28 ns | (1) を超える |
| 30 cm | 366 nH | 50.6 MHz | 2.33 | 7.32 V | 45 ns | (1) を超え、(2) もぎりぎり |
| 20 cm + R<sub>s</sub> 100 Ω | 227 nH | 64.3 MHz | 0.61 | **5.05 V** | 12 ns | **届く** (立ち上がりは 7.7 ns に遅れる) |

- 立ち下がりでも同じだけ 0 V の下へ行き過ぎる (20 cm で −1.72 V)
- **10 MHz の方形波を 74HC で送るなら、ジャンパは 5 cm ほどまで。** 長くするなら、出力の側に直列の抵抗 (ここでは 100 Ω) を入れて
  Q を 0.7 以下にする。抵抗の値の目安は 2√(L/C) − 50 Ω (20 cm なら 2√(227 nH / 27 pF) − 50 = 133 Ω。E24 の 100 Ω で Q 0.61)
- 揺れの中で電源を超えた分は、実物では入力の保護ダイオードが電源へ流す。ジャンパに流れる電流は最大で 30 mA ほど (計算値) なので、
  10 cm 以上では入力クランプ電流 ±20 mA を超えるおそれがある (目安。模型はダイオードを入れていない)
- 受け側の 27 pF のうち 24 pF は CH2 の入力容量。**計器をつなぐと回路が変わる** — 10:1 プローブ (0-5) にすれば受け側は軽くなり、
  f<sub>0</sub> は上がり Q も上がる (揺れは速く大きくなる)

## LTspice での確かめ

`sim/14-jumper-length.cir` で、台形の電源 (0→5 V、5 ns) → 50 Ω (→ R<sub>s</sub>) → ジャンパの L → 27 pF を過渡解析し、
3 周期目の立ち上がりの最大と、5 V ± 0.25 V に入るまでの時間を波形から読んだ (L と出力の模型は本文の仮定)。

| ジャンパ | 本文の数字 (最大・落ち着き) | LTspice | 判定 |
| --- | --- | --- | --- |
| 5 cm | 5.19 V・6 ns | 5.19 V・6.0 ns | 合う |
| 10 cm | 5.82 V・11 ns | 5.82 V・11.2 ns | 合う |
| 20 cm | 6.72 V・28 ns、最小 −1.72 V | 6.72 V・28.4 ns、−1.72 V | 合う |
| 30 cm | 7.32 V・45 ns | 7.32 V・44.7 ns | 合う |
| 20 cm + R<sub>s</sub> 100 Ω | 5.05 V・12 ns | 5.05 V・11.5 ns | 合う |

図3 は理想の方形波を RC (1.5 ns) と 2 次の低域 (64.3 MHz・Q 1.83) に通した描き方で、台形と 50 Ω の模型とは角の形が少し違う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
74HC14 の入力の容量・変化時間・入力クランプ電流は [TI SN74HC14 のデータシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)。
