; sum.s  1 + 2 + … + n を求めて OUT に出す (11-11)。n は 0xF1 番地 (既定 10 → 55)
start:  LDI  0
        ST   sum
loop:   LD   n          ; LD はゼロフラグを書く
        JZ   done       ; n が 0 なら終わり
        ADD  sum
        ST   sum        ; sum ← sum + n
        LD   n
        SUBI 1
        ST   n          ; n ← n - 1
        JMP  loop
done:   LD   sum
        OUT
        HLT

        .org 0xF0
sum:    .db  0
n:      .db  10
