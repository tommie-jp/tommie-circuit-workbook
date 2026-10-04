---
book: nanovna
chapter: 8
id: 8-5
title: 安定性 (K 因子)
tier: 100
source: 自作
board: PF
device: H4
---

# 8-5 安定性 (K 因子)

8-4 で測ったトランジスタの 4 つの S パラメータから、**安定係数 K** を計算する。
K は「入力と出力にどんな受動のインピーダンス (アンテナ・フィルタ・ケーブル) を
つないでも発振しないか」を 1 つの数で言う。NanoVNA は K を直接は表示しないので、
**4 つの S パラメータをマーカーで読むか Touchstone に保存して、手で (Python で) 計算する**。

8-4 のむき出しのトランジスタは、**低い周波数で K < 1** (条件つき安定) になる。
出力に 270 Ω を 1 ピンすと K > 1 に変わる。8-1 のコレクタ抵抗 Rc (270 Ω) が、
利得を決めるだけでなく**安定化の役もしていた**ことが分かる。

## この実験で確かめる式

**K = (1 − |S11|² − |S22|² + |Δ|²) / (2 |S12 S21|)**、**Δ = S11 S22 − S12 S21**

**K > 1 かつ |Δ| < 1 なら無条件安定** (どんな受動の終端でも発振しない)。
K < 1 の周波数では、入力か出力のある終端で発振しうる (50 Ω で測っている間は
発振しなくても、アンテナや共振回路をつなぐと発振することがある)。

S パラメータは**大きさと位相の両方**が要る (Δ は複素数の引き算)。dB だけでは
計算できない。

K を下げる主な原因は 2 つ。**S22 がほぼ 1** (コレクタの Z が高く、出力が
ほとんど全反射) なことと、**S21 が大きい**ことだ。出力に 270 Ω を並列に
足すと |S22| が 0.97 → 0.67 に下がり、S21 は 1.5 dB しか下がらないので、K が大きく上がる。

## 回路図

8-4 の図1 と同じ治具に、出力の直流カット (C2) の先から GND へ RST (270 Ω) を足す。
C2 の先には直流が無いので、RST に直流は流れない (動作点は 8-4 と同じ)。

```circuit
title: 図1 8-4 の治具の出力に RST (270 Ω) を足す
parts:
  BAT: battery a1 g1 5 l=$\mathrm{BAT}$
  Cd: capacitor a2 c2 10u
  J1: sma e3 mirror CH0
  C1: capacitor e4 e5 0.1u
  RB: resistor a6 c6 200k
  L1: inductor c6 e6 100u
  Q1: npn e8
  Rs: resistor a10 b10 100
  L2: inductor b10 d10 100u
  C2: capacitor d11 d12 0.1u
  RST: resistor d13 f13 270
  J2: sma d15 CH1
  GBAT: ground g1
  GCd: ground c2
  GJ1: ground f3
  GQ1: ground g8
  GRST: ground f13
  GJ2: ground e15
wires:
  - a1 -- a2 -- a6 -- a10
  - J1.1 -- e4
  - J1.2 -- f3
  - e5 -- e6 -- Q1.B
  - Q1.E |- g8
  - Q1.C |- d10
  - d10 -- d11
  - d12 -- d13 -- d15 -- J2.1
  - J2.2 -- e15
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/05-stability-k-factor.svg)

## 実体配線図

8-4 の図2 に RST を 1 ピンすだけ。**RST を外せば 8-4 のユニバーサル基板に戻る**ので、
同じユニバーサル基板で「無し」と「有り」を続けて測れる。

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 8-4 のユニバーサル基板に RST を足す (i19 から m 行へ)
parts:
  J1: sma/female-edge i1 j0
  BAT: battery c4 c1 5
  Cd: capacitor d5 e5 10u
  C1: capacitor i3 i5 100n
  RB: resistor c7 f7 200k
  L1: inductor f8 i8 100u
  Q1: transistor j12 j11 j10
  Rs: resistor c14 f14 100
  L2: inductor f13 i13 100u
  C2: capacitor i15 i17 100n
  RST: resistor i19 l19 270
  J2: sma/female-edge i24 j25
wires:
  - c4 -- c5 red
  - c5 -- c7 red
  - c7 -- c14 red
  - d5 -- c5 red
  - c1 -- e1 black
  - e1 -- h1 black
  - h1 -- h0 black
  - e5 -- e1 black
  - i1 -- i3
  - i5 -- i8
  - i8 -- i10
  - i10 -- j10
  - f7 -- f8
  - i11 -- j11
  - i11 -- i13
  - f13 -- f14
  - i13 -- i15
  - i17 -- i19
  - i19 -- i24
  - l19 -- m19 black
  - j0 -- j2 black
  - j2 -- m2 black
  - m2 -- m12 black
  - m12 -- m19 black
  - m19 -- m21 black
  - j12 -- m12 black
  - j25 -- j21 black
  - j21 -- m21 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/05-stability-k-factor.svg)

- RST は C2 の出口 (i19) から GND の線 (m 行) へ最短で。長いと高い周波数で
  RST にインダクタンスが直列に付き、効きが落ちる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜150 MHz (8-4 と同じ。K < 1 の所を細かく見るなら 1〜10 MHz) |
| 点数 | 150 |
| 校正 | 8-4 と同じ (CH0 に 20 dB パッド、パッドの先で SOLT) |
| 測る順 | 表で S11・S21 → **ユニバーサル基板を裏返して** (J2 を CH0、J1 を CH1) S22・S12 → RST を足して同じ 2 回 |
| 表示 | 表では S11 と S21 の Log Mag と位相。裏では S11 (= S22) の \|Z\| と Smith |

4 回の掃引を `.s1p` / `.s2p` に保存し、次のように組み合わせて K を出す
(NanoVNA-Saver の保存は 2-4・2-5)。

```python
import numpy as np

def k_factor(s11, s21, s12, s22):
    """複素数の S パラメータ 4 つから K と |Δ| を返す"""
    delta = s11 * s22 - s12 * s21
    k = (1 - abs(s11)**2 - abs(s22)**2 + abs(delta)**2) / (2 * abs(s12 * s21))
    return k, abs(delta)
```

裏返したときの S11 が S22、S21 が S12 になる。**表と裏で校正を変えない**
(同じ校正で 2 回測る) ことと、両方の周波数の並びをそろえることに気をつける。

**裏返して見た出力側** (S22) の見えるはずの画面。コレクタの Z は周波数で大きく
動くので、ここでは **3 MHz の値に合わせた等価回路** (3.3 kΩ ∥ 25 pF) で描き、
3 MHz のマーカーだけを読む。

```vna
device: h4
sweep: 2M-5M 31
title: 図3 RST 無しの S22 — |Z| 1.8 kΩ、Smith の外周すれすれ (3 MHz で合わせた等価回路)
dut:
  - shunt R 3k3
  - shunt C 25p
  - open
traces:
  - S11 z
  - S11 smith
markers:
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/05-stability-k-factor-1.svg)

```vna
device: h4
sweep: 2M-5M 31
title: 図4 RST 270 Ω を足した S22 — |Z| 248 Ω、外周から内へ入る (同じ等価回路 + 270 Ω)
dut:
  - shunt R 270
  - shunt R 3k3
  - shunt C 25p
  - open
traces:
  - S11 z
  - S11 smith
markers:
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/05-stability-k-factor-2.svg)

- 図3 の点は Smith の**外周のすぐ内側** (|Γ| ≈ 0.97、SWR 66)。出力に来た波をほとんど
  そのまま返す。**これが K を 1 より下げる**。SWR や Log Mag の枠では上端に
  張り付いて読めないので、|Z| の枠 (対数) で見る
- 図4 は 270 Ω が並列に入って 246 Ω − j29 Ω (|Γ| ≈ 0.67、SWR 5.0)。外周から離れた
- 等価回路は 3 MHz でだけ合わせてある。ほかの周波数の S22 は下の表 (ハイブリッド π の
  計算値) を見る。S21 は利得の素子が無いので描けない (8-4 と同じ)

## 見るべき値

計算値 (8-4 のハイブリッド π の模型、入出力とも 50 Ω)。

| 周波数 | K (RST 無し) | \|Δ\| (無し) | S22 (無し) | K (RST 270 Ω) | \|Δ\| (有り) | S22 (有り) | S21 (無し → 有り) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 MHz | **0.25** | 0.90 | −0.07 dB | 4.08 | 0.62 | −3.32 dB | 23.5 → 22.0 dB |
| 3 MHz | **0.66** | 0.79 | −0.25 dB | 3.97 | 0.54 | −3.52 dB | 22.3 → 20.9 dB |
| 4.6 MHz | **1.00** | 0.68 | −0.42 dB | 5.17 | 0.47 | −3.69 dB | 21.0 → 19.5 dB |
| 10 MHz | 2.16 | 0.41 | −0.72 dB | 10.1 | 0.28 | −4.01 dB | 16.7 → 15.2 dB |
| 30 MHz | 6.47 | 0.15 | −0.89 dB | 29.4 | 0.10 | −4.18 dB | 8.0 → 6.5 dB |

- **RST 無しでは 4.6 MHz より下で K < 1** (条件つき安定)。|Δ| はどこでも 1 より小さい
- RST 270 Ω を足すと、**全域で K > 3** になる (無条件安定)。代わりに失う利得は 1.5 dB
- 周波数を上げると K は大きくなる。S21 が落ち、S12 は −45 dB あたりで止まるので、
  分母の |S12 S21| が小さくなるから
- 実測の f<sub>T</sub> が 80 MHz より高いと、S21 の落ち始めが遅れ、K < 1 の範囲は
  表より高い周波数まで伸びる。**表の数ではなく、自分で測った 4 つから計算した K で判断する**

## 出典

自作。安定係数 K (Rollett の安定係数) と Δ の式は標準的な RF 回路の教科書による。
