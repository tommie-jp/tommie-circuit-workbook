---
book: etc
chapter: 3
id: 3-1
title: デュアルゲート FET ミキサー — 3SK291 で中波を 455 kHz の IF に変える
tier: 200
source: 自作
board: —
---

# 3-1 デュアルゲート FET ミキサー — 3SK291 で中波を 455 kHz の IF に変える

中波 (0.53〜1.6 MHz) の信号 (RF) に局部発振 (LO) を混ぜ、**455 kHz の中間周波 (IF)** に変える回路。
デュアルゲート FET の 3SK291 の G1 に RF、G2 に LO を入れ、ドレインに出る差の周波数をセラミックフィルタで選ぶ。
RF・LO・IF の 3 つのポートはどれも **50 Ω**、電源は **5 V** の単電源。
特性をシミュレーションで見た結果は [3-2](02-simulation.md)。

> [!WARNING]
> 3SK291 の SPICE モデルが無かったので、特性は**代用のモデル**で解析した。**実機では測っていない**。
> データシートの本文も直接は読めていない (検索結果の要約で読んだ)。
> 値は初期値として、組んだら測って合わせる (「調整」の節)。

## 仕様

| 項目 | 値 |
| --- | --- |
| RF | 0.53〜1.6 MHz (中波)。50 Ω |
| LO | RF + 455 kHz (0.985〜2.055 MHz)。50 Ω。+7 dBm (0.71 V 波高値) を標準にする |
| IF | 455 kHz。50 Ω |
| 電源 | 5 V (単電源) |
| FET | 3SK291 (東芝、デュアルゲート N チャネル MOSFET、**エンハンスメント型**、SMD 4 ピン) |

## 回路図

```circuit
title: 図01 3SK291 デュアルゲート FET ミキサー (+5 V・50 Ω 入出力・IF 455 kHz)
parts:
  VDD:  vcc a8 5V
  C6:   capacitor b3 d3 100n
  C7:   ecap b6 d6 10u
  R4:   resistor c8 e8 33k
  R5:   resistor f8 h8 13k
  LO:   port f2
  R3:   resistor f4 h4 51
  C2:   capacitor f5 f7 10n
  RF:   port n2
  R1:   resistor n4 p4 51
  C1:   capacitor n5 n7 10n
  VDD:  vcc j8 5V
  R2:   resistor k8 m8 1M
  R6:   resistor n8 p8 150k
  VR1:  resistor-var p8 r8 200k
  U1:
    type: device
    at: f13c0
    label: 3SK291
    pins: [D, G2, G1, S]
  L1:   inductor b13 d13 220u
  C3:   capacitor b15 d15 560p
  C4:   capacitor d16 d18 10n
  R7:   resistor d19 f19 2k
  FL1:
    type: ic3
    at: d21
    label: 455kHz
    pins: [IN, GND, OUT]
  C5:   capacitor d23 f23 1.2n
  L2:   inductor d23 d25 100u
  IF:   port d27
  G1:   ground d3
  G2:   ground d6
  G3:   ground h4
  G4:   ground h8
  G5:   ground p4
  G6:   ground r8
  G7:   ground h11a5
  G8:   ground e21
  G9:   ground f23
  G10:  ground f19
wires:
  - b3 -- b15
  - a8 -- b8
  - b8 -- c8
  - b6 -- b8
  - e8 -- f8
  - f2 -- f5
  - f7 -- f8 |- U1.G2
  - n2 -- n5
  - n7 -- n8
  - j8 -- k8
  - m8 -- n8
  - n8 -- n10 |- U1.G1
  - U1.D -| d11
  - d11 -- d13
  - d13 -- d15 -- d16
  - d18 -- d19 -- FL1.IN
  - FL1.OUT -- d23
  - d25 -- d27
  - FL1.GND -- e21
  - U1.S -| h11a5
notes:
  - text i1 small left: "LO IN 50Ω (0.985-2.055 MHz)"
  - text j1 small blue left: "+7 dBm (0.71 Vp / 1.4 Vpp)"
  - text l1 small left: "RF IN 50Ω (0.53-1.6 MHz)"
  - text m1 small blue left: "-30 dBm (10 mVp / 20 mVpp)"
  - text f26 small left: "IF OUT 50Ω (455 kHz)"
  - text g26 small blue left: "RF -30 dBm で -28.6 dBm (11.7 mVp)"
  - text e8a5 small blue left: "G2 1.41 V"
  - text l10a5 small blue left: "G1 1.24 V (VR1 約 180 kΩ)"
  - text a14 small left: "L1・C3 は約 454 kHz に同調"
  - text g22 small left: "FL1 は入出力 1.5 kΩ 品"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/03-mixer-dual-gate-fet/circuit/01-mixer.svg)

左から RF と LO を入れ、中央の 3SK291 (U1) で混ぜ、右のセラミックフィルタ (FL1) で 455 kHz を選んで IF OUT へ出す。
電源の記号 (+5V) は、G1 の分圧を遠くの電源の線まで引き回さないよう 2 か所に置いた (同じ名前なので同じ電源)。
3SK291 は circuit フェンスにデュアルゲートの記号が無いので、足の名前 (G1・G2・D・S) を刷った箱で描いた。
青い数字は解析で求めた動作点と信号の大きさ。

### 3 つの工夫

- **G1 は 1 V 前後の正の電圧が要る。** 3SK291 はエンハンスメント型で、G1 を 0 V にすると ID がほぼ流れない
  (IDSS は最大 0.1 mA)。VDD から 1 MΩ で引き上げ、150 kΩ と可変抵抗 VR1 (200 kΩ) で分けて、
  VR1 で ID を 10 mA 前後に合わせる。ソースは直接 GND
- **G2 は低い電圧 (約 1.4 V) に置く。** データシートの測定条件の VG2S = 4.5 V は増幅器の条件で、
  LO で G2 を振るミキサーでは変換が起きない (3-2 の図 3)。33 kΩ と 13 kΩ の分圧で 1.41 V にした
- **ドレインは 220 µH と 560 pF の並列に給電する。** 約 454 kHz に同調し、RF と LO に低いインピーダンスを
  見せる。1 mH と 120 pF では RF の周波数で利得が約 5 dB 揺れた。フィルタの入力には 2 kΩ (R7) を並列にして、
  フィルタの源のインピーダンスを決める。R7 が無いと IF OUT が 50 Ω にならない

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| U1 | 3SK291 | デュアルゲート N チャネル MOSFET。**SMD (SMQ 4 ピン)** なので変換基板が要る |
| R1 | 51 Ω | RF IN の 50 Ω 終端 (ポートに並列) |
| R2 | 1 MΩ | VDD から G1 へのバイアス |
| R3 | 51 Ω | LO IN の 50 Ω 終端 (ポートに並列) |
| R4 | 33 kΩ | G2 の分圧 (上) |
| R5 | 13 kΩ | G2 の分圧 (下)。G2 = 5 V × 13 / 46 ≒ 1.41 V |
| R6 | 150 kΩ | G1 の分圧 (下の固定分) |
| VR1 | 200 kΩ (B カーブ) | G1 の分圧 (下の可変分)。ID を合わせる |
| R7 | 2 kΩ | セラミックフィルタ入力の終端 |
| C1, C2 | 10 nF | RF と LO の DC カット (セラミック) |
| C3 | 560 pF | L1 と並列で約 454 kHz に同調 (C0G / NP0) |
| C4 | 10 nF | IF をフィルタへ (DC カット) |
| C5 | 1.2 nF | 出力整合 (シャント。C0G / NP0) |
| C6 | 100 nF | 電源のデカップリング (セラミック) |
| C7 | 10 µF 16 V | 電源のデカップリング (電解。+ を電源側に) |
| L1 | 220 µH | ドレインの DC 給電と IF の同調 (直流抵抗の小さいもの) |
| L2 | 100 µH | 出力整合 (直列) |
| FL1 | 455 kHz セラミックフィルタ | **入出力 1.5 kΩ の品**。型番ごとにインピーダンスが違うので、データシートで確かめる |
| 電源 | 5 V | 既定の電源 |

出力整合は、フィルタの出力 (1.5 kΩ) に C5 を並列に、50 Ω 側へ L2 を直列に入れた L 型。
455 kHz で C5 の抵抗分を考えると 1.5 kΩ が約 54 Ω に下がり、L2 の 286 Ω のリアクタンスがその C5 の残りを打ち消す。
フィルタが 1.5 kΩ でなければ、C5 と L2 を計算し直す。

## 実体配線図

**まだ描いていない。** 3SK291 は SMD の 4 ピン (SMQ) で、ブレッドボードやユニバーサル基板に挿せない。
変換基板に載せるか、銅張り基板に直接はんだ付けする。bread / perf フェンスに 3SK291 の部品が無いので、
部品を足すときに描く。

## 想定する電圧

### 直流 (解析の動作点)

| 場所 | 電圧 | 備考 |
| --- | --- | --- |
| VDD | 5.00 V | |
| ドレイン | 4.95 V | L1 の直流抵抗 (モデルで 5 Ω) による降下 |
| G1 | 1.24 V | VR1 が約 180 kΩ のとき。**VR1 で ID を合わせる** |
| G2 | 1.41 V | 33 kΩ と 13 kΩ の分圧 |
| ソース | 0 V | 直接 GND |
| ID | 9.8 mA | 電力 約 49 mW (絶対最大 150 mW) |

RF IN・LO IN・IF OUT は**どれも直流 0 V** (C1・C2・C4 とフィルタで切ってある)。外から直流を加えない。

### 交流 (ポートの 50 Ω の両端)

| ポート | 条件 | 電力 | 実効値 | 波高値 | ピーク間 |
| --- | --- | --- | --- | --- | --- |
| RF IN | 標準 (解析条件) | −30 dBm | 7.1 mV | 10 mV | 20 mV |
| RF IN | 利得が一定の上限の目安 | −10 dBm | 70.7 mV | 100 mV | 0.2 V |
| RF IN | 利得が約 1.5 dB 落ちる (モデル) | 0 dBm | 224 mV | 0.32 V | 0.63 V |
| LO IN | 標準 | +7 dBm | 0.50 V | 0.71 V | 1.42 V |
| LO IN | 下限 (変換利得 −4 dB) | 0 dBm | 0.22 V | 0.32 V | 0.63 V |
| LO IN | 上限の目安 (+2 dB 以上) | +10 dBm | 0.71 V | 1.0 V | 2.0 V |
| IF OUT | RF −30 dBm のとき | −28.6 dBm | 8.2 mV | 11.7 mV | 23 mV |
| IF OUT | RF −10 dBm のとき | −8.7 dBm | 82 mV | 0.12 V | 0.23 V |

LO は G2 の直流 (1.41 V) の周りを ±0.7 V (+7 dBm のとき) 振る。G1・G2 の絶対最大は ±8 V なので余裕がある。

## 調整

1. RF と LO を入れずに VR1 を回し、**ID が約 10 mA** になる所に合わせる。ID は VDD の線に入れた電流計か、L1 の両端の電圧で見る
2. LO を +7 dBm、RF を −30 dBm (LO は RF + 455 kHz) で入れ、IF OUT の 455 kHz を見ながら R5 を替えて、
   G2 を 1.2〜1.6 V の間で探す。G2 を上げすぎると変換が急に落ちる
3. LO を 0〜+10 dBm で動かして、利得の傾きを確かめる

## 見るべき値

IF OUT で見える 455 kHz の大きさは、RF −30 dBm・LO +7 dBm のとき **約 −28.6 dBm (波高値 11.7 mV)**。
変換利得は +1 dB 前後で、**組んだ実機では大きく外れうる** (3-2 の「確かめていないこと」)。
測るなら tinySA Ultra か Analog Discovery 3 の Spectrum で、IF OUT の 455 kHz とその両側を見る。

## 注意

- 中波の RF 入力に**前置の同調回路が無い**。影像 (LO + 455 kHz) も同じ利得で出るので、
  実際に使うときは RF の前にバリコンなどの同調回路を置く
- ミキサーの出力にはセラミックフィルタ 1 つ。RF・LO・和周波を落とす深さは、フィルタの型番で決まる
- 3SK291 はゲートが静電気に弱い。取り扱いに注意する

## 出典

- [3SK291 (RS)](https://au.rs-online.com/web/p/mosfets/7560385) — VDS 最大 12.5 V・ID 最大 30 mA
- [3SK291 データシート (electronicsdatasheets)](https://www.electronicsdatasheets.com/download/101912.pdf?format=pdf) —
  VDS = 6 V・VG2S = 4.5 V・ID = 10 mA の測定条件 (検索結果の要約で読んだもの)
- [3SK291 データシート (秋月電子)](https://akizukidenshi.com/goodsaffix/3SK291_datasheet_ja_20140301.pdf) —
  |Yfs| 26 mS・Ciss 2.0 pF・Crss 0.016 pF・IDSS 最大 0.1 mA (検索結果の要約で読んだもの)
- [CFX455G (村田)](https://pdf.jiepei.com/cfx455g-28251406.html) — 入出力 1500 Ω の記載
- 元の回路は AI が描いた図で、動かない所を直して描き直した (図と文は写していない)
