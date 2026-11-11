#!/bin/sh
# 13-8: PC 版と Wasm 版 (Node) で同じ 2 行を打ち、速さと出力を比べる。
# 使い方: sh 08-speed.sh <soft-fpga-riscv-linux の場所> [回数 (既定 3)]
#   先に make linux-sd-save (保存ファイル) と make wasm (Wasm 版) を済ませておく。
set -eu
H=$(cd "$(dirname "$0")" && pwd)
R=$(cd "${1:?usage: sh 08-speed.sh <soft-fpga-riscv-linux> [runs]}" && pwd)
N=${2:-3}
STATE=$(make -s -C "$R/sim" state-name)
i=1
while [ "$i" -le "$N" ]; do
    # PC 版: 出た字は標準出力。頭の "main: restored" の行と、止まった後の報告 (==== から後ろ) を除いて比べる
    printf 'ls /\ncat /proc/cpuinfo\n' | "$R/build/mmrisc2/obj/Vtop" "+restore=$STATE" +maxcycles=1500000000 > "$H/.pc.out" 2>&1
    # 終わりの改行の数は比べない ($(...) が落とす)
    printf '%s\n' "$(sed -e '/^main: restored/d' -e '/^=====/,$d' -e '/^@@/d' "$H/.pc.out" | tr -d '\r')" > "$H/.pc.txt"
    echo "pc: $(grep 'cycles/s' "$H/.pc.out" | sed 's/^ *//'), $(wc -c < "$H/.pc.txt" | tr -d ' ') chars"
    SIM_MJS="$R/build/mmrisc2/wasm/sim.mjs" node "$H/08-wasm-speed.mjs" "$STATE.gz" "--out=$H/.wasm.out"
    printf '%s\n' "$(tr -d '\r' < "$H/.wasm.out")" > "$H/.wasm.txt"
    cmp -s "$H/.pc.txt" "$H/.wasm.txt" && echo "output: same ($(wc -c < "$H/.wasm.txt" | tr -d ' ') chars without CR)" || echo "output: DIFFERENT"
    SIM_MJS="$R/build/mmrisc2/wasm/sim.mjs" node "$H/08-wasm-speed.mjs" "$STATE.gz" --la-off
    i=$((i + 1))
done
rm -f "$H/.pc.out" "$H/.pc.txt" "$H/.wasm.out" "$H/.wasm.txt"
