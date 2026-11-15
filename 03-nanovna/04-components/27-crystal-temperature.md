---
book: nanovna
chapter: 4
id: 4-27
title: 温度で水晶の f が動く
tier: 200
source: 自作
board: PF
device: H4
---

# 4-27 温度で水晶の f が動く

水晶振動子の共振周波数は、温度でわずかに動く。ふつうの水晶 (AT カット) の動き方は温度の **3 次式**で、
25 °C あたりを中心に、低い側と高い側に山と谷が 1 つずつある。動く量は ppm (100 万分の 1) の桁で、
10 MHz の水晶なら 1 ppm が 10 Hz。4-6 の直列治具に挿した水晶を抵抗で温め、**直列共振 fs が何 Hz 下がるか**を
VNA で読む。治具ごと温める方法や、温度を変えながら掃引を記録する方法もあるが、この題は
抵抗 1 本で水晶だけを温める簡単な形にする。

この題で使う模型は次のとおり (目安)。

| 量 | 値 | 根拠 |
| --- | --- | --- |
| 等価回路 (25 °C) | Lm 21.1 mH・Cm 12 fF・Rm 25 Ω・Co 4 pF | 4-6 と同じ。fs = 10.002033 MHz |
| 温度特性 | Δf / f = −0.25 ppm/°C × (T − 25) + 1.0 × 10⁻⁴ ppm/°C³ × (T − 25)³ | AT カットの形 (3 次の係数は AT カットの代表値、1 次の係数は切り出しの角度で決まるので仮定) |
| 55 °C の fs | 10.002033 MHz × (1 − 4.80 ppm) = 10.001985 MHz | 48 Hz 下がる。模型では Lm を 21.100203 mH にして表す |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 直列治具に水晶、その脇に温める抵抗 (電気はつながない)
parts:
  J1: sma 2,2 mirror CH0
  X1: crystal 4,2 6,2 10M
  J2: sma 8,2 CH1
  G1: ground 2,3
  G2: ground 8,3
  V1: vsource 4,4 4,6 5
  R1: resistor 6,4 6,6 22
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
  - 4,4 -- 6,4
  - 4,6 -- 6,6
notes:
  - text 7.1,5 left: ヒーター (X1 に密着)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/27-crystal-temperature.svg)

- X1 は 4-6 と同じ直列治具。R1 は X1 と**電気的にはつながず**、熱だけでつなぐ
- R1 には USB の 5 V を掛け、5² / 22 = 1.14 W で温める (2 W の抵抗なので定格の 57%)

## 実体配線図

4-6 のユニバーサル基板に、ヒーターの R1 を足す。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 直列治具の水晶に 22 Ω 2 W のヒーターを添える
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  X1: crystal/hc49 f10 i10 10M
  R1: resistor/half f12 k12 22
  V1:
    type: device
    at: f22
    label: USB 5V
    pins: + -
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
  - V1.+ -- f12 red
  - V1.- -- g15 black
  - g15 -- k15 black
  - k15 -- k12 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/27-crystal-temperature.svg)

- **R1 の胴を X1 の缶の上に寝かせ、耐熱のテープで巻いて密着させる**。図では R1 を 12 行目に描いたが、
  ピンを曲げて胴を缶に載せる
- 温度は、テスターの K 熱電対の先を X1 の缶に当ててテープで留めて読む
- **R1 の胴は 100 °C を超えることがある**。通電中と直後は触らない

## 部品

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| X1 | 10 MHz の水晶 (HC-49) | 4-6 と同じ。動作温度の範囲をデータシートで確かめ、その上限を超えて温めない |
| R1 | 22 Ω 2 W (酸化金属皮膜) | 5 V で 1.14 W のヒーター |
| 電源 | 5 V (USB) | ヒーターだけに使う。VNA の側とは繋がない |
| 温度計 | テスターの K 熱電対 | 缶の表面の温度を読む |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10.0015 MHz〜10.0025 MHz (1 kHz の幅) |
| 点数 | 201 (5 Hz おき) |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag (1 dB/目盛) と位相 (20°/目盛) |
| 手順 | 25 °C で掃引 → R1 に通電して缶が 55 °C に届いたら USB を抜く → 冷えていく途中、55・40 °C を通るときに掃引 |

**fs は位相が 0° になる周波数で読む。** S21 の山は 3 dB の幅が約 940 Hz と広く (4-6)、48 Hz のずれは
山の形ではほとんど分からない。位相は fs の近くで 1 Hz あたり約 0.12° 動くので、ずれがそのまま角度に出る。
2 つのマーカーは 1 番が 10.001985 MHz (55 °C の fs)、2 番が 10.002033 MHz (25 °C の fs) で、
読み値の表では丸められて同じ 10.002 MHz と出る。

**25 °C** — 見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10.0015M-10.0025M 201
title: 図3 25 °C — fs = 10.002033 MHz で位相が 0°
dut:
  - series C 12f esl 21.1m esr 25 cp 4p
traces:
  - S21 logmag 1dB
  - S21 phase 20deg
markers:
  - 10.001985M
  - 10.002033M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/27-crystal-temperature-1.svg)

**55 °C** — 同じ掃引とマーカー。Lm だけを 21.100203 mH に替えた模型。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10.0015M-10.0025M 201
title: 図4 55 °C — fs が 48 Hz 下がり 10.001985 MHz に
dut:
  - series C 12f esl 21.100202561m esr 25 cp 4p
traces:
  - S21 logmag 1dB
  - S21 phase 20deg
markers:
  - 10.001985M
  - 10.002033M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/27-crystal-temperature-2.svg)

**周波数と温度の関係** (模型の式)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 AT カットの周波数温度特性 (模型) — 25 °C と 55 °C の差は −4.8 ppm
x: 温度 °C -10..70
y: 周波数のずれ ppm
lines:
  模型 ppm: -0.25*(x-25) + 0.0001*(x-25)^3
notes:
  - mark 0
  - mark 25
  - mark 55
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/graph/27-crystal-temperature.svg)

## 見るべき値

計算値。

| 温度 | Δf / f | fs | 10.002033 MHz での S21 の位相 |
| --- | --- | --- | --- |
| 0 °C | +4.69 ppm | 10.002080 MHz | (掃引しない) |
| 25 °C | 0 | 10.002033 MHz | +0.07° |
| 40 °C | −3.41 ppm | 10.001999 MHz | (表のみ) |
| 55 °C | −4.80 ppm | 10.001985 MHz | −5.76° |

| 図 | マーカー 1 (10.001985 MHz) | マーカー 2 (10.002033 MHz) |
| --- | --- | --- |
| 図3 (25 °C) | −1.97 dB / +5.87° | −1.94 dB / +0.07° (fs) |
| 図4 (55 °C) | −1.94 dB / +0.06° (fs) | −1.99 dB / −5.76° |

分かること:

- **55 °C で fs は 48 Hz 下がる** (−4.8 ppm)。10 MHz の水晶の発振回路なら、温まると周波数がこれだけ動く。
  時計なら 1 日に 0.41 秒の遅れ (4.8 × 10⁻⁶ × 86,400 秒)
- 曲線は 25 °C の上で下がり、54 °C あたりの谷で向きを変えて上がる (図5)。**谷と山の温度は水晶を
  切り出す角度で動く**。温度で動かない水晶が欲しいなら、使う温度の真ん中に谷か山が来る品を選ぶ
  (TCXO は残りを回路で打ち消し、OCXO は谷の温度に保温する)
- VNA 自身の基準の周波数も温度で動く。測る間は VNA を温めない (ヒーターから離す)。ずれを読むのは
  **同じ VNA で測った 2 回の差**なので、VNA の絶対の確かさ (ppm の桁) は差には効きにくい
- 冷えていく途中で掃引するのは、温度が一定の点を作るより簡単だから。缶と中の水晶片の温度に差があるので、
  ゆっくり冷えるほど読みが合う。冷やす側 (0 °C) は冷蔵庫に治具を入れる方法があるが、結露に注意

## LTspice での確かめ

`sim/27-crystal-temperature.cir` で、図3 と図4 の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端、
S21 = 2·V(out) / Vs)。図5 の曲線は式の算術で確かめた (LTspice には温度の模型を入れていない)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 10.001985 MHz | S21 / 位相 | −1.97 dB / 5.87° | −1.97 dB / 5.87° | 合う |
| 図3 | 10.002033 MHz | S21 / 位相 | −1.94 dB / 0.07° | −1.94 dB / 0.07° | 合う |
| 図4 | 10.001985 MHz | S21 / 位相 | −1.94 dB / 0.06° | −1.94 dB / 0.06° | 合う |
| 図4 | 10.002033 MHz | S21 / 位相 | −1.99 dB / −5.76° | −1.99 dB / 5.76° | 合う (大きさ) |
| 図5 | 55 °C | Δf / f | −4.80 ppm | (算術) −0.25 × 30 + 10⁻⁴ × 30³ = −4.80 ppm | 合う |
| 図5 | 0 °C | Δf / f | +4.69 ppm | (算術) −0.25 × (−25) + 10⁻⁴ × (−25)³ = +4.69 ppm | 合う |

6 点すべて合う。LTspice の .meas が返す位相は符号の無い値だったので、図4 の 10.002033 MHz の位相は大きさで比べた
(符号は、fs より上で直列の枝がコイルになるので − 。図の読み値のとおり)。

## 出典

自作。

参考: [Wikipedia「水晶振動子」](https://ja.wikipedia.org/wiki/水晶振動子)、[Wikipedia "Crystal oscillator" (Temperature effects)](https://en.wikipedia.org/wiki/Crystal_oscillator)
