---
book: circuits
chapter: 5
id: 5-4
title: LDO — USB 5V → 3.3V
tier: 50
source: 自作
board: [BB, PF]
era: 今
---

# 5-4 LDO — USB 5V → 3.3V

USB の 5 V から、今のマイコン (11 章の Pico 2 など) やセンサーの定番の電圧 3.3 V を作る。
5-3 の 7805 は入出力の差が約 2 V 要るので、5 V から 3.3 V (差 1.7 V) は作れない。
LDO (Low Drop Out) は、ドロップアウト (5-2 で見た) が小さく、入力と出力の差が小さくても動く 3 端子レギュレータの仲間で、
USB 給電の基板でいちばんよく見る電源回路だ。

## 回路図

```circuit
title: 図1 USB 5V から 3.3V の LDO (CH1 は出力の電圧)
parts:
  J1: usb-c b2g0d0
  U1: regulator b6 AMS1117-3.3
  Cin: capacitor b4 d4 10u
  Cout: ecap b8 d8 22u
  Rled: resistor b10 c10 150
  Dled: led c10 d10 red
  M1: voltmeter b12 d12 l=$\mathrm{CH1}$
  G1: ground gnd
points:
  gnd: d3
wires:
  - J1.VBUS -| b4
  - J1.GND -| gnd
  - b4 -- U1.in
  - U1.out -- b8 -- b10 -- b12
  - U1.gnd -- d6
  - gnd -- d4 -- d6 -- d8 -- d10 -- d12
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/04-ldo-usb.svg)

- J1 は USB Type-C。電源として使うのは VBUS (+5 V)・GND だけ。
  CC1・CC2 は、つながれた機器が電源を受ける側かを相手 (PC や充電器) に知らせるピンで、
  受ける側はそれぞれを 5.1 kΩ で GND へつなぐ (プルダウン)。これが無いと、C-C ケーブルでつないだ相手は
  VBUS に 5 V を出さない (A-C ケーブルなら出る)。図1 では CC を省いている。実物は 5.1 kΩ の載った
  電源取り出しモジュールを使う (下の実体配線図の注)
- Cout (22 µF) は AMS1117 の働きの一部。AMS1117 のデータシート (Advanced Monolithic Systems) は、
  出力のコンデンサを周波数補償 (帰還のループを発振させないための仕組み) に使うと書き、
  「22 µF の固体タンタルを付ければ、すべての条件で安定する」とだけ数を挙げている。ESR
  (等価直列抵抗。コンデンサの中にある小さな抵抗分) の範囲は書いていない
- 同じ作りの LM1117 (TI) のデータシート (SNOS412) は、出力のコンデンサを 10 µF 以上、
  ESR を 0.3〜22 Ω と数で決めている。この教科書は AMS1117 にもこの範囲を目安として当てる
- 汎用のアルミ電解 (16 V・22 µF) の ESR は、損失角の正接 tan δ (120 Hz で 0.16 前後が多い。品種のデータシートで確かめる) から
  ESR = tan δ ÷ (2π f C) = 0.16 ÷ (2π × 120 Hz × 22 µF) ≈ 9.6 Ω。周波数が上がると下がって
  100 kHz で 1 Ω 前後になり、どちらも 0.3〜22 Ω の中に入る (目安)。そこで Cout はタンタルではなく、
  この教科書の標準のアルミ電解 (22 µF・16 V) にする。極性があり、+ 側を OUT につなぐ
- 積層セラミックの ESR は数 mΩ で、0.3 Ω を大きく下回る。Cout を積層セラミックだけにすると
  発振することがあるので使わない。寒い所ではアルミ電解の ESR が上がるので、22 Ω を超えないよう室温で使う
- Cin (10 µF) は入力の線の影響を抑えるためのもので、ESR を問わないので積層セラミックでよい
- Rled・Dled は 3.3 V が出ているかを示す表示の LED

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (5 V は AD の V+、1+ を OUT へ)
board: half
parts:
  U1: regulator/to220 c8(in) c9(gnd) c10(out) AMS1117-3.3
  Cin: capacitor g5 g8 10uF
  Cout: capacitor/electrolytic g10 g13 22uF
  Rled: resistor b14 b20 150
  Dled: led d20(A) d23(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Supplies V+ と Scope)
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- i8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - a10 -- a14 orange
  - a23 -- -t23 black
  - -t29 -- -b29 black
  - AD.GND -- -b4 black
  - AD.1+ -- i10 orange
  - AD.1- -- -b11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/04-ldo-usb.svg)

- 入力の 5 V は Analog Discovery の Supplies の V+ (WaveForms で 5 V にする) から、IN の 8 列 (`i8`) へ入れる。
  負荷は約 9 mA で、Supplies の各レール 50 mA (USB 給電で 250 mW) に収まる。GND は下の − レール (`-b4`) へ。
  実機の USB 給電にするなら、USB-C の電源取り出しモジュール基板の VBUS を V+ の代わりに、GND を GND の代わりに挿す。
  CC に 5.1 kΩ のプルダウンが載ったものを選ぶ (載っているかは商品の説明で確かめる)。USB の D+・D− は使わない
- Analog Discovery の 1+ (橙) は OUT の 10 列 (`i10`)、1− (黒) は下の − レール (`-b11`) へ
- U1 のピン (IN・GND・OUT = 8・9・10 列) は、上のブロックの e 行から線で下のブロックへ渡す。
  Cin (5・8 列) と Cout (10・13 列) は下のブロックに挿し、出力は a10 から 14 列の Rled へ渡す。
  上下の − レールは 29 列でつなぐ
- AMS1117 の実物は SOT-223 (面実装) だけで、ブレッドボードへ直接は挿せない。
  図2 で 3 ピンの部品として描いているのは、市販の「AMS1117 3.3V 固定出力モジュール」基板
  (SOT-223 を 3 本のピンヘッダに出したもの) を挿す想定だからだ。
  IN・GND・OUT の並びは品種・基板によって違うので、モジュールの基板の印刷で確かめる

USB の 5 V の電源として使い続けるなら、ブレッドボードの配線は接触が不安定なので、ユニバーサル基板に半田付けして残す。
電圧は 5 V、電流は約 9 mA、周波数は直流なので、ユニバーサル基板の範囲 (定常 12 V・500 mA 以下) に収まる。

```perf
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
unused: [J1.D+, J1.D-, J2.D+, J2.D-]
title: 図3 ユニバーサル基板に組む (部品面から見た図。黄色の丸は AD3 を挟む所)
parts:
  J1: usb-c/female b5 c5 d5 e5
  J2: usb-c/female t5 u5 v5 w5
  U1: regulator i14 j14 k14
  Cin: capacitor g14 g11 10u
  Cout: capacitor/electrolytic n17 n13 22u
  Rled: resistor q17 q14 150
  Dled: led q12 q9 red
wires:
  - b5 -- b6 black
  - b6 -- g6 black
  - g11 -- g6 black
  - g6 -- j6 black
  - j14 -- j6 black
  - j6 -- n6 black
  - n13 -- n6 black
  - n6 -- q6 black
  - q9 -- q6 black
  - q6 -- t6 black
  - t5 -- t6 black
  - e5 -- e17 red
  - e17 -- g17 red
  - g17 -- i17 red
  - g17 -- g14 red
  - i17 -- i14 red
  - k14 -- k17 orange
  - k17 -- n17 orange
  - n17 -- q17 orange
  - q17 -- w17 orange
  - w5 -- w17 orange
  - q14 -- q12 orange
notes:
  - mark w6 yellow
  - mark t6 yellow
  - text w6 red large bold right: AD3 1+
  - text t7 red large bold center: AD3 1-
  - text b3 red large bold: IN 5V
  - text w3 red large bold: OUT 3.3V
  - parts
style:
  back: on
  labels:
    sides: left bottom
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/perfboard/04-ldo-usb.svg)

- ユニバーサル基板は 5×7 cm のパッド付き基板 (左右の縁に細長い銅箔のパッドがある両面スルーホール) を横に使う (24 列 × 18 行、1.6 mm の FR-4)。
  番地は基板の刷りどおりで、英字が列 (左から A〜X)、数字が行 (下から 1〜18)。縁のパッドは図の 0 列と Y 列で、この題では使わない。
  上の図は部品面から見た図で、17 行が + の筋 (赤の 5 V と橙の 3.3 V)、6 行が GND の筋 (黒)。
  下の図は半田面 (裏返した基板) で、列が左右逆になる。半田付けは半田面で行う
- 入力の J1 は左下端 (B5〜E5)、出力の J2 は右下端 (T5〜W5) に置く。どちらも USB-C の電源取り出しモジュールで、
  受け口は 2 つとも下の縁を向き、基板の中に収まる (ケーブルは 2 本とも下から出る)。J1 の置き場は 05-etc の 3-1 (`05-etc/03-mixer-dual-gate-fet/01-mixer.md`) の図03 と同じ
- J1 の VBUS (E5) は E 列を上って 17 行の + の筋 (5 V) へ、GND (B5) は B6 を経て 6 行の GND の筋へ行く。
  J2 の VBUS (W5) へは U1 の OUT (3.3 V) を 17 行で右へ運んで W 列を下ろし、GND (T5) は T6 で 6 行の GND の筋に入る。
  線をパッドから縦に出すのは、パッドの横の刷り字 (V・D−・D+・GND) を隠さないため。D+ と D− は使わない (`unused:` に並べて、ERC の「つながっていない」から外した)
- J1 のモジュールは、CC に 5.1 kΩ が載ったものを選ぶ (図2の注と同じ。充電器から 5 V をもらう側)
- 同じ形の受け口が下の縁に 2 つ並ぶので、図に `IN 5V` と `OUT 3.3V` を大きな赤の太字で書いた。実物の基板にも同じ字を書いておく。
  充電器を J2 に挿すと、AMS1117 の出力に 5 V が逆から入り、壊れることがある
- **J2 は USB の規格の出力ではない。** VBUS に 3.3 V が出るので、スマートフォン・パソコン・充電器などの USB 機器を J2 につながない
  (相手の VBUS と 3.3 V がぶつかり、壊れることがある)。J2 は、3.3 V の実験回路 (11 章の Pico 2 の 3V3 など) へ
  ケーブルで電源を渡す取り出し口として使い、その先も電源の取り出しモジュールにする
- U1 は AMS1117 3.3V のモジュール (IN・GND・OUT = I14・J14・K14)。IN は 17 行の + の筋から、GND は下の 6 行へ、OUT は 17 行の右半分へ出す。
  モジュールのピンの並びは印刷で確かめる (図2と同じ)
- Cin (10 µF、G14・G11) は 5 V の筋と GND の筋の間、Cout (22 µF、N17・N13) は 3.3 V の筋と GND の筋の間。
  Cout は極性があり、+ 側を 17 行 (OUT) につなぐ。Rled (Q17・Q14) と Dled (Q12・Q9) は 3.3 V の表示
- AD3 は半田付けしない。測るときだけ、J2 のパッドにクリップで挟む。1+ は VBUS につながる W6 (3.3 V)、1− は GND の筋の T6 で、どちらも黄色の丸で囲み、
  `AD3 1+` は W6 の丸の右、`AD3 1-` は T6 の丸の 1 行上 (T7 の真上に中心。6 行目は GND の筋が通るので避けた) に、赤の大きな太字で書いた。出力のコネクタで測るので、出力の 3.3 V が実際に出ているかを見られる。
  AD は測るだけで、この基板に電力は供給しない
- 線は縦と横だけで、交差は E6 の 1 か所。J1 の VBUS の赤い線が、GND の筋 (6 行) を弧で跨ぐ。
  実物では、赤い線を被覆線にして GND の筋の上を渡すか、部品面のジャンパにする

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | LDO レギュレータ (SOT-223 → ピンヘッダ変換モジュール) | AMS1117-3.3 |
| Cin | セラミックコンデンサ (入力側) | 10 µF |
| Cout | アルミ電解コンデンサ (出力側、極性あり) | 22 µF・16 V |
| Rled | 抵抗 (表示 LED 電流制限) | 150 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 基板 (図3) | ユニバーサル基板 5×7 cm、パッド付き (横使い、1.6 mm・FR-4) |
| J1 | USB-C 電源取り出しモジュール (入力。CC に 5.1 kΩ つき) | 図3 の左下端 |
| J2 | USB-C 電源取り出しモジュール (出力。3.3 V の取り出し口) | 図3 の右下端。USB 機器をつながない |
| — | 電源・計器 | Analog Discovery 3 の Supplies V+ = 5 V (USB 5 V の代わり。電流 約 9 mA) と Scope (1+ = OUT、1− = GND)。USB-C 給電でも同じ |

## 計器の設定

計器は Analog Discovery 3 の Scope (1+ = OUT、1− = GND) か、テスター。この題は直流の電圧と電流だけを見るので、
オシロの波形の図は付けない (時間で変わる量が無く、読み値の数字で足りる)。Scope は DC カップリング・1 V/div で OUT の電圧を読む。

## 見るべき値

表の値は計算値。電圧はテスターの DC 電圧レンジで、− 側の棒を GND (− レール) に当てて測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| OUT の電圧 | 3.30 V | AMS1117-3.3 の固定出力 |
| Dled の電流 | 約 8.7 mA | (3.3 V − 2.0 V) ÷ 150 Ω |
| ドロップアウト電圧 | 約 1.1 V (@1A、代表値) | V<sub>in</sub> − V<sub>out</sub> が 1.1 V を割ると出力を保てなくなる。5 V 入力なら差は 1.7 V で余裕がある |
| U1 の損失 (Dled だけの軽負荷) | 約 14.7 mW | (5 V − 3.3 V) × 8.7 mA |
| USB の電流上限との比較 | 8.7 mA ≪ 500 mA (USB 2.0 の規定) | この程度の負荷なら USB 給電で全く問題ない |

負荷電流 I が数百 mA に増えると、(5 − 3.3) V × I の損失が無視できなくなる
(300 mA で約 0.5 W)。放熱の無い SOT-223 では熱くなり、AMS1117 の過熱保護が働いて出力が絞られることがある。
大電流が要るなら降圧スイッチング (5-6) を使う。

USB の 5 V はスマートフォンの充電器でもモバイルバッテリーでも取れるが、どちらも中はスイッチング電源で、
出力には数十 kHz から数 MHz のノイズが乗る。LED やマイコンを動かすだけなら、そのままでよい。
マイクやセンサーの小さな信号を増幅する回路では、乾電池にするか、LC のフィルタを通す。
どれだけ乗っているかは、Analog Discovery の冊の 10-3 (USB 充電器のノイズを見る) で測る。

## 出典

自作。
