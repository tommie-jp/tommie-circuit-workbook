---
book: circuits
chapter: 9
id: 9-5
title: 1 石レフレックスラジオ
tier: 100
source: 自作
board: BB
era: 古
---

# 9-5 1 石レフレックスラジオ

9-3 の 1 石ラジオは、トランジスタで**高周波を増幅してから**検波するだけだった。
**レフレックス**は、検波した後の**音声をもう一度同じトランジスタのベースへ
戻して**、同じ 1 石で 2 回目の増幅 (今度は低周波) をさせる方式。石を増やさずに
ゲインを稼げる、電池の少ない時代ならではの工夫。

## 回路図

```circuit
title: 図1 検波した音声をベースへ戻す1石レフレックス
parts:
  ANT: port g1
  L1: inductor g2 i2 250u
  GL: ground i2
  VC1: capacitor-var g4 i4 l=$\mathrm{VC}_1$
  GVC: ground i4
  C1: capacitor g6 g7 0.01u
  Q1: npn g10
  VCC: vcc a10
  Rc: resistor a10 c10 1.5k
  Rb: resistor f10 f8 180k
  GE: ground h10
  D1: diode e11 e13 1N60
  C3: capacitor e14 g14 0.001u
  GC3: ground g14
  R3: resistor e16 g16 100k
  GR3: ground g16
  Cf: capacitor i18 i16 0.1u
  Rf: resistor i15 i11 470k
  L2: inductor c11 c13 1m
  C5: capacitor c13 c15 0.1u
  EAR:
    type: device
    at: d23
    pins: [A, B]
  C6: capacitor c20 e20 0.001u
  GC6: ground e20
wires:
  - g1 -- g6
  - g7 -- g8
  - g8 -- Q1.B
  - f8 -- g8
  - Q1.C -- f10
  - f10 -- e10
  - e10 -- c10
  - c10 -- c11
  - e10 -- e11
  - Q1.E -- h10
  - e13 -- e18
  - e18 -- i18
  - i16 -- i15
  - i11 -- i8
  - i8 -- g8
  - c15 -- c21
  - c21 |- EAR.A
  - EAR.B -| e22
  - e22 -- e20
```

- **前段は 9-3 と同じ**: L1・VC1 のタンクで選局し、C1 で Q1 のベースへ結合。
  Rb (180kΩ、コレクタ帰還) と Rc (1.5kΩ) のバイアスも同じ (Ic ≈ 1.0mA、
  Vc ≈ 1.5V、9-3 と同じ計算値)
- **検波も 9-3 と同じ**: D1 (1N60) がコレクタから検波し、C3 が高周波バイパス、
  R3 (100kΩ) が検波の負荷。ここまでは「タンク → 増幅 → 検波」の 1 パス
- **ここからがレフレックス**: 検波済みの音声 (R3 の上端、D1 のカソード側) を
  **Cf (0.1µF) と Rf (470kΩ) を通してもう一度 Q1 のベースへ戻す**。Cf は
  音声 (1kHz 前後) では低インピーダンスだが、C1 (0.01µF) ほど高周波を
  よく通さないので、ベースには「タンクからの高周波」と「戻ってきた音声」の
  **両方が別々に重なって**乗る
- Q1 は重なった信号をそのまま増幅するので、コレクタには**増幅された高周波
  (もう検波済みで使わない) と増幅された音声の両方**が出る。L2 (1mH) が
  高周波を止め、C5 (0.1µF) で直流を切り、C6 (0.001µF) で残った高周波を
  EAR の手前でアースへ逃がすと、**2 回増幅された音声**だけが EAR
  (クリスタルイヤホン) に届く
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω の
  ダイナミック型のイヤホンでは鳴らない
- 音声では、C5 (0.1µF) とイヤホン + C6 (合わせて約 16nF) が直列の分圧になり、
  イヤホンに届くのはコレクタの音声の約 0.86 倍 (約 −1.3dB)。Rc (1.5kΩ) から見た
  高域のカットオフは約 7.7kHz で、声の帯域 (〜3kHz) は落ちない
- **L2 は高周波のせき止め (RFC)**: C5 の先の EAR と C6 は合わせて約 16nF あり、
  中波では 10〜20Ω しかない (1MHz で約 10Ω)。コレクタから直につなぐと、
  増幅したい高周波がここで GND へ抜けて、コレクタの高周波の利得が 1 を下回る。
  L2 は 1MHz で約 6.3kΩ (531kHz でも約 3.3kΩ) あるので、高周波の負荷は
  Rc と並べて約 1.2kΩ に戻り、利得は約 47 倍 (g<sub>m</sub> ≈ 38mS、D1 と Rb の負荷を除いた計算値) になる。
  1kHz の音声には約 6Ω しかなく、ほぼそのまま通る
- Rf (470kΩ) は帰還の量を絞る抵抗。小さくしすぎると高周波側にも回り込んで
  発振しやすくなり、大きすぎると音声が戻らずレフレックスの効果が薄れる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [E, A]
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b8 b12 250u
  C1: capacitor/ceramic d8 d14 0.01u
  Q1: transistor j14(B) j18(C) j22(E) 2SC1815
  Rf: resistor b14 b19 470k
  Rc: resistor d18 d15 1.5k
  D1: diode a18(A) a24(K) 1N60
  Cf: capacitor/ceramic c19 c24 0.1u
  C3: capacitor/ceramic b24 b28 0.001u
  R3: resistor d24 d28 100k
  Rb: resistor h14 h18 180k
  L2: inductor/axial g18 g21 1m
  C5: capacitor/ceramic f21 f24 0.1u
  C6: capacitor/ceramic h24 h28 0.001u
wires:
  - ANT.1 -- c8 yellow
  - VC1.A -- a8 yellow
  - VC1.E -- -t6 black
  - a12 -- -t12 black
  - e14 -- f14 orange
  - e18 -- f18 blue
  - +t15 -- a15 red
  - a28 -- -t28 black
  - i22 -- i23 black
  - j23 -- -b23 black
  - EAR.A -- j24 green
  - EAR.B -- -b26 black
  - j28 -- -b28 black
  - -t30 -- -b30 black
```

- 上の赤レール = +5V (USB や電池)、青レール = GND。30 列で上下の − レールを渡している
- 前段は 9-3 と同じく、8 列にアンテナ・VC1・L1・C1 をまとめる
- Q1 は下のブロックの j 行 (14 列 B・18 列 C・22 列 E)。ベース (14 列) とコレクタ (18 列) は
  e–f の短い線で上のブロックへも出し、足の多いネットを上下に分ける
- レフレックスの帰還は D1 のカソード (24 列) → Cf → 19 列 → Rf → ベース (14 列)。
  コレクタ (g18) から L2 で 21 列へ、C5 で EAR の A 端子 (24 列、下) へ。C6 が残った高周波を GND へ逃がす
- 1 つの穴には足か線を 1 本だけ挿す

## 見るべき値

計算値。バイアス点は 9-3 と同じ (Ic ≈ 1.0mA、Vc ≈ 1.5V)。

| 確かめること | 期待する値 |
| --- | --- |
| 9-3 と同じ局を受信 | **9-3 より音が大きい** (音声も増幅される分) |
| Cf を外す (帰還を切る) | 9-3 と同じ音量に戻る (レフレックスの効果が消える) |
| Rf を 100kΩ に下げる | 音が大きくなるが、局によっては「ボー」という発振音が混ざることがある (帰還が強すぎる目安) |

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
