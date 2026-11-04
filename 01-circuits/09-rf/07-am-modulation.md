---
book: circuits
chapter: 9
id: 9-7
title: AM 変調 — 555 の搬送波を音声で振る
tier: 50
source: 自作
board: BB
---

# 9-7 AM 変調 — 555 の搬送波を音声で振る

**AM (振幅変調)** は、一定の周波数の搬送波の**振幅だけ**を、音声の大きさに合わせて上下させる方式。
555 の出力の H レベルは電源電圧そのものなので、**555 の電源に音声を混ぜる**と、出力の振幅が音声で揺れ、仕組みの分かりやすい AM 変調器になる。
9-2〜9-5 のラジオが受けていた AM の電波を自分で作り、ラジオで聞いてオシロで波形を見る。
音声の通り道の分圧とスペアナで見る側波は 9-29 に分けた。

> [!WARNING]
> 出力をごく小さな結合コンデンサ (Cant) と短いループ線で近くの AM ラジオへ
> 渡すだけの実験にする。9-4 と同じく**電波法の微弱無線局**の範囲 (322 MHz
> 以下、距離 3m で電界強度 500 µV/m 以下、電波法施行規則第 6 条) に収める
> ため、**ループ線を伸ばしたり、後段を増幅したりしない**。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 555の電源に音声を混ぜてAM変調する
parts:
  V1: sine 2,3 2,5 0.5
  GV1: ground 2,5
  Cmod: capacitor 2,3 4,3 1u
  VCC: vcc 8,1 5V
  Rmod: resistor 8,1 8,3 220
  U555: ic 10,7 TLC555
  GU555: ground 10,10.5
  R1: resistor 6,3 6,5 1k
  R2: resistor 6,6.5 6,8.5 10k
  C1: capacitor 8,8.5 8,10.5 100p
  GC1: ground 8,10.5
  Cant: capacitor 14,7 16,7 100p
  ANT: port 17,7
wires:
  - 4,3 -- 10.5,3
  - U555.VDD |- 10,3
  - U555.RESET |- 10.5,3
  - 6,5 -- 6,6.5
  - U555.DISCH -| 6,6.5
  - U555.THRES -| 8,7
  - U555.TRIG -| 8,7.5
  - 8,7 -- 8,8.5
  - 6,8.5 -- 8,8.5
  - U555.GND |- 10,10.5
  - U555.OUT -| 14,7
  - 16,7 -- 17,7
notes:
  # 計測点。オシロは橙、スペアナは緑 (計器の設定の表と同じ名前)
  - arrow 1,2 2,3 orange
  - text 1,1.7 small orange left: 音声
  - arrow 9.5,2.5 9.5,3 orange
  - text 9.5,2.2 small orange center: PIN 8
  - arrow 12,5.5 12,7 orange
  - text 12,5.2 small orange center: PIN 3
  - arrow 17,8.5 17,7 orange
  - text 17,8.7 small orange right: ANT
  - arrow 12,9 10,9 orange
  - text 12,9 small orange left: オシロ GND
  - arrow 13.5,5.5 13.5,7 green
  - text 13.5,5.2 small green center: スペアナ入力
  - arrow 12,9.7 10,9.7 green
  - text 12,9.7 small green left: スペアナ GND
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/07-am-modulation.svg)

- **搬送波**: R1 (1 kΩ)・R2 (10 kΩ)・C1 (100 pF) の 555 非安定。
  f = 1.44/((R1+2R2)C) = 1.44/((1k+20k)×100p) **≈ 686 kHz**。日本の
  AM 放送帯 (531 kHz〜1602 kHz) の中
- **変調**: V1 (信号発生器、1 kHz の正弦波) を Rmod (220 Ω) と Cmod (1 µF) を介して
  555 の電源ピン (PIN 8) へ混ぜる。出力 H は「そのときの電源電圧」なので、振幅が音声で揺れる
- **CMOS 版 (TLC555) を使う理由**: NE555 (バイポーラ) の動作下限は 4.5 V ほど、TLC555 は 2 V。
  変調を深くして電源電圧が瞬間的に下がっても、発振が止まりにくい
- Rmod は直流の給電、Cmod は音声の交流分だけを PIN 8 へ渡す結合コンデンサ。**変調度**は音声の振幅 ÷ PIN 8 の直流の電圧
  (約 4.4 V、下の項目) で決まる。深くしすぎると波形がつぶれて歪む
- **音声源 (V1) の想定**: 0-6 のファンクションジェネレータ (出力 50 Ω) を **1 kHz の正弦波・
  振幅 0.5 V** (発生器の表示値) にする。1 kHz は AM ラジオが通す音声の帯域 (数 kHz まで) の中。PIN 8 に届く振れは V1 の **0.70 倍** (0.5 V → 約 0.35 V)。発生器の 50 Ω・Cmod・Rmod の分圧の計算と、
  スマホやマイクアンプを音声源にするときの条件は 9-29
- **Rmod の直流の降下** (PIN 8 の直流の見積もり): PIN 8 に流れ込む電流は 3 つ。
  (1) PIN 7 が L の間 (周期の約 48 %) に R1 を通って GND へ抜ける電流。
  PIN 7 の L の電圧は 10 mA で 0.06 V (typ、5 V) と小さいので、
  (4.5 V − 0.05 V)/1 kΩ ≈ **4.4 mA** が 48 % の間だけ流れる (平均 2.1 mA)。
  (2) PIN 7 が開いている間に R1 と R2 を通って C1 を充電する電流、平均 0.1 mA ほど。
  (3) IC 自身の消費電流、5 V で typ 180 µA (最大 350 µA)。
  合計は平均 **約 2.4 mA** (パルスの山で約 4.7 mA)。Rmod (220 Ω) で 0.53 V 落ちるので、
  **PIN 8 の直流は約 4.5 V** (555 を理想の比較器として python3 で解いた目安。実物の貫通電流やばらつきで変わる)。
  図と表は余裕を見て **4.4 V** で描いた。これが搬送波の H の高さで、変調度の分母になる。組んだら PIN 8 をテスターの直流で測る
- **ANT はループ線** (Cant 経由の弱い結合)。搬送波が方形波なので、ラジオで聞く音は歪む

### LTspice での確かめ

音声の通り道 (V1 → Cmod → PIN 8) は `sim/07-am-modulation.cir` の交流解析で確かめた。表は 9-29。
PIN 8 の振れは 0.351 V (555 の消費を入れても 0.335 V) で、本文の 0.35 V と合う。

搬送波 555 の部分は、LTspice の TLC555 の理想モデル (しきい値が電源の 1/3・2/3) が細かい刻みを要求して終わらなかったため、
同じ式を python で解いた (PIN 7 の L = 6 Ω、R1・R2・C1 は本文のまま)。t<sub>H</sub> = 0.76 µs、t<sub>L</sub> = 0.70 µs (本文は理想の 0.69 µs)、
周波数 682.5 kHz (本文の式は 686 kHz)、デューティ 52.0 %。**電源電圧 (4.05〜5 V) を変えても周波数・デューティは同じ**で、振幅 (H の高さ) だけが電源に比例し、本文の AM のしくみと合う。
ANT の振れは 0.87 倍 (+1.84 / −1.99 V) で本文と合う。判定: 合う (本文は直さない)。
PIN 8 の直流 (約 4.4〜4.5 V) は実物の貫通電流などに依るので対象外。ラジオでの受信も対象外。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む
board: half
parts:
  GEN:
    type: device
    at: top
    label: 信号発生器 1kHz 0.5V
    pins: [GND, OUT]
  ANT:
    type: device
    at: bottom
    label: ループ線
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - ANT.1 -- j27 yellow
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/07-am-modulation-1.svg)

- 上の赤レール = +5 V (USB や電池)、青レール = GND。30 列で上下の − レールを渡している
- U555 は 20〜23 列で溝をまたぐ (1 番は左下の f20)。16 列が 555 の電源のネット (PIN 8 から a 行の線、PIN 4 から g 行の線)。Rmod で +5 V から、
  Cmod で発生器 (GEN) から入る
- PIN 7 (21 列) と 16 列の間に R1、PIN 7 と 25 列の間に R2。PIN 6 (c 行の線) と PIN 2
  (h 行の線) を 25 列にまとめ、C1 で GND へ
- ループ線は PIN 3 (22 列) から Cant を通した 27 列 (下、j27)
- PIN 1 (20 列) は h 行の線で 13 列へ出して下の − レールへ (j 行は計器のために空ける)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U555 | CMOS タイマ IC | TLC555 (バイポーラの NE555 は動作下限 4.5 V なので不可) |
| R1 | 抵抗 | 1 kΩ |
| R2 | 抵抗 | 10 kΩ |
| C1 | セラミックコンデンサ (時定数) | 100 pF |
| Rmod | 抵抗 (555 の電源の給電) | 220 Ω |
| Cmod | セラミックコンデンサ (音声の結合) | 1 µF |
| Cant | セラミックコンデンサ (アンテナ結合) | 100 pF |
| — | ループ線 | 短い線 (伸ばさない) |
| — | 信号源 (V1) | 信号発生器 (0-6 のファンクションジェネレータ)。1 kHz 正弦波、振幅 0.5 V (表示値)、出力 50 Ω |
| — | 電源 | 5 V (USB や電池) |

## 計器の設定

オシロスコープ (2 チャンネル) で調べ、グランドは − レールに取る。スペアナは 9-29。

| 項目 | 設定 |
| --- | --- |
| プローブ | 2 本とも 10:1。測る点は下の 3 つで、図ごとに付け替える |
| PIN 3 (搬送波) | 22 列の空き穴 (j22)。DC 結合 |
| ANT (Cant の先) | 27 列の空き穴 (j27。ループ線は g27〜g28 の線で j28 へ移す)。DC 結合 |
| PIN 8 (555 の電源) | 16 列の空き穴 (j16)。AC 結合で音声の揺れだけを見る |
| 搬送波を見るとき (図4) | CH1 PIN 3 (2 V/div)、CH2 ANT (1 V/div)。0.5 µs/div、トリガは CH1 の立ち上がり |
| 包絡線の山と谷を比べるとき (図5) | PIN 3 を 1 V/div・位置 −2.5 目盛 (0 V が下から 1.5 目盛)、0.5 µs/div。山の波を Reference に残し、谷の波と重ねる |
| 変調の包絡線を見るとき | CH1 PIN 3 (1 V/div)、CH2 PIN 8。200 µs/div、トリガは CH2 (音声) の立ち上がり |

- PIN 2・6 (25 列) にはプローブを当てない。プローブの容量 (10〜15 pF) が C1 (100 pF) に
  足されて、搬送波の周波数が 1 割ほど下がる

### オシロスコープのつなぎ方

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図3 オシロスコープをつなぐ (PIN 3 と ANT を見るとき)
board: half
parts:
  GEN:
    type: device
    at: top
    label: 信号発生器 1kHz 0.5V
    pins: [GND, OUT]
  SCOPE:
    type: device
    at: bottom
    label: オシロスコープ
    pins: [GND, CH1, CH2]
  ANT:
    type: device
    at: bottom
    label: ループ線
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - g27 -- g28 yellow
  - ANT.1 -- j28 yellow
  - -t30 -- -b30 black
  - SCOPE.CH1 -- j22 purple
  - SCOPE.CH2 -- j27 pink
  - SCOPE.GND -- -b17 black
notes:
  - circle j22
  - circle j27
  - circle -b17
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/07-am-modulation-2.svg)

- 赤い丸はプローブと GND のクリップ (下の − レール) の所。図は PIN 3 (CH1) と ANT (CH2) を見るとき (図4)
- ループ線を j28 へ移し、空いた j27 に CH2 を当てる (プローブの線とループ線が触れないように)
- 変調の包絡線を見るときは、CH2 を j16 (PIN 8) に付け替える

## 見るべき値

計算値。VCC = 5 V (USB や電池)、V1 は出力 50 Ω の発生器とする。PIN 8 の直流は Rmod の降下で約 4.4 V (回路図の項目)。

| 確かめること | 期待する値 |
| --- | --- |
| 搬送波の周波数 (無変調時) | f ≈ 686 kHz (計算値) |
| V1 を 1 kHz 正弦波・振幅 0.5 V にする | 近くの AM ラジオ (686 kHz 付近) から 1 kHz の音が聞こえる |
| V1 の振幅を 2 V にする | 変調度 約 32% (PIN 8 の揺れ 約 1.4 V ÷ 4.4 V、計算値)。音は 0.5 V のときの 4 倍 (+12 dB) になり、歪みはまだ目立たない |
| V1 の振幅を 3.4 V より大きくする | PIN 8 の谷 (4.4 V − 2.4 V) が TLC555 の動作下限 (2 V) を割り、谷ごとに発振が途切れて音がひどく歪む (変調が深すぎる目安。変調度 約 55% 以上、計算値)。出力 0 Ω の発生器なら 3.0 V から (このとき V1 の電流は約 11 mA。Analog Discovery 3 の Wavegen は 30 mA まで流せる) |
| V1 を外す | 無変調の搬送波だけになり、ラジオからは「サー」という単調な音 (方形波の高調波混じり) |

### オシロスコープで見る

計算値。t<sub>H</sub> = 0.693(R1+R2)C ≈ 0.76 µs、t<sub>L</sub> = 0.693·R2·C ≈ 0.69 µs。
破線の図は計算で描いた「見えるはずの画面」。まず V1 を外し、搬送波と ANT を見る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 無変調の搬送波 — PIN 3 (CH1) と ANT (CH2)
time: 0.5us/div
trigger: ch1 rising 2.2V
ch1: {wave: square 686kHz 2.2V offset 2.2V duty 52%, range: 2V/div, position: 0.5div}
ch2: {wave: ch1 | gain 0.87 | offset -1.99V, range: 1V/div, position: -2div}
measure: [vpp, vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/07-am-modulation-1.svg)

- PIN 3 (CH1) は 0〜4.4 V の方形波。H の高さは PIN 8 の電圧そのもの
- ANT (CH2) は Cant で直流が切れ、**0 V を中心に振れる** (+1.84〜−1.99 V)。平均が 0 V に
  なるので、デューティ 52 % のぶん H のほうが低い。振幅は PIN 3 の 0.87 倍 (4.4 → 3.83 Vpp)。
  Cant (100 pF) とプローブの容量 (約 15 pF) の分圧で、100/(100+15) ≈ 0.87

次に V1 を 1 kHz・0.5 V にして、変調された PIN 3 を見る。200 µs/div では、搬送波の 1 周期 (1.46 µs) は細かすぎて
1 本ずつは見えず、**H の頂が作る包絡線**が PIN 8 と同じ 1 kHz で揺れる帯に見える
(この画面は scope の図では描けないので、下の表の値で確かめる)。
包絡線の山と谷を 0.5 µs/div に広げて見比べる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 PIN 3 の搬送波 — 包絡線の山 (CH1) と谷 (CH2) を重ねる
time: 0.5us/div
trigger: ch1 rising 2V
ch1: {wave: square 686kHz 2.375V offset 2.375V duty 52%, range: 1V/div, position: -2.5div}
ch2: {wave: square 686kHz 2.025V offset 2.025V duty 52%, range: 1V/div, position: -2.5div}
measure: [vmax, freq, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/07-am-modulation-2.svg)

- 図の CH2 は、山の波を Reference に残した後の 2 回目 (谷) の取り込み。プローブは PIN 3 の 1 本
- **高さ (4.75 V と 4.05 V) だけが違い、周期は同じ 1.458 µs**。電源が揺れても
  周波数は動かず、振幅だけが動く。これが AM

| 確かめること | 期待する値 |
| --- | --- |
| 無変調の PIN 3 (CH1、0.5 µs/div) | 方形波。周期 ≈ 1.46 µs (686 kHz)、H ≈ 4.4 V (PIN 8 の電圧。Rmod の降下ぶん 5 V より低い)、デューティ ≈ 52 % |
| 無変調の ANT (CH2) | 0 V を中心とする方形波、+1.84〜−1.99 V (3.83 Vpp、図4) |
| V1 を 1 kHz・0.5 V にしたときの PIN 8 (CH2) | 1 kHz の正弦波、振幅 約 0.35 V (0.5 V × 0.70)。その上に 686 kHz の細かい揺れが 0.2 V ほど乗る (9-29) |
| そのときの PIN 3 (CH1、200 µs/div) | 方形波の H の頂が 1 kHz で 約 4.05〜4.75 V に揺れる (包絡線)。L は 0 V のまま。変調度 m = (4.75 − 4.05)/(4.75 + 4.05) ≈ 8 % |
| 包絡線の山と谷で、搬送波の周期をカーソルで測る | どちらも ≈ 1.46 µs (しきい値が電源電圧に比例するので、周波数は動かない) |

## 出典

自作。電波法の微弱無線局の技術基準は総務省電波法施行規則第 6 条による。
TLC555 の電源電圧の範囲 (2〜15 V)・5 V の消費電流 (typ 180 µA)・PIN 7 の L の電圧 (10 mA で 0.06 V) は
[Texas Instruments のデータシート TLC555 (SLFS043K)](https://www.ti.com/lit/ds/symlink/tlc555.pdf)、
ファンクションジェネレータの出力抵抗 50 Ω は 9-1 と同じ前提、Analog Discovery 3 の
Wavegen の出力電流 (30 mA) は Digilent の仕様書による。
