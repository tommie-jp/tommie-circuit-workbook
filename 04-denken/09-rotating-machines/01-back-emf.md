---
book: denken
chapter: 9
id: 9-1
title: 直流モータの逆起電力 — 回転数に比例する
tier: 50
source: 自作
board: BB
---

# 9-1 直流モータの逆起電力 — 回転数に比例する

回っている直流モータは、電源として働くと同時に**逆起電力**を発生している。
端子電圧から巻線抵抗の電圧降下を引いた分がそれで、回転数にほぼ比例する。
小型の模型用 DC モータを電池で回し、電圧を変えて確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| E = Ke × N | 逆起電力は回転数 N に比例する (Ke: 起電力定数) |
| E = V − I × Ra | 端子電圧 V から電機子抵抗 Ra の電圧降下を引いたものが E |

## 回路図

```circuit
title: 図1 モータの端子電圧と電流
style:
  standard: jis
parts:
  B1: battery c1 g1 4.5
  Rs1: resistor c1 c3 10 i=I
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  M3: voltmeter c3 g3 l=$\mathrm{CH1}$
  M1: motor c6 g6
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- c6
  - g1 -- g3 -- g6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/01-back-emf-1.svg)

- B1 は単 3 電池 (1〜3 本) で 1.5 V / 3.0 V / 4.5 V の 3 段を作る
- Rs1 (10 Ω) はモータの電流 I を読むシャント。CH2 はその両端 (差動)
- CH1 はモータの端子電圧 V (Rs1 の後ろ、モータの両端そのもの)。電源電圧より
  I × Rs1 (15 mA × 10 Ω = 0.15 V) だけ低い
- Ra (電機子抵抗) は回転を指で止めて 1.5 V をかけ、そのときの V と I から
  Ra = V / I で測っておく (この実験では 3 Ω とする)

## 実体配線図

```breadboard
title: 図2 ブレッドボードとモータ
# 上の赤レール = 電池 (1〜3本) の+、青レール = GND
board: half
parts:
  S1: switch c4 c7
  Rs1: resistor b7 b11 10
  BAT:
    type: device
    at: top
    label: 電池 1〜3本
    pins: ["+", "-"]
  MOT:
    type: device
    at: top
    label: DCモータ
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: ["2+", "1+", "2-", "1-"]
wires:
  - BAT.+ -- +t2 red
  - BAT.- -- -t3 black
  - +t4 -- a4 red
  - MOT.+ -- a11 orange
  - MOT.- -- -t13 black
  - AD.1+ -- d11 blue
  - AD.1- -- -t16 black
  - AD.2+ -- a7 white
  - AD.2- -- e11 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/01-back-emf.svg)

- S1 で電池を入り切りする。Rs1 (10 Ω) はモータの電流を電圧に変えるシャント
- 電池 (BAT) とモータ (MOT) はブレッドボードの外の機器として描く。電池は上の赤・青レールへ、
  モータの + 側は 11 列 (Rs1 の右)、− 側は青レールにつながる
- AD の CH1 (1+・1−) は 11 列 (モータの +) と GND (青レール) の間、CH2 (2+・2−) は Rs1 の両端
  (7 列と 11 列) につなぐ
- 電源は AD の Supplies ではなく電池にする。回転を指で止めたとき (Ra の測定) に 0.5 A 流れ、
  Supplies の 1 レール (50 mA まで) では足りない。AD は Scope だけを使う

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = モータの端子電圧 V (Rs1 の後ろ。電源電圧より I × Rs1 = 0.15 V 低い)。CH2 = Rs1 の両端 (差動、I = 読み ÷ 10 Ω) |
| 電源 | 単 3 電池を 1 本・2 本・3 本に替えて電源電圧 1.5 / 3.0 / 4.5 V を作る。電圧を 3 段に変えることがこの題の中身なので、5 V の電源ではなく電池の本数で作る (3 本の 4.5 V が 5 V の代わり) |

### オシロスコープと発振器

AD の CH2 は Rs1 の両端 (7 列と 11 列) を差動で挟む。汎用オシロの 2 本のグランドクリップは
中でつながっていて、大地にも落ちている ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 のクリップを青レールに、
CH2 のクリップを 7 列か 11 列に当てると、電池 (7 列) かモータ (11 列) をクリップどうしで短絡する。
電池が大地から浮いていても、この短絡は起きる。Rs1 の電圧は 0.15 V で CH1 (最大 4.35 V) の 3 % ほどしかなく、
CH1 − CH2 で引くと 8 bit の分解能に埋もれる。そこで **Rs1 をモータの GND 側へ移す** (図3)。
試験の図とはシャントの位置が変わるが、直列なので流れる電流は同じ。

```circuit
title: 図3 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  B1: battery c1 g1 4.5
  M1: motor c4 e4
  Rs1: resistor e4 g4 10 i=I
  M2: voltmeter e6 g6 l=$\mathrm{CH2}$
  M3: voltmeter c8 g8 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - c1 -- c4 -- c8
  - e4 -- e6
  - g1 -- g4 -- g6 -- g8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/01-back-emf-2.svg)

- ブレッドボードの変え方: Rs1 を 7〜11 列から抜き、7 列と 11 列を線でつなぐ。MOT の − を青レールから
  空いた 15 列へ挿し替え、Rs1 を 15 列と青レールの間に挿す
- CH1 の先端は 11 列 (モータの +)、CH2 の先端は 15 列 (Rs1 の上)。グランドクリップは 2 本とも青レール
- I は CH2 ÷ 10 Ω (図1 と同じ)。モータの端子電圧 V は Math の CH1 − CH2 で読む。
  CH1 をそのまま V とすると、Rs1 の 0.15 V の分だけ E が大きく出る
- 直流なので Measure の Mean (平均) で読む。Math に Measure を当てられない機種は、
  CH1 と CH2 の Mean の差でよい (平均は引き算と順序を入れ替えられる)

この題はオシロの図を付けない — 見るのは直流の電圧と電流だけで (Scope の Mean か、テスターの読みで足りる)、時間で変わる波形が出ないため。

## 見るべき値

計算値。Ra ≒ 3 Ω、無負荷電流 I ≒ 15 mA (電圧によらずほぼ一定、摩擦分) とした。
V は CH1 で読む端子電圧で、電源電圧から Rs1 の降下 I × 10 Ω = 0.15 V を引いた値。

| 電源電圧 | V (CH1 の読み) | I (CH2 の読み) | E = V − I×Ra | 分かること |
| --- | --- | --- | --- | --- |
| 1.5 V | 1.35 V | 15 mA (150 mV) | 1.305 V | 基準点 |
| 3.0 V | 2.85 V | 15 mA (150 mV) | 2.805 V | E は約 2.15 倍 (V は 2.11 倍)。ほぼ V に比例 |
| 4.5 V | 4.35 V | 15 mA (150 mV) | 4.305 V | E は約 3.30 倍 (V は 3.22 倍)。回転もはっきり速くなって見える |

**無負荷では電流がほとんど変わらないので、E は V にほぼそのまま比例する。**
V を上げるほどモータの回る音・見た目の速さもはっきり増す。逆起電力が回転数に
比例するという式 E = Ke × N は、9-2 で同じモータを発電機として回して裏から確かめる。

## 出典

自作。
