---
book: circuits
chapter: 9
id: 9-18
title: FM 送信機を AD の信号発生器で変調する — マイクの代わりに 1 kHz を入れる
tier: 100
source: 自作
board: CB
era: 古
---

# 9-18 FM 送信機を AD の信号発生器で変調する — マイクの代わりに 1 kHz を入れる

**先に 9-4 (FM 送信機、1 石) を組んでおく。** この題は 9-4 の送信機の変調を、マイクの代わりに
AD3 の信号発生器 W1 で確かめる。回路の働き・銅張り基板の島の配置・tinySA の拾い方と電波法の注意は 9-4 のまま。
回路が働く周波数は 80 MHz (FM 放送帯) で 3 MHz を超えるが、題材が FM 放送帯で 9-4 と同じ銅張り基板に組むので入門に置く。

声は毎回ちがうので、変調のようすを確かめるには、**Analog Discovery 3 (AD3) の信号発生器 W1 の 1 kHz の正弦波**を
マイクの代わりに入れるほうがそろう。エレクトレットマイクの出力は、ふつうの声の大きさで数 mV〜数十 mV (rms)
ほどしかない。W1 は小さい振幅だと安定しないので、**1 Vpp で出して抵抗の分圧で 100 分の 1 に落とし**、
同じ Cmic でベースへ入れる。

## 回路図

**W1 の設定**: Wavegen の W1 を Simple、波形 Sine、周波数 1 kHz、振幅 500 mV (peak、1 Vpp)、オフセット 0 V。
分圧は Rin (10 kΩ) と Rd (100 Ω) の E24 2 本で、**MIC の節点は 1 Vpp × 100 Ω / (10 kΩ + 100 Ω) ≈ 9.9 mVpp**
(約 3.5 mVrms。負荷のベース側を含めると 9〜10 mVpp)。声の大きさの目安 (数 mV〜十数 mV rms) の下のほうに
そろえてある。1 kHz は音声帯の真ん中で、Cmic (0.1 µF) と、ベースから見た抵抗 (数 kΩ) がつくる高域通過の
角 (数百 Hz) より上にある。W1 の GND は電源の − (回路の GND) に必ずつなぐ。

このときマイクのバイアス用の Rmic (2.2 kΩ) は要らないので外す (W1 は直流を流さず、Rmic が残ると
分圧の下側に並んで 100 Ω の値をずらす)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 マイクの代わりに AD の W1 (1kHz) を分圧して入れる
parts:
  VCC: vcc 2,1 5V
  L1: inductor 10,3 10,1 260n
  Cb: capacitor 4,1 4,3 0.1u
  GCb: ground 4,3
  Cant: capacitor 13,3 15,3 2.2p
  ANT: antenna 16,3
  Q1: npn 10,5
  C1: capacitor 12,4 12,6 22p
  C2: capacitor 12,7 12,9 47p
  GC2: ground 12,9
  Re: resistor 10,7 10,9 470
  GRe: ground 10,9
  Rb1: resistor 8,1 8,3 10k
  Rb2: resistor 7,7 7,5 2.4k
  GRb2: ground 7,7
  C3: capacitor 8,5 8,7 0.001u
  GC3: ground 8,7
  W1: sine 1,5 1,7 l=$\mathrm{W1}$
  GW1: ground 1,7
  Rin: resistor 1,5 3,5 10k
  Rd: resistor 3,5 3,7 100
  GRd: ground 3,7
  Cmic: capacitor 3,5 5,5 0.1u
wires:
  - 2,1 -- 10,1
  - 10,3 -- Q1.C
  - 10,3 -- 12,3
  - 12,3 -- 13,3
  - 12,3 -- 12,4
  - 15,3 -- 16,3
  - 12,6 -- 12,7
  - Q1.E -- 10,7
  - 10,7 -- 12,7
  - 5,5 -- 7,5
  - 7,5 -- 8,5
  - 8,5 -- Q1.B
  - 8,3 -- 8,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/18-fm-transmitter-wavegen.svg)

## 実体配線図

**銅張り基板の組み方は 9-4 の図 2 のまま、マイクの箱と Rmic をやめて次のように変える**。
銅張り基板の外の機器は AD3 (Supplies の V+、W1、GND) とアンテナ線の 2 つ。AD3 の W1 は Rin の下の島 (VIN) へ、
GND は電源の − と同じ GND (裏の面) の島へ渡す。V+ は 9-4 の図2 と同じく VCC の帯へ。Rin (10 kΩ) は VIN から MIC の島へ、Rd (100 Ω) は
MIC の島から GND の島 (via) へ渡す。9-4 の図 2 にあった上の VA の島は使わないので切り出さない。
`copper-fence check` のネットリストは、図 1 の回路図 (VIN = W1 と Rin の節点、MIC = Rin・Rd・Cmic の節点)
と一致する。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 70x50mm
  ground: back
title: 図2 マイクを外し、AD の W1 を分圧して MIC の島へ
f: 80M
copper:
  VCC: pad 31,7 46x4mm
  VIN: pad 9,34 4x4mm
  VB: pad 25,11 4x6mm
  MIC: pad 13,24 8x4mm
  BASE: pad 29.5,24 15x4mm
  COL: pad 48,18 14x4mm
  EMI: pad 48,30 14x4mm
  ANT: pad 61,18 4x4mm
  GCb: pad 17,16 4x4mm
  VCb: via 17,16
  GMIC: pad 15,34 4x4mm
  VMIC: via 15,34
  GC3: pad 28,36 4x4mm
  VC3: via 28,36
  GB2: pad 33.5,36 4x4mm
  VB2: via 33.5,36
  GC2: pad 47,41 4x4mm
  VC2: via 47,41
  GRe: pad 53,41 4x4mm
  VRe: via 53,41
parts:
  Cb: capacitor 17,8 17,16 0.1u
  Rin: resistor 10,25 10,34 10k
  Rd: resistor 14,25 14,34 100
  Cmic: capacitor 16,24 23,24 0.1u
  Rb1: resistor 25,13 25,23 10k
  Rb2: resistor 33.5,25 33.5,36 2.4k
  C3: capacitor 28,25 28,36 0.001u
  Q1: transistor/to92 36,24 43,18 43,30 2SC3355L
  L1: inductor 46.5,8 46.5,17 260n
  C1: capacitor 50,19 50,29 22p
  C2: capacitor 47,31 47,41 47p
  Re: resistor 53,31 53,41 470
  Cant: capacitor 54,18 60,18 2.2p
  AD:
    type: device
    at: -26,16
    label: Analog Discovery 3 (Supplies・W1)
    pins: V+ GND W1
    face: right
  WIRE:
    type: device
    at: 80,12
    label: アンテナ線 20cm
    pins: A
    face: left
wires:
  - AD.V+ -- 8.5,6 red
  - AD.GND -- 15.5,16 black
  - AD.W1 -- VIN
  - AD.GND -- 15,35.5 black
  - WIRE.A -- ANT
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/copper/18-fm-transmitter-wavegen.svg)

## 部品

9-4 の部品表のまま、マイクと Rmic を外して次を足す。

| 記号 | 値・型番 | 備考 |
| --- | --- | --- |
| Rin・Rd | 10 kΩ・100 Ω | マイクの代わりに AD の W1 で試すとき (Rmic は外す) |
| 信号源 | Analog Discovery 3 の W1 | 1 kHz、1 Vpp の正弦波 |

## 計器の設定

この題はオシロの図を付けない。搬送波は 80 MHz で、AD3 の Scope の範囲 (10 MHz 以下) の外にあり、波形では見えない。
図3 の tinySA のスペクトルで確かめる。電源と変調用の信号は AD3 (Supplies・W1) から入れる。

**tinySA Ultra で見るもの。** 1 kHz の正弦波で変調すると、搬送波の両側 ±1 kHz、±2 kHz、… に線が立つ。
搬送波の両側に立つこの線を**側波**という。
ただし**広い掃引では 1 本の線のまま**: RBW 100 kHz (9-4 の図 3) では、振れが数 kHz なので搬送波の線に収まり、
**周波数の振れは見えない** (幅 200 kHz・RBW 3 kHz でも ±1 kHz は RBW より狭く、線が少し太るだけで分かれない)。
±1 kHz の側波を分けて見るには、**搬送波に中心を合わせ、幅 10 kHz・RBW 200 Hz** (tinySA Ultra の一番狭い RBW)
に絞る。RBW 200 Hz なら ±1 kHz は RBW の 5 倍離れて別々の山になる。掃引は遅い (数十秒) ので、
搬送波が動かないよう銅張り基板を手や机に触れさせず、5 分ほど暖機してから見る。それでも自励の LC 発振は
数 kHz 流れることがあり、山が画面から出るときは中心を合わせ直す。

## 計器の画面

**計算値の仮定** (変調の深さは見積もりで、実物は数分の 1〜数倍ずれうる)。

1. 搬送波の合計電力は 9-4 の図 3 と同じ −50 dBm (数十cm で拾う)
2. ベースの信号は MIC の節点の約 7 割 (Cmic とベースの抵抗の分圧) で、ピーク約 3.3 mV
3. Re (470 Ω) が交流の負帰還になり、V<sub>BE</sub> の変化は約 1 割弱 (r<sub>e</sub> ≈ 26 mV / 0.75 mA ≈ 35 Ω、
   35 Ω / (470 Ω + 35 Ω) ≈ 0.07) で、ΔV<sub>BE</sub> ≈ 0.23 mV
4. その変化でコレクタ電流が 0.9% (ΔV<sub>BE</sub> / 26 mV) 変わり、拡散容量 (ベース-エミッタ間に
   電流に比例して現れる容量。gm·τ<sub>F</sub> ≈ 29mS × 23ps ≈ 0.66 pF、τ<sub>F</sub> ≈ 1/(2πf<sub>T</sub>) で
   f<sub>T</sub> = 7 GHz から) が約 6fF 動く。C1 と C2 の分圧で C<sub>s</sub> には 0.1 倍
   (C1/(C1 + C2))² の約 0.6fF が効き、Δf/f = ΔC<sub>s</sub> / 2C<sub>s</sub> ≈ 2×10<sup>−5</sup>。
   接合容量の変化は含めない

これで**最大周波数偏移 (搬送波の周波数が中心から振れる幅の最大) は約 1.6 kHz (80 MHz の 2×10<sup>−5</sup>)**、変調指数 β = 偏移 / 変調周波数 = 1.6 kHz / 1 kHz ≈ 1.6。
搬送波と側波の電力は、ベッセル関数 (FM の n 番目の側波の大きさを β から決める関数。値は数表か
python の scipy で求める) J<sub>n</sub>(1.6) (J<sub>0</sub> = 0.455、J<sub>1</sub> = 0.570、J<sub>2</sub> = 0.257、
J<sub>3</sub> = 0.073) を使い、合計 −50 dBm から 20 log<sub>10</sub>|J<sub>n</sub>| を引いて次のようになる (図 3)。

| 線 | 周波数 | 見積もり |
| --- | --- | --- |
| 搬送波 | 80 MHz | −56.8 dBm |
| ±1 kHz の側波 | 80 MHz ± 1 kHz | −54.9 dBm (搬送波より約 2 dB 高い) |
| ±2 kHz | 80 MHz ± 2 kHz | −61.8 dBm |
| ±3 kHz | 80 MHz ± 3 kHz | −72.8 dBm |

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 1kHz で変調した搬送波の側波 (目安)
device: tinysa-ultra
center: 80MHz
span: 10kHz
points: 450
rbw: 200Hz
ref: -50dBm
signal:
  - sine 80MHz -56.8dBm
  - sine 80.001MHz -54.9dBm
  - sine 79.999MHz -54.9dBm
  - sine 80.002MHz -61.8dBm
  - sine 79.998MHz -61.8dBm
  - sine 80.003MHz -72.8dBm
  - sine 79.997MHz -72.8dBm
markers: [80M, 80.001M, 79.999M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/18-fm-transmitter-wavegen.svg)

- 実物の搬送波は 73〜80 MHz のどこかに出るので、図の 80 MHz は「コイルを広げて 80 MHz に合わせた」ときの姿
  (9-4 の図 3 と同じ仮定)。中心は実物の搬送波に合わせる
- マイクで声を出したときの偏移は、数 mV〜数十 mV の声の大きさに応じて上の見積もりの数倍になる。
  W1 の 1 kHz で山が 5〜7 本並ぶのは、**変調が実際にかかっている印**。W1 を止めれば搬送波 1 本 (−50 dBm) に戻る。
  側波が出ない (または出すぎる) ときは、W1 の振幅で偏移が比例して変わる (β が小さいほど J<sub>1</sub> は β に比例する)
- 近くの FM ラジオで受けると、W1 の 1 kHz の音 (ピー) が聞こえる。声より聞き分けやすく、コイルの巻き・
  アンテナ・受信位置を変えても音の高さは 1 kHz のまま
- **安全**: W1 の出力は 1 Vpp と小さく、回路には直流の 5 V しか加わらない。電波のほうは声のときと同じ規則で、
  アンテナ線は 20cm のまま、Cant は 2.2 pF のまま、実験は屋内で短時間にとどめ、送信したまま放置しない
  (9-4 の警告のとおり、微弱無線局の範囲は距離 3m で 500 µV/m 以下)。W1 の信号を強くして偏移を稼がない
  (占有する周波数の幅が広がる)

## 見るべき値

計算値・実測を併用。

| 確かめること | 期待する値 |
| --- | --- |
| W1 (1 kHz、1 Vpp) を分圧して入れる: MIC の節点 | 約 9.9 mVpp (Rin 10 kΩ・Rd 100 Ω の分圧、計算値) |
| 幅 10 kHz・RBW 200 Hz、マーカー 1 (搬送波) | 中心の線。約 −56.8 dBm (変調指数 β ≈ 1.6 の仮定、目安) |
| マーカー 2・3 (80 MHz ± 1 kHz、側波) | 約 −54.9 dBm。搬送波より約 2 dB 高い。±2 kHz は約 −61.8 dBm、±3 kHz は約 −72.8 dBm (見積もり、実物は数分の 1〜数倍) |
| W1 を止める | 側波が消えて搬送波 1 本 (約 −50 dBm) に戻る。ラジオの 1 kHz の音も消える |

## LTspice での確かめ (対象外)

回路はマイクの入れ方のほかは 9-4 の図1 と同じで、動作点と発振周波数の突き合わせは 9-4 の「LTspice での確かめ」にある。
変調の深さ (β ≈ 1.6)・側波の dBm は、アンテナと結合の仮定を置いた見積もりで、ここでは走らせていない (対象外)。

## 出典

自作。電波法の微弱無線局の技術基準 (322 MHz 以下、距離 3m で 500 µV/m 以下) は
総務省電波法施行規則第 6 条による。

1. UNISONIC TECHNOLOGIES 2SC3355 データシート
   ([https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf))。
   f<sub>T</sub>・C<sub>re</sub>・hFE・定格・端子の並び (TO-92 は B・E・C) はこれによる。
