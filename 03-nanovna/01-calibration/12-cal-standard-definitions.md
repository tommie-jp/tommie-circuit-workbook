---
book: nanovna
chapter: 1
id: 1-12
title: 校正標準のオフセット (Open の容量・Short の誘導) と定義
tier: 200
source: 自作 (係数の欄と式は NanoVNA-Saver のソース)
board: —
device: V2
---

# 1-12 校正標準のオフセット (Open の容量・Short の誘導) と定義

1-11 では、付属キットを理想 (+1・−1・0) と思い込むと、GHz で 100 Ω が 78 + j32 Ω に読めた。
直すには、**標準器の本当の姿を数で校正に教える**。その数の組を**校正標準の定義** (キットの係数)
という。この題では、定義に何が入っているか、どう決めるか、NanoVNA-Saver のどこに入れるかを見る。

## 定義に入っているもの

NanoVNA-Saver の校正の窓の **Calibration standards** で **Use coefficients** を選ぶと、次の欄が出る
(欄の名前と単位は Saver のソースのまま)。

| 標準器 | 欄 | 意味 |
| --- | --- | --- |
| Short | L0 (H(e-12))、L1 (H(e-24))、L2 (H(e-33))、L3 (H(e-42)) | 短絡の面のインダクタンス L(f) = L0 + L1 f + L2 f² + L3 f³。L0 の単位は pH |
| Short | Offset Delay (ps) | 基準面から短絡の面までの線の遅延 (片道) |
| Open | C0 (F(e-15))、C1 (F(e-27))、C2 (F(e-36))、C3 (F(e-45)) | 開放の縁の容量 C(f) = C0 + C1 f + C2 f² + C3 f³。C0 の単位は fF |
| Open | Offset Delay (ps) | 基準面から開放の面までの遅延 (片道) |
| Load | Resistance (Ω)、Inductance (pH)、Capacitance (fF)、Offset Delay (ps) | 抵抗に直列の L、並列の C、線の遅延 |
| Through | Offset Delay (ps) | Thru のアダプタの遅延 |

Saver は、この係数から標準器の本当の反射を次の式で作り、+1・−1・0 の代わりに使う
(f は周波数、τ (タウ) は Offset Delay、ω = 2πf)。

- Open: Γ<sub>O</sub> = (1 − jωC(f) × 50) / (1 + jωC(f) × 50) × e<sup>−j4πfτ</sup>
- Short: Γ<sub>S</sub> = (jωL(f) − 50) / (jωL(f) + 50) × e<sup>−j4πfτ</sup>

e<sup>−j4πfτ</sup> は往復 (2τ) の位相の遅れ。**Offset Delay は片道で入れる**。
市販の標準器の係数表には、このほかに線の Z0 (オフセットの特性インピーダンス) と損失が載ることがあるが、
Saver の欄には無い (この教科書の範囲では 50 Ω・損失なしとみなす)。

## 容量と遅延は見分けがつかない

Open の縁の容量 C0 は、反射の位相を −2 atan(ωC0 × 50) だけ遅らせる。ωC0 × 50 が小さい間は
これは −2ω × (50 C0) と同じ — **C0 は 50 C0 の遅延とほとんど同じ働き**をする。
50 fF なら 50 Ω × 50 fF = 2.5 ps。

| Open の定義の書き方 | C0 | Offset Delay |
| --- | --- | --- |
| A: 奥行きと縁の容量に分けて書く (9-2・1-11 の模型) | 50 fF | 19.06 ps |
| B: 全部を遅延にまとめる | 0 | 21.56 ps |

A と B の位相の差は 3 GHz でも 0.01° より小さい。**自分で測って決めるなら、B の形 (遅延 1 つ) で
足りる**。C0 と遅延を分けて書いてある市販の係数は、そのまま両方入れる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 付属の Open の模型 (4 mm 奥で開放、縁に 50 fF)
parts:
  M1:
    type: device
    at: 2,2
    label: NanoVNA V2
    pins: [CH0, CH1]
    turn: mirror
  J1: sma 4,2
  T1: tline 5,2 8,2 50 l=$\mathrm{4mm}$
  C1: capacitor 9,2 9,4 0.05p
  G1: ground 4,3
  G2: ground 9,4
wires:
  - M1.CH0 -- J1.1
  - J1.1 -- 5,2
  - 8,2 -- 9,2
  - J1.2 -- 4,3
notes:
  - text 4,1 blue center: 基準面
  - text 6.5,4 blue center: C1 は縁の容量 50 fF (0.05 pF)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/12-cal-standard-definitions.svg)

T1 が Offset Delay (19.06 ps)、C1 が C0 (50 fF)。Short の模型は 1-11 の図1 (4 mm 奥で短絡、L0 = 0)。

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 校正キットの定義を決めて入れる題で、基板に組む物が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜3 GHz (V2。NanoVNA-Saver の分割掃引で 301 点) |
| 点数 | 301 |
| 校正 | Saver の Calibration assistant で SOLT (2-9)。1 回目は Use ideal values、2 回目は Use coefficients |
| 表示 | S11 の位相と Smith |

定義 A で書いた Open の**本当の姿** (仮定の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50k-3G 301
title: 図2 定義 A (4 mm + 50 fF) の Open — 3 GHz で −46.57°
dut:
  - line 50 4mm vf 0.7
  - shunt C 50f
  - open
traces:
  - S11 phase 10deg at -20deg
  - S11 smith
markers:
  - 1G
  - 2G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/12-cal-standard-definitions-1.svg)

定義 B (遅延 21.56 ps だけ。VF 0.7 の線なら 4.5246 mm) で書いた Open。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50k-3G 301
title: 図3 定義 B (遅延だけ) の Open — 図2 と同じ −46.57°
dut:
  - line 50 4.5246mm vf 0.7
  - open
traces:
  - S11 phase 10deg at -20deg
  - S11 smith
markers:
  - 1G
  - 2G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/12-cal-standard-definitions-2.svg)

- 図2 と図3 は、マーカーの読みが小数 2 桁まで同じ。**画面で見分けられない物は、校正にとっても同じ**

## 定義を自分で決める手順

付属キットに係数が付いていないときの決め方。

1. **信用できる校正** を用意する。係数の付いた市販のキットで校正するか、無ければ低い周波数
   (数百 MHz まで。1-11 で誤差が小さかった帯) だけで校正する
2. 付属の Open を DUT として測り、S11 の位相を 1 GHz・2 GHz・3 GHz で読む
3. 位相 φ (度、負の値) から遅延を出す: τ = −φ ÷ (720° × f)。図2 の値なら 3 GHz で
   46.57 ÷ (720 × 3 × 10⁹) = 21.56 ps。3 つの周波数で同じ値になれば、定義 B の形で足りる
4. Short も同じ: φ = 180° − 720° × f × τ から τ を出す。1-11 の図2 なら 3 GHz で
   (180 − 138.83) ÷ (720 × 3 × 10⁹) = 19.06 ps
5. Load は低い周波数で DC の抵抗 (1-8) を Resistance に、反射が周波数とともに増えるぶんを
   Inductance に入れる (|Γ| ≈ ωL ÷ 100。1-11 の Load なら 3 GHz の −25.0 dB から 300 pH)
6. Saver の **Saved settings** に名前を付けて保存する (キットごとに 1 つ)

手順 1 の校正が 3 GHz まで信用できないなら、手順 3 の 3 GHz の値は外挿 (低い周波数の傾きを伸ばした
値) になる。位相が周波数に比例する (遅延が一定の) 間は、外挿で足りる。

## 見るべき値

| 項目 | 1 GHz | 2 GHz | 3 GHz |
| --- | --- | --- | --- |
| 図2 の Open の位相 (定義 A) | −15.52° | −31.05° | −46.57° |
| 図3 の Open の位相 (定義 B) | −15.52° | −31.05° | −46.57° |
| 位相から出す遅延 (手順 3) | 21.56 ps | 21.56 ps | 21.56 ps |
| Short の位相 (1-11 の図2) から出す遅延 | 19.06 ps | 19.06 ps | 19.06 ps |
| 定義を入れた後に 100 Ω を測った読み | 100 Ω | 100 Ω | 100 Ω |
| 定義を入れずに (1-11) | 96.6 + j15.0 Ω | 88.1 + j26.0 Ω | 78.1 + j32.3 Ω |

定義を入れた校正は、標準器の本当の値をそのまま 3 点として使うので、模型が合っていれば読みのずれは
0 になる (下の LTspice の節で確かめた)。実物で残るのは、模型と実物の差 (係数の誤差) だけ。

## LTspice での確かめ

`sim/12-cal-standard-definitions.cir` で、図2・図3 の Open と、1-11 の Short・Load・100 Ω の模型を LTspice の AC 解析にかけた (50 Ω の電源、最後を開放か短絡)。理想の模型どうしの比べで、実測ではない。定義を入れた校正の写し方は、LTspice の標準器の値と Saver の式で作った定義の値から 1-11 と同じ算術で解いた。

| 項目 | 周波数 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 図2 の Open の位相 (定義 A) | 1 / 2 / 3 GHz | −15.52° / −31.05° / −46.57° | −15.52° / −31.05° / −46.57° | 合う |
| 図3 の Open の位相 (定義 B) | 同 | −15.52° / −31.05° / −46.57° | −15.52° / −31.05° / −46.57° | 合う |
| Open の位相から出す遅延 | 同 | 21.56 ps | 21.561 / 21.560 / 21.559 ps | 合う |
| Short の位相から出す遅延 | 同 | 19.06 ps | 19.061 ps (3 点とも) | 合う |
| Load の反射から出す L | 3 GHz | 300 pH | 299.5 pH | 合う |
| 定義を入れた後の 100 Ω の読み (A でも B でも) | 1 / 2 / 3 GHz | 100 Ω | 100.000 Ω (B は 3 GHz で −j0.003 Ω) | 合う |

## 出典

自作。係数の欄の名前・単位と、Open・Short の式は
[NanoVNA-Saver (GitHub)](https://github.com/NanoVNA-Saver/nanovna-saver) のソース
(`Windows/CalibrationSettings.py` と `Calibration.py`) による。標準器の模型の値は仮定。

参考: [Network analyzer (electrical) (Wikipedia)](https://en.wikipedia.org/wiki/Network_analyzer_(electrical))
