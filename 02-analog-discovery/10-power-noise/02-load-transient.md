---
book: analog-discovery
chapter: 10
id: 10-2
title: 負荷過渡応答
tier: 100
source: 自作 (計器の操作は Digilent の Using the Oscilloscope と Using the Waveform Generator)
board: BB
---

# 10-2 負荷過渡応答

10-1 と同じブリッジ整流・平滑回路に、**2N7000 で on/off するもう 1 つの負荷**
(470 Ω) を足す。この負荷が急に加わった瞬間、平滑コンデンサの電圧がどれだけ
沈み込み、リップルがどう増えるかを Scope の時間軸で見る。AD はこの回路に
電力を供給しない (10-1 と同じ) — 見ているだけ。

## 回路図

```circuit
title: 図1 ブリッジ整流・平滑と、切り替えできる追加負荷
parts:
  V1: sine a5 e5 12.7
  D1: diode a5 a9 1N4007
  D2: diode e5 a9 1N4007
  D3: diode e12 a5 1N4007
  D4: diode e12 e5 1N4007
  Csmooth: capacitor a9 e12 470u
  Rload: resistor h9 h12 1k
  Radd: resistor k25 k28 470
  Q1: nmos-e n28 2N7000
  Rg: resistor n3 n9 1k
  Rgpd: resistor n9 q9 100k
  AD:
    type: device
    at: q1
    label: Analog Discovery
    pins: [GND, W2, 1+, 1-, 2+, 2-]
wires:
  - a9 -- h9
  - h9 -- k25
  - e12 -- h12
  - h12 -- q9
  - AD.1+ |- h9
  - AD.1- -| h12
  - AD.W2 -| n3
  - n9 |- Q1.G
  - k28 |- Q1.D
  - Q1.S -| q9
  - AD.2+ -| n9
  - AD.2- -| q9
  - AD.GND -| q9
```

- Radd (470 Ω) と Q1 (2N7000) が直列で Rload と並列に入る、**切り替えられる
  追加負荷**。Q1 の G を W2 (0〜5 V の方形波) で開け閉めする
- Rg (1 kΩ) はゲート電流の制限、Rgpd (100 kΩ) はゲートのプルダウン
  (W2 が出ていない間、ゲートを浮かせない)
- 1+ が出力電圧 (Rload の両端)、2+ が Q1 のゲート (スイッチのタイミング確認用)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (10-1 に追加負荷を足す)
board: full
parts:
  ADP:
    type: device
    at: top
    label: AC アダプタ 9V
    pins: ["~1", "~2"]
  D1: diode/do41 c5(A) c12(K)
  D2: diode/do41 d8(A) d12(K)
  D3: diode/do41 e3(A) e5(K)
  D4: diode/do41 b3(A) b8(K)
  Rload: resistor j12 j3 1k
  Csmooth: capacitor/electrolytic i12(+) i3(-) 470uF
  Radd: resistor f16 f20 470
  Q1: transistor h22(S) h23(G) h24(D) 2N7000
  Rg: resistor f28 f23 1k
  Rgpd: resistor j23 j27 100k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [GND, W2, 1+, 1-, 2+, 2-]
wires:
  - ADP.~1 -- a5
  - ADP.~2 -- a8
  - d3 -- f3
  - e12 -- g12
  - h3 -- -b3 black
  - h12 -- g16
  - g20 -- g24
  - i22 -- -b22 black
  - i27 -- -b27 black
  - AD.1+ -- f12
  - AD.1- -- g3
  - AD.2+ -- g23
  - AD.2- -- -b6
  - AD.GND -- -b5
  - AD.W2 -- g28
```

- Q1 (2N7000) は TO-92、**平らな面を見て左から S・G・D** (01-circuits の
  2-5 と同じ実物の並び) を 22・23・24 列に挿す。D (24 列) に Radd (16〜20 列)
  の先 (20 列) を渡し、S (22 列) は下の − レールへ落とす。G (23 列) が Rg
  (28 列から W2) と Rgpd (27 列から − レール) の節点で、2+ もここで読む
- 整流部・Rload・Csmooth は 10-1 と同じ配置 (DC+ が 12 列、DC− が 3 列)。
  DC− (3 列) を下の − レールにつなぎ、AD の GND・2− と Q1 の S をそこへ集める。
  1+ は DC+ (12 列)、1− は DC− (3 列) で、10-1 と同じ極性
- Radd と Q1 のぶんだけ下ブロックの右に足す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W2: Square、**2 Hz**、Offset 2.5 V、振幅 2.5 V (0〜5 V のスイッチ) |
| Scope | CH1 = Rload の両端 (出力電圧)、CH2 = Q1 のゲート。トリガ = CH2 の立ち上がり、Single または Normal |
| 時間軸 | 50 ms/div 程度 (2 Hz の 1 周期 500 ms の一部が見える範囲) |

## 見るべき値

計算値。10-1 と同じ V<sub>DC</sub> ≒ 11.3 V (9 V<sub>rms</sub> のピークからダイオード
2 段ぶんを引いた値)、C = 470 µF、リップル周波数 120 Hz (60 Hz 地域)。

| 状態 | 負荷抵抗 | 平均電流 | リップル (peak-to-peak) |
| --- | --- | --- | --- |
| Q1 off (Rload だけ) | 1 kΩ | 11.3 mA | 約 201 mV (10-1 と同じ) |
| Q1 on (Rload ∥ Radd) | 320 Ω | 35.4 mA | 約 628 mV |

Q1 が on になった瞬間の**追加の沈み込み**は、増えた電流ぶん (35.4 − 11.3 =
24.1 mA) がそのままリップルの式に乗る形で計算できる。

ΔV ≒ ΔI / (f<sub>ripple</sub> × C) = 24.1 mA / (120 Hz × 470 µF) ≒ **427 mV**。

**Q1 が on になった瞬間、出力は 1 リップル周期 (約 8.3 ms) のうちに新しい
低いレベルまで沈み、そこから先は増えたリップル (約 628 mV<sub>pp</sub>) の
上を往復する。** レギュレータの無いこの電源では「元の電圧に戻る」ことは無く、
**新しい (低い) 平均値のまま**になる — 巻き線抵抗ぶんの追加の低下もあるはず
だが、変圧器の内部インピーダンスが分からないので定量化はしない (仮定を
増やさないための注記)。レギュレータを挟んだときの過渡応答は 10-3 (PSRR) の
続きで扱う。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)
と
[Using the Waveform Generator](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)。
