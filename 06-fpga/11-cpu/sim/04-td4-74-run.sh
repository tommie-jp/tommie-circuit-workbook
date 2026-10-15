#!/bin/sh
# 11-4 の確かめ: IC の模型と TD4.v (5-8) を並べて回し、TD4 を合成・配置配線する
# 使い方: sh 04-td4-74-run.sh   (iverilog・Verilator・yosys が要る。OSS CAD Suite があれば nextpnr も回す)
set -eu
cd "$(dirname "$0")"
TD4=../../05-soft-fpga-pico/sim/08-td4.v
OUT=${OUT:-${TMPDIR:-/tmp}/td4-11-4}
OSS=${OSS:-$HOME/tools/oss-cad-suite/bin}
mkdir -p "$OUT"

# 本文のファイル名はモジュール名と同じ (td4_xrom.v)。ここでは題の番号を頭に付けたので DECLFILENAME を外す
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module td4_xrom 04-td4-xrom.v
echo "lint td4_xrom: 0 warnings"

iverilog -g2012 -Wall -Wno-timescale -o "$OUT/t74" 04-td4-74.v 04-td4-xrom.v 04-td4-74-tb.v "$TD4"
vvp -n "$OUT/t74"
# 図の波形 (td4_74_wave.vcd は $OUT に出す)
iverilog -g2012 -Wall -o "$OUT/w74" 04-td4-74.v 04-td4-74-wave-tb.v
(cd "$OUT" && vvp -n w74)

for top in td4_xrom TD4; do
  src=04-td4-xrom.v; [ "$top" = TD4 ] && src=$TD4
  echo "== yosys $(yosys -V | cut -d' ' -f2) synth_gowin $top"
  yosys -p "read_verilog $src; synth_gowin -top $top; stat" | sed -n '/Printing statistics/,$p' | grep -E '^ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
done

if [ -x "$OSS/nextpnr-himbaechel" ]; then
  for top in td4_xrom TD4; do
    src=04-td4-xrom.v; cst=04-td4-xrom.cst
    [ "$top" = TD4 ] && { src=$TD4; cst=04-td4-full.cst; }
    echo "== $("$OSS/yosys" -V | cut -d' ' -f1-2) + nextpnr-himbaechel: $top"
    "$OSS/yosys" -p "read_verilog $src; synth_gowin -top $top -json $OUT/$top.json; stat" | sed -n '/Printing statistics/,$p' | grep -E '^ +[0-9]+ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
    for seed in "" 1 2 3; do
      opt=""; [ -n "$seed" ] && opt="--seed $seed"
      # shellcheck disable=SC2086
      "$OSS/nextpnr-himbaechel" --json "$OUT/$top.json" --write "$OUT/$top-pnr.json" \
        --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=$cst --freq 27 $opt \
        > "$OUT/$top-pnr.log" 2>&1
      echo "seed=${seed:-なし} $(grep 'Max frequency' "$OUT/$top-pnr.log" | tail -1 | sed 's/.*: //')"
    done
    grep -E 'LUT4:|DFF:|IOB:' "$OUT/$top-pnr.log" | tail -3
  done
else
  echo "SKIP nextpnr (OSS CAD Suite が無い: $OSS)"
fi
