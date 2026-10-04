---
book: denken
chapter: 2
id: 2-10
title: ホール効果 — ホール素子で磁束密度を測る
tier: 100
source: 自作 (ホール IC の特性は Allegro A1324 のデータシート)
board: BB
---

# 2-10 ホール効果 — ホール素子で磁束密度を測る

電流の流れる半導体のブレッドボードに、ブレッドボードと垂直に磁界を掛けると、流れる電荷がローレンツ力で片側へ寄り、電流とも
磁界とも直角の向きに電圧が出る (**ホール効果**)。その電圧 (ホール電圧) は磁束密度 B に比例するので、
B を測る計器になる。ここでは、ホール素子に増幅器を組み込んだ**リニアホール IC** (A1324) を使い、
2-6 の 200 回のコイルの中に置く。コイルの電流から式で出した B と、IC の出力から読んだ B を比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_H = R_H I B / d | ホール電圧。R_H はホール係数、I は素子の電流、d はブレッドボードの厚さ。B に比例する |
| Vout = Vcc / 2 + S B | A1324 の出力。B = 0 で 2.5 V、感度 S = 5.0 mV/G = 50 mV/mT (5 V のとき) |
| B = μ0 N I / √(l² + D²) | 有限の長さ l・直径 D のソレノイドの中心の磁束密度 |
| B = (Vout − 2.5 V) / S | 出力から磁束密度を読む |

1 mT = 10 G (ガウス)。

## 回路図

```circuit
title: 図1 ホール IC (左) とコイルの電流 (右)
style:
  standard: jis
  pitch: 1.2
parts:
  U1:
    type: ic3
    at: e5
    label: A1324
    pins: [VCC, GND, VOUT]
  VCC: vcc b3 5V
  C1: capacitor c1 g1 100n
  M1: voltmeter e7 h7 l=$\mathrm{CH1}$
  G1: ground h3
  B1: battery e11 i11 3
  S1: switch e11 e13
  R1: resistor e13 e15 10
  A1: ammeter e15 e17
  L1: inductor e19 i19 l=$\mathrm{L_1}$
wires:
  - b3 -- c3 -- c1
  - c3 |- U1.VCC
  - U1.GND -| h3
  - g1 -- h1 -- h3 -- h7
  - U1.VOUT -| e7
  - e17 -- e19
  - i11 -- i19
notes:
  - text e19f5 left small: 200 回 (U1 は筒の中)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/10-hall-effect.svg)

- VCC は AD の Supplies (V+ = 5 V)。A1324 の電流は 6.9 mA ほど。C1 (0.1 µF) は電源のピンのすぐそばに置く
- CH1 は U1 の出力 (GND 基準)。B = 0 で 2.5 V
- 右はコイルの電流の回路 (2-4 と同じ 3 V・10 Ω)。L1 は 2-6 の 200 回のコイル。A1 (テスターの 10 A レンジ) で電流を読む
- U1 は 3 本の線で延ばし、**印字の面をコイルの軸に直角にして**筒の真ん中に入れる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | リニアホール IC | A1324LUA-T (3 ピン、UA パッケージ)。印字の面を手前にして左から 1 VCC・2 GND・3 VOUT。感度 5.0 mV/G (4.75〜5.25) |
| C1 | セラミックコンデンサ | 0.1 µF |
| L1 | 手巻きのコイル | 2-6 の 200 回のコイル (直径 20 mm の紙筒、φ0.3 mm を 33 mm に 2 層、抵抗 3.2 Ω) |
| R1 | 抵抗 1 W | 10 Ω (0.48 W) |
| S1 | スイッチ | 1 A 以上 |
| B1 | 電池 | 3 V (単 3 を 2 本) — 0.2 A 余りを流すので R1 の発熱を抑えるため 5 V にしない (2-4 と同じ理由)。U1 の 5 V は AD の Supplies |

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  C1: capacitor c16 c19 100n
  S1: switch h3 h6
  R1: resistor f6 f11 10
  U1:
    type: device
    at: top
    label: A1324 (筒の中)
    pins: [VCC, GND, VOUT]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [1+, 1-, GND, V+]
  BAT:
    type: device
    at: bottom
    label: 単3電池 2本 3V
    pins: ["-", "+"]
  AM:
    type: device
    at: bottom
    label: "テスター (DC 10A)"
    pins: [A, COM]
  L1:
    type: device
    at: bottom
    label: コイル 200回
    pins: ["1", "2"]
wires:
  - U1.VCC -- +t3 red
  - U1.GND -- -t5 black
  - U1.VOUT -- a8 orange
  - AD.1+ -- b8 orange
  - AD.1- -- -t10 black
  - AD.GND -- -t12 black
  - AD.V+ -- +t14 red
  - a16 -- +t16 red
  - a19 -- -t19 black
  - BAT.- -- -b2 black
  - BAT.+ -- j3 red
  - AM.A -- j11 orange
  - AM.COM -- i14 orange
  - L1.1 -- j14 green
  - L1.2 -- -b20 black
notes:
  - text: "上: U1 の電源と出力 (5 V は AD の V+)"
  - text: "下: コイルの電流 (3 V の電池。下の − レールは電池の −)"
  - text: "U1 は 3 本の線で延ばしてコイルの筒の中へ。C1 は U1 のピンの近くに付けてもよい"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/10-hall-effect.svg)

- 上の + レールが AD の 5 V、上の − レールが GND。C1 はレールの間 (16 列と 19 列)
- U1 の出力は 8 列。CH1 (1+) も 8 列
- 下はコイルの回路で、上とはつながらない。電池 + → 3 列 → S1 → 6 列 → R1 → 11 列 → テスター → 14 列 → コイル → 下の − レール → 電池 −
- 電流の向きを逆にするときは、コイルの 2 本の線 (14 列と − レール) を入れ替える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。Enable してから Master Enable |
| Scope | CH1 = U1 の出力。DC、20 mV/div、Offset −2.5 V (2.5 V を画面の中央に)、Time base 10 ms/div |
| Measure | CH1 の Average。U1 の雑音 (7 mVpp) を平均で消す |
| テスター | 直流電流レンジ (10 A)。コイルの電流 |

手順: 1) S1 を開いて Average を読む (B = 0 の値、2.5 V 前後)。2) S1 を閉じて読む。3) 電池の向きを逆にして読む。
各回 5 秒以内。U1 の出力の変化 ΔV を 50 mV/mT で割ると B。

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。CH1 は GND 基準なので回路はそのままでよい。
発振器は使わない。

- AD の V+ は安定化電源の 5 V に替える (電流制限 30 mA。U1 は 9 mA 以下)
- CH1 の先端を 8 列、グランドクリップを上の − レール。DC 結合、20 mV/div にして、位置 (オフセット) で
  2.5 V を画面に入れる。オフセットの幅が足りない機種は、Measure の Mean を 2 V/div のまま読む
  (8 bit では 1 段が約 60 mV で、71 mV の変化が 1 段ほどしか動かない。Average を 64 回以上に)
- テスターの DC V レンジ (1 mV の桁) で 8 列と GND を読んでもよい。DC の読みは平均なので、この題には合う

## 見るべき値

計算値 (N = 200、l = 33 mm、D = 20.7 mm (巻線の中心)、I = 3 V / (10 + 3.2 + 0.5) Ω = 0.22 A、S = 50 mV/mT)。

| 状態 | コイルの電流 | B (式) | U1 の出力 | ΔV = 出力 − 2.5 V |
| --- | --- | --- | --- | --- |
| S1 開 | 0 | 0 | 2.500 V | 0 |
| S1 閉 | +220 mA | 1.42 mT (14.2 G) | 2.571 V | +71.0 mV |
| 電池を逆に | −220 mA | −1.42 mT | 2.429 V | −71.0 mV |
| (参考) 小さなネオジム磁石を筒の口に近づける | — | 数十 mT (目安) | 44 mT を超えると 4.7 V 近くで頭打ち | — |

出力の変化はコイルの電流に比例する (図3)。1 mA あたり 0.323 mV。

```graph
title: 図3 ホール IC の出力の変化はコイルの電流に比例する
x: コイルの電流 mA -300..300
y: 出力の変化 mV -100..100
lines:
  出力の変化 mV: 0.3226 * x
notes:
  - mark -220
  - mark 220
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/graph/10-hall-effect.svg)

分かること:

- **出力の変化は B に比例し、電流の向きを逆にすると符号が逆になる。** ホール電圧は B の向きを持つ
- 式の B (1.42 mT) と、出力から読んだ B (ΔV / 50 mV/mT) が合えば、U1 の感度とコイルの式が両方確かめられる。
  感度の誤差 (±5 %) と巻き方の差で、数 % はずれる
- 無限に長いソレノイドの式 B = μ0 N I / l では 1.68 mT になる。この筒は長さ (33 mm) が直径 (21 mm) の 1.6 倍しか
  なく、端から磁束が逃げる分だけ中心の B は小さい
- U1 の中のホール素子そのものの電圧は数 mV 以下。IC の中で増幅して 5 mV/G にしている。
  ホール素子は電流計 (電線の周りの磁束を測るクランプメータ) や、ブラシレスモータの回転位置の検出に使う
- 地磁気 (0.05 mT ほど) は出力で 2.5 mV。S1 を開いたままで U1 の向きを変えると、わずかに読みが動く

## 出典

自作。A1324 の感度・静止出力・ピンの並び・電流・雑音は Allegro MicroSystems の
[A1324/5/6 データシート](https://www.allegromicro.com/-/media/files/datasheets/a1324-5-6-datasheet.pdf)。
計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Scope の節)。
