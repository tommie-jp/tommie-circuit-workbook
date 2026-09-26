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
    at: a1
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 100k
  R2: resistor c6 c9 100k
  Cin: capacitor f3 f6 1u
  U1: opamp i6 LM358
  Rf: resistor c14 f14 10k
  Rg: resistor f14 f17 1k
  Cg: capacitor f17 i17 10u
  G1: ground i17
  G2: ground c9
wires:
  - AD.V+ -| c3
  - AD.W1 |- f3
  - f6 -- c6
  - AD.1+ -| c6
  - U1.+ |- c6
  - U1.- |- f14
  - U1.out |- c14
  - AD.2+ -| c14
  - AD.1- -| c9
  - AD.2- -| c9
  - AD.GND -| c9
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
board: full
parts:
  U1: dip8 @ e5 LM358
  R1: resistor d35 d30 100k
  R2: resistor e30 e25 100k
  Cin: capacitor/ceramic b27 b30 1u
  Rf: resistor j5 j6 10k
  Rg: resistor i6 i9 1k
  Cg: capacitor/electrolytic h9(+) h12(-) 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - a5 -- +t5 red
  - j8 -- -b8 black
  - c35 -- +t35 red
  - c25 -- -t25 black
  - c30 -- g7 orange
  - AD.W1 -- a27 yellow
  - AD.1+ -- a30 orange
  - AD.2+ -- i5 gray
  - AD.1- -- -t8 black
  - AD.2- -- -t9 black
  - i12 -- -b12 black
  - +t50 -- +b50 red
  - -t50 -- -b50 black
  - c6 -- c7 green
  - a8 -- -t7 black
```

- LM358 (`U1`) は 8=VCC (e5)・4=GND (f8)。1=OUT1 (f5)・2=IN1− (f6)・3=IN1+ (f7)
  だけを使う
- 使わない 2 回路目は浮かせず**フォロワにして入力を固定する**: 7=OUT2 (e6) と
  6=IN2− (e7) を緑の線で短絡し (`c6 -- c7`)、5=IN2+ (e8) を GND へ落とす
  (`a8 -- -t7`)。浮いたままだと発振や余計な電流の元になる (9-3〜9-5 も同じ)
- 分圧・結合コンデンサ (R1・R2・Cin) は**チップの胴に重ならないよう**上ブロックの
  遠い列へ逃がし、橙の線で 3=IN1+ へ橋渡しする (9-1 と同じ考え方)
- 帰還 (Rf・Rg・Cg) はチップのすぐ下 (i・j 行) の空いた列で組む

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
