---
book: nanovna
chapter: 11
id: 11-2
title: 中心・スパン・RBW・基準レベル
tier: 100
source: 自作
board: —
device: SA
---

# 11-2 中心・スパン・RBW・基準レベル

スペアナの画面を決める 4 つの言葉。**中心周波数とスパン** (または開始・終了)
が横軸、**RBW** が「隣の信号とどこまで見分けられるか」、**基準レベル** が
縦軸の上端を決める。Analog Discovery の Wavegen で作った 1 本の正弦波を
題材に、まず横軸と縦軸の合わせ方を確かめ、次に RBW を変えてノイズフロアが
動くのを見る。

## 回路図

```circuit
title: 図1 Wavegen の 1 MHz 正弦波を抵抗で落として tinySA へ
parts:
  X1:
    type: device
    at: b1
    label: Analog Discovery
    pins: [W1, GND]
    turn: mirror
  R1: resistor b5 b7 1k
  X2:
    type: device
    at: b9
    label: tinySA
    pins: [RF, GND]
  GA: ground d4
  GM: ground d8
wires:
  - X1.W1 -| b5
  - b7 -| X2.RF
  - X1.GND -| d4
  - X2.GND -| d8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/02-center-span-rbw.svg)

- W1 を 1 MHz・振幅 1 V (peak) の正弦波にする。R1 (1 kΩ) を直列に入れて
  50 Ω の tinySA 入力へ落とすと、Wavegen から見た負荷は 1 kΩ + 50 Ω ≈ 1.05 kΩ
  で、流れる電流は 1 V ÷ 1.05 kΩ ≈ 0.95 mA。**Wavegen の保証駆動電流 10 mA
  (README) に対して十分小さい**ので、これだけで安全に収まる。0-3 のような
  パッド (アッテネータ) は足さなくてよい。0-3 の決まりは、**信号のレベルが
  入力の上限に近いときだけアッテネータを挟む**というもの
- tinySA に届く電圧は 1 V × 50/(1000+50) ≈ 47.6 mV (peak)。50 Ω での電力に
  直すと **約 −16.4 dBm** (計算値)。tinySA Ultra の入力上限 (11-1、自動減衰で
  +0 dBm 程度) より 16 dB 以上低いので安全

## 実体配線図

1 MHz で 1 kΩ の抵抗が 1 本だけなので、ブレッドボードに組んでよい (3 MHz 以下)。
AD3 の Wavegen W1 と GND、tinySA の RF と GND に、それぞれケーブルをつなぐ。

```breadboard
title: 図2 ブレッドボードに R1 を挿す (W1 から tinySA へ)
board: half
parts:
  R1: resistor b5 b10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1]
  SA:
    type: device
    at: top
    label: tinySA
    pins: [RF, GND]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - SA.RF -- a10 orange
  - SA.GND -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/breadboard/02-center-span-rbw.svg)

- ブレッドボードを流れる電流は約 0.95 mA で、ブレッドボードの範囲 (1 穴 200 mA) に収まる
- **グランドを先に**つなぎ、外すときは最後に外す

## 計器の設定

計器は tinySA Ultra。信号源は Analog Discovery 3 (AD3) の Wavegen W1 (1 MHz・振幅 1 V の正弦波) で、オシロは使わない (周波数を見る題)。

一般の名前と tinySA Ultra のメニューの対応 (ファームウェアは TinySA4 系を仮定)。

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 中心周波数 (Center) | 1 MHz | `FREQUENCY` → `CENTER` |
| スパン (Span) | 200 kHz | `FREQUENCY` → `SPAN` |
| RBW | 100 kHz → 10 kHz (2 通りで比べる) | `FREQUENCY` → `RBW` |
| 基準レベル (Ref Level) | 0 dBm、SCALE/DIV 10 dB/div | `LEVEL` → `REF LEVEL`、`LEVEL` → `SCALE/DIV` |
| 入力アッテネータ | 0 dB (自動でよい) | `LEVEL` → `ATTENUATE` |

中心・スパンの代わりに開始・終了 (`FREQUENCY` → `START` / `STOP`) でも同じ
範囲を指定できる。900 kHz〜1.1 MHz (Start/Stop) と 1 MHz・200 kHz
(Center/Span) は同じ画面になる。

## 見るべき値

計算値。RBW を変えたときのノイズフロアの変化は、**RBW を 1/n にすると
ノイズフロアが 10 log₁₀(n) dB 下がる**という掃引型スペアナに共通の関係
(RBW の帯域が狭いほど、そこに入る熱雑音のパワーが減るため)。

| 設定 | 見え方 (計算値・理論) | 分かること |
| --- | --- | --- |
| 1 MHz の信号のレベル | 約 −16.4 dBm (回路図の計算値。実測は自分の tinySA の読みを記録する) | 中心・スパンが合っていれば、信号の山が画面の中央に立つ |
| RBW 100 kHz → 10 kHz (1/10) | ノイズフロアが 10 log₁₀(10) = **10 dB** 下がる。信号の山の高さはほぼ変わらない | RBW が狭いほど小さい信号が見やすくなる (11-3 で本題) |
| RBW を 1/10 にしたときの掃引時間 | 目安で **約 100 倍** に伸びる (掃引型はおおむね 掃引時間 ∝ スパン / RBW² という関係。tinySA の実際の値は画面の表示を読む) | 分解能を上げると遅くなる、というトレードオフ |
| 基準レベルを −20 dBm に下げる | 信号の山が画面の上のほうに来る (縦軸を信号に合わせただけで、測った値自体は変わらない) | 基準レベルは見やすさの設定で、信号のレベルには影響しない |

## 出典

自作。tinySA Ultra のメニュー名は公式 wiki の
[Frequency メニュー](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.FREQ)と
[Level メニュー](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.LEVEL) (2026-09-27 に確認)。
Wavegen の名前と駆動電流の目安は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
