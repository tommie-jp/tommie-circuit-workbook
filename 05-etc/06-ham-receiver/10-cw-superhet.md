---
book: etc
chapter: 6
id: 6-10
title: CW 用スーパーヘテロダイン — SA612 2 個と水晶ラダーフィルタで逆サイドの混信を落とす
tier: 300
source: 自作
board: PF
---

# 6-10 CW 用スーパーヘテロダイン — SA612 2 個と水晶ラダーフィルタで逆サイドの混信を落とす

[6-5 のダイレクトコンバージョン受信機](05-direct-conversion.md) は、局発の 700 Hz 上の局も 700 Hz 下の局も同じ 700 Hz の音にする。
聞きたい局の反対側 (**逆サイド**) にいる局が、同じ大きさで重なって聞こえる。混んだバンドでは、これが一番の弱点になる。

この題では、信号をいったん約 4.9155 MHz の中間周波 (IF) に移し、[6-9 の水晶ラダーフィルタ](09-crystal-ladder-filter.md) (幅 464 Hz) を通してから音にする。
フィルタを通れるのは片側だけなので、逆サイドは計算で 67 dB 落ちる。スーパーヘテロダインの考え方は [01-circuits の 9-10](../../01-circuits/09-rf/10-superheterodyne.md)、
ミキサーの働きは [05-etc の第 3 章](../03-mixer-2sc1815/01-mixer.md) で扱った。ブロック図は [6-1](01-block.md) にある。

- 第 1 ミキサー (SA612) が 7 MHz を IF に移す。局発は Si5351 の CLK0
- 水晶ラダーフィルタが IF の 464 Hz 幅だけを通す
- 第 2 ミキサー (SA612) が IF を 700 Hz の音にする (**プロダクト検波**)。相手の発振は BFO (うなり周波数発振。Si5351 の CLK1)
- 音声段は [6-4](04-audio-lm386.md) のブレッドボードをそのまま使う

**規模**: 新しく足す IC は SA612 が 2 個 (Si5351 モジュールと Pico 2 は 6-5、LM386 は 6-4 の物を使い回す。合わせて 5 個)。
新しく組む基板はユニバーサル基板 2 枚 (5×7 cm と 7×9 cm。5×7 cm に直して 3 枚ぶん)、基板の間の信号は 5 本 (LO・BFO・IF・AFA・AFB) で、上限の内に収まる。

> [!WARNING]
> **実機では組んでいない (未測定)。** 数は算術の値で、水晶の定数は 6-9 と同じ見積りを使った。組んだら 6-9 の手順で通過帯域の中心を測り、
> 局発と BFO の周波数をその値で決め直す。

## 周波数の計画

IF は、水晶に刷ってある 4.9152 MHz ではなく、**6-9 で測った通過帯域の中心 f<sub>0</sub>** を使う。見積りの定数では 4.915514 MHz (水晶の直列共振より 314 Hz 上)。

| 受信する周波数 | 第 1 局発 (CLK0) = 受信 − f<sub>0</sub> | BFO (CLK1) = f<sub>0</sub> + 700 Hz |
| --- | --- | --- |
| 7.000 MHz | 2.084486 MHz | 4.916214 MHz |
| 7.030 MHz | 2.114486 MHz | 4.916214 MHz |
| 7.200 MHz | 2.284486 MHz | 4.916214 MHz |

同調するときに動かすのは第 1 局発だけで、BFO は動かさない。

### イメージと、局発を上に置く案

ミキサーは和と差の両方を出す。局発 2.114486 MHz のとき、IF に落ちる入力は 2 つある。

- 7.030 MHz (差: 7.030 − 2.114 = 4.916)。聞きたい信号
- **2.801 MHz** (和: 2.801 + 2.114 = 4.916)。これが**イメージ**で、受信周波数 − 2 × f<sub>0</sub> の絶対値にあたる

イメージを落とすのは、ミキサーの前の同調回路 ([6-3](03-input-tuning.md)) だけ。局発は Si5351 の方形波なので、3 倍・5 倍の成分でも混合が起きる。
下の表は 6-3 の式 (結合係数 1、負荷 1.5 kΩ (キロオーム。Ω はオーム)、負荷時の Q 5.4) で計算した、7.030 MHz を 0 dB としたときの同調回路の減衰。

| 入力の周波数 | 何か | 同調回路の減衰 | 混合の強さ |
| --- | --- | --- | --- |
| 2.801 MHz | 下側の局発のイメージ | −21.2 dB | 0 dB |
| 1.428 MHz | 局発の 3 倍との差 (**中波放送の帯**) | −28.2 dB | −9.5 dB |
| 5.657 MHz | 局発の 5 倍との差 | −8.5 dB | −14.0 dB |
| 9.886 MHz | 局発の 7 倍との差 (31 m バンドの放送の端) | −11.5 dB | −16.9 dB |
| 4.916 MHz | IF そのもの (ミキサーを素通りする分) | −12.4 dB | SA612 の平衡で決まる |
| 16.861 MHz | **上側の局発**にしたときのイメージ | −20.4 dB | 0 dB |
| 30.921 MHz | 上側の局発の 3 倍との差 | −26.9 dB | −9.5 dB |

局発を上 (受信 + f<sub>0</sub> = 11.945514 MHz) に置いても、イメージの減衰は 20 dB 前後で変わらない。違いは高調波の応答の場所に出る。

| | 下側の局発 (2.1 MHz 台。この題の標準) | 上側の局発 (11.9 MHz 台) |
| --- | --- | --- |
| イメージ | 2.8 MHz。夜でも静かな帯 | 16.9 MHz。昼は放送の帯 (16 m) の近く |
| 高調波の応答 | 1.43 MHz (中波放送)・5.7 MHz・9.9 MHz に出る | 30 MHz より上で、同調回路がよく落とす |
| IF の向き | 反転しない (受信周波数が上がると IF も上がる) | 反転する |

**近くに強い中波局がある所では、上側に替える。** 替えるのは CLK0 の数だけで、回路は同じ。そのときは BFO を f<sub>0</sub> + 700 Hz のままにしておけば、
音の高さの向きだけが逆になる。同調回路 1 段の 21 dB は心もとないので、夜に放送が混じるなら 6-3 の同調回路を 2 段にするのが次の手になる。

### BFO をどちら側に置くか

BFO は通過帯域の中心から 700 Hz 離して置く。音の高さは「BFO − IF」の絶対値なので、IF で BFO の反対側 700 Hz にある信号も 700 Hz の音になる。
これがスーパーヘテロダインでの逆サイドで、フィルタの中心から 1.4 kHz 離れている。

| BFO の位置 | 逆サイドが IF に来る所 | 逆サイドの抑圧 (フィルタ単体、6-9) | 整合を入れた値 |
| --- | --- | --- | --- |
| **上 (f<sub>0</sub> + 700 Hz)** | f<sub>0</sub> + 1.4 kHz | −69 dB | **−67 dB** |
| 下 (f<sub>0</sub> − 700 Hz) | f<sub>0</sub> − 1.4 kHz | −59 dB | −56 dB |

ラダーフィルタは上側の裾が急なので (水晶の並列共振が上にあるため)、**BFO は上に置く**。このとき受信周波数を上げると音は低くなる。
BFO の位置は、フィルタの裾で −40 dB の所にあたる。BFO そのものが IF の経路に漏れても、第 2 ミキサーでは直流になるだけで音にはならない。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 ラダーフィルタの裾と BFO の位置 (IF の中心を 0 Hz・0 dB に置く)
x: IFの中心からのずれ Hz -2500..2500
y: 通過量 dB -90..0
lines:
  フィルタと整合 dB:
    - -2500 -72.9
    - -2400 -71.8
    - -2300 -70.6
    - -2200 -69.4
    - -2100 -68.1
    - -2000 -66.7
    - -1900 -65.3
    - -1800 -63.7
    - -1700 -62.1
    - -1600 -60.3
    - -1500 -58.5
    - -1400 -56.4
    - -1300 -54.2
    - -1200 -51.8
    - -1100 -49.2
    - -1000 -46.3
    - -900 -43.0
    - -800 -39.4
    - -750 -37.3
    - -700 -35.2
    - -650 -32.9
    - -600 -30.3
    - -550 -27.6
    - -500 -24.6
    - -450 -21.3
    - -400 -17.6
    - -350 -13.4
    - -300 -8.9
    - -250 -4.4
    - -200 -1.2
    - -150 -0.2
    - -100 -0.0
    - -50 -0.0
    - 0 0.0
    - 50 -0.1
    - 100 -0.2
    - 150 -0.3
    - 200 -1.3
    - 250 -4.4
    - 300 -9.4
    - 350 -14.5
    - 400 -19.2
    - 450 -23.4
    - 500 -27.3
    - 550 -30.8
    - 600 -34.0
    - 650 -37.0
    - 700 -39.7
    - 750 -42.3
    - 800 -44.8
    - 900 -49.3
    - 1000 -53.4
    - 1100 -57.2
    - 1200 -60.7
    - 1300 -63.9
    - 1400 -67.0
    - 1500 -69.8
    - 1600 -72.6
    - 1700 -75.1
    - 1800 -77.6
    - 1900 -80.0
    - 2000 -82.3
    - 2100 -84.5
    - 2200 -86.6
    - 2300 -88.7
    - 2400 -90.7
    - 2500 -92.7
notes:
  - mark 0
  - mark 700
  - mark 1400
  - mark -1400
  - band -232 232: 通過帯域 464 Hz
  - text -800 -6dB: 聞きたい信号
  - text 1050 -12dB: BFO
  - text 1950 -58dB: 逆サイド
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/graph/10-cw-superhet.svg)

図5 の線は計算値 (SA612 の 1.5 kΩ・L 型の整合・水晶 4 個)。−3 dB の幅 464 Hz を帯で示した。
音にすると、聞こえるのは 468〜932 Hz の高さの信号だけで、それより高い音・低い音になる局は急に小さくなる。

### Si5351 の 2 つの出力は PLL を分ける

Si5351A には PLL が 2 つ (A・B) ある。6-5 と同じく「PLL を分数で細かく動かし、出力の分周は偶数の整数に固定する」やり方を守ると、
1 つの PLL から出せる 2 つの周波数は整数比に縛られる。第 1 局発は同調で動かし、BFO は動かさないので、**CLK0 は PLL A、CLK1 は PLL B** に分ける。

| 出力 | 周波数 | PLL | VCO | 出力の分周 | PLL の倍率 a + b/1048575 | 刻み |
| --- | --- | --- | --- | --- | --- | --- |
| CLK0 (7.030 MHz 用) | 2.114486 MHz | A | 634.3458 MHz | 300 | 25 + 391991/1048575 | 0.079 Hz |
| CLK1 (BFO) | 4.916214 MHz | B | 737.4321 MHz | 150 | 29 + 521440/1048575 | 0.159 Hz |

7.000〜7.200 MHz の全部で、分周 300 のまま VCO は 625〜685 MHz に収まる (範囲は 600〜900 MHz)。

[6-5](05-direct-conversion.md) のプログラムからの変更は 3 つで、完全なプログラムはここには載せない。

1. 周波数から PLL の a・b と分周比を決めて書き込む関数を、**PLL (A か B) と出力の番号 (0 か 1)** を引数に取る形にする。
   書き込み先は PLL A がレジスタ 26〜33、PLL B が 34〜41、出力 0 の分周が 42〜49、出力 1 が 50〜57
2. 出力 1 の制御 (レジスタ 17) で**分周の源を PLL B** にする (ビット 5 を 1)。出力を有効にするレジスタ 3 で CLK0 と CLK1 の両方を出す。
   書き終えたら 2 つの PLL をリセットする (レジスタ 177)
3. 同調で書き換えるのは PLL A だけにする。表示は「CLK0 + f<sub>0</sub>」を受信周波数として出し、f<sub>0</sub> と BFO は定数にまとめて、測った値に直せるようにする

レジスタの番号と意味は Skyworks の AN619 による。**実機では動かしていない。**

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フロントエンドの基板 (入力の同調と第 1 ミキサー)
parts:
  J1: sma 2,6.25 mirror ANT
  G1: ground 2,9
  T1: transformer 5,7
  C1: capacitor 7.5,6 7.5,8 100p
  TC1: capacitor-var 10.5,6 10.5,8 50p
  C2: capacitor 12.5,8 12.5,10 10n
  G2: ground 12.5,10
  U1: ic 17,7 SA612
  VCC: vcc 17,2 5V
  C3: capacitor 15,3 15,4.5 100n
  G3: ground 15,4.5
  C4: ecap 12.5,3 12.5,4.5 10u
  G4: ground 12.5,4.5
  G5: ground 17,9.5
  LO: port 9,12
  R1: resistor 10,12 12,12 1k
  R2: resistor 12,12 12,14 100
  G6: ground 12,14
  C5: capacitor 12,12 14,12 1n
  C6: capacitor 20.5,7 20.5,9 47p
  G7: ground 20.5,9
  L1: inductor 21.5,7 23.5,7 18u
  IF: port 25,7
wires:
  - J1.1 -| T1.A1
  - J1.2 -- 2,9
  - T1.A2 -| 3.5,9
  - 3.5,9 -- 2,9
  - T1.B1 -| 6.5,6
  - 6.5,6 -- 7.5,6 -- 10.5,6 -- 14,6
  - 14,6 |- U1.IN_A
  - T1.B2 -| 6.5,8
  - 6.5,8 -- 7.5,8 -- 10.5,8 -- 12.5,8 -- 13.5,8
  - 13.5,8 |- U1.IN_B
  - U1.VCC |- 17,3
  - 17,2 -- 17,3
  - 17,3 -- 15,3 -- 12.5,3
  - U1.GND |- 17,9.5
  - 9,12 -- 10,12
  - 14,12 -- 14.5,12
  - U1.OSC_B -| 14.5,12
  - U1.OUT_A -| 20.5,7
  - 20.5,7 -- 21.5,7
  - 23.5,7 -- 25,7
notes:
  - text 5,5 small center: "T37-2 4 回 : 32 回"
  - text 22.5,5.6 small center: "FT37-61 18 回"
  - text 7,10.4 small left: "Si5351 の CLK0 から"
  - text 7,11 small blue left: "2.1145 MHz・約 3 Vpp"
  - text 15,12.6 small blue left: "約 0.3 Vpp"
  - text 24.5,8 small left: "IF の基板へ"
  - text 24.5,8.6 small blue left: "4.9155 MHz・約 240 Ω"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/10-cw-superhet-1.svg)

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 IF の基板 (水晶ラダーフィルタと第 2 ミキサー)
parts:
  IF: port 2,7
  C7: capacitor 3,7 5,7 220p
  X1: crystal 5,7 7.5,7 4.9152M
  X2: crystal 7.5,7 10,7 4.9152M
  X3: crystal 10,7 12.5,7 4.9152M
  X4: crystal 12.5,7 15,7 4.9152M
  C8: capacitor 7.5,7 7.5,9.5 220p
  C9: capacitor 10,7 10,9.5 220p
  C10: capacitor 12.5,7 12.5,9.5 220p
  G1: ground 10,9.5
  C11: capacitor 15,7 17,7 220p
  L2: inductor 17.5,7 19.5,7 18u
  C12: capacitor 20.5,7 20.5,9.5 47p
  C13: capacitor 23,7.5 23,9.5 10n
  U2: ic 27.5,7.5 SA612
  VCC: vcc 27.5,2.5 5V
  C14: capacitor 25.5,3.5 25.5,5 100n
  G3: ground 25.5,5
  C15: ecap 23,3.5 23,5 10u
  G4: ground 23,5
  G5: ground 27.5,10
  BFO: port 16,12.5
  R3: resistor 17,12.5 19,12.5 1k
  R4: resistor 19,12.5 19,14.5 100
  G6: ground 19,14.5
  C16: capacitor 19,12.5 21,12.5 1n
  AFA: port 31.5,7.5
  AFB: port 31.5,8
wires:
  - 2,7 -- 3,7
  - 17,7 -- 17.5,7
  - 7.5,9.5 -- 10,9.5 -- 12.5,9.5 -- 20.5,9.5 -- 23,9.5
  - 19.5,7 -- 20.5,7
  - 20.5,7 -| U2.IN_A
  - 23,7.5 -| U2.IN_B
  - U2.VCC |- 27.5,3.5
  - 27.5,2.5 -- 27.5,3.5
  - 27.5,3.5 -- 25.5,3.5 -- 23,3.5
  - U2.GND |- 27.5,10
  - 16,12.5 -- 17,12.5
  - 21,12.5 -- 25,12.5
  - U2.OSC_B -| 25,12.5
  - U2.OUT_A -| 31.5,7.5
  - U2.OUT_B -| 31.5,8
notes:
  - text 18.5,5.6 small center: "FT37-61 18 回"
  - text 14.5,10.9 small left: "Si5351 の CLK1 から (BFO)"
  - text 14.5,11.5 small blue left: "4.9162 MHz・約 3 Vpp"
  - text 25.5,13.1 small blue left: "約 0.3 Vpp"
  - text 2,8 small left: "約 240 Ω"
  - text 30.5,9 small left: "音声段 (6-4) へ"
  - text 30.5,9.6 small blue left: "700 Hz・差動"
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/circuit/10-cw-superhet-2.svg)

- **入力の同調 (T1・C1・TC1)** は 6-3 と同じ。2 次の巻線は U1 の IN_A と IN_B の間に入れ、IN_B を C2 (10 nF) で GND に落とす。
  IN_A・IN_B は IC の中でバイアスされているので、巻線の片側を GND に直結しない
- **局発の入口 (R1・R2・C5 と R3・R4・C16)** は 6-5 と同じ形。Si5351 の約 3 Vpp を 1 kΩ と 100 Ω で約 0.3 Vpp にして、1 nF で OSC_B へ入れる。OSC_E は開けておく
- **L 型の整合 (C6・L1 と L2・C12)** は 6-9 の「6-10 でのつなぎ方」の値。SA612 の 1.5 kΩ を、フィルタから見て約 240 Ω にする。
  18 µH (マイクロヘンリー) は FT37-61 に 18 回。フィルタの両端の 220 pF (C7・C11) が直流を切るので、結合コンデンサは別に要らない
- **水晶ラダーフィルタ (X1〜X4・C7〜C11)** は 6-9 の回路から、測るための 150 Ω を外した物。6-9 で選んだ 4 個の水晶と 220 pF をそのまま移す
- **U1 の OUT_B は使わない** (開ける)。フィルタへは OUT_A の片側だけで渡す
- **U2 の OUT_A・OUT_B (AFA・AFB)** は差動のまま 6-4 の音声段へ渡す。6-4 のブレッドボードの R1・R2 (SA612 の代わりの 1.5 kΩ) と R3 を抜き、
  A 点 (15 列) に AFA、B 点 (16 列) に AFB をつなぐ。47 nF と結合の 10 nF 2 個は 6-4 の基板にある

### 利得の配分

| 段 | 利得 (見積り) | 根拠 |
| --- | --- | --- |
| 入力の同調回路 | +7.8 dB (アンテナの開放電圧から IN_A まで) | 6-3 の式。巻数比 8 の昇圧 |
| 第 1 ミキサー | +17 dB | SA612A の資料の代表値 |
| フィルタと整合 | −4.8 dB | 6-9。コイルの Q を 80 と置いた値 (損失なしなら −4.5 dB) |
| 第 2 ミキサー | +17 dB | 同上 |
| 音声段 | +43.55 dB (700 Hz) | 6-4 |
| **IN_A から音声出力まで** | **約 72.8 dB** | 6-5 は 17 + 43.55 = 60.5 dB |

IF の増幅段も AGC (自動利得制御) も入れていない。理由は 3 つある。

- ミキサー 2 個で、6-5 より 12 dB 多い利得がもう取れている。7 MHz では外から来る雑音が受信機の雑音より大きいので、これ以上増やしても聞こえる局は増えない
- 増幅段を足すと、フィルタの前後の回り込み (入力から出力へ基板の上を飛び越える分) が効いてきて、67 dB の裾が保てなくなる
- 新しい原理はフィルタと BFO の 2 つで足りる。AGC は [01-circuits の 9-25](../../01-circuits/09-rf/25-agc.md) で扱った

限界もはっきりしている。強い局では LM386 が先に頭を打ち、音が割れる (ヘッドホンでは耳に痛い)。音量を変える所が無いので、
強い局にはアンテナとの間に減衰器を入れる。IF の基板の下半分は、増幅段や AGC を足すときのために空けてある。

## 実体配線図

7 MHz と 4.9 MHz はユニバーサル基板の範囲 (10 MHz 以下・短い配線) の内。ブレッドボードは穴の列の間の容量 (数 pF) が同調回路と整合を狂わせ、
フィルタの裾も回り込みで浅くなるので使わない。基板は 2 枚に分けた。分け目は L1 と C7 の間で、ここは約 240 Ω と低く、線を延ばしても乱れにくい。
フィルタの入口と出口を離すため、IF の基板は 7×9 cm を横に使い、信号を左から右へ一直線に並べた (5×7 cm では折り返しが要り、入口と出口が近づく)。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
unused: [U1.OUT_B, U1.OSC_E]
title: 図3 フロントエンドの基板 (部品面。5×7 cm を横に使う)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  VCC: 016
  GND: y2
  LO: w15
  IF: w9
parts:
  J1: sma/female-edge a10 09
  T1: transformer/toroid d10 d7 h10 h7 T37-2 4t:32t
  C1: capacitor/ceramic j10 j7 100p
  TC1: capacitor/ceramic l10 l7 50p
  C2: capacitor/ceramic n7 n4 10n
  U1: dip8 o13 SA612
  C3: capacitor/ceramic m16 m18 100n
  C4: capacitor/electrolytic k16 k18 10u v=16V
  R1: resistor t14 w14 1k
  R2: resistor s15 s18 100
  C5: capacitor/ceramic q14 s14 1n
  C6: capacitor/ceramic s9 s6 47p
  L1: inductor/toroid s10 w10 FT37-61 18t
wires:
  - a10 -- d10 white
  - h10 -- j10 yellow
  - j10 -- l10 yellow
  - l10 -- o10 yellow
  - h7 -- j7 blue
  - j7 -- l7 blue
  - l7 -- n7 blue
  - n7 -- p7 blue
  - p7 -- p10 blue
  - 09 -- a9 black
  - a9 -- a2 black
  - a2 -- d2 black
  - d7 -- d2 black
  - d2 -- n2 black
  - n4 -- n2 black
  - n2 -- q2 black
  - q10 -- q2 black
  - q2 -- s2 black
  - s6 -- s2 black
  - s2 -- x2 black
  - x2 -- y2 black
  - x2 -- x18 black
  - x18 -- s18 black
  - s18 -- m18 black
  - m18 -- k18 black
  - VCC -- k16 red
  - k16 -- m16 red
  - m16 -- o16 red
  - o16 -- o13 red
  - LO -- w14 green
  - t14 -- s14 green
  - s14 -- s15 green
  - q14 -- q13 green
  - r10 -- s10 orange
  - s10 -- s9 orange
  - w10 -- IF orange
notes:
  - mark w9 yellow
  - text w8 red large bold center: 1+
  - mark x5 yellow
  - text w5 red large bold left: 1-
  - text i4 yellow bold center: TC1 はトリマ (図は固定の形)
  - parts
style:
  back: on
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/perfboard/10-cw-superhet-1.svg)

- 番地は基板の刷りどおり (英字が列、数字が下からの行)。J1 は端面の SMA で、アンテナか試験の信号をつなぐ
- GND は 2 行 (下) と 18 行 (上) の筋で、右端の X 列でつないだ。上の筋には C3・C4 と R2 が落ちる
- +5 V は左の縁の銅箔 (16 行) から赤い線で U1 の 8 番へ。LO (w15)・IF (w9) と GND (y2) は、基板の外へ出る線を半田付けする穴
- T1 は左がリンク 4 回 (d10・d7)、右が 2 次 32 回 (h10・h7)。**TC1 はトリマコンデンサ** (フェンスに形が無いので固定の形で描いた)
- L1 (FT37-61 に 18 回) は s10 と w10 の間。C6 (47 pF) は U1 の 4 番のすぐ下
- 黄色の丸は Analog Discovery 3 で挟む所 (1+ が IF、1− が GND)。半田付けはしない

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
unused: [U2.OSC_E]
title: 図4 IF の基板 (部品面。7×9 cm を横に使う)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
points:
  IF: 016
  GND: 013
  VCC: 022
  BFO: z24
  AFA: ad15
  AFB: ad20
parts:
  C7: capacitor/ceramic a16 c16 220p
  X1: crystal/hc49 d16 f16 4.9152M
  C8: capacitor/ceramic g16 g13 220p
  X2: crystal/hc49 h16 j16 4.9152M
  C9: capacitor/ceramic k16 k13 220p
  X3: crystal/hc49 l16 n16 4.9152M
  C10: capacitor/ceramic o16 o13 220p
  X4: crystal/hc49 q16 s16 4.9152M
  C11: capacitor/ceramic t16 u16 220p
  L2: inductor/toroid v16 z16 FT37-61 18t
  C12: capacitor/ceramic z15 z13 47p
  U2: dip8 aa19 SA612
  C13: capacitor/ceramic ab14 ac14 10n
  C14: capacitor/ceramic y22 y25 100n
  C15: capacitor/electrolytic w22 w25 10u v=16V
  C16: capacitor/ceramic ac20 ac22 1n
  R3: resistor ac23 z23 1k
  R4: resistor ad22 ad25 100
wires:
  - IF -- a16 orange
  - c16 -- d16 orange
  - f16 -- g16 orange
  - g16 -- h16 orange
  - j16 -- k16 orange
  - k16 -- l16 orange
  - n16 -- o16 orange
  - o16 -- q16 orange
  - s16 -- t16 orange
  - u16 -- v16 orange
  - z16 -- aa16 yellow
  - z16 -- z15 yellow
  - ab16 -- ab14 blue
  - GND -- a13 black
  - a13 -- g13 black
  - g13 -- k13 black
  - k13 -- o13 black
  - o13 -- z13 black
  - z13 -- ab13 black
  - ab13 -- ac13 black
  - ac16 -- ac14 black
  - ac14 -- ac13 black
  - ac13 -- ae13 black
  - ae13 -- ae25 black
  - ae25 -- ad25 black
  - ad25 -- y25 black
  - y25 -- w25 black
  - VCC -- w22 red
  - w22 -- y22 red
  - y22 -- aa22 red
  - aa22 -- aa19 red
  - BFO -- z23 green
  - ac23 -- ac22 green
  - ac22 -- ad22 green
  - ac20 -- ac19 green
  - ad16 -- AFA white
  - ad19 -- AFB white
notes:
  - mark ad15 yellow
  - text ad14 red large bold center: 1+
  - mark ae18 yellow
  - text ae18 red large bold right: 1-
  - text p8 yellow bold center: 下半分は空き (IF の増幅段を足すときの場所)
  - parts
style:
  back: on
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/perfboard/10-cw-superhet-2.svg)

- 16 行が信号の筋。左の縁の銅箔 (IF) から C7・X1〜X4・C11・L2 と並び、U2 の 1 番 (aa16) に入る。並列の 220 pF (C8〜C10) は 13 行の GND の筋へ落とす
- 水晶のケースは、4 個を細い線で結んで GND の筋に半田付けすると、手を近づけたときの変化が減る (図には描いていない)
- +5 V は左の縁の銅箔 (22 行)、GND は 13 行。上の GND の筋 (25 行) へは右端の AE 列で渡した
- BFO は z24 の穴から R3・C16 を通って U2 の 6 番へ。AFA (ad15)・AFB (ad20) から 6-4 のブレッドボードへ、撚った 2 本の線で渡す
- 2 枚の基板の間は、IF と GND の 2 本を短く (5 cm 以内) 撚ってつなぐ。LO と BFO は Si5351 から別々の線で、それぞれ GND の線を添える
- 5 V は 6-4 の音声段のブレッドボードの + のレールから 2 枚へ配る。SA612 は 1 個 2.4 mA (代表値) しか流さない

## 計器の設定

信号発生器は Analog Discovery 3 (AD3) の Wavegen W1。受信機の利得が 6-5 より 12 dB 高いので、章の標準の減衰器 (5.1 kΩ + 51 Ω、−40 dB) の後ろに
510 Ω + 51 Ω をもう 1 段足す。W1 が 20 mV<sub>p</sub> のとき、J1 に入るのは開放で約 16.5 µV<sub>p</sub> (源の抵抗は約 47 Ω)。

| 項目 | 設定 |
| --- | --- |
| Wavegen W1 | Sine、7.030000 MHz、振幅 20 mV、オフセット 0 V。減衰器 2 段を通して J1 へ |
| Si5351 | CLK0 = 2.114486 MHz、CLK1 = 4.916214 MHz |
| Scope CH1 | 6-4 の音声出力 (1+)、GND (1−)。100 mV/div、500 µs/div |
| Spectrum (フロントエンドだけを見るとき) | CH1 を図3 の IF の穴へ。中心 4.9155 MHz、幅 20 kHz、縦軸 dBm |

AD3 を図3 の基板の図に箱で描かないのは、測るときだけ挟む接続だから (黄色の丸で示した)。W1 は SMA のケーブルで J1 へ入れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図6 音声出力 (W1 = 7.030000 MHz、局発 2.114486 MHz、BFO 4.916214 MHz)
time: 500us/div
trigger: ch1 rising 0V
ch1: sine 700Hz 180mV
cursors: [0, 1.4286ms]
measure: [freq, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/06-ham-receiver/scope/10-cw-superhet.svg)

**基板 1 枚ずつ確かめる。** 動かないときは、この順で原因を 1 枚に絞る。

1. **音声段だけ**: 6-4 の手順で 700 Hz が出ることを確かめる (R1〜R3 を挿した状態)
2. **IF の基板だけ**: 6-4 の R1〜R3 を抜いて AFA・AFB をつなぐ。W1 を 4.915514 MHz にして、減衰器 1 段 (−40 dB) で IF の銅箔へ入れる。
   BFO を出すと 700 Hz が聞こえる。W1 を 100 Hz ずつ動かして、音が大きい範囲 (幅 約 460 Hz) の真ん中を探し、その周波数を f<sub>0</sub> として控える。
   BFO を f<sub>0</sub> + 700 Hz に書き直す。この確かめでは源が 50 Ω で整合が外れるので、通過帯域は波打つ (位置を知るには足りる)
3. **フロントエンドの基板だけ**: IF の穴と GND の間に 240 Ω を仮に付け、W1 を 7.030 MHz・200 mV・減衰器 1 段にする。
   AD3 の Spectrum で IF の穴に 4.9155 MHz の線が立つ (約 14 mV<sub>p</sub>。見積り)。TC1 を回して線が一番高くなる所に合わせる
4. **全部つなぐ**: 240 Ω を外し、表の設定にして 700 Hz を聞く

AD3 の基準と Si5351 の水晶には、それぞれ数十 ppm の誤差がある。7 MHz の 30 ppm は 210 Hz で、通過帯域の幅の半分に近い。
最初に音が出なければ、W1 を ±500 Hz の範囲で動かして探す。

## 見るべき値

計算値と見積り。**実機では組んでいない (未測定)。**

| 測る所 | 期待する値 |
| --- | --- |
| 音声出力 (W1 = 7.030000 MHz) | 700 Hz の正弦波、約 0.18 V<sub>p</sub> (0.36 Vpp)。利得の見積りに ±6 dB の幅がある |
| W1 を 100 Hz 上げる (7.030100 MHz) | 音は 600 Hz に**下がる** (BFO が上にあるため) |
| 音が大きい範囲 | W1 = 7.029768〜7.030232 MHz (幅 464 Hz)。音の高さで 932〜468 Hz |
| **逆サイド** (W1 = 7.031400 MHz) | 同じ 700 Hz の音だが **67 dB 小さい** (雑音に埋もれる。W1 を 40 dB 上げて、やっと 8 mV<sub>p</sub>) |
| 6-5 で同じことをする (局発の 700 Hz 上と下) | 2 か所で同じ大きさ。この差がこの題の成果 |
| イメージ (W1 = 2.801 MHz) | 700 Hz が出るが、7.030 MHz のときより 21 dB 小さい |
| BFO を f<sub>0</sub> − 700 Hz に替える | 音の高さの向きが逆になり、逆サイドの抑圧は 56 dB に減る |
| 電源の電流 (基板 2 枚) | 約 5 mA (SA612 が 2.4 mA × 2。代表値) |

- 0.18 V<sub>p</sub> は、16.5 µV × 2.45 (同調回路の昇圧) × 4365 (72.8 dB) の計算
- 67 dB は、回り込みが無いときの値。基板の上で入口と出口が結合すると浅くなる。50 dB より浅ければ、2 枚の基板を離し、IF の線を撚り直す
- 逆サイドを測るときは W1 を上げるので、聞きたい側ではヘッドホンを外す

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1・U2 | SA612A (DIP8) | 第 1 ミキサーと第 2 ミキサー。NE602・NE612 でも同じ |
| T1 | T37-2 に 4 回 : 32 回 | 6-3 と同じ。φ0.3 mm の UEW |
| C1・TC1 | 100 pF (記号 101、C0G)・トリマ 50 pF | 6-3 と同じ |
| L1・L2 | 18 µH — FT37-61 に 18 回 | L 型の整合。φ0.3 mm の UEW |
| C6・C12 | 47 pF (記号 470、C0G) | L 型の整合。SA612 のピンのすぐそばに |
| X1〜X4 | 水晶振動子 4.9152 MHz (HC-49/S) | 6-9 で測って選んだ 4 個 |
| C7〜C11 | 220 pF (記号 221、C0G) | 6-9 の 5 個 |
| C2・C13 | 10 nF (記号 103) | IN_B を GND へ |
| C5・C16 | 1 nF (記号 102) | 局発と BFO の結合 |
| R1・R3 / R2・R4 | 1 kΩ / 100 Ω | 局発と BFO を約 0.3 Vpp に落とす |
| C3・C14 / C4・C15 | 100 nF (記号 104) / 10 µF 16 V | 電源のデカップリング |
| J1 | 端面の SMA (メス) | アンテナと試験の入口 |
| 基板 | ユニバーサル基板 5×7 cm と 7×9 cm | 厚さ 1.6 mm の FR-4 |
| 試験の減衰器 | 5.1 kΩ・510 Ω・51 Ω × 2・240 Ω | 基板の外で組む。240 Ω は手順 3 の仮の負荷 |
| 電源 | 5 V | 既定の電源 |

Si5351 モジュールと Pico 2 は 6-5、LM386 の音声段は 6-4 の物を使う。局発が方形波なので、アンテナへ漏れる分は同調回路と SA612 の平衡で小さく抑えられる。
基板の外へ長い線を出さなければ、微弱の範囲に収まる。

## LTspice での確かめ

この題は**算術 (Python) で確かめた**。回路で決まる数は、6-9 の水晶の模型と 6-3 の同調回路の式の組み合わせで出るので、それぞれの題のスクリプトを呼んで計算した
([sim/10-superhet.py](sim/10-superhet.py)。`python3 -I 10-superhet.py`)。ミキサー (SA612) の中身は SPICE の模型が無く、変換利得は資料の代表値を置いた。

| 確かめること | 本文の数字 | 算術の値 | 判定 |
| --- | --- | --- | --- |
| フィルタと整合: 損失・幅・中心 | 4.5 dB (Q 80 で 4.8 dB)・464 Hz・4.915514 MHz | 4.47 dB (4.78 dB)・464 Hz・4.915514 MHz | 合う (6-9 と同じ) |
| 逆サイド (BFO が上 / 下)、整合込み | −67 dB / −56 dB | −67.0 dB / −56.4 dB | 合う |
| 局発 (7.000・7.030・7.200 MHz) | 2.084486・2.114486・2.284486 MHz | 同じ | 合う |
| イメージ (下側 / 上側) と同調回路の減衰 | 2.801 MHz −21.2 dB / 16.861 MHz −20.4 dB | 同じ | 合う |
| 同調回路: 幅と Q | 6-3 の 1.32 MHz・5.4 | 1.32 MHz・5.4 | 合う (6-3 と同じ) |
| Si5351: CLK0 と CLK1 の a・b | 25 + 391991/1048575、29 + 521440/1048575 | 実際の出力 2114486.01 Hz・4916214.07 Hz | 合う |
| 利得の合計 | 約 72.8 dB | 72.8 dB | 合う (各段は見積り) |

確かめていない物: SA612 の変換利得と平衡、基板の上の回り込み、水晶の実物の定数、Si5351 の 2 つの出力の間の漏れ。どれも実機で測る物。

## 出典

自作。SA612A の入出力の抵抗 1.5 kΩ・変換利得の代表値 17 dB・外からの局発の入れ方は NXP の SA612A データシートと応用ノート AN1983、
Si5351 の PLL と分周の決まりは [Skyworks の Si5351 データシート](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/data-sheets/Si5351-B.pdf) と
[AN619 (レジスタの表)](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/application-notes/AN619.pdf) による。
フィルタと整合の値は [6-9](09-crystal-ladder-filter.md)、同調回路は [6-3](03-input-tuning.md)、音声段は [6-4](04-audio-lm386.md) の値。

参考: [スーパーヘテロダイン受信機 (Wikipedia)](https://ja.wikipedia.org/wiki/スーパーヘテロダイン受信機)、
[Beat frequency oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Beat_frequency_oscillator)、
[Crystal filter (Wikipedia)](https://en.wikipedia.org/wiki/Crystal_filter)
