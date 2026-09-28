---
book: denken
chapter: 2
id: 2-8
title: 和動接続と差動接続 — コイルの直列で極性を変える
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 2-8 和動接続と差動接続 — コイルの直列で極性を変える

磁気的に結合した 2 つのコイルを直列につなぐと、合わせた L は 2 つの L の和にならない。2 つの磁束が
**強め合う向き** (和動接続) なら相互インダクタンス M の 2 倍だけ増え、**打ち消す向き** (差動接続) なら
2M だけ減る。2-7 の 100 回のコイル 2 つを筒の端で突き合わせ、片方のリードを入れ替えるだけで 2 通りの
L を測る。2 つの差から M が求まる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| L+ = L1 + L2 + 2M | 和動接続 (巻線の始め ● どうしが同じ側) |
| L− = L1 + L2 − 2M | 差動接続 (片方のリードを入れ替える) |
| M = (L+ − L−) / 4 | 2 つの L の差から M を求める |
| k = M / √(L1 L2) | 結合係数 (2-7) |

## 回路図

```circuit
title: 図1 2 つのコイルを直列に (和動接続)
style:
  standard: jis
  pitch: 1.2
parts:
  W1: sine c1 i1 l=$\mathrm{W1}$
  L1: inductor c4 d4 l=$\mathrm{L_1}$
  L2: inductor d4 e4f0 l=$\mathrm{L_2}$
  M1: voltmeter c7 e7f0 l=$\mathrm{CH1}$
  Rr: resistor e4f0 i4 150 l=$\mathrm{R_{ref}}$
  M2: voltmeter e9f0 i9 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c1 -- c4 -- c7
  - e4f0 -- e7f0 -- e9f0
  - i1 -- i4 -- i9
notes:
  - text c4c3 left small: 始め
  - text d4c3 left small: 始め
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/08-series-aiding-opposing.svg)

- L1・L2 は 2-7 の 100 回のコイル (95.9 µH ずつ)。筒を一直線に並べ、端を突き合わせる (k = 0.125)
- 図の「始め」は巻線の始め (試験の図では ● で描く)。L1 の終わりを L2 の始めにつなぐと、同じ向きの電流が同じ向きの磁束を作る (和動)。
  L2 の 2 本のリードを入れ替えると差動になる
- W1 は 100 kHz、振幅 1 V。CH1 は 2 つのコイルの両端 (差動)、CH2 は R<sub>ref</sub> = 150 Ω の両端 (GND 基準)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1・L2 | 手巻きのコイル | 2-6・2-7 の 100 回のコイル 2 つ (直径 20 mm の紙筒、φ0.3 mm を 33 mm に 100 回、95.9 µH、巻線の抵抗 1.55 Ω) |
| Rref | 抵抗 (1/4 W) | 150 Ω |

コイルを巻くとき、始めのリードに印 (テープなど) を付けておく。筒は同じ向き (始めが左) にそろえて並べる。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (和動接続)
board: half
parts:
  Rr: resistor h12 h17 150
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
  L1:
    type: device
    at: bottom
    label: "L1 (100 回、始め ●)"
    pins: ["●", "終"]
  L2:
    type: device
    at: bottom
    label: "L2 (100 回、始め ●)"
    pins: ["●", "終"]
wires:
  - AD.W1 -- a3 yellow
  - AD.1+ -- b3 orange
  - AD.1- -- c12 white
  - AD.2+ -- d12 blue
  - AD.2- -- -t20 black
  - AD.GND -- -t22 black
  - e3 -- f3 yellow
  - L1.● -- j3 yellow
  - L1.終 -- i7 green
  - L2.● -- j7 green
  - L2.終 -- j12 white
  - e12 -- f12 white
  - j17 -- -b17 black
  - -t28 -- -b28 black
notes:
  - text: "差動接続は L2 の 2 本 (7 列と 12 列) を入れ替える"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/08-series-aiding-opposing.svg)

- 3 列が W1 と L1 の始め (溝をまたぐ黄色の線で上下をつなぐ)
- 7 列 (下) で L1 の終わりと L2 の始めがつながる。12 列が L2 の終わりと R<sub>ref</sub> の上
- R<sub>ref</sub> の下 (17 列) は下の − レールへ。上下の − レールは 28 列でつなぐ
- CH1 は 3 列 (1+) と 12 列 (1−)、CH2 は 12 列 (2+) と − レール (2−)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、100 kHz、Amplitude 1 V |
| Scope | CH1 = 2 つのコイル (差動、500 mV/div)、CH2 = Rref (500 mV/div)。Time base 2 µs/div |
| Measure | CH1・CH2 の Amplitude と、CH2 の CH1 に対する Phase。L = V_L sin θ / (ω I)、I = CH2 / 150 Ω |

和動接続の画面。差動接続では CH1 が 0.567 V に下がり、CH2 が 0.807 V に上がる。

```scope
title: 図3 和動接続 — コイルの電圧 0.663 V、電流の分 0.733 V
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 100kHz 663mV, range: 500mV/div}
ch2: {wave: sine 100kHz 733mV phase -88.7deg, range: 500mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/scope/08-series-aiding-opposing.svg)

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。AD の CH1 は 2 つのコイルの両端を差動で
挟み、1− は 12 列 (GND ではない) に当たる。

2-6 と同じく、**回路はそのままで、CH1 の先端を 3 列 (コイルの上)、CH2 の先端を 12 列 (コイルの下 =
R<sub>ref</sub> の上) に当て、コイルの電圧は Math の CH1 − CH2** で出す。グランドクリップは 2 本とも − レール。
差 (0.66 V) は CH1 の振れ (約 1 V) の 6 割あり、8 bit でも埋もれない。回路は 2-6 の図3 の L<sub>x</sub> を
L1 と L2 の直列にしたもので、ブレッドボードは 1− の白い線 (c12) が要らなくなるだけで、CH1 は 1+ の橙の線の所 (3 列)、CH2 は 2+ の青い線の所 (12 列) に当てる。

- FG は High-Z、Sine、100 kHz、振幅 1 V。負荷は約 200 Ω なので、FG の 50 Ω で振幅は 8 割ほどに
  下がる (計算値)。電圧と電流の比 (L) は変わらない

## 見るべき値

計算値 (L1 = L2 = 95.9 µH、M = 12.0 µH、巻線の抵抗は 2 つで 3.1 Ω、100 kHz、W1 は振幅 1 V)。

| 測る所 | 和動接続 | 差動接続 |
| --- | --- | --- |
| 合わせた L (計算) | L+ = 215.8 µH | L− = 167.8 µH |
| X = ωL | 135.6 Ω | 105.4 Ω |
| CH2 (Rref、振幅) | 0.733 V (I = 4.89 mA) | 0.807 V (I = 5.38 mA) |
| CH1 (コイル、振幅) | 0.663 V | 0.567 V |
| 位相差 (電流の遅れ) | 88.7° | 88.3° |
| M = (L+ − L−) / 4 | 12.0 µH | ← |
| k = M / L1 | 0.125 (2-7 の d = 0 と同じ) | ← |

分かること:

- **リードを入れ替えるだけで L が 48 µH 変わる。** 和動は結合のない和 (191.8 µH) より 2M = 24 µH 大きく、
  差動は 24 µH 小さい
- 和動と差動の 2 回の測定から M が出る。2-7 のように 2 つめのコイルの電圧を測らなくてもよい
- 2-6 の 200 回のコイル (2 層) は、2 つの巻線を**重ねて和動に**つないだもの。重ね巻きは k ≈ 0.97 なので、
  L+ ≈ 4 L1 (389 µH) になる。同じ重ね巻きを差動にすると、L− は数 µH まで下がる (磁束がほぼ打ち消し合う)。
  電流を打ち消す巻き方は、無誘導巻きの抵抗や、コモンモードチョークに使われる
- 電験の問題は ● (極性) の向きで和動か差動かを読ませる。● から電流が入る向きが 2 つとも同じなら和動

## 出典

自作。M は 2-7 と同じ計算 (輪の並びとみてノイマンの式で足し合わせた)。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
