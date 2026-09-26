---
book: nanovna
chapter: 8
id: 8-1
title: アンプの S21 (利得 vs 周波数)
tier: 50
source: 自作
board: PF
device: H4
---

# 8-1 アンプの S21 (利得 vs 周波数)

小信号アンプ (2SC1815 の 1 段増幅) の利得を S21 で測る。**アンプは電力を生む
(受動素子ではない) ので、この本のフェンス (vna 0.1.0) の `dut:` (R・L・C・
伝送線路の縦続だけ) では利得のある画面を描けない。** ここでは描ける範囲
(アッテネータだけの基準画面) を示し、利得を足した実際の読みは計算で示す。

**CH1 の最大入力に注意**: 0-3 で扱ったとおり、NanoVNA の CH1 に入れてよい電力には
上限があり、超えると壊れる。アンプの出力をそのまま CH1 に入れると、利得の分だけ
NanoVNA 自身の出力レベルより高くなって上限に届くおそれがある。**アンプの出力と
CH1 の間に必ずアッテネータを挟む** (ここでは 3-5 と同じ考え方の 10 dB パッドを使う)。

## この実験で確かめる式

**Av = Rc / re′**、**re′ = 26 mV / Ic** (共通エミッタ、エミッタを大きな
コンデンサでバイパスした場合の中域利得)。

バイアス: Vcc = 9 V、R1 = 27 kΩ、R2 = 4.7 kΩ、Re = 620 Ω、Rc = 270 Ω。

Vb = Vcc × R2/(R1+R2) = 1.33 V、Ve = Vb − 0.7 = 0.63 V、
Ic ≈ Ve / Re = 1.02 mA、re′ = 26mV / 1.02mA ≈ 25.4 Ω。

**Av = 270 / 25.4 ≈ 10.6 倍 ≈ 20.5 dB (計算値、中域)**。

## 回路図

```circuit
title: 図1 2SC1815 1 段増幅 + 出力アッテネータ
parts:
  J1: sma c2 mirror CH0
  C1: capacitor c4 c6 0.1u
  R1: resistor a6 c6 27k
  R2: resistor c6 e6 4k7
  BAT: battery a1 e1 9
  Q1: npn c8
  Rc: resistor a8 b8 270
  Re: resistor d8 f8 620
  Ce: capacitor d9 f9 10u
  C2: capacitor b8 b10 0.1u
  PR1: resistor b10 e10 100
  PR2: resistor b10 b12 68
  PR3: resistor b12 e12 100
  J2: sma b14 CH1
  GJ1: ground d2
  GBAT: ground e1
  GR2: ground e6
  GRE: ground f8
  GCE: ground f9
  GPR1: ground e10
  GPR3: ground e12
  GJ2: ground c14
wires:
  - J1.1 -- c4
  - J1.2 -- d2
  - a1 -- a6 -- a8
  - c6 -- Q1.B
  - Q1.C |- b8
  - Q1.E |- d8
  - d8 -- d9
  - f8 -- f9
  - b12 -- b14 -- J2.1
  - J2.2 -- c14
```

- Q1 のコレクタ抵抗 Rc (270 Ω) が利得を決める。エミッタの Re (620 Ω) は
  Ce (10 µF) でバイパスして交流的には短絡し、直流の動作点だけを安定させる
- 出力の PR1・PR2・PR3 が 10 dB (計算値 9.6 dB) の π 型アッテネータ
  (100 Ω・68 Ω・100 Ω、8-3 と同じ設計)。ここを通してから CH1 へ

## 実体配線図

```perfboard
board:
  size: 27x9
title: 図2 perfboard に組む (アンプ + アッテネータ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 e5 100n
  R1: resistor c6 e6 27k
  R2: resistor e8 h8 4k7
  BAT: battery c4 c1 9
  Q1: transistor f12 f11 f10
  Rc: resistor c11 e11 270
  Re: resistor g12 i12 620
  Ce: capacitor g13 h13 10u
  C2: capacitor e15 e17 100n
  PR1: resistor e19 h19 100
  PR2: resistor e20 e22 68
  PR3: resistor e23 h23 100
  J2: sma/female-edge e26 f27
wires:
  - e1 -- e3
  - e5 -- e6
  - e6 -- e8
  - e8 -- e10
  - e10 -- f10
  - c4 -- c6 red
  - c6 -- c11 red
  - e11 -- f11
  - e11 -- e15
  - f12 -- g12
  - g12 -- g13
  - i12 -- h12
  - h13 -- h12
  - e17 -- e19
  - e19 -- e20
  - e22 -- e23
  - e23 -- e25
  - e25 -- e26
  - c1 -- d1 black
  - d1 -- d0 black
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h8 black
  - h8 -- h12 black
  - h12 -- h19 black
  - h19 -- h23 black
  - f27 -- f25 black
  - f25 -- h25 black
  - h25 -- h23 black
```

- Q1 は変換基板に載せた TO-92 (`transistor` は 3 本足)。足の並びは 2SC1815 の
  実物 (1 = E、2 = C、3 = B) に合わせて配線する
- Vcc (電池) の配線は省略。R1 の上端と Rc の上端を電池の + へ、GND バスを − へ
  つなぐ (図1 の等価回路を参照)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz (2SC1815 が素直に増幅できる範囲) |
| 点数 | 61 |
| 校正 | SOLT (アッテネータの手前で) |
| 表示 | S21 の Log Mag |

**アンプを挟む前に、出力アッテネータ単体の S21 を確かめる**画面
(利得は描けないので、この基準を先に見る)。

```vna
device: h4
sweep: 1M-30M 61
title: 図3 出力アッテネータ単体の S21 (アンプを挟む前の基準)
dut:
  - shunt R 100
  - series R 68
  - shunt R 100
traces:
  - S21 logmag
markers:
  - 1M
  - 30M
```

- アッテネータだけなら周波数によらず一定 (−9.63 dB、計算値)。**この基準を
  確かめてから**アンプをアッテネータの前に足す
- アンプを足すと、実際の CH1 の読みは「アンプの利得 − アッテネータの減衰」に
  なるはずだが、**利得のある画面はこのフェンスでは描けない** (見るべき値の
  表に計算値を示す)

## 見るべき値

計算値。

| 状態 | S21 | 分かること |
| --- | --- | --- |
| アッテネータ単体 (アンプなし) | −9.63 dB | 基準。パッドが正しく作れているかの確認 |
| 2SC1815 単体の利得 (計算) | +20.5 dB | Rc / re′ から計算した中域利得 |
| アンプ + アッテネータ (計算) | +10.9 dB | 20.5 dB − 9.6 dB。CH1 で読めるはずの値 |

- +10.9 dB は NanoVNA の出力レベルより信号が**強く**なって CH1 に入ることを
  意味する。アッテネータを外すと CH1 の最大入力に近づく、または超えるおそれが
  あるので、**測定中は外さない**
- 1 MHz〜30 MHz の範囲では 2SC1815 (f_T 約 80 MHz) はまだ素直に増幅する。
  上の周波数 (8-9 の GHz LNA モジュールなど) では別の部品が要る

## 出典

自作。2SC1815 の f_T はデータシートに載る代表値。
