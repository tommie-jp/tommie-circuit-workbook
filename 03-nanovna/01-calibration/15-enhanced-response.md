---
book: nanovna
chapter: 1
id: 1-15
title: Enhanced response / 12 項校正
tier: 200
source: 自作 (補正の式は NanoVNA-D と NanoVNA-Saver のソース)
board: —
device: V2
---

# 1-15 Enhanced response / 12 項校正

S21 の校正 (Thru、1-3) には段がある。いちばん簡単な **Response** は「Thru で測った値で割る」だけ。
**Enhanced response** は、それに CH0 側の整合のずれの補正を足す。大きな VNA の **12 項校正**は、
両方向から測って、両方のポートの整合のずれまで消す。NanoVNA は CH0 → CH1 の一方向しか測らない
ので、12 項は本体ではできない。どこまで消えてどこが残るかを、整合の悪い DUT で確かめる。

## 3 つの校正の違い

| 校正 | 測る物 | S21 で消えるもの | 残るもの |
| --- | --- | --- | --- |
| Response | Thru | 通り道の損失と位相 (伝達の項) | CH0 側の整合 (ソースの整合)・CH1 側の整合 (負荷の整合) |
| Enhanced response | Open・Short・Load + Thru | 上に加えて、**CH0 側の整合** (DUT の S11 を使う) | CH1 側の整合 |
| 12 項 (両方向の SOLT) | 両方のポートで Open・Short・Load、Thru を両方向 | 両方の整合も含めて全部 | (標準器の質だけ) |

12 項の名前は、誤差の項が片方向に 6 つ (方向性・ソースの整合・反射の伝達・アイソレーション・
負荷の整合・伝達の伝達)、両方向で 12 になることから。NanoVNA は片方向の 6 つ (のうち使えるもの) までしか
測れない。

## ソースの整合がなぜ S21 を狂わせるか

CH0 側から見た整合のずれ (ソースの整合) を Γ<sub>s</sub> (ガンマ) とする。DUT の入口で反射した波は
Γ<sub>s</sub> で跳ね返されて、もう一度 DUT に入る。Thru は反射しないのでこの往復が無いが、
反射のある DUT では、読みが

S21 の読み (Response) = S21 ÷ (1 − Γ<sub>s</sub> × S11)

になる。Γ<sub>s</sub> は SOLT の 1 ポートの校正で分かっていて (ソースの整合の項)、S11 も同じ掃引で
測っているので、**読みに (1 − Γ<sub>s</sub> × S11) を掛ければ戻せる**。これが Enhanced response。

- DiSlord 版の H4 は CALIBRATE → **ENHANCED RESPONSE** で入り切りし、入れると画面左の校正の印に **E** が出る。
  切ると S21 は Response (と ISOLN を取ったならアイソレーション) の補正だけになる
- NanoVNA-Saver の S21 の補正の式にも、2 ポートの校正 (Through まで) を取れば同じ掛け算が入る
- 12 項に近づけるには、DUT を裏返して 2 回測り、PC で組み合わせる (scikit-rf の `TwoPortOnePath`)。
  DUT が左右対称なら、裏返さずに済ませる方法 (同じ例の「Fake Flip」) もある

## 測る物

**SMA の T アダプタの横の口に 50 Ω の終端器**を付けた物を CH0 と CH1 の間に入れる。
通り道に 50 Ω を並列に置いたことになり、S11 は −1/3 (−9.54 dB)、S21 は 2/3 (−3.52 dB) で、
周波数によらない (T アダプタの中の長さは見ない、理想の模型)。

ソースの整合が悪い状態は、CH0 のケーブルの先に **60 Ω の線を 5 cm** (VF 0.7) 入れたと**仮定**して作る
(校正の後に足したアダプタやケーブルのずれの代わり)。Γ<sub>s</sub> は 1.05 GHz (この線が λ/4) で
最大の −14.9 dB になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ソースの整合のずれ (60 Ω の線) と DUT (並列 50 Ω)
parts:
  M1:
    type: device
    at: 2,2
    label: NanoVNA V2
    pins: [CH0, CH1]
    turn: mirror
  T1: tline 4,2 7,2 60 l=$\mathrm{5cm}$
  R1: resistor 9,2 9,4 50
  J1: sma 11,2
  G1: ground 9,4
  G2: ground 11,3
wires:
  - M1.CH0 -- 4,2
  - 7,2 -- 9,2 -- J1.1
  - J1.2 -- 11,3
notes:
  - text 5.5,3 blue center: ずれ (仮定)
  - text 9,4.9 blue center: DUT (T アダプタ + 50 Ω)
  - text 11.6,2 blue left: CH1 へ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/15-enhanced-response.svg)

T1 は校正の基準面より CH0 側に残ったずれ (等価回路)。CH1 側は理想の 50 Ω とした (負荷の整合のずれは 0)。

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 市販の T アダプタと終端器を測る題で、基板に組む物が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜3 GHz (V2) |
| 点数 | 301 |
| 校正 | SOLT (Open・Short・Load・Thru)。ENHANCED RESPONSE を切った読みと入れた読みを比べる |
| ずれを作る | 校正の後に、CH0 のケーブルの先に 75 Ω の BNC を挟むなど (0-7)。この題の数は 60 Ω・5 cm の模型 |
| 表示 | S21 の Log Mag (2 dB/目盛)、S11 の Log Mag |

Enhanced response を入れたときに**見えるはずの画面** (DUT の本当の値)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50k-3G 301
title: 図2 DUT (並列 50 Ω) の本当の値 — S21 −3.52 dB、S11 −9.54 dB
dut: shunt R 50
traces:
  - S21 logmag 2dB
  - S11 logmag 2dB
markers:
  - 500M
  - 1.05G
  - 1.5G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/15-enhanced-response-1.svg)

ずれの線 (60 Ω・5 cm) だけの反射 (Log Mag と SWR)。CH0 側から見たソースの整合 Γ<sub>s</sub> の大きさにあたる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50k-3G 301
title: 図3 ずれの線の反射 (ソースの整合) — 1.05 GHz で −14.9 dB
dut: line 60 5cm vf 0.7
traces:
  - S11 logmag
  - S11 swr 0.1
markers:
  - 500M
  - 1.05G
  - 1.5G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/15-enhanced-response-2.svg)

- Γ<sub>s</sub> は 1.05 GHz と 3.15 GHz の近くで大きく、2.1 GHz (λ/2) でほぼ 0 になる
- Response だけの読みは、この Γ<sub>s</sub> と DUT の S11 (−1/3) の掛け算のぶんだけ、図2 の −3.52 dB から外れる

## 見るべき値

S21 の読み (計算値)。DUT の本当の値は −3.52 dB。

| 周波数 | Γ<sub>s</sub> の大きさ | Response だけ | Enhanced response |
| --- | --- | --- | --- |
| 500 MHz | −18.15 dB (SWR 1.28) | −3.77 dB | −3.52 dB |
| 1.05 GHz | −14.88 dB (SWR 1.44) | −4.03 dB | −3.52 dB |
| 1.5 GHz | −16.97 dB (SWR 1.33) | −3.84 dB | −3.52 dB |
| 2.1 GHz | −68 dB (ほぼ 0) | −3.52 dB | −3.52 dB |
| 3 GHz | −15.09 dB (SWR 1.43) | −4.01 dB | −3.52 dB |

- **Response だけだと、S21 が周波数とともに波打つ** (この例で −3.52〜−4.03 dB、0.5 dB の幅)。
  Thru (反射なし) で割っているので、Thru を測り直しても消えない
- Enhanced response なら波が消える。残るのは CH1 側の整合のずれ (この模型では 0) で、実物では
  CH1 の前に 6 dB くらいのアッテネータを入れると小さくできる (反射が往復で 12 dB 落ちる)
- フィルタのように S11 が帯の外で大きい DUT ほど、この差が効く。**NanoVNA でフィルタや
  アンプの S21 を測るときは、ENHANCED RESPONSE を入れる** (この教科書の決め)

## LTspice での確かめ

`sim/15-enhanced-response.cir` で、ずれの線 + Thru と、ずれの線 + DUT の S21 を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端)。Response の読みはその比、Enhanced response は比に (1 − Γ<sub>s</sub> × S11) を掛けた算術。理想の模型どうしの比べで、実測ではない。

| 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 0.5 / 1.05 / 1.5 / 2.1 / 3 GHz | Γ<sub>s</sub> (図3) | −18.15 / −14.88 / −16.97 / −68 / −15.09 dB | −18.15 / −14.88 / −16.97 / −67.99 / −15.09 dB | 合う |
| 同 | Response だけの S21 | −3.77 / −4.03 / −3.84 / −3.52 / −4.01 dB | −3.768 / −4.029 / −3.842 / −3.522 / −4.006 dB | 合う |
| 同 | Enhanced response の S21 | −3.52 dB | −3.522 dB (5 点とも) | 合う |
| 同 | DUT の S11 / S21 (図2) | −9.54 / −3.52 dB | −9.54 / −3.522 dB | 合う |

## 出典

自作。ENHANCED RESPONSE のメニューと印 E、補正の式 S21 × (1 − E<sub>s</sub> × S11) は
[NanoVNA-D (GitHub)](https://github.com/DiSlord/NanoVNA-D) のソース (`main.c` の `apply_CH1_error_term`、`ui.c`、`plot.c`)、
Saver の補正は [NanoVNA-Saver (GitHub)](https://github.com/NanoVNA-Saver/nanovna-saver) のソース (`Calibration.py` の `correct21`)、
裏返して測る方法は scikit-rf の例
[TwoPortOnePath, EnhancedResponse, and FakeFlip](https://scikit-rf.readthedocs.io/en/latest/examples/metrology/TwoPortOnePath,%20EnhancedResponse,%20and%20FakeFlip.html) による。
