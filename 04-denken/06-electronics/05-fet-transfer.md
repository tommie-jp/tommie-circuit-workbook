---
book: denken
chapter: 6
id: 6-5
title: FET の伝達特性 — V_GS と I_D
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-5 FET の伝達特性 — V_GS と I_D

電界効果トランジスタ (FET) は、ゲートとソースの間の電圧 V_GS でドレイン電流 I_D を決める
**電圧制御**の素子である。バイポーラトランジスタ (6-2) がベース電流で動くのと違い、
ゲートには電流がほとんど流れない。エンハンスメント形の MOSFET 2N7000 のゲートに
ゆっくりした三角波を加え、V_GS と I_D の関係 (**伝達特性**) を描く。しきい値電圧 V_th を
越えるまでは流れず、越えると I_D は (V_GS − V_th) の **2 乗**で増える。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_D = 0 (V_GS < V_th) | しきい値電圧より下では流れない (遮断) |
| I_D = K (V_GS − V_th)² (V_DS ≧ V_GS − V_th) | 飽和領域の伝達特性。K は素子で決まる係数 |
| g_m = ΔI_D / ΔV_GS = 2K (V_GS − V_th) = 2√(K I_D) | 相互コンダクタンス。増幅回路の増幅度を決める |
| I_D = (5 V − V_D) / R_D | ドレインの電圧 (CH2) から I_D を求める式 |

## 回路図

```circuit
title: 図1 2N7000 の伝達特性を測る
parts:
  V1: triangle 1,4 1,6 2 l=$\mathrm{W1}$
  RG: resistor 1,4 3,4 1k
  Q1: nmos-e 5,4 2N7000
  RD: resistor 5,1 5,3 1k i=ID
  VCC: vcc 5,1 5V
  G1: ground 1,6
wires:
  - 3,4 -| Q1.G
  - 5,3 -| Q1.D
  - Q1.S -| 5,6
  - 1,6 -- 5,6
notes:
  - text 3.5,3.7 blue: ゲート (CH1)
  - text 5.5,3.7 blue: ドレイン (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/05-fet-transfer.svg)

- ゲートは AD の Wavegen (W1) の三角波。Offset 2 V、Amplitude 2 V なので、0 V から 4 V まで
  10 Hz でゆっくり動く。R_G (1 kΩ) は発振止めで、ゲートに電流は流れないので電圧は落ちない
- ドレインは R_D (1 kΩ) を通して V_CC (AD の Supplies、+5 V)。R_D は I_D を電圧に変える役も持つ
- ソースは GND なので、ゲートの電圧 (CH1) がそのまま V_GS になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RG: resistor c9 c14 1k
  Q1: transistor e15(S) e16(G) e17(D) 2N7000
  RD: resistor c24 c17 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1-, 1+, 2+, 2-, V+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a9 yellow
  - AD.1+ -- a16 yellow
  - AD.1- -- -t12 black
  - b14 -- b16 yellow
  - a15 -- -t15 black
  - AD.V+ -- +t27 red
  - +t24 -- a24 red
  - AD.2+ -- a17 green
  - AD.2- -- -t22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/05-fet-transfer.svg)

- Q1 (2N7000) は平らな面を手前にして、左から S (15 列)・G (16 列)・D (17 列)。
  ソース (15 列) は黒い線で GND のレールへ
  ※ **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- R_G は 9〜14 列。W1 を 9 列に挿し、14 列から黄色の線でゲート (16 列) へ運ぶ
- R_D は 17〜24 列。24 列を赤い線で + のレール (V+ = 5 V) につなぐ
- CH1 (1+) はゲート (16 列)、CH2 (2+) はドレイン (17 列)。1− と 2− は GND のレール

## 計器の設定

計器は Analog Discovery 3 (AD3)。電源は Supplies の V+ (5 V、約 5 mA)、ゲートの三角波は Wavegen W1、ゲートとドレインの波形は Scope の 2 ch で読む。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen | W1: Triangle、10 Hz、Amplitude 2 V、Offset 2 V (0 V〜4 V) |
| Scope | CH1 = ゲート (V_GS)、CH2 = ドレイン (V_D)。Time base 20 ms/div |
| Math | M1 = 5 − C2 (R_D の電圧。1 kΩ なので V の読みがそのまま I_D の mA) |
| XY | X = C1、Y = M1。伝達特性の曲線が出る |

時間軸の画面は図3 のようになる (上りの 1 本を 5 ms/div で拡大)。ゲート (CH1) の三角波が 2.2 V・2.4 V を通る瞬間にカーソルを当てると、
ドレイン (CH2) は 4.50 V・0.50 V と読める (表の値。V_th = 2.1 V、K = 50 mA/V² の仮定)。

```scope
title: 図3 ゲート 2.2 → 2.4 V でドレインは 4.50 → 0.50 V
time: 5ms/div
trigger: ch1 rising 2V
ch1: {wave: triangle 10Hz 2V offset 2V phase 90deg, range: 1V/div, position: -3div}
ch2: {wave: "= max(5V - 50 * max(ch1 - 2.1V, 0V) ^ 2 / 1V, 60mV)", range: 1V/div, position: -3div}
cursors: [2.5ms, 5ms]
measure: [freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/scope/05-fet-transfer.svg)

表の 3 点は、XY の画面でカーソルを当てて読むか、時間軸の画面で CH1 が 2.2 V・2.3 V・2.4 V を
通る瞬間の Math を読む。三角波の上りと下りで同じ曲線をなぞれば、発熱などの影響は無い。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Triangle、10 Hz、**4 Vpp、Offset 2 V** (AD の Amplitude 2 V は山の高さ)、出力は High-Z |
| V+ | 安定化電源の 5 V。電流制限は 10 mA (I_D は R_D で 5 mA までに抑えられる) |
| 1+ | CH1 の先端を 16 列 (ゲート)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 17 列 (ドレイン)、グランドクリップを GND のレール |

- ゲートに電流が流れないので、FG の 50 Ω による電圧の低下は無い
- 汎用オシロの Math は定数を引けない機種が多い。XY 表示を X = CH1、Y = CH2 にすると、
  V_D が上下に裏返った曲線になる (5 V から下がる向きが I_D の増える向き)。I_D は
  (5 V − V_D) ÷ 1 kΩ で読み替える。5 V は安定化電源の表示ではなく、CH2 の先端を
  上の + のレールに当てて読んだ値を使う

## 見るべき値

計算値。2N7000 の V_th と K は個体差が大きい (データシートの V_th は 0.8〜3 V)。ここでは
**V_th = 2.1 V、K = 50 mA/V² と仮定**した。実物では曲線が左右にずれるが、形は同じになる。

| V_GS (CH1) | V_D (CH2) | I_D (= 5 V − CH2、mA) | g_m = 2K (V_GS − V_th) |
| --- | --- | --- | --- |
| 2.0 V 以下 | 5.00 V | 0 (遮断) | 0 |
| 2.2 V | 4.50 V | 0.5 mA | 10 mS |
| 2.3 V | 3.00 V | 2.0 mA | 20 mS |
| 2.4 V | 0.50 V | 4.5 mA | 30 mS |
| 3.0 V | 0.06 V | 4.94 mA (R_D で頭打ち) | — |

```graph
title: 図4 2N7000 の伝達特性 (計算) — V_th を越えると 2 乗で増え、5 mA で頭打ち
x: ゲート電圧 V 1.8..3.0
y: ドレイン電流 mA 0..5.5
lines:
  I_D mA:
    - 1.80 0.000
    - 1.82 0.000
    - 1.84 0.000
    - 1.86 0.000
    - 1.88 0.000
    - 1.90 0.000
    - 1.92 0.000
    - 1.94 0.000
    - 1.96 0.000
    - 1.98 0.000
    - 2.00 0.000
    - 2.02 0.000
    - 2.04 0.000
    - 2.06 0.000
    - 2.08 0.000
    - 2.10 0.000
    - 2.12 0.020
    - 2.14 0.080
    - 2.16 0.180
    - 2.18 0.320
    - 2.20 0.500
    - 2.22 0.720
    - 2.24 0.980
    - 2.26 1.280
    - 2.28 1.620
    - 2.30 2.000
    - 2.32 2.420
    - 2.34 2.880
    - 2.36 3.380
    - 2.38 3.920
    - 2.40 4.500
    - 2.42 4.764
    - 2.44 4.800
    - 2.46 4.822
    - 2.48 4.838
    - 2.50 4.851
    - 2.52 4.861
    - 2.54 4.870
    - 2.56 4.878
    - 2.58 4.884
    - 2.60 4.890
    - 2.62 4.895
    - 2.64 4.900
    - 2.66 4.904
    - 2.68 4.908
    - 2.70 4.912
    - 2.72 4.915
    - 2.74 4.918
    - 2.76 4.921
    - 2.78 4.923
    - 2.80 4.926
    - 2.82 4.928
    - 2.84 4.930
    - 2.86 4.932
    - 2.88 4.934
    - 2.90 4.936
    - 2.92 4.937
    - 2.94 4.939
    - 2.96 4.940
    - 2.98 4.942
    - 3.00 4.943
notes:
  - mark 2.2
  - mark 2.4
  - band 2.41 3.0: R_D で頭打ち
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/graph/05-fet-transfer.svg)

曲線は飽和領域では K (V_GS − V_th)²、2.41 V より右では V_DS が V_GS − V_th を下回る
(非飽和領域) ので、R_D と V_CC で決まる 5 mA 近くで止まる。

分かること:

- **V_GS が 0.1 V 増えるごとに I_D の増え方が大きくなる** (0.5 → 2.0 → 4.5 mA)。
  √I_D を V_GS に対して並べると直線 (0.71・1.41・2.12) になり、その直線が 0 になる所が V_th
- g_m は I_D とともに大きくなる。FET の増幅回路で動作点 (バイアス) の電流を決めると、
  増幅度 (g_m R_D) も決まる
- 頭打ちの所は FET がスイッチとして**オン**になった状態 (V_DS が小さい)。6-7 の
  トランジスタのスイッチと同じ使い方で、V_GS を 0 V と 4 V の 2 値で動かせば FET のスイッチになる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。2N7000 のピンの並びとしきい値電圧の範囲はメーカーのデータシート
(onsemi 2N7000)。
