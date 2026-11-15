---
book: nanovna
chapter: 6
id: 6-18
title: 同軸スタブのノッチ (144 / 430 MHz)
tier: 200
source: 自作
board: —
device: H4
---

# 6-18 同軸スタブのノッチ (144 / 430 MHz)

5-7 で、先を開いた同軸ケーブル (スタブ) が長さ λ (ラムダ)/4 の周波数とその奇数倍で信号を落とすのを見た。
これをアマチュア無線の 2 つのバンド、**144 MHz 帯 (144〜146 MHz) と 430 MHz 帯 (430〜440 MHz)** に使う。
2 つの機械を近くで使うと、片方の送信がもう片方の受信機に飛び込む。スタブで相手のバンドだけを落としたい。
ところが 145 MHz の 3 倍は **435 MHz** で、ちょうど 430 MHz 帯の真ん中に当たる。この偶然が何を起こすかを
NanoVNA で確かめ、**先にコンデンサを付けた短いスタブ**で避ける。

## この実験で確かめる式

先端開放のスタブの入口の Z は −jZ0 cot βl (β (ベータ) は位相定数)。βl = 90°・270°・… (λ/4 の奇数倍) で 0 になり、
主線を GND へ短絡して S21 が落ちる。ケーブルは 5-7 と同じ 50 Ω (オーム)・速度係数 vf 0.66 として、
長さは l = vf × c / (4f):

| スタブ | ねらい | 長さ (電気的) | 落ちる所 |
| --- | --- | --- | --- |
| A | 435 MHz を落とす | 113.7 mm | 435 MHz・1305 MHz・… |
| B | 145 MHz を落とす | 341.1 mm | 145 MHz・**435 MHz**・725 MHz・… |

B は 145 MHz の 3 倍の 435 MHz でも 3λ/4 になって落ちる。**1 本のスタブでは 145 MHz を落として 435 MHz を通すことができない**。

**先にコンデンサ C を付けたスタブ** (長さ l、145 MHz での電気角 x) なら、落ちる所と通す所を別々に決められる。
入口の Z が 145 MHz で 0、435 MHz で ∞ (通す) になる条件は

- 145 MHz で 0: tan x = 1 / (ωC Z0) (ω (オメガ) = 2π (パイ) f)
- 435 MHz で ∞: tan 3x = −3ωC Z0

2 つを合わせると tan x の 4 次式 t⁴ + 6t² − 3 = 0 になり、t = 0.681、**x = 34.3°・C = 32.2 pF**。
E12 の **33 pF** にして 145 MHz で合わせ直すと x = 33.6°、**長さ 127.5 mm** (計算値)。
435 MHz での ∞ は 441 MHz に少しずれるが、430〜440 MHz の S21 は 0.00 dB のまま (下の LTspice)。

## 回路図

CH0 と CH1 の間を SMA の T 型アダプタで直結し、T の 3 つ目の口にスタブを挿す (5-7 と同じ)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 T で分けた先端開放の同軸スタブ
points:
  open: 5,5
parts:
  J1: sma 2,2 mirror CH0
  J2: sma 8,2 CH1
  TL1: tline 5,2 open 50 l=$\mathrm{TL}_1$
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 5,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 5,5.4 center: 開放
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/18-coax-stub-notch-1.svg)

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 先に 33 pF を付けた短いスタブ (145 MHz だけを落とす)
parts:
  J1: sma 2,2 mirror CH0
  J2: sma 8,2 CH1
  TL1: tline 5,2 5,5 50 l=$\mathrm{TL}_1$
  C1: capacitor 5,5 5,7 33p
  G1: ground 2,3
  G2: ground 8,3
  G3: ground 5,7
wires:
  - J1.1 -- 5,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/18-coax-stub-notch-2.svg)

- 図1 の TL1 の先は意図して開放のままにしてある (check が「どこにもつながっていない」と言うのはこのため)。
  長さは表のスタブ A か B
- 図2 の C1 はケーブルの切り口で、芯線と外皮の間に**チップの 33 pF (1608、C0G)** を直に半田付けする。
  リード付きのコンデンサはリードの数 nH で 435 MHz 付近に直列共振が来て、計算どおりにならない

この題は実体配線図を付けない — 同軸ケーブルと T 型アダプタだけで組む題で、基板に組む回路が無い (5-7 と同じ)。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100〜500 MHz (2 つのバンドを 1 画面に) |
| 点数 | 401 (1 MHz おき) |
| 校正 | SOLT。2 本のケーブルの先で。T はそのあと挿す |
| 表示 | S21 の Log Mag |

**長さは T の中と SMA のプラグの分も含めた電気的な長さ**。ケーブルは長めに切り、ノッチを見ながら先を詰める
(ノッチの周波数は長さに反比例。1 % 詰めると 1 % 上がる)。マーカーは 2 つのバンドの両端。
スタブ A の**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 100M-500M 401
title: 図4 435 MHz の λ/4 開放スタブ — 430 MHz 帯を落とし、144 MHz 帯は通す
dut:
  - shunt line 50 113.7mm vf 0.66 open
traces:
  - S21 logmag
markers:
  - 144M
  - 146M
  - 430M
  - 440M
notes:
  - band 144M 146M
  - band 430M 440M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/18-coax-stub-notch-1.svg)

スタブ B。掃引もマーカーも図4 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 100M-500M 401
title: 図5 145 MHz の λ/4 開放スタブ — 3 倍の 435 MHz でも落ちる
dut:
  - shunt line 50 341.1mm vf 0.66 open
traces:
  - S21 logmag
markers:
  - 144M
  - 146M
  - 430M
  - 440M
notes:
  - band 144M 146M
  - band 430M 440M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/18-coax-stub-notch-2.svg)

## 見るべき値

計算値 (損失の無いケーブルの模型)。

| マーカー | 周波数 | スタブ A (図4) | スタブ B (図5) | 33 pF 付き (127.5 mm) |
| --- | --- | --- | --- | --- |
| 1 | 144 MHz | −0.34 dB | −33.13 dB | −36.87 dB |
| 2 | 146 MHz | −0.35 dB | −33.45 dB | −36.73 dB |
| 3 | 430 MHz | −28.76 dB | −19.25 dB | 0.00 dB |
| 4 | 440 MHz | −28.95 dB | −19.44 dB | 0.00 dB |

- バンドの中心 (A は 435 MHz、B は 145 MHz と 435 MHz) では模型の S21 は限りなく深い。実物はケーブルの損失で
  −30〜−40 dB くらいで止まる (5-2 と同じ。目安)。読むのは**ノッチの周波数と、バンドの端の値**
- 33 pF 付きのスタブは vna の図の模型 (`dut:`) で描けない (スタブの先に部品を付けた形が無い) ので、LTspice で確かめた
- 33 pF のチップに ESL 0.5 nH (目安) があると、145 MHz のノッチは 144.1 MHz に下がる (計算値)。
  ケーブルを少し詰めて合わせる

分かること:

- **430 MHz 帯を落として 144 MHz 帯を通す**のは素直で、スタブ A 1 本で済む (144 MHz 帯の損失は 0.35 dB)
- **144 MHz 帯を落として 430 MHz 帯を通す**のは、λ/4 のスタブ 1 本ではできない。3 倍の高調波の関係で、
  430 MHz 帯も −19 dB 落ちる。逆に言えば、スタブ B は **144 MHz の送信機の 3 倍の高調波 (435 MHz) も一緒に落とす**
- 先にコンデンサを付けると、スタブの共振の並びが 1:3 から崩れ、落とす所と通す所を別々に選べる。
  LC のトラップ (6-6) と同じ考え方を、ケーブルの長さで作った

## LTspice での確かめ

`sim/18-coax-stub-notch.cir` で、図4・図5 の `dut:` の模型と、先に 33 pF を付けたスタブを LTspice の AC 解析にかけた
(50 Ω の電源と 50 Ω の終端。ケーブルは損失の無い T 素子、開放は 1 TΩ)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 本文の数字 (S21) | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 図4 (A) | 144 / 146 MHz | −0.34 / −0.35 dB | −0.34 / −0.35 dB | 合う |
| 図4 (A) | 430 / 440 MHz | −28.76 / −28.95 dB | −28.76 / −28.95 dB | 合う |
| 図5 (B) | 144 / 146 MHz | −33.13 / −33.45 dB | −33.13 / −33.45 dB | 合う |
| 図5 (B) | 430 / 440 MHz | −19.25 / −19.44 dB | −19.25 / −19.44 dB | 合う |
| 33 pF 付き | 144 / 145 / 146 MHz | −36.87 dB / 深い / −36.73 dB | −36.87 / −76.92 / −36.73 dB | 合う |
| 33 pF 付き | 430 / 435 / 440 MHz | 0.00 dB | 0.00 / 0.00 / 0.00 dB | 合う |
| 33 pF + ESL 0.5 nH | 145 / 435 MHz | ノッチが下にずれる / 通す | −37.84 / 0.00 dB | 合う |

t⁴ + 6t² − 3 = 0 → t = 0.681・x = 34.3°・C = 32.2 pF、33 pF での x = 33.6°・127.5 mm、∞ の 441 MHz は算術 (Python で数え直した)。

## 出典

自作。スタブの入口の Z は伝送線路の標準的な式による。

参考: [Wikipedia "Stub (electronics)"](https://en.wikipedia.org/wiki/Stub_(electronics))、[Wikipedia「スプリアス」](https://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%97%E3%83%AA%E3%82%A2%E3%82%B9)
