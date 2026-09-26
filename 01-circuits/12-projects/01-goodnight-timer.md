---
book: circuits
chapter: 12
id: 12-1
title: おやすみタイマー — 555 単安定 + MOSFET
tier: 50
source: 自作
board: [BB, PF]
---

# 12-1 おやすみタイマー — 555 単安定 + MOSFET

555 の単安定 (3-3) と MOSFET スイッチ (2-5) を組み合わせた実用回路。ボタンを
押すと常夜灯の LED が点き、約 19 分後に自動で消える。寝る前に押しておけば、
読書灯として使って自然に消灯する「おやすみタイマー」になる。

## 回路図

```circuit
title: 図1 555単安定(CMOS版)でMOSFETを約19分だけON
parts:
  VCC: vcc b4
  U1: dip8 d6 TLC555
  Gu1: ground a6
  Rtrig: resistor b4 c4 100k
  SWtrig: button c4 c2
  Gtrig: ground c2
  VCC: vcc b7
  Rt: resistor b8 c8 4.7M
  Ct: capacitor c10 e10 220u
  Get: ground e10
  VCC: vcc f6
  Rg: resistor g9 g11 220
  Q1: nmos-e f12i0i0
  Gq1: ground h12
  VCC: vcc b12
  RLED: resistor b12 d12 470
  DLED: led d12 e12 red
wires:
  - U1.1 -| a5
  - a5 -- a6
  - c4 |- U1.2
  - U1.8 -| b7
  - b7 -- b8
  - U1.7 -| c8
  - c8 -- c9 -- c10
  - U1.6 -| c9
  - U1.4 -| f5
  - f5 -- f6
  - U1.3 -| g3
  - g3 -- g9
  - g11 |- Q1.G
  - e12 -- Q1.D
  - Q1.S -- h12
style:
  grid: on
```

- U1.2 (TRIG) は Rtrig (100kΩ) で常時 H。SWtrig を押した瞬間だけ L になり、
  単安定が始まる
- U1.6・7 (THR・DISCH) と Rt (4.7MΩ)・Ct (220µF) が時定数を決める:
  T = 1.1×Rt×Ct **≈ 1137秒 (約19分、計算値)**
- **U1 は普通の (バイポーラ) NE555 ではなく CMOS 版 (TLC555) を使う。**
  Rt が大きいと、THR・TRIG 入力に流れ込むわずかな電流 (入力バイアス電流) も
  無視できなくなる。バイポーラの NE555 は数百 nA 流れることがあり、4.7MΩ
  では電圧の誤差になるが、CMOS 版は pA オーダーで無視できる
- **電解コンデンサ自身の漏れ電流にも注意。** Rt を流れる充電電流は
  9V/4.7MΩ ≈ 1.9µA しかない。コンデンサの漏れがこれに近づくと、C は 2/3 Vcc に
  なかなか届かず、時間が延びる。漏れがこれを超えると**タイマーが終わらない**。
  データシートの漏れの上限 0.01×C×V (V は定格電圧、電圧をかけて 2 分後) は
  220µF・25V 品で 55µA もあるが、これは定格の電圧をかけた直後の上限。
  定格に余裕のある品 (25V 以上) を 9V で使い、しばらく電圧をかけておくと、
  実際の漏れは 1µA を大きく下回るのがふつう (**目安**)。そこで
  **定格 25V 以上の電解コンデンサか、低漏れ (低リーク) 品を使い、組んだら数分
  電圧をかけてから使う**。容量を 10 倍にすると漏れもおよそ 10 倍になるので、
  時間は C より Rt で稼ぎ、C は 220µF に留める
- U1.3 (OUT) が単安定の間 H になり、Rg (220Ω) を通して Q1 (2N7000) のゲートを
  駆動する。Q1 が ON の間、DLED (常夜灯) が点く
- U1.4 (RESET) は U1.8 (VCC) にそのまま結んで無効化 (常に動作可能にする)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  U1: dip8 @ e5 TLC555
  Rtrig: resistor a10 a12 100k
  SWtrig: button @ e15
  Rt: resistor a20 a22 4.7M
  Ct: capacitor/electrolytic c22 c24 220u
  Rg: resistor a32 a34 220
  Q1: transistor h36(G) h37(D) h38(S) 2N7000
  RLED: resistor a42 a44 470
  DLED: led c44(A) c46(K) red
wires:
  - U1.8 -- b3
  - b3 -- +t3
  - U1.4 -- b3
  - U1.1 -- b2
  - b2 -- -t2
  - +t10 -- b10
  - U1.2 -- b12
  - b12 -- d15
  - g15 -- -b15
  - -t50 -- -b50
  - +t20 -- b20
  - U1.7 -- b22
  - U1.6 -- b22
  - b24 -- -t24
  - U1.3 -- b32
  - b34 -- h36
  - h38 -- -t38
  - +t42 -- b42
  - b46 -- h37
```

- U1 (e5) の足8・4 を +t、足1 を GND。足2 (TRIG) は Rtrig で +t へプルアップし、
  SWtrig (10 列と 15 列を橋渡し) を押すと GND へ落ちる。SWtrig の GND 側は下の −
  レールなので、50 列の線で上の − レールとつなぐ
- 足6・7 (THR・DISCH) が Rt・Ct の時定数ノード
- 足3 (OUT) が Rg を通して Q1 のゲート (h36)。+t → RLED → DLED (常夜灯) の
  カソード (46 列) を Q1 のドレイン (h37) へ、ソース (h38) が GND

## ユニバーサル基板に組む

作品として仕上げるので、perfboard にも同じ回路を組む。

```perfboard
board:
  size: 35x12
  slots: on
title: 図3 perfboardに組む
points:
  VCC: a1
  GND: j1
parts:
  U1: dip8 c1 TLC555
  Rtrig: resistor a10 c10 100k
  SWtrig: button g10
  Rt: resistor a15 c15 4.7M
  Ct: capacitor/electrolytic g15 h15 220u
  Rg: resistor g20 g22 220
  Q1: transistor g24 g25 g26 2N7000
  RLED: resistor a28 g28 470
  DLED: led g30 g32 red
wires:
  - c1 -- a1
  - a5 -- a28
  - a1 -- a10
  - a1 -- a15
  - f1 -- g1
  - g1 -- j1
  - f4 -- f5
  - f5 -- a5
  - a5 -- a1
  - c2 -- c3
  - c3 -- b3
  - b3 -- b15
  - b15 -- c15
  - g10 -- f2
  - c10 -- g10
  - i10 -- j10
  - j10 -- j1
  - g15 -- c15
  - h15 -- h20
  - h20 -- j20
  - j20 -- j1
  - g20 -- f3
  - g22 -- g24
  - g26 -- j26
  - j26 -- j1
  - g28 -- g30
  - g32 -- i32
  - i32 -- i25
  - i25 -- g25
```

- U1 (c1、DIP8) は 3 穴間隔で足8 (VCC) が c1、足7 (DISCH) が c2、足6 (THR) が
  c3、足5 (CTRL) が c4、足1 (GND) が f1、足2 (TRIG) が f2、足3 (OUT) が f3、
  足4 (RESET) が f4 に来る
- 足4 (RESET) は 5 列へ迂回してから VCC の a 行へ、足1 (GND) は g・j 行を
  通って GND の j 行へ。**足5 (CTRL) はどこにもつなげていない** — 単安定の
  動作には必須ではなく、浮かせたままでも動く (つなぐならここに 0.01µF を
  GND へ)
- Rtrig・SWtrig が足2 (TRIG) のプルアップと押しボタン (c10 行経由)、Rt・Ct が
  足6・7 (THR・DISCH、b3 経由でひとつの節点) の時定数、Rg・Q1・RLED・DLED が
  足3 (OUT) から先の出力段 (g 行を東西に使い、Q1 のドレインだけ i 行で迂回)
  (足3、d1 の列から)

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| SWtrig を押した直後の U1.3 (OUT) | H (約9V) に変わり、DLED が点く |
| 点灯している時間 | T = 1.1×4.7MΩ×220µF **≈ 1137秒 (約19分、計算値)** |
| DLED の電流 | 約14.9mA ((9V−2.0V)/470Ω、赤色 LED、計算値) |
| 19分後の U1.3 | L (0V) に戻り、DLED が消える |

Ct (220µF) を 100µF に替えると T ≈ 8.6分になる (計算値)。電解コンデンサの
容量誤差は ±20% ほどあり、漏れでも延びるので、実際の時間は目安。

**30 分たっても LED が消えないとき**は、漏れが充電電流に勝っている。Rt を
2.2MΩ に下げる (充電電流 約4µA、T ≈ 9分) と余裕ができる。40 分ほどの長い
時間が要るなら、単安定で粘らず、555 の発振を 4040 などのカウンタで数える形
(10-4) にするほうが確実。

## 出典

自作。
