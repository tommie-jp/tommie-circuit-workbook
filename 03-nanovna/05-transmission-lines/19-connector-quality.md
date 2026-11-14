---
book: nanovna
chapter: 5
id: 5-19
title: コネクタの質 (真鍮 vs 金メッキ) を GHz で
tier: 200
source: 自作
board: —
device: V2
---

# 5-19 コネクタの質 (真鍮 vs 金メッキ) を GHz で

SMA の中継 (J-J の短いアダプタ) は、数十円の物から数千円の物まである。安い物は真鍮の地に
ニッケルメッキ (銀色)、良い物はベリリウム銅や真鍮に金メッキの中心ピンで、寸法の公差も
決まっている。5-9 で見たとおり、継ぎ目は小さな**直列インダクタンス**に見え、GHz で
反射が増える。安い中継と規格品の中継を 1 つずつ CH0-CH1 の間に挿し、**反射と再現性**を比べる。

先に結論を書くと、GHz で差を作るのはメッキの色より**寸法の精度** (中心ピンの太さ・
誘電体の段差・ピンの突き出し) だ。メッキは**接触の安定 (抜き差ししても同じ値か)** に効く。

## この実験で確かめる式

継ぎ目を直列の L (両側が 50 Ω (オーム)) とみなすと、反射係数は **Γ (ガンマ) = jωL / (100 + jωL)** (ω (オメガ) = 2π (パイ) f、5-9 と同じ)。
SWR = (1 + |Γ|) / (1 − |Γ|)。

ここでは次を**仮定**する (目安。品物で違い、測って読むのがこの題):

| 中継 | 等価な L | 3 GHz の SWR |
| --- | --- | --- |
| 安い真鍮 (ニッケルメッキ、規格の書かれていない物) | 1 nH | 1.45 |
| 金メッキの規格品 (データシートに SWR の上限が書いてある物) | 0.2 nH | 1.08 |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CH0-CH1 間に SMA の中継 1 つ (中継は等価回路)
parts:
  J1: sma 2,2 mirror CH0
  L1: inductor 4,2 6,2 1n
  J2: sma 8,2 CH1
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 5,2.8 center: 中継 (1 nH か 0.2 nH)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/19-connector-quality.svg)

- L1 は中継の**等価回路** (安い物で 1 nH、規格品で 0.2 nH と仮定)。中継の長さ (15 mm ほど) の遅れは、
  校正の Thru に同じ形の中継を使えば消える
- 校正の Thru には、測る 2 つとは**別の良い中継** (またはケーブルどうしを直に) を使う。測る中継で
  校正すると、その中継の不連続が校正に吸い込まれて見えなくなる

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる (3 GHz は H4 の範囲の外)。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 市販の中継を CH0 と CH1 のケーブルの間に挿すだけで、組む回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT。CH0・CH1 のケーブルの先で (Thru は上の注意のとおり) |
| 表示 | S11 の Log Mag |

安い真鍮の中継 (1 nH と仮定) の見えるはずの画面 (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図2 安い真鍮の中継 (1 nH) — 3 GHz で S11 −14.7 dB (SWR 1.45)
dut:
  - series L 1n
traces:
  - S11 logmag
markers:
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/19-connector-quality-1.svg)

金メッキの規格品 (0.2 nH と仮定)。掃引とマーカーは図2 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図3 金メッキの規格品 (0.2 nH) — 3 GHz で S11 −28.5 dB (SWR 1.08)
dut:
  - series L 0.2n
traces:
  - S11 logmag
markers:
  - 1G
  - 2.4G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/19-connector-quality-2.svg)

## 見るべき値

計算値 (上の仮定による)。

| 周波数 | 安い真鍮の S11 | 規格品の S11 | 差 |
| --- | --- | --- | --- |
| 1 GHz | −24.05 dB | −38.02 dB | 14 dB |
| 2.4 GHz | −16.53 dB | −30.42 dB | 14 dB |
| 3 GHz | **−14.65 dB** | **−28.48 dB** | 14 dB |

- L が 1/5 なら |Γ| もほぼ 1/5 で、**どの周波数でも 14 dB の差**。周波数が倍になると、どちらの S11 も
  約 6 dB 上がる (|Γ| が ω にほぼ比例する)
- 安い中継の S21 の落ち込みは 3 GHz で 0.15 dB (反射で返ったぶん)。**損失より反射が先に効く**。
  1 つなら小さいが、変換を 3 段重ねると反射が重なり、周波数によっては S21 に 0.5 dB 以上の波打ちが出る (目安)
- 金色でも寸法の悪い物はある。**SWR の上限 (例: 6 GHz まで 1.2 以下) がデータシートに書かれた物**を選ぶ

**再現性** (メッキが効く所)。同じ中継を 5 回抜き差しして、3 GHz の S21 と S11 を書き留める。
締め付けはトルクレンチで 5 回とも同じに (9-6)。

| 見るもの | 規格品 (目安) | 安い真鍮 (目安) |
| --- | --- | --- |
| 5 回の S21 の幅 (3 GHz) | ±0.01 dB | ±0.05 dB |
| 5 回の S11 の幅 (3 GHz) | ±1 dB | ±3 dB |

- ニッケルや真鍮の表面は酸化して接触の抵抗が揺れ、ピンの割り (スリット) のばねも弱い。抜き差しの
  たびに値が変わる。金は酸化しないので値が戻る
- ニッケルは磁性体で、GHz では電流の流れる層が薄くなり損失が増える。ただ中継 1 つの長さでは
  0.01 dB の桁で、反射と再現性の差のほうがずっと大きい (目安)
- 安い中継は、**校正キットや測定器のポートに直に付けない**。中心ピンの寸法が外れた物は、相手の
  ジャックの割りを広げて傷める (0-2)

## LTspice での確かめ

`sim/19-connector-quality.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ (マイクロオーム) に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図2 (1 nH) | 1 GHz | S11 | −24.05 dB | −24.05 dB | 合う |
| 図2 | 2.4 GHz | S11 | −16.53 dB | −16.53 dB | 合う |
| 図2 | 3 GHz | S11 / S21 | −14.65 dB / −0.15 dB | −14.65 dB / −0.15 dB | 合う |
| 図3 (0.2 nH) | 1 GHz | S11 | −38.02 dB | −38.02 dB | 合う |
| 図3 | 2.4 GHz | S11 | −30.42 dB | −30.42 dB | 合う |
| 図3 | 3 GHz | S11 | −28.48 dB | −28.48 dB | 合う |

.meas は大きさを線形で出すので、20 log₁₀ で dB に直した。SWR (1.45・1.08) と再現性の表は式と目安で、LTspice では確かめていない。

## 出典

自作。

参考: [Wikipedia "SMA connector"](https://en.wikipedia.org/wiki/SMA_connector)、[Wikipedia "Standing wave ratio"](https://en.wikipedia.org/wiki/Standing_wave_ratio)
