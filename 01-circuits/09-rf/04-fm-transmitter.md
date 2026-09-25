---
book: circuits
chapter: 9
id: 9-4
title: FM 送信機 (1 石)
tier: 50
source: 自作
board: BB
era: 古
---

# 9-4 FM 送信機 (1 石)

トランジスタ 1 石だけの**コルピッツ発振回路**を FM 放送帯 (80MHz 前後、日本の
FM 放送は 76〜95MHz) で組み、
マイクの音声で発振周波数をわずかに揺らす (直接 FM)。近くの FM ラジオで受かる
ほど電波は届くが、**電波法の微弱無線局の範囲に収めるため、アンテナは短く・
電源は低電圧のまま・増幅段を足さない**。

> [!WARNING]
> 日本の電波法では、322MHz 以下の微弱無線局は**距離 3m での電界強度が
> 500µV/m 以下**なら免許が要らない (電波法施行規則第 6 条)。この題の
> 定数 (短いアンテナ・小さな結合コンデンサ・電池 3V) はその範囲に収める
> ための設計で、**アンテナを伸ばしたり石を足して増幅したりすると免許なしでは
> 違法**になる。実験は屋内で短時間、電波を出したまま放置しない。

## 回路図

```circuit
title: 図1 コルピッツ発振 + マイク直接FM
parts:
  VCC: vcc a2
  L1: inductor a10 c10 260n
  Cb: capacitor a4 c4 0.1u
  GCb: ground c4
  Cant: capacitor c13 c15 2p
  ANT: port c16
  Q1: npn e10
  C1: capacitor d12 f12 22p
  C2: capacitor g12 i12 47p
  GC2: ground i12
  Re: resistor g10 i10 470
  GRe: ground i10
  Rb1: resistor a8 c8 10k
  Rb2: resistor e7 g7 4.7k
  GRb2: ground g7
  MIC: mic e2 g2
  GMIC: ground g2
  Rmic: resistor a2 c2 2.2k
  Cmic: capacitor e3 e5 0.1u
wires:
  - a2 -- a10
  - c10 -- Q1.C
  - c10 -- c12
  - c12 -- c13
  - c12 -- d12
  - c15 -- c16
  - f12 -- g12
  - Q1.E -- g10
  - g10 -- g12
  - c2 -- e2
  - e2 -- e3
  - e5 -- e7
  - e7 -- e8
  - e8 -- Q1.B
  - c8 -- e8
```

- **タンク**: L1 (260nH、実測でずれる。手巻きコイル) と C1・C2 (コルピッツの
  分圧) で並列共振回路を作る。コレクタは L1 を介して Vcc につながるので、
  L1 は「タンクの一部」と「コレクタの負荷 (RFC 代わり)」を兼ねる
- **帰還**: C1 と C2 の分圧点がエミッタ。C1・C2 の直列合成 C<sub>s</sub> と L1 で
  発振周波数が決まる: f<sub>0</sub> = 1 / (2π√(L1·C<sub>s</sub>))
- **直接 FM**: MIC (エレクトレットマイク) の音声を Cmic でベースへ結合する。
  ベースの直流電位がわずかに揺れると、Q1 のベース-エミッタ間容量 (C<sub>be</sub>) も
  わずかに変わり、C2 と一緒にタンクの容量を揺らして周波数が動く
- **アンテナ**: Cant (2pF) の小さな結合でコレクタから取り出す。結合を弱くする
  ほど発振回路への負荷が軽く保たれ、輻射も弱くなる (微弱無線の条件そのもの)

**発振周波数の計算値**: C<sub>s</sub> = C1·C2/(C1+C2) = 22p·47p/69p ≈ 15pF。

f<sub>0</sub> = 1 / (2π√(260nH × 15pF)) **≈ 80.6MHz (約80MHz)**。

コイルの巻きを少し広げる (実効インダクタンスが下がる) と周波数は上がり、
詰めると下がる。実測ではコイル 1 巻きぶんの調整で数 MHz 動くので、
**近くの FM ラジオで一番静かな (放送局の無い) 周波数に合わせる**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  ANT:
    type: device
    at: top
    label: アンテナ 20cm
    pins: ["1"]
  MIC:
    type: device
    at: top
    label: マイク
    pins: [OUT, GND]
  Q1: transistor f10(B) f12(C) f14(E) 2SC1815
  Rb1: resistor a6 a10 10k
  C1: capacitor/ceramic a12 a14 22p
  Rb2: resistor c7 c10 4.7k
  Cant: capacitor/ceramic c12 c13 2p
  L1: inductor/axial d12 d16 260n
  Rmic: resistor d18 d20 2.2k
  Re: resistor e14 e17 470
  Cmic: capacitor/ceramic e20 e22 0.1u
  C2: capacitor/ceramic c14 c17 47p
  Cb: capacitor/ceramic e25 e27 0.1u
wires:
  - +t6 -- b6
  - b10 -- g10
  - +t16 -- b16
  - b12 -- g12
  - b7 -- -t7
  - ANT.1 -- b13
  - b14 -- g14
  - +t18 -- b18
  - MIC.OUT -- b20
  - MIC.GND -- -t21
  - b17 -- -t17
  - b22 -- b10
  - +t25 -- b25
  - b27 -- -t27
```

- 赤レール = +3V (単3 電池 2 本)、青レール = GND
- **アンテナ線は 20cm ほど**にとどめる (伸ばすと電波法の範囲を超えやすい)。
  結合コンデンサ Cant (2pF) も指定どおりの小さい値で
- L1 は太さ 0.6mm のエナメル線を直径 8mm の丸棒に 8 回巻き、両端をブレッド
  ボードの穴に合わせて曲げたもの (インダクタンスは目安。実測でずれる)
- Q1 のベース (f10、10 列) に Rb1・Rb2 の分圧と Cmic からのマイク音声が集まる。
  コレクタ (f12、12 列) に L1・Cant・C1 が、エミッタ (f14、14 列) に C1・C2・Re が集まる

## 見るべき値

計算値・実測を併用。

| 確かめること | 期待する値 |
| --- | --- |
| 近くの FM ラジオで受信 | 80MHz 付近 (計算値) の**静かな周波数**でノイズが変わる |
| マイクに向かって話す | ラジオから声が (小さく歪みつつ) 聞こえる |
| コイルの巻きを少し広げる | 受かる周波数が上がる方向へ動く |
| アンテナを外す | 数十cm 以内でしか受からなくなる (電波法の範囲内であることの目安) |

## 出典

自作。電波法の微弱無線局の技術基準 (322MHz 以下、距離 3m で 500µV/m 以下) は
総務省電波法施行規則第 6 条による。
