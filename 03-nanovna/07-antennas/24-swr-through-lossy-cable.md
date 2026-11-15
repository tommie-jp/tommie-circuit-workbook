---
book: nanovna
chapter: 7
id: 7-24
title: 同軸込みの SWR と給電点の SWR (ケーブル損失で良く見える)
tier: 200
source: 自作
board: —
device: H4
---

# 7-24 同軸込みの SWR と給電点の SWR (ケーブル損失で良く見える)

アンテナの SWR は、**どこで測ったか**で値が変わる。アンテナから無線機まで長い同軸を引くと、アンテナで返ってきた
反射も同軸の中で減るので、無線機の側 (同軸の根元) で測った SWR は給電点の SWR より**良く**見える。
5-3 で見たとおり、430 MHz では 10 m の同軸で数 dB を失う。ここでは、給電点で SWR 2.9 の合っていないアンテナを、
損失 3 dB の同軸の根元から測ると SWR 1.65 に見えること、**アンテナが外れて先が開放でも SWR 3 にしか見えない**ことを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| **\|Γ<sub>in</sub>\| = \|Γ<sub>L</sub>\| × 10<sup>−2A/20</sup> = \|Γ<sub>L</sub>\| × 10<sup>−A/10</sup>** | 片道の損失 A [dB] の同軸の根元で見た反射係数 Γ (ガンマ)。反射は行きと帰りで 2 回損をする |
| **SWR = (1 + \|Γ\|) / (1 − \|Γ\|)** | 反射係数から SWR |
| **A = RL<sub>open</sub> / 2** | 先を開放 (か短絡) した同軸の根元のリターンロス RL [dB] の半分が、片道の損失。同軸の損失を測る手早い方法 |
| **Z<sub>in</sub> の点は Smith の上を回る** | 損の無い同軸は \|Γ\| を変えず、長さの分だけ点を回すだけ (5-5)。損のある同軸は、回りながら中心へ寄る (渦巻き) |

給電点で SWR 2.93 (\|Γ<sub>L</sub>\| = 0.491) のアンテナを、A = 3 dB の同軸の根元で測ると
\|Γ<sub>in</sub>\| = 0.491 × 0.501 = 0.246、SWR = 1.65。

## 回路図

アンテナを直列 R-L-C の等価回路で表し、10 m の同軸 (TL1) で CH0 へ繋ぐ。基板は使わない。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 10 m の同軸の先のアンテナ (等価回路) と、2 つの校正面
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 4,2 7,2 50 l=$\mathrm{TL}_1$
  R1: resistor 9,2 11,2 36
  L1: inductor 11,2 13,2 180n
  C1: capacitor 13,2 15,2 0.82p
  G1: ground 2,3
  G2: ground 15,3
wires:
  - J1.1 -- 4,2
  - 7,2 -- 9,2
  - 15,2 -- 15,3
  - J1.2 -- 2,3
notes:
  - text 3,1.5 center: 面 A
  - text 8,1.5 center: 面 B
  - text 5.5,3 center: 10 m・vf 0.66・損失 3 dB
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/circuit/24-swr-through-lossy-cable.svg)

- R1・L1・C1 は**等価回路**の値。7-3 の 430 MHz の 1/4 波長ホイップを長く作りすぎた形で、自分の共振は 414 MHz。
  435 MHz では 36 + j45.8 Ω (オーム、誘導性)
- TL1 は 10 m の同軸 (RG-58 相当)。430 MHz での損失 3 dB は、5-3 の見積り (10 m で 2.5 dB) を実物の撚り線と編組で
  少し大きく見た**目安**。自分の同軸の値は、下の「先を開放して測る」で測る
- 面 A は NanoVNA の CH0 (無線機の側、同軸の根元)。面 B はアンテナの給電点

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — アンテナ本体と同軸を測る題で、基板に載せる回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 400 MHz〜470 MHz |
| 点数 | 701 (0.1 MHz おき。10 m の同軸は 1 MHz で点を Smith の上で約 0.1 周回すので細かく) |
| 校正 | 図2 は面 B (アンテナの給電点、NanoVNA をアンテナの所へ持って行く)。図3・図4 は面 A (同軸の根元) |
| 表示 | S11 の Smith チャートと SWR |

**電波が出る**: アンテナをつないで掃引すると、NanoVNA の出力がそのまま電波になる。
免許の要らない微弱無線局の上限は、3 m の距離で 500 µV/m (µ はマイクロ) (322 MHz 以下)・35 µV/m
(322 MHz〜10 GHz) (電波法施行規則 第 6 条)。1 mW に満たない出力 (0-3) でもアンテナから
出ればこれを超えうるので、**掃引は測る間だけにし、つないだまま掃引を続けない**。

給電点 (面 B) で測った**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 400M-470M 701
title: 図2 給電点 (面 B) — 435 MHz で SWR 2.93
dut:
  - series R 36
  - series L 180n
  - series C 0.82p
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 430M
  - 435M
  - 440M
notes:
  - band 430M 440M: 430 MHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/24-swr-through-lossy-cable-1.svg)

同じアンテナを 10 m の同軸の根元 (面 A) で測った**見えるはずの画面**。模型は損の無い同軸 (`line`) と、
3 dB の整合した減衰器 (π (パイ) 型の抵抗 292・17.6・292 Ω、部品ではなく損失の代わり) の縦続。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 400M-470M 701
title: 図3 同軸の根元 (面 A) — 同じアンテナが SWR 1.65 に見える
dut:
  - line 50 10m vf 0.66
  - shunt R 292
  - series R 17.6
  - shunt R 292
  - series R 36
  - series L 180n
  - series C 0.82p
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 430M
  - 435M
  - 440M
notes:
  - band 430M 440M: 430 MHz 帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/24-swr-through-lossy-cable-2.svg)

アンテナを外して同軸の先を開放にした**見えるはずの画面** (面 A)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 400M-470M 701
title: 図4 先が開放 (アンテナが外れた) — それでも SWR 3.01
dut:
  - line 50 10m vf 0.66
  - shunt R 292
  - series R 17.6
  - shunt R 292
  - open
traces:
  - S11 smith
  - S11 swr
markers:
  - 435M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/24-swr-through-lossy-cable-3.svg)

- 図2 の点は Smith の上半分 (誘導性) をゆっくり動く。SWR の谷は帯の外 (414 MHz) にある
- 図3 は同じアンテナの点が、同軸の長さの分だけ速く回る (1 MHz で約 0.1 周) 渦巻きになる。中心からの距離は図2 の半分。
  SWR の谷は図2 と同じ 414 MHz にあるが、浅く平らになり (最小 1.18)、帯の中は 1.5〜1.8。**谷の深さで合い方を判じると誤る**
- 図4 は開放なのに半径 0.5 の円 (SWR 3.01)。点は 10 MHz で約 1 周するので、マーカーは 435 MHz だけにした。**根元の SWR 3 は、アンテナが無いことと見分けが付かない**

## 見るべき値

計算値 (等価回路。同軸の損失 3 dB は目安。面 A の Z は同軸の長さで変わるので、SWR で比べる)。

| 周波数 | 面 B の Z | 面 B の SWR | 面 A の SWR (3 dB の同軸込み) | 面 A の SWR (先が開放) |
| --- | --- | --- | --- | --- |
| 430 MHz | 36 + j34.9 Ω | 2.36 | 1.51 | 3.01 |
| 435 MHz | 36 + j45.8 Ω | 2.93 | 1.65 | 3.01 |
| 440 MHz | 36 + j56.5 Ω | 3.61 | 1.79 | 3.01 |

同軸の損失ごとの見え方 (給電点の SWR → 根元の SWR、計算値):

| 給電点の SWR | 損失 1 dB | 損失 3 dB | 損失 6 dB |
| --- | --- | --- | --- |
| 1.5 | 1.38 | 1.22 | 1.11 |
| 2 | 1.72 | 1.40 | 1.18 |
| 3 | 2.32 | 1.67 | 1.29 |
| ∞ (開放・短絡) | 8.72 | 3.01 | 1.67 |

- **先を開放して根元の SWR を見れば、同軸の損失が分かる** (A = RL / 2。SWR 3.01 なら RL = 6.0 dB、A = 3.0 dB)。
  アンテナを測る前に、同軸だけの値をこれで測っておく
- 根元の SWR が良いのは、反射が同軸で熱になっているからで、**アンテナが合っている証拠にはならない**。
  6 dB の同軸なら、給電点の SWR が 3 でも 1.29 にしか見えない (送った電力の 3/4 が同軸で熱になる)
- アンテナを調整するときは、面 B で校正して給電点で測る (NanoVNA は電池で動くので、アンテナの所へ持って行ける)。
  持って行けなければ、同軸の S パラメータを測っておいて引く (3-8 の de-embedding)
- 模型の同軸は 50 Ω ちょうどなので、SWR は長さで変わらない。実物の同軸が 50 Ω から少し外れていると、根元の SWR が周波数で
  細かく波打つ (波の周期は 1 MHz で約 0.1 周に対応して約 10 MHz)。波打ちが見えたら同軸かコネクタを疑う

## LTspice での確かめ

`sim/24-swr-through-lossy-cable.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と、1 端子の模型の先を短絡か開放。
同軸は損失の無い T 素子で TD = 10 m / (0.66 c)、損は 3 dB の π 型の抵抗。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。
損失ごとの表は式の算術で確かめた。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図2 | 430 / 435 / 440 MHz | SWR | 2.36 / 2.93 / 3.61 | 2.36 / 2.93 / 3.61 | 合う |
| 図3 | 430 / 435 / 440 MHz | SWR | 1.51 / 1.65 / 1.79 | 1.51 / 1.65 / 1.79 | 合う |
| 図4 | 430 / 435 / 440 MHz | SWR | 3.01 (435 MHz のマーカー) | 3.01 / 3.01 / 3.01 | 合う |

9 点すべて見るべき値の表と合う。

## 出典

自作。損のある線路の根元で反射係数が 2 倍の損失の分だけ小さく見えることは、伝送線路の教科書に載る標準的な式。
微弱無線局の電界強度の上限 (距離 3 m で 322 MHz 以下は 500 µV/m、322 MHz〜10 GHz は 35 µV/m) は
[電波法施行規則 第 6 条第 1 項第 1 号](https://laws.e-gov.go.jp/law/325M50080000014) による。

参考: [Wikipedia「定在波比」](https://ja.wikipedia.org/wiki/定在波比)、[Wikipedia「Standing wave ratio」](https://en.wikipedia.org/wiki/Standing_wave_ratio)
