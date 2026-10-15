#!/bin/sh
# 11-10 の確かめ: cpu8i を lint し、アセンブラ (11-6) で作ったプログラムを Verilator と iverilog で回す
# 使い方: sh 10-cpu8i-run.sh   (Python 3.10 以上・Verilator 5.x・iverilog・yosys が要る)
set -eu
cd "$(dirname "$0")"
OUT=${OUT:-${TMPDIR:-/tmp}/cpu8i-11-10}
OSS=${OSS:-$HOME/tools/oss-cad-suite/bin}
mkdir -p "$OUT"

# 本文のファイル名はモジュール名と同じ (cpu8i.v)。ここでは題の番号を頭に付けたので DECLFILENAME を外す
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module cpu8i 10-cpu8i.v
verilator --lint-only -Wall -Wno-DECLFILENAME --quiet-stats --top-module cpu8i_sys 10-cpu8i.v 10-cpu8i-sys.v
echo "lint cpu8i・cpu8i_sys: 0 warnings"

for p in main nosave wait; do python3 -I -B 06-asm.py --isa cpu8i "10-$p.s" -o "$OUT/$p.hex"; done
for p in sum mul fib ops; do python3 -I -B 06-asm.py --isa cpu8i "11-$p.s" -o "$OUT/11-$p.hex"; done
verilator --binary --timing --trace --quiet-stats -Wno-fatal -Wno-DECLFILENAME --top-module tb_cpu8i \
  --Mdir "$OUT/obj" -o Vtb 10-cpu8i.v 10-cpu8i-sys.v 10-cpu8i-tb.v > "$OUT/build.log" 2>&1
iverilog -g2012 -Wall -Wno-timescale -o "$OUT/iv" 10-cpu8i.v 10-cpu8i-sys.v 10-cpu8i-tb.v

fails=0
t() {   # t <+引数…>
  for sim in verilator iverilog; do
    if [ $sim = verilator ]; then r=$("$OUT/obj/Vtb" "$@" | grep -v '^- ')
    else r=$(vvp -n "$OUT/iv" "$@" | grep -v 'finish called'); fi
    echo "[$sim] $r"
    case "$r" in *PASS*) ;; *) fails=$((fails + 1)) ;; esac
  done
}
t +rom="$OUT/main.hex"   +test=main
t +rom="$OUT/nosave.hex" +test=nosave
t +rom="$OUT/wait.hex"   +test=wait
t +rom="$OUT/11-sum.hex" +test=masked +want=55
t +rom="$OUT/11-mul.hex" +test=masked +want=143
t +rom="$OUT/11-fib.hex" +test=masked +want=233

if [ -x "$OSS/yosys" ]; then
  for top in cpu8 cpu8i; do
    src=11-cpu8.v; [ $top = cpu8i ] && src=10-cpu8i.v
    echo "== $("$OSS/yosys" -V | cut -d' ' -f1-2) synth_gowin $top (メモリを除く)"
    "$OSS/yosys" -p "read_verilog $src; synth_gowin -top $top; stat" | sed -n '/Printing statistics/,$p' \
      | grep -E '^ +[0-9]+ +(ALU|DFF|LUT|MUX2)' | awk '!seen[$0]++' || true
  done
fi
if [ $fails -eq 0 ]; then echo "PASS (全部)"; else echo "FAIL: $fails 件"; exit 1; fi
