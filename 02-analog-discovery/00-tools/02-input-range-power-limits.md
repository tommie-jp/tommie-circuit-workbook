---
book: analog-discovery
chapter: 0
id: 0-2
title: 入力範囲 ±25 V と電源の限界 — 電流は直列抵抗で決める
tier: 50
source: 自作
board: —
---

# 0-2 入力範囲 ±25 V と電源の限界 — 電流は直列抵抗で決める

Analog Discovery を壊さないための 2 つの上限を確かめる。**入力**
(オシロの 1+ / 1- など) は GND に対して ±25 V まで。**電源**
(Supplies) は USB 給電のとき 1 系統あたり 250 mW まで。

Supplies の画面には Master Enable・Positive Supply／Negative Supply の
Enable・出力電圧・Tracking はあるが、**mA 単位で電流を決める Current Limit
という設定項目は無い**（AD2・AD3 とも）。内部にはハードウェアの固定した
過電流しきい値があるが、これは USB 給電を守るための値（AD2 で合計 300 mA
前後、外部給電なら 1.4 A 超）で、LED の定格 (20 mA) よりずっと高く、
**LED を守る役には立たない**——切れる前に LED のほうが先に壊れる。したがって
LED の電流は、昔からの標準的な方法である**直列抵抗**で決める（回路の
教科書の 1-1 と同じ考え方）。実機で電圧と抵抗を組み合わせて電流を確かめる
詳しい手順は 1-8 で扱う。

## 回路図

```circuit
title: 図1 抵抗を直列に入れて LED を V+ につなぐ
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 330
  D1: led a3 a5 v=VF
  G1: ground c1
wires:
  - a5 -- c1
```

V+（Supplies、5 V）→ R1（330 Ω）→ LED → GND。抵抗を入れずに LED を V+ に
直結すると、LED の順方向抵抗はごく小さいので大電流が流れ、LED か AD 自体を
壊す恐れがある——**これは実機では試さない**。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |

## 見るべき値

LED の V<sub>F</sub> ≈ 2.0 V と仮定。電流 = (V+ − V<sub>F</sub>) ÷ 330 Ω。

| 測る所 | 期待する値（計算値） | 分かること |
| --- | --- | --- |
| LED の順方向電圧 | 約 2.0 V | 抵抗と電圧の組み合わせで決まる、ほぼ一定の値 |
| LED に流れる電流 | 約 **9.1 mA**（= (5 − 2.0) / 330） | LED の定格 (20 mA 前後) に対して十分小さく、余裕がある |
| V+ が使う電力 | 約 45.5 mW（= 5 V × 9.1 mA） | Supplies の上限 (USB 給電で 1 系統 250 mW) に対して十分小さい |
| ±25 V の入力範囲との比較 | 今回の回路は最大 5 V | オシロの入力レンジ (±25 V) に対して十分小さく、壊れる心配は無い |

Supplies に Current Limit という設定が無い以上、**抵抗を省いてよい場面は
無い**。同じ抵抗のまま V+ の電圧を変えると電流が変わることは 1-8 で
確かめる。

## 出典

自作。Supplies の操作 (Master Enable・Positive Supply・Negative Supply・
Voltage・Tracking) は Digilent の
[Using the Power Supplies](https://digilent.com/reference/test-and-measurement/guides/waveforms-supplies)。
Current Limit という設定項目が無いことと AD2 のハードウェア過電流しきい値
(USB 給電で合算約 290 mA、外部給電で約 1.45 A) は
[Analog Discovery 2 リファレンスマニュアル](https://digilent.com/reference/test-and-measurement/analog-discovery-2/reference-manual)
§6.3 (User Supply Control)・§6.4 (User Voltage Supplies) による。AD3 に
current limiting が無いことは Digilent フォーラムでの記載による。
