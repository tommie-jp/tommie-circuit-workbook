# Pico 2 のプログラムの標準テスト

題の本文にある Pico 2 のプログラム (C・MicroPython) を、実機に載せる前に PC で確かめる。
決めた経緯と計画は、非公開側のメモ docs/133 にある。ここは使い方と足し方だけ書く。

**実機の置き換えではない。** 層が全部通っても、題の「実機で動かしていない」の注意書きは外さない。

## 層

| 層 | 道具 | 確かめること | 実行 |
| --- | --- | --- | --- |
| A | `host/` の SDK のモック + gcc | SDK の呼び方と、設定から導く物理量 (周期・パルス幅・速度) | `npm run pico:host` |
| A' | `upy/` の `machine` のスタブ + CPython | MicroPython 版でも同じ数になる | `npm run pico:upy` |
| B | rp2040-pio-emulator | PIO プログラムの出力の並びとサイクル数 | `npm run pico:pio` |
| 前提 | `uf2/` + Docker の wb-pico-sdk | 全部の C が Pico 2 用の `.uf2` になる | `npm run pico:uf2` |
| D | `emu/` + Docker の picoemu (RP2350 のエミュレータ) | `.uf2` を丸ごと動かし、GPIO の並びと sleep の間隔 | `npm run pico:emu` |

`npm run pico:test` が A・A'・B (Docker 不要、`npm run all` に入る)、`npm run pico` が前提と D (Docker が要る)。
B は `pip install rp2040-pio-emulator==0.88.0` が無ければ SKIP する。

## 取り出し

`scripts/pico-extract.mjs` が、題の本文のコードブロックを `out/pico/` に取り出す。写しをコミットしない。

- C: `c` か `cpp` のブロックで、`int main(` と `pico/` か `hardware/` の include を含む
- MicroPython: `python` のブロックで、`machine` か `rp2` を使う
- ブロックの直前の行に `<!-- program: skip -->` を置くと取り出さない (断片・別の機種向け)

## 期待値の足し方

- C: `host/cases/<章>-<題>.c` を書く。1 行目に `// program: <out/pico からの相対パス>`。
  `mock_run(予算 µs)` で本文の `main` を仮想時刻で動かし、`M` (GPIO の変化・PWM・ADC・I2C・UART など) を調べる。
  使えない API はモックにない。`host/mock/hardware/*.h` に足す (本物と同じ引数で、記録するだけ)
- MicroPython: `upy/cases/<章>-<題>.py` に `PROGRAM`・`BUDGET_US`・`setup(S)`・`check(S, out, ok)`。
  C 版と同じ数を期待値にする
- 期待値は、題の「見るべき値」の表の数と同じ量で書く。レジスタの数にしない
- 周期や遅れの assert は、実機の速さではなく、本文の式から決まる値だけにする
  (仮想時刻は `sleep` で進む。`tight_loop_contents` は 1 µs と置いた)

## 見ていない物

電圧・電流・外部部品、XIP フラッシュから動かしたときのループの周期、USB シリアルの遅れ、2 コアの競合、
RP2350 のエラッタ。PWM・UART・I2C・ADC は picoemu の GPIO の記録に出ないので、D では見ない (A が見る)。
