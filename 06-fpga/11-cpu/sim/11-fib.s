; fib.s  フィボナッチ数を 8 ビットに収まる間 OUT に出す (11-11)。1 1 2 3 5 … 233
start:  LDI  1
        ST   x
        ST   y
        OUT             ; 1
loop:   LD   y
        OUT
        ADD  x          ; A ← x + y
        JC   done       ; 255 を超えたら終わり
        ST   t
        LD   y
        ST   x          ; x ← y
        LD   t
        ST   y          ; y ← x + y
        JMP  loop
done:   HLT

        .org 0xF0
x:      .db  0
y:      .db  0
t:      .db  0
