---
book: analog-discovery
chapter: 5
id: 5-10
title: CR 発振器の帰還路をループを切って測る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-10 CR 発振器の帰還路をループを切って測る

発振回路は「ループを 1 周した信号が、元の信号とぴったり同じ (利得 1・位相 0°)
になる」ときに発振する (バルクハウゼンの条件)。CR 移相発振器を組み、**わざと
帰還路を 1 か所で切り**、そこに Wavegen で信号を注入して、ループを 1 周した
信号がどう変わって戻ってくるかを Network で測る。中級の 5-17 (アンプの位相余裕)
と同じ「ループを切って測る」考え方を、発振回路で先に体験する。

## 回路図

```circuit
title: 図1 CR 移相発振器 (S1 でループを切る)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
  G2: ground c3
  Rin: resistor a5 a7 10k l=$\mathrm{R_{in}}$
  U1: opamp c9 +down
  G3: ground e8
  Rf: resistor a7 a11 300k l=$\mathrm{R_f}$
  C1: capacitor a11 a15 10n l=$\mathrm{C_1}$
  R1: resistor a15 c15 10k l=$\mathrm{R_1}$
  G4: ground c15
  C2: capacitor a15 a19 10n l=$\mathrm{C_2}$
  R2: resistor a19 c19 10k l=$\mathrm{R_2}$
  G5: ground c19
  C3: capacitor a19 a23 10n l=$\mathrm{C_3}$
  M2: voltmeter a23 c23 l=$\mathrm{CH2}$
  G6: ground c23
  S1: switch f5 f7
wires:
  - a1 -- a3
  - a3 -- a5
  - a7 |- U1.-
  - U1.+ -| e8
  - U1.out -| a11
  - a23 -- a24
  - a24 -- f24
  - f24 -- f7
  - f5 -- a5
```

- U1 は反転増幅 (R<sub>in</sub> = 10 kΩ、R<sub>f</sub> = 300 kΩ、利得 = −R<sub>f</sub>/R<sub>in</sub> = −30 倍)。
  U1.+ は GND
- C1・R1・C2・R2・C3 は**移相回路**。すべて C = 10 nF、R = 10 kΩ (R<sub>1</sub>・R<sub>2</sub>・
  R<sub>in</sub> の 3 つがこの回路網の抵抗そのもの)。理想的にはこの 3 段が、
  ある 1 つの周波数でちょうど 180° 位相を遅らせ、振幅を 1/29 に落とす
  (下の「見るべき値」の計算根拠)
- **S1 が帰還路の切れ目。** 閉じれば「U1 出力 → 移相回路 → R<sub>in</sub> → U1 入力」の
  ループが閉じて自励発振になる (この題では発振させない)。**開いて**、代わりに
  W1 (CH1 で監視) を R<sub>in</sub> 側に注入し、移相回路側の応答 (CH2) と比べる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  U1: dip8 @ f5 LM358
  Rin: resistor h6 h9 10k
  Rf: resistor i6 i5 300k
  C1: capacitor g5 g16 10n
  R1: resistor h16 h20 10k
  C2: capacitor i16 i28 10n
  R2: resistor h28 h32 10k
  C3: capacitor g28 g40 10n
  S1: switch j9 j40
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, V-, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - AD.V+ -- a5 red
  - AD.V- -- h8 orange
  - a6 -- a7 green
  - a8 -- -t8 black
  - g7 -- -b7 black
  - AD.W1 -- i9 yellow
  - AD.1+ -- g9 orange [h9]
  - AD.1- -- -t11 black
  - i20 -- -b20 black
  - i32 -- -b32 black
  - AD.2+ -- i40 blue
  - AD.2- -- -t41 black
```

- U1 (LM358) は 5-6 と同じ 1 回路目だけを使う配置。1=OUT1 (f5) が R<sub>f</sub> の
  帰還点、2=IN1− (f6) に R<sub>in</sub>・R<sub>f</sub>、3=IN1+ (f7) は GND へ。**使わない側**は
  5-6 と同じくフォロワにして固定 (`a6--a7`、`a8--(-t8)`)
- IN1+ (g7)・R<sub>1</sub>・R<sub>2</sub> の GND は**下の − レール**に落とす。下の − レールは
  1 列目の黒線 (`-t1--(-b1)`) で上の − レール (AD.GND) とつなぐ。これが無いと
  3 つとも GND から浮いてしまう
- R<sub>in</sub> (6〜9 列) の 9 列側が X (W1 の注入点・CH1・S1)。**R<sub>f</sub> (5〜6 列) は
  IN1− と OUT1 を結ぶ**帰還抵抗。ここまでは 5-6 と同じ考え方
- 移相回路は右へ大きく間隔を空けて 1 段ずつ並べる: C1 (5〜16 列) → ノード A
  (16 列、R1 と C2 がここから分岐) → R1 (16〜20 列、20 列で下レールへ) →
  C2 (16〜28 列) → ノード B (28 列、R2 と C3 がここから分岐) → R2 (28〜32 列、
  32 列で下レールへ) → C3 (28〜40 列) → ノード C (40 列)。**同じ列なら
  行が違ってもつながる**ので、分岐に配線は要らない
- S1 (9〜40 列) が帰還路の切れ目。X (9 列) とノード C (40 列) を直接結ぶ
  1 本。**開いた状態で測定する** (閉じれば自励発振になる)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Sine、周波数を下表のとおり変える、Amplitude 30 mV |
| Network | Start 300 Hz、Stop 1 kHz、Log、Steps 101、Reference: Channel 1。**S1 を開けたまま**掃引する |

## 見るべき値

計算値。移相回路 (C = 10 nF、R = 10 kΩ、3 段、出力は開放) の伝達関数を
回路方程式から求めると、**f₀ = 1/(2πRC√6) ≈ 649.7 Hz で位相がちょうど 180°
遅れ、振幅は 1/29 になる**(教科書でよく見る CR 移相発振器の条件そのもの)。
アンプの利得は −30 倍 (R<sub>f</sub>/R<sub>in</sub> = 30)。

| 周波数 | 移相回路単体 (振幅・位相) | ループ利得 (アンプ×移相回路) |
| --- | --- | --- |
| 300 Hz | ×0.0055 (−45.2 dB)、−139.9° | −15.7 dB、+40.1° |
| 500 Hz | ×0.0195 (−34.2 dB)、−165.2° | −4.7 dB、+14.8° |
| **649.7 Hz (f₀)** | **×0.0345 (1/29)、−180.0°** | **+0.29 dB、0.0°** |
| 800 Hz | ×0.0520 (−25.7 dB)、+167.8° | +3.9 dB、−12.2° |
| 1 kHz | ×0.0775 (−22.2 dB)、+154.7° | +7.3 dB、−25.3° |

分かること:

- **f₀ = 649.7 Hz でループ利得がちょうど 0 dB・0°に近づく。** CH2/CH1 の比の
  利得が 0 dB を跨ぎ、位相が 0° (360° の倍数) を跨ぐ、その**同じ周波数**である
  ことが、この回路が f₀ で発振する条件そのもの
- **R<sub>f</sub> = 300 kΩ (R<sub>in</sub> の 30 倍) にしたのは、必要な 29 倍にわずかな余裕
  (30/29 ≈ 1.03 倍、+0.29 dB) を持たせるため。** ちょうど 29 倍だとループ利得が
  厳密に 1 で、部品の誤差や温度で発振が止まりかねない。**実際に発振させるには
  1 よりわずかに大きく**しておき、振幅は最終的にアンプの飽和で頭打ちになる
  (この題では S1 を開けたままなので発振はしない)
- **移相回路単体では、f₀ でちょうど 1/29 に減衰し 180° 遅れる。** アンプの
  −180° (反転) と合わせて 1 周で 360° (= 0°) になる — CR 移相発振器の
  「3 段の CR で 180°」という定石の中身がこの数値

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CR 移相発振器の f₀ = 1/(2πRC√6)・振幅 1/29 は、教科書でよく
使われる回路方程式による導出 (自分で確かめた)。
