---
book: circuits
chapter: 5
id: 5-4
title: LDO — USB 5V → 3.3V
tier: 50
source: 自作
board: BB
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

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | LDO レギュレータ (SOT-223 → ピンヘッダ変換モジュール) | AMS1117-3.3 |
| Cin | セラミックコンデンサ (入力側) | 10 µF |
| Cout | アルミ電解コンデンサ (出力側、極性あり) | 22 µF・16 V |
| Rled | 抵抗 (表示 LED 電流制限) | 150 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
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

## 出典

自作。
