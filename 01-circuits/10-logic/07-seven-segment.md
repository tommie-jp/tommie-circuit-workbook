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
- LT̄ (PIN 3) と BĪ (PIN 4) は +5V に固定する。どちらも負論理 (10-2) の検査用のピンで、
  LT̄ を GND に落とすと全セグメント点灯 (ランプテスト)、BĪ を GND に落とすと全消灯になる。
  ここでは使わないので無効にする
- LE (PIN 5) は GND に固定する。LE = 0 の間は、今の BCD がそのまま表示に出る (素通し)。
  LE を H にすると、そのときの表示のまま固定される (ラッチ、10-2)。10-5 の D フリップ
  フロップがクロックの立ち上がりの瞬間にだけ値を取り込むのに対し、LE は L の間ずっと
  素通しにする点が違う
- 4511 は BCD が 10〜15 (1010〜1111) のとき、どのセグメントも点けない
  (無効なコードとして空白にする)。数字の表示に絞った 4511 ならではの性質
- 出力 (PIN 9〜15、セグメント a〜g) は H で点灯させる向きに電流を出す。そのため DS1 は
  コモンカソード (全セグメントの LED のカソードを共通のピン COM1・COM2 にまとめた品) を使い、
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
  (閉じたとき 1 本 0.5mA) を足しても 70mA に届かない。4511 の 1 出力あたりの
  上限 25mA にも十分余裕がある。基板に組んだときの電流の扱いは、図2 の説明に書く

## 実体配線図

出力が 7 本 (a〜g) あり、ブレッドボードでは線が重なって追えない。配線が多いので perfboard に組む。
7 セグメントの 7 本の線は、ピンの並びの向きが U1 と逆なので、そのままでは交差が避けられない。
電流は約 50mA と、AD3 の Supplies の各レール 50mA (USB 給電で 250mW) の限度に近い。
そこで電源は別の 5V (USB アダプタ) にする。AD3 は電源に使わないので、この題の図には入れない。

```perfboard
unused: [DS1.dp]
title: 図2 perfboard に組む (部品面と半田面。電源は USB アダプタ)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
style:
  back: on
parts:
  PSU:
    type: device
    at: c30
    label: 5V USB アダプタ
    pins: [GND, +5V]
  U1: dip16 s17 r90 CD4511B
  DS1: seg7 z15
  Rf: resistor t16 v16 330
  Rg: resistor w15 y15 330
  Ra: resistor t14 v14 330
  Rb: resistor w13 y13 330
  Rc: resistor t12 v12 330
  Rd: resistor w11 y11 330
  Re: resistor t10 v10 330
  SWB: switch f23 f20
  RpdB: resistor f19 f17 10k
  SWC: switch i19 i16
  RpdC: resistor i15 i13 10k
  SWD: switch k15 k12
  RpdD: resistor k11 k9 10k
  SWA: switch m11 m8
  RpdA: resistor m7 m5 10k
notes:
  - text aa17: DS1 5161AS
wires:
  # 電源
  - PSU.+5V -- d25 red
  - d25 -- f25 red
  - f25 -- s25 red
  - s25 -- s17 red
  - PSU.GND -- c25 black
  - c25 -- c2 black
  - c2 -- k2 black
  - k2 -- ab2 black
  - ab2 -- ae2 black
  - ae16 -- ae2 black
  - ab16 -- ae16 black
  - ab15 -- ab16 black
  - ab9 -- ab2 black
  # + の階段
  - f25 -- f23 red
  - f23 -- i23 red
  - i23 -- i19 red
  - i19 -- k19 red
  - k19 -- k15 red
  - k15 -- m15 red
  - m15 -- p15 red
  - m15 -- m11 red
  - p15 -- p14 red
  # GND の階段
  - k5 -- k2 black
  - m5 -- k5 black
  - k5 -- k9 black
  - k9 -- i9 black
  - i9 -- i13 black
  - i13 -- f13 black
  - f13 -- f17 black
  - p13 -- o13 black
  - o13 -- o10 black
  - o10 -- p10 black
  - o10 -- o5 black
  - o5 -- m5 black
  # 入力
  - f20 -- f19 gray
  - p17 -- o17 gray
  - o17 -- o20 gray
  - o20 -- f20 gray
  - i16 -- i15 pink
  - p16 -- i16 pink
  - "k12 -- k11 #00aaaa"
  - "p12 -- k12 #00aaaa"
  - "m8 -- m7 #c8a000"
  - "n8 -- m8 #c8a000"
  - "n11 -- n8 #c8a000"
  - "p11 -- n11 #c8a000"
  # 出力
  - s16 -- t16 yellow
  - s15 -- w15 orange
  - s14 -- t14 green
  - s13 -- w13 blue
  - s12 -- t12 purple
  - s11 -- w11 brown
  - s10 -- t10 white
  - v16 -- aa16 yellow
  - aa16 -- aa15 yellow
  - y15 -- z15 orange
  - v14 -- ac14 green
  - ac14 -- ac15 green
  - y13 -- ad13 blue
  - ad13 -- ad15 blue
  - v12 -- ac12 purple
  - ac12 -- ac9 purple
  - y11 -- aa11 brown
  - aa11 -- aa9 brown
  - v10 -- y10 white
  - y10 -- y9 white
  - y9 -- z9 white
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/perfboard/07-seven-segment.svg)

- ユニバーサル基板は 7×9 cm (1.6mm の FR-4) を横に置く。5×7 cm は、外周の 1 穴と電源の筋を残すと、入力の 4 組と出力の 7 本を線が重ならない間隔で置けない。
  左から入力 (スイッチと 10kΩ)・U1・Ra〜Rg・DS1 の順に並べ、信号が左から右へ流れる
- U1 (CD4511B) は縦に立てて切り欠きを上にする。左の列が上から PIN 1 (INB)〜PIN 8 (VSS)、右の列が上から PIN 16 (VDD)〜PIN 9 (Oe)。
  電源は左上の 5V USB アダプタ。+5V (赤) は B 行を右へ運んで VDD (J19) へ。
  左の「+ の階段」は、B 行から SWB・SWC・SWD・SWA の上のピン (D6・H9・L11・P13) と、LT・BL (L16・M16) へ配る
- GND (黒) は 3 列を下って Y 行へ。左の「GND の階段」は、RpdB・RpdC・RpdD・RpdA の下のピン (J6・N9・R11・V13) と、
  LE・VSS (N16・Q16) を結んで Y 行へ落とす。DS1 の COM2 (L28) は K 行を右へ出て 31 列を下り、COM1 (R28) は 28 列を下って、どちらも Y 行へ
- 入力は階段状の 4 組。上のピンを + の階段へ、下のピンを GND の階段へつなぎ、スイッチと 10kΩ の間 (G6/H6・K9/L9・O11/P11・S13/T13) から、
  色の付いた線で U1 の入力 (灰 INB・桃 INC・水色 IND・金 INA) へ運ぶ
- 出力 Ra〜Rg は、U1 の右の列から 1 行ずつ右へ出る。隣の行の字が重ならないよう、Rf・Ra・Rc・Re と Rg・Rb・Rd を 2 列にずらして置いた。
  線は実物の被覆の色で描き分ける (f 黄・g 橙・a 緑・b 青・c 紫・d 茶・e 白)
- DS1 は 5161AS (コモンカソード)。上の列が左から g・f・COM2・a・b、下の列が左から e・d・COM1・c・dp。dp は使わない (`unused:` に並べて、ERC の「つながっていない」から外した)
- DS1 のピンは上と下の 2 列だけで、間の穴は空いている。a・b・c・d の 4 本は半田面で DS1 の下を通し、
  上の列の a・b と下の列の c・d のピンへ運ぶ。f・g・e は DS1 の外を通る
- 交差は 5 か所で、どれも被覆線で跨ぐ。灰 (INB) が + の階段 (SWC へ) を、桃 (INC) が + の階段 (SWD へ) を、
  水色 (IND) が + の階段 (SWA へ) と GND の線 (LE・VSS を結ぶ線) を、金 (INA) が GND の線を跨ぐ。
  このピンの並びで、交差を 0 にする配置は見つけられなかった
- ユニバーサル基板を流れる電流は、セグメント 7 本で最大約 47mA (回路図の見積もり)、プルダウンで約 2mA で、合計は 50mA 前後
  (5V で見積もっても 7 × 9.1mA ≈ 64mA)。perfboard の範囲 (1 本の線・ランドごとに 500mA、ユニバーサル基板全体で 2A) には余裕で収まる。
  USB アダプタは 500mA 以上のものを使う

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | BCD → 7 セグメント デコーダ | CD4511 (DIP-16) |
| DS1 | 7 セグメント LED (赤、コモンカソード) | 5161AS など。V<sub>F</sub> 約 2.0V |
| Ra〜Rg | 抵抗 (1/4 W)、セグメントの電流制限 | 330Ω × 7 本 |
| RpdA〜RpdD | 抵抗 (1/4 W)、プルダウン | 10kΩ × 4 本 |
| SWA〜SWD | スライドスイッチかトグルスイッチ | 4 個 |
| — | 電源 | 5V の USB アダプタ (500mA 以上)。AD3 の Supplies は各レール 50mA の限度に近いので使わない |

## 計器の設定

計器はテスターだけ。電源は 5V の USB アダプタで、AD3 は使わない (電流が Supplies の限度に近いため)。
スイッチで決めた BCD を 7 セグメントの形に直す回路は、時間で動かず、
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
