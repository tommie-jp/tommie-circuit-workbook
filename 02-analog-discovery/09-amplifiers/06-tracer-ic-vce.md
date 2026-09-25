---
book: analog-discovery
chapter: 9
id: 9-6
title: "Tracer でトランジスタの Ic–Vce 曲線"
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
device: AD3
---

# 9-6 Tracer でトランジスタの Ic–Vce 曲線

AD3 の **Tracer** (カーブトレーサ) は、ベース電流 Ib を数段階に自動で振りながら
Vce を掃引し、Ic–Vce の特性曲線を家族 (ファミリー) で描いてくれる。**AD2 には
Tracer が無い**ので、ここでは Ib を固定した状態で Vce だけを掃引する
「手動の 1 本」を、Ib を替えて何度か繰り返す方法を説明する — 2-13 で
ダイオードの順方向特性を XY 表示で描いたのと同じ考え方を、3 端子に広げたもの。
Tracer はこれを自動でまとめて重ねて描く。

## 回路図

```circuit
title: 図1 Vce を掃引し、Ib を数段階に固定して測る (AD2 でもできるやり方)
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
  Rb: resistor a5 c5 220k
  Q1: npn f9 2SC1815
  Rs: resistor c15 c18 100
  G1: ground f18
wires:
  - AD.V+ -| a5
  - c5 |- Q1.B
  - AD.W1 -| c15
  - AD.1+ -| c15
  - c18 |- Q1.C
  - AD.1- -| c18
  - AD.2+ -| c18
  - Q1.E -| f18
  - AD.2- -| f18
  - AD.GND -| f18
```

- Rb (220 kΩ) がベース電流を決める。Vcc = 5 V、Vbe ≒ 0.7 V とすると
  Ib = (5 − 0.7) / 220 k ≒ 19.6 µA。**別の値に差し替えて Ib を数段階に振る**
  (下の表)
- W1 は 0〜5 V の三角波 (Offset 2.5 V、振幅 2.5 V) にして、コレクタ側を
  Rs (100 Ω、電流検出用) 経由で掃引する。1+ が Vce 側、2+ が Rs の両端 (Ic に比例)
- Rs は 6-1 などと同じ「基準抵抗」の考え方 — Ic = (2+ の読み) / Rs

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rb: resistor c5 c10 220k
  Q1: transistor h9(B) h10(C) h11(E) 2SC1815
  Rs: resistor d15 d20 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t2 red
  - b5 -- +t5 red
  - AD.GND -- -t3 black
  - -t25 -- -b25 black
  - b10 -- g9 orange
  - AD.W1 -- a15 yellow
  - AD.1+ -- b15 orange [h5]
  - c20 -- g10 gray
  - AD.1- -- e20 white [h5]
  - AD.2+ -- b20 purple [h5]
  - AD.2- -- -t18 black
  - i11 -- -b11 black
```

- Q1 の並びは平らな面を左に見て B・C・E (9-1 と同じ 2SC1815)。ベース (Rb 経由)、
  コレクタ (Rs・W1 経由)、エミッタ (GND) の 3 本を橙・灰の線で上ブロックへ渡す
- Rb を差し替えるたびに、その先の配線はそのまま (220 k → 470 k → 100 k の
  順に挿し替えるだけでよい)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| AD3 (Tracer) | DUT 種別 = NPN トランジスタ、Ib を 3 段階 (自動)、Vce 掃引 0〜5 V |
| AD2 の代わり | Wavegen: W1 Triangle、Offset 2.5 V、振幅 2.5 V、10 Hz (ゆっくり)。Scope: XY モード (CH1 = Vce、CH2 = Rs の両端)。Rb を差し替えて 3 回繰り返す |

## 見るべき値

計算値。Vcc = 5 V、Vbe = 0.7 V、hFE = 200 と仮定 (9-1 と同じ仮定)。
Vce が十分大きい領域では Ic ≒ hFE × Ib で頭打ちになるとみなす。

| Rb | Ib (計算値) | Ic = hFE × Ib (計算値) |
| --- | --- | --- |
| 470 kΩ | 9.15 µA | 1.83 mA |
| 220 kΩ | 19.55 µA | 3.91 mA |
| 100 kΩ | 43.0 µA | 8.60 mA |

**Vce が小さい所 (0〜0.2 V 付近、飽和領域)** では、Ic は Vce にほぼ比例して
立ち上がり、Vce ≒ 0.2 V (2SC1815 の代表的な Vce(sat)) を超えたところから
上の表の値でほぼ平らになる — これが Ic–Vce 曲線の「膝」。**Ib を変えるたびに
この平らな部分の高さが変わり、間隔がほぼ等しければ hFE がほぼ一定**だと
確かめられる。Tracer を持つ AD3 ならこの 3 本 (またはもっと細かい段階) を
自動で重ねて 1 枚の図にしてくれる。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Tracer の節)。AD2 での代用は 2-13 (ダイオードの順方向特性を XY で描く) と
同じ考え方の応用。
