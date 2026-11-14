---
book: etc
chapter: 6
id: 6-6
title: 局発を水晶の VXO に替える — マイコン無しで 7.030 MHz の水晶を数 kHz 引っぱる
tier: 300
source: 自作
board: PF
---

# 6-6 局発を水晶の VXO に替える — マイコン無しで 7.030 MHz の水晶を数 kHz 引っぱる

[6-5 のダイレクトコンバージョン受信機](05-direct-conversion.md) は、局発 (局部発振) を Si5351 のモジュールと
Raspberry Pi Pico 2 で作った。ここではその 2 つを外し、**SA612 の中にある発振用のトランジスタと、7.030 MHz の水晶 1 個**で局発を作る。
水晶にコイルとポリバリコンを直列に足すと、発振周波数を数 kHz だけ動かせる。この回路を
**VXO (Variable Crystal Oscillator、可変水晶発振回路)** と呼ぶ。足す部品は 5 個で、プログラムは要らない。

- 得る物: マイコンもプログラムも無い受信機。電源を入れた瞬間から聞こえ、マイコンのクロックの雑音が無い
- 失う物: 受信できる範囲。Si5351 は 7.000〜7.200 MHz のどこへでも行けたが、VXO は**水晶の刻印のすぐ下の 5 kHz ほど**しか動かない
- 水晶発振そのものは [01-circuits 3-5 水晶発振](../../01-circuits/03-oscillators/05-crystal-oscillator.md)、
  コルピッツの形は [01-circuits 3-10 コルピッツ発振](../../01-circuits/03-oscillators/10-colpitts.md)、
  水晶の等価回路の測り方は [03-nanovna 4-6 水晶](../../03-nanovna/04-components/06-crystal.md) で扱った

受信だけの回路なので免許は要らない。局発はアンテナ端子へわずかに漏れるが、SA612 の発振は 1 mW に満たず、
同調回路とミキサーを逆向きに通って出るので微弱の範囲に収まる (見積り。漏れの大きさは測っていない)。

## 水晶を引っぱる仕組み

水晶は、直列の L<sub>m</sub>・C<sub>m</sub>・R<sub>s</sub> (機械の振動を表す枝) と、それに並列の C<sub>0</sub> (電極の間の容量) で表せる。
この題では 7 MHz の HC-49/U の典型として次の値を置く。**実物を測った値ではない** (見積り。測るなら 03-nanovna 4-6 の方法)。

| 定数 | 置いた値 | 意味 |
| --- | --- | --- |
| C<sub>m</sub> | 20 fF | 引っぱれる幅を決める。背の低い HC-49/S は 10〜15 fF と小さい |
| C<sub>0</sub> | 5 pF | 電極とケースの容量 |
| R<sub>s</sub> | 20 Ω (オーム) | 損失。データシートの上限は 100 Ω |
| 刻印 | 7.030 MHz (負荷容量 20 pF のとき) | 負荷容量は品ごとに違う (18〜32 pF) |
| 直列共振 f<sub>s</sub> | 7,027,189 Hz | 上の 4 つから計算。L<sub>m</sub> = 25.65 mH、Q = 5.7 万 |

水晶に直列に容量 C<sub>L</sub> をつなぐと、発振周波数は f<sub>s</sub> より上へ動く。

f = f<sub>s</sub> × (1 + C<sub>m</sub> ÷ (2 × (C<sub>0</sub> + C<sub>L</sub>)))

- **直列の容量を小さくするほど上へ**動く。ただし C<sub>L</sub> をいくら大きくしても f<sub>s</sub> より下へは行けない
- **直列にコイルを足すと下へ**行ける。コイルのリアクタンス ωL (ω (オメガ) = 2πf、π (パイ) は円周率) が容量の 1/(ωC<sub>L</sub>) を打ち消し、
  残りが誘導性になると、式の C<sub>L</sub> が**負の容量**として働く。実効の容量は C<sub>Leff</sub> = 1 ÷ (ω × (1/(ωC<sub>L</sub>) − ωL))
- C<sub>0</sub> + C<sub>Leff</sub> が 0 に近づくほど大きく動く。同時に、**コイルと容量のわずかな変化で周波数が大きく動く**ようになる

この回路の C<sub>L</sub> は、VC1 (と浮遊容量 10 pF、見積り) に、コルピッツの C<sub>A</sub>・C<sub>B</sub> (100 pF 2 本の直列で 50 pF) を直列にした値。
L1 を変えたときの発振周波数 (算術と LTspice。下の「LTspice での確かめ」):

| L1 | VC1 = 10 pF | VC1 = 260 pF | 動く幅 | L1 が 1 % 増えたときの動き (260 pF) |
| --- | --- | --- | --- | --- |
| 無し | 7.03083 MHz | 7.02868 MHz | 2.2 kHz | — |
| 22 µH (マイクロヘンリー) | 7.02887 MHz | 7.02570 MHz | 3.2 kHz | −37 Hz |
| **47 µH** | **7.02549 MHz** | **7.01999 MHz** | **5.5 kHz** | **−147 Hz** |
| 68 µH | 7.02082 MHz | 7.01059 MHz | 10.2 kHz | −442 Hz |

**47 µH にする。** 幅は 5.5 kHz 取れ、コイルの 1 % の変化で動くのは 150 Hz ほどに収まる。
68 µH なら幅は 2 倍になるが、コイルの温度変化や手を近づけたときの変化が 3 倍効き、CW の音の高さ (700 Hz) がふらつく。
さらに増やすと水晶は周波数を決められなくなり、コイルと容量で決まるただの LC 発振回路になる。**幅を欲張らないのが VXO の作法**。

**聞ける範囲は 7.0200〜7.0255 MHz。** 日本の 7 MHz 帯で CW が主に出る 7.000〜7.030 MHz のうち、5.5 kHz ぶんだけになる。
局発から 700 Hz 離れた信号が 700 Hz の音になるので、信号でいえば 7.0193〜7.0262 MHz。範囲を変えたければ水晶を替える
(7.010 MHz の水晶なら同じ回路で 7.000〜7.0055 MHz 付近)。**手に入る水晶の周波数が、そのまま受信範囲を決める。**
水晶の C<sub>m</sub> が 10 fF なら幅は 2.8 kHz、25 fF なら 6.9 kHz と、品でも大きく変わる (計算値)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 局発を水晶の VXO にした 7 MHz のダイレクトコンバージョン受信機
parts:
  J1: sma 2,9.5 mirror
  GJ1: ground 2,12.5
  T1: transformer 5,10.25
  GT1: ground 4,12.5
  C1: capacitor 7.5,9.5 7.5,11.5 100p
  TC1: capacitor-var 10.5,9.5 10.5,11.5 50p l=$\mathrm{TC}_1$
  C2: capacitor 12,11.5 12,13.5 10n
  GC2: ground 12,13.5
  U1: ic 18,10 SA612
  GU1: ground 18,13
  VCC: vcc 18,6 5V
  C12: capacitor 16,6 16,8 100n
  GC12: ground 16,8
  C13: ecap 13.5,6 13.5,8 10u
  GC13: ground 13.5,8
  CA: capacitor 14,16 14,18 100p l=$\mathrm{C_A}$
  CB: capacitor 14,18 14,20 100p l=$\mathrm{C_B}$
  GCB: ground 14,20
  X1: crystal 12,16 10,16 7.03M
  L1: inductor 9,16 7,16 47u
  VC1: capacitor-var 6,16 6,18 260p l=$\mathrm{VC}_1$
  GVC: ground 6,18
  C5: capacitor 21,8.5 21,11.5 47n
  C3: capacitor 22,8.5 24,8.5 10n
  C4: capacitor 22,11.5 24,11.5 10n
  U2: ic 28,10 LM386
  GU2: ground 28,13
  VCC: vcc 27.5,2 5V
  C10: ecap 30,2 30,4 100u
  GC10: ground 30,4
  C11: capacitor 33,2 33,4 100n
  GC11: ground 33,4
  C6: ecap 28,6.5 30,6.5 10u
  C7: ecap 30,12.5 30,14.5 10u
  GC7: ground 30,14.5
  R1: resistor 32,10 32,12 10
  C9: capacitor 32,12 32,14 47n
  GC9: ground 32,14
  C8: ecap 33,10 35,10 220u
  J2: earphone 36.5,10 36.5,12 l=$\mathrm{J}_2$
  GJ2: ground 36.5,12
wires:
  - J1.1 -- 3,9.5 -| T1.A1
  - J1.2 -- 2,12.5
  - T1.A2 -| 4,12.5
  - T1.B1 |- 7.5,9.5
  - 7.5,9.5 -- 10.5,9.5
  - 10.5,9.5 -| U1.IN_A
  - T1.B2 |- 7.5,11.5
  - 7.5,11.5 -- 10.5,11.5
  - 10.5,11.5 -- 12,11.5
  - 12,11.5 |- U1.IN_B
  - U1.VCC |- 18,6
  - 13.5,6 -- 16,6
  - 16,6 -- 18,6
  - U1.GND |- 18,13
  - U1.OSC_B -| 14,16
  - U1.OSC_E -| 16,18
  - 16,18 -- 14,18
  - 14,16 -- 12,16
  - 10,16 -- 9,16
  - 7,16 -- 6,16
  - U1.OUT_A -| 20,8.5
  - 20,8.5 -- 21,8.5
  - 21,8.5 -- 22,8.5
  - U1.OUT_B -| 20,11.5
  - 20,11.5 -- 21,11.5
  - 21,11.5 -- 22,11.5
  - 24,8.5 -- 25,8.5 |- U2.+INPUT
  - 24,11.5 -- 25,11.5 |- U2.-INPUT
  - U2.VS |- 27.5,2
  - 27.5,2 -- 30,2
  - 30,2 -- 33,2
  - U2.GAIN1 |- 28,6.5
  - U2.GAIN8 |- 28.5,7.5
  - 28.5,7.5 -- 30,7.5 -- 30,6.5
  - U2.GND |- 28,13
  - U2.BYPASS |- 30,12.5
  - U2.VOUT -| 32,10
  - 32,10 -- 33,10
  - 35,10 -- 36.5,10
notes:
  - text 3.2,8 small left: "T1 は T37-2 にリンク 4 回・2 次 32 回"
  - text 7,18.6 small left: "L1 は FT37-61 に 29 回"
  - box 4.6,15 16.8,20.8 blue
  - text 4.9,20.3 small blue left: "VXO (この題で足す 5 個)"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/06-vxo-1.svg)

- **VXO (青い枠)**: SA612 の 6 ピン (OSC_B、発振用トランジスタのベース) と 7 ピン (OSC_E、エミッタ) の間に C<sub>A</sub>、7 ピンと GND の間に C<sub>B</sub> を付けると
  コルピッツ発振回路になる。3-10 のコルピッツではコイルが入る所に、**水晶 X1・L1・VC1 の直列**を入れた。
  発振するのは、この枝のリアクタンスが C<sub>A</sub>・C<sub>B</sub> の直列 50 pF をちょうど打ち消す周波数
- **VC1** は中波ラジオ用の単連 260 pF のポリバリコン。片側を GND につなぐので、つまみに手を近づけても周波数が動きにくい。
  7.0255 MHz から 7.0219 MHz までの 3.6 kHz は 10〜50 pF の間で動く (回し始めに偏る)。細かく合わせたいときは、
  つまみに大きなダイヤルを付ける
- **L1** は FT37-61 (フェライトのトロイダルコア) に φ0.3 mm の UEW (ポリウレタン銅線) を 29 回巻く (約 46 µH、コアの許容差 ±25 %)。
  47 µH のアキシアルのコイルは自己共振が 10 MHz 前後にあり、7 MHz では値が大きく見えるので使わない
  (コアの材質は [03-nanovna 4-14](../../03-nanovna/04-components/14-toroid-materials.md))。
  **巻き数で範囲を合わせる**: 範囲が低すぎるか、VC1 を入れ切った所で発振が不安定なら 2〜3 回ほどく
- **T1 の 2 次の冷たい側は GND ではなく 2 ピン (IN_B) へ**つなぎ、IN_B を C2 で GND に落とす。
  1 ピンと 2 ピンには IC の中からバイアスの電圧が出ているので、コイルで GND に直結するとバイアスが落ちる。
  同調回路そのものは [6-3](03-input-tuning.md) と同じ (負荷時の Q 5.4、幅 1.32 MHz)
- **音声段**は [6-4](04-audio-lm386.md) と同じ。結合の C3・C4 は 10 nF、差動の間の C5 は 47 nF で、通過は 214 Hz〜1.70 kHz、700 Hz で 43.55 dB
- 3-5 の水晶発振 (CMOS インバータ) は、水晶の両側に負荷容量を付けて刻印の周波数で発振させる回路で、動かす部品が無い。
  ここでは水晶の片側にコイルとバリコンを直列に入れ、わざと刻印から外して使う

**6-5 の基板から替える部品** (6-5 の部品番号ではなく、働きで書く):

| 6-5 | この題 | 理由 |
| --- | --- | --- |
| Si5351 のモジュールと Pico 2、ブレッドボード | 外す | 局発を SA612 の中で作る |
| 局発を 0.3 Vpp に落とす 1 kΩ + 100 Ω と、OSC_B への 1 nF | 外す | 外からの局発を入れない |
| — | X1 (7.030 MHz)・L1・VC1・C<sub>A</sub>・C<sub>B</sub> を足す | VXO の 5 個 |
| OSC_E は何もつながない | C<sub>A</sub>・C<sub>B</sub> の中点へ | コルピッツの帰還 |
| 同調回路・SA612・LM386 の周り | そのまま | — |

## 実体配線図

基板は 7×9 cm を横置き (31 列 × 26 行、1.6 mm の FR-4、左右の縁にパッド)。5×7 cm では SA612・LM386・トロイダル 2 個・水晶が
配線の跨ぎを増やさずに並ばなかったので、標準の次の大きさにした。7 MHz はユニバーサル基板の範囲 (10 MHz 以下・短い配線) の内。
番地は基板の刷りどおりで、英字が列 (左から A〜AE)、数字が行 (下から 1〜26)。下は半田面 (左右が逆)。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
unused: [J3.D+, J3.D-]
title: 図2 ユニバーサル基板に組む (部品面。黄色の丸は AD3 を挟む所)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
parts:
  J1: sma/female-edge a13 014 012
  T1: transformer/toroid g13 g10 k13 k10 T37-2 4t:32t
  C1: capacitor/ceramic m13 m10 100p
  TC1: capacitor/trimmer o13 o11 50p
  C2: capacitor/ceramic q10 q7 10n
  U1: dip8 r16 SA612
  C12: capacitor/ceramic n17 n20 100n
  C13: capacitor/electrolytic l17 l19 10u v=16V
  CA: capacitor/ceramic t18 s18 100p
  CB: capacitor/ceramic r18 p18 100p
  X1: crystal/hc49 u18 u20 7.03M
  L1: inductor/toroid v22 y22 FT37-61 29t
  VC1:
    type: device
    at: y30
    label: VC1 バリコン
    pins: [A, E]
  C5: capacitor/ceramic v15 v12 47n
  C3: capacitor/ceramic v11 w11 10n
  C4: capacitor/ceramic w15 w13 10n
  U2: dip8 y16 LM386
  C6: capacitor/electrolytic x13 x16 10u v=16V
  C7: capacitor/electrolytic z17 z19 10u v=16V
  R1: resistor ac16 ac13 10
  C9: capacitor/ceramic ac12 ac11 47n
  C8: capacitor/electrolytic ad16 ad14 220u v=16V
  J2: sip4 aa8 AE-PHONE-JACK-DIP blue
  C10: capacitor/electrolytic v6 v7 100u v=16V
  C11: capacitor/ceramic x6 x7 100n
  J3: usb-c/female b5 c5 d5 e5
wires:
  - e5 -- e6 red
  - e6 -- e16 red
  - e16 -- l16 red
  - l16 -- n16 red
  - n16 -- r16 red
  - l16 -- l17 red
  - n16 -- n17 red
  - e6 -- v6 red
  - v6 -- x6 red
  - x6 -- ae6 red
  - ae6 -- ae17 red
  - ae17 -- aa17 red
  - aa17 -- aa16 red
  - b5 -- b6 black
  - b6 -- b7 black
  - a7 -- b7 black
  - b7 -- g7 black
  - g7 -- q7 black
  - q7 -- t7 black
  - t7 -- v7 black
  - v7 -- x7 black
  - x7 -- z7 black
  - z7 -- ab7 black
  - ab7 -- ac7 black
  - 012 -- a12 black
  - a12 -- a7 black
  - 014 -- a14 black
  - a14 -- a24 black
  - a24 -- l24 black
  - l24 -- n24 black
  - n24 -- p24 black
  - p24 -- z24 black
  - g10 -- g7 black
  - t13 -- t7 black
  - l19 -- l24 black
  - n20 -- n24 black
  - p18 -- p24 black
  - z19 -- z24 black
  - ab8 -- ab7 black
  - ac8 -- ac7 black
  - ab13 -- ab10 black
  - ab10 -- z10 black
  - z10 -- z7 black
  - ac11 -- ac10 black
  - ac10 -- ab10 black
  - a13 -- g13 white
  - k13 -- m13 yellow
  - m13 -- o13 yellow
  - o13 -- r13 yellow
  - k10 -- m10 green
  - m10 -- o10 green
  - o10 -- q10 green
  - o11 -- o10 green
  - q10 -- s10 green
  - s10 -- s13 green
  - t16 -- t18 orange
  - t18 -- u18 orange
  - s16 -- s18 blue
  - s18 -- r18 blue
  - u20 -- u22 orange
  - u22 -- v22 orange
  - VC1.A -- y22 orange
  - VC1.E -- z24 black
  - u13 -- u11 white
  - u11 -- v11 white
  - v12 -- v11 white
  - w11 -- aa11 white
  - aa11 -- aa13 white
  - u16 -- v16 yellow
  - v16 -- v15 yellow
  - v15 -- w15 yellow
  - w13 -- w12 yellow
  - w12 -- z12 yellow
  - z12 -- z13 yellow
  - y13 -- x13 blue
  - y16 -- x16 blue
  - z16 -- z17 white
  - ab16 -- ac16 orange
  - ac16 -- ad16 orange
  - ac13 -- ac12 white
  - ad14 -- ad9 orange
  - ad9 -- ad8 orange
  - ad9 -- aa9 orange
  - aa9 -- aa8 orange
notes:
  - mark ad12 yellow
  - text ae12 red large bold right: 1+
  - mark i7 yellow
  - text i8 red large bold center: GND
style:
  back: on
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/perfboard/06-vxo.svg)

- **電源**: USB-C (J3) の VBUS (e5) から E 列を 16 行まで上り、16 行を右へ U1 の 8 ピン (r16) へ (赤)。
  U2 へは 6 行を右端まで行き、AE 列を上って 17 行から 6 ピン (aa16) へ入る
- **GND**: 7 行を端から端まで (黒)。上の 24 行にも GND の筋を通し、J1 の金物 (012 と 014 は 1 つの金物) を通って 7 行とつながる。
  VXO の C<sub>B</sub>・VC1、U1 のパスコン (C12・C13)、U2 の C7 は 24 行へ落とす
- **同調回路**: T1 は G〜K 列。リンク (4 回) が g13・g10、2 次 (32 回) が k13・k10。熱い側は 13 行 (黄) を U1 の 1 ピンへ、
  冷たい側は 10 行 (緑) を回って 2 ピンへ。TC1 はトリマ (O13・O11。ピンの間隔が 5 mm なので 1 穴空け、O11 から O10 の緑の線へ短い線でつなぐ)
- **VXO**: U1 の 6 ピン (t16) から t18 の C<sub>A</sub>、隣の列の X1 (u18〜u20)、L1 (v22〜y22) と上へ並べた (橙)。7 ピン (s16) は s18 で C<sub>A</sub> と C<sub>B</sub> へ (青)。
  **X1 から L1 までの線は短く**する。ここは浮遊容量 1 pF で 200 Hz 動く (VC1 を抜いた側、計算値)
- **VC1 はパネルに付け、2 本の線で基板へ**つなぐ。A (固定の羽根) を L1 の端 y22 へ、E (回る羽根・軸) を GND の z24 へ。線は 5 cm 以内に
- **J2** は 3.5 mm ジャックの DIP 化キット。ピンは 8 行で、ジャックの口が基板の下の縁を向く。
  L と R を 9 行の線で束ねてある (ステレオのヘッドホンの両耳で鳴る)。2 本の GND のピンはすぐ下の 7 行へ落とし、
  U2 の 4 ピン (ab13) の GND は 10 行と Z 列を回って 7 行へ入る (束ねた線を渡らない)。
  キットの基板はピンヘッダの上に浮くので、下を電源と GND の線が通る
- **跨ぎは 3 か所**: VBUS が 7 行の GND を渡る e7、アンテナの線が VBUS を渡る e13、VC1 の A の線が 24 行の GND を渡る y24。
  どれも被覆線で渡る
- 動かないときは 3 つに分けて見る: ① J2 に指を触れて (または U2 の入力に AD3 の W1 の 700 Hz を入れて) 音が出るか (音声段)、
  ② 別の受信機か tinySA を基板に近づけて 7.02 MHz 付近に局発が見えるか (VXO)、③ 下の AD3 の信号が聞こえるか (同調とミキサー)

## 計器の設定

Analog Discovery 3 (AD3) の Wavegen は 7 MHz 台の正弦を出せるので、これを弱い電波の代わりにする。
ユニバーサル基板の図 (図2) では AD3 を箱で描かず、挟む穴を黄色の丸で示した。つなぎ方は次の図。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図3 試験のつなぎ (AD3 の W1 を減衰器に通してアンテナ端子へ)
parts:
  AD:
    type: device
    at: 2,4
    label: AD3
    pins: [W1, GND, 1+, 1-]
    turn: mirror
  R2: resistor 6,3 8,3 5.1k
  R3: resistor 9,3 9,5 51
  G1: ground 9,6
  RX:
    type: device
    at: 13,4
    label: RX
    pins: [J1, GND, J2]
wires:
  - AD.W1 -| 6,3
  - 8,3 -- 9,3
  - 9,3 -| RX.J1
  - 9,5 -- 9,6
  - AD.GND -| 5,5.5
  - 5,5.5 -- 9,5.5
  - RX.GND -| 10.5,5.5
  - 10.5,5.5 -- 9,5.5
  - AD.1+ -| 4.5,7
  - 4.5,7 -- 11.5,7
  - 11.5,7 |- RX.J2
  - AD.1- -| 5,5.5
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/06-vxo-2.svg)

- RX の箱は図1 の受信機 (J1 がアンテナ端子、J2 がヘッドホンの出力)
- R2 (5.1 kΩ) と R3 (51 Ω) は基板の外で、SMA のケーブルの先に空中配線する。W1 の振幅が約 1/100 (−40 dB) になり、出力抵抗は約 50 Ω
- 1+ は J2 の出力 (図2 の黄色の丸 ad12)、1− と GND は基板の GND (i7)。ヘッドホンは挿したままでよい
- **OSC_B (6 ピン) や水晶にプローブを当てない。** プローブの 10 pF 前後がそのまま回路に入り、周波数が動く。
  局発の周波数は、下の手順のように**音がゼロになる W1 の周波数**で読む

| 項目 | 設定 | 理由 |
| --- | --- | --- |
| Supplies | 使わない | 電源は USB-C の 5 V |
| Wavegen W1 | 正弦、7.0230 MHz、振幅 10 mV | 減衰器の先は開放で約 100 µV<sub>p</sub> (50 Ω に −76 dBm)。強い局くらいの信号 |
| Scope CH1 | 100 mV/div、500 µs/div、トリガは CH1 の立ち上がり 0 V | 700 Hz の音が 3.5 周期入る |
| 計測 | 周波数と Vpp | 音の高さと大きさ |

1. VC1 をゆっくり回す。W1 の 7.0230 MHz と局発の差が音になり、局発が近づくと音が低くなる。**音が消える所 (ゼロビート)** で局発は 7.0230 MHz
2. そこから少し回して 700 Hz にする (局発が 7.0223 MHz か 7.0237 MHz。どちら側でも同じ音になる)
3. VC1 を入れ切り (260 pF)、W1 の周波数を下げてゼロビートを探す。これが局発の下の端 (計算では 7.0200 MHz)。抜き切った側も同じ
4. T1 のトリマ TC1 を回して、音が一番大きくなる所に合わせる (幅が 1.3 MHz あるので山はなだらか)

AD3 の周波数の誤差はそのまま読みに乗る (10 ppm で 70 Hz)。CW を聞くだけなら差し支えない。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 J2 の出力 — W1 が局発の 700 Hz 上にあるときの音
time: 500us/div
trigger: ch1 rising 0V
ch1: sine 700Hz 0.26V
cursors: [0, 1.4286ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/scope/06-vxo.svg)

振幅 0.26 V<sub>p</sub> は見積り: アンテナ端子を 50 Ω で受けた電圧 49.5 µV<sub>p</sub> × 同調回路の 4.9 倍 (6-3) × SA612 の変換利得 17 dB (代表値) × 音声段の 43.55 dB (6-4)。
SA612 の利得は品と電源で数 dB 動く。

## 見るべき値

計算値。**実機では組んでいない (未測定)。** 水晶の定数は典型の見積りなので、周波数は数百 Hz〜1 kHz ずれて当たり前と考える。

| 測る所 | 期待する値 |
| --- | --- |
| 局発の上の端 (VC1 を抜き切る、10 pF) | 7.0255 MHz |
| 局発の下の端 (VC1 を入れ切る、260 pF) | 7.0200 MHz |
| 動く幅 | 5.5 kHz (水晶の C<sub>m</sub> が 10〜25 fF なら 2.8〜6.9 kHz) |
| VC1 = 50 pF・100 pF | 7.0219 MHz・7.0208 MHz |
| W1 が局発の 700 Hz 上・振幅 10 mV のときの J2 | 700 Hz、0.52 Vpp (見積り) |
| L1 を 2 回ほどいたとき (27 回、約 40 µH) | 下の端が約 2 kHz 上がり (7.0219 MHz)、幅は約 4.6 kHz に縮む |
| 手をコイルに近づける | 音の高さが変わる。数十 Hz なら正常、数百 Hz 動くなら L1 が大きすぎる |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 VC1 の容量と発振周波数 (刻印の 7.030 MHz からのずれ)
x: VC1の容量 pF 0..260
y: 刻印からのずれ kHz -11..1
lines:
  L1無し kHz:
    - 10 0.831
    - 20 0.146
    - 50 -0.635
    - 100 -1.027
    - 150 -1.182
    - 200 -1.264
    - 260 -1.323
  L1=22µH kHz:
    - 10 -1.135
    - 20 -2.115
    - 50 -3.263
    - 100 -3.852
    - 150 -4.086
    - 200 -4.212
    - 260 -4.302
  L1=47µH kHz:
    - 10 -4.512
    - 20 -6.132
    - 50 -8.121
    - 100 -9.184
    - 150 -9.613
    - 200 -9.845
    - 260 -10.013
notes:
  - mark 50
  - mark 260
  - level -2.811kHz
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/graph/06-vxo.svg)

- 3 本とも右へ行くほど寝る。VC1 の大きい側は、直列の 50 pF (C<sub>A</sub>・C<sub>B</sub>) が効いて容量がほとんど変わらないため
- 縦軸は刻印の 7.030 MHz からのずれ。赤い横の破線は水晶の直列共振 f<sub>s</sub> (−2.81 kHz)。47 µH の線は −4.5 kHz (7.0255 MHz) から −10.0 kHz (7.0200 MHz) まで
- L1 を足すと線が**丸ごと下へ**下がり、傾きも急になる。直列共振 f<sub>s</sub> (刻印の 2.81 kHz 下) より下にあるのが、コイルで引き下げたぶん
- 47 µH の線は、10 pF から 50 pF までに 3.6 kHz 動き、残りの 210 pF では 1.9 kHz しか動かない
- 電源を入れてから数分は周波数がゆっくり動く (水晶とフェライトの温度)。動きが止まってから合わせる

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | SA612A (DIP8) | NE612・NE602 も同じ |
| U2 | LM386N-1 | 6-4 と同じ |
| X1 | 水晶 7.030 MHz、HC-49/U | 背の高い HC-49/U を選ぶ (HC-49/S は引っぱれる幅が狭い)。刻印の周波数で受信範囲が決まる |
| L1 | FT37-61 に φ0.3 mm の UEW を 29 回 (約 46 µH) | 巻き数で範囲を合わせる |
| VC1 | ポリバリコン 単連 260 pF | 中波ラジオ用。パネルに付ける |
| C<sub>A</sub>・C<sub>B</sub> | 100 pF (101)、C0G | コルピッツの 2 本。温度で動かない C0G (CH) |
| T1 | T37-2 に φ0.3 mm の UEW、リンク 4 回・2 次 32 回 | 6-3 と同じ |
| C1・TC1 | 100 pF (101、C0G)・トリマ 50 pF | 6-3 と同じ |
| C2・C3・C4 | 10 nF (103) | IN_B のバイパスと、音声の結合 |
| C5・C9 | 47 nF (473) | 音声の低域フィルタと、出力の発振止め |
| C6・C7・C13 | 10 µF の電解 | 利得 200 倍・BYPASS・U1 の電源 |
| C8・C10 | 220 µF・100 µF の電解 | 出力の結合・U2 の電源 |
| C11・C12 | 100 nF (104) | 電源のパスコン |
| R1 | 10 Ω | 出力の発振止め |
| J1・J2・J3 | 端面 SMA・3.5 mm ジャックの DIP 化キット・USB-C の変換基板 | アンテナ・ヘッドホン (32 Ω)・電源 5 V |
| R2・R3 | 5.1 kΩ・51 Ω | 試験の減衰器 (基板の外) |

## LTspice での確かめ

デッキは `sim/06-vxo-ac.cir` (発振周波数)・`sim/06-vxo-tran.cir` (発振の立ち上がり)、算術は `sim/06-vxo.py`。

| 確かめること | 本文の数字 | LTspice / 算術の値 | 判定 |
| --- | --- | --- | --- |
| f<sub>s</sub>・L<sub>m</sub>・Q | 7,027,189 Hz・25.65 mH・5.7 万 | 7,027,189.1 Hz・25.6476 mH・56,621 (算術) | 合う |
| L1 = 47 µH の上下の端 | 7.0255 MHz・7.0200 MHz | 7,025,488 Hz・7,019,987 Hz (AC 解析)、7,025,489 Hz・7,019,988 Hz (算術) | 合う |
| L1 無し・22 µH の幅 | 2.2 kHz・3.2 kHz | 2,153 Hz・3,166 Hz (AC 解析) | 合う |
| L1 = 68 µH の幅・L1 の 1 % の感度 | 10.2 kHz・−442 Hz、47 µH は −147 Hz | 10,232 Hz・−442 Hz・−147 Hz (算術) | 合う (算術だけ) |
| L1 を 27 回 (40.1 µH) にしたとき | 下の端 7.0219 MHz、幅 4.6 kHz | 7,021,942 Hz、4,649 Hz (算術) | 合う (算術だけ) |
| C<sub>m</sub> 10 fF・25 fF のときの幅 | 2.8 kHz・6.9 kHz | 2,758 Hz・6,867 Hz (算術) | 合う (算術だけ) |
| 発振が始まるか (L1 の Q を 80、直列 26 Ω と見積り) | 始まる | 損失は 35〜42 Ω (AC 解析の電流の山から)、負性抵抗は −238 Ω (エミッタ電流 0.12 mA の見積り)。過渡解析は VC1 = 10・100・260 pF とも 2 ms で立ち上がる | 合う (模型) |

- AC 解析は、水晶・L1・VC1・C<sub>A</sub>・C<sub>B</sub> を 1 周の直列回路にして、電流が最大になる周波数を読んだ (発振周波数は、この周のリアクタンスの和が 0 になる所)
- 過渡解析の SA612 は**一般的な小信号 NPN で代用**した。内部の定数は公開の模型が無く、バイアス (ベース約 3.7 V、エミッタに 25 kΩ) も見積り。
  模型の OSC_B の振幅 1.6〜2.1 Vpp は信用しない。確かめたのは「損失より負性抵抗が大きく、発振が始まる」ことだけ
- 過渡解析から周波数は読んでいない (刻み 2 ns の台形積分は共振を約 0.06 % 低く見せる)
- 確かめていない物: 実物の水晶の定数、L1 の実際の値と Q、浮遊容量、温度での動き、局発の漏れ、受信の感度

## 出典

自作。SA612 の内蔵発振を水晶のコルピッツで使う形と、水晶にコイルと可変容量を直列に入れて引っぱる VXO は、アマチュア無線の自作で広く使われる定番の回路。
水晶の定数の範囲 (C<sub>0</sub>・直列抵抗の上限・負荷容量) は [Abracon ABL シリーズ (HC-49 水晶) のデータシート](https://www.abracon.com/Resonators/ABL.pdf)、
LM386 は [TI LM386 データシート](https://www.ti.com/lit/ds/symlink/lm386.pdf) による。
7.03 MHz の HC-49/U の水晶は [サトー電気の水晶の一覧](https://sato-electric.cocotte.jp/l.html) に載っている (2026-11 に確認)。

参考: [水晶振動子 (Wikipedia)](https://ja.wikipedia.org/wiki/水晶振動子)、[Crystal oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Crystal_oscillator)、
[コルピッツ発振回路 (Wikipedia)](https://ja.wikipedia.org/wiki/コルピッツ発振回路)、[NE612 (Wikipedia)](https://en.wikipedia.org/wiki/NE612)、[バリコン (Wikipedia)](https://ja.wikipedia.org/wiki/バリコン)
