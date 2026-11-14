---
book: nanovna
chapter: 11
id: 11-9
title: 信号発生器を兼ねる機種 — 出力の確かさ
tier: 200
source: 自作
board: —
device: SA
---

# 11-9 信号発生器を兼ねる機種 — 出力の確かさ

tinySA は**信号発生器にもなる**。`MODE` → `Signal Generator` に切り替えると、受信に使っていた RF 端子から
正弦波が出る (tinySA Ultra。Basic は端子が LOW / HIGH の 2 つ)。ラジオや受信機の確かめ、11-8 のような
スカラーの測定の発生器に使える。ただし**表示した dBm がそのまま出ているか**は、別の計器で確かめないと分からない。
この題では 1 MHz に設定し、Analog Discovery 3 (AD3) のオシロで電圧を、Spectrum (FFT) で電力と高調波を読んで、
公式の仕様と突き合わせる。1 MHz を選ぶのは、AD3 で確かめられる周波数だから (10 MHz 以下)。

## 仕様 (tinySA Ultra の発生器)

公式の仕様の値 (目安ではなく、確かめる相手)。

| 項目 | 値 |
| --- | --- |
| 正弦波の周波数 | 100 kHz〜800 MHz (Ultra+ は 900 MHz)。それより上は方形波か、スプリアスの多い出し方 |
| 出力のレベル | −115〜−19 dBm、1 dB 刻み |
| レベルの確かさ | 800 MHz まで、−72〜−19 dBm で ±2 dB。−72 dBm より下はもっと悪い |
| 高調波 | 基本波の −40 dB より下 (仕様の頁)。発生器の頁では、最大の出力で −35 dB、−35 dBm より下の出力で −50 dB より下 |
| 変調 | AM (深さ 10〜100 %)・FM (偏移 1〜300 kHz)・バースト |

- 出力の dBm は **50 Ω (オーム) の負荷に入る電力**。50 Ω で終わらせないと電圧が変わる (開放なら 2 倍、+6 dB に見える)
- 発生器の頁は出力の範囲を −123〜−18 dBm と書き、仕様の頁 (−115〜−19 dBm) と食い違う。
  確かさの保証は −72〜−19 dBm なので、この範囲で使う

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 tinySA の出力を 50 Ω で終わらせて AD3 の 1+ で読む
parts:
  X1:
    type: device
    at: 1,2
    label: tinySA OUT
    pins: [RF, GND]
    turn: mirror
  RT: resistor 7,2 7,4 50
  X2:
    type: device
    at: 10,2
    label: AD3 Scope
    pins: [1+, 1-]
  GX: ground 4,5
  GT: ground 7,5
  GA: ground 9,5
wires:
  - X1.RF -- 7,2
  - 7,2 -| X2.1+
  - 7,4 -- 7,5
  - X1.GND -| 4,5
  - X2.1- -| 9,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/09-generator-accuracy.svg)

- RT は BNC の**貫通型 50 Ω 終端** (市販品)。tinySA の SMA から SMA-BNC 変換と同軸 (BNC) で来て、
  終端を AD3 の BNC アダプタの 1+ に直に挿す。AD3 の入力 (1 MΩ) は 50 Ω に並んでもほとんど効かない
- この題は実体配線図を付けない。基板を使わず、市販の変換と終端をつなぐだけ

## 計器の設定

計器は tinySA Ultra (発生器として使う) と AD3 の Scope・Spectrum。

| 計器 | 設定 | メニュー・画面 |
| --- | --- | --- |
| tinySA (発生器) | 周波数 1 MHz、レベル −19 → −29 → −39 dBm、変調なし、出力 ON | `MODE` → `Signal Generator`、`FREQ`・`LEVEL`、`LOW OUTPUT` |
| AD3 Scope | CH1、DC 結合、20 mV/div、200 ns/div、Average 16 回 (−39 dBm を読むとき) | Scope |
| AD3 Spectrum | CH1、0〜5 MHz、Window Flat-top、単位 dBm | Spectrum |

## 計器の画面

−19 dBm を出したとき、50 Ω の終端の両端に**見えるはずの波形**。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 −19 dBm は 50 Ω で 70.96 mVpp (1 MHz)
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 1MHz -19dBm, range: 20mV/div}
measure: [vpp, rms, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/scope/09-generator-accuracy.svg)

同じ信号を AD3 の Spectrum で見た画面。高調波は仕様の上限 (最大の出力で −35 dBc) の所に描いた
(**上限の目安**。実物はこれより低ければよい)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 基本波 −19 dBm と、高調波の上限の目安 (−35 dBc)
device: ad3
sweep: 0-5MHz
samples: 32768
window: flattop
unit: dBm
ref: -10dBm
signal:
  - sine 1MHz -19dBm
  - sine 2MHz -54dBm
  - sine 3MHz -54dBm
markers: [1M, 2M, 3M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/09-generator-accuracy.svg)

## 見るべき値

計算値。50 Ω で P [dBm] の正弦波は V<sub>p</sub> = √(2 × 50 Ω × P)。±2 dB は電圧で 0.794〜1.259 倍。

| tinySA の設定 | 50 Ω の両端 (計算値) | ±2 dB に入る範囲 (Vpp) |
| --- | --- | --- |
| −19 dBm | 35.48 mV<sub>p</sub> = 70.96 mVpp (25.09 mV rms) | 56.4〜89.3 mVpp |
| −29 dBm | 11.22 mV<sub>p</sub> = 22.44 mVpp | 17.8〜28.3 mVpp |
| −39 dBm | 3.55 mV<sub>p</sub> = 7.10 mVpp | 5.6〜8.9 mVpp |

| 確かめること | 期待する値 |
| --- | --- |
| Spectrum の基本波 (1 MHz) | −19 dBm ± 2 dB |
| 2 次・3 次の高調波 | −54 dBm (−35 dBc) より下 |
| 設定を 10 dB ずつ下げたとき | 読みも 10 dB ずつ下がる (オシロでは 1/√10 = 0.316 倍ずつ) |

分かること:

- **オシロは −39 dBm (7 mVpp) くらいまで**。それより下は AD3 の雑音 (入力レンジ ±2.5 V の 1 段 0.3 mV) に
  埋もれる。Spectrum (FFT) なら雑音が周波数に分かれるので、−59・−79 dBm も同じ 1 MHz の線として読め、
  10 dB ずつ下がるか (減衰器の段の確かさ) を −72 dBm の下まで追える
- **50 Ω の終端を外すと約 +6 dB 高く読む** (141.9 mVpp)。発生器の出力は「50 Ω に入れたときの値」で、
  受信機の入力が 50 Ω でないなら、表示の dBm はその入力には入っていない
- 合わなければ `EXT GAIN` (外の減衰・利得の補正) ではなく、まずつなぎ方 (終端・変換の緩み) を疑う。
  ずれが 2 dB を超えて一定なら、`CONFIG` の `LEVEL CAL` (CAL 出力を基準にした校正) をやり直す

### ラジオで受けて確かめる

発生器を `MOD` → `AM` (1 kHz・深さ 30 %) にして中波のラジオの周波数 (例: 1 MHz) に合わせ、
RF 端子に数回巻いた小さなループをつないでラジオのバーアンテナに近づけると、1 kHz の音が聞こえる。
レベルを 10 dB ずつ下げて、音が雑音に沈むレベルを比べれば、2 台のラジオの感度を比べられる。
FM 放送帯なら `MOD` → `FM` (偏移 75 kHz・1 kHz)。ループからの電波は弱く、出力も −19 dBm 以下だが、
**ラジオのすぐ横で使い、アンテナや増幅器はつながない** (微弱無線局の範囲)。

## LTspice での確かめ

`sim/09-generator-level.cir` で、出力抵抗 50 Ω の源 (−19 dBm を 50 Ω に出す開放電圧 70.96 mV<sub>p</sub>) を
50 Ω の終端と AD3 の入力 (1 MΩ・30 pF。容量は仮定) で受け、1 MHz の電圧を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 終端の両端 (−19 dBm) | 35.48 mV<sub>p</sub> | −29.0005 dBV = 35.48 mV<sub>p</sub> | 合う |
| AD3 の入力の影響 (30 pF の有無) | ほとんど効かない | 差 0.0001 dB | 合う |

−29・−39 dBm の電圧、±2 dB の範囲、終端を外したときの 2 倍 (+6.02 dB) は算術。
発生器のレベルの確かさ・高調波は計器の性質 (仕様の値) で、SPICE の対象外。

## 出典

自作。発生器の範囲・確かさ・高調波・変調は
[tinySA Ultra の仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification)と
[Signal Generator の頁](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.SignalGenerator)、
出力が RF 端子から出ることは[技術説明](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.TechnicalDescription)、
メニューの名前は[メニューの一覧](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.MenuTree) (いずれも 2026-11-14 に確認)。
AD3 の Spectrum の dBm (50 Ω の基準) は Analog Discovery の教科書の 4-1。
