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
  VCC: vcc a17 5V
  SWA: switch a17 c17 l=$\mathrm{SW}_\mathrm{A}$
  RpdA: resistor c17 c15 10k
  GA: ground c15
  VCC: vcc a13 5V
  SWB: switch a13 c13 l=$\mathrm{SW}_\mathrm{B}$
  RpdB: resistor c13 c11 10k
  GB: ground c11
  VCC: vcc a9 5V
  SWC: switch a9 c9 l=$\mathrm{SW}_\mathrm{C}$
  RpdC: resistor c9 c7 10k
  GC: ground c7
  VCC: vcc a5 5V
  SWD: switch a5 c5 l=$\mathrm{SW}_\mathrm{D}$
  RpdD: resistor c5 c3 10k
  GD: ground c3
  U1: ic h20 CD4511B
  VCC: vcc d20 5V
  GU1: ground k20
  Ra: resistor k36 m36 330
  Rb: resistor k34 m34 330
  Rc: resistor k32 m32 330
  Rd: resistor k30 m30 330
  Re: resistor k28 m28 330
  Rf: resistor k26 m26 330
  Rg: resistor k24 m24 330
  DS1: seg7 q41
  GCOM: ground t38
wires:
  # 電源: VDD (PIN 16)・LT (PIN 3)・BL (PIN 4) を +5V、VSS (PIN 8)・LE (PIN 5) を GND へ
  - U1.VDD |- d19a5
  - U1.LT |- d20
  - U1.BL |- d20a5
  - d19a5 -- d20 -- d20a5
  - U1.VSS |- k20
  - U1.5 |- k20a5
  - k20 -- k20a5
  # 入力: SWA〜SWD から BCD の A〜D へ (D が最も左)
  - U1.INA -| c17
  - U1.INB -| c13
  - U1.INC -| c9
  - U1.IND -| c5
  # 出力 a〜g: 下りて電流制限の抵抗 (Ra〜Rg) を通り、DS1 へ
  - U1.Oa -| k36
  - m36 |- DS1.a
  - U1.Ob -| k34
  - m34 |- DS1.b
  - U1.Oc -| k32
  - m32 |- DS1.c
  - U1.Od -| k30
  - m30 |- DS1.d
  - U1.Oe -| k28
  - m28 |- DS1.e
  - U1.Of -| k26
  - m26 |- DS1.f
  - U1.Og -| k24
  - m24 |- DS1.g
  - DS1.COM1 -| t38
  - DS1.COM2 -| t38
notes:
  - text u1 small left: "VDD は PIN 16 (+5V)、VSS は PIN 8 (GND)"
  - text v1 small left: "LT (PIN 3)・BL (PIN 4) は +5V、LE (PIN 5) は GND に固定"
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

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (U1 は CD4511B、DS1 は 7 セグメント LED。電源は AD3 の Supplies)
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  U1: dip16 @ e30 CD4511B
  DS1: seg7 @ h50
  Rg: resistor a47 a50 330
  Rf: resistor b48 b51 330
  Ra: resistor c49 c53 330
  Rb: resistor b54 b57 330
  Re: resistor i47 i50 330
  Rd: resistor j48 j51 330
  Rc: resistor i53 i56 330
  SWA: switch c22 c25
  RpdA: resistor d22 d20 10k
  SWB: switch c16 c19
  RpdB: resistor d16 d14 10k
  SWC: switch c10 c13
  RpdC: resistor d10 d8 10k
  SWD: switch c4 c7
  RpdD: resistor d4 d2 10k
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t3 -- +b3 red
  - a30 -- +t30 red
  - h32 -- +b32 red
  - h33 -- +b33 red
  - h34 -- -b34 black
  - h37 -- -b37 black
  - a7 -- +t7 red
  - a13 -- +t13 red
  - a19 -- +t19 red
  - a25 -- +t25 red
  - a2 -- -t2 black
  - a8 -- -t8 black
  - a14 -- -t14 black
  - a20 -- -t20 black
  - a52 -- -t52 black
  - j52 -- -b52 black
  - e22 -- g22 yellow
  - g22 -- g36 yellow
  - e16 -- h16 yellow
  - h16 -- h30 yellow
  - e10 -- i10 yellow
  - i10 -- i31 yellow
  - e4 -- j4 yellow
  - j4 -- j35 yellow
  - b32 -- b47 orange
  - c31 -- c48 orange
  - d33 -- d49 orange
  - a34 -- b57 orange
  - c35 -- h56 orange
  - d36 -- h48 orange
  - d37 -- h47 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/07-seven-segment.svg)

- 板は full (60 列)。U1 (CD4511B) は 30〜37 列で、切り欠きが左、PIN 1 (INB) が下の左端 (f 行の 30 列)、PIN 16 (VDD) が上の左端
- 電源は AD3 の Supplies。V+ (赤) を +5V、GND (黒) を GND へ。VDD (PIN 16) と LT・BL (PIN 3・4) は +5V、VSS (PIN 8) と LE (PIN 5) は GND へ
- 入力は左の 4 組。上のブロックの SWD・SWC・SWB・SWA (左から 4・10・16・22 列) が +5V から、10kΩ のプルダウンが GND へ。
  各スイッチの出力の列から黄の線で、下のブロックの U1 の足 (IND・INC・INB・INA) へ
- 出力はオレンジの線。U1 の上の足 (Oa〜Og) から、右の抵抗 Ra〜Rg (330Ω) の左端へ渡す。
  抵抗の右端は DS1 の足の列で、a・b・f・g は上のブロック、c・d・e は下のブロック。
  7 本の線が交わらないように置けないので、図の色は同じで、線の端 (列の番号) で追う
- DS1 は 5161AS (コモンカソード)。50〜54 列に挿し、COM1・COM2 (52 列) を GND へ。dp は使わない
- 板を流れる電流は、セグメント 7 本で最大約 47mA (回路図の見積もり)、プルダウンで約 2mA で、合計は 50mA 前後
  (5V で見積もっても 7 × 9.1mA ≈ 64mA)。AD3 の Supplies の各レール 50mA (USB 給電で 250mW) の目安をわずかに超え得るので、
  Supplies だけで足りないときは 5V の USB アダプタを使い、その GND を AD3 の GND につなぐ。板の範囲 (1 穴 200mA・板全体 500mA) には収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | BCD → 7 セグメント デコーダ | CD4511 (DIP-16) |
| DS1 | 7 セグメント LED (赤、コモンカソード) | 5161AS など。V<sub>F</sub> 約 2.0V |
| Ra〜Rg | 抵抗 (1/4 W)、セグメントの電流制限 | 330Ω × 7 本 |
| RpdA〜RpdD | 抵抗 (1/4 W)、プルダウン | 10kΩ × 4 本 |
| SWA〜SWD | スライドスイッチかトグルスイッチ | 4 個 |
| — | 電源・計器 | AD3 の Supplies (V+ = 5V、GND。Master Enable を入れる)。電流が足りないときは 5V の USB アダプタ |

## 計器の設定

計器は AD3 の Supplies (5V) だけ。スイッチで決めた BCD を 7 セグメントの形に直す回路は、時間で動かず、
入力の組で表示が決まるので、オシロやロジックの画面は付けない (見るのは表示器の形と、テスターで測る電圧)。
テスターの直流電圧レンジで、Ra など抵抗の両端を測る。

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
