---
book: analog-discovery
chapter: 6
id: 6-8
title: バーアンテナの L と Q
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-8 バーアンテナの L と Q

AM ラジオのフェライトバーアンテナは、フェライト棒に巻いた**コイル**そのもの。
6-3 (10 mH のリード付きインダクタ) と同じ基準抵抗の仕組みで、バーアンテナの
コイル (代表的な値 L ≈ 330 µH) の L と Q を測る。5-21 (バーアンテナ+バリコンの
同調曲線) の下ごしらえになる測定。

## 回路図

```circuit
title: 図1 基準抵抗とバーアンテナのコイル
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 220
  Lant: inductor c9 c12 330u l=$\mathrm{L_{ANT}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- c14
  - AD.GND -| c14
```

- Rref は 220 Ω。**100 kHz** で測るので、XL (約 207 Ω) に近い値を選んだ
- L<sub>ANT</sub> はバーアンテナの巻線 (代表的な値として 330 µH を使う。実物は
  タップ付きのことが多く、ここでは巻線全体の両端を測る)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 220
  Lant:
    type: device
    at: bottom
    label: Bar Antenna
    pins: [A, B]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - Lant.A -- e10 brown
  - Lant.B -- e14 brown
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

- バーアンテナは基板に載る 2 本足の部品ではないので、AD と同じ**板の外の
  機器**として下辺 (`at: bottom`) に描いた。2 本の巻線の端 (A・B) をワイヤで
  10・14 列に渡す
- 配線の考え方は 6-3 と同じ。10 列がコイルと Rref の中点

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**100 kHz**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = L<sub>ANT</sub> の両端。Range は両方 1 V/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

AM 放送帯 (526.5 kHz〜1606.5 kHz、日本) の下のほうで測ると同調前のコイル
単体の様子が見やすいので、あえて 100 kHz を選んだ。

## 見るべき値

計算値。巻線の Q はここでは**目安 Q ≈ 100** と仮定した (バーアンテナの
コイルは一般に Q が高く、100〜300 程度のものが多い。実測で確かめる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| XL = 2πfL (100 kHz) | 207 Ω | 理想のリアクタンス |
| Rs = XL / Q | 2.07 Ω | 巻線抵抗の見積もり |
| CH1 (Rref の両端) | 0.724 V | I ≈ 3.29 mA |
| CH2 (L<sub>ANT</sub> の両端) | 0.683 V、位相 89.4° | \|Z\| ≈ 207 Ω |
| L = \|Z\|sin(89.4°) / ω | 約 330 µH | 表示値どおり |
| Q = XL / Rs | 約 100 | 6-3 (Q ≈ 78.5、10 mH の小型インダクタ) より高い |

分かること:

- **バーアンテナは 6-3 の小型インダクタより Q が高い。** 太い線を大きな
  フェライト棒に巻いてあるぶん巻線抵抗 Rs が小さく、Q = XL/Rs が大きくなる —
  同調回路 (5-21) で鋭い山を作るのに向いている理由
- **100 kHz でもまだ理想的な L として振る舞う** (位相はほぼ 90°)。6-4 で見た
  自己共振はもっと高い周波数 (バーアンテナなら数 MHz 以上) で起きる。AM
  放送帯 (〜1.6 MHz) の中では自己共振の影響は小さい
- 実際のバーアンテナはタップ (中間の引き出し線) を持つことが多く、タップを
  使うとインピーダンス変換 (トランスの巻数比と同じ考え方) ができる —
  5-18 のトランスの周波数特性と同じ仲間

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。バーアンテナの代表的な L (330 µH 前後) と Q の目安は、
一般的な AM ラジオ用フェライトバーアンテナの特性による。
