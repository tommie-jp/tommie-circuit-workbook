---
book: etc
chapter: 6
id: 6-8
title: 再生式受信機 — 1 石の再生検波と LM386 で短波放送と CW を聞く
tier: 300
source: 自作
board: PF
---

# 6-8 再生式受信機 — 1 石の再生検波と LM386 で短波放送と CW を聞く

**再生式受信機**は、同調回路の損をトランジスタの正帰還で打ち消して、Q (共振の鋭さ) を何十倍にも上げる受信機だ。
[6-5 のダイレクトコンバージョン受信機](05-direct-conversion.md)はミキサーの IC とマイコンの局発を使ったが、
ここではトランジスタ 1 個 (2SC1815) が高周波増幅・検波・局発の 3 役をこなす。部品はいちばん少ないが、
つまみを 2 つ (同調と再生) 同時に合わせる癖がある。同調コイルは [6-3](03-input-tuning.md) と同じ T37-2 の 32 回、
音声段は [6-4](04-audio-lm386.md) の LM386 をそのまま使う (回路の説明は 6-4。ここでは図に描くだけ)。

この題の流れは次のとおり。

- 再生の原理と、発振の手前 (AM) と発振させた後 (CW・SSB) の聞き方の違い
- 回路図 (図1) と、再生が滑らかに掛かるようにした所
- ユニバーサル基板の実体配線図 (図2)
- Analog Discovery 3 (AD3) での試験 (図3〜図5) と、アンテナ端子へ漏れる発振の大きさ (図6)

> [!WARNING]
> **この受信機は、CW を聞く間は自分で 7 MHz を発振している。** 発振の一部は結合コンデンサ C1 を通ってアンテナへ漏れる。
> 免許の要らない微弱無線局の範囲は、322 MHz 以下なら距離 3 m で 500 µV/m (マイクロボルト毎メートル) 以下。
> 再生は発振の境目のすぐ上で止め、C1 を大きくしない (見積りは「計器の設定」の図6)。送信の話は第 7 章で扱う。

## 再生の原理

同調回路 (L1 と C2・C3・VC1) だけの Q は、アンテナをつないだ状態で約 135 (計算)。7.15 MHz での帯域は 53 kHz で、
5 kHz おきに並ぶ短波放送も、数百 Hz おきに並ぶ CW も分けられない。

トランジスタのベースを同調回路につなぎ、エミッタを C5 と C6 の分け目に戻すと (コルピッツ形)、同調回路から見て
**負の抵抗**が並列に入る。大きさはトランジスタの相互コンダクタンス g<sub>m</sub> (= コレクタ電流 ÷ 26 mV) に比例するので、
**電流を増やすほど損が打ち消され、Q が上がる**。損がちょうど 0 になる電流が発振の境目で、それを超えると自分で発振する。

| 再生の位置 | 起きること | 聞ける電波 |
| --- | --- | --- |
| 境目のずっと手前 | Q は元のまま。感度も選択度も低い | 強い放送だけ |
| 境目のすぐ手前 | Q が数千になり、帯域が数 kHz に狭まる。信号は同調回路で数十〜数百倍になる | AM (短波放送) |
| 境目のすぐ上 | 弱く発振する。発振と信号の周波数の差が音になる (ビート) | CW・SSB |
| 境目のずっと上 | 発振が強くなり、感度が落ちて漏れが増える | 使わない |

検波は同じトランジスタがする。ベース・エミッタ間の電圧と電流の関係が曲がっているので、高周波の振幅が変わると
コレクタ電流の平均が変わり、R3 に音声が出る。発振しているときは、発振そのものが局発になって信号と掛け合わさる
(6-5 のミキサーと局発を 1 石で兼ねた形)。

**よく似た名前の回路との違い。** [01-circuits 9-6 の超再生](../../01-circuits/09-rf/06-superregen-fm.md)は、発振を毎秒数万回
わざと止めては起こす回路で、帯域が広く FM 放送向き。CW のビートは聞けない。
[01-circuits 9-5 のレフレックス](../../01-circuits/09-rf/05-reflex-radio.md)は 1 石を高周波と低周波の増幅に 2 度使う回路で、
正帰還は掛けないので Q は上がらない。再生式は発振を**止めず**、境目の近くに**置き続ける**。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 再生式受信機 (2SC1815 の再生検波とLM386)
parts:
  J1: sma 1,11
  C1: capacitor 1.5,11 3,11 4.7p
  L1: inductor 3,12 3,14 4.1u
  C2: capacitor 5,12 5,14 62p
  C3: capacitor 7,11 7,13 22p
  VC1: capacitor-var 7,13 7,15 260p
  C4: capacitor 9.5,11 11.5,11 47p
  C5: capacitor 13,11 13,13 220p
  C6: capacitor 13,13 13,15 470p
  Q1: npn 14.5,11
  R1: resistor 12,6 12,8 100k
  R2: resistor 15.5,13 15.5,15 4.7k
  R3: resistor 14.5,5 14.5,7 22k
  R4: resistor 8.5,3 8.5,5 51k
  VR1: potentiometer 8.5,5 8.5,7
  R5: resistor 8.5,7 8.5,9 10k
  C8: ecap 10,6 10,8 10u
  C9: ecap 11,3 11,5 100u
  R6: resistor 15.5,3 17.5,3 220
  C7: capacitor 16,9 16,11 2.2n
  C10: capacitor 17.5,9 19.5,9 10n
  U1: ic 23,8.2 LM386
  C11: ecap 23,5 25,5 10u
  C12: ecap 24.5,11 24.5,13 10u
  C13: ecap 27,9 29,9 220u
  R7: resistor 27,9 27,11 10
  C14: capacitor 27,11 27,13 47n
  C16: capacitor 18.5,3 18.5,5 100n
  C15: ecap 21,3 21,5 100u
  J2: speaker 30.5,9 30.5,11
  V5: vcc 22.5,2 5V
  G1: ground 15.5,15
  G2: ground 8.5,9
  G3: ground 10,8
  G4: ground 11,5
  G5: ground 16,11
  G6: ground 18.5,5
  G7: ground 21,5
  G8: ground 23,12
  G9: ground 24.5,13
  G10: ground 27,13
  G11: ground 30.5,11
  G12: ground 20.4,8.2
wires:
  - J1.1 -- 1.5,11
  - 3,11 -- 9.5,11
  - 3,11 -- 3,12
  - 3,14 -- 3,15
  - 5,11 -- 5,12
  - 5,14 -- 5,15
  - J1.2 |- 3,15
  - 3,15 -- 15.5,15
  - 11.5,11 -- 12,11
  - 12,11 -- 13,11
  - 13,11 -- Q1.B
  - 12,8 -- 12,11
  - 13,13 -- 14.5,13
  - Q1.E -- 14.5,13
  - 14.5,13 -- 15.5,13
  - VR1.w -| 10,6
  - 10,6 -- 12,6
  - 8.5,3 -- 15.5,3
  - Q1.C -- 14.5,9
  - 14.5,9 -- 14.5,7
  - 14.5,5 -- 14.5,3
  - 14.5,9 -- 17.5,9
  - 19.5,9 -| U1.-INPUT
  - U1.+INPUT -| 20.4,8.2
  - 17.5,3 -- 22.5,3
  - 22.5,2 -- 22.5,3
  - U1.VS |- 22.5,3
  - U1.GAIN1 |- 23,5
  - 25,5 -- 25,5.75
  - 25,5.75 -| U1.GAIN8
  - U1.GND |- 23,12
  - U1.BYPASS |- 24.5,11
  - U1.VOUT -| 27,9
  - 29,9 -- 30.5,9
notes:
  - text 1,9.5 blue: アンテナ
  - text 30,8 blue: ヘッドホン
  - text 6.3,6 small: 10kΩ (B)
  - text 15,11.7 small: 2SC1815
  - text 1.2,15.8 blue: L1はT37-2に32回
  - text 8.3,14.5 blue: ポリバリコン
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/08-regenerative-1.svg)

- **同調回路**: L1 は T37-2 に φ0.3 mm の UEW を 32 回 (4.1 µH、6-3 の 2 次側と同じ。リンクは巻かない)。
  C2 (62 pF) と、C3 (22 pF) を直列にしたポリバリコン VC1 (260 pF) が並列に入る。C3 を直列にするのは、VC1 の変化 (約 5〜260 pF) を
  4〜20 pF に縮めて、つまみ 1 回転を約 6.9〜7.4 MHz (計算。配線の浮遊容量を 5 pF と置いた) に広げるため。
  7.0〜7.2 MHz のアマチュア帯と 7.2〜7.45 MHz の短波放送が入る
- **アンテナは C1 (4.7 pF) で軽く結ぶ**。7 MHz で 4.7 kΩ のリアクタンスなので、50 Ω のアンテナをつないでも同調回路の Q は
  ほとんど下がらず、発振の漏れも小さい。アンテナの長さや向きで同調がずれる量も減る
- **Q1 (2SC1815) はコルピッツ形**。同調回路 → C4 (47 pF) → ベース、ベース・エミッタ間に C5 (220 pF)、エミッタ・GND 間に C6 (470 pF)。
  C4 を小さくしたのは、帰還を弱めて、発振の境目をエミッタ電流 約 0.09 mA に置くため (C4 を省いてベースを直結すると、
  境目が数 µA になり、つまみの端で発振して調整できない)。2SC1815 を発振・検波に使う範囲 (27 MHz 以下) の内
- **再生のつまみ VR1 (10 kΩ B)** は、ベースの直流電圧 (R4 と R5 で挟んで 0.70〜1.40 V) を変えて、エミッタ電流を
  0.03〜0.16 mA の間で動かす。境目 (1.05 V) はつまみのほぼ中央に来る。C8 (10 µF) はつまみを回したときの雑音を落とす
- **R2 (4.7 kΩ) はバイパスしない**。発振が大きくなるとエミッタの平均電圧が上がって電流を絞るので、発振の振幅が
  つまみに沿って滑らかに増える (下の表)。R2 を大きなコンデンサでバイパスすると、発振が間欠になる (シミュレーションでも起きた)
- **検波出力**はコレクタ。C7 (2.2 nF) が 7 MHz を GND へ逃がし、R3 (22 kΩ) に音声が残る (C7 と R3 で約 3.3 kHz の低域)
- **R6 (220 Ω) と C9 (100 µF)** は検波段の電源を LM386 の電源から切り離す。LM386 の出力電流で 5 V が揺れると、
  それが VR1 を通ってベースに戻り、低い音で発振する (モーターボーティング)
- **音声段 U1 (LM386N-1)** は 6-4 と同じ利得 200 倍 (1-8 ピン間に C11 10 µF)。検波出力は片側なので、C10 (10 nF) で **−INPUT (2 ピン)** に入れ、
  **+INPUT (3 ピン) は GND** に落とす。入力抵抗 50 kΩ と C10 の折れ点は 318 Hz で、6-4 と同じ。−INPUT に入れるのは、
  DIP の 3 ピンが GND の 4 ピンの隣で、基板の上で線を交差させずに済むから (出力の位相は反転するが、耳には同じ)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
unused: [J3.D+, J3.D-]
title: 図2 ユニバーサル基板 (7×9 cm) に組む (部品面から見た図)
board:
  size: 9x7cm
  h: 1.6mm
  material: FR-4
  slots: on
parts:
  J1: sma/female-edge a12 011
  C1: capacitor/ceramic e12 g12 4.7p
  L1: inductor/toroid h12 h9 T37-2 32t
  C2: capacitor/ceramic j12 j9 62p
  C3: capacitor/ceramic l12 l9 22p
  VC1: capacitor m9 m6 260p
  C4: capacitor/ceramic o12 q12 47p
  C5: capacitor/ceramic q10 t10 220p
  C6: capacitor/ceramic u10 u7 470p
  Q1: transistor t12 s12 r12 2SC1815
  R1: resistor q16 q13 100k
  R2: resistor v10 v6 4.7k
  R3: resistor s17 s13 22k
  R4: resistor m21 m18 51k
  R5: resistor h19 h23 10k
  VR1: potentiometer/knob k18 j18 i18 10k
  C8: capacitor/electrolytic f16 f19 10u
  C9: capacitor/electrolytic o21 o23 100u
  R6: resistor k21 k25 220
  C7: capacitor/ceramic w13 w10 2.2n
  C10: capacitor/ceramic x8 aa8 10n
  U1: dip8 z12 LM386
  C11: capacitor/electrolytic y9 y12 10u
  C12: capacitor/electrolytic aa13 aa16 10u
  C13: capacitor/electrolytic ae5 ae2 220u
  R7: resistor ad12 ad9 10
  C14: capacitor/ceramic ad8 ad6 47n
  C15: capacitor/electrolytic x25 x23 100u
  C16: capacitor/ceramic u25 u23 100n
  J3: usb-c/female a20 a21 a22 a23
  PH:
    type: device
    at: ad-2
    label: ヘッドホン 32Ω
    pins: GND TIP
wires:
  - a20 -- c20 black
  - c20 -- c13 black
  - c13 -- 013 black
  - b6 -- h6 black
  - h6 -- j6 black
  - j6 -- m6 black
  - m6 -- u6 black
  - u6 -- v6 black
  - v6 -- w6 black
  - w6 -- ab6 black
  - ab6 -- ac6 black
  - ac6 -- ad6 black
  - 011 -- b11 black
  - b11 -- b6 black
  - h9 -- h6 black
  - j9 -- j6 black
  - u7 -- u6 black
  - w10 -- w6 black
  - ac9 -- ac8 black
  - ab9 -- ab8 black
  - ab8 -- ac8 black
  - ab8 -- ab6 black
  - c20 -- c23 black
  - c23 -- f23 black
  - f23 -- h23 black
  - h23 -- o23 black
  - o23 -- u23 black
  - u23 -- x23 black
  - x23 -- aa23 black
  - f19 -- f23 black
  - aa16 -- aa23 black
  - ad9 -- ad8 black
  - a23 -- a25 red
  - a25 -- k25 red
  - k25 -- u25 red
  - u25 -- x25 red
  - x25 -- ab25 red
  - ab25 -- ab12 red
  - k21 -- m21 red
  - m21 -- o21 red
  - o21 -- s21 red
  - s21 -- s17 red
  - k18 -- m18 orange
  - i18 -- h18 orange
  - h18 -- h19 orange
  - j18 -- j16 orange
  - j16 -- f16 orange
  - j16 -- q16 orange
  - a12 -- e12 white
  - g12 -- h12 yellow
  - h12 -- j12 yellow
  - j12 -- l12 yellow
  - l12 -- o12 yellow
  - l9 -- m9 yellow
  - q12 -- r12 blue
  - q12 -- q13 blue
  - q12 -- q10 blue
  - t12 -- u12 green
  - u12 -- u10 green
  - t10 -- u10 green
  - u10 -- v10 green
  - s12 -- s13 white
  - s13 -- w13 white
  - w13 -- x13 white
  - x13 -- x8 white
  - aa8 -- aa9 white
  - y9 -- z9 yellow
  - y12 -- z12 yellow
  - aa12 -- aa13 blue
  - ac12 -- ad12 white
  - ad12 -- ae12 white
  - ae12 -- ae5 white
  - PH.TIP -- ae2 white
  - PH.GND -- ad6 black
notes:
  - text d21 red large bold: IN 5V
  - mark ae2 yellow
  - text ac3 red large bold: 1+
  - mark z6 yellow
  - text z5 red large bold center: 1-
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/perfboard/08-regenerative.svg)

- 基板は 7×9 cm (31 列 × 26 行、縁のパッド付き)。5×7 cm では、同調回路の周りに余白を取ると LM386 までが 1 枚に載らなかった。
  7 MHz はユニバーサル基板の範囲 (10 MHz 以下・短い配線) の内。ブレッドボードは穴の間の容量 (数 pF) が C1 や C3 と同じ桁なので使わない
- **下の 6 行目と上の 23 行目が GND の筋** (黒)、**25 行目が 5 V の筋** (赤)。上下の GND は J1 (SMA) の凹の金物でつなぐ。
  上の筋は C 列を下りて凹の上の先端 (0 列 13 行) へ、下の筋は B 列を上がって下の先端 (0 列 11 行) へ。凹は 1 つの金物なので、これで上下がつながり、配線どうしはどこも交差しない。
  検波段の電源 (R6 の先) は 21 行目の赤い線
- **黄の線が同調回路の熱い側** (G12〜O12)。ここに指やドライバーを近づけると同調がずれるので、線は短く、ほかの線から離す
- J1 (SMA) の中心導体から C1 までの白い線 (A12〜E12) は、どの線も跨がない。電源の縦の線を C1 の左に通さないため、USB-C は左上に置いた
- R6 は GND の筋 (23 行目) を跨いで立つ (K25〜K21)。抵抗のリードで線を跨ぐ形
- **VC1 はポリバリコン**。図は固定コンデンサの形で描いてある (M9〜M6)。実物は基板の端に両面テープで留め、2 本の端子を短い線で
  M9 と M6 へつなぐ。つまみの軸に手を近づけると同調が動くときは、ローター側 (軸とつながる端子) を M6 (GND) にする
- **VR1 (再生) は基板に立てる** (K18・J18・I18)。細かく合わせたいときは多回転の品にする
- Q1 は **T12 が E、S12 が C、R12 が B** (E は U12 へ出して下ろす)。2SC1815 のピンは平らな面 (印字面) を手前にして左から E・C・B なので、平らな面を図の上 (26 行目の側) へ向けて挿す。向きは図の胴の形ではなく、この穴の名前で確かめる
- ヘッドホンは 3.5 mm のジャックを基板の外に置き、L と R を並列にして AE2 (TIP) と AD6 (GND) へつなぐ
- 黄色の丸は AD3 を挟む点: **1+ は AE2** (ヘッドホンの信号)、**1− は Z6** (GND)。W1 は基板に直接つながず、図3 の減衰器を通して J1 へ入れる
- 電源は左上の USB-C から 5 V (変換基板を左の縁に横向きに挿す。A23 が V、A20 が GND。無音のとき 5 mA 前後。LM386 の静止電流が大半)

## 計器の設定

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図3 AD3で試す (W1を40dB落としてJ1へ、出力を1+で見る)
parts:
  AD:
    type: device
    at: 3,4
    label: Analog Discovery 3
    pins: [W1, GND, 1-, 1+]
    turn: mirror
  R8: resistor 6,3.6 8,3.6 5.1k
  R9: resistor 9,3.6 9,5.6 51
  RX:
    type: device
    at: 14,4
    label: RX
    pins: [J1, TIP, GND]
  G1: ground 9,5.6
  G2: ground 5.5,6
  G3: ground 12,5.5
wires:
  - AD.W1 -- 6,3.6
  - 8,3.6 -- 9,3.6
  - 9,3.6 -- RX.J1
  - AD.GND -- 5.5,4
  - 5.5,4 -- 5.5,4.4
  - AD.1- -- 5.5,4.4
  - 5.5,4.4 -- 5.5,6
  - AD.1+ -- 5,4.8
  - 5,4.8 -- 5,7
  - 5,7 -- 11.5,7
  - 11.5,7 -- 11.5,4
  - 11.5,4 -- RX.TIP
  - RX.GND -- 12,4.4
  - 12,4.4 -- 12,5.5
notes:
  - text 9.5,2.8 blue: J1で約1/100 (-40dB)
  - text 13.2,2.8 blue: 図1の受信機
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/08-regenerative-2.svg)

AD3 の W1 は 7 MHz 台の正弦を出せる。そのままでは大きすぎるので、R8 (5.1 kΩ) と R9 (51 Ω) で約 1/100 (−40.1 dB) に落として
J1 に入れる。減衰器は SMA のプラグに直接半田付けし、J1 のすぐ手前に置く (長い線で引くと、線がアンテナになって減衰が効かない)。

| 項目 | AM の試験 (図4) | CW の試験 (図5) |
| --- | --- | --- |
| Wavegen W1 | 正弦 7.15 MHz、振幅 100 mV、AM 変調 1 kHz・30 % | 正弦 (無変調)、振幅 10 mV。周波数は受信機の発振の 700 Hz 上 |
| J1 に入る大きさ | 約 1 mV<sub>p</sub> | 約 100 µV<sub>p</sub> |
| 再生 VR1 | 発振の手前 (摺動子 1.00 V 付近) | 発振のすぐ上 (1.10 V 付近) |
| Scope 1+ | ヘッドホン端子 (AE2)。100 mV/div、500 µs/div | 同じ。50 mV/div |
| Supplies | 使わない (電源は USB-C) | 同じ |

**同調回路に AD3 のプローブを当てない。** 入力容量 (20 pF 前後) が C3 と同じ桁で、同調が大きくずれ、再生も掛からなくなる。
見るのは音声の出力だけにする。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 AM の検波 (W1 7.15MHz 100mV・1kHz 30%)。ヘッドホン端子は約0.36Vpp (計算)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 180mV, range: 100mV/div}
cursors: [0, 1ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/scope/08-regenerative-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 CW のビート (W1 無変調 10mV、発振の700Hz上)。約0.2Vpp (計算)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 700Hz 100mV, range: 50mV/div}
cursors: [0, 1.4286ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/scope/08-regenerative-2.svg)

図4・図5 はシミュレーションで得た検波出力 (AM で 1.8 mVpp、CW で約 1 mVpp) を LM386 の 200 倍で掛けた値。
実機は再生の位置で数倍動く (境目に近いほど大きい)。カーソルの間は 1 周期。

**アンテナ端子へ漏れる発振。** J1 に tinySA Ultra をつなぎ (アンテナは外す)、再生を回して発振の線が立つ所を見る。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図6 J1に出てくる発振の漏れ (VW 1.10V、計算)
device: tinysa-ultra
center: 7.15MHz
span: 200kHz
points: 450
rbw: 1kHz
ref: -20dBm
unit: dBm
signal:
  - sine 7.15MHz -45.4dBm
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/spectrum/08-regenerative.svg)

| tinySA の項目 | 設定 | 理由 |
| --- | --- | --- |
| 中心 / 幅 | 7.15 MHz / 200 kHz | 同調を動かしても線が画面に残る |
| RBW | 1 kHz | 線が細く立つ。フロアは約 −117 dBm |
| 基準レベル | −20 dBm | 線 (−45 dBm) が上から 2.5 目盛 |

| 摺動子の電圧 | 同調回路の発振 | J1 (50 Ω) への漏れ |
| --- | --- | --- |
| 1.06 V (境目のすぐ上) | 0.14 Vpp | −52.7 dBm (5 nW) |
| 1.10 V | 0.32 Vpp | −45.4 dBm (29 nW) |
| 1.20 V | 0.58 Vpp | −40.3 dBm (94 nW) |
| 1.40 V (つまみの上端) | 0.95 Vpp | −36.0 dBm (250 nW) |

距離 3 m で 500 µV/m は、全方向へ均等に出る電力に直すと約 75 nW (−41 dBm。P = (E × d)² ÷ 30)。**1.10 V までなら、
漏れた電力が全部電波になったとしても範囲の内** (見積り)。室内のワイヤ ([6-2](02-wire-antenna.md)) は効率が低いのでさらに余裕があるが、
つまみを上端まで回したまま屋外の大きなアンテナにつながない。測り方の考え方は
[03-nanovna 11-14](../../03-nanovna/11-spectrum-analyzer/14-field-strength.md)。

## 見るべき値

計算値 (LTspice)。**実機では組んでいない (未測定)。** 2SC1815 の模型は代用で、境目の電圧は実物で ±0.1 V ほど動く見込み。

| 測る所 | 期待する値 |
| --- | --- |
| 同調の範囲 (VC1 を端から端) | 約 6.9〜7.4 MHz (浮遊容量 5 pF と置いた見積り) |
| 再生を絞り切ったときの Q と帯域 (7.15 MHz) | 135、53 kHz |
| 発振の境目 | 摺動子 1.05 V、エミッタ電流 0.093 mA、コレクタ 約 3.0 V |
| 境目の手前 1.00 V | Q 1,470、帯域 4.9 kHz、J1 から同調回路まで 57 倍 |
| 境目の手前 1.04 V | Q 9,300、帯域 0.77 kHz、361 倍 |
| 再生を回したときの同調のずれ | 摺動子 0.1 V あたり約 −1 kHz |
| AM の試験の出力 (図4) | 1 kHz、約 0.36 Vpp |
| CW の試験の出力 (図5) | 700 Hz、約 0.2 Vpp |
| 発振の漏れ (1.10 V、図6) | −45.4 dBm |

- **帯域は境目までの残りに比例する**: 摺動子 1 mV あたり約 100 Hz。つまみの全幅 0.70 V の 1 % で 700 Hz 動くので、
  AM を聞くときは境目の手前で「サー」という雑音が急に増える所を探し、少し戻す
- **同調を動かすと境目も動く**: 同じ 1.00 V でも、6.94 MHz では Q 980、7.43 MHz では Q 4,100 (計算)。周波数を上げたら再生を少し戻す
- **境目は温度でも動く**: ベース・エミッタ間の電圧は 1 °C で約 −2 mV 変わり、境目の近くでは帯域が 200 Hz ほど変わる。
  電源を入れて数分は合わせ直す
- CW を聞くときは、発振させてから同調をゆっくり回す。信号の両側でビートが聞こえ、真ん中 (ゼロビート) で音が消える。
  700 Hz の音になる側へ 700 Hz ずらして止める
- **音声の利得は足りない側**: AM は検波が 2 乗特性なので、弱い局 (J1 で数十 µV) は境目のすぐ手前まで寄せないと聞こえない。
  CW は発振が局発になるので、同じ大きさの信号で AM の 10 倍以上の出力が出る。音量を足すなら、C10 の前に 2SC1815 の低周波増幅を 1 段入れる

## ダイレクトコンバージョン (6-5) と比べる

| | 再生式 (この題) | ダイレクトコンバージョン (6-5) |
| --- | --- | --- |
| 能動部品 | 2SC1815 1 個 + LM386 | SA612 + Si5351 + Pico 2 + LM386 |
| 聞ける電波 | AM・CW・SSB | CW・SSB (AM はゼロビートに合わせれば聞ける) |
| 選択度 | 再生の位置で決まる (数百 Hz まで狭められるが、狭いほど不安定) | 音声のフィルタで決まり、動かない |
| 周波数の安定 | LC の発振。手・温度・再生のつまみ・アンテナで動く | 水晶の精度で止まる |
| 周波数の読み | 読めない (つまみの目盛だけ) | 数値で分かる |
| 調整 | 同調と再生の 2 つを同時に | 同調 1 つ |
| 発振の漏れ | 同調回路がアンテナに直結なので出やすい | ミキサーの分離があり小さい |

部品の数は再生式が勝つが、初めての 1 台には、合わせる所が少なく周波数が分かる 6-5 を勧める。再生式は「Q を上げる」「発振の境目」を
手で感じられる回路で、同調回路の勉強として組む価値がある。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| Q1 | 2SC1815 (GR) | 再生検波 |
| U1 | LM386N-1 | 音声段 (6-4 と同じ) |
| L1 | 4.1 µH | T37-2 に φ0.3 mm の UEW を 32 回 (6-3 と同じ。リンクは巻かない) |
| VC1 | ポリバリコン 260 pF | AM 用の単連。2 連なら 260 pF に近い側を使う |
| C1・C2・C3・C4 | 4.7 pF・62 pF・22 pF・47 pF | 温度補償のセラミック (CH・C0G)。C2 が無ければ 56 pF にして L1 の巻きを詰める |
| C5・C6 | 220 pF (221)・470 pF (471) | C0G |
| C7・C10・C14 | 2.2 nF (222)・10 nF (103)・47 nF (473) | セラミックかフィルム |
| C8・C11・C12 | 10 µF | 電解 |
| C9・C15 / C13 / C16 | 100 µF / 220 µF / 100 nF (104) | 電解 / 電解 / セラミック |
| R1・R2・R3 | 100 kΩ・4.7 kΩ・22 kΩ | ベースの給電・エミッタ・コレクタの負荷 |
| R4・R5・R6・R7 | 51 kΩ・10 kΩ・220 Ω・10 Ω | VR1 の上下・電源の切り離し・LM386 の出力の RC |
| VR1 | 10 kΩ B | 再生。多回転でもよい |
| R8・R9 | 5.1 kΩ・51 Ω | 試験用の減衰器 (図3)。基板には載せない |
| J1 / J3 | SMA (端面) / USB-C の変換基板 | アンテナ / 5 V |
| ヘッドホン | 32 Ω、3.5 mm ジャック | L と R を並列 |
| 基板 | ユニバーサル基板 7×9 cm | 両面スルーホール、FR-4、1.6 mm |

- 電源は既定の 5 V
- フェンスの図では J2 (回路図のスピーカーの記号) が基板の図の「ヘッドホン」の箱に当たる

## LTspice での確かめ

デッキは [sim/](sim/) の `08-regen-*.cir`、作る手順は `08-regen-lib.py`。2SC1815 は 05-etc 第 3 章と同じ代用の模型
(h<sub>FE</sub> 250・f<sub>T</sub> 約 80 MHz。実測の値ではない)。L1 は無負荷 Q 150 (直列 1.22 Ω) と置き、アンテナは 50 Ω、
C3 と VC1 の枝は合計 18 pF (約 7.15 MHz) にした。

| 確かめること | 本文の数字 | LTspice の値 | 判定 |
| --- | --- | --- | --- |
| 再生なしの Q・帯域 (`.ac`、摺動子 0.3 V) | 135、53 kHz | 135、52.9 kHz (7.1558 MHz) | 合う |
| 境目の手前の Q (1.00 V / 1.04 V / 1.05 V) | 1,470 / 9,300 / — | 1,468 / 9,309 / 27,855 (帯域 4.87 kHz / 768 Hz / 257 Hz) | 合う |
| 発振の境目 | 1.05 V、0.093 mA | `.ac` の利得の逆数が 0 になるのは 1.055 V。`.dc` で I<sub>E</sub> 93 µA (1.05 V) | 合う |
| 発振の振幅 (1.06 / 1.10 / 1.20 / 1.40 V) | 0.14 / 0.32 / 0.58 / 0.95 Vpp | 0.138 / 0.322 / 0.580 / 0.947 Vpp。前後 0.5 ms で同じ値 (間欠にならない) | 合う |
| 同調の範囲 (枝 9.1 pF / 25.3 pF) | 約 6.9〜7.4 MHz | 7.43 MHz / 6.94 MHz | 合う |
| 再生による同調のずれ | 0.1 V で約 −1 kHz | 0.9 → 1.0 V で 7.1503 → 7.1493 MHz | 合う |
| AM の検波出力 (1 mV<sub>p</sub>・30 %、1.00 V) | 1.8 mVpp → 0.36 Vpp | LM386 の入力で 1.79 mVpp | 合う |
| CW のビート (100 µV<sub>p</sub>、1.10 V) | 約 1 mVpp → 約 0.2 Vpp | 700 Hz 付近に 0.7〜1.2 mVpp (4 ms の窓。粗い) | 見積り |
| J1 への漏れ | −52.7 / −45.4 / −40.3 / −36.0 dBm | 50 Ω の両端で 1.46 / 3.40 / 6.12 / 10.0 mVpp | 合う |

- 過渡解析は刻み 2 ns で回したので、発振の周波数が `.ac` の値より約 5 kHz 低く出る (数値積分の誤差)。周波数は `.ac` の値を正とした
- エミッタの R2 を高周波チョークと 1 µF でバイパスした版は、同調回路に 27 Vpp の間欠発振が出たので捨てた (デッキは残していない)
- 見ていない物: 実物の浮遊容量、ポリバリコンの Q、手を近づけたときのずれ、LM386 の雑音、強い局による引き込み

## 出典

自作。参考: [再生回路 (Wikipedia)](https://ja.wikipedia.org/wiki/%E5%86%8D%E7%94%9F%E5%9B%9E%E8%B7%AF)、
[コルピッツ発振回路 (Wikipedia)](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%AB%E3%83%94%E3%83%83%E3%83%84%E7%99%BA%E6%8C%AF%E5%9B%9E%E8%B7%AF)、
再生を滑らかに掛ける設計の考え方は [C. Kitchin, "High Performance Regenerative Receiver Design" (QEX 1998 年 11・12 月号)](https://www.arrl.org/files/file/Technology/tis/info/pdf/9811qex026.pdf)
(回路は写していない)。LM386 の利得とピンは [TI LM386 データシート](https://www.ti.com/lit/ds/symlink/lm386.pdf)。
微弱無線局の範囲は[電波法施行規則](https://laws.e-gov.go.jp/law/325M50080000014)第 6 条第 1 項第 1 号。
