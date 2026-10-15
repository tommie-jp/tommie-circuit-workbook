#!/bin/sh
# 11-6 の確かめ: アセンブラの単体試験を回し、アセンブルした .hex を td4x_rom (11-5) に読ませて
# Verilator と iverilog の両方で走らせる
# 使い方: sh 06-asm-run.sh   (Python 3.10 以上・Verilator 5.x・iverilog が要る)
set -eu
cd "$(dirname "$0")"
OUT=${OUT:-${TMPDIR:-/tmp}/asm-11-6}
mkdir -p "$OUT"

echo "== Python の単体試験"
python3 -I -B 06-asm-test.py

echo "== アセンブル"
python3 -I -B 06-asm.py --isa td4x 06-td4x-sum.s   -o "$OUT/sum.hex"
python3 -I -B 06-asm.py --isa td4x 06-td4x-cmp.s   -o "$OUT/cmp.hex"
python3 -I -B 06-asm.py --isa td4  06-td4-led.s    -o "$OUT/led.hex"
python3 -I -B 06-asm.py --isa td4  06-td4-timer.s  -o "$OUT/timer.hex"
python3 -I -B 06-asm.py --isa td4x 06-td4x-sum.s --list

echo "== 組む"
verilator --binary --timing --trace --quiet-stats -Wno-fatal -Wno-DECLFILENAME --top-module tb_asm \
  --Mdir "$OUT/obj" -o Vtb 05-td4x.v 06-asm-tb.v > "$OUT/build.log" 2>&1
iverilog -g2012 -Wall -Wno-timescale -o "$OUT/iv" 05-td4x.v 06-asm-tb.v

fails=0
run() {   # run <名前> <+引数…>
  name=$1; shift
  for sim in verilator iverilog; do
    if [ $sim = verilator ]; then r=$("$OUT/obj/Vtb" "$@" | grep 'クロック')
    else r=$(vvp -n "$OUT/iv" "$@" | grep 'クロック'); fi
    echo "$name ($sim): $r"
    case "$r" in *PASS*) ;; *) fails=$((fails + 1)) ;; esac
  done
}
run "sum.s           " +rom="$OUT/sum.hex" +cycles=30 +expect=15
run "cmp.s  IN=3     " +rom="$OUT/cmp.hex" +in=3  +cycles=6 +expect=0
run "cmp.s  IN=5     " +rom="$OUT/cmp.hex" +in=5  +cycles=6 +expect=1
run "cmp.s  IN=12    " +rom="$OUT/cmp.hex" +in=12 +cycles=6 +expect=1
run "led.s  (5-8 の A)" +rom="$OUT/led.hex" +cycles=20 +seq=36C88C631136C88C6311
run "timer.s         " +rom="$OUT/timer.hex" +cycles=52 +expect=15 \
    +seq=000111222333444555666777888999AAABBBCCCDDDEEEFFFFF
if [ $fails -eq 0 ]; then echo "PASS (全部)"; else echo "FAIL: $fails 件"; exit 1; fi
