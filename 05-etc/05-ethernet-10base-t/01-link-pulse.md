---
book: etc
chapter: 5
id: 5-1
title: リンクパルスを見る — 使わなくなったルータの 10BASE-T の対をオシロで見る
tier: 200
source: 自作 (数値は IEEE 802.3 の Clause 14 と Clause 28)
board: —
---

# 5-1 リンクパルスを見る — 使わなくなったルータの 10BASE-T の対をオシロで見る

> [!WARNING]
> **この工作 (5 章 ethernet-10base-t) は、まだ実機で測っていない。** 波形の図と数値は規格 (IEEE 802.3) の値から計算で作ったもので、手元のルータと PC で同じに見えるかは確かめていない。測ったら WaveForms の CSV を題の隣に置いて `data:` で重ねる。

この題で組むのは RJ45 のブレークアウト (線に触れるための基板) だけで、回路は無い。買った物を使うなら組まなくてよい。自作するときのユニバーサル基板の図を「つなぎ方」に付けた。

## この章の意図

ネットワークは「ケーブルに流れる電圧」で、回路と地続きだ。この章は、使わなくなったルータの
LAN ポートを相手に、10 Mb/s のイーサネット (10BASE-T) をディスクリート部品と Raspberry Pi Pico 2 で
送受し、最後は PC の `ping` に答えるまでを 6 題で組む。

| 題 | やること | 組む物 |
| --- | --- | --- |
| 5-1 (この題) | ルータと PC の間の対にオシロを掛け、リンクパルスとフレームの波形を見る | なし (ブレークアウト基板) |
| 5-2 | Pico 2 の PIO と抵抗だけでリンクパルスとフレームを送り、ルータにリンクさせる | 送信回路 |
| 5-3 | 100 Ω (オーム) 終端と 74HC14 で差動を 3.3 V の論理に戻し、ロジアナで読む | 受信回路 |
| 5-4 | マンチェスターを PIO で復号し、MAC と IP のヘッダを USB シリアルに出す | 受信のプログラム |
| 5-5 | ARP と ping に答える。応答までの時間をオシロで測る | 最小の IP 処理 |
| 5-6 | トランス内蔵の RJ45 に差し替えて絶縁し、波形の違いを比べる | パルストランス |

10BASE-T を選ぶのは、信号が 10 MHz までで教科書のオシロ (Analog Discovery 3) に入り、
マイコンの PIO で作れる最後の世代のイーサネットだからだ。100BASE-TX は 125 MHz の
MLT-3 で、どちらも教科書の範囲を超える。

この題では**何も組まない**。ルータと PC が出している信号に触れて、次の題から自分で作る物
(100 ns のパルス、5 MHz のプリアンブル、フレームの長さ) を先に目で見ておく。

## 10BASE-T の信号

| 項目 | 値 |
| --- | --- |
| 速さ | 10 Mb/s (1 ビット 100 ns) |
| 符号 | マンチェスター。1 ビットの中央で必ず電圧が変わる。1 は低→高、0 は高→低 |
| 線 | ツイストペア 2 対 (送りと受けで別の対)。特性インピーダンス 100 Ω |
| 振幅 | 差動で 2.2〜2.8 V<sub>p</sub> (100 Ω の負荷で) |
| 絶縁 | 両端にパルストランス。対は直流的に浮いている |
| リンクパルス | 送る物が無いとき 16 ms ごとに幅 100 ns の正のパルス (相手に「線がつながっている」と知らせる) |
| ピン | 端末 (PC、MDI) は 1・2 で送り 3・6 で受ける。ハブやルータの LAN ポート (MDI-X) は逆に 3・6 で送り 1・2 で受ける |

マンチェスター符号は、クロックをデータに埋め込む符号だ。受け手はビットの中央の変わり目から
クロックを取り戻せるので、別にクロックの線を引かなくてよい。代わりに、線の上の変わり目は
ビットの速さの 2 倍 (最大 20 M 回/秒) になる。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 マンチェスター符号 — 1 はビットの中央で立ち上がり、0 は立ち下がり
device: generic
time: 100ns/div
signals:
  BIT:  clock 10MHz
  DATA: pattern 1010101011 bit 100ns
  TX:   pattern 01100110011001100101 bit 50ns
cursors: [850ns, 950ns]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/logic/01-link-pulse.svg)

図1 は符号の説明の図で、計器の画面ではない (BIT はビットの区切りを示す 10 MHz、DATA は送るビット、
TX が線の上の電圧の高低)。DATA の `1010101011` はプリアンブルの終わりと SFD (後述) の終わりで、
`…1010` の間は TX が 5 MHz の方形波になり、最後の `11` で変わり目の間隔が 50 ns に詰まる。
カーソルは最後の `11` の 2 ビットの真ん中に置いた (X1 850 ns・X2 950 ns、ΔX = 100 ns = 1 ビット)。
実際の線の上では、高が +2.5 V・低が −2.5 V の差動電圧になる。

フレームの前には、受け手がクロックを合わせるためのプリアンブル (`10101010` × 7 バイト = 56 ビット、
5.6 µs) と SFD (Start Frame Delimiter、`10101011`、0.8 µs) が付く。

## 用意する物

| 物 | 数 | 備考 |
| --- | --- | --- |
| 使わなくなったルータ | 1 | LAN ポートが 10/100 Mb/s (10BASE-T に対応) の物。WAN ポートは使わない |
| PC | 1 | 有線 LAN。NIC の速さを 10 Mb/s に固定できる物 (下記) |
| LAN ケーブル (ストレート) | 2 | 短い物 (1 m 程度)。カテゴリは 5 以上なら何でもよい |
| RJ45 ブレークアウト基板 | 1 | ジャック 2 つの間に 8 本の線がピンヘッダかネジ端子で出ている物 (数百円) |
| Analog Discovery 3 | 1 | **BNC アダプタ基板**と BNC のプローブ (下記) |

ルータの LAN 側は、PC とルータのスイッチをまたいで 1 つのネットワークになる。ルータの DHCP が
PC に番地を配るので、設定は要らない。PC からルータの番地 (多くは 192.168.0.1 か 192.168.1.1) に
`ping` を打つと、ケーブルにフレームが流れる。

## つなぎ方

```plantuml
@startuml
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
left to right direction
rectangle "PC\n(NIC を 10 Mb/s に固定)" as PC
rectangle "RJ45 ブレークアウト基板\n(8 本が通り抜け)" as BO
rectangle "ルータの LAN ポート\n(10/100、MDI-X)" as RT
rectangle "Analog Discovery 3\nScope (差動入力)" as AD
PC -- BO : ストレート
BO -- RT : ストレート
BO .. AD : ピン 3・6 を 1+ 1-\nピン 1・2 を 2+ 2-
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/plantuml/01-link-pulse.svg)

PC とルータの間にブレークアウト基板を挟み、通り抜けている 8 本の線のうち、ルータから PC へ向かう対
(ピン 3・6) にオシロの ch1、PC からルータへ向かう対 (ピン 1・2) に ch2 を掛ける。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 10BASE-T の 2 対にオシロを掛ける (RJ45 ブレークアウト基板で線に触れる)
parts:
  J1:
    type: device
    at: 1,3
    label: Router
    pins: [RX+, RX-, TX+, TX-]
    turn: mirror
  J2:
    type: device
    at: 11,3
    label: PC
    pins: [TX+, TX-, RX+, RX-]
  SC:
    type: device
    at: 6.5,7
    label: AD3
    pins: [1+, 1-, 2+, 2-]
    turn: r90
wires:
  - J1.RX+ -- 6.38,2.75 -- J2.TX+
  - J1.RX- -- 6.13,3 -- J2.TX-
  - J1.TX+ -- 6.88,3.25 -- J2.RX+
  - J1.TX- -- 6.63,3.5 -- J2.RX-
  - SC.1+ |- 6.88,3.25
  - SC.1- |- 6.63,3.5
  - SC.2+ |- 6.38,2.75
  - SC.2- |- 6.13,3
notes:
  - box 4.5,2 8.5,4 ink
  - text 6.5,1.45 small: RJ45 ブレークアウト基板
  - text 1,2.3 small left: ピン 1・2 (PC からルータへ)
  - text 1,3.9 small left: ピン 3・6 (ルータから PC へ)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/circuit/01-link-pulse.svg)

ブレークアウト基板は買える物 (RJ45 ジャック 2 つの間の 8 本が端子に出ている物) でよい。
自作するなら、DIP 化した RJ45 (8 ピンが 2.54 mm で 1 列に出る物) を 2 つユニバーサル基板に挿し、
8 本をスズめっき線で渡す。対に触れる 4 本だけ、下の行に被覆線で引き出してオシロを当てる。

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図3 自作のブレークアウト — DIP 化した RJ45 を 2 つ渡し、下の行で対に触れる
board:
  size: 5x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
parts:
  J1: sip8 c6 RJ45
  J2: sip8 v6 RJ45
  AD:
    type: device
    at: bottom
    label: AD3 Scope
    pins: 2+ 2- 1+ 1-
wires:
  - c6 -- v6 white
  - c7 -- v7 white
  - c8 -- v8 white
  - c9 -- v9 white
  - c10 -- v10 white
  - c11 -- v11 white
  - c12 -- v12 white
  - c13 -- v13 white
  - v6 -- w6 orange
  - v7 -- w7 orange
  - v8 -- w8 blue
  - v11 -- w11 blue
  - AD.2+ -- w6 orange
  - AD.2- -- w7 orange
  - AD.1+ -- w8 blue
  - AD.1- -- w11 blue
notes:
  - text a16 left: ルータへ
  - text x16 left: PC へ
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/perfboard/01-link-pulse.svg)

- 5×7 cm のユニバーサル基板 (18 列 × 24 行) を縦に置き、J1 (ルータ側) を C 行、J2 (PC 側) を V 行に挿す。
  ピン 1〜8 が 6〜13 列に並ぶ。8 本とも渡すので、10BASE-T 以外のケーブルをつないでも通る
- オシロは W 行に出した 4 本に当てる。青が ch1 (ピン 3・6 = ルータから PC)、橙が ch2 (ピン 1・2 = PC からルータ)。
  被覆線は短くし、対の 2 本は撚る
- 信号は 10 MHz までで、ユニバーサル基板の範囲 (10 MHz 以下、短い配線) に収まる。渡す線は 5 cm ほどで、
  100 Ω の対の中に 1 か所だけインピーダンスの乱れが入るが、10BASE-T の 100 ns のビットには影響しない
  (100BASE-TX 以上では、この作りは使えない)

- オシロは**差動で**掛ける。1+ をピン 3 (TX+)、1− をピン 6 (TX−) につなぎ、**GND はどこにもつながない**。
  対は両端のトランスで浮いているので、片側を GND に落とすと信号が崩れる。
  Analog Discovery 3 の Scope は差動入力 (1+ と 1− の差を測る) なので、そのまま掛けられる
- 入力は 1 MΩ (メグオーム) で、100 Ω の線路にはほとんど負荷にならない。プローブの線は短くする
  (長いと 10 MHz の波形がなまる)
- **BNC アダプタ基板を使う。** 付属のワイヤキットでは帯域が 9 MHz で、幅 100 ns のパルスの角が丸くなる。
  BNC アダプタ基板なら 30 MHz 以上あり、立ち上がりまで見える
- ルータが Auto-MDIX (対の自動入れ替え) を持つと、どちらの対で送るかが逆になることがある。
  ch1 にリンクパルスが見えず ch2 に見えたら、対が逆になっている。本文の 3・6 と 1・2 を読み替える
- パルスの向きも手掛かりになる。リンクパルスは TX+ が TX− より高くなる正のパルスなので、
  負に出たら 1+ と 1− が逆

## PC の NIC を 10 Mb/s にする

今の NIC は 1000BASE-T でつながろうとするので、PC 側で 10 Mb/s に固定する。ルータの LAN ポートは
相手に合わせて 10BASE-T に落ちる。

Linux (`ethtool`):

```bash
sudo ethtool -s enp3s0 advertise 0x002   # 10BASE-T 全二重だけを申し出る (0x001 なら半二重)
ethtool enp3s0 | grep -E 'Speed|Duplex'  # Speed: 10Mb/s になったことを確かめる
sudo ethtool -s enp3s0 advertise 0x0ff   # 戻すとき (元の値は事前に ethtool enp3s0 で控える)
```

Windows は、デバイスマネージャーで NIC の「詳細設定」を開き、「速度とデュプレックス (Speed & Duplex)」を
「10 Mbps 全二重 (10 Mbps Full Duplex)」にする。

`advertise` で絞る方式は自動ネゴシエーション (FLP、後述) を残したまま 10 Mb/s にするので、
全二重でつながる。`autoneg off` で固定すると PC はリンクパルス (NLP) だけを出し、ルータは
並列検出で 10BASE-T **半二重**にする。ping には半二重でも支障ない。

USB の NIC には 10 Mb/s を選べない物がある。選べない PC では、5-2 で作る Pico 2 の送信回路を相手にする。

## 見えるはずの信号

ケーブルを順につないでいくと、3 つの段階が見える。

### 段階 1: リンクが無いとき — FLP バースト

ルータにブレークアウト基板だけをつなぎ、PC はまだつながない。ルータの LAN ポートは相手を探して
**FLP (Fast Link Pulse) バースト**を 16 ms ごとに出す。1 バーストは幅 100 ns のパルス 17〜33 発で、
125 µs ごとの「クロックパルス」の間に、送りたいビットが 1 のときだけ「データパルス」(クロックの
62.5 µs 後) が入る。16 ビットで「自分は 10/100 の全二重・半二重ができる」と相手に伝える
(自動ネゴシエーション)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 FLP バースト — 125 µs ごとのクロックパルス (ch1 = ルータからの対)
time: 20us/div
trigger: ch1 rising 1.25V at -4div
ch1: pulse 8kHz 1.25V offset 1.25V duty 0.08%
cursors: [0, 125us]
measure: [vmax, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/01-link-pulse-1.svg)

図3 はクロックパルスだけを描いた (データパルスはビットが 1 の所にだけ、2 本の真ん中 62.5 µs に出る)。
時間軸を 500 µs/div にすると 1 バースト (2 ms ほど) が入り、20 ms/div にすると 16 ms ごとの
バーストの繰り返しが見える。ただし、どちらも 1 画面の標本の間隔が 100 ns より粗くなるので、
WaveForms の Scope のチャネルの設定で Filter を **MinMax** にする (間引きで落ちるパルスを拾う)。

### 段階 2: リンクが上がったとき — NLP

PC を 10 Mb/s にしてからつなぐ。両方が FLP を交わして 10BASE-T の全二重で合意すると、ルータの
ポートの LED が点く。合意のあとは FLP をやめ、送る物が無い間は **NLP (Normal Link Pulse)** を
16 ms (8〜24 ms) ごとに出す。NLP は幅 100 ns の正のパルス 1 発で、FLP の 1 発と同じ形だ。
ch1 (ルータの送り) と ch2 (PC の送り) のどちらにも、独立に出る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 NLP 1 発 — 幅 100 ns、振幅 2.5 V
time: 100ns/div
trigger: ch1 rising 1.25V at -3div
ch1: pulse 62.5Hz 1.25V offset 1.25V duty 0.000625%
cursors: [0, 100ns]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/01-link-pulse-2.svg)

図4 の `pulse 62.5Hz` は 16 ms ごとの繰り返しで、1 画面 (1 µs) には 1 発だけが入る。
実物のパルスは角が丸く、立ち下がりのあとに小さく負に振れてから 0 V に戻る (トランスの応答)。
規格の型枠は幅 60〜200 ns、振幅は 2.2〜2.8 V<sub>p</sub> を許す。

### 段階 3: フレーム — プリアンブルとマンチェスター

PC からルータに `ping` を打つ。ch2 (PC の送り) に要求のフレーム、少し遅れて ch1 (ルータの送り) に
応答のフレームが出る。フレームの先頭はプリアンブルで、`1010…` のマンチェスターは
**5 MHz の方形波** (±2.5 V) に見える。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 プリアンブル — 1010… のマンチェスターは 5 MHz の方形波
time: 100ns/div
trigger: ch1 rising 0V
ch1: square 5MHz 2.5V
cursors: [0, 200ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/01-link-pulse-3.svg)

プリアンブルのあと (SFD の最後の `11` から) はデータに応じて変わり目の間隔が 50 ns と 100 ns で
混ざり、方形波には見えなくなる。フレームの終わりは正側に 250 ns 以上とどまってから 0 V に戻る
(TP_IDL、アイドルの始まり)。次のフレームまでは少なくとも 9.6 µs (96 ビット分) 空く。

ping のフレームの長さは OS で違う。Linux の `ping` はデータ 56 バイトで、ICMP 64 + IP 20 + Ethernet 14 +
FCS 4 = 102 バイト。線の上ではプリアンブルと SFD の 8 バイトが付いて 110 バイト = 880 ビット = **88.0 µs**。
Windows はデータ 32 バイトで 86 バイト = **68.8 µs**。時間軸を 10 µs/div にすると 1 フレームが 9 目盛に入る。

ルータは ping を打たなくても、ARP の問い合わせや mDNS などのブロードキャストを時々流す。
ch1 に ping と無関係のフレームが出たらそれで、次の題で Pico 2 が受ける信号の予行になる。

## 計器の設定

計器は Analog Discovery 3 の Scope (BNC アダプタ基板)。信号が 10 MHz までなので、帯域 30 MHz 以上の
BNC アダプタ基板で足りる。125 MS/s で標本の間隔は 8 ns、幅 100 ns のパルスが 12 点で描ける。

| 項目 | 設定 |
| --- | --- |
| ch1 | 1+ をピン 3、1− をピン 6 (ルータの送り)。500 mV/div、0 V を下から 1 目盛 |
| ch2 | 2+ をピン 1、2− をピン 2 (PC の送り)。ch1 と同じ |
| トリガ | Normal、ch1 立ち上がり 1.25 V (パルスとプリアンブルのどちらにも掛かる)。段階 3 で PC の送りを見るときは ch2 |
| 時間軸 | 図4 は 100 ns/div、図3 は 20 µs/div (バースト全体は 500 µs/div)、図5 は 100 ns/div、1 フレームは 10 µs/div |
| Filter | 500 µs/div より遅い時間軸では MinMax (細いパルスを間引きで落とさない) |

## 見るべき値

| 何を | 値 | 根拠 |
| --- | --- | --- |
| NLP の幅 (図4 の ΔX) | 100 ns (型枠は 60〜200 ns) | IEEE 802.3 14.3.1.2.1 |
| NLP の間隔 | 16 ms (8〜24 ms) | 同 14.2.1.1 |
| パルスの高さ (図4 の Vmax) | 2.5 V (2.2〜2.8 V) | 同 14.3.1.2.1 (100 Ω 負荷) |
| FLP のクロックパルスの間隔 (図3 の ΔX) | 125 µs (±14 µs)。データパルスはその 62.5 µs 後 | 同 28.2.1.1.2 |
| FLP の 1 バースト | 17〜33 発、2 ms ほど。16 ms ごと | 同 28.2.1.1.2 |
| プリアンブルの周波数 (図5 の Freq) | 5 MHz (ビット 100 ns、`1010…`)。Vpp は 5 V | 同 7.2.3.2・14.3.1.2.1 |
| プリアンブルと SFD の長さ | 8 バイト = 6.4 µs | 同 7.2.3.2・7.2.3.3 |
| ping 1 フレーム (線の上) | Linux 88.0 µs / Windows 68.8 µs | 上の計算 |
| フレームの間 | 9.6 µs 以上 (IFG) | 同 4.2.3.2.2 |

数は規格の値で、手元のルータと PC で**同じに見えるかは測って確かめる**。振幅はケーブルが長いほど下がる
(100 m で半分ほど)。NLP の間隔は機器ごとに 8〜24 ms の中の決まった値を取る。

## LTspice での確かめ

ルータと PC が出す信号を見るだけの題で、計算する回路が無い。この題は SPICE の対象外。数値は
IEEE 802.3 の値とビット数からの算術で、上の表に根拠の節を書いた。

## 出典

- [IEEE 802.3-2022](https://ieeexplore.ieee.org/document/9844436) — Clause 14 (10BASE-T。14.2.1.1 リンクパルスの間隔、14.3.1.2.1 出力の振幅と型枠)、Clause 28 (Auto-Negotiation。28.2.1.1.2 FLP バーストの時間)、Clause 4 (4.2.3.2.2 IFG)、Clause 7 (7.2.3.2 プリアンブル・7.2.3.3 SFD)。IEEE の GET Program で無料で読める
- [Ethernet over twisted pair — Wikipedia (英語)](https://en.wikipedia.org/wiki/Ethernet_over_twisted_pair) — ピン配置 (MDI と MDI-X) とリンクパルスの概要
- [Autonegotiation — Wikipedia (英語)](https://en.wikipedia.org/wiki/Autonegotiation) — FLP バーストの構成 (17〜33 パルス、125 µs と 62.5 µs)
- [Manchester code — Wikipedia (英語)](https://en.wikipedia.org/wiki/Manchester_code) — IEEE 802.3 の符号の向き (1 は低→高)
