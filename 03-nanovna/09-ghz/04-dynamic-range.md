---
book: nanovna
chapter: 9
id: 9-4
title: ダイナミックレンジの帯域依存 — H4 (70 / 60 / 40 dB) と V2 を測る
tier: 100
source: 自作。H4 のダイナミックレンジは販売元の仕様の値
board: —
device: V2
---

# 9-4 ダイナミックレンジの帯域依存 — H4 (70 / 60 / 40 dB) と V2 を測る

**ダイナミックレンジ**は、S21 で読める一番小さい値 (床) と 0 dB の差。これより深い
減衰やアイソレーションは、床 (雑音) に埋もれて読めない。

NanoVNA-H4 は 300 MHz より上を si5351 の**高調波**で作るので (0-1)、周波数の帯ごとに
床が段になって上がる。仕様の値は **70 dB (〜300 MHz)・60 dB (〜900 MHz)・40 dB (〜1.5 GHz)**。
V2 は基本波で作るので段が無い。V2 の値は版によって公表値が違うので、**自分の機体で測る**。

測り方は 2 つ。

1. **床を直接見る**: 両方のポートに Load を付け (CH0 と CH1 をつながない)、S21 を読む。
   読みはでたらめに揺れる雑音で、その上の端が床
2. **分かっている減衰を読む**: SMA の固定アッテネータを 20 + 20 + 10 = **50 dB** つないで S21 を読む。
   床より 10 dB 以上上なら −50 dB がきれいに読め、床に近づくと読みが揺れ、床より下なら
   −50 dB ではなく床の値が出る

## この実験で確かめる式

読める条件: **減衰量 < ダイナミックレンジ − 余裕 (10 dB 程度)**。

| 帯 | H4 の床 (仕様) | 50 dB は読めるか (H4) |
| --- | --- | --- |
| 50 kHz〜300 MHz | −70 dB | 読める (20 dB の余裕) |
| 300〜900 MHz | −60 dB | 読める (余裕 10 dB。平均すると落ち着く) |
| 900 MHz〜1.5 GHz | −40 dB | **読めない** (床の −40 dB 前後が出る) |

アッテネータは市販の SMA の固定アッテネータ (DC〜数 GHz) を使う。perfboard のパッド (8-3) は
300 MHz より上で値がずれる (3-6) ので、この題には使わない。

## 回路図

```circuit
title: 図1 CH0 から 20 + 20 + 10 dB を通して CH1 へ
parts:
  J1: sma c2 mirror CH0
  A1:
    type: ic3
    at: c4
    label: 20dB
    pins: [IN, GND, OUT]
  A2:
    type: ic3
    at: c7
    label: 20dB
    pins: [IN, GND, OUT]
  A3:
    type: ic3
    at: c10
    label: 10dB
    pins: [IN, GND, OUT]
  J2: sma c12 CH1
  GJ1: ground d2
  GA1: ground d4
  GA2: ground d7
  GA3: ground d10
  GJ2: ground d12
wires:
  - J1.1 -- A1.IN
  - J1.2 -- d2
  - A1.OUT -- A2.IN
  - A2.OUT -- A3.IN
  - A3.OUT -- J2.1
  - A1.GND -- d4
  - A2.GND -- d7
  - A3.GND -- d10
  - J2.2 -- d12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/circuit/04-dynamic-range.svg)

- A1〜A3 は SMA の固定アッテネータ (オス・メスの筒)。ケーブルの先で校正してから、
  アッテネータどうしを直に重ねてつなぐ
- 床を直接見るときは、アッテネータを外し、J1 と J2 (ケーブルの先) それぞれに Load を付ける

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 市販の SMA アッテネータと Load を測る題で、基板に載せる回路が無い (perfboard のパッドは 300 MHz より上で値がずれるので使わない)。

| 項目 | 値 |
| --- | --- |
| 範囲 | H4 は 50 kHz〜1.5 GHz、V2 は 50 kHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT (ケーブルの先で。機種と範囲ごとにやり直す、1-4) |
| 表示 | S21 の Log Mag |
| 平均・帯域 | 既定のまま 1 回測り、次に平均を増やして (または IF の帯域を狭めて) もう 1 回。床が何 dB 下がるかも読む |

**H4** で 50 dB を測ったときの見えるはずの画面。帯ごとの床 (仕様の値) を注釈で書き込んだ。

```vna
device: h4
sweep: 50k-1.5G 301
title: 図2 H4 で 50 dB を読む — 900 MHz より上は床 (−40 dB) に埋もれる
dut:
  - series R 40.91
  - shunt R 10.1
  - series R 40.91
  - series R 40.91
  - shunt R 10.1
  - series R 40.91
  - series R 25.97
  - shunt R 35.14
  - series R 25.97
traces:
  - S21 logmag
markers:
  - 100M
  - 600M
  - 1.2G
notes:
  - band 900M 1.5G: 床 −40 dB
  - text 150M -70dB: 床 −70 dB
  - text 600M -60dB: 床 −60 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/04-dynamic-range-1.svg)

- 理想の線は全域で −50 dB。実物では 100 MHz と 600 MHz は −50 dB が読め、
  **1.2 GHz の読みは −40 dB 前後でばらつく** (床に埋もれた)
- 300 MHz と 900 MHz で床が段になるのは、高調波の次数が変わる所 (0-1。段そのものは 9-10 で測る)

**V2** で同じ 50 dB を測ったときの見えるはずの画面。設定は機種と範囲だけ変えた。

```vna
device: v2
sweep: 50k-3G 301
title: 図3 V2 で 50 dB を読む — 床は段にならない (値は測って書き込む)
dut:
  - series R 40.91
  - shunt R 10.1
  - series R 40.91
  - series R 40.91
  - shunt R 10.1
  - series R 40.91
  - series R 25.97
  - shunt R 35.14
  - series R 25.97
traces:
  - S21 logmag
markers:
  - 100M
  - 1.2G
  - 2.4G
notes:
  - band 1.5G 3G: H4 では出ない帯
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/04-dynamic-range-2.svg)

- V2 が 1.2 GHz でも −50 dB を読めれば、同じ帯で H4 より 10 dB 以上広い
- 2.4 GHz でも読めるか、読めなければ床がいくつかを、Load を 2 つ付けた測り方で確かめて
  表に書き込む

## 見るべき値

| 周波数 | 50 dB の理想 (計算値) | H4 の読み (予想) | V2 の読み |
| --- | --- | --- | --- |
| 100 MHz | −50.0 dB | −50 dB (床 −70) | 測って書く |
| 600 MHz | −50.0 dB | −50 dB で少し揺れる (床 −60) | 測って書く |
| 1.2 GHz | −50.0 dB | −40 dB 前後で揺れる (床 −40) | 測って書く |
| 2.4 GHz | −50.0 dB | 出ない (範囲の外) | 測って書く |

- **深い S21 (アイソレーション・阻止域) を測る題では、先にこの床を知っておく**。8-7・8-8 の
  −60 dB より下の読みや、フィルタの阻止域 (第 6 章) の底は、床より下なら床の値が出ているだけ
- 床は平均の回数を増やすと下がる。4 倍にすると雑音は半分 (6 dB 下がる) が目安

## 出典

- NanoVNA-H4 のダイナミックレンジ (70 / 60 / 40 dB) は販売元の製品ページの仕様の値
- V2 の値は公表の版で違うので、この題で測る
