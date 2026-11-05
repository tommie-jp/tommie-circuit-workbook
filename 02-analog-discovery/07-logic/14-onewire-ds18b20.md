---
book: analog-discovery
chapter: 7
id: 7-14
title: 1-Wire (DS18B20)
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Patterns と Logic の 1-Wire)
board: BB
---

# 7-14 1-Wire (DS18B20)

**1-Wire** はデータ線 1 本 (DQ) と GND で話す方式で、温度センサー DS18B20 が代表。I2C と同じく線は引き下げるだけで、
H は 4.7 kΩ (オーム) のプルアップが作る。クロックの線が無いので、**L にする時間の長さ**で意味が決まる (Maxim のデータシートの値)。

| 動作 | 主 (AD3) がすること | DS18B20 がすること |
| --- | --- | --- |
| リセット | 480 µs (マイクロ秒) 以上 L | 離されてから 15〜60 µs 待ち、60〜240 µs の L を返す (在席パルス) |
| 書き 1 | 1〜15 µs だけ L にして離す (スロットは 60 µs 以上) | 15〜60 µs の間に線を読む |
| 書き 0 | 60〜120 µs L | 同上 |
| 読み | 1 µs 以上 L にして離し、15 µs 以内に線を読む | 0 を返すときは L を続ける |

AD3 の Protocol に 1-Wire の主は無いが、**Pattern の Custom を Output OD (オープンドレイン) で流せば、主の並びを決め打ちで出せる**。
DS18B20 が 1 個だけなら、Read ROM (0x33) の後は 64 回の読みのスロットを出すだけで、返事を待って分かれる所が無い。
返ってきた線は **Logic の 1-Wire の解読**で読み、在席パルスの電圧は Scope で見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 DS18B20 の DQ を 4.7 kΩ で引き上げ、DIO0 (OD) で叩く
parts:
  AD:
    type: device
    at: 2,4
    label: Analog Discovery 3
    pins: [V+, DIO0, 1+, GND, 1-]
    turn: mirror
  U1:
    type: device
    at: 10,4
    label: DS18B20
    pins: [VDD, DQ, GND]
  R1: resistor 7,2 7,3 4.7k
  G1: ground 6,6
wires:
  - AD.V+ -| 6,2
  - 6,2 -- 7,2
  - 7,2 -- 8.5,2
  - U1.VDD -| 8.5,2
  - AD.DIO0 -- 6.5,3.75
  - 6.5,3.75 -- 6.5,4
  - AD.1+ -- 6.5,4
  - 6.5,4 -- 7,4
  - 7,3 -- 7,4
  - 7,4 -- U1.DQ
  - AD.GND -| 6,6
  - AD.1- -| 6,6
  - 6,6 -- 8.5,6
  - U1.GND -| 8.5,6
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/14-onewire-ds18b20.svg)

- DS18B20 は VDD を 3.3 V につなぐ使い方 (外部電源)。DQ を R1 (4.7 kΩ) で 3.3 V に引き上げる。データシートの電源の範囲は 3.0〜5.5 V
- DIO0 を DQ に直接つなぐ。Pattern の Output を OD にすると、DIO0 は L か Z (離す) だけを出し、H を押し付けない。
  PP (プッシュプル) のままだと、DS18B20 が L を返すときに DIO0 の H とぶつかる
- 同じ DQ を Scope の 1+ でも見る。Logic は DIO0 そのものを読む (Pattern が出している線を、同じ DIO で読める)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (DS18B20 は平らな面が手前)
board: half
parts:
  U1: ic3 f10 f11 f12 DS18B20
  R1: resistor h11 h15 4.7k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [GND, 1-, 1+, DIO0, V+]
wires:
  - AD.GND -- -b5 black
  - AD.1- -- -b6 black
  - j10 -- -b10 black
  - AD.DIO0 -- i11 yellow
  - AD.1+ -- j11 blue
  - j12 -- +b12 red
  - j15 -- +b15 red
  - AD.V+ -- +b20 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/14-onewire-ds18b20.svg)

- DS18B20 (U1) は平らな面を手前に f10〜f12 に挿す。左から 1 番 GND・2 番 DQ・3 番 VDD (データシートの TO-92 の図)。
  逆に挿すと電源が逆になり、熱くなる。挿す前に印字の面を確かめる
- R1 は DQ の 11 列 (h11) から 15 列へ。15 列と VDD の 12 列を赤い線で下の + レールへ、GND の 10 列を − レールへ
- AD3 は下に置く。DIO0 (黄) と 1+ (青) を DQ の 11 列 (i11・j11) へ、V+ を + レール、GND と 1− を − レールへ
- DS18B20 は部品の表に無いので、TO-92 の 3 ピンの IC の形 (`ic3`) に型番を書いて描いた

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | DIO0 = Custom、**Output OD**、Idle Z、Frequency 200 kHz (1 標本 5 µs)。下の CSV を Import し、Run は 1 回 (Repeat 1) |
| Logic | DIO0。Rate 1 MS/s、Samples 8k (8 ms)。トリガは DIO0 の立ち下がり。Add → **1-Wire** (Data = DIO0、Protocol = ROM) |
| Scope CH1 (1+) | DQ。1 V/div、100 µs/div、トリガは CH1 の立ち下がり 1.65 V、Single |

並びは Python で作る (下)。`rom` は Read ROM、`convert` は温度の変換の開始、`scratch` は結果を読む並び。
Read ROM は 1,148 標本になる。ヘルプによれば Analog Discovery の Pattern の Custom のバッファは構成によって 1k か 16k ビットなので、
**Device Manager で Pattern に大きいバッファを割り当てる構成**を選ぶ (1-10)。

```python
# 1-Wire の並びを Pattern の Custom 用の CSV にする。1 行 = 5 us (Frequency 200 kHz)
# 0 = L に引く、1 = 離す (Output を OD にすると 1 は Z になり、4.7 kΩ で H に戻る)
import sys

STEP_US = 5

def low_release(low_us, release_us):
    return [0] * (low_us // STEP_US) + [1] * (release_us // STEP_US)

def reset():
    return low_release(480, 480)            # 480 us の L と、在席パルスを待つ 480 us

def write_byte(value):
    out = []
    for i in range(8):                      # 下位ビットから送る
        out += low_release(5, 60) if (value >> i) & 1 else low_release(60, 5)
    return out

def read_slots(n):
    return low_release(5, 60) * n           # 5 us だけ L にして離す。0 なら DS18B20 が L を続ける

SEQUENCES = {
    'rom':     reset() + write_byte(0x33) + read_slots(64),                    # Read ROM
    'convert': reset() + write_byte(0xCC) + write_byte(0x44),                  # Skip ROM・Convert T
    'scratch': reset() + write_byte(0xCC) + write_byte(0xBE) + read_slots(72), # Skip ROM・Read Scratchpad
}

name = sys.argv[1] if len(sys.argv) > 1 else 'rom'
samples = SEQUENCES[name] + [1] * 20         # 最後は 100 us 離したまま
with open(f'onewire_{name}.csv', 'w') as f:
    f.write('DIO0\n')
    f.writelines(f'{s}\n' for s in samples)
print(name, len(samples), 'samples,', len(samples) * STEP_US, 'us')
```

`python onewire_csv.py rom` で `onewire_rom.csv` ができる (1,148 標本、5.74 ms)。この PC で 3 つとも作り、`rom` の頭がリセット 96 標本・
離す 96 標本・0x33 の 8 スロットの順に並ぶことを確かめた。**AD3 の実機には流していない**。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 リセット (480 µs の L) の後に DS18B20 が在席パルスを返す
time: 100us/div
trigger: ch1 falling 1.65V at -4div
ch1: {wave: = 3.3V * (1 - step(t) * step(480us - t) - step(t - 510us) * step(630us - t)), range: 1V/div, position: -2div}
cursors: [495us, 570us]
measure: [vmax, vmin]
notes:
  - band 0 480us
  - band 510us 630us
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/14-onewire-ds18b20.svg)

図3 は計算で作った理想の画面で、実測ではない。DS18B20 が待つ時間と在席パルスの長さは個体で変わり (データシートの範囲 15〜60 µs と 60〜240 µs)、
図では 30 µs と 120 µs と置いた。X1 (495 µs) は離して H に戻った所、X2 (570 µs) は DS18B20 が引いている所。**主は何もしていないのに L になる**のが在席の印。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 読みの 8 スロット — 15 µs の値を下位から並べると 0x28 (家族コード)
device: ad3
time: 60us/div
start: -20us
sample: 1MHz
signals:
  DQ: dio0 edges -20us=1 0s=0 30us=1 65us=0 95us=1 130us=0 160us=1 195us=0 200us=1 260us=0 290us=1 325us=0 330us=1 390us=0 420us=1 455us=0 485us=1
cursors: [15us, 210us]
trigger: DQ falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/14-onewire-ds18b20.svg)

図4 は Read ROM の後の最初の 8 スロットの理想の画面 (実測ではない)。どのスロットも主が 5 µs だけ L にし、1 を返すスロットはすぐ H に戻り、
0 を返すスロットは DS18B20 が 30 µs ほど L を続ける (図では 30 µs と置いた)。スロットの頭から 15 µs の値を下位から並べると 0・0・0・1・0・1・0・0 = **0x28**。
X1 は 1 つ目 (0)、X2 は 4 つ目 (1) の 15 µs の点。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 1-Wire 温度センサー | DS18B20 (TO-92、3.3 V で使う) |
| R1 | 抵抗 (1/4 W)、プルアップ | 4.7 kΩ |
| — | 電源・信号源・計器 | Analog Discovery 3 (Supplies 3.3 V、Pattern、Logic、Scope) |

L の間に R1 を流れるのは 3.3 V ÷ 4.7 kΩ = 0.70 mA。DS18B20 が引ける 4 mA (0.4 V で、データシート) に余裕がある。変換中の電流は 1.5 mA 以下 (同)。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 在席パルス (Scope) | 離して 15〜60 µs 後に 60〜240 µs の L、L は 0.1 V ほど | DS18B20 が線につながって動いている |
| Logic の 1-Wire の解読 (`rom`) | Reset → Presence → Read ROM [0x33] → Family: 0x28 → SN (48 ビット) → CRC | 64 ビットの ROM。家族コード 0x28 が DS18B20 の印 |
| 読みのスロットの L の長さ | 1 は 5 µs、0 は 15〜60 µs | 主の 5 µs に DS18B20 が足した分が 0 |
| `convert` を流して 1 s 以上待ち、`scratch` を流す | 最初の 2 バイトが温度 (下位・上位)。25.0625 °C なら 0x91 0x01 | 12 ビットで 0.0625 °C 刻み (データシートの表) |
| `convert` を飛ばして `scratch` | 0x50 0x05 (= 85 °C) | 電源を入れた直後の値。変換を始めていない印 |
| R1 を外して `rom` | 在席パルスが見えず、線はずっと L か宙に浮く | H はプルアップだけが作る |

変換には 12 ビットで最大 750 ms かかる (データシート)。Pattern の 1 回の並びに入れると標本が足りないので、`convert` と `scratch` の 2 回に分けた。
VDD を電源につないでいるので、2 回の間に線を H のまま放っておいてよい。

## LTspice での確かめ

`sim/14-onewire-ds18b20.cir` で、読みのスロット (5 µs の L) から離したあと、DQ が 4.7 kΩ で DS18B20 の V<sub>IH</sub> 2.2 V に戻るまでの時間を読んだ。
線の容量は 50 pF (仮定) と、長い線を足した 500 pF。DIO0 は理想のスイッチ (オン 50 Ω、仮定)。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 2.2 V に戻るまで (50 pF) | 0.26 µs (計算 1.1 · R · C) | 0.256 µs | 合う。15 µs の読みの点よりずっと早い |
| 2.2 V に戻るまで (500 pF) | 2.6 µs | 2.56 µs | 合う。まだ 15 µs の内 |
| L の電圧 (DIO0 が引く) | 0.1 V より下 | 35 mV | 合う |
| プルアップの電流 | 0.70 mA | 0.70 mA | 合う |

並びは算術と上の Python で確かめた。Read ROM の 1,148 標本 = 192 (リセット) + 8 × 13 (0x33) + 64 × 13 (読み) + 20。家族コード 0x28 を下位から並べると 0・0・0・1・0・1・0・0 で、図4 と合う。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Patterns の Custom と Output、Logic の 1-Wire)。1-Wire の時間と DS18B20 の値は
[Maxim DS18B20 データシート](https://cdn-shop.adafruit.com/datasheets/DS18B20.pdf)。

参考: [1-Wire (Wikipedia)](https://ja.wikipedia.org/wiki/1-Wire)
