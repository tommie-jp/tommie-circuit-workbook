---
book: circuits
chapter: 9
id: 9-15
title: アンテナ — ダイポールとループ、SWR
tier: 200
source: 自作
tools: [VNA]
board: BB
---

# 9-15 アンテナ — ダイポールとループ、SWR

9-2・9-3 のラジオはアンテナに長い線を張るだけだった。中波の波長 (1 MHz で 300 m) に比べて
線がずっと短く、アンテナとしての働きは弱い。ここでは NanoVNA-H4 が得意な **144 MHz 帯
(波長 約 2.07 m)** で、**半波長ダイポール**と**小さなループ**を作り、S11 と SWR で
「アンテナが給電線とどれだけ整合しているか」を測る。この題は**受信と測定だけ**で、
送信はしない (NanoVNA の出力は −10 dBm 前後で、電波法の免許の要らない微弱な測定信号)。

- **半波長ダイポール**: 長さ λ/2 の線を中央で 2 つに切り、切れ目に給電する。
  145 MHz の λ/2 は 299.8 / 145 / 2 = **1.034 m**。線の太さと端の効果で電気的には少し長く見えるので、
  実際は **0.95 倍の 約 0.98 m** (片側 49 cm) で共振する
- 共振点のダイポールは、自由空間で **約 73 Ω の純抵抗** (放射抵抗) に見える。
  **50 Ω の同軸で給電すると SWR は 73 / 50 = 1.46** が最小値になる。
  共振から外れると、短い側は容量性 (X < 0)、長い側は誘導性 (X > 0) になる
- 共振の近くは **直列 RLC** で置き換えられる。R = 73 Ω、Q を 10 と置くと
  L = Q·R / (2πf<sub>0</sub>) = **801 nH**、C = 1 / ((2πf<sub>0</sub>)²L) = **1.504 pF** (図5 の模型)。
  Q は線が細いほど高い (Q = 10 は線径 1〜2 mm のおおよその目安)
- **長さを切り詰める**: 共振周波数は長さにほぼ反比例する。f<sub>0</sub> が 142 MHz と低く出たら
  (2 % 長い)、両側を 1 cm ずつ (0.98 m の 2 %) 切ると 145 MHz に上がる。**切りすぎは戻せない**ので、
  最初は 1 m ほどに作って少しずつ切る
- **1:1 バラン**: 同軸は外皮が地で、中心と外皮で**不平衡**。ダイポールは左右が対称の**平衡**の負荷。
  そのままつなぐと、同軸の外皮の外側にも電流が流れ、給電線まで電波を出して SWR が
  手を近づけるだけで変わる。**給電点の近くで同軸にフェライトコア (FT-37-43 など) を数個通すか、
  同軸を 5〜6 回巻いて (チョーク) 外皮の外側の電流を止める** (1:1 の電流バラン)。
  インピーダンスは変えない
- **小さなループ**: 周長が λ/10 より短いループ (ここでは直径 10 cm) は、放射抵抗がとても小さい。
  R<sub>r</sub> = 31171 × (A / λ²)² (A は面積)。A = π × 0.05² = 7.85 × 10⁻³ m²、λ = 2.07 m で
  **R<sub>r</sub> ≈ 0.10 Ω**。一方、線径 2 mm の銅線の表皮効果の損失抵抗は **約 0.16 Ω** あり、
  **効率は 0.10 / (0.10 + 0.16) ≈ 40 %**。ループそのものは L ≈ 0.25 µH (145 MHz で
  X ≈ 230 Ω) のコイルなので、**約 4.8 pF の同調コンデンサ**で共振させ、さらに小さなループや
  タップで 50 Ω へ合わせる (磁界ループ、マグネチックループ)。**Q が数百と高く、帯域がとても狭い**。
  ループの SWR が下がる幅はダイポールよりはるかに狭く、同調のコンデンサを少し回すだけで外れる

> [!NOTE]
> 送信機をつなぐときは、アマチュア無線の免許と 144〜146 MHz の割り当てが要る。
> 免許の要らない**微弱無線局**は「3 m の距離で電界強度 500 µV/m 以下」(322 MHz 以下) で、
> アンテナを整合させるとこの範囲を超えやすい。この題は NanoVNA の測定信号だけを使う。

## 回路図

```circuit
title: 図1 NanoVNA からバラン経由でダイポールへ
parts:
  J1: sma c2 mirror
  G1: ground d2
  T1: tline c3 c6 50 l=$\mathrm{1m}$
  T2: transformer c8
  G2: ground d7
  ANT1: antenna a11
  ANT2: antenna a13
wires:
  - J1.1 -- c3
  - J1.2 -- d2
  - c6 -| T2.A1
  - T2.A2 -| d7
  - T2.B1 -| a11
  - T2.B2 -| a13
notes:
  - text c1 right: CH0
  - text b11 right small: 片側49cm
  - text b13 left small: 片側49cm
  - text d9 left small: 1:1電流バラン
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/15-antenna-dipole-loop-1.svg)

- J1 は NanoVNA-H4 の CH0 (S11 を測る口)。T1 は給電線の同軸 (50 Ω、1 m)。
  **測る前に、同軸の先 (バランの手前) で OPEN・SHORT・LOAD の校正をする**と、同軸の長さが
  画面から消え、給電点のインピーダンスがそのまま見える
- T2 はバラン。電流バランは実物では「同軸にフェライトを通したもの」で、変圧器の記号は
  **1:1 で平衡と不平衡をつなぎ替える**働きを表す
- ANT1・ANT2 がダイポールの左右の素子 (線径 1〜2 mm の銅線かアルミ棒、片側 49 cm)。
  **一直線に張り**、金属や壁から 1 m ほど離す (近いと f<sub>0</sub> も R も変わる)

共振の近くのダイポールの模型 (図5 の `dut:`)。給電点から見た 1 端子なので、最後を地へ落とす。

```circuit
title: 図2 共振の近くのダイポールの模型 (直列RLC)
parts:
  J1: sma c2 mirror
  G1: ground d2
  R1: resistor c4 c6 73 l=$\mathrm{R_r}$
  L1: inductor c6 c8 801n
  C1: capacitor c8 c10 1.504p
  G2: ground d11
wires:
  - J1.1 -- c4
  - J1.2 -- d2
  - c10 -- c11 -- d11
notes:
  - text b2 center: CH0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/15-antenna-dipole-loop-2.svg)

## 実体配線図

```breadboard
title: 図3 ダイポールの給電点をブレッドボードに組む
board: half
parts:
  CH0:
    type: device
    at: top
    label: CH0 (同軸 1m)
    pins: [外皮, 芯線]
  BL:
    type: device
    at: top
    label: 1:1電流バラン
    pins: [A1, A2, B1, B2]
  ANT1:
    type: device
    at: bottom
    label: 左の素子 49cm
    pins: ["1"]
  ANT2:
    type: device
    at: bottom
    label: 右の素子 49cm
    pins: ["1"]
wires:
  - CH0.芯線 -- a5 yellow
  - CH0.外皮 -- -t4 black
  - BL.A1 -- b5 yellow
  - BL.A2 -- -t9 black
  - BL.B1 -- a14 orange
  - BL.B2 -- a20 blue
  - ANT1.1 -- j14 orange
  - ANT2.1 -- j20 blue
  - e14 -- f14 orange
  - e20 -- f20 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/15-antenna-dipole-loop-1.svg)

- 5 列が同軸の芯線、上の − レールが外皮 (GND)。バランの入り口 (A1・A2) はここにつなぐ
- バランの出口 B1 は 14 列 (橙)、B2 は 20 列 (青)。左右の素子は同じ列の下の段から出す。
  中央の溝は e と f の短い線で渡る
- 実際のバランは**同軸そのものにフェライトを通した物**で、給電点の直前に置く。
  ブレッドボードは試しの給電点で、**ここの線 (数 cm) も素子の一部になる**。f<sub>0</sub> を
  追い込むのは、素子を端子台や基板の切れ端に直にはんだ付けしてからにする

```breadboard
title: 図4 小さなループと同調コンデンサ
board: half
parts:
  CT: capacitor/ceramic c10 c14 4.7p
  LOOP:
    type: device
    at: bottom
    label: ループ 直径10cm
    pins: ["1", "2"]
  CH0:
    type: device
    at: top
    label: CH0
    pins: [外皮, 芯線]
  CPL:
    type: device
    at: top
    label: 結合ループ 直径2cm
    pins: ["1", "2"]
wires:
  - LOOP.1 -- j10 green
  - LOOP.2 -- j14 green
  - e10 -- f10 green
  - e14 -- f14 green
  - CH0.外皮 -- -t17 black
  - CH0.芯線 -- a18 yellow
  - CPL.1 -- b18 yellow
  - CPL.2 -- -t23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/15-antenna-dipole-loop-2.svg)

- ループの両端 (10 列と 14 列) の間に同調の CT (4.7 pF、計算の 4.8 pF に近い E12 の値) を挿す。
  回して合わせるならトリマ (10 pF) に替える
- 結合ループは同軸の芯線 (18 列) と外皮 (− レール) をつなぐ小さな輪で、大きなループの内側に
  寄せて置く。**近づけると結合が強まり、離すと弱まる** — 50 Ω に合う位置を SWR を見ながら探す
- ブレッドボードの浮遊容量 (数 pF) が CT に足されるので、f<sub>0</sub> は計算より低めに出る

## 計器の設定

| 項目 | 設定 |
| --- | --- |
| 計器 | NanoVNA-H4 (CH0 だけ使う) |
| 掃引 | 120〜170 MHz、101 点 |
| 校正 | 同軸の先で OPEN / SHORT / LOAD (CH1 は使わないので THRU は省ける) |
| トレース | S11 SWR、S11 Smith |
| マーカー | 140 MHz、145 MHz、150 MHz |

## 計器の画面

```vna
device: h4
sweep: 120M-170M 101
title: 図5 ダイポール (f0 = 145 MHz) の SWR と Smith
dut:
  - series R 73
  - series L 801n
  - series C 1.504p
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 140M
  - 145M
  - 150M
notes:
  - band 144M 146M: 144 MHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/vna/15-antenna-dipole-loop.svg)

- SWR の谷が f<sub>0</sub>。谷の底は 1 まで下がらず **1.46** (73 Ω と 50 Ω の違い)
- Smith チャートでは、軌跡が実軸 (横の線) を **73 Ω の所**で横切る。下の半分 (f<sub>0</sub> より低い周波数) は
  素子が波長に比べて短く容量性、上の半分 (高い周波数) は長く誘導性
- **谷が帯より低い周波数にあれば長すぎ、高ければ短すぎ**。両側を同じだけ切って、谷を帯に寄せる

## 見るべき値

計算値 (R = 73 Ω、Q = 10 の模型。実物は置き方と線径で変わる)。

| 測る所 | 期待する値 |
| --- | --- |
| SWR の谷の周波数 f<sub>0</sub> | 145 MHz (素子 0.98 m のとき) |
| f<sub>0</sub> の SWR | 1.46 (R = 73 Ω、リターンロス 14.6 dB) |
| 140 MHz の SWR / X | 2.46 / −51 Ω (容量性) |
| 150 MHz の SWR / X | 2.40 / +50 Ω (誘導性) |
| SWR ≤ 2 の幅 | 141.5〜148.6 MHz (約 7 MHz、144〜146 MHz を覆う) |
| 素子が 2 % 長いとき | f<sub>0</sub> ≈ 142 MHz へ下がる |
| バランを外す | 同軸に手を触れると SWR の谷が動く (外皮に電流が流れている) |
| 直径 10 cm のループ | R<sub>r</sub> ≈ 0.10 Ω、損失 約 0.16 Ω、同調 約 4.8 pF、帯域はダイポールよりずっと狭い |

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| ダイポールの素子 | 銅線 (線径 1〜2 mm) またはアルミ棒、片側 約 50 cm | 長めに切って詰める |
| 同軸 | 50 Ω (RG-58 や 1.5D-2V)、約 1 m、SMA オス | NanoVNA の CH0 へ |
| バラン | フェライトコア FT-37-43 やパッチン型を数個 | 給電点の近くの同軸に通す |
| 給電点 | 小さな板 (ラグ板や基板の切れ端) | 左右の素子と同軸の中心・外皮をはんだ付け |
| ループ | 銅線 2 mm、直径 10 cm、トリマ 10 pF | 小さな結合ループで 50 Ω へ |
| 計器 | NanoVNA-H4 | 50 kHz〜1.5 GHz |

## 出典

自作。半波長ダイポールの放射抵抗 73 Ω と小ループの放射抵抗の式
R<sub>r</sub> = 31171 (A/λ²)² は、アンテナの標準的な教科書 (C. A. Balanis, *Antenna Theory*) による。
微弱無線局の電界強度の上限は、電波法施行規則第 6 条による。
