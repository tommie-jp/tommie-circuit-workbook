---
book: analog-discovery
chapter: 9
id: 9-2
title: オペアンプの GBW とスルーレート
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 9-2 オペアンプの GBW とスルーレート

LM358 の非反転増幅 (利得 11 倍) を組み、**Network** で −3 dB 帯域を測って
GBW (利得帯域幅積) を確かめる。続けて **Wavegen で方形波**を入れ、出力の
立ち上がりがスルーレートで頭打ちになる様子を見る。同じ回路で 2 つの限界
(帯域とスルーレート) のどちらが効くかを切り分けるのがこの題の目的。

## 回路図

```circuit
title: 図1 LM358 非反転増幅 (単電源、利得 11 倍)
parts:
  AD:
    type: device
    at: f2
    label: Analog Discovery
    pins: [2+, V+, W1, 1+, 1-, 2-, GND]
    turn: mirror
  R1: resistor c11 e11 100k
  R2: resistor e11 g11 100k
  Cin: capacitor e6 e8 1u
  U1: opamp e14d0f0 +up LM358
  Rf: resistor g17 g13 10k
  Rg: resistor g13 i13 1k
  Cg: capacitor i13 k13 10u
  G1: ground k13
  G2: ground g11
  G3: ground h5
wires:
  - AD.V+ -| c5
  - c5 -- c11
  - AD.W1 -| e6
  - e8 -- e9 -- e11
  - AD.1+ -| e9
  - e11 -| U1.+
  - U1.- -| g13
  - U1.out -| g17
  - AD.2+ -| b4
  - b4 -- b18 -- g18
  - g17 -- g18
  - AD.GND -| h4
  - AD.2- -| h5
  - AD.1- -| h6
  - h4 -- h5 -- h6
style:
  pitch: 1.2
```

- R1・R2 (100 kΩ) が **Vcc/2 のバイアス**、Cin (1 µF) が W1 を交流だけ重ねる
  結合コンデンサ
- Rg (1 kΩ) は Cg (10 µF) で交流だけ GND に落とす。直流の帰還利得は 1 倍
  (Vout の直流 = V+ の直流 = Vcc/2) のまま、**交流の利得だけ 1 + Rf/Rg = 11 倍**
- 1+ が入力 (バイアス点)、2+ が出力。単電源なので 1−・2− は GND のままでよい
  (交流成分だけを見る)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8 @ e12 r180 LM358
  Cin: capacitor/ceramic a5 a8 1u
  R1: resistor c3 c8 100k
  R2: resistor d8 d12 100k
  Rf: resistor h17 h20 10k
  Rg: resistor i20 i24 1k
  Cg: capacitor/electrolytic g24(+) g27(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t4 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a13 orange
  - AD.1- -- -t10 black
  - AD.2+ -- a17 gray
  - AD.2- -- -t19 black
  - a3 -- +t3 red
  - b8 -- b13 orange
  - a12 -- -t12 black
  - b15 -- b17 gray
  - c14 -- c20 green
  - e17 -- f17 gray
  - e20 -- f20 green
  - j12 -- -b12 black
  - g13 -- g14 green
  - j15 -- +b15 red
  - j27 -- -b27 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
```

- LM358 (`U1`) は `r180` で置き、使う 1〜4 番を上ブロックに揃える:
  4=GND (e12)・3=IN1+ (e13)・2=IN1− (e14)・1=OUT1 (e15)。8=VCC (f15) は +b へ
- 使わない 2 回路目は浮かせず**フォロワにして入力を固定する**: 7=OUT2 (f14) と
  6=IN2− (f13) を緑の線で短絡し (`g13 -- g14`)、5=IN2+ (f12) を GND へ落とす
  (`j12 -- -b12`)。浮いたままだと発振や余計な電流の元になる (9-3〜9-5 も同じ)
- 分圧・結合コンデンサ (R1・R2・Cin) は**チップの胴に重ならないよう**左の上ブロックで
  組み、節点 (8 列) を橙の線 (`b8 -- b13`) で 3=IN1+ へ橋渡しする。R2 の GND 側は
  4=GND と同じ 12 列に挿す
- 帰還 (Rf・Rg・Cg) は右の下ブロックで組む。1=OUT1 を `b15 -- b17` と溝越しの
  `e17 -- f17` で 17 列へ、2=IN1− を `c14 -- c20` と `e20 -- f20` で 20 列へ下ろし、
  その間に Rf を挿す。上下のレールは 29・30 列で渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Network (GBW 測定) | 掃引 100 Hz〜1 MHz、点数 101、振幅 20 mV、Reference = CH1、DUT = CH2 |
| Wavegen (スルーレート測定) | W1: Square、1 kHz、Amplitude 136 mV (出力 3 Vpp 相当)、Offset 0 V |
| Scope (スルーレート測定) | CH2 の立ち上がり時間を Measurements で読む |

## 見るべき値

計算値。LM358 の代表値: GBW ≈ 1 MHz、スルーレート SR ≈ 0.3 V/µs (データシート
の代表値)。

| 項目 | 計算値 | 分かること |
| --- | --- | --- |
| 交流利得 Av = 1 + Rf/Rg | 11 倍 (20.8 dB) | 帰還抵抗の比だけで決まる |
| 予想 −3 dB 帯域 = GBW / Av | 90.9 kHz | GBW が一定なら利得を上げるほど帯域が狭くなる |
| 帯域だけで決まる立ち上がり時間 (0.35/BW) | 3.85 µs | もしスルーレートが無限なら、これだけの時間で 3 V 変化するはず |
| 必要な傾き (3 V / 3.85 µs) | 0.78 V/µs | **LM358 の SR (0.3 V/µs) を超えている** |
| 実際の立ち上がり時間 (ΔV / SR = 3 V / 0.3 V/µs) | **10 µs** | 帯域予想の 2.6 倍も遅い — **スルーレートが効いている** |

**利得 11 倍という中途半端な設定でも、出力振幅が数 V あればすぐスルー律速になる。**
GBW から予想した帯域と実際の立ち上がりが合わないときは、振幅を絞ってスルーレートの
影響を消してから帯域だけを測り直すとよい。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
LM358 の GBW・スルーレートはメーカーのデータシートの代表値。
