---
book: nanovna
chapter: 5
id: 5-15
title: マイクロストリップの Zo と FR4 の誘電率
tier: 200
source: 自作
board: CB
device: V2
---

# 5-15 マイクロストリップの Zo と FR4 の誘電率

両面の銅張り基板 (FR4) の表に細長い線を残し、裏を全面 GND にすると**マイクロストリップ**に
なる (9-3)。幅 3.06 mm・厚さ 1.6 mm で 50 Ω (オーム) になるのは、FR4 の比誘電率を 4.4 と**仮定**した
計算で、実物の FR4 は 4.0〜4.8 ほどばらつく。作った線の **Z₀ を 5-10 の方法 (Zoc と Zsc)** で測り、
同じ測定の**共振の周波数から比誘電率**を逆算する。

銅張り基板にするのは、線の真下の GND の面と線の幅で Z₀ が決まる伝送線路を作る題だから
(perfboard では線と GND の間が決まらない。9-3)。

## この実験で確かめる式

長さ l の線の先を開放にしたときの入力の Z を Zoc、短絡にしたときを Zsc とすると (損失を見ない)

- Zoc = −j Z₀ cot βl、Zsc = j Z₀ tan βl (β (ベータ) は位相定数で 2π (パイ) f / (速度係数 × c))
- **Z₀ = √(Zoc × Zsc)** — 周波数によらない (5-10 と同じ)
- 線が λ (ラムダ)/4 になる周波数 f₄ で、Zoc は 0 (直列共振)、Zsc は ∞ (並列共振) になる。
  **実効比誘電率 ε<sub>eff</sub> (イプシロン) = (c / (4 l f₄))²**

マイクロストリップの電界は半分ほど空気を通るので、ε<sub>eff</sub> は基材の比誘電率 ε<sub>r</sub> より小さい。
ε<sub>r</sub> は Hammerstad の式で ε<sub>eff</sub> から逆算する (下の読み替えの表)。

| 基材の ε<sub>r</sub> | Z₀ (幅 3.06 mm) | ε<sub>eff</sub> | 速度係数 | 50 mm の f₄ |
| --- | --- | --- | --- | --- |
| 4.0 | 52.2 Ω | 3.059 | 0.572 | 857 MHz |
| 4.2 | 51.1 Ω | 3.195 | 0.560 | 839 MHz |
| 4.4 | 50.1 Ω | 3.331 | 0.548 | **821 MHz** |
| 4.6 | 49.1 Ω | 3.467 | 0.537 | 805 MHz |
| 4.8 | 48.1 Ω | 3.603 | 0.527 | 790 MHz |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CH0 に 50 mm のマイクロストリップ (先は開放か短絡)
points:
  end: 7,2
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 4,2 end 50 l=$\mathrm{TL}_1$
  G1: ground 2,3
wires:
  - J1.1 -- 4,2
  - J1.2 -- 2,3
notes:
  - text 5.5,2.7 center: 幅 3.06 mm・50 mm
  - text 7.2,2 left: 開放 / 短絡 (銅テープ)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/15-microstrip-z0-er.svg)

- TL1 は図2 の基板の線。先 (end) は、まず開放で測り、次に銅テープで裏の GND へつないで短絡で測る
- 開放のとき check は TL1 の先が「どこにもつながっていない」と言う。**開放で測るのが意図**

## 実体配線図

5×7 cm の両面基板から 50 mm × 30 mm を切り出して組む。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 50x30mm
  ground: back
title: 図2 50 mm のマイクロストリップ (先は右の縁)
f: 821M
copper:
  L1: line 0,15 50,15 3.06mm
parts:
  J1: sma left 15 CH0
notes:
  - text 25,24: 短絡は右の縁に銅テープを巻いて裏の GND へ
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/copper/15-microstrip-z0-er.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、50 mm × 30 mm。裏は全面の銅 (GND) |
| 線 | 表の中央に幅 3.06 mm、左の縁から右の縁まで 50 mm。表の銅は線のほかは全部剥がす (図の地の色) |
| 端面 SMA (J1) | 左の縁。中心ピンを線の端へ、外皮の脚は基板の縁で裏のベタへ半田付け |
| 短絡 | 幅 5 mm ほどの銅テープを右の縁に巻き、線の端と裏のベタを半田でつなぐ (via で落とすと via のインダクタンスが乗る。5-21) |

- 線の幅はカッターで切った後に**ノギスで測って書いておく**。幅が 0.2 mm 細ると Z₀ は 2 Ω ほど上がる (Hammerstad の式、目安)
- 流れるのは VNA の出力 (0 dBm 以下) だけ

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる (f₄ は H4 でも届くが、次の 3λ/4 の 2.46 GHz を見るには V2 が要る)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜1.5 GHz |
| 点数 | 281 (5 MHz 刻み) |
| 校正 | SOL (1 ポート)。CH0 のケーブルの先、基板の SMA を挿す所で。基板の SMA の中の長さは校正の外 (数 mm の誤差になる) |
| 表示 | S11 のリアクタンス X (R + jX の X) |

先を**開放** (見えるはずの画面、理想の模型。縁の効果は見ない)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-1.5G 281
title: 図3 開放 — 400 MHz で X = −52.1 Ω、821 MHz で X = 0 (λ/4)
dut:
  - line 50 50mm vf 0.548
  - open
traces:
  - S11 x
markers:
  - 400M
  - 821M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/15-microstrip-z0-er-1.svg)

先を**短絡** (掃引とマーカーは図3 と同じ)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-1.5G 281
title: 図4 短絡 — 400 MHz で X = +48.0 Ω、821 MHz で X が ±∞ に跳ぶ
dut:
  - line 50 50mm vf 0.548
  - short
traces:
  - S11 x
markers:
  - 400M
  - 821M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/15-microstrip-z0-er-2.svg)

## 見るべき値

計算値 (ε<sub>r</sub> = 4.4 の仮定、損失と縁の効果は見ない)。

| 読む所 | 開放 (図3) | 短絡 (図4) | 求まるもの |
| --- | --- | --- | --- |
| 400 MHz の X | −52.08 Ω | +48.00 Ω | Z₀ = √(52.08 × 48.00) = **50.0 Ω** |
| X が 0 か ±∞ になる周波数 f₄ | 821 MHz (0 を横切る) | 821 MHz (跳ぶ。読み値は 60.6 kΩ) | ε<sub>eff</sub> = (c / (4 × 0.05 × f₄))² = **3.33** → 表から ε<sub>r</sub> ≈ 4.4 |

- 400 MHz で読むのは、線が λ/8 ほど (βl = 43.8°) で、Zoc と Zsc がどちらも 50 Ω の近くにあり読み誤りが少ないから。
  共振の近く (X が 0 や ∞ の近く) で読むと、掛け算の誤差が大きくなる
- **f₄ は短絡のほうで読む**。開放の先には電界がはみ出し、線が 0.6 mm ほど長く見える (Hammerstad の開放端の式による
  見積り)。開放の f₄ は 811 MHz ほどに下がり、そのまま読むと ε<sub>eff</sub> を 2.5 % 大きく見積もる
- 測った f₄ が 805 MHz なら ε<sub>r</sub> ≈ 4.6、839 MHz なら 4.2 (表)。そのときの Z₀ も表の行が言い、
  √(Zoc Zsc) の読みと突き合わせられる。**2 つの読みが同じ行を指せば、測り方が正しい**
- FR4 の ε<sub>r</sub> は周波数で少し下がる (1 MHz の値が 1 GHz より大きい)。メーカーの値がどの周波数かを確かめる。
  長さの違う 2 本の線で SMA の不確かさを消す方法は 9-7

## LTspice での確かめ

`sim/15-microstrip-z0-er.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源、先は 1 GΩ の開放か 1 µΩ (マイクロオーム) の短絡)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (開放) | 400 MHz | X | −52.08 Ω | 52.09 Ω (大きさ) | 合う |
| 図4 (短絡) | 400 MHz | X | +48.00 Ω | 47.99 Ω | 合う |
| 図3 | — | X が 0 を横切る周波数 | 821 MHz | 821.45 MHz | 合う |

.meas の im() は符号を落として返すので、開放の X は大きさで比べた (符号は Zoc = −j Z₀ cot βl から負)。
√(52.09 × 47.99) = 50.0 Ω も合う。表の Z₀・ε<sub>eff</sub> と縁の伸び 0.6 mm は Hammerstad の式を Python で解いた算術。

## 出典

自作。[マイクロストリップ](https://en.wikipedia.org/wiki/Microstrip)の Z₀ と実効比誘電率は Hammerstad の近似式で計算した。

参考: [Wikipedia "FR-4"](https://en.wikipedia.org/wiki/FR-4)
