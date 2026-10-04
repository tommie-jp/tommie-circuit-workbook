---
book: circuits
chapter: 10
id: 10-7
title: 7 セグメントとデコーダ (4511)
tier: 100
source: 自作
---

# 10-7 7 セグメントとデコーダ (4511)

7 セグメント LED は、8 の字に並んだ 7 本の棒 (セグメント a〜g) の LED を点け分けて
数字を表す表示器。2 進数のままでは人が読みにくいので、数字の形に直す IC (デコーダ) を
間に入れる。

CD4511 は、2 進数 4 桁で表した 0〜9 (BCD: 10 進の 1 桁を 2 進数 4 桁で表す形) を、
7 セグメントの「0〜9 の形」に変換する IC。10-4 のバイナリカウンタの出力をここへ
つなげば、数字がそのまま見える表示器になる。この題ではまず、スイッチで直接 BCD を
入れてデコーダ単体の働きを確かめる。

## 回路図

```circuit
title: 図1 CD4511でBCDを7セグメントに変換する
parts:
  VCC: vcc a11 5V
  SWB: switch a11 c11 l=$\mathrm{SW}_\mathrm{B}$
  RpdB: resistor c11 e11 10k
  GB: ground e11
  VCC: vcc d8 5V
  SWC: switch d8 f8 l=$\mathrm{SW}_\mathrm{C}$
  RpdC: resistor f8 h8 10k
  GC: ground h8
  VCC: vcc h11 5V
  SWD: switch h11 j11 l=$\mathrm{SW}_\mathrm{D}$
  RpdD: resistor j11 l11 10k
  GD: ground l11
  VCC: vcc k8 5V
  SWA: switch k8 m8 l=$\mathrm{SW}_\mathrm{A}$
  RpdA: resistor m8 o8 10k
  GA: ground o8
  U1: dip16 h16 CD4511
  VCC: vcc e12a5 5V
  VCC: vcc e18a5 5V
  GND: ground h13f0
  GU1: ground j14a5
  DS1: seg7 p31
  GCOM: ground s29a5
  Ra: resistor k26a5 m26a5 330
  Rb: resistor k24a5 m24a5 330
  Rc: resistor k22a5 m22a5 330
  Rd: resistor k20a5 m20a5 330
  Re: resistor k18a5 m18a5 330
  Rg: resistor k33a5 m33a5 330
  Rf: resistor k35a5 m35a5 330
wires:
  - c11 -- c14
  - c14 |- U1.1
  - f8 -- f13a5
  - f13a5 |- U1.2
  - j11 -- j13a5
  - j13a5 |- U1.6
  - m8 -- m14
  - m14 |- U1.7
  - U1.3 -| e12a5
  - U1.4 -| e12a5
  - U1.5 -| h13f0
  - U1.8 -| j14a5
  - U1.16 -| e18a5
  # 出力 a〜e: 縦に下りて電流制限の抵抗 (Ra〜Re) を通り、DS1 へ
  - U1.13 -| k26a5
  - m26a5 |- DS1.a
  - U1.12 -| k24a5
  - m24a5 |- DS1.b
  - U1.11 -| k22a5
  - m22a5 |- DS1.c
  - U1.10 -| k20a5
  - m20a5 |- DS1.d
  - U1.9 -| k18a5
  - m18a5 |- DS1.e
  # 出力 f・g: 右を回って Rf・Rg を通り、DS1 の下から入る
  - U1.14 -| k33a5
  - m33a5 -- t33f5 -- t28f5
  - t28f5 |- DS1.g
  - U1.15 -| k35a5
  - m35a5 -- u35f5 -- u27f5
  - u27f5 |- DS1.f
  - DS1.COM1 -| s29a5
  - DS1.COM2 -| s29a5
notes:
  - text b12a5h5 small blue: "B"
  - text f10d5 small blue: "C"
  - text j11d8 small blue: "D"
  - text l12h5 small blue: "A"
  - text w1 small left: "VDD は PIN 16 (+5V)、VSS は PIN 8 (GND)"
  - text x1 small left: "LT (PIN 3)・BI (PIN 4) は +5V、LE (PIN 5) は GND に固定"
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/07-seven-segment.svg)

- SWA〜SWD が BCD の A (LSB、1 の位)〜D (MSB、8 の位)。開けると 0、閉じると 1
  (プルダウン抵抗が、開いたときの入力を 0V に決める)
- LT̄ (PIN 3) と BĪ (PIN 4) は +5V に固定する。どちらも負論理 (10-2) の検査用の足で、
  LT̄ を GND に落とすと全セグメント点灯 (ランプテスト)、BĪ を GND に落とすと全消灯になる。
  ここでは使わないので無効にする
- LE (PIN 5) は GND に固定する。LE = 0 の間は、今の BCD がそのまま表示に出る (素通し)。
  LE を H にすると、そのときの表示のまま固定される (ラッチ、10-2)。10-5 の D フリップ
  フロップがクロックの立ち上がりの瞬間にだけ値を取り込むのに対し、LE は L の間ずっと
  素通しにする点が違う
- 4511 は BCD が 10〜15 (1010〜1111) のとき、どのセグメントも点けない
  (無効なコードとして空白にする)。数字の表示に絞った 4511 ならではの性質
- 出力 (PIN 9〜15、セグメント a〜g) は H で点灯させる向きに電流を出す。そのため DS1 は
  コモンカソード (全セグメントの LED のカソードを共通の足 COM1・COM2 にまとめた品) を使い、
  COM を GND へつなぐ。コモンアノード品 (アノードが共通) では向きが逆で点かない
- セグメントは 1 本ずつが LED なので、1-1 の LED と同じく電流を決める抵抗が要る。
  出力ごとに Ra〜Rg (330Ω) を 1 本ずつ直列に入れる (図1 の中ほどの 7 本)。抵抗を
  省いて直結すると、電流を決めるものが 4511 の出力の内部だけになり、セグメントと
  4511 の両方に無理な電流が流れる
- 4511 の出力は、H のとき電源の 5V より 1V 弱低い。データシートの典型値は、
  5V 電源で 5mA を流したとき 4.25V、10mA で 4.10V なので、ここでは V<sub>OH</sub> ≈ 4.2V とする。
  セグメントの順方向電圧 V<sub>F</sub> は、赤の 7 セグメントで約 2.0V (使う品のデータシートで
  確かめる)。1 セグメントの電流は
  I = (V<sub>OH</sub> − V<sub>F</sub>) / R = (4.2V − 2.0V) / 330Ω ≈ 6.7mA (計算値)。
  5〜10mA の範囲に入る。出力が落ちないと仮定して 5V で見積もっても
  (5V − 2.0V) / 330Ω ≈ 9.1mA で、10mA を超えない。330Ω は E24 の値
- 電流がいちばん多いのは「8」を出して 7 セグメントが全部点くときで、
  7 × 6.7mA ≈ 47mA (5V で見積もっても 7 × 9.1mA ≈ 64mA)。プルダウン抵抗の 4 本
  (閉じたとき 1 本 0.5mA) を足しても 70mA に届かない。ブレッドボードに組んでも、
  1 穴 200mA・板全体 500mA (README の板の範囲) に収まる。4511 の 1 出力あたりの
  上限 25mA にも十分余裕がある

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | BCD → 7 セグメント デコーダ | CD4511 (DIP-16) |
| DS1 | 7 セグメント LED (赤、コモンカソード) | 5161AS など。V<sub>F</sub> 約 2.0V |
| Ra〜Rg | 抵抗 (1/4 W)、セグメントの電流制限 | 330Ω × 7 本 |
| RpdA〜RpdD | 抵抗 (1/4 W)、プルダウン | 10kΩ × 4 本 |
| SWA〜SWD | スライドスイッチかトグルスイッチ | 4 個 |
| — | 電源 | 5V |

## 見るべき値

| D C B A | 10進 | 表示 |
| --- | --- | --- |
| 0 0 0 0 | 0 | **0** |
| 0 0 0 1 | 1 | **1** |
| 0 1 0 0 | 4 | **4** |
| 1 0 0 1 | 9 | **9** |
| 1 0 1 0 | 10 | **空白** (無効なコード) |
| 1 1 1 1 | 15 | **空白** (無効なコード) |

スイッチは閉じると 1。10 進で 9 まではふつうの数字の形、10 以上はセグメントが全部消える。
点いているセグメントの抵抗 (Ra など) の両端をテスターの直流電圧レンジで測ると約 2.2V で、
330Ω で割ると約 6.7mA (計算値) になる。
LE を GND から外して +5V につなぎ替えてから BCD を変えると、表示は変わらないままになる
(直前の値を保持している)。

## 出典

自作。
