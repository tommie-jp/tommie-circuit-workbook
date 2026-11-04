---
book: fpga
chapter: 11
id: 11-19
title: TD4 の中をブラウザの画面に出す — ハーネスにレーンを足す
tier: 100
source: 自作 (命令の決め方は asfdrwe の simpleTD4 (MIT) の TD4.v に合わせた)
board: —
device: WEB
---

# 11-19 TD4 の中をブラウザの画面に出す — ハーネスにレーンを足す

この題は実体配線図と Analog Discovery 3 の図を付けない。ブラウザの中で動く題で、組む物が無いから。
ロジックアナライザの図も付けない。見える画面は 11-2 の図1・図2 と同じなので、そちらを見る。

11-2 では、TD4 の `counter` に A・B・いまの命令・キャリーフラグの 4 本の出力 (`o_a` `o_b` `o_op` `o_c`) を足し、
15 命令のプログラムを 1 クロックずつ表と波形で追った。この題では、その 4 本を soft-fpga のブラウザの画面にレーンとして出し、
1 クロックずつ進めて同じ表を画面で読む。Verilog は 11-2 のまま使う。

## つなぐ (ハーネスと画面)

4-5 と同じく、足した出力をハーネスで読み、画面にレーンを足す。ビルドの手順 (`scripts/build-wasm.sh`) は替えない。
ファイルが 1 つで、最上位の名前 (`counter`) も、呼ぶ関数 (`step()` など) も同じだから。

1. `examples/01-counter/cxx/harness.cpp` — `record_sample()` の 1 語に、11-2 で足した 4 つの出力を詰める。リングバッファの 1 サンプルは 32 ビットで、元は下の 9 ビット (`count` と `rst`) しか使っていない

   ```cpp
   static void record_sample() {
       const uint32_t w[1] = {
           ((uint32_t)top->count & 0xFFu) | ((uint32_t)(top->rst & 1u) << 8)
           | ((uint32_t)(top->o_c & 1u) << 9)                  // 11-2 で足した 4 行
           | ((uint32_t)(top->o_a & 0xFu) << 12)
           | ((uint32_t)(top->o_b & 0xFu) << 16)
           | ((uint32_t)(top->o_op & 0xFFu) << 20)
       };
       ring.record(w);
   }
   ```

2. `js/sft-counter-la-defs.js` — `COUNTER_LA_SIGNALS` の頭に 6 本のレーンを足し、`COUNTER_LA_GROUPS` の頭に 1 組足す。
   `bit` はリングバッファの何ビット目から読むか、`width` は何ビットか。PC と OUT は `count` の上と下の 4 ビットを別の名前で読む

   ```js
     { id:'td4_pc',  label:'PC',  word:0, bit:4,  type:'hex', width:4, color:'#aa5500', on:true, tip:'TD4 の PC (count[7:4])。' },
     { id:'td4_op',  label:'op',  word:0, bit:20, type:'hex', width:8, color:'#aa5500', on:true, tip:'TD4 のいまの命令 (ROM[PC])。' },
     { id:'td4_a',   label:'A',   word:0, bit:12, type:'hex', width:4, color:'#228833', on:true, tip:'TD4 のレジスタ A。' },
     { id:'td4_b',   label:'B',   word:0, bit:16, type:'hex', width:4, color:'#228833', on:true, tip:'TD4 のレジスタ B。' },
     { id:'td4_out', label:'OUT', word:0, bit:0,  type:'hex', width:4, color:'#228833', on:true, tip:'TD4 の出力ポート (count[3:0])。' },
     { id:'td4_c',   label:'C',   word:0, bit:9,  type:'bit', width:1, color:'#cc3333', on:true, tip:'TD4 の桁上げ (1 で桁上げあり)。' },
   ```

   ```js
     { label:'TD4',     color:'#aa5500', ids:['td4_pc','td4_op','td4_a','td4_b','td4_out','td4_c'] },
   ```

直した 2 つのファイルの写しは `sim/02-td4-trace-harness.cpp` と `sim/02-td4-trace-la-defs.js` に置いた。`js/` は全部の例で共通のフォルダなので、この直しはほかの例の画面にも見える。終わったら `git checkout js/sft-counter-la-defs.js` で戻す。

## 手順

1. 11-1 の `counter.v` の `td4_rom` と `counter` を 11-2 の 2 つに替え、`harness.cpp` と `sft-counter-la-defs.js` を上のとおり直す
2. lint を掛ける (`verilator --lint-only -Wall examples/01-counter/verilog/counter.v`)
3. 4-3 と同じく `docker compose -f docker/compose.yml run --rm build-wasm scripts/build-wasm.sh` でビルドし、
   `examples/01-counter/web/doStartWebServer.sh` で Web サーバを立てて `http://localhost:8081/` を開く
4. Run を押さずに、ブラウザの開発者ツールの Console で `Module._step()` を 1 回ずつ打つと、1 クロックずつ進む。
   画面の `PC` `op` `A` `B` `OUT` `C` のレーンが 1 サンプルずつ伸びる

ブラウザの画面では、`PC` `op` `A` `B` `OUT` は 2 桁の 16 進 (`01` `40` …) で出る。ズームを 8x にすると、1 サンプルの幅に値が読める。
1 クロックごとの値は 11-2 の表のとおりに並ぶ。

## 見るべき値

soft-fpga f89a885 (2026-10-13) の 01-counter に 11-2 の Verilog と本文の 2 か所の直しを入れ、`sfa-dev-wasm:local` (Verilator 5.048・Emscripten 5.0.7) でビルドして、
Playwright の Chromium で開いた。`step()` を 16 回呼んでリングバッファを読み、画面にレーンが出ることを見た。

| 見る所 | 値 | 種類 |
| --- | --- | --- |
| 画面のレーン | `PC` `op` `A` `B` `OUT` `C` が `count` の上に並ぶ | 動かして確かめた (Chromium) |
| 16 クロックの PC・A・B・OUT・C・`op` | 11-2 の表のとおり | 動かして確かめた (Chromium) |

Chromium のリングバッファの値 (リセットの 2 サンプルのあと、16 進 8 桁) は `04005010 00355020 05c58030 0e018240 …`。
上の位から `op` (2 桁)・B・A・(C と rst)・`count` (PC と OUT) の順で、たとえば `0e018240` は `op` = E0、B = 1、A = 8、C = 1、PC = 4、OUT = 0。

## シミュレーションでの確かめ

本文の直しを入れた `harness.cpp` (`sim/02-td4-trace-harness.cpp`) を 11-2 の `counter.v` と link し、ブラウザと同じ `step()` を 45 回呼んでリングバッファを読む試験
(`bash sim/02-td4-trace-run.sh` の 3 つめ、`sim/02-td4-trace-tb.cpp`) を、手元の Verilator 5.042 で回した。結果は 11-2 の「シミュレーションでの確かめ」。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| ブラウザのリングバッファ | 11-2 の表と同じ値 | Chromium で 16 クロックとも同じ (上の 16 進) | 合った |
| ブラウザの画面のレーンの見え方 | `PC` `op` `A` `B` `OUT` `C` が出る | Chromium の画面で 6 本のレーンが出た (目で見た) | 合った |

## 出典

- [tommie-jp/soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/01-counter` (`cxx/harness.cpp`) と `js/sft-counter-la-defs.js` — 直した先
- [simpleTD4](https://github.com/asfdrwe/simpleTD4) (asfdrwe、MIT) — 命令のビットの決め方。直しは自作
