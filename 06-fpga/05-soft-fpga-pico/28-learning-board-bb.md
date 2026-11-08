---
book: fpga
chapter: 5
id: 5-28
title: 学習ボードをブレッドボードで組む — 7 セグ 4 桁・LED 8 個・スイッチ 8 個
tier: 200
source: 自作 (入出力の並びは Digilent Basys 3 を参考にした)
board: BB
device: PICO
---

# 5-28 学習ボードをブレッドボードで組む — 7 セグ 4 桁・LED 8 個・スイッチ 8 個

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は lint を通し、Pico 2 のプログラムは `.uf2` までビルドした。
> 主ループは PC に移し、74HC595 の 2 段を真似て確かめた (「シミュレーションでの確かめ」)。
> 電流・明るさ・SPI の波形は計算値と見込みで、測った値ではない。

FPGA の学習ボード (Digilent Basys 3 など) には、スイッチ・LED・押しボタン・7 セグが載っていて、Verilog を書いたらすぐ手で試せる。
Pico 2 の Soft-FPGA にも同じ物を用意する。この題ではブレッドボードで組んで全部の入出力を確かめ、次の 5-29 でユニバーサル基板に移す。

| 入出力 | 数 | つなぎ方 | GPIO |
| --- | --- | --- | --- |
| LED | 8 | 直結 (330 Ω) | GP2〜GP9 |
| スライドスイッチ | 4 | GND との間。内蔵プルアップ | GP10〜GP13 |
| 押しボタン | 4 | GND との間。内蔵プルアップ | GP14〜GP17 |
| 7 セグ 4 桁 | 1 | 74HC595 2 段 (3 本) | GP18〜GP20 |
| USB シリアル | — | Pico 2 の USB (5-14) | 配線なし |

全部を直結すると 12 + 8 + 4 + 4 = 28 本で、Pico 2 の GPIO (26 本) に入らない。そこで 7 セグだけを 74HC595 の後ろに隠す。
Verilog の側は `seg` と `dig` の 12 本のままで、シフトレジスタを知らない (5-3 の「Verilog はピンの番号を知らない」と同じ)。
スイッチのプルダウンは使わない (RP2350-E9。5-3)。

## 回路図

図1 が Pico 2 と直結の入出力、図2 が 7 セグの駆動。同じ名前の端子どうしがつながっている。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 に LED 8 個を直に、スライドスイッチと押しボタンを GND との間に
parts:
  U1: pico2 6,6 mirror
  R7: resistor 9.6,6.8 9.6,8.2 330
  D7: led 9.6,8.2 9.6,9.6
  GL7: ground 9.6,9.6
  R6: resistor 10.8,6.4 10.8,7.8 330
  D6: led 10.8,7.8 10.8,9.2
  GL6: ground 10.8,9.2
  R5: resistor 12,6 12,7.4 330
  D5: led 12,7.4 12,8.8
  GL5: ground 12,8.8
  R4: resistor 13.2,5.6 13.2,7 330
  D4: led 13.2,7 13.2,8.4
  GL4: ground 13.2,8.4
  R3: resistor 14.4,4.8 14.4,6.2 330
  D3: led 14.4,6.2 14.4,7.6
  GL3: ground 14.4,7.6
  R2: resistor 15.6,4.4 15.6,5.8 330
  D2: led 15.6,5.8 15.6,7.2
  GL2: ground 15.6,7.2
  R1: resistor 16.8,4 16.8,5.4 330
  D1: led 16.8,5.4 16.8,6.8
  GL1: ground 16.8,6.8
  R0: resistor 18,3.6 18,5 330
  D0: led 18,5 18,6.4
  GL0: ground 18,6.4
  SW0: port 8.6,7.6
  SW1: port 8.6,8
  SW2: port 8.6,8.4
  SW3: port 8.6,8.8
  BTN0: port 8.6,9.6
  BTN1: port 8.6,10
  BTN2: port 3.4,10
  BTN3: port 3.4,9.6
  SRCLK: port 3.4,8.8
  SER: port 3.4,8.4
  RCLK: port 3.4,8
  V0: vcc 2.2,2.6 3.3V
  G0: ground 1.4,11
  SW0: port 2,12.6
  S0: slide-switch 2,13.6 r90
  GS0: ground 2.25,15
  SW1: port 4,12.6
  S1: slide-switch 4,13.6 r90
  GS1: ground 4.25,15
  SW2: port 6,12.6
  S2: slide-switch 6,13.6 r90
  GS2: ground 6.25,15
  SW3: port 8,12.6
  S3: slide-switch 8,13.6 r90
  GS3: ground 8.25,15
  BTN0: port 11,12.6
  B0: button 11,12.6 11,14.4
  GB0: ground 11,14.4
  BTN1: port 13,12.6
  B1: button 13,12.6 13,14.4
  GB1: ground 13,14.4
  BTN2: port 15,12.6
  B2: button 15,12.6 15,14.4
  GB2: ground 15,14.4
  BTN3: port 17,12.6
  B3: button 17,12.6 17,14.4
  GB3: ground 17,14.4
wires:
  - U1.GP9 -- 9.6,6.8
  - U1.GP8 -- 10.8,6.4
  - U1.GP7 -- 12,6
  - U1.GP6 -- 13.2,5.6
  - U1.GP5 -- 14.4,4.8
  - U1.GP4 -- 15.6,4.4
  - U1.GP3 -- 16.8,4
  - U1.GP2 -- 18,3.6
  - U1.GP10 -- 8.6,7.6
  - U1.GP11 -- 8.6,8
  - U1.GP12 -- 8.6,8.4
  - U1.GP13 -- 8.6,8.8
  - U1.GP14 -- 8.6,9.6
  - U1.GP15 -- 8.6,10
  - U1.GP16 -- 3.4,10
  - U1.GP17 -- 3.4,9.6
  - U1.GP18 -- 3.4,8.8
  - U1.GP19 -- 3.4,8.4
  - U1.GP20 -- 3.4,8
  - U1.3V3 -| 2.2,2.6
  - U1.GND28 -| 1.4,11
  - 2,12.6 -- S0.in
  - S0.1 |- 2.25,15
  - 4,12.6 -- S1.in
  - S1.1 |- 4.25,15
  - 6,12.6 -- S2.in
  - S2.1 |- 6.25,15
  - 8,12.6 -- S3.in
  - S3.1 |- 8.25,15
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/28-learning-board-bb-1.svg)

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 74HC595 を 2 段につなぐ。1 段めの出力で桁を選び、2 段めの出力でセグメントを光らせる
parts:
  SER: port 3.4,4.5
  SRCLK: port 3.4,5
  RCLK: port 3.4,5.5
  U3: ic 7,5 74HC595
  V3: vcc 7,1.8 3.3V
  G3: ground 7,8.4
  DRV1: port 10.4,3.5
  DRV2: port 10.4,4
  DRV3: port 10.4,4.5
  DRV4: port 10.4,5
  SER2: port 10.4,7
  SER2: port 3.4,12.5
  SRCLK: port 3.4,13
  RCLK: port 3.4,13.5
  U2: ic 7,13 74HC595
  V2: vcc 7,9.8 3.3V
  G2: ground 7,16.4
  SG: port 10.4,11
  SC: port 10.4,11.5
  SDP: port 10.4,12
  SD: port 10.4,12.5
  SE: port 10.4,13
  SA: port 10.4,13.5
  SF: port 10.4,14
  SB: port 10.4,14.5
  DS1: seg7x4 18.2,8.1 OSL40562-LR
  SA: port 12.4,1.6
  Ra: resistor 12.4,1.6 13.8,1.6 220
  SB: port 12.4,2.6
  Rb: resistor 12.4,2.6 13.8,2.6 220
  SC: port 12.4,3.6
  Rc: resistor 12.4,3.6 13.8,3.6 220
  SD: port 12.4,4.6
  Rd: resistor 12.4,4.6 13.8,4.6 220
  SE: port 12.4,5.6
  Re: resistor 12.4,5.6 13.8,5.6 220
  SF: port 12.4,6.6
  Rf: resistor 12.4,6.6 13.8,6.6 220
  SG: port 12.4,7.6
  Rg: resistor 12.4,7.6 13.8,7.6 220
  SDP: port 12.4,8.6
  Rdp: resistor 12.4,8.6 13.8,8.6 220
  DIG1: port 15,9.3
  DIG2: port 15,9.7
  DIG3: port 15,10.1
  DIG4: port 15,10.5
  DRV1: port 11.5,14.4
  RB1: resistor 11.5,14.4 12.8,14.4 1k
  Q1: npn 13.4,14.4 2SC1815
  DIG1: port 13.4,13
  GQ1: ground 13.4,15.8
  DRV2: port 15.3,14.4
  RB2: resistor 15.3,14.4 16.6,14.4 1k
  Q2: npn 17.2,14.4 2SC1815
  DIG2: port 17.2,13
  GQ2: ground 17.2,15.8
  DRV3: port 19.1,14.4
  RB3: resistor 19.1,14.4 20.4,14.4 1k
  Q3: npn 21,14.4 2SC1815
  DIG3: port 21,13
  GQ3: ground 21,15.8
  DRV4: port 22.9,14.4
  RB4: resistor 22.9,14.4 24.2,14.4 1k
  Q4: npn 24.8,14.4 2SC1815
  DIG4: port 24.8,13
  GQ4: ground 24.8,15.8
  AD:
    type: device
    at: 2,18.6
    label: AD3
    pins: [DIO0, DIO1, DIO2, GND]
    turn: mirror
  SRCLK: port 4.6,18.2
  SER: port 4.6,18.6
  RCLK: port 4.6,19
  GA: ground 4.6,20
wires:
  - U3.SER |- 3.4,4.5
  - U3.SRCLK |- 3.4,5
  - U3.RCLK |- 3.4,5.5
  - U3.VCC |- 7,1.8
  - U3.SRCLR |- 7.5,1.8
  - 7,1.8 -- 7.5,1.8
  - U3.GND |- 7,8.4
  - U3.OE |- 7.5,8
  - 7.5,8 -- 7,8
  - U3.QB |- 10.4,3.5
  - U3.QC |- 10.4,4
  - U3.QD |- 10.4,4.5
  - U3.QE |- 10.4,5
  - U3.QH' |- 10.4,7
  - U2.SER |- 3.4,12.5
  - U2.SRCLK |- 3.4,13
  - U2.RCLK |- 3.4,13.5
  - U2.VCC |- 7,9.8
  - U2.SRCLR |- 7.5,9.8
  - 7,9.8 -- 7.5,9.8
  - U2.GND |- 7,16.4
  - U2.OE |- 7.5,16
  - 7.5,16 -- 7,16
  - U2.QA |- 10.4,11
  - U2.QB |- 10.4,11.5
  - U2.QC |- 10.4,12
  - U2.QD |- 10.4,12.5
  - U2.QE |- 10.4,13
  - U2.QF |- 10.4,13.5
  - U2.QG |- 10.4,14
  - U2.QH |- 10.4,14.5
  - 13.8,1.6 -- 15.8,1.6 -- 15.8,6.1 -- DS1.a
  - 13.8,2.6 -- 15.6,2.6 -- 15.6,6.5 -- DS1.b
  - 13.8,3.6 -- 15.4,3.6 -- 15.4,6.9 -- DS1.c
  - 13.8,4.6 -- 15.2,4.6 -- 15.2,7.3 -- DS1.d
  - 13.8,5.6 -- 15,5.6 -- 15,7.7 -- DS1.e
  - 13.8,6.6 -- 14.8,6.6 -- 14.8,8.1 -- DS1.f
  - 13.8,7.6 -- 14.6,7.6 -- 14.6,8.5 -- DS1.g
  - 13.8,8.6 -- 14.4,8.6 -- 14.4,8.9 -- DS1.dp
  - DS1.DIG1 -- 15,9.3
  - DS1.DIG2 -- 15,9.7
  - DS1.DIG3 -- 15,10.1
  - DS1.DIG4 -- 15,10.5
  - 12.8,14.4 -- Q1.B
  - 13.4,13 -- Q1.C
  - Q1.E -- 13.4,15.8
  - 16.6,14.4 -- Q2.B
  - 17.2,13 -- Q2.C
  - Q2.E -- 17.2,15.8
  - 20.4,14.4 -- Q3.B
  - 21,13 -- Q3.C
  - Q3.E -- 21,15.8
  - 24.2,14.4 -- Q4.B
  - 24.8,13 -- Q4.C
  - Q4.E -- 24.8,15.8
  - AD.DIO0 -- 4.6,18.2
  - AD.DIO1 -- 4.6,18.6
  - AD.DIO2 -- 4.6,19
  - AD.GND -| 4.6,20
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/28-learning-board-bb-2.svg)

- `SER` → U3 → `SER2` → U2 の順につなぐ。先に送った 8 ビットが U3 を通り抜けて U2 に残る
- U2 の 8 本は 220 Ω (オーム) を通してセグメントへ。出力とセグメントの対応は、次の実体配線図で線が交わりにくい順にした (表1)
- U3 の QB〜QE は 1 kΩ を通して 2SC1815 のベースへ。トランジスタが桁の共通のカソードを GND へ落とす (2-15 と同じ)
- 両方の 74HC595 の SRCLR は +3.3 V、OE は GND に固定する (7-18 と同じ)
- スライドスイッチは共通 (C) をピンに、1 番を GND につなぎ、2 番は開けておく。1 番の側へ倒すと ON

| 表1 | QA | QB | QC | QD | QE | QF | QG | QH |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| U2 (セグメント) | g | c | dp | d | e | a | f | b |
| U3 (桁) | — | DIG1 | DIG2 | DIG3 | DIG4 | — | — | — |

## 部品

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす。USB から給電 |
| U2・U3 | 74HC595 (16 ピン DIP) | 2 | 7 セグの駆動 |
| DS1 | OSL40562-LR (0.56 インチ 4 桁、カソード共通、赤) | 1 | 表示 |
| Q1〜Q4 | 2SC1815 (NPN) | 4 | 桁のカソードを GND へ落とす |
| D0〜D7 | 5 mm LED 赤 | 8 | `led[0]`〜`led[7]` |
| R0〜R7 | 330 Ω (E24)、1/4 W | 8 | LED の電流を決める |
| Ra〜Rg・Rdp | 220 Ω (E24)、1/4 W | 8 | セグメントの電流を決める |
| RB1〜RB4 | 1 kΩ (E24)、1/4 W | 4 | ベースの電流を決める |
| S0〜S3 | スライドスイッチ (3 ピン) | 4 | `sw[0]`〜`sw[3]` |
| B0〜B3 | タクトスイッチ 6 mm | 4 | `btn[0]`〜`btn[3]` |
| — | ブレッドボード (full、63 列) | 2 | |
| AD | Analog Discovery 3 | 1 | Logic で 3 本を測る |

- 電源は既定の 5 V でなく **3.3 V** (Pico 2 のピンに 5 V を入れない。0-3)。74HC595 の電源電圧の範囲は 2 V〜6 V
- LED の電流は (3.3 − 2.0) ÷ 330 ≈ 3.9 mA、8 個で 31 mA (計算値。順電圧を 2.0 V と置いた)
- セグメントの電流は (3.3 − 2.0) ÷ 220 ≈ 5.9 mA。1 桁で最大 47 mA がトランジスタに集まる。1 桁はデューティ 1/4 なので、1 セグメントの平均は約 1.5 mA (計算値)
- ベースの電流は (3.3 − 0.7) ÷ 1 k ≈ 2.6 mA。47 mA を流すのに要る電流増幅率は 18 で、2SC1815 の範囲に収まる (計算値)

## 実体配線図

ブレッドボード 2 枚に分ける。1 枚めが Pico 2 と直結の入出力、2 枚めが 7 セグの駆動で、基板の間の信号は `SER` `SRCLK` `RCLK` の 3 本と電源だけ。

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図3 ブレッドボード 2 枚に組む
board: full
sheets:
  - name: 入出力
    points:
      ser: b18
      srclk: a19
      rclk: a17
    parts:
      U1: pico2 @ h3
      B0: button @ e33
      B1: button @ e30
      B2: button @ e27
      B3: button @ e24
      S0: slide-switch c45(1) c46(C) c47(2)
      S1: slide-switch c42(1) c43(C) c44(2)
      S2: slide-switch c39(1) c40(C) c41(2)
      S3: slide-switch c36(1) c37(C) c38(2)
      R0: resistor e63 f63 330
      D0: led a63(A) -t63(K)
      R1: resistor e61 f61 330
      D1: led a61(A) -t61(K)
      R2: resistor e59 f59 330
      D2: led a59(A) -t59(K)
      R3: resistor e57 f57 330
      D3: led a57(A) -t57(K)
      R4: resistor e55 f55 330
      D4: led a55(A) -t55(K)
      R5: resistor e53 f53 330
      D5: led a53(A) -t53(K)
      R6: resistor e51 f51 330
      D6: led a51(A) -t51(K)
      R7: resistor e49 f49 330
      D7: led a49(A) -t49(K)
    wires:
      - b7 -- +t7 red
      - a5 -- -t5 black
      - a35 -- -t35 black
      - a32 -- -t32 black
      - a29 -- -t29 black
      - a26 -- -t26 black
      - a21 -- g24 green [h40, v140]
      - b22 -- h27 green [h10, v140]
      - i22 -- i30 green
      - j21 -- j33 green
      - a45 -- -t45 black
      - f46 -- e46 blue
      - j16 -- j46 blue [v29, h600]
      - a42 -- -t42 black
      - f43 -- e43 blue
      - j17 -- j43 blue [v22, h520]
      - a39 -- -t39 black
      - f40 -- e40 blue
      - j18 -- j40 blue [v15, h440]
      - a36 -- -t36 black
      - f37 -- e37 blue
      - j19 -- j37 blue [v8, h360]
      - j6 -- j63 orange [v73, h1140]
      - j7 -- j61 yellow [v68, h1080]
      - j8 -- j59 orange [v63, h1020]
      - j9 -- j57 yellow [v58, h960]
      - j11 -- j55 orange [v53, h880]
      - j12 -- j53 yellow [v48, h820]
      - j13 -- j51 orange [v43, h760]
      - j14 -- j49 yellow [v38, h700]
  - name: 7セグ
    points:
      ser2: d4
      rclk2: c6
      srclk2: b7
    parts:
      U3: dip16 @ e2 74HC595
      U2: dip16 @ e12 r180 74HC595
      DS1: seg7x4 @ c39
      Rc: resistor e26 f26 220 cap=above:-0.8,0
      Rdp: resistor e27 f27 220 cap=below:-0.8,0
      Rd: resistor e28 f28 220 cap=above:0.8,0
      Re: resistor e29 f29 220 cap=below:0.8,0
      Rg: resistor i18 i22 220
      Ra: resistor a35 a40 220 cap=above
      Rf: resistor b36 b41 220 cap=below
      Rb: resistor b44 b48 220 cap=above
      Q4: transistor d52(B) d53(C) d54(E) 
      RB4: resistor e52 f52 1k cap=below:0.3,0
      Q3: transistor d55(B) d56(C) d57(E) 
      RB3: resistor e55 f55 1k cap=below:0.3,0
      Q2: transistor d58(B) d59(C) d60(E) 
      RB2: resistor e58 f58 1k cap=below:0.3,0
      Q1: transistor d61(B) d62(C) d63(E) 
      RB1: resistor e61 f61 1k cap=below:0.3,0
      AD:
        type: device
        at: top
        label: AD3 Logic
        pins: [DIO1, DIO2, DIO0, GND]
    wires:
      - a2 -- +t2 red
      - a8 -- +t8 red
      - a5 -- -t5 black
      - j9 -- -b9 black
      - a12 -- -t12 black
      - j13 -- +b13 red
      - j19 -- +b19 red
      - j16 -- -b16 black
      - c7 -- g14 brown [h60, v110, h20]
      - d6 -- h15 gray [h100, v110, h60]
      - b9 -- i17 purple [h50, v170, h110]
      - d19 -- d26 yellow [h140]
      - c18 -- c27 yellow [h180]
      - b17 -- b28 yellow [h220]
      - a16 -- a29 yellow [h260]
      - i29 -- i39 yellow
      - j28 -- j40 yellow
      - j27 -- j41 yellow [v12]
      - j26 -- j42 yellow [v20]
      - j22 -- j43 yellow [v28]
      - a15 -- b35 orange [v-62, h400]
      - a14 -- a36 orange [v-68, h440]
      - a13 -- a48 orange [v-74, h700]
      - a54 -- -t54 black
      - a57 -- -t57 black
      - a60 -- -t60 black
      - a63 -- -t63 black
      - e53 -- f53 white
      - j53 -- j44 white [v12]
      - a56 -- a43 white [v-42, h-260]
      - a59 -- a42 white [v-48, h-340]
      - a62 -- a39 white [v-54, h-460]
      - j5 -- j52 green [v62, h940]
      - j4 -- j55 green [v68, h1020]
      - j3 -- j58 green [v74, h1100]
      - j2 -- j61 green [v80, h1180]
      - AD.DIO1 -- a4 green
      - AD.DIO2 -- a6 green
      - AD.DIO0 -- a7 green
      - AD.GND -- -t10 black
links:
  - 入出力.ser 7セグ.ser2 purple
  - 入出力.srclk 7セグ.srclk2 brown
  - 入出力.rclk 7セグ.rclk2 gray
  - 入出力.+t 7セグ.+t 7セグ.+b
  - 入出力.-t 7セグ.-t 7セグ.-b
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/28-learning-board-bb.svg)

- 1 枚め: Pico 2 は USB を左に向けて `@ h3` に挿す。下の列の GP2〜GP13 は板の下を回して右へ、入れ子にして線を交えない
- LED は a 行から − レールへ挿し、抵抗は同じ列で溝をまたぐ。左から `led[7]`〜`led[0]` で、数の読みと同じ並び
- スライドスイッチの共通 (C) は、下の段から青い短い線で溝を渡して受ける
- 押しボタンは上の側を GND、下の側を信号にする。GP16・GP17 だけ Pico 2 の上の列にあるので、Pico 2 の右端を回して下の段へ渡す
- 2 枚め: 左の U3 が 1 段め、右の U2 が 2 段め。橙の線はセグメント a・f・b で、板の上を回して 7 セグの上の列へ入る
- 2 枚めの下のレールは図の左の線で上のレールとつなぐ
- 全体の電流は約 80 mA (計算値)、信号は最速で 1 MHz。ブレッドボードの範囲 (3 MHz 以下) に収まる

## Verilog

`board_test.v` (この題で書く物) と、`seg7_decoder.v` (1-8) の 2 つ。

```verilog
// board_test.v: 学習ボードの入出力を全部確かめる
//   LED      : 下 4 個がスライドスイッチ、上 4 個が押しボタンをそのまま写す
//   7 セグ   : k 桁めに BTNk を押した回数 (16 進 0〜F)。点 (dp) は SWk
module board_test (
    input  wire       clk,       // 1 kHz (5-7 のタイマ)
    input  wire       rst,
    input  wire [3:0] sw,        // 1 = ON
    input  wire [3:0] btn,       // 1 = 押している
    output wire [7:0] led,       // 1 で点灯
    output wire [7:0] seg,       // {dp, g, f, e, d, c, b, a}。1 で点灯
    output wire [3:0] dig,       // 1 の桁だけ光る。dig[3] が左端
    output reg [15:0] cnt        // 4 桁の回数 {BTN3, BTN2, BTN1, BTN0}
);
    // 4 ビットのカウンタ。下 2 ビットが光らせる桁、16 クロック (16 ms) に 1 回ボタンを見る
    reg  [3:0] div;
    reg  [3:0] btn_q;            // 前に見たボタン
    wire       smp   = (div == 4'd15);
    wire [3:0] press = smp ? (btn & ~btn_q) : 4'b0000;

    always @(posedge clk)
        if (rst) begin
            div   <= 4'd0;
            btn_q <= 4'b0000;
            cnt   <= 16'h0000;
        end else begin
            div <= div + 4'd1;
            if (smp) btn_q <= btn;
            if (press[0]) cnt[3:0]   <= cnt[3:0]   + 4'd1;
            if (press[1]) cnt[7:4]   <= cnt[7:4]   + 4'd1;
            if (press[2]) cnt[11:8]  <= cnt[11:8]  + 4'd1;
            if (press[3]) cnt[15:12] <= cnt[15:12] + 4'd1;
        end

    // 光らせる桁 pos の回数を 7 セグの形に直す (1-8)
    wire [1:0] pos = div[1:0];
    wire [3:0] shown = cnt[{pos, 2'b00} +: 4];
    wire [6:0] abc;
    seg7_decoder dec (.d(shown), .seg(abc));

    assign seg = {sw[pos], abc};
    assign dig = 4'b0001 << pos;
    assign led = {btn, sw};
endmodule
```

- `led` はスイッチとボタンをそのまま写す。配線の確かめがいちばん簡単な出力
- `div` の下 2 ビットが光らせる桁。1 クロック (1 ms) ごとに次の桁へ進み、4 ms で 1 周する
- ボタンは 16 クロック (16 ms) に 1 回だけ見る。接点の跳ねが 16 ms より短ければ、1 回の押しを 1 回と数える
- `cnt` は試験で見る出口で、ピンには出さない

lint は警告なし (Verilator 5.048)。

```bash
#!/bin/sh
# verilate.sh: Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc
verilator --cc --no-timing --no-trace -Wall --top-module board_test --prefix Vboard_test --Mdir v_board_test board_test.v seg7_decoder.v
```

## Pico 2 のプログラム

ビルドは [5-1 の「ファイル」と「ビルドする」](01-verilator-on-pico.md#ファイル)のとおり。`CMakeLists.txt` の最後の行を次の 2 行に替える。

```cmake
add_soft_fpga(board528 board528.cpp board_test)
target_link_libraries(board528 hardware_spi)
```

`board528.cpp`:

```cpp
// 5-28 学習ボード — board_test.v を 1 kHz で回し、7 セグは 74HC595 2 個に SPI で送る
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "Vboard_test.h"

constexpr int64_t HALF_US = 500;     // 半周期 500 µs → クロック 1 kHz (5-7)
constexpr uint LED0  = 2;            // GP2〜GP9  = led[0]〜led[7]
constexpr uint SW0   = 10;           // GP10〜GP13 = sw[0]〜sw[3]   (ON で L)
constexpr uint BTN0  = 14;           // GP14〜GP17 = btn[0]〜btn[3] (押すと L)
constexpr uint SRCLK = 18;           // SPI0 の SCK → 74HC595 の SRCLK
constexpr uint SER   = 19;           // SPI0 の TX  → 74HC595 の SER
constexpr uint RCLK  = 20;           // 普通の GPIO → 74HC595 の RCLK
constexpr uint32_t LED_MASK = 0xFFu << LED0;

// U2 の出力 QA〜QH の何番めに、セグメント a b c d e f g dp をつないだか (線が交わりにくい順)
constexpr uint SEG_Q[8] = {5, 7, 1, 3, 4, 6, 0, 2};
// U3 の出力の何番めに、dig[0]〜dig[3] をつないだか (QE QD QC QB)
constexpr uint DIG_Q[4] = {4, 3, 2, 1};

static Vboard_test top;
static unsigned g_clk = 0;

// 1. 読む: 8 本の入力は ON・押すで L。反転して 1 にする
static void read_inputs() {
    uint32_t in = ~gpio_get_all();
    top.sw  = (in >> SW0)  & 0xFu;
    top.btn = (in >> BTN0) & 0xFu;
}

// 3. 書く: LED は直に、7 セグは 16 ビットを 74HC595 へ送ってから RCLK で写す
static void write_outputs() {
    gpio_put_masked(LED_MASK, (uint32_t)top.led << LED0);
    uint32_t seg_byte = 0, dig_byte = 0;
    for (int i = 0; i < 8; i++) if ((top.seg >> i) & 1u) seg_byte |= 1u << SEG_Q[i];
    for (int i = 0; i < 4; i++) if ((top.dig >> i) & 1u) dig_byte |= 1u << DIG_Q[i];
    uint16_t word = (uint16_t)((seg_byte << 8) | dig_byte);  // 先に送る上の 8 ビットは U3 を通り抜けて U2 に残る
    spi_write16_blocking(spi0, &word, 1);                    // 1 MHz で 16 µs。送り終わるまで戻らない
    gpio_put(RCLK, 1);
    busy_wait_us_32(1);                                      // RCLK の H を 1 µs 保つ
    gpio_put(RCLK, 0);
}

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;
    if (g_clk) read_inputs();        // 立ち上がりの前に入力を読む
    top.clk = g_clk;
    top.eval();                      // 2. eval
    if (g_clk) write_outputs();
    return true;
}

int main() {
    gpio_init_mask(LED_MASK);
    gpio_set_dir_out_masked(LED_MASK);
    for (uint p = SW0; p < BTN0 + 4; p++) {     // GP10〜GP17 は入力。内蔵プルアップ (プルダウンは使わない。5-3)
        gpio_init(p);
        gpio_set_dir(p, GPIO_IN);
        gpio_pull_up(p);
    }
    gpio_init(RCLK);
    gpio_set_dir(RCLK, GPIO_OUT);

    spi_init(spi0, 1000 * 1000);                                  // 1 MHz
    spi_set_format(spi0, 16, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);   // 16 ビットを 1 語で
    gpio_set_function(SRCLK, GPIO_FUNC_SPI);
    gpio_set_function(SER, GPIO_FUNC_SPI);

    top.rst = 1;                     // 1 クロックだけリセット
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    top.rst = 0;

    repeating_timer_t timer;
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);
    while (true) tight_loop_contents();
}
```

5-1 の手順でビルドし、`build/board528.uf2` は 97 280 バイト、text 52 280・bss 2 456 バイト (Verilator 5.048、Pico SDK 2.2.0)。**実機では動かしていない。**

- クロックは 5-7 のタイマで 1 kHz に固定する。割り込みの中で「読む → eval → 書く」を回す
- 16 ビットを 1 語にして送る (`spi_set_format` の 16)。8 ビットを 2 回送ると語の間に隙間ができる
- SPI のモード 0 は、SRCLK の立ち上がりで 74HC595 が SER を読む形にちょうど合う
- 1 MHz で 16 µs (マイクロ秒)。1 クロックの 1 ms に対して 2 % 足らずで、1 kHz の固定には響かない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 = SRCLK、DIO1 = SER、DIO2 = RCLK を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 2.5 µs/div。標本化 10 MS/s (SRCLK の 1 周期に 10 標本) |
| トリガ | DIO0 (SRCLK) の立ち上がり。トリガの前を 2 µs 見せる |

## Logic に見えるはずの画面

リセットの直後、スイッチもボタンも触っていないとき、右端の桁 (`dig[0]`) に `0` を出す 1 語。`seg` = 0x3F を表1 で並べ替えると U2 へ 0xFA、`dig` = 0001 は U3 へ 0x10 なので、語は 0xFA10。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 16 ビットの語 0xFA10 を送り、RCLK で出力に写す
device: ad3
time: 2.5us/div
start: -2us
sample: 10MHz
signals:
  SRCLK: dio0 edges -2us=0 0.5us=1 1us=0 1.5us=1 2us=0 2.5us=1 3us=0 3.5us=1 4us=0 4.5us=1 5us=0 5.5us=1 6us=0 6.5us=1 7us=0 7.5us=1 8us=0 8.5us=1 9us=0 9.5us=1 10us=0 10.5us=1 11us=0 11.5us=1 12us=0 12.5us=1 13us=0 13.5us=1 14us=0 14.5us=1 15us=0 15.5us=1 16us=0
  SER: dio1 edges -2us=0 0s=1 5us=0 6us=1 7us=0 11us=1 12us=0
  RCLK: dio2 edges -2us=0 17us=1 18us=0
cursors: [0.5us, 15.5us]
trigger: SRCLK rising at 0.5us
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/28-learning-board-bb.svg)

- SRCLK は 1 µs の周期で 16 回。カーソルの間の 15 µs が、立ち上がり 16 回ぶんの間隔
- SER は SRCLK の立ち上がりの所で読む。先頭から 1111 1010 0001 0000 = 0xFA10
- RCLK が H になった瞬間に 16 ビットが出力へ写る。送っている間は前の表示のまま
- 送り終わりから RCLK までの間隔は、SPI の FIFO が空になるのを待つ時間で決まる。図は 1 µs と置いた見込み (RCLK の H の幅 1 µs は `busy_wait_us_32(1)` の値)。測って書く

## 見るべき値

シミュレーションの値と計算値。実機では測っていない。

| 見る所 | 値 | 実機 (測って書く) |
| --- | --- | --- |
| 電源を入れた直後の 7 セグ | `0000`、点なし | |
| スイッチ SWk を ON | `led[k]` が点き、k 桁めの点が点く | |
| ボタン BTNk を押している間 | `led[4+k]` が点く | |
| ボタン BTNk を 1 回押す | k 桁めの数が 1 増える (16 進、F の次は 0) | |
| 桁の切り替え | 1 ms ごと、4 ms で 1 周 (250 Hz) | |
| SRCLK の周期 | 1 µs (1 MHz) | |
| 1 語を送る時間 | 16 µs | |
| 1 語の周期 (RCLK の間隔) | 1 ms | |

動かないときは、基板 1 枚ずつ切り分ける。

1. **1 枚めだけ**: スイッチとボタンで LED が点けば、Pico 2 と 1 枚めは動いている
2. **SPI の線**: AD3 の Logic で図4 の形が出ているかを見る。出ていなければ 1 枚めのピンか links の線
3. **2 枚め**: U3 の QB〜QE と U2 の QA〜QH を AD3 で見る。形があるのに光らなければ、抵抗より先

## シミュレーションでの確かめ

本文の `board528.cpp` を PC の替え玉の GPIO (`sim/pcstub/`) で動かし、74HC595 の 2 段を真似て、RCLK の立ち上がりごとに光っている桁の形を読んだ (`sim/28-learning-board.v`・`sim/28-learning-board-pc.cpp`)。`.uf2` は本文の Docker イメージでビルドした。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`) | 警告なし | 警告 0 件 (Verilator 5.042・5.048) | 合った |
| BTN3 を 10 回 | 左端の桁が A | 0x77 (A) | 合った |
| BTN1 を 3 回 | 3 | 0x4F (3) | 合った |
| 跳ねる押し方 (L・H・L・H・L) を BTN2 に 15 回、見る時刻とのずれを 16 通り | 15 回と数える (F) | 0xF1 (点つきの F) | 合った |
| SW0・SW2 を ON | 右端と右から 3 桁めの点が点く | 0x86・0xF1 に点の bit | 合った |
| LED (SW0・SW2 ON、BTN0 を押したまま) | 0x15 | 0x15 | 合った |
| SPI の語の数 | 1 ms に 1 語 | 3 055 ms で 3 055 語 | 合った |
| 2 桁が同時に光る語 | 0 | 0 | 合った |
| 桁の並び | 1 ms ごとに次の桁へ | 3 054 回とも次の桁 | 合った |
| 回路図 2 枚と実体配線図の部品のつながり | 一致 | 56 組とも一致 (AD3 を除く) | 合った |
| `.uf2` の大きさ | 97 280 バイト、text 52 280・bss 2 456 | 同じ | 合った |

確かめられなかったもの。

- 実機の動作、SPI の波形 (図4 の RCLK の時刻)、7 セグの明るさ、電流、接点の実際の跳ねの長さ

`npm run parity` は 1 枚の実体配線図と 1 枚の回路図で共通の部品だけを比べるので、回路図 2 枚を併せた突き合わせは別に行った (上の表の「部品のつながり」)。

## 出典

自作。入出力の並びは [Digilent Basys 3 の資料](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Basys-3_Datasheet_0525.pdf) の、スイッチの上に LED を置く形を参考にした。
74HC595 の機能・ピン・電圧の範囲は Texas Instruments [SN74HC595 データシート](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf)。
ダイナミック点灯は 2-15、SPI で 74HC595 を動かす話は 7-18、`seg7_decoder` は 1-8。
Pico 2 のピン番号は [Pico-2-Pinout.pdf](https://datasheets.raspberrypi.com/pico/Pico-2-Pinout.pdf)。SPI の呼び方は [raspberrypi/pico-sdk](https://github.com/raspberrypi/pico-sdk) の `hardware_spi`。
