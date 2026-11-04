---
book: circuits
chapter: 4
id: 4-12
title: 精密整流とピークホールド
tier: 200
source: 自作
---

# 4-12 精密整流とピークホールド

ダイオード 1 本の半波整流は、順方向電圧 (約 0.6 V) より小さい信号を通さない。振幅 0.5 V の正弦波を入れると、
山の先が 0.1 V ほど顔を出すだけで、ほとんど消える。**ダイオードを OP アンプの帰還の中に入れる**と、
OP アンプの利得が順方向電圧を打ち消し、数十 mV の信号でも形を崩さずに整流できる。これが**精密整流**で、
交流電圧計・音量計 (VU メータ)・AGC の検波に使う。後ろに**ピークホールド** (山の値を C に貯めて持ち続ける回路) を
つなぐと、交流の振幅を直流の電圧として読める。

この題では、LM358 の 2 回路で精密整流とピークホールドを組み、振幅 0.5 V の正弦波が 0.5 V の半波になり、
ピークホールドの出力が約 0.5 V の直流になることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 精密整流 (U1・D1・D2) とピークホールド (U2・D3・C1)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 3,4
  W1: sine 4,5 4,7 0.5 l=$\mathrm{W1}$
  GW: ground 4,7
  R1: resistor 5,5 7,5 10k
  U1: opamp 10,6 +down
  GU1: ground 8,7
  D1: diode 8,3 11,3 1N4148
  R2: resistor 8,2 13,2 10k
  D2: diode 11,6 13,6 1N4148
  U2: opamp 16,7 +up
  D3: diode 17,7 19,7 1N4148
  C1: capacitor 21,7 21,9 1u
  GC1: ground 21,9
  R3: resistor 23,7 23,9 100k
  GR3: ground 23,9
  RECT: port 13,8 out
  HOLD: port 24,7 out
points:
  vp: 2,1
  vm: 2,7
  mid: 2,4
wires:
  - mid -- 3,4
  - 4,5 -- 5,5
  - 7,5 -- 8,5
  - 8,5 |- U1.-
  - 8,7 |- U1.+
  - 8,5 -- 8,3
  - 8,3 -- 8,2
  - U1.out -- 11,6
  - 11,6 -- 11,3
  - 13,6 -- 13,2
  - 13,6 -- 14,6
  - 14,6 |- U2.+
  - 13,6 -- 13,8
  - U2.out -- 17,7
  - 19,7 -- 21,7 -- 23,7 -- 24,7
  - 19,7 -- 19,9 -- 14,9
  - 14,9 |- U2.-
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/12-precision-rectifier.svg)

- 左の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **U1 は 4-3 の反転増幅 (R1 = R2 = 10 kΩ) の帰還に、ダイオードを 2 本入れた形。** 入力が負の間は U1 の出力が正に振れ、
  D2 が導通して R2 の帰還が働く。RECT には −1 倍の入力、つまり**正の半波**が出る。入力が正の間は U1 の出力が負に振れ、
  D1 が導通して − 入力 (仮想接地) に戻る。D2 は逆バイアスで切れ、RECT は R2 を通して仮想接地の 0 V に引かれる
- どちらの半周期も、ダイオードの順方向電圧は**OP アンプの出力が余分に振れて打ち消す**。U1 の出力 (D1・D2 の間) は、
  RECT より約 0.6 V 高い所か、0 V より約 0.6 V 低い所にいる。RECT に順方向電圧は残らない
- D1 の役目は、入力が正の間に U1 の出力が −5 V まで飽和しないよう、0.6 V で止めておくこと。次の半周期に
  出力が 0.6 V 動くだけで済み、LM358 の遅いスルーレート (0.3 V/µs) でも半波の頭が欠けにくい
- **U2・D3・C1 はピークホールド**。U2 の − 入力を D3 の先 (HOLD) から取るので、D3 の順方向電圧はここでも消える。
  RECT が HOLD より高い間だけ D3 が導通して C1 を充電し、RECT が下がると D3 が切れて C1 は電圧を保つ
- R3 (100 kΩ) は C1 の放電路。HOLD は 時定数 τ (タウ) = C1 × R3 で下がり、振幅が小さくなったときに追いかけて下がる。
  R3 が無いと、一度貯めた山の値がいつまでも残る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (上が精密整流、下がピークホールド)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [2+, 1+, 1-, 2-]
  U1: dip8 @ e20 LM358
  R1: resistor d22 d27 10k
  R2: resistor b22 b16 10k cap=left
  D1: diode c22(A) c18(K) 1N4148 cap=left
  D2: diode a18(A) a16(K) 1N4148 cap=above
  D3: diode h20(A) h12(K) 1N4148 cap=left
  C1: capacitor c12 c9 1u
  R3: resistor a12 -t12 100k
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a27 yellow
  - +t20 -- a20 red
  - a23 -- -t23 black
  - j23 -- -b23 blue
  - d21 -- d18 green
  - e16 -- f16 orange
  - g16 -- g22 orange
  - i21 -- i12 white
  - e12 -- f12 white
  - a9 -- -t9 black
  - SC.1+ -- j16 orange
  - SC.2+ -- j12 white
  - SC.1- -- -t29 black
  - SC.2- -- -t30 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/12-precision-rectifier.svg)

- AD3 の Supplies の V+ は上の赤レール、GND は上の青レール、V− は下の青レールへ入れる (4-10 と同じ分け方。下の赤レールは使わない)。
  電流は数 mA で、各レール約 50 mA の範囲に収まる
- LM358 は 20 列〜23 列。**上ブロック側の回路 (PIN 5〜7) が U1 (精密整流)、下ブロック側 (PIN 1〜3) が U2 (ピークホールド)**。
  PIN 8 (20 列) は `+t20 → a20` で +5 V、PIN 4 (23 列) は `j23 → -b23` で −5 V、U1 の + 入力 (PIN 5、23 列) は `a23 → -t23` で GND
- **22 列が U1 の − 入力 (PIN 6)**。W1 (黄) は 27 列へ入り、R1 (d 段) で 22 列へ。R2 (b 段) は 22 列と RECT の 16 列の間
- U1 の出力 (PIN 7、21 列) は緑の線 `d21 → d18` で 18 列へ出す。D1 は 22 列 (アノード) と 18 列 (カソード) の間、
  D2 は 18 列 (アノード) と 16 列 (カソード) の間。ダイオードの帯 (カソード) の向きを図と合わせる
- RECT (16 列) は橙の線 `e16 → f16` で下ブロックへ下ろし、`g16 → g22` で U2 の + 入力 (PIN 3) へ
- U2 の出力 (PIN 1、20 列) から D3 (h 段) で HOLD の 12 列へ。HOLD は白の線 `i21 → i12` で U2 の − 入力 (PIN 2、21 列) に戻し、
  `e12 → f12` で上ブロックの 12 列へ上げる。上の 12 列に C1 (12 列〜9 列、9 列は `a9 → -t9` で GND) と R3 (12 列から上の青レール) を挿す
- Scope の 1+ (橙) は RECT の 16 列 (`j16`)、2+ (白) は HOLD の 12 列 (`j12`)。1− と 2− は上の青レール (GND) へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の半波と直流を並べて見る題で、10 MHz よりずっと低いから。
W1 は 1 kHz・振幅 0.5 V の正弦波。CH1 に RECT、CH2 に HOLD をつなぎ、どちらも DC 結合で同じ尺度にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1 kHz、振幅 0.5 V、オフセット 0 V |
| Scope CH1 (RECT、16 列) | DC、100 mV/div。オフセットを −0.2 V にして 0〜0.6 V を画面に収める |
| Scope CH2 (HOLD、12 列) | DC、100 mV/div。CH1 と同じオフセット |
| Time | 500 µs/div (1 kHz が 5 周期) |
| Trigger | CH1、立ち上がり、0.25 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 精密整流 (CH1) は 0〜0.5 V の半波、ホールド (CH2) は約 0.5 V
time: 500us/div
trigger: ch1 rising 0.25V
ch1: {wave: sine 1kHz 0.5V phase 180deg | clip 0V, range: 100mV/div, position: -2div}
ch2: {wave: dc 0.497V, range: 100mV/div, position: -2div}
cursors: [-833us, 167us]
measure: [vmax, vmin, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/12-precision-rectifier.svg)

図3 の CH1 は 0 V から 0.5 V (5 目盛) まで立つ半波で、入力が負の半周期だけが正に折り返って出る。入力の正の半周期は 0 V に張り付く。
CH2 (HOLD) は半波の山の高さに張り付いた直流で、山と山の間に C1 が R3 で放電する分だけ、わずかに下がる (1 周期で約 5.5 mV。画面では見えない)。
カーソル X1・X2 は CH1 の山 (1 周期離れた 2 つ) に置いた。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2 | オペアンプ (1 個の LM358 の 2 回路) | LM358 |
| R1, R2 | 抵抗 (精密整流の利得 −1 倍) | 各 10 kΩ |
| D1, D2, D3 | 小信号ダイオード | 1N4148 |
| C1 | フィルムコンデンサ (ピークホールド。漏れの小さいもの) | 1 µF |
| R3 | 抵抗 (C1 の放電) | 100 kΩ |
| — | 信号源 | 1 kHz・振幅 0.5 V の正弦波 |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (RECT と HOLD)、テスター |

## 見るべき値

W1 を入れて、オシロで RECT と HOLD を、テスターの直流電圧レンジで HOLD と RECT の平均を測る。表の値は計算値。
HOLD の放電は R3 と Scope の入力 1 MΩ の並列 (90.9 kΩ) で、τ = 1 µF × 90.9 kΩ ≈ 91 ms。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RECT の山 | 0.50 V | 入力の振幅そのまま。順方向電圧が残らない |
| RECT の平均 (テスター) | 約 0.16 V | 半波の平均 = 振幅 / π。交流電圧計はこの値を目盛に換算する |
| U1 の出力 (D1・D2 の間、18 列) | 約 −0.5 V〜+1.0 V | RECT より順方向電圧だけ高い所と、0 V より順方向電圧だけ低い所を行き来する |
| HOLD (テスター) | 約 0.49 V | 山の値を持ち続ける |
| HOLD の 1 周期の下がり | 約 5.5 mV | 0.5 V × 1 ms / 91 ms。τ を周期より十分長くすると下がりが減る |
| W1 を止めた後の HOLD | 約 91 ms で 0.18 V (1/e) に下がる | 振幅が減ったら τ で追いかける。τ が長いほど保持はよく、追いかけは遅い |
| 比べ: ダイオード 1 本 + 10 kΩ の半波 | 山 約 0.12 V | 0.5 V の信号は順方向電圧に食われてほとんど通らない |

ピークホールドの C1 には、漏れと誘電吸収 (放電した後に電圧が少し戻る現象) の小さいフィルムコンデンサを使う。
電解コンデンサは漏れ電流が大きく、保持の間に電圧が下がる。

## LTspice での確かめ

`sim/12-precision-rectifier.cir` で図1 を過渡解析で 1 秒走らせ、最後の 0.1 秒を読んだ。比べの「ダイオード 1 本の半波」も同じファイルで解いた。
オペアンプは 1 極の簡易模型 (GBW 1 MHz・スルーレート 0.3 V/µs・出力は V+ − 1.5 V と V− + 0.1 V で頭打ち。LM358 相当の**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RECT の山 | 0.50 V | 0.500 V | 合う |
| RECT の平均 | 約 0.16 V | 0.159 V | 合う |
| RECT の谷 | 0 V | −10 mV (切り替わりの瞬間だけ) | 合う (切り替わりのひげは U1 のスルーレートで決まる) |
| U1 の出力 | 約 −0.5 V〜+1.0 V | −0.45 V〜+0.95 V | 合う |
| HOLD の平均 | 約 0.49 V | 0.494 V | 合う |
| HOLD の揺れ | 1 周期 約 5.5 mV の下がり | 0.478〜0.513 V (35 mVpp) | 近い (下の注) |
| ダイオード 1 本の半波の山 | 約 0.12 V | 0.117 V | 合う |

HOLD の揺れが計算の 5.5 mV より大きいのは、U2 の出力が RECT の谷の間に −4.9 V まで飽和し、次の山で HOLD まで戻るのに
スルーレートで約 18 µs かかるため。追いついた所で行き過ぎて C1 を 13 mV ほど余分に充電し、
そのぶん数周期は充電されずに下がる。速い OP アンプにするか、U2 の出力の飽和を止めるダイオードを足すと揺れが減る。

## 出典

自作。
参考: [Precision rectifier (Wikipedia)](https://en.wikipedia.org/wiki/Precision_rectifier)、[Peak detector (Wikipedia)](https://en.wikipedia.org/wiki/Peak_detector)、[TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)
