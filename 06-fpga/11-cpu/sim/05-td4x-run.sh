#!/bin/sh
# 11-5 の確かめ: td4x を lint し、Verilator と iverilog で試験台を回し、yosys で大きさを数える
# 使い方: sh 05-td4x-run.sh   (Verilator 5.x・iverilog・yosys が要る)
set -eu
cd "$(dirname "$0")"
OUT=${OUT:-${TMPDIR:-/tmp}/td4x-11-5}
mkdir -p "$OUT"
# 本文のファイル名はモジュール名と同じ (td4x.v)。ここでは題の番号を頭に付けたので DECLFILENAME を外す
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module td4x 05-td4x.v
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module td4x_rom 05-td4x.v
echo "lint td4x・td4x_rom: 0 warnings"
verilator --binary --timing --trace --quiet-stats -Wno-fatal -Wno-DECLFILENAME --top-module tb_td4x \
  --Mdir "$OUT/obj" -o Vtb 05-td4x.v 04-td4-xrom.v 05-td4x-tb.v > "$OUT/build.log" 2>&1
echo "== Verilator"
"$OUT/obj/Vtb"
echo "== iverilog"
iverilog -g2012 -Wall -Wno-timescale -o "$OUT/iv" 05-td4x.v 04-td4-xrom.v 05-td4x-tb.v
vvp -n "$OUT/iv"
for top in td4_xrom td4x; do
  echo "== yosys $(yosys -V | cut -d' ' -f2) synth_gowin $top"
  yosys -p "read_verilog 04-td4-xrom.v 05-td4x.v; synth_gowin -top $top; stat" | sed -n '/Printing statistics/,$p' | grep -E '^ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
done
OSS=${OSS:-$HOME/tools/oss-cad-suite/bin}
if [ -x "$OSS/yosys" ]; then
  for top in td4_xrom td4x; do
    echo "== $("$OSS/yosys" -V | cut -d' ' -f1-2) synth_gowin $top"
    "$OSS/yosys" -p "read_verilog 04-td4-xrom.v 05-td4x.v; synth_gowin -top $top; stat" | sed -n '/Printing statistics/,$p' | grep -E '^ +[0-9]+ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
  done
fi
