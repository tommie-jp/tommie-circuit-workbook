---
book: nanovna
chapter: 4
id: 4-22
title: 電解 vs OS-CON vs セラミック
tier: 200
source: 自作
board: PF
device: H4
---

# 4-22 電解 vs OS-CON vs セラミック

電源のデカップリングやスイッチング電源の出力に置く大きな容量は、主に 3 種類から選ぶ。
**アルミ電解** (電解液)、**OS-CON** などの導電性高分子のアルミ固体電解コンデンサ、**積層セラミック** (MLCC)。
同じ「100 µF (マイクロファラド)」「10 µF」でも、高い周波数での \|Z\| (インピーダンスの大きさ) は桁で違う。
4-3 では電解の ESR (等価直列抵抗) 0.8 Ω (オーム) を S11 の \|Z\| で読んだ。OS-CON の ESR は数十 mΩ、セラミックは数 mΩ で、
S11 では読めない。そこで 3-2 の**並列治具** (シャント) で S21 から読み、3 つを同じ物差しで比べる。

## この実験で確かめる式

3 つとも、C・ESR・ESL (等価直列インダクタンス) の直列で書く。

- \|Z\| = √(ESR² + (2πf·ESL − 1 / (2πf·C))²)。SRF (自己共振周波数) = 1 / (2π√(ESL·C)) で \|Z\| = ESR
- シャントの S21 = 2Z / (2Z + 50)。Z が 25 Ω より十分小さければ \|S21\| ≈ \|Z\| / 25、つまり **\|Z\| = 25·\|S21\|**
  (S21 が −20 dB 下がるごとに \|Z\| は 1/10)

| コンデンサ (模型。目安) | C | ESR | ESL | SRF |
| --- | --- | --- | --- | --- |
| アルミ電解 (汎用、16 V) | 100 µF | 0.8 Ω | 8 nH | 177.9 kHz |
| OS-CON (導電性高分子、16 V) | 100 µF | 25 mΩ | 5 nH | 225.1 kHz |
| 積層セラミック (X7R、リード付き、25 V) | 10 µF | 5 mΩ | 3 nH | 918.9 kHz |

電解の値は 4-3 と同じ。OS-CON とセラミックの値は、この大きさの部品でデータシートによく見る桁に合わせた目安で、
特定の品番の値ではない。買った品のデータシートの ESR (100 kHz) と見比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 並列治具からコンデンサを GND へ (1 つずつ付け替える)
parts:
  J1: sma 2,2 mirror CH0
  J2: sma 8,2 CH1
  C1: ecap 5,2.75 5,4.25 100u
  G1: ground 2,3
  G2: ground 8,3
  G3: ground 5,4.75
wires:
  - J1.1 -- 5,2 -- J2.1
  - 5,2 -- 5,2.75
  - 5,4.25 -- 5,4.75
  - J1.2 -- 2,3
  - J2.2 -- 8,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/22-elec-oscon-ceramic.svg)

- C1 は電解・OS-CON・セラミックを 1 つずつ付け替える。極性のある電解と OS-CON は + を上 (信号の線の側) にする
- 直流の電圧は掛けない (NanoVNA の出力だけ)。セラミックの容量は直流の電圧で下がるが、この測定では見えない

## 実体配線図

3-2 の並列治具の R1 の代わりに C1 を挿す (4-8 と同じ置き方)。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の並列治具に C1 (OS-CON を挿したところ)
points:
  GND: b7
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  C1: capacitor/electrolytic h10 h7 100u v=16V
wires:
  - a10 -- h10
  - h10 -- x10
  - 09 -- b9 black
  - b9 -- GND black
  - GND -- h7 black
  - h7 -- o7 black
  - o7 -- o9 black
  - o9 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/22-elec-oscon-ceramic.svg)

- C1 は胴を基板に付け、リードを最短で切る。OS-CON はアルミ電解と同じ形の部品として描いた (図の部品の種類に OS-CON が無いため)
- **GND の戻りを短く**: C1 の − のリード (h7) から J1・J2 の外皮までの黒の線の長さが、そのまま ESL に足される。
  mΩ を読む測定なので、7 行の GND のまとめは太い線で両側の SMA へ渡す

## 部品

| 部品 | 値 | 備考 |
| --- | --- | --- |
| C1 (1 つめ) | 100 µF 16 V、アルミ電解 (汎用) | E6。4-3 と同じ物でよい |
| C1 (2 つめ) | 100 µF 16 V、OS-CON (導電性高分子アルミ固体電解) | E6 |
| C1 (3 つめ) | 10 µF 25 V、X7R、リード付き積層セラミック | E6 |
| J1・J2 | 端面 SMA (メス) | 2 個 |
| 基板 | 5×7 cm のユニバーサル基板 | 3-2 の治具 |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜2 MHz (谷を見る)、50 kHz〜50 MHz (ESL の上り坂まで) |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で。Thru の後に**何も挿さない治具**で S21 が 0 dB になることを確かめる |
| 表示 | S21 の Log Mag (10 dB/目盛)。平均化を 4 回以上 |

- **H4 のダイナミックレンジは 300 MHz まで 70 dB** (S21 の下限は −70 dB ほど)。セラミックの谷 (−74 dB) は下限より下で、
  雑音の床に埋もれて読めない (計算値と比べて浅く出る)
- 低い周波数で mΩ を読むと、CH0 と CH1 のケーブルの外皮を通る電流が測定に混ざる (外皮の抵抗が \|Z\| に足されて見える)。
  CH1 側のケーブルにフェライトのコアを何回か巻いて、谷の深さが変わらないことを確かめる (目安)

OS-CON の見えるはずの画面 (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50k-2M 401
title: 図3 OS-CON 100 µF — 225 kHz の谷で −60 dB (ESR 25 mΩ)
dut:
  - shunt C 100u esr 0.025 esl 5n
traces:
  - S21 logmag
expect:
  - match: しか動きません
    why: LOGMAG の上端は 0 dB に固定で、−60 dB の谷を枠に入れるには 10 dB/目盛 が要る。谷の深さはマーカーで読む
markers:
  - 100k
  - 225.1k
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/22-elec-oscon-ceramic.svg)

3 つの \|Z\| を対数の軸で重ねる (模型から計算した値。NanoVNA の画面ではない)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 3 つのコンデンサの |Z| (計算値)
x: 周波数 Hz log 50k..50M
y: インピーダンス Ω log 0.001..10
lines:
  電解 100µF Ω: sqrt(0.8^2 + (2*pi*x*8n - 1/(2*pi*x*100u))^2)
  OS-CON 100µF Ω: sqrt(0.025^2 + (2*pi*x*5n - 1/(2*pi*x*100u))^2)
  セラミック 10µF Ω: sqrt(0.005^2 + (2*pi*x*3n - 1/(2*pi*x*10u))^2)
notes:
  - mark 100k
  - mark 1M
  - mark 10M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/graph/22-elec-oscon-ceramic.svg)

## 見るべき値

計算値 (模型は上の表)。S21 はシャントの式から。

| コンデンサ | 100 kHz の \|Z\| / S21 | 1 MHz の \|Z\| / S21 | 10 MHz の \|Z\| / S21 | 谷 (SRF) の \|Z\| / S21 |
| --- | --- | --- | --- | --- |
| 電解 | 0.800 Ω / −30.17 dB | 0.801 Ω / −30.15 dB | 0.945 Ω / −28.73 dB | 0.8 Ω / −30.17 dB (177.9 kHz) |
| OS-CON | 28.1 mΩ / −59.00 dB | 38.9 mΩ / −56.16 dB | 315 mΩ / −38.00 dB | 25 mΩ / −60.01 dB (225.1 kHz) |
| セラミック | 157 mΩ / −44.02 dB | 5.8 mΩ / −72.70 dB | 187 mΩ / −42.53 dB | 5 mΩ / −73.98 dB (918.9 kHz) |

分かること:

- **電解は 50 kHz〜10 MHz のほとんどで 0.8 Ω の抵抗**。OS-CON は同じ 100 µF で **30 分の 1** (25 mΩ)。
  電源の出力のリップルは、この \|Z\| に流れる電流の積なので、同じ電流ならリップルも 30 分の 1 になる
- **セラミックは容量が 1/10 でも、452 kHz より上では 3 つの中で一番 \|Z\| が小さい** (計算値。ESL と ESR が一番小さいため)。ただし 100 kHz では
  容量が小さいぶん 157 mΩ と、OS-CON より大きい。低い周波数は大きな容量、高い周波数は小さな ESL と ESR で受け持つ (4-8 の並列)
- **10 MHz から上は 3 つとも ESL で決まる** (電解 8 nH、OS-CON 5 nH、セラミック 3 nH)。種類より、リードの長さと
  置き方が効く (4-7)
- ESR が小さいほど、ESL と C の共振 (反共振) で \|Z\| が跳ね上がりやすい。OS-CON とセラミックを並列にするときは 4-8 の反共振の山に注意する
- セラミックの谷は H4 の下限 (−70 dB) より深いので、実測では −70 dB 前後で平らに切れて見える。それは部品ではなく計器の限界

## LTspice での確かめ

`sim/22-elec-oscon-ceramic.cir` で、3 つの模型をシャントにして LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。
LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (OS-CON) | 100 kHz | S21 | −59.00 dB | −59.00 dB | 合う |
| 図3 (OS-CON) | 1 MHz | S21 | −56.16 dB | −56.16 dB | 合う |
| 図3 (OS-CON) | 225.1 kHz | S21 | −60.01 dB | −60.01 dB | 合う |
| 表 (OS-CON) | 10 MHz | S21 | −38.00 dB | −38.00 dB | 合う |
| 表 (電解) | 1 MHz | S21 | −30.15 dB | −30.15 dB | 合う |
| 表 (セラミック) | 1 MHz | S21 | −72.70 dB | −72.69 dB | 合う |
| 表 (セラミック) | 10 MHz | S21 | −42.53 dB | −42.53 dB | 合う |

7 点すべて合う。図4 の \|Z\| は同じ式なので、表の \|Z\| と図の読み値を突き合わせた (算術)。

## 出典

自作。

参考: [Wikipedia「電解コンデンサ」](https://ja.wikipedia.org/wiki/電解コンデンサ)、[Wikipedia "Polymer capacitor"](https://en.wikipedia.org/wiki/Polymer_capacitor)、[Wikipedia「セラミックコンデンサ」](https://ja.wikipedia.org/wiki/セラミックコンデンサ)
