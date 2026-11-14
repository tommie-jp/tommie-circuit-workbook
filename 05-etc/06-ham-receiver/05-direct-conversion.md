---
book: etc
chapter: 6
id: 6-5
title: ダイレクトコンバージョン受信機 — SA612 と Si5351 と LM386 で 7 MHz の CW を聞く
tier: 300
source: 自作 (SA612 と LM386 を差動でつなぐ形は G3RJV の Sudden 受信機などの定番による)
board: [PF, BB]
---

# 6-5 ダイレクトコンバージョン受信機 — SA612 と Si5351 と LM386 で 7 MHz の CW を聞く

[6-3](03-input-tuning.md) の同調回路と [6-4](04-audio-lm386.md) の音声段の間にミキサーの SA612 を置き、
局部発振 (局発) を Si5351A モジュールと Raspberry Pi Pico 2 で作ると、7 MHz 帯の CW (モールス) が聞こえる受信機になる。
IC は 2 個、同調の調整は 1 か所で、この章の最初の 1 台にする。

**ダイレクトコンバージョン** (直接変換) は、信号のすぐ脇の周波数の局発を混ぜて、**差の周波数をそのまま音にする**受信の方式。
7.0107 MHz の CW の局に 7.0100 MHz の局発を掛けると、差の 700 Hz が音になって出てくる。中間周波も検波器も要らない。
掛け算で和と差ができることは [01-circuits/09-rf/12-balanced-mixer.md](../../01-circuits/09-rf/12-balanced-mixer.md)、
同じ方式をスイッチで組んだ例は [01-circuits/14-iq/05-tayloe-detector.md](../../01-circuits/14-iq/05-tayloe-detector.md) にある。

- **局発は信号の 700 Hz 下か上に置く。** 局発を動かすと音の高さが変わり、局発と信号が重なると音は 0 Hz になって消える (ゼロビート)
- **弱点は、局発の上下が同じ音になること。** 7.0100 MHz の局発に対して、7.0107 MHz の局も 7.0093 MHz の局も同じ 700 Hz で聞こえる (下の「LTspice での確かめ」)。
  混んでいるバンドでは混信が 2 倍になる。これを水晶フィルタで片側だけにするのが [6-10](10-cw-superhet.md)
- **選択度は音声段が受け持つ。** 7 MHz の同調回路の幅は約 1.3 MHz (6-3) で、局を分けているのは 6-4 の 214 Hz〜1.70 kHz の帯域

この題の流れは次のとおり。

- 回路図は 2 枚。受信部 (図1) と局発 (図2)
- 受信部はユニバーサル基板 (図3)、局発は Pico 2 とモジュールをブレッドボード (図4) に組み、短い同軸でつなぐ
- Si5351A の周波数の決め方とプログラム (C / C++ と MicroPython)
- Analog Discovery 3 (AD3) の 7.0107 MHz を入れて 700 Hz が出るのを見てから (図5)、アンテナをつないで聞く

> [!NOTE]
> 受信だけなので免許は要らない。局発の 7 MHz は SA612 の入力から同調回路を逆にたどってアンテナへ少し漏れる。
> SA612 は平衡ミキサーで漏れは小さいが、局発の線を長く引き回さず、J2 までは同軸でつなぐ。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 受信部 (同調回路・SA612・LM386)
parts:
  J1: sma 2,9 mirror ANT
  GJ1: ground 2,10
  TEST: port 3.5,6.5
  R4: resistor 3.5,6.5 3.5,8.5 5k1
  VR1: potentiometer 5,9 5,11
  GVR: ground 5,11
  T1: transformer 8,10
  GT1: ground 7,11.5
  C1: capacitor 10,9 10,11 100p
  TC1: capacitor-var 12.5,9 12.5,11 50p
  U1: ic 18.5,9.5 SA612
  C2: capacitor 14,11 14,12.5 10n
  GC2: ground 14,12.5
  GU1: ground 18.5,12
  V5: vcc 14.5,4.5 5V
  R1: resistor 14.5,5.5 16.5,5.5 100
  C5: ecap 17,5.5 17,7 10u
  GC5: ground 17,7
  C4: capacitor 20,5.5 20,7 100n
  GC4: ground 20,7
  J2: sma 2,15 mirror LO
  GJ2: ground 2,16
  R2: resistor 3.5,15 5.5,15 1k
  R3: resistor 6,15 6,17 100
  GR3: ground 6,17
  C3: capacitor 7,15 9,15 1n
  C7: capacitor 22.5,8 22.5,11 47n
  C8: capacitor 23.5,8 25,8 10n
  C9: capacitor 23.5,11 25,11 10n
  U2: ic 29,9.5 LM386
  V5: vcc 28.5,3.5 5V
  C12: ecap 26,4.5 26,6 100u
  GC12: ground 26,6
  C13: capacitor 23,4.5 23,6 100n
  GC13: ground 23,6
  C10: ecap 32,6 32,7 10u
  C11: ecap 30.5,12 30.5,13.5 10u
  GC11: ground 30.5,13.5
  GU2: ground 29,13.5
  C15: ecap 32.5,9.5 34,9.5 220u
  R5: resistor 34.5,9.5 34.5,11 10
  C14: capacitor 34.5,11 34.5,12.5 47n
  GC14: ground 34.5,12.5
  J3:
    type: device
    model: AE-PHONE-JACK-DIP
    at: 38.5,9
    pins: [R, L, GND]
  GJ3: ground 36.6,12.5
wires:
  - J1.1 -- 3.5,9 -- 5,9
  - J1.2 -- 2,10
  - 3.5,8.5 -- 3.5,9
  - VR1.w -| T1.A1
  - T1.A2 -| 7,11.5
  - T1.B2 -| 10,11
  - 10,11 -- 12.5,11 -- 14,11 -- 15.2,11
  - T1.B1 -| 10,9
  - 10,9 -- 12.5,9 -- 15,9
  - U1.IN_A -| 15,9
  - U1.IN_B -| 15.2,11
  - U1.GND |- 18.5,12
  - 14.5,4.5 -- 14.5,5.5
  - 16.5,5.5 -- 17,5.5 -- 18.5,5.5 -- 20,5.5
  - U1.VCC |- 18.5,5.5
  - J2.1 -- 3.5,15
  - J2.2 -- 2,16
  - 5.5,15 -- 6,15 -- 7,15
  - 9,15 -- 16.6,15
  - U1.OSC_B -| 16.6,15
  - U1.OUT_A -| 21,8
  - 21,8 -- 22.5,8 -- 23.5,8
  - U1.OUT_B -| 21,11
  - 21,11 -- 22.5,11 -- 23.5,11
  - 25,8 -- 26.5,8
  - U2.+INPUT -| 26.5,8
  - 25,11 -- 26.5,11
  - U2.-INPUT -| 26.5,11
  - U2.VS |- 28.5,4.5
  - 28.5,3.5 -- 28.5,4.5
  - 28.5,4.5 -- 26,4.5 -- 23,4.5
  - U2.GAIN1 |- 32,6
  - U2.GAIN8 |- 32,7
  - U2.BYPASS |- 30.5,12
  - U2.GND |- 29,13.5
  - U2.VOUT -| 32.5,9.5
  - 34,9.5 -- 34.5,9.5
  - 34.5,9.5 -- 36,9.5
  - 36,9.5 |- J3.R
  - 36,9.5 |- J3.L
  - J3.GND -| 36.6,12.5
notes:
  - text 3.5,5.8 small blue: 試験の入口 (AD3 の W1)
  - text 2,13.8 small blue left: Si5351 の CLK0 から (約 3 Vpp の方形波)
  - text 13,16 small blue: OSC_B で約 0.3 Vpp
  - text 9,7.8 small: リンク 4回・2次 32回
  - text 39,7.6 small blue: ヘッドホン 32 Ω
  - text 3.6,11.3 small: 1 kΩ (B)
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/05-direct-conversion-1.svg)

- **入力**: アンテナは J1 から。VR1 (1 kΩ、Ω はオーム) は高周波の音量調整で、摺動子から T1 のリンク (4 回) へ入れる。
  音声段の利得は固定なので、強い局で音が割れるときはここで絞る。T1・C1・TC1 は 6-3 の同調回路そのもの
- **SA612 の入力**: T1 の 2 次 (32 回) を IN_A と IN_B の間に入れ、IN_B を C2 (10 nF) で GND に落とす。
  IN_A と IN_B は IC の中で約 1.4 V に吊られている。2 次の片側を GND に直結すると、このバイアスを巻線が短絡してしまう
- **局発の入口**: J2 に Si5351A の方形波 (約 3.3 Vpp) を入れ、R2 (1 kΩ) と R3 (100 Ω) で 0.30 Vpp (基本波は 0.38 Vpp) に落として C3 (1 nF) で OSC_B へ。
  SA612 が外からの局発に求める大きさは 200〜300 mVpp (データシート)。OSC_E は開けておく
- **出力**: OUT_A と OUT_B の差動を、6-4 と同じ C7 (47 nF)・C8・C9 (10 nF) で LM386 の 2 つの入力へ渡す。LM386 の周りも 6-4 と同じ
- **電源**: 5 V。SA612 へは R1 (100 Ω) と C5 (10 µF、µ はマイクロ)・C4 で分けて入れる。
  LM386 の出力電流で電源が揺れ、それが SA612 に戻ると「ポコポコ」と低い音で発振する (モーターボーティング)。R1 と C5 で 160 Hz より上の揺れを止める
- **R4 (5.1 kΩ) と TEST** は試験の入口。「計器の設定」で使う。聞くときは何もつながない

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 局発 (Pico 2 が I2C で Si5351A を設定する)
parts:
  U3: pico2 3,11 mirror
  M1:
    type: device
    at: 12,9
    model: ADAFRUIT-2045
    label: Si5351A
    pins: [VIN, SDA, SCL, GND, CLK0]
  V3V3: vcc 1,8 3.3V
  V3V3: vcc 9,7.4 3.3V
  SW1: button 7.5,14.6 9,14.6
  SW2: button 7.5,16 9,16
  G1: ground 9.5,17.5
  J5: sma 16,11.5 LO
  G2: ground 16,12.5
wires:
  - U3.3V3 -| 1,8
  - M1.VIN -| 9,7.4
  - U3.GP4 -| 6,8.6
  - M1.SDA -| 6,8.6
  - U3.GP5 -| 7,9
  - M1.SCL -| 7,9
  - U3.GND8 -| 9.5,10.2
  - M1.GND -| 9.5,10.2
  - 9.5,10.2 -- 9.5,14.6 -- 9.5,16 -- 9.5,17.5
  - U3.GP14 -| 7.5,14.6
  - U3.GP15 -| 6.5,16
  - 6.5,16 -- 7.5,16
  - 9,14.6 -- 9.5,14.6
  - 9,16 -- 9.5,16
  - M1.CLK0 -| 10.2,11.5
  - 10.2,11.5 -- J5.1
  - J5.2 -- 16,12.5
notes:
  - text 15.5,10.5 small blue: 短い同軸で図1 の J2 へ
  - text 8.2,13.9 small blue: UP
  - text 8.2,16.8 small blue: DOWN
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/05-direct-conversion-2.svg)

- Si5351A モジュールは 3 本の出力を持つクロック発生器で、Pico 2 から I2C (2 本の線で IC を設定する通信) で周波数を書く。使うのは CLK0 だけ
- **I2C0** の SDA が GP4 (PIN 6)、SCL が GP5 (PIN 7)。モジュールは 3.3 V で動かす (Pico 2 の 3V3、PIN 36)。プルアップ抵抗はモジュールに載っている
- SW1 (UP、GP14)・SW2 (DOWN、GP15) は周波数を動かすボタン。Pico 2 の内蔵プルアップを使い、押すと L
- 01-circuits の [9-16](../../01-circuits/09-rf/16-dds-sdr-module.md) の DDS (AD9833) でも同じことができる。Si5351A を選んだのは、
  [6-10](10-cw-superhet.md) で 2 本めの出力 (CLK1) が要るのと、第 7 章の送信機でも同じモジュールを使うため

## Si5351A の周波数の決め方

Si5351A は、水晶 (モジュールでは 25 MHz) を **PLL** で 600〜900 MHz に上げ、それを**分周**して出力にする (データシート)。

f<sub>VCO</sub> = 25 MHz × (a + b ÷ c)　　f<sub>out</sub> = f<sub>VCO</sub> ÷ d

- **出力の分周 d は偶数の整数 120 に固定する。** 7.000〜7.450 MHz なら f<sub>VCO</sub> は 840〜894 MHz で範囲に収まる。分周を整数にすると出力の揺れ (ジッタ) が小さい
- **周波数は PLL の側の分数 a + b ÷ c で動かす。** c = 1,000,000 に固定すると、b の 1 は f<sub>VCO</sub> の 25 Hz、出力の **約 0.21 Hz** にあたる
- 7.0100 MHz なら f<sub>VCO</sub> = 841.2 MHz、841.2 ÷ 25 = 33.648 なので **a = 33、b = 648,000**。100 Hz 動かすには b を 480 動かす
- IC に書くのは a・b・c そのものではなく、P1 = 128a + ⌊128b ÷ c⌋ − 512、P2 = 128b − c × ⌊128b ÷ c⌋、P3 = c の 3 つ (AN619)。
  PLL A はレジスタ 26〜33、CLK0 の分周はレジスタ 42〜49 に、同じ並び (P3 の中位・下位、P1 の上位・中位・下位、P3 と P2 の上位、P2 の中位・下位) で 8 バイトを書く
- **周波数を動かすときは PLL A の 8 バイトだけを書き直す。** PLL のリセット (レジスタ 177) は起動のときの 1 回だけにする。毎回リセットすると、出力が一瞬止まって音に「プツッ」と入る

## 実体配線図

受信部は 7 MHz を扱うので、ユニバーサル基板に短い配線で組む (ユニバーサル基板の範囲は 10 MHz 以下。ブレッドボードは 3 MHz 以下)。
基板は **5×7 cm を横置き** (24 列 × 18 行、1.6 mm の FR-4、左右の縁に銅箔)。番地は基板の刷りどおりで、英字が列 (左から A〜X)、数字が行 (下から 1〜18)。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図3 受信部をユニバーサル基板に組む (部品面から見た図)
unused: [J4.D+, J4.D-, U1.OSC_E, J3.3]
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  TEST: b13
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge a17 018 016
  J4: usb-c/female b5 c5 d5 e5
  R4: resistor b13 b10 5k1
  VR1: potentiometer/knob c10 c9 c8 1k
  T1: transformer/toroid f11 f8 i11 i9 T37-2 4t:32t
  C1: capacitor/ceramic j11 j9 100p
  TC1: capacitor/trimmer k11 k9 50p
  U1: dip8 m13 SA612
  C2: capacitor/ceramic m8 o8 10n
  R1: resistor e14 h14 100
  C5: capacitor/electrolytic i13 i15 10u
  C4: capacitor/ceramic k13 k15 100n
  R2: resistor b17 e17 1k
  R3: resistor e16 b16 100
  C3: capacitor/ceramic f17 i17 1n
  C7: capacitor/ceramic q10 q13 47n
  C8: capacitor/ceramic r10 r13 10n
  C9: capacitor/ceramic r15 t15 10n
  U2: dip8 w10 r180 LM386
  C10: capacitor/electrolytic x13 x10 10u
  C11: capacitor/electrolytic v9 v8 10u
  C12: capacitor/electrolytic p7 p6 100u
  C13: capacitor/ceramic r7 r6 100n
  C15: capacitor/electrolytic t5 t4 220u
  R5: resistor s4 p4 10
  C14: capacitor/ceramic o4 o6 47n
  J3: sip4 u2 AE-PHONE-JACK-DIP blue
wires:
  - b5 -- b6 black
  - a6 -- b6 black
  - b6 -- o6 black
  - o6 -- p6 black
  - p6 -- r6 black
  - r6 -- u6 black
  - u6 -- v6 black
  - v6 -- x6 black
  - a6 -- a8 black
  - a8 -- a9 black
  - 09 -- a9 black
  - 011 -- a11 black
  - a11 -- a15 black
  - a15 -- a16 black
  - 016 -- a16 black
  - b16 -- a16 black
  - a15 -- i15 black
  - i15 -- k15 black
  - a8 -- c8 black
  - c8 -- f8 black
  - o6 -- o8 black
  - o8 -- s8 black
  - o10 -- o8 black
  - s8 -- s13 black
  - s13 -- t13 black
  - v8 -- v6 black
  - v2 -- v6 black
  - e5 -- e7 red
  - e7 -- p7 red
  - p7 -- r7 red
  - r7 -- u7 red
  - u7 -- u10 red
  - e7 -- e14 red
  - h14 -- h13 orange
  - h13 -- i13 orange
  - i13 -- k13 orange
  - k13 -- m13 orange
  - a10 -- b10 white
  - b10 -- c10 white
  - c9 -- d9 white
  - d9 -- d11 white
  - d11 -- f11 white
  - i11 -- j11 yellow
  - j11 -- k11 yellow
  - k11 -- l11 yellow
  - l11 -- l10 yellow
  - l10 -- m10 yellow
  - i9 -- j9 white
  - j9 -- k9 white
  - k9 -- m9 white
  - m9 -- n9 white
  - m9 -- m8 white
  - n9 -- n10 white
  - a17 -- b17 green
  - e16 -- e17 green
  - e17 -- f17 green
  - i17 -- o17 green
  - o17 -- o13 green
  - p10 -- q10 blue
  - q10 -- r10 blue
  - r13 -- r14 blue
  - r14 -- u14 blue
  - u14 -- u13 blue
  - p13 -- q13 purple
  - q13 -- q15 purple
  - q15 -- r15 purple
  - t15 -- v15 purple
  - v15 -- v13 purple
  - w13 -- x13 white
  - w10 -- x10 white
  - v10 -- v9 white
  - t10 -- t9 pink
  - t9 -- t5 pink
  - s4 -- t4 pink
  - t4 -- t1 pink
  - t1 -- u1 pink
  - u1 -- u2 pink
  - u1 -- x1 pink
  - x1 -- x2 pink
  - p4 -- o4 white
notes:
  - mark b13 yellow
  - text b14 red large bold right: W1
  - mark x6 yellow
  - text x5 red large bold center: GND
  - mark s4 yellow
  - text r5 red large bold center: 1+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/perfboard/05-direct-conversion.svg)

- **左の縁に入口が 2 つ**: 上の J2 が局発、下の J1 がアンテナ (どちらも端面実装の SMA)。信号は左から右へ流れ、右下の J3 (3.5 mm ジャック) から音が出る
- **電源は左下の USB-C (J4)**。赤い線が 5 V で、7 行を右へ走って LM386 (U2) の 6 番へ、E 列を上って R1 から SA612 (U1) の 8 番へ行く。
  黒い線が GND で、6 行と 8 行と左端の A 列。8 行は T1 の輪の下をくぐらせず、F8 で止めて、右の側は O 列で 6 行から上げる。D+ と D− は使わない
- **線が跨ぐ所は 6 つ** (弧で描いた所)。E 列の 5 V が GND (6 行・8 行) とアンテナ側の線 (11 行) を、O 列の GND が 5 V (7 行) を、T 列の音声出力が 5 V (7 行) と GND (6 行) を跨ぐ。
  どれも直流か低いインピーダンスの線どうしで、同調回路の熱い側 (黄色) は跨がせていない。被覆線で渡す
- **T1** は F〜I 列。リンクが F11・F8、2 次が I11 (IN_A の側)・I9 (IN_B の側)。**TC1** (K11・K9) はトリマコンデンサ。ピンの間隔が 5 mm なので 1 穴空けて挿す
- **U2 (LM386) は 180° 回して挿す** (切り欠きが右)。1 番が右上の W13 で、出力 (5 番) と電源 (6 番) が下の列に来て、電源の線と J3 に近くなる
- **J3** は秋月のジャックの DIP 化キットで、U〜X 列の 2 行に挿し、基板の右下の角から外へ張り出す。L と R を 1 行の線で結び、両耳に同じ音を出す
- **黄色の丸は AD3 を挟む穴**。`W1` (B13、R4 の先)・`1+` (S4、音声出力)・`GND` (X6)。測るときだけ挟む
- U1 の上 (L〜P 列の 14〜16 行) は空けてある。[6-6](06-vxo.md) で水晶の VXO の部品を足す場所

局発の側は、ブレッドボードを通るのが I2C (100 kHz) と 3.3 V とボタンだけなので、half のブレッドボードでよい。

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図4 局発をブレッドボードに組む (I2C と 3.3 V だけ)
board: half
parts:
  U3: pico2 @ h2
  SW1: button @ e23
  SW2: button @ e26
  M1:
    type: device
    at: bottom
    model: ADAFRUIT-2045
    label: Si5351A モジュール
    pins: [SDA, SCL, GND, VIN, CLK0]
  RX:
    type: device
    at: bottom
    label: 受信部の J2 (SMA)
    pins: [LO, GND]
wires:
  - a6 -- +t6 red
  - a4 -- -t4 black
  - j9 -- -b9 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
  - M1.SDA -- j7 yellow
  - M1.SCL -- j8 green
  - M1.GND -- -b11 black
  - M1.VIN -- +b13 red
  - M1.CLK0 -- RX.LO orange
  - RX.GND -- -b19 black
  - j20 -- j23 white
  - i21 -- i26 blue
  - a25 -- -t25 black
  - a28 -- -t28 black
notes:
  - text c24 small: UP
  - text c27 small: DOWN
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/breadboard/05-direct-conversion.svg)

- U3 (Pico 2) は h2 に挿す。3V3 (PIN 36、6 列) を上の + レールへ、GND (4 列・9 列) を − レールへ。右端で上下のレールを渡す
- M1 (Si5351A モジュール) はブレッドボードの外に置き、SDA → j7 (GP4)、SCL → j8 (GP5)、VIN → + レール、GND → − レール。
  図のピンの並びは線が交わらない順で、実物の並びは基板の印字で確かめる
- **CLK0 はブレッドボードに挿さない。** モジュールの SMA (または CLK0 と GND のピン) から、10 cm ほどの同軸で受信部の J2 へ直接つなぐ (図の橙の線)。
  7 MHz がブレッドボードを通らないので、ブレッドボードの範囲 (3 MHz 以下) に収まる。2 枚の基板の GND は、この同軸の外皮でつながる
- SW1 (UP) は j20 (GP14)、SW2 (DOWN) は i21 (GP15) から。反対側のピンは上の − レールへ

## 計器の設定

### プログラム

C / C++ (Pico SDK) が第 1、MicroPython が第 2。どちらも起動すると **7.0100 MHz** を出し、SW1・SW2 を押している間、0.1 秒ごとに 100 Hz ずつ動かす。
1 秒押し続けると刻みが 1 kHz に上がる。範囲は 7.000〜7.450 MHz (上は試し受信に使う短波放送の帯)。周波数は USB のシリアルに Hz で出る。
C 版はシリアルから `u`・`d` を送ると 10 kHz ずつ動く。

**C/C++ (Pico SDK)**。`lo7mhz.c`。ビルドの手順は 9-16 と同じで、`CMakeLists.txt` のライブラリを `pico_stdlib hardware_i2c` にする。

```c
#include <stdio.h>
#include <stdint.h>
#include "pico/stdlib.h"
#include "hardware/i2c.h"

#define SI5351   0x60          // I2C のアドレス
#define XTAL     25000000u     // モジュールの水晶
#define DIV      120u          // 出力の分周 (偶数の整数に固定)
#define PLL_C    1000000u      // 分数の分母 c
#define F_MIN    7000000
#define F_MAX    7450000
#define PIN_SDA  4
#define PIN_SCL  5
#define PIN_UP   14
#define PIN_DOWN 15

static void reg_write(uint8_t reg, const uint8_t *data, size_t n) {
    uint8_t buf[9] = {reg};
    for (size_t i = 0; i < n; i++) buf[1 + i] = data[i];
    i2c_write_blocking(i2c0, SI5351, buf, n + 1, false);
}

static void reg1(uint8_t reg, uint8_t value) { reg_write(reg, &value, 1); }

// 分周比 a + b/c を P1・P2・P3 に直して、reg から 8 バイトに書く
static void write_divider(uint8_t reg, uint32_t a, uint32_t b, uint32_t c) {
    uint32_t fl = (uint32_t)((uint64_t)128 * b / c);
    uint32_t p1 = 128 * a + fl - 512, p2 = 128 * b - c * fl, p3 = c;
    uint8_t d[8] = {(uint8_t)(p3 >> 8), (uint8_t)p3, (uint8_t)((p1 >> 16) & 3), (uint8_t)(p1 >> 8), (uint8_t)p1,
                    (uint8_t)(((p3 >> 12) & 0xF0) | ((p2 >> 16) & 0x0F)), (uint8_t)(p2 >> 8), (uint8_t)p2};
    reg_write(reg, d, 8);
}

// PLL A だけを書き直す。戻り値は実際に出る周波数 (Hz)
static double set_freq(uint32_t f) {
    uint64_t vco = (uint64_t)f * DIV;                   // 7.01 MHz なら 841.2 MHz
    uint32_t a = (uint32_t)(vco / XTAL);
    uint32_t b = (uint32_t)(vco % XTAL) / (XTAL / PLL_C);
    write_divider(26, a, b, PLL_C);
    return (double)XTAL * (a + (double)b / PLL_C) / DIV;
}

static void si5351_init(uint32_t f) {
    reg1(3, 0xFF);                    // 出力を全部止める
    reg1(17, 0x80);                   // CLK1・CLK2 は電源を切る
    reg1(18, 0x80);
    reg1(183, 0xD2);                  // 水晶の負荷容量 10 pF
    write_divider(42, DIV, 0, 1);     // CLK0 の分周 = 120
    set_freq(f);
    reg1(16, 0x4C);                   // CLK0: PLL A・整数分周・2 mA
    reg1(177, 0xA0);                  // PLL のリセット (起動のときだけ)
    reg1(3, 0xFE);                    // CLK0 だけ出す
}

int main(void) {
    stdio_init_all();
    i2c_init(i2c0, 100 * 1000);
    gpio_set_function(PIN_SDA, GPIO_FUNC_I2C);
    gpio_set_function(PIN_SCL, GPIO_FUNC_I2C);
    for (uint pin = PIN_UP; pin <= PIN_DOWN; pin++) {
        gpio_init(pin);
        gpio_set_dir(pin, GPIO_IN);
        gpio_pull_up(pin);            // 押すと L
    }

    int32_t f = 7010000;
    int held = 0;                     // 押し続けている回数 (0.1 秒ごと)
    si5351_init((uint32_t)f);
    printf("%.1f\n", set_freq((uint32_t)f));
    while (true) {
        int dir = (gpio_get(PIN_UP) ? 0 : 1) - (gpio_get(PIN_DOWN) ? 0 : 1);
        int32_t step = dir * (held >= 10 ? 1000 : 100);
        held = dir ? held + 1 : 0;
        int c = getchar_timeout_us(0);
        if (c == 'u') step += 10000;
        if (c == 'd') step -= 10000;
        if (step) {
            f += step;
            if (f < F_MIN) f = F_MIN;
            if (f > F_MAX) f = F_MAX;
            printf("%.1f\n", set_freq((uint32_t)f));
        }
        sleep_ms(100);
    }
}
```

**MicroPython**。ボタンだけで動かす (シリアルからの入力は省いた)。

```python
from machine import Pin, I2C
import time

SI5351 = 0x60
XTAL = 25_000_000                 # モジュールの水晶
DIV = 120                         # 出力の分周 (偶数の整数に固定)
PLL_C = 1_000_000                 # 分数の分母 c
F_MIN, F_MAX = 7_000_000, 7_450_000

i2c = I2C(0, sda=Pin(4), scl=Pin(5), freq=100_000)
up = Pin(14, Pin.IN, Pin.PULL_UP)     # 押すと 0
down = Pin(15, Pin.IN, Pin.PULL_UP)

def reg1(reg, value):
    i2c.writeto_mem(SI5351, reg, bytes([value]))

def write_divider(reg, a, b, c):      # a + b/c を P1・P2・P3 に直して 8 バイトに書く
    fl = 128 * b // c
    p1, p2, p3 = 128 * a + fl - 512, 128 * b - c * fl, c
    i2c.writeto_mem(SI5351, reg, bytes([
        (p3 >> 8) & 0xFF, p3 & 0xFF, (p1 >> 16) & 3, (p1 >> 8) & 0xFF, p1 & 0xFF,
        ((p3 >> 12) & 0xF0) | ((p2 >> 16) & 0x0F), (p2 >> 8) & 0xFF, p2 & 0xFF]))

def set_freq(f):                      # PLL A だけを書き直す。実際に出る周波数を返す
    vco = f * DIV
    a = vco // XTAL
    b = (vco % XTAL) // (XTAL // PLL_C)
    write_divider(26, a, b, PLL_C)
    return XTAL * (a + b / PLL_C) / DIV

def si5351_init(f):
    reg1(3, 0xFF)                     # 出力を全部止める
    reg1(17, 0x80)                    # CLK1・CLK2 は電源を切る
    reg1(18, 0x80)
    reg1(183, 0xD2)                   # 水晶の負荷容量 10 pF
    write_divider(42, DIV, 0, 1)      # CLK0 の分周 = 120
    set_freq(f)
    reg1(16, 0x4C)                    # CLK0: PLL A・整数分周・2 mA
    reg1(177, 0xA0)                   # PLL のリセット (起動のときだけ)
    reg1(3, 0xFE)                     # CLK0 だけ出す

f = 7_010_000
held = 0
si5351_init(f)
print("%.1f" % set_freq(f))
while True:
    d = (1 - up.value()) - (1 - down.value())
    step = d * (1000 if held >= 10 else 100)
    held = held + 1 if d else 0
    if step:
        f = min(max(f + step, F_MIN), F_MAX)
        print("%.1f" % set_freq(f))
    time.sleep_ms(100)
```

**実機では動かしていない。** PC の模型で、書いたレジスタから逆算した周波数が表の値になることは確かめた (下の「プログラムでの確かめ」)。

### AD3 で 700 Hz を出す

アンテナをつなぐ前に、AD3 の信号発生器 (Wavegen) を「局」の代わりにする。

1. J1 に **50 Ω の終端** (VNA の校正キットの LOAD) をねじ込む。アンテナの代わりの 50 Ω になる
2. W1 を `W1` の穴 (R4 の先) に挟む。R4 (5.1 kΩ) と終端で約 −40 dB の減衰器になり、50 Ω の源に直した起電力は W1 の 1/108
3. Scope の 1+ を `1+` (J3 の L・R の線)、1− と GND を `GND` に挟む。J3 にはヘッドホンか 33 Ω の抵抗をつなぐ
4. 局発を 7.0100 MHz (起動したまま) にして、W1 を下の表に合わせる。VR1 は右いっぱい (最大)

| 項目 | 設定 | 理由 |
| --- | --- | --- |
| Wavegen W1 | Sine、**7.0107 MHz**、振幅 10 mV、オフセット 0 V | 局発の 700 Hz 上。起電力は 92.5 µV (振幅) |
| Scope の時間軸 | 500 µs/div | 700 Hz の 1 周期 (1.43 ms) が 3 目盛弱 |
| Scope CH1 | 100 mV/div、AC 結合 | 出力は約 0.50 Vpp |
| トリガ | CH1 の立ち上がり、0 V | — |
| Measurements | Peak-to-Peak、Frequency | 「見るべき値」の量 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 W1 が 7.0107 MHz・10 mV のときの音声出力 (CH1)。700 Hz・0.50 Vpp (計算)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 700Hz 0.252V, range: 100mV/div}
cursors: [0, 1.4286ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/scope/05-direct-conversion.svg)

- TC1 を回して振幅が最大になる所に合わせる (6-3 で VNA を使って合わせてあれば、ほぼそのまま)
- W1 を 7.0093 MHz (局発の 700 Hz 下) にしても同じ 700 Hz が出る。7.0100 MHz に重ねると音が消える (ゼロビート)
- AD3 と Si5351A の水晶は別々なので、音の高さは数十 Hz ずれることがある (両方の誤差を ±10 ppm と置くと 7 MHz で最大 ±140 Hz。見積り)

### アンテナをつないで聞く

終端と AD3 を外し、J1 に [6-2](02-wire-antenna.md) のワイヤアンテナをつなぐ。

- **まず短波放送で確かめる。** SW1 を押し続けて局発を 7.2〜7.45 MHz へ上げる。AM の放送局は搬送波を出し続けているので、
  近づくと「ピー」という音が聞こえ、局発を搬送波に重ねる (ゼロビート) と音声が聞こえる。少しずれると音声が濁る。これが聞こえれば受信機は動いている
- **CW は 7.000〜7.030 MHz。** 局発を 100 Hz ずつ動かして、「ピー、ピピ」という断続音が 700 Hz 前後になる所に合わせる
- 夜は強い放送局で音が割れる。VR1 を絞る

## 見るべき値

計算値。SA612 の変換利得は 17 dB (データシートの代表値。最小 14 dB)、音声段は 6-4 の 43.55 dB (700 Hz)。**実機では組んでいない (未測定)。**

| 測る所 | 期待する値 |
| --- | --- |
| シリアルの最初の表示 | 7010000.0 (Hz) |
| SW1 を 1 回 (0.1 秒) 押す | 7010100.0 |
| 周波数の分解能 | 0.21 Hz (25 MHz ÷ 1,000,000 ÷ 120) |
| J2 の局発 (AD3 の 2+ で見る) | 約 3.3 Vpp の方形波、7.0100 MHz |
| OSC_B の局発 | 0.30 Vpp (基本波は 0.38 Vpp) |
| U1 の 8 番の直流 | 約 4.76 V (2.4 mA × 100 Ω の降下) |
| W1 が 7.0107 MHz・10 mV のときの IN_A | 237 µV (振幅) |
| そのときの音声出力 (図5) | **700 Hz、0.50 Vpp** (振幅 252 mV) |
| W1 が 7.0093 MHz のとき | 同じ 700 Hz、同じ大きさ |
| W1 が 7.0150 MHz のとき | 5 kHz。音声段の帯域の外で、700 Hz のときより 13 dB ほど小さい (6-4 の 1.13 kHz の折れ点から) |

**感度の見積り。** 50 Ω の源の起電力から音声出力までの利得は、同調回路の昇圧 8.2 dB + 変換利得 17 dB + 音声段 43.55 dB = **68.7 dB (約 2,700 倍)**。
起電力 1 µV の局は出力で 2.7 mV になり、32 Ω のヘッドホンなら静かな部屋で聞こえる大きさ (見積り)。
7 MHz ではアンテナが拾う外からの雑音のほうが受信機の雑音より大きいので、感度はこれで足りる。足りないのは選択度のほう。

- 変換利得は IC の個体と局発の大きさで ±3 dB ほど動く。出力が 0.35〜0.7 Vpp なら合っている (目安)
- 局発が方形波なので、3 倍の 21.03 MHz 付近にも −9.5 dB の感度がある (計算)。同調回路がここを約 24 dB 落とす (6-3 の Q 5.4 の単同調。見積り)

### よくある不具合

| 症状 | 原因 | 直し方 |
| --- | --- | --- |
| どこに合わせても同じ放送が聞こえる | 強い中波・短波の放送が SA612 で直接検波されている | VR1 を絞る。TC1 を合わせ直す。アンテナを短くする |
| 「ブーン」というハム (局発を動かしても高さが変わらない) | 電源のリプルか、GND の回り込み | USB の電源をモバイルバッテリーにする。C8・C9 が 10 nF か確かめる (6-4) |
| 局に合わせたときだけ「ブーン」と濁る | 漏れた局発が電源の線で変調されて戻る (ダイレクトコンバージョンに特有) | アンテナを電源の線から離す。受信部を金属の箱に入れる |
| 「ジー」「ピロピロ」という雑音 | Pico 2 と USB のデジタル雑音 | Pico 2 を受信部とアンテナから離す。PC から外してバッテリーで動かす |
| 基板を叩くと「コン」と鳴る | 利得の大きい音声段に、部品の振動が電気になって入る (マイクロフォニック) | T1 と C1 を基板に固定する。配線を短く |
| 「ポコポコ」と低い音で発振 | 電源を通した帰還 (モーターボーティング) | R1・C5・C12 を確かめる。電池が減っていないか |
| 「サー」とは鳴るが局が聞こえない | 局発が来ていない | J2 の方形波を見る。シリアルの表示、モジュールの配線 |

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | SA612A (NE612・NE602 も同じ) | ミキサー。DIP 8 ピン。面実装品しか無ければ変換基板に載せる |
| U2 | LM386N-1 | 音声段。6-4 と同じ |
| U3 | Raspberry Pi Pico 2 | 局発の設定。USB から給電 |
| M1 | Si5351A モジュール (Adafruit 2045、25 MHz 水晶つき、I2C アドレス 0x60) | 7 ピンの並びは印字の左から 0 (CLK0)・1 (CLK1)・2 (CLK2)・SCL・SDA・GND・VIN (Adafruit の基板データで確かめた)。基板に 3.3 V のレギュレータと I2C のレベル変換があり、VIN は 3〜5 V なので Pico 2 の 3.3 V で動く (Adafruit の説明)。同じ並びの紫の互換基板 (CJMCU-5351) でもよい。秋月の AE-Si5351A-B は 8 ピンで並びが違い、電源も 3.3 V だけ |
| T1 | T37-2 に φ0.3 mm の UEW を 2 次 32 回・リンク 4 回 | 6-3 と同じ (約 4.1 µH) |
| C1 | 100 pF (C0G、記号 101) | 同調 |
| TC1 | トリマコンデンサ 最大 50 pF | 同調の合わせ込み。7.1 MHz で合計 約 123 pF |
| C2 | 10 nF (103) | IN_B を交流で GND へ |
| C3 | 1 nF (102) | 局発の結合 |
| C4・C13 | 100 nF (104) | 電源のパスコン |
| C5・C10・C11 | 10 µF 16 V (電解) | U1 の電源・LM386 の利得 (1 番が +)・BYPASS |
| C7 | 47 nF (473) | OUT_A-OUT_B 間。高い側を切る |
| C8・C9 | 10 nF (103) | 結合。低い側を切る |
| C12 | 100 µF 16 V (電解) | LM386 の電源 |
| C14 | 47 nF (473) | Zobel |
| C15 | 220 µF 10 V (電解) | 出力の直流を切る |
| R1 | 100 Ω | SA612 の電源を分ける |
| R2・R3 | 1 kΩ・100 Ω | 局発の減衰 |
| R4 | 5.1 kΩ | 試験の入口。50 Ω の終端と組んで約 −40 dB |
| R5 | 10 Ω | Zobel |
| VR1 | 1 kΩ (B カーブ) | 高周波の音量調整 |
| SW1・SW2 | タクトスイッチ | UP・DOWN |
| J1・J2 | SMA コネクタ (メス、端面実装) | アンテナ・局発 |
| J3 | 3.5 mm ステレオミニジャック DIP 化キット (秋月 AE-PHONE-JACK-DIP) | 32 Ω のヘッドホン |
| J4 | USB-C の電源取り出し基板 | 5 V。CC に 5.1 kΩ を内蔵した品 |
| 終端 | SMA の 50 Ω | 試験のときだけ J1 に付ける |
| 電源 | 5 V | 既定の電源。局発の側は Pico 2 の 3.3 V |

- 章の標準の減衰器 (5.1 kΩ + 51 Ω) の 51 Ω を、J1 に付ける 50 Ω の終端で兼ねた。基板に 51 Ω を付けたままにすると、聞くときにアンテナの信号を半分捨てる
- Zobel (R5・C14) は、基板の配線の都合で出力のコンデンサ C15 の後ろに付けた (6-4 は前)。220 µF は高い周波数では短絡と同じなので、働きは変わらない

## LTspice での確かめ

この題は **SPICE の対象外**: SA612 と Si5351A の模型が無い。同調回路は 6-3、音声段は 6-4 で LTspice にかけてあるので、
ここでは残りの数を算術 (Python) と、理想の乗算器 (方形波の局発 × 正弦の信号) で確かめた。`sim/05-direct-conversion.py`。

| 確かめること | 本文の数字 | 算術の値 | 判定 |
| --- | --- | --- | --- |
| 7.0100 MHz の a・b と出る周波数 | a = 33、b = 648,000、7010000.0 Hz | 同じ (P1 = 3794、P2 = 944000) | 合う |
| 分解能、100 Hz の b | 0.21 Hz、480 | 0.2083 Hz、480 | 合う |
| 7.000〜7.450 MHz の f<sub>VCO</sub> | 840〜894 MHz | 840.0〜894.0 MHz | 合う |
| 局発の減衰 | 0.30 Vpp、基本波 0.38 Vpp | 0.300 Vpp、0.382 Vpp | 合う |
| 試験の起電力と IN_A | 92.5 µV、237 µV | 92.5 µV、237 µV | 合う |
| 音声出力 | 0.50 Vpp (振幅 252 mV) | 252 mV | 合う |
| 局発の 700 Hz 上と下 | 同じ 700 Hz、同じ大きさ | 0.6366 と 0.6366 (理想の値 2/π、π はパイ) | 合う |
| 3 倍の高調波の感度 | −9.5 dB | −9.5 dB | 合う |
| 局発から 5 kHz 離れた信号 | 700 Hz には出ない | −100 dB 以下 | 合う |

確かめていない物: SA612 の実際の変換利得と雑音、局発の漏れ、Pico 2 の雑音、強い放送局による直接検波。どれも実物で聞いて決まる。

## プログラムでの確かめ

本文のプログラムを PC で動かし、I2C に書いたレジスタから周波数を逆算して表と突き合わせた (`npm run pico:test`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| I2C の設定 | 100 kHz、GP4 が SDA・GP5 が SCL、宛先 0x60 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |
| 起動のときに出る周波数 | 7010000.0 Hz (PLL A と CLK0 の分周のレジスタから逆算)。CLK0 だけが出て、分周は 120 | 同上 |
| SW1 を押し続ける | 0.1 秒ごとに +100 Hz を 10 回、そのあとは +1 kHz | 同上 |
| SW2 を押し続ける | 7.000 MHz で止まる (下の端) | 同上 |
| シリアルの `u`・`d` (C 版) | +10 kHz・−10 kHz | C: Pico SDK のモック |
| PLL のリセット | 起動のときの 1 回だけ | C: Pico SDK のモック |

見ていない物: Si5351A の実際の出力 (波形・大きさ・ジッタ)、ボタンのチャタリング、I2C の応答が無いときの動き

## 出典

自作。SA612 の差動の出力を LM386 の 2 つの入力へ直接つなぐ形は、G3RJV の Sudden 受信機をはじめ広く使われている定番による (図と値は描き直した)。
Si5351A の PLL と分周の範囲は [Skyworks Si5351A/B/C のデータシート](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/data-sheets/Si5351-B.pdf)、
P1・P2・P3 の式とレジスタの番号は [AN619 (Si5351 のレジスタの手引き)](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/application-notes/AN619.pdf)、
モジュールのピンは [Adafruit Si5351A Clock Generator Breakout の説明](https://learn.adafruit.com/adafruit-si5351-clock-generator-breakout)、
LM386 は [TI LM386 のデータシート](https://www.ti.com/lit/ds/symlink/lm386.pdf)、
Pico 2 のピンは [Raspberry Pi Pico 2 のデータシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf)、
MicroPython の I2C は [machine.I2C のドキュメント](https://docs.micropython.org/en/latest/library/machine.I2C.html) による。
SA612A の変換利得・入出力の抵抗・局発の大きさは NXP の SA612A のデータシート (公式の URL が移動したので、型番で検索する)。
方式の解説は [ダイレクトコンバージョン受信機 (Wikipedia)](https://ja.wikipedia.org/wiki/ダイレクトコンバージョン受信機)。
