---
book: analog-discovery
chapter: 1
id: 1-16
title: Raspberry Pi で WaveForms を動かす (Linux 版)
tier: 200
source: 自作 (入れ方は Digilent の Analog Discovery 3 Getting Started Guide)
board: —
---

# 1-16 Raspberry Pi で WaveForms を動かす (Linux 版)

WaveForms には Windows・macOS のほかに Linux 版があり、Raspberry Pi の上でも動く。机のパソコンを空けずに、
Raspberry Pi を Analog Discovery 3 (AD3) の専用の計測器にしておける (長時間のロガー (1-13) や、
SDK を使う第 11 章の自動化を回しっぱなしにする、など)。

この題では Raspberry Pi に WaveForms を入れ、0-3 のループバックで最初の 1 本を出して見る。
手順は Linux の一般の手順 (Adept Runtime → WaveForms の順に `.deb` を入れる) と同じで、
Raspberry Pi で違うのは**パッケージの CPU の種類**と**USB の電力**の 2 つ。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine 1,2 1,4 1
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G1: ground 1,4
wires:
  - 1,2 -- 3,2
  - 1,4 -- 3,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/16-raspberry-pi-linux.svg)

この題は実体配線図を付けない — 0-3 と同じループバックで、W1 と 1+ の付属ワイヤを直に挿し合わせるだけ (基板を使わない)。
Raspberry Pi の GPIO は使わない (AD3 は USB だけでつなぐ)。

## 入れ方

1. **OS の CPU の種類を確かめる**。端末で `dpkg --print-architecture` を打つ。64 ビットの Raspberry Pi OS なら `arm64`、
   32 ビットなら `armhf`。この後のパッケージは、出た名前と同じ物を選ぶ (混ぜると入らない)
2. Digilent のダウンロードの頁から、**Adept Runtime** と **WaveForms** の、同じ CPU の種類の `.deb` を取る。
   Getting Started Guide は、Adept Runtime の版を WaveForms に合わせるよう書いている
3. **Adept Runtime を先に**、WaveForms を後に入れる。足りない部品は最後の 1 行で入る

```bash
dpkg --print-architecture                  # arm64 か armhf か
sudo dpkg -i <Adept Runtime の .deb>
sudo dpkg -i <WaveForms の .deb>
sudo apt-get install -f                    # 足りない依存を入れる
```

WaveForms を入れると、計器の画面 (WaveForms の本体)・SDK のライブラリ (第 11 章で Python から呼ぶ物)・
SDK の見本が一緒に入る (Getting Started Guide の Linux の節)。

## USB の電力

AD3 は、計器を何も動かしていなくても USB から最大 700 mA (約 3.5 W) を取る。Specifications は、補助電源を使わないとき、
つなぐ先の USB の口が **USB 3.2 の電力** (規格では 1 つの口で 900 mA) を出せることを求めている。

| つなぎ方 | どうなるか |
| --- | --- |
| Raspberry Pi の USB 3.0 の口 (青) に直に | 900 mA を出せる口なら動く (目安。Raspberry Pi 自身の電源の容量と、ほかに挿した機器の電流による) |
| USB 2.0 の口 (黒) か、電源の無い USB ハブ | 足りないことがある。WaveForms がデバイスを見失う・Supplies が使えない、などが出る (目安) |
| AD3 の DC ジャックに 5 V の補助電源 (0-7) | USB の電力に頼らない。Raspberry Pi で回しっぱなしにするならこれを勧める |

Supplies で外の回路に電力を出す題 (0-7・1-11 など) を Raspberry Pi で行うときは、補助電源を使う。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Device Manager | WaveForms を開くと AD3 が出る。出なければ USB の電力と Adept Runtime を疑う |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1) | DC、200 µs/div、トリガは CH1 の立ち上がり 0 V。Measurements に Vpp・Frequency |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 Raspberry Pi の WaveForms でも同じ画面 — Vpp 2.00 V・1.000 kHz
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/16-raspberry-pi-linux.svg)

## 見るべき値

| 確かめる所 | 期待する値 | 分かること |
| --- | --- | --- |
| `dpkg --print-architecture` | `arm64` (64 ビットの OS) | 選ぶパッケージの種類 |
| Device Manager | Analog Discovery 3 が 1 行出る | Adept Runtime がデバイスを見つけた |
| Scope (CH1) | Vpp 2.00 V・1.000 kHz (図2) | パソコンの WaveForms と同じに測れる |
| 0-4 で保存したプロジェクトを開く | 同じ画面に戻る (版が同じなら) | 設定のファイルは OS をまたいで使える (目安。版が違うと読めないことがある) |

測る速さそのもの (標本化・バッファ長) は AD3 の中で決まるので、Raspberry Pi でも同じ。違いが出るのは、
画面の書き換えの速さと、Record モード (2-11) でディスクへ流せる速さ (Specifications は「ホストの性能による」と書く) である。

## LTspice での確かめ (対象外)

ソフトウェアを入れる題で、回路は 0-3 のループバック。算術で確かめた。AD3 の待機の電力は 5 V × 700 mA = 3.5 W、
USB 3.2 の口の 900 mA は 4.5 W で、差の 1 W ほどしか余らない。振幅 1 V の正弦波は Vpp 2.00 V、1 kHz の 1 周期 1 ms は
200 µs/div で 5 目盛。本文の値と合う。

## 出典

自作。Linux への入れ方 (Adept Runtime を先に、`dpkg -i` と `apt-get install -f`、版をそろえる、入る物) は Digilent の
[Analog Discovery 3 Getting Started Guide](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Getting-Started-Guide_1123.pdf)
(Installing WaveForms: Linux の節。Raspberry Pi 用の詳しい手引きがあるとも書く)。USB の電力 (待機で最大 700 mA、USB 3.2 の電力が要る) と
Record モードの速さは
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Power Supplies の節) と
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Connectivity・Horizontal System の節) による。
