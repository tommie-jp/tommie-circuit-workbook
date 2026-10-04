---
book: denken
chapter: 2
id: 2-3
title: 電磁誘導 — 磁石をコイルに出し入れして起電力 (レンツの法則)
tier: 50
source: 自作
board: BB
---

# 2-3 電磁誘導 — 磁石をコイルに出し入れして起電力 (レンツの法則)

コイルを貫く磁束が変化すると、コイルに起電力が生まれる (電磁誘導)。
磁石をコイルに近づける・遠ざける・向きを変えるだけで、
オシロスコープの波形の**符号が変わる**ことを目で見て確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| e = −N dΦ/dt | 誘導起電力。コイルの巻数 N と磁束 Φ の変化の速さに比例する |
| レンツの法則 (符号) | 誘導電流は、磁束の変化を**打ち消す向き**に流れる |

## 回路図

```circuit
title: 図1 コイルに磁石を出し入れする
style:
  standard: jis
parts:
  L1: inductor a3 c3
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
wires:
  - a3 -- a5
  - c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/03-electromagnetic-induction.svg)

- L1 が実験用のコイル (巻線)。M1 は AD の Scope の CH1 (電圧を読むだけで、
  電流はほとんど流さない。コイルには抵抗負荷を追加しなくてよい)

## 実体配線図

```breadboard
title: 図2 コイルを Analog Discovery の Scope につなぐ
board: half
parts:
  COIL:
    type: device
    at: bottom
    label: コイル
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: ["1+", "1-"]
wires:
  - COIL.+ -- j5 orange
  - COIL.- -- j8 black
  - AD.1+ -- f5 blue
  - AD.1- -- f8 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/03-electromagnetic-induction.svg)

- ブレッドボードに挿す部品は無い。コイルの 2 本の端を 5 列と 8 列にそれぞれつなぎ、AD の 1+ と 1− も同じ列 (f 行) に挿す
  (コイルの端を AD の 1+ と 1− に直接つないでもよい)
- 電源も発振器も使わない。コイルが磁束の変化を受けて作る電圧を、Scope の CH1 が読むだけ

## 手順

1. エナメル線を紙筒 (直径 2 cm ほど) に 300 回ほど巻き、両端の被膜を剥がして
   コイルを作る。両端を AD の CH1 (1+・1−) に直接つなぐ
2. ネオジム磁石を N 極を下にしてコイルの上から近づけ、素早く差し込んで抜く。
   Scope を Single (1 回だけ捕える) トリガにして波形を記録する
3. 磁石を**逆向き (S 極を下)** にして同じ動作を繰り返す
4. 磁石を**ゆっくり**動かした場合と**素早く**動かした場合を比べる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 (1+・1−)、DC 結合、Range は 1 V/div 程度、Time base は 100 ms/div、Trigger は Single |

AD の Scope の CH1 (1+・1−) でコイルの両端の電圧を読む。

```scope
title: 図3 磁石を近づけると正の山、遠ざけると逆符号の山 (波形は目安)
time: 100ms/div
trigger: ch1 rising 50mV at -2div
ch1: {wave: "= 0.3V * exp(-((t - 80ms) / 60ms)^2) - 0.3V * exp(-((t - 380ms) / 60ms)^2)", range: 200mV/div}
measure: [vmax, vmin]
notes:
  - text 80ms 0.3V: 近づける
  - text 380ms -0.3V: 遠ざける
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/scope/03-electromagnetic-induction.svg)

図の山の高さ 0.3 V は「見るべき値」の見当 (300 回巻き・0.1 秒ほど) による。実際の波形は磁石の動かし方で変わる。

### オシロスコープと発振器

発振器は使わない。コイルの両端を CH1 のプローブの先端 (1+ の代わり) とグランドクリップ (1− の代わり) で
挟む ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。コイルはどこにもつながらず大地から浮いているので、どちらの端にクリップを当ててもよい。
当てる端を入れ替えると波形の符号が逆になるので、磁石の向きを比べる間は入れ替えない。

- 設定は AD と同じ (DC 結合、1 V/div、100 ms/div)。×10 のプローブならオシロ側の倍率も ×10 にする。
  山が 0.3 V ほどと小さく見えるなら 200 mV/div まで下げる
- 1 回だけ捕えるには Single のボタンを押す (無い機種はトリガの Mode を Normal にし、捕えたら Stop)。
  トリガのレベルは +50 mV 前後の立ち上がり。最初の山が負に出るなら立ち下がりにする

## 見るべき値

目安 (実測は磁石の動かし方で大きく変わる。式の関係を確かめることが目的)。

| 動作 | 波形の形 |
| --- | --- |
| N 極を近づける | 正 (または負) の 1 つの山 |
| N 極を遠ざける | **近づけたときと逆符号**の山 (レンツの法則) |
| S 極を近づける | N 極を近づけたときと逆符号の山 |
| 素早く動かす | 山が**高く・細く**なる (dΦ/dt が大きい) |
| ゆっくり動かす | 山が**低く・広く**なる (dΦ/dt が小さい) |

300 回巻き・磁石を 0.1 秒ほどで通過させたとすると、e = N ΔΦ/Δt ≈
300 × 1×10⁻⁴ Wb / 0.1 s ≈ 0.3 V ほどの目安 (磁石の強さ・コイルとの
距離で大きく変わる、あくまで大きさの見当)。

分かること:

- **山の面積 (電圧 × 時間) は、動かす速さによらずほぼ一定になる。**
  積分すると磁束の変化量 ΔΦ そのものになるため (e dt を積分すると N ΔΦ)
- 近づけると遠ざけるとで符号が逆になるのは、コイルが**磁束の変化を
  打ち消す向きに**起電力を作るため (レンツの法則)
- 磁石をコイルの中で止めれば、電圧は 0 に戻る (磁束が変化していないため)

## 出典

自作。
