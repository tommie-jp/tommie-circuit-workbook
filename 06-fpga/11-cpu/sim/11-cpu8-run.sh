#!/bin/sh
# 11-11 の確かめ: cpu8 を lint し、アセンブラ (11-6) で 4 本のプログラムを作り、
# Verilator と iverilog で走らせる。yosys で cpu8 (メモリを除く) の大きさを数える
# 使い方: sh 11-cpu8-run.sh   (Python 3.10 以上・Verilator 5.x・iverilog・yosys が要る)
set -eu
cd "$(dirname "$0")"
OUT=${OUT:-${TMPDIR:-/tmp}/cpu8-11-11}
OSS=${OSS:-$HOME/tools/oss-cad-suite/bin}
mkdir -p "$OUT"

# 本文のファイル名はモジュール名と同じ (cpu8.v)。ここでは題の番号を頭に付けたので DECLFILENAME を外す
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module cpu8 11-cpu8.v
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module cpu8_sys 11-cpu8.v 11-cpu8-sys.v
echo "lint cpu8・cpu8_sys: 0 warnings"

for p in sum mul fib ops; do
  python3 -I -B 06-asm.py --isa cpu8 "11-$p.s" -o "$OUT/$p.hex"
done
verilator --binary --timing --trace --quiet-stats -Wno-fatal -Wno-DECLFILENAME --top-module tb_cpu8 \
  --Mdir "$OUT/obj" -o Vtb 11-cpu8.v 11-cpu8-sys.v 11-cpu8-tb.v > "$OUT/build.log" 2>&1
iverilog -g2012 -Wall -Wno-timescale -o "$OUT/iv" 11-cpu8.v 11-cpu8-sys.v 11-cpu8-tb.v

fails=0
for p in sum mul fib ops; do
  for sim in verilator iverilog; do
    if [ $sim = verilator ]; then r=$("$OUT/obj/Vtb" +rom="$OUT/$p.hex" +test=$p | grep -v '^- ')
    else r=$(vvp -n "$OUT/iv" +rom="$OUT/$p.hex" +test=$p | grep -v 'finish called'); fi
    echo "[$sim] $r"
    case "$r" in *PASS*) ;; *) fails=$((fails + 1)) ;; esac
  done
done

echo "== yosys $(yosys -V | cut -d' ' -f2) synth_gowin cpu8 (メモリを除く)"
yosys -p "read_verilog 11-cpu8.v; synth_gowin -top cpu8; stat" | sed -n '/Printing statistics/,$p' \
  | grep -E '^ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
if [ -x "$OSS/yosys" ]; then
  echo "== $("$OSS/yosys" -V | cut -d' ' -f1-2) synth_gowin cpu8 (メモリを除く)"
  "$OSS/yosys" -p "read_verilog 11-cpu8.v; synth_gowin -top cpu8; stat" | sed -n '/Printing statistics/,$p' \
    | grep -E '^ +[0-9]+ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
fi
if [ $fails -eq 0 ]; then echo "PASS (全部)"; else echo "FAIL: $fails 件"; exit 1; fi
