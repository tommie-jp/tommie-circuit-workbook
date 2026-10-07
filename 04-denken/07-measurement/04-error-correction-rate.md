---
book: denken
chapter: 7
id: 7-4
title: 誤差率と補正率 — 1 % の抵抗を測って計算する
tier: 50
source: 自作
board: BB
---

# 7-4 誤差率と補正率 — 1 % の抵抗を測って計算する

計器で測った**測定値**と、本当の**真の値**とのずれを、誤差・誤差率・補正・
補正率という 4 つの言葉で表す。1 % 級の抵抗 (公称 1 kΩ) を、7-3 と同じ
「電流計が先」のつなぎ方で測り、電流計自身の抵抗による誤差から計算する。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| 誤差 = 測定値 − 真の値 | 測ったときのずれ (符号つき) |
| 誤差率 = 誤差 / 真の値 × 100 % | 真の値を基準にした割合 |
| 補正 = 真の値 − 測定値 (= −誤差) | 測定値を真の値に直すために足す量 |
| 補正率 = 補正 / 測定値 × 100 % | **測定値を基準**にした割合 (誤差率と分母が違う) |

## 回路図

```circuit
title: 図1 電流計が先で Rx を測る
parts:
  V1: vsource 1,1 1,3 5
  Rlim: resistor 1,1 5,1 3.9k
  Ra: resistor 5,1 9,1 100 i=I
  Rx: resistor 9,1 13,1 1k
  G1: ground 1,3
wires:
  - 1,3 -- 13,3
  - 13,1 -- 13,3
style:
  standard: jis
  pitch: 1.3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/04-error-correction-rate-1.svg)

- R_x は公称 1 kΩ (1 % 級) の抵抗。あらかじめ精密な方法 (7-10 の 4 端子法など)
  で真の値を測ると **992 Ω** だったとする (公称の −0.8 %、1 % の規格内)
- R_a (100 Ω) は電流計の内部抵抗の模型。実物は 1 Ω に満たないが、誤差率と補正率の
  違いが数字に出るように、模型はわざと大きくしてある。7-3 の「電流計が先」と同じ
  つなぎ方で、電圧計は R_a + R_x の両端 (R_a の左端、GND 基準) にかける
- R_lim (3.9 kΩ) は電流を程よい大きさ (約 1 mA) に抑える抵抗

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rlim: resistor c3 c7 3k9
  Ra: resistor e7 e11 100
  Rx: resistor c11 c15 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t4 red
  - +t3 -- a3 red
  - AD.GND -- -t5 black
  - AD.1+ -- a7 green
  - AD.1- -- a11 green
  - a15 -- -t15 black
  - b7 -- b17 orange
  - AD.2+ -- a17 orange
  - AD.2- -- -t19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/04-error-correction-rate.svg)

- CH1 (差動) は R_a (100 Ω) の両端で電流を読む。CH2 は R_a + R_x の両端
  (GND 基準) で電圧計の読みになる

## 計器の設定

この題はオシロの図を付けない — 直流の量だけを見る。テスターの読みで足りる。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Scope | CH1 = R_a の両端 (差動、電流)、CH2 = R_a + R_x の両端 (GND 基準、電圧計の読み) |

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この題は直流なので発振器は使わない。

AD の CH1 は R_a の両端 (100 mV) を差動で挟んでいる。CH2 (1.09 V) の 1 割ほどしかないので、
2 本の先端で引くと 8 bit の分解能で読みが粗くなる。7-3 と同じく **R_a を GND 側へ移し** (R_x と R_a の順を
入れ替え)、CH1 の 1 本で直に読む (図3)。回路図は図1 (電流計が上) から変わるが、
直列の順を入れ替えただけなので、電流 (1.00 mA) も CH2 (R_a + R_x の両端、1.09 V) も変わらない。

```circuit
title: 図3 汎用オシロでの測り方
parts:
  V1: vsource 2,2 2,6 5
  Rlim: resistor 2,2 4,2 3.9k
  M2: voltmeter 5,2 5,6 l=$\mathrm{CH2}$
  Rx: resistor 7,2 7,4 1k
  Ra: resistor 7,4 7,6 100 i=I
  M1: voltmeter 9,4 9,6 l=$\mathrm{CH1}$
  G1: ground 2,6
wires:
  - 4,2 -- 5,2 -- 7,2
  - 7,4 -- 9,4
  - 2,6 -- 5,6 -- 7,6 -- 9,6
style:
  standard: jis
  pitch: 1.3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/04-error-correction-rate-2.svg)

- ブレッドボードは R_a (e7–e11) と R_x (c11–c15) を入れ替え、7〜11 列に R_x、11〜15 列に
  R_a を挿す。11 列が R_x と R_a の間になる
- AD の 1+ (a7) と 1− (a11) の線を外し、CH1 の先端を 11 列に当てる。CH2 の先端は 17 列
  (橙の線で 7 列とつながったまま)。グランドクリップはどちらも − レール
- 電源は安定化電源 5 V、電流制限 10 mA (流れるのは 1.0 mA)。入力の結合は DC、Measure の Mean で読む

**この題の誤差 (+10 %) は、汎用オシロでも読み分けられる。** 直流の確度が数 % ある機種でも
(仕様を見る) それより大きい。CH1 は 20 mV/div にし、電源を切った時の CH1 の Mean (オフセット) を
引いてから電流に直す。もっと細かく読むなら、テスターの直流電圧で 11 列と 7 列を
− レールに対して読む。

## 見るべき値

計算値。真の値 T = 992 Ω、R_lim = 3.9 kΩ、R_a = 100 Ω としたときの
電流は I = 5 V ÷ (3900 + 100 + 992) = 1.002 mA (ほぼ 1 mA になるように選んである)。

| 測る所 | 期待する値 |
| --- | --- |
| CH1 (電流) | 1.002 mA |
| CH2 (電圧計の読み) | 1.094 V |
| 測定値 M (= CH2 / CH1) | 1092 Ω |
| 真の値 T (あらかじめ分かっている) | 992 Ω |
| 誤差 (= M − T) | +100 Ω |
| 誤差率 (= 誤差 / T × 100) | +10.1 % |
| 補正 (= T − M) | −100 Ω |
| 補正率 (= 補正 / M × 100) | −9.2 % |

分かること:

- **誤差の正体は電流計の内部抵抗 R_a そのもの。** 測定値 M = R_a + T = 100 + 992
  = 1092 Ω と、電流計の抵抗を測定物にそのまま足した形になる (7-3 の式と同じ)
- **誤差率と補正率は分母が違うので、値も違う** (+10.1 % と −9.2 %)。
  誤差が小さいうちは近い数字になるが、1 割にもなると 1 ポイント近く開く。
  混同しないよう式を確認する
- この抵抗は表示 1 kΩ・1 % 級で、真の値 992 Ω は表示から −0.8 % — 規格の
  ±1 % の中に収まっている。**測定の誤差率 (+10.1 %) は抵抗自体の精度とは
  別物**で、電流計の抵抗を測定物の抵抗に足してしまったことによる

## 出典

自作。
