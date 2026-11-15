---
book: nanovna
chapter: 6
id: 6-17
title: QRP 送信機の高調波フィルタ (7 MHz、2 倍・3 倍を見る)
tier: 200
source: 自作
board: PF
device: H4
---

# 6-17 QRP 送信機の高調波フィルタ (7 MHz、2 倍・3 倍を見る)

5 W 以下の小さな送信機 (QRP) の終段は、トランジスタを強く振って効率を稼ぐので、出力は正弦波から崩れ、
**2 倍・3 倍の高調波**を含む。7 MHz の送信機なら 14 MHz と 21 MHz で、どちらも別のアマチュアバンドや
ほかの無線局の周波数に当たる。アンテナの手前に**ローパスフィルタ**を入れて高調波だけを落とす。
7 MHz の 5 次チェビシェフを T37-2 のトロイダルコイルで組み、NanoVNA で**基本波の損失と、2 倍・3 倍の減衰**を読む。
送信機そのものは繋がない (フィルタだけを測る)。

## この実験で確かめる式

5 次チェビシェフ (リップル 0.1 dB) の g 値は g1 = g5 = 1.147、g2 = g4 = 1.371、g3 = 1.975。
カットオフ f<sub>c</sub> の π (パイ) 型 (C-L-C-L-C) は C = g / (2π f<sub>c</sub> × 50 Ω (オーム))、L = g × 50 Ω / (2π f<sub>c</sub>)。
f<sub>c</sub> = 8.6 MHz なら C1 = C5 = 424 pF、L = 1.27 µH (マイクロヘンリー)、C3 = 731 pF。これを買える値に丸めた:

| 部品 | 計算 | 使う値 | 理由 |
| --- | --- | --- | --- |
| C1・C3 (両端) | 424 pF | **470 pF** | E12 |
| C2 (中央) | 731 pF | **820 pF** | E12 |
| L1・L2 | 1.27 µH | **1.44 µH** | T37-2 に 19 回 |

コイルは鉄粉のトロイダルコア **T37-2** (A<sub>L</sub> = 4.0 nH/回²) に巻く。L = A<sub>L</sub> × N² なので 19 回で 4.0 × 361 = 1.444 µH。
丸めた値の組で、通過帯域の S11 が −26 dB より良く、2 倍の減衰が大きくなる組を計算で選んだ (−3 dB は 8.6 MHz)。
コイルの Q は 7 MHz で 150 と見積もった (目安)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 7 MHz の高調波フィルタ (5 次チェビシェフ、パイ型)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 470p
  L1: inductor 5,2 7,2 1.44u
  C2: capacitor 8,2 8,4 820p
  L2: inductor 9,2 11,2 1.44u
  C3: capacitor 12,2 12,4 470p
  J2: sma 14,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 8,4
  G4: ground 12,4
  G5: ground 14,3
wires:
  - J1.1 -- 4,2 -- 5,2
  - 7,2 -- 8,2 -- 9,2
  - 11,2 -- 12,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/17-qrp-harmonic-lpf.svg)

## 実体配線図

7 MHz は perfboard の範囲 (300 MHz くらいまで) に十分収まる。5×7 cm を横に使い、10 行が信号の通り道、7 行が GND の筋。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (T37-2 に 19 回を 2 個)
parts:
  J1: sma/female-edge a10 09
  C1: capacitor c9 c8 470p
  L1: inductor/toroid e10 h10 T37-2 19t
  C2: capacitor j9 j8 820p
  L2: inductor/toroid l10 o10 T37-2 19t
  C3: capacitor q9 q8 470p
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - c10 -- e10
  - h10 -- j10
  - j10 -- l10
  - o10 -- q10
  - q10 -- x10
  - 09 -- b9 black
  - b9 -- b7 black
  - c10 -- c9
  - c8 -- c7 black
  - j10 -- j9
  - j8 -- j7 black
  - q10 -- q9
  - q8 -- q7 black
  - b7 -- c7 black
  - c7 -- j7 black
  - j7 -- q7 black
  - q7 -- w7 black
  - y9 -- w9 black
  - w9 -- w7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/17-qrp-harmonic-lpf.svg)

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| C1・C3 | 470 pF (471) | セラミック (C0G / NP0)。定格 50 V 以上 |
| C2 | 820 pF (821) | 同じ |
| L1・L2 | 1.44 µH | T37-2 (鉄粉、赤。外径 9.5 mm) に φ0.4 mm の UEW を 19 回 (約 30 cm) |
| J1・J2 | 端面 SMA (メス) | 基板の左右の縁 |

- コンデンサは温度で値が動かない C0G を使う。高誘電率系 (B・X7R) は送信の電力で熱を持ち、値が変わる
- 5 W を 50 Ω に出すと、電圧は √(5 × 50) = 15.8 V (実効値)、ピークで 22.4 V、電流は 0.32 A (算術)。
  定格 50 V のコンデンサと T37-2 で足りる。NanoVNA で測るときの電力はずっと小さい
- 巻き数を 1 回変えると L は約 10 % 動く (19 回 → 18 回で 1.30 µH)。巻いたら 4-14 の方法で L を測ってから付ける

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

**送信機の出力を NanoVNA に直に入れない** (CH1 の最大入力を大きく超える。0-3)。フィルタだけを NanoVNA で測る。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1〜31 MHz (3 倍の 21.3 MHz を含む) |
| 点数 | 301 (100 kHz おき) |
| 校正 | SOLT (Thru はケーブル 2 本を直結) |
| 表示 | S21 と S11 の Log Mag |

コイルの Q 150 (直列 0.43 Ω) を入れた模型の**見えるはずの画面**。塗った帯は 7.0〜7.2 MHz (7 MHz 帯)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-31M 301
title: 図3 7 MHz の高調波フィルタ — 2 倍で −31 dB、3 倍で −51 dB
dut:
  - shunt C 470p
  - series L 1.444u esr 0.43
  - shunt C 820p
  - series L 1.444u esr 0.43
  - shunt C 470p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 7.1M
  - 8.6M
  - 14.2M
  - 21.3M
notes:
  - band 7M 7.2M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/17-qrp-harmonic-lpf.svg)

## 見るべき値

計算値 (コイルの Q 150 の模型)。

| マーカー | 周波数 | S21 | S11 | 意味 |
| --- | --- | --- | --- | --- |
| 1 | 7.1 MHz | **−0.16 dB** | −31.56 dB | 基本波。損失は 0.16 dB (5 W のうち 0.18 W) |
| 2 | 8.6 MHz | −3.01 dB | −3.38 dB | カットオフ |
| 3 | 14.2 MHz | **−31.09 dB** | −0.01 dB | 2 倍の高調波 |
| 4 | 21.3 MHz | **−50.72 dB** | 0.00 dB | 3 倍の高調波 |

- 7.0〜7.2 MHz の S11 は −26〜−41 dB (SWR 1.1 以下、計算値)。送信機から見て 50 Ω のまま
- 2 倍・3 倍の S11 は 0 dB。**高調波は消えるのではなく、送信機の側へ跳ね返る** (π 型は短絡に近い Z で返す。6-10)
- 実物の 2 倍・3 倍の減衰は、コイルどうしの結合と GND の線の長さで浅くなる。2 つのトロイダルコアは 1 cm 以上離し、
  向きを 90° 変えると結合が減る (目安)

分かること:

- 終段の出力に 2 倍が −20 dB (目安) 含まれていても、このフィルタの後では −51 dB になる。3 倍はさらに 50 dB 落ちる
- **基本波の損失と高調波の減衰は、カットオフの置き方で取り合う**。カットオフを 7.2 MHz に近づけるほど 2 倍は深く落ちるが、
  通過帯域の端で S11 と損失が悪くなる。8.6 MHz は 7.2 MHz の 1.2 倍で、基本波の S11 が −26 dB より良い所
- 送信の決まり (スプリアスの許容値) と、実際に電波を出す前の確かめは、番外の工作の 7-1 で扱う

## LTspice での確かめ

`sim/17-qrp-harmonic-lpf.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定し、Q の分は 0.43 Ω で入れた)。
理想の模型どうしの比べで、実測ではない。

| 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 7.1 MHz | S21 / S11 | −0.16 dB / −31.56 dB | −0.16 dB / −31.56 dB | 合う |
| 8.6 MHz | S21 / S11 | −3.01 dB / −3.38 dB | −3.01 dB / −3.38 dB | 合う |
| 14.2 MHz | S21 | −31.09 dB | −31.09 dB | 合う |
| 21.3 MHz | S21 | −50.72 dB | −50.72 dB | 合う |

4 点すべて図の読み値と合う。L = 4.0 nH × 19² = 1.444 µH、0.43 Ω = 2π × 7.1 MHz × 1.444 µH / 150 は算術。

## 出典

自作。T37-2 の A<sub>L</sub> (4.0 nH/回²) は [Amidon の T37-2 の表](https://www.amidoncorp.com/t37-2/) による。
5 次チェビシェフの g 値は標準的なフィルタ設計表による。

参考: [Wikipedia「チェビシェフフィルタ」](https://ja.wikipedia.org/wiki/%E3%83%81%E3%82%A7%E3%83%93%E3%82%B7%E3%82%A7%E3%83%95%E3%83%95%E3%82%A3%E3%83%AB%E3%82%BF)、[Wikipedia「スプリアス」](https://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%97%E3%83%AA%E3%82%A2%E3%82%B9)
